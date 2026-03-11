
/********************************************************************************
** Programa: INT020 - Geracao notas fiscais a partir de Cupom Fiscal PRS
**
** Versao : 12 - 20/03/2016 - Alessandro V Baccin
**
********************************************************************************/
/* include de controle de versao */
{include/i-prgvrs.i INT020RP 2.12.01.AVB}

/* defini»ao das temp-tables para recebimento de parametros */
def temp-table tt-param no-undo
    field destino          as integer
    field arquivo          as char format "x(35)"
    field usuario          as char format "x(12)"
    field data-exec        as date
    field hora-exec        as integer
    field classifica       as integer
    field desc-classifica  as char format "x(40)".

def temp-table tt-raw-digita
        field raw-digita	as raw.

def temp-table tt-cst_nota_fiscal like cst_nota_fiscal.
def temp-table tt-int_ds_nota_loja_cartao like int_ds_nota_loja_cartao
    field cod-esp       like fat-duplic.cod-esp
    field cod-vencto    like fat-duplic.cod-vencto
    field cod-cond-pag  like nota-fiscal.cod-cond-pag
    field cod-portador  like nota-fiscal.cod-portador
    field modalidade    like nota-fiscal.modalidade.


{cdp/cd4305.i1}  /* Definicao da temp-table tt-docto e tt-it-doc            */
{cdp/cd4314.i2}  /* Definicao da temp-table tt-nota-trans                   */
{cdp/cd4401.i3}  /* Definicao da temp-table tt-saldo-estoq                  */
{cdp/cd4313.i1}  /* Def da temp-table tt-cond-pag e tt-fat-duplic           */
{cdp/cd4313.i4}  /* Def da temp-table tt-rateio-it-duplic                   */
{ftp/ft2070.i1}  /* Definicao da temp-table tt-fat-repre                    */
{ftp/ft2073.i1}  /* Definicao das temp-tables tt-nota-embal e tt-item-embal */
{ftp/ft2010.i1}  /* Definicao da temp-table tt-notas-geradas                */
{ftp/ft2015.i}   /* Temp-table tt-docto-bn e tt-it-docto-bn                 */
{cdp/cd4305.i2}  /* Temp-table tt-it-nota-doc                               */
{ftp/ft2015.i2}  /* Temp-table tt-desp-nota-fisc                            */

/* temp-tables das API's e BO's */
{method/dbotterr.i}

/* recebimento de parametros */
def input parameter raw-param as raw no-undo.
def input parameter table for tt-raw-digita.  

create tt-param.                    
raw-transfer raw-param to tt-param. 

/* include padrao para variÿveis de relat½rio  */
{include/i-rpvar.i}

/* ++++++++++++++++++ (Definicao Stream) ++++++++++++++++++ */

/* ++++++++++++++++++ (Definicao Buffer) ++++++++++++++++++ */
define buffer bemitente for emitente.

/* defini»ao de variÿveis  */
def var h-acomp             as handle no-undo.
def var l-proc-ok-aux       as log    no-undo.
def var i-seq-wt-docto      as int    no-undo.
def var i-seq-wt-it-docto   as int    no-undo.
def var c-num-nota          like ped-venda.nr-pedcli.
def var i-cod-emitente       like emitente.cod-emitente.
def var i-cod-rep            as integer.
def var i-cod-cond-pag       as integer.
def var c-nr-cupom          as char.
def var c-it-codigo          as char.
def var de-quantidade        as decimal.
def var c-natur              like ped-venda.nat-operacao.
def var c-nat-devol          like ped-venda.nat-operacao.
def var de-vl-uni            as dec format "999.999".
def var de-desconto          as decimal no-undo.
def var i-tab-finan          as integer.
def var i-indice             as integer.
def var de-aliquota-ipi      as decimal.
def var de-vl-tot-dup        like ped-venda.vl-tot-ped.
def var de-vl-tot-cup        like ped-venda.vl-tot-ped.
def var de-vl-liq-abe        like ped-venda.vl-tot-ped.
def var de-vl-liq            like ped-venda.vl-tot-ped.
def var i-canal-vendas       as integer.
def var i-nr-registro        as integer init 0.
def var c-informacao         as char format "x(90)".
def var i-erro               as integer init 0.
def var l-cupom-com-erro    as logical init no no-undo.
def var d-dt-emissao         as date.
def var d-dt-implantacao     as date.
def var i-nr-sequencia       as integer.
def var c-nome-repres        as character.
def var c-numero-lote        as character.
def var tb-erro              as char format "x(50)" extent 40 init
                             ["01. Faturado com Sucesso                          ",
                              "02. Cliente nao Cadastrado                        ",
                              "03. Tabela de preco nao Cadastrada                ",
                              "04. Tabela de preco fora do limite                ",
                              "05. Tabela de preco inativa                       ",
                              "06. Data Emissao invalida                         ",
                              "07. Data Entrega invalida                         ",
                              "08. Data Implantacao invalida                     ",
                              "09. Produto nao Cadastrado                        ",
                              "10. Produto esta obsoleto                         ",
                              "11. Produto nao disponivel para venda             ",
                              "12. Quantidade invalida                           ",
                              "13. Representante nao Cadastrado                  ",
                              "14. Cliente nao eh do Representante               ",
                              "15. Condicao de Pagamento Nao Cadastrada          ",
                              "16. Transportador Nao Cadastrado                  ",
                              "17. Numero do Pedido interno invalido             ",
                              "18. Documento a ser devolvido nÊo existe          ",
                              "19. Serie deve ter tipo de emissao MANUAL         ",
                              "20. *** Cupom nao Importado ***                    ",
                              "21. Natureza de Operacao nao Cadastrada em INT018 ",
                              "22. ERRO BO de Calculo                            ",
                              "23. Transportador de redespachop NAO Cadastrado   ",
                              "24. Codigo do Cliente p/ Entrega NAO Existe       ",
                              "25. Quantidade de parcelas p/ pagto inconsistente ",
                              "26. Cliente so pode comprar A Vista               ",
                              "27. Cliente esta Suspenso                         ",
                              "28. Nat de Operacao de Devolucao exige nota origem",
                              "29. Nota Origem informada e Nat. Oper. Envio      ",
                              "30. Estabelecimento nao Cadastrado                ",
                              "31. Canal de vendas nao Cadastrado                ",
                              "32. Nat.Operacao indicada esta inativa            ",
                              "33. Saldo estoque insuficiente p/ envio do lote   ",
                              "34. Portador nao Cadastrado                       ",
                              "35. Tabela de Financiamento NAO Cadastrada        ",
                              "36. Serie nao cadastrada p/ estabelecimento       ",
                              "37. Cupom inconsistente ou sem itens              ",
                              "38. Valor do item zerado                          ",
                              "39. Dados do cartao debito/credito nao encontradas",
                              "40. Valor do cartao diferente do valor do CUPOM   "].

def var i-cont          as int init 0.
def var i-cont2         as int init 0.
def var de-red-base-icm as decimal no-undo.
def var de-red-base-ipi as decimal no-undo.
def var de-base-ipi     as decimal no-undo.
def var c-estado        as char no-undo. 
def var c-cidade        as char no-undo. 
def var c-cod-estabel   as char no-undo.
def var c-nome-abrev    as char no-undo.
def var c-class-fiscal  as char no-undo.
def var c-condipag      as char no-undo.
def var c-convenio      as char no-undo.
def var i-cod-portador  as integer no-undo.
def var i-modalidade    as integer no-undo.
def var i-cod-port-dinh as integer initial 99901 no-undo.
def var i-modalid-dinh  as integer initial 6 no-undo.
def var i-cond-pag-dinh as integer initial 1 no-undo.
def var c-serie         as char no-undo.
def var de-aliq-icms    as decimal no-undo.
def var de-base-icms    as decimal no-undo.
def var de-valor-icms   as decimal no-undo.
def var de-valor-dinh   as decimal no-undo.
def var de-valor-cartaod as decimal no-undo.
def var de-valor-cartaoc as decimal no-undo.
def var de-valor-vale    as decimal no-undo.
def var r-rowid          as rowid no-undo.
def var de-aux           as decimal no-undo.
def var l-saldo-neg      as logical no-undo.
def var i-seq-fat-duplic as integer no-undo.
def var c-cpf            as char no-undo.
def var i-tip-cob-desp   as integer no-undo.
def var c-cod-esp-princ  like fat-duplic.cod-esp no-undo.
def var i-cod-mensagem   like natur-oper.cod-mensagem no-undo.
{utp/ut-glob.i}

/* defini»ao de frames do relat½rio */
form i-nr-registro    column-label "Sequencia"
     tb-erro[1]       column-label "Mensagem"
     c-informacao     column-label "Conteudo"
     with no-box no-attr-space width 300
     down stream-io frame f-erro.

/* include com a defini»ao da frame de cabe»alho e rodap² */
/*{include/i-rpcab.i &stream="str-rp"}*/
{include/i-rpcab.i}
/* bloco principal do programa */

function OnlyNumbers returns char
    (p-char as char):

    def var i-ind as integer no-undo.
    def var c-aux as char no-undo.
    do i-ind = 1 to length (p-char):
        if lookup (substring(p-char,i-ind,1),"1,2,3,4,5,6,7,8,9,0") > 0 then
            assign c-aux = c-aux + substring(p-char,i-ind,1).
    end.
    return c-aux.
end.

find first tt-param no-lock no-error.
assign c-programa       = "INT020RP"
       c-versao         = "2.12"
       c-revisao        = ".01.AVB"
       c-empresa        = "* Nao Definido *"
       c-sistema        = "Faturamento"
       c-titulo-relat   = "Importa¯Êo de Notas Fiscais - Cupons - PRS".

