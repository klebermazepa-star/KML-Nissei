/******************************************************************************
**
**     Programa: UPC-BODI159COM.P
**     Objetivo: UPC para enviar pedido ao datahub.
**     Autor...: Kleber Mazepa - KML Consultoria
**     Versao..: 1.00.00.001
**     Alterac.: 
**
******************************************************************************/

{include/i-prgvrs.i UPC-BODI159COM 2.03.00.001}  /*** 010001 ***/
/* {include/i-epc200.i bodi159com} */
{include/i-epc200.i1}   /****** Definicao da temp-table tt-epc  ************/

DEF new global shared var v_cdn_empres_usuar  LIKE ems2mult.empresa.ep-codigo no-undo.

{utp/ut-glob.i}

def input param p-ind-event  as char no-undo. 
def input-output param table for tt-epc.

def var r-ped-venda      as rowid     no-undo.

DEF VAR h-bodi159com    AS HANDLE  NO-UNDO .
DEF VAR h-aloc          AS HANDLE  NO-UNDO .
DEF VAR de-qtd-saldo    AS DECIMAL NO-UNDO.

DEFINE BUFFER bf-ped-venda FOR ped-venda.
DEFINE BUFFER bf-ped-item  FOR ped-item.

.MESSAGE p-ind-event
    VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.

IF p-ind-event = 'afterCompleteOrder' THEN DO:
    
    FIND FIRST tt-epc 
        WHERE tt-epc.cod-event = p-ind-event 
          AND tt-epc.cod-parameter = "TABLE-ROWID" NO-ERROR.

    IF AVAIL tt-epc THEN
        ASSIGN r-ped-venda = TO-ROWID(tt-epc.val-parameter).
        
    IF r-ped-venda <> ? 
        AND v_cdn_empres_usuar = "10" THEN DO:
        
        FIND FIRST ped-venda NO-LOCK
            WHERE rowid(ped-venda)  = r-ped-venda NO-ERROR.
            
            
        IF AVAIL ped-venda THEN
        DO:
            IF ped-venda.cod-sit-aval <> 3 AND ped-venda.cod-sit-aval <> 2  THEN
                RUN custom/eswms003rp.p ( INPUT  r-ped-venda, "Pedido com Bloqueio de CrÇdito").  
            ELSE 
                RUN custom/eswms003rp.p ( INPUT  r-ped-venda, "Pedido Efetivado"). 
        END.
        
        
    END.

END.

