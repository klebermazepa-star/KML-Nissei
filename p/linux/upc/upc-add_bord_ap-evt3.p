define input param p-wgh-frame  as widget-handle no-undo.

define variable btZoomPortador as widget-handle no-undo.
define variable fcod_portador  as widget-handle no-undo.
define variable num_bord_ap    as widget-handle no-undo.

run utils/findWidget.p('bt_zoo_64301', 'button', p-wgh-frame, output btZoomPortador).
run utils/findWidget.p('fcod_portador', 'fill-in', p-wgh-frame, output fcod_portador).
run utils/findWidget.p('num_bord_ap', 'fill-in', p-wgh-frame, output num_bord_ap).

if valid-handle(btZoomPortador) and valid-handle(fcod_portador) then do:
    apply 'choose':u to btZoomPortador.
    apply 'entry':u to fcod_portador.
    num_bord_ap:screen-value = ''.
end.


