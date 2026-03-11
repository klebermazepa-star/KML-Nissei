/**********************************************************************
** Include onde estao as temp-tables utilizadas no desenvolvimento   **
**********************************************************************/

DEF TEMP-TABLE tt-gera-movto  NO-UNDO
    FIELD cod-estabel     LIKE  estabelec.cod-estabel
    FIELD nr-pedido       LIKE  ped-venda.nr-pedido
    FIELD rowid-tit-acr   AS    ROWID
    FIELD rowid-tit-do    AS    ROWID
    FIELD especie-docto   AS    CHAR
    FIELD transacao       AS    CHAR
    FIELD val-antecipacao LIKE  tit_acr.val_sdo_tit_acr /* <Vincula>, <Desvincula> */
    FIELD origem          AS    CHAR.

DEF TEMP-TABLE tt-log NO-UNDO
    FIELD cod_estab       LIKE tit_acr.cod_estab
    FIELD cod_espec_docto LIKE tit_acr.cod_espec_docto
    FIELD cod_ser_docto   LIKE tit_acr.cod_ser_docto
    FIELD cod_tit_acr     LIKE tit_acr.cod_tit_acr
    FIELD cod_parcela     LIKE tit_acr.cod_parcela
    FIELD val_receber     LIKE tit_acr.val_sdo_tit_acr
    FIELD num_erro_log    AS INT
    FIELD des_msg_erro    AS CHAR FORMAT "x(200)".

def temp-table tt_integr_acr_renegoc no-undo
    field tta_cod_empresa                  as character  format "x(3)" label "Empresa" column-label "Empresa"
    field tta_cod_estab                    as character  format "x(3)" label "Estabelecimento" column-label "Estab"
    field tta_num_renegoc_cobr_acr         as integer    format ">>>>,>>9" initial 0 label "Num. Renegoc" column-label "Renegocia»’o"
    field tta_cdn_cliente                  as Integer    format ">>>,>>>,>>9" initial 0 label "Cliente" column-label "Cliente"
    field tta_dat_transacao                as date       format "99/99/9999" initial today label "Data Transa»’o" column-label "Dat Transac"
    field tta_cod_cond_pagto               as character  format "x(8)" label "Condi»’o Pagamento" column-label "Condi»’o Pagamento"
    field tta_val_renegoc_cobr_acr         as decimal    format "->>,>>>,>>>,>>9.99" decimals 2 initial 0 label "Valor" column-label "Valor"
    field tta_num_id_renegoc_cobr_acr      as integer    format ">>>>,>>9" initial 0 label "Id Renegocia»’o" column-label "Id Reneg"
    field tta_val_perc_juros_renegoc       as decimal    format "->>,>>>,>>>,>>9.99" decimals 2 initial 0 label "Perc Juros" column-label "Perc Juros"
    field tta_ind_tip_renegoc_acr          as character  format "X(15)" initial "Prorroga" label "Tipo Renegocia»’o" column-label "Tipo Renegocia»’o"
    field tta_log_renegoc_acr_estordo      as logical    format "Sim/N’o" initial no label "Reneg Estornada" column-label "Renegoc Estornada"
    field tta_cod_indic_econ_val_pres      as character  format "x(8)" label "™ndice Reajuste" column-label "™ndice Reaj"
    field tta_val_perc_val_pres            as decimal    format ">>9.99" decimals 2 initial 0 label "%" column-label "%"
    field tta_cod_livre_1                  as character  format "x(100)" label "Livre 1" column-label "Livre 1"
    field tta_dat_livre_1                  as date       format "99/99/9999" initial ? label "Livre 1" column-label "Livre 1"
    field tta_log_livre_1                  as logical    format "Sim/N’o" initial no label "Livre 1" column-label "Livre 1"
    field tta_num_livre_1                  as integer    format ">>>>>9" initial 0 label "Livre 1" column-label "Livre 1"
    field tta_val_livre_1                  as decimal    format ">>>,>>>,>>9.9999" decimals 4 initial 0 label "Livre 1" column-label "Livre 1"
    field tta_cod_livre_2                  as character  format "x(100)" label "Livre 2" column-label "Livre 2"
    field tta_dat_livre_2                  as date       format "99/99/9999" initial ? label "Livre 2" column-label "Livre 2"
    field tta_log_livre_2                  as logical    format "Sim/N’o" initial no label "Livre 2" column-label "Livre 2"
    field tta_num_livre_2                  as integer    format ">>>>>9" initial 0 label "Livre 2" column-label "Livre 2"
    field tta_val_livre_2                  as decimal    format ">>>,>>>,>>9.9999" decimals 4 initial 0 label "Livre 2" column-label "Livre 2"
    field tta_log_consid_juros_renegoc     as logical    format "Sim/N’o" initial yes label "Considera Juros" column-label "Consid Juros"
    field tta_log_consid_multa_renegoc     as logical    format "Sim/N’o" initial yes label "Considera Multa" column-label "Considera Multa"
    field tta_log_consid_abat_renegoc      as logical    format "Sim/N’o" initial no label "Considera Abatimento" column-label "Consid Abatimento"
    field tta_log_consid_desc_renegoc      as logical    format "Sim/N’o" initial no label "Considera Desconto" column-label "Consid Desconto"
    field tta_val_perc_reaj_renegoc        as decimal    format ">>9.99" decimals 2 initial 0 label "Reajuste" column-label "Reaj"
    field tta_val_juros_renegoc_calcul     as decimal    format "->>,>>>,>>>,>>9.99" decimals 2 initial 0 label "Juros Calculado" column-label "Juros Calc"
    field tta_val_juros_renegoc_infor      as decimal    format ">>,>>>,>>>,>>9.99" decimals 2 initial 0 label "Juros Informado" column-label "Juros Inform"
    field tta_val_multa_renegoc_calcul     as decimal    format ">>,>>>,>>>,>>9.99" decimals 2 initial 0 label "Multa Calculada" column-label "Multa Calcul"
    field tta_val_multa_renegoc_infor      as decimal    format ">>,>>>,>>>,>>9.99" decimals 2 initial 0 label "Multa Informada" column-label "Multa Informada"
    field tta_val_tot_reaj_renegoc         as decimal    format ">>,>>>,>>>,>>9.99" decimals 2 initial 0 label "Total Reajuste" column-label "Total Reajuste"
    field tta_val_tot_ajust_renegoc        as decimal    format "->>,>>>,>>>,>>9.99" decimals 2 initial 0 label "Total Ajuste" column-label "Total Ajuste"
    field tta_ind_sit_renegoc_acr          as character  format "X(10)" initial "Pendente" label "Situa»’o" column-label "Situa»’o"
    field tta_cod_refer                    as character  format "x(10)" label "Refer¼ncia" column-label "Refer¼ncia"
    field tta_cod_espec_docto              as character  format "x(3)" label "Esp²cie Documento" column-label "Esp²cie"
    field tta_cod_ser_docto                as character  format "x(3)" label "S²rie Documento" column-label "S²rie"
    field tta_cod_tit_acr                  as character  format "x(10)" label "T­tulo" column-label "T­tulo"
    field tta_cod_parcela                  as character  format "x(02)" label "Parcela" column-label "Parc"
    field tta_dat_vencto_tit_acr           as date       format "99/99/9999" initial ? label "Vencimento" column-label "Vencimento"
    field tta_cod_portador                 as character  format "x(5)" label "Portador" column-label "Portador"
    field tta_cod_cart_bcia                as character  format "x(3)" label "Carteira" column-label "Carteira"
    field tta_cod_indic_econ               as character  format "x(8)" label "Moeda" column-label "Moeda"
    field tta_cdn_repres                   as Integer    format ">>>,>>9" initial 0 label "Representante" column-label "Representante"
    field tta_ind_base_calc_reaj           as character  format "X(17)" initial "Principal" label "Base Cÿlculo" column-label "Base Cÿlculo"
    field tta_val_tit_acr                  as decimal    format ">>>,>>>,>>9.99" decimals 2 initial 0 label "Valor" column-label "Valor"
    field tta_qtd_parc_renegoc             as decimal    format ">9" initial 1 label "Qtd Parcelas" column-label "Qtd Parcelas"
    field tta_ind_vencto_renegoc           as character  format "X(10)" initial "Diÿria" label "Periodicidade Vencto" column-label "Vencimento"
    field tta_num_dia_mes_base_vencto      as integer    format ">9" initial 0 label "Dia Base Vencto" column-label "Dia Base Ven"
    field tta_num_dias_vencto_renegoc      as integer    format ">9" initial 0 label "Dias Vencimentto" column-label "Dias Vencimento"
    field tta_cod_indic_econ_reaj_renegoc  as character  format "x(8)" label "Ind Reajuste" column-label "™ndice Reaj"
    field tta_dat_primei_vencto_renegoc    as date       format "99/99/9999" initial ? label "Primeiro Vencto" column-label "Primeiro Vencto"
    field tta_ind_calc_juros_desc          as character  format "X(08)" label "Cÿlculo Juros" column-label "Cÿlculo Juros"
    field tta_cod_cond_cobr                as character  format "x(8)" label "Condi»’o Cobran»a" column-label "Cond Cobran»a"
    field tta_log_juros_param_estab_reaj   as logical    format "Sim/N’o" initial yes label "Consid Juros Padr’o" column-label "Juros Pad"
    field ttv_rec_renegoc_acr              as recid      format ">>>>>>9" initial ?
    field ttv_log_atualiza_salario_admit   as logical    format "Sim/N’o" initial No
    field ttv_log_atualiza_renegoc         as logical    format "Sim/N’o" initial no
    field ttv_cod_usuar_corren             as character  format "x(12)" label "Usuÿrio Corrente" column-label "Usuÿrio Corrente"
    field tta_log_soma_movto_cobr          as logical    format "Sim/N’o" initial no label "Soma Movtos Cobr" column-label "Soma Movtos Cobr"
    field tta_val_acresc_parc              as decimal    format ">>9.99" decimals 2 initial 0 label "Acrescimo Parcela" column-label "Acrescimo Parcela"
    index tt_rngccr_id                     is primary unique
          tta_cod_estab                    ascending
          tta_num_renegoc_cobr_acr         ascending
    .

def temp-table tt_integr_acr_item_renegoc no-undo
    field tta_cod_estab                    as character  format "x(3)" label "Estabelecimento" column-label "Estab"
    field tta_num_renegoc_cobr_acr         as integer    format ">>>>,>>9" initial 0 label "Num. Renegoc" column-label "Renegocia»’o"
    field tta_cod_estab_tit_acr            as character  format "x(8)" label "Estab T­tulo ACR" column-label "Estab T­tulo ACR"
    field tta_num_id_tit_acr               as integer    format "9999999999" initial 0 label "Token Cta Receber" column-label "Token Cta Receber"
    field tta_dat_novo_vencto_tit_acr      as date       format "99/99/9999" initial ? label "Novo Vencimento" column-label "Novo Vencimento"
    field tta_val_juros_renegoc_tit_acr    as decimal    format "->>,>>>,>>>,>>9.99" decimals 2 initial 0 label "Valor Juros" column-label "Valor Juros"
    field tta_val_multa_renegoc_tit_acr    as decimal    format "->>,>>>,>>>,>>9.99" decimals 2 initial 0 label "Valor Multa" column-label "Valor Multa"
    field tta_val_juros_renegoc_calcul     as decimal    format "->>,>>>,>>>,>>9.99" decimals 2 initial 0 label "Juros Calculado" column-label "Juros Calc"
    field tta_val_multa_renegoc_calcul     as decimal    format ">>,>>>,>>>,>>9.99" decimals 2 initial 0 label "Multa Calculada" column-label "Multa Calcul"
    field tta_cod_livre_1                  as character  format "x(100)" label "Livre 1" column-label "Livre 1"
    field tta_cod_livre_2                  as character  format "x(100)" label "Livre 2" column-label "Livre 2"
    field tta_log_livre_1                  as logical    format "Sim/N’o" initial no label "Livre 1" column-label "Livre 1"
    field tta_log_livre_2                  as logical    format "Sim/N’o" initial no label "Livre 2" column-label "Livre 2"
    field tta_num_livre_1                  as integer    format ">>>>>9" initial 0 label "Livre 1" column-label "Livre 1"
    field tta_num_livre_2                  as integer    format ">>>>>9" initial 0 label "Livre 2" column-label "Livre 2"
    field tta_val_livre_1                  as decimal    format ">>>,>>>,>>9.9999" decimals 4 initial 0 label "Livre 1" column-label "Livre 1"
    field tta_val_livre_2                  as decimal    format ">>>,>>>,>>9.9999" decimals 4 initial 0 label "Livre 2" column-label "Livre 2"
    field tta_dat_livre_1                  as date       format "99/99/9999" initial ? label "Livre 1" column-label "Livre 1"
    field tta_dat_livre_2                  as date       format "99/99/9999" initial ? label "Livre 2" column-label "Livre 2"
    field ttv_rec_renegoc_acr              as recid      format ">>>>>>9" initial ?
    index tt_rec_index                    
          ttv_rec_renegoc_acr              ascending
    .

