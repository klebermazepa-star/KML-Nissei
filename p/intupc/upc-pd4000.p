/******************************************************************************
**
**     Programa: UPC-PD4000
**
**     Objetivo: Chamada UPC no programa PD4000 para valida‡Æo de Pedidos
**
**     Autor...: Alessandro V. Baccin - AVB Planejamento e Consultoria
**
**     VersÆo..: 1.00.00.001 - 25/01/2016
**
******************************************************************************/
/* defini‡Æo de parƒmetros */
/*{utp/ut-glob.i}*/
def input parameter p-ind-event     as character     no-undo.
def input parameter p-ind-object    as character     no-undo.
def input parameter p-wgh-object    as handle        no-undo.
def input parameter p-wgh-frame     as widget-handle no-undo.
def input parameter p-cod-table     as character     no-undo.
def input parameter p-row-table     as rowid         no-undo.

/* Variable Definitions *****************************************************/
def var c-objeto                    as char          no-undo.
def var h-campo                     as widget-handle no-undo. 
def var h-campo2                    as widget-handle no-undo. 
def var h-estab-central             as widget-handle no-undo. 
def var h-btUpdateOrderNew          as widget-handle no-undo. 
def var h-btDeleteOrderNew          as widget-handle no-undo. 
def var h-btUpdateItemNew           as widget-handle no-undo. 
def var h-btDeleteItemNew           as widget-handle no-undo. 
def var h-log-integrado-wms         as widget-handle no-undo. 
def var h-log-liberado-wms          as widget-handle no-undo. 

def new global shared var row-order as rowid no-undo.
def new global shared var row-cst-order as rowid no-undo.
def new global shared var h-btUpdateOrder as widget-handle no-undo. 
def new global shared var h-btDeleteOrder as widget-handle no-undo. 
def new global shared var h-btUpdateItem as widget-handle no-undo. 
def new global shared var h-btDeleteItem as widget-handle no-undo. 


assign c-objeto = entry(num-entries(p-wgh-object:private-data, "~/"),
                                    p-wgh-object:private-data, "~/").
    /*
message "Evento........: " p-ind-event         skip
        "Objeto........: " p-ind-object        skip
        "Handle Objeto.: " string(p-wgh-object)  skip
        "Nome Objeto...: " c-objeto skip
        "Frame.........: " p-wgh-frame         skip
        "Tabela........: " p-cod-table         skip
        "Rowid.........: " string(p-row-table) skip
        view-as alert-box info buttons ok.
*/

/* Main Block ***************************************************************/
if p-cod-table = 'ped-venda' and
   p-row-table <> ? then assign row-order = p-row-table.

/* Tratamento de Armazenamento de Campos **************************************/
if (p-ind-event  = "AFTER-INITIALIZE" and 
    p-ind-object = "CONTAINER")
