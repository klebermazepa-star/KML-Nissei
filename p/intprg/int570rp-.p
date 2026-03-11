/********************************************************************************
** Programa: int570 - C lculo Preco Base
**
** Versao : 12 - 11/2019 - Alessandro V Baccin
**
********************************************************************************/
/* include de controle de versÆo */
{include/i-prgvrs.i int570RP 2.12.01.AVB}
{cdp/cdcfgdis.i}
{utp/ut-glob.i}

/* defini‡Æo das temp-tables para recebimento de parƒmetros */
define temp-table tt-param no-undo
    field destino          as integer
    field arquivo          as char format "x(35)"
    field usuario          as char format "x(12)"
    field data-exec        as date
    field hora-exec        as integer
    field classifica       as integer
    field desc-classifica  as char format "x(40)".

def temp-table tt-raw-digita NO-UNDO
    field raw-digita      as raw.
 
define temp-table tt-docto like cst_docum_est_custo
    field r-rowid as rowid
    index CHAVE 
        serie_docto  
        Nro_docto    
        cod_emitente 
        nat_operacao.

define temp-table tt-nota like cst_nota_fiscal_custo
    field r-rowid as rowid
    index CHAVE 
        cod_estabel
        serie
        nr_nota_fis
        .

define temp-table tt-movto like movto-estoq
    field r-rowid as rowid
    index CHAVE 
        it-codigo
        serie-docto
        Nro-docto    
        dt-trans.

define buffer btt-docto for tt-docto.
define buffer btt-nota for tt-nota.

/* recebimento de parƒmetros */
def input parameter raw-param as raw no-undo.
def input parameter TABLE for tt-raw-digita. 

create tt-param.                    
raw-transfer raw-param to tt-param NO-ERROR. 
IF tt-param.arquivo = "" THEN 
    ASSIGN tt-param.arquivo = "int570.txt"
           tt-param.destino = 3
           tt-param.data-exec = TODAY
           tt-param.hora-exec = TIME.

/* include padrÆo para vari veis de relat¢rio  */
{include/i-rpvar.i}

/* defini‡Æo de vari veis  */
def var h-acomp         as handle no-undo.
def var de-qtde         as decimal format "->>,>>>,>>>,>>9.99" no-undo.
def var de-valor        as decimal format "->>,>>>,>>>,>>9.99" no-undo.
def var de-valor-ini    as decimal format "->>,>>>,>>>,>>9.99" no-undo.
def var d-dt-ini        as date no-undo.

/* defini‡Æo de frames do relat¢rio */

/* include com a defini‡Æo da frame de cabe‡alho e rodap‚ */
{include/i-rpcab.i /*&STREAM="str-rp"*/}
/* bloco principal do programa */

/*{include/i-rpcb80.i &stream = "str-rp"}
 */
FIND FIRST tt-param NO-LOCK NO-ERROR. 
IF tt-param.arquivo <> "" THEN DO:
    {include/i-rpout.i /*&stream = "stream str-rp"*/}
END.

assign c-programa     = "int570"
       c-versao       = "2.13"
       c-revisao      = ".06.AVB"
       c-empresa      = ""
       c-sistema      = "Recebimento"
       c-titulo-relat = "C lculo do Pre‡o Base dos Itens".

IF tt-param.arquivo <> "" THEN DO:
    view /*stream str-rp*/ frame f-cabec.
    view /*stream str-rp*/ frame f-rodape.
END.

run utp/ut-acomp.p persistent set h-acomp.
run pi-inicializar in h-acomp (input "Importando Arquivo").

for first param-global fields (empresa-prin) no-lock: end.
for first mgadm.empresa fields (razao-social) no-lock where
     empresa.ep-codigo = param-global.empresa-prin: end.
assign c-empresa = mgadm.empresa.razao-social.

for first param-estoq no-lock:
    assign d-dt-ini = param-estoq.ult-fech-dia + 1.
end.

