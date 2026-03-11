/********************************************************************************
** Copyright DATASUL S.A. (1997)
** Todos os Direitos Reservados.
**
** Este fonte e de propriedade exclusiva da DATASUL, sua reproducao
** parcial ou total por qualquer meio, so podera ser feita mediante
** autorizacao expressa.
*******************************************************************************/

{include/i-prgvrs.i NI9999 2.00.00.000}  /*** 010001 ***/

define temp-table tt-param no-undo
    field destino          as integer
    field arquivo          as char format "x(35)"
    field usuario          as char format "x(12)"
    field data-exec        as date
    field hora-exec        as integer
    field dir-exporta      as CHAR 
    field elimina          as LOGICAL
    FIELD devolucao-cupom  as LOGICAL
    FIELD nota-saida       as LOGICAL
    FIELD ndd-envio        as LOGICAL
    FIELD docto-xml        as LOGICAL
    FIELD nota-entrada     as LOGICAL
    FIELD ped-venda        as LOGICAL
    FIELD nota-loja        as LOGICAL
    FIELD cliente          as LOGICAL
    FIELD ped-compra       as LOGICAL
    FIELD doc              as LOGICAL
    FIELD log              as LOGICAL
    FIELD xml-nfe          as LOGICAL
    FIELD fat-conv-site    as LOGICAL
    FIELD tit-ap           as LOGICAL
    FIELD c-destino        AS CHAR.

define temp-table tt-digita no-undo
    field ordem            as integer   format ">>>>9"
    field exemplo          as character format "x(30)"
    index id ordem.

def temp-table tt-raw-digita
    field raw-digita as raw.

DEF TEMP-TABLE tt-log
    FIELD tabela   AS CHAR    FORMAT "x(40)"                 COLUMN-LABEL "Nome Tabela"
    FIELD qtde-reg AS INT     FORMAT ">>>,>>>,>>9"         COLUMN-LABEL "Quantidade"
    FIELD situacao AS LOGICAL FORMAT "Eliminados/Exportados" COLUMN-LABEL "Registros"
    FIELD dt-corte AS DATE    FORMAT "99/99/9999"            COLUMN-LABEL "Data Corte"
    INDEX codigo
             tabela.

def input param raw-param as raw no-undo.
def input param table for tt-raw-digita.

create tt-param.
raw-transfer raw-param to tt-param.

DEF VAR c-arq-exporta       AS CHAR                     NO-UNDO.
def var h-acomp             as HANDLE                   NO-UNDO.
DEF VAR da-dt-corte         AS DATE                     NO-UNDO.
DEF VAR i-cont              AS INT FORMAT ">>>,>>>,>>9" NO-UNDO.
DEF VAR i-cont-docto-xml    AS INT FORMAT ">>>,>>>,>>9" NO-UNDO.
DEF VAR i-cont-it-docto-xml AS INT FORMAT ">>>,>>>,>>9" NO-UNDO.
DEF VAR i-cont-nf-entrada   AS INT FORMAT ">>>,>>>,>>9" NO-UNDO.
DEF VAR i-cont-nf-ent-dup   AS INT FORMAT ">>>,>>>,>>9" NO-UNDO.
DEF VAR i-cont-nf-ent-pro   AS INT FORMAT ">>>,>>>,>>9" NO-UNDO.
DEF VAR i-cont-nf-saida     AS INT FORMAT ">>>,>>>,>>9" NO-UNDO.
DEF VAR i-cont-nf-saida-it  AS INT FORMAT ">>>,>>>,>>9" NO-UNDO.
DEF VAR i-cont-pedido       AS INT FORMAT ">>>,>>>,>>9" NO-UNDO.
DEF VAR i-cont-ped-prod     AS INT FORMAT ">>>,>>>,>>9" NO-UNDO.
DEF VAR i-cont-ped-ret      AS INT FORMAT ">>>,>>>,>>9" NO-UNDO.
DEF VAR i-cont-nota-loja    AS INT FORMAT ">>>,>>>,>>9" NO-UNDO.
DEF VAR i-cont-nf-loja-it   AS INT FORMAT ">>>,>>>,>>9" NO-UNDO.
DEF VAR i-cont-nf-loja-ca   AS INT FORMAT ">>>,>>>,>>9" NO-UNDO.
DEF VAR i-cont-ord          AS INT FORMAT ">>>,>>>,>>9" NO-UNDO.
DEF VAR i-cont-ped          AS INT FORMAT ">>>,>>>,>>9" NO-UNDO.
DEF VAR i-cont-doc          AS INT FORMAT ">>>,>>>,>>9" NO-UNDO.
DEF VAR i-cont-it-doc       AS INT FORMAT ">>>,>>>,>>9" NO-UNDO.
DEF VAR dt-contab-ate       AS DATE                     NO-UNDO.

DEF BUFFER b-int_ds_devolucao_cupom      FOR int_ds_devolucao_cupom.     
DEF BUFFER b-int_ndd_envio               FOR int_ndd_envio.              
DEF BUFFER b-int_ds_docto_xml            FOR int_ds_docto_xml.           
DEF BUFFER b-int_ds_it_docto_xml         FOR int_ds_it_docto_xml.        
DEF BUFFER b-int_ds_nota_entrada_dup     FOR int_ds_nota_entrada_dup.    
DEF BUFFER b-int_ds_nota_entrada_produto FOR int_ds_nota_entrada_produt.
DEF BUFFER b-int_ds_nota_entrada         FOR int_ds_nota_entrada.        
DEF BUFFER b-int_ds_nota_saida_item      FOR int_ds_nota_saida_item.     
DEF BUFFER b-int_ds_nota_saida           FOR int_ds_nota_saida.          
DEF BUFFER b-int_ds_pedido_produto       FOR int_ds_pedido_produto.      
DEF BUFFER b-int_ds_pedido_retorno       FOR int_ds_pedido_retorno.      
DEF BUFFER b-int_ds_pedido               FOR int_ds_pedido.              
DEF BUFFER b-int_ds_nota_loja_item       FOR int_ds_nota_loja_item.      
DEF BUFFER b-int_ds_nota_loja_cartao     FOR int_ds_nota_loja_cartao.    
DEF BUFFER b-int_ds_nota_loja            FOR int_ds_nota_loja.           
DEF BUFFER b-int_ds_cliente              FOR int_ds_cliente.             
DEF BUFFER b-int_ds_ordem_compra         FOR int_ds_ordem_compra.        
DEF BUFFER b-int_ds_ped_compra           FOR int_ds_ped_compra.          
DEF BUFFER b-int_ds_it_doc               FOR int_ds_it_doc.              
DEF BUFFER b-int_ds_doc                  FOR int_ds_doc.                 
DEF BUFFER b-int_ds_log                  FOR int_ds_log.                 
DEF BUFFER b-int_ds_xml_nfe              FOR int_ds_xml_nfe.             
DEF BUFFER b-int_ds_fat_conv_site        FOR int_ds_fat_conv_site.       
DEF BUFFER b-cst_tit_ap                  FOR cst_tit_ap.                 

