
function isExecuting returns logical(programName as character):
    
    define variable iCount as integer   no-undo initial 2.

    do while program-name(iCount) <> ?:
        if index(program-name(iCount), programName) > 0 then
            return true.

        assign
            iCount = iCount + 1.
    end.

    return false.
end.

