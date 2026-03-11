/****************************************************************************
**
**    Programa: int001.p - Atualizar Movimentos de Caixa e bancos 
**                         Sysfarma/PRS X Datasul 
**  Tabela Int: int_ds_fundo_fixo
*****************************************************************************/

/********************* Temporary Table Definition Begin *********************/

{intprg/int-rpw.i} /* Se for rodar manual deixar em coment†rio  */

DEFINE BUFFER bf-int_ds_fundo_fixo FOR int_ds_fundo_fixo.
DEFINE BUFFER bf-int_dp_fundo_fixo FOR int_dp_fundo_fixo.

DEF NEW GLOBAL SHARED VAR c-seg-usuario        LIKE usuar_mestre.cod_usuario NO-UNDO.
DEF NEW GLOBAL SHARED VAR i-ep-codigo-usuario  LIKE ems2mult.empresa.ep-codigo  NO-UNDO.


def temp-table tt_aprop_ctbl_cmg_imp no-undo
    field tta_num_id_movto_cta_corren      as integer format "9999999999" initial 0 label "ID Movto Conta" column-label "ID Movto Conta"
    field tta_num_seq_aprop_ctbl_cmg       as integer format ">>9" initial 0 label "Sequància" column-label "Seq Aprop"
    field tta_ind_finalid_aprop_ctbl_cmg   as character format "X(2)" initial "PR" label "Finalidade" column-label "Finalidade"
    field tta_ind_natur_lancto_ctbl        as character format "X(02)" initial "DB" label "Natureza" column-label "Natureza"
    field tta_ind_orig_aprop_ctbl_cmg      as character format "X(3)" label "Origem Apropriaá∆o" column-label "Origem Aprop"
    field tta_cod_empresa                  as character format "x(3)" label "Empresa" column-label "Empresa"
    field tta_cod_estab                    as character format "x(3)" label "Estabelecimento" column-label "Estab"
    field tta_cod_cenar_ctbl               as character format "x(8)" label "Cen†rio Cont†bil" column-label "Cen†rio Cont†bil"
    field tta_cod_plano_cta_ctbl           as character format "x(8)" label "Plano Contas" column-label "Plano Contas"
    field tta_cod_cta_ctbl                 as character format "x(20)" label "Conta Cont†bil" column-label "Conta Cont†bil"
    field tta_cod_unid_negoc               as character format "x(3)" label "Unid Neg¢cio" column-label "Un Neg"
    field tta_cod_plano_ccusto             as character format "x(8)" label "Plano Centros Custo" column-label "Plano Centros Custo"
    field tta_cod_ccusto                   as Character format "x(11)" label "Centro Custo" column-label "Centro Custo"
    field tta_cod_cta_corren               as character format "x(10)" label "Conta Corrente" column-label "Cta Corrente"
    field tta_cod_indic_econ               as character format "x(8)" label "Moeda" column-label "Moeda"
    field tta_val_movto_cta_corren         as decimal format ">>>>,>>>,>>9.99" decimals 2 initial 0 label "Valor Movimento" column-label "Valor Movimento"
    field tta_log_ctbz_movto_cta_corren    as logical format "Sim/N∆o" initial no label "Contabilizado" column-label "Contabilizado"
    field tta_log_mutuo_pagto              as logical format "Sim/N∆o" initial no label "M£tuo Pagamento" column-label "M£tuo Pagamento"
    field tta_dat_transacao                as date format "99/99/9999" initial today label "Data Transaá∆o" column-label "Dat Transac"
    field ttv_rec_movto_cta_corren         as recid format ">>>>>>9" initial ?
    field ttv_rec_aprop_ctbl_cmg           as recid format ">>>>>>9" initial ?
    index tt_id                            is primary
          ttv_rec_movto_cta_corren         ascending
    index tt_id_aprop                     
          ttv_rec_aprop_ctbl_cmg           ascending
    .

def new global shared temp-table tt_histor_finalid_econ_decimais no-undo
    field tta_cod_indic_econ               as character format "x(8)" label "Moeda" column-label "Moeda"
    field tta_cod_finalid_econ             as character format "x(10)" label "Finalidade" column-label "Finalidade"
    field tta_dat_inic_valid_finalid       as date format "99/99/9999" initial &IF "{&ems_dbtype}":U = "MSS":U &THEN 01/01/1800 &ELSE 01/01/0001 &ENDIF label "In°cio Validade" column-label "Inic Valid"
    field tta_dat_fim_valid_finalid        as date format "99/99/9999" initial 12/31/9999 label "Fim Validade" column-label "Fim Validade"
    field tta_num_casas_arredond           as integer format ">>9" initial 0 label "Casas Decimais" column-label "Casas Arred"
    field tta_ind_tratam_valores_infor     as character format "X(09)" initial "Arredonda" label "Valores Informados" column-label "Valores Informados"
    field tta_ind_tip_arredond             as character format "X(10)" initial "Arredonda" label "Arredondamento" column-label "Arredonda"
    .

def new shared temp-table tt_import_movto_cta_corren no-undo
    field tta_cod_cta_corren               as character format "x(10)" label "Conta Corrente" column-label "Cta Corrente"
    field tta_dat_movto_cta_corren         as date format "99/99/9999" initial today label "Data Movimento" column-label "Data Movimento"
    field tta_num_seq_movto_cta_corren     as integer format ">>>>9" initial 0 label "Sequància" column-label "Sequància"
    field tta_ind_tip_movto_cta_corren     as character format "X(2)" initial "RE" label "Tipo Movimento" column-label "Tipo Movto"
    field tta_cod_tip_trans_cx             as character format "x(8)" label "Tipo Transaá∆o Caixa" column-label "Tipo Transaá∆o Caixa"
    field tta_ind_fluxo_movto_cta_corren   as character format "X(3)" initial "ENT" label "Fluxo Movimento" column-label "Fluxo Movto"
    field tta_cod_cenar_ctbl               as character format "x(8)" label "Cen†rio Cont†bil" column-label "Cen†rio Cont†bil"
    field tta_cod_histor_padr              as character format "x(8)" label "Hist¢rico Padr∆o" column-label "Hist¢rico Padr∆o"
    field tta_val_movto_cta_corren         as decimal format ">>>>,>>>,>>9.99" decimals 2 initial 0 label "Valor Movimento" column-label "Valor Movimento"
    field tta_cod_docto_movto_cta_bco      as character format "x(20)" label "Documento Banco" column-label "Documento Banco"
    field tta_cod_modul_dtsul              as character format "x(3)" label "M¢dulo" column-label "M¢dulo"
    field ttv_ind_erro_valid               as character format "X(08)" initial "N∆o"
    field tta_des_histor_padr              as character format "x(40)" label "Descriá∆o" column-label "Descriá∆o Hist¢rico Padr∆o"
    field tta_ind_natur_lancto_ctbl        as character format "X(02)" initial "DB" label "Natureza" column-label "Natureza"
    field tta_cod_plano_cta_ctbl           as character format "x(8)" label "Plano Contas" column-label "Plano Contas"
    field tta_cod_cta_ctbl                 as character format "x(20)" label "Conta Cont†bil" column-label "Conta Cont†bil"
    field tta_cod_unid_negoc               as character format "x(3)" label "Unid Neg¢cio" column-label "Un Neg"
    field tta_cod_plano_ccusto             as character format "x(8)" label "Plano Centros Custo" column-label "Plano Centros Custo"
    field tta_cod_ccusto                   as Character format "x(11)" label "Centro Custo" column-label "Centro Custo"
    field ttv_val_aprop                    as decimal format "->>,>>>,>>>,>>9.99" decimals 2
    index tt_import_movto_cta_corren       is primary unique
          tta_cod_cta_corren               ascending
          tta_dat_movto_cta_corren         ascending
          tta_num_seq_movto_cta_corren     ascending
    .

def new shared temp-table tt_import_movto_valid no-undo
    field ttv_rec_movto_cta_corren         as recid format ">>>>>>9" initial ?
    field ttv_num_mensagem                 as integer format ">>>>,>>9" label "N£mero" column-label "N£mero Mensagem"
    field ttv_cod_parameters               as character format "x(256)"
    .

def temp-table tt_import_movto_valid_cmg no-undo
    field ttv_rec_movto_cta_corren         as recid format ">>>>>>9" initial ?
    field ttv_num_mensagem                 as integer format ">>>>,>>9" label "N£mero" column-label "N£mero Mensagem"
    field ttv_des_mensagem                 as character format "x(50)" label "Mensagem" column-label "Mensagem"
    field ttv_des_msg_erro                 as character format "x(60)" label "Mensagem Erro" column-label "Inconsistància"
    field ttv_cod_parameters               as character format "x(256)"
    .

