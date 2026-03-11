define input param p-ind-event  as character     no-undo.
define input param p-ind-object as character     no-undo.
define input param p-wgh-object as handle        no-undo.
define input param p-wgh-frame  as widget-handle no-undo.
define input param p-cod-table  as character     no-undo.
define input param p-row-table  as recid         no-undo.

define variable codPortador     as widget-handle no-undo.
define variable fcod_portador   as widget-handle no-undo.
define variable btZoomPortador  as widget-handle no-undo.
define variable fbtZoomPortador as widget-handle no-undo.

DEFINE VARIABLE h_log_bord_ap_escrit        AS WIDGET-HANDLE NO-UNDO.
DEFINE VARIABLE h_log_bord_ap_desc_dist     AS WIDGET-HANDLE NO-UNDO.
DEFINE VARIABLE h_val_tot_lote_pagto_efetd  AS WIDGET-HANDLE NO-UNDO.
DEFINE VARIABLE h_val_desconto              AS WIDGET-HANDLE NO-UNDO.
DEFINE VARIABLE h_lb_val_desconto           AS WIDGET-HANDLE NO-UNDO.

DEFINE BUFFER b_bord_ap FOR bord_ap.

/* message ' p-ind-event   '  p-ind-event     skip */
/*         ' p-ind-object  '  p-ind-object    skip */
/*         ' p-wgh-object  '  p-wgh-object    skip */
/*         ' p-wgh-frame   '  p-wgh-frame     skip */
/*         ' p-cod-table   '  p-cod-table     skip */
/*         ' p-row-table   '  p-row-table     skip */
/*         ' transaction() '  transaction .        */
