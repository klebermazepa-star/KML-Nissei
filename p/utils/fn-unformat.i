/***
*
* PROGRAMA:
*   fn-unformat.i
*
* FINALIDADE:
*   Retorna char com apenas os digitos e letras.
*
*/

function fn-unformat returns char (input c-param as char).
    def var c-result as char    no-undo.
    def var i        as integer no-undo.

    do i = 1 to length(c-param):
        if (substr(c-param, i, 1) >= '0' and
            substr(c-param, i, 1) <= '9'    ) or
           (substr(c-param, i, 1) >= 'a' and
            substr(c-param, i, 1) <= 'z'    )    then
            assign c-result = c-result + substr(c-param, i, 1).
    end.

    return c-result.

end function.

