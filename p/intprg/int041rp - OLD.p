/********************************************************************************
** Programa: INT041 - Gera‡Æo notas fiscais a partir de Pedidos Notas de Retorno
**                    Notas nÆo podem ser mais canceladas devido ao per¡odo estipulado pelo SEFAZ 
**
** Versao : 1 - 10/2016 - ResultPro
**
********************************************************************************/
/* include de controle de versao */
{include/i-prgvrs.i INT041rp 2.12.02.AVB}

{rep/reapi191.i1}
{rep/reapi190b.i}

/* definiçao das temp-tables para recebimento de parametros */
    define temp-table tt-param no-undo
        field destino          as integer
        field arquivo          as char format "x(35)":U
        field usuario          as char format "x(12)":U
        field data-exec        as date
        field hora-exec        as integer
        FIELD dt-periodo-ini   AS DATE FORMAT "99/99/9999"
        FIELD dt-periodo-fim   AS DATE FORMAT "99/99/9999"
        FIELD cod-estabel-ini  AS CHAR format "x(03)"
        FIELD cod-estabel-fim  AS CHAR FORMAT "x(03)"
        FIELD pedido-ini       AS INTEGER FORMAT ">>>>>>>9"
        FIELD pedido-fim       AS INTEGER FORMAT ">>>>>>>9".                               



DEF TEMP-TABLE tt-retorno NO-UNDO
FIELD ped-tipopedido-n LIKE int-ds-pedido.ped-tipopedido-n.

DEFINE TEMP-TABLE tt-item
FIELD it-codigo LIKE ITEM.it-codigo.

DEFINE TEMP-TABLE tt-estab NO-UNDO
FIELD cod-estabel LIKE estabelec.cod-estabel
FIELD cgc         LIKE estabelec.cgc
FIELD dt-fim-operacao LIKE cst-estabelec.dt-fim-operacao. 
                 
DEF TEMP-TABLE tt-nota no-undo
    FIELD situacao     AS INTEGER
    FIELD nro-docto    LIKE docum-est.nro-docto   
    FIELD serie-nota   LIKE docum-est.serie-docto
    FIELD serie-docum  LIKE docum-est.serie-docto        
    FIELD cod-emitente LIKE docum-est.cod-emitente
    FIELD nat-operacao LIKE docum-est.nat-operacao
    FIELD tipo-nota    LIKE int-ds-docto-xml.tipo-nota
    FIELD valor-mercad LIKE doc-fisico.valor-mercad.

define temp-table tt-param-int012 no-undo
    field destino          as integer
    field arquivo          as char format "x(35)"
    field usuario          as char format "x(12)"
    field data-exec        as date
    field hora-exec        as integer
    field classifica       as integer
    field desc-classifica  as char format "x(40)"
    field cod-emitente-fim as integer
    field cod-emitente-ini as integer
    field cod-estabel-fim  as char
    field cod-estabel-ini  as char
    field dt-emis-nota-fim as date
    field dt-emis-nota-ini as date
    field nro-docto-fim    as integer
    field nro-docto-ini    as integer
    field serie-docto-fim  as char
    field serie-docto-ini  as char.

{intprg/int002.i}
{intprg/int002c.i}

{inbo/boin090.i tt-docum-est}       /* Defini¯?o TT-DOCUM-EST       */
{inbo/boin176.i tt-item-doc-est}    /* Defini¯?o TT-ITEM-DOC-EST    */

DEF TEMP-TABLE tt-nota-ent          NO-UNDO LIKE tt-nota.
DEF TEMP-TABLE tt-docum-est-ent     NO-UNDO LIKE tt-docum-est-nova.
DEF TEMP-TABLE tt-item-doc-est-ent  NO-UNDO LIKE tt-item-doc-est-nova.
               
DEF TEMP-TABLE tt-nfe NO-UNDO
FIELD ped-codigo-n LIKE int-ds-pedido.ped-codigo-n
FIELD nro-docto    AS INTEGER.

DEF TEMP-TABLE tt-it-nfe NO-UNDO
FIELD ped-codigo-n LIKE  int-ds-pedido.ped-codigo-n
FIELD nro-docto    AS INTEGER
FIELD it-codigo    LIKE  item.it-codigo 
FIELD quantidade   LIKE  int-ds-pedido-retorno.rpp-quantidade-n
FIELD vl-uni       LIKE item-uni-estab.preco-base
FIELD nr-caixa     AS   CHAR
FIELD lote         LIKE movto-estoq.lote
FIELD serie-comp   LIKE nota-fiscal.serie
FIELD nro-comp     LIKE nota-fiscal.nr-nota-fis 
FIELD nat-comp     LIKE nota-fiscal.nat-operacao
FIELD seq-comp     LIKE it-nota-fisc.nr-seq-fat.
         
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

DEF TEMP-TABLE tt-arquivo-erro
    FIELD c-linha AS CHAR.

DEF TEMP-TABLE tt-erro-nota NO-UNDO
    FIELD serie        AS CHAR FORMAT "x(03)"
    FIELD nro-docto    AS CHAR FORMAT "9999999"
    FIELD cod-emitente AS INTEGER FORMAT ">>>>>>>>9"
    FIELD cod-erro     AS INTEGER FORMAT ">>>>>9"
    FIELD descricao    AS CHAR.

/* temp-tables das API's e BO's */
{method/dbotterr.i}

/* recebimento de parametros */
def input parameter raw-param as raw no-undo.
def input parameter table for tt-raw-digita.  

create tt-param.                    
raw-transfer raw-param to tt-param no-error.
IF tt-param.arquivo = "" THEN 
    ASSIGN tt-param.arquivo         = "INT041.txt"
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

/* ++++++++++++++++++ (Definicao Stream) ++++++++++++++++++ */

/* ++++++++++++++++++ (Definicao Buffer) ++++++++++++++++++ */

DEFINE BUFFER b-int-ds-pedido FOR int-ds-pedido.
DEFINE BUFFER b-item          FOR ITEM.
DEFINE BUFFER b-docum-est     FOR docum-est.
DEFINE BUFFER b-nota-fiscal   FOR nota-fiscal.

/* definiçao de variáveis  */
DEF VAR h-api                AS HANDLE NO-UNDO.
def var h-acomp              as handle no-undo.
def var l-proc-ok-aux        as log    no-undo.
def var i-seq-wt-docto       as int    no-undo.
def var i-seq-wt-it-docto    as int    no-undo.
def var i-seq-wt-it-last     as int    no-undo.
def var c-ultimo-metodo-exec as char   no-undo.

