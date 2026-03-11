/******************************************************************************************
**  Programa: epc-bodi317ef.p
**   
**  Objetivo: SubstituiÂ‡Ã†o de Cupom - Gravar tabela nota-fisc-adc  
******************************************************************************************/      
          
{include/i-epc200.i bodi317ef}
{cdp/cdcfgdis.i} /* DefiniÂ‡Ã†o dos prÂ‚-processadores */
    {dibo/bodi317ef.i1}
    {dibo/bodi317.i tt-wt-docto}

DEF INPUT PARAM p-ind-event AS CHAR NO-UNDO.
DEF INPUT-OUTPUT PARAM TABLE FOR tt-epc. 

DEF VAR c-rowid    AS CHAR    NO-UNDO.
DEF VAR i-tot-nota AS INTEGER NO-UNDO. 
DEFINE VARIABLE l-int110 AS LOGICAL     NO-UNDO.
DEFINE VARIABLE i-cont AS INTEGER     NO-UNDO.
def var l-proc-ok-aux              AS   LOG                        NO-UNDO.
DEF VAR wh-bo                      AS   WIDGET-HANDLE              NO-UNDO.


def var r-nota-fiscal      as rowid     no-undo.
def var r-wt-docto      as rowid     no-undo.

def new global shared var v_cod_empres_usuar as character format 'x(3)' label 'Empresa' column-label 'Empresa' no-undo.

DEF BUFFER b-nota-fiscal FOR nota-fiscal. 
DEF BUFFER b-wt-docto FOR wt-docto.

DEF VAR hBODI317ef-ft4002 AS HANDLE NO-UNDO.
DEF VAR h-BODI317ef AS HANDLE NO-UNDO.
def var de-fator as decimal no-undo.

//MESSAGE 'p-ind-event '  p-ind-event VIEW-AS ALERT-BOX INFORMATION BUTTONS OK TITLE 'bodi317ef'.

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

        ASSIGN h-BODI317ef = WIDGET-HANDLE(tt-epc.val-parameter). 
    
    
        .MESSAGE "gui " wt-docto.nome-abrev
            VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
            
            
        IF v_cod_empres_usuar = "10" THEN
        DO:
            FIND FIRST ems2mult.emitente NO-LOCK
                WHERE  emitente.nome-abrev  = wt-docto.nome-abrev NO-ERROR.  
            
            //tela ESPDOC001
            FIND FIRST esp-tipo-documento NO-LOCK NO-ERROR.


            //tela ESPDOC002
            FIND FIRST esp-tipo-doc NO-LOCK
                WHERE esp-tipo-doc.cod-emitente = string(emitente.cod-emitente) no-error.

