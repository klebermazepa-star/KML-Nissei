/* ex:
{c:/datasul/clientes/dtpr/utils/_viewx.i 
    &table=movto-estoq
    &where="where movto-estoq.dt-trans >= 01/01/2008"
    &fields=".dt-trans movto-estoq.nr-trans"
    &enable="enable <fields>"
    }
*/

DEFINE QUERY qry_query FOR {&table}.

DEFINE BUTTON btn_delete    LABEL 'Delete'.

DEFINE BROWSE brw_browse QUERY qry_query
    DISPLAY {&table}{&fields}
    {&enable}
        WITH 25 DOWN WIDTH 79 SEPARATORS FONT 3.

DEFINE FRAME f-frame-zoom
    brw_browse
    SKIP
    btn_delete.

OPEN QUERY qry_query
    FOR EACH {&table} {&where} NO-LOCK.

ON 'choose':U OF btn_delete
DO:

    MESSAGE 'Delete this record ?'
        VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE l-resposta AS LOGICAL.

    IF l-resposta THEN
    DO:
        FIND CURRENT {&table} EXCLUSIVE-LOCK.

        DELETE {&table}.

        OPEN QUERY qry_query
            FOR EACH {&table} {&where} NO-LOCK.

    END.

END.


ENABLE ALL WITH FRAME f-frame-zoom.

WAIT-FOR WINDOW-CLOSE OF CURRENT-WINDOW.
