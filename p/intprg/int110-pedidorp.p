/************************************************************************************
** Programa: INT110-10RP.P - Faturamento de Pedidos CD->Lojas do Tutorial/Sysfarma

************************************************************************************/

/* include de controle de versao */
{include/i-prgvrs.i int110-10rp 1.00.01.KML}

/* definiçao das temp-tables para recebimento de parametros */

define temp-table tt-param no-undo
    field destino          as integer
    field arquivo          as char format "x(35)"
    field usuario          as char FORMAT "x(12)"
    field data-exec        as date
    field hora-exec        as integer
    field classifica       as integer
    field desc-classifica  as char format "x(40)"
    field pedido-ini       as INTEGER
    field pedido-fim       as INTEGER.

def temp-table tt-raw-digita
        field raw-digita	as raw.

def temp-table tt-ped-venda-imp         like ped-venda.
def temp-table tt-ped-item-imp          like ped-item  
    field numero-caixa like cst_ped_item.numero_caixa
    field numero-lote  like cst_ped_item.numero_lote
    /*
    field ct-codigo    like item.ct-codigo
    field sc-codigo    like item.sc-codigo
    */
    .
def temp-table tt-ped-repre-imp         like ped-repre.

&global-define log-erro     "ERRO"
&global-define log-erro-api "ERRO API"
&global-define log-adv      "ADVERT"
&global-define log-info     "INFO"

/* temp-tables das API's e BO's */
{method/dbotterr.i}

def var h-bodi317pr         as handle no-undo.
def var h-bodi317sd         as handle no-undo.
def var h-bodi317im1bra     as handle no-undo.
def var h-bodi317va         as handle no-undo.
def var h-bodi317in         as handle no-undo.
def var h-bodi317ef         as handle no-undo.
def var h-boin404te         as handle no-undo.
def var h-bodi515           as handle no-undo.

def var i-seq-wt-docto      as int    no-undo.
def var i-seq-wt-it-docto   as int    no-undo.
def var i-seq-wt-it-last    as int    no-undo.
def var c-ultimo-metodo-exec as char  no-undo.
def var l-proc-ok-aux        as log    no-undo.
def var l-movto-com-erro     as logical init no no-undo.
DEF VAR c-prog-log           AS CHAR NO-UNDO.
DEF VAR tipo_pedido          AS CHAR NO-UNDO.

def temp-table tt-notas-geradas no-undo
    field rw-nota-fiscal   as rowid
    field nr-nota        like nota-fiscal.nr-nota-fis
    field seq-wt-docto   like wt-docto.seq-wt-docto.

def var c-docto-orig         as character.
def var c-obs-gerada         as character.

/* recebimento de parametros */
def input parameter raw-param as raw no-undo.
def input parameter table for tt-raw-digita.  

create tt-param.                    
raw-transfer raw-param to tt-param no-error. 
IF tt-param.arquivo = "" THEN 
    ASSIGN tt-param.arquivo = SESSION:TEMP-DIRECTORY + "int110-10.txt"
           tt-param.destino = 3
           tt-param.data-exec = TODAY
           tt-param.hora-exec = TIME.
           
           



DEFINE VARIABLE i-cont-pedidos AS INTEGER     NO-UNDO.

ASSIGN i-cont-pedidos = 0.
//{intprg/int110rp.i}

/*************************************************************************************
**
**  int110rp.1 - L¢gica principal dos programas int110-10rp.p, int110-11rp.p,
**               int110-12rp.p, int110-13rp.p e int110-14rp.p 
**
*************************************************************************************/

/* include padrao para vari veis de relat¢rio  */
{include/i-rpvar.i}

DEF TEMP-TABLE tt-erro-nota NO-UNDO
    FIELD cod-erro     AS INTEGER FORMAT ">>>>>9"
    FIELD descricao    AS CHAR.

DEF NEW SHARED TEMP-TABLE tt-item-st-aux NO-UNDO
    FIELD it-codigo     AS CHAR
    FIELD quantidade    AS DEC
    FIELD preco         AS DEC
    FIELD l-item-criado AS LOG
    FIELD r-rowid       AS ROWID.

DEF NEW SHARED TEMP-TABLE tt-item-nfs-ds-retorno NO-UNDO
    FIELD nr-sequencia       AS INT
    FIELD seq-wt-docto       AS INT
    FIELD seq-wt-it-docto    AS INT
    FIELD nsa_cnpj_origem_s  AS CHAR
    FIELD nsa_cnpj_destino_s AS CHAR
    FIELD nsa_notafiscal_n   AS INT
    FIELD nsa_serie_s        AS CHAR
    FIELD ped_codigo_n       AS INT
    FIELD nsp_produto_n      AS INT
    FIELD nsp_lote_s         AS CHAR
    FIELD nsp_caixa_n        AS INT
    FIELD nsp_sequencia_n    AS INT
    FIELD rpp_validade_d     AS DATE
    INDEX id IS PRIMARY seq-wt-docto seq-wt-it-docto
    INDEX seq nr-sequencia.

DEF BUFFER bf-esp-item-entr-st FOR esp-item-entr-st.
DEF BUFFER b-item FOR ITEM.
DEFINE VARIABLE p-l-ok AS LOGICAL     NO-UNDO.

/*DEF TEMP-TABLE tt-aux
    FIELD r-pedido AS ROWID.*/

/* ++++++++++++++++++ (Definicao Stream) ++++++++++++++++++ */

/* ++++++++++++++++++ (Definicao Buffer) ++++++++++++++++++ */
def buffer b-natur-oper for natur-oper.
DEF BUFFER b-loc-entr   FOR loc-entr.
DEF BUFFER b-int_ds_pedido FOR int_ds_pedido.

/* definiçao de variáveis  */
def var h-acomp             as handle no-undo.

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
def var de-preco             like ems2dis.preco-item.preco-venda.
def var de-preco-liq         like ped-item.vl-preuni.
def var c-cod-refer          as char.
def var c-cod-entrega        as char.
def var c-cidade-cif         as char.
def var c-redespacho         as char.
def var c-cod-rota           as char.
def var i-nr-registro        as integer init 0.
def var c-informacao         as char format "x(256)".
def var i-erro               as integer init 0.
def var r-registro           as recid no-undo.
def var l-confirma           as logical no-undo format "Sim/Nao".
def var d-dt-emissao         as date.
def var d-dt-entrega         as date.
def var d-dt-implantacao     as date.
def var i-nr-sequencia       as integer.
def var c-placa              as character.
def var c-uf-placa           as character.
def var c-numero-caixa       as character.
def var c-caixa-grupo        as character.
def var c-numero-lote        as character.
def var i-canal-vendas       as integer no-undo.
def var tb-erro              as char format "x(50)" extent 42 init
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
                              "18. Numero do Pedido Interno Ja Cadastrado        ",
                              "19. Pedido de Venda ja FATURADO                   ",
                              "20.*** Pedido de Venda nao Importado ***          ",
                              "21. Natureza de Operacao nao Cadastrada em INT115 ",
                              "22. ERRO BO de Implantacao                        ",
                              "23. Transportador de redespachop NAO Cadastrado   ",
                              "24. Codigo do Cliente p/ Entrega NAO Existe       ",
                              "25. Quantidade de parcelas p/ pagto inconsistente ",
                              "26. Cliente so pode comprar A Vista               ",
                              "27. Cliente esta Suspenso                         ",
                              "28. Emitente NAO cadastrado como cliente/ambos    ",
                              "29. S‚rie Estab. deve ter forma emissÆo AUTOMµTICA",
                              "30. Estabelecimento nao Cadastrado/Fora de Operacao",
                              "31. Canal de vendas nao Cadastrado                ",
                              "32. Nat.Operacao indicada esta Inativa            ",
                              "33. Qtdes lidas # qtdes enviadas - reprocessando  ",
                              "34. Item exige conta aplica‡Æo em CD0138          ",
                              "35. Tabela de Financiamento NAO Cadastrada        ",
                              "36. Item com classificacao fiscal em branco       ",
                              "37. Pedido inconsistente ou sem itens             ",
                              "38. Valor do item zerado                          ",
                              "39. S‚rie nÆo cadastrada em rotas X cliente EQ0513",
                              "40. S‚rie X Estab. de emissÆo deve ser de NFe     ",
                              "41. Observacao da nota ultrapassou 2000 caracteres",
                              "42. Pedido em uso por outro usu rio               "].

def var i-qt-volumes    as integer  format ">>>>9" init 0.
def var i-qt-caixas     as integer.
def var d-pes-liq-tot   as decimal format ">>,>>9.99" no-undo.
def var de-peso-itens   as dec  format ">>>,>>9.99" init 0. 
def var i-cont          as int init 0.
def var de-red-base-ipi as decimal no-undo.
def var de-base-ipi     as decimal no-undo.

def var c-cod-estabel as char initial "1" no-undo.
def var c-nome-abrev as char no-undo.
def var l-ind-icm-ret as logical no-undo.
def var c-uf-destino as char no-undo.
def var c-uf-origem as char no-undo.
def var r-rowid as rowid no-undo.
def var i-cod-portador  as integer no-undo.
def var i-modalidade    as integer no-undo.
def var c-serie         as char no-undo.
def var c-class-fiscal  as char no-undo.
def var c-ct-codigo     as char no-undo.
def var c-sc-codigo     as char no-undo.
def new global shared var c-seg-usuario   as char no-undo.
def var c-aux as char no-undo.
DEF VAR i-tot-item      AS INT NO-UNDO.
DEF VAR i-ped-codigo    AS INT NO-UNDO.
DEF VAR c-nota-fis-mon  AS CHAR NO-UNDO.
DEF VAR c-estab-mon     AS CHAR NO-UNDO.  
DEF VAR c-serie-mon     AS CHAR NO-UNDO.
DEF VAR l-criou-mon-fat AS LOGICAL NO-UNDO.
DEF VAR da-dt_ini_fat   AS DATE NO-UNDO.
DEF VAR i-hr_ini_fat    AS INT NO-UNDO. 
DEF VAR i-ped_codigo_n  AS INT NO-UNDO.
DEF VAR da-dt_ger_ped   AS DATE NO-UNDO.
DEF VAR c-hr_ger_ped    AS CHAR NO-UNDO.

define buffer bemitente for emitente.
define buffer btransporte for transporte.
DEFINE BUFFER bint_ds_pedido FOR int_ds_pedido.

/* definiçao de frames do relatório */
form i-nr-registro    column-label "Sequencia"
     tb-erro[1]       column-label "Mensagem"
     c-informacao     column-label "Conteudo"
     with no-box no-attr-space width 330
     down stream-io frame f-erro.

/* include com a definiçao da frame de cabeçalho e rodapé */
{include/i-rpcab.i}
/* bloco principal do programa */

{utp/utapi019.i}

find first tt-param no-lock no-error.
assign c-programa       = "int110rp.i"
       c-versao         = "2.12"
       c-revisao        = ".01.AVB"
       c-empresa        = "* Nao Definido *"
       c-sistema        = "Pedidos"
       c-titulo-relat   = "Faturamento de Pedidos de Transferˆncia".

/* ----- inicio do programa ----- */
for first param-global no-lock: end.
for mgadm.empresa fields (razao-social) where
    empresa.ep-codigo = param-global.empresa-prin no-lock: end.
