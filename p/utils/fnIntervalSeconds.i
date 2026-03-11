/* fnIntervalSeconds.i : retorna o numero de segundos entre 
   time inicial e final
*/

function fnIntervalSeconds returns integer 
    (tIni as integer, tFin as integer):

    def var iReturn as integer no-undo.


    if tIni <= tFin then
        assign iReturn = tFin - tIni.
    else
        assign iReturn = (24 * 3600) - tIni + /* horas antes da meia-noite */
                         tFin.
    return iReturn.

end.

