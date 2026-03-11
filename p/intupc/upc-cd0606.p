/**********************************************************************
**
**  Programa: upc-cd0606.p - UPC para o programa CD0606 
**              
**  Objetivo: Criar o campo Cancela Saldo Pedido de Venda
**
**  06/07/2017 - Hoepers: Criar campos Natureza Bonificaá∆o e Conta Bonificaá∆o
**********************************************************************/

DEFINE INPUT PARAMETER p-ind-event  AS CHARACTER.
DEFINE INPUT PARAMETER p-ind-object AS CHARACTER.
DEFINE INPUT PARAMETER p-wgh-object AS HANDLE.
DEFINE INPUT PARAMETER p-wgh-frame  AS WIDGET-HANDLE.
DEFINE INPUT PARAMETER p-cod-table  AS CHARACTER.
DEFINE INPUT PARAMETER p-row-table  AS ROWID.


/* Criar novo botao em tela */
RUN intupc\upc-cd0606-b.p (INPUT p-ind-event,
                        INPUT p-ind-object,
                        INPUT p-wgh-object,
                        INPUT p-wgh-frame,
                        INPUT p-cod-table,
                        INPUT p-row-table).             



DEFINE BUFFER b-natur-oper FOR natur-oper.

{utp/ut-glob.i}

DEFINE NEW GLOBAL SHARED VAR wh-can-sdo-ped-cd0606     AS WIDGET-HANDLE NO-UNDO.
DEFINE NEW GLOBAL SHARED VAR wh-log-bonif-cd0606       AS WIDGET-HANDLE NO-UNDO.
DEFINE NEW GLOBAL SHARED VAR wh-txt-cta-bonif-cd0606   AS WIDGET-HANDLE NO-UNDO.
DEFINE NEW GLOBAL SHARED VAR wh-cod-cta-bonif-cd0606   AS WIDGET-HANDLE NO-UNDO.

DEF VAR wgh-grupo AS WIDGET-HANDLE NO-UNDO.
DEF VAR wgh-child AS WIDGET-HANDLE NO-UNDO.
DEF VAR wgh-frame AS WIDGET-HANDLE NO-UNDO.

DEFINE VARIABLE v_cod_cta_ctbl     AS CHARACTER   NO-UNDO.
DEFINE VARIABLE v_titulo_cta_ctbl  AS CHARACTER   NO-UNDO.
DEFINE VARIABLE v_ind_finalid_cta  AS CHARACTER   NO-UNDO.
DEFINE VARIABLE v_num_tip_cta_ctbl AS INTEGER     NO-UNDO.
DEFINE VARIABLE v_num_sit_cta_ctbl AS INTEGER     NO-UNDO.
DEFINE VARIABLE h_api_cta_ctbl     AS HANDLE      NO-UNDO.

def temp-table tt_log_erro no-undo
    field ttv_num_cod_erro   as int  format ">>>>,>>9" label "N£mero"         column-label "N£mero"
    field ttv_des_msg_ajuda  as char format "x(40)"    label "Mensagem Ajuda" column-label "Mensagem Ajuda"
    field ttv_des_msg_erro   as char format "x(60)"    label "Mensagem Erro"  column-label "Inconsistància".

FIND b-natur-oper WHERE 
      ROWID(b-natur-oper) = p-row-table NO-LOCK NO-ERROR.

IF  p-ind-event  = "BEFORE-INITIALIZE" AND 
    p-ind-object = "CONTAINER"         THEN DO:     

    ASSIGN wgh-grupo = p-wgh-frame:FIRST-CHILD.
    IF  VALID-HANDLE(wgh-grupo) THEN DO:
        ASSIGN wgh-child = wgh-grupo:FIRST-CHILD. 
    
        encontra-frame:
        DO  WHILE VALID-HANDLE(wgh-child):
            CASE wgh-child:TYPE:
                 WHEN "frame" THEN DO:   
                    IF  wgh-child:NAME = "fpage3" THEN DO:

                        ASSIGN wgh-frame = wgh-child:HANDLE.
                        LEAVE encontra-frame.

                    END.
                END.
            END.
            ASSIGN wgh-child = wgh-child:NEXT-SIBLING NO-ERROR.
        END.
    END.
                          
    CREATE TOGGLE-BOX wh-can-sdo-ped-cd0606
    ASSIGN FRAME              = wgh-frame
           ROW                = 9
           COL                = 10.4
           VISIBLE            = YES
           SENSITIVE          = NO
           LABEL              = "Cancela Saldo Pedido de Venda".


    ASSIGN wgh-grupo = p-wgh-frame:FIRST-CHILD.
    IF  VALID-HANDLE(wgh-grupo) THEN DO:
        ASSIGN wgh-child = wgh-grupo:FIRST-CHILD. 
    
        encontra-frame:
        DO  WHILE VALID-HANDLE(wgh-child):
            CASE wgh-child:TYPE:
                 WHEN "frame" THEN DO:  
                    IF  wgh-child:NAME = "fpage1" THEN DO:

                        ASSIGN wgh-frame = wgh-child:HANDLE.
                        LEAVE encontra-frame.

                    END.
                END.
            END.
            ASSIGN wgh-child = wgh-child:NEXT-SIBLING NO-ERROR.
        END.
    END.
                          
    CREATE TOGGLE-BOX wh-log-bonif-cd0606
    ASSIGN NAME      = "wh-log-bonif-cd0606"
           FRAME     = wgh-frame
           ROW       = 1.5
           COL       = 60
           VISIBLE   = YES
           SENSITIVE = NO
           LABEL     = "Natureza Bonificaá∆o".


    create text wh-txt-cta-bonif-cd0606
    ASSIGN name         = "wh-txt-cta-bonif-cd0606"
           frame        = wgh-frame
           row          = 2.5
           format       = 'x(18)'
           col          = 47
           width        = 18
           screen-value = 'Conta Bonificaá∆o:'
           visible      = yes.
    
    create FILL-IN wh-cod-cta-bonif-cd0606
    ASSIGN name      = "wh-cod-cta-bonif-cd0606"
           frame     = wgh-frame
           width     = 20
           height    = .88
           column    = 60
           row       = 2.4
           format    = "X(20)"
           visible   = true
           sensitive = no.

       ON F5                    OF wh-cod-cta-bonif-cd0606 PERSISTENT RUN intupc/upc-cd0606-a.p.
       ON MOUSE-SELECT-DBLCLICK OF wh-cod-cta-bonif-cd0606 PERSISTENT RUN intupc/upc-cd0606-a.p. 
