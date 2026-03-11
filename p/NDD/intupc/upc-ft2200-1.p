{int\wsinventti0000.i}
def new global shared var h-rs-reabre-2200 as widget-handle no-undo. 
def new global shared var h-cod-estabel-2200 as widget-handle no-undo. 
def new global shared var h-serie-2200 as widget-handle no-undo. 
def new global shared var h-nr-nota-fis-2200 as widget-handle no-undo. 
def new global shared var h-btok-2200 as widget-handle no-undo. 
def new global shared var h-btok-2200-new as widget-handle no-undo. 
def new global shared var h-ft2200-desc-cancela as widget-handle no-undo.
DEFINE NEW GLOBAL SHARED VARIABLE ft0909-cancelar   AS LOGICAL NO-UNDO.
DEFINE NEW GLOBAL SHARED VARIABLE ft0909-inutilizar AS LOGICAL NO-UNDO.
DEF VAR c-motivo AS CHAR NO-UNDO.
DEF VAR i-opcao AS INT NO-UNDO.
DEFINE NEW GLOBAL SHARED VARIABLE gc-NFe-nfs-a-cancelar   AS CHAR NO-UNDO.
DEFINE NEW GLOBAL SHARED VARIABLE gc-NFe-nfs-a-inutilizar AS CHAR NO-UNDO.

{utp/ut-glob.i}
{include/i-epc200.i bodi135cancel}


DEF  VAR c-xml AS LONGCHAR NO-UNDO.
DEF var c-url                AS CHAR     NO-UNDO.

define buffer b-docum-est for docum-est.

if  valid-handle (h-btok-2200) then do:
    apply "choose":u to h-btok-2200.
    if  valid-handle (h-cod-estabel-2200) and
        valid-handle (h-serie-2200) and
        valid-handle (h-nr-nota-fis-2200) then do:

        for first nota-fiscal 
            where nota-fiscal.cod-estabel = h-cod-estabel-2200:screen-value 
            and   nota-fiscal.serie       = h-serie-2200:screen-value 
            and   nota-fiscal.nr-nota-fis = h-nr-nota-fis-2200:screen-value
            no-lock:

            FIND FIRST es-param-integracao-estab
                 WHERE es-param-integracao-estab.cod-estabel =  nota-fiscal.cod-estabel 
                 AND   es-param-integracao-estab.empresa-integracao = 2
                 NO-LOCK NO-ERROR.

            IF AVAIL es-param-integracao-estab THEN do:

               //   mESSAGE 'ft0909-inutilizar ' ft0909-inutilizar VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
               ASSIGN i-opcao = IF ft0909-inutilizar = YES THEN 3 ELSE 1.
                      c-motivo = trim(nota-fiscal.desc-cancela).

                IF VALID-HANDLE(h-ft2200-desc-cancela) THEN
                   c-motivo = trim(h-ft2200-desc-cancela:SCREEN-VALUE).
               
               RUN int\wsinventti0003.p  (input nota-fiscal.cod-estabel,
                                          input nota-fiscal.serie,      
                                          input nota-fiscal.nr-nota-fis,
                                          INPUT c-motivo,
                                          INPUT 110111,
                                          INPUT i-opcao, 
                                          OUTPUT c-xml).
               
               //MESSAGE STRING(c-xml) VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
               IF c-xml <> "" THEN do:
               
                  FIND FIRST esp_integracao 
                       WHERE  esp_integracao.id_integracao = 1
                       NO-ERROR.
                  
                  IF ft0909-inutilizar = NO THEN
                      FIND FIRST esp_servico_integracao
                           WHERE esp_servico_integracao.id_integracao = esp_integracao.id_integracao
                           AND  esp_servico_integracao.descricao = "CANCELAMENTO NFe"
                           NO-LOCK NO-ERROR.
                  ELSE 
                     FIND FIRST esp_servico_integracao
                          WHERE esp_servico_integracao.id_integracao = esp_integracao.id_integracao
                          AND  esp_servico_integracao.descricao = "INUTILIZACAO NFe"
                          NO-LOCK NO-ERROR.
               
                     
                  ASSIGN c-url = trim(esp_integracao.URL) + trim(esp_servico_integracao.servico) .

                  //MESSAGE c-url VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
                  
                  RUN int\wsinventti0001.p  (INPUT  c-url, 
                                             INPUT  c-xml,
                                             OUTPUT v-retonro-integracao).
                  
                  IF string(v-retonro-integracao) <> "" THEN do:
                     RUN int\wsinventti0005.p  (INPUT v-retonro-integracao, 
                                                ROWID(nota-fiscal)).
                  END.
               
                  RUN int\wsinventti0004.p  (input nota-fiscal.cod-estabel,
                                             input nota-fiscal.serie,      
                                             input nota-fiscal.nr-nota-fis).
                 
               END. //c-xml <> ""
            END. //AVAIL es-param-integracao-estab
               
            /*j† estava na nota*/
            IF valid-handle (h-rs-reabre-2200) THEN DO:
               if not h-rs-reabre-2200:input-value THEN
                 if  nota-fiscal.nr-pedcli <> "" and (
                     nota-fiscal.idi-sit-nf-eletro = 12 or
                     nota-fiscal.idi-sit-nf-eletro = 13)then do:
                 
                     for first int_ds_pedido 
                         WHERE int_ds_pedido.ped_codigo_n = int64(nota-fiscal.nr-pedcli):
                 
                         assign int_ds_pedido.situacao = 3.
                     end.
                     if not avail int_ds_pedido then
                       for first int_ds_pedido_subs where
                           int_ds_pedido_subs.ped_codigo_n = int(nota-fiscal.nr-pedcli):
                       
                           assign int_ds_pedido_subs.situacao = 3.
                       
                       end.
                    
                 end.
            END.
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

            PAUSE 1.
            RUN int\wsinventti0004.p  (input nota-fiscal.cod-estabel,
                                       input nota-fiscal.serie,      
                                       input nota-fiscal.nr-nota-fis).
        end.

    end.
end.
return "ok".
