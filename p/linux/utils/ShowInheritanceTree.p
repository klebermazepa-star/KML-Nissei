{system/InstanceManagerDef.i}
{system/InstanceManager.i}

define variable etiqueta as handle     no-undo.
define variable espacos  as integer    no-undo.

run createInstance in ghInstanceManager(this-procedure,
    "esclass/bike/EtiquetaUnicidade.p",output etiqueta).

output to value(session:temp-dir + "inheritance.txt").
put unformatted space(espacos) "- " etiqueta:file-name "," etiqueta skip.
run showSupers(etiqueta).
output close.
dos silent value('notepad.exe "' + session:temp-dir + 'inheritance.txt"').


procedure showSupers:
    define input  parameter superProc as handle no-undo.

    define variable i as integer no-undo.    
    define variable proc as handle no-undo.

    assign espacos = espacos + 4.
    do i = 1 to num-entries(superProc:super-procedures):
        assign proc = widget-handle(entry(i,superProc:super-procedures)).
        put unformatted space(espacos) "- " proc:file-name "," proc skip.
        run showSupers(proc).
    end.
    assign espacos = espacos - 4.
end procedure.


