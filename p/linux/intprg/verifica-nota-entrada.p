{utp/ut-glob.i}
def var i-cont as integer.
def var i-atualiz as integer.
for each int-ds-nota-entrada no-lock:
    for first emitente NO-LOCK WHERE emitente.cgc = int-ds-nota-entrada.nen-cnpj-origem-s:
        for first docum-est where 
            docum-est.serie-docto = int-ds-nota-entrada.nen-serie-s and
            docum-est.nro-docto = string(int-ds-nota-entrada.nen-notafiscal-n,"9999999") and
            docum-est.cod-emitente = emitente.cod-emitente /*and 
            docum-est.dt-atualiza >= 06/09/2016*/:
                            
            /*if docum-est.cod-estabel = "973" then next.*/

            i-cont = i-cont + 1.

            if docum-est.dt-atualiza > 08/01/2016 and
              (docum-est.CE-atual or
               docum-est.cr-atual or
               docum-est.ap-atual or
               docum-est.of-atual) then do:
                i-atualiz = i-atualiz + 1.
                display docum-est.dt-atualiza 
                        docum-est.dt-trans
                        docum-est.cod-estabel 
                        docum-est.serie-docto
                        docum-est.nro-docto
                        docum-est.cod-emitente
                        docum-est.nat-operacao
                        docum-est.CE-atual
                        docum-est.cr-atual
                        docum-est.ap-atual
                        docum-est.of-atual.
            end.
            /*
            else do:
                for each item-doc-est of docum-est:
                    for each rat-lote of item-doc-est.
                        delete rat-lote.
                    end.
                    delete item-doc-est.
                end.
                for each dupli-apagar of docum-est:
                    for each dupli-imp of dupli-apagar:
                        delete dupli-imp.
                    end.
                    delete dupli-apagar.
                end.
                delete docum-est.
            end.
            */
        end.
    end.
end.
display i-cont i-atualiz.
