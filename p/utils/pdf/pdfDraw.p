&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v9r12
&ANALYZE-RESUME
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Procedure 
/**
* CLASSE:
*   utils/pdf/PdfDraw.p
*
* FINALIDADE: 
*   Prover metodos de medio e alto n°vel para criaá∆o de layouts em um PDF.
* NOTAS:
*   
*   
*   
*/


/*Constantes de pdf*/
{utils/pdf/inc/pdf.i}

{system/Error.i}
{system/InstanceManagerDef.i}

/*Temp-Table para implementar o conceito de 'shape-named' */
define temp-table ttcoordenadas no-undo
    field nome  as character   /* Nome arbitrario do objeto   */
    field sdx   as integer     /* Superior Direito X (Colula) */
    field sdy   as integer     /* Superior direito Y (Linha)  */
    field sex   as integer     /* Superior Esquerdo X (Colula)*/
    field sey   as integer     /* Superior Esquerdo Y (Linha) */ 
    field idx   as integer     /* Inferior Direito X (Colula) */ 
    field idy   as integer     /* Inferior direito Y (Linha)  */  
    field iex   as integer     /* Inferior Esquerdo X (Colula)*/
    field iey   as integer     /* Inferior Esquerdo Y (Linha) */ 
    field pag   as integer.    /* n£mero da p†gina            */
      

define variable pdfStream     as character initial ''        no-undo.
define variable hasErrors     as logical no-undo.

define variable config          as handle    no-undo. /* Configuraá‰es de renderizaá∆o */
define variable userProcedures  as handle    no-undo. /* Ponteiro para customizaá‰es do usuario */
define variable primitive       as handle    no-undo.

define variable simpleRectangle as handle    no-undo. /* Retangulo padr∆o */
define variable simpleText      as handle    no-undo. /* Retangulo padr∆o */


/*Variaveis de controle*/
define variable lineSize            as integer   no-undo.
define variable contaElementos      as decimal   no-undo.
define variable isUpcLocked         as logical   no-undo.
define variable isDebugMode         as logical  initial false  no-undo.
define variable referencePoint      as integer initial {&begin} no-undo.
define variable arbitraryDiference  as integer initial 0  no-undo.



/*Cursor do pdf*/
define variable x               as integer initial 0   no-undo.
define variable y               as integer initial 0   no-undo.

/*Medidas do de referencia de outro objeto*/

define variable referenceX      as integer   no-undo.
define variable referenceY      as integer   no-undo.
define variable referenceWidth  as integer   no-undo.
define variable referenceHeight as integer   no-undo.

/*Nome do objeto Atual*/
define variable currentName     as character no-undo.

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
         HEIGHT             = 23.46
         WIDTH              = 39.43.
/* END WINDOW DEFINITION */
                                                                        */
&ANALYZE-RESUME

 


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Procedure 


/* ***************************  Main Block  *************************** */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&IF DEFINED(EXCLUDE-callUpcDrawRectangle) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE callUpcDrawRectangle Procedure 
PROCEDURE callUpcDrawRectangle PRIVATE :
/*------------------------------------------------------------------------------
  Purpose:  chama o procedimento customizado do usuario caso este exista   
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define input parameter rectangle_ as handle no-undo. 

    define variable drawConfig as handle    no-undo.
    
    do {&throws}:

        if not isUpcLocked then
            if valid-handle(userProcedures) and 
               lookup('upcDrawRectangle', userProcedures:internal-entries) > 0 then do:
    
                /*Prepara objetos para serem enviados*/
                run getDrawConfig in config(output drawConfig).
                
                /*Bloqueia chamadas de callback para objetos criados dentro do callback*/
                assign isUpcLocked = true.

                /*Chama o procedimento do usuario.*/
                run upcDrawRectangle in userProcedures(this-procedure,
                                                       rectangle_,
                                                       drawConfig,
                                                       currentName).
                /*Libera o bloqueio  */
                assign isUpcLocked = false.
    
            end.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-callUpcInitialConfig) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE callUpcInitialConfig Procedure 