/* inicio tratamento DIVs */
put /*stream str-rp*/ "Lendo DIVs" skip(1).
empty temp-table tt-movto.
for each movto-estoq no-lock where
    movto-estoq.dt-trans >= d-dt-ini and
    movto-estoq.esp-docto = 6 and
    movto-estoq.cod-estabel = "973":

    run pi-acompanhar in h-acomp (input "Lendo DIV: " + string(movto-estoq.nr-trans)).

    create  tt-movto.
    buffer-copy movto-estoq to tt-movto.

    /*
    display /*stream str-rp */
        movto-estoq.serie-docto
        movto-estoq.nro-docto
        movto-estoq.it-codigo
        movto-estoq.quantidade
        movto-estoq.valor-mat-m[1]
        with width 550 stream-io.
        */

end.

put /*stream str-rp*/ "Processando DIV" skip(1).
for each tt-movto no-lock 
    break by tt-movto.it-codigo:

    if first-of (tt-movto.it-codigo) then do:

        run pi-acompanhar in h-acomp (input "Calculando: " + string(tt-movto.it-codigo)).

        run pi-processa-movtos(tt-movto.it-codigo). 
        RUN intprg/int999.p ("PRECOBASE", 
                             "DIV" + "/" +
                             trim(string(tt-movto.nr-trans)) + "/" +
                             trim(string(year(tt-movto.dt-trans),"9999")) + 
                             trim(string(month(tt-movto.dt-trans),"99")) +
                             trim(string(day(tt-movto.dt-trans),"99"))+ "/" +
                             trim(string(tt-movto.it-codigo)),
                             "Calculo efetuado",
                             2, /* 1 - Pendente, 2 - Processado */ 
                             c-seg-usuario,
                             "INT570RP.P").
    end.
end. /* tt-movto */
/* final tratament DIVs */


/* inicio tratamento NFe */
put /*stream str-rp*/ "Lendo Documentos" skip(1).
empty temp-table tt-docto.
for each cst_docum_est_custo no-lock where cst_docum_est_custo.situacao = 1:

    /*
    display /*stream str-rp */
        cst_docum_est_custo.serie_docto
        cst_docum_est_custo.nro_docto
        cst_docum_est_custo.cod_emitente
        cst_docum_est_custo.nat_operacao
        with width 550  stream-io.
    */

    run pi-acompanhar in h-acomp (input "Lendo NFE: " + string(cst_docum_est_custo.cod_emitente) + "/" + 
                                  cst_docum_est_custo.serie_docto + "/" + cst_docum_est_custo.nro_docto).

    create  tt-docto.
    buffer-copy cst_docum_est_custo to tt-docto
        assign tt-docto.r-rowid = rowid(cst_docum_est_custo).
end.

