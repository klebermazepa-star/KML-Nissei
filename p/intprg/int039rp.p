/********************************************************************************
** Copyright DATASUL S.A. (1997)
** Todos os Direitos Reservados.
**
** Este fonte e de propriedade exclusiva da DATASUL, sua reproducao
** parcial ou total por qualquer meio, so podera ser feita mediante
** autorizacao expressa.
*******************************************************************************/
{include/i-prgvrs.i int039RP 2.12.00.001 } /* */

&IF "{&EMSFND_VERSION}" >= "1.00" &THEN
    {include/i-license-manager.i int039RP MRE} //corrigido
&ENDIF
 
{include/i_fnctrad.i}
{utp/ut-glob.i}
/********************************************************************************
** Copyright DATASUL S.A. (2004)
** Todos os Direitos Reservados.
**
** Este fonte e de propriedade exclusiva da DATASUL, sua reproducao
** parcial ou total por qualquer meio, so podera ser feita mediante
** autorizacao expressa.
*******************************************************************************/

/****************************************************************************
**
**  Programa: int039RP.P
**
**  Data....: Outubro de 2016
**
**  Autor...: ResultPro 
**
**  Objetivo: Lista Pedidos Balan�o 
**
******************************************************************************/

/*** defini��o de pre-processador ***/
{cdp/cdcfgdis.i} 

DEF TEMP-TABLE tt-balanco NO-UNDO
FIELD ped_tipopedido_n LIKE int_ds_pedido.ped_tipopedido_n
FIELD desc-pedido      AS CHAR.

DEF TEMP-TABLE tt-pedido NO-UNDO LIKE int_ds_pedido
FIELD cod-estab        LIKE estabelec.cod-estabel
FIELD cod-emitente     LIKE emitente.cod-emitente
FIELD desc-sit         AS CHAR
FIELD nr-itens-entrada AS INTEGER
FIELD nr-itens-saida   AS INTEGER.

define temp-table tt-param no-undo
    field destino          as integer
    field arquivo          as char format "x(35)":U
    field usuario          as char format "x(12)":U
    field data-exec        as date
    field hora-exec        as integer
    FIELD dt-periodo-ini   AS DATE FORMAT "99/99/9999"
    FIELD dt-periodo-fim   AS DATE FORMAT "99/99/9999"
    FIELD cod-estabel-ini  AS CHAR format "x(05)"
    FIELD cod-estabel-fim  AS CHAR FORMAT "x(03)"
    FIELD pedido-ini       AS INTEGER FORMAT ">>>>>>>9"
    FIELD pedido-fim       AS INTEGER FORMAT ">>>>>>>9"  
    FIELD rs-tipo          AS INTEGER
    FIELD rs-tipo-ped      AS INTEGER
    FIELD cancelados       AS LOGICAL.

define temp-table tt-digita no-undo
    field ordem            as integer   format ">>>>9":U
    field exemplo          as character format "x(30)":U
    index id ordem.

DEFINE TEMP-TABLE tt-erro NO-UNDO
FIELD ped_codigo_n  LIKE int_ds_pedido.ped_codigo_n
FIELD erro-adv      AS INTEGER
FIELD desc-adv      AS CHAR
FIELD tipo-erro     AS INTEGER
FIELD cod-erro      AS INTEGER
FIELD descricao     AS CHAR.

DEFINE TEMP-TABLE tt-estab NO-UNDO
FIELD cod-estabel     LIKE estabelec.cod-estabel
FIELD cgc             LIKE estabelec.cgc
FIELD dt_fim_operacao LIKE cst_estabelec.dt_fim_operacao.

DEFINE TEMP-TABLE tt-notas-geradas NO-UNDO
FIELD ped_codigo_n  LIKE int_ds_pedido.ped_codigo_n
FIELD nr-nota-fis   LIKE nota-fiscal.nr-nota-fis
FIELD serie         LIKE nota-fiscal.serie
FIELD cod-estabel   LIKE nota-fiscal.cod-estabel
FIELD nat-oepracao  LIKE nota-fiscal.nat-operacao
FIELD dt-emis-nota  LIKE nota-fiscal.dt-emis
FIELD dt-cancel     LIKE nota-fiscal.dt-cancel.

DEF TEMP-TABLE tt-nfe NO-UNDO
FIELD ped_codigo_n LIKE int_ds_pedido.ped_codigo_n
FIELD nro-docto    AS INTEGER
INDEX i-chpedido ped_codigo_n.

DEF TEMP-TABLE tt-nfs NO-UNDO
FIELD ped_codigo_n LIKE int_ds_pedido.ped_codigo_n.

DEF TEMP-TABLE tt-it-nfe NO-UNDO
FIELD ped_codigo_n LIKE  int_ds_pedido.ped_codigo_n
FIELD nro-docto    AS INTEGER
FIELD it-codigo    LIKE  item.it-codigo 
FIELD quantidade   LIKE  int_ds_pedido_retorno.rpp_quantidade_n
FIELD vl-uni       LIKE  item-uni-estab.preco-base
FIELD nr-caixa     AS    CHAR
FIELD lote         LIKE  movto-estoq.lote
FIELD qtd-prs      LIKE int_ds_pedido_retorno.rpp_quantidade_n
FIELD qtd-inv      LIKE int_ds_pedido_retorno.rpp_qtd_inventario_n 
INDEX i-chpedido   ped_codigo_n nro-docto it-codigo.

DEF TEMP-TABLE tt-it-nfs NO-UNDO
FIELD ped_codigo_n LIKE  int_ds_pedido.ped_codigo_n
FIELD it-codigo    LIKE  item.it-codigo 
FIELD quantidade   LIKE  int_ds_pedido_retorno.rpp_quantidade_n
FIELD vl-uni       LIKE  item-uni-estab.preco-base
FIELD nr-caixa     AS    CHAR
FIELD lote         LIKE  movto-estoq.lote
FIELD qtd-prs      LIKE int_ds_pedido_retorno.rpp_quantidade_n
FIELD qtd-inv      LIKE int_ds_pedido_retorno.rpp_qtd_inventario_n.

define buffer bemitente for emitente.
define buffer btransporte for transporte.
DEF BUFFER b-tt-digita             FOR tt-digita.

