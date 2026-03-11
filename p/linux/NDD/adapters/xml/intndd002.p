/********************************************************************************
** Cancelamento de notas fiscais
*******************************************************************************/
{include/i-prgvrs.i INTNDD002 2.00.00.023 } /*** 010023 ***/

{cdp/cdcfgdis.i}

/*LOCAL VARIABLES - BEGIN*/
DEFINE VAR lCreateMsg      AS LOGICAL   INITIAL FALSE NO-UNDO.
DEFINE VAR pSendSuccess    AS LOGICAL   INITIAL YES   NO-UNDO.
DEFINE VAR pTotalErrors    AS INTEGER   INITIAL ?     NO-UNDO.
DEFINE VAR c-motivo        AS CHARACTER               NO-UNDO.

DEFINE TEMP-TABLE tt_log_erro NO-UNDO
       FIELD ttv_num_cod_erro  AS integer   INITIAL ?
       FIELD ttv_des_msg_ajuda AS character INITIAL ?
       FIELD ttv_des_msg_erro  AS character INITIAL ?.

def temp-table tt_nfe_erro  no-undo
    field cStat     as CHAR    /* C¢digo do Status da resposta */
    field chNFe     as CHAR   /* Chave de acesso da Nota Fiscal Eletrìnica */
    field dhRecbto  as CHAR   /* Data/Hora da homologacao do cancelamento */
    field nProt     as CHAR.  /* N£mero do protocolo de aprovacao */


/*---------------------------------------------------------
             TRATAMENTO PARA ACENTUAÄ«O
---------------------------------------------------------*/

{include/i-freeac.i}

DEFINE VARIABLE c-string-com-acento AS CHARACTER   NO-UNDO.
DEFINE VARIABLE c-string-sem-acento AS CHARACTER   NO-UNDO.

/*-------------------------------------------------------*/
/* Variaveis e funá‰es para tratamento de XML - NDD Web */
{xmlinc/xmlndd.i}
{utp/ut-glob.i}

/* Handle do BusinessContent */
DEF VAR hBusinessContent AS HANDLE NO-UNDO.
CREATE X-DOCUMENT hBusinessContent.

DEF VAR hQueryResult AS HANDLE NO-UNDO.

/* Carrega API auxiliar processamento de XML */
{xmlinc/xmlloadgenxml.i &GenXml="hGenXML" &GXReturnValue="cReturnValue"}
IF cReturnValue <> "OK":U
THEN DO:
     CREATE TT_LOG_ERRO.
     ASSIGN TT_LOG_ERRO.TTV_NUM_COD_ERRO  = 17006.
     /* Inicio -- Projeto Internacional */
     {utp/ut-liter.i "Erro_ao_carregar_a_API_XML" *}
     ASSIGN TT_LOG_ERRO.TTV_DES_MSG_ERRO  = RETURN-VALUE + ": "+ string(cReturnValue)
            tt_log_erro.ttv_des_msg_ajuda = tt_log_erro.ttv_des_msg_erro.
     RETURN string(cReturnValue).
END.

