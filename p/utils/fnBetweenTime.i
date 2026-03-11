/*
    fnBetweenTime.i : retorna true se o iTime estiver entre tIni e tFin
*/

function fnBetweenTime returns logical 
    (iTime as integer, tIni as integer, tFin as integer):

    if tFin > tIni then
        return (iTime >= tIni and iTime < tFin).
    else
        return fnBetweenTime(iTime, tIni, (24 * 3600) + 1) or
               fnBetweenTime(iTime, 0, tFin).
end.