/*** defini��o de vari�veis locais ***/
DEF VAR h-acomp        AS HANDLE  NO-UNDO.
DEF VAR i-linha        AS INTEGER NO-UNDO.
DEF VAR l-transf       AS LOGICAL NO-UNDO.
DEF VAR l-prod         AS LOGICAL NO-UNDO.
DEF VAR i-seq-item     AS INTEGER NO-UNDO.
DEF VAR c-lista        AS CHAR INITIAL "1,2,3,4,5,6,7,8,9,10".
DEF VAR c-data         AS CHAR    NO-UNDO.
DEF VAR i-cont         AS INTEGER.
DEF VAR i-pos          AS INTEGER.
DEF VAR h-niveis       AS HANDLE  NO-UNDO.
DEF VAR i-cont-ent     AS INTEGER.
DEF VAR i-cont-sai     AS INTEGER.
DEF VAR i-nro-docto     AS INT     NO-UNDO.
DEF VAR i-seq-entrada   AS INT     NO-UNDO.
DEF VAR i-tipo-erro     AS INT     NO-UNDO.
DEF VAR i-erro-adv      AS INT     NO-UNDO.
DEF VAR c-tipo-contr    AS CHAR    NO-UNDO.  
DEF VAR c-cod-obsoleto  AS CHAR    NO-UNDO.
DEF VAR c-cont-contabil AS CHAR    NO-UNDO.

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
def var de-preco             like ems2dis.preco-item.preco-venda.
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
def var tb-erro              as char format "x(50)" extent 44 init
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
                              "28. Nat de Operacao Devolucao exige nota origem",
                              "29. Nota Origem Informada e Nat. Oper. Envio      ",
                              "30. Estabelecimento nao Cadastrado/Fora de Oper.  ",
                              "31. Canal de vendas nao Cadastrado                ",
                              "32. Nat.Operacao indicada esta Inativa            ",
                              "33. Saldo estoque insuficiente p/ envio do lote   ",
                              "34. Natureza de Opera��o deve ser Entrada         ",
                              "35. Tabela de Financiamento NAO Cadastrada        ",
                              "36. Pedido j� foi faturado                        ",
                              "37. Pedido inconsistente ou sem itens             ",
                              "38. Valor do item zerado                          ",
                              "39. Documento Pendente ou n�o cadastrado no int002",
                              "40. Natureza de Opera��o deve ser de entrada NFE",
                              "41. Nota Deve ser autorizada pelo SEFAZ",
                              "42. Classifica�ao Fiscal Do item n�o cadastrada",
                              "43. Natureza de Opera��o deve estar marcada para gerar faturamento",
                              "44. Item Parametrizado como d�bito direto."].

def var i-qt-volumes    as integer  format ">>>>9" init 0.
def var i-qt-caixas     as integer.
def var d-pes-liq-tot   as decimal format ">>,>>9.99" no-undo.
def var de-peso-itens   as dec  format ">>>,>>9.99" init 0. 
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
                   
DEF VAR c-nome-emit AS CHAR NO-UNDO.
def var c-saida     as char format "x(40)" no-undo.
def var c-estabel   like estabelec.nome    no-undo.
DEF VAR c-desc-docto AS CHAR NO-UNDO.

def temp-table tt-raw-digita NO-UNDO
    field raw-digita as raw.

def input param raw-param as raw no-undo.
def input param table for tt-raw-digita.

create tt-param.
raw-transfer raw-param to tt-param.

{include/i-rpvar.i}

form   
    skip (04)
    "SELE��O"  at 10  skip(01)
    tt-param.dt-periodo-ini    label "Per�odo."         at 30 "|<    >|" at 50
    tt-param.dt-periodo-fim    no-label                 at 63 skip(1)
    "PAR�METROS" at 10 skip(1)
    tt-param.cod-estabel-ini label "Estabelecimento"  colon 34 "|<    >|" AT 50
    tt-param.cod-estabel-fim NO-LABEL                          SKIP
    tt-param.rs-tipo        label "Modo Execu��o"     colon 34 skip
    skip(1)
    "IMPRESS�O" at 10  skip(1)
    c-saida label "Destino"                        colon 34  
    tt-param.usuario  label "Usu�rio"              colon 34 
    with side-labels stream-io frame f-resumo.


run utp/ut-acomp.p persistent set h-acomp.

run pi-inicializar in h-acomp (input "Int039 - Lista Pedidos Balan�o").

FIND FIRST param-global NO-LOCK NO-ERROR.
FIND FIRST para-fat     NO-LOCK NO-ERROR.

FIND FIRST ems2mult.empresa NO-LOCK WHERE
                 empresa.ep-codigo = param-global.empresa-prin NO-ERROR.

if avail empresa then 
   assign c-empresa   = string(empresa.ep-codigo) 
          c-estabel   = empresa.razao-social.

{utp/ut-liter.i Pedidos_Balan�o  * r}
assign c-sistema  = return-value.

{include/i-rpout.i} 

/* output to value(tt-param.arquivo) page-size 0 convert target "iso8859-1".
   */

{include/i-rpcab.i}

view frame f-cabec.
view frame f-rodape.

EMPTY TEMP-TABLE tt-estab.
EMPTY TEMP-TABLE tt-pedido.
EMPTY TEMP-TABLE tt-balanco.
EMPTY TEMP-TABLE tt-notas-geradas.

for each int_ds_mod_pedido no-lock where int_ds_mod_pedido.cod_prog_dtsul = "int038",
    each int_ds_tipo_pedido no-lock where int_ds_tipo_pedido.cod_mod_pedido = int_ds_mod_pedido.cod_mod_pedido
     and int_ds_tipo_pedido.log_ativo = yes:
    run pi-cria-balanco(input int(int_ds_tipo_pedido.tp_pedido),
                        input int_ds_tipo_pedido.descricao).
end.

/*
DO i-cont = 1 TO 36:
    CASE i-cont:
        WHEN 3  THEN RUN pi-cria-balanco(INPUT i-cont, INPUT "BALANCO MANUAL FILIAL").
        WHEN 11 THEN RUN pi-cria-balanco(INPUT i-cont, INPUT "BALANCO MANUAL DEPOSITO").
        WHEN 12 THEN RUN pi-cria-balanco(INPUT i-cont, INPUT "BALANCO COLETOR FILIAL").
        WHEN 13 THEN RUN pi-cria-balanco(INPUT i-cont, INPUT "BALANCO COLETOR DEPOSITO").
        WHEN 14 THEN RUN pi-cria-balanco(INPUT i-cont, INPUT "BALANCO MANUAL FILIAL - PERMITE CONSOLIDA��O").  
        WHEN 31 THEN RUN pi-cria-balanco(INPUT i-cont, INPUT "BALANCO MANUAL FILIAL - ESPECIAL(MED. CONTROLADO").  
        WHEN 35 THEN RUN pi-cria-balanco(INPUT i-cont, INPUT "BALANCO GERAL CONTROLADOS DEPOSITO").  
        WHEN 36 THEN RUN pi-cria-balanco(INPUT i-cont, INPUT "BALANCO GERAL CONTROLADOS FILIAL").  
        when 30 THEN RUN pi-cria-balanco(INPUT i-cont, input "BALAN�O CD � ROTATIVO").
    END CASE.
END.
*/

RUN pi-leitura-pedidos.   /* Leitura dos Pedidos */      

/** Impressao dos Pedidos */

