/** 
* PROGRAMA
*   utils/ttBoErroToRowErrors.p
*
* FINALIDADE
*   Converter erros da tt-bo-erro para RowErrors
*/

{utils/ttBoErro.i}
{method/dbotterr.i}

define input parameter table for tt-bo-erro.
define input-output parameter table for RowErrors.

define variable iSequencia as int init 1 no-undo.

for each tt-bo-erro:
    create RowErrors.
    assign
        RowErrors.ErrorSequence     = tt-bo-erro.i-sequen
        RowErrors.ErrorNumber       = tt-bo-erro.cd-erro
        RowErrors.ErrorDescription  = tt-bo-erro.mensagem
        RowErrors.ErrorType         = tt-bo-erro.errorType
        RowErrors.ErrorSubtype      = tt-bo-erro.errorSubType
        RowErrors.ErrorHelp         = tt-bo-erro.errorHelp.
end.