PROCEDURE callUpcInitialConfig PRIVATE :
/*------------------------------------------------------------------------------
  Purpose:  chama o procedimento de configuraá‰es iniciais caso este exista   
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define input parameter pageConfig as handle no-undo. 

    define variable drawConfig as handle    no-undo.
    define variable textConfig as handle    no-undo.
    
    do {&throws}:

        if not isUpcLocked then
            if valid-handle(userProcedures) and 
               lookup('UpcInitialConfig', userProcedures:internal-entries) > 0 then do:
    
                /*Prepara objetos para serem enviados*/
                run getDrawConfig in config(output drawConfig).
                run getTextConfig in config(output textConfig).
                
                /*Bloqueia chamadas de callback para objetos criados dentro do callback*/
                assign isUpcLocked = true.

                /*Chama o procedimento do usuario.*/
                run UpcInitialConfig in userProcedures(pageConfig,
                                                       drawConfig,
                                                       textConfig).
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
PROCEDURE configure PRIVATE :
/*------------------------------------------------------------------------------
  Purpose: Aplica as configuraá‰es ao stream Enviado    
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    
    do {&throws}:

        run configure in Config. 
        
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-configureObject) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE configureObject Procedure 
PROCEDURE configureObject PRIVATE :
/*------------------------------------------------------------------------------
  Purpose: Prepara um objeto para ser desenhado no PDF    
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define input parameter RectangleObject as handle      no-undo. 
    define input parameter objName         as character   no-undo. 
    define input parameter x_              as integer     no-undo. 
    define input parameter y_              as integer     no-undo. 
    define input parameter width_          as integer     no-undo. 
    define input parameter height_         as integer     no-undo. 

    do {&throws}:
        run setName    in RectangleObject(objName).
        run setMetrics in RectangleObject(x_,      
                                          y_,      
                                          width_,  
                                          height_).
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
    define input parameter pageOrientation as integer   no-undo. 
    define variable pageNum as integer   no-undo.
    
    define variable pageConfig             as handle    no-undo.
    do {&throws}:
        run getPageConfig in config(output pageConfig).
        run getPageNumber in pageConfig(output pageNum).

        if pageNum = 0 then
            run callUpcInitialConfig(pageConfig).

        run createNewPage in pageConfig(pageOrientation).

        /*Cria um ponto de partida em 0,0*/
        run setCursorXY('Begin',0,0).
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

&IF DEFINED(EXCLUDE-drawObject) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE drawObject Procedure 
PROCEDURE drawObject PRIVATE :
/*------------------------------------------------------------------------------
  Purpose: Desenha um objeto da familia rectangle e salva no hist¢rico.    
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define input parameter RectangleObject as handle   no-undo. 
    do {&throws}:

        
        run configureDraw in Config.
        
        /*Desenha o retangulo*/
        run draw  in RectangleObject.

        /*Armazena as coordenadas do retangulo para uso posterior*/
        run saveRectangle(RectangleObject).
    end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-drawRectangle) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE drawRectangle Procedure 
PROCEDURE drawRectangle :
/*------------------------------------------------------------------------------
  Purpose: Esta procedure provavelemente ser† exclu°da.
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define input parameter myName   as character no-undo.
    define input parameter width  as integer   no-undo. 
    define input parameter height as integer   no-undo. 
    
    do {&throws}:
        
        if myname = ? or myname = '' then
            run getNextName(output myname).

        assign currentName = myname.


        /*Define o retangulo*/
        run setName in simpleRectangle(myName).
        run setMetrics in simpleRectangle(x,
                                          y,
                                          width,
                                          height).

        /*Reservado para chamar o UPC*/
        run callUpcDrawRectangle(simpleRectangle).

        /*Define as alteraá‰es feitas pela upc*/
        run getMetrics in simpleRectangle(output x,
                                          output y,
                                          output width,
                                          output height).
        /*Configura opá‰es de desenho*/
        run configureDraw in Config.

        /*Desenha o retangulo*/
        run draw        in simpleRectangle.

        /*Armazena as coordenadas do retangulo para uso posterior*/
        run saveRectangle(simpleRectangle).

        
    end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-drawRectangleInDownOf) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE drawRectangleInDownOf Procedure 
