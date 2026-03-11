/****************************************************************************************************
**   Programa: trg-w-imp-valor.p - Trigger de write para a tabela imp-valor
**             Criar tabela de altera‡Æo para leitura do BI
**   Data....: Junho/2024
**   KML Consultoria - Guilherme Nichele
*****************************************************************************************************/

DEF PARAM BUFFER b-imp-valor		FOR ems2dis.imp-valor.
DEF PARAM BUFFER b-old-imp-valor	FOR ems2dis.imp-valor. 

.MESSAGE "entrou trigger v2"
    VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
  
 
 FIND FIRST b-imp-valor NO-ERROR.
 
 IF AVAIL b-imp-valor THEN
 DO:
 
   /*
    CREATE esp-alteracao-bi.
    ASSIGN esp-alteracao-bi.tabela = "imp-valor"
           esp-alteracao-bi.dt-alteracao = TODAY
           esp-alteracao-bi.cod-estabel = b-imp-valor.cod-estabel
	       esp-alteracao-bi.tp-imposto = b-imp-valor.tp-imposto
	       esp-alteracao-bi.dt-apur-ini = b-imp-valor.dt-apur-ini
	       esp-alteracao-bi.dt-apur-fim = b-imp-valor.dt-apur-fim
	       esp-alteracao-bi.cod-lanc = b-imp-valor.cod-lanc 
	       esp-alteracao-bi.nr-sequencia = b-imp-valor.nr-sequencia.
	    */  
         
 END.
