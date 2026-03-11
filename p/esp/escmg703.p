/*****************************************************************************
** KML SISTEMAS
**
** Cliente...............: NISSEI
** Programa..............: escmg703
** Descricao.............: Importaá∆o Movimento Conta Corrente - Aplicaá‰es e Resgates
** Versao................:  1.00.00.000
** Procedimento..........: tar_import_movto_cmg
** Nome Externo..........: esp/escmg703
** Criado por............: Eduardo Marcel Barth (edu_barth@hotmail.com)
** Criado em.............: 01/08/2023
******************************************************************************/
DEF BUFFER histor_exec_especial FOR ems5.histor_exec_especial.
DEF BUFFER empresa FOR ems5.empresa.

/*-- Filtro Multi-idioma Aplicado --*/

def var c-versao-prg as char initial " 1.00.00.000":U no-undo.
def var c-versao-rcode as char initial "[[[1.00.00.000[[[":U no-undo. /* Controle de Versao R-CODE - Nao retirar do Fonte */
DEF VAR h_facelift AS HANDLE NO-UNDO.

{include/i_dbinst.i}
{include/i_dbtype.i}

{include/i_fcldef.i}
{include/i_trddef.i}

{utp/ut-glob.i}

/******************************* Private-Data *******************************/
assign this-procedure:private-data = "HLP=35":U.
/*************************************  *************************************/

/********************* Temporary Table Definition Begin *********************/

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
          ttv_rec_val_aprop_ctbl_cmg       ascending
    .



/********************** Temporary Table Definition End **********************/

/************************** Stream Definition Begin *************************/

def new shared stream s_1.


/*************************** Stream Definition End **************************/

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
    &if "{&FNC_MULTI_IDIOMA}" = "YES" &then
    list-item-pairs "",""
    &else
    list-items ""
    &endif
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
def var v_hra_execution
    as Character
    format "99:99":U
    no-undo.
def new shared var v_log_cancel
    as logical
    format "Sim/N∆o"
    initial yes
    label "Cancelado"
    column-label "Cancelado"
    no-undo.
def var v_log_method
    as logical
    format "Sim/N∆o"
    initial yes
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
    bgcolor 15 font 2 drop-target
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
def var v_nom_prog_ext
    as character
    format "x(8)":U
    label "Nome Externo"
    no-undo.
def var v_nom_report_title
    as character
    format "x(40)":U
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
def var v_rec_log
    as recid
    format ">>>>>>9":U
    no-undo.
def var v_wgh_focus
    as widget-handle
    format ">>>>>>9":U
    no-undo.
def var v_wgh_frame
    as widget-handle
    format ">>>>>>9":U
    no-undo.
def var v_wgh_label
    as widget-handle
    format ">>>>>>9":U
    no-undo.
def var v_cod_dir_temp                   as character       no-undo. /*local*/
def var v_cod_return                     as character       no-undo. /*local*/
def var v_hdl_text                       as handle          no-undo. /*local*/
def var v_num_list                       as integer         no-undo. /*local*/


/************************** Variable Definition End *************************/

/*************************** Menu Definition Begin **************************/

.

def menu      m_help                menubar
    menu-item mi_conteudo           label "&Conte£do"
    menu-item mi_sobre              label "&Sobre".



/**************************** Menu Definition End ***************************/

/************************ Rectangle Definition Begin ************************/

def rectangle rt_001
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


/************************* Rectangle Definition End *************************/

/************************** Image Definition Begin **************************/

def image im_fld_page_1
    file "image/im-fldup":U
    size 15.72 by 01.21.

/*************************** Image Definition End ***************************/

/************************** Button Definition Begin *************************/

def button bt_can
    label "Cancela"
    tooltip "Cancela"
    size 1 by 1
    auto-endkey.
def button bt_get_file
    label "Pesquisa Arquivo"
    tooltip "Pesquisa Arquivo"
    image-up file "image/im-sea1"
    image-insensitive file "image/ii-sea1"
    size 1 by 1.
def button bt_hel2
    label "Ajuda"
    tooltip "Ajuda"
    size 1 by 1.
def button bt_ok
    label "OK"
    tooltip "OK"
    size 1 by 1
    auto-go.

/****************************** Function Button *****************************/

/*************************** Button Definition End **************************/

/************************** Report Definition Begin *************************/

def new shared var v_rpt_s_1_lines as integer initial 66.
def new shared var v_rpt_s_1_columns as integer initial 132.
def new shared var v_rpt_s_1_bottom as integer initial 65.
def new shared var v_rpt_s_1_page as integer.
def new shared var v_rpt_s_1_name as character initial "Relat¢rio Importaá∆o Movtos Aplicaá∆o".
/*************************** Report Definition End **************************/

/************************** Frame Definition Begin **************************/

def frame f8_imp01_movto_cta_corren_import
    rt_folder
         at row 02.50 col 02.00 bgcolor 8 
    rt_folder_right
         at row 02.58 col 72.00 bgcolor 7 
    rt_folder_left
         at row 02.58 col 02.14 bgcolor 15 
    rt_cxcf
         at row 12.33 col 02.00 bgcolor 7 
    rt_folder_bottom
         at row 11.79 col 02.14 bgcolor 7 
    rt_folder_top
         at row 02.54 col 02.14 bgcolor 15 
    im_fld_page_1
         at row 01.50 col 02.29
    bt_ok
         at row 12.54 col 03.00 font ?
         help "OK"
    bt_can
         at row 12.54 col 14.00 font ?
         help "Cancela"
    bt_hel2
         at row 12.54 col 61.57 font ?
         help "Ajuda"
    with 1 down side-labels no-validate keep-tab-order three-d
         size-char 74.00 by 14.17
         view-as dialog-box
         font 1 fgcolor ? bgcolor 8
         title "Importaá∆o Excel Movimentos da Aplicaá∆o".
    /* adjust size of objects in this frame */
    assign bt_can:width-chars            in frame f8_imp01_movto_cta_corren_import = 10.00
           bt_can:height-chars           in frame f8_imp01_movto_cta_corren_import = 01.00
           bt_hel2:width-chars           in frame f8_imp01_movto_cta_corren_import = 10.00
           bt_hel2:height-chars          in frame f8_imp01_movto_cta_corren_import = 01.00
           bt_ok:width-chars             in frame f8_imp01_movto_cta_corren_import = 10.00
           bt_ok:height-chars            in frame f8_imp01_movto_cta_corren_import = 01.00
           im_fld_page_1:width-chars     in frame f8_imp01_movto_cta_corren_import = 15.72
           im_fld_page_1:height-chars    in frame f8_imp01_movto_cta_corren_import = 01.21
           rt_cxcf:width-chars           in frame f8_imp01_movto_cta_corren_import = 70.57
           rt_cxcf:height-chars          in frame f8_imp01_movto_cta_corren_import = 01.42
           rt_folder:width-chars         in frame f8_imp01_movto_cta_corren_import = 70.57
           rt_folder:height-chars        in frame f8_imp01_movto_cta_corren_import = 09.46
           rt_folder_bottom:width-chars  in frame f8_imp01_movto_cta_corren_import = 70.29
           rt_folder_bottom:height-chars in frame f8_imp01_movto_cta_corren_import = 00.13
           rt_folder_left:width-chars    in frame f8_imp01_movto_cta_corren_import = 00.43
           rt_folder_left:height-chars   in frame f8_imp01_movto_cta_corren_import = 09.17
           rt_folder_right:width-chars   in frame f8_imp01_movto_cta_corren_import = 00.43
           rt_folder_right:height-chars  in frame f8_imp01_movto_cta_corren_import = 09.25
           rt_folder_top:width-chars     in frame f8_imp01_movto_cta_corren_import = 70.29
           rt_folder_top:height-chars    in frame f8_imp01_movto_cta_corren_import = 00.13.
    /* set private-data for the help system */
    assign im_fld_page_1:private-data in frame f8_imp01_movto_cta_corren_import = "HLP=000023629":U
           bt_ok:private-data         in frame f8_imp01_movto_cta_corren_import = "HLP=000010721":U
           bt_can:private-data        in frame f8_imp01_movto_cta_corren_import = "HLP=000011050":U
           bt_hel2:private-data       in frame f8_imp01_movto_cta_corren_import = "HLP=000011326":U
           frame f8_imp01_movto_cta_corren_import:private-data                  = "HLP=000023629".

