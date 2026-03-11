/*

copia todos os arquivos do arquivo origem (v. input from)
para cPathDest, criando as pastas se necessario
o formato do arquivo origem deve ser igual ao formato do resultado
da busca no TextPad, ou seja, por ex:
C:\Datasul\clientes\imesul\MatoGrosso\src\ftp\ft0513f.p: 12
Nesse exemplo, seria criado a pasta ftp e copiado o ft0513f.p para
C:\datasul\compile\ftp
No caso de:
C:\Datasul\clientes\imesul\MatoGrosso\src\prgime\imp\populaAntecipacoes.p: 9
seria criada a pasta prgime e a imp dentro dela e entao copiado o arquivo

cSrcFolder define a pasta a partir da qual serao criadas as pastas, ou seja, eh a pasta dos especificos
ex.: P:\ems2\especificos\xxp\xxpd001.w: 14
  - para esse caso, cSrcFolder deve ser 'especificos'
*/


def var cFile as char no-undo.
def var cDest as char no-undo.

&global-define cSrcFolder 'src'

def var cPathDest as char no-undo
    init 'C:\datasul\compile\'.

def var iSrcEntry as integer no-undo.
def var iAux as integer no-undo.

input from 'c:\datasul\temp\compilar.txt'.

repeat:

    import cFile.

    assign
        cFile = entry(01, cFile, ':') + ':' + entry(02, cFile, ':')
        cDest = ''
        .

    message cFile.

/*     if iSrcEntry = 0 then do: */
        do iSrcEntry = 1 to num-entries(cFile, '\'):
            if entry(iSrcEntry, cFile, '\') = {&cSrcFolder} then
                leave.
        end.
/*     end. */

    if iSrcEntry < num-entries(cFile, '\') then do:

        do iAux = iSrcEntry + 1 to num-entries(cFile, '\') - 1:
            assign
                cDest = cDest + entry(iAux, cFile, '\') + '\'.
    
            os-command silent value('md ' + cPathDest + cDest).
        end.
    
        os-command silent value('copy ' + cFile + ' ' + cPathDest + cDest).

    end.
end.

input close.