PROCEDURE drawRectangleInDownOf :
/*------------------------------------------------------------------------------
  Purpose: Desenha um retangulo a direita de outro retangulo
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define input parameter myName    as character no-undo.
    define input parameter referenceName as character no-undo.
    define input parameter width     as integer   no-undo. 
    define input parameter height    as integer   no-undo. 
    
    do {&throws}:
        
        /*Prepara para desenhar*/
        run prepareDraw(input-output myName,
                        input-output referenceName).

        /*Escolhe as medidas adequadas para o objeto clonado*/
        run populateReferenceDownMetrics.

         
        /*Verifica se o objeto pode mudar de p†gina*/
        run validateMarginDownOverflow.

        /*Finaliza a operaá∆o*/
        run finalizeDraw(input simpleRectangle,
                         input-output myName,
                         input-output referenceName,
                         input-output width,
                         input-output height).

        
        
    end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-drawRectangleInRightOf) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE drawRectangleInRightOf Procedure 
PROCEDURE drawRectangleInRightOf :
/*------------------------------------------------------------------------------
  Purpose: Desenha um retangulo a direita de outro retangulo
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define input parameter myname    as character no-undo.
    define input parameter referenceName as character no-undo.
    define input parameter width     as integer   no-undo. 
    define input parameter height    as integer   no-undo. 
    
    do {&throws}:
        
        /*Prepara para desenhar*/
        run prepareDraw(input-output myName,
                        input-output referenceName).

        /*Escolhe as medidas adequadas para o objeto clonado*/
        run populateReferenceRightMetrics.

        /*Finaliza a operaá∆o*/
        run finalizeDraw(input simpleRectangle,
                         input-output myName,
                         input-output referenceName,
                         input-output width,
                         input-output height).

        
        
    end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-drawTextInDownOf) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE drawTextInDownOf Procedure 
PROCEDURE drawTextInDownOf :
/*------------------------------------------------------------------------------
  Purpose: Desenha um retangulo a direita de outro retangulo
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define input parameter textValue as character no-undo. 
    define input parameter myname    as character no-undo.
    define input parameter referenceName as character no-undo.
    define input parameter width     as integer   no-undo. 
    define input parameter height    as integer   no-undo.

    
    do {&throws}:
        
        /*Prepara para desenhar*/
        run prepareDraw(input-output myName,
                        input-output referenceName).

        /*Escolhe as medidas adequadas para o objeto clonado*/
        run populateReferenceDownMetrics.

        run setTextValue in simpleText(textValue).

        /*Finaliza a operaá∆o*/
        run finalizeDraw(input simpleText,
                         input-output myName,
                         input-output referenceName,
                         input-output width,
                         input-output height).

        
        
    end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-drawTextInRightOf) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE drawTextInRightOf Procedure 
PROCEDURE drawTextInRightOf :
/*------------------------------------------------------------------------------
  Purpose: Desenha um retangulo a direita de outro retangulo
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define input parameter textValue as character no-undo. 
    define input parameter myname    as character no-undo.
    define input parameter referenceName as character no-undo.
    define input parameter width     as integer   no-undo. 
    define input parameter height    as integer   no-undo.

    
    do {&throws}:
        
        /*Prepara para desenhar*/
        run prepareDraw(input-output myName,
                        input-output referenceName).

        /*Escolhe as medidas adequadas para o objeto clonado*/
        run populateReferenceRightMetrics.

        run setTextValue in simpleText(textValue).

        /*Finaliza a operaá∆o*/
        run finalizeDraw(input simpleText,
                         input-output myName,
                         input-output referenceName,
                         input-output width,
                         input-output height).

        
        
    end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-finalizeDraw) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE finalizeDraw Procedure 
PROCEDURE finalizeDraw PRIVATE :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define input parameter rectangleObject  as handle    no-undo.
    define input-output parameter myName    as character no-undo.
    define input-output parameter referenceName as character no-undo.
    define input-output parameter width     as integer   no-undo. 
    define input-output parameter height    as integer   no-undo. 

    do {&throws}:
        /*Assume os valores padr∆o para as medidas n∆o informadas*/
        run patchMetricsParameter(input-output width,
                                  input-output height).
        
        /*Define o retangulo*/
        run configureObject(rectangleObject, 
                            myName,
                            referenceX,
                            referenceY,
                            width,
                            height).
        
        /*Reservado para chamar o UPC*/ 
        run callUpcDrawRectangle(rectangleObject).
        
        /*Define as alteraá‰es feitas pela upc*/
        run getMetrics in rectangleObject(output x,
                                          output y,     
                                          output width,
                                          output height).
        
        /*Desenha o objeto*/
        run drawObject(rectangleObject).

    end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-find) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE find Procedure 