/* ----- inicio do programa ----- */
for first param-global no-lock: end.
for mgadm.empresa fields (razao-social) where
    empresa.ep-codigo = param-global.empresa-prin no-lock: end.
assign c-empresa = mgadm.empresa.razao-social.

do:
   run utp/ut-acomp.p persistent set h-acomp.
   run pi-inicializar in h-acomp (input "Processando").

   /*{include/i-rpout.i &stream = "stream str-rp"}*/
   {include/i-rpout.i}
                         
   view /*stream str-rp*/ frame f-cabec.
   view /*stream str-rp*/ frame f-rodape.

   run pi-importa.

   pause 3 no-message.
end.
/* ----- fim do programa -------- */
run pi-elimina-tabelas.

RUN intprg/int888.p (INPUT "CUPOM",
                     INPUT "INT020RP.P").

run pi-finalizar in h-acomp.

/* fechamento do output do relatorio  */
/*{include/i-rpclo.i &stream="stream str-rp"}*/
{include/i-rpclo.i}

/* elimina BO's */
return "OK".

/* procedures */

procedure pi-elimina-tabelas.
   run pi-acompanhar in h-acomp (input "Eliminando Tabelas Temporarias").
   /* limpa temp-tables */
   empty temp-table tt-docto.
   empty temp-table tt-it-docto.
   empty temp-table tt-it-imposto.
   empty temp-table tt-saldo-estoq.
   empty temp-table tt-nota-trans.
   empty temp-table tt-fat-duplic.
   empty temp-table tt-fat-repre.
   empty temp-table tt-nota-embal.
   empty temp-table tt-item-embal.
   empty temp-table tt-cst_nota_fiscal. 
   empty temp-table tt-fat-duplic. 
   empty temp-table tt-int_ds_nota_loja_cartao. 
   empty temp-table tt-notas-geradas .
   empty temp-table RowErrors.   
end.        

procedure pi-importa:
    run pi-acompanhar in h-acomp (input "Lendo Cupons").
    
    i-nr-sequencia = 0.
    assign i-nr-registro    = 0.
    for each int_ds_nota_loja no-lock where 
        int_ds_nota_loja.situacao = 1 and
        int_ds_nota_loja.tipo_movto = 1 
        query-tuning(no-lookahead):
        
        run pi-acompanhar in h-acomp (input "Lendo Cupom: " + string(int_ds_nota_loja.num_nota)).
        assign  de-vl-tot-cup       = 0
                de-vl-liq           = 0
                l-cupom-com-erro    = no
                c-estado            = ""
                c-cidade            = ""
                c-condipag          = ""
                c-convenio          = ""
                i-cod-portador      = 0
                i-modalidade        = 0
                c-serie             = ""
                de-valor-dinh       = 0
                de-valor-cartaod    = 0
                de-valor-cartaoc    = 0
                de-valor-vale       = 0.

        assign  c-num-nota          = trim(string(int(int_ds_nota_loja.num_nota),">>>9999999"))
                d-dt-implantacao    = today
                d-dt-emissao        = int_ds_nota_loja.emissao
                de-valor-dinh       = int_ds_nota_loja.Valor_din_mov
                de-valor-cartaod    = int_ds_nota_loja.valor_cartaod
                de-valor-cartaoc    = int_ds_nota_loja.valor_cartaoc
                de-valor-vale       = int_ds_nota_loja.valor_vale
                c-condipag          = int_ds_nota_loja.condipag
                c-convenio          = int_ds_nota_loja.convenio
                c-serie             = int_ds_nota_loja.serie.

        assign i-nr-registro = i-nr-registro + 1.
        /* processa cupom atual */
        run valida-registro-cabecalho.

        assign  c-it-codigo         = ""
                de-quantidade       = 0
                de-vl-uni           = 0
                de-desconto         = 0
                c-class-fiscal      = ""
                l-saldo-neg         = no.

        if not l-cupom-com-erro then
        for each int_ds_nota_loja_item exclusive of int_ds_nota_loja
            query-tuning(no-lookahead)
            break by int_ds_nota_loja_item.num_nota
                    by int_ds_nota_loja_item.sequencia
                      by int_ds_nota_loja_item.produto:

            assign  c-it-codigo         = trim(string(int(int_ds_nota_loja_item.produto)))
                    de-quantidade       = int_ds_nota_loja_item.quantidade
                    de-vl-uni           = int_ds_nota_loja_item.preco_unit
                    de-vl-liq           = int_ds_nota_loja_item.preco_liqu
                    de-desconto         = /*int_ds_nota_loja_item.preco_unit - int_ds_nota_loja_item.preco_liqu*/ int_ds_nota_loja_item.desconto
                    c-numero-lote       = if trim(int_ds_nota_loja_item.lote) <> ? and
                                             trim(int_ds_nota_loja_item.lote) <> "?" then 
                                             trim(int_ds_nota_loja_item.lote) else ""
                    /*i-nr-sequencia      = int(int_ds_nota_loja_item.sequencia)*/
                    de-aliq-icms        = int_ds_nota_loja_item.aliq_icms
                    de-base-icms        = int_ds_nota_loja_item.base_icms
                    de-valor-icms       = if int_ds_nota_loja.valor_icms <> 0 
                                          then ((de-aliq-icms * de-base-icms) / 100)
                                          else 0.
                    /*
                    int_ds_nota_loja_item.trib_icms
                    int_ds_nota_loja_item.valortrib
                    int_ds_nota_loja_item.valortribestadual
                    */

            
            run valida-registro-item.        
            if l-cupom-com-erro then next.
            find first tt-docto where 
                tt-docto.cod-estabel = c-cod-estabel and
                tt-docto.serie       = c-serie and
                tt-docto.nr-nota     = c-num-nota no-error.
            if not avail tt-docto then do:
                run cria-tt-docto.
            end.
            run cria-tt-it-docto.
        end.
        for first tt-it-docto: end.
        if not l-cupom-com-erro and not avail tt-it-docto then do:
            assign i-erro = 37
                   c-informacao = c-serie + " - " + c-num-nota + " - " + string(int_ds_nota_loja.cnpj_filial)
                   l-cupom-com-erro = yes.
            run gera-log. 
        end.
        if not l-cupom-com-erro then run gera-duplicatas.
        else run apaga-registro-atual.
        if i-nr-registro mod 1000 = 0 then do:
            run importa-nota.
        end.
    end.
    run importa-nota.
end.

