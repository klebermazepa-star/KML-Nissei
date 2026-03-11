/***
*
* PROGRAMA:
*   fnNumMeses.i
*
* FINALIDADE:
*   Retorna numero de meses entre duas datas.
*
* VERSOES:
*   18/12/2006, Dalle Laste,
*   - criacao
*
*/

/* essas funcoes devem ser incluidas nos programas que usarem esta funcao */
/* {utils/fn-first-day.i} */

function fnNumMeses returns integer (input dIni as date, dFim as date).

    define variable dAux as date      no-undo.
    define variable iResult as integer   no-undo.

    assign
        dAux = fn-first-day(minimum(dIni, dFim))
        dFim = fn-first-day(maximum(dIni, dFim)).

    do while dAux < dFim:
        assign
            iResult = iResult + 1
            dAux    = fn-first-day(dAux + 40).
    end.

    return iResult.
end function.

