/**********************************************************************
**
**  Programa: upc-cd1508 - Redu‡Æo ICMS
**              
**  Objetivo: Criar o campo Redu‡Æo ICMS
**
**  20/09/2022 - Mazepa: Criar o campo Redu‡Æo ICMS
**********************************************************************/

DEFINE INPUT PARAMETER p-ind-event  AS CHARACTER.
DEFINE INPUT PARAMETER p-ind-object AS CHARACTER.
DEFINE INPUT PARAMETER p-wgh-object AS HANDLE.
DEFINE INPUT PARAMETER p-wgh-frame  AS WIDGET-HANDLE.
DEFINE INPUT PARAMETER p-cod-table  AS CHARACTER.
DEFINE INPUT PARAMETER p-row-table  AS ROWID.


DEFINE NEW GLOBAL SHARED VAR wh-txt-reduc-pmc  AS WIDGET-HANDLE NO-UNDO.
DEFINE NEW GLOBAL SHARED VAR wh-reduc-pmc  AS WIDGET-HANDLE NO-UNDO.


/* MESSAGE p-ind-event              "p-ind-event  " skip  */
/*          p-ind-object             "p-ind-object " skip */
/*          p-wgh-object:FILE-NAME   "p-wgh-object " skip */
/*          p-wgh-frame:NAME         "p-wgh-frame  " skip */
/*          p-cod-table              "p-cod-table  " skip */
/*         string(p-row-table)      "p-row-table  " skip  */
/* VIEW-AS ALERT-BOX INFO BUTTONS OK.                     */


if  p-ind-event  = "BEFORE-DISPLAY" and
    p-ind-object = "CONTAINER"   THEN DO:

    create text wh-txt-reduc-pmc
    ASSIGN name         = "wh-txt-reduc-pmc"
           frame        = p-wgh-frame
           row          = 4.2
           format       = 'x(8)'
           col          = 70
           width        = 7.3
           screen-value = 'Red PMC:'
           visible      = yes.
    
    create FILL-IN wh-reduc-pmc
    ASSIGN name      = "wh-reduc-pmc"
           frame     = p-wgh-frame
           width     = 7
           height    = .88
           DATA-TYPE = "DECIMAL"
           column    = wh-txt-reduc-pmc:COL + wh-txt-reduc-pmc:width
           row       = wh-txt-reduc-pmc:ROW - 0.2
           format    = ">9.99"
           visible   = true
           sensitive = no.


END.


if  p-ind-event  = "AFTER-DISPLAY" and
    p-ind-object = "CONTAINER"   THEN DO:

    FIND FIRST ems2dis.tb-preco NO-LOCK
        WHERE ROWID(tb-preco) = p-row-table NO-ERROR.

    IF AVAIL tb-preco THEN
        ASSIGN wh-reduc-pmc:SCREEN-VALUE = SUBSTRING(tb-preco.char-1, 120, 6).

END.