PROCEDURE find PRIVATE :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define input parameter name_ as character no-undo. 

    do {&throws}:
        find first ttcoordenadas
            where ttcoordenadas.nome = name_
            no-lock no-error.

        if not avail(ttcoordenadas) then
            run createError(17006,substitute('O elemento com o nome "&1" n∆o foi encontrado',name_)).

        run validateErrors.
    end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getConfig) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getConfig Procedure 
PROCEDURE getConfig :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define output parameter config_ as handle no-undo.

    do {&throws}:
        assign config_ = config.
    end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getNextName) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getNextName Procedure 
PROCEDURE getNextName PRIVATE :
/*------------------------------------------------------------------------------
  Purpose: Criar um nome £nico para cada cada objeto sem nome definido    
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define output parameter newName_ as character no-undo.
    do {&throws}:
       assign contaElementos = contaElementos + 1
              newName_ = 'obj' + string(contaElementos).

    end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-initializeConfig) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE initializeConfig Procedure 
PROCEDURE initializeConfig PRIVATE :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    do {&throws}:
        run setStream    in config(pdfStream).
        run setPrimitive in config(primitive).
    end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-initializeObjects) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE initializeObjects Procedure 
PROCEDURE initializeObjects PRIVATE :
/*------------------------------------------------------------------------------
  Purpose: inicia as propriedades de comunicaá∆o com as classes manipuladas     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    do {&throws}:
        
       run getPdfStream (output pdfStream).
       run getPrimitive (output primitive).

       run initializeConfig.

       run initializeShape(simpleRectangle).
       run initializeShape(simpleText).

    end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-initializeShape) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE initializeShape Procedure 
PROCEDURE initializeShape PRIVATE :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define input parameter rectangleObject as handle   no-undo. 
    do {&throws}:
        
        run setStream     in rectangleObject(pdfStream).
        run setPrimitive  in rectangleObject(primitive).
        run setConfig     in rectangleObject(Config).
        
    end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-patchMetricsParameter) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE patchMetricsParameter Procedure 
PROCEDURE patchMetricsParameter PRIVATE :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define  input-output parameter  width      as integer   no-undo.
    define  input-output parameter  height     as integer   no-undo.

    do {&throws}:
        if height = ? or height = 0 then
            height = referenceHeight.

        if width = ? or width = 0 then
            width = referenceWidth.

    end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-patchNameParameter) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE patchNameParameter Procedure 
PROCEDURE patchNameParameter PRIVATE :
/*------------------------------------------------------------------------------
  Purpose: Assumir valores padr∆o para nomes recebidos por parametros    
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

   define  input-output parameter  myName     as character no-undo.
   define  input-output parameter  referenceName  as character no-undo.

    do {&throws}:
        if myName = ? or myName = '' then
            run getNextName(output myName). /*Um nome aleatorio qualquer*/

        if referenceName = ? or referenceName = '' then
            assign referenceName = currentName. /*Ultimo objeto utilizado*/

        assign currentName = myName.
        
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-populateReferenceDownMetrics) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE populateReferenceDownMetrics Procedure 
PROCEDURE populateReferenceDownMetrics PRIVATE :
/*------------------------------------------------------------------------------
  Purpose: Define as coordenadas inferiores de acordo com as configuraá‰es de desenho.
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    
    do {&throws}:
        
        run populateReferenceMetrics.


        /*Define o ponto base para o desenho*/
        case referencePoint:
            when {&begin}    then
                assign  referenceX = ttcoordenadas.iex 
                        referenceY = ttcoordenadas.iey. 
            
            when {&beginMid} then 
                assign  referenceX = (ttcoordenadas.iex + (ttcoordenadas.iex + ttcoordenadas.idx) / 2) / 2
                        referenceY = ttcoordenadas.iey. 

            when {&mid}      then 
                assign  referenceX = (ttcoordenadas.iex + ttcoordenadas.idx) / 2
                        referenceY = ttcoordenadas.idy . /*teste*/ 

            when {&midEnd}   then 
                assign  referenceX = (ttcoordenadas.idx  + (ttcoordenadas.iex + ttcoordenadas.idx) / 2) / 2
                        referenceY = ttcoordenadas.iey. 

            when {&End}      then 
                assign  referenceX = ttcoordenadas.idx 
                        referenceY = ttcoordenadas.idy.
        end case.
        
        /*acrescenta a diferenáa arbitr†ria*/
        assign referenceX = referenceX + arbitraryDiference
               arbitraryDiference = 0.

    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-populateReferenceMetrics) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE populateReferenceMetrics Procedure 
