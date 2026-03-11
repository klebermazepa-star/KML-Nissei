/****************************************************************************************************
**   Programa: enviar para datahub quando aprovado credito
**   Data....: Maio/2025
**   KML Consultoria - Kleber Mazepa
*****************************************************************************************************/

DEF PARAM BUFFER b-ped-venda		FOR ems2dis.ped-venda.
DEF PARAM BUFFER b-old-ped-venda	FOR ems2dis.ped-venda. 
  

 FIND FIRST b-ped-venda NO-ERROR.
 
 IF AVAIL b-ped-venda THEN
 DO:
 
    IF b-ped-venda.cod-sit-aval = 3 /* Aprovado cr‚dito */ 
         AND b-old-ped-venda.cod-sit-aval <> 3 THEN
    DO:

        RUN custom/eswms003rp.p ( INPUT  rowid(b-ped-venda), "Pedido Aprovado Cr‚dito").
        
    END.
    
    
    // KML - Enviar quando o pedido for cancelado
    
    IF b-ped-venda.dt-cancela <> ?  /* Aprovado cr‚dito */ 
         AND b-old-ped-venda.dt-cancela = ? THEN
    DO:
        RUN custom/eswms003rp.p ( INPUT  rowid(b-ped-venda), "Pedido Cancelado").
        
    END.    
    
         
 END.
