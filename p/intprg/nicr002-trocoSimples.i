
def temp-table tt_aprop_ctbl_cmg_imp no-undo
    field tta_num_id_movto_cta_corren      as integer format "9999999999" initial 0 label "ID Movto Conta" column-label "ID Movto Conta"
    field tta_num_seq_aprop_ctbl_cmg       as integer format ">>9" initial 0 label "Sequ¼ncia" column-label "Seq Aprop"
    field tta_ind_finalid_aprop_ctbl_cmg   as character format "X(2)" initial "PR" label "Finalidade" column-label "Finalidade"
    field tta_ind_natur_lancto_ctbl        as character format "X(02)" initial "DB" label "Natureza" column-label "Natureza"
    field tta_ind_orig_aprop_ctbl_cmg      as character format "X(3)" label "Origem Apropria»’o" column-label "Origem Aprop"
    field tta_cod_empresa                  as character format "x(3)" label "Empresa" column-label "Empresa"
    field tta_cod_estab                    as character format "x(3)" label "Estabelecimento" column-label "Estab"
    field tta_cod_cenar_ctbl               as character format "x(8)" label "Cenÿrio Contÿbil" column-label "Cenÿrio Contÿbil"
    field tta_cod_plano_cta_ctbl           as character format "x(8)" label "Plano Contas" column-label "Plano Contas"
    field tta_cod_cta_ctbl                 as character format "x(20)" label "Conta Contÿbil" column-label "Conta Contÿbil"
    field tta_cod_unid_negoc               as character format "x(3)" label "Unid Neg½cio" column-label "Un Neg"
    field tta_cod_plano_ccusto             as character format "x(8)" label "Plano Centros Custo" column-label "Plano Centros Custo"
    field tta_cod_ccusto                   as Character format "x(11)" label "Centro Custo" column-label "Centro Custo"
    field tta_cod_cta_corren               as character format "x(10)" label "Conta Corrente" column-label "Cta Corrente"
    field tta_cod_indic_econ               as character format "x(8)" label "Moeda" column-label "Moeda"
    field tta_val_movto_cta_corren         as decimal format ">>>>,>>>,>>9.99" decimals 2 initial 0 label "Valor Movimento" column-label "Valor Movimento"
    field tta_log_ctbz_movto_cta_corren    as logical format "Sim/N’o" initial no label "Contabilizado" column-label "Contabilizado"
    field tta_log_mutuo_pagto              as logical format "Sim/N’o" initial no label "Mœtuo Pagamento" column-label "Mœtuo Pagamento"
    field tta_dat_transacao                as date format "99/99/9999" initial today label "Data Transa»’o" column-label "Dat Transac"
    field ttv_rec_movto_cta_corren         as recid format ">>>>>>9" initial ?
    field ttv_rec_aprop_ctbl_cmg           as recid format ">>>>>>9" initial ?
    index tt_id                            is primary
          ttv_rec_movto_cta_corren         ascending
    index tt_id_aprop                     
          ttv_rec_aprop_ctbl_cmg           ascending
    .


def temp-table tt_movto_cta_corren_import no-undo
    field tta_cod_cta_corren               as character format "x(10)" label "Conta Corrente" column-label "Cta Corrente"
    field tta_dat_movto_cta_corren         as date format "99/99/9999" initial today label "Data Movimento" column-label "Data Movimento"
    field tta_num_seq_movto_cta_corren     as integer format ">>>>9" initial 0 label "Sequ¼ncia" column-label "Sequ¼ncia"
    field tta_ind_tip_movto_cta_corren     as character format "X(2)" initial "RE" label "Tipo Movimento" column-label "Tipo Movto"
    field tta_cod_tip_trans_cx             as character format "x(8)" label "Tipo Transa»’o Caixa" column-label "Tipo Transa»’o Caixa"
    field tta_ind_fluxo_movto_cta_corren   as character format "X(3)" initial "ENT" label "Fluxo Movimento" column-label "Fluxo Movto"
    field tta_cod_cenar_ctbl               as character format "x(8)" label "Cenÿrio Contÿbil" column-label "Cenÿrio Contÿbil"
    field tta_cod_histor_padr              as character format "x(8)" label "Hist½rico Padr’o" column-label "Hist½rico Padr’o"
    field tta_val_movto_cta_corren         as decimal format ">>>>,>>>,>>9.99" decimals 2 initial 0 label "Valor Movimento" column-label "Valor Movimento"
    field tta_cod_docto_movto_cta_bco      as character format "x(20)" label "Documento Banco" column-label "Documento Banco"
    field tta_cod_modul_dtsul              as character format "x(3)" label "M½dulo" column-label "M½dulo"
    field ttv_ind_erro_valid               as character format "X(08)" initial "N’o"
    field tta_des_histor_padr              as character format "x(40)" label "Descri»’o" column-label "Descri»’o Hist½rico Padr’o"
    field tta_num_id_movto_cta_corren      as integer format "9999999999" initial 0 label "ID Movto Conta" column-label "ID Movto Conta"
    field ttv_rec_movto_cta_corren         as recid format ">>>>>>9" initial ?
    index tt_erro                         
          ttv_ind_erro_valid               ascending
    index tt_import_movto_cta_corren       is primary unique
          tta_cod_cta_corren               ascending
          tta_dat_movto_cta_corren         ascending
          tta_num_seq_movto_cta_corren     ascending
    index tt_rec_movto                    
          ttv_rec_movto_cta_corren         ascending.