{include/i-rpvar.i}

find first param-global no-lock no-error.

find first ems2log.empresa WHERE
           ems2log.empresa.ep-codigo = param-global.empresa-prin no-lock no-error.
assign c-empresa      = (if avail empresa then empresa.razao-social else "")
       c-programa     = "NI9999"
       c-versao       = "2.00"
       c-revisao      = "000"
       c-titulo-relat = "Exporta‡Æo/Elimina‡Æo Tabelas de Integra‡Æo"
       c-sistema      = "Espec¡fico".

EMPTY TEMP-TABLE tt-log.

FOR FIRST param-estoq NO-LOCK:
END.
ASSIGN dt-contab-ate = param-estoq.contab-ate.

run utp/ut-acomp.p persistent set h-acomp.

IF tt-param.elimina = YES THEN
   run pi-inicializar in h-acomp (input "Eliminando Tabela").
ELSE
   run pi-inicializar in h-acomp (input "Exportando Tabela").

/********************* Tabela int_ds_devolucao_cupom - Manter 120 dias ********************/

IF  tt-param.devolucao-cupom = YES THEN DO:

    ASSIGN da-dt-corte   = TODAY - 120
           i-cont        = 0
           c-arq-exporta = tt-param.dir-exporta + "int_ds_devolucao_cupom.d".
    
    OUTPUT TO VALUE(c-arq-exporta) APPEND.
    
    FOR EACH int_ds_devolucao_cupom NO-LOCK WHERE
             int_ds_devolucao_cupom.dt_gera‡Æo < da-dt-corte query-tuning(no-lookahead):
    
        ASSIGN i-cont = i-cont + 1.
        RUN pi-acompanhar IN h-acomp (INPUT "Devolu‡Æo Cupom: " + STRING(i-cont,">>>,>>>,>>9")).
    
        IF int_ds_devolucao_cupom.dt_gera‡Æo > dt-contab-ate THEN
           NEXT.

        EXPORT int_ds_devolucao_cupom.
    
        IF tt-param.elimina = YES THEN DO:
           FOR FIRST b-int_ds_devolucao_cupom WHERE 
                     ROWID(b-int_ds_devolucao_cupom) = ROWID(int_ds_devolucao_cupom):
           END.
           IF AVAIL b-int_ds_devolucao_cupom THEN
              DELETE b-int_ds_devolucao_cupom.
           RELEASE b-int_ds_devolucao_cupom.
        END.
    END.
    
    OUTPUT CLOSE.
    
    CREATE tt-log.
    ASSIGN tt-log.tabela   = "int_ds_devolucao_cupom"
           tt-log.qtde-reg = i-cont
           tt-log.situacao = tt-param.elimina
           tt-log.dt-corte = da-dt-corte - 1.
END.
/******************************************************************************************/

/********************* Tabelas int_ds_nota_saida e int_ds_nota_saida_item - Manter 60 dias ********************/

IF  tt-param.nota-saida = YES THEN DO:

    DEF STREAM s-nf-saida.
    DEF STREAM s-nf-sai-it.

    ASSIGN da-dt-corte        = TODAY - 60
           i-cont-nf-saida    = 0
           i-cont-nf-saida-it = 0
           c-arq-exporta      = tt-param.dir-exporta + "int_ds_nota_saida_item.d".
    
    OUTPUT STREAM s-nf-sai-it TO VALUE(c-arq-exporta) APPEND.
    
    ASSIGN c-arq-exporta = tt-param.dir-exporta + "int_ds_nota_saida.d".
    
    OUTPUT STREAM s-nf-saida TO VALUE(c-arq-exporta) APPEND.

    FOR EACH int_ds_nota_saida NO-LOCK WHERE
             int_ds_nota_saida.nsa_dataemissao_d < da-dt-corte query-tuning(no-lookahead):                                              
    
        ASSIGN i-cont-nf-saida = i-cont-nf-saida + 1.
        RUN pi-acompanhar IN h-acomp (INPUT "Nota Sa¡da: " + STRING(i-cont-nf-saida,">>>,>>>,>>9")).

        IF int_ds_nota_saida.nsa_dataemissao_d > dt-contab-ate THEN
           NEXT.

        EXPORT STREAM s-nf-saida int_ds_nota_saida.

        FOR EACH int_ds_nota_saida_item OF int_ds_nota_saida NO-LOCK query-tuning(no-lookahead):   
    
            ASSIGN i-cont-nf-saida-it = i-cont-nf-saida-it + 1.
    
            EXPORT STREAM s-nf-sai-it int_ds_nota_saida_item.
    
            IF tt-param.elimina = YES THEN DO:
               FOR FIRST b-int_ds_nota_saida_item WHERE
                         ROWID(b-int_ds_nota_saida_item) = ROWID(int_ds_nota_saida_item):
               END.
               IF AVAIL b-int_ds_nota_saida_item THEN
                  DELETE b-int_ds_nota_saida_item.
               RELEASE b-int_ds_nota_saida_item.
            END.
        END.

        IF tt-param.elimina = YES THEN DO:
           FOR FIRST b-int_ds_nota_saida WHERE
                     ROWID(b-int_ds_nota_saida) = ROWID(int_ds_nota_saida):
           END.
           IF AVAIL b-int_ds_nota_saida THEN
              DELETE b-int_ds_nota_saida.
           RELEASE b-int_ds_nota_saida.
        END.
    END.
    
    OUTPUT STREAM s-nf-saida CLOSE.
    OUTPUT STREAM s-nf-sai-it CLOSE.
    
    CREATE tt-log.
    ASSIGN tt-log.tabela   = "int_ds_nota_saida_item"
           tt-log.qtde-reg = i-cont-nf-saida-it
           tt-log.situacao = tt-param.elimina
           tt-log.dt-corte = da-dt-corte - 1.
        
    CREATE tt-log.
    ASSIGN tt-log.tabela   = "int_ds_nota_saida"
           tt-log.qtde-reg = i-cont-nf-saida
           tt-log.situacao = tt-param.elimina
           tt-log.dt-corte = da-dt-corte - 1.
