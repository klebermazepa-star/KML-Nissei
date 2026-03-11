/*****************************************************************************
**
**     Programa: UPC-CD0606-2  Botao relacionamento Natureza de operacao
**
**
*****************************************************************************/

def input param p-ind-event        as character     no-undo.
def input param p-ind-object       as character     no-undo.
def input param p-wgh-object       as handle        no-undo.
def input param p-wgh-frame        as widget-handle no-undo.
def input param p-cod-table        as character     no-undo.
def input param p-row-table        as rowid         no-undo.

def var c-objeto as char no-undo.

if valid-handle(p-wgh-object) then
   assign c-objeto  = entry(num-entries(p-wgh-object:private-data, "~/"),
                            p-wgh-object:private-data, "~/") no-error.

def new global shared var wgh-bt-cd0606         as widget-handle no-undo.
def new global shared var wgh-bt-cd0606-estab         as widget-handle no-undo.
def new global shared var wgh-bt-add-cd0606     as widget-handle no-undo.
def new global shared var gr-natur-oper-cd0606  as ROWID no-undo.


&if "{&aplica_facelift}" = "YES" &then
   {include/i_fcldef.i}
&endif

IF p-ind-event = "after-display" THEN DO:

    ASSIGN gr-natur-oper-cd0606 = p-row-table.

END.


IF  p-ind-event  = "after-initialize"
AND p-ind-object = "container" THEN DO:

   //message "criando botao" view-as alert-box.
        CREATE BUTTON wgh-bt-cd0606 
        ASSIGN FRAME     = p-wgh-frame
               WIDTH     = 4.00
               HEIGHT    = 1.25
               /*
               tooltip   = wgh-bt-cd0606:TOOLTIP
               */
               ROW       = 1.13
               COL       = 64.29
               /*
               FONT      = wgh-bt-cd0606:FONT
               */
               VISIBLE   = YES
               LABEL     = "PARAM"
               SENSITIVE = YES.                               
    
        wgh-bt-cd0606:MOVE-TO-TOP(). 
        wgh-bt-cd0606:LOAD-IMAGE-UP("image\im-exp.bmp").
        wgh-bt-cd0606:LOAD-IMAGE-INSENSITIVE("image\ii-exp.bmp").
        ON "choose" OF wgh-bt-cd0606  PERSISTENT RUN intupc\upc-cd0606-c.p.

        &if "{&aplica_facelift}" = "YES" &then
              {include/i_fcldin.i wgh-bt-cd0606}
        &endif 
        

END.

IF p-ind-event = "after-enable"
AND VALID-HANDLE(wgh-bt-cd0606) THEN
   ASSIGN wgh-bt-cd0606:SENSITIVE = NO.

IF p-ind-event = "after-disable"
AND VALID-HANDLE(wgh-bt-cd0606) THEN
   ASSIGN wgh-bt-cd0606:SENSITIVE = YES.



RETURN "OK".
