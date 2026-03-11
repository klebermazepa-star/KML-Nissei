/* include de controle de versÆo */
{include/i-prgvrs.i INT034RP 1.00.00.AVB}

/* defini‡Æo das temp-tables para recebimento de parƒmetros */
define temp-table tt-param no-undo
    field destino          as integer
    field arquivo          as char format "x(35)"
    field usuario          as char format "x(12)"
    field data-exec        as date
    field hora-exec        as integer
    field classifica       as integer
    field desc-classifica  as char format "x(40)"
    field cod-estabel-fim  as char
    field cod-estabel-ini  as char
    field dt-movto-fim     as date
    field dt-movto-ini     as date
    field estado-fim       as char
    field estado-ini       as char.

def temp-table tt-raw-digita
    	field raw-digita	as raw.

/* recebimento de parƒmetros */
def input parameter raw-param as raw no-undo.
def input parameter table for tt-raw-digita.
create tt-param.
raw-transfer raw-param to tt-param.

/* include padrÆo para vari veis de relat¢rio  */
{include/i-rpvar.i}

/* defini‡Æo de vari veis  */
def var h-acomp as handle no-undo.
def var de-total as decimal no-undo.
def var i-mod as integer no-undo.

/* defini‡Æo de frames do relat¢rio */
form
  with frame f-rel down stream-io.

/* include padrÆo para output de relat¢rios */
{include/i-rpout.i &STREAM="stream str-rp"}

/* include com a defini‡Æo da frame de cabe‡alho e rodap‚ */
{include/i-rpcab.i &STREAM="str-rp"}

for first param-global fields (empresa-prin ct-format sc-format) no-lock: end.
for first mgadm.empresa fields (razao-social) no-lock where
     empresa.ep-codigo = param-global.empresa-prin: end.
assign c-empresa = mgadm.empresa.razao-social.

/* bloco principal do programa */
assign  c-programa 	    = "INT034RP"
	    c-versao	    = "1.00"
	    c-revisao	    = ".00.AVB"
        c-empresa       = empresa.razao-social
	    c-sistema	    = "Faturamento Lojas"
	    c-titulo-relat  = "Resumo Faturamento".

view stream str-rp frame f-cabec.
view stream str-rp frame f-rodape.

run utp/ut-acomp.p persistent set h-acomp.
run pi-inicializar in h-acomp (input "Imprimindo").
for each estabelec no-lock where 
    estabelec.estado >= tt-param.estado-ini and
    estabelec.estado <= tt-param.estado-fim and
    estabelec.cod-estabel >= tt-param.cod-estabel-ini and 
    estabelec.cod-estabel <= tt-param.cod-estabel-fim,
    each ser-estab no-lock where
    ser-estab.cod-estabel = estabelec.cod-estabel and
    ser-estab.forma-emis = 2 /* Manual - Cupons */
    break by estabelec.cod-estabel
            by ser-estab.serie
    on stop undo, leave:

    if first-of (estabelec.cod-estabel) then
        de-total = 0.
    for each nota-fiscal no-lock where
        nota-fiscal.cod-estabel = ser-estab.cod-estabel and
        nota-fiscal.serie = ser-estab.serie and
        nota-fiscal.dt-emis-nota >= tt-param.dt-movto-ini and
        nota-fiscal.dt-emis-nota <= tt-param.dt-movto-fim and
        nota-fiscal.dt-cancela    = ?
        on stop undo, leave:

        i-mod = i-mod + 1.
        if i-mod mod 500 = 0 then 
            run pi-acompanhar in h-acomp (input string(nota-fiscal.cod-estabel + "/" + nota-fiscal.serie + "/" + nota-fiscal.nr-nota-fis)).

        FOR EACH it-nota-fisc NO-LOCK OF nota-fiscal:
            /*IF it-nota-fisc.it-codigo = "4" THEN NEXT.*/
            IF NOT it-nota-fisc.nat-operacao BEGINS "5102" AND
               NOT it-nota-fisc.nat-operacao BEGINS "6102" AND
               NOT it-nota-fisc.nat-operacao BEGINS "5405" AND
               NOT it-nota-fisc.nat-operacao BEGINS "6405" THEN NEXT.
            de-total = de-total + it-nota-fisc.vl-tot-item.
        END.

    end.
    if last-of (estabelec.cod-estabel) then do:
        display stream str-rp
            estabelec.cod-estabel
            estabelec.estado
            de-total column-label "Total" format "->>>,>>>,>>9.99"
            with frame f-rel.
        down stream str-rp with frame f-rel.
    end.
end.    
/* fechamento do output do relat¢rio  */
{include/i-rpclo.i &STREAM="stream str-rp"}

run pi-finalizar in h-acomp.
return "OK":U.
