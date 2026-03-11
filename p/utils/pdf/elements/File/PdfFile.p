&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v9r12
&ANALYZE-RESUME
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Procedure 
/**
* CLASSE:
*   utils/pdf/PdfFile
*
*AUTOR:
*   Gilberto Griesbach Jr.
* FINALIDADE:
*   Encapsular as operaá‰es e propriedades referentes a um arquivo PDF
* NOTAS:
*   Esta classe dever† abrir e fechar arquivos PDF, porem, n∆o deve poder 
*   desenhar ou inserir informaá‰es no PDF alÇm das requeridas pelo sistema
*   ou pelo reader.
*
*   Todas as propriedades devem conter valores padr∆o que sejam funcionais.
*   
*/

/*Constantes de pdf*/
{utils/pdf/inc/pdf.i}

{system/Error.i}
{system/InstanceManagerDef.i}

/* Include para o tratamento de PDF ----------------------*/
{PDFinclude/pdf_inc.i "THIS-PROCEDURE"}


/* Criando canal de saida para o arquivo PDF -------------*/
def stream PDF.

/*Informaá‰es do arquivo*/
define variable pdfFileName as character initial 'noname.pdf'         no-undo.
define variable pdfPath     as character initial 'c:/datasul/oework/' no-undo.
define variable pdfStream   as character initial 'Spdf'               no-undo.

/* Informaá‰es do documento */ 
define variable pdfAuthor   as character initial "DATASUL"               no-undo.
define variable pdfSubject  as character initial "DATASUL"               no-undo.
define variable pdfTitle    as character initial "DATASUL"               no-undo.
define variable pdfKeywords as character initial "DATASUL"               no-undo.
define variable pdfCreator  as character initial "PDFinclude V2"         no-undo.
define variable pdfProducer as character initial "DATASUL - ESPECIFICOS" no-undo.

define variable uniqueId    as character   no-undo.

/*Controle da classe*/
define variable Initialized  as logical  initial false  no-undo.
define variable hasErrors    as logical no-undo.

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
         HEIGHT             = 19.21
         WIDTH              = 39.43.
/* END WINDOW DEFINITION */
                                                                        */
&ANALYZE-RESUME

 


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Procedure 


/* ***************************  Main Block  *************************** */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&IF DEFINED(EXCLUDE-createNewPage) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE createNewPage Procedure 
PROCEDURE createNewPage :
/*------------------------------------------------------------------------------
  Purpose: Cria uma nova p†gina. Este mÇtodo ser† especializado em PdfDraw
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define input parameter pageOrientation as integer   no-undo. 

    do {&throws}:
        if pageOrientation = {&landscape} then
            run pdf_new_page2(pdfStream,'landscape').
        else
            run pdf_new_page2(pdfStream,'portrait'). 
    end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-createPdf) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE createPdf Procedure 
PROCEDURE createPdf :
/*------------------------------------------------------------------------------
  Purpose:  Inicializa a engine do pdfInclude  com os valores setados    
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define input parameter pageOrientation as integer no-undo. 
    do {&throws}:

        run pdf_new    (pdfStream, pdfPath + pdfFileName).
        
    /* Set Document Information */ 
        RUN pdf_set_info(pdfStream,"Author"  , pdfAuthor).
        RUN pdf_set_info(pdfStream,"Subject" , pdfSubject).
        RUN pdf_set_info(pdfStream,"Title"   , pdfTitle).
        RUN pdf_set_info(pdfStream,"Keywords", pdfKeywords).
        RUN pdf_set_info(pdfStream,"Creator" , pdfCreator).
        RUN pdf_set_info(pdfStream,"Producer", pdfProducer).

        run createNewPage in child()(pageOrientation).
        
        assign Initialized = true.
    end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-createUniqueId) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE createUniqueId Procedure 
PROCEDURE createUniqueId PRIVATE :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
   
    assign uniqueId = "Spdf" 
                      + string(year(today))
                      + string(month(today))
                      + string(day(today))
                      + substring(string(time,"HH:MM:SS"),1,2)
                      + substring(string(time,"HH:MM:SS"),4,2)
                      + substring(string(time,"HH:MM:SS"),7,2)
                      + string(random(1,99999)).
    
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

&IF DEFINED(EXCLUDE-finalizePdf) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE finalizePdf Procedure 
PROCEDURE finalizePdf :
/*------------------------------------------------------------------------------
  Purpose: Fecha o Arquivo     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    do {&throws}:
        run pdf_close(pdfStream).
        assign initialized = false.
    end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getAuthor) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getAuthor Procedure 
PROCEDURE getAuthor :
/*------------------------------------------------------------------------------
  Purpose: Recuperar o nome do autor do documento.    
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define output parameter pdfAuthor_ as character no-undo.

    do {&throws}:
        assign pdfAuthor_ = pdfAuthor.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getFileName) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getFileName Procedure 
PROCEDURE getFileName :
/*------------------------------------------------------------------------------
  Purpose: Recuperar o nome do arquivo.    
  Parameters:  <none>
  Notes: Nome do arquivo sem o path. Ex. teste.pdf      
------------------------------------------------------------------------------*/
    define output parameter pdfFileName_ as character no-undo.

    do {&throws}:
        assign pdfFileName_ = pdfFileName.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getKeywords) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getKeywords Procedure 
