define temp-table tt_integr_acr_item_lote_impl_8 no-undo
    field ttv_rec_lote_impl_tit_acr        as recid format ">>>>>>9" initial ?
    field tta_num_seq_refer                as integer format ">>>9" initial 0 label "Secuencia" column-label "Sec"
    field tta_cdn_cliente                  as Integer format ">>>,>>>,>>9" initial 0 label "Cliente" column-label "Cliente"
    field tta_cod_espec_docto              as character format "x(3)" label "Clase Documento" column-label "Clase"
    field tta_cod_ser_docto                as character format "x(3)" label "Serie Documento" column-label "Serie"
    field tta_cod_tit_acr                  as character format "x(10)" label "T¡tulo" column-label "T¡tulo"
    field tta_cod_parcela                  as character format "x(02)" label "Cuota" column-label "Cuota"
    field tta_cod_indic_econ               as character format "x(8)" label "Moneda" column-label "Moneda"
    field tta_cod_finalid_econ_ext         as character format "x(8)" label "Finalid Econ Externa" column-label "Finalidad Externa"
    field tta_cod_portador                 as character format "x(5)" label "Portador" column-label "Portador"
    field tta_cod_portad_ext               as character format "x(8)" label "Portador Externo" column-label "Portador Externo"
    field tta_cod_cart_bcia                as character format "x(3)" label "Cartera" column-label "Cartera"
    field tta_cod_modalid_ext              as character format "x(8)" label "Modalidad Externa" column-label "Modalidad Externa"
    field tta_cod_cond_cobr                as character format "x(8)" label "Condici¢n Cobro" column-label "Cond Cobranza"
    field tta_cod_motiv_movto_tit_acr      as character format "x(8)" label "Motivo Movimiento" column-label "Motivo Movimiento"
    field tta_cod_histor_padr              as character format "x(8)" label "Hist¢rico Est nd" column-label "Hist¢rico Est nd"
    field tta_cdn_repres                   as Integer format ">>>,>>9" initial 0 label "Representante" column-label "Representante"
    field tta_dat_vencto_tit_acr           as date format "99/99/9999" initial ? label "Vencimiento" column-label "Vencimiento"
    field tta_dat_prev_liquidac            as date format "99/99/9999" initial ? label "Prev Liquidaci¢n" column-label "Prev Liquidaci¢n"
    field tta_dat_desconto                 as date format "99/99/9999" initial ? label "Fecha Descto" column-label "Fch Descto"
    field tta_dat_emis_docto               as date format "99/99/9999" initial today label "Fecha Emisi¢n" column-label "Fch Emisi¢n"
    field tta_val_tit_acr                  as decimal format ">>>,>>>,>>9.99" decimals 2 initial 0 label "Valor" column-label "Valor"
    field tta_val_desconto                 as decimal format "->>>,>>>,>>9.99" decimals 2 initial 0 label "Valor Descuento" column-label "Valor Descuento"
    field tta_val_perc_desc                as decimal format ">9.9999" decimals 4 initial 0 label "Porcentaje Descuento" column-label "% Descto"
    field tta_val_perc_juros_dia_atraso    as decimal format ">9.999999" decimals 6 initial 00.00 label "% Inter D¡a Atraso" column-label "% D¡a"
    field tta_val_perc_multa_atraso        as decimal format ">9.99" decimals 2 initial 00.00 label "% Multa Atraso" column-label "Multa Atr"
    field tta_val_base_calc_comis          as decimal format ">>>,>>>,>>9.99" decimals 2 initial 0 label "Base C lc Comis" column-label "Base C lc Comis"
    field tta_des_text_histor              as character format "x(2000)" label "Hist¢rico" column-label "Hist¢rico"
    field tta_qtd_dias_carenc_multa_acr    as decimal format ">>9" initial 0 label "D¡as Carencia Multa" column-label "D¡as Carencia Multa"
    field tta_cod_banco                    as character format "x(8)" label "Banco" column-label "Banco"
    field tta_cod_agenc_bcia               as character format "x(10)" label "Agencia Bancaria" column-label "Agencia Bancaria"
    field tta_cod_cta_corren_bco           as character format "x(20)" label "Cta Corriente Banco" column-label "Cta Corriente Banco"
    field tta_cod_digito_cta_corren        as character format "x(2)" label "D¡gito Cta Corriente" column-label "D¡gito Cta Corriente"
    field tta_cod_instruc_bcia_1_movto     as character format "x(4)" label "Instr Bancaria 1" column-label "Instr Banc 1"
    field tta_cod_instruc_bcia_2_movto     as character format "x(4)" label "Instr Bancaria 2" column-label "Instr Banc 2"
    field tta_qtd_dias_carenc_juros_acr    as decimal format ">>9" initial 0 label "D¡as Carencia Inter" column-label "D¡as Inter"
    field tta_val_liq_tit_acr              as decimal format ">>>,>>>,>>9.99" decimals 2 initial 0 label "Vl L¡quido" column-label "Vl L¡quido"
    field tta_ind_tip_espec_docto          as character format "X(17)" initial "Normal" label "Tipo Clase" column-label "Tipo Clase"
    field tta_cod_cond_pagto               as character format "x(8)" label "Condici¢n Pago" column-label "Condici¢n Pago"
    field ttv_cdn_agenc_fp                 as Integer format ">>>9" label "Agencia"
    field tta_ind_sit_tit_acr              as character format "X(13)" initial "Normal" label "Situaci¢n T¡tulo" column-label "Situaci¢n T¡tulo"
    field tta_log_liquidac_autom           as logical format "S¡/No" initial no label "Liquidaci¢n Autom tica" column-label "Liquidaci¢n Autom tica"
    field tta_num_id_tit_acr               as integer format "9999999999" initial 0 label "Token Cta Cobrar" column-label "Token Cta Cobrar"
    field tta_num_id_movto_tit_acr         as integer format "9999999999" initial 0 label "Token Movto T¡t CR" column-label "Token Movto T¡t CR"
    field tta_num_id_movto_cta_corren      as integer format "9999999999" initial 0 label "ID Movto Cta" column-label "ID Movto Cta"
    field tta_cod_admdra_cartao_cr         as character format "x(5)" label "Administradora" column-label "Administradora"
    field tta_cod_cartcred                 as character format "x(20)" label "C¢d Tarjeta" column-label "C¢d Tarjeta"
    field tta_cod_mes_ano_valid_cartao     as character format "XX/XXXX" label "Validez Tarjeta" column-label "Validez Tarjeta"
    field tta_cod_autoriz_cartao_cr        as character format "x(6)" label "C¢d Preautorizaci¢n" column-label "C¢d Preautorizaci¢n"
    field tta_dat_compra_cartao_cr         as date format "99/99/9999" initial ? label "Fcha Ejec Venta" column-label "Fcha Ejec Venta"
    field tta_cod_conces_telef             as character format "x(5)" label "Concesionaria" column-label "Concesionaria"
    field tta_num_ddd_localid_conces       as integer format "999" initial 0 label "DDD" column-label "DDD"
    field tta_num_prefix_localid_conces    as integer format ">>>9" initial 0 label "Prefijo" column-label "Prefijo"
    field tta_num_milhar_localid_conces    as integer format "9999" initial 0 label "Millar" column-label "Millar"
    field tta_log_tip_cr_perda_dedut_tit   as logical format "S¡/No" initial no label "Cr‚dito con Garant¡a" column-label "Cr‚d Garant"
    field tta_cod_refer                    as character format "x(10)" label "Referencia" column-label "Referencia"
    field tta_ind_ender_cobr               as character format "X(15)" initial "Cliente" label "Direcci¢n Cobranza" column-label "Direcci¢n Cobranza"
    field tta_nom_abrev_contat             as character format "x(15)" label "Abreviado Contact" column-label "Abreviado Contact"
    field tta_log_db_autom                 as logical format "S¡/No" initial no label "D‚bito Autom tico" column-label "D‚bito Autom tico"
    field tta_log_destinac_cobr            as logical format "S¡/No" initial no label "Destino Cobranza" column-label "Destino Cobranza"
    field tta_ind_sit_bcia_tit_acr         as character format "X(12)" initial "Liberado" label "Sit Bancaria" column-label "Sit Bancaria"
    field tta_cod_tit_acr_bco              as character format "x(20)" label "N§ T¡tulo Banco" column-label "N§ T¡tulo Banco"
    field tta_cod_agenc_cobr_bcia          as character format "x(10)" label "Agencia Cobranza" column-label "Agencia Cobr"
    field tta_dat_abat_tit_acr             as date format "99/99/9999" initial ? label "Reb" column-label "Reb"
    field tta_val_perc_abat_acr            as decimal format ">>9.9999" decimals 4 initial 0 label "% Rebaja" column-label "Rebaja"
    field tta_val_abat_tit_acr             as decimal format ">>>>,>>>,>>9.99" decimals 2 initial 0 label "Vl Rebaja" column-label "Vl Rebaja"
    field tta_des_obs_cobr                 as character format "x(40)" label "Obs Cobranza" column-label "Obs Cobranza"
    field tta_val_cotac_indic_econ         as decimal format ">>>>,>>9.9999999999" decimals 10 initial 0 label "Cotiz" column-label "Cotiz"
    field ttv_rec_item_lote_impl_tit_acr   as recid format ">>>>>>9"
    field tta_ind_tip_calc_juros           as character format "x(10)" initial "Simple" label "Tipo C lculo Inter" column-label "Tipo C lculo Inter"
    field ttv_cod_comprov_vda_aux          as character format "x(12)"
    field ttv_num_parc_cartcred            as integer format ">9" label "Cantidad Cuotas" column-label "Cantidad Cuotas"
    field ttv_cod_autoriz_bco_emissor      as character format "x(6)" label "C¢d Autorizaci¢n" column-label "C¢d Autorizaci¢n"
    field ttv_cod_lote_origin              as character format "x(7)" label "Lote Orig Venta" column-label "Lote Orig Venta"
    field ttv_cod_estab_vendor             as character format "x(3)" label "Sucursal" column-label "Sucursal"
    field ttv_num_planilha_vendor          as integer format ">>>,>>>,>>9" initial 0 label "Planilla Vendor" column-label "Planilla Vendor"
    field ttv_cod_cond_pagto_vendor        as character format "x(3)" initial "0" label "Condici¢n Pago" column-label "Condici¢n Pago"
    field ttv_val_cotac_tax_vendor_clien   as decimal format ">>9.9999999999" decimals 10 label "Taza Vendor Cliente" column-label "Taza Vendor Cliente"
    field ttv_dat_base_fechto_vendor       as date format "99/99/9999" initial today label "Fch Base" column-label "Fch Base"
    field ttv_qti_dias_carenc_fechto       as Integer format "->>9" label "D¡as Carencia" column-label "D¡as Carencia"
    field ttv_log_assume_tax_bco           as logical format "S¡/No" initial no label "Asume Taza Banco" column-label "Asume Taza Banco"
    field ttv_log_vendor                   as logical format "S¡/No" initial no
    field ttv_cod_estab_portad             as character format "x(8)"
    field tta_cod_proces_export            as character format "x(12)" label "Proceso Exportac" column-label "Proceso Exportac"
    field ttv_val_cr_pis                   as decimal format ">>>,>>>,>>9.99" decimals 2 initial 0 label "Valor Cr‚dito Imp" column-label "Vl Cr‚d IMP"
    field ttv_val_cr_cofins                as decimal format ">>>,>>>,>>9.99" decimals 2 initial 0 label "Valor Cr‚dito IMP" column-label "Cr‚dito IMP"
    field ttv_val_cr_csll                  as decimal format ">>>,>>>,>>9.99" decimals 2 initial 0 label "Valor Cr‚dito IMP" column-label "Cr‚dito IMP"
    field tta_cod_indic_econ_desemb        as character format "x(8)" label "Moned Desembolso" column-label "Moned Desembolso"
    field tta_val_base_calc_impto          as decimal format ">>>,>>>,>>9.99" decimals 2 initial 0 label "Base C lculo Imp" column-label "Base C lculo Imp"
    field tta_log_retenc_impto_impl        as logical format "S¡/No" initial no label "Ret Imp Impl" column-label "Ret Imp Impl"
    field ttv_cod_nota_fisc_faturam        as character format "x(16)"
    index tt_id                            is primary unique
          ttv_rec_lote_impl_tit_acr        ascending
          tta_num_seq_refer                ascending.

