/********************************************************************************
** Programa: INT117 - Gera‡Æo notas fiscais a partir de Pedidos do Tutorial/PRS
**
** Versao : 12 - 05/03/2016 - Alessandro V Baccin
**
********************************************************************************/
/* include de controle de versao */
{include/i-prgvrs.i INT117RP 2.12.01.AVB}

/* definiçao das temp-tables para recebimento de parametros */
define temp-table tt-param no-undo
    field destino          as integer
    field arquivo          as char format "x(35)"
    field usuario          as char format "x(12)"
    field data-exec        as date
    field hora-exec        as integer
    field classifica       as integer
    field desc-classifica  as char format "x(40)"
    FIELD tipo-pedido      AS CHAR FORMAT "x(03)"
    FIELD nr-pedido        AS CHAR FORMAT "x(20)"
    FIELD tp-todos-ped     AS LOG.

def temp-table tt-raw-digita
        field raw-digita	as raw.

DEFINE BUFFER b-int_ds_pedido FOR int_ds_pedido .

def temp-table tt-ped-venda-prs         like ped-venda.
def temp-table tt-ped-item-prs          like ped-item
    field numero-caixa like cst_ped_item.numero_caixa
    field numero-lote  like cst_ped_item.numero_lote
    field nr-docum     like docum-est.nro-docto
    field serie-docum  like docum-est.serie-docto
    field nat-docum    like docum-est.nat-operacao
    field seq-docum    like item-doc-est.sequencia.

DEF TEMP-TABLE tt-nota-origem 
    field nome-abrev     LIKE ped-venda.nome-abrev
    field nr-pedcli      LIKE ped-venda.nr-pedcli
    field nro-docto      LIKE int_ds_docto_xml.nnf  
    field serie          LIKE int_ds_docto_xml.serie       
    field tipo-nota      LIKE int_ds_docto_xml.tipo_nota   
    field nat-operacao   LIKE int_ds_docto_xml.nat_operacao
    field cod-emitente   LIKE int_ds_docto_xml.cod_emitente.

DEF TEMP-TABLE tt-nota no-undo
    FIELD situacao     AS INTEGER
    FIELD nro-docto    LIKE docum-est.nro-docto   
    FIELD serie-nota   LIKE docum-est.serie-docto
    FIELD serie-docum  LIKE docum-est.serie-docto        
    FIELD cod-emitente LIKE docum-est.cod-emitente
    FIELD nat-operacao LIKE docum-est.nat-operacao
    FIELD tipo-nota    LIKE int_ds_docto_xml.tipo_nota
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

{inbo/boin090.i tt-docum-est}       /* Defini¯Êo TT-DOCUM-EST       */
{inbo/boin176.i tt-item-doc-est}    /* Defini¯Êo TT-ITEM-DOC-EST    */

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

{dibo/bodi317sd.i1}

/* temp-tables das API's e BO's */
{method/dbotterr.i}

/* recebimento de parametros */
def input parameter raw-param as raw no-undo.
def input parameter table for tt-raw-digita.  

create tt-param.                    
raw-transfer raw-param to tt-param no-error.
IF tt-param.arquivo = "" THEN 
    ASSIGN tt-param.arquivo = "INT117.txt"
           tt-param.destino = 3
           tt-param.data-exec = TODAY
           tt-param.hora-exec = TIME.

/* include padrao para variáveis de relatório  */
{include/i-rpvar.i}

/* ++++++++++++++++++ (Definicao Stream) ++++++++++++++++++ */

/* ++++++++++++++++++ (Definicao Buffer) ++++++++++++++++++ */
define buffer bcomponente for componente.
define buffer bemitente for emitente.
define buffer btransporte for transporte.
DEFINE BUFFER bint_ds_pedido FOR int_ds_pedido.



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

DEF VAR i-pos-arq            AS INTEGER                   NO-UNDO.
DEF VAR c-nr-nota            AS CHAR FORMAT "x(07)"       NO-UNDO.
DEF VAR c-linha              AS CHAR.
DEF VAR c-cod-depos          AS CHAR.
DEF VAR c-nat-docum          AS CHAR NO-UNDO.

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
def var de-vl-uni            as dec format "999.999".
def var de-desconto          as decimal no-undo.
def var i-tab-finan          as integer.
def var i-indice             as integer.
def var c-nome-transp        like transporte.nome-abrev.
def var de-aliquota-ipi      as decimal.
def var de-preco             LIKE ems2dis.preco-item.preco-venda.
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
def var l-movto-com-erro     as logical init no no-undo.
def var d-dt-emissao         as date.
def var d-dt-entrega         as date.
def var d-dt-implantacao     as date.
def var i-nr-sequencia       as integer.
def var c-nome-repres        as character.
def var c-placa              as character.
def var c-uf-placa           as character.
def var c-numero-caixa       as character.
def var c-numero-lote        as character.
def var c-tp_pedido          as character.
def var c-docto-orig         as character.
def var c-obs-gerada         as character.
def var tb-erro              as char format "x(50)" extent 39 init
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
                              "28. Nat de Operacao de Devolucao exige nota origem",
                              "29. Nota Origem Informada e Nat. Oper. Envio      ",
                              "30. Estabelecimento nao Cadastrado/Fora de Oper.  ",
                              "31. Canal de vendas nao Cadastrado                ",
                              "32. Nat.Operacao indicada esta Inativa            ",
                              "33. Saldo estoque insuficiente p/ envio do lote   ",
                              "34.                                               ",
                              "35. Tabela de Financiamento NAO Cadastrada        ",
                              "36. Pedido j  foi faturado                        ",
                              "37. Pedido inconsistente ou sem itens             ",
                              "38. Valor do item zerado                          ",
                              "39. Documento Pendente ou n’o cadastrado no int002"].

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
def var r-rowid         as rowid no-undo.
def var i-cst-icms      as integer no-undo.
def var d-dt-procfit        as date    no-undo.

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
assign c-programa       = "INT117RP"
       c-versao         = "2.12"
       c-revisao        = ".01.AVB"
       c-empresa        = "* Nao Definido *"
       c-sistema        = "Faturamento"
       c-titulo-relat   = "Gera‡Æo de Notas Fiscais - Pedidos - PRS".

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
RUN intprg/int888.p (INPUT "NF PED",
                     INPUT "INT117RP.P").

run pi-finalizar in h-acomp.

/* elimina BO's */

return "OK".

/* procedures */

procedure pi-elimina-tabelas.
   run pi-acompanhar in h-acomp (input "Eliminando Tabelas Temporarias").
   /* limpa temp-tables */
   empty temp-table tt-ped-venda-prs.
   empty temp-table tt-ped-item-prs. 
   empty temp-table RowErrors.   
   empty temp-table tt-envio2.
   empty temp-table tt-mensagem.
end.        

