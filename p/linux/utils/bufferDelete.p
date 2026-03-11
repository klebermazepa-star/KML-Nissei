/* deleta registros de um buffer handle */

define input parameter hBuf as widget-handle no-undo. 
define input parameter cWhere as character no-undo. 

define variable hQry as widget-handle no-undo.

create query hQry.
hQry:set-buffers(hBuf).
hQry:query-prepare(substitute('for each &1 &2':u,
                              hBuf:table,
                              cWhere)).
hQry:query-open().
hQry:get-first().
do while not hQry:query-off-end:
    hBuf:buffer-delete().
    hQry:get-next().
end.
hQry:query-close().
delete object hQry.

return.