define temp-table tt_integr_acr_repres_comis_2 no-undo
    field ttv_rec_item_lote_impl_tit_acr   as recid format ">>>>>>9"
    field tta_cdn_repres                   as Integer format ">>>,>>9" initial 0 label "Representante" column-label "Representante"
    field tta_ind_tip_comis_ext            as character format "X(15)" initial "Ning£n" label "Tipo Comis Externo" column-label "Tipo Comis Externo"
    field ttv_ind_liber_pagto_comis        as character format "X(20)" initial "Ning£n" label "Lib Pago Comis" column-label "Lib Comis"
    field ttv_ind_sit_comis_ext            as character format "X(10)" initial "Ning£n" label "Sit Comis Ext" column-label "Sit Comis Ext".

define temp-table tt_integr_acr_aprop_relacto_2 no-undo
    field ttv_rec_relacto_pend_tit_acr     as recid format ">>>>>>9" initial ? label "TK Relac Tit" column-label "TK Relac Tit"
    field tta_cod_plano_ccusto             as character format "x(8)" label "Plan Centros Costo" column-label "Plan Centros Costo"
    field tta_cod_ccusto                   as Character format "x(11)" label "Centro Costo" column-label "Centro Costo".

define new shared temp-table tt_integr_acr_abat_antecip no-undo
    field ttv_rec_item_lote_impl_tit_acr   as recid format ">>>>>>9"
    field ttv_rec_abat_antecip_acr         as recid format ">>>>>>9"
    field tta_cod_estab                    as character format "x(3)" label "Sucursal" column-label "Suc"
    field tta_cod_estab_ext                as character format "x(8)" label "Sucursal Externa" column-label "Sucursal Ext"
    field tta_cod_espec_docto              as character format "x(3)" label "Clase Documento" column-label "Clase"
    field tta_cod_ser_docto                as character format "x(3)" label "Serie Documento" column-label "Serie"
    field tta_cod_tit_acr                  as character format "x(10)" label "T¡tulo" column-label "T¡tulo"
    field tta_cod_parcela                  as character format "x(02)" label "Cuota" column-label "Cuota"
    field tta_val_abtdo_antecip_tit_abat   as decimal format "->>>,>>>,>>9.99" decimals 2 initial 0 label "Vl Rebaj" column-label "Vl Rebaj"
    index tt_id                            is primary unique
          ttv_rec_item_lote_impl_tit_acr   ascending
          tta_cod_estab                    ascending
          tta_cod_estab_ext                ascending
          tta_cod_espec_docto              ascending
          tta_cod_ser_docto                ascending
          tta_cod_tit_acr                  ascending
          tta_cod_parcela                  ascending.

