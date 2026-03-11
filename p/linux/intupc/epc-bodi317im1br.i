    def var de-soma-pis-cofins-subst as decimal no-undo.
    def var de-base-icms as decimal no-undo.

    define buffer b-natur-oper for natur-oper.

    /*OUTPUT TO t:\epc-bodi317im1br-log.txt APPEND.*/

    /* c¢pia valore originais quando devolu‡Æo a fornecedor loja */
    if  wt-docto.esp-docto     = 20 /* NFD */ and
        /*wt-docto.cod-estabel  <> "973" and*/
        wt-docto.nat-operacao >= "5000" then 
    for each wt-it-docto of wt-docto:

        /*
        DISPLAY wt-it-docto.it-codigo
                wt-it-docto.nro-comp
                wt-it-docto.serie-comp
                wt-it-docto.nat-comp
                wt-it-docto.seq-comp
                wt-it-docto.nr-docum
                wt-it-docto.serie-docum
            WITH WIDTH 330 STREAM-IO.
        */

        if wt-it-docto.nro-comp <> "" then do: 

            for each item-doc-est no-lock where 
                item-doc-est.cod-emitente = wt-docto.cod-emitente   and
                item-doc-est.serie-docto  = wt-it-docto.serie-comp  and
                item-doc-est.nro-docto    = wt-it-docto.nro-comp    and
                item-doc-est.nat-operacao = wt-it-docto.nat-comp    and
                item-doc-est.it-codigo    = wt-it-docto.it-codigo   and
                item-doc-est.sequencia    = wt-it-docto.seq-comp:

                /*      
                DISPLAY item-doc-est.cod-emitente
                        item-doc-est.serie-docto 
                        item-doc-est.nro-docto   
                        item-doc-est.nat-operacao
                        item-doc-est.it-codigo   
                        item-doc-est.sequencia   
                    WITH WIDTH 330 STREAM-IO.
                */

                /* PIS/COFINS - Notas de devolu¯Êo */
                &if "{&bf_dis_versao_ems}" < "2.06" &then
                    ASSIGN overlay(wt-it-docto.char-2,76,5) = string(dec(substr(item-doc-est.char-2,22,5)),"99.99":U)   /* aliquota do PIS */
                           overlay(wt-it-docto.char-2,86,5) = "00,00":U                                                 /* reducao do PIS */
                           overlay(wt-it-docto.char-2,96,1) = if int(substr(item-doc-est.char-2,21,1)) > 0              /* codigo de tributacao */ 
                                                              then substr(item-doc-est.char-2,21,1)
                                                              else "2":U
                           overlay(wt-it-docto.char-2,81,5) = substr(item-doc-est.char-2,84, 5)                         /* Aliquota COFINS   */
                           overlay(wt-it-docto.char-2,91,5) = "00,00":U                                                     /* Reducao COFINS    */
                           overlay(wt-it-docto.char-2,97,1) = if int(substr(item-doc-est.char-2, 83, 1)) > 0                /* Tributacao COFINS */
                                                              then substr(item-doc-est.char-2,83,1) 
                                                              else "2":U. 
                &else
                    ASSIGN overlay(wt-it-docto.char-2,76,5) = string(item-doc-est.val-aliq-pis)                         /* alðquota do PIS */
                           overlay(wt-it-docto.char-2,86,5) = "00,00":U                                                 /* reducao do PIS */
                           overlay(wt-it-docto.char-2,96,1) = if item-doc-est.idi-tributac-pis > 0                          /* codigo tributacao PIS*/ 
                                                              then string(item-doc-est.idi-tributac-pis)
                                                              else "2":U
                           overlay(wt-it-docto.char-2,81,5) = string(Item-doc-est.val-aliq-cofins)                          /* Aliquota COFINS   */
                           overlay(wt-it-docto.char-2,91,5) = "00,00":U                                                     /* Reducao COFINS    */
                           overlay(wt-it-docto.char-2,97,1) = if Item-doc-est.idi-tributac-cofins  > 0                      /* Tributacao COFINS */
                                                              then string(Item-doc-est.idi-tributac-cofins)
                                                              else "2":U.               
                &endif
                

                assign de-fator = wt-it-docto.quantidade[1] / item-doc-est.quantidade.

                for each wt-it-imposto of wt-it-docto:
                    /*  
                    display "Aliq ICM:" wt-it-imposto.aliquota-icm       item-doc-est.aliquota-icm    SKIP                
                            "Aliq IPI:" wt-it-imposto.aliquota-ipi       item-doc-est.aliquota-ipi    SKIP                
                            "Trib ICM:" wt-it-imposto.cd-trib-icm        item-doc-est.cd-trib-icm     SKIP
                            "Trib IPI:" wt-it-imposto.cd-trib-ipi        item-doc-est.cd-trib-ipi     SKIP
                            "ICMS RET:" wt-it-imposto.ind-icm-ret        item-doc-est.log-2  SKIP
                            "RED ICM: " wt-it-imposto.perc-red-icm       item-doc-est.val-perc-red-icms    SKIP
                            "RED IPI: " wt-it-imposto.perc-red-ipi       item-doc-est.val-perc-rep-ipi     SKIP
                            "Base ICM:" wt-it-imposto.vl-bicms-it        item-doc-est.base-icm[1]          * de-fator SKIP
                            "Base IPI:" wt-it-imposto.vl-bipi-it         item-doc-est.base-ipi[1]          * de-fator SKIP
                            "BSUBS ICM:" wt-it-imposto.vl-bsubs-it        item-doc-est.base-subs[1]         * de-fator SKIP
                            "COFINS:" wt-it-imposto.vl-cofins          item-doc-est.val-cofins           * de-fator SKIP
                            "COFINS SUB:" wt-it-imposto.vl-cofins-sub      item-doc-est.vl-cofins-subs       * de-fator SKIP
                            "VALOR ICM:" wt-it-imposto.vl-icms-it         item-doc-est.valor-icm[1]         * de-fator SKIP
                            "ICMS OUT:" wt-it-imposto.vl-icms-outras     item-doc-est.icm-outras[1]        * de-fator SKIP
                            "ICMS ISN:" wt-it-imposto.vl-icmsnt-it       item-doc-est.icm-ntrib[1]         * de-fator SKIP
                            "ICMS OUT:" wt-it-imposto.vl-icmsou-it       item-doc-est.icm-outras[1]        * de-fator SKIP
                            "VL SUBS:" wt-it-imposto.vl-icmsub-it       item-doc-est.vl-subs[1]           * de-fator SKIP
                            "VL IPI:" wt-it-imposto.vl-ipi-it          item-doc-est.valor-ipi[1]         * de-fator SKIP
                            "IPI OUT:" wt-it-imposto.vl-ipi-outras      item-doc-est.ipi-outras[1]        * de-fator SKIP
                            "IPI ISN:" wt-it-imposto.vl-ipint-it        item-doc-est.ipi-ntrib[1]         * de-fator SKIP
                            "IPI OUT:" wt-it-imposto.vl-ipiou-it        item-doc-est.ipi-outras[1]        * de-fator SKIP
                            "PIS:" wt-it-imposto.vl-pis             item-doc-est.valor-pis            * de-fator SKIP
                            "PIS SUBS:" wt-it-imposto.vl-pis-sub         item-doc-est.vl-pis-subs          * de-fator SKIP

                            "TOT item:" wt-it-docto.vl-tot-item         SKIP
                        WITH WIDTH 550 stream-io no-labels.
                    */

                    de-base-icms = if item-doc-est.base-icm[1] <> 0 then (item-doc-est.base-icm[1] * de-fator)
                                   else if item-doc-est.icm-outras[1] <> 0 then (item-doc-est.icm-outras[1] * de-fator) 
                                   else if item-doc-est.icm-ntrib[1] <> 0 then (item-doc-est.icm-outras[1] * de-fator)
                                   else 0.

                    for first natur-oper 
                        fields (cd-trib-icm 
                                subs-trib
                                log-2
                                char-2
                                emite-duplic) no-lock where 
                        natur-oper.nat-operacao = wt-it-docto.nat-operacao: end.
                    assign  wt-it-imposto.aliquota-icm      = item-doc-est.aliquota-icm
                            wt-it-imposto.aliquota-ipi      = item-doc-est.aliquota-ipi
                            wt-it-imposto.cd-trib-icm       = natur-oper.cd-trib-icm 
                            wt-it-imposto.cd-trib-ipi       = item-doc-est.cd-trib-ipi 
                            /*wt-it-imposto.ind-icm-ret       = /*item-doc-est.log-icm-retido*/ item-doc-est.log-2*/
                            wt-it-imposto.perc-red-icm      = item-doc-est.val-perc-red-icms
                            wt-it-imposto.perc-red-ipi      = item-doc-est.val-perc-rep-ipi  

                            wt-it-imposto.vl-bicms-it       = if wt-it-imposto.cd-trib-icm = 1 
                                                              then de-base-icms else 0

                            wt-it-imposto.vl-icms-outras    = if wt-it-imposto.cd-trib-icm = 3
                                                              then de-base-icms else 0
                            wt-it-imposto.vl-icms-outras-me = if wt-it-imposto.cd-trib-icm = 3
                                                              then de-base-icms else 0
                            wt-it-imposto.vl-icmsou-it      = if wt-it-imposto.cd-trib-icm = 3
                                                              then de-base-icms else 0
                            wt-it-imposto.vl-icmsnt-it      = if wt-it-imposto.cd-trib-icm = 2
                                                              then de-base-icms else 0
                            wt-it-imposto.vl-icms-it        = if wt-it-imposto.cd-trib-icm = 2
                                                              then 0 else 
                                                            /*((item-doc-est.aliquota-icm * (1 - item-doc-est.val-perc-red-icms) * de-base-icms) / 100 ) * de-fator*/
                                                              item-doc-est.valor-icm[1] * de-fator

                            wt-it-imposto.vl-bipi-it        = item-doc-est.base-ipi[1]          * de-fator
                            wt-it-imposto.vl-cofins         = item-doc-est.val-cofins           * de-fator
                            wt-it-imposto.vl-cofins-sub     = item-doc-est.vl-cofins-subs       * de-fator
                            wt-it-imposto.vl-ipi-it         = item-doc-est.valor-ipi[1]         * de-fator
                            wt-it-imposto.vl-ipi-outras     = item-doc-est.ipi-outras[1]        * de-fator
                            wt-it-imposto.vl-ipi-outras-me  = item-doc-est.ipi-outras[1]        * de-fator
                            wt-it-imposto.vl-ipint-it       = item-doc-est.ipi-ntrib[1]         * de-fator
                            wt-it-imposto.vl-ipiou-it       = item-doc-est.ipi-outras[1]        * de-fator
                            wt-it-imposto.vl-pis            = item-doc-est.valor-pis            * de-fator
                            wt-it-imposto.vl-pis-sub        = item-doc-est.vl-pis-subs          * de-fator.
  
                    assign wt-it-imposto.vl-bsubs-it       = 0
                           wt-it-imposto.vl-icmsub-it      = 0.
                    if natur-oper.subs-trib then do:
                        for first b-natur-oper no-lock where
                            b-natur-oper.nat-operacao = item-doc-est.nat-of and
                            b-natur-oper.log-contrib-st-antec = no:
                            assign wt-it-imposto.vl-bsubs-it       = item-doc-est.base-subs[1]         * de-fator
                                   wt-it-imposto.vl-icmsub-it      = item-doc-est.vl-subs[1]           * de-fator.
                        end.
                    end.

                    find item no-lock where item.it-codigo = wt-it-docto.it-codigo no-error.
                    find first para-fat no-lock no-error.

                    if avail natur-oper and avail item and avail para-fat then do:
                        if substring(item.char-1,50,5) = "Sim":U then
                            assign de-soma-pis-cofins-subst = wt-it-imposto.vl-pis-sub + wt-it-imposto.vl-cofins-sub.
                        else
                            assign de-soma-pis-cofins-subst = 0.

                        assign wt-it-docto.vl-tot-item = 
                                   (if   (   wt-docto.ind-tip-nota    = 2  /* Nota Manual                    */
                                          OR wt-docto.ind-tip-nota    = 5) /* Nota de Entrada                */
                                    and  wt-it-docto.vl-tot-item-inf <> 0  /* Foi informado valor            */
                                    then wt-it-docto.vl-tot-item-inf       /* Entao ² o valor informado      */
                                    else wt-it-docto.vl-merc-liq    +      /* Senao calcula o valor          */
                                         wt-it-docto.vl-despes-it   + 
                                         wt-it-imposto.vl-icmsub-it +
                                         de-soma-pis-cofins-subst +
                                         if  natur-oper.log-2                              /* NF de Comercio   */
                                         or  (    wt-it-imposto.cd-trib-ipi = 3            /* Outras de IPI    */
                                              and substr(natur-oper.char-2,16,1) = "2":U)  /* IPI tot NF = nao */
                                         then 0
                                         else wt-it-imposto.vl-ipi-it) +  
                                   (if  wt-docto.ind-tip-nota      = 50  /* Complementar de Imposto         */
                                    and wt-it-imposto.vl-icms-it  <> 0   /* Possui valor de ICMS            */
                                    and wt-it-imposto.vl-icmsub-it = 0   /* N’o possui ICMS Substituto      */ 
                                    and not para-fat.ind-preco           /* N’o tem ICMS Incluso no Preco   */
                                    and natur-oper.emite-duplic          /* Gera duplicatas                 */
                                    then wt-it-imposto.vl-icms-it        /* Entao soma o ICMS               */
                                    else 0).                             /* Senao nao soma nada             */
                    end.
                end. /* wt-it-imposto */
            end. /* item-doc-est */
        end. /* nro-comp <> "" */
    end. /* wt-it-docto */
/*output close.*/
