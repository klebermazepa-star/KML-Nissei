/****************************************************************************************************
**   Programa: trg-w-it-nota-fisc.p - Trigger de write para a tabela it-nota-fisc
**             Criar tabela de altera‡Æo para leitura do BI
**   Data....: Junho/2024
**   KML Consultoria - Guilherme Nichele
*****************************************************************************************************/

DEF PARAM BUFFER b-it-nota-fisc		FOR ems2dis.it-nota-fisc.
DEF PARAM BUFFER b-old-it-nota-fisc	FOR ems2dis.it-nota-fisc. 

  
 
 FIND FIRST b-it-nota-fisc NO-ERROR.
 
 IF AVAIL b-it-nota-fisc THEN
 DO:
    
    CREATE esp-alteracao-bi.
    ASSIGN esp-alteracao-bi.tabela = "it-nota-fisc"
           esp-alteracao-bi.dt-alteracao = TODAY
           esp-alteracao-bi.cod-estabel = b-it-nota-fisc.cod-estabel
	       esp-alteracao-bi.serie = b-it-nota-fisc.serie
	       esp-alteracao-bi.nr-nota-fis = b-it-nota-fisc.nr-nota-fis
	       esp-alteracao-bi.nr-seq-fat = b-it-nota-fisc.nr-seq-fat
           esp-alteracao-bi.it-codigo = b-it-nota-fisc.it-codigo.
	   
	   
         
 END.
