&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v9r12
&ANALYZE-RESUME
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Procedure 
/**
* CLASSE:
*   utils/pdf/PdfComfig.p
*
* FINALIDADE: 
*   Encapsular as propriedades graficas de renderizaá∆o de texto do pdfInclude.
* NOTAS:
*   Todo o texto que for renderizado para um arquivo PDF dever† obrigat¢riamente seguir as 
*   definiá‰es desta classe   
*   
*/


/*Constantes de pdf*/
{utils/pdf/inc/pdf.i}

{system/Error.i}
{system/InstanceManagerDef.i}


define variable fontName          as character initial 'Helvetica'     no-undo.
define variable fontSize          as integer   initial 10              no-undo.
define variable fontColor         as character initial '#000000'       no-undo.
define variable fontAlign         as integer   initial {&left}         no-undo.
define variable fontVerticalAlign as integer   initial {&top}          no-undo.

/*Distancia entre a linha do retangulo e o texto*/
define variable borderMargin as integer initial 3  no-undo.


/*Modo de impress∆o*/
define variable canResizeWidth      as logical   initial true        no-undo.
define variable canResizeHeight     as logical   initial true        no-undo.
define variable canHideExcedentText as logical   initial true        no-undo.

define variable breakLineSize       as integer   initial 5           no-undo.

define variable primitive     as handle    no-undo.
define variable pdfStream     as character initial ''      no-undo.
define variable hasErrors     as logical no-undo.
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
         HEIGHT             = 24.42
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
        run pdf_set_font in primitive(pdfStream, fontName, fontSize).
        run pdf_rgb in primitive(pdfStream, "pdf_text_color", fontColor).  /*Must be one of: pdf_text_color, pdf_stroke_color, pdf_stroke_fill*/ 

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

&IF DEFINED(EXCLUDE-getAlign) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getAlign Procedure 
PROCEDURE getAlign :
/*------------------------------------------------------------------------------
  Purpose: retorna o alinhamento do texto dentro de um retangulo    
  Parameters:  <none>
  Notes: Definiá‰es de alinhamento em utils/pdf/inc/pdf.i      
------------------------------------------------------------------------------*/
    define output parameter fontAlign_ as integer no-undo. 

    do {&throws}:
        assign fontAlign_ = fontAlign.
    end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getBorderMargin) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getBorderMargin Procedure 
PROCEDURE getBorderMargin :
/*------------------------------------------------------------------------------
  Purpose: Retorna a distancia entre o texto e a linha do retangulo    
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define output parameter borderMargin_ as integer no-undo.

    do {&throws}:
        assign borderMargin_ = borderMargin.
    end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getBreakLineSize) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getBreakLineSize Procedure 
PROCEDURE getBreakLineSize :
/*------------------------------------------------------------------------------
  Purpose: Define o tamanho da quebra de linha quando objetos puderem quebrar o texto.    
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define output parameter breakLineSize_ as integer   no-undo. 

    do {&throws}:
        assign breakLineSize_ = breakLineSize.
    end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getFont) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getFont Procedure 
PROCEDURE getFont :
/*------------------------------------------------------------------------------
  Purpose: Retorna o nome da fonte     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define output parameter fontName_ as character no-undo.
    
    do {&throws}:
        assign fontName_ = fontName.    
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getFontSize) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getFontSize Procedure 
PROCEDURE getFontSize :
/*------------------------------------------------------------------------------
  Purpose: Retorna o tamanho da fonte     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define output parameter fontSize_ as integer no-undo.
    
    do {&throws}:
        assign fontSize_ = fontSize.    
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getVerticalAlign) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getVerticalAlign Procedure 
PROCEDURE getVerticalAlign :
/*------------------------------------------------------------------------------
  Purpose:  retorna o alinhamento vertical do texto dentro de retangulos   
  Parameters:  <none>
  Notes: pode retornar tràs valores  1 - {&top}  
                                     2 - {&bottom}   
                                     3 - {&center} 
        
------------------------------------------------------------------------------*/
    define output parameter fontVerticalAlign_ as integer   no-undo. 

    do {&throws}:
        assign fontVerticalAlign_ = fontVerticalAlign.
    end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-isCanHideExcedentText) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE isCanHideExcedentText Procedure 
