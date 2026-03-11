define variable cProgMsg as character no-undo.
define variable cMsg     as character no-undo.
define variable cHelp    as character no-undo.
define variable cType    as character no-undo.
define variable cButtons as character no-undo.

define variable iMsg as integer   no-undo.

form
    iMsg      column-label 'Cod.' format '99999'
    cType     column-label 'Tipo' format 'x(05)'
    cButtons  column-label 'Btns' format 'x(04)'
    cMsg      column-label 'Mensagem' format 'x(70)'
    cHelp     column-label 'Ajuda'    format 'x(230)'
    with stream-io width 320 no-box down frame fMsg.

define stream stMsg.
output stream stMsg to C:\Datasul\msgs-505.txt convert target 'iso8859-1'.

do iMsg = 1 to 18999:

    message iMsg.

    assign
        cProgMsg = 'messages/'
                 + string(trunc(iMsg / 1000, 0), '99':u)
                 + "/msg"
                 + string(iMsg, '99999':u).

    if search(cProgMsg + ".r") <> ? or
       search(cProgMsg + ".p") <> ? then do:

        run value(cProgMsg + '.p':u) (input 'Msg':u, input '') no-error.
        if error-status:error then
            next.

        assign cMsg = return-value.

        run value(cProgMsg + '.p':u) (input 'Help':u, input '').
        assign cHelp = return-value.

        run value(cProgMsg + '.p':u) (input 'Type':u, input '').
        assign cType = return-value.

        run value(cProgMsg + '.p':u) (input 'Buttons':u, input '').
        assign cButtons = return-value.

        display stream stMsg
            iMsg
            cType
            cButtons
            cMsg
            cHelp
            with frame fMsg.
        down stream stMsg with frame fmsg.
    end.

end.

output stream stMsg close.

/* end  */
