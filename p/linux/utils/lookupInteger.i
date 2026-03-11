FUNCTION lookupInteger RETURNS INTEGER
  (element as integer, list as character) :
    define variable iCount as integer   no-undo.
    define variable listElement as integer   no-undo.

    do iCount = 1 to num-entries(list):

        assign
            listElement = integer(entry(iCount, list))
            no-error.

        if not error-status:error and
           listElement = element      then
            return iCount.
    end.

    return 0.

END FUNCTION.
