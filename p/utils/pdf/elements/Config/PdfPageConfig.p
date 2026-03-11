&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v9r12
&ANALYZE-RESUME
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Procedure 
/**
* CLASSE:
*   utils/pdf/PdfComfig.p
*
* FINALIDADE: 
*   Encapsular os limites e procedimentos de uma p†gina.
* NOTAS:
*   
*   Qualquer objeto ou texto impresso no pdf ir† respeitar este limites.
*   
*/


/*Constantes de pdf*/
{utils/pdf/inc/pdf.i}

{system/Error.i}
{system/InstanceManagerDef.i}

/*Configuraá∆o*/
define variable topMargin     as integer   initial 20        no-undo.
define variable BottomMargin  as integer   initial 30        no-undo.
define variable leftMargin    as integer   initial 20        no-undo.
define variable rightMargin   as integer   initial 20        no-undo.
define variable pageWidth     as integer   no-undo.
define variable pageHeight    as integer   no-undo.
define variable pageColor     as character initial '#FFFFFF'   no-undo.
define variable PageOrientation  as integer   initial {&portrait} no-undo.
define variable isVisibleMargins as logical   initial true no-undo.


/*Controle*/
define variable currentPage     as integer   initial 0    no-undo.
define variable userProcedures  as handle    no-undo. /* customizaá‰es do usuario*/
define variable isUpcLocked     as logical   no-undo. /* Lock para UPC*/
define variable isAutomaticPageBreak  as logical initial true  no-undo.


define variable pdfStream     as character initial ''        no-undo.
define variable hasErrors     as logical no-undo.
define variable primitive     as handle  no-undo.

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

&IF DEFINED(EXCLUDE-BottomMarginOverflow) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE BottomMarginOverflow Procedure 
PROCEDURE BottomMarginOverflow :
/*------------------------------------------------------------------------------
  Purpose: Evento que ocorre quando um objeto ultrapassa a margem inferior    
  Parameters:  <none>
  Notes:  REspons†vel por criar uma nova p†gina     
------------------------------------------------------------------------------*/
    define input parameter simpleRectangle_ as handle no-undo. 

    do {&throws}:
            
        /*Chama o procedimento do usuario*/
        run callUpcBottomMarginOverflow(simpleRectangle_).
        
        if isAutomaticPageBreak then
            run createNewPage(pageOrientation).
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-callUpcBeforeCreateNewPage) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE callUpcBeforeCreateNewPage Procedure 
PROCEDURE callUpcBeforeCreateNewPage PRIVATE :
/*------------------------------------------------------------------------------
  Purpose:  chama o procedimento customizado do usuario caso este exista   
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    
    do {&throws}:
        if not isUpcLocked then
            if valid-handle(userProcedures) and 
               lookup('upcBeforeCreateNewPage', userProcedures:internal-entries) > 0 then do:
    
                /*Prepara objetos para serem enviados*/
                
                /*Bloqueia chamadas de callback para objetos criados dentro do callback*/
                assign isUpcLocked = true.

                /*Chama o procedimento do usuario.*/
                run upcBeforeCreateNewPage in userProcedures(primitive,
                                                             this-procedure,
                                                             currentPage).
                /*Libera o bloqueio  */
                assign isUpcLocked = false.
    
            end.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-callUpcBottomMarginOverflow) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE callUpcBottomMarginOverflow Procedure 
PROCEDURE callUpcBottomMarginOverflow :
/*------------------------------------------------------------------------------
  Purpose:  chama o procedimento customizado do usuario caso este exista   
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define input parameter simpleRectangle_ as handle no-undo.

    define variable blameName as character no-undo.

    do {&throws}:
        if not isUpcLocked then
            if valid-handle(userProcedures) and 
               lookup('UpcBottomMarginOverflow', userProcedures:internal-entries) > 0 then do:
    
                /*Prepara objetos para serem enviados*/
                run getName in simpleRectangle_(output blameName).
                
                /*Bloqueia chamadas de callback para objetos criados dentro do callback*/
                assign isUpcLocked = true.

                /*Chama o procedimento do usuario.*/
                run UpcBottomMarginOverflow in userProcedures(primitive,
                                                             this-procedure,
                                                             simpleRectangle_,
                                                             blameName).
                /*Libera o bloqueio  */
                assign isUpcLocked = false.
    
            end.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-configure) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE configure Procedure 
