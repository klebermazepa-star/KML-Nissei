/***
*
* PROGRAMA:
*   fn-first-day.i
*
* FINALIDADE:
*   Retorna data ref primeiro dia do mes de data.
*
* VERSOES:
*   12/2005, Dalle Laste,
*   - criacao
*
*/
function fn-first-day returns date (input d-base as date).

    return d-base - day(d-base) + 1.

end function.