END.
/******************************************************************************************/                                                                                            

/********************* Tabela int_ndd_envio - Manter 30 dias ********************/

IF  tt-param.ndd-envio = YES THEN DO:

    ASSIGN da-dt-corte   = TODAY - 30
           i-cont        = 0
           c-arq-exporta = tt-param.dir-exporta + "int_ndd_envio.d".
    
    OUTPUT TO VALUE(c-arq-exporta) APPEND.
    
    FOR EACH int_ndd_envio NO-LOCK WHERE
             int_ndd_envio.dt_envio < da-dt-corte query-tuning(no-lookahead):
    
        ASSIGN i-cont = i-cont + 1.
        RUN pi-acompanhar IN h-acomp (INPUT "NDD Envio: " + STRING(i-cont,">>>,>>>,>>9")).
    
        IF int_ndd_envio.dt_envio > dt-contab-ate THEN
           NEXT.
        
        EXPORT int_ndd_envio.

        IF tt-param.elimina = YES THEN DO:
           FOR FIRST b-int_ndd_envio WHERE 
                     ROWID(b-int_ndd_envio) = ROWID(int_ndd_envio):
           END.
           IF AVAIL b-int_ndd_envio THEN
              DELETE b-int_ndd_envio.
           RELEASE b-int_ndd_envio.
        END.
    END.
    
    OUTPUT CLOSE.
    
    CREATE tt-log.
    ASSIGN tt-log.tabela   = "int_ndd_envio"
           tt-log.qtde-reg = i-cont
           tt-log.situacao = tt-param.elimina
           tt-log.dt-corte = da-dt-corte - 1.
END.
/******************************************************************************************/

/********************* Tabelas int_ds_docto_xml e int_ds_it_docto_xml - Manter 120 dias ********************/

IF  tt-param.docto-xml = YES THEN DO:
                                
    DEF STREAM s-docto-xml.
    DEF STREAM s-it-docto-x.

    ASSIGN da-dt-corte         = TODAY - 120
           i-cont-docto-xml    = 0
           i-cont-it-docto-xml = 0
           c-arq-exporta       = tt-param.dir-exporta + "int_ds_docto_xml.d".
    
    OUTPUT STREAM s-docto-xml TO VALUE(c-arq-exporta) APPEND.

    ASSIGN c-arq-exporta = tt-param.dir-exporta + "int_ds_it_docto_xml.d".

    OUTPUT STREAM s-it-docto-x TO VALUE(c-arq-exporta) APPEND.
    
    FOR EACH int_ds_docto_xml NO-LOCK WHERE
             int_ds_docto_xml.dt_trans < da-dt-corte query-tuning(no-lookahead):
    
        ASSIGN i-cont-docto-xml = i-cont-docto-xml + 1.
        RUN pi-acompanhar IN h-acomp (INPUT "Docto. XML: " + STRING(i-cont-docto-xml,">>>,>>>,>>9")).
    
        IF int_ds_docto_xml.dt_trans > dt-contab-ate THEN
           NEXT.

        EXPORT STREAM s-docto-xml int_ds_docto_xml.
    
        FOR EACH int_ds_it_docto_xml NO-LOCK WHERE 
                 int_ds_it_docto_xml.serie        = int_ds_docto_xml.serie         AND
                 int(int_ds_it_docto_xml.nNF)     = int(int_ds_docto_xml.nNF)      AND
                 int_ds_it_docto_xml.cod_emitente = int_ds_docto_xml.cod_emitente  AND
                 int_ds_it_docto_xml.tipo_nota    = int_ds_docto_xml.tipo_nota query-tuning(no-lookahead):   
    
            ASSIGN i-cont-it-docto-xml = i-cont-it-docto-xml + 1.
    
            EXPORT STREAM s-it-docto-x int_ds_it_docto_xml.
    
            IF tt-param.elimina = YES THEN DO:
               FOR FIRST b-int_ds_it_docto_xml WHERE
                         ROWID(b-int_ds_it_docto_xml) = ROWID(int_ds_it_docto_xml):
               END.
               IF AVAIL b-int_ds_it_docto_xml THEN
                  DELETE b-int_ds_it_docto_xml.
               RELEASE b-int_ds_it_docto_xml.
            END.
        END.

        IF tt-param.elimina = YES THEN DO:
           FOR FIRST b-int_ds_docto_xml WHERE
                     ROWID(b-int_ds_docto_xml) = ROWID(int_ds_docto_xml):
           END.
           IF AVAIL b-int_ds_docto_xml THEN
              DELETE b-int_ds_docto_xml.
           RELEASE b-int_ds_docto_xml.
        END.
    END.
    
    OUTPUT STREAM s-docto-xml CLOSE.
    OUTPUT STREAM s-it-docto-x CLOSE.
    
    CREATE tt-log.
    ASSIGN tt-log.tabela   = "int_ds_it_docto_xml"
           tt-log.qtde-reg = i-cont-it-docto-xml
           tt-log.situacao = tt-param.elimina
           tt-log.dt-corte = da-dt-corte - 1.    
        
    CREATE tt-log.
    ASSIGN tt-log.tabela   = "int_ds_docto_xml"
           tt-log.qtde-reg = i-cont-docto-xml
           tt-log.situacao = tt-param.elimina
           tt-log.dt-corte = da-dt-corte - 1.
