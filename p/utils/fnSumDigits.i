/*------------------------------------------------------------------------------
  Purpose:  reduz o numero a um digito, somando os digitos
------------------------------------------------------------------------------*/

function fnSumDigits returns integer (numero as integer) :
    define variable iCount as integer   no-undo.
    define variable iSum as integer   no-undo.

    do while numero >= 10:
        do iCount = 1 to length(string(numero)):
            assign
                iSum = iSum
                     + integer(substring(string(numero), iCount, 1)).
        end.
        assign
            numero = iSum
            iSum   = 0.
    end.

    return numero.

end function.

