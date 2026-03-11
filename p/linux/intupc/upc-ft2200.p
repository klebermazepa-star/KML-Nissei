/******************************************************************************
**
**     Programa: UPC-FT2200
**
**     Objetivo: Chamada UPC no programa FT4003 para verificar pedido tipo 1
**
**     Autor...: Alessandro V. Baccin - AVB Planejamento e Consultoria
**
**     Vers∆o..: 1.00.00.001 - 25/01/2016
**
******************************************************************************/
{utp/ut-glob.i}

def new global shared var row-order as rowid no-undo.
def new global shared var row-cst-order as rowid no-undo.

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

def new global shared var h-rs-reabre-2200 as widget-handle no-undo. 
def new global shared var h-cod-estabel-2200 as widget-handle no-undo. 
def new global shared var h-serie-2200 as widget-handle no-undo. 
def new global shared var h-nr-nota-fis-2200 as widget-handle no-undo. 
def new global shared var h-btok-2200 as widget-handle no-undo. 
def new global shared var h-btok-2200-new as widget-handle no-undo. 

/*
message "Evento.....: " p-ind-event  skip
        "Objeto.....: " p-ind-object skip
        "Nome Objeto: " c-objeto     skip
        "Frame......: " p-wgh-frame  skip
        "Tabela.....: " p-cod-table  skip
        "Rowid......: " string(p-row-table)
        view-as alert-box.
*/        

/* bloquear faturamento parcial */
if p-ind-event = "after-initialize" and
    p-ind-object = "container"  then do:
    if not valid-handle (h-rs-reabre-2200) then
    do:
        RUN utils/findWidget.p (INPUT  'rs-reabre',   
                                INPUT  'toggle-box',      
                                INPUT  p-wgh-frame,
                                OUTPUT h-rs-reabre-2200).
    end.

    if not valid-handle (h-cod-estabel-2200) then
    do:
        RUN utils/findWidget.p (INPUT  'cod-estabel',   
                                INPUT  'fill-in',
                                INPUT  p-wgh-frame,
                                OUTPUT h-cod-estabel-2200).
    end.
    if not valid-handle (h-serie-2200) then
    do:
        RUN utils/findWidget.p (INPUT  'serie', 
                                INPUT  'fill-in', 
                                INPUT  p-wgh-frame,
                                OUTPUT h-serie-2200).
    end.
    if not valid-handle (h-nr-nota-fis-2200) then
    do:
        RUN utils/findWidget.p (INPUT  'nr-nota-fis',
                                INPUT  'fill-in',      
                                INPUT  p-wgh-frame,
                                OUTPUT h-nr-nota-fis-2200).
    end.
    if not valid-handle (h-btok-2200) then
    do:
        RUN utils/findWidget.p (INPUT  'btOk',
                                INPUT  'button',
                                INPUT  p-wgh-frame,
                                OUTPUT h-btOk-2200).
    end.

    if valid-handle (h-btok-2200) then do:
       CREATE BUTTON h-btok-2200-new
       ASSIGN FRAME     = h-btok-2200:frame                       
              LABEL     = h-btok-2200:label 
              FONT      = h-btok-2200:font 
              WIDTH     = h-btok-2200:width 
              HEIGHT    = h-btok-2200:height 
              ROW       = h-btok-2200:row 
              COL       = h-btok-2200:col
              FGCOLOR   = ?
              BGCOLOR   = ?
              CONVERT-3D-COLORS = h-btok-2200:convert-3D-COLORS
              TOOLTIP   = "Executa relat¢rio"
              VISIBLE   = h-btok-2200:VISIBLE 
              SENSITIVE = h-btok-2200:SENSITIVE
              TRIGGERS:
                  ON CHOOSE PERSISTENT RUN intupc/upc-ft2200-1.p.
              END TRIGGERS.

              /*
              h-btok-2200-new:LOAD-IMAGE-UP(h-btok-2200:IMAGE-UP).
              h-btok-2200-new:LOAD-IMAGE-INSENSITIVE(h-btok-2200:IMAGE-INSENSITIVE).
              */
              h-btok-2200-new:MOVE-TO-TOP().

    end.

end.
return "OK"
