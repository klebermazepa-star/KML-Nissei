/******************************************************************************************
**  Programa: epc-bodi317ef.p
**   
**  Objetivo: Substitui‡Æo de Cupom - Gravar tabela nota-fisc-adc  
******************************************************************************************/      
          
{include/i-epc200.i bodi317ef}

DEF INPUT PARAM p-ind-event AS CHAR NO-UNDO.
DEF INPUT-OUTPUT PARAM TABLE FOR tt-epc. 

DEF VAR c-rowid    AS CHAR    NO-UNDO.
DEF VAR i-tot-nota AS INTEGER NO-UNDO. 

DEF BUFFER b-nota-fiscal FOR nota-fiscal. 

DEF VAR hBODI317ef-ft4002 AS HANDLE NO-UNDO.
def var de-fator as decimal no-undo.

IF p-ind-event  = "afterCriaItNotaFisc" 
THEN DO:    

   FOR FIRST tt-epc WHERE 
             tt-epc.cod-event     = p-ind-event AND   
             tt-epc.cod-parameter = "Rowid_WtItDocto_ItNotaFisc":
   END.
   IF AVAIL tt-epc THEN DO:
      ASSIGN c-rowid = ENTRY(2,tt-epc.val-parameter,",").
        
      FOR FIRST it-nota-fisc WHERE 
                ROWID(it-nota-fisc) = TO-ROWID(c-rowid) NO-LOCK:
      END.
      IF AVAIL it-nota-fisc THEN DO:
         IF it-nota-fisc.cod-estabel <> "973" THEN DO:
            FOR FIRST int-ds-pedido-subs WHERE
                      int-ds-pedido-subs.ped-codigo-n = INT(it-nota-fisc.nr-pedcli) NO-LOCK: 
            END.
            IF AVAIL int-ds-pedido-subs THEN DO:
               IF int-ds-pedido-subs.cod-model-ecf   <> "?" AND 
                  int-ds-pedido-subs.cod-fabricc-ecf <> "?" AND 
                  int-ds-pedido-subs.ped-tipopedido-n = 48 THEN DO:
                  FOR FIRST nota-fiscal OF it-nota-fisc NO-LOCK:
                  END.
                  IF AVAIL nota-fiscal THEN DO:
                     FOR FIRST nota-fisc-adc WHERE
                               nota-fisc-adc.cod-estab      = nota-fiscal.cod-estabel  AND
                               nota-fisc-adc.cod-serie      = nota-fiscal.serie        AND
                               nota-fisc-adc.cod-nota-fisc  = nota-fiscal.nr-nota-fis  AND
                               nota-fisc-adc.cdn-emitente   = nota-fiscal.cod-emitente AND
                               nota-fisc-adc.cod-natur-oper = nota-fiscal.nat-operacao AND
                               nota-fisc-adc.idi-tip-dado   = 4                        AND
                               nota-fisc-adc.num-seq        = 1:
                     END.
                     IF NOT AVAIL nota-fisc-adc THEN DO:
                        create nota-fisc-adc.
                        ASSIGN nota-fisc-adc.cod-estab      = nota-fiscal.cod-estabel  
                               nota-fisc-adc.cod-serie      = nota-fiscal.serie        
                               nota-fisc-adc.cod-nota-fisc  = nota-fiscal.nr-nota-fis  
                               nota-fisc-adc.cdn-emitente   = nota-fiscal.cod-emitente 
                               nota-fisc-adc.cod-natur-oper = nota-fiscal.nat-operacao 
                               nota-fisc-adc.idi-tip-dado   = 4                          
                               nota-fisc-adc.num-seq        = 1.
                     END.
                     ASSIGN nota-fisc-adc.cod-model-ecf          = int-ds-pedido-subs.cod-model-ecf
                            nota-fisc-adc.cod-fabricc-ecf        = int-ds-pedido-subs.cod-fabricc-ecf
                            nota-fisc-adc.cod-cx-ecf             = int-ds-pedido-subs.cod-cx-ecf
                            nota-fisc-adc.cod-docto-referado-ecf = int-ds-pedido-subs.cod-docto-referado-ecf
                            nota-fisc-adc.dat-docto-referado-ecf = int-ds-pedido-subs.dat-docto-referado-ecf.
                  END.
               END.
            END.

            FOR FIRST int-ds-pedido-produto WHERE
                      int-ds-pedido-produto.ped-codigo-n      = INT(it-nota-fisc.nr-pedcli) AND 
                      int-ds-pedido-produto.nen-notafiscal-n <> ? AND 
                      int-ds-pedido-produto.nen-serie-s      <> ? NO-LOCK: 
            END.
            IF AVAIL int-ds-pedido-produto THEN DO:       
               FOR FIRST int-ds-pedido OF int-ds-pedido-produto WHERE 
                         int-ds-pedido.ped-tipopedido-n = 15 NO-LOCK:
               END.
               IF AVAIL int-ds-pedido THEN DO:
                  FOR FIRST nota-fiscal OF it-nota-fisc NO-LOCK:
                  END.
                  IF AVAIL nota-fiscal THEN DO:
                     FOR FIRST nota-fisc-adc WHERE
                               nota-fisc-adc.cod-estab      = nota-fiscal.cod-estabel  AND
                               nota-fisc-adc.cod-serie      = nota-fiscal.serie        AND
                               nota-fisc-adc.cod-nota-fisc  = nota-fiscal.nr-nota-fis  AND
                               nota-fisc-adc.cdn-emitente   = nota-fiscal.cod-emitente AND
                               nota-fisc-adc.cod-natur-oper = nota-fiscal.nat-operacao AND
                               nota-fisc-adc.idi-tip-dado   = 3                        AND
                               nota-fisc-adc.num-seq        = 1:
                     END.
                     IF NOT AVAIL nota-fisc-adc THEN DO:
                        create nota-fisc-adc.
                        ASSIGN nota-fisc-adc.cod-estab      = nota-fiscal.cod-estabel  
                               nota-fisc-adc.cod-serie      = nota-fiscal.serie        
                               nota-fisc-adc.cod-nota-fisc  = nota-fiscal.nr-nota-fis  
                               nota-fisc-adc.cdn-emitente   = nota-fiscal.cod-emitente 
                               nota-fisc-adc.cod-natur-oper = nota-fiscal.nat-operacao 
                               nota-fisc-adc.idi-tip-dado   = 3                          
                               nota-fisc-adc.num-seq        = 1.
                     END.
                     ASSIGN nota-fisc-adc.cod-docto-referado       = string(int-ds-pedido-produto.nen-notafiscal-n) 
                            nota-fisc-adc.cod-ser-docto-referado   = string(int-ds-pedido-produto.nen-serie-s)
                            nota-fisc-adc.cdn-emit-docto-referado  = nota-fiscal.cod-emitente
                            nota-fisc-adc.cod-model-docto-referado = "1"
                            nota-fisc-adc.dat-docto-referado       = /*int-ds-pedido.dat-docto-referado-ecf*/ 08/01/2016
                            nota-fisc-adc.idi-tip-docto-referado   = 1
                            nota-fisc-adc.idi-tip-emit-referado    = 1.
                     
                  END.
               END.
            END.
         END.
      END.
   END.
