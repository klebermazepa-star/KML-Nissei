/**
 * Procedure para encontrar o frame principal (container) de uma procedure (viewer)
 * 
 * Parametros:  c-procedure:  nome da procedure a ser localizada
 *              p-wgh-frame:  frame do procedure (passado para a UPC), ou null
 *              h-frame:      frme encontrado
 **/

def input param c-procedure as char no-undo.
def input param p-wgh-frame as widget-handle no-undo.
def output param h-frame    as widget-handle no-undo.

def var h-proc as handle no-undo.
def var h-frm  as widget-handle no-undo.

assign h-frame = ?
       h-proc = session:first-procedure.

do while h-proc <> ? :

    if (index(h-proc:file-name, c-procedure) > 0) then do:
        
        assign h-frm = h-proc:current-window.

        if h-frm <> ? then do:

            h-frm = h-frm:first-child.

            if h-frm <> ? and
               (p-wgh-frame = ? or
                h-frm:parent = p-wgh-frame:frame:parent) then do:
               
                assign h-frame = h-frm.
               
                leave.
            end.
        end.
    end.
    assign h-proc = h-proc:next-sibling.
end.
