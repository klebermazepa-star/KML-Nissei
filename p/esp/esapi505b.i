&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12
&ANALYZE-RESUME
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Include 
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

DEFINE TEMP-TABLE apiRowErrors NO-UNDO
    FIELD ErrorSequence    AS INTEGER
    FIELD ErrorNumber      AS INTEGER
    FIELD ErrorDescription AS CHARACTER
    FIELD ErrorParameters  AS CHARACTER
    FIELD ErrorType        AS CHARACTER
    FIELD ErrorHelp        AS CHARACTER
    FIELD ErrorSubType     AS CHARACTER.

DEF VAR reqErro    AS i        NO-UNDO.
DEF VAR lcRequest  AS LONGCHAR NO-UNDO.
DEF VAR reqwRec    AS ROWID    NO-UNDO.
DEF VAR lgRollback AS l        NO-UNDO.

DEF TEMP-TABLE tt-rollback-api-log NO-UNDO
    LIKE  es-api-log
    FIELD rw-registro AS ROWID
    INDEX i rw-registro.

DEF TEMP-TABLE tt-rollback-api-aux NO-UNDO
    LIKE  es-api-aux
    FIELD rw-registro AS ROWID
    INDEX i rw-registro.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */



/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Include
   Allow: 
   Frames: 0
   Add Fields to: Neither
   Other Settings: INCLUDE-ONLY
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
/* DESIGN Window definition (used by the UIB) 
  CREATE WINDOW Include ASSIGN
         HEIGHT             = 15
         WIDTH              = 60.
/* END WINDOW DEFINITION */
                                                                        */
&ANALYZE-RESUME

 


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Include 


/* ***************************  Main Block  *************************** */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-output-api-request Include 
PROCEDURE pi-output-api-request :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
   DEF BUFFER bf-las-api-log FOR es-api-log.
   DEF BUFFER bf-new-api-log FOR es-api-log.

   DEF  INPUT PARAM cIDAplicacao LIKE es-api-log.id-aplicacao NO-UNDO.
   DEF  INPUT PARAM cIDCodigo    LIKE es-api-log.id-codigo    NO-UNDO.
   DEF  INPUT PARAM cURI         AS c                         NO-UNDO.
   DEF  INPUT PARAM cOrigem      AS c                         NO-UNDO.
   DEF  INPUT PARAM cAux         AS c                         NO-UNDO.
   DEF  INPUT PARAM lcInput      AS LONGCHAR                  NO-UNDO.

   DEF          VAR h-acomp      AS HANDLE                    NO-UNDO.
   DEF          VAR cErro        AS c                         NO-UNDO.
   DEF          VAR iRet         AS i                         NO-UNDO.
   DEF          VAR i            AS i                         NO-UNDO.

   
   FIND LAST bf-las-api-log NO-LOCK
       WHERE bf-las-api-log.id-api-log > 0
       NO-ERROR.
   CREATE bf-new-api-log.
   ASSIGN
      bf-new-api-log.seqexec        = 10
      bf-new-api-log.id-aplicacao   = cIDAplicacao
      bf-new-api-log.id-codigo      = cIDCodigo
      bf-new-api-log.id-URI         = cURI
      bf-new-api-log.dh-request     = NOW
      bf-new-api-log.Aux            = cAux
      bf-new-api-log.flg-processado = NO
      bf-new-api-log.Origem         = cOrigem
      .

   IF NOT AVAIL bf-las-api-log 
   THEN ASSIGN
      bf-new-api-log.id-api-log = 1.
   ELSE ASSIGN
      bf-new-api-log.id-api-log = bf-las-api-log.id-api-log + 1.

   COPY-LOB lcInput TO bf-new-api-log.cl-envio.   

   ASSIGN
      reqwRec = ROWID(bf-new-api-log).

   CREATE tt-rollback-api-log.
   BUFFER-COPY bf-new-api-log TO tt-rollback-api-log.
   ASSIGN
      tt-rollback-api-log.rw-registro = ROWID(bf-new-api-log).

   RELEASE bf-new-api-log.

   FIND FIRST es-api-URI NO-LOCK
        WHERE es-api-URI.id-URI = cUri
        NO-ERROR.
   IF AVAIL es-api-URI
   THEN DO:
      IF es-api-URI.flg-batch = NO
      THEN DO:
         IF SEARCH(REPLACE(es-api-URI.nom-programa-env,".p",".r")) = ?
         THEN ASSIGN
            cErro = "Programa de intagracao " + REPLACE(es-api-URI.nom-programa-env,".p",".r") + " nao foi encontrado.".
         ELSE DO:
            RUN VALUE(es-api-URI.nom-programa-env) (h-acomp,
                                                    1,
                                                    reqwRec)
                                                    NO-ERROR.
            IF ERROR-STATUS:ERROR 
            THEN DO:
               DO i = 1 TO ERROR-STATUS:NUM-MESSAGES:
                  IF cErro = ""
                  THEN ASSIGN 
                     cErro = ERROR-STATUS:GET-MESSAGE(i).
                  ELSE ASSIGN
                     cErro = cErro + ERROR-STATUS:GET-MESSAGE(i).
               END.
               ASSIGN
                  cErro = cErro 
                        + " - propath: " + PROPATH.
            END.
            FOR FIRST es-api-log NO-LOCK
                WHERE ROWID(es-api-log) = reqwRec:
               FOR EACH es-api-aux NO-LOCK
                     OF es-api-log
                  WHERE es-api-aux.tipo = "RowErrors":
                  CREATE apiRowErrors.
                  RAW-TRANSFER es-api-aux.raw-aux TO apiRowErrors NO-ERROR. 
                  MESSAGE ">>> pi-output-api-request erro " apiRowErrors.ErrorDescription.
               END.
            END.
         END.
      END.
   END.
   ELSE ASSIGN
      cErro = "URI " + cUri + " nÆo foi encontrada.".

   IF cErro > ""
   THEN RUN piErroREQ (cErro,"").   


   RUN pi-output-gera-rollback.

   /*
   IF AVAIL es-api-log
   THEN FOR FIRST apiRowErrors:
      RAW-TRANSFER apiRowErrors TO es-api-log.data-raw.
   END.
   */
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-output-gera-rollback Include 
PROCEDURE pi-output-gera-rollback :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
   DEF BUFFER bf-rollback-api-log FOR es-api-log.
   DEF BUFFER bf-rollback-api-aux FOR es-api-aux.

   EMPTY TEMP-TABLE tt-rollback-api-aux.
   FOR EACH tt-rollback-api-log:
      FIND FIRST bf-rollback-api-log NO-LOCK
           WHERE ROWID(bf-rollback-api-log) = tt-rollback-api-log.rw-registro
           NO-ERROR.
      IF AVAIL bf-rollback-api-log 
      THEN DO:
         BUFFER-COPY bf-rollback-api-log TO tt-rollback-api-log.
         FOR EACH bf-rollback-api-aux
               OF bf-rollback-api-log:
            FIND FIRST tt-rollback-api-aux
                 WHERE tt-rollback-api-aux.rw-registro = ROWID(bf-rollback-api-aux)
                 NO-ERROR.
            IF NOT AVAIL tt-rollback-api-aux
            THEN CREATE tt-rollback-api-aux.
            BUFFER-COPY bf-rollback-api-aux TO tt-rollback-api-aux.
            ASSIGN
               tt-rollback-api-aux.rw-registro = ROWID(bf-rollback-api-aux).
         END.
      END.
   END.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-output-grava-rollback Include 
