/***
*
* PROGRAMA:
*   fn-Inc-Month.i
*
* FINALIDADE:
*   Incrementa i-meses meses na data d-ini.
*
* VERSOES:
*   31/03/2005, Dalle Laste,
*   - criacao
*
*/

/* essas funcoes devem ser incluidas nos programas que usarem esta funcao */
/* {utils/fn-last-day.i} */

function fn-inc-month returns date (input d-ini as date, 
                                    input i-inc as integer).
    def var i-ano as integer no-undo.
    def var i-mes as integer no-undo.
    def var d-result as date no-undo.

    assign i-mes = month(d-ini) + i-inc.
    if i-inc >= 0 then
        assign i-ano = year(d-ini) + trunc(i-mes / 12, 0) - int(i-mes mod 12 = 0).
    else
        assign i-ano = year(d-ini) - trunc(abs(i-inc) / 12, 0) - int(abs(i-inc) mod 12 >= month(d-ini)).

    if i-mes < 0 then
        assign i-mes = int(i-mes mod 12) + (int(i-mes mod 12 = 0) * 12).
    else
        assign i-mes = month(d-ini) + (i-inc - ((trunc(i-mes / 12, 0) - int(i-mes mod 12 = 0)) * 12)).

    assign d-result = date(i-mes, 01, i-ano).

    if d-ini = fn-last-day(d-ini) or
       day(d-ini) > day(fn-last-day(d-result)) then
       /* se era o ultimo dia ou o dia era maior do que o ultimo do mes atual, usa o ultimo dia */
        assign d-result = fn-last-day(d-result).
    else
        /* usa o mesmo dia */
        assign d-result = date(month(d-result), day(d-ini), year(d-result)).

    return d-result.
end function.