FOR EACH tt-pedido,
    FIRST tt-balanco WHERE
          tt-balanco.ped_tipopedido_n = tt-pedido.ped_tipopedido_n
    BY tt-pedido.ped_tipopedido_n
    BY tt-pedido.cod-estab
    BY tt-pedido.dt_geracao:

   FIND FIRST emitente NO-LOCK WHERE
              emitente.cod-emitente = tt-pedido.cod-emitente NO-ERROR.
   IF AVAIL emitente THEN
      ASSIGN c-nome-emit = emitente.nome-emit.
                   
   DISP  tt-pedido.ped_tipopedido_n COLUMN-LABEL "Tipo Ped"
         tt-balanco.desc-pedido     COLUMN-LABEL "Descri��o" FORMAT "X(40)"
         tt-pedido.cod-estab        COLUMN-LABEL "Estab"
         tt-pedido.dt_geracao
         tt-pedido.ped_codigo_n
         tt-pedido.situacao
         tt-pedido.desc-sit     COLUMN-LABEL "Descri��o" FORMAT "x(12)"
         tt-pedido.nr-itens-ent COLUMN-LABEL "Itens Ent" 
         tt-pedido.nr-itens-sai COLUMN-LABEL "Itens Sa�da"
         tt-pedido.cod-emitente COLUMN-LABEL "Fornecedor"
         c-nome-emit         COLUMN-LABEL  "Nome" FORMAT "X(40)" 
         WITH DOWN STREAM-IO WIDTH 333 FRAME f-nfe.
   DOWN WITH FRAME tt-nfe.

   FOR EACH tt-notas-geradas WHERE 
            tt-notas-geradas.ped_codigo_n = tt-pedido.ped_codigo_n:

       DISP tt-notas-geradas.nr-nota-fis   
            tt-notas-geradas.serie         
            tt-notas-geradas.cod-estabel   
            tt-notas-geradas.nat-oepracao  
            tt-notas-geradas.dt-emis-nota
            tt-notas-geradas.dt-cancel
            WITH WIDTH 333 STREAM-IO DOWN FRAME f-notas.
       DOWN WITH FRAME f-notas.
   END.

   FOR EACH tt-nfe WHERE
            tt-nfe.ped_codigo_n = tt-pedido.ped_codigo_n :

       PUT skip(1) "Itens Nota Entrada :" AT 05 SKIP (1).

       FOR EACH tt-it-nfe WHERE
                tt-it-nfe.nro-docto    = tt-nfe.nro-docto AND  
                tt-it-nfe.ped_codigo_n = tt-nfe.ped_codigo_n:

           FOR FIRST ITEM NO-LOCK WHERE
                     ITEM.it-codigo = tt-it-nfe.it-codigo:
           END.

           ASSIGN c-cod-obsoleto = ""
                  c-tipo-contr   = "".

           IF AVAIL ITEM 
           THEN DO:
               CASE ITEM.cod-obsoleto:
                 WHEN 1 THEN ASSIGN c-cod-obsoleto = "Ativo".
                 WHEN 2 THEN ASSIGN c-cod-obsoleto = "Obsoleto Ordens Autom.".
                 WHEN 3 THEN ASSIGN c-cod-obsoleto = "Obsoleto Todas as Ordens".
                 WHEN 4 THEN ASSIGN c-cod-obsoleto = "Totalmente Obsoleto". 
               END.
               
               CASE ITEM.tipo-contr:
                 WHEN 1 THEN ASSIGN c-tipo-contr  = "F�sico".
                 WHEN 2 THEN ASSIGN c-tipo-contr  = "Total".
                 WHEN 3 THEN ASSIGN c-tipo-contr  = "Consignado".
                 WHEN 4 THEN ASSIGN c-tipo-contr  = "D�bito Direto". 
                 WHEN 5 THEN ASSIGN c-tipo-contr  = "N�o Definido".     
               END.

           END.

           DISP  "Entrada"            COLUMN-LABEL "Tipo"    AT 05
                 tt-it-nfe.it-codigo         
                 ITEM.desc-item FORMAT "x(30)" WHEN AVAIL ITEM
                 tt-it-nfe.quantidade COLUMN-LABEL "Qtd Nota"   FORMAT "->>>,>>>,>>9.99"
                 tt-it-nfe.vl-uni     COLUMN-LABEL "Vl Unitario"    
                 tt-it-nfe.lote       COLUMN-LABEL "Lote"  FORMAT "x(12)"
                 tt-it-nfe.qtd-prs    COLUMN-LABEL "Qtd PRS"  FORMAT "->>>,>>>,>>9.99"
                 tt-it-nfe.qtd-inv    COLUMN-LABEL "Qtd Contagem" FORMAT "->>>,>>>,>>9.99"
                 tt-it-nfe.nr-caixa   COLUMN-LABEL "Caixa"
                 ITEM.class-fiscal    WHEN AVAIL ITEM
                 c-tipo-contr         COLUMN-LABEL "Tipo Controle" FORMAT "x(20)"  
                 c-cod-obsoleto       COLUMN-LABEL "Situa��o" FORMAT "x(20)"
                WITH WIDTH 333 STREAM-IO DOWN FRAME f-it-ent.
           DOWN WITH FRAME f-it-ent.
           
       END.
                 
   END.
    
   FOR EACH tt-nfs WHERE
            tt-nfs.ped_codigo_n = tt-pedido.ped_codigo_n :

       PUT skip(1) "Itens Nota Sa�da :" AT 05 SKIP (1).

       FOR EACH tt-it-nfs WHERE
                tt-it-nfs.ped_codigo_n = tt-nfs.ped_codigo_n:

           FOR FIRST ITEM NO-LOCK WHERE
                     ITEM.it-codigo = tt-it-nfs.it-codigo:
           END.

           IF AVAIL ITEM 
           THEN DO:
               CASE ITEM.cod-obsoleto:
                 WHEN 1 THEN ASSIGN c-cod-obsoleto = "Ativo".
                 WHEN 2 THEN ASSIGN c-cod-obsoleto = "Obsoleto Ordens Autom.".
                 WHEN 3 THEN ASSIGN c-cod-obsoleto = "Obsoleto Todas as Ordens".
                 WHEN 4 THEN ASSIGN c-cod-obsoleto = "Totalmente Obsoleto". 
               END.
               
               CASE ITEM.tipo-contr:
                 WHEN 1 THEN ASSIGN c-tipo-contr  = "F�sico".
                 WHEN 2 THEN ASSIGN c-tipo-contr  = "Total".
                 WHEN 3 THEN ASSIGN c-tipo-contr  = "Consignado".
                 WHEN 4 THEN ASSIGN c-tipo-contr  = "D�bito Direto". 
                 WHEN 5 THEN ASSIGN c-tipo-contr  = "N�o Definido".     
               END.

           END.

           DISP "Saida"             COLUMN-LABEL "Tipo"    AT 05
                tt-it-nfs.it-codigo   
                ITEM.desc-item FORMAT "x(30)" WHEN AVAIL ITEM
                tt-it-nfs.quantidade COLUMN-LABEL "Qtd Nota"  FORMAT "->>>,>>>,>>9.99"
                tt-it-nfs.vl-uni     COLUMN-LABEL "Vl Unitario"    
                tt-it-nfs.lote       COLUMN-LABEL "Lote"  FORMAT "x(12)"
                tt-it-nfs.qtd-prs    COLUMN-LABEL "Qtd PRS"   FORMAT "->>>,>>>,>>9.99"
                tt-it-nfs.qtd-inv    COLUMN-LABEL "Qtd Contagem" FORMAT "->>>,>>>,>>9.99" 
                tt-it-nfs.nr-caixa   COLUMN-LABEL "Caixa"
                ITEM.class-fiscal  WHEN AVAIL ITEM
                 c-tipo-contr         COLUMN-LABEL "Tipo Controle" FORMAT "x(20)"  
                 c-cod-obsoleto       COLUMN-LABEL "Situa��o" FORMAT "x(20)"
                WITH WIDTH 333 STREAM-IO DOWN FRAME f-it-sai.
           DOWN WITH FRAME f-it-sai.
           
       END.
                 
   END.

   IF tt-param.rs-tipo = 2 AND  /* Detalahado */
      tt-param.rs-tipo-ped <> 2 /* Atualizados */  
   THEN DO:
         
       FOR EACH tt-erro WHERE
                tt-erro.ped_codigo_n = tt-pedido.ped_codigo_n
           BREAK BY tt-erro.tipo-erro
                 BY tt-erro.erro-adv:

           DISP tt-erro.desc-adv FORMAT "X(12)"  COLUMN-LABEL "Tipo" 
                tt-erro.descricao FORMAT "x(160)"
                WITH WIDTH 333 STREAM-IO DOWN FRAME f-erro.
           DOWN WITH FRAME f-erro.

       END.

   END.
       
