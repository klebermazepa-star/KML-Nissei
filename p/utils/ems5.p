define var c-connected    as char no-undo.
define var c-disconnected as char no-undo.
    
if connected('emsuni') then do:
    disconnect emsuni.
    assign c-disconnected = 'EMSUNI'.
end.
else do:
    connect c:\datasul\database\ems204\imesul\emsuni.db no-error.
    assign c-connected = 'EMSUNI'.
end.

if connected('emsbas') then do:
    disconnect emsbas.
    assign c-disconnected = c-disconnected +
                            if c-disconnected = ''
                            then ''
                            else ', ' +
                            'EMSBAS'.
end.
else do:
    connect c:\datasul\database\ems204\imesul\emsbas.db no-error.
    assign c-connected = c-connected +
                         if c-connected = ''
                         then ''
                         else ', ' +
                         'EMSBAS'.
end.

if connected('ems505') then do:
    disconnect ems505.
    assign c-disconnected = c-disconnected +
                            if c-disconnected = ''
                            then ''
                            else ', ' +
                            'EMS505'.
end.
else do:
    connect c:\datasul\database\ems204\imesul\ems505.db no-error.
    assign c-connected = c-connected +
                         if c-connected = ''
                         then ''
                         else ', ' +
                         'EMS505'.
end.

message 'Conectados:'    if c-connected = '' then '----' else c-connected skip
        'Desconectados:' if c-disconnected = '' then '----' else c-disconnected
    view-as alert-box info title 'Bancos EMS5'.
