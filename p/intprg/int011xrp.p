/****************************************************************************/
/* intprg/int011xrp.p - Inytegra‡Æo de Notas Fiscais p/ Sysfarma                  */
/****************************************************************************/
{include/i-prgvrs.i int11 1.00.00.AVB}
    
&Global-Define Program int011

define new global shared var c-seg-usuario as char format "x(12)" no-undo.    

define temp-table tt-param no-undo
    field destino          as integer
    field arquivo          as char format "x(35)"
    field usuario          as char format "x(12)"
    field data-exec        as date
    field hora-exec        as integer
    field classifica       as integer
    field desc-classifica  as char format "x(40)"
    field cod-estabel-ini  as char format "x(5)"
    field cod-estabel-fim  as char format "x(5)"
    field dt-cancela-ini   as date format "99/99/9999"
    field dt-cancela-fim   as date format "99/99/9999"
    field dt-emis-nota-ini as date format "99/99/9999"
    field dt-emis-nota-fim as date format "99/99/9999".

def temp-table tt-raw-digita
   field raw-digita      as raw.

/* Definiacao dos parametros de execucao */
def var raw-param        as raw no-undo.

create tt-param.
assign tt-param.usuario          = c-seg-usuario
       tt-param.destino          = 2 /* Arquivo */
       tt-param.arquivo          = session:temp-directory + "\int011.log"
       tt-param.data-exec        = today
       tt-param.hora-exec        = time
       tt-param.cod-estabel-ini  = ""
       tt-param.cod-estabel-fim  = "ZZZZZ"
       tt-param.dt-cancela-ini   = today - 7
       tt-param.dt-cancela-fim   = today
       tt-param.dt-emis-nota-ini = today - 7
       tt-param.dt-emis-nota-fim = today.


raw-transfer tt-param to raw-param.
if not OPSYS = "UNIX" then
assign current-window:visible = no.
/* Chamada ao programa de geracao dos dados */
run intprg/{&Program}rp.p (input raw-param, input table tt-raw-digita).
if not OPSYS = "UNIX" then
assign current-window:visible = no.

quit.