assign c-empresa = mgadm.empresa.razao-social.

opcao: 
DO:

   /*run utp/ut-acomp.p persistent set h-acomp.
   run pi-inicializar in h-acomp (input "Processando").*/

   if tt-param.arquivo <> "" then do:
       {include/i-rpout.i}

       view frame f-cabec.
       view frame f-rodape.
   end.
   run elimina-tabelas.
   run importa.

   pause 3 no-message.
   
end.
run elimina-tabelas.
run pi-finaliza-bos.

if tt-param.arquivo <> "" then do:
    /* fechamento do output do relatorio  */
    {include/i-rpclo.i}
end.


RUN intprg/int888.p (INPUT "PED",
                     INPUT c-prog-log).

/*run pi-finalizar in h-acomp.*/

/*return "OK".*/
/* ----- fim do programa -------- */


/* procedures */

procedure elimina-tabelas.

   /*run pi-acompanhar in h-acomp (input "Eliminando Tabelas Temporarias").*/
   /* limpa temp-tables */
   empty temp-table tt-ped-venda-imp.
   empty temp-table tt-ped-repre-imp. 
   empty temp-table tt-ped-item-imp. 
   empty temp-table RowErrors.   
   empty temp-table tt-envio2.
   empty temp-table tt-mensagem.
   empty temp-table tt-notas-geradas.
end.        

procedure importa:
    /*run pi-acompanhar in h-acomp (input "Lendo Pedidos").*/
    
    assign i-nr-registro    = 0.
        
    /* L¢gica para alterar a situa‡Æo dos pedidos para 2 quando j  foram faturados */

    for each int_ds_mod_pedido no-lock where int_ds_mod_pedido.cod_prog_dtsul = "int110",
        each int_ds_tipo_pedido no-lock where int_ds_tipo_pedido.cod_mod_pedido = int_ds_mod_pedido.cod_mod_pedido
         and int_ds_tipo_pedido.log_ativo = yes:       
        
        for each int_ds_pedido NO-LOCK USE-INDEX Situacao where 
                 int_ds_pedido.ped_tipopedido_n = int(int_ds_tipo_pedido.tp_pedido) AND
                 (int_ds_pedido.situacao = 1 OR int_ds_pedido.situacao = 9):
            
            FIND first emitente no-lock USE-INDEX cgc where
                       emitente.cgc = trim(int_ds_pedido.ped_cnpj_destino_s) NO-ERROR. 
            IF not avail emitente then 
               next.

            FIND FIRST nota-fiscal USE-INDEX ch-pedido WHERE
                       nota-fiscal.nome-ab-cli = emitente.nome-abrev AND
                       nota-fiscal.nr-pedcli   = trim(string(int_ds_pedido.ped_codigo_n)) NO-LOCK NO-ERROR. 
            IF AVAIL nota-fiscal THEN DO:
               IF  nota-fiscal.idi-sit-nf-eletro <> 6
               AND nota-fiscal.idi-sit-nf-eletro <> 7 THEN 
               /* avb 19/01/2019 */
               do transaction :
                   FIND FIRST b-int_ds_pedido USE-INDEX Pedido WHERE
                              b-int_ds_pedido.ped_codigo_n = int_ds_pedido.ped_codigo_n exclusive-lock no-wait no-error.
                   IF AVAIL b-int_ds_pedido THEN DO:
                      ASSIGN b-int_ds_pedido.situacao = 2 .
                      RELEASE b-int_ds_pedido.
                   END.
               END.
            END.
        END.
    END.

    bl_pedidos:
    for each int_ds_mod_pedido no-lock where int_ds_mod_pedido.cod_prog_dtsul = "int110",
        each int_ds_tipo_pedido no-lock where int_ds_tipo_pedido.cod_mod_pedido = int_ds_mod_pedido.cod_mod_pedido
         and int_ds_tipo_pedido.log_ativo = yes:

        assign i-nr-registro    = 0.
        for-ped:
        for EACH int_ds_pedido no-lock 
            WHERE int_ds_pedido.situacao = 1 
              AND int_ds_pedido.ped_tipopedido_n = int(int_ds_tipo_pedido.tp_pedido)
              AND INT_ds_pedido.ped_codigo_n >= tt-param.pedido-ini
              AND INT_ds_pedido.ped_codigo_n <= tt-param.pedido-fim
                on error undo, next:
   
             ASSIGN tipo_pedido = STRING(int_ds_pedido.ped_tipopedido_n).


            .MESSAGE INT_ds_pedido.ped_codigo_n 
                VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
            /* RETIRAR FILIAL 320 COM PROBLEMAS */

            EMPTY TEMP-TABLE tt-item-st-aux.

            FOR FIRST estabelec NO-LOCK WHERE estabelec.cod-estabel = "320" AND
                estabelec.cgc = int_ds_pedido.ped_cnpj_destino_s:
                IF int_ds_pedido.ped_codigo_n = 1094800 THEN NEXT for-ped.
            END.



            // KML - Deixar em status auxiliar enquanto fatura
            FIND FIRST b-int_ds_pedido EXCLUSIVE-LOCK
                WHERE ROWID(b-int_ds_pedido) = ROWID(int_ds_pedido) NO-ERROR.

            IF AVAIL b-int_ds_pedido THEN
                ASSIGN b-int_ds_pedido.situacao =  5 .

            RELEASE b-int_ds_pedido.
            /*
            if int_ds_pedido.ped-tipopedido-n <> 1  and
               int_ds_pedido.ped-tipopedido-n <> 8  and
               int_ds_pedido.ped-tipopedido-n <> 37 then next.
            */
    
            /* 19/01/2019 - AVB - diminuir transa‡Æo da emissÆo da nota
            find first b-int_ds_pedido where 
                       b-int_ds_pedido.ped_codigo_n = int_ds_pedido.ped_codigo_n exclusive-lock no-wait no-error.
            if avail b-int_ds_pedido then do:
               assign b-int_ds_pedido.situacao = 9.
            end.
            release b-int_ds_pedido.
            */ 
            /* movido para dentro da trasa‡Æo da nota fiscal - AVB 06/02/2019
            do transaction:
                find first b-int_ds_pedido where 
                           b-int_ds_pedido.ped_codigo_n = int_ds_pedido.ped_codigo_n exclusive-lock no-wait no-error.
                if avail b-int_ds_pedido then do:
                   assign b-int_ds_pedido.situacao = 9.
                   release b-int_ds_pedido.
                end.
            end.
            */
            /*run pi-acompanhar in h-acomp (input "Lendo Pedido: " + string(int_ds_pedido.ped_codigo_n)).*/
            assign  de-preco            = 0 
                    l-movto-com-erro   = no
                    c-observacao        = ""
                    c-placa             = ""
                    c-uf-placa          = "".
    
            assign  c-nr-pedcli         = trim(string(int_ds_pedido.ped_codigo_n))
                    d-dt-implantacao    = today
                    d-dt-entrega        = if int_ds_pedido.ped_dataentrega_d >= today 
                                          then int_ds_pedido.ped_dataentrega_d else today
                    d-dt-emissao        = int_ds_pedido.ped_data_d
                    c-observacao        = if int_ds_pedido.ped_observacao_s <> ? then trim(int_ds_pedido.ped_observacao_s) else ""
                    c-placa             = int_ds_pedido.ped_placaveiculo_s
                    c-uf-placa          = int_ds_pedido.ped_estadoveiculo_s
                    c-docto-orig        = trim(string(int_ds_pedido.ped_codigo_n)).
    
            assign i-nr-registro = i-nr-registro + 1.
            /* processa pedido atual */
            run valida-registro-pedido.
    
    
            assign  c-it-codigo         = ""
                    de-quantidade       = 0
                    de-vl-uni           = 0
                    de-desconto         = 0
                    c-numero-caixa      = ""
                    c-caixa-grupo       = ""
                    c-numero-lote       = ""
                    c-class-fiscal      = ""
                    c-ct-codigo         = ""
                    c-sc-codigo         = ""
                    c-class-fiscal      = "".
    

            MESSAGE l-movto-com-erro
                VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
            if not l-movto-com-erro then
            for each int_ds_pedido_produto no-lock of int_ds_pedido,
                each int_ds_pedido_retorno no-lock of int_ds_pedido_produto
                
                break by int_ds_pedido_retorno.ped_codigo_n
                        by int_ds_pedido_retorno.ppr_produto_n
                          by int_ds_pedido_retorno.rpp_lote_s
                            by int_ds_pedido_retorno.rpp_caixa_n
                on error undo for-ped, next for-ped:
    
                assign l-movto-com-erro = no.  //KML 23/09/2024 - Guilherme Nichele KML
    
                /*if first-of (int_ds_pedido_retorno.rpp-lote-s) then de-quantidade = 0.*/
                if first-of (int_ds_pedido_retorno.rpp_caixa_n) then do:
                    de-quantidade = 0.
                    c-caixa-grupo = string(int_ds_pedido_retorno.rpp_caixa_n).
                end.
                c-aux = if string(int_ds_pedido_retorno.rpp_caixa_n) <> ? then string(int_ds_pedido_retorno.rpp_caixa_n) else "".

                  .MESSAGE "antes" int_ds_pedido_retorno.rpp_quantidade_n SKIP
                          int_ds_pedido_produto.ppr_valorbruto_n
                      VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
                assign  c-it-codigo         = trim(string(int_ds_pedido_produto.ppr_produto_n))
                        de-quantidade       = de-quantidade + int_ds_pedido_retorno.rpp_quantidade_n
                        de-vl-uni           = int_ds_pedido_produto.ppr_valorbruto_n
                        de-desconto         = int_ds_pedido_produto.ppr_percentualdesconto_n
                        c-numero-caixa      = (if c-numero-caixa = ""
                                               then string(c-aux)
                                               else if not c-numero-caixa matches "*" + c-aux + "*"  then c-numero-caixa + "," + string(c-aux)
                                                   else c-numero-caixa)
                        c-numero-lote       = int_ds_pedido_retorno.rpp_lote_s.
    
                
                run valida-registro-item.        
                if l-movto-com-erro then next.
                find first tt-ped-venda-imp use-index ch-pedido where 
                    tt-ped-venda-imp.nome-abrev = c-nome-abrev and
                    tt-ped-venda-imp.nr-pedcli  = c-nr-pedcli no-error.
                if not avail tt-ped-venda-imp then do:
                    run cria-tt-ped-venda-imp.
                    assign i-nr-sequencia = 0.
                end.
                /*if last-of(int_ds_pedido_retorno.rpp-lote-s) then run cria-tt-ped-item-imp.*/
                if last-of(int_ds_pedido_retorno.rpp_caixa_n) then run cria-tt-ped-item-imp.
            end. /* int_ds_pedido_produto */
            for each tt-ped-venda-imp use-index ch-pedido where 
                tt-ped-venda-imp.nome-abrev = c-nome-abrev and
                tt-ped-venda-imp.nr-pedcli  = c-nr-pedcli:
                assign tt-ped-venda-imp.observacoes = c-observacao + " Pedido: " + c-nr-pedcli + if c-numero-caixa <> "" then " Cx: " + c-numero-caixa else "".

                ASSIGN tt-ped-venda-imp.observacoes = SUBSTRING(tt-ped-venda-imp.observacoes,1,1990).
                IF LENGTH(tt-ped-venda-imp.observacoes) >= 2000 THEN DO:
                    assign i-erro = 41
                           c-informacao = "Pedido: " + c-nr-pedcli + "/" + "Nome Abrev.: " + c-nome-abrev + " - " + "CNPJ Origem: " + string(int_ds_pedido.ped_cnpj_origem)
                                        + " - " + "CNPJ Destino: " + string(int_ds_pedido.ped_cnpj_destino)
                           l-movto-com-erro = yes.
                    run gera-log. 
    
                END.
            end.


            for first tt-ped-item-imp: end.
            if not l-movto-com-erro and not avail tt-ped-item-imp then do:
                assign i-erro = 37
                       c-informacao = "Pedido: " + c-nr-pedcli + "/" + "Nome Abrev.: " + c-nome-abrev + " - " + "CNPJ Origem: " + string(int_ds_pedido.ped_cnpj_origem)
                                    + " - " + "CNPJ Destino: " + string(int_ds_pedido.ped_cnpj_destino)
                       l-movto-com-erro = yes.
                run gera-log. 
            end.
            else if not l-movto-com-erro THEN DO: 
                
                .MESSAGE "antes verifica qtd"
                    VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
                run verifica-quantidades.

            END.

           
        
            message c-it-codigo skip l-movto-com-erro
                   VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
           
            run finaliza-pedido.
            
            if not l-movto-com-erro THEN DO:
                ASSIGN i-cont-pedidos = i-cont-pedidos + 1.
    
                IF i-cont-pedidos >= 8 THEN
                    LEAVE bl_pedidos.
            END.

        end. /* int_ds_pedido */
    end. /* int_ds_mod_pedido */
