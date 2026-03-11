/** 
* PROGRAMA
*   utils/ttErrosToRowErrors
*
* FINALIDADE
*   Converter erros da tt-erros (utapi's) para RowErrors dos DBOs
*
*/

{utils/ttErros.i}
{method/dbotterr.i}

define input parameter table for tt-erros.
define input-output parameter table for RowErrors.

define variable iSequencia as int init 1 no-undo.

function getErrorSubtype returns char
    (input iTipoMsg as integer) forward.


for last RowErrors:
    assign iSequencia = RowErrors.ErrorSequence + 1.
end.

for each tt-erros
    by rowid(tt-erros):
    
    create RowErrors.
    assign RowErrors.ErrorSequence     = iSequencia
           RowErrors.ErrorNumber       = tt-erros.cod-erro
           RowErrors.ErrorDescription  = tt-erros.desc-erro
           RowErrors.ErrorType         = "EMS"
           RowErrors.ErrorSubtype      = 'Erro'
           iSequencia                  = iSequencia + 1.

    for first cadast_msg no-lock
        where cadast_msg.cdn_msg = RowErrors.ErrorNumber:
        assign RowErrors.ErrorSubtype = getErrorSubtype(cadast_msg.idi_tip_msg).

        if index(cadast_msg.dsl_help_msg, '&':u) > 0 then
            assign RowErrors.ErrorHelp = RowErrors.ErrorDescription.
        else
            assign RowErrors.ErrorHelp = cadast_msg.dsl_help_msg.
    end.

    
    &if defined(debug) &then
        define variable cStack as char no-undo init "Stack Trace:~n".
        define variable i as int init 2.

        if last(rowid(tt-erros)) then do:
            do while program-name(i) <> ?:
                assign cStack = cStack + program-name(i) + chr(10)
                       i = i + 1.            
            end.
        
            find last RowErrors.    
            assign RowErrors.ErrorHelp = RowErrors.ErrorHelp + '~n~n' + cStack.                                     
        end.
    
    &endif

end.

function getErrorSubtype returns char
    (input iTipoMsg as integer):

    case iTipoMsg:
        when 1 then
            return "Erro".
        when 2 then
            return "Aviso".
        when 3 then
            return "Pergunta".
        when 4 then
            return "Informa‡Æo".
        otherwise
            return "".
    end case.
end function.
