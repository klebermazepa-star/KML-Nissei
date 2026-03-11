/***
*
* PROGRAMA:
*     utils/getLineEditorByKey.p
*
* FINALIDADE:
*   retorar o conteudo da linha cujo conteudo comece com key (sem a key)
*/

define input  parameter cText as character no-undo. 
define input  parameter cKey  as character   no-undo. 
define output parameter cLine as character no-undo. 

/* includes para utilizar pi-print-editor */
{include/tt-edit.i}
{include/pi-edit.i}

run pi-print-editor (cText, 2000).

for each tt-editor:
    if tt-editor.conteudo begins cKey then do:
        assign
            cLine = trim(substring(tt-editor.conteudo, length(cKey) + 1)).
        leave.
    end.
end.

return.