END. /* importa */ 

procedure verifica-quantidades:
    def var i-qt-tt as integer no-undo.
    def var i-qt-ds as integer no-undo.

    for each tt-ped-item-imp no-lock:
        i-qt-tt = i-qt-tt + tt-ped-item-imp.qt-pedida.
    end.
    for each int_ds_pedido_produto fields (ped_codigo_n) no-lock of int_ds_pedido,
        each int_ds_pedido_retorno fields (rpp_quantidade_n) no-lock of int_ds_pedido_produto
        :
        .MESSAGE "depois" int_ds_pedido_retorno.rpp_quantidade_n
                      VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
        i-qt-ds = i-qt-ds + int_ds_pedido_retorno.rpp_quantidade_n.
    end.

    .MESSAGE "i-qt-tt e i-qt-ds" i-qt-tt SKIP i-qt-ds
        VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
        
   
    
   /* if i-qt-tt <> i-qt-ds then do:
        
        assign i-erro       = 33
               c-informacao = "Pedido: " + c-nr-pedcli
                            + " Nome Abrev.: " + c-nome-abrev.
        assign l-movto-com-erro = yes. 
        
        
    
        run gera-log.
    end.  */
end.

procedure finaliza-pedido.
   /*run pi-acompanhar in h-acomp (input "Finalizando Pedido").*/
   if not l-movto-com-erro then do:
      run emite-nota.
   end.
   /* esta altera‡Æo nÆo pode ficar aqui pois expande o escopo da transa‡Æo da nota fiscal permitindo desfazer o processo
   depois de enviado o XML para o SEFAZ - AVB 16/01/2019
   /* se houve erro na emissao, retorna situacao para pendente */
   if l-movto-com-erro then do:
       FIND FIRST b-int_ds_pedido WHERE
                  b-int_ds_pedido.ped_codigo_n = int_ds_pedido.ped_codigo_n exclusive-lock no-wait no-error.
       IF AVAIL b-int_ds_pedido and b-int_ds_pedido.situacao <> 2 and i-erro <> 19 /* jah faturado */ THEN DO:
          ASSIGN b-int_ds_pedido.situacao = 1.
       END.
       RELEASE b-int_ds_pedido.
   end.
   */

   run pi-verifica-erro.
   run elimina-tabelas.
end.

procedure pi-verifica-erro:
    /* se houve erro na emissao, retorna situacao para pendente */
    if l-movto-com-erro then do transaction:
        find b-int_ds_pedido where 
             b-int_ds_pedido.ped_codigo_n = int_ds_pedido.ped_codigo_n exclusive-lock no-wait no-error.
        if avail b-int_ds_pedido and b-int_ds_pedido.situacao > 2 and i-erro <> 19 /* jah faturado */ then do:
           assign b-int_ds_pedido.situacao = 1.
        end.
        release b-int_ds_pedido.

        FOR EACH tt-item-st-aux,
            FIRST esp-item-entr-st EXCLUSIVE-LOCK
            WHERE ROWID(esp-item-entr-st) = tt-item-st-aux.r-rowid:
            ASSIGN esp-item-entr-st.qtd-sdo-final = esp-item-entr-st.qtd-sdo-final + tt-item-st-aux.quantidade.
            DELETE tt-item-st-aux.
        END.
    end.
end.

procedure valida-registro-pedido.
    
    /*run pi-acompanhar in h-acomp (input "Validando Pedido").*/
    
    assign c-cod-estabel = ""
           c-uf-origem   = "".

    for each estabelec 
        fields (cod-estabel estado cidade 
                cep pais endereco bairro ep-codigo) 
        no-lock where
        estabelec.cgc = int_ds_pedido.ped_cnpj_origem_s,
        first cst_estabelec no-lock where 
        cst_estabelec.cod_estabel = estabelec.cod-estabel and
        cst_estabelec.dt_fim_operacao >= d-dt-emissao:
        assign c-cod-estabel = estabelec.cod-estabel.
               c-uf-origem   = estabelec.estado.
        leave.
    end.
    if c-cod-estabel = "" then
    do:
       assign i-erro = 30
              c-informacao = "Pedido: " + c-nr-pedcli + " - " + "CNPJ Origem: " + string(int_ds_pedido.ped_cnpj_origem)
              l-movto-com-erro = yes.
       run gera-log. 
       return.
    end.
    
    assign  c-nome-abrev = ""
            i-cod-emitente = 0
            c-nr-tabpre    = ""
            i-canal-vendas = 0
            i-cod-rep      = 1
            i-cod-cond-pag = 0
            c-cod-transp   = ""
            c-natur        = ""
            c-nome-transp  = ""
            c-redespacho   = ""
            c-uf-destino   = "".

    for first emitente no-lock where
        emitente.cgc = trim(int_ds_pedido.ped_cnpj_destino_s):
        assign  c-nome-abrev   = emitente.nome-abrev
                i-cod-emitente = emitente.cod-emitente
                c-nr-tabpre    = if emitente.nr-tabpre <> "" then emitente.nr-tabpre else ""
                i-canal-vendas = emitente.cod-canal-venda
                i-cod-rep      = if emitente.cod-rep <> 0 
                                 then emitente.cod-rep
                                 else i-cod-rep
                i-cod-cond-pag = if emitente.cod-cond-pag <> 0 then emitente.cod-cond-pag else i-cod-cond-pag
                c-cod-transp   = int_ds_pedido.ped_cnpj_transportadora
                c-uf-destino   = emitente.estado
                c-cod-entrega  = emitente.cod-entrega.

        if c-cod-transp = "" then 
        for first transporte no-lock where 
            transporte.cod-transp = emitente.cod-transp:
            assign  c-nome-transp = transporte.nome-abrev.
        end.
        assign c-redespacho = emitente.nome-tr-red.

        if emitente.ind-cre-cli = 4 then do:
          assign i-erro = 27
                 c-informacao = "Pedido: " + c-nr-pedcli + "/" + "Nome Abrev.: " + c-nome-abrev + " - " + "Emitente: " + string(i-cod-emitente)
                 l-movto-com-erro = yes.
          run gera-log. 
          return.
        end. 

        if emitente.identific = 2 then do:
          assign i-erro = 28
                 c-informacao = "Pedido: " + c-nr-pedcli + "/" + "Nome Abrev.: " + c-nome-abrev + " - " + "Emitente: " + string(i-cod-emitente)
                 l-movto-com-erro = yes.
          run gera-log. 
          return.
        end. 
    end.
    if c-nome-abrev = "" then do:
        assign i-erro = 02
               c-informacao = "Pedido: " + c-nr-pedcli + " - " + "CNPJ Destino: " + string((int_ds_pedido.ped_cnpj_destino))
               l-movto-com-erro = yes.
        run gera-log. 
        return.
    end.

    assign  c-cod-rota    = "".
    /*
    for first estab-cli no-lock where 
        estab-cli.cod-estabel = c-cod-estabel and
        estab-cli.nome-abrev = c-nome-abrev and
        estab-cli.cod-rota <> "":
        assign  c-cod-rota    = estab-cli.cod-rota.
                c-nome-transp = if c-nome-transp = "" then estab-cli.nome-transp else "".
        if estab-cli.cod-entrega <> "" then c-cod-entrega = estab-cli.cod-entrega.
    end.        
    */
    for first loc-entr no-lock where 
        loc-entr.nome-abrev = c-nome-abrev and
        loc-entr.cod-entrega = "PadrÆo":
        assign  c-cod-rota    = loc-entr.cod-rota
                c-nome-transp = if c-nome-transp = "" then loc-entr.nome-transp else "".
        if loc-entr.cod-entrega <> "" then c-cod-entrega = loc-entr.cod-entrega.
    end.

    c-serie = "".
    for first estab-rota-entreg no-lock where 
        estab-rota-entreg.cod-estabel = c-cod-estabel and
        estab-rota-entreg.nome-abrev  = c-nome-abrev  and
        estab-rota-entreg.cod-rota    = c-cod-rota:
        if estab-rota-entreg.cod-livre-2 <> "" then
            c-serie = estab-rota-entreg.cod-livre-2.
    end.
    if c-serie = "" then do:
        assign i-erro = 39
               c-informacao = "Pedido: " + c-nr-pedcli + " - Est: " + c-cod-estabel + " - Cliente: " + c-nome-abrev + " - Rota: " + c-cod-rota
               l-movto-com-erro = yes.
        run gera-log. 
        return.
    end.
    if  c-serie <> "10"
    AND c-serie <> "11"
    AND c-serie <> "12"
    AND c-serie <> "13"
    AND c-serie <> "14" then do:
        l-movto-com-erro = yes.
        return.
    end.
    for first ser-estab no-lock where
        ser-estab.serie = c-serie and
        ser-estab.cod-estabel = c-cod-estabel:
        if ser-estab.forma-emis <> 1 /* autom tica */ then do:
            assign i-erro = 29
                   c-informacao = "Pedido: " + c-nr-pedcli + " - Est: " + c-cod-estabel + " - Cliente: " + c-nome-abrev + " - Rota: " + c-cod-rota + " - S‚rie: " + c-serie
                   l-movto-com-erro = yes.
            run gera-log. 
            return.
        end.
        if not ser-estab.log-nf-eletro /* NFe */ then do:
            assign i-erro = 40
                   c-informacao = "Pedido: " + c-nr-pedcli + " - Est: " + c-cod-estabel + " - Cliente: " + c-nome-abrev + " - Rota: " + c-cod-rota + " - S‚rie: " + c-serie
                   l-movto-com-erro = yes.
            run gera-log. 
            return.
        end.

    end.

    if i-tab-finan = 0 then
      assign i-tab-finan = 1
             i-indice    = 0.
            
    if i-canal-vendas <> 0 then
    do:
       find first ems2dis.canal-venda no-lock where
           canal-venda.cod-canal-venda = i-canal-vendas
           no-error.
       if not avail canal-venda then
       do:
          assign i-erro = 31
                 c-informacao = "Pedido: " + c-nr-pedcli + "/" + "Nome Abrev.: " + c-nome-abrev + " - " +
                                "Canal Venda: " + string(i-canal-vendas) + " - " + "Emitente: " + string(i-cod-emitente)
                 l-movto-com-erro = yes.
          run gera-log. 
          return.
       end.
    end.

    if i-cod-cond-pag <> 0
    then do:
      find cond-pagto where
           cond-pagto.cod-cond-pag = i-cod-cond-pag
           no-lock no-error.
      if not avail cond-pagto then do:
         assign i-erro = 15
                c-informacao = "Pedido: " + c-nr-pedcli + "/" + "Nome Abrev.: " + c-nome-abrev + " - " +
                               "Cond. Pagto.: " + string(i-cod-cond-pag)
                l-movto-com-erro = yes.
         run gera-log. 
         return.
      end.    
      else if cond-pagto.cod-vencto <> 2 /* a vista */ and 
           avail emitente and emitente.ind-cre-cli = 5 /* so a vista */ then
      do:
         assign i-erro = 26
                c-informacao = "Pedido: " + c-nr-pedcli + "/" + "Nome Abrev.: " + c-nome-abrev + " - " +
                               "Cond. Pagto.: " + string(i-cod-cond-pag)
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
                  c-informacao = "Pedido: " + c-nr-pedcli + " - " + 
                                 "Nome Abrev.: " + c-nome-abrev + 
                                 " - " +
                                 "Transp. Redesp.: " + c-redespacho
                  l-movto-com-erro = yes.
           run gera-log. 
           return.
        end.
    end.
