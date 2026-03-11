/***********************************************************************************************
**  Programa: upc-re1001-b.p
**  
**  Objetivo: Carregar os impostos Ö partir das tabelas int_ds_docto_xml / int_ds_it_docto_xml
***********************************************************************************************/

DEF NEW GLOBAL SHARED VAR r-row-table-imposto-re1001 AS ROWID NO-UNDO.

RUN utp/ut-msgs.p (INPUT "SHOW",
                   INPUT 27100,
                   INPUT "Confirma a carga dos Impostos?").
IF RETURN-VALUE = "yes" THEN DO:
   FIND FIRST docum-est WHERE 
              ROWID(docum-est) = r-row-table-imposto-re1001 NO-ERROR. 
   IF AVAIL docum-est THEN DO:
      FOR FIRST int_ds_docto_xml WHERE
                int_ds_docto_xml.serie        = docum-est.serie-docto    AND
                int(int_ds_docto_xml.nNF)     = int(docum-est.nro-docto) AND
                int_ds_docto_xml.cod_emitente = docum-est.cod-emitente   AND 
                int_ds_docto_xml.tipo_nota    = docum-est.tipo-nota      NO-LOCK:
      END.
      for first int_ds_docto_wms where 
          int_ds_docto_wms.doc_numero_n = int(int_ds_docto_xml.nNF) and
          int_ds_docto_wms.doc_serie_s  = int_ds_docto_xml.serie and
          int_ds_docto_wms.cnpj_cpf     = int_ds_docto_xml.CNPJ: 
      end.
       /* Notas Pepsico , apenas atualizam no re1001 */
      FOR FIRST int_ds_ext_emitente NO-LOCK WHERE
                int_ds_ext_emitente.cod_emitente = docum-est.cod-emitente
          query-tuning(no-lookahead) : END.

      IF (AVAIL int_ds_ext_emitente AND  
                int_ds_ext_emitente.gera_nota) OR 
                int_ds_docto_xml.tipo_docto = 0 OR
                int_ds_docto_xml.tipo_docto = 4 OR 
                int_ds_docto_xml.dt_trans < 02/01/2017 /* novo recebimento n∆o far† leitura dos impostos */ THEN DO:
         ASSIGN docum-est.valor-frete  = int_ds_docto_xml.valor_frete            
                docum-est.valor-seguro = int_ds_docto_xml.valor_seguro           
                docum-est.despesa-nota = int_ds_docto_xml.despesa_nota           
                docum-est.valor-outras = int_ds_docto_xml.valor_outras                 
                docum-est.tot-desconto = int_ds_docto_xml.tot_desconto           
                docum-est.valor-mercad = int_ds_docto_xml.valor_mercad           
                docum-est.icm-deb-cre  = int_ds_docto_xml.valor_icms
                docum-est.ipi-deb-cre  = int_ds_docto_xml.valor_ipi
                docum-est.base-icm     = int_ds_docto_xml.vbc
                docum-est.base-subs    = int_ds_docto_xml.vbc_cst
                docum-est.tot-valor    = int_ds_docto_xml.vNF
                /*docum-est.val-cofins = int_ds_docto_xml.valor_cofins*/
                /*docum-est.valor-pis  = int_ds_docto_xml.valor_pis*/
                docum-est.vl-subs      = int_ds_docto_xml.valor_st
                docum-est.base-ipi     = 0 /* busca nos itens */
                docum-est.cod-chave-aces-nf-eletro = int_ds_docto_xml.chnfe.
                /* docum-est.icm-nao-trib  = int_ds_docto_xml.valor_icms_des. */

         FOR EACH int_ds_it_docto_xml WHERE 
                  int_ds_it_docto_xml.cod_emitente = int_ds_docto_xml.cod_emitente AND
                  int_ds_it_docto_xml.serie        = int_ds_docto_xml.serie        AND
                  int(int_ds_it_docto_xml.nNF)     = int(int_ds_docto_xml.nNF)     AND
                  int_ds_it_docto_xml.tipo_nota    = int_ds_docto_xml.tipo_nota    NO-LOCK:
             FOR FIRST item-doc-est WHERE
                       item-doc-est.cod-emitente   = int_ds_it_docto_xml.cod_emitente AND
                       item-doc-est.serie-docto    = int_ds_it_docto_xml.serie        AND
                       int(item-doc-est.nro-docto) = int(int_ds_it_docto_xml.nNF)     AND
                       item-doc-est.sequencia      = int_ds_it_docto_xml.sequencia  AND
                       item-doc-est.it-codigo      = int_ds_it_docto_xml.it_codigo:
             END.
             IF AVAIL item-doc-est THEN DO:

                FIND FIRST ITEM NO-LOCK
                     WHERE ITEM.it-codigo = item-doc-est.it-codigo NO-ERROR.

                IF AVAIL ITEM THEN DO:

                    IF ITEM.tipo-contr <> 2 THEN DO:

                        IF item-doc-est.num-pedido > 0 AND item-doc-est.numero-ordem > 0 THEN DO:
                            FIND FIRST ordem-compra NO-LOCK
                                 WHERE ordem-compra.num-pedido   = item-doc-est.num-pedido
                                   AND ordem-compra.numero-ordem = item-doc-est.numero-ordem NO-ERROR.

                            IF AVAIL ordem-compra THEN
                                ASSIGN item-doc-est.ct-codigo = ordem-compra.ct-codigo
                                       item-doc-est.sc-codigo = ordem-compra.sc-codigo.         
                        END.
                        ELSE IF item-doc-est.num-pedido > 0 AND item-doc-est.numero-ordem = 0 THEN DO:
                            FIND FIRST ordem-compra NO-LOCK
                                 WHERE ordem-compra.num-pedido   = item-doc-est.num-pedido
                                   AND ordem-compra.it-codigo    = item-doc-est.it-codigo NO-ERROR.

                              IF AVAIL ordem-compra THEN
                                  ASSIGN item-doc-est.ct-codigo = ordem-compra.ct-codigo
                                         item-doc-est.sc-codigo = ordem-compra.sc-codigo.   
                        END.
                        ELSE DO:
                               ASSIGN item-doc-est.ct-codigo = ITEM.ct-codigo
                                      item-doc-est.sc-codigo = ITEM.sc-codigo.   
                        END.

                        IF item-doc-est.ct-codigo = "" THEN DO:
                           IF AVAIL ordem-compra THEN
                               ASSIGN item-doc-est.ct-codigo = ordem-compra.ct-codigo
                                      item-doc-est.sc-codigo = ordem-compra.sc-codigo.   
                        END.
                    END.
                END.

                ASSIGN item-doc-est.num-pedido           = int_ds_it_docto_xml.num_pedido
                       item-doc-est.numero-ordem         = int_ds_it_docto_xml.numero_ordem 
                       item-doc-est.desconto             = int_ds_it_docto_xml.vDEsc                   
                       /*item-doc-est.nat-operacao       = int_ds_it_docto_xml.nat_operacao*/
                       item-doc-est.nat-of               = int_ds_it_docto_xml.nat_operacao
                       item-doc-est.aliquota-icm         = int_ds_it_docto_xml.picms   
                       item-doc-est.base-ipi[1]          = IF item-doc-est.cd-trib-ipi = 1 THEN int_ds_it_docto_xml.vbc_ipi ELSE 0
                       item-doc-est.valor-ipi[1]         = int_ds_it_docto_xml.vipi /*int_ds_it_docto_xml.vbc_ipi*/ /* Alterado Ricardo 27032017 */ 
                       item-doc-est.ipi-outras           = IF item-doc-est.cd-trib-ipi = 3 THEN int_ds_it_docto_xml.vbc_ipi /* Alterado Ricardo 27032017 */ ELSE 0
                       item-doc-est.ipi-ntrib            = IF item-doc-est.cd-trib-ipi = 1 THEN int_ds_it_docto_xml.vbc_ipi ELSE 0
                       item-doc-est.valor-pis            = int_ds_it_docto_xml.vpis
                       item-doc-est.preco-unit-me        = int_ds_it_docto_xml.vuncom
                       item-doc-est.preco-unit           = int_ds_it_docto_xml.vuncom
                       item-doc-est.preco-total[1]       = int_ds_it_docto_xml.vprod
                       item-doc-est.val-cofins           = int_ds_it_docto_xml.vcofins
                       item-doc-est.val-aliq-cofins      = int_ds_it_docto_xml.pcofins
                       item-doc-est.val-aliq-pis         = int_ds_it_docto_xml.ppis
                       item-doc-est.base-pis             = int_ds_it_docto_xml.vbc_pis
                       item-doc-est.idi-tributac-pis     = IF int_ds_it_docto_xml.ppis > 0 THEN 1 ELSE 3
                       item-doc-est.idi-tributac-cofins  = IF int_ds_it_docto_xml.pcofins > 0 THEN 1 ELSE 3
                       item-doc-est.val-base-calc-cofins = int_ds_it_docto_xml.vbc_cofins
                       item-doc-est.base-icm[1]          = int_ds_it_docto_xml.vbc_icms
                       item-doc-est.icm-outras[1]        = int_ds_it_docto_xml.vbc_icms
                       item-doc-est.valor-icm            = int_ds_it_docto_xml.vicms
                       item-doc-est.base-subs[1]         = int_ds_it_docto_xml.vbcst
                       item-doc-est.vl-subs[1]           = int_ds_it_docto_xml.vicmsst.
                       /* item-doc-est.icm-ntrib            = int_ds_it_docto_xml.vicmsdeson. */

                for first natur-oper fields (subs-trib)
                    no-lock where natur-oper.nat-operacao = item-doc-est.nat-of:
                end.
                IF AVAIL natur-oper THEN DO:
                   assign item-doc-est.log-2 = natur-oper.subs-trib.
                   /* retirado a pedido do Michel
                   IF int_ds_it_docto_xml.vicmsst > 0 THEN DO:
                      ASSIGN item-doc-est.log-icm-retido = natur-oper.subs-trib. 
                   END.
                   */
                END.
                /* retirado a pedido do Michel
                if int_ds_it_docto_xml.vicmsstret <> 0 then do:
                    assign item-doc-est.vl-subs[1]   = int_ds_it_docto_xml.vicmsstret.
                           /* item-doc-est.base-subs[1] = int_ds_it_docto_xml.vbcstret */
                END.
                */
               /* = int_ds_it_docto_xml.vbcst */   
               /* Verificar qual o campo no Datasul = int_ds_it_docto_xml.picmsst    */             
               /* Verificar qual o campo no Datasul = int_ds_it_docto_xml.pmvast     */
               /* Verificar qual o campo no Datasul = int_ds_it_docto_xml.vicmsst    */           

             END.

             assign docum-est.base-ipi = docum-est.base-ipi + int_ds_it_docto_xml.vbc_ipi.

         END.
      END.
      ELSE DO:
          IF (AVAIL int_ds_docto_xml AND 
              int_ds_docto_xml.tipo_docto <> 4) OR 
              NOT AVAIL int_ds_docto_xml 
          THEN DO:
          
            run utp/ut-msgs.p(input "show",
                              input 17006,
                             input ("Documento inv†lido!" + "~~" + "Notas do novo recebimento CD ou de lojas dever∆o ser acertadas nas telas INT510/INT520.")).
            return "NOK".
          END.
      END.

   END.
END.
RETURN "OK".

