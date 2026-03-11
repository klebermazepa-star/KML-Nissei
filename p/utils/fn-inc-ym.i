/***
*
* PROGRAMA:
*   fn-Inc-ym.i
*
* FINALIDADE:
*   Incrementa i-meses meses no ano-mes (yyyymm) c-mes-ini
*
* VERSOES:
*   22/05/2005, Dalle Laste,
*   - criacao
*/

/* essas funcoes devem ser incluidas nos programas que usarem esta funcao */
/*{utils/fn-ymtod.i}*/
/*{utils/fn-dtoym.i}*/
/*{utils/fn-inc-month.i}*/

function fn-inc-ym returns char (input c-mes-ini as char, 
                                 input i-inc as integer).
    
    /* converte c-mes-ini para data, some os meses e converte para yyyymm */
    return fn-dtoym(fn-inc-month(fn-ymtod(c-mes-ini), i-inc)).

end function.

