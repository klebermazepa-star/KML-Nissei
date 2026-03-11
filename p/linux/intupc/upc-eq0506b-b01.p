/******************************************************************************
**
**     Programa: upc-eq0506b-b01.p
**
**     Objetivo: Customiza‡Æo da sele‡Æo de pedidos eq0506b-b01
**
**     Autor...: Alessandro V. Baccin 
**
**     VersÆo..: 1.00.00.001 - 22/02/2016
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
def var c-objeto        as char          no-undo.
def var h-campo         as widget-handle no-undo. 
def var h-tp-pedido-ini as widget-handle no-undo. 
def var h-tp-pedido-fim as widget-handle no-undo. 

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