PROCEDURE isCanHideExcedentText :
/*------------------------------------------------------------------------------
  Purpose: Retorna se o texto que ultrapassar as margens do retangulo deve ser
           truncado.     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
   define output parameter canHideExcedentText_ as logical   no-undo. 

    do {&throws}:
        assign canHideExcedentText_ = canHideExcedentText.
    end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-isCanResizeHeight) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE isCanResizeHeight Procedure 
PROCEDURE isCanResizeHeight :
/*------------------------------------------------------------------------------
  Purpose: Define se o texto pode ajustar a altura do objeto para caber    
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define output parameter canResizeHeight_ as logical   no-undo. 

    do {&throws}:
        assign canResizeHeight_ = canResizeHeight.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-isCanResizeWidth) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE isCanResizeWidth Procedure 
PROCEDURE isCanResizeWidth :
/*------------------------------------------------------------------------------
  Purpose: Retorna se o texto pode ajustar a largura do objeto para caber    
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define output parameter canResizeWidth_ as logical   no-undo. 

    do {&throws}:
        assign canResizeWidth_ = canResizeWidth.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setAlign) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setAlign Procedure 
PROCEDURE setAlign :
/*------------------------------------------------------------------------------
  Purpose: define o alinhamento do texto dentro de um retangulo    
  Parameters:  <none>
  Notes: Definiá‰es de alinhamento em utils/pdf/inc/pdf.i      
------------------------------------------------------------------------------*/
    define input parameter fontAlign_ as integer no-undo. 

    do {&throws}:
        assign fontAlign = fontAlign_.
    end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setBorderMargin) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setBorderMargin Procedure 
PROCEDURE setBorderMargin :
/*------------------------------------------------------------------------------
  Purpose: Define a distancia entre o texto e a linha do retangulo    
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define input parameter borderMargin_ as integer no-undo.

    do {&throws}:
        assign borderMargin = borderMargin_.
    end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setBreakLineSize) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setBreakLineSize Procedure 
PROCEDURE setBreakLineSize :
/*------------------------------------------------------------------------------
  Purpose: Define o tamanho da quebra de linha quando objetos puderem quebrar o texto.    
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define input parameter breakLineSize_ as integer   no-undo. 

    do {&throws}:
        assign breakLineSize = breakLineSize_.
    end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setCanHideExcedentText) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setCanHideExcedentText Procedure 
PROCEDURE setCanHideExcedentText :
/*------------------------------------------------------------------------------
  Purpose: Define se o texto que ultrapassar as margens do retangulo deve ser
           truncado.     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
   define input parameter canHideExcedentText_ as logical   no-undo. 

    do {&throws}:
        assign canHideExcedentText = canHideExcedentText_.
    end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setCanResizeHeight) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setCanResizeHeight Procedure 
PROCEDURE setCanResizeHeight :
/*------------------------------------------------------------------------------
  Purpose: Define se o texto pode ajustar a altura do objeto para caber    
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define input parameter canResizeHeight_ as logical   no-undo. 

    do {&throws}:
        assign canResizeHeight = canResizeHeight_.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setCanResizeWidth) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setCanResizeWidth Procedure 
PROCEDURE setCanResizeWidth :
/*------------------------------------------------------------------------------
  Purpose: Define se o texto pode ajustar a largura do objeto para caber    
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define input parameter canResizeWidth_ as logical   no-undo. 

    do {&throws}:
        assign canResizeWidth = canResizeWidth_.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setFont) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setFont Procedure 
PROCEDURE setFont :
/*------------------------------------------------------------------------------
  Purpose: Definir a fonte    
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define input parameter fontName_ as character no-undo.
    
    do {&throws}:
        assign fontName = fontName_.    
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setFontColor) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setFontColor Procedure 
PROCEDURE setFontColor :
/*------------------------------------------------------------------------------
  Purpose: Define a cor da fonte     
  Parameters:  <none>
  Notes: Recebe o valor em RGB hexadecimal Ex. #23baff , #babaca , #00ff00      
         Em pdf/inc/Color.i Existem varias opá‰es padronizadas.
------------------------------------------------------------------------------*/
    define input parameter fontColor_ as character no-undo.
    
    do {&throws}:
        assign fontColor = fontColor_.    
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setFontSize) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setFontSize Procedure 
PROCEDURE setFontSize :
/*------------------------------------------------------------------------------
  Purpose: Define o tamanho da fonte     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define input parameter fontSize_ as integer no-undo.
    
    do {&throws}:
        assign fontSize = fontSize_.    
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
            run createError(17006,"O Stream para propriedades da p·gina j· foi definido").

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

&IF DEFINED(EXCLUDE-setVerticalAlign) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setVerticalAlign Procedure 
PROCEDURE setVerticalAlign :
/*------------------------------------------------------------------------------
  Purpose:  definir o alinhamento vertical do texto dentro de retangulos   
  Parameters:  <none>
  Notes: aceita tràs valores  1 - {&top}  
                              2 - {&bottom}   
                              3 - {&center} 
        
------------------------------------------------------------------------------*/
    define input parameter fontVerticalAlign_ as integer   no-undo. 

    do {&throws}:
        assign fontVerticalAlign = fontVerticalAlign_.
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

