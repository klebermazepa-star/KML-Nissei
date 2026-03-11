/** 
* PROGRAMA
*   utils/ttErroToRowErrors
*
* FINALIDADE
*   Converter erros da tt-erro (cd0666) para RowErrors dos DBOs
*
* VERSOES
*   15/05/2006, Alexandre Reis, Datasul Paranaense
*/

{utils/ttErro.i}
{method/dbotterr.i}

define input parameter table for tt-erro.
define input-output parameter table for RowErrors.

define variable iSequencia as int init 1 no-undo.

function getErrorSubtype returns char
    (input iTipoMsg as integer) forward.


for last RowErrors:
    assign iSequencia = RowErrors.ErrorSequence + 1.
end.

for each tt-erro
    by tt-erro.i-sequen:
    
    create RowErrors.
    assign RowErrors.ErrorSequence     = iSequencia
           RowErrors.ErrorNumber       = tt-erro.cd-erro
           RowErrors.ErrorDescription  = tt-erro.mensagem
           RowErrors.ErrorType         = "EMS"
           RowErrors.ErrorSubtype      = 'Erro'
           iSequencia                  = iSequencia + 1.

    for first cad-msgs no-lock
        where cad-msgs.cd-msg = tt-erro.cd-erro:
        assign RowErrors.ErrorSubtype = getErrorSubtype(cad-msgs.tipo-msg).

        if index(cad-msgs.help-msg, '&':u) > 0 then
            assign RowErrors.ErrorHelp = tt-erro.mensagem.
        else
            assign RowErrors.ErrorHelp = cad-msgs.help-msg.
    end.

    
    &if defined(debug) &then
        define variable cStack as char no-undo init "Stack Trace:~n".
        define variable i as int init 2.

        if last(tt-erro.i-sequen) then do:
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
