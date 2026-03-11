/********************************************************************************
** Copyright DATASUL S.A. (1997)
** Todos os Direitos Reservados.
**
** Este fonte e de propriedade exclusiva da DATASUL, sua reproducao
** parcial ou total por qualquer meio, so podera ser feita mediante
** autorizacao expressa.
*******************************************************************************/
{include/i-prgvrs.i NIRE0101RP 2.00.00.000}  /*** 020016 ***/

/* ---------------------[ VERSAO ]-------------------- */
/******************************************************************************
**
**   Programa: NIRE0101RP.P
**
**   Objetivo: Relat¢rio Entrada de Mercadorias 
**
******************************************************************************/

define temp-table tt-param
    field destino          as integer
    field arquivo          as char
    field usuario          as char
    field data-exec        as date
    field hora-exec        as integer
    field serie-ini        AS CHAR
    field serie-fim        AS CHAR  
    field nr-docto-ini     AS CHAR     
    field nr-docto-fim     AS CHAR 
    field natur-ini        AS CHAR   
    field natur-fim        AS CHAR     
    field forn-ini         AS INT   
    field forn-fim         AS INT
    field estab-ini        AS CHAR  
    field estab-fim        AS CHAR    
    field emis-ini         AS DATE       
    field emis-fim         AS DATE.

def temp-table tt-raw-digita
    field raw-digita as raw.

DEF TEMP-TABLE tt-excel 
    FIELD dt-emissao     AS DATE FORMAT "99/99/9999"
    FIELD dt-transacao   AS DATE FORMAT "99/99/9999"
    FIELD cod-estabel    AS CHAR
    FIELD cod-emitente   AS INT
    FIELD cnpj           AS CHAR
    FIELD natur-oper     AS CHAR
    FIELD nro-docto      AS CHAR
    FIELD serie          AS CHAR
    FIELD nr-contrato    AS INT
    FIELD conta-trans    AS CHAR
    FIELD vlr-desc       AS DEC
    FIELD vlr-merc       AS DEC
    FIELD sit-nfe        AS CHAR
    FIELD usuario        AS CHAR
    FIELD doc-import     AS CHAR
    FIELD vlr-total      AS DEC
    FIELD sequencia      AS INT
    FIELD it-codigo      AS CHAR
    FIELD descricao      AS CHAR
    FIELD un             AS CHAR
    FIELD numero-ordem   AS INT
    FIELD nr-ord-produ   AS INT
    FIELD conta-contabil AS CHAR
    FIELD qtde-item-doc  AS DEC
    FIELD vlr-item-doc   AS DEC
    FIELD desconto       AS DEC
    FIELD vlr-tot-item   AS DEC
    FIELD data-pedido    AS DATE
    FIELD num-pedido     AS INT
    FIELD cond-pagto     AS CHAR
    FIELD qtde-pedido    AS DEC
    FIELD valor-pedido   AS DEC
    FIELD mensagem       AS CHAR
    FIELD vencimento     AS CHAR
    FIELD situacao       AS CHAR
    INDEX data-docto 
            dt-emissao  
            nro-docto   
            serie       
            cod-emitente
            numero-ordem.

def input parameter raw-param as raw no-undo.
def input parameter table for tt-raw-digita.

{cdp/cdcfgman.i}

create tt-param.
raw-transfer raw-param to tt-param.

DEF VAR chExcelApplication AS COM-HANDLE       NO-UNDO.
DEF VAR chWorkbook         AS COMPONENT-HANDLE NO-UNDO.
DEF VAR ch-Planilha        AS COMPONENT-HANDLE NO-UNDO.
def var h-acomp            as handle           no-undo. 
DEF VAR i-linha            AS INT              NO-UNDO.
DEF VAR de-qtde-ped        AS DEC              NO-UNDO.
DEF VAR de-vlr-ped         AS DEC              NO-UNDO.
DEF VAR c-mensagem         AS CHAR EXTENT 18   NO-UNDO.
DEF VAR i-cont-msg         AS INT              NO-UNDO.
DEF VAR l-erro             AS LOGICAL          NO-UNDO.
DEF VAR i-ordem            AS INT              NO-UNDO.
DEF VAR i-pedido           AS INT              NO-UNDO.
DEF VAR i-nr-contrato      AS INT              NO-UNDO.
DEF VAR de-quantidade      AS DEC              NO-UNDO.
DEF VAR i-cont-venc        AS INT              NO-UNDO.
DEF VAR da-vencimento      AS DATE FORMAT "99/99/9999" EXTENT 8 NO-UNDO.
DEF VAR i-cont-reg         AS INT              NO-UNDO.
DEF VAR da-data-pedido     AS DATE FORMAT "99/99/9999" NO-UNDO.
DEF VAR c-cta-contabil     AS CHAR NO-UNDO.
DEF VAR i-sit-nfe          AS INT NO-UNDO.
DEF VAR c-sit-nfe          AS CHAR INIT "NF-e n∆o Gerada,Em Processamento no EAI,Uso Autorizado,Uso Denegado,Documento Rejeitado,Documento Cancelado,Documento Inutilizado,              
                                         Em Processamento Aplic. Transmiss∆o,Em Processamento na SEFAZ,Em processamento no SCAN,NF-e Gerada,NF-e em Processo de Cancelamento,   
                                         NF-e em Processo de Inutilizaá∆o,NF-e Pendente de Retorno,DPEC Recebido pelo SCE" NO-UNDO.

create tt-param.
raw-transfer raw-param to tt-param.    

run utp/ut-acomp.p persistent set h-acomp. 

CREATE "Excel.Application" chExcelApplication.

ASSIGN chExcelApplication:SheetsInNewWorkbook            = 1
       chWorkbook                                        = chExcelApplication:Workbooks:ADD("")
       ch-planilha                                       = chexcelapplicAtion:sheets:ITEM(1)
       ch-planilha:Name                                  = "Entrada de Mercadorias"
       ch-planilha:range("A1:AI1"):MergeCells            = TRUE
       ch-planilha:range("A1"):VALUE                     = "Entrada de Mercadorias - Emiss∆o: " + STRING(TODAY,"99/99/9999")
       ch-planilha:range("A1:AI1"):FONT:bold             = TRUE
       ch-planilha:range("A1:AI1"):FONT:SIZE             = 22
       ch-planilha:range("A1:AI1"):Interior:ColorIndex   = 15
       ch-planilha:range("A1:AI1"):HorizontalAlignment   = 3
       ch-planilha:range("A1:AI1"):Borders(7):LineStyle  = 1
       ch-planilha:range("A1:AI1"):Borders(7):Weight     = 3
       ch-planilha:range("A1:AI1"):Borders(8):LineStyle  = 1
       ch-planilha:range("A1:AI1"):Borders(8):Weight     = 3
       ch-planilha:range("A1:AI1"):Borders(9):LineStyle  = 1
       ch-planilha:range("A1:AI1"):Borders(9):Weight     = 3
       ch-planilha:range("A1:AI1"):Borders(10):LineStyle = 1
       ch-planilha:range("A1:AI1"):Borders(10):Weight    = 3.