END.

{include/i-rpclo.i}
RUN pi-finalizar IN h-acomp.
RETURN "OK":U.
               

PROCEDURE pi-leitura-pedidos:

        FOR EACH estabelec NO-LOCK WHERE
                 estabelec.cod-estabel >= tt-param.cod-estabel-ini AND 
                 estabelec.cod-estabel <= tt-param.cod-estabel-fim :
    
            CREATE tt-estab.
            ASSIGN tt-estab.cod-estabel = estabelec.cod-estabel
                   tt-estab.cgc         = estabelec.cgc.

            FOR first cst_estabelec no-lock where 
                      cst_estabelec.cod_estabel = estabelec.cod-estabel:
                ASSIGN tt-estab.dt_fim_operacao = cst_estabelec.dt_fim_operacao.
            END.
    
        END.
    
        for EACH tt-balanco ,
            each int_ds_pedido no-lock WHERE
                 int_ds_pedido.ped_tipopedido_n  = tt-balanco.ped_tipopedido_n AND 
                 int_ds_pedido.ped_codigo_n    >=  tt-param.pedido-ini         AND  
                 int_ds_pedido.ped_codigo_n    <=  tt-param.pedido-fim         AND
                 date(int_ds_pedido.dt_geracao) >= tt-param.dt-periodo-ini     AND                
                 date(int_ds_pedido.dt_geracao) <= tt-param.dt-periodo-fim ,
            FIRST tt-estab WHERE
                  tt-estab.cgc = int_ds_pedido.ped_cnpj_destino_s  AND 
                  tt-estab.dt_fim_operacao >= int_ds_pedido.dt_geracao :
            
               FIND FIRST emitente NO-LOCK  // kml
                   WHERE emitente.cgc = int_ds_pedido.ped_cnpj_origem_s NO-ERROR.
               IF AVAIL emitente THEN
                    ASSIGN c-nome-abrev = emitente.nome-abrev.

                // n�o mostrar pedidos cancelados
                IF tt-param.cancelados = NO THEN 
                    IF int_ds_pedido.situacao = 3 THEN NEXT.
           
                IF tt-param.rs-tipo-ped = 1 THEN 
                    IF int_ds_pedido.situacao = 2 THEN NEXT.
    
                IF tt-param.rs-tipo-ped = 2 THEN 
                    IF int_ds_pedido.situacao = 1 THEN NEXT.
    
                RUN pi-acompanhar IN h-acomp(INPUT "Pedido :" + string(int_ds_pedido.ped_codigo_n)).
    
               CREATE tt-pedido.
               BUFFER-COPY int_ds_pedido TO tt-pedido.
                
               IF int_ds_pedido.situacao = 1 THEN
                  ASSIGN tt-pedido.desc-sit = "Pendente".
               ELSE IF int_ds_pedido.situacao = 3 THEN
                  ASSIGN tt-pedido.desc-sit = "Cancelado".
               ELSE 
                  ASSIGN tt-pedido.desc-sit = "Atualizado".
                                              
               ASSIGN tt-pedido.cod-estab   = tt-estab.cod-estabel.
    
               FIND FIRST emitente NO-LOCK WHERE
                          emitente.cgc = int_ds_pedido.ped_cnpj_origem_s NO-ERROR.
               IF AVAIL emitente THEN
                  ASSIGN tt-pedido.cod-emitente = emitente.cod-emitente. 

               IF tt-param.rs-tipo = 2 /* Detalhado */
               THEN DO:
    
                   FOR EACH nota-fiscal NO-LOCK WHERE // KML
                            nota-fiscal.cod-estabel = tt-estab.cod-estabel AND
                            nota-fiscal.nome-ab-cli = c-nome-abrev AND
                            nota-fiscal.nr-pedcli   = STRING(int_ds_pedido.ped_codigo_n):
                   
                     CREATE tt-notas-geradas.
                     ASSIGN tt-notas-geradas.ped_codigo_n  = int_ds_pedido.ped_codigo_n
                            tt-notas-geradas.nr-nota-fis   = nota-fiscal.nr-nota-fis
                            tt-notas-geradas.serie         = nota-fiscal.serie
                            tt-notas-geradas.cod-estabel   = nota-fiscal.cod-estabel
                            tt-notas-geradas.nat-oepracao  = nota-fiscal.nat-operacao
                            tt-notas-geradas.dt-emis-nota  = nota-fiscal.dt-emis
                            tt-notas-geradas.dt-cancel     = nota-fiscal.dt-cancel. 
                   END.
    
                   RUN pi-item-divergente.
    
                   ASSIGN tt-pedido.nr-itens-entrada = i-cont-ent
                          tt-pedido.nr-itens-saida   = i-cont-sai.  
                                         
               END.

        END. /* tt-balanco */ 

END PROCEDURE.

PROCEDURE pi-cria-balanco:
   DEF INPUT PARAMETER p-tipo AS INTEGER.
   DEF INPUT PARAMETER p-desc AS CHAR.
  
  CREATE tt-balanco.
  ASSIGN tt-balanco.ped_tipopedido_n = p-tipo
         tt-balanco.desc-pedido      = p-desc. 

