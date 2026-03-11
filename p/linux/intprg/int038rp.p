/********************************************************************************
** Programa: INT038 - Gera‡Æo notas fiscais a partir de Pedidos Balan‡o 
**
** Versao : 1 - 10/2016 - ResultPro
**
********************************************************************************/
/* include de controle de versao */
{include/i-prgvrs.i INT038 2.12.02.AVB}
{cdp/cdcfgdis.i}
{utp/ut-glob.i}

/* definiçao das temp-s para recebimento de parametros */
define temp-table tt-param no-undo
    field destino          as integer
    field arquivo          as char format "x(35)":U
    field usuario          as char format "x(12)":U
    field data-exec        as date
    field hora-exec        as integer
    field dt-periodo-ini   as date format "99/99/9999"
    field dt-periodo-fim   as date format "99/99/9999"
    field cod-estabel-ini  as char format "x(03)"
    field cod-estabel-fim  as char format "x(03)"
    field pedido-ini       as integer format ">>>>>>>9"
    field pedido-fim       as integer format ">>>>>>>9"
    field txt-obs          as char    format "X(300)".                               

def temp-table tt-raw-digita
        field raw-digita	as raw.

def temp-table tt-ped-venda-prs no-undo like ped-venda.

def temp-table tt-ped-item-prs  no-undo like ped-item
    field numero-caixa as char format "x(20)"
    field numero-lote  as char format "x(20)"
    field nr-docum     like docum-est.nro-docto
    field serie-docum  like docum-est.serie-docto
    field nat-docum    like docum-est.nat-operacao
    field seq-docum    like item-doc-est.sequencia.

def temp-table tt-balanco no-undo
field ped_tipopedido_n like int_ds_pedido.ped_tipopedido_n.

define temp-table tt-item
    field it-codigo like item.it-codigo.

define temp-table tt-estab no-undo
    field cod-estabel     like estabelec.cod-estabel
    field cgc             like estabelec.cgc 
    field dt-fim-operacao like cst_estabelec.dt_fim_operacao.

def temp-table tt-nota no-undo
    field situacao     as integer
    field nro-docto    like docum-est.nro-docto   
    field serie-nota   like docum-est.serie-docto
    field serie-docum  like docum-est.serie-docto        
    field cod-emitente like docum-est.cod-emitente
    field nat-operacao like docum-est.nat-operacao
    field tipo-nota    like int_ds_docto_xml.tipo_nota
    field valor-mercad like doc-fisico.valor-mercad.

{inbo/boin090.i tt-docum-est}       /* definiCAo tt-docum-est       */
{inbo/boin176.i tt-item-doc-est}    /* definiCAo tt-item-doc-est    */

def temp-table tt-nota-ent          no-undo like tt-nota.
def temp-table tt-docum-est-ent     no-undo like tt-docum-est.
def temp-table tt-item-doc-est-ent  no-undo like tt-item-doc-est.
               
def temp-table tt-nfe no-undo
    field ped_codigo_n like int_ds_pedido.ped_codigo_n
    field nro-docto    as integer.

def temp-table tt-nfs no-undo
    field ped_codigo_n like int_ds_pedido.ped_codigo_n.

def temp-table tt-it-nfe no-undo
    field ped_codigo_n like  int_ds_pedido.ped_codigo_n
    field nro-docto    as integer
    field it-codigo    like  item.it-codigo 
    field quantidade   like  int_ds_pedido_retorno.rpp_quantidade_n
    field vl-uni       like item-uni-estab.preco-base
    field nr-caixa     as    char
    field lote         like  movto-estoq.lote.

def temp-table tt-it-nfs no-undo
    field ped_codigo_n like  int_ds_pedido.ped_codigo_n
    field it-codigo    like  item.it-codigo 
    field quantidade   like  int_ds_pedido_retorno.rpp_quantidade_n
    field vl-uni       like item-uni-estab.preco-base
    field nr-caixa     as    char
    field lote         like  movto-estoq.lote.
                     
def temp-table tt-notas-geradas no-undo
    field rw-nota-fiscal   as rowid
    field nr-nota        like nota-fiscal.nr-nota-fis
    field seq-wt-docto   like wt-docto.seq-wt-docto.

define temp-table tt-param-re
    field destino            as integer
    field arquivo            as char
    field usuario            as char
    field data-exec          as date
    field hora-exec          as integer
    field classifica         as integer
    field c-cod-estabel-ini  as char
    field c-cod-estabel-fim  as char
    field i-cod-emitente-ini as integer
    field i-cod-emitente-fim as integer
    field c-nro-docto-ini    as char
    field c-nro-docto-fim    as char
    field c-serie-docto-ini  as char
    field c-serie-docto-fim  as char
    field c-nat-operacao-ini as char
    field c-nat-operacao-fim as char
    field da-dt-trans-ini    as date
    field da-dt-trans-fim    as date.

define temp-table tt-digita-re
    field r-docum-est        as rowid.

def temp-table tt-raw-digita-re
   field raw-digita   as raw.

def temp-table tt-arquivo-erro
    field c-linha as char.

def temp-table tt-erro-nota no-undo
    field serie        as char format "x(03)"
    field nro-docto    as char format "9999999"
    field cod-emitente as integer format ">>>>>>>>9"
    field cod-erro     as integer format ">>>>>9"
    field descricao    as char.

DEF BUFFER bf-docum-est FOR docum-est.

{dibo/bodi317sd.i1}

/* temp-tables das API's e BO's */
{method/dbotterr.i}

/* recebimento de parametros */
def input parameter raw-param as raw no-undo.
def input parameter table for tt-raw-digita.  

create tt-param.                    
raw-transfer raw-param to tt-param no-error.
if tt-param.arquivo = "" then 
    assign tt-param.arquivo         = "INT038.txt"
           tt-param.destino         = 3
           tt-param.data-exec       = TODAY
           tt-param.hora-exec       = TIME
           tt-param.dt-periodo-ini  = 10/01/2016 
           tt-param.dt-periodo-fim  = TODAY 
           tt-param.cod-estabel-ini = ""  
           tt-param.cod-estabel-fim = "ZZZ" 
           tt-param.pedido-ini      = 0 
           tt-param.pedido-fim      = 999999999.
              

/* include padrao para variáveis de relatório  */
{include/i-rpvar.i}

/* ++++++++++++++++++ (definicao stream) ++++++++++++++++++ */

/* ++++++++++++++++++ (definicao Buffer) ++++++++++++++++++ */
define buffer btransporte     for transporte.
define BUFFER b-int_ds_pedido for int_ds_pedido.
define BUFFER b-item          for item.
define BUFFER b-docum-est     for docum-est.
define BUFFER b-nota-fiscal   for nota-fiscal.

/* definiçao de variaveis  */
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

def VAR i-pos-arq            as integer                   no-undo.
def VAR c-nr-nota            as char format "x(07)"       no-undo.
def VAR c-linha              as char.
def VAR c-cod-depos          as char.
def VAR c-nat-docum          as char    no-undo.
def VAR i-nro-docto          as int     no-undo.
def VAR i-seq-entrada        as int     no-undo.
def VAR l-nota-saida         as logical no-undo.

def var c-nr-pedcli          like ped-venda.nr-pedcli.
def var c-observacao         as char.
def var c-cond-redespacho    as char.
def var i-cod-emitente       like emitente.cod-emitente.
def var i-cod-rep            as integer.
def var c-nr-tabpre          as char.
def var i-cod-cond-pag       as integer.
def var c-nr-pedido          as char.
def var c-tp-transp          as char.
def var c-cod-transp         as char.
def var c-it-codigo          as char.
def var de-quantidade        as decimal.
def var c-natur              like ped-venda.nat-operacao.
def VAR c-natur-ent          like natur-oper.nat-operacao.
def var de-vl-uni            like item-uni-estab.preco-base.
def var de-desconto          as decimal no-undo.
def var i-tab-finan          as integer.
def var i-indice             as integer.
def var c-nome-transp        like transporte.nome-abrev.
def var de-aliquota-ipi      as decimal.
def var de-preco             like preco-item.preco-venda.
def var de-preco-liq         like ped-item.vl-preuni.
def var c-cod-refer          as char.
def var c-cod-entrega        as char.
def var c-cidade-cif         as char.
def var c-redespacho         as char.
def var i-canal-vendas       as integer.
def var c-cod-rota           as char.
def var i-nr-registro        as integer init 0.
def var c-informacao         as char format "x(220)".
def var i-erro               as integer init 0.
def var l-movto-com-erro     as logical init NO no-undo.
def var d-dt-emissao         as date.
def var d-dt-entrega         as date.
def var d-dt-implantacao     as date.
def var i-nr-sequencia       as integer.
def var c-nome-repres        as character.
def var c-placa              as character.
def var c-uf-placa           as character.
def var c-numero-caixa       as character.
def var c-numero-lote        as character.
def var c-tp-pedido          as character.
def var c-docto-orig         as character.
def var c-obs-gerada         as character.
def var tb-erro              as char format "x(60)" extent 49 init
                             ["01. Faturado com Sucesso                          ",
                              "02. Cliente nao Cadastrado                        ",
                              "03. Tabela de preco nao Cadastrada                ",
                              "04. Tabela de preco fora do limite                ",
                              "05. Tabela de preco Inativa                       ",
                              "06. Data Emissao Invalida                         ",
                              "07. Data Entrega Invalida                         ",
                              "08. Data Implantacao Invalida                     ",
                              "09. Produto nao Cadastrado                        ",
                              "10. Produto esta obsoleto                         ",
                              "11. Produto nao disponivel para venda             ",
                              "12. Quantidade Invalida                           ",
                              "13. Representante nao Cadastrado                  ",
                              "14. Cliente nao eh do Representante               ",
                              "15. Condicao de Pagamento Nao Cadastrada          ",
                              "16. Transportador Nao Cadastrado                  ",
                              "17. Numero do Pedido Interno Invalido             ",
                              "18. Documento a ser devolvido                     ",
                              "19. Saldo 3os insuficiente para qtde a devolder   ",
                              "20.*** Pedido de Venda nao Importado ***          ",
                              "21. Natureza de Operacao nao Cadastrada em INT115 ",
                              "22. ERRO BO de Calculo                            ",
                              "23. Transportador de redespachop NAO Cadastrado   ",
                              "24. Codigo do Cliente p/ Entrega NAO Existe       ",
                              "25. Quantidade de parcelas p/ pagto inconsistente ",
                              "26. Cliente so pode comprar A Vista               ",
                              "27. Cliente esta Suspenso                         ",
                              "28. Nat de Operacao Devolucao exige nota origem   ",
                              "29. Nota origem Informada e Nat. Oper. Envio      ",
                              "30. Estabelecimento nao Cadastrado/fora de Oper.  ",
                              "31. Canal de vendas nao Cadastrado                ",
                              "32. Nat.Operacao indicada esta Inativa            ",
                              "33. Saldo estoque insuficiente p/ envio do lote   ",
                              "34. Natureza de Opera‡Æo deve ser Entrada         ",
                              "35. Tabela de Financiamento NAO Cadastrada        ",
                              "36. Pedido j  foi faturado                        ",
                              "37. Pedido inconsistente ou sem itens             ",
                              "38. Valor do item zerado                          ",
                              "39. Documento j  cadastrado pendente atualiza‡Æo  ",
                              "40. Natureza de Opera‡Æo deve ser de entrada NFE",
                              "41. Nota Deve ser autorizada pelo SEFAZ",
                              "42. Classifica‡ao Fiscal do item nÆo cadastrada",
                              "43. Nat. de Opera‡Æo deve estar marcada p/ gerar faturamento",
                              "44. Item d‚bito direto nÆo possui cta cont bil cadastrada",
                              "45. Usu rio do Faturamento nÆo cadastrado",
                              "46. S‚rie Estab. deve ter forma emissÆo AUTOMµTICA",
                              "47. S‚rie X Estab. de emissÆo deve ser de NFe     ",
                              "48. AVISO: Nota de sa¡da j  emitida               ",
                              "49. AVISO: Nota de entrada j  emitida             "].