procedure gera-duplicatas:
    i-cont  = 0.
    i-cont2 = 0.
    de-vl-tot-dup = 0.
    if de-valor-dinh <> 0 and
       de-valor-dinh < de-vl-tot-cup then do:
        assign i-seq-fat-duplic = i-seq-fat-duplic + 1.
        assign i-cont  = i-cont + 1.
        create tt-fat-duplic.
        assign tt-fat-duplic.seq-tt-fat-duplic = i-seq-fat-duplic
               tt-fat-duplic.seq-tt-docto      = i-nr-registro
               tt-fat-duplic.cod-vencto        = 3 /* antecipacao */
               tt-fat-duplic.dt-venciment      = d-dt-emissao
               tt-fat-duplic.dt-desconto       = ? /*tt-fat-duplic.dt-venciment*/
               tt-fat-duplic.vl-desconto       = 0
               tt-fat-duplic.parcela           = trim(string(i-cont,">9"))
               tt-fat-duplic.vl-parcela        = de-valor-dinh
               tt-fat-duplic.vl-comis          = 0
               tt-fat-duplic.vl-acum-dup       = de-vl-tot-dup + tt-fat-duplic.vl-parcela
               tt-fat-duplic.cod-esp           = "DI".
        assign de-vl-tot-dup                   = de-vl-tot-dup + tt-fat-duplic.vl-parcela
               i-cont2                         = 1
               de-vl-tot-cup                   = de-vl-tot-cup - tt-fat-duplic.vl-parcela.
        create cst_fat_duplic.
        buffer-copy tt-fat-duplic to cst_fat_duplic
            assign cst_fat_duplic.cod_portador  = i-cod-port-dinh
                   cst_fat_duplic.modalidade    = i-modalid-dinh
                   cst_fat_duplic.cod_cond_pag  = i-cond-pag-dinh
                   cst_fat_duplic.condipag      = string(i-cond-pag-dinh,"99")
                   cst_fat_duplic.cod_estabel   = c-cod-estabel
                   cst_fat_duplic.serie         = c-serie
                   cst_fat_duplic.nr_fatura     = c-num-nota.
            assign cst_fat_duplic.adm_cartao    = ""
                   cst_fat_duplic.autorizacao   = ""
                   cst_fat_duplic.nsu_admin     = ""
                   cst_fat_duplic.nsu_numero    = ""
                   cst_fat_duplic.taxa_admin    = 0.

    end.
    if de-valor-cartaoc <> 0 or 
       de-valor-cartaod <> 0 or
       de-valor-vale    <> 0 then do:
        for each tt-int_ds_nota_loja_cartao no-lock where 
            tt-int_ds_nota_loja_cartao.cnpj_filial = int_ds_nota_loja.cnpj_filial and
            tt-int_ds_nota_loja_cartao.serie = int_ds_nota_loja.serie and
            tt-int_ds_nota_loja_cartao.num_nota = int_ds_nota_loja.num_nota
            query-tuning(no-lookahead):

            assign i-seq-fat-duplic = i-seq-fat-duplic + 1
                   i-cont           = i-cont + 1.
            create tt-fat-duplic.
            assign tt-fat-duplic.seq-tt-fat-duplic = i-seq-fat-duplic
                   tt-fat-duplic.seq-tt-docto      = i-nr-registro
                   tt-fat-duplic.cod-vencto        = tt-int_ds_nota_loja_cartao.cod-vencto
                   tt-fat-duplic.dt-venciment      = tt-int_ds_nota_loja_cartao.vencimento
                   tt-fat-duplic.dt-desconto       = ? 
                   tt-fat-duplic.vl-desconto       = 0
                   tt-fat-duplic.parcela           = trim(string(i-cont,">9"))
                   tt-fat-duplic.vl-parcela        = tt-int_ds_nota_loja_cartao.valor
                   tt-fat-duplic.vl-comis          = 0
                   tt-fat-duplic.vl-acum-dup       = de-vl-tot-dup + tt-fat-duplic.vl-parcela
                   tt-fat-duplic.cod-esp           = tt-int_ds_nota_loja_cartao.cod-esp.
            assign de-vl-tot-dup                   = de-vl-tot-dup + tt-fat-duplic.vl-parcela.
            create cst_fat_duplic.
            buffer-copy tt-fat-duplic to cst_fat_duplic
                assign cst_fat_duplic.cod_portador  = tt-int_ds_nota_loja_cartao.cod-portador
                       cst_fat_duplic.modalidade    = tt-int_ds_nota_loja_cartao.modalidade
                       cst_fat_duplic.cod_cond_pag  = tt-int_ds_nota_loja_cartao.cod-cond-pag
                       cst_fat_duplic.adm_cartao    = tt-int_ds_nota_loja_cartao.adm_cartao
                       cst_fat_duplic.autorizacao   = tt-int_ds_nota_loja_cartao.autorizacao
                       cst_fat_duplic.condipag      = tt-int_ds_nota_loja_cartao.condipag
                       cst_fat_duplic.nsu_admin     = substring(tt-int_ds_nota_loja_cartao.nsu_admin,1,10) /* retirar apos aumentado o campo */
                       cst_fat_duplic.nsu_numero    = substring(tt-int_ds_nota_loja_cartao.nsu_numero,1,10) /* retirar apos aumentado o campo */
                       cst_fat_duplic.taxa_admin    = tt-int_ds_nota_loja_cartao.taxa_admin
                       cst_fat_duplic.cod_estabel   = c-cod-estabel
                       cst_fat_duplic.serie         = c-serie
                       cst_fat_duplic.nr_fatura     = c-num-nota.
        end.
    end.
    else 
    for first cond-pagto fields (cod-cond-pag cod-vencto prazos per-pg-dup num-parcelas) no-lock where 
        cond-pagto.cod-cond-pag = i-cod-cond-pag:
        do i-cont = 1 to cond-pagto.num-parcelas:
            assign i-seq-fat-duplic = i-seq-fat-duplic + 1.
            create tt-fat-duplic.
            assign tt-fat-duplic.seq-tt-fat-duplic = i-seq-fat-duplic
                   tt-fat-duplic.seq-tt-docto      = i-nr-registro
                   tt-fat-duplic.cod-vencto        = cond-pagto.cod-vencto
                   tt-fat-duplic.dt-venciment      = d-dt-emissao + 
                                                     cond-pagto.prazos[i-cont]
                   tt-fat-duplic.dt-desconto       = ? 
                   tt-fat-duplic.vl-desconto       = 0
                   tt-fat-duplic.parcela           = trim(string(i-cont + i-cont2,">9"))
                   tt-fat-duplic.vl-parcela        = de-vl-tot-cup * per-pg-dup[i-cont] / 100
                   tt-fat-duplic.vl-comis          = 0
                   tt-fat-duplic.vl-acum-dup       = de-vl-tot-dup + tt-fat-duplic.vl-parcela
                   tt-fat-duplic.cod-esp           = c-cod-esp-princ.
            assign de-vl-tot-dup                   = de-vl-tot-dup + tt-fat-duplic.vl-parcela.
            create cst_fat_duplic.
            buffer-copy tt-fat-duplic to cst_fat_duplic
                assign cst_fat_duplic.cod_portador  = i-cod-portador
                       cst_fat_duplic.modalidade    = i-modalidade
                       cst_fat_duplic.cod_cond_pag  = cond-pagto.cod-cond-pag
                       cst_fat_duplic.condipag      = c-condipag
                       cst_fat_duplic.cod_estabel   = c-cod-estabel
                       cst_fat_duplic.serie         = c-serie
                       cst_fat_duplic.nr_fatura     = c-num-nota.
                assign cst_fat_duplic.adm_cartao    = ""
                       cst_fat_duplic.autorizacao   = ""
                       cst_fat_duplic.nsu_admin     = ""
                       cst_fat_duplic.nsu_numero    = ""
                       cst_fat_duplic.taxa_admin    = 0.
        end.
    end.

    create tt-fat-repre.
    assign tt-fat-repre.seq-tt-docto = i-nr-registro
           tt-fat-repre.sequencia    = 1
           tt-fat-repre.cod-rep      = i-cod-rep
           tt-fat-repre.nome-ab-rep  = c-nome-repres
           tt-fat-repre.perc-comis   = 0
           tt-fat-repre.comis-emis   = 0
           tt-fat-repre.vl-comis     = 0
           tt-fat-repre.vl-emis      = 0.

   if not can-find(first tt-fat-duplic where
                   tt-fat-duplic.seq-tt-docto = i-nr-registro) then do:
      run pi-erros-nota (input 15299, input trim(return-value)).
      return.
   end.

   /* eliminando cst_fat_duplic anterior, se houver */
   for each cst_fat_duplic exclusive where 
       cst_fat_duplic.cod_estabel = c-cod-estabel and
       cst_fat_duplic.serie       = c-serie and
       cst_fat_duplic.nr_fatura   = c-num-nota
       query-tuning(no-lookahead):
       delete cst_fat_duplic.
   end.
end.