DEF VAR i-seq-item           AS INTEGER             NO-UNDO.
DEF VAR i-pos-arq            AS INTEGER             NO-UNDO.
DEF VAR c-nr-nota            AS CHAR FORMAT "x(07)" NO-UNDO.
DEF VAR c-linha              AS CHAR                NO-UNDO.
DEF VAR c-cod-depos          AS CHAR                NO-UNDO.
DEF VAR c-nat-docum          AS CHAR                NO-UNDO.
DEF VAR i-nro-docto          AS INT                 NO-UNDO.
DEF VAR i-seq-entrada        AS INT                 NO-UNDO.
DEF VAR l-nota-saida         AS LOGICAL             NO-UNDO.
DEF VAR c-log                AS CHAR                NO-UNDO.

DEF VAR c-cont-contabil      AS CHAR. 
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
DEF VAR c-natur-ent          LIKE natur-oper.nat-operacao.
def var de-vl-uni            LIKE item-uni-estab.preco-base.
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
def var l-movto-com-erro     as logical init NO NO-UNDO.
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
def var tb-erro              as char format "x(50)" extent 45 init
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
                              "21. Natureza de Operacao nao Cadastrada em INT015 ",
                              "22. ERRO BO de Calculo                            ",
                              "23. Transportador de redespachop NAO Cadastrado   ",
                              "24. Codigo do Cliente p/ Entrega NAO Existe       ",
                              "25. Quantidade de parcelas p/ pagto inconsistente ",
                              "26. Cliente so pode comprar A Vista               ",
                              "27. Cliente esta Suspenso                         ",
                              "28. Nat de Operacao Devolucao exige nota origem",
                              "29. Nota Origem Informada e Nat. Oper. Envio      ",
                              "30. Estabelecimento nao Cadastrado/Fora de Oper.  ",
                              "31. Canal de vendas nao Cadastrado                ",
                              "32. Nat.Operacao indicada esta Inativa            ",
                              "33. Saldo estoque insuficiente p/ envio do lote   ",
                              "34. Natureza de Opera‡Æo deve ser Devolu‡Æo       ",
                              "35. Tabela de Financiamento NAO Cadastrada        ",
                              "36. Pedido j  foi faturado                        ",
                              "37. Pedido inconsistente ou sem itens             ",
                              "38. Valor do item zerado                          ",
                              "39. Documento Pendente ou n’o cadastrado no int002",
                              "40. Natureza de Opera‡Æo deve ser de entrada NFE",
                              "41. Nota Deve ser autorizada pelo SEFAZ",
                              "42. Classifica‡ao Fiscal Do item nÆo cadastrada",
                              "43. Natureza de Opera‡Æo deve estar marcada para gerar faturamento",
                              "44. Item Parametrizado como d‚bito direto, nÆo possui conta cont bil cadastrada",
                              "45. Usu rio do Faturamento nÆo cadastrado"].

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
def var c-uf-destino        as char no-undo. 
def var c-uf-origem        as char no-undo. 
def var c-cod-estabel   as char no-undo.
def var c-nome-abrev    as char no-undo.
def var l-ind-icm-ret   as logical no-undo.
def var c-class-fiscal  as char no-undo.
def var i-cod-portador  as integer no-undo.
def var i-modalidade    as integer no-undo.
def var c-serie         as char no-undo.
DEF VAR c-serie-ent     AS CHAR NO-UNDO.
def var r-rowid         as rowid no-undo.
def var i-cst-icms      as integer no-undo.
DEF VAR l-movto-entrada-erro AS LOGICAL NO-UNDO.

DEF NEW GLOBAL SHARED VAR i-nro-docto-int038  AS INTEGER FORMAT "9999999"  NO-UNDO. /* Retorna a nota gerada */

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
assign c-programa       = "INT041RP"
       c-versao         = "2.12"
       c-revisao        = ".02.AVB"
       c-empresa        = "* Nao Definido *"
       c-sistema        = "Faturamento"
       c-titulo-relat   = "Gera‡Æo de Notas Fiscais - Pedidos de Retorno".

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


   ASSIGN c-log = SESSION:TEMP-DIRECTORY + "log-int041-producao.txt".

   /* log-manager:logfile-name= c-log.
      log-manager:log-entry-types= "4gltrace".
   */

   run pi-elimina-tabelas.
   run pi-importa.

   pause 3 no-message.
   /*
   run envia-e-mail.
   */
end.
/* ----- fim do programa -------- */
run pi-elimina-tabelas.

if tt-param.arquivo <> "" then do:
    /* fechamento do output do relatorio  */
    {include/i-rpclo.i &stream="stream str-rp"}
end.
run pi-finalizar in h-acomp.

/* log-manager:close-log(). */

/* elimina BO's */

return "OK".

/* procedures */

procedure pi-elimina-tabelas.
   run pi-acompanhar in h-acomp (input "Eliminando Tabelas Temporarias").
   /* limpa temp-tables */
   
   EMPTY TEMP-TABLE tt-nfe.
   EMPTY TEMP-TABLE tt-it-nfe.
   EMPTY TEMP-TABLE tt-nota.
   EMPTY TEMP-TABLE tt-docum-est.
   EMPTY TEMP-TABLE tt-item-doc-est.
   EMPTY TEMP-TABLE tt-nota-ent.
   EMPTY TEMP-TABLE tt-docum-est-ent.
   EMPTY TEMP-TABLE tt-item-doc-est-ent.
   EMPTY TEMP-TABLE tt-item.

   empty temp-table RowErrors.   
   empty temp-table tt-mensagem.
end.        

