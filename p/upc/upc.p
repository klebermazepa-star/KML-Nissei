/*
*/

{include/i-prgvrs.i FT0918-UPC 1.00.00.000}

DEF INPUT PARAM p-ind-event        AS CHAR          NO-UNDO.
DEF INPUT PARAM p-ind-object       AS CHAR          NO-UNDO.
DEF INPUT PARAM p-wgh-object       AS HANDLE        NO-UNDO.
DEF INPUT PARAM p-wgh-frame        AS WIDGET-HANDLE NO-UNDO.
DEF INPUT PARAM p-cod-table        AS CHAR          NO-UNDO.
DEF INPUT PARAM p-row-table        AS ROWID         NO-UNDO.

/*Joga os Eventos em arquivo*/
{upc/events-upc.i "C:\temp\eventos.txt"}

RETURN "OK":U .

/*
ASSIGN h-btIncluir:VISIBLE = FALSE .
ASSIGN h-btIncluir:SENSITIVE = FALSE .

CREATE BUTTON h-btIncluir-new ASSIGN
    NAME    = "btIncluir-UPC"
    ROW     = h-btIncluir:ROW
    COL     = h-btIncluir:COL
    WIDTH   = h-btIncluir:WIDTH
    HEIGHT  = h-btIncluir:HEIGHT
    LABEL   = h-btIncluir:LABEL
TRIGGERS:
ON CHOOSE PERSISTENT RUN upc/ft0918-evt.w .
END TRIGGERS.
*/