END.
/******************************************************************************************/                                                                                            

/********************* Tabelas int_ds_nota_entrada, int_ds_nota_entrada_dup e int_ds_nota_entrada_produto - Manter 120 dias ********************/

IF  tt-param.nota-entrada = YES THEN DO:

    DEF STREAM s-nf-entrada.
    DEF STREAM s-nf-ent-dup.
    DEF STREAM s-nf-ent-pro.

    ASSIGN da-dt-corte       = TODAY - 120
           i-cont-nf-entrada = 0
           i-cont-nf-ent-dup = 0
           i-cont-nf-ent-pro = 0
           c-arq-exporta     = tt-param.dir-exporta + "int_ds_nota_entrada_dup.d".
    
    OUTPUT STREAM s-nf-ent-dup TO VALUE(c-arq-exporta) APPEND.

    ASSIGN c-arq-exporta = tt-param.dir-exporta + "int_ds_nota_entrada_produt.d".
    
    OUTPUT STREAM s-nf-ent-pro TO VALUE(c-arq-exporta) APPEND.

    ASSIGN c-arq-exporta = tt-param.dir-exporta + "int_ds_nota_entrada.d".

    OUTPUT STREAM s-nf-entrada TO VALUE(c-arq-exporta) APPEND.
    
    FOR EACH int_ds_nota_entrada NO-LOCK WHERE
             int_ds_nota_entrada.nen_dataemissao_d < da-dt-corte query-tuning(no-lookahead):                                              
    
        ASSIGN i-cont-nf-entrada = i-cont-nf-entrada + 1.
        RUN pi-acompanhar IN h-acomp (INPUT "Nota Entrada: " + STRING(i-cont-nf-entrada,">>>,>>>,>>9")).
    
        IF int_ds_nota_entrada.nen_dataemissao_d > dt-contab-ate THEN
           NEXT.

        EXPORT STREAM s-nf-entrada int_ds_nota_entrada.
    
        FOR EACH int_ds_nota_entrada_dup OF int_ds_nota_entrada NO-LOCK query-tuning(no-lookahead):   
    
            ASSIGN i-cont-nf-ent-dup = i-cont-nf-ent-dup + 1.
    
            EXPORT STREAM s-nf-ent-dup int_ds_nota_entrada_dup.
    
            IF tt-param.elimina = YES THEN DO:
               FOR FIRST b-int_ds_nota_entrada_dup WHERE
                         ROWID(b-int_ds_nota_entrada_dup) = ROWID(int_ds_nota_entrada_dup):
               END.
               IF AVAIL b-int_ds_nota_entrada_dup THEN
                  DELETE b-int_ds_nota_entrada_dup.
               RELEASE b-int_ds_nota_entrada_dup.
            END.
        END.

        FOR EACH int_ds_nota_entrada_produt OF int_ds_nota_entrada NO-LOCK query-tuning(no-lookahead):   
    
            ASSIGN i-cont-nf-ent-pro = i-cont-nf-ent-pro + 1.
    
            EXPORT STREAM s-nf-ent-pro int_ds_nota_entrada_produt.
    
            IF tt-param.elimina = YES THEN DO:
               FOR FIRST b-int_ds_nota_entrada_produto WHERE
                         ROWID(b-int_ds_nota_entrada_produto) = ROWID(int_ds_nota_entrada_produt):
               END.
               IF AVAIL b-int_ds_nota_entrada_produto THEN
                  DELETE b-int_ds_nota_entrada_produto.
               RELEASE b-int_ds_nota_entrada_produto.
            END.
        END.

        IF tt-param.elimina = YES THEN DO:
           FOR FIRST b-int_ds_nota_entrada WHERE
                     ROWID(b-int_ds_nota_entrada) = ROWID(int_ds_nota_entrada):
           END.
           IF AVAIL b-int_ds_nota_entrada THEN
              DELETE b-int_ds_nota_entrada.
           RELEASE b-int_ds_nota_entrada.
        END.
    END.
    
    OUTPUT STREAM s-nf-entrada CLOSE.
    OUTPUT STREAM s-nf-ent-dup CLOSE.
    OUTPUT STREAM s-nf-ent-pro CLOSE.
    
    CREATE tt-log.
    ASSIGN tt-log.tabela   = "int_ds_nota_entrada_dup"
           tt-log.qtde-reg = i-cont-nf-ent-dup
           tt-log.situacao = tt-param.elimina
           tt-log.dt-corte = da-dt-corte - 1.
    
    CREATE tt-log.
    ASSIGN tt-log.tabela   = "int_ds_nota_entrada_produto"
           tt-log.qtde-reg = i-cont-nf-ent-pro
           tt-log.situacao = tt-param.elimina
           tt-log.dt-corte = da-dt-corte - 1.
    
    CREATE tt-log.
    ASSIGN tt-log.tabela   = "int_ds_nota_entrada"
           tt-log.qtde-reg = i-cont-nf-entrada
           tt-log.situacao = tt-param.elimina
           tt-log.dt-corte = da-dt-corte - 1.
END.
/******************************************************************************************/                                                                                            

/********************* Tabelas int_ds_pedido, int_ds_pedido_produto e int_ds_pedido_retorno - Manter 60 dias ********************/

