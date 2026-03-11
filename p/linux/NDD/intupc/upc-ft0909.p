def input param p-ind-event  as char          no-undo.
def input param p-ind-object as char          no-undo.
def input param p-wgh-object as handle        no-undo.
def input param p-wgh-frame  as widget-handle no-undo.
def input param p-cod-table  as char          no-undo.
def input param p-row-table  as rowid         no-undo.

DEF NEW GLOBAL SHARED VAR h-ver-xml            AS handle        no-undo.
DEF NEW GLOBAL SHARED VAR h-browse             AS handle        no-undo.
DEF NEW GLOBAL SHARED VAR h-buffer             AS handle        no-undo.
DEF NEW GLOBAL SHARED VAR h-query              AS handle        no-undo.

/* message p-ind-event  skip                            */
/*         string(p-ind-object) skip                    */
/*         string(p-wgh-object) skip                    */
/*         string(p-wgh-frame)  skip                    */
/*         p-cod-table  skip                            */
/*         string(p-row-table)  skip view-as alert-box. */

IF p-ind-event = "AFTER-INITIALIZE" THEN
DO :    
    RUN utils/findWidget.p (INPUT  'brNfe',
                            INPUT  'browse',
                            INPUT  p-wgh-frame,
                            OUTPUT h-browse).
    
    h-query  = h-browse:QUERY.
    h-buffer = h-query:GET-BUFFER-HANDLE(1).       


    CREATE BUTTON h-ver-xml
    ASSIGN FRAME     = p-wgh-frame
           WIDTH     = 10
           LABEL     = "Ver XML"
           HEIGHT    = 1
           ROW       = 6.7
           COL       = 122
           SENSITIVE = YES
           VISIBLE   = YES.
    ON 'CHOOSE' OF h-ver-xml PERSISTENT RUN intupc\upc-ft0909a.p.
           
END.


