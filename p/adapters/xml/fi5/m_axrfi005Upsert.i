if  cTranEvent = "add" or cTranAction = "add" then do:

    /* Tabelas envolvidas na substitui‡Æo
    
        tt_integr_apb_lote_fatura
        tt_integr_apb_item_lote_fatura
        tt_integr_apb_relacto_fatura
        tt_integr_apb_impto_impl_pend1
        
    Tabelas envolvidas na substitui‡Æo*/ 

    CREATE tt_integr_apb_lote_fatura. 
    ASSIGN tt_integr_apb_lote_fatura.tta_cod_estab                = BranchCode
           tt_integr_apb_lote_fatura.tta_cod_refer                = Reference
           tt_integr_apb_lote_fatura.tta_cod_espec_docto          = DocumentClassCode
           tt_integr_apb_lote_fatura.tta_dat_transacao            = TransactionDate
           tt_integr_apb_lote_fatura.tta_ind_origin_tit_ap        = "EXP"
           tt_integr_apb_lote_fatura.tta_val_tot_lote_impl_tit_ap = TransactionTotalValue
           tt_integr_apb_lote_fatura.tta_cod_empresa              = CompanyCode
           tt_integr_apb_lote_fatura.tta_cod_indic_econ           = CurrencyCode
           tt_integr_apb_lote_fatura.ttv_cod_empresa_ext          = ""
           tt_integr_apb_lote_fatura.tta_cod_finalid_econ_ext     = ""
           tt_integr_apb_lote_fatura.tta_cod_estab_ext            = ""
           tt_integr_apb_lote_fatura.ttv_log_atualiza_refer_apb   = yes
           tt_integr_apb_lote_fatura.ttv_log_elimina_lote         = no
           tt_integr_apb_lote_fatura.tta_cdn_fornecedor           = integer(SupplierCode)
           tt_integr_apb_lote_fatura.tta_num_fatur_ap             = InvoiceNumber 
           tt_integr_apb_lote_fatura.tta_qtd_parcela              = QuantityParcel 
           tt_integr_apb_lote_fatura.tta_cod_histor_padr          = StandardHistoryCode
           tt_integr_apb_lote_fatura.tta_cod_histor_padr_dupl     = StandartHistoryDescription
           tt_integr_apb_lote_fatura.ttv_ind_matriz_fornec        = SupplierMatrix
           tt_integr_apb_lote_fatura.ttv_rec_integr_apb_lote_impl = recid(tt_integr_apb_lote_fatura).

        for each ttAccountPayableDocumentI_00:

            create tt_integr_apb_item_lote_fatura. 
            assign tt_integr_apb_item_lote_fatura.ttv_rec_integr_apb_lote_impl  = recid(tt_integr_apb_lote_fatura)
                   tt_integr_apb_item_lote_fatura.tta_num_seq_refer             = integer(ttAccountPayableDocumentI_00.Sequence)
                   tt_integr_apb_item_lote_fatura.tta_cdn_fornecedor            = integer(ttAccountPayableDocumentI_00.SupplierCode)
                   tt_integr_apb_item_lote_fatura.tta_cod_ser_docto             = string(ttAccountPayableDocumentI_00.DocumentSerieCode)
                   tt_integr_apb_item_lote_fatura.tta_cod_tit_ap                = string(ttAccountPayableDocumentI_00.DocumentNumber)
                   tt_integr_apb_item_lote_fatura.tta_cod_parcela               = string(ttAccountPayableDocumentI_00.DocumentParcelNumber)
                   tt_integr_apb_item_lote_fatura.tta_dat_emis_docto            = ttAccountPayableDocumentI_00.PrintDate
                   tt_integr_apb_item_lote_fatura.tta_dat_vencto_tit_ap         = ttAccountPayableDocumentI_00.DueDate
                   tt_integr_apb_item_lote_fatura.tta_dat_prev_pagto            = ttAccountPayableDocumentI_00.PaymentForecastDate
                   tt_integr_apb_item_lote_fatura.tta_dat_desconto              = ttAccountPayableDocumentI_00.DiscountDate
                   tt_integr_apb_item_lote_fatura.tta_cod_indic_econ            = string(ttAccountPayableDocumentI_00.CurrencyCode)
                   tt_integr_apb_item_lote_fatura.tta_val_tit_ap                = ttAccountPayableDocumentI_00.DocumentValue
                   tt_integr_apb_item_lote_fatura.tta_cod_portador              = ttAccountPayableDocumentI_00.CollectorCode
                   tt_integr_apb_item_lote_fatura.ttv_rec_integr_apb_item_lote  = recid(tt_integr_apb_item_lote_fatura)
                   tt_integr_apb_item_lote_fatura.tta_val_desconto              = ttAccountPayableDocumentI_00.DiscountValue
                   tt_integr_apb_item_lote_fatura.tta_cod_cart_bcia             = ttAccountPayableDocumentI_00.PortfolioCode
                   tt_integr_apb_item_lote_fatura.tta_val_perc_desc             = ttAccountPayableDocumentI_00.DiscountPercentage
                   tt_integr_apb_item_lote_fatura.tta_num_dias_atraso           = integer(ttAccountPayableDocumentI_00.DaysLate)
                   tt_integr_apb_item_lote_fatura.tta_val_juros_dia_atraso      = ttAccountPayableDocumentI_00.DaysLateInterest
                   tt_integr_apb_item_lote_fatura.tta_val_perc_juros_dia_atraso = ttAccountPayableDocumentI_00.DayLateInterestPercentage
                   tt_integr_apb_item_lote_fatura.tta_val_perc_multa_atraso     = ttAccountPayableDocumentI_00.Penalty
                   tt_integr_apb_item_lote_fatura.tta_cod_apol_seguro           = string(ttAccountPayableDocumentI_00.InsurancePolicyNumber)
                   tt_integr_apb_item_lote_fatura.tta_cod_seguradora            = string(ttAccountPayableDocumentI_00.InsurerCode)
                   tt_integr_apb_item_lote_fatura.tta_cod_arrendador            = string(ttAccountPayableDocumentI_00.LessorCode)
                   tt_integr_apb_item_lote_fatura.tta_cod_contrat_leas          = string(ttAccountPayableDocumentI_00.LeasingContractNumber)
                   tt_integr_apb_item_lote_fatura.tta_des_text_histor           = string(ttAccountPayableDocumentI_00.StandartHistoryDescription)
                   tt_integr_apb_item_lote_fatura.ttv_qtd_parc_tit_ap           = ttAccountPayableDocumentI_00.ParcelQuantity
                   tt_integr_apb_item_lote_fatura.ttv_num_dias                  = integer(ttAccountPayableDocumentI_00.Days)
                   tt_integr_apb_item_lote_fatura.ttv_ind_vencto_previs         = string(ttAccountPayableDocumentI_00.DueForecastType)
                   tt_integr_apb_item_lote_fatura.tta_cod_forma_pagto           = string(ttAccountPayableDocumentI_00.PaymentMethodCode)
                   tt_integr_apb_item_lote_fatura.tta_val_cotac_indic_econ      = ttAccountPayableDocumentI_00.QuotationValue
                   tt_integr_apb_item_lote_fatura.ttv_num_ord_invest            = integer(ttAccountPayableDocumentI_00.InvestmentOrder)
                   tt_integr_apb_item_lote_fatura.ttv_val_1099                  = ttAccountPayableDocumentI_00.TenNineNineValue
                   tt_integr_apb_item_lote_fatura.tta_cod_tax_ident_number      = ttAccountPayableDocumentI_00.TaxIdentNumber
                   tt_integr_apb_item_lote_fatura.tta_ind_tip_trans_1099        = "".

            for each ttPendentTaxInformation
                where ttPendentTaxInformation.ttAccountPayableDocumentI_00ID = ttAccountPayableDocumentI_00.ttAccountPayableDocumentI_00ID:
    
                create tt_integr_apb_impto_impl_pend1.
                assign tt_integr_apb_impto_impl_pend1.ttv_rec_integr_apb_item_lote   = recid(tt_integr_apb_item_lote_fatura)
                       tt_integr_apb_impto_impl_pend1.ttv_rec_antecip_pef_pend       = ? 
                       tt_integr_apb_impto_impl_pend1.tta_cod_pais                   = CountryCode
                       tt_integr_apb_impto_impl_pend1.tta_cod_unid_federac           = ttPendentTaxInformation.StateCode
                       tt_integr_apb_impto_impl_pend1.tta_cod_imposto                = ttPendentTaxInformation.TaxCode
                       tt_integr_apb_impto_impl_pend1.tta_cod_classif_impto          = ttPendentTaxInformation.TaxClassification
                       tt_integr_apb_impto_impl_pend1.tta_cod_espec_docto            = ttPendentTaxInformation.DocumentClassCode
                       tt_integr_apb_impto_impl_pend1.tta_cod_ser_docto              = ttPendentTaxInformation.DocumentSerieCode
                       tt_integr_apb_impto_impl_pend1.tta_cod_tit_ap                 = ttPendentTaxInformation.DocumentNumber
                       tt_integr_apb_impto_impl_pend1.tta_cod_parcela                = ttPendentTaxInformation.DocumentParcelNumber
                       tt_integr_apb_impto_impl_pend1.tta_ind_clas_impto             = ttPendentTaxInformation.TaxClassification
                       tt_integr_apb_impto_impl_pend1.tta_cod_plano_cta_ctbl         = ttPendentTaxInformation.AccountPlanCode
                       tt_integr_apb_impto_impl_pend1.tta_cod_cta_ctbl               = ttPendentTaxInformation.AccountCode
                       tt_integr_apb_impto_impl_pend1.tta_val_rendto_tribut          = ttPendentTaxInformation.RevenueTax
                       tt_integr_apb_impto_impl_pend1.tta_val_deduc_inss             = ttPendentTaxInformation.INSSDeduction
                       tt_integr_apb_impto_impl_pend1.tta_val_deduc_depend           = ttPendentTaxInformation.DependentDeduction
                       tt_integr_apb_impto_impl_pend1.tta_val_deduc_pensao           = ttPendentTaxInformation.PensionDeduction
                       tt_integr_apb_impto_impl_pend1.tta_val_outras_deduc_impto     = ttPendentTaxInformation.OtherDeductions
                       tt_integr_apb_impto_impl_pend1.tta_val_base_liq_impto         = ttPendentTaxInformation.TaxBaseValue
                       tt_integr_apb_impto_impl_pend1.tta_val_aliq_impto             = ttPendentTaxInformation.TaxPercentage
                       tt_integr_apb_impto_impl_pend1.tta_val_impto_ja_recolhid      = ttPendentTaxInformation.PaidTax
                       tt_integr_apb_impto_impl_pend1.tta_val_imposto                = ttPendentTaxInformation.TaxValue
                       tt_integr_apb_impto_impl_pend1.tta_dat_vencto_tit_ap          = ttPendentTaxInformation.DueDate
                       tt_integr_apb_impto_impl_pend1.tta_cod_indic_econ             = ttPendentTaxInformation.CurrencyCode
                       tt_integr_apb_impto_impl_pend1.tta_val_impto_indic_econ_impto = ttPendentTaxInformation.EconomicPurposeValue
                       tt_integr_apb_impto_impl_pend1.tta_des_text_histor            = ""
                       tt_integr_apb_impto_impl_pend1.tta_cdn_fornec_favorec         = integer(ttPendentTaxInformation.SupplierCode)
                       tt_integr_apb_impto_impl_pend1.tta_val_deduc_faixa_impto      = ttPendentTaxInformation.DeductionValue
                       tt_integr_apb_impto_impl_pend1.tta_num_id_tit_ap              = 0
                       tt_integr_apb_impto_impl_pend1.tta_num_id_movto_tit_ap        = 0
                       tt_integr_apb_impto_impl_pend1.tta_num_id_movto_cta_corren    = 0
                       tt_integr_apb_impto_impl_pend1.tta_cod_pais_ext               = ""
                       tt_integr_apb_impto_impl_pend1.tta_cod_cta_ctbl_ext           = ""
                       tt_integr_apb_impto_impl_pend1.tta_cod_sub_cta_ctbl_ext       = ""
                       tt_integr_apb_impto_impl_pend1.ttv_cod_tip_fluxo_financ_ext   = "".
            end.
        end.

        for each ttRelactoAccountPayableDo_00:
            
            create tt_integr_apb_relacto_fatura. 
            assign tt_integr_apb_relacto_fatura.ttv_rec_integr_apb_lote_impl = recid(tt_integr_apb_lote_fatura)
                   tt_integr_apb_relacto_fatura.tta_cod_estab_tit_ap_pai     = ttRelactoAccountPayableDo_00.BranchCode
                   tt_integr_apb_relacto_fatura.tta_cdn_fornec_pai           = integer(ttRelactoAccountPayableDo_00.SupplierCode)
                   tt_integr_apb_relacto_fatura.tta_cod_espec_docto_nf       = ttRelactoAccountPayableDo_00.DocumentClassCode
                   tt_integr_apb_relacto_fatura.tta_cod_ser_docto_nf         = ttRelactoAccountPayableDo_00.DocumentSerieCode
                   tt_integr_apb_relacto_fatura.tta_cod_tit_ap               = ttRelactoAccountPayableDo_00.DocumentNumber
                   tt_integr_apb_relacto_fatura.tta_cod_parc_nf              = ttRelactoAccountPayableDo_00.DocumentParcelNumber
                   tt_integr_apb_relacto_fatura.tta_ind_motiv_acerto_val     = ttRelactoAccountPayableDo_00.CorrectValueReason
                   tt_integr_apb_relacto_fatura.ttv_log_bxo_estab_tit        = no.
        end.
        
    assign p_num_vers_integr_api = 1.

    /* INICIO - EXECUTANDO A API DE SUBSTITUI€ÇO */
    run prgfin/apb/apb925za.py persistent set v_hdl_apb925za.
    run pi_main_code_apb925za_03 in v_hdl_apb925za (Input p_num_vers_integr_api,
                                              Input table tt_integr_apb_lote_fatura,
                                              Input table tt_integr_apb_item_lote_fatura,
                                              Input table tt_integr_apb_relacto_fatura,
                                              Input table tt_integr_apb_impto_impl_pend1,
                                              input-output table tt_log_erros_atualiz,
                                              input-output table tt_params_generic_api).
    
    delete procedure v_hdl_apb925za no-error.
    /* FIM - EXECUTANDO A API DE SUBSTITUI€ÇO */

    output to value(session:temp-directory + "LOGS\" + "SUB-APB-" + string(today, "999999") + "-" + replace(string(time,"HH:MM:SS"),":","") + ".log")
        convert target "ISO8859-1" paged page-size 200.

    if not can-find(first tt_log_erros_atualiz) then do:
        put "Atualiza‡Æo dos T¡tulos por Substitui‡Æo Efetuada com Sucesso." at 01 skip. 
    end.
    else
        put unformatted
            "Erros encontrados" at 01 skip
            "--------------------------------------------------------" at 01 skip(1).

    for each tt_log_erros_atualiz no-lock:

        create tt_log_erro.
        assign tt_log_erro.ttv_num_cod_erro = tt_log_erros_atualiz.ttv_num_mensagem
               tt_log_erro.ttv_des_msg_erro = string(tt_log_erros_atualiz.ttv_des_msg_erro,"x(150)").
        
        if  tt_log_erros_atualiz.ttv_des_msg_ajuda <> "" then
            assign tt_log_erro.ttv_des_msg_erro = STRING(tt_log_erro.ttv_des_msg_erro                     + chr(10) +
                                                  tt_log_erros_atualiz.ttv_des_msg_ajuda                  + chr(10) +
                                                  "EST: " + tt_log_erros_atualiz.tta_cod_estab            + chr(10) +
                                                  "REF: " + tt_log_erros_atualiz.tta_cod_refer,"X(256)").

        put unformatted 
            "Estabelecimento: " at 01
            tt_log_erros_atualiz.tta_cod_estab at 18 skip
            "Referencia: " at 01
            tt_log_erros_atualiz.tta_cod_refer at 18 skip
            "Sequencia Refer: " at 01
            tt_log_erros_atualiz.tta_num_seq_refer at 18 skip
            "Nr Mensagem: " at 01
            tt_log_erros_atualiz.ttv_num_mensagem at 18 skip
            "Mensagem: " at 01
            tt_log_erros_atualiz.ttv_des_msg_erro at 18 skip
            "Ajuda: " at 01
            tt_log_erros_atualiz.ttv_des_msg_ajuda at 18 skip
            "Tipo Relacto: " at 01
            tt_log_erros_atualiz.ttv_ind_tip_relacto at 18 skip
            "Nr Relacto: " at 01
            tt_log_erros_atualiz.ttv_num_relacto at 18 skip(2).
        
    end.
    
    output close.
end.

