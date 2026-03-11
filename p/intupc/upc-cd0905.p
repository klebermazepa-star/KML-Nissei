/*******************************************************************************
**  Programa.: upc-cd0905.p	- UPC S‚rie Papafila
**  
**  Descri»’o: Cria‡Æo do campo papaFila para diferenciar cupons dessa s‚rie
*********************************************************************************/

def input param p-ind-event        as char          no-undo.
def input param p-ind-object       as char          no-undo.
def input param p-wgh-object       as handle        no-undo.
def input param p-wgh-frame        as widget-handle no-undo.
def input param p-cod-table        as char          no-undo.
def input param p-row-table        as rowid         no-undo.

DEF VAR c-char                     AS CHAR          NO-UNDO.
DEF VAR wh-objeto                  AS WIDGET-HANDLE NO-UNDO.
DEF VAR wgh-child                  AS WIDGET-HANDLE NO-UNDO.
DEF VAR h-campo                    as widget-handle no-undo. 

DEFINE NEW GLOBAL SHARED VAR wh-txt-tp-ped-papafila AS WIDGET-HANDLE NO-UNDO.
DEFINE NEW GLOBAL SHARED VAR wh-tp-ped-papafila     AS WIDGET-HANDLE NO-UNDO.
define new global shared var h-cd0905-nr-ult-fat    as handle no-undo.

.MESSAGE p-ind-event SKIP p-ind-object
    VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.

if  p-ind-event  = "INITIALIZE" AND  /* Criar campos */
    p-ind-object = "VIEWER"     THEN DO:

    RUN utils/findWidget.p (INPUT  'nr-ult-fat',   
                            INPUT  'fill-in',       
                            INPUT  p-wgh-frame,    
                            OUTPUT h-campo).
    if valid-handle (h-campo) then 
       assign h-cd0905-nr-ult-fat  = h-campo.


    create text wh-txt-tp-ped-papafila
    ASSIGN name         = "wh-txt-tp-ped-papafila"
           frame        = p-wgh-frame
           row          = h-cd0905-nr-ult-fat:ROW + 0.1
           format       = 'x(21)'
           col          = h-cd0905-nr-ult-fat:COL + 15
           width        = 15
           screen-value = 'Tipo Pedido PapaFila:'
           visible      = yes.
    
    create FILL-IN wh-tp-ped-papafila
    ASSIGN name      = "wh-tp-ped-papafila"
           frame     = p-wgh-frame
           width     = 4
           height    = .88
           column    = wh-txt-tp-ped-papafila:COL + wh-txt-tp-ped-papafila:width
           row       = wh-txt-tp-ped-papafila:ROW - 0.1
           format    = "X(2)"
           visible   = true
           sensitive = no.


END.


if  p-ind-event  = "DISPLAY" AND      /* carregar dados default */
    p-ind-object = "VIEWER"  THEN DO: 

    if valid-handle (wh-tp-ped-papafila) then
        ASSIGN wh-tp-ped-papafila:SCREEN-VALUE = "".

    for first serie no-lock
        where rowid(serie) = p-row-table:

        FIND FIRST ext_serie NO-LOCK
            WHERE ext_serie.serie = serie.serie NO-ERROR.

        IF AVAIL ext_serie THEN DO:

            if valid-handle (wh-tp-ped-papafila) then
                ASSIGN wh-tp-ped-papafila:SCREEN-VALUE = ext_serie.tp-ped-papafila.


        END.
        ELSE DO:

            if valid-handle (wh-tp-ped-papafila) then
                ASSIGN wh-tp-ped-papafila:SCREEN-VALUE = "".

        END.


    END.


END.

IF  p-ind-event  = "AFTER-ENABLE" AND  /* Habilitar campos ap¢s editar a tela */
    p-ind-object = "VIEWER" THEN DO:

    if valid-handle (wh-tp-ped-papafila) then assign wh-tp-ped-papafila:sensitive = yes.

END.

IF  p-ind-event  = "AFTER-DISABLE" AND
    p-ind-object = "VIEWER" THEN DO:
    
    if valid-handle (wh-tp-ped-papafila) then assign wh-tp-ped-papafila:sensitive = NO.

end.

IF  p-ind-event  = "ASSIGN" AND
    p-ind-object = "VIEWER" THEN DO:

    IF  wh-tp-ped-papafila:SCREEN-VALUE <> "" THEN DO:

        for first serie no-lock
            where rowid(serie) = p-row-table:
    
            FIND FIRST ext_serie EXCLUSIVE-LOCK
                WHERE  ext_serie.serie = serie.serie NO-ERROR.
    
            IF NOT AVAIL ext_serie THEN DO:
            
                CREATE ext_serie. 
                ASSIGN ext_serie.serie              = serie.serie
                       ext_serie.tp-ped-papafila    = wh-tp-ped-papafila:SCREEN-VALUE.
    
            END.
            ELSE DO:
                ASSIGN ext_serie.tp-ped-papafila    = wh-tp-ped-papafila:SCREEN-VALUE.
            END.
        END.
        RELEASE ext_serie.
    END.

END.

IF  p-ind-event = "DESTROY" THEN DO:

    if valid-handle (wh-tp-ped-papafila) then delete widget wh-tp-ped-papafila.

    IF VALID-HANDLE (wh-tp-ped-papafila) THEN wh-tp-ped-papafila:MOVE-TO-TOP().


END.

RETURN "OK".
