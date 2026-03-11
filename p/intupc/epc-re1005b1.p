/******************************************************************************************
**  Programa: epc-re1005b1
******************************************************************************************/
              
{include/i-epc200.i epc-re1005b1}

DEF INPUT PARAM p-ind-event AS CHAR NO-UNDO.
DEF INPUT-OUTPUT PARAM TABLE FOR tt-epc. 
    
DEF NEW GLOBAL SHARED VAR c-seg-usuario AS CHAR NO-UNDO.

DEF BUFFER bf-item-doc-est     FOR item-doc-est.
DEF BUFFER bf-docum-est        FOR docum-est.
DEF BUFFER bf-natur-oper       FOR natur-oper.
DEF BUFFER bf-esp-item-entr-st FOR esp-item-entr-st.
DEF BUFFER bf-emitente         FOR emitente.

DEFINE VARIABLE de-qtd-baixa-aux AS DECIMAL     NO-UNDO.
DEFINE VARIABLE de-base-sta-aux  AS DECIMAL     NO-UNDO.
DEFINE VARIABLE de-valor-sta-aux AS DECIMAL     NO-UNDO.
.MESSAGE "6 RE" VIEW-AS ALERT-BOX INFORMATION BUTTONS OK .
IF p-ind-event = "valida-matriz-rateio" THEN DO:
.MESSAGE "5 RE" VIEW-AS ALERT-BOX INFORMATION BUTTONS OK .
    FOR FIRST tt-epc 
        WHERE tt-epc.cod-event     = p-ind-event 
        AND   tt-epc.cod-parameter = "rowid item-doc-est" NO-LOCK:
        FOR FIRST bf-item-doc-est NO-LOCK
            WHERE ROWID(bf-item-doc-est)     = TO-ROWID(tt-epc.val-parameter),
            FIRST bf-natur-oper NO-LOCK
            WHERE bf-natur-oper.nat-operacao = bf-item-doc-est.nat-operacao
            AND   (   bf-natur-oper.tipo-compra = 1 
                   OR bf-natur-oper.tipo-compra = 3),
            FIRST bf-docum-est NO-LOCK
            WHERE bf-docum-est.cod-emitente = bf-item-doc-est.cod-emitente
            AND   bf-docum-est.serie-docto  = bf-item-doc-est.serie-docto 
            AND   bf-docum-est.nro-docto    = bf-item-doc-est.nro-docto   
            AND   bf-docum-est.nat-operacao = bf-item-doc-est.nat-operacao
            AND   bf-docum-est.cod-estabel = "973", // FIXO estabelcimento 973 A
            //FIRST bf-emitente NO-LOCK
            //WHERE bf-emitente.cod-emitente = bf-docum-est.cod-emitente,
            FIRST item-uf NO-LOCK
            WHERE item-uf.it-codigo       = bf-item-doc-est.it-codigo
            /*AND   item-uf.cod-estado-orig = bf-emitente.estado
            AND   item-uf.estado          = bf-docum-est.uf*/ :
            .MESSAGE "4 RE" VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
            IF NOT CAN-FIND (FIRST esp-item-entr-st
                             WHERE esp-item-entr-st.cod-estab        = bf-docum-est.cod-estabel
                             AND   esp-item-entr-st.cod-serie        = bf-docum-est.serie-docto
                             AND   esp-item-entr-st.cod-docto        = bf-docum-est.nro-docto
                             AND   esp-item-entr-st.cod-natur-operac = bf-docum-est.nat-operacao
                             AND   esp-item-entr-st.cod-emitente     = string(bf-docum-est.cod-emitente)
                             AND   esp-item-entr-st.cod-item         = bf-item-doc-est.it-codigo
                             AND   esp-item-entr-st.num-seq          = bf-item-doc-est.sequencia ) THEN DO:
           .MESSAGE "3 RE" VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
                CREATE esp-item-entr-st.
                ASSIGN esp-item-entr-st.cod-estab        = bf-docum-est.cod-estabel         
                       esp-item-entr-st.cod-serie        = bf-docum-est.serie-docto         
                       esp-item-entr-st.cod-docto        = bf-docum-est.nro-docto           
                       esp-item-entr-st.cod-natur-operac = bf-docum-est.nat-operacao        
                       esp-item-entr-st.cod-emitente     = string(bf-docum-est.cod-emitente)
                       esp-item-entr-st.cod-item         = bf-item-doc-est.it-codigo        
                       esp-item-entr-st.num-seq          = bf-item-doc-est.sequencia.
                .MESSAGE "2 RE" VIEW-AS ALERT-BOX INFORMATION BUTTONS OK .
                /*Buscar do registro de baixa de STA, para recria-lo*/
                IF CAN-FIND (FIRST esp-item-nfs-st NO-LOCK
                             WHERE esp-item-nfs-st.cod-estab-nfs = bf-docum-est.cod-estabel         
                               AND esp-item-nfs-st.cod-ser-nfs   = bf-item-doc-est.serie-comp
                               AND esp-item-nfs-st.cod-docto-nfs = bf-item-doc-est.nro-comp
                               AND esp-item-nfs-st.cod-item      = bf-item-doc-est.it-codigo
                               AND esp-item-nfs-st.num-seq-nfs   = bf-item-doc-est.seq-comp) THEN DO:
                               .MESSAGE "1 RE" VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
                               
                   FIND FIRST esp-item-nfs-st NO-LOCK
                        WHERE esp-item-nfs-st.cod-estab-nfs    = bf-docum-est.cod-estabel         
                          AND esp-item-nfs-st.cod-ser-nfs      = bf-item-doc-est.serie-comp
                          AND esp-item-nfs-st.cod-docto-nfs    = bf-item-doc-est.nro-comp
                          AND esp-item-nfs-st.cod-item         = bf-item-doc-est.it-codigo
                          AND esp-item-nfs-st.num-seq-nfs      = bf-item-doc-est.seq-comp NO-ERROR.
                
                   FIND FIRST bf-esp-item-entr-st NO-LOCK
                        WHERE bf-esp-item-entr-st.cod-estab        = esp-item-nfs-st.cod-estab-entr
                        AND   bf-esp-item-entr-st.cod-serie        = esp-item-nfs-st.cod-ser-entr 
                        AND   bf-esp-item-entr-st.cod-docto        = esp-item-nfs-st.cod-nota-entr
                        AND   bf-esp-item-entr-st.cod-natur-operac = esp-item-nfs-st.cod-natur-operac-entr
                        AND   bf-esp-item-entr-st.cod-emitente     = esp-item-nfs-st.cod-emitente-entr
                        AND   bf-esp-item-entr-st.cod-item         = esp-item-nfs-st.cod-item
                        AND   bf-esp-item-entr-st.num-seq          = esp-item-nfs-st.num-seq-item-entr NO-ERROR.
                   IF AVAIL bf-esp-item-entr-st THEN
                       ASSIGN esp-item-entr-st.dat-movto = bf-esp-item-entr-st.dat-movto.
                   ELSE
                       ASSIGN esp-item-entr-st.dat-movto = TODAY.
                
                   ASSIGN de-qtd-baixa-aux     = 0
                          de-base-sta-aux      = 0
                          de-valor-sta-aux     = 0.
                
                   /*Verificar se a quantidade total da baixa de saldo de STA ² inferior a quantidade da item-doc-est*/
                   /*Acumula base e valor para calculo proporcional, em caso de devolu»’o parcial*/
                   FOR EACH esp-item-nfs-st NO-LOCK
                      WHERE esp-item-nfs-st.cod-estab-nfs = bf-docum-est.cod-estabel         
                        AND esp-item-nfs-st.cod-ser-nfs   = bf-item-doc-est.serie-comp
                        AND esp-item-nfs-st.cod-docto-nfs = bf-item-doc-est.nro-comp
                        AND esp-item-nfs-st.cod-item      = bf-item-doc-est.it-codigo
                        AND esp-item-nfs-st.num-seq-nfs   = bf-item-doc-est.seq-comp:
                        ASSIGN de-qtd-baixa-aux     = de-qtd-baixa-aux     + esp-item-nfs-st.qtd-saida           /*Quantidade*/
                               de-base-sta-aux      = de-base-sta-aux      + esp-item-nfs-st.val-base-calc-impto /*Base ST*/
                               de-valor-sta-aux     = de-valor-sta-aux     + esp-item-nfs-st.val-impto           /*Valor ST*/.
                   END.
                
                   /*Se a devolu»’o for parcial, deve-se recriar o saldo calculando a propor»’o em rela»’o aos saldos baixados*/
                   IF de-qtd-baixa-aux > bf-item-doc-est.quantidade THEN DO:
                       ASSIGN esp-item-entr-st.qtd-sdo-final              = bf-item-doc-est.quantidade                                          /*Saldo Quantidade*/
                              esp-item-entr-st.qtd-sdo-orig               = bf-item-doc-est.quantidade                                          /*Quantidade*/
                              esp-item-entr-st.val-base-calc-impto        = (de-base-sta-aux / de-qtd-baixa-aux * bf-item-doc-est.quantidade)   /*Base STA*/
                              esp-item-entr-st.val-impto                  = (de-valor-sta-aux / de-qtd-baixa-aux * bf-item-doc-est.quantidade). /*Valor STA*/
                   END. /*IF de-qtd-baixa-aux > item-doc-est.quantidade*/
                   /*Se foi baixado saldo de STA menor ou igual a quantidade que estÿ sendo devolvida, os valor devem ser recriados conforme a baixa*/
                   ELSE DO:
                       FOR EACH esp-item-nfs-st NO-LOCK
                          WHERE esp-item-nfs-st.cod-estab-nfs = bf-docum-est.cod-estabel         
                            AND esp-item-nfs-st.cod-ser-nfs   = bf-item-doc-est.serie-comp
                            AND esp-item-nfs-st.cod-docto-nfs = bf-item-doc-est.nro-comp
                            AND esp-item-nfs-st.cod-item      = bf-item-doc-est.it-codigo
                            AND esp-item-nfs-st.num-seq-nfs   = bf-item-doc-est.seq-comp:
                
                           ASSIGN esp-item-entr-st.qtd-sdo-final              = esp-item-entr-st.qtd-sdo-final + esp-item-nfs-st.qtd-saida                  /*Saldo Quantidade*/
                                  esp-item-entr-st.qtd-sdo-orig               = esp-item-entr-st.qtd-sdo-orig + esp-item-nfs-st.qtd-saida                    /*Quantidade*/
                                  esp-item-entr-st.val-base-calc-impto        = esp-item-entr-st.val-base-calc-impto + esp-item-nfs-st.val-base-calc-impto  /*Base ST*/
                                  esp-item-entr-st.val-impto                  = esp-item-entr-st.val-impto + esp-item-nfs-st.val-impto.                     /*Valor ST*/
                       END. /*FOR EACH item-nfs-st*/
                   END. /*ELSE DO*/
                
                END. /*IF CAN-FIND (FIRST item-nfs-st NO-LOCK*/
                /*Caso n’o tenha NF origem, ou a NF origem n’o tenha baixado saldo STA, cria o saldo com os valores de entrada*/
                ELSE DO:
                    ASSIGN esp-item-entr-st.dat-movto           = TODAY
                           esp-item-entr-st.qtd-sdo-final       = bf-item-doc-est.quantidade
                           esp-item-entr-st.qtd-sdo-orig        = bf-item-doc-est.quantidade
                           esp-item-entr-st.val-base-calc-impto = bf-item-doc-est.base-subs[1]
                           esp-item-entr-st.val-impto           = bf-item-doc-est.vl-subs[1].
                
                    FOR FIRST item-nf-adc NO-LOCK
                        WHERE item-nf-adc.cod-estab        = bf-docum-est.cod-estabel
                          AND item-nf-adc.cod-serie        = bf-item-doc-est.serie-docto 
                          AND item-nf-adc.cod-nota-fisc    = bf-item-doc-est.nro-docto   
                          AND item-nf-adc.cdn-emitente     = bf-item-doc-est.cod-emitente
                          AND item-nf-adc.cod-natur-operac = bf-item-doc-est.nat-operacao
                          AND item-nf-adc.idi-tip-dado     = 1
                          AND item-nf-adc.num-seq          = 1
                          AND item-nf-adc.num-seq-item-nf  = bf-item-doc-est.sequencia
                          AND item-nf-adc.cod-item         = bf-item-doc-est.it-codigo: 
                        ASSIGN esp-item-entr-st.aliq-impto = item-nf-adc.val-aliq-icms-st. /*Aliquota ST*/ 
                    END.
                END.

                RELEASE esp-item-entr-st.
            END.
        END.
    END.
END. 

RETURN "OK".
     

