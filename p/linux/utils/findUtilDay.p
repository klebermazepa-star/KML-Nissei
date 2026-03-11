define input parameter estab as character no-undo. 
define input-output parameter base as date      no-undo.

{system/Error.i}

define new shared variable i-ep-codigo-usuario as CHAR no-undo.

find first param-global
    no-lock no-error.

do while true
    {&throws}:

    for first calen-coml fields (calen-coml.tipo-dia calen-coml.data)
        where calen-coml.ep-codigo   = i-ep-codigo-usuario
          and calen-coml.cod-estabel = estab
          and calen-coml.data        = base
          and calen-coml.tipo-dia   <> 1
        no-lock
        {&throws}:
    end.
    
    if avail calen-coml then do:

        if avail param-global and
           ((calen-coml.tipo-dia = 3 /* Feriado */      and param-global.ind-venc-fer = 3) or
            (weekday(calen-coml.data) = 7 /* Sabado */  and param-global.ind-venc-sab = 3) or
            (weekday(calen-coml.data) = 1 /* Domingo */ and param-global.ind-venc-dom = 3)   ) then
            leave.
        else
        if avail param-global and
           ((calen-coml.tipo-dia = 3 /* Feriado */      and param-global.ind-venc-fer = 1) or
            (weekday(calen-coml.data) = 7 /* Sabado */  and param-global.ind-venc-sab = 1) or
            (weekday(calen-coml.data) = 1 /* Domingo */ and param-global.ind-venc-dom = 1)   ) then
            assign
                base = base - 1.
        else
            assign
                base = base + 1.
    end.
    else
        leave.
end.

return.
