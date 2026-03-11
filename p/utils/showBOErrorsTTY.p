/**
*
* PROGRAMA:
*   utils/showBOErrorsTTY.p
*
* FINALIDADE:
*   Mostra as mensagens de erro em modo TTY
*   Retorna OK se teve erro
*
*/

{method/dbotterr.i} /* RowErrors */

define input parameter table for RowErrors.

define variable cMensagens as character no-undo.

form
    " ** Mensagens/Erros **" at row 01 col 01 skip
    cMensagens view-as editor size 25 by 9
/*     scrollbar-vertical */
    with 1 down font 3 size 25 by 10 row 1 col 1
    no-label overlay no-box
    frame fLines.

on 'return':U OF cMensagens in frame fLines
do:
    apply "go".
end.

on 'end-error':U OF cMensagens in frame fLines
do:
    readkey pause 0.
    apply "go".
end.

/* Oooops... Abort here... */
if not can-find(first RowErrors) then
    return 'nok':u.

for each rowErrors:
    assign cMensagens = cMensagens 
                      + trim(string(rowErrors.errorNumber, '>>>>9')) + '-' 
                      + trim(rowErrors.errorDescription) 
                      + "~n".
end.
/* view frame fLines. */
assign cMensagens:read-only in frame fLines = yes.
update cMensagens with frame fLines.
hide frame fLines.
return 'ok':u.
