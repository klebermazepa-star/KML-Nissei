/********************************************************************************
** Programa: INT020 - Gera‡Æo notas fiscais a partir de Cupom Fiscal PRS
**
** Versao : 12 - 20/03/2016 - Alessandro V Baccin
**
********************************************************************************/
/* include de controle de versao */
{include/i-prgvrs.i INT020RP 2.12.01.AVB}

/* definiçao das temp-tables para recebimento de parametros */
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

def temp-table tt-ped-venda-prs         like ped-venda.
def temp-table tt-ped-item-prs          like ped-item
    field numero-lote   as char
    field aliquota-icm  as decimal
    field vl-bicms-it   as decimal
    field vl-icms-it    as decimal
    field vl-bipi-it    as decimal.
def temp-table tt-cst-nota-fiscal like cst-nota-fiscal.

def temp-table tt-notas-geradas no-undo
    field rw-nota-fiscal   as rowid
    field nr-nota        like nota-fiscal.nr-nota-fis
    field seq-wt-docto   like wt-docto.seq-wt-docto.

{dibo/bodi317sd.i1}

/* temp-tables das API's e BO's */
{method/dbotterr.i}

/* recebimento de parametros */
def input parameter raw-param as raw no-undo.
def input parameter table for tt-raw-digita.  

create tt-param.                    
raw-transfer raw-param to tt-param. 

/* include padrao para variáveis de relatório  */
{include/i-rpvar.i}

/* ++++++++++++++++++ (Definicao Stream) ++++++++++++++++++ */

/* ++++++++++++++++++ (Definicao Buffer) ++++++++++++++++++ */
define buffer bemitente for emitente.

/* definiçao de variáveis  */
def var h-acomp             as handle no-undo.
def var l-proc-ok-aux       as log    no-undo.
def var i-seq-wt-docto      as int    no-undo.
def var i-seq-wt-it-docto   as int    no-undo.
def var i-seq-wt-it-last    as int    no-undo.
def var c-ultimo-metodo-exec as char  no-undo.
def var h-bodi317pr         as handle no-undo.
def var h-bodi317sd         as handle no-undo.
def var h-bodi317im1bra     as handle no-undo.
def var h-bodi317va         as handle no-undo.
def var h-bodi317in         as handle no-undo.
def var h-bodi317ef         as handle no-undo.
def var h-boin404te         as handle no-undo.
def var h-bodi515           as handle no-undo.

def var c-num-nota          like ped-venda.nr-pedcli.
def var i-cod-emitente       like emitente.cod-emitente.
def var i-cod-rep            as integer.
def var i-cod-cond-pag       as integer.
def var c-nr-cupom          as char.
def var c-it-codigo          as char.
def var de-quantidade        as decimal.
def var c-natur              like ped-venda.nat-operacao.
def var de-vl-uni            as dec format "999.999".
def var de-desconto          as decimal no-undo.
def var i-tab-finan          as integer.
def var i-indice             as integer.
def var de-aliquota-ipi      as decimal.
def var de-vl-tot-ped        like ped-venda.vl-tot-ped.
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
def var c-docto-orig         as character.
def var c-obs-gerada         as character.
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
                              "18. Documento a ser devolvido nÆo existe          ",
                              "19. Serie deve ter tipo de emissao MANUAL         ",
                              "20.*** Cupom nao Importado ***                    ",
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
                              "34. Portador nao Cadasstrado                      ",
                              "35. Tabela de Financiamento NAO Cadastrada        ",
                              "36. Serie nao cadastrada p/ estabelecimento       ",
                              "37. Cupom inconsistente ou sem itens              ",
                              "38. Valor do item zerado                          ",
                              "39. Dados do cartao debito/credito nao encontradas",
                              "40. Valor do cartao diferente do valor do CUPOM   "].

def var d-pes-liq-tot   as decimal format ">>,>>9.99" no-undo.
def var de-peso-itens   as dec  format ">>>,>>9.99" init 0. 
def var i-cont          as int init 0.
def var de-red-base-ipi as decimal no-undo.
def var de-base-ipi     as decimal no-undo.
def var c-estado        as char no-undo. 
def var c-cidade        as char no-undo. 
def var c-cod-estabel   as char no-undo.
def var c-nome-abrev    as char no-undo.
def var l-ind-icm-ret   as logical no-undo.
def var c-class-fiscal  as char no-undo.
def var c-condipag      as char no-undo.
def var c-convenio      as char no-undo.
def var i-cod-portador  as integer no-undo.
def var i-modalidade    as integer no-undo.
def var i-cod-port-dinh as integer initial 99901 no-undo.
def var i-modalid-dinh  as integer initial 6 no-undo.
def var c-serie         as char no-undo.
def var de-aliq-icms    as decimal no-undo.
def var de-base-icms    as decimal no-undo.
def var de-valor-icms   as decimal no-undo.
def var de-valor-dinh   as decimal no-undo.
def var de-valor-cartaod as decimal no-undo.
def var de-valor-cartaoc as decimal no-undo.
def var r-rowid          as rowid no-undo.

{utp/ut-glob.i}

/* definiçao de frames do relatório */
form i-nr-registro    column-label "Sequencia"
     tb-erro[1]       column-label "Mensagem"
     c-informacao     column-label "Conteudo"
     with no-box no-attr-space width 300
     down stream-io frame f-erro.

/* include com a definiçao da frame de cabeçalho e rodapé */
{include/i-rpcab.i &stream="str-rp"}
/* bloco principal do programa */

{utp/utapi019.i}

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
       c-titulo-relat   = "Importa‡Æo de Notas Fiscais - Cupons - PRS".

/* ----- inicio do programa ----- */
for first param-global no-lock: end.
for mgadm.empresa fields (razao-social) where
    empresa.ep-codigo = param-global.empresa-prin no-lock: end.
assign c-empresa = mgadm.empresa.razao-social.

do:
   run utp/ut-acomp.p persistent set h-acomp.
   run pi-inicializar in h-acomp (input "Processando").

   {include/i-rpout.i &stream = "stream str-rp"}
                         
   view stream str-rp frame f-cabec.
   view stream str-rp frame f-rodape.
   
   run pi-elimina-tabelas.
   run pi-importa.

   pause 3 no-message.
   /*
   run envia-e-mail.
   */
