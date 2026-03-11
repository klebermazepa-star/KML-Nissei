/*******************************************************************************
**  Programa.: upc-cn0201a.p	- UPC programa Manuten‡Æo de Contratos
**  
**  Descri‡Æo: upc no botÆo Liberar para criar registro no esre1001
*********************************************************************************/

def input param p-ind-event        as char          no-undo.
def input param p-ind-object       as char          no-undo.
def input param p-wgh-object       as handle        no-undo.
def input param p-wgh-frame        as widget-handle no-undo.
def input param p-cod-table        as char          no-undo.
def input param p-row-table        as rowid         no-undo.

def new global shared var wh-nr-contrato-cn0201a   as widget-handle no-undo.
def new global shared var wh-txt-cod-esp-cn0201a   as widget-handle no-undo.
def new global shared var wh-cod-esp-cn0201a       as widget-handle no-undo.
def new global shared var wh-txt-tp-desp-cn0201a   as widget-handle no-undo.
def new global shared var wh-tp-desp-cn0201a       as widget-handle no-undo.

{utp/ut-glob.i}
/*MESSAGE p-ind-event              "p-ind-event  " skip
         p-ind-object             "p-ind-object " skip
         p-wgh-object:FILE-NAME   "p-wgh-object " skip
         p-wgh-frame:NAME         "p-wgh-frame  " skip
         p-cod-table              "p-cod-table  " skip
        string(p-row-table)      "p-row-table  " skip
 VIEW-AS ALERT-BOX INFO BUTTONS OK.*/

IF  p-ind-event  = "BEFORE-INITIALIZE" 
AND p-ind-object = "VIEWER"          
AND p-wgh-object:FILE-NAME = "cnp/cn0201a-v01.w" THEN DO:  

    RUN utils/findWidget.p (INPUT  'i-nr-contrato',   
                            INPUT  'FILL-IN',       
                            INPUT  p-wgh-frame,    
                            OUTPUT wh-nr-contrato-cn0201a).

    if valid-handle (wh-nr-contrato-cn0201a) then DO:

        CREATE TEXT wh-txt-cod-esp-cn0201a
        ASSIGN FRAME        = wh-nr-contrato-cn0201a:FRAME
               FORMAT       = "x(15)"
               WIDTH        = 5.86
               HEIGHT       = 0.54
               SCREEN-VALUE = "Esp‚cie:"
               ROW          = 9.75
               COL          = 64.12
               VISIBLE      = YES.
        
        CREATE FILL-IN wh-cod-esp-cn0201a
        ASSIGN FRAME             = wh-nr-contrato-cn0201a:FRAME
               SIDE-LABEL-HANDLE = wh-txt-cod-esp-cn0201a
               LABEL             = "Esp‚cie:"
               DATA-TYPE         = "CHARACTER"
               FORMAT            = "X(3)"
               WIDTH             = 5.00
               HEIGHT            = 0.88
               ROW               = 9.65
               COL               = 70.20
               NAME              = "cod-esp"
               SENSITIVE         = YES
               VISIBLE           = YES
               HELP              = "Esp‚cie".

        CREATE TEXT wh-txt-tp-desp-cn0201a
        ASSIGN FRAME        = wh-nr-contrato-cn0201a:FRAME
               FORMAT       = "x(15)"
               WIDTH        = 10.86
               HEIGHT       = 0.54
               SCREEN-VALUE = "Tipo Despesa:"
               ROW          = 10.75
               COL          = 60.02
               VISIBLE      = YES.
        
        CREATE FILL-IN wh-tp-desp-cn0201a
        ASSIGN FRAME             = wh-nr-contrato-cn0201a:FRAME
               SIDE-LABEL-HANDLE = wh-txt-tp-desp-cn0201a
               LABEL             = "Tipo Despesa:"
               DATA-TYPE         = "INTEGER"
               FORMAT            = ">>>9"
               WIDTH             = 5.00
               HEIGHT            = 0.88
               ROW               = 10.65
               COL               = 70.20
               NAME              = "tp-desp"
               SENSITIVE         = YES
               VISIBLE           = YES
               HELP              = "Tipo Despesa".

    END.
END.

IF  p-ind-event  = "DISPLAY" 
AND p-ind-object = "VIEWER"          
AND p-wgh-object:FILE-NAME = "cnp/cn0201a-v01.w" THEN DO:
    
    RUN utils/findWidget.p (INPUT  'i-nr-contrato',   
                            INPUT  'FILL-IN',       
                            INPUT  p-wgh-frame,    
                            OUTPUT wh-nr-contrato-cn0201a).

    FOR FIRST es-contrato-for NO-LOCK
        WHERE es-contrato-for.nr-contrato     = INT(wh-nr-contrato-cn0201a:SCREEN-VALUE): 

        ASSIGN wh-cod-esp-cn0201a:SCREEN-VALUE = STRING(es-contrato-for.cod-esp)
               wh-tp-desp-cn0201a:SCREEN-VALUE = STRING(es-contrato-for.tp-desp).
    END.
END.

IF  p-ind-event  = "ASSIGN" 
AND p-ind-object = "VIEWER" 
AND p-wgh-object:FILE-NAME = "cnp/cn0201a-v01.w" THEN DO:

    RUN utils/findWidget.p (INPUT  'i-nr-contrato',   
                            INPUT  'FILL-IN',       
                            INPUT  p-wgh-frame,    
                            OUTPUT wh-nr-contrato-cn0201a).

    FOR FIRST es-contrato-for EXCLUSIVE-LOCK
        WHERE es-contrato-for.nr-contrato     = wh-nr-contrato-cn0201a:INPUT-VALUE: END.
    IF NOT AVAIL es-contrato-for THEN DO:
        CREATE es-contrato-for.
        ASSIGN es-contrato-for.nr-contrato     = wh-nr-contrato-cn0201a:INPUT-VALUE.
    END.
    ASSIGN es-contrato-for.cod-esp = wh-cod-esp-cn0201a:INPUT-VALUE
           es-contrato-for.tp-desp = wh-tp-desp-cn0201a:INPUT-VALUE.

END.

IF VALID-HANDLE(wh-txt-cod-esp-cn0201a) THEN
    ASSIGN wh-txt-cod-esp-cn0201a:SCREEN-VALUE = "Esp‚cie:".

IF VALID-HANDLE(wh-txt-tp-desp-cn0201a) THEN
    ASSIGN wh-txt-tp-desp-cn0201a:SCREEN-VALUE = "Tipo Despesa:".


RETURN "OK".