def temp-table tt_movto_cta_corren_import no-undo
    field tta_cod_cta_corren               as character format "x(10)" label "Conta Corrente" column-label "Cta Corrente"
    field tta_dat_movto_cta_corren         as date format "99/99/9999" initial today label "Data Movimento" column-label "Data Movimento"
    field tta_num_seq_movto_cta_corren     as integer format ">>>>9" initial 0 label "Sequància" column-label "Sequància"
    field tta_ind_tip_movto_cta_corren     as character format "X(2)" initial "RE" label "Tipo Movimento" column-label "Tipo Movto"
    field tta_cod_tip_trans_cx             as character format "x(8)" label "Tipo Transaá∆o Caixa" column-label "Tipo Transaá∆o Caixa"
    field tta_ind_fluxo_movto_cta_corren   as character format "X(3)" initial "ENT" label "Fluxo Movimento" column-label "Fluxo Movto"
    field tta_cod_cenar_ctbl               as character format "x(8)" label "Cen†rio Cont†bil" column-label "Cen†rio Cont†bil"
    field tta_cod_histor_padr              as character format "x(8)" label "Hist¢rico Padr∆o" column-label "Hist¢rico Padr∆o"
    field tta_val_movto_cta_corren         as decimal format ">>>>,>>>,>>9.99" decimals 2 initial 0 label "Valor Movimento" column-label "Valor Movimento"
    field tta_cod_docto_movto_cta_bco      as character format "x(20)" label "Documento Banco" column-label "Documento Banco"
    field tta_cod_modul_dtsul              as character format "x(3)" label "M¢dulo" column-label "M¢dulo"
    field ttv_ind_erro_valid               as character format "X(08)" initial "N∆o"
    field tta_des_histor_padr              as character format "x(40)" label "Descriá∆o" column-label "Descriá∆o Hist¢rico Padr∆o"
    field tta_num_id_movto_cta_corren      as integer format "9999999999" initial 0 label "ID Movto Conta" column-label "ID Movto Conta"
    field ttv_rec_movto_cta_corren         as recid format ">>>>>>9" initial ?
    index tt_erro                         
          ttv_ind_erro_valid               ascending
    index tt_import_movto_cta_corren       is primary unique
          tta_cod_cta_corren               ascending
          tta_dat_movto_cta_corren         ascending
          tta_num_seq_movto_cta_corren     ascending
    index tt_rec_movto                    
          ttv_rec_movto_cta_corren         ascending
    .

def temp-table tt_rat_financ_cmg_import no-undo
    field ttv_rec_movto_cta_corren         as recid format ">>>>>>9" initial ?
    field tta_cod_estab                    as character format "x(3)" label "Estabelecimento" column-label "Estab"
    field tta_cod_unid_negoc               as character format "x(3)" label "Unid Neg¢cio" column-label "Un Neg"
    field tta_cod_tip_fluxo_financ         as character format "x(12)" label "Tipo Fluxo Financ" column-label "Tipo Fluxo Financ"
    field tta_val_movto_cta_corren         as decimal format ">>>>,>>>,>>9.99" decimals 2 initial 0 label "Valor Movimento" column-label "Valor Movimento"
    index tt_codigo                        is primary
          ttv_rec_movto_cta_corren         ascending
    .

def temp-table tt_val_aprop_ctbl_cmg_import no-undo
    field tta_cod_finalid_econ             as character format "x(10)" label "Finalidade" column-label "Finalidade"
    field tta_dat_cotac_indic_econ         as date format "99/99/9999" initial ? label "Data Cotaá∆o" column-label "Data Cotaá∆o"
    field tta_val_cotac_indic_econ         as decimal format ">>>>,>>9.9999999999" decimals 10 initial 0 label "Cotaá∆o" column-label "Cotaá∆o"
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
          ttv_rec_val_aprop_ctbl_cmg       ascending.

DEF TEMP-TABLE tt_movto_ffixo
FIELD ttv_rec_movto_cta_corren as recid format ">>>>>>9" initial ?
FIELD ttv_num_id_ffixo         LIKE int_ds_fundo_fixo.num_id_ffixo
INDEX rec_movto
      ttv_rec_movto_cta_corren ASCENDING
INDEX tt_id                     IS PRIMARY  
      ttv_rec_movto_cta_corren  ASCENDING
      ttv_num_id_ffixo          ASCENDING.         

/********************** Temporary Table Definition End **********************/

def new shared stream s_1.
def stream s_import.

/************************* Variable Definition Begin ************************/

def new global shared var v_cod_aplicat_dtsul_corren
    as character
    format "x(3)":U
    no-undo.
def new global shared var v_cod_ccusto_corren
    as character
    format "x(11)":U
    label "Centro Custo"
    column-label "Centro Custo"
    no-undo.
def new shared var v_cod_cenar_ctbl
    as character
    format "x(8)":U
    label "Cen†rio Cont†bil"
    column-label "Cen†rio Cont†bil"
    no-undo.
def var v_cod_cta_corren
    as character
    format "x(10)":U
    label "Conta Corrente"
    column-label "Conta Corrente"
    no-undo.
def new shared var v_cod_cta_corren_imp
    as character
    format "x(10)":U
    label "Conta Corrente"
    column-label "Cta Corrente"
    no-undo.
def new shared var v_cod_docto_movto_cta_bco
    as character
    format "x(20)":U
    label "Documento Banco"
    column-label "Documento Banco"
    no-undo.
def var v_cod_dwb_file
    as character
    format "x(40)":U
    label "Arquivo"
    column-label "Arquivo"
    no-undo.
def var v_cod_dwb_print_layout
    as character
    format "x(8)":U
    no-undo.
def var v_cod_dwb_proced
    as character
    format "x(8)":U
    no-undo.
def new shared var v_cod_dwb_program
    as character
    format "x(32)":U
    label "Programa"
    column-label "Programa"
    no-undo.
def new global shared var v_cod_dwb_user
    as character
    format "x(21)":U
    label "Usu†rio"
    column-label "Usu†rio"
    no-undo.
def new global shared var v_cod_empres_usuar
    as character
    format "x(3)":U
    label "Empresa"
    column-label "Empresa"
    no-undo.
def new global shared var v_cod_estab_usuar
    as character
    format "x(3)":U
    label "Estabelecimento"
    column-label "Estab"
    no-undo.
def new global shared var v_cod_funcao_negoc_empres
    as character
    format "x(50)":U
    no-undo.
def new global shared var v_cod_grp_usuar_lst
    as character
    format "x(3)":U
    label "Grupo Usu†rios"
    column-label "Grupo"
    no-undo.
def new shared var v_cod_histor_padr
    as character
    format "x(8)":U
    label "Hist¢rico Padr∆o"
    column-label "Hist¢rico Padr∆o"
    no-undo.
def new global shared var v_cod_idiom_usuar
    as character
    format "x(8)":U
    label "Idioma"
    column-label "Idioma"
    no-undo.
def var v_cod_layout_movto_cta_corren
    as character
    format "x(8)":U
    label "Layout Movimento"
    column-label "Layout Movto"
    no-undo.
def new shared var v_cod_modul_dtsul
    as character
    format "x(3)":U
    label "M¢dulo"
    column-label "M¢dulo"
    no-undo.
def new global shared var v_cod_modul_dtsul_corren
    as character
    format "x(3)":U
    label "M¢dulo Corrente"
    column-label "M¢dulo Corrente"
    no-undo.
def new global shared var v_cod_modul_dtsul_empres
    as character
    format "x(100)":U
    no-undo.
def new global shared var v_cod_pais_empres_usuar
    as character
    format "x(3)":U
    label "Pa°s Empresa Usu†rio"
    column-label "Pa°s"
    no-undo.
def var v_cod_parameters
    as character
    format "x(256)":U
    no-undo.
def new global shared var v_cod_plano_ccusto_corren
    as character
    format "x(8)":U
    label "Plano CCusto"
    column-label "Plano CCusto"
    no-undo.
def var v_cod_reg_import
    as character
    format "x(256)":U
    no-undo.
def var v_cod_release
    as character
    format "x(12)":U
    no-undo.
def new shared var v_cod_tip_trans_cx
    as character
    format "x(8)":U
    label "Tipo Transaá∆o Caixa"
    column-label "Tipo Transaá∆o Caixa"
    no-undo.
def new global shared var v_cod_unid_negoc_usuar
    as character
    format "x(3)":U
    view-as combo-box
    list-items ""
    inner-lines 5
    bgcolor 15 font 2
    label "Unidade Neg¢cio"
    column-label "Unid Neg¢cio"
    no-undo.
def new global shared var v_cod_usuar_corren
    as character
    format "x(12)":U
    label "Usu†rio Corrente"
    column-label "Usu†rio Corrente"
    no-undo.
def new global shared var v_cod_usuar_corren_criptog
    as character
    format "x(16)":U
    no-undo.
