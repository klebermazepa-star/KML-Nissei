/*********************************************************************
** PROGRAMA
**   intupc/upc-eq0506b2.p
**
** FINALIDADE
**   Customiza‡Æo da sele‡Æo de pedidos eq0506b2
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

assign c-objeto = entry(num-entries(p-wgh-object:private-data, "~/"),
                                    p-wgh-object:private-data, "~/").
    
/*
message "Evento........: " p-ind-event         skip
        "Objeto........: " p-ind-object        skip
        "Handle Objeto.: " string(p-wgh-object) skip
        "Nome Objeto...: " c-objeto skip
        "Frame.........: " p-wgh-frame         skip
        "Tabela........: " p-cod-table         skip
        "Rowid.........: " string(p-row-table) skip
        view-as alert-box info buttons ok.
*/

/* Main Block ***************************************************************/

/* Tratamento de Armazenamento de Campos **************************************/
if (p-ind-event  = "INITIALIZE" AND 
    p-ind-object = "CONTAINER")
then do:

    if not valid-handle (h-tp-pedido-ini) then 
        RUN utils/findWidget.p (INPUT  'tp-pedido-ini',   
                                INPUT  'fill-in',      
                                INPUT  p-wgh-frame,
                                OUTPUT h-tp-pedido-ini).
                            
    if not valid-handle (h-tp-pedido-fim) then 
        RUN utils/findWidget.p (INPUT  'tp-pedido-fim',   
                                INPUT  'fill-in',      
                                INPUT  p-wgh-frame,
                                OUTPUT h-tp-pedido-fim).

    if valid-handle (h-tp-pedido-ini) then
    do:
        assign h-tp-pedido-ini:screen-value = "1".
    end.
    if valid-handle (h-tp-pedido-fim) then
    do:
        assign h-tp-pedido-fim:screen-value = "1".
    end.
end.

if valid-handle (h-tp-pedido-ini) then
do:
    assign h-tp-pedido-ini:screen-value = "1".
end.
if valid-handle (h-tp-pedido-fim) then
do:
    assign h-tp-pedido-fim:screen-value = "1".
end.
    
return "OK".