def frame f_fld_01_movto_cta_corren_import
    v_nom_filename_import 
         at row 03.25 col 11.00 colon-aligned label "Planilha"
         help "Planilha Excel com os dados para importaá∆o"
         view-as editor max-chars 250 no-word-wrap
         size 50 by 1
         bgcolor 15 font 2
    bt_get_file
         at row 03.21 col 63.00 font ?
         help "Pesquisa Arquivo"
    with 1 down side-labels no-validate keep-tab-order three-d
         size-char 69.14 by 09.08
         at row 04.54 col 02.00 no-box
         font 1 fgcolor ? bgcolor 8.
    /* adjust size of objects in this frame */
    assign bt_get_file:width-chars  in frame f_fld_01_movto_cta_corren_import = 04.00
           bt_get_file:height-chars in frame f_fld_01_movto_cta_corren_import = 01.08
           .
    /* set return-inserted = yes for editors */
    assign v_nom_filename_import:return-inserted in frame f_fld_01_movto_cta_corren_import = yes.

{include/i_fclfrm.i f8_imp01_movto_cta_corren_import f_fld_01_movto_cta_corren_import }
/*************************** Frame Definition End ***************************/

/*********************** User Interface Trigger Begin ***********************/

ON ENTRY OF v_nom_filename_import IN FRAME f_fld_01_movto_cta_corren_import
do:
    IF v_nom_filename_import:screen-value in frame f_fld_01_movto_cta_corren_import BEGINS "<" THEN
        ASSIGN v_nom_filename_import:screen-value in frame f_fld_01_movto_cta_corren_import = "".
end.

ON DROP-FILE-NOTIFY OF v_nom_filename_import IN FRAME f_fld_01_movto_cta_corren_import
do:

    assign v_nom_filename_import:screen-value in frame f_fld_01_movto_cta_corren_import = v_nom_filename_import:GET-DROPPED-FILE(1).
    v_nom_filename_import:END-FILE-DROP().

end.

ON MOUSE-SELECT-CLICK OF im_fld_page_1 IN FRAME f8_imp01_movto_cta_corren_import
DO:

    if  im_fld_page_1:load-image('image/im-fldup')
    then do: end /* if */.
    assign im_fld_page_1:height = 1.20
           im_fld_page_1:row    = 1.45.
    view frame f_fld_01_movto_cta_corren_import.
END.


ON CHOOSE OF bt_get_file IN FRAME f_fld_01_movto_cta_corren_import
DO:

    system-dialog get-file v_nom_filename_import
        title "Importar Movimentos de Conta Corrente..." /*l_import_movto_cta_corren*/ 
        filters '*.xls*' '*.xls*'
        must-exist.

    display v_nom_filename_import
            with frame f_fld_01_movto_cta_corren_import.
END. /* ON CHOOSE OF bt_get_file IN FRAME f_fld_01_movto_cta_corren_import */


/************************ User Interface Trigger End ************************/

/**************************** Frame Trigger Begin ***************************/


ON GO OF FRAME f8_imp01_movto_cta_corren_import
DO:

END. /* ON GO OF FRAME f8_imp01_movto_cta_corren_import */

ON ENDKEY OF FRAME f8_imp01_movto_cta_corren_import
DO:


END. /* ON ENDKEY OF FRAME f8_imp01_movto_cta_corren_import */

ON HELP OF FRAME f8_imp01_movto_cta_corren_import ANYWHERE
DO:


    /* Begin_Include: i_context_help */
    run prgtec/men/men900za.py (Input self:handle,
                                Input this-procedure:handle) /*prg_fnc_chamar_help_context*/.
    /* End_Include: i_context_help */

END. /* ON HELP OF FRAME f8_imp01_movto_cta_corren_import */

ON RIGHT-MOUSE-DOWN OF FRAME f8_imp01_movto_cta_corren_import ANYWHERE
DO:


    /* Begin_Include: i_right_mouse_down_dialog_box */
    if  (self:type <> "DIALOG-BOX" /*l_dialog_box*/ )
    and (self:type <> "FRAME" /*l_frame*/      )
    and (self:type <> "text" /*l_text*/       )
    and (self:type <> "IMAGE" /*l_image*/      )
    and (self:type <> "RECTANGLE" /*l_rectangle*/  )
    then do:

        assign v_wgh_frame = self:parent.

        if  self:type        = "fill-in" /*l_fillin*/ 
        and v_wgh_frame:type = "Browse" /*l_browse*/  then
            return no-apply.

        if  valid-handle(self:popup-menu) = yes then
            return no-apply.

        assign v_wgh_frame = self:frame.

        if  (v_wgh_frame:type <> "DIALOG-BOX" /*l_dialog_box*/ ) and (v_wgh_frame:frame <> ?)
        then do:
               assign v_wgh_frame     = v_wgh_frame:frame.
        end /* if */.
        assign v_nom_title_aux    = v_wgh_frame:title
               v_wgh_frame:title  = self:help.
    end /* if */.
    /* End_Include: i_right_mouse_down_dialog_box */


END. /* ON RIGHT-MOUSE-DOWN OF FRAME f8_imp01_movto_cta_corren_import */

ON RIGHT-MOUSE-UP OF FRAME f8_imp01_movto_cta_corren_import ANYWHERE
DO:


    /* Begin_Include: i_right_mouse_up_dialog_box */
    if  (self:type <> "DIALOG-BOX" /*l_dialog_box*/ )
    and (self:type <> "FRAME" /*l_frame*/      )
    and (self:type <> "text" /*l_text*/       )
    and (self:type <> "IMAGE" /*l_image*/      )
    and (self:type <> "RECTANGLE" /*l_rectangle*/  )
    then do:

        assign v_wgh_frame = self:parent.

        if  self:type        = "fill-in" /*l_fillin*/ 
        and v_wgh_frame:type = "Browse" /*l_browse*/  then
            return no-apply.

        if  valid-handle(self:popup-menu) = yes then
            return no-apply.

        assign v_wgh_frame        = self:frame.
        if  (v_wgh_frame:type <> "DIALOG-BOX" /*l_dialog_box*/ ) and (v_wgh_frame:frame <> ?)
        then do:
               assign v_wgh_frame     = v_wgh_frame:frame.
        end /* if */.
        assign v_wgh_frame:title  = v_nom_title_aux.
    end /* if */.

    /* End_Include: i_right_mouse_up_dialog_box */

END. /* ON RIGHT-MOUSE-UP OF FRAME f8_imp01_movto_cta_corren_import */

ON WINDOW-CLOSE OF FRAME f8_imp01_movto_cta_corren_import
DO:

    apply "end-error" to self.
END. /* ON WINDOW-CLOSE OF FRAME f8_imp01_movto_cta_corren_import */


/***************************** Frame Trigger End ****************************/

/**************************** Menu Trigger Begin ****************************/


ON CHOOSE OF MENU-ITEM mi_conteudo IN MENU m_help
DO:


        apply "choose" to bt_hel2 in frame f8_imp01_movto_cta_corren_import.





END. /* ON CHOOSE OF MENU-ITEM mi_conteudo IN MENU m_help */

ON CHOOSE OF MENU-ITEM mi_sobre IN MENU m_help
DO:

    /************************* Variable Definition Begin ************************/

    def var v_cod_release
        as character
        format "x(12)":U
        no-undo.
    def var v_nom_prog
        as character
        format "x(8)":U
        no-undo.
    def var v_nom_prog_ext
        as character
        format "x(8)":U
        label "Nome Externo"
        no-undo.


    /************************** Variable Definition End *************************/


        assign v_nom_prog     = substring(frame f8_imp01_movto_cta_corren_import:title, 1, max(1, length(frame f8_imp01_movto_cta_corren_import:title) - 10)).
        if  v_nom_prog = ? then
            assign v_nom_prog = "".

        assign v_nom_prog     = v_nom_prog
                              + chr(10)
                              + "escmg703":U.




    assign v_nom_prog_ext = "esp/escmg703.p":U
           v_cod_release  = trim(" 1.00.00.000":U).
    {include/sobre5.i}

END. /* ON CHOOSE OF MENU-ITEM mi_sobre IN MENU m_help */


