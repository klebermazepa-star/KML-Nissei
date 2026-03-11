/***
*
* PROGRAMA:
*   fn-Last-Day.i
*
* FINALIDADE:
*   Retorna data ref ultimo dia de data.
*
* VERSOES:
*   31/03/2005, Dalle Laste,
*   - criacao
*
*/
function fn-Last-Day returns date (input d-ini as date).
    def var d-result as date no-undo.

    assign d-result = d-ini + 20 + (20 - day(d-ini))
           d-result = d-result - day(d-result).

    return d-result.

end function.

