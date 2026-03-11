/******************************************************************************
**
**     Programa: UPC-FT4002
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

def new global shared var h-bt-calcula-4002 as widget-handle no-undo. 
def new global shared var h-bt-calcula-4002-new as widget-handle no-undo. 
def new global shared var h-bt-conf-4002 as widget-handle no-undo. 
def new global shared var h-bt-conf-4002-new as widget-handle no-undo. 

def new global shared var h-bt-UpdateSon2-4002 as widget-handle no-undo. 
def new global shared var h-bt-UpdateSon2-4002-new as widget-handle no-undo. 
def new global shared var h-bt-DeleteSon2-4002 as widget-handle no-undo. 
def new global shared var h-bt-DeleteSon2-4002-new as widget-handle no-undo. 
def new global shared var h-bt-AtendSeq-4002 as widget-handle no-undo. 
def new global shared var h-bt-AtendSeq-4002-new as widget-handle no-undo. 

def new global shared var row-order as rowid no-undo.

/*
message "Evento.....: " p-ind-event  skip
        "Objeto.....: " p-ind-object skip
        "Nome Objeto: " c-objeto     skip
        "Frame......: " p-wgh-frame  skip
        "Tabela.....: " p-cod-table  skip
        "Rowid......: " string(p-row-table)
        view-as alert-box.
*/        

/*
if (p-ind-event  = "After-Display") AND
    p-ind-object = "Container"     then do:
   do:
      assign h_frame = p-wgh-frame:first-child.
      do while h_frame <> ?:
         if h_frame:type <> "field-group" then do:
            message  h_frame:name view-as alert-box.
            assign h_frame = h_frame:next-sibling.
         end.
         else do:
            assign h_frame = h_frame:first-child.
         end.
      end.
   end.
end.
*/
/* Main Block ***************************************************************/
if  p-cod-table = "ped-venda" and
    p-row-table <> ? then assign row-order = p-row-table.

/* Tratamento de Armazenamento de Campos **************************************/
/*
if not valid-handle (h-bt-calcula-4002) then
do:
    RUN utils/findWidget.p (INPUT  'btCalcula',   
                            INPUT  'BUTTON',      
                            INPUT  p-wgh-frame,
                            OUTPUT h-bt-calcula-4002).

    if not valid-handle (h-bt-calcula-4002-new) then do:
        create button h-bt-calcula-4002-new
        assign frame      = p-wgh-frame
               width      = h-bt-calcula-4002:width
               height     = h-bt-calcula-4002:height
               row        = h-bt-calcula-4002:row
               col        = h-bt-calcula-4002:col
               visible    = yes
               sensitive  = yes 
               tab-stop   = false 
               label      = h-bt-calcula-4002:label
               name       = "OK"
        triggers:
          on choose persistent run intupc\upc-ft4002a.p.
        end triggers.

        h-bt-calcula-4002-new:load-image(h-bt-calcula-4002:image).
        h-bt-calcula-4002-new:move-to-top().
/*        h-bt-calcula-4002-new:move-after-tab-item(h-bt-calcula-4002).*/
        h-bt-calcula-4002-new:sensitive = yes.
        h-bt-calcula-4002:tab-stop = no.
    end.    
    
    
end.
if not valid-handle (h-bt-conf-4002) then
do:

    RUN utils/findWidget.p (INPUT  'btConf',   
                            INPUT  'BUTTON',      
                            INPUT  p-wgh-frame,
                            OUTPUT h-bt-conf-4002).
    
    if  not valid-handle (h-bt-conf-4002-new) then do:
        create button h-bt-conf-4002-new
        assign frame      = p-wgh-frame
               width      = h-bt-conf-4002:width
               height     = h-bt-conf-4002:height
               row        = h-bt-conf-4002:row
               col        = h-bt-conf-4002:col
               visible    = yes
               sensitive  = yes 
               tab-stop   = false 
               label      = h-bt-conf-4002:label
               name       = "OK"
        triggers:
          on choose persistent run intupc\upc-ft4002b.p.
        end triggers.

        h-bt-conf-4002-new:load-image(h-bt-conf-4002:image).
        h-bt-conf-4002-new:move-to-top().
/*        h-bt-conf-4002-new:move-after-tab-item(h-bt-conf-4002).*/
        h-bt-conf-4002-new:sensitive = yes.
        h-bt-conf-4002:tab-stop = no.
    end.    