define new shared temp-table tt_integr_acr_abat_prev no-undo
    field ttv_rec_item_lote_impl_tit_acr   as recid format ">>>>>>9"
    field tta_cod_estab                    as character format "x(3)" label "Sucursal" column-label "Suc"
    field tta_cod_estab_ext                as character format "x(8)" label "Sucursal Externa" column-label "Sucursal Ext"
    field tta_cod_espec_docto              as character format "x(3)" label "Clase Documento" column-label "Clase"
    field tta_cod_ser_docto                as character format "x(3)" label "Serie Documento" column-label "Serie"
    field tta_cod_tit_acr                  as character format "x(10)" label "T¡tulo" column-label "T¡tulo"
    field tta_cod_parcela                  as character format "x(02)" label "Cuota" column-label "Cuota"
    field tta_val_abtdo_prev_tit_abat      as decimal format "->>>,>>>,>>9.99" decimals 2 initial 0 label "Vl Reb" column-label "Vl Reb"
    field tta_log_zero_sdo_prev            as logical format "S¡/No" initial no label "Saldo Cero" column-label "Saldo Cero"
    index tt_id                            is primary unique
          ttv_rec_item_lote_impl_tit_acr   ascending
          tta_cod_estab                    ascending
          tta_cod_estab_ext                ascending
          tta_cod_espec_docto              ascending
          tta_cod_ser_docto                ascending
          tta_cod_tit_acr                  ascending
          tta_cod_parcela                  ascending.

define new shared temp-table tt_integr_acr_aprop_ctbl_pend no-undo
    field ttv_rec_item_lote_impl_tit_acr   as recid format ">>>>>>9"
    field tta_cod_plano_cta_ctbl           as character format "x(8)" label "Plan Cuentas" column-label "Plan Cuentas"
    field tta_cod_cta_ctbl                 as character format "x(20)" label "Cta Contable" column-label "Cta Contable"
    field tta_cod_cta_ctbl_ext             as character format "x(20)" label "Cta Contable Ext" column-label "Cta Contable Ext"
    field tta_cod_sub_cta_ctbl_ext         as character format "x(15)" label "Subcuenta Externa" column-label "Subcuenta Externa"
    field tta_cod_unid_negoc               as character format "x(3)" label "Unid Negocio" column-label "Un Neg"
    field tta_cod_unid_negoc_ext           as character format "x(8)" label "Unid Negocio Externa" column-label "Unid Negocio Externa"
    field tta_cod_plano_ccusto             as character format "x(8)" label "Plan Centros Costo" column-label "Plan Centros Costo"
    field tta_cod_ccusto                   as Character format "x(11)" label "Centro Costo" column-label "Centro Costo"
    field tta_cod_ccusto_ext               as character format "x(8)" label "Centro Costo Externo" column-label "CCosto Externo"
    field tta_cod_tip_fluxo_financ         as character format "x(12)" label "Tipo Flujo Financ" column-label "Tipo Flujo Financ"
    field tta_cod_fluxo_financ_ext         as character format "x(20)" label "Tipo Flujo Externo" column-label "Tipo Flujo Externo"
    field tta_val_aprop_ctbl               as decimal format "->>>,>>>,>>9.99" decimals 2 initial 0 label "Valor Aprop Ctbl" column-label "Vl Aprop Ctbl"
    field tta_cod_unid_federac             as character format "x(3)" label "Estado" column-label "ES"
    field tta_log_impto_val_agreg          as logical format "S¡/No" initial no label "Imp Val Agreg" column-label "Imp Vl Agr"
    field tta_cod_imposto                  as character format "x(5)" label "Imp" column-label "Imp"
    field tta_cod_classif_impto            as character format "x(05)" initial "00000" label "Clase Impuest" column-label "Clase Impuest"
    field tta_cod_pais                     as character format "x(3)" label "Pa¡s" column-label "Pa¡s"
    field tta_cod_pais_ext                 as character format "x(20)" label "Pa¡s Externo" column-label "Pa¡s Externo"
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
          tta_log_impto_val_agreg          ascending.

