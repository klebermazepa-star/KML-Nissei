/***
*
* PROGRAMA:
*   utils/fnMonthName.i
*
* FINALIDADE:
*   retorna o nome do mes.
*
* NOTAS:
*   'aaa' = jan
*   'Aaa' = Jan
*   'AAA' = JAN
*   'aaaa' = janeiro
*   'a'    = j
*   ...
*
* VERSOES:
*   17/02/2006, Dalle Laste,
*   - criacao
*
*/

function fnMonthName returns char (input iMonth as integer, input cFormat as char).
    def var cResult as char no-undo.

    if iMonth >= 1 and iMonth <= 12 then do:
        if cFormat = '' then
            assign cFormat = 'a'.
        assign cResult = entry(iMonth, 
                               'janeiro,fevereiro,mar‡o,abril,maio,junho,julho,agosto,setembro,outubro,novembro,dezembro').
        if length(cFormat) < 4 then
            assign cResult = substring(cResult, 1, length(cFormat)).

        if asc(substring(cFormat, 1, 1)) <= 90 then do:
            if length(cFormat) > 1 and asc(substring(cFormat, 2, 1)) <= 90 then
                assign cResult = caps(cResult).
            else
                substring(cResult, 1, 1) = caps(substring(cResult, 1, 1)).
        end.
    end.

    return cResult.
end function.

