/* converte 'hh:mm:ss' ou hhmmss para segundos */

function fn-stot returns integer (input cTime as character):

    assign
        cTime = replace(cTime, ':', '').
        
    return (integer(substring(cTime, 1, 2)) * 3600 ) + 
           (if length(cTime) > 2 then (integer(substring(cTime, 3, 2)) * 60) else 0) +
           (if length(cTime) > 4 then integer(substring(cTime, 5, 2)) else 0).
end function.