run pi-inicializar in h-acomp ("Entrada de Mercadorias").

EMPTY TEMP-TABLE tt-excel.

ASSIGN i-cont-reg = 0.

FOR EACH docum-est WHERE
         docum-est.serie-docto  >= tt-param.serie-ini    AND
         docum-est.serie-docto  <= tt-param.serie-fim    AND
         docum-est.nro-docto    >= tt-param.nr-docto-ini AND
         docum-est.nro-docto    <= tt-param.nr-docto-fim AND
         docum-est.cod-emitente >= tt-param.forn-ini     AND
         docum-est.cod-emitente <= tt-param.forn-fim     AND
         docum-est.nat-operacao >= tt-param.natur-ini    AND 
         docum-est.nat-operacao <= tt-param.natur-fim    AND
         docum-est.cod-estabel  >= tt-param.estab-ini    AND 
         docum-est.cod-estabel  <= tt-param.estab-fim    AND
         docum-est.dt-emissao   >= tt-param.emis-ini     AND
         docum-est.dt-emissao   <= tt-param.emis-fim     NO-LOCK QUERY-TUNING(NO-LOOKAHEAD):
            
    ASSIGN i-cont-reg = i-cont-reg + 1.

    run pi-acompanhar in h-acomp (input "Nr. Docto: " + docum-est.nro-docto + " - " + STRING(i-cont-reg,">>>,>>9")).

    ASSIGN i-cont-venc    = 1
           da-vencimento  = ?
           c-cta-contabil = "".

    FOR EACH dupli-apagar FIELDS (dt-vencim)
             {cdp/cd8900.i "docum-est" "dupli-apagar"} NO-LOCK QUERY-TUNING(NO-LOOKAHEAD):

        IF i-cont-venc = 1 THEN
           assign da-vencimento[1] = dupli-apagar.dt-vencim.
        IF i-cont-venc = 2 THEN
           assign da-vencimento[2] = dupli-apagar.dt-vencim.
        IF i-cont-venc = 3 THEN
           assign da-vencimento[3] = dupli-apagar.dt-vencim.
        IF i-cont-venc = 4 THEN
           assign da-vencimento[4] = dupli-apagar.dt-vencim.
        IF i-cont-venc = 5 THEN
           assign da-vencimento[5] = dupli-apagar.dt-vencim.
        IF i-cont-venc = 6 THEN
           assign da-vencimento[6] = dupli-apagar.dt-vencim.
        IF i-cont-venc = 7 THEN
           assign da-vencimento[7] = dupli-apagar.dt-vencim.
        IF i-cont-venc = 8 THEN
           assign da-vencimento[8] = dupli-apagar.dt-vencim.

        ASSIGN i-cont-venc = i-cont-venc + 1.

        IF i-cont-venc = 9 THEN
           LEAVE.
    END.

    FOR FIRST movto-estoq OF docum-est WHERE
              movto-estoq.tipo-trans = 1 AND
              movto-estoq.esp-docto  = 21 NO-LOCK QUERY-TUNING(NO-LOOKAHEAD):
    END.
    IF AVAIL movto-estoq THEN
       ASSIGN c-cta-contabil = movto-estoq.ct-saldo.

    FIND FIRST emitente WHERE 
               emitente.cod-emitente = docum-est.cod-emitente NO-LOCK NO-ERROR.

    ASSIGN i-cont-msg = 1
           c-mensagem = ""
           l-erro     = NO.

    FOR EACH consist-nota WHERE
             consist-nota.nro-docto    = docum-est.nro-docto    AND
             consist-nota.serie-docto  = docum-est.serie-docto  AND
             consist-nota.nat-operacao = docum-est.nat-operacao AND
             consist-nota.cod-emitente = docum-est.cod-emitente AND 
             consist-nota.tipo         < 3 NO-LOCK QUERY-TUNING(NO-LOOKAHEAD):
        run utp/ut-msgs.p (input "msg",
                           input consist-nota.mensagem,
                           input "").
        ASSIGN l-erro = YES.

        IF i-cont-msg = 1 THEN
           assign c-mensagem[1] = return-value.
        IF i-cont-msg = 2 THEN
           assign c-mensagem[2] = return-value.
        IF i-cont-msg = 3 THEN
           assign c-mensagem[3] = return-value.
        IF i-cont-msg = 4 THEN
           assign c-mensagem[4] = return-value.
        IF i-cont-msg = 5 THEN
           assign c-mensagem[5] = return-value.

        ASSIGN i-cont-msg = i-cont-msg + 1.

        IF i-cont-msg = 6 THEN
           LEAVE.
    END.

    ASSIGN i-cont-msg = 6.

    FOR EACH int_ds_doc_erro WHERE
             int_ds_doc_erro.serie_docto  = docum-est.serie-docto  AND
             int_ds_doc_erro.nro_docto    = docum-est.nro-docto    AND
             int_ds_doc_erro.cod_emitente = docum-est.cod-emitente AND
             int_ds_doc_erro.nat_operacao = docum-est.nat-operacao NO-LOCK QUERY-TUNING(NO-LOOKAHEAD):

        ASSIGN l-erro = YES.

        IF i-cont-msg = 6 THEN
           assign c-mensagem[6] = int_ds_doc_erro.descricao.
        IF i-cont-msg = 7 THEN
           assign c-mensagem[7] = int_ds_doc_erro.descricao.
        IF i-cont-msg = 8 THEN
           assign c-mensagem[8] = int_ds_doc_erro.descricao.
        IF i-cont-msg = 9 THEN
           assign c-mensagem[9] = int_ds_doc_erro.descricao.
        IF i-cont-msg = 10 THEN
           assign c-mensagem[10] = int_ds_doc_erro.descricao.

        ASSIGN i-cont-msg = i-cont-msg + 1.

        IF i-cont-msg = 11 THEN
           LEAVE.
    END.

    ASSIGN i-cont-msg = 11.
    
    FOR FIRST int_ds_docto_xml_compras WHERE
              int_ds_docto_xml_compras.serie        = docum-est.serie-docto AND
              int_ds_docto_xml_compras.nnf          = docum-est.nro-docto   AND
              int_ds_docto_xml_compras.cod_emitente = docum-est.cod-emitente NO-LOCK:
    END.
    IF AVAIL int_ds_docto_xml_compras THEN DO:
       IF int_ds_docto_xml_compras.qtde_original <> int_ds_docto_xml_compras.qtde_entregue THEN
          ASSIGN c-mensagem[11] = "Quantidade do Pedido divergente da Quantidade da Nota. Usu†rio Aprovaá∆o: " + int_ds_docto_xml_compras.usuario_aprovacao
                 l-erro         = YES.
       IF int_ds_docto_xml_compras.valor_original <> int_ds_docto_xml_compras.valor_etregue THEN
          ASSIGN c-mensagem[12] = "Valor do Pedido divergente do Valor da Nota. Usu†rio Aprovaá∆o: " + int_ds_docto_xml_compras.usuario_aprovacao
                 l-erro         = YES.
    END.

    ASSIGN i-cont-msg = 13.

    FOR EACH int_ds_docto_xml_log_compras WHERE
             int_ds_docto_xml_log_compras.serie        = docum-est.serie-docto  AND
             int_ds_docto_xml_log_compras.nNF          = docum-est.nro-docto    AND
             int_ds_docto_xml_log_compras.cod_emitente = docum-est.cod-emitente NO-LOCK QUERY-TUNING(NO-LOOKAHEAD):

        ASSIGN l-erro = YES.

        IF i-cont-msg = 13 THEN
           assign c-mensagem[13] = int_ds_docto_xml_log_compras.descricao.
        IF i-cont-msg = 14 THEN
           assign c-mensagem[14] = int_ds_docto_xml_log_compras.descricao.
        IF i-cont-msg = 15 THEN
           assign c-mensagem[15] = int_ds_docto_xml_log_compras.descricao.
        IF i-cont-msg = 16 THEN
           assign c-mensagem[16] = int_ds_docto_xml_log_compras.descricao.
        IF i-cont-msg = 17 THEN
           assign c-mensagem[17] = int_ds_docto_xml_log_compras.descricao.
        IF i-cont-msg = 18 THEN
           assign c-mensagem[18] = int_ds_docto_xml_log_compras.descricao.

        ASSIGN i-cont-msg = i-cont-msg + 1.

        IF i-cont-msg = 19 THEN
           LEAVE.
    END.

    FOR EACH item-doc-est OF docum-est NO-LOCK QUERY-TUNING(NO-LOOKAHEAD):
        ASSIGN de-qtde-ped    = 0
               de-vlr-ped     = 0
               i-nr-contrato  = 0
               da-data-pedido = ?
               i-pedido       = 0
               i-ordem        = 0
               de-quantidade  = item-doc-est.quantidade.

        IF item-doc-est.ct-codigo <> "" THEN
           ASSIGN c-cta-contabil = item-doc-est.ct-codigo.

        FIND FIRST rat-ordem OF item-doc-est NO-LOCK NO-ERROR.
        IF AVAIL rat-ordem THEN DO:
           ASSIGN i-nr-contrato = rat-ordem.nr-contrato                                      
                  i-pedido      = rat-ordem.num-pedido                                       
                  i-ordem       = rat-ordem.numero-ordem                                     
                  de-qtde-ped   = rat-ordem.quantidade                                       
                  /*de-vlr-ped    = rat-ordem.val-medicao*/
                  de-quantidade = rat-ordem.quantidade.
        END.
     
        FIND FIRST ordem-compra WHERE
                   ordem-compra.numero-ordem = i-ordem NO-LOCK NO-ERROR.
        IF AVAIL ordem-compra THEN DO:
           IF  ordem-compra.qt-solic   <> 0
           AND /*ordem-compra.preco-unit*/ ordem-compra.pre-unit-for <> 0 THEN DO:
               ASSIGN de-qtde-ped = ordem-compra.qt-solic
                      de-vlr-ped  = /*ordem-compra.preco-unit*/ ordem-compra.pre-unit-for
                      i-pedido    = IF i-pedido = 0 THEN ordem-compra.num-pedido ELSE i-pedido.
           END.
        END.

        FIND FIRST pedido-compr WHERE
                   pedido-compr.num-pedido = i-pedido NO-LOCK NO-ERROR.
        IF AVAIL pedido-compr THEN DO:
           ASSIGN da-data-pedido = pedido-compr.data-pedido.
           IF pedido-compr.nr-contrato <> 0 THEN
              ASSIGN i-nr-contrato = pedido-compr.nr-contrato.
           FIND FIRST cond-pagto WHERE
                      cond-pagto.cod-cond-pag = pedido-compr.cod-cond-pag NO-LOCK NO-ERROR. 
        END.

        FIND FIRST ordem-compra WHERE
                   ordem-compra.numero-ordem = item-doc-est.numero-ordem NO-LOCK NO-ERROR.
        IF AVAIL ordem-compra THEN DO:
           IF  ordem-compra.qt-solic   <> 0
           AND /*ordem-compra.preco-unit*/ ordem-compra.pre-unit-for <> 0 THEN DO:
               ASSIGN de-qtde-ped = ordem-compra.qt-solic
                      de-vlr-ped  = /*ordem-compra.preco-unit*/ ordem-compra.pre-unit-for
                      i-ordem     = ordem-compra.numero-ordem
                      i-pedido    = IF i-pedido = 0 THEN ordem-compra.num-pedido ELSE i-pedido.
           END.
        END.

        /*FIND FIRST cotacao-item WHERE
                   cotacao-item.numero-ordem = i-ordem AND
                   cotacao-item.it-codigo    = item-doc-est.it-codigo AND
                   cotacao-item.cot-aprovada = YES NO-LOCK NO-ERROR.
        IF AVAIL cotacao-item THEN
           ASSIGN de-vlr-ped = cotacao-item.preco-fornec.*/

        FIND FIRST pedido-compr WHERE
                   pedido-compr.num-pedido = item-doc-est.num-pedido NO-LOCK NO-ERROR.
        IF AVAIL pedido-compr THEN DO:
           ASSIGN da-data-pedido = pedido-compr.data-pedido
                  i-pedido       = item-doc-est.num-pedido.
           IF pedido-compr.nr-contrato <> 0 THEN
              ASSIGN i-nr-contrato = pedido-compr.nr-contrato.
           FIND FIRST cond-pagto WHERE
                      cond-pagto.cod-cond-pag = pedido-compr.cod-cond-pag NO-LOCK NO-ERROR. 
        END.

        FIND FIRST ITEM WHERE
                   ITEM.it-codigo = item-doc-est.it-codigo NO-LOCK NO-ERROR.

        ASSIGN i-sit-nfe = docum-est.idi-sit-nf-eletro.
        IF i-sit-nfe = 0 THEN
           ASSIGN i-sit-nfe = 1.

        CREATE tt-excel.
        ASSIGN tt-excel.dt-emissao     = docum-est.dt-emissao
               tt-excel.dt-transacao   = docum-est.dt-trans
               tt-excel.cod-estabel    = docum-est.cod-estabel
               tt-excel.cod-emitente   = docum-est.cod-emitente
               tt-excel.cnpj           = IF AVAIL emitente THEN emitente.cgc ELSE ""
               tt-excel.natur-oper     = docum-est.nat-operacao
               tt-excel.nro-docto      = docum-est.nro-docto
               tt-excel.serie          = docum-est.serie-docto 
               tt-excel.nr-contrato    = i-nr-contrato
               tt-excel.conta-trans    = docum-est.ct-transit
               tt-excel.vlr-desc       = docum-est.tot-desconto
               tt-excel.vlr-merc       = docum-est.valor-mercad
               tt-excel.sit-nfe        = ENTRY(i-sit-nfe,c-sit-nfe)
               tt-excel.usuario        = docum-est.usuario
               tt-excel.doc-import     = IF docum-est.origem = "I" THEN "Sim" ELSE "N∆o"
               tt-excel.vlr-total      = docum-est.tot-valor
               tt-excel.sequencia      = item-doc-est.sequencia
               tt-excel.it-codigo      = item-doc-est.it-codigo
               tt-excel.descricao      = IF AVAIL ITEM THEN ITEM.desc-item ELSE ""
               tt-excel.un             = item-doc-est.un
               tt-excel.numero-ordem   = i-ordem
               tt-excel.nr-ord-produ   = item-doc-est.nr-ord-produ
               tt-excel.conta-contabil = c-cta-contabil 
               tt-excel.qtde-item-doc  = de-quantidade
               tt-excel.vlr-item-doc   = item-doc-est.preco-total[1] / de-quantidade 
               tt-excel.desconto       = item-doc-est.desconto[1]
               tt-excel.vlr-tot-item   = item-doc-est.preco-total[1] - item-doc-est.desconto[1]
               tt-excel.data-pedido    = da-data-pedido 
               tt-excel.num-pedido     = i-pedido
               tt-excel.cond-pagto     = IF AVAIL cond-pagto   THEN cond-pagto.descricao     ELSE ""
               tt-excel.qtde-pedido    = de-qtde-ped
               tt-excel.valor-pedido   = de-vlr-ped
               tt-excel.mensagem       = c-mensagem[1]
               tt-excel.vencimento     = string(da-vencimento[1],"99/99/9999")
               tt-excel.situacao       = IF docum-est.ce-atual = YES THEN
                                            IF l-erro = YES THEN
                                               "Atualizado com Erro"
                                            ELSE
                                              "Atualizado"
                                         ELSE 
                                            IF l-erro = YES THEN
                                               "Pendente com Erro"
                                             ELSE
                                               "Pendente".

        DO i-cont-msg = 2 TO 18:
           IF c-mensagem[i-cont-msg] <> "" THEN DO:
              IF tt-excel.mensagem <> "" THEN
                 ASSIGN tt-excel.mensagem = tt-excel.mensagem + " / " + c-mensagem[i-cont-msg].
              ELSE
                 ASSIGN tt-excel.mensagem = c-mensagem[i-cont-msg].
           END.
        END.

        DO i-cont-venc = 2 TO 8:
           IF da-vencimento[i-cont-venc] <> ? THEN DO:
              IF tt-excel.vencimento <> "" THEN
                 ASSIGN tt-excel.vencimento = tt-excel.vencimento + " / " + string(da-vencimento[i-cont-venc],"99/99/9999").
              ELSE
                 ASSIGN tt-excel.vencimento = string(da-vencimento[i-cont-venc],"99/99/9999").
           END.
        END.
    END.
