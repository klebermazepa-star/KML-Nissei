/****************************************************************************/
/* intprg/int012xrp.p - Integra‡Æo de NFS p/ Tutorial/PRS                   */
/****************************************************************************/
{include/i-prgvrs.i int012 1.00.00.AVB}
    
&Global-Define Program int012

define new global shared var c-seg-usuario as char format "x(12)" no-undo.    

def temp-table tt-param no-undo
    field destino          as integer
    field arquivo          as char format "x(35)"
    field usuario          as char format "x(12)"
    field data-exec        as date
    field hora-exec        as integer
    field classifica       as integer
    field desc-classifica  as char format "x(40)"
    field cod-emitente-fim as integer
    field cod-emitente-ini as integer
    field cod-estabel-fim  as char
    field cod-estabel-ini  as char
    field dt-emis-nota-fim as date
    field dt-emis-nota-ini as date
    field nro-docto-fim    as integer
    field nro-docto-ini    as integer
    field serie-docto-fim  as char
    field serie-docto-ini  as char.

def temp-table tt-raw-digita
   field raw-digita      as raw.

/* Definiacao dos parametros de execucao */
def var raw-param        as raw no-undo.

create tt-param.
assign tt-param.usuario         = c-seg-usuario
       tt-param.destino         = 2 /* Arquivo */
       tt-param.arquivo         = session:temp-directory + "\int012.log"
       tt-param.data-exec       = today
       tt-param.hora-exec       = time.
       tt-param.cod-emitente-fim = 999999999
       tt-param.cod-emitente-ini = 0
       tt-param.cod-estabel-fim  = "ZZZZZ"
       tt-param.cod-estabel-ini  = ""
       tt-param.dt-emis-nota-fim = today
       tt-param.dt-emis-nota-ini = today - 7
       tt-param.nro-docto-fim    = 999999999
       tt-param.nro-docto-ini    = 0
       tt-param.serie-docto-fim  = "ZZZZZ"
       tt-param.serie-docto-ini  = "". 

raw-transfer tt-param to raw-param.
if not OPSYS = "UNIX" then
assign current-window:visible = no.
/* Chamada ao programa de geracao dos dados */
run intprg/{&Program}rp.p (input raw-param, input table tt-raw-digita).
if not OPSYS = "UNIX" then
assign current-window:visible = no.

quit.
