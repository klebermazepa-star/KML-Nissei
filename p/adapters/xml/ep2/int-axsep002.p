/********************************************************************************
** Copyright DATASUL S.A. (1997)
** Todos os Direitos Reservados.
**
** Este fonte e de propriedade exclusiva da DATASUL, sua reproducao
** parcial ou total por qualquer meio, so podera ser feita mediante
** autorizacao expressa.
*******************************************************************************/
{include/i-prgvrs.i INT-AXSEP002 2.00.00.023 } /*** 010023 ***/

{cdp/cdcfgdis.i}

&IF DEFINED(bf_dis_nfe) &THEN 

/*LOCAL VARIABLES - BEGIN*/
DEFINE VAR cReturnValue    AS CHARACTER INITIAL ?     NO-UNDO.
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



/*LOCAL VARIABLES - END*/
DEFINE VAR cProtocolo AS CHARACTER NO-UNDO.
DEFINE VAR cMotivo    AS CHARACTER NO-UNDO.

/*PARAMETERS - BEGIN*/
DEFINE OUTPUT PARAM TABLE FOR tt_log_erro.
/*PARAMETERS - END*/

{utp/ut-glob.i}

/* Handle do BusinessContent */
DEF VAR hBusinessContent AS HANDLE NO-UNDO.
CREATE X-DOCUMENT hBusinessContent.

DEF VAR hQueryResult AS HANDLE NO-UNDO.

/* VARIABEL PARA ARMAZENAR OS VALORES OBTIDOS NA INICIALIZACAO DO loalGenXml */
DEF VAR hGenXml AS HANDLE NO-UNDO.

/* VERIFICA SE APIXML ESTA NA MEMORIA */
{xmlinc/xmlloadgenxml.i &GenXml="hGenXml" &GXReturnValue="cReturnValue"}
IF cReturnValue <> "OK":U
THEN DO:
     CREATE TT_LOG_ERRO.
     ASSIGN TT_LOG_ERRO.TTV_NUM_COD_ERRO  = 17006.
     /* Inicio -- Projeto Internacional */
     {utp/ut-liter.i "Erro_ao_carregar_a_API_XML" *}
     ASSIGN TT_LOG_ERRO.TTV_DES_MSG_ERRO  = RETURN-VALUE + ": "+ cReturnValue
            tt_log_erro.ttv_des_msg_ajuda = tt_log_erro.ttv_des_msg_erro.
     RETURN cReturnValue.
END.

DEFINE TEMP-TABLE ttStack NO-UNDO
     FIELD ttID AS INTEGER
     FIELD ttPos AS INTEGER
     INDEX tt_id IS PRIMARY UNIQUE
           ttID  ASCENDING.

FUNCTION addStack RETURN INTEGER (INPUT val AS INTEGER).
     DEFINE VAR id AS INTEGER INITIAL 1 NO-UNDO.
     FIND LAST ttStack NO-ERROR.
     IF AVAIL(ttStack) THEN
          id = ttStack.ttID + 1.
     CREATE ttStack.
     ASSIGN ttStack.ttID = id.
     ASSIGN ttStack.ttPos = val.
END FUNCTION.

FUNCTION delStack RETURN INTEGER.
     FIND LAST ttStack NO-ERROR.
     IF AVAIL(ttStack) THEN
          DELETE ttStack.
     FIND LAST ttStack NO-ERROR.
END FUNCTION.

FUNCTION getStack RETURN INTEGER.
     IF AVAIL(ttStack) THEN
          RETURN ttStack.ttPos.
     ELSE
          RETURN 0.
END FUNCTION.