procedure valida-registro-cabecalho.
    
    run pi-acompanhar in h-acomp (input "Validando cupom").
    
    assign c-cod-estabel = "".
    for first estabelec fields (cod-estabel estado cidade 
                                cep pais endereco bairro ep-codigo) 
        no-lock where 
        estabelec.cgc = int_ds_nota_loja.cnpj_filial: 
        assign c-cod-estabel = estabelec.cod-estabel
               c-estado      = estabelec.estado
               c-cidade      = estabelec.cidade.                                     
    end.
    if c-cod-estabel = "" then
    do:
       assign i-erro = 30
              c-informacao = c-serie + " - " + c-num-nota + " - " + string(int_ds_nota_loja.cnpj_filial)
              l-cupom-com-erro = yes.
       run gera-log. 
       return.
    end.
    
    assign  c-nome-abrev = if int_ds_nota_loja.valor_convenio <> 0 
                           then "CONSUMIDORCV" else "CONSUMIDOR"
            i-cod-emitente = 0
            i-canal-vendas = 0
            i-cod-rep      = 1.
    if int_ds_nota_loja.cnpjcpf_imp_cup <> ? AND 
       trim(OnlyNumbers(int_ds_nota_loja.cnpjcpf_imp_cup)) <> "" AND
       decimal(trim(OnlyNumbers(int_ds_nota_loja.cnpjcpf_imp_cup))) > 1000 then do:
        for first emitente fields (cod-emitente nome-abrev cod-canal-venda tip-cob-desp
                                   cod-rep ind-cre-cli identific pais estado cgc)
            no-lock where
            emitente.cgc = trim(OnlyNumbers(int_ds_nota_loja.cnpjcpf_imp_cup)):
            assign  c-nome-abrev   = emitente.nome-abrev
                    i-cod-emitente = emitente.cod-emitente
                    i-canal-vendas = emitente.cod-canal-venda
                    i-cod-rep      = if emitente.cod-rep <> 0 
                                     then emitente.cod-rep
                                     else i-cod-rep
                    c-cpf           = emitente.cgc
                    i-tip-cob-desp  = emitente.tip-cob-desp    .
        end.
        if not avail emitente then do:
            for first emitente fields (cod-emitente nome-abrev cod-canal-venda tip-cob-desp
                                       cod-rep ind-cre-cli identific pais estado cgc)
                no-lock where
                emitente.nome-abrev = c-nome-abrev:
                assign  c-nome-abrev   = emitente.nome-abrev
                        i-cod-emitente = emitente.cod-emitente
                        i-canal-vendas = emitente.cod-canal-venda
                        i-cod-rep      = if emitente.cod-rep <> 0 
                                         then emitente.cod-rep
                                         else i-cod-rep
                        c-cpf          = emitente.cgc
                        i-tip-cob-desp = emitente.tip-cob-desp    .
            end.
            /* temporario ara gerar notas de testes, retirar comentario e 
               for first anterior....
            assign i-erro = 2
                   c-informacao = c-serie + "/" + c-num-nota + " - " + 
                                  " CPF: " + 
                                  int_ds_nota_loja.cnpjcpf_imp_cup
                   l-cupom-com-erro = yes.
            run gera-log. 
            return.
            */
        end.
    end.
    else do:
        for first emitente fields (cod-emitente nome-abrev cod-canal-venda tip-cob-desp
                                   cod-rep ind-cre-cli identific pais estado cgc)
            no-lock where
            emitente.nome-abrev = c-nome-abrev:
            assign  c-nome-abrev   = emitente.nome-abrev
                    i-cod-emitente = emitente.cod-emitente
                    i-canal-vendas = emitente.cod-canal-venda
                    i-cod-rep      = if emitente.cod-rep <> 0 
                                     then emitente.cod-rep
                                     else i-cod-rep
                    c-cpf          = emitente.cgc
                    i-tip-cob-desp = emitente.tip-cob-desp    .
        end.
        if not avail emitente then do:
            assign i-erro = 2
                   c-informacao = c-serie + "/" + c-num-nota + " - " + 
                                  c-nome-abrev
                   l-cupom-com-erro = yes.
            run gera-log. 
            return.
        end.
    end.

        
    if emitente.ind-cre-cli = 4 then do:
        assign i-erro = 27
               c-informacao = c-serie + " - " + c-num-nota + " - " + string(i-cod-emitente)
               l-cupom-com-erro = yes.
        run gera-log. 
        return.
    end. 
    if emitente.identific = 2 then do:     /* Fornecedor */
        run pi-erros-nota (input 15143, input "Fornecedor").
        return.                                 
    end.

    if not can-find(unid-feder 
                    where unid-feder.pais   = emitente.pais 
                    and   unid-feder.estado = emitente.estado) then do:
       {utp/ut-table.i mguni unid-feder 1}              
       run pi-erros-nota (input 56, input trim(return-value)).
       return.
    end.      
    c-nome-repres  = "".
    if i-cod-rep <> 0 then do:
        for first repres fields (cod-rep nome-abrev) no-lock where 
            repres.cod-rep = i-cod-rep:
            assign c-nome-repres = repres.nome-abrev.
        end.
    end.
    if i-tab-finan = 0 then
      assign i-tab-finan = 1
             i-indice    = 0.
            
    if not can-find (first tab-finan no-lock where 
                    tab-finan.nr-tab-finan = i-tab-finan) then do:
      assign i-erro = 35
             c-informacao = c-num-nota + " - " + 
                            c-serie + " - " +
                            string(i-tab-finan)
             l-cupom-com-erro = yes.
      run gera-log. 
      return.
    end.                     
    
    if i-canal-vendas <> 0 then
    do:
       for first ems2dis.canal-venda fields (cod-canal-venda) no-lock where
           canal-venda.cod-canal-venda = i-canal-vendas: end.
       if not avail canal-venda then
       do:
          assign i-erro = 31
                 c-informacao = c-serie + " - " + c-num-nota + " - " +
                                string(i-canal-vendas) + " - " + string(i-cod-emitente)
                 l-cupom-com-erro = yes.
          run gera-log. 
          return.
       end.
    end.
    if de-valor-cartaod <> 0 or 
       de-valor-cartaoc <> 0 or 
       de-valor-vale    <> 0 then do:
        if not can-find(first int_ds_nota_loja_cartao no-lock where
            int_ds_nota_loja_cartao.cnpj_filial = int_ds_nota_loja.cnpj_filial and
            int_ds_nota_loja_cartao.serie = int_ds_nota_loja.serie and
            int_ds_nota_loja_cartao.num_nota = int_ds_nota_loja.num_nota) then do:
            assign i-erro = 39
                   c-informacao = c-serie + " - " + c-num-nota + " - " + int_ds_nota_loja.cnpj_filial + " - " + c-cod-estabel
                   l-cupom-com-erro = yes.
            run gera-log. 
            return.
        end.
        else do:
            assign de-aux = 0.
            for each int_ds_nota_loja_cartao no-lock where 
                int_ds_nota_loja_cartao.cnpj_filial = int_ds_nota_loja.cnpj_filial and
                int_ds_nota_loja_cartao.serie       = int_ds_nota_loja.serie and
                int_ds_nota_loja_cartao.num_nota    = int_ds_nota_loja.num_nota
                query-tuning(no-lookahead):
                de-aux = de-aux + int_ds_nota_loja_cartao.valor.
                create tt-int_ds_nota_loja_cartao.
                buffer-copy int_ds_nota_loja_cartao to tt-int_ds_nota_loja_cartao.

                /* determina natureza de operacao */
                run intprg/int018a.p (input trim(int_ds_nota_loja_cartao.condipag),
                                      input c-estado        ,
                                      input c-cidade        ,
                                      input c-cod-estabel   ,
                                      input c-convenio      ,
                                      input ?               ,
                                      output r-rowid).

                for first int_ds_loja_natur_oper no-lock where rowid(int_ds_loja_natur_oper) = r-rowid:
                    for first natur-oper fields (cod-esp)
                        no-lock where
                        natur-oper.nat-operacao = int_ds_loja_natur_oper.nat_operacao: 
                        assign tt-int_ds_nota_loja_cartao.cod-esp = natur-oper.cod-esp.
                    end.
                    for first cond-pagto fields (cod-vencto) no-lock where 
                        cond-pagto.cod-cond-pag = int_ds_loja_natur_oper.cod_cond_pag:
                        assign tt-int_ds_nota_loja_cartao.cod-vencto   = cond-pagto.cod-vencto
                               tt-int_ds_nota_loja_cartao.cod-cond-pag = int_ds_loja_natur_oper.cod_cond_pag.
                    end.
                    assign tt-int_ds_nota_loja_cartao.cod-portador  = int_ds_loja_natur_oper.cod_portador
                           tt-int_ds_nota_loja_cartao.modalidade    = int_ds_loja_natur_oper.modalidade.
                end.
                if not avail natur-oper then do:
                    assign i-erro = 21
                           c-informacao = c-num-nota    + " - " + 
                                          " "           + " - " + 
                                          trim(int_ds_nota_loja_cartao.condipag) + " - " + 
                                          c-estado      + " - " +   
                                          c-cidade      + " - " +   
                                          c-cod-estabel + " - " + 
                                          c-convenio    + " - " + 
                                          "?"
                           l-cupom-com-erro = yes.
                    run gera-log. 
                    return.
                end.
            end.
            if  de-aux <> (de-valor-cartaoc + de-valor-cartaod + de-valor-vale) then do:
                assign i-erro = 40
                       c-informacao = c-serie + " - " + c-num-nota + " - " + c-cod-estabel + " - " + 
                                      string(de-aux) + " - " + string(de-valor-cartaoc) + " - " + 
                                      string(de-valor-cartaod) + " - " + string(de-valor-vale)
                       l-cupom-com-erro = yes.
                run gera-log. 
                return.
            end.
        end.
    end.

end.
      
