/******************************************************************************
**
**     Programa: UPC-PD4000A
**
**     Objetivo: Chamada UPC no programa PD4000A para validaá∆o de Pedidos
**
**     Autor...: Alessandro V. Baccin - AVB Planejamento e Consultoria
**
**     Vers∆o..: 1.00.00.001 - 25/01/2016
**
******************************************************************************/
def new global shared var h-btUpdateOrder as widget-handle no-undo. 
def new global shared var row-order as rowid no-undo.

for first ped-venda fields (tp-pedido)
    no-lock where rowid(ped-venda) = row-order:

    if valid-handle(h-btUpdateOrder) and ped-venda.tp-pedido <> "1"
    then do:
        apply "CHOOSE" to h-btUpdateOrder. 
    end.
    else do:
        message "Pedido tipo 1 n∆o pode ser alterado!" view-as alert-box.
    end.
end.

return "OK".



