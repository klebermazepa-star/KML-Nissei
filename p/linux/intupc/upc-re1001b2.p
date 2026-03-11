/******************************************************************************************
**  Programa..: upc-re1001b2.p
**  Versao....:  
**  Objetivo..: Bloquear altera‡Æo dos itens de notas oriundos de XML
******************************************************************************************/
DEF INPUT PARAM p-ind-event      AS   CHAR              NO-UNDO.
DEF INPUT PARAM p-ind-object     AS   CHAR              NO-UNDO.
DEF INPUT PARAM p-wgh-object     AS   HANDLE            NO-UNDO.
DEF INPUT PARAM p-wgh-frame      AS   WIDGET-HANDLE     NO-UNDO.
DEF INPUT PARAM p-cod-table      AS   CHAR              NO-UNDO.
DEF INPUT PARAM p-row-table      AS   ROWID             NO-UNDO.

/*
MESSAGE p-ind-event              "p-ind-event  " skip 
         p-ind-object             "p-ind-object " skip
         p-wgh-object:FILE-NAME   "p-wgh-object " skip
         p-wgh-frame:NAME         "p-wgh-frame  " skip
         p-cod-table              "p-cod-table  " skip
        string(p-row-table)      "p-row-table  " skip 
 VIEW-AS ALERT-BOX INFO BUTTONS OK.                   
*/

DEFINE NEW GLOBAL SHARED VAR wh-frame                 AS WIDGET-HANDLE NO-UNDO.
DEFINE NEW GLOBAL SHARED VAR wh-object-frame          AS WIDGET-HANDLE NO-UNDO.
DEFINE NEW GLOBAL SHARED VAR wh-btOK-re1001b2         AS WIDGET-HANDLE no-undo.
DEFINE NEW GLOBAL SHARED VAR wh-btOK-re1001b2-new     AS WIDGET-HANDLE no-undo.
DEFINE NEW GLOBAL SHARED VAR wh-btSave-re1001b2         AS WIDGET-HANDLE no-undo.
DEFINE NEW GLOBAL SHARED VAR wh-btSave-re1001b2-new     AS WIDGET-HANDLE no-undo.

DEFINE NEW GLOBAL SHARED VAR r-row-item-re1001b       AS ROWID NO-UNDO.

define var c-objects      as character no-undo.
define var h-object       as handle    no-undo.
define var i-objects      as integer   no-undo.
define var l-habilita     as logical   no-undo.

/* {utp/ut-glob.i} 
def new Global shared var c-seg-usuario as char format "x(12)" no-undo.
*/ 

IF p-ind-event  = "before-initialize" AND  
   p-ind-object = "container" 
THEN DO:          

    ASSIGN wh-frame  = p-wgh-frame:FIRST-CHILD
           wh-frame  = wh-frame:FIRST-CHILD. 
 
    DO WHILE VALID-HANDLE(wh-frame):

        IF wh-frame:NAME = "btOK" THEN
           ASSIGN wh-btOK-re1001b2 = wh-frame.
        
        IF wh-frame:NAME = "btSave" THEN
           ASSIGN wh-btSave-re1001b2 = wh-frame.

        ASSIGN wh-frame = wh-frame:NEXT-SIBLING.

    END.
    
END.

IF p-ind-event  = "after-initialize" AND  
   p-ind-object = "container" 
THEN DO:  
  
  IF VALID-HANDLE (wh-btOK-re1001b2) THEN DO:
     CREATE BUTTON wh-btOK-re1001b2-new
     ASSIGN FRAME     = wh-btOK-re1001b2:FRAME                        
            LABEL     = wh-btOK-re1001b2:LABEL                            
            FONT      = wh-btOK-re1001b2:FONT
            WIDTH     = wh-btOK-re1001b2:WIDTH
            HEIGHT    = wh-btOK-re1001b2:HEIGHT
            ROW       = wh-btOK-re1001b2:ROW
            COL       = wh-btOK-re1001b2:COL
            FGCOLOR   = ?
            BGCOLOR   = ?
            DEFAULT   = YES
            CONVERT-3D-COLORS = wh-btOK-re1001b2:convert-3D-COLORS
            TOOLTIP   = wh-btOK-re1001b2:TOOLTIP
            VISIBLE   = wh-btOK-re1001b2:VISIBLE                                        
            SENSITIVE = wh-btOK-re1001b2:SENSITIVE
            TRIGGERS:
                ON CHOOSE PERSISTENT RUN intupc/upc-re1001b2-a.p.
            END TRIGGERS.
              
            wh-btOK-re1001b2-new:LOAD-IMAGE-UP(wh-btOK-re1001b2:IMAGE-UP).
            wh-btOK-re1001b2-new:LOAD-IMAGE-INSENSITIVE(wh-btOK-re1001b2:IMAGE-INSENSITIVE).
            wh-btOK-re1001b2-new:MOVE-TO-TOP().
  END.   
  IF VALID-HANDLE (wh-btSave-re1001b2) THEN DO:
     CREATE BUTTON wh-btSave-re1001b2-new
     ASSIGN FRAME     = wh-btSave-re1001b2:FRAME                        
            LABEL     = wh-btSave-re1001b2:LABEL                            
            FONT      = wh-btSave-re1001b2:FONT
            WIDTH     = wh-btSave-re1001b2:WIDTH
            HEIGHT    = wh-btSave-re1001b2:HEIGHT
            ROW       = wh-btSave-re1001b2:ROW
            COL       = wh-btSave-re1001b2:COL
            FGCOLOR   = ?
            BGCOLOR   = ?
            DEFAULT   = YES
            CONVERT-3D-COLORS = wh-btSave-re1001b2:convert-3D-COLORS
            TOOLTIP   = wh-btSave-re1001b2:TOOLTIP
            VISIBLE   = wh-btSave-re1001b2:VISIBLE                                        
            SENSITIVE = wh-btSave-re1001b2:SENSITIVE
            TRIGGERS:
                ON CHOOSE PERSISTENT RUN intupc/upc-re1001b2-b.p.
            END TRIGGERS.
              
            wh-btSave-re1001b2-new:LOAD-IMAGE-UP(wh-btSave-re1001b2:IMAGE-UP).
            wh-btSave-re1001b2-new:LOAD-IMAGE-INSENSITIVE(wh-btSave-re1001b2:IMAGE-INSENSITIVE).
            wh-btSave-re1001b2-new:MOVE-TO-TOP().
  END.   
END. 

if valid-handle( wh-btOK-re1001b2         ) AND valid-handle( wh-btOK-re1001b2-new     ) THEN ASSIGN wh-btOK-re1001b2-new:SENSITIVE = wh-btOK-re1001b2:SENSITIVE.
if valid-handle( wh-btSave-re1001b2       ) AND valid-handle( wh-btSave-re1001b2-new   ) THEN ASSIGN wh-btSave-re1001b2-new:SENSITIVE = wh-btSave-re1001b2:SENSITIVE.

IF (p-ind-event  = "after-control-tool-bar" OR p-ind-event  = "after-initialize") AND  
    p-ind-object = "container"
THEN DO:  
    ASSIGN r-row-item-re1001b = p-row-table.
END.

RETURN "OK".

