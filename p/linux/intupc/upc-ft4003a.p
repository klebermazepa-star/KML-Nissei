/******************************************************************************
**
**     Programa: UPC-FT4003
**
**     Objetivo: Chamada UPC no programa FT4003 para verificar pedido tipo 1
**
**     Autor...: Alessandro V. Baccin - AVB Planejamento e Consultoria
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

def new global shared var h-btOK-4003-new   AS WIDGET-HANDLE no-undo.
def new global shared var h-btOK-4003       AS widget-handle no-undo.
def new global shared var h-nr-pedcli-4003  as widget-handle no-undo. 
def new global shared var h-nome-abrev-4003 as widget-handle no-undo. 

/*
message "Evento.....: " p-ind-event  skip
        "Objeto.....: " p-ind-object skip
        "Nome Objeto: " c-objeto     skip
        "Frame......: " p-wgh-frame  skip
        "Tabela.....: " p-cod-table  skip
        "Rowid......: " string(p-row-table)
        view-as alert-box.
*/

if not valid-handle(h-nr-pedcli-4003) then 
do:
    RUN utils/findWidget.p (INPUT  'nr-pedcli',   
                            INPUT  'fill-in',      
                            INPUT  p-wgh-frame,
                            OUTPUT h-nr-pedcli-4003).
end.

if not valid-handle(h-nome-abrev-4003) then 
do:
    RUN utils/findWidget.p (INPUT  'nome-abrev',   
                            INPUT  'fill-in',      
                            INPUT  p-wgh-frame,
                            OUTPUT h-nome-abrev-4003).
end.

if not valid-handle (h-btOK-4003) then
do:
    RUN utils/findWidget.p (INPUT  'btOk',   
                            INPUT  'BUTTON',      
                            INPUT  p-wgh-frame,
                            OUTPUT h-btOK-4003).

    if not valid-handle (h-btOK-4003-new) then do:
        create button h-btOK-4003-new
        assign frame      = p-wgh-frame
               width      = h-btOK-4003:width
               height     = h-btOK-4003:height
               row        = h-btOK-4003:row + 0.3
               col        = h-btOK-4003:col
               visible    = yes
               sensitive  = yes 
               tab-stop   = false 
               label      = h-btOK-4003:label
               name       = "OK"
        triggers:
          on choose persistent run intupc\upc-ft4003a1.p.
        end triggers.

        /*h-btOK-4003-new:load-image(h-btOK-4003:image).*/
        h-btOK-4003-new:move-to-top().
        /*h-btOK-4003-new:move-after-tab-item(h-btOK-4003).*/
        h-btOK-4003-new:sensitive = yes.
        h-btOK-4003:tab-stop = no.
    end.    
end.

return "OK"
