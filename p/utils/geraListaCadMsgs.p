{utils/fn-unWrap.i}

OUTPUT TO C:\Datasul\msgs-204.txt CONVERT TARGET 'iso8859-1'.
    
FOR EACH cad-msgs no-lock:

    DISP cad-msgs.cd-msg cd-msg-subs texto-msg tipo-msg
         
        fn-unwrap(help-msg) FORMAT 'x(200)'

        WITH STREAM-IO WIDTH 300 NO-BOX NO-LABEL.

END.

OUTPUT CLOSE.