def var i-qt-volumes    as integer  format ">>>>9" init 0.
def var i-qt-caixas     as integer.
def var d-pes-liq-tot   as decimal format ">>,>>9.99" no-undo.
def var de-peso-itens   as dec  format ">>>,>>9.99" init 0. 
def var i-cont          as int init 0.
def var de-red-base-ipi as decimal no-undo.
def var de-base-ipi     as decimal no-undo.
def var i-seq-docum     as integer no-undo.
def var c-nr-docum      as char no-undo.
def var c-serie-docum   as char no-undo.
def var c-uf-destino    as char no-undo. 
def var c-uf-origem     as char no-undo. 
def var c-cod-estabel   as char no-undo.
def var c-nome-abrev    as char no-undo.
def var l-ind-icm-ret   as logical no-undo.
def var c-class-fiscal  as char no-undo.
def var i-cod-portador  as integer no-undo.
def var i-modalidade    as integer no-undo.
def var c-serie         as char no-undo.
def VAR c-serie-ent     as char no-undo.
def var r-rowid         as rowid no-undo.
def var i-cst-icms      as integer no-undo.
def VAR l-movto-entrada-erro as logical no-undo.
DEF VAR r-docum-est     AS ROWID NO-UNDO.

def new global shared var i-nro-docto-int038 as integer format "9999999"  no-undo. /* Retorna a nota gerada */

{utp/ut-glob.i}

/* definiçao de frames do relatório */
form i-nr-registro    column-label "Sequencia"
     tb-erro[1]       column-label "Mensagem"
     c-informacao     column-label "Conteudo"
     with no-box no-attr-space width 400
     down stream-io frame f-erro.

/* include com a definiçao da frame de cabeçalho e rodapé */
{include/i-rpcab.i &stream="str-rp"}
/* bloco principal do programa */

{utp/utapi019.i}

find first tt-param no-lock no-error.
assign c-programa       = "INT038RP"
       c-versao         = "2.12"
       c-revisao        = ".02.AVB"
       c-empresa        = "* Nao definido *"
       c-sistema        = "Faturamento"
       c-titulo-relat   = "Gera‡Æo de Notas Fiscais - Pedidos de Balan‡o".

/* ----- inicio do programa ----- */
for first param-global no-lock: end.
for mgadm.empresa fields (razao-social) where
    empresa.ep-codigo = param-global.empresa-prin no-lock: end.
assign c-empresa = mgadm.empresa.razao-social.

opcao: 
do:
   run utp/ut-acomp.p persistent set h-acomp.
   run pi-inicializar in h-acomp (input "Processando").

   if tt-param.arquivo <> "" then do:
       {include/i-rpout.i &stream = "stream str-rp"}
                             
       view stream str-rp frame f-cabec.
       view stream str-rp frame f-rodape.
   end.

   run pi-elimina-tabelas.
   run pi-importa.

   pause 3 no-message.
end.
/* ----- fim do programa -------- */
run pi-elimina-tabelas.

if tt-param.arquivo <> "" then do:
    /* fechamento do output do relatorio  */
    {include/i-rpclo.i &stream="stream str-rp"}
end.
RUN intprg/int888.p (INPUT "NF PED",
                     INPUT "INT038RP.P").
run pi-finalizar in h-acomp.

return "OK".

/* procedures */

procedure pi-elimina-tabelas.
   run pi-acompanhar in h-acomp (input "Eliminando Tabelas Temporarias").
   /* limpa temp-tables */
   empty temp-table tt-ped-venda-prs.
   empty temp-table tt-ped-item-prs. 

   empty temp-table tt-nfe.
   empty temp-table tt-it-nfe.
   empty temp-table tt-nfs.
   empty temp-table tt-it-nfs.
   empty temp-table tt-nota.
   empty temp-table tt-docum-est.
   empty temp-table tt-item-doc-est.
   empty temp-table tt-nota-ent.
   empty temp-table tt-docum-est-ent.
   empty temp-table tt-item-doc-est-ent.
   empty temp-table tt-item.

   empty temp-table RowErrors.   
   empty temp-table tt-envio2.
   empty temp-table tt-mensagem.
end.        

procedure pi-importa:
    
    run pi-acompanhar in h-acomp (input "Lendo Pedidos").
    
    assign i-nr-registro    = 0.

    empty temp-table tt-balanco.
    empty temp-table tt-estab.

    for each estabelec no-lock where
             estabelec.cod-estabel >= tt-param.cod-estabel-ini and 
             estabelec.cod-estabel <= tt-param.cod-estabel-fim :
    
        create tt-estab.
        assign tt-estab.cod-estabel = estabelec.cod-estabel
               tt-estab.cgc         = estabelec.cgc. 

        for first cst_estabelec no-lock where 
                  cst_estabelec.cod_estabel = estabelec.cod-estabel:
                
            assign tt-estab.dt-fim-operacao = cst_estabelec.dt_fim_operacao.

        end.
    
    end.

    for each int_ds_mod_pedido no-lock where int_ds_mod_pedido.cod_prog_dtsul = "int038",
        each int_ds_tipo_pedido no-lock where int_ds_tipo_pedido.cod_mod_pedido = int_ds_mod_pedido.cod_mod_pedido
         and int_ds_tipo_pedido.log_ativo = yes:
        run pi-cria-balanco(input int(int_ds_tipo_pedido.tp_pedido)).
    end.
    /*
    do i-cont = 1 TO 36:
        case i-cont:
            when 3  then run pi-cria-balanco(input i-cont). /* BALANCO MANUAL FILIAL */
            when 11 then run pi-cria-balanco(input i-cont). /* BALANCO MANUAL DEPOSITO */
            when 12 then run pi-cria-balanco(input i-cont). /* BALANCO COLETor FILIAL */
            when 13 then run pi-cria-balanco(input i-cont). /* BALANCO COLETor DEPOSITO */
            when 14 then run pi-cria-balanco(input i-cont). /* BALANCO MANUAL FILIAL - PERMITE CONSOLIDA€ÇO */  
            when 31 then run pi-cria-balanco(input i-cont). /* BALANCO MANUAL FILIAL - ESPECIAL (MED. CONTROLAdo) */  
            when 35 then run pi-cria-balanco(input i-cont). /* BALAN€O GERAL CONTROLAdoS DEPOSITO */  
            when 36 then run pi-cria-balanco(input i-cont). /* BALAN€O GERAL CONTROLAdoS FILIAL */  
            when 30 then run pi-cria-balanco(input i-cont). /* BALAN€O CD Î ROTATIVO  */  

        end case.
    end.
    */
    find first para-fat no-error.

    for each tt-balanco ,
        each int_ds_pedido no-lock where 
             int_ds_pedido.ped_tipopedido_n = tt-balanco.ped_tipopedido_n and
             int_ds_pedido.ped_codigo_n    >=  tt-param.pedido-ini        and  
             int_ds_pedido.ped_codigo_n    <=  tt-param.pedido-fim        and
        date(int_ds_pedido.dt_geracao)     >= tt-param.dt-periodo-ini     and                
        date(int_ds_pedido.dt_geracao)     <= tt-param.dt-periodo-fim     and 
             int_ds_pedido.situacao         = 1 ,
        last tt-estab where
             tt-estab.cgc = int_ds_pedido.ped_cnpj_destino_s  and 
             tt-estab.dt-fim-operacao >= int_ds_pedido.dt_geracao query-tuning(no-lookahead):

        run pi-acompanhar in h-acomp (input "Lendo Pedidos Invent rio: " + string(int_ds_pedido.ped_codigo_n)).

        assign  l-movto-com-erro    = no
                c-uf-destino        = ""
                c-uf-origem         = ""
                c-nr-pedcli         = trim(string(int_ds_pedido.ped_codigo_n))
                d-dt-implantacao    = today
                d-dt-entrega        = int_ds_pedido.ped_dataentrega_d
                d-dt-emissao        = /*int_ds_pedido.ped-data-d*/ d-dt-implantacao
                c-observacao        = string(int_ds_pedido.ped_observacao_s) 
                c-placa             = if int_ds_pedido.ped_placaveiculo_s  <> ? then int_ds_pedido.ped_placaveiculo_s  else ""
                c-uf-placa          = if int_ds_pedido.ped_estadoveiculo_s <> ? then int_ds_pedido.ped_estadoveiculo_s else ""
                c-tp-pedido         = trim(string(int_ds_pedido.ped_tipopedido_n))
                c-docto-orig        = trim(string(int_ds_pedido.ped_codigo_n))
                c-serie             = ""
                c-serie-ent         = "".

        if tt-param.txt-obs <> "" then do:
            if  c-observacao <> "" and
                c-observacao <> ? 
            then
                assign c-observacao = c-observacao + CHR(13) + CHR(13) + tt-param.txt-obs. 
            else
                assign c-observacao = tt-param.txt-obs.
        end.
        run valida-pedido.

        assign i-nr-registro = i-nr-registro + 1.

        assign  c-it-codigo         = ""
                de-quantidade       = 0
                de-vl-uni           = 0
                de-preco            = 0 
                de-desconto         = 0
                c-numero-caixa      = ""
                c-numero-lote       = ""
                c-nr-docum          = ""
                c-serie-docum       = ""
                i-seq-docum         = 0
                c-class-fiscal      = ""
                i-seq-entrada       = 0
                i-nro-docto         = 1.

        if not l-movto-com-erro 
        then do:
            for each int_ds_pedido_produto no-lock of int_ds_pedido ,
                each int_ds_pedido_retorno no-lock of int_ds_pedido_produto 
                query-tuning(no-lookahead)
                break by int_ds_pedido_retorno.ppr_produto_n
                      by int_ds_pedido_retorno.rpp_lote_s:
                        
                assign de-vl-uni           = 0
                       c-it-codigo         = trim(string(int_ds_pedido_produto.ppr_produto_n))
                       de-quantidade       = int_ds_pedido_retorno.rpp_quantidade_n - int_ds_pedido_retorno.rpp_qtd_inventario_n 
                       de-desconto         = int_ds_pedido_produto.ppr_percentualdesconto_n
                       c-numero-caixa      = ""
                       c-numero-caixa      = (if c-numero-caixa = ""
                                              then string(int_ds_pedido_retorno.rpp_caixa_n)
                                              else c-numero-caixa + "," + string(int_ds_pedido_retorno.rpp_caixa_n))
                       c-numero-lote       = if trim(int_ds_pedido_retorno.rpp_lote_s) <> "?" and
                                                trim(int_ds_pedido_retorno.rpp_lote_s) <> ? then trim(int_ds_pedido_retorno.rpp_lote_s) else "".

                run pi-calcula-preco.

                /* prepara tt para notas de entrada */
                if de-quantidade > 0 
                then do:
                    if int_ds_pedido_produto.nen_notafiscal_n = ? or
                       int_ds_pedido_produto.nen_notafiscal_n = 0 then do:
                        assign i-seq-entrada = i-seq-entrada + 1.

                        if i-seq-entrada = para-fat.nr-item-nota then
                          assign i-nro-docto   = i-nro-docto + 1
                                 i-seq-entrada = 1.

                        for first tt-nfe no-lock where
                            tt-nfe.ped_codigo_n = int_ds_pedido.ped_codigo_n and  
                            tt-nfe.nro-docto    = i-nro-docto : end.
                        if not avail tt-nfe 
                        then do:
                             create tt-nfe.
                             assign tt-nfe.ped_codigo_n = int_ds_pedido.ped_codigo_n
                                    tt-nfe.nro-docto    = i-nro-docto. 
                             run valida-nota-entrada.
                        end.

                        if not l-movto-com-erro then do:
                            find first tt-it-nfe where 
                                tt-it-nfe.ped_codigo_n = int_ds_pedido.ped_codigo_n and 
                                tt-it-nfe.nro-docto    = i-nro-docto                and  
                                tt-it-nfe.it-codigo    = c-it-codigo                and
                                tt-it-nfe.lote         = c-numero-lote no-error.    
                            if not avail tt-it-nfe 
                            then do:
                               create tt-it-nfe.
                               assign tt-it-nfe.ped_codigo_n = int_ds_pedido.ped_codigo_n
                                      tt-it-nfe.nro-docto    = i-nro-docto    
                                      tt-it-nfe.it-codigo    = c-it-codigo 
                                      tt-it-nfe.quantidade   = de-quantidade
                                      tt-it-nfe.vl-uni       = de-vl-uni 
                                      tt-it-nfe.nr-caixa     = c-numero-caixa
                                      tt-it-nfe.lote         = c-numero-lote.
                            end.
                            else 
                               assign tt-it-nfe.quantidade   = tt-it-nfe.quantidade + de-quantidade.  
                            run valida-item-entrada. 
                        end.
                    end.
                end.

                /* prepara tt para Notas de Sa¡da */
                else if de-quantidade < 0 
                then do:
                    /* Quando gera mais de uma nota de sa¡da para o pedido, pode ter notas canceladas
                       que precisam ser emitidas novamente. SerÆo emitidos apenas os itens cancelados.
                       Este campo (int_ds_pedido_produto.nen_notafiscal_n) ‚ gravado na trigger de write da tabela nota-fiscal */
                    if  int_ds_pedido_produto.nen_notafiscal_n = ? or /* J  emitiu nota e nÆo foi cancelada */
                        int_ds_pedido_produto.nen_notafiscal_n = 0     /* J  emitiu nota e nÆo foi cancelada */
                    then do:
                        for first tt-nfs no-lock where
                            tt-nfs.ped_codigo_n = int_ds_pedido.ped_codigo_n: end.
                        if not avail tt-nfs 
                        then do:
                            create tt-nfs.
                            assign tt-nfs.ped_codigo_n = int_ds_pedido.ped_codigo_n.

                            run valida-nota-saida.
                        end.

                        if not l-movto-com-erro then do:
                            find first tt-it-nfs where
                                tt-it-nfs.ped_codigo_n = int_ds_pedido.ped_codigo_n and 
                                tt-it-nfs.it-codigo    = c-it-codigo                and
                                tt-it-nfs.lote         = c-numero-lote no-error.
                            if not avail tt-it-nfs 
                            then do:
                               create tt-it-nfs.
                               assign tt-it-nfs.ped_codigo_n = int_ds_pedido.ped_codigo_n
                                      tt-it-nfs.it-codigo    = c-it-codigo 
                                      tt-it-nfs.quantidade   = de-quantidade * -1
                                      tt-it-nfs.vl-uni       = de-vl-uni 
                                      tt-it-nfs.nr-caixa     = c-numero-caixa
                                      tt-it-nfs.lote         = c-numero-lote.
                            end.
                            else 
                               assign tt-it-nfs.quantidade   = tt-it-nfs.quantidade + (de-quantidade * -1).
                            run valida-item-saida. 
                        end.
                    end.
                end.

                /*put stream str-rp c-it-codigo skip.*/
                if last(int_ds_pedido_retorno.rpp_lote_s)
                then do:
                    for first tt-nfs no-lock where
                              tt-nfs.ped_codigo_n = int_ds_pedido.ped_codigo_n: end.
                    if avail tt-nfs 
                    then do:
                        find first tt-ped-venda-prs use-index ch-pedido where 
                                   tt-ped-venda-prs.nome-abrev = c-nome-abrev and
                                   tt-ped-venda-prs.nr-pedcli  = c-nr-pedcli no-error.
                         if not avail tt-ped-venda-prs 
                         then do:
                            run pi-cria-tt-ped-venda-prs.
                            assign i-nr-sequencia = 0.
                        end.   
                    end.

                    /*put stream str-rp "pi-cria-tt-docum-est 0" skip.*/
                    run pi-cria-tt-docum-est. 
                end.   
            end. /* for each int_ds_pedido_produto */
        end. /* l-movto-com-erro */

        find first tt-ped-venda-prs no-error.
        
        if avail tt-ped-venda-prs
        then do:
            for first tt-ped-item-prs: end.
                           
            if not l-movto-com-erro and not avail tt-ped-item-prs 
            then do:
              assign i-erro = 37
                    c-informacao = "Pedido: " + c-nr-pedcli + " CNPJ origem: " + string(int_ds_pedido.ped_cnpj_origem) + " Saida"
                    l-movto-com-erro = yes.
             run gera-log. 
    
            end.
        end.
    
        find first tt-nfe no-error.
        
        if avail tt-nfe 
        then do:
            for first tt-item-doc-est-ent: end.
            if not l-movto-com-erro and not avail tt-item-doc-est-ent 
            then do:
              assign i-erro = 37
                    c-informacao = "Pedido: " + c-nr-pedcli + " CNPJ origem: " + string(int_ds_pedido.ped_cnpj_origem) + " Entrada"
                    l-movto-com-erro = yes.
               run gera-log. 
            end.
        end.
            
        run pi-acompanhar in h-acomp (input "Finalizando Pedido").
        
        if not l-movto-com-erro 
        then do:

            run pi-altera-itens(input 2). 
             
            run emite-nota-entrada. 
            if not l-movto-com-erro 
            then do:

                 assign l-nota-saida = NO.
    
                 find first tt-ped-venda-prs use-index ch-pedido where 
                            tt-ped-venda-prs.nome-abrev = c-nome-abrev and
                            tt-ped-venda-prs.nr-pedcli  = c-nr-pedcli no-error.
                 if avail tt-ped-venda-prs 
                 then do:
                     run emite-nota-saida.
                 end.
            end.

            if not l-movto-com-erro and 
               not l-movto-entrada-erro and
               can-find (first nota-fiscal no-lock where
                         nota-fiscal.cod-estabel = c-cod-estabel and 
                         nota-fiscal.nr-pedcli   = string(int_ds_pedido.ped_codigo_n))
            then do:
               find first b-int_ds_pedido  where 
                          rowid(b-int_ds_pedido) = rowid(int_ds_pedido) no-error.
               if avail b-int_ds_pedido 
               then do:
                   assign b-int_ds_pedido.situacao = 2 /* integrado */.
                   assign i-erro       = 1
                          c-informacao = "Pedido: "    +  c-nr-pedcli
                                       + " Emitente: " + c-nome-abrev.
                   run gera-log.
                end.
    
                release b-int_ds_pedido.
    
                for each nota-fiscal no-lock where
                         nota-fiscal.cod-estabel = c-cod-estabel and 
                         nota-fiscal.nr-pedcli   = string(int_ds_pedido.ped_codigo_n):
                 
                    disp stream str-rp 
                        nota-fiscal.cod-estabel AT 63
                        nota-fiscal.serie
                        nota-fiscal.nr-nota-fis  
                        nota-fiscal.nat-operacao
                        nota-fiscal.dt-emis
                        nota-fiscal.dt-cancel
                        with stream-IO width 333 down frame f-notas.
                    down with frame f-notas.
                end.
            end.
    
             /* run pi-altera-itens(input 4).  NÆo voltar antes de atualizar a nota no estoque */ 

        end.
        
        run pi-elimina-tabelas. 
        
    end. /* for ech int_ds_pedido. */