/*             IF NOT AVAIL esp-tipo-doc THEN                                                                                                                                                                                                                             */
/*             DO:                                                                                                                                                                                                                                                        */
/*                                                                                                                                                                                                                                                                        */
/*                RUN setInterrompeCalculo IN h-BODI317ef (INPUT YES).                                                                                                                                                                                                    */
/*                RUN _insertErrorManual IN h-BODI317ef (INPUT 9999,                                                                                                                                                                                                      */
/*                                          INPUT "EPC",                                                                                                                                                                                                                  */
/*                                          INPUT "ERROR",                                                                                                                                                                                                                */
/*                                          INPUT "Nota nÆo Efetivada",                                                                                                                                                                                                   */
/*                                          INPUT "*** Para emissÆo do pedido de venda/Faturamento deve ter o documento, Ëdocumento necess rioÌ com data de validade dentro do prazo na tela ESPDOC002. Solicitar atualiza‡Æo do documento para o setor respons vel.***", */
/*                                          INPUT "").                                                                                                                                                                                                                    */
/*                                                                                                                                                                                                                                                                        */
/*                 RETURN "NOK"    .                                                                                                                                                                                                                                      */
/*                                                                                                                                                                                                                                                                        */
/*             END.                                                                                                                                                                                                                                                       */
            
            // trava bloquei de cr‚dito
            

            FIND FIRST cst_cliente_bloqueio NO-LOCK
                WHERE cst_cliente_bloqueio.cod-emitente = string(emitente.cod-emitente) no-error.
                
            IF AVAIL cst_cliente_bloqueio AND
               cst_cliente_bloqueio.bloqueio = YES AND 
               cst_cliente_bloqueio.dt_fim > TODAY - 1
               THEN DO:
               
                RUN _insertErrorManual IN h-BODI317ef (INPUT 9999,
                                         INPUT "EPC",
                                         INPUT "ERROR",
                                         INPUT "*** Cliente " + emitente.nome-abrev + "tem bloqueio de vendas (ESCM0201) .*** ", 
                                         INPUT "",
                                         INPUT "").
                                         
                RETURN "NOK"    .            
                
            END.
            
            IF AVAIL cst_cliente_bloqueio AND
               cst_cliente_bloqueio.bloqueio = YES AND 
               cst_cliente_bloqueio.dt_fim = ?
               THEN DO:
               
                RUN _insertErrorManual IN h-BODI317ef (INPUT 9999,
                                         INPUT "EPC",
                                         INPUT "ERROR",
                                         INPUT "*** Cliente " + emitente.nome-abrev + "est  sem data de fim (ESCM0201) .*** ", 
                                         INPUT "",
                                         INPUT "").
                                         
                RETURN "NOK"    .            
                
            END.
            
            IF AVAIL esp-tipo-doc AND esp-tipo-doc.Data-validade < TODAY - 1 THEN
            DO:

               RUN setInterrompeCalculo IN h-BODI317ef (INPUT YES). 
               RUN _insertErrorManual IN h-BODI317ef (INPUT 9999,
                                         INPUT "EPC",
                                         INPUT "ERROR",
                                         INPUT "Documento com data de validade vencida",
                                         INPUT "*** Para emissÆo do pedido de venda/Faturamento deve ter o documento, Ëdocumento necess rioÌ com data de validade dentro do prazo na tela ESPDOC002. Solicitar atualiza‡Æo do documento para o setor respons vel.***",
                                         INPUT "").

                RETURN "NOK"    .

            END.

            IF AVAIL esp-tipo-doc AND esp-tipo-doc.bloqueia-vendas = YES THEN
            DO:
                RUN setInterrompeCalculo IN h-BODI317ef (INPUT YES).
                RUN _insertErrorManual IN h-BODI317ef (INPUT 9999,
                                         INPUT "EPC",
                                         INPUT "ERROR",
                                         INPUT "Documento com Bloqueio vendas",
                                         INPUT "*** Para emissÆo do pedido de venda/Faturamento deve ter o documento, Ëdocumento necess rioÌ com data de validade dentro do prazo na tela ESPDOC002. Solicitar atualiza‡Æo do documento para o setor respons vel.***",
                                         INPUT "").

                RETURN "NOK"    .

            END.

            IF AVAIL esp-tipo-documento AND esp-tipo-documento.obrigatorio = YES THEN
            DO:

                IF AVAIL esp-tipo-doc AND NOT esp-tipo-doc.obrigatorio THEN    
                DO:
                
                    RUN _insertErrorManual IN h-BODI317ef (INPUT 9999,
                                         INPUT "EPC",
                                         INPUT "ERROR",
                                         INPUT "Documento obrigatorio nÆo vinculado", 
                                         INPUT "*** Para emissÆo do pedido de venda/Faturamento deve ter o documento, Ëdocumento necess rioÌ com data de validade dentro do prazo na tela ESPDOC002. Solicitar atualiza‡Æo do documento para o setor respons vel.***",
                                         INPUT "").
                                         
                    RETURN "NOK"    .
                    
                    
                END.
            END.
        END.    
    
    END.
    
    
/*     IF AVAIL tt-epc THEN DO:                                    */
/*         ASSIGN h-BODI317ef = HANDLE(tt-epc.val-parameter).      */
/*                                                                 */
/*         MESSAGE "entrou if avail epc"                           */
/*             VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.           */
/*                                                                 */
/*         if tt-epc.cod-parameter = "Rowid_wt-docto" then         */
/*             ASSIGN r-wt-docto = TO-ROWID(tt-epc.val-parameter). */
/*     END.                                                        */

