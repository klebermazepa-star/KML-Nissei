/***
*
* Valida uma string passada como parametro. 24:00 eh valida
*
*/
function validateHour returns log (cTime as char):
    def var iHor   as int no-undo.
    def var iMin   as int no-undo.

    if index(cTime, ':') = 0 then do:
        assign cTime = string(cTime, '99:99') no-error.
        
        if error-status:error then
            return false.        
    end.

    if num-entries(cTime, ':':u) <> 2 then
        return false.

    assign
        iHor = integer(entry(1, cTime, ':':u))
        iMin = integer(entry(2, cTime, ':':u))
        no-error.

    if error-status:error or 
       iHor < 0  or iMin < 0  or
       iHor > 24 or iMin > 59 or
       (iHor = 24 and iMin > 0) then
        return false.

    return true.
end function.

