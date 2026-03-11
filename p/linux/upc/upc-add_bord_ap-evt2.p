define input param p-wgh-frame  as widget-handle no-undo.

define variable cod_portador as widget-handle no-undo.
define variable fcod_portador as widget-handle no-undo.

run utils/findWidget.p('cod_portador', 'fill-in', p-wgh-frame, output cod_portador).
run utils/findWidget.p('fcod_portador', 'fill-in', p-wgh-frame, output fcod_portador).

if valid-handle(fcod_portador) and valid-handle(cod_portador) then do:
    fcod_portador:screen-value = cod_portador:screen-value.
end.