end.
      
procedure valida-registro-item.

   /*run pi-acompanhar in h-acomp (input "Validando Itens").*/
   for first item no-lock where
        item.it-codigo = c-it-codigo:
       c-class-fiscal = item.class-fiscal.
       if item.tipo-contr = 1 /* Fisico */ OR item.tipo-contr = 4 /* DDireto */ then
           assign c-ct-codigo = item.ct-codigo
                  c-sc-codigo = item.sc-codigo.
   end.
   if not avail item then do:
      assign i-erro = 9
             c-informacao = "Pedido: " + c-nr-pedcli + "/" + "Nome Abrev.: " + c-nome-abrev + " - " +
                            "Item: " + c-it-codigo 
             l-movto-com-erro = yes.
      run gera-log. 
      return.
   end.
   if c-class-fiscal = "" then do:
       assign i-erro = 36
              c-informacao = "Pedido: " + c-nr-pedcli + "/" + "Nome Abrev.: " + c-nome-abrev + " - " +
                             "Item: " + c-it-codigo 
              l-movto-com-erro = yes.
       run gera-log. 
       return.
   end.
   if avail item and item.cod-obsoleto = 4 then do:
      assign i-erro = 10
             c-informacao = "Pedido: " + c-nr-pedcli + "/" + "Nome Abrev.: " + c-nome-abrev + " - " +
                            "Item: " + c-it-codigo
             l-movto-com-erro = yes.
      run gera-log. 
      return.
   end.     
   if avail item and not item.ind-item-fat then do:
      assign i-erro = 11
             c-informacao = "Pedido: " + c-nr-pedcli + "/" + "Nome Abrev.: " + c-nome-abrev + " - " +
                            "Item: " + c-it-codigo
             l-movto-com-erro = yes.
      run gera-log. 
      return.
   end.     
   if avail item and 
     (item.tipo-contr = 1 /* Fisico */ OR item.tipo-contr = 4 /* DDireto */) and 
      c-ct-codigo = "" then do:
       assign i-erro = 34
              c-informacao = "Pedido: " + c-nr-pedcli + "/" + "Nome Abrev.: " + c-nome-abrev + " - " +
                             "Item: " + c-it-codigo
              l-movto-com-erro = yes.
       run gera-log. 
       return.
   end.

   if dec(de-quantidade) <= 0 then do:
      assign i-erro = 12
             c-informacao = "Pedido: " + c-nr-pedcli + "/" + "Nome Abrev.: " + c-nome-abrev + " - " +
                            "Item: " + c-it-codigo + " - " + 
                            "Qtde.: " + string(de-quantidade)
             l-movto-com-erro = yes.
      run gera-log. 
      return.
   end. 
       
   /*
   /* determina natureza de operacao */
   run intprg/int015a.p ( input "1"              ,
                          input c-uf-destino         ,
                          input c-uf-origem         ,
                          input c-cod-estabel    ,
                          input i-cod-emitente   ,
                          input c-class-fiscal,
                          input 0, /* cst-icms devolucoes */
                          output c-natur         , 
                          output i-cod-cond-pag  , 
                          output i-cod-portador ,
                          output i-modalidade   ,
                          output c-aux        ,
                          output r-rowid,
                          OUTPUT c-natur-ent).
   */
   /* determina natureza de operacao */
   run intprg/int115a.p ( INPUT tipo_pedido   ,
                          input c-uf-destino  ,
                          input c-uf-origem   ,
                          input "" /*nat or*/ ,
                          input i-cod-emitente,
                          input c-class-fiscal,
			              input c-it-codigo   , /* item */
                          INPUT C-COD-ESTABEL , /* estab */
                          output c-natur      ,
                          output c-natur-ent  ,
                          output r-rowid).
                          
                          
    .MESSAGE "apos int115 - "  c-natur
        VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.

   find natur-oper where
        natur-oper.nat-operacao = c-natur 
        no-lock no-error.
   if not avail natur-oper then do:
       assign i-erro = 21
           c-informacao = "Pedido: " + c-nr-pedcli + 
                          " Nome Abrev.: " + c-nome-abrev + " - " + 
                          "UF Destino: " + c-uf-destino + " - " + 
                          "UF Origem: " + c-uf-origem + " - " + 
                          "Estab.: " + C-COD-ESTABEL + " - " + 
                          "Emitente: " + STRING(I-COD-EMITENTE) + " - " +
                          "Class. Fiscal: " + c-class-fiscal + " - " +
                          "Cod Item: " + c-it-codigo
              l-movto-com-erro = yes.
       run gera-log. 
       return.
   end.
   if avail natur-oper and 
      not natur-oper.nat-ativa then do:
       assign i-erro = 32  
              c-informacao = "Pedido: " + c-nr-pedcli + "/" + "Nome Abrev.: " + c-nome-abrev + " - " +
                             "Natur. Oper.: " + c-natur
           l-movto-com-erro = yes.
       run gera-log. 
       return.
   end.
   if (avail natur-oper and not natur-oper.emite-duplic) or i-cod-cond-pag = ? then
       assign i-cod-cond-pag = 0.

   assign l-ind-icm-ret = no.
   if avail natur-oper and natur-oper.subs-trib then
        assign l-ind-icm-ret = yes.

   IF c-cod-estabel = "973" or c-cod-estabel = "977" THEN DO:
       de-vl-uni = 0.
       for first item-uni-estab no-lock where 
           item-uni-estab.it-codigo   = c-it-codigo and
           item-uni-estab.cod-estabel = c-cod-estabel:
           
           IF SUBSTRING(item-uni-estab.char-2,60,1) = "S" THEN             
                assign de-vl-uni = item-uni-estab.preco-ul-ent. 
                
                
           ELSE DO:            
               if c-uf-origem = c-uf-destino then
                   assign de-vl-uni = item-uni-estab.preco-base.
               else
                   assign de-vl-uni = item-uni-estab.preco-ul-ent.
           END.
       end.
   END.
   
   IF c-it-codigo = "1001382"  THEN
   MESSAGE "kleber -c-uf-destino preco base que buscou" SKIP
           c-it-codigo SKIP
           c-uf-origem SKIP
           c-uf-destino SKIP
           c-cod-estabel  SKIP
           de-vl-uni 
       VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.

   if de-vl-uni = 0 then do:
        assign i-erro = 38
               c-informacao = "Pedido: " + c-nr-pedcli + "/" + "Nome Abrev.: " + c-nome-abrev + " - " +
                              "Tab. Pre‡o: " + c-nr-tabpre + " - " + 
                              "Item: " + c-it-codigo
               l-movto-com-erro = yes.
        run gera-log. 
        return.
   end.

   assign de-aliquota-ipi = 0.
   if avail item and 
      item.cd-trib-ipi <> 2 and /* isento */
      item.cd-trib-ipi <> 3     /* outros */
   then 
       assign de-aliquota-ipi = item.aliquota-ipi.
   else 
       assign de-aliquota-ipi = 0.
end.
 
