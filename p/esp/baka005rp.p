DEF VAR l-erro AS LOGICAL NO-UNDO.

{cdp/cd0666.i}
{utp/ut-glob.i}

define temp-table tt-param no-undo
    field destino          as integer
    field arquivo          as char format "x(35)"
    field usuario          as char format "x(12)"
    field data-exec        as date
    field hora-exec        as integer
    field classifica       as integer
    field desc-classifica  as char format "x(40)"
    field r-docum-est      as ROWID.

/* Transfer Definitions */

def temp-table tt-raw-digita
    field raw-digita as raw.
    
def input parameter raw-param as raw no-undo.
def input parameter table for tt-raw-digita.

create tt-param.
raw-transfer raw-param to tt-param.

RUN esp/recalcula-impostos-re1001-transf4.r.


//OUTPUT CLOSE.