PROCEDURE pi-output-grava-rollback :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
   DEF BUFFER bf-rollback-api-log FOR es-api-log.
   DEF BUFFER bf-rollback-api-aux FOR es-api-aux.

   MESSAGE ">>> pi-output-grava-rollback " lgRollback.
   IF lgRollback = YES
   THEN FOR EACH tt-rollback-api-log:
      FIND FIRST bf-rollback-api-log NO-LOCK
           WHERE ROWID(bf-rollback-api-log) = tt-rollback-api-log.rw-registro
           NO-ERROR.
      IF NOT AVAIL bf-rollback-api-log 
      THEN DO:
         CREATE bf-rollback-api-log.
         BUFFER-COPY tt-rollback-api-log TO bf-rollback-api-log.
         MESSAGE ">>> pi-output-grava-rollback -- " bf-rollback-api-log.id-api-log.
         FOR EACH tt-rollback-api-aux:
            FIND FIRST bf-rollback-api-aux
                 WHERE ROWID(bf-rollback-api-aux) = tt-rollback-api-aux.rw-registro
                 NO-ERROR.
            IF NOT AVAIL bf-rollback-api-aux
            THEN CREATE bf-rollback-api-aux.
            BUFFER-COPY tt-rollback-api-aux TO bf-rollback-api-aux.
         END.
      END.
   END.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE piErroREQ Include 
PROCEDURE piErroREQ :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    DEF INPUT PARAM cErrorDescription AS c NO-UNDO.
    DEF INPUT PARAM cErrorHelp        AS c NO-UNDO.
    CREATE apiRowErrors.
    ASSIGN
        reqErro                       = reqErro + 1
        apiRowErrors.ErrorSequence    = reqErro
        apiRowErrors.ErrorNumber      = 17006
        apiRowErrors.ErrorType        = "Error"
        apiRowErrors.ErrorDescription = cErrorDescription
        apiRowErrors.ErrorHelp        = cErrorHelp       .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

