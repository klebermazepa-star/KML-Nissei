/* selecao de impressora para ems5 */

define variable full       as character no-undo.
define variable impressora as character no-undo.
define variable layout     as character no-undo.
define variable filePrint  as character no-undo.

if c-arquivo:screen-value in frame f-pg-imp <> '':u then do:
    assign
        full = replace(c-arquivo:screen-value in frame f-pg-imp, ':', ',').

    if num-entries(full) >= 2 then
        assign
            impressora = entry(1, full)
            layout     = entry(2, full)
            .

    if num-entries(full) >= 4 then
        assign
            filePrint = entry(3, full) + ':' + entry(4, full).
    else
    if num-entries(full) = 3 then
        assign
            filePrint = entry(3, full).
end.

run prgtec/btb/btb036zb.p
    (input-output impressora,
     input-output layout,
     input-output filePrint).

assign
    full = impressora + ':' + layout.

if filePrint <> '':u then
    assign
        full = full + ':' + filePrint.

if full <> ':' then do:
    assign
        c-arquivo = full.
    display
        c-arquivo
    with frame f-pg-imp.
end.

assign
    c-imp-old = c-arquivo.

/* end */