IF  tt-param.ped-venda = YES THEN DO:

    DEF STREAM s-pedido.
    DEF STREAM s-ped-prod.
    DEF STREAM s-ped-ret.

    ASSIGN da-dt-corte     = TODAY - 60
           i-cont-pedido   = 0
           i-cont-ped-prod = 0
           i-cont-ped-ret  = 0
           c-arq-exporta   = tt-param.dir-exporta + "int_ds_pedido_produto.d".
                          
    OUTPUT STREAM s-ped-prod TO VALUE(c-arq-exporta) APPEND.
    
    ASSIGN c-arq-exporta = tt-param.dir-exporta + "int_ds_pedido_retorno.d".
    
    OUTPUT STREAM s-ped-ret TO VALUE(c-arq-exporta) APPEND.

    ASSIGN c-arq-exporta = tt-param.dir-exporta + "int_ds_pedido.d".
    
    OUTPUT STREAM s-pedido TO VALUE(c-arq-exporta) APPEND.

    RUN pi-acompanhar IN h-acomp (INPUT "Pedido Venda...").

    FOR EACH int_ds_pedido NO-LOCK WHERE
             int_ds_pedido.ped_data_d < da-dt-corte query-tuning(no-lookahead):                                              
    
        ASSIGN i-cont-pedido = i-cont-pedido + 1.
        /*RUN pi-acompanhar IN h-acomp (INPUT "Pedido Venda: " + /*STRING(i-cont-pedido,">>>,>>>,>>9"))*/ STRING(int_ds_pedido.ped-codigo-n)).*/
    
        IF int_ds_pedido.ped_data_d > dt-contab-ate THEN
           NEXT.

        EXPORT STREAM s-pedido int_ds_pedido.
    
        FOR EACH int_ds_pedido_produto OF int_ds_pedido NO-LOCK query-tuning(no-lookahead):   
    
            ASSIGN i-cont-ped-prod = i-cont-ped-prod + 1.
    
            EXPORT STREAM s-ped-prod int_ds_pedido_produto.
    
            IF tt-param.elimina = YES THEN DO:
               FOR FIRST b-int_ds_pedido_produto WHERE
                         ROWID(b-int_ds_pedido_produto) = ROWID(int_ds_pedido_produto):
               END.
               IF AVAIL b-int_ds_pedido_produto THEN
                  DELETE b-int_ds_pedido_produto.
               RELEASE b-int_ds_pedido_produto. 
            END.
        END.

        FOR EACH int_ds_pedido_retorno OF int_ds_pedido NO-LOCK query-tuning(no-lookahead):   
    
            ASSIGN i-cont-ped-ret = i-cont-ped-ret + 1.
    
            EXPORT STREAM s-ped-ret int_ds_pedido_retorno.
    
            IF tt-param.elimina = YES THEN DO:
               FOR FIRST b-int_ds_pedido_retorno WHERE
                         ROWID(b-int_ds_pedido_retorno) = ROWID(int_ds_pedido_retorno):
               END.
               IF AVAIL b-int_ds_pedido_retorno THEN
                  DELETE b-int_ds_pedido_retorno.
               RELEASE b-int_ds_pedido_retorno.
            END.
        END.

        IF tt-param.elimina = YES THEN DO:
           FOR FIRST b-int_ds_pedido WHERE
                     ROWID(b-int_ds_pedido) = ROWID(int_ds_pedido):
           END.
           IF AVAIL b-int_ds_pedido THEN
              DELETE b-int_ds_pedido.
           RELEASE b-int_ds_pedido.
        END.
    END.
    
    OUTPUT STREAM s-pedido   CLOSE.
    OUTPUT STREAM s-ped-prod CLOSE.
    OUTPUT STREAM s-ped-ret  CLOSE.
    
    CREATE tt-log.
    ASSIGN tt-log.tabela   = "int_ds_pedido_produto"
           tt-log.qtde-reg = i-cont-ped-prod
           tt-log.situacao = tt-param.elimina
           tt-log.dt-corte = da-dt-corte - 1.
    
    CREATE tt-log.
    ASSIGN tt-log.tabela   = "int_ds_pedido_retorno"
           tt-log.qtde-reg = i-cont-ped-ret
           tt-log.situacao = tt-param.elimina
           tt-log.dt-corte = da-dt-corte - 1.    
        
    CREATE tt-log.
    ASSIGN tt-log.tabela   = "int_ds_pedido"
           tt-log.qtde-reg = i-cont-pedido
           tt-log.situacao = tt-param.elimina
           tt-log.dt-corte = da-dt-corte - 1.
END.
/******************************************************************************************/                                                                                            

/********************* Tabelas int_ds_nota_loja, int_ds_nota_loja_item e int_ds_nota_loja_cartao - Manter 120 dias ********************/