procedure pi-importa:
    run pi-acompanhar in h-acomp (input "Lendo Pedidos").
   
    for each int_ds_mod_pedido no-lock where 
        int_ds_mod_pedido.cod_prog_dtsul = "int117" OR
        int_ds_mod_pedido.cod_prog_dtsul = "int127" OR
        int_ds_mod_pedido.cod_prog_dtsul = "int137" OR
        int_ds_mod_pedido.cod_prog_dtsul = "int147",
        each int_ds_tipo_pedido no-lock where 
        int_ds_tipo_pedido.cod_mod_pedido = int_ds_mod_pedido.cod_mod_pedido AND
        int_ds_tipo_pedido.tp_pedido      = trim(string(tt-param.tipo-pedido)) and
        int_ds_tipo_pedido.log_ativo = yes
        query-tuning(no-lookahead):



    
        assign i-nr-registro    = 0.
        for each int_ds_pedido no-lock where
                 int_ds_pedido.situacao         = 1 and
                 int_ds_pedido.ped_codigo_n     = (if tt-param.tp-todos-ped = no 
                                                   then int(tt-param.nr-pedido) 
                                                   else int_ds_pedido.ped_codigo_n) and
                 int_ds_pedido.ped_tipopedido_n = int(int_ds_tipo_pedido.tp_pedido)
            :

            IF int_ds_pedido.ped_observacao_s =  ? THEN DO:
                FIND FIRST b-int_ds_pedido EXCLUSIVE-LOCK
                    WHERE ROWID(int_ds_pedido) = ROWID(b-int_ds_pedido) NO-ERROR.

                IF AVAIL b-int_ds_pedido  THEN
                    ASSIGN b-int_ds_pedido.ped_observacao_s = "".
                RELEASE b-int_ds_pedido.
            END.
            
            /*
            if  int_ds_pedido.ped_tipopedido_n = 1  or /* transf cd -> filial s¢ pedidos */
                int_ds_pedido.ped_tipopedido_n = 8  or /* ELETRONICO DEPOSITO - FILIAL */
                int_ds_pedido.ped_tipopedido_n = 20 or /* CD INT110 */
                int_ds_pedido.ped_tipopedido_n = 37 or /* CD INT110 */
                int_ds_pedido.ped_tipopedido_n = 2  or /* Retirada Lj->CD - Caixa */
                int_ds_pedido.ped_tipopedido_n = 48 OR   /* Substitiocao Cupom */
                int_ds_pedido.ped_tipopedido_n = 3  OR /* BALANCO MANUAL FILIAL */ 
                int_ds_pedido.ped_tipopedido_n = 11 OR /* BALANCO MANUAL DEPOSITO */
                int_ds_pedido.ped_tipopedido_n = 12 OR /* BALANCO COLETOR FILIAL */
                int_ds_pedido.ped_tipopedido_n = 13 OR /* BALANCO COLETOR DEPOSITO */
                int_ds_pedido.ped_tipopedido_n = 14 OR /* BALANCO MANUAL FILIAL - PERMITE CONSOLIDA€ÇO */
                int_ds_pedido.ped_tipopedido_n = 31 OR /* BALANCO MANUAL FILIAL - ESPECIAL (MED. CONTROLADO) */ 
                int_ds_pedido.ped_tipopedido_n = 35 OR /* BALAN€O GERAL CONTROLADOS DEPOSITO */
                int_ds_pedido.ped_tipopedido_n = 36 /* BALAN€O GERAL CONTROLADOS FILIAL */ 
                then next.
            */
            run pi-acompanhar in h-acomp (input "Lendo Pedido: " + string(int_ds_pedido.ped_codigo_n)).
            assign  l-movto-com-erro  = no
                    c-uf-destino      = ""
                    c-uf-origem       = "".
    
            assign  c-nr-pedcli         = trim(string(int_ds_pedido.ped_codigo_n))
                    d-dt-implantacao    = today
                    d-dt-entrega        = int_ds_pedido.ped_dataentrega_d
                    d-dt-emissao        = /*int_ds_pedido.ped-data-d*/ d-dt-implantacao
                    c-observacao        = SUBSTRING(int_ds_pedido.ped_observacao_s,1,500)
                    c-placa             = if int_ds_pedido.ped_placaveiculo_s <> ? then int_ds_pedido.ped_placaveiculo_s else ""
                    c-uf-placa          = if int_ds_pedido.ped_estadoveiculo_s <> ? then int_ds_pedido.ped_estadoveiculo_s else ""
                    c-tp_pedido         = trim(string(int_ds_pedido.ped_tipopedido_n))
                    c-docto-orig        = trim(string(int_ds_pedido.ped_codigo_n))
                    c-serie             = ""
                    .

            
            assign i-nr-registro = i-nr-registro + 1.
    
            /* processa pedido atual */
            run valida-registro-pedido.
    
            /* pedido de loja gerados no procfit */
            
            if int_ds_pedido.situacao <> 1 and (c-cod-estabel <> "973" OR c-cod-estabel <> "977") then next.
            
            

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
                    c-class-fiscal      = "".
                    
           
            if not l-movto-com-erro then
            for each int_ds_pedido_produto no-lock of int_ds_pedido,
                each int_ds_pedido_retorno of int_ds_pedido_produto
                query-tuning(no-lookahead)
                break by int_ds_pedido_retorno.ped_codigo_n
                      by int_ds_pedido_retorno.ppr_produto_n
                      by int_ds_pedido_retorno.rpp_lote_s:
                      
               
                if first-of (int_ds_pedido_retorno.rpp_lote_s) then de-quantidade = 0.
    
                assign  c-it-codigo         = trim(string(int_ds_pedido_produto.ppr_produto_n))
                        de-quantidade       = de-quantidade + int_ds_pedido_retorno.rpp_quantidade_n
                        de-vl-uni           = if ( int_ds_pedido.ped_tipopedido_n <> 10 
                                                and int_ds_pedido.ped_tipopedido_n <> 23
                                                and int_ds_pedido.ped_tipopedido_n <> 55
                                                and int_ds_pedido.ped_tipopedido_n <> 88 )
                                              then int_ds_pedido_produto.ppr_valorbruto_n
                                              else int_ds_pedido_produto.ppr_valorliquido_n
                        de-desconto         = int_ds_pedido_produto.ppr_percentualdesconto_n
                        c-numero-caixa      = (if c-numero-caixa = ""
                                               then string(int_ds_pedido_retorno.rpp_caixa_n)
                                               else c-numero-caixa + "," + string(int_ds_pedido_retorno.rpp_caixa_n))
                        c-numero-lote       = if trim(int_ds_pedido_retorno.rpp_lote_s) <> "0" and 
                                                 trim(int_ds_pedido_retorno.rpp_lote_s) <> "?" and
                                                 trim(int_ds_pedido_retorno.rpp_lote_s) <> ? then trim(int_ds_pedido_retorno.rpp_lote_s) else ""
                        c-nr-docum          = if int_ds_pedido_produto.nen_notafiscal_n <> ? and
                                                 int_ds_pedido_produto.nen_notafiscal_n <> 0 and
                                                 int_ds_pedido.ped_tipopedido_n <> 33 
                                                 then trim(string(int_ds_pedido_produto.nen_notafiscal_n,">>9999999")) else ""
                        c-serie-docum       = if int_ds_pedido_produto.nen_serie_s <> ? and int_ds_pedido.ped_tipopedido_n <> 33 then int_ds_pedido_produto.nen_serie_s else ""
    
                        i-seq-docum         = if int_ds_pedido_produto.nep_sequencia_n <> ? and int_ds_pedido.ped_tipopedido_n <> 33 
                                              then int_ds_pedido_produto.nep_sequencia_n else 0.
    
                run valida-registro-item. 
                
               
                if l-movto-com-erro then next.
                
                find first tt-ped-venda-prs use-index ch-pedido where 
                    tt-ped-venda-prs.nome-abrev = c-nome-abrev and
                    tt-ped-venda-prs.nr-pedcli  = c-nr-pedcli no-error.
                if not avail tt-ped-venda-prs then do:
                    run cria-tt-ped-venda-prs.
                    assign i-nr-sequencia = 0.
                end.
                if last-of(int_ds_pedido_retorno.rpp_lote_s) then run cria-tt-ped-item-prs.
            end.
            for first tt-ped-item-prs: end.
            if not l-movto-com-erro and not avail tt-ped-item-prs then do:
                assign i-erro = 37
                       c-informacao = "Pedido: " + c-nr-pedcli + " CNPJ Origem: " + string(int_ds_pedido.ped_cnpj_origem)
                       l-movto-com-erro = yes.
                run gera-log. 
            end.
            run finaliza-pedido.
        end. /* int_ds_pedido */
    end. /* int_ds_mod_pedido */
end.

procedure finaliza-pedido.
   DEF VAR c-aux AS CHAR NO-UNDO.
   run pi-acompanhar in h-acomp (input "Finalizando Pedido").
   
   if not l-movto-com-erro then 
   do:
     /*   run utp/ut-msgs.p (input 'show',
                           input 27100,
                           input 'Confirma emissao da nota fiscal ?' + 'Pedido ' + c-nr-pedcli ).
        IF return-value = 'yes':u THEN
        DO:*/
            run emite-nota.
            if not l-movto-com-erro then do:
               c-aux = "".
               FOR LAST tt-notas-geradas:
                   FOR nota-fiscal NO-LOCK WHERE ROWID(nota-fiscal) = tt-notas-geradas.rw-nota-fiscal:
                      c-aux = " Estab.: " + nota-fiscal.cod-estabel + "/" + "S‚rie: " + nota-fiscal.serie + "/" + "NF: " + nota-fiscal.nr-nota-fis.
                   END.
               END.
               assign i-erro       = 1
                      c-informacao = "Pedido: " +  c-nr-pedcli
                                   + " Nome Abrev.: "
                                   + c-nome-abrev 
                                   + c-aux.
                                   
               find current int_ds_pedido exclusive-lock no-wait no-error.
               if avail int_ds_pedido then
                   assign int_ds_pedido.situacao = 2 /* integrado */.
               run gera-log.
               release int_ds_pedido.
            end.
        /*END. */
   end.
   run pi-elimina-tabelas.
end.

procedure valida-registro-pedido.
    
    run pi-acompanhar in h-acomp (input "Validando Pedido").
    
    assign c-cod-estabel = ""
           d-dt-procfit  = ?.
    for each estabelec 
        fields (cod-estabel estado cidade serie
                cep pais endereco bairro ep-codigo) 
        no-lock where
        estabelec.cgc = int_ds_pedido.ped_cnpj_origem_s,
        first cst_estabelec no-lock where 
        cst_estabelec.cod_estabel = estabelec.cod-estabel and
        cst_estabelec.dt_fim_operacao >= d-dt-emissao:
        assign c-cod-estabel = estabelec.cod-estabel
               c-uf-origem   = estabelec.estado
               c-serie       = estabelec.serie
               d-dt-procfit  = cst_estabelec.dt_inicio_oper.
        leave.
    end.
    if c-cod-estabel = "" then
    do:
       assign i-erro = 30
              c-informacao = "Pedido: " + c-nr-pedcli + " CNPJ Origem: " + string(int_ds_pedido.ped_cnpj_origem)
              l-movto-com-erro = yes.
       run gera-log. 
       return.
    end.

    /* estabelecimento ‹Procfit - Notas emitidas pelo Procfit */
    IF (c-cod-estabel <>  "973" OR c-cod-estabel <> "977") and d-dt-procfit <> ? and
        d-dt-emissao <= d-dt-procfit  then do:
        
        assign l-movto-com-erro = yes.
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
                 c-informacao = "Pedido: " + c-nr-pedcli + " Emitente:" + string(i-cod-emitente)
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

    for first nota-fiscal  no-lock where
        nota-fiscal.nr-pedcli = string(c-nr-pedcli) AND 
        nota-fiscal.nome-ab-cli = c-nome-abrev:
        if nota-fiscal.dt-cancel = ? then do:

            assign i-erro = 36
                   c-informacao = "Pedido: " + c-nr-pedcli + " CNPJ Origem: " + string(int_ds_pedido.ped_cnpj_origem) + " Estab.: " + 
                                  c-cod-estabel + " S‚rie: " + nota-fiscal.serie + " NF: " + nota-fiscal.nr-nota-fis
                   l-movto-com-erro = yes.
            find current int_ds_pedido exclusive-lock no-wait no-error.
            if avail int_ds_pedido then
                assign int_ds_pedido.situacao = 2 /* integrado */.
            run gera-log. 
            return.
        end.
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
             c-informacao = "Pedido: " + c-nr-pedcli + " Tab. Finan.: " + 
                            string(i-tab-finan)
             l-movto-com-erro = yes.
      run gera-log. 
      return.
    end.                     
    
    
    if i-canal-vendas <> 0 then
    do:
       find first ems2dis.canal-venda no-lock where
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

end.
      