end.
/* ----- fim do programa -------- */
run pi-elimina-tabelas.
run pi-finalizar in h-acomp.

/* fechamento do output do relatorio  */
{include/i-rpclo.i &stream="stream str-rp"}

/* elimina BO's */
return "OK".

/* procedures */

procedure pi-elimina-tabelas.
   run pi-acompanhar in h-acomp (input "Eliminando Tabelas Temporarias").
   /* limpa temp-tables */
   empty temp-table tt-ped-venda-prs.
   empty temp-table tt-ped-item-prs. 
   empty temp-table tt-cst-nota-fiscal. 
   empty temp-table RowErrors.   
   empty temp-table tt-envio2.
   empty temp-table tt-mensagem.
end.        

procedure pi-importa:
    run pi-acompanhar in h-acomp (input "Lendo Cupons").
    
    assign i-nr-registro    = 0.
    for each int-ds-nota-loja exclusive where 
        int-ds-nota-loja.situacao = 1 and
        int-ds-nota-loja.tipo-movto = 1 
        
        and valor_dinheiro <> 0 
        and valor_cartaoc = 0
        and valor_cartaod = 0:

        run pi-acompanhar in h-acomp (input "Lendo Cupom: " + string(int-ds-nota-loja.num_nota)).
        assign  de-vl-tot-ped       = 0
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
                de-valor-cartaoc    = 0.

        assign  c-num-nota          = trim(string(int-ds-nota-loja.num_nota))
                d-dt-implantacao    = today
                d-dt-emissao        = int-ds-nota-loja.emissao
                c-docto-orig        = int-ds-nota-loja.cupom_ecf
                c-obs-gerada        = int-ds-nota-loja.convenio
                de-valor-dinh       = int-ds-nota-loja.Valor_din_mov
                de-valor-cartaod    = int-ds-nota-loja.valor_cartaod
                de-valor-cartaoc    = int-ds-nota-loja.valor_cartaoc
                c-condipag          = int-ds-nota-loja.condipag
                c-convenio          = int-ds-nota-loja.convenio.

        assign i-nr-registro = i-nr-registro + 1.
        /* processa cupom atual */
        run valida-registro-cabecalho.

        assign  c-it-codigo         = ""
                de-quantidade       = 0
                de-vl-uni           = 0
                de-desconto         = 0
                c-class-fiscal      = "".

        if not l-cupom-com-erro then
        for each int-ds-nota-loja-item exclusive of int-ds-nota-loja
            break by int-ds-nota-loja-item.num_nota
                    by int-ds-nota-loja-item.sequencia
                      by int-ds-nota-loja-item.produto:

            assign  c-it-codigo         = trim(string(int(int-ds-nota-loja-item.produto)))
                    de-quantidade       = int-ds-nota-loja-item.quantidade
                    de-vl-uni           = int-ds-nota-loja-item.preco_unit
                    de-vl-liq           = int-ds-nota-loja-item.preco_liqu
                    de-desconto         = /*int-ds-nota-loja-item.preco_unit - int-ds-nota-loja-item.preco_liqu*/ int-ds-nota-loja-item.desconto
                    c-numero-lote       = if trim(int-ds-nota-loja-item.lote) <> ? and
                                             trim(int-ds-nota-loja-item.lote) <> "?" then 
                                             trim(int-ds-nota-loja-item.lote) else ""
                    i-nr-sequencia      = int(int-ds-nota-loja-item.sequencia)
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
            find first tt-ped-venda-prs use-index ch-pedido where 
                tt-ped-venda-prs.nome-abrev = c-nome-abrev and
                tt-ped-venda-prs.nr-pedcli  = c-num-nota no-error.
            if not avail tt-ped-venda-prs then do:
                run cria-tt-ped-venda-prs.
            end.
            run cria-tt-ped-item-prs.
        end.
        for first tt-ped-item-prs: end.
        if not l-cupom-com-erro and not avail tt-ped-item-prs then do:
            assign i-erro = 37
                   c-informacao = c-serie + " - " + c-num-nota + " - " + string(int-ds-nota-loja.cnpj_filial)
                   l-cupom-com-erro = yes.
            run gera-log. 
        end.
        run finaliza-cupom.
    end.
end.

procedure finaliza-cupom.
   run pi-acompanhar in h-acomp (input "Finalizando cupom").
    
   if not l-cupom-com-erro then do:
      run emite-nota.
      if not l-cupom-com-erro then do:
         assign i-erro       = 1
                c-informacao = c-num-nota
                             + " "
                             + c-nome-abrev.
         assign int-ds-nota-loja.situacao = 2 /* integrado */.
         run gera-log.
         release int-ds-nota-loja.
      end.
   end.
   run pi-elimina-tabelas.
end.

