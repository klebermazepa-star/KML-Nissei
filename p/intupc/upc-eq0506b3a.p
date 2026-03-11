/******************************************************************************
**
**     Programa: UPC-FT0506b3a
**
**     Objetivo: Chamada UPC no programa FT0506b3a para verificar pedido tipo 1
**
**     Autor...: Alessandro V. Baccin - AVB Planejamento e Consultoria
**
**     Vers∆o..: 1.00.00.001 - 25/01/2016
**
******************************************************************************/
def new global shared var h-btOK-0506b3-new   AS WIDGET-HANDLE no-undo.
def new global shared var h-btOK-0506b3       AS widget-handle no-undo.
def new global shared var h-nr-pedcli-0506b3  as widget-handle no-undo. 
def new global shared var h-nome-abrev-0506b3 as widget-handle no-undo. 



if valid-handle(h-btOK-0506b3) and
   valid-handle(h-nr-pedcli-0506b3) and
   valid-handle(h-nome-abrev-0506b3) then do:

    if h-nome-abrev-0506b3:screen-value <> "" and
       h-nr-pedcli-0506b3:screen-value <> ""  then do:
        for first ped-venda fields (tp-pedido nome-abrev nr-pedcli nr-pedido) no-lock where 
            ped-venda.nome-abrev = h-nome-abrev-0506b3:screen-value and
            ped-venda.nr-pedcli  = h-nr-pedcli-0506b3:screen-value:
        
            if ped-venda.tp-pedido = "1" 
            then do:
                for first cst_ped_venda 
                    no-lock where 
                    cst_ped_venda.nr_pedido = ped-venda.nr-pedido:
                    if  not cst_ped_venda.log_integrado_wms or
                        not cst_ped_venda.log_liberado_wms 
                    then do:
                        message "Pedido de venda n∆o liberado pelo WMS." view-as alert-box.
                        return "NOK".
                    end.                        
                    else apply "CHOOSE" to h-btOk-0506b3. 
                end.                
            end.                
        end.
        if not avail ped-venda then 
        for first ped-venda fields (tp-pedido nome-abrev nr-pedcli nr-pedido) no-lock where 
            ped-venda.cod-emitente = int(h-nome-abrev-0506b3:screen-value) and
            ped-venda.nr-pedcli  = h-nr-pedcli-0506b3:screen-value:
        
            if ped-venda.tp-pedido = "1" 
            then do:
                for first cst_ped_venda 
                    no-lock where 
                    cst_ped_venda.nr_pedido = ped-venda.nr-pedido:
                    if  not cst_ped_venda.log_integrado_wms or
                        not cst_ped_venda.log_liberado_wms 
                    then do:
                        message "Pedido de venda n∆o liberado pelo WMS." view-as alert-box.
                        return "NOK".
                    end.                        
                    else apply "CHOOSE" to h-btOk-0506b3. 
                end.                
            end.
            else apply "CHOOSE" to h-btOk-0506b3. 
        end.
    end.        
    else apply "CHOOSE" to h-btOk-0506b3. 
end.
return "OK".



