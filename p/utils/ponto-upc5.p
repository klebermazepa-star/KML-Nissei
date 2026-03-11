def input param p-ind-event        as char          no-undo.
def input param p-ind-object       as char          no-undo.
def input param p-wgh-object       as handle        no-undo.
def input param p-wgh-frame        as widget-handle no-undo.
def input param p-cod-table        as char          no-undo.
def input param p-row-table        as recid         no-undo.
def var c-objeto as char no-undo.

assign c-objeto = entry(num-entries(p-wgh-object:private-data, "~/"), p-wgh-object:private-data, "~/").

define variable wgh-bt-histor  as widget-handle no-undo.
define variable wgh-bt-cheques as widget-handle no-undo.

message "EVENTO" p-ind-event skip
        "OBJETO" p-ind-object skip
        "NOME OBJ" c-objeto skip
        "FRAME" p-wgh-frame skip
        "TABELA" p-cod-table skip
        "ROWID" string(p-row-table) view-as alert-box.

case p-ind-event:
    when "INITIALIZE" then do:
        run utils/findWidget.p(input "bt_historico_concil_banco",
                       input "BUTTON",
                       input p-wgh-frame,
                       output wgh-bt-histor).

        create button wgh-bt-cheques
        assign
            name   = "bt-cheques-devol"
            frame  = p-wgh-frame
            width  = wgh-bt-histor:width + 0.20
            height = wgh-bt-histor:height + 0.10
            row    = wgh-bt-histor:row - 0.05
            col    = wgh-bt-histor:col + 4.17
            label  = "Chq"
            sensitive = true
            tooltip = "Cheques Devolvidos"
            help    = "Concilia os registros selecionados como cheques devolvidos"
        triggers:
            on choose persistent run espec/cmg/upc-cmg706aa-trg.p(input p-wgh-frame).
        end.
        wgh-bt-cheques:load-image("image/im-envia.bmp").

    end.
end case.


