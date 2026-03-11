define input param p-wgh-frame  as widget-handle no-undo.

define variable lote as widget-handle no-undo.
define variable lancamento as widget-handle no-undo.
define variable btVapara as widget-handle no-undo.

run utils/findWidget.p('num_lote_ctbl', 'fill-in', p-wgh-frame, output lote).
run utils/findWidget.p('num_lancto_ctbl', 'fill-in', p-wgh-frame, output lancamento).
run utils/findWidget.p('bt_ent_26767', 'button', p-wgh-frame, output btVapara).

if valid-handle(lote) and 
    valid-handle(lancamento) and 
    valid-handle(btVapara) then do:

    run cstp/csfg001.w(lote:input-value).

    apply 'choose' to btVapara.
end.
