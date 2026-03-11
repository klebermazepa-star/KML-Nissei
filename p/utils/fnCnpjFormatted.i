
function fnCnpjFormatted returns character (cnpj as character):

    if not avail param-global then
        find first param-global
        no-lock no-error.

    if avail param-global and param-global.formato-id-federal <> '':u then
        assign
            cnpj = string(cnpj, param-global.formato-id-federal).

    return cnpj.

end function.