def temp-table tt_integr_acr_item_lote_impl_7 no-undo
    field ttv_rec_lote_impl_tit_acr        as recid      format ">>>>>>9" initial ?
    field tta_num_seq_refer                as integer    format ">>>9" initial 0 label "Sequ¼ncia" column-label "Seq"
    field tta_cdn_cliente                  as Integer    format ">>>,>>>,>>9" initial 0 label "Cliente" column-label "Cliente"
    field tta_cod_espec_docto              as character  format "x(3)" label "Esp²cie Documento" column-label "Esp²cie"
    field tta_cod_ser_docto                as character  format "x(3)" label "S²rie Documento" column-label "S²rie"
    field tta_cod_tit_acr                  as character  format "x(10)" label "T­tulo" column-label "T­tulo"
    field tta_cod_parcela                  as character  format "x(02)" label "Parcela" column-label "Parc"
    field tta_cod_indic_econ               as character  format "x(8)" label "Moeda" column-label "Moeda"
    field tta_cod_finalid_econ_ext         as character  format "x(8)" label "Finalid Econ Externa" column-label "Finalidade Externa"
    field tta_cod_portador                 as character  format "x(5)" label "Portador" column-label "Portador"
    field tta_cod_portad_ext               as character  format "x(8)" label "Portador Externo" column-label "Portador Externo"
    field tta_cod_cart_bcia                as character  format "x(3)" label "Carteira" column-label "Carteira"
    field tta_cod_modalid_ext              as character  format "x(8)" label "Modalidade Externa" column-label "Modalidade Externa"
    field tta_cod_cond_cobr                as character  format "x(8)" label "Condi»’o Cobran»a" column-label "Cond Cobran»a"
    field tta_cod_motiv_movto_tit_acr      as character  format "x(8)" label "Motivo Movimento" column-label "Motivo Movimento"
    field tta_cod_histor_padr              as character  format "x(8)" label "Hist½rico Padr’o" column-label "Hist½rico Padr’o"
    field tta_cdn_repres                   as Integer    format ">>>,>>9" initial 0 label "Representante" column-label "Representante"
    field tta_dat_vencto_tit_acr           as date       format "99/99/9999" initial ? label "Vencimento" column-label "Vencimento"
    field tta_dat_prev_liquidac            as date       format "99/99/9999" initial ? label "Prev Liquida»’o" column-label "Prev Liquida»’o"
    field tta_dat_desconto                 as date       format "99/99/9999" initial ? label "Data Desconto" column-label "Dt Descto"
    field tta_dat_emis_docto               as date       format "99/99/9999" initial today label "Data  Emiss’o" column-label "Dt Emiss’o"
    field tta_val_tit_acr                  as decimal    format ">>>,>>>,>>9.99" decimals 2 initial 0 label "Valor" column-label "Valor"
    field tta_val_desconto                 as decimal    format "->>>,>>>,>>9.99" decimals 2 initial 0 label "Valor Desconto" column-label "Valor Desconto"
    field tta_val_perc_desc                as decimal    format ">9.9999" decimals 4 initial 0 label "Percentual Desconto" column-label "Perc Descto"
    field tta_val_perc_juros_dia_atraso    as decimal    format ">9.999999" decimals 6 initial 00.00 label "Perc Jur Dia Atraso" column-label "Perc Dia"
    field tta_val_perc_multa_atraso        as decimal    format ">9.99" decimals 2 initial 00.00 label "Perc Multa Atraso" column-label "Multa Atr"
    field tta_val_base_calc_comis          as decimal    format ">>>,>>>,>>9.99" decimals 2 initial 0 label "Base Calc Comis" column-label "Base Calc Comis"
    field tta_des_text_histor              as character  format "x(2000)" label "Hist½rico" column-label "Hist½rico"
    field tta_qtd_dias_carenc_multa_acr    as decimal    format ">>9" initial 0 label "Dias Carenc Multa" column-label "Dias Carenc Multa"
    field tta_cod_banco                    as character  format "x(8)" label "Banco" column-label "Banco"
    field tta_cod_agenc_bcia               as character  format "x(10)" label "Ag¼ncia Bancÿria" column-label "Ag¼ncia Bancÿria"
    field tta_cod_cta_corren_bco           as character  format "x(20)" label "Conta Corrente Banco" column-label "Conta Corrente Banco"
    field tta_cod_digito_cta_corren        as character  format "x(2)" label "D­gito Cta Corrente" column-label "D­gito Cta Corrente"
    field tta_cod_instruc_bcia_1_movto     as character  format "x(4)" label "Instr Bancÿria 1" column-label "Instr Banc 1"
    field tta_cod_instruc_bcia_2_movto     as character  format "x(4)" label "Instr Bancÿria 2" column-label "Instr Banc 2"
    field tta_qtd_dias_carenc_juros_acr    as decimal    format ">>9" initial 0 label "Dias Carenc Juros" column-label "Dias Juros"
    field tta_val_liq_tit_acr              as decimal    format ">>>,>>>,>>9.99" decimals 2 initial 0 label "Vl L­quido" column-label "Vl L­quido"
    field tta_ind_tip_espec_docto          as character  format "X(17)" initial "Normal" label "Tipo Esp²cie" column-label "Tipo Esp²cie"
    field tta_cod_cond_pagto               as character  format "x(8)" label "Condi»’o Pagamento" column-label "Condi»’o Pagamento"
    field ttv_cdn_agenc_fp                 as Integer    format ">>>9" label "Ag¼ncia"
    field tta_ind_sit_tit_acr              as character  format "X(13)" initial "Normal" label "Situa»’o T­tulo" column-label "Situa»’o T­tulo"
    field tta_log_liquidac_autom           as logical    format "Sim/N’o" initial no label "Liquidac Automÿtica" column-label "Liquidac Automÿtica"
    field tta_num_id_tit_acr               as integer    format "9999999999" initial 0 label "Token Cta Receber" column-label "Token Cta Receber"
    field tta_num_id_movto_tit_acr         as integer    format "9999999999" initial 0 label "Token Movto Tit  ACR" column-label "Token Movto Tit  ACR"
    field tta_num_id_movto_cta_corren      as integer    format "9999999999" initial 0 label "ID Movto Conta" column-label "ID Movto Conta"
    field tta_cod_admdra_cartao_cr         as character  format "x(5)" label "Administradora" column-label "Administradora"
    field tta_cod_cartcred                 as character  format "x(20)" label "C½digo Cart’o" column-label "C½digo Cart’o"
    field tta_cod_mes_ano_valid_cartao     as character  format "XX/XXXX" label "Validade Cart’o" column-label "Validade Cart’o"
    field tta_cod_autoriz_cartao_cr        as character  format "x(6)" label "C½d Pr²-Autoriza»’o" column-label "C½d Pr²-Autoriza»’o"
    field tta_dat_compra_cartao_cr         as date       format "99/99/9999" initial ? label "Data Efetiv Venda" column-label "Data Efetiv Venda"
    field tta_cod_conces_telef             as character  format "x(5)" label "Concessionÿria" column-label "Concessionÿria"
    field tta_num_ddd_localid_conces       as integer    format "999" initial 0 label "DDD" column-label "DDD"
    field tta_num_prefix_localid_conces    as integer    format ">>>9" initial 0 label "Prefixo" column-label "Prefixo"
    field tta_num_milhar_localid_conces    as integer    format "9999" initial 0 label "Milhar" column-label "Milhar"
    field tta_log_tip_cr_perda_dedut_tit   as logical    format "Sim/N’o" initial no label "Credito com Garantia" column-label "Cred Garant"
    field tta_cod_refer                    as character  format "x(10)" label "Refer¼ncia" column-label "Refer¼ncia"
    field tta_ind_ender_cobr               as character  format "X(15)" initial "Cliente" label "Endere»o Cobran»a" column-label "Endere»o Cobran»a"
    field tta_nom_abrev_contat             as character  format "x(15)" label "Abreviado Contato" column-label "Abreviado Contato"
    field tta_log_db_autom                 as logical    format "Sim/N’o" initial no label "D²bito Automÿtico" column-label "D²bito Automÿtico"
    field tta_log_destinac_cobr            as logical    format "Sim/N’o" initial no label "Destin Cobran»a" column-label "Destin Cobran»a"
    field tta_ind_sit_bcia_tit_acr         as character  format "X(12)" initial "Liberado" label "Sit Bancÿria" column-label "Sit Bancÿria"
    field tta_cod_tit_acr_bco              as character  format "x(20)" label "Num T­tulo Banco" column-label "Num T­tulo Banco"
    field tta_cod_agenc_cobr_bcia          as character  format "x(10)" label "Ag¼ncia Cobran»a" column-label "Ag¼ncia Cobr"
    field tta_dat_abat_tit_acr             as date       format "99/99/9999" initial ? label "Abat" column-label "Abat"
    field tta_val_perc_abat_acr            as decimal    format ">>9.9999" decimals 4 initial 0 label "Perc Abatimento" column-label "Abatimento"
    field tta_val_abat_tit_acr             as decimal    format ">>>>,>>>,>>9.99" decimals 2 initial 0 label "Vl Abatimento" column-label "Vl Abatimento"
    field tta_des_obs_cobr                 as character  format "x(40)" label "Obs Cobran»a" column-label "Obs Cobran»a"
    field tta_val_cotac_indic_econ         as decimal    format ">>>>,>>9.9999999999" decimals 10 initial 0 label "Cota»’o" column-label "Cota»’o"
    field ttv_rec_item_lote_impl_tit_acr   as recid      format ">>>>>>9"
    field tta_ind_tip_calc_juros           as character  format "x(10)" initial "Simples" label "Tipo Cÿlculo Juros" column-label "Tipo Cÿlculo Juros"
    field ttv_cod_comprov_vda              as character  format "x(12)" label "Comprovante Venda" column-label "Comprovante Venda"
    field ttv_num_parc_cartcred            as integer    format ">9" label "Quantidade Parcelas" column-label "Quantidade Parcelas"
    field ttv_cod_autoriz_bco_emissor      as character  format "x(6)" label "Codigo Autoriza»’o" column-label "Codigo Autoriza»’o"
    field ttv_cod_lote_origin              as character  format "x(7)" label "Lote Orig Venda" column-label "Lote Orig Venda"
    field ttv_cod_estab_vendor             as character  format "x(3)" label "Estabelecimento" column-label "Estabelecimento"
    field ttv_num_planilha_vendor          as integer    format ">>>,>>>,>>9" initial 0 label "Planilha Vendor" column-label "Planilha Vendor"
    field ttv_cod_cond_pagto_vendor        as character  format "x(3)" initial "0" label "Condi»’o Pagto" column-label "Condi»’o Pagto"
    field ttv_val_cotac_tax_vendor_clien   as decimal    format ">>9.9999999999" decimals 10 label "Taxa Vendor Cliente" column-label "Taxa Vendor Cliente"
    field ttv_dat_base_fechto_vendor       as date       format "99/99/9999" initial today label "Data Base" column-label "Data Base"
    field ttv_qti_dias_carenc_fechto       as Integer    format "->>9" label "Dias Car¼ncia" column-label "Dias Car¼ncia"
    field ttv_log_assume_tax_bco           as logical    format "Sim/N’o" initial no label "Assume Taxa Banco" column-label "Assume Taxa Banco"
    field ttv_log_vendor                   as logical    format "Sim/N’o" initial no
    field ttv_cod_estab_portad             as character  format "x(8)"
    field tta_cod_proces_export            as character  format "x(12)" label "Processo Exporta»’o" column-label "Processo Exporta»’o"
    field ttv_val_cr_pis                   as decimal    format ">>>,>>>,>>9.99" decimals 2 initial 0 label "Valor Cr²dito PIS" column-label "Vl Cred PIS/PASEP"
    field ttv_val_cr_cofins                as decimal    format ">>>,>>>,>>9.99" decimals 2 initial 0 label "Valor Cr²dito COFINS" column-label "Credito COFINS"
    field ttv_val_cr_csll                  as decimal    format ">>>,>>>,>>9.99" decimals 2 initial 0 label "Valor Cr²dito CSLL" column-label "Credito CSLL"
    field tta_cod_indic_econ_desemb        as character  format "x(8)" label "Moeda Desembolso" column-label "Moeda Desembolso"
    field tta_val_base_calc_impto          as decimal    format ">>>,>>>,>>9.99" decimals 2 initial 0 label "Base Cÿlculo Impto" column-label "Base Cÿlculo Impto"
    field tta_log_retenc_impto_impl        as logical    format "Sim/N’o" initial no label "Ret Imposto Impl" column-label "Ret Imposto Impl"
    index tt_id                            is primary unique
          ttv_rec_lote_impl_tit_acr        ascending
          tta_num_seq_refer                ascending
    .

def temp-table tt_integr_acr_fiador_renegoc no-undo
    field tta_cod_estab                    as character  format "x(3)" label "Estabelecimento" column-label "Estab"
    field tta_num_renegoc_cobr_acr         as integer    format ">>>>,>>9" initial 0 label "Num. Renegoc" column-label "Renegocia»’o"
    field tta_num_seq                      as integer    format ">>>,>>9" initial 0 label "Sequ¼ncia" column-label "NumSeq"
    field tta_ind_testem_fiador            as character  format "X(08)" label "Testem/Fiador" column-label "Testem/Fiador"
    field tta_ind_tip_pessoa               as character  format "X(08)" label "Tipo Pessoa" column-label "Tipo Pessoa"
    field tta_num_pessoa                   as integer    format ">>>,>>>,>>9" initial ? label "Pessoa" column-label "Pessoa"
    field tta_nom_abrev                    as character  format "x(15)" label "Nome Abreviado" column-label "Nome Abreviado"
    field tta_cod_livre_1                  as character  format "x(100)" label "Livre 1" column-label "Livre 1"
    field tta_cod_livre_2                  as character  format "x(100)" label "Livre 2" column-label "Livre 2"
    field tta_log_livre_1                  as logical    format "Sim/N’o" initial no label "Livre 1" column-label "Livre 1"
    field tta_log_livre_2                  as logical    format "Sim/N’o" initial no label "Livre 2" column-label "Livre 2"
    field tta_num_livre_1                  as integer    format ">>>>>9" initial 0 label "Livre 1" column-label "Livre 1"
    field tta_num_livre_2                  as integer    format ">>>>>9" initial 0 label "Livre 2" column-label "Livre 2"
    field tta_val_livre_1                  as decimal    format ">>>,>>>,>>9.9999" decimals 4 initial 0 label "Livre 1" column-label "Livre 1"
    field tta_val_livre_2                  as decimal    format ">>>,>>>,>>9.9999" decimals 4 initial 0 label "Livre 2" column-label "Livre 2"
    field tta_dat_livre_1                  as date       format "99/99/9999" initial ? label "Livre 1" column-label "Livre 1"
    field tta_dat_livre_2                  as date       format "99/99/9999" initial ? label "Livre 2" column-label "Livre 2"
    field ttv_rec_renegoc_acr              as recid      format ">>>>>>9" initial ?
    field ttv_rec_pessoa_fisic_jurid       as recid      format ">>>>>>9"
    index tt_rec_renegoc_id               
          ttv_rec_renegoc_acr              ascending
    .

def temp-table tt_pessoa_fisic_integr no-undo
    field tta_num_pessoa_fisic             as integer    format ">>>,>>>,>>9" initial 0 label "Pessoa F­sica" column-label "Pessoa F­sica"
    field tta_nom_pessoa                   as character  format "x(40)" label "Nome" column-label "Nome"
    field tta_cod_id_feder                 as character  format "x(20)" initial ? label "ID Federal" column-label "ID Federal"
    field tta_cod_id_estad_fisic           as character  format "x(20)" initial ? label "ID Estadual F­sica" column-label "ID Estadual F­sica"
    field tta_cod_orgao_emis_id_estad      as character  format "x(10)" label "…rg’o Emissor" column-label "…rg’o Emissor"
    field tta_cod_unid_federac_emis_estad  as character  format "x(3)" label "Estado Emiss’o" column-label "UF Emis"
    field tta_nom_endereco                 as character  format "x(40)" label "Endere»o" column-label "Endere»o"
    field tta_nom_ender_compl              as character  format "x(10)" label "Complemento" column-label "Complemento"
    field tta_nom_bairro                   as character  format "x(20)" label "Bairro" column-label "Bairro"
    field tta_nom_cidade                   as character  format "x(32)" label "Cidade" column-label "Cidade"
    field tta_nom_condado                  as character  format "x(32)" label "Condado" column-label "Condado"
    field tta_cod_pais_ext                 as character  format "x(20)" label "Pa­s Externo" column-label "Pa­s Externo"
    field tta_cod_pais                     as character  format "x(3)" label "Pa­s" column-label "Pa­s"
    field tta_cod_unid_federac             as character  format "x(3)" label "Unidade Federa»’o" column-label "UF"
    field tta_cod_cep                      as character  format "x(20)" label "CEP" column-label "CEP"
    field tta_cod_cx_post                  as character  format "x(20)" label "Caixa Postal" column-label "Caixa Postal"
    field tta_cod_telefone                 as character  format "x(20)" label "Telefone" column-label "Telefone"
    field tta_cod_ramal                    as character  format "x(7)" label "Ramal" column-label "Ramal"
    field tta_cod_fax                      as character  format "x(20)" label "FAX" column-label "FAX"
    field tta_cod_ramal_fax                as character  format "x(07)" label "Ramal Fax" column-label "Ramal Fax"
    field tta_cod_telex                    as character  format "x(7)" label "TELEX" column-label "TELEX"
    field tta_cod_modem                    as character  format "x(20)" label "Modem" column-label "Modem"
    field tta_cod_ramal_modem              as character  format "x(07)" label "Ramal Modem" column-label "Ramal Modem"
    field tta_cod_e_mail                   as character  format "x(40)" label "Internet E-Mail" column-label "Internet E-Mail"
    field tta_dat_nasc_pessoa_fisic        as date       format "99/99/9999" initial ? label "Nascimento" column-label "Data Nasc"
    field ttv_cod_pais_ext_nasc            as character  format "x(20)" label "Pa­s Ext Nascimento" column-label "Pa­s Ext Nascimento"
    field ttv_cod_pais_nasc                as character  format "x(3)" label "Pa­s Nascimento" column-label "Pa­s Nasc"
    field tta_cod_unid_federac_nasc        as character  format "x(3)" label "Estado Nascimento" column-label "UF Nasc"
    field tta_des_anot_tab                 as character  format "x(2000)" label "Anota»’o Tabela" column-label "Anota»’o Tabela"
    field tta_nom_mae_pessoa               as character  format "x(40)" label "M’e Pessoa" column-label "M’e Pes"
    field tta_cod_imagem                   as character  format "x(30)" label "Imagem" column-label "Imagem"
    field tta_log_ems_20_atlzdo            as logical    format "Sim/N’o" initial no label "2.0 Atualizado" column-label "2.0 Atualizado"
    field ttv_num_tip_operac               as integer    format ">9" column-label "Tipo  Opera»’o"
    field ttv_rec_fiador_renegoc           as recid      format ">>>>>>9" initial ?
    index tt_pssfsca_id                    is primary unique
          tta_num_pessoa_fisic             ascending
          tta_cod_id_feder                 ascending
          tta_cod_pais_ext                 ascending
    index tt_pssfsca_identpes             
          tta_nom_pessoa                   ascending
          tta_cod_id_estad_fisic           ascending
          tta_cod_unid_federac_emis_estad  ascending
          tta_dat_nasc_pessoa_fisic        ascending
          tta_nom_mae_pessoa               ascending
    index tt_pssfsca_nom_pessoa_word      
          tta_nom_pessoa                   ascending
    index tt_pssfsca_unid_federac         
          tta_cod_pais_ext                 ascending
          tta_cod_unid_federac             ascending
    .

def temp-table tt_pessoa_jurid_integr no-undo
    field tta_num_pessoa_jurid             as integer    format ">>>,>>>,>>9" initial 0 label "Pessoa Jur­dica" column-label "Pessoa Jur­dica"
    field tta_nom_pessoa                   as character  format "x(40)" label "Nome" column-label "Nome"
    field tta_cod_id_feder                 as character  format "x(20)" initial ? label "ID Federal" column-label "ID Federal"
    field tta_cod_id_estad_jurid           as character  format "x(20)" initial ? label "ID Estadual" column-label "ID Estadual"
    field tta_cod_id_munic_jurid           as character  format "x(20)" initial ? label "ID Municipal" column-label "ID Municipal"
    field tta_cod_id_previd_social         as character  format "x(20)" label "Id Previd¼ncia" column-label "Id Previd¼ncia"
    field tta_log_fins_lucrat              as logical    format "Sim/N’o" initial yes label "Fins Lucrativos" column-label "Fins Lucrativos"
    field tta_num_pessoa_jurid_matriz      as integer    format ">>>,>>>,>>9" initial 0 label "Matriz" column-label "Matriz"
    field tta_nom_endereco                 as character  format "x(40)" label "Endere»o" column-label "Endere»o"
    field tta_nom_ender_compl              as character  format "x(10)" label "Complemento" column-label "Complemento"
    field tta_nom_bairro                   as character  format "x(20)" label "Bairro" column-label "Bairro"
    field tta_nom_cidade                   as character  format "x(32)" label "Cidade" column-label "Cidade"
    field tta_nom_condado                  as character  format "x(32)" label "Condado" column-label "Condado"
    field tta_cod_pais_ext                 as character  format "x(20)" label "Pa­s Externo" column-label "Pa­s Externo"
    field tta_cod_pais                     as character  format "x(3)" label "Pa­s" column-label "Pa­s"
    field tta_cod_unid_federac             as character  format "x(3)" label "Unidade Federa»’o" column-label "UF"
    field tta_cod_cep                      as character  format "x(20)" label "CEP" column-label "CEP"
    field tta_cod_cx_post                  as character  format "x(20)" label "Caixa Postal" column-label "Caixa Postal"
    field tta_cod_telefone                 as character  format "x(20)" label "Telefone" column-label "Telefone"
    field tta_cod_fax                      as character  format "x(20)" label "FAX" column-label "FAX"
    field tta_cod_ramal_fax                as character  format "x(07)" label "Ramal Fax" column-label "Ramal Fax"
    field tta_cod_telex                    as character  format "x(7)" label "TELEX" column-label "TELEX"
    field tta_cod_modem                    as character  format "x(20)" label "Modem" column-label "Modem"
    field tta_cod_ramal_modem              as character  format "x(07)" label "Ramal Modem" column-label "Ramal Modem"
    field tta_cod_e_mail                   as character  format "x(40)" label "Internet E-Mail" column-label "Internet E-Mail"
    field tta_des_anot_tab                 as character  format "x(2000)" label "Anota»’o Tabela" column-label "Anota»’o Tabela"
    field tta_ind_tip_pessoa_jurid         as character  format "X(08)" label "Tipo Pessoa" column-label "Tipo Pessoa"
    field tta_ind_tip_capit_pessoa_jurid   as character  format "X(13)" label "Tipo Capital" column-label "Tipo Capital"
    field tta_cod_imagem                   as character  format "x(30)" label "Imagem" column-label "Imagem"
    field tta_log_ems_20_atlzdo            as logical    format "Sim/N’o" initial no label "2.0 Atualizado" column-label "2.0 Atualizado"
    field ttv_num_tip_operac               as integer    format ">9" column-label "Tipo  Opera»’o"
    field tta_num_pessoa_jurid_cobr        as integer    format ">>>,>>>,>>9" initial 0 label "Pessoa Jur­dica Cobr" column-label "Pessoa Jur­dica Cobr"
    field tta_nom_ender_cobr               as character  format "x(40)" label "Endere»o Cobran»a" column-label "Endere»o Cobran»a"
    field tta_nom_ender_compl_cobr         as character  format "x(10)" label "Complemento" column-label "Complemento"
    field tta_nom_bairro_cobr              as character  format "x(20)" label "Bairro Cobran»a" column-label "Bairro Cobran»a"
    field tta_nom_cidad_cobr               as character  format "x(32)" label "Cidade Cobran»a" column-label "Cidade Cobran»a"
    field tta_nom_condad_cobr              as character  format "x(32)" label "Condado Cobran»a" column-label "Condado Cobran»a"
    field tta_cod_unid_federac_cobr        as character  format "x(3)" label "Unidade Federa»’o" column-label "Unidade Federa»’o"
    field ttv_cod_pais_ext_cob             as character  format "x(20)" label "Pa­s Externo" column-label "Pa­s Externo"
    field ttv_cod_pais_cobr                as character  format "x(3)" label "Pa­s Cobran»a" column-label "Pa­s Cobran»a"
    field tta_cod_cep_cobr                 as character  format "x(20)" label "CEP Cobran»a" column-label "CEP Cobran»a"
    field tta_cod_cx_post_cobr             as character  format "x(20)" label "Caixa Postal Cobran»" column-label "Caixa Postal Cobran»"
    field tta_num_pessoa_jurid_pagto       as integer    format ">>>,>>>,>>9" initial 0 label "Pessoa Jurid Pagto" column-label "Pessoa Jurid Pagto"
    field tta_nom_ender_pagto              as character  format "x(40)" label "Endere»o Pagamento" column-label "Endere»o Pagamento"
    field tta_nom_ender_compl_pagto        as character  format "x(10)" label "Complemento" column-label "Complemento"
    field tta_nom_bairro_pagto             as character  format "x(20)" label "Bairro Pagamento" column-label "Bairro Pagamento"
    field tta_nom_cidad_pagto              as character  format "x(32)" label "Cidade Pagamento" column-label "Cidade Pagamento"
    field tta_nom_condad_pagto             as character  format "x(32)" label "Condado Pagamento" column-label "Condado Pagamento"
    field tta_cod_unid_federac_pagto       as character  format "x(3)" label "Unidade Federa»’o" column-label "Unidade Federa»’o"
    field ttv_cod_pais_ext_pag             as character  format "x(20)" label "Pa­s Externo" column-label "Pa­s Externo"
    field ttv_cod_pais_pagto               as character  format "x(3)" label "Pa­s Pagamento" column-label "Pa­s Pagamento"
    field tta_cod_cep_pagto                as character  format "x(20)" label "CEP Pagamento" column-label "CEP Pagamento"
    field tta_cod_cx_post_pagto            as character  format "x(20)" label "Caixa Postal Pagamen" column-label "Caixa Postal Pagamen"
    field ttv_rec_fiador_renegoc           as recid      format ">>>>>>9" initial ?
    index tt_pssjrda_cobranca             
          tta_num_pessoa_jurid_cobr        ascending
    index tt_pssjrda_id                    is primary unique
          tta_num_pessoa_jurid             ascending
          tta_cod_id_feder                 ascending
          tta_cod_pais_ext                 ascending
    index tt_pssjrda_id_previd_social     
          tta_cod_pais_ext                 ascending
          tta_cod_id_previd_social         ascending
    index tt_pssjrda_matriz               
          tta_num_pessoa_jurid_matriz      ascending
    index tt_pssjrda_nom_pessoa_word      
          tta_nom_pessoa                   ascending
    index tt_pssjrda_pagto                
          tta_num_pessoa_jurid_pagto       ascending
    index tt_pssjrda_razao_social         
          tta_nom_pessoa                   ascending
    index tt_pssjrda_unid_federac         
          tta_cod_pais_ext                 ascending
          tta_cod_unid_federac             ascending
    .

