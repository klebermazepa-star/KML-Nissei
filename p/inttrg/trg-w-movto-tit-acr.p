 /****************************************************************************************************
**   Programa: trg-w-movto-tit-acr.p - Trigger de write para a tabela movto_tit_acr
**   Objetivo: Atualizar as tabelas de transaá∆o da Geraá∆o de Titulo Pai
**   Data....: Junho/2016
*****************************************************************************************************/
DEF PARAM BUFFER b_movto_tit_acr     FOR movto_tit_acr.
DEF PARAM BUFFER b_old_movto_tit_acr FOR movto_tit_acr.

DEFINE NEW GLOBAL SHARED VARIABLE v_cod_empres_usuar AS CHARACTER FORMAT "x(3)":U NO-UNDO.
DEFINE VARIABLE iSeq  AS INTEGER     NO-UNDO.
DEFINE VARIABLE idSeq AS INTEGER  INITIAL "0"  NO-UNDO.

DEFINE BUFFER cliente          FOR ems5.cliente.
DEFINE BUFFER bf_tit_acr       FOR tit_acr.

IF  NEW b_movto_tit_acr                         AND
    b_movto_tit_acr.ind_trans_acr_abrev = "LIQ" AND
    b_movto_tit_acr.cod_espec_docto     = "CH"  THEN DO:

    FIND FIRST cheq_acr NO-LOCK
         WHERE cheq_acr.num_id_tit_acr = b_movto_tit_acr.num_id_tit_acr NO-ERROR.
    IF AVAIL cheq_acr THEN DO:
        ASSIGN idSeq = 0.

        FOR LAST int_ds_cheque_liq NO-LOCK:
            ASSIGN idSeq = int_ds_cheque_liq.id_seq + 1.
        END.

        IF idSeq = 0 THEN ASSIGN idSeq = 1.

        FIND FIRST int_ds_cheque_liq NO-LOCK
             WHERE int_ds_cheque_liq.id_seq = idSeq NO-ERROR.
        IF NOT AVAIL int_ds_cheque_liq THEN DO:
            CREATE int_ds_cheque_liq.
            ASSIGN int_ds_cheque_liq.id_seq = idSeq.

            ASSIGN int_ds_cheque_liq.cod_agenc_bcia = cheq_acr.cod_agenc_bcia 
                   int_ds_cheque_liq.cod_banco      = cheq_acr.cod_banco
                   int_ds_cheque_liq.cod_cta_corren = cheq_acr.cod_cta_corren_bco
                   int_ds_cheque_liq.cod_estabel    = cheq_acr.cod_estab
                   int_ds_cheque_liq.dat_compensa   = TODAY
                   int_ds_cheque_liq.num_cheque     = cheq_acr.num_cheque
                   int_ds_cheque_liq.situacao       = 1.   

            FIND FIRST cliente NO-LOCK
                 WHERE cliente.num_pessoa = cheq_acr.num_pessoa NO-ERROR.
            IF AVAIL cliente THEN
                ASSIGN int_ds_cheque_liq.cpf_cliente = cliente.cod_id_feder.

            FIND FIRST estabelecimento NO-LOCK
                 WHERE estabelecimento.cod_estab = cheq_acr.cod_estab NO-ERROR.
            IF AVAIL estabelecimento THEN
                ASSIGN int_ds_cheque_liq.cnpj_estab = estabelecimento.cod_id_feder.
        END.
    END.


END.