/****** INTERNAL PROCEDURES - BEGIN*/
PROCEDURE PIUpsert:

    /*PARAMETERS - BEGIN*/
    DEFINE INPUT  PARAM p-motivo    AS CHARACTER           NO-UNDO.
    DEFINE INPUT  PARAM p-row-table AS ROWID               NO-UNDO. 
    DEFINE OUTPUT PARAM TABLE FOR tt_log_erro.
    /*PARAMETERS - END*/

    /*LOCAL VARIABLES - BEGIN*/
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
   /*LOCAL VARIABLES - END*/
    
    ASSIGN c-motivo = p-motivo.

    /*--- Tratamento Acentuacao ---*/
    ASSIGN c-string-com-acento = c-motivo
           c-string-sem-acento = fn-free-accent(c-string-com-acento).

    ASSIGN c-motivo = c-string-sem-acento.
    /*--- FIM Tratamento Acentuacao ---*/


    

    /* ******************************************* */
    /* *************** BODY - BEGIN ************** */
    /* ******************************************* */
    
    /* RESETA OS VALORES */
    RUN reset IN hGenXml.
    
    /* SETA VALOR DE ENCODING */
    RUN setEncoding IN hGenXml ("UTF-8":U).

    RUN addNode IN hGenXml (getStack(), 
                            "Upsert":U, 
                            "":U, 
                            OUTPUT iId).
    addStack(iId).

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
    cFile = "t:\int-axsep002-" + nota-fiscal.cod-estabel + nota-fiscal.serie + "-" + nota-fiscal.nr-nota-fis + ".XML".
    hBusinessContent:SAVE("File",cFile).
    define variable cXML as longchar no-undo.
    define buffer bint_ndd_envio for int_ndd_envio.
    hBusinessContent:SAVE("LONGCHAR",cXML).    
    do transaction:
        i-id = 1.
        for last bint_ndd_envio use-index id:
            assign i-id = bint_ndd_envio.id + 1.
        end.
        create int_ndd_envio.
        assign int_ndd_envio.ID           = i-id
               int_ndd_envio.STATUSNUMBER = 0 /* A processar */
               int_ndd_envio.JOB          = nota-fiscal.cod-estabel
               int_ndd_envio.DOCUMENTUSER = c-seg-usuario
               int_ndd_envio.KIND         = 1 /* XML */
               int_ndd_envio.cod_estabel  = nota-fiscal.cod-estabel
               int_ndd_envio.serie        = nota-fiscal.serie
               int_ndd_envio.nr_nota_fis  = nota-fiscal.nr-nota-fis
               int_ndd_envio.dt_envio     = today
               int_ndd_envio.hr_envio     = time.
        copy-lob cXML to int_ndd_envio.DOCUMENTDATA.
    end.
    RETURN "OK":U.
    
    /* ******************************************* */
    /* *************** BODY - END   ************** */
    /* ******************************************* */

END PROCEDURE.


/****** INTERNAL PROCEDURES - END*/

PROCEDURE PITransUpsert:

    /*PARAMETERS - BEGIN*/
    DEFINE INPUT  PARAM p-motivo    AS CHARACTER           NO-UNDO.
    DEFINE INPUT  PARAM p-row-table AS ROWID               NO-UNDO. 
    DEFINE OUTPUT PARAM TABLE FOR tt_log_erro.
    DEFINE OUTPUT PARAM TABLE FOR tt_nfe_erro.
    /*PARAMETERS - END*/
    
    /* ******************************************* */
    /* *************** BODY - BEGIN ************** */
    /* ******************************************* */
    EMPTY TEMP-TABLE tt_log_erro NO-ERROR.
    EMPTY TEMP-TABLE tt_nfe_erro NO-ERROR.
    
    FOR FIRST nota-fiscal FIELDS(cod-estabel serie nr-nota-fis
                                 &IF"{&bf_dis_versao_ems}" < "2.07" &THEN
                                    char-2 char-1
                                 &ELSE
                                    cod-chave-aces-nf-eletro cod-protoc
                                 &ENDIF) NO-LOCK
            WHERE ROWID(nota-fiscal) = p-row-table: END.
    
    IF AVAIL nota-fiscal THEN DO:
    
      EMPTY TEMP-TABLE tt_nfe_erro.
    
      RUN PIUpsert (INPUT p-motivo,
                    INPUT p-row-table,
                    OUTPUT TABLE tt_log_erro).
    
    END.

END PROCEDURE.

&endif 
