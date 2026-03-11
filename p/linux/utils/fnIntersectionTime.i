/* calcula o tempo, entre tIni e tFin, que pertence ao intervalo tIntI/tIntF, ou seja,
   o tempo que pertence aos dois intervalos (Intersecao)
   OBS.: parametros em segundos (hora * 3600)
   
   Ex.: 22:00, 02:00, 01:00, 03:00 = 01:00
        22:00, 02:00, 20:00, 23:00 = 01:00
        22:00, 02:00, 21:00, 01:00 = 03:00
*/

function fnIntersectionTime returns integer (tIntI as integer, tIntF as integer,
                                             tIni as integer, tFin as integer).

    def var iReturn as integer no-undo.

    if tIntI > tIntF then
        assign iReturn = fnIntersectionTime(tIntI, 24 * 3600, tIni, tFin) +
                         fnIntersectionTime(0,       tIntF,   tIni, tFin).
    else
    if tIni > tFin then
        assign iReturn = fnIntersectionTime(tIntI, tIntF, tIni, 24 * 3600) +
                         fnIntersectionTime(tIntI, tIntF, 0,    tFin).
    else
        assign iReturn = max(min(tIntF, tFin) - max(tIntI, tIni), 0).

    return iReturn.
end.