def temp-table tt_log_erros_renegoc_acr no-undo
    field tta_cod_estab                    as character  format "x(3)" label "Estabelecimento" column-label "Estab"
    field tta_num_renegoc_cobr_acr         as integer    format ">>>>,>>9" initial 0 label "Num. Renegoc" column-label "Renegocia»’o"
    field tta_num_seq_item_renegoc_acr     as integer    format ">>>>,>>9" initial 0 label "Sequ¼ncia Item" column-label "Sequ¼ncia Item"
    field tta_cdn_cliente                  as Integer    format ">>>,>>>,>>9" initial 0 label "Cliente" column-label "Cliente"
    field tta_cod_espec_docto              as character  format "x(3)" label "Esp²cie Documento" column-label "Esp²cie"
    field tta_cod_ser_docto                as character  format "x(3)" label "S²rie Documento" column-label "S²rie"
    field tta_cod_tit_acr                  as character  format "x(10)" label "T­tulo" column-label "T­tulo"
    field tta_cod_parcela                  as character  format "x(02)" label "Parcela" column-label "Parc"
    field tta_cod_fiador                   as character  format "x(8)" label "Fiador" column-label "Fiador"
    field tta_num_pessoa                   as integer    format ">>>,>>>,>>9" initial ? label "Pessoa" column-label "Pessoa"
    field tta_num_mensagem                 as integer    format ">>,>>>,>>9" initial 0 label "Mensagem" column-label "Mensagem"
    field ttv_des_msg                      as character  format "x(40)"
    .

def temp-table tt_integr_acr_liquidac_lote no-undo
    field tta_cod_empresa                  as character format "x(3)" label "Empresa" column-label "Empresa"
    field tta_cod_estab_refer              as character format "x(3)" initial ? label "Estabelecimento" column-label "Estab"
    field tta_cod_refer                    as character format "x(10)" label "Refer¼ncia" column-label "Refer¼ncia"
    field tta_cod_usuario                  as character format "x(12)" label "Usuÿrio" column-label "Usuÿrio"
    field ttv_cod_indic_econ               as character format "x(8)" label "Moeda" column-label "Moeda"
    field tta_cod_portador                 as character format "x(5)" label "Portador" column-label "Portador"
    field tta_cod_cart_bcia                as character format "x(3)" label "Carteira" column-label "Carteira"
    field tta_dat_transacao                as date      format "99/99/9999" initial today label "Data Transa»’o" column-label "Dat Transac"
    field tta_dat_gerac_lote_liquidac      as date      format "99/99/9999" initial ? label "Data Gera»’o" column-label "Data Gera»’o"
    field tta_val_tot_lote_liquidac_infor  as decimal   format "->>,>>>,>>>,>>9.99" decimals 2 initial 0 label "Total Informado" column-label "Total Informado"
    field tta_val_tot_lote_liquidac_efetd  as decimal   format "->>,>>>,>>>,>>9.99" decimals 2 initial 0 label "Total Movimento" column-label "Vl Tot Movto"
    field tta_val_tot_despes_bcia          as decimal   format ">>>>,>>>,>>9.99" decimals 2 initial 0 label "Total Desp Bcia" column-label "Desp Bcia"
    field tta_ind_tip_liquidac_acr         as character format "X(15)" initial "Lote" label "Tipo Liquidacao" column-label "Tipo Liquidacao"
    field tta_ind_sit_lote_liquidac_acr    as character format "X(15)" initial "Em Digita»’o" label "Situa»’o" column-label "Situa»’o"
    field tta_nom_arq_movimen_bcia         as character format "x(30)" label "Nom Arq Bancaria" column-label "Nom Arq Bancaria"
    field tta_cdn_cliente                  as Integer   format ">>>,>>>,>>9" initial 0 label "Cliente" column-label "Cliente"
    field tta_log_enctro_cta               as logical   format "Sim/N’o" initial no label "Encontro de Contas" column-label "Encontro de Contas"
    field tta_cod_livre_1                  as character format "x(100)" label "Livre 1" column-label "Livre 1"
    field tta_dat_livre_1                  as date      format "99/99/9999" initial ? label "Livre 1" column-label "Livre 1"
    field tta_log_livre_1                  as logical   format "Sim/N’o" initial no label "Livre 1" column-label "Livre 1"
    field tta_num_livre_1                  as integer   format ">>>>>9" initial 0 label "Livre 1" column-label "Livre 1"
    field tta_val_livre_1                  as decimal   format ">>>,>>>,>>9.9999" decimals 4 initial 0 label "Livre 1" column-label "Livre 1"
    field tta_cod_livre_2                  as character format "x(100)" label "Livre 2" column-label "Livre 2"
    field tta_dat_livre_2                  as date      format "99/99/9999" initial ? label "Livre 2" column-label "Livre 2"
    field tta_log_livre_2                  as logical   format "Sim/N’o" initial no label "Livre 2" column-label "Livre 2"
    field tta_num_livre_2                  as integer   format ">>>>>9" initial 0 label "Livre 2" column-label "Livre 2"
    field tta_val_livre_2                  as decimal   format ">>>,>>>,>>9.9999" decimals 4 initial 0 label "Livre 2" column-label "Livre 2"
    field ttv_rec_lote_liquidac_acr        as recid     format ">>>>>>9" initial ?
    field ttv_log_atualiz_refer            as logical   format "Sim/N’o" initial no
    field ttv_log_gera_lote_parcial        as logical   format "Sim/N’o" initial no
    index tt_itlqdccr_id                   is primary unique
          tta_cod_estab_refer              ascending
          tta_cod_refer                    ascending
    .

def temp-table tt_integr_acr_liq_item_lote no-undo
    field tta_cod_empresa                  as character format "x(3)" label "Empresa" column-label "Empresa"
    field tta_cod_estab                    as character format "x(3)" label "Estabelecimento" column-label "Estab"
    field tta_cod_espec_docto              as character format "x(3)" label "Esp²cie Documento" column-label "Esp²cie"
    field tta_cod_ser_docto                as character format "x(3)" label "S²rie Documento" column-label "S²rie"
    field tta_num_seq_refer                as integer   format ">>>9" initial 0 label "Sequ¼ncia" column-label "Seq"
    field tta_cod_tit_acr                  as character format "x(10)" label "T­tulo" column-label "T­tulo"
    field tta_cod_parcela                  as character format "x(02)" label "Parcela" column-label "Parc"
    field tta_cdn_cliente                  as Integer   format ">>>,>>>,>>9" initial 0 label "Cliente" column-label "Cliente"
    field tta_cod_portador                 as character format "x(5)" label "Portador" column-label "Portador"
    field tta_cod_portad_ext               as character format "x(8)" label "Portador Externo" column-label "Portador Externo"
    field tta_cod_cart_bcia                as character format "x(3)" label "Carteira" column-label "Carteira"
    field tta_cod_modalid_ext              as character format "x(8)" label "Modalidade Externa" column-label "Modalidade Externa"
    field tta_cod_finalid_econ             as character format "x(10)" label "Finalidade" column-label "Finalidade"
    field tta_cod_finalid_econ_ext         as character format "x(8)" label "Finalid Econ Externa" column-label "Finalidade Externa"
    field tta_cod_indic_econ               as character format "x(8)" label "Moeda" column-label "Moeda"
    field tta_dat_cr_liquidac_tit_acr      as date      format "99/99/9999" initial ? label "Data Cr²dito" column-label "Data Cr²dito"
    field tta_dat_cr_liquidac_calc         as date      format "99/99/9999" initial ? label "Cred Calculada" column-label "Cred Calculada"
    field tta_dat_liquidac_tit_acr         as date      format "99/99/9999" initial ? label "Liquida»’o" column-label "Liquida»’o"
    field tta_cod_autoriz_bco              as character format "x(8)" label "Autoriza»’o Bco" column-label "Autorizacao Bco"
    field tta_val_tit_acr                  as decimal   format ">>>,>>>,>>9.99" decimals 2 initial 0 label "Valor" column-label "Valor"
    field tta_val_liquidac_tit_acr         as decimal   format ">>>,>>>,>>9.99" decimals 2 initial 0 label "Vl Liquida»’o" column-label "Vl Liquida»’o"
    field tta_val_desc_tit_acr             as decimal   format ">>>>,>>>,>>9.99" decimals 2 initial 0 label "Vl Desc" column-label "Vl Desc"
    field tta_val_abat_tit_acr             as decimal   format ">>>>,>>>,>>9.99" decimals 2 initial 0 label "Vl Abatimento" column-label "Vl Abatimento"
    field tta_val_despes_bcia              as decimal   format "->>>,>>>,>>9.99" decimals 2 initial 0 label "Vl Desp Banc" column-label "Vl Desp Banc"
    field tta_val_multa_tit_acr            as decimal   format ">>>>,>>>,>>9.99" decimals 2 initial 0 label "Vl Multa" column-label "Vl Multa"
    field tta_val_juros                    as decimal   format ">>>>,>>>,>>9.99" decimals 2 initial 0 label "Valor Juros" column-label "Valor Juros"
    field tta_val_cm_tit_acr               as decimal   format ">>>>,>>>,>>9.99" decimals 2 initial 0 label "Vl CM" column-label "Vl CM"
    field tta_val_liquidac_orig            as decimal   format "->>>,>>>,>>9.99" decimals 2 initial 0 label "Vl Liquid Orig" column-label "Vl Liquid Orig"
    field tta_val_desc_tit_acr_orig        as decimal   format "->>>,>>>,>>9.99" decimals 2 initial 0 label "Vl Desc Orig" column-label "Vl Desc Orig"
    field tta_val_abat_tit_acr_orig        as decimal   format "->>>,>>>,>>9.99" decimals 2 initial 0 label "Vl Abat Orig" column-label "Vl Abat Orig"
    field tta_val_despes_bcia_orig         as decimal   format "->>>,>>>,>>9.99" decimals 2 initial 0 label "Vl Desp Bcia Orig" column-label "Vl Desp Bcia Orig"
    field tta_val_multa_tit_acr_origin     as decimal   format "->>>,>>>,>>9.99" decimals 2 initial 0 label "Vl Multa Orig" column-label "Vl Multa Orig"
    field tta_val_juros_tit_acr_orig       as decimal   format "->>>,>>>,>>9.99" decimals 2 initial 0 label "Vl Juros Orig" column-label "Vl Juros Orig"
    field tta_val_cm_tit_acr_orig          as decimal   format "->>>,>>>,>>9.99" decimals 2 initial 0 label "Vl CM Orig" column-label "Vl CM Orig"
    field tta_val_nota_db_orig             as decimal   format "->>>,>>>,>>9.99" decimals 2 initial 0 label "Valor Nota DB" column-label "Valor Nota DB"
    field tta_log_gera_antecip             as logical   format "Sim/N’o" initial no label "Gera Antecipacao" column-label "Gera Antecipacao"
    field tta_des_text_histor              as character format "x(2000)" label "Hist½rico" column-label "Hist½rico"
    field tta_ind_sit_item_lote_liquidac   as character format "X(09)" initial "Gerado" label "Situa»’o Item Lote" column-label "Situa»’o Item Lote"
    field tta_log_gera_avdeb               as logical   format "Sim/N’o" initial no label "Gera Aviso D²bito" column-label "Gera Aviso D²bito"
    field tta_cod_indic_econ_avdeb         as character format "x(8)" label "Moeda Aviso D²bito" column-label "Moeda Aviso D²bito"
    field tta_cod_portad_avdeb             as character format "x(5)" label "Portador AD" column-label "Portador AD"
    field tta_cod_cart_bcia_avdeb          as character format "x(3)" label "Carteira AD" column-label "Carteira AD"
    field tta_dat_vencto_avdeb             as date      format "99/99/9999" initial ? label "Vencto AD" column-label "Vencto AD"
    field tta_val_perc_juros_avdeb         as decimal   format ">>9.99" decimals 2 initial 0 label "Juros Aviso Debito" column-label "Juros ADebito"
    field tta_val_avdeb                    as decimal   format "->>>,>>>,>>9.99" decimals 2 initial 0 label "Aviso D²bito" column-label "Aviso D²bito"
    field tta_log_movto_comis_estordo      as logical   format "Sim/N’o" initial no label "Estorna Comiss’o" column-label "Estorna Comiss’o"
    field tta_ind_tip_item_liquidac_acr    as character format "X(09)" label "Tipo Item" column-label "Tipo Item"
    field ttv_rec_lote_liquidac_acr        as recid     format ">>>>>>9" initial ?
    field ttv_rec_item_lote_liquidac_acr   as recid     format ">>>>>>9"
    field tta_cod_livre_1                  as character format "x(100)" label "Livre 1" column-label "Livre 1"
    field tta_cod_livre_2                  as character format "x(100)" label "Livre 2" column-label "Livre 2"
    field tta_log_livre_1                  as logical   format "Sim/N’o" initial no label "Livre 1" column-label "Livre 1"
    field tta_log_livre_2                  as logical   format "Sim/N’o" initial no label "Livre 2" column-label "Livre 2"
    field tta_dat_livre_1                  as date      format "99/99/9999" initial ? label "Livre 1" column-label "Livre 1"
    field tta_dat_livre_2                  as date      format "99/99/9999" initial ? label "Livre 2" column-label "Livre 2"
    field tta_val_livre_1                  as decimal   format ">>>,>>>,>>9.9999" decimals 4 initial 0 label "Livre 1" column-label "Livre 1"
    field tta_val_livre_2                  as decimal   format ">>>,>>>,>>9.9999" decimals 4 initial 0 label "Livre 2" column-label "Livre 2"
    field tta_num_livre_1                  as integer   format ">>>>>9" initial 0 label "Livre 1" column-label "Livre 1"
    field tta_num_livre_2                  as integer   format ">>>>>9" initial 0 label "Livre 2" column-label "Livre 2"
    field tta_val_cotac_indic_econ         as decimal   format ">>>>,>>9.9999999999" decimals 10 initial 0 label "Cota»’o" column-label "Cota»’o"
    field tta_ind_tip_calc_juros           as character format "x(10)" initial "Simples" label "Tipo Cÿlculo Juros" column-label "Tipo Cÿlculo Juros"
    index tt_rec_index
          ttv_rec_lote_liquidac_acr        ascending
    .
def new shared temp-table tt_integr_acr_abat_antecip no-undo
    field ttv_rec_item_lote_impl_tit_acr   as recid     format ">>>>>>9"
    field ttv_rec_abat_antecip_acr         as recid     format ">>>>>>9"
    field tta_cod_estab                    as character format "x(3)"  label "Estabelecimento" column-label "Estab"
    field tta_cod_estab_ext                as character format "x(8)"  label "Estabelecimento Exte" column-label "Estabelecimento Ext"
    field tta_cod_espec_docto              as character format "x(3)"  label "Esp²cie Documento" column-label "Esp²cie"
    field tta_cod_ser_docto                as character format "x(3)"  label "S²rie Documento" column-label "S²rie"
    field tta_cod_tit_acr                  as character format "x(10)" label "T­tulo" column-label "T­tulo"
    field tta_cod_parcela                  as character format "x(02)" label "Parcela" column-label "Parc"
    field tta_val_abtdo_antecip_tit_abat   as decimal   format "->>>,>>>,>>9.99" decimals 2 initial 0 label "Vl Abtdo" column-label "Vl Abtdo"
    index tt_id                            is primary unique
          ttv_rec_item_lote_impl_tit_acr   ascending
          tta_cod_estab                    ascending
          tta_cod_estab_ext                ascending
          tta_cod_espec_docto              ascending
          tta_cod_ser_docto                ascending
          tta_cod_tit_acr                  ascending
          tta_cod_parcela                  ascending
    .
def new shared temp-table tt_integr_acr_abat_prev no-undo
    field ttv_rec_item_lote_impl_tit_acr   as recid     format ">>>>>>9"
    field tta_cod_estab                    as character format "x(3)"  label "Estabelecimento" column-label "Estab"
    field tta_cod_estab_ext                as character format "x(8)"  label "Estabelecimento Exte" column-label "Estabelecimento Ext"
    field tta_cod_espec_docto              as character format "x(3)"  label "Esp²cie Documento" column-label "Esp²cie"
    field tta_cod_ser_docto                as character format "x(3)"  label "S²rie Documento" column-label "S²rie"
    field tta_cod_tit_acr                  as character format "x(10)" label "T­tulo" column-label "T­tulo"
    field tta_cod_parcela                  as character format "x(02)" label "Parcela" column-label "Parc"
    field tta_val_abtdo_prev_tit_abat      as decimal   format "->>>,>>>,>>9.99" decimals 2 initial 0 label "Vl Abat" column-label "Vl Abat"
    field tta_log_zero_sdo_prev            as logical   format "Sim/N’o" initial no label "Zera Saldo" column-label "Zera Saldo"
    index tt_id                            is primary unique
          ttv_rec_item_lote_impl_tit_acr   ascending
          tta_cod_estab                    ascending
          tta_cod_estab_ext                ascending
          tta_cod_espec_docto              ascending
          tta_cod_ser_docto                ascending
          tta_cod_tit_acr                  ascending
          tta_cod_parcela                  ascending
    .