end procedure. /* pi-importa */
          

procedure pi-cria-balanco:
    def input parameter p-tipo as integer.
  
    create tt-balanco.
    assign tt-balanco.ped_tipopedido_n = p-tipo.
end.
 
procedure valida-pedido:
  
    run pi-acompanhar in h-acomp (input "Validando Pedido").
    
    assign c-cod-estabel = "".
    for each estabelec 
        fields (cod-estabel estado cidade serie
                cep pais endereco bairro ep-codigo) 
        no-lock where
        estabelec.cgc = int_ds_pedido.ped_cnpj_origem_s,
        first cst_estabelec no-lock where 
        cst_estabelec.cod_estabel = estabelec.cod-estabel and
        cst_estabelec.dt_fim_operacao >= d-dt-emissao:
        assign c-cod-estabel = estabelec.cod-estabel
               c-uf-origem   = estabelec.estado.
               c-serie-ent   = estabelec.serie.
               c-serie       = estabelec.serie.
        leave.
    end.
    if c-cod-estabel = "" then
    do:
       assign i-erro = 30
              c-informacao = "Pedido: " + c-nr-pedcli + " CNPJ origem: " + string(int_ds_pedido.ped_cnpj_origem)
              l-movto-com-erro = yes.
       run gera-log. 
       return.
    end.
    if c-cod-estabel = "973" then 
       assign c-serie-ent = "30".

    for first ser-estab no-lock where
        ser-estab.serie = c-serie-ent and
        ser-estab.cod-estabel = c-cod-estabel:
        if ser-estab.forma-emis <> 1 /* autom tica */ then do:
            assign i-erro = 46
                   c-informacao = "Pedido: " + c-nr-pedcli + " - Est: " + c-cod-estabel + " - S‚rie: " + c-serie-ent
                   l-movto-com-erro = yes.
            run gera-log. 
            return.
        end.

        &if  "{&bf_dis_versao_ems}"  >=  "2.07"  &then
            if not ser-estab.log-nf-eletro /* NFe */ then do:
        &ELSE
            if substr(ser-estab.char-1,1,3) <> "yes" then do:
        &ENDIF /* &if  "{&bf_dis_versao_ems}"  >=  "2.07"  &then */
            assign i-erro = 47
                   c-informacao = "Pedido: " + c-nr-pedcli + " - Est: " + c-cod-estabel + " - S‚rie: " + c-serie-ent
                   l-movto-com-erro = yes.
            run gera-log. 
            return.
        end.

    end.
end. /* valida pedido */

procedure valida-nota-entrada:
         /* 1949 - Entrada sempre para o mesmo estado 
            5949 - Sa¡da para o mesmo estado */
                    
    assign  i-cod-emitente = 0
            i-cod-cond-pag = 0.

    for first emitente no-lock where
              emitente.cgc = trim(int_ds_pedido.ped_cnpj_destino_s):
        assign  c-nome-abrev   = emitente.nome-abrev
                i-cod-emitente = emitente.cod-emitente
                c-nr-tabpre    = emitente.nr-tabpre
                i-canal-vendas = emitente.cod-canal-venda
                i-cod-rep      = if emitente.cod-rep <> 0 
                                 then emitente.cod-rep
                                 else i-cod-rep
                i-cod-cond-pag = emitente.cod-cond-pag
                c-cod-transp   = int_ds_pedido.ped_cnpj_transportadora
                c-uf-destino   = emitente.estado.
    end.

    if c-nome-abrev = "" then do:
        assign i-erro = 2
               c-informacao = "Pedido: " + c-nr-pedcli + " CNPJ Destino: " + string((int_ds_pedido.ped_cnpj_destino))
               l-movto-com-erro = yes.
        run gera-log. 
        return.
    end.
   
    find first user-coml no-lock where
               user-coml.usuario = c-seg-usuario no-error.
    if not avail user-coml 
    then do:
         assign i-erro = 45
               c-informacao = "Pedido: " + c-nr-pedcli + " Usu rio: " + string(c-seg-usuario).
               l-movto-com-erro = yes.
        run gera-log. 
        return.
    end.

end. /* valida-nota-entrada */
 
