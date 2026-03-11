/*********************************************************************
** PROGRAMA
**   intupc/upc-eq0506b3.p
**
** FINALIDADE
**   Customiza‡Æo da sele‡Æo de pedidos eq0506b3
**
** VERSåES
**   22/02/2016 -  Cria‡Æo - AVB 
********************************************************************/

/* defini‡Æo de parƒmetros */
/*{utp/ut-glob.i}*/
def input parameter p-ind-event     as character     no-undo.
def input parameter p-ind-object    as character     no-undo.
def input parameter p-wgh-object    as handle        no-undo.
def input parameter p-wgh-frame     as widget-handle no-undo.
def input parameter p-cod-table     as character     no-undo.
def input parameter p-row-table     as rowid         no-undo.

/* Variable Definitions *****************************************************/
def var c-objeto        as char          no-undo.
def var h-campo         as widget-handle no-undo. 
def var h-tp-pedido-ini as widget-handle no-undo. 
def var h-tp-pedido-fim as widget-handle no-undo. 

def new global shared var h-btOK-0506b3-new   AS WIDGET-HANDLE no-undo.
def new global shared var h-btOK-0506b3       AS widget-handle no-undo.
def new global shared var h-btSave-0506b3-new   AS WIDGET-HANDLE no-undo.
def new global shared var h-btSave-0506b3       AS widget-handle no-undo.
def new global shared var h-nr-pedcli-0506b3  as widget-handle no-undo. 
def new global shared var h-nome-abrev-0506b3 as widget-handle no-undo. 

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

if not valid-handle(h-nr-pedcli-0506b3) then 
do:
    RUN utils/findWidget.p (INPUT  'nr-pedcli',   
                            INPUT  'fill-in',      
                            INPUT  p-wgh-frame,
                            OUTPUT h-nr-pedcli-0506b3).
end.

if not valid-handle(h-nome-abrev-0506b3) then 
do:
    RUN utils/findWidget.p (INPUT  'c-cliente',   
                            INPUT  'fill-in',      
                            INPUT  p-wgh-frame,
                            OUTPUT h-nome-abrev-0506b3).
end.

if not valid-handle (h-btOK-0506b3) then
do:
    RUN utils/findWidget.p (INPUT  'bt-Ok',   
                            INPUT  'BUTTON',      
                            INPUT  p-wgh-frame,
                            OUTPUT h-btOK-0506b3).

    if not valid-handle (h-btOK-0506b3-new) then do:
        create button h-btOK-0506b3-new
        assign frame      = p-wgh-frame
               width      = h-btOK-0506b3:width
               height     = h-btOK-0506b3:height
               row        = h-btOK-0506b3:row
               col        = h-btOK-0506b3:col
               visible    = yes
               sensitive  = yes 
               tab-stop   = false 
               label      = h-btOK-0506b3:label
               name       = "OK"
        triggers:
          on choose persistent run intupc\upc-eq0506b3a.p.
        end triggers.

        /*h-btOK-0506b3-new:load-image(h-btOK-0506b3:image).*/
        h-btOK-0506b3-new:move-to-top().
        /*h-btOK-0506b3-new:move-after-tab-item(h-btOK-0506b3).*/
        h-btOK-0506b3-new:sensitive = yes.
        h-btOK-0506b3:tab-stop = no.
    end.    
end.

if not valid-handle (h-btSave-0506b3) then
do:
    RUN utils/findWidget.p (INPUT  'bt-save',   
                            INPUT  'BUTTON',      
                            INPUT  p-wgh-frame,
                            OUTPUT h-btSave-0506b3).

    if not valid-handle (h-btSave-0506b3-new) then do:
        create button h-btSave-0506b3-new
        assign frame      = p-wgh-frame
               width      = h-btSave-0506b3:width
               height     = h-btSave-0506b3:height
               row        = h-btSave-0506b3:row
               col        = h-btSave-0506b3:col
               visible    = yes
               sensitive  = yes 
               tab-stop   = false 
               label      = h-btSave-0506b3:label
               name       = "OK"
        triggers:
          on choose persistent run intupc\upc-eq0506b3b.p.
        end triggers.

        /*h-btSave-0506b3-new:load-image(h-btSave-0506b3:image).*/
        h-btSave-0506b3-new:move-to-top().
        /*h-btSave-0506b3-new:move-after-tab-item(h-btSave-0506b3).*/
        h-btSave-0506b3-new:sensitive = yes.
        h-btSave-0506b3:tab-stop = no.
    end.    
end.


/* Tratamento de Armazenamento de Campos **************************************/
if p-ind-event  = "CREATE-TEMP-TABLE-ped-venda"
then do:
    for first ped-venda fields (nr-pedido tp-pedido)
        no-lock where rowid(ped-venda) = p-row-table:
        if ped-venda.tp-pedido = "1" then
        for first cst_ped_venda 
            no-lock where 
            cst_ped_venda.nr_pedido = ped-venda.nr-pedido:
            if  not cst_ped_venda.log_integrado_wms or
                not cst_ped_venda.log_liberado_wms 
                then return "NOK".
        end.
    end.
end.

return "OK".