def new shared temp-table tt_integr_acr_cheq no-undo
    field tta_cod_banco                    as character format "x(8)"  label "Banco" column-label "Banco"
    field tta_cod_agenc_bcia               as character format "x(10)" label "Ag¼ncia Bancÿria" column-label "Ag¼ncia Bancÿria"
    field tta_cod_cta_corren               as character format "x(10)" label "Conta Corrente" column-label "Cta Corrente"
    field tta_num_cheque                   as integer   format ">>>>,>>>,>>9" initial ? label "Num Cheque" column-label "Num Cheque"
    field tta_dat_emis_cheq                as date      format "99/99/9999" initial ? label "Data Emiss’o" column-label "Dt Emiss"
    field tta_dat_depos_cheq_acr           as date      format "99/99/9999" initial ? label "Dep½sito" column-label "Dep½sito"
    field tta_dat_prev_depos_cheq_acr      as date      format "99/99/9999" initial ? label "Previs’o Dep½sito" column-label "Previs’o Dep½sito"
    field tta_dat_desc_cheq_acr            as date      format "99/99/9999" initial ? label "Data Desconto" column-label "Data Desconto"
    field tta_dat_prev_desc_cheq_acr       as date      format "99/99/9999" initial ? label "Data Prev Desc" column-label "Data Prev Desc"
    field tta_val_cheque                   as decimal   format ">>>,>>>,>>9.99" decimals 2 initial 0 label "Valor Cheque" column-label "Valor Cheque"
    field tta_nom_emit                     as character format "x(40)" label "Nome Emitente" column-label "Nome Emitente"
    field tta_nom_cidad_emit               as character format "x(30)" label "Cidade Emitente" column-label "Cidade Emitente"
    field tta_cod_estab                    as character format "x(3)"  label "Estabelecimento" column-label "Estab"
    field tta_cod_estab_ext                as character format "x(8)"  label "Estabelecimento Exte" column-label "Estabelecimento Ext"
    field tta_cod_id_feder                 as character format "x(20)" initial ? label "ID Federal" column-label "ID Federal"
    field tta_cod_motiv_devol_cheq         as character format "x(5)"  label "Motivo Devolu»’o" column-label "Motivo Devolu»’o"
    field tta_cod_indic_econ               as character format "x(8)"  label "Moeda" column-label "Moeda"
    field tta_cod_finalid_econ_ext         as character format "x(8)"  label "Finalid Econ Externa" column-label "Finalidade Externa"
    field tta_cod_usuar_cheq_acr_terc      as character format "x(12)" label "Usuÿrio" column-label "Usuÿrio"
    field tta_log_pend_cheq_acr            as logical   format "Sim/N’o" initial no label "Cheque Pendente" column-label "Cheque Pendente"
    field tta_log_cheq_terc                as logical   format "Sim/N’o" initial no label "Cheque Terceiro" column-label "Cheque Terceiro"
    field tta_log_cheq_acr_renegoc         as logical   format "Sim/N’o" initial no label "Cheque Reneg" column-label "Cheque Reneg"
    field tta_log_cheq_acr_devolv          as logical   format "Sim/N’o" initial no label "Cheque Devolvido" column-label "Cheque Devolvido"
    field tta_num_pessoa                   as integer   format ">>>,>>>,>>9" initial ? label "Pessoa" column-label "Pessoa"
    field tta_cod_pais                     as character format "x(3)" label "Pa­s" column-label "Pa­s"
    index tt_id                            is primary unique
          tta_cod_banco                    ascending
          tta_cod_agenc_bcia               ascending
          tta_cod_cta_corren               ascending
          tta_num_cheque                   ascending
    .
def temp-table tt_integr_acr_liquidac_impto_2 no-undo
    field tta_cod_estab_refer              as character format "x(3)" initial ? label "Estabelecimento" column-label "Estab"
    field tta_cod_refer                    as character format "x(10)" label "Refer¼ncia" column-label "Refer¼ncia"
    field tta_num_seq_refer                as integer   format ">>>9" initial 0 label "Sequ¼ncia" column-label "Seq"
    field tta_cod_pais                     as character format "x(3)" label "Pa­s" column-label "Pa­s"
    field tta_cod_unid_federac             as character format "x(3)" label "Unidade Federa»’o" column-label "UF"
    field tta_cod_imposto                  as character format "x(5)" label "Imposto" column-label "Imposto"
    field tta_cod_classif_impto            as character format "x(05)" initial "00000" label "Class Imposto" column-label "Class Imposto"
    field tta_val_retid_indic_impto        as decimal   format ">>>,>>>,>>9.99" decimals 2 initial 0 label "Vl Retido IE Imposto" column-label "Vl Retido IE Imposto"
    field tta_val_retid_indic_tit_acr      as decimal   format ">>>,>>>,>>9.99" decimals 2 initial 0 label "Vl Retido IE T­tulo" column-label "Vl Retido IE T­tulo"
    field tta_val_retid_indic_pagto        as decimal   format ">>>,>>>,>>9.99" decimals 2 initial 0 label "Retido Indicador Pag" column-label "Retido Indicador Pag"
    field tta_dat_cotac_indic_econ         as date      format "99/99/9999" initial ? label "Data Cota»’o" column-label "Data Cota»’o"
    field tta_val_cotac_indic_econ         as decimal   format ">>>>,>>9.9999999999" decimals 10 initial 0 label "Cota»’o" column-label "Cota»’o"
    field tta_dat_cotac_indic_econ_pagto   as date      format "99/99/9999" initial ? label "Dat Cotac IE Pagto" column-label "Dat Cotac IE Pagto"
    field tta_val_cotac_indic_econ_pagto   as decimal   format ">>>>,>>9.9999999999" decimals 10 initial 0 label "Val Cotac IE Pagto" column-label "Val Cotac IE Pagto"
    field tta_cod_livre_1                  as character format "x(100)" label "Livre 1" column-label "Livre 1"
    field tta_cod_livre_2                  as character format "x(100)" label "Livre 2" column-label "Livre 2"
    field tta_dat_livre_1                  as date      format "99/99/9999" initial ? label "Livre 1" column-label "Livre 1"
    field tta_dat_livre_2                  as date      format "99/99/9999" initial ? label "Livre 2" column-label "Livre 2"
    field tta_log_livre_1                  as logical   format "Sim/N’o" initial no label "Livre 1" column-label "Livre 1"
    field tta_log_livre_2                  as logical   format "Sim/N’o" initial no label "Livre 2" column-label "Livre 2"
    field tta_num_livre_1                  as integer   format ">>>>>9" initial 0 label "Livre 1" column-label "Livre 1"
    field tta_num_livre_2                  as integer   format ">>>>>9" initial 0 label "Livre 2" column-label "Livre 2"
    field tta_val_livre_1                  as decimal   format ">>>,>>>,>>9.9999" decimals 4 initial 0 label "Livre 1" column-label "Livre 1"
    field tta_val_livre_2                  as decimal   format ">>>,>>>,>>9.9999" decimals 4 initial 0 label "Livre 2" column-label "Livre 2"
    field ttv_rec_item_lote_liquidac_acr   as recid     format ">>>>>>9"
    field tta_val_rendto_tribut            as decimal   format ">,>>>,>>>,>>9.99" decimals 2 initial 0 label "Rendto Tributÿvel" column-label "Vl Rendto Tribut"
    .
def temp-table tt_integr_acr_rel_pend_cheq no-undo
    field ttv_rec_item_lote_liquidac_acr   as recid     format ">>>>>>9"
    field tta_cod_banco                    as character format "x(8)" label "Banco" column-label "Banco"
    field tta_cod_agenc_bcia               as character format "x(10)" label "Ag¼ncia Bancÿria" column-label "Ag¼ncia Bancÿria"
    field tta_cod_cta_corren               as character format "x(10)" label "Conta Corrente" column-label "Cta Corrente"
    field tta_num_cheque                   as integer   format ">>>>,>>>,>>9" initial ? label "Num Cheque" column-label "Num Cheque"
    field tta_val_vincul_cheq_acr          as decimal   format ">>>,>>>,>>9.99" decimals 2 initial 0 label "Valor Vinculado" column-label "Valor Vinculado"
    field tta_cdn_bco_cheq_salario         as Integer   format ">>9" initial 0 label "Banco Cheque Salÿrio" column-label "Banco Cheque Salÿrio"
    .
def temp-table tt_integr_acr_liq_aprop_ctbl no-undo
    field ttv_rec_item_lote_liquidac_acr   as recid     format ">>>>>>9"
    field tta_cod_fluxo_financ_ext         as character format "x(20)" label "Tipo Fluxo Externo" column-label "Tipo Fluxo Externo"
    field tta_cod_unid_negoc               as character format "x(3)" label "Unid Neg½cio" column-label "Un Neg"
    field tta_cod_tip_fluxo_financ         as character format "x(12)" label "Tipo Fluxo Financ" column-label "Tipo Fluxo Financ"
    field tta_val_aprop_ctbl               as decimal   format "->>>,>>>,>>9.99" decimals 2 initial 0 label "Valor Aprop Ctbl" column-label "Vl Aprop Ctbl"
    index tt_integr_acr_liq_aprop_ctbl_id  is primary unique
          ttv_rec_item_lote_liquidac_acr   ascending
          tta_cod_fluxo_financ_ext         ascending
          tta_cod_tip_fluxo_financ         ascending
          tta_cod_unid_negoc               ascending
    .

def temp-table tt_integr_acr_liq_desp_rec no-undo
    field ttv_rec_item_lote_liquidac_acr   as recid     format ">>>>>>9"
    field tta_cod_cta_ctbl_ext             as character format "x(20)" label "Conta Contab Extern" column-label "Conta Contab Extern"
    field tta_cod_sub_cta_ctbl_ext         as character format "x(15)" label "Sub Conta Externa" column-label "Sub Conta Externa"
    field tta_cod_fluxo_financ_ext         as character format "x(20)" label "Tipo Fluxo Externo" column-label "Tipo Fluxo Externo"
    field tta_cod_unid_negoc_ext           as character format "x(8)" label "Unid Neg½cio Externa" column-label "Unid Neg½cio Externa"
    field tta_cod_plano_cta_ctbl           as character format "x(8)" label "Plano Contas" column-label "Plano Contas"
    field tta_cod_cta_ctbl                 as character format "x(20)" label "Conta Contÿbil" column-label "Conta Contÿbil"
    field tta_cod_unid_negoc               as character format "x(3)" label "Unid Neg½cio" column-label "Un Neg"
    field tta_cod_tip_fluxo_financ         as character format "x(12)" label "Tipo Fluxo Financ" column-label "Tipo Fluxo Financ"
    field tta_cod_tip_abat                 as character format "x(8)" label "Tipo de Abatimento" column-label "Tipo de Abatimento"
    field tta_ind_tip_aprop_recta_despes   as character format "x(20)" label "Tipo Apropria»’o" column-label "Tipo Apropria»’o"
    field tta_val_perc_rat_ctbz            as decimal   format ">>9.99" decimals 2 initial 0 label "Perc Rateio" column-label "% Rat"
    index tt_integr_acr_liq_des_rec_id     is primary unique
          ttv_rec_item_lote_liquidac_acr   ascending
          tta_cod_cta_ctbl_ext             ascending
          tta_cod_sub_cta_ctbl_ext         ascending
          tta_cod_fluxo_financ_ext         ascending
          tta_cod_unid_negoc_ext           ascending
          tta_cod_plano_cta_ctbl           ascending
          tta_cod_cta_ctbl                 ascending
          tta_cod_unid_negoc               ascending
          tta_cod_tip_fluxo_financ         ascending
          tta_ind_tip_aprop_recta_despes   ascending
    .
def new shared temp-table tt_integr_acr_aprop_liq_antec no-undo
    field ttv_rec_item_lote_impl_tit_acr   as recid     format ">>>>>>9"
    field ttv_rec_abat_antecip_acr         as recid     format ">>>>>>9"
    field tta_cod_fluxo_financ_ext         as character format "x(20)" label "Tipo Fluxo Externo" column-label "Tipo Fluxo Externo"
    field ttv_cod_fluxo_financ_tit_ext     as character format "x(20)"
    field tta_cod_unid_negoc               as character format "x(3)" label "Unid Neg½cio" column-label "Un Neg"
    field tta_cod_tip_fluxo_financ         as character format "x(12)" label "Tipo Fluxo Financ" column-label "Tipo Fluxo Financ"
    field tta_cod_unid_negoc_tit           as character format "x(3)" label "Unid Negoc T­tulo" column-label "Unid Negoc T­tulo"
    field tta_cod_tip_fluxo_financ_tit     as character format "x(12)" label "Tp Fluxo Financ Tit" column-label "Tp Fluxo Financ Tit"
    field tta_val_abtdo_antecip            as decimal   format "->>>,>>>,>>9.99" decimals 2 initial 0 label "Valor Abatido" column-label "Vl Abatido"
    .
def new shared temp-table tt_integr_acr_aprop_relacto no-undo
    field ttv_rec_relacto_pend_tit_acr     as recid format ">>>>>>9" initial ?
    field tta_cod_cta_ctbl_ext             as character format "x(20)" label "Conta Contab Extern" column-label "Conta Contab Extern"
    field tta_cod_sub_cta_ctbl_ext         as character format "x(15)" label "Sub Conta Externa" column-label "Sub Conta Externa"
    field tta_cod_unid_negoc_ext           as character format "x(8)" label "Unid Neg½cio Externa" column-label "Unid Neg½cio Externa"
    field tta_cod_fluxo_financ_ext         as character format "x(20)" label "Tipo Fluxo Externo" column-label "Tipo Fluxo Externo"
    field tta_cod_plano_cta_ctbl           as character format "x(8)" label "Plano Contas" column-label "Plano Contas"
    field tta_cod_cta_ctbl                 as character format "x(20)" label "Conta Contÿbil" column-label "Conta Contÿbil"
    field tta_cod_unid_negoc               as character format "x(3)" label "Unid Neg½cio" column-label "Un Neg"
    field tta_cod_tip_fluxo_financ         as character format "x(12)" label "Tipo Fluxo Financ" column-label "Tipo Fluxo Financ"
    field tta_val_aprop_ctbl               as decimal format "->>>,>>>,>>9.99" decimals 2 initial 0 label "Valor Aprop Ctbl" column-label "Vl Aprop Ctbl"
    field tta_ind_tip_aprop_ctbl           as character format "x(30)" initial "Saldo" label "Tipo Aprop Ctbl" column-label "Tipo Aprop Ctbl"
    .
def new shared temp-table tt_integr_acr_impto_impl_pend no-undo
    field ttv_rec_item_lote_impl_tit_acr   as recid format ">>>>>>9"
    field tta_cod_pais                     as character format "x(3)" label "Pa­s" column-label "Pa­s"
    field tta_cod_pais_ext                 as character format "x(20)" label "Pa­s Externo" column-label "Pa­s Externo"
    field tta_cod_unid_federac             as character format "x(3)" label "Unidade Federa»’o" column-label "UF"
    field tta_cod_imposto                  as character format "x(5)" label "Imposto" column-label "Imposto"
    field tta_cod_classif_impto            as character format "x(05)" initial "00000" label "Class Imposto" column-label "Class Imposto"
    field tta_num_seq                      as integer format ">>>,>>9" initial 0 label "Sequ¼ncia" column-label "NumSeq"
    field tta_val_rendto_tribut            as decimal format ">,>>>,>>>,>>9.99" decimals 2 initial 0 label "Rendto Tributÿvel" column-label "Vl Rendto Tribut"
    field tta_val_aliq_impto               as decimal format ">9.99" decimals 2 initial 0.00 label "Al­quota" column-label "Aliq"
    field tta_val_imposto                  as decimal format ">,>>>,>>>,>>9.99" decimals 2 initial 0 label "Valor Imposto" column-label "Vl Imposto"
    field tta_cod_plano_cta_ctbl           as character format "x(8)" label "Plano Contas" column-label "Plano Contas"
    field tta_cod_cta_ctbl                 as character format "x(20)" label "Conta Contÿbil" column-label "Conta Contÿbil"
    field tta_cod_cta_ctbl_ext             as character format "x(20)" label "Conta Contab Extern" column-label "Conta Contab Extern"
    field tta_cod_sub_cta_ctbl_ext         as character format "x(15)" label "Sub Conta Externa" column-label "Sub Conta Externa"
    field tta_ind_clas_impto               as character format "X(14)" initial "Retido" label "Classe Imposto" column-label "Classe Imposto"
    field tta_cod_indic_econ               as character format "x(8)" label "Moeda" column-label "Moeda"
    field tta_cod_finalid_econ_ext         as character format "x(8)" label "Finalid Econ Externa" column-label "Finalidade Externa"
    field tta_val_cotac_indic_econ         as decimal format ">>>>,>>9.9999999999" decimals 10 initial 0 label "Cota»’o" column-label "Cota»’o"
    field tta_dat_cotac_indic_econ         as date format "99/99/9999" initial ? label "Data Cota»’o" column-label "Data Cota»’o"
    field tta_val_impto_indic_econ_impto   as decimal format "->>>,>>>,>>9.99" decimals 2 initial 0 label "Val Finalid Impto" column-label "Val Finalid Impto"
    index tt_id                            is primary unique
          ttv_rec_item_lote_impl_tit_acr   ascending
          tta_cod_pais                     ascending
          tta_cod_pais_ext                 ascending
          tta_cod_unid_federac             ascending
          tta_cod_imposto                  ascending
          tta_cod_classif_impto            ascending
          tta_num_seq                      ascending
    .
def new shared temp-table tt_integr_acr_ped_vda_pend no-undo
    field ttv_rec_item_lote_impl_tit_acr   as recid format ">>>>>>9"
    field tta_cod_ped_vda                  as character format "x(12)" label "Pedido Venda" column-label "Pedido Venda"
    field tta_cod_ped_vda_repres           as character format "x(12)" label "Pedido Repres" column-label "Pedido Repres"
    field tta_val_perc_particip_ped_vda    as decimal format ">>9.99" decimals 2 initial 0 label "Particip Ped Vda" column-label "Particip"
    field tta_val_origin_ped_vda           as decimal format "->>,>>>,>>>,>>9.99" decimals 2 initial 0 label "Original Ped Venda" column-label "Original Ped Venda"
    field tta_val_sdo_ped_vda              as decimal format "->>,>>>,>>>,>>9.99" decimals 2 initial 0 label "Saldo Pedido Venda" column-label "Saldo Pedido Venda"
    field tta_des_ped_vda                  as character format "x(40)" label "Pedido Venda" column-label "Pedido Venda"
    index tt_id                            is primary unique
          ttv_rec_item_lote_impl_tit_acr   ascending
          tta_cod_ped_vda                  ascending
    .