procedure cria-tt-ped-venda-imp.
   /*run pi-acompanhar in h-acomp (input "Criando Pedido").*/

   for first emitente no-lock where
       emitente.cod-emitente = i-cod-emitente: end.
   
   create tt-ped-venda-imp.
   assign tt-ped-venda-imp.cod-estabel    = c-cod-estabel
          tt-ped-venda-imp.nome-abrev     = emitente.nome-abrev
          tt-ped-venda-imp.nr-pedcli      = c-nr-pedcli
          tt-ped-venda-imp.nr-pedrep      = c-nr-pedcli
          tt-ped-venda-imp.cod-emitente   = emitente.cod-emitente
          tt-ped-venda-imp.nr-pedido      = next-value (seq-nr-pedido)
          tt-ped-venda-imp.dt-emissao     = d-dt-emissao
          tt-ped-venda-imp.dt-implant     = d-dt-implantacao
          tt-ped-venda-imp.dt-entrega     = d-dt-entrega
          tt-ped-venda-imp.dt-entorig     = d-dt-entrega
          tt-ped-venda-imp.nat-operacao   = c-natur
          tt-ped-venda-imp.cod-cond-pag   = int(i-cod-cond-pag)
          tt-ped-venda-imp.perc-desco1    = 0  
          tt-ped-venda-imp.perc-desco2    = 0
          tt-ped-venda-imp.nr-tabpre      = c-nr-tabpre
          tt-ped-venda-imp.nr-tab-finan   = i-tab-finan 
          tt-ped-venda-imp.nr-ind-finan   = i-indice    
          tt-ped-venda-imp.tp-pedido      = "1"
          tt-ped-venda-imp.cod-priori     = 0
          tt-ped-venda-imp.local-entreg   = emitente.endereco
          tt-ped-venda-imp.bairro         = emitente.bairro
          tt-ped-venda-imp.cidade         = emitente.cidade
          tt-ped-venda-imp.nome-tr-red    = if avail btransporte 
                                            then btransporte.nome-abrev
                                            else ""
          tt-ped-venda-imp.cond-redespa   = c-cond-redespacho                                         
          tt-ped-venda-imp.inc-desc-txt   = no
          tt-ped-venda-imp.placa          = c-placa
          tt-ped-venda-imp.uf-placa       = c-uf-placa

          tt-ped-venda-imp.cod-canal-venda = if avail canal-venda
                                             then ems2dis.canal-venda.cod-canal-venda
                                             else 0.

   assign tt-ped-venda-imp.ind-tp-frete   = 2 /* FOB */.
   if emitente.cod-entrega <> "" then do:
        assign tt-ped-venda-imp.cod-entrega = emitente.cod-entrega.
   end.
   else do: 
        find first loc-entr no-lock 
            where loc-entr.nome-abrev = emitente.nome-abrev
            no-error.
        if avail loc-entr then
        do:
            assign tt-ped-venda-imp.cod-entrega  = loc-entr.cod-entrega.
            if loc-entr.nome-transp <> "" then assign tt-ped-venda-imp.nome-transp = loc-entr.nome-transp.
            if loc-entr.cod-rota <> "" then assign tt-ped-venda-imp.cod-rota = loc-entr.cod-rota.
            if loc-entr.nom-cidad-cif <> "" then assign c-cidade-cif = loc-entr.nom-cidad-cif
                                                        tt-ped-venda-imp.ind-tp-frete   = 1 /* CIF */.
        end.
        else do:
            assign tt-ped-venda-imp.cod-entrega  = "PadrÆo".
        end.
   end.

   if tt-ped-venda-imp.ind-tp-frete = 1 then /* CIF */
   do:
      assign tt-ped-venda-imp.cidade-cif = if c-cidade-cif <> "" and
                                              c-cidade-cif <> "0" and
                                              c-cidade-cif <> "." 
                                           then c-cidade-cif
                                           else emitente.cidade. 
   end.
                
   assign tt-ped-venda-imp.estado         = emitente.estado
          tt-ped-venda-imp.cep            = emitente.cep
          tt-ped-venda-imp.caixa-postal   = emitente.caixa-postal
          tt-ped-venda-imp.pais           = emitente.pais
          tt-ped-venda-imp.cgc            = emitente.cgc
          tt-ped-venda-imp.ins-estadual   = emitente.ins-estadual
          tt-ped-venda-imp.cod-sit-ped    = 1.
          
   assign tt-ped-venda-imp.cod-portador   = if i-cod-portador <> ? then i-cod-portador else emitente.port-prefer
          tt-ped-venda-imp.modalidade     = if i-modalidade <> ? then i-modalidade else emitente.mod-prefer
          tt-ped-venda-imp.cod-mensagem   = natur-oper.cod-mensagem
          tt-ped-venda-imp.user-impl      = c-seg-usuario
          tt-ped-venda-imp.dt-userimp     = today
          tt-ped-venda-imp.ind-aprov      = no
          tt-ped-venda-imp.quem-aprovou   = " "
          tt-ped-venda-imp.dt-apr-cred    = ?
          tt-ped-venda-imp.cod-des-merc   = if natur-oper.consum-final 
                                            then 2 else 1
          tt-ped-venda-imp.vl-tot-ped     = 0
          tt-ped-venda-imp.vl-liq-ped     = 0
          tt-ped-venda-imp.vl-liq-abe     = 0
          tt-ped-venda-imp.observacoes    = c-observacao + " Pedido: " + c-nr-pedcli + if c-numero-caixa <> "" then " Cx: " + c-numero-caixa else ""
          tt-ped-venda-imp.nome-transp    = c-nome-transp  
          tt-ped-venda-imp.tp-preco       = 1
          tt-ped-venda-imp.tip-cob-desp   = 1
          tt-ped-venda-imp.per-max-canc   = emitente.per-max-canc
          tt-ped-venda-imp.ind-lib-nota   = yes
          tt-ped-venda-imp.completo       = yes
          tt-ped-venda-imp.ind-ent-completa = yes
          tt-ped-venda-imp.cod-sit-aval   = 1
          tt-ped-venda-imp.cod-sit-com    = 1
          tt-ped-venda-imp.cod-sit-ped    = 1
          tt-ped-venda-imp.ind-imp-ped    = 2  /* batch */
          tt-ped-venda-imp.cd-origem      = 3  /* Sistema */
          tt-ped-venda-imp.origem         = 4. /* batch */ 

   for first b-loc-entr no-lock where 
       b-loc-entr.nome-abrev = emitente.nome-abrev:
       assign tt-ped-venda-imp.nome-transp = b-loc-entr.nome-transp
              tt-ped-venda-imp.cod-rota    = b-loc-entr.cod-rota.
       for first int_ds_rota_veic no-lock where
           int_ds_rota_veic.cod_rota = b-loc-entr.cod-rota:
           assign tt-ped-venda-imp.placa    = int_ds_rota_veic.placa
                  tt-ped-venda-imp.uf-placa = int_ds_rota_veic.uf_placa.          
       end.
   end.
end.
 
procedure cria-tt-ped-item-imp.

   /*run pi-acompanhar in h-acomp (input "Criando Itens do Pedido").*/
   assign de-preco = de-vl-uni.
 /*  IF int_ds_pedido_retorno.ppr_produto_n = 43911 THEN DO:
       MESSAGE "1" SKIP
               "int_ds_pedido_retorno.ppr_produto_n - " int_ds_pedido_retorno.ppr_produto_n SKIP
               "de-preco - " de-preco
           VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
   END.*/


   RUN pi-quebra-item-st.

   FOR EACH tt-item-st-aux
       WHERE tt-item-st-aux.it-codigo     = c-it-codigo
       AND   tt-item-st-aux.l-item-criado = NO:
       
       assign i-nr-sequencia               = i-nr-sequencia + 10
              de-quantidade                = tt-item-st-aux.quantidade
              de-preco                     = tt-item-st-aux.preco
              tt-item-st-aux.l-item-criado = YES.


       CREATE tt-item-nfs-ds-retorno.
       ASSIGN tt-item-nfs-ds-retorno.nr-sequencia       = i-nr-sequencia
              tt-item-nfs-ds-retorno.seq-wt-docto       = 0
              tt-item-nfs-ds-retorno.seq-wt-it-docto    = 0
              tt-item-nfs-ds-retorno.nsa_cnpj_origem_s  = int_ds_pedido.ped_cnpj_origem_s
              tt-item-nfs-ds-retorno.nsa_cnpj_destino_s = int_ds_pedido.ped_cnpj_destino_s
              tt-item-nfs-ds-retorno.nsa_notafiscal_n   = 0
              tt-item-nfs-ds-retorno.nsa_serie_s        = ""
              tt-item-nfs-ds-retorno.ped_codigo_n       = int_ds_pedido_retorno.ped_codigo_n  
              tt-item-nfs-ds-retorno.nsp_produto_n      = int_ds_pedido_retorno.ppr_produto_n 
              tt-item-nfs-ds-retorno.nsp_lote_s         = int_ds_pedido_retorno.rpp_lote_s    
              tt-item-nfs-ds-retorno.nsp_caixa_n        = int_ds_pedido_retorno.rpp_caixa_n   
              tt-item-nfs-ds-retorno.nsp_sequencia_n    = 0
              tt-item-nfs-ds-retorno.rpp_validade_d     = int_ds_pedido_retorno.rpp_validade_d.

       create tt-ped-item-imp.
       assign tt-ped-item-imp.nome-abrev   = tt-ped-venda-imp.nome-abrev
              tt-ped-item-imp.nr-pedcli    = tt-ped-venda-imp.nr-pedcli
              tt-ped-item-imp.nr-sequencia = i-nr-sequencia
              tt-ped-item-imp.it-codigo    = c-it-codigo
              tt-ped-item-imp.nat-operacao = c-natur
              tt-ped-item-imp.nr-tabpre    = "" /*c-nr-tabpre*/
              tt-ped-item-imp.qt-pedida    = dec(de-quantidade)
              tt-ped-item-imp.qt-un-fat    = tt-ped-item-imp.qt-pedida
              tt-ped-item-imp.vl-pretab    = de-preco /* preco-item.preco-venda */
              tt-ped-item-imp.vl-preori    = de-preco.
       assign tt-ped-item-imp.des-un-medida = item.un
              tt-ped-item-imp.cod-un        = item.un
              tt-ped-item-imp.ind-icm-ret   = l-ind-icm-ret.
    
       assign tt-ped-item-imp.ct-codigo     = c-ct-codigo
              tt-ped-item-imp.sc-codigo     = c-sc-codigo.
    
       assign tt-ped-item-imp.numero-lote   = c-numero-lote
              tt-ped-item-imp.numero-caixa  = c-caixa-grupo.
    
       assign tt-ped-item-imp.cod-refer    = c-cod-refer.
    
       assign de-preco-liq = de-preco.
       if de-desconto <> 0 then
       do:
          assign de-preco-liq = de-preco * (1 - (de-desconto / 100)).
          assign tt-ped-item-imp.val-pct-desconto-total = de-desconto
                 tt-ped-item-imp.val-desconto-total = (dec(de-quantidade) * de-preco)
                                                * (de-desconto / 100).
          assign tt-ped-item-imp.des-pct-desconto-inform = string(de-desconto)
                 tt-ped-item-imp.per-des-item = de-desconto
                 tt-ped-item-imp.log-usa-tabela-desconto = no.
       end.
       assign de-red-base-ipi = 0 /* base normal */
              de-base-ipi = (de-preco-liq * tt-ped-item-imp.qt-pedida). 
       if avail natur-oper and /* IPI SOBRE O BRUTO */
         substring(natur-oper.char-2,11,1) = "1" then
       do:
          de-base-ipi = (de-preco * tt-ped-item-imp.qt-pedida). 
       end.
       
       /* Aliquota ISS */
       if avail natur-oper and
          natur-oper.tipo = 3 then 
          assign tt-ped-item-imp.dec-2 = item.aliquota-iss
                 tt-ped-item-imp.val-aliq-iss = item.aliquota-iss.
       else 
          assign tt-ped-item-imp.dec-2 = 0
                 tt-ped-item-imp.val-aliq-iss = 0.
    
           /* IPI Diferenciado */
       if item.ind-ipi-dife = no and 
          item.tipo-contr <> 4 then do:
          overlay(tt-ped-item-imp.char-2,01,08) = "".
          assign tt-ped-item-imp.cod-class-fis = "".
       end.       
       else do:
          overlay(tt-ped-item-imp.char-2,01,08) = c-class-fiscal. 
          assign tt-ped-item-imp.cod-class-fis = c-class-fiscal.
       end.       
    
       if avail natur-oper  and
          natur-oper.cd-trib-ipi <> 2 and    /* isento */
          natur-oper.cd-trib-ipi <> 3 then do: /* outros */ 
          if natur-oper.cd-trib-ipi = 4 and /* reduzido */
             item.cd-trib-ipi = 4 then     /* reduzido */
          do:
             assign de-red-base-ipi = natur-oper.perc-red-ipi.
                    de-base-ipi = (de-preco-liq * tt-ped-item-imp.qt-pedida) * 
                                   (1 - (de-red-base-ipi / 100)).
          end. 
       end.
       else do: /* somente tributa se natureza = T/R e item = T/R */
          assign de-aliquota-ipi = 0.
       end.
       
       assign tt-ped-item-imp.vl-preuni    = de-preco-liq
              tt-ped-item-imp.vl-merc-abe  = de-preco-liq * tt-ped-item-imp.qt-pedida 
              tt-ped-item-imp.vl-liq-it    = de-preco-liq * tt-ped-item-imp.qt-pedida
              tt-ped-item-imp.vl-liq-abe   = (de-preco-liq * tt-ped-item-imp.qt-pedida) + 
                                             de-base-ipi * (de-aliquota-ipi / 100)
              tt-ped-item-imp.vl-tot-it    = (de-preco-liq * tt-ped-item-imp.qt-pedida) +
                                             de-base-ipi * (de-aliquota-ipi / 100)
              tt-ped-item-imp.aliquota-ipi = de-aliquota-ipi
              tt-ped-item-imp.tipo-atend   = 1
              tt-ped-item-imp.dt-userimp   = today
              tt-ped-item-imp.user-impl    = c-seg-usuario
              tt-ped-item-imp.dt-entorig   = d-dt-entrega
              tt-ped-item-imp.dt-entrega   = d-dt-entrega
              tt-ped-item-imp.dt-userimp   = today
              tt-ped-item-imp.user-impl    = c-seg-usuario
              tt-ped-item-imp.esp-ped      = 1
              tt-ped-item-imp.ind-componen = 1
              tt-ped-item-imp.tipo-atend   = 02 /* Parcial */
              tt-ped-item-imp.cd-origem    = 3  /* Sistema */
              tt-ped-item-imp.cod-sit-com  = 1
              tt-ped-item-imp.cod-sit-item = 1.
    
       assign substring (tt-ped-item-imp.char-2,56 - length(string(de-base-ipi * (1 + (de-aliquota-ipi / 100)),">>>>>99.99")),10) = 
              string(de-base-ipi * (de-aliquota-ipi / 100) ,">>>>>99.99")
              tt-ped-item-imp.val-ipi = de-base-ipi * (de-aliquota-ipi / 100).
    
       assign tt-ped-item-imp.cod-sit-preco      = 2 /* aprovado */
              tt-ped-item-imp.dat-aprov-preco    = today
              tt-ped-item-imp.desc-lib-preco     = "Pedido Loja"
              tt-ped-item-imp.dat-aprov-preco    = today
              tt-ped-item-imp.cod-sit-com        = 2
              tt-ped-item-imp.dt-lib-cot         = today
              tt-ped-item-imp.motivo-alt-sit-quota = "Pedido Loja"
              tt-ped-item-imp.dt-aprov-cot       = today
              tt-ped-item-imp.user-aprov-cot     = c-seg-usuario
              tt-ped-item-imp.user-lib-cot       = c-seg-usuario.
   END.