procedure valida-nota-saida:

    run pi-acompanhar in h-acomp (input "Validando Nota Saida").
    
    /* for first nota-fiscal fields (cod-estabel serie nr-nota-fis dt-cancel) no-lock where
        nota-fiscal.nr-pedcli = string(c-nr-pedcli):
        if nota-fiscal.dt-cancel = ? then do:
            assign i-erro = 48
                   c-informacao = "Pedido: " + c-nr-pedcli + " CNPJ origem: " + string(int_ds_pedido.ped_cnpj_origem) + " Estab.: " + 
                                  c-cod-estabel + " S‚rie: " + nota-fiscal.serie + " NF: " + nota-fiscal.nr-nota-fis
                   l-movto-com-erro = yes.
            find current int_ds_pedido exclusive-lock no-wait no-error.
            if avail int_ds_pedido then
                assign int_ds_pedido.situacao = 2 /* integrado */.
            run gera-log. 
            return.
        end.
    end. */

     find first user-coml no-lock where
                user-coml.usuario = c-seg-usuario no-error.
     if not avail user-coml 
     then do:

         assign i-erro = 45
               c-informacao = "Pedido: " + c-nr-pedcli + " Usu rio: " + string(c-seg-usuario).
               l-movto-com-erro = yes.
        run gera-log. 
        return.
        
    end.

    assign  c-nome-abrev   = ""
            i-cod-emitente = 0
            c-nr-tabpre    = ""
            i-canal-vendas = 0
            i-cod-rep      = 1
            i-cod-cond-pag = 0
            c-cod-transp   = ""
            c-natur        = ""
            c-nome-transp  = ""
            c-redespacho   = "".

    for first emitente no-lock where
        emitente.cgc = trim(int_ds_pedido.ped_cnpj_destino_s):
        assign  c-nome-abrev   = emitente.nome-abrev
                i-cod-emitente = emitente.cod-emitente
                c-nr-tabpre    = emitente.nr-tabpre
                i-canal-vendas = emitente.cod-canal-venda
                i-cod-rep      = if emitente.cod-rep <> 0 
                                 then emitente.cod-rep
                                 else i-cod-rep
                i-cod-cond-pag = emitente.cod-cond-pag
                c-cod-transp   = int_ds_pedido.ped_cnpj_transportadora
                c-uf-destino   = emitente.estado.
                                     /*
                c-natur        = if emitente.estado = estabelec.estado 
                                 then emitente.nat-operacao else emitente.nat-ope-ext.
                if c-natur = "" then c-natur = "5101A2".
                */

        
        if c-cod-transp = "" then 
        for first transporte no-lock where 
            transporte.cod-transp = emitente.cod-transp:
            assign  c-nome-transp = transporte.nome-abrev.
        end.
        assign c-redespacho = emitente.nome-tr-red.

        if emitente.ind-cre-cli = 4 then do:
          assign i-erro = 27
                 c-informacao = "Pedido: " + c-nr-pedcli + " Emitente: " + string(i-cod-emitente)
                 l-movto-com-erro = yes.
          run gera-log. 
          return.
        end. 
    end.
    if c-nome-abrev = "" then do:
        assign i-erro = 2
               c-informacao = "Pedido: " + c-nr-pedcli + " CNPJ Destino: " + string((int_ds_pedido.ped_cnpj_destino))
               l-movto-com-erro = yes.
        run gera-log. 
        return.
    end.

    assign  c-cod-rota    = ""
            c-cod-entrega = emitente.cod-entrega.

    for first estab-cli no-lock where 
        estab-cli.cod-estabel = c-cod-estabel and
        estab-cli.nome-abrev = c-nome-abrev:
        assign  c-cod-rota    = estab-cli.cod-rota.
                c-nome-transp = if c-nome-transp = "" then estab-cli.nome-transp else "".
        if estab-cli.cod-entrega <> "" then  c-cod-entrega = estab-cli.cod-entrega.
    end.        
    c-nome-repres  = "".
    if i-cod-rep <> 0 then do:
        for first repres no-lock where 
            repres.cod-rep = i-cod-rep:
            assign c-nome-repres = repres.nome-abrev.
        end.
    end.
    if c-nome-repres = "" then do:
        assign i-erro = 13
               c-informacao = "Pedido: " + c-nr-pedcli + " Repres.: " + string(i-cod-rep)
               l-movto-com-erro = yes.
        run gera-log. 
        return.
    end.
    
    if i-tab-finan = 0 then
      assign i-tab-finan = 1
             i-indice    = 0.
            
    if not can-find (first tab-finan no-lock where 
                    tab-finan.nr-tab-finan = i-tab-finan) then do:
      assign i-erro = 35
             c-informacao = "Pedido: " + c-nr-pedcli + " Tab. Financ.: " + 
                            string(i-tab-finan)
             l-movto-com-erro = yes.
      run gera-log. 
      return.
    end.                     
    
    
    if i-canal-vendas <> 0 then
    do:
       find first canal-venda no-lock where
           canal-venda.cod-canal-venda = i-canal-vendas
           no-error.
       if not avail canal-venda then
       do:
          assign i-erro = 31
                 c-informacao = "Pedido: " + c-nr-pedcli + " Canal Venda: " + 
                                string(i-canal-vendas) + " Emitente: " + string(i-cod-emitente)
                 l-movto-com-erro = yes.
          run gera-log. 
          return.
       end.
    end.

    if c-cod-transp <> "" then do:
       find transporte where 
            transporte.cgc = c-cod-transp
            no-lock no-error.
       if avail transporte then do:
          assign c-nome-transp = transporte.nome-abrev.
       end.
    end.    
    
    if c-redespacho <> "" and 
       c-redespacho <> "0" 
    then do:
        for first btransporte no-lock where
            btransporte.cod-transp = int(c-redespacho). end.
        if not avail btransporte then do:
           assign i-erro = 23
                  c-informacao = "Pedido: " + c-nr-pedcli + " Nome Abrev.: " + 
                                 emitente.nome-abrev + 
                                 " Transp. Redesp.: " +
                                 c-redespacho
                  l-movto-com-erro = yes.
           run gera-log. 
           return.
        end.
    end.

end. /* valida-nota-saida */

procedure valida-item-entrada:

   run pi-acompanhar in h-acomp (input "Validando Itens Entrada : " +  c-it-codigo ).
                             
   for first item no-lock where
        item.it-codigo = c-it-codigo:
        assign c-class-fiscal = item.class-fiscal.
   end.
   
   if not avail item then do:
      assign i-erro = 9
             c-informacao = "Pedido: " + c-nr-pedcli + " item: " + 
                            c-it-codigo 
             l-movto-com-erro = yes.
      run gera-log. 
      return.

   end.
    
   for first classif-fisc no-lock where
             classif-fisc.class-fiscal = c-class-fiscal and 
             classif-fisc.class-fiscal <> ""  : end.

   
   if not avail classif-fisc 
   then do:
         assign i-erro = 42
             c-informacao = "Pedido: " + c-nr-pedcli + " item: " + 
                            c-it-codigo
             l-movto-com-erro = yes.

      run gera-log. 
      return.
   end.

   /* cria tt de itens obsoletos para altera‡Æo */
   if avail item and item.cod-obsoleto = 4 
   then do:
       /* assign i-erro = 10
              c-informacao = "Pedido: " + c-nr-pedcli + " item: " + 
                             c-it-codigo
              l-movto-com-erro = yes.
       run gera-log. 
       return. */

       create tt-item.
       assign tt-item.it-codigo = item.it-codigo.
      
   end.     
   if avail item and not item.ind-item-fat then do:
      assign i-erro = 11
             c-informacao = "Pedido: " + c-nr-pedcli + " item: " + 
                            c-it-codigo
             l-movto-com-erro = yes.
      run gera-log. 
      return.
   end.     
   if dec(tt-it-nfe.quantidade) <= 0 then do:
      assign i-erro = 12
             c-informacao = "Pedido: " + c-nr-pedcli + " item: " + 
                            c-it-codigo + " Qtde.: " + string(de-quantidade)
             l-movto-com-erro = yes.
      run gera-log. 
      return.
   end.
     
   /*
   /* determina natureza de operacao */
   run intprg/int015a.p ( input c-tp-pedido     ,
                          input c-uf-destino    ,
                          input c-uf-origem     ,
                          input c-cod-estabel   ,
                          input i-cod-emitente  ,
                          input c-class-fiscal  ,
                          input i-cst-icms      ,
                          output c-natur        , 
                          output i-cod-cond-pag , 
                          output i-cod-portador ,
                          output i-modalidade   ,
                          output c-serie-ent    ,
                          output r-rowid,
                          OUTPUT c-natur-ent).
   */

   /* determina natureza de operacao */
   run intprg/int115a.p ( input c-tp-pedido   ,
                          input c-uf-destino  ,
                          input c-uf-origem   ,
                          input "" /*nat or*/ ,
                          input i-cod-emitente,
                          input c-class-fiscal,
                          output c-natur      ,
                          output c-natur-ent  ,
                          output r-rowid).

   assign l-ind-icm-ret = no.

   for first natur-oper no-lock where
             natur-oper.nat-operacao = c-natur-ent: 

       if natur-oper.subs-trib then l-ind-icm-ret = yes.

   end.

   if not avail natur-oper 
   then do:
       assign i-erro = 21
              c-informacao = "Pedido: " + c-nr-pedcli + " Tipo: " + 
                             string(C-TP-PEDIdo) + " Natur. Oper.: " + c-natur-ent + 
                             " UF Destino: " + 
                             c-uf-destino + " UF origem: " + 
                             c-uf-origem + " Estab.: " + 
                             C-COD-ESTABEL + " Emitente: " + 
                             string(I-COD-EMITENTE) + " NCM: " +
                             C-CLasS-FISCAL
              l-movto-com-erro = yes.
       run gera-log. 
       return.
   end.

   if avail natur-oper and 
      not natur-oper.nat-ativa then do:
       assign i-erro = 32  
              c-informacao = "Pedido: " + c-nr-pedcli + " Natur. Oper.: " + 
                          c-natur-ent
           l-movto-com-erro = yes.
       run gera-log. 
       return.
   end.
   if avail natur-oper and 
     (natur-oper.especie-doc = "NFD" or
      natur-oper.terceiros) and
      c-nr-docum = "" then do:
       assign i-erro = 28
              c-informacao = "Pedido: " + c-nr-pedcli + " Natur. Oper.: " + 
                          c-natur-ent + " Esp. doc.: " + natur-oper.especie-doc
           l-movto-com-erro = yes.
       run gera-log. 
       return.
   end.
   if avail natur-oper and 
      natur-oper.especie-doc <> "NFE" then do:
       assign i-erro = 34
              c-informacao = "Pedido: " + c-nr-pedcli + " Natur. Oper.: " + 
                             c-natur-ent + " Esp. doc.: " + natur-oper.especie-doc
           l-movto-com-erro = yes.
       run gera-log. 
       return.
   end.
   if avail natur-oper and 
            natur-oper.imp-nota = NO     
    then do:
       assign i-erro = 43
              c-informacao = "Pedido: " + c-nr-pedcli + " Natur. Oper.: " + 
                             c-natur-ent + " Esp. doc.: " + natur-oper.especie-doc
           l-movto-com-erro = yes.
       run gera-log. 
       return.
   end.

   if avail natur-oper and not natur-oper.emite-duplic then
       assign i-cod-cond-pag = 0.

   if i-cod-cond-pag <> 0 and i-cod-cond-pag <> ?
   then do:
      find cond-pagto where
           cond-pagto.cod-cond-pag = i-cod-cond-pag
           no-lock no-error.
      if not avail cond-pagto then do:
         assign i-erro = 15
                c-informacao = "Pedido: " + c-nr-pedcli + " Cond. Pagto.: " + 
                               string(i-cod-cond-pag)
                l-movto-com-erro = yes.
         run gera-log. 
         return.
      end.    
      else if cond-pagto.cod-vencto <> 2 /* a vista */ and 
           avail emitente and emitente.ind-cre-cli = 5 /* so a vista */ then
      do:
         assign i-erro = 26
                c-informacao = "Pedido: " + c-nr-pedcli + " Cond. Pagto.: " + 
                               string(i-cod-cond-pag)
                l-movto-com-erro = yes.
         run gera-log. 
         return.
      end.
   end.     

   if de-vl-uni = 0 
   then do: 
        assign i-erro = 38
               c-informacao = "Pedido: " + c-nr-pedcli + " Estabel: " + c-cod-estabel + " item: " + c-it-codigo 
               l-movto-com-erro = yes.
        run gera-log. 
        return.
   end.

   if item.tipo-contr = 4 then do:
       for first item-uni-estab no-lock where 
                 item-uni-estab.cod-estabel = c-cod-estabel and
                 item-uni-estab.it-codigo   = item.it-codigo: end.
       if (avail item-uni-estab and
           item-uni-estab.ct-codigo = "") or
          (not avail item-uni-estab and
           item.ct-codigo = "") then do:
           assign i-erro = 44
                  c-informacao = "Pedido: " + c-nr-pedcli + " Estabel: " + c-cod-estabel + " item: " + c-it-codigo 
                  l-movto-com-erro = yes.
           run gera-log. 
           return.
       end.
   end.
      
end procedure. /* valida-item-entrada */