IF b_movto_tit_acr.ind_trans_acr_abrev = "ESTT" THEN DO:

    FIND FIRST tit_acr OF b_movto_tit_acr NO-LOCK NO-ERROR.
    IF AVAIL tit_acr THEN DO:

        IF tit_acr.cod_espec_docto = "CF" THEN DO:

            FIND FIRST int_ds_fat_convenio EXCLUSIVE-LOCK
                 WHERE int_ds_fat_convenio.nro_fatura   = tit_acr.cod_tit_acr  NO-ERROR.
            IF  AVAIL int_ds_fat_convenio THEN DO:
                ASSIGN int_ds_fat_convenio.tipo_movto         = 3 
                       int_ds_fat_convenio.situacao           = 1
                       int_ds_fat_convenio.ENVIO_STATUS       = 1.
            END.

            FIND FIRST renegoc_acr NO-LOCK
                 WHERE renegoc_acr.num_renegoc_cobr_acr = tit_acr.num_renegoc_cobr_acr NO-ERROR.
            IF AVAIL renegoc_acr THEN DO:

                FOR EACH estabelecimento NO-LOCK
                   WHERE estabelecimento.cod_empresa = v_cod_empres_usuar:
                    movto_tit_block:
                    for each movto_tit_acr no-lock 
                       where movto_tit_acr.cod_estab           = estabelecimento.cod_estab
                         and movto_tit_acr.cod_refer           = renegoc_acr.cod_refer
                         and movto_tit_acr.ind_trans_acr_abrev = "LQRN" /*l_lqrn*/ 
                        use-index mvtttcr_refer:

                        if movto_tit_acr.cod_estab_proces_bxa <> renegoc_acr.cod_estab then 
                            next movto_tit_block.

                        FIND FIRST bf_tit_acr use-index titacr_token 
                             WHERE bf_tit_acr.cod_estab      = movto_tit_acr.cod_estab 
                               AND bf_tit_acr.num_id_tit_acr = movto_tit_acr.num_id_tit_acr NO-ERROR.
                        IF AVAIL bf_tit_acr THEN DO:

                            ASSIGN iSeq = 0.
                            FOR LAST int_ds_canc_fat_conv_site NO-LOCK
                                  BY int_ds_canc_fat_conv_site.id_canc_fat_conv_site:
                                ASSIGN iSeq = int_ds_canc_fat_conv_site.id_canc_fat_conv_site + 1.
                            END.

                            IF iSeq = 0 THEN ASSIGN iSeq = 1.

                            FIND FIRST int_ds_canc_fat_conv_site NO-LOCK
                                 WHERE int_ds_canc_fat_conv_site.id_canc_fat_conv_site = iSeq  NO-ERROR.
                            IF NOT AVAIL int_ds_canc_fat_conv_site  THEN DO:

                                FIND FIRST cliente NO-LOCK
                                     WHERE cliente.cdn_cliente = tit_acr.cdn_cliente NO-ERROR.

                                FOR FIRST nota-fiscal NO-LOCK                                              
                                    WHERE nota-fiscal.cod-estabel = bf_tit_acr.cod_estab           
                                      AND nota-fiscal.serie       = bf_tit_acr.cod_ser_docto 
                                      AND nota-fiscal.nr-nota-fis = bf_tit_acr.cod_tit_acr,
                                    FIRST cst_nota_fiscal
                                    WHERE cst_nota_fiscal.cod_estabel = nota-fiscal.cod-estabel
                                      AND cst_nota_fiscal.serie       = nota-fiscal.serie
                                      AND cst_nota_fiscal.nr_nota_fis = nota-fiscal.nr-nota-fis NO-LOCK:

                                    CREATE int_ds_canc_fat_conv_site.
                                    ASSIGN int_ds_canc_fat_conv_site.id_canc_fat_conv_site = iSeq.
                                    ASSIGN int_ds_canc_fat_conv_site.cnpj               = IF AVAIL cliente THEN cliente.cod_id_feder ELSE ""
                                           int_ds_canc_fat_conv_site.cod_convenio       = INT(cst_nota_fiscal.convenio)
                                           int_ds_canc_fat_conv_site.cod_estabel        = bf_tit_acr.cod_estab 
                                           int_ds_canc_fat_conv_site.dat_estorno        = TODAY
                                           int_ds_canc_fat_conv_site.nro_cupom          = bf_tit_acr.cod_tit_acr 
                                           int_ds_canc_fat_conv_site.nro_fatura         = tit_acr.cod_tit_acr
                                           int_ds_canc_fat_conv_site.situacao           = 1.
                                END.
                            END.
                        END.
                    END.
                END.
            END.
        END.
        ELSE DO:
            FOR EACH cst_fat_duplic EXCLUSIVE-LOCK
             WHERE cst_fat_duplic.cod_estabel    = tit_acr.cod_estab
               AND cst_fat_duplic.num_id_tit_acr = tit_acr.num_id_tit_acr :
    
                ASSIGN cst_fat_duplic.num_id_tit_acr = ?.
            
                FIND FIRST fat-duplic 
                     WHERE fat-duplic.cod-estabel  = cst_fat_duplic.cod_estabel
                       AND fat-duplic.serie        = cst_fat_duplic.serie
                       AND fat-duplic.nr-fatura    = cst_fat_duplic.nr_fatura
                       AND fat-duplic.parcela      = cst_fat_duplic.parcela  EXCLUSIVE-LOCK NO-ERROR.
                IF AVAIL fat-duplic THEN DO:
                    ASSIGN fat-duplic.flag-atualiz = NO.

                    FIND FIRST nota-fiscal EXCLUSIVE-LOCK
                         WHERE nota-fiscal.cod-estabel = fat-duplic.cod-estabel
                           AND nota-fiscal.serie       = fat-duplic.serie
                           AND nota-fiscal.nr-nota-fis = fat-duplic.nr-fatura   NO-ERROR.
                    IF AVAIL nota-fiscal THEN DO:
                        ASSIGN nota-fiscal.dt-atual-cr = ?.
                    END.
                END.          
            END.
                        
            FOR EACH tit_acr_cartao
               WHERE tit_acr_cartao.cod_estab      = tit_acr.cod_estab      
                 AND tit_acr_cartao.num_id_tit_acr = tit_acr.num_id_tit_acr EXCLUSIVE-LOCK:
        
                DELETE tit_acr_cartao.
            END.  
        END.
    END.
    
    RELEASE fat-duplic.
    RELEASE cst_fat_duplic.  
    RELEASE tit_acr_cartao.     
    
END.

