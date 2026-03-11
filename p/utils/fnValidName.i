/* 
    Retira caracteres invalidos do nome
*/

function fnValidName returns char (input cName as char).

    def var cInvalids as char no-undo init '*/\?[]'.
    def var iAux as integer no-undo.

    do iAux = 1 to length(cInvalids):
        assign cName = replace(cName, substring(cInvalids, iAux, 1), '').
    end.

    return cName.

end function.