def new shared temp-table tt_integr_acr_relacto_pend no-undo
    field ttv_rec_item_lote_impl_tit_acr   as recid format ">>>>>>9"
    field tta_cod_estab_tit_acr_pai        as character format "x(3)" label "Estab Tit Pai" column-label "Estab Tit Pai"
    field ttv_cod_estab_tit_acr_pai_ext    as character format "x(3)" label "Estab Tit Pai" column-label "Estab Tit Pai"
    field tta_num_id_tit_acr_pai           as integer format "9999999999" initial 0 label "Token" column-label "Token"
    field tta_cod_espec_docto              as character format "x(3)" label "Espýcie Documento" column-label "Espýcie"
    field tta_cod_ser_docto                as character format "x(3)" label "Sýrie Documento" column-label "Sýrie"
    field tta_cod_tit_acr                  as character format "x(10)" label "T­tulo" column-label "T­tulo"
    field tta_cod_parcela                  as character format "x(02)" label "Parcela" column-label "Parc"
    field tta_val_relacto_tit_acr          as decimal format "->>>,>>>,>>9.99" decimals 2 initial 0 label "Vl Relacto" column-label "Vl Relacto"
    field tta_log_gera_alter_val           as logical format "Sim/N’o" initial no label "Gera Alter Valor" column-label "Gera Alter Valor"
    field tta_ind_motiv_acerto_val         as character format "X(12)" initial "Altera»’o" label "Motivo Acerto Valor" column-label "Motivo Acerto Valor"
    .
def new shared temp-table tt_integr_acr_relacto_pend_cheq no-undo
    field ttv_rec_item_lote_impl_tit_acr   as recid format ">>>>>>9"
    field tta_cod_banco                    as character format "x(8)" label "Banco" column-label "Banco"
    field tta_cod_agenc_bcia               as character format "x(10)" label "Ag¼ncia Bancÿria" column-label "Ag¼ncia Bancÿria"
    field tta_cod_cta_corren               as character format "x(10)" label "Conta Corrente" column-label "Cta Corrente"
    field tta_num_cheque                   as integer format ">>>>,>>>,>>9" initial ? label "Num Cheque" column-label "Num Cheque"
    field tta_val_vincul_cheq_acr          as decimal format ">>>,>>>,>>9.99" decimals 2 initial 0 label "Valor Vinculado" column-label "Valor Vinculado"
    field tta_cdn_bco_cheq_salario         as Integer format ">>9" initial 0 label "Banco Cheque Salÿrio" column-label "Banco Cheque Salÿrio"
    index tt_id                            is primary unique
          ttv_rec_item_lote_impl_tit_acr   ascending
          tta_cod_banco                    ascending
          tta_cod_agenc_bcia               ascending
          tta_cod_cta_corren               ascending
          tta_num_cheque                   ascending
    .
def temp-table tt_log_erros_import_liquidac no-undo
    field tta_num_seq                      as integer   format ">>>,>>9" initial 0 label "Sequ¼ncia" column-label "NumSeq"
    field tta_cod_estab                    as character format "x(3)" label "Estabelecimento" column-label "Estab"
    field tta_cod_refer                    as character format "x(10)" label "Refer¼ncia" column-label "Refer¼ncia"
    field tta_cod_espec_docto              as character format "x(3)" label "Esp²cie Documento" column-label "Esp²cie"
    field tta_cod_ser_docto                as character format "x(3)" label "S²rie Documento" column-label "S²rie"
    field tta_cod_tit_acr                  as character format "x(10)" label "T­tulo" column-label "T­tulo"
    field tta_cod_parcela                  as character format "x(02)" label "Parcela" column-label "Parc"
    field ttv_nom_abrev_clien              as character format "x(12)" label "Cliente" column-label "Cliente"
    field ttv_num_erro_log                 as integer   format ">>>>,>>9" label "Nœmero Erro" column-label "Nœmero Erro"
    field ttv_des_msg_erro                 as character format "x(60)" label "Mensagem Erro" column-label "Inconsist¼ncia"
    index tt_sequencia                    
          tta_num_seq                      ascending
    .

def temp-table tt_integr_cambio_ems5 no-undo
    field ttv_rec_table_child              as recid     format ">>>>>>9"
    field ttv_rec_table_parent             as recid     format ">>>>>>9"
    field ttv_cod_contrat_cambio           as character format "x(15)"
    field ttv_dat_contrat_cambio_import    as date      format "99/99/9999"
    field ttv_num_contrat_id_cambio        as integer   format "999999999"
    field ttv_cod_estab_contrat_cambio     as character format "x(3)"
    field ttv_cod_refer_contrat_cambio     as character format "x(10)"
    field ttv_dat_refer_contrat_cambio     as date      format "99/99/9999"
    index tt_rec_index                     is primary unique
          ttv_rec_table_parent             ascending
          ttv_rec_table_child              ascending
    .

/* Defini»’o das temp-tables utilizdas pela API de altera»’o de t­tulos - acr711zo */
def temp-table tt_alter_tit_acr_base_3 no-undo
    field tta_cod_estab                    as character format "x(3)" label "Estabelecimento" column-label "Estab"
    field tta_num_id_tit_acr               as integer format "9999999999" initial 0 label "Token Cta Receber" column-label "Token Cta Receber"
    field tta_dat_transacao                as date format "99/99/9999" initial today label "Data Transa»’o" column-label "Dat Transac"
    field tta_cod_refer                    as character format "x(10)" label "Refer¼ncia" column-label "Refer¼ncia"
    field ttv_cod_motiv_movto_tit_acr_imp  as character format "x(8)" label "Motivo Impl" column-label "Motivo Movimento"
    field tta_val_sdo_tit_acr              as decimal format ">>>,>>>,>>9.99" decimals 2 initial 0 label "Saldo T­tulo" column-label "Saldo T­tulo"
    field ttv_cod_motiv_movto_tit_acr_alt  as character format "x(8)" label "Motivo Alter" column-label "Motivo Movimento"
    field ttv_ind_motiv_acerto_val         as character format "X(12)" label "Motivo Acerto Valor" column-label "Motivo Acerto Valor"
    field tta_cod_portador                 as character format "x(5)" label "Portador" column-label "Portador"
    field tta_cod_cart_bcia                as character format "x(3)" label "Carteira" column-label "Carteira"
    field tta_val_despes_bcia              as decimal format "->>>,>>>,>>9.99" decimals 2 initial 0 label "Vl Desp Banc" column-label "Vl Desp Banc"
    field tta_cod_agenc_cobr_bcia          as character format "x(10)" label "Ag¼ncia Cobran»a" column-label "Ag¼ncia Cobr"
    field tta_cod_tit_acr_bco              as character format "x(20)" label "Num T­tulo Banco" column-label "Num T­tulo Banco"
    field tta_dat_emis_docto               as date format "99/99/9999" initial today label "Data  Emiss’o" column-label "Dt Emiss’o"
    field tta_dat_vencto_tit_acr           as date format "99/99/9999" initial ? label "Vencimento" column-label "Vencimento"
    field tta_dat_prev_liquidac            as date format "99/99/9999" initial ? label "Prev Liquida»’o" column-label "Prev Liquida»’o"
    field tta_dat_fluxo_tit_acr            as date format "99/99/9999" initial ? label "Fluxo" column-label "Fluxo"
    field tta_ind_sit_tit_acr              as character format "X(13)" initial "Normal" label "Situa»’o T­tulo" column-label "Situa»’o T­tulo"
    field tta_cod_cond_cobr                as character format "x(8)" label "Condi»’o Cobran»a" column-label "Cond Cobran»a"
    field tta_log_tip_cr_perda_dedut_tit   as logical format "Sim/N’o" initial no label "Credito com Garantia" column-label "Cred Garant"
    field tta_dat_abat_tit_acr             as date format "99/99/9999" initial ? label "Abat" column-label "Abat"
    field tta_val_perc_abat_acr            as decimal format ">>9.9999" decimals 4 initial 0 label "Perc Abatimento" column-label "Abatimento"
    field tta_val_abat_tit_acr             as decimal format ">>>>,>>>,>>9.99" decimals 2 initial 0 label "Vl Abatimento" column-label "Vl Abatimento"
    field tta_dat_desconto                 as date format "99/99/9999" initial ? label "Data Desconto" column-label "Dt Descto"
    field tta_val_perc_desc                as decimal format ">9.9999" decimals 4 initial 0 label "Percentual Desconto" column-label "Perc Descto"
    field tta_val_desc_tit_acr             as decimal format ">>>>,>>>,>>9.99" decimals 2 initial 0 label "Vl Desc" column-label "Vl Desc"
    field tta_qtd_dias_carenc_juros_acr    as decimal format ">>9" initial 0 label "Dias Carenc Juros" column-label "Dias Juros"
    field tta_val_perc_juros_dia_atraso    as decimal format ">9.999999" decimals 6 initial 00.00 label "Perc Jur Dia Atraso" column-label "Perc Dia"
    field tta_qtd_dias_carenc_multa_acr    as decimal format ">>9" initial 0 label "Dias Carenc Multa" column-label "Dias Carenc Multa"
    field tta_val_perc_multa_atraso        as decimal format ">9.99" decimals 2 initial 00.00 label "Perc Multa Atraso" column-label "Multa Atr"
    field ttv_cod_portador_mov             as character format "x(5)" label "Portador Movto" column-label "Portador Movto"
    field tta_ind_tip_cobr_acr             as character format "X(10)" initial "Normal" label "Tipo Cobran»a" column-label "Tipo Cobran»a"
    field tta_ind_ender_cobr               as character format "X(15)" initial "Cliente" label "Endere»o Cobran»a" column-label "Endere»o Cobran»a"
    field tta_nom_abrev_contat             as character format "x(15)" label "Abreviado Contato" column-label "Abreviado Contato"
    field tta_val_liq_tit_acr              as decimal format ">>>,>>>,>>9.99" decimals 2 initial 0 label "Vl L­quido" column-label "Vl L­quido"
    field tta_cod_instruc_bcia_1_movto     as character format "x(4)" label "Instr Bancÿria 1" column-label "Instr Banc 1"
    field tta_cod_instruc_bcia_2_movto     as character format "x(4)" label "Instr Bancÿria 2" column-label "Instr Banc 2"
    field tta_log_tit_acr_destndo          as logical format "Sim/N’o" initial no label "Destinado" column-label "Destinado"
    field tta_cod_histor_padr              as character format "x(8)" label "Hist½rico Padr’o" column-label "Hist½rico Padr’o"
    field ttv_des_text_histor              as character format "x(2000)" label "Hist½rico" column-label "Hist½rico"
    field tta_des_obs_cobr                 as character format "x(40)" label "Obs Cobran»a" column-label "Obs Cobran»a"
    field ttv_wgh_lista                    as widget-handle extent 26 format ">>>>>>9"
    field tta_num_seq_tit_acr              as integer format ">>>9" initial 0 label "Sequ¼ncia" column-label "Sequ¼ncia"
    field ttv_cod_estab_planilha           as character format "x(3)"
    field ttv_num_planilha_vendor          as integer format ">>>,>>>,>>9" label "Planilha Vendor" column-label "Planilha Vendor"
    field ttv_cod_cond_pagto_vendor        as character format "x(3)" initial "0" label "Condi»’o Pagto" column-label "Condi»’o Pagto"
    field ttv_val_cotac_tax_vendor_clien   as decimal format ">>9.9999999999" decimals 10 label "Taxa Vendor Cliente" column-label "Taxa Vendor Cliente"
    field ttv_dat_base_fechto_vendor       as date format "99/99/9999" label "Data Base" column-label "Data Base"
    field ttv_qti_dias_carenc_fechto       as Integer format "->>9" label "Dias Car¼ncia" column-label "Dias Car¼ncia"
    field ttv_log_assume_tax_bco           as logical format "Sim/N’o" initial no label "Assume Taxa Banco" column-label "Assume Taxa Banco"
    field ttv_log_vendor                   as logical format "Sim/N’o" initial no
    field tta_val_cr_pis                   as decimal format ">>>,>>>,>>9.99" decimals 2 initial 0 label "Valor Cred PIS/PASEP" column-label "Vl Cred PIS/PASEP"
    field tta_val_cr_cofins                as decimal format ">>>,>>>,>>9.99" decimals 2 initial 0 label "Valor Cr²dito COFINS" column-label "Credito COFINS"
    field tta_val_cr_csll                  as decimal format ">>>,>>>,>>9.99" decimals 2 initial 0 label "Valor Cr²dito CSLL" column-label "Credito CSLL"
    index tt_id                            is primary unique
          tta_cod_estab                    ascending
          tta_num_id_tit_acr               ascending
          tta_dat_transacao                ascending
          tta_num_seq_tit_acr              ascending
    .
def temp-table tt_alter_tit_acr_rateio no-undo
    field tta_cod_estab                    as character format "x(3)" label "Estabelecimento" column-label "Estab"
    field tta_num_id_tit_acr               as integer format "9999999999" initial 0 label "Token Cta Receber" column-label "Token Cta Receber"
    field ttv_ind_tip_rat_tit_acr          as character format "X(12)" label "Tipo Rateio" column-label "Tipo Rateio"
    field tta_cod_refer                    as character format "x(10)" label "Refer¼ncia" column-label "Refer¼ncia"
    field tta_num_seq_refer                as integer format ">>>9" initial 0 label "Sequ¼ncia" column-label "Seq"
    field tta_cod_plano_cta_ctbl           as character format "x(8)" label "Plano Contas" column-label "Plano Contas"
    field tta_cod_cta_ctbl                 as character format "x(20)" label "Conta Contÿbil" column-label "Conta Contÿbil"
    field tta_cod_unid_negoc               as character format "x(3)" label "Unid Neg½cio" column-label "Un Neg"
    field tta_cod_plano_ccusto             as character format "x(8)" label "Plano Centros Custo" column-label "Plano Centros Custo"
    field tta_cod_ccusto                   as Character format "x(11)" label "Centro Custo" column-label "Centro Custo"
    field tta_cod_tip_fluxo_financ         as character format "x(12)" label "Tipo Fluxo Financ" column-label "Tipo Fluxo Financ"
    field tta_num_seq_aprop_ctbl_pend_acr  as integer format ">>>9" initial 0 label "Seq Aprop Pend" column-label "Seq Apro"
    field tta_val_aprop_ctbl               as decimal format "->>>,>>>,>>9.99" decimals 2 initial 0 label "Valor Aprop Ctbl" column-label "Vl Aprop Ctbl"
    field tta_log_impto_val_agreg          as logical format "Sim/N’o" initial no label "Impto Val Agreg" column-label "Imp Vl Agr"
    field tta_cod_pais                     as character format "x(3)" label "Pa­s" column-label "Pa­s"
    field tta_cod_unid_federac             as character format "x(3)" label "Unidade Federa»’o" column-label "UF"
    field tta_cod_imposto                  as character format "x(5)" label "Imposto" column-label "Imposto"
    field tta_cod_classif_impto            as character format "x(05)" initial "00000" label "Class Imposto" column-label "Class Imposto"
    field tta_dat_transacao                as date format "99/99/9999" initial today label "Data Transa»’o" column-label "Dat Transac"
    index tt_relac_tit_acr                
          tta_cod_estab                    ascending
          tta_num_id_tit_acr               ascending
    .
def temp-table tt_alter_tit_acr_ped_vda no-undo
    field tta_cod_estab                    as character format "x(3)" label "Estabelecimento" column-label "Estab"
    field tta_num_id_tit_acr               as integer format "9999999999" initial 0 label "Token Cta Receber" column-label "Token Cta Receber"
    field ttv_num_tip_operac               as integer format ">9"
    field tta_cod_ped_vda                  as character format "x(12)" label "Pedido Venda" column-label "Pedido Venda"
    field tta_cod_ped_vda_repres           as character format "x(12)" label "Pedido Repres" column-label "Pedido Repres"
    field tta_val_perc_particip_ped_vda    as decimal format ">>9.99" decimals 2 initial 0 label "Particip Ped Vda" column-label "Particip"
    field tta_des_ped_vda                  as character format "x(40)" label "Pedido Venda" column-label "Pedido Venda"
    index tt_id                            is primary unique
          tta_cod_estab                    ascending
          tta_num_id_tit_acr               ascending
          tta_cod_ped_vda                  ascending
    .
def temp-table tt_alter_tit_acr_comis no-undo
    field tta_cod_empresa                  as character format "x(3)" label "Empresa" column-label "Empresa"
    field tta_cod_estab                    as character format "x(3)" label "Estabelecimento" column-label "Estab"
    field tta_num_id_tit_acr               as integer format "9999999999" initial 0 label "Token Cta Receber" column-label "Token Cta Receber"
    field ttv_num_tip_operac               as integer format ">9"
    field tta_cdn_repres                   as Integer format ">>>,>>9" initial 0 label "Representante" column-label "Representante"
    field tta_val_perc_comis_repres        as decimal format ">>9.99" decimals 2 initial 0 label "% Comiss’o" column-label "% Comiss’o"
    field tta_val_perc_comis_repres_emis   as decimal format ">>9.99" decimals 2 initial 0 label "% Comis Emiss’o" column-label "% Comis Emiss’o"
    field tta_val_perc_comis_abat          as decimal format ">>9.99" decimals 2 initial 0 label "% Comis Abatimento" column-label "% Comis Abatimento"
    field tta_val_perc_comis_desc          as decimal format ">>9.99" decimals 2 initial 0 label "% Comis Desconto" column-label "% Comis Desconto"
    field tta_val_perc_comis_juros         as decimal format ">>9.99" decimals 2 initial 0 label "% Comis Juros" column-label "% Comis Juros"
    field tta_val_perc_comis_multa         as decimal format ">>9.99" decimals 2 initial 0 label "% Comis Multa" column-label "% Comis Multa"
    field tta_val_perc_comis_acerto_val    as decimal format ">>9.99" decimals 2 initial 0 label "% Comis AVA" column-label "% Comis AVA"
    field tta_log_comis_repres_proporc     as logical format "Sim/N’o" initial no label "Comis Proporcional" column-label "Comis Propor"
    field tta_ind_tip_comis                as character format "X(15)" initial "Valor Bruto" label "Tipo Comiss’o" column-label "Tipo Comiss’o"
    index tt_id                            is primary unique
          tta_cod_empresa                  ascending
          tta_cod_estab                    ascending
          tta_num_id_tit_acr               ascending
          tta_cdn_repres                   ascending
    index tt_relac_tit_acr                
          tta_cod_estab                    ascending
          tta_num_id_tit_acr               ascending
    .
