     /* Para evitar mensagem do dedo-duro */
     assign v_num_control_ult_msg = time + 1.

    /* FAZER AQUI TRATAMENTO DE CONTROLE DE VERS√O ADEQUADO! */

    /* ********* EXECU«√O DAS PI - BEGIN ********* */
    def var l-cadfor as logical no-undo init no.
    def var l-cadcli as logical no-undo init no.
    DEF VAR v_log_achou AS LOGICAL NO-UNDO.

    /*ROTINA DE UPSERT - BEGIN*/
    IF  (cTranAction = "add") or (cTranAction = "upd") THEN DO:
        

        RUN PIUpsert.

        IF CustomerVendorIdentification = 1 THEN 
        DO:
            /*Cliente*/
            RUN pi_atualiza_cliente.
        END.
        ELSE 
        IF CustomerVendorIdentification = 2 THEN 
        DO:
            /*Fornecedor*/
            RUN pi_atualiza_fornecedor.
        END.
        ELSE 
        DO:
            /*Ambos*/
            RUN pi_atualiza_ambos.
        END.

        FIND FIRST matriz_trad_org_ext NO-LOCK NO-ERROR.
        IF NOT AVAIL matriz_trad_org_ext THEN DO:
            RUN setError IN hMessageHandler (INPUT 111,
                                             INPUT "business_error",
                                             INPUT "Matriz de Traduá∆o de Organizaá∆o Externa n∆o encontrada." +
                                                   "Deve existir no m°nimo uma matriz de Traduá∆o de Organizaá∆o Externa.").
            RETURN "NOK".
        END.

        ASSIGN v_cod_empres_usuar = CompanyCode_00.

        ASSIGN v_log_eai_habilit_bkp = v_log_eai_habilit
               v_log_eai_habilit     = NO.

        run prgint/utb/utb765zl.py persistent set v_hdl_utb765zl (Input 1,
                                                                  Input matriz_trad_org_ext.cod_matriz_trad_org_ext,
                                                                  Input v_cod_empres_usuar).

        if  valid-handle(v_hdl_utb765zl) then do:
            /*run pi_main_block_utb765zl_6 in  v_hdl_utb765zl  (Input table tt_cliente_integr_j,*/
            run pi_main_block_utb765zl_8 in  v_hdl_utb765zl
                                       (Input table tt_cliente_integr_j,
                                        Input table tt_fornecedor_integr_k,
                                        Input table tt_clien_financ_integr_e,
                                        Input table tt_fornec_financ_integr_d,
                                        Input table tt_pessoa_jurid_integr_j,
                                        Input table tt_pessoa_fisic_integr_e,
                                        Input table tt_contato_integr_e,
                                        Input table tt_contat_clas_integr,
                                        Input table tt_estrut_clien_integr,
                                        Input table tt_estrut_fornec_integr,
                                        Input table tt_histor_clien_integr,
                                        Input table tt_histor_fornec_integr,
                                        Input table tt_ender_entreg_integr_e,
                                        Input table tt_telef_integr,
                                        Input table tt_telef_pessoa_integr,
                                        Input table tt_pj_ativid_integr_i,
                                        Input table tt_pj_ramo_negoc_integr_j,
                                        Input table tt_porte_pj_integr,
                                        Input table tt_idiom_pf_integr,
                                        Input table tt_idiom_contat_integr,
                                        input-output table tt_retorno_clien_fornec,
                                        Input table tt_clien_analis_cr_integr,
                                        Input table tt_cta_corren_fornec).
            
            ASSIGN v_log_eai_habilit = v_log_eai_habilit_bkp.
        
            delete procedure v_hdl_utb765zl no-error.
        end.

    END.
    /*ROTINA DE UPSERT - END*/
               
    /*ROTINA DE DELETE - BEGIN*/
    IF (cTranAction = "del") THEN DO:

        RUN PIDelete.

        IF  CustomerVendorIdentification_00 = 1 OR 
            CustomerVendorIdentification_00 = 3 THEN 
        DO:
            /*Cliente*/
            CREATE tt_cliente_integr_j.
            ASSIGN tt_cliente_integr_j.ttv_num_tip_operac        = 2.

            IF CustomerVendorCode_00 <> ? THEN
                ASSIGN tt_cliente_integr_j.tta_cdn_cliente = CustomerVendorCode_00.
            
            IF CustomerVendorShortName_00 <> ? THEN
                ASSIGN tt_cliente_integr_j.tta_nom_abrev   = CustomerVendorShortName_00.

            FIND ems.cliente NO-LOCK WHERE
                 cliente.cod_empresa = CompanyCode_00 AND
                 cliente.cdn_cliente = tt_cliente_integr_j.tta_cdn_cliente NO-ERROR.

            IF AVAIL cliente THEN DO:
                ASSIGN tt_cliente_integr_j.tta_cod_pais = cliente.cod_pais.
            END.
        END.
        
        IF  CustomerVendorIdentification_00 = 2 OR 
            CustomerVendorIdentification_00 = 3 THEN
        DO:
            /*Fornecedor*/
            CREATE tt_fornecedor_integr_k.
            ASSIGN tt_fornecedor_integr_k.ttv_num_tip_operac        = 2.

            IF CustomerVendorCode_00 <> ? THEN
                ASSIGN tt_fornecedor_integr_k.tta_cdn_fornecedor = CustomerVendorCode_00.
            
            IF CustomerVendorShortName_00 <> ? THEN
                ASSIGN tt_fornecedor_integr_k.tta_nom_abrev      = CustomerVendorShortName_00.

            FIND ems.fornecedor NO-LOCK WHERE
                 fornecedor.cod_empresa = CompanyCode_00 AND
                 fornecedor.cdn_fornec  = tt_fornecedor_integr_k.tta_cdn_fornec NO-ERROR.

            IF AVAIL fornecedor THEN DO:
                ASSIGN tt_fornecedor_integr_k.tta_cod_pais = fornecedor.cod_pais.
            END.

        END.
        
        ASSIGN v_log_eai_habilit_bkp = v_log_eai_habilit
               v_log_eai_habilit     = NO.

        run prgint/utb/utb765zl.py persistent set v_hdl_utb765zl (Input 1,
                                                                  Input "",
                                                                  Input "").


        if  valid-handle(v_hdl_utb765zl) then do:
            run pi_main_block_utb765zl_8 in  v_hdl_utb765zl
                                       (Input table tt_cliente_integr_j,
                                        Input table tt_fornecedor_integr_k,
                                        Input table tt_clien_financ_integr_e,
                                        Input table tt_fornec_financ_integr_d,
                                        Input table tt_pessoa_jurid_integr_j,
                                        Input table tt_pessoa_fisic_integr_e,
                                        Input table tt_contato_integr_e,
                                        Input table tt_contat_clas_integr,
                                        Input table tt_estrut_clien_integr,
                                        Input table tt_estrut_fornec_integr,
                                        Input table tt_histor_clien_integr,
                                        Input table tt_histor_fornec_integr,
                                        Input table tt_ender_entreg_integr_e,
                                        Input table tt_telef_integr,
                                        Input table tt_telef_pessoa_integr,
                                        Input table tt_pj_ativid_integr_i,
                                        Input table tt_pj_ramo_negoc_integr_j,
                                        Input table tt_porte_pj_integr,
                                        Input table tt_idiom_pf_integr,
                                        Input table tt_idiom_contat_integr,
                                        input-output table tt_retorno_clien_fornec,
                                        Input table tt_clien_analis_cr_integr,
                                        Input table tt_cta_corren_fornec).
            
            ASSIGN v_log_eai_habilit = v_log_eai_habilit_bkp.
        
            delete procedure v_hdl_utb765zl no-error.
        end.

    END.

    OUTPUT TO VALUE(SESSION:TEMP-DIRECTORY + "IMP-CLIFOR-" + STRING(TODAY, "999999") + "-" + REPLACE(STRING(TIME, "HH:MM:SS"), ":" , "") + ".log")
              CONVERT TARGET "ISO8859-1".

    /* Se retornar o c¢digo 17953 Ç porque o cliente possui algum t°tulo no contas a receber */
    IF CAN-FIND(FIRST tt_retorno_clien_fornec WHERE
                      tt_retorno_clien_fornec.ttv_num_mensagem = 17953) AND CustomerVendorIdentification_00 = 1 THEN DO:

        ASSIGN v_log_achou = NO.

        /* Verificaá∆o se o Cliente possui algum t°tulo em aberto */
        FOR EACH ems.empresa FIELD(empresa.cod_empresa empresa.log_recebe_cop_clien) NO-LOCK:

            IF empresa.cod_empresa = CompanyCode_00 OR empresa.log_recebe_cop_clien = yes then do:

                IF can-find(FIRST tit_acr NO-LOCK WHERE
                                  tit_acr.cod_empresa = empresa.cod_empresa
                              AND tit_acr.cdn_cliente = CustomerVendorCode_00
                              AND tit_acr.val_sdo_tit_acr > 0) THEN DO:

                    CREATE tt_retorno_clien_fornec.
                    ASSIGN tt_retorno_clien_fornec.ttv_cod_parameters = "An†lise de CrÇdito!"
                           tt_retorno_clien_fornec.ttv_num_mensagem   = 1122
                           tt_retorno_clien_fornec.ttv_des_mensagem   = "Cliente possui Movimentos no Contas a Receber em aberto!".
                           tt_retorno_clien_fornec.ttv_des_ajuda      = "O Cliente " + STRING(CustomerVendorCode_00) +
                                                                        " possui Movimentaá‰es no Contas a Receber em aberto, portanto n∆o pode ser desativado.".
                    ASSIGN v_log_achou = YES.
                    LEAVE.
                END.
            END.
            IF v_log_achou THEN
                LEAVE.
        END.

        FOR EACH tt_retorno_clien_fornec WHERE tt_retorno_clien_fornec.ttv_num_mensagem = 17953:
            DELETE tt_retorno_clien_fornec.
        END.
    END.

    /* Se retornar o c¢digo 17953 Ç porque o cliente possui algum t°tulo no contas a receber */
    IF CAN-FIND(FIRST tt_retorno_clien_fornec WHERE
                      tt_retorno_clien_fornec.ttv_num_mensagem = 99999) AND CustomerVendorIdentification_00 = 2 THEN DO:

        ASSIGN v_log_achou = NO.

        /* Verificaá∆o se o Cliente possui algum t°tulo em aberto */
        FOR EACH empresa FIELD(empresa.cod_empresa empresa.log_recebe_cop_clien) NO-LOCK:

            IF empresa.cod_empresa = CompanyCode_00 OR empresa.log_recebe_cop_clien = yes then do:

                IF can-find(FIRST tit_ap NO-LOCK WHERE
                                  tit_ap.cod_empresa = empresa.cod_empresa
                              AND tit_ap.cdn_fornec  = CustomerVendorCode_00
                              AND tit_ap.val_sdo_tit_ap > 0) THEN DO:

                    CREATE tt_retorno_clien_fornec.
                    ASSIGN tt_retorno_clien_fornec.ttv_cod_parameters = "An†lise de DÇbitos!"
                           tt_retorno_clien_fornec.ttv_num_mensagem   = 1133
                           tt_retorno_clien_fornec.ttv_des_mensagem   = "Fornecedor possui Movimentos no Contas a Pagar em aberto!".
                           tt_retorno_clien_fornec.ttv_des_ajuda      = "O Fornecedor " + STRING(CustomerVendorCode_00) +
                                                                        " possui Movimentaá‰es no Contas a Pagar em aberto, portanto n∆o pode ser desativado.".
                    ASSIGN v_log_achou = YES.
                    LEAVE.
                END.
            END.
            IF v_log_achou THEN
                LEAVE.
        END.

        FOR EACH tt_retorno_clien_fornec WHERE tt_retorno_clien_fornec.ttv_num_mensagem = 99999:
            DELETE tt_retorno_clien_fornec.
        END.
    END.

    IF NOT CAN-FIND(FIRST tt_retorno_clien_fornec) THEN DO:

        IF (cTranAction = "add") or (cTranAction = "upd") THEN DO:
            PUT UNFORMATTED "Importaá∆o de Movimentos no Fluxo de Caixa realizado com sucesso!".
        END.
        ELSE IF cTranAction = "del" THEN DO:

            DELETE_block:
            DO:
                IF CustomerVendorIdentification_00 = 1 THEN DO: /* Cliente */

                    IF NOT CAN-FIND(grp_clien WHERE grp_clien.cod_grp_clien = "9999") THEN DO:
                        CREATE tt_retorno_clien_fornec.
                        ASSIGN tt_retorno_clien_fornec.ttv_cod_parameters = "Desativaá∆o do Cliente n∆o realizada!"
                               tt_retorno_clien_fornec.ttv_num_mensagem   = 9999
                               tt_retorno_clien_fornec.ttv_des_mensagem   = "Grupo de Cliente 9999 n∆o encontrado!".
                               tt_retorno_clien_fornec.ttv_des_ajuda      = "Favor verificar no Cadastro de Grupo de Cliente se existe um grupo 9999 cadastrado.".

                        LEAVE DELETE_block.
                    END.
        
                    /* Altera o c¢digo do grupo do cliente enviado no XML para 9999 (tamanho m†ximo do permitido no campo) */
                    FIND cliente EXCLUSIVE-LOCK WHERE
                         cliente.cod_empresa = CompanyCode_00 AND
                         cliente.cdn_cliente = CustomerVendorCode_00 NO-ERROR.
        
                    IF AVAIL cliente THEN DO:
                        ASSIGN cliente.cod_grp_clien = "9999".
        
                        /* Altera o c¢digo do cliente nas outras empresas que recebem c¢pia do cadastro de clientes */
                        for each empresa no-lock:
                            if  empresa.cod_empresa <> CompanyCode_00 AND
                                empresa.log_recebe_cop_clien = yes then do:
        
                                FIND cliente EXCLUSIVE-LOCK WHERE
                                     cliente.cod_empresa = empresa.cod_empresa   AND
                                     cliente.cdn_cliente = CustomerVendorCode_00 NO-ERROR.
                                IF AVAIL cliente THEN
                                    ASSIGN cliente.cod_grp_clien = "9999".
                            END.
                        END.
                    END.
                END.
                ELSE IF CustomerVendorIdentification_00 = 2 THEN DO: /* Fornecedor */

                    IF NOT CAN-FIND(grp_fornec WHERE grp_fornec.cod_grp_fornec = "9999") THEN DO:
                        CREATE tt_retorno_clien_fornec.
                        ASSIGN tt_retorno_clien_fornec.ttv_cod_parameters = "Desativaá∆o do Fornecedor n∆o realizada!"
                               tt_retorno_clien_fornec.ttv_num_mensagem   = 9999
                               tt_retorno_clien_fornec.ttv_des_mensagem   = "Grupo de Fornecedor 9999 n∆o encontrado!".
                               tt_retorno_clien_fornec.ttv_des_ajuda      = "Favor verificar no Cadastro de Grupo de Fornecedor se existe um grupo 9999 cadastrado.".

                        LEAVE DELETE_block.
                    END.

                    /* Altera o c¢digo do grupo do fornecedor enviado no XML para 9999 (tamanho m†ximo do permitido no campo) */
                    FIND fornecedor EXCLUSIVE-LOCK WHERE
                         fornecedor.cod_empresa = CompanyCode_00 AND
                         fornecedor.cdn_fornec  = CustomerVendorCode_00 NO-ERROR.
        
                    IF AVAIL fornecedor THEN DO:
                        ASSIGN fornecedor.cod_grp_fornec = "9999".
        
                        /* Altera o c¢digo do grupo do fornecedor nas outras empresas que recebem c¢pia do cadastro de clientes */
                        for each empresa no-lock:
                            if  empresa.cod_empresa <> CompanyCode_00 AND
                                empresa.log_recebe_cop_fornec = yes then do:
        
                                FIND fornecedor EXCLUSIVE-LOCK WHERE
                                     fornecedor.cod_empresa = empresa.cod_empresa   AND
                                     fornecedor.cdn_fornec  = CustomerVendorCode_00 NO-ERROR.
                                IF AVAIL fornecedor THEN
                                    ASSIGN fornecedor.cod_grp_fornec = "9999".
                            END.
                        END.
                    END.
                END.
            END.
        END. /* DELETE_block: */

    END.

    IF CAN-FIND(FIRST tt_retorno_clien_fornec) THEN DO:
        PUT UNFORMATTED
            "Erros encontrados." SKIP(1).

        FOR EACH tt_retorno_clien_fornec:

            PUT UNFORMATTED
                "ParÉmetros:"
                    tt_retorno_clien_fornec.ttv_cod_parameters AT 19 SKIP
                "C¢digo do Erro:"
                    tt_retorno_clien_fornec.ttv_num_mensagem   AT 19 SKIP
                "Mensagem:"
                    tt_retorno_clien_fornec.ttv_des_mensagem   AT 19 SKIP
                "Ajuda:"
                    tt_retorno_clien_fornec.ttv_des_ajuda      AT 19
                SKIP(1).
        END.
    END.

    OUTPUT CLOSE.

    /*ALIMENTA«√O DOS ERROS OCORRIDOS NA EFETIVA«√O*/
    FOR EACH tt_retorno_clien_fornec:

        /* INFORMA AO MESSAGE HANDLER UM ERRO QUE DEVE ESTAR PRESENTE NA MENSAGEM DE RETORNO */
        RUN setError IN hMessageHandler (INPUT tt_retorno_clien_fornec.ttv_num_mensagem, INPUT "business_error", INPUT tt_retorno_clien_fornec.ttv_des_mensagem + " " + tt_retorno_clien_fornec.ttv_des_ajuda).
    END.


    /* OBTEM UMA MENSAGEM DE RETORNO - SENDO ELA DE ERRO OU DE CONFIRMA«√O */
    RUN getReturnMessage IN hMessageHandler (OUTPUT hOutputXML).
    /* ********* EXECU«√O DAS PI - END ********* */

    

