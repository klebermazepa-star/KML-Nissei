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

/* Include para o tratamento de PDF ----------------------*/
{PDFinclude/pdf_inc.i}

define variable primitive      as handle no-undo.
define variable pdfStream      as character initial ''        no-undo.
define variable hasErrors      as logical no-undo.
define variable userProcedures as handle    no-undo.

define variable textValue      as character initial '' no-undo.
define variable x          as decimal   no-undo. 
define variable y          as decimal   no-undo. 
define variable y_old      as integer   no-undo. /*Para reverter a correá∆o de eixo*/
define variable width      as integer   no-undo. 
define variable height     as integer   no-undo. 
define variable myName     as character no-undo.

define variable textWidth  as integer   no-undo.
define variable textHeight as integer   no-undo.

define variable Config     as handle    no-undo.
define variable textConfig as handle    no-undo.
define variable pageConfig as handle    no-undo.

/*Variaveis de controle*/
define variable maxTextWidth as decimal   no-undo.
define variable lineCount    as integer   no-undo.

/*Clones de configuraá∆o - Para evitar multiplas chamadas*/
define variable canResizeHeight     as logical   no-undo.
define variable canResizeWidth      as logical   no-undo.
define variable canHideExcedentText as logical   no-undo.
define variable breakLineSize       as integer   no-undo.
define variable fontSize            as integer   no-undo.
define variable borderMargin        as integer   no-undo.


define temp-table ttWrap
    field lineNum as integer
    field lineText as character.

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

&IF DEFINED(EXCLUDE-configurePlace) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE configurePlace Procedure 
PROCEDURE configurePlace PRIVATE :
/*------------------------------------------------------------------------------
  Purpose: Configura o textX e Y para plotar o texto    
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define variable valign   as integer   no-undo.
    define variable fontSize as integer   no-undo.

    do {&throws}:

        run getVerticalAlign in textConfig(output valign).
        run getFontSize in textConfig(output fontSize).
        
        if height = textHeight then
            assign valign = {&top}.

        case valign: 
            when {&bottom} then
                assign y = y + textHeight - fontSize / 2.
            when {&top} then
                assign y = y + height - fontSize.
            when {&center} then
/*                 assign y = (y + ( y + height - fontSize )) / 2. */
                assign y = (y) + ((height + textHeight) / 2) - fontSize.

            otherwise 
                run createError(17006, substitute('Valor n∆o permitido para alinhamento vertical "&1"',valign)). 
        end case.

        assign x = x + borderMargin.

/*         run pdf_set_TextX in primitive(pdfStream, x). */
/*         run pdf_set_TextY in primitive(pdfStream, y). */
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

&IF DEFINED(EXCLUDE-draw) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE draw Procedure 
PROCEDURE draw :
/*------------------------------------------------------------------------------
  Purpose: Desenha o texto.     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    do {&throws}:
        /*Desenha o retangulo*/
        message 'draw:a' y.
        run super.
        message 'draw:b' y.
        /*Configura o X e Y do PDF*/
        run configurePlace.
        message 'draw:c' y.

        
        /*Coloca o texto*/
        if lineCount = 0 then
            run pdf_text_xy_dec in primitive (pdfStream, textValue, x, y).
        else
            run drawMultiLine.
/*         run pdf_text in primitive (pdfStream, textValue). */

/*         RUN pdf_Wrap_Text in primitive(pdfStream,textValue, x, x + width, "left", OUTPUT y). */

    end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-drawMultiLine) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE drawMultiLine Procedure 
