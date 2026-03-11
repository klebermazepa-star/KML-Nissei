def temp-table tt-raw-digita NO-UNDO field raw-digita  as raw.

define temp-table tt-param no-undo
    field destino       as integer
    field arquivo       as char
    field usuario       as char format "x(12)"
    field data-exec     as date
    field hora-exec     as integer.

def new global shared var c-seg-usuario as char no-undo.

def var raw-param          as raw no-undo.
DEF VAR i-num-ped-exec-rpw AS INT NO-UNDO.

create tt-param.
assign tt-param.usuario   = c-seg-usuario
       tt-param.destino   = 2
       tt-param.data-exec = today
       tt-param.hora-exec = TIME.

raw-transfer tt-param to raw-param.

run btb/btb911zb.p (input "INT004",
                    input "intprg/int004.p",
                    input "2.00.00.000",
                    input 97,
                    input "INT004.LST",
                    input 2,
                    input raw-param,
                    input table tt-raw-digita,
                    output i-num-ped-exec-rpw).