put /*stream str-rp*/ skip(1) "Processando Documentos" skip(2).
for each tt-docto no-lock where tt-docto.tipo_movto < 3
    break by tt-docto.serie_docto  
            by tt-docto.Nro_docto    
              by tt-docto.cod_emitente 
                by tt-docto.nat_operacao:

    if first-of (tt-docto.nat_operacao) then
    for each docum-est fields (serie-docto nro-docto cod-emitente dt-trans 
                               nat-operacao)  
        no-lock where
        docum-est.serie-docto   = tt-docto.serie_docto  and
        docum-est.nro-docto     = tt-docto.nro_docto    and
        docum-est.cod-emitente  = tt-docto.cod_emitente and
        docum-est.nat-operacao  = tt-docto.nat_operacao:

        /*
        display /*stream str-rp */
            docum-est.nro-docto
            docum-est.serie-docto
            docum-est.cod-emitente
            docum-est.nat-operacao
            with width 550 stream-io.
        */

        for each item-doc-est fields (it-codigo) of docum-est no-lock:
            /*
            display /*stream str-rp */
                item-doc-est.sequencia
                item-doc-est.it-codigo
                item-doc-est.quantidade
                with width 550 stream-io.
            */


            /* pular itens j  processados pela DIV ou NFT */
            if can-find (first tt-movto where 
                         tt-movto.it-codigo = item-doc-est.it-codigo) then next.
            else do:
                create tt-movto.
                assign tt-movto.it-codigo = item-doc-est.it-codigo.
            end.

            run pi-acompanhar in h-acomp (input "Calculando: " + item-doc-est.it-codigo).

            run pi-processa-movtos(item-doc-est.it-codigo).
        end. /* item-doc-est */
        RUN intprg/int999.p ("PRECOBASE", 
                             docum-est.serie-docto + "/" + 
                             trim(docum-est.nro-docto) + "/" +                
                             trim(string(docum-est.cod-emitente)) + "/" +  
                             trim(string(docum-est.nat-operacao)),
                             "Calculo efetuado",
                             2, /* 1 - Pendente, 2 - Processado */ 
                             c-seg-usuario,
                             "INT570RP.P").

    end. /* docum-est */

    for each btt-docto where
        btt-docto.serie_docto   = tt-docto.serie_docto  and
        btt-docto.nro_docto     = tt-docto.nro_docto    and
        btt-docto.cod_emitente  = tt-docto.cod_emitente and
        btt-docto.nat_operacao  = tt-docto.nat_operacao:

        find cst_docum_est_custo EXCLUSIVE-LOCK where
            rowid(cst_docum_est_custo) = btt-docto.r-rowid no-wait.
        if avail cst_docum_est_custo then do:
            assign cst_docum_est_custo.situacao = 2.
        end.

    end.
end. /* tt-docto */
/* fim tratamento NFE */


/* inicio tratamento NFT */
put /*stream str-rp*/ "Lendo Transferencias" skip(1).
empty temp-table tt-nota.
for each cst_nota_fiscal_custo no-lock where cst_nota_fiscal_custo.situacao = 1:

    /*
    display /*stream str-rp */
        cst_nota_fiscal_custo.cod_estabel
        cst_nota_fiscal_custo.serie
        cst_nota_fiscal_custo.nr_nota_fis
        with width 550  stream-io.
    */

    run pi-acompanhar in h-acomp (input "Lendo NFT: " + cst_nota_fiscal_custo.cod_estabel + "/" + 
                                  cst_nota_fiscal_custo.serie + "/" + cst_nota_fiscal_custo.nr_nota_fis).

    create  tt-nota.
    buffer-copy cst_nota_fiscal_custo to tt-nota
        assign tt-nota.r-rowid = rowid(cst_nota_fiscal_custo).
end.

put /*stream str-rp*/ skip(1) "Processando NFTs" skip(2).
for each tt-nota no-lock where tt-nota.tipo_movto < 3
    break by tt-nota.cod_estabel
            by tt-nota.serie
              by tt-nota.nr_nota_fis:

    if first-of (tt-nota.nr_nota_fis) then
    for each nota-fiscal 
        fields (serie nr-nota-fis cod-emitente 
                dt-emis-nota nat-operacao cod-estabel)  
        no-lock where
        nota-fiscal.serie        = tt-nota.serie        and
        nota-fiscal.nr-nota-fis  = tt-nota.nr_nota_fis  and
        nota-fiscal.cod-estabel  = tt-nota.cod_estabel:

        for each it-nota-fisc fields (it-codigo) of nota-fiscal no-lock:

            /* pular itens j  processados pela DIV ou NFT */
            if can-find (first tt-movto where 
                         tt-movto.it-codigo = it-nota-fisc.it-codigo) then next.
            else do:
                create tt-movto.
                assign tt-movto.it-codigo = it-nota-fisc.it-codigo.
            end.

            run pi-acompanhar in h-acomp (input "Calculando: " + it-nota-fisc.it-codigo).

            run pi-processa-movtos(it-nota-fisc.it-codigo).
        end. /* it-nota-fisc */
        RUN intprg/int999.p ("PRECOBASE", 
                             nota-fiscal.cod-estabel + "/" +  
                             nota-fiscal.serie + "/" + 
                             trim(nota-fiscal.nr-nota-fis),
                             "Calculo efetuado",
                             2, /* 1 - Pendente, 2 - Processado */ 
                             c-seg-usuario,
                             "INT570RP.P").

    end. /* nota-fiscal */

    for each btt-nota where
        btt-nota.serie        = tt-nota.serie       and
        btt-nota.nr_nota_fis  = tt-nota.nr_nota_fis and
        btt-nota.cod_estabel  = tt-nota.cod_estabel:

        find cst_nota_fiscal_custo EXCLUSIVE-LOCK where
            rowid(cst_nota_fiscal_custo) = btt-nota.r-rowid no-wait.
        if avail cst_nota_fiscal_custo then do:
            assign cst_nota_fiscal_custo.situacao = 2.
        end.

    end.
