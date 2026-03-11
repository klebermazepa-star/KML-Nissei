/* converte 'yyyymmdd' para data */

function fn-stod returns date (input c-data as char).

    if trim(c-data) = '' or c-data = fill('0', 8) then
        return ?.

    return date(substring(c-data, 7, 2) + '/' +
                substring(c-data, 5, 2) + '/' +
                substring(c-data, 1, 4)        ).

end function.

