/*Exemplo de PdfFile*/

/*Include de constantes para o uso da classe.*/
{utils/pdf/inc/pdf.i}

{system/Error.i}
{system/InstanceManagerDef.i}
{system/InstanceManager.i}

define variable pdfFile    as handle no-undo.
define variable config     as handle no-undo.
define variable drawConfig as handle    no-undo.

do {&try}:

    run createInstance in ghInstanceManager (this-procedure,
     'utils/pdf/PdfDraw.p':u, output pdfFile).
 
    run setPath in pdfFile('C:\datasul\oework').
    run setFileName in pdfFile('_botton.pdf'). 
    run setKeyWords in pdfFile('haha').
    
    /*Utilizando as rotinas customizadas do usuario*/
    run setUserProcedures in pdfFile(this-procedure).
    run setDebugMode in pdfFile(false).

    run createPdf in pdfFile({&portrait}). 

    run getConfig in pdfFile(output config).
    run getDrawConfig in config(output drawConfig).

    run setLineColor in drawConfig('#ff0000').
     run tmpTest in pdfFile(?,0 , 0 , 30 , 30  ).
     
     run drawRectangleInDownOf in pdfFile('3',?,30,30).
     run drawRectangleInDownOf in pdfFile('4','3',50,50).
     run setLineColor in drawConfig('#00ff00').
     run drawRectangleInDownOf in pdfFile('5','4',60, 40).
     run drawRectangleInDownOf in pdfFile('6','5',70, ?).
     run setLineColor in drawConfig('#0000ff').
     run drawRectangleInDownOf in pdfFile('7','6',80, 70).
     run drawRectangleInDownOf in pdfFile('8','7',90, 60).
     run setLineColor in drawConfig('#ff0000').
     run drawRectangleInDownOf in pdfFile('3',?,30,30).
     run drawRectangleInDownOf in pdfFile('3',?,30,30).
     run drawRectangleInDownOf in pdfFile('3',?,30,30).
     run drawRectangleInDownOf in pdfFile('3',?,30,30).
     run drawRectangleInDownOf in pdfFile('3',?,30,30).
     run drawRectangleInDownOf in pdfFile('3',?,30,30).
     run drawRectangleInDownOf in pdfFile('3',?,30,30).
     run drawRectangleInDownOf in pdfFile('3',?,30,30).
     run drawRectangleInDownOf in pdfFile('3',?,30,30).
     run drawRectangleInDownOf in pdfFile('3',?,30,30).
     run drawRectangleInDownOf in pdfFile('3',?,30,30).
     run drawRectangleInDownOf in pdfFile('debug',?,30,60).
     run setLineColor in drawConfig('#000000').
     run drawRectangleInDownOf in pdfFile('debug',?,30,30).
     run setLineColor in drawConfig('#0000FF').
     run drawRectangleInDownOf in pdfFile('debug',?,30,30).
     run setLineColor in drawConfig('#00FF00').
     run drawRectangleInDownOf in pdfFile('3',?,30,30).
     run setLineColor in drawConfig('#000000').
     run drawRectangleInDownOf in pdfFile('3',?,30,30).
     run setLineColor in drawConfig('#0000FF').
     run drawRectangleInDownOf in pdfFile('3',?,30,30).
    

/*                                                           

     run tmpTest in pdfFile(?,35 , 60 , 30 , 20  ).
     run tmpTest in pdfFile(?,60  ,150 , 50, 50  ).
     run tmpTest in pdfFile(?,90  ,190 , 60, 40  ).
     run tmpTest in pdfFile(?,125 , 230 , 70, 40 ).
     run tmpTest in pdfFile(?,165 , 270 , 80, 40 ).
 */

    run finalizePdf in pdfFile.

    /*Arquivo finalizado*/

end.

run showErrors.

run deleteInstance in ghInstanceManager(this-procedure:handle).
    
/*Procedures de callback*/
procedure upcDrawRectangle:
    define input parameter  primitive       as handle    no-undo.
    define input parameter  simpleRectangle as handle    no-undo.
    define input parameter  drawConfig      as handle    no-undo.
    define input parameter  name            as char      no-undo.

    define variable x as integer   no-undo.
    define variable y as integer   no-undo.
    define variable w as integer   no-undo.
    define variable h as integer   no-undo.

    
    message 'chamou upcDrawRectangle' name.
    
end procedure.

procedure upcBeforeCreateNewPage:
    define input parameter  primitive       as handle    no-undo.
    define input parameter  pageConfig      as handle    no-undo.
    define input parameter  pageNum         as integer   no-undo.

    message 'Chamou a upc para criar nova pagina:' pageNum .

end procedure.

procedure upcBottomMarginOverflow:
    define input parameter  primitive       as handle    no-undo.
    define input parameter  pageConfig      as handle    no-undo.
    define input parameter  simpleRectangle as handle    no-undo.
    define input parameter  blameName       as character no-undo.

    message 'Chamou a UpcBottomMarginOverflow:' blameName .
    
    

end procedure.

procedure upcInitialConfig:
    define input parameter  pageConfig as handle    no-undo.
    define input parameter  drawConfig as handle    no-undo.
    define input parameter  textConfig as handle    no-undo.

    message 'Chamou a UpcInitialConfig:' .
    
    

end procedure.

