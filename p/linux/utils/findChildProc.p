/***
*
* PROGRAMA:
*   utils/findChildProc.p
*
* FINALIDADE:
*   Encontra e retorna as procedures filhas de um determinado container. Essa
*   eh util, por exemplo, para encontrar os handles das procedures de uma
*   viewer ou de uma query.
*
* VERSOES:
*   19/07/2004, Leandro Johann e Alexandre Reis, Datasul Parana,
*     Criacao
*
*/

def input  param hContainer as handle no-undo.
def input  param cChildProc as char   no-undo.
def output param hChildProc as handle no-undo.

def var hProcedure as handle no-undo.

/* Se o handle do container nao for valido, simplesmente retorna.
   Dessa forma o handle retornado em hChildProc sera invalido */
if not valid-handle(hContainer) then
    return.

assign hProcedure = hContainer:next-sibling.
do while valid-handle(hProcedure):
    if index(hProcedure:file-name, cChildProc) > 0 and
       hProcedure:current-window = hContainer:current-window then
        leave.

    assign hProcedure = hProcedure:next-sibling.
end.

if valid-handle(hProcedure) then
    assign hChildProc = hProcedure.
