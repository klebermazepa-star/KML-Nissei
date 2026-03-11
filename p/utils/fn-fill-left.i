/***
*
* PROGRAMA:
*   fn-fill-left.i
*
* FINALIDADE:
*   preenche caracteres a esquerda.
*
* VERSOES:
*   04/04/2005, Dalle Laste,
*   - criacao
*
*/
function fn-fill-left returns char (input c-text as char, input i-width as integer, 
                                    input c-fill as char).
    def var c-result as char    no-undo.

    assign c-result = fill(c-fill, i-width - length(c-text)) + c-text
           c-result = substr(c-result, length(c-result) - i-width + 1, i-width).

    return c-result.

end function.