procedure valida-registro-item.

   run pi-acompanhar in h-acomp (input "Validando Itens").
   for first item 
        fields (class-fiscal ind-item-fat cod-obsoleto tipo-contr cd-trib-icm aliquota-ipi
                aliquota-iss cd-trib-ipi un ind-ipi-dife cod-localiz tipo-con-est perm-saldo-neg)
        no-lock where
        item.it-codigo = c-it-codigo:
        c-class-fiscal = item.class-fiscal.
        l-saldo-neg = item.perm-saldo-neg = 3.
   end.
   if not avail item then do:
      assign i-erro = 9
             c-informacao = c-serie + " - " + c-num-nota + " - " +
                            c-it-codigo 
             l-cupom-com-erro = yes.
      run gera-log. 
      return.
   end.
   if avail item and item.cod-obsoleto = 4 then do:
      assign i-erro = 10
             c-informacao = c-serie + " - " + c-num-nota + " - " +
                            c-it-codigo
             l-cupom-com-erro = yes.
      run gera-log. 
      return.
   end.     
   if avail item and not item.ind-item-fat then do:
      for first item exclusive-lock where
           item.it-codigo = c-it-codigo:
           item.ind-item-fat = yes.
      end.
      /*
      assign i-erro = 11
             c-informacao = c-num-nota + " - " + 
                            c-it-codigo
             l-cupom-com-erro = yes.
      run gera-log. 
      return.
      */
   end.     
   /***************** Classifica¯Êo Fiscal *******************************/
   if avail item and i-pais-impto-usuario = 1  /* Brasil */
   and not can-find(classif-fisc where 
                   classif-fisc.class-fiscal = item.class-fiscal) then do:
       {utp/ut-table.i mgind classif-fisc 1}  
       run pi-erros-nota (input 56, input trim(return-value) ).
       return.
   end.
   /**************** Item x Refer¬ncia ***********************************/
   if avail item and item.tipo-con-est = 4 then do:  /* Referencia */
      if not can-find(ref-item where
                      ref-item.it-codigo = tt-it-docto.it-codigo and
                      ref-item.cod-refer = tt-it-docto.cod-refer) then do:        
          {utp/ut-table.i mgind ref-item 1}                        
          run pi-erros-nota (input 56, input trim(return-value) ).
          return.
      end.
   end.

   if dec(de-quantidade) <= 0 then do:
      assign i-erro = 12
             c-informacao = c-serie + " - " + c-num-nota + " - " +
                            c-it-codigo + " - " + 
                            string(de-quantidade)
             l-cupom-com-erro = yes.
      run gera-log. 
      return.
   end. 
   
   /* determina natureza de operacao */
   run intprg/int018a.p (input c-condipag      ,
                         input c-estado        ,
                         input c-cidade        ,
                         input c-cod-estabel   ,
                         input c-convenio      ,
                         input c-class-fiscal  ,
                         output r-rowid).
   
   assign  c-natur         = ""
           i-cod-cond-pag  = ?
           i-cod-portador  = ?
           i-modalidade    = ?
           c-serie         = ""
           c-cod-esp-princ = "".
   for first int_ds_loja_natur_oper no-lock where rowid(int_ds_loja_natur_oper) = r-rowid:
       assign  c-natur        = int_ds_loja_natur_oper.nat_operacao 
               i-cod-cond-pag = int_ds_loja_natur_oper.cod_cond_pag 
               i-cod-portador = int_ds_loja_natur_oper.cod_portador
               i-modalidade   = int_ds_loja_natur_oper.modalidade
               c-serie        = int_ds_loja_natur_oper.serie.
               c-nat-devol    = int_ds_loja_natur_oper.nat_devol.
   end.
   
   i-cod-mensagem = 0.
   for first natur-oper 
       fields (nat-ativa nat-operacao emite-duplic tipo char-2 cod-esp log-ipi-bicms 
               terceiros cd-trib-icm cd-trib-ipi cod-mensagem 
               consum-final perc-red-ipi perc-red-icm )
       no-lock where
       natur-oper.nat-operacao = c-natur: 
       c-cod-esp-princ = natur-oper.cod-esp.
       i-cod-mensagem = natur-oper.cod-mensagem.
   end.

   if not avail natur-oper then do:
       assign i-erro = 21
              c-informacao = c-num-nota    + " - " + 
                             c-natur       + " - " + 
                             c-condipag    + " - " + 
                             c-estado      + " - " +   
                             c-cidade      + " - " +   
                             c-cod-estabel + " - " + 
                             c-convenio    + " - " + 
                             c-class-fiscal 
              l-cupom-com-erro = yes.
       run gera-log. 
       return.
   end.
   /*
   if avail natur-oper and 
      not natur-oper.nat-ativa then do:
       assign i-erro = 32  
              c-informacao = c-num-nota + " - " + 
                          c-natur
           l-cupom-com-erro = yes.
       run gera-log. 
       return.
   end.
   */

   /**************** Natureza nÊo pode ser de entrada ****************/
   if natur-oper.tipo = 1 then do:     /* Entrada */
      run pi-erros-nota (input 6028, input "Entrada").
      return.
   end.

    /*********** Natureza nÊo pode ser operacao com terceiros *********/
    if natur-oper.terceiros then do:     /* terceiro */
       run pi-erros-nota (input 15126, input "Terceiros").
       return.
    end.

    /********** Natureza de Opera¯Êo Inativa ***********************/
    if natur-oper.nat-ativa = no then do:
       run pi-erros-nota (input 26759, input "Inativa").
       return.
    end.

    /*************** C«digo da Mensagem ***********************************/

    if  natur-oper.cod-mensagem <> 0 
    and not can-find(mensagem where 
                     mensagem.cod-mensagem = natur-oper.cod-mensagem) then do:
        {utp/ut-table.i mgadm mensagem 1}    
        run pi-erros-nota (input 56, input trim(return-value) ).
        return.
    end.

   if i-cod-cond-pag <> 0
   then do:
      for first cond-pagto fields (cod-cond-pag nr-tab-finan nr-ind-finan)
          where cond-pagto.cod-cond-pag = i-cod-cond-pag
          no-lock: end.
      if not avail cond-pagto then do:
         assign i-erro = 15
                c-informacao = c-serie + " - " + c-num-nota + " - " +
                               string(i-cod-cond-pag)
                l-cupom-com-erro = yes.
         run gera-log. 
         return.
      end.
      else
          assign i-tab-finan = cond-pagto.nr-tab-finan
                 i-indice    = cond-pagto.nr-ind-finan.
   end.

   if i-cod-portador <> 0
   then do:
      for first mgadm.portador fields (cod-portador modalidade)
           no-lock where
           portador.ep-codigo    = estabelec.ep-codigo and
           portador.cod-portador = i-cod-portador and
           portador.modalidade   = i-modalidade: end.
      if not avail portador then do:
         assign i-erro = 34
                c-informacao = c-serie + " - " + c-num-nota + " - " +
                               string(i-cod-portador) + "/" + string(i-modalidade)
                l-cupom-com-erro = yes.
         run gera-log. 
         return.
      end.    
   end.

   if c-serie = ? then assign c-serie = trim(int_ds_nota_loja.serie).
   for first ser-estab exclusive-lock where
        ser-estab.serie = c-serie and
        ser-estab.cod-estabel = c-cod-estabel: end.
   if not avail ser-estab then do:
      assign i-erro = 36
             c-informacao = "Nr. Nota: " + c-num-nota + " - " + 
                            "S‚rie: " + c-serie + " - " + "Estab.: " + c-cod-estabel
             l-cupom-com-erro = yes.
      run gera-log. 
      return.
   end.    
   if avail ser-estab then do:
   
      if ser-estab.forma-emis = 1 /* automatica */ then do:
          assign i-erro = 19
                 c-informacao = c-num-nota + " - " + 
                                c-serie + " - "
                 l-cupom-com-erro = yes.
          run gera-log. 
          return.
      end.
      else do:
        assign ser-estab.dt-prox-fat = 01/01/0001
               ser-estab.dt-ult-fat  = 01/01/0001.
      end.
   end.

   for first serie fields (serie forma-emis ind-nff)
       no-lock where 
       serie.serie = c-serie:
       if serie.forma-emis = 1 /* Automatica */ then do:
           assign i-erro = 19
                  c-informacao = c-num-nota + " - " + 
                                 c-serie + " - "
                  l-cupom-com-erro = yes.
           run gera-log. 
           return.
       end.
   end.

   /**************** Nota Fiscal j˜ existe *********************************/
   if can-find(nota-fiscal
      where nota-fiscal.cod-estabel = c-cod-estabel
      and   nota-fiscal.serie       = c-serie
      and   nota-fiscal.nr-nota-fis = c-num-nota) then do:
       {utp/ut-table.i mgdis nota-fiscal 1}
       /*run pi-erros-nota (input 1, input trim(return-value)).*/
       run finaliza-cupom.
       return.
   end.

   if de-vl-uni = 0 then do:
        assign i-erro = 38
               c-informacao = c-serie + " - " + c-num-nota + " - " +
                              c-it-codigo
               l-cupom-com-erro = yes.
        run gera-log. 
        return.
   end.

end.
 
procedure cria-tt-docto.
    run pi-acompanhar in h-acomp (input "Criando Cupom").

    create tt-docto.
    assign tt-docto.fat-nota         = IF serie.ind-nff and int_ds_nota_loja.valor_convenio <> 0
                                       then 1 /* NFF */ else 2 /* nota */
           tt-docto.ind-tip-nota     = 11     /* Importada */
           tt-docto.nr-prog          = 2015
           tt-docto.seq-tt-docto     = i-nr-registro
           tt-docto.cod-des-merc     = 2 /* consumo */
           tt-docto.cod-estabel      = c-cod-estabel
           tt-docto.dt-nf-ent-fut    = ?
           tt-docto.nat-operacao     = c-natur
           tt-docto.cod-emitente     = i-cod-emitente
           tt-docto.nr-nota          = c-num-nota
           tt-docto.serie            = c-serie
           tt-docto.cgc              = c-cpf
           tt-docto.ins-estadual     = ""
           tt-docto.nome-abrev       = c-nome-abrev
           tt-docto.cod-emitente     = i-cod-emitente
           tt-docto.tip-cob-desp     = i-tip-cob-desp.

    assign tt-docto.estado         = estabelec.estado
           tt-docto.cep            = string(estabelec.cep)
           tt-docto.pais           = estabelec.pais
           tt-docto.endereco       = estabelec.endereco
           tt-docto.bairro         = estabelec.bairro
           tt-docto.cidade         = estabelec.cidade.
 
    assign tt-docto.perc-embalagem   = 0
           tt-docto.perc-frete       = 0
           tt-docto.perc-desco1      = 0
           tt-docto.perc-desco2      = 0
           tt-docto.perc-seguro      = 0
           tt-docto.peso-bru-tot     = 0
           tt-docto.peso-liq-tot     = 0
           tt-docto.vl-embalagem     = 0
           tt-docto.vl-frete         = 0
           tt-docto.vl-seguro        = 0
           tt-docto.cod-canal-venda  = 0
           tt-docto.cidade-cif       = ""
           tt-docto.cod-cond-pag     = i-cod-cond-pag
           tt-docto.cod-entrega      = ""
           tt-docto.dt-base-dup      = d-dt-emissao
           tt-docto.dt-emis-nota     = d-dt-emissao
           tt-docto.dt-prvenc        = d-dt-emissao
           tt-docto.marca-volume     = ""
           tt-docto.mo-codigo        = 0
           tt-docto.no-ab-reppri     = c-nome-repres
           tt-docto.nome-tr-red      = ""
           tt-docto.nome-transp      = "PADRAO"
           tt-docto.nr-fatura        = c-num-nota
           tt-docto.nr-tabpre        = ""
           tt-docto.nr-volumes       = ""
           tt-docto.placa            = ""
           tt-docto.serie-ent-fut    = ""
           tt-docto.nr-nota-ent-fut  = ""
           tt-docto.ind-lib-nota     = yes
           tt-docto.cod-rota         = ""
           tt-docto.cod-msg          = i-cod-mensagem
           tt-docto.vl-taxa-exp      = 0
           tt-docto.nr-proc-exp      = ""
           tt-docto.nr-tab-finan     = i-tab-finan
           tt-docto.nr-ind-finan     = i-indice
           tt-docto.cod-portador     = i-cod-portador
           tt-docto.modalidade       = i-modalidade
           tt-docto.nr-nota-base     = ""
           tt-docto.serie-base       = ""
           tt-docto.uf-placa         = ""
           tt-docto.dt-embarque      = ?
           tt-docto.serie-dif        = ""
           tt-docto.nr-nota-dif      = ""
           tt-docto.perc-acres-dif   = 0
           tt-docto.vl-acres-dif     = 0
           tt-docto.vl-taxa-exp-dif  = 0
           tt-docto.cond-redespa     = ""
           tt-docto.obs              = ""
           tt-docto.esp-docto        = 22 /* NFS */
           tt-docto.dt-cancela       = ?
           tt-docto.motvo-cance      = "".

    if int_ds_nota_loja.nfce_chave_s  /* chave acesso */ <> ? and
       int_ds_nota_loja.nfce_transmissao_s /* tipo transmissao*/  <> ? and
       int_ds_nota_loja.nfce_protocolo_s /* protocolo */ <> ? then do:
           assign overlay(tt-docto.char-1,112,60) = int_ds_nota_loja.nfce_chave_s  /* chave acesso */
                  overlay(tt-docto.char-1,172,2)  = "3"  /* situacao */
                  overlay(tt-docto.char-1,174,1)  = int_ds_nota_loja.nfce_transmissao_s /* tipo transmissao*/
                  overlay(tt-docto.char-1,175,15) = int_ds_nota_loja.nfce_protocolo_s. /* protocolo */ 
    end.
    /*
    Modalidade de Frete
    assign overlay(tt-docto.char-1,190,8) = TRIM(SUBSTR(c-linha,8863,8)) NO-ERROR.
    Fim Modalidade de Frete*/			     

    create tt-cst_nota_fiscal.
    assign tt-cst_nota_fiscal.cod_estabel       = c-cod-estabel
           tt-cst_nota_fiscal.serie             = c-serie
           tt-cst_nota_fiscal.nr_nota_fis       = c-num-nota
           tt-cst_nota_fiscal.condipag          = int_ds_nota_loja.condipag
           tt-cst_nota_fiscal.convenio          = int_ds_nota_loja.convenio
           tt-cst_nota_fiscal.cupom_ecf         = int_ds_nota_loja.cupom_ecf
           tt-cst_nota_fiscal.nfce_chave        = int_ds_nota_loja.nfce_chave_s
           tt-cst_nota_fiscal.valor_chq         = int_ds_nota_loja.valor_chq
           tt-cst_nota_fiscal.valor_chq_pre     = int_ds_nota_loja.valor_chq_pre
           tt-cst_nota_fiscal.valor_convenio    = int_ds_nota_loja.valor_convenio
           tt-cst_nota_fiscal.valor_dinheiro    = de-valor-dinh
           tt-cst_nota_fiscal.valor_ticket      = int_ds_nota_loja.valor_ticket
           tt-cst_nota_fiscal.valor_vale        = int_ds_nota_loja.valor_vale
           tt-cst_nota_fiscal.nfce_dt_transmissao   = int_ds_nota_loja.nfce_transmissao_d
           tt-cst_nota_fiscal.nfce_protocolo        = int_ds_nota_loja.nfce_protocolo_s
           tt-cst_nota_fiscal.nfce_transmissao      = int_ds_nota_loja.nfce_transmissao_s.