procedure valida-item-saida:

   run pi-acompanhar in h-acomp (input "Validando Itens Saida : " + c-it-codigo).
   
   for first item  no-lock  where
             item.it-codigo = c-it-codigo:
        c-class-fiscal = item.class-fiscal.
   end.
   if not avail item then do:
      assign i-erro = 9
             c-informacao = "Pedido: " + c-nr-pedcli + " item: " + 
                            c-it-codigo 
             l-movto-com-erro = yes.
      run gera-log. 
      return.

   end.

   for first classif-fisc no-lock where
             classif-fisc.class-fiscal = c-class-fiscal and 
             classif-fisc.class-fiscal <> ""  :

   end.
   if not avail classif-fisc 
   then do:
         assign i-erro = 42
             c-informacao = "Pedido: " + c-nr-pedcli + " item: " + 
                            c-it-codigo
             l-movto-com-erro = yes.
      run gera-log. 
      return.
   end.
                           
   /* cria tt de itens obsoletos para altera‡Æo */
   if avail item and item.cod-obsoleto = 4 
   then do:
        /* assign i-erro = 10
               c-informacao = "Pedido: " + c-nr-pedcli + " item: " + 
                              c-it-codigo
               l-movto-com-erro = yes.
        run gera-log. 
        return. */

        create tt-item.
        assign tt-item.it-codigo = item.it-codigo.

   end.     
   if avail item and not item.ind-item-fat then do:
      assign i-erro = 11
             c-informacao = "Pedido: " + c-nr-pedcli + " item: " + 
                            c-it-codigo
             l-movto-com-erro = yes.
      run gera-log. 
      return.
   end.     
   if dec(tt-it-nfs.quantidade) <= 0 then do:
      assign i-erro = 12
             c-informacao = "Pedido: " + c-nr-pedcli + " item: " + 
                            c-it-codigo + " Qtde.: " + string(de-quantidade)
             l-movto-com-erro = yes.
      run gera-log. 
      return.
   end. 
   
   assign i-cst-icms = 0.

   /*
   /* determina natureza de operacao */
   run intprg/int015a.p ( input c-tp-pedido ,
                          input c-uf-destino    ,
                          input c-uf-origem     ,
                          input c-cod-estabel   ,
                          input i-cod-emitente  ,
                          input c-class-fiscal  ,
                          input i-cst-icms      ,
                          output c-natur        , 
                          output i-cod-cond-pag , 
                          output i-cod-portador ,
                          output i-modalidade   ,
                          output c-serie        ,
                          output r-rowid,
                          OUTPUT c-natur-ent).
   */
   /* determina natureza de operacao */
   run intprg/int115a.p ( input c-tp-pedido   ,
                          input c-uf-destino  ,
                          input c-uf-origem   ,
                          input "" /*nat or*/ ,
                          input i-cod-emitente,
                          input c-class-fiscal,
                          output c-natur      ,
                          output c-natur-ent  ,
                          output r-rowid).

   assign l-ind-icm-ret = no.

   for first natur-oper no-lock where
             natur-oper.nat-operacao = c-natur: 
       if natur-oper.subs-trib then l-ind-icm-ret = yes.
   end.

   if not avail natur-oper 
   then do:
       assign i-erro = 21
              c-informacao = "Pedido: " + c-nr-pedcli + " Tipo: " + 
                             string(C-TP-PEDIdo) + " Natur. Oper.: " + c-natur + 
                             " UF Destino: " + 
                             c-uf-destino + " UF origem: " + 
                             c-uf-origem + " Estab.: " + 
                             C-COD-ESTABEL + " Emitente: " + 
                             string(I-COD-EMITENTE) + " NCM: " +
                             C-CLasS-FISCAL
              l-movto-com-erro = yes.
       run gera-log. 
       return.
   end.

   if avail natur-oper and 
      not natur-oper.nat-ativa then do:
       assign i-erro = 32  
              c-informacao = "Pedido: " + c-nr-pedcli + " Natur. Oper.: " + 
                          c-natur
           l-movto-com-erro = yes.
       run gera-log. 
       return.
   end.
   if avail natur-oper and 
     (natur-oper.especie-doc = "NFD" or
      natur-oper.terceiros) and
      c-nr-docum = "" then do:
       assign i-erro = 28
              c-informacao = "Pedido: " + c-nr-pedcli + " Natur. Oper.: " + 
                          c-natur + " Esp. doc.: " + natur-oper.especie-doc
           l-movto-com-erro = yes.
       run gera-log. 
       return.
   end.
   if avail natur-oper and 
     (natur-oper.especie-doc <> "NFD" and
      not natur-oper.terceiros) and
      c-nr-docum <> "" then do:
       assign i-erro = 29
              c-informacao = "Pedido: " + c-nr-pedcli + " Natur. Oper.: " + 
                             c-natur + " Esp. doc.: " + natur-oper.especie-doc
           l-movto-com-erro = yes.
       run gera-log. 
       return.
   end.

   if avail natur-oper and not natur-oper.emite-duplic then
       assign i-cod-cond-pag = 0.

   if i-cod-cond-pag <> 0 and i-cod-cond-pag <> ?
   then do:
      find cond-pagto where
           cond-pagto.cod-cond-pag = i-cod-cond-pag
           no-lock no-error.
      if not avail cond-pagto then do:
         assign i-erro = 15
                c-informacao = "Pedido: " + c-nr-pedcli + " Cond. Pagto.: " + 
                               string(i-cod-cond-pag)
                l-movto-com-erro = yes.
         run gera-log. 
         return.
      end.    
      else if cond-pagto.cod-vencto <> 2 /* a vista */ and 
           avail emitente and emitente.ind-cre-cli = 5 /* so a vista */ then
      do:
         assign i-erro = 26
                c-informacao = "Pedido: " + c-nr-pedcli + " Cond. Pagto.: " + 
                               string(i-cod-cond-pag)
                l-movto-com-erro = yes.
         run gera-log. 
         return.
      end.
   end.
   
  if de-vl-uni = 0 then do:
        assign i-erro = 38
               c-informacao = "Pedido: " + c-nr-pedcli + " Estabel : " + c-cod-estabel + " Tab. Pre‡o: " + 
                              c-nr-tabpre + " item: " + 
                              c-it-codigo
               l-movto-com-erro = yes.
        run gera-log. 
        return.
   end.
end. /* valida-item-saida */
 
procedure pi-cria-tt-docum-est:
   
   run pi-acompanhar in h-acomp (input "Criando Nota de Entrada :" + substring(string(int_ds_pedido.ped_codigo_n),2,6)).
    
   find first param-estoq no-lock no-error.

   for each tt-nfe no-lock where
            tt-nfe.ped_codigo_n = int_ds_pedido.ped_codigo_n:

        create tt-nota-ent.
        assign tt-nota-ent.nro-docto    =  substring(string(tt-nfe.ped_codigo_n),4,6) + string(tt-nfe.nro-docto,"99")  
               tt-nota-ent.serie-nota   = c-serie-ent
               tt-nota-ent.serie-docum  = c-serie-ent
               tt-nota-ent.nat-operacao = c-natur-ent                                   
               tt-nota-ent.cod-emitente = i-cod-emitente 
               tt-nota-ent.tipo-nota    = 1
               tt-nota-ent.situacao     = 2.
        
        find first emitente no-lock where
                   emitente.cod-emitente = i-cod-emitente no-error.
        
        find first natur-oper where 
                   natur-oper.nat-operacao = c-natur-ent no-error.

        create tt-docum-est-ent.
        assign tt-docum-est-ent.nro-docto    = tt-nota-ent.nro-docto
               tt-docum-est-ent.cod-emitente = tt-nota-ent.cod-emitente
               tt-docum-est-ent.serie-docto  = tt-nota-ent.serie-nota 
               tt-docum-est-ent.char-2       = tt-nota-ent.serie-docum /* Serie documento principal */
               tt-docum-est-ent.nat-operacao = c-natur-ent                              
               tt-docum-est-ent.cod-observa  = if natur-oper.log-2 then 2 /* Comercio */ else 1  /* Industria*/
               tt-docum-est-ent.cod-estabel  = c-cod-estabel
               tt-docum-est-ent.estab-fisc   = c-cod-estabel
               tt-docum-est-ent.estab-de-or  = c-cod-estabel 
               tt-docum-est-ent.usuario      = c-seg-usuario
               tt-docum-est-ent.uf           = emitente.estado 
               tt-docum-est-ent.via-transp   = 1
               tt-docum-est-ent.dt-emis      = TODAY   
               tt-docum-est-ent.dt-trans     = TODAY                          
               tt-docum-est-ent.nff          = no                              
               tt-docum-est-ent.observacao   = "Pedido Balan‡o : " + string(tt-nfe.ped_codigo_n) + CHR(13) + CHR(13) + tt-param.txt-obs
               tt-docum-est-ent.valor-mercad = 0 
               tt-docum-est-ent.tot-valor    = 0
               tt-docum-est-ent.conta-transit = /*param-estoq.conta-fornec*/ "91107005"
               tt-docum-est-ent.ct-transit    = "91107005"
               OVERLAY(tt-docum-est-ent.char-1,93,60)  = ""
               OVERLAY(tt-docum-est-ent.char-1,192,16) = "" /* Aviso de recolhimento */     
               tt-docum-est-ent.esp-docto     = 21.
     
        release tt-docum-est-ent.
    
        for first tt-docum-est-ent where
                  tt-docum-est-ent.nro-docto = tt-nota-ent.nro-docto : end.   
         
        assign i-sequencia = 0.
           
        for each tt-it-nfe where
             tt-it-nfe.nro-docto    = tt-nfe.nro-docto and
             tt-it-nfe.ped_codigo_n = tt-nfe.ped_codigo_n :
          

             for first item no-lock where 
                       item.it-codigo = tt-it-nfe.it-codigo: end.
             if not avail item then next.

             assign i-sequencia = i-sequencia + 10.

             /*
             /* determina natureza de operacao */
             run intprg/int015a.p ( input c-tp-pedido     ,
                                    input c-uf-destino    ,
                                    input c-uf-origem     ,
                                    input c-cod-estabel   ,
                                    input i-cod-emitente  ,
                                    input item.class-fiscal ,
                                    input i-cst-icms      ,
                                    output c-natur        , 
                                    output i-cod-cond-pag , 
                                    output i-cod-portador ,
                                    output i-modalidade   ,
                                    output c-serie-ent    ,
                                    output r-rowid,
                                    OUTPUT c-natur-ent).
             */

             /* determina natureza de operacao */
             run intprg/int115a.p ( input c-tp-pedido   ,
                                    input c-uf-destino  ,
                                    input c-uf-origem   ,
                                    input "" /*nat or*/ ,
                                    input i-cod-emitente,
                                    input c-class-fiscal,
                                    output c-natur      ,
                                    output c-natur-ent  ,
                                    output r-rowid).

             create tt-item-doc-est-ent.
             assign tt-item-doc-est-ent.serie-docto    = tt-docum-est-ent.serie-docto
                    tt-item-doc-est-ent.char-2         = tt-nota-ent.serie-nota       /* Serie documento principal */
                    tt-item-doc-est-ent.nro-docto      = tt-nota-ent.nro-docto
                    tt-item-doc-est-ent.cod-emitente   = tt-nota-ent.cod-emitente
                    tt-item-doc-est-ent.nat-operacao   = c-natur-ent
                    tt-item-doc-est-ent.sequencia      = i-sequencia
                    tt-item-doc-est-ent.it-codigo      = tt-it-nfe.it-codigo
                    tt-item-doc-est-ent.lote           = if item.tipo-con-est = 3 /* lote */ then tt-it-nfe.lote else ""
                    tt-item-doc-est-ent.num-pedido     = 0    
                    tt-item-doc-est-ent.numero-ordem   = 0
                    tt-item-doc-est-ent.parcela        = 0
                    tt-item-doc-est-ent.nr-pedcli      = c-nr-pedcli.

             
/*                  find first item-uni-estab no-lock where                               */
/*                             item-uni-estab.cod-estabel = c-cod-estabel and             */
/*                             item-uni-estab.it-codigo   = tt-it-nfe.it-codigo no-error. */
/*                  if avail item-uni-estab then                                          */
/*                     assign c-cod-depos = item-uni-estab.deposito-pad.                  */
/*                  else                                                                  */
/*                     assign c-cod-depos = item.deposito-pad.                            */

               if c-cod-estabel = "973" 
               then
                   assign c-cod-depos = "973".
               else
                   assign c-cod-depos = "LOJ".
               
             assign tt-item-doc-est-ent.encerra-pa     = no
                    tt-item-doc-est-ent.log-1          = NO /* FifO */ 
                    tt-item-doc-est-ent.nr-ord-prod    = 0
                    tt-item-doc-est-ent.cod-roteiro    = ""
                    tt-item-doc-est-ent.op-codigo      = 0
                    tt-item-doc-est-ent.item-pai       = ""
                    tt-item-doc-est-ent.baixa-ce       = YES 
                    tt-item-doc-est-ent.quantidade     = tt-it-nfe.quantidade
                    tt-item-doc-est-ent.preco-unit[1]  = tt-it-nfe.vl-uni
                    tt-item-doc-est-ent.pre-uni[1]     = tt-it-nfe.vl-uni 
                    tt-item-doc-est-ent.cod-depos      = c-cod-depos
                    tt-item-doc-est-ent.class-fiscal   = item.class-fiscal
                    tt-item-doc-est-ent.preco-total[1] = tt-item-doc-est-ent.preco-unit[1] * tt-item-doc-est-ent.quantidade.    

             if item.tipo-contr = 4 then do:
                if avail item-uni-estab then
                   assign tt-item-doc-est-ent.ct-codigo      = item-uni-estab.ct-codigo
                          tt-item-doc-est-ent.sc-codigo      = item-uni-estab.sc-codigo
                          tt-item-doc-est-ent.conta-contabil = tt-item-doc-est-ent.ct-codigo + tt-item-doc-est-ent.sc-codigo.
                else 
                   assign tt-item-doc-est-ent.ct-codigo      = item.ct-codigo                                
                          tt-item-doc-est-ent.sc-codigo      = item.sc-codigo                
                          tt-item-doc-est-ent.conta-contabil = tt-item-doc-est-ent.ct-codigo + tt-item-doc-est-ent.sc-codigo.
             end.
             else 
                assign tt-item-doc-est-ent.conta-contabil = "".

             assign tt-docum-est-ent.valor-mercad = tt-docum-est-ent.valor-mercad + tt-item-doc-est-ent.preco-total[1] 
                    tt-docum-est-ent.tot-valor    = tt-docum-est-ent.tot-valor    + tt-item-doc-est-ent.preco-total[1]. 
        end.
    
        for each int_ds_doc_erro where
                 int_ds_doc_erro.serie_docto  = tt-nota-ent.serie-nota   and 
                 int_ds_doc_erro.cod_emitente = tt-nota-ent.cod-emitente and
                 int_ds_doc_erro.nro_docto    = tt-nota-ent.nro-docto    and
                 int_ds_doc_erro.tipo_nota    = tt-nota-ent.tipo-nota   :
               delete int_ds_doc_erro.
        end.
   end.