procedure pi-importa:
    
    run pi-acompanhar in h-acomp (input "Lendo Pedidos").
    
    assign i-nr-registro    = 0.

    EMPTY TEMP-TABLE tt-retorno.
    EMPTY TEMP-TABLE tt-estab.

    FOR EACH estabelec NO-LOCK WHERE
             estabelec.cod-estabel >= tt-param.cod-estabel-ini AND 
             estabelec.cod-estabel <= tt-param.cod-estabel-fim :
    
        CREATE tt-estab.
        ASSIGN tt-estab.cod-estabel = estabelec.cod-estabel
               tt-estab.cgc         = estabelec.cgc. 

         FOR first cst-estabelec no-lock where 
                   cst-estabelec.cod-estabel = estabelec.cod-estabel:
                
            ASSIGN tt-estab.dt-fim-operacao = cst-estabelec.dt-fim-operacao.

        END.
    
    END.

    DO i-cont = 50 TO 55:
        CASE i-cont:
            WHEN 51 THEN RUN pi-cria-retorno(INPUT i-cont). /* estorno  51 */
            WHEN 52 THEN RUN pi-cria-retorno(INPUT i-cont). /* estorno  52 */
            WHEN 53 THEN RUN pi-cria-retorno(INPUT i-cont). /* estorno  53 */
        END CASE.
    END.

    FIND FIRST para-fat NO-ERROR.

    for EACH tt-retorno ,
        each int-ds-pedido no-lock WHERE 
             int-ds-pedido.ped-tipopedido-n = tt-retorno.ped-tipopedido-n AND
             int-ds-pedido.ped-codigo-n    >=  tt-param.pedido-ini        AND  
             int-ds-pedido.ped-codigo-n    <=  tt-param.pedido-fim        AND
        date(int-ds-pedido.dt-geracao)     >= tt-param.dt-periodo-ini     AND                
        date(int-ds-pedido.dt-geracao)     <= tt-param.dt-periodo-fim     AND 
             int-ds-pedido.situacao         = 1 ,
         FIRST tt-estab WHERE
               tt-estab.cgc = int-ds-pedido.ped-cnpj-destino-s  AND 
               tt-estab.dt-fim-operacao >= int-ds-pedido.dt-geracao query-tuning(no-lookahead):

        run pi-acompanhar in h-acomp (input "Lendo Pedidos Invent rio: " + string(int-ds-pedido.ped-codigo-n)).

        assign  l-movto-com-erro  = no
                c-uf-destino      = ""
                c-uf-origem       = "".

        assign  c-nr-pedcli         = trim(string(int-ds-pedido.ped-codigo-n))
                d-dt-implantacao    = today
                d-dt-entrega        = int-ds-pedido.ped-dataentrega-d
                d-dt-emissao        = /*int-ds-pedido.ped-data-d*/ d-dt-implantacao
                c-observacao        = int-ds-pedido.ped-observacao-s
                c-placa             = int-ds-pedido.ped-placaveiculo-s
                c-uf-placa          = int-ds-pedido.ped-estadoveiculo-s
                c-tp-pedido         = trim(string(int-ds-pedido.ped-tipopedido-n))
                c-docto-orig        = trim(string(int-ds-pedido.ped-codigo-n)).

        RUN valida-pedido.

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
        THEN DO:
        
            for each int-ds-pedido-produto no-lock of int-ds-pedido ,
                each int-ds-pedido-retorno NO-LOCK of int-ds-pedido-produto 
                query-tuning(no-lookahead)
                break by int-ds-pedido-retorno.ppr-produto-n
                      by int-ds-pedido-retorno.rpp-lote-s:
                        
                assign de-vl-uni           = 0
                       c-it-codigo         = trim(string(int-ds-pedido-produto.ppr-produto-n))
                       de-quantidade       = int-ds-pedido-retorno.rpp-quantidade-n 
                       de-desconto         = int-ds-pedido-produto.ppr-percentualdesconto-n
                       c-numero-caixa      = ""
                       c-numero-caixa      = (if c-numero-caixa = ""
                                              then string(int-ds-pedido-retorno.rpp-caixa-n)
                                              else c-numero-caixa + "," + string(int-ds-pedido-retorno.rpp-caixa-n))
                       c-numero-lote       = if trim(int-ds-pedido-retorno.rpp-lote-s) <> "0" and 
                                                trim(int-ds-pedido-retorno.rpp-lote-s) <> "?" and
                                                trim(int-ds-pedido-retorno.rpp-lote-s) <> ? then trim(int-ds-pedido-retorno.rpp-lote-s) else ""
                       c-nr-docum          = if int-ds-pedido-produto.nen-notafiscal-n <> ? and
                                             int-ds-pedido-produto.nen-notafiscal-n <> 0 and
                                             int-ds-pedido.ped-tipopedido-n <> 33 
                                             then trim(string(int-ds-pedido-produto.nen-notafiscal-n,">>9999999")) else ""
                       c-serie-docum       = if int-ds-pedido-produto.nen-serie-s <> ? and int-ds-pedido.ped-tipopedido-n <> 33 then int-ds-pedido-produto.nen-serie-s else ""

                       i-seq-docum         = if int-ds-pedido-produto.nep-sequencia-n <> ? and int-ds-pedido.ped-tipopedido-n <> 33 
                                             then int-ds-pedido-produto.nep-sequencia-n else 0.



                RUN pi-calcula-preco.

                /*** Retirar apenas para teste
                IF de-vl-uni = 0 THEN
                   ASSIGN de-vl-uni = int-ds-pedido-produto.ppr-valorliquido-n. 

                IF de-vl-uni = 0 THEN
                   ASSIGN de-vl-uni = 1. **/   
                                   
                ASSIGN i-seq-entrada = i-seq-entrada + 1.
                                                              
                IF i-seq-entrada = para-fat.nr-item-nota THEN
                   ASSIGN i-nro-docto   = i-nro-docto + 1
                          i-seq-entrada = 1.
                        
                 FOR FIRST tt-nfe NO-LOCK WHERE
                           tt-nfe.ped-codigo-n = int-ds-pedido.ped-codigo-n AND  
                           tt-nfe.nro-docto    = i-nro-docto :
                 END.
                 IF NOT AVAIL tt-nfe 
                 THEN DO:
                      
                    CREATE tt-nfe.
                    ASSIGN tt-nfe.ped-codigo-n = int-ds-pedido.ped-codigo-n
                           tt-nfe.nro-docto    = i-nro-docto. 

                    run valida-nota-entrada.

                    if l-movto-com-erro then next.

                 END.

                 FIND FIRST tt-it-nfe WHERE 
                            tt-it-nfe.ped-codigo-n = int-ds-pedido.ped-codigo-n AND 
                            tt-it-nfe.nro-docto    = i-nro-docto                AND  
                            tt-it-nfe.it-codigo    = c-it-codigo                AND
                            tt-it-nfe.lote         = c-numero-lote NO-ERROR.    
                 IF NOT AVAIL tt-it-nfe 
                 THEN DO:
                    
                    CREATE tt-it-nfe.
                    ASSIGN tt-it-nfe.ped-codigo-n = int-ds-pedido.ped-codigo-n
                           tt-it-nfe.nro-docto    = i-nro-docto    
                           tt-it-nfe.it-codigo    = c-it-codigo 
                           tt-it-nfe.quantidade   = de-quantidade
                           tt-it-nfe.vl-uni       = de-vl-uni 
                           tt-it-nfe.nr-caixa     = c-numero-caixa
                           tt-it-nfe.lote         = c-numero-lote
                           tt-it-nfe.nro-comp     = c-nr-docum
                           tt-it-nfe.serie-comp   = c-serie-docum 
                           tt-it-nfe.seq-comp     = i-seq-docum * 10.
                 END.
                 ELSE 
                    ASSIGN tt-it-nfe.quantidade   = tt-it-nfe.quantidade + de-quantidade.  

                 run valida-item-entrada. 
                       
                 if l-movto-com-erro then next.
                 
                 IF LAST(int-ds-pedido-retorno.rpp-lote-s) 
                 THEN DO:
                                        
                    run pi-cria-tt-docum-est. 
                    
                 END.   

            end. /* For each int-ds-pedido-produto */

        END. /* l-movto-com-erro */
        
        FIND FIRST tt-nfe NO-ERROR.
            
        IF AVAIL tt-nfe 
        THEN DO:
            for first tt-item-doc-est-ent: 

            end.
            if not l-movto-com-erro and not avail tt-item-doc-est-ent 
            then do:
              assign i-erro = 37
                    c-informacao = "Pedido: " + c-nr-pedcli + " CNPJ Origem: " + string(int-ds-pedido.ped-cnpj-origem)
                    l-movto-com-erro = yes.
               run gera-log. 
            end.
        END.
                
        run pi-acompanhar in h-acomp (input "Finalizando Pedido").
        
        if not l-movto-com-erro 
        then do:
               RUN pi-altera-item(INPUT 2). 
               
               run emite-nota-entrada. 
              
              if not l-movto-com-erro AND 
                 NOT l-movto-entrada-erro  
              then do:
                 assign i-erro       = 1
                        c-informacao = "Pedido: "    +  c-nr-pedcli
                                     + " Emitente: " + c-nome-abrev.
                 find FIRST b-int-ds-pedido  WHERE 
                            ROWID(b-int-ds-pedido) = ROWID(int-ds-pedido) NO-ERROR.
                 if avail b-int-ds-pedido 
                 THEN DO:
                
                     assign b-int-ds-pedido.situacao = 2 /* integrado */.
                        
                     run gera-log-final.

                  END.

                  release b-int-ds-pedido.

                  FOR EACH nota-fiscal NO-LOCK WHERE
                           nota-fiscal.cod-estabel = c-cod-estabel AND 
                           nota-fiscal.nr-pedcli   = STRING(int-ds-pedido.ped-codigo-n):
                   
                      DISP STREAM str-rp nota-fiscal.cod-estabel AT 63
                                         nota-fiscal.serie
                                         nota-fiscal.nr-nota-fis  
                                         nota-fiscal.nat-operacao
                                         nota-fiscal.dt-emis
                                         nota-fiscal.dt-cancel
                                        WITH STREAM-IO WIDTH 333 DOWN FRAME f-notas.
                                   DOWN WITH FRAME f-notas.
                   
                  END.

              end.

               /* RUN pi-altera-item(INPUT 4).  NÆo voltar antes de atualizar a nota no estoque */ 

        end.
            
            /* DISP STREAM str-rp "Notas de Entrada" SKIP.
                 
            FOR EACH tt-nfe :

                DISP STREAM str-rp tt-nfe
                          WITH WIDTH 333 STREAM-IO.
                     
                FOR EACH tt-it-nfe WHERE
                         tt-it-nfe.ped-codigo-n = tt-nfe.ped-codigo-n:
    
                   DISP STREAM str-rp tt-it-nfe
                       WITH WIDTH 333 STREAM-IO.

                END.

            END. */

        run pi-elimina-tabelas. 
        
    END. /* for ech int-ds-pedido. */