/***************************** Menu Trigger End *****************************/


/****************************** Main Code Begin *****************************/


/* Begin_Include: i_version_extract */
{include/i-ctrlrp5.i escmg703}


def new global shared var v_cod_arq
    as char  
    format 'x(60)'
    no-undo.
def new global shared var v_cod_tip_prog
    as character
    format 'x(8)'
    no-undo.

def stream s-arq.

if  v_cod_arq <> '' and v_cod_arq <> ?
then do:
    run pi_version_extract ('escmg703':U, 'esp/escmg703.p':U, '1.00.00.000':U, 'pro':U).
end /* if */.
/* End_Include: i_version_extract */

run prgtec/btb/btb906za.py /*prg_fnc_verify_controls*/.
if  v_cod_dwb_user = ""
then do:
    assign v_cod_dwb_user = v_cod_usuar_corren.
end /* if */.

/* Begin_Include: i_verify_security */
run prgtec/men/men901za.py (Input 'escmg703') /*prg_fnc_verify_security*/.
if  return-value = "2014"
then do:
    /* Programa a ser executado n∆o Ç um programa v†lido Datasul ! */
    run pi_messages (input "show",
                     input 2014,
                     input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9",
                                       'escmg703')) /*msg_2014*/.
    return.
end /* if */.
if  return-value = "2012"
then do:
    /* Usu†rio sem permiss∆o para acessar o programa. */
    run pi_messages (input "show",
                     input 2012,
                     input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9",
                                       'escmg703')) /*msg_2012*/.
    return.
end /* if */.
/* End_Include: i_verify_security */



/* Begin_Include: i_log_exec_prog_dtsul_ini */
assign v_rec_log = ?.

if can-find(prog_dtsul
       where prog_dtsul.cod_prog_dtsul = 'escmg703' 
         and prog_dtsul.log_gera_log_exec = yes) then do transaction:
    create log_exec_prog_dtsul.
    assign log_exec_prog_dtsul.cod_prog_dtsul           = 'escmg703'
           log_exec_prog_dtsul.cod_usuario              = v_cod_usuar_corren
           log_exec_prog_dtsul.dat_inic_exec_prog_dtsul = today
           log_exec_prog_dtsul.hra_inic_exec_prog_dtsul = replace(string(time,"hh:mm:ss" /*l_hh:mm:ss*/ ),":":U,"":U).
    assign v_rec_log = recid(log_exec_prog_dtsul).
    release log_exec_prog_dtsul no-error.
end.


/* End_Include: i_log_exec_prog_dtsul_ini */



/* Begin_Include: ix_p00_imp_movto_cta_corren */

/* Begin_Include: i_declara_GetEntryField */
FUNCTION GetEntryField RETURNS CHARACTER (input p_num_posicao     AS INTEGER,
                                          INPUT p_cod_campo       AS CHARACTER,
                                          input p_cod_separador   AS CHARACTER):

/* ************* Parametros da FUNÄ«O *******************************
** Funá∆o para tratamento dos Entries dos c¢digos livres
** 
**  p_num_posicao     - N£mero do Entry que ser† atualizado
**  p_cod_campo       - Campo / Vari†vel que ser† atualizada
**  p_cod_separador   - Separador que ser† utilizado
*******************************************************************/

    if  p_num_posicao <= 0  then do:
        assign p_num_posicao  = 1.
    end.
    if num-entries(p_cod_campo,p_cod_separador) >= p_num_posicao  then do:
       return entry(p_num_posicao,p_cod_campo,p_cod_separador).
    end.
    return "" /*l_*/ .

END FUNCTION.

/* End_Include: i_declara_GetEntryField */
.

/* Begin_Include: i_declara_SetEntryField */
FUNCTION SetEntryField RETURNS CHARACTER (input p_num_posicao     AS INTEGER,
                                          input p_cod_campo       AS CHARACTER,
                                          input p_cod_separador   AS CHARACTER,
                                          input p_cod_valor       AS CHARACTER):

/* ************* Parametros da FUNÄ«O *******************************
** Funá∆o para tratamento dos Entries dos c¢digos livres
** 
**  p_num_posicao     - N£mero do Entry / Posiá∆o que ser† atualizado
**  p_cod_campo       - Campo / Vari†vel que ser† atualizada
**  p_cod_separador   - Separador que ser† utilizado
**  p_cod_valor       - Valor que ser† atualizado no Entry passado 
*******************************************************************/

    def var v_num_cont        as integer initial 0 no-undo.
    def var v_num_entries_ini as integer initial 0 no-undo.

    /* ** No progress a menor Entry Ç 1 ***/
    if p_num_posicao <= 0 then 
       assign p_num_posicao = 1.       

    /* ** Caso o Campo contenha um valor inv†lido, este valor ser† convertido para Branco
         para possibilitar os c†lculo ***/
    if p_cod_campo = ? then do:
       assign p_cod_campo = "" /* l_*/ .
    end.

    assign v_num_entries_ini = num-entries(p_cod_campo,p_cod_separador) + 1 .    
    if p_cod_campo = "" /* l_*/  then do:
       assign v_num_entries_ini = 2.
    end.

    do v_num_cont =  v_num_entries_ini to p_num_posicao :
       assign p_cod_campo = p_cod_campo + p_cod_separador.
    end.

    assign entry(p_num_posicao,p_cod_campo,p_cod_separador) = p_cod_valor.

    RETURN p_cod_campo.

END FUNCTION.


/* End_Include: i_declara_SetEntryField */

/* redefiniá‰es do frame */

/* Begin_Include: i_std_dialog_box */
/* tratamento do titulo e vers∆o */
assign frame f8_imp01_movto_cta_corren_import:title = frame f8_imp01_movto_cta_corren_import:title
                            + chr(32)
                            + chr(40)
                            + trim(" 1.00.00.000":U)
                            + chr(41).
/* menu pop-up de ajuda e sobre */
assign menu m_help:popup-only = yes
       bt_hel2:popup-menu in frame f8_imp01_movto_cta_corren_import = menu m_help:handle.


/* End_Include: i_std_dialog_box */
{include/title5.i f8_imp01_movto_cta_corren_import FRAME}


/* Inicializa vari†veis */
find empresa no-lock
     where empresa.cod_empresa = v_cod_empres_usuar /*cl_empres_usuar of empresa*/ no-error.
assign v_cod_dwb_proced    = "tar_import_movto_cmg":U
       v_cod_dwb_program   = "tar_import_movto_cmg":U
       v_cod_release       = trim(" 1.00.00.000":U).
if  avail empresa
then do:
    assign v_nom_enterprise = empresa.nom_razao_social.
end /* if */.
else do:
    assign v_nom_enterprise = 'DATASUL'.
end /* else */.

create text v_wgh_label
    assign format       = 'x(11)'
           screen-value = "ParÉmetros" /*l_parÉmetros*/ 
           frame        = frame f8_imp01_movto_cta_corren_import:handle
           width        = 13
           row          = 1.7
           col          = 4
       triggers:
&if '{&window-system}' <> 'TTY' &then
           on  mouse-select-click
               apply "mouse-select-click" to im_fld_page_1 in frame f8_imp01_movto_cta_corren_import.
&endif
       end.
{include/i_fcldin.i v_wgh_label }

assign frame f_fld_01_movto_cta_corren_import:frame  = frame f8_imp01_movto_cta_corren_import:handle
       frame f_fld_01_movto_cta_corren_import:row    = 2.7
       frame f_fld_01_movto_cta_corren_import:col    = 2.5.

/* ix_p10_imp_movto_cta_corren */

pause 0 before-hide.
view frame f8_imp01_movto_cta_corren_import.


