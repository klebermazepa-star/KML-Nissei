/* include de controle de versÆo */
{include/i-prgvrs.i INT118RP 1.00.00.AVB}

/* defini‡Æo das temp-tables para recebimento de parƒmetros */
define temp-table tt-param no-undo
    field destino          as integer
    field arquivo          as char format "x(35)"
    field usuario          as char format "x(12)"
    field data-exec        as date
    field hora-exec        as integer
    field classifica       as integer
    field desc-classifica  as char format "x(40)"
    field modelo-rtf       as char format "x(35)"
    field l-habilitaRtf    as logical
    field cd-trib-icm      as integer
    field class-fiscal-ini like int-ds-classif-fisc.class-fiscal
    field class-fiscal-fim like int-ds-classif-fisc.class-fiscal.

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
def var c-tributacao as char format "x(12)" label "Descri‡Æo" no-undo.
/* defini‡Æo de frames do relat¢rio */


form
    classif-fisc.class-fiscal
    classif-fisc.descricao
    int-ds-classif-fisc.cd-trib-icm
    c-tributacao
  with frame f-rel-1 down stream-io width 550.

Form
    int-ds-classif-fisc.cd-trib-icm
    c-tributacao
    int-ds-classif-fisc.class-fiscal
    classif-fisc.descricao
  with frame f-rel-2 down stream-io width 550.


/* include padrÆo para output de relat¢rios */
{include/i-rpout.i &STREAM="stream str-rp"}

/* include com a defini‡Æo da frame de cabe‡alho e rodap‚ */
{include/i-rpcab.i &STREAM="str-rp"}


find first param-global no-lock no-error.
find mgcad.empresa no-lock where
     empresa.ep-codigo = param-global.empresa-prin 
    no-error.


/* bloco principal do programa */
assign  c-programa 	    = "INT118RP"
	    c-versao	    = "1.00"
	    c-revisao	    = ".00.AVB"
        c-empresa       = empresa.razao-social
	    c-sistema	    = "Cadastros"
	    c-titulo-relat  = "Listagem Tp Trib X NCM".

view stream str-rp frame f-cabec.
view stream str-rp frame f-rodape.

run utp/ut-acomp.p persistent set h-acomp.
run pi-inicializar in h-acomp (input "Imprimindo").

if tt-param.classific = 1 THEN
for each classif-fisc no-lock where
	classif-fisc.class-fiscal >= tt-param.class-fiscal-ini and
	classif-fisc.class-fiscal <= tt-param.class-fiscal-fim
    by classif-fisc.class-fiscal
    on stop undo, leave:

    for each int-ds-classif-fisc no-lock of classif-fisc
        on stop undo, leave:

        run pi-acompanhar in h-acomp (input string(int-ds-classif-fisc.class-fiscal)).

        if tt-param.cd-trib-icm <> 99 and
           tt-param.cd-trib-icm <> int-ds-classif-fisc.cd-trib-icm then next.

        case int-ds-classif-fisc.cd-trib-icm:
            when 0 then c-tributacao = "Nenhum".
            when 1 then c-tributacao = "Tributado".
            when 2 then c-tributacao = "Isento".
            when 3 then c-tributacao = "Cesta B sica".
            when 4 then c-tributacao = "Outros".
            when 9 then c-tributacao = "ST".
        end case.
        display stream str-rp
            classif-fisc.class-fiscal
            classif-fisc.descricao
            int-ds-classif-fisc.cd-trib-icm
            c-tributacao
        with frame f-rel-1.

        down stream str-rp with frame f-rel-1.
    end.
end.
else 
for each int-ds-classif-fisc no-lock
	where int-ds-classif-fisc.class-fiscal >= tt-param.class-fiscal-ini and
	      int-ds-classif-fisc.class-fiscal <= tt-param.class-fiscal-fim 
    by int-ds-classif-fisc.cd-trib-icm
    on stop undo, leave:
	
    run pi-acompanhar in h-acomp (input int-ds-classif-fisc.cd-trib-icm).

    if tt-param.cd-trib-icm <> 99 and
       tt-param.cd-trib-icm <> int-ds-classif-fisc.cd-trib-icm then next.

    case int-ds-classif-fisc.cd-trib-icm:
        when 0 then c-tributacao = "Nenhum".
        when 1 then c-tributacao = "Tributado".
        when 2 then c-tributacao = "Isento".
        when 3 then c-tributacao = "Cesta B sica".
        when 4 then c-tributacao = "Outros".
        when 9 then c-tributacao = "ST".
    end case.	
    for first classif-fisc no-lock of int-ds-classif-fisc: end.
    display stream str-rp
        int-ds-classif-fisc.cd-trib-icm
        c-tributacao
        int-ds-classif-fisc.class-fiscal
        classif-fisc.descricao when avail classif-fisc
    with frame f-rel-2.

	down stream str-rp with frame f-rel-2.
end.

/* fechamento do output do relat¢rio  */
{include/i-rpclo.i &STREAM="stream str-rp"}

run pi-finalizar in h-acomp.
return "OK":U.
