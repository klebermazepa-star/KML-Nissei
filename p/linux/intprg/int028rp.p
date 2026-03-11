/********************************************************************************
** Programa: int028 - Importaá∆o de Cadastro INT018
**
** Versao : 12 - 05/05/2016 - Alessandro V Baccin
**
********************************************************************************/
/* include de controle de vers∆o */
{include/i-prgvrs.i INT028rp 2.12.01.AVB}

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

define temp-table tt-int_ds_loja_natur_oper like int_ds_loja_natur_oper.

/* definiá∆o de frames do log */
form 
    with frame f-rel width 300 stream-io down.

/* include padr∆o para output de log */
{include/i-rpout.i &STREAM="stream str-rp" &TOFILE=tt-param.arq-destino}

/* include com a definiá∆o da frame de cabeáalho e rodapÇ */
{include/i-rpcab.i &STREAM="str-rp"}


for first param-global fields (empresa-prin) no-lock: end.
for first mgadm.empresa fields (razao-social) no-lock where
    empresa.ep-codigo = param-global.empresa-prin: end.

/* bloco principal do programa */
assign	c-programa 	    = "INT028RP"
        c-versao	    = "2.12"
        c-revisao	    = ".02.AVB"
        c-empresa       = mgadm.empresa.razao-social
        c-sistema	    = 'Faturamento'
        c-titulo-relat  = "Importaá∆o de Cadastro INT018".

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
    create tt-int_ds_loja_natur_oper.
    import stream s-imp delimiter ";"
        tt-int_ds_loja_natur_oper.cod_estabel
        tt-int_ds_loja_natur_oper.estado
        tt-int_ds_loja_natur_oper.cidade
        tt-int_ds_loja_natur_oper.condipag
        tt-int_ds_loja_natur_oper.convenio
        tt-int_ds_loja_natur_oper.class_fiscal
        tt-int_ds_loja_natur_oper.nat_operacao
        tt-int_ds_loja_natur_oper.cod_cond_pag
        tt-int_ds_loja_natur_oper.cod_portador
        tt-int_ds_loja_natur_oper.modalidade
        tt-int_ds_loja_natur_oper.serie
        tt-int_ds_loja_natur_oper.nat_devol
        tt-int_ds_loja_natur_oper.cod_esp.

    assign i-cont = i-cont + 1.
	run pi-acompanhar in h-acomp (input "Linha: " + string(i-cont)).


    if tt-int_ds_loja_natur_oper.condipag < '01' or
       tt-int_ds_loja_natur_oper.condipag > '99' then do:
        assign c-mensagem = "Cond Pagto PRS invalida!".
    end.
    if tt-int_ds_loja_natur_oper.cod_estabel <> ? and
       not can-find(first estabelec no-lock where 
           estabelec.cod-estabel = tt-int_ds_loja_natur_oper.cod_estabel) then do:
        assign c-mensagem = "Estabelecimento n∆o encontrado!".
    end.
    if tt-int_ds_loja_natur_oper.estado <> ? and
       not can-find(first unid-feder no-lock where 
           unid-feder.estado = tt-int_ds_loja_natur_oper.estado and
           unid-feder.pais = "Brasil") then do:
        assign c-mensagem = "Estado n∆o encontrado!".
    end.

    if tt-int_ds_loja_natur_oper.convenio <> "S" and 
       tt-int_ds_loja_natur_oper.convenio <> "N" then do:
        assign c-mensagem = "Convenio deve ser S ou N!".
    end.
    if tt-int_ds_loja_natur_oper.class_fiscal <> ? and
       not can-find(first classif-fisc no-lock where 
           classif-fisc.class-fiscal = tt-int_ds_loja_natur_oper.class_fiscal) then do:
        assign c-mensagem = "NCM n∆o encontrado!".
    end.
    if tt-int_ds_loja_natur_oper.serie <> ? and
       not can-find(first serie no-lock where 
           serie.serie = tt-int_ds_loja_natur_oper.serie) then do:
        assign c-mensagem = "Serie n∆o encontrada!".
    end.
    if tt-int_ds_loja_natur_oper.cod_portador <> ? and
       not can-find(first mgadm.portador no-lock where 
           mgadm.portador.cod-portador = tt-int_ds_loja_natur_oper.cod_portador and
           mgadm.portador.modalidade = tt-int_ds_loja_natur_oper.modalidade) then do:
        assign c-mensagem = "Portador n∆o encontrado!".
    end.
    if tt-int_ds_loja_natur_oper.serie <> ? and
       tt-int_ds_loja_natur_oper.cod_estabel <> ? and
       not can-find(first ser-estab no-lock where 
           ser-estab.serie = tt-int_ds_loja_natur_oper.serie and
           ser-estab.cod-estabel = tt-int_ds_loja_natur_oper.cod_estabel) then do:
        assign c-mensagem = "Serie X Estabelecimento n∆o encontrada!".
    end.
    if tt-int_ds_loja_natur_oper.cod_cond_pag <> ? and
       not can-find(first cond-pagto no-lock where 
           cond-pagto.cod-cond-pag = tt-int_ds_loja_natur_oper.cod_cond_pag) then do:
        assign c-mensagem = "Cond. Pagto n∆o encontrada!".
    end.
    if not can-find(first natur-oper no-lock where 
           natur-oper.nat-operacao = tt-int_ds_loja_natur_oper.nat_operacao) then do:
        assign c-mensagem = "Natureza de Operaá∆o n∆o encontrada!".
    end.
    if  tt-int_ds_loja_natur_oper.nat_devol <> ? and
        not can-find(first natur-oper no-lock where 
           natur-oper.nat-operacao = tt-int_ds_loja_natur_oper.nat_devol) then do:
        assign c-mensagem = "Nat. Operaá∆o Devoluá∆o n∆o encontrada!".
    end.
    if  tt-int_ds_loja_natur_oper.cod_esp = "" or 
        tt-int_ds_loja_natur_oper.cod_esp = ? or
        not can-find (first esp-doc no-lock where esp-doc.cod-esp = 
                      tt-int_ds_loja_natur_oper.cod_esp) then do:
        assign c-mensagem = "EspÇcie n∆o encontrada!".
    end.

    if c-mensagem = "" then do:
        for first int_ds_loja_natur_oper exclusive where 
            int_ds_loja_natur_oper.condipag       = tt-int_ds_loja_natur_oper.condipag and
            int_ds_loja_natur_oper.cod_estabel    = tt-int_ds_loja_natur_oper.cod_estabel and
            int_ds_loja_natur_oper.estado         = tt-int_ds_loja_natur_oper.estado and
            int_ds_loja_natur_oper.cidade         = tt-int_ds_loja_natur_oper.cidade and
            int_ds_loja_natur_oper.convenio       = tt-int_ds_loja_natur_oper.convenio and
            int_ds_loja_natur_oper.class_fiscal   = tt-int_ds_loja_natur_oper.class_fiscal: end.
        if not avail int_ds_loja_natur_oper then do:
            create int_ds_loja_natur_oper no-error.
        end.            
        buffer-copy tt-int_ds_loja_natur_oper to int_ds_loja_natur_oper no-error.
    end.
    if tt-param.todos = 1 or c-mensagem <> "" then do:
        display stream str-rp
            tt-int_ds_loja_natur_oper.cod_estabel   format "x(4)"
            tt-int_ds_loja_natur_oper.estado        format "x(2)"
            tt-int_ds_loja_natur_oper.cidade
            tt-int_ds_loja_natur_oper.condipag      format "x(4)"
            tt-int_ds_loja_natur_oper.convenio
            tt-int_ds_loja_natur_oper.class_fiscal
            tt-int_ds_loja_natur_oper.nat_operacao
            tt-int_ds_loja_natur_oper.cod_cond_pag
            tt-int_ds_loja_natur_oper.cod_portador
            tt-int_ds_loja_natur_oper.modalidade
            tt-int_ds_loja_natur_oper.serie
            tt-int_ds_loja_natur_oper.nat_devol
            tt-int_ds_loja_natur_oper.cod_esp
            c-mensagem column-label "Mensagem"
            with frame f-rel width 300 stream-io down.
        down stream str-rp with frame f-rel.
    end.
end.
input stream s-imp close.
empty temp-table tt-int_ds_loja_natur_oper.

/* fechamento do output do log */
{include/i-rpclo.i &STREAM="stream str-rp"}

run pi-finalizar in h-acomp.

return "Ok":U.
