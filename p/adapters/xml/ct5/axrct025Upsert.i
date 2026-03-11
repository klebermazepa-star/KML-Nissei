/* Lista de Lotes Cont†beis */
def var v_cod_msg as char no-undo.

FOR EACH ttGLBatchInformation:

    create tt_integr_lote_ctbl_1.
    assign tt_integr_lote_ctbl_1.tta_cod_modul_dtsul        = "FGL"
           tt_integr_lote_ctbl_1.ttv_rec_integr_lote_ctbl   = recID(tt_integr_lote_ctbl_1)
           tt_integr_lote_ctbl_1.tta_des_lote_ctbl          = ttGLBatchInformation.GLBatchDescription
           tt_integr_lote_ctbl_1.tta_cod_empresa            = ttGLBatchInformation.CompanyCode
           tt_integr_lote_ctbl_1.tta_dat_lote_ctbl          = IF ttGLBatchInformation.GLBatchDate = ? THEN TODAY ELSE ttGLBatchInformation.GLBatchDate
           tt_integr_lote_ctbl_1.ttv_ind_erro_valid         = "N∆o"
           tt_integr_lote_ctbl_1.tta_log_integr_ctbl_online = ttGLBatchInformation.IsOnlineAccounting.

    /* Lista de Lanáamentos do Lote */
    FOR EACH ttPosting WHERE
             ttPosting.ttGLBatchInformationID = ttGLBatchInformation.ttGLBatchInformationID:

        CREATE tt_integr_lancto_ctbl_1.
        ASSIGN tt_integr_lancto_ctbl_1.ttv_rec_integr_lancto_ctbl     = RECID(tt_integr_lancto_ctbl_1)
               tt_integr_lancto_ctbl_1.tta_cod_cenar_ctbl             = IF ttPosting.ScenarioCode = ? THEN "" ELSE ttPosting.ScenarioCode
               tt_integr_lancto_ctbl_1.ttv_rec_integr_lote_ctbl       = tt_integr_lote_ctbl_1.ttv_rec_integr_lote_ctbl
               /*tt_integr_lancto_ctbl_1.tta_log_lancto_conver          =
               tt_integr_lancto_ctbl_1.tta_log_lancto_apurac_restdo   =
               tt_integr_lancto_ctbl_1.tta_cod_rat_ctbl               =*/
               tt_integr_lancto_ctbl_1.tta_num_lancto_ctbl            = ttPosting.PostingNumber
               tt_integr_lancto_ctbl_1.ttv_ind_erro_valid             = "N∆o"
               tt_integr_lancto_ctbl_1.tta_dat_lancto_ctbl            = IF ttPosting.PostingDate = ? THEN TODAY ELSE ttPosting.PostingDate.


        /* Lista de Itens do Lanáamento */
        FOR EACH ttPostingItem WHERE
                 ttPostingItem.ttPostingID = ttPosting.ttPostingID:

            CREATE tt_integr_item_lancto_ctbl_1.
            ASSIGN tt_integr_item_lancto_ctbl_1.ttv_rec_integr_lancto_ctbl       = tt_integr_lancto_ctbl_1.ttv_rec_integr_lancto_ctbl
                   tt_integr_item_lancto_ctbl_1.tta_num_seq_lancto_ctbl          = ttPostingItem.PostingItemSequenceNumber
                   tt_integr_item_lancto_ctbl_1.ttv_rec_integr_item_lancto_ctbl  = RECID(tt_integr_item_lancto_ctbl_1)
                   tt_integr_item_lancto_ctbl_1.tta_ind_natur_lancto_ctbl        = IF ttPostingItem.PostingNature = 1 THEN
                                                                                       "DB"
                                                                                   ELSE
                                                                                       "CR"

                   tt_integr_item_lancto_ctbl_1.tta_cod_plano_cta_ctbl           = ttPostingItem.AccountPlanCode
                   tt_integr_item_lancto_ctbl_1.tta_cod_cta_ctbl                 = ttPostingItem.AccountCode
                   tt_integr_item_lancto_ctbl_1.tta_cod_plano_ccusto             = ttPostingItem.CostCenterPlanCode
                   tt_integr_item_lancto_ctbl_1.tta_cod_ccusto                   = ttPostingItem.CostCenterCode
                   tt_integr_item_lancto_ctbl_1.tta_cod_estab                    = ttPostingItem.BranchCode
                   tt_integr_item_lancto_ctbl_1.tta_cod_unid_negoc               = ttPostingItem.BusinessUnitCode
                   tt_integr_item_lancto_ctbl_1.tta_cod_histor_padr              = ttPostingItem.StandardHistoryCode
                   tt_integr_item_lancto_ctbl_1.tta_des_histor_lancto_ctbl       = ttPostingItem.StandardHistoryDescription
                   tt_integr_item_lancto_ctbl_1.tta_cod_espec_docto              = ttPostingItem.DocumentClassCode
                   tt_integr_item_lancto_ctbl_1.tta_dat_docto                    = ttPostingItem.DocumentDate
                   tt_integr_item_lancto_ctbl_1.tta_des_docto                    = ttPostingItem.DocumentNumber
                   tt_integr_item_lancto_ctbl_1.tta_cod_indic_econ               = ttPostingItem.CurrencyCode
                   tt_integr_item_lancto_ctbl_1.tta_dat_lancto_ctbl              = IF ttPostingItem.PostingItemDate = ? THEN TODAY ELSE ttPostingItem.PostingItemDate
                   tt_integr_item_lancto_ctbl_1.tta_qtd_unid_lancto_ctbl         = IF ttPostingItem.PostingItemQuantity = ? THEN 0 ELSE ttPostingItem.PostingItemQuantity
                   tt_integr_item_lancto_ctbl_1.tta_val_lancto_ctbl              = ttPostingItem.PostingItemValue
                   tt_integr_item_lancto_ctbl_1.ttv_ind_erro_valid               = "N∆o".
                   /*tt_integr_item_lancto_ctbl_1.tta_cod_imagem                   = */
                   /*tt_integr_item_lancto_ctbl_1.tta_num_seq_lancto_ctbl_cpart    =*/
                   /*tt_integr_item_lancto_ctbl_1.tta_cod_proj_financ              =*/

            /* Lista das Apropriaá‰es dos Itens */
            FOR EACH ttPostingAppropriation WHERE
                     ttPostingAppropriation.ttPostingItemID = ttPostingItem.ttPostingItemID:

                CREATE tt_integr_aprop_lancto_ctbl_1.
                ASSIGN tt_integr_aprop_lancto_ctbl_1.tta_num_id_aprop_lancto_ctbl     = ttPostingAppropriation.PostingAppropriationSequence
                       tt_integr_aprop_lancto_ctbl_1.tta_cod_finalid_econ             = "corrente"
                       tt_integr_aprop_lancto_ctbl_1.tta_cod_unid_negoc               = "000"

                       tt_integr_aprop_lancto_ctbl_1.tta_cod_plano_ccusto             = ""
                       tt_integr_aprop_lancto_ctbl_1.tta_cod_ccusto                   = ""
                     /*tt_integr_aprop_lancto_ctbl_1.tta_cod_plano_ccusto             = tt_integr_item_lancto_ctbl_1.tta_cod_plano_ccusto
                       tt_integr_aprop_lancto_ctbl_1.tta_cod_ccusto                   = tt_integr_item_lancto_ctbl_1.tta_cod_ccusto
                       tt_integr_aprop_lancto_ctbl_1.tta_qtd_unid_lancto_ctbl         =*/
                       
                       tt_integr_aprop_lancto_ctbl_1.tta_val_lancto_ctbl              = IF ttPostingAppropriation.PostingAppropriationValue = ? THEN
                                                                                            tt_integr_item_lancto_ctbl_1.tta_val_lancto_ctbl
                                                                                        ELSE
                                                                                            ttPostingAppropriation.PostingAppropriationValue
                       
                       tt_integr_aprop_lancto_ctbl_1.tta_dat_cotac_indic_econ         = IF ttPostingAppropriation.ExchangeDate = ? THEN
                                                                                            TODAY
                                                                                        ELSE
                                                                                            ttPostingAppropriation.ExchangeDate

                       tt_integr_aprop_lancto_ctbl_1.tta_val_cotac_indic_econ         = IF ttPostingAppropriation.ExchangeValue = ? THEN
                                                                                            1
                                                                                        ELSE
                                                                                            ttPostingAppropriation.ExchangeValue

                       tt_integr_aprop_lancto_ctbl_1.tta_ind_orig_val_lancto_ctbl     = IF ttPostingAppropriation.OriginValuePosting = ? then
                                                                                            "Autom†tico"
                                                                                        ELSE
                                                                                            ttPostingAppropriation.OriginValuePosting

                       tt_integr_aprop_lancto_ctbl_1.ttv_rec_integr_item_lancto_ctbl  = tt_integr_item_lancto_ctbl_1.ttv_rec_integr_item_lancto_ctbl
                       tt_integr_aprop_lancto_ctbl_1.ttv_rec_integr_aprop_lancto_ctbl = RECID(tt_integr_aprop_lancto_ctbl_1)
                       tt_integr_aprop_lancto_ctbl_1.ttv_ind_erro_valid               = "N∆o".
            END.
        END.
    END.