END.

ASSIGN i-linha = 2.

ch-planilha:range("A" + STRING(i-linha)):VALUE                 = "Data Emiss∆o".                                 
ch-planilha:range("A" + STRING(i-linha)):Borders(7):LineStyle  = 1.
ch-planilha:range("A" + STRING(i-linha)):Borders(7):Weight     = 3.

ch-planilha:range("B" + STRING(i-linha)):VALUE                 = "Data Transaá∆o".                                 
ch-planilha:range("B" + STRING(i-linha)):Borders(7):LineStyle  = 1.
ch-planilha:range("B" + STRING(i-linha)):Borders(7):Weight     = 3.
                                                                                                         
ch-planilha:range("C" + STRING(i-linha)):VALUE                 = "Estab".                            
ch-planilha:range("C" + STRING(i-linha)):Borders(7):LineStyle  = 1.                                      
ch-planilha:range("C" + STRING(i-linha)):Borders(7):Weight     = 3.                                      
                                                                                                         
ch-planilha:range("D" + STRING(i-linha)):VALUE                 = "Emitente".                                   
ch-planilha:range("D" + STRING(i-linha)):Borders(7):LineStyle  = 1.                                      
ch-planilha:range("D" + STRING(i-linha)):Borders(7):Weight     = 3.                                      
                                                                                                         
