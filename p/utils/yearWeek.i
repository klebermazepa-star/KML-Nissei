function yearWeek returns integer
  (d-data as date, i-day-ini-week as integer) :
/*------------------------------------------------------------------------------
  Purpose:  Calcula o nœmero da semana no ano.
    Notes:  Assume que a semana inicia no domingo e termina no sÿbado.
            o parametro i-day-ini-week nao estah sendo usado
------------------------------------------------------------------------------*/
    define variable i-dias      as integer no-undo.
    define variable i-semana    as integer no-undo.

    assign
        i-dias   = (d-data + (7 - weekday(d-data)))
                 - date(1, 1, year(d-data)) + 1
        i-semana = truncate(i-dias / 7, 0).

    if (i-dias modulo 7) > 0 then
        assign
            i-semana = i-semana + 1.

  return i-semana.

end function.

/***************** end function ****************/