IF p-ind-event = "beforeCompleteOrder" THEN DO:
    FIND FIRST tt-epc
        WHERE tt-epc.cod-event     = "beforeCompleteOrder"
        AND   tt-epc.cod-parameter = "Object-Handle" NO-ERROR.
    IF AVAIL tt-epc THEN
        ASSIGN h-bodi159com = HANDLE(tt-epc.val-parameter) .

    FIND FIRST tt-epc
        WHERE tt-epc.cod-event     = "beforeCompleteOrder"
        AND   tt-epc.cod-parameter = "Table-Rowid" NO-ERROR.
    IF AVAIL tt-epc THEN
        ASSIGN r-ped-venda = TO-ROWID(tt-epc.val-parameter) .

    RUN pdp/pdapi002.p PERSISTENT SET h-aloc.

    IF r-ped-venda <> ? THEN DO:
        FOR FIRST bf-ped-venda NO-LOCK
            WHERE ROWID(bf-ped-venda) = r-ped-venda:
            
            // trava bloquei de crÇdito
            
            IF v_cod_empres_usuar = "10" THEN
            DO:
            
                FIND FIRST ems2mult.emitente NO-LOCK
                    WHERE emitente.nome-abrev = bf-ped-venda.nome-abrev NO-ERROR.
                FIND FIRST cst_cliente_bloqueio NO-LOCK
                    WHERE cst_cliente_bloqueio.cod-emitente = string(emitente.cod-emitente) no-error.
                    
                IF AVAIL cst_cliente_bloqueio AND
                   cst_cliente_bloqueio.bloqueio = YES AND 
                   cst_cliente_bloqueio.dt_fim > TODAY - 1
                   THEN DO:
                   
                    RUN _insertErrorManual IN h-bodi159com (INPUT 9999,
                                             INPUT "EPC",
                                             INPUT "ERROR",
                                             INPUT "*** Cliente " + bf-ped-venda.nome-abrev + "tem bloqueio de vendas (ESCM0201) .*** ", 
                                             INPUT "",
                                             INPUT "").
                                             
                    RETURN "NOK"    .            
                    
                END.  
                
                IF AVAIL cst_cliente_bloqueio AND
                   cst_cliente_bloqueio.bloqueio = YES AND 
                   cst_cliente_bloqueio.dt_fim = ?
                   THEN DO:
                   
                    RUN _insertErrorManual IN h-bodi159com (INPUT 9999,
                                             INPUT "EPC",
                                             INPUT "ERROR",
                                             INPUT "*** Cliente " + bf-ped-venda.nome-abrev + "esta sem data de fim (ESCM0201) .*** ", 
                                             INPUT "",
                                             INPUT "").
                                             
                    RETURN "NOK"    .            
                    
                END.

            
            
                //tela ESPDOC001
                FIND FIRST esp-tipo-documento NO-LOCK NO-ERROR.
                
                
                //tela ESPDOC002
                FIND FIRST esp-tipo-doc NO-LOCK
                    WHERE esp-tipo-doc.cod-emitente = string(emitente.cod-emitente) no-error.
                    
                
                
    /*             IF NOT AVAIL esp-tipo-doc THEN                                                                                                                                                                                                                             */
    /*             DO:                                                                                                                                                                                                                                                        */
    /*                                                                                                                                                                                                                                                                        */
    /*                RUN _insertErrorManual IN h-bodi159com (INPUT 9999,                                                                                                                                                                                                     */
    /*                                          INPUT "EPC",                                                                                                                                                                                                                  */
    /*                                          INPUT "ERROR",                                                                                                                                                                                                                */
    /*                                          INPUT "Pedido n∆o faturado",                                                                                                                                                                                                  */
    /*                                          INPUT "*** Para emiss∆o do pedido de venda/Faturamento deve ter o documento, Àdocumento necess†rioÃ com data de validade dentro do prazo na tela ESPDOC002. Solicitar atualizaá∆o do documento para o setor respons†vel.***", */
    /*                                          INPUT "").                                                                                                                                                                                                                    */
    /*                                                                                                                                                                                                                                                                        */
    /*                 RETURN "NOK"    .                                                                                                                                                                                                                                      */
    /*                                                                                                                                                                                                                                                                        */
    /*             END.                                                                                                                                                                                                                                                       */
                IF AVAIL esp-tipo-doc AND esp-tipo-doc.Data-validade < TODAY - 1 THEN
                DO:
                
                   RUN _insertErrorManual IN h-bodi159com (INPUT 9999,
                                             INPUT "EPC",
                                             INPUT "ERROR",
                                             INPUT "Documento com data de validade vencida", 
                                             INPUT "*** Para emiss∆o do pedido de venda/Faturamento deve ter o documento, Àdocumento necess†rioÃ com data de validade dentro do prazo na tela ESPDOC002. Solicitar atualizaá∆o do documento para o setor respons†vel.***",
                                             INPUT "").
                                             
                    RETURN "NOK"    .    
                    
                END.
                
                IF AVAIL esp-tipo-doc AND esp-tipo-doc.bloqueia-vendas = YES THEN
                DO:
                    RUN _insertErrorManual IN h-bodi159com (INPUT 9999,
                                             INPUT "EPC",
                                             INPUT "ERROR",
                                             INPUT "Documento com Bloqueio vendas", 
                                             INPUT "*** Para emiss∆o do pedido de venda/Faturamento deve ter o documento, Àdocumento necess†rioÃ com data de validade dentro do prazo na tela ESPDOC002. Solicitar atualizaá∆o do documento para o setor respons†vel.***",
                                             INPUT "").
                                             
                    RETURN "NOK"    .

                END.
                
                IF AVAIL esp-tipo-documento AND esp-tipo-documento.obrigatorio = YES THEN
                DO:
                
                    IF AVAIL esp-tipo-doc AND NOT esp-tipo-doc.obrigatorio THEN    
                    DO:
                    
                        RUN _insertErrorManual IN h-bodi159com (INPUT 9999,
                                             INPUT "EPC",
                                             INPUT "ERROR",
                                             INPUT "Documento obrigatorio n∆o vinculado", 
                                             INPUT "*** Para emiss∆o do pedido de venda/Faturamento deve ter o documento, Àdocumento necess†rioÃ com data de validade dentro do prazo na tela ESPDOC002. Solicitar atualizaá∆o do documento para o setor respons†vel.***",
                                             INPUT "").
                                             
                        RETURN "NOK"    .
                        
                        
                    END.
                    
                END.

            END.     

            FOR EACH bf-ped-item NO-LOCK OF bf-ped-venda:

                RUN pi-verifica-saldo IN h-aloc (INPUT bf-ped-item.it-codigo,
                                                 INPUT bf-ped-item.cod-refer,
                                                 INPUT bf-ped-venda.cod-estab,
                                                 INPUT TODAY,
                                                 OUTPUT de-qtd-saldo).
                                                 
                IF bf-ped-item.qt-pedida - bf-ped-item.qt-log-aloca <= de-qtd-saldo THEN
                    RETURN "OK".
                ELSE DO:
                    RUN _insertErrorManual IN h-bodi159com (INPUT 9999,
                                             INPUT "EPC",
                                             INPUT "ERROR",
                                             INPUT "*** Item " + bf-ped-item.it-codigo + "sem saldo em estoque disponivel.*** ", 
                                             INPUT "",
                                             INPUT "").
                                             
                    RETURN "NOK" .
                END.
            END.
               
        END.
    END.
END.