ch-planilha:range("E" + STRING(i-linha)):VALUE                 = "CNPJ".                               
ch-planilha:range("E" + STRING(i-linha)):Borders(7):LineStyle  = 1.                                       
ch-planilha:range("E" + STRING(i-linha)):Borders(7):Weight     = 3.                                    
                                                                                                         
ch-planilha:range("F" + STRING(i-linha)):VALUE                 = "Natur. Oper.".                             
ch-planilha:range("F" + STRING(i-linha)):Borders(7):LineStyle  = 1.                                      
ch-planilha:range("F" + STRING(i-linha)):Borders(7):Weight     = 3.                                      
                                                                                                         
ch-planilha:range("G" + STRING(i-linha)):VALUE                 = "Documento".                                
ch-planilha:range("G" + STRING(i-linha)):Borders(7):LineStyle  = 1.                                      
ch-planilha:range("G" + STRING(i-linha)):Borders(7):Weight     = 3.                                      

ch-planilha:range("H" + STRING(i-linha)):VALUE                 = "SÇrie".
ch-planilha:range("H" + STRING(i-linha)):Borders(7):LineStyle  = 1.
ch-planilha:range("H" + STRING(i-linha)):Borders(7):Weight     = 3.

ch-planilha:range("I" + STRING(i-linha)):VALUE                 = "Sit. Docto.".
ch-planilha:range("I" + STRING(i-linha)):Borders(7):LineStyle  = 1.
ch-planilha:range("I" + STRING(i-linha)):Borders(7):Weight     = 3.

ch-planilha:range("J" + STRING(i-linha)):VALUE                 = "Nr. Contrato".
ch-planilha:range("J" + STRING(i-linha)):Borders(7):LineStyle  = 1.
ch-planilha:range("J" + STRING(i-linha)):Borders(7):Weight     = 3.

