/******************************************************************************************
**  Programa: epc-bodi601.p
**   
**  Objetivo: Eliminar funá∆o tss na inclus∆o da CCe  
******************************************************************************************/      
def input param p-ind-event           as char          no-undo.
def input param p-ind-object          as char          no-undo.
def input param p-wgh-object          as handle        no-undo.
def input param p-wgh-frame           as widget-handle no-undo.
def input param p-cod-table           as char          no-undo.
def input param p-row-table           as rowid         no-undo.

DEF VAR c-char                     AS CHAR          NO-UNDO.
DEF VAR wh-objeto                  AS WIDGET-HANDLE NO-UNDO.
DEF VAR wgh-child                  AS WIDGET-HANDLE NO-UNDO.

DEF NEW GLOBAL SHARED VAR wh-frame             AS WIDGET-HANDLE no-undo.
DEF NEW GLOBAL SHARED VAR h-buffer             AS HANDLE        no-undo.
DEF NEW GLOBAL SHARED VAR c-valor-nfe          AS CHAR        no-undo.
DEF NEW GLOBAL SHARED VAR wh-texto-carta       AS WIDGET-HANDLE NO-UNDO.
DEF NEW GLOBAL SHARED VAR wh-btOK              AS WIDGET-HANDLE NO-UNDO.
DEF NEW GLOBAL SHARED VAR wh-btOKNew           AS WIDGET-HANDLE NO-UNDO.

IF p-ind-event = "BEFORE-DESTROY-INTERFACE" AND c-valor-nfe <> "" THEN DO:
    FOR FIRST param-gener EXCLUSIVE-LOCK
        WHERE param-gener.cod-param = "NF-e"
          AND param-gener.cod-chave-2 = h-buffer:buffer-field(1):buffer-value:
        ASSIGN param-gener.cod-valor = c-valor-nfe.
    END.
    RELEASE param-gener.
END.

IF p-ind-event = "BEFORE-INITIALIZE" THEN DO: 
    FOR FIRST param-gener EXCLUSIVE-LOCK
        WHERE param-gener.cod-param = "NF-e"
          AND param-gener.cod-chave-2 = h-buffer:buffer-field(1):buffer-value:
        ASSIGN c-valor-nfe = param-gener.cod-valor
               param-gener.cod-valor = "1".
    END.
    RELEASE param-gener.
    
    ASSIGN wh-frame = p-wgh-frame:FIRST-CHILD
           wh-frame = wh-frame:FIRST-CHILD. 
 
    DO WHILE VALID-HANDLE(wh-frame):
       IF wh-frame:NAME = "c-texto-carta" THEN
          ASSIGN wh-texto-carta = wh-frame.

       IF wh-frame:NAME = "btOk" THEN
          ASSIGN wh-btOk = wh-frame.
               
       ASSIGN wh-frame = wh-frame:NEXT-SIBLING.

    END.

    IF VALID-HANDLE(wh-btOK) THEN DO:
        CREATE BUTTON wh-btOKNew                                       
        ASSIGN FRAME     = wh-btOk:FRAME                        
               LABEL     = wh-btOk:LABEL                        
               FONT      = wh-btOk:FONT
               WIDTH     = wh-btOk:WIDTH 
               HEIGHT    = wh-btOk:HEIGHT
               ROW       = wh-btOk:ROW
               COL       = wh-btOk:COL
               FGCOLOR   = ?
               BGCOLOR   = ?
               TOOLTIP   = wh-btOk:TOOLTIP
               VISIBLE   = YES                                       
               SENSITIVE = YES
               TRIGGERS:
                ON 'choose' PERSISTENT RUN intupc\upc-ft0909f1.p(INPUT "eventobtOk",
                                                                 INPUT p-ind-object,
                                                                 INPUT p-wgh-object,
                                                                 INPUT p-wgh-frame ,
                                                                 INPUT p-cod-table ,
                                                                 INPUT p-row-table ).
               END TRIGGERS.

                
        wh-btOkNew:MOVE-TO-TOP().
    END.

END.

IF p-ind-event = "eventobtok" THEN DO:
    IF index(wh-texto-carta:SCREEN-VALUE, "  ") > 0  THEN DO:
        RUN utp/ut-msgs.p (INPUT "show",
                           INPUT 17006,
                           INPUT "Texto carta de Correá∆o n∆o deve conter espaáos desnecess†rios.").
        RETURN "NOK".
    END.

    IF index(wh-texto-carta:SCREEN-VALUE, CHR(10)) > 0 OR
       index(wh-texto-carta:SCREEN-VALUE, CHR(13)) > 0 THEN DO:
        RUN utp/ut-msgs.p (INPUT "show",
                           INPUT 17006,
                           INPUT "Texto carta de Correá∆o n∆o deve conter pulos de linha.").
        RETURN "NOK".
    END.

    IF index(wh-texto-carta:SCREEN-VALUE, "<") > 0 OR
       index(wh-texto-carta:SCREEN-VALUE, ">") > 0 OR
       index(wh-texto-carta:SCREEN-VALUE, "&") > 0 OR
       index(wh-texto-carta:SCREEN-VALUE, '"') > 0 OR
       index(wh-texto-carta:SCREEN-VALUE, "'") > 0  THEN DO:
        RUN utp/ut-msgs.p (INPUT "show",
                           INPUT 17006,
                           INPUT "Texto carta de Correá∆o n∆o deve conter caracteres especiais.").
        RETURN "NOK".
    END.

    {include/i-freeac.i}

    ASSIGN wh-texto-carta:SCREEN-VALUE = fn-free-accent(wh-texto-carta:SCREEN-VALUE).

    apply "choose" to wh-btOk.
END.

RETURN "OK".
     
