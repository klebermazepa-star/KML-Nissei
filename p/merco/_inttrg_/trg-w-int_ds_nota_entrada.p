/****************************************************************************************************
**   Programa: trg-w-int_ds_nota_entrada.p - Trigger de write para a tabela int_ds_nota_entrada
**             Criar tabela de altera‡Æo para leitura do BI
**   Data....: Junho/2024
**   KML Consultoria - Guilherme Nichele
*****************************************************************************************************/

DEF PARAM BUFFER b-int_ds_nota_entrada		FOR custom.int_ds_nota_entrada.
DEF PARAM BUFFER b-old-int_ds_nota_entrada	for custom.int_ds_nota_entrada. 

.MESSAGE "entrou trigger v2"
    VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
  
 
 FIND FIRST b-int_ds_nota_entrada NO-ERROR.
 
 IF AVAIL b-int_ds_nota_entrada THEN
 DO:
    /*
    CREATE esp-alteracao-bi.
    ASSIGN esp-alteracao-bi.tabela = "int_ds_nota_entrada"
           esp-alteracao-bi.dt-alteracao = TODAY
           esp-alteracao-bi.nen_cnpj_origem_s = b-int_ds_nota_entrada.nen_cnpj_origem_s
	       esp-alteracao-bi.nen_serie_s = b-int_ds_nota_entrada.nen_serie_s
           esp-alteracao-bi.nen_notafiscal_n = b-int_ds_nota_entrada.nen_notafiscal_n.
	   
	  */ 
	   
         
 END.