procedure valida-registro-cabecalho.
    
    run pi-acompanhar in h-acomp (input "Validando cupom").
    
    assign c-cod-estabel = "".
    for first estabelec fields (cod-estabel estado cidade cep pais endereco bairro) 
        no-lock where 
        estabelec.cgc = int-ds-nota-loja.cnpj_filial: 
        assign c-cod-estabel = estabelec.cod-estabel
               c-estado      = estabelec.estado
               c-cidade      = estabelec.cidade.                                     
    end.
    if c-cod-estabel = "" then
    do:
       assign i-erro = 30
              c-informacao = c-num-nota + " - " + string(int-ds-nota-loja.cnpj_filial)
              l-cupom-com-erro = yes.
       run gera-log. 
       return.
    end.
    
    assign  c-nome-abrev = "CONSUMIDOR"
            i-cod-emitente = 0
            i-canal-vendas = 0
            i-cod-rep      = 1.
    if int-ds-nota-loja.cnpjcpf_imp_cup <> "" then
    for first emitente fields (cod-emitente nome-abrev cod-canal-venda cod-rep ind-cre-cli)
        no-lock where
        emitente.cgc = trim(OnlyNumbers(int-ds-nota-loja.cnpjcpf_imp_cup)):
        assign  c-nome-abrev   = emitente.nome-abrev
                i-cod-emitente = emitente.cod-emitente
                i-canal-vendas = emitente.cod-canal-venda
                i-cod-rep      = if emitente.cod-rep <> 0 
                                 then emitente.cod-rep
                                 else i-cod-rep.
        
        if emitente.ind-cre-cli = 4 then do:
          assign i-erro = 27
                 c-informacao = c-num-nota + " - " + string(i-cod-emitente)
                 l-cupom-com-erro = yes.
          run gera-log. 
          return.
        end. 
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
                            string(i-tab-finan)
             l-cupom-com-erro = yes.
      run gera-log. 
      return.
    end.                     
    
    if i-canal-vendas <> 0 then
    do:
       for first canal-venda fields (cod-canal-venda) no-lock where
           canal-venda.cod-canal-venda = i-canal-vendas: end.
       if not avail canal-venda then
       do:
          assign i-erro = 31
                 c-informacao = c-num-nota + " - " + 
                                string(i-canal-vendas) + " - " + string(i-cod-emitente)
                 l-cupom-com-erro = yes.
          run gera-log. 
          return.
       end.
    end.
    if de-valor-cartaod <> 0 or de-valor-cartaoc <> 0 then do:
        for first int-ds-nota-loja-cartao no-lock where
            int-ds-nota-loja-cartao.cnpj_filial = int-ds-nota-loja.cnpj_filial and
            int-ds-nota-loja-cartao.serie = int-ds-nota-loja.serie and
            int-ds-nota-loja-cartao.num_nota = int-ds-nota-loja.num_nota: end.
        if not avail int-ds-nota-loja-cartao then do:
            assign i-erro = 39
                   c-informacao = c-num-nota + " - " + c-cod-estabel
                   l-cupom-com-erro = yes.
            run gera-log. 
            return.
        end.
        else if int-ds-nota-loja-cartao.valor <> de-valor-cartaoc and
                int-ds-nota-loja-cartao.valor <> de-valor-cartaod then do:
            assign i-erro = 40
                   c-informacao = c-num-nota + " - " + c-cod-estabel + " - " + 
                                  string(int-ds-nota-loja-cartao.valor)
                   l-cupom-com-erro = yes.
            run gera-log. 
            return.
        end.
    end.
end.
      
procedure valida-registro-item.

   run pi-acompanhar in h-acomp (input "Validando Itens").
   for first item 
        fields (class-fiscal ind-item-fat cod-obsoleto tipo-contr 
                aliquota-iss cd-trib-ipi un ind-ipi-dife cod-localiz)
        no-lock where
        item.it-codigo = c-it-codigo:
        c-class-fiscal = item.class-fiscal.
   end.
   if not avail item then do:
      assign i-erro = 9
             c-informacao = c-num-nota + " - " + 
                            c-it-codigo 
             l-cupom-com-erro = yes.
      run gera-log. 
      return.
   end.
   if avail item and item.cod-obsoleto = 4 then do:
      assign i-erro = 10
             c-informacao = c-num-nota + " - " + 
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
   if dec(de-quantidade) <= 0 then do:
      assign i-erro = 12
             c-informacao = c-num-nota + " - " + 
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
                         output c-natur        , 
                         output i-cod-cond-pag , 
                         output i-cod-portador ,
                         output i-modalidade   ,
                         output c-serie        ,
                         output r-rowid).

   for first natur-oper 
       fields (nat-ativa nat-operacao emite-duplic tipo char-2
               cd-trib-icm cd-trib-ipi cod-mensagem consum-final)
       no-lock where
       natur-oper.nat-operacao = c-natur: end.

   if not avail natur-oper then do:
       assign i-erro = 21
              c-informacao = c-num-nota + " - " + 
                             c-natur
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
   /*
   if avail natur-oper and not natur-oper.emite-duplic then
       assign i-cod-cond-pag = 0.
   */

   if i-cod-cond-pag <> 0
   then do:
      for first cond-pagto fields (cod-cond-pag nr-tab-finan nr-ind-finan)
          where cond-pagto.cod-cond-pag = i-cod-cond-pag
          no-lock: end.
      if not avail cond-pagto then do:
         assign i-erro = 15
                c-informacao = c-num-nota + " - " + 
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
           portador.cod-portador = i-cod-portador and
           portador.modalidade = i-modalidade: end.
      if not avail portador then do:
         assign i-erro = 34
                c-informacao = c-num-nota + " - " + 
                               string(i-cod-portador) + "/" + string(i-modalidade)
                l-cupom-com-erro = yes.
         run gera-log. 
         return.
      end.    
   end.

   if c-serie = ? then assign c-serie = trim(string(int(int-ds-nota-loja.serie),"999")).
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

   for first serie fields (serie forma-emis)
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

   if de-vl-uni = 0 then do:
        assign i-erro = 38
               c-informacao = c-num-nota + " - " + 
                              c-it-codigo
               l-cupom-com-erro = yes.
        run gera-log. 
        return.
   end.
end.
 
