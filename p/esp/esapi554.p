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


DEFINE BUFFER bf-trans-api-log FOR es-api-log.

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

DEF BUFFER bf-fat-duplic   FOR fat-duplic.
                           
DEF VAR cXML               AS LONGCHAR NO-UNDO.
DEF VAR lcRetorno          AS LONGCHAR NO-UNDO.

DEF VAR iPagina            AS i        NO-UNDO.
DEF VAR iPlano             AS i        NO-UNDO.

DEF VAR dt-ult-envio       AS da       EXTENT 2 NO-UNDO.

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
         HEIGHT             = 11.75
         WIDTH              = 41.14.
/* END WINDOW DEFINITION */
                                                                        */
&ANALYZE-RESUME

 


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Procedure 


/* ***************************  Main Block  *************************** */

RUN pi-inicializar IN h-acomp ("Retorno de Consulta").

blk: FOR FIRST es-api-log NO-LOCK
   WHERE ROWID(es-api-log) = rw-registro,
   FIRST es-api-URI       NO-LOCK
      OF es-api-log,
   FIRST es-api-empresa   NO-LOCK
      OF es-api-log,
   FIRST es-api-aplicacao NO-LOCK
      OF es-api-log
      BY es-api-log.flg-processado
      BY es-api-log.dh-request:
   
   DO TRANS:
      FIND FIRST bf-trans-api-log 
           WHERE ROWID(bf-trans-api-log) = ROWID(es-api-log)
           NO-ERROR.
      ASSIGN
         bf-trans-api-log.dh-envio       = NOW
         bf-trans-api-log.flg-processado = YES.
   END.

   IF es-api-aplicacao.Testes  = NO
   THEN ASSIGN
      c-endereco          = es-api-URI.ent-PRD.
   ELSE ASSIGN            
      c-endereco          = es-api-URI.end-TST.

/*
   FIND FIRST es-bv-fat-duplic NO-LOCK
        WHERE es-bv-fat-duplic.ind-envio =  1
          AND es-bv-fat-duplic.dt-envio  >= 01/05/2022
       NO-ERROR.
   IF AVAIL es-bv-fat-duplic
   THEN ASSIGN
      da-data-ini = es-bv-fat-duplic.dt-envio.
   FIND  LAST es-bv-fat-duplic NO-LOCK
        WHERE es-bv-fat-duplic.ind-envio =  1
          AND es-bv-fat-duplic.dt-envio  >= 01/05/2022
       NO-ERROR.
   IF AVAIL es-bv-fat-duplic
   THEN ASSIGN
      da-data-fim = es-bv-fat-duplic.dt-envio.
   IF da-data-ini <= 01/05/2022
   THEN ASSIGN
      da-data-ini  = 01/05/2022.
*/
   ASSIGN
      dt-ult-envio[1] = TODAY - 2
      dt-ult-envio[2] = TODAY
      .

   FIND FIRST es-bv-setup NO-LOCK 
        NO-ERROR.
   IF AVAIL es-bv-setup
   THEN DO:
      IF es-bv-setup.conciliados
      THEN ASSIGN
         dt-ult-envio[1] = es-bv-setup.dt-conciliados-ini
         dt-ult-envio[2] = es-bv-setup.dt-conciliados-fim
         .                 
   END.


//   MESSAGE da-data-ini da-data-fim 
//       VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.

/*   IF AVAIL es-bv-fat-duplic
   THEN*/ DO:
      DISP 
         dt-ult-envio
         WITH SCROLLABLE STREAM-IO.

      ASSIGN
         iPagina = 1.

      MESSAGE "Iniciando envio ==>".
      REPEAT:
         ASSIGN 
            cXML = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
                    <Filtro>
                        <dataVendaInicio>' + fc-data(dt-ult-envio[1]) + '</dataVendaInicio>
                        <dataVendaFim>'    + fc-data(dt-ult-envio[2]) + '</dataVendaFim>
                        <pagina>'          + STRING(iPagina)          + '</pagina>
                    </Filtro>'. 
         
         MESSAGE STRING(cXML).

         RUN pi-criar-log ("Envio Con BV",
                             STRING(es-api-log.id-api-log)
                           + ","
                           + STRING(iPagina),
                           cXML
                           ).
         IF NUM-ENTRIES(es-api-log.aux) > 1
         THEN DO:
             MESSAGE 
                 "Pagina enviada ==>"
                 INT(ENTRY(2,es-api-log.aux))
                 " de "
                 INT(ENTRY(3,es-api-log.aux)).
    
    
             RUN pi-acompanhar IN h-acomp (ENTRY(2,es-api-log.aux)
                                         + "/"
                                         + ENTRY(3,es-api-log.aux)).
             ASSIGN
                iPagina = iPagina + 1.
    
             /**/ IF iPagina > INT(ENTRY(3,es-api-log.aux)) // *-*-*-*-*-*
             THEN /**/ LEAVE.
         END.
         ELSE LEAVE.
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

   DEF BUFFER bf-api-URI FOR es-api-URI.

   IF cJSON = ""
   THEN RETURN.

   DO TRANS:

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
   
      FIND FIRST bf-api-URI NO-LOCK
           WHERE bf-api-URI.id-URI = cURI
           NO-ERROR.
   
      RUN VALUE(bf-api-URI.nom-programa-env) (h-acomp,
                                              1,
                                              ROWID(bf-new-api-log)).
   
      RELEASE bf-new-api-log.
   END.

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

