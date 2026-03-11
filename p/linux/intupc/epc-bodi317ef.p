/******************************************************************************************
**  Programa: epc-bodi317ef.p
**   
**  Objetivo: Substitui‡Æo de Cupom - Gravar tabela nota-fisc-adc  
******************************************************************************************/      
          
{include/i-epc200.i bodi317ef}
{cdp/cdcfgdis.i} /* Defini‡Æo dos pr‚-processadores */

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
        
      FOR FIRST it-nota-fisc fields (cod-estabel serie nr-nota-fis nr-seq-fat it-codigo nr-pedcli) WHERE 
                ROWID(it-nota-fisc) = TO-ROWID(c-rowid) NO-LOCK: END.
      IF AVAIL it-nota-fisc and it-nota-fisc.cod-estabel <> "973" THEN DO:
        FOR FIRST int_ds_pedido_subs fields (ped_codigo_n 
                                             cod_model_ecf          
                                             cod_fabricc_ecf        
                                             cod_cx_ecf             
                                             cod_docto_referado_ecf 
                                             dat_docto_referado_ecf
                                             ped_tipopedido_n)
            where int_ds_pedido_subs.ped_codigo_n = INT(it-nota-fisc.nr-pedcli) NO-LOCK: END.
        IF AVAIL int_ds_pedido_subs and
           int_ds_pedido_subs.cod_model_ecf   <> "?" AND 
           int_ds_pedido_subs.cod_fabricc_ecf <> "?" AND 
           int_ds_pedido_subs.ped_tipopedido_n = 48 THEN DO:
          FOR FIRST nota-fiscal fields (cod-estabel 
                                        serie       
                                        nr-nota-fis 
                                        cod-emitente
                                        nat-operacao)
             OF it-nota-fisc NO-LOCK: 
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
             ASSIGN nota-fisc-adc.cod-model-ecf          = int_ds_pedido_subs.cod_model_ecf
                    nota-fisc-adc.cod-fabricc-ecf        = int_ds_pedido_subs.cod_fabricc_ecf
                    nota-fisc-adc.cod-cx-ecf             = int_ds_pedido_subs.cod_cx_ecf
                    nota-fisc-adc.cod-docto-referado-ecf = int_ds_pedido_subs.cod_docto_referado_ecf
                    nota-fisc-adc.dat-docto-referado-ecf = int_ds_pedido_subs.dat_docto_referado_ecf.
          END. /* for first */
        END. /* pedido_subs */
        else  do:
            IF can-find(FIRST int_ds_pedido no-lock where 
                         int_ds_pedido.ped_codigo_n = INT(it-nota-fisc.nr-pedcli) and
                         int_ds_pedido.ped_tipopedido_n = 15) THEN DO:

                FOR FIRST int_ds_pedido_produto fields (ped_codigo_n nen_notafiscal_n nen_serie_s) WHERE
                      int_ds_pedido_produto.ped_codigo_n      = INT(it-nota-fisc.nr-pedcli) AND 
                      int_ds_pedido_produto.nen_notafiscal_n <> ? AND 
                      int_ds_pedido_produto.nen_serie_s      <> ? NO-LOCK: END.
                IF AVAIL int_ds_pedido_produto THEN do:
                    FOR FIRST nota-fiscal fields (cod-estabel 
                                                serie       
                                                nr-nota-fis 
                                                cod-emitente
                                                nat-operacao)
                        OF it-nota-fisc NO-LOCK: 
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
                        ASSIGN nota-fisc-adc.cod-docto-referado       = string(int_ds_pedido_produto.nen_notafiscal_n) 
                               nota-fisc-adc.cod-ser-docto-referado   = string(int_ds_pedido_produto.nen_serie_s)
                               nota-fisc-adc.cdn-emit-docto-referado  = nota-fiscal.cod-emitente
                               nota-fisc-adc.cod-model-docto-referado = "1"
                               nota-fisc-adc.dat-docto-referado       = /*int-ds-pedido.dat-docto-referado-ecf*/ 08/01/2016
                               nota-fisc-adc.idi-tip-docto-referado   = 1
                               nota-fisc-adc.idi-tip-emit-referado    = 1.
                    end. /* nota-fiscal */
                END. /* pedido_produto */
            end. /* if can-find */
        END. /* else if */
      END. /* avail it-nota-fisc */
   END. /* tt-epc */
END. 

/****** Evitar Duplicidade das notas *****/
/*
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

              if can-find(FIRST nota-fiscal NO-LOCK WHERE        
                          nota-fiscal.cod-estabel = ped-venda.cod-estabel AND
                          nota-fiscal.nr-pedcli   = ped-venda.nr-pedcli   AND 
                          nota-fiscal.nome-ab-cli = ped-venda.nome-abrev  AND 
                          nota-fiscal.dt-cancela  = ?)
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

        /* c¢pia valore originais quando devolu‡Æo a fornecedor loja */
        {intupc/epc-bodi317im1br.i}
   END.
END.
*/
RETURN "OK".
     
