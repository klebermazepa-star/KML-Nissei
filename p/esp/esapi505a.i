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

DEF TEMP-TABLE ttRetorno                       SERIALIZE-NAME "Retorno"
    FIELD situacao        AS i                 SERIALIZE-NAME "Status"
    FIELD Descricao       AS c FORMAT "x(400)" 
    .
DEF VAR rwRec AS ROWID NO-UNDO.

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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-input-api-request Include 
PROCEDURE pi-input-api-request :
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
      rwRec = ROWID(bf-new-api-log).
   
   RELEASE bf-new-api-log.

   FIND FIRST es-api-URI NO-LOCK
        WHERE es-api-URI.id-URI = cUri
        NO-ERROR.

   IF AVAIL es-api-URI
   THEN DO:
      MESSAGE ">> es-api-URI.flg-batch" es-api-URI.flg-batch.
      IF es-api-URI.flg-batch = NO
      THEN DO:
         IF SEARCH(REPLACE(es-api-URI.nom-programa-env,".p",".r")) = ?
         THEN ASSIGN
            cErro = "Programa de integracao " + REPLACE(es-api-URI.nom-programa-env,".p",".r") + " nao foi encontrado.".
         ELSE DO:
            RUN VALUE(es-api-URI.nom-programa-env) (h-acomp,
                                                    1,
                                                    rwRec)
                                                    NO-ERROR.
            MESSAGE ">>> pi-input-api-request 1".
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
            ELSE DO:
               MESSAGE ">>> pi-input-api-request 2".
               FIND FIRST es-api-log NO-LOCK
                    WHERE ROWID(es-api-log) = rwRec
                    NO-ERROR.
               IF AVAIL es-api-log 
               THEN DO:
                  MESSAGE ">>> pi-input-api-request 3 es-api-log.cod-retorno" es-api-log.cod-retorno.
                  IF es-api-log.cod-retorno  >= "300"
                  THEN DO:
                     MESSAGE ">>> pi-input-api-request 4".
                     ASSIGN
                        iRet = INT(es-api-log.cod-retorno).
                     FOR EACH es-api-aux NO-LOCK
                           OF es-api-log
                        WHERE es-api-aux.tipo = "RowErrors":
                        CREATE RowErrors.
                        RAW-TRANSFER es-api-aux.raw-aux TO RowErrors NO-ERROR. 
                        MESSAGE ">>> pi-input-api-request 4" RowErrors.ErrorDescription.
                     END.
                     
                     FOR EACH RowErrors:
                        IF RowErrors.ErrorNumber > 0
                        THEN DO:
                           CREATE ttRetorno.
                           ASSIGN 
                              ttRetorno.situacao  = INT(es-api-log.cod-retorno)
                              ttRetorno.descricao = STRING(RowErrors.ErrorNumber)
                                                  + " - " 
                                                  + RowErrors.ErrorDescription.
                        END.
                     END.
                  END.
                  ELSE DO:
                     CREATE ttRetorno.
                     ASSIGN 
                        ttRetorno.situacao  = INT(es-api-log.cod-retorno)
                        ttRetorno.descricao = es-api-log.aux.
                     IF es-api-log.cod-retorno = ""
                     THEN ASSIGN
                        ttRetorno.situacao  = 500
                        ttRetorno.descricao = "Processamento n∆o foi efetuado pelo programa " 
                                            + REPLACE(es-api-URI.nom-programa-env,".p",".r").
                  END.
               END.
            END.
         END.
      END.
      ELSE DO:
         RUN VALUE(es-api-URI.nom-programa-env) (h-acomp,
                                                 1,
                                                 rwRec)
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
         ELSE DO:
            FIND FIRST es-api-log NO-LOCK
                 WHERE ROWID(es-api-log) = rwRec
                 NO-ERROR.
            IF AVAIL es-api-log 
            THEN DO:
               CREATE ttRetorno.
               ASSIGN 
                  ttRetorno.situacao  = INT(es-api-log.cod-retorno)
                  ttRetorno.descricao = es-api-log.aux.
               IF es-api-log.cod-retorno = ""
               THEN ASSIGN
                  ttRetorno.situacao  = 201
                  ttRetorno.descricao = "Processamento agendado para o programa " 
                                      + REPLACE(es-api-URI.nom-programa-env,".p",".r").
            END.
         END.
      END.
   END.
   ELSE ASSIGN
      cErro = "URI " + cUri + " n∆o foi encontrada.".

   IF cErro > ""
   THEN DO:
      CREATE ttRetorno.
      ASSIGN 
         ttRetorno.situacao  = (IF iRet = 0 THEN 500 ELSE iRet)
         ttRetorno.descricao = cErro.
   END.
   
   
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-input-json-retorno Include 
PROCEDURE pi-input-json-retorno :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
   DEF OUTPUT PARAM jsonOutput        AS JsonObject NO-UNDO.
   DEF          VAR jsonObjectOutput  AS JsonObject NO-UNDO.
   DEF          VAR iRet              AS i          NO-UNDO.
   DEF          VAR lcOutput          AS LONGCHAR   NO-UNDO.

   ASSIGN
      iRet = 500.
   
   FIND FIRST ttRetorno 
        NO-ERROR.
   IF NOT AVAIL ttRetorno
   THEN DO:
      CREATE ttRetorno.
      ASSIGN 
         ttRetorno.situacao      = 500
         ttRetorno.descricao     = "API n∆o pode ser processada".
   END.
   ASSIGN
      iRet = ttRetorno.situacao.

   ASSIGN  
      jsonObjectOutput = NEW JsonObject().
   jsonObjectOutput:READ(TEMP-TABLE ttRetorno:HANDLE).
   jsonOutput = JsonAPIResponseBuilder:ok(jsonObjectOutput, iRet).

   FIND FIRST es-api-log 
        WHERE ROWID(es-api-log) = rwRec
        NO-ERROR.
   IF AVAIL es-api-log
   THEN DO:
      jsonOutput:WRITE (INPUT-OUTPUT lcOutput, INPUT YES, INPUT "UTF-8").
      COPY-LOB lcOutput TO es-api-log.cl-retorno.
      ASSIGN
         es-api-log.dh-retorno     = NOW
         es-api-log.flg-processado = YES.
   END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