procedure valida-registro-item.

   run pi-acompanhar in h-acomp (input "Validando Itens").
   for first item where
        item.it-codigo = c-it-codigo:
        c-class-fiscal = item.class-fiscal.
   end.
   if not avail item then do:
      assign i-erro = 9
             c-informacao = "Pedido: " + c-nr-pedcli + " Item: " + 
                            c-it-codigo 
             l-movto-com-erro = yes.
      run gera-log. 
      return.

   end.
   if avail item and item.cod-obsoleto = 4 then do:
      assign i-erro = 10
             c-informacao = "Pedido: " + c-nr-pedcli + " Item: " + 
                            c-it-codigo
             l-movto-com-erro = yes.
      run gera-log. 
      return.
   end.     
   if avail item and not item.ind-item-fat then do:
      assign i-erro = 11
             c-informacao = "Pedido: " + c-nr-pedcli + " Item: " + 
                            c-it-codigo
             l-movto-com-erro = yes.
      run gera-log. 
      return.
   end.     
   if dec(de-quantidade) <= 0 then do:
      assign i-erro = 12
             c-informacao = "Pedido: " + c-nr-pedcli + " Item: " + 
                            c-it-codigo + " Qtde.: " + 
                            string(de-quantidade)
             l-movto-com-erro = yes.
      run gera-log. 
      return.
   end. 
   
   i-cst-icms = 0.
   c-nat-docum = "".
   if trim(c-nr-docum) <> "" and c-tp_pedido <> "48"
   then do:  /* Nota de origem de uma devolu»’o no Sysfarma */

       FIND FIRST int_ds_ext_emitente NO-LOCK WHERE
                  int_ds_ext_emitente.cod_emitente = i-cod-emitente NO-ERROR. 
       IF AVAIL int_ds_ext_emitente AND 
                int_ds_ext_emitente.gera_nota = YES  /* Quando for Pepsico Verifica se a nota estÿ pendente de atualiza‡Æo */ 
       THEN DO:
                       
           FIND FIRST int_ds_docto_xml NO-LOCK WHERE
                      int_ds_docto_xml.nnf          = c-nr-docum        AND 
                      int_ds_docto_xml.serie        = c-serie-docum     AND 
                      int_ds_docto_xml.tipo_nota    = 1                 AND  
                      int_ds_docto_xml.cod_emitente = i-cod-emitente  NO-ERROR.
           IF AVAIL int_ds_docto_xml 
           THEN DO:

               IF int_ds_docto_xml.situacao = 0 AND /* Nunca */
                  int_ds_docto_xml.tot_desconto = 0
               THEN DO : 
                 
                    assign i-erro = 39
                           c-informacao = "Pedido: " + c-nr-pedcli   + " - " + 
                                          "S‚rie: " + c-serie-docum + " - " + 
                                          "Docto.: " + c-nr-docum    + " - " + 
                                          "Seq.: " + string(i-seq-docum) + " - " + 
                                          "Item: " + c-it-codigo
                           l-movto-com-erro = yes.

                   run gera-log.
                   RETURN.

               END.
               ELSE DO:   

                    FIND FIRST tt-nota-origem WHERE
                               tt-nota-origem.nro-docto      = int_ds_docto_xml.nnf           AND 
                               tt-nota-origem.serie          = int_ds_docto_xml.serie         AND 
                               tt-nota-origem.tipo-nota      = int_ds_docto_xml.tipo_nota     AND 
                               tt-nota-origem.nat-operacao   = int_ds_docto_xml.nat_operacao  AND
                               tt-nota-origem.cod-emitente   = int_ds_docto_xml.cod_emitente NO-ERROR.
                    IF NOT AVAIL tt-nota-origem  
                    THEN DO:
                    
                        CREATE tt-nota-origem.
                        ASSIGN tt-nota-origem.nome-abrev     = c-nome-abrev
                               tt-nota-origem.nr-pedcli      = c-nr-pedcli
                               tt-nota-origem.nro-docto      = int_ds_docto_xml.nnf  
                               tt-nota-origem.serie          = int_ds_docto_xml.serie       
                               tt-nota-origem.tipo-nota      = int_ds_docto_xml.tipo_nota   
                               tt-nota-origem.nat-operacao   = int_ds_docto_xml.nat_operacao
                               tt-nota-origem.cod-emitente   = int_ds_docto_xml.cod_emitente.
                               
                        assign c-nat-docum = int_ds_docto_xml.nat_operacao.       
                    END.
               END.
                 
           END.
           ELSE DO:
                assign i-erro = 39
                       c-informacao = "Pedido: " + c-nr-pedcli   + " - " + 
                                      "S‚rie: " + c-serie-docum + " - " + 
                                      "Docto.: " + c-nr-docum    + " - " + 
                                      "Seq.: " + string(i-seq-docum) + " - " + 
                                      "Item: " + c-it-codigo
                       l-movto-com-erro = yes.

                run gera-log.
                RETURN.
           END.
       END.
       ELSE DO: /* Notas <> de PEPSICO */
           if c-tp_pedido <> "48" then do:
               IF i-seq-docum = ? THEN ASSIGN i-seq-docum = 0.
               for first item-doc-est 
                   fields (nat-operacao sequencia)
                   no-lock where 
                   item-doc-est.cod-emitente = i-cod-emitente and
                   item-doc-est.serie-docto  = c-serie-docum  and
                   item-doc-est.nro-docto    = c-nr-docum     and
                   item-doc-est.nat-operacao <> ""            and
                /* item-doc-est.sequencia    = i-seq-docum and */
                   item-doc-est.it-codigo    = c-it-codigo    and
                   item-doc-est.lote         = if item.tipo-con-est = 3 /* lote */ 
                                               then c-numero-lote else "": 
               end.
               if not avail item-doc-est then do:

                   empty temp-table tt-param-int012.
                   create  tt-param-int012.
                   assign  tt-param-int012.destino          = 3
                           tt-param-int012.usuario          = c-seg-usuario
                           tt-param-int012.data-exec        = today
                           tt-param-int012.hora-exec        = time
                           tt-param-int012.cod-emitente-fim = i-cod-emitente
                           tt-param-int012.cod-emitente-ini = i-cod-emitente
                           tt-param-int012.cod-estabel-fim  = c-cod-estabel
                           tt-param-int012.cod-estabel-ini  = c-cod-estabel
                           tt-param-int012.dt-emis-nota-fim = 08/01/2016
                           tt-param-int012.dt-emis-nota-ini = today
                           tt-param-int012.nro-docto-fim    = decimal(c-nr-docum)
                           tt-param-int012.nro-docto-ini    = decimal(c-nr-docum)
                           tt-param-int012.serie-docto-fim  = c-serie-docum
                           tt-param-int012.serie-docto-ini  = c-serie-docum.
                    assign tt-param-int012.arquivo = session:temp-directory + "INT520" + ".tmp":U.                

                    raw-transfer tt-param-int012 to raw-param.
                    run intprg/int012rp.p (input raw-param,
                                           input table tt-raw-digita).

                    for first item-doc-est 
                        fields (nat-operacao sequencia)
                        no-lock where 
                        item-doc-est.cod-emitente = i-cod-emitente and
                        item-doc-est.serie-docto  = c-serie-docum  and
                        item-doc-est.nro-docto    = c-nr-docum     and
                        item-doc-est.nat-operacao <> ""            and
                     /* item-doc-est.sequencia    = i-seq-docum and */
                        item-doc-est.it-codigo    = c-it-codigo    and
                        item-doc-est.lote         = if item.tipo-con-est = 3 /* lote */ 
                                                    then c-numero-lote else "": 
                    end.

                    if not avail item-doc-est then do:
                        assign i-erro = 18
                               c-informacao = " NÆo existe " +
                                              "Pedido: " + c-nr-pedcli + " - " + 
                                              "S‚rie: " + c-serie-docum + " - " + 
                                              "Docto.: " + c-nr-docum + " - " + 
                                              "Seq.: " + string(i-seq-docum) + " - " +
                                              "Item: " + c-it-codigo
                               l-movto-com-erro = yes.
                        find current int_ds_pedido exclusive-lock no-wait no-error.
                        if avail int_ds_pedido AND int_ds_pedido.ped_tipopedido_n <> 48 then
                            assign int_ds_pedido.situacao = 3.
                        run gera-log. 
                        return.
                    end.
               end.
               ELSE do:
                   c-nat-docum = item-doc-est.nat-operacao.
                   i-seq-docum = item-doc-est.sequencia.
                   for first natur-oper 
                       fields (ind-it-sub-dif 
                               ind-it-icms 
                               subs-trib)
                       no-lock where 
                       natur-oper.nat-operacao = c-nat-docum: 
                       /* Tributado */
                       if item-doc-est.cd-trib-icm = 1 then do:
                           i-cst-icms = if natur-oper.subs-trib and item-doc-est.vl-subs[1] <> 0 then 10 else 0.
                       end.
                       /* Isenta */
                       if item-doc-est.cd-trib-icm = 2 then do:
                           i-cst-icms = if natur-oper.subs-trib and item-doc-est.vl-subs[1] <> 0 then 30 else 40.
                       end.
                       /* Outras */
                       if item-doc-est.cd-trib-icm = 3 then do:
                           i-cst-icms = 90.
                       end.
                       /* Reduzido */
                       if item-doc-est.cd-trib-icm = 4 then do:
                           i-cst-icms = if natur-oper.subs-trib and item-doc-est.vl-subs[1] <> 0 then 70 else 20.
                       end.
                       /* Direfido */
                       if item-doc-est.cd-trib-icm = 5 then do:
                           i-cst-icms = 51.
                       end.
                       if natur-oper.ind-it-sub-dif then i-cst-icms = 50.
                       if natur-oper.ind-it-icms then i-cst-icms = 60.
                   end.
               end. 
           end.
       END. 
   end.

   /*
   /* determina natureza de operacao */
   run intprg/int015a.p ( input c-tp_pedido     ,
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
                          output r-rowid        ,
                          OUTPUT c-natur-ent).
   */

   /* determina natureza de operacao */
   run intprg/int115a.p ( input c-tp_pedido   ,
                          input c-uf-destino  ,
                          input c-uf-origem   ,
                          input c-nat-docum   ,
                          input i-cod-emitente,
                          input c-class-fiscal,
			              input c-it-codigo    , /* item */
                          INPUT "", // estabel
                          output c-natur      ,
                          output c-natur-ent  ,
                          output r-rowid).

   for first natur-oper no-lock where
       natur-oper.nat-operacao = c-natur: end.

   if not avail natur-oper then do:
       assign i-erro = 21
              c-informacao = "Pedido: " + c-nr-pedcli + " Tipo Ped.: " + 
                             string(C-tp_pedido) + " Natur. Oper.: " + c-natur + " UF Destino: " + 
                             c-uf-destino + " UF Origem: " + 
                             c-uf-origem + " Estab.: " + 
                             C-COD-ESTABEL + " Emitente: " + 
                             STRING(I-COD-EMITENTE) + " NCM: " +
                             C-CLASS-FISCAL
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
                          c-natur + " Esp. Doc.: " + natur-oper.especie-doc
           l-movto-com-erro = yes.
       run gera-log. 
       return.
   end.
   if avail natur-oper and 
     (natur-oper.especie-doc <> "NFD" and
      not natur-oper.terceiros) and
      c-nr-docum <> "" and
      c-tp_pedido <> "48" then do:
       assign i-erro = 29
              c-informacao = "Pedido: " + c-nr-pedcli + " Natur. Oper.: " + 
                             c-natur + " Esp. Doc.: " + natur-oper.especie-doc
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

   assign l-ind-icm-ret = yes.
   if de-vl-uni = 0 and avail item then do:
      /*
      if c-nr-tabpre <> "" then do:    
          find tb-preco where 
               tb-preco.nr-tabpre = c-nr-tabpre
               no-lock no-error.
          if not avail tb-preco then do:
             assign i-erro = 3
                    c-informacao = "Pedido: " + c-nr-pedcli + " Tab. Pre‡o: " + 
                                   c-nr-tabpre
                    l-movto-com-erro = yes.
             run gera-log. 
             return.
          end.
          if avail tb-preco then do:
              if tb-preco.dt-inival >= d-dt-emissao or 
                 tb-preco.dt-fimval <= d-dt-emissao then do:
                 assign i-erro = 4
                        c-informacao = "Pedido: " + c-nr-pedcli + " Tab. Pre‡o: " + 
                                       c-nr-tabpre
                        l-movto-com-erro = yes.
                 run gera-log. 
                 return.
              end.     
              if tb-preco.dt-inival >= today or 
                 tb-preco.dt-fimval <= today then do:
                 assign i-erro = 4
                        c-informacao = "Pedido: " + c-nr-pedcli + " Tab. Pre‡o: " + 
                                       c-nr-tabpre
                        l-movto-com-erro = yes.
                 run gera-log. 
                 return.
              end.     
              if not tb-preco.situacao = 1 then do:
                 assign i-erro = 5
                        c-informacao = "Pedido: " + c-nr-pedcli + " Tab. Pre‡o: " + 
                                       c-nr-tabpre
                        l-movto-com-erro = yes.
                 run gera-log. 
                 return.
              end.
           end.
        end.  

        for last preco-item no-lock where 
            preco-item.nr-tabpre = c-nr-tabpre and
            preco-item.it-codigo = item.it-codigo and
            preco-item.situacao = 1 /* ativo */ and
            preco-item.dt-inival <= today:
            assign de-vl-uni = preco-item.preco-venda.
        end.
        */
   end.

   if de-vl-uni = 0 then do:
        assign i-erro = 38
               c-informacao = "Pedido: " + c-nr-pedcli + " Tab. Pre‡o: " + 
                              c-nr-tabpre + " Item: " + 
                              c-it-codigo
               l-movto-com-erro = yes.
        run gera-log. 
        return.
   end.
    /* original baccin - verificar lote!
   if trim(c-nr-docum) <> "" then do:
        for first item-doc-est no-lock where 
            item-doc-est.cod-emitente = i-cod-emitente and
            item-doc-est.serie-docto  = c-serie-docum  and
            item-doc-est.nro-docto    = c-nr-docum     and
            item-doc-est.nat-operacao <> ""            and
            /*item-doc-est.sequencia    = i-seq-docum    and*/
            item-doc-est.it-codigo    = c-it-codigo    and
            item-doc-est.lote         = c-numero-lote: 
            i-seq-docum = item-doc-est.sequencia.
        end.
        if not avail item-doc-est then do:
            assign i-erro = 18
                   c-informacao = "Pedido: " + c-nr-pedcli + " S‚rie: " + 
                                  c-serie-docum + " Docto.: " + 
                                  c-nr-docum + " Lote: " + 
                                  c-numero-lote + " Item: " +
                                  c-it-codigo
                   l-movto-com-erro = yes.
            run gera-log. 
            return.
        end.
    end.
    */

