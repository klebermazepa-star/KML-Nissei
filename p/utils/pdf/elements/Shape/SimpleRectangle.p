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

define variable pdfStream     as character initial ''        no-undo.
define variable hasErrors     as logical no-undo.
define variable primitive     as handle  no-undo. 

define variable x          as integer   no-undo. 
define variable y          as integer   no-undo. 
define variable y_inv      as integer   no-undo. /*Para reverter a correá∆o de eixo*/
define variable pageHeight as integer   no-undo. /*PAra calcular a invers∆o de eixo*/
define variable width      as integer   no-undo. 
define variable height     as integer   no-undo. 
define variable myName     as character no-undo.

define variable lineSize   as integer initial 1  no-undo.
define variable isVisible  as logical initial true no-undo.
define variable isShowBreakLines  as logical initial false  no-undo. /*Linhas para depurar o layout*/
define variable isFill     as logical initial true  no-undo. /*Define se ser† preenchido com alguma cor*/



/*Eventos*/
define variable isSupressBottomMarginOverflow as logical initial false  no-undo. /*Suprime o evento quando um objeto Ç desenhado abaixo do limite da p†gina */


define variable config     as handle    no-undo.
define variable pageConfig as handle    no-undo.

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
         HEIGHT             = 18.88
         WIDTH              = 40.72.
/* END WINDOW DEFINITION */
                                                                        */
&ANALYZE-RESUME

 


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Procedure 


/* ***************************  Main Block  *************************** */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

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
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    
    do {&throws}:
        if not isVisible then
            return.
        
        /*Inverte o eixo Y*/
        run getInverseY(y, output y_inv).
        
        if isFill then
            RUN pdf_rect  in primitive(pdfStream,
                                       x,    
                                       y_inv,    
                                       width,
                                       height,
                                       lineSize).
        else
            RUN pdf_rect2 in primitive(pdfStream,
                                       x,    
                                       y_inv,    
                                       width,
                                       height,
                                       lineSize).
       
           
    end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-drawBreakLines) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE drawBreakLines Procedure 
PROCEDURE drawBreakLines :
/*------------------------------------------------------------------------------
  Purpose: Mostra as linhas de quebra     
  Parameters:  <none>
  Notes: Linha Verde    - Local onde o objeto que quebrou a pagina comeáaria
         Linha Vermelha - Local onde o objeto terminaria
         linha Azul     - Limite da quebra.     
------------------------------------------------------------------------------*/
    
    define input parameter bMargin as integer   no-undo.

    define variable YH_inv    as integer   no-undo.
    define variable maiorYInv as integer   no-undo.
    
    do {&throws}:
        
        if not isShowBreakLines then
            return.

        assign maiorYInv =  bMargin.

        run getInverseY(y, output y_inv).
        run getInverseY(y + height, output YH_inv).

        assign y_inv = y_inv + height
               yh_inv = yh_inv + height. /*Correá∆o de tamanho...*/
               
        
        /*Linha Vermelha*/
        RUN pdf_rgb      in primitive(pdfStream,'pdf_stroke_color','#FF0000').
        if YH_inv > 0 then 
            run pdf_line in primitive(pdfStream, 0,YH_inv, 214, YH_inv, 2).

        /*Linha Verde*/    
        RUN pdf_rgb      in primitive(pdfStream,'pdf_stroke_color','#00FF00').
        if y_inv > 0 then
            run pdf_line in primitive(pdfStream, 0, y_inv, 170, y_inv, 2).

        /*Linha Azul*/
        RUN pdf_rgb      in primitive(pdfStream,'pdf_stroke_color','#0000FF').
        if maiorYInv > 0 then
            run pdf_line     in primitive(pdfStream, 0, maiorYInv, 100, maiorYInv , 2).

       
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getFullMetrics) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getFullMetrics Procedure 
PROCEDURE getFullMetrics :
/*------------------------------------------------------------------------------
  Purpose: retorna os quatro pontos principais do retangulo    
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
   define output parameter  sdx   as integer  no-undo.   /* Superior Direito X (Colula)*/  
   define output parameter  sdy   as integer  no-undo.   /* Superior direito Y (Linha)*/   
   define output parameter  sex   as integer  no-undo.   /* Superior Esquerdo X (Colula)*/ 
   define output parameter  sey   as integer  no-undo.   /* Superior Esquerdo Y (Linha)*/  
   define output parameter  idx   as integer  no-undo.   /* Inferior Direito X (Colula)*/  
   define output parameter  idy   as integer  no-undo.   /* Inferior direito Y (Linha)*/   
   define output parameter  iex   as integer  no-undo.   /* Inferior Esquerdo X (Colula)*/ 
   define output parameter  iey   as integer  no-undo.   /* Inferior Esquerdo Y (Linha)*/  

    do {&throws}:
        
        assign sdx = x + width
               sdy = y 
               sex = x
               sey = y
               idx = sdx 
               idy = y + height
               iex = x
               iey = y + height.
    end.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getInverseY) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getInverseY Procedure 
