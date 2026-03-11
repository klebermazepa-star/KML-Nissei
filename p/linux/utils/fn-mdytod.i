/* converte 'mmddyyyy' para data */

function fn-mdytod returns date (input c-data as char).

    define variable dResult as date      no-undo init ?.

    if trim(c-data) <> '' and c-data <> fill('0', 8) then
        assign dResult = date(substring(c-data, 3, 2) + '/' +
                              substring(c-data, 1, 2) + '/' +
                              substring(c-data, 5, 4)        )
            no-error.

    if error-status:error then
        return error.

    return dResult.

end function.