end.
 
procedure cria-tt-it-docto.

   define var i-cd-trib-ipi as integer no-undo.
   define var i-cd-trib-icm as integer no-undo.

   run pi-acompanhar in h-acomp (input "Criando Itens do Cupom").

   assign i-cd-trib-ipi = natur-oper.cd-trib-ipi.
   if i-cd-trib-ipi <> 2 /* Isento */ and 
      i-cd-trib-ipi <> 3 /* Outros */ then
        if item.cd-trib-ipi = 1 /* tributado */ or  
           item.cd-trib-ipi = 4 /* reduzido */ then
            assign i-cd-trib-ipi = item.cd-trib-ipi.

   assign de-red-base-ipi = 0 /* base normal */
          de-base-ipi = (de-vl-liq * de-quantidade). 
   if avail natur-oper and /* IPI SOBRE O BRUTO */
     substring(natur-oper.char-2,11,1) = "1" then
   do:
      de-base-ipi = (de-vl-uni * de-quantidade). 
   end.
   
   if i-cd-trib-ipi <> 2 and    /* isento */
      i-cd-trib-ipi <> 3 then do: /* outros */ 
      if i-cd-trib-ipi = 4 /* reduzido */ then
      do:
         assign de-red-base-ipi = natur-oper.perc-red-ipi.
                de-base-ipi = (de-vl-liq * de-quantidade) * 
                               (1 - (de-red-base-ipi / 100)).
      end. 
   end.
   else do: /* somente tributa se natureza = T/R e item = T/R */
      assign de-aliquota-ipi = 0.
   end.

   assign i-cd-trib-icm = natur-oper.cd-trib-icm.
   if i-cd-trib-icm <> 2 /* Isento */ and 
      i-cd-trib-icm <> 3 /* Outros */ then
        if item.cd-trib-icm = 1 /* tributado */ or  
           item.cd-trib-icm = 4 /* reduzido */ then
            assign i-cd-trib-icm = item.cd-trib-icm.

   assign de-red-base-icm = 0 /* base normal */
          de-base-icms = (de-vl-liq * de-quantidade). 

   if natur-oper.log-ipi-bicms or trim(substr(natur-oper.char-2,1,5)) = "1" then 
       assign de-base-icms = de-base-icms + it-nota-fisc.vl-ipi-it.
   
   if i-cd-trib-icm <> 2 and    /* isento */
      i-cd-trib-icm <> 3 then do: /* outros */ 
      if i-cd-trib-icm = 4 /* reduzido */ then
      do:
         assign de-red-base-icm = natur-oper.perc-red-icm.
                de-base-icms = (de-vl-liq * de-quantidade) * 
                               (1 - (de-red-base-icm / 100)).
      end. 
   end.
   else do: /* somente tributa se natureza = T/R e item = T/R */
      assign de-aliq-icms = 0.
   end.
   i-nr-sequencia = i-nr-sequencia + 1.
   create tt-it-docto.
   assign tt-it-docto.calcula             = yes
          tt-it-docto.tipo-atend          = 1   /* Total */
          tt-it-docto.seq-tt-it-docto     = i-nr-sequencia
          tt-it-docto.baixa-estoq         = yes
          tt-it-docto.class-fiscal        = item.class-fiscal
          tt-it-docto.cod-estabel         = c-cod-estabel
          tt-it-docto.cod-refer           = ""
          tt-it-docto.data-comp           = ?
          tt-it-docto.it-codigo           = c-it-codigo
          tt-it-docto.nat-comp            = ""
          tt-it-docto.nat-operacao        = c-natur
          tt-it-docto.nr-nota             = c-num-nota
          tt-it-docto.nr-sequencia        = i-nr-sequencia
          tt-it-docto.nro-comp            = ""
          tt-it-docto.per-des-item        = (de-desconto / de-vl-uni) * 100
          tt-it-docto.peso-liq-it-inf     = 0
          tt-it-docto.peso-embal-it       = 0
          tt-it-docto.quantidade[1]       = de-quantidade
          tt-it-docto.quantidade[2]       = 0
          tt-it-docto.seq-comp            = 0
          tt-it-docto.serie               = c-serie
          tt-it-docto.serie-comp          = ""
          tt-it-docto.un[1]               = item.un
          tt-it-docto.un[2]               = ""
          tt-it-docto.vl-despes-it        = 0
          tt-it-docto.vl-embalagem        = 0
          tt-it-docto.vl-frete            = 0
          tt-it-docto.vl-merc-liq         = de-vl-liq * de-quantidade
          tt-it-docto.vl-merc-ori         = de-vl-uni * de-quantidade
          tt-it-docto.vl-merc-tab         = de-vl-uni * de-quantidade
          tt-it-docto.vl-preori           = de-vl-uni
          tt-it-docto.vl-pretab           = de-vl-uni
          tt-it-docto.vl-preuni           = de-vl-liq
          tt-it-docto.vl-seguro           = 0
          tt-it-docto.vl-tot-item         = (de-vl-liq * de-quantidade) /*+ (de-base-ipi * (de-aliquota-ipi / 100))*/
          tt-it-docto.ind-imprenda        = no
          tt-it-docto.mercliq-moeda-forte = 0
          tt-it-docto.mercori-moeda-forte = 0
          tt-it-docto.merctab-moeda-forte = 0
          tt-it-docto.peso-bru-it-inf     = 0
          tt-it-docto.vl-taxa-exp         = 0
          tt-it-docto.vl-desconto         = de-desconto
          tt-it-docto.vl-desconto-perc    = 0.
   
   assign tt-docto.vl-mercad              = tt-docto.vl-mercad + tt-it-docto.vl-merc-liq.

   create tt-it-imposto.
   assign tt-it-imposto.seq-tt-it-docto   = i-nr-sequencia
          tt-it-imposto.aliquota-icm      = de-aliq-icms
          tt-it-imposto.aliquota-ipi      = de-aliquota-ipi
          tt-it-imposto.cd-trib-icm       = i-cd-trib-icm
          tt-it-imposto.cd-trib-iss       = 2 /* isento */
          tt-it-imposto.cod-servico       = 0
          tt-it-imposto.ind-icm-ret       = no
          tt-it-imposto.per-des-icms      = 0
          tt-it-imposto.perc-red-icm      = de-red-base-icm
          tt-it-imposto.perc-red-iss      = 0
          tt-it-imposto.vl-bicms-ent-fut  = 0
          tt-it-imposto.vl-bicms-it       = de-base-icms
          tt-it-imposto.vl-icms-it        = de-valor-icms
          tt-it-imposto.vl-icms-outras    = if i-cd-trib-icm = 3 then de-base-icms else                             
                                            if de-red-base-icm <> 0 then ((de-vl-liq * de-quantidade) - de-base-icms) 
                                            else 0                                                                 
          tt-it-imposto.vl-icmsou-it      = tt-it-imposto.vl-icms-outras
          tt-it-imposto.vl-icmsnt-it      = if i-cd-trib-icm = 2 then de-base-icms else 0
          tt-it-imposto.cd-trib-ipi       = i-cd-trib-ipi
          tt-it-imposto.perc-red-ipi      = de-red-base-ipi
          tt-it-imposto.vl-bipi-ent-fut   = 0
          tt-it-imposto.vl-ipi-ent-fut    = 0
          tt-it-imposto.vl-bipi-it        = if i-cd-trib-ipi = 1 or i-cd-trib-ipi = 4 then de-base-ipi else 0
          tt-it-imposto.vl-ipi-it         = de-base-ipi * (de-aliquota-ipi / 100)
          tt-it-imposto.vl-ipi-outras     = if i-cd-trib-ipi = 3 then de-base-ipi else 
                                            if de-red-base-ipi <> 0 then ((de-vl-liq * de-quantidade) - de-base-ipi)
                                            else 0
          tt-it-imposto.vl-ipiou-it       = tt-it-imposto.vl-ipi-outras
          tt-it-imposto.vl-ipint-it       = if i-cd-trib-ipi = 2 then de-base-ipi else 0.


   assign tt-it-imposto.vl-biss-it        = 0
          tt-it-imposto.vl-bsubs-ent-fut  = 0
          tt-it-imposto.vl-bsubs-it       = 0
          tt-it-imposto.icm-complem       = 0
          tt-it-imposto.vl-icms-ent-fut   = 0
          tt-it-imposto.vl-icmsub-ent-fut = 0
          tt-it-imposto.vl-icmsub-it      = 0
          tt-it-imposto.aliq-icm-comp     = 0
          tt-it-imposto.aliquota-iss      = 0
          tt-it-imposto.vl-irf-it         = 0
          tt-it-imposto.vl-iss-it         = 0
          tt-it-imposto.vl-issnt-it       = 0
          tt-it-imposto.vl-issou-it       = 0
          tt-it-docto.desconto-zf         = 0
          tt-it-docto.narrativa           = "".
          /*
          tt-it-docto.ct-cuscon = REPLACE(REPLACE(STRING(SUBSTR(c-linha,2970,20)),".",""),"-","")
          tt-it-docto.sc-cuscon = REPLACE(REPLACE(STRING(SUBSTR(c-linha,2990,20)),".",""),"-","")
          OVERLAY(tt-it-docto.char-2,175,14) = string(dec(substr(c-linha,3010,14)) / 100 )    /* vl-pis-st      */
          OVERLAY(tt-it-docto.char-2,189,15) = string(dec(substr(c-linha,3024,15)) / 100 )   /* base-pis-st    */
          OVERLAY(tt-it-docto.char-2,204,06) = string(dec(substr(c-linha,3039,6)) / 10000)   /* aliq-pis-st    */
          OVERLAY(tt-it-docto.char-2,210,14) = string(dec(substr(c-linha,3045,14)) / 100 )   /* vl-cofins-st   */
          OVERLAY(tt-it-docto.char-2,224,15) = string(dec(substr(c-linha,3059,15)) / 100 )   /* base-cofins-st */
          OVERLAY(tt-it-docto.char-2,239,06) = string(dec(substr(c-linha,3074,6)) / 10000).  /* aliq-cofins-st */
          */

   /* Unidade de Negocio */
   assign overlay(tt-it-docto.char-2,172,03) = "000"
          tt-it-imposto.vl-pauta             = 0.

   assign de-vl-tot-cup = de-vl-tot-cup + tt-it-docto.vl-merc-liq.

   for first saldo-estoq fields (dt-vali-lote) no-lock where 
       saldo-estoq.cod-estabel = c-cod-estabel and
       saldo-estoq.cod-depos   = "LOJ" and
       saldo-estoq.cod-localiz = "" and
       saldo-estoq.cod-refer   = "" and
       saldo-estoq.it-codigo   = c-it-codigo and
       saldo-estoq.lote        = c-numero-lote:
       create tt-saldo-estoq.
       assign tt-saldo-estoq.seq-tt-saldo-estoq = i-nr-sequencia
              tt-saldo-estoq.seq-tt-it-docto    = i-nr-sequencia
              tt-saldo-estoq.it-codigo          = c-it-codigo
              tt-saldo-estoq.cod-depos          = "LOJ"
              tt-saldo-estoq.cod-localiz        = ""
              tt-saldo-estoq.lote               = c-numero-lote
              tt-saldo-estoq.dt-vali-lote       = saldo-estoq.dt-vali-lote
              tt-saldo-estoq.quantidade         = de-quantidade
              tt-saldo-estoq.qtd-contada        = de-quantidade.
   end.
   if not avail saldo-estoq and l-saldo-neg then do:
       create tt-saldo-estoq.
       assign tt-saldo-estoq.seq-tt-saldo-estoq = i-nr-sequencia
              tt-saldo-estoq.seq-tt-it-docto    = i-nr-sequencia
              tt-saldo-estoq.it-codigo          = c-it-codigo
              tt-saldo-estoq.cod-depos          = "LOJ"
              tt-saldo-estoq.cod-localiz        = ""
              tt-saldo-estoq.lote               = c-numero-lote
              tt-saldo-estoq.dt-vali-lote       = if c-numero-lote <> "" 
                                                  then today else ?
              tt-saldo-estoq.quantidade         = de-quantidade
              tt-saldo-estoq.qtd-contada        = de-quantidade.
   end.
   /*************** Baixa do Estoque *************************************/
   if  tt-it-docto.baixa-estoq and 
   not can-find(first tt-saldo-estoq where
                tt-saldo-estoq.seq-tt-it-docto = tt-it-docto.seq-tt-it-docto) then do:
       run pi-erros-nota (input 26082, input trim(tt-it-docto.it-codigo)).
       return.
   end.