END. 

/****** Evitar Duplicidade das notas *****/
                              
IF p-ind-event  = "beforeEfetivaNota" 
THEN DO:
   
   FIND FIRST tt-epc WHERE 
              tt-epc.cod-event     = p-ind-event  AND 
              tt-epc.cod-parameter = "table-rowid" NO-ERROR.
   IF AVAIL tt-epc 
   THEN DO:
   
        FIND FIRST wt-docto NO-LOCK WHERE 
           ROWID(wt-docto) = TO-ROWID(tt-epc.val-parameter) NO-ERROR.

   END.
   
   find FIRST tt-epc where 
              tt-epc.cod-event     = p-ind-event AND 
              tt-epc.cod-parameter = "object-handle" NO-LOCK NO-ERROR.
   IF AVAIL tt-epc  AND
      AVAIL wt-docto 
   THEN DO:

        ASSIGN hBODI317ef-ft4002 = WIDGET-HANDLE(tt-epc.val-parameter). 

        FIND ped-venda WHERE 
             ped-venda.nr-pedcli  = wt-docto.nr-pedcli AND 
             ped-venda.nome-abrev = wt-docto.nome-abrev NO-LOCK NO-ERROR.
        IF AVAIL ped-venda  
        THEN DO:

              FOR FIRST nota-fiscal NO-LOCK WHERE        
                        nota-fiscal.cod-estabel = ped-venda.cod-estabel AND
                        nota-fiscal.nr-pedcli   = ped-venda.nr-pedcli   AND 
                        nota-fiscal.nome-ab-cli = ped-venda.nome-abrev  AND 
                        nota-fiscal.dt-cancela  = ?:                      
              END.
              IF AVAIL nota-fiscal 
              THEN DO:  
                  
                  RUN setInterrompeCalculo IN hBODI317ef-ft4002 (INPUT YES).
    
                  RUN _insertErrorManual IN hBODI317ef-ft4002 (INPUT 99999,
                                                        INPUT "EMS",
                                                        INPUT "ERROR",
                                                        INPUT "Pedido Informado J  faturado",
                                                        INPUT "Pedido Informado J  faturado",
                                                        INPUT "").


                  RETURN "NOK".
    
              END.
        END.


        DISPLAY wt-docto.esp-docto   
                wt-docto.cod-estabel 
                wt-docto.nat-operacao
            WITH WIDTH 330 STREAM-IO.




        /* c¢pia valore originais quando devolu‡Æo a fornecedor loja */
        if  wt-docto.esp-docto     = 20 /* NFD */ and
            wt-docto.cod-estabel  <> "973" and
            wt-docto.nat-operacao >= "5000"
        then do:

            for first emitente no-lock where emitente.cod-emitente = nota-fiscal.cod-emitente: end.
            for each wt-it-docto of wt-docto:


                DISPLAY wt-it-docto.it-codigo
                        wt-it-docto.nro-comp
                        wt-it-docto.serie-comp
                        wt-it-docto.nat-comp
                        wt-it-docto.seq-comp

                        wt-it-docto.nr-docum
                        wt-it-docto.serie-docum

                    WITH WIDTH 330 STREAM-IO.


                if wt-it-docto.nro-comp <> "" then do: 

                    for each item-doc-est no-lock where 
                        item-doc-est.cod-emitente = wt-docto.cod-emitente   and
                        item-doc-est.serie-docto  = wt-it-docto.serie-comp  and
                        item-doc-est.nro-docto    = wt-it-docto.nro-comp    and
                        item-doc-est.nat-operacao = wt-it-docto.nat-comp    and
                        item-doc-est.it-codigo    = wt-it-docto.it-codigo   and
                        item-doc-est.sequencia    = wt-it-docto.seq-comp: /* conirmar seq-comp */


                        DISPLAY item-doc-est.cod-emitente
                                item-doc-est.serie-docto 
                                item-doc-est.nro-docto   
                                item-doc-est.nat-operacao
                                item-doc-est.it-codigo   
                                item-doc-est.sequencia   
                            WITH WIDTH 330 STREAM-IO.


                        display 
                        /* PIS/COFINS - Notas de devolu¯Êo */
                        &if "{&bf_dis_versao_ems}" < "2.06" &then
                                   substring(wt-it-docto.char-2,76,5) string(dec(substr(item-doc-est.char-2,22,5)),"99.99":U)   /* aliquota do PIS */
                                   substring(wt-it-docto.char-2,86,5) "00,00":U                                                 /* reducao do PIS */
                                   substring(wt-it-docto.char-2,96,1)  int(substr(item-doc-est.char-2,21,1))               /* codigo de tributacao */ 
                                   substring(wt-it-docto.char-2,81,5)  substr(item-doc-est.char-2,84, 5)                         /* Aliquota COFINS   */
                        	       substring(wt-it-docto.char-2,91,5)  "00,00":U                                                     /* Reducao COFINS    */
                        	       substring(wt-it-docto.char-2,97,1)  int(substr(item-doc-est.char-2, 83, 1))                /* Tributacao COFINS */
                        &else
                                   substring(wt-it-docto.char-2,76,5)  string(item-doc-est.val-aliq-pis)                         /* alðquota do PIS */
                                   substring(wt-it-docto.char-2,86,5)  "00,00":U                                                 /* reducao do PIS */
                	               substring(wt-it-docto.char-2,96,1)  string(item-doc-est.idi-tributac-pis)
                    	           substring(wt-it-docto.char-2,81,5)  string(Item-doc-est.val-aliq-cofins)                          /* Aliquota COFINS   */
                            	   substring(wt-it-docto.char-2,91,5)  "00,00":U                                                     /* Reducao COFINS    */
                    	           substring(wt-it-docto.char-2,97,1)  string(Item-doc-est.idi-tributac-cofins)
                        &endif
                           WITH WIDTH 550 STREAM-IO.

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
    

                        assign de-fator = wt-it-docto.quantidade[1] / item-doc-est.quantidade. /* confirmar campo quantidade */

                        for each wt-it-imposto of wt-it-docto:
                            display wt-it-imposto.aliquota-icm       item-doc-est.aliquota-icm                    
                                    wt-it-imposto.aliquota-ipi       item-doc-est.aliquota-ipi                    
                                    wt-it-imposto.cd-trib-icm        item-doc-est.cd-trib-icm                     
                                    wt-it-imposto.cd-trib-ipi        item-doc-est.cd-trib-ipi                     
                                    wt-it-imposto.ind-icm-ret        item-doc-est.log-icm-retido                  
                                    wt-it-imposto.perc-red-icm       item-doc-est.val-perc-red-icms    * de-fator 
                                    wt-it-imposto.perc-red-ipi       item-doc-est.val-perc-rep-ipi     * de-fator 
                                    wt-it-imposto.vl-bicms-it        item-doc-est.base-icm[1]          * de-fator 
                                    wt-it-imposto.vl-bipi-it         item-doc-est.base-ipi[1]          * de-fator 
                                    wt-it-imposto.vl-bsubs-it        item-doc-est.base-subs[1]         * de-fator 
                                    wt-it-imposto.vl-cofins          item-doc-est.val-cofins           * de-fator 
                                    wt-it-imposto.vl-cofins-sub      item-doc-est.vl-cofins-subs       * de-fator 
                                    wt-it-imposto.vl-icms-it         item-doc-est.valor-icm[1]         * de-fator 
                                    wt-it-imposto.vl-icms-outras     item-doc-est.icm-outras[1]        * de-fator 
                                    wt-it-imposto.vl-icms-outras-me  item-doc-est.icm-outras[1]        * de-fator 
                                    wt-it-imposto.vl-icmsnt-it       item-doc-est.icm-ntrib[1]         * de-fator 
                                    wt-it-imposto.vl-icmsou-it       item-doc-est.icm-outras[1]        * de-fator 
                                    wt-it-imposto.vl-icmsub-it       item-doc-est.vl-subs[1]           * de-fator 
                                    wt-it-imposto.vl-ipi-it          item-doc-est.valor-ipi[1]         * de-fator 
                                    wt-it-imposto.vl-ipi-outras      item-doc-est.ipi-outras[1]        * de-fator 
                                    wt-it-imposto.vl-ipi-outras-me   item-doc-est.ipi-outras[1]        * de-fator 
                                    wt-it-imposto.vl-ipint-it        item-doc-est.ipi-ntrib[1]         * de-fator 
                                    wt-it-imposto.vl-ipiou-it        item-doc-est.ipi-outras[1]        * de-fator 
                                    wt-it-imposto.vl-pis             item-doc-est.valor-pis            * de-fator 
                                    wt-it-imposto.vl-pis-sub         item-doc-est.vl-pis-subs          * de-fator
                                WITH WIDTH 550 STREAM-IO.

                            assign  wt-it-imposto.aliquota-icm      = item-doc-est.aliquota-icm
                                    wt-it-imposto.aliquota-ipi      = item-doc-est.aliquota-ipi
                                    wt-it-imposto.cd-trib-icm       = item-doc-est.cd-trib-icm 
                                    wt-it-imposto.cd-trib-ipi       = item-doc-est.cd-trib-ipi 
                                    wt-it-imposto.ind-icm-ret       = item-doc-est.log-icm-retido
                                    wt-it-imposto.perc-red-icm      = item-doc-est.val-perc-red-icms    * de-fator
                                    wt-it-imposto.perc-red-ipi      = item-doc-est.val-perc-rep-ipi     * de-fator
                                    wt-it-imposto.vl-bicms-it       = item-doc-est.base-icm[1]          * de-fator
                                    wt-it-imposto.vl-bipi-it        = item-doc-est.base-ipi[1]          * de-fator
                                    wt-it-imposto.vl-bsubs-it       = item-doc-est.base-subs[1]         * de-fator
                                    wt-it-imposto.vl-cofins         = item-doc-est.val-cofins           * de-fator
                                    wt-it-imposto.vl-cofins-sub     = item-doc-est.vl-cofins-subs       * de-fator
                                    wt-it-imposto.vl-icms-it        = item-doc-est.valor-icm[1]         * de-fator
                                    wt-it-imposto.vl-icms-outras    = item-doc-est.icm-outras[1]        * de-fator
                                    wt-it-imposto.vl-icms-outras-me = item-doc-est.icm-outras[1]        * de-fator
                                    wt-it-imposto.vl-icmsnt-it      = item-doc-est.icm-ntrib[1]         * de-fator
                                    wt-it-imposto.vl-icmsou-it      = item-doc-est.icm-outras[1]        * de-fator
                                    wt-it-imposto.vl-icmsub-it      = item-doc-est.vl-subs[1]           * de-fator
                                    wt-it-imposto.vl-ipi-it         = item-doc-est.valor-ipi[1]         * de-fator
                                    wt-it-imposto.vl-ipi-outras     = item-doc-est.ipi-outras[1]        * de-fator
                                    wt-it-imposto.vl-ipi-outras-me  = item-doc-est.ipi-outras[1]        * de-fator
                                    wt-it-imposto.vl-ipint-it       = item-doc-est.ipi-ntrib[1]         * de-fator
                                    wt-it-imposto.vl-ipiou-it       = item-doc-est.ipi-outras[1]        * de-fator
                                    wt-it-imposto.vl-pis            = item-doc-est.valor-pis            * de-fator
                                    wt-it-imposto.vl-pis-sub        = item-doc-est.vl-pis-subs          * de-fator.

                        end.
                    end.
                end.
            end.
        end.
         
   END.
     
END.
OUTPUT CLOSE.
RETURN "OK".
     