IF  tt-param.nota-loja = YES THEN DO:

    DEF STREAM s-nota-loja.
    DEF STREAM s-nf-loja-it.
    DEF STREAM s-nf-loja-ca.

    ASSIGN da-dt-corte       = TODAY - 120
           i-cont-nota-loja  = 0
           i-cont-nf-loja-it = 0
           i-cont-nf-loja-ca = 0
           c-arq-exporta     = tt-param.dir-exporta + "int_ds_nota_loja_item.d".
    
    OUTPUT STREAM s-nf-loja-it TO VALUE(c-arq-exporta) APPEND.
    
    ASSIGN c-arq-exporta = tt-param.dir-exporta + "int_ds_nota_loja_cartao.d".
    
    OUTPUT STREAM s-nf-loja-ca TO VALUE(c-arq-exporta) APPEND.

    ASSIGN c-arq-exporta = tt-param.dir-exporta + "int_ds_nota_loja.d".
    
    OUTPUT STREAM s-nota-loja TO VALUE(c-arq-exporta) APPEND.

    FOR EACH int_ds_nota_loja NO-LOCK WHERE
             int_ds_nota_loja.emissao < da-dt-corte query-tuning(no-lookahead):                                              
    
        ASSIGN i-cont-nota-loja = i-cont-nota-loja + 1.
        RUN pi-acompanhar IN h-acomp (INPUT "Nota Loja (Cupons): " + STRING(i-cont-nota-loja,">>>,>>>,>>9")).
    
        IF int_ds_nota_loja.emissao > dt-contab-ate THEN
           NEXT.

        EXPORT STREAM s-nota-loja int_ds_nota_loja.
   
        FOR EACH int_ds_nota_loja_item OF int_ds_nota_loja NO-LOCK query-tuning(no-lookahead):   
    
            ASSIGN i-cont-nf-loja-it = i-cont-nf-loja-it + 1.
    
            EXPORT STREAM s-nf-loja-it int_ds_nota_loja_item.
    
            IF tt-param.elimina = YES THEN DO:
               FOR FIRST b-int_ds_nota_loja_item WHERE
                         ROWID(b-int_ds_nota_loja_item) = ROWID(int_ds_nota_loja_item):
               END.
               IF AVAIL b-int_ds_nota_loja_item THEN
                  DELETE b-int_ds_nota_loja_item.
               RELEASE b-int_ds_nota_loja_item.
            END.
        END.

        FOR EACH int_ds_nota_loja_cartao OF int_ds_nota_loja NO-LOCK query-tuning(no-lookahead):   
    
            ASSIGN i-cont-nf-loja-ca = i-cont-nf-loja-ca + 1.
    
            EXPORT STREAM s-nf-loja-ca int_ds_nota_loja_cartao.
    
            IF tt-param.elimina = YES THEN DO:
               FOR FIRST b-int_ds_nota_loja_cartao WHERE
                         ROWID(b-int_ds_nota_loja_cartao) = ROWID(int_ds_nota_loja_cartao):
               END.
               IF AVAIL b-int_ds_nota_loja_cartao THEN
                  DELETE b-int_ds_nota_loja_cartao.
               RELEASE b-int_ds_nota_loja_cartao.
            END.
        END.

        IF tt-param.elimina = YES THEN DO:
           FOR FIRST b-int_ds_nota_loja WHERE
                     ROWID(b-int_ds_nota_loja) = ROWID(int_ds_nota_loja):
           END.
           IF AVAIL b-int_ds_nota_loja THEN
              DELETE b-int_ds_nota_loja.
           RELEASE b-int_ds_nota_loja.
        END.
    END.
    
    OUTPUT STREAM s-nota-loja  CLOSE.
    OUTPUT STREAM s-nf-loja-it CLOSE.
    OUTPUT STREAM s-nf-loja-ca CLOSE.
    
    CREATE tt-log.
    ASSIGN tt-log.tabela   = "int_ds_nota_loja_item"
           tt-log.qtde-reg = i-cont-nf-loja-it
           tt-log.situacao = tt-param.elimina
           tt-log.dt-corte = da-dt-corte - 1.          
    
    CREATE tt-log.
    ASSIGN tt-log.tabela   = "int_ds_nota_loja_cartao"
           tt-log.qtde-reg = i-cont-nf-loja-ca
           tt-log.situacao = tt-param.elimina
           tt-log.dt-corte = da-dt-corte - 1.
    
    CREATE tt-log.
    ASSIGN tt-log.tabela   = "int_ds_nota_loja"
           tt-log.qtde-reg = i-cont-nota-loja
           tt-log.situacao = tt-param.elimina
           tt-log.dt-corte = da-dt-corte - 1.
END.
/******************************************************************************************/                                                                                            

/********************* Tabela int_ds_cliente - Manter 120 dias ******************/

IF  tt-param.cliente = YES THEN DO:

    ASSIGN da-dt-corte   = TODAY - 120
           i-cont        = 0
           c-arq-exporta = tt-param.dir-exporta + "int_ds_cliente.d".
    
    OUTPUT TO VALUE(c-arq-exporta) APPEND.
    
    FOR EACH int_ds_cliente NO-LOCK WHERE
             int_ds_cliente.dt_geracao < da-dt-corte query-tuning(no-lookahead):
    
        ASSIGN i-cont = i-cont + 1.
        RUN pi-acompanhar IN h-acomp (INPUT "Cliente: " + STRING(i-cont,">>>,>>>,>>9")).
    
        IF int_ds_cliente.dt_geracao > dt-contab-ate THEN
           NEXT.

        EXPORT int_ds_cliente.
    
        IF tt-param.elimina = YES THEN DO:
           FOR FIRST b-int_ds_cliente WHERE
                     ROWID(b-int_ds_cliente) = ROWID(int_ds_cliente):
           END.
           IF AVAIL b-int_ds_cliente THEN
              DELETE b-int_ds_cliente.
           RELEASE b-int_ds_cliente.
        END.    
    END.
    
    OUTPUT CLOSE.
    
    CREATE tt-log.
    ASSIGN tt-log.tabela   = "int_ds_cliente"
           tt-log.qtde-reg = i-cont
           tt-log.situacao = tt-param.elimina
           tt-log.dt-corte = da-dt-corte - 1.
END.
/******************************************************************************************/

/********************* Tabelas int_ds_ped_compra e int_ds_ordem_compra - Manter 120 dias ******************/