end.
 
procedure gera-log.

   /*run pi-acompanhar in h-acomp (input "Listando Erros").*/
   
   
   MESSAGE  "DEntro gera-log" SKIP
            tb-erro[i-erro] SKIP
            tb-erro[1]  SKIP
             c-informacao
       VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.

   if tt-param.arquivo <> "" then do:
      display i-nr-registro
              with frame f-erro. 
           
       display tb-erro[i-erro] @ tb-erro[1]
               c-informacao
               with frame f-erro.
       down with frame f-erro.
   end.
   RUN intprg/int999.p ("PED", 
                        c-nr-pedcli,
                        (trim(tb-erro[i-erro]) + " - " + c-informacao),
                        if int_ds_pedido.situacao = 9 then 2 else int_ds_pedido.situacao, /* 1 - Pendente, 2 - Processado */ 
                        c-seg-usuario ,
                        c-prog-log ).

    /* INICIO - Grava»’o LOG Tabela para a PROCFIT */
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
    /* FIM    - Grava»’o LOG Tabela para a PROCFIT */

   assign c-informacao = " ".
   
   
end.
/* FIM DO PROGRAMA */

procedure emite-nota.

    /*run pi-acompanhar in h-acomp (input "Gerando Nota").*/

    empty temp-table tt-erro-nota.

    for each tt-ped-venda-imp:

        /* Inicializa‡Æo das BOS para C lculo */
        if valid-handle(h-bodi317in) then
            run finalizaBOS in h-bodi317in.
            
        run dibo/bodi317in.p persistent set h-bodi317in.
    
        run inicializaBOS in h-bodi317in(output h-bodi317pr,
                                         output h-bodi317sd,     
                                         output h-bodi317im1bra,
                                         output h-bodi317va).
        
        /* Limpar a tabela de erros em todas as BOS */
        run emptyRowErrors        in h-bodi317in. 
        
        trans-block:
        DO: //TRANSACTION ON ERROR UNDO, LEAVE:

            DO TRANS:
                /* marca pedido para evitar faturamento duplicado - nÆo usar release - manter bloqueado at‚ o final */
                find first b-int_ds_pedido where 
                           b-int_ds_pedido.ped_codigo_n = int_ds_pedido.ped_codigo_n exclusive-lock no-wait no-error.
                if avail b-int_ds_pedido then do:
                   assign b-int_ds_pedido.situacao = 9 no-error.
                   RELEASE b-int_ds_pedido.
                end.
                else do:
                    assign i-erro = 42
                           c-informacao = "Pedido: " + c-nr-pedcli + "/" + "Nome Abrev.: " + c-nome-abrev + " - " + "CNPJ Origem: " + string(int_ds_pedido.ped_cnpj_origem)
                                        + " - " + "CNPJ Destino: " + string(int_ds_pedido.ped_cnpj_destino)
                           l-movto-com-erro = yes.
                    run gera-log.
                    //undo trans-block, 
                        LEAVE trans-block. //return error.
                end.
            END.
            
                   
            ASSIGN i-ped-codigo    = INT(tt-ped-venda-imp.nr-pedcli)
                   l-criou-mon-fat = NO.
            FOR FIRST bint_ds_pedido USE-INDEX Pedido WHERE
                      bint_ds_pedido.ped_codigo_n = i-ped-codigo NO-LOCK :
            END.
            IF AVAIL bint_ds_pedido THEN DO:
               ASSIGN da-dt_ini_fat   = TODAY
                      i-hr_ini_fat    = TIME
                      i-ped_codigo_n  = bint_ds_pedido.ped_codigo_n
                      da-dt_ger_ped   = bint_ds_pedido.dt_geracao
                      c-hr_ger_ped    = bint_ds_pedido.hr_geracao
                      l-criou-mon-fat = YES.
            END.
            run criaWtDocto in h-bodi317sd
                    (input  c-seg-usuario,
                     input  tt-ped-venda-imp.cod-estabel,
                     input  c-serie,
                     input  "",
                     input  tt-ped-venda-imp.nome-abrev,
                     input  "",
                     input  4, /* Complementar */
                     input  120, /* alterar para 120 a fim de evitar res-item */
                     input  /*tt-ped-venda-imp.dt-emissao*/ today,
                     input  0, /* N£mero do embarque */
                     input  tt-ped-venda-imp.nat-operacao,
                     input  tt-ped-venda-imp.cod-canal-venda,
                     output i-seq-wt-docto,
                     output l-proc-ok-aux).
            /* Caso tenha achado algum erro ou advertˆncia, gera tt-erro */
            run pi-erro-nota(h-bodi317sd,'sd'). 
            
            if l-movto-com-erro then do: //undo trans-block, 
                RUN eliminaRegistrosWorkTable IN h-bodi317sd (INPUT i-seq-wt-docto,
                                                              INPUT NO,
                                                              OUTPUT p-l-ok).
                LEAVE trans-block. //return.
            END.
    
            DO TRANS:
                for first wt-docto EXCLUSIVE-LOCK
                    WHERE wt-docto.seq-wt-docto = i-seq-wt-docto:
                    assign  wt-docto.nr-tabpre    = tt-ped-venda-imp.nr-tabpre
                            wt-docto.ind-lib-nota = yes
                            wt-docto.cod-cond-pag = tt-ped-venda-imp.cod-cond-pag
                            wt-docto.cod-entrega  = tt-ped-venda-imp.cod-entrega
                            wt-docto.nome-transp  = tt-ped-venda-imp.nome-transp
                            wt-docto.cod-rota     = tt-ped-venda-imp.cod-rota
                            wt-docto.cond-redespa = tt-ped-venda-imp.cond-redespa
                            wt-docto.cidade-cif   = tt-ped-venda-imp.cidade-cif
                            wt-docto.nome-tr-red  = tt-ped-venda-imp.nome-tr-red
                            wt-docto.placa        = tt-ped-venda-imp.placa
                            wt-docto.uf-placa     = tt-ped-venda-imp.uf-placa
                            wt-docto.observ-nota  = trim(substring(tt-ped-venda-imp.observacoes,1,2000))
                            wt-docto.ind-tp-frete = tt-ped-venda-imp.ind-tp-frete
                            wt-docto.nr-tab-finan = tt-ped-venda-imp.nr-tab-finan
                            wt-docto.nr-ind-finan = tt-ped-venda-imp.nr-ind-finan
                            wt-docto.cod-portador = tt-ped-venda-imp.cod-portador
                            wt-docto.modalidade   = tt-ped-venda-imp.modalidade
                            wt-docto.nr-pedcli    = /*tt-ped-venda-imp.nr-pedcli*/ "".
                END.
            END.
            

            run emptyRowErrors          in h-bodi317sd.
            run emptyRowErrors          in h-bodi317va.
            /*
            run atualizaDadosGeraisNota in h-bodi317sd(input  i-seq-wt-docto,
                                                       output l-proc-ok-aux).

            */
            /* Caso tenha achado algum erro ou advertˆncia, gera tt-erro */
            run pi-erro-nota(h-bodi317sd,'sd'). if l-movto-com-erro then do: //undo trans-block, 
                RUN eliminaRegistrosWorkTable IN h-bodi317sd (INPUT i-seq-wt-docto,
                                                              INPUT NO,
                                                              OUTPUT p-l-ok).
                LEAVE trans-block. //return.
            END.
            
            RUN pi-gera-itens-nota.
            if l-movto-com-erro then do: //undo trans-block, 
                RUN eliminaRegistrosWorkTable IN h-bodi317sd (INPUT i-seq-wt-docto,
                                                              INPUT NO,
                                                              OUTPUT p-l-ok).
                LEAVE trans-block. //return.
            END.

            RUN pi-calcula-nota.
            if l-movto-com-erro then do: //undo trans-block, 
                RUN eliminaRegistrosWorkTable IN h-bodi317sd (INPUT i-seq-wt-docto,
                                                              INPUT NO,
                                                              OUTPUT p-l-ok).
                LEAVE trans-block. //return.
            END.
            
            /*EMPTY TEMP-TABLE tt-aux.*/

            RUN pi-efetiva-nota.
            if l-movto-com-erro then do: //undo trans-block, 
                RUN eliminaRegistrosWorkTable IN h-bodi317sd (INPUT i-seq-wt-docto,
                                                              INPUT NO,
                                                              OUTPUT p-l-ok).
                LEAVE trans-block. //return.
            END.
            
            /* nÆo devem ser feitas altera‡äes ap¢s gerar o XML da nota. 
            Se ocorrer algum erro aqui vai desfazer a nota que j  foi para o SEFAZ - AVB 16/01/2019
            IF l-criou-mon-fat = YES THEN DO:
               IF c-serie-mon <> "30" THEN DO:
                  CREATE cst_monitor_fat.
                  ASSIGN cst_monitor_fat.dt_ini_fat   = da-dt_ini_fat 
                         cst_monitor_fat.hr_ini_fat   = i-hr_ini_fat  
                         cst_monitor_fat.ped_codigo_n = i-ped_codigo_n
                         cst_monitor_fat.dt_ger_ped   = da-dt_ger_ped 
                         cst_monitor_fat.hr_ger_ped   = c-hr_ger_ped  
                         cst_monitor_fat.cod_estabel  = c-estab-mon
                         cst_monitor_fat.serie        = c-serie-mon                    
                         cst_monitor_fat.nr_nota_fis  = c-nota-fis-mon
                         cst_monitor_fat.dt_fim_fat   = TODAY
                         cst_monitor_fat.hr_fim_fat   = TIME
                         cst_monitor_fat.qtde_itens   = i-tot-item.
               END.
            END.
            RELEASE cst_monitor_fat.
            */

            DO TRANS:
                find first b-int_ds_pedido 
                    where b-int_ds_pedido.ped_codigo_n = int_ds_pedido.ped_codigo_n exclusive-lock no-wait no-error.
                /* marca pedido como faturado */
                if avail b-int_ds_pedido and not l-movto-com-erro then do:
                   assign b-int_ds_pedido.situacao = 2 no-error.
                end.
                RELEASE b-int_ds_pedido.
            END.
            
        end.
    end.
    /* Aqui ‚ o lugar certo para fazer altera‡äes posteriores ao envio do XML para o SEFAZ, 
       em OUTRA TRANSA€ÇO NO DB - AVB 16/01/2019 */
    if l-criou-mon-fat = yes then do transaction:
       if c-serie-mon <> "30" then do:
          create cst_monitor_fat.
          assign cst_monitor_fat.dt_ini_fat   = da-dt_ini_fat 
                 cst_monitor_fat.hr_ini_fat   = i-hr_ini_fat  
                 cst_monitor_fat.ped_codigo_n = i-ped_codigo_n
                 cst_monitor_fat.dt_ger_ped   = da-dt_ger_ped 
                 cst_monitor_fat.hr_ger_ped   = c-hr_ger_ped  
                 cst_monitor_fat.cod_estabel  = c-estab-mon
                 cst_monitor_fat.serie        = c-serie-mon                    
                 cst_monitor_fat.nr_nota_fis  = c-nota-fis-mon
                 cst_monitor_fat.dt_fim_fat   = TODAY
                 cst_monitor_fat.hr_fim_fat   = TIME
                 cst_monitor_fat.qtde_itens   = i-tot-item.
       end.
       release cst_monitor_fat.
    end.
    

    /*DO TRANS:
       FOR EACH tt-aux:
           find first b-int_ds_pedido where 
                      rowid(b-int_ds_pedido) = tt-aux.r-pedido exclusive-lock no-wait no-error.
           IF avail b-int_ds_pedido then do:
              assign b-int_ds_pedido.situacao = 2.
           end.
           release b-int_ds_pedido.
       END.
    END.
    EMPTY TEMP-TABLE tt-aux.*/

    run pi-grava-log.
    run elimina-tabelas.
    run finalizaBOS in h-bodi317in.
    RUN pi-finaliza-bos.
    
