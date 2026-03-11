&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v9r12
&ANALYZE-RESUME
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Procedure 
/**
* CLASSE:
*   utils/pdf/GeneralConfig.p
*
* FINALIDADE: 
*   Encapsular varios tipos de instancias de configuraá∆o.
*
* NOTAS:
*   
*   Qualquer objeto ou texto impresso no pdf ir† respeitar este limites.
*   
*/


/*Constantes de pdf*/
{utils/pdf/inc/pdf.i}

{system/Error.i}
{system/InstanceManagerDef.i}

define variable primitive     as handle no-undo.
define variable pdfStream     as character initial ''        no-undo.
define variable hasErrors     as logical no-undo.

define variable textConfig      as handle    no-undo. /*Configuraá‰es de texto*/
define variable drawConfig      as handle    no-undo. /*Configuraá‰es de desenho */
define variable pageConfig      as handle    no-undo. /*Configuraá‰es da p†gina */
define variable userProcedures  as handle    no-undo. /* customizaá‰es do usuario*/

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
         HEIGHT             = 23.71
         WIDTH              = 39.43.
/* END WINDOW DEFINITION */
                                                                        */
&ANALYZE-RESUME

 


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Procedure 


/* ***************************  Main Block  *************************** */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&IF DEFINED(EXCLUDE-configure) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE configure Procedure 
PROCEDURE configure :
/*------------------------------------------------------------------------------
  Purpose: Aplica as configuraá‰es    
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    
    do {&throws}:
        run configure in textConfig. 
        run configure in drawConfig. 
        run configure in pageConfig. 
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-configureDraw) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE configureDraw Procedure 
PROCEDURE configureDraw :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    do {&throws}:
        run configure in drawConfig.
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


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getDrawConfig) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getDrawConfig Procedure 
PROCEDURE getDrawConfig :
/*------------------------------------------------------------------------------
  Purpose: Retorna a configuraá∆o de desenho
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define output parameter drawConfig_ as handle no-undo. 

    do {&throws}:
        assign drawConfig_ = drawConfig.
    end.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getPageConfig) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getPageConfig Procedure 
PROCEDURE getPageConfig :
/*------------------------------------------------------------------------------
  Purpose: Retorna a configuraá∆o da p†gina
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define output parameter pageConfig_ as handle no-undo. 

    do {&throws}:
        assign pageConfig_ = pageConfig.
    end.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getTextConfig) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getTextConfig Procedure 
PROCEDURE getTextConfig :
/*------------------------------------------------------------------------------
  Purpose: Retorna a configuraá∆o de texto
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define output parameter textConfig_ as handle no-undo. 

    do {&throws}:
        assign textConfig_ = textConfig.
    end.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setDrawConfig) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setDrawConfig Procedure 
PROCEDURE setDrawConfig :
/*------------------------------------------------------------------------------
  Purpose: Define a configuraá∆o de desenho
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define input parameter drawConfig_ as handle no-undo. 

    do {&throws}:
        assign drawConfig = drawConfig_.
    end.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setPageConfig) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setPageConfig Procedure 
PROCEDURE setPageConfig :
/*------------------------------------------------------------------------------
  Purpose: Define a configuraá∆o da p†gina
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define input parameter pageConfig_ as handle no-undo. 

    do {&throws}:
        assign pageConfig = pageConfig_.
    end.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setPrimitive) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setPrimitive Procedure 
PROCEDURE setPrimitive :
/*------------------------------------------------------------------------------
  Purpose: Um ponteiro para o objeto principal que contem as funá‰es e metodos
           primitivos do pfdInclude.  
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define input parameter primitive_ as handle no-undo. 

    do {&throws}:

        if valid-handle(primitive) then
            run createError(17006,"O handle primitivo deste objeto n∆o pode ser modificado.").

        assign primitive = primitive_.

        run setPrimitive in textConfig(primitive).
        run setPrimitive in drawConfig(primitive).
        run setPrimitive in pageConfig(primitive).

        run validateErrors.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setStream) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setStream Procedure 
PROCEDURE setStream :
/*------------------------------------------------------------------------------
  Purpose: DEfine o stream    
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define input parameter pdfStream_ as character no-undo. 

    do {&throws}:

        if length(pdfStream) > 0 then
            run createError(17006,"O Stream para propriedades da p†gina j† foi definido").

        assign pdfStream = pdfStream_.

        run setStream in  textConfig(pdfStream).
        run setStream in  drawConfig(pdfStream).
        run setStream in  pageConfig(pdfStream).

        run validateErrors.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setTextConfig) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setTextConfig Procedure 
PROCEDURE setTextConfig :
/*------------------------------------------------------------------------------
  Purpose: Define a configuraá∆o de texto
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define input parameter textConfig_ as handle no-undo. 

    do {&throws}:
        assign textConfig = textConfig_.
    end.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setUserProcedures) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setUserProcedures Procedure 
PROCEDURE setUserProcedures :
/*------------------------------------------------------------------------------
  Purpose:  Definir a instancia onde est∆o as rotinas de customizaá∆o do usuario.
           
  Parameters:  <none>
  Notes: A descriá∆o e declaraá∆o destas rotinas est∆o em pdf/user/drawListener.p     
------------------------------------------------------------------------------*/
    define input parameter userProcedures_ as handle no-undo.

    do {&throws}:
        assign userProcedures = userProcedures_.

        run setUserProcedures in textConfig(userProcedures_).
        run setUserProcedures in drawConfig(userProcedures_).
        run setUserProcedures in pageConfig(userProcedures_).

        run validateErrors.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-startup) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE startup Procedure 
PROCEDURE startup :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    {system/InstanceManager.i}
    
    /*Handles de configuraá∆o para as funá‰es de callback*/
        run createInstance in ghInstanceManager (this-procedure,
            'utils/pdf/Elements/Config/PdfTextConfig.p':u, output textConfig).

        run createInstance in ghInstanceManager (this-procedure,
            'utils/pdf/Elements/Config/PdfDrawConfig.p':u, output drawConfig).

        run createInstance in ghInstanceManager (this-procedure,
            'utils/pdf/Elements/Config/PdfPageConfig.p':u, output pageConfig).

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-validateErrors) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE validateErrors Procedure 
PROCEDURE validateErrors :
/*------------------------------------------------------------------------------
  Purpose: Verifica a ocorrencia de erros e em caso positivo, retorna erro.    
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    do {&throws}:
        run hasError(output hasErrors).
        if hasErrors then
            return error.
    end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