PROCEDURE populateReferenceMetrics PRIVATE :
/*------------------------------------------------------------------------------
  Purpose: Define a altura e largura do objeto clon†vel    
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    do {&throws}:
        
        assign referenceHeight = ttcoordenadas.iey - ttcoordenadas.sey
               referenceWidth = ttcoordenadas.sdx - ttcoordenadas.sex.

    end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-populateReferenceRightMetrics) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE populateReferenceRightMetrics Procedure 
PROCEDURE populateReferenceRightMetrics PRIVATE :
/*------------------------------------------------------------------------------
  Purpose: Define as coordenadas a direita de acordo com as configuraá‰es de desenho.
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    
    do {&throws}:
        
        run populateReferenceMetrics.
        
        
        /*Define o ponto base de referencia para o desenho*/
        case referencePoint:
            when {&begin}    then
                assign  referenceX = ttcoordenadas.sdx 
                        referenceY = ttcoordenadas.sdy. 
            
            when {&beginMid} then 
                assign  referenceX = ttcoordenadas.sdx 
                        referenceY = (ttcoordenadas.sdy + (ttcoordenadas.idy + ttcoordenadas.sdy) / 2) / 2. 

            when {&mid}      then 
                assign  referenceX = ttcoordenadas.sdx 
                        referenceY = (ttcoordenadas.idy + ttcoordenadas.sdy) / 2. 

            when {&midEnd}   then 
                assign  referenceX = ttcoordenadas.sdx 
                        referenceY = (ttcoordenadas.idy + (ttcoordenadas.idy + ttcoordenadas.sdy) / 2) / 2. 
                        

            when {&end}      then 
                assign  referenceX = ttcoordenadas.idx 
                        referenceY = ttcoordenadas.idy. 

        end case.
        
        /*acrescenta a diferenáa arbitr†ria*/
        assign referenceY = referenceY + arbitraryDiference
               arbitraryDiference = 0.
        
                
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-prepareDraw) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE prepareDraw Procedure 
PROCEDURE prepareDraw PRIVATE :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define input-output parameter myname    as character no-undo.
    define input-output parameter referenceName as character no-undo.

    do {&throws}:
        /*Define os valores padr∆o para os parametros n∆o passados.*/
        run patchNameParameter(input-output myName,
                               input-output referenceName).
        
        /*Encontra o hist¢rico do objeto clonado*/
        run find(referenceName).

    end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-savePoint) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE savePoint Procedure 
PROCEDURE savePoint PRIVATE :
/*------------------------------------------------------------------------------
  Purpose: Armazena as coordenadas do retangulo    
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    
    define variable currentPage as integer   no-undo.
    define variable pageConfig  as handle    no-undo.

    do {&throws}:
            
       run getPageConfig in config(output pageConfig).
       run getPageNumber in pageConfig(output currentPage).


       find first ttcoordenadas where ttcoordenadas.nome = currentName exclusive-lock no-error. 

       if not avail ttcoordenadas then
           create ttcoordenadas.

       assign ttcoordenadas.nome = currentName   /* Nome arbitrario do objeto   */
              ttcoordenadas.sdx = x           /* Superior Direito X (Colula) */
              ttcoordenadas.sdy = y           /* Superior direito Y (Linha)  */
              ttcoordenadas.sex = x           /* Superior Esquerdo X (Colula)*/
              ttcoordenadas.sey = y           /* Superior Esquerdo Y (Linha) */ 
              ttcoordenadas.idx = x           /* Inferior Direito X (Colula) */ 
              ttcoordenadas.idy = y           /* Inferior direito Y (Linha)  */  
              ttcoordenadas.iex = x           /* Inferior Esquerdo X (Colula)*/
              ttcoordenadas.iey = y           /* Inferior Esquerdo Y (Linha) */ 
              ttcoordenadas.pag = currentPage.   /* Pagina corrente             */
       release ttcoordenadas.

    end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-saveRectangle) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE saveRectangle Procedure 
