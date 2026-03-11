{include/i-epc200.i1}

define input param p-ind-event as char no-undo.
define input-output param table for tt-epc.

for each tt-epc:
    message "Evento EPC:" p-ind-event skip
            "Evento tt-epc:" tt-epc.cod-event skip
            "Parƒmetro:" tt-epc.cod-parameter skip
            "Valor:" tt-epc.val-parameter
        view-as alert-box.
end.
