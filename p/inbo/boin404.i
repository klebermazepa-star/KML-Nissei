/*
**  BOIN403.i
**
**  saldo-terc - Saldos em Terceiros
**
**  Ultima altera‡Æo : 21/06/99 - GeraBO
*/
 
DEFINE TEMP-TABLE {1} like saldo-terc
    field r-rowid  as rowid
    &if defined (bf_dis_versao_ems)  &then
     &if {&bf_dis_versao_ems} >= 2.03 &then
       field RowNum as integer
     &endif
    &endif
   .
