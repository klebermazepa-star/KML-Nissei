/* busca o nome abreviado do cliente, a partir do codigo ou 
   do nome abrev ou do cnpj */

define input parameter cCodNomeCnpj as character no-undo. 
define output parameter cNomeAbrev as character no-undo. 

define variable hEmitente as handle    no-undo.

if cCodNomeCnpj <> '' then do:
    run adbo/boad098.p persistent set hEmitente.

    do on error undo, leave:    
        run findNomeAbrev in hEmitente
            (input cCodNomeCnpj, output cNomeAbrev).
    end.

    delete procedure hEmitente.
end.

return cNomeAbrev.
