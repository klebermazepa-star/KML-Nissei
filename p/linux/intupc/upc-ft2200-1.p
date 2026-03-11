def new global shared var h-rs-reabre-2200 as widget-handle no-undo. 
def new global shared var h-cod-estabel-2200 as widget-handle no-undo. 
def new global shared var h-serie-2200 as widget-handle no-undo. 
def new global shared var h-nr-nota-fis-2200 as widget-handle no-undo. 
def new global shared var h-btok-2200 as widget-handle no-undo. 
def new global shared var h-btok-2200-new as widget-handle no-undo. 

define buffer b-docum-est for docum-est.

if  valid-handle (h-btok-2200) then do:
    apply "choose":u to h-btok-2200.
    if  valid-handle (h-rs-reabre-2200) and
        valid-handle (h-cod-estabel-2200) and
        valid-handle (h-serie-2200) and
        valid-handle (h-nr-nota-fis-2200) then do:
        if not h-rs-reabre-2200:input-value then 
        for first nota-fiscal 
            fields (nr-pedcli)
            no-lock where 
            nota-fiscal.cod-estabel = h-cod-estabel-2200 :screen-value and
            nota-fiscal.serie       = h-serie-2200       :screen-value and
            nota-fiscal.nr-nota-fis = h-nr-nota-fis-2200 :screen-value:

            if  nota-fiscal.nr-pedcli <> "" and (
                nota-fiscal.idi-sit-nf-eletro = 12 or
                nota-fiscal.idi-sit-nf-eletro = 13) then do:
                for first int_ds_pedido where
                    int_ds_pedido.ped_codigo_n = int64(nota-fiscal.nr-pedcli):

                    assign int_ds_pedido.situacao = 3.

                end.
                if not avail int_ds_pedido then
                for first int_ds_pedido_subs where
                    int_ds_pedido_subs.ped_codigo_n = int(nota-fiscal.nr-pedcli):

                    assign int_ds_pedido_subs.situacao = 3.

                end.
            end.

            /* deve sempre reabrir
            /* devoluá∆o */
            if nota-fiscal.ind-tip-nota = 8 and
               nota-fiscal.esp-docto = 20 then do:

                for first docum-est 
                    fields (cod-estabel nro-docto serie-docto nat-operacao cod-emitente) 
                    no-lock where 
                    docum-est.serie-docto  = nota-fiscal.serie and
                    docum-est.nro-docto    = nota-fiscal.nr-nota-fis and
                    docum-est.cod-emitente = nota-fiscal.cod-emitente and
                    docum-est.nat-operacao = nota-fiscal.nat-operacao
                    query-tuning(no-lookahead): end.
                if not avail docum-est then next.
                for first estabelec fields (cgc)
                    no-lock where estabelec.cod-estabel = docum-est.cod-estabel
                    query-tuning(no-lookahead): end.

                if nota-fiscal.cod-estabel <> "973" then do:
                    for each cst-fat-devol of docum-est
                        query-tuning(no-lookahead):
                        for each int-ds-devolucao-cupom where
                            int-ds-devolucao-cupom.numero_dev = cst-fat-devol.numero-dev and
                            int-ds-devolucao-cupom.cnpj_filial_dev = estabelec.cgc
                            query-tuning(no-lookahead):
                             /* reabrir somente se situacao de pedido for 2 - processado. 3 - marcado para n∆o reabrir no cancelamento */
                            assign int-ds-devolucao-cupom.situacao = 3.
                        end.
                    end.
                    for each item-doc-est no-lock of docum-est
                        query-tuning(no-lookahead):
                        if item-doc-est.nr-pedcli <> "" then do:
                            for each cst-fat-devol where 
                                cst-fat-devol.cod-estabel = docum-est.cod-estabel   and
                                cst-fat-devol.serie-docto = item-doc-est.serie-docto and
                                cst-fat-devol.nro-docto   = item-doc-est.nr-pedcli
                                query-tuning(no-lookahead):

                                if not can-find(first b-docum-est no-lock where
                                                b-docum-est.cod-estabel = cst-fat-devol.cod-estabel and
                                                b-docum-est.serie-docto = cst-fat-devol.serie-docto and
                                                b-docum-est.nro-docto   = cst-fat-devol.nro-docto   and
                                                b-docum-est.nro-docto  <> docum-est.nro-docto) then do:
                                    for each int-ds-devolucao-cupom where
                                        int-ds-devolucao-cupom.numero_dev = cst-fat-devol.numero-dev and
                                        int-ds-devolucao-cupom.cnpj_filial_dev = estabelec.cgc
                                        query-tuning(no-lookahead):
                                        /* reabrir somente se situacao de pedido for 2 - processado. 3 - marcado para n∆o reabrir no cancelamento */
                                        assign int-ds-devolucao-cupom.situacao = 3.
                                    end.
                                end.
                            end.
                        end.
                        else do:
                            if item-doc-est.nro-comp <> "" then
                            for each cst-fat-devol where 
                                cst-fat-devol.cod-estabel = docum-est.cod-estabel   and
                                cst-fat-devol.serie-comp  = item-doc-est.serie-comp and
                                cst-fat-devol.nro-comp    = item-doc-est.nro-comp
                                query-tuning(no-lookahead):

                                if not can-find(first b-docum-est no-lock where
                                                b-docum-est.cod-estabel = cst-fat-devol.cod-estabel and
                                                b-docum-est.serie-docto = cst-fat-devol.serie-docto and
                                                b-docum-est.nro-docto   = cst-fat-devol.nro-docto   and
                                                b-docum-est.nro-docto  <> docum-est.nro-docto) then do:

                                    for each int-ds-devolucao-cupom where
                                        int-ds-devolucao-cupom.numero_dev = cst-fat-devol.numero-dev and
                                        int-ds-devolucao-cupom.cnpj_filial_dev = estabelec.cgc
                                        query-tuning(no-lookahead):
                                        /* reabrir somente se situacao de pedido for 2 - processado. 3 - marcado para n∆o reabrir no cancelamento */
                                        assign int-ds-devolucao-cupom.situacao = 3.
                                    end.
                                end.
                            end.
                        end.
                    end. /* item-doc-est */
                end. /* cod-estabel <> "973" */
            end. /* tipo-nota = 8 */
            */
        end.

    end.
end.
return "ok".