end procedure. /* pi-cria-tt-docum-est */

procedure pi-cria-tt-ped-venda-prs:

   run pi-acompanhar in h-acomp (input "Criando Pedido").

   for first emitente no-lock where
       emitente.cod-emitente = i-cod-emitente: end.
   
   create tt-ped-venda-prs.
   assign tt-ped-venda-prs.cod-estabel    = c-cod-estabel
          tt-ped-venda-prs.nome-abrev     = emitente.nome-abrev
          tt-ped-venda-prs.nr-pedcli      = c-nr-pedcli
          tt-ped-venda-prs.nr-pedrep      = c-nr-pedcli
          tt-ped-venda-prs.cod-emitente   = emitente.cod-emitente
          tt-ped-venda-prs.dt-emissao     = d-dt-emissao
          tt-ped-venda-prs.dt-implant     = d-dt-implantacao
          tt-ped-venda-prs.dt-entrega     = d-dt-entrega
          tt-ped-venda-prs.dt-entorig     = d-dt-entrega
          tt-ped-venda-prs.nat-operacao   = c-natur
          tt-ped-venda-prs.cod-cond-pag   = int(i-cod-cond-pag)
          tt-ped-venda-prs.no-ab-reppri   = c-nome-repres
          tt-ped-venda-prs.nr-tabpre      = c-nr-tabpre
          tt-ped-venda-prs.nr-tab-finan   = i-tab-finan 
          tt-ped-venda-prs.nr-ind-finan   = i-indice
          tt-ped-venda-prs.tp-pedido      = c-tp-pedido
          tt-ped-venda-prs.local-entreg   = emitente.endereco
          tt-ped-venda-prs.bairro         = emitente.bairro
          tt-ped-venda-prs.cidade         = emitente.cidade
          tt-ped-venda-prs.nome-tr-red    = if avail btransporte 
                                            then btransporte.nome-abrev
                                            else ""
          tt-ped-venda-prs.cond-redespa   = c-cond-redespacho                                         
          tt-ped-venda-prs.inc-desc-txt   = no
          tt-ped-venda-prs.placa          = c-placa
          tt-ped-venda-prs.uf-placa       = c-uf-placa

          tt-ped-venda-prs.cod-canal-venda = if avail canal-venda
                                             then canal-venda.cod-canal-venda
                                             else 0.

   assign tt-ped-venda-prs.ind-tp-frete   = 2 /* FOB */.
   if emitente.cod-entrega <> "" then do:
        assign tt-ped-venda-prs.cod-entrega = emitente.cod-entrega.
   end.
   else do: 
        find first loc-entr no-lock 
            where loc-entr.nome-abrev = emitente.nome-abrev
            no-error.
        if avail loc-entr then
        do:
            assign tt-ped-venda-prs.cod-entrega  = loc-entr.cod-entrega.
            if loc-entr.nome-transp <> "" then assign tt-ped-venda-prs.nome-transp = loc-entr.nome-transp.
            if loc-entr.cod-rota <> "" then assign tt-ped-venda-prs.cod-rota = loc-entr.cod-rota.
            if loc-entr.nom-cidad-cif <> "" then assign c-cidade-cif = loc-entr.nom-cidad-cif
                                                        tt-ped-venda-prs.ind-tp-frete   = 1 /* Cif */.
        end.
        else do:
            assign tt-ped-venda-prs.cod-entrega  = "PadrÆo".
        end.
   end.

   if tt-ped-venda-prs.ind-tp-frete = 1 then /* Cif */
   do:
      assign tt-ped-venda-prs.cidade-cif = if c-cidade-cif <> "" and
                                              c-cidade-cif <> "0" and
                                              c-cidade-cif <> "." 
                                           then c-cidade-cif
                                           else emitente.cidade. 
   end.
                
   assign tt-ped-venda-prs.estado         = emitente.estado
          tt-ped-venda-prs.cep            = emitente.cep
          tt-ped-venda-prs.caixa-postal   = emitente.caixa-postal
          tt-ped-venda-prs.pais           = emitente.pais
          tt-ped-venda-prs.cgc            = emitente.cgc
          tt-ped-venda-prs.ins-estadual   = emitente.ins-estadual.

   assign tt-ped-venda-prs.cod-portador   = if i-cod-portador <> ? then i-cod-portador else emitente.port-prefer
          tt-ped-venda-prs.modalidade     = if i-modalidade <> ? then i-modalidade else emitente.mod-prefer
          tt-ped-venda-prs.cod-mensagem   = natur-oper.cod-mensagem
          tt-ped-venda-prs.user-impl      = c-seg-usuario
          tt-ped-venda-prs.dt-userimp     = today
          tt-ped-venda-prs.ind-aprov      = no
          tt-ped-venda-prs.quem-aprovou   = " "
          tt-ped-venda-prs.dt-apr-cred    = ?
          tt-ped-venda-prs.cod-des-merc   = if natur-oper.consum-final or not emitente.contrib-icms
                                            then 2 else 1
          tt-ped-venda-prs.observacoes    = c-observacao
          tt-ped-venda-prs.nome-transp    = c-nome-transp  
          tt-ped-venda-prs.tp-preco       = 1
          tt-ped-venda-prs.tip-cob-desp   = emitente.tip-cob-desp
          tt-ped-venda-prs.per-max-canc   = emitente.per-max-canc
          tt-ped-venda-prs.ind-lib-nota   = yes.
    
   run pi-acompanhar in h-acomp (input "Criando Itens do Pedido Sa¡da").
    
   assign i-nr-sequencia = 0.

   for each tt-it-nfs where
            tt-it-nfs.ped_codigo_n = int(c-nr-pedcli),
       first item no-lock where
             item.it-codigo = tt-it-nfs.it-codigo : 

       find last preco-item where 
                 preco-item.nr-tabpre   = c-nr-tabpre and
                 preco-item.it-codigo   = tt-it-nfs.it-codigo and
                 preco-item.situacao = 1 /* ativo */ and
                 preco-item.dt-inival <= today
            no-lock no-error. 
       if avail preco-item and tt-it-nfs.vl-uni = 0 and 
          preco-item.preco-venda <> 0 then
            assign de-preco = preco-item.preco-venda.
       else
            assign de-preco = tt-it-nfs.vl-uni. 
    
       for first tt-ped-item-prs where
                 tt-ped-item-prs.nome-abrev   = tt-ped-venda-prs.nome-abrev and
                 tt-ped-item-prs.nr-pedcli    = tt-ped-venda-prs.nr-pedcli  and
                 tt-ped-item-prs.nr-sequencia = i-nr-sequencia              and
                 tt-ped-item-prs.it-codigo    = tt-it-nfs.it-codigo         and
                 tt-ped-item-prs.numero-lote  = tt-it-nfs.lote: 
       end.
       if not avail tt-ped-item-prs 
       then do:
           assign i-nr-sequencia = i-nr-sequencia + 10.

           /*
           /* determina natureza de operacao */
           run intprg/int015a.p ( input c-tp-pedido     ,
                                  input c-uf-destino    ,
                                  input c-uf-origem     ,
                                  input c-cod-estabel   ,
                                  input i-cod-emitente  ,
                                  input item.class-fiscal ,
                                  input i-cst-icms      ,
                                  output c-natur        , 
                                  output i-cod-cond-pag , 
                                  output i-cod-portador ,
                                  output i-modalidade   ,
                                  output c-serie ,
                                  output r-rowid,
                                  OUTPUT c-natur-ent).
           */

           /* determina natureza de operacao */
           run intprg/int115a.p ( input c-tp-pedido   ,
                                  input c-uf-destino  ,
                                  input c-uf-origem   ,
                                  input "" /*nat or*/ ,
                                  input i-cod-emitente,
                                  input c-class-fiscal,
                                  output c-natur      ,
                                  output c-natur-ent  ,
                                  output r-rowid).

           create tt-ped-item-prs.
           assign tt-ped-item-prs.nome-abrev   = tt-ped-venda-prs.nome-abrev
                  tt-ped-item-prs.nr-pedcli    = tt-ped-venda-prs.nr-pedcli
                  tt-ped-item-prs.nr-sequencia = i-nr-sequencia
                  tt-ped-item-prs.it-codigo    = tt-it-nfs.it-codigo
                  tt-ped-item-prs.nat-operacao = c-natur
                  tt-ped-item-prs.nr-tabpre    = "" /*c-nr-tabpre*/
                  tt-ped-item-prs.qt-un-fat    = 0
                  tt-ped-item-prs.vl-pretab    = de-preco /* preco-item.preco-venda */
                  tt-ped-item-prs.vl-preori    = de-preco 
                  tt-ped-item-prs.des-un-medida = item.un
                  tt-ped-item-prs.cod-un        = item.un. 
       end.

       assign tt-ped-item-prs.qt-pedida     = tt-ped-item-prs.qt-pedida 
                                            + dec(tt-it-nfs.quantidade)
              tt-ped-item-prs.numero-lote   = tt-it-nfs.lote
              tt-ped-item-prs.numero-caixa  = tt-it-nfs.nr-caixa.
    
       assign de-preco-liq    = de-preco
              de-red-base-ipi = 0 /* base normal */
              de-base-ipi     = (de-preco-liq * tt-ped-item-prs.qt-pedida).

       if avail natur-oper and /* IPI SOBRE O BRUTO */
         substring(natur-oper.char-2,11,1) = "1" then
       do:
          de-base-ipi = (de-preco * tt-ped-item-prs.qt-pedida). 
       end.
       
       /* Aliquota ISS */
       if avail natur-oper and
          natur-oper.tipo = 3 then 
          assign tt-ped-item-prs.dec-2        = item.aliquota-iss
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
          overlay(tt-ped-item-prs.char-2,01,08) = c-class-fiscal. 
          assign tt-ped-item-prs.cod-class-fis = c-class-fiscal.
       end.       
    
       if avail natur-oper  and
          natur-oper.cd-trib-ipi <> 2 and    /* isento */
          natur-oper.cd-trib-ipi <> 3 then do: /* outros */ 
          if natur-oper.cd-trib-ipi = 4 and /* reduzido */
             item.cd-trib-ipi = 4 then     /* reduzido */
          do:
             assign de-red-base-ipi = natur-oper.perc-red-ipi.
                    de-base-ipi = (de-preco-liq * tt-ped-item-prs.qt-pedida) * 
                                   (1 - (de-red-base-ipi / 100)).
          end. 
       end.
       else do: /* somente tributa se natureza = T/R e item = T/R */
          assign de-aliquota-ipi = 0.
       end.
       
       assign tt-ped-item-prs.vl-preuni    = de-preco-liq
              tt-ped-item-prs.vl-merc-abe  = de-preco-liq * tt-ped-item-prs.qt-pedida 
              tt-ped-item-prs.vl-liq-it    = de-preco-liq * tt-ped-item-prs.qt-pedida
              tt-ped-item-prs.vl-liq-abe   = (de-preco-liq * tt-ped-item-prs.qt-pedida) 
                                           + de-base-ipi * (de-aliquota-ipi / 100)
              tt-ped-item-prs.vl-tot-it    = (de-preco-liq * tt-ped-item-prs.qt-pedida) 
                                           + de-base-ipi * (de-aliquota-ipi / 100)
              tt-ped-item-prs.aliquota-ipi = de-aliquota-ipi
              tt-ped-item-prs.dt-userimp   = today
              tt-ped-item-prs.user-impl    = c-seg-usuario
              tt-ped-item-prs.dt-entorig   = d-dt-entrega
              tt-ped-item-prs.dt-entrega   = d-dt-entrega
              tt-ped-item-prs.dt-userimp   = today
              tt-ped-item-prs.user-impl    = c-seg-usuario.
    
       assign tt-ped-item-prs.val-ipi = de-base-ipi * (de-aliquota-ipi / 100).

   end.

end. /* pi-cria-tt-ped-venda-prs */


