/********************************************************************************
** Programa: int025 - Importaá∆o de Cadastro INT015
**
** Versao : 12 - 05/05/2016 - Alessandro V Baccin
**
********************************************************************************/

/* include de controle de vers∆o */
{include/i-prgvrs.i INT025rp 2.12.01.AVB}

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

define temp-table tt-int-ds-tp-natur-oper like int-ds-tp-natur-oper.

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
assign	c-programa 	    = "INT025RP"
        c-versao	    = "2.12"
        c-revisao	    = ".02.AVB"
        c-empresa       = mgadm.empresa.razao-social
        c-sistema	    = 'Faturamento'
        c-titulo-relat  = "Importaá∆o de Cadastro INT015".

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
    create tt-int-ds-tp-natur-oper.
    import stream s-imp delimiter ";"
        tt-int-ds-tp-natur-oper.tp-pedido
        tt-int-ds-tp-natur-oper.cod-estabel
        tt-int-ds-tp-natur-oper.uf-destino
        tt-int-ds-tp-natur-oper.uf-origem
        tt-int-ds-tp-natur-oper.cod-emitente
        tt-int-ds-tp-natur-oper.class-fiscal
        tt-int-ds-tp-natur-oper.nat-operacao
        tt-int-ds-tp-natur-oper.cod-cond-pag
        tt-int-ds-tp-natur-oper.cod-portador
        tt-int-ds-tp-natur-oper.modalidade
        tt-int-ds-tp-natur-oper.serie
        tt-int-ds-tp-natur-oper.cst-icms
        tt-int-ds-tp-natur-oper.nat-oper-entrada.

    assign i-cont = i-cont + 1.
	run pi-acompanhar in h-acomp (input "Linha: " + string(i-cont)).

    if tt-int-ds-tp-natur-oper.cst-icms = ? then
        assign tt-int-ds-tp-natur-oper.cst-icms = 0.