PROCEDURE configure :
/*------------------------------------------------------------------------------
  Purpose: Aplica as configuraá‰es ao stream Enviado    
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    
    do {&throws}:
        RUN pdf_set_BottomMargin in primitive(pdfStream, bottomMargin).
        RUN pdf_set_LeftMargin in primitive(pdfStream,leftMargin).
        RUN pdf_set_RightMargin in primitive(pdfStream, rightMargin).
        RUN pdf_set_topMargin in primitive(pdfStream,topMargin).
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-createNewPage) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE createNewPage Procedure 
PROCEDURE createNewPage :
/*------------------------------------------------------------------------------
  Purpose: Cria uma nova p†gina. 
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define input parameter pageOrientation_ as integer   no-undo.
    
    do {&throws}:
        assign pageOrientation = pageOrientation_
               currentPage = currentPage + 1.
        
        run callUpcBeforeCreateNewPage.

        if pageOrientation = {&landscape} then
            run pdf_new_page2 in primitive(pdfStream,'landscape').
        else
            run pdf_new_page2 in primitive(pdfStream,'portrait'). 

        run drawMargins.
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

&IF DEFINED(EXCLUDE-drawMargins) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE drawMargins Procedure 
PROCEDURE drawMargins PRIVATE :
/*------------------------------------------------------------------------------
  Purpose: desenha as margens da p†gina 
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define variable sdx as integer   no-undo.
    define variable sdy as integer   no-undo.
    define variable sex as integer   no-undo.
    define variable sey as integer   no-undo.

    define variable idx as integer   no-undo.
    define variable idy as integer   no-undo.
    define variable iex as integer   no-undo.
    define variable iey as integer   no-undo.


    do {&throws}:
        if not isVisibleMargins then
            return.

        run populateMetrics.

        RUN pdf_set_dash in primitive(pdfStream,3,6).
        RUN pdf_rgb      in primitive(pdfStream,'pdf_stroke_color','#0000FF').

        assign   sex =  leftMargin              
                 sey =  pageHeight - topMargin 
                 sdx =  pageWidth - rightMargin 
                 sdy =  pageHeight - topMargin 

                 iex =  leftMargin
                 iey =  BottomMargin
                 idx =  pageWidth - rightMargin
                 idy =  BottomMargin.


        /*TopMargin*/
        RUN pdf_line in primitive(pdfStream, sex, sey, sdx, sdy, 0.5).

        /*BottomMargin*/
        RUN pdf_line in primitive(pdfStream, iex, iey, idx, idy, 0.5).

        /*LeftMargin*/
        RUN pdf_line in primitive(pdfStream, iex, iey, sex, sey, 0.5).

        /*RightMargin*/
        RUN pdf_line in primitive(pdfStream, idx, idy, sdx, sdy, 0.5).

    end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getBottomMargin) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getBottomMargin Procedure 
