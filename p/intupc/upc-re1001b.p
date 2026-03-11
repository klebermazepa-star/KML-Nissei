/***********************************************************************************************
**  Programa: upc-re1001-b.p
**  
**  Objetivo: Carregar os impostos … partir das tabelas int_ds_docto_xml / int-ds-it-docto-xml
***********************************************************************************************/

DEF NEW GLOBAL SHARED VAR r-row-table-imposto-re1001 AS ROWID NO-UNDO.

RUN utp/ut-msgs.p (INPUT "SHOW",
                   INPUT 27100,
                   INPUT "Confirma a carga dos Impostos?").
IF RETURN-VALUE = "yes" THEN DO:
   FIND FIRST docum-est WHERE 
              ROWID(docum-est) = r-row-table-imposto-re1001 NO-ERROR. 
   IF AVAIL docum-est THEN DO:

      /*
      MESSAGE "atualiza docum-est.frete"
          VIEW-AS ALERT-BOX INFO BUTTONS OK.
      */

      FOR FIRST int_ds_docto_xml WHERE
                int_ds_docto_xml.serie        = docum-est.serie-docto    AND
                int(int_ds_docto_xml.nNF)     = int(docum-est.nro-docto) AND
                int_ds_docto_xml.cod_emitente = docum-est.cod-emitente   AND 
                int_ds_docto_xml.tipo_nota    = docum-est.tipo-nota      NO-LOCK:
      END.
      IF AVAIL int_ds_docto_xml THEN DO:
         ASSIGN docum-est.valor-frete   = int_ds_docto_xml.valor_frete            
                docum-est.valor-seguro  = int_ds_docto_xml.valor_seguro           
                docum-est.despesa-nota  = int_ds_docto_xml.despesa_nota           
                docum-est.valor-outras  = int_ds_docto_xml.valor_outras                 
                docum-est.tot-desconto  = int_ds_docto_xml.tot_desconto           
                docum-est.valor-mercad  = int_ds_docto_xml.valor_mercad           
                docum-est.icm-deb-cre   = int_ds_docto_xml.valor_icms             
                docum-est.ipi-deb-cre   = int_ds_docto_xml.valor_ipi              
                docum-est.base-icm      = int_ds_docto_xml.vbc                    
                docum-est.base-subs     = int_ds_docto_xml.vbc_cst.

         assign /*docum-est.val-cofins    = int_ds_docto_xml.valor-cofins*/
                /*docum-est.valor-pis     = int_ds_docto_xml.valor-pis*/
                docum-est.vl-subs       = int_ds_docto_xml.valor_st.

         FOR EACH int-ds-it-docto-xml WHERE 
                  int-ds-it-docto-xml.cod-emitente = int_ds_docto_xml.cod_emitente AND
                  int-ds-it-docto-xml.serie        = int_ds_docto_xml.serie        AND
                  int-ds-it-docto-xml.nNF          = int_ds_docto_xml.nNF          AND
                  int-ds-it-docto-xml.tipo-nota    = int_ds_docto_xml.tipo_nota    NO-LOCK:
             FOR FIRST item-doc-est WHERE
                       item-doc-est.cod-emitente   = int-ds-it-docto-xml.cod-emitente AND
                       item-doc-est.serie-docto    = int-ds-it-docto-xml.serie        AND
                       int(item-doc-est.nro-docto) = int(int-ds-it-docto-xml.nNF)     AND
                       item-doc-est.sequencia      = int-ds-it-docto-xml.sequencia:   
             END.
             IF AVAIL item-doc-est THEN DO:
                ASSIGN item-doc-est.num-pedido   = int-ds-it-docto-xml.num-pedido
                       item-doc-est.numero-ordem = int-ds-it-docto-xml.numero-ordem 
                       item-doc-est.desconto     = int-ds-it-docto-xml.vDEsc                   
                       item-doc-est.nat-operacao = int-ds-it-docto-xml.nat-operacao   
                       item-doc-est.aliquota-icm = int-ds-it-docto-xml.picms   
                       item-doc-est.base-ipi[1]  = int-ds-it-docto-xml.vbc-ipi                  
                       item-doc-est.valor-ipi[1] = int-ds-it-docto-xml.vipi.

                assign item-doc-est.valor-pis       = int-ds-it-docto-xml.vpis   
                       item-doc-est.val-cofins      = int-ds-it-docto-xml.vcofins
                       item-doc-est.val-aliq-cofins = int-ds-it-docto-xml.pcofins
                       item-doc-est.val-aliq-pis    = int-ds-it-docto-xml.ppis
                       item-doc-est.base-pis        = int-ds-it-docto-xml.vbc-pis
                       item-doc-est.val-base-calc-cofins   = int-ds-it-docto-xml.vbc-cofins.

                assign item-doc-est.base-icm     = int-ds-it-docto-xml.vbc-icms 
                       item-doc-est.base-subs[1] = int-ds-it-docto-xml.vbcstret 
                       item-doc-est.valor-icm    = int-ds-it-docto-xml.vicms
                       item-doc-est.vl-subs[1]   = int-ds-it-docto-xml.vicmsstret.
                       
                       /* = int-ds-it-docto-xml.vbcst */   
                       /* Verificar qual o campo no Datasul = int-ds-it-docto-xml.picmsst    */             
                       /* Verificar qual o campo no Datasul = int-ds-it-docto-xml.pmvast     */
                       /* Verificar qual o campo no Datasul = int-ds-it-docto-xml.vicmsst    */           

             END.
         END.
      END.
   END.
END.