main_block:
do on endkey undo main_block, leave main_block
               on error undo main_block, leave main_block with frame f8_imp01_movto_cta_corren_import:

    /* ix_p20_imp_movto_cta_corren */

    blk_trans:
    do transaction:

        enable all with frame f8_imp01_movto_cta_corren_import.
        
        apply "mouse-select-click" to im_fld_page_1.

        display v_nom_filename_import
                with frame f_fld_01_movto_cta_corren_import.

        enable bt_get_file
               v_nom_filename_import
               with frame f_fld_01_movto_cta_corren_import.

        assign v_wgh_focus = v_nom_filename_import:handle in frame f_fld_01_movto_cta_corren_import.

        assign v_nom_filename_import:screen-value in frame f_fld_01_movto_cta_corren_import = "< Vocà pode arrastar e soltar o arquivo aqui >".

        wait-for go of frame f8_imp01_movto_cta_corren_import.


        assign input frame f_fld_01_movto_cta_corren_import v_nom_filename_import.

        run pi_filename_validation( input v_nom_filename_import ).
        if  return-value <> "OK" then do:
            run pi_messages (input "show",
                             input 524,
                             input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9",
                                               'Arquivo inv†lido')).
            
            undo main_block, retry main_block.
        end.
        
    end /* do blk_trans */.

    assign v_log_method       = session:set-wait-state('general')
           v_nom_report_title = fill(" ", 40 - length(v_rpt_s_1_name)) + v_rpt_s_1_name.

    assign v_nom_filename   = session:temp-directory + "escmg703":U + '.tmp'
           v_rpt_s_1_bottom = v_rpt_s_1_bottom - v_rpt_s_1_lines + 66
           v_rpt_s_1_lines  = 66.
    output stream s_1 to value(v_nom_filename)
           paged page-size value(v_rpt_s_1_lines) convert target 'iso8859-1'.

    assign v_nom_prog_ext  = caps(substring("esp/escmg703.p", 12, 8))
           v_dat_execution = today
           v_hra_execution = replace(string(time, "hh:mm:ss" /*l_hh:mm:ss*/ ), ":", "").

    run pi_imp_movto_cta_corren /*pi_imp_movto_cta_corren*/.

    assign v_log_method = session:set-wait-state("").
        
end /* do main_block */.

hide frame f8_imp01_movto_cta_corren_import.


/******************************* Main Code End ******************************/

/************************* Internal Procedure Begin *************************/

