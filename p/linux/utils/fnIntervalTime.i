/* fnIntervalTime.i : retorna o numero de segundos entre 
   data/time inicial e final
*/

function fnIntervalTime returns integer 
    (dIni as date, tIni as integer,
     dFin as date, tFin as integer):

    def var iAux as integer no-undo.
    def var iReturn as integer no-undo.

    if dIni = dFin then do:
        if tFin > tIni then
            assign iReturn = tFin - tIni.
        else
        if tFin < tIni then
            assign iReturn = fnIntervalTime(dIni, tIni, dFin + 1, tFin).
    end.
    else do:
        assign iReturn = (24 * 3600) - tIni. /* horas do 1o dia */

        do iAux = 1 to dFin - dIni - 1 :
            /* dias cheios */
            assign iReturn = iReturn + (24 * 3600).
        end.
    
        assign iReturn = iReturn + tFin. /* horas do ultimo dia */
    end.

    return iReturn.

end.

