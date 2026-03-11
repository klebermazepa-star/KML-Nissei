/******************************************************************************
**
**     Programa: UPC-FT4003A
**
**     Objetivo: Chamada UPC no programa FT4003 para verificar pedido tipo 1
**
**     Autor...: Alessandro V. Baccin - AVB Planejamento e Consultoria
**
**     Vers∆o..: 1.00.00.001 - 25/01/2016
**
******************************************************************************/
def new global shared var h-btOK-4003 as widget-handle no-undo. 
def new global shared var h-nr-pedcli-4003  as widget-handle no-undo. 
def new global shared var h-nome-abrev-4003 as widget-handle no-undo. 

if valid-handle(h-btOK-4003) and
   valid-handle(h-nr-pedcli-4003) and
   valid-handle(h-nome-abrev-4003) then do:

    if h-nome-abrev-4003:screen-value <> "" and
       h-nr-pedcli-4003:screen-value <> ""  then do:
        for first ped-venda fields (tp-pedido) no-lock where 
            ped-venda.nome-abrev = h-nome-abrev-4003:screen-value and
            ped-venda.nr-pedcli  = h-nr-pedcli-4003:screen-value:
        
            if ped-venda.tp-pedido = "1" 
            then do:
                message "Pedido tipo 1 deve ser faturado em ft4001!" view-as alert-box.
                return "NOK".
            end.
            else apply "CHOOSE" to h-btOk-4003. 
        end.
        if not avail ped-venda then 
        for first ped-venda fields (tp-pedido) no-lock where 
            ped-venda.cod-emitente = int(h-nome-abrev-4003:screen-value) and
            ped-venda.nr-pedcli  = h-nr-pedcli-4003:screen-value:
        
            if ped-venda.tp-pedido = "1" 
            then do:
                message "Pedido tipo 1 deve ser faturado em ft4001!" view-as alert-box.
                return "NOK".
            end.
            else apply "CHOOSE" to h-btOk-4003. 
        end.
        
    end.        
    else apply "CHOOSE" to h-btOk-4003. 
end.
return "OK".