END.


PROCEDURE pi-item-divergente:

   ASSIGN i-cont-ent          = 0
          i-cont-sai          = 0
          c-it-codigo         = ""
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

   ASSIGN d-dt-entrega        = int_ds_pedido.ped_dataentrega_d
          d-dt-emissao        = /*int_ds_pedido.ped-data-d*/ TODAY
          c-nr-pedcli         = trim(string(int_ds_pedido.ped_codigo_n))
          d-dt-implantacao    = today
          c-observacao        = int_ds_pedido.ped_observacao_s
          c-placa             = if int_ds_pedido.ped_placaveiculo_s <> ? then int_ds_pedido.ped_placaveiculo_s else ""
          c-uf-placa          = if int_ds_pedido.ped_estadoveiculo_s <> ? then int_ds_pedido.ped_estadoveiculo_s else ""
          c-tp-pedido         = trim(string(int_ds_pedido.ped_tipopedido_n))
          c-docto-orig        = trim(string(int_ds_pedido.ped_codigo_n)).
           
   RUN valida-pedido.

   FIND FIRST emitente NO-LOCK
       WHERE emitente.cgc = int_ds_pedido.ped_cnpj_origem_s NO-ERROR.
   IF AVAIL emitente THEN
        ASSIGN c-nome-abrev = emitente.nome-abrev.


   FOR each int_ds_pedido_produto no-lock 
       WHERE int_ds_pedido_produto.ped_codigo_n =  int_ds_pedido.ped_codigo_n,
       EACH int_ds_pedido_retorno NO-LOCK 
            WHERE int_ds_pedido_retorno.ped_codigo_n = int_ds_pedido_produto.ped_codigo_n
              AND int_ds_pedido_retorno.ppr_produto_n = int_ds_pedido_produto.ppr_produto_n
       break BY int_ds_pedido_retorno.ped_codigo_n 
             by int_ds_pedido_retorno.ppr_produto_n
             BY int_ds_pedido_retorno.rpp_caixa_n
             by int_ds_pedido_retorno.rpp_lote_s:

             RUN pi-acompanhar IN h-acomp(INPUT "Itens :" + string(int_ds_pedido_retorno.ppr_produto_n)).

             assign  l-movto-com-erro  = no.
                                
             assign de-vl-uni           = 0
                    c-it-codigo         = trim(string(int_ds_pedido_produto.ppr_produto_n))
                    de-quantidade       = int_ds_pedido_retorno.rpp_quantidade_n - int_ds_pedido_retorno.rpp_qtd_inventario_n 
                    de-desconto         = int_ds_pedido_produto.ppr_percentualdesconto_n
                    c-numero-caixa      = ""
                    c-numero-caixa      = (if c-numero-caixa = ""
                                            then string(int_ds_pedido_retorno.rpp_caixa_n)
                                           else c-numero-caixa + "," + string(int_ds_pedido_retorno.rpp_caixa_n))
                    c-numero-lote       = if trim(int_ds_pedido_retorno.rpp_lote_s) <> "0" and 
                                             trim(int_ds_pedido_retorno.rpp_lote_s) <> "?" and
                                             trim(int_ds_pedido_retorno.rpp_lote_s) <> ? then trim(int_ds_pedido_retorno.rpp_lote_s) else "".
            /*RUN pi-calcula-preco.*/

            IF de-quantidade > 0 
            THEN DO:
            
                   ASSIGN i-cont-ent    = i-cont-ent    + 1
                          i-seq-entrada = i-seq-entrada + 1.
                                                              
                   IF i-seq-entrada = para-fat.nr-item-nota THEN
                      ASSIGN i-nro-docto   = i-nro-docto + 1
                             i-seq-entrada = 1.
                        
                   FOR FIRST tt-nfe NO-LOCK WHERE
                             tt-nfe.ped_codigo_n = int_ds_pedido.ped_codigo_n AND  
                             tt-nfe.nro-docto    = i-nro-docto :
                   END.
                   IF NOT AVAIL tt-nfe 
                   THEN DO:
                      
                        CREATE tt-nfe.
                        ASSIGN tt-nfe.ped_codigo_n = int_ds_pedido.ped_codigo_n
                               tt-nfe.nro-docto    = i-nro-docto. 
                          
                        IF int_ds_pedido.situacao = 1 THEN
                            run valida-nota-entrada.
                        
                    END.

                    FIND FIRST tt-it-nfe WHERE 
                               tt-it-nfe.ped_codigo_n = int_ds_pedido.ped_codigo_n AND 
                               tt-it-nfe.nro-docto    = i-nro-docto                AND  
                               tt-it-nfe.it-codigo    = c-it-codigo                AND
                               tt-it-nfe.lote         = c-numero-lote NO-ERROR.    
                    IF NOT AVAIL tt-it-nfe 
                    THEN DO:

                       ASSIGN de-vl-uni = 0.   
                       FOR EACH nota-fiscal USE-INDEX ch-pedido NO-LOCK WHERE
                                nota-fiscal.nome-ab-cli = c-nome-abrev AND
                                nota-fiscal.nr-pedcli   = STRING(int_ds_pedido.ped_codigo_n) AND
                                nota-fiscal.cod-estabel = tt-estab.cod-estabel AND
                                nota-fiscal.dt-cancel  = ?:
                           FOR EACH it-nota-fisc OF nota-fiscal WHERE
                                    it-nota-fisc.it-codigo = c-it-codigo NO-LOCK:
                               ASSIGN de-vl-uni = it-nota-fisc.vl-preuni.
                           END.
                       END.
                       
                       if de-vl-uni = 0 then do:                                        
                          for first item-uni-estab  no-lock where 
                                    item-uni-estab.cod-estabel = tt-estab.cod-estabel AND  
                                    item-uni-estab.it-codigo   = c-it-codigo: 
                              assign de-vl-uni = item-uni-estab.preco-base.  /* Pre�o base */
                          end.   
                       end.

                       CREATE tt-it-nfe.
                       ASSIGN tt-it-nfe.ped_codigo_n = int_ds_pedido.ped_codigo_n
                              tt-it-nfe.nro-docto    = i-nro-docto    
                              tt-it-nfe.it-codigo    = c-it-codigo 
                              tt-it-nfe.quantidade   = de-quantidade
                              tt-it-nfe.qtd-prs      = int_ds_pedido_retorno.rpp_quantidade_n
                              tt-it-nfe.qtd-inv      = int_ds_pedido_retorno.rpp_qtd_inventario_n  
                              tt-it-nfe.vl-uni       = de-vl-uni 
                              tt-it-nfe.nr-caixa     = c-numero-caixa
                              tt-it-nfe.lote         = c-numero-lote.
                    END.
                    ELSE 
                       ASSIGN tt-it-nfe.quantidade   = tt-it-nfe.quantidade + de-quantidade
                              tt-it-nfe.qtd-prs      = tt-it-nfe.qtd-prs + int_ds_pedido_retorno.rpp_quantidade_n     
                              tt-it-nfe.qtd-inv      = tt-it-nfe.qtd-inv + int_ds_pedido_retorno.rpp_qtd_inventario_n.
                      
                    IF int_ds_pedido.situacao = 1 THEN 
                       run valida-item-entrada.
                
            END.

            IF de-quantidade < 0 
            THEN DO:
                    ASSIGN i-cont-sai = i-cont-sai + 1.

                    FOR FIRST tt-nfs NO-LOCK WHERE
                              tt-nfs.ped_codigo_n = int_ds_pedido.ped_codigo_n:
                    END.
                    IF NOT AVAIL tt-nfs 
                    THEN DO:
                   
                        CREATE tt-nfs.
                        ASSIGN tt-nfs.ped_codigo_n = int_ds_pedido.ped_codigo_n.
                           
                        IF int_ds_pedido.situacao = 1 THEN 
                           run valida-nota-saida.
                        
                    END.

                    FIND FIRST tt-it-nfs WHERE
                               tt-it-nfs.ped_codigo_n = int_ds_pedido.ped_codigo_n AND 
                               tt-it-nfs.it-codigo    = c-it-codigo                AND
                               tt-it-nfs.lote         = c-numero-lote NO-ERROR.
                    IF NOT AVAIL tt-it-nfs 
                    THEN DO:

                       ASSIGN de-vl-uni = 0.                            
                       FOR EACH nota-fiscal USE-INDEX ch-pedido NO-LOCK WHERE
                                nota-fiscal.nome-ab-cli = c-nome-abrev AND
                                nota-fiscal.nr-pedcli   = STRING(int_ds_pedido.ped_codigo_n) AND
                                nota-fiscal.cod-estabel = tt-estab.cod-estabel :

                           FOR EACH it-nota-fisc OF nota-fiscal WHERE
                                    it-nota-fisc.it-codigo = c-it-codigo NO-LOCK:
                               ASSIGN de-vl-uni = it-nota-fisc.vl-preuni.
                           END.
                       END.

                       if de-vl-uni = 0 then do:                                        
                          for first item-uni-estab  no-lock where 
                                    item-uni-estab.cod-estabel = "973" AND  
                                    item-uni-estab.it-codigo   = c-it-codigo:                 
                              assign de-vl-uni = item-uni-estab.preco-base.  /* Pre�o base */
                          end.   
                       end.

                       CREATE tt-it-nfs.
                       ASSIGN tt-it-nfs.ped_codigo_n = int_ds_pedido.ped_codigo_n
                              tt-it-nfs.it-codigo    = c-it-codigo 
                              tt-it-nfs.quantidade   = de-quantidade * -1
                              tt-it-nfs.qtd-prs      = int_ds_pedido_retorno.rpp_quantidade_n
                              tt-it-nfs.qtd-inv      = int_ds_pedido_retorno.rpp_qtd_inventario_n  
                              tt-it-nfs.vl-uni       = de-vl-uni 
                              tt-it-nfs.nr-caixa     = c-numero-caixa
                              tt-it-nfs.lote         = c-numero-lote.
                    END.
                    ELSE 
                       ASSIGN tt-it-nfs.quantidade   = tt-it-nfs.quantidade + (de-quantidade * -1)
                              tt-it-nfs.qtd-prs      = tt-it-nfs.qtd-prs    + int_ds_pedido_retorno.rpp_quantidade_n
                              tt-it-nfs.qtd-inv      = tt-it-nfs.qtd-inv    + int_ds_pedido_retorno.rpp_qtd_inventario_n.
                         
                    IF int_ds_pedido.situacao = 1 THEN 
                       run valida-item-saida.

            END.

   END. /* int_ds_pedido_produto */   

