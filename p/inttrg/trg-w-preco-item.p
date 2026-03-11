/****************************************************************************************************
**   Programa: trg-w-PRECO-ITEM.p - Trigger de write para a tabela PRECO-ITEM
**             Criar tabela de altera‡Æo para leitura do BI
**   Data....: Junho/2024
**   KML Consultoria - Guilherme Nichele
*****************************************************************************************************/

DEF PARAM BUFFER b-PRECO-ITEM		FOR ems2dis.PRECO-ITEM.
DEF PARAM BUFFER b-old-PRECO-ITEM	FOR ems2dis.PRECO-ITEM. 
def new global shared var v_cdn_empres_usuar  LIKE ems2mult.empresa.ep-codigo no-undo.  
  
 
FIND FIRST b-PRECO-ITEM NO-ERROR.

IF AVAIL b-PRECO-ITEM THEN
DO:
    
    CREATE esp-alteracao-bi.
    ASSIGN esp-alteracao-bi.tabela = "PRECO-ITEM"
           esp-alteracao-bi.dt-alteracao = TODAY
           esp-alteracao-bi.nr-tabpre = b-PRECO-ITEM.nr-tabpre
           esp-alteracao-bi.it-codigo = b-PRECO-ITEM.it-codigo
           esp-alteracao-bi.cod-refer = b-PRECO-ITEM.cod-refer
           esp-alteracao-bi.cod-unid-med = b-PRECO-ITEM.cod-unid-med
           esp-alteracao-bi.dt-inival = b-PRECO-ITEM.dt-inival
           esp-alteracao-bi.quant-min = b-PRECO-ITEM.quant-min.
           
           
    IF v_cdn_empres_usuar = "10" THEN DO:
        
        RUN intprg/int307TabPreco.p (INPUT ROWID (esp-alteracao-bi)).
        
    END.
    
    
              
END.
