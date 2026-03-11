if  cTranAction = "add" then do:

    block_1:
    do trans:
    
        assign v_cod_release      = "1.00.00.002":U
               v_dat_execution    = today
               v_hra_execution    = replace(string(time,"hh:mm:ss"),":","")
               v_nom_enterprise   = 'Datasul S.A.'
               v_nom_report_title = fill(" ", 40 - length(v_rpt_s_1_name)) + v_rpt_s_1_name
               v_nom_prog_ext     = "spp001aa":U.
    
        file-info:file-name = session:temp-directory + "LOGS\".
        if  file-info:full-pathname = ? then do:
            os-create-dir value(session:temp-directory + "LOGS\").
        end.
    
        output stream s_1 to value(session:temp-directory + "LOGS\" + "CARD-ACR-" + string(today, "999999") + "-" + replace(string(time,"HH:MM:SS"),":","") + ".log")
                convert target "ISO8859-1" paged page-size 200.
    
        view stream s_1 frame f_rpt_s_1_header_unique.
        hide stream s_1 frame f_rpt_s_1_footer_last_page.
        view stream s_1 frame f_rpt_s_1_footer_normal.
    
        empty temp-table tt_alter_tit_acr_base_5.
        empty temp-table tt_titulos_cartao.
        empty temp-table tt_log_erro.
        empty temp-table tt_erro_implanta.

        assign v_num_seq = 0.
    
        for each ttCardAccountReceivableIn_00 no-lock:
        
            /*****************************************************************************************/
            /** Validaá‰es para verificar se todos os valores obrigat¢rios foram enviados           **/
            /*****************************************************************************************/
            assign v_erro_codigo = 0
                   v_erro_descri = ""
                   v_ajuda       = "".
    
            if ttCardAccountReceivableIn_00.BranchCode = "" then do:
                assign v_erro_codigo = 0301
                       v_erro_descri = "O c¢digo do estabelecimento n∆o foi informado."
                       v_ajuda       = "O campo BranchCode do XML Ç de preenchimento obrigat¢rio, verifique.".
            end.
    
            if ttCardAccountReceivableIn_00.CardAuthorize = "" then do:
                assign v_erro_codigo = 0302
                       v_erro_descri = "O c¢digo de autorizaá∆o do cart∆o n∆o foi informado."
                       v_ajuda       = "O campo CardAuthorize do XML Ç de preenchimento obrigat¢rio, verifique.".
            end.
    
            if ttCardAccountReceivableIn_00.CompanyCode = "" then do:
                assign v_erro_codigo = 0303
                       v_erro_descri = "O c¢digo da empresa da operadora n∆o foi informado."
                       v_ajuda       = "O campo CompanyCode do XML Ç de preenchimento obrigat¢rio, verifique.".
            end.
    
            if ttCardAccountReceivableIn_00.DateSell = ? then do:
                assign v_erro_codigo = 0304
                       v_erro_descri = "A data de venda n∆o foi informada."
                       v_ajuda       = "O campo DateSell do XML Ç de preenchimento obrigat¢rio, verifique.".
            end.
    
            if ttCardAccountReceivableIn_00.DocumentClassCode = "" then do:
                assign v_erro_codigo = 0305
                       v_erro_descri = "O c¢digo da espÇcie do t°tulo n∆o foi informado."
                       v_ajuda       = "O campo DocumentClassCode do XML Ç de preenchimento obrigat¢rio, verifique.".
            end.
    
            if ttCardAccountReceivableIn_00.DocumentNumber = "" then do:
                assign v_erro_codigo = 0306
                       v_erro_descri = "O c¢digo do t°tulo n∆o foi informado."
                       v_ajuda       = "O campo DocumentNumber do XML Ç de preenchimento obrigat¢rio, verifique.".
            end.
    
            if ttCardAccountReceivableIn_00.DocumentParcelNumber = "" then do:
                assign v_erro_codigo = 0307
                       v_erro_descri = "O c¢digo da parcela n∆o foi informado."
                       v_ajuda       = "O campo DocumentParcelNumber do XML Ç de preenchimento obrigat¢rio, caso seja compra A VISTA informe 0 (zero).".
            end.
    
    
            if ttCardAccountReceivableIn_00.ProofSell = "" then do:
                assign v_erro_codigo = 0308
                       v_erro_descri = "O c¢digo do comprovante de venda n∆o foi informado."
                       v_ajuda       = "O campo ProofSell do XML Ç de preenchimento obrigat¢rio, verifique.".
            end.
    
            if v_erro_codigo <> 0 then do:
    
                create tt_log_erro.
                assign tt_log_erro.ttv_num_cod_erro = v_erro_codigo
                       tt_log_erro.ttv_des_msg_erro = v_erro_descri.

               create tt_erro_implanta.
                assign tt_erro_implanta.tta_cod_erro   = v_erro_codigo
                       tt_erro_implanta.tta_informacao = ttCardAccountReceivableIn_00.BranchCode        + "," +
                                                         ttCardAccountReceivableIn_00.DocumentClassCode + "," +
                                                         ttCardAccountReceivableIn_00.DocumentSerieCode + "," +
                                                         ttCardAccountReceivableIn_00.DocumentNumber    + "," +
                                                         ttCardAccountReceivableIn_00.CardAuthorize     + "," +
                                                         ttCardAccountReceivableIn_00.ProofSell         + "," +
                                                         ttCardAccountReceivableIn_00.CompanyCode       + "," +
                                                         ttCardAccountReceivableIn_00.ManagerNumber     + "," +
                                                         ""                                             + "," +
                                                         ""                                             + "," +
                                                         ""                                             + "," +
                                                         ttCardAccountReceivableIn_00.DocumentParcelNumber
                       tt_erro_implanta.tta_des_erro   = v_erro_descri
                       tt_erro_implanta.tta_ajuda      = v_ajuda.
    
                next.
            end.
    
            /*****************************************************************************************/
            /** Verifica se a Operadora esta cadastrada antes de efetuar o cadastro do titulo       **/
            /*****************************************************************************************/
            find first admdra_cart_esp 
                where admdra_cart_esp.cod_empresa = ttCardAccountReceivableIn_00.CompanyCode
                  and admdra_cart_esp.cod_estab   = ttCardAccountReceivableIn_00.BranchCode
                  and admdra_cart_esp.cod_admdra  = ttCardAccountReceivableIn_00.ManagerNumber
                no-lock no-error.
    
            if not avail admdra_cart_esp then do:
    
                create tt_log_erro.
                assign tt_log_erro.ttv_num_cod_erro = 0309
                       tt_log_erro.ttv_des_msg_erro = "A Operadora utilizada n∆o est† cadastrada. Operadora/Estab: " + ttCardAccountReceivableIn_00.ManagerNumber + "/" + ttCardAccountReceivableIn_00.BranchCode.
    
                create tt_erro_implanta.
                assign tt_erro_implanta.tta_cod_erro   = 0309
                       tt_erro_implanta.tta_informacao = ttCardAccountReceivableIn_00.BranchCode        + "," +
                                                         ttCardAccountReceivableIn_00.DocumentClassCode + "," +
                                                         ttCardAccountReceivableIn_00.DocumentSerieCode + "," +
                                                         ttCardAccountReceivableIn_00.DocumentNumber    + "," +
                                                         ttCardAccountReceivableIn_00.CardAuthorize     + "," +
                                                         ttCardAccountReceivableIn_00.ProofSell         + "," +
                                                         ttCardAccountReceivableIn_00.CompanyCode       + "," +
                                                         ttCardAccountReceivableIn_00.ManagerNumber     + "," +
                                                         ""                                             + "," +
                                                         ""                                             + "," +
                                                         ""                                             + "," +
                                                         ttCardAccountReceivableIn_00.DocumentParcelNumber
                       tt_erro_implanta.tta_des_erro   = "A Operadora utilizada n∆o est† cadastrada. Operadora/Estab: " + ttCardAccountReceivableIn_00.ManagerNumber + "/" + ttCardAccountReceivableIn_00.BranchCode
                       tt_erro_implanta.tta_ajuda      = "Efetue o cadastro da Operadora utilizando o programa BAS_ADMDRA_CART_ESP para que seja poss°vel implanta um t°tulo com a mesma.".
                       
                next.
            end.
                
            /*****************************************************************************************/
            /** Verifica se existe um t°tulo pai na tit_acr                                         **/
            /*****************************************************************************************/
            find first tit_acr where tit_acr.cod_estab       = ttCardAccountReceivableIn_00.BranchCode
                                 and tit_acr.cod_espec_docto = ttCardAccountReceivableIn_00.DocumentClassCode
                                 and tit_acr.cod_ser_docto   = ttCardAccountReceivableIn_00.DocumentSerieCode
                                 and tit_acr.cod_tit_acr     = ttCardAccountReceivableIn_00.DocumentNumber 
                                 and tit_acr.cod_parcela     = ttCardAccountReceivableIn_00.DocumentParcelNumber no-lock no-error.
    
            if not avail tit_acr then do:
    
                create tt_log_erro.
                assign tt_log_erro.ttv_num_cod_erro = 0310
                       tt_log_erro.ttv_des_msg_erro = "N∆o existe t°tulo cadastrado na tabela pai (tit_acr)".                                 
    
                create tt_erro_implanta.
                assign tt_erro_implanta.tta_cod_erro   = 0310
                       tt_erro_implanta.tta_informacao = ttCardAccountReceivableIn_00.BranchCode        + "," +
                                                         ttCardAccountReceivableIn_00.DocumentClassCode + "," +
                                                         ttCardAccountReceivableIn_00.DocumentSerieCode + "," +
                                                         ttCardAccountReceivableIn_00.DocumentNumber    + "," +
                                                         ttCardAccountReceivableIn_00.CardAuthorize     + "," +
                                                         ttCardAccountReceivableIn_00.ProofSell         + "," +
                                                         ""                                             + "," +
                                                         ""                                             + "," +
                                                         ""                                             + "," +
                                                         ""                                             + "," +
                                                         ""                                             + "," +
                                                         ttCardAccountReceivableIn_00.DocumentParcelNumber
                       tt_erro_implanta.tta_des_erro   = "N∆o existe t°tulo cadastrado na tabela pai (tit_acr)"
                       tt_erro_implanta.tta_ajuda      = "Para realizar a implantaá∆o de um t°tulo de cart∆o na tabela filho (tit_acr_cartao) Ç necess†rio que este t°tulo tenho um t°tulo pai na tabela pai (tit_acr)".
    
                next.
                
            end.
            else if avail tit_acr then do:
    
                /*****************************************************************************************/
                /** Verifica se a Pessoa Jur°dica Ç a mesma para o cliente e a operadora e se a         **/
                /** operadora Ç esta cadastrada como cliente                                            **/
                /*****************************************************************************************/
                find first ems.cliente where cliente.cdn_cliente = tit_acr.cdn_cliente no-lock no-error.
                if avail cliente then do:
                    if cliente.num_pessoa <> admdra_cart_esp.num_pessoa_jurid then do:
    
                        create tt_log_erro.
                        assign tt_log_erro.ttv_num_cod_erro = 0311
                               tt_log_erro.ttv_des_msg_erro = "Pessoa cadastrada para operadora Ç diferente da cadastrada para o cliente".
            
                        create tt_erro_implanta.
                        assign tt_erro_implanta.tta_cod_erro   = 0311
                               tt_erro_implanta.tta_informacao = ttCardAccountReceivableIn_00.BranchCode        + "," +
                                                                 ttCardAccountReceivableIn_00.DocumentClassCode + "," +
                                                                 ttCardAccountReceivableIn_00.DocumentSerieCode + "," +
                                                                 ttCardAccountReceivableIn_00.DocumentNumber    + "," +
                                                                 ttCardAccountReceivableIn_00.CardAuthorize     + "," +
                                                                 ttCardAccountReceivableIn_00.ProofSell         + "," +
                                                                 ""                                             + "," +
                                                                 ""                                             + "," +
                                                                 string(cliente.num_pessoa)                     + "," +
                                                                 ""                                             + "," +
                                                                 ""                                             + "," +
                                                                 ttCardAccountReceivableIn_00.DocumentParcelNumber
                               tt_erro_implanta.tta_des_erro   = "Pessoa cadastrada para operadora Ç diferente da cadastrada para o cliente"
                               tt_erro_implanta.tta_ajuda      = "A pessoa Jur°dica cadastrada para a Operadora de Cart∆o deve ser a mesma que foi cadastrada para o cliente do t°tulo pai (tit_acr), verifique as informaá‰es.".
                       
                        next.
                    end.
                end.
                else if not avail cliente then do:
                    
                        create tt_log_erro.
                        assign tt_log_erro.ttv_num_cod_erro = 0312
                               tt_log_erro.ttv_des_msg_erro = "Pessoa cadastrada para operadora n∆o Ç um cliente".
            
                        create tt_erro_implanta.
                        assign tt_erro_implanta.tta_cod_erro   = 0312
                               tt_erro_implanta.tta_informacao = ttCardAccountReceivableIn_00.BranchCode        + "," +
                                                                 ttCardAccountReceivableIn_00.DocumentClassCode + "," +
                                                                 ttCardAccountReceivableIn_00.DocumentSerieCode + "," +
                                                                 ttCardAccountReceivableIn_00.DocumentNumber    + "," +
                                                                 ttCardAccountReceivableIn_00.CardAuthorize     + "," +
                                                                 ttCardAccountReceivableIn_00.ProofSell         + "," +
                                                                 ""                                             + "," +
                                                                 ""                                             + "," +
                                                                 ""                                             + "," +
                                                                 string(admdra_cart_esp.num_pessoa_jurid)       + "," +
                                                                 ""                                             + "," +
                                                                 ttCardAccountReceivableIn_00.DocumentParcelNumber
                               tt_erro_implanta.tta_des_erro   = "Pessoa cadastrada para operadora n∆o Ç um cliente"
                               tt_erro_implanta.tta_ajuda      = "A pessoa informada para a operadora de cart∆o deve ser obrigat¢riamente um cliente, verifique o cadastro de clientes".
                       
                       next.
    
                end.
    
                /*****************************************************************************************/
                /** Valida se j† n∆o existe um t°tulo cadastrado com a mesma chave                      **/
                /*****************************************************************************************/
                
                FIND first tit_acr_cartao use-index concil_autom
                                          where tit_acr_cartao.cod_empresa           = ttCardAccountReceivableIn_00.CompanyCode
                                            and tit_acr_cartao.cod_admdra            = admdra_cart_esp.cod_admdra
                                            and tit_acr_cartao.cod_comprov_vda       = ttCardAccountReceivableIn_00.ProofSell
                                            and tit_acr_cartao.cod_autoriz_cartao_cr = ttCardAccountReceivableIn_00.CardAuthorize
                                            and tit_acr_cartao.dat_vda_cartao_cr     = ttCardAccountReceivableIn_00.DateSell
                                            and tit_acr_cartao.cod_parc              = ttCardAccountReceivableIn_00.DocumentParcelNumber
                                            and tit_acr_cartao.num_tot_parc          = integer(ttCardAccountReceivableIn_00.ParcelTotal)
                                            and tit_acr_cartao.cod_estab             = tit_acr.cod_estab NO-LOCK NO-ERROR.

                IF AVAIL tit_acr_cartao THEN DO:
                    create tt_log_erro.
                    assign tt_log_erro.ttv_num_cod_erro = 0313
                           tt_log_erro.ttv_des_msg_erro = "O T°tulo de Cart∆o j† est† cadastrado na tabela filho (tit_acr_cartao)." +
                                                          " EST: " + tit_acr.cod_estab        +
                                                          " ESP: " + tit_acr.cod_espec_docto  +
                                                          " SER: " + tit_acr.cod_ser_docto    +
                                                          " TIT: " + tit_acr.cod_tit_acr      +
                                                          " PAR: " + tit_acr.cod_parcela      +
                                                          " COMPROV: "  + ttCardAccountReceivableIn_00.ProofSell     +
                                                          " AUTORIZ: "  + ttCardAccountReceivableIn_00.CardAuthorize +
                                                          " DT VENDA: " + string(ttCardAccountReceivableIn_00.DateSell, "99/99/9999") +
                                                          " PARC: "     + ttCardAccountReceivableIn_00.DocumentParcelNumber +
                                                          " TOT PARC: " + ttCardAccountReceivableIn_00.ParcelTotal.
        
                    create tt_erro_implanta.
                    assign tt_erro_implanta.tta_cod_erro   = 0313
                           tt_erro_implanta.tta_informacao = tit_acr.cod_estab                              + "," +
                                                             ttCardAccountReceivableIn_00.DocumentClassCode + "," +
                                                             ttCardAccountReceivableIn_00.DocumentSerieCode + "," +
                                                             ttCardAccountReceivableIn_00.DocumentNumber    + "," +
                                                             ttCardAccountReceivableIn_00.CardAuthorize     + "," +
                                                             ttCardAccountReceivableIn_00.ProofSell         + "," +
                                                             ""                                             + "," +
                                                             ""                                             + "," +
                                                             "0"                                            + "," +
                                                             "0"                                            + "," +
                                                             ""                                             + "," +
                                                             ttCardAccountReceivableIn_00.DocumentParcelNumber
                           tt_erro_implanta.tta_des_erro   = "O T°tulo de Cart∆o j† est† cadastrado na tabela filho (tit_acr_cartao)"
                           tt_erro_implanta.tta_ajuda      = "O t°tulo processado j† esta cadastrado na tabela filho (tit_acr_cartao)".
                   
                   next.
                end.
                
                /* Barth - Foi colocada a validaá∆o acima para que veja verificada se o t°tulo j† existe.
                           Caso exista ir† gerar um erro.
                           A sequància ser† conforme validaá∆o abaixo onde ser† sempre pego a £ltima sequància
                           dentro do t°tulo pai e somado mais um */
                assign v_num_seq = 1.
                if can-find(first tit_acr_cartao where tit_acr_cartao.cod_estab      = tit_acr.cod_estab
                                                 and   tit_acr_cartao.num_id_tit_acr = tit_acr.num_id_tit_acr) then do:
                    
                    find last tit_acr_cartao where tit_acr_cartao.cod_estab      = tit_acr.cod_estab
                                              and   tit_acr_cartao.num_id_tit_acr = tit_acr.num_id_tit_acr no-error.

                    if avail tit_acr_cartao then
                        assign v_num_seq = tit_acr_cartao.num_seq + 1.
                end.


                if ttCardAccountReceivableIn_00.SituationAccount = "" then
                    assign v_ind_sit_tit_acr = "Aberto".
                else
                    assign v_ind_sit_tit_acr = ttCardAccountReceivableIn_00.SituationAccount.

                create tit_acr_cartao.
                assign tit_acr_cartao.cod_estab             = tit_acr.cod_estab
                       tit_acr_cartao.num_id_tit_acr        = tit_acr.num_id_tit_acr
                       tit_acr_cartao.num_seq               = v_num_seq
                       tit_acr_cartao.cod_admdra            = ttCardAccountReceivableIn_00.ManagerNumber
                       tit_acr_cartao.cod_empresa           = ttCardAccountReceivableIn_00.CompanyCode
                       tit_acr_cartao.cod_empresa           = tit_acr.cod_empresa
                       tit_acr_cartao.cod_autoriz_cartao_cr = ttCardAccountReceivableIn_00.CardAuthorize
                       tit_acr_cartao.cod_comprov_vda       = ttCardAccountReceivableIn_00.ProofSell
                       tit_acr_cartao.cod_parc              = tit_acr.cod_parcela
                       tit_acr_cartao.cod_res_vda           = ttCardAccountReceivableIn_00.SellResume
                       tit_acr_cartao.dat_cred_cartao_cr    = ttCardAccountReceivableIn_00.DateCredit
                       tit_acr_cartao.dat_vda_cartao_cr     = ttCardAccountReceivableIn_00.DateSell
                       tit_acr_cartao.ind_sit_tit_acr       = v_ind_sit_tit_acr
                       tit_acr_cartao.num_tot_parc          = integer(ttCardAccountReceivableIn_00.ParcelTotal)
                       tit_acr_cartao.val_comprov_vda       = ttCardAccountReceivableIn_00.ValueSellProof
                       tit_acr_cartao.val_des_admdra        = ttCardAccountReceivableIn_00.ValueManagerCard
                       tit_acr_cartao.cod_refer_lote_liq    = ttCardAccountReceivableIn_00.ReferCode
                       tit_acr_cartao.hra_atualiz           = REPLACE(STRING(TIME, "HH:MM:SS"), ":","")
                       tit_acr_cartao.dat_atualiz           = TODAY
                       tit_acr_cartao.cod_usuario           = v_cod_usuar_corren.

                assign v_tot_val_adm_cartao = v_tot_val_adm_cartao + ttCardAccountReceivableIn_00.ValueManagerCard.

                /*****************************************************************************************/
                /** Cria uma Temp-Table com os t°tulos para enviar Ö API de Alteraá∆o                   **/
                /*****************************************************************************************/
                find first tt_titulos_cartao where tt_titulos_cartao.cod_estab      = tit_acr.cod_estab      and
                                                   tt_titulos_cartao.num_id_tit_acr = tit_acr.num_id_tit_acr no-error.

                if not avail tt_titulos_cartao then do:
    
                    create tt_titulos_cartao.
                    assign tt_titulos_cartao.cod_estab          = tit_acr.cod_estab
                           tt_titulos_cartao.num_id_tit_acr     = tit_acr.num_id_tit_acr
                           tt_titulos_cartao.val_sdo_tit_acr    = tit_acr.val_sdo_tit_acr
                           tt_titulos_cartao.dat_vencto_tit_acr = tit_acr.dat_vencto_tit_acr
                           tt_titulos_cartao.dat_prev_liquidac  = tit_acr.dat_prev_liquidac.
                end.
                assign tt_titulos_cartao.tot_val_adm_cartao = tt_titulos_cartao.tot_val_adm_cartao + 
                                                              ttCardAccountReceivableIn_00.ValueManagerCard.

                if ttCardAccountReceivableIn_00.RestoreCard then
                    assign tt_titulos_cartao.val_ava_maior = tt_titulos_cartao.val_ava_maior + tit_acr_cartao.val_comprov_vda.
            end.
        end.
        /*Fim do For each ttCardAccountReceivableIn_00*/


        /*****************************************************************************************/
        /** Chama a API de Alteraá∆o para realizar um AVA MAIOR no t°tulo pai (tit_acr)        **/
        /*****************************************************************************************/

        for each tt_titulos_cartao where
                 tt_titulos_cartao.val_ava_maior > 0:
                 
           find first tit_acr where tit_acr.cod_estab      = tt_titulos_cartao.cod_estab     
                                and tit_acr.num_id_tit_acr = tt_titulos_cartao.num_id_tit_acr no-lock no-error.
	        
           if available tit_acr and tit_acr.val_sdo_tit_acr <= 0 then next.
           
           /****** Cria Referencia para alteraá∆o ******/
           assign v_log_refer_uni = no
                  v_cod_refer     = "".
           
           repeat while v_log_refer_uni = no:

               run pi_retorna_sugestao_referencia (Input "A", 
                                                   Input today,
                                                   output v_cod_refer).
    
               run pi_verifica_refer_unica_acr (input tt_titulos_cartao.cod_estab,
                                                input v_cod_refer,
                                                input '',
                                                input ?,
                                                output v_log_refer_uni).
           end.

           for each movto_tit_acr fields(movto_tit_acr.dat_transacao) use-index mvtttcr_id no-lock where
                    movto_tit_acr.cod_estab      = tt_titulos_cartao.cod_estab
                and movto_tit_acr.num_id_tit_acr = tt_titulos_cartao.num_id_tit_acr
                by  movto_tit_acr.dat_transacao descending:

               assign v_dat_transacao = movto_tit_acr.dat_transacao.
               leave.
           end.

           create tt_alter_tit_acr_base_5.
           assign tt_alter_tit_acr_base_5.tta_cod_estab                   = tt_titulos_cartao.cod_estab
                  tt_alter_tit_acr_base_5.tta_num_id_tit_acr              = tt_titulos_cartao.num_id_tit_acr
                  tt_alter_tit_acr_base_5.tta_dat_transacao               = v_dat_transacao
                  tt_alter_tit_acr_base_5.tta_cod_refer                   = v_cod_refer
                  tt_alter_tit_acr_base_5.tta_val_sdo_tit_acr             = (tt_titulos_cartao.val_sdo_tit_acr + tt_titulos_cartao.val_ava_maior)
                  tt_alter_tit_acr_base_5.ttv_cod_motiv_movto_tit_acr_alt = ?
                  tt_alter_tit_acr_base_5.ttv_cod_motiv_movto_tit_acr_imp = ?
                  tt_alter_tit_acr_base_5.tta_val_despes_bcia             = ?
                  tt_alter_tit_acr_base_5.tta_cod_agenc_cobr_bcia         = ?
                  tt_alter_tit_acr_base_5.tta_cod_tit_acr_bco             = ?
                  tt_alter_tit_acr_base_5.tta_dat_emis_docto              = ?
                  tt_alter_tit_acr_base_5.tta_dat_vencto_tit_acr          = tt_titulos_cartao.dat_vencto_tit_acr
                  tt_alter_tit_acr_base_5.tta_dat_prev_liquidac           = tt_titulos_cartao.dat_prev_liquidac
                  tt_alter_tit_acr_base_5.tta_dat_fluxo_tit_acr           = ?
                  tt_alter_tit_acr_base_5.tta_ind_sit_tit_acr             = ?
                  tt_alter_tit_acr_base_5.tta_cod_cond_cobr               = ?
                  tt_alter_tit_acr_base_5.tta_log_tip_cr_perda_dedut_tit  = ?  
                  tt_alter_tit_acr_base_5.tta_dat_abat_tit_acr            = ?
                  tt_alter_tit_acr_base_5.tta_val_abat_tit_acr            = ?
                  tt_alter_tit_acr_base_5.tta_dat_desconto                = ? 
                  tt_alter_tit_acr_base_5.tta_val_perc_desc               = ?
                  tt_alter_tit_acr_base_5.tta_val_desc_tit_acr            = ?
                  tt_alter_tit_acr_base_5.tta_qtd_dias_carenc_juros_acr   = ?
                  tt_alter_tit_acr_base_5.tta_val_perc_juros_dia_atraso   = ?
                  tt_alter_tit_acr_base_5.tta_val_perc_multa_atraso       = ?
                  tt_alter_tit_acr_base_5.tta_qtd_dias_carenc_multa_acr   = ?
                  tt_alter_tit_acr_base_5.tta_ind_ender_cobr              = ?
                  tt_alter_tit_acr_base_5.tta_nom_abrev_contat            = ?
                  tt_alter_tit_acr_base_5.tta_val_liq_tit_acr             = ?
                  tt_alter_tit_acr_base_5.tta_cod_instruc_bcia_1_movto    = ?
                  tt_alter_tit_acr_base_5.tta_cod_instruc_bcia_2_movto    = ?
                  tt_alter_tit_acr_base_5.ttv_des_text_histor             = ?
                  tt_alter_tit_acr_base_5.tta_ind_tip_cobr_acr            = ?
                  tt_alter_tit_acr_base_5.tta_log_tit_acr_destndo         = ?
                  tt_alter_tit_acr_base_5.tta_des_obs_cobr                = ?
                  tt_alter_tit_acr_base_5.tta_val_perc_abat_acr           = ?
                  tt_alter_tit_acr_base_5.tta_val_cr_pis                  = ?
                  tt_alter_tit_acr_base_5.tta_val_cr_cofins               = ?
                  tt_alter_tit_acr_base_5.tta_val_cr_csll                 = ?
                  tt_alter_tit_acr_base_5.tta_val_base_calc_impto         = ?
                  tt_alter_tit_acr_base_5.tta_log_retenc_impto_impl       = ? 
                  tt_alter_tit_acr_base_5.ttv_ind_motiv_acerto_val        = "Alteraá∆o" 
                  tt_alter_tit_acr_base_5.tta_cod_portador                = ?
                  tt_alter_tit_acr_base_5.tta_cod_cart_bcia               = ?
                  tt_alter_tit_acr_base_5.ttv_log_vendor                  = ?
                  tt_alter_tit_acr_base_5.ttv_cod_portador_mov            = ?
                  tt_alter_tit_acr_base_5.tta_cod_histor_padr             = ?
                  tt_alter_tit_acr_base_5.ttv_wgh_lista                   = ?
                  tt_alter_tit_acr_base_5.tta_num_seq_tit_acr             = ?
                  tt_alter_tit_acr_base_5.ttv_cod_estab_planilha          = ?
                  tt_alter_tit_acr_base_5.ttv_num_planilha_vendor         = ?
                  tt_alter_tit_acr_base_5.ttv_cod_cond_pagto_vendor       = ?
                  tt_alter_tit_acr_base_5.ttv_val_cotac_tax_vendor_clien  = ?
                  tt_alter_tit_acr_base_5.ttv_dat_base_fechto_vendor      = ?
                  tt_alter_tit_acr_base_5.ttv_qti_dias_carenc_fechto      = ?
                  tt_alter_tit_acr_base_5.ttv_log_assume_tax_bco          = ?.

           assign tt_titulos_cartao.val_sdo_tit_acr                       = tt_alter_tit_acr_base_5.tta_val_sdo_tit_acr.

        end.

        if can-find(first tt_alter_tit_acr_base_5) then do:
        
            run prgfin/acr/acr711zv.py persistent set v_hdl_programa.
    
            run pi_main_code_integr_acr_alter_tit_acr_novo_14 in v_hdl_programa (Input  14,
                                                                                 Input  table tt_alter_tit_acr_base_5,
                                                                                 Input  table tt_alter_tit_acr_rateio,
                                                                                 Input  table tt_alter_tit_acr_ped_vda,
                                                                                 Input  table tt_alter_tit_acr_comis_1,
                                                                                 Input  table tt_alter_tit_acr_cheq,
                                                                                 Input  table tt_alter_tit_acr_iva,
                                                                                 Input  table tt_alter_tit_acr_impto_retid_2,
                                                                                 Input  table tt_alter_tit_acr_cobr_espec_2,
                                                                                 Input  table tt_alter_tit_acr_rat_desp_rec,
                                                                                 Output table tt_log_erros_alter_tit_acr,
                                                                                 Input  no,
                                                                                 Input  table tt_alter_tit_acr_cobr_esp_2_c,
                                                                                 Input  table tt_params_generic_api).
        
            delete procedure v_hdl_programa.
    
            run pi_grava_erros_api.

        end.

        /*****************************************************************************************/
        /** Chama a API de Alteraá∆o para realizar um AVA MENOR no t°tulo pai (tit_acr)        **/
        /*****************************************************************************************/

        for each tt_titulos_cartao where tt_titulos_cartao.tot_val_adm_cartao > 0 no-lock:

           find first tit_acr where tit_acr.cod_estab      = tt_titulos_cartao.cod_estab     
                                and tit_acr.num_id_tit_acr = tt_titulos_cartao.num_id_tit_acr no-lock no-error.
	        
           if available tit_acr and tit_acr.val_sdo_tit_acr <= 0 then next.
           
           /****** Cria Referencia para alteraá∆o ******/
           assign v_log_refer_uni = no
                  v_cod_refer     = "".
           
           repeat while v_log_refer_uni = no:

               run pi_retorna_sugestao_referencia (Input "A", 
                                                   Input today,
                                                   output v_cod_refer).
    
               run pi_verifica_refer_unica_acr (input tt_titulos_cartao.cod_estab,
                                                input v_cod_refer,
                                                input '',
                                                input ?,
                                                output v_log_refer_uni).
           end.

           for each movto_tit_acr fields(movto_tit_acr.dat_transacao) use-index mvtttcr_id no-lock where
                    movto_tit_acr.cod_estab      = tt_titulos_cartao.cod_estab
                and movto_tit_acr.num_id_tit_acr = tt_titulos_cartao.num_id_tit_acr
                by  movto_tit_acr.dat_transacao descending:

               assign v_dat_transacao = movto_tit_acr.dat_transacao.
               leave.
           end.

           empty temp-table tt_alter_tit_acr_base_5.
           empty temp-table tt_alter_tit_acr_rateio.

           create tt_alter_tit_acr_base_5.
           assign tt_alter_tit_acr_base_5.tta_cod_estab                   = tt_titulos_cartao.cod_estab
                  tt_alter_tit_acr_base_5.tta_num_id_tit_acr              = tt_titulos_cartao.num_id_tit_acr
                  tt_alter_tit_acr_base_5.tta_dat_transacao               = v_dat_transacao
                  tt_alter_tit_acr_base_5.tta_cod_refer                   = v_cod_refer
                  tt_alter_tit_acr_base_5.tta_val_sdo_tit_acr             = (tt_titulos_cartao.val_sdo_tit_acr - tt_titulos_cartao.tot_val_adm_cartao)
                  tt_alter_tit_acr_base_5.ttv_cod_motiv_movto_tit_acr_alt = ?
                  tt_alter_tit_acr_base_5.ttv_cod_motiv_movto_tit_acr_imp = ?
                  tt_alter_tit_acr_base_5.tta_val_despes_bcia             = ?
                  tt_alter_tit_acr_base_5.tta_cod_agenc_cobr_bcia         = ?
                  tt_alter_tit_acr_base_5.tta_cod_tit_acr_bco             = ?
                  tt_alter_tit_acr_base_5.tta_dat_emis_docto              = ?
                  tt_alter_tit_acr_base_5.tta_dat_vencto_tit_acr          = tt_titulos_cartao.dat_vencto_tit_acr
                  tt_alter_tit_acr_base_5.tta_dat_prev_liquidac           = tt_titulos_cartao.dat_prev_liquidac
                  tt_alter_tit_acr_base_5.tta_dat_fluxo_tit_acr           = ?
                  tt_alter_tit_acr_base_5.tta_ind_sit_tit_acr             = ?
                  tt_alter_tit_acr_base_5.tta_cod_cond_cobr               = ?
                  tt_alter_tit_acr_base_5.tta_log_tip_cr_perda_dedut_tit  = ?  
                  tt_alter_tit_acr_base_5.tta_dat_abat_tit_acr            = ?
                  tt_alter_tit_acr_base_5.tta_val_abat_tit_acr            = ?
                  tt_alter_tit_acr_base_5.tta_dat_desconto                = ? 
                  tt_alter_tit_acr_base_5.tta_val_perc_desc               = ?
                  tt_alter_tit_acr_base_5.tta_val_desc_tit_acr            = ?
                  tt_alter_tit_acr_base_5.tta_qtd_dias_carenc_juros_acr   = ?
                  tt_alter_tit_acr_base_5.tta_val_perc_juros_dia_atraso   = ?
                  tt_alter_tit_acr_base_5.tta_val_perc_multa_atraso       = ?
                  tt_alter_tit_acr_base_5.tta_qtd_dias_carenc_multa_acr   = ?
                  tt_alter_tit_acr_base_5.tta_ind_ender_cobr              = ?
                  tt_alter_tit_acr_base_5.tta_nom_abrev_contat            = ?
                  tt_alter_tit_acr_base_5.tta_val_liq_tit_acr             = ?
                  tt_alter_tit_acr_base_5.tta_cod_instruc_bcia_1_movto    = ?
                  tt_alter_tit_acr_base_5.tta_cod_instruc_bcia_2_movto    = ?
                  tt_alter_tit_acr_base_5.ttv_des_text_histor             = ?
                  tt_alter_tit_acr_base_5.tta_ind_tip_cobr_acr            = ?
                  tt_alter_tit_acr_base_5.tta_log_tit_acr_destndo         = ?
                  tt_alter_tit_acr_base_5.tta_des_obs_cobr                = ?
                  tt_alter_tit_acr_base_5.tta_val_perc_abat_acr           = ?
                  tt_alter_tit_acr_base_5.tta_val_cr_pis                  = ?
                  tt_alter_tit_acr_base_5.tta_val_cr_cofins               = ?
                  tt_alter_tit_acr_base_5.tta_val_cr_csll                 = ?
                  tt_alter_tit_acr_base_5.tta_val_base_calc_impto         = ?
                  tt_alter_tit_acr_base_5.tta_log_retenc_impto_impl       = ? 
                  tt_alter_tit_acr_base_5.ttv_ind_motiv_acerto_val        = "Alteraá∆o" 
                  tt_alter_tit_acr_base_5.tta_cod_portador                = ?
                  tt_alter_tit_acr_base_5.tta_cod_cart_bcia               = ?
                  tt_alter_tit_acr_base_5.ttv_log_vendor                  = ?
                  tt_alter_tit_acr_base_5.ttv_cod_portador_mov            = ?
                  tt_alter_tit_acr_base_5.tta_cod_histor_padr             = ?
                  tt_alter_tit_acr_base_5.ttv_wgh_lista                   = ?
                  tt_alter_tit_acr_base_5.tta_num_seq_tit_acr             = ?
                  tt_alter_tit_acr_base_5.ttv_cod_estab_planilha          = ?
                  tt_alter_tit_acr_base_5.ttv_num_planilha_vendor         = ?
                  tt_alter_tit_acr_base_5.ttv_cod_cond_pagto_vendor       = ?
                  tt_alter_tit_acr_base_5.ttv_val_cotac_tax_vendor_clien  = ?
                  tt_alter_tit_acr_base_5.ttv_dat_base_fechto_vendor      = ?
                  tt_alter_tit_acr_base_5.ttv_qti_dias_carenc_fechto      = ?
                  tt_alter_tit_acr_base_5.ttv_log_assume_tax_bco          = ?.

           find first tit_acr where tit_acr.cod_estab      = tt_titulos_cartao.cod_estab     
                                and tit_acr.num_id_tit_acr = tt_titulos_cartao.num_id_tit_acr no-lock no-error.
    
           find first param_esp where param_esp.cod_empresa = v_cod_empres_usuar no-lock no-error.

           /*****************************************************************************************/
           /** Rateio do T°tulo                                                                    **/
           /*****************************************************************************************/
           assign v_val_tot_aprop_rat = 0
                  v_val_aprop_rat     = 0.

           run pi_retornar_finalid_indic_econ (input  tit_acr.cod_indic_econ,
                                               input  tit_acr.dat_transacao,
                                               output v_cod_finalid_econ). 

           assign v_num_seq = 1.

           for each val_tit_acr where val_tit_acr.cod_estab        = tit_acr.cod_estab      and 
                                      val_tit_acr.num_id_tit_acr   = tit_acr.num_id_tit_acr and 
                                      val_tit_acr.cod_finalid_econ = v_cod_finalid_econ     no-lock:

              create tt_alter_tit_acr_rateio.

              assign tt_alter_tit_acr_rateio.tta_cod_estab                   = tit_acr.cod_estab
                     tt_alter_tit_acr_rateio.tta_num_id_tit_acr              = tit_acr.num_id_tit_acr
                     tt_alter_tit_acr_rateio.ttv_ind_tip_rat_tit_acr         = "Alteraá∆o"
                     tt_alter_tit_acr_rateio.tta_cod_refer                   = v_cod_refer
                     tt_alter_tit_acr_rateio.tta_num_seq_refer               = 10
                     tt_alter_tit_acr_rateio.tta_cod_plano_cta_ctbl          = param_esp.cod_plano_cta_ctbl
                     tt_alter_tit_acr_rateio.tta_cod_cta_ctbl                = param_esp.cod_cta_ctbl_des
                     tt_alter_tit_acr_rateio.tta_cod_unid_negoc              = val_tit_acr.cod_unid_negoc
                     tt_alter_tit_acr_rateio.tta_cod_plano_ccusto            = ""
                     tt_alter_tit_acr_rateio.tta_cod_ccusto                  = ""
                     tt_alter_tit_acr_rateio.tta_cod_tip_fluxo_financ        = val_tit_acr.cod_tip_fluxo_financ
                     tt_alter_tit_acr_rateio.tta_num_seq_aprop_ctbl_pend_acr = v_num_seq
                     tt_alter_tit_acr_rateio.tta_val_aprop_ctbl              = (tt_titulos_cartao.tot_val_adm_cartao * val_tit_acr.val_perc_rat) / 100
                     tt_alter_tit_acr_rateio.tta_log_impto_val_agreg         = NO
                     tt_alter_tit_acr_rateio.tta_cod_pais                    = ""
                     tt_alter_tit_acr_rateio.tta_cod_unid_federac            = ""
                     tt_alter_tit_acr_rateio.tta_cod_imposto                 = ""
                     tt_alter_tit_acr_rateio.tta_cod_classif_impto           = ""
                     tt_alter_tit_acr_rateio.tta_dat_transacao               = v_dat_transacao.

              assign v_num_seq = v_num_seq + 1.

              assign v_val_tot_aprop_rat = v_val_tot_aprop_rat + tt_alter_tit_acr_rateio.tta_val_aprop_ctbl.

           end.

           if tt_titulos_cartao.tot_val_adm_cartao <> v_val_tot_aprop_rat then do:

              find first tt_alter_tit_acr_rateio exclusive-lock no-error.

              if available tt_alter_tit_acr_rateio then do:

                 assign tt_alter_tit_acr_rateio.tta_val_aprop_ctbl = tt_alter_tit_acr_rateio.tta_val_aprop_ctbl + (tt_titulos_cartao.tot_val_adm_cartao - v_val_tot_aprop_rat).

              end.
           end.

           /*assign tt_alter_tit_acr_rateio.tta_val_aprop_ctbl = tt_alter_tit_acr_rateio.tta_val_aprop_ctbl + ((tt_titulos_cartao.val_sdo_tit_acr - tt_titulos_cartao.tot_val_adm_cartao) - v_val_tot_aprop_rat).*/
           /* FIM: Efetua o rateio da alteraá∆o de valor */

           output stream s-ed to c:\temp\aprop_ctbl_pend_acr.d append.

           for each aprop_ctbl_pend_acr where aprop_ctbl_pend_acr.cod_estab = tit_acr.cod_estab and 
                                              aprop_ctbl_pend_acr.cod_refer = tit_acr.cod_refer exclusive-lock:

              export stream s-ed aprop_ctbl_pend_acr.

              delete  aprop_ctbl_pend_acr.
              release aprop_ctbl_pend_acr.

           end.

           output stream s-ed close.

           run prgfin/acr/acr711zv.py persistent set v_hdl_programa .

           run pi_main_code_integr_acr_alter_tit_acr_novo_14 in v_hdl_programa (Input  14,
                                                                                Input  table tt_alter_tit_acr_base_5,
                                                                                Input  table tt_alter_tit_acr_rateio,
                                                                                Input  table tt_alter_tit_acr_ped_vda,
                                                                                Input  table tt_alter_tit_acr_comis_1,
                                                                                Input  table tt_alter_tit_acr_cheq,
                                                                                Input  table tt_alter_tit_acr_iva,
                                                                                Input  table tt_alter_tit_acr_impto_retid_2,
                                                                                Input  table tt_alter_tit_acr_cobr_espec_2,
                                                                                Input  table tt_alter_tit_acr_rat_desp_rec,
                                                                                Output table tt_log_erros_alter_tit_acr,
                                                                                Input  no,
                                                                                Input table  tt_alter_tit_acr_cobr_esp_2_c,
                                                                                Input table  tt_params_generic_api).

           delete procedure v_hdl_programa.

           run pi_grava_erros_api.

        end.

        view stream s_1 frame f_rpt_s_1_header_unique.
        hide stream s_1 frame f_rpt_s_1_footer_last_page.
        view stream s_1 frame f_rpt_s_1_footer_normal.
    
        if can-find(first tt_erro_implanta) then do:
            put stream s_1 unformatted
                "|-----------------------------------------------------------------------------------------------------------------------|" at 01 skip
                "|Erros encontrados na Implantaá∆o - Todo o processo ser† abortado  - vrs 02                                             |" at 01 skip
                "|-----------------------------------------------------------------------------------------------------------------------|" at 01 skip(1).        
        
    
            view stream s_1 frame f_rpt_s_1_impl_errado.
        
            put stream s_1 unformatted
                "Est" at 01
                "Esp" at 05
                "Ser" at 09
                "T°tulo" at 13
                "Emp" at 24
                "Admin" at 28
                "P Cliente" at 36
                "P Juridica" at 47
                "Mensagem" at 58
                "Ajuda" at 119
                "---" at 01
                "---" at 05
                "---" at 09
                "----------" at 13
                "---" at 24
                "-----" at 28
                "-----------" at 34
                "-----------" at 46
                "------------------------------------------------------------" at 58
                "----------------------------------------" at 119 skip(1).
        end.
    
        for each tt_erro_implanta:
    
            if entry(2,tt_erro_implanta.tta_informacao) = "" then do:
    
                find first tit_acr where tit_acr.cod_estab      = entry(1,tt_erro_implanta.tta_informacao)
                                     and tit_acr.num_id_tit_acr = int(entry(11,tt_erro_implanta.tta_informacao)) no-lock no-error.
    
                if avail tit_acr then do:
    
                    if (line-counter(s_1) + 3) > v_rpt_s_1_bottom then
                        page stream s_1.
                
                    put stream s_1 unformatted
                        tit_acr.cod_estab at 01
                        tit_acr.cod_espec_docto at 05
                        tit_acr.cod_ser_docto at 09
                        tit_acr.cod_tit_acr at 13
                        tit_acr.cod_empresa at 24
                        "" at 28
                        "" at 36
                        "" at 47
                        substr(tt_erro_implanta.tta_des_erro,1,40) at 58 format "x(40)" 
                        substr(tt_erro_implanta.tta_ajuda,1,40) at 119 format "x(40)" skip
                        substr(tt_erro_implanta.tta_des_erro,41,40) at 58 format "x(40)"
                        substr(tt_erro_implanta.tta_ajuda,41,40) at 119 format "x(40)" skip
                        substr(tt_erro_implanta.tta_des_erro,81,40) at 58 format "x(40)"
                        substr(tt_erro_implanta.tta_ajuda,81,40) at 119 format "x(40)" skip
                        substr(tt_erro_implanta.tta_des_erro,121,40) at 58 format "x(40)"
                        substr(tt_erro_implanta.tta_ajuda,121,40) at 119 format "x(40)" skip
                        substr(tt_erro_implanta.tta_des_erro,161,40) at 58 format "x(40)"   
                        substr(tt_erro_implanta.tta_ajuda,161,40) at 119 format "x(40)" skip(1).
                end.
            end.
            else do:
    
                if (line-counter(s_1) + 3) > v_rpt_s_1_bottom then
                    page stream s_1.
                
                put stream s_1 unformatted
                    entry(1,tt_erro_implanta.tta_informacao) at 01
                    entry(2,tt_erro_implanta.tta_informacao) at 05
                    entry(3,tt_erro_implanta.tta_informacao) at 09
                    entry(4,tt_erro_implanta.tta_informacao) at 13
                    entry(7,tt_erro_implanta.tta_informacao) at 24
                    entry(8,tt_erro_implanta.tta_informacao) at 28
                    entry(9,tt_erro_implanta.tta_informacao) to 44
                    entry(10,tt_erro_implanta.tta_informacao)     to 56
                    substr(tt_erro_implanta.tta_des_erro,1,40) at 58 format "x(40)" 
                    substr(tt_erro_implanta.tta_ajuda,1,40) at 119 format "x(40)" skip
                    substr(tt_erro_implanta.tta_des_erro,41,40) at 58 format "x(40)" 
                    substr(tt_erro_implanta.tta_ajuda,41,40) at 119 format "x(40)" skip
                    substr(tt_erro_implanta.tta_des_erro,81,40) at 58 format "x(40)" 
                    substr(tt_erro_implanta.tta_ajuda,81,40) at 119 format "x(40)" skip
                    substr(tt_erro_implanta.tta_des_erro,121,40) at 58 format "x(40)"
                    substr(tt_erro_implanta.tta_ajuda,121,40) at 119 format "x(40)" skip
                    substr(tt_erro_implanta.tta_des_erro,161,40) at 58 format "x(40)"
                    substr(tt_erro_implanta.tta_ajuda,161,40) at 119 format "x(40)" skip(1).
    
            end.
        end.

        if can-find(first tt_erro_implanta) then do:
    
            hide stream s_1 frame f_rpt_s_1_impl_errado.
            hide stream s_1 frame f_rpt_s_1_header_unique.
            view stream s_1 frame f_rpt_s_1_header_unique.
            page stream s_1.

        end.
    
        
    
        put stream s_1 unformatted
            "|-----------------------------------------------------------------------------------------------------------------------|" at 01 skip
            "|T°tulos Implantados Corretamente - vrs 02                                                                              |" at 01 skip
            "|-----------------------------------------------------------------------------------------------------------------------|" at 01 skip(1).        
    
        view stream s_1 frame f_rpt_s_1_impl_correto.
    
        put stream s_1 unformatted
            "Est" at 01
            "Esp" at 05
            "Ser" at 09
            "T°tulo" at 13
            "/P" at 24
            "Emp" at 27
            "Admin" at 31
            "Autorizaá∆o" at 37
            "Comprovante" at 58
            "Dt Venda" at 79
            "Dt Credito" at 90
            "Resumo" at 101
            "Vl Admin" at 128
            "VL Venda" at 143
            "---" at 01
            "---" at 05
            "---" at 09
            "----------" at 13
            "--" at 24  
            "---" at 27
            "-----" at 31
            "--------------------" at 37
            "--------------------" at 58
            "----------" at 79
            "----------" at 90
            "--------------------" at 101
            "--------------" at 122
            "--------------" at 137 skip(1).
    
        for each ttCardAccountReceivableIn_00:
    
                if can-find(tt_erro_implanta where entry(1,tt_erro_implanta.tta_informacao)  = ttCardAccountReceivableIn_00.BranchCode
                                               and entry(2,tt_erro_implanta.tta_informacao)  = ttCardAccountReceivableIn_00.DocumentClassCode
                                               and entry(3,tt_erro_implanta.tta_informacao)  = ttCardAccountReceivableIn_00.DocumentSerieCode
                                               and entry(5,tt_erro_implanta.tta_informacao)  = ttCardAccountReceivableIn_00.CardAuthorize
                                               and entry(6,tt_erro_implanta.tta_informacao)  = ttCardAccountReceivableIn_00.ProofSell
                                               and entry(12,tt_erro_implanta.tta_informacao) = ttCardAccountReceivableIn_00.DocumentParcelNumber)
                then do:
                    next.
                end.
    
                if (line-counter(s_1) + 3) > v_rpt_s_1_bottom then
                    page stream s_1.
    
                put stream s_1 unformatted
                    ttCardAccountReceivableIn_00.BranchCode            at 01 
                    ttCardAccountReceivableIn_00.DocumentClassCode     at 05
                    ttCardAccountReceivableIn_00.DocumentSerieCode     at 09
                    ttCardAccountReceivableIn_00.DocumentNumber        at 13
                    ttCardAccountReceivableIn_00.DocumentParcelNumber  at 24
                    ttCardAccountReceivableIn_00.CompanyCode           at 27
                    ttCardAccountReceivableIn_00.ManagerNumber         at 31
                    ttCardAccountReceivableIn_00.CardAuthorize         at 37
                    ttCardAccountReceivableIn_00.ProofSell             at 58
                    ttCardAccountReceivableIn_00.DateSell              at 79
                    ttCardAccountReceivableIn_00.DateCredit            at 90
                    ttCardAccountReceivableIn_00.SellResume            at 101
                    ttCardAccountReceivableIn_00.ValueManagerCard      to 135
                    ttCardAccountReceivableIn_00.ValueSellProof        to 150 skip(1).
            
            
        end.
    
        output stream s_1 close.

        if can-find(tt_log_erros_alter_tit_acr) then
            undo, retry block_1.
        
    end.
    
end.