end.
 
procedure cria-tt-ped-venda-prs.
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
          tt-ped-venda-prs.tp-pedido      = c-tp_pedido
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
                                             then ems2dis.canal-venda.cod-canal-venda
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
                                                        tt-ped-venda-prs.ind-tp-frete   = 1 /* CIF */.
        end.
        else do:
            assign tt-ped-venda-prs.cod-entrega  = "PadrÆo".
        end.
   end.

   if tt-ped-venda-prs.ind-tp-frete = 1 then /* CIF */
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
          tt-ped-venda-prs.cod-des-merc   = if natur-oper.consum-final OR NOT emitente.contrib-icms
                                            then 2 else 1
          tt-ped-venda-prs.observacoes    = c-observacao
          tt-ped-venda-prs.nome-transp    = c-nome-transp  
          tt-ped-venda-prs.tp-preco       = 1
          tt-ped-venda-prs.tip-cob-desp   = emitente.tip-cob-desp
          tt-ped-venda-prs.per-max-canc   = emitente.per-max-canc
          tt-ped-venda-prs.ind-lib-nota   = yes.
end.
 
procedure cria-tt-ped-item-prs.
   run pi-acompanhar in h-acomp (input "Criando Itens do Pedido").
   /*
   find last preco-item where 
        preco-item.nr-tabpre   = c-nr-tabpre and
        preco-item.it-codigo   = c-it-codigo and
        preco-item.situacao = 1 /* ativo */ and
        preco-item.dt-inival <= today
        no-lock no-error. 
   if avail preco-item and de-vl-uni = 0 and 
      preco-item.preco-venda <> 0 then
        assign de-preco = preco-item.preco-venda.
   else*/
        assign de-preco = de-vl-uni. 

   for first tt-ped-item-prs where
       tt-ped-item-prs.nome-abrev   = tt-ped-venda-prs.nome-abrev and
       tt-ped-item-prs.nr-pedcli    = tt-ped-venda-prs.nr-pedcli  and
       tt-ped-item-prs.nr-sequencia = i-nr-sequencia              and
       tt-ped-item-prs.it-codigo    = c-it-codigo                 and
       tt-ped-item-prs.numero-lote  = c-numero-lote: end.
   if not avail tt-ped-item-prs then do:
       assign i-nr-sequencia = i-nr-sequencia + 10.
       create tt-ped-item-prs.
       assign tt-ped-item-prs.nome-abrev   = tt-ped-venda-prs.nome-abrev
              tt-ped-item-prs.nr-pedcli    = tt-ped-venda-prs.nr-pedcli
              tt-ped-item-prs.nr-sequencia = i-nr-sequencia
              tt-ped-item-prs.it-codigo    = c-it-codigo
              tt-ped-item-prs.nat-operacao = c-natur
              tt-ped-item-prs.nr-tabpre    = "" /*c-nr-tabpre*/
              tt-ped-item-prs.qt-un-fat    = tt-ped-item-prs.qt-pedida
              tt-ped-item-prs.vl-pretab    = de-preco /* preco-item.preco-venda */
              tt-ped-item-prs.vl-preori    = de-preco.
       assign tt-ped-item-prs.des-un-medida = item.un
              tt-ped-item-prs.cod-un        = item.un.
       assign tt-ped-item-prs.cod-refer     = c-cod-refer.
   end.
   assign tt-ped-item-prs.qt-pedida     = tt-ped-item-prs.qt-pedida 
                                        + dec(de-quantidade).

   assign tt-ped-item-prs.numero-lote   = c-numero-lote
          tt-ped-item-prs.numero-caixa  = c-numero-caixa
          tt-ped-item-prs.nr-docum      = if c-tp_pedido <> "48" then c-nr-docum else ""
          tt-ped-item-prs.nat-docum     = if c-tp_pedido <> "48" then c-nat-docum else ""
          tt-ped-item-prs.serie-docum   = if c-tp_pedido <> "48" then c-serie-docum else ""
          tt-ped-item-prs.seq-docum     = if c-tp_pedido <> "48" and trim(c-nr-docum) <> "" then i-seq-docum else ?.


   assign de-preco-liq = de-preco.
   if de-desconto <> 0 then
   do:
      assign de-preco-liq = de-preco * (1 - (de-desconto / 100)).
      assign tt-ped-item-prs.val-pct-desconto-total = de-desconto
             tt-ped-item-prs.val-desconto-total = (dec(de-quantidade) * de-preco)
                                            * (de-desconto / 100).
      assign tt-ped-item-prs.des-pct-desconto-inform = string(de-desconto)
             tt-ped-item-prs.per-des-item = de-desconto
             tt-ped-item-prs.log-usa-tabela-desconto = no.
   end.
   assign de-red-base-ipi = 0 /* base normal */
          de-base-ipi = (de-preco-liq * tt-ped-item-prs.qt-pedida). 
   if avail natur-oper and /* IPI SOBRE O BRUTO */
     substring(natur-oper.char-2,11,1) = "1" then
   do:
      de-base-ipi = (de-preco * tt-ped-item-prs.qt-pedida). 
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
 
procedure emite-nota.
    run pi-acompanhar in h-acomp (input "Gerando Nota").

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
    
            FIND FIRST tt-nota-origem WHERE
                       tt-nota-origem.nome-abrev = tt-ped-venda-prs.nome-abrev AND 
                       tt-nota-origem.nr-pedcli  = tt-ped-venda-prs.nr-pedcli NO-ERROR.
            IF AVAIL tt-nota-origem THEN DO:
               
               RUN pi-AtualizaNotaOrigem.

               if l-movto-com-erro then undo, next.

            END.   

            run criaWtDocto in h-bodi317sd
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
            run pi-erro-nota(h-bodi317sd,'sd'). if l-movto-com-erro then undo, return.
    
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
                run atualizaDadosGeraisNota in h-bodi317sd(input  i-seq-wt-docto,
                                                           output l-proc-ok-aux).
    
                */
                /* Caso tenha achado algum erro ou advertˆncia, gera tt-erro */
                run pi-erro-nota(h-bodi317sd,'sd'). if l-movto-com-erro then undo, return.
        
                RUN pi-gera-itens-nota.
                if l-movto-com-erro then undo, next.

                RUN pi-calcula-nota.
                if l-movto-com-erro then undo, next.

                RUN pi-efetiva-nota.
                if l-movto-com-erro then undo, next.

            end.    
        end.
    end.
    run pi-elimina-tabelas.
    RUN pi-finaliza-bos.
end.

