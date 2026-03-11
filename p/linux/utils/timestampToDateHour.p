
define input parameter timestamp as character no-undo. 
define output parameter data as date no-undo.
define output parameter hora as character  no-undo.

do {&throws}:
    assign
        data = (date(substring(timeStamp, 09, 2) + '/' +
                     substring(timeStamp, 06, 2) + '/' +
                     substring(timeStamp, 01, 4)))
        hora = substring(timeStamp, 12, 8).
end.

return.