procedure cria-tt-ped-venda-prs.
   run pi-acompanhar in h-acomp (input "Criando Cupom").

   create tt-ped-venda-prs.
   assign tt-ped-venda-prs.cod-estabel    = c-cod-estabel
          tt-ped-venda-prs.nr-pedcli      = c-num-nota
          tt-ped-venda-prs.nr-pedrep      = c-num-nota
          tt-ped-venda-prs.dt-emissao     = d-dt-emissao
          tt-ped-venda-prs.dt-implant     = d-dt-implantacao
          tt-ped-venda-prs.nat-operacao   = c-natur
          tt-ped-venda-prs.cod-cond-pag   = i-cod-cond-pag
          tt-ped-venda-prs.no-ab-reppri   = c-nome-repres
          tt-ped-venda-prs.nr-tab-finan   = i-tab-finan 
          tt-ped-venda-prs.nr-ind-finan   = i-indice    
          tt-ped-venda-prs.inc-desc-txt   = no.

          tt-ped-venda-prs.cod-canal-venda = if avail canal-venda
                                             then canal-venda.cod-canal-venda
                                             else 0.

   assign tt-ped-venda-prs.ind-tp-frete   = 2 /* FOB */.
          
   assign tt-ped-venda-prs.cod-portador   = i-cod-portador
          tt-ped-venda-prs.modalidade     = i-modalidade
          tt-ped-venda-prs.cod-mensagem   = natur-oper.cod-mensagem
          tt-ped-venda-prs.user-impl      = c-seg-usuario
          tt-ped-venda-prs.dt-userimp     = today
          tt-ped-venda-prs.ind-aprov      = no
          tt-ped-venda-prs.quem-aprovou   = " "
          tt-ped-venda-prs.dt-apr-cred    = ?
          tt-ped-venda-prs.cod-des-merc   = if natur-oper.consum-final 
                                            then 2 else 1
          tt-ped-venda-prs.tp-preco       = 1
          tt-ped-venda-prs.ind-lib-nota   = yes.

    assign tt-ped-venda-prs.estado         = estabelec.estado
           tt-ped-venda-prs.cep            = string(estabelec.cep)
           tt-ped-venda-prs.pais           = estabelec.pais
           tt-ped-venda-prs.local-entreg   = estabelec.endereco
           tt-ped-venda-prs.bairro         = estabelec.bairro
           tt-ped-venda-prs.cidade         = estabelec.cidade.

    for first emitente fields (cgc nome-abrev cod-emitente tip-cob-desp per-max-canc) no-lock where
        emitente.nome-abrev = c-nome-abrev: 
        assign tt-ped-venda-prs.cgc            = emitente.cgc
               tt-ped-venda-prs.ins-estadual   = ""
               tt-ped-venda-prs.nome-abrev     = emitente.nome-abrev
               tt-ped-venda-prs.cod-emitente   = emitente.cod-emitente
               tt-ped-venda-prs.tip-cob-desp   = emitente.tip-cob-desp
               tt-ped-venda-prs.per-max-canc   = emitente.per-max-canc.
    end.
    if not avail emitente then do:
        assign tt-ped-venda-prs.cgc            = /*int-ds-nota-loja.cnpjcpf_imp_cup*/ '00000000001'
               tt-ped-venda-prs.ins-estadual   = ""
               tt-ped-venda-prs.nome-abrev     = c-nome-abrev
               tt-ped-venda-prs.cod-emitente   = 0.
    end.

    create tt-cst-nota-fiscal.
    assign tt-cst-nota-fiscal.cod-estabel    = c-cod-estabel
           tt-cst-nota-fiscal.serie          = c-serie
           tt-cst-nota-fiscal.nr-nota-fis    = trim(string(int(int-ds-nota-loja.num_nota),"9999999"))
           tt-cst-nota-fiscal.condipag       = int-ds-nota-loja.condipag
           tt-cst-nota-fiscal.convenio       = int-ds-nota-loja.convenio
           tt-cst-nota-fiscal.cupom-ecf      = int-ds-nota-loja.cupom_ecf
           tt-cst-nota-fiscal.nfce-chave     = int-ds-nota-loja.nfce_chave_s
           tt-cst-nota-fiscal.valor-chq      = int-ds-nota-loja.valor_chq
           tt-cst-nota-fiscal.valor-chq-pre  = int-ds-nota-loja.valor_chq_pre
           tt-cst-nota-fiscal.valor-convenio = int-ds-nota-loja.valor_convenio
           tt-cst-nota-fiscal.valor-dinheiro = de-valor-dinh
           tt-cst-nota-fiscal.valor-ticket   = int-ds-nota-loja.valor_ticket
           tt-cst-nota-fiscal.valor-vale     = int-ds-nota-loja.valor_vale
           tt-cst-nota-fiscal.nfce-dt-transmissao   = int-ds-nota-loja.nfce_transmissao_d
           tt-cst-nota-fiscal.nfce-protocolo        = int-ds-nota-loja.nfce_protocolo_s
           tt-cst-nota-fiscal.nfce-transmissao      = int-ds-nota-loja.nfce_transmissao_s.
               
    for first int-ds-nota-loja-cartao no-lock of int-ds-nota-loja:
        assign tt-cst-nota-fiscal.adm-cartao     = int-ds-nota-loja-cartao.adm_cartao
               tt-cst-nota-fiscal.autorizacao    = int-ds-nota-loja-cartao.autorizacao
               tt-cst-nota-fiscal.condipag       = int-ds-nota-loja-cartao.condipag
               tt-cst-nota-fiscal.nsu-admin      = int-ds-nota-loja-cartao.nsu_admin
               tt-cst-nota-fiscal.nsu-numero     = int-ds-nota-loja-cartao.nsu_numero
               tt-cst-nota-fiscal.taxa-admin     = int-ds-nota-loja-cartao.taxa_admin
               tt-cst-nota-fiscal.vencimento     = int-ds-nota-loja-cartao.vencimento
               tt-cst-nota-fiscal.valor-cartao   = int-ds-nota-loja-cartao.valor.
    end.
end.
 
