/********************************************************************************
** Programa: int026 - Importaá∆o de Cadastro INT013
**
** Versao : 12 - 05/05/2016 - Alessandro V Baccin
**
********************************************************************************/

/* include de controle de vers∆o */
{include/i-prgvrs.i INT026rp 2.12.01.AVB}

/* definiá∆o das temp-tables para recebimento de parÉmetros */
define temp-table tt-param no-undo
    field destino          as integer
    field arquivo          as char format "x(35)"
    field usuario          as char format "x(12)"
    field arq-destino      as char format "x(35)"
    field data-exec        as date
    field hora-exec        as integer
    field todos            as integer
    field arq-entrada      as char.

def temp-table tt-raw-digita
    	field raw-digita	as raw.

/* recebimento de parÉmetros */
def input parameter raw-param as raw no-undo.
def input parameter TABLE for tt-raw-digita.
    
create tt-param.
RAW-TRANSFER raw-param to tt-param NO-ERROR.

/* include padr∆o para vari†veis para o log  */
{include/i-rpvar.i}

/* definiá∆o de vari†veis e streams */
def stream s-imp.
def var h-acomp as handle no-undo.
def var i-cont as integer no-undo.
def var c-mensagem as char format "X(70)" no-undo.

define temp-table tt-int_ds_cfop_natur_oper like int_ds_cfop_natur_oper.

/* definiá∆o de frames do log */
form 
    with frame f-rel width 300 stream-io down.

/* include padr∆o para output de log */
{include/i-rpout.i &STREAM="stream str-rp" &TOFILE=tt-param.arq-destino}

/* include com a definiá∆o da frame de cabeáalho e rodapÇ */
{include/i-rpcab.i &STREAM="str-rp"}


for first param-global fields (empresa-prin) no-lock: end.
for first ems2mult.empresa fields (razao-social) no-lock where
    ems2mult.empresa.ep-codigo = param-global.empresa-prin: end.

/* bloco principal do programa */
assign	c-programa 	    = "INT026RP"
        c-versao	    = "2.12"
        c-revisao	    = ".02.AVB"
        c-empresa       = ems2mult.empresa.razao-social
        c-sistema	    = 'Recebimento'
        c-titulo-relat  = "Importaá∆o de Cadastro INT013".

view stream str-rp frame f-cabec.
view stream str-rp frame f-rodape.
run utp/ut-acomp.p persistent set h-acomp.
{utp/ut-liter.i Importando *}
run pi-inicializar in h-acomp (input RETURN-VALUE).

/* define o arquivo de entrada informando na p†gina de parÉmetros */
input stream s-imp FROM value(tt-param.arq-entrada).

/* bloco principal do programa */
repeat on stop undo, leave:
    c-mensagem = ''.
    create tt-int_ds_cfop_natur_oper.
    import stream s-imp delimiter ";"
        tt-int_ds_cfop_natur_oper.nen_cfop_n
        tt-int_ds_cfop_natur_oper.nep_cstb_icm_n
        tt-int_ds_cfop_natur_oper.nep_cstb_ipi_n
        tt-int_ds_cfop_natur_oper.cod_estabel
        tt-int_ds_cfop_natur_oper.cod_emitente
        tt-int_ds_cfop_natur_oper.dt_inicio_validade
        tt-int_ds_cfop_natur_oper.nat_operacao.

    assign i-cont = i-cont + 1.
	run pi-acompanhar in h-acomp (input "Linha: " + string(i-cont)).



    if tt-int_ds_cfop_natur_oper.cod_estabel <> ? and
       not can-find(first estabelec no-lock where 
           estabelec.cod-estabel = tt-int_ds_cfop_natur_oper.cod_estabel) then do:
        assign c-mensagem = "Estabelecimento n∆o encontrado!".
    end.
    if tt-int_ds_cfop_natur_oper.cod_emitente <> ? and
       not can-find(first emitente no-lock where 
           emitente.cod-emitente = tt-int_ds_cfop_natur_oper.cod_emitente) then do:
        assign c-mensagem = "Emitente n∆o encontrado!".
    end.
    if not can-find(first natur-oper no-lock where 
           natur-oper.nat-operacao = tt-int_ds_cfop_natur_oper.nat_operacao) then do:
        assign c-mensagem = "Natureza de Operaá∆o n∆o encontrada!".
    end.
    if tt-int_ds_cfop_natur_oper.nep_cstb_ipi_n <> ? and
       not can-find(first familia no-lock where 
           familia.fm-codigo = string(tt-int_ds_cfop_natur_oper.nep_cstb_ipi_n)) then do:
        assign c-mensagem = "Fam°lia n∆o encontrada!".
    end.

    if c-mensagem = "" then do:
        for first int_ds_cfop_natur_oper exclusive where 
            int_ds_cfop_natur_oper.nen_cfop_n     = tt-int_ds_cfop_natur_oper.nen_cfop_n and
            int_ds_cfop_natur_oper.nep_cstb_icm_n = tt-int_ds_cfop_natur_oper.nep_cstb_icm_n and
            int_ds_cfop_natur_oper.nep_cstb_ipi_n = tt-int_ds_cfop_natur_oper.nep_cstb_ipi_n and
            int_ds_cfop_natur_oper.cod_estabel    = tt-int_ds_cfop_natur_oper.cod_estabel and
            int_ds_cfop_natur_oper.cod_emitente   = tt-int_ds_cfop_natur_oper.cod_emitente: end.
        if not avail int_ds_cfop_natur_oper then do:
            create int_ds_cfop_natur_oper no-error.
        end.            
        buffer-copy tt-int_ds_cfop_natur_oper to int_ds_cfop_natur_oper no-error.
    end.
    if tt-param.todos = 1 or c-mensagem <> "" then do:
        display stream str-rp
            tt-int_ds_cfop_natur_oper.nen_cfop_n
            tt-int_ds_cfop_natur_oper.nep_cstb_icm_n
            tt-int_ds_cfop_natur_oper.nep_cstb_ipi_n
            tt-int_ds_cfop_natur_oper.cod_estabel
            tt-int_ds_cfop_natur_oper.cod_emitente
            tt-int_ds_cfop_natur_oper.nat_operacao
            c-mensagem column-label "Mensagem"
            with frame f-rel width 300 stream-io down.
        down stream str-rp with frame f-rel.
    end.
end.
input stream s-imp close.
empty temp-table tt-int_ds_cfop_natur_oper.

/* fechamento do output do log */
{include/i-rpclo.i &STREAM="stream str-rp"}

run pi-finalizar in h-acomp.

return "Ok":U.