END.

IF  p-ind-event  = "AFTER-INITIALIZE" AND 
    p-ind-object = "CONTAINER" 
THEN DO:
    IF  VALID-HANDLE(wh-can-sdo-ped-cd0606)
    THEN
        ASSIGN wh-can-sdo-ped-cd0606:SENSITIVE = NO.

    IF  VALID-HANDLE(wh-cod-cta-bonif-cd0606)
    THEN
        ASSIGN wh-log-bonif-cd0606:SENSITIVE     = NO
               wh-cod-cta-bonif-cd0606:SENSITIVE = NO.
END.                                

IF  p-ind-event  = "BEFORE-ADD" AND 
    p-ind-object = "CONTAINER"
THEN DO:
    IF  VALID-HANDLE(wh-can-sdo-ped-cd0606)
    THEN DO:
        IF AVAIL b-natur-oper THEN DO:              
           IF  b-natur-oper.tipo = 2 /* Sa°da */
           AND (SUBSTR(b-natur-oper.nat-operacao,1,1) = "5" OR
                SUBSTR(b-natur-oper.nat-operacao,1,1) = "6" OR
                SUBSTR(b-natur-oper.nat-operacao,1,1) = "7") THEN
               ASSIGN wh-can-sdo-ped-cd0606:SENSITIVE = YES. 
           ELSE
               ASSIGN wh-can-sdo-ped-cd0606:SENSITIVE = NO. 
        END.
        ELSE
           ASSIGN wh-can-sdo-ped-cd0606:SENSITIVE = NO. 
    
        ASSIGN wh-can-sdo-ped-cd0606:CHECKED = NO. 
    END.

    IF  VALID-HANDLE(wh-cod-cta-bonif-cd0606)
    THEN
        ASSIGN wh-log-bonif-cd0606:SENSITIVE     = YES
               wh-cod-cta-bonif-cd0606:SENSITIVE = YES.
END.

IF  p-ind-event  = "AFTER-DISABLE" AND 
    p-ind-object = "CONTAINER" 
THEN DO:
    IF  VALID-HANDLE(wh-can-sdo-ped-cd0606)
    THEN
        ASSIGN wh-can-sdo-ped-cd0606:SENSITIVE = NO.

    IF  VALID-HANDLE(wh-cod-cta-bonif-cd0606)
    THEN
        ASSIGN wh-log-bonif-cd0606:SENSITIVE     = NO
               wh-cod-cta-bonif-cd0606:SENSITIVE = NO.
END.

IF  p-ind-event  = "AFTER-ENABLE" AND 
    p-ind-object = "CONTAINER"
THEN DO:
    IF  VALID-HANDLE(wh-can-sdo-ped-cd0606)
    THEN DO:
        IF AVAIL b-natur-oper THEN DO:              
           IF  b-natur-oper.tipo = 2 /* Sa°da */
           AND (SUBSTR(b-natur-oper.nat-operacao,1,1) = "5" OR
                SUBSTR(b-natur-oper.nat-operacao,1,1) = "6" OR
                SUBSTR(b-natur-oper.nat-operacao,1,1) = "7") THEN
              ASSIGN wh-can-sdo-ped-cd0606:SENSITIVE = YES. 
        END.
        ELSE
           ASSIGN wh-can-sdo-ped-cd0606:SENSITIVE = NO.
    END.

    IF  VALID-HANDLE(wh-cod-cta-bonif-cd0606)
    THEN
        ASSIGN wh-log-bonif-cd0606:SENSITIVE     = YES
               wh-cod-cta-bonif-cd0606:SENSITIVE = YES.
