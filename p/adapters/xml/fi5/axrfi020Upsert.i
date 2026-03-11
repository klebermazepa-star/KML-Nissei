FOR EACH ttMovement:

    create tt_import_movto_fluxo_cx.
    assign tt_import_movto_fluxo_cx.tta_num_fluxo_cx              = ttMovement.CashFluxCode
           tt_import_movto_fluxo_cx.tta_dat_movto_fluxo_cx        = ttMovement.MovementDate
           tt_import_movto_fluxo_cx.tta_cod_estab                 = ttMovement.BranchCode
           tt_import_movto_fluxo_cx.tta_cod_unid_negoc            = ttMovement.BusinessUnitCode
           tt_import_movto_fluxo_cx.tta_cod_tip_fluxo_financ      = ttMovement.FinancialFluxType
           tt_import_movto_fluxo_cx.tta_ind_fluxo_movto_cx        = ttMovement.MovementFluxType
           tt_import_movto_fluxo_cx.tta_ind_tip_movto_fluxo_cx    = ttMovement.MovementType
           tt_import_movto_fluxo_cx.tta_cod_modul_dtsul           = ttMovement.ModuleCode
           tt_import_movto_fluxo_cx.tta_val_movto_fluxo_cx        = ttMovement.MovementValue
           tt_import_movto_fluxo_cx.tta_cod_histor_padr           = ttMovement.StandardHistoryCode
           tt_import_movto_fluxo_cx.tta_des_histor_movto_fluxo_cx = ttMovement.StandardHistoryDescription
           tt_import_movto_fluxo_cx.ttv_ind_erro_valid            = "nÆo"
           tt_import_movto_fluxo_cx.ttv_rec_movto_fluxo_cx        = recid(tt_import_movto_fluxo_cx).
END.

run prgfin/cfl/cfl724zb.py (input 1, 
                            input-output table tt_import_movto_fluxo_cx,
                            input-output table tt_import_movto_valid_cfl).

OUTPUT TO VALUE(SESSION:TEMP-DIRECTORY + "IMP-CFL-" + STRING(TODAY, "999999") + "-" + REPLACE(STRING(TIME, "HH:MM:SS"), ":" , "") + ".log")
          CONVERT TARGET "ISO8859-1".

IF NOT CAN-FIND(FIRST tt_import_movto_valid_cfl) THEN
    PUT UNFORMATTED "Importa‡Æo de Movimentos no Fluxo de Caixa realizado com sucesso!".
ELSE DO:
    PUT UNFORMATTED
        "Erros encontrados." SKIP(1).

    FOR EACH tt_import_movto_fluxo_cx WHERE
             tt_import_movto_fluxo_cx.ttv_ind_erro_valid = "sim":

        FOR EACH tt_import_movto_valid_cfl WHERE
                 tt_import_movto_valid_cfl.ttv_rec_movto_fluxo_cx = tt_import_movto_fluxo_cx.ttv_rec_movto_fluxo_cx:

            CREATE tt_log_erro.
            ASSIGN tt_log_erro.ttv_num_cod_erro  = tt_import_movto_valid_cfl.ttv_num_mensagem
                   tt_log_erro.ttv_des_msg_erro  = tt_import_movto_valid_cfl.ttv_des_mensagem.

            PUT UNFORMATTED
                "C¢digo do Erro:"
                    tt_import_movto_valid_cfl.ttv_num_mensagem       AT 19 SKIP
                "Mensagem de Erro:"
                    tt_import_movto_valid_cfl.ttv_des_mensagem       AT 19 SKIP
                "Estabelecimento:"
                    tt_import_movto_fluxo_cx.tta_cod_estab           AT 19 SKIP
                "Uniddade Neg¢cio:"
                    tt_import_movto_fluxo_cx.tta_cod_unid_negoc      AT 19 SKIP
                "Fluxo Caixa:"
                    tt_import_movto_fluxo_cx.tta_num_fluxo_cx        AT 19 SKIP
                "Data Movimento:"
                    STRING(tt_import_movto_fluxo_cx.tta_dat_movto_fluxo_cx, "99/99/9999") AT 19 SKIP
                "Tipo Fluxo:"
                    tt_import_movto_fluxo_cx.tta_cod_tip_fluxo_financ   AT 19 SKIP
                "Fluxo Movimento:"
                    tt_import_movto_fluxo_cx.tta_ind_fluxo_movto_cx     AT 19 SKIP
                "Tipo Movimento:"
                    tt_import_movto_fluxo_cx.tta_ind_tip_movto_fluxo_cx AT 19 SKIP
                "M¢dulo:"
                    tt_import_movto_fluxo_cx.tta_cod_modul_dtsul        AT 19 SKIP
                "Valor:"
                    TRIM(STRING(tt_import_movto_fluxo_cx.tta_val_movto_fluxo_cx, ">>,>>>,>>>,>>9.99")) AT 19 SKIP
                SKIP(1).
        END.
    END.
END.

OUTPUT CLOSE.
