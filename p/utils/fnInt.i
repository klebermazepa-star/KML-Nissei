function fnInt returns integer (cValue as char).
    def var iResult as integer no-undo.

    assign iResult = int(cValue)
        no-error.

    return iResult.
end function.
