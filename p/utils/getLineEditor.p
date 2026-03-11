/***
*
* PROGRAMA:
*     utils/getLineEditor.p
*
* FINALIDADE:
*   retorar o conteudo da linha iLine do texto
* 
* NOTA:
*
*
* VERSOES:
*   22/06/2006, Leandro Dalle Laste
*/

define input  parameter cText as character no-undo. 
define input  parameter iLine as integer   no-undo. 
define output parameter cLine as character no-undo. 

define variable iCount as integer   no-undo.

/* includes para utilizar pi-print-editor */
{include/tt-edit.i}
{include/pi-edit.i}

run pi-print-editor (cText, 2000).

assign iCount = 1.

for each tt-editor:
    if iCount = iLine then do:
        assign cLine = tt-editor.conteudo.
        leave.
    end.
    assign iCount = iCount + 1.
end.

return.