procedure cria-tt-ped-item-prs.
   run pi-acompanhar in h-acomp (input "Criando Itens do Cupom").
   /*assign i-nr-sequencia = i-nr-sequencia + 10.*/
   create tt-ped-item-prs.
   assign tt-ped-item-prs.nome-abrev   = tt-ped-venda-prs.nome-abrev
          tt-ped-item-prs.nr-pedcli    = tt-ped-venda-prs.nr-pedcli
          tt-ped-item-prs.nr-sequencia = i-nr-sequencia
          tt-ped-item-prs.it-codigo    = c-it-codigo
          tt-ped-item-prs.nat-operacao = c-natur
          tt-ped-item-prs.nr-tabpre    = ""
          tt-ped-item-prs.qt-pedida    = dec(de-quantidade)
          tt-ped-item-prs.qt-un-fat    = tt-ped-item-prs.qt-pedida
          tt-ped-item-prs.vl-pretab    = de-vl-uni
          tt-ped-item-prs.vl-preori    = de-vl-uni.
   assign tt-ped-item-prs.des-un-medida = item.un
          tt-ped-item-prs.cod-un        = item.un.

   assign de-red-base-ipi = 0 /* base normal */
          de-base-ipi = (de-vl-liq * tt-ped-item-prs.qt-pedida). 
   if avail natur-oper and /* IPI SOBRE O BRUTO */
     substring(natur-oper.char-2,11,1) = "1" then
   do:
      de-base-ipi = (de-vl-liq * tt-ped-item-prs.qt-pedida). 
   end.
   
   /* Aliquota ISS */
   if avail natur-oper and
      natur-oper.tipo = 3 then 
      assign tt-ped-item-prs.dec-2 = item.aliquota-iss
             tt-ped-item-prs.val-aliq-iss = item.aliquota-iss.
   else 
      assign tt-ped-item-prs.dec-2 = 0
             tt-ped-item-prs.val-aliq-iss = 0.

       /* IPI Diferenciado */
   if item.ind-ipi-dife = no and 
      item.tipo-contr <> 4 then do:
      overlay(tt-ped-item-prs.char-2,01,08) = "".
      assign tt-ped-item-prs.cod-class-fis = "".
   end.       
   else do:
      overlay(tt-ped-item-prs.char-2,01,08) = item.class-fiscal. 
      assign tt-ped-item-prs.cod-class-fis = item.class-fiscal.
   end.       

   if avail natur-oper  and
      natur-oper.cd-trib-ipi <> 2 and    /* isento */
      natur-oper.cd-trib-ipi <> 3 then do: /* outros */ 
      if natur-oper.cd-trib-ipi = 4 and /* reduzido */
         item.cd-trib-ipi = 4 then     /* reduzido */
      do:
         assign de-red-base-ipi = natur-oper.perc-red-ipi.
                de-base-ipi = (de-vl-liq * tt-ped-item-prs.qt-pedida) * 
                               (1 - (de-red-base-ipi / 100)).
      end. 
   end.
   else do: /* somente tributa se natureza = T/R e item = T/R */
      assign de-aliquota-ipi = 0.
   end.
   
   assign tt-ped-item-prs.vl-preuni    = de-vl-liq
          tt-ped-item-prs.vl-merc-abe  = de-vl-liq * tt-ped-item-prs.qt-pedida 
          tt-ped-item-prs.vl-liq-it    = de-vl-liq * tt-ped-item-prs.qt-pedida 
          tt-ped-item-prs.vl-liq-abe   = (de-vl-liq * tt-ped-item-prs.qt-pedida) + 
                                          de-base-ipi * (de-aliquota-ipi / 100)
          tt-ped-item-prs.vl-tot-it    = (de-vl-liq * tt-ped-item-prs.qt-pedida) +
                                          de-base-ipi * (de-aliquota-ipi / 100)
          tt-ped-item-prs.aliquota-ipi = de-aliquota-ipi
          tt-ped-item-prs.dt-userimp   = today
          tt-ped-item-prs.user-impl    = c-seg-usuario
          tt-ped-item-prs.dt-userimp   = today
          tt-ped-item-prs.user-impl    = c-seg-usuario
          tt-ped-item-prs.ind-icm-ret  = l-ind-icm-ret
          tt-ped-item-prs.aliquota-icm = de-aliq-icms
          tt-ped-item-prs.vl-bicms-it  = de-base-icms
          tt-ped-item-prs.vl-icms-it   = de-valor-icms
          tt-ped-item-prs.vl-bipi-it   = de-base-ipi.

   assign tt-ped-item-prs.val-ipi = de-base-ipi * (de-aliquota-ipi / 100).

   assign de-vl-tot-ped = de-vl-tot-ped + tt-ped-item-prs.vl-tot-it.

end.
 
procedure emite-nota.

    run pi-acompanhar in h-acomp (input "Gerando Nota").

    /* inicializa‡Æo das BOS para C lculo */
    if not valid-handle(h-bodi317in) then
        run dibo/bodi317in.p persistent set h-bodi317in.

    run inicializaBOS in h-bodi317in(output h-bodi317pr,
                                     output h-bodi317sd,     
                                     output h-bodi317im1bra,
                                     output h-bodi317va).

    /* Limpar a tabela de erros em todas as BOS */
    run emptyRowErrors        in h-bodi317in. 

    trans-block:
    do transaction:

        for each tt-ped-venda-prs:
    
            run criaWtDocto in h-bodi317sd
                    (input  c-seg-usuario,
                     input  tt-ped-venda-prs.cod-estabel,
                     input  c-serie,
                     input  tt-ped-venda-prs.nr-pedcli /* nr-nota */,
                     input  tt-ped-venda-prs.nome-abrev,
                     input  "",
                     input  2, /* Manual */
                     input  9999,
                     input  tt-ped-venda-prs.dt-emissao,
                     input  0, /* N£mero do embarque */
                     input  tt-ped-venda-prs.nat-operacao,
                     input  tt-ped-venda-prs.cod-canal-venda,
                     output i-seq-wt-docto,
                     output l-proc-ok-aux).
    
            /* Caso tenha achado algum erro ou advertˆncia, gera tt-erro */
            run pi-erro-nota(h-bodi317sd,'sd'). if l-cupom-com-erro then undo, return.
    
            for first wt-docto where
                wt-docto.seq-wt-docto = i-seq-wt-docto:
                assign  wt-docto.nr-tabpre    = ""
                        wt-docto.ind-lib-nota = yes
                        wt-docto.cod-cond-pag = tt-ped-venda-prs.cod-cond-pag
                        wt-docto.cod-entrega  = tt-ped-venda-prs.cod-entrega
                        wt-docto.observ-nota  = tt-ped-venda-prs.observacoes
                        wt-docto.ind-tp-frete = tt-ped-venda-prs.ind-tp-frete
                        wt-docto.nr-tab-finan = tt-ped-venda-prs.nr-tab-finan
                        wt-docto.nr-ind-finan = tt-ped-venda-prs.nr-ind-finan
                        wt-docto.val-tot-dupl-infor = de-vl-tot-ped
                        wt-docto.cod-des-merc = 2 /* consumo */
                        wt-docto.dt-base-dup  = tt-ped-venda-prs.dt-emissao.

                run emptyRowErrors          in h-bodi317sd.
                run emptyRowErrors          in h-bodi317va.
                run atualizaDadosGeraisNota in h-bodi317sd(input  i-seq-wt-docto,
                                                           output l-proc-ok-aux).

                /* Caso tenha achado algum erro ou advertˆncia, gera tt-erro */
                run pi-erro-nota(h-bodi317sd,'sd'). if l-cupom-com-erro then undo, return.

                run pi-gera-itens-nota.
                if l-cupom-com-erro then undo, next.

                run pi-calcula-nota.
                if l-cupom-com-erro then undo, next.

                run pi-efetiva-nota.
                if l-cupom-com-erro then undo, next.

            end.    
        end.
    end.
    run pi-elimina-tabelas.
    run pi-finaliza-bos.
end.