ch-planilha:range("K" + STRING(i-linha)):VALUE                 = "Conta Transit.".
ch-planilha:range("K" + STRING(i-linha)):Borders(7):LineStyle  = 1.
ch-planilha:range("K" + STRING(i-linha)):Borders(7):Weight     = 3.

ch-planilha:range("L" + STRING(i-linha)):VALUE                 = "Tot. Desconto".
ch-planilha:range("L" + STRING(i-linha)):Borders(7):LineStyle  = 1.
ch-planilha:range("L" + STRING(i-linha)):Borders(7):Weight     = 3.

ch-planilha:range("M" + STRING(i-linha)):VALUE                 = "Tot. Mercadoria".
ch-planilha:range("M" + STRING(i-linha)):Borders(7):LineStyle  = 1.
ch-planilha:range("M" + STRING(i-linha)):Borders(7):Weight     = 3.

ch-planilha:range("N" + STRING(i-linha)):VALUE                 = "Situaá∆o NFe".
ch-planilha:range("N" + STRING(i-linha)):Borders(7):LineStyle  = 1.
ch-planilha:range("N" + STRING(i-linha)):Borders(7):Weight     = 3.

ch-planilha:range("O" + STRING(i-linha)):VALUE                 = "Usu†rio".
ch-planilha:range("O" + STRING(i-linha)):Borders(7):LineStyle  = 1.
ch-planilha:range("O" + STRING(i-linha)):Borders(7):Weight     = 3.

ch-planilha:range("P" + STRING(i-linha)):VALUE                 = "Doc. Import.".
ch-planilha:range("P" + STRING(i-linha)):Borders(7):LineStyle  = 1.
ch-planilha:range("P" + STRING(i-linha)):Borders(7):Weight     = 3.

ch-planilha:range("Q" + STRING(i-linha)):VALUE                 = "Valor Total".
ch-planilha:range("Q" + STRING(i-linha)):Borders(7):LineStyle  = 1.
ch-planilha:range("Q" + STRING(i-linha)):Borders(7):Weight     = 3.

ch-planilha:range("R" + STRING(i-linha)):VALUE                 = "Seq.".
ch-planilha:range("R" + STRING(i-linha)):Borders(7):LineStyle  = 1.
ch-planilha:range("R" + STRING(i-linha)):Borders(7):Weight     = 3.

ch-planilha:range("S" + STRING(i-linha)):VALUE                 = "Item".
ch-planilha:range("S" + STRING(i-linha)):Borders(7):LineStyle  = 1.
ch-planilha:range("S" + STRING(i-linha)):Borders(7):Weight     = 3.

ch-planilha:range("T" + STRING(i-linha)):VALUE                 = "Descriá∆o".
ch-planilha:range("T" + STRING(i-linha)):Borders(7):LineStyle  = 1.
ch-planilha:range("T" + STRING(i-linha)):Borders(7):Weight     = 3.

ch-planilha:range("U" + STRING(i-linha)):VALUE                 = "Un".
ch-planilha:range("U" + STRING(i-linha)):Borders(7):LineStyle  = 1.
ch-planilha:range("U" + STRING(i-linha)):Borders(7):Weight     = 3.

ch-planilha:range("V" + STRING(i-linha)):VALUE                 = "Ord. Compra".
ch-planilha:range("V" + STRING(i-linha)):Borders(7):LineStyle  = 1.
ch-planilha:range("V" + STRING(i-linha)):Borders(7):Weight     = 3.

ch-planilha:range("W" + STRING(i-linha)):VALUE                 = "Ord. Prod.".
ch-planilha:range("W" + STRING(i-linha)):Borders(7):LineStyle  = 1.
ch-planilha:range("W" + STRING(i-linha)):Borders(7):Weight     = 3.

ch-planilha:range("X" + STRING(i-linha)):VALUE                 = "Conta Cont†bil".
ch-planilha:range("X" + STRING(i-linha)):Borders(7):LineStyle  = 1.
ch-planilha:range("X" + STRING(i-linha)):Borders(7):Weight     = 3.

ch-planilha:range("Y" + STRING(i-linha)):VALUE                 = "Quantidade".
ch-planilha:range("Y" + STRING(i-linha)):Borders(7):LineStyle  = 1.
ch-planilha:range("Y" + STRING(i-linha)):Borders(7):Weight     = 3.

ch-planilha:range("Z" + STRING(i-linha)):VALUE                 = "Valor Material".
ch-planilha:range("Z" + STRING(i-linha)):Borders(7):LineStyle  = 1.
ch-planilha:range("Z" + STRING(i-linha)):Borders(7):Weight     = 3.

ch-planilha:range("AA" + STRING(i-linha)):VALUE                 = "Desconto Material".
ch-planilha:range("AA" + STRING(i-linha)):Borders(7):LineStyle  = 1.
ch-planilha:range("AA" + STRING(i-linha)):Borders(7):Weight     = 3.

ch-planilha:range("AB" + STRING(i-linha)):VALUE                 = "Preáo Total".
ch-planilha:range("AB" + STRING(i-linha)):Borders(7):LineStyle  = 1.
ch-planilha:range("AB" + STRING(i-linha)):Borders(7):Weight     = 3.

ch-planilha:range("AC" + STRING(i-linha)):VALUE                 = "Data Pedido".
ch-planilha:range("AC" + STRING(i-linha)):Borders(7):LineStyle  = 1.
ch-planilha:range("AC" + STRING(i-linha)):Borders(7):Weight     = 3.

ch-planilha:range("AD" + STRING(i-linha)):VALUE                 = "Nr. Pedido".
ch-planilha:range("AD" + STRING(i-linha)):Borders(7):LineStyle  = 1.
ch-planilha:range("AD" + STRING(i-linha)):Borders(7):Weight     = 3.

ch-planilha:range("AE" + STRING(i-linha)):VALUE                 = "Cond. Pagto. Pedido".
ch-planilha:range("AE" + STRING(i-linha)):Borders(7):LineStyle  = 1.
ch-planilha:range("AE" + STRING(i-linha)):Borders(7):Weight     = 3.

ch-planilha:range("AF" + STRING(i-linha)):VALUE                 = "Vencimento".
ch-planilha:range("AF" + STRING(i-linha)):Borders(7):LineStyle  = 1.
ch-planilha:range("AF" + STRING(i-linha)):Borders(7):Weight     = 3.

ch-planilha:range("AG" + STRING(i-linha)):VALUE                 = "Qtde. Pedido".
ch-planilha:range("AG" + STRING(i-linha)):Borders(7):LineStyle  = 1.
ch-planilha:range("AG" + STRING(i-linha)):Borders(7):Weight     = 3.

