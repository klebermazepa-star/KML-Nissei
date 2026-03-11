/********************************************************************************
** Copyright DATASUL S.A. (1997)
** Todos os Direitos Reservados.
**
** Este fonte e de propriedade exclusiva da DATASUL, sua reproducao
** parcial ou total por qualquer meio, so podera ser feita mediante
** autorizacao expressa.
*******************************************************************************/
{include/i-prgvrs.i INT-AXSEP003 2.00.00.019 } /*** 010019 ***/

{cdp/cdcfgdis.i}

/*LOCAL VARIABLES - BEGIN*/
DEFINE VAR cReturnValue AS CHARACTER INITIAL ? NO-UNDO.

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


/*LOCAL VARIABLES - END*/
DEFINE VAR cProtocolo AS CHARACTER NO-UNDO.
DEFINE VAR cMotivo    AS CHARACTER NO-UNDO.

/*PARAMETERS - BEGIN*/
DEFINE OUTPUT PARAM TABLE FOR tt_log_erro.
/*PARAMETERS - END*/

/*{adapters/xml/ep2/axsep003extradeclarations.i}*/
{utp/ut-glob.i}

/* Handle do BusinessContent */
DEF VAR hBusinessContent AS HANDLE NO-UNDO.
CREATE X-DOCUMENT hBusinessContent.


/* VARIABEL PARA ARMAZENAR OS VALORES OBTIDOS NA INICIALIZACAO DO loalGenXml */
DEF VAR hGenXml AS HANDLE NO-UNDO.

/* VERIFICA SE APIXML ESTA NA MEMORIA */
{xmlinc/xmlloadgenxml.i &GenXml="hGenXml" &GXReturnValue="cReturnValue"}

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
    DEFINE INPUT  PARAM TABLE FOR ttInutInvoiceDocument.
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
    
    /*LOCAL VARIABLES - END*/
    
    /* ******************************************* */
    /* *************** BODY - BEGIN ************** */
    /* ******************************************* */
    
    FIND FIRST ttInutInvoiceDocument NO-ERROR.
    
     /* RESETA OS VALORES */
     RUN reset IN hGenXml.

     /* SETA VALOR DE ENCODING */
     RUN setEncoding IN hGenXml ("UTF-8").


     RUN addNode IN hGenXml (getStack(), "Upsert", "", OUTPUT iId).
     addStack(iId).

          RUN addNode IN hGenXml (getStack(), "inutNFe", "", OUTPUT iId).
          addStack(iId).
                
               RUN addNode IN hGenXml (getStack(), "versao", ttInutInvoiceDocument.versao, OUTPUT iId).

               /*FOR EACH ttInutInvoiceDocument:*/
                    RUN addNode IN hGenXml (getStack(), "infInut", "", OUTPUT iId).
                    addStack(iId).

                         RUN addNode IN hGenXml (getStack(), "id", ttInutInvoiceDocument.id, OUTPUT iId).
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

    def var cFile as character.
    def var i-id as integer.
    cFile = "t:\int-axsep003-" + ttInutInvoiceDocument.serie + "-" + ttInutInvoiceDocument.nNFIni + ".XML".
    hBusinessContent:SAVE("File",cFile).

    define variable cXML as longchar no-undo.
    define buffer bint_ndd_envio for int_ndd_envio.
    hBusinessContent:SAVE("LONGCHAR",cXML).    
    for first estabelec no-lock where 
        estabelec.cgc = ttInutInvoiceDocument.CNPJ
        transaction:
        
        i-id = 1.
        for last bint_ndd_envio use-index id:
            assign i-id = bint_ndd_envio.id + 1.
        end.
        create int_ndd_envio.
        assign int_ndd_envio.ID           = i-id
               int_ndd_envio.STATUSNUMBER = 0 /* A processar */
               int_ndd_envio.JOB          = estabelec.cod-estabel
               int_ndd_envio.DOCUMENTUSER = c-seg-usuario
               int_ndd_envio.KIND         = 1 /* XML */
               int_ndd_envio.cod_estabel  = estabelec.cod-estabel
               int_ndd_envio.serie        = ttInutInvoiceDocument.serie
               int_ndd_envio.nr_nota_fis  = ttInutInvoiceDocument.nNFIni
               int_ndd_envio.dt_envio     = today
               int_ndd_envio.hr_envio     = time.
        copy-lob cXML to int_ndd_envio.DOCUMENTDATA.
    end.

END PROCEDURE.

PROCEDURE PITransUpsert:
    
    /*PARAMETERS - BEGIN*/
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
    /*PARAMETERS - END*/
    
    DEF VAR c-serie          AS CHARACTER  NO-UNDO. 
    DEF VAR cVersaoLayoutNFe AS CHARACTER NO-UNDO.


    EMPTY TEMP-TABLE tt_log_erro           NO-ERROR.
    EMPTY TEMP-TABLE tt_nfe_erro           NO-ERROR.
    EMPTY TEMP-TABLE ttInutInvoiceDocument NO-ERROR.

    FOR FIRST nota-fiscal NO-LOCK
        WHERE ROWID(nota-fiscal) = pRowidNotaFiscal:
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

    IF CAN-FIND(FIRST funcao
                WHERE funcao.cd-funcao = "spp-nfe"
                AND   funcao.ativo     ) THEN DO:
            
           assign c-serie = pserie.
            
            /* TrataSerieNfe */
            ASSIGN pserie = c-serie. 
            IF pserie = "" THEN ASSIGN pserie = "0". 
    END.

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
           ttInutInvoiceDocument.tpAmb     = "1"
           ttInutInvoiceDocument.versao    = (IF cVersaoLayoutNFe = "1.10":U THEN "1.06":U
                                                                             ELSE cVersaoLayoutNFe)
           ttInutInvoiceDocument.xJust     = pJust
           ttInutInvoiceDocument.xServ     = "INUTILIZAR":U
           ttInutInvoiceDocument.Signature = " ":U.
           ttInutInvoiceDocument.id        = "ID":U + STRING(pcUf) + STRING(pModelo) + STRING(pSerie) + STRING(pnNfeIni) + STRING(pnNfeFin).

    RUN PIUpsert ( INPUT TABLE ttInutInvoiceDocument,     /* Dados do Pedido de Cancelamento da nota fiscal  */
                   OUTPUT TABLE tt_log_erro ).

END PROCEDURE.