END.


ASSIGN v_nom_arquivo = SESSION:TEMP-DIRECTORY + "FGL_" + STRING(TODAY, "999999") + "_" + REPLACE(STRING(TIME, "HH:MM:SS"), ":" , "") + ".txt".

OUTPUT STREAM s_1 TO VALUE(v_nom_arquivo) CONVERT TARGET "utf-8".

run prgfin/fgl/fgl900zl.py (Input 3,
                            Input "Aborta Tudo",
                            Input YES,
                            Input 66,
                            Input "Apropriaá∆o",
                            Input "Com Erro",
                            Input yes,
                            Input yes,
                            input-output table tt_integr_lote_ctbl_1,
                            input-output table tt_integr_lancto_ctbl_1,
                            input-output table tt_integr_item_lancto_ctbl_1,
                            input-output table tt_integr_aprop_lancto_ctbl_1,
                            input-output table tt_integr_ctbl_valid_1).                            

OUTPUT STREAM s_1 CLOSE.

/*OS-DELETE VALUE(v_nom_arquivo) NO-ERROR.*/
                           

FOR EACH tt_integr_lote_ctbl_1:

    IF tt_integr_lote_ctbl_1.ttv_ind_erro_valid = "N∆o" THEN
        RUN setExtraInformation IN hMessageHandler (INPUT "LoteCriado",
                                                    INPUT tt_integr_lote_Ctbl_1.tta_num_lote_ctbl).
