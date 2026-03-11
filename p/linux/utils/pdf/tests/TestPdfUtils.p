&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v9r12
&ANALYZE-RESUME
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Procedure 
/**
*
* PROGRAMA:
*   tests/...
*
* FINALIDADE:
*   Teste de <Classe>
*
* AUTOR
*   <nome>
*/

{system/Error.i}
{system/InstanceManagerDef.i}

/* atributos */
define variable pdfFile as handle no-undo.
define variable cErro as char no-undo.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Procedure
&Scoped-define DB-AWARE no



/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Procedure
   Allow: 
   Frames: 0
   Add Fields to: Neither
   Other Settings: CODE-ONLY
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
/* DESIGN Window definition (used by the UIB) 
  CREATE WINDOW Procedure ASSIGN
         HEIGHT             = 8.38
         WIDTH              = 44.43.
/* END WINDOW DEFINITION */
                                                                        */
&ANALYZE-RESUME

 


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Procedure 


/* ***************************  Main Block  *************************** */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&IF DEFINED(EXCLUDE-checkFail) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE checkFail Procedure 
PROCEDURE checkFail :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       Obrigado Dalle!
------------------------------------------------------------------------------*/
    define variable hasError as logical   no-undo.
    define variable errorMessage as character no-undo.
    
    run hasError(output hasError).
    
    run assertTrue(not hasError).
    if hasError then do:
        run getErrorMessage(output errorMessage).
        run fail(errorMessage).
    end.
    
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-createPdf) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE createPdf Procedure 
PROCEDURE createPdf :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    do {&throws}:

        run setAuthor in pdfFile('Zeh').
        run setFileName in pdfFile('someFile.pdf').
        run setKeywords in pdfFile("TOTUS").
        run setpath in pdfFile("c:/bolinhaFoiCriadoPelaClassePdfFile").
        run setPdfStream in pdfFile("streamTST").
        run setSubject in pdfFile("TOTUSDeNovo").
        run setTitle in pdfFile('TOTUSDeNovoNovamente').

        run createPdf in pdfFile(1).
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-dispose) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE dispose Procedure 
PROCEDURE dispose :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    run deleteInstance in ghInstanceManager(this-procedure).
    
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-initialize) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE initialize Procedure 
PROCEDURE initialize :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    {system/InstanceManager.i}
    
    /* Instancias */
    run createInstance in ghInstanceManager(this-procedure,
                                            'pdf/PdfFile.p',
                                             output pdfFile).

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setup) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setup Procedure 
PROCEDURE setup :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    run emptyErrors.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-testFinalizePdf) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE testFinalizePdf Procedure 
PROCEDURE testFinalizePdf :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define variable lErro as logical init yes no-undo.

    do transaction {&try}:

        run createPdf.
        run finalizePdf in pdfFile.

        assign lErro = false.

        undo, leave.

    end.

    if not lErro then do:
        run assertTrue(true).
        return.
    end.

    run getErrorMessage(output cErro).
    run fail(cErro).

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

