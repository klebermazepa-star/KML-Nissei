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
def new global shared var h-bt-calcula-4002 as widget-handle no-undo. 
def new global shared var row-order as rowid no-undo.
for first ped-venda fields (tp-pedido)
    no-lock where rowid(ped-venda) = row-order:
    if valid-handle(h-bt-calcula-4002) and ped-venda.tp-pedido <> "1"
    then do:
        apply "CHOOSE" to h-bt-calcula-4002. 
    end.
    else do:
        message "Pedido tipo 1 deve ser faturado em ft4001!" view-as alert-box.
    end.
end.
return "OK".



