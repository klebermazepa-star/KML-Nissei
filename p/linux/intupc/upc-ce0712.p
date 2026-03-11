/***************************************************************************************
**  Autor....: ResultPro
**  Cliente..: Nissei
**  Programa.: upc-ce0712.p
**  
**  Objetivo: Criar filtro por estabelecimento 
***************************************************************************************/
DEF INPUT PARAM p-ind-event      AS   CHAR              NO-UNDO.
DEF INPUT PARAM p-ind-object     AS   CHAR              NO-UNDO.
DEF INPUT PARAM p-wgh-object     AS   HANDLE            NO-UNDO.
DEF INPUT PARAM p-wgh-frame      AS   WIDGET-HANDLE     NO-UNDO.
DEF INPUT PARAM p-cod-table      AS   CHAR              NO-UNDO.
DEF INPUT PARAM p-row-table      AS   ROWID             NO-UNDO.

/*   MESSAGE p-ind-event              "p-ind-event  " skip */
/*          p-ind-object             "p-ind-object " skip  */
/*          p-wgh-object:FILE-NAME   "p-wgh-object " skip  */
/*          p-wgh-frame:NAME         "p-wgh-frame  " skip  */
/*          p-cod-table              "p-cod-table  " skip  */
/*         string(p-row-table)      "p-row-table  " skip   */
/*  VIEW-AS ALERT-BOX INFO BUTTONS OK.                     */
 
DEFINE NEW GLOBAL SHARED VAR wh-frame               AS WIDGET-HANDLE NO-UNDO.
DEFINE NEW GLOBAL SHARED VAR wh-object-frame        AS WIDGET-HANDLE NO-UNDO.
DEFINE NEW GLOBAL SHARED VAR wh-btgoto-orig         AS WIDGET-HANDLE no-undo.
DEFINE NEW GLOBAL SHARED VAR wh-btgoto-ce0712       AS WIDGET-HANDLE no-undo.
DEFINE NEW GLOBAL SHARED VAR wh-tela-ce0712         AS WIDGET-HANDLE no-undo.
DEFINE NEW GLOBAL SHARED VAR wh-dt-saldo-ce0712     AS WIDGET-HANDLE no-undo.
DEFINE NEW GLOBAL SHARED VAR wh-cod-estabel-ce0712  AS WIDGET-HANDLE no-undo.
DEFINE NEW GLOBAL SHARED VAR wh-txt-estab-ce0712    AS WIDGET-HANDLE NO-UNDO.
DEFINE NEW GLOBAL SHARED VAR c-cod-estabel-ce0712   LIKE inventario.cod-estabel NO-UNDO.

{utp/ut-glob.i}

IF p-ind-event  = "After-display" AND
   p-ind-object = "container"     AND 
   VALID-HANDLE(wh-cod-estabel-ce0712)  
THEN DO:
  FIND FIRST inventario NO-LOCK WHERE
             rowid(inventario) = p-row-table NO-ERROR.
  IF AVAIL inventario THEN DO:

     IF wh-cod-estabel-ce0712:SCREEN-VALUE = "" 
     THEN DO:

        ASSIGN wh-cod-estabel-ce0712:SCREEN-VALUE = inventario.cod-estabel.

        run setFaixas in p-wgh-object (input "",
                                       input "ZZZZZZZZZZZZZZZZ",
                                       input 0,
                                       input 99,
                                       input "",
                                       input "ZZZZZZZZ",
                                       input "",
                                       input "ZZZZZZZZ",
                                       input "",
                                       input "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ",
                                       input "",
                                       input "ZZZZZZZZZZZZZZZZZZZZ",
                                       input "",
                                       input "ZZZ",
                                       input wh-cod-estabel-ce0712:SCREEN-VALUE,
                                       input wh-cod-estabel-ce0712:SCREEN-VALUE,
                                       input 0,
                                       input 9999999).

        run piAtualizaBrowse IN p-wgh-object.

     END.
        
  END.
 
END.
    
IF p-ind-event  = "before-initialize" AND
   p-ind-object = "container"
THEN DO:
        
      ASSIGN wh-frame  = p-wgh-frame:FIRST-CHILD
             wh-frame  = wh-frame:FIRST-CHILD.

      DO WHILE VALID-HANDLE(wh-frame):

        IF wh-frame:NAME = "dt-saldo" THEN
           ASSIGN wh-dt-saldo-ce0712 = wh-frame.
     
        ASSIGN wh-frame = wh-frame:NEXT-SIBLING.

      END.

      CREATE TEXT wh-txt-estab-ce0712
        ASSIGN FRAME        = wh-dt-saldo-ce0712:FRAME
               FORMAT       = "x(6)"   
               WIDTH        = 7
               SCREEN-VALUE = "Estab:"
               ROW          = wh-dt-saldo-ce0712:ROW + 0.3
               COL          = wh-dt-saldo-ce0712:COL + 15
               VISIBLE      = YES.
           
        create fill-in wh-cod-estabel-ce0712
        assign frame              = wh-dt-saldo-ce0712:FRAME 
               font               = wh-dt-saldo-ce0712:FONT
               data-type          = "character"
               format             = "x(03)"
               row                = wh-dt-saldo-ce0712:ROW
               col                = wh-dt-saldo-ce0712:COL + 20
               height             = wh-dt-saldo-ce0712:HEIGHT
               bgcolor            = wh-dt-saldo-ce0712:BGCOLOR
               visible            = wh-dt-saldo-ce0712:VISIBLE
               sensitive          = wh-dt-saldo-ce0712:SENSITIVE
               screen-value       = "".


END.

IF p-ind-event  = "after-initialize" AND
   p-ind-object = "container"
THEN DO:

    ASSIGN wh-frame  = p-wgh-frame:FIRST-CHILD
           wh-frame  = wh-frame:FIRST-CHILD.

    DO WHILE VALID-HANDLE(wh-frame):

        IF wh-frame:NAME = "btGoTo" THEN
           ASSIGN wh-btgoto-orig = wh-frame.

        IF wh-frame:NAME = "dt-saldo" THEN
           ASSIGN wh-dt-saldo-ce0712 = wh-frame.

     
        ASSIGN wh-frame = wh-frame:NEXT-SIBLING.

    END.

    IF VALID-HANDLE (wh-btgoto-orig)
    THEN DO:
        ASSIGN  wh-tela-ce0712 = p-wgh-object.
                
        CREATE BUTTON wh-btgoto-ce0712
        ASSIGN FRAME     = wh-btgoto-orig:FRAME
               LABEL     = wh-btgoto-orig:LABEL
               FONT      = wh-btgoto-orig:FONT
               WIDTH     = wh-btgoto-orig:WIDTH
               HEIGHT    = wh-btgoto-orig:HEIGHT
               ROW       = wh-btgoto-orig:ROW
               COL       = wh-btgoto-orig:COL 
               FGCOLOR   = wh-btgoto-orig:FGCOLOR
               BGCOLOR   = wh-btgoto-orig:BGCOLOR
               TOOLTIP   = wh-btgoto-orig:TOOLTIP 
               VISIBLE   = wh-btgoto-orig:VISIBLE
               SENSITIVE = YES
               TRIGGERS:
                   ON CHOOSE PERSISTENT RUN intupc/upc-ce0712-a.p.
               END TRIGGERS.
               
               wh-btgoto-ce0712:load-image("image\toolbar\im-enter.bmp").
               wh-btgoto-ce0712:LOAD-IMAGE-INSENSITIVE("image\toolbar\ii-enter.bmp").

               wh-btgoto-ce0712:MOVE-TO-TOP().

      
        
    END.
END.