end.
 
procedure importa-nota.

    run pi-acompanhar in h-acomp (input "Gerando Nota").
    if  can-find (first tt-docto) and
        can-find (first tt-it-docto) then do:
        run ftp/ft2010.p (input  no,
                          output l-cupom-com-erro,
                          input  table tt-docto,
                          input  table tt-it-docto,
                          input  table tt-it-imposto,
                          input  table tt-nota-trans,
                          input  table tt-saldo-estoq,
                          input  table tt-fat-duplic,
                          input  table tt-fat-repre,
                          input  table tt-nota-embal,
                          input  table tt-item-embal,
                          input  table tt-it-docto-imp,
                          &IF DEFINED(bf_dis_desc_bonif) &THEN
                          input  table tt-docto-bn,
                          input  table tt-it-docto-bn,
                          &ENDIF
                          &IF DEFINED(bf_dis_unid_neg) &THEN
                          input table tt-rateio-it-duplic ,
                          &ENDIF
                          input-output table tt-notas-geradas
                          &IF DEFINED(bf_dis_ciap) &THEN ,
                          input table tt-it-nota-doc
                          &ENDIF ,
                          input table tt-desp-nota-fisc).                         
    end.
    for each tt-notas-geradas:
        for first nota-fiscal exclusive-lock where 
            rowid(nota-fiscal) = tt-notas-geradas.rw-nota-fiscal:
            run pi-acompanhar in h-acomp (input "Altera Duplicata: " + nota-fiscal.nr-nota-fis).

            for each cst_fat_duplic no-lock where 
                cst_fat_duplic.cod_estabel = nota-fiscal.cod-estabel and
                cst_fat_duplic.serie       = nota-fiscal.serie and
                cst_fat_duplic.nr_fatura   = nota-fiscal.nr-fatura:
                for each fat-duplic exclusive where 
                    fat-duplic.cod-estabel  = cst_fat_duplic.cod_estabel  and
                    fat-duplic.serie        = cst_fat_duplic.serie        and
                    fat-duplic.nr-fatura    = cst_fat_duplic.nr_fatura    and
                    fat-duplic.parcela      = cst_fat_duplic.parcela
                    query-tuning(no-lookahead):
                    assign fat-duplic.int-1 = cst_fat_duplic.cod_portador
                           fat-duplic.int-2 = cst_fat_duplic.modalidade.
                    /* nota - nao gera ACR */
                    if fat-duplic.cod-esp <> "CV" then 
                        assign fat-duplic.ind-fat-nota = 2.
                end.
            end.
            for first tt-cst_nota_fiscal no-lock where
                tt-cst_nota_fiscal.cod_estabel = nota-fiscal.cod-estabel and
                tt-cst_nota_fiscal.serie       = nota-fiscal.serie       and
                tt-cst_nota_fiscal.nr_nota_fis = nota-fiscal.nr-nota-fis:
                create cst_nota_fiscal.
                buffer-copy tt-cst_nota_fiscal to cst_nota_fiscal.
            end.
			for first estabelec fields (cgc) no-lock where 
				estabelec.cod-estabel = nota-fiscal.cod-estabel: 
				for each int_ds_nota_loja where
					int_ds_nota_loja.cnpj_filial = estabelec.cgc and
					/*int_ds_nota_loja.serie       = nota-fiscal.serie and*/
					int_ds_nota_loja.num_nota    = trim(string(int(nota-fiscal.nr-nota-fis),"999999")) and
					int_ds_nota_loja.emissao     = nota-fiscal.dt-emis-nota and
					int_ds_nota_loja.situacao    = 1
                    query-tuning(no-lookahead):
					assign i-erro       = 1
						   c-informacao = nota-fiscal.cod-estabel + "/" + nota-fiscal.serie + "/" + nota-fiscal.nr-nota-fis + "/" + nota-fiscal.nome-ab-cli.
					assign int_ds_nota_loja.situacao = 2 /* integrado */.
					run gera-log.
					release int_ds_nota_loja.
				end.
			end.
        end.
    end.
    
    /* verificando notas n’o importadas */
    for each tt-docto:
        if not can-find (first nota-fiscal no-lock where
                         tt-docto.cod-estabel = nota-fiscal.cod-estabel and
                         tt-docto.serie       = nota-fiscal.serie and
                         tt-docto.nr-nota     = nota-fiscal.nr-nota-fis) then do:
            for first estabelec fields (cgc) no-lock where 
                estabelec.cod-estabel = tt-docto.cod-estabel: 
                for first int_ds_nota_loja where
                    int_ds_nota_loja.cnpj_filial = estabelec.cgc and
                    /*int_ds_nota_loja.serie       = nota-fiscal.serie and*/ 
                    int_ds_nota_loja.num_nota    = trim(string(int(tt-docto.nr-nota),"999999")) and
                    int_ds_nota_loja.emissao     = tt-docto.dt-emis-nota and
                    int_ds_nota_loja.situacao    = 1:

                    run pi-acompanhar in h-acomp (input "Marcando N Integrada: " + tt-docto.nr-nota).
                    assign i-erro       = 22
                           c-informacao = tt-docto.cod-estabel
                                        + "/" +
                                        tt-docto.serie
                                        + "/" +
                                        tt-docto.nr-nota
                                        + "/" +
                                        tt-docto.nome-abrev
                                        + " Nota fiscal nÊo integrada" .
                    run gera-log.
                end.
            end.
            for each cst_fat_duplic exclusive-lock where 
                cst_fat_duplic.cod_estabel = tt-docto.cod-estabel and
                cst_fat_duplic.serie       = tt-docto.serie and
                cst_fat_duplic.nr_fatura   = tt-docto.nr-fatura
                query-tuning(no-lookahead):
                delete cst_fat_duplic.
            end.                
        end.
    end.
    
    run pi-elimina-tabelas.
