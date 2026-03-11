/******************************************************************************************
**  Programa: epc-re0402rp
******************************************************************************************/
              
{include/i-epc200.i epc-re0402rp}

DEF INPUT PARAM p-ind-event AS CHAR NO-UNDO.
DEF INPUT-OUTPUT PARAM TABLE FOR tt-epc. 
    
DEF NEW GLOBAL SHARED VAR c-seg-usuario AS CHAR NO-UNDO.

DEF BUFFER b-docum-est FOR docum-est.
DEF VAR c-erro AS CHAR.

DEF TEMP-TABLE tt-erro NO-UNDO
    FIELD i-seq    AS INT
    FIELD cd-erro  AS INT
    FIELD mensagem AS CHAR
    INDEX id IS PRIMARY i-seq.

{rep/re0402d.i1}
DEFINE VARIABLE l-estornou AS LOGICAL     NO-UNDO.

DEF BUFFER bf-tt-epc FOR tt-epc.
DEFINE VARIABLE hBufferTTErro      AS WIDGET-HANDLE NO-UNDO.

IF p-ind-event = "desatualiz-cr" 
THEN DO:

    FOR FIRST tt-epc WHERE 
              tt-epc.cod-event     = p-ind-event AND
              tt-epc.cod-parameter = "parametros" NO-LOCK:
    END.
    IF AVAIL tt-epc 
    THEN DO:
        FIND FIRST b-docum-est WHERE
                   ROWID(b-docum-est) = TO-ROWID(tt-epc.val-parameter) NO-LOCK NO-ERROR.
        IF AVAIL b-docum-est 
        THEN DO:
            IF CAN-FIND(FIRST estabelec 
                        WHERE estabelec.cod-estabel  = "973"
                        AND   estabelec.cod-emitente = b-docum-est.cod-emitente) THEN DO:
                FOR FIRST estabelec NO-LOCK
                    WHERE estabelec.cod-estabel = b-docum-est.cod-estabel,
                    FIRST esp_param_unid_feder_tit_st NO-LOCK
                    WHERE esp_param_unid_feder_tit_st.pais   = estabelec.pais
                    AND   esp_param_unid_feder_tit_st.estado = estabelec.estado,
                    FIRST natur-oper NO-LOCK
                    WHERE natur-oper.nat-operacao = b-docum-est.nat-operacao
                    AND   natur-oper.transf       = YES:

                    FIND LAST tit_ap USE-INDEX titap_id NO-LOCK
                         WHERE tit_ap.cod_estab        = b-docum-est.cod-estabel
                           AND tit_ap.cdn_fornecedor   = esp_param_unid_feder_tit_st.cdn_fornecedor
                           AND tit_ap.cod_espec_docto  = esp_param_unid_feder_tit_st.cod_espec_docto
                           AND tit_ap.cod_ser_docto    = b-docum-est.serie-docto
                           AND tit_ap.cod_tit_ap       = b-docum-est.nro-docto
                           AND tit_ap.cod_parcela      = STRING(1,"99") NO-ERROR.
                    IF AVAIL tit_ap THEN DO:
                
                        EMPTY TEMP-TABLE tt-erro.
                        EMPTY TEMP-TABLE tt_cancelamento_estorno_apb_1.
                        EMPTY TEMP-TABLE tt_estornar_agrupados.
                        EMPTY TEMP-TABLE tt_log_erros_atualiz.
                        EMPTY TEMP-TABLE tt_log_erros_estorn_cancel_apb.
                        EMPTY TEMP-TABLE tt_estorna_tit_imptos.
                        
                        /*Cria tt estorno*/
                        CREATE tt_cancelamento_estorno_apb_1.
                        ASSIGN tt_cancelamento_estorno_apb_1.tta_cod_estab_ext      = b-docum-est.cod-estabel
                               tt_cancelamento_estorno_apb_1.tta_cod_espec_docto    = esp_param_unid_feder_tit_st.cod_espec_docto
                               tt_cancelamento_estorno_apb_1.tta_cod_ser_docto      = b-docum-est.serie-docto
                               tt_cancelamento_estorno_apb_1.tta_cod_tit_ap         = b-docum-est.nro-docto
                               tt_cancelamento_estorno_apb_1.tta_cdn_fornecedor     = esp_param_unid_feder_tit_st.cdn_fornecedor
                               tt_cancelamento_estorno_apb_1.ttv_ind_niv_operac_apb = "Titulo" 
                               tt_cancelamento_estorno_apb_1.ttv_ind_tip_operac_apb = "Cancelamento" 
                               tt_cancelamento_estorno_apb_1.ttv_ind_tip_estorn     = "Total"  
                               tt_cancelamento_estorno_apb_1.ttv_log_reaber_item    = NO
                               tt_cancelamento_estorno_apb_1.ttv_log_reembol        = NO
                               tt_cancelamento_estorno_apb_1.ttv_rec_tit_ap         = 0
                               tt_cancelamento_estorno_apb_1.tta_cod_parcela        = STRING(1,"99").

                        RUN prgfin/apb/apb768zd.py (INPUT 1,
                                                    INPUT "REP",
                                                    INPUT "",
                                                    INPUT TABLE tt_cancelamento_estorno_apb_1,
                                                    INPUT TABLE tt_estornar_agrupados,
                                                    OUTPUT TABLE tt_log_erros_atualiz,
                                                    OUTPUT TABLE tt_log_erros_estorn_cancel_apb,
                                                    OUTPUT TABLE tt_estorna_tit_imptos,
                                                    OUTPUT l-estornou).
    
                        /*Tratamento de erro*/
                        FIND FIRST tt_log_erros_atualiz           NO-ERROR.
                        FIND FIRST tt_log_erros_estorn_cancel_apb NO-ERROR.
                        
                        IF  AVAIL tt_log_erros_atualiz OR
                            AVAIL tt_log_erros_estorn_cancel_apb THEN DO:
                            
                            /* Criacao dos erros do documento */
                            FOR EACH tt_log_erros_atualiz:
                                CREATE tt-erro.
                                ASSIGN tt-erro.cd-erro  = tt_log_erros_atualiz.ttv_num_mensagem
                                       tt-erro.mensagem = tt_log_erros_atualiz.ttv_des_msg_erro.
                            END.
                            
                            FOR EACH tt_log_erros_estorn_cancel_apb:
                                CREATE tt-erro.
                                ASSIGN tt-erro.cd-erro  = tt_log_erros_estorn_cancel_apb.tta_num_mensagem
                                       tt-erro.mensagem = tt_log_erros_estorn_cancel_apb.ttv_des_msg_erro.
                            END.
                        END.

                        IF RETURN-VALUE <> "OK" THEN DO:
                            FOR FIRST bf-tt-epc 
                                WHERE bf-tt-epc.cod-event     = "desatualiz-cr"
                                AND   bf-tt-epc.cod-parameter = "tt-erro":

                                ASSIGN hBufferTTErro = WIDGET-HANDLE(bf-tt-epc.val-parameter).


                                FOR EACH tt-erro:
                                    hBufferTTErro:BUFFER-CREATE().
                                    hBufferTTErro:BUFFER-FIELD("cd-erro" ):BUFFER-VALUE = tt-erro.cd-erro.
                                    hBufferTTErro:BUFFER-FIELD("mensagem"):BUFFER-VALUE = tt-erro.mensagem.
                                    
                                END.
                                

                            END.

                            CREATE bf-tt-epc.
                            ASSIGN bf-tt-epc.cod-event     = "desatualiz-cr"
                                   bf-tt-epc.cod-parameter = "tt-erro-return"
                                   bf-tt-epc.val-parameter = "Sim".

                            RETURN "NOK".
                        END.
                    END.
                END.
            END.
        END.
    END.
END. 

RETURN "OK".
     

