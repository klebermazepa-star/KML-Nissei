
/**********************************************************************
**
**  Programa: upc-cd1508a - Redu‡Æo ICMS
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


DEFINE NEW GLOBAL SHARED VAR wh-txt-reduc-pmc-cd1508a  AS WIDGET-HANDLE NO-UNDO.
DEFINE NEW GLOBAL SHARED VAR wh-reduc-pmc-cd1508a  AS WIDGET-HANDLE NO-UNDO.


/* MESSAGE p-ind-event              "p-ind-event  " skip  */
/*          p-ind-object             "p-ind-object " skip */
/*          p-wgh-object:FILE-NAME   "p-wgh-object " skip */
/*          p-wgh-frame:NAME         "p-wgh-frame  " skip */
/*          p-cod-table              "p-cod-table  " skip */
/*         string(p-row-table)      "p-row-table  " skip  */
/* VIEW-AS ALERT-BOX INFO BUTTONS OK.                     */


if  p-ind-event  = "BEFORE-DISPLAY" and
    p-ind-object = "CONTAINER"   THEN DO:

    create text wh-txt-reduc-pmc-cd1508a
    ASSIGN name         = "wh-txt-reduc-pmc-cd1508a"
           frame        = p-wgh-frame
           row          = 4.7
           format       = 'x(8)'
           col          = 69
           width        = 7.3
           screen-value = 'Red PMC:'
           visible      = yes.
    
    create FILL-IN wh-reduc-pmc-cd1508a
    ASSIGN name      = "wh-reduc-pmc-cd1508a"
           frame     = p-wgh-frame
           width     = 7
           height    = .88
           DATA-TYPE = "DECIMAL"
           column    = wh-txt-reduc-pmc-cd1508a:COL + wh-txt-reduc-pmc-cd1508a:width
           row       = wh-txt-reduc-pmc-cd1508a:ROW - 0.2
           format    = ">9.99"
           visible   = true
           sensitive = YES.


END.

if  p-ind-event  = "AFTER-DISPLAY" and
    p-ind-object = "CONTAINER"   THEN DO:

    FIND FIRST ems2dis.tb-preco NO-LOCK
        WHERE ROWID(tb-preco) = p-row-table NO-ERROR.

    IF AVAIL tb-preco THEN DO:
        IF SUBSTRING(tb-preco.char-1, 120, 5) = ""  THEN
            ASSIGN wh-reduc-pmc-cd1508a:SCREEN-VALUE = "0".
        ELSE
            ASSIGN wh-reduc-pmc-cd1508a:SCREEN-VALUE = SUBSTRING(tb-preco.char-1, 120, 6).
    END.
        

END.

if  p-ind-event  = "AFTER-ASSIGN" and
    p-ind-object = "CONTAINER"   THEN DO:

    FIND FIRST tb-preco EXCLUSIVE-LOCK
        WHERE ROWID(tb-preco) = p-row-table NO-ERROR.

    IF AVAIL tb-preco THEN 
        ASSIGN OVERLAY(tb-preco.char-1, 120, 6) = wh-reduc-pmc-cd1508a:SCREEN-VALUE .

    RELEASE tb-preco.

END.

/*


---------------------------
Informacao
---------------------------
AFTER-ASSIGN p-ind-event   
CONTAINER p-ind-object  
cdp/cd1508a.w p-wgh-object  
fpage0 p-wgh-frame   
tb-preco p-cod-table   
0x000000000047c207 p-row-table   
---------------------------
OK   
---------------------------


if  p-ind-event  = "AFTER-DISPLAY" and
    p-ind-object = "CONTAINER"   THEN DO:

    FIND FIRST tb-preco NO-LOCK
        WHERE ROWID(tb-preco) = p-row-table NO-ERROR.

    IF AVAIL tb-preco THEN
        ASSIGN wh-reduc-pmc:SCREEN-VALUE = SUBSTRING(tb-preco.char-1, 120, 6).

END.
*/
/* 

---------------------------
Informacao
---------------------------
AFTER-DISPLAY p-ind-event   
CONTAINER p-ind-object  
cdp/cd1508.r p-wgh-object  
fPage0 p-wgh-frame   
tb-preco p-cod-table   
0x000000000047c205 p-row-table   
---------------------------
OK   
---------------------------

---------------------------



---------------------------
Informacao
---------------------------
BEFORE-DISPLAY p-ind-event   
CONTAINER p-ind-object  
cdp/cd1508.w p-wgh-object  
fPage0 p-wgh-frame   
tb-preco p-cod-table   
0x000000000047c206 p-row-table   
---------------------------
OK   
---------------------------
*/
