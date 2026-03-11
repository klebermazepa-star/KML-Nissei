/* utils/fn-excel-format.i

   converte format padrao PROGRESS para
   formto excel
*/

function fn-excel-format returns character (input cFormat as character).

    define variable cReturn as character no-undo.

    if index(cFormat, '/') > 0 then do:

        if num-entries(cFormat, '/') > 2 then
            assign cReturn = 'dd/mm/aaaa'.
        else
        if cFormat = '99/99':u or cFormat = '9999/99':u or 
           cFormat = '99/9999':u then
            assign cReturn = replace(replace(cFormat, '9', '0'), '/', '"/"').
        else
            assign cReturn = '':u. /* logico */
    end.
    else
    if index(cFormat, ':') > 0 then do:
        assign cReturn = 'hh:mm':u.
        if num-entries(':', cFormat) > 1 then
            assign cReturn = cReturn + ':ss':u.
    end.
    else
    if index(cFormat, 'x':u) > 0 then
        assign cReturn = '@'.
    else
    if index(cFormat, '>') > 0 or index(cFormat, '<') > 0 or
       index(cFormat, '9') > 0 or index(cFormat, 'z') > 0 then
        assign
            cReturn = replace(cFormat, 'z':u, '>':u)
            cReturn = replace(replace(replace(replace(cReturn,
                                                      '<':u, '#':u),
                                              '>':u, '#':u),
                                      '9':u, '0':u),
                              '-':u, '':u)
            cReturn = replace(replace(replace(cReturn,
                                              ',':u, ';':u),
                                      '.':u, ',':u),
                              ';':u, '.':u).

    return cReturn.

end function.

/* MESSAGE fn-excel-format('>>>,>>9.99') skip */
/*         fn-excel-format('->>>999.99') skip */
/*         fn-excel-format('x(10)') skip      */
/*         fn-excel-format('99/99/9999') skip */
/*     VIEW-AS ALERT-BOX INFO BUTTONS OK.     */
