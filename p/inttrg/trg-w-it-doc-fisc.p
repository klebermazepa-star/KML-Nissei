/****************************************************************************************************
**   Programa: trg-w-it-doc-fisc.p - Trigger de write para a tabela it-doc-fisc
**             Criar tabela de altera»’o para leitura do BI
**   Data....: Junho/2024
**   KML Consultoria - Guilherme Nichele
*****************************************************************************************************/

DEF PARAM BUFFER b-it-doc-fisc		FOR ems2dis.it-doc-fisc.
DEF PARAM BUFFER b-old-it-doc-fisc	FOR ems2dis.it-doc-fisc. 

  
 
 FIND FIRST b-it-doc-fisc NO-ERROR.
 
 IF AVAIL b-it-doc-fisc THEN
 DO:
    
    CREATE esp-alteracao-bi.
    ASSIGN esp-alteracao-bi.tabela = "it-doc-fisc"
           esp-alteracao-bi.dt-alteracao = TODAY
           esp-alteracao-bi.cod-estabel = b-it-doc-fisc.cod-estabel
	       esp-alteracao-bi.serie = b-it-doc-fisc.serie
	       esp-alteracao-bi.nr-doc-fis = string(b-it-doc-fisc.nr-doc-fis)
		   esp-alteracao-bi.cod-emitente = b-it-doc-fisc.cod-emitente
	       esp-alteracao-bi.nat-operacao = b-it-doc-fisc.nat-operacao
           esp-alteracao-bi.nr-seq-doc = b-it-doc-fisc.nr-seq-doc.
          
	   
         
 END.
