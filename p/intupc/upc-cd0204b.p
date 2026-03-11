/*********************************************************************************
**  Programa.: upc-cd0204b.p - UPC no programa Caracter¡sticas T‚cnicas do Item
**  
**  Descri‡Æo: Validar se a Caracter¡stica T‚cnica do Item ‚ obrigat¢ria
*********************************************************************************/

def input param p-ind-event        as char          no-undo.
def input param p-ind-object       as char          no-undo.
def input param p-wgh-object       as handle        no-undo.
def input param p-wgh-frame        as widget-handle no-undo.
def input param p-cod-table        as char          no-undo.
def input param p-row-table        as rowid         no-undo.

DEF VAR c-char                     AS CHAR          NO-UNDO.
DEF VAR l-result                   AS LOGICAL       NO-UNDO.

def new global shared var wh-cd-folh-item-cd0204   as widget-handle no-undo.
DEF NEW GLOBAL SHARED VAR wh-it-carac-tec-cd0204   AS WIDGET-HANDLE NO-UNDO.

DEFINE NEW GLOBAL SHARED VAR wh-bt-ok-orig-cd0204b    AS WIDGET-HANDLE NO-UNDO.
DEFINE NEW GLOBAL SHARED VAR wh-bt-ok-cd0204b         AS WIDGET-HANDLE NO-UNDO.
DEFINE NEW GLOBAL SHARED VAR wh-frame                 AS WIDGET-HANDLE NO-UNDO.

/******************************************************************************************************/
assign c-char = entry(num-entries(p-wgh-object:private-data, "~/"), p-wgh-object:private-data, "~/").

/*MESSAGE p-ind-event              "p-ind-event  " skip
        p-ind-object             "p-ind-object " skip
        p-wgh-object:FILE-NAME   "p-wgh-object " skip
        p-wgh-frame:NAME         "p-wgh-frame  " skip
        p-cod-table              "p-cod-table  " skip
        string(p-row-table)      "p-row-table  " skip
        c-char                                   SKIP
        VIEW-AS ALERT-BOX INFO BUTTONS OK.*/

IF ((p-ind-event  = "initialize" AND
     p-ind-object = "viewer" ) OR
    (p-ind-event  = "enable"   AND 
     p-ind-object = "container")) THEN DO:
        
    /*** Pegar objetos na tela ***/

    ASSIGN wh-frame  = p-wgh-frame:FIRST-CHILD
           wh-frame  = wh-frame:FIRST-CHILD.

    DO WHILE VALID-HANDLE(wh-frame):
                                
         IF wh-frame:NAME = "bt-ok" THEN
            ASSIGN wh-bt-ok-orig-cd0204b = wh-frame.

         IF wh-frame:NAME = "it-codigo" THEN 
            ASSIGN wh-it-carac-tec-cd0204 = wh-frame.

         ASSIGN wh-frame = wh-frame:NEXT-SIBLING.
         
    END.    
END.

IF p-ind-event  = "initialize" AND
   p-ind-object = "container" THEN DO:

   IF VALID-HANDLE(wh-bt-ok-orig-cd0204b) THEN DO:
      CREATE BUTTON wh-bt-ok-cd0204b
      ASSIGN FRAME     = wh-bt-ok-orig-cd0204b:FRAME
             LABEL     = wh-bt-ok-orig-cd0204b:LABEL
             FONT      = wh-bt-ok-orig-cd0204b:FONT
             WIDTH     = wh-bt-ok-orig-cd0204b:WIDTH
             HEIGHT    = wh-bt-ok-orig-cd0204b:HEIGHT
             ROW       = wh-bt-ok-orig-cd0204b:ROW
             COL       = wh-bt-ok-orig-cd0204b:COL 
             FGCOLOR   = wh-bt-ok-orig-cd0204b:FGCOLOR
             BGCOLOR   = wh-bt-ok-orig-cd0204b:BGCOLOR
             TOOLTIP   = wh-bt-ok-orig-cd0204b:TOOLTIP 
             VISIBLE   = wh-bt-ok-orig-cd0204b:VISIBLE
             SENSITIVE = YES
             TRIGGERS:
                 ON CHOOSE PERSISTENT RUN intupc/upc-cd0204b-01.p (INPUT "OK").
             END TRIGGERS.
                   
             wh-bt-ok-cd0204b:MOVE-TO-TOP().   
   END.
END.
