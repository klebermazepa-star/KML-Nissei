/**
 * Procedure para encontrar uma procedure (viewer)
 * 
 * Parametros:  c-procedure:  nome da procedure a ser localizada
 *              p-wgh-frame:  frame do procedure (passado para a UPC), para validar, ou null
 *              h-proc:       procedure encontrado
 **/

def input param c-procedure as char no-undo.
def input param p-wgh-frame as widget-handle no-undo.
def output param h-proc     as handle no-undo.

def var h-prc as handle no-undo.
def var h-frm as widget-handle no-undo.

assign h-proc = ?
       h-prc  = session:first-procedure.

do while h-prc <> ? :

    if (index(h-prc:file-name, c-procedure) > 0) then do:
        
        assign h-frm = h-prc:current-window.

        if h-frm <> ? then do:

            h-frm = h-frm:first-child.

            if h-frm <> ? and
               (p-wgh-frame = ? or
                h-frm:parent = if p-wgh-frame:frame <> ? then
                                   p-wgh-frame:frame:parent
                               else
                                   p-wgh-frame:parent) then do:
               
                assign h-proc = h-prc.
               
                leave.
            end.
        end.
    end.
    assign h-prc = h-prc:next-sibling.
end.