end procedure.

procedure pi-erros-nota:
    define input parameter pcod-erro as integer.
    define input parameter pmensagem as character.

    &IF "{&bf_dis_versao_ems}":U >= "2.07":U &THEN
        for first cadast_msg fields (des_text_msg)
            no-lock where 
            cadast_msg.cdn_msg = pcod-erro: end.
        assign i-erro = 22
               c-informacao = trim(substring(c-cod-estabel + "/" + c-serie + "/" + c-num-nota + " - " + 
                              string(pcod-erro) + '-' +
                              replace(des_text_msg,"&1", pmensagem),1,400)).
               l-cupom-com-erro = yes.
        run gera-log. 
        return.
    &else
        for first Cad-msgs fields (Cad-msgs.texto-msg)
            no-lock where 
            Cad-msgs.cd-msg = pcod-erro: end.
        assign i-erro = 22
               c-informacao = trim(substring(c-cod-estabel + "/" + c-serie + "/" + c-num-nota + " - " + 
                              string(pcod-erro) + '-' +
                              replace(Cad-msgs.texto-msg,"$1", pmensagem),1,400)).
               l-cupom-com-erro = yes.
        run gera-log. 
        return.
    &endif
end.

procedure gera-log.

   run pi-acompanhar in h-acomp (input "Listando Erros").

   display /*stream str-rp*/
           i-nr-registro
           with frame f-erro. 
       
   display /*stream str-rp*/
           tb-erro[i-erro] @ tb-erro[1]
           c-informacao
           with frame f-erro.
   down /*stream str-rp*/
        with frame f-erro.

   run intprg/int999.p ("CUPOM", 
                        trim(int_ds_nota_loja.cnpj_filial + "/" + c-serie  + "/" + trim(string(int(c-num-nota),">>>9999999"))),
                        substring(trim(tb-erro[i-erro]) + " - " + c-informacao,1,500),
                        int_ds_nota_loja.situacao, /* 1 - Pendente, 2 - Processado */ 
                        c-seg-usuario,
                        "INT020RP.P").
   assign c-informacao = " ".
end.
/* FIM DO PROGRAMA */

procedure apaga-registro-atual:
    for first tt-docto where 
        tt-docto.cod-estabel = c-cod-estabel and
        tt-docto.serie       = c-serie       and
        tt-docto.nr-nota     = c-num-nota:
        for each tt-it-docto where
            tt-it-docto.cod-estabel = c-cod-estabel and
            tt-it-docto.serie       = c-serie       and
            tt-it-docto.nr-nota     = c-num-nota:
            for each tt-it-imposto where 
                tt-it-imposto.seq-tt-it-docto = tt-it-docto.seq-tt-it-docto:
                delete tt-it-imposto.
            end.
            for each tt-saldo-estoq where 
                tt-saldo-estoq.seq-tt-it-docto = tt-it-docto.seq-tt-it-docto:
                delete tt-saldo-estoq.
            end.
            delete tt-it-docto. 
        end.
        for each tt-fat-duplic where tt-fat-duplic.seq-tt-docto = tt-docto.seq-tt-docto:
            delete tt-fat-duplic.
        end.
        for each tt-fat-repre where tt-fat-repre.seq-tt-docto = tt-docto.seq-tt-docto:
            delete tt-fat-repre.
        end.
        for each tt-cst_nota_fiscal where 
            tt-cst_nota_fiscal.cod_estabel = c-cod-estabel and
            tt-cst_nota_fiscal.serie       = c-serie       and
            tt-cst_nota_fiscal.nr_nota     = c-num-nota:
            delete tt-cst_nota_fiscal.
        end.
        for each tt-int_ds_nota_loja_cartao no-lock where 
            tt-int_ds_nota_loja_cartao.cnpj_filial = int_ds_nota_loja.cnpj_filial and
            tt-int_ds_nota_loja_cartao.serie = int_ds_nota_loja.serie and
            tt-int_ds_nota_loja_cartao.num_nota = int_ds_nota_loja.num_nota:
            delete tt-int_ds_nota_loja_cartao.
        end.
        delete tt-docto.
    end.
end.

procedure finaliza-cupom.
   run pi-acompanhar in h-acomp (input "Finalizando cupom: " + trim(int_ds_nota_loja.num_nota)).
   find current int_ds_nota_loja exclusive-lock no-error.
   if avail int_ds_nota_loja then do:
       for first nota-fiscal fields (cod-estabel nr-fatura
                                    serie cod-cond-pag modalidade
                                    nr-nota-fis cod-portador)
         where nota-fiscal.cod-estabel = c-cod-estabel
         and   nota-fiscal.serie       = c-serie
         and   nota-fiscal.nr-nota-fis = c-num-nota
         no-lock:
    
           for each cst_fat_duplic no-lock where 
               cst_fat_duplic.cod_estabel = nota-fiscal.cod-estabel and
               cst_fat_duplic.serie       = nota-fiscal.serie and
               cst_fat_duplic.nr_fatura   = nota-fiscal.nr-fatura
               query-tuning(no-lookahead):
               for each fat-duplic exclusive where 
                   fat-duplic.cod-estabel  = cst_fat_duplic.cod_estabel  and
                   fat-duplic.serie        = cst_fat_duplic.serie        and
                   fat-duplic.nr-fatura    = cst_fat_duplic.nr_fatura    and
                   fat-duplic.parcela      = cst_fat_duplic.parcela
                   query-tuning(no-lookahead):
                   assign fat-duplic.int-1 = cst_fat_duplic.cod_portador
                          fat-duplic.int-2 = cst_fat_duplic.modalidade.
                   /* nota - nao gera ACR */
                   if fat-duplic.cod-esp <> "CV" then 
                       assign fat-duplic.ind-fat-nota = 2.
               end.
           end.
    
           for first cst_nota_fiscal WHERE
                     cst_nota_fiscal.cod_estabel = nota-fiscal.cod-estabel AND
                     cst_nota_fiscal.serie       = nota-fiscal.serie AND
                     cst_nota_fiscal.nr_nota_fis = nota-fiscal.nr-nota-fis exclusive-lock: end.
           if not avail cst_nota_fiscal then do:
               create cst_nota_fiscal.
               assign cst_nota_fiscal.cod_estabel       = nota-fiscal.cod-estabel
                      cst_nota_fiscal.serie             = nota-fiscal.serie
                      cst_nota_fiscal.nr_nota_fis       = nota-fiscal.nr-nota-fis.
               assign i-erro       = 1
                      c-informacao = c-cod-estabel + "/" + 
                                     c-serie + "/" + c-num-nota + "/" + c-nome-abrev.
               assign int_ds_nota_loja.situacao = 2 /* integrado */
                      l-cupom-com-erro = yes.
               run gera-log.
           end.
           assign cst_nota_fiscal.condipag            = int_ds_nota_loja.condipag
                  cst_nota_fiscal.convenio            = int_ds_nota_loja.convenio
                  cst_nota_fiscal.cupom_ecf           = int_ds_nota_loja.cupom_ecf
                  cst_nota_fiscal.nfce_chave          = int_ds_nota_loja.nfce_chave_s
                  cst_nota_fiscal.valor_chq           = int_ds_nota_loja.valor_chq
                  cst_nota_fiscal.valor_chq_pre       = int_ds_nota_loja.valor_chq_pre
                  cst_nota_fiscal.valor_convenio      = int_ds_nota_loja.valor_convenio
                  cst_nota_fiscal.valor_dinheiro      = int_ds_nota_loja.valor_din_mov
                  cst_nota_fiscal.valor_ticket        = int_ds_nota_loja.valor_ticket
                  cst_nota_fiscal.valor_vale          = int_ds_nota_loja.valor_vale
                  cst_nota_fiscal.valor_cartao        = int_ds_nota_loja.valor_cartaod + 
                                                        int_ds_nota_loja.valor_cartaoc
                  cst_nota_fiscal.nfce_dt_transmissao = int_ds_nota_loja.nfce_transmissao_d
                  cst_nota_fiscal.nfce_protocolo      = int_ds_nota_loja.nfce_protocolo_s
                  cst_nota_fiscal.nfce_transmissao    = int_ds_nota_loja.nfce_transmissao_s.
       end.
       release int_ds_nota_loja.
   end.
end.

