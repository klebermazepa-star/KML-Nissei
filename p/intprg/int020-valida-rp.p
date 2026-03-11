/********************************************************************************
** Programa: INT020-VALIDA-RP - Geracao notas fiscais a partir de Cupom Fiscal PRS
**
** Versao : 12 - 20/03/2016 - Alessandro V Baccin
**
********************************************************************************/
/* include de controle de versao */
{include/i-prgvrs.i INT020-VALIDA-RP 2.12.01.AVB}

/* defini‡ao das temp-tables para recebimento de parametros */
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

def temp-table tt-cst-nota-fiscal like cst-nota-fiscal.
def temp-table tt-int-ds-nota-loja-cartao like int-ds-nota-loja-cartao
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

/* include padrao para vari veis de relat¢rio  */
{include/i-rpvar.i}

/* ++++++++++++++++++ (Definicao Stream) ++++++++++++++++++ */

/* ++++++++++++++++++ (Definicao Buffer) ++++++++++++++++++ */
define buffer bemitente for emitente.

/* defini‡ao de vari veis  */
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
def var tb-erro              as char format "x(50)" extent 44 init
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
                              "15. Condicao de Pagamento NAO Cadastrada          ",
                              "16. Transportador Nao Cadastrado                  ",
                              "17. Numero do Pedido interno invalido             ",
                              "18. Documento a ser devolvido NAO existe          ",
                              "19. Serie deve ter tipo de emissao MANUAL         ",
                              "20. *** Cupom nao Importado ***                   ",
                              "21. Natureza de Operacao nao Cadastrada em CD0603 ",
                              "22. ERRO BO de Calculo                            ",
                              "23. Transportador de redespachop NAO Cadastrado   ",
                              "24. Codigo do Cliente p/ Entrega NAO Existe       ",
                              "25. Quantidade de parcelas p/ pagto inconsistente ",
                              "26. Cliente so pode comprar A Vista               ",
                              "27. Cliente esta Suspenso                         ",
                              "28. Nat de Operacao de Devolucao exige nota origem",
                              "29. Nota Origem informada e Nat. Oper. Envio      ",
                              "30. Estabelecimento nao Cadastrado ou Inv lido    ",
                              "31. Canal de vendas nao Cadastrado                ",
                              "32. Nat.Operacao indicada esta inativa            ",
                              "33. Saldo estoque insuficiente p/ envio do lote   ",
                              "34. Portador nao Cadasstrado                      ",
                              "35. Tabela de Financiamento NAO Cadastrada        ",
                              "36. Serie nao cadastrada p/ estabelecimento       ",
                              "37. Cupom inconsistente ou sem itens              ",
                              "38. Valor do item zerado                          ",
                              "39. Dados do cartao debito/credito nao encontradas",
                              "40. Valor do cartao diferente do valor do CUPOM   ",
                              "41. Lote Informado e Item nÆo controla lote       ",
                              "42. Lote NAO informado para item que controla lote",
                              "43. Especie titulos natureza de operacao em BRANCO",
                              "44. Condicao de Pagamento nao Cadastrada INT018"].

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
def var i-tipo-contr     like item.tipo-contr no-undo.
def var i-cod-vencto     like cond-pagto.cod-vencto   no-undo.
def var i-prazos         like cond-pagto.prazos       no-undo.
def var de-per-pg-dup    like cond-pagto.per-pg-dup   no-undo.
def var i-num-parcelas   like cond-pagto.num-parcelas no-undo.
def var c-status         as char no-undo.
def var c-bairro         like estabelec.bairro no-undo.
def var c-pais           like estabelec.pais no-undo.
def var c-endereco       like estabelec.endereco no-undo.
def var i-ep-codigo      like estabelec.ep-codigo no-undo.
def var i-cep            like estabelec.cep no-undo.
DEF VAR i-cupom          AS INT FORMAT ">>>,>>9" NO-UNDO.
def var c-uf-destino    like estabelec.estado no-undo.
def var c-uf-origem     like estabelec.estado no-undo.

DEFINE VARIABLE v-row-loja-cond-pag AS ROWID       NO-UNDO.
DEFINE VARIABLE v-row-classif-fisc  AS ROWID       NO-UNDO.

{utp/ut-glob.i}

/* defini‡ao de frames do relat¢rio */
form i-nr-registro    column-label "Sequencia"
     tb-erro[1]       column-label "Mensagem"
     c-informacao     column-label "Conteudo"
     with no-box no-attr-space width 300
     down stream-io frame f-erro.

