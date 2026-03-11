&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v9r12
&ANALYZE-RESUME
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Procedure 
/**
* CLASSE:
*   utils/pdf/PdfDrawComfig.p
*
* FINALIDADE: 
*   Encapsular as propriedades de desenho do pdfInclude.
* NOTAS:
*   
*   Qualquer objeto ou texto impresso no pdf ir† respeitar este limites.
*   
*/


/*Constantes de pdf*/
{utils/pdf/inc/pdf.i}

{system/Error.i}
{system/InstanceManagerDef.i}


define variable pdfStream as character initial ''        no-undo.
define variable hasErrors as logical no-undo.
define variable primitive as handle  no-undo.
define variable userProcedures  as handle    no-undo. /* customizaá‰es do usuario*/

define variable lineColor as character initial '#000000' no-undo.

define variable lineSize  as integer  initial 1          no-undo.
define variable lineStyle as integer  initial {&solid}   no-undo.

define variable fillColor   as character initial '#FFFFFF' no-undo.
define variable fillObjects as logical   initial true      no-undo.

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
  Purpose: Aplica as configuraá‰es ao stream Enviado    
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    
    do {&throws}:
        
        case lineStyle:
            when {&solid} then
                RUN pdf_set_dash in primitive(pdfStream, 1,0).
            when {&dash}  then
                RUN pdf_set_dash in primitive(pdfStream, 3,3).
            when {&dashpoint} then
                RUN pdf_set_dash in primitive(pdfStream, 1,1).
        end case.

        RUN pdf_rgb in primitive(pdfStream, "pdf_stroke_color",  lineColor).
        RUN pdf_rgb in primitive(pdfStream, "pdf_stroke_fill", fillColor).
        
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

&IF DEFINED(EXCLUDE-getFillColor) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getFillColor Procedure 
PROCEDURE getFillColor :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define output parameter fillColor_ as character no-undo. 

    do {&throws}:
        assign fillColor_ = fillColor.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getLineColor) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getLineColor Procedure 
PROCEDURE getLineColor :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define output parameter lineColor_ as character no-undo. 

    do {&throws}:
        assign lineColor_ = lineColor.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getLineSize) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getLineSize Procedure 
PROCEDURE getLineSize :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define output parameter lineSize_ as integer no-undo. 

    do {&throws}:
        assign lineSize_ = lineSize.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getLineStyle) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getLineStyle Procedure 
PROCEDURE getLineStyle :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define output parameter lineStyle_ as integer no-undo. 

    do {&throws}:
        assign lineStyle_ = lineStyle.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-isFillObjects) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE isFillObjects Procedure 
PROCEDURE isFillObjects :
/*------------------------------------------------------------------------------
  Purpose: Determina se os retangulos e circulos ser∆o preenchidos
           com a cor escolhida em fillColor     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define output parameter fillObjects_ as logical no-undo. 

    do {&throws}:
        assign fillObjects_ = fillObjects.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setFillColor) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setFillColor Procedure 
PROCEDURE setFillColor :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define input parameter fillColor_ as character no-undo. 

    do {&throws}:
        assign fillColor = fillColor_.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setFillObjects) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setFillObjects Procedure 
PROCEDURE setFillObjects :
/*------------------------------------------------------------------------------
  Purpose: Determina se os retangulos e circulos ser∆o preenchidos
           com a cor escolhida em fillColor     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define input parameter fillObjects_ as logical no-undo. 

    do {&throws}:
        assign fillObjects = fillObjects_.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setLineColor) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setLineColor Procedure 
PROCEDURE setLineColor :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define input parameter lineColor_ as character no-undo. 
    do {&throws}:
        assign lineColor = lineColor_.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setLineSize) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setLineSize Procedure 
PROCEDURE setLineSize :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define input parameter lineSize_ as integer no-undo. 

    do {&throws}:
        assign lineSize = lineSize_.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setLineStyle) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setLineStyle Procedure 
PROCEDURE setLineStyle :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define input parameter lineStyle_ as integer no-undo. 

    do {&throws}:
        assign lineStyle = lineStyle_.
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

        run validateErrors.
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
        if valid-handle(userProcedures) then
            run createError(17006,"O handle de procedimentos do usuario deste objeto n∆o pode ser modificado.").

        assign userProcedures = userProcedures_.

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