END PROCEDURE.
          

PROCEDURE pi-cria-retorno:
DEF INPUT PARAMETER p-tipo AS INTEGER.
  
  CREATE tt-retorno.
  ASSIGN tt-retorno.ped-tipopedido-n = p-tipo.

END.
 
procedure valida-pedido:
  
    run pi-acompanhar in h-acomp (input "Validando Pedido").
    
    assign c-cod-estabel = "".
    for each estabelec 
        fields (cod-estabel estado cidade 
                cep pais endereco bairro ep-codigo) 
        no-lock where
        estabelec.cgc = int-ds-pedido.ped-cnpj-destino-s,
        first cst-estabelec no-lock where 
        cst-estabelec.cod-estabel = estabelec.cod-estabel and
        cst-estabelec.dt-fim-operacao >= d-dt-emissao:
        assign c-cod-estabel = estabelec.cod-estabel
               c-uf-destino  = estabelec.estado.
        leave.
    end.
    if c-cod-estabel = "" then
    do:
       assign i-erro = 30
              c-informacao = "Pedido: " + c-nr-pedcli + " CNPJ Destino: " + string(int-ds-pedido.ped-cnpj-destino-s)
              l-movto-com-erro = yes.
       run gera-log. 
       return.
    end.

END.

PROCEDURE valida-nota-entrada:
         /* 1949 - Entrada sempre para o mesmo estado 
            5949 - Sa¡da para o mesmo estado */
                    
    assign  i-cod-emitente = 0
            i-cod-cond-pag = 0.

    for first emitente no-lock where
              emitente.cgc = trim(int-ds-pedido.ped-cnpj-origem-s):
        assign  c-nome-abrev   = emitente.nome-abrev
                i-cod-emitente = emitente.cod-emitente
                c-nr-tabpre    = emitente.nr-tabpre
                i-canal-vendas = emitente.cod-canal-venda
                i-cod-rep      = if emitente.cod-rep <> 0 
                                 then emitente.cod-rep
                                 else i-cod-rep
                i-cod-cond-pag = emitente.cod-cond-pag
                c-cod-transp   = int-ds-pedido.ped-cnpj-transportadora
                c-uf-origem   = emitente.estado.
                  
    end.

    if c-nome-abrev = "" then do:
        assign i-erro = 2
               c-informacao = "Pedido: " + c-nr-pedcli + " CNPJ Destino: " + string((int-ds-pedido.ped-cnpj-destino))
               l-movto-com-erro = yes.
        run gera-log. 
        return.
    end.
   
    FIND FIRST user-coml NO-LOCK WHERE
               user-coml.usuario = c-seg-usuario NO-ERROR.
    IF NOT AVAIL user-coml 
    THEN DO:

         assign i-erro = 45
               c-informacao = "Pedido: " + c-nr-pedcli + " Usu rio: " + string(c-seg-usuario).
               l-movto-com-erro = yes.
        run gera-log. 
        return.
        
    END.

    /****  Incluir usu rio do recebimento */


END.
 