ch-planilha:range("AH" + STRING(i-linha)):VALUE                 = "Valor Pedido".
ch-planilha:range("AH" + STRING(i-linha)):Borders(7):LineStyle  = 1.
ch-planilha:range("AH" + STRING(i-linha)):Borders(7):Weight     = 3.

ch-planilha:range("AI" + STRING(i-linha)):VALUE                 = "Mensagens de Erro".
ch-planilha:range("AI" + STRING(i-linha)):Borders(7):LineStyle  = 1.
ch-planilha:range("AI" + STRING(i-linha)):Borders(7):Weight     = 3.

ch-planilha:range("AJ" + STRING(i-linha)):Borders(7):LineStyle  = 1.
ch-planilha:range("AJ" + STRING(i-linha)):Borders(7):Weight     = 3.

ch-planilha:range("A" + STRING(i-linha) + ":" + "AI" + STRING(i-linha)):FONT:bold = TRUE.
ch-planilha:range("A" + STRING(i-linha) + ":" + "AI" + STRING(i-linha)):Interior:ColorIndex  = 15.
ch-planilha:range("A" + STRING(i-linha) + ":" + "AI" + STRING(i-linha)):Borders(8):LineStyle = 1.
ch-planilha:range("A" + STRING(i-linha) + ":" + "AI" + STRING(i-linha)):Borders(8):Weight    = 3.
ch-planilha:range("A" + STRING(i-linha) + ":" + "AI" + STRING(i-linha)):Borders(9):LineStyle = 1.
ch-planilha:range("A" + STRING(i-linha) + ":" + "AI" + STRING(i-linha)):Borders(9):Weight    = 3.

FOR EACH tt-excel USE-INDEX data-docto BREAK BY tt-excel.dt-emissao
                                             BY tt-excel.nro-docto
                                             BY tt-excel.serie
                                             BY tt-excel.cod-emitente
                                             BY tt-excel.numero-ordem QUERY-TUNING(NO-LOOKAHEAD):

    ASSIGN i-linha = i-linha + 1.
    
    run pi-acompanhar in h-acomp (input "Gerando Excel - Data: " + string(tt-excel.dt-emissao,"99/99/9999") + " - " + tt-excel.nro-docto).

    ch-planilha:range("A" + STRING(i-linha)):VALUE = tt-excel.dt-emissao. 
    ch-planilha:range("B" + STRING(i-linha)):VALUE = tt-excel.dt-transacao.
    ch-planilha:range("C" + STRING(i-linha)):VALUE = tt-excel.cod-estabel.                          
    ch-planilha:range("D" + STRING(i-linha)):VALUE = tt-excel.cod-emitente.         
    ch-planilha:range("E" + STRING(i-linha)):NumberFormat = "@".
    ch-planilha:range("E" + STRING(i-linha)):VALUE = tt-excel.cnpj.
    ch-planilha:range("F" + STRING(i-linha)):VALUE = tt-excel.natur-oper.                             
    ch-planilha:range("G" + STRING(i-linha)):VALUE = tt-excel.nro-docto. 
    ch-planilha:range("H" + STRING(i-linha)):VALUE = tt-excel.serie.
    ch-planilha:range("I" + STRING(i-linha)):VALUE = tt-excel.situacao.
    ch-planilha:range("J" + STRING(i-linha)):VALUE = tt-excel.nr-contrato. 
    ch-planilha:range("K" + STRING(i-linha)):VALUE = tt-excel.conta-trans.  
    ch-planilha:range("L" + STRING(i-linha)):NumberFormat = "###.###.##0,0000".  
    ch-planilha:range("L" + STRING(i-linha)):VALUE = tt-excel.vlr-desc.     
    ch-planilha:range("M" + STRING(i-linha)):NumberFormat = "###.###.##0,0000".  
    ch-planilha:range("M" + STRING(i-linha)):VALUE = tt-excel.vlr-merc.                 
    ch-planilha:range("N" + STRING(i-linha)):VALUE = tt-excel.sit-nfe.                        
    ch-planilha:range("O" + STRING(i-linha)):VALUE = tt-excel.usuario.                  
    ch-planilha:range("P" + STRING(i-linha)):VALUE = tt-excel.doc-import.    
    ch-planilha:range("Q" + STRING(i-linha)):NumberFormat = "###.###.##0,0000".  
    ch-planilha:range("Q" + STRING(i-linha)):VALUE = tt-excel.vlr-total.
    ch-planilha:range("R" + STRING(i-linha)):VALUE = tt-excel.sequencia.
    ch-planilha:range("S" + STRING(i-linha)):VALUE = tt-excel.it-codigo.
    ch-planilha:range("T" + STRING(i-linha)):VALUE = tt-excel.descricao.
    ch-planilha:range("U" + STRING(i-linha)):VALUE = tt-excel.un.   
    ch-planilha:range("V" + STRING(i-linha)):VALUE = tt-excel.numero-ordem.
    ch-planilha:range("W" + STRING(i-linha)):VALUE = tt-excel.nr-ord-produ.
    ch-planilha:range("X" + STRING(i-linha)):NumberFormat = "@".
    ch-planilha:range("X" + STRING(i-linha)):VALUE = tt-excel.conta-contabil.
    ch-planilha:range("Y" + STRING(i-linha)):NumberFormat = "###.###.##0,0000".  
    ch-planilha:range("Y" + STRING(i-linha)):VALUE = tt-excel.qtde-item-doc.
    ch-planilha:range("Z" + STRING(i-linha)):NumberFormat = "###.###.##0,0000".  
    ch-planilha:range("Z" + STRING(i-linha)):VALUE = tt-excel.vlr-item-doc.
    ch-planilha:range("AA" + STRING(i-linha)):NumberFormat = "###.###.##0,0000".  
    ch-planilha:range("AA" + STRING(i-linha)):VALUE = tt-excel.desconto.
    ch-planilha:range("AB" + STRING(i-linha)):NumberFormat = "###.###.##0,0000".  
    ch-planilha:range("AB" + STRING(i-linha)):VALUE = tt-excel.vlr-tot-item.
    
    IF FIRST-OF(tt-excel.numero-ordem) THEN DO:    
       ch-planilha:range("AC" + STRING(i-linha)):VALUE = tt-excel.data-pedido.
       ch-planilha:range("AD" + STRING(i-linha)):VALUE = tt-excel.num-pedido.
       ch-planilha:range("AE" + STRING(i-linha)):VALUE = tt-excel.cond-pagto.
       ch-planilha:range("AF" + STRING(i-linha)):NumberFormat = "@".
       ch-planilha:range("AF" + STRING(i-linha)):VALUE = tt-excel.vencimento.
       ch-planilha:range("AG" + STRING(i-linha)):NumberFormat = "###.###.##0,0000".  
       ch-planilha:range("AG" + STRING(i-linha)):VALUE = tt-excel.qtde-pedido.
       ch-planilha:range("AH" + STRING(i-linha)):NumberFormat = "###.###.##0,0000".  
       ch-planilha:range("AH" + STRING(i-linha)):VALUE = tt-excel.valor-pedido.
       ch-planilha:range("AI" + STRING(i-linha)):NumberFormat = "@".
       ch-planilha:range("AI" + STRING(i-linha)):VALUE = tt-excel.mensagem.
    END.
