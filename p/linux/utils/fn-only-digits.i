/***
*
* PROGRAMA:
*   fn-only-digits.i
*
* FINALIDADE:
*   Retorna char com apenas os digitos (12.123.354/0001-23 -> 12123354000123).
*
* VERSOES:
*   04/04/2005, Dalle Laste,
*   - criacao
*
*/

&if defined(FN-ONLY-DIGITS) = 0 &then
function fn-only-digits returns char (input c-param as char).
    def var c-result as char    no-undo.
    def var i        as integer no-undo.

    do i = 1 to length(c-param):
        if substr(c-param, i, 1) >= '0' and
           substr(c-param, i, 1) <= '9'     then
            assign c-result = c-result + substr(c-param, i, 1).
    end.

    return c-result.

end function.

&global-define FN-ONLY-DIGITS

&endif

