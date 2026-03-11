/*****************************************************************************
*  Programa: UPC/FT0114.p - Atualizaá∆o de Serie X Estabelecimentos
*  
*  Autor: AVB Consultoria e Planejamento
*
*  Data: 06/2016
*
*  
******************************************************************************/

def input param p-ind-event        as char          no-undo.
def input param p-ind-object       as char          no-undo.
def input param p-wgh-object       as handle        no-undo.
def input param p-wgh-frame        as widget-handle no-undo.
def input param p-cod-table        as char          no-undo.
def input param p-row-table        as rowid         no-undo.

/* Global Variable Definitions **********************************************/
define new global shared var adm-broker-hdl as handle no-undo.

/* Variable Definitions *****************************************************/
define var c-objects      as character no-undo.
define var i-objects      as integer   no-undo.
define var h-object       as handle    no-undo.
DEFINE var h-campo        as widget-handle no-undo. 

define new global shared var h-forma-emis      as handle no-undo.
define new global shared var h-lbl-forma-emis  as handle no-undo.
define new global shared var h-114-cod-estabel as handle no-undo.
define new global shared var h-114-serie       as handle no-undo.

def var c-objeto as char no-undo.
assign c-objeto   = entry(num-entries(p-wgh-object:private-data, "~/"), p-wgh-object:private-data, "~/").

/*
message "EVENTO" p-ind-event skip
        "OBJETO" p-ind-object skip
        "NOME OBJ" c-objeto skip
        "FRAME" p-wgh-frame skip
        "TABELA" p-cod-table skip
        "ROWID" string(p-row-table) 
    view-as alert-box.

if valid-handle (h-forma-emis) then
    message int(h-forma-emis:screen-value) "AA" view-as alert-box.
*/
  

/* Main Block ***************************************************************/
/* Main Block ***************************************************************/
/* Tratamento de Armazenamento de Campos **************************************/
if (p-ind-event  = "INITIALIZE" AND 
    p-ind-object = "CONTAINER")
then do:

    RUN utils/findWidget.p (INPUT  'cod-estabel',   
                            INPUT  'fill-in',       
                            INPUT  p-wgh-frame,    
                            OUTPUT h-campo).
    if valid-handle (h-campo) then assign h-114-cod-estabel = h-campo.
    RUN utils/findWidget.p (INPUT  'serie',   
                            INPUT  'fill-in',       
                            INPUT  p-wgh-frame,    
                            OUTPUT h-campo).
    if valid-handle (h-campo) then assign h-114-serie = h-campo.

    /* cria campos da tela */     
    if     valid-handle (h-campo) /*and 
       not valid-handle (h-forma-emis)*/ then
    do:
        create text h-lbl-forma-emis
            assign
                name      = 'lbl-forma-emis':u
                frame     = h-campo:frame
                row       = h-campo:row + 0.15
                format    = 'x(18)'
                col       = h-campo:col + 22
                width     = 6.5
                screen-value = 'Emiss∆o:'
                font      = h-campo:font
                fgcolor   = h-campo:fgcolor
                visible   = yes.
    
        create radio-set h-forma-emis
            assign
                name      = 'forma-emis':u
                frame     = h-campo:frame
                horizontal = true
                width     = 20
                height    = .88
                column    = h-lbl-forma-emis:col + h-lbl-forma-emis:width
                row       = h-campo:row
                font      = h-campo:font
                fgcolor   = h-campo:fgcolor
                side-label-handle = h-lbl-forma-emis
                radio-buttons = "Autom†tica,1,Manual,2"
                help      = 'Forma de emiss∆o da sÇrie (Autom†tica para Faturamento/MANUAL para importaá∆o de CUPONS)':u
                tooltip   = 'Forma de emiss∆o da sÇrie (Autom†tica para Faturamento/MANUAL para importaá∆o de CUPONS)':u
                visible   = true
                sensitive = no.

        h-forma-emis:tab-stop = yes.
    end.

    if valid-handle (h-forma-emis) then
    do:
        for first ser-estab where 
            ser-estab.cod-estabel = h-114-cod-estabel:screen-value and
            ser-estab.serie = h-114-serie:screen-value. end.
        if avail ser-estab then
        do:
            assign h-forma-emis:screen-value = string(ser-estab.forma-emis).
        end.
    end.

end.

 /* Cria o fill-in na tela  **************************************/
 if p-ind-event = "DISPLAY" and 
    p-ind-object = "VIEWER" and
    c-objeto = "V01DI182.W"
 then do:

     if valid-handle (h-forma-emis) then
     do:
         for first ser-estab where 
             ser-estab.cod-estabel = h-114-cod-estabel:screen-value and
             ser-estab.serie = h-114-serie:screen-value. end.
         if avail ser-estab then
         do:
             assign h-forma-emis:screen-value = string(ser-estab.forma-emis).
         end.
     end.
 end.

  /* Tratamento de Gravaá∆o de Campos **************************************/
 IF (p-ind-event = "AFTER-END-UPDATE" or
     p-ind-event = "ASSIGN") and
     p-ind-object = "VIEWER" and
     c-objeto = "V01DI182.W"
 THEN DO:
     for first ser-estab where 
         ser-estab.cod-estabel = h-114-cod-estabel:screen-value and
         ser-estab.serie = h-114-serie:screen-value. end.
     if NOT AVAIL ser-estab THEN do:
         CREATE ser-estab.
         ASSIGN ser-estab.cod-estabel = h-114-cod-estabel:screen-value
                ser-estab.serie       = h-114-serie:screen-value.
     end.
     assign ser-estab.forma-emis = int(h-forma-emis:screen-value).
     assign h-forma-emis:sensitive = no.
 END.

 /* Tratamento de Eliminaá∆o de Registros **************************************/
 IF p-ind-event = "BEFORE-DELETE" and 
    p-ind-object = "CONTAINER"
 THEN DO:
     for first ser-estab where 
         ser-estab.cod-estabel = h-114-cod-estabel:screen-value and
         ser-estab.serie = h-114-serie:screen-value. end.
     IF AVAIL ser-estab THEN delete ser-estab.
 END.

 /* Tratamento de Alteraá∆o de Registros **************************************/
 IF p-ind-event = "ENABLE" and 
     p-ind-object = "VIEWER" and
     c-objeto = "V01DI182.W"
 THEN DO:
     if valid-handle (h-forma-emis) then
     do:
         assign h-forma-emis:sensitive = h-114-cod-estabel:sensitive.
     end.
 END.

 /* Tratamento de Cancelamento de Registros **************************************/
 IF p-ind-event = "CANCEL" and 
    p-ind-object = "VIEWER" and
    c-objeto = "V01DI182.W"
 THEN DO:
     if valid-handle (h-forma-emis) then
     do:
         assign h-forma-emis:sensitive = no.
     end.
 END.

RETURN "OK".
