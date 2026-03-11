/****************************************************************************************************
**   Programa: trg-w-item-uf.p - Trigger de write para a tabela item-uf
**             Criar tabela de altera‡Æo para leitura do BI
**   Data....: Junho/2024
**   KML Consultoria - Guilherme Nichele
*****************************************************************************************************/

DEF PARAM BUFFER b-item-uf      FOR ems2dis.item-uf.
DEF PARAM BUFFER b-old-item-uf  FOR ems2dis.item-uf. 

.MESSAGE "entrou trigger v2"
    VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
  
 
 FIND FIRST b-item-uf NO-ERROR.
 
 IF AVAIL b-item-uf THEN
 DO:
     /*
    CREATE esp-alteracao-bi.
    ASSIGN esp-alteracao-bi.tabela = "item-uf"
           esp-alteracao-bi.dt-alteracao = TODAY
           esp-alteracao-bi.it-codigo = b-item-uf.it-codigo
           esp-alteracao-bi.cod-estado-orig = b-item-uf.cod-estado-orig
           esp-alteracao-bi.estado = b-item-uf.estado
           esp-alteracao-bi.cod-estab = b-item-uf.cod-estab.
	   
	  */ 
	   
	   
         
 END.