define new shared temp-table tt_integr_acr_aprop_desp_rec no-undo
    field ttv_rec_item_lote_impl_tit_acr   as recid format ">>>>>>9"
    field tta_cod_cta_ctbl_ext             as character format "x(20)" label "Cta Contable Ext" column-label "Cta Contable Ext"
    field tta_cod_sub_cta_ctbl_ext         as character format "x(15)" label "Subcuenta Externa" column-label "Subcuenta Externa"
    field tta_cod_unid_negoc_ext           as character format "x(8)" label "Unid Negocio Externa" column-label "Unid Negocio Externa"
    field tta_cod_fluxo_financ_ext         as character format "x(20)" label "Tipo Flujo Externo" column-label "Tipo Flujo Externo"
    field tta_val_perc_rat_ctbz            as decimal format ">>9.99" decimals 2 initial 0 label "Porc Prorrat" column-label "% Pr"
    field tta_cod_plano_cta_ctbl           as character format "x(8)" label "Plan Cuentas" column-label "Plan Cuentas"
    field tta_cod_cta_ctbl                 as character format "x(20)" label "Cta Contable" column-label "Cta Contable"
    field tta_cod_unid_negoc               as character format "x(3)" label "Unid Negocio" column-label "Un Neg"
    field tta_cod_tip_abat                 as character format "x(8)" label "Tipo de Rebaja" column-label "Tipo de Rebaja"
    field tta_cod_tip_fluxo_financ         as character format "x(12)" label "Tipo Flujo Financ" column-label "Tipo Flujo Financ"
    field tta_ind_tip_aprop_recta_despes   as character format "x(20)" label "Tipo Apropiaci¢n" column-label "Tipo Apropiaci¢n"
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
          tta_cod_tip_abat                 ascending.

define new shared temp-table tt_integr_acr_aprop_liq_antec no-undo
    field ttv_rec_item_lote_impl_tit_acr   as recid format ">>>>>>9"
    field ttv_rec_abat_antecip_acr         as recid format ">>>>>>9"
    field tta_cod_fluxo_financ_ext         as character format "x(20)" label "Tipo Flujo Externo" column-label "Tipo Flujo Externo"
    field ttv_cod_fluxo_financ_tit_ext     as character format "x(20)" label "Fujo Tit Ext" column-label "Fujo Tit Ext"
    field tta_cod_unid_negoc               as character format "x(3)" label "Unid Negocio" column-label "Un Neg"
    field tta_cod_tip_fluxo_financ         as character format "x(12)" label "Tipo Flujo Financ" column-label "Tipo Flujo Financ"
    field tta_cod_unid_negoc_tit           as character format "x(3)" label "Unid Negoc T¡tulo" column-label "Unid Negoc T¡tulo"
    field tta_cod_tip_fluxo_financ_tit     as character format "x(12)" label "Tp Flujo Financ T¡t" column-label "Tp Flujo Financ T¡t"
    field tta_val_abtdo_antecip            as decimal format "->>>,>>>,>>9.99" decimals 2 initial 0 label "Valor Rebajado" column-label "Vl Rebajado".

define new shared temp-table tt_integr_acr_aprop_relacto no-undo
    field ttv_rec_relacto_pend_tit_acr     as recid format ">>>>>>9" initial ? label "TK Relac Tit" column-label "TK Relac Tit"
    field tta_cod_cta_ctbl_ext             as character format "x(20)" label "Cta Contable Ext" column-label "Cta Contable Ext"
    field tta_cod_sub_cta_ctbl_ext         as character format "x(15)" label "Subcuenta Externa" column-label "Subcuenta Externa"
    field tta_cod_unid_negoc_ext           as character format "x(8)" label "Unid Negocio Externa" column-label "Unid Negocio Externa"
    field tta_cod_fluxo_financ_ext         as character format "x(20)" label "Tipo Flujo Externo" column-label "Tipo Flujo Externo"
    field tta_cod_plano_cta_ctbl           as character format "x(8)" label "Plan Cuentas" column-label "Plan Cuentas"
    field tta_cod_cta_ctbl                 as character format "x(20)" label "Cta Contable" column-label "Cta Contable"
    field tta_cod_unid_negoc               as character format "x(3)" label "Unid Negocio" column-label "Un Neg"
    field tta_cod_tip_fluxo_financ         as character format "x(12)" label "Tipo Flujo Financ" column-label "Tipo Flujo Financ"
    field tta_val_aprop_ctbl               as decimal format "->>>,>>>,>>9.99" decimals 2 initial 0 label "Valor Aprop Ctbl" column-label "Vl Aprop Ctbl"
    field tta_ind_tip_aprop_ctbl           as character format "x(30)" initial "Saldo" label "Tipo Aprop Ctbl" column-label "Tipo Aprop Ctbl".