procedure pi-gera-itens-nota:

    for each tt-ped-item-prs no-lock of tt-ped-venda-prs:

        for first item fields (it-codigo deposito-pad item.cod-localiz)
            no-lock where item.it-codigo = tt-ped-item-prs.it-codigo: end.
        for first item-uni-estab no-lock where 
            item-uni-estab.it-codigo = tt-ped-item-prs.it-codigo and
            item-uni-estab.cod-estabel = tt-ped-venda-prs.cod-estabel: end.

        /* Disponibilizar o registro WT-DOCTO na bodi317sd */
        run localizaWtDocto in h-bodi317sd(input  i-seq-wt-docto,
                                           output l-proc-ok-aux).
             
        /* faturamentos */
        if tt-ped-item-prs.nr-docum = "" then run pi-envios.
        /* beneficiamentos */
        else if natur-oper.terceiros /*and
                natur-oper.tp-oper-terc = 2 /* retorno beneficiamento */ */ then run pi-terceiros.
        /* devolucao */
        else run pi-devolucoes.

        /* Disp. registro WT-DOCTO, WT-IT-DOCTO e WT-IT-IMPOSTO na bodi317pr */
        run localizaWtDocto       in h-bodi317pr(input  i-seq-wt-docto,
                                                 output l-proc-ok-aux).
       
        run localizaWtItDocto     in h-bodi317pr(input  i-seq-wt-docto,
                                                 input  i-seq-wt-it-docto,
                                                 output l-proc-ok-aux).

        run localizaWtItImposto   in h-bodi317pr(input  i-seq-wt-docto,
                                                 input  i-seq-wt-it-docto,
                                                 output l-proc-ok-aux).

        for each wt-it-docto exclusive-lock
            where wt-it-docto.seq-wt-docto    = i-seq-wt-docto and
                  wt-it-docto.seq-wt-it-docto = i-seq-wt-it-docto:
            assign wt-it-docto.nr-pedcli      = tt-ped-item-prs.nr-pedcli
                   wt-it-docto.nr-seq-ped     = tt-ped-item-prs.nr-sequencia
                .

            /* resolver erro dos adapters que utilizam qt familia mesmo se marcado para nÆo utilizar 
            ASSIGN wt-it-docto.quantidade[2]  = wt-it-docto.quantidade[1]
                   wt-it-docto.un[2]          = wt-it-docto.un[1]
                   wt-it-docto.fat-qtfam      = NO.
            */

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
            assign wt-it-imposto.ind-icm-ret = NO.

        /* Atualiza dados c lculados do item */
        run atualizaDadosItemNota in h-bodi317pr(output l-proc-ok-aux).
        /* Caso tenha achado algum erro ou advertˆncia, gera tt-erro */
        run pi-erro-nota(h-bodi317pr,'pr'). if l-movto-com-erro then undo, return.

        /* Valida informa‡äes do item */
        run validaItemDaNota      in h-bodi317va(input  i-seq-wt-docto,
                                                 input  i-seq-wt-it-docto,
                                                 output l-proc-ok-aux).
        /* Caso tenha achado algum erro ou advertˆncia, gera tt-erro */
        run pi-erro-nota(h-bodi317va,'va'). if l-movto-com-erro then undo, return.

    end. /* tt-ped-item-prs */
    if l-movto-com-erro then undo, leave.
end procedure.

procedure pi-envios:
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
    run pi-erro-nota(h-bodi317sd,'sd'). if l-movto-com-erro then undo, return.


    run WriteUomQuantity in h-bodi317sd 
        (input  i-seq-wt-docto,
         input  i-seq-wt-it-docto,
         input  tt-ped-item-prs.qt-pedida,
         input  tt-ped-item-prs.cod-un,
         output de-quantidade,
         output l-proc-ok-aux).

    /* Grava informa‡äes gerais para o item da nota */
    run gravaInfGeraisWtItDocto in h-bodi317sd 
            (input i-seq-wt-docto,
             input i-seq-wt-it-docto,
             input /*tt-ped-item-imp.qt-pedida*/ de-quantidade,
             input tt-ped-item-prs.vl-preori,
             input 0,
             input tt-ped-item-prs.per-des-item). /*0*/


    if tt-ped-item-prs.numero-lote <> "" and 
       item.tipo-con-est = 3 /* lote */ then do:
        for each Wt-fat-ser-lote exclusive-lock 
            where  wt-fat-ser-lote.seq-wt-docto    = i-seq-wt-docto 
              and  wt-fat-ser-lote.seq-wt-it-docto = i-seq-wt-it-docto:
            delete wt-fat-ser-lote.
        end.
        
        de-qt-utilizada = /*tt-ped-item-prs.qt-pedida.*/ de-quantidade.
        
        for first deposito no-lock where deposito.cons-saldo:
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
                     input tt-ped-item-prs.numero-lote,
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
end.

procedure pi-busca-saldo-terc:
    def input param de-qt-devol as decimal no-undo.

    for-1:
    for each saldo-terc where 
        saldo-terc.cod-estabel   = c-cod-estabel                 and
        saldo-terc.cod-emitente  = item-doc-est.cod-emitente     and
        saldo-terc.nat-operacao  = item-doc-est.nat-operacao     and
        saldo-terc.it-codigo     = item-doc-est.it-codigo        and
        saldo-terc.nro-docto     = item-doc-est.nro-docto        and
        saldo-terc.serie-docto   = item-doc-est.serie-docto      and
        saldo-terc.quantidade > 0
        break by saldo-terc.serie-docto
                 by saldo-terc.nro-docto:
 
        run pi-saldo-terc (input-output de-qt-devol).
        if de-qt-devol <= 0 then leave for-1.
    end.
    if de-qt-devol > 0 and not l-movto-com-erro then do:
        assign i-erro = 19
               c-informacao = "S‚rie: " + c-serie-docum + " Docto.:" + 
                              c-nr-docum + " Lote: " + 
                              c-numero-lote + " Item: " +
                              c-it-codigo
               l-movto-com-erro = yes.
        run gera-log. 
        return error.
    end.
end.

procedure pi-saldo-terc:
    def input-output param de-qt-devol as decimal format "->>>,>>>,>>9.99" no-undo.

    def var de-qt-ja-devolvida as decimal no-undo.
    def var de-qt-utilizada as decimal no-undo.

    run pi-acompanhar in h-acomp (input 'Lendo 3os ' + saldo-terc.it-codigo + ' ' + 
                                  saldo-terc.nro-docto).

    assign de-qt-ja-devolvida = 0.
    /* verifica qtde que vai usar na nota de devolucao */
    for each tt-it-terc-nf no-lock
        where tt-it-terc-nf.rw-saldo-terc = rowid(saldo-terc):
        assign de-qt-ja-devolvida = de-qt-ja-devolvida + tt-it-terc-nf.qt-disponivel-inf.
    end.

    i-cont = 10.
    assign de-qt-utilizada = (saldo-terc.quantidade - saldo-terc.dec-1) 
                           - de-qt-ja-devolvida.
    if de-qt-utilizada < 0 then de-qt-utilizada = 0.
    if de-qt-utilizada > 0 then do:

        for first tt-it-terc-nf where tt-it-terc-nf.rw-saldo-terc = rowid(saldo-terc): end.
        if not avail tt-it-terc-nf then do:
            for first item no-lock where item.it-codigo = saldo-terc.it-codigo: end.
            create tt-it-terc-nf.
            assign tt-it-terc-nf.rw-saldo-terc     = rowid(saldo-terc)
                   tt-it-terc-nf.sequencia         = i-cont
                   tt-it-terc-nf.it-codigo         = saldo-terc.it-codigo
                   tt-it-terc-nf.cod-refer         = saldo-terc.cod-refer
                   tt-it-terc-nf.desc-nar          = if item.tipo-contr = 4 /* D‚bito Direto */
                                                     then substr(item.narrativa,1,60)
                                                     else item.desc-item
                   tt-it-terc-nf.quantidade        = saldo-terc.quantidade
                   tt-it-terc-nf.qt-alocada        = saldo-terc.dec-1
                   tt-it-terc-nf.qt-disponivel     = saldo-terc.quantidade - saldo-terc.dec-1
                   tt-it-terc-nf.selecionado       = yes.
            assign i-cont = i-cont + 10.
        end.

        if de-qt-utilizada >= de-qt-devol then 
            assign tt-it-terc-nf.qt-disponivel-inf = tt-it-terc-nf.qt-disponivel-inf + de-qt-devol
                   de-qt-devol = 0.    
        else
            assign tt-it-terc-nf.qt-disponivel-inf = tt-it-terc-nf.qt-disponivel-inf + de-qt-utilizada
                   de-qt-devol = de-qt-devol - de-qt-utilizada.

        for first componente
           fields(componente.preco-total[1]
                  componente.cod-emitente 
                  componente.nro-docto    
                  componente.serie-docto  
                  componente.nat-operacao 
                  componente.it-codigo    
                  componente.cod-refer   
                  componente.sequencia)
            where componente.serie-docto  = saldo-terc.serie-docto
              and componente.nro-docto    = saldo-terc.nro-docto
              and componente.cod-emitente = saldo-terc.cod-emitente
              and componente.nat-operacao = saldo-terc.nat-operacao
              and componente.it-codigo    = saldo-terc.it-codigo
              and componente.cod-refer    = saldo-terc.cod-refer
              and componente.sequencia    = saldo-terc.sequencia no-lock,
            first docum-est no-lock
            where docum-est.nro-docto     = saldo-terc.nro-docto
              and docum-est.cod-emitente  = saldo-terc.cod-emitente
              and docum-est.nat-operacao  = saldo-terc.nat-operacao
              and docum-est.serie-docto   = saldo-terc.serie-docto
              and docum-est.CE-atual      = yes:

            assign tt-it-terc-nf.preco-total    = componente.preco-total[1].
            for each bcomponente
                fields (bcomponente.componente
                        bcomponente.preco-total[1]
                        bcomponente.desconto[1])
                where bcomponente.cod-emitente = componente.cod-emitente 
                  and bcomponente.nro-comp     = componente.nro-docto    
                  and bcomponente.serie-comp   = componente.serie-docto  
                  and bcomponente.nat-comp     = componente.nat-operacao 
                  and bcomponente.it-codigo    = componente.it-codigo    
                  and bcomponente.cod-refer    = componente.cod-refer   
                  and bcomponente.seq-comp     = componente.sequencia 
                  and (bcomponente.quantidade <> 0
                   OR  bcomponente.dt-retorno <= today) no-lock: /* NF Reajuste ate Dt Trans */ 


                if bcomponente.componente = 1 then /* Envio */
                    assign tt-it-terc-nf.preco-total = tt-it-terc-nf.preco-total + bcomponente.preco-total[1].
                else /* Retorno */
                    assign tt-it-terc-nf.preco-total = tt-it-terc-nf.preco-total - bcomponente.preco-total[1].
            end.

            assign tt-it-terc-nf.preco-total     = if tt-it-terc-nf.preco-total < 0 then 0
                                                   else tt-it-terc-nf.preco-total.
            assign tt-it-terc-nf.preco-total-inf = (tt-it-terc-nf.preco-total / saldo-terc.quantidade) * 
                                                    tt-it-terc-nf.qt-disponivel-inf.
        end.
    end.

end procedure.

