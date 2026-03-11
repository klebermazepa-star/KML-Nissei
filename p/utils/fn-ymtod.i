/* converte 'yyyymm' para data (dia 01)*/

function fn-ymtod returns date (input c-ano-mes as char).

    return date(int(substr(c-ano-mes, 5, 2)), 01, int(substr(c-ano-mes, 1, 4))).

end function.