def temp-table tt_alter_tit_acr_cheq no-undo
    field tta_cod_estab                    as character format "x(3)" label "Estabelecimento" column-label "Estab"
    field tta_num_id_tit_acr               as integer format "9999999999" initial 0 label "Token Cta Receber" column-label "Token Cta Receber"
    field tta_cod_banco                    as character format "x(8)" label "Banco" column-label "Banco"
    field tta_cod_agenc_bcia               as character format "x(10)" label "Ag¼ncia Bancÿria" column-label "Ag¼ncia Bancÿria"
    field tta_cod_cta_corren_bco           as character format "x(20)" label "Conta Corrente Banco" column-label "Conta Corrente Banco"
    field tta_num_cheque                   as integer format ">>>>,>>>,>>9" initial ? label "Num Cheque" column-label "Num Cheque"
    field tta_dat_emis_cheq                as date format "99/99/9999" initial ? label "Data Emiss’o" column-label "Dt Emiss"
    field tta_dat_prev_apres_cheq_acr      as date format "99/99/9999" initial ? label "Previs’o Apresent" column-label "Previs’o Apresent"
    field tta_dat_prev_cr_cheq_acr         as date format "99/99/9999" initial ? label "Previs’o Cr²dito" column-label "Previs’o Cr²dito"
    field tta_cod_id_feder                 as character format "x(20)" initial ? label "ID Federal" column-label "ID Federal"
    field tta_nom_emit                     as character format "x(40)" label "Nome Emitente" column-label "Nome Emitente"
    field tta_nom_cidad_emit               as character format "x(30)" label "Cidade Emitente" column-label "Cidade Emitente"
    field tta_log_cheq_terc                as logical format "Sim/N’o" initial no label "Cheque Terceiro" column-label "Cheque Terceiro"
    field tta_cod_usuar_cheq_acr_terc      as character format "x(12)" label "Usuÿrio" column-label "Usuÿrio"
    field tta_ind_dest_cheq_acr            as character format "X(15)" initial "Dep½sito" label "Destino Cheque" column-label "Destino Cheque"
    index tt_id                            is primary unique
          tta_cod_estab                    ascending
          tta_num_id_tit_acr               ascending
          tta_cod_banco                    ascending
          tta_cod_agenc_bcia               ascending
          tta_cod_cta_corren_bco           ascending
          tta_num_cheque                   ascending
    .
def temp-table tt_alter_tit_acr_iva no-undo
    field tta_cod_estab                    as character format "x(3)" label "Estabelecimento" column-label "Estab"
    field tta_num_id_tit_acr               as integer format "9999999999" initial 0 label "Token Cta Receber" column-label "Token Cta Receber"
    field tta_cod_refer                    as character format "x(10)" label "Refer¼ncia" column-label "Refer¼ncia"
    field tta_num_seq_refer                as integer format ">>>9" initial 0 label "Sequ¼ncia" column-label "Seq"
    field tta_cod_pais                     as character format "x(3)" label "Pa­s" column-label "Pa­s"
    field tta_cod_unid_federac             as character format "x(3)" label "Unidade Federa»’o" column-label "UF"
    field tta_cod_imposto                  as character format "x(5)" label "Imposto" column-label "Imposto"
    field tta_cod_classif_impto            as character format "x(05)" initial "00000" label "Class Imposto" column-label "Class Imposto"
    field tta_num_seq                      as integer format ">>>,>>9" initial 0 label "Sequ¼ncia" column-label "NumSeq"
    field ttv_num_tip_operac               as integer format ">9"
    field tta_val_rendto_tribut            as decimal format ">,>>>,>>>,>>9.99" decimals 2 initial 0 label "Rendto Tributÿvel" column-label "Vl Rendto Tribut"
    field tta_val_aliq_impto               as decimal format ">9.99" decimals 2 initial 0.00 label "Al­quota" column-label "Aliq"
    field tta_val_imposto                  as decimal format ">,>>>,>>>,>>9.99" decimals 2 initial 0 label "Valor Imposto" column-label "Vl Imposto"
    index tt_id                            is primary unique
          tta_cod_estab                    ascending
          tta_num_id_tit_acr               ascending
          tta_cod_pais                     ascending
          tta_cod_unid_federac             ascending
          tta_cod_imposto                  ascending
          tta_cod_classif_impto            ascending
          tta_num_seq                      ascending
    .
def temp-table tt_alter_tit_acr_impto_retid_2 no-undo
    field tta_cod_estab                    as character format "x(3)" label "Estabelecimento" column-label "Estab"
    field tta_num_id_tit_acr               as integer format "9999999999" initial 0 label "Token Cta Receber" column-label "Token Cta Receber"
    field tta_cod_pais                     as character format "x(3)" label "Pa­s" column-label "Pa­s"
    field tta_cod_unid_federac             as character format "x(3)" label "Unidade Federa»’o" column-label "UF"
    field tta_cod_imposto                  as character format "x(5)" label "Imposto" column-label "Imposto"
    field tta_cod_classif_impto            as character format "x(05)" initial "00000" label "Class Imposto" column-label "Class Imposto"
    field tta_num_impto_refer_tit_acr      as integer format ">>>>>9" initial 0 label "Impto Refer" column-label "Impto Refer"
    field ttv_num_tip_operac               as integer format ">9"
    field tta_val_aliq_impto               as decimal format ">9.99" decimals 2 initial 0.00 label "Al­quota" column-label "Aliq"
    field tta_val_rendto_tribut            as decimal format ">,>>>,>>>,>>9.99" decimals 2 initial 0 label "Rendto Tributÿvel" column-label "Vl Rendto Tribut"
    index tt_id                            is primary unique
          tta_cod_estab                    ascending
          tta_num_id_tit_acr               ascending
          tta_cod_pais                     ascending
          tta_cod_unid_federac             ascending
          tta_cod_imposto                  ascending
          tta_cod_classif_impto            ascending
          tta_num_impto_refer_tit_acr      ascending
    .

def temp-table tt_alter_tit_acr_cobr_espec_2 no-undo
    field tta_cod_estab                    as character format "x(3)" label "Estabelecimento" column-label "Estab"
    field tta_num_id_tit_acr               as integer format "9999999999" initial 0 label "Token Cta Receber" column-label "Token Cta Receber"
    field tta_num_seq_tit_acr              as integer format ">>>9" initial 0 label "Sequ¼ncia" column-label "Sequ¼ncia"
    field tta_num_id_cobr_especial_acr     as integer format "99999999" initial 0 label "Token Cobr Especial" column-label "Token Cobr Especial"
    field tta_val_tit_acr                  as decimal format ">>>,>>>,>>9.99" decimals 2 initial 0 label "Valor" column-label "Valor"
    field tta_cod_portador                 as character format "x(5)" label "Portador" column-label "Portador"
    field tta_cod_cart_bcia                as character format "x(3)" label "Carteira" column-label "Carteira"
    field tta_cod_cartcred                 as character format "x(20)" label "C½digo Cart’o" column-label "C½digo Cart’o"
    field tta_cod_autoriz_cartao_cr        as character format "x(6)" label "C½d Pr²-Autoriza»’o" column-label "C½d Pr²-Autoriza»’o"
    field tta_cod_mes_ano_valid_cartao     as character format "XX/XXXX" label "Validade Cart’o" column-label "Validade Cart’o"
    field tta_dat_compra_cartao_cr         as date format "99/99/9999" initial ? label "Data Efetiv Venda" column-label "Data Efetiv Venda"
    field tta_cod_banco                    as character format "x(8)" label "Banco" column-label "Banco"
    field tta_cod_agenc_bcia               as character format "x(10)" label "Ag¼ncia Bancÿria" column-label "Ag¼ncia Bancÿria"
    field tta_cod_cta_corren_bco           as character format "x(20)" label "Conta Corrente Banco" column-label "Conta Corrente Banco"
    field tta_cod_digito_cta_corren        as character format "x(2)" label "D­gito Cta Corrente" column-label "D­gito Cta Corrente"
    field tta_num_ddd_localid_conces       as integer format "999" initial 0 label "DDD" column-label "DDD"
    field tta_num_prefix_localid_conces    as integer format ">>>9" initial 0 label "Prefixo" column-label "Prefixo"
    field tta_num_milhar_localid_conces    as integer format "9999" initial 0 label "Milhar" column-label "Milhar"
    field tta_des_text_histor              as character format "x(2000)" label "Hist½rico" column-label "Hist½rico"
    field ttv_log_alter_tip_cobr_acr       as logical format "Sim/N’o" initial no label "Alter Tip Cobr" column-label "Alter Tip Cobr"
    field tta_ind_sit_tit_cobr_especial    as character format "X(15)" label "Situa»’o T­tulo" column-label "Situa»’o T­tulo"
    field ttv_cod_comprov_vda              as character format "x(12)" label "Comprovante Venda" column-label "Comprovante Venda"
    field ttv_num_parc_cartcred            as integer format ">9" label "Quantidade Parcelas" column-label "Quantidade Parcelas"
    field ttv_val_tot_sdo_tit_acr          as decimal format ">>>,>>>,>>9.99" decimals 2 initial 0 label "Val Total Parcelas" column-label "Val Total Parcelas"
    field tta_cod_autoriz_bco_emissor      as character format "x(6)" label "Autorizacao Venda" column-label "Autorizacao Venda"
    field tta_cod_lote_origin              as character format "x(7)" label "Lote Orig Venda" column-label "Lote Orig Venda"
    index tt_id                            is primary unique
          tta_cod_estab                    ascending
          tta_num_id_tit_acr               ascending
          tta_num_seq_tit_acr              ascending
    .
def temp-table tt_alter_tit_acr_rat_desp_rec no-undo
    field tta_cod_empresa                  as character format "x(3)" label "Empresa" column-label "Empresa"
    field tta_cod_estab                    as character format "x(3)" label "Estabelecimento" column-label "Estab"
    field tta_cod_plano_cta_ctbl           as character format "x(8)" label "Plano Contas" column-label "Plano Contas"
    field tta_cod_cta_ctbl                 as character format "x(20)" label "Conta Contÿbil" column-label "Conta Contÿbil"
    field tta_cod_unid_negoc               as character format "x(3)" label "Unid Neg½cio" column-label "Un Neg"
    field tta_cod_tip_abat                 as character format "x(8)" label "Tipo de Abatimento" column-label "Tipo de Abatimento"
    field tta_val_perc_rat_ctbz            as decimal format ">>9.99" decimals 2 initial 0 label "Perc Rateio" column-label "% Rat"
    field tta_ind_tip_aprop_recta_despes   as character format "x(20)" label "Tipo Apropria»’o" column-label "Tipo Apropria»’o"
    field tta_num_id_tit_acr               as integer format "9999999999" initial 0 label "Token Cta Receber" column-label "Token Cta Receber"
    field tta_num_id_aprop_despes_recta    as integer format "9999999999" initial 0 label "Id Apropria»’o" column-label "Id Apropria»’o"
    field tta_cod_tip_fluxo_financ         as character format "x(12)" label "Tipo Fluxo Financ" column-label "Tipo Fluxo Financ"
    field tta_cod_livre_1                  as character format "x(100)" label "Livre 1" column-label "Livre 1"
    index tt_aprpdspa_id                   is primary unique
          tta_cod_estab                    ascending
          tta_num_id_tit_acr               ascending
          tta_cod_plano_cta_ctbl           ascending
          tta_cod_cta_ctbl                 ascending
          tta_cod_unid_negoc               ascending
          tta_cod_tip_fluxo_financ         ascending
          tta_num_id_aprop_despes_recta    ascending
    index tt_aprpdspa_token                is unique
          tta_cod_estab                    ascending
          tta_num_id_aprop_despes_recta    ascending
    .
def temp-table tt_log_erros_alter_tit_acr no-undo
    field tta_cod_estab                    as character format "x(3)" label "Estabelecimento" column-label "Estab"
    field tta_num_id_tit_acr               as integer format "9999999999" initial 0 label "Token Cta Receber" column-label "Token Cta Receber"
    field ttv_num_mensagem                 as integer format ">>>>,>>9" label "Nœmero" column-label "Nœmero Mensagem"
    field ttv_cod_tip_msg_dwb              as character format "x(12)" label "Tipo Mensagem" column-label "Tipo Mensagem"
    field ttv_des_msg_erro                 as character format "x(60)" label "Mensagem Erro" column-label "Inconsist¼ncia"
    field ttv_des_msg_ajuda                as character format "x(40)" label "Mensagem Ajuda" column-label "Mensagem Ajuda"
    field ttv_wgh_focus                    as widget-handle format ">>>>>>9"
    index tt_relac_tit_acr
          tta_cod_estab                    ascending
          tta_num_id_tit_acr               ascending
          ttv_num_mensagem                 ascending
    .
def new shared temp-table tt_integr_acr_aprop_ctbl_pend no-undo
    field ttv_rec_item_lote_impl_tit_acr   as recid format ">>>>>>9"
    field tta_cod_plano_cta_ctbl           as character format "x(8)" label "Plano Contas" column-label "Plano Contas"
    field tta_cod_cta_ctbl                 as character format "x(20)" label "Conta Contÿbil" column-label "Conta Contÿbil"
    field tta_cod_cta_ctbl_ext             as character format "x(20)" label "Conta Contab Extern" column-label "Conta Contab Extern"
    field tta_cod_sub_cta_ctbl_ext         as character format "x(15)" label "Sub Conta Externa" column-label "Sub Conta Externa"
    field tta_cod_unid_negoc               as character format "x(3)" label "Unid Neg½cio" column-label "Un Neg"
    field tta_cod_unid_negoc_ext           as character format "x(8)" label "Unid Neg½cio Externa" column-label "Unid Neg½cio Externa"
    field tta_cod_plano_ccusto             as character format "x(8)" label "Plano Centros Custo" column-label "Plano Centros Custo"
    field tta_cod_ccusto                   as Character format "x(11)" label "Centro Custo" column-label "Centro Custo"
    field tta_cod_ccusto_ext               as character format "x(8)" label "Centro Custo Externo" column-label "CCusto Externo"
    field tta_cod_tip_fluxo_financ         as character format "x(12)" label "Tipo Fluxo Financ" column-label "Tipo Fluxo Financ"
    field tta_cod_fluxo_financ_ext         as character format "x(20)" label "Tipo Fluxo Externo" column-label "Tipo Fluxo Externo"
    field tta_val_aprop_ctbl               as decimal format "->>>,>>>,>>9.99" decimals 2 initial 0 label "Valor Aprop Ctbl" column-label "Vl Aprop Ctbl"
    field tta_cod_unid_federac             as character format "x(3)" label "Unidade Federa»’o" column-label "UF"
    field tta_log_impto_val_agreg          as logical format "Sim/N’o" initial no label "Impto Val Agreg" column-label "Imp Vl Agr"
    field tta_cod_imposto                  as character format "x(5)" label "Imposto" column-label "Imposto"
    field tta_cod_classif_impto            as character format "x(05)" initial "00000" label "Class Imposto" column-label "Class Imposto"
    field tta_cod_pais                     as character format "x(3)" label "Pais" column-label "Pais"
    field tta_cod_pais_ext                 as character format "x(20)" label "Pais Externo" column-label "Pais Externo"
    index tt_id                            is primary unique
          ttv_rec_item_lote_impl_tit_acr   ascending
          tta_cod_plano_cta_ctbl           ascending
          tta_cod_cta_ctbl                 ascending
          tta_cod_cta_ctbl_ext             ascending
          tta_cod_sub_cta_ctbl_ext         ascending
          tta_cod_unid_negoc               ascending
          tta_cod_unid_negoc_ext           ascending
          tta_cod_plano_ccusto             ascending
          tta_cod_ccusto                   ascending
          tta_cod_ccusto_ext               ascending
          tta_cod_tip_fluxo_financ         ascending
          tta_cod_fluxo_financ_ext         ascending
          tta_log_impto_val_agreg          ascending
    .

def new shared temp-table tt_integr_acr_aprop_desp_rec no-undo
    field ttv_rec_item_lote_impl_tit_acr   as recid format ">>>>>>9"
    field tta_cod_cta_ctbl_ext             as character format "x(20)" label "Conta Contab Extern" column-label "Conta Contab Extern"
    field tta_cod_sub_cta_ctbl_ext         as character format "x(15)" label "Sub Conta Externa" column-label "Sub Conta Externa"
    field tta_cod_unid_negoc_ext           as character format "x(8)" label "Unid Neg½cio Externa" column-label "Unid Neg½cio Externa"
    field tta_cod_fluxo_financ_ext         as character format "x(20)" label "Tipo Fluxo Externo" column-label "Tipo Fluxo Externo"
    field tta_val_perc_rat_ctbz            as decimal format ">>9.99" decimals 2 initial 0 label "Perc Rateio" column-label "% Rat"
    field tta_cod_plano_cta_ctbl           as character format "x(8)" label "Plano Contas" column-label "Plano Contas"
    field tta_cod_cta_ctbl                 as character format "x(20)" label "Conta Contÿbil" column-label "Conta Contÿbil"
    field tta_cod_unid_negoc               as character format "x(3)" label "Unid Neg½cio" column-label "Un Neg"
    field tta_cod_tip_abat                 as character format "x(8)" label "Tipo de Abatimento" column-label "Tipo de Abatimento"
    field tta_cod_tip_fluxo_financ         as character format "x(12)" label "Tipo Fluxo Financ" column-label "Tipo Fluxo Financ"
    field tta_ind_tip_aprop_recta_despes   as character format "x(20)" label "Tipo Apropria»’o" column-label "Tipo Apropria»’o"
    index tt_id                            is primary unique
          ttv_rec_item_lote_impl_tit_acr   ascending
          tta_cod_cta_ctbl_ext             ascending
          tta_cod_sub_cta_ctbl_ext         ascending
          tta_cod_unid_negoc_ext           ascending
          tta_cod_fluxo_financ_ext         ascending
          tta_cod_plano_cta_ctbl           ascending
          tta_cod_cta_ctbl                 ascending
          tta_cod_unid_negoc               ascending
          tta_cod_tip_fluxo_financ         ascending
          tta_ind_tip_aprop_recta_despes   ascending
          tta_cod_tip_abat                 ascending
    .
