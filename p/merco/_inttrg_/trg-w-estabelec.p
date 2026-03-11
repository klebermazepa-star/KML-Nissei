/****************************************************************************************************
**   Programa: trg-w-estabelec.p - Trigger de write para a tabela estabelec
**             Criar tabela de altera‡Æo para leitura do BI
**   Data....: Junho/2024
**   KML Consultoria - Guilherme Nichele
*****************************************************************************************************/

DEF PARAM BUFFER b-estabelec		FOR ems2mult.estabelec.
DEF PARAM BUFFER b-old-estabelec	FOR ems2mult.estabelec. 
  
 
 FIND FIRST b-estabelec NO-ERROR.
 
 IF AVAIL b-estabelec THEN
 DO:
    /*
    CREATE esp-alteracao-bi.
    ASSIGN esp-alteracao-bi.tabela = "estabelec"
           esp-alteracao-bi.dt-alteracao = TODAY
           esp-alteracao-bi.cod-estabel = b-estabelec.cod-estabel.
           
	*/   	   
         
 END.