/*****************************************************************************
** Procedure Interna.....: pi_filename_validation
*****************************************************************************/
PROCEDURE pi_filename_validation:

    /************************ Parameter Definition Begin ************************/

    def Input param p_cod_filename
        as character
        format "x(40)"
        no-undo.


    /************************* Parameter Definition End *************************/

    /************************* Variable Definition Begin ************************/

    def var v_cod_1                          as character       no-undo. /*local*/
    def var v_cod_2                          as character       no-undo. /*local*/
    def var v_num_1                          as integer         no-undo. /*local*/
    def var v_num_2                          as integer         no-undo. /*local*/


    /************************** Variable Definition End *************************/

    if  p_cod_filename = "" or p_cod_filename = "."
    then do:
        return "NOK" /*l_nok*/ .
    end /* if */.

    assign v_cod_1 = replace(p_cod_filename, "~\", "/").

    1_block:
    repeat v_num_1 = 1 to length(v_cod_1):
        if  index('abcdefghijklmnopqrstuvwxyz0123456789-_:/. ', substring(v_cod_1, v_num_1, 1)) = 0
        then do:
            return "NOK" /*l_nok*/ .
        end /* if */.
    end /* repeat 1_block */.

    if  num-entries(v_cod_1, ":") > 2
    then do:
        return "NOK" /*l_nok*/ .
    end /* if */.

    if  num-entries(v_cod_1, ":") = 2 and length(entry(1,v_cod_1,":")) > 1
    then do:
        return "NOK" /*l_nok*/ .
    end /* if */.

    if  index(entry(num-entries(v_cod_1, "/"),v_cod_1, "/"),".") = 0
    then do:
        return "NOK" /*l_nok*/ .
    end /* if */.

    if  search(v_cod_1) = ? then do:
        return "NOK".
    end.

    return "OK" /*l_ok*/ .
END PROCEDURE. /* pi_filename_validation */

/*****************************************************************************
** Procedure Interna.....: pi_show_report_2
*****************************************************************************/
PROCEDURE pi_show_report_2:

    /************************ Parameter Definition Begin ************************/

    def Input param p_cod_dwb_file
        as character
        format "x(40)"
        no-undo.


    /************************* Parameter Definition End *************************/

    /************************* Variable Definition Begin ************************/

    def var v_cod_key_value
        as character
        format "x(8)":U
        no-undo.


    /************************** Variable Definition End *************************/

    get-key-value section 'EMS' key 'Show-Report-Program' value v_cod_key_value.
    if  v_cod_key_value = ""
    or   v_cod_key_value = ?
    then do:
        assign v_cod_key_value = 'notepad.exe'.
        put-key-value section 'EMS' key 'Show-Report-Program' value v_cod_key_value no-error.
    end /* if */.

    run winexec (input v_cod_key_value + chr(32) + p_cod_dwb_file, input 1).

    END PROCEDURE.

    PROCEDURE WinExec EXTERNAL 'kernel32.dll':
      DEF INPUT  PARAM prg_name                          AS CHARACTER.
      DEF INPUT  PARAM prg_style                         AS SHORT.

END PROCEDURE. /* pi_show_report_2 */

/*****************************************************************************
** Procedure Interna.....: pi_imp_movto_cta_corren
*****************************************************************************/
PROCEDURE pi_imp_movto_cta_corren:

    /************************** Buffer Definition Begin *************************/

    /*************************** Buffer Definition End **************************/

    movto_block:
    for each tt_movto_cta_corren_import exclusive-lock:
        delete tt_movto_cta_corren_import.
    end /* for movto_block */.

    aprop_block:
    for each tt_aprop_ctbl_cmg_imp exclusive-lock:
        delete tt_aprop_ctbl_cmg_imp.
    end /* for aprop_block */.

    movto_valid_block:
    for each tt_import_movto_valid exclusive-lock:
        delete tt_import_movto_valid.
    end /* for movto_valid_block */.

    movto_valid_block_2:
    for each tt_import_movto_valid_cmg exclusive-lock:
        delete tt_import_movto_valid_cmg.
    end /* for movto_valid_block_2 */.

    val_aprop:
    for each tt_val_aprop_ctbl_cmg_import exclusive-lock:
        delete tt_val_aprop_ctbl_cmg_import.
    end /* for val_aprop */.

    run pi_cria_tt_movto_import.
    
    if  return-value = "OK" then do:
        run prgfin/cmg/cmg719zf.py (Input 1,
                                    Input yes,
                                    Input yes,
                                    input-output table tt_movto_cta_corren_import,
                                    Input table tt_aprop_ctbl_cmg_imp,
                                    Input table tt_val_aprop_ctbl_cmg_import,
                                    Input table tt_rat_financ_cmg_import,
                                    output table tt_import_movto_valid_cmg) /*prg_api_movto_cta_corren_import_recebto_2*/. 
        if  return-value = '2782'
        then do:
            /* Vers∆o de integraá∆o incorreta ! */
            run pi_messages (input "show",
                             input 2782,
                             input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")) /*msg_2782*/.
          
            return error.
        end.

        output stream s_1 close.

        if  can-find(first tt_import_movto_valid_cmg) then do:
            run pi_messages (input "show", input 588, input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9",
                               'Houve erro na importaá∆o',
                               "Alguns movimentos podem n∆o ter sido importados. Consulte o relat¢rio para ver os detalhes." )).
            
        end.

        run pi_show_report_2 (Input v_nom_filename) /*pi_show_report_2*/.
    end.
    else do:
        output stream s_1 close.
        return "NOK".
    end.

END PROCEDURE. /* pi_imp_movto_cta_corren */
/*****************************************************************************
** Procedure Interna.....: pi_cria_tt_movto_import
** Descricao.............: pi_cria_tt_movto_import
** Criado por............: Klug
** Criado em.............: 07/01/1997 15:18:14
** Alterado por..........: bre17760
** Alterado em...........: 12/07/2004 20:39:32
*****************************************************************************/
PROCEDURE pi_cria_tt_movto_import:


    define variable chexcel           as office.iface.excel.excelwrapper no-undo.  
    define variable charquivo         as char                            no-undo.  
    define variable i-linha           as integer                         no-undo initial 1. 
    define variable ch-arquivo        as office.iface.excel.workbook     no-undo. 
    define variable ch-planilha       as office.iface.excel.worksheet    no-undo. 
    define variable c-arquivo         as character                       no-undo.
    def var c-aux      as char no-undo.
    def var c-conta    as char no-undo.
    def var c-agencia  as char no-undo.
    def var i-inicio   as int  no-undo.
    def var tot-aplic  as dec  no-undo init 0.
    def var tot-resgat as dec  no-undo init 0.
    def var tot-iof    as dec  no-undo init 0.
    def var tot-irrf   as dec  no-undo init 0.
    def var tot-rend   as dec  no-undo init 0.
    def var acum-aplic  as dec  no-undo init 0.
    def var acum-resgat as dec  no-undo init 0.
    def var acum-iof    as dec  no-undo init 0.
    def var acum-irrf   as dec  no-undo init 0.
    def var acum-rend   as dec  no-undo init 0.
    def var val-aplic  as dec  no-undo.
    def var val-resgat as dec  no-undo.
    def var val-iof    as dec  no-undo.
    def var val-irrf   as dec  no-undo.
    def var val-rend   as dec  no-undo.
    def var dat-movto  as date no-undo.
    def var num-docto  as char no-undo.
    def var c-data-aux as char no-undo.
    def var c-dia      as char no-undo.
    def var c-mes      as char no-undo.
    def var c-ano      as char no-undo.
    def var c-hist-aplic  as char no-undo.
    def var c-hist-iof    as char no-undo.
    def var c-hist-irrf   as char no-undo.
    def var c-hist-rend   as char no-undo.
    def var num-seq       as int  NO-UNDO INIT 1.
    def var dat-movto-seq as date no-undo init 01/01/0001.
    def var l-ja-importado as log no-undo init NO.
    def var dat-aplic     as date no-undo.
    def buffer b_tip_aplic for tip_trans_cx.
    def buffer b_tip_iof   for tip_trans_cx.
    def buffer b_tip_irrf  for tip_trans_cx.
    def buffer b_tip_rend  for tip_trans_cx.

    assign charquivo = v_nom_filename_import.

    {office/office.i excel chExcel}
    assign ch-arquivo  = chExcel:workbooks:open(charquivo, 0, yes)
           ch-planilha = ch-arquivo:worksheets(1).

    ch-arquivo:worksheets:item(1):select.
    
    // Busca conta-corrente na cÇlula B4 no formato '8541-61048-4' (agencia-conta-digito)
    // Alterado KML Lohan para adequar-se de acordo com o formato que o arquivo vem do Banco
    assign c-aux = TRIM(chExcel:range("B4"):text).

    assign c-agencia = TRIM(entry( 1, c-aux, "-" )).
    if  num-entries(c-aux,"-") < 2 then do:
        run pi_messages (input "show",
                         input 524,
                         input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9",
                                           'Agància e Conta inv†lidos!',
                                           "Era esperada a Conta-corrente junto com a agància na cÇlula B4 no formato '9999-99999' com o h°fen separando agància e conta." )).


        chexcel:QUIT().
        return "NOK".
    end.
    assign c-conta = entry( 2, c-aux, "-" ).

    find cta_corren
        where cta_corren.cod_cta_corren = c-conta
        no-lock no-error.
    if  not avail cta_corren then do:
        run pi_messages (input "show",
                         input 524,
                         input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9",
                                           'Conta corrente inv†lidas!',
                                           "Era esperada a Conta-corrente junto com a agància na cÇlula B4 no formato '9999-99999' com o h°fen separando agància e conta." + chr(13) + 
                                           "A conta-corrente " + c-conta + " n∆o foi encontrada no sistema." )).

        chexcel:QUIT().
        return "NOK".
    end.
    if  cta_corren.cod_agenc <> c-agencia then do:
        run pi_messages (input "show",
                         input 524,
                         input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9",
                                           'Agància inv†lida!',
                                           "A agància na cÇlula B4 Ç: " + c-agencia + chr(13) + 
                                           "Mas a agància da conta-corrente no sistema Ç: " + cta_corren.cod_agenc )).

        chexcel:QUIT().
        return "NOK".
    end.

    find cst_tip_trans_aplic
        where cst_tip_trans_aplic.cod_cta_corren = c-conta
        no-lock no-error.
    if  not avail cst_tip_trans_aplic then do:
        run pi_messages (input "show",
                         input 524,
                         input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9",
                                           'Tipo de Transaá∆o Aplicaá∆o n∆o cadastrado!',
                                           "N∆o foi encontrado registro para a conta " + c-conta + " no cadastro ESCMG705aa." )).

        chexcel:QUIT().
        return "NOK".
    end.                               

    find b_tip_aplic
        where b_tip_aplic.cod_tip_trans_cx = cst_tip_trans_aplic.cod_tip_aplic
        no-lock no-error.
    find b_tip_iof
        where b_tip_iof.cod_tip_trans_cx = cst_tip_trans_aplic.cod_tip_iof
        no-lock no-error.
    find b_tip_irrf
        where b_tip_irrf.cod_tip_trans_cx = cst_tip_trans_aplic.cod_tip_irrf
        no-lock no-error.
    find b_tip_rend
        where b_tip_rend.cod_tip_trans_cx = cst_tip_trans_aplic.cod_tip_rend
        no-lock no-error.
    if  not avail b_tip_aplic then do:
        run pi_messages (input "show", input 524, input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9",
                           'Tipo de Transaá∆o Caixa para Aplicaá∆o n∆o cadastrado!',
                           "N∆o foi encontrado o Tipo Transaá∆o Caixa " + cst_tip_trans_aplic.cod_tip_aplic )).
        
        return "NOK".
    end.
    if  not avail b_tip_iof   then do:
        run pi_messages (input "show", input 524, input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9",
                           'Tipo de Transaá∆o Caixa para IOF n∆o cadastrado!',
                           "N∆o foi encontrado o Tipo Transaá∆o Caixa " + cst_tip_trans_aplic.cod_tip_iof )).
        
        return "NOK".
    end.
    if  not avail b_tip_irrf  then do:
        run pi_messages (input "show", input 524, input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9",
                           'Tipo de Transaá∆o Caixa para IRRF n∆o cadastrado!',
                           "N∆o foi encontrado o Tipo Transaá∆o Caixa " + cst_tip_trans_aplic.cod_tip_irrf )).
    
        return "NOK".
    end.
    if  not avail b_tip_rend then do:
        run pi_messages (input "show", input 524, input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9",
                           'Tipo de Transaá∆o Caixa para Rendimentos n∆o cadastrado!',
                           "N∆o foi encontrado o Tipo Transaá∆o Caixa " + cst_tip_trans_aplic.cod_tip_rend )).

       
        return "NOK".
    end.

    run pi-get-historico-padrao( input  b_tip_aplic.cod_histor_padr, output c-hist-aplic ).
    run pi-get-historico-padrao( input  b_tip_iof.cod_histor_padr,   output c-hist-iof   ).
    run pi-get-historico-padrao( input  b_tip_irrf.cod_histor_padr,  output c-hist-irrf  ).
    run pi-get-historico-padrao( input  b_tip_rend.cod_histor_padr,  output c-hist-rend  ).

    ASSIGN i-inicio = 10
           num-seq  = 1.
    if chExcel:range("A6"):text = "DATA" then assign i-inicio = 10.
    else if chExcel:range("A7"):text = "DATA" then assign i-inicio = 11.
    else if chExcel:range("A8"):text = "DATA" then assign i-inicio = 12.
    else if chExcel:range("A9"):text = "DATA" then assign i-inicio = 13.

    /* COLUNA A - Data do movimento   */
    /* COLUNA B - N£mero do documento */
    /* COLUNA C - Valor aplicado      */
    /* COLUNA D - Data Aplicaá∆o Resgatada  */
    /* COLUNA E - Valor resgatado     */
    /* COLUNA F - <Ignorar>           */
    /* COLUNA G - IOF                 */
    /* COLUNA H - IRRF                */
    /* COLUNA I- <Ignorar>           */
    /* COLUNA J - Rendimento Bruto    */

    bl-import:
    do i-linha = i-inicio to 9999:  // O metodo "chexcel:activesheet:usedrange:rows:count" estava retornando -1. (Barth)

        if  chExcel:range("A" + string(i-linha)):text = ''
        and chExcel:range("B" + string(i-linha)):text = '' then
            leave bl-import. // fim das linhas com conte£do
        if  chExcel:range("A" + string(i-linha)):text begins 'Acum' then do:
            // Ultima linha com totais
            assign acum-aplic  = dec(chExcel:range("C" + string(i-linha)):text)
                   acum-resgat = dec(chExcel:range("E" + string(i-linha)):text)
                   acum-iof    = dec(chExcel:range("G" + string(i-linha)):text)
                   acum-irrf   = dec(chExcel:range("H" + string(i-linha)):text)
                   acum-rend   = dec(chExcel:range("J" + string(i-linha)):text).
            leave bl-import.
        end.
        if  chExcel:range("B" + string(i-linha)):text = '' then
            next bl-import.  // linhas onde n∆o h† n£mero do documento s∆o linhas de total
        
        assign val-aplic  = 0
               val-resgat = 0
               val-iof    = 0
               val-irrf   = 0
               val-rend   = 0
               dat-movto  = ?
               num-docto  = trim(chExcel:range("B" + string(i-linha)):text).
        assign c-data-aux = trim(chExcel:range("A" + string(i-linha)):text).
        
        // Barth: a data pode vir no formato 01/09/2023 ou 1/9/2023.
        if  index(c-data-aux,"/") = 3 then
            assign dat-movto  = date( int(substr(c-data-aux,4,2)),
                                      int(substr(c-data-aux,1,2)),
                                      int(substr(c-data-aux,7,4)) ) no-error.
        else do:
            assign c-dia = substr(c-data-aux,1,1).
            assign c-mes = substr(substr(c-data-aux,3),1,index(substr(c-data-aux,3),"/") - 1).
            assign c-ano = substr(substr(c-data-aux,3),index(substr(c-data-aux,3),"/") + 1).
            assign dat-movto  = date( int(c-mes),
                                      int(c-dia),
                                      int(c-ano) ) no-error.
        end.
        if  error-status:error = yes then do:
            run pi_messages (input "show",
                             input 524,
                             input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9",
                                               "Erro na leitura da linha " + string(i-linha) + " da planilha!",
                                               "A data do movimento na coluna A n∆o Ç legivel: " + c-data-aux )).
            chexcel:QUIT().
           
            return "NOK". 

        end.

        assign val-aplic  = dec(chExcel:range("C" + string(i-linha)):text)
               val-resgat = dec(chExcel:range("E" + string(i-linha)):text)
               val-iof    = dec(chExcel:range("G" + string(i-linha)):text)
               val-irrf   = dec(chExcel:range("H" + string(i-linha)):text)
               val-rend   = dec(chExcel:range("J" + string(i-linha)):text)
               no-error.
        if  error-status:error = yes then do:
            run pi_messages (input "show",
                             input 524,
                             input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9",
                                               'Erro na leitura da linha " + string(i-linha) + " da planilha!',
                                               "As colunas C, E, G, H, J, deveriam conter apenas valores." )).
            chexcel:QUIT().
            return "NOK".
        end.

        if  val-resgat > 0 then do:
            assign c-data-aux = trim(chExcel:range("D" + string(i-linha)):text).
            if  index(c-data-aux,"/") = 3 then
                assign dat-aplic  = date( int(substr(c-data-aux,4,2)),
                                          int(substr(c-data-aux,1,2)),
                                          int(substr(c-data-aux,7,4)) ) no-error.
            else do:
                assign c-dia = substr(c-data-aux,1,1).
                assign c-mes = substr(substr(c-data-aux,3),1,index(substr(c-data-aux,3),"/") - 1).
                assign c-ano = substr(substr(c-data-aux,3),index(substr(c-data-aux,3),"/") + 1).
                assign dat-aplic  = date( int(c-mes),
                                          int(c-dia),
                                          int(c-ano) ) no-error.
            end.
            if  error-status:error = yes then do:
                run pi_messages (input "show",
                                 input 524,
                                 input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9",
                                                   "Erro na leitura da linha " + string(i-linha) + " da planilha!",
                                                   "A data da aplicaá∆o resgatada na coluna D n∆o Ç uma data legivel: " + c-data-aux )).
                chexcel:QUIT().
                return "NOK".            
            end.
            
            if  month(dat-aplic) < month(dat-movto) then do:
                // Se o dinheiro foi aplicado num màs, e resgatado somente no màs seguinte, o financeiro da Nissei (Carol/Ivana)
                // solicitou que o rendimento fosse somado ao valor resgatado, pois na virada de màs, o rendimento j† foi
                // contabilmente incorporado ao valor aplicado. Como parte do rendimento pertence ao màs atual, ao ser
                // questionada, Ivana disse que "as aplicaá‰es de resgate normalmente ocorrem em D+2. Supondo que tiver alguma diferenáa na rentabilidade, eles fariamˇmanualmente".
                assign val-resgat = val-resgat + val-rend
                       val-rend   = 0.
            end.
        end.

        // Aplicaá∆o
        if  val-aplic > 0 then do:
            // valida se o movimento j† existe...
            if  can-find(first movto_cta_corren no-lock use-index mvtctcrr_id
                         where movto_cta_corren.cod_cta_corren          = c-conta
                         and   movto_cta_corren.dat_movto_cta_corren    = dat-movto
                         and   movto_cta_corren.cod_docto_movto_cta_bco = num-docto
                         and   movto_cta_corren.cod_tip_trans_cx        = cst_tip_trans_aplic.cod_tip_aplic) then do:
                assign l-ja-importado = YES.
            end.
            else do:
                create tt_movto_cta_corren_import.
                assign tt_movto_cta_corren_import.tta_cod_cta_corren             = c-conta
                       tt_movto_cta_corren_import.tta_dat_movto_cta_corren       = dat-movto
                       tt_movto_cta_corren_import.tta_num_seq_movto_cta_corren   = num-seq
                       tt_movto_cta_corren_import.tta_ind_tip_movto_cta_corren   = "RE"
                       tt_movto_cta_corren_import.tta_cod_tip_trans_cx           = cst_tip_trans_aplic.cod_tip_aplic
                       tt_movto_cta_corren_import.tta_ind_fluxo_movto_cta_corren = "SAI"
                       tt_movto_cta_corren_import.tta_cod_cenar_ctbl             = ""
                       tt_movto_cta_corren_import.tta_cod_histor_padr            = ""
                       tt_movto_cta_corren_import.tta_val_movto_cta_corren       = val-aplic
                       tt_movto_cta_corren_import.tta_cod_docto_movto_cta_bco    = num-docto
                       tt_movto_cta_corren_import.tta_cod_modul_dtsul            = "CMG"
                       tt_movto_cta_corren_import.ttv_ind_erro_valid             = "N∆o"
                       tt_movto_cta_corren_import.tta_des_histor_padr            = c-hist-aplic
                       tt_movto_cta_corren_import.ttv_rec_movto_cta_corren       = recid(tt_movto_cta_corren_import).
                assign num-seq = num-seq + 1.
                assign tot-aplic = tot-aplic + val-aplic.
            end.
        end.

        // Resgate
        if  val-resgat > 0 then do:
            // valida se o movimento j† existe...
            if  can-find(first movto_cta_corren no-lock use-index mvtctcrr_id
                         where movto_cta_corren.cod_cta_corren          = c-conta
                         and   movto_cta_corren.dat_movto_cta_corren    = dat-movto
                         and   movto_cta_corren.cod_docto_movto_cta_bco = num-docto
                         and   movto_cta_corren.cod_tip_trans_cx        = cst_tip_trans_aplic.cod_tip_aplic) then do:
                assign l-ja-importado = YES.
            end.
            else do:
                create tt_movto_cta_corren_import.
                assign tt_movto_cta_corren_import.tta_cod_cta_corren             = c-conta
                       tt_movto_cta_corren_import.tta_dat_movto_cta_corren       = dat-movto
                       tt_movto_cta_corren_import.tta_num_seq_movto_cta_corren   = num-seq
                       tt_movto_cta_corren_import.tta_ind_tip_movto_cta_corren   = "RE"
                       tt_movto_cta_corren_import.tta_cod_tip_trans_cx           = cst_tip_trans_aplic.cod_tip_aplic
                       tt_movto_cta_corren_import.tta_ind_fluxo_movto_cta_corren = "ENT"
                       tt_movto_cta_corren_import.tta_cod_cenar_ctbl             = ""
                       tt_movto_cta_corren_import.tta_cod_histor_padr            = ""
                       tt_movto_cta_corren_import.tta_val_movto_cta_corren       = val-resgat
                       tt_movto_cta_corren_import.tta_cod_docto_movto_cta_bco    = num-docto
                       tt_movto_cta_corren_import.tta_cod_modul_dtsul            = "CMG"
                       tt_movto_cta_corren_import.ttv_ind_erro_valid             = "N∆o"
                       tt_movto_cta_corren_import.tta_des_histor_padr            = "RESGATE " + c-hist-aplic
                       tt_movto_cta_corren_import.ttv_rec_movto_cta_corren       = recid(tt_movto_cta_corren_import).    
                assign num-seq = num-seq + 1.
                assign tot-resgat = tot-resgat + val-resgat.
            end.
        end.

        // IOF sobre o resgate
        if  val-iof > 0 then do:
            // valida se o movimento j† existe...
            if  can-find(first movto_cta_corren no-lock use-index mvtctcrr_id
                         where movto_cta_corren.cod_cta_corren          = c-conta
                         and   movto_cta_corren.dat_movto_cta_corren    = dat-movto
                         and   movto_cta_corren.cod_docto_movto_cta_bco = num-docto
                         and   movto_cta_corren.cod_tip_trans_cx        = cst_tip_trans_aplic.cod_tip_iof) then do:
                assign l-ja-importado = YES.
            end.
            else do:
                create tt_movto_cta_corren_import.
                assign tt_movto_cta_corren_import.tta_cod_cta_corren             = c-conta
                       tt_movto_cta_corren_import.tta_dat_movto_cta_corren       = dat-movto
                       tt_movto_cta_corren_import.tta_num_seq_movto_cta_corren   = num-seq
                       tt_movto_cta_corren_import.tta_ind_tip_movto_cta_corren   = "RE"
                       tt_movto_cta_corren_import.tta_cod_tip_trans_cx           = cst_tip_trans_aplic.cod_tip_iof
                       tt_movto_cta_corren_import.tta_ind_fluxo_movto_cta_corren = "SAI"
                       tt_movto_cta_corren_import.tta_cod_cenar_ctbl             = ""
                       tt_movto_cta_corren_import.tta_cod_histor_padr            = ""
                       tt_movto_cta_corren_import.tta_val_movto_cta_corren       = val-iof
                       tt_movto_cta_corren_import.tta_cod_docto_movto_cta_bco    = num-docto
                       tt_movto_cta_corren_import.tta_cod_modul_dtsul            = "CMG"
                       tt_movto_cta_corren_import.ttv_ind_erro_valid             = "N∆o"
                       tt_movto_cta_corren_import.tta_des_histor_padr            = c-hist-iof
                       tt_movto_cta_corren_import.ttv_rec_movto_cta_corren       = recid(tt_movto_cta_corren_import).    
                assign num-seq = num-seq + 1.
                assign tot-iof = tot-iof + val-iof.
            end.
        end.

        // IRRF sobre o resgate
        if  val-irrf > 0 then do:
            // valida se o movimento j† existe...
            if  can-find(first movto_cta_corren no-lock use-index mvtctcrr_id
                         where movto_cta_corren.cod_cta_corren          = c-conta
                         and   movto_cta_corren.dat_movto_cta_corren    = dat-movto
                         and   movto_cta_corren.cod_docto_movto_cta_bco = num-docto
                         and   movto_cta_corren.cod_tip_trans_cx        = cst_tip_trans_aplic.cod_tip_irrf) then do:
                assign l-ja-importado = YES.
            end.
            else do:
                create tt_movto_cta_corren_import.
                assign tt_movto_cta_corren_import.tta_cod_cta_corren             = c-conta
                       tt_movto_cta_corren_import.tta_dat_movto_cta_corren       = dat-movto
                       tt_movto_cta_corren_import.tta_num_seq_movto_cta_corren   = num-seq
                       tt_movto_cta_corren_import.tta_ind_tip_movto_cta_corren   = "RE"
                       tt_movto_cta_corren_import.tta_cod_tip_trans_cx           = cst_tip_trans_aplic.cod_tip_irrf
                       tt_movto_cta_corren_import.tta_ind_fluxo_movto_cta_corren = "SAI"
                       tt_movto_cta_corren_import.tta_cod_cenar_ctbl             = ""
                       tt_movto_cta_corren_import.tta_cod_histor_padr            = ""
                       tt_movto_cta_corren_import.tta_val_movto_cta_corren       = val-irrf
                       tt_movto_cta_corren_import.tta_cod_docto_movto_cta_bco    = num-docto
                       tt_movto_cta_corren_import.tta_cod_modul_dtsul            = "CMG"
                       tt_movto_cta_corren_import.ttv_ind_erro_valid             = "N∆o"
                       tt_movto_cta_corren_import.tta_des_histor_padr            = c-hist-irrf
                       tt_movto_cta_corren_import.ttv_rec_movto_cta_corren       = recid(tt_movto_cta_corren_import).    
                assign num-seq = num-seq + 1.
                assign tot-irrf = tot-irrf + val-irrf.
            end.
        end.

        // Rendimento sobre o resgate
        if  val-rend > 0 then do:
            // valida se o movimento j† existe...
            if  can-find(first movto_cta_corren no-lock use-index mvtctcrr_id
                         where movto_cta_corren.cod_cta_corren          = c-conta
                         and   movto_cta_corren.dat_movto_cta_corren    = dat-movto
                         and   movto_cta_corren.cod_docto_movto_cta_bco = num-docto
                         and   movto_cta_corren.cod_tip_trans_cx        = cst_tip_trans_aplic.cod_tip_rend) then do:
                assign l-ja-importado = YES.
            end.
            else do:
                create tt_movto_cta_corren_import.
                assign tt_movto_cta_corren_import.tta_cod_cta_corren             = c-conta
                       tt_movto_cta_corren_import.tta_dat_movto_cta_corren       = dat-movto
                       tt_movto_cta_corren_import.tta_num_seq_movto_cta_corren   = num-seq
                       tt_movto_cta_corren_import.tta_ind_tip_movto_cta_corren   = "RE"
                       tt_movto_cta_corren_import.tta_cod_tip_trans_cx           = cst_tip_trans_aplic.cod_tip_rend
                       tt_movto_cta_corren_import.tta_ind_fluxo_movto_cta_corren = "ENT"
                       tt_movto_cta_corren_import.tta_cod_cenar_ctbl             = ""
                       tt_movto_cta_corren_import.tta_cod_histor_padr            = ""
                       tt_movto_cta_corren_import.tta_val_movto_cta_corren       = val-rend
                       tt_movto_cta_corren_import.tta_cod_docto_movto_cta_bco    = num-docto
                       tt_movto_cta_corren_import.tta_cod_modul_dtsul            = "CMG"
                       tt_movto_cta_corren_import.ttv_ind_erro_valid             = "N∆o"
                       tt_movto_cta_corren_import.tta_des_histor_padr            = c-hist-rend
                       tt_movto_cta_corren_import.ttv_rec_movto_cta_corren       = recid(tt_movto_cta_corren_import).    
                assign num-seq = num-seq + 1.
                assign tot-rend = tot-rend + val-rend.
            end.
        end.

    end.