PROCEDURE saveRectangle PRIVATE :
/*------------------------------------------------------------------------------
  Purpose: Armazena as coordenadas do retangulo    
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define input parameter rectangleObject as handle no-undo. 

    define variable sdx_ as integer no-undo.
    define variable sdy_ as integer no-undo.
    define variable sex_ as integer no-undo.
    define variable sey_ as integer no-undo.
    define variable idx_ as integer no-undo.
    define variable idy_ as integer no-undo.
    define variable iex_ as integer no-undo.
    define variable iey_ as integer no-undo.

    define variable currentPage as integer   no-undo.
    define variable pageConfig  as handle    no-undo.

    do {&throws}:
            
       run getPageConfig in config(output pageConfig).
       run getPageNumber in pageConfig(output currentPage).


       run getFullMetrics in rectangleObject(output sdx_,
                                             output sdy_,
                                             output sex_,
                                             output sey_,
                                             output idx_,
                                             output idy_,
                                             output iex_,
                                             output iey_).

       find first ttcoordenadas where ttcoordenadas.nome = currentName exclusive-lock no-error. 

       if not avail ttcoordenadas then
           create ttcoordenadas.

      
       assign ttcoordenadas.nome = currentName   /* Nome arbitrario do objeto   */
              ttcoordenadas.sdx = sdx_           /* Superior Direito X (Colula) */
              ttcoordenadas.sdy = sdy_           /* Superior direito Y (Linha)  */
              ttcoordenadas.sex = sex_           /* Superior Esquerdo X (Colula)*/
              ttcoordenadas.sey = sey_           /* Superior Esquerdo Y (Linha) */ 
              ttcoordenadas.idx = idx_           /* Inferior Direito X (Colula) */ 
              ttcoordenadas.idy = idy_           /* Inferior direito Y (Linha)  */  
              ttcoordenadas.iex = iex_           /* Inferior Esquerdo X (Colula)*/
              ttcoordenadas.iey = iey_           /* Inferior Esquerdo Y (Linha) */ 
              ttcoordenadas.pag = currentPage.   /* Pagina corrente             */
       release ttcoordenadas.

    end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setArbitraryDiference) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setArbitraryDiference Procedure 
PROCEDURE setArbitraryDiference :
/*------------------------------------------------------------------------------
  Purpose: Valor arbitrario de diferenáa entre o local onde o quadrado seria desenhado
           de acordo com o objeto de referencia e o local onde ele efetivamente ser†
           desenhado.     
  Parameters:  <none>
  Notes: Ser† zerado autom†ticamente ap¢s ser utilizado.
------------------------------------------------------------------------------*/
    define input parameter arbitraryDiference_ as integer   no-undo. 

    do {&throws}:
        assign arbitraryDiference = arbitraryDiference_.
    end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setCursorXY) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setCursorXY Procedure 
PROCEDURE setCursorXY :
/*------------------------------------------------------------------------------
  Purpose: Define um ponto no layout e atribui a ele um nome.    
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define input parameter pointName as character no-undo.
    define input parameter x_ as integer   no-undo.
    define input parameter y_ as integer   no-undo.
    

    do {&throws}:
        assign x = x_
               y = y_
               currentName = pointName.

        run savePoint.

    end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setDebugMode) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setDebugMode Procedure 
PROCEDURE setDebugMode :
/*------------------------------------------------------------------------------
  Purpose: Liga/Desliga o modo de debug    
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define input parameter isDebugMode_ as logical   no-undo. 

    do {&throws}:
        /*Mostra as breakLines*/
        run setShowBreakLines in simpleRectangle(isDebugMode_).
    end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setReferencePointTo) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setReferencePointTo Procedure 