def new shared temp-table tt_integr_acr_item_lote_impl no-undo
    field ttv_rec_lote_impl_tit_acr        as recid format ">>>>>>9" initial ?
    field tta_num_seq_refer                as integer format ">>>9" initial 0 label "Sequ¼ncia" column-label "Seq"
    field tta_cdn_cliente                  as Integer format ">>>,>>>,>>9" initial 0 label "Cliente" column-label "Cliente"
    field tta_cod_espec_docto              as character format "x(3)" label "Esp²cie Documento" column-label "Esp²cie"
    field tta_cod_ser_docto                as character format "x(3)" label "S²rie Documento" column-label "S²rie"
    field tta_cod_tit_acr                  as character format "x(10)" label "Titulo" column-label "Titulo"
    field tta_cod_parcela                  as character format "x(02)" label "Parcela" column-label "Parc"
    field tta_cod_indic_econ               as character format "x(8)" label "Moeda" column-label "Moeda"
    field tta_cod_finalid_econ_ext         as character format "x(8)" label "Finalid Econ Externa" column-label "Finalidade Externa"
    field tta_cod_portador                 as character format "x(5)" label "Portador" column-label "Portador"
    field tta_cod_portad_ext               as character format "x(8)" label "Portador Externo" column-label "Portador Externo"
    field tta_cod_cart_bcia                as character format "x(3)" label "Carteira" column-label "Carteira"
    field tta_cod_modalid_ext              as character format "x(8)" label "Modalidade Externa" column-label "Modalidade Externa"
    field tta_cod_cond_cobr                as character format "x(8)" label "Condi»’o Cobran»a" column-label "Cond Cobran»a"
    field tta_cod_motiv_movto_tit_acr      as character format "x(8)" label "Motivo Movimento" column-label "Motivo Movimento"
    field tta_cod_histor_padr              as character format "x(8)" label "Hist½rico Padr’o" column-label "Hist½rico Padr’o"
    field tta_cdn_repres                   as Integer format ">>>,>>9" initial 0 label "Representante" column-label "Representante"
    field tta_dat_vencto_tit_acr           as date format "99/99/9999" initial ? label "Vencimento" column-label "Vencimento"
    field tta_dat_prev_liquidac            as date format "99/99/9999" initial ? label "Prev Liquida»’o" column-label "Prev Liquida»’o"
    field tta_dat_desconto                 as date format "99/99/9999" initial ? label "Data Desconto" column-label "Dt Descto"
    field tta_dat_emis_docto               as date format "99/99/9999" initial today label "Data  Emiss’o" column-label "Dt Emiss’o"
    field tta_val_tit_acr                  as decimal format ">>>,>>>,>>9.99" decimals 2 initial 0 label "Valor" column-label "Valor"
    field tta_val_desconto                 as decimal format "->>>,>>>,>>9.99" decimals 2 initial 0 label "Valor Desconto" column-label "Valor Desconto"
    field tta_val_perc_desc                as decimal format ">9.9999" decimals 4 initial 0 label "Percentual Desconto" column-label "Perc Descto"
    field tta_val_perc_juros_dia_atraso    as decimal format ">9.999999" decimals 6 initial 00.00 label "Perc Jur Dia Atraso" column-label "Perc Dia"
    field tta_val_perc_multa_atraso        as decimal format ">9.99" decimals 2 initial 00.00 label "Perc Multa Atraso" column-label "Multa Atr"
    field tta_val_base_calc_comis          as decimal format ">>>,>>>,>>9.99" decimals 2 initial 0 label "Base Calc Comis" column-label "Base Calc Comis"
    field tta_des_text_histor              as character format "x(2000)" label "Hist½rico" column-label "Hist½rico"
    field tta_qtd_dias_carenc_multa_acr    as decimal format ">>9" initial 0 label "Dias Carenc Multa" column-label "Dias Carenc Multa"
    field tta_cod_banco                    as character format "x(8)" label "Banco" column-label "Banco"
    field tta_cod_agenc_bcia               as character format "x(10)" label "Ag¼ncia Bancÿria" column-label "Ag¼ncia Bancÿria"
    field tta_cod_cta_corren_bco           as character format "x(20)" label "Conta Corrente Banco" column-label "Conta Corrente Banco"
    field tta_cod_digito_cta_corren        as character format "x(2)" label "Digito Cta Corrente" column-label "Digito Cta Corrente"
    field tta_cod_instruc_bcia_1_movto     as character format "x(4)" label "Instr Bancÿria 1" column-label "Instr Banc 1"
    field tta_cod_instruc_bcia_2_movto     as character format "x(4)" label "Instr Bancÿria 2" column-label "Instr Banc 2"
    field tta_qtd_dias_carenc_juros_acr    as decimal format ">>9" initial 0 label "Dias Carenc Juros" column-label "Dias Juros"
    field tta_val_liq_tit_acr              as decimal format ">>>,>>>,>>9.99" decimals 2 initial 0 label "Vl Liquido" column-label "Vl Liquido"
    field tta_ind_tip_espec_docto          as character format "X(17)" initial "Normal" label "Tipo Esp²cie" column-label "Tipo Esp²cie"
    field tta_cod_cond_pagto               as character format "x(8)" label "Condi»’o Pagamento" column-label "Condi»’o Pagamento"
    field ttv_cdn_agenc_fp                 as Integer format ">>>9" label "Ag¼ncia"
    field tta_ind_sit_tit_acr              as character format "X(13)" initial "Normal" label "Situa»’o Titulo" column-label "Situa»’o Titulo"
    field tta_log_liquidac_autom           as logical format "Sim/N’o" initial no label "Liquidac Automÿtica" column-label "Liquidac Automÿtica"
    field tta_num_id_tit_acr               as integer format "9999999999" initial 0 label "Token Cta Receber" column-label "Token Cta Receber"
    field tta_num_id_movto_tit_acr         as integer format "9999999999" initial 0 label "Token Movto Tit  ACR" column-label "Token Movto Tit  ACR"
    field tta_num_id_movto_cta_corren      as integer format "9999999999" initial 0 label "ID Movto Conta" column-label "ID Movto Conta"
    field tta_cod_admdra_cartao_cr         as character format "x(5)" label "Administradora" column-label "Administradora"
    field tta_cod_cartcred                 as character format "x(20)" label "C½digo Cart’o" column-label "C½digo Cart’o"
    field tta_cod_mes_ano_valid_cartao     as character format "XX/XXXX" label "Validade Cart’o" column-label "Validade Cart’o"
    field tta_cod_autoriz_cartao_cr        as character format "x(6)" label "C½d Pr²-Autoriza»’o" column-label "C½d Pr²-Autoriza»’o"
    field tta_dat_compra_cartao_cr         as date format "99/99/9999" initial ? label "Data Efetiv Venda" column-label "Data Efetiv Venda"
    field tta_cod_conces_telef             as character format "x(5)" label "Concessionÿria" column-label "Concessionÿria"
    field tta_num_ddd_localid_conces       as integer format "999" initial 0 label "DDD" column-label "DDD"
    field tta_num_prefix_localid_conces    as integer format ">>>9" initial 0 label "Prefixo" column-label "Prefixo"
    field tta_num_milhar_localid_conces    as integer format "9999" initial 0 label "Milhar" column-label "Milhar"
    field tta_log_tip_cr_perda_dedut_tit   as logical format "Sim/N’o" initial no label "Credito com Garantia" column-label "Cred Garant"
    field tta_cod_refer                    as character format "x(10)" label "Refer¼ncia" column-label "Refer¼ncia"
    field tta_ind_ender_cobr               as character format "X(15)" initial "Cliente" label "Endere»o Cobran»a" column-label "Endere»o Cobran»a"
    field tta_nom_abrev_contat             as character format "x(15)" label "Abreviado Contato" column-label "Abreviado Contato"
    field tta_log_db_autom                 as logical format "Sim/N’o" initial no label "D²bito Automÿtico" column-label "D²bito Automÿtico"
    field tta_log_destinac_cobr            as logical format "Sim/N’o" initial no label "Destin Cobran»a" column-label "Destin Cobran»a"
    field tta_ind_sit_bcia_tit_acr         as character format "X(12)" initial "Liberado" label "Sit Bancÿria" column-label "Sit Bancÿria"
    field tta_cod_tit_acr_bco              as character format "x(20)" label "Num Titulo Banco" column-label "Num Titulo Banco"
    field tta_cod_agenc_cobr_bcia          as character format "x(10)" label "Ag¼ncia Cobran»a" column-label "Ag¼ncia Cobr"
    field tta_dat_abat_tit_acr             as date format "99/99/9999" initial ? label "Abat" column-label "Abat"
    field tta_val_perc_abat_acr            as decimal format ">>9.9999" decimals 4 initial 0 label "Perc Abatimento" column-label "Abatimento"
    field tta_val_abat_tit_acr             as decimal format ">>>>,>>>,>>9.99" decimals 2 initial 0 label "Vl Abatimento" column-label "Vl Abatimento"
    field tta_des_obs_cobr                 as character format "x(40)" label "Obs Cobran»a" column-label "Obs Cobran»a"
    index tt_id                            is primary unique
          ttv_rec_lote_impl_tit_acr        ascending
          tta_num_seq_refer                ascending
    .        
def temp-table tt_integr_acr_item_lote_impl_4 no-undo
    field ttv_rec_lote_impl_tit_acr        as recid format ">>>>>>9" initial ?
    field tta_num_seq_refer                as integer format ">>>9" initial 0 label "Sequ¼ncia" column-label "Seq"
    field tta_cdn_cliente                  as Integer format ">>>,>>>,>>9" initial 0 label "Cliente" column-label "Cliente"
    field tta_cod_espec_docto              as character format "x(3)" label "Esp²cie Documento" column-label "Esp²cie"
    field tta_cod_ser_docto                as character format "x(3)" label "S²rie Documento" column-label "S²rie"
    field tta_cod_tit_acr                  as character format "x(10)" label "Titulo" column-label "Titulo"
    field tta_cod_parcela                  as character format "x(02)" label "Parcela" column-label "Parc"
    field tta_cod_indic_econ               as character format "x(8)" label "Moeda" column-label "Moeda"
    field tta_cod_finalid_econ_ext         as character format "x(8)" label "Finalid Econ Externa" column-label "Finalidade Externa"
    field tta_cod_portador                 as character format "x(5)" label "Portador" column-label "Portador"
    field tta_cod_portad_ext               as character format "x(8)" label "Portador Externo" column-label "Portador Externo"
    field tta_cod_cart_bcia                as character format "x(3)" label "Carteira" column-label "Carteira"
    field tta_cod_modalid_ext              as character format "x(8)" label "Modalidade Externa" column-label "Modalidade Externa"
    field tta_cod_cond_cobr                as character format "x(8)" label "Condi»’o Cobran»a" column-label "Cond Cobran»a"
    field tta_cod_motiv_movto_tit_acr      as character format "x(8)" label "Motivo Movimento" column-label "Motivo Movimento"
    field tta_cod_histor_padr              as character format "x(8)" label "Hist½rico Padr’o" column-label "Hist½rico Padr’o"
    field tta_cdn_repres                   as Integer format ">>>,>>9" initial 0 label "Representante" column-label "Representante"
    field tta_dat_vencto_tit_acr           as date format "99/99/9999" initial ? label "Vencimento" column-label "Vencimento"
    field tta_dat_prev_liquidac            as date format "99/99/9999" initial ? label "Prev Liquida»’o" column-label "Prev Liquida»’o"
    field tta_dat_desconto                 as date format "99/99/9999" initial ? label "Data Desconto" column-label "Dt Descto"
    field tta_dat_emis_docto               as date format "99/99/9999" initial today label "Data  Emiss’o" column-label "Dt Emiss’o"
    field tta_val_tit_acr                  as decimal format ">>>,>>>,>>9.99" decimals 2 initial 0 label "Valor" column-label "Valor"
    field tta_val_desconto                 as decimal format "->>>,>>>,>>9.99" decimals 2 initial 0 label "Valor Desconto" column-label "Valor Desconto"
    field tta_val_perc_desc                as decimal format ">9.9999" decimals 4 initial 0 label "Percentual Desconto" column-label "Perc Descto"
    field tta_val_perc_juros_dia_atraso    as decimal format ">9.999999" decimals 6 initial 00.00 label "Perc Jur Dia Atraso" column-label "Perc Dia"
    field tta_val_perc_multa_atraso        as decimal format ">9.99" decimals 2 initial 00.00 label "Perc Multa Atraso" column-label "Multa Atr"
    field tta_val_base_calc_comis          as decimal format ">>>,>>>,>>9.99" decimals 2 initial 0 label "Base Calc Comis" column-label "Base Calc Comis"
    field tta_des_text_histor              as character format "x(2000)" label "Hist½rico" column-label "Hist½rico"
    field tta_qtd_dias_carenc_multa_acr    as decimal format ">>9" initial 0 label "Dias Carenc Multa" column-label "Dias Carenc Multa"
    field tta_cod_banco                    as character format "x(8)" label "Banco" column-label "Banco"
    field tta_cod_agenc_bcia               as character format "x(10)" label "Ag¼ncia Bancÿria" column-label "Ag¼ncia Bancÿria"
    field tta_cod_cta_corren_bco           as character format "x(20)" label "Conta Corrente Banco" column-label "Conta Corrente Banco"
    field tta_cod_digito_cta_corren        as character format "x(2)" label "Digito Cta Corrente" column-label "Digito Cta Corrente"
    field tta_cod_instruc_bcia_1_movto     as character format "x(4)" label "Instr Bancÿria 1" column-label "Instr Banc 1"
    field tta_cod_instruc_bcia_2_movto     as character format "x(4)" label "Instr Bancÿria 2" column-label "Instr Banc 2"
    field tta_qtd_dias_carenc_juros_acr    as decimal format ">>9" initial 0 label "Dias Carenc Juros" column-label "Dias Juros"
    field tta_val_liq_tit_acr              as decimal format ">>>,>>>,>>9.99" decimals 2 initial 0 label "Vl Liquido" column-label "Vl Liquido"
    field tta_ind_tip_espec_docto          as character format "X(17)" initial "Normal" label "Tipo Esp²cie" column-label "Tipo Esp²cie"
    field tta_cod_cond_pagto               as character format "x(8)" label "Condi»’o Pagamento" column-label "Condi»’o Pagamento"
    field ttv_cdn_agenc_fp                 as Integer format ">>>9" label "Ag¼ncia"
    field tta_ind_sit_tit_acr              as character format "X(13)" initial "Normal" label "Situa»’o Titulo" column-label "Situa»’o Titulo"
    field tta_log_liquidac_autom           as logical format "Sim/N’o" initial no label "Liquidac Automÿtica" column-label "Liquidac Automÿtica"
    field tta_num_id_tit_acr               as integer format "9999999999" initial 0 label "Token Cta Receber" column-label "Token Cta Receber"
    field tta_num_id_movto_tit_acr         as integer format "9999999999" initial 0 label "Token Movto Tit  ACR" column-label "Token Movto Tit  ACR"
    field tta_num_id_movto_cta_corren      as integer format "9999999999" initial 0 label "ID Movto Conta" column-label "ID Movto Conta"
    field tta_cod_admdra_cartao_cr         as character format "x(5)" label "Administradora" column-label "Administradora"
    field tta_cod_cartcred                 as character format "x(20)" label "C½digo Cart’o" column-label "C½digo Cart’o"
    field tta_cod_mes_ano_valid_cartao     as character format "XX/XXXX" label "Validade Cart’o" column-label "Validade Cart’o"
    field tta_cod_autoriz_cartao_cr        as character format "x(6)" label "C½d Pr²-Autoriza»’o" column-label "C½d Pr²-Autoriza»’o"
    field tta_dat_compra_cartao_cr         as date format "99/99/9999" initial ? label "Data Efetiv Venda" column-label "Data Efetiv Venda"
    field tta_cod_conces_telef             as character format "x(5)" label "Concessionÿria" column-label "Concessionÿria"
    field tta_num_ddd_localid_conces       as integer format "999" initial 0 label "DDD" column-label "DDD"
    field tta_num_prefix_localid_conces    as integer format ">>>9" initial 0 label "Prefixo" column-label "Prefixo"
    field tta_num_milhar_localid_conces    as integer format "9999" initial 0 label "Milhar" column-label "Milhar"
    field tta_log_tip_cr_perda_dedut_tit   as logical format "Sim/N’o" initial no label "Credito com Garantia" column-label "Cred Garant"
    field tta_cod_refer                    as character format "x(10)" label "Refer¼ncia" column-label "Refer¼ncia"
    field tta_ind_ender_cobr               as character format "X(15)" initial "Cliente" label "Endere»o Cobran»a" column-label "Endere»o Cobran»a"
    field tta_nom_abrev_contat             as character format "x(15)" label "Abreviado Contato" column-label "Abreviado Contato"
    field tta_log_db_autom                 as logical format "Sim/N’o" initial no label "D²bito Automÿtico" column-label "D²bito Automÿtico"
    field tta_log_destinac_cobr            as logical format "Sim/N’o" initial no label "Destin Cobran»a" column-label "Destin Cobran»a"
    field tta_ind_sit_bcia_tit_acr         as character format "X(12)" initial "Liberado" label "Sit Bancÿria" column-label "Sit Bancÿria"
    field tta_cod_tit_acr_bco              as character format "x(20)" label "Num Titulo Banco" column-label "Num Titulo Banco"
    field tta_cod_agenc_cobr_bcia          as character format "x(10)" label "Ag¼ncia Cobran»a" column-label "Ag¼ncia Cobr"
    field tta_dat_abat_tit_acr             as date format "99/99/9999" initial ? label "Abat" column-label "Abat"
    field tta_val_perc_abat_acr            as decimal format ">>9.9999" decimals 4 initial 0 label "Perc Abatimento" column-label "Abatimento"
    field tta_val_abat_tit_acr             as decimal format ">>>>,>>>,>>9.99" decimals 2 initial 0 label "Vl Abatimento" column-label "Vl Abatimento"
    field tta_des_obs_cobr                 as character format "x(40)" label "Obs Cobran»a" column-label "Obs Cobran»a"
    field tta_val_cotac_indic_econ         as decimal format ">>>>,>>9.9999999999" decimals 10 initial 0 label "Cota»’o" column-label "Cota»’o"
    field ttv_rec_item_lote_impl_tit_acr   as recid format ">>>>>>9"
    field tta_ind_tip_calc_juros           as character format "x(10)" initial "Simples" label "Tipo Cÿlculo Juros" column-label "Tipo Cÿlculo Juros"
    field ttv_cod_comprov_vda              as character format "x(12)" label "Comprovante Venda" column-label "Comprovante Venda"
    field ttv_num_parc_cartcred            as integer format ">9" label "Quantidade Parcelas" column-label "Quantidade Parcelas"
    field ttv_cod_autoriz_bco_emissor      as character format "x(6)" label "Codigo Autoriza»’o" column-label "Codigo Autoriza»’o"
    field ttv_cod_lote_origin              as character format "x(7)" label "Lote Orig Venda" column-label "Lote Orig Venda"
    field ttv_cod_estab_vendor             as character format "x(3)" label "Estabelecimento" column-label "Estabelecimento"
    field ttv_num_planilha_vendor          as integer format ">>>,>>>,>>9" label "Planilha Vendor" column-label "Planilha Vendor"
    field ttv_cod_cond_pagto_vendor        as character format "x(3)" initial "0" label "Condi»’o Pagto" column-label "Condi»’o Pagto"
    field ttv_val_cotac_tax_vendor_clien   as decimal format ">>9.9999999999" decimals 10 label "Taxa Vendor Cliente" column-label "Taxa Vendor Cliente"
    field ttv_dat_base_fechto_vendor       as date format "99/99/9999" label "Data Base" column-label "Data Base"
    field ttv_qti_dias_carenc_fechto       as Integer format "->>9" label "Dias Car¼ncia" column-label "Dias Car¼ncia"
    field ttv_log_assume_tax_bco           as logical format "Sim/N’o" initial no label "Assume Taxa Banco" column-label "Assume Taxa Banco"
    field ttv_log_vendor                   as logical format "Sim/N’o" initial no
    field ttv_cod_estab_portad             as character format "x(8)"
    field tta_cod_proces_export            as character format "x(12)" label "Processo Exporta»’o" column-label "Processo Exporta»’o"
    index tt_id                            is primary unique
          ttv_rec_lote_impl_tit_acr        ascending
          tta_num_seq_refer                ascending
    .
