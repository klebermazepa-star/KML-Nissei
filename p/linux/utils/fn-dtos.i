/* converte data para 'yyyymmdd' */

function fn-dtos returns char (input d-conv as date).

    return string(year(d-conv), '9999') +
           string(month(d-conv), '99') +
           string(day(d-conv), '99').

end function.