procedure pi-finaliza-bos:
    if  valid-handle(h-bodi317va) then delete procedure h-bodi317va.
    if  valid-handle(h-bodi317pr) then delete procedure h-bodi317pr.
    if  valid-handle(h-bodi317sd) then delete procedure h-bodi317sd.
    if  valid-handle(h-bodi317im1bra) then delete procedure h-bodi317im1bra.
end.

procedure pi-gera-itens-nota:
        
    for each tt-ped-item-prs no-lock of tt-ped-venda-prs:

        for first item fields (it-codigo deposito-pad item.cod-localiz)
            no-lock where item.it-codigo = tt-ped-item-prs.it-codigo: end.
        for first item-uni-estab exclusive-lock where 
            item-uni-estab.it-codigo = tt-ped-item-prs.it-codigo and
            item-uni-estab.cod-estabel = tt-ped-venda-prs.cod-estabel: 
            assign item-uni-estab.ind-item-fat = yes.
        end.

        /* Disponibilizar o registro WT-DOCTO na bodi317sd */
        run localizaWtDocto in h-bodi317sd(input  i-seq-wt-docto,
                                           output l-proc-ok-aux). 
        
        run pi-itens.

        /* gerar dados de estoque para sa¡da de itens com lote */
        /* Disp. registro WT-DOCTO, WT-IT-DOCTO e WT-IT-IMPOSTO na bodi317pr */
        run localizaWtDocto       in h-bodi317pr(input  i-seq-wt-docto,
                                                 output l-proc-ok-aux).
        run localizaWtItDocto     in h-bodi317pr(input  i-seq-wt-docto,
                                                 input  i-seq-wt-it-docto,
                                                 output l-proc-ok-aux).
        run localizaWtItImposto   in h-bodi317pr(input  i-seq-wt-docto,
                                                 input  i-seq-wt-it-docto,
                                                 output l-proc-ok-aux).


        /* Atualiza dados c lculados do item */
        run atualizaDadosItemNota in h-bodi317pr(output l-proc-ok-aux).
        /* Caso tenha achado algum erro ou advertˆncia, gera tt-erro */
        run pi-erro-nota(h-bodi317pr,'pr'). if l-cupom-com-erro then undo, return.
        
        /* Valida informa‡äes do item */
        run validaItemDaNota      in h-bodi317va(input  i-seq-wt-docto,
                                                 input  i-seq-wt-it-docto,
                                                 output l-proc-ok-aux).
        /* Caso tenha achado algum erro ou advertˆncia, gera tt-erro */
        run pi-erro-nota(h-bodi317va,'va'). if l-cupom-com-erro then undo, return.
        
    end. /* tt-ped-item-prs */
    if l-cupom-com-erro then undo, leave.
end procedure.

procedure pi-itens:
    def var de-qt-utilizada as decimal no-undo.
    
    /* Cria um item para nota fiscal. */
    run criaWtItDocto in h-bodi317sd  (input  ?,
                                       input  "",
                                       input  tt-ped-item-prs.nr-sequencia,
                                       input  tt-ped-item-prs.it-codigo,
                                       input  tt-ped-item-prs.cod-refer,
                                       input  tt-ped-item-prs.nat-operacao,
                                       output i-seq-wt-it-docto,
                                       output l-proc-ok-aux).
    /* Caso tenha achado algum erro ou advertˆncia, gera tt-erro */
    run pi-erro-nota(h-bodi317sd,'sd'). if l-cupom-com-erro then undo, return.

    /* Grava informa‡äes gerais para o item da nota */
    run gravainfGeraisWtItDocto in h-bodi317sd 
            (input i-seq-wt-docto,
            input i-seq-wt-it-docto,
            input tt-ped-item-prs.qt-pedida,
            input tt-ped-item-prs.vl-preori,
            input 0,
            input (de-desconto /* tt-ped-item-prs.vl-preori) * 100*/ )).

    for first wt-it-docto exclusive-lock where 
        wt-it-docto.seq-wt-docto    = i-seq-wt-docto and
        wt-it-docto.seq-wt-it-docto = i-seq-wt-it-docto:
        assign wt-it-docto.nr-seq-ped       = tt-ped-item-prs.nr-sequencia. 
        assign wt-it-docto.vl-pretab        = tt-ped-item-prs.vl-preori
               wt-it-docto.vl-preori        = tt-ped-item-prs.vl-preori
               wt-it-docto.vl-preuni        = tt-ped-item-prs.vl-preuni
               wt-it-docto.vl-desconto      = 0
               wt-it-docto.vl-desconto-perc = 0
               wt-it-docto.vl-desconto-uni  = tt-ped-item-prs.vl-preori - tt-ped-item-prs.vl-preuni
               wt-it-docto.vl-desconto-tot  = wt-it-docto.vl-desconto-uni * wt-it-docto.quantidade[1].
    end.

    for each wt-it-imposto exclusive-lock 
        where wt-it-imposto.seq-wt-docto    = i-seq-wt-docto
          and wt-it-imposto.seq-wt-it-docto = i-seq-wt-it-docto:

        /* CD TRIB ICMS     -----       CD TRIB IPI
        1 T                 -----       1 T
        2 I                 -----       2 I
        3 O                 -----       3 O
        4 R                 -----       4 R
        5 D
        */

        assign /*wt-it-imposto.ind-icm-ret  = tt-ped-item-prs.ind-icm-ret*/
               wt-it-imposto.aliquota-icm = tt-ped-item-prs.aliquota-icm
               wt-it-imposto.vl-bicms-it  = if wt-it-imposto.cd-trib-icm = 1 then tt-ped-item-prs.vl-bicms-it else 0
               wt-it-imposto.vl-icms-it   = if wt-it-imposto.cd-trib-icm = 1 then tt-ped-item-prs.vl-icms-it else 0
               wt-it-imposto.aliquota-ipi = if wt-it-imposto.cd-trib-ipi = 1 then tt-ped-item-prs.aliquota-ipi else 0
               wt-it-imposto.vl-bipi-it   = if wt-it-imposto.cd-trib-ipi = 1 then tt-ped-item-prs.vl-bipi-it else 0
               wt-it-imposto.vl-ipi-it    = if wt-it-imposto.cd-trib-ipi = 1 then tt-ped-item-prs.val-ipi else 0
               wt-it-imposto.vl-icmsnt-it = if wt-it-imposto.cd-trib-icm = 2 then tt-ped-item-prs.vl-bicms-it else
                                            if wt-it-imposto.cd-trib-icm = 4 then (tt-ped-item-prs.vl-liq-abe - tt-ped-item-prs.vl-bicms-it) else 0
               wt-it-imposto.vl-icmsou-it = if wt-it-imposto.cd-trib-icm = 3 or
                                               wt-it-imposto.cd-trib-icm = 5 then tt-ped-item-prs.vl-bicms-it else 0
               wt-it-imposto.vl-ipint-it  = if wt-it-imposto.cd-trib-ipi = 2 then tt-ped-item-prs.vl-bipi-it else
                                            if wt-it-imposto.cd-trib-ipi = 4 then (tt-ped-item-prs.vl-liq-abe - tt-ped-item-prs.vl-bipi-it) else 0
               wt-it-imposto.vl-ipiou-it  = if wt-it-imposto.cd-trib-ipi = 3 then tt-ped-item-prs.vl-bipi-it else 0.
    end.

    if tt-ped-item-prs.numero-lote <> "" then do:
        for each Wt-fat-ser-lote exclusive-lock 
            where  wt-fat-ser-lote.seq-wt-docto    = i-seq-wt-docto 
              and  wt-fat-ser-lote.seq-wt-it-docto = i-seq-wt-it-docto:
            delete wt-fat-ser-lote.
        end.
        
        de-qt-utilizada = tt-ped-item-prs.qt-pedida.
        for each deposito no-lock where deposito.cons-saldo:
            for each saldo-estoq fields (it-codigo cod-depos cod-localiz lote)
                no-lock where 
                saldo-estoq.cod-estabel = tt-ped-venda-prs.cod-estabel and
                saldo-estoq.cod-depos   = deposito.cod-depos and
                saldo-estoq.lote        = tt-ped-item-prs.numero-lote and
                saldo-estoq.it-codigo   = tt-ped-item-prs.it-codigo and
                saldo-estoq.qtidade-atu > 0:

                if saldo-estoq.qtidade-atu >= tt-ped-item-prs.qt-pedida then 
                    assign de-quantidade = tt-ped-item-prs.qt-pedida.
                else
                    assign de-quantidade = saldo-estoq.qtidade-atu.

                assign de-qt-utilizada = de-qt-utilizada - de-quantidade.

                run criaAlteraWtFatSerLote in h-bodi317sd 
                        (input yes,
                         input i-seq-wt-docto,
                         input i-seq-wt-it-docto,
                         input saldo-estoq.it-codigo,
                         input saldo-estoq.cod-depos,
                         input saldo-estoq.cod-localiz,
                         input saldo-estoq.lote,
                         input de-quantidade,
                         input 0,
                         input ?,
                         output l-proc-ok-aux).
                /* Caso tenha achado algum erro ou advertˆncia, gera tt-erro */
                run pi-erro-nota(h-bodi317sd,'sd'). if l-cupom-com-erro then undo, return.
            end.
        end.
        if de-qt-utilizada > 0 then do:
            assign i-erro = 33
                   c-informacao = c-num-nota + " - " + tt-ped-item-prs.numero-lote
                   l-cupom-com-erro = yes.
            run gera-log. 
            return.
        end.
    end.
