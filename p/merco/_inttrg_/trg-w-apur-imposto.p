/****************************************************************************************************
**   Programa: trg-w-apur-imposto.p - Trigger de write para a tabela apur-imposto
**             Criar tabela de altera‡Æo para leitura do BI
**   Data....: Junho/2024
**   KML Consultoria - Guilherme Nichele
*****************************************************************************************************/

DEF PARAM BUFFER b-apur-imposto		FOR ems2dis.apur-imposto.
DEF PARAM BUFFER b-old-apur-imposto	FOR ems2dis.apur-imposto. 

.MESSAGE "entrou trigger v2"
    VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
  
 
 FIND FIRST b-apur-imposto NO-ERROR.
 
 IF AVAIL b-apur-imposto THEN
 DO:
 
  /*  CREATE esp-alteracao-bi.
    ASSIGN esp-alteracao-bi.tabela = "apur-imposto"
           esp-alteracao-bi.dt-alteracao = TODAY
           esp-alteracao-bi.cod-estabel = b-apur-imposto.cod-estabel
	   esp-alteracao-bi.tp-imposto = b-apur-imposto.tp-imposto
	   esp-alteracao-bi.dt-apur-ini = b-apur-imposto.dt-apur-ini
	   esp-alteracao-bi.dt-apur-fim = b-apur-imposto.dt-apur-fim.
	    */  
         
 END.
