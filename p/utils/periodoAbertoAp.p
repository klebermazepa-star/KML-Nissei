define output parameter dataInicio as date      no-undo.
define output parameter dataFinal as date      no-undo.

define new global shared var i-ep-codigo-usuario as CHAR no-undo.

assign
    dataInicio = 01/01/0001
    dataFinal  = dataInicio.

for first mg.empresa
    where empresa.ep-codigo = i-ep-codigo-usuario
    no-lock
    ,
    first param-ap
    where param-ap.ep-codigo = empresa.ep-codigo
    no-lock:

    assign
        dataInicio = max(empresa.data-inicio, param-ap.dt-ult-fec)
        dataFinal  = empresa.data-fim.
end.