end. /* tt-nota */
/* fim tratamento NFe */

/* fechamento do output do relat¢rio  */
IF tt-param.arquivo <> "" THEN DO:

    {include/i-rpclo.i /*&STREAM="stream str-rp"*/}
END.

RUN intprg/int888.p (INPUT "PRECOBASE",
                     INPUT "INT570RP.P").

run pi-finalizar in h-acomp.

empty temp-table tt-docto.
empty temp-table tt-nota.
empty temp-table tt-movto.


return "OK":U.


procedure pi-processa-movtos:

    define input parameter p-it-codigo as char no-undo.

    for each saldo-estoq fields (cod-estabel cod-depos 
                                 cod-refer it-codigo 
                                 qtidade-atu qtidade-ini
                                 cod-localiz cod-refer lote) 
        no-lock where 
        saldo-estoq.cod-estabel = "973" and
        saldo-estoq.cod-depos = "973" and
        saldo-estoq.it-codigo = p-it-codigo and
        saldo-estoq.cod-refer = "" and
        saldo-estoq.cod-localiz = "" and
        saldo-estoq.lote = "":

        /*
        display /*stream str-rp */
            saldo-estoq.cod-refer saldo-estoq.cod-localiz saldo-estoq.lote
            with stream-io.
        */

        de-qtde = saldo-estoq.qtidade-ini.
        for each item-estab no-lock where 
            item-estab.it-codigo = saldo-estoq.it-codigo and
            item-estab.cod-estabel = saldo-estoq.cod-estabel:
            assign de-valor-ini = item-estab.val-unit-mat-m[1] + 
                                  item-estab.val-unit-mob-m[1] + 
                                  item-estab.val-unit-ggf-m[1].
        end.
        assign de-valor = de-valor-ini * de-qtde.


        display /*stream str-rp */
            saldo-estoq.cod-estabel
            saldo-estoq.cod-depos
            saldo-estoq.it-codigo
            saldo-estoq.qtidade-atu format "->>,>>>,>>>,>>9.99"
            saldo-estoq.qtidade-ini format "->>,>>>,>>>,>>9.99"
            de-valor                format "->>,>>>,>>>,>>9.99" column-label "Total"
            de-valor-ini            format "->>,>>>,>>>,>>9.99" column-label "Unit"
            with width 550 stream-io.


        /*display /*stream str-rp*/ de-valor-ini de-valor de-qtde with width 550 stream-io.*/

        for each movto-estoq fields (cod-estabel cod-depos dt-trans it-codigo 
                                     esp-docto tipo-trans valor-mat-m[1]
                                     valor-ggf-m[1] valor-mob-m[1] valor-nota
                                     cod-emitente serie-docto nro-docto 
                                     nat-operacao nr-trans quantidade) 
            use-index item-data no-lock where 
            movto-estoq.it-codigo   = saldo-estoq.it-codigo and
            movto-estoq.cod-estabel = saldo-estoq.cod-estabel and
            movto-estoq.dt-trans   >= d-dt-ini and
            movto-estoq.cod-depos   = saldo-estoq.cod-depos /* decidir se inclui */:
            
            if  movto-estoq.esp-docto = 23 /* NFT */  or
                movto-estoq.esp-docto = 21 /* NFE */  or 
                movto-estoq.esp-docto = 06 /* DIV */  or
                movto-estoq.esp-docto = 20 /* NFD */
            then do:

                if movto-estoq.esp-docto = 20 and movto-estoq.tipo-trans = 1 then next.

                display /*stream str-rp*/
                    {ininc/i03in218.i 4 movto-estoq.esp-docto} format "X(3)" column-label "Esp"
                    {ininc/i01in218.i 4 movto-estoq.tipo-trans} format "X(7)" column-label "Tp"
                    movto-estoq.cod-emitente
                    movto-estoq.serie-docto
                    movto-estoq.nro-docto
                    movto-estoq.nat-operacao
                    movto-estoq.nr-trans
                    movto-estoq.it-codigo
                    movto-estoq.quantidade format "->>,>>>,>>>,>>9.99"
                    movto-estoq.it-codigo
                    movto-estoq.valor-mat-m[1] format "->>>,>>>,>>>,>>9.99"
                    movto-estoq.valor-nota
                    with width 550 stream-io.

                if movto-estoq.tipo-trans = 1 /* entrada */ then do:
                    assign  de-qtde  = de-qtde  +  movto-estoq.quantidade.

                    if (movto-estoq.valor-mat-m[1] + movto-estoq.valor-mob-m[1] + movto-estoq.valor-ggf-m[1]) > 0 then
                        assign de-valor = de-valor + (movto-estoq.valor-mat-m[1] + 
                                                      movto-estoq.valor-mob-m[1] + 
                                                      movto-estoq.valor-ggf-m[1]).
                    else if movto-estoq.valor-nota > 0 then
                        assign de-valor = de-valor + (movto-estoq.valor-nota).
                    else if movto-estoq.quantidade > 0 then
                        assign de-valor = de-valor + (movto-estoq.quantidade * de-valor-ini).
                end.
                if movto-estoq.tipo-trans = 2 /* saida */ then do:
                    assign  de-qtde  = de-qtde  -  movto-estoq.quantidade.
                    if (movto-estoq.valor-mat-m[1] + movto-estoq.valor-mob-m[1] + movto-estoq.valor-ggf-m[1]) > 0 then
                        assign de-valor = de-valor - (movto-estoq.valor-mat-m[1] + 
                                                      movto-estoq.valor-mob-m[1] + 
                                                      movto-estoq.valor-ggf-m[1]).
                    else if movto-estoq.valor-nota > 0 then
                        assign de-valor = de-valor - (movto-estoq.valor-nota).
                    else if movto-estoq.quantidade > 0 then
                        assign de-valor = de-valor - (movto-estoq.quantidade * de-valor-ini).

                end.
                display /*stream str-rp */
                    de-valor column-label "Vlr Sdo"
                    de-qtde  column-label "Qtde Sdo"
                    de-valor / de-qtde  column-label "Preco"
                    with stream-io.

            end. /* if esp-docto... */
        end. /* movto-estoq */

        for each item-uni-estab exclusive-lock where 
            item-uni-estab.it-codigo = saldo-estoq.it-codigo and
            item-uni-estab.cod-estabel = saldo-estoq.cod-estabel:
            if de-qtde > 0 and de-valor > 0 then
                assign de-valor-ini = de-valor / de-qtde.
            if item-uni-estab.preco-base <> de-valor-ini and de-valor-ini > 0 then
                assign  item-uni-estab.preco-base = de-valor-ini
                        item-uni-estab.data-base  = today.

            /*
            display /*stream str-rp*/
                item-uni-estab.preco-base format "->>>,>>>,>>>,>>9.99"
                item-uni-estab.data-base
                with stream-io.
            */

        end.
    end. /* saldo-estoq */

end.
