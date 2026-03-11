/********************************************************************************
** Programa: EPC-FP2200RP - EPC Cancelamento de Notas
**
** Versao : 12 - 13/01/2017 - Alessandro V Baccin
**
********************************************************************************/

/* ------------------- Parametros da DBO -------------------------*/            
{include/i-epc200.i} 
{utp/ut-glob.i}

{method/dbotterr.i}

define input        param p-ind-event  as char          no-undo.
define input-output param table for tt-epc.

define buffer btt-epc for tt-epc.
define buffer b-docum-est for docum-est.

define variable l-ok as logical no-undo.
define variable r-rowid as rowid no-undo.
define variable l-resumo-ft2200 as logical.

/* marcar pedidos para nÆo reabertura em caso de nao selecionado o parƒmetro "Rabre resumo" */
for first btt-epc where 
    btt-epc.cod-event     = "ft2200rp":U and   
    btt-epc.cod-parameter = "param":U:
    l-resumo-ft2200       = logical(btt-epc.val-parameter).
    if not l-resumo-ft2200 then
    for first tt-epc where 
        tt-epc.cod-event     = "ft2200rp":U and   
        tt-epc.cod-parameter = "nota-fiscal rowid":U:
        r-rowid = to-rowid(tt-epc.val-parameter).

        for first nota-fiscal no-lock where rowid(nota-fiscal) = r-rowid: 

            IF  nota-fiscal.cod-estabel = "973"
            AND CAN-FIND(FIRST natur-oper
                         WHERE natur-oper.nat-operacao = nota-fiscal.nat-operacao
                         AND   natur-oper.transf       = YES) THEN DO:

                RUN intupc/epc-ft2200rp-titSTAPB.p(BUFFER nota-fiscal).
            END.


            if nota-fiscal.nr-pedcli <> "" then do:
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

            /* devolu‡Æo de cupom */
            if nota-fiscal.ind-tip-nota = 8 and 
               nota-fiscal.esp-docto = 20 and 
               nota-fiscal.cod-estabel <> "973" then do:

                for first docum-est 
                    fields (cod-estabel nro-docto serie-docto nat-operacao cod-emitente) 
                    no-lock where 
                    docum-est.serie-docto  = nota-fiscal.serie and
                    docum-est.nro-docto    = nota-fiscal.nr-nota-fis and
                    docum-est.cod-emitente = nota-fiscal.cod-emitente and
                    docum-est.nat-operacao = nota-fiscal.nat-operacao: end.
                if not avail docum-est then next.
                for first estabelec fields (cgc)
                    no-lock where estabelec.cod-estabel = docum-est.cod-estabel: end.
                l-ok = no.
                for each cst_fat_devol WHERE
                         cst_fat_devol.cod_estabel  = docum-est.cod-estabel  AND
                         cst_fat_devol.serie_docto  = docum-est.serie-docto  AND
                         cst_fat_devol.nro_docto    = docum-est.nro-docto    AND
                         cst_fat_devol.cod_emitente = docum-est.cod-emitente AND 
                         cst_fat_devol.nat_operacao = docum-est.nat-operacao query-tuning(no-lookahead):
                    for each int_ds_devolucao_cupom where
                        int_ds_devolucao_cupom.numero_dev = cst_fat_devol.numero_dev and
                        int_ds_devolucao_cupom.cnpj_filial_dev = estabelec.cgc:
                        assign int_ds_devolucao_cupom.situacao = 3.
                        l-ok = yes.
                    end.
                end.
                if not l-ok then
                for first item-doc-est 
                    fields (nr-pedcli serie-comp nro-comp nro-docto serie-docto cod-emitente nat-operacao)
                    no-lock of docum-est:
                    /* nr-pedcli tem o n£mero do documento antes de alterar para o n£mero da nota emitida */ 
                    if item-doc-est.nr-pedcli <> "" 
                    then do:
                        for each cst_fat_devol where 
                            cst_fat_devol.cod_estabel = docum-est.cod-estabel   and
                            cst_fat_devol.serie_docto = item-doc-est.serie-docto and
                            cst_fat_devol.nro_docto   = item-doc-est.nr-pedcli:

                            if not can-find(first b-docum-est no-lock where
                                            b-docum-est.cod-estabel = cst_fat_devol.cod_estabel and
                                            b-docum-est.serie-docto = cst_fat_devol.serie_docto and
                                            b-docum-est.nro-docto   = cst_fat_devol.nro_docto   and
                                            b-docum-est.nro-docto  <> docum-est.nro-docto) then do:
                                for each int_ds_devolucao_cupom where
                                    int_ds_devolucao_cupom.numero_dev = cst_fat_devol.numero_dev and
                                    int_ds_devolucao_cupom.cnpj_filial_dev = estabelec.cgc:
                                    assign int_ds_devolucao_cupom.situacao = 3.                                
                                end.
                            end.
                        end.
                    end.
                    else do:
                        if item-doc-est.nro-comp <> "" then
                        for each cst_fat_devol where 
                            cst_fat_devol.cod_estabel = docum-est.cod-estabel   and
                            cst_fat_devol.serie_comp  = item-doc-est.serie-comp and
                            cst_fat_devol.nro_comp    = item-doc-est.nro-comp:

                            if not can-find(first b-docum-est no-lock where
                                            b-docum-est.cod-estabel = cst_fat_devol.cod_estabel and
                                            b-docum-est.serie-docto = cst_fat_devol.serie_docto and
                                            b-docum-est.nro-docto   = cst_fat_devol.nro_docto   and
                                            b-docum-est.nro-docto  <> docum-est.nro-docto) then do:

                                for each int_ds_devolucao_cupom where
                                    int_ds_devolucao_cupom.numero_dev = cst_fat_devol.numero_dev and
                                    int_ds_devolucao_cupom.cnpj_filial_dev = estabelec.cgc:
                                    assign int_ds_devolucao_cupom.situacao = 3.
                                end.
                            end.
                        end.
                    end.
                end. /* item-doc-est */
            end. /* if nota-fiscal.tipo-nta */
        end. /* nota fiscal */

    end. /* tt-epc */
end. /* btt-epc */


return "OK":U.

