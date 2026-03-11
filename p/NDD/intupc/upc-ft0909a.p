DEF NEW GLOBAL SHARED VAR h-ver-xml            AS handle        no-undo.
DEF NEW GLOBAL SHARED VAR h-browse             AS handle        no-undo.
DEF NEW GLOBAL SHARED VAR h-buffer             AS handle        no-undo.
DEF NEW GLOBAL SHARED VAR h-query              AS handle        no-undo.

def var cFile as character.

FOR EACH int_ndd_envio
     WHERE int_ndd_envio.cod_estabel = trim(h-buffer:buffer-field(1):buffer-value)
       AND int_ndd_envio.serie       = trim(h-buffer:buffer-field(2):buffer-value)
       AND int_ndd_envio.nr_nota_fis = trim(h-buffer:buffer-field(3):buffer-value) 
    NO-LOCK BY ID DESC:
    cFile = "C:\temp\int_ndd_envio.cod-estabel" + "-" + int_ndd_envio.serie + "-" + int_ndd_envio.nr_nota_fis  + ".XML".
    copy-lob int_ndd_envio.DOCUMENTDATA to file cFile.
    RUN utils\winopen.p (cFile,3).
    LEAVE.
END.





