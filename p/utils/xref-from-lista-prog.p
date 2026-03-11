/* gera um arquivo com o xref de todos os programas de uma lista gerada pelo TextPad
   util por exemplo para verificar quem usa determinado indice */

def var cFile as char no-undo.
def var cLinha as char no-undo.

def stream stOut.
def stream stIn.

output stream stOut to value(session:temp-directory + 'xref-lista.xrf':u).

input from 'c:\datasul\temp\xref-lista.txt'.

repeat:

    import cFile.

    assign
        cFile = entry(01, cFile, ':') + ':' + entry(02, cFile, ':').

    if entry(2, cFile, '.') begins 'i':u then
        next.

    message cFile.

    compile value(cFile) xref c:\datasul\temp\xref.txt.

    input stream stIn from c:\datasul\temp\xref.txt.

    repeat:
        import stream stIn unformatted
            cLinha.

        put stream stOut unformatted
            cLinha
            skip.
    end.

    input stream stIn close.

    put stream stOut
        skip(1).

end.

input close.

output stream stOut close.

run utils/showReport.p (session:temp-directory + 'xref-lista.xrf':u).