/*  Fecha o Objeto Excel ********************************************************************************************************************************************************************/  

    chexcel:QUIT().

    ASSIGN chexcel     = ? NO-ERROR.
    ASSIGN c-arquivo   = ? NO-ERROR.
    ASSIGN ch-Planilha = ? NO-ERROR.    
    
    //chExcel:workbooks:close. // Ponto para colocar o RUN

    if  l-ja-importado = yes then do:
        run pi_messages (input "show", input 588, input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9",
                           'Movimentos j† lanáados foram ignorados !',
                           "Pelo menos um dos movimentos dessa planilha j† estava lanáado no CMG e foi ignorado." + chr(13) +
                           "O movimento Ç ignorado se j† existe um movimento com o N£mero Documento registrado na Conta-corrente na mesma data." )).
    end.
    else do:
        if  tot-aplic  <> acum-aplic 
        or  tot-resgat <> acum-resgat
        or  tot-iof    <> acum-iof   
        or  tot-irrf   <> acum-irrf  
        or  tot-rend   <> acum-rend then do:
            run pi_messages (input "show", input 588, input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9",
                             'Totais n∆o batem !',
                             "Houve diferenáa em algum dos totais com o Acumulado da planilha:" + chr(13) +
                             "TOTAIS CALCULADOS:" + chr(13) +
                             "Aplicaá‰es: " + trim(string(tot-aplic,">>>>,>>>,>>9.99")) + chr(13) +
                             "Resgates: " + trim(string(tot-resgat,">>>>,>>>,>>9.99")) + chr(13) +
                             "IOF: " + trim(string(tot-iof,">>>>,>>>,>>9.99")) + chr(13) +
                             "IRRF: " + trim(string(tot-irrf,">>>>,>>>,>>9.99")) + chr(13) +
                             "Rendimentos: " + trim(string(tot-rend,">>>>,>>>,>>9.99")) + chr(13) +
                             "LINHA ACUM.M“S DA PLANILHA:" + chr(13) +
                             "Aplicaá‰es: " + trim(string(acum-aplic,">>>>,>>>,>>9.99")) + chr(13) +
                             "Resgates: " + trim(string(acum-resgat,">>>>,>>>,>>9.99")) + chr(13) +
                             "IOF: " + trim(string(acum-iof,">>>>,>>>,>>9.99")) + chr(13) +
                             "IRRF: " + trim(string(acum-irrf,">>>>,>>>,>>9.99")) + chr(13) +
                             "Rendimentos: " + trim(string(acum-rend,">>>>,>>>,>>9.99")) + chr(13)
                            )).
        end.
    end.

    return "OK".

