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
         HEIGHT             = 14.5
         WIDTH              = 60.
/* END WINDOW DEFINITION */
                                                                        */
&ANALYZE-RESUME

 


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Include 


/* ***************************  Main Block  *************************** */

&IF "{&OPC}" = "OPEN" 
&THEN
    OUTPUT TO VALUE(cArquivoRec) PAGE-SIZE 0.
    PUT UNFORMATTED                   SKIP
       "Inicio de execucao -- " PROGRAM-NAME(1) " -- "
       NOW                            SKIP
       FILL("-",80)                  SKIP
       "Chamada 1 - " PROGRAM-NAME(2) SKIP
       "Chamada 2 - " PROGRAM-NAME(3) SKIP
       "Chamada 3 - " PROGRAM-NAME(4) SKIP
       FILL("-",80)                  SKIP(3).

&ENDIF

&IF "{&OPC}" = "CLOSE" 
&THEN
    PUT UNFORMATTED SKIP(1)
       FILL("-",80) SKIP
       "Fim de execucao -- "
       NOW
       SKIP.

    OUTPUT CLOSE.
    RUN pi-input-erro (rw-registro).

    FIND FIRST es-api-log NO-LOCK
         WHERE ROWID(es-api-log) = rw-registro
         NO-ERROR.
    IF AVAIL es-api-log
    THEN DO TRANS:
       FIND LAST bf-api-aux NO-LOCK
           WHERE bf-api-aux.id-api-log = es-api-log.id-api-log
             AND bf-api-aux.Seq        > 0
           NO-ERROR.

       CREATE es-api-aux.
       ASSIGN
          es-api-aux.id-api-log = es-api-log.id-api-log
          es-api-aux.Seq        = (IF AVAIL bf-api-aux
                                   THEN bf-api-aux.seq + 1
                                   ELSE 1)
          es-api-aux.Tipo       = "Record"
          es-api-aux.dh-exec    = NOW.
       COPY-LOB FILE cArquivoRec TO es-api-aux.cl-aux.
    END.
    OS-DELETE VALUE(cArquivoRec).
&ENDIF

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


