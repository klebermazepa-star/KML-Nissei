/******************************************************************************
**
**     Programa: UPC-FT4002A
**
**     Objetivo: Chamada UPC no programa FT4002 para verificar pedido tipo 1
**
**     Autor...: Alessandro V. Baccin - AVB Planejamento e Consultoria
**
**     Vers∆o..: 1.00.00.001 - 25/01/2016
**
******************************************************************************/
def new global shared var row-order as rowid no-undo.

message "Pedido tipo 1/8 deve ser faturado total!" view-as alert-box.

return "OK".