/* include com a defini‡ao da frame de cabe‡alho e rodap‚ */
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
assign c-programa       = "INT020-VALIDA-RP"
       c-versao         = "2.12"
       c-revisao        = ".01.AVB"
       c-empresa        = "Nissei"
       c-sistema        = "Faturamento"
       c-titulo-relat   = "Importa‡Æo de Notas Fiscais - Cupons - VALIDA€ÇO".

/* ----- inicio do programa ----- */
for first param-global no-lock: end.
for mgadm.empresa fields (razao-social) where
    empresa.ep-codigo = param-global.empresa-prin no-lock: end.
assign c-empresa = mgadm.empresa.razao-social
       i-cupom   = 0.

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
   empty temp-table tt-cst-nota-fiscal. 
   empty temp-table tt-fat-duplic. 
   empty temp-table tt-int-ds-nota-loja-cartao. 
   empty temp-table tt-notas-geradas .
   empty temp-table RowErrors.   
end.        

procedure pi-importa:
    run pi-acompanhar in h-acomp (input "Lendo Cupons").
    
    i-nr-sequencia = 0.
    assign i-nr-registro    = 0.

    /*bloco-cupom:*/
    for each int-ds-nota-loja no-lock where 
        int-ds-nota-loja.situacao = 1
        query-tuning(no-lookahead):

        if int-ds-nota-loja.tipo-movto <> 1 then next.
        
        /*ASSIGN i-cupom = i-cupom + 1.
        IF i-cupom > 100000 THEN
           LEAVE bloco-cupom.*/

        if i-nr-registro mod 100 = 0 then
            run pi-acompanhar in h-acomp (input "Lendo Cupom: " + string(i-cupom)).
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
                de-valor-vale       = 0
                c-status            = "".

        assign  c-num-nota          = trim(string(int(int-ds-nota-loja.num_nota),">>>9999999"))
                d-dt-implantacao    = today
                d-dt-emissao        = int-ds-nota-loja.emissao
                de-valor-dinh       = int-ds-nota-loja.Valor_din_mov
                de-valor-cartaod    = int-ds-nota-loja.valor_cartaod
                de-valor-cartaoc    = int-ds-nota-loja.valor_cartaoc
                de-valor-vale       = int-ds-nota-loja.valor_vale
                c-condipag          = int-ds-nota-loja.condipag
                c-convenio          = int-ds-nota-loja.convenio
                c-serie             = int-ds-nota-loja.serie
                c-status            = trim(int-ds-nota-loja.istatus).

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
        for each int-ds-nota-loja-item exclusive of int-ds-nota-loja
            query-tuning(no-lookahead)
            break by int-ds-nota-loja-item.num_nota
                    by int-ds-nota-loja-item.sequencia
                      by int-ds-nota-loja-item.produto:

            assign  c-it-codigo         = trim(string(int(int-ds-nota-loja-item.produto)))
                    de-quantidade       = int-ds-nota-loja-item.quantidade
                    de-vl-uni           = int-ds-nota-loja-item.preco_unit
                    de-vl-liq           = int-ds-nota-loja-item.preco_liqu 
                                        / int-ds-nota-loja-item.quantidade
                    de-desconto         = int-ds-nota-loja-item.desconto
                    c-numero-lote       = if trim(int-ds-nota-loja-item.lote) <> ? and
                                             trim(int-ds-nota-loja-item.lote) <> "?" then 
                                             trim(int-ds-nota-loja-item.lote) else ""
                    /*i-nr-sequencia      = int(int-ds-nota-loja-item.sequencia)*/
                    de-aliq-icms        = int-ds-nota-loja-item.aliq_icms
                    de-base-icms        = int-ds-nota-loja-item.base_icms
                    de-valor-icms       = if int-ds-nota-loja.valor_icms <> 0 
                                          then ((de-aliq-icms * de-base-icms) / 100)
                                          else 0.
                    /*
                    int-ds-nota-loja-item.trib_icms
                    int-ds-nota-loja-item.valortrib
                    int-ds-nota-loja-item.valortribestadual
                    */

            
            run valida-registro-item.        
            if l-cupom-com-erro then next.
            if not can-find (first tt-docto no-lock where 
                tt-docto.cod-estabel = c-cod-estabel and
                tt-docto.serie       = c-serie and
                tt-docto.nr-nota     = c-num-nota) then do:
                run cria-tt-docto.
            end.
            run cria-tt-it-docto.
        end.
        for first tt-it-docto: end.
        if not l-cupom-com-erro and not avail tt-it-docto then do:
            assign i-erro = 37
                   c-informacao = c-serie + " - " + c-num-nota + " - " + string(int-ds-nota-loja.cnpj_filial)
                   l-cupom-com-erro = yes.
            run gera-log. 
        end.

        if l-cupom-com-erro then
           run apaga-registro-atual.

    end.
    run pi-elimina-tabelas.
