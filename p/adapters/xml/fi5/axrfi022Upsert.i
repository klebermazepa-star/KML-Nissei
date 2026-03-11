DEF VAR i_seq_movto AS INTEGER INITIAL 0 NO-UNDO.

FOR EACH ttMovement:

    ASSIGN i_seq_movto = i_seq_movto + 10.

    create tt_movto_cta_corren_import.
    assign tt_movto_cta_corren_import.tta_cod_cta_corren             = ttMovement.CurrentAccountCode
           tt_movto_cta_corren_import.tta_dat_movto_cta_corren       = ttMovement.MovementDate
           tt_movto_cta_corren_import.tta_num_seq_movto_cta_corren   = i_seq_movto
           tt_movto_cta_corren_import.tta_ind_tip_movto_cta_corren   = ttMovement.MovementType
           tt_movto_cta_corren_import.tta_cod_tip_trans_cx           = ttMovement.TransactionCashType
           tt_movto_cta_corren_import.tta_ind_fluxo_movto_cta_corren = ttMovement.MovementFluxType
           tt_movto_cta_corren_import.tta_cod_cenar_ctbl             = ttMovement.Scenario
           tt_movto_cta_corren_import.tta_cod_histor_padr            = ttMovement.StandardHistoryCode
           tt_movto_cta_corren_import.tta_val_movto_cta_corren       = ttMovement.MovementValue
           tt_movto_cta_corren_import.tta_cod_docto_movto_cta_bco    = ttMovement.BankDocumentReference
           tt_movto_cta_corren_import.tta_cod_modul_dtsul            = ttMovement.ModuleCode
           tt_movto_cta_corren_import.ttv_ind_erro_valid             = "NÆo"
           tt_movto_cta_corren_import.tta_des_histor_padr            = ttMovement.StandardHistoryDescription
           tt_movto_cta_corren_import.ttv_rec_movto_cta_corren       = recid(tt_movto_cta_corren_import).
    
    FOR EACH ttAppropriationInformation WHERE
             ttAppropriationInformation.ttMovementID = ttMovement.ttMovementID:

        CREATE tt_aprop_ctbl_cmg_imp.
        ASSIGN tt_aprop_ctbl_cmg_imp.ttv_rec_movto_cta_corren  = tt_movto_cta_corren_import.ttv_rec_movto_cta_corren
               tt_aprop_ctbl_cmg_imp.tta_ind_natur_lancto_ctbl = ttAppropriationInformation.ChargeNature
               tt_aprop_ctbl_cmg_imp.tta_cod_estab             = ttAppropriationInformation.BranchCode
               tt_aprop_ctbl_cmg_imp.tta_cod_plano_cta_ctbl    = ttAppropriationInformation.AccountPlanCode
               tt_aprop_ctbl_cmg_imp.tta_cod_cta_ctbl          = ttAppropriationInformation.AccountCode
               tt_aprop_ctbl_cmg_imp.tta_cod_unid_negoc        = ttAppropriationInformation.BusinessUnitCode
               tt_aprop_ctbl_cmg_imp.tta_cod_plano_ccusto      = ttAppropriationInformation.CostCenterPlanCode
               tt_aprop_ctbl_cmg_imp.tta_cod_ccusto            = ttAppropriationInformation.CostCenterCode
               tt_aprop_ctbl_cmg_imp.tta_val_movto_cta_corren  = ttAppropriationInformation.AppropriationValue
               tt_aprop_ctbl_cmg_imp.ttv_rec_aprop_ctbl_cmg    = RECID(tt_aprop_ctbl_cmg_imp).

        FOR EACH ttValue WHERE
                 ttValue.ttAppropriationInformationID = ttAppropriationInformation.ttAppropriationInformationID:

            CREATE tt_val_aprop_ctbl_cmg_import.
            ASSIGN tt_val_aprop_ctbl_cmg_import.tta_cod_finalid_econ       = ttValue.EconomicPurposeCode
                   tt_val_aprop_ctbl_cmg_import.tta_dat_cotac_indic_econ   = ttValue.QuotationDate
                   tt_val_aprop_ctbl_cmg_import.tta_val_cotac_indic_econ   = ttValue.QuotationValue
                   tt_val_aprop_ctbl_cmg_import.tta_val_movto_cta_corren   = ttValue.EconomicPurposeValue
                   tt_val_aprop_ctbl_cmg_import.ttv_rec_movto_cta_corren   = RECID(tt_movto_cta_corren_import)
                   tt_val_aprop_ctbl_cmg_import.ttv_rec_aprop_ctbl_cmg     = RECID(tt_aprop_ctbl_cmg_imp)
                   tt_val_aprop_ctbl_cmg_import.ttv_rec_val_aprop_ctbl_cmg = RECID(tt_val_aprop_ctbl_cmg_import).
        END.
    END.

    FOR EACH ttFinancialShareInformation WHERE
             ttFinancialShareInformation.ttMovementID = ttMovement.ttMovementID:
        
        create tt_rat_financ_cmg_import.
        assign tt_rat_financ_cmg_import.ttv_rec_movto_cta_corren  = recid(tt_movto_cta_corren_import)
               tt_rat_financ_cmg_import.tta_cod_estab             = ttFinancialShareInformation.BranchCode
               tt_rat_financ_cmg_import.tta_cod_unid_negoc        = ttFinancialShareInformation.BusinessUnitCode
               tt_rat_financ_cmg_import.tta_cod_tip_fluxo_financ  = ttFinancialShareInformation.FinancialFluxType
               tt_rat_financ_cmg_import.tta_val_movto_cta_corren  = ttFinancialShareInformation.FinancialShareValue.
    END.

