DEFINE QUERY qry_query FOR {1}.

DEFINE BUTTON btn_delete    LABEL 'Delete'.

DEFINE BROWSE brw_browse QUERY qry_query
    DISPLAY {1} 
        WITH 25 DOWN WIDTH 79 SEPARATORS FONT 3.

DEFINE FRAME f-frame-zoom
    brw_browse
    SKIP
    btn_delete.

OPEN QUERY qry_query
    FOR EACH {1} NO-LOCK {2}.

ON 'choose':U OF btn_delete
DO:

    MESSAGE 'Delete this record ?'
        VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE l-resposta AS LOGICAL.

    IF l-resposta THEN
    DO:
        FIND CURRENT {1} EXCLUSIVE-LOCK.

        DELETE {1}.

        OPEN QUERY qry_query
            FOR EACH {1} NO-LOCK {2}.

    END.

END.


ENABLE ALL WITH FRAME f-frame-zoom.

WAIT-FOR WINDOW-CLOSE OF CURRENT-WINDOW.
