
def var h_api_perm_estab as handle no-undo.
def new global shared  temp-table tt_estab_ems2 no-undo
    field tta_cod_estab as Character format "x(5)" label "Estabelecimento" column-label "Estab".

def temp-table tt_log_erro no-undo
    field ttv_num_cod_erro  as int  format ">>>>,>>9" label "N£mero"         column-label "N£mero"
    field ttv_des_msg_ajuda as char format "x(40)"    label "Mensagem Ajuda" column-label "Mensagem Ajuda"
    field ttv_des_msg_erro  as char format "x(60)"    label "Mensagem Erro"  column-label "Inconsistˆncia".

FIND ems2mult.param_seg_estab 
    &IF "{1}" = "MPD" &THEN
       WHERE param_seg_estab.cdn_param = 1001 /* Pedidos de Vendas*/
    &ENDIF                             
    &IF "{1}" = "MQO" &THEN
       WHERE param_seg_estab.cdn_param = 1002 /* Cota‡äes de Vendas */
    &ENDIF                             
    &IF "{1}" = "MEQ" &THEN
       WHERE param_seg_estab.cdn_param = 1003 /* Embarques */
    &ENDIF                             
    &IF "{1}" = "MFT" &THEN
       WHERE param_seg_estab.cdn_param = 1004 /* Faturamento */
    &ENDIF                             
    &IF "{1}" = "EQ1007" &THEN
       WHERE param_seg_estab.cdn_param = 1005 /* Programa EQ1007 do Modulo de Embarques */
    &ENDIF
    NO-LOCK NO-ERROR.

IF  AVAIL param_seg_estab
AND param_seg_estab.des_valor = "SIM":U
THEN DO:

    FOR EACH tt_estab_ems2:
        DELETE tt_estab_ems2.
    END.

    IF {2} THEN DO:
        run prgint/utb/utb746za.py persistent set h_api_perm_estab.
        run pi_retorna_estab_permissao_ems2 in h_api_perm_estab (output table tt_estab_ems2,
                                                                 output table tt_log_erro).
        DELETE PROCEDURE h_api_perm_estab.
        DO TRANS:
            FOR EACH ems2mult.seg_usuar_estab WHERE seg_usuar_estab.cod_usuar = c-seg-usuario 
                AND NOT CAN-FIND(FIRST tt_estab_ems2 WHERE tt_estab_ems2.tta_cod_estab = seg_usuar_estab.cod_estab) EXCLUSIVE-LOCK:
                DELETE seg_usuar_estab.
            END.
            FOR EACH tt_estab_ems2 WHERE NOT CAN-FIND(FIRST ems2mult.seg_usuar_estab WHERE seg_usuar_estab.cod_usuar = c-seg-usuario
                                                    AND seg_usuar_estab.cod_estab = tt_estab_ems2.tta_cod_estab):
                CREATE ems2mult.seg_usuar_estab.
                ASSIGN ems2mult.seg_usuar_estab.cod_usuar = c-seg-usuario
                       ems2mult.seg_usuar_estab.cod_estab = tt_estab_ems2.tta_cod_estab.
            END.
            RELEASE seg_usuar_estab.
        END.
    END.
    ELSE DO:
        FOR EACH ems2mult.seg_usuar_estab WHERE seg_usuar_estab.cod_usuar = c-seg-usuario NO-LOCK:
            CREATE tt_estab_ems2.
            ASSIGN tt_estab_ems2.tta_cod_estab = seg_usuar_estab.cod_estab.
        END.
    END.
END.

