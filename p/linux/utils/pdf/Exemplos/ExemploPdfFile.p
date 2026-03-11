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

    run createPdf in pdfFile({&portrait}). 

    run getConfig in pdfFile(output config).
    run getDrawConfig in config(output drawConfig).

    /*Objetos respeitam a margem (Nunca saindo da p gina)*/
    /*Desenha arbitr riamente sem callback*/
    run setCursorXY in pdfFile(0,0).
    run drawRectangle in pdfFile('primeiro', 50,50).
    
    run setCursorXY in pdfFile(10000,10000).
    run drawRectangle in pdfFile(?,50,50).

    run setLineColor in drawConfig('#FF0000').

    run setCursorXY in pdfFile(10000,0).
    run drawRectangle in pdfFile(?,50,50).

    run setLineStyle in drawConfig({&dash}).
    run setCursorXY in pdfFile(0,10000).
    run drawRectangle in pdfFile('ultimo',50,50). 

    /*Utilizando as rotinas customizadas do usuario*/
    run setUserProcedures in pdfFile(this-procedure).

    run createNewPage in PdfFile({&portrait}).

    /*Repare que estou passando todos nas mesmas coordenadas*/
    run setCursorXY in pdfFile(140,140).
    run drawRectangle in pdfFile('cb1',50,50). 
    run drawRectangle in pdfFile('cb2',50,50). 
    run drawRectangle in pdfFile('cb3',50,50). 

    /*Agora o metodo simples de fazer layouts... Lembra do primeiro retangulo?*/
    run drawRectangeInRightOf in pdfFile('Segundo','Primeiro',100,?).

    run finalizePdf in pdfFile.

    /*Arquivo finalizado*/


    
end.

run showErrors.



run deleteInstance in ghInstanceManager(this-procedure:handle).
    
/*Procedure de callback inutil*/
procedure upcDrawRectangle:
    define input parameter  primitive       as handle    no-undo.
    define input parameter  simpleRectangle as handle    no-undo.
    define input parameter  drawConfig      as handle    no-undo.
    define input parameter  name            as char      no-undo.

    define variable x as integer   no-undo.
    define variable y as integer   no-undo.
    define variable w as integer   no-undo.
    define variable h as integer   no-undo.

    

    if name = 'segundo' then
        run setLineColor in drawConfig('#0000FF'). 
    else do:
        run setLineColor in drawConfig('#00FFFF'). 
        run getMetrics in simpleRectangle(output x,
                                          output y,
                                          output w,
                                          output h).

        assign x = x + random(1,20)
               y = y + 5.

        run setMetrics in simpleRectangle(x, 
                                          y, 
                                          w, 
                                          h). 

        message name view-as alert-box info buttons ok.


    end.
end procedure.

procedure upcBeforeCreateNewPage:
    define input parameter  primitive       as handle    no-undo.
    define input parameter  pageConfig      as handle    no-undo.
    define input parameter  pageNum         as integer   no-undo.

    message 'Chamou a upc para criar nova pagina:' pageNum view-as alert-box info buttons ok.

end procedure.

procedure UpcBottomMarginOverflow:
    define input parameter  primitive       as handle    no-undo.
    define input parameter  pageConfig      as handle    no-undo.
    define input parameter  simpleRectangle as handle    no-undo.
    define input parameter  blameName       as character no-undo.

    message 'Chamou a UpcBottomMarginOverflow:' blameName view-as alert-box info buttons ok.

end procedure.

