/******************************************************************************************
**  Programa..: upc-re1001b.p
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

DEFINE NEW GLOBAL SHARED VAR wh-btAdd-re1001b         AS WIDGET-HANDLE no-undo.
DEFINE NEW GLOBAL SHARED VAR wh-btUpdate-re1001b      AS WIDGET-HANDLE no-undo.
DEFINE NEW GLOBAL SHARED VAR wh-btCopy-re1001b        AS WIDGET-HANDLE no-undo.
DEFINE NEW GLOBAL SHARED VAR wh-btDelete-re1001b      AS WIDGET-HANDLE no-undo.
                                                                               
DEFINE NEW GLOBAL SHARED VAR wh-btAdd-re1001b-new     AS WIDGET-HANDLE no-undo.
DEFINE NEW GLOBAL SHARED VAR wh-btUpdate-re1001b-new  AS WIDGET-HANDLE no-undo.
DEFINE NEW GLOBAL SHARED VAR wh-btCopy-re1001b-new    AS WIDGET-HANDLE no-undo.
DEFINE NEW GLOBAL SHARED VAR wh-btDelete-re1001b-new  AS WIDGET-HANDLE no-undo.

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

        IF wh-frame:NAME = "btAdd" THEN
           ASSIGN wh-btAdd-re1001b = wh-frame.
        
        IF wh-frame:NAME = "btUpdate" THEN
           ASSIGN wh-btUpdate-re1001b = wh-frame.

        IF wh-frame:NAME = "btCopy" THEN
           ASSIGN wh-btCopy-re1001b = wh-frame.

        IF wh-frame:NAME = "btDelete" THEN
           ASSIGN wh-btDelete-re1001b = wh-frame.

        ASSIGN wh-frame = wh-frame:NEXT-SIBLING.

    END.
    
END.

IF p-ind-event  = "after-initialize" AND  
   p-ind-object = "container" 
THEN DO:  
  
  IF VALID-HANDLE (wh-btAdd-re1001b) THEN DO:
         
     CREATE BUTTON wh-btAdd-re1001b-new
     ASSIGN FRAME     = wh-btAdd-re1001b:FRAME                        
            LABEL     = wh-btAdd-re1001b:LABEL                            
            FONT      = wh-btAdd-re1001b:FONT
            WIDTH     = wh-btAdd-re1001b:WIDTH
            HEIGHT    = wh-btAdd-re1001b:HEIGHT
            ROW       = wh-btAdd-re1001b:ROW
            COL       = wh-btAdd-re1001b:COL
            FGCOLOR   = ?
            BGCOLOR   = ?
            CONVERT-3D-COLORS = wh-btAdd-re1001b:convert-3D-COLORS
            TOOLTIP   = wh-btAdd-re1001b:TOOLTIP
            VISIBLE   = wh-btAdd-re1001b:VISIBLE                                        
            SENSITIVE = wh-btAdd-re1001b:SENSITIVE
            TRIGGERS:
                ON CHOOSE PERSISTENT RUN intupc/upc-re1001b-a.p.
            END TRIGGERS.
              
            wh-btAdd-re1001b-new:LOAD-IMAGE-UP(wh-btAdd-re1001b:IMAGE-UP).
            wh-btAdd-re1001b-new:LOAD-IMAGE-INSENSITIVE(wh-btAdd-re1001b:IMAGE-INSENSITIVE).
            wh-btAdd-re1001b-new:MOVE-TO-TOP().
  END.   
  IF VALID-HANDLE (wh-btUpdate-re1001b) THEN DO:

     CREATE BUTTON wh-btUpdate-re1001b-new
     ASSIGN FRAME     = wh-btUpdate-re1001b:FRAME                        
            LABEL     = wh-btUpdate-re1001b:LABEL                            
            FONT      = wh-btUpdate-re1001b:FONT
            WIDTH     = wh-btUpdate-re1001b:WIDTH
            HEIGHT    = wh-btUpdate-re1001b:HEIGHT
            ROW       = wh-btUpdate-re1001b:ROW
            COL       = wh-btUpdate-re1001b:COL
            FGCOLOR   = ?
            BGCOLOR   = ?
            CONVERT-3D-COLORS = wh-btUpdate-re1001b:convert-3D-COLORS
            TOOLTIP   = wh-btUpdate-re1001b:TOOLTIP
            VISIBLE   = wh-btUpdate-re1001b:VISIBLE                                        
            SENSITIVE = wh-btUpdate-re1001b:SENSITIVE
            TRIGGERS:
                ON CHOOSE PERSISTENT RUN intupc/upc-re1001b-b.p.
            END TRIGGERS.
    
            wh-btUpdate-re1001b-new:LOAD-IMAGE-UP(wh-btUpdate-re1001b:IMAGE-UP).
            wh-btUpdate-re1001b-new:LOAD-IMAGE-INSENSITIVE(wh-btUpdate-re1001b:IMAGE-INSENSITIVE).
            wh-btUpdate-re1001b-new:MOVE-TO-TOP().
  END.   

  IF VALID-HANDLE (wh-btCopy-re1001b) THEN DO:

     CREATE BUTTON wh-btCopy-re1001b-new
     ASSIGN FRAME     = wh-btCopy-re1001b:FRAME                        
            LABEL     = wh-btCopy-re1001b:LABEL                            
            FONT      = wh-btCopy-re1001b:FONT
            WIDTH     = wh-btCopy-re1001b:WIDTH
            HEIGHT    = wh-btCopy-re1001b:HEIGHT
            ROW       = wh-btCopy-re1001b:ROW
            COL       = wh-btCopy-re1001b:COL
            FGCOLOR   = ?
            BGCOLOR   = ?
            CONVERT-3D-COLORS = wh-btCopy-re1001b:convert-3D-COLORS
            TOOLTIP   = wh-btCopy-re1001b:TOOLTIP
            VISIBLE   = wh-btCopy-re1001b:VISIBLE                                        
            SENSITIVE = wh-btCopy-re1001b:SENSITIVE
            TRIGGERS:
                ON CHOOSE PERSISTENT RUN intupc/upc-re1001b-c.p.
            END TRIGGERS.
       
            wh-btCopy-re1001b-new:LOAD-IMAGE-UP(wh-btCopy-re1001b:IMAGE-UP).
            wh-btCopy-re1001b-new:LOAD-IMAGE-INSENSITIVE(wh-btCopy-re1001b:IMAGE-INSENSITIVE).
            wh-btCopy-re1001b-new:MOVE-TO-TOP().
  END.   

  IF VALID-HANDLE (wh-btDelete-re1001b) THEN DO:

     CREATE BUTTON wh-btDelete-re1001b-new
     ASSIGN FRAME     = wh-btDelete-re1001b:FRAME                        
            LABEL     = wh-btDelete-re1001b:LABEL                            
            FONT      = wh-btDelete-re1001b:FONT
            WIDTH     = wh-btDelete-re1001b:WIDTH
            HEIGHT    = wh-btDelete-re1001b:HEIGHT
            ROW       = wh-btDelete-re1001b:ROW
            COL       = wh-btDelete-re1001b:COL
            FGCOLOR   = ?
            BGCOLOR   = ?
            CONVERT-3D-COLORS = wh-btDelete-re1001b:convert-3D-COLORS
            TOOLTIP   = wh-btDelete-re1001b:TOOLTIP
            VISIBLE   = wh-btDelete-re1001b:VISIBLE                                        
            SENSITIVE = wh-btDelete-re1001b:SENSITIVE
            TRIGGERS:
                ON CHOOSE PERSISTENT RUN intupc/upc-re1001b-d.p.
            END TRIGGERS.
       
            wh-btDelete-re1001b-new:LOAD-IMAGE-UP(wh-btDelete-re1001b:IMAGE-UP).
            wh-btDelete-re1001b-new:LOAD-IMAGE-INSENSITIVE(wh-btDelete-re1001b:IMAGE-INSENSITIVE).
            wh-btDelete-re1001b-new:MOVE-TO-TOP().
  END.   

END. 
IF (p-ind-event  = "after-control-tool-bar" OR p-ind-event  = "after-initialize") AND  
    p-ind-object = "container"
THEN DO:  
    ASSIGN r-row-item-re1001b = p-row-table.
END.

RETURN "OK".

