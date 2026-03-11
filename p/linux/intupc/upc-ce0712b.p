/***************************************************************************************
**  Autor....: ResultPro
**  Cliente..: Nissei
**  Programa.: upc-ce0712b.p
**  
**  Objetivo: Criar filtro por estabelecimento 
***************************************************************************************/
DEF INPUT PARAM p-ind-event      AS   CHAR              NO-UNDO.
DEF INPUT PARAM p-ind-object     AS   CHAR              NO-UNDO.
DEF INPUT PARAM p-wgh-object     AS   HANDLE            NO-UNDO.
DEF INPUT PARAM p-wgh-frame      AS   WIDGET-HANDLE     NO-UNDO.
DEF INPUT PARAM p-cod-table      AS   CHAR              NO-UNDO.
DEF INPUT PARAM p-row-table      AS   ROWID             NO-UNDO.


DEFINE NEW GLOBAL SHARED VAR wh-frame                    AS WIDGET-HANDLE NO-UNDO.
DEFINE NEW GLOBAL SHARED VAR wh-object-frame             AS WIDGET-HANDLE NO-UNDO.
DEFINE NEW GLOBAL SHARED VAR wh-cod-estabel-ce0712       AS WIDGET-HANDLE no-undo.
DEFINE NEW GLOBAL SHARED VAR wh-c-cod-estabel-ini-ce0712 AS WIDGET-HANDLE no-undo.
DEFINE NEW GLOBAL SHARED VAR wh-c-cod-estabel-fim-ce0712 AS WIDGET-HANDLE no-undo.
DEFINE NEW GLOBAL SHARED VAR wh-bt-ok-orig-ce0712b       AS WIDGET-HANDLE NO-UNDO.
DEFINE NEW GLOBAL SHARED VAR wh-bt-ok-ce0712b            AS WIDGET-HANDLE NO-UNDO.


{utp/ut-glob.i}


IF p-ind-event  = "after-initialize" AND
   p-ind-object = "container"
THEN DO:
        
      ASSIGN wh-frame  = p-wgh-frame:FIRST-CHILD
             wh-frame  = wh-frame:FIRST-CHILD.

      DO WHILE VALID-HANDLE(wh-frame):

         IF wh-frame:NAME = "c-cod-estabel-ini" THEN
            ASSIGN wh-c-cod-estabel-ini-ce0712 = wh-frame.

         IF wh-frame:NAME = "c-cod-estabel-fim" THEN
           ASSIGN wh-c-cod-estabel-fim-ce0712 = wh-frame.
     
         IF wh-frame:NAME = "btOK" THEN
           ASSIGN wh-bt-ok-orig-ce0712b = wh-frame.
         
         ASSIGN wh-frame = wh-frame:NEXT-SIBLING.

      END.

      IF VALID-HANDLE(wh-c-cod-estabel-fim-ce0712) THEN DO:

          ASSIGN wh-c-cod-estabel-fim-ce0712:SENSITIVE = NO.


          ON LEAVE OF wh-c-cod-estabel-ini-ce0712 PERSISTENT RUN intupc\upc-ce0712b-01.p (INPUT "Leave").
      END.
      
      CREATE BUTTON wh-bt-ok-ce0712b 
      ASSIGN FRAME     = wh-bt-ok-orig-ce0712b:FRAME
             LABEL     = wh-bt-ok-orig-ce0712b:LABEL
             FONT      = wh-bt-ok-orig-ce0712b:FONT
             WIDTH     = wh-bt-ok-orig-ce0712b:WIDTH
             HEIGHT    = wh-bt-ok-orig-ce0712b:HEIGHT
             ROW       = wh-bt-ok-orig-ce0712b:ROW
             COL       = wh-bt-ok-orig-ce0712b:COL 
             FGCOLOR   = wh-bt-ok-orig-ce0712b:FGCOLOR
             BGCOLOR   = wh-bt-ok-orig-ce0712b:BGCOLOR
             TOOLTIP   = wh-bt-ok-orig-ce0712b:TOOLTIP 
             VISIBLE   = wh-bt-ok-orig-ce0712b:VISIBLE
             SENSITIVE = YES
             TRIGGERS:
                 ON CHOOSE PERSISTENT RUN intupc\upc-ce0712b-01.p (INPUT "OK").
             END TRIGGERS.
               
             wh-bt-ok-ce0712b:MOVE-TO-TOP().

END.

