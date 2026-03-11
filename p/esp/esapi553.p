&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12
&ANALYZE-RESUME
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Procedure 
/*------------------------------------------------------------------------
    File        : 
    Purpose     :

    Syntax      :

    Description :

    Author(s)   :
    Created     :
    Notes       :
  ----------------------------------------------------------------------*/
/*          This .W file was created with the Progress AppBuilder.      */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

{esp/esapi505.i}

DEF INPUT PARAM h-acomp       AS HANDLE   NO-UNDO.    
DEF INPUT PARAM i-acao        AS i        NO-UNDO.
DEF INPUT PARAM rw-registro   AS ROWID    NO-UNDO.

DEF          VAR t            AS i        NO-UNDO.
DEF          VAR i-pag        AS i        NO-UNDO.
DEF          VAR httCust      AS HANDLE   NO-UNDO.
DEF          VAR lReturnValue AS LOGICAL  NO-UNDO.

DEF NEW GLOBAL SHARED VAR l-esapi550 AS l NO-UNDO.

SESSION:DEBUG-ALERT = YES.

ASSIGN
   t = TIME.

{esp/esapi505x.i &OPC="OPEN"}


IF i-acao = 0
THEN DO:
   l-esapi550 = NO.
   {esp/esapi505x.i &OPC="CLOSE"}
   RETURN "OK".
END.

DEF TEMP-TABLE conciliadas NO-UNDO
    FIELD tipo AS c INIT "conciliadas".
DEF TEMP-TABLE divergentes NO-UNDO
    FIELD tipo AS c INIT "divegentes".
DEF TEMP-TABLE erros NO-UNDO
    FIELD tipo AS c INIT "erros".

DEF TEMP-TABLE venda NO-UNDO
    FIELD rec                    AS RECID
    FIELD areaCliente            AS c FORMAT "x(20)"
    FIELD autorizacao            AS c
    FIELD bandeira               AS c
    FIELD codigoLoja             AS c
    FIELD codigoEstabelecimento  AS c
    FIELD dataVenda              AS c FORMAT "x(10)"
    FIELD id                     AS c
    FIELD modoCaptura            AS c
    FIELD nsu                    AS c
    FIELD nsuHost                AS c
    FIELD parcela                AS c
    FIELD plano                  AS c
    FIELD produto                AS c
    FIELD rede                   AS c
    FIELD tid                    AS c
    FIELD tipoDivergencia        AS c
    FIELD valor                  AS c
    FIELD mensagem               AS c FORMAT "x(40)"
    .

DEF DATASET RemessaResponse 
        FOR conciliadas, divergentes, erros, venda
    PARENT-ID-RELATION con FOR conciliadas, venda
        PARENT-ID-FIELD rec
    PARENT-ID-RELATION div FOR divergentes, venda
        PARENT-ID-FIELD rec
    PARENT-ID-RELATION err FOR erros, venda
        PARENT-ID-FIELD rec
    .

DEF BUFFER bf-fat-duplic   FOR fat-duplic.
                           
DEF VAR lcRetorno          AS LONGCHAR NO-UNDO.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Procedure
&Scoped-define DB-AWARE no



/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&IF DEFINED(EXCLUDE-fc-data) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD fc-data Procedure 
FUNCTION fc-data RETURNS CHARACTER
  ( d AS DATE )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-fc-valor) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD fc-valor Procedure 
FUNCTION fc-valor RETURNS CHARACTER
  ( v LIKE fat-duplic.vl-parcela )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Procedure
   Allow: 
   Frames: 0
   Add Fields to: Neither
   Other Settings: CODE-ONLY COMPILE
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
/* DESIGN Window definition (used by the UIB) 
  CREATE WINDOW Procedure ASSIGN
         HEIGHT             = 11.33
         WIDTH              = 41.14.
/* END WINDOW DEFINITION */
                                                                        */
&ANALYZE-RESUME

 


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Procedure 


/* ***************************  Main Block  *************************** */

RUN pi-inicializar IN h-acomp ("Enviando Faturas").

