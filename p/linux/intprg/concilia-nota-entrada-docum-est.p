{utp/ut-glob.i}
def var i-cont as integer.
def var i-atualiz as integer.
def var i-it-docum as integer.
def var i-it-entrada as integer.
def var i-nao as integer no-undo.
def var i-docum as integer no-undo.
def var i-emit as integer no-undo.
def var i-conferida as integer no-undo.
def var i-zero as integer no-undo.
output to t:\conciliacao.txt.
define buffer b-estabelec for estabelec.
for each estabelec no-lock where estabelec.estado = "SC":
    for each int-ds-nota-entrada no-lock where 
        int-ds-nota-entrada.nen-cnpj-destino-s = estabelec.cgc and
        int-ds-nota-entrada.nen-dataemissao-d <= 08/31/2016:
        if int-ds-nota-entrada.nen-datamovimentacao-d < 08/01/2016 then next.

        IF int-ds-nota-entrada.situacao >= 2 and
           int-ds-nota-entrada.nen-conferida-n >= 1 AND 
           int-ds-nota-entrada.nen-datamovimentacao-d <> ? THEN
            i-conferida = i-conferida + 1.
        i-cont = i-cont + 1.
        for first emitente NO-LOCK WHERE emitente.cgc = int-ds-nota-entrada.nen-cnpj-origem-s: end.
        if not avail emitente then do:
            assign i-emit = i-emit + 1.
            display int-ds-nota-entrada.nen-cnpj-origem-s "Fornecedor nao cadastrado" with width 300 stream-io.
            next.
        end.
        for first docum-est where 
            docum-est.serie-docto = int-ds-nota-entrada.nen-serie-s and
            docum-est.nro-docto = trim(string(int-ds-nota-entrada.nen-notafiscal-n,">>>9999999")) and
            docum-est.cod-emitente = emitente.cod-emitente /*and 
            docum-est.dt-atualiza >= 06/09/2016*/:
            i-docum = i-docum + 1.
            /*if docum-est.cod-estabel = "973" then next.*/
            if docum-est.dt-atualiza > 08/01/2016 and
              (docum-est.CE-atual or
               docum-est.cr-atual or
               docum-est.ap-atual or
               docum-est.of-atual) then do:
                i-atualiz = i-atualiz + 1.
                /*
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
                        */
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
            i-it-docum = 0.
            for each item-doc-est no-lock of docum-est:
                assign i-it-docum = i-it-docum + item-doc-est.quantidade.
            end.
            i-it-entrada = 0.
            for each int-ds-nota-entrada-produto no-lock of int-ds-nota-entrada:
                assign i-it-entrada = i-it-entrada + int-ds-nota-entrada-produto.nep-quantidade-n.
            end.
            if i-it-docum <> i-it-entrada then do:
                display docum-est.cod-estabel 
                        docum-est.serie-docto
                        docum-est.nro-docto
                        docum-est.cod-emitente
                        docum-est.nat-operacao
                        i-it-docum
                        i-it-entrada
                    with width 300 stream-io.
            end.
        end. /*
        if not avail docum-est and int-ds-nota-entrada.nen-conferida-n = 2 then do:
            i-nao = i-nao + 1.
            display int-ds-nota-entrada.nen-cnpj-origem-s
                    int-ds-nota-entrada.nen-notafiscal-n
                    int-ds-nota-entrada.nen-serie-s
                    int-ds-nota-entrada.situacao
                    int-ds-nota-entrada.nen-conferida-n
                    int-ds-nota-entrada.nen-dataemissao-d
                    int-ds-nota-entrada.nen-datamovimentacao-d
                with width 300 stream-io.
            /*int-ds-nota-entrada.nen-conferida-n = 1.*/
        end.*/
        if not avail docum-est and int-ds-nota-entrada.situacao >= 2 and           
           int-ds-nota-entrada.nen-conferida-n >= 1 AND    
           int-ds-nota-entrada.nen-datamovimentacao-d <> ? then do:
            i-nao = i-nao + 1.

            /*
            display int-ds-nota-entrada.nen-cnpj-origem-s
                    int-ds-nota-entrada.nen-notafiscal-n
                    int-ds-nota-entrada.nen-serie-s
                    int-ds-nota-entrada.situacao
                    int-ds-nota-entrada.nen-conferida-n
                    int-ds-nota-entrada.nen-dataemissao-d
                    int-ds-nota-entrada.nen-datamovimentacao-d
                with width 300 stream-io.

            for first emitente fields (cod-emitente estado tp-desp-padrao     cod-cond-pag) no-lock where 
                emitente.cgc = int-ds-nota-entrada.nen-cnpj-origem-s: end.
            if  emitente.cod-emitente < 0 or
                emitente.cod-emitente > 999999999 then put UNFORMATTED  "emitente".
            def var c-cod-estabel as char no-undo.
            c-cod-estabel = "".
            for each b-estabelec 
                fields (cod-estabel estado cidade 
                        cep pais endereco bairro ep-codigo) 
                no-lock where
                b-estabelec.cgc = int-ds-nota-entrada.nen-cnpj-destino-s,
                first cst-estabelec no-lock where 
                cst-estabelec.cod-estabel = b-estabelec.cod-estabel and
                cst-estabelec.dt-fim-operacao >= int-ds-nota-entrada.nen-dataemissao-d:
                c-cod-estabel = b-estabelec.cod-estabel.
                leave.
            end.
            if c-cod-estabel = "" then do:
                put unformatted "b-estabelec desativado".
            end.
            if  b-estabelec.cod-estabel < "" or
                b-estabelec.cod-estabel > "zzz" then put unformatted "b-estabelecimento.".
            */
            /*
            for first int-ds-nota-entrada-produto no-lock where
                int-ds-nota-entrada-produto.nen-cnpj-origem-s = int-ds-nota-entrada.nen-cnpj-origem-s and
                int-ds-nota-entrada-produto.nen-serie-s       = int-ds-nota-entrada.nen-serie-s       and
                int-ds-nota-entrada-produto.nen-notafiscal-n  = int-ds-nota-entrada.nen-notafiscal-n:
            end.

            if not avail int-ds-nota-entrada-produto then put UNFORMATTED 'protudos'.
            */
            for first int-ds-nota-entrada-produto no-lock of int-ds-nota-entrada where
                int-ds-nota-entrada-produto.nep-produto-n = 0:
                assign i-zero = i-zero + 1.
            end.
            /*int-ds-nota-entrada.nen-conferida-n = 1.*/
        end.
    end.
end.
display i-cont      LABEL "Notas Integracao"
        i-conferida LABEL "Conferidas"
        i-docum     LABEL "Importadas RE1001"
        i-atualiz   LABEL "Atualizadas Estoque"
        i-nao       LABEL "Faltantes"
        i-emit      LABEL "Fornecedor NAO Cadastrado"
        i-zero      LABEL "Item Zero"
    WITH  STREAM-IO down width 300.
output close.
