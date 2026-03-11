define temp-table tt-param no-undo
    field destino          as integer
    field arquivo          as char format "x(35)"
    field usuario          as char format "x(12)"
    field data-exec        as date
    field hora-exec        as integer
    field modelo           as char format "x(35)"
    field classifica       as integer
    field desc-classifica  as char format "x(40)".


def temp-table tt-raw-digita
   field raw-digita      as raw.
                    