define new shared temp-table tt_integr_acr_cheq no-undo
    field tta_cod_banco                    as character format "x(8)" label "Banco" column-label "Banco"
    field tta_cod_agenc_bcia               as character format "x(10)" label "Agencia Bancaria" column-label "Agencia Bancaria"
    field tta_cod_cta_corren               as character format "x(10)" label "Cta Corriente" column-label "Cta Corrient"
    field tta_num_cheque                   as integer format ">>>>,>>>,>>9" initial ? label "N§ Cheque" column-label "N§ Cheque"
    field tta_dat_emis_cheq                as date format "99/99/9999" initial ? label "Fch Emisi¢n" column-label "Fch Emis"
    field tta_dat_depos_cheq_acr           as date format "99/99/9999" initial ? label "Dep¢sito" column-label "Dep¢sito"
    field tta_dat_prev_depos_cheq_acr      as date format "99/99/9999" initial ? label "Previs Dep¢sito" column-label "Previs Dep¢sito"
    field tta_dat_desc_cheq_acr            as date format "99/99/9999" initial ? label "Fecha Descto" column-label "Fecha Descto"
    field tta_dat_prev_desc_cheq_acr       as date format "99/99/9999" initial ? label "Fch Prev Desc" column-label "Fch Prev Desc"
    field tta_val_cheque                   as decimal format ">>>,>>>,>>9.99" decimals 2 initial 0 label "Valor Cheque" column-label "Valor Cheque"
    field tta_nom_emit                     as character format "x(40)" label "Nombre Emitente" column-label "Nombre Emitente"
    field tta_nom_cidad_emit               as character format "x(30)" label "Ciudad Emitente" column-label "Ciudad Emitente"
    field tta_cod_estab                    as character format "x(3)" label "Sucursal" column-label "Suc"
    field tta_cod_estab_ext                as character format "x(8)" label "Sucursal Externa" column-label "Sucursal Ext"
    field tta_cod_id_feder                 as character format "x(20)" initial ? label "Id Federal" column-label "Id Federal"
    field tta_cod_motiv_devol_cheq         as character format "x(5)" label "Motivo Devoluci¢n" column-label "Motivo Devoluci¢n"
    field tta_cod_indic_econ               as character format "x(8)" label "Moneda" column-label "Moneda"
    field tta_cod_finalid_econ_ext         as character format "x(8)" label "Finalid Econ Externa" column-label "Finalidad Externa"
    field tta_cod_usuar_cheq_acr_terc      as character format "x(12)" label "Usuario" column-label "Usuario"
    field tta_log_pend_cheq_acr            as logical format "S¡/No" initial no label "Cheque Pendient" column-label "Cheque Pendient"
    field tta_log_cheq_terc                as logical format "S¡/No" initial no label "Cheque Tercero" column-label "Cheque Tercero"
    field tta_log_cheq_acr_renegoc         as logical format "S¡/No" initial no label "Cheque Reneg" column-label "Cheque Reneg"
    field tta_log_cheq_acr_devolv          as logical format "S¡/No" initial no label "Cheque Devuelto" column-label "Cheque Devuelto"
    field tta_num_pessoa                   as integer format ">>>,>>>,>>9" initial ? label "Persona" column-label "Persona"
    field tta_cod_pais                     as character format "x(3)" label "Pa¡s" column-label "Pa¡s"
    index tt_id                            is primary unique
          tta_cod_banco                    ascending
          tta_cod_agenc_bcia               ascending
          tta_cod_cta_corren               ascending
          tta_num_cheque                   ascending.

define new shared temp-table tt_integr_acr_impto_impl_pend no-undo
    field ttv_rec_item_lote_impl_tit_acr   as recid format ">>>>>>9"
    field tta_cod_pais                     as character format "x(3)" label "Pa¡s" column-label "Pa¡s"
    field tta_cod_pais_ext                 as character format "x(20)" label "Pa¡s Externo" column-label "Pa¡s Externo"
    field tta_cod_unid_federac             as character format "x(3)" label "Estado" column-label "ES"
    field tta_cod_imposto                  as character format "x(5)" label "Imp" column-label "Imp"
    field tta_cod_classif_impto            as character format "x(05)" initial "00000" label "Clase Impuest" column-label "Clase Impuest"
    field tta_num_seq                      as integer format ">>>,>>9" initial 0 label "Secuencia" column-label "N§ Sec"
    field tta_val_rendto_tribut            as decimal format ">,>>>,>>>,>>9.99" decimals 2 initial 0 label "Rendto Tributable" column-label "Vl Rendto Tribut"
    field tta_val_aliq_impto               as decimal format ">9.99" decimals 2 initial 0.00 label "Al¡cuota" column-label "Al¡c"
    field tta_val_imposto                  as decimal format ">,>>>,>>>,>>9.99" decimals 2 initial 0 label "Valor Impuesto" column-label "Vl Impuesto"
    field tta_cod_plano_cta_ctbl           as character format "x(8)" label "Plan Cuentas" column-label "Plan Cuentas"
    field tta_cod_cta_ctbl                 as character format "x(20)" label "Cta Contable" column-label "Cta Contable"
    field tta_cod_cta_ctbl_ext             as character format "x(20)" label "Cta Contable Ext" column-label "Cta Contable Ext"
    field tta_cod_sub_cta_ctbl_ext         as character format "x(15)" label "Subcuenta Externa" column-label "Subcuenta Externa"
    field tta_ind_clas_impto               as character format "X(14)" initial "Reten" label "Clase Impuesto" column-label "Clase Impuesto"
    field tta_cod_indic_econ               as character format "x(8)" label "Moneda" column-label "Moneda"
    field tta_cod_finalid_econ_ext         as character format "x(8)" label "Finalid Econ Externa" column-label "Finalidad Externa"
    field tta_val_cotac_indic_econ         as decimal format ">>>>,>>9.9999999999" decimals 10 initial 0 label "Cotiz" column-label "Cotiz"
    field tta_dat_cotac_indic_econ         as date format "99/99/9999" initial ? label "Fch Cotiz" column-label "Fch Cotiz"
    field tta_val_impto_indic_econ_impto   as decimal format "->>>,>>>,>>9.99" decimals 2 initial 0 label "Vl Finalid IMP" column-label "Vl Finalid IMP"
    index tt_id                            is primary unique
          ttv_rec_item_lote_impl_tit_acr   ascending
          tta_cod_pais                     ascending
          tta_cod_pais_ext                 ascending
          tta_cod_unid_federac             ascending
          tta_cod_imposto                  ascending
          tta_cod_classif_impto            ascending
          tta_num_seq                      ascending.

