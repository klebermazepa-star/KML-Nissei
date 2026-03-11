/******************************************************************************
**
**     Programa: UPC-FT4003
**
**     Objetivo: Chamada UPC no programa FT4003 para verificar pedido tipo 1
**
**     Autor...: Alessandro V. Baccin 
**
**     Vers∆o..: 1.00.00.001 - 25/01/2016
**
******************************************************************************/
{utp/ut-glob.i}

def input param p-ind-event     as character     no-undo.
def input param p-ind-object    as character     no-undo.
def input param p-wgh-object    as handle        no-undo.
def input param p-wgh-frame     as widget-handle no-undo.
def input param p-cod-table     as character     no-undo.
def input param p-row-table     as rowid         no-undo.

def var c-objeto       as character     no-undo.
def var h_frame        as widget-handle no-undo.
def var h_campo        as widget-handle no-undo.

assign c-objeto = entry(num-entries(p-wgh-object:private-data,"~/"),
                        p-wgh-object:private-data, "~/").

def new global shared var h-bt-calcula-new   AS WIDGET-HANDLE.
def new global shared var h-bt-calcula      AS widget-handle.
def new global shared var v-row-table        as rowid.
def new global shared var h-ft4003           as handle no-undo.

/*
message "Evento.....: " p-ind-event  skip
        "Objeto.....: " p-ind-object skip
        "Nome Objeto: " c-objeto     skip
        "Frame......: " p-wgh-frame  skip
        "Tabela.....: " p-cod-table  skip
        "Rowid......: " string(p-row-table)
        view-as alert-box.
*/

if not valid-handle (h-bt-calcula) then
do:
    RUN utils/findWidget.p (INPUT  'btCalcula',   
                            INPUT  'BUTTON',      
                            INPUT  p-wgh-frame,
                            OUTPUT h-bt-calcula).

    if not valid-handle (h-bt-calcula-new) then do:
        create button h-bt-calcula-new
        assign frame      = p-wgh-frame
               width      = h-bt-calcula:width
               height     = h-bt-calcula:height
               row        = h-bt-calcula:row
               col        = h-bt-calcula:col
               visible    = yes
               sensitive  = yes 
               tab-stop   = false 
               label      = h-bt-calcula:label
               name       = "OK"
        triggers:
          on choose persistent run upc\upc-ft4003a.p.
        end triggers.

        h-bt-calcula-new:load-image(h-bt-calcula:image).
        h-bt-calcula-new:move-to-top().
        /*h-bt-calcula-new:move-after-tab-item(h-bt-calcula).*/
        h-bt-calcula-new:sensitive = yes.
        h-bt-calcula:tab-stop = no.

    end.    
end.

return "OK"