procedure emite-nota-entrada.

    def var l-nota-entrada as logical no-undo. 
                              
    run pi-acompanhar in h-acomp (input "Gerando Nota Entrada ").
              
    assign l-movto-entrada-erro = NO.
      
    for each tt-nota-ent:

        assign l-nota-entrada = NO.
         
        empty temp-table tt-nota.
        empty temp-table tt-docum-est.
        empty temp-table tt-item-doc-est.
        empty temp-table RowErrors.

        for first tt-docum-est-ent where
            tt-docum-est-ent.nro-docto = tt-nota-ent.nro-docto: end.

        /* verificar documentos pendentes ou com processo interrompido */
        for-docto:
        for each docum-est no-lock where 
            docum-est.cod-estabel   = tt-docum-est-ent.cod-estabel   and
            docum-est.dt-trans     >= int_ds_pedido.ped_data_d       and
            docum-est.cod-emitente  = tt-docum-est-ent.cod-emitente  and
            docum-est.esp-docto     = 21:
            /* documento nÆo atualizado 
            if  docum-est.serie-docto = tt-docum-est-ent.serie-docto and
                docum-est.nro-docto   = tt-docum-est-ent.nro-docto then do:
                assign i-erro = 39
                       c-informacao = "Pedido: " + c-nr-pedcli + " Serie: " + tt-docum-est-ent.serie-docto + " Docto: " + tt-docum-est-ent.nro-docto
                       l-movto-com-erro = yes.
                run gera-log. 
                assign l-nota-entrada = YES.
                leave for-docto.
            end.
            */

            /* documento atualizado com nota ativa porem sem nr-pedcli no cabe‡alho */
            for each item-doc-est no-lock of docum-est where
                item-doc-est.nr-pedcli = c-nr-pedcli:
                for each nota-fiscal no-lock where
                    nota-fiscal.cod-estabel  = docum-est.cod-estabel  and 
                    nota-fiscal.serie        = docum-est.serie-docto  and
                    nota-fiscal.nr-nota-fis  = docum-est.nro-docto    and
                    nota-fiscal.dt-cancel    = ?:
                    
                    assign i-erro = 49
                           c-informacao = "Pedido: " + c-nr-pedcli + " Serie: " + tt-docum-est-ent.serie-docto + " Docto: " + tt-docum-est-ent.nro-docto
                           /*l-movto-com-erro = yes*/ .
                    run gera-log. 
                    
                    assign l-nota-entrada = YES.
                    leave for-docto.
                end.
            end.
            /* nota fiscal ativa pra o documento com numero do pedido */
            for each nota-fiscal no-lock where 
                nota-fiscal.cod-estabel = docum-est.cod-estabel and
                nota-fiscal.serie       = docum-est.serie-docto and
                nota-fiscal.nr-nota-fis = docum-est.nro-docto   and
                nota-fiscal.dt-cancela  = ?:
                if nota-fiscal.nr-pedcli = c-nr-pedcli then do:

                    assign i-erro = 49
                           c-informacao = "Pedido: " + c-nr-pedcli + " Serie: " + tt-docum-est-ent.serie-docto + " Docto: " + tt-docum-est-ent.nro-docto
                           /*l-movto-com-erro = yes*/ .
                    run gera-log. 

                    assign l-nota-entrada = YES.
                    leave for-docto.
                end.                
                for each it-nota-fisc no-lock of nota-fiscal where
                    it-nota-fisc.nr-pedcli = c-nr-pedcli:
                    assign i-erro = 49
                           c-informacao = "Pedido: " + c-nr-pedcli + " Serie: " + tt-docum-est-ent.serie-docto + " Docto: " + tt-docum-est-ent.nro-docto
                           /*l-movto-com-erro = yes*/ .
                    run gera-log. 

                    assign l-nota-entrada = YES.
                    leave for-docto.
                end.
            end.
        end.
        if l-nota-entrada then next.

        /* nota fiscal emitida- m‚todo antigo de checagem */
        for first nota-fiscal no-lock where
            nota-fiscal.cod-estabel      = tt-docum-est-ent.cod-estabel  and 
            nota-fiscal.serie            = tt-docum-est-ent.serie        and
            nota-fiscal.nr-pedcli        = c-nr-pedcli                   and 
            nota-fiscal.nro-nota-orig    = tt-docum-est-ent.nro-docto    and 
            nota-fiscal.dt-cancel        = ?,
            first natur-oper no-lock where
            natur-oper.nat-operacao = nota-fiscal.nat-operacao and 
            natur-oper.tipo         = 1 : /* Entrada */  
            assign i-erro = 49
                   c-informacao = "Pedido: " + c-nr-pedcli + " Serie: " + tt-docum-est-ent.serie-docto + " Docto: " + tt-docum-est-ent.nro-docto
                   /*l-movto-com-erro = yes*/ .
            run gera-log. 
            assign l-nota-entrada = YES.
        end.      
        if l-nota-entrada then next.
        
        create tt-nota.
        buffer-copy tt-nota-ent TO tt-nota.
        
        for each tt-docum-est-ent where
                 tt-docum-est-ent.nro-docto = tt-nota-ent.nro-docto:
            create tt-docum-est.
            buffer-copy tt-docum-est-ent TO tt-docum-est.
        end.
        
        for each tt-item-doc-est-ent where
                 tt-item-doc-est-ent.nro-docto = tt-nota-ent.nro-docto :
            create tt-item-doc-est.
            buffer-copy tt-item-doc-est-ent TO tt-item-doc-est.
        end. 
              
        find docum-est no-lock where
             docum-est.nro-docto    =  tt-nota.nro-docto    and
             docum-est.serie        =  tt-nota.serie-nota   and
             docum-est.tipo-nota    =  tt-nota.tipo-nota    and
             docum-est.nat-operacao =  tt-nota.nat-operacao and
             docum-est.cod-emitente =  tt-nota.cod-emitente no-error.
        if not avail docum-est 
        then do: 

            /* Cria‡Æo do documento via BOïs */
            run intprg/int038a.p (input  table tt-nota,
                                  input  table tt-docum-est,
                                  input  table tt-item-doc-est,
                                  output table RowErrors).
            
            for each RowErrors where RowErrors.ErrorNumber  <> 6506 and
                RowErrors.ErrorSubType <> "warning":
                MESSAGE "RowErrors.ErrorNumber - " RowErrors.ErrorNumber
                    VIEW-AS ALERT-BOX INFO BUTTONS OK.
                 assign i-erro = 22 
                        c-informacao = "Estab.: " + c-cod-estabel + " - " + "Pedido: " + c-nr-pedcli + " - " 
                                       + "Natur. Oper.: " + c-natur-ent + " - " + 
                                      "Cod. Erro: " + string(RowErrors.ErrorNumber) + " - " + 
                                      RowErrors.ErrorDescription.
                        assign l-movto-entrada-erro = YES.
                 run gera-log.
            end.
        end.
        
        if l-movto-com-erro = NO 
        then do:
            find first tt-docum-est no-error. 
                                                                              
            find first docum-est no-lock where
                       int(docum-est.nro-docto) =  i-nro-docto-int038        and
                       docum-est.serie          =  tt-docum-est.serie        and
                       docum-est.tipo-nota      =  tt-docum-est.tipo-nota    and
                       docum-est.nat-operacao   =  tt-docum-est.nat-operacao and
                       docum-est.cod-emitente   =  tt-docum-est.cod-emitente no-error.
            if avail docum-est 
            then do:
               if docum-est.ce-atual = NO 
               then do:
                   
                   /*ASSIGN r-docum-est = ROWID(docum-est).*/

                   run pi-atualizadocumento. 
        
                   /*DO TRANS:
                      for first bf-docum-est WHERE 
                                ROWID(bf-docum-est) = r-docum-est:
                      end.
                      if avail bf-docum-est then do:
                         assign bf-docum-est.conta-transit = "91107005"
                                bf-docum-est.ct-transit    = "91107005".
                      end.
                      release bf-docum-est.
                   END.*/
                   /**** Usar como valida»’o para gera»’o das notas nÆo esquecer do dt-cancel ***/
        
                   /*
                   for first nota-fiscal where
                       nota-fiscal.cod-estabel      = docum-est.cod-estabel and 
                       nota-fiscal.serie            = docum-est.serie       and
                       INT(nota-fiscal.nr-nota-fis) = INT(docum-est.nro-docto),
                       first natur-oper no-lock where
                       natur-oper.nat-operacao = nota-fiscal.nat-operacao and 
                       natur-oper.tipo         = 1 : /* Entrada */  
        
                       assign nota-fiscal.nr-pedcli     = string(int_ds_pedido.ped_codigo_n)
                              nota-fiscal.nro-nota-orig = tt-docum-est.nro-docto.
                   end.
                   */
               end.
            end.
        end. /* l-movto com erro */
    end. /* each tt-nota */
end. /* emite-nota-entrada */

procedure emite-nota-saida:

    run pi-acompanhar in h-acomp (input "Gerando Nota Saida").

    /* Inicializa‡Æo das BOS para C lculo */
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

            run criaWtdocto in h-bodi317sd
                    (input  c-seg-usuario,
                     input  tt-ped-venda-prs.cod-estabel,
                     input  c-serie,
                     input  "",
                     input  tt-ped-venda-prs.nome-abrev,
                     input  "",
                     input  4, /* Complementar */
                     input  9999,
                     input  tt-ped-venda-prs.dt-emissao,
                     input  0, /* N£mero do embarque */
                     input  tt-ped-venda-prs.nat-operacao,
                     input  tt-ped-venda-prs.cod-canal-venda,
                     output i-seq-wt-docto,
                     output l-proc-ok-aux).
            /* Caso tenha achado algum erro ou advertˆncia, gera tt-erro */
            
            run pi-erro-nota(h-bodi317sd,'sd'). 
            if l-movto-com-erro then undo, return.

            for first wt-docto where
                      wt-docto.seq-wt-docto = i-seq-wt-docto:
                assign  wt-docto.nr-tabpre    = tt-ped-venda-prs.nr-tabpre
                        wt-docto.ind-lib-nota = yes
                        wt-docto.cod-cond-pag = tt-ped-venda-prs.cod-cond-pag
                        wt-docto.cod-entrega  = tt-ped-venda-prs.cod-entrega
                        wt-docto.nome-transp  = tt-ped-venda-prs.nome-transp
                        wt-docto.cod-rota     = tt-ped-venda-prs.cod-rota
                        wt-docto.cond-redespa = tt-ped-venda-prs.cond-redespa
                        wt-docto.cidade-cif   = tt-ped-venda-prs.cidade-cif
                        wt-docto.nome-tr-red  = tt-ped-venda-prs.nome-tr-red
                        wt-docto.placa        = tt-ped-venda-prs.placa
                        wt-docto.uf-placa     = tt-ped-venda-prs.uf-placa
                        wt-docto.observ-nota  = tt-ped-venda-prs.observacoes
                        wt-docto.ind-tp-frete = tt-ped-venda-prs.ind-tp-frete
                        wt-docto.nr-tab-finan = tt-ped-venda-prs.nr-tab-finan
                        wt-docto.nr-ind-finan = tt-ped-venda-prs.nr-ind-finan
                        wt-docto.cod-portador = tt-ped-venda-prs.cod-portador
                        wt-docto.modalidade   = tt-ped-venda-prs.modalidade
                        wt-docto.nr-pedcli    = /*tt-ped-venda-prs.nr-pedcli*/ "".   

                /*
                for first natur-oper no-lock where 
                    natur-oper.nat-operacao = wt-docto.nat-operacao:
                    if natur-oper.transf then do:
                        for first estab-mat fields (conta-transf) no-lock where 
                            estab-mat.cod-estabel = wt-docto.cod-estabel:
                            assign wt-docto.ct-transf-terc = estab-mat.cod-cta-transf-unif.
                        end.
                    end.
                end.
                */

                run emptyRowErrors          in h-bodi317sd.
                run emptyRowErrors          in h-bodi317va.
                /*
                run atualizaDadosGeraisnota in h-bodi317sd(input  i-seq-wt-docto,
                                                           output l-proc-ok-aux).
    
                */
                /* Caso tenha achado algum erro ou advertˆncia, gera tt-erro */
                run pi-erro-nota(h-bodi317sd,'sd'). if l-movto-com-erro then undo, return.
        
                run pi-gera-itens-nota.
                if l-movto-com-erro then undo, next.

                run pi-calcula-nota.
                if l-movto-com-erro then undo, next.
                
                run pi-efetiva-nota.
                if l-movto-com-erro then undo, next.

            end.    
        end.
    end.
    run pi-finaliza-bos.

end. /* emite-nota-saida */