define new shared temp-table tt_integr_acr_item_lote_impl no-undo
    field ttv_rec_lote_impl_tit_acr        as recid format ">>>>>>9" initial ?
    field tta_num_seq_refer                as integer format ">>>9" initial 0 label "Secuencia" column-label "Sec"
    field tta_cdn_cliente                  as Integer format ">>>,>>>,>>9" initial 0 label "Cliente" column-label "Cliente"
    field tta_cod_espec_docto              as character format "x(3)" label "Clase Documento" column-label "Clase"
    field tta_cod_ser_docto                as character format "x(3)" label "Serie Documento" column-label "Serie"
    field tta_cod_tit_acr                  as character format "x(10)" label "T¡tulo" column-label "T¡tulo"
    field tta_cod_parcela                  as character format "x(02)" label "Cuota" column-label "Cuota"
    field tta_cod_indic_econ               as character format "x(8)" label "Moneda" column-label "Moneda"
    field tta_cod_finalid_econ_ext         as character format "x(8)" label "Finalid Econ Externa" column-label "Finalidad Externa"
    field tta_cod_portador                 as character format "x(5)" label "Portador" column-label "Portador"
    field tta_cod_portad_ext               as character format "x(8)" label "Portador Externo" column-label "Portador Externo"
    field tta_cod_cart_bcia                as character format "x(3)" label "Cartera" column-label "Cartera"
    field tta_cod_modalid_ext              as character format "x(8)" label "Modalidad Externa" column-label "Modalidad Externa"
    field tta_cod_cond_cobr                as character format "x(8)" label "Condici¢n Cobro" column-label "Cond Cobranza"
    field tta_cod_motiv_movto_tit_acr      as character format "x(8)" label "Motivo Movimiento" column-label "Motivo Movimiento"
    field tta_cod_histor_padr              as character format "x(8)" label "Hist¢rico Est nd" column-label "Hist¢rico Est nd"
    field tta_cdn_repres                   as Integer format ">>>,>>9" initial 0 label "Representante" column-label "Representante"
    field tta_dat_vencto_tit_acr           as date format "99/99/9999" initial ? label "Vencimiento" column-label "Vencimiento"
    field tta_dat_prev_liquidac            as date format "99/99/9999" initial ? label "Prev Liquidaci¢n" column-label "Prev Liquidaci¢n"
    field tta_dat_desconto                 as date format "99/99/9999" initial ? label "Fecha Descto" column-label "Fch Descto"
    field tta_dat_emis_docto               as date format "99/99/9999" initial today label "Fecha Emisi¢n" column-label "Fch Emisi¢n"
    field tta_val_tit_acr                  as decimal format ">>>,>>>,>>9.99" decimals 2 initial 0 label "Valor" column-label "Valor"
    field tta_val_desconto                 as decimal format "->>>,>>>,>>9.99" decimals 2 initial 0 label "Valor Descuento" column-label "Valor Descuento"
    field tta_val_perc_desc                as decimal format ">9.9999" decimals 4 initial 0 label "Porcentaje Descuento" column-label "% Descto"
    field tta_val_perc_juros_dia_atraso    as decimal format ">9.999999" decimals 6 initial 00.00 label "% Inter D¡a Atraso" column-label "% D¡a"
    field tta_val_perc_multa_atraso        as decimal format ">9.99" decimals 2 initial 00.00 label "% Multa Atraso" column-label "Multa Atr"
    field tta_val_base_calc_comis          as decimal format ">>>,>>>,>>9.99" decimals 2 initial 0 label "Base C lc Comis" column-label "Base C lc Comis"
    field tta_des_text_histor              as character format "x(2000)" label "Hist¢rico" column-label "Hist¢rico"
    field tta_qtd_dias_carenc_multa_acr    as decimal format ">>9" initial 0 label "D¡as Carencia Multa" column-label "D¡as Carencia Multa"
    field tta_cod_banco                    as character format "x(8)" label "Banco" column-label "Banco"
    field tta_cod_agenc_bcia               as character format "x(10)" label "Agencia Bancaria" column-label "Agencia Bancaria"
    field tta_cod_cta_corren_bco           as character format "x(20)" label "Cta Corriente Banco" column-label "Cta Corriente Banco"
    field tta_cod_digito_cta_corren        as character format "x(2)" label "D¡gito Cta Corriente" column-label "D¡gito Cta Corriente"
    field tta_cod_instruc_bcia_1_movto     as character format "x(4)" label "Instr Bancaria 1" column-label "Instr Banc 1"
    field tta_cod_instruc_bcia_2_movto     as character format "x(4)" label "Instr Bancaria 2" column-label "Instr Banc 2"
    field tta_qtd_dias_carenc_juros_acr    as decimal format ">>9" initial 0 label "D¡as Carencia Inter" column-label "D¡as Inter"
    field tta_val_liq_tit_acr              as decimal format ">>>,>>>,>>9.99" decimals 2 initial 0 label "Vl L¡quido" column-label "Vl L¡quido"
    field tta_ind_tip_espec_docto          as character format "X(17)" initial "Normal" label "Tipo Clase" column-label "Tipo Clase"
    field tta_cod_cond_pagto               as character format "x(8)" label "Condici¢n Pago" column-label "Condici¢n Pago"
    field ttv_cdn_agenc_fp                 as Integer format ">>>9" label "Agencia"
    field tta_ind_sit_tit_acr              as character format "X(13)" initial "Normal" label "Situaci¢n T¡tulo" column-label "Situaci¢n T¡tulo"
    field tta_log_liquidac_autom           as logical format "S¡/No" initial no label "Liquidaci¢n Autom tica" column-label "Liquidaci¢n Autom tica"
    field tta_num_id_tit_acr               as integer format "9999999999" initial 0 label "Token Cta Cobrar" column-label "Token Cta Cobrar"
    field tta_num_id_movto_tit_acr         as integer format "9999999999" initial 0 label "Token Movto T¡t CR" column-label "Token Movto T¡t CR"
    field tta_num_id_movto_cta_corren      as integer format "9999999999" initial 0 label "ID Movto Cta" column-label "ID Movto Cta"
    field tta_cod_admdra_cartao_cr         as character format "x(5)" label "Administradora" column-label "Administradora"
    field tta_cod_cartcred                 as character format "x(20)" label "C¢d Tarjeta" column-label "C¢d Tarjeta"
    field tta_cod_mes_ano_valid_cartao     as character format "XX/XXXX" label "Validez Tarjeta" column-label "Validez Tarjeta"
    field tta_cod_autoriz_cartao_cr        as character format "x(6)" label "C¢d Preautorizaci¢n" column-label "C¢d Preautorizaci¢n"
    field tta_dat_compra_cartao_cr         as date format "99/99/9999" initial ? label "Fcha Ejec Venta" column-label "Fcha Ejec Venta"
    field tta_cod_conces_telef             as character format "x(5)" label "Concesionaria" column-label "Concesionaria"
    field tta_num_ddd_localid_conces       as integer format "999" initial 0 label "DDD" column-label "DDD"
    field tta_num_prefix_localid_conces    as integer format ">>>9" initial 0 label "Prefijo" column-label "Prefijo"
    field tta_num_milhar_localid_conces    as integer format "9999" initial 0 label "Millar" column-label "Millar"
    field tta_log_tip_cr_perda_dedut_tit   as logical format "S¡/No" initial no label "Cr‚dito con Garant¡a" column-label "Cr‚d Garant"
    field tta_cod_refer                    as character format "x(10)" label "Referencia" column-label "Referencia"
    field tta_ind_ender_cobr               as character format "X(15)" initial "Cliente" label "Direcci¢n Cobranza" column-label "Direcci¢n Cobranza"
    field tta_nom_abrev_contat             as character format "x(15)" label "Abreviado Contact" column-label "Abreviado Contact"
    field tta_log_db_autom                 as logical format "S¡/No" initial no label "D‚bito Autom tico" column-label "D‚bito Autom tico"
    field tta_log_destinac_cobr            as logical format "S¡/No" initial no label "Destino Cobranza" column-label "Destino Cobranza"
    field tta_ind_sit_bcia_tit_acr         as character format "X(12)" initial "Liberado" label "Sit Bancaria" column-label "Sit Bancaria"
    field tta_cod_tit_acr_bco              as character format "x(20)" label "N§ T¡tulo Banco" column-label "N§ T¡tulo Banco"
    field tta_cod_agenc_cobr_bcia          as character format "x(10)" label "Agencia Cobranza" column-label "Agencia Cobr"
    field tta_dat_abat_tit_acr             as date format "99/99/9999" initial ? label "Reb" column-label "Reb"
    field tta_val_perc_abat_acr            as decimal format ">>9.9999" decimals 4 initial 0 label "% Rebaja" column-label "Rebaja"
    field tta_val_abat_tit_acr             as decimal format ">>>>,>>>,>>9.99" decimals 2 initial 0 label "Vl Rebaja" column-label "Vl Rebaja"
    field tta_des_obs_cobr                 as character format "x(40)" label "Obs Cobranza" column-label "Obs Cobranza"
    index tt_id                            is primary unique
          ttv_rec_lote_impl_tit_acr        ascending
          tta_num_seq_refer                ascending.