IF  NEW b_movto_tit_acr                         AND
    b_movto_tit_acr.ind_trans_acr_abrev = "LIQ" AND
    b_movto_tit_acr.cod_espec_docto     = "CF"  THEN DO:

    FIND FIRST tit_acr OF b_movto_tit_acr NO-LOCK NO-ERROR.
    IF AVAIL tit_acr THEN DO:
        FIND FIRST int_ds_fat_convenio
             WHERE int_ds_fat_convenio.nro_fatura   = tit_acr.cod_tit_acr  NO-ERROR.
        IF AVAIL int_ds_fat_convenio THEN DO:
            ASSIGN int_ds_fat_convenio.tipo_movto         = 4 
                   int_ds_fat_convenio.situacao           = 1
                   int_ds_fat_convenio.dat_liquidacao     = b_movto_tit_acr.dat_liquidac_tit_acr 
                   int_ds_fat_convenio.ENVIO_STATUS       = 1.
    
        END.
    END.
END.


IF  NEW b_movto_tit_acr                                 AND  // QUANDO O TITULO DE ESPECIE AV ê MOVIMENTADO 
    b_movto_tit_acr.ind_trans_acr_abrev    <> "IMPL"    AND  // CRIA TABELA DE INTEGRAÄ«O COM PROCFIT        
    b_movto_tit_acr.cod_espec_docto         = "AV"      AND 
    b_movto_tit_acr.log_ctbz_aprop_ctbl     = YES THEN DO: 

    FIND FIRST tit_acr OF b_movto_tit_acr NO-LOCK NO-ERROR.
    IF AVAIL tit_acr THEN DO:

        FIND FIRST estabelec NO-LOCK
            WHERE estabelec.cod-estabel = tit_acr.cod_estab NO-ERROR.

                
       FIND FIRST emitente NO-LOCK
           WHERE emitente.cod-emitente = tit_Acr.cdn_cliente NO-ERROR.
    
        IF AVAIL estabelec THEN DO:

            FIND FIRST int_dp_acordos_duplicatas NO-LOCK
                WHERE int_dp_acordos_duplicatas.cnpj_filial = estabelec.cgc
                  AND int_dp_acordos_duplicatas.especie     = b_movto_tit_acr.cod_espec_docto
                  AND int_dp_acordos_duplicatas.parcela     = string(int(tit_acr.cod_parcela))
                  AND int_dp_acordos_duplicatas.titulo      = tit_acr.cod_tit_acr
                  AND int_dp_acordos_duplicatas.serie       = tit_acr.cod_ser_docto 
                  AND int_dp_acordos_duplicatas.CNPJ_emitente = emitente.cgc   NO-ERROR.
    
            IF AVAIL int_dp_acordos_duplicatas THEN DO:

                CREATE int_dp_acordos_duplicatas_baixas.
                ASSIGN int_dp_acordos_duplicatas_baixas.titulo_receber     = int_dp_acordos_duplicatas.titulo_receber
                       int_dp_acordos_duplicatas_baixas.data_hora          = DATETIME(TODAY, MTIME)  
                       int_dp_acordos_duplicatas_baixas.data_transacao     = b_movto_tit_acr.dat_transacao 
                       int_dp_acordos_duplicatas_baixas.codigo_movimento   = b_movto_tit_acr.ind_trans_acr_abrev
                       int_dp_acordos_duplicatas_baixas.id_sequencial      = NEXT-VALUE(seq_acordos_dup_baixas)
                       int_dp_acordos_duplicatas_baixas.envio_status       = 1
                       int_dp_acordos_duplicatas_baixas.envio_data_hora    = DATETIME(TODAY, MTIME) 
                       int_dp_acordos_duplicatas_baixas.envio_erro         = " " 
                       int_dp_acordos_duplicatas_baixas.retorno_validacao  = "Titulo movimentado" 
                       .
        
                IF (b_movto_tit_acr.ind_trans_acr_abrev = "AVMN" OR
                    b_movto_tit_acr.ind_trans_acr_abrev = "LIQ"  OR
                    b_movto_tit_acr.ind_trans_acr_abrev = "LQEC" OR
                    b_movto_tit_acr.ind_trans_acr_abrev = "LQRN" OR
                    b_movto_tit_acr.ind_trans_acr_abrev = "LQTE" OR
                    b_movto_tit_acr.ind_trans_acr_abrev = "EVMN" OR
                    b_movto_tit_acr.ind_trans_acr_abrev = "REN" )
                    THEN DO:

                    ASSIGN int_dp_acordos_duplicatas_baixas.valor_debito       = b_movto_tit_acr.val_movto_tit_acr 
                           int_dp_acordos_duplicatas_baixas.valor_credito      = 0.

                END.
                ELSE DO:

                    ASSIGN int_dp_acordos_duplicatas_baixas.valor_debito       = 0 
                           int_dp_acordos_duplicatas_baixas.valor_credito      = b_movto_tit_acr.val_movto_tit_acr.

                END.


            END. // FIM - AVAIL int_dp_acordos_duplicatas

        END.   // FIM - AVAIL estabelec
        
    END.  // FIM - AVAIL tit_acr
END.

RETURN "OK".