IF  tt-param.ped-compra = YES THEN DO:

    DEF STREAM s-ped-compra.
    DEF STREAM s-ord-compra.

    ASSIGN da-dt-corte   = TODAY - 120
           i-cont-ord    = 0
           i-cont-ped    = 0
           c-arq-exporta = tt-param.dir-exporta + "int_ds_ordem_compra.d".
    
    OUTPUT STREAM s-ord-compra TO VALUE(c-arq-exporta) APPEND.
    
    ASSIGN c-arq-exporta = tt-param.dir-exporta + "int_ds_ped_compra.d".
    
    OUTPUT STREAM s-ped-compra TO VALUE(c-arq-exporta) APPEND.

    FOR EACH int_ds_ped_compra NO-LOCK WHERE
             int_ds_ped_compra.data_pedido < da-dt-corte query-tuning(no-lookahead):                                              
    
        ASSIGN i-cont-ped = i-cont-ped + 1.
        RUN pi-acompanhar IN h-acomp (INPUT "Pedido Compra: " + STRING(i-cont-ped,">>>,>>>,>>9")).
    
        IF int_ds_ped_compra.data_pedido > dt-contab-ate THEN
           NEXT.

        EXPORT STREAM s-ped-compra int_ds_ped_compra.
    
        FOR EACH int_ds_ordem_compra NO-LOCK WHERE 
                 int_ds_ordem_compra.num_pedido_orig = int_ds_ped_compra.num_pedido_orig query-tuning(no-lookahead):   
    
            ASSIGN i-cont-ord = i-cont-ord + 1.
    
            EXPORT STREAM s-ord-compra int_ds_ordem_compra.
    
            IF tt-param.elimina = YES THEN DO:
               FOR FIRST b-int_ds_ordem_compra WHERE
                         ROWID(b-int_ds_ordem_compra) = ROWID(int_ds_ordem_compra):
               END.
               IF AVAIL b-int_ds_ordem_compra THEN
                  DELETE b-int_ds_ordem_compra.
               RELEASE b-int_ds_ordem_compra.
            END.
        END.

        IF tt-param.elimina = YES THEN DO:  
           FOR FIRST b-int_ds_ped_compra WHERE
                     ROWID(b-int_ds_ped_compra) = ROWID(int_ds_ped_compra):
           END.
           IF AVAIL b-int_ds_ped_compra THEN
              DELETE b-int_ds_ped_compra.
           RELEASE b-int_ds_ped_compra.
        END.
    END.
    
    OUTPUT STREAM s-ped-compra CLOSE.
    OUTPUT STREAM s-ord-compra CLOSE.
    
    CREATE tt-log.
    ASSIGN tt-log.tabela   = "int_ds_ordem_compra"
           tt-log.qtde-reg = i-cont-ord
           tt-log.situacao = tt-param.elimina
           tt-log.dt-corte = da-dt-corte - 1.
    
    CREATE tt-log.
    ASSIGN tt-log.tabela   = "int_ds_ped_compra"
           tt-log.qtde-reg = i-cont-ped
           tt-log.situacao = tt-param.elimina
           tt-log.dt-corte = da-dt-corte - 1.
END.
/******************************************************************************************/                                                                                            

/********************* Tabelas int_ds_doc e int_ds_it_doc - Manter 120 dias ******************/

IF  tt-param.doc = YES THEN DO:

    DEF STREAM s-doc.
    DEF STREAM s-it-doc.

    ASSIGN da-dt-corte   = TODAY - 120
           i-cont-doc    = 0
           i-cont-it-doc = 0
           c-arq-exporta = tt-param.dir-exporta + "int_ds_it_doc.d".
    
    OUTPUT STREAM s-it-doc TO VALUE(c-arq-exporta) APPEND.
    
    ASSIGN c-arq-exporta = tt-param.dir-exporta + "int_ds_doc.d".
    
    OUTPUT STREAM s-doc TO VALUE(c-arq-exporta) APPEND.

    FOR EACH int_ds_doc NO-LOCK WHERE
             int_ds_doc.dt_trans < da-dt-corte query-tuning(no-lookahead):
    
        ASSIGN i-cont-doc = i-cont-doc + 1.
        RUN pi-acompanhar IN h-acomp (INPUT "Docto. Mov. Estoque: " + STRING(i-cont-doc,">>>,>>>,>>9")).
    
        IF int_ds_doc.dt_trans > dt-contab-ate THEN
           NEXT.

        EXPORT STREAM s-doc int_ds_doc.
    
        FOR EACH int_ds_it_doc OF int_ds_doc NO-LOCK query-tuning(no-lookahead):   
    
            ASSIGN i-cont-it-doc = i-cont-it-doc + 1.
    
            EXPORT STREAM s-it-doc int_ds_it_doc.
    
            IF tt-param.elimina = YES THEN DO:
               FOR FIRST b-int_ds_it_doc WHERE
                         ROWID(b-int_ds_it_doc) = ROWID(int_ds_it_doc):
               END.
               IF AVAIL b-int_ds_it_doc THEN
                  DELETE b-int_ds_it_doc.
               RELEASE b-int_ds_it_doc.
            END.
        END.

        IF tt-param.elimina = YES THEN DO:
           FOR FIRST b-int_ds_doc WHERE
                     ROWID(b-int_ds_doc) = ROWID(int_ds_doc):
           END.
           IF AVAIL b-int_ds_doc THEN
              DELETE b-int_ds_doc.
           RELEASE b-int_ds_doc.
        END.
    END.
    
    OUTPUT STREAM s-doc    CLOSE.
    OUTPUT STREAM s-it-doc CLOSE.
    
    CREATE tt-log.
    ASSIGN tt-log.tabela   = "int_ds_it_doc"
           tt-log.qtde-reg = i-cont-it-doc
           tt-log.situacao = tt-param.elimina
           tt-log.dt-corte = da-dt-corte - 1.
       
    CREATE tt-log.
    ASSIGN tt-log.tabela   = "int_ds_doc"
           tt-log.qtde-reg = i-cont-doc
           tt-log.situacao = tt-param.elimina
           tt-log.dt-corte = da-dt-corte - 1.
END.
/******************************************************************************************/                                                                                            

/********************* Tabela int_ds_log - Manter 120 dias ******************/

IF  tt-param.LOG = YES THEN DO:

    ASSIGN da-dt-corte   = TODAY - 120
           i-cont        = 0
           c-arq-exporta = tt-param.dir-exporta + "int_ds_log.d".
    
    OUTPUT TO VALUE(c-arq-exporta) APPEND.
    
    FOR EACH int_ds_log NO-LOCK WHERE
             int_ds_log.dt_ocorrencia < da-dt-corte AND 
             int_ds_log.situacao      = 2 query-tuning(no-lookahead):
    
        ASSIGN i-cont = i-cont + 1.
        RUN pi-acompanhar IN h-acomp (INPUT "Mensagens (Logs): " + STRING(i-cont,">>>,>>>,>>9")).
    
        EXPORT int_ds_log.
    
        IF tt-param.elimina = YES THEN DO:
           FOR FIRST b-int_ds_log WHERE
                     ROWID(b-int_ds_log) = ROWID(int_ds_log):
           END.
           IF AVAIL b-int_ds_log THEN
              DELETE b-int_ds_log.
           RELEASE b-int_ds_log.
        END.
    END.
    
    OUTPUT CLOSE.
    
    CREATE tt-log.
    ASSIGN tt-log.tabela   = "int_ds_log"
           tt-log.qtde-reg = i-cont
           tt-log.situacao = tt-param.elimina
           tt-log.dt-corte = da-dt-corte - 1.
