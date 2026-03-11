/********************************************************************************
** Inutiliza‡Æo de N£meros
*******************************************************************************/
{include/i-prgvrs.i INTNDD003 2.00.00.019 } /*** 010019 ***/

{cdp/cdcfgdis.i}

DEFINE TEMP-TABLE ttInutInvoiceDocument NO-UNDO
     FIELD ano AS INTEGER INITIAL ?  /*Ano de inutilização da numeração*/
     FIELD CNPJ AS CHARACTER INITIAL ?  /*CNPJ do emitente*/
     FIELD cUF AS CHARACTER INITIAL ?  /*Código da UF do emitente*/
     FIELD id AS CHARACTER INITIAL ? /* Identificador da Tag a ser assinada */
     FIELD infInutID AS INTEGER INITIAL ?
     FIELD mod AS CHARACTER INITIAL ?  /*Modelo da NF-e (55, etc.)*/
     FIELD nNFFin AS CHARACTER INITIAL ?  /*Número da NF-e final*/
     FIELD nNFIni AS CHARACTER INITIAL ?  /*Número da NF-e inicial*/
     FIELD serie AS CHARACTER INITIAL ?  /*Série da NF-e*/
     FIELD signature AS CHARACTER INITIAL ?
     FIELD tpAmb AS CHARACTER INITIAL ?  /*Identificação do Ambiente: 1 - Produção 2 - Homologação*/
     FIELD versao AS CHARACTER INITIAL ?
     FIELD xJust AS CHARACTER INITIAL ?  /*Justificativa do pedido de inutilização*/
     FIELD xServ AS CHARACTER INITIAL ?  /*Serviço Solicitado*/
     INDEX ixinfInutID IS PRIMARY UNIQUE infInutID ASCENDING.

DEFINE VAR lCreateMsg AS LOGICAL INITIAL FALSE NO-UNDO.
DEFINE VAR pSendSuccess AS LOGICAL INITIAL YES NO-UNDO.
DEFINE VAR pTotalErrors AS INTEGER INITIAL ? NO-UNDO.

DEFINE TEMP-TABLE tt_log_erro NO-UNDO
     FIELD ttv_num_cod_erro AS integer INITIAL ?
     FIELD ttv_des_msg_ajuda AS character INITIAL ?
     FIELD ttv_des_msg_erro AS character INITIAL ?
.

def temp-table tt_nfe_erro  no-undo
    field cStat     as CHAR    /* C¢digo do Status da resposta */
    field chNFe     as CHAR   /* Chave de acesso da Nota Fiscal Eletr“nica */
    field dhRecbto  as CHAR   /* Data/Hora da homologacao do cancelamento */
    field nProt     as CHAR.  /* N£mero do protocolo de aprovacao */


/*---------------------------------------------------------
                  TRATAMENTO PARA ACENTUA€ÇO
---------------------------------------------------------*/

{include/i-freeac.i}

DEFINE VARIABLE c-string-com-acento AS CHARACTER   NO-UNDO.
DEFINE VARIABLE c-string-sem-acento AS CHARACTER   NO-UNDO.

/*-------------------------------------------------------*/

/* Variaveis e fun‡äes para tratamento de XML - NDD Web */
{xmlinc/xmlndd.i}


/* RETIRAR APOS RESOLVER NOME DO BANCO */
/* RETIRAR APOS RESOLVER NOME DO BANCO */
/* RETIRAR APOS RESOLVER NOME DO BANCO */
/* RETIRAR APOS RESOLVER NOME DO BANCO */
i-job-ndd = 2.
/* RETIRAR APOS RESOLVER NOME DO BANCO */
/* RETIRAR APOS RESOLVER NOME DO BANCO */
/* RETIRAR APOS RESOLVER NOME DO BANCO */
/* RETIRAR APOS RESOLVER NOME DO BANCO */