def new shared temp-table tt_integr_acr_lote_impl no-undo
    field tta_cod_empresa                  as character format "x(3)" label "Empresa" column-label "Empresa"
    field ttv_cod_empresa_ext              as character format "x(3)" label "C½digo Empresa Ext" column-label "C½d Emp Ext"
    field tta_cod_estab                    as character format "x(3)" label "Estabelecimento" column-label "Estab"
    field tta_cod_estab_ext                as character format "x(8)" label "Estabelecimento Exte" column-label "Estabelecimento Ext"
    field tta_cod_refer                    as character format "x(10)" label "Refer¼ncia" column-label "Refer¼ncia"
    field tta_cod_indic_econ               as character format "x(8)" label "Moeda" column-label "Moeda"
    field tta_cod_finalid_econ_ext         as character format "x(8)" label "Finalid Econ Externa" column-label "Finalidade Externa"
    field tta_cod_espec_docto              as character format "x(3)" label "Esp²cie Documento" column-label "Esp²cie"
    field tta_dat_transacao                as date format "99/99/9999" initial today label "Data Transa»’o" column-label "Dat Transac"
    field tta_ind_tip_espec_docto          as character format "X(17)" initial "Normal" label "Tipo Esp²cie" column-label "Tipo Esp²cie"
    field tta_ind_orig_tit_acr             as character format "X(8)" initial "ACREMS50" label "Origem Tit Cta Rec" column-label "Origem Tit Cta Rec"
    field tta_val_tot_lote_impl_tit_acr    as decimal format ">>,>>>,>>>,>>9.99" decimals 2 initial 0 label "Total Movimento" column-label "Total Movimento"
    field tta_val_tot_lote_infor_tit_acr   as decimal format ">>,>>>,>>>,>>9.99" decimals 2 initial 0 label "Total Informado" column-label "Total Informado"
    field tta_ind_tip_cobr_acr             as character format "X(10)" initial "Normal" label "Tipo Cobran»a" column-label "Tipo Cobran»a"
    field ttv_log_lote_impl_ok             as logical format "Sim/N’o" initial no
    field tta_log_liquidac_autom           as logical format "Sim/N’o" initial no label "Liquidac Automÿtica" column-label "Liquidac Automÿtica"
    index tt_id                            is primary unique
          tta_cod_estab                    ascending
          tta_cod_estab_ext                ascending
          tta_cod_refer                    ascending
    .
def new shared temp-table tt_integr_acr_repres_pend no-undo
    field ttv_rec_item_lote_impl_tit_acr   as recid format ">>>>>>9"
    field tta_cdn_repres                   as Integer format ">>>,>>9" initial 0 label "Representante" column-label "Representante"
    field tta_val_perc_comis_repres        as decimal format ">>9.99" decimals 2 initial 0 label "% Comiss’o" column-label "% Comiss’o"
    field tta_val_perc_comis_repres_emis   as decimal format ">>9.99" decimals 2 initial 0 label "% Comis Emiss’o" column-label "% Comis Emiss’o"
    field tta_val_perc_comis_abat          as decimal format ">>9.99" decimals 2 initial 0 label "% Comis Abatimento" column-label "% Comis Abatimento"
    field tta_val_perc_comis_desc          as decimal format ">>9.99" decimals 2 initial 0 label "% Comis Desconto" column-label "% Comis Desconto"
    field tta_val_perc_comis_juros         as decimal format ">>9.99" decimals 2 initial 0 label "% Comis Juros" column-label "% Comis Juros"
    field tta_val_perc_comis_multa         as decimal format ">>9.99" decimals 2 initial 0 label "% Comis Multa" column-label "% Comis Multa"
    field tta_val_perc_comis_acerto_val    as decimal format ">>9.99" decimals 2 initial 0 label "% Comis AVA" column-label "% Comis AVA"
    field tta_log_comis_repres_proporc     as logical format "Sim/N’o" initial no label "Comis Proporcional" column-label "Comis Propor"
    field tta_ind_tip_comis                as character format "X(15)" initial "Valor Bruto" label "Tipo Comiss’o" column-label "Tipo Comiss’o"
    index tt_id                            is primary unique
          ttv_rec_item_lote_impl_tit_acr   ascending
          tta_cdn_repres                   ascending
    .
def new shared temp-table tt_log_erros_atualiz no-undo
    field tta_cod_estab                    as character format "x(3)" label "Estabelecimento" column-label "Estab"
    field tta_cod_refer                    as character format "x(10)" label "Refer¼ncia" column-label "Refer¼ncia"
    field tta_num_seq_refer                as integer format ">>>9" initial 0 label "Sequ¼ncia" column-label "Seq"
    field ttv_num_mensagem                 as integer format ">>>>,>>9" label "Nœmero" column-label "Nœmero Mensagem"
    field ttv_des_msg_erro                 as character format "x(60)" label "Mensagem Erro" column-label "Inconsist¼ncia"
    field ttv_des_msg_ajuda                as character format "x(40)" label "Mensagem Ajuda" column-label "Mensagem Ajuda"
    field ttv_ind_tip_relacto              as character format "X(15)" label "Tipo Relacionamento" column-label "Tipo Relac"
    field ttv_num_relacto                  as integer format ">>>>,>>9" label "Relacionamento" column-label "Relacionamento"
    .
def temp-table tt_integr_acr_estorn_cancel no-undo
    field ttv_ind_niv_operac_acr           as character format "X(12)" label "N­vel Opera»’o" column-label "N­vel Opera»’o"
    field ttv_ind_tip_operac_acr           as character format "X(15)" label "Tipo Opera»’o" column-label "Tipo Opera»’o"
    field tta_cod_estab                    as character format "x(3)" label "Estabelecimento" column-label "Estab"
    field tta_num_id_tit_acr               as integer format "9999999999" initial 0 label "Token Cta Receber" column-label "Token Cta Receber"
    field tta_num_id_movto_tit_acr         as integer format "9999999999" initial 0 label "Token Movto Tit  ACR" column-label "Token Movto Tit  ACR"
    field tta_cod_refer                    as character format "x(10)" label "Refer¼ncia" column-label "Refer¼ncia"
    field tta_dat_transacao                as date format "99/99/9999" initial today label "Data Transa»’o" column-label "Dat Transac"
    field tta_des_text_histor              as character format "x(2000)" label "Hist½rico" column-label "Hist½rico"
    field ttv_cod_estab_reembol            as character format "x(8)"
    field ttv_cod_portad_reembol           as character format "x(5)"
    field ttv_cod_cart_bcia_reembol        as character format "x(3)"
    index tt_id                            is primary unique
          tta_cod_estab                    ascending
          tta_num_id_tit_acr               ascending
          tta_num_id_movto_tit_acr         ascending
    .
def temp-table tt_log_erros_estorn_cancel no-undo
    field tta_cod_estab                    as character format "x(3)" label "Estabelecimento" column-label "Estab"
    field tta_num_id_tit_acr               as integer format "9999999999" initial 0 label "Token Cta Receber" column-label "Token Cta Receber"
    field tta_num_id_movto_tit_acr         as integer format "9999999999" initial 0 label "Token Movto Tit  ACR" column-label "Token Movto Tit  ACR"
    field ttv_num_mensagem                 as integer format ">>>>,>>9" label "Nœmero" column-label "Nœmero Mensagem"
    field ttv_des_msg_erro                 as character format "x(60)" label "Mensagem Erro" column-label "Inconsist¼ncia"
    field ttv_des_msg_ajuda                as character format "x(40)" label "Mensagem Ajuda" column-label "Mensagem Ajuda"
    index tt_relac_tit_acr                
          tta_cod_estab                    ascending
          tta_num_id_tit_acr               ascending
          tta_num_id_movto_tit_acr         ascending
          ttv_num_mensagem                 ascending
    .
def temp-table tt_input_estorno no-undo
    field ttv_cod_label                    as character format "x(8)" label "Label" column-label "Label"
    field ttv_des_conteudo                 as character format "x(40)" label "Texto" column-label "Texto"
    field ttv_num_seq                      as integer format ">>>,>>9" label "Sequ¼ncia" column-label "Seq"
    index tt_primario                      is primary
          ttv_num_seq                      ascending
    .
def temp-table tt_alter_tit_acr_base no-undo
    field tta_cod_estab                    as character format "x(3)" label "Estabelecimento" column-label "Estab"
    field tta_num_id_tit_acr               as integer format "9999999999" initial 0 label "Token Cta Receber" column-label "Token Cta Receber"
    field tta_dat_transacao                as date format "99/99/9999" initial today label "Data Transa»’o" column-label "Dat Transac"
    field tta_cod_refer                    as character format "x(10)" label "Refer¼ncia" column-label "Refer¼ncia"
    field ttv_cod_motiv_movto_tit_acr_imp  as character format "x(8)" label "Motivo Impl" column-label "Motivo Movimento"
    field tta_val_sdo_tit_acr              as decimal format ">>>,>>>,>>9.99" decimals 2 initial 0 label "Saldo T­tulo" column-label "Saldo T­tulo"
    field ttv_cod_motiv_movto_tit_acr_alt  as character format "x(8)" label "Motivo Alter" column-label "Motivo Movimento"
    field ttv_ind_motiv_acerto_val         as character format "X(12)" label "Motivo Acerto Valor" column-label "Motivo Acerto Valor"
    field tta_cod_portador                 as character format "x(5)" label "Portador" column-label "Portador"
    field tta_cod_cart_bcia                as character format "x(3)" label "Carteira" column-label "Carteira"
    field tta_val_despes_bcia              as decimal format "->>>,>>>,>>9.99" decimals 2 initial 0 label "Vl Desp Banc" column-label "Vl Desp Banc"
    field tta_cod_agenc_cobr_bcia          as character format "x(10)" label "Ag¼ncia Cobran»a" column-label "Ag¼ncia Cobr"
    field tta_cod_tit_acr_bco              as character format "x(20)" label "Num T­tulo Banco" column-label "Num T­tulo Banco"
    field tta_dat_emis_docto               as date format "99/99/9999" initial today label "Data  Emiss’o" column-label "Dt Emiss’o"
    field tta_dat_vencto_tit_acr           as date format "99/99/9999" initial ? label "Vencimento" column-label "Vencimento"
    field tta_dat_prev_liquidac            as date format "99/99/9999" initial ? label "Prev Liquida»’o" column-label "Prev Liquida»’o"
    field tta_dat_fluxo_tit_acr            as date format "99/99/9999" initial ? label "Fluxo" column-label "Fluxo"
    field tta_ind_sit_tit_acr              as character format "X(13)" initial "Normal" label "Situa»’o T­tulo" column-label "Situa»’o T­tulo"
    field tta_cod_cond_cobr                as character format "x(8)" label "Condi»’o Cobran»a" column-label "Cond Cobran»a"
    field tta_log_tip_cr_perda_dedut_tit   as logical format "Sim/N’o" initial no label "Credito com Garantia" column-label "Cred Garant"
    field tta_dat_abat_tit_acr             as date format "99/99/9999" initial ? label "Abat" column-label "Abat"
    field tta_val_perc_abat_acr            as decimal format ">>9.9999" decimals 4 initial 0 label "Perc Abatimento" column-label "Abatimento"
    field tta_val_abat_tit_acr             as decimal format ">>>>,>>>,>>9.99" decimals 2 initial 0 label "Vl Abatimento" column-label "Vl Abatimento"
    field tta_dat_desconto                 as date format "99/99/9999" initial ? label "Data Desconto" column-label "Dt Descto"
    field tta_val_perc_desc                as decimal format ">9.9999" decimals 4 initial 0 label "Percentual Desconto" column-label "Perc Descto"
    field tta_val_desc_tit_acr             as decimal format ">>>>,>>>,>>9.99" decimals 2 initial 0 label "Vl Desc" column-label "Vl Desc"
    field tta_qtd_dias_carenc_juros_acr    as decimal format ">>9" initial 0 label "Dias Carenc Juros" column-label "Dias Juros"
    field tta_val_perc_juros_dia_atraso    as decimal format ">9.999999" decimals 6 initial 00.00 label "Perc Jur Dia Atraso" column-label "Perc Dia"
    field tta_qtd_dias_carenc_multa_acr    as decimal format ">>9" initial 0 label "Dias Carenc Multa" column-label "Dias Carenc Multa"
    field tta_val_perc_multa_atraso        as decimal format ">9.99" decimals 2 initial 00.00 label "Perc Multa Atraso" column-label "Multa Atr"
    field ttv_cod_portador_mov             as character format "x(5)" label "Portador Movto" column-label "Portador Movto"
    field tta_ind_tip_cobr_acr             as character format "X(10)" initial "Normal" label "Tipo Cobran»a" column-label "Tipo Cobran»a"
    field tta_ind_ender_cobr               as character format "X(15)" initial "Cliente" label "Endere»o Cobran»a" column-label "Endere»o Cobran»a"
    field tta_nom_abrev_contat             as character format "x(15)" label "Abreviado Contato" column-label "Abreviado Contato"
    field tta_val_liq_tit_acr              as decimal format ">>>,>>>,>>9.99" decimals 2 initial 0 label "Vl L­quido" column-label "Vl L­quido"
    field tta_cod_instruc_bcia_1_movto     as character format "x(4)" label "Instr Bancÿria 1" column-label "Instr Banc 1"
    field tta_cod_instruc_bcia_2_movto     as character format "x(4)" label "Instr Bancÿria 2" column-label "Instr Banc 2"
    field tta_log_tit_acr_destndo          as logical format "Sim/N’o" initial no label "Destinado" column-label "Destinado"
    field tta_cod_histor_padr              as character format "x(8)" label "Hist½rico Padr’o" column-label "Hist½rico Padr’o"
    field ttv_des_text_histor              as character format "x(2000)" label "Hist½rico" column-label "Hist½rico"
    field tta_des_obs_cobr                 as character format "x(40)" label "Obs Cobran»a" column-label "Obs Cobran»a"
    field ttv_wgh_lista                    as widget-handle extent 26 format ">>>>>>9"
    index tt_id                            is primary unique
          tta_cod_estab                    ascending
          tta_num_id_tit_acr               ascending
    .
def temp-table tt_alter_tit_acr_cobr_espec_1 no-undo
    field tta_cod_estab                    as character format "x(3)" label "Estabelecimento" column-label "Estab"
    field tta_num_id_tit_acr               as integer format "9999999999" initial 0 label "Token Cta Receber" column-label "Token Cta Receber"
    field tta_num_seq_tit_acr              as integer format ">>>9" initial 0 label "Sequ¬ncia" column-label "Sequ¬ncia"
    field tta_num_id_cobr_especial_acr     as integer format "99999999" initial 0 label "Token Cobr Especial" column-label "Token Cobr Especial"
    field tta_val_tit_acr                  as decimal format ">>>,>>>,>>9.99" decimals 2 initial 0 label "Valor" column-label "Valor"
    field tta_cod_portador                 as character format "x(5)" label "Portador" column-label "Portador"
    field tta_cod_cart_bcia                as character format "x(3)" label "Carteira" column-label "Carteira"
    field tta_cod_cartcred                 as character format "x(20)" label "C«digo CartÊo" column-label "C«digo CartÊo"
    field tta_cod_autoriz_cartao_cr        as character format "x(6)" label "C«d Prý-Autoriza¯Êo" column-label "C«d Prý-Autoriza¯Êo"
    field tta_cod_mes_ano_valid_cartao     as character format "XX/XXXX" label "Validade CartÊo" column-label "Validade CartÊo"
    field tta_dat_compra_cartao_cr         as date format "99/99/9999" initial ? label "Data Efetiv Venda" column-label "Data Efetiv Venda"
    field tta_cod_banco                    as character format "x(8)" label "Banco" column-label "Banco"
    field tta_cod_agenc_bcia               as character format "x(10)" label "Ag¬ncia Banc˜ria" column-label "Ag¬ncia Banc˜ria"
    field tta_cod_cta_corren_bco           as character format "x(20)" label "Conta Corrente Banco" column-label "Conta Corrente Banco"
    field tta_cod_digito_cta_corren        as character format "x(2)" label "Dðgito Cta Corrente" column-label "Dðgito Cta Corrente"
    field tta_num_ddd_localid_conces       as integer format "999" initial 0 label "DDD" column-label "DDD"
    field tta_num_prefix_localid_conces    as integer format ">>>9" initial 0 label "Prefixo" column-label "Prefixo"
    field tta_num_milhar_localid_conces    as integer format "9999" initial 0 label "Milhar" column-label "Milhar"
    field tta_des_text_histor              as character format "x(2000)" label "Hist«rico" column-label "Hist«rico"
    field ttv_log_alter_tip_cobr_acr       as logical format "Sim/NÊo" initial no label "Alter Tip Cobr" column-label "Alter Tip Cobr"
    field tta_ind_sit_tit_cobr_especial    as character format "X(15)" label "Situa¯Êo Tðtulo" column-label "Situa¯Êo Tðtulo"
    field ttv_cod_comprov_vda              as character format "x(12)" label "Comprovante Venda" column-label "Comprovante Venda"
    field ttv_num_parc_cartcred            as integer format ">9" label "Quantidade Parcelas" column-label "Quantidade Parcelas"
    field ttv_val_tot_sdo_tit_acr          as decimal format ">>>,>>>,>>9.99" decimals 2 initial 0 label "Val Total Parcelas" column-label "Val Total Parcelas"
    index tt_id                            is primary unique
          tta_cod_estab                    ascending
          tta_num_id_tit_acr               ascending
          tta_num_seq_tit_acr              ascending
    .
def temp-table tt_alter_tit_acr_impto_retid no-undo
    field tta_cod_estab                    as character format "x(3)" label "Estabelecimento" column-label "Estab"
    field tta_num_id_tit_acr               as integer format "9999999999" initial 0 label "Token Cta Receber" column-label "Token Cta Receber"
    field tta_cod_pais                     as character format "x(3)" label "Paðs" column-label "Paðs"
    field tta_cod_unid_federac             as character format "x(3)" label "Unidade Federa¯Êo" column-label "UF"
    field tta_cod_imposto                  as character format "x(5)" label "Imposto" column-label "Imposto"
    field tta_cod_classif_impto            as character format "x(05)" initial "00000" label "Class Imposto" column-label "Class Imposto"
    field tta_num_impto_refer_tit_acr      as integer format ">>>>>9" initial 0 label "Impto Refer" column-label "Impto Refer"
    field ttv_num_tip_operac               as integer format ">9"
    field tta_val_aliq_impto               as decimal format ">9.99" decimals 2 initial 0.00 label "Alðquota" column-label "Aliq"
    index tt_id                            is primary unique
          tta_cod_estab                    ascending
          tta_num_id_tit_acr               ascending
          tta_cod_pais                     ascending
          tta_cod_unid_federac             ascending
          tta_cod_imposto                  ascending
          tta_cod_classif_impto            ascending
          tta_num_impto_refer_tit_acr      ascending
    .