blk: FOR FIRST es-api-log
   WHERE ROWID(es-api-log) = rw-registro,
   FIRST es-api-URI       NO-LOCK
      OF es-api-log,
   FIRST es-api-empresa   NO-LOCK
      OF es-api-log,
   FIRST es-api-aplicacao NO-LOCK
      OF es-api-log
      BY es-api-log.flg-processado
      BY es-api-log.dh-request:
   ASSIGN
      es-api-log.dh-envio       = NOW
      es-api-log.flg-processado = YES.

   RUN pi-acompanhar IN h-acomp (es-api-log.aux).

   IF es-api-aplicacao.Testes  = NO
   THEN ASSIGN
      c-endereco          = es-api-URI.ent-PRD.
   ELSE ASSIGN            
      c-endereco          = es-api-URI.end-TST.

   RUN piHeader (10,"chaveAcesso" ,es-api-empresa.API_KEY).
   RUN piHeader (20,"chaveSecreta",es-api-empresa.API_SECRET).

   fc-chamada-4(). 

   lcRetorno = es-api-log.cl-retorno.

   DATASET RemessaResponse:READ-XML("longchar",lcRetorno,?,?,?).

   FOR EACH conciliadas:
       FOR EACH venda 
          WHERE venda.rec = RECID(conciliadas):
           FIND FIRST es-bv-fat-duplic 
                WHERE es-bv-fat-duplic.areaCliente = venda.areaCliente
                NO-ERROR.
           IF AVAIL es-bv-fat-duplic 
           THEN DO:
              ASSIGN
                 es-bv-fat-duplic.ind-send     = "x"
                 es-bv-fat-duplic.ind-retorno  = 1
                 es-bv-fat-duplic.ret-mensagem = venda.mensagem.
              RELEASE es-bv-fat-duplic.
           END.
           
           DISP 
              conciliadas.
           DISP 
              venda
              WITH STREAM-IO SCROLLABLE.
           
       END.
   END.
   
   FOR EACH divergentes:
       FOR EACH venda 
          WHERE venda.rec = RECID(divergentes):
           FIND FIRST es-bv-fat-duplic 
                WHERE es-bv-fat-duplic.areaCliente = venda.areaCliente
                NO-ERROR.
           IF AVAIL es-bv-fat-duplic 
           THEN DO:
              ASSIGN
                 es-bv-fat-duplic.ind-send     = "x"
                 es-bv-fat-duplic.ind-retorno  = 2
                 es-bv-fat-duplic.ret-mensagem = venda.mensagem.
              RELEASE es-bv-fat-duplic.
           END.

           DISP 
              divergentes.
           DISP 
              venda
              WITH STREAM-IO SCROLLABLE.
       END.
   END.
   
   FOR EACH erros:
       FOR EACH venda 
          WHERE venda.rec = RECID(erros):
           FIND FIRST es-bv-fat-duplic 
                WHERE es-bv-fat-duplic.areaCliente = venda.areaCliente
                NO-ERROR.
           IF AVAIL es-bv-fat-duplic 
           THEN DO:
              ASSIGN
                 es-bv-fat-duplic.ind-send     = "x"
                 es-bv-fat-duplic.ind-retorno  = 3
                 es-bv-fat-duplic.ret-mensagem = venda.mensagem.
              RELEASE es-bv-fat-duplic.
           END.

           DISP 
              erros.
           DISP 
              venda
              WITH STREAM-IO SCROLLABLE.
       END.
   END.

   RELEASE es-api-log.
END.

{esp/esapi505x.i &OPC="CLOSE"}


RETURN "OK".

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&IF DEFINED(EXCLUDE-pi-criar-log) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-criar-log Procedure 
PROCEDURE pi-criar-log :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
   DEF BUFFER bf-las-api-log FOR es-api-log.
   DEF BUFFER bf-new-api-log FOR es-api-log.
   DEF INPUT PARAM cURI      AS  c NO-UNDO.
   DEF INPUT PARAM cCod      AS  c NO-UNDO.
   DEF INPUT PARAM cJson     AS  c NO-UNDO.

   IF cJSON = ""
   THEN RETURN.

   FIND LAST bf-las-api-log NO-LOCK
       WHERE bf-las-api-log.id-api-log > 0
       NO-ERROR.
   CREATE bf-new-api-log.
   ASSIGN
      bf-new-api-log.seqexec        = es-api-log.seqexec     
      bf-new-api-log.id-aplicacao   = es-api-log.id-aplicacao
      bf-new-api-log.id-codigo      = es-api-log.id-codigo   
      bf-new-api-log.id-URI         = cURI
      bf-new-api-log.dh-request     = NOW
      bf-new-api-log.end-envio      = es-api-log.end-envio
      bf-new-api-log.flg-processado = NO
      bf-new-api-log.Origem         = es-api-log.Origem
      bf-new-api-log.aux            = cCod
      bf-new-api-log.cJSON          = cJson
      .

   IF NOT AVAIL bf-las-api-log 
   THEN ASSIGN
      bf-new-api-log.id-api-log = 1.
   ELSE ASSIGN
      bf-new-api-log.id-api-log = bf-las-api-log.id-api-log + 1.

   RELEASE bf-new-api-log.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

/* ************************  Function Implementations ***************** */

&IF DEFINED(EXCLUDE-fc-data) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION fc-data Procedure 
FUNCTION fc-data RETURNS CHARACTER
  ( d AS DATE ) :
/*------------------------------------------------------------------------------
  Purpose:  
    Notes:  
------------------------------------------------------------------------------*/

  RETURN STRING(YEAR(d)) + "-" + STRING(MONTH(d),"99") + "-" + STRING(DAY(d),"99").

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-fc-valor) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION fc-valor Procedure 
FUNCTION fc-valor RETURNS CHARACTER
  ( v LIKE fat-duplic.vl-parcela ) :
/*------------------------------------------------------------------------------
  Purpose:  
    Notes:  
------------------------------------------------------------------------------*/

  RETURN REPLACE(STRING(v),",",".").

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

