/****************************************************************************************************
**   Programa: trg-w-natur-oper.p - Trigger de write para a tabela natur-oper
**             Criar tabela de altera‡Æo para leitura do BI
**   Data....: Junho/2024
**   KML Consultoria - Guilherme Nichele
*****************************************************************************************************/

DEF PARAM BUFFER b-natur-oper		FOR ems2log.natur-oper.
DEF PARAM BUFFER b-old-natur-oper	FOR ems2log.natur-oper. 
  
 
 FIND FIRST b-natur-oper NO-ERROR.
 
 IF AVAIL b-natur-oper THEN
 DO:
    /*
    CREATE esp-alteracao-bi.
    ASSIGN esp-alteracao-bi.tabela = "natur-oper"
           esp-alteracao-bi.dt-alteracao = TODAY
           esp-alteracao-bi.nat-operacao = b-natur-oper.nat-operacao.
     */      
	   	   
         
 END.