END.

PROCEDURE valida-nota-entrada:
         /* 1949 - Entrada sempre para o mesmo estado 
            5949 - Sa�da para o mesmo estado */
                    
    assign  i-cod-emitente = 0
            i-cod-cond-pag = 0
            i-tipo-erro    = 1
            i-erro-adv     = 1.
             
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
       
    end.

END.
 
procedure valida-nota-saida:

    run pi-acompanhar in h-acomp (input "Validando Nota Saida").
    
    /* for first nota-fiscal fields (cod-estabel serie nr-nota-fis dt-cancel) no-lock where
        nota-fiscal.nr-pedcli = string(c-nr-pedcli):
        if nota-fiscal.dt-cancel = ? then do:
            assign i-erro = 36
                   c-informacao = "Pedido: " + c-nr-pedcli + " CNPJ Origem: " + string(int_ds_pedido.ped-cnpj-origem) + " Estab.: " + 
                                  c-cod-estabel + " S�rie: " + nota-fiscal.serie + " NF: " + nota-fiscal.nr-nota-fis
                   l-movto-com-erro = yes.
            find current int_ds_pedido exclusive-lock no-wait no-error.
            if avail int_ds_pedido then
                assign int_ds_pedido.situacao = 2 /* integrado */.
            run gera-log. 
            return.
        end.
    end. */

    assign  c-nome-abrev   = ""
            i-cod-emitente = 0
            c-nr-tabpre    = ""
            i-canal-vendas = 0
            i-cod-rep      = 1
            i-cod-cond-pag = 0
            c-cod-transp   = ""
            c-natur        = ""
            c-nome-transp  = ""
            c-redespacho   = ""
            i-tipo-erro    = 3
            i-erro-adv     = 1.

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
         
        end. 
    end.
    if c-nome-abrev = "" then do:
        assign i-erro = 2
               c-informacao = "Pedido: " + c-nr-pedcli + " CNPJ Destino: " + string((int_ds_pedido.ped_cnpj_destino))
               l-movto-com-erro = yes.
        run gera-log. 
     
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
           
        end.
    end.

end.