PROCEDURE drawMultiLine PRIVATE :
/*------------------------------------------------------------------------------
  Purpose: Imprime varias linhas de um editor...    
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define variable tempY as integer   no-undo.
    do {&throws}:
        assign tempY = y.
        for each ttWrap no-lock:
            run pdf_text_xy_dec in primitive (pdfStream, ttWrap.lineText, x, tempY).
            assign tempY = tempY - fontSize - breakLineSize.
        end.
    end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getTextValue) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getTextValue Procedure 
PROCEDURE getTextValue :
/*------------------------------------------------------------------------------
  Purpose: retorna o texto a imprimir    
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define output parameter textValue_ as character no-undo. 

    do {&throws}:
        assign textValue_ = textValue.
    end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getTextWidth) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getTextWidth Procedure 
PROCEDURE getTextWidth PRIVATE :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define input parameter textValue_  as character no-undo. 
    define output parameter textWidth_ as decimal   no-undo.
    

    do {&throws}:
        assign textWidth_ = dynamic-function('pdf_text_widthdec' in primitive, pdfStream, textValue_).
    end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-patchHeight) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE patchHeight Procedure 
PROCEDURE patchHeight PRIVATE :
/*------------------------------------------------------------------------------
  Purpose: Se o texto n∆o cabe na altura do retangulo, aumenta a altura    
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    
    do {&throws}:
        run isCanResizeHeight in textConfig(output canResizeHeight).

        if canResizeHeight and height < textHeight then
            assign height = textHeight.
        
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-patchWidth) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE patchWidth Procedure 
PROCEDURE patchWidth :
/*------------------------------------------------------------------------------
  Purpose: Se o texto n∆o cabe na largura do retangulo, aumenta a largura    
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    
    do {&throws}:
        run isCanResizeWidth in textConfig(output canResizeWidth).
        
        /*Descobre o tamanho da margem*/
        run getBorderMargin in textConfig(output borderMargin).
        
        if canResizeWidth and width + borderMargin < textWidth then do:

            run getMaxColumn in pageConfig(output maxTextWidth).
            assign maxTextWidth = maxTextWidth - (x + borderMargin)
                   width = textWidth + borderMargin + borderMargin.

            if width > maxTextWidth then do:
                assign width = maxTextWidth.
                run wrapText.
            end.
                
            
                
        end.
        
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-populateTextMetrics) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE populateTextMetrics Procedure 
PROCEDURE populateTextMetrics PRIVATE :
/*------------------------------------------------------------------------------
  Purpose:  Define a altura e largura do texto    
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    
    do {&throws}:
        run getFontSize in textConfig(output fontSize).
        assign textHeight = fontSize.
        run getTextWidth(textValue, output textWidth).

        /*Verifica a necessidade de aumentar a altura ou largura do retangulo*/
        run patchWidth.
        run patchHeight.
        
/*                textHeight = textHeight + dynamic-function('pdf_get_wrap_length' in primitive, pdfStream, textvalue, Width). . */
/*                                                                                                                               */
    end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-populateTextWraped) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE populateTextWraped Procedure 
PROCEDURE populateTextWraped :
/*------------------------------------------------------------------------------
  Purpose: Popula a tabela ttWraped 
  Parameters:  <none>
  Notes: 
------------------------------------------------------------------------------*/
    define variable letter       as character no-undo.
    define variable letterWidth  as decimal   no-undo.

    define variable word         as character no-undo.
    define variable wordWidth    as decimal no-undo.
    define variable lineText     as character no-undo.
    define variable textSize     as integer   no-undo.
    define variable digit        as integer   no-undo.
    define variable pointWidth   as integer no-undo.
    define variable lineWidth    as decimal initial 0  no-undo.
    
    do {&throws}:
        empty temp-table ttWrap.
        assign textSize = length(trim(textValue)).    

        run getTextWidth('.', output pointWidth).

        do digit = 1 to textSize:
            assign letter = substr(textValue,digit,1)
                   word = word + letter.
            
            run getTextWidth(word, output wordWidth).
            
            run getTextWidth(lineText + '.', output lineWidth).
            assign lineWidth = lineWidth - pointWidth.
            
            if letter = ' ' or  letter = chr(10) then do:
                
                if lineWidth + wordWidth < width   then
                    assign lineText = lineText + word
                           word = ''.
                else do:
                    
                    create ttWrap.
                    assign lineCount = lineCount + 1
                           ttWrap.lineNum  = lineCount
                           ttWrap.lineText = lineText
                           lineText = word
                           lineWidth = wordWidth
                           word = ''
                           textHeight = textHeight + fontSize + breakLineSize.
                end.
            end.
        end.

        /*Coloca a £ltima linha*/
        if lineText <> word then do:
            create ttWrap.
            assign lineCount = lineCount + 1
                   ttWrap.lineNum  = lineCount
                   ttWrap.lineText = lineText + word
                   lineText = word
                   lineWidth = wordWidth
                   word = ''. 
                   
        end.

        

    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setConfig) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setConfig Procedure 
