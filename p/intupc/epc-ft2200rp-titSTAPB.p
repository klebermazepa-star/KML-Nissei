DEF PARAM BUFFER bf-nota-fiscal FOR nota-fiscal.
    
DEF NEW GLOBAL SHARED VAR c-seg-usuario AS CHAR NO-UNDO.
DEF VAR c-erro AS CHAR.

DEF TEMP-TABLE tt-erro NO-UNDO
    FIELD i-seq    AS INT
    FIELD cd-erro  AS INT
    FIELD mensagem AS CHAR
    INDEX id IS PRIMARY i-seq.

{rep/re0402d.i1}
DEFINE VARIABLE l-estornou AS LOGICAL     NO-UNDO.

DEFINE VARIABLE hBufferTTErro      AS WIDGET-HANDLE NO-UNDO.

DEFINE VARIABLE i-parcela AS INTEGER     NO-UNDO.

ASSIGN i-parcela = 0.

FOR FIRST estabelec NO-LOCK
    WHERE estabelec.cod-emitente = bf-nota-fiscal.cod-emitente,
    EACH esp_param_unid_feder_tit_st NO-LOCK
    WHERE esp_param_unid_feder_tit_st.pais   = estabelec.pais
    AND   esp_param_unid_feder_tit_st.estado = estabelec.estado:
    
    ASSIGN i-parcela = i-parcela + 1.

    FIND LAST tit_ap USE-INDEX titap_id NO-LOCK
         WHERE tit_ap.cod_estab        = estabelec.cod-estabel
           AND tit_ap.cdn_fornecedor   = esp_param_unid_feder_tit_st.cdn_fornecedor
           AND tit_ap.cod_espec_docto  = esp_param_unid_feder_tit_st.cod_espec_docto
           AND tit_ap.cod_ser_docto    = bf-nota-fiscal.serie
           AND tit_ap.cod_tit_ap       = bf-nota-fiscal.nr-nota-fis
           AND tit_ap.cod_parcela      = STRING(i-parcela,"99") NO-ERROR.
    IF AVAIL tit_ap THEN DO:

        EMPTY TEMP-TABLE tt-erro.
        EMPTY TEMP-TABLE tt_cancelamento_estorno_apb_1.
        EMPTY TEMP-TABLE tt_estornar_agrupados.
        EMPTY TEMP-TABLE tt_log_erros_atualiz.
        EMPTY TEMP-TABLE tt_log_erros_estorn_cancel_apb.
        EMPTY TEMP-TABLE tt_estorna_tit_imptos.
        
        /*Cria tt estorno*/
        CREATE tt_cancelamento_estorno_apb_1.
        ASSIGN tt_cancelamento_estorno_apb_1.tta_cod_estab_ext      = estabelec.cod-estabel
               tt_cancelamento_estorno_apb_1.tta_cod_espec_docto    = esp_param_unid_feder_tit_st.cod_espec_docto
               tt_cancelamento_estorno_apb_1.tta_cod_ser_docto      = bf-nota-fiscal.serie
               tt_cancelamento_estorno_apb_1.tta_cod_tit_ap         = bf-nota-fiscal.nr-nota-fis
               tt_cancelamento_estorno_apb_1.tta_cdn_fornecedor     = esp_param_unid_feder_tit_st.cdn_fornecedor
               tt_cancelamento_estorno_apb_1.ttv_ind_niv_operac_apb = "Titulo" 
               tt_cancelamento_estorno_apb_1.ttv_ind_tip_operac_apb = "Cancelamento" 
               tt_cancelamento_estorno_apb_1.ttv_ind_tip_estorn     = "Total"  
               tt_cancelamento_estorno_apb_1.ttv_log_reaber_item    = NO
               tt_cancelamento_estorno_apb_1.ttv_log_reembol        = NO
               tt_cancelamento_estorno_apb_1.ttv_rec_tit_ap         = 0
               tt_cancelamento_estorno_apb_1.tta_cod_parcela        = STRING(i-parcela,"99").

        RUN prgfin/apb/apb768zd.py (INPUT 1,
                                    INPUT "APB",
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
    END.
END.

RETURN "OK".