/*     if tt-int-ds-tp-natur-oper.tp-pedido < '1' or                                     */
/*        tt-int-ds-tp-natur-oper.tp-pedido > '53' then do:                              */
/*         assign c-mensagem = "Tipo de pedido inv†lido!".                               */
/*     end.                                                                              */
/*     if tt-int-ds-tp-natur-oper.tp-pedido <> '15' and                                  */
/*        tt-int-ds-tp-natur-oper.tp-pedido <> '32' and                                  */
/*        tt-int-ds-tp-natur-oper.cst-icms <> 0 then do:                                 */
/*         assign c-mensagem = "Informar CST Icms somente p/ devoluá‰es!".               */
/*     end.                                                                              */
/*     if (tt-int-ds-tp-natur-oper.tp-pedido = '15' or                                   */
/*         tt-int-ds-tp-natur-oper.tp-pedido = '32') and                                 */
/*        tt-int-ds-tp-natur-oper.cst-icms > 99 then do:                                 */
/*         assign c-mensagem = "CST Icms inv†lido!".                                     */
/*     end.                                                                              */
/*                                                                                       */
/*     if tt-int-ds-tp-natur-oper.cod-estabel <> ? and                                   */
/*        not can-find(first estabelec no-lock where                                     */
/*            estabelec.cod-estabel = tt-int-ds-tp-natur-oper.cod-estabel) then do:      */
/*         assign c-mensagem = "Estabelecimento n∆o encontrado!".                        */
/*     end.                                                                              */
/*     if tt-int-ds-tp-natur-oper.uf-destino <> ? and                                    */
/*        not can-find(first unid-feder no-lock where                                    */
/*            unid-feder.estado = tt-int-ds-tp-natur-oper.uf-destino and                 */
/*            unid-feder.pais = "Brasil") then do:                                       */
/*         assign c-mensagem = "Estado n∆o encontrado!".                                 */
/*     end.                                                                              */
/*     if tt-int-ds-tp-natur-oper.class-fiscal <> ? and                                  */
/*        not can-find(first classif-fisc no-lock where                                  */
/*            classif-fisc.class-fiscal = tt-int-ds-tp-natur-oper.class-fiscal) then do: */
/*         assign c-mensagem = "NCM n∆o encontrado!".                                    */
/*     end.                                                                              */
/*     if tt-int-ds-tp-natur-oper.cod-emitente <> ? and                                  */
/*        not can-find(first emitente no-lock where                                      */
/*            emitente.cod-emitente = tt-int-ds-tp-natur-oper.cod-emitente) then do:     */
/*         assign c-mensagem = "Emitente n∆o encontrado!".                               */
/*     end.                                                                              */
/*     if tt-int-ds-tp-natur-oper.serie <> ? and                                         */
/*        not can-find(first serie no-lock where                                         */
/*            serie.serie = tt-int-ds-tp-natur-oper.serie) then do:                      */
/*         assign c-mensagem = "Serie n∆o encontrada!".                                  */
/*     end.                                                                              */
/*     if tt-int-ds-tp-natur-oper.cod-portador <> ? and                                  */
/*        not can-find(first mgadm.portador no-lock where                                */
/*            mgadm.portador.cod-portador = tt-int-ds-tp-natur-oper.cod-portador and     */
/*            mgadm.portador.modalidade = tt-int-ds-tp-natur-oper.modalidade) then do:   */
/*         assign c-mensagem = "Portador n∆o encontrado!".                               */
/*     end.                                                                              */
/*                                                                                       */
/*     if tt-int-ds-tp-natur-oper.serie <> ? and                                         */
/*        tt-int-ds-tp-natur-oper.cod-estabel <> ? and                                   */
/*        not can-find(first ser-estab no-lock where                                     */
/*            ser-estab.serie = tt-int-ds-tp-natur-oper.serie and                        */
/*            ser-estab.cod-estabel = tt-int-ds-tp-natur-oper.cod-estabel) then do:      */
/*         assign c-mensagem = "Serie X Estabelecimento n∆o encontrada!".                */
/*     end.                                                                              */
/*     if tt-int-ds-tp-natur-oper.cod-cond-pag <> ? and                                  */
/*        not can-find(first cond-pagto no-lock where                                    */
/*            cond-pagto.cod-cond-pag = tt-int-ds-tp-natur-oper.cod-cond-pag) then do:   */
/*         assign c-mensagem = "Cond. Pagto n∆o encontrada!".                            */
/*     end.                                                                              */
/*     if not can-find(first natur-oper no-lock where                                    */
/*            natur-oper.nat-operacao = tt-int-ds-tp-natur-oper.nat-operacao) then do:   */
/*         assign c-mensagem = "Natureza de Operaá∆o n∆o encontrada!".                   */
/*     end.                                                                              */
/*                                                                                       */
/*     IF tt-int-ds-tp-natur-oper.nat-oper-entrada <> ""                                 */
/*     THEN DO:                                                                          */
/*         if not can-find(first natur-oper no-lock where                                */
/*            natur-oper.nat-operacao = tt-int-ds-tp-natur-oper.nat-oper-entrad)         */
/*         then do:                                                                      */
/*            assign c-mensagem = "Natureza de Operaá∆o de Entrada n∆o encontrada!".     */
/*         end.                                                                          */
/*     END.                                                                              */

    if c-mensagem = "" then do:
        for first int-ds-tp-natur-oper exclusive where 
            int-ds-tp-natur-oper.tp-pedido      = tt-int-ds-tp-natur-oper.tp-pedido and
            int-ds-tp-natur-oper.cod-estabel    = tt-int-ds-tp-natur-oper.cod-estabel and
            int-ds-tp-natur-oper.uf-destino     = tt-int-ds-tp-natur-oper.uf-destino and
            int-ds-tp-natur-oper.uf-origem      = tt-int-ds-tp-natur-oper.uf-origem and
            int-ds-tp-natur-oper.cod-emitente   = tt-int-ds-tp-natur-oper.cod-emitente and
            int-ds-tp-natur-oper.class-fiscal   = tt-int-ds-tp-natur-oper.class-fiscal: end.
        if not avail int-ds-tp-natur-oper then do:
            create int-ds-tp-natur-oper no-error.
        end.            
        buffer-copy tt-int-ds-tp-natur-oper to int-ds-tp-natur-oper no-error.
    end.
    if tt-param.todos = 1 or c-mensagem <> "" then do:
        display stream str-rp
            tt-int-ds-tp-natur-oper.tp-pedido
            tt-int-ds-tp-natur-oper.cod-estabel
            tt-int-ds-tp-natur-oper.uf-destino
            tt-int-ds-tp-natur-oper.uf-origem
            tt-int-ds-tp-natur-oper.cod-emitente
            tt-int-ds-tp-natur-oper.class-fiscal
            tt-int-ds-tp-natur-oper.nat-operacao
            tt-int-ds-tp-natur-oper.cod-cond-pag
            tt-int-ds-tp-natur-oper.cod-portador
            tt-int-ds-tp-natur-oper.modalidade
            tt-int-ds-tp-natur-oper.serie
            tt-int-ds-tp-natur-oper.cst-icms
            tt-int-ds-tp-natur-oper.nat-oper-entrada
            c-mensagem column-label "Mensagem"
            with frame f-rel width 300 stream-io down.
        down stream str-rp with frame f-rel.
    end.
end.
input stream s-imp close.
empty temp-table tt-int-ds-tp-natur-oper.

/* fechamento do output do log */
{include/i-rpclo.i &STREAM="stream str-rp"}

run pi-finalizar in h-acomp.

return "Ok":U.