def temp-table tt_val_aprop_ctbl_cmg_import no-undo
    field tta_cod_finalid_econ             as character format "x(10)" label "Finalidade" column-label "Finalidade"
    field tta_dat_cotac_indic_econ         as date format "99/99/9999" initial ? label "Data Cota»’o" column-label "Data Cota»’o"
    field tta_val_cotac_indic_econ         as decimal format ">>>>,>>9.9999999999" decimals 10 initial 0 label "Cota»’o" column-label "Cota»’o"
    field tta_val_movto_cta_corren         as decimal format ">>>>,>>>,>>9.99" decimals 2 initial 0 label "Valor Movimento" column-label "Valor Movimento"
    field ttv_rec_movto_cta_corren         as recid format ">>>>>>9" initial ?
    field ttv_rec_aprop_ctbl_cmg           as recid format ">>>>>>9" initial ?
    field ttv_rec_val_aprop_ctbl_cmg       as recid format ">>>>>>9" initial ?
    index tt_finalid                      
          ttv_rec_movto_cta_corren         ascending
          tta_cod_finalid_econ             ascending
    index tt_id                            is primary
          ttv_rec_movto_cta_corren         ascending
          ttv_rec_aprop_ctbl_cmg           ascending
          ttv_rec_val_aprop_ctbl_cmg       ascending
    .

def temp-table tt_rat_financ_cmg_import no-undo
    field ttv_rec_movto_cta_corren         as recid format ">>>>>>9" initial ?
    field tta_cod_estab                    as character format "x(3)" label "Estabelecimento" column-label "Estab"
    field tta_cod_unid_negoc               as character format "x(3)" label "Unid Neg½cio" column-label "Un Neg"
    field tta_cod_tip_fluxo_financ         as character format "x(12)" label "Tipo Fluxo Financ" column-label "Tipo Fluxo Financ"
    field tta_val_movto_cta_corren         as decimal format ">>>>,>>>,>>9.99" decimals 2 initial 0 label "Valor Movimento" column-label "Valor Movimento"
    index tt_codigo                        is primary
          ttv_rec_movto_cta_corren         ascending.


def temp-table tt_import_movto_valid_cmg no-undo
    field ttv_rec_movto_cta_corren         as recid format ">>>>>>9" initial ?
    field ttv_num_mensagem                 as integer format ">>>>,>>9" label "N£mero" column-label "N£mero Mensagem"
    field ttv_des_mensagem                 as character format "x(50)" label "Mensagem" column-label "Mensagem"
    field ttv_des_msg_erro                 as character format "x(60)" label "Mensagem Erro" column-label "Inconsistˆncia"
    field ttv_cod_parameters               as character format "x(256)"
    .

def temp-table tt_val_aprop_cmg_cambial no-undo
    field ttv_rec_val_aprop_ctbl_cmg       as recid format ">>>>>>9" initial ?
    field ttv_rec_val_aprop_cmg_cambial    as recid format ">>>>>>9"
    field tta_cod_finalid_econ             as character format "x(10)" label "Finalidade"
    field tta_dat_inic_calc                as date format "99/99/9999" label "In¡cio C lculo"
    field tta_dat_fim_calc                 as date format "99/99/9999" label "Data Fim C lculo"
    field tta_dat_cotac_sdo_inic           as date format "99/99/9999" label "Dt Cotac Sdo Inicial"
    field tta_dat_cotac_sdo_fim            as date format "99/99/9999" label "Dt Cota‡Æo Saldo Fim"
    field tta_val_cotac_sdo_inic           as decimal format ">>>>,>>9.9999999999" decimals 10 label "Vl Cotac Sdo Inicial"
    field tta_val_cotac_sdo_fim            as decimal format ">>>>,>>9.9999999999" decimals 10 label "Vl Cotac Sdo Final"
    field tta_val_sdo_inic_orig            as decimal format "->>>,>>>>,>>>,>>9.9999999999" decimals 10 label "Sdo Inicial Original"
    field tta_val_sdo_fim_orig             as decimal format "->>>,>>>>,>>>,>>9.9999999999" decimals 10 label "Sdo Final Original"
    field tta_val_sdo_inic_conver          as decimal format "->>>,>>>>,>>>,>>9.9999999999" decimals 10 label "Sdo Ini Convertido"
    field tta_val_sdo_fim_conver           as decimal format "->>>,>>>>,>>>,>>9.9999999999" decimals 10 label "Sdo Fim Convertido"
    field tta_val_movto_finalid_econ       as decimal format "->>>,>>>>,>>>,>>9.9999999999" decimals 10 label "Val Movto Finalidade"
    field tta_val_sdo_fim_calc             as decimal format "->>>,>>>>,>>>,>>9.9999999999" decimals 10 label "Saldo Fim Calculado"
    field tta_dat_inic_period_ctbl         as date format "99/99/9999" label "In¡cio Per¡odo"
    field tta_dat_fim_period_ctbl          as date format "99/99/9999" label "Fim Per¡odo"
    index tt_val_aprop_ctbl_cmg           
          ttv_rec_val_aprop_ctbl_cmg       ascending.


def var v_hdl_program as Handle format ">>>>>>9":U no-undo.
def new shared stream s_1.