END.                                                                                                                
                                                                                                                          
ch-planilha:range("A2:A" + STRING(i-linha)):HorizontalAlignment   = 3.                                                     
ch-planilha:range("A2:A" + STRING(i-linha)):Borders(7):LineStyle  = 1.                                                       
ch-planilha:range("A2:A" + STRING(i-linha)):Borders(7):Weight     = 3.                                                    
                                                                                                                
ch-planilha:range("B2:B" + STRING(i-linha)):HorizontalAlignment   = 3.                                      
ch-planilha:range("B2:B" + STRING(i-linha)):Borders(7):LineStyle  = 1.                                          
ch-planilha:range("B2:B" + STRING(i-linha)):Borders(7):Weight     = 3.                                          
                                                                                                                
ch-planilha:range("C2:C" + STRING(i-linha)):HorizontalAlignment   = 3.                                          
ch-planilha:range("C2:C" + STRING(i-linha)):Borders(7):LineStyle  = 1.                                          
ch-planilha:range("C2:C" + STRING(i-linha)):Borders(7):Weight     = 3.                                          
                                                                                                                
ch-planilha:range("D2:D" + STRING(i-linha)):HorizontalAlignment   = 3.                                      
ch-planilha:range("D2:D" + STRING(i-linha)):Borders(7):LineStyle  = 1.
ch-planilha:range("D2:D" + STRING(i-linha)):Borders(7):Weight     = 3.

ch-planilha:range("E2:E" + STRING(i-linha)):HorizontalAlignment   = 3.
ch-planilha:range("E2:E" + STRING(i-linha)):Borders(7):LineStyle  = 1.
ch-planilha:range("E2:E" + STRING(i-linha)):Borders(7):Weight     = 3.

ch-planilha:range("F2:F" + STRING(i-linha)):HorizontalAlignment   = 3.
ch-planilha:range("F2:F" + STRING(i-linha)):Borders(7):LineStyle  = 1.
ch-planilha:range("F2:F" + STRING(i-linha)):Borders(7):Weight     = 3.

ch-planilha:range("G2:G" + STRING(i-linha)):HorizontalAlignment   = 3.
ch-planilha:range("G2:G" + STRING(i-linha)):Borders(7):LineStyle  = 1.
ch-planilha:range("G2:G" + STRING(i-linha)):Borders(7):Weight     = 3.

ch-planilha:range("H2:H" + STRING(i-linha)):HorizontalAlignment   = 3.
ch-planilha:range("H2:H" + STRING(i-linha)):Borders(7):LineStyle  = 1.
ch-planilha:range("H2:H" + STRING(i-linha)):Borders(7):Weight     = 3.

ch-planilha:range("I2:I" + STRING(i-linha)):HorizontalAlignment   = 3.
ch-planilha:range("I2:I" + STRING(i-linha)):Borders(7):LineStyle  = 1.
ch-planilha:range("I2:I" + STRING(i-linha)):Borders(7):Weight     = 3.

ch-planilha:range("J2:J" + STRING(i-linha)):HorizontalAlignment   = 3.
ch-planilha:range("J2:J" + STRING(i-linha)):Borders(7):LineStyle  = 1.
ch-planilha:range("J2:J" + STRING(i-linha)):Borders(7):Weight     = 3.

ch-planilha:range("K2:K" + STRING(i-linha)):HorizontalAlignment   = 3.
ch-planilha:range("K2:K" + STRING(i-linha)):Borders(7):LineStyle  = 1.
ch-planilha:range("K2:K" + STRING(i-linha)):Borders(7):Weight     = 3.

ch-planilha:range("L2:L" + STRING(i-linha)):HorizontalAlignment   = 3.
ch-planilha:range("L2:L" + STRING(i-linha)):Borders(7):LineStyle  = 1.
ch-planilha:range("L2:L" + STRING(i-linha)):Borders(7):Weight     = 3.

ch-planilha:range("M2:M" + STRING(i-linha)):HorizontalAlignment   = 3.
ch-planilha:range("M2:M" + STRING(i-linha)):Borders(7):LineStyle  = 1.
ch-planilha:range("M2:M" + STRING(i-linha)):Borders(7):Weight     = 3.

ch-planilha:range("N2:N" + STRING(i-linha)):HorizontalAlignment   = 3.
ch-planilha:range("N2:N" + STRING(i-linha)):Borders(7):LineStyle  = 1.
ch-planilha:range("N2:N" + STRING(i-linha)):Borders(7):Weight     = 3.

ch-planilha:range("O2:O" + STRING(i-linha)):HorizontalAlignment   = 3.
ch-planilha:range("O2:O" + STRING(i-linha)):Borders(7):LineStyle  = 1.
ch-planilha:range("O2:O" + STRING(i-linha)):Borders(7):Weight     = 3.

ch-planilha:range("P2:P" + STRING(i-linha)):HorizontalAlignment   = 3.
ch-planilha:range("P2:P" + STRING(i-linha)):Borders(7):LineStyle  = 1.
ch-planilha:range("P2:P" + STRING(i-linha)):Borders(7):Weight     = 3.

ch-planilha:range("Q2:Q" + STRING(i-linha)):HorizontalAlignment   = 3.
ch-planilha:range("Q2:Q" + STRING(i-linha)):Borders(7):LineStyle  = 1.
ch-planilha:range("Q2:Q" + STRING(i-linha)):Borders(7):Weight     = 3.

ch-planilha:range("R2:R" + STRING(i-linha)):HorizontalAlignment   = 3.
ch-planilha:range("R2:R" + STRING(i-linha)):Borders(7):LineStyle  = 1.
ch-planilha:range("R2:R" + STRING(i-linha)):Borders(7):Weight     = 3.

ch-planilha:range("S2:S" + STRING(i-linha)):HorizontalAlignment   = 3.
ch-planilha:range("S2:S" + STRING(i-linha)):Borders(7):LineStyle  = 1.
ch-planilha:range("S2:S" + STRING(i-linha)):Borders(7):Weight     = 3.

