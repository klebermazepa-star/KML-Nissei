define temp-table tt-notas
    field nen-cnpjorigem-s as char format "x(14)"
    field nen-notafiscal-n as integer format ">>>>>>>>9"
    field nen-serie-s as char
    field nen-datamovimentacao-d as date label "Dt Movto"
    field l-achou as logical label "Localizada"
    field l-ok as logical label "Conferida"
    field l-item as logical label "Conferida"
    index chave is unique
        nen-notafiscal-n 
        nen-cnpjorigem-s 
        nen-serie-s.
define temp-table tt-entrada like int-ds-nota-entrada
    field nen-cnpjorigem-n as decimal decimals 0
    INDEX chave is unique 
                nen-cnpjorigem-n
                nen-notafiscal-n 
                nen-serie-s .


{utp/ut-glob.i}
def var raw-param as raw no-undo.
define temp-table tt-param-re1005
    field destino            as integer
    field arquivo            as char
    field usuario            as char
    field data-exec          as date
    field hora-exec          as integer
    field classifica         as integer
    field c-cod-estabel-ini  as char
    field c-cod-estabel-fim  as char
    field i-cod-emitente-ini as integer
    field i-cod-emitente-fim as integer
    field c-nro-docto-ini    as char
    field c-nro-docto-fim    as char
    field c-serie-docto-ini  as char
    field c-serie-docto-fim  as char
    field c-nat-operacao-ini as char
    field c-nat-operacao-fim as char
    field da-dt-trans-ini    as date
    field da-dt-trans-fim    as date.
define temp-table tt-digita-re1005
    field r-docum-est        as rowid.

def temp-table tt-raw-digita NO-UNDO field raw-digita  as raw.


input from t:\NFsProcessadasPRS_.csv.
repeat:
    create tt-notas.
    import delimiter ";"
        tt-notas.
end.
input close.
def var i-cont as integer.
def var i-atualiz as integer.
for each tt-notas:
    for first int-ds-nota-entrada no-lock where 
        int-ds-nota-entrada.nen-cnpj-origem-s = string(dec(tt-notas.nen-cnpjorigem-s),"99999999999999") and
        int-ds-nota-entrada.nen-notafiscal-n = tt-notas.nen-notafiscal-n and
        int-ds-nota-entrada.nen-serie-s = trim(tt-notas.nen-serie-s):

        for first emitente NO-LOCK WHERE emitente.cgc = int-ds-nota-entrada.nen-cnpj-origem-s:
            for first docum-est where 
                docum-est.serie-docto = int-ds-nota-entrada.nen-serie-s and
                docum-est.nro-docto = string(int-ds-nota-entrada.nen-notafiscal-n,"9999999") and
                docum-est.cod-emitente = emitente.cod-emitente /*and 
                docum-est.dt-atualiza >= 06/09/2016*/:
                                
                if docum-est.cod-estabel = "973" then next.

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
            end.
        end.
    end.
end.
display i-cont i-atualiz.
