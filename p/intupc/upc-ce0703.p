/***************************************************************************************
**  Autor....: ResultPro
**  Cliente..: Nissei
**  Programa.: upc-ce0703.p
**  
**  Objetivo: Desabilitar o campo de sele‡Æo do estabelecimento 
***************************************************************************************/
DEF INPUT PARAM p-ind-event      AS   CHAR              NO-UNDO.
DEF INPUT PARAM p-ind-object     AS   CHAR              NO-UNDO.
DEF INPUT PARAM p-wgh-object     AS   HANDLE            NO-UNDO.
DEF INPUT PARAM p-wgh-frame      AS   WIDGET-HANDLE     NO-UNDO.
DEF INPUT PARAM p-cod-table      AS   CHAR              NO-UNDO.
DEF INPUT PARAM p-row-table      AS   ROWID             NO-UNDO.

DEFINE NEW GLOBAL SHARED VAR wh-frame               AS WIDGET-HANDLE NO-UNDO.
DEFINE NEW GLOBAL SHARED VAR wh-object-frame        AS WIDGET-HANDLE NO-UNDO.
DEFINE NEW GLOBAL SHARED VAR wh-btexec-orig-ce0703  AS WIDGET-HANDLE no-undo.
DEFINE NEW GLOBAL SHARED VAR wh-btexec-ce0703       AS WIDGET-HANDLE no-undo.
DEFINE NEW GLOBAL SHARED VAR wh-br-digita-ce0703    AS WIDGET-HANDLE no-undo.
DEFINE NEW GLOBAL SHARED VAR wh-c-estab-ini-ce0703  AS WIDGET-HANDLE NO-UNDO.
DEFINE NEW GLOBAL SHARED VAR wh-c-estab-fim-ce0703  AS WIDGET-HANDLE NO-UNDO.
DEFINE NEW GLOBAL SHARED VAR wh-image-17-ce0703     AS WIDGET-HANDLE no-undo.
DEFINE NEW GLOBAL SHARED VAR wh-image-18-ce0703     AS WIDGET-HANDLE no-undo.
                                                   
{utp/ut-glob.i}

IF p-ind-event  = "enable" AND
   p-ind-object = "container"
THEN DO:

    ASSIGN wh-frame  = p-wgh-frame:FIRST-CHILD
           wh-frame  = wh-frame:FIRST-CHILD.

    DO WHILE VALID-HANDLE(wh-frame):
     
        IF wh-frame:NAME = "bt-executar" THEN
           ASSIGN wh-btexec-orig-ce0703 = wh-frame.

        ASSIGN wh-frame = wh-frame:NEXT-SIBLING.
    END.

    IF VALID-HANDLE (wh-btexec-orig-ce0703)
    THEN DO:
      
        CREATE BUTTON wh-btexec-ce0703 
        ASSIGN FRAME     = wh-btexec-orig-ce0703:FRAME
               LABEL     = wh-btexec-orig-ce0703:LABEL
               FONT      = wh-btexec-orig-ce0703:FONT
               WIDTH     = wh-btexec-orig-ce0703:WIDTH
               HEIGHT    = wh-btexec-orig-ce0703:HEIGHT
               ROW       = wh-btexec-orig-ce0703:ROW
               COL       = wh-btexec-orig-ce0703:COL 
               FGCOLOR   = wh-btexec-orig-ce0703:FGCOLOR
               BGCOLOR   = wh-btexec-orig-ce0703:BGCOLOR
               TOOLTIP   = wh-btexec-orig-ce0703:TOOLTIP 
               VISIBLE   = wh-btexec-orig-ce0703:VISIBLE
               NAME      = "wh-bt-exec-espec"
               SENSITIVE = YES
               TRIGGERS:
                   ON CHOOSE PERSISTENT RUN intupc/upc-ce0703-a.p.
               END TRIGGERS.  
             
               wh-btexec-ce0703:MOVE-TO-TOP().
        
    END.

END.

IF p-ind-event  = "change-page" AND
   p-ind-object = "container"
THEN DO:

    ASSIGN wh-frame  = p-wgh-frame:FIRST-CHILD
           wh-frame  = wh-frame:FIRST-CHILD.

    DO WHILE VALID-HANDLE(wh-frame):

        IF wh-frame:NAME = "c-estab-ini" THEN
           ASSIGN wh-c-estab-ini-ce0703 = wh-frame.

        IF wh-frame:NAME = "c-estab-fim" THEN
           ASSIGN wh-c-estab-fim-ce0703 = wh-frame.

        IF wh-frame:NAME = "image-17" THEN
           ASSIGN wh-image-17-ce0703 = wh-frame.

        IF wh-frame:NAME = "image-18" THEN
           ASSIGN wh-image-18-ce0703 = wh-frame.

         IF wh-frame:NAME = "br-digita" THEN
           ASSIGN wh-br-digita-ce0703 = wh-frame.
     
        ASSIGN wh-frame = wh-frame:NEXT-SIBLING.

    END.

   

    IF VALID-HANDLE(wh-c-estab-ini-ce0703)
    THEN DO:

        ASSIGN wh-c-estab-fim-ce0703:SCREEN-VALUE = ""
               wh-c-estab-ini-ce0703:HIDDEN       = YES
               wh-c-estab-fim-ce0703:HIDDEN       = YES
               wh-image-17-ce0703:HIDDEN          = YES
               wh-image-18-ce0703:HIDDEN          = YES.
    END.
   
   
END.

