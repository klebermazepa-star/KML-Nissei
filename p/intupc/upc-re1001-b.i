      FOR FIRST int-ds-docto-xml WHERE
                int-ds-docto-xml.serie        = docum-est.serie-docto    AND
                int(int-ds-docto-xml.nNF)     = int(docum-est.nro-docto) AND
                int-ds-docto-xml.cod-emitente = docum-est.cod-emitente   AND 
                int-ds-docto-xml.tipo-nota    = docum-est.tipo-nota      NO-LOCK:
      END.
      IF AVAIL int-ds-docto-xml THEN DO:
         ASSIGN docum-est.valor-frete   = int-ds-docto-xml.valor-frete            
                docum-est.valor-seguro  = int-ds-docto-xml.valor-seguro           
                docum-est.despesa-nota  = int-ds-docto-xml.despesa-nota           
                docum-est.valor-outras  = int-ds-docto-xml.valor-outras                 
                docum-est.tot-desconto  = int-ds-docto-xml.tot-desconto           
                docum-est.valor-mercad  = int-ds-docto-xml.valor-mercad           
                docum-est.icm-deb-cre   = int-ds-docto-xml.valor-icms             
                docum-est.ipi-deb-cre   = int-ds-docto-xml.valor-ipi              
                docum-est.base-icm      = int-ds-docto-xml.vbc                    
                docum-est.base-subs     = int-ds-docto-xml.vbc-cst.

         assign /*docum-est.val-cofins    = int-ds-docto-xml.valor-cofins*/
                /*docum-est.valor-pis     = int-ds-docto-xml.valor-pis*/
                docum-est.vl-subs       = int-ds-docto-xml.valor-st.

         FOR EACH int-ds-it-docto-xml WHERE 
                  int-ds-it-docto-xml.cod-emitente = int-ds-docto-xml.cod-emitente AND
                  int-ds-it-docto-xml.serie        = int-ds-docto-xml.serie        AND
                  int-ds-it-docto-xml.nNF          = int-ds-docto-xml.nNF          AND
                  int-ds-it-docto-xml.tipo-nota    = int-ds-docto-xml.tipo-nota    NO-LOCK:
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