procedure valida-item-entrada:
     
   ASSIGN i-tipo-erro = 2
          i-erro-adv  = 1.

   run pi-acompanhar in h-acomp (input "Validando Itens Entrada : " +  c-it-codigo ).
                             
   for first item NO-LOCK where
             item.it-codigo = c-it-codigo:

        ASSIGN c-class-fiscal = item.class-fiscal.

   end.

   if not avail item 
   then do:

      assign i-erro = 9
             c-informacao = "Pedido: " + c-nr-pedcli + " Item: " + 
                            c-it-codigo 
             l-movto-com-erro = yes.

      run gera-log. 
     
   end.
    
   FOR FIRST classif-fisc NO-LOCK WHERE
             classif-fisc.class-fiscal = c-class-fiscal AND 
             classif-fisc.class-fiscal <> ""  :
   END.

   
   IF NOT AVAIL classif-fisc 
   THEN DO:

          /* ASSIGN ITEM.class-fiscal = "33059000". */
                            
         assign i-erro-adv  = 1
                i-erro = 42
                c-informacao = " Item: " + 
                            c-it-codigo
             l-movto-com-erro = yes.

      run gera-log. 
      
   END.

   IF AVAIL ITEM AND 
            ITEM.tipo-contr = 4 /* D�bito Direto */
   THEN DO: 

       assign i-erro-adv   = 2
              i-erro       = 44
              c-informacao = " Item: " + 
                             c-it-codigo
              l-movto-com-erro = yes.
    
          run gera-log. 

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
          assign i-erro-adv = 1
                 i-erro     = 44
                 c-informacao = " Item: " + 
                                c-it-codigo + " n�o possui conta cont�bil relacionada.".
                 l-movto-com-erro = yes.
    
          run gera-log. 
      END.
      
      /* IF AVAIL item-uni-estab THEN
         ASSIGN c-cont-contabil = item-uni-estab.conta-aplicacao.
      ELSE 
         ASSIGN c-cont-contabil = ITEM.conta-aplicacao.
       */
      
   END.
   
   if avail item and item.cod-obsoleto = 4 
   then do:
      assign i-erro-adv   = 2
             i-erro       = 10
             c-informacao = " Item: " + 
                            c-it-codigo
             l-movto-com-erro = yes.

      run gera-log. 
     
   end.     
   if avail item and not item.ind-item-fat 
   then do:
      assign i-erro-adv   = 1
             i-erro       = 11
             c-informacao = " Item: " + 
                            c-it-codigo
             l-movto-com-erro = yes.
      run gera-log. 
    
   end.     
   if dec(tt-it-nfe.quantidade) <= 0 
   then do:
      assign i-erro-adv   = 1
             i-erro       = 12
             c-informacao = " Item: " + 
                            c-it-codigo + " Qtde.: " + string(de-quantidade)
             l-movto-com-erro = yes.
      run gera-log. 
      
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
			              input ""	      , /* item */
                          INPUT c-cod-estabel, 
                          output c-natur      ,
                          output c-natur-ent  ,
                          output r-rowid).
   ASSIGN l-ind-icm-ret = no.

   for first natur-oper no-lock where
             natur-oper.nat-operacao = c-natur-ent: 

       if natur-oper.subs-trib then l-ind-icm-ret = yes.

   end.

   if not avail natur-oper 
   then do:
       assign i-erro-adv   = 1
              i-erro       = 21
              c-informacao = " Natur. Oper.: " + c-natur-ent + 
                             " UF Destino: " + 
                             c-uf-destino + " UF Origem: " + 
                             c-uf-origem + " Estab.: " + 
                             C-COD-ESTABEL + " Emitente: " + 
                             STRING(I-COD-EMITENTE) + " NCM: " +
                             C-CLASS-FISCAL
              l-movto-com-erro = yes.

       run gera-log. 
   end.
         
   if avail natur-oper and 
      not natur-oper.nat-ativa 
   then do:
       assign i-erro-adv   = 1
              i-erro       = 32  
              c-informacao = " Natur. Oper.: " + 
                          c-natur-ent
           l-movto-com-erro = yes.
       run gera-log. 
       
   end.

   if avail natur-oper and 
     (natur-oper.especie-doc = "NFD" or
      natur-oper.terceiros) and
      c-nr-docum = "" 
   then do:
       assign i-erro-adv   = 1
              i-erro       = 28
              c-informacao = " Natur. Oper.: " + 
                               c-natur-ent + " Esp. Doc.: " + natur-oper.especie-doc
           l-movto-com-erro = yes.
       run gera-log. 
       
   end.
   if avail natur-oper and 
      natur-oper.especie-doc <> "NFE" 
    then do:
       assign i-erro-adv   = 1
              i-erro       = 34
              c-informacao = " Natur. Oper.: " + 
                             c-natur-ent + " Esp. Doc.: " + natur-oper.especie-doc
           l-movto-com-erro = yes.
       run gera-log. 
     
   end.
   if avail natur-oper and 
            natur-oper.imp-nota = NO     
    then do:

       assign i-erro-adv   = 1
              i-erro       = 43
              c-informacao = " Natur. Oper.: " + 
                             c-natur-ent + " Esp. Doc.: " + natur-oper.especie-doc
           l-movto-com-erro = yes.
       run gera-log. 
      
   end.

   if avail natur-oper and not natur-oper.emite-duplic then
       assign i-cod-cond-pag = 0.

   if i-cod-cond-pag <> 0 and i-cod-cond-pag <> ?
   then do:
      find cond-pagto where
           cond-pagto.cod-cond-pag = i-cod-cond-pag
           no-lock no-error.
      if not avail cond-pagto 
      then do:
         assign i-erro-adv   = 1
                i-erro = 15
                c-informacao = " Cond. Pagto.: " + 
                               string(i-cod-cond-pag)
                l-movto-com-erro = yes.
         run gera-log. 
         
      end.    
      else if cond-pagto.cod-vencto <> 2 /* a vista */ and 
           avail emitente and emitente.ind-cre-cli = 5 /* so a vista */ then
      do:
         assign i-erro-adv   = 1
                i-erro = 26
                c-informacao =  " Cond. Pagto.: " + 
                               string(i-cod-cond-pag)
                l-movto-com-erro = yes.
         run gera-log. 
         
      end.
   end.     

   if de-vl-uni = 0 
   then do: 
        assign i-erro-adv   = 1
               i-erro       = 38
               c-informacao =  " Estabel: " + c-cod-estabel + " Item: " + c-it-codigo 
               l-movto-com-erro = yes.

        run gera-log. 
        
   end.

      
END PROCEDURE.