end.

procedure valida-registro-cabecalho.
    
    if i-nr-registro mod 100 = 0 then
        run pi-acompanhar in h-acomp (input "Validando cupom").

    assign  c-cod-estabel = ""
            c-estado      = ""
            c-cidade      = ""
            c-bairro      = ""
            c-endereco    = ""
            c-pais        = ""
            i-cep         = 0
            i-ep-codigo   = "". 
    for each estabelec 
        fields (cod-estabel estado cidade 
                cep pais endereco bairro ep-codigo) 
        no-lock where
        estabelec.cgc = int-ds-nota-loja.cnpj_filial,
        first cst-estabelec no-lock where 
        cst-estabelec.cod-estabel = estabelec.cod-estabel and
        cst-estabelec.dt-fim-operacao >= d-dt-emissao:
        assign c-cod-estabel = estabelec.cod-estabel
               c-estado      = estabelec.estado
               c-cidade      = estabelec.cidade
               c-bairro      = estabelec.bairro
               c-endereco    = estabelec.endereco
               c-pais        = estabelec.pais
               i-cep         = estabelec.cep
               i-ep-codigo   = estabelec.ep-codigo.                                     
        leave.
    end.
    if c-cod-estabel = "" then
    do:
       assign i-erro = 30
              c-informacao = c-serie + " - " + c-num-nota + " - " + string(int-ds-nota-loja.cnpj_filial)
              l-cupom-com-erro = yes.
       run gera-log. 
       return.
    end.
    
    assign  c-nome-abrev = if int-ds-nota-loja.valor_convenio <> 0 
                           then "CONSUMIDORCV" else "CONSUMIDOR"
            i-cod-emitente = 0
            i-canal-vendas = 0
            i-cod-rep      = 1.
    if int-ds-nota-loja.cpf_cliente <> ? AND 
       trim(OnlyNumbers(int-ds-nota-loja.cpf_cliente)) <> "" AND
       decimal(trim(OnlyNumbers(int-ds-nota-loja.cpf_cliente))) > 0 then do:
        for first emitente fields (cod-emitente nome-abrev cod-canal-venda tip-cob-desp
                                   cod-rep ind-cre-cli identific pais estado cgc)
            no-lock where
            emitente.cgc = trim(OnlyNumbers(int-ds-nota-loja.cnpjcpf_imp_cup)):
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
           IF c-nome-abrev = "CONSUMIDOR" THEN DO:
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
            END.
        END.
        IF NOT AVAIL emitente THEN DO:
           assign i-erro = 2
                  c-informacao = c-serie + "/" + c-num-nota + " - " + 
                                 " CPF: " + 
                                 int-ds-nota-loja.cpf_cliente
                  l-cupom-com-erro = yes.
           run gera-log. 
           return.
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
        run pi-erros-nota (input 15143, input "Fornecedor " + string(emitente.cod-emitente)).
        return.                                 
    end.

    if not can-find(unid-feder 
                    where unid-feder.pais   = emitente.pais 
                    and   unid-feder.estado = emitente.estado) then do:
       {utp/ut-table.i mguni unid-feder 1}              
       run pi-erros-nota (input 56, input trim(return-value) + " " + emitente.estado).
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
    
    /*
    if i-canal-vendas <> 0 then
    do:
       for first canal-venda fields (cod-canal-venda) no-lock where
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
    */

    if c-status <> "C" and  (
       de-valor-cartaod <> 0 or 
       de-valor-cartaoc <> 0 or 
       de-valor-vale    <> 0) then do:
        if not can-find(first int-ds-nota-loja-cartao no-lock where
            int-ds-nota-loja-cartao.cnpj_filial = int-ds-nota-loja.cnpj_filial and
            int-ds-nota-loja-cartao.serie = int-ds-nota-loja.serie and
            int-ds-nota-loja-cartao.num_nota = int-ds-nota-loja.num_nota) then do:
            assign i-erro = 39
                   c-informacao = c-serie + " - " + c-num-nota + " - " + int-ds-nota-loja.cnpj_filial + " - " + c-cod-estabel
                   l-cupom-com-erro = yes.
            run gera-log. 
            return.
        end.
        else do:
            assign de-aux = 0.
            for each int-ds-nota-loja-cartao no-lock where 
                int-ds-nota-loja-cartao.cnpj_filial = int-ds-nota-loja.cnpj_filial and
                int-ds-nota-loja-cartao.serie       = int-ds-nota-loja.serie and
                int-ds-nota-loja-cartao.num_nota    = int-ds-nota-loja.num_nota
                query-tuning(no-lookahead):
                if int-ds-nota-loja-cartao.valor <= 0 then next.
                de-aux = de-aux + int-ds-nota-loja-cartao.valor.
                create tt-int-ds-nota-loja-cartao.
                buffer-copy int-ds-nota-loja-cartao to tt-int-ds-nota-loja-cartao.

                /*
                /* determina natureza de operacao */
                 run intprg/int018a.p (INPUT  trim(int-ds-nota-loja-cartao.condipag),
                                       INPUT  ?,
                                       OUTPUT v-row-loja-cond-pag,
                                       OUTPUT v-row-classif-fisc). 
                */

                for first int-ds-loja-cond-pag no-lock where 
                    int-ds-loja-cond-pag.condipag = trim(int-ds-nota-loja-cartao.condipag):
                    for first cond-pagto fields (cod-vencto) no-lock where 
                        cond-pagto.cod-cond-pag = int-ds-loja-cond-pag.cod-cond-pag:
                        assign tt-int-ds-nota-loja-cartao.cod-vencto   = cond-pagto.cod-vencto
                               tt-int-ds-nota-loja-cartao.cod-cond-pag = int-ds-loja-cond-pag.cod-cond-pag.
                    end.
                    if not avail cond-pagto then do:
                        assign i-erro = 15
                               c-informacao = c-serie + " - " + c-num-nota + " - " +
                                              string(i-cod-cond-pag)
                               l-cupom-com-erro = yes.
                        run gera-log. 
                        return.
                    end.
                    assign tt-int-ds-nota-loja-cartao.cod-portador  = int-ds-loja-cond-pag.cod-portador
                           tt-int-ds-nota-loja-cartao.modalidade    = int-ds-loja-cond-pag.modalidade.
                    if not can-find (first mgadm.portador no-lock where
                         portador.ep-codigo    = i-ep-codigo and
                         portador.cod-portador = tt-int-ds-nota-loja-cartao.cod-portador and
                         portador.modalidade   = tt-int-ds-nota-loja-cartao.modalidade)
                    then do:
                       assign i-erro = 34
                              c-informacao = c-serie + " - " + c-num-nota + " - " +
                                             string(tt-int-ds-nota-loja-cartao.cod-portador) + "/" + string(tt-int-ds-nota-loja-cartao.modalidade)
                              l-cupom-com-erro = yes.
                       run gera-log. 
                       return.
                    end.    
                end.
                if not avail int-ds-loja-cond-pag then do:
                    assign i-erro = 44
                           c-informacao = c-num-nota    + " - " + 
                                          " "           + " - " + 
                                          trim(int-ds-nota-loja-cartao.condipag) + " - " + 
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

   if i-nr-registro mod 100 = 0 then
       run pi-acompanhar in h-acomp (input "Validando Itens").
   for first item 
        fields (class-fiscal ind-item-fat cod-obsoleto tipo-contr cd-trib-icm aliquota-ipi
                aliquota-iss cd-trib-ipi un ind-ipi-dife cod-localiz tipo-con-est perm-saldo-neg)
        no-lock where
        item.it-codigo = c-it-codigo:
        c-class-fiscal = item.class-fiscal.
        l-saldo-neg = item.perm-saldo-neg = 3.
        i-tipo-contr = item.tipo-contr.
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
   if avail item THEN do: /*and not item.ind-item-fat then do:*/
      FOR FIRST item-uni-estab WHERE
                item-uni-estab.it-codigo   = ITEM.it-codigo AND
                item-uni-estab.cod-estabel = c-cod-estabel NO-LOCK:  
      END.
      IF AVAIL item-uni-estab AND item-uni-estab.ind-item-fat = NO THEN DO:
         assign i-erro = 11
                c-informacao = c-num-nota + " - " + 
                               c-it-codigo
                l-cupom-com-erro = yes.
         run gera-log. 
         return.
      END.
   end.     
   /***************** Classifica»’o Fiscal *******************************/
   if avail item and i-pais-impto-usuario = 1  /* Brasil */
   and not can-find(classif-fisc where 
                   classif-fisc.class-fiscal = item.class-fiscal) then do:
       {utp/ut-table.i mgind classif-fisc 1}  
       run pi-erros-nota (input 56, input trim(return-value) + " " + item.class-fiscal).
       return.
   end.
   /**************** Item x Refer¼ncia ***********************************/
   if avail item and item.tipo-con-est = 4 then do:  /* Referencia */
      if not can-find(ref-item where
                      ref-item.it-codigo = tt-it-docto.it-codigo and
                      ref-item.cod-refer = tt-it-docto.cod-refer) then do:        
          {utp/ut-table.i mgind ref-item 1}                        
          run pi-erros-nota (input 56, input trim(return-value) + " " + tt-it-docto.it-codigo + "/" + tt-it-docto.cod-refer).
          return.
      end.
   end.

   if avail item and item.tipo-con-est = 3 and
      c-numero-lote = "" then do:  /* Lote */
       assign i-erro = 41
              c-informacao = c-serie + " - " + c-num-nota + " - " +
                             c-it-codigo + " - " + 
                             c-numero-lote
              l-cupom-com-erro = yes.
       run gera-log. 
       return.
   end.

   /* RETIRAR DE COMENTARIO APOS OS TESTES */

   /*if avail item and item.tipo-con-est <> 3 and
      c-numero-lote <> "" then do:  /* Lote */
       assign i-erro = 42
              c-informacao = c-serie + " - " + c-num-nota + " - " +
                             c-it-codigo + " - " + 
                             c-numero-lote
              l-cupom-com-erro = yes.
       run gera-log. 
       return.
   end.*/

   /******************************************/

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
    run intprg/int018a.p (INPUT  c-condipag,
                          INPUT  c-class-fiscal,
                          OUTPUT v-row-loja-cond-pag,
                          OUTPUT v-row-classif-fisc). 
   
   assign  c-natur         = ""
           i-cod-cond-pag  = ?
           i-cod-portador  = ?
           i-modalidade    = ?
           c-serie         = ""
           c-cod-esp-princ = "".


   FOR FIRST estabelec NO-LOCK
       WHERE estabelec.cod-estabel = c-cod-estabel:
       ASSIGN c-serie = estabelec.serie
              c-uf-destino = estabelec.estado
              c-uf-origem  = estabelec.estado.
   END.

   for first int-ds-loja-cond-pag no-lock 
       where int-ds-loja-cond-pag.condipag = trim(c-condipag):
       assign  i-cod-cond-pag = int-ds-loja-cond-pag.cod-cond-pag 
               i-cod-portador = int-ds-loja-cond-pag.cod-portador
               i-modalidade   = int-ds-loja-cond-pag.modalidade.
   end.

   /*
   for first int-ds-classif-fisc no-lock 
       where rowid(int-ds-classif-fisc) = v-row-classif-fisc:
       assign  c-natur        = int-ds-classif-fisc.cod-nat-oper-cupom 
               c-nat-devol    = int-ds-classif-fisc.cod-nat-oper-devol.
   end.
   */

   /* determina natureza de operacao */
   run intprg/int115a.p ( input "98"          ,
                          input c-uf-destino  ,
                          input c-uf-origem   ,
                          input "" /*nat or*/ ,  
                          input i-cod-emitente,
                          input c-class-fiscal,
			  input ""	      , /* item */
                          output c-natur      ,
                          output c-nat-devol  ,
                          output r-rowid).
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
   if avail natur-oper and natur-oper.cod-esp = "" then do:
       assign i-erro = 43
              c-informacao = c-num-nota    + " - " + 
                             " "           + " - " + 
                             natur-oper.nat-operacao
              l-cupom-com-erro = yes.
       run gera-log. 
       return.
   end.

   IF  NOT AVAIL natur-oper OR 
       NOT AVAIL int-ds-classif-fisc
   then do:
       assign i-erro = 21
              c-informacao = c-num-nota    + " - " + 
                             c-natur       + " - " + 
                             c-class-fiscal 
              l-cupom-com-erro = yes.
       run gera-log. 
       return.
   end.
   if avail natur-oper and 
      not natur-oper.nat-ativa then do:
       assign i-erro = 32  
              c-informacao = c-num-nota + " - " + 
                          c-natur
           l-cupom-com-erro = yes.
       run gera-log. 
       return.
   end.

   /**************** Natureza n’o pode ser de entrada ****************/
   if natur-oper.tipo = 1 then do:     /* Entrada */
      run pi-erros-nota (input 6028, input "Entrada").
      return.
   end.

    /*********** Natureza n’o pode ser operacao com terceiros *********/
    if natur-oper.terceiros then do:     /* terceiro */
       run pi-erros-nota (input 15126, input "Terceiros").
       return.
    end.

    /********** Natureza de Opera»’o Inativa ***********************/
    if natur-oper.nat-ativa = no then do:
       run pi-erros-nota (input 26759, input "Inativa").
       return.
    end.

    /*************** C½digo da Mensagem ***********************************/

    if  natur-oper.cod-mensagem <> 0 
    and not can-find(mensagem where 
                     mensagem.cod-mensagem = natur-oper.cod-mensagem) then do:
        {utp/ut-table.i mgadm mensagem 1}    
        run pi-erros-nota (input 56, input trim(return-value) + " " + string(natur-oper.cod-mensagem)).
        return.
    end.

   if i-cod-cond-pag <> 0
   then do:
      for first cond-pagto fields (cod-cond-pag nr-tab-finan nr-ind-finan 
                                   cod-vencto prazos per-pg-dup num-parcelas)
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
                 i-indice    = cond-pagto.nr-ind-finan
                 i-cod-vencto   = cond-pagto.cod-vencto  
                 i-prazos       = cond-pagto.prazos      
                 de-per-pg-dup  = cond-pagto.per-pg-dup  
                 i-num-parcelas = cond-pagto.num-parcelas.
   end.

   if i-cod-portador <> 0
   then do:
      if not can-find (first mgadm.portador no-lock where
           portador.ep-codigo    = i-ep-codigo and
           portador.cod-portador = i-cod-portador and
           portador.modalidade   = i-modalidade)
      then do:
         assign i-erro = 34
                c-informacao = c-serie + " - " + c-num-nota + " - " +
                               string(i-cod-portador) + "/" + string(i-modalidade)
                l-cupom-com-erro = yes.
         run gera-log. 
         return.
      end.    
   end.

   if c-serie = ? then assign c-serie = trim(int-ds-nota-loja.serie).
   for first ser-estab exclusive-lock where
        ser-estab.serie = c-serie and
        ser-estab.cod-estabel = c-cod-estabel: end.
   if not avail ser-estab then do:
      assign i-erro = 36
             c-informacao = c-num-nota + " - " + 
                            c-serie + " - " + c-cod-estabel
             l-cupom-com-erro = yes.
      run gera-log. 
      return.
   end.    
   if avail ser-estab then do:
      if ser-estab.forma-emis = 1 /* automatica */ then do:
          assign i-erro = 19
                 c-informacao = c-num-nota + " - " + 
                                c-serie + " - " + c-cod-estabel
                 l-cupom-com-erro = yes.
          run gera-log. 
          return.
      end.
      else do:
        assign ser-estab.dt-prox-fat = 01/01/0001
               ser-estab.dt-ult-fat  = 01/01/0001.
      end.
   end.

   if can-find (first serie no-lock where 
       serie.serie = c-serie and
       serie.forma-emis = 1 /* Automatica */) then do:
       assign i-erro = 19
              c-informacao = c-num-nota + " - " + 
                             c-serie + " - "
              l-cupom-com-erro = yes.
       run gera-log. 
       return.
   end.

   /**************** Nota Fiscal jÿ existe *********************************/
   if can-find(nota-fiscal
      where nota-fiscal.cod-estabel = c-cod-estabel
      and   nota-fiscal.serie       = c-serie
      and   nota-fiscal.nr-nota-fis = c-num-nota) then do:
       {utp/ut-table.i mgdis nota-fiscal 1}
       run pi-erros-nota (input 1, input trim(return-value)).
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
    if i-nr-registro mod 100 = 0 then
        run pi-acompanhar in h-acomp (input "Criando Cupom").
    
    create tt-docto.
    assign tt-docto.fat-nota         = if int-ds-nota-loja.valor_convenio <> 0 and c-status <> "C"
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

    assign tt-docto.estado         = c-estado
           tt-docto.cep            = string(i-cep)
           tt-docto.pais           = c-pais
           tt-docto.endereco       = c-endereco
           tt-docto.bairro         = c-bairro
           tt-docto.cidade         = c-cidade.
 
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
           tt-docto.dt-cancel        = if c-status <> "C" then d-dt-emissao else ?
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

    if int-ds-nota-loja.nfce_chave_s  /* chave acesso */ <> ? and
       int-ds-nota-loja.nfce_transmissao_s /* tipo transmissao*/  <> ? and
       int-ds-nota-loja.nfce_protocolo_s /* protocolo */ <> ? then do:
           assign overlay(tt-docto.char-1,112,60) = replace(int-ds-nota-loja.nfce_chave_s,'NFe','')  /* chave acesso */
                  overlay(tt-docto.char-1,172,2)  = if c-status <> "C" then "3" else "6" /* situacao */ 
                  overlay(tt-docto.char-1,174,1)  = int-ds-nota-loja.nfce_transmissao_s /* tipo transmissao*/
                  overlay(tt-docto.char-1,175,15) = int-ds-nota-loja.nfce_protocolo_s. /* protocolo */ 
    end.
    /*
    Modalidade de Frete
    assign overlay(tt-docto.char-1,190,8) = TRIM(SUBSTR(c-linha,8863,8)) NO-ERROR.
    Fim Modalidade de Frete*/			     

    create tt-cst-nota-fiscal.
    assign tt-cst-nota-fiscal.cod-estabel       = c-cod-estabel
           tt-cst-nota-fiscal.serie             = c-serie
           tt-cst-nota-fiscal.nr-nota-fis       = c-num-nota
           tt-cst-nota-fiscal.condipag          = int-ds-nota-loja.condipag
           tt-cst-nota-fiscal.convenio          = int-ds-nota-loja.convenio
           tt-cst-nota-fiscal.cupom-ecf         = int-ds-nota-loja.cupom_ecf
           tt-cst-nota-fiscal.nfce-chave        = int-ds-nota-loja.nfce_chave_s
           tt-cst-nota-fiscal.valor-chq         = int-ds-nota-loja.valor_chq
           tt-cst-nota-fiscal.valor-chq-pre     = int-ds-nota-loja.valor_chq_pre
           tt-cst-nota-fiscal.valor-convenio    = int-ds-nota-loja.valor_convenio
           tt-cst-nota-fiscal.valor-cartao      = int-ds-nota-loja.valor_cartaod 
                                                + int-ds-nota-loja.valor_cartaoc
           tt-cst-nota-fiscal.valor-dinheiro    = de-valor-dinh
           tt-cst-nota-fiscal.valor-ticket      = int-ds-nota-loja.valor_ticket
           tt-cst-nota-fiscal.valor-vale        = int-ds-nota-loja.valor_vale
           tt-cst-nota-fiscal.nfce-dt-transmissao   = int-ds-nota-loja.nfce_transmissao_d
           tt-cst-nota-fiscal.nfce-protocolo        = int-ds-nota-loja.nfce_protocolo_s
           tt-cst-nota-fiscal.nfce-transmissao      = int-ds-nota-loja.nfce_transmissao_s
           tt-cst-nota-fiscal.cpf-cupom             = int-ds-nota-loja.cnpjcpf_imp_cup.