PROCEDURE PIUpsert:

    DEFINE INPUT  PARAM p-motivo    AS CHARACTER           NO-UNDO.
    DEFINE INPUT  PARAM p-row-table AS ROWID               NO-UNDO. 
    DEFINE OUTPUT PARAM TABLE FOR tt_log_erro.

    DEFINE VAR iCount                    AS INTEGER   INITIAL ? NO-UNDO.
    DEFINE VAR iId                       AS INTEGER   INITIAL ? NO-UNDO.
    DEFINE VAR iIdDatasulMessage         AS INTEGER   INITIAL ? NO-UNDO.
    DEFINE VAR iIdReturnContent          AS INTEGER   INITIAL ? NO-UNDO.
    DEFINE VAR iIdListOfExtraInformation AS INTEGER   INITIAL ? NO-UNDO. 
    DEFINE VAR iIdExtraInformation       AS INTEGER   INITIAL ? NO-UNDO. 
    DEFINE VAR pErrorId                  AS INTEGER   INITIAL ? NO-UNDO.
    DEFINE VAR pErrorType                AS CHARACTER INITIAL ? NO-UNDO.
    DEFINE VAR pTotalErrors              AS INTEGER   INITIAL ? NO-UNDO.
    DEFINE VAR cKey                      AS CHARACTER INITIAL ? NO-UNDO.
    DEFINE VAR cStatus                   AS CHARACTER           NO-UNDO.
    DEFINE VAR hOutputXML                AS HANDLE              NO-UNDO.
    DEFINE VAR cVersaoLayoutNFe          AS CHARACTER           NO-UNDO.
    
    ASSIGN c-motivo = p-motivo.

    /*--- Tratamento Acentuacao ---*/
    ASSIGN c-string-com-acento = c-motivo
           c-string-sem-acento = fn-free-accent(c-string-com-acento).

    ASSIGN c-motivo = c-string-sem-acento.
    /*--- FIM Tratamento Acentuacao ---*/
    
    /* RESETA OS VALORES */
    RUN reset IN hGenXml.
    
    /* SETA VALOR DE ENCODING */
    RUN setEncoding IN hGenXml ("UTF-8":U).

    /*
    RUN addNode IN hGenXml (getStack(), 
                            "Upsert":U, 
                            "":U, 
                            OUTPUT iId).
    addStack(iId).
    */

    IF  NOT AVAIL estabelec
    OR (AVAIL estabelec
    AND estabelec.cod-estabel <> nota-fiscal.cod-estabel) THEN
        FOR FIRST estabelec NO-LOCK
            WHERE estabelec.cod-estabel = nota-fiscal.cod-estabel: 
        END.

    ASSIGN cVersaoLayoutNFe = &if "{&bf_dis_versao_ems}" >= "2.071" &then 
                                 TRIM(estabelec.des-vers-layout)
                              &else 
                                 TRIM(SUBSTRING(estabelec.char-1,173,10))
                              &endif WHEN AVAIL estabelec NO-ERROR.
    
    RUN addNode IN hGenXml (getStack(), 
                            "cancNFe":U, 
                            "":U, 
                            OUTPUT iId).
    RUN setAttribute IN hGenXml (INPUT iId, "versao", (IF cVersaoLayoutNFe = "1.10":U THEN "1.07":U
                                                                                      ELSE cVersaoLayoutNFe)).

    addStack(iId).

    
    
    /* RUN addNode IN hGenXml (getStack(),  */
    /*                         "versao":U,  */
    /*                         "1.06",      */
    /*                         OUTPUT iId). */
    
    RUN addNode IN hGenXml (getStack(), 
                            "infCanc":U, 
                            "":U, 
                            OUTPUT iId).

    RUN setAttribute IN hGenXml (INPUT iId, "Id",     ("NFe" + 
                                                       &IF "{&bf_dis_versao_ems}":U >= "2.07":U &THEN TRIM(REPLACE(nota-fiscal.cod-chave-aces-nf-eletro," ",""))
						       &else TRIM(REPLACE(SUBSTRING(nota-fiscal.char-2,3,60)," ",""))
                                                       &endif  )).

    addStack(iId).
    
    /* alterado para homologá∆o pra testes ndd web */
    RUN addNode IN hGenXml (getStack(), "tpAmb":U, STRING(i-job-ndd,"9"), OUTPUT iId).
    /*RUN addNode IN hGenXml (getStack(), "xServ":U, "CANCELAR":U, OUTPUT iId).*/

    /*
    &if "{&bf_dis_versao_ems}" < "2.07" &THEN
        RUN addNode IN hGenXml (getStack(), 
                                "Id":U, 
                                "ID" + REPLACE(SUBSTRING(nota-fiscal.char-2,3,60)," ",""), 
                                OUTPUT iId).
    &else
        RUN addNode IN hGenXml (getStack(), 
                                "Id":U, 
                                "ID" + REPLACE(STRING(nota-fiscal.cod-chave-aces-nf-eletro)," ",""), 
                                OUTPUT iId).
    &ENDIF
    */

    &if "{&bf_dis_versao_ems}" < "2.07" &THEN
        RUN addNode IN hGenXml (getStack(), 
                                "chNFe":U, 
                                SUBSTRING(nota-fiscal.char-2,3,60), 
                                OUTPUT iId).

        RUN addNode IN hGenXml (getStack(), 
                                "nProt":U, 
                                SUBSTR(nota-fiscal.char-1,97,15), 
                                OUTPUT iId).
    &ELSE
        RUN addNode IN hGenXml (getStack(), 
                                "chNFe":U, 
                                STRING(nota-fiscal.cod-chave-aces-nf-eletro), 
                                OUTPUT iId).

        RUN addNode IN hGenXml (getStack(), 
                                "nProt":U, 
                                nota-fiscal.cod-protoc, 
                                OUTPUT iId).
    &ENDIF
    

    RUN addNode IN hGenXml (getStack(), 
                           "xJust":U, 
                            c-motivo, 
                            OUTPUT iId).
    
    delStack().
    delStack().
    delStack().
    delStack().
    
    /* OBTEM O XML NUMA HANDLE */
    RUN generateXML IN hGenXml (OUTPUT hBusinessContent).

    def var cFile as character.
    def var i-id as integer.
    /*cFile = "t:\" + nota-fiscal.cod-estabel + nota-fiscal.serie + "-" + nota-fiscal.nr-nota-fis + ".XML".*/
    /*define buffer bint_ndd_envio for int_ndd_envio.*/
    hBusinessContent:SAVE("LONGCHAR",cXML).    
    do transaction:
        ASSIGN c-job-ndd = nota-fiscal.cod-estabel.
        IF i-job-ndd = 1 THEN DO:
           /*IF nota-fiscal.cod-estabel <> "973" THEN*/
              ASSIGN c-job-ndd = "PD_" + nota-fiscal.cod-estabel.
           /*ELSE 
              ASSIGN c-job-ndd = nota-fiscal.cod-estabel.*/
        END.
        IF i-job-ndd = 2 THEN DO:
           /*IF nota-fiscal.cod-estabel <> "973" THEN*/
              ASSIGN c-job-ndd = "HM_" + nota-fiscal.cod-estabel.
           /*ELSE 
              ASSIGN c-job-ndd = nota-fiscal.cod-estabel.*/
        END.
        IF i-job-ndd = 3 THEN DO:
           /*IF nota-fiscal.cod-estabel <> "973" THEN*/
              ASSIGN c-job-ndd = "TS_" + nota-fiscal.cod-estabel.
           /*ELSE 
              ASSIGN c-job-ndd = nota-fiscal.cod-estabel.*/
        END.
        /*
        if l-log then do: 
            cFile = session:temp-directory + "\eformsInserirDocumento.xml".
            copy-lob cXML to FILE cFile.
        end.
        */
        /* Gera Header do envio para NDD */
        run pi-geraHeaderInserirDocumentoNDD ("2" /* Cancelamento */, output cHeader).
        /*
        if l-log then do: 
            cFile = session:temp-directory + "\eformsInserirHeader.xml".
            copy-lob cHeader to FILE cFile.
        end.
        */

        /* envio p/ WebService */
        run pi-conectaWebServer (input 'WSInserirDocumento.wsdl',
                                 input 'WSInserirDocumento',
                                 input nota-fiscal.cod-estabel,
                                 output l-connected).
        if l-connected then do:
            run WSInserirDocumentoSoap set hWSPortaSoap on hWebService.

            run InserirDocumento in hWSPortaSoap(input  cHeader, 
                                                 input  cXML, 
                                                 output cReturnValue).

            /*
            if l-log then do:
                cFile = session:temp-directory + "\eformsInserirRetorno.xml".
                copy-lob cReturnValue to FILE cFile.
            end.
            */

            /* Trata Retorno do WebService */
            run reset in hGenXML.
            run loadXMLFromLongChar in hGenXML (cReturnValue).
            run loadValue in hGenXML ("protocolo", 1, output cProtocolo).
    
            if cProtocolo = ? or cProtocolo = "0" then do:
                cMensagem = "".
                cCodigoErro = "".
                run loadValue in hGenXML ("codigo", 4, output cCodigoErro) .
                cCodigoErro = OnlyNumbers(string(cCodigoErro)).
                run loadValue in hGenXML ("mensagem", 4, output cMensagem) .
                cMensagem = PrintChar(string(cMensagem)).
                run loadValue in hGenXML ("observacao", 4, output cReturnValue) .
                cMensagem = cMensagem + "-" + PrintChar(string(cReturnValue)).
                run pi-cria-ret-nf-eletro (nota-fiscal.cod-estabel,
                                           nota-fiscal.serie,
                                           nota-fiscal.nr-nota-fis).
            end.
            else do:
    
                &if "{&bf_dis_versao_ems}" >= "2.071" &then 
                ASSIGN nota-fiscal.idi-sit-nf-eletro = 12 /* Em processo de cancelamento */
                       nota-fiscal.cd-vendedor = c-seg-usuario.
                &endif
                for last int_ndd_envio exclusive-lock where
                    int_ndd_envio.STATUSNUMBER = 0 /* A processar */ and
                    int_ndd_envio.JOB          = c-job-ndd           and
                    int_ndd_envio.DOCUMENTUSER = c-seg-usuario       and
                    int_ndd_envio.KIND         = 2 /* Cancelamento */         and
                    int_ndd_envio.cod_estabel  = nota-fiscal.cod-estabel and
                    int_ndd_envio.serie        = nota-fiscal.serie       and
                    int_ndd_envio.nr_nota_fis  = nota-fiscal.nr-nota-fis and
                    int_ndd_envio.protocolo    = "": end.
                if not avail int_ndd_envio then do:
                    /* Base Progress n∆o tem trigger para incremento autom†tico */
                    iId = next-value(seq-int-ndd-envio).
                    create int_ndd_envio.
                    assign int_ndd_envio.ID           = iId /* base Progress */
                           int_ndd_envio.STATUSNUMBER = 0 /* A processar */
                           int_ndd_envio.JOB          = c-job-ndd 
                           int_ndd_envio.DOCUMENTUSER = c-seg-usuario
                           int_ndd_envio.KIND         = 2 /* Cancelamento */
                           int_ndd_envio.cod_estabel  = nota-fiscal.cod-estabel 
                           int_ndd_envio.serie        = nota-fiscal.serie 
                           int_ndd_envio.nr_nota_fis  = nota-fiscal.nr-nota-fis.
                end.
                copy-lob cXML to int_ndd_envio.DOCUMENTDATA.
                /* Guardar Protocolo para Consulta Posterior */
                assign  int_ndd_envio.protocolo    = cProtocolo
                        int_ndd_envio.dt_envio     = today
                        int_ndd_envio.hr_envio     = time.
                run pi-consultarProtocolo.
            end. /* protocolo inserido com sucesso */
            release int_ndd_envio.
            run pi-LimpaObjetos.
        end. /* conected */
        else do:
            cCodigoErro = '9999'. cMensagem = "WebService NDD n∆o conectado".
            run pi-cria-ret-nf-eletro (nota-fiscal.cod-estabel,
                                       nota-fiscal.serie,
                                       nota-fiscal.nr-nota-fis).
        end.
    end. /* transaction */

    RETURN "OK":U.
    
