/******************************************************************************************
**  Programa: upc-eq0506a.p
**  Versao..:  
**  Data....: Desabilitar campo numero de embarque e incrementar automaticamente 
******************************************************************************************/
DEF INPUT PARAM p-ind-event      AS   CHAR              NO-UNDO.
DEF INPUT PARAM p-ind-object     AS   CHAR              NO-UNDO.
DEF INPUT PARAM p-wgh-object     AS   HANDLE            NO-UNDO.
DEF INPUT PARAM p-wgh-frame      AS   WIDGET-HANDLE     NO-UNDO.
DEF INPUT PARAM p-cod-table      AS   CHAR              NO-UNDO.
DEF INPUT PARAM p-row-table      AS   ROWID             NO-UNDO.


DEFINE NEW GLOBAL SHARED VAR wh-frame                 AS WIDGET-HANDLE NO-UNDO.
DEFINE NEW GLOBAL SHARED VAR wh-nr-embarque-eq0506a   AS WIDGET-HANDLE no-undo.
DEFINE NEW GLOBAL SHARED VAR l-add-cq0506a            AS LOGICAL       NO-UNDO. 
          
define var c-objects      as character no-undo.
define var h-object       as handle    no-undo.
define var i-objects      as integer   no-undo.

/* MESSAGE p-ind-event              "p-ind-event  " skip 
        p-ind-object             "p-ind-object " skip
        p-wgh-object:FILE-NAME   "p-wgh-object " skip
        p-wgh-frame:NAME         "p-wgh-frame  " skip
        p-cod-table              "p-cod-table  " skip
       string(p-row-table)      "p-row-table  " skip
 VIEW-AS ALERT-BOX INFO BUTTONS OK.
*/

IF p-ind-event  = "INITIALIZE" AND  
   p-ind-object = "CONTAINER"
THEN DO:

   ASSIGN l-add-cq0506a = NO.

END.
     
IF ((p-ind-event  = "ADD" OR 
     p-ind-event  = "AFTER-ENABLE") AND  
     p-ind-object = "viewer")   
THEN DO:          
    
    ASSIGN wh-frame  = p-wgh-frame:FIRST-CHILD
           wh-frame  = wh-frame:FIRST-CHILD. 
 
    DO WHILE VALID-HANDLE(wh-frame):
       
        IF wh-frame:NAME = "cdd-embarq" THEN
           ASSIGN wh-nr-embarque-eq0506a = wh-frame.
        
        ASSIGN wh-frame = wh-frame:NEXT-SIBLING.

    END.
    
    IF p-ind-event = "ADD" THEN
       ASSIGN l-add-cq0506a = YES.

    IF VALID-HANDLE(wh-nr-embarque-eq0506a) THEN DO:
               
       ON entry OF wh-nr-embarque-eq0506a PERSISTENT RUN intupc/upc-eq0506a-01.p (INPUT "ENTRY").
       
    END. 
    
END.
 