def var v_dat_execution
    as date
    format "99/99/9999":U
    no-undo.
def var v_dat_execution_end
    as date
    format "99/99/9999":U
    no-undo.
def var v_dat_fim_period
    as date
    format "99/99/9999":U
    label "Fim Per°odo"
    no-undo.
def var v_dat_inic_period
    as date
    format "99/99/9999":U
    label "In°cio Per°odo"
    column-label "Per°odo"
    no-undo.
def new shared var v_dat_movto_cta_corren
    as date
    format "99/99/9999":U
    initial &IF "{&ems_dbtype}":U = "MSS":U &THEN 01/01/1800 &ELSE 01/01/0001 &ENDIF
    label "Data Movimento"
    column-label "Data Movimento"
    no-undo.
def new shared var v_des_histor_movto
    as character
    format "x(2000)":U
    view-as editor max-chars 2000 scrollbar-vertical
    size 40 by 3
    bgcolor 15 font 2
    label "Hist¢rico"
    column-label "Hist¢rico"
    no-undo.
def var v_des_import_movto_cta_corren
    as character
    format "x(300)":U
    no-undo.
def var v_des_mensagem
    as character
    format "x(50)":U
    view-as editor max-chars 2000 scrollbar-vertical
    size 50 by 4
    bgcolor 15 font 2
    label "Mensagem"
    column-label "Mensagem"
    no-undo.
def var v_des_msg_erro
    as character
    format "x(60)":U
    view-as editor max-chars 2000 scrollbar-vertical
    size 60 by 2
    bgcolor 15 font 2
    label "Mensagem Erro"
    column-label "Inconsistància"
    no-undo.
def var v_hra_execution
    as Character
    format "99:99":U
    no-undo.
def var v_hra_execution_end
    as Character
    format "99:99:99":U
    label "Tempo Exec"
    no-undo.
def var v_ind_contdo_layout_movto_cta
    as character
    format "X(16)":U
    view-as combo-box
    list-items "Conta Corrente","Data Movimento","Tipo Movimento","Tipo Trans Caixa","Fluxo","Cen†rio Cont†bil","Hist¢rico","Valor Movimento","Documento","M¢dulo"
     /*l_conta_corrente*/ /*l_data_movimento*/ /*l_tipo_movimento*/ /*l_tipo_trans_caixa*/ /*l_fluxo*/ /*l_cenario_contabil*/ /*l_historico*/ /*l_valor_movimento*/ /*l_documento*/ /*l_modulo*/
    inner-lines 12
    bgcolor 15 font 2
    label "Conte£do Layout"
    column-label "Conte£do Layout"
    no-undo.
def new shared var v_ind_fluxo_movto_cta_corren
    as character
    format "X(3)":U
    view-as combo-box
    list-items "ENT","SAI"
     /*l_ent*/ /*l_sai*/
    inner-lines 3
    bgcolor 15 font 2
    label "Fluxo Movimento"
    column-label "Fluxo Movto"
    no-undo.
def new shared var v_ind_tip_movto_cta_corren_imp
    as character
    format "X(2)":U
    initial "RE" /*l_re*/
    view-as combo-box
    list-items "RE","NR"
     /*l_re*/ /*l_nr*/
    inner-lines 3
    bgcolor 15 font 2
    label "Tipo Movimento"
    column-label "Tipo Movto"
    no-undo.
def var v_log_aprop
    as logical
    format "Sim/N∆o"
    initial yes
    no-undo.
def new shared var v_log_cancel
    as logical
    format "Sim/N∆o"
    initial yes
    label "Cancelado"
    column-label "Cancelado"
    no-undo.
def var v_log_cancel_todas_import
    as logical
    format "Sim/N∆o"
    initial no
    view-as toggle-box
    no-undo.
def var v_log_dec_rejtdo
    as logical
    format "Sim/N∆o"
    initial no
    no-undo.
def new global shared var v_log_dupl_cmg
    as logical
    format "Sim/N∆o"
    initial no
    view-as toggle-box
    label "Cta Corren/Data/Tp T"
    column-label "Cta Corren/Data/Tp T"
    no-undo.
def new global shared var v_log_dupl_cmg_aux
    as logical
    format "Sim/N∆o"
    initial no
    view-as toggle-box
    label "Cta Corren/Data/Tp T"
    column-label "Cta Corren/Data/Tp T"
    no-undo.
def var v_log_funcao_tratam_dec
    as logical
    format "Sim/N∆o"
    initial no
    no-undo.
def var v_log_import_valores
    as logical
    format "Sim/N∆o"
    initial no
    no-undo.
def var v_log_method
    as logical
    format "Sim/N∆o"
    initial yes
    no-undo.
def var v_log_movto
    as logical
    format "Sim/N∆o"
    initial no
    view-as toggle-box
    label "Movimento"
    column-label "Movimento"
    no-undo.
def var v_log_print_imported
    as logical
    format "Sim/N∆o"
    initial yes
    view-as toggle-box
    label "Importados"
    column-label "Importados"
    no-undo.
def var v_log_print_imported_nok
    as logical
    format "Sim/N∆o"
    initial yes
    view-as toggle-box
    label "N∆o Importados"
    column-label "N∆o Importados"
    no-undo.
def var v_log_um_aprop
    as logical
    format "Sim/N∆o"
    initial no
    no-undo.
def var v_log_val
    as logical
    format "Sim/N∆o"
    initial no
    no-undo.
def var v_nom_dwb_printer
    as character
    format "x(30)":U
    no-undo.
def var v_nom_dwb_print_file
    as character
    format "x(100)":U
    label "Arquivo Impress∆o"
    column-label "Arq Impr"
    no-undo.
def var v_nom_enterprise
    as character
    format "x(40)":U
    no-undo.
def var v_nom_filename
    as character
    format "x(80)":U
    view-as editor max-chars 250 no-word-wrap
    size 40 by 1
    bgcolor 15 font 2
    label "Nome Arquivo"
    no-undo.
def var v_nom_filename_import
    as character
    format "x(80)":U
    view-as editor max-chars 250 no-word-wrap
    size 40 by 1
    bgcolor 15 font 2
    label "Nome Arquivo"
    column-label "Arquivo"
    no-undo.
def var v_nom_filename_temp
    as character
    format "x(30)":U
    no-undo.
def var v_nom_integer
    as character
    format "x(30)":U
    no-undo.
def var v_nom_prog_appc
    as character
    format "x(50)":U
    label "Programa APPC"
    column-label "Programa APPC"
    no-undo.
def var v_nom_prog_dpc
    as character
    format "x(50)":U
    label "Programa Dpc"
    column-label "Programa Dpc"
    no-undo.
def var v_nom_prog_ext
    as character
    format "x(8)":U
    label "Nome Externo"
    no-undo.
def var v_nom_prog_upc
    as character
    format "X(50)":U
    label "Programa UPC"
    column-label "Programa UPC"
    no-undo.
def var v_nom_report_title
    as character
    format "x(40)":U
    no-undo.
def var v_nom_table_epc
    as character
    format "x(30)":U
    no-undo.
def var v_nom_title_aux
    as character
    format "x(60)":U
    no-undo.
def var v_num_page_number
    as integer
    format ">>>>>9":U
    label "P†gina"
    column-label "P†gina"
    no-undo.
def var v_num_ped_exec
    as integer
    format ">>>>9":U
    label "Pedido"
    column-label "Pedido"
    no-undo.
def new global shared var v_num_ped_exec_corren
    as integer
    format ">>>>9":U
    no-undo.
def var v_num_seq_movto
    as integer
    format ">>>>,>>9":U
    no-undo.
def var v_qtd_column
    as decimal
    format ">>9":U
    decimals 0
    label "Colunas"
    column-label "Colunas"
    no-undo.
def var v_qtd_line
    as decimal
    format ">>9":U
    decimals 0
    label "Linhas"
    column-label "Linhas"
    no-undo.
def var v_rec_aprop_ctbl_cmg
    as recid
    format ">>>>>>9":U
    initial ?
    no-undo.
def var v_rec_cta_corren
    as recid
    format ">>>>>>9":U
    initial ?
    no-undo.
def new global shared var v_rec_layout_movto_cta_corren
    as recid
    format ">>>>>>9":U
    initial ?
    no-undo.
def var v_rec_log
    as recid
    format ">>>>>>9":U
    no-undo.
def var v_rec_table_epc
    as recid
    format ">>>>>>9":U
    no-undo.
def new shared var v_val_movto_cta_corren
    as decimal
    format ">>>>,>>>,>>9.99":U
    decimals 2
    initial 0
    label "Valor Movimento"
    column-label "Valor Movimento"
    no-undo.
def var v_wgh_focus
    as widget-handle
    format ">>>>>>9":U
    no-undo.
def var v_wgh_frame
    as widget-handle
    format ">>>>>>9":U
    no-undo.