END.

if  v_nom_prog_upc  <> '' or
    v_nom_prog_appc <> '' or
    v_nom_prog_dpc  <> '' then do:

    for each tt_epc:
        delete tt_epc.
    end.

    create tt_epc.
    assign tt_epc.cod_event     = "axrct025"
           tt_epc.cod_parameter = "Valida Erros"
           tt_epc.val_parameter = STRING(TEMP-TABLE tt_log_erro:HANDLE).
           
end.

/* Begin_Include: i_exec_program_epc_custom */
if  v_nom_prog_upc <> '' then
do:
    run value(v_nom_prog_upc) (input 'axrct025',
                               input-output table tt_epc).
end.

if  v_nom_prog_appc <> '' then
do:
    run value(v_nom_prog_appc) (input 'axrct025',
                                input-output table tt_epc).
end.

&if '{&emsbas_version}' > '5.00' &then
if  v_nom_prog_dpc <> '' then
do:
    run value(v_nom_prog_dpc) (input 'axrct025',
                                input-output table tt_epc).
end.
&endif
/* End_Include: i_exec_program_epc_custom */

/* *******************************************************************
run prgfin/fgl/fgl900zg.py PERSISTENT SET h_prg_msg (Input 66,
                                                     Input "Apropriaá∆o",
                                                     Input "Com Erro",
                                                     Input YES,
                                                     Input YES).

******************************************************************* */

FOR EACH tt_integr_ctbl_valid_1:

    CREATE tt_log_erro.
    ASSIGN tt_log_erro.ttv_num_cod_erro = tt_integr_ctbl_valid_1.ttv_num_mensagem.

    assign v_cod_msg = 'messages/' 
                     + string(trunc(tt_integr_ctbl_valid_1.ttv_num_mensagem / 1000,0),'99') 
                     + '/msg' 
                     + string(tt_integr_ctbl_valid_1.ttv_num_mensagem, '99999'). 
    
    if  search(v_cod_msg + '.r') = ? and search(v_cod_msg + '.p') = ? 
    then do: 
        /* A mensagem &1 n∆o est† dispon°vel em seu ambiente ! */ 
        run pi_messages (input "show", 
                         input 3530, 
                         input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9", 
                                           tt_integr_ctbl_valid_1.ttv_num_mensagem)) /*msg_3530*/. 
        LEAVE.
    end /* if */. 

    run pi_messages (input "msg", 
                     input tt_integr_ctbl_valid_1.ttv_num_mensagem, 
                     input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")). 
    ASSIGN tt_log_erro.ttv_des_msg_erro = RETURN-VALUE.

    run pi_messages (input "help", 
                     input tt_integr_ctbl_valid_1.ttv_num_mensagem, 
                     input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")). 
    ASSIGN tt_log_erro.ttv_des_msg_erro = tt_log_erro.ttv_des_msg_erro + chr(10) + RETURN-VALUE.
  
END.