procedure pi-terceiros:

    for first item-doc-est no-lock where 
        item-doc-est.cod-emitente = i-cod-emitente and
        item-doc-est.serie-docto  = c-serie-docum  and
        item-doc-est.nro-docto    = c-nr-docum     and
        item-doc-est.nat-operacao <> ""            and
        item-doc-est.sequencia    = i-seq-docum    and
        item-doc-est.it-codigo    = c-it-codigo:   

        run pi-busca-saldo-terc (input de-quantidade).

        RUN emptyRowErrors IN h-bodi317in.
        RUN inbo/boin404te.p PERSISTENT SET h-boin404te.
        RUN setaHandleBoin404te IN h-bodi317sd(INPUT h-boin404te).
        RUN geraWtItDoctoPartindoDoTtItTercNf IN h-bodi317sd(INPUT  wt-docto.seq-wt-docto,
                                                             INPUT  10,
                                                             INPUT  10,
                                                             INPUT  TABLE tt-it-terc-nf,
                                                             OUTPUT l-proc-ok-aux).
        /* Caso tenha achado algum erro ou advertˆncia, gera tt-erro */
        run pi-erro-nota(h-bodi317sd,'sd'). if l-movto-com-erro then undo, return.
    end.
end.

procedure pi-devolucoes:

    DEF VAR c-serie-devol AS CHAR.
     
    empty temp-table tt-itens-devol.
   
     /* for first wt-docto where 
               wt-docto.seq-wt-docto = i-seq-wt-docto :

          MESSAGE wt-docto.ind-tip-nota VIEW-AS ALERT-BOX.
     END. */

    FIND FIRST tt-nota-origem WHERE
               tt-nota-origem.nome-abrev  = tt-ped-item-prs.nome-abrev AND
               tt-nota-origem.nr-pedcli   = tt-ped-item-prs.nr-pedcli   NO-ERROR.
    IF AVAIL tt-nota-origem THEN
       ASSIGN c-serie-devol = "D".
    ELSE 
       ASSIGN c-serie-devol = tt-ped-item-prs.serie-docum.  
       
    
    /* popula a tt-itens-devol */
    run geraItensDevolucaoTtItensDevol in h-bodi317sd 
        (input i-seq-wt-docto,
         input c-serie-devol,
         input tt-ped-item-prs.nr-docum,
         input tt-ped-item-prs.nat-docum,
         output table tt-itens-devol,
         output l-proc-ok-aux).
              
    /* Caso tenha achado algum erro ou advertˆncia, gera tt-erro */
    run pi-erro-nota(h-bodi317sd,'sd'). if l-movto-com-erro then undo, return.

    /* seleciona o item a ser devolvido e a quantidade
       aqui nao eh usado o cod-emitente pq ele nao eh usado no
       geraItensDevolucaoTtItensDevol, apesar de fazer parte da chave 
       da tt-itens-devol */
    for each tt-itens-devol
        where tt-itens-devol.serie-docto  = c-serie-devol
          and tt-itens-devol.nro-docto    = tt-ped-item-prs.nr-docum
          and tt-itens-devol.nat-operacao = tt-ped-item-prs.nat-docum
          AND tt-itens-devol.it-codigo    = tt-ped-item-prs.it-codigo:
        
        assign
            tt-itens-devol.selecionado       = yes
            tt-itens-devol.qt-a-devolver     = tt-ped-item-prs.qt-pedida
            tt-itens-devol.qt-a-devolver-inf = tt-ped-item-prs.qt-pedida.
    end.

    /* cria o Wt-it-docto */
    run geraWtItDoctoPartindoDoTtItensDevol in h-bodi317sd 
        (input i-seq-wt-docto,
         input table tt-itens-devol,
         output l-proc-ok-aux).
    
    
    /* Caso tenha achado algum erro ou advertˆncia, gera tt-erro */
    run pi-erro-nota(h-bodi317sd,'sd'). if l-movto-com-erro then undo, return.


    /* localiza a seq do item criado */
    assign i-seq-wt-it-last  = i-seq-wt-it-docto.
    
    for first wt-it-docto
        where wt-it-docto.seq-wt-docto    = i-seq-wt-docto
          and wt-it-docto.seq-wt-it-docto > i-seq-wt-it-last
        no-lock:
        assign i-seq-wt-it-docto = wt-it-docto.seq-wt-it-docto.
    end.

    
                  
    IF i-seq-wt-it-docto = 0 /* Evitar erro da sequencia */ 
    THEN DO:

         for each tt-itens-devol
            where tt-itens-devol.serie-docto  = c-serie-devol
              and tt-itens-devol.nro-docto    = tt-ped-item-prs.nr-docum
              and tt-itens-devol.nat-operacao = tt-ped-item-prs.nat-docum:
    
            FOR FIRST wt-it-docto NO-LOCK WHERE
                      wt-it-docto.nat-operacao = tt-itens-devol.nat-operacao AND 
                      wt-it-docto.it-codigo    = tt-itens-devol.it-codigo   :
                
               assign i-seq-wt-it-docto = wt-it-docto.seq-wt-it-docto.     
    
            END.
                
         END.

    END.
               
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
    run confirmaCalculo          in h-bodi317pr(input  i-seq-wt-docto,
                                                output l-proc-ok-aux).
    run finalizaAcompanhamento   in h-bodi317pr.

    /* Caso tenha achado algum erro ou advertˆncia, gera tt-erro */
    run pi-erro-nota(h-bodi317pr,'pr'). if l-movto-com-erro then undo, return.

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
                                                input  yes,
                                                output l-proc-ok-aux).
    run finalizaAcompanhamento   in h-bodi317ef.
    /* Caso tenha achado algum erro ou advertˆncia, gera tt-erro */
    run pi-erro-nota(h-bodi317ef,'ef'). if l-movto-com-erro then undo, return.

    /* Busca as notas fiscais geradas */
    FOR EACH tt-notas-geradas.
        DELETE tt-notas-geradas.
    END.
    run buscaTTNotasGeradas in h-bodi317ef(output l-proc-ok-aux,
                                           output table tt-notas-geradas).
    for each tt-notas-geradas:
        for first nota-fiscal exclusive-lock where 
            rowid(nota-fiscal) = tt-notas-geradas.rw-nota-fiscal:
            assign /*nota-fiscal.docto-orig = c-docto-orig*/
                   nota-fiscal.obs-gerada = c-obs-gerada
                   nota-fiscal.nr-pedcli  = tt-ped-venda-prs.nr-pedcli.

            FOR FIRST int_ds_pedido WHERE
                      int_ds_pedido.ped_codigo_n = INT(tt-ped-venda-prs.nr-pedcli) NO-LOCK: 
            END.
            IF AVAIL int_ds_pedido THEN DO:

               IF int_ds_pedido.ped_tipopedido_n <> 33 THEN
                 ASSIGN nota-fiscal.docto-orig = c-docto-orig.

               IF int_ds_pedido.cod_model_ecf   <> "?" AND 
                  int_ds_pedido.cod_fabricc_ecf <> "?" THEN DO:
                  FOR FIRST nota-fisc-adc WHERE
                            nota-fisc-adc.cod-estab      = nota-fiscal.cod-estabel  AND
                            nota-fisc-adc.cod-serie      = nota-fiscal.serie        AND
                            nota-fisc-adc.cod-nota-fisc  = nota-fiscal.nr-nota-fis  AND
                            nota-fisc-adc.cdn-emitente   = nota-fiscal.cod-emitente AND
                            nota-fisc-adc.cod-natur-oper = nota-fiscal.nat-operacao AND
                            nota-fisc-adc.idi-tip-dado   = 4                        AND
                            nota-fisc-adc.num-seq        = 1:
                  END.
                  IF NOT AVAIL nota-fisc-adc THEN DO:
                     create nota-fisc-adc.
                     ASSIGN nota-fisc-adc.cod-estab      = nota-fiscal.cod-estabel  
                            nota-fisc-adc.cod-serie      = nota-fiscal.serie        
                            nota-fisc-adc.cod-nota-fisc  = nota-fiscal.nr-nota-fis  
                            nota-fisc-adc.cdn-emitente   = nota-fiscal.cod-emitente 
                            nota-fisc-adc.cod-natur-oper = nota-fiscal.nat-operacao 
                            nota-fisc-adc.idi-tip-dado   = 4                          
                            nota-fisc-adc.num-seq        = 1.
                  END.
                  ASSIGN nota-fisc-adc.cod-model-ecf          = int_ds_pedido.cod_model_ecf
                         nota-fisc-adc.cod-fabricc-ecf        = int_ds_pedido.cod_fabricc_ecf
                         nota-fisc-adc.cod-cx-ecf             = int_ds_pedido.cod_cx_ecf
                         nota-fisc-adc.cod-docto-referado-ecf = int_ds_pedido.cod_docto_referado_ecf
                         nota-fisc-adc.dat-docto-referado-ecf = int_ds_pedido.dat_docto_referado_ecf.
               END.
            END.
        end.
    end.
   /* Elimina o handle do programa bodi317ef */
   delete procedure h-bodi317ef.
end.

procedure pi-finaliza-bos:
    if  valid-handle(h-bodi317va) then delete procedure h-bodi317va.
    if  valid-handle(h-bodi317pr) then delete procedure h-bodi317pr.
    if  valid-handle(h-bodi317sd) then delete procedure h-bodi317sd.
    if  valid-handle(h-bodi317im1bra) then delete procedure h-bodi317im1bra.
end.


procedure pi-erro-nota:
    define input parameter h-bo as handle.
    define input parameter c-bo as char no-undo.

    def var c-proc as char no-undo.
    
    ASSIGN c-proc = "devolveErrosbodi317" + c-bo.

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
        if RowErrors.errornumber = 18699 then next. /* aviso */
        /*if RowErrors.errornumber = 18507 then next. /* aviso */*/

      
        assign i-erro = 22
               c-informacao = "Estab.: " + c-cod-estabel + " Cliente: " + string(i-cod-emitente) + " Pedido: " + c-nr-pedcli + " BO: " 
                              + c-bo + " Natur. Oper.: " + c-natur + " S‚rie: " + c-serie + " Item: " + c-it-codigo + " - " +
                              "Cod. Erro: " + string(RowErrors.errornumber) + " - " + 
                              RowErrors.errordescription
               l-movto-com-erro = yes.
        run gera-log. 
        return.
    end.
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
   RUN intprg/int999.p ("NF PED", 
                        c-nr-pedcli,
                        (trim(tb-erro[i-erro]) + " - " + c-informacao),
                        int_ds_pedido.situacao, /* 1 - Pendente, 2 - Processado */ 
                        c-seg-usuario,
                        "INT117RP.P").
    /* INICIO - Grava¯Êo LOG Tabela para a PROCFIT */
    FIND FIRST bint_ds_pedido OF int_ds_pedido EXCLUSIVE-LOCK NO-ERROR.
    IF AVAIL bint_ds_pedido THEN DO:
        IF bint_ds_pedido.situacao = 2 THEN DO:
            ASSIGN bint_ds_pedido.envio_status      = 8
                   bint_ds_pedido.retorno_validacao = "".
        END.
        ELSE IF bint_ds_pedido.situacao = 1 THEN DO:
            ASSIGN bint_ds_pedido.envio_status      = 9
                   bint_ds_pedido.retorno_validacao = substring(trim(tb-erro[i-erro]) + " - " + c-informacao,1,500).
        END.
    END.
    RELEASE bint_ds_pedido.
    /* FIM    - Grava¯Êo LOG Tabela para a PROCFIT */


   assign c-informacao = " ".