PROCEDURE setReferencePointTo :
/*------------------------------------------------------------------------------
  Purpose: Quando um objeto vai ser desenhado usando outro de referencia, por padr∆o
           utiliza-se o inferior esquerdo para desenhar abaixo, o superior direito para 
           desenhar a direita, etc... Esta propriedade permite escolher outros pontos.     
  Parameters:  <none>
  Notes: Valores permitidos
            {&begin}      1 - Inicio                          
            {&beginMid}   2 - Entre o inicio e o meio         
            {&mid}        3 - Meio                            
            {&midEnd}     4 - entre o meio e o fim            
            {&End}        5 - fim                             
------------------------------------------------------------------------------*/
    define input parameter referencePoint_ as integer   no-undo. 

    do {&throws}:
        assign referencePoint = referencePoint_.
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

        /*Notifica os filhos*/
        run setUserProcedures in config(userProcedures).
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
    {system/inherit.i utils/pdf/Elements/File/PdfFile.p}
    
    do {&throws}:

        run super.

        /*Handle de configuraá∆o para as funá‰es de callback*/
        run createInstance in ghInstanceManager (this-procedure,
            'utils/pdf/Elements/Config/GeneralConfig.p':u, output config).
        
        /*Shapes e geometria em geral*/
        /*Cria um retangulo*/        
        run createInstance in ghInstanceManager (this-procedure,
            'utils/pdf/Elements/Shape/SimpleRectangle.p':u, output simpleRectangle).
        /*Controlador de texto*/
        run createInstance in ghInstanceManager (this-procedure,
            'utils/pdf/Elements/Shape/SimpleText.p':u, output simpleText).
        
        run initializeObjects.

        run setDebugMode(isDebugMode).

    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-tmpTest) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE tmpTest Procedure 
PROCEDURE tmpTest :
/*------------------------------------------------------------------------------
  Purpose: Esta procedure provavelemente ser† exclu°da.
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define input parameter myName   as character no-undo.
    define input parameter x as integer   no-undo. 
    define input parameter y as integer   no-undo. 
    define input parameter width  as integer   no-undo. 
    define input parameter height as integer   no-undo. 
    
    do {&throws}:
        
        if myname = ? or myname = '' then
            run getNextName(output myname).

        assign currentName = myname.


        /*Define o retangulo*/
        run setName in simpleRectangle(myName).
        run setMetrics in simpleRectangle(x,
                                          y,
                                          width,
                                          height).

        /*Reservado para chamar o UPC*/
        run callUpcDrawRectangle(simpleRectangle).

        /*Define as alteraá‰es feitas pela upc*/
        run getMetrics in simpleRectangle(output x,
                                          output y,
                                          output width,
                                          output height).
        /*Configura opá‰es de desenho*/
        run configureDraw in Config.

        /*Desenha o retangulo*/
        run draw        in simpleRectangle.

        /*Armazena as coordenadas do retangulo para uso posterior*/
        run saveRectangle(simpleRectangle).

        
    end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-validateErrors) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE validateErrors Procedure 
PROCEDURE validateErrors PRIVATE :
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

&IF DEFINED(EXCLUDE-validateMarginDownOverflow) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE validateMarginDownOverflow Procedure 
PROCEDURE validateMarginDownOverflow PRIVATE :
/*------------------------------------------------------------------------------
  Purpose: Verifica se a operaá∆o de desenho pode criar uma nova p†gina    
  Parameters:  <none>
  Notes: Se um objeto Ç desenhado abaixo de um outro que est† no limite inferior da pagina
         ir† avanáar para a p†gina seguinte quando ambos os objetos se encontram na 
         mesma p†gina. Sen∆o, vai apenas alinhar o novo objeto no topo da p†gina corrente.
------------------------------------------------------------------------------*/
    define variable pageConfig       as handle    no-undo.
    define variable currentPage      as integer   no-undo.

    do {&throws}:
        run getPageConfig in config(output pageConfig).
        run getPageNumber in pageConfig(output currentPage).

        /*Bloqueia o evento, que joga o objeto em uma p†gina seguinte.*/
        if ttcoordenadas.pag <> currentPage then
            run setSupressBottomMarginOverflow in simpleRectangle(true).
        else
            run setSupressBottomMarginOverflow in simpleRectangle(false).
    end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