procedure valida-item-entrada:

   run pi-acompanhar in h-acomp (input "Validando Itens Entrada : " +  c-it-codigo ).
                             
   for first item NO-LOCK where
             item.it-codigo = c-it-codigo:

        ASSIGN c-class-fiscal = item.class-fiscal.

   end.
   
   if not avail item then do:
      assign i-erro = 9
             c-informacao = "Pedido: " + c-nr-pedcli + " Item: " + 
                            c-it-codigo 
             l-movto-com-erro = yes.
      run gera-log. 
      return.

   end.
    
   FOR FIRST classif-fisc NO-LOCK WHERE
             classif-fisc.class-fiscal = c-class-fiscal AND 
             classif-fisc.class-fiscal <> ""  :
   END.

   
   IF NOT AVAIL classif-fisc 
   THEN DO:

          /* ASSIGN ITEM.class-fiscal = "33059000". */
                            
         assign i-erro = 42
             c-informacao = "Pedido: " + c-nr-pedcli + " Item: " + 
                            c-it-codigo
             l-movto-com-erro = yes.

      run gera-log. 
      return.

   END.

   IF AVAIL ITEM AND ITEM.tipo-contr = 4 /* D‚bito Direto */
   THEN DO:

       FOR FIRST item-uni-estab NO-LOCK WHERE
                 item-uni-estab.cod-estabel = c-cod-estabel AND
                 item-uni-estab.it-codigo   = item.it-codigo :
       END.

       IF AVAIL item-uni-estab THEN
          ASSIGN c-cont-contabil = item-uni-estab.ct-codigo.
       ELSE 
          ASSIGN c-cont-contabil = ITEM.ct-codigo. 
       
      IF c-cont-contabil = "" 
      THEN DO:

          assign i-erro = 44
                 c-informacao = " Item: " + 
                                c-it-codigo
                 l-movto-com-erro = yes.
    
          run gera-log. 
          return.

      END.
      
   END.
 
   if avail item and item.cod-obsoleto = 4 
   then do:
      /* assign i-erro = 10
             c-informacao = "Pedido: " + c-nr-pedcli + " Item: " + 
                            c-it-codigo
             l-movto-com-erro = yes.
      run gera-log. 
      return. */

       CREATE tt-item.
       ASSIGN tt-item.it-codigo = item.it-codigo.
      
   end.     
   if avail item and not item.ind-item-fat then do:
      assign i-erro = 11
             c-informacao = "Pedido: " + c-nr-pedcli + " Item: " + 
                            c-it-codigo
             l-movto-com-erro = yes.
      run gera-log. 
      return.
   end.     
   if dec(tt-it-nfe.quantidade) <= 0 then do:
      assign i-erro = 12
             c-informacao = "Pedido: " + c-nr-pedcli + " Item: " + 
                            c-it-codigo + " Qtde.: " + string(de-quantidade)
             l-movto-com-erro = yes.
      run gera-log. 
      return.
   end.
     
   /* determina natureza de operacao */
   run intprg/int015a.p ( input c-tp-pedido     ,
                          input c-uf-destino    ,
                          input c-uf-destino    ,
                          input c-cod-estabel   ,
                          input i-cod-emitente  ,
                          input c-class-fiscal  ,
                          input i-cst-icms      ,
                          output c-natur-ent    , 
                          output i-cod-cond-pag , 
                          output i-cod-portador ,
                          output i-modalidade   ,
                          output c-serie-ent    ,
                          output r-rowid,
                          OUTPUT c-natur).

   IF c-cod-estabel = "973" THEN
      ASSIGN c-serie-ent = "30".

   ASSIGN l-ind-icm-ret = no.
   
   for first natur-oper no-lock where
             natur-oper.nat-operacao = c-natur-ent: 

       if natur-oper.subs-trib then l-ind-icm-ret = yes.

   end.

   if not avail natur-oper 
   then do:
       assign i-erro = 21
              c-informacao = "Pedido: " + c-nr-pedcli + " Tipo: " + 
                             string(C-TP-PEDIDO) + " Natur. Oper.: " + c-natur-ent + 
                             " UF Destino: " + 
                             c-uf-destino + " UF Origem: " + 
                             c-uf-origem + " Estab.: " + 
                             C-COD-ESTABEL + " Emitente: " + 
                             STRING(I-COD-EMITENTE) + " NCM: " +
                             C-CLASS-FISCAL
              l-movto-com-erro = yes.
       run gera-log. 
       return.
   end.

/*    MESSAGE "entrada"               SKIP            */
/*            c-tp-pedido             SKIP            */
/*            natur-oper.nat-operacao SKIP            */
/*            c-natur-ent             SKIP            */
/*            natur-oper.nat-ativa VIEW-AS ALERT-BOX. */
         
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
                          c-natur-ent + " Esp. Doc.: " + natur-oper.especie-doc
           l-movto-com-erro = yes.
       run gera-log. 
       return.
   end.
   if avail natur-oper and 
      natur-oper.especie-doc <> "NFD" then do:
       assign i-erro = 34
              c-informacao = "Pedido: " + c-nr-pedcli + " Natur. Oper.: " + 
                             c-natur-ent + " Esp. Doc.: " + natur-oper.especie-doc
           l-movto-com-erro = yes.
       run gera-log. 
       return.
   end.
   if avail natur-oper and 
            natur-oper.imp-nota = NO     
    then do:
       assign i-erro = 43
              c-informacao = "Pedido: " + c-nr-pedcli + " Natur. Oper.: " + 
                             c-natur-ent + " Esp. Doc.: " + natur-oper.especie-doc
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
               c-informacao = "Pedido: " + c-nr-pedcli + " Estabel: " + c-cod-estabel + " Item: " + c-it-codigo 
               l-movto-com-erro = yes.
        run gera-log. 
        return.
   end.

      
END PROCEDURE.