ch-planilha:range("T2:T" + STRING(i-linha)):HorizontalAlignment   = 3.
ch-planilha:range("T2:T" + STRING(i-linha)):Borders(7):LineStyle  = 1.
ch-planilha:range("T2:T" + STRING(i-linha)):Borders(7):Weight     = 3.

ch-planilha:range("U2:U" + STRING(i-linha)):HorizontalAlignment   = 3.
ch-planilha:range("U2:U" + STRING(i-linha)):Borders(7):LineStyle  = 1.
ch-planilha:range("U2:U" + STRING(i-linha)):Borders(7):Weight     = 3.

ch-planilha:range("V2:V" + STRING(i-linha)):HorizontalAlignment   = 3.
ch-planilha:range("V2:V" + STRING(i-linha)):Borders(7):LineStyle  = 1.
ch-planilha:range("V2:V" + STRING(i-linha)):Borders(7):Weight     = 3.

ch-planilha:range("W2:W" + STRING(i-linha)):HorizontalAlignment   = 3.
ch-planilha:range("W2:W" + STRING(i-linha)):Borders(7):LineStyle  = 1.
ch-planilha:range("W2:W" + STRING(i-linha)):Borders(7):Weight     = 3.

ch-planilha:range("X2:X" + STRING(i-linha)):HorizontalAlignment   = 3.
ch-planilha:range("X2:X" + STRING(i-linha)):Borders(7):LineStyle  = 1.
ch-planilha:range("X2:X" + STRING(i-linha)):Borders(7):Weight     = 3.

ch-planilha:range("Y2:Y" + STRING(i-linha)):HorizontalAlignment   = 3.
ch-planilha:range("Y2:Y" + STRING(i-linha)):Borders(7):LineStyle  = 1.
ch-planilha:range("Y2:Y" + STRING(i-linha)):Borders(7):Weight     = 3.

ch-planilha:range("Z2:Z" + STRING(i-linha)):HorizontalAlignment   = 3.
ch-planilha:range("Z2:Z" + STRING(i-linha)):Borders(7):LineStyle  = 1.
ch-planilha:range("Z2:Z" + STRING(i-linha)):Borders(7):Weight     = 3.

ch-planilha:range("AA2:AA" + STRING(i-linha)):HorizontalAlignment   = 3.
ch-planilha:range("AA2:AA" + STRING(i-linha)):Borders(7):LineStyle  = 1.
ch-planilha:range("AA2:AA" + STRING(i-linha)):Borders(7):Weight     = 3.

ch-planilha:range("AB2:AB" + STRING(i-linha)):HorizontalAlignment   = 3.
ch-planilha:range("AB2:AB" + STRING(i-linha)):Borders(7):LineStyle  = 1.
ch-planilha:range("AB2:AB" + STRING(i-linha)):Borders(7):Weight     = 3.

ch-planilha:range("AC2:AC" + STRING(i-linha)):HorizontalAlignment   = 3.
ch-planilha:range("AC2:AC" + STRING(i-linha)):Borders(7):LineStyle  = 1.
ch-planilha:range("AC2:AC" + STRING(i-linha)):Borders(7):Weight     = 3.

ch-planilha:range("AD2:AD" + STRING(i-linha)):HorizontalAlignment   = 3.
ch-planilha:range("AD2:AD" + STRING(i-linha)):Borders(7):LineStyle  = 1.
ch-planilha:range("AD2:AD" + STRING(i-linha)):Borders(7):Weight     = 3.

ch-planilha:range("AE2:AE" + STRING(i-linha)):HorizontalAlignment   = 3.
ch-planilha:range("AE2:AE" + STRING(i-linha)):Borders(7):LineStyle  = 1.
ch-planilha:range("AE2:AE" + STRING(i-linha)):Borders(7):Weight     = 3.

ch-planilha:range("AF2:AF" + STRING(i-linha)):HorizontalAlignment   = 3.
ch-planilha:range("AF2:AF" + STRING(i-linha)):Borders(7):LineStyle  = 1.
ch-planilha:range("AF2:AF" + STRING(i-linha)):Borders(7):Weight     = 3.

ch-planilha:range("AG2:AG" + STRING(i-linha)):HorizontalAlignment   = 3.
ch-planilha:range("AG2:AG" + STRING(i-linha)):Borders(7):LineStyle  = 1.
ch-planilha:range("AG2:AG" + STRING(i-linha)):Borders(7):Weight     = 3.

ch-planilha:range("AH2:AH" + STRING(i-linha)):HorizontalAlignment   = 3.
ch-planilha:range("AH2:AH" + STRING(i-linha)):Borders(7):LineStyle  = 1.
ch-planilha:range("AH2:AH" + STRING(i-linha)):Borders(7):Weight     = 3.

ch-planilha:range("AI2:AI" + STRING(i-linha)):HorizontalAlignment   = 3.
ch-planilha:range("AI2:AI" + STRING(i-linha)):Borders(7):LineStyle  = 1.
ch-planilha:range("AI2:AI" + STRING(i-linha)):Borders(7):Weight     = 3.

ch-planilha:range("AJ2:AJ" + STRING(i-linha)):HorizontalAlignment   = 3.
ch-planilha:range("AJ2:AJ" + STRING(i-linha)):Borders(7):LineStyle  = 1.
ch-planilha:range("AJ2:AJ" + STRING(i-linha)):Borders(7):Weight     = 3.

ch-planilha:range("A" + STRING(i-linha) + ":" + "AI" + STRING(i-linha)):Borders(9):LineStyle = 1.
ch-planilha:range("A" + STRING(i-linha) + ":" + "AI" + STRING(i-linha)):Borders(9):Weight    = 3.

ch-planilha:SELECT().
chExcelApplication:COLUMNS("A:AZ"):AutoFit.

chExcelApplication:VISIBLE = YES. 

IF VALID-HANDLE(chExcelApplication) THEN
   RELEASE OBJECT chExcelApplication.
IF VALID-HANDLE(chWorkbook) THEN
   RELEASE OBJECT chWorkbook.
IF VALID-HANDLE(ch-planilha) THEN
   RELEASE OBJECT ch-planilha.

run pi-finalizar in h-acomp.   

return "OK".

/*  Situaá‰es NFE  

1  - NF-e n∆o Gerada
2  - Em Processamento no EAI
3  - Uso Autorizado
4  - Uso Denegado
5  - Documento Rejeitado
6  - Documento Cancelado
7  - Documento Inutilizado
8  - Em Processamento Aplic. Transmiss∆o
9  - Em Processamento na SEFAZ
10 - Em processamento no SCAN
11 - NF-e Gerada
12 - NF-e em Processo de Cancelamento
13 - NF-e em Processo de Inutilizaá∆o
14 - NF-e Pendente de Retorno
15 - DPEC Recebido pelo SCE     */