procedure valida-item-saida:
   
   ASSIGN i-tipo-erro = 4.

   run pi-acompanhar in h-acomp (input "Validando Itens Saida : " + c-it-codigo).
   
   for first item  NO-LOCK  where
             item.it-codigo = c-it-codigo:
        c-class-fiscal = item.class-fiscal.
   end.
   if not avail item then do:
      assign i-erro-adv   = 1
             i-erro       = 9
             c-informacao = " Item: " + 
                            c-it-codigo 
             l-movto-com-erro = yes.
      run gera-log. 
      
   end.

   FOR FIRST classif-fisc NO-LOCK WHERE
             classif-fisc.class-fiscal = c-class-fiscal AND 
             classif-fisc.class-fiscal <> ""  :

   END.
   IF NOT AVAIL classif-fisc 
   THEN DO:

         /* ASSIGN ITEM.class-fiscal = "33059000". 
            */

         assign i-erro-adv   = 1
                i-erro       = 42
                c-informacao = " Item: " + 
                            c-it-codigo
             l-movto-com-erro = yes.
      run gera-log. 
      
   END.
                           
   if avail item and 
            item.cod-obsoleto = 4 
   then do:
      assign i-erro-adv   = 2
             i-erro       = 10
             c-informacao = " Item: " + 
                            c-it-codigo
             l-movto-com-erro = yes.
      run gera-log. 
      
   end.     
   if avail item and not item.ind-item-fat then do:
      assign i-erro-adv   = 1
             i-erro       = 11
             c-informacao = " Item: " + 
                            c-it-codigo
             l-movto-com-erro = yes.
      run gera-log. 
      
   end.     
   if dec(tt-it-nfs.quantidade) <= 0 
   then do:
      assign i-erro-adv   = 1
             i-erro       = 12
             c-informacao = " Item: " + 
                            c-it-codigo + " Qtde.: " + string(de-quantidade)
             l-movto-com-erro = yes.
      run gera-log. 
      
   end. 
   
   ASSIGN i-cst-icms = 0.

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
			              input ""	      , /* item */
                          INPUT c-cod-estabel, 
                          output c-natur      ,
                          output c-natur-ent  ,
                          output r-rowid).
          
   ASSIGN l-ind-icm-ret = no.

   for first natur-oper no-lock where
             natur-oper.nat-operacao = c-natur: 
       if natur-oper.subs-trib then l-ind-icm-ret = yes.
   end.

   if not avail natur-oper 
   then do:
       assign i-erro-adv   = 2 
              i-erro       = 21
              c-informacao = " Natur. Oper.: " + c-natur + 
                             " UF Destino: " + 
                             c-uf-destino + " UF Origem: " + 
                             c-uf-origem + " Estab.: " + 
                             C-COD-ESTABEL + " Emitente: " + 
                             STRING(I-COD-EMITENTE) + " NCM: " +
                             C-CLASS-FISCAL
              l-movto-com-erro = yes.
       run gera-log. 
      
   end.

   if avail natur-oper and 
      not natur-oper.nat-ativa 
   then do:
       assign i-erro-adv   = 1
              i-erro       = 32  
              c-informacao = " Natur. Oper.: " + 
                          c-natur
           l-movto-com-erro = yes.

       run gera-log. 
       
   end.
   if avail natur-oper and 
     (natur-oper.especie-doc = "NFD" or
      natur-oper.terceiros) and
      c-nr-docum = "" 
   then do:
       assign i-erro-adv   = 1
              i-erro = 28
              c-informacao = " Natur. Oper.: " + 
                          c-natur + " Esp. Doc.: " + natur-oper.especie-doc
           l-movto-com-erro = yes.
       run gera-log. 
       
   end.
   if avail natur-oper and 
     (natur-oper.especie-doc <> "NFD" and
      not natur-oper.terceiros) and
      c-nr-docum <> "" 
    then do:
       ASSIGN i-erro-adv   = 1
              i-erro       = 29
              c-informacao = " Natur. Oper.: " + 
                             c-natur + " Esp. Doc.: " + natur-oper.especie-doc
           l-movto-com-erro = yes.
       run gera-log. 
      
   end.

   if avail natur-oper and not natur-oper.emite-duplic then
       assign i-cod-cond-pag = 0.

   if i-cod-cond-pag <> 0 and i-cod-cond-pag <> ?
   then do:
      find cond-pagto where
           cond-pagto.cod-cond-pag = i-cod-cond-pag
           no-lock no-error.
      if not avail cond-pagto then do:
         assign i-erro-adv = 1
                i-erro = 15
                c-informacao = " Cond. Pagto.: " + 
                               string(i-cod-cond-pag)
                l-movto-com-erro = yes.
         run gera-log. 
         
      end.    
      else if cond-pagto.cod-vencto <> 2 /* a vista */ and 
           avail emitente and emitente.ind-cre-cli = 5 /* so a vista */ then
      do:
         assign i-erro-adv = 1
                i-erro = 26
                c-informacao = " Cond. Pagto.: " + 
                               string(i-cod-cond-pag)
                l-movto-com-erro = yes.
         run gera-log. 
         
      end.
   end.
   
  if de-vl-uni = 0 
  then do:
        assign i-erro-adv = 1
               i-erro = 38
               c-informacao = " Estabel : " + c-cod-estabel + " Tab. Pre�o: " + 
                              c-nr-tabpre + " Item: " + 
                              c-it-codigo
               l-movto-com-erro = yes.

        run gera-log. 

   end.

end.

procedure pi-calcula-preco:
                   
    /*
    if de-vl-uni = 0
    then do:

       /* Pre�o M�dio */
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
   
           assign de-vl-uni = item-uni-estab.preco-base.  /* Pre�o base */

           IF de-vl-uni = 0 THEN
              assign de-vl-uni = item-uni-estab.preco-ul-ent. /* Pre�o Ult Entrada */ 
       end.      
          
    end.
    */

    if de-vl-uni = 0
    then do:
                                                            
       for first item-uni-estab  no-lock where 
                 item-uni-estab.cod-estabel = "973" AND  
                 item-uni-estab.it-codigo   = c-it-codigo:                 
   
           assign de-vl-uni = item-uni-estab.preco-base.  /* Pre�o base */

           /* IF de-vl-uni = 0 THEN
              assign de-vl-uni = item-uni-estab.preco-ul-ent. /* Pre�o Ult Entrada */ 
            */
       end.   

          
    end.
  
end procedure.

procedure valida-pedido:
  
    assign c-cod-estabel = "". //ponto de interesse
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
               c-serie       = estabelec.serie.
    end.
    
    if c-cod-estabel = "" then
    do:
       assign i-erro-adv = 1
              i-erro = 30
              c-informacao = " CNPJ Origem: " + string(int_ds_pedido.ped_cnpj_origem)
              l-movto-com-erro = yes.
       run gera-log. 
       
    end.
    for first ser-estab no-lock where
        ser-estab.serie = c-serie and
        ser-estab.cod-estabel = c-cod-estabel:
        if ser-estab.forma-emis <> 1 /* autom�tica */ then do:
            assign i-erro = 34
                   c-informacao = "Pedido: " + c-nr-pedcli + " - Est: " + c-cod-estabel + " - S�rie: " + c-serie
                   l-movto-com-erro = yes.
            run gera-log. 
            return.
        end.
        if not ser-estab.log-nf-eletro /* NFe */ then do:
            assign i-erro = 40
                   c-informacao = "Pedido: " + c-nr-pedcli + " - Est: " + c-cod-estabel + " - S�rie: " + c-serie
                   l-movto-com-erro = yes.
            run gera-log. 
            return.
        end.

    end.

END.


procedure gera-log:
   
   CREATE tt-erro.
   ASSIGN tt-erro.ped_codigo_n = int_ds_pedido.ped_codigo_n
          tt-erro.erro-adv     = i-erro-adv
          tt-erro.tipo-erro    = i-tipo-erro  
          tt-erro.cod-erro     = i-erro 
          tt-erro.descricao    = tb-erro[i-erro] + " - " + c-informacao.

   IF i-erro-adv = 1 THEN
     ASSIGN tt-erro.desc-adv = "Erro".
   ELSE
     ASSIGN tt-erro.desc-adv = "Advert�ncia".                           
                   
end.


