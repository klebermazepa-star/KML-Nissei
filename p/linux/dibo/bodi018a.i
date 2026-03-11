/*
**  BODI018a.i
**
**  cond-ped - Condicoes de Pagamento do Pedido de Venda
**
**  Ultima altera‡Æo : 31/03/99 - GeraBO
*/
 
DEFINE TEMP-TABLE {1} 
       field seq as  int format "9"
       field cod-vencto   like cond-ped.cod-vencto
       field data-pagto   like cond-ped.data-pagto
       field nr-dias-venc like cond-ped.nr-dias-venc
       field vl-pagto     like cond-ped.vl-pagto    
       Field perc-pagto   like cond-ped.perc-pagto 
       field r-rowid  as rowid.
 