PROCEDURE setConfig :
/*------------------------------------------------------------------------------
  Purpose: Define a configuraá∆o da p†gina
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define input parameter Config_ as handle no-undo. 

    do {&throws}:
        run super(Config_).

        if valid-handle(Config) then
            run createError(17006,"O objeto de configuraá∆o n∆o pode ser redefinido").

        assign Config = Config_.

        run getTextConfig in config(output textConfig).
        run getPageConfig in config(output pageConfig).

        run validateErrors.
    end.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setMetrics) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setMetrics Procedure 
PROCEDURE setMetrics :
/*------------------------------------------------------------------------------
  Purpose: Define o tamanho do retangulo e quebra o texto se necess†rio    
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define input  parameter x_       as integer no-undo.
    define input  parameter y_       as integer no-undo.
    define input  parameter width_   as integer no-undo.
    define input  parameter height_  as integer no-undo.

    do {&throws}:

        /*Assume as configuraá‰es de renderizaá∆o (para medir o texto de acordo com a fonte)*/
        run configure in textConfig.

        run super(x_,      
                  y_,      
                  width_,  
                  height_). 
        

        /*Assume as medidas internamente*/
        run getMetrics(output x,
                       output y,     
                       output width,
                       output height).
        message x y  width  height. 

        /*Define as medidas do texto*/
        run populateTextMetrics.
        
        /*Redefine as medidas do pai com as correá‰es do filho*/
        run super(x,      
                  y,      
                  width,  
                  height).

        
        /*Finalmente, assume os valores definitivos para o filho*/
        run getMetrics(output x,
                       output y,     
                       output width,
                       output height).

        
        /*Pega o valor verdadeiro de Y (o n∆o o convertido)*/
        run getRealY(output y).
         
        
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
        run super(primitive_).

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

        run super(pdfStream_).

        if length(pdfStream) > 0 then
            run createError(17006,"O Stream para propriedades da p†gina j† foi definido").

        assign pdfStream = pdfStream_.

        run validateErrors.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setTextValue) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setTextValue Procedure 
PROCEDURE setTextValue :
/*------------------------------------------------------------------------------
  Purpose: Define o texto a imprimir    
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define input parameter textValue_ as character no-undo. 

    do {&throws}:
        
        assign textValue = textValue_
               lineCount = 0.

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

        run super(userProcedures_).

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
    {system/inherit.i utils/pdf/Elements/Shape/SimpleRectangle.p}

    
    

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-truncateText) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE truncateText Procedure 
PROCEDURE truncateText :
/*------------------------------------------------------------------------------
  Purpose: Elimina todo o texto que n∆o poderia ser mostrado.     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

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

&IF DEFINED(EXCLUDE-wrapText) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE wrapText Procedure 
PROCEDURE wrapText PRIVATE :
/*------------------------------------------------------------------------------
  Purpose: Quebra o texto qeu n∆o cabe dentro do retangulo    
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    do {&throws}:
        run isCanResizeHeight     in textConfig(output canResizeHeight).
        run isCanHideExcedentText in textConfig(output canHideExcedentText).

        if not canResizeHeight and not canHideExcedentText then 
            return.

        if canResizeHeight then 
            run populateTextWraped.

        if not canResizeHeight and canHideExcedentText then 
            run truncateText.



        
    end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

