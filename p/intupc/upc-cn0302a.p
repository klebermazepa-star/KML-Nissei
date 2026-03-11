/*******************************************************************************
**  Programa.: upc-cn0302a.p	- UPC programa Manutená∆o de Contratos
**  
**  Descriá∆o: upc no bot∆o Liberar para criar registro no esre1001
*********************************************************************************/

def input param p-ind-event        as char          no-undo.
def input param p-ind-object       as char          no-undo.
def input param p-wgh-object       as handle        no-undo.
def input param p-wgh-frame        as widget-handle no-undo.
def input param p-cod-table        as char          no-undo.
def input param p-row-table        as rowid         no-undo.

def new global shared var wh-nr-contrato-cn0302a   as widget-handle no-undo.
def new global shared var wh-txt-dt-valid-cn0302a  as widget-handle no-undo.
def new global shared var wh-dt-valid-cn0302a      as widget-handle no-undo.

def new global shared var wh-num-seq-item-cn0302a       as widget-handle no-undo.
def new global shared var wh-numero-ordem-cn0302a       as widget-handle no-undo.
def new global shared var wh-num-seq-event-cn0302a      as widget-handle no-undo.
def new global shared var wh-num-seq-medicao-cn0302a    as widget-handle no-undo.

{utp/ut-glob.i}
/*MESSAGE p-ind-event              "p-ind-event  " skip
         p-ind-object             "p-ind-object " skip
         p-wgh-object:FILE-NAME   "p-wgh-object " skip
         p-wgh-frame:NAME         "p-wgh-frame  " skip
         p-cod-table              "p-cod-table  " skip
        string(p-row-table)      "p-row-table  " skip
 VIEW-AS ALERT-BOX INFO BUTTONS OK.*/

IF p-ind-event  = "BEFORE-INITIALIZE" AND  
   p-ind-object = "VIEWER"          THEN DO:  

    RUN utils/findWidget.p (INPUT  'i-nr-contrato',   
                            INPUT  'FILL-IN',       
                            INPUT  p-wgh-frame,    
                            OUTPUT wh-nr-contrato-cn0302a).

    RUN utils/findWidget.p (INPUT  'i-num-seq-item',   
                            INPUT  'FILL-IN',       
                            INPUT  p-wgh-frame,    
                            OUTPUT wh-num-seq-item-cn0302a).
    
    RUN utils/findWidget.p (INPUT  'i-numero-ordem',   
                            INPUT  'FILL-IN',       
                            INPUT  p-wgh-frame,    
                            OUTPUT wh-numero-ordem-cn0302a).
    
    RUN utils/findWidget.p (INPUT  'num-seq-event',   
                            INPUT  'FILL-IN',       
                            INPUT  p-wgh-frame,    
                            OUTPUT wh-num-seq-event-cn0302a).
    
    RUN utils/findWidget.p (INPUT  'num-seq-medicao',   
                            INPUT  'FILL-IN',       
                            INPUT  p-wgh-frame,    
                            OUTPUT wh-num-seq-medicao-cn0302a).


    if valid-handle (wh-nr-contrato-cn0302a) then DO:
    
        CREATE TEXT wh-txt-dt-valid-cn0302a
        ASSIGN FRAME        = wh-nr-contrato-cn0302a:FRAME
               FORMAT       = "x(15)"
               WIDTH        = 9.86
               HEIGHT       = 0.54
               SCREEN-VALUE = "Data Validade:"
               ROW          = 12.39
               COL          = 11.22
               VISIBLE      = YES.
        
        CREATE FILL-IN wh-dt-valid-cn0302a
        ASSIGN FRAME             = wh-nr-contrato-cn0302a:FRAME
               SIDE-LABEL-HANDLE = wh-txt-dt-valid-cn0302a
               LABEL             = "Data Validade:"
               DATA-TYPE         = "DATE"
               FORMAT            = "99/99/9999"
               WIDTH             = 10.00
               HEIGHT            = 0.88
               ROW               = 12.29
               COL               = 21.70
               NAME              = "dt-valid"
               SENSITIVE         = YES
               VISIBLE           = YES
               HELP              = "Data Validade".

        FOR FIRST medicao-contrat NO-LOCK
            WHERE ROWID(medicao-contrat) = p-row-table,
            FIRST es-medicao-contrat NO-LOCK
            WHERE es-medicao-contrat.nr-contrato     = medicao-contrat.nr-contrato
            AND   es-medicao-contrat.num-seq-item    = medicao-contrat.num-seq-item
            AND   es-medicao-contrat.numero-ordem    = medicao-contrat.numero-ordem
            AND   es-medicao-contrat.num-seq-event   = medicao-contrat.num-seq-event
            AND   es-medicao-contrat.num-seq-medicao = medicao-contrat.num-seq-medicao:
            ASSIGN wh-dt-valid-cn0302a:SCREEN-VALUE = STRING(es-medicao-contrat.dt-valid).
        END.
    END.
END.

IF p-ind-event  = "ASSIGN" AND  
   p-ind-object = "VIEWER" THEN DO:

    FOR FIRST es-medicao-contrat EXCLUSIVE-LOCK
        WHERE es-medicao-contrat.nr-contrato     = wh-nr-contrato-cn0302a    :INPUT-VALUE
        AND   es-medicao-contrat.num-seq-item    = wh-num-seq-item-cn0302a   :INPUT-VALUE
        AND   es-medicao-contrat.numero-ordem    = wh-numero-ordem-cn0302a   :INPUT-VALUE
        AND   es-medicao-contrat.num-seq-event   = wh-num-seq-event-cn0302a  :INPUT-VALUE
        AND   es-medicao-contrat.num-seq-medicao = wh-num-seq-medicao-cn0302a:INPUT-VALUE: END.
    IF NOT AVAIL es-medicao-contrat THEN DO:
        CREATE es-medicao-contrat.
        ASSIGN es-medicao-contrat.nr-contrato     = wh-nr-contrato-cn0302a    :INPUT-VALUE
               es-medicao-contrat.num-seq-item    = wh-num-seq-item-cn0302a   :INPUT-VALUE
               es-medicao-contrat.numero-ordem    = wh-numero-ordem-cn0302a   :INPUT-VALUE
               es-medicao-contrat.num-seq-event   = wh-num-seq-event-cn0302a  :INPUT-VALUE
               es-medicao-contrat.num-seq-medicao = wh-num-seq-medicao-cn0302a:INPUT-VALUE.
    END.
    ASSIGN es-medicao-contrat.dt-valid = wh-dt-valid-cn0302a:INPUT-VALUE.

END.

IF VALID-HANDLE(wh-txt-dt-valid-cn0302a) THEN
    ASSIGN wh-txt-dt-valid-cn0302a:SCREEN-VALUE = "Data Validade:".
    //       wh-dt-valid-cn0302a:SCREEN-VALUE = STRING(TODAY).

RETURN "OK".