END PROCEDURE. /* pi_cria_tt_movto_import */
/*****************************************************************************
** Procedure Interna.....: pi_version_extract
** Descricao.............: pi_version_extract
** Criado por............: jaison
** Criado em.............: 31/07/1998 09:33:22
** Alterado por..........: tech14020
** Alterado em...........: 12/06/2006 09:09:21
*****************************************************************************/
PROCEDURE pi_version_extract:

    /************************ Parameter Definition Begin ************************/

    def Input param p_cod_program
        as character
        format "x(08)"
        no-undo.
    def Input param p_cod_program_ext
        as character
        format "x(8)"
        no-undo.
    def Input param p_cod_version
        as character
        format "x(8)"
        no-undo.
    def Input param p_cod_program_type
        as character
        format "x(8)"
        no-undo.


    /************************* Parameter Definition End *************************/

    /************************* Variable Definition Begin ************************/

    def var v_cod_event_dic
        as character
        format "x(20)":U
        label "Evento"
        column-label "Evento"
        no-undo.
    def var v_cod_tabela
        as character
        format "x(28)":U
        label "Tabela"
        column-label "Tabela"
        no-undo.


    /************************** Variable Definition End *************************/

    if  can-do(v_cod_tip_prog, p_cod_program_type)
    then do:
        if p_cod_program_type = 'dic' then 
           assign p_cod_program_ext = replace(p_cod_program_ext, 'database/', '').

        output stream s-arq to value(v_cod_arq) append.

        put stream s-arq unformatted
            p_cod_program            at 1 
            p_cod_program_ext        at 43 
            p_cod_version            at 69 
            today                    at 84 format "99/99/99"
            string(time, 'HH:MM:SS') at 94 skip.

        if  p_cod_program_type = 'pro' then do:
            &if '{&emsbas_version}' > '1.00' &then
            find prog_dtsul 
                where prog_dtsul.cod_prog_dtsul = p_cod_program 
                no-lock no-error.
            if  avail prog_dtsul
            then do:
                &if '{&emsbas_version}' > '5.00' &then
                    if  prog_dtsul.nom_prog_dpc <> '' then
                        put stream s-arq 'DPC : ' at 5 prog_dtsul.nom_prog_dpc  at 15 skip.
                &endif
                if  prog_dtsul.nom_prog_appc <> '' then
                    put stream s-arq 'APPC: ' at 5 prog_dtsul.nom_prog_appc at 15 skip.
                if  prog_dtsul.nom_prog_upc <> '' then
                    put stream s-arq 'UPC : ' at 5 prog_dtsul.nom_prog_upc  at 15 skip.
            end /* if */.
            &endif
        end.

        if  p_cod_program_type = 'dic' then do:
            &if '{&emsbas_version}' > '1.00' &then
            assign v_cod_event_dic = ENTRY(1,p_cod_program ,'/':U)
                   v_cod_tabela    = ENTRY(2,p_cod_program ,'/':U). /* FO 1100.980 */
            find tab_dic_dtsul 
                where tab_dic_dtsul.cod_tab_dic_dtsul = v_cod_tabela 
                no-lock no-error.
            if  avail tab_dic_dtsul
            then do:
                &if '{&emsbas_version}' > '5.00' &then
                    if  tab_dic_dtsul.nom_prog_dpc_gat_delete <> '' and v_cod_event_dic = 'Delete':U then
                        put stream s-arq 'DPC-DELETE : ' at 5 tab_dic_dtsul.nom_prog_dpc_gat_delete  at 25 skip.
                &endif
                if  tab_dic_dtsul.nom_prog_appc_gat_delete <> '' and v_cod_event_dic = 'Delete':U then
                    put stream s-arq 'APPC-DELETE: ' at 5 tab_dic_dtsul.nom_prog_appc_gat_delete at 25 skip.
                if  tab_dic_dtsul.nom_prog_upc_gat_delete <> '' and v_cod_event_dic = 'Delete':U then
                    put stream s-arq 'UPC-DELETE : ' at 5 tab_dic_dtsul.nom_prog_upc_gat_delete  at 25 skip.
                &if '{&emsbas_version}' > '5.00' &then
                    if  tab_dic_dtsul.nom_prog_dpc_gat_write <> '' and v_cod_event_dic = 'Write':U then
                        put stream s-arq 'DPC-WRITE : ' at 5 tab_dic_dtsul.nom_prog_dpc_gat_write  at 25 skip.
                &endif
                if  tab_dic_dtsul.nom_prog_appc_gat_write <> '' and v_cod_event_dic = 'Write':U then
                    put stream s-arq 'APPC-WRITE: ' at 5 tab_dic_dtsul.nom_prog_appc_gat_write at 25 skip.
                if  tab_dic_dtsul.nom_prog_upc_gat_write <> '' and v_cod_event_dic = 'Write':U  then
                    put stream s-arq 'UPC-WRITE : ' at 5 tab_dic_dtsul.nom_prog_upc_gat_write  at 25 skip.
            end /* if */.
            &endif
        end.

        output stream s-arq close.
    end /* if */.

