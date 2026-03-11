define input param p-ind-event  as character     no-undo.
define input param p-ind-object as character     no-undo.
define input param p-wgh-object as handle        no-undo.
define input param p-wgh-frame  as widget-handle no-undo.
define input param p-cod-table  as character     no-undo.
define input param p-row-table  as recid         no-undo.

define variable btCancelamento as widget-handle no-undo.
define variable btRateio as widget-handle no-undo.

run utils\findWidget.p('bt_cancelamento', 'button', p-wgh-frame, output btCancelamento).
if valid-handle(btCancelamento) then do:
    run utils\findWidget.p('btRateio', 'button', p-wgh-frame, output btRateio).
    if not valid-handle(btRateio) then do:
        create button btRateio
            assign 
                frame       = btCancelamento:frame
                width       = btCancelamento:width
                height      = btCancelamento:height
                row         = btCancelamento:row
                col         = btCancelamento:col + 5
                flat-button = true
                no-focus    = true
                sensitive   = true
                visible     = true
                name        = 'btRateio'
                tooltip     = 'Rateio Itens Lan‡amento Cont bil'
                help        = 'Rateio Itens Lan‡amento Cont bil'
                triggers:
                  on choose persistent run upc/upc-bas_lancto_ctbl-evt.p(p-wgh-frame).
                end triggers.
        btRateio:load-image('image/toolbar/im-rat.bmp').
    end.
end.