end.

procedure pi-calcula-nota:

    def var l-nf-man-dev-terc-dif as log no-undo.
    def var l-recal-apenas-totais as log no-undo.

    run finalizaBOS in h-bodi317in.

    /* Reinicializa‡Æo das BOS para C lculo */
    run dibo/bodi317in.p persistent set h-bodi317in.
    run inicializaBOS in h-bodi317in(output h-bodi317pr,
                                     output h-bodi317sd,     
                                     output h-bodi317im1bra,
                                     output h-bodi317va).

   run retornaVariaveisParaCalculoImpostos in h-bodi317sd (input  i-seq-wt-docto,
                                                           output l-nf-man-dev-terc-dif,
                                                           output l-recal-apenas-totais,
                                                           output l-proc-ok-aux).
   run recebeVariavelTipoCalculoImpostos   in h-bodi317im1bra (input if l-recal-apenas-totais 
                                                                     then 1
                                                                     else 0,
                                                                     output l-proc-ok-aux).

    /* Limpar a tabela de erros em todas as BOS */
    run emptyRowErrors        in h-bodi317in. 

    run inicializaAcompanhamento in h-bodi317pr.

    run localizaWtDocto       in h-bodi317pr(input  i-seq-wt-docto,
                                             output l-proc-ok-aux).
    run localizaWtItDocto     in h-bodi317pr(input  i-seq-wt-docto,
                                             input  i-seq-wt-it-docto,
                                             output l-proc-ok-aux).
    run localizaWtItImposto   in h-bodi317pr(input  i-seq-wt-docto,
                                             input  i-seq-wt-it-docto,
                                             output l-proc-ok-aux).
    run localizaEmitente      in h-bodi317pr(input  tt-ped-venda-prs.cod-emitente,
                                             output l-proc-ok-aux).

    /* refazer wt-fat-duplic se valor em dinheiro + outros */
    run geraCondPagto in h-bodi317pr (input  tt-ped-venda-prs.cod-cond-pag,
                                      output l-proc-ok-aux) . /* Gerar a cond. de pagamento */
    /* Caso tenha achado algum erro ou advertˆncia, gera tt-erro */
    run pi-erro-nota(h-bodi317pr,'pr'). if l-cupom-com-erro then undo, return.
    
    /* Criar duplicatas */
    run criaDuplicatas in h-bodi317pr 
                      (input  if de-vl-tot-ped > de-valor-dinh then de-vl-tot-ped - de-valor-dinh else de-vl-tot-ped,
                       input  0 /*de-ger-ipi*/,
                       input  0 /*de-ger-desp*/,
                       input  0 /*de-ger-iss*/,
                       input  0 /*de-ger-irf*/,
                       input  0 /*de-iss-retido*/,
                       input  0 /*de-ger-inss*/,
                       input  0 /*de-ger-icmsr*/,
                       input  if de-vl-tot-ped > de-valor-dinh then de-valor-dinh else 0,
                       input  0 /*wt-docto.val-base-calc-comis-infor*/,
                       input  0,
                       input  0 /*quantas-dps-ve*/,
                       input  0,
                       input  0,
                       input  0,
                       output l-proc-ok-aux).
    /* Caso tenha achado algum erro ou advertˆncia, gera tt-erro */
    run pi-erro-nota(h-bodi317pr,'pr'). if l-cupom-com-erro then undo, return.

    run validaDuplicatasDigitadas in h-bodi317va(input  wt-docto.seq-wt-docto,
                                                 output l-proc-ok-aux).
    /* Caso tenha achado algum erro ou advertˆncia, gera tt-erro */
    run pi-erro-nota(h-bodi317va,'va'). if l-cupom-com-erro then undo, return.

    run confirmaCalculo          in h-bodi317pr(input  i-seq-wt-docto,
                                                output l-proc-ok-aux).

    run finalizaAcompanhamento   in h-bodi317pr.

    /* Caso tenha achado algum erro ou advertˆncia, gera tt-erro */
    run pi-erro-nota(h-bodi317pr,'pr'). if l-cupom-com-erro then undo, return.