end.
*/
/* bloquear faturamento parcial */
if p-ind-event = "after-initialize" and
    p-ind-object = "container"  then do:
    if not valid-handle (h-bt-UpdateSon2-4002) then
    do:
        RUN utils/findWidget.p (INPUT  'btUpdateSon2',   
                                INPUT  'BUTTON',      
                                INPUT  p-wgh-frame,
                                OUTPUT h-bt-UpdateSon2-4002).

        if  not valid-handle (h-bt-UpdateSon2-4002-new) then do:
            create button h-bt-UpdateSon2-4002-new
            assign frame      = p-wgh-frame
                   width      = h-bt-UpdateSon2-4002:width
                   height     = h-bt-UpdateSon2-4002:height
                   row        = h-bt-UpdateSon2-4002:row
                   col        = h-bt-UpdateSon2-4002:col
                   visible    = yes
                   sensitive  = yes 
                   tab-stop   = false 
                   label      = h-bt-UpdateSon2-4002:label
                   name       = "OK"
            triggers:
              on choose persistent run intupc\upc-ft4002c.p.
            end triggers.

            h-bt-UpdateSon2-4002-new:load-image(h-bt-UpdateSon2-4002:image).
            h-bt-UpdateSon2-4002-new:move-to-top().
    /*        h-bt-UpdateSon2-4002-new:move-after-tab-item(h-bt-UpdateSon2-4002).*/
            h-bt-UpdateSon2-4002-new:sensitive = no.
            h-bt-UpdateSon2-4002:tab-stop = no.
        end.    
    end.

    if not valid-handle (h-bt-DeleteSon2-4002) then
    do:
        RUN utils/findWidget.p (INPUT  'btDeleteSon2',   
                                INPUT  'BUTTON',      
                                INPUT  p-wgh-frame,
                                OUTPUT h-bt-DeleteSon2-4002).

        if  not valid-handle (h-bt-DeleteSon2-4002-new) then do:
            create button h-bt-DeleteSon2-4002-new
            assign frame      = p-wgh-frame
                   width      = h-bt-DeleteSon2-4002:width
                   height     = h-bt-DeleteSon2-4002:height
                   row        = h-bt-DeleteSon2-4002:row
                   col        = h-bt-DeleteSon2-4002:col
                   visible    = yes
                   sensitive  = yes 
                   tab-stop   = false 
                   label      = h-bt-DeleteSon2-4002:label
                   name       = "OK"
            triggers:
              on choose persistent run intupc\upc-ft4002c.p.
            end triggers.

            h-bt-DeleteSon2-4002-new:load-image(h-bt-DeleteSon2-4002:image).
            h-bt-DeleteSon2-4002-new:move-to-top().
    /*        h-bt-DeleteSon2-4002-new:move-after-tab-item(h-bt-DeleteSon2-4002).*/
            h-bt-DeleteSon2-4002-new:sensitive = no.
            h-bt-DeleteSon2-4002:tab-stop = no.
        end.    
    end.

    if not valid-handle (h-bt-AtendSeq-4002) then
    do:
        RUN utils/findWidget.p (INPUT  'btAtendSeq',   
                                INPUT  'BUTTON',      
                                INPUT  p-wgh-frame,
                                OUTPUT h-bt-AtendSeq-4002).

        if  not valid-handle (h-bt-AtendSeq-4002-new) then do:
            create button h-bt-AtendSeq-4002-new
            assign frame      = p-wgh-frame
                   width      = h-bt-AtendSeq-4002:width
                   height     = h-bt-AtendSeq-4002:height
                   row        = h-bt-AtendSeq-4002:row
                   col        = h-bt-AtendSeq-4002:col
                   visible    = yes
                   sensitive  = yes 
                   tab-stop   = false 
                   label      = h-bt-AtendSeq-4002:label
                   name       = "OK"
            triggers:
              on choose persistent run intupc\upc-ft4002c.p.
            end triggers.

            h-bt-AtendSeq-4002-new:load-image(h-bt-AtendSeq-4002:image).
            h-bt-AtendSeq-4002-new:move-to-top().
    /*        h-bt-AtendSeq-4002-new:move-after-tab-item(h-bt-AtendSeq-4002).*/
            h-bt-AtendSeq-4002-new:sensitive = no.
            h-bt-AtendSeq-4002:tab-stop = no.
        end.    
    end.
end.
if valid-handle(h-bt-AtendSeq-4002) then h-bt-AtendSeq-4002:sensitive = no.
if valid-handle(h-bt-UpdateSon2-4002) then h-bt-UpdateSon2-4002:sensitive = no.
if valid-handle(h-bt-DeleteSon2-4002) then h-bt-DeleteSon2-4002:sensitive = no.
return "OK"
