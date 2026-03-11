/***
*
* FINALIDADE:
*   retornar char sem espacos duplicados.
*
* NOTAS:
*
* VERSOES:
*   05/08/2005, Leansro Dalle Laste,
*   - criacao
*
*/

function fn-one-space returns char (input c-text as char).

    do while index(c-text, '  ') > 0 :
        assign c-text = replace(c-text, '  ', ' ').
    end.

    return c-text.
end function.