PROCEDURE getKeywords :
/*------------------------------------------------------------------------------
  Purpose: Recuperar as palavras chave do documento.    
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define output parameter pdfKeywords_ as character no-undo.

    do {&throws}:
        assign pdfKeywords_ = pdfKeywords.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getPath) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getPath Procedure 
PROCEDURE getPath :
/*------------------------------------------------------------------------------
  Purpose: Recuperar o caminho para o arquivo.    
  Parameters:  <none>
  Notes: Path do arquivo sem o nome, sempre com a barra no final. Ex. c:/temp/testepdf/      
------------------------------------------------------------------------------*/
    define output parameter pdfPath_ as character no-undo.

    do {&throws}:
        assign pdfPath_ = pdfPath.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getPdfStream) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getPdfStream Procedure 
PROCEDURE getPdfStream :
/*------------------------------------------------------------------------------
  Purpose: Recuperar o nome da stream utilizada para enviar dados ao pdf.    
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define output parameter pdfStream_ as character no-undo.

    do {&throws}:
        assign pdfStream_ = pdfStream.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getPrimitive) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getPrimitive Procedure 
PROCEDURE getPrimitive :
/*------------------------------------------------------------------------------
  Purpose: retorna o primitivo para todos os outros elementos    
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define output parameter primitive_ as handle no-undo.

    do {&throws}:
        assign primitive_ = this-procedure.
    end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getSubject) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getSubject Procedure 
PROCEDURE getSubject :
/*------------------------------------------------------------------------------
  Purpose: Recuperar o nome do Assunto do documento.    
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define output parameter pdfSubject_ as character no-undo.

    do {&throws}:
        assign pdfSubject_ = pdfSubject.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getTitle) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getTitle Procedure 
PROCEDURE getTitle :
/*------------------------------------------------------------------------------
  Purpose: Recuperar o titulo do documento.    
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define output parameter pdfTitle_ as character no-undo.

    do {&throws}:
        assign pdfTitle_ = pdfTitle.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-isInitialized) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE isInitialized Procedure 
PROCEDURE isInitialized :
/*------------------------------------------------------------------------------
  Purpose: Retorna o estado do arquivo (inicialido/criado) ou ainda n∆o.    
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define output parameter Initialized_ as logical   no-undo. 

    do {&throws}:
        assign Initialized_ = Initialized.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-loadTemplate) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE loadTemplate Procedure 
PROCEDURE loadTemplate :
/*------------------------------------------------------------------------------
  Purpose: Abrir para ediá∆o um PDF previamente gravado ou template.    
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define input parameter nomePdf as character no-undo. 
    do {&throws}:
        
    end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-preparePath) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE preparePath Procedure 
PROCEDURE preparePath PRIVATE :
/*------------------------------------------------------------------------------
  Purpose: Garantir que o path ter† a barra no final, e que seja um diretorio
           Existente.     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    do {&throws}:

        assign pdfPath = REPLACE(pdfPath,'\','/').

        if substr(pdfPath,length(pdfPath),1) <> '/'  then
            assign pdfPath = pdfPath + '/'.

        file-info:file-name = pdfPath.

        if file-info:file-type = ? or substr(file-info:file-type,1,1) <> 'D' then do:
            os-create-dir value(pdfPath).

            /*Verifica se conseguiu criar*/
            file-info:file-name = pdfPath.

            if file-info:file-type = ? or substr(file-info:file-type,1,1) <> 'D' then
                run createError(17006, substitute('N∆o foi poss°vel criar o diret¢rio: "&1"',pdfPath)).
            
        end.

    end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setAuthor) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setAuthor Procedure 
PROCEDURE setAuthor :
/*------------------------------------------------------------------------------
  Purpose: Definir o nome do autor do documento.    
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define input parameter pdfAuthor_ as character no-undo.

    do {&throws}:
        assign pdfAuthor = pdfAuthor_.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setFileName) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setFileName Procedure 
PROCEDURE setFileName :
/*------------------------------------------------------------------------------
  Purpose: Definir o nome do arquivo.    
  Parameters:  <none>
  Notes: Nome do arquivo sem o path. Ex. teste.pdf   
         O nome do arquivo n∆o pode ser alterado ap¢s um create ou load.   
------------------------------------------------------------------------------*/
    define input parameter pdfFileName_ as character no-undo.

    do {&throws}:

        if pdfFileName = pdfFileName_ then
            return.

        if not Initialized then do:
            run validateFileName(input pdfFileName_).

            assign pdfFileName = pdfFileName_.
        end.
        else
            run createError(17006, substitute('Imposs°vel definir o nome de arquivo com o arquivo em uso.: "&1"', pdfFileName_)).

        run validateErrors.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setKeywords) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setKeywords Procedure 
