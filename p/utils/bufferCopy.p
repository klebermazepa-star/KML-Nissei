/* duplica os registros de um buffer para outro */

define input parameter hBufSrc as widget-handle no-undo. 
define input parameter hBufTrg as widget-handle no-undo. 
define input parameter cWhere as character no-undo. 
define input parameter lEmpty as logical   no-undo. 

define variable hQry as widget-handle no-undo.

if lEmpty then
    hBufTrg:empty-temp-table().

create query hQry.
hQry:set-buffers(hBufSrc).
hQry:query-prepare(substitute('for each &1 &2':u,
                              hBufSrc:table,
                              cWhere)).
hQry:query-open().
hQry:get-first().
do while not hQry:query-off-end:
    hBufTrg:buffer-create().
    hBufTrg:buffer-copy(hBufSrc).
    hQry:get-next().
end.
hQry:query-close().
delete object hQry.

return.
