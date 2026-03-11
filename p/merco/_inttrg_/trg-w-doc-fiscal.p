/****************************************************************************************************
**   Programa: trg-w-doc-fiscal.p - Trigger de write para a tabela doc-fiscal
**             Criar tabela de altera‡Æo para leitura do BI
**   Data....: Junho/2024
**   KML Consultoria - Guilherme Nichele
*****************************************************************************************************/

DEF PARAM BUFFER b-doc-fiscal		FOR ems2dis.doc-fiscal.
DEF PARAM BUFFER b-old-doc-fiscal	FOR ems2dis.doc-fiscal. 

.MESSAGE "entrou trigger v2"
    VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
  
 
 FIND FIRST b-doc-fiscal NO-ERROR.
 
 IF AVAIL b-doc-fiscal THEN
 DO:
 
   /* CREATE esp-alteracao-bi.
    ASSIGN esp-alteracao-bi.tabela = "doc-fiscal"
           esp-alteracao-bi.dt-alteracao = TODAY
           esp-alteracao-bi.cod-estabel = b-doc-fiscal.cod-estabel
	        esp-alteracao-bi.serie = b-doc-fiscal.serie
           esp-alteracao-bi.nr-doc-fis = b-doc-fiscal.nr-doc-fis
           esp-alteracao-bi.cod-emitente = b-doc-fiscal.cod-emitente
           esp-alteracao-bi.nat-operacao = b-doc-fiscal.nat-operacao.
	   
	   */
	   
         
 END.
