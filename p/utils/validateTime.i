/***
*
* Valida uma string passada como parametro.
*
*/
function validateTime returns log (cTime as char):
    def var iSeg   as int no-undo.

    if index(cTime, ':') = 0 then do:
        assign cTime = string(cTime, '99:99:99') no-error.
        
        if error-status:error then
            return false.        
    end.

    if num-entries(cTime, ':':u) <> 3 then
        return false.

    assign iSeg = integer(entry(1, cTime, ':':u)) no-error.
    if error-status:error or iSeg < 0 or iSeg > 23 then
        return false.

    assign iSeg = integer(entry(2, cTime, ':':u)) no-error.
    if error-status:error or iSeg < 0 or iSeg > 59 then
        return false.

    assign iSeg = integer(entry(3, cTime, ':':u)) no-error.
    if error-status:error or iSeg < 0 or iSeg > 59 then
        return false.

    return true.
end function.