end.

PROCEDURE pi-AtualizaNotaOrigem:
/* Atualiza as quantidades na nota de origem e gera uma nota de entrada com uma 
   serie espec­fica para devolu»’o cria um registro no int0002 e atualiza automaticamente no re1001 */

    DEF VAR c-serie-devol AS CHAR. 
            
    EMPTY TEMP-TABLE tt-docto-xml.
    EMPTY TEMP-TABLE tt-it-docto-xml.

    ASSIGN c-serie-devol = "D".

    FIND FIRST int_ds_docto_xml NO-LOCK WHERE
               int_ds_docto_xml.nnf           = tt-nota-origem.nro-docto     AND
               int_ds_docto_xml.serie         = tt-nota-origem.serie         AND 
               int_ds_docto_xml.tipo_nota     = tt-nota-origem.tipo-nota     AND 
               int_ds_docto_xml.nat_operacao  = tt-nota-origem.nat-operacao  AND 
               int_ds_docto_xml.cod_emitente  = tt-nota-origem.cod-emitente  NO-ERROR.
    IF AVAIL int_ds_docto_xml THEN DO:

        CREATE tt-docto-xml.                                                   
        BUFFER-COPY int_ds_docto_xml TO tt-docto-xml.                       
        ASSIGN tt-docto-xml.serie    = c-serie-devol                           
               tt-docto-xml.situacao = 3
               tt-docto-xml.vNF      = int_ds_pedido.ped_valortotalbruto_n
               tt-docto-xml.dt_trans = TODAY 
               tt-docto-xml.dEmi     = TODAY.

        FIND FIRST emitente NO-LOCK WHERE
                   emitente.cod-emitente = int_ds_docto_xml.cod_emitente NO-ERROR.

        FIND FIRST param-estoq NO-LOCK NO-ERROR. 
                          
        FOR EACH int_ds_pedido_produto NO-LOCK WHERE
                 int_ds_pedido_produto.ped_codigo_n = int_ds_pedido.ped_codigo_n,
            EACH  int_ds_pedido_retorno OF int_ds_pedido_produto NO-LOCK:

            ASSIGN c-numero-lote = if trim(int_ds_pedido_retorno.rpp_lote_s) <> "0" and 
                                      trim(int_ds_pedido_retorno.rpp_lote_s) <> "?" and
                                      trim(int_ds_pedido_retorno.rpp_lote_s) <> ? then trim(int_ds_pedido_retorno.rpp_lote_s) else "".

            FIND FIRST int-ds-it-docto-xml EXCLUSIVE-LOCK WHERE
                       int-ds-it-docto-xml.nnf          = int_ds_docto_xml.nnf           AND 
                       int-ds-it-docto-xml.serie        = int_ds_docto_xml.serie         AND
                       int-ds-it-docto-xml.tipo-nota    = int_ds_docto_xml.tipo_nota     AND
                       int-ds-it-docto-xml.cod-emitente = int_ds_docto_xml.cod_emitente  AND 
                       int-ds-it-docto-xml.it-codigo    = string(int_ds_pedido_produto.ppr_produto_n) NO-ERROR.
            IF AVAIL int-ds-it-docto-xml 
            THEN DO:
                IF int_ds_pedido_produto.ppr_quantidade_n >= int-ds-it-docto-xml.qcom 
                THEN ASSIGN int-ds-it-docto-xml.situacao = 4. /* Devolvida */
                ELSE ASSIGN int-ds-it-docto-xml.qcom = int-ds-it-docto-xml.qcom - int_ds_pedido_produto.ppr_quantidade_n.

                CREATE tt-it-docto-xml.
                BUFFER-COPY int-ds-it-docto-xml TO tt-it-docto-xml.
                ASSIGN tt-it-docto-xml.serie    = c-serie-devol
                       tt-it-docto-xml.situacao = 3
                       tt-it-docto-xml.qcom     = int_ds_pedido_produto.ppr_quantidade_n
                       tt-it-docto-xml.vprod    = tt-it-docto-xml.qcom * tt-it-docto-xml.vuncom. 
            END.

            RELEASE int-ds-it-docto-xml.

            FIND FIRST tt-nota WHERE
                       tt-nota.nro-docto    = int_ds_docto_xml.nnf           AND 
                       tt-nota.serie-nota   = c-serie-devol /* serie devolucao */    AND 
                       tt-nota.nat-operacao = int_ds_docto_xml.nat_operacao  AND 
                       tt-nota.cod-emitente = emitente.cod-emitente NO-ERROR.
            IF NOT AVAIL tt-nota 
            THEN DO:
        
                CREATE tt-nota.
                ASSIGN tt-nota.nro-docto    = int_ds_docto_xml.nnf 
                       tt-nota.serie-nota   = c-serie-devol
                       tt-nota.serie-docum  = c-serie-devol
                       tt-nota.nat-operacao = int_ds_docto_xml.nat_operacao                                    
                       tt-nota.cod-emitente = emitente.cod-emitente
                       tt-nota.situacao     = 2.
                
                FIND FIRST natur-oper WHERE 
                           natur-oper.nat-operacao = int_ds_docto_xml.nat_operacao NO-ERROR.
                                                            
                CREATE tt-docum-est.
                assign tt-docum-est.nro-docto    = tt-nota.nro-docto
                       tt-docum-est.cod-emitente = tt-nota.cod-emitente
                       tt-docum-est.serie-docto  = tt-nota.serie-nota 
                       tt-docum-est.char-2       = tt-nota.serie-docum /* Serie documento principal */
                       tt-docum-est.nat-operacao = int_ds_docto_xml.nat_operacao                              
                       tt-docum-est.cod-observa  = if natur-oper.log-2 then 2 /* Comercio */ else 1  /* Industria*/
                       tt-docum-est.cod-estabel  = int_ds_docto_xml.cod_estab
                       tt-docum-est.estab-fisc   = int_ds_docto_xml.cod_estab
                       tt-docum-est.estab-de-or  = int_ds_docto_xml.estab_de_or  
                       tt-docum-est.usuario      = "super"
                       tt-docum-est.uf           = emitente.estado 
                       tt-docum-est.via-transp   = 1
                       tt-docum-est.dt-emis      = TODAY   
                       tt-docum-est.dt-trans     = TODAY                          
                       tt-docum-est.nff          = no                              /**** Nota fiscal de Fatura ***/
                       tt-docum-est.observacao   = "Devolu»’o nota : " + int_ds_docto_xml.nnf + "/" + int_ds_docto_xml.serie 
                       tt-docum-est.valor-mercad = 0 
                       tt-docum-est.tot-valor    = int_ds_pedido.ped_valortotalbruto_n
                       tt-docum-est.conta-transit = param-estoq.conta-fornec
                       OVERLAY(tt-docum-est.char-1,93,60)  = IF int_ds_docto_xml.chNfe = ? THEN "" ELSE int_ds_docto_xml.chNfe
                       OVERLAY(tt-docum-est.char-1,192,16) = "" /* Aviso de recolhimento */     
                       tt-docum-est.esp-docto     = 21.
            END.
            
            IF AVAIL tt-nota THEN DO:

                 FIND FIRST tt-docum-est NO-ERROR.  
                 
                 FIND FIRST int-ds-it-docto-xml NO-LOCK WHERE
                            int-ds-it-docto-xml.nnf          = int_ds_docto_xml.nnf           AND 
                            int-ds-it-docto-xml.serie        = int_ds_docto_xml.serie         AND
                            int-ds-it-docto-xml.tipo-nota    = int_ds_docto_xml.tipo_nota     AND
                            int-ds-it-docto-xml.cod-emitente = int_ds_docto_xml.cod_emitente  AND 
                            int-ds-it-docto-xml.it-codigo    = string(int_ds_pedido_produto.ppr_produto_n) NO-ERROR.
                 IF AVAIL int-ds-it-docto-xml THEN DO:
                 
                     for first item fields (it-codigo tipo-con-est) no-lock where 
                         item.it-codigo = int-ds-it-docto-xml.it-codigo: end.
                     CREATE tt-item-doc-est.
                     ASSIGN tt-item-doc-est.serie-docto    = tt-docum-est.serie-docto
                            tt-item-doc-est.char-2         = tt-nota.serie-nota       /* Serie documento principal */
                            tt-item-doc-est.nro-docto      = tt-docum-est.nro-docto
                            tt-item-doc-est.cod-emitente   = tt-docum-est.cod-emitente
                            tt-item-doc-est.nat-operacao   = tt-docum-est.nat-operacao
                            tt-item-doc-est.sequencia      = int-ds-it-docto-xml.sequencia
                            tt-item-doc-est.it-codigo      = int-ds-it-docto-xml.it-codigo
                            tt-item-doc-est.lote           = if item.tipo-con-est = 3 /* lote */ then c-numero-lote else ""
                            tt-item-doc-est.num-pedido     = int-ds-it-docto-xml.num-pedido    
                            tt-item-doc-est.numero-ordem   = int-ds-it-docto-xml.numero-ordem
                            tt-item-doc-est.numero-ordem   = 0
                            tt-item-doc-est.parcela        = 0.
                          
                     find first item no-lock where
                                item.it-codigo = int-ds-it-docto-xml.it-codigo no-error. 

                     FIND FIRST item-uni-estab NO-LOCK WHERE
                                item-uni-estab.cod-estabel = int_ds_docto_xml.cod_estab AND
                                item-uni-estab.it-codigo   = int-ds-it-docto-xml.it-codigo NO-ERROR.
                     IF AVAIL item-uni-estab THEN
                        ASSIGN c-cod-depos = item-uni-estab.deposito-pad.
                     ELSE 
                        ASSIGN c-cod-depos = item.deposito-pad.
                       
                     assign tt-item-doc-est.encerra-pa     = no
                            tt-item-doc-est.log-1          = NO /* FIFO */ 
                            tt-item-doc-est.parcela        = 0
                            tt-item-doc-est.nr-ord-prod    = 0
                            tt-item-doc-est.cod-roteiro    = ""
                            tt-item-doc-est.op-codigo      = 0
                            tt-item-doc-est.item-pai       = ""
                            tt-item-doc-est.baixa-ce       = YES 
                            tt-item-doc-est.quantidade     = int_ds_pedido_produto.ppr_quantidade_n
                            tt-item-doc-est.pre-uni[1]     = int_ds_pedido_produto.ppr_valorbruto_n 
                            tt-item-doc-est.cod-depos      = c-cod-depos
                            tt-item-doc-est.class-fiscal   = item.class-fiscal
                            tt-item-doc-est.preco-total[1] = tt-item-doc-est.pre-uni[1] * tt-item-doc-est.quantidade.    
    
                     IF ITEM.tipo-contr = 4 THEN DO:
                        IF AVAIL item-uni-estab THEN
                           ASSIGN tt-item-doc-est.conta-contabil = item-uni-estab.conta-aplicacao.
                        ELSE 
                           ASSIGN tt-item-doc-est.conta-contabil = ITEM.conta-aplicacao.
                     END.
                     ELSE 
                       ASSIGN tt-item-doc-est.conta-contabil = "".

                 END.
              END.
            
        END.
          
        FIND FIRST tt-nota NO-ERROR.

        FOR EACH int_ds_doc_erro WHERE
                 int_ds_doc_erro.serie_docto  = tt-nota.serie-nota   AND 
                 int_ds_doc_erro.cod_emitente = tt-nota.cod-emitente AND
                 int_ds_doc_erro.nro_docto    = tt-nota.nro-docto    AND
                 int_ds_doc_erro.tipo_nota    = tt-nota.tipo-nota   :

            DELETE int_ds_doc_erro.

        END.

        FIND FIRST docum-est NO-LOCK WHERE
                   docum-est.nro-docto    =  tt-nota.nro-docto    AND
                   docum-est.serie        =  tt-nota.serie-nota   AND
                   docum-est.tipo-nota    =  tt-nota.tipo-nota    AND
                   docum-est.nat-operacao =  tt-nota.nat-operacao AND
                   docum-est.cod-emitente =  tt-nota.cod-emitente NO-ERROR.
        IF NOT AVAIL docum-est 
        THEN DO:

            RUN intprg/int002e.p(INPUT TABLE tt-nota,
                                 INPUT TABLE tt-docum-est,
                                 INPUT TABLE tt-item-doc-est).
                
            FOR EACH int_ds_doc_erro WHERE
                     int_ds_doc_erro.serie_docto  = tt-nota.serie-nota     AND
                     int_ds_doc_erro.cod_emitente = tt-nota.cod-emitente   AND
                     int_ds_doc_erro.nro_docto    = tt-nota.nro-docto      AND
                     int_ds_doc_erro.tipo_nota    = tt-nota.tipo-nota  :
                                   
                 assign i-erro = 22 
                        c-informacao = "Estab.: " + c-cod-estabel + " - " + "Pedido: " + c-nr-pedcli + " - " +
                                       "Natur. Oper.: " + c-natur + " - " + "Item: " + c-it-codigo + " - " +
                                       "Cod. Erro: " + string(int_ds_doc_erro.cod_erro) + " - " +  
                                       int_ds_doc_erro.descricao
                        l-movto-com-erro = yes.
                 run gera-log. 
                 return.    
            END.
        END.
        

        IF l-movto-com-erro = NO 
        THEN DO:
        
            FIND FIRST tt-docum-est NO-ERROR. 
           
            FIND FIRST docum-est NO-LOCK WHERE
                       docum-est.nro-docto    =  tt-docum-est.nro-docto    AND
                       docum-est.serie        =  tt-docum-est.serie        AND
                       docum-est.tipo-nota    =  tt-docum-est.tipo-nota    AND
                       docum-est.nat-operacao =  tt-docum-est.nat-operacao AND
                       docum-est.cod-emitente =  tt-docum-est.cod-emitente NO-ERROR.
            IF AVAIL docum-est THEN DO:
                    
                /* IF docum-est.char-1 = ? THEN docum-est.char-1 */

               IF docum-est.ce-atual = NO 
               THEN DO:
                   RUN pi-atualizaDocumento.
                   
                   IF l-movto-com-erro = NO 
                   THEN DO:
                        FIND FIRST tt-docto-xml NO-ERROR.

                        FIND FIRST int_ds_docto_xml NO-LOCK WHERE
                                   int_ds_docto_xml.nnf   = tt-docto-xml.nnf   AND 
                                   int_ds_docto_xml.serie = tt-docto-xml.serie AND
                                   int_ds_docto_xml.cod_emitente = tt-docto-xml.cod_emitente AND 
                                   int_ds_docto_xml.nat_operacao = tt-docto-xml.nat_operacao AND 
                                   int_ds_docto_xml.tipo_nota    = tt-docto-xml.tipo_nota NO-ERROR.
                        IF NOT AVAIL int_ds_docto_xml 
                        THEN DO:
                        
                            FOR EACH tt-it-docto-xml:
        
                                CREATE int-ds-it-docto-xml.
                                BUFFER-COPY tt-it-docto-xml TO int-ds-it-docto-xml.
        
                            END.
        
                            FOR EACH tt-docto-xml:
        
                                CREATE int_ds_docto_xml.
                                BUFFER-COPY tt-docto-xml TO int_ds_docto_xml.
                                   /* ASSIGN int_ds_docto_xml.id_sequencial = ?.*/
                                /*ASSIGN int_ds_docto_xml.id_sequencial = NEXT-VALUE(seq-int_ds_docto_xml) /* Prepara‡Æo para integra‡Æo com Procfit */*/
                                .
        
                            END.
                        END.
                   END.

               END.
            END.

        END.

       END.