/*{adapters/xml/ep2/axsep003extradeclarations.i}*/
{utp/ut-glob.i}

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

/* Handle do BusinessContent */
DEF VAR hBusinessContent AS HANDLE NO-UNDO.
CREATE X-DOCUMENT hBusinessContent.

PROCEDURE PIUpsert:
    
    DEFINE INPUT  PARAM TABLE FOR ttInutInvoiceDocument.
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
    
    FIND FIRST ttInutInvoiceDocument NO-ERROR.
    
     /* RESETA OS VALORES */
     RUN reset IN hGenXml.

     /* SETA VALOR DE ENCODING */
     RUN setEncoding IN hGenXml ("UTF-8").


    /*
     RUN addNode IN hGenXml (getStack(), "Upsert", "", OUTPUT iId).
     addStack(iId).
     */
          RUN addNode IN hGenXml (getStack(), "inutNFe", "", OUTPUT iId).
          addStack(iId).
              RUN setAttribute IN hGenXml (INPUT iId, "xmlns", "http://www.portalfiscal.inf.br/nfe").
              RUN setAttribute IN hGenXml (INPUT iId, "versao", ttInutInvoiceDocument.versao).
                
               /*RUN addNode IN hGenXml (getStack(), "versao", ttInutInvoiceDocument.versao, OUTPUT iId).*/

               /*FOR EACH ttInutInvoiceDocument:*/
                    RUN addNode IN hGenXml (getStack(), "infInut", "", OUTPUT iId).
                    addStack(iId).
                        RUN setAttribute IN hGenXml (INPUT iId, "Id", ttInutInvoiceDocument.id).

                         /*RUN addNode IN hGenXml (getStack(), "id", ttInutInvoiceDocument.id, OUTPUT iId).*/
                         RUN addNode IN hGenXml (getStack(), "tpAmb", ttInutInvoiceDocument.tpAmb, OUTPUT iId).
                         RUN addNode IN hGenXml (getStack(), "xServ", ttInutInvoiceDocument.xServ, OUTPUT iId).
                         RUN addNode IN hGenXml (getStack(), "cUF", ttInutInvoiceDocument.cUF, OUTPUT iId).
                         RUN addNode IN hGenXml (getStack(), "ano", ttInutInvoiceDocument.ano, OUTPUT iId).
                         RUN addNode IN hGenXml (getStack(), "CNPJ", ttInutInvoiceDocument.CNPJ, OUTPUT iId).
                         RUN addNode IN hGenXml (getStack(), "mod", ttInutInvoiceDocument.mod, OUTPUT iId).
                         RUN addNode IN hGenXml (getStack(), "serie", ttInutInvoiceDocument.serie, OUTPUT iId).
                         RUN addNode IN hGenXml (getStack(), "nNFIni", ttInutInvoiceDocument.nNFIni, OUTPUT iId).
                         RUN addNode IN hGenXml (getStack(), "nNFFin", ttInutInvoiceDocument.nNFFin, OUTPUT iId).
                         RUN addNode IN hGenXml (getStack(), "xJust", ttInutInvoiceDocument.xJust, OUTPUT iId).
                    delStack().

             /*  END.*/
          delStack().


     delStack().
         
    /* OBTEM O XML NUMA HANDLE */
    RUN generateXML IN hGenXml (OUTPUT hBusinessContent).
    /*cFile = "t:\" + ttInutInvoiceDocument.serie + "_" + ttInutInvoiceDocument.nNFIni + ".XML".*/
    /*define buffer bint_ndd_envio for int_ndd_envio.*/

    define variable cXML as longchar no-undo.
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
        IF l-log then do: 
            cFile = "t:" + "\NDD\eformsInserirDocumento.xml".
            copy-lob cXML to FILE cFile.
        end.
        */

        /* Gera Header do envio para NDD */
        run pi-geraHeaderInserirDocumentoNDD ("3" /* Inutiliza‡Æo */, output cHeader).
        /*
        if l-log then do: 
            cFile = "t:" + "\NDD\eformsInserirHeader.xml".
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
                cFile = "t:" + "\NDD\eformsInserirRetorno.xml".
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
                ASSIGN nota-fiscal.idi-sit-nf-eletro = 13 /* Em processo de inutiliza‡Æo */
                       nota-fiscal.cd-vendedor = c-seg-usuario.
                &endif

                for last int_ndd_envio exclusive-lock where
                    int_ndd_envio.STATUSNUMBER = 0 /* A processar */ and
                    int_ndd_envio.JOB          = c-job-ndd           and
                    int_ndd_envio.DOCUMENTUSER = c-seg-usuario       and
                    int_ndd_envio.KIND         = 3 /* Inutiliza‡Æo */ and
                    int_ndd_envio.cod_estabel  = nota-fiscal.cod-estabel and
                    int_ndd_envio.serie        = nota-fiscal.serie       and
                    int_ndd_envio.nr_nota_fis  = nota-fiscal.nr-nota-fis and
                    int_ndd_envio.protocolo    = "": end.
                if not avail int_ndd_envio then do:
                    /* Base Progress nÆo tem trigger para incremento autom tico */
                    iId = next-value(seq-int-ndd-envio).
                    create int_ndd_envio.
                    assign int_ndd_envio.ID           = iId /* base Progress */
                           int_ndd_envio.STATUSNUMBER = 0 /* A processar */
                           int_ndd_envio.JOB          = c-job-ndd 
                           int_ndd_envio.DOCUMENTUSER = c-seg-usuario
                           int_ndd_envio.KIND         = 3 /* Inutiliza‡Æo */
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
            cCodigoErro = '9999'. cMensagem = "WebService NDD nÆo conectado".
            run pi-cria-ret-nf-eletro (nota-fiscal.cod-estabel,
                                       nota-fiscal.serie,
                                       nota-fiscal.nr-nota-fis).
        end.
    end.