end procedure.

procedure pi-efetiva-nota:
    /* Efetiva a nota */
    run dibo/bodi317ef.p persistent set h-bodi317ef.
    run emptyRowErrors           in h-bodi317in. 
    run inicializaAcompanhamento in h-bodi317ef.
    run setaHandlesBOS           in h-bodi317ef(h-bodi317pr,     
                                                h-bodi317sd, 
                                                h-bodi317im1bra, 
                                                h-bodi317va).
    run efetivaNota              in h-bodi317ef(input  i-seq-wt-docto,
                                                input  no, /* mantem numero */
                                                output l-proc-ok-aux).
    run finalizaAcompanhamento   in h-bodi317ef.
    /* Caso tenha achado algum erro ou advertˆncia, gera tt-erro */
    run pi-erro-nota(h-bodi317ef,'ef'). if l-cupom-com-erro then undo, return.

    /* Busca as notas fiscais geradas */
    run buscaTTNotasGeradas in h-bodi317ef(output l-proc-ok-aux,
                                           output table tt-notas-geradas).

    for each tt-notas-geradas:
        for first nota-fiscal exclusive-lock where 
            rowid(nota-fiscal) = tt-notas-geradas.rw-nota-fiscal:
            assign nota-fiscal.docto-orig = c-docto-orig
                   nota-fiscal.obs-gerada = c-obs-gerada.
            for each fat-duplic exclusive where 
                fat-duplic.cod-estabel = nota-fiscal.cod-estabel and
                fat-duplic.serie       = nota-fiscal.serie and
                fat-duplic.nr-fatura   = nota-fiscal.nr-fatura:
                if fat-duplic.cod-vencto = 3 then 
                    assign fat-duplic.int-1 = i-cod-port-dinh
                           fat-duplic.int-2 = i-modalid-dinh.
                else
                    assign fat-duplic.int-1 = i-cod-portador
                           fat-duplic.int-2 = i-modalidade.
            end.
            for first tt-cst-nota-fiscal no-lock of nota-fiscal:
                create cst-nota-fiscal.
                buffer-copy tt-cst-nota-fiscal to cst-nota-fiscal.
            end.
        end.
    end.
   /* Elimina o handle do programa bodi317ef */
   delete procedure h-bodi317ef.
end.

/*
procedure pi-dados-adc:

        run dibo/bodi515.p persistent set h-bodi515.
        run openQueryStatic in h-bodi515 (input "Main":U).

        create tt-nota-fisc-adc.
        assign tt-nota-fisc-adc.cod-estab        = wt-docto.cod-estabel
               tt-nota-fisc-adc.cod-serie        = wt-docto.serie     
               tt-nota-fisc-adc.cod-nota-fisc    = string(wt-docto.seq-wt-docto)
               tt-nota-fisc-adc.cdn-emitente     = wt-docto.cod-emitente
               tt-nota-fisc-adc.cod-natur-operac = wt-docto.nat-operacao 
               tt-nota-fisc-adc.idi-tip-dado     = 4
               nota-fisc-adc.cod-model-ecf       = int-ds-nota-loja.versaopdv
               nota-fisc-adc.cod-fabricc-ecf     = int-ds-nota-loja.impressora
               nota-fisc-adc.cod-terminal        = int-ds-nota-loja.indterminal
               nota-fisc-adc.cod-cx-ecf          = int-ds-nota-loja.indterminal.

        run setRecord in h-bodi515 (input table tt-nota-fisc-adc).
        run emptyRowErrors in h-bodi515.
        if return-value = "OK":U then 
            run createRecord in h-bodi515.
        run getRowErrors in h-bodi515 (output table rowErrors).

        if can-find(first RowErrors) then run pi_erros.

end procedure.
*/

procedure pi-erro-nota:
    define input parameter h-bo as handle.
    define input parameter c-bo as char no-undo.

    def var c-proc as char no-undo.
    c-proc = "devolveErrosbodi317" + c-bo.

    /* Busca poss¡veis erros que ocorreram nas valida‡äes */
    run value(c-proc) in h-bo (output c-ultimo-metodo-exec,
                               output table RowErrors).
    for each RowErrors:
        /*if RowErrors.errornumber = 15450 then next. /* saldo */ */
        if RowErrors.errornumber = 15046 then next. /* aviso */
        if RowErrors.errornumber = 15047 then next. /* aviso */
        if RowErrors.errornumber = 15091 then next. /* aviso */
        assign i-erro = 22
               c-informacao = c-num-nota + " - " + 
                              string(RowErrors.errornumber) + '-' + 
                              RowErrors.errordescription
               l-cupom-com-erro = yes.
        run gera-log. 
        return.
    end.
end.

procedure gera-log.

   run pi-acompanhar in h-acomp (input "Listando Erros").

   display stream str-rp
           i-nr-registro
           with frame f-erro. 
       
   display stream str-rp
           tb-erro[i-erro] @ tb-erro[1]
           c-informacao
           with frame f-erro.
   down stream str-rp
        with frame f-erro.

   run intprg/int999.p ("CUPOM", 
                        int-ds-nota-loja.cnpj_filial + "/" + c-serie  + "/" + trim(string(int(c-num-nota),">>9999999")),
                        (trim(tb-erro[i-erro]) + " - " + c-informacao),
                        int-ds-nota-loja.situacao, /* 1 - Pendente, 2 - Processado */ 
                        c-seg-usuario).
   assign c-informacao = " ".
end.
/* FIM DO PROGRAMA */