PROCEDURE pi-cria-tt-docum-est:
   
   run pi-acompanhar in h-acomp (input "Criando Nota de Entrada :" + SUBSTRING(string(tt-nfe.ped-codigo-n),2,6)).
    
   FIND FIRST param-estoq NO-LOCK NO-ERROR.

   FOR EACH tt-nfe NO-LOCK WHERE
            tt-nfe.ped-codigo-n = int-ds-pedido.ped-codigo-n:

        CREATE tt-nota-ent.
        ASSIGN tt-nota-ent.nro-docto    =  SUBSTRING(string(tt-nfe.ped-codigo-n),4,6) + STRING(tt-nfe.nro-docto,"99")  
               tt-nota-ent.serie-nota   = c-serie-ent
               tt-nota-ent.serie-docum  = c-serie-ent
               tt-nota-ent.nat-operacao = c-natur-ent                                   
               tt-nota-ent.cod-emitente = i-cod-emitente 
               tt-nota-ent.tipo-nota    = 1
               tt-nota-ent.situacao     = 2.
        
        FIND FIRST emitente NO-LOCK WHERE
                   emitente.cod-emitente = i-cod-emitente NO-ERROR.
        
        FIND FIRST natur-oper WHERE 
                   natur-oper.nat-operacao = c-natur-ent NO-ERROR.
                                                            
        find first estab-mat no-lock where
                   estab-mat.cod-estabel = c-cod-estabel NO-ERROR.

        CREATE tt-docum-est-ent.
        assign tt-docum-est-ent.registro     = 2
               tt-docum-est-ent.nro-docto    = tt-nota-ent.nro-docto
               tt-docum-est-ent.cod-emitente = tt-nota-ent.cod-emitente
               tt-docum-est-ent.serie-docto  = tt-nota-ent.serie-nota 
               tt-docum-est-ent.nat-operacao = c-natur-ent                              
               tt-docum-est-ent.cod-observa  = natur-oper.tipo-compra
               tt-docum-est-ent.cod-estabel  = c-cod-estabel
               tt-docum-est-ent.estab-fisc   = c-cod-estabel
               tt-docum-est-ent.usuario      = c-seg-usuario
               tt-docum-est-ent.uf           = emitente.estado 
               tt-docum-est-ent.via-transp   = 1
               tt-docum-est-ent.dt-emis      = TODAY   
               tt-docum-est-ent.dt-trans     = TODAY                          
               tt-docum-est-ent.nff          = no                              
               tt-docum-est-ent.observacao   = "Pedido Balan‡o : " + string(tt-nfe.ped-codigo-n) 
               tt-docum-est-ent.valor-mercad = 0 
               tt-docum-est-ent.tot-valor    = 0
               tt-docum-est-ent.ct-transit   = IF AVAIL estab-mat THEN estab-mat.cod-cta-fornec-unif ELSE ""
               tt-docum-est-ent.sc-transit   = "" 
               OVERLAY(tt-docum-est-ent.char-1,93,60)  = ""
               OVERLAY(tt-docum-est-ent.char-1,192,16) = "" /* Aviso de recolhimento */     
               tt-docum-est-ent.esp-docto     = 20.
     
     RELEASE tt-docum-est-ent.

     FOR FIRST tt-docum-est-ent where
               tt-docum-est-ent.nro-docto = tt-nota-ent.nro-docto :

     end.   
     
     ASSIGN i-seq-item = 0.
       
     FOR EACH tt-it-nfe WHERE
              tt-it-nfe.nro-docto    = tt-nfe.nro-docto AND
              tt-it-nfe.ped-codigo-n = tt-nfe.ped-codigo-n :
              
                 for first item no-lock where 
                           item.it-codigo = tt-it-nfe.it-codigo: 
                 end.

                 ASSIGN i-seq-item = i-seq-item + 10.

                 /* determina natureza de operacao */
                 run intprg/int015a.p ( input c-tp-pedido     ,
                                        input c-uf-destino    ,
                                        input c-uf-destino     ,
                                        input c-cod-estabel   ,
                                        input i-cod-emitente  ,
                                        input ITEM.class-fiscal ,
                                        input i-cst-icms      ,
                                        output c-natur-ent    , 
                                        output i-cod-cond-pag , 
                                        output i-cod-portador ,
                                        output i-modalidade   ,
                                        output c-serie-ent    ,
                                        output r-rowid,
                                        OUTPUT c-natur).
                 
                 IF c-cod-estabel = "973" THEN
                    ASSIGN c-serie-ent = "30".

                 CREATE tt-item-doc-est-ent.
                 ASSIGN tt-item-doc-est-ent.registro       = 3
                        tt-item-doc-est-ent.serie-docto    = tt-docum-est-ent.serie-docto
                        tt-item-doc-est-ent.nro-docto      = tt-nota-ent.nro-docto
                        tt-item-doc-est-ent.cod-emitente   = tt-nota-ent.cod-emitente
                        tt-item-doc-est-ent.nat-operacao   = c-natur-ent
                        tt-item-doc-est-ent.sequencia      = i-seq-item
                        tt-item-doc-est-ent.it-codigo      = tt-it-nfe.it-codigo
                        tt-item-doc-est-ent.lote           = if item.tipo-con-est = 3 /* lote */ then c-numero-lote else ""
                        tt-item-doc-est-ent.num-pedido     = 0    
                        tt-item-doc-est-ent.numero-ordem   = 0
                        tt-item-doc-est-ent.parcela        = 0.
                 
                 FIND FIRST item-uni-estab NO-LOCK WHERE
                            item-uni-estab.cod-estabel = c-cod-estabel AND
                            item-uni-estab.it-codigo   = tt-it-nfe.it-codigo NO-ERROR.
                 IF AVAIL item-uni-estab THEN
                    ASSIGN c-cod-depos = item-uni-estab.deposito-pad.
                 ELSE 
                    ASSIGN c-cod-depos = item.deposito-pad.

                 IF c-cod-depos = "" THEN
                    ASSIGN c-cod-depos = "LOJ". 
                   
                 assign tt-item-doc-est-ent.encerra-pa     = no
                        tt-item-doc-est-ent.nr-ord-prod    = 0
                        tt-item-doc-est-ent.cod-roteiro    = ""
                        tt-item-doc-est-ent.op-codigo      = 0
                        tt-item-doc-est-ent.item-pai       = ""
                        tt-item-doc-est-ent.baixa-ce       = YES 
                        tt-item-doc-est-ent.quantidade     = tt-it-nfe.quantidade
                        tt-item-doc-est-ent.qt-do-forn     = tt-it-nfe.quantidade
                        tt-item-doc-est-ent.preco-unit-me  = tt-it-nfe.vl-uni
                        tt-item-doc-est-ent.preco-unit     = tt-it-nfe.vl-uni
                        tt-item-doc-est-ent.cod-depos      = c-cod-depos
                        tt-item-doc-est-ent.class-fiscal   = item.class-fiscal
                        tt-item-doc-est-ent.preco-total    = tt-item-doc-est-ent.preco-unit-me * tt-item-doc-est-ent.quantidade
                        tt-item-doc-est-ent.serie-comp     = tt-it-nfe.serie-comp
                        tt-item-doc-est-ent.nro-comp       = tt-it-nfe.nro-comp
                        tt-item-doc-est-ent.seq-comp       = tt-it-nfe.seq-comp.
                        
                  
                  FOR FIRST nota-fiscal NO-LOCK WHERE
                            nota-fiscal.cod-estabel  = c-cod-estabel      AND
                            nota-fiscal.nr-nota-fis  = tt-it-nfe.nro-comp AND 
                            nota-fiscal.serie        = tt-it-nfe.serie-comp,
                     FIRST it-nota-fisc OF nota-fiscal NO-LOCK WHERE
                           it-nota-fisc.it-codigo  = tt-it-nfe.it-codigo :
                                                      
                      ASSIGN tt-item-doc-est-ent.nat-comp = it-nota-fisc.nat-operacao
                             tt-item-doc-est-ent.seq-comp = it-nota-fisc.nr-seq-fat. 
                                                      
                  END.

                 IF ITEM.tipo-contr = 4 THEN DO:
                    IF AVAIL item-uni-estab THEN
                       ASSIGN tt-item-doc-est-ent.ct-codigo      = item-uni-estab.ct-codigo
                              tt-item-doc-est-ent.sc-codigo      = item-uni-estab.sc-codigo.
                    ELSE 
                       ASSIGN tt-item-doc-est-ent.ct-codigo      = ITEM.ct-codigo                                
                              tt-item-doc-est-ent.sc-codigo      = item.sc-codigo. 
                 END.
                 
                 ASSIGN tt-docum-est-ent.valor-mercad = tt-docum-est-ent.valor-mercad + tt-item-doc-est-ent.preco-total 
                        tt-docum-est-ent.tot-valor    = tt-docum-est-ent.tot-valor    + tt-item-doc-est-ent.preco-total. 

     END.

     FOR EACH int-ds-doc-erro WHERE
              int-ds-doc-erro.serie-docto  = tt-nota-ent.serie-nota   AND 
              int-ds-doc-erro.cod-emitente = tt-nota-ent.cod-emitente AND
              int-ds-doc-erro.nro-docto    = tt-nota-ent.nro-docto    AND
              int-ds-doc-erro.tipo-nota    = tt-nota-ent.tipo-nota   :
          
            DELETE int-ds-doc-erro.

     END.

   END.