END PROCEDURE.

PROCEDURE PITransUpsert:
    
    DEFINE INPUT  PARAM pcUf                  AS CHARACTER NO-UNDO.
    DEFINE INPUT  PARAM pAnoInut              AS INTEGER   NO-UNDO.
    DEFINE INPUT  PARAM pCnpj                 AS CHARACTER NO-UNDO.
    DEFINE INPUT  PARAM pModelo               AS CHARACTER NO-UNDO.
    DEFINE INPUT  PARAM pSerie                AS CHARACTER NO-UNDO.
    DEFINE INPUT  PARAM pnNfeIni              AS CHARACTER NO-UNDO.
    DEFINE INPUT  PARAM pnNfeFin              AS CHARACTER NO-UNDO.
    DEFINE INPUT  PARAM pJust                 AS CHARACTER NO-UNDO.
    DEFINE INPUT  PARAM pRowidNotaFiscal      AS ROWID     NO-UNDO.
    DEFINE OUTPUT PARAM TABLE FOR tt_log_erro.
    DEFINE OUTPUT PARAM TABLE FOR tt_nfe_erro.
    
    DEF VAR c-serie          AS CHARACTER  NO-UNDO. 
    DEF VAR cVersaoLayoutNFe AS CHARACTER NO-UNDO.


    EMPTY TEMP-TABLE tt_log_erro           NO-ERROR.
    EMPTY TEMP-TABLE tt_nfe_erro           NO-ERROR.
    EMPTY TEMP-TABLE ttInutInvoiceDocument NO-ERROR.

    FOR FIRST nota-fiscal EXCLUSIVE-LOCK
        WHERE ROWID(nota-fiscal) = pRowidNotaFiscal: END.
    IF NOT AVAIL nota-fiscal THEN DO:
        CREATE TT_LOG_ERRO.
        ASSIGN TT_LOG_ERRO.TTV_NUM_COD_ERRO  = 17006.
        ASSIGN TT_LOG_ERRO.TTV_DES_MSG_ERRO  = "Nota fiscal NAO esta disponivel"
               tt_log_erro.ttv_des_msg_ajuda = tt_log_erro.ttv_des_msg_erro.
        RETURN "NOK".
    END.
    FOR FIRST ser-estab NO-LOCK WHERE 
        ser-estab.cod-estabel = nota-fiscal.cod-estabel AND
        ser-estab.serie = nota-fiscal.serie:
        IF ser-estab.forma-emis = 2 /* Manual */ THEN DO:
            CREATE TT_LOG_ERRO.
            ASSIGN TT_LOG_ERRO.TTV_NUM_COD_ERRO  = 17006.
            ASSIGN TT_LOG_ERRO.TTV_DES_MSG_ERRO  = "Nota fiscal foi importada-Nao pode ser cancelada!"
                   tt_log_erro.ttv_des_msg_ajuda = tt_log_erro.ttv_des_msg_erro.
            RETURN "NOK".
        END.
    END.

    IF  NOT AVAIL estabelec
    OR (AVAIL estabelec
    AND estabelec.cod-estabel <> nota-fiscal.cod-estabel) THEN
        FOR FIRST estabelec NO-LOCK
            WHERE estabelec.cod-estabel = nota-fiscal.cod-estabel: 
        END.
    
    ASSIGN cVersaoLayoutNFe = &if "{&bf_dis_versao_ems}" >= "2.071" &then 
                                 Trim(estabelec.des-vers-layout)
                              &else 
                                 TRIM(SUBSTRING(estabelec.char-1,173,10))
                              &endif WHEN AVAIL estabelec NO-ERROR.
                              
    FOR FIRST unid-feder FIELDS( &IF "{&bf_dis_versao_ems}" < "2.07" &THEN char-1 &ELSE cod-uf-ibge &ENDIF) 
        WHERE unid-feder.estado = pcUf AND 
              unid-feder.pais   = 'Brasil':U NO-LOCK: END.

    CREATE ttInutInvoiceDocument.
    ASSIGN ttInutInvoiceDocument.ano       = pAnoInut
           ttInutInvoiceDocument.cnpj      = pCnpj
           ttInutInvoiceDocument.cUf       = &IF "{&bf_dis_versao_ems}" < "2.07" &THEN SUBSTR(unid-feder.char-1,1,2) 
                                             &ELSE unid-feder.cod-uf-ibge &ENDIF WHEN AVAIL unid-feder
           ttInutInvoiceDocument.mod       = pModelo
           ttInutInvoiceDocument.nNFFin    = pnNfeFin
           ttInutInvoiceDocument.nNFIni    = pnNfeIni
           ttInutInvoiceDocument.serie     = pSerie
           ttInutInvoiceDocument.tpAmb     = STRING(i-job-ndd,"9") 
           ttInutInvoiceDocument.versao    = (IF cVersaoLayoutNFe = "1.10":U THEN "1.06":U
                                                                             ELSE cVersaoLayoutNFe)
           ttInutInvoiceDocument.xJust     = pJust
           ttInutInvoiceDocument.xServ     = "INUTILIZAR":U
           ttInutInvoiceDocument.Signature = " ":U.
           ttInutInvoiceDocument.id        = "ID":U + STRING(&if '{&bf_dis_versao_ems}' >= '2.07':U &then unid-feder.cod-uf-ibge &else int(unid-feder.char-1) &endif,"99") + string(pAnoInut,"99") + 
                                             estabelec.cgc + pModelo + string(int(pSerie),"999") + string(int(pnNfeIni),"999999999") + string(int(pnNfeFin),"999999999").

    RUN PIUpsert ( INPUT TABLE ttInutInvoiceDocument,     /* Dados do Pedido de Cancelamento da nota fiscal  */
                   OUTPUT TABLE tt_log_erro ).

END PROCEDURE.


