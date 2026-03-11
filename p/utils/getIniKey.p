/**
*
* PROGRAMA:
*   utils/getIniKey.p
*
* FINALIDADE:
*   Obtem o valor para a secao e chave informados. A busca sempre eh feita
*   no .ini da sessao. Se a secao/chave nao for encontrada, cria-a.
*
* VERSOES:
*   25/01/2005, Leandro Johann, Datasul Paranaense,
*     Criacao
*
*/
define input  parameter cSectionName as character  no-undo.
define input  parameter cKeyName     as character  no-undo.

define variable cKeyValue as character  no-undo.

get-key-value section cSectionName key cKeyName value cKeyValue.
if cKeyValue = '' or cKeyValue = ? then do:
    assign cKeyValue = 'notepad.exe'.
    put-key-value section cSectionName key cKeyName value cKeyValue no-error.
end.

return cKeyValue.