/*     /* S¢ entra se tiver uma nota fiscal v lida */                    */
/*     IF r-wt-docto <> ? THEN DO:                                       */
/*         MESSAGE "entrou if r-wt-docto <> ?"                           */
/*             VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.                 */
/*                                                                       */
/*         FOR FIRST b-wt-docto NO-LOCK                                  */
/*             WHERE ROWID(b-wt-docto) = r-wt-docto:                     */
/*                                                                       */
/*             MESSAGE "entrou for first"                                */
/*                 VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.             */
/*                                                                       */
/*             FIND FIRST ems2mult.emitente NO-LOCK                      */
/*                 WHERE emitente.cod-emitente = b-wt-docto.cod-emitente */
/*                 NO-ERROR.                                             */
/*                                                                       */
/*             MESSAGE "Nota Fiscal: " b-wt-docto.cod-emitente           */
/*                 VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.             */
/*         END.                                                          */
/*     END.                                                              */

        
    
END.

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
      
      IF AVAIL it-nota-fisc AND 
         ( it-nota-fisc.cod-estabel = "973" OR it-nota-fisc.cod-estabel = "977") THEN DO:

            assign l-int110 = no
                   i-cont   = 1.
            for-programa:
            repeat while program-name(i-cont) <> ?:
                if  program-name(i-cont) = "intprg/int110-todasrp.p" then do:
                    assign l-int110 = yes.
                    LEAVE for-programa.
                end.
                assign i-cont   =   i-cont  +   1.
            end.

          IF l-int110 THEN DO:
                RUN intupc/epc-bodi317ef-st.p (INPUT tt-epc.val-parameter,
                                         BUFFER it-nota-fisc).
          END.
      END.

      IF AVAIL it-nota-fisc and it-nota-fisc.cod-estabel <> "973" AND it-nota-fisc.cod-estabel = "977" THEN DO:
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


IF p-ind-event = "endEfetivaNota2" AND (SESSION:DISPLAY-TYPE  = 'gui':U OR OPSYS = "WIN32") THEN DO:
    //MESSAGE 'p-ind-event' p-ind-event VIEW-AS ALERT-BOX INFORMATION BUTTONS OK TITLE "bodi317ef".
    FIND FIRST tt-epc 
        WHERE tt-epc.cod-event = p-ind-event     
        AND   tt-epc.cod-param = "object-handle" 
        NO-ERROR.

   IF AVAILABLE tt-epc THEN DO:
      ASSIGN wh-bo = WIDGET-HANDLE(tt-epc.val-parameter).
   
      FOR EACH tt-notas-geradas:
          DELETE tt-notas-geradas.
      END.
          
      RUN buscaTTNotasGeradas IN wh-bo(OUTPUT l-proc-ok-aux, OUTPUT TABLE tt-notas-geradas).      

      FOR EACH tt-notas-geradas:

          FIND FIRST wt-docto 
               WHERE wt-docto.seq-wt-docto = tt-notas-geradas.seq-wt-docto 
               NO-LOCK NO-ERROR.

          FIND FIRST nota-fiscal 
               WHERE ROWID(nota-fiscal) = tt-notas-geradas.rw-nota-fiscal 
               NO-ERROR.

          IF AVAIL nota-fiscal  THEN DO:

             FIND FIRST es-param-integracao-estab
                  WHERE es-param-integracao-estab.cod-estabel =  nota-fiscal.cod-estabel 
                  AND   es-param-integracao-estab.empresa-integracao = 2
                  NO-LOCK NO-ERROR.

             IF AVAIL es-param-integracao-estab THEN do:

                RUN int\wsinventti0004.p  (input nota-fiscal.cod-estabel,
                                           input nota-fiscal.serie,      
                                           input nota-fiscal.nr-nota-fis).
             END.
          	 IF v_cod_empres_usuar = "10" THEN
                 ASSIGN nota-fiscal.observ-nota = nota-fiscal.observ-nota + ". Pedido: " +
                                                  nota-fiscal.nr-pedcli.  
		END.
      END.
   END.
END.

RETURN "OK".
     

