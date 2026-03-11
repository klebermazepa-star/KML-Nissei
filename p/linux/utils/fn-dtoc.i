/* converte data para formato (ex 'ddmmyyyy') */

function fn-dtoc returns char (data as date, formato as character).

    define variable cReturn as character no-undo.

    if data = ? then
        assign
            cReturn = fill(' ':u, length(formato)).
    else
        assign
            cReturn = formato
            cReturn = replace(cReturn, 'dd':u, 'd':u)
            cReturn = replace(cReturn, 'mm':u, 'm':u)
            cReturn = replace(cReturn, 'a':u, 'y':u)

            cReturn = replace(cReturn, 'd':u, string(day(data), '99':u))
            cReturn = replace(cReturn, 'm':u, string(month(data), '99':u))

            cReturn = replace(cReturn, 'yyyy':u, string(year(data), '9999':u))
            cReturn = replace(cReturn, 'yyy':u, substring(string(year(data), '9999':u), 2, 3))
            cReturn = replace(cReturn, 'yy':u, substring(string(year(data), '9999':u), 3, 2))
            cReturn = replace(cReturn, 'y':u, substring(string(year(data), '9999':u), 4, 1))
            .

    return cReturn.

end function.

/* message fn-dtoc(today, 'ddmmyy')       */
/*     view-as alert-box info buttons ok. */