def var v_wgh_frame_epc
    as widget-handle
    format ">>>>>>9":U
    no-undo.
def var v_wgh_label
    as widget-handle
    format ">>>>>>9":U
    no-undo.

DEF rectangle rt_001
    size 1 by 1
    edge-pixels 2.
def rectangle rt_002
    size 1 by 1
    edge-pixels 2.
def rectangle rt_003
    size 1 by 1
    edge-pixels 2.
def rectangle rt_004
    size 1 by 1
    edge-pixels 2.
def rectangle rt_005
    size 1 by 1
    edge-pixels 2.
def rectangle rt_cxcf
    size 1 by 1
    fgcolor 1 edge-pixels 2.
def rectangle rt_folder
    size 1 by 1
    edge-pixels 1.
def rectangle rt_folder_bottom
    size 1 by 1
    edge-pixels 0.
def rectangle rt_folder_left
    size 1 by 1
    edge-pixels 0.
def rectangle rt_folder_right
    size 1 by 1
    edge-pixels 0.
def rectangle rt_folder_top
    size 1 by 1
    edge-pixels 0.

def var v_cod_dir_temp             as character       no-undo. 
def var v_cod_return               as character       no-undo. 
def var v_hdl_text                 as handle          no-undo. 
def var v_num_list                 as integer         no-undo. 
DEF VAR v_tipo_movto               AS CHAR            NO-UNDO. 
DEF VAR c-cta-ctbl                 AS CHAR            NO-UNDO. 

def buffer b_lin_layout_movto_cta for lin_layout_movto_cta.

assign v_cod_cta_corren = "36267".

assign v_nom_filename   = session:temp-directory + "Caixa_e_Bancos":U + '.txt'.

output stream s_1 to value(v_nom_filename) paged convert target 'iso8859-1'.
     
assign v_cod_layout_movto_cta_corren = "FFixo".

find first b_lin_layout_movto_cta
     where b_lin_layout_movto_cta.cod_layout_movto_cta_corren = v_cod_layout_movto_cta_corren
     and   b_lin_layout_movto_cta.ind_contdo_layout_movto_cta = "Tipo Reg Movto" /*l_tipo_registro_movimento*/ 
     no-lock no-error.
 if avail b_lin_layout_movto_cta then
     assign v_log_movto = yes.
   
 find first b_lin_layout_movto_cta
     where b_lin_layout_movto_cta.cod_layout_movto_cta_corren = v_cod_layout_movto_cta_corren
     and   b_lin_layout_movto_cta.ind_contdo_layout_movto_cta = "Tipo Reg Aprop" /*l_tipo_registro_apropriacao*/ 
     no-lock no-error.
 if avail b_lin_layout_movto_cta then
     assign v_log_aprop = YES
            v_log_import_valores = YES.

FIND FIRST int_ds_param_fundo_fixo NO-LOCK WHERE
           int_ds_param_fundo_fixo.cod_empresa =  i-ep-codigo-usuario NO-ERROR.
IF NOT AVAIL int_ds_param_fundo_fixo THEN DO:
   
    DISP "Parametros fundo fixo n∆o cadastradas para a empresa " + STRING(i-ep-codigo-usuario).

    RETURN NO-APPLY.

END.

RUN pi_imp_movto_cta_corren. 
RUN pi_imp_movto_cta_corren_procfit.

output stream s_1 close.

PROCEDURE pi_imp_movto_cta_corren:      
       DEF VAR c_codEstabel LIKE  int_ds_fundo_fixo.cod_estab NO-UNDO.
     
       EMPTY TEMP-TABLE tt_movto_cta_corren_import.
       EMPTY TEMP-TABLE tt_aprop_ctbl_cmg_imp. 
       EMPTY TEMP-TABLE tt_import_movto_valid.
       EMPTY TEMP-TABLE tt_import_movto_valid_cmg.
       EMPTY TEMP-TABLE tt_val_aprop_ctbl_cmg_import.
       EMPTY TEMP-TABLE tt_movto_ffixo.  
           
    /*************************** Buffer Definition End **************************/
       
    FOR EACH int_ds_fundo_fixo NO-LOCK WHERE
             int_ds_fundo_fixo.situacao = 1 /* N∆o integrado */:  

       /*PAUSE(1).*/

       EMPTY TEMP-TABLE tt_movto_cta_corren_import.
       EMPTY TEMP-TABLE tt_aprop_ctbl_cmg_imp. 
       EMPTY TEMP-TABLE tt_import_movto_valid.
       EMPTY TEMP-TABLE tt_import_movto_valid_cmg.
       EMPTY TEMP-TABLE tt_val_aprop_ctbl_cmg_import.
       EMPTY TEMP-TABLE tt_movto_ffixo.        


       assign v_log_movto    = no
              v_log_aprop    = no
              v_log_um_aprop = no
              v_log_val      = no.
              
         if int_ds_fundo_fixo.cod_estab <> "973" then DO:  
             ASSIGN  v_cod_cta_corren    =  "FF-" + int_ds_fundo_fixo.cod_estab.

             IF int_ds_fundo_fixo.cod_estab = "401" THEN DO:
                ASSIGN v_cod_cta_corren    =  "FF-" + "014".
             END.
         END.
         ELSE DO:
           ASSIGN v_cod_cta_corren    =  "FF-" + "ADM".       
         END.
        
        find cta_corren where 
             cta_corren.cod_cta_corren = v_cod_cta_corren no-lock no-error.

        FIND FIRST movto_cta_corren NO-LOCK 
             WHERE movto_cta_corren.cod_cta_corren          = v_cod_cta_corren 
               AND movto_cta_corren.cod_docto_movto_cta_bco = int_ds_fundo_fixo.cod_docto NO-ERROR.
        IF AVAIL movto_cta_corren THEN DO:

            FIND FIRST bf-int_ds_fundo_fixo EXCLUSIVE-LOCK
                 WHERE ROWID(bf-int_ds_fundo_fixo) = ROWID(int_ds_fundo_fixo) NO-ERROR.
            IF AVAIL bf-int_ds_fundo_fixo THEN DO:
                ASSIGN bf-int_ds_fundo_fixo.situacao = 2.
            END.
            RELEASE bf-int_ds_fundo_fixo.

            RUN intprg/int999.p (INPUT "FFIXO", 
                                 INPUT string(int(int_ds_fundo_fixo.cod_docto)),
                                 INPUT "Documento j† integrado para essa Conta Corrente." + " Estab.: " + int_ds_fundo_fixo.cod_estab + " Docto.: " + int_ds_fundo_fixo.cod_docto +
                                       " Conta: " + int_ds_fundo_fixo.cta_ctbl  /* + " CCusto: " + int_ds_fundo_fixo.cod_ccusto */ ,
                                 INPUT 1, /* 1 - Pendente ou 2 - Integrado */
                                 INPUT c-seg-usuario,
                                 INPUT "int001.p").
            NEXT.
        END.

        
        run pi_cria_tt_movto_import. /*pi_cria_tt_movto_import*/  


/*         do trans: */
        
            run prgfin/cmg/cmg719zf.py (Input 1,
                                    Input v_log_print_imported_nok,
                                    Input v_log_print_imported,
                                    input-output table tt_movto_cta_corren_import,
                                    Input table tt_aprop_ctbl_cmg_imp,
                                    Input table tt_val_aprop_ctbl_cmg_import,
                                    Input table tt_rat_financ_cmg_import,
                                    output table tt_import_movto_valid_cmg) /*prg_api_movto_cta_corren_import_recebto_2*/. 
    
/*         end. */
        
        FOR EACH tt_movto_cta_corren_import:   
    
               IF CAN-FIND(FIRST tt_import_movto_valid_cmg WHERE
                                 tt_import_movto_valid_cmg.ttv_rec_movto_cta_corren = RECID(tt_movto_cta_corren_import) AND  
                                 tt_import_movto_valid_cmg.ttv_num_mensagem > 0) THEN DO: 
                     
                  FOR EACH tt_import_movto_valid_cmg WHERE
                           tt_import_movto_valid_cmg.ttv_rec_movto_cta_corren = RECID(tt_movto_cta_corren_import) AND  
                           tt_import_movto_valid_cmg.ttv_num_mensagem > 0,   
                      FIRST tt_movto_ffixo NO-LOCK WHERE
                            tt_movto_ffixo.ttv_num_id_ffixo = int(tt_movto_cta_corren_import.tta_cod_docto_movto_cta_bco):
                      
                         RUN intprg/int999.p (INPUT "FFIXO", 
                                              INPUT string(int(int_ds_fundo_fixo.cod_docto)),
                                              INPUT tt_import_movto_valid_cmg.ttv_des_mensagem + " Estab.: " + int_ds_fundo_fixo.cod_estab + " Docto.: " + int_ds_fundo_fixo.cod_docto +
                                                    " Conta: " + int_ds_fundo_fixo.cta_ctbl  /* + " CCusto: " + int_ds_fundo_fixo.cod_ccusto */ ,
                                              INPUT 1, /* 1 - Pendente ou 2 - Integrado */
                                              INPUT c-seg-usuario,
                                              INPUT "int001.p").
                  END.  
    
               END.   
               ELSE DO:    
                   
                     FOR FIRST tt_movto_ffixo NO-LOCK WHERE
                               tt_movto_ffixo.ttv_num_id_ffixo = int(tt_movto_cta_corren_import.tta_cod_docto_movto_cta_bco):
    
                         IF CAN-FIND(FIRST tt_import_movto_valid_cmg WHERE
                                           tt_import_movto_valid_cmg.ttv_rec_movto_cta_corren = RECID(tt_movto_cta_corren_import) AND  
                                           tt_import_movto_valid_cmg.ttv_num_mensagem > 0) THEN DO: 
                             NEXT.
                         END.
    