procedure pi-gera-itens-nota:
             
    for each tt-ped-item-prs no-lock of tt-ped-venda-prs:

        run pi-acompanhar in h-acomp (input "Gerando Nota Saida item: " + tt-ped-item-prs.it-codigo).

        for first item fields (it-codigo deposito-pad item.cod-localiz tipo-con-est)
            no-lock where item.it-codigo = tt-ped-item-prs.it-codigo: end.
        for first item-uni-estab no-lock where 
            item-uni-estab.it-codigo = tt-ped-item-prs.it-codigo and
            item-uni-estab.cod-estabel = tt-ped-venda-prs.cod-estabel: end.

        /* disponibilizar o registro WT-doCTO na bodi317sd */
        run localizaWtdocto in h-bodi317sd(input  i-seq-wt-docto,
                                           output l-proc-ok-aux).
             
        /* faturamentos */
        if tt-ped-item-prs.nr-docum = "" then run pi-envios.
        /* beneficiamentos */
        else if natur-oper.terceiros /*and
                natur-oper.tp-oper-terc = 2 /* retorno beneficiamento */ */ then run pi-terceiros.
        /* devolucao */
        else run pi-devolucoes.

        /* disp. registro WT-doCTO, WT-IT-doCTO e WT-IT-IMPOSTO na bodi317pr */
        run localizaWtdocto       in h-bodi317pr(input  i-seq-wt-docto,
                                                 output l-proc-ok-aux).
       
        run localizaWtItdocto     in h-bodi317pr(input  i-seq-wt-docto,
                                                 input  i-seq-wt-it-docto,
                                                 output l-proc-ok-aux).

        run localizaWtItImposto   in h-bodi317pr(input  i-seq-wt-docto,
                                                 input  i-seq-wt-it-docto,
                                                 output l-proc-ok-aux).

        for each wt-it-docto exclusive-lock
            where wt-it-docto.seq-wt-docto    = i-seq-wt-docto:
            assign wt-it-docto.nr-pedcli      = tt-ped-item-prs.nr-pedcli
                   wt-it-docto.nr-seq-ped     = tt-ped-item-prs.nr-sequencia
                .
            /*
                   wt-it-docto.ct-cuscon      = wt-docto.ct-transf-terc
                   wt-it-docto.ct-cusven      = wt-docto.ct-transf-terc. 
            put stream str-rp "2 - " wt-docto.ct-transf-terc skip.
            */
        end.

        find first wt-it-imposto exclusive-lock 
            where wt-it-imposto.seq-wt-docto    = i-seq-wt-docto
              and wt-it-imposto.seq-wt-it-docto = i-seq-wt-it-docto no-error.

        if avail wt-it-imposto then
            assign wt-it-imposto.ind-icm-ret = l-ind-icm-ret.

        /* Atualiza dados c lculados do item */
        run atualizaDadositemnota in h-bodi317pr(output l-proc-ok-aux).
        /* Caso tenha achado algum erro ou advertˆncia, gera tt-erro */
        run pi-erro-nota(h-bodi317pr,'pr'). if l-movto-com-erro then undo, return.

        /* Valida informa‡äes do item */
        run validaitemDanota      in h-bodi317va(input  i-seq-wt-docto,
                                                 input  i-seq-wt-it-docto,
                                                 output l-proc-ok-aux).
        /* Caso tenha achado algum erro ou advertˆncia, gera tt-erro */
        assign c-it-codigo = tt-ped-item-prs.it-codigo.
        run pi-erro-nota(h-bodi317va,'va'). if l-movto-com-erro then undo, return.

    end. /* tt-ped-item-prs */
    if l-movto-com-erro then undo, leave.
end procedure. /* pi-gera-itens-nota */

procedure pi-envios:
    def var de-qt-utilizada as decimal no-undo.
        
    /* Cria um item para nota fiscal. */
    run criaWtItdocto in h-bodi317sd  (input  ?,
                                       input  "",
                                       input  tt-ped-item-prs.nr-sequencia,
                                       input  tt-ped-item-prs.it-codigo,
                                       input  tt-ped-item-prs.cod-refer,
                                       input  tt-ped-item-prs.nat-operacao,
                                       output i-seq-wt-it-docto,
                                       output l-proc-ok-aux).
    /* Caso tenha achado algum erro ou advertˆncia, gera tt-erro */
    run pi-erro-nota(h-bodi317sd,'sd'). 
    if l-movto-com-erro then undo, return.
    
    run WriteUomQuantity in h-bodi317sd 
        (input  i-seq-wt-docto,
         input  i-seq-wt-it-docto,
         input  tt-ped-item-prs.qt-pedida,
         input  tt-ped-item-prs.cod-un,
         output de-quantidade,
         output l-proc-ok-aux).

    /* Grava informa‡ões gerais para o item da nota */
    run gravaInfGeraisWtItDocto in h-bodi317sd 
            (input i-seq-wt-docto,
             input i-seq-wt-it-docto,
             input /*tt-ped-item-prs.qt-pedida,*/ de-quantidade,
             input tt-ped-item-prs.vl-preori,
             input 0, 
             input 0).


    /*if tt-ped-item-prs.numero-lote <> "" 
    then*/ do:
        for each Wt-fat-ser-lote exclusive-lock 
            where  wt-fat-ser-lote.seq-wt-docto    = i-seq-wt-docto 
              and  wt-fat-ser-lote.seq-wt-it-docto = i-seq-wt-it-docto:
            delete wt-fat-ser-lote.
        end.
        
        de-qt-utilizada = /*tt-ped-item-prs.qt-pedida.*/ de-quantidade.

       if c-cod-estabel = "973" 
       then
           assign c-cod-depos = "973".
       else
           assign c-cod-depos = "LOJ".
        
        for first deposito no-lock 
            where deposito.cod-depos = c-cod-depos:
            /*
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
                run pi-erro-nota(h-bodi317sd,'sd'). if l-movto-com-erro then undo, return.
            end.
            */
            run criaAlteraWtFatSerLote in h-bodi317sd 
                    (input yes,
                     input i-seq-wt-docto,
                     input i-seq-wt-it-docto,
                     input tt-ped-item-prs.it-codigo,
                     input deposito.cod-depos,
                     input "",
                     input if item.tipo-con-est = 3 then tt-ped-item-prs.numero-lote else "",
                     input de-qt-utilizada,
                     input 0,
                     input ?,
                     output l-proc-ok-aux).
            de-qt-utilizada = 0.
        end.

        if de-qt-utilizada > 0 then do:
            assign i-erro = 33
                   c-informacao = "Pedido: " + c-nr-pedcli + " Lote: " + tt-ped-item-prs.numero-lote
                   l-movto-com-erro = yes.
            run gera-log. 
            return.
        end.
    end.
end. /* pi-envios */

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
    run confirmaCalculo          in h-bodi317pr(input  i-seq-wt-docto,
                                                output l-proc-ok-aux).
    run finalizaAcompanhamento   in h-bodi317pr.

    /* Caso tenha achado algum erro ou advertˆncia, gera tt-erro */
    run pi-erro-nota(h-bodi317pr,'pr'). if l-movto-com-erro then undo, return.

end procedure. /* pi-calcula-nota */


procedure pi-efetiva-nota:
    /* Efetiva a nota */
    run dibo/bodi317ef.p persistent set h-bodi317ef.
    run emptyRowErrors           in h-bodi317in. 
    run inicializaAcompanhamento in h-bodi317ef.
    run setaHandlesBOS           in h-bodi317ef(h-bodi317pr,     
                                                h-bodi317sd, 
                                                h-bodi317im1bra, 
                                                h-bodi317va).
    run efetivanota              in h-bodi317ef(input  i-seq-wt-docto,
                                                input  yes,
                                                output l-proc-ok-aux).
    run finalizaAcompanhamento   in h-bodi317ef.
    /* Caso tenha achado algum erro ou advertˆncia, gera tt-erro */
    run pi-erro-nota(h-bodi317ef,'ef'). if l-movto-com-erro then undo, return.

    /* Busca as notas fiscais geradas */
    run buscaTTnotasGeradas in h-bodi317ef(output l-proc-ok-aux,
                                           output table tt-notas-geradas).
    for each tt-notas-geradas:
        for first nota-fiscal exclusive-lock where 
            rowid(nota-fiscal) = tt-notas-geradas.rw-nota-fiscal:
            assign nota-fiscal.docto-orig = c-docto-orig
                   nota-fiscal.obs-gerada = c-obs-gerada
                   nota-fiscal.nr-pedcli  = tt-ped-venda-prs.nr-pedcli.
        end.
    end.
   /* Elimina o handle do programa bodi317ef */
   delete procedure h-bodi317ef.
end. /* pi-efetiva-nota */

procedure pi-finaliza-bos:
    if  valid-handle(h-bodi317va) then delete procedure h-bodi317va.
    if  valid-handle(h-bodi317pr) then delete procedure h-bodi317pr.
    if  valid-handle(h-bodi317sd) then delete procedure h-bodi317sd.
    if  valid-handle(h-bodi317im1bra) then delete procedure h-bodi317im1bra.
end. /* pi-finaliza-bos */


procedure pi-erro-nota:
    define input parameter h-bo as handle.
    define input parameter c-bo as char no-undo.

    def var c-proc as char no-undo.
    
    assign c-proc = "devolveErrosbodi317" + c-bo.

    /* Busca poss¡veis erros que ocorreram nas valida‡äes */
    run value(c-proc) in h-bo (output c-ultimo-metodo-exec,
                               output table RowErrors).
    for each RowErrors:
        if RowErrors.errornumber = 15450 then next. /* saldo */ 
        if RowErrors.errornumber = 26082 then next. /* saldo */ 
        if RowErrors.errornumber = 31520 then next. /* saldo */ 
        if RowErrors.errornumber = 15046 then next. /* aviso */
        if RowErrors.errornumber = 15047 then next. /* aviso */
        if RowErrors.errornumber = 15091 then next. /* aviso */
        IF RowErrors.ErrorSubType = "Warning" THEN NEXT.
        /*if RowErrors.errornumber = 8304  then next. /* aviso */*/
        /*if RowErrors.errornumber = 18507 then next. /* aviso */*/

        MESSAGE "RowErrors.errornumber - " RowErrors.errornumber
            VIEW-AS ALERT-BOX INFO BUTTONS OK.
        assign i-erro = 22
               c-informacao = "Estab.: " + c-cod-estabel + " Cliente: " + string(i-cod-emitente) + " Pedido: " + c-nr-pedcli + " BO: " 
                              + c-bo + " Natur. Oper.: " + c-natur + " S‚rie: " + c-serie + " item: " + c-it-codigo + " - " +
                              "Cod. Erro.: " + string(RowErrors.errornumber) + " - " + 
                              RowErrors.errordescription
               l-movto-com-erro = yes.
        run gera-log. 
        return.
    end.
end. /* pi-erro-nota */

procedure gera-log.

   run pi-acompanhar in h-acomp (input "Listando Erros").

   if tt-param.arquivo <> "" then do:
       display stream str-rp
               i-nr-registro
               with frame f-erro. 
           
       display stream str-rp
               tb-erro[i-erro] @ tb-erro[1]
               c-informacao
               with frame f-erro.
       down stream str-rp
            with frame f-erro.
   end.

   run intprg/int999.p ("NF Balanco", 
                        c-nr-pedcli,
                        (trim(tb-erro[i-erro]) + " - " + c-informacao),
                        int_ds_pedido.situacao, /* 1 - Pendente, 2 - Processado */ 
                        c-seg-usuario,
                        "INT038RP.P").
   assign c-informacao = " ".
end. /* gera-log */

procedure pi-calcula-preco:

    if de-vl-uni = 0
    then do:
                                                            
       for first item-uni-estab  no-lock where 
                 item-uni-estab.cod-estabel = "973" and  
                 item-uni-estab.it-codigo   = c-it-codigo:                 
           assign de-vl-uni = item-uni-estab.preco-base.  /* Pre‡o base */
       end.              
    end.
  
end procedure. /* pi-calcula-preco */

procedure pi-altera-itens:
  def input parameter p-tipo as integer.

  DISABLE TRIGGERS for LOAD OF b-item.
  DISABLE TRIGGERS for LOAD OF item-uni-estab.

  for each tt-item: 
        
     for first b-item where
               b-item.it-codigo = string(tt-item.it-codigo):
         
         assign b-item.cod-obsoleto = p-tipo.
         
     end.

     release b-item.
    
     for first item-uni-estab fields(cod-estabel it-codigo cod-obsoleto) where 
               item-uni-estab.cod-estabel = c-cod-estabel and 
               item-uni-estab.it-codigo   = tt-item.it-codigo: 
     end.

     if avail item-uni-estab       
     then do:
         assign item-uni-estab.cod-obsoleto = p-tipo.
     end.

     release item-uni-estab.

  end.

end procedure. /* pi-altera-itens */
     

{intprg/int038.i} /* Atualiza documento */


/* FIM do PROGRAMA */