END.
/******************************************************************************************/

/********************* Tabela int_ds_xml_nfe - Manter 120 dias ******************/

IF  tt-param.xml-nfe = YES THEN DO:

    ASSIGN da-dt-corte   = TODAY - 120
           i-cont        = 0
           c-arq-exporta = tt-param.dir-exporta + "int_ds_xml_nfe.d".
    
    OUTPUT TO VALUE(c-arq-exporta) APPEND.
    
    FOR EACH int_ds_xml_nfe NO-LOCK WHERE
             int_ds_xml_nfe.emissao < da-dt-corte query-tuning(no-lookahead):
    
        ASSIGN i-cont = i-cont + 1.
        RUN pi-acompanhar IN h-acomp (INPUT "XML NFE: " + STRING(i-cont,">>>,>>>,>>9")).
    
        IF int_ds_xml_nfe.emissao > dt-contab-ate THEN
           NEXT.

        EXPORT int_ds_xml_nfe.
    
        IF tt-param.elimina = YES THEN DO:
           FOR FIRST b-int_ds_xml_nfe WHERE
                     ROWID(b-int_ds_xml_nfe) = ROWID(int_ds_xml_nfe):
           END.
           IF AVAIL b-int_ds_xml_nfe THEN
              DELETE b-int_ds_xml_nfe.
           RELEASE b-int_ds_xml_nfe.
        END.    
    END.
    
    OUTPUT CLOSE.
    
    CREATE tt-log.
    ASSIGN tt-log.tabela   = "int_ds_xml_nfe"
           tt-log.qtde-reg = i-cont
           tt-log.situacao = tt-param.elimina
           tt-log.dt-corte = da-dt-corte - 1.
END.
/******************************************************************************************/

/********************* Tabela int_ds_fat_conv_site - Manter 120 dias *********************/

IF  tt-param.fat-conv-site = YES THEN DO:

    ASSIGN da-dt-corte   = TODAY - 120
           i-cont        = 0
           c-arq-exporta = tt-param.dir-exporta + "int_ds_fat_conv_site.d".
    
    OUTPUT TO VALUE(c-arq-exporta) APPEND.
    
    FOR EACH int_ds_fat_conv_site NO-LOCK WHERE
             int_ds_fat_conv_site.dat_cupom < da-dt-corte query-tuning(no-lookahead):
    
        ASSIGN i-cont = i-cont + 1.
        RUN pi-acompanhar IN h-acomp (INPUT "Fat. Convˆnio Site: " + STRING(i-cont,">>>,>>>,>>9")).
    
        IF int_ds_fat_conv_site.dat_cupom > dt-contab-ate THEN
           NEXT.

        EXPORT int_ds_fat_conv_site.
    
        IF tt-param.elimina = YES THEN DO:
           FOR FIRST b-int_ds_fat_conv_site WHERE
                     ROWID(b-int_ds_fat_conv_site) = ROWID(int_ds_fat_conv_site):
           END.
           IF AVAIL b-int_ds_fat_conv_site THEN
              DELETE b-int_ds_fat_conv_site.
           RELEASE b-int_ds_fat_conv_site.
        END.
    END.
    
    OUTPUT CLOSE.
    
    CREATE tt-log.
    ASSIGN tt-log.tabela   = "int_ds_fat_conv_site"
           tt-log.qtde-reg = i-cont
           tt-log.situacao = tt-param.elimina
           tt-log.dt-corte = da-dt-corte - 1.
END.
/******************************************************************************************/

/********************* Tabela CST_TIT_AP - Manter 120 dias *********************/

IF  tt-param.tit-ap = YES THEN DO:

    ASSIGN da-dt-corte   = TODAY - 120
           i-cont        = 0
           c-arq-exporta = tt-param.dir-exporta + "cst_tit_ap.d".
    
    OUTPUT TO VALUE(c-arq-exporta) APPEND.
    
    FOR EACH cst_tit_ap NO-LOCK WHERE
             cst_tit_ap.dat_vencto_tit_ap < da-dt-corte query-tuning(no-lookahead):
    
        ASSIGN i-cont = i-cont + 1.
        RUN pi-acompanhar IN h-acomp (INPUT "Titulos AP: " + STRING(i-cont,">>>,>>>,>>9")).
    
        IF cst_tit_ap.dat_vencto_tit_ap > dt-contab-ate THEN
           NEXT.

        EXPORT cst_tit_ap.
    
        IF tt-param.elimina = YES THEN DO:
           FOR FIRST b-cst_tit_ap WHERE
                     ROWID(b-cst_tit_ap) = ROWID(cst_tit_ap):
           END.
           IF AVAIL b-cst_tit_ap THEN
              DELETE b-cst_tit_ap.
           RELEASE b-cst_tit_ap.
        END.
    END.
    
    OUTPUT CLOSE.
    
    CREATE tt-log.
    ASSIGN tt-log.tabela   = "cst_tit_ap"
           tt-log.qtde-reg = i-cont
           tt-log.situacao = tt-param.elimina
           tt-log.dt-corte = da-dt-corte - 1.
END.
/******************************************************************************************/

{include/i-rpcab.i}
{include/i-rpout.i}

view frame f-cabec.
view frame f-rodape.

FOR EACH tt-log query-tuning(no-lookahead):
    DISP tt-log WITH STREAM-IO NO-BOX WIDTH 132 DOWN FRAME f-log.
END.

run pi-finalizar in h-acomp.   

{include/i-rpclo.i}