/*                          FIND FIRST int_ds_fundo_fixo EXCLUSIVE-LOCK WHERE                                       */
/*                                     int(int_ds_fundo_fixo.cod_docto) = tt_movto_ffixo.ttv_num_id_ffixo NO-ERROR. */
                         IF AVAIL int_ds_fundo_fixo THEN DO:
                             
                             IF int_ds_fundo_fixo.cod_estab = "401" THEN
                                 ASSIGN c_codEstabel =  "014".
                             ELSE ASSIGN c_codEstabel =  int_ds_fundo_fixo.cod_estab.
    
                             FIND FIRST movto_cta_corren
                                  WHERE movto_cta_corren.cod_cta_corren          = "FF-" + c_codEstabel
                                    AND movto_cta_corren.cod_docto_movto_cta_bco = int_ds_fundo_fixo.cod_docto  NO-ERROR.
                             IF AVAIL movto_cta_corren THEN DO:
                                 
                                 RUN intprg/int999.p (INPUT "FFIXO", 
                                                      INPUT string(int(int_ds_fundo_fixo.cod_docto)),
                                                      INPUT "Registro Integrado -" + " Estab.: " + int_ds_fundo_fixo.cod_estab + " Docto.: " + int_ds_fundo_fixo.cod_docto +
                                                            " Conta: " + int_ds_fundo_fixo.cta_ctbl /* + " CCusto: " + int_ds_fundo_fixo.cod_ccusto */ , 
                                                      INPUT 2, /* 1 - Pendente ou 2 - Integrado */
                                                      INPUT c-seg-usuario,
                                                      INPUT "int001.p").

                                FIND FIRST bf-int_ds_fundo_fixo EXCLUSIVE-LOCK
                                     WHERE ROWID(bf-int_ds_fundo_fixo) = ROWID(int_ds_fundo_fixo) NO-ERROR.
                                IF AVAIL bf-int_ds_fundo_fixo THEN DO:
                                    ASSIGN bf-int_ds_fundo_fixo.situacao = 2.
                                END.
                                RELEASE bf-int_ds_fundo_fixo.
                             END.
    
                         END.
    
                         RELEASE int_ds_fundo_fixo.
                     END.                          
    
               END.
    
        END.   
    
        if  return-value = '2782'
        then do:
            /* Vers∆o de integraá∆o incorreta ! */
            run pi_messages (input "show",
                             input 2782,
                             input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")) /*msg_2782*/.
            return error.
        end /* if */.

    END.
    
END PROCEDURE. /* pi_imp_movto_cta_corren */



PROCEDURE pi_cria_tt_movto_import:

    /************************* Variable Definition Begin ************************/

    def var v_cod_list_aprop                 as character       no-undo. /*local*/
    def var v_num_list_aprop                 as integer         no-undo. /*local*/
    DEF VAR  c-cod-ccusto                    LIKE int_ds_ccusto_fundo_fixo.cod_ccusto NO-UNDO.

    DEF VAR c_codEstabel                     LIKE int_ds_fundo_fixo.cod_estab         NO-UNDO.
    /************************** Variable Definition End *************************/
         /*** Campos tabela de integraá∆o 
         
            int_ds_fundo_fixo.cod_ccusto 
            int_ds_fundo_fixo.cod_docto 
            int_ds_fundo_fixo.cod_empresa 
            int_ds_fundo_fixo.cod_estab 
            int_ds_fundo_fixo.situacao 
            int_ds_fundo_fixo.cod_unid_negoc 
            int_ds_fundo_fixo.cta_ctbl 
            int_ds_fundo_fixo.dat_movto 
            int_ds_fundo_fixo.des_historico 
            int_ds_fundo_fixo.natureza 
            int_ds_fundo_fixo.num_id_ffixo 
            int_ds_fundo_fixo.tipo_movto 
            int_ds_fundo_fixo.val_movto 
        
        ***************/
        
        
         IF AVAIL int_ds_param_fundo_fixo THEN
            ASSIGN c-cta-ctbl = int_ds_param_fundo_fixo.cta_ctbl.

         IF int_ds_fundo_fixo.tipo_movto = "D" THEN
            ASSIGN v_tipo_movto = "SAI".
         ELSE
            ASSIGN v_tipo_movto = "ENT".

         ASSIGN v_num_seq_movto = 1.
           
         FOR LAST movto_cta_corren NO-LOCK WHERE
                  movto_cta_corren.cod_cta_corren       = v_cod_cta_corren AND 
                  movto_cta_corren.dat_movto_cta_corren = int_ds_fundo_fixo.dat_movto  
                 BY movto_cta_corren.num_seq_movto_cta_corren DESC:
                
            ASSIGN v_num_seq_movto = movto_cta_corren.num_seq_movto_cta_corren + 1.
                  
         END.
         
         FOR LAST tt_movto_cta_corren_import NO-LOCK WHERE
                  tt_movto_cta_corren_import.tta_cod_cta_corren        = v_cod_cta_corren AND 
                  tt_movto_cta_corren_import.tta_dat_movto_cta_corren  = int_ds_fundo_fixo.dat_movto  
               BY tt_movto_cta_corren_import.tta_num_seq_movto_cta_corren DESC:
                
               ASSIGN v_num_seq_movto = tt_movto_cta_corren_import.tta_num_seq_movto_cta_corren + 1.
                  
         END.

        /*** Temp Table Movimento ***/
        
        create tt_movto_cta_corren_import.
        assign tt_movto_cta_corren_import.ttv_ind_erro_valid             = "N∆o" /*l_nao*/ 
               tt_movto_cta_corren_import.tta_num_seq_movto_cta_corren   = v_num_seq_movto
               tt_movto_cta_corren_import.tta_cod_cta_corren             = v_cod_cta_corren                 /* Conta Corrente        */
               tt_movto_cta_corren_import.tta_dat_movto_cta_corren       = int_ds_fundo_fixo.dat_movto      /* Data Movto            */
               tt_movto_cta_corren_import.tta_ind_tip_movto_cta_corren   = "RE"                             /* Tipo movto Cta Corren */
               tt_movto_cta_corren_import.tta_cod_tip_trans_cx           = int_ds_param_fundo_fixo.cod_tip_trans_cx  /* Tipo Trans Caixa      */
               tt_movto_cta_corren_import.tta_ind_fluxo_movto_cta_corren = v_tipo_movto                     /* Fluxo - int_ds_fundo_fixo.tipo_movto  */
               tt_movto_cta_corren_import.tta_cod_cenar_ctbl             = ""                               /* Cen†rio Cont†bil       */
               tt_movto_cta_corren_import.tta_des_histor_padr            = int_ds_fundo_fixo.des_historico  /* Hist¢rico              */
               tt_movto_cta_corren_import.tta_val_movto_cta_corren       = int_ds_fundo_fixo.val_movto      /* Valor Movimento        */ 
               tt_movto_cta_corren_import.tta_cod_docto_movto_cta_bco    = int_ds_fundo_fixo.cod_docto      /* Documento              */ 
               tt_movto_cta_corren_import.tta_cod_modul_dtsul            = "CMG"                            /* M¢dulo                 */
               tt_movto_cta_corren_import.tta_num_id_movto_cta_corren    = 0 
               tt_movto_cta_corren_import.ttv_rec_movto_cta_corren       = recid(tt_movto_cta_corren_import)
               v_rec_cta_corren                                          = recid(tt_movto_cta_corren_import)
               v_cod_cta_corren                                          = tt_movto_cta_corren_import.tta_cod_cta_corren. 

        create tt_movto_ffixo.
        ASSIGN tt_movto_ffixo.ttv_rec_movto_cta_corren = recid(tt_movto_cta_corren_import)
               tt_movto_ffixo.ttv_num_id_ffixo         = int(int_ds_fundo_fixo.cod_docto).  
            
       /* ** Temp Table das apropriaá‰es ***/
        IF int_ds_fundo_fixo.cod_estab = "401" THEN
             ASSIGN c_codEstabel =  "014".
        ELSE ASSIGN c_codEstabel =  int_ds_fundo_fixo.cod_estab.


       FIND FIRST int_ds_ccusto_fundo_fixo NO-LOCK WHERE
                  int_ds_ccusto_fundo_fixo.cod_empresa = int_ds_param_fundo_fixo.cod_empresa AND 
                  int_ds_ccusto_fundo_fixo.cod_estab   = int_ds_fundo_fixo.cod_estab NO-ERROR.
       IF AVAIL int_ds_ccusto_fundo_fixo THEN
          ASSIGN c-cod-ccusto =  int_ds_ccusto_fundo_fixo.cod_ccusto.
                      
       create tt_aprop_ctbl_cmg_imp.
       assign tt_aprop_ctbl_cmg_imp.ttv_rec_aprop_ctbl_cmg    = recid(tt_aprop_ctbl_cmg_imp)
              v_rec_aprop_ctbl_cmg                            = tt_aprop_ctbl_cmg_imp.ttv_rec_aprop_ctbl_cmg
              tt_aprop_ctbl_cmg_imp.tta_ind_natur_lancto_ctbl = int_ds_fundo_fixo.natureza     /* Natureza        */
              tt_aprop_ctbl_cmg_imp.tta_cod_plano_cta_ctbl    = "PADRAO"                       /* Plano Contas    */
              tt_aprop_ctbl_cmg_imp.tta_cod_cta_ctbl          = c-cta-ctbl                     /* Cta Ctbl        */
              tt_aprop_ctbl_cmg_imp.tta_cod_estab             = int_ds_fundo_fixo.cod_estab    /* Estabelecimento */
              tt_aprop_ctbl_cmg_imp.tta_cod_unid_negoc        =  "000"                         /* Unid Negoc      */
              tt_aprop_ctbl_cmg_imp.tta_cod_plano_ccusto      =  "PADRAO"                      /* Plano CCusto    */ 
              tt_aprop_ctbl_cmg_imp.tta_cod_ccusto            =   c-cod-ccusto                 /* Centro Custo    */ 
              tt_aprop_ctbl_cmg_imp.tta_val_movto_cta_corren  = int_ds_fundo_fixo.val_movto    /* Valor Aprop     */
              tt_aprop_ctbl_cmg_imp.tta_cod_estab             = int_ds_fundo_fixo.cod_estab    /* Estabelecimento */    
              tt_aprop_ctbl_cmg_imp.ttv_rec_movto_cta_corren = v_rec_cta_corren
              tt_aprop_ctbl_cmg_imp.ttv_rec_aprop_ctbl_cmg   = v_rec_aprop_ctbl_cmg.
             
                  
        /* ** Temp Table dos valores ***/

        create tt_val_aprop_ctbl_cmg_import.
        assign tt_val_aprop_ctbl_cmg_import.ttv_rec_movto_cta_corren   = v_rec_cta_corren
               tt_val_aprop_ctbl_cmg_import.ttv_rec_aprop_ctbl_cmg     = v_rec_aprop_ctbl_cmg
               tt_val_aprop_ctbl_cmg_import.ttv_rec_val_aprop_ctbl_cmg = recid(tt_val_aprop_ctbl_cmg_import)            
               tt_val_aprop_ctbl_cmg_import.tta_cod_finalid_econ       = "Corrente" /* Finalidade    */
               tt_val_aprop_ctbl_cmg_import.tta_dat_cotac_indic_econ   = int_ds_fundo_fixo.dat_movto  /* Data Cotaá∆o  */
               tt_val_aprop_ctbl_cmg_import.tta_val_cotac_indic_econ   =  1             /* Valor Cotaá∆o */
               tt_val_aprop_ctbl_cmg_import.tta_val_movto_cta_corren   =  tt_aprop_ctbl_cmg_imp.tta_val_movto_cta_corren * tt_val_aprop_ctbl_cmg_import.tta_val_cotac_indic_econ. 
    
END PROCEDURE. /* pi_cria_tt_movto_import */


PROCEDURE pi_imp_movto_cta_corren_procfit:      
       DEF VAR c_codEstabel LIKE  int_dp_fundo_fixo.cod_estab NO-UNDO.
       DEFINE VARIABLE aux AS INTEGER   NO-UNDO.
     
       EMPTY TEMP-TABLE tt_movto_cta_corren_import.
       EMPTY TEMP-TABLE tt_aprop_ctbl_cmg_imp. 
       EMPTY TEMP-TABLE tt_import_movto_valid.
       EMPTY TEMP-TABLE tt_import_movto_valid_cmg.
       EMPTY TEMP-TABLE tt_val_aprop_ctbl_cmg_import.
       EMPTY TEMP-TABLE tt_movto_ffixo.  
           
    /*************************** Buffer Definition End **************************/
       
    FOR EACH int_dp_fundo_fixo NO-LOCK WHERE
             int_dp_fundo_fixo.situacao = 1 /* N∆o integrado */
/*          AND int_dp_fundo_fixo.dat_movto >= 11/01/18 */
         AND int_dp_fundo_fixo.cod_docto <> ?:  

       FIND FIRST bf-int_dp_fundo_fixo EXCLUSIVE-LOCK
           WHERE ROWID(bf-int_dp_fundo_fixo) = ROWID(int_dp_fundo_fixo) NO-ERROR.
       ASSIGN bf-int_dp_fundo_fixo.cod_docto = REPLACE(int_dp_fundo_fixo.cod_docto,"/","")
              bf-int_dp_fundo_fixo.cod_docto = REPLACE(int_dp_fundo_fixo.cod_docto,"\","")
              bf-int_dp_fundo_fixo.cod_docto = REPLACE(int_dp_fundo_fixo.cod_docto,"-","")
              bf-int_dp_fundo_fixo.cod_docto = REPLACE(int_dp_fundo_fixo.cod_docto," ","")
              bf-int_dp_fundo_fixo.cod_docto = REPLACE(int_dp_fundo_fixo.cod_docto,"+","")
              bf-int_dp_fundo_fixo.cod_docto = REPLACE(int_dp_fundo_fixo.cod_docto,"*","")
              bf-int_dp_fundo_fixo.cod_docto = SUBSTRING(int_dp_fundo_fixo.cod_docto,1,8)
              bf-int_dp_fundo_fixo.cod_docto = REPLACE(int_dp_fundo_fixo.cod_docto,",","")
              bf-int_dp_fundo_fixo.cod_docto = REPLACE(int_dp_fundo_fixo.cod_docto,"'","")
              bf-int_dp_fundo_fixo.cod_docto = REPLACE(int_dp_fundo_fixo.cod_docto,"A","")
              bf-int_dp_fundo_fixo.cod_docto = REPLACE(int_dp_fundo_fixo.cod_docto,"B","")
              bf-int_dp_fundo_fixo.cod_docto = REPLACE(int_dp_fundo_fixo.cod_docto,"C","")
              bf-int_dp_fundo_fixo.cod_docto = REPLACE(int_dp_fundo_fixo.cod_docto,"D","")
              bf-int_dp_fundo_fixo.cod_docto = REPLACE(int_dp_fundo_fixo.cod_docto,"E","")
              bf-int_dp_fundo_fixo.cod_docto = REPLACE(int_dp_fundo_fixo.cod_docto,"F","")
              bf-int_dp_fundo_fixo.cod_docto = REPLACE(int_dp_fundo_fixo.cod_docto,"G","")
              bf-int_dp_fundo_fixo.cod_docto = REPLACE(int_dp_fundo_fixo.cod_docto,"H","")
              bf-int_dp_fundo_fixo.cod_docto = REPLACE(int_dp_fundo_fixo.cod_docto,"I","")
              bf-int_dp_fundo_fixo.cod_docto = REPLACE(int_dp_fundo_fixo.cod_docto,"J","")
              bf-int_dp_fundo_fixo.cod_docto = REPLACE(int_dp_fundo_fixo.cod_docto,"K","")
              bf-int_dp_fundo_fixo.cod_docto = REPLACE(int_dp_fundo_fixo.cod_docto,"L","")
              bf-int_dp_fundo_fixo.cod_docto = REPLACE(int_dp_fundo_fixo.cod_docto,"M","")
              bf-int_dp_fundo_fixo.cod_docto = REPLACE(int_dp_fundo_fixo.cod_docto,"N","")
              bf-int_dp_fundo_fixo.cod_docto = REPLACE(int_dp_fundo_fixo.cod_docto,"O","")
              bf-int_dp_fundo_fixo.cod_docto = REPLACE(int_dp_fundo_fixo.cod_docto,"P","")
              bf-int_dp_fundo_fixo.cod_docto = REPLACE(int_dp_fundo_fixo.cod_docto,"Q","")
              bf-int_dp_fundo_fixo.cod_docto = REPLACE(int_dp_fundo_fixo.cod_docto,"R","")
              bf-int_dp_fundo_fixo.cod_docto = REPLACE(int_dp_fundo_fixo.cod_docto,"S","")
              bf-int_dp_fundo_fixo.cod_docto = REPLACE(int_dp_fundo_fixo.cod_docto,"T","")
              bf-int_dp_fundo_fixo.cod_docto = REPLACE(int_dp_fundo_fixo.cod_docto,"U","")
              bf-int_dp_fundo_fixo.cod_docto = REPLACE(int_dp_fundo_fixo.cod_docto,"V","")
              bf-int_dp_fundo_fixo.cod_docto = REPLACE(int_dp_fundo_fixo.cod_docto,"W","")
              bf-int_dp_fundo_fixo.cod_docto = REPLACE(int_dp_fundo_fixo.cod_docto,"X","")
              bf-int_dp_fundo_fixo.cod_docto = REPLACE(int_dp_fundo_fixo.cod_docto,"Y","")
              bf-int_dp_fundo_fixo.cod_docto = REPLACE(int_dp_fundo_fixo.cod_docto,"Z","").
             

       RELEASE bf-int_dp_fundo_fixo.

       /* PAUSE(1). 
       */

       EMPTY TEMP-TABLE tt_movto_cta_corren_import.
       EMPTY TEMP-TABLE tt_aprop_ctbl_cmg_imp. 
       EMPTY TEMP-TABLE tt_import_movto_valid.
       EMPTY TEMP-TABLE tt_import_movto_valid_cmg.
       EMPTY TEMP-TABLE tt_val_aprop_ctbl_cmg_import.
       EMPTY TEMP-TABLE tt_movto_ffixo.        


       assign v_log_movto    = no
              v_log_aprop    = no
              v_log_um_aprop = no
              v_log_val      = no.
              
         if int_dp_fundo_fixo.cod_estab <> "973" then DO:  
             ASSIGN  v_cod_cta_corren    =  "FF-" + int_dp_fundo_fixo.cod_estab.

             IF int_dp_fundo_fixo.cod_estab = "401" THEN DO:
                ASSIGN v_cod_cta_corren    =  "FF-" + "014".
             END.
         END.
         ELSE DO:
           ASSIGN v_cod_cta_corren    =  "FF-" + "ADM".       
         END.
        
        find cta_corren where 
             cta_corren.cod_cta_corren = v_cod_cta_corren no-lock no-error.
        
        run pi_cria_tt_movto_import_procfit. /*pi_cria_tt_movto_import*/  


/*         do trans: */
        
            run prgfin/cmg/cmg719zf.py (Input 1,
                                    Input v_log_print_imported_nok,
                                    Input v_log_print_imported,
                                    input-output table tt_movto_cta_corren_import,
                                    Input table tt_aprop_ctbl_cmg_imp,
                                    Input table tt_val_aprop_ctbl_cmg_import,
                                    Input table tt_rat_financ_cmg_import,
                                    output table tt_import_movto_valid_cmg) /*prg_api_movto_cta_corren_import_recebto_2*/. 
    
/*         end. */
        
        FOR EACH tt_movto_cta_corren_import:   
    
               IF CAN-FIND(FIRST tt_import_movto_valid_cmg WHERE
                                 tt_import_movto_valid_cmg.ttv_rec_movto_cta_corren = RECID(tt_movto_cta_corren_import) AND  
                                 tt_import_movto_valid_cmg.ttv_num_mensagem > 0) THEN DO: 

                   .MESSAGE tt_movto_cta_corren_import.tta_cod_docto_movto_cta_bco
                       VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
                     
                  FOR EACH tt_import_movto_valid_cmg WHERE
                           tt_import_movto_valid_cmg.ttv_rec_movto_cta_corren = RECID(tt_movto_cta_corren_import) AND  
                           tt_import_movto_valid_cmg.ttv_num_mensagem > 0,   
                      FIRST tt_movto_ffixo NO-LOCK WHERE
                            tt_movto_ffixo.ttv_num_id_ffixo = int(tt_movto_cta_corren_import.tta_cod_docto_movto_cta_bco):
                      
                         RUN intprg/int999.p (INPUT "FFIXO", 
                                              INPUT string(int_dp_fundo_fixo.cod_docto),
                                              INPUT tt_import_movto_valid_cmg.ttv_des_mensagem + " Estab.: " + int_dp_fundo_fixo.cod_estab + " Docto.: " + int_dp_fundo_fixo.cod_docto +
                                                    " Conta: " + int_dp_fundo_fixo.cta_ctbl  /* + " CCusto: " + int_dp_fundo_fixo.cod_ccusto */ ,
                                              INPUT 1, /* 1 - Pendente ou 2 - Integrado */
                                              INPUT c-seg-usuario,
                                              INPUT "int001.p").
                  END.  
    
               END.   
               ELSE DO:    
                   
                     FOR FIRST tt_movto_ffixo NO-LOCK WHERE
                               tt_movto_ffixo.ttv_num_id_ffixo = int(tt_movto_cta_corren_import.tta_cod_docto_movto_cta_bco):
    
                         IF CAN-FIND(FIRST tt_import_movto_valid_cmg WHERE
                                           tt_import_movto_valid_cmg.ttv_rec_movto_cta_corren = RECID(tt_movto_cta_corren_import) AND  
                                           tt_import_movto_valid_cmg.ttv_num_mensagem > 0) THEN DO: 
                             NEXT.
                         END.
    
/*                          FIND FIRST int_dp_fundo_fixo EXCLUSIVE-LOCK WHERE                                       */
/*                                     int(int_dp_fundo_fixo.cod_docto) = tt_movto_ffixo.ttv_num_id_ffixo NO-ERROR. */
                         IF AVAIL int_dp_fundo_fixo THEN DO:
                             
                             IF int_dp_fundo_fixo.cod_estab = "401" THEN
                                 ASSIGN c_codEstabel =  "014".
                             ELSE ASSIGN c_codEstabel =  int_dp_fundo_fixo.cod_estab.
    
                             FIND FIRST movto_cta_corren
                                  WHERE movto_cta_corren.cod_cta_corren          = "FF-" + c_codEstabel
                                    AND movto_cta_corren.cod_docto_movto_cta_bco = int_dp_fundo_fixo.cod_docto  NO-ERROR.
                             IF AVAIL movto_cta_corren THEN DO:
                                 
                                 RUN intprg/int999.p (INPUT "FFIXO", 
                                                      INPUT string(int_dp_fundo_fixo.cod_docto),
                                                      INPUT "Registro Integrado -" + " Estab.: " + int_dp_fundo_fixo.cod_estab + " Docto.: " + int_dp_fundo_fixo.cod_docto +
                                                            " Conta: " + int_dp_fundo_fixo.cta_ctbl /* + " CCusto: " + int_dp_fundo_fixo.cod_ccusto */ , 
                                                      INPUT 2, /* 1 - Pendente ou 2 - Integrado */
                                                      INPUT c-seg-usuario,
                                                      INPUT "int001.p").

                                FIND FIRST bf-int_dp_fundo_fixo EXCLUSIVE-LOCK
                                     WHERE ROWID(bf-int_dp_fundo_fixo) = ROWID(int_dp_fundo_fixo) NO-ERROR.
                                IF AVAIL bf-int_dp_fundo_fixo THEN DO:
                                    ASSIGN bf-int_dp_fundo_fixo.situacao = 2.
                                END.
                                RELEASE bf-int_dp_fundo_fixo.
                             END.
    
                         END.
    
                         RELEASE int_dp_fundo_fixo.
                     END.                          
    
               END.
    
        END.   
    
        if  return-value = '2782'
        then do:
            /* Vers∆o de integraá∆o incorreta ! */
            run pi_messages (input "show",
                             input 2782,
                             input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")) /*msg_2782*/.
            return error.
        end /* if */.

    END.
    
END PROCEDURE. /* pi_imp_movto_cta_corren */



PROCEDURE pi_cria_tt_movto_import_procfit:

    /************************* Variable Definition Begin ************************/

    def var v_cod_list_aprop                 as character       no-undo. /*local*/
    def var v_num_list_aprop                 as integer         no-undo. /*local*/
    DEF VAR  c-cod-ccusto                    LIKE int_ds_ccusto_fundo_fixo.cod_ccusto NO-UNDO.

    DEF VAR c_codEstabel                     LIKE int_dp_fundo_fixo.cod_estab         NO-UNDO.
    /************************** Variable Definition End *************************/
         /*** Campos tabela de integraá∆o 
         
            int_dp_fundo_fixo.cod_ccusto 
            int_dp_fundo_fixo.cod_docto 
            int_dp_fundo_fixo.cod_empresa 
            int_dp_fundo_fixo.cod_estab 
            int_dp_fundo_fixo.situacao 
            int_dp_fundo_fixo.cod_unid_negoc 
            int_dp_fundo_fixo.cta_ctbl 
            int_dp_fundo_fixo.dat_movto 
            int_dp_fundo_fixo.des_historico 
            int_dp_fundo_fixo.natureza 
            int_dp_fundo_fixo.num_id_ffixo 
            int_dp_fundo_fixo.tipo_movto 
            int_dp_fundo_fixo.val_movto 
        
        ***************/
        
        
         IF AVAIL int_ds_param_fundo_fixo THEN
            ASSIGN c-cta-ctbl = int_ds_param_fundo_fixo.cta_ctbl.

         IF int_dp_fundo_fixo.tipo_movto = "D" THEN
            ASSIGN v_tipo_movto = "SAI".
         ELSE
            ASSIGN v_tipo_movto = "ENT".

         ASSIGN v_num_seq_movto = 1.
           
         FOR LAST movto_cta_corren NO-LOCK WHERE
                  movto_cta_corren.cod_cta_corren       = v_cod_cta_corren AND 
                  movto_cta_corren.dat_movto_cta_corren = int_dp_fundo_fixo.dat_movto  
                 BY movto_cta_corren.num_seq_movto_cta_corren DESC:
                
            ASSIGN v_num_seq_movto = movto_cta_corren.num_seq_movto_cta_corren + 1.
                  
         END.
         
         FOR LAST tt_movto_cta_corren_import NO-LOCK WHERE
                  tt_movto_cta_corren_import.tta_cod_cta_corren        = v_cod_cta_corren AND 
                  tt_movto_cta_corren_import.tta_dat_movto_cta_corren  = int_dp_fundo_fixo.dat_movto  
               BY tt_movto_cta_corren_import.tta_num_seq_movto_cta_corren DESC:
                
               ASSIGN v_num_seq_movto = tt_movto_cta_corren_import.tta_num_seq_movto_cta_corren + 1.
                  
         END.

        /*** Temp Table Movimento ***/
        
        create tt_movto_cta_corren_import.
        assign tt_movto_cta_corren_import.ttv_ind_erro_valid             = "N∆o" /*l_nao*/ 
               tt_movto_cta_corren_import.tta_num_seq_movto_cta_corren   = v_num_seq_movto
               tt_movto_cta_corren_import.tta_cod_cta_corren             = v_cod_cta_corren                 /* Conta Corrente        */
               tt_movto_cta_corren_import.tta_dat_movto_cta_corren       = int_dp_fundo_fixo.dat_movto      /* Data Movto            */
               tt_movto_cta_corren_import.tta_ind_tip_movto_cta_corren   = "RE"                             /* Tipo movto Cta Corren */
               tt_movto_cta_corren_import.tta_cod_tip_trans_cx           = int_ds_param_fundo_fixo.cod_tip_trans_cx  /* Tipo Trans Caixa      */
               tt_movto_cta_corren_import.tta_ind_fluxo_movto_cta_corren = v_tipo_movto                     /* Fluxo - int_dp_fundo_fixo.tipo_movto  */
               tt_movto_cta_corren_import.tta_cod_cenar_ctbl             = ""                               /* Cen†rio Cont†bil       */
               tt_movto_cta_corren_import.tta_des_histor_padr            = int_dp_fundo_fixo.des_historico  /* Hist¢rico              */
               tt_movto_cta_corren_import.tta_val_movto_cta_corren       = int_dp_fundo_fixo.val_movto      /* Valor Movimento        */ 
               tt_movto_cta_corren_import.tta_cod_docto_movto_cta_bco    = int_dp_fundo_fixo.cod_docto      /* Documento              */ 
               tt_movto_cta_corren_import.tta_cod_modul_dtsul            = "CMG"                            /* M¢dulo                 */
               tt_movto_cta_corren_import.tta_num_id_movto_cta_corren    = 0 
               tt_movto_cta_corren_import.ttv_rec_movto_cta_corren       = recid(tt_movto_cta_corren_import)
               v_rec_cta_corren                                          = recid(tt_movto_cta_corren_import)
               v_cod_cta_corren                                          = tt_movto_cta_corren_import.tta_cod_cta_corren. 

        create tt_movto_ffixo.
        ASSIGN tt_movto_ffixo.ttv_rec_movto_cta_corren = recid(tt_movto_cta_corren_import)
               tt_movto_ffixo.ttv_num_id_ffixo         = int(int_dp_fundo_fixo.cod_docto).  
            
       /* ** Temp Table das apropriaá‰es ***/
        IF int_dp_fundo_fixo.cod_estab = "401" THEN
             ASSIGN c_codEstabel =  "014".
        ELSE ASSIGN c_codEstabel =  int_dp_fundo_fixo.cod_estab.


       FIND FIRST int_ds_ccusto_fundo_fixo NO-LOCK WHERE
                  int_ds_ccusto_fundo_fixo.cod_empresa = int_ds_param_fundo_fixo.cod_empresa AND 
                  int_ds_ccusto_fundo_fixo.cod_estab   = int_dp_fundo_fixo.cod_estab NO-ERROR.
       IF AVAIL int_ds_ccusto_fundo_fixo THEN
          ASSIGN c-cod-ccusto =  int_ds_ccusto_fundo_fixo.cod_ccusto.
                      
       create tt_aprop_ctbl_cmg_imp.
       assign tt_aprop_ctbl_cmg_imp.ttv_rec_aprop_ctbl_cmg    = recid(tt_aprop_ctbl_cmg_imp)
              v_rec_aprop_ctbl_cmg                            = tt_aprop_ctbl_cmg_imp.ttv_rec_aprop_ctbl_cmg
              tt_aprop_ctbl_cmg_imp.tta_ind_natur_lancto_ctbl = int_dp_fundo_fixo.natureza     /* Natureza        */
              tt_aprop_ctbl_cmg_imp.tta_cod_plano_cta_ctbl    = "PADRAO"                       /* Plano Contas    */
              tt_aprop_ctbl_cmg_imp.tta_cod_cta_ctbl          = c-cta-ctbl                     /* Cta Ctbl        */
              tt_aprop_ctbl_cmg_imp.tta_cod_estab             = int_dp_fundo_fixo.cod_estab    /* Estabelecimento */
              tt_aprop_ctbl_cmg_imp.tta_cod_unid_negoc        =  "000"                         /* Unid Negoc      */
              tt_aprop_ctbl_cmg_imp.tta_cod_plano_ccusto      =  "PADRAO"                      /* Plano CCusto    */ 
              tt_aprop_ctbl_cmg_imp.tta_cod_ccusto            =   c-cod-ccusto                 /* Centro Custo    */ 
              tt_aprop_ctbl_cmg_imp.tta_val_movto_cta_corren  = int_dp_fundo_fixo.val_movto    /* Valor Aprop     */
              tt_aprop_ctbl_cmg_imp.tta_cod_estab             = int_dp_fundo_fixo.cod_estab    /* Estabelecimento */    
              tt_aprop_ctbl_cmg_imp.ttv_rec_movto_cta_corren = v_rec_cta_corren
              tt_aprop_ctbl_cmg_imp.ttv_rec_aprop_ctbl_cmg   = v_rec_aprop_ctbl_cmg.
             
                  
        /* ** Temp Table dos valores ***/

        create tt_val_aprop_ctbl_cmg_import.
        assign tt_val_aprop_ctbl_cmg_import.ttv_rec_movto_cta_corren   = v_rec_cta_corren
               tt_val_aprop_ctbl_cmg_import.ttv_rec_aprop_ctbl_cmg     = v_rec_aprop_ctbl_cmg
               tt_val_aprop_ctbl_cmg_import.ttv_rec_val_aprop_ctbl_cmg = recid(tt_val_aprop_ctbl_cmg_import)            
               tt_val_aprop_ctbl_cmg_import.tta_cod_finalid_econ       = "Corrente" /* Finalidade    */
               tt_val_aprop_ctbl_cmg_import.tta_dat_cotac_indic_econ   = int_dp_fundo_fixo.dat_movto  /* Data Cotaá∆o  */
               tt_val_aprop_ctbl_cmg_import.tta_val_cotac_indic_econ   =  1             /* Valor Cotaá∆o */
               tt_val_aprop_ctbl_cmg_import.tta_val_movto_cta_corren   =  tt_aprop_ctbl_cmg_imp.tta_val_movto_cta_corren * tt_val_aprop_ctbl_cmg_import.tta_val_cotac_indic_econ. 
    
END PROCEDURE. /* pi_cria_tt_movto_import */