END PROCEDURE. /* pi_version_extract */



/*************************************  *************************************/
/*****************************************************************************
**  Procedure Interna: pi_messages
**  Descricao........: Mostra Mensagem com Ajuda
*****************************************************************************/
PROCEDURE pi_messages:

    def input param c_action    as char    no-undo.
    def input param i_msg       as integer no-undo.
    def input param c_param     as char    no-undo.

    def var c_prg_msg           as char    no-undo.

    assign c_prg_msg = "messages/":U
                     + string(trunc(i_msg / 1000,0),"99":U)
                     + "/msg":U
                     + string(i_msg, "99999":U).

    if search(c_prg_msg + ".r":U) = ? and search(c_prg_msg + ".p":U) = ? then do:
        message "Mensagem nr. " i_msg "!!!":U skip
                "Programa Mensagem" c_prg_msg "n∆o encontrado."
                view-as alert-box error.
        return error.
    end.

    run value(c_prg_msg + ".p":U) (input c_action, input c_param).
    return return-value.
END PROCEDURE.  /* pi_messages */

/*****************************************************************************
**  Procedure Interna: pi-get-historico-padrao
*****************************************************************************/
PROCEDURE pi-get-historico-padrao:
    DEF INPUT  PARAM p-cod-histor-padr as char.
    DEF OUTPUT PARAM p-historico       as char init "".

    find histor_padr
        where histor_padr.cod_histor_padr = p-cod-histor-padr
        no-lock no-error.
    if  avail histor_padr then do:
        assign p-historico = replace(histor_padr.des_text_histor_padr, "#BANCO#", "").
    end.
end.