END PROCEDURE.

PROCEDURE pi-atualizaDocumento:

/*------------------------------------------------------------------------------
*     Notes: Faz a atualiza¯Êo do documento com base no TT-DOCUM-EST
*
 ------------------------------------------------------------------------------*/
    EMPTY TEMP-TABLE tt-arquivo-erro.
    EMPTY TEMP-TABLE tt-erro-nota.
              
    for each tt-digita-re:
        delete tt-digita-re.
    end.

    for each tt-param-re:
        delete tt-param-re.
    end.
    
   find first usuar_mestre no-lock
        where usuar_mestre.cod_usuario = "" /* c-seg-usuario */ no-error.
    
    create tt-param-re.
    assign tt-param-re.usuario         =  c-seg-usuario 
           tt-param-re.destino         = 2
           tt-param-re.data-exec       = today
           tt-param-re.hora-exec       = time
           tt-param-re.arquivo         = if avail usuar_mestre and usuar_mestre.nom_dir_spool <> "" then 
                                      (usuar_mestre.nom_dir_spool + "/")
                                      else session:temp-directory
           tt-param-re.arquivo         = tt-param-re.arquivo + "RE1005" + ".txt":U.
    
                                      
    for each tt-raw-digita-re:
        delete tt-raw-digita-re.
    end.

    create tt-digita-re.
    assign tt-digita-re.r-docum-est = rowid(DOCUM-EST).
    
    raw-transfer tt-param-re  to raw-param.

    for each tt-digita-re:
        create tt-raw-digita-re.
        raw-transfer tt-digita-re to tt-raw-digita-re.raw-digita.
    end.
    
    if  session:set-wait-state("GENERAL":U) THEN
        run rep/re1005rp.p (input raw-param, input table tt-raw-digita-re). 
   
    INPUT FROM value(tt-param-re.arquivo) CONVERT TARGET "iso8859-1".
    
        REPEAT:
           IMPORT UNFORMATTED c-linha.
            
           CREATE tt-arquivo-erro.
           ASSIGN tt-arquivo-erro.c-linha = c-linha.
        
        END.

        FOR EACH tt-arquivo-erro WHERE
                 LENGTH(tt-arquivo-erro.c-linha) > 0:
        
            IF tt-arquivo-erro.c-linha BEGINS "-" THEN NEXT. 
        
            ASSIGN c-nr-nota  = "".
               
            DO i-cont = 1 TO 7:    
        
               DO i-pos-arq = 0 TO 10:
        
                  IF SUBSTRING(SUBSTRING(tt-arquivo-erro.c-linha,7,7),i-cont,1) = STRING(i-pos-arq) THEN 
                     ASSIGN c-nr-nota = c-nr-nota + STRING(i-pos-arq).
        
               END.
        
            END.
        
            IF c-nr-nota = "" AND 
               SUBSTRING(tt-arquivo-erro.c-linha,53,90) = "" THEN NEXT.
            
            FIND LAST tt-erro-nota NO-ERROR.

            IF c-nr-nota <> "" THEN DO:
               CREATE tt-erro-nota.
               ASSIGN tt-erro-nota.serie         = SUBSTRING(tt-arquivo-erro.c-linha,1,3)
                      tt-erro-nota.nro-docto     = c-nr-nota
                      tt-erro-nota.cod-emitente  = int(SUBSTRING(tt-arquivo-erro.c-linha,24,9)) 
                      tt-erro-nota.cod-erro      = int(SUBSTRING(tt-arquivo-erro.c-linha,44,6)).
            END.

            IF AVAIL tt-erro-nota THEN
               ASSIGN tt-erro-nota.descricao  = tt-erro-nota.descricao + SUBSTRING(tt-arquivo-erro.c-linha,53,90).
        END.

        FOR EACH tt-erro-nota WHERE
                 tt-erro-nota.serie         =  docum-est.serie        AND
                 tt-erro-nota.nro-docto     =  c-nr-nota              AND          
                 tt-erro-nota.cod-emitente  =  docum-est.cod-emitente AND                    
                  tt-erro-nota.cod-erro <> 4070 AND
                  tt-erro-nota.cod-erro <> 11010
            BREAK BY tt-erro-nota.cod-erro:
          
             assign i-erro = 18
                    c-informacao = "Docto.: " + tt-erro-nota.nro-docto + " - " + 
                                   "S‚rie: " + tt-erro-nota.serie + " - " + 
                                   "Cod. Erro: " + STRING(tt-erro-nota.cod-erro) + " - " +
                                   tt-erro-nota.descricao.

                   l-movto-com-erro = yes.
                   run gera-log.

            IF LAST (tt-erro-nota.cod-erro) THEN
               RETURN.
        END.

 
END PROCEDURE.

/* FIM DO PROGRAMA */