end.

procedure pi-gera-itens-nota:

    ASSIGN i-tot-item = 0.
    for each tt-ped-item-imp no-lock of tt-ped-venda-imp:

        for first item fields (it-codigo deposito-pad item.cod-localiz)
            no-lock where item.it-codigo = tt-ped-item-imp.it-codigo: end.
        for first item-uni-estab no-lock where 
            item-uni-estab.it-codigo = tt-ped-item-imp.it-codigo and
            item-uni-estab.cod-estabel = tt-ped-venda-imp.cod-estabel: end.

        /* Disponibilizar o registro WT-DOCTO na bodi317sd */
        run localizaWtDocto in h-bodi317sd(input  i-seq-wt-docto,
                                           output l-proc-ok-aux).
             
        /* faturamentos */
        run pi-envios.

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
        run pi-erro-nota(h-bodi317pr,'pr'). if l-movto-com-erro then RETURN.

        /* Valida informa‡äes do item */
        run validaItemDaNota      in h-bodi317va(input  i-seq-wt-docto,
                                                 input  i-seq-wt-it-docto,
                                                 output l-proc-ok-aux).
        /* Caso tenha achado algum erro ou advertˆncia, gera tt-erro */
        run pi-erro-nota(h-bodi317va,'va'). if l-movto-com-erro then return.

        ASSIGN i-tot-item = i-tot-item + 1.

    end. /* tt-ped-item-imp */
    if l-movto-com-erro then return.
end procedure.

procedure pi-envios:
    def var de-qt-utilizada as decimal no-undo.
        
    /* Cria um item para nota fiscal. */
    run criaWtItDocto in h-bodi317sd  (input  ?,
                                       input  "",
                                       input  tt-ped-item-imp.nr-sequencia,
                                       input  tt-ped-item-imp.it-codigo,
                                       input  tt-ped-item-imp.cod-refer,
                                       input  tt-ped-item-imp.nat-operacao,
                                       output i-seq-wt-it-docto,
                                       output l-proc-ok-aux).
    
    FOR EACH tt-item-nfs-ds-retorno
        WHERE tt-item-nfs-ds-retorno.nr-sequencia = tt-ped-item-imp.nr-sequencia
        AND   tt-item-nfs-ds-retorno.seq-wt-docto = i-seq-wt-docto:
        ASSIGN tt-item-nfs-ds-retorno.seq-wt-docto    = i-seq-wt-docto
               tt-item-nfs-ds-retorno.seq-wt-it-docto = i-seq-wt-it-docto.
    END.

     
    
    /* Caso tenha achado algum erro ou advertˆncia, gera tt-erro */
    run pi-erro-nota(h-bodi317sd,'sd'). if l-movto-com-erro then return.


    run WriteUomQuantity in h-bodi317sd 
        (input  i-seq-wt-docto,
         input  i-seq-wt-it-docto,
         input  tt-ped-item-imp.qt-pedida,
         input  tt-ped-item-imp.cod-un,
         output de-quantidade,
         output l-proc-ok-aux).
   
    IF tt-ped-item-imp.vl-preori < 0.01
        THEN ASSIGN tt-ped-item-imp.vl-preori = 0.01.


    
    /* Grava informa‡äes gerais para o item da nota */
    run gravaInfGeraisWtItDocto in h-bodi317sd 
            (input i-seq-wt-docto,
             input i-seq-wt-it-docto,
             input /*tt-ped-item-imp.qt-pedida*/ de-quantidade,
             input tt-ped-item-imp.vl-preori,
             input 0,
             input 0).

    for each wt-it-docto exclusive-lock where 
        wt-it-docto.seq-wt-docto    = i-seq-wt-docto and 
        wt-it-docto.seq-wt-it-docto = i-seq-wt-it-docto:
        
        .MESSAGE "1 Entrou item: " wt-it-docto.it-codigo VIEW-AS ALERT-BOX INFO BUTTONS OK.
        
        assign wt-it-docto.nr-pedcli      = tt-ped-item-imp.nr-pedcli
               wt-it-docto.nr-seq-ped     = /*tt-ped-item-imp.nr-sequencia*/ int(tt-ped-item-imp.numero-caixa).
        if trim(tt-ped-item-imp.numero-lote) <> "" then
            assign wt-it-docto.narrativa  = "LT: " + trim(tt-ped-item-imp.numero-lote).

        /*
        /* resolver erro dos adapters que utilizam qt familia mesmo se marcado para nÆo utilizar */
        ASSIGN wt-it-docto.quantidade[2] = wt-it-docto.quantidade[1]
               wt-it-docto.un[2]         = wt-it-docto.un[1]
               wt-it-docto.fat-qtfam     = NO.
               */
    end.

    for first wt-it-imposto exclusive-lock where 
        wt-it-imposto.seq-wt-docto    = i-seq-wt-docto and 
        wt-it-imposto.seq-wt-it-docto = i-seq-wt-it-docto:
        
        .MESSAGE "2 Entrou item: " wt-it-imposto.seq-wt-it-docto
        VIEW-AS ALERT-BOX INFO BUTTONS OK.
        
        assign wt-it-imposto.ind-icm-ret  = tt-ped-item-imp.ind-icm-ret.
    end.


    /*
    if tt-ped-item-imp.numero-lote <> "" and 
       item.tipo-con-est = 3 /* lote */ then*/ do:
        for each Wt-fat-ser-lote exclusive-lock 
            where  wt-fat-ser-lote.seq-wt-docto    = i-seq-wt-docto 
              and  wt-fat-ser-lote.seq-wt-it-docto = i-seq-wt-it-docto:
            /*DISPLAY wt-fat-ser-lote.it-codigo wt-fat-ser-lote.qt-baixada.*/
            delete wt-fat-ser-lote.
        end.
        
        de-qt-utilizada = /*tt-ped-item-imp.qt-pedida.*/  de-quantidade.
        
        FOR first item-uni-estab no-lock where 
            item-uni-estab.it-codigo = tt-ped-item-imp.it-codigo and
            item-uni-estab.cod-estabel = tt-ped-venda-imp.cod-estabel:

            /*PUT unformmatted tt-ped-item-imp.it-codigo tt-ped-item-imp.qt-pedida de-quantidade  SKIP.*/
            run criaAlteraWtFatSerLote in h-bodi317sd 
                    (input yes,
                     input i-seq-wt-docto,
                     input i-seq-wt-it-docto,
                     input tt-ped-item-imp.it-codigo,
                     input item-uni-estab.deposito-pad,
                     input "",
                     input "" /* if item.tipo-con-est = 3 then tt-ped-item-imp.numero-lote else "" */,
                     input de-qt-utilizada,
                     input 0,
                     input ?,
                     output l-proc-ok-aux).
            de-qt-utilizada = 0.
        end.
        if de-qt-utilizada > 0 then do:
            assign i-erro = 33
                   c-informacao = "Pedido: " + c-nr-pedcli + " Lote: " + tt-ped-item-imp.numero-lote
                   l-movto-com-erro = yes.
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
    run confirmaCalculo          in h-bodi317pr(input  i-seq-wt-docto,
                                                output l-proc-ok-aux).
    run finalizaAcompanhamento   in h-bodi317pr.

    /* Caso tenha achado algum erro ou advertˆncia, gera tt-erro */
    run pi-erro-nota(h-bodi317pr,'pr'). if l-movto-com-erro then return.

end procedure.