define new shared temp-table tt_integr_acr_lote_impl no-undo
    field tta_cod_empresa                  as character format "x(3)" label "Empresa" column-label "Empresa"
    field ttv_cod_empresa_ext              as character format "x(3)" label "C¢digo Empresa Ext" column-label "C¢d Emp Ext"
    field tta_cod_estab                    as character format "x(3)" label "Sucursal" column-label "Suc"
    field tta_cod_estab_ext                as character format "x(8)" label "Sucursal Externa" column-label "Sucursal Ext"
    field tta_cod_refer                    as character format "x(10)" label "Referencia" column-label "Referencia"
    field tta_cod_indic_econ               as character format "x(8)" label "Moneda" column-label "Moneda"
    field tta_cod_finalid_econ_ext         as character format "x(8)" label "Finalid Econ Externa" column-label "Finalidad Externa"
    field tta_cod_espec_docto              as character format "x(3)" label "Clase Documento" column-label "Clase"
    field tta_dat_transacao                as date format "99/99/9999" initial today label "Fecha Trans" column-label "Fch Trans"
    field tta_ind_tip_espec_docto          as character format "X(17)" initial "Normal" label "Tipo Clase" column-label "Tipo Clase"
    field tta_ind_orig_tit_acr             as character format "X(8)" initial "ACREMS50" label "Origen T¡t Cta Cob" column-label "Origen T¡t Cta Cob"
    field tta_val_tot_lote_impl_tit_acr    as decimal format ">>,>>>,>>>,>>9.99" decimals 2 initial 0 label "Total Movimiento" column-label "Total Movimiento"
    field tta_val_tot_lote_infor_tit_acr   as decimal format ">>,>>>,>>>,>>9.99" decimals 2 initial 0 label "Total Informado" column-label "Total Informado"
    field tta_ind_tip_cobr_acr             as character format "X(10)" initial "Normal" label "Tipo Cobro" column-label "Tipo Cobro"
    field ttv_log_lote_impl_ok             as logical format "S¡/No" initial no label "Lote Imp. OK" column-label "Lote Imp. OK"
    field tta_log_liquidac_autom           as logical format "S¡/No" initial no label "Liquidaci¢n Autom tica" column-label "Liquidaci¢n Autom tica"
    index tt_id                            is primary unique
          tta_cod_estab                    ascending
          tta_cod_estab_ext                ascending
          tta_cod_refer                    ascending.

define new shared temp-table tt_integr_acr_ped_vda_pend no-undo
    field ttv_rec_item_lote_impl_tit_acr   as recid format ">>>>>>9"
    field tta_cod_ped_vda                  as character format "x(12)" label "Pedido Venta" column-label "Pedido Venta"
    field tta_cod_ped_vda_repres           as character format "x(12)" label "Pedido Rep" column-label "Pedido Rep"
    field tta_val_perc_particip_ped_vda    as decimal format ">>9.99" decimals 2 initial 0 label "Particip Ped Vta" column-label "Particip"
    field tta_val_origin_ped_vda           as decimal format "->>,>>>,>>>,>>9.99" decimals 2 initial 0 label "Original Ped Venta" column-label "Original Ped Venta"
    field tta_val_sdo_ped_vda              as decimal format "->>,>>>,>>>,>>9.99" decimals 2 initial 0 label "Saldo Pedido Venta" column-label "Saldo Pedido Venta"
    field tta_des_ped_vda                  as character format "x(40)" label "Pedido Venta" column-label "Pedido Venta"
    index tt_id                            is primary unique
          ttv_rec_item_lote_impl_tit_acr   ascending
          tta_cod_ped_vda                  ascending.