END.

FOR EACH tt_import_movto_valid_cmg:
    DELETE tt_import_movto_valid_cmg.
END.

OUTPUT STREAM s_1
       TO VALUE(SESSION:TEMP-DIRECTORY + "IMP-CMG-" + STRING(TODAY, "999999") + "-" + REPLACE(STRING(TIME, "HH:MM:SS"), ":" , "") + ".log")
       CONVERT TARGET "ISO8859-1" paged page-size 66.

run prgfin/cmg/cmg719zf.py (input 1,
                            input YES,
                            input YES,
                            input-output table tt_movto_cta_corren_import,
                            input table tt_aprop_ctbl_cmg_imp,
                            input table tt_val_aprop_ctbl_cmg_import,
                            input table tt_rat_financ_cmg_import,
                            output table tt_import_movto_valid_cmg).

IF NOT CAN-FIND(FIRST tt_import_movto_valid_cmg) THEN
    PUT STREAM s_1 UNFORMATTED "Importa‡Æo de Movimentos no Caixa e Bancos realizado com sucesso!".
ELSE DO:
    
    FOR EACH tt_movto_cta_corren_import WHERE
             tt_movto_cta_corren_import.ttv_ind_erro_valid = "sim":

        FOR EACH tt_import_movto_valid_cmg WHERE
                 tt_import_movto_valid_cmg.ttv_rec_movto_cta_corren = tt_movto_cta_corren_import.ttv_rec_movto_cta_corren:
        
            CREATE tt_log_erro.
            ASSIGN tt_log_erro.ttv_num_cod_erro  = tt_import_movto_valid_cmg.ttv_num_mensagem
                   tt_log_erro.ttv_des_msg_erro  = tt_import_movto_valid_cmg.ttv_des_msg_erro +
                       " CONTA: " + tt_movto_cta_corren_import.tta_cod_cta_corren             +
                       " DATA: "  + STRING(tt_movto_cta_corren_import.tta_dat_movto_cta_corren, "99/99/9999") +
                       " SEQ: "   + STRING(tt_movto_cta_corren_import.tta_num_seq_movto_cta_corren).
        END.
    END.
END.

OUTPUT STREAM s_1 CLOSE.
