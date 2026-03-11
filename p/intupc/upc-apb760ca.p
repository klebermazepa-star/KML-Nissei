define input param p-ind-event  as character     no-undo.
define input param p-ind-object as character     no-undo.
define input param p-wgh-object as handle        no-undo.
define input param p-wgh-frame  as widget-handle no-undo.
define input param p-cod-table  as character     no-undo.
define input param p-row-table  as recid         no-undo.

DEF NEW GLOBAL SHARED VAR h_g_cod_estab_bord    as widget-handle    no-undo.  
DEF NEW GLOBAL SHARED VAR h_g_cod_portador      as widget-handle    no-undo.  
DEF NEW GLOBAL SHARED VAR h_g_num_bord_ap       as widget-handle    no-undo.

DEFINE BUFFER b_bord_ap FOR bord_ap.

/* message ' p-ind-event   '  p-ind-event     skip */
/*         ' p-ind-object  '  p-ind-object    skip */
/*         ' p-wgh-object  '  p-wgh-object    skip */
/*         ' p-wgh-frame   '  p-wgh-frame     skip */
/*         ' p-cod-table   '  p-cod-table     skip */
/*         ' p-row-table   '  p-row-table     skip */
/*         ' transaction() '  transaction .        */

IF p-ind-event  = "INITIALIZE" THEN DO:
    run utils\findWidget.p('cod_estab_bord', 'fill-in', p-wgh-frame, output h_g_cod_estab_bord).
    run utils\findWidget.p('cod_portador ',  'fill-in', p-wgh-frame, output h_g_cod_portador).
    run utils\findWidget.p('num_bord_ap',    'fill-in', p-wgh-frame, output h_g_num_bord_ap).

    
    ON 'leave' OF h_g_num_bord_ap persistent run intupc\upc-apb760ca-leave.p.

END.