END PROCEDURE.


PROCEDURE PITransUpsert:

    DEFINE INPUT  PARAM p-motivo    AS CHARACTER           NO-UNDO.
    DEFINE INPUT  PARAM p-row-table AS ROWID               NO-UNDO. 
    DEFINE OUTPUT PARAM TABLE FOR tt_log_erro.
    DEFINE OUTPUT PARAM TABLE FOR tt_nfe_erro.

    EMPTY TEMP-TABLE tt_log_erro NO-ERROR.
    EMPTY TEMP-TABLE tt_nfe_erro NO-ERROR.
    
    FOR FIRST nota-fiscal EXCLUSIVE-LOCK
            WHERE ROWID(nota-fiscal) = p-row-table: END.
    
    IF AVAIL nota-fiscal THEN DO:
    
      FOR FIRST ser-estab NO-LOCK WHERE 
          ser-estab.cod-estabel = nota-fiscal.cod-estabel AND
          ser-estab.serie = nota-fiscal.serie:
          IF ser-estab.forma-emis = 2 /* Manual */ THEN do:
              CREATE TT_LOG_ERRO.
              ASSIGN TT_LOG_ERRO.TTV_NUM_COD_ERRO  = 17006.
              ASSIGN TT_LOG_ERRO.TTV_DES_MSG_ERRO  = "Nota fiscal foi importada-Nao pode ser cancelada!"
                     tt_log_erro.ttv_des_msg_ajuda = tt_log_erro.ttv_des_msg_erro.
              RETURN "NOK".
          END.
      END.

      EMPTY TEMP-TABLE tt_nfe_erro.
    
      RUN PIUpsert (INPUT p-motivo,
                    INPUT p-row-table,
                    OUTPUT TABLE tt_log_erro).
    
    END.
    ELSE DO:
        CREATE TT_LOG_ERRO.
        ASSIGN TT_LOG_ERRO.TTV_NUM_COD_ERRO  = 17006.
        ASSIGN TT_LOG_ERRO.TTV_DES_MSG_ERRO  = "Nota fiscal NAO esta disponivel"
               tt_log_erro.ttv_des_msg_ajuda = tt_log_erro.ttv_des_msg_erro.
        RETURN "NOK".
    END.

END PROCEDURE.
