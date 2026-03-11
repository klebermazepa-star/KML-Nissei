/***
*
* PROGRAMA:
*   utils/fn-inc-char.i
*
* FINALIDADE:
*   incrementa char, usando 0..9 e A..Z
*
* NOTA: apesar do parametro inc, o incremento por eqto eh sempre de 1
*/

function fn-inc-char returns char (source as character,
                                   inc as integer,
                                   maxLength as integer).
    define variable result as character no-undo.
    define variable toInc as character no-undo.
    define variable charToInc as character no-undo.

    if source = '':u then
        return 'A':u.

    assign
        result = substring(source, 1, maxLength)
        toInc = substring(result, length(result))
        charToInc = toInc.

    if toInc = 'Z':u and length(result) < maxLength then
        return result + 'A'.

    do while true:

        if charToInc = 'Z':u then do:

            if length(result) = length(toInc) then
                return error 'Nao foi possivel incrementar ' + source.

            assign
                toInc = substring(result, length(result) - length(toInc), 1)
                      + 'A'
                charToInc = substring(toInc, 1, 1).
        end.
        else do:
            if charToInc = '9':u then
                assign
                    charToInc = 'A'.
            else
                assign
                    charToInc = chr(asc(charToInc) + 1).
    
            assign
                substring(toInc, 1, 1) = charToInc
                substring(result, length(result) - length(toInc) + 1) = toInc.

            leave.
        end.
    end.

    return result.

end function.

/* message fn-inc-char('1y', 1, 2) fn-inc-char('1z', 1, 2) */
/*     view-as alert-box info buttons ok.                  */