procedure pi-efetiva-nota:
    
    for first nota-fiscal no-lock USE-INDEX ch-pedido where 
        nota-fiscal.nr-pedcli = tt-ped-venda-imp.nr-pedcli and
        nota-fiscal.nome-ab-cli = tt-ped-venda-imp.nome-abrev and 
        nota-fiscal.cod-estabel = tt-ped-venda-imp.cod-estabel and 
        nota-fiscal.dt-cancela = ?
 	:
        assign i-erro       = 19
               c-informacao = "Pedido: " + c-nr-pedcli
                            + " Nome Abrev.: " + c-nome-abrev.
        assign l-movto-com-erro = yes.
        run gera-log.
        return error.
    end.
    
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
    run pi-erro-nota(h-bodi317ef,'ef'). 
    if l-movto-com-erro then do:
        delete procedure h-bodi317ef.
        return.
    END.

    /* Busca as notas fiscais geradas */
    run buscaTTNotasGeradas in h-bodi317ef(output l-proc-ok-aux,
                                           output table tt-notas-geradas).

    ASSIGN c-nota-fis-mon = ""
           c-estab-mon    = ""
           c-serie-mon    = "".

    for each tt-notas-geradas:
        for first nota-fiscal exclusive-lock where 
            rowid(nota-fiscal) = tt-notas-geradas.rw-nota-fiscal :
            assign nota-fiscal.docto-orig = c-docto-orig
                   nota-fiscal.obs-gerada = c-obs-gerada
                   nota-fiscal.nr-pedcli  = tt-ped-venda-imp.nr-pedcli
                   /* retornar nota para programa gerados 9999 a fim de 
                   permitir integra‡äes fiscais*/ 
                   nota-fiscal.int-2      = 9999.
           assign i-erro       = 1
                  c-informacao = "Pedido: "    + nota-fiscal.nr-pedcli
                               + " Emitente: " + nota-fiscal.nome-ab-cli
                               + " Est: "      + nota-fiscal.cod-estabel
                               + " Ser: "      + nota-fiscal.serie
                               + " Nota: "     + nota-fiscal.nr-nota-fis.

           ASSIGN c-nota-fis-mon = nota-fiscal.nr-nota-fis
                  c-estab-mon    = nota-fiscal.cod-estabel
                  c-serie-mon    = nota-fiscal.serie.

           IF AVAIL int_ds_pedido THEN DO:
              run gera-log.
              /*CREATE tt-aux.
              ASSIGN tt-aux.r-pedido = ROWID(int_ds_pedido).*/
           END.
        end.
        delete tt-notas-geradas.
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

procedure pi-grava-log:

    for each tt-erro-nota:
        assign i-erro = tt-erro-nota.cod-erro
               c-informacao = tt-erro-nota.descricao.
        run gera-log. 
    end.
    empty temp-table tt-erro-nota.

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
        IF RowErrors.errornumber = 18699 then next. /* aviso */
        /*if RowErrors.errornumber = 18507 then next. /* aviso */*/
        if RowErrors.errorsubtype begins "WARNING" then next. /* aviso */
        if RowErrors.errorsubtype begins "AVISO" then next. /* aviso */

        create tt-erro-nota.
        assign tt-erro-nota.cod-erro = 22
               tt-erro-nota.descricao = "Estab.: " + c-cod-estabel + " Cliente: " + string(i-cod-emitente) + " Pedido: " + c-nr-pedcli + " BO: " 
                              + c-bo + " Natur. Oper.: " + c-natur + " S‚rie: " + c-serie + " Item: " + c-it-codigo + " - " +
                              "Cod. Erro: " + string(RowErrors.errornumber) + " - " + 
                              RowErrors.errordescription
               l-movto-com-erro = yes.

        assign i-erro = tt-erro-nota.cod-erro
               c-informacao = tt-erro-nota.descricao
               l-movto-com-erro = yes.
        run gera-log. 
        return.
    end.
end.



PROCEDURE pi-quebra-item-st:
    DEFINE VARIABLE de-qtd-sdo-aux    AS DECIMAL     NO-UNDO.
    DEFINE VARIABLE de-quantidade-aux AS DECIMAL     NO-UNDO.
    DEFINE VARIABLE de-qtd-st         AS DECIMAL     NO-UNDO.

    DEFINE VARIABLE de-preco-entrada AS DECIMAL     NO-UNDO.
    
    DEFINE VARIABLE l-RegimeEspecial AS LOGICAL     NO-UNDO.

    ASSIGN l-RegimeEspecial = NO. 
    
    FOR FIRST item-uf NO-LOCK
        WHERE item-uf.it-codigo = c-it-codigo,
        FIRST b-item NO-LOCK
            WHERE b-item.it-codigo = item-uf.it-codigo,
        FIRST item-uni-estab NO-LOCK
            WHERE item-uni-estab.it-codigo = c-it-codigo
              AND item-uni-estab.cod-estabel = c-cod-estabel
              AND SUBSTRING(item-uni-estab.char-2,60,1) = "S":
        
        ASSIGN l-RegimeEspecial = YES.                
              
    END. 
    
    IF l-RegimeEspecial = YES THEN DO:
        
        ASSIGN de-quantidade-aux = de-quantidade
               de-qtd-st         = 0.

        .message "validando estabelecimento - " c-cod-estabel
            VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.            
          
        bl_itens:
        FOR EACH esp-item-entr-st NO-LOCK USE-INDEX id-ult-data
            WHERE esp-item-entr-st.cod-item      = item-uf.it-codigo
            AND   esp-item-entr-st.qtd-sdo-final > 0 
            AND   esp-item-entr-st.cod-estab     = c-cod-estabel,
            FIRST item-doc-est NO-LOCK
            WHERE item-doc-est.serie-docto  = esp-item-entr-st.cod-serie       
            AND   item-doc-est.nro-docto    = esp-item-entr-st.cod-docto       
            AND   item-doc-est.nat-operacao = esp-item-entr-st.cod-natur-operac
            AND   item-doc-est.cod-emitente = INT(esp-item-entr-st.cod-emitente)
            AND   item-doc-est.it-codigo    = esp-item-entr-st.cod-item        
            AND   item-doc-est.sequencia    = esp-item-entr-st.num-seq:        
    
            .MESSAGE " ants de-quantidade-aux" de-quantidade-aux skip  "antes esp-item-entr-st.qtd-sdo-final" esp-item-entr-st.qtd-sdo-final VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
    
            IF esp-item-entr-st.qtd-sdo-final > de-quantidade-aux THEN                               
            
           
            
                ASSIGN de-qtd-sdo-aux = de-quantidade-aux.
            ELSE
                ASSIGN de-qtd-sdo-aux = esp-item-entr-st.qtd-sdo-final.
                
                 .MESSAGE "de-quantidade-aux" de-quantidade-aux skip  "esp-item-entr-st.qtd-sdo-final" esp-item-entr-st.qtd-sdo-final VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.

                /*IF c-it-codigo = "43911" THEN
                MESSAGE "3" SKIP
                        "item-doc-est.preco-total[1] - " item-doc-est.preco-total[1] SKIP
                        "item-doc-est.desconto[1] - " item-doc-est.desconto[1] SKIP
                        "item-doc-est.valor-ipi[1] - " item-doc-est.valor-ipi[1] SKIP
                        "item-doc-est.quantidade - " item-doc-est.quantidade SKIP 
                        "item-doc-est.serie-docto  - " item-doc-est.serie-docto  skip 
                        "item-doc-est.nro-docto    - " item-doc-est.nro-docto    skip 
                        "item-doc-est.nat-operacao - " item-doc-est.nat-operacao skip 
                        "item-doc-est.cod-emitente - " item-doc-est.cod-emitente
                    VIEW-AS ALERT-BOX INFORMATION BUTTONS OK. */

                ASSIGN de-preco-entrada =  ROUND((item-doc-est.preco-total[1] - item-doc-est.desconto[1] + item-doc-est.valor-ipi[1]) / item-doc-est.quantidade,2).
            
             IF c-it-codigo = "1001382"  THEN
             MESSAGE "KLEBER - de-preco-entrada"
                      c-it-codigo SKIP
                      de-preco-entrada SKIP
                      de-preco
                 VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
            
            .MESSAGE "de-qtd-sdo-aux" de-qtd-sdo-aux VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
            
            CREATE tt-item-st-aux.
            ASSIGN tt-item-st-aux.it-codigo       = c-it-codigo
                   tt-item-st-aux.quantidade      = de-qtd-sdo-aux
                   tt-item-st-aux.preco           = IF de-preco-entrada = 0 THEN de-preco ELSE de-preco-entrada
                   tt-item-st-aux.l-item-criado   = NO
                   tt-item-st-aux.r-rowid         = ROWID(esp-item-entr-st)
                   de-quantidade-aux              = de-quantidade-aux - de-qtd-sdo-aux
                   de-qtd-st                      = de-qtd-st + de-qtd-sdo-aux.

            FOR FIRST bf-esp-item-entr-st EXCLUSIVE-LOCK
                WHERE ROWID(bf-esp-item-entr-st) = ROWID(esp-item-entr-st):
                ASSIGN bf-esp-item-entr-st.qtd-sdo-final = bf-esp-item-entr-st.qtd-sdo-final - de-qtd-sdo-aux.

                RELEASE bf-esp-item-entr-st.
            END.
/*             IF de-qtd-st < de-quantidade THEN DO:                                                                       */
/*                MESSAGE "2 de-quantidade" de-quantidade VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.                        */
/*                                                                                                                         */
/*                CREATE tt-item-st-aux.                                                                                   */
/*                ASSIGN tt-item-st-aux.it-codigo     = c-it-codigo                                                        */
/*                       tt-item-st-aux.quantidade    = de-quantidade - de-qtd-st                                          */
/*                       tt-item-st-aux.preco         = de-preco                                                           */
/*                       tt-item-st-aux.l-item-criado = NO                                                                 */
/*                       tt-item-st-aux.r-rowid       = ROWID(esp-item-entr-st).                                           */
/*                                                                                                                         */
/*               MESSAGE "3 tt-item-st-aux.quantidade" tt-item-st-aux.quantidade VIEW-AS ALERT-BOX INFORMATION BUTTONS OK. */
/*             END.                                                                                                        */
            .MESSAGE "de-quantidade-aux" de-quantidade-aux SKIP de-qtd-st
                VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
            IF de-quantidade-aux <= 0 THEN LEAVE bl_itens.
        END.

        
        
        .MESSAGE "1 de-qtd-st" de-qtd-st VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
                
        IF de-qtd-st < de-quantidade THEN DO:
        .MESSAGE "2 de-quantidade" de-quantidade VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
        
            CREATE tt-item-st-aux.
            ASSIGN tt-item-st-aux.it-codigo     = c-it-codigo
                   tt-item-st-aux.quantidade    = de-quantidade - de-qtd-st
                   tt-item-st-aux.preco         = de-preco
                   tt-item-st-aux.l-item-criado = NO
                   tt-item-st-aux.r-rowid       = ROWID(esp-item-entr-st).
                   
           .MESSAGE "3 tt-item-st-aux.quantidade" tt-item-st-aux.quantidade VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.        
        END.
    END.
    ELSE DO:
    
    .MESSAGE "3 de-quantidade" de-quantidade VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
        CREATE tt-item-st-aux.
        ASSIGN tt-item-st-aux.it-codigo     = c-it-codigo
               tt-item-st-aux.quantidade    = de-quantidade
               tt-item-st-aux.preco         = de-preco
               tt-item-st-aux.l-item-criado = NO
               tt-item-st-aux.r-rowid       = ?.
    END.
      IF NOT AVAILABLE tt-item-st-aux THEN DO:
         MESSAGE "Erro ao criar item: " c-it-codigo VIEW-AS ALERT-BOX ERROR BUTTONS OK.
         RETURN.
      END.
END PROCEDURE.


DO TRANS:
   FOR FIRST cst_mon_fat_serie :
   END.
   IF AVAIL cst_mon_fat_serie THEN DO:
      ASSIGN cst_mon_fat_serie.serie_10 = NO
             cst_mon_fat_serie.serie_11 = NO
             cst_mon_fat_serie.serie_12 = NO 
             cst_mon_fat_serie.serie_13 = NO 
             cst_mon_fat_serie.serie_14 = NO.
   END.
   RELEASE cst_mon_fat_serie.
END.

RETURN "OK"