end.
 
procedure cria-tt-it-docto.

   define var i-cd-trib-ipi as integer no-undo.
   define var i-cd-trib-icm as integer no-undo.

   if i-nr-registro mod 100 = 0 then
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
          tt-it-docto.baixa-estoq         = if c-status <> "C" then i-tipo-contr <> 4 else no
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
          tt-it-docto.per-des-item        = de-desconto
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
          tt-it-docto.vl-desconto         = if de-vl-uni >= de-vl-liq then (de-vl-uni - de-vl-liq) else 0
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

   if i-tipo-contr <> 4 /* dbito direto */ and c-status <> "C" then do:

       if item.tipo-con-est = 3 /* lote */ then
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
       not avail tt-saldo-estoq then do:
           run pi-erros-nota (input 26082, input trim(tt-it-docto.it-codigo)).
           return.
       end.
   end.
end.
 
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

   if i-nr-registro mod 100 = 0 then
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
                        trim(int-ds-nota-loja.cnpj_filial + "/" + c-serie  + "/" + trim(string(int(c-num-nota),">>>9999999"))),
                        substring(trim(tb-erro[i-erro]) + " - " + c-informacao,1,500),
                        int-ds-nota-loja.situacao, /* 1 - Pendente, 2 - Processado */ 
                        c-seg-usuario,
                        "INT020-1RP.P").
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
        for each tt-cst-nota-fiscal where 
            tt-cst-nota-fiscal.cod-estabel = c-cod-estabel and
            tt-cst-nota-fiscal.serie       = c-serie       and
            tt-cst-nota-fiscal.nr-nota     = c-num-nota:
            delete tt-cst-nota-fiscal.
        end.
        for each tt-int-ds-nota-loja-cartao no-lock where 
            tt-int-ds-nota-loja-cartao.cnpj_filial = int-ds-nota-loja.cnpj_filial and
            tt-int-ds-nota-loja-cartao.serie = int-ds-nota-loja.serie and
            tt-int-ds-nota-loja-cartao.num_nota = int-ds-nota-loja.num_nota:
            delete tt-int-ds-nota-loja-cartao.
        end.
        delete tt-docto.
    end.
