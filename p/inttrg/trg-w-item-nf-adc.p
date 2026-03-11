/****************************************************************************************************
**   Programa: trg-w-item-nf-adc.p - Trigger de write para a tabela item-uf
**             Criar tabela de altera‡Æo para leitura do BI
**   Data....: Junho/2024
**   KML Consultoria - Guilherme Nichele
*****************************************************************************************************/

DEF PARAM BUFFER b-item-nf-adc		FOR ems2dis.item-nf-adc.
DEF PARAM BUFFER b-old-item-nf-adc		FOR ems2dis.item-nf-adc. 

  
 
 FIND FIRST b-item-nf-adc NO-ERROR.
 
 IF AVAIL b-item-nf-adc THEN
 DO:
    
    CREATE esp-alteracao-bi.
    ASSIGN esp-alteracao-bi.tabela = "item-nf-adc"
           esp-alteracao-bi.dt-alteracao = TODAY
           esp-alteracao-bi.cod-serie = b-item-nf-adc.cod-serie
           esp-alteracao-bi.cod-nota-fisc = b-item-nf-adc.cod-nota-fisc
           esp-alteracao-bi.cdn-emitente = b-item-nf-adc.cdn-emitente
           esp-alteracao-bi.cod-natur-operac = b-item-nf-adc.cod-natur-operac
           esp-alteracao-bi.idi-tip-dado = b-item-nf-adc.idi-tip-dado
           esp-alteracao-bi.num-seq = b-item-nf-adc.num-seq
           esp-alteracao-bi.num-seq-item-nf = b-item-nf-adc.num-seq-item-nf
           esp-alteracao-bi.cod-item = b-item-nf-adc.cod-item.
	   	   
         
 END.