END.

IF  p-ind-event  = "AFTER-DISPLAY" AND 
    p-ind-object = "CONTAINER"     AND 
    AVAIL b-natur-oper 
THEN DO:
    FIND FIRST int_ds_natur_oper WHERE 
               int_ds_natur_oper.nat_operacao = b-natur-oper.nat-operacao 
               NO-LOCK NO-ERROR.

    IF  VALID-HANDLE(wh-can-sdo-ped-cd0606) 
    THEN DO:
        IF  AVAIL int_ds_natur_oper THEN
            ASSIGN wh-can-sdo-ped-cd0606:CHECKED = int_ds_natur_oper.canc_sdo_ped_venda.
        ELSE
            ASSIGN wh-can-sdo-ped-cd0606:CHECKED = NO.
    END.

    IF  VALID-HANDLE(wh-cod-cta-bonif-cd0606)
    THEN DO:
        IF  AVAIL int_ds_natur_oper 
        THEN DO:
            IF  int_ds_natur_oper.log_bonificacao = ?
            THEN
                ASSIGN wh-log-bonif-cd0606:CHECKED = NO.
            ELSE
                ASSIGN wh-log-bonif-cd0606:CHECKED = int_ds_natur_oper.log_bonificacao.

            ASSIGN wh-cod-cta-bonif-cd0606:SCREEN-VALUE = int_ds_natur_oper.cod_cta_transit_bonificacao.
        END.
        ELSE
            ASSIGN wh-log-bonif-cd0606:CHECKED          = NO
                   wh-cod-cta-bonif-cd0606:SCREEN-VALUE = "".
    END.
END.
       

IF  p-ind-event  = "BEFORE-ASSIGN" AND 
    p-ind-object = "CONTAINER"     AND
    AVAIL b-natur-oper 
THEN DO:
    IF  wh-cod-cta-bonif-cd0606:SCREEN-VALUE <> ""
    THEN DO:
        RUN prgint\utb\utb743za.py PERSISTENT SET h_api_cta_ctbl.

        ASSIGN v_cod_cta_ctbl = wh-cod-cta-bonif-cd0606:SCREEN-VALUE.
    
        run pi_busca_dados_cta_ctbl in h_api_cta_ctbl (INPUT        STRING(i-ep-codigo-usuario),  /* EMPRESA EMS2 */
                                                       INPUT        "",                           /* PLANO DE CONTAS */
                                                       INPUT-OUTPUT v_cod_cta_ctbl,               /* CONTA */
                                                       INPUT        TODAY,                        /* DATA TRANSACAO */   
                                                       OUTPUT       v_titulo_cta_ctbl,            /* DESCRICAO CONTA */
                                                       OUTPUT       v_num_tip_cta_ctbl,           /* TIPO DA CONTA */
                                                       OUTPUT       v_num_sit_cta_ctbl,           /* SITUACAO DA CONTA */
                                                       OUTPUT       v_ind_finalid_cta,            /* FINALIDADES DA CONTA */
                                                       OUTPUT TABLE tt_log_erro).                 /* ERROS */
        DELETE OBJECT h_api_cta_ctbl.

        IF  RETURN-VALUE <> "OK"
        THEN DO:
            RUN utp\ut-msgs.p (INPUT "show",
                               INPUT 17006,
                               INPUT "Conta de Bonificaá∆o n∆o cadastrada.").
            APPLY "entry" TO wh-cod-cta-bonif-cd0606.
            RETURN ERROR.
        END.
    END.
END.

IF  p-ind-event  = "AFTER-ASSIGN" AND 
    p-ind-object = "CONTAINER"    AND
    AVAIL b-natur-oper 
THEN DO:
    FIND FIRST int_ds_natur_oper WHERE 
               int_ds_natur_oper.nat_operacao = b-natur-oper.nat-operacao 
               EXCLUSIVE-LOCK NO-ERROR.
    IF  NOT AVAIL int_ds_natur_oper THEN DO:
        CREATE int_ds_natur_oper.
        ASSIGN int_ds_natur_oper.nat_operacao = b-natur-oper.nat-operacao.
    END.

    IF  VALID-HANDLE(wh-can-sdo-ped-cd0606)
    THEN
        ASSIGN int_ds_natur_oper.canc_sdo_ped_venda = wh-can-sdo-ped-cd0606:CHECKED.

    IF  VALID-HANDLE(wh-cod-cta-bonif-cd0606)
    THEN
        ASSIGN int_ds_natur_oper.log_bonificacao             = wh-log-bonif-cd0606:CHECKED
               int_ds_natur_oper.cod_cta_transit_bonificacao = wh-cod-cta-bonif-cd0606:SCREEN-VALUE.
END.

IF  p-ind-event = "AFTER-DESTROY-INTERFACE"
THEN
    ASSIGN wh-log-bonif-cd0606     = ?
           wh-txt-cta-bonif-cd0606 = ?
           wh-cod-cta-bonif-cd0606 = ?.