PROCEDURE setKeywords :
/*------------------------------------------------------------------------------
  Purpose: Definir as palavras chave do documento.    
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define input parameter pdfKeywords_ as character no-undo.

    do {&throws}:
        assign pdfKeywords = pdfKeywords_.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setPath) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setPath Procedure 
PROCEDURE setPath :
/*------------------------------------------------------------------------------
  Purpose: Definir o caminho para o arquivo.    
  Parameters:  <none>
  Notes: Path do arquivo sem o nome, sempre com a barra no final. Ex. c:/temp/testepdf/   
         n∆o pode ser alterado ap¢s create ou load   
------------------------------------------------------------------------------*/
    define input parameter pdfPath_ as character no-undo.

    do {&throws}:

        if pdfPath = pdfPath_ then
            return.

        if not Initialized then do:
            run validatePath(input pdfPath_).
            assign pdfPath = pdfPath_.
            run preparePath.
        end.
        else
            run createError(17006, substitute('Imposs°vel definir o diret¢rio com o arquivo em uso.: "&1"', pdfPath_)).
        
        run validateErrors.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setPdfStream) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setPdfStream Procedure 
PROCEDURE setPdfStream :
/*------------------------------------------------------------------------------
  Purpose: Definir o nome da stream utilizada para enviar dados ao pdf.    
  Parameters:  <none>
  Notes: N∆o pode ser alterado ap¢s um create ou load      
------------------------------------------------------------------------------*/
    define input parameter pdfStream_ as character no-undo.

    do {&throws}:

        if pdfStream = pdfStream_ then
            return.

        if not Initialized then do:
            assign pdfStream = pdfStream_.
        end.
        else
            run createError(17006, substitute('Imposs°vel definir a stream com o arquivo em uso.: "&1"', pdfStream_)).

        run validateErrors.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setSubject) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setSubject Procedure 
PROCEDURE setSubject :
/*------------------------------------------------------------------------------
  Purpose: Definir o nome do Assunto do documento.    
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define input parameter pdfSubject_ as character no-undo.

    do {&throws}:
        assign pdfSubject = pdfSubject_.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setTitle) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setTitle Procedure 
PROCEDURE setTitle :
/*------------------------------------------------------------------------------
  Purpose: Definir o titulo do documento.    
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define input parameter pdfTitle_ as character no-undo.

    do {&throws}:
        assign pdfTitle = pdfTitle_.
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
    
    do {&throws}:
        run setPath(session:temp-directory).

        run createUniqueId.
        run setPdfStream(uniqueId).
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

&IF DEFINED(EXCLUDE-validateFileName) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE validateFileName Procedure 
PROCEDURE validateFileName PRIVATE :
/*------------------------------------------------------------------------------
  Purpose: Verificar se um nome de arquivo Ç v†lido     
  Parameters:  <none>
  Notes: Um arquivo n∆o pode conter caracteres reservados, como * ,  etc...
         Um arquivo deve ter pelo menos UM digito.      
------------------------------------------------------------------------------*/
    define input parameter NomeArq as character no-undo. 

    define variable digito as integer no-undo.

    do {&throws}:
        if length(NomeArq) = 0  then 
            run createError(17006, substitute('Nome de arquivo inv†lido: "&1"',NomeArq)).

        do digito = 1 to length(NomeArq):
            if lookup(substr(NomeArq,digito,1), '*,/,\,",~',:,~r,~n,?') > 0 then
                run createError(17006, substitute('Nome de arquivo inv†lido: "&1"',NomeArq)).
        end.

        run validateErrors.
    end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-validatePath) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE validatePath Procedure 
PROCEDURE validatePath :
/*------------------------------------------------------------------------------
  Purpose: Verificar se um diret¢rio Ç v†lido     
  Parameters:  <none>
  Notes: Um diret¢rio n∆o pode conter caracteres reservados, como * ,  etc...
         Um diret¢rio deve ter pelo menos UM digito.      
------------------------------------------------------------------------------*/
    define input parameter NomePasta as character no-undo. 

    define variable digito as integer no-undo.

    do {&throws}:
        if length(NomePasta) = 0  then 
            run createError(17006, substitute('Caminho de arquivo inv†lido: "&1"',NomePasta)).

        do digito = 1 to length(NomePasta):
            if lookup(substr(NomePasta,digito,1), '*,",~',~r,~n') > 0 then
                run createError(17006, substitute('Caminho de arquivo inv†lido: "&1"',NomePasta)).
        end.
        
    end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