PROCEDURE getInverseY PRIVATE :
/*------------------------------------------------------------------------------
  Purpose: Inverter o eixo Y    
  Parameters:  <none>
  Notes: O pdfInclude usa o eixo Y invertido por padr∆o, fazendo o ponto 0,0 ser
         no canto inferior esquerdo. A invers∆o Ç necess†ria para poder se trabalhar
         considerando o ponto 0,0 como superior esquerdo.
------------------------------------------------------------------------------*/
    define input parameter  y_normal as integer   no-undo. 
    define output parameter y_inverse as integer no-undo.


    do {&throws}:
         assign y_inverse = pageHeight - (y_normal + height).
    end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getLineSize) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getLineSize Procedure 
PROCEDURE getLineSize :
/*------------------------------------------------------------------------------
  Purpose: Define a espessura da linha    
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

&IF DEFINED(EXCLUDE-getMetrics) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getMetrics Procedure 
PROCEDURE getMetrics :
/*------------------------------------------------------------------------------
  Purpose: Retorna as medidas do retangulo    
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define output parameter x_       as integer no-undo.
    define output parameter y_       as integer no-undo.
    define output parameter width_   as integer no-undo.
    define output parameter height_  as integer no-undo.

    do {&throws}:
        assign x_      = x     
               y_      = y     
               width_  = width 
               height_ = height.

    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getName) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getName Procedure 
PROCEDURE getName :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define output parameter myName_ as character no-undo.

    do {&throws}:
        assign myName_ = myName.
    end.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getRealY) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getRealY Procedure 
PROCEDURE getRealY :
/*------------------------------------------------------------------------------
  Purpose:  Retorna o valor de Y efetivamente utilizado para desenhar no pdfinclude   
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define output parameter realY_ as integer no-undo.

    do {&throws}:
        assign realY_ = y.
    end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-isVisible) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE isVisible Procedure 
PROCEDURE isVisible :
/*------------------------------------------------------------------------------
  Purpose: Retorna se o retangulo Ç v°sivel ou n∆o    
  Parameters:  <none>
  Notes: Quando um retangulo Ç definido como invis°vel, ele n∆o Ç desenhado. (¢bvio)      
------------------------------------------------------------------------------*/
    define output parameter isVisible_ as logical   no-undo. 

    do {&throws}:

        assign isVisible_ = isVisible.

    end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-pacthMetrics) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pacthMetrics Procedure 
PROCEDURE pacthMetrics PRIVATE :
/*------------------------------------------------------------------------------
  Purpose: Corrige as medidas do retangulo para garantir que caiba na p†gina    
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define variable maiorY     as integer   no-undo.
    define variable maiorX     as integer   no-undo.
    define variable menorY     as integer   no-undo.
    define variable menorX     as integer   no-undo.

    do {&throws}:

        if valid-handle(config) and not valid-handle(pageConfig) then
            run getPageConfig in config(output pageConfig).

        if valid-handle(pageConfig) then do:
            run getMaxColumn in pageConfig(output maiorX).
            run getMaxLine   in pageConfig(output maiorY).
            run getMinColumn in pageConfig(output menorX).
            run getMinLine   in pageConfig(output menorY).
            run getPageHeight   in pageConfig(output pageHeight).

            /*Verifica se o objeto deve ir para a pr¢xima p†gina*/
            run validateBottomMarginOverflow.
            
            /*Garante que as margens ser∆o respeitadas*/
            run patch_x_point(maiorX, menorX).
            run patch_y_point(maiorY, menorY).

        end.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-patch_x_point) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE patch_x_point Procedure 