END PROCEDURE.

procedure emite-nota-entrada:

    DEF VAR l-nota-entrada AS LOGICAL NO-UNDO. 
                              
    run pi-acompanhar in h-acomp (input "Gerando Nota Entrada ").
              
         ASSIGN l-movto-entrada-erro = NO.
          
         FOR EACH tt-nota-ent:
                
                   ASSIGN l-nota-entrada = NO.
                 
                   EMPTY TEMP-TABLE tt-nota.
                   EMPTY TEMP-TABLE tt-docum-est-nova.
                   EMPTY TEMP-TABLE tt-item-doc-est-nova.
                                 
                   FOR FIRST tt-docum-est-ent WHERE
                             tt-docum-est-ent.nro-docto = tt-nota-ent.nro-docto:

                   END.

                   FOR FIRST nota-fiscal NO-LOCK WHERE
                             nota-fiscal.cod-estabel      = tt-docum-est-ent.cod-estabel       AND 
                             nota-fiscal.serie            = tt-docum-est-ent.serie             AND
                             nota-fiscal.nr-pedcli        = STRING(int-ds-pedido.ped-codigo-n) AND 
                             nota-fiscal.nro-nota-orig    = tt-docum-est-ent.nro-docto         AND 
                             nota-fiscal.dt-cancel        = ? ,
                       FIRST natur-oper NO-LOCK WHERE
                             natur-oper.nat-operacao = nota-fiscal.nat-operacao AND 
                             natur-oper.tipo         = 1 : /* Entrada */  

                       ASSIGN l-nota-entrada = YES.
                             
                    END.      

                    IF l-nota-entrada THEN NEXT.

                    CREATE tt-nota.
                    BUFFER-COPY tt-nota-ent TO tt-nota.

                    FOR EACH tt-docum-est-ent WHERE
                             tt-docum-est-ent.nro-docto = tt-nota-ent.nro-docto:

                        CREATE tt-docum-est-nova.
                        BUFFER-COPY tt-docum-est-ent TO tt-docum-est-nova.

                        FOR FIRST ser-estab NO-LOCK WHERE
                                  ser-estab.serie       = tt-docum-est-nova.serie AND 
                                  ser-estab.cod-estabel = tt-docum-est-nova.cod-estabel:
                        END.

                        IF AVAIL ser-estab THEN DO:
                       
                          ASSIGN tt-docum-est-nova.nro-docto = string(INT(ser-estab.nr-ult-nota) + 1,"9999999").  

                          FOR LAST docum-est NO-LOCK WHERE
                                   docum-est.cod-emitente = tt-docum-est-nova.cod-emitente AND 
                                   docum-est.serie        = tt-docum-est-nova.serie        AND 
                                   docum-est.nro-docto    = tt-docum-est-nova.nro-docto    AND 
                                   docum-est.nat-operacao <> "":
                          END.

                          IF AVAIL docum-est 
                          THEN DO:
                              FOR LAST docum-est NO-LOCK WHERE
                                       docum-est.cod-emitente > 0  AND 
                                       docum-est.serie        = tt-docum-est-nova.serie AND 
                                       int(docum-est.nro-docto) > 0 AND 
                                       docum-est.nat-operacao <> "":
                                   
                                ASSIGN tt-docum-est-nova.nro-docto = string(INT(docum-est.nro-docto) + 1,"9999999").

                              END.

                          END.

                       END.
                    END.
                         
                    FIND FIRST tt-docum-est-nova NO-ERROR.

                    FOR EACH tt-item-doc-est-ent WHERE
                             tt-item-doc-est-ent.nro-docto = tt-nota-ent.nro-docto :

                        CREATE tt-item-doc-est-nova.
                        BUFFER-COPY tt-item-doc-est-ent TO tt-item-doc-est-nova.

                        ASSIGN  tt-item-doc-est-nova.nro-docto = tt-docum-est-nova.nro-docto.
                       
                    END. 
                          
                    /* DISP STREAM str-rp tt-nota.nro-docto      
                           tt-nota.serie-nota    
                           tt-nota.tipo-nota     
                           tt-nota.nat-operacao  
                           tt-nota.cod-emitente WITH WIDTH 333 STREAM-IO.

                    FOR EACH tt-item-doc-est:

                        DISP STREAM str-rp 
                             tt-item-doc-est.nro-docto
                             tt-item-doc-est.it-codigo
                             tt-item-doc-est.sequencia
                             WITH WIDTH 333 STREAM-IO.
                               
                    END. */

                    FIND FIRST docum-est NO-LOCK WHERE
                               docum-est.nro-docto    =  tt-docum-est-nova.nro-docto    AND
                               docum-est.serie        =  tt-docum-est-nova.serie        AND
                               docum-est.nat-operacao =  tt-docum-est-nova.nat-operacao AND
                               docum-est.cod-emitente =  tt-docum-est-nova.cod-emitente NO-ERROR.
                    IF NOT AVAIL docum-est 
                    THEN DO: 
                                  
                        /* 
                          RUN intprg/int002e.p(INPUT TABLE tt-nota,
                                               INPUT TABLE tt-docum-est,
                                               INPUT TABLE tt-item-doc-est).  
                          */

                         EMPTY TEMP-TABLE tt-erro.
                         EMPTY TEMP-TABLE tt-versao-integr.

                         create tt-versao-integr.
                         assign tt-versao-integr.registro              = 1
                                tt-versao-integr.cod-versao-integracao = 004.

                         run rep/reapi190b.p persistent set h-api.
                         run execute in h-api (input  table tt-versao-integr,
                                               input  table tt-docum-est-nova,
                                               input  table tt-item-doc-est-nova,
                                               input  table tt-dupli-apagar,
                                               input  table tt-dupli-imp,
                                               input  table tt-unid-neg-nota,
                                               output table tt-erro).
                         if valid-handle(h-api) then delete procedure h-api no-error.

                         find first tt-erro no-error.
                         if avail tt-erro 
                         then do:

                            FOR EACH tt-erro WHERE
                                     tt-erro.cd-erro <> 6506 :
                                                   
                                 assign i-erro = 22 
                                        c-informacao = "Estab.: " + c-cod-estabel + " - " + "Pedido: " + c-nr-pedcli + " - " 
                                                     + "Natur. Oper.: " + c-natur-ent + " - " + 
                                                       "Cod. Erro: " + string(tt-erro.cd-erro) + " - " + 
                                                       tt-erro.mensagem.

                                    ASSIGN l-movto-com-erro = YES.
                                      
                                 run gera-log.

                            END.

                         END.  
                        
                    END.
            
                    IF l-movto-com-erro = NO 
                    THEN DO:
                    
                       FIND FIRST tt-docum-est-ent NO-ERROR.
                       FIND FIRST tt-docum-est-nova NO-ERROR. 
                       
                       FIND FIRST docum-est NO-LOCK WHERE
                                  int(docum-est.nro-docto) =  int(tt-docum-est-nova.nro-docto) AND
                                  docum-est.serie          =  tt-docum-est-nova.serie        AND
                                  docum-est.nat-operacao   =  tt-docum-est-nova.nat-operacao AND
                                  docum-est.cod-emitente   =  tt-docum-est-nova.cod-emitente NO-ERROR.
                       IF AVAIL docum-est 
                       THEN DO:

                           IF docum-est.ce-atual = NO 
                           THEN DO:

                                /* RUN pi-atualizaDocumento. */

                               /**** Usar como valida»’o para gera»’o das notas nÆo esquecer do dt-cancel ***/

                               FOR FIRST nota-fiscal WHERE
                                         nota-fiscal.cod-estabel      = docum-est.cod-estabel AND 
                                         nota-fiscal.serie            = docum-est.serie       AND
                                         INT(nota-fiscal.nr-nota-fis) = INT(docum-est.nro-docto),
                                  FIRST natur-oper NO-LOCK WHERE
                                        natur-oper.nat-operacao = nota-fiscal.nat-operacao AND 
                                        natur-oper.tipo         = 1 : /* Entrada */  

                                   ASSIGN nota-fiscal.nr-pedcli     = STRING(int-ds-pedido.ped-codigo-n)
                                          nota-fiscal.nro-nota-orig = tt-docum-est-ent.nro-docto.

                               END.

                           END.
            
                       END.
            
                    END. /* l-movto com erro */

         END. /* each tt-nota */

