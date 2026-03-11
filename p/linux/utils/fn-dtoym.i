/* converte data para 'yyyymm' */

function fn-dtoym returns char (input d-conv as date).

    return string(year(d-conv), '9999') +
           string(month(d-conv), '99').

end function.