PROCEDURE getBottomMargin :
/*------------------------------------------------------------------------------
  Purpose: Retorna o tamanho da margem inferior     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define output parameter BottomMargin_ as integer no-undo.
    
    do {&throws}:
        assign BottomMargin_ = BottomMargin.    
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getLeftMargin) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getLeftMargin Procedure 
PROCEDURE getLeftMargin :
/*------------------------------------------------------------------------------
  Purpose: Retorna o tamanho da margem esquerda    
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define output parameter LeftMargin_ as integer no-undo.
    
    do {&throws}:
        assign LeftMargin_ = LeftMargin.    
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getMaxColumn) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getMaxColumn Procedure 
PROCEDURE getMaxColumn :
/*------------------------------------------------------------------------------
  Purpose: retorna o ponto X m†ximo em que se pode imprimir no PDF    
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define output parameter max_x as integer no-undo.

    do {&throws}:
        run populateMetrics. 
        assign max_x = pageWidth - rightMargin.
    end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getMaxLine) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getMaxLine Procedure 
PROCEDURE getMaxLine :
/*------------------------------------------------------------------------------
  Purpose: retorna o ponto Y m†ximo em que se pode imprimir no PDF.    
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define output parameter max_y as integer no-undo.

    do {&throws}:
        run populateMetrics. 
        assign max_y = pageHeight - bottomMargin - topMargin.
    end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getMinColumn) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getMinColumn Procedure 
PROCEDURE getMinColumn :
/*------------------------------------------------------------------------------
  Purpose: retorna o ponto X m°nimo em que se pode imprimir no PDF    
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define output parameter min_x as integer no-undo.

    do {&throws}:
        assign min_x = leftMargin.
    end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getMinLine) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getMinLine Procedure 
PROCEDURE getMinLine :
/*------------------------------------------------------------------------------
  Purpose: retorna o ponto Y m°nimo em que se pode imprimir no PDF.    
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define output parameter min_y as integer no-undo.

    do {&throws}:
        assign min_y = topMargin.
    end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getPageColor) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getPageColor Procedure 
PROCEDURE getPageColor :
/*------------------------------------------------------------------------------
  Purpose: Retorna a cor de fundo a p†gina   
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define output parameter pageColor_ as character no-undo.
    
    do {&throws}:
        assign pageColor_ = pageColor.    
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getPageHeight) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getPageHeight Procedure 
PROCEDURE getPageHeight :
/*------------------------------------------------------------------------------
  Purpose: Retorna a largura da p†gina    
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define output parameter pageHeight_ as integer no-undo.
    do {&throws}:
        run populateMetrics. 
        assign pageHeight_ = pageHeight.
    end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getPageNumber) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getPageNumber Procedure 
PROCEDURE getPageNumber :
/*------------------------------------------------------------------------------
  Purpose: N£mero da p†gina atual    
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define output parameter currentPage_ as integer no-undo.

    do {&throws}:
        assign currentPage_ = currentPage.
    end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getPageOrientation) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getPageOrientation Procedure 
PROCEDURE getPageOrientation :
/*------------------------------------------------------------------------------
  Purpose: N£mero da p†gina atual    
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define output parameter pageOrientation_ as integer no-undo.

    do {&throws}:
        assign pageOrientation_ = pageOrientation.
    end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getPageWidth) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getPageWidth Procedure 
PROCEDURE getPageWidth :
/*------------------------------------------------------------------------------
  Purpose: Retorna a largura da p†gina    
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define output parameter pageWidth_ as integer no-undo.

    do {&throws}:
        run populateMetrics. 
        assign pageWidth_ = pageWidth.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getRightMargin) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getRightMargin Procedure 
PROCEDURE getRightMargin :
/*------------------------------------------------------------------------------
  Purpose: Retorna o tamanho da margem esquerda    
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define output parameter RightMargin_ as integer no-undo.
    
    do {&throws}:
        assign RightMargin_ = RightMargin.    
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getTopMargin) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getTopMargin Procedure 
PROCEDURE getTopMargin :
/*------------------------------------------------------------------------------
  Purpose: Retorna a margem superior     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define output parameter topMargin_ as integer no-undo.
    
    do {&throws}:
        assign topMargin_ = topMargin.    
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getTotalPages) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getTotalPages Procedure 
PROCEDURE getTotalPages :
/*------------------------------------------------------------------------------
  Purpose: retorna a macro de PDF que informa o total de p†ginas em tempo de impress∆o    
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define output parameter macroTotalPages as character no-undo.

    do {&throws}:
        assign macroTotalPages = dynamic-function('pdf_TotalPages'  in primitive, pdfStream).
    end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-populateMetrics) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE populateMetrics Procedure 
PROCEDURE populateMetrics PRIVATE :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    do {&throws}:

        assign pageWidth  = dynamic-function('pdf_PageWidth'  in primitive, pdfStream)
               pageHeight = dynamic-function('pdf_PageHeight' in primitive, pdfStream).

    end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setAutomaticPageBreak) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setAutomaticPageBreak Procedure 
PROCEDURE setAutomaticPageBreak :
/*------------------------------------------------------------------------------
  Purpose:  Define se o evento de overflow ir† quebrar a p†gina automaticamente   
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define input parameter isAutomaticPageBreak_ as logical   no-undo. 

    do {&throws}:
        set isAutomaticPageBreak = isAutomaticPageBreak_.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setBottomMargin) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setBottomMargin Procedure 
PROCEDURE setBottomMargin :
/*------------------------------------------------------------------------------
  Purpose: Definir a margem inferior   
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define input parameter bottomMargin_ as integer no-undo.
    
    do {&throws}:
        assign bottomMargin = bottomMargin_.    
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setLeftMargin) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setLeftMargin Procedure 
PROCEDURE setLeftMargin :
/*------------------------------------------------------------------------------
  Purpose: Define o tamanho da margem esquerda
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define input parameter LeftMargin_ as integer no-undo.
    
    do {&throws}:
        assign LeftMargin = LeftMargin_.    
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setPageColor) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setPageColor Procedure 
PROCEDURE setPageColor :
/*------------------------------------------------------------------------------
  Purpose: Definir a cor de fundo a p†gina   
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define input parameter pageColor_ as character no-undo.
    
    do {&throws}:
        assign pageColor = pageColor_.    
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setPageOrientation) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setPageOrientation Procedure 
PROCEDURE setPageOrientation :
/*------------------------------------------------------------------------------
  Purpose: N£mero da p†gina atual    
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define input parameter pageOrientation_ as integer no-undo.

    do {&throws}:
        assign pageOrientation = pageOrientation_.
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

&IF DEFINED(EXCLUDE-setRightMargin) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setRightMargin Procedure 
PROCEDURE setRightMargin :
/*------------------------------------------------------------------------------
  Purpose: Definir a margem superior   
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define input parameter RightMargin_ as integer no-undo.
    
    do {&throws}:
        assign RightMargin = RightMargin_.    
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

&IF DEFINED(EXCLUDE-setTopMargin) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setTopMargin Procedure 
PROCEDURE setTopMargin :
/*------------------------------------------------------------------------------
  Purpose: Definir a margem superior   
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define input parameter topMargin_ as integer no-undo.
    
    do {&throws}:
        assign topMargin = topMargin_.    
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

&IF DEFINED(EXCLUDE-setVisibleMargins) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setVisibleMargins Procedure 
PROCEDURE setVisibleMargins :
/*------------------------------------------------------------------------------
  Purpose:  Mostra as margens da p†gina com uma linha pontilhada   
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define input parameter isVisibleMargins_ as logical no-undo.

    do {&throws}:
        assign isVisibleMargins = isVisibleMargins_.
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

