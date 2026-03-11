/**
*
* PROGRAMA:
* utils/showBOErrors.p
*
* FINALIDADE:
*   Mostra as mensagens de erro (ShowMessage) 
*   Retorna OK se teve erro
*
* Leandro Dalle Laste, Datasul Paranaense
*
* $Id$
*
*/

{method/dbotterr.i} /* RowErrors */

def input param table for RowErrors.

def var hShowMsg as widget-handle no-undo.

if can-find(first RowErrors) then do:

    {method/ShowMessage.i1}

    {method/ShowMessage.i2 &Modal="YES"}

    {method/ShowMessage.i3}

    return 'ok':u.
end.

return 'nok':u.

