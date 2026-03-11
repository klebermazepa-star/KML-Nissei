/****************************************************************************/
/* intprg/int110xrp.p - Inytegra‡Æo de pedidos do Sysfarma                  */
/****************************************************************************/
{include/i-prgvrs.i int110 1.00.00.AVB}
    
&Global-Define Program int110

define new global shared var c-seg-usuario as char format "x(12)" no-undo.    

def temp-table tt-param no-undo
    field destino          as integer
    field arquivo          as char format "x(35)"
    field usuario          as char format "x(12)"
    field data-exec        as date
    field hora-exec        as integer
    field classifica       as integer
    field desc-classifica  as char format "x(40)"
    field serie            as char.

def temp-table tt-raw-digita
   field raw-digita      as raw.

/* Definiacao dos parametros de execucao */
def var raw-param        as raw no-undo.

create tt-param.
assign tt-param.usuario         = c-seg-usuario
       tt-param.destino         = 2 /* Arquivo */
       tt-param.arquivo         = session:temp-directory + "\int110-10.log"
       tt-param.data-exec       = today
       tt-param.hora-exec       = time
       tt-param.serie           = "10".

raw-transfer tt-param to raw-param.
if not OPSYS = "UNIX" then
assign current-window:visible = no.
/* Chamada ao programa de geracao dos dados */
run intprg/{&Program}rp.p (input raw-param, input table tt-raw-digita).
if not OPSYS = "UNIX" then
assign current-window:visible = no.

quit.
