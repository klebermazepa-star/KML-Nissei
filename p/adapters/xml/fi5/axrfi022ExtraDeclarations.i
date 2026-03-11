def new shared stream s_1.

def temp-table tt_movto_cta_corren_import no-undo
    field tta_cod_cta_corren               as character format "x(10)" label "Conta Corrente" column-label "Cta Corrente"
    field tta_dat_movto_cta_corren         as date format "99/99/9999" initial today label "Data Movimento" column-label "Data Movimento"
    field tta_num_seq_movto_cta_corren     as integer format ">>>>9" initial 0 label "Sequˆncia" column-label "Sequˆncia"
    field tta_ind_tip_movto_cta_corren     as character format "X(2)" initial "RE" label "Tipo Movimento" column-label "Tipo Movto"
    field tta_cod_tip_trans_cx             as character format "x(8)" label "Tipo Transa‡Æo Caixa" column-label "Tipo Transa‡Æo Caixa"
    field tta_ind_fluxo_movto_cta_corren   as character format "X(3)" initial "ENT" label "Fluxo Movimento" column-label "Fluxo Movto"
    field tta_cod_cenar_ctbl               as character format "x(8)" label "Cen rio Cont bil" column-label "Cen rio Cont bil"
    field tta_cod_histor_padr              as character format "x(8)" label "Hist¢rico PadrÆo" column-label "Hist¢rico PadrÆo"
    field tta_val_movto_cta_corren         as decimal format ">>>>,>>>,>>9.99" decimals 2 initial 0 label "Valor Movimento" column-label "Valor Movimento"
    field tta_cod_docto_movto_cta_bco      as character format "x(20)" label "Documento Banco" column-label "Documento Banco"
    field tta_cod_modul_dtsul              as character format "x(3)" label "M¢dulo" column-label "M¢dulo"
    field ttv_ind_erro_valid               as character format "X(08)" initial "NÆo"
    field tta_des_histor_padr              as character format "x(40)" label "Descri‡Æo" column-label "Descri‡Æo Hist¢rico PadrÆo"
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

def temp-table tt_aprop_ctbl_cmg_imp no-undo
    field tta_num_id_movto_cta_corren      as integer format "9999999999" initial 0 label "ID Movto Conta" column-label "ID Movto Conta"
    field tta_num_seq_aprop_ctbl_cmg       as integer format ">>9" initial 0 label "Sequˆncia" column-label "Seq Aprop"
    field tta_ind_finalid_aprop_ctbl_cmg   as character format "X(2)" initial "PR" label "Finalidade" column-label "Finalidade"
    field tta_ind_natur_lancto_ctbl        as character format "X(02)" initial "DB" label "Natureza" column-label "Natureza"
    field tta_ind_orig_aprop_ctbl_cmg      as character format "X(3)" label "Origem Apropria‡Æo" column-label "Origem Aprop"
    field tta_cod_empresa                  as character format "x(3)" label "Empresa" column-label "Empresa"
    field tta_cod_estab                    as character format "x(3)" label "Estabelecimento" column-label "Estab"
    field tta_cod_cenar_ctbl               as character format "x(8)" label "Cen rio Cont bil" column-label "Cen rio Cont bil"
    field tta_cod_plano_cta_ctbl           as character format "x(8)" label "Plano Contas" column-label "Plano Contas"
    field tta_cod_cta_ctbl                 as character format "x(20)" label "Conta Cont bil" column-label "Conta Cont bil"
    field tta_cod_unid_negoc               as character format "x(3)" label "Unid Neg¢cio" column-label "Un Neg"
    field tta_cod_plano_ccusto             as character format "x(8)" label "Plano Centros Custo" column-label "Plano Centros Custo"
    field tta_cod_ccusto                   as Character format "x(11)" label "Centro Custo" column-label "Centro Custo"
    field tta_cod_cta_corren               as character format "x(10)" label "Conta Corrente" column-label "Cta Corrente"
    field tta_cod_indic_econ               as character format "x(8)" label "Moeda" column-label "Moeda"
    field tta_val_movto_cta_corren         as decimal format ">>>>,>>>,>>9.99" decimals 2 initial 0 label "Valor Movimento" column-label "Valor Movimento"
    field tta_log_ctbz_movto_cta_corren    as logical format "Sim/NÆo" initial no label "Contabilizado" column-label "Contabilizado"
    field tta_log_mutuo_pagto              as logical format "Sim/NÆo" initial no label "M£tuo Pagamento" column-label "M£tuo Pagamento"
    field tta_dat_transacao                as date format "99/99/9999" initial today label "Data Transa‡Æo" column-label "Dat Transac"
    field ttv_rec_movto_cta_corren         as recid format ">>>>>>9" initial ?
    field ttv_rec_aprop_ctbl_cmg           as recid format ">>>>>>9" initial ?
    index tt_id                            is primary
          ttv_rec_movto_cta_corren         ascending
    index tt_id_aprop                     
          ttv_rec_aprop_ctbl_cmg           ascending
    .

def temp-table tt_val_aprop_ctbl_cmg_import no-undo
    field tta_cod_finalid_econ             as character format "x(10)" label "Finalidade" column-label "Finalidade"
    field tta_dat_cotac_indic_econ         as date format "99/99/9999" initial ? label "Data Cota‡Æo" column-label "Data Cota‡Æo"
    field tta_val_cotac_indic_econ         as decimal format ">>>>,>>9.9999999999" decimals 10 initial 0 label "Cota‡Æo" column-label "Cota‡Æo"
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
    field tta_cod_unid_negoc               as character format "x(3)" label "Unid Neg¢cio" column-label "Un Neg"
    field tta_cod_tip_fluxo_financ         as character format "x(12)" label "Tipo Fluxo Financ" column-label "Tipo Fluxo Financ"
    field tta_val_movto_cta_corren         as decimal format ">>>>,>>>,>>9.99" decimals 2 initial 0 label "Valor Movimento" column-label "Valor Movimento"
    index tt_codigo                        is primary
          ttv_rec_movto_cta_corren         ascending.

def temp-table tt_import_movto_valid_cmg no-undo
    field ttv_rec_movto_cta_corren         as recid format ">>>>>>9" initial ?
    field ttv_num_mensagem                 as integer format ">>>>,>>9" label "Número" column-label "Número Mensagem"
    field ttv_des_mensagem                 as character format "x(50)" label "Mensagem" column-label "Mensagem"
    field ttv_des_msg_erro                 as character format "x(60)" label "Mensagem Erro" column-label "Inconsistência"
    field ttv_cod_parameters               as character format "x(256)".