then do:

    run utils/findWidget.p(input 'estab-central',
                           input 'fill-in',
                           input p-wgh-frame,
                           output h-estab-central).
    
    run utils/findWidget.p(input 'btUpdateOrder',
                           input 'Button',
                           input p-wgh-frame,
                           output h-btUpdateOrder).
                           
    run utils/findWidget.p(input 'btDeleteOrder',
                           input 'Button',
                           input p-wgh-frame,
                           output h-btDeleteOrder).

    run utils/findWidget.p(input 'btUpdateItem',
                           input 'Button',
                           input p-wgh-frame,
                           output h-btUpdateItem).
                           
    run utils/findWidget.p(input 'btDeleteItem',
                           input 'Button',
                           input p-wgh-frame,
                           output h-btDeleteItem).


    
    if valid-handle (h-estab-central) then do:
        if not valid-handle (h-log-integrado-wms) then do:
            create toggle-box h-log-integrado-wms
                   assign name      = 'IntegradoWMS'
                          label     = 'Integrado WMS'
                          frame     = h-estab-central:frame
                          width     = 15
                          height    = h-estab-central:height
                          row       = h-estab-central:row + 1
                          col       = h-estab-central:col
                          visible   = yes
                          sensitive = no.
        end.
        if not valid-handle (h-log-liberado-wms) then do:
            create toggle-box h-log-liberado-wms
                   assign name      = 'LiberadoWMS'
                          label     = 'Liberado WMS'
                          frame     = h-estab-central:frame
                          width     = 15
                          height    = h-estab-central:height
                          row       = h-estab-central:row + 1
                          col       = h-estab-central:col + 15
                          visible   = yes
                          sensitive = no.
        end.
        if  valid-handle (h-log-integrado-wms) and
            valid-handle (h-log-liberado-wms) then do:
            for first ped-venda fields (nr-pedido tp-pedido)
                no-lock where rowid(ped-venda) = p-row-table:
                if ped-venda.tp-pedido = "1" then
                for first cst_ped_venda 
                    no-lock where 
                    cst_ped_venda.nr_pedido = ped-venda.nr-pedido:

                    assign h-log-integrado-wms:screen-value = string(cst_ped_venda.log_integrado_wms)
                           h-log-liberado-wms:screen-value = string(cst_ped_venda.log_liberado_wms)
                           row-cst-order = rowid(cst_ped_venda).
                end.
            end.
            assign h-log-integrado-wms:sensitive = no
                   h-log-liberado-wms:sensitive = no.
        end.
    end.
    if not valid-handle(h-btUpdateOrderNew) and 
           valid-handle(h-btUpdateOrder)      
    then do:
      create button h-btUpdateOrderNew
         assign row       = h-btUpdateOrder:row
                col       = h-btUpdateOrder:col
                width     = h-btUpdateOrder:width
                height    = h-btUpdateOrder:height
                label     = h-btUpdateOrder:label
                visible   = yes
                tab-stop  = yes
                default   = yes
                tooltip   = h-btUpdateOrder:tooltip
                frame     = h-btUpdateOrder:frame
                triggers:
                   on choose persistent run intupc/upc-pd4000a.p.
                end triggers.
    
      h-btUpdateOrderNew:load-image(h-btUpdateOrder:image).
      h-btUpdateOrderNew:move-to-top().
      h-btUpdateOrderNew:move-after-tab-item(h-btUpdateOrder).
      h-btUpdateOrderNew:sensitive = yes.

    end. /* IF NOT VALID */

    if not valid-handle(h-btDeleteOrderNew) and 
           valid-handle(h-btDeleteOrder)      
    then do:
      create button h-btDeleteOrderNew
         assign row       = h-btDeleteOrder:row
                col       = h-btDeleteOrder:col
                width     = h-btDeleteOrder:width
                height    = h-btDeleteOrder:height
                label     = h-btDeleteOrder:label
                visible   = yes
                tab-stop  = yes
                default   = yes
                tooltip   = h-btDeleteOrder:tooltip
                frame     = h-btDeleteOrder:frame
                triggers:
                   on choose persistent run intupc/upc-pd4000b.p.
                end triggers.
    
      h-btDeleteOrderNew:load-image(h-btDeleteOrder:image).
      h-btDeleteOrderNew:move-to-top().
      h-btDeleteOrderNew:move-after-tab-item(h-btDeleteOrder).
      h-btDeleteOrderNew:sensitive = yes.

    end. /* IF NOT VALID */

    if not valid-handle(h-btUpdateItemNew) and 
           valid-handle(h-btUpdateItem)      
    then do:
      create button h-btUpdateItemNew
         assign row       = h-btUpdateItem:row
                col       = h-btUpdateItem:col
                width     = h-btUpdateItem:width
                height    = h-btUpdateItem:height
                label     = h-btUpdateItem:label
                visible   = yes
                tab-stop  = yes
                default   = yes
                tooltip   = h-btUpdateItem:tooltip
                frame     = h-btUpdateItem:frame
                triggers:
                   on choose persistent run intupc/upc-pd4000c.p.
                end triggers.
    
      h-btUpdateItemNew:load-image(h-btUpdateItem:image).
      h-btUpdateItemNew:move-to-top().
      h-btUpdateItemNew:move-after-tab-item(h-btUpdateItem).
      h-btUpdateItemNew:sensitive = yes.

    end. /* IF NOT VALID */

    if not valid-handle(h-btDeleteItemNew) and 
           valid-handle(h-btDeleteItem)      
    then do:
      create button h-btDeleteItemNew
         assign row       = h-btDeleteItem:row
                col       = h-btDeleteItem:col
                width     = h-btDeleteItem:width
                height    = h-btDeleteItem:height
                label     = h-btDeleteItem:label
                visible   = yes
                tab-stop  = yes
                default   = yes
                tooltip   = h-btDeleteItem:tooltip
                frame     = h-btDeleteItem:frame
                triggers:
                   on choose persistent run intupc/upc-pd4000d.p.
                end triggers.
    
      h-btDeleteItemNew:load-image(h-btDeleteItem:image).
      h-btDeleteItemNew:move-to-top().
      h-btDeleteItemNew:move-after-tab-item(h-btDeleteItem).
      h-btDeleteItemNew:sensitive = yes.

    end. /* IF NOT VALID */


end.

return "OK".