end.

procedure finaliza-cupom.
   run pi-acompanhar in h-acomp (input "Finalizando cupom: " + trim(int-ds-nota-loja.num_nota)).
   find current int-ds-nota-loja exclusive-lock no-error.
   if avail int-ds-nota-loja then do:
       for first nota-fiscal fields (cod-estabel nr-fatura
                                    serie cod-cond-pag modalidade
                                    nr-nota-fis cod-portador)
         where nota-fiscal.cod-estabel = c-cod-estabel
         and   nota-fiscal.serie       = c-serie
         and   nota-fiscal.nr-nota-fis = c-num-nota
         no-lock:
    
           for each cst-fat-duplic no-lock where 
               cst-fat-duplic.cod-estabel = nota-fiscal.cod-estabel and
               cst-fat-duplic.serie       = nota-fiscal.serie and
               cst-fat-duplic.nr-fatura   = nota-fiscal.nr-fatura
               query-tuning(no-lookahead):
               for each fat-duplic exclusive where 
                   fat-duplic.cod-estabel  = cst-fat-duplic.cod-estabel  and
                   fat-duplic.serie        = cst-fat-duplic.serie        and
                   fat-duplic.nr-fatura    = cst-fat-duplic.nr-fatura    and
                   fat-duplic.parcela      = cst-fat-duplic.parcela
                   query-tuning(no-lookahead):
                   assign fat-duplic.int-1 = cst-fat-duplic.cod-portador
                          fat-duplic.int-2 = cst-fat-duplic.modalidade.
                   /* nota - nao gera ACR */
                   if fat-duplic.cod-esp <> "CV" then 
                       assign fat-duplic.ind-fat-nota = 2.
               end.
           end.
    
           for first cst-nota-fiscal of nota-fiscal exclusive-lock: end.
           if not avail cst-nota-fiscal then do:
               create cst-nota-fiscal.
               assign cst-nota-fiscal.cod-estabel       = nota-fiscal.cod-estabel
                      cst-nota-fiscal.serie             = nota-fiscal.serie
                      cst-nota-fiscal.nr-nota-fis       = nota-fiscal.nr-nota-fis.
               assign i-erro       = 1
                      c-informacao = c-cod-estabel + "/" + 
                                     c-serie + "/" + c-num-nota + "/" + c-nome-abrev.
               assign int-ds-nota-loja.situacao = 2 /* integrado */
                      l-cupom-com-erro = yes.
               run gera-log.
           end.
           assign cst-nota-fiscal.condipag            = int-ds-nota-loja.condipag
                  cst-nota-fiscal.convenio            = int-ds-nota-loja.convenio
                  cst-nota-fiscal.cupom-ecf           = int-ds-nota-loja.cupom_ecf
                  cst-nota-fiscal.nfce-chave          = int-ds-nota-loja.nfce_chave_s
                  cst-nota-fiscal.valor-chq           = int-ds-nota-loja.valor_chq
                  cst-nota-fiscal.valor-chq-pre       = int-ds-nota-loja.valor_chq_pre
                  cst-nota-fiscal.valor-convenio      = int-ds-nota-loja.valor_convenio
                  cst-nota-fiscal.valor-dinheiro      = int-ds-nota-loja.valor_din_mov
                  cst-nota-fiscal.valor-ticket        = int-ds-nota-loja.valor_ticket
                  cst-nota-fiscal.valor-vale          = int-ds-nota-loja.valor_vale
                  cst-nota-fiscal.valor-cartao        = int-ds-nota-loja.valor_cartaod + 
                                                        int-ds-nota-loja.valor_cartaoc
                  cst-nota-fiscal.nfce-dt-transmissao = int-ds-nota-loja.nfce_transmissao_d
                  cst-nota-fiscal.nfce-protocolo      = int-ds-nota-loja.nfce_protocolo_s
                  cst-nota-fiscal.nfce-transmissao    = int-ds-nota-loja.nfce_transmissao_s
                  cst-nota-fiscal.cpf-cupom           = int-ds-nota-loja.cnpjcpf_imp_cup.
       end.
       /*release int-ds-nota-loja.*/
   end.
end.