PROCEDURE patch_x_point PRIVATE :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define input parameter maiorX as integer   no-undo. 
    define input parameter menorX as integer   no-undo. 

    do {&throws}:
        if x + width > maiorX then
                assign x = maiorX - width.
            else if x < menorX then
                assign x = menorX.
    end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-patch_y_point) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE patch_y_point Procedure 
PROCEDURE patch_y_point PRIVATE :
/*------------------------------------------------------------------------------
  Purpose: Garantir que o eixo Y respeitara as margens...    
  Parameters:  <none>
  Notes: Devido a quebra autom†tica de p†gina, a margem inferior n∆o precisa ser testada.
------------------------------------------------------------------------------*/
    define input parameter maiorY      as integer   no-undo. 
    define input parameter menorY      as integer   no-undo. 

   
    do {&throws}:

        if y < menorY then
           assign y = menorY.
        
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

        if valid-handle(Config) then
            run createError(17006,"O objeto de configuraá∆o n∆o pode ser redefinido").

        assign Config = Config_.

        run validateErrors.
    end.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setFill) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setFill Procedure 
PROCEDURE setFill :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define input parameter isFill_ as logical   no-undo. 

    do {&throws}:
        assign isFill = isFill_.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setLineSize) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setLineSize Procedure 
PROCEDURE setLineSize :
/*------------------------------------------------------------------------------
  Purpose: Define a espessura da linha    
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

&IF DEFINED(EXCLUDE-setMetrics) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setMetrics Procedure 
PROCEDURE setMetrics :
/*------------------------------------------------------------------------------
  Purpose: Define as medidas do retangulo    
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define input  parameter x_       as integer no-undo.
    define input  parameter y_       as integer no-undo.
    define input  parameter width_   as integer no-undo.
    define input  parameter height_  as integer no-undo.

    do {&throws}:
        assign x      = x_     
               y      = y_     
               width  = width_ 
               height = height_.
        
        run pacthMetrics.
        
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setName) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setName Procedure 
PROCEDURE setName :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define input parameter myName_ as character no-undo. 

    do {&throws}:
        assign myName = myName_.
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

&IF DEFINED(EXCLUDE-setShowBreakLines) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setShowBreakLines Procedure 
PROCEDURE setShowBreakLines :
/*------------------------------------------------------------------------------
  Purpose:   Determina se as linhas de quebra ser∆o mostradas ou n∆o.  
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define input parameter isShowBreakLines_ as logical no-undo. 

    do {&throws}:

        assign isShowBreakLines = isShowBreakLines_.
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

&IF DEFINED(EXCLUDE-setSupressBottomMarginOverflow) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setSupressBottomMarginOverflow Procedure 
PROCEDURE setSupressBottomMarginOverflow :
/*------------------------------------------------------------------------------
  Purpose: Liga e desliga o evento de overflow da pagina.    
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define input parameter isSupressBottomMarginOverflow_ as logical   no-undo. 

    do {&throws}:
        assign isSupressBottomMarginOverflow = isSupressBottomMarginOverflow_.
    end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setVisible) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setVisible Procedure 
PROCEDURE setVisible :
/*------------------------------------------------------------------------------
  Purpose: Define se o retangulo Ç v°sivel ou n∆o    
  Parameters:  <none>
  Notes: Mesmo invisiveis, objetos causam a quebra de p†gina.      
------------------------------------------------------------------------------*/
    define input parameter isVisible_ as logical   no-undo. 

    do {&throws}:
        assign isVisible = isVisible_.
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

&IF DEFINED(EXCLUDE-validateBottomMarginOverflow) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE validateBottomMarginOverflow Procedure 
PROCEDURE validateBottomMarginOverflow :
/*------------------------------------------------------------------------------
  Purpose: Verificar ser o objeto ultrapassa os limites inferiores da p†gina    
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define variable pageHeight as integer   no-undo.
    define variable bottomMargin as integer   no-undo.

    do {&throws}:
        
        run getPageHeight in pageConfig(output pageHeight).
        run getBottomMargin in pageConfig(output bottomMargin).
        
        /*Mostra breakLines*/
        run drawBreakLines(bottomMargin).

        if (y + height) > (pageHeight - bottomMargin) then do:
                    
            /*Coloca no topo da p†gina*/
            assign y =  y - (pageHeight - bottomMargin).

            /*Chama o evento do usuario*/
            if not isSupressBottomMarginOverflow then
                run BottomMarginOverflow in PageConfig(this-procedure).

        end.
    end.

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