END.

procedure gera-log-final:

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
   RUN intprg/int999.p ("NF Retorno", 
                        c-nr-pedcli,
                        (trim(tb-erro[i-erro]) + " - " + c-informacao),
                        b-int-ds-pedido.situacao, /* 1 - Pendente, 2 - Processado */ 
                        c-seg-usuario).
   assign c-informacao = " ".
end.

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

   RUN intprg/int999.p ("NF Retorno", 
                        c-nr-pedcli,
                        (trim(tb-erro[i-erro]) + " - " + c-informacao),
                        int-ds-pedido.situacao, /* 1 - Pendente, 2 - Processado */ 
                        c-seg-usuario).
   assign c-informacao = " ".
end.


{intprg/int038.i}  /* Atualiza documento */


procedure pi-calcula-preco:
                   
    /* 
    if de-vl-uni = 0
    then do:

       /* Pre‡o M‚dio */
       for first item-estab no-lock where 
                 item-estab.it-codigo   = c-it-codigo and
                 item-estab.cod-estabel = c-cod-estabel:
   
           assign de-vl-uni = item-estab.val-unit-mat-m[1] +
                              item-estab.val-unit-ggf-m[1] +
                              item-estab.val-unit-mob-m[1].
        end.  
        
    end.   
   
    if de-vl-uni = 0
    then do:
                                                            
       for first item-uni-estab  no-lock where 
                 item-uni-estab.cod-estabel = c-cod-estabel AND  
                 item-uni-estab.it-codigo   = c-it-codigo:                 
   
           assign de-vl-uni = item-uni-estab.preco-base.  /* Pre‡o base */

           IF de-vl-uni = 0 THEN
              assign de-vl-uni = item-uni-estab.preco-ul-ent. /* Pre‡o Ult Entrada */ 
       end.      
          
    end.
    */

    if de-vl-uni = 0
    then do:
                                                            
       for first item-uni-estab  no-lock where 
                 item-uni-estab.cod-estabel = "973" AND  
                 item-uni-estab.it-codigo   = c-it-codigo:                 
   
           assign de-vl-uni = item-uni-estab.preco-base.  /* Pre‡o base */

           /* IF de-vl-uni = 0 THEN
              assign de-vl-uni = item-uni-estab.preco-ul-ent. /* Pre‡o Ult Entrada */ 
              */

       end.      
          
    end.
  
end procedure.

PROCEDURE pi-altera-item:
DEF INPUT PARAMETER p-tipo AS INTEGER.

  DISABLE TRIGGERS FOR LOAD OF b-item.
  DISABLE TRIGGERS FOR LOAD OF item-uni-estab.

  FOR EACH tt-item: 
        
         FOR FIRST b-item WHERE
                   b-item.it-codigo = STRING(tt-item.it-codigo):
             
             ASSIGN b-item.cod-obsoleto = p-tipo. /* Obsoleto Ordens Autom ticas */
             
         END.
    
         RELEASE b-item.
        
         for first item-uni-estab fields(cod-estabel it-codigo cod-obsoleto) where 
                   item-uni-estab.cod-estabel = c-cod-estabel and 
                   item-uni-estab.it-codigo   = tt-item.it-codigo: 
         end.
    
         if avail item-uni-estab       
         THEN DO:
             ASSIGN item-uni-estab.cod-obsoleto = p-tipo.  /* Obsoleto Ordens Autom ticas */
         END.
    
         RELEASE item-uni-estab.

  END.

END PROCEDURE.
     
/* FIM DO PROGRAMA */