define new shared temp-table tt_integr_acr_relacto_pend no-undo
    field ttv_rec_item_lote_impl_tit_acr   as recid format ">>>>>>9"
    field tta_cod_estab_tit_acr_pai        as character format "x(3)" label "Suc T¡t Est" column-label "Suc T¡t Est"
    field ttv_cod_estab_tit_acr_pai_ext    as character format "x(3)" label "Suc T¡t Est" column-label "Suc T¡t Est"
    field tta_num_id_tit_acr_pai           as integer format "9999999999" initial 0 label "Token" column-label "Token"
    field tta_cod_espec_docto              as character format "x(3)" label "Clase Documento" column-label "Clase"
    field tta_cod_ser_docto                as character format "x(3)" label "Serie Documento" column-label "Serie"
    field tta_cod_tit_acr                  as character format "x(10)" label "T¡tulo" column-label "T¡tulo"
    field tta_cod_parcela                  as character format "x(02)" label "Cuota" column-label "Cuota"
    field tta_val_relacto_tit_acr          as decimal format "->>>,>>>,>>9.99" decimals 2 initial 0 label "Vl Rel" column-label "Vl Rel"
    field tta_log_gera_alter_val           as logical format "S¡/No" initial no label "Gen Alter Valor" column-label "Gen Alter Valor"
    field tta_ind_motiv_acerto_val         as character format "X(12)" initial "Altera" label "Motivo Ajuste Valor" column-label "Motivo Ajuste Valor".

define new shared temp-table tt_integr_acr_relacto_pend_cheq no-undo
    field ttv_rec_item_lote_impl_tit_acr   as recid format ">>>>>>9"
    field tta_cod_banco                    as character format "x(8)" label "Banco" column-label "Banco"
    field tta_cod_agenc_bcia               as character format "x(10)" label "Agencia Bancaria" column-label "Agencia Bancaria"
    field tta_cod_cta_corren               as character format "x(10)" label "Cta Corriente" column-label "Cta Corrient"
    field tta_num_cheque                   as integer format ">>>>,>>>,>>9" initial ? label "N§ Cheque" column-label "N§ Cheque"
    field tta_val_vincul_cheq_acr          as decimal format ">>>,>>>,>>9.99" decimals 2 initial 0 label "Valor Vinculado" column-label "Valor Vinculado"
    field tta_cdn_bco_cheq_salario         as Integer format ">>9" initial 0 label "Banco Cheque Salario" column-label "Banco Cheque Salario"
    index tt_id                            is primary unique
          ttv_rec_item_lote_impl_tit_acr   ascending
          tta_cod_banco                    ascending
          tta_cod_agenc_bcia               ascending
          tta_cod_cta_corren               ascending
          tta_num_cheque                   ascending.

define new shared temp-table tt_integr_acr_repres_pend no-undo
    field ttv_rec_item_lote_impl_tit_acr   as recid format ">>>>>>9"
    field tta_cdn_repres                   as Integer format ">>>,>>9" initial 0 label "Representante" column-label "Representante"
    field tta_val_perc_comis_repres        as decimal format ">>9.99" decimals 2 initial 0 label "% Comisi¢n" column-label "% Comisi¢n"
    field tta_val_perc_comis_repres_emis   as decimal format ">>9.99" decimals 2 initial 0 label "% Comis Emisi¢n" column-label "% Comis Emisi¢n"
    field tta_val_perc_comis_abat          as decimal format ">>9.99" decimals 2 initial 0 label "% Comisi¢n Rebaja" column-label "% Comisi¢n Rebaja"
    field tta_val_perc_comis_desc          as decimal format ">>9.99" decimals 2 initial 0 label "% Comisi¢n Desct" column-label "% Comisi¢n Desct"
    field tta_val_perc_comis_juros         as decimal format ">>9.99" decimals 2 initial 0 label "% Comis Inter" column-label "% Comis Inter"
    field tta_val_perc_comis_multa         as decimal format ">>9.99" decimals 2 initial 0 label "% Comis Multa" column-label "% Comis Multa"
    field tta_val_perc_comis_acerto_val    as decimal format ">>9.99" decimals 2 initial 0 label "% Comis AVA" column-label "% Comis AVA"
    field tta_log_comis_repres_proporc     as logical format "S¡/No" initial no label "Comis Proporcional" column-label "Comis Propor"
    field tta_ind_tip_comis                as character format "X(15)" initial "Valor Bruto" label "Tipo Comisi¢n" column-label "Tipo Comisi¢n"
    index tt_id                            is primary unique
          ttv_rec_item_lote_impl_tit_acr   ascending
          tta_cdn_repres                   ascending.

define new shared temp-table tt_log_erros_atualiz no-undo
    field tta_cod_estab                    as character format "x(3)" label "Sucursal" column-label "Suc"
    field tta_cod_refer                    as character format "x(10)" label "Referencia" column-label "Referencia"
    field tta_num_seq_refer                as integer format ">>>9" initial 0 label "Secuencia" column-label "Sec"
    field ttv_num_mensagem                 as integer format ">>>>,>>9" label "N£mero" column-label "N£mero Mensaje"
    field ttv_des_msg_erro                 as character format "x(60)" label "Mensaje Error" column-label "Inconsistencia"
    field ttv_des_msg_ajuda                as character format "x(40)" label "Mensaje Ayuda" column-label "Mensaje Ayuda"
    field ttv_ind_tip_relacto              as character format "X(15)" label "Tipo Relaci¢n" column-label "Tipo Rel"
    field ttv_num_relacto                  as integer format ">>>>,>>9" label "Relaci¢n" column-label "Relaci¢n".

define new shared temp-table tt_lote_impl_tit_cheq_acr no-undo
    field tta_cod_estab                    as character format "x(3)" label "Sucursal" column-label "Suc"
    field tta_cod_refer                    as character format "x(10)" label "Referencia" column-label "Referencia"
    field ttv_rec_lote_impl_tit_acr        as recid format ">>>>>>9" initial ?
    field ttv_log_erro                     as logical format "S¡/No" initial yes
    index tt_cod_estab                     is primary unique
          tta_cod_estab                    ascending
    index tt_log_erro                     
          ttv_log_erro                     ascending.

