/*****************************************************************************
** Programa..............: rpt_tit_acr_antecip_prev_acr_conv
** Descricao.............: Relat¢rio de Antecipaá‰es/Previs‰es Convànio
** Versao................:  1.00.00.012
** Procedimento..........: rel_antecip_prev_acr_convenio
** Nome Externo..........: intprg/Relat_AE_Convenio.p
** Criado por............: Amarildo
** Criado em.............: 16/11/2016
*****************************************************************************/
DEFINE BUFFER empresa          FOR emscad.empresa.
DEFINE BUFFER espec_docto      FOR emscad.espec_docto.
DEFINE BUFFER cliente          FOR emscad.cliente.
DEFINE BUFFER segur_unid_organ FOR emscad.segur_unid_organ.

def var c-versao-prg as char initial " 1.00.00.012":U no-undo.

{include/i_dbinst.i}
{include/i_dbtype.i}

/* Alteracao via filtro - Controle de impressao - inicio */
{include/i_prdvers.i}
/* Alteracao via filtro - Controle de impressao - fim    */

{include/i_fcldef.i}


&IF "{&EMSFND_VERSION}" >= "1.00" &THEN
{include/i-license-manager.i rpt_tit_acr_antecip_prev_acr ACR}
&ENDIF

/******************************* Private-Data *******************************/
assign this-procedure:private-data = "HLP=37":U.
/*************************************  *************************************/

&if "{&emsfin_dbinst}" <> "yes" &then
run pi_messages (input "show",
                 input 5884,
                 input substitute ("&1~&2~&3~&4~&5~&6~&7~&8~&9", 
                                    "EMSFIN")) /*msg_5884*/.
&elseif "{&emsfin_version}" < "5.01" &then
run pi_messages (input "show",
                 input 5009,
                 input substitute ("&1~&2~&3~&4~&5~&6~&7~&8~&9", 
                                    "RPT_TIT_ACR_ANTECIP_PREV_ACR","~~EMSFIN", "~~{~&emsfin_version}", "~~5.01")) /*msg_5009*/.
&else

/********************* Temporary Table Definition Begin *********************/

def temp-table tt_empresa no-undo
    field tta_cod_empresa                  as character format "x(3)" label "Empresa" column-label "Empresa"
    index tt_id                           
          tta_cod_empresa                  ascending
    .

def temp-table tt_estabelecimento_empresa no-undo like estabelecimento
    field tta_cod_estab                    as character format "x(3)" label "Estabelecimento" column-label "Estab"
    field tta_nom_pessoa                   as character format "x(40)" label "Nome" column-label "Nome"
    field tta_cod_empresa                  as character format "x(3)" label "Empresa" column-label "Empresa"
    field tta_nom_razao_social             as character format "x(40)" label "Raz∆o Social" column-label "Raz∆o Social"
    field ttv_log_selec                    as logical format "Sim/N∆o" initial no column-label "Gera"
    index tt_cod_estab                     is primary unique
          tta_cod_estab                    ascending
    .

def temp-table tt_rpt_tit_acr_antecip_prev_acr no-undo like tit_acr
    field ttv_cod_dwb_field_rpt            as character extent 9 format "x(32)" label "Conjunto" column-label "Conjunto"
    field ttv_val_origin_tit_acr_apres     as decimal format "->>>,>>>,>>9.99" decimals 2 label "Vl Original Apres" column-label "Vl Original Apres"
    field ttv_val_sdo_tit_acr_apres        as decimal format "->>>,>>>,>>9.99" decimals 2 label "Saldo Finalid Apres" column-label "Saldo Apres"
    field ttv_rec_tit_acr                  as recid format ">>>>>>9"
    field tta_cod_unid_negoc               as character format "x(3)" label "Unid Neg¢cio" column-label "Un Neg"
    index tt_estab_unidneg_id              is primary unique
          cod_estab                        ascending
          tta_cod_unid_negoc               ascending
          num_id_tit_acr                   ascending
    .

def temp-table tt_usuar_grp_usuar no-undo like usuar_grp_usuar
    .



/********************** Temporary Table Definition End **********************/

/************************** Buffer Definition Begin *************************/

&if "{&emsuni_version}" >= "1.00" &then
def buffer b_finalid_econ
    for finalid_econ.
&endif
&if "{&emsuni_version}" >= "1.00" &then
def buffer b_finalid_unid_organ
    for finalid_unid_organ.
&endif
&if "{&emsbas_version}" >= "1.00" &then
def buffer b_ped_exec_style
    for ped_exec.
&endif
&if "{&emsbas_version}" >= "1.00" &then
def buffer b_servid_exec_style
    for servid_exec.
&endif

DEFINE BUFFER b1_tit_acr FOR tit_acr.
DEFINE BUFFER b2_tit_acr FOR tit_acr.


/*************************** Buffer Definition End **************************/

/************************** Stream Definition Begin *************************/

def new shared stream s_1.


/*************************** Stream Definition End **************************/

/************************* Variable Definition Begin ************************/

/* Alteracao via filtro - Controle de impressao - inicio */
&IF "{&product_version}" >= "11.5.7" &THEN
DEFINE VARIABLE v_page_number                   AS INTEGER INITIAL -1 NO-UNDO.
DEFINE VARIABLE v_cod_usuar_abert               AS CHARACTER          NO-UNDO.

&ENDIF
/* Alteracao via filtro - Controle de impressao - fim    */

/* Alteracao via filtro - Impressao grandes volumes - inicio */
&IF "{&product_version}" >= "11.5.7" &THEN
DEFINE VARIABLE c-servid_exec_nom_dir_spool     AS CHARACTER   NO-UNDO.
DEFINE VARIABLE c-cod_dwb_user                  AS CHARACTER   NO-UNDO.
DEFINE VARIABLE i-num_ped_exec                  AS INTEGER     NO-UNDO.
DEFINE VARIABLE c-usuar_mestre_nom_subdir_spool AS CHARACTER   NO-UNDO.

DEFINE BUFFER b-dwb_rpt_param FOR dwb_rpt_param.
&ENDIF
/* Alteracao via filtro - Impressao grandes volumes - fim */


def var v_cdn_cliente_ant
    as Integer
    format ">>>,>>>,>>9":U
    initial 0
    label "Cliente"
    column-label "Cliente Anterior"
    no-undo.
def new shared var v_cdn_cliente_fim
    as Integer
    format ">>>,>>>,>>9":U
    initial 999999999
    label "atÇ"
    column-label "Cliente Final"
    no-undo.
def new shared var v_cdn_cliente_ini
    as Integer
    format ">>>,>>>,>>9":U
    initial 0
    label "Cliente"
    column-label "Cliente Inicial"
    no-undo.
def var v_cdn_repres_ant
    as Integer
    format ">>>,>>9":U
    initial 999
    label "Representante"
    column-label "Representante"
    no-undo.
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
def var v_cod_cta_ctbl
    as character
    format "x(20)":U
    label "Cod. Emp. Convenio"
    column-label "Cod. Emp. Convenio"
    no-undo.
def new shared var v_cod_dwb_file
    as character
    format "x(40)":U
    label "Arquivo"
    column-label "Arquivo"
    no-undo.
def var v_cod_dwb_file_temp
    as character
    format "x(12)":U
    no-undo.
def var v_cod_dwb_parameters
    as character
    format "x(8)":U
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
def new shared var v_cod_espec_docto_fim
    as character
    format "x(3)":U
    initial "ZZZ"
    label "atÇ"
    column-label "C¢digo Final"
    no-undo.
def new shared var v_cod_espec_docto_ini
    as character
    format "x(3)":U
    label "EspÇcie"
    column-label "C¢digo Inicial"
    no-undo.
&IF "{&emsfin_version}" >= "" AND "{&emsfin_version}" < "5.07A" &THEN
def var v_cod_estab
    as character
    format "x(3)":U
    label "Estabelecimento"
    column-label "Estabelecimento"
    no-undo.
&ENDIF
&IF "{&emsfin_version}" >= "5.07A" AND "{&emsfin_version}" < "9.99" &THEN
def var v_cod_estab
    as Character
    format "x(5)":U
    label "Estabelecimento"
    column-label "Estabelecimento"
    no-undo.
&ENDIF
def new global shared var v_cod_estab_usuar
    as character
    format "x(3)":U
    label "Estabelecimento"
    column-label "Estab"
    no-undo.
def var v_cod_finalid_econ
    as character
    format "x(10)":U
    label "Finalidade Econìmica"
    column-label "Finalidade Econìmica"
    no-undo.
def var v_cod_finalid_econ_apres
    as character
    format "x(10)":U
    initial "Corrente" /*l_corrente*/
    label "Finalid Apresentaá∆o"
    column-label "Finalid Apresentaá∆o"
    no-undo.
def var v_cod_finalid_econ_aux
    as character
    format "x(10)":U
    label "Finalidade"
    column-label "Finalidade"
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
def new global shared var v_cod_idiom_usuar
    as character
    format "x(8)":U
    label "Idioma"
    column-label "Idioma"
    no-undo.
def new shared var v_cod_indic_econ_fim
    as character
    format "x(8)":U
    initial "ZZZZZZZZ"
    label "atÇ"
    column-label "Final"
    no-undo.
def new shared var v_cod_indic_econ_ini
    as character
    format "x(8)":U
    label "Moeda"
    column-label "Inicial"
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
def new shared var v_cod_order_rpt
    as character
    format "x(80)":U
    label "Ordem Relat"
    column-label "Ordem Relat"
    no-undo.
def new global shared var v_cod_pais_empres_usuar
    as character
    format "x(3)":U
    label "Pa°s Empresa Usu†rio"
    column-label "Pa°s"
    no-undo.
def var v_cod_ped_vda
    as character
    format "x(12)":U
    label "Pedido Venda"
    column-label "Pedido Venda"
    no-undo.
def var v_cod_convenio
    as character
    format "x(12)":U
    label "Convànio"
    column-label "Convànio"
    no-undo.
def var v_cod_cli_convenio
    as INTEGER
    format ">>>,>>>,>>9":U
    label "Cod. Emp. Convenio"
    column-label "Cod. Emp. Convenio"
    no-undo.
def new global shared var v_cod_plano_ccusto_corren
    as character
    format "x(8)":U
    label "Plano CCusto"
    column-label "Plano CCusto"
    no-undo.
def new shared var v_cod_portador_fim
    as character
    format "x(5)":U
    initial "ZZZZZ"
    label "atÇ"
    column-label "Portador Final"
    no-undo.
def new shared var v_cod_portador_ini
    as character
    format "x(5)":U
    label "Portador"
    column-label "Portador Inicial"
    no-undo.
def var v_cod_refer
    as character
    format "x(10)":U
    label "Referància"
    column-label "Referància"
    no-undo.
def new shared var v_cod_release
    as character
    format "x(12)":U
    no-undo.
def var v_cod_ult_obj_procesdo
    as character
    format "x(32)":U
    no-undo.
def new shared var v_cod_unid_negoc_fim
    as character
    format "x(3)":U
    initial "ZZZ"
    label "atÇ"
    column-label "Final"
    no-undo.
def new shared var v_cod_unid_negoc_ini
    as character
    format "x(3)":U
    label "Unid Neg¢cio"
    column-label "Inicial"
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
def var v_dat_conver
    as date
    format "99/99/9999":U
    initial today
    label "Data Convers∆o"
    column-label "Data Convers∆o"
    no-undo.
def var v_dat_cotac_indic_econ
    as date
    format "99/99/9999":U
    initial today
    label "Data Cotaá∆o"
    column-label "Data Cotaá∆o"
    no-undo.
def new shared var v_dat_emis_docto_fim
    as date
    format "99/99/9999":U
    initial 12/31/9999
    label "atÇ"
    column-label "atÇ"
    no-undo.
def new shared var v_dat_emis_docto_ini
    as date
    format "99/99/9999":U
    initial &IF "{&ems_dbtype}":U = "MSS":U &THEN 01/01/1800 &ELSE 01/01/0001 &ENDIF
    label "Emiss∆o"
    column-label "Emiss∆o"
    no-undo.
def new shared var v_dat_execution
    as date
    format "99/99/9999":U
    no-undo.
def new shared var v_dat_execution_end
    as date
    format "99/99/9999":U
    no-undo.
def new shared var v_dat_fim_period
    as date
    format "99/99/9999":U
    label "Fim Per°odo"
    no-undo.
def new shared var v_dat_inic_period
    as date
    format "99/99/9999":U
    label "In°cio Per°odo"
    column-label "Per°odo"
    no-undo.
def new shared var v_dat_vencto_tit_acr_fim
    as date
    format "99/99/9999":U
    initial 12/31/9999
    label "atÇ"
    column-label "Vencto Final"
    no-undo.
def new shared var v_dat_vencto_tit_acr_ini
    as date
    format "99/99/9999":U
    initial &IF "{&ems_dbtype}":U = "MSS":U &THEN 01/01/1800 &ELSE 01/01/0001 &ENDIF
    label "Vencimento"
    column-label "Vencto Inicial"
    no-undo.
def new shared var v_des_estab_select
    as character
    format "x(2000)":U
    view-as editor max-chars 2000 no-word-wrap
    size 30 by 1
    bgcolor 15 font 2
    label "Selecionados"
    column-label "Selecionados"
    no-undo.
def new shared var v_hra_execution
    as Character
    format "99:99":U
    no-undo.
def new shared var v_hra_execution_end
    as Character
    format "99:99:99":U
    label "Tempo Exec"
    no-undo.
def new shared var v_ind_classif
    as character
    format "X(35)":U
    initial "Por T°tulo" /*l_por_titulo*/
    no-undo.
def var v_ind_dwb_run_mode
    as character
    format "X(07)":U
    initial "On-Line" /*l_online*/
    view-as radio-set Horizontal
    radio-buttons "On-Line", "On-Line", "Batch", "Batch"
     /*l_online*/ /*l_online*/ /*l_batch*/ /*l_batch*/
    bgcolor 8 
    label "Run Mode"
    column-label "Run Mode"
    no-undo.
def var v_ind_tip_espec_docto
    as character
    format "X(17)":U
    view-as combo-box
    list-items "Nenhum","Normal","Antecipaá∆o","Previs∆o","Provis∆o","Cheques Recebidos","Imposto Retido","Imposto Taxado","Material Recebido","Nota de CrÇdito","Nota de DÇbito","Nota Fiscal","Aviso DÇbito","Nota Promiss¢ria"
     /*l_nenhum*/ /*l_normal*/ /*l_antecipacao*/ /*l_previsao*/ /*l_provisao*/ /*l_cheques_recebidos*/ /*l_imposto_retido*/ /*l_imposto_taxado*/ /*l_material_recebido*/ /*l_nota_de_credito*/ /*l_nota_de_debito*/ /*l_nota_fiscal*/ /*l_aviso_debito*/ /*l_nota_promissoria*/
    inner-lines 10
    bgcolor 15 font 2
    label "Tipo EspÇcie"
    column-label "Tipo EspÇcie"
    no-undo.
def new shared var v_ind_visualiz_tit_acr_vert
    as character
    format "X(20)":U
    initial "Por Estabelecimento" /*l_por_estabelecimento*/
    view-as radio-set Vertical
    radio-buttons "Por Estabelecimento", "Por Estabelecimento", "Por Unidade Neg¢cio", "Por Unidade Neg¢cio"
     /*l_por_estabelecimento*/ /*l_por_estabelecimento*/ /*l_por_unid_negoc*/ /*l_por_unid_negoc*/
    bgcolor 8 
    label "Visualiza T°tulo"
    column-label "Visualiza T°tulo"
    no-undo.
def var v_log_alter
    as logical
    format "Sim/N∆o"
    initial no
    no-undo.
def new global shared var v_log_execution
    as logical
    format "Sim/N∆o"
    initial yes
    no-undo.
def var v_log_lista_abat_pend
    as logical
    format "Sim/N∆o"
    initial no
    view-as toggle-box
    no-undo.
def var v_log_lista_cta_ctbl
    as logical
    format "Sim/N∆o"
    initial no
    view-as toggle-box
    no-undo.
def var v_log_lista_ped
    as logical
    format "Sim/N∆o"
    initial no
    view-as toggle-box
    no-undo.
def var v_log_method
    as logical
    format "Sim/N∆o"
    initial yes
    no-undo.
def new shared var v_log_mudan
    as logical
    format "Sim/N∆o"
    initial no
    no-undo.
def var v_log_plano_ativ
    as logical
    format "Sim/N∆o"
    initial no
    no-undo.
def new shared var v_log_prev
    as logical
    format "Sim/N∆o"
    initial yes
    view-as toggle-box
    label "Previs∆o"
    column-label "Previs∆o"
    no-undo.
def var v_log_primei_abat
    as logical
    format "Sim/N∆o"
    initial yes
    no-undo.
def var v_log_primei_ped_vda
    as logical
    format "Sim/N∆o"
    initial yes
    no-undo.
def var v_log_print
    as logical
    format "Sim/N∆o"
    initial no
    no-undo.
def var v_log_print_par
    as logical
    format "Sim/N∆o"
    initial yes
    view-as toggle-box
    no-undo.
def var v_log_sdo_zero
    as logical
    format "Sim/N∆o"
    initial no
    view-as toggle-box
    no-undo.
def var v_log_tot_por_espec
    as logical
    format "Sim/N∆o"
    initial no
    view-as toggle-box
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
def new shared var v_nom_enterprise
    as character
    format "x(40)":U
    no-undo.
def var v_nom_integer
    as character
    format "x(30)":U
    no-undo.
def var v_nom_pessoa_cli
    as character
    format "x(40)":U
    label "Nome"
    column-label "Nome"
    no-undo.
def var v_nom_pessoa_rep
    as character
    format "x(40)":U
    label "Nome"
    column-label "Nome"
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
def new shared var v_nom_prog_ext
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
def new shared var v_nom_report_title
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
def var v_num_count
    as integer
    format ">>>>,>>9":U
    no-undo.
def new shared var v_num_entry
    as integer
    format ">>>>,>>9":U
    label "Ordem"
    column-label "Ordem"
    no-undo.
def var v_num_idx
    as integer
    format ">>>>,>>9":U
    no-undo.
def var v_num_ocorrencia
    as integer
    format ">>>>,>>9":U
    no-undo.
def new shared var v_num_page_number
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
def var v_num_seq
    as integer
    format ">>>,>>9":U
    label "SeqÅància"
    column-label "Seq"
    no-undo.
def var v_qtd_bottom
    as decimal
    format ">>9":U
    decimals 0
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
def var v_qtd_line_ant
    as decimal
    format "->>>>,>>9.9999":U
    decimals 4
    no-undo.
def new global shared var v_rec_finalid_econ
    as recid
    format ">>>>>>9":U
    no-undo.
def var v_rec_log
    as recid
    format ">>>>>>9":U
    no-undo.
def var v_rec_table_epc
    as recid
    format ">>>>>>9":U
    no-undo.
def new global shared var v_rec_tit_acr
    as recid
    format ">>>>>>9":U
    no-undo.
def var v_val_abat
    as decimal
    format "->>>,>>>,>>9.99":U
    decimals 2
    initial 0
    label "Valor Abatimento"
    column-label "Valor Abatimento"
    no-undo.
def var v_val_cotac_indic_econ
    as decimal
    format "->>,>>>,>>>,>>9.9999999999":U
    decimals 10
    label "Cotaá∆o"
    column-label "Cotaá∆o"
    no-undo.
def var v_val_origin_tit_acr
    as decimal
    format "->>>,>>>,>>9.99":U
    decimals 2
    label "Valor Original"
    column-label "Valor Original"
    no-undo.
def var v_val_sdo_tit_acr
    as decimal
    format "->>>,>>>,>>9.99":U
    decimals 2
    label "Valor Saldo"
    column-label "Valor Saldo"
    no-undo.
def var v_val_tot_cr_clien
    as decimal
    format ">>,>>>,>>>,>>9.99":U
    decimals 2
    label "Total de CrÇditos"
    column-label "Total de CrÇditos"
    no-undo.
def var v_val_tot_cr_clien_sdo
    as decimal
    format "->>,>>>,>>>,>>9.99":U
    decimals 2
    no-undo.
def var v_val_tot_espec
    as decimal
    format "->>,>>>,>>>,>>9.99":U
    decimals 2
    label "Total EspÇcie"
    column-label "Total EspÇcie"
    no-undo.
def var v_val_tot_espec_sdo
    as decimal
    format "->>,>>>,>>>,>>9.99":U
    decimals 2
    no-undo.
def var v_val_tot_geral_acr
    as decimal
    format "->>>,>>>,>>>,>>9.99":U
    decimals 2
    label "Total Geral"
    column-label "Total Geral"
    no-undo.
def var v_val_tot_geral_acr_sdo
    as decimal
    format "->>>,>>>,>>>,>>9.99":U
    decimals 2
    no-undo.
def var v_val_tot_repres
    as decimal
    format "->>,>>>,>>>,>>9.99":U
    decimals 2
    label "Tot Representante"
    column-label "Tot Representante"
    no-undo.
def var v_val_tot_repres_sdo
    as decimal
    format "->>,>>>,>>>,>>9.99":U
    decimals 2
    no-undo.
def var v_wgh_focus
    as widget-handle
    format ">>>>>>9":U
    no-undo.
def var v_wgh_frame_epc
    as widget-handle
    format ">>>>>>9":U
    no-undo.


/************************** Variable Definition End *************************/

/*************************** Menu Definition Begin **************************/

.

def menu      m_help                menubar
    menu-item mi_conteudo           label "&Conte£do"
    menu-item mi_sobre              label "&Sobre".



/**************************** Menu Definition End ***************************/

/************************ Rectangle Definition Begin ************************/

def rectangle rt_002
    size 1 by 1
    edge-pixels 2.
def rectangle rt_005
    size 1 by 1
    edge-pixels 2.
def rectangle rt_006
    size 1 by 1
    edge-pixels 2.
def rectangle rt_008
    size 1 by 1
    edge-pixels 2.
def rectangle rt_010
    size 1 by 1
    edge-pixels 2.
def rectangle rt_cxcf
    size 1 by 1
    fgcolor 1 edge-pixels 2.
def rectangle rt_dimensions
    size 1 by 1
    edge-pixels 2.
def rectangle rt_run
    size 1 by 1
    edge-pixels 2.
def rectangle rt_target
    size 1 by 1
    edge-pixels 2.


/************************* Rectangle Definition End *************************/

/************************** Button Definition Begin *************************/

def button bt_can
    label "Cancela"
    tooltip "Cancela"
    size 1 by 1
    auto-endkey.
def button bt_classificacao
    label "Classificaá∆o"
    tooltip "Classificaá∆o"
&if "{&window-system}" <> "TTY" &then
    image-up file "image/im-cla.bmp"
    image-insensitive file "image/ii-cla.bmp"
&endif
    size 1 by 1.
def button bt_close
    label "&Fecha"
    tooltip "Fecha"
    size 1 by 1
    auto-go.
def button bt_get_file
    label "Pesquisa Arquivo"
    tooltip "Pesquisa Arquivo"
&if "{&window-system}" <> "TTY" &then
    image-up file "image/im-sea1"
    image-insensitive file "image/ii-sea1"
&endif
    size 1 by 1.
def button bt_hel2
    label "Ajuda"
    tooltip "Ajuda"
    size 1 by 1.
def button bt_print
    label "&Imprime"
    tooltip "Imprime"
    size 1 by 1
    auto-go.
def button bt_ran2
    label "Faixa"
    tooltip "Faixa"
&if "{&window-system}" <> "TTY" &then
    image-up file "image/im-ran"
    image-insensitive file "image/ii-ran"
&endif
    size 1 by 1.
def button bt_set_printer
    label "Define Impressora e Layout"
    tooltip "Define Impressora e Layout de Impress∆o"
&if "{&window-system}" <> "TTY" &then
    image-up file "image/im-setpr.bmp"
    image-insensitive file "image/ii-setpr"
&endif
    size 1 by 1.
/****************************** Function Button *****************************/
def button bt_zoo_194804
    label "Zoom"
    tooltip "Zoom"
&if "{&window-system}" <> "TTY" &then
    image-up file "image/im-zoo"
    image-insensitive file "image/ii-zoo"
&endif
    size 4 by .88.
def button bt_zoo_194805
    label "Zoom"
    tooltip "Zoom"
&if "{&window-system}" <> "TTY" &then
    image-up file "image/im-zoo"
    image-insensitive file "image/ii-zoo"
&endif
    size 4 by .88.


/*************************** Button Definition End **************************/

/************************** Editor Definition Begin *************************/

def var ed_1x40
    as character
    view-as editor no-word-wrap
    size 40 by 1
    bgcolor 15 font 2
    no-undo.


/*************************** Editor Definition End **************************/

/************************ Radio-Set Definition Begin ************************/

def var rs_cod_dwb_output
    as character
    initial "Terminal"
    view-as radio-set Horizontal
    radio-buttons "Terminal", "Terminal", "Arquivo", "Arquivo", "Impressora", "Impressora"
     /*l_terminal*/ /*l_terminal*/ /*l_file*/ /*l_file*/ /*l_printer*/ /*l_printer*/
    bgcolor 8 
    no-undo.
def var rs_ind_run_mode
    as character
    initial "On-Line"
    view-as radio-set Horizontal
    radio-buttons "On-Line", "On-Line", "Batch", "Batch"
     /*l_online*/ /*l_online*/ /*l_batch*/ /*l_batch*/
    bgcolor 8 
    no-undo.
def var rs_prev_antec
    as character
    initial "Previs‰es"
    view-as radio-set Vertical
    radio-buttons "Previs‰es", "Previs‰es", "Antecipaá‰es", "Antecipaá‰es"
     /*l_previsoes*/ /*l_previsoes*/ /*l_antecipacoes*/ /*l_antecipacoes*/
    bgcolor 8 
    no-undo.


/************************* Radio-Set Definition End *************************/

/************************** Report Definition Begin *************************/

def new shared var v_rpt_s_1_lines as integer initial 66.
def new shared var v_rpt_s_1_columns as integer initial 172.
def new shared var v_rpt_s_1_bottom as integer initial 65.
def new shared var v_rpt_s_1_page as integer.
def new shared var v_rpt_s_1_name as character initial "Antecipaá‰es/Previs‰es Contas a Receber".
def frame f_rpt_s_1_header_period header
    "-------------------------------------------------------------------------------------------------------------------------------------------------------------" at 1
    "P†gina: " at 159
    (page-number (s_1) + v_rpt_s_1_page) to 172 format ">>>>>9" skip
    v_nom_enterprise at 1 format "x(40)"
    fill(" ", 40 - length(trim(v_nom_report_title))) + trim(v_nom_report_title) to 172 format "x(40)" skip
    "Per°odo: " at 1
    v_dat_inic_period at 10 format "99/99/9999"
    "A" at 21
    v_dat_fim_period at 23 format "99/99/9999"
    "------------------------------------------------------------------------------------------------------------------------" at 34
    v_dat_execution at 155 format "99/99/9999"
    "-" at 166
    v_hra_execution at 168 format "99:99" skip (1)
    with no-box no-labels width 172 page-top stream-io.
def frame f_rpt_s_1_header_unique header
    "-------------------------------------------------------------------------------------------------------------------------------------------------------------" at 1
    "P†gina: " at 159
    (page-number (s_1) + v_rpt_s_1_page) to 172 format ">>>>>9" skip
    v_nom_enterprise at 1 format "x(40)"
    fill(" ", 40 - length(trim(v_nom_report_title))) + trim(v_nom_report_title) to 172 format "x(40)" skip
    "---------------------------------------------------------------------------------------------------------------------------------------------------------" at 1
    v_dat_execution at 155 format "99/99/9999"
    "-" at 166
    v_hra_execution at 168 format "99:99" skip (1)
    with no-box no-labels width 172 page-top stream-io.
def frame f_rpt_s_1_footer_last_page header
    skip (1)
    "Èltima p†gina" at 1
    "--------------------------------------------------------------------------------------------------------------------------------------" at 15
    v_nom_prog_ext at 150 format "x(8)"
    "-" at 159
    v_cod_release at 161 format "x(12)" skip
    with no-box no-labels width 172 page-bottom stream-io.
def frame f_rpt_s_1_footer_normal header
    skip (1)
    "----------------------------------------------------------------------------------------------------------------------------------------------------" at 1
    v_nom_prog_ext at 150 format "x(8)"
    "-" at 159
    v_cod_release at 161 format "x(12)" skip
    with no-box no-labels width 172 page-bottom stream-io.
def frame f_rpt_s_1_footer_param_page header
    skip (1)
    "P†gina ParÉmetros" at 2
    "-----------------------------------------------------------------------------------------------------------------------------" at 24
    v_nom_prog_ext at 150 format "x(8)"
    "-" at 159
    v_cod_release at 161 format "x(12)" skip
    with no-box no-labels width 172 page-bottom stream-io.
def frame f_rpt_s_1_Grp_cab_complem_Lay_compl_cab header
    "---- Moeda Original ----" at 69
    "--------- Moeda Apresentaá∆o --------" at 94 skip
    with no-box no-labels width 172 page-top stream-io.
def frame f_rpt_s_1_Grp_cab_complem_Lay_compl_cab2 header
    "---- Moeda Original ----" at 78
    "--------- Moeda Apresentaá∆o --------" at 104 skip
    with no-box no-labels width 172 page-top stream-io.
def frame f_rpt_s_1_Grp_cab_princip_Lay_cab_princip header
&IF "{&emsfin_version}" >= "" AND "{&emsfin_version}" < "5.07A" &THEN
    "Estab" at 1
&ENDIF
&IF "{&emsfin_version}" >= "5.07A" AND "{&emsfin_version}" < "9.99" &THEN
    "Estab" at 1
&ENDIF
    "Esp" at 7
    "SÇrie" at 11
    "T°tulo" at 17
    "/P" at 34
    "UN" at 37
    "Port" at 41
    "Car" at 47
    "Emiss∆o" at 51
    "Vencto" at 60
    "Moeda" at 69
    "Saldo T°tulo" to 91
    "Vl Original" to 108
    "Saldo" to 128
    "Cod. Emp. Convenio" at 130
    "Cod.Convànio" at 151 skip
&IF "{&emsfin_version}" >= "" AND "{&emsfin_version}" < "5.07A" &THEN
    "-----" at 1
&ENDIF
&IF "{&emsfin_version}" >= "5.07A" AND "{&emsfin_version}" < "9.99" &THEN
    "-----" at 1
&ENDIF
    "---" at 7
    "-----" at 11
    "----------------" at 17
    "--" at 34
    "---" at 37
    "-----" at 41
    "---" at 47
    "--------" at 51
    "--------" at 60
    "--------" at 69
    "--------------" to 91
    "---------------" to 108
    "---------------" to 128
    "--------------------" at 130
    "------------" at 151 skip
    with no-box no-labels width 172 page-top stream-io.
def frame f_rpt_s_1_Grp_cab_princip_Lay_cab_princip2 header
&IF "{&emsfin_version}" >= "" AND "{&emsfin_version}" < "5.07A" &THEN
    "Est" at 1
&ENDIF
&IF "{&emsfin_version}" >= "5.07A" AND "{&emsfin_version}" < "9.99" &THEN
    "Est" at 1
&ENDIF
    "Esp" at 7
    "SÇrie" at 11
    "T°tulo" at 17
    "/P" at 34
    "Cliente" to 47
    "UN" at 49
    "Port" at 53
    "Car" at 59
    "Emiss∆o" at 63
    "Vencto" at 72
    "Moeda" at 81
    "Saldo T°tulo" to 103
    "Vl Original" to 119
    "Saldo" to 138
    "Cod. Emp. Convenio" at 140
    "Cod.Convànio" at 161 skip
&IF "{&emsfin_version}" >= "" AND "{&emsfin_version}" < "5.07A" &THEN
    "---" at 1
&ENDIF
&IF "{&emsfin_version}" >= "5.07A" AND "{&emsfin_version}" < "9.99" &THEN
    "-----" at 1
&ENDIF
    "---" at 7
    "-----" at 11
    "----------------" at 17
    "--" at 34
    "-----------" to 47
    "---" at 49
    "-----" at 53
    "---" at 59
    "--------" at 63
    "--------" at 72
    "--------" at 81
    "--------------" to 103
    "---------------" to 119
    "---------------" to 138
    "--------------------" at 140
    "------------" at 161 skip
    with no-box no-labels width 172 page-top stream-io.
def frame f_rpt_s_1_Grp_param_Lay_param_1 header
    skip (1)
    "---------------------------------------------" at 33
    "Visualizaá∆o" at 79
    "---------------------------------------------" at 93
    skip (1)
    "  Visualiza: " at 74
    v_ind_visualiz_tit_acr_vert at 87 format "X(20)" view-as text skip
    v_ind_classif at 87 format "X(35)" view-as text
    skip (1)
    "---------------------------------------------" at 33
    "Apresentaá∆o  " at 79
    "---------------------------------------------" at 93
    skip (1)
    "    Finalidade Econìmica: " at 61
    v_cod_finalid_econ at 87 format "x(10)" view-as text skip
    "Finalid Apresentaá∆o: " at 65
    v_cod_finalid_econ_apres at 87 format "x(10)" view-as text skip
    "Data Cotaá∆o: " at 73
    v_dat_cotac_indic_econ at 87 format "99/99/9999" view-as text
    skip (1)
    "---------------------------------------------" at 33
    "Tipo EspÇcie  " at 79
    "---------------------------------------------" at 93
    skip (1)
    v_ind_tip_espec_docto at 78 format "X(17)" view-as text
    skip (1)
    "---------------------------------------------" at 37
    "Opá‰es" at 83
    "---------------------------------------------" at 90
    skip (1)
    "Totaliza por EspÇcie:    " at 72
    v_log_tot_por_espec at 100 format "Sim/N∆o" view-as text skip
    "Lista AN/PREV Totalmente Abatidas:       " at 59
    v_log_sdo_zero at 100 format "Sim/N∆o" view-as text skip
    "Lista Pedidos:   " at 79
    v_log_lista_ped at 100 format "Sim/N∆o" view-as text skip
    "Lista Abatimentos Pendentes:      " at 65
    v_log_lista_abat_pend at 100 format "Sim/N∆o" view-as text skip
    "Lista Conta Cont†bil:    " at 72
    v_log_lista_cta_ctbl at 100 format "Sim/N∆o" view-as text skip
    with no-box no-labels width 172 page-top stream-io.
def frame f_rpt_s_1_Grp_pendencias_Lay_pendencias header
&IF "{&emsfin_version}" >= "" AND "{&emsfin_version}" < "5.07A" &THEN
    "Est" at 130
&ENDIF
&IF "{&emsfin_version}" >= "5.07A" AND "{&emsfin_version}" < "9.99" &THEN
    "Est" at 130
&ENDIF
    "Referància" at 136
    "Seq" to 153
    "Valor Abatimento" to 170 skip
&IF "{&emsfin_version}" >= "" AND "{&emsfin_version}" < "5.07A" &THEN
    "---" at 130
&ENDIF
&IF "{&emsfin_version}" >= "5.07A" AND "{&emsfin_version}" < "9.99" &THEN
    "-----" at 130
&ENDIF
    "----------" at 136
    "-------" to 153
    "----------------" to 170 skip
    with no-box no-labels width 172 page-top stream-io.
def frame f_rpt_s_1_Grp_repre_client_Lay_tit_cliente header
    "Cliente: " at 7
    v_cdn_cliente_ant to 26 format ">>>,>>>,>>9" view-as text
    v_nom_pessoa_cli at 28 format "x(40)" view-as text skip
    with no-box no-labels width 172 page-top stream-io.
def frame f_rpt_s_1_Grp_repre_client_Lay_tit_repres header
    "Representante: " at 1
    v_cdn_repres_ant to 22 format ">>>,>>9" view-as text
    v_nom_pessoa_rep at 24 format "x(40)" view-as text skip
    with no-box no-labels width 172 page-top stream-io.
def frame f_rpt_s_1_Grp_totais_Lay_Cliente header
    "Total Cliente:" at 78
    v_val_tot_cr_clien to 108 format ">>,>>>,>>>,>>9.99" view-as text
    v_val_tot_cr_clien_sdo to 128 format "->>,>>>,>>>,>>9.99" view-as text skip
    with no-box no-labels width 172 page-top stream-io.
def frame f_rpt_s_1_Grp_totais_Lay_especie header
    "Total EspÇcie:" at 77
    v_val_tot_espec to 108 format "->>,>>>,>>>,>>9.99" view-as text
    v_val_tot_espec_sdo to 128 format "->>,>>>,>>>,>>9.99" view-as text skip
    with no-box no-labels width 172 page-top stream-io.
def frame f_rpt_s_1_Grp_totais_Lay_especie2 header
    "Total EspÇcie:" at 86
    v_val_tot_espec to 118 format "->>,>>>,>>>,>>9.99" view-as text
    v_val_tot_espec_sdo to 138 format "->>,>>>,>>>,>>9.99" view-as text skip
    with no-box no-labels width 172 page-top stream-io.
def frame f_rpt_s_1_Grp_totais_Lay_geral header
    "Total Geral:" at 78
    v_val_tot_geral_acr to 108 format "->>>,>>>,>>>,>>9.99" view-as text
    v_val_tot_geral_acr_sdo to 128 format "->>>,>>>,>>>,>>9.99" view-as text skip
    with no-box no-labels width 172 page-top stream-io.
def frame f_rpt_s_1_Grp_totais_Lay_geral2 header
    "Total Geral:" at 88
    v_val_tot_geral_acr to 118 format "->>>,>>>,>>>,>>9.99" view-as text
    v_val_tot_geral_acr_sdo to 138 format "->>>,>>>,>>>,>>9.99" view-as text skip
    with no-box no-labels width 172 page-top stream-io.
def frame f_rpt_s_1_Grp_totais_lay_repres header
    "Total Representante:" at 71
    v_val_tot_repres to 108 format "->>,>>>,>>>,>>9.99" view-as text
    v_val_tot_repres_sdo to 128 format "->>,>>>,>>>,>>9.99" view-as text skip
    with no-box no-labels width 172 page-top stream-io.


/*************************** Report Definition End **************************/

/************************** Frame Definition Begin **************************/

def frame f_rpt_41_tit_acr_antecip_prev
    rt_002
         at row 04.75 col 02.00
    " Apresentaá∆o " view-as text
         at row 04.45 col 04.00 bgcolor 8 
    rt_008
         at row 04.75 col 48.00
    " Opá‰es " view-as text
         at row 04.45 col 50.00 bgcolor 8 
    rt_006
         at row 01.38 col 02.00
    " Visualizaá∆o " view-as text
         at row 01.08 col 04.00 bgcolor 8 
    rt_target
         at row 11.13 col 02.00
    " Destino " view-as text
         at row 10.83 col 04.00 bgcolor 8 
    rt_005
         at row 01.38 col 48.00
    " Tipo EspÇcie " view-as text
         at row 01.08 col 50.00 bgcolor 8 
    rt_run
         at row 11.13 col 48.00
    " Execuá∆o " view-as text
         at row 10.83 col 50.00
    rt_dimensions
         at row 11.13 col 72.72
    " Dimens‰es " view-as text
         at row 10.83 col 74.72
    rt_010
         at row 01.38 col 81.14 bgcolor 8 
    rt_cxcf
         at row 14.63 col 02.00 bgcolor 7 
    v_ind_visualiz_tit_acr_vert
         at row 02.21 col 03.00 no-label
         help "Visualiza T°tulos por Estabelecimento ou UN"
         view-as radio-set Vertical
         radio-buttons "Por Estabelecimento", "Por Estabelecimento", "Por Unidade Neg¢cio", "Por Unidade Neg¢cio"
          /*l_por_estabelecimento*/ /*l_por_estabelecimento*/ /*l_por_unid_negoc*/ /*l_por_unid_negoc*/
         bgcolor 8 
    rs_prev_antec
         at row 02.21 col 49.00
         help "" no-label
    bt_ran2
         at row 01.63 col 82.86 font ?
         help "Faixa"
    bt_classificacao
         at row 03.00 col 82.86 font ?
         help "Classificaá∆o"
    v_cod_finalid_econ
         at row 06.50 col 25.86 colon-aligned label "Finalidade Econìmica"
         help "Finalidade Econìmica"
         view-as fill-in
         size-chars 11.14 by .88
         fgcolor ? bgcolor 15 font 2
    bt_zoo_194804
         at row 06.50 col 39.00
    v_cod_finalid_econ_apres
         at row 07.50 col 25.86 colon-aligned label "Finalid Apresentaá∆o"
         view-as fill-in
         size-chars 11.14 by .88
         fgcolor ? bgcolor 15 font 2
    bt_zoo_194805
         at row 07.50 col 39.00
    v_dat_cotac_indic_econ
         at row 08.50 col 25.86 colon-aligned label "Data Cotaá∆o"
         view-as fill-in
         size-chars 11.14 by .88
         fgcolor ? bgcolor 15 font 2
    v_log_tot_por_espec
         at row 05.50 col 49.00 label "Totaliza por EspÇcie"
         view-as toggle-box
    v_log_sdo_zero
         at row 06.50 col 49.00 label "Lista AN/PREV Totalmente Abatidas"
         view-as toggle-box
    v_log_lista_ped
         at row 07.50 col 49.00 label "Lista Pedidos de Venda"
         view-as toggle-box
    v_log_lista_abat_pend
         at row 08.50 col 49.00 label "Lista Abatimentos Pendentes"
         view-as toggle-box
    rs_cod_dwb_output
         at row 11.83 col 03.00
         help "" no-label
    ed_1x40
         at row 12.79 col 03.00
         help "" no-label
    rs_ind_run_mode
         at row 11.83 col 49.00
         help "" no-label
    v_log_print_par
         at row 12.83 col 49.00 label "Imprime ParÉmetros"
         view-as toggle-box
    bt_set_printer
         at row 12.79 col 42.00 font ?
         help "Define Impressora e Layout de Impress∆o"
    bt_get_file
         at row 12.79 col 42.00 font ?
         help "Pesquisa Arquivo"
    v_qtd_line
         at row 11.83 col 81.00 colon-aligned
         view-as fill-in
         size-chars 4.14 by .88
         fgcolor ? bgcolor 15 font 2
    v_qtd_column
         at row 12.83 col 81.00 colon-aligned
         view-as fill-in
         size-chars 4.14 by .88
         fgcolor ? bgcolor 15 font 2
    bt_close
         at row 14.83 col 03.00 font ?
         help "Fecha"
    bt_print
         at row 14.83 col 14.00 font ?
         help "Imprime"
    bt_can
         at row 14.83 col 25.00 font ?
         help "Cancela"
    v_log_lista_cta_ctbl
         at row 09.50 col 49.00 label "Lista Conta Cont†bil"
         view-as toggle-box
    bt_hel2
         at row 14.83 col 77.57 font ?
         help "Ajuda"
    with 1 down side-labels no-validate keep-tab-order three-d
         size-char 90.00 by 16.46
         view-as dialog-box
         font 1 fgcolor ? bgcolor 8
         title "Relat¢rio de Antecipaá‰es/Previs‰es".
    /* adjust size of objects in this frame */
    assign bt_can:width-chars            in frame f_rpt_41_tit_acr_antecip_prev = 10.00
           bt_can:height-chars           in frame f_rpt_41_tit_acr_antecip_prev = 01.00
           bt_classificacao:width-chars  in frame f_rpt_41_tit_acr_antecip_prev = 04.00
           bt_classificacao:height-chars in frame f_rpt_41_tit_acr_antecip_prev = 01.13
           bt_close:width-chars          in frame f_rpt_41_tit_acr_antecip_prev = 10.00
           bt_close:height-chars         in frame f_rpt_41_tit_acr_antecip_prev = 01.00
           bt_get_file:width-chars       in frame f_rpt_41_tit_acr_antecip_prev = 04.00
           bt_get_file:height-chars      in frame f_rpt_41_tit_acr_antecip_prev = 01.08
           bt_hel2:width-chars           in frame f_rpt_41_tit_acr_antecip_prev = 10.00
           bt_hel2:height-chars          in frame f_rpt_41_tit_acr_antecip_prev = 01.00
           bt_print:width-chars          in frame f_rpt_41_tit_acr_antecip_prev = 10.00
           bt_print:height-chars         in frame f_rpt_41_tit_acr_antecip_prev = 01.00
           bt_ran2:width-chars           in frame f_rpt_41_tit_acr_antecip_prev = 04.00
           bt_ran2:height-chars          in frame f_rpt_41_tit_acr_antecip_prev = 01.13
           bt_set_printer:width-chars    in frame f_rpt_41_tit_acr_antecip_prev = 04.00
           bt_set_printer:height-chars   in frame f_rpt_41_tit_acr_antecip_prev = 01.08
           ed_1x40:width-chars           in frame f_rpt_41_tit_acr_antecip_prev = 38.00
           ed_1x40:height-chars          in frame f_rpt_41_tit_acr_antecip_prev = 01.00
           rt_002:width-chars            in frame f_rpt_41_tit_acr_antecip_prev = 45.00
           rt_002:height-chars           in frame f_rpt_41_tit_acr_antecip_prev = 06.00
           rt_005:width-chars            in frame f_rpt_41_tit_acr_antecip_prev = 32.29
           rt_005:height-chars           in frame f_rpt_41_tit_acr_antecip_prev = 03.00
           rt_006:width-chars            in frame f_rpt_41_tit_acr_antecip_prev = 45.00
           rt_006:height-chars           in frame f_rpt_41_tit_acr_antecip_prev = 03.00
           rt_008:width-chars            in frame f_rpt_41_tit_acr_antecip_prev = 40.43
           rt_008:height-chars           in frame f_rpt_41_tit_acr_antecip_prev = 06.00
           rt_010:width-chars            in frame f_rpt_41_tit_acr_antecip_prev = 07.29
           rt_010:height-chars           in frame f_rpt_41_tit_acr_antecip_prev = 03.00
           rt_cxcf:width-chars           in frame f_rpt_41_tit_acr_antecip_prev = 86.57
           rt_cxcf:height-chars          in frame f_rpt_41_tit_acr_antecip_prev = 01.42
           rt_dimensions:width-chars     in frame f_rpt_41_tit_acr_antecip_prev = 15.72
           rt_dimensions:height-chars    in frame f_rpt_41_tit_acr_antecip_prev = 03.00
           rt_run:width-chars            in frame f_rpt_41_tit_acr_antecip_prev = 23.86
           rt_run:height-chars           in frame f_rpt_41_tit_acr_antecip_prev = 03.00
           rt_target:width-chars         in frame f_rpt_41_tit_acr_antecip_prev = 45.00
           rt_target:height-chars        in frame f_rpt_41_tit_acr_antecip_prev = 03.00.
    /* set return-inserted = yes for editors */
    assign ed_1x40:return-inserted in frame f_rpt_41_tit_acr_antecip_prev = yes.
    /* set private-data for the help system */
    assign v_ind_visualiz_tit_acr_vert:private-data in frame f_rpt_41_tit_acr_antecip_prev = "HLP=000023756":U
           rs_prev_antec:private-data               in frame f_rpt_41_tit_acr_antecip_prev = "HLP=000018136":U
           bt_ran2:private-data                     in frame f_rpt_41_tit_acr_antecip_prev = "HLP=000008773":U
           bt_classificacao:private-data            in frame f_rpt_41_tit_acr_antecip_prev = "HLP=000021578":U
           bt_zoo_194804:private-data               in frame f_rpt_41_tit_acr_antecip_prev = "HLP=000009431":U
           v_cod_finalid_econ:private-data          in frame f_rpt_41_tit_acr_antecip_prev = "HLP=000014662":U
           bt_zoo_194805:private-data               in frame f_rpt_41_tit_acr_antecip_prev = "HLP=000009431":U
           v_cod_finalid_econ_apres:private-data    in frame f_rpt_41_tit_acr_antecip_prev = "HLP=000014663":U
           v_dat_cotac_indic_econ:private-data      in frame f_rpt_41_tit_acr_antecip_prev = "HLP=000012264":U
           v_log_tot_por_espec:private-data         in frame f_rpt_41_tit_acr_antecip_prev = "HLP=000023873":U
           v_log_sdo_zero:private-data              in frame f_rpt_41_tit_acr_antecip_prev = "HLP=000023871":U
           v_log_lista_ped:private-data             in frame f_rpt_41_tit_acr_antecip_prev = "HLP=000023869":U
           v_log_lista_abat_pend:private-data       in frame f_rpt_41_tit_acr_antecip_prev = "HLP=000023867":U
           rs_cod_dwb_output:private-data           in frame f_rpt_41_tit_acr_antecip_prev = "HLP=000018136":U
           ed_1x40:private-data                     in frame f_rpt_41_tit_acr_antecip_prev = "HLP=000018136":U
           rs_ind_run_mode:private-data             in frame f_rpt_41_tit_acr_antecip_prev = "HLP=000018136":U
           v_log_print_par:private-data             in frame f_rpt_41_tit_acr_antecip_prev = "HLP=000024662":U
           bt_set_printer:private-data              in frame f_rpt_41_tit_acr_antecip_prev = "HLP=000008785":U
           bt_get_file:private-data                 in frame f_rpt_41_tit_acr_antecip_prev = "HLP=000008782":U
           v_qtd_line:private-data                  in frame f_rpt_41_tit_acr_antecip_prev = "HLP=000024737":U
           v_qtd_column:private-data                in frame f_rpt_41_tit_acr_antecip_prev = "HLP=000024669":U
           bt_close:private-data                    in frame f_rpt_41_tit_acr_antecip_prev = "HLP=000009420":U
           bt_print:private-data                    in frame f_rpt_41_tit_acr_antecip_prev = "HLP=000010815":U
           bt_can:private-data                      in frame f_rpt_41_tit_acr_antecip_prev = "HLP=000011050":U
           v_log_lista_cta_ctbl:private-data        in frame f_rpt_41_tit_acr_antecip_prev = "HLP=000023868":U
           bt_hel2:private-data                     in frame f_rpt_41_tit_acr_antecip_prev = "HLP=000011326":U
           frame f_rpt_41_tit_acr_antecip_prev:private-data                                = "HLP=000018136".
    /* enable function buttons */
    assign bt_zoo_194804:sensitive in frame f_rpt_41_tit_acr_antecip_prev = yes
           bt_zoo_194805:sensitive in frame f_rpt_41_tit_acr_antecip_prev = yes.
    /* move buttons to top */
    bt_zoo_194804:move-to-top().
    bt_zoo_194805:move-to-top().



{include/i_fclfrm.i f_rpt_41_tit_acr_antecip_prev }
/*************************** Frame Definition End ***************************/

/* tech38629 - Alteraá∆o efetuada via filtro */
&if '{&emsbas_version}':U >= '5.05':U &then
def var v_prog_filtro_pdf as handle no-undo.

function getCodTipoRelat returns character in v_prog_filtro_pdf.

run prgtec/btb/btb920aa.py persistent set v_prog_filtro_pdf.

run pi_define_objetos in v_prog_filtro_pdf (frame f_rpt_41_tit_acr_antecip_prev:handle,
                       rs_cod_dwb_output:handle in frame f_rpt_41_tit_acr_antecip_prev,
                       bt_get_file:row in frame f_rpt_41_tit_acr_antecip_prev,
                       bt_get_file:col in frame f_rpt_41_tit_acr_antecip_prev).

&endif
/* tech38629 - Fim da alteraá∆o */


/*********************** User Interface Trigger Begin ***********************/


ON CHOOSE OF bt_classificacao IN FRAME f_rpt_41_tit_acr_antecip_prev
DO:

    if  search("prgfin/acr/acr339za.r") = ? and search("prgfin/acr/acr339za.p") = ? then do:
        if  v_cod_dwb_user begins 'es_' then
            return "Programa execut†vel n∆o foi encontrado:" /*l_programa_nao_encontrado*/  + "prgfin/acr/acr339za.p".
        else do:
            message "Programa execut†vel n∆o foi encontrado:" /*l_programa_nao_encontrado*/  "prgfin/acr/acr339za.p"
                   view-as alert-box error buttons ok.
            return.
        end.
    end.
    else
        run prgfin/acr/acr339za.p /*prg_fnc_tit_acr_ant_prev_classif*/.
END. /* ON CHOOSE OF bt_classificacao IN FRAME f_rpt_41_tit_acr_antecip_prev */

ON CHOOSE OF bt_get_file IN FRAME f_rpt_41_tit_acr_antecip_prev
DO:

    system-dialog get-file v_cod_dwb_file
        title "Imprimir" /*l_imprimir*/ 
        filters '*.rpt' '*.rpt',
                "*.*"   "*.*"
        save-as
        create-test-file
        ask-overwrite.
        assign dwb_rpt_param.cod_dwb_file             = v_cod_dwb_file
               ed_1x40:screen-value in frame f_rpt_41_tit_acr_antecip_prev = v_cod_dwb_file.

END. /* ON CHOOSE OF bt_get_file IN FRAME f_rpt_41_tit_acr_antecip_prev */

ON CHOOSE OF bt_hel2 IN FRAME f_rpt_41_tit_acr_antecip_prev
DO:


    /* Begin_Include: i_context_help_frame */
    run prgtec/men/men900za.py (Input self:frame,
                                Input this-procedure:handle) /*prg_fnc_chamar_help_context*/.


    /* End_Include: i_context_help_frame */

END. /* ON CHOOSE OF bt_hel2 IN FRAME f_rpt_41_tit_acr_antecip_prev */

ON CHOOSE OF bt_print IN FRAME f_rpt_41_tit_acr_antecip_prev
DO:

    if  input frame f_rpt_41_tit_acr_antecip_prev v_cod_finalid_econ       = "" /*l_null*/  or
        input frame f_rpt_41_tit_acr_antecip_prev v_cod_finalid_econ_apres = "" /*l_null*/ 
    then do:
        /* Finalidade Econìmica inexistente ! */
        run pi_messages (input "show",
                         input 1652,
                         input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")) /*msg_1652*/.
        return no-apply.
    end /* if */.

    print_block:
    do on error undo print_block, return no-apply:
        run pi_vld_valores_apres_apb_acr (Input input frame f_rpt_41_tit_acr_antecip_prev v_cod_finalid_econ,
                                          Input input frame f_rpt_41_tit_acr_antecip_prev v_cod_finalid_econ_apres,
                                          Input input frame f_rpt_41_tit_acr_antecip_prev v_dat_cotac_indic_econ,
                                          output v_dat_conver,
                                          output v_val_cotac_indic_econ) /*pi_vld_valores_apres_apb_acr*/.
do:
/* tech38629 - Alteraá∆o efetuada via filtro */
&if '{&emsbas_version}':U >= '5.05':U &then
    run pi_restricoes in v_prog_filtro_pdf (input rs_cod_dwb_output:screen-value in frame f_rpt_41_tit_acr_antecip_prev).
    if return-value = 'nok' then 
        return no-apply.
&endif
/* tech38629 - Fim da alteraá∆o */
        assign v_log_print = yes.
end.
    end /* do print_block */.
END. /* ON CHOOSE OF bt_print IN FRAME f_rpt_41_tit_acr_antecip_prev */

ON CHOOSE OF bt_ran2 IN FRAME f_rpt_41_tit_acr_antecip_prev
DO:

    assign input frame f_rpt_41_tit_acr_antecip_prev v_ind_visualiz_tit_acr_vert.
    if  search("prgfin/acr/acr339zb.r") = ? and search("prgfin/acr/acr339zb.p") = ? then do:
        if  v_cod_dwb_user begins 'es_' then
            return "Programa execut†vel n∆o foi encontrado:" /*l_programa_nao_encontrado*/  + "prgfin/acr/acr339zb.p".
        else do:
            message "Programa execut†vel n∆o foi encontrado:" /*l_programa_nao_encontrado*/  "prgfin/acr/acr339zb.p"
                   view-as alert-box error buttons ok.
            return.
        end.
    end.
    else
        run prgfin/acr/acr339zb.p /*prg_fnc_tit_acr_ant_prev_faixa*/.
END. /* ON CHOOSE OF bt_ran2 IN FRAME f_rpt_41_tit_acr_antecip_prev */

ON CHOOSE OF bt_set_printer IN FRAME f_rpt_41_tit_acr_antecip_prev
DO:

    assign v_nom_dwb_printer      = ""
           v_cod_dwb_print_layout = "".

    &if '{&emsbas_version}' <= '1.00' &then
    if  search("prgtec/btb/btb036nb.r") = ? and search("prgtec/btb/btb036nb.p") = ? then do:
        if  v_cod_dwb_user begins 'es_' then
            return "Programa execut†vel n∆o foi encontrado:" /*l_programa_nao_encontrado*/  + "prgtec/btb/btb036nb.p".
        else do:
            message "Programa execut†vel n∆o foi encontrado:" /*l_programa_nao_encontrado*/  "prgtec/btb/btb036nb.p"
                   view-as alert-box error buttons ok.
            return.
        end.
    end.
    else
        run prgtec/btb/btb036nb.p (output v_nom_dwb_printer,
                               output v_cod_dwb_print_layout) /*prg_see_layout_impres_imprsor*/.
    &else
    if  search("prgtec/btb/btb036zb.r") = ? and search("prgtec/btb/btb036zb.p") = ? then do:
        if  v_cod_dwb_user begins 'es_' then
            return "Programa execut†vel n∆o foi encontrado:" /*l_programa_nao_encontrado*/  + "prgtec/btb/btb036zb.p".
        else do:
            message "Programa execut†vel n∆o foi encontrado:" /*l_programa_nao_encontrado*/  "prgtec/btb/btb036zb.p"
                   view-as alert-box error buttons ok.
            return.
        end.
    end.
    else
        run prgtec/btb/btb036zb.p (input-output v_nom_dwb_printer,
                               input-output v_cod_dwb_print_layout,
                               input-output v_nom_dwb_print_file) /*prg_fnc_layout_impres_imprsor*/.
    &endif

    if  v_nom_dwb_printer <> ""
    and  v_cod_dwb_print_layout <> ""
    then do:
        assign dwb_rpt_param.nom_dwb_printer      = v_nom_dwb_printer
               dwb_rpt_param.cod_dwb_print_layout = v_cod_dwb_print_layout
    &if '{&emsbas_version}' > '1.00' &then           
    &if '{&emsbas_version}' >= '5.03' &then           
               dwb_rpt_param.nom_dwb_print_file        = v_nom_dwb_print_file
    &else
               dwb_rpt_param.cod_livre_1               = v_nom_dwb_print_file
    &endif
    &endif
               ed_1x40:screen-value in frame f_rpt_41_tit_acr_antecip_prev = v_nom_dwb_printer
                                                       + ":"
                                                       + v_cod_dwb_print_layout
    &if '{&emsbas_version}' > '1.00' &then
                                                       + (if v_nom_dwb_print_file <> "" then ":" + v_nom_dwb_print_file
                                                          else "")
    &endif
    .
        find layout_impres no-lock
             where layout_impres.nom_impressora = dwb_rpt_param.nom_dwb_printer
               and layout_impres.cod_layout_impres = dwb_rpt_param.cod_dwb_print_layout /*cl_get_layout of layout_impres*/ no-error.
        assign v_qtd_line               = layout_impres.num_lin_pag.
        display v_qtd_line
                with frame f_rpt_41_tit_acr_antecip_prev.
    end /* if */.

END. /* ON CHOOSE OF bt_set_printer IN FRAME f_rpt_41_tit_acr_antecip_prev */

ON LEAVE OF ed_1x40 IN FRAME f_rpt_41_tit_acr_antecip_prev
DO:

    /************************* Variable Definition Begin ************************/

    def var v_cod_filename_final             as character       no-undo. /*local*/
    def var v_cod_filename_initial           as character       no-undo. /*local*/


    /************************** Variable Definition End *************************/

    block:
    do with frame f_rpt_41_tit_acr_antecip_prev:
        if  rs_cod_dwb_output:screen-value = "Arquivo" /*l_file*/ 
        then do:
            if  rs_ind_run_mode:screen-value <> "Batch" /*l_batch*/ 
            then do:
                if  ed_1x40:screen-value <> ""
                then do:
                    assign ed_1x40:screen-value   = replace(ed_1x40:screen-value, '~\', '/')
                           v_cod_filename_initial = entry(num-entries(ed_1x40:screen-value, '/'), ed_1x40:screen-value, '/')
                           v_cod_filename_final   = substring(ed_1x40:screen-value, 1,
                                                              length(ed_1x40:screen-value) - length(v_cod_filename_initial) - 1)
                           file-info:file-name    = v_cod_filename_final.
                    if  file-info:file-type = ?
                    then do:
                         /* O diret¢rio &1 n∆o existe ! */
                         run pi_messages (input "show",
                                          input 4354,
                                          input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9",
                                                             v_cod_filename_final)) /*msg_4354*/.
                         return no-apply.
                    end /* if */.
                end /* if */.
            end /* if */.

            find dwb_rpt_param
                where dwb_rpt_param.cod_dwb_user    = v_cod_usuar_corren
                and   dwb_rpt_param.cod_dwb_program = v_cod_dwb_program
                exclusive-lock no-error.
            assign dwb_rpt_param.cod_dwb_file = ed_1x40:screen-value.
        end /* if */.
    end /* do block */.

END. /* ON LEAVE OF ed_1x40 IN FRAME f_rpt_41_tit_acr_antecip_prev */

ON VALUE-CHANGED OF rs_cod_dwb_output IN FRAME f_rpt_41_tit_acr_antecip_prev
DO:

    initout:
    do with frame f_rpt_41_tit_acr_antecip_prev:
        /* block: */
        case self:screen-value:
            when "Terminal" /*l_terminal*/ then ter:
             do:
                if  rs_cod_dwb_output <> "Impressora" /*l_printer*/ 
                then do:
                    assign v_qtd_line_ant = input frame f_rpt_41_tit_acr_antecip_prev v_qtd_line.
                end /* if */.
                if  v_qtd_line_ant > 0
                then do:
                    assign v_qtd_line = v_qtd_line_ant.
                end /* if */.
                else do:
                    assign v_qtd_line = (if  dwb_rpt_param.qtd_dwb_line > 0 then dwb_rpt_param.qtd_dwb_line
                                        else v_rpt_s_1_lines).
                end /* else */.
                display v_qtd_line
                        with frame f_rpt_41_tit_acr_antecip_prev.
                assign ed_1x40:screen-value   = ""
                       ed_1x40:sensitive      = no
                       bt_get_file:visible    = no
                       bt_set_printer:visible = no.
            end /* do ter */.
            when "Arquivo" /*l_file*/ then fil:
             do:
                if  rs_cod_dwb_output <> "Impressora" /*l_printer*/ 
                then do:
                    assign v_qtd_line_ant = input frame f_rpt_41_tit_acr_antecip_prev v_qtd_line.
                end /* if */.
                if  v_qtd_line_ant > 0
                then do:
                    assign v_qtd_line = v_qtd_line_ant.
                end /* if */.
                else do:
                    assign v_qtd_line = (if  dwb_rpt_param.qtd_dwb_line > 0 then dwb_rpt_param.qtd_dwb_line
                                        else v_rpt_s_1_lines).
                end /* else */.
                display v_qtd_line
                        with frame f_rpt_41_tit_acr_antecip_prev.
                assign ed_1x40:screen-value   = ""
                       ed_1x40:sensitive      = yes
                       bt_set_printer:visible = no
                       bt_get_file:visible    = yes.

                /* define arquivo default */
                find usuar_mestre no-lock
                     where usuar_mestre.cod_usuario = v_cod_dwb_user
    &if "{&emsbas_version}" >= "5.01" &then
                     use-index srmstr_id
    &endif
                      /*cl_current_user of usuar_mestre*/ no-error.
                do  transaction:                
                    find dwb_rpt_param
                        where dwb_rpt_param.cod_dwb_user    = v_cod_usuar_corren
                        and   dwb_rpt_param.cod_dwb_program = v_cod_dwb_program
                        exclusive-lock no-error.

                    assign dwb_rpt_param.cod_dwb_file = "".

                    if  rs_ind_run_mode:screen-value in frame f_rpt_41_tit_acr_antecip_prev <> "Batch" /*l_batch*/ 
                    then do:
                        if  usuar_mestre.nom_dir_spool <> ""
                        then do:
                            assign dwb_rpt_param.cod_dwb_file = usuar_mestre.nom_dir_spool
                                                              + "~/".
                        end /* if */.
                        if  usuar_mestre.nom_subdir_spool <> ""
                        then do:
                            assign dwb_rpt_param.cod_dwb_file = dwb_rpt_param.cod_dwb_file
                                                              + usuar_mestre.nom_subdir_spool
                                                              + "~/".
                        end /* if */.
                    end /* if */.
                    else do:
                        assign dwb_rpt_param.cod_dwb_file = dwb_rpt_param.cod_dwb_file.
                    end /* else */.
                    if  v_cod_dwb_file_temp = ""
                    then do:
                        assign dwb_rpt_param.cod_dwb_file = dwb_rpt_param.cod_dwb_file
                                                          + caps("acr339ab":U)
                                                          + '.rpt'.
                    end /* if */.
                    else do:
                        assign dwb_rpt_param.cod_dwb_file = dwb_rpt_param.cod_dwb_file
                                                          + v_cod_dwb_file_temp.
                    end /* else */.
                    assign ed_1x40:screen-value               = dwb_rpt_param.cod_dwb_file
                           dwb_rpt_param.cod_dwb_print_layout = ""
                           v_qtd_line                         = (if v_qtd_line_ant > 0 then v_qtd_line_ant
                                                                 else v_rpt_s_1_lines)
    &if '{&emsbas_version}' > '1.00' &then
                           v_nom_dwb_print_file               = ""
    &endif
    .
                end.     
            end /* do fil */.
            when "Impressora" /*l_printer*/ then prn:
             do:
                if  rs_cod_dwb_output <> "Impressora" /*l_printer*/  /* and rs_ind_run_mode <> "Batch" /*l_batch*/  */
                then do: 
                    assign v_qtd_line_ant = input frame f_rpt_41_tit_acr_antecip_prev v_qtd_line.
                end /* if */.

                assign ed_1x40:sensitive        = no
                       bt_get_file:visible      = no
                       bt_set_printer:visible   = yes
                       bt_set_printer:sensitive = yes.

                /* define layout default */
                if  dwb_rpt_param.nom_dwb_printer = ""
                or  dwb_rpt_param.cod_dwb_print_layout = ""
                then do:
                    run pi_set_print_layout_default /*pi_set_print_layout_default*/.
                end /* if */.
                else do:
                    assign ed_1x40:screen-value = dwb_rpt_param.nom_dwb_printer
                                                + ":"
                                                + dwb_rpt_param.cod_dwb_print_layout.
                end /* else */.
                find layout_impres no-lock
                     where layout_impres.nom_impressora = dwb_rpt_param.nom_dwb_printer
                       and layout_impres.cod_layout_impres = dwb_rpt_param.cod_dwb_print_layout /*cl_get_layout of layout_impres*/ no-error.
                if  avail layout_impres
                then do:
                    assign v_qtd_line               = layout_impres.num_lin_pag.
                end /* if */.
                display v_qtd_line
                        with frame f_rpt_41_tit_acr_antecip_prev.
            end /* do prn */.
        end /* case block */.

        assign v_cod_dwb_file_temp = replace(dwb_rpt_param.cod_dwb_file, "~\", "~/").
        if  index(v_cod_dwb_file_temp, "~/") <> 0
        then do:
            assign v_cod_dwb_file_temp = substring(v_cod_dwb_file_temp, r-index(v_cod_dwb_file_temp, "~/") + 1).
        end /* if */.
        else do:
            assign v_cod_dwb_file_temp = dwb_rpt_param.cod_dwb_file.
        end /* else */.
    end /* do initout */.

    if  self:screen-value = "Impressora" /*l_printer*/ 
    then do:
        disable v_qtd_line
                with frame f_rpt_41_tit_acr_antecip_prev.
    end /* if */.
    else do:
        enable v_qtd_line
               with frame f_rpt_41_tit_acr_antecip_prev.
    end /* else */.
    assign rs_cod_dwb_output.

END. /* ON VALUE-CHANGED OF rs_cod_dwb_output IN FRAME f_rpt_41_tit_acr_antecip_prev */

ON VALUE-CHANGED OF rs_ind_run_mode IN FRAME f_rpt_41_tit_acr_antecip_prev
DO:

    do  transaction:
        find dwb_rpt_param
            where dwb_rpt_param.cod_dwb_user    = v_cod_usuar_corren
            and   dwb_rpt_param.cod_dwb_program = v_cod_dwb_program
            exclusive-lock no-error.
        assign dwb_rpt_param.ind_dwb_run_mode = input frame f_rpt_41_tit_acr_antecip_prev rs_ind_run_mode.

        if  dwb_rpt_param.ind_dwb_run_mode = "Batch" /*l_batch*/ 
        then do:
            if  rs_cod_dwb_output:disable("Terminal" /*l_terminal*/ ) in frame f_rpt_41_tit_acr_antecip_prev
            then do:
            end /* if */.
        end /* if */.
        else do:
            if  rs_cod_dwb_output:enable("Terminal" /*l_terminal*/ ) in frame f_rpt_41_tit_acr_antecip_prev
            then do:
            end /* if */.
        end /* else */.
        if  rs_ind_run_mode = "Batch" /*l_batch*/ 
        then do:
           assign v_qtd_line = v_qtd_line_ant.
           display v_qtd_line
                   with frame f_rpt_41_tit_acr_antecip_prev.
        end /* if */.
        assign rs_ind_run_mode.
        apply "value-changed" to rs_cod_dwb_output in frame f_rpt_41_tit_acr_antecip_prev.
    end.    

END. /* ON VALUE-CHANGED OF rs_ind_run_mode IN FRAME f_rpt_41_tit_acr_antecip_prev */

ON VALUE-CHANGED OF rs_prev_antec IN FRAME f_rpt_41_tit_acr_antecip_prev
DO:

    assign v_log_lista_cta_ctbl  = no.

    if  input frame f_rpt_41_tit_acr_antecip_prev rs_prev_antec = "Previs‰es" /*l_previsoes*/ 
    then do:
       assign v_log_prev = yes.
       disable v_log_lista_cta_ctbl
               with frame f_rpt_41_tit_acr_antecip_prev.
    end /* if */.
    else do:
       assign v_log_prev = no.
       enable v_log_lista_cta_ctbl
              with frame f_rpt_41_tit_acr_antecip_prev.
    end /* else */.

    display v_log_lista_cta_ctbl
            with frame f_rpt_41_tit_acr_antecip_prev.
    assign v_log_mudan = yes.
END. /* ON VALUE-CHANGED OF rs_prev_antec IN FRAME f_rpt_41_tit_acr_antecip_prev */

ON LEAVE OF v_cod_finalid_econ IN FRAME f_rpt_41_tit_acr_antecip_prev
DO:

    if  v_cod_finalid_econ_apres:screen-value in frame f_rpt_41_tit_acr_antecip_prev = " "
    then do:
        assign v_cod_finalid_econ_apres:screen-value in frame f_rpt_41_tit_acr_antecip_prev = input frame f_rpt_41_tit_acr_antecip_prev v_cod_finalid_econ.
    end /* if */.
END. /* ON LEAVE OF v_cod_finalid_econ IN FRAME f_rpt_41_tit_acr_antecip_prev */

ON VALUE-CHANGED OF v_ind_visualiz_tit_acr_vert IN FRAME f_rpt_41_tit_acr_antecip_prev
DO:

    assign v_ind_visualiz_tit_acr_vert = input frame f_rpt_41_tit_acr_antecip_prev v_ind_visualiz_tit_acr_vert.

    if  v_ind_visualiz_tit_acr_vert = "Por Unidade Neg¢cio" /*l_por_unid_negoc*/ 
    then do:
       assign v_log_tot_por_espec   = no
              v_log_lista_ped       = no
              v_log_lista_abat_pend = no.

       disable v_log_tot_por_espec
               v_log_lista_ped
               v_log_lista_abat_pend
               with frame f_rpt_41_tit_acr_antecip_prev.
    end /* if */.
    else do:
       enable v_log_tot_por_espec
              v_log_sdo_zero
              v_log_lista_ped
              v_log_lista_abat_pend
              with frame f_rpt_41_tit_acr_antecip_prev.
    end /* else */.
    if  v_log_prev = yes
    then do:
       assign v_log_lista_cta_ctbl  = no.
       disable v_log_lista_cta_ctbl
               with frame f_rpt_41_tit_acr_antecip_prev.
    end /* if */.
    else do:
       enable v_log_lista_cta_ctbl
              with frame f_rpt_41_tit_acr_antecip_prev.
    end /* else */.

    display v_log_tot_por_espec
            v_log_sdo_zero
            v_log_lista_ped
            v_log_lista_abat_pend
            v_log_lista_cta_ctbl
            with frame f_rpt_41_tit_acr_antecip_prev.
END. /* ON VALUE-CHANGED OF v_ind_visualiz_tit_acr_vert IN FRAME f_rpt_41_tit_acr_antecip_prev */

ON VALUE-CHANGED OF v_log_lista_abat_pend IN FRAME f_rpt_41_tit_acr_antecip_prev
DO:

    assign v_log_lista_abat_pend = input frame f_rpt_41_tit_acr_antecip_prev v_log_lista_abat_pend.
END. /* ON VALUE-CHANGED OF v_log_lista_abat_pend IN FRAME f_rpt_41_tit_acr_antecip_prev */

ON VALUE-CHANGED OF v_log_lista_cta_ctbl IN FRAME f_rpt_41_tit_acr_antecip_prev
DO:

    assign v_log_lista_cta_ctbl = input frame f_rpt_41_tit_acr_antecip_prev v_log_lista_cta_ctbl.
END. /* ON VALUE-CHANGED OF v_log_lista_cta_ctbl IN FRAME f_rpt_41_tit_acr_antecip_prev */

ON VALUE-CHANGED OF v_log_lista_ped IN FRAME f_rpt_41_tit_acr_antecip_prev
DO:

    assign v_log_lista_ped = input frame f_rpt_41_tit_acr_antecip_prev v_log_lista_ped.
END. /* ON VALUE-CHANGED OF v_log_lista_ped IN FRAME f_rpt_41_tit_acr_antecip_prev */

ON VALUE-CHANGED OF v_log_print_par IN FRAME f_rpt_41_tit_acr_antecip_prev
DO:

    assign v_log_print_par = input frame f_rpt_41_tit_acr_antecip_prev v_log_print_par.
END. /* ON VALUE-CHANGED OF v_log_print_par IN FRAME f_rpt_41_tit_acr_antecip_prev */

ON VALUE-CHANGED OF v_log_sdo_zero IN FRAME f_rpt_41_tit_acr_antecip_prev
DO:

    assign v_log_sdo_zero = input frame f_rpt_41_tit_acr_antecip_prev v_log_sdo_zero.
END. /* ON VALUE-CHANGED OF v_log_sdo_zero IN FRAME f_rpt_41_tit_acr_antecip_prev */

ON VALUE-CHANGED OF v_log_tot_por_espec IN FRAME f_rpt_41_tit_acr_antecip_prev
DO:

    assign v_log_tot_por_espec = input frame f_rpt_41_tit_acr_antecip_prev v_log_tot_por_espec.
END. /* ON VALUE-CHANGED OF v_log_tot_por_espec IN FRAME f_rpt_41_tit_acr_antecip_prev */


/************************ User Interface Trigger End ************************/

/************************** Function Trigger Begin **************************/


ON  CHOOSE OF bt_zoo_194804 IN FRAME f_rpt_41_tit_acr_antecip_prev
OR F5 OF v_cod_finalid_econ IN FRAME f_rpt_41_tit_acr_antecip_prev DO:

    /* fn_generic_zoom_variable */
    if  search("prgint/utb/utb077ka.r") = ? and search("prgint/utb/utb077ka.p") = ? then do:
        if  v_cod_dwb_user begins 'es_' then
            return "Programa execut†vel n∆o foi encontrado:" /*l_programa_nao_encontrado*/  + "prgint/utb/utb077ka.p".
        else do:
            message "Programa execut†vel n∆o foi encontrado:" /*l_programa_nao_encontrado*/  "prgint/utb/utb077ka.p"
                   view-as alert-box error buttons ok.
            return.
        end.
    end.
    else
        run prgint/utb/utb077ka.p /*prg_sea_finalid_econ*/.
    if  v_rec_finalid_econ <> ?
    then do:
        find finalid_econ where recid(finalid_econ) = v_rec_finalid_econ no-lock no-error.
        assign v_cod_finalid_econ:screen-value in frame f_rpt_41_tit_acr_antecip_prev =
               string(finalid_econ.cod_finalid_econ).

        apply "entry" to v_cod_finalid_econ in frame f_rpt_41_tit_acr_antecip_prev.
    end /* if */.

end. /* ON  CHOOSE OF bt_zoo_194804 IN FRAME f_rpt_41_tit_acr_antecip_prev */

ON  CHOOSE OF bt_zoo_194805 IN FRAME f_rpt_41_tit_acr_antecip_prev
OR F5 OF v_cod_finalid_econ_apres IN FRAME f_rpt_41_tit_acr_antecip_prev DO:

    /* fn_generic_zoom_variable */
    if  search("prgint/utb/utb077ka.r") = ? and search("prgint/utb/utb077ka.p") = ? then do:
        if  v_cod_dwb_user begins 'es_' then
            return "Programa execut†vel n∆o foi encontrado:" /*l_programa_nao_encontrado*/  + "prgint/utb/utb077ka.p".
        else do:
            message "Programa execut†vel n∆o foi encontrado:" /*l_programa_nao_encontrado*/  "prgint/utb/utb077ka.p"
                   view-as alert-box error buttons ok.
            return.
        end.
    end.
    else
        run prgint/utb/utb077ka.p /*prg_sea_finalid_econ*/.
    if  v_rec_finalid_econ <> ?
    then do:
        find b_finalid_econ where recid(b_finalid_econ) = v_rec_finalid_econ no-lock no-error.
        assign v_cod_finalid_econ_apres:screen-value in frame f_rpt_41_tit_acr_antecip_prev =
               string(b_finalid_econ.cod_finalid_econ).

        apply "entry" to v_cod_finalid_econ_apres in frame f_rpt_41_tit_acr_antecip_prev.
    end /* if */.

end. /* ON  CHOOSE OF bt_zoo_194805 IN FRAME f_rpt_41_tit_acr_antecip_prev */


/*************************** Function Trigger End ***************************/

/**************************** Frame Trigger Begin ***************************/


ON GO OF FRAME f_rpt_41_tit_acr_antecip_prev
DO:

    assign dwb_rpt_param.cod_dwb_output   = rs_cod_dwb_output:screen-value in frame f_rpt_41_tit_acr_antecip_prev.
    if  dwb_rpt_param.cod_dwb_output = "Arquivo" /*l_file*/ 
    then do:
        run pi_filename_validation (Input dwb_rpt_param.cod_dwb_file) /*pi_filename_validation*/.
        if  return-value = "NOK" /*l_nok*/ 
        then do:
            /* Nome do arquivo incorreto ! */
            run pi_messages (input "show",
                             input 1064,
                             input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")) /*msg_1064*/.
            return no-apply.
        end /* if */.
    end /* if */.
    else do:
        if  dwb_rpt_param.cod_dwb_output = "Impressora" /*l_printer*/ 
        then do:
            if  dwb_rpt_param.nom_dwb_printer = ""
            or   dwb_rpt_param.cod_dwb_print_layout = ""
            then do:
                /* Impressora destino e layout de impress∆o n∆o definidos ! */
                run pi_messages (input "show",
                                 input 2052,
                                 input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")) /*msg_2052*/.
                return no-apply.
            end /* if */.
        end /* if */.
    end /* else */.

    assign input frame f_rpt_41_tit_acr_antecip_prev v_cod_finalid_econ
           input frame f_rpt_41_tit_acr_antecip_prev v_cod_finalid_econ_apres
           input frame f_rpt_41_tit_acr_antecip_prev v_dat_cotac_indic_econ
           input frame f_rpt_41_tit_acr_antecip_prev v_ind_visualiz_tit_acr_vert
           input frame f_rpt_41_tit_acr_antecip_prev v_log_tot_por_espec
           input frame f_rpt_41_tit_acr_antecip_prev v_log_sdo_zero
           input frame f_rpt_41_tit_acr_antecip_prev v_log_lista_ped
           input frame f_rpt_41_tit_acr_antecip_prev v_log_lista_abat_pend
           input frame f_rpt_41_tit_acr_antecip_prev rs_prev_antec
           input frame f_rpt_41_tit_acr_antecip_prev v_log_lista_cta_ctbl.
END. /* ON GO OF FRAME f_rpt_41_tit_acr_antecip_prev */

ON ENDKEY OF FRAME f_rpt_41_tit_acr_antecip_prev
DO:


    /* Begin_Include: i_exec_program_epc */
    &if '{&emsbas_version}' > '1.00' &then
    if  v_nom_prog_upc <> '' then
    do:
        assign v_rec_table_epc = recid(tit_acr).    
        run value(v_nom_prog_upc) (input 'CANCEL',
                                   input 'viewer',
                                   input this-procedure,
                                   input v_wgh_frame_epc,
                                   input v_nom_table_epc,
                                   input v_rec_table_epc).
        if  'no' = 'yes'
        and return-value = 'NOK' then
            undo, retry.
    end.

    if  v_nom_prog_appc <> '' then
    do:
        assign v_rec_table_epc = recid(tit_acr).    
        run value(v_nom_prog_appc) (input 'CANCEL',
                                    input 'viewer',
                                    input this-procedure,
                                    input v_wgh_frame_epc,
                                    input v_nom_table_epc,
                                    input v_rec_table_epc).
        if  'no' = 'yes'
        and return-value = 'NOK' then
            undo, retry.
    end.

    &if '{&emsbas_version}' > '5.00' &then
    if  v_nom_prog_dpc <> '' then
    do:
        assign v_rec_table_epc = recid(tit_acr).    
        run value(v_nom_prog_dpc) (input 'CANCEL',
                                    input 'viewer',
                                    input this-procedure,
                                    input v_wgh_frame_epc,
                                    input v_nom_table_epc,
                                    input v_rec_table_epc).
        if  'no' = 'yes'
        and return-value = 'NOK' then
            undo, retry.
    end.
    &endif
    &endif
    /* End_Include: i_exec_program_epc */

END. /* ON ENDKEY OF FRAME f_rpt_41_tit_acr_antecip_prev */

ON HELP OF FRAME f_rpt_41_tit_acr_antecip_prev ANYWHERE
DO:


    /* Begin_Include: i_context_help */
    run prgtec/men/men900za.py (Input self:handle,
                                Input this-procedure:handle) /*prg_fnc_chamar_help_context*/.
    /* End_Include: i_context_help */

END. /* ON HELP OF FRAME f_rpt_41_tit_acr_antecip_prev */

ON RIGHT-MOUSE-DOWN OF FRAME f_rpt_41_tit_acr_antecip_prev ANYWHERE
DO:

    /************************* Variable Definition Begin ************************/

    def var v_wgh_frame
        as widget-handle
        format ">>>>>>9":U
        no-undo.


    /************************** Variable Definition End *************************/


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

END. /* ON RIGHT-MOUSE-DOWN OF FRAME f_rpt_41_tit_acr_antecip_prev */

ON RIGHT-MOUSE-UP OF FRAME f_rpt_41_tit_acr_antecip_prev ANYWHERE
DO:

    /************************* Variable Definition Begin ************************/

    def var v_wgh_frame
        as widget-handle
        format ">>>>>>9":U
        no-undo.


    /************************** Variable Definition End *************************/


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

END. /* ON RIGHT-MOUSE-UP OF FRAME f_rpt_41_tit_acr_antecip_prev */

ON WINDOW-CLOSE OF FRAME f_rpt_41_tit_acr_antecip_prev
DO:

    apply "end-error" to self.
END. /* ON WINDOW-CLOSE OF FRAME f_rpt_41_tit_acr_antecip_prev */


/***************************** Frame Trigger End ****************************/

/**************************** Menu Trigger Begin ****************************/


ON CHOOSE OF MENU-ITEM mi_conteudo IN MENU m_help
DO:


        apply "choose" to bt_hel2 in frame f_rpt_41_tit_acr_antecip_prev.





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


        assign v_nom_prog     = substring(frame f_rpt_41_tit_acr_antecip_prev:title, 1, max(1, length(frame f_rpt_41_tit_acr_antecip_prev:title) - 10)).
        if  v_nom_prog = ? then
            assign v_nom_prog = "".

        assign v_nom_prog     = v_nom_prog
                              + chr(10)
                              + "rpt_tit_acr_antecip_prev_acr":U.




    assign v_nom_prog_ext = "prgfin/acr/acr339ab.py":U
           v_cod_release  = trim(" 1.00.00.012":U).
/*    run prgtec/btb/btb901zb.p (Input v_nom_prog,
                               Input v_nom_prog_ext,
                               Input v_cod_release) /*prg_fnc_about*/. */
{include/sobre5.i}
END. /* ON CHOOSE OF MENU-ITEM mi_sobre IN MENU m_help */


/***************************** Menu Trigger End *****************************/


/****************************** Main Code Begin *****************************/


/* Begin_Include: i_version_extract */
{include/i-ctrlrp5.i rpt_tit_acr_antecip_prev_acr}


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
    run pi_version_extract ('rpt_tit_acr_antecip_prev_acr':U, 'prgfin/acr/acr339ab.py':U, '1.00.00.012':U, 'pro':U).
end /* if */.



/* End_Include: i_version_extract */

run pi_return_user (output v_cod_dwb_user) /*pi_return_user*/.

if  search("prgtec/btb/btb906za.r") = ? and search("prgtec/btb/btb906za.py") = ? then do:
    if  v_cod_dwb_user begins 'es_' then
        return "Programa execut†vel n∆o foi encontrado:" /*l_programa_nao_encontrado*/  + "prgtec/btb/btb906za.py".
    else do:
        message "Programa execut†vel n∆o foi encontrado:" /*l_programa_nao_encontrado*/  "prgtec/btb/btb906za.py"
               view-as alert-box error buttons ok.
        stop.
    end.
end.
else
    run prgtec/btb/btb906za.py /*prg_fnc_verify_controls*/.
if (v_cod_dwb_user = "") then
   assign v_cod_dwb_user = v_cod_usuar_corren.


/* Begin_Include: i_verify_security */
if  search("prgtec/men/men901za.r") = ? and search("prgtec/men/men901za.py") = ? then do:
    if  v_cod_dwb_user begins 'es_' then
        return "Programa execut†vel n∆o foi encontrado:" /*l_programa_nao_encontrado*/  + "prgtec/men/men901za.py".
    else do:
        message "Programa execut†vel n∆o foi encontrado:" /*l_programa_nao_encontrado*/  "prgtec/men/men901za.py"
               view-as alert-box error buttons ok.
        return.
    end.
end.
else
    run prgtec/men/men901za.py (Input 'rpt_tit_acr_antecip_prev_acr') /*prg_fnc_verify_security*/.
if  return-value = "2014"
then do:
    /* Programa a ser executado n∆o Ç um programa v†lido Datasul ! */
    run pi_messages (input "show",
                     input 2014,
                     input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9",
                                       'rpt_tit_acr_antecip_prev_acr')) /*msg_2014*/.
    return.
end /* if */.
if  return-value = "2012"
then do:
    /* Usu†rio sem permiss∆o para acessar o programa. */
    run pi_messages (input "show",
                     input 2012,
                     input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9",
                                       'rpt_tit_acr_antecip_prev_acr')) /*msg_2012*/.
    return.
end /* if */.
/* End_Include: i_verify_security */



/* Begin_Include: i_log_exec_prog_dtsul_ini */
assign v_rec_log = ?.

if can-find(prog_dtsul
       where prog_dtsul.cod_prog_dtsul = 'rpt_tit_acr_antecip_prev_acr' 
         and prog_dtsul.log_gera_log_exec = yes) then do transaction:
    create log_exec_prog_dtsul.
    assign log_exec_prog_dtsul.cod_prog_dtsul           = 'rpt_tit_acr_antecip_prev_acr'
           log_exec_prog_dtsul.cod_usuario              = v_cod_usuar_corren
           log_exec_prog_dtsul.dat_inic_exec_prog_dtsul = today
           log_exec_prog_dtsul.hra_inic_exec_prog_dtsul = replace(string(time,"hh:mm:ss" /*l_hh:mm:ss*/ ),":":U,"":U).
    assign v_rec_log = recid(log_exec_prog_dtsul).
    release log_exec_prog_dtsul no-error.
end.


/* End_Include: i_log_exec_prog_dtsul_ini */

/* tech38629 - Alteraá∆o efetuada via filtro */
&if '{&emsbas_version}':U >= '5.05':U &then
run pi_permissoes in v_prog_filtro_pdf (input 'rpt_tit_acr_antecip_prev_acr':U).
&endif
/* tech38629 - Fim da alteraá∆o */




/* Begin_Include: i_verify_program_epc */
&if '{&emsbas_version}' > '1.00' &then
assign v_rec_table_epc = ?
       v_wgh_frame_epc = ?.

find prog_dtsul
    where prog_dtsul.cod_prog_dtsul = "rpt_tit_acr_antecip_prev_acr":U
    no-lock no-error.
if  avail prog_dtsul then do:
    if  prog_dtsul.nom_prog_upc <> ''
    and prog_dtsul.nom_prog_upc <> ? then
        assign v_nom_prog_upc = prog_dtsul.nom_prog_upc.
    if  prog_dtsul.nom_prog_appc <> ''
    and prog_dtsul.nom_prog_appc <> ? then
        assign v_nom_prog_appc = prog_dtsul.nom_prog_appc.
&if '{&emsbas_version}' > '5.00' &then
    if  prog_dtsul.nom_prog_dpc <> ''
    and prog_dtsul.nom_prog_dpc <> ? then
        assign v_nom_prog_dpc = prog_dtsul.nom_prog_dpc.
&endif
end.


assign v_wgh_frame_epc = frame f_rpt_41_tit_acr_antecip_prev:handle.



assign v_nom_table_epc = 'tit_acr':U
       v_rec_table_epc = recid(tit_acr).

&endif

/* End_Include: i_verify_program_epc */


/* redefiniá‰es do frame */

/* Begin_Include: i_std_dialog_box */
/* tratamento do titulo e vers∆o */
assign frame f_rpt_41_tit_acr_antecip_prev:title = frame f_rpt_41_tit_acr_antecip_prev:title
                            + chr(32)
                            + chr(40)
                            + trim(" 1.00.00.012":U)
                            + chr(41).
/* menu pop-up de ajuda e sobre */
assign menu m_help:popup-only = yes
       bt_hel2:popup-menu in frame f_rpt_41_tit_acr_antecip_prev = menu m_help:handle.


/* End_Include: i_std_dialog_box */
{include/title5.i f_rpt_41_tit_acr_antecip_prev FRAME}


/* inicializa vari†veis */
find empresa no-lock
     where empresa.cod_empresa = v_cod_empres_usuar /*cl_empres_usuar of empresa*/ no-error.
find dwb_rpt_param
     where dwb_rpt_param.cod_dwb_program = "rel_antecip_prev_acr":U
       and dwb_rpt_param.cod_dwb_user    = v_cod_dwb_user
       no-lock no-error.
if  avail dwb_rpt_param then do:
&if '{&emsbas_version}' > '1.00' &then
&if '{&emsbas_version}' >= '5.03' &then
    assign v_nom_dwb_print_file = dwb_rpt_param.nom_dwb_print_file.
&else
    assign v_nom_dwb_print_file = dwb_rpt_param.cod_livre_1.
&endif
&endif
    if  dwb_rpt_param.qtd_dwb_line <> 0 then
        assign v_qtd_line = dwb_rpt_param.qtd_dwb_line.
    else
        assign v_qtd_line = v_rpt_s_1_lines.
end.
assign v_cod_dwb_proced   = "rel_antecip_prev_acr":U
       v_cod_dwb_program  = "rel_antecip_prev_acr":U
       v_cod_release      = trim(" 1.00.00.012":U)
       v_ind_dwb_run_mode = "On-Line" /*l_online*/ 
       v_qtd_column       = v_rpt_s_1_columns
       v_qtd_bottom       = v_rpt_s_1_bottom.
if (avail empresa) then
    assign v_nom_enterprise   = empresa.nom_razao_social.
else
    assign v_nom_enterprise   = 'DATASUL'.


/* Begin_Include: ix_p00_rpt_tit_acr_antecip_prev_acr */

/* End_Include: ix_p00_rpt_tit_acr_antecip_prev_acr */


if  v_cod_dwb_user begins 'es_'
then do:
    find dwb_rpt_param no-lock
         where dwb_rpt_param.cod_dwb_program = v_cod_dwb_program
           and dwb_rpt_param.cod_dwb_user = v_cod_dwb_user /*cl_dwb_rpt_param of dwb_rpt_param*/ no-error.
    if (not avail dwb_rpt_param) then
        return "ParÉmetros para o relat¢rio n∆o encontrado." /*1993*/ + " (" + "1993" + ")" + chr(10) + "N∆o foi poss°vel encontrar os parÉmetros necess†rios para a impress∆o do relat¢rio para o programa e usu†rio corrente." /*1993*/.
    if index( dwb_rpt_param.cod_dwb_file ,'~\') <> 0 then
        assign file-info:file-name = replace(dwb_rpt_param.cod_dwb_file, '~\', '~/').
    else
        assign file-info:file-name = dwb_rpt_param.cod_dwb_file.

    assign file-info:file-name = substring(file-info:file-name, 1,
                                           r-index(file-info:file-name, '~/') - 1).
    if  dwb_rpt_param.cod_dwb_output = "Arquivo" /*l_file*/ 
    then do:
       if file-info:file-type = ? then
          return "Diret¢rio Inexistente:" /*l_directory*/  + dwb_rpt_param.cod_dwb_file.
    end /* if */.

    find ped_exec no-lock
         where ped_exec.num_ped_exec = v_num_ped_exec_corren /*cl_le_ped_exec_global of ped_exec*/ no-error.
    if (ped_exec.cod_release_prog_dtsul <> trim(" 1.00.00.012":U)) then
        return "Vers‰es do programa diferente." /*1994*/ + " (" + "1994" + ")" + chr(10)
                                     + substitute("A vers∆o do programa (&3) que gerou o pedido de execuá∆o batch (&1) Ç diferente da vers∆o do programa que deveria executar o pedido batch (&2)." /*1994*/,ped_exec.cod_release_prog_dtsul,
                                                  trim(" 1.00.00.012":U),
                                                  "prgfin/acr/acr339ab.py":U).
    assign v_nom_prog_ext     = caps("acr339ab":U)
           v_dat_execution    = today
           v_hra_execution    = replace(string(time, "hh:mm:ss" /*l_hh:mm:ss*/ ), ":", "")
           v_cod_dwb_file     = dwb_rpt_param.cod_dwb_file
           v_nom_report_title = fill(" ", 40 - length(v_rpt_s_1_name)) + v_rpt_s_1_name
           v_ind_dwb_run_mode = "Batch" /*l_batch*/ .


    /* Begin_Include: ix_p02_rpt_tit_acr_antecip_prev_acr */
    assign v_ind_visualiz_tit_acr_vert = entry(1,dwb_rpt_param.cod_dwb_parameters, chr(10))
           rs_prev_antec               = entry(2,dwb_rpt_param.cod_dwb_parameters, chr(10))
           v_cod_finalid_econ          = entry(3,dwb_rpt_param.cod_dwb_parameters, chr(10))
           v_cod_finalid_econ_apres    = entry(4,dwb_rpt_param.cod_dwb_parameters, chr(10))
           v_dat_cotac_indic_econ      = date(entry(5,dwb_rpt_param.cod_dwb_parameters, chr(10)))
           v_log_tot_por_espec         = (entry(6,dwb_rpt_param.cod_dwb_parameters, chr(10)) = "yes" /*l_yes*/ )
           v_log_sdo_zero              = (entry(7,dwb_rpt_param.cod_dwb_parameters, chr(10)) = "yes" /*l_yes*/ )
           v_log_lista_ped             = (entry(8,dwb_rpt_param.cod_dwb_parameters, chr(10)) = "yes" /*l_yes*/ )
           v_log_lista_abat_pend       = (entry(9,dwb_rpt_param.cod_dwb_parameters, chr(10)) = "yes" /*l_yes*/ )
           v_log_lista_cta_ctbl        = (entry(10,dwb_rpt_param.cod_dwb_parameters, chr(10)) = "yes" /*l_yes*/ ).

    assign v_ind_classif               = entry(11,dwb_rpt_param.cod_dwb_parameters, chr(10)).

    assign /* Projeto 99 - Retirada a faixa de estabelecimento */
           v_cod_unid_negoc_ini        = entry(14,dwb_rpt_param.cod_dwb_parameters, chr(10))
           v_cod_unid_negoc_fim        = entry(15,dwb_rpt_param.cod_dwb_parameters, chr(10))
           v_cod_portador_ini          = entry(16,dwb_rpt_param.cod_dwb_parameters, chr(10))
           v_cod_portador_fim          = entry(17,dwb_rpt_param.cod_dwb_parameters, chr(10))
           v_cod_espec_docto_ini       = entry(18,dwb_rpt_param.cod_dwb_parameters, chr(10))
           v_cod_espec_docto_fim       = entry(19,dwb_rpt_param.cod_dwb_parameters, chr(10))
           v_cdn_cliente_ini           = integer(entry(20,dwb_rpt_param.cod_dwb_parameters, chr(10)))
           v_cdn_cliente_fim           = integer(entry(21,dwb_rpt_param.cod_dwb_parameters, chr(10)))
           v_cod_indic_econ_ini        = entry(22,dwb_rpt_param.cod_dwb_parameters, chr(10))
           v_cod_indic_econ_fim        = entry(23,dwb_rpt_param.cod_dwb_parameters, chr(10))
           v_dat_emis_docto_ini        = date(entry(24,dwb_rpt_param.cod_dwb_parameters, chr(10)))
           v_dat_emis_docto_fim        = date(entry(25,dwb_rpt_param.cod_dwb_parameters, chr(10)))
           v_dat_vencto_tit_acr_ini    = date(entry(26,dwb_rpt_param.cod_dwb_parameters, chr(10)))
           v_dat_vencto_tit_acr_fim    = date(entry(27,dwb_rpt_param.cod_dwb_parameters, chr(10))).

    assign v_log_prev                  = (entry(28,dwb_rpt_param.cod_dwb_parameters, chr(10)) = "yes" /*l_yes*/ )
           v_val_cotac_indic_econ      = dec(entry(29,dwb_rpt_param.cod_dwb_parameters, chr(10))).

    if  num-entries( dwb_rpt_param.cod_dwb_parameters , chr(10) ) >= 30
    then do:
        assign v_des_estab_select = entry(30, dwb_rpt_param.cod_dwb_parameters, chr(10)).
        run pi_vld_estab_select (Input "ACR" /*l_acr*/ ).
    end /* if */.
    else do:
        run pi_vld_permissao_usuar_estab_empres (Input "ACR" /*l_acr*/ ).
    end /* else */.
    /* End_Include: ix_p02_rpt_tit_acr_antecip_prev_acr */


    /* configura e define destino de impress∆o */
    if (dwb_rpt_param.cod_dwb_output = "Impressora" /*l_printer*/ ) then
        assign v_qtd_line_ant = v_qtd_line.


/* Alteracao via filtro - Impressao grandes volumes - inicio */
&IF "{&product_version}" >= "11.5.7" &THEN
    IF CAN-FIND(FIRST PARAM_extens_ems
                WHERE PARAM_extens_ems.cod_entid_param_ems = "impressao":U
                  AND PARAM_extens_ems.cod_chave_param_ems = "impress_escala":U
                  AND PARAM_extens_ems.cod_param_ems       = "impress_escala":U
                  AND PARAM_extens_ems.log_param_ems       = YES) THEN DO:

       ASSIGN v_nom_dwb_print_file = dwb_rpt_param.cod_dwb_file
              v_nom_dwb_print_file = REPLACE(v_nom_dwb_print_file,"~\","~/")
              v_nom_dwb_print_file = SUBSTRING(v_nom_dwb_print_file, R-INDEX(v_nom_dwb_print_file,"/") + 1).

       ASSIGN c-cod_dwb_user = ENTRY(2,v_cod_dwb_user,"_")
              i-num_ped_exec = INTEGER(ENTRY(3,v_cod_dwb_user,"_")) NO-ERROR.

       IF v_nom_dwb_print_file <> "" THEN DO:
          IF SUBSTRING(v_nom_dwb_print_file, LENGTH(v_nom_dwb_print_file) - 3, 1) = "." THEN
             ASSIGN v_nom_dwb_print_file = SUBSTRING(v_nom_dwb_print_file,1,INDEX(v_nom_dwb_print_file,"."))
                + STRING(TODAY,"99999999")
                + STRING(TIME,"99999")
                + STRING(i-num_ped_exec)
                + SUBSTRING(v_nom_dwb_print_file, LENGTH(v_nom_dwb_print_file) - 3).
          ELSE
             ASSIGN v_nom_dwb_print_file = SUBSTRING(v_nom_dwb_print_file, 1, R-INDEX(v_nom_dwb_print_file,"."))
                   + STRING(TODAY,"99999999")
                   + STRING(TIME,"99999")
                   + STRING(i-num_ped_exec).

          FIND FIRST ped_exec NO-LOCK
             WHERE ped_exec.num_ped_exec = i-num_ped_exec NO-ERROR.
          IF AVAIL ped_exec THEN DO:
             FIND FIRST servid_exec NO-LOCK
                WHERE servid_exec.cod_servid_exec = ped_exec.cod_servid_exec NO-ERROR.
             IF AVAIL servid_exec THEN
                ASSIGN c-servid_exec_nom_dir_spool = servid_exec.nom_dir_spool.
          END.

          FIND FIRST usuar_mestre NO-LOCK
             WHERE usuar_mestre.cod_usuario = c-cod_dwb_user NO-ERROR.
          IF AVAIL usuar_mestre THEN
             ASSIGN c-usuar_mestre_nom_subdir_spool = usuar_mestre.nom_subdir_spool.

          IF CAN-FIND(FIRST param_extens_ems
               WHERE param_extens_ems.cod_entid_param_ems = "impressao":U
                 AND param_extens_ems.cod_chave_param_ems = "impress_escala":U
                 AND param_extens_ems.cod_param_ems       = "impress_escala":U
                 AND param_extens_ems.log_param_ems       = YES) AND
             CAN-FIND(FIRST impressora
                      WHERE impressora.nom_impressora = dwb_rpt_param.nom_dwb_printer
                        AND impressora.log_impres_escal = YES) THEN
             ASSIGN v_nom_dwb_print_file = c-servid_exec_nom_dir_spool + "/" + v_nom_dwb_print_file.
          ELSE
             ASSIGN v_nom_dwb_print_file = c-servid_exec_nom_dir_spool + "/" + c-usuar_mestre_nom_subdir_spool + "/" + v_nom_dwb_print_file.

       END.

       ASSIGN v_nom_dwb_print_file = REPLACE(v_nom_dwb_print_file,"~\","~/").

       DO TRANSACTION:
          FIND b-dwb_rpt_param EXCLUSIVE-LOCK
             WHERE ROWID(b-dwb_rpt_param) = ROWID(dwb_rpt_param) NO-ERROR.
          IF AVAIL b-dwb_rpt_param THEN
             ASSIGN b-dwb_rpt_param.cod_dwb_file = v_nom_dwb_print_file
                    b-dwb_rpt_param.nom_dwb_print_file = v_nom_dwb_print_file.
          RELEASE b-dwb_rpt_param.
       END.
    END.

&ENDIF
/* Alteracao via filtro - Impressao grandes volumes - fim    */

    run pi_output_reports /*pi_output_reports*/.

    if  dwb_rpt_param.log_dwb_print_parameters = yes
    then do:
        if (page-number (s_1) > 0) then
            page stream s_1.

        /* ix_p29_rpt_tit_acr_antecip_prev_acr */

        hide stream s_1 frame f_rpt_s_1_header_period.
        view stream s_1 frame f_rpt_s_1_header_unique.
        hide stream s_1 frame f_rpt_s_1_footer_last_page.
        hide stream s_1 frame f_rpt_s_1_footer_normal.
        view stream s_1 frame f_rpt_s_1_footer_param_page.
        if (line-counter(s_1) + 3) > v_rpt_s_1_bottom then
            page stream s_1.
        put stream s_1 unformatted 
            skip (1)
            "Usu†rio: " at 1
            v_cod_usuar_corren at 10 format "x(12)" skip (1).


        /* Begin_Include: ix_p30_rpt_tit_acr_antecip_prev_acr */
        if (line-counter(s_1) + 23) > v_rpt_s_1_bottom then
            page stream s_1.
        put stream s_1 unformatted 
            skip (1)
            "---------------------------------------------" at 33
            "Visualizaá∆o" at 79
            "---------------------------------------------" at 93
            skip (1)
            "  Visualiza: " at 74
            v_ind_visualiz_tit_acr_vert at 87 format "X(20)" skip.
        put stream s_1 unformatted 
            v_ind_classif at 87 format "X(35)"
            skip (1)
            "---------------------------------------------" at 33
            "Apresentaá∆o  " at 79
            "---------------------------------------------" at 93
            skip (1)
            "    Finalidade Econìmica: " at 61
            v_cod_finalid_econ at 87 format "x(10)" skip
            "Finalid Apresentaá∆o: " at 65
            v_cod_finalid_econ_apres at 87 format "x(10)" skip.
        put stream s_1 unformatted 
            "Data Cotaá∆o: " at 73
            v_dat_cotac_indic_econ at 87 format "99/99/9999"
            skip (1)
            "---------------------------------------------" at 33
            "Tipo EspÇcie  " at 79
            "---------------------------------------------" at 93
            skip (1)
            v_ind_tip_espec_docto at 78 format "X(17)"
            skip (1)
            "---------------------------------------------" at 37.
        put stream s_1 unformatted 
            "Opá‰es" at 83
            "---------------------------------------------" at 90
            skip (1)
            "Totaliza por EspÇcie:    " at 72
            v_log_tot_por_espec at 100 format "Sim/N∆o" skip
            "Lista AN/PREV Totalmente Abatidas:       " at 59
            v_log_sdo_zero at 100 format "Sim/N∆o" skip
            "Lista Pedidos:   " at 79
            v_log_lista_ped at 100 format "Sim/N∆o" skip
            "Lista Abatimentos Pendentes:      " at 65.
        put stream s_1 unformatted 
            v_log_lista_abat_pend at 100 format "Sim/N∆o" skip
            "Lista Conta Cont†bil:    " at 72
            v_log_lista_cta_ctbl at 100 format "Sim/N∆o" skip.
        /* End_Include: ix_p30_rpt_tit_acr_antecip_prev_acr */


    end /* if */.


/* Alteracao via filtro - Controle de impressao - inicio */
&IF "{&product_version}" >= "11.5.7" &THEN
    ASSIGN v_page_number = PAGE-NUMBER(s_1) NO-ERROR.
&ENDIF
/* Alteracao via filtro - Controle de impressao - fim    */

    output stream s_1 close.

/* tech38629 - Alteraá∆o efetuada via filtro */
&if '{&emsbas_version}':U >= '5.05':U &then
run pi_call_convert_object in v_prog_filtro_pdf (input yes,
                                                 input dwb_rpt_param.cod_dwb_output,
                                                 input dwb_rpt_param.nom_dwb_print_file,
                                                 input v_cod_dwb_file,
                                                 input v_nom_report_title).
&endif
/* tech38629 - Fim da alteraá∆o */


&if '{&emsbas_version}':U >= '5.05':U &then
    if ((dwb_rpt_param.cod_dwb_output = 'Impressora':U or dwb_rpt_param.cod_dwb_output = 'Impresora':U or dwb_rpt_param.cod_dwb_output = 'printer':U) and getCodTipoRelat() = 'PDF':U) then do:
        if dwb_rpt_param.nom_dwb_print_file = '' then
            run pi_print_pdf_file in v_prog_filtro_pdf (input yes).
    end.
&endif

/* Alteracao via filtro - Controle de impressao - inicio */
&IF "{&product_version}" >= "11.5.7" &THEN
   IF CAN-FIND(FIRST param_extens_ems
               WHERE PARAM_extens_ems.cod_entid_param_ems = "histor_impres":U
                 AND param_extens_ems.cod_chave_param_ems = "histor_impres":U
                 AND param_extens_ems.cod_param_ems       = "log_histor_impres":U
                 AND param_extens_ems.log_param_ems       = YES) AND
      CAN-FIND(FIRST usuar_mestre
               WHERE usuar_mestre.cod_usuario = c-cod_dwb_user
                 AND usuar_mestre.log_solic_impres = YES) AND
     (dwb_rpt_param.cod_dwb_output = "Impressora":U OR
      dwb_rpt_param.cod_dwb_output = "Impresora":U OR
      dwb_rpt_param.cod_dwb_output = "printer":U) THEN DO:
      ASSIGN v_cod_usuar_abert = TRIM(dwb_rpt_param.cod_livre_1).
   END.

   RUN prgtec/btb/btb001.p (INPUT c-cod_dwb_user,
                            INPUT v_cod_usuar_abert,
                            INPUT v_page_number,
                            INPUT v_dat_execution,
                            INPUT dwb_rpt_param.cod_dwb_program,
                            INPUT v_nom_report_title,
                            INPUT dwb_rpt_param.nom_dwb_printer,
                            INPUT dwb_rpt_param.cod_dwb_file).
&ENDIF
/* Alteracao via filtro - Controle de impressao - fim    */

    return "OK" /*l_ok*/ .

end /* if */.

pause 0 before-hide.
view frame f_rpt_41_tit_acr_antecip_prev.

/* Begin_Include: i_exec_program_epc */
&if '{&emsbas_version}' > '1.00' &then
if  v_nom_prog_upc <> '' then
do:
    assign v_rec_table_epc = recid(tit_acr).    
    run value(v_nom_prog_upc) (input 'INITIALIZE',
                               input 'viewer',
                               input this-procedure,
                               input v_wgh_frame_epc,
                               input v_nom_table_epc,
                               input v_rec_table_epc).
    if  'no' = 'yes'
    and return-value = 'NOK' then
        undo, retry.
end.

if  v_nom_prog_appc <> '' then
do:
    assign v_rec_table_epc = recid(tit_acr).    
    run value(v_nom_prog_appc) (input 'INITIALIZE',
                                input 'viewer',
                                input this-procedure,
                                input v_wgh_frame_epc,
                                input v_nom_table_epc,
                                input v_rec_table_epc).
    if  'no' = 'yes'
    and return-value = 'NOK' then
        undo, retry.
end.

&if '{&emsbas_version}' > '5.00' &then
if  v_nom_prog_dpc <> '' then
do:
    assign v_rec_table_epc = recid(tit_acr).    
    run value(v_nom_prog_dpc) (input 'INITIALIZE',
                                input 'viewer',
                                input this-procedure,
                                input v_wgh_frame_epc,
                                input v_nom_table_epc,
                                input v_rec_table_epc).
    if  'no' = 'yes'
    and return-value = 'NOK' then
        undo, retry.
end.
&endif
&endif
/* End_Include: i_exec_program_epc */


super_block:
repeat
    on stop undo super_block, retry super_block:

    if (retry) then
       output stream s_1 close.

    param_block:
    do transaction:

        find dwb_rpt_param exclusive-lock
             where dwb_rpt_param.cod_dwb_program = v_cod_dwb_program
               and dwb_rpt_param.cod_dwb_user = v_cod_dwb_user /*cl_dwb_rpt_param of dwb_rpt_param*/ no-error.
        if  not available dwb_rpt_param
        then do:
            create dwb_rpt_param.
            assign dwb_rpt_param.cod_dwb_program         = v_cod_dwb_program
                   dwb_rpt_param.cod_dwb_user            = v_cod_dwb_user
                   dwb_rpt_param.cod_dwb_parameters      = v_cod_dwb_parameters
                   dwb_rpt_param.cod_dwb_output          = "Terminal" /*l_terminal*/ 
                   dwb_rpt_param.ind_dwb_run_mode        = "On-Line" /*l_online*/ 
                   dwb_rpt_param.cod_dwb_file            = ""
                   dwb_rpt_param.nom_dwb_printer         = ""
                   dwb_rpt_param.cod_dwb_print_layout    = ""
                   v_cod_dwb_file_temp                   = "".
        end /* if */.
        assign v_qtd_line = (if dwb_rpt_param.qtd_dwb_line <> 0 then dwb_rpt_param.qtd_dwb_line else v_rpt_s_1_lines).
    end /* do param_block */.

    init:
    do with frame f_rpt_41_tit_acr_antecip_prev:
        assign rs_cod_dwb_output:screen-value   = dwb_rpt_param.cod_dwb_output
               rs_ind_run_mode:screen-value     = dwb_rpt_param.ind_dwb_run_mode.

        if  dwb_rpt_param.cod_dwb_output = "Arquivo" /*l_file*/ 
        then do:
            assign v_cod_dwb_file_temp = replace(dwb_rpt_param.cod_dwb_file, "~\", "~/").
            if (index(v_cod_dwb_file_temp, "~/") <> 0) then
                assign v_cod_dwb_file_temp = substring(v_cod_dwb_file_temp, r-index(v_cod_dwb_file_temp, "~/") + 1).
            else
                assign v_cod_dwb_file_temp = dwb_rpt_param.cod_dwb_file.
            assign ed_1x40:screen-value = v_cod_dwb_file_temp.
        end /* if */.

        if  dwb_rpt_param.cod_dwb_output = "Impressora" /*l_printer*/ 
        then do:
            if (not can-find(imprsor_usuar
                            where imprsor_usuar.nom_impressora = dwb_rpt_param.nom_dwb_printer
                              and imprsor_usuar.cod_usuario = dwb_rpt_param.cod_dwb_user
&if "{&emsbas_version}" >= "5.01" &then
                            use-index imprsrsr_id
&endif
                             /*cl_get_printer of imprsor_usuar*/)
            or   not can-find(layout_impres
                             where layout_impres.nom_impressora = dwb_rpt_param.nom_dwb_printer
                               and layout_impres.cod_layout_impres = dwb_rpt_param.cod_dwb_print_layout /*cl_get_layout of layout_impres*/)) then
                run pi_set_print_layout_default /*pi_set_print_layout_default*/.
            assign ed_1x40:screen-value = dwb_rpt_param.nom_dwb_printer
                                        + ":"
                                        + dwb_rpt_param.cod_dwb_print_layout.
        end /* if */.
        assign v_log_print_par = dwb_rpt_param.log_dwb_print_parameters.
        display v_log_print_par
                with frame f_rpt_41_tit_acr_antecip_prev.
    end /* do init */.

    display v_qtd_column
            v_qtd_line
            with frame f_rpt_41_tit_acr_antecip_prev.


    /* Begin_Include: i_exec_program_epc */
    &if '{&emsbas_version}' > '1.00' &then
    if  v_nom_prog_upc <> '' then
    do:
        assign v_rec_table_epc = recid(tit_acr).    
        run value(v_nom_prog_upc) (input 'DISPLAY',
                                   input 'viewer',
                                   input this-procedure,
                                   input v_wgh_frame_epc,
                                   input v_nom_table_epc,
                                   input v_rec_table_epc).
        if  'no' = 'yes'
        and return-value = 'NOK' then
            undo, retry.
    end.

    if  v_nom_prog_appc <> '' then
    do:
        assign v_rec_table_epc = recid(tit_acr).    
        run value(v_nom_prog_appc) (input 'DISPLAY',
                                    input 'viewer',
                                    input this-procedure,
                                    input v_wgh_frame_epc,
                                    input v_nom_table_epc,
                                    input v_rec_table_epc).
        if  'no' = 'yes'
        and return-value = 'NOK' then
            undo, retry.
    end.

    &if '{&emsbas_version}' > '5.00' &then
    if  v_nom_prog_dpc <> '' then
    do:
        assign v_rec_table_epc = recid(tit_acr).    
        run value(v_nom_prog_dpc) (input 'DISPLAY',
                                    input 'viewer',
                                    input this-procedure,
                                    input v_wgh_frame_epc,
                                    input v_nom_table_epc,
                                    input v_rec_table_epc).
        if  'no' = 'yes'
        and return-value = 'NOK' then
            undo, retry.
    end.
    &endif
    &endif
    /* End_Include: i_exec_program_epc */


    enable rs_cod_dwb_output
           v_log_print_par
           bt_hel2
           bt_ran2
           bt_classificacao
           bt_close
           bt_print
           bt_can
           v_ind_visualiz_tit_acr_vert
           rs_prev_antec
           v_cod_finalid_econ
           v_cod_finalid_econ_apres
           v_dat_cotac_indic_econ
           v_log_tot_por_espec
           v_log_sdo_zero
           v_log_lista_ped
           v_log_lista_abat_pend
           bt_get_file
           bt_set_printer
           with frame f_rpt_41_tit_acr_antecip_prev.


    /* Begin_Include: i_exec_program_epc */
    &if '{&emsbas_version}' > '1.00' &then
    if  v_nom_prog_upc <> '' then
    do:
        assign v_rec_table_epc = recid(tit_acr).    
        run value(v_nom_prog_upc) (input 'ENABLE',
                                   input 'viewer',
                                   input this-procedure,
                                   input v_wgh_frame_epc,
                                   input v_nom_table_epc,
                                   input v_rec_table_epc).
        if  'no' = 'yes'
        and return-value = 'NOK' then
            undo, retry.
    end.

    if  v_nom_prog_appc <> '' then
    do:
        assign v_rec_table_epc = recid(tit_acr).    
        run value(v_nom_prog_appc) (input 'ENABLE',
                                    input 'viewer',
                                    input this-procedure,
                                    input v_wgh_frame_epc,
                                    input v_nom_table_epc,
                                    input v_rec_table_epc).
        if  'no' = 'yes'
        and return-value = 'NOK' then
            undo, retry.
    end.

    &if '{&emsbas_version}' > '5.00' &then
    if  v_nom_prog_dpc <> '' then
    do:
        assign v_rec_table_epc = recid(tit_acr).    
        run value(v_nom_prog_dpc) (input 'ENABLE',
                                    input 'viewer',
                                    input this-procedure,
                                    input v_wgh_frame_epc,
                                    input v_nom_table_epc,
                                    input v_rec_table_epc).
        if  'no' = 'yes'
        and return-value = 'NOK' then
            undo, retry.
    end.
    &endif
    &endif
    /* End_Include: i_exec_program_epc */


/* tech38629 - Alteraá∆o efetuada via filtro */
&if '{&emsbas_version}':U >= '5.05':U &then
    run pi_posiciona_dwb_rpt_param in v_prog_filtro_pdf (input rowid(dwb_rpt_param)).
    run pi_load_params in v_prog_filtro_pdf.
&endif
/* tech38629 - Fim da alteraá∆o */



    apply "value-changed" to rs_cod_dwb_output in frame f_rpt_41_tit_acr_antecip_prev.


    if  yes = yes
    then do:
       enable rs_ind_run_mode
              with frame f_rpt_41_tit_acr_antecip_prev.
       apply "value-changed" to rs_ind_run_mode in frame f_rpt_41_tit_acr_antecip_prev.
    end /* if */.



    /* Begin_Include: ix_p10_rpt_tit_acr_antecip_prev_acr */
    if  dwb_rpt_param.cod_dwb_parameters <> "" and
        num-entries(dwb_rpt_param.cod_dwb_parameters,chr(10)) >= 29
    then do:
       assign v_ind_visualiz_tit_acr_vert = entry(1,dwb_rpt_param.cod_dwb_parameters, chr(10))
              rs_prev_antec               = entry(2,dwb_rpt_param.cod_dwb_parameters, chr(10))
              v_cod_finalid_econ          = entry(3,dwb_rpt_param.cod_dwb_parameters, chr(10))
              v_cod_finalid_econ_apres    = entry(4,dwb_rpt_param.cod_dwb_parameters, chr(10))
              v_dat_cotac_indic_econ      = date(entry(5,dwb_rpt_param.cod_dwb_parameters, chr(10)))
              v_log_tot_por_espec         = (entry(6,dwb_rpt_param.cod_dwb_parameters, chr(10)) = "yes" /*l_yes*/ )
              v_log_sdo_zero              = (entry(7,dwb_rpt_param.cod_dwb_parameters, chr(10)) = "yes" /*l_yes*/ )
              v_log_lista_ped             = (entry(8,dwb_rpt_param.cod_dwb_parameters, chr(10)) = "yes" /*l_yes*/ )
              v_log_lista_abat_pend       = (entry(9,dwb_rpt_param.cod_dwb_parameters, chr(10)) = "yes" /*l_yes*/ )
              v_log_lista_cta_ctbl        = (entry(10,dwb_rpt_param.cod_dwb_parameters, chr(10)) = "yes" /*l_yes*/ ).

       assign v_ind_classif               = entry(11,dwb_rpt_param.cod_dwb_parameters, chr(10)).

       assign /* Projeto 99 - Seguranáa por Estabelecimento */
              v_cod_unid_negoc_ini        = entry(14,dwb_rpt_param.cod_dwb_parameters, chr(10))
              v_cod_unid_negoc_fim        = entry(15,dwb_rpt_param.cod_dwb_parameters, chr(10))
              v_cod_portador_ini          = entry(16,dwb_rpt_param.cod_dwb_parameters, chr(10))
              v_cod_portador_fim          = entry(17,dwb_rpt_param.cod_dwb_parameters, chr(10))
              v_cod_espec_docto_ini       = entry(18,dwb_rpt_param.cod_dwb_parameters, chr(10))
              v_cod_espec_docto_fim       = entry(19,dwb_rpt_param.cod_dwb_parameters, chr(10))
              v_cdn_cliente_ini           = integer(entry(20,dwb_rpt_param.cod_dwb_parameters, chr(10)))
              v_cdn_cliente_fim           = integer(entry(21,dwb_rpt_param.cod_dwb_parameters, chr(10)))
              v_cod_indic_econ_ini        = entry(22,dwb_rpt_param.cod_dwb_parameters, chr(10))
              v_cod_indic_econ_fim        = entry(23,dwb_rpt_param.cod_dwb_parameters, chr(10))
              v_dat_emis_docto_ini        = date(entry(24,dwb_rpt_param.cod_dwb_parameters, chr(10)))
              v_dat_emis_docto_fim        = date(entry(25,dwb_rpt_param.cod_dwb_parameters, chr(10)))
              v_dat_vencto_tit_acr_ini    = date(entry(26,dwb_rpt_param.cod_dwb_parameters, chr(10)))
              v_dat_vencto_tit_acr_fim    = date(entry(27,dwb_rpt_param.cod_dwb_parameters, chr(10)))
              v_log_prev                  = (entry(28,dwb_rpt_param.cod_dwb_parameters, chr(10)) = "yes" /*l_yes*/ ).
    end /* if */.
    else do:
       assign v_dat_cotac_indic_econ = today
              v_ind_classif          = "Por C¢digo Cliente/T°tulo" /*l_por_codigo_clientetitulo*/ 
              rs_prev_antec          = "Previs‰es" /*l_previsoes*/ .
    end /* else */.

    if  num-entries( dwb_rpt_param.cod_dwb_parameters , chr(10) ) >= 30
    then do:
        assign v_des_estab_select = entry(30, dwb_rpt_param.cod_dwb_parameters, chr(10)).
        run pi_vld_estab_select (Input "ACR" /*l_acr*/ ).
    end /* if */.
    else do:
        run pi_vld_permissao_usuar_estab_empres (Input "ACR" /*l_acr*/ ).
    end /* else */.

    display bt_can
            bt_classificacao
            bt_close
            bt_get_file
            bt_hel2
            bt_print
            bt_ran2
            bt_set_printer
            ed_1x40
            rs_cod_dwb_output
            rs_ind_run_mode
            rs_prev_antec
            v_cod_finalid_econ
            v_cod_finalid_econ_apres
            v_dat_cotac_indic_econ
            v_ind_visualiz_tit_acr_vert
            v_log_lista_abat_pend
            v_log_lista_cta_ctbl
            v_log_lista_ped
            v_log_print_par
            v_log_sdo_zero
            v_log_tot_por_espec
            v_qtd_column
            v_qtd_line
            with frame f_rpt_41_tit_acr_antecip_prev.

/* tech38629 - Alteraá∆o efetuada via filtro */
&if '{&emsbas_version}':U >= '5.05':U &then
    run pi_posiciona_dwb_rpt_param in v_prog_filtro_pdf (input rowid(dwb_rpt_param)).
    run pi_load_params in v_prog_filtro_pdf.
&endif
/* tech38629 - Fim da alteraá∆o */



    apply "value-changed" to rs_cod_dwb_output in frame f_rpt_41_tit_acr_antecip_prev. 

    /* End_Include: ix_p10_rpt_tit_acr_antecip_prev_acr */


    block1:
    repeat on error undo block1, retry block1:

        main_block:
        repeat on error undo super_block, retry super_block
                        on endkey undo super_block, leave super_block
                        on stop undo super_block, retry super_block
                        with frame f_rpt_41_tit_acr_antecip_prev:

            if (retry) then
                output stream s_1 close.
            assign v_log_print = no.
            if  valid-handle(v_wgh_focus) then
                wait-for go of frame f_rpt_41_tit_acr_antecip_prev focus v_wgh_focus.
            else
                wait-for go of frame f_rpt_41_tit_acr_antecip_prev.

            param_block:
            do transaction:
                /* ix_p15_rpt_tit_acr_antecip_prev_acr */
                assign dwb_rpt_param.log_dwb_print_parameters = input frame f_rpt_41_tit_acr_antecip_prev v_log_print_par
                       dwb_rpt_param.ind_dwb_run_mode         = input frame f_rpt_41_tit_acr_antecip_prev rs_ind_run_mode
                       input frame f_rpt_41_tit_acr_antecip_prev v_qtd_line.

                assign dwb_rpt_param.cod_dwb_parameters = v_ind_visualiz_tit_acr_vert      + chr(10) +
rs_prev_antec                    + chr(10) +
v_cod_finalid_econ               + chr(10) +
v_cod_finalid_econ_apres         + chr(10) +
string(v_dat_cotac_indic_econ)   + chr(10) +
string(v_log_tot_por_espec)      + chr(10) +
string(v_log_sdo_zero)           + chr(10) +
string(v_log_lista_ped)          + chr(10) +
string(v_log_lista_abat_pend)    + chr(10) +
string(v_log_lista_cta_ctbl)     + chr(10) +
v_ind_classif                    + chr(10) +
''                               + chr(10) +
''                               + chr(10) +
v_cod_unid_negoc_ini             + chr(10) +
v_cod_unid_negoc_fim             + chr(10) +
v_cod_portador_ini               + chr(10) +
v_cod_portador_fim               + chr(10) +
v_cod_espec_docto_ini            + chr(10) +
v_cod_espec_docto_fim            + chr(10) +
string(v_cdn_cliente_ini)        + chr(10) +
string(v_cdn_cliente_fim)        + chr(10) +
v_cod_indic_econ_ini             + chr(10) +
v_cod_indic_econ_fim             + chr(10) +
string(v_dat_emis_docto_ini)     + chr(10) +
string(v_dat_emis_docto_fim)     + chr(10) +
string(v_dat_vencto_tit_acr_ini) + chr(10) +
string(v_dat_vencto_tit_acr_fim) + chr(10) +
string(v_log_prev)               + chr(10) +
string(v_val_cotac_indic_econ)   + chr(10) +
v_des_estab_select.

                /* ix_p20_rpt_tit_acr_antecip_prev_acr */
            end /* do param_block */.

            if  v_log_print = yes
            then do:
/* Alteracao via filtro - Controle de impressao - inicio */
&IF "{&product_version}" >= "11.5.7" &THEN
               IF CAN-FIND(FIRST param_extens_ems
                           WHERE PARAM_extens_ems.cod_entid_param_ems = "histor_impres":U
                             AND param_extens_ems.cod_chave_param_ems = "histor_impres":U
                             AND param_extens_ems.cod_param_ems       = "log_histor_impres":U
                             AND param_extens_ems.log_param_ems       = YES) AND
                  CAN-FIND(FIRST usuar_mestre
                           WHERE usuar_mestre.cod_usuario = v_cod_usuar_corren
                             AND usuar_mestre.log_solic_impres = YES) AND
                 (dwb_rpt_param.cod_dwb_output = "Impressora":U OR
                  dwb_rpt_param.cod_dwb_output = "Impresora":U OR
                  dwb_rpt_param.cod_dwb_output = "printer":U) THEN DO:

                  RUN btb/btb004aa.w (OUTPUT v_cod_usuar_abert).
                  RUN pi-grava-usuar-solic.

               END.
&ENDIF
/* Alteracao via filtro - Controle de impressao - fim    */

/* Alteracao via filtro - Impressao grandes volumes - inicio */
&IF "{&product_version}" >= "11.5.7" &THEN
               ASSIGN v_nom_dwb_print_file = REPLACE(v_nom_dwb_print_file,"~\","~/").

               IF CAN-FIND(FIRST PARAM_extens_ems
                           WHERE PARAM_extens_ems.cod_entid_param_ems = "impressao":U
                             AND PARAM_extens_ems.cod_chave_param_ems = "impress_escala":U
                             AND PARAM_extens_ems.cod_param_ems       = "impress_escala":U
                             AND PARAM_extens_ems.log_param_ems       = YES) THEN DO:
                  IF v_nom_dwb_print_file <> "" THEN DO:
                     IF SUBSTRING(v_nom_dwb_print_file, LENGTH(v_nom_dwb_print_file) - 3, 1) = "." THEN DO:
                        ASSIGN v_nom_dwb_print_file = SUBSTRING(v_nom_dwb_print_file,1,INDEX(v_nom_dwb_print_file,"."))
                           + STRING(TODAY,"99999999")
                           + STRING(TIME,"99999")
                           + SUBSTRING(v_nom_dwb_print_file, LENGTH(v_nom_dwb_print_file) - 3).
                     END.
                     IF INDEX(v_nom_dwb_print_file, "/") = 0 THEN DO:
                        FIND FIRST usuar_mestre NO-LOCK
                           WHERE usuar_mestre.cod_usuario = v_cod_dwb_user NO-ERROR.
                        IF AVAIL usuar_mestre THEN
                           ASSIGN v_nom_dwb_print_file = usuar_mestre.nom_dir_spool + "/" + usuar_mestre.nom_subdir_spool + "/" + v_nom_dwb_print_file
                                  v_nom_dwb_print_file = REPLACE(v_nom_dwb_print_file,"~\","~/").
                     END.
                  END.
               END.
&ENDIF
/* Alteracao via filtro - Impressao grandes volumes - fim    */

                if  dwb_rpt_param.ind_dwb_run_mode = "Batch" /*l_batch*/ 
                then do:
                   if  dwb_rpt_param.cod_dwb_output = "Arquivo" /*l_file*/ 
                   then do:
                       assign v_cod_dwb_file = replace(dwb_rpt_param.cod_dwb_file, "~\", "~/")
                              v_nom_integer = v_cod_dwb_file.
                       if  index(v_cod_dwb_file, ":") <> 0
                       then do:
                           /* Nome de arquivo com problemas. */
                           run pi_messages (input "show",
                                            input 1979,
                                            input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")) /*msg_1979*/.
                           next main_block.
                       end /* if */.

                       file_1:
                       do
                          while index(v_cod_dwb_file,"~/") <> 0:
                          assign v_cod_dwb_file = substring(v_cod_dwb_file,(index(v_cod_dwb_file,"~/" ) + 1)).
                       end /* do file_1 */.

                       /* valname: */
                       case num-entries(v_cod_dwb_file,"."):
                           when 1 then
                               if  length(v_cod_dwb_file) > 8
                               then do:
                                  /* Nome de arquivo com problemas. */
                                  run pi_messages (input "show",
                                                   input 1979,
                                                   input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")) /*msg_1979*/.
                                  next main_block.
                               end /* if */.
                           when 2 then
                               if  length(entry(1, v_cod_dwb_file, ".")) > 8
                               or length(entry(2, v_cod_dwb_file, ".")) > 3
                               then do:
                                  /* Nome de arquivo com problemas. */
                                  run pi_messages (input "show",
                                                   input 1979,
                                                   input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")) /*msg_1979*/.
                                  next main_block.
                               end /* if */.
                           otherwise other:
                                     do:
                               /* Nome de arquivo com problemas. */
                               run pi_messages (input "show",
                                                input 1979,
                                                input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")) /*msg_1979*/.
                               next main_block.
                           end /* do other */.
                       end /* case valname */.
                   end /* if */.
/* tech38629 - Alteraá∆o efetuada via filtro */
&if '{&emsbas_version}':U >= '5.05':U &then
                    run pi_filename_batch in v_prog_filtro_pdf.
&endif
/* tech38629 - Fim da alteraá∆o */


                   assign v_cod_dwb_file = v_nom_integer.
                   if  search("prgtec/btb/btb911za.r") = ? and search("prgtec/btb/btb911za.p") = ? then do:
                       if  v_cod_dwb_user begins 'es_' then
                           return "Programa execut†vel n∆o foi encontrado:" /*l_programa_nao_encontrado*/  + "prgtec/btb/btb911za.p".
                       else do:
                           message "Programa execut†vel n∆o foi encontrado:" /*l_programa_nao_encontrado*/  "prgtec/btb/btb911za.p"
                                  view-as alert-box error buttons ok.
                           return.
                       end.
                   end.
                   else
                       run prgtec/btb/btb911za.p (Input v_cod_dwb_program,
                                              Input v_cod_release,
                                              Input 41,
                                              Input recid(dwb_rpt_param),
                                              output v_num_ped_exec) /*prg_fnc_criac_ped_exec*/.
                   if (v_num_ped_exec <> 0) then
                       leave main_block.
                   else
                       next main_block.
                end /* if */.
                else do:
                    assign v_log_method = session:set-wait-state('general')
                           v_nom_report_title = fill(" ", 40 - length(v_rpt_s_1_name)) + v_rpt_s_1_name.
                    /* out_def: */
&if '{&emsbas_version}':U >= '5.05':U &then
/*                    case dwb_rpt_param.cod_dwb_output:*/
&else
                    case dwb_rpt_param.cod_dwb_output:
&endif
&if '{&emsbas_version}':U >= '5.05':U &then
/*                        when "Terminal" /*l_terminal*/ then out_term:*/
                        if dwb_rpt_param.cod_dwb_output = 'Terminal' then
&else
                        when "Terminal" /*l_terminal*/ then out_term:
&endif
                         do:
                            assign v_cod_dwb_file   = session:temp-directory + substring ("prgfin/acr/acr339ab.py", 12, 6) + '.tmp'
                                   v_rpt_s_1_bottom = v_qtd_line - (v_rpt_s_1_lines - v_qtd_bottom).
                            output stream s_1 to value(v_cod_dwb_file) paged page-size value(v_qtd_line) convert target 'iso8859-1'.
                        end /* do out_term */.
&if '{&emsbas_version}':U >= '5.05':U &then
/*                        when "Impressora" /*l_printer*/ then out_print:*/
                        if dwb_rpt_param.cod_dwb_output = 'Impressora' and getCodTipoRelat() <> 'PDF':U and getCodTipoRelat() <> 'RTF':U then
&else
                        when "Impressora" /*l_printer*/ then out_print:
&endif
                         do:
                            find imprsor_usuar no-lock
                                 where imprsor_usuar.nom_impressora = dwb_rpt_param.nom_dwb_printer
                                   and imprsor_usuar.cod_usuario = dwb_rpt_param.cod_dwb_user
&if "{&emsbas_version}" >= "5.01" &then
                                 use-index imprsrsr_id
&endif
                                  /*cl_get_printer of imprsor_usuar*/ no-error.
                            find impressora no-lock
                                 where impressora.nom_impressora = imprsor_usuar.nom_impressora
                                  no-error.
                            find tip_imprsor no-lock
                                 where tip_imprsor.cod_tip_imprsor = impressora.cod_tip_imprsor
                                  no-error.
                            find layout_impres no-lock
                                 where layout_impres.nom_impressora = dwb_rpt_param.nom_dwb_printer
                                   and layout_impres.cod_layout_impres = dwb_rpt_param.cod_dwb_print_layout /*cl_get_layout of layout_impres*/ no-error.
                            assign v_rpt_s_1_bottom = layout_impres.num_lin_pag - (v_rpt_s_1_lines - v_qtd_bottom).
&if '{&emsbas_version}' > '1.00' &then
                            if  v_nom_dwb_print_file <> "" then
                                if  layout_impres.num_lin_pag = 0 then
                                    output stream s_1 to value(lc(v_nom_dwb_print_file))
                                           page-size 0 convert target tip_imprsor.cod_pag_carac_conver.
                                else
                                    output stream s_1 to value(lc(v_nom_dwb_print_file))
                                           paged page-size value(layout_impres.num_lin_pag) convert target  tip_imprsor.cod_pag_carac_conver.
                            else
&endif
                                if  layout_impres.num_lin_pag = 0 then
                                    output stream s_1 to value(imprsor_usuar.nom_disposit_so)
                                           page-size 0 convert target tip_imprsor.cod_pag_carac_conver.
                                else
                                    output stream s_1 to value(imprsor_usuar.nom_disposit_so)
                                           paged page-size value(layout_impres.num_lin_pag) convert target  tip_imprsor.cod_pag_carac_conver.

                            setting:
                            for
                                each configur_layout_impres no-lock
                                where configur_layout_impres.num_id_layout_impres = layout_impres.num_id_layout_impres

                                by configur_layout_impres.num_ord_funcao_imprsor:
                                find configur_tip_imprsor no-lock
                                     where configur_tip_imprsor.cod_tip_imprsor = layout_impres.cod_tip_imprsor
                                       and configur_tip_imprsor.cod_funcao_imprsor = configur_layout_impres.cod_funcao_imprsor
                                       and configur_tip_imprsor.cod_opc_funcao_imprsor = configur_layout_impres.cod_opc_funcao_imprsor
&if "{&emsbas_version}" >= "5.01" &then
                                     use-index cnfgrtpm_id
&endif
                                      /*cl_get_print_command of configur_tip_imprsor*/ no-error.
                                bloco_1:
                                do
                                    v_num_count = 1 to extent(configur_tip_imprsor.num_carac_configur):
                                    /* configur_tip_imprsor: */
                                    case configur_tip_imprsor.num_carac_configur[v_num_count]:
                                         when 0 then put  stream s_1 control null.
                                         when ? then leave.
                                         otherwise 
                                             /* Convers∆o interna do OUTPUT TARGET */
                                             put stream s_1 control codepage-convert ( chr(configur_tip_imprsor.num_carac_configur[v_num_count]),
                                                                                       session:cpinternal,
                                                                                       tip_imprsor.cod_pag_carac_conver).
                                    end /* case configur_tip_imprsor */.
                                end /* do bloco_1 */.   
                            end /* for setting */.
                        end /* do out_print */.
&if '{&emsbas_version}':U >= '5.05':U &then
/*                        when "Arquivo" /*l_file*/ then out_file:*/
                        if dwb_rpt_param.cod_dwb_output = 'Impressora' and getCodTipoRelat() = 'PDF':U then do:
                            run pi_config_output_print_pdf in v_prog_filtro_pdf (input v_qtd_line, input-output v_cod_dwb_file, input dwb_rpt_param.cod_dwb_user, input no).
                        end.
                        if dwb_rpt_param.cod_dwb_output = 'Arquivo' then
&else
                        when "Arquivo" /*l_file*/ then out_file:
&endif
                         do:
                            assign v_cod_dwb_file   = dwb_rpt_param.cod_dwb_file
                                   v_rpt_s_1_bottom = v_qtd_line - (v_rpt_s_1_lines - v_qtd_bottom).

/* tech38629 - Alteraá∆o efetuada via filtro */
&if '{&emsbas_version}':U >= '5.05':U &then
run pi_rename_file in v_prog_filtro_pdf (input-output v_cod_dwb_file).
&endif
/* tech38629 - Fim da alteraá∆o */



                            output stream s_1 to value(v_cod_dwb_file)
                                   paged page-size value(v_qtd_line) convert target 'iso8859-1'.
                        end /* do out_file */.
&if '{&emsbas_version}':U >= '5.05':U &then
/*                    end /* case out_def */.*/
&else
                    end /* case out_def */.
&endif
                    assign v_nom_prog_ext  = caps(substring("prgfin/acr/acr339ab.py",12,8))
                           v_cod_release   = trim(" 1.00.00.012":U)
                           v_dat_execution = today
                           v_hra_execution = replace(string(time,"hh:mm:ss" /*l_hh:mm:ss*/ ),":","").
                    run pi_rpt_tit_acr_antecip_prev_acr /*pi_rpt_tit_acr_antecip_prev_acr*/.
                end /* else */.
                if  dwb_rpt_param.log_dwb_print_parameters = yes
                then do:
                    if (page-number (s_1) > 0) then
                        page stream s_1.
                    /* ix_p29_rpt_tit_acr_antecip_prev_acr */    
                    hide stream s_1 frame f_rpt_s_1_header_period.
                    view stream s_1 frame f_rpt_s_1_header_unique.
                    hide stream s_1 frame f_rpt_s_1_footer_last_page.
                    hide stream s_1 frame f_rpt_s_1_footer_normal.
                    view stream s_1 frame f_rpt_s_1_footer_param_page.
                    if (line-counter(s_1) + 3) > v_rpt_s_1_bottom then
                        page stream s_1.
                    put stream s_1 unformatted 
                        skip (1)
                        "Usu†rio: " at 1
                        v_cod_usuar_corren at 10 format "x(12)" skip (1).

                    /* Begin_Include: ix_p30_rpt_tit_acr_antecip_prev_acr */
                    if (line-counter(s_1) + 23) > v_rpt_s_1_bottom then
                        page stream s_1.
                    put stream s_1 unformatted 
                        skip (1)
                        "---------------------------------------------" at 33
                        "Visualizaá∆o" at 79
                        "---------------------------------------------" at 93
                        skip (1)
                        "  Visualiza: " at 74
                        v_ind_visualiz_tit_acr_vert at 87 format "X(20)" skip.
                    put stream s_1 unformatted 
                        v_ind_classif at 87 format "X(35)"
                        skip (1)
                        "---------------------------------------------" at 33
                        "Apresentaá∆o  " at 79
                        "---------------------------------------------" at 93
                        skip (1)
                        "    Finalidade Econìmica: " at 61
                        v_cod_finalid_econ at 87 format "x(10)" skip
                        "Finalid Apresentaá∆o: " at 65
                        v_cod_finalid_econ_apres at 87 format "x(10)" skip.
                    put stream s_1 unformatted 
                        "Data Cotaá∆o: " at 73
                        v_dat_cotac_indic_econ at 87 format "99/99/9999"
                        skip (1)
                        "---------------------------------------------" at 33
                        "Tipo EspÇcie  " at 79
                        "---------------------------------------------" at 93
                        skip (1)
                        v_ind_tip_espec_docto at 78 format "X(17)"
                        skip (1)
                        "---------------------------------------------" at 37.
                    put stream s_1 unformatted 
                        "Opá‰es" at 83
                        "---------------------------------------------" at 90
                        skip (1)
                        "Totaliza por EspÇcie:    " at 72
                        v_log_tot_por_espec at 100 format "Sim/N∆o" skip
                        "Lista AN/PREV Totalmente Abatidas:       " at 59
                        v_log_sdo_zero at 100 format "Sim/N∆o" skip
                        "Lista Pedidos:   " at 79
                        v_log_lista_ped at 100 format "Sim/N∆o" skip
                        "Lista Abatimentos Pendentes:      " at 65.
                    put stream s_1 unformatted 
                        v_log_lista_abat_pend at 100 format "Sim/N∆o" skip
                        "Lista Conta Cont†bil:    " at 72
                        v_log_lista_cta_ctbl at 100 format "Sim/N∆o" skip.
                    /* End_Include: ix_p30_rpt_tit_acr_antecip_prev_acr */

                end /* if */.

/* Alteracao via filtro - Controle de impressao - inicio */
&IF "{&product_version}" >= "11.5.7" &THEN
                ASSIGN v_page_number = PAGE-NUMBER(s_1) NO-ERROR.
&ENDIF
/* Alteracao via filtro - Controle de impressao - fim    */

                output stream s_1 close.

/* tech38629 - Alteraá∆o efetuada via filtro */
&if '{&emsbas_version}':U >= '5.05':U &then
run pi_call_convert_object in v_prog_filtro_pdf (input no,
                                                 input rs_cod_dwb_output:screen-value in frame f_rpt_41_tit_acr_antecip_prev,
                                                 input v_nom_dwb_print_file,
                                                 input v_cod_dwb_file,
                                                 input v_nom_report_title).
&endif
/* tech38629 - Fim da alteraá∆o */


&if '{&emsbas_version}':U >= '5.05':U &then
    if ((dwb_rpt_param.cod_dwb_output = 'Impressora':U or dwb_rpt_param.cod_dwb_output = 'Impresora':U or dwb_rpt_param.cod_dwb_output = 'printer':U) and getCodTipoRelat() = 'PDF':U) then do:
        if v_nom_dwb_print_file = '' then
            run pi_print_pdf_file in v_prog_filtro_pdf (input no).
    end.
&endif
                assign v_log_method = session:set-wait-state("").
                if (dwb_rpt_param.cod_dwb_output = "Terminal" /*l_terminal*/ ) then
                /* tech38629 - Alteraá∆o efetuada via filtro */
                &if '{&emsbas_version}':U >= '5.05':U &then
                    if  getCodTipoRelat() = 'PDF':U and OPSYS = 'WIN32':U
                    then do:
                        run pi_open_pdf_file in v_prog_filtro_pdf.
                    end.
                    else if getCodTipoRelat() = 'Texto' then do:
                &endif
                /* tech38629 - Fim da alteraá∆o */
                    run pi_show_report_2 (Input v_cod_dwb_file) /*pi_show_report_2*/.
                /* tech38629 - Alteraá∆o efetuada via filtro */
                &if '{&emsbas_version}':U >= '5.05':U &then
                    end.
                &endif
                /* tech38629 - Fim da alteraá∆o */


/* Alteracao via filtro - Controle de impressao - inicio */
&IF "{&product_version}" >= "11.5.7" &THEN
                RUN prgtec/btb/btb001.p (INPUT v_cod_usuar_corren,
                                         INPUT v_cod_usuar_abert,
                                         INPUT v_page_number,
                                         INPUT v_dat_execution,
                                         INPUT v_cod_dwb_program,
                                         INPUT v_nom_report_title,
                                         INPUT v_nom_dwb_printer,
                                         INPUT v_nom_dwb_print_file).
&ENDIF
/* Alteracao via filtro - Controle de impressao - fim    */

                leave main_block.

            end /* if */.
            else do:
                leave super_block.
            end /* else */.

        end /* repeat main_block */.

        /* ix_p32_rpt_tit_acr_antecip_prev_acr */

        if  v_num_ped_exec <> 0
        then do:
            /* Criado pedido &1 para execuá∆o batch. */
            run pi_messages (input "show",
                             input 3556,
                             input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9",
                                                v_num_ped_exec)) /*msg_3556*/.
            assign v_num_ped_exec = 0.
        end /* if */.

        /* ix_p35_rpt_tit_acr_antecip_prev_acr */

    end /* repeat block1 */.
end /* repeat super_block */.

/* ix_p40_rpt_tit_acr_antecip_prev_acr */

hide frame f_rpt_41_tit_acr_antecip_prev.

/* Begin_Include: i_log_exec_prog_dtsul_fim */
if v_rec_log <> ? then do transaction:
    find log_exec_prog_dtsul where recid(log_exec_prog_dtsul) = v_rec_log exclusive-lock no-error.
    if  avail log_exec_prog_dtsul
    then do:
        assign log_exec_prog_dtsul.dat_fim_exec_prog_dtsul = today
               log_exec_prog_dtsul.hra_fim_exec_prog_dtsul = replace(string(time,"hh:mm:ss" /*l_hh:mm:ss*/ ),":":U,"":U).
    end /* if */.
    release log_exec_prog_dtsul.
end.

/* End_Include: i_log_exec_prog_dtsul_fim */


if  this-procedure:persistent then
    delete procedure this-procedure.

/* tech38629 - Alteraá∆o efetuada via filtro */
&if '{&emsbas_version}':U >= '5.05':U &then
delete procedure v_prog_filtro_pdf.
&endif
/* tech38629 - Fim da alteraá∆o */





/******************************* Main Code End ******************************/

/************************* Internal Procedure Begin *************************/

/* Alteracao via filtro - Controle de impressao - inicio    */
&IF "{&product_version}" >= "11.5.7" &THEN
PROCEDURE pi-grava-usuar-solic:
   DO TRANSACTION:
      FIND b-dwb_rpt_param EXCLUSIVE-LOCK
         WHERE ROWID(b-dwb_rpt_param) = ROWID(dwb_rpt_param) NO-ERROR.
      IF AVAIL b-dwb_rpt_param THEN
         ASSIGN b-dwb_rpt_param.cod_livre_1 = TRIM(v_cod_usuar_abert).
      RELEASE b-dwb_rpt_param.
   END.
END PROCEDURE.
&ENDIF
/* Alteracao via filtro - Controle de impressao - fim    */


/*****************************************************************************
** Procedure Interna.....: pi_return_user
** Descricao.............: pi_return_user
** Criado por............: 
** Criado em.............: // 
** Alterado por..........: vladimir
** Alterado em...........: 12/02/1996 10:16:42
*****************************************************************************/
PROCEDURE pi_return_user:

    /************************ Parameter Definition Begin ************************/

    def output param p_nom_user
        as character
        format "x(32)"
        no-undo.


    /************************* Parameter Definition End *************************/

    assign p_nom_user = v_cod_usuar_corren.

    if  v_cod_usuar_corren begins 'es_'
    then do:
       assign v_cod_usuar_corren = entry(2,v_cod_usuar_corren,"_").
    end /* if */.

END PROCEDURE. /* pi_return_user */
/*****************************************************************************
** Procedure Interna.....: pi_filename_validation
** Descricao.............: pi_filename_validation
** Criado por............: 
** Criado em.............: // 
** Alterado por..........: tech35592
** Alterado em...........: 14/02/2006 07:39:05
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
        if  index('abcdefghijklmnopqrstuvwxyz0123456789-_:/.', substring(v_cod_1, v_num_1, 1)) = 0
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

    if  num-entries(v_cod_1, ".") > 2
    then do:
        return "NOK" /*l_nok*/ .
    end /* if */.

    if  num-entries(v_cod_1, ".") = 2 and length(entry(2,v_cod_1,".")) > 3
    then do:
        return "NOK" /*l_nok*/ .
    end /* if */.

    if  index(entry(num-entries(v_cod_1, "/"),v_cod_1, "/"),".") = 0
    then do:
        return "NOK" /*l_nok*/ .
    end /* if */.
    else do:
        if  entry(1,entry(num-entries(v_cod_1,"/"),v_cod_1,"/"),".") = ""
        or  entry(2,entry(num-entries(v_cod_1,"/"),v_cod_1,"/"),".") = ""
        then do:
           return "NOK" /*l_nok*/ .
        end /* if */.
    end /* else */.

    assign v_num_1 = 1.
    2_block:
    repeat v_num_2 = 1 to length(v_cod_1):
        if  index(":" + "/" + ".", substring(v_cod_1, v_num_2, 1)) > 0
        then do:
            assign v_cod_2 = substring(v_cod_1, v_num_1, v_num_2 - v_num_1)
                   v_num_1 = v_num_2 + 1.
            if  length(v_cod_2) > 8
            then do:
                return "NOK" /*l_nok*/ .
            end /* if */.
        end /* if */.
    end /* repeat 2_block */.
    assign v_cod_2 = substring(v_cod_1, v_num_1).
    if  length(v_cod_2) > 8
    then do:
        return "NOK" /*l_nok*/ .
    end /* if */.

    return "OK" /*l_ok*/ .
END PROCEDURE. /* pi_filename_validation */
/*****************************************************************************
** Procedure Interna.....: pi_set_print_layout_default
** Descricao.............: pi_set_print_layout_default
** Criado por............: Gilsinei
** Criado em.............: 04/03/1996 09:22:54
** Alterado por..........: bre19127
** Alterado em...........: 16/09/2002 08:39:04
*****************************************************************************/
PROCEDURE pi_set_print_layout_default:

    dflt:
    do with frame f_rpt_41_tit_acr_antecip_prev:

        find layout_impres_padr no-lock
             where layout_impres_padr.cod_usuario = v_cod_dwb_user
               and layout_impres_padr.cod_proced = v_cod_dwb_proced
    &if "{&emsbas_version}" >= "5.01" &then
             use-index lytmprsp_id
    &endif
              /*cl_default_procedure_user of layout_impres_padr*/ no-error.
        if  not avail layout_impres_padr
        then do:
            find layout_impres_padr no-lock
                 where layout_impres_padr.cod_usuario = "*"
                   and layout_impres_padr.cod_proced = v_cod_dwb_proced
    &if "{&emsbas_version}" >= "5.01" &then
                 use-index lytmprsp_id
    &endif
                  /*cl_default_procedure of layout_impres_padr*/ no-error.
            if  avail layout_impres_padr
            then do:
                find imprsor_usuar no-lock
                     where imprsor_usuar.nom_impressora = layout_impres_padr.nom_impressora
                       and imprsor_usuar.cod_usuario = v_cod_dwb_user
    &if "{&emsbas_version}" >= "5.01" &then
                     use-index imprsrsr_id
    &endif
                      /*cl_layout_current_user of imprsor_usuar*/ no-error.
            end /* if */.
            if  not avail imprsor_usuar
            then do:
                find layout_impres_padr no-lock
                     where layout_impres_padr.cod_usuario = v_cod_dwb_user
                       and layout_impres_padr.cod_proced = "*"
    &if "{&emsbas_version}" >= "5.01" &then
                     use-index lytmprsp_id
    &endif
                      /*cl_default_user of layout_impres_padr*/ no-error.
            end /* if */.
        end /* if */.
        do transaction:
            find dwb_rpt_param
                where dwb_rpt_param.cod_dwb_user = v_cod_usuar_corren
                and   dwb_rpt_param.cod_dwb_program = v_cod_dwb_program
                exclusive-lock no-error.
            if  avail layout_impres_padr
            then do:
                assign dwb_rpt_param.nom_dwb_printer      = layout_impres_padr.nom_impressora
                       dwb_rpt_param.cod_dwb_print_layout = layout_impres_padr.cod_layout_impres
                       ed_1x40:screen-value = dwb_rpt_param.nom_dwb_printer
                                            + ":"
                                            + dwb_rpt_param.cod_dwb_print_layout.
            end /* if */.
            else do:
                assign dwb_rpt_param.nom_dwb_printer       = ""
                       dwb_rpt_param.cod_dwb_print_layout  = ""
                       ed_1x40:screen-value = "".
            end /* else */.
        end.
    end /* do dflt */.
END PROCEDURE. /* pi_set_print_layout_default */
/*****************************************************************************
** Procedure Interna.....: pi_show_report_2
** Descricao.............: pi_show_report_2
** Criado por............: Gilsinei
** Criado em.............: 07/03/1996 14:42:50
** Alterado por..........: bre19127
** Alterado em...........: 21/05/2002 10:16:34
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
** Procedure Interna.....: pi_output_reports
** Descricao.............: pi_output_reports
** Criado por............: glauco
** Criado em.............: 21/03/1997 09:26:29
** Alterado por..........: tech38629
** Alterado em...........: 06/10/2006 22:40:15
*****************************************************************************/
PROCEDURE pi_output_reports:

/* tech38629 - Alteraá∆o efetuada via filtro */
&if '{&emsbas_version}':U >= '5.05':U &then
    run pi_posiciona_dwb_rpt_param in v_prog_filtro_pdf (input rowid(dwb_rpt_param)).
    run pi_load_params in v_prog_filtro_pdf.
&endif
/* tech38629 - Fim da alteraá∆o */




    assign v_log_method       = session:set-wait-state('general')
           v_nom_report_title = fill(" ",40 - length(v_rpt_s_1_name)) + v_rpt_s_1_name
           v_rpt_s_1_bottom   = v_qtd_line - (v_rpt_s_1_lines - v_qtd_bottom).

    /* block: */
&if '{&emsbas_version}':U >= '5.05':U &then
/*    case dwb_rpt_param.cod_dwb_output:*/
&else
    case dwb_rpt_param.cod_dwb_output:
&endif
&if '{&emsbas_version}':U >= '5.05':U &then
/*            when "Arquivo" /*l_file*/ then*/
            if dwb_rpt_param.cod_dwb_output = 'Impressora' and getCodTipoRelat() = 'PDF':U then do:
                run pi_config_output_print_pdf in v_prog_filtro_pdf (input v_qtd_line, input-output v_cod_dwb_file, input v_cod_usuar_corren, input yes).
            end.
            if dwb_rpt_param.cod_dwb_output = 'Arquivo' then
&else
            when "Arquivo" /*l_file*/ then
&endif
            block1:
            do:

               /* tech38629 - Relatorio PDF e RTF                 */
               /* Renomear arquivo quando extensao for pdf ou rtf */

/* tech38629 - Alteraá∆o efetuada via filtro */
&if '{&emsbas_version}':U >= '5.05':U &then
run pi_rename_file in v_prog_filtro_pdf (input-output v_cod_dwb_file).
&endif
/* tech38629 - Fim da alteraá∆o */



               output stream s_1 to value(v_cod_dwb_file)
               paged page-size value(v_qtd_line) convert target 'iso8859-1'.
            end /* do block1 */.
&if '{&emsbas_version}':U >= '5.05':U &then
/*            when "Impressora" /*l_printer*/ then*/
            if dwb_rpt_param.cod_dwb_output = 'Impressora' and getCodTipoRelat() <> 'PDF':U and getCodTipoRelat() <> 'RTF':U then
&else
            when "Impressora" /*l_printer*/ then
&endif
               block2:
               do:
                  find imprsor_usuar use-index imprsrsr_id no-lock
                      where imprsor_usuar.nom_impressora = dwb_rpt_param.nom_dwb_printer
                      and   imprsor_usuar.cod_usuario    = v_cod_usuar_corren no-error.
                  find impressora no-lock
                       where impressora.nom_impressora = imprsor_usuar.nom_impressora
                        no-error.
                  find tip_imprsor no-lock
                       where tip_imprsor.cod_tip_imprsor = impressora.cod_tip_imprsor
                        no-error.
                  find layout_impres no-lock
                       where layout_impres.nom_impressora = dwb_rpt_param.nom_dwb_printer
                         and layout_impres.cod_layout_impres = dwb_rpt_param.cod_dwb_print_layout /*cl_get_layout of layout_impres*/ no-error.
                  find b_ped_exec_style
                      where b_ped_exec_style.num_ped_exec = v_num_ped_exec_corren no-lock no-error.
                  find servid_exec_imprsor no-lock
                       where servid_exec_imprsor.nom_impressora = dwb_rpt_param.nom_dwb_printer
                         and servid_exec_imprsor.cod_servid_exec = b_ped_exec_style.cod_servid_exec no-error.

                  find b_servid_exec_style no-lock
                       where b_servid_exec_style.cod_servid_exec = b_ped_exec_style.cod_servid_exec
                       no-error.

                  if  avail layout_impres
                  then do:
                     assign v_rpt_s_1_bottom = layout_impres.num_lin_pag - (v_rpt_s_1_lines - v_qtd_bottom).
                  end /* if */.

                  if  available b_servid_exec_style
                  and b_servid_exec_style.ind_tip_fila_exec = 'UNIX'
                  then do:
                      &if '{&emsbas_version}' > '1.00' &then           
                      &if '{&emsbas_version}' >= '5.03' &then           
                          if dwb_rpt_param.nom_dwb_print_file <> "" then do:
                              if  layout_impres.num_lin_pag = 0
                              then do:
                                  output stream s_1 to value(lc(dwb_rpt_param.nom_dwb_print_file))
                                         page-size 0 convert target tip_imprsor.cod_pag_carac_conver.
                              end /* if */. 
                              else do:
                                  output stream s_1 to value(lc(dwb_rpt_param.nom_dwb_print_file))
                                         paged page-size value(layout_impres.num_lin_pag) convert target tip_imprsor.cod_pag_carac_conver.
                              end /* else */.
                          end.
                          else do:
                              if  layout_impres.num_lin_pag = 0
                              then do:
                                  output stream s_1 through value(servid_exec_imprsor.nom_disposit_so)
                                         page-size 0 convert target tip_imprsor.cod_pag_carac_conver.
                              end /* if */. 
                              else do:
                                  output stream s_1 through value(servid_exec_imprsor.nom_disposit_so)
                                         paged page-size value(layout_impres.num_lin_pag) convert target tip_imprsor.cod_pag_carac_conver.
                              end /* else */.
                          end.
                      &else
                          if dwb_rpt_param.cod_livre_1 <> "" then do:
                              if  layout_impres.num_lin_pag = 0
                              then do:
                                  output stream s_1 to value(lc(dwb_rpt_param.cod_livre_1))
                                         page-size 0 convert target tip_imprsor.cod_pag_carac_conver.
                              end /* if */. 
                              else do:
                                  output stream s_1 to value(lc(dwb_rpt_param.cod_livre_1))
                                         paged page-size value(layout_impres.num_lin_pag) convert target tip_imprsor.cod_pag_carac_conver.
                              end /* else */.
                          end.
                          else do:
                              if  layout_impres.num_lin_pag = 0
                              then do:
                                  output stream s_1 through value(servid_exec_imprsor.nom_disposit_so)
                                         page-size 0 convert target tip_imprsor.cod_pag_carac_conver.
                              end /* if */. 
                              else do:
                                  output stream s_1 through value(servid_exec_imprsor.nom_disposit_so)
                                         paged page-size value(layout_impres.num_lin_pag) convert target tip_imprsor.cod_pag_carac_conver.
                              end /* else */.
                          end.
                      &endif
                      &endif
                  end /* if */.
                  else do:
                      &if '{&emsbas_version}' > '1.00' &then           
                      &if '{&emsbas_version}' >= '5.03' &then           
                          if dwb_rpt_param.nom_dwb_print_file <> "" then do:
                              if  layout_impres.num_lin_pag = 0
                              then do:
                                  output stream s_1 to value(lc(dwb_rpt_param.nom_dwb_print_file))
                                         page-size 0 convert target tip_imprsor.cod_pag_carac_conver.                            
                              end /* if */.
                              else do:
                                  output stream s_1 to value(lc(dwb_rpt_param.nom_dwb_print_file))
                                         paged page-size value(layout_impres.num_lin_pag) convert target tip_imprsor.cod_pag_carac_conver.                     
                              end /* else */.
                          end.
                          else do:
                              if  layout_impres.num_lin_pag = 0
                              then do:
                                  output stream s_1 to value(servid_exec_imprsor.nom_disposit_so)
                                         page-size 0 convert target tip_imprsor.cod_pag_carac_conver.                            
                              end /* if */.
                              else do:
                                  output stream s_1 to value(servid_exec_imprsor.nom_disposit_so)
                                         paged page-size value(layout_impres.num_lin_pag) convert target tip_imprsor.cod_pag_carac_conver.                     
                              end /* else */.
                          end.
                      &else
                          if dwb_rpt_param.cod_livre_1 <> "" then do:
                              if  layout_impres.num_lin_pag = 0
                              then do:
                                  output stream s_1 to value(lc(dwb_rpt_param.cod_livre_1))
                                         page-size 0 convert target tip_imprsor.cod_pag_carac_conver.                            
                              end /* if */.
                              else do:
                                  output stream s_1 to value(lc(dwb_rpt_param.cod_livre_1))
                                         paged page-size value(layout_impres.num_lin_pag) convert target tip_imprsor.cod_pag_carac_conver.                     
                              end /* else */.
                          end.
                          else do:
                              if  layout_impres.num_lin_pag = 0
                              then do:
                                  output stream s_1 to value(servid_exec_imprsor.nom_disposit_so)
                                         page-size 0 convert target tip_imprsor.cod_pag_carac_conver.                            
                              end /* if */.
                              else do:
                                  output stream s_1 to value(servid_exec_imprsor.nom_disposit_so)
                                         paged page-size value(layout_impres.num_lin_pag) convert target tip_imprsor.cod_pag_carac_conver.                     
                              end /* else */.
                          end.
                      &endif
                      &endif
                  end /* else */.

                  setting:
                  for
                      each configur_layout_impres no-lock
                      where configur_layout_impres.num_id_layout_impres = layout_impres.num_id_layout_impres

                      by configur_layout_impres.num_ord_funcao_imprsor:

                      find configur_tip_imprsor no-lock
                           where configur_tip_imprsor.cod_tip_imprsor = layout_impres.cod_tip_imprsor
                             and configur_tip_imprsor.cod_funcao_imprsor = configur_layout_impres.cod_funcao_imprsor
                             and configur_tip_imprsor.cod_opc_funcao_imprsor = configur_layout_impres.cod_opc_funcao_imprsor
    &if "{&emsbas_version}" >= "5.01" &then
                           use-index cnfgrtpm_id
    &endif
                            /*cl_get_print_command of configur_tip_imprsor*/ no-error.

                      bloco_1:
                      do
                          v_num_count = 1 to extent(configur_tip_imprsor.num_carac_configur):
                          /* configur_tip_imprsor: */
                          case configur_tip_imprsor.num_carac_configur[v_num_count]:
                              when 0 then put  stream s_1 control null.
                              when ? then leave.
                              otherwise 
                                  /* Convers∆o interna do OUTPUT TARGET */
                                  put stream s_1 control codepage-convert ( chr(configur_tip_imprsor.num_carac_configur[v_num_count]),
                                                                            session:cpinternal,
                                                                            tip_imprsor.cod_pag_carac_conver).
                          end /* case configur_tip_imprsor */.
                      end /* do bloco_1 */.
                 end /* for setting */.
            end /* do block2 */.
&if '{&emsbas_version}':U >= '5.05':U &then
/*    end /* case block */.*/
&else
    end /* case block */.
&endif

    run pi_rpt_tit_acr_antecip_prev_acr /*pi_rpt_tit_acr_antecip_prev_acr*/.
END PROCEDURE. /* pi_output_reports */
/*****************************************************************************
** Procedure Interna.....: pi_rpt_tit_acr_antecip_prev_acr
** Descricao.............: pi_rpt_tit_acr_antecip_prev_acr
** Criado por............: Amarildo
** Criado em.............: 24/02/1997 15:05:12
** Alterado por..........: fut1147
** Alterado em...........: 25/07/2005 09:24:36
*****************************************************************************/
PROCEDURE pi_rpt_tit_acr_antecip_prev_acr:

    assign v_num_idx = 0.

    run pi_carrega_tt_rpt_tit_acr_antecip_prev_acr /*pi_carrega_tt_rpt_tit_acr_antecip_prev_acr*/.
    /* ******************************************************************************/
    hide stream s_1 frame f_rpt_s_1_header_period.
    view stream s_1 frame f_rpt_s_1_header_unique.
    hide stream s_1 frame f_rpt_s_1_footer_last_page.
    hide stream s_1 frame f_rpt_s_1_footer_param_page.
    view stream s_1 frame f_rpt_s_1_footer_normal.
    if v_ind_classif = "Por T°tulo" /*l_por_titulo*/  then do:
       hide stream s_1 frame f_rpt_s_1_Grp_cab_complem_Lay_compl_cab.
       view stream s_1 frame f_rpt_s_1_Grp_cab_complem_Lay_compl_cab2.
       hide stream s_1 frame f_rpt_s_1_Grp_cab_princip_Lay_cab_princip.
       view stream s_1 frame f_rpt_s_1_Grp_cab_princip_Lay_cab_princip2.
    end.   
    else do:
       hide stream s_1 frame f_rpt_s_1_Grp_cab_complem_Lay_compl_cab2.
       view stream s_1 frame f_rpt_s_1_Grp_cab_complem_Lay_compl_cab.
       hide stream s_1 frame f_rpt_s_1_Grp_cab_princip_Lay_cab_princip2.
       view stream s_1 frame f_rpt_s_1_Grp_cab_princip_Lay_cab_princip.   
    end.   

    find last param_geral_ems no-lock no-error.
    run pi_inicializa_variaveis_acr /*pi_inicializa_variaveis_acr*/.

    grp_block:
    for
        each tt_rpt_tit_acr_antecip_prev_acr no-lock
        break
        by tt_rpt_tit_acr_antecip_prev_acr.ttv_cod_dwb_field_rpt[1]
        by tt_rpt_tit_acr_antecip_prev_acr.ttv_cod_dwb_field_rpt[2]
        by tt_rpt_tit_acr_antecip_prev_acr.ttv_cod_dwb_field_rpt[3]
        by tt_rpt_tit_acr_antecip_prev_acr.ttv_cod_dwb_field_rpt[4]
        by tt_rpt_tit_acr_antecip_prev_acr.ttv_cod_dwb_field_rpt[5]
        by tt_rpt_tit_acr_antecip_prev_acr.ttv_cod_dwb_field_rpt[6]:

        ASSIGN v_cod_convenio = ""
               v_cod_cli_convenio = ?.
        FOR FIRST b1_tit_acr
            WHERE b1_tit_acr.cod_estab       = tt_rpt_tit_acr_antecip_prev_acr.cod_estab 
              AND b1_tit_acr.cod_espec_docto = tt_rpt_tit_acr_antecip_prev_acr.cod_espec_docto
              AND b1_tit_acr.cod_ser_docto   = tt_rpt_tit_acr_antecip_prev_acr.cod_ser_docto
              AND b1_tit_acr.cod_tit_acr     = tt_rpt_tit_acr_antecip_prev_acr.cod_tit_acr
              AND b1_tit_acr.cod_parcela     = tt_rpt_tit_acr_antecip_prev_acr.cod_parcela     NO-LOCK:
        
            FOR FIRST movto_tit_acr FIELDS(cod_estab num_id_movto_tit_acr) NO-LOCK
                WHERE movto_tit_acr.cod_estab      = b1_tit_acr.cod_estab
                  AND movto_tit_acr.num_id_tit_acr = b1_tit_acr.num_id_tit_acr
                  AND movto_tit_acr.ind_trans_acr  = "Implantaá∆o a CrÇdito" :
    
                FOR FIRST relacto_tit_acr FIELDS(cod_estab num_id_tit_acr) NO-LOCK
                    WHERE relacto_tit_acr.cod_estab_tit_acr_pai = movto_tit_acr.cod_estab
                      AND relacto_tit_acr.num_id_movto_tit_acr  = movto_tit_acr.num_id_movto_tit_acr:
    
                    for first b2_tit_acr no-lock
                        where b2_tit_acr.cod_estab      = relacto_tit_acr.cod_estab
                        and   b2_tit_acr.num_id_tit_acr = relacto_tit_acr.num_id_tit_acr:
                        find nota_devol_tit_acr no-lock
                            where nota_devol_tit_acr.cod_estab       = b2_tit_acr.cod_estab
                              and nota_devol_tit_acr.cod_espec_docto = b2_tit_acr.cod_espec_docto
                              and nota_devol_tit_acr.cod_ser_docto   = b2_tit_acr.cod_ser_docto
                              and nota_devol_tit_acr.cod_tit_acr     = b2_tit_acr.cod_tit_acr
                              and nota_devol_tit_acr.cod_parcela     = b2_tit_acr.cod_parcela
                            no-error.
                        if  avail nota_devol_tit_acr THEN DO:
                            FIND FIRST docum-est NO-LOCK
                                 WHERE docum-est.cod-estabel  = nota_devol_tit_acr.cod_estab 
                                   AND docum-est.cod-emitente = nota_devol_tit_acr.cdn_cliente
                                   AND docum-est.serie-docto  = nota_devol_tit_acr.cod_ser_nota_devol
                                   AND docum-est.nro-docto    = nota_devol_tit_acr.cod_nota_devol
                                   AND docum-est.nat-operacao = nota_devol_tit_acr.cod_natur_operac_devol NO-ERROR.
                            IF AVAIL docum-est THEN DO:
                                FIND FIRST item-doc-est OF docum-est NO-LOCK NO-ERROR.
                                IF AVAIL item-doc-est THEN DO:
                                    FIND FIRST cst-nota-fiscal NO-LOCK
                                         WHERE cst-nota-fiscal.cod-estabel = docum-est.cod-estabel
                                           AND cst-nota-fiscal.serie       = item-doc-est.serie-comp
                                           AND cst-nota-fiscal.nr-nota-fis = item-doc-est.nro-comp  NO-ERROR.
                                    IF AVAIL cst-nota-fiscal THEN DO:
                                        ASSIGN v_cod_convenio = cst-nota-fiscal.convenio.

                                        FIND FIRST int-ds-convenio NO-LOCK
                                             WHERE int-ds-convenio.cod-convenio = INT(cst-nota-fiscal.convenio) NO-ERROR.
                                        IF AVAIL int-ds-convenio THEN DO:
                                            FIND FIRST cliente
                                                 WHERE cliente.cod_id_feder = int-ds-convenio.cnpj NO-ERROR.
                                            IF AVAIL cliente THEN DO:
                                                ASSIGN v_cod_cli_convenio = cliente.cdn_cliente.
                                            END.
                                        END.
                                    END.
                                END.
                            END.
                        END.
                    END.
                END.
            END.
        END.

        IF v_cod_convenio = "" THEN DO:
            FOR FIRST nota-fiscal
                WHERE nota-fiscal.cod-estabel   = tt_rpt_tit_acr_antecip_prev_acr.cod_estab 
                  AND nota-fiscal.serie         = tt_rpt_tit_acr_antecip_prev_acr.cod_ser_docto
                  AND nota-fiscal.nr-nota-fis   = tt_rpt_tit_acr_antecip_prev_acr.cod_tit_acr       NO-LOCK:

                FIND FIRST cst-nota-fiscal NO-LOCK
                     WHERE cst-nota-fiscal.cod-estabel = nota-fiscal.cod-estabel
                       AND cst-nota-fiscal.serie       = nota-fiscal.serie      
                       AND cst-nota-fiscal.nr-nota-fis = nota-fiscal.nr-nota-fis NO-ERROR.
                IF AVAIL cst-nota-fiscal THEN DO:
                    ASSIGN v_cod_convenio = cst-nota-fiscal.convenio.

                    FIND FIRST int-ds-convenio NO-LOCK
                         WHERE int-ds-convenio.cod-convenio = INT(cst-nota-fiscal.convenio) NO-ERROR.
                    IF AVAIL int-ds-convenio THEN DO:
                        FIND FIRST cliente
                             WHERE cliente.cod_id_feder = int-ds-convenio.cnpj NO-ERROR.
                        IF AVAIL cliente THEN DO:
                            ASSIGN v_cod_cli_convenio = cliente.cdn_cliente.
                        END.
                    END.
                END.
            END.

        END.

        if  v_ind_dwb_run_mode = "Batch" /*l_batch*/ 
        then do:
            run prgtec/btb/btb908ze.py (Input 1,
                                        Input tt_rpt_tit_acr_antecip_prev_acr.cod_estab              + "/" +                                      string(tt_rpt_tit_acr_antecip_prev_acr.num_id_tit_acr) + "/" +                                      tt_rpt_tit_acr_antecip_prev_acr.tta_cod_unid_negoc) /*prg_api_atualizar_ult_obj*/.
        end /* if */.

        /* ************************ TESTA QUEBRAS FIRST************************************/
        if  first-of(tt_rpt_tit_acr_antecip_prev_acr.ttv_cod_dwb_field_rpt[1])
        then do:
           run pi_testa_quebras_1 (Input 1) /*pi_testa_quebras_1*/.
        end /* if */.
        if  first-of(tt_rpt_tit_acr_antecip_prev_acr.ttv_cod_dwb_field_rpt[2])
        then do:
           run pi_testa_quebras_1 (Input 2) /*pi_testa_quebras_1*/.
        end /* if */.
        if  first-of(tt_rpt_tit_acr_antecip_prev_acr.ttv_cod_dwb_field_rpt[3])
        then do:
           run pi_testa_quebras_1 (Input 3) /*pi_testa_quebras_1*/.
        end /* if */.

        /* ***********************  LINHA PRINCIPAL DO RELAT‡RIO *****************************/
        assign v_cod_cta_ctbl = "" /*l_null*/ .
        if  v_log_lista_cta_ctbl = yes
        then do:
           run pi_lista_cta_ctbl /*pi_lista_cta_ctbl*/.
        end /* if */.

        if  v_log_lista_ped = yes
        then do:
           run pi_lista_ped /*pi_lista_ped*/.
        end /* if */.
        else do:
           assign v_cod_ped_vda = "" /*l_null*/ .
           if v_ind_classif = "Por T°tulo" /*l_por_titulo*/  then do:
              if (line-counter(s_1) + 1) > v_rpt_s_1_bottom then
                  page stream s_1.
              put stream s_1 unformatted 
    &IF "{&emsfin_version}" >= "" AND "{&emsfin_version}" < "5.07A" &THEN
                  tt_rpt_tit_acr_antecip_prev_acr.cod_estab at 1 format "x(3)"
    &ENDIF
    &IF "{&emsfin_version}" >= "5.07A" AND "{&emsfin_version}" < "9.99" &THEN
                  tt_rpt_tit_acr_antecip_prev_acr.cod_estab at 1 format "x(5)"
    &ENDIF
                  tt_rpt_tit_acr_antecip_prev_acr.cod_espec_docto at 7 format "x(3)".
    put stream s_1 unformatted 
                  tt_rpt_tit_acr_antecip_prev_acr.cod_ser_docto at 11 format "x(5)"
                  tt_rpt_tit_acr_antecip_prev_acr.cod_tit_acr at 17 format "x(16)"
                  "/" at 33
                  tt_rpt_tit_acr_antecip_prev_acr.cod_parcela at 34 format "x(02)"
                  tt_rpt_tit_acr_antecip_prev_acr.cdn_cliente to 47 format ">>>,>>>,>>9"
                  tt_rpt_tit_acr_antecip_prev_acr.tta_cod_unid_negoc at 49 format "x(3)"
                  tt_rpt_tit_acr_antecip_prev_acr.cod_portador at 53 format "x(5)"
                  tt_rpt_tit_acr_antecip_prev_acr.cod_cart_bcia at 59 format "x(3)"
                  tt_rpt_tit_acr_antecip_prev_acr.dat_emis_docto at 63 format "99/99/99"
                  tt_rpt_tit_acr_antecip_prev_acr.dat_vencto_tit_acr at 72 format "99/99/99".
    put stream s_1 unformatted 
                  tt_rpt_tit_acr_antecip_prev_acr.cod_indic_econ at 81 format "x(8)"
                  tt_rpt_tit_acr_antecip_prev_acr.val_sdo_tit_acr to 103 format ">>>,>>>,>>9.99"
                  tt_rpt_tit_acr_antecip_prev_acr.ttv_val_origin_tit_acr_apres to 119 format "->>>,>>>,>>9.99"
                  tt_rpt_tit_acr_antecip_prev_acr.ttv_val_sdo_tit_acr_apres to 138 format "->>>,>>>,>>9.99"
                  v_cod_cli_convenio at 140 format ">>>,>>>,>>9"
/*                   v_cod_ped_vda at 161 format "x(12)" */
                  v_cod_convenio at 161 format "x(12)" 
                  skip.
           end.   
           else do:
              if (line-counter(s_1) + 1) > v_rpt_s_1_bottom then
                  page stream s_1.
              put stream s_1 unformatted 
    &IF "{&emsfin_version}" >= "" AND "{&emsfin_version}" < "5.07A" &THEN
                  tt_rpt_tit_acr_antecip_prev_acr.cod_estab at 1 format "x(3)"
    &ENDIF
    &IF "{&emsfin_version}" >= "5.07A" AND "{&emsfin_version}" < "9.99" &THEN
                  tt_rpt_tit_acr_antecip_prev_acr.cod_estab at 1 format "x(5)"
    &ENDIF
                  tt_rpt_tit_acr_antecip_prev_acr.cod_espec_docto at 7 format "x(3)".
    put stream s_1 unformatted 
                  tt_rpt_tit_acr_antecip_prev_acr.cod_ser_docto at 11 format "x(5)"
                  tt_rpt_tit_acr_antecip_prev_acr.cod_tit_acr at 17 format "x(16)"
                  "/" at 33
                  tt_rpt_tit_acr_antecip_prev_acr.cod_parcela at 34 format "x(02)"
                  tt_rpt_tit_acr_antecip_prev_acr.tta_cod_unid_negoc at 37 format "x(3)"
                  tt_rpt_tit_acr_antecip_prev_acr.cod_portador at 41 format "x(5)"
                  tt_rpt_tit_acr_antecip_prev_acr.cod_cart_bcia at 47 format "x(3)"
                  tt_rpt_tit_acr_antecip_prev_acr.dat_emis_docto at 51 format "99/99/99"
                  tt_rpt_tit_acr_antecip_prev_acr.dat_vencto_tit_acr at 60 format "99/99/99"
                  tt_rpt_tit_acr_antecip_prev_acr.cod_indic_econ at 69 format "x(8)".
    put stream s_1 unformatted 
                  tt_rpt_tit_acr_antecip_prev_acr.val_sdo_tit_acr to 91 format ">>>,>>>,>>9.99"
                  tt_rpt_tit_acr_antecip_prev_acr.ttv_val_origin_tit_acr_apres to 108 format "->>>,>>>,>>9.99"
                  tt_rpt_tit_acr_antecip_prev_acr.ttv_val_sdo_tit_acr_apres to 128 format "->>>,>>>,>>9.99"
                  v_cod_cli_convenio at 130 format ">>>,>>>,>>9"
/*                   v_cod_ped_vda at 151 format "x(12)" */
                  v_cod_convenio at 151 format "x(12)" 
                  skip.
           end.   
        end /* else */.

        /* ******************************* ACUMULA TOTAIS ***********************************/
        assign v_val_tot_geral_acr     = v_val_tot_geral_acr     +
                                         tt_rpt_tit_acr_antecip_prev_acr.ttv_val_origin_tit_acr_apres
               v_val_tot_geral_acr_sdo = v_val_tot_geral_acr_sdo +
                                         tt_rpt_tit_acr_antecip_prev_acr.ttv_val_sdo_tit_acr_apres

               v_val_tot_cr_clien      = v_val_tot_cr_clien      +
                                         tt_rpt_tit_acr_antecip_prev_acr.ttv_val_origin_tit_acr_apres
               v_val_tot_cr_clien_sdo  = v_val_tot_cr_clien_sdo  +
                                         tt_rpt_tit_acr_antecip_prev_acr.ttv_val_sdo_tit_acr_apres

               v_val_tot_repres        = v_val_tot_repres        +
                                         tt_rpt_tit_acr_antecip_prev_acr.ttv_val_origin_tit_acr_apres
               v_val_tot_repres_sdo    = v_val_tot_repres_sdo    +
                                         tt_rpt_tit_acr_antecip_prev_acr.ttv_val_sdo_tit_acr_apres.
        if  v_log_tot_por_espec = yes
        then do:
           assign v_val_tot_espec         = v_val_tot_espec         +
                                            tt_rpt_tit_acr_antecip_prev_acr.ttv_val_origin_tit_acr_apres
                  v_val_tot_espec_sdo     = v_val_tot_espec_sdo     +
                                            tt_rpt_tit_acr_antecip_prev_acr.ttv_val_sdo_tit_acr_apres.
        end /* if */.
        /* ************************ TESTA QUEBRAS ****************************************/
        if  last-of(tt_rpt_tit_acr_antecip_prev_acr.ttv_cod_dwb_field_rpt[3])
        then do:
           run pi_testa_quebras (Input 3) /*pi_testa_quebras*/.
        end /* if */.
        if  last-of(tt_rpt_tit_acr_antecip_prev_acr.ttv_cod_dwb_field_rpt[2])
        then do:
           run pi_testa_quebras (Input 2) /*pi_testa_quebras*/.
        end /* if */.
        if  last-of(tt_rpt_tit_acr_antecip_prev_acr.ttv_cod_dwb_field_rpt[1])
        then do:
           run pi_testa_quebras (Input 1) /*pi_testa_quebras*/.
        end /* if */.

        /* *******************************************************************************/
        if  v_log_lista_abat_pend
        then do:
           if  v_log_prev = yes
           then do:

              /* Begin_Include: i_abatimentos_pendentes */
              assign v_log_primei_abat = yes.
              pendencias:
              for
                 each abat_prev_acr no-lock
                 where abat_prev_acr.cod_estab       = tt_rpt_tit_acr_antecip_prev_acr.cod_estab
                   and abat_prev_acr.cod_espec_docto = tt_rpt_tit_acr_antecip_prev_acr.cod_espec_docto
                   and abat_prev_acr.cod_ser_docto   = tt_rpt_tit_acr_antecip_prev_acr.cod_ser_docto
                   and abat_prev_acr.cod_tit_acr     = tt_rpt_tit_acr_antecip_prev_acr.cod_tit_acr
                   and abat_prev_acr.cod_parcela     = tt_rpt_tit_acr_antecip_prev_acr.cod_parcela
                 use-index abtprvcr_titacr:
                 if  v_log_prev = yes
                 then do:
                    assign v_val_abat = abat_prev_acr.val_abtdo_prev_orig.
                 end /* if */.
                 else do:
                    assign v_val_abat = abat_antecip_acr.val_abtdo_antecip_orig.
                 end /* else */.
                 assign v_cod_estab = abat_prev_acr.cod_estab_refer
                        v_cod_refer = abat_prev_acr.cod_refer
                        v_num_seq   = abat_prev_acr.num_seq_refer.
                 if  v_log_primei_abat = yes
                 then do:
                    if  line-counter(s_1) + 1 > v_rpt_s_1_bottom
                    then do:
                        page stream s_1.
                    end /* if */.
                    put stream s_1 unformatted
                        "Pendàncias:" /*l_pendencias*/  at 117 format "x(10)" /*l_x(10)*/ .
                    if (line-counter(s_1) + 3) > v_rpt_s_1_bottom then
                        page stream s_1.
                    put stream s_1 unformatted 
              &IF "{&emsfin_version}" >= "" AND "{&emsfin_version}" < "5.07A" &THEN
                        "Est" at 130
              &ENDIF
              &IF "{&emsfin_version}" >= "5.07A" AND "{&emsfin_version}" < "9.99" &THEN
                        "Est" at 130
              &ENDIF
                        "Referància" at 136
                        "Seq" to 153
                        "Valor Abatimento" to 170 skip
              &IF "{&emsfin_version}" >= "" AND "{&emsfin_version}" < "5.07A" &THEN
                        "---" at 130
              &ENDIF
              &IF "{&emsfin_version}" >= "5.07A" AND "{&emsfin_version}" < "9.99" &THEN
                        "-----" at 130
              &ENDIF
                        "----------" at 136
                        "-------" to 153
                        "----------------" to 170 skip.
                    assign v_log_primei_abat = no.
                 end /* if */.
                 if (line-counter(s_1) + 1) > v_rpt_s_1_bottom then
                     page stream s_1.
                 put stream s_1 unformatted 
              &IF "{&emsfin_version}" >= "" AND "{&emsfin_version}" < "5.07A" &THEN
                     v_cod_estab at 130 format "x(3)"
              &ENDIF
              &IF "{&emsfin_version}" >= "5.07A" AND "{&emsfin_version}" < "9.99" &THEN
                     v_cod_estab at 130 format "x(5)"
              &ENDIF
                     v_cod_refer at 136 format "x(10)".
              put stream s_1 unformatted 
                     v_num_seq to 153 format ">>>,>>9"
                     v_val_abat to 170 format "->>>,>>>,>>9.99" skip.
              end /* for pendencias */.

              /* End_Include: i_abatimentos_pendentes */

           end /* if */.
           else do:

              /* Begin_Include: i_abatimentos_pendentes */
              assign v_log_primei_abat = yes.
              pendencias:
              for
                 each abat_antecip_acr no-lock
                 where abat_antecip_acr.cod_estab       = tt_rpt_tit_acr_antecip_prev_acr.cod_estab
                   and abat_antecip_acr.cod_espec_docto = tt_rpt_tit_acr_antecip_prev_acr.cod_espec_docto
                   and abat_antecip_acr.cod_ser_docto   = tt_rpt_tit_acr_antecip_prev_acr.cod_ser_docto
                   and abat_antecip_acr.cod_tit_acr     = tt_rpt_tit_acr_antecip_prev_acr.cod_tit_acr
                   and abat_antecip_acr.cod_parcela     = tt_rpt_tit_acr_antecip_prev_acr.cod_parcela
                 use-index abtntcpc_tit_acr:
                 if  v_log_prev = yes
                 then do:
                    assign v_val_abat = abat_prev_acr.val_abtdo_prev_orig.
                 end /* if */.
                 else do:
                    assign v_val_abat = abat_antecip_acr.val_abtdo_antecip_orig.
                 end /* else */.
                 assign v_cod_estab = abat_antecip_acr.cod_estab_refer
                        v_cod_refer = abat_antecip_acr.cod_refer
                        v_num_seq   = abat_antecip_acr.num_seq_refer.
                 if  v_log_primei_abat = yes
                 then do:
                    if  line-counter(s_1) + 1 > v_rpt_s_1_bottom
                    then do:
                        page stream s_1.
                    end /* if */.
                    put stream s_1 unformatted
                        "Pendàncias:" /*l_pendencias*/  at 117 format "x(10)" /*l_x(10)*/ .
                    if (line-counter(s_1) + 3) > v_rpt_s_1_bottom then
                        page stream s_1.
                    put stream s_1 unformatted 
              &IF "{&emsfin_version}" >= "" AND "{&emsfin_version}" < "5.07A" &THEN
                        "Est" at 130
              &ENDIF
              &IF "{&emsfin_version}" >= "5.07A" AND "{&emsfin_version}" < "9.99" &THEN
                        "Est" at 130
              &ENDIF
                        "Referància" at 136
                        "Seq" to 153
                        "Valor Abatimento" to 170 skip
              &IF "{&emsfin_version}" >= "" AND "{&emsfin_version}" < "5.07A" &THEN
                        "---" at 130
              &ENDIF
              &IF "{&emsfin_version}" >= "5.07A" AND "{&emsfin_version}" < "9.99" &THEN
                        "-----" at 130
              &ENDIF
                        "----------" at 136
                        "-------" to 153
                        "----------------" to 170 skip.
                    assign v_log_primei_abat = no.
                 end /* if */.
                 if (line-counter(s_1) + 1) > v_rpt_s_1_bottom then
                     page stream s_1.
                 put stream s_1 unformatted 
              &IF "{&emsfin_version}" >= "" AND "{&emsfin_version}" < "5.07A" &THEN
                     v_cod_estab at 130 format "x(3)"
              &ENDIF
              &IF "{&emsfin_version}" >= "5.07A" AND "{&emsfin_version}" < "9.99" &THEN
                     v_cod_estab at 130 format "x(5)"
              &ENDIF
                     v_cod_refer at 136 format "x(10)".
              put stream s_1 unformatted 
                     v_num_seq to 153 format ">>>,>>9"
                     v_val_abat to 170 format "->>>,>>>,>>9.99" skip.
              end /* for pendencias */.

              /* End_Include: i_abatimentos_pendentes */

           end /* else */.
        end /* if */.

        delete tt_rpt_tit_acr_antecip_prev_acr.
    end /* for grp_block */.
    if v_ind_classif = "Por T°tulo" /*l_por_titulo*/  then do:
       if (line-counter(s_1) + 1) > v_rpt_s_1_bottom then
           page stream s_1.
       put stream s_1 unformatted 
           "Total Geral:" at 88
           v_val_tot_geral_acr to 118 format "->>>,>>>,>>>,>>9.99"
           v_val_tot_geral_acr_sdo to 138 format "->>>,>>>,>>>,>>9.99" skip.
       hide stream s_1 frame f_rpt_s_1_Grp_cab_complem_Lay_compl_cab2.
       hide stream s_1 frame f_rpt_s_1_Grp_cab_princip_Lay_cab_princip2.
    end.   
    else do:
       if (line-counter(s_1) + 1) > v_rpt_s_1_bottom then
           page stream s_1.
       put stream s_1 unformatted 
           "Total Geral:" at 78
           v_val_tot_geral_acr to 108 format "->>>,>>>,>>>,>>9.99"
           v_val_tot_geral_acr_sdo to 128 format "->>>,>>>,>>>,>>9.99" skip.
       hide stream s_1 frame f_rpt_s_1_Grp_cab_complem_Lay_compl_cab.   
       hide stream s_1 frame f_rpt_s_1_Grp_cab_princip_Lay_cab_princip.
    end.   
    hide stream s_1 frame f_rpt_s_1_footer_normal.
    hide stream s_1 frame f_rpt_s_1_footer_param_page.
    view stream s_1 frame f_rpt_s_1_footer_last_page.
END PROCEDURE. /* pi_rpt_tit_acr_antecip_prev_acr */
/*****************************************************************************
** Procedure Interna.....: pi_carrega_tt_rpt_tit_acr_antecip_prev_acr
** Descricao.............: pi_carrega_tt_rpt_tit_acr_antecip_prev_acr
** Criado por............: Amarildo
** Criado em.............: 25/02/1997 08:58:06
** Alterado por..........: fut42625_3
** Alterado em...........: 15/02/2011 16:38:02
*****************************************************************************/
PROCEDURE pi_carrega_tt_rpt_tit_acr_antecip_prev_acr:

    /************************* Variable Definition Begin ************************/

    def var v_num_cont_aux
        as integer
        format ">9":U
        no-undo.


    /************************** Variable Definition End *************************/

    if  v_log_prev = yes
    then do:
       assign v_ind_tip_espec_docto = "Previs∆o" /*l_previsao*/ .
    end /* if */.
    else do:
       assign v_ind_tip_espec_docto = "Antecipaá∆o" /*l_antecipacao*/ .
    end /* else */.

    estab_block:
    do v_num_cont_aux = 1 to num-entries(v_des_estab_select):
        find first estabelecimento no-lock
             where estabelecimento.cod_estab = entry(v_num_cont_aux, v_des_estab_select) no-error.
        if not avail estabelecimento then
            next estab_block.

       espec_block:
       for
          each espec_docto no-lock
          where espec_docto.cod_espec_docto    >= v_cod_espec_docto_ini
            and espec_docto.cod_espec_docto    <= v_cod_espec_docto_fim
            and espec_docto.ind_tip_espec_docto = v_ind_tip_espec_docto:

          tit_block:
          for
             each tit_acr no-lock
             where tit_acr.cod_estab           = estabelecimento.cod_estab
               and tit_acr.cod_espec_docto     = espec_docto.cod_espec_docto
               and tit_acr.dat_emis_docto     >= v_dat_emis_docto_ini
               and tit_acr.dat_emis_docto     <= v_dat_emis_docto_fim
               and tit_acr.cdn_cliente        >= v_cdn_cliente_ini
               and tit_acr.cdn_cliente        <= v_cdn_cliente_fim
               and tit_acr.cod_portador       >= v_cod_portador_ini
               and tit_acr.cod_portador       <= v_cod_portador_fim
               and tit_acr.dat_vencto_tit_acr >= v_dat_vencto_tit_acr_ini
               and tit_acr.dat_vencto_tit_acr <= v_dat_vencto_tit_acr_fim
               and tit_acr.cod_indic_econ     >= v_cod_indic_econ_ini
               and tit_acr.cod_indic_econ     <= v_cod_indic_econ_fim
               and tit_acr.log_tit_acr_estordo = no:

               /* ** S‡ LISTA AN/PREV TOTALMENTE ABATIDAS ***/
               if  tit_acr.val_sdo_tit_acr = 0 and
                  v_log_sdo_zero = no
               then do:
                  next tit_block.
               end /* if */.

               /* RETORNA A FINALIDADE ORIGINAL DO T÷TULO */
               run pi_retornar_finalid_indic_econ (Input tit_acr.cod_indic_econ,
                                                   Input tit_acr.dat_transacao,
                                                   output v_cod_finalid_econ_aux) /*pi_retornar_finalid_indic_econ*/.

               if  v_ind_visualiz_tit_acr_vert = "Por Unidade Neg¢cio" /*l_por_unid_negoc*/ 
               then do:
                  /* VALORES DO T÷TULO NA FINALIDADE INFORMADA */
                  val_block:
                  for
                     each val_tit_acr no-lock
                     where val_tit_acr.cod_estab         = tit_acr.cod_estab
                       and val_tit_acr.num_id_tit_acr    = tit_acr.num_id_tit_acr
                       and val_tit_acr.cod_finalid_econ  = v_cod_finalid_econ
                       and val_tit_acr.cod_unid_negoc   >= v_cod_unid_negoc_ini
                       and val_tit_acr.cod_unid_negoc   <= v_cod_unid_negoc_fim
                       break
                       by val_tit_acr.cod_unid_negoc:

                       assign v_val_origin_tit_acr = v_val_origin_tit_acr + val_tit_acr.val_origin_tit_acr.

                       if  last-of (val_tit_acr.cod_unid_negoc)
                       then do:
                          create tt_rpt_tit_acr_antecip_prev_acr.
                          assign tt_rpt_tit_acr_antecip_prev_acr.cod_estab                    = tit_acr.cod_estab
                                 tt_rpt_tit_acr_antecip_prev_acr.num_id_tit_acr               = tit_acr.num_id_tit_acr
                                 tt_rpt_tit_acr_antecip_prev_acr.cod_espec_docto              = tit_acr.cod_espec_docto
                                 tt_rpt_tit_acr_antecip_prev_acr.cod_ser_docto                = tit_acr.cod_ser_docto
                                 tt_rpt_tit_acr_antecip_prev_acr.cod_tit_acr                  = tit_acr.cod_tit_acr
                                 tt_rpt_tit_acr_antecip_prev_acr.cod_parcela                  = tit_acr.cod_parcela
                                 tt_rpt_tit_acr_antecip_prev_acr.tta_cod_unid_negoc           = val_tit_acr.cod_unid_negoc
                                 tt_rpt_tit_acr_antecip_prev_acr.cdn_cliente                  = tit_acr.cdn_cliente
                                 tt_rpt_tit_acr_antecip_prev_acr.cod_portador                 = tit_acr.cod_portador
                                 tt_rpt_tit_acr_antecip_prev_acr.cod_cart_bcia                = tit_acr.cod_cart_bcia
                                 tt_rpt_tit_acr_antecip_prev_acr.dat_emis_docto               = tit_acr.dat_emis_docto
                                 tt_rpt_tit_acr_antecip_prev_acr.dat_vencto_tit_acr           = tit_acr.dat_vencto_tit_acr
                                 tt_rpt_tit_acr_antecip_prev_acr.cod_indic_econ               = tit_acr.cod_indic_econ
                                 tt_rpt_tit_acr_antecip_prev_acr.ttv_val_origin_tit_acr_apres = v_val_origin_tit_acr / v_val_cotac_indic_econ
                                 tt_rpt_tit_acr_antecip_prev_acr.ttv_val_sdo_tit_acr_apres    = v_val_sdo_tit_acr / v_val_cotac_indic_econ
                                 tt_rpt_tit_acr_antecip_prev_acr.ttv_rec_tit_acr              = recid (tit_acr)
                                 tt_rpt_tit_acr_antecip_prev_acr.cdn_repres                   = tit_acr.cdn_repres 
                                 v_val_origin_tit_acr                                         = 0
                                 v_val_sdo_tit_acr                                            = 0.
                          run pi_classifica_tit_acr_antecip_prev /*pi_classifica_tit_acr_antecip_prev*/.
                       end /* if */.
                  end /* for val_block */.

                  /* VALORES DO T÷TULO NA FINALIDADE ORIGINAL */
                  val_block:
                  for
                     each val_tit_acr no-lock
                     where val_tit_acr.cod_estab         = tit_acr.cod_estab
                       and val_tit_acr.num_id_tit_acr    = tit_acr.num_id_tit_acr
                       and val_tit_acr.cod_finalid_econ  = v_cod_finalid_econ_aux
                       and val_tit_acr.cod_unid_negoc   >= v_cod_unid_negoc_ini
                       and val_tit_acr.cod_unid_negoc   <= v_cod_unid_negoc_fim
                       break
                       by val_tit_acr.cod_unid_negoc:

                       assign v_val_origin_tit_acr = v_val_origin_tit_acr + val_tit_acr.val_origin_tit_acr
                              v_val_sdo_tit_acr    = v_val_sdo_tit_acr    + val_tit_acr.val_sdo_tit_acr.

                       if  last-of (val_tit_acr.cod_unid_negoc)
                       then do:
                          find first tt_rpt_tit_acr_antecip_prev_acr exclusive-lock
                             where tt_rpt_tit_acr_antecip_prev_acr.cod_estab      = tit_acr.cod_estab
                               and tt_rpt_tit_acr_antecip_prev_acr.num_id_tit_acr = tit_acr.num_id_tit_acr
                               and tt_rpt_tit_acr_antecip_prev_acr.tta_cod_unid_negoc     = val_tit_acr.cod_unid_negoc
                               no-error.

                          assign tt_rpt_tit_acr_antecip_prev_acr.val_origin_tit_acr = v_val_origin_tit_acr
                                 tt_rpt_tit_acr_antecip_prev_acr.val_sdo_tit_acr    = v_val_sdo_tit_acr
                                 v_val_sdo_tit_acr                                      = 0
                                 v_val_origin_tit_acr                                   = 0.
                       end /* if */.
                  end /* for val_block */.
               end /* if */.
               else do:
                  create tt_rpt_tit_acr_antecip_prev_acr.
                  assign tt_rpt_tit_acr_antecip_prev_acr.cod_estab                    = tit_acr.cod_estab
                         tt_rpt_tit_acr_antecip_prev_acr.num_id_tit_acr               = tit_acr.num_id_tit_acr
                         tt_rpt_tit_acr_antecip_prev_acr.cod_espec_docto              = tit_acr.cod_espec_docto
                         tt_rpt_tit_acr_antecip_prev_acr.cod_ser_docto                = tit_acr.cod_ser_docto
                         tt_rpt_tit_acr_antecip_prev_acr.cod_tit_acr                  = tit_acr.cod_tit_acr
                         tt_rpt_tit_acr_antecip_prev_acr.cod_parcela                  = tit_acr.cod_parcela
                         tt_rpt_tit_acr_antecip_prev_acr.tta_cod_unid_negoc           = "" /*l_null*/ 
                         tt_rpt_tit_acr_antecip_prev_acr.cdn_cliente                  = tit_acr.cdn_cliente
                         tt_rpt_tit_acr_antecip_prev_acr.cod_portador                 = tit_acr.cod_portador
                         tt_rpt_tit_acr_antecip_prev_acr.cod_cart_bcia                = tit_acr.cod_cart_bcia
                         tt_rpt_tit_acr_antecip_prev_acr.dat_emis_docto               = tit_acr.dat_emis_docto
                         tt_rpt_tit_acr_antecip_prev_acr.dat_vencto_tit_acr           = tit_acr.dat_vencto_tit_acr
                         tt_rpt_tit_acr_antecip_prev_acr.cod_indic_econ               = tit_acr.cod_indic_econ
                         tt_rpt_tit_acr_antecip_prev_acr.val_sdo_tit_acr              = tit_acr.val_sdo_tit_acr
                         tt_rpt_tit_acr_antecip_prev_acr.ttv_val_origin_tit_acr_apres = 0
                         tt_rpt_tit_acr_antecip_prev_acr.ttv_val_sdo_tit_acr_apres    = 0
                         tt_rpt_tit_acr_antecip_prev_acr.ttv_rec_tit_acr              = recid (tit_acr)
                         tt_rpt_tit_acr_antecip_prev_acr.cdn_repres                   = tit_acr.cdn_repres.
                  val_block:
                  for
                     each  val_tit_acr no-lock
                     where val_tit_acr.cod_estab        = tit_acr.cod_estab
                       and val_tit_acr.num_id_tit_acr   = tit_acr.num_id_tit_acr
                       and val_tit_acr.cod_finalid_econ = v_cod_finalid_econ:

                       assign tt_rpt_tit_acr_antecip_prev_acr.ttv_val_origin_tit_acr_apres =
                              tt_rpt_tit_acr_antecip_prev_acr.ttv_val_origin_tit_acr_apres +
                              ( val_tit_acr.val_origin_tit_acr / v_val_cotac_indic_econ )

                              tt_rpt_tit_acr_antecip_prev_acr.ttv_val_sdo_tit_acr_apres =
                              tt_rpt_tit_acr_antecip_prev_acr.ttv_val_sdo_tit_acr_apres +
                              ( val_tit_acr.val_sdo_tit_acr / v_val_cotac_indic_econ ).
                  end /* for val_block */.
               end /* else */.
               run pi_classifica_tit_acr_antecip_prev /*pi_classifica_tit_acr_antecip_prev*/.
          end /* for tit_block */.
       end /* for espec_block */.
    end /* for estab_block */.
END PROCEDURE. /* pi_carrega_tt_rpt_tit_acr_antecip_prev_acr */
/*****************************************************************************
** Procedure Interna.....: pi_vld_valores_apres_apb_acr
** Descricao.............: pi_vld_valores_apres_apb_acr
** Criado por............: Uno
** Criado em.............: 19/07/1996 15:44:37
** Alterado por..........: fut41061
** Alterado em...........: 09/04/2013 14:46:55
*****************************************************************************/
PROCEDURE pi_vld_valores_apres_apb_acr:

    /************************ Parameter Definition Begin ************************/

    def Input param p_cod_finalid_econ
        as character
        format "x(10)"
        no-undo.
    def Input param p_cod_finalid_econ_apres
        as character
        format "x(10)"
        no-undo.
    def Input param p_dat_conver
        as date
        format "99/99/9999"
        no-undo.
    def output param p_dat_cotac_indic_econ
        as date
        format "99/99/9999"
        no-undo.
    def output param p_val_cotac_indic_econ
        as decimal
        format ">>>>,>>9.9999999999"
        decimals 10
        no-undo.


    /************************* Parameter Definition End *************************/

    /************************* Variable Definition Begin ************************/

    def var v_cod_indic_econ_base
        as character
        format "x(8)":U
        label "Moeda Base"
        column-label "Moeda Base"
        no-undo.
    def var v_cod_indic_econ_idx
        as character
        format "x(8)":U
        label "Moeda ÷ndice"
        column-label "Moeda ÷ndice"
        no-undo.
    def var v_cod_return
        as character
        format "x(40)":U
        no-undo.


    /************************** Variable Definition End *************************/

    find first finalid_econ no-lock
         where finalid_econ.cod_finalid_econ = p_cod_finalid_econ
         no-error.
    if  not avail finalid_econ
    then do:
        /* Finalidade Econìmica inexistente ! */
        run pi_messages (input "show",
                         input 1652,
                         input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")) /*msg_1652*/.
        return error.
    end /* if */.

    if  finalid_econ.ind_armaz_val <> "M¢dulos" /*l_modulos*/ 
    then do:
        /* Finalidade Econìmica n∆o armazena valores no M¢dulo ! */
        run pi_messages (input "show",
                         input 1389,
                         input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9",
                                            p_cod_finalid_econ)) /*msg_1389*/.
        return error.
    end /* if */.

    find first finalid_unid_organ no-lock
         where finalid_unid_organ.cod_unid_organ   = v_cod_empres_usuar
         and   finalid_unid_organ.cod_finalid_econ = p_cod_finalid_econ
         no-error.
    if  not avail finalid_unid_organ
    then do:
        /* Finalidade n∆o liberada para Empresa do Usu†rio ! */
        run pi_messages (input "show",
                         input 2655,
                         input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")) /*msg_2655*/.
        return error.
    end /* if */.



    run pi_retornar_indic_econ_finalid (Input p_cod_finalid_econ,
                                        Input p_dat_conver,
                                        output v_cod_indic_econ_base) /*pi_retornar_indic_econ_finalid*/.
    if  v_cod_indic_econ_base = ? or v_cod_indic_econ_base = " "
    then do:
        /* Hist¢rico da Finalidade Inexistente para Data Convers∆o ! */
        run pi_messages (input "show",
                         input 2452,
                         input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")) /*msg_2452*/.
        return error.
    end /* if */.

    find first b_finalid_econ no-lock
         where b_finalid_econ.cod_finalid_econ = p_cod_finalid_econ_apres
         no-error.
    if  not avail b_finalid_econ
    then do:
        /* Finalidade Econìmica de Apresentaá∆o Inexistente ! */
        run pi_messages (input "show",
                         input 2450,
                         input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")) /*msg_2450*/.
        return error.
    end /* if */.

    find first b_finalid_unid_organ no-lock
         where b_finalid_unid_organ.cod_unid_organ   = v_cod_empres_usuar
         and   b_finalid_unid_organ.cod_finalid_econ = p_cod_finalid_econ_apres
         no-error.
    if  not avail b_finalid_unid_organ
    then do:
        /* Finalidade Apresentaá∆o n∆o liberada p/ Empresa do Usu†rio ! */
        run pi_messages (input "show",
                         input 2656,
                         input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")) /*msg_2656*/.
        return error.
    end /* if */.

    run pi_retornar_indic_econ_finalid (Input p_cod_finalid_econ_apres,
                                        Input p_dat_conver,
                                        output v_cod_indic_econ_idx) /*pi_retornar_indic_econ_finalid*/.
    if  v_cod_indic_econ_idx = ? or v_cod_indic_econ_idx = " "
    then do:
        /* Hist¢rico Finalid. Apresent. Inexistente p/ Data Convers∆o ! */
        run pi_messages (input "show",
                         input 2453,
                         input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")) /*msg_2453*/.
        return error.
    end /* if */.

    run pi_achar_cotac_indic_econ (Input v_cod_indic_econ_base,
                                   Input v_cod_indic_econ_idx,
                                   Input p_dat_conver,
                                   Input "Real" /*l_real*/,
                                   output p_dat_cotac_indic_econ,
                                   output p_val_cotac_indic_econ,
                                   output v_cod_return) /*pi_achar_cotac_indic_econ*/.
    if  v_cod_return <> "OK" /*l_ok*/ 
    then do:
        /* Cotaá∆o entre Indicadores Econìmicos n∆o encontrada ! */
        run pi_messages (input "show",
                         input 358,
                         input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9",
                                            entry(2,v_cod_return), entry(3,v_cod_return), entry(4,v_cod_return), entry(5,v_cod_return))) /*msg_358*/.
        return error.
    end /* if */.
END PROCEDURE. /* pi_vld_valores_apres_apb_acr */
/*****************************************************************************
** Procedure Interna.....: pi_retornar_indic_econ_finalid
** Descricao.............: pi_retornar_indic_econ_finalid
** Criado por............: vladimir
** Criado em.............: // 
** Alterado por..........: Menna
** Alterado em...........: 06/05/1999 10:21:29
*****************************************************************************/
PROCEDURE pi_retornar_indic_econ_finalid:

    /************************ Parameter Definition Begin ************************/

    def Input param p_cod_finalid_econ
        as character
        format "x(10)"
        no-undo.
    def Input param p_dat_transacao
        as date
        format "99/99/9999"
        no-undo.
    def output param p_cod_indic_econ
        as character
        format "x(8)"
        no-undo.


    /************************* Parameter Definition End *************************/

    find first histor_finalid_econ no-lock
         where histor_finalid_econ.cod_finalid_econ = p_cod_finalid_econ
           and histor_finalid_econ.dat_inic_valid_finalid <= p_dat_transacao
           and histor_finalid_econ.dat_fim_valid_finalid > p_dat_transacao
    &if "{&emsuni_version}" >= "5.01" &then
         use-index hstrfnld_id
    &endif
          /*cl_finalid_ativa of histor_finalid_econ*/ no-error.
    if  avail histor_finalid_econ then
        assign p_cod_indic_econ = histor_finalid_econ.cod_indic_econ.

END PROCEDURE. /* pi_retornar_indic_econ_finalid */
/*****************************************************************************
** Procedure Interna.....: pi_achar_cotac_indic_econ
** Descricao.............: pi_achar_cotac_indic_econ
** Criado por............: vladimir
** Criado em.............: // 
** Alterado por..........: fut1309_4
** Alterado em...........: 08/02/2006 16:12:34
*****************************************************************************/
PROCEDURE pi_achar_cotac_indic_econ:

    /************************ Parameter Definition Begin ************************/

    def Input param p_cod_indic_econ_base
        as character
        format "x(8)"
        no-undo.
    def Input param p_cod_indic_econ_idx
        as character
        format "x(8)"
        no-undo.
    def Input param p_dat_transacao
        as date
        format "99/99/9999"
        no-undo.
    def Input param p_ind_tip_cotac_parid
        as character
        format "X(09)"
        no-undo.
    def output param p_dat_cotac_indic_econ
        as date
        format "99/99/9999"
        no-undo.
    def output param p_val_cotac_indic_econ
        as decimal
        format ">>>>,>>9.9999999999"
        decimals 10
        no-undo.
    def output param p_cod_return
        as character
        format "x(40)"
        no-undo.


    /************************* Parameter Definition End *************************/

    /************************* Variable Definition Begin ************************/

    def var v_dat_cotac_mes
        as date
        format "99/99/9999":U
        no-undo.
    def var v_log_indic
        as logical
        format "Sim/N∆o"
        initial no
        no-undo.
    def var v_cod_indic_econ_orig            as character       no-undo. /*local*/
    def var v_val_cotac_indic_econ_base      as decimal         no-undo. /*local*/
    def var v_val_cotac_indic_econ_idx       as decimal         no-undo. /*local*/


    /************************** Variable Definition End *************************/

    /* alteraá∆o sob demanda da atividade 148.681*/
    release cotac_parid.

    if  p_cod_indic_econ_base = p_cod_indic_econ_idx
    then do:
        /* **
         Quando a Base e o ÷ndice forem iguais, significa que a cotaá∆o pode ser percentual,
         portanto n∆o basta apenas retornar 1 e deve ser feita toda a pesquisa abaixo para
         encontrar a taxa da moeda no dia informado.
         Exemplo: D¢lar - D¢lar, poder°amos retornar 1
                  ANBID - ANBID, devemos retornar a taxa do dia.
        ***/
        find indic_econ no-lock
             where indic_econ.cod_indic_econ  = p_cod_indic_econ_base
               and indic_econ.dat_inic_valid <= p_dat_transacao
               and indic_econ.dat_fim_valid  >  p_dat_transacao
             no-error.
        if  avail indic_econ then do:
            if  indic_econ.ind_tip_cotac = "Valor" /*l_valor*/  then do:
                assign p_dat_cotac_indic_econ = p_dat_transacao
                       p_val_cotac_indic_econ = 1
                       p_cod_return           = "OK" /*l_ok*/ .
            end.
            else do:
                find cotac_parid no-lock
                     where cotac_parid.cod_indic_econ_base = p_cod_indic_econ_base
                       and cotac_parid.cod_indic_econ_idx = p_cod_indic_econ_idx
                       and cotac_parid.dat_cotac_indic_econ = p_dat_transacao
                       and cotac_parid.ind_tip_cotac_parid = p_ind_tip_cotac_parid
    &if "{&emsuni_version}" >= "5.01" &then
                     use-index ctcprd_id
    &endif
                      /*cl_acha_cotac of cotac_parid*/ no-error.
                if  not avail cotac_parid
                then do:
                    find parid_indic_econ no-lock
                         where parid_indic_econ.cod_indic_econ_base = p_cod_indic_econ_base
                           and parid_indic_econ.cod_indic_econ_idx = p_cod_indic_econ_idx
    &if "{&emsuni_version}" >= "5.01" &then
                         use-index prdndccn_id
    &endif
                          /*cl_acha_parid_param of parid_indic_econ*/ no-error.
                    /* block: */
                    case parid_indic_econ.ind_criter_busca:
                        when "Anterior" /*l_anterior*/ then find prev cotac_parid no-lock
                              where cotac_parid.cod_indic_econ_base = p_cod_indic_econ_base
                                and cotac_parid.cod_indic_econ_idx = p_cod_indic_econ_idx
                                and cotac_parid.dat_cotac_indic_econ < p_dat_transacao
                                and cotac_parid.ind_tip_cotac_parid = p_ind_tip_cotac_parid
                                and cotac_parid.val_cotac_indic_econ <> 0.0
    &if "{&emsuni_version}" >= "5.01" &then
                              use-index ctcprd_id
    &endif
                               /*cl_acha_cotac_anterior of cotac_parid*/ no-error.
                        when "Pr¢ximo" /*l_proximo*/ then  find next cotac_parid no-lock
                               where cotac_parid.cod_indic_econ_base = p_cod_indic_econ_base
                                 and cotac_parid.cod_indic_econ_idx = p_cod_indic_econ_idx
                                 and cotac_parid.dat_cotac_indic_econ > p_dat_transacao
                                 and cotac_parid.ind_tip_cotac_parid = p_ind_tip_cotac_parid
                                 and cotac_parid.val_cotac_indic_econ <> 0.0
    &if "{&emsuni_version}" >= "5.01" &then
                               use-index ctcprd_id
    &endif
                                /*cl_acha_cotac_posterior of cotac_parid*/ no-error.
                    end /* case block */.
                    if  not avail cotac_parid
                    then do:
                        assign p_cod_return = "358"                   + "," +
                                              p_cod_indic_econ_base   + "," +
                                              p_cod_indic_econ_idx    + "," +
                                              string(p_dat_transacao) + "," +
                                              p_ind_tip_cotac_parid.
                    end /* if */.
                    else do:
                        assign p_dat_cotac_indic_econ = cotac_parid.dat_cotac_indic_econ
                               p_val_cotac_indic_econ = cotac_parid.val_cotac_indic_econ
                               p_cod_return           = "OK" /*l_ok*/ .
                    end /* else */.
                end /* if */.
                else do:
                    assign p_dat_cotac_indic_econ = cotac_parid.dat_cotac_indic_econ
                           p_val_cotac_indic_econ = cotac_parid.val_cotac_indic_econ
                           p_cod_return           = "OK" /*l_ok*/ .
                end /* else */.
            end.
        end.
        else do:
            assign p_cod_return = "335".
        end.
    end /* if */.
    else do:
        find parid_indic_econ no-lock
             where parid_indic_econ.cod_indic_econ_base = p_cod_indic_econ_base
               and parid_indic_econ.cod_indic_econ_idx = p_cod_indic_econ_idx
             use-index prdndccn_id no-error.
        if  avail parid_indic_econ
        then do:


            /* Begin_Include: i_verifica_cotac_parid */
            /* verifica as cotacoes da moeda p_cod_indic_econ_base para p_cod_indic_econ_idx 
              cadastrada na base, de acordo com a periodicidade da cotacao (obtida na 
              parid_indic_econ, que deve estar avail)*/

            /* period_block: */
            case parid_indic_econ.ind_periodic_cotac:
                when "Di†ria" /*l_diaria*/ then
                    diaria_block:
                    do:
                        find cotac_parid no-lock
                            where cotac_parid.cod_indic_econ_base  = p_cod_indic_econ_base
                              and cotac_parid.cod_indic_econ_idx   = p_cod_indic_econ_idx
                              and cotac_parid.dat_cotac_indic_econ = p_dat_transacao
                              and cotac_parid.ind_tip_cotac_parid  = p_ind_tip_cotac_parid
                            use-index ctcprd_id no-error.
                        if  not avail cotac_parid or cotac_parid.val_cotac_indic_econ = 0
                        then do:
                            find parid_indic_econ no-lock
                                where parid_indic_econ.cod_indic_econ_base = p_cod_indic_econ_base
                                  and parid_indic_econ.cod_indic_econ_idx  = p_cod_indic_econ_idx
                                use-index prdndccn_id no-error.
                            /* block: */
                            case parid_indic_econ.ind_criter_busca:
                                when "Anterior" /*l_anterior*/ then 
                                    find prev cotac_parid no-lock
                                        where cotac_parid.cod_indic_econ_base  = p_cod_indic_econ_base
                                          and cotac_parid.cod_indic_econ_idx   = p_cod_indic_econ_idx
                                          and cotac_parid.dat_cotac_indic_econ < p_dat_transacao
                                          and cotac_parid.ind_tip_cotac_parid  = p_ind_tip_cotac_parid
                                          and cotac_parid.val_cotac_indic_econ <> 0.0
                                          &if '{&emsuni_version}' >= '5.01' &then
                                          use-index ctcprd_id
                                          &endif
                                          no-error.
                                when "Pr¢ximo" /*l_proximo*/ then  
                                    find next cotac_parid no-lock
                                        where cotac_parid.cod_indic_econ_base  = p_cod_indic_econ_base
                                          and cotac_parid.cod_indic_econ_idx   = p_cod_indic_econ_idx
                                          and cotac_parid.dat_cotac_indic_econ > p_dat_transacao
                                          and cotac_parid.ind_tip_cotac_parid  = p_ind_tip_cotac_parid
                                          and cotac_parid.val_cotac_indic_econ <> 0.0
                                          &if '{&emsuni_version}' >= '5.01' &then
                                          use-index ctcprd_id
                                          &endif
                                          no-error.
                            end /* case block */.
                        end /* if */.
                    end /* do diaria_block */.
                when "Mensal" /*l_mensal*/ then
                    mensal_block:
                    do:
                        assign v_dat_cotac_mes = date(month(p_dat_transacao), 1, year(p_dat_transacao))
                               &if yes = yes &then 
                               v_log_indic     = yes
                               &endif .
                        find cotac_parid no-lock
                            where cotac_parid.cod_indic_econ_base  = p_cod_indic_econ_base
                              and cotac_parid.cod_indic_econ_idx   = p_cod_indic_econ_idx
                              and cotac_parid.dat_cotac_indic_econ = v_dat_cotac_mes
                              and cotac_parid.ind_tip_cotac_parid  = p_ind_tip_cotac_parid
                            use-index ctcprd_id no-error.
                        if  not avail cotac_parid or cotac_parid.val_cotac_indic_econ = 0
                        then do:
                            /* block: */
                            case parid_indic_econ.ind_criter_busca:
                                when "Anterior" /*l_anterior*/ then
                                    find prev cotac_parid no-lock
                                        where cotac_parid.cod_indic_econ_base  = p_cod_indic_econ_base
                                          and cotac_parid.cod_indic_econ_idx   = p_cod_indic_econ_idx
                                          and cotac_parid.dat_cotac_indic_econ < v_dat_cotac_mes
                                          and cotac_parid.ind_tip_cotac_parid  = p_ind_tip_cotac_parid
                                          and cotac_parid.val_cotac_indic_econ <> 0.0
                                        use-index ctcprd_id no-error.
                                when "Pr¢ximo" /*l_proximo*/ then
                                    find next cotac_parid no-lock
                                        where cotac_parid.cod_indic_econ_base  = p_cod_indic_econ_base
                                          and cotac_parid.cod_indic_econ_idx   = p_cod_indic_econ_idx
                                          and cotac_parid.dat_cotac_indic_econ > v_dat_cotac_mes
                                          and cotac_parid.ind_tip_cotac_parid  = p_ind_tip_cotac_parid
                                          and cotac_parid.val_cotac_indic_econ <> 0.0
                                        use-index ctcprd_id no-error.
                            end /* case block */.
                        end /* if */.
                    end /* do mensal_block */.
                when "Bimestral" /*l_bimestral*/ then
                    bimestral_block:
                    do:
                    end /* do bimestral_block */.
                when "Trimestral" /*l_trimestral*/ then
                    trimestral_block:
                    do:
                    end /* do trimestral_block */.
                when "Quadrimestral" /*l_quadrimestral*/ then
                    quadrimestral_block:
                    do:
                    end /* do quadrimestral_block */.
                when "Semestral" /*l_semestral*/ then
                    semestral_block:
                    do:
                    end /* do semestral_block */.
                when "Anual" /*l_anual*/ then
                    anual_block:
                    do:
                    end /* do anual_block */.
            end /* case period_block */.
            /* End_Include: i_verifica_cotac_parid */


            if  parid_indic_econ.ind_orig_cotac_parid = "Outra Moeda" /*l_outra_moeda*/  and
                 parid_indic_econ.cod_finalid_econ_orig_cotac <> "" and
                 (not avail cotac_parid or cotac_parid.val_cotac_indic_econ = 0)
            then do:
                /* Cotaá∆o Ponte */
                run pi_retornar_indic_econ_finalid (Input parid_indic_econ.cod_finalid_econ_orig_cotac,
                                                    Input p_dat_transacao,
                                                    output v_cod_indic_econ_orig) /*pi_retornar_indic_econ_finalid*/.
                find parid_indic_econ no-lock
                    where parid_indic_econ.cod_indic_econ_base = v_cod_indic_econ_orig
                    and parid_indic_econ.cod_indic_econ_idx = p_cod_indic_econ_base
                    use-index prdndccn_id no-error.
                run pi_achar_cotac_indic_econ_2 (Input v_cod_indic_econ_orig,
                                                 Input p_cod_indic_econ_base,
                                                 Input p_dat_transacao,
                                                 Input p_ind_tip_cotac_parid,
                                                 Input p_cod_indic_econ_base,
                                                 Input p_cod_indic_econ_idx) /*pi_achar_cotac_indic_econ_2*/.

                if  avail cotac_parid and cotac_parid.val_cotac_indic_econ <> 0
                then do:
                    assign v_val_cotac_indic_econ_base = cotac_parid.val_cotac_indic_econ.
                    find parid_indic_econ no-lock
                        where parid_indic_econ.cod_indic_econ_base = v_cod_indic_econ_orig
                        and parid_indic_econ.cod_indic_econ_idx = p_cod_indic_econ_idx
                        use-index prdndccn_id no-error.
                    run pi_achar_cotac_indic_econ_2 (Input v_cod_indic_econ_orig,
                                                     Input p_cod_indic_econ_idx,
                                                     Input p_dat_transacao,
                                                     Input p_ind_tip_cotac_parid,
                                                     Input p_cod_indic_econ_base,
                                                     Input p_cod_indic_econ_idx) /*pi_achar_cotac_indic_econ_2*/.

                    if  avail cotac_parid and cotac_parid.val_cotac_indic_econ <> 0
                    then do:
                        assign v_val_cotac_indic_econ_idx = cotac_parid.val_cotac_indic_econ
                               p_val_cotac_indic_econ = v_val_cotac_indic_econ_idx / v_val_cotac_indic_econ_base
                               p_dat_cotac_indic_econ = cotac_parid.dat_cotac_indic_econ
                               p_cod_return = "OK" /*l_ok*/ .
                        return.
                    end /* if */.
                end /* if */.
            end /* if */.
            if  parid_indic_econ.ind_orig_cotac_parid = "Inversa" /*l_inversa*/  and
                 (not avail cotac_parid or cotac_parid.val_cotac_indic_econ = 0)
            then do:
                find parid_indic_econ no-lock
                    where parid_indic_econ.cod_indic_econ_base = p_cod_indic_econ_idx
                    and parid_indic_econ.cod_indic_econ_idx = p_cod_indic_econ_base
                    use-index prdndccn_id no-error.
                run pi_achar_cotac_indic_econ_2 (Input p_cod_indic_econ_idx,
                                                 Input p_cod_indic_econ_base,
                                                 Input p_dat_transacao,
                                                 Input p_ind_tip_cotac_parid,
                                                 Input p_cod_indic_econ_base,
                                                 Input p_cod_indic_econ_idx) /*pi_achar_cotac_indic_econ_2*/.

                if  avail cotac_parid and cotac_parid.val_cotac_indic_econ <> 0
                then do:
                    assign p_dat_cotac_indic_econ = cotac_parid.dat_cotac_indic_econ
                           p_val_cotac_indic_econ = 1 / cotac_parid.val_cotac_indic_econ
                           p_cod_return = "OK" /*l_ok*/ .
                    return.
                end /* if */.
            end /* if */.
        end /* if */.
        if v_log_indic = yes then do:
           if  not avail cotac_parid or cotac_parid.val_cotac_indic_econ = 0
           then do:
               assign p_cod_return = "358"                 + "," +
                      p_cod_indic_econ_base   + "," +
                      p_cod_indic_econ_idx    + "," +
                      string(v_dat_cotac_mes) + "," +
                      p_ind_tip_cotac_parid.
           end /* if */.
           else do:
               assign p_dat_cotac_indic_econ = cotac_parid.dat_cotac_indic_econ
                      p_val_cotac_indic_econ = cotac_parid.val_cotac_indic_econ
                      p_cod_return           = "OK" /*l_ok*/ .
           end /* else */.
        end.
        else do:   
           if  not avail cotac_parid or cotac_parid.val_cotac_indic_econ = 0
           then do:
               assign p_cod_return = "358"                 + "," +
                      p_cod_indic_econ_base   + "," +
                      p_cod_indic_econ_idx    + "," +
                      string(p_dat_transacao) + "," +
                      p_ind_tip_cotac_parid.
           end /* if */.
           else do:
               assign p_dat_cotac_indic_econ = cotac_parid.dat_cotac_indic_econ
                      p_val_cotac_indic_econ = cotac_parid.val_cotac_indic_econ
                      p_cod_return           = "OK" /*l_ok*/ .
           end /* else */.
        end.
        assign v_log_indic = no.
    end /* else */.
END PROCEDURE. /* pi_achar_cotac_indic_econ */
/*****************************************************************************
** Procedure Interna.....: pi_achar_cotac_indic_econ_2
** Descricao.............: pi_achar_cotac_indic_econ_2
** Criado por............: src531
** Criado em.............: 29/07/2003 11:10:10
** Alterado por..........: bre17752
** Alterado em...........: 30/07/2003 12:46:24
*****************************************************************************/
PROCEDURE pi_achar_cotac_indic_econ_2:

    /************************ Parameter Definition Begin ************************/

    def Input param p_cod_param_1
        as character
        format "x(8)"
        no-undo.
    def Input param p_cod_param_2
        as character
        format "x(50)"
        no-undo.
    def Input param p_dat_transacao
        as date
        format "99/99/9999"
        no-undo.
    def Input param p_ind_tip_cotac_parid
        as character
        format "X(09)"
        no-undo.
    def Input param p_cod_indic_econ_base
        as character
        format "x(8)"
        no-undo.
    def Input param p_cod_indic_econ_idx
        as character
        format "x(8)"
        no-undo.


    /************************* Parameter Definition End *************************/

    /************************* Variable Definition Begin ************************/

    def var v_dat_cotac_mes                  as date            no-undo. /*local*/


    /************************** Variable Definition End *************************/

    /* period_block: */
    case parid_indic_econ.ind_periodic_cotac:
        when "Di†ria" /*l_diaria*/ then
            diaria_block:
            do:
                find cotac_parid no-lock
                     where cotac_parid.cod_indic_econ_base = p_cod_param_1
                       and cotac_parid.cod_indic_econ_idx = p_cod_param_2
                       and cotac_parid.dat_cotac_indic_econ = p_dat_transacao
                       and cotac_parid.ind_tip_cotac_parid = p_ind_tip_cotac_parid
                     use-index ctcprd_id no-error.
                if  not avail cotac_parid or cotac_parid.val_cotac_indic_econ = 0
                then do:
                    find parid_indic_econ no-lock
                         where parid_indic_econ.cod_indic_econ_base = p_cod_param_1
                           and parid_indic_econ.cod_indic_econ_idx = p_cod_param_2
                         use-index prdndccn_id no-error.
                    /* block: */
                    case parid_indic_econ.ind_criter_busca:
                        when "Anterior" /*l_anterior*/ then find prev cotac_parid no-lock
                              where cotac_parid.cod_indic_econ_base = p_cod_indic_econ_base
                                and cotac_parid.cod_indic_econ_idx = p_cod_indic_econ_idx
                                and cotac_parid.dat_cotac_indic_econ < p_dat_transacao
                                and cotac_parid.ind_tip_cotac_parid = p_ind_tip_cotac_parid
                                and cotac_parid.val_cotac_indic_econ <> 0.0
    &if "{&emsuni_version}" >= "5.01" &then
                              use-index ctcprd_id
    &endif
                               /*cl_acha_cotac_anterior of cotac_parid*/ no-error.
                        when "Pr¢ximo" /*l_proximo*/ then  find next cotac_parid no-lock
                               where cotac_parid.cod_indic_econ_base = p_cod_indic_econ_base
                                 and cotac_parid.cod_indic_econ_idx = p_cod_indic_econ_idx
                                 and cotac_parid.dat_cotac_indic_econ > p_dat_transacao
                                 and cotac_parid.ind_tip_cotac_parid = p_ind_tip_cotac_parid
                                 and cotac_parid.val_cotac_indic_econ <> 0.0
    &if "{&emsuni_version}" >= "5.01" &then
                               use-index ctcprd_id
    &endif
                                /*cl_acha_cotac_posterior of cotac_parid*/ no-error.
                    end /* case block */.
                end /* if */.
            end /* do diaria_block */.
        when "Mensal" /*l_mensal*/ then
            mensal_block:
            do:
                assign v_dat_cotac_mes = date(month(p_dat_transacao), 1, year(p_dat_transacao)).
                find cotac_parid no-lock
                     where cotac_parid.cod_indic_econ_base = p_cod_param_1
                       and cotac_parid.cod_indic_econ_idx = p_cod_param_2
                       and cotac_parid.dat_cotac_indic_econ = v_dat_cotac_mes
                       and cotac_parid.ind_tip_cotac_parid = p_ind_tip_cotac_parid
                     use-index ctcprd_id no-error.
                if  not avail cotac_parid or cotac_parid.val_cotac_indic_econ = 0
                then do:
                    /* block: */
                    case parid_indic_econ.ind_criter_busca:
                        when "Anterior" /*l_anterior*/ then
                        find prev cotac_parid no-lock
                                           where cotac_parid.cod_indic_econ_base = p_cod_param_1
                                             and cotac_parid.cod_indic_econ_idx = p_cod_param_2
                                             and cotac_parid.dat_cotac_indic_econ < v_dat_cotac_mes
                                             and cotac_parid.ind_tip_cotac_parid = p_ind_tip_cotac_parid
                                             and cotac_parid.val_cotac_indic_econ <> 0.0
                                           use-index ctcprd_id no-error.
                        when "Pr¢ximo" /*l_proximo*/ then
                        find next cotac_parid no-lock
                                           where cotac_parid.cod_indic_econ_base = p_cod_param_1
                                             and cotac_parid.cod_indic_econ_idx = p_cod_param_2
                                             and cotac_parid.dat_cotac_indic_econ > v_dat_cotac_mes
                                             and cotac_parid.ind_tip_cotac_parid = p_ind_tip_cotac_parid
                                             and cotac_parid.val_cotac_indic_econ <> 0.0
                                           use-index ctcprd_id no-error.
                    end /* case block */.
                end /* if */.
            end /* do mensal_block */.
        when "Bimestral" /*l_bimestral*/ then
            bimestral_block:
            do:
            end /* do bimestral_block */.
        when "Trimestral" /*l_trimestral*/ then
            trimestral_block:
            do:
            end /* do trimestral_block */.
        when "Quadrimestral" /*l_quadrimestral*/ then
            quadrimestral_block:
            do:
            end /* do quadrimestral_block */.
        when "Semestral" /*l_semestral*/ then
            semestral_block:
            do:
            end /* do semestral_block */.
        when "Anual" /*l_anual*/ then
            anual_block:
            do:
            end /* do anual_block */.
    end /* case period_block */.
END PROCEDURE. /* pi_achar_cotac_indic_econ_2 */
/*****************************************************************************
** Procedure Interna.....: pi_retornar_finalid_indic_econ
** Descricao.............: pi_retornar_finalid_indic_econ
** Criado por............: 
** Criado em.............: // 
** Alterado por..........: fut43117
** Alterado em...........: 05/12/2011 10:21:41
*****************************************************************************/
PROCEDURE pi_retornar_finalid_indic_econ:

    /************************ Parameter Definition Begin ************************/

    def Input param p_cod_indic_econ
        as character
        format "x(8)"
        no-undo.
    def Input param p_dat_transacao
        as date
        format "99/99/9999"
        no-undo.
    def output param p_cod_finalid_econ
        as character
        format "x(10)"
        no-undo.


    /************************* Parameter Definition End *************************/

    /* alteracao sob demanda - atividade 195864*/
    find first histor_finalid_econ no-lock
        where histor_finalid_econ.cod_indic_econ          = p_cod_indic_econ
        and   histor_finalid_econ.dat_inic_valid_finalid <= p_dat_transacao
        and   histor_finalid_econ.dat_fim_valid_finalid  > p_dat_transacao no-error.
    if  avail histor_finalid_econ then 
        assign p_cod_finalid_econ = histor_finalid_econ.cod_finalid_econ.




END PROCEDURE. /* pi_retornar_finalid_indic_econ */
/*****************************************************************************
** Procedure Interna.....: pi_classifica_tit_acr_antecip_prev
** Descricao.............: pi_classifica_tit_acr_antecip_prev
** Criado por............: Amarildo
** Criado em.............: 24/02/1997 17:25:21
** Alterado por..........: fut12197
** Alterado em...........: 10/01/2005 15:47:11
*****************************************************************************/
PROCEDURE pi_classifica_tit_acr_antecip_prev:

    /* class_block: */
    case v_ind_classif:
        when "Por T°tulo" /*l_por_titulo*/ then
            assign tt_rpt_tit_acr_antecip_prev_acr.ttv_cod_dwb_field_rpt[v_num_idx + 1] = tt_rpt_tit_acr_antecip_prev_acr.cod_estab
                   tt_rpt_tit_acr_antecip_prev_acr.ttv_cod_dwb_field_rpt[v_num_idx + 2] = tt_rpt_tit_acr_antecip_prev_acr.cod_espec_docto
                   tt_rpt_tit_acr_antecip_prev_acr.ttv_cod_dwb_field_rpt[v_num_idx + 3] = tt_rpt_tit_acr_antecip_prev_acr.cod_ser_docto
                   tt_rpt_tit_acr_antecip_prev_acr.ttv_cod_dwb_field_rpt[v_num_idx + 4] = tt_rpt_tit_acr_antecip_prev_acr.cod_tit_acr
                   tt_rpt_tit_acr_antecip_prev_acr.ttv_cod_dwb_field_rpt[v_num_idx + 5] = tt_rpt_tit_acr_antecip_prev_acr.cod_parcela.

        when "Por C¢digo Cliente" /*l_por_codigo_cliente*/ then
            assign tt_rpt_tit_acr_antecip_prev_acr.ttv_cod_dwb_field_rpt[v_num_idx + 1] = string(tt_rpt_tit_acr_antecip_prev_acr.cdn_cliente, ">>>,>>>,>>9":U)
                   tt_rpt_tit_acr_antecip_prev_acr.ttv_cod_dwb_field_rpt[v_num_idx + 2] = tt_rpt_tit_acr_antecip_prev_acr.cod_espec_docto
                   tt_rpt_tit_acr_antecip_prev_acr.ttv_cod_dwb_field_rpt[v_num_idx + 3] = string (year  (tt_rpt_tit_acr_antecip_prev_acr.dat_emis_docto),"9999") +
                                                                                          string (month (tt_rpt_tit_acr_antecip_prev_acr.dat_emis_docto),"99") +
                                                                                          string (day   (tt_rpt_tit_acr_antecip_prev_acr.dat_emis_docto),"99").

        when "Por C¢digo Cliente/Representante" /*l_por_codigo_clienterepresentant*/ then
            assign tt_rpt_tit_acr_antecip_prev_acr.ttv_cod_dwb_field_rpt[v_num_idx + 1] = string(tt_rpt_tit_acr_antecip_prev_acr.cdn_cliente, ">>>,>>>,>>9":U)
                   tt_rpt_tit_acr_antecip_prev_acr.ttv_cod_dwb_field_rpt[v_num_idx + 2] = string(tt_rpt_tit_acr_antecip_prev_acr.cdn_repres, ">>>,>>9":U)
                   tt_rpt_tit_acr_antecip_prev_acr.ttv_cod_dwb_field_rpt[v_num_idx + 3] = tt_rpt_tit_acr_antecip_prev_acr.cod_espec_docto
                   tt_rpt_tit_acr_antecip_prev_acr.ttv_cod_dwb_field_rpt[v_num_idx + 4] = string (year  (tt_rpt_tit_acr_antecip_prev_acr.dat_emis_docto),"9999") +
                                                                                          string (month (tt_rpt_tit_acr_antecip_prev_acr.dat_emis_docto),"99") +
                                                                                          string (day   (tt_rpt_tit_acr_antecip_prev_acr.dat_emis_docto),"99").

        when "Por C¢digo Cliente/T°tulo" /*l_por_codigo_clientetitulo*/ then
            assign tt_rpt_tit_acr_antecip_prev_acr.ttv_cod_dwb_field_rpt[v_num_idx + 1] = string(tt_rpt_tit_acr_antecip_prev_acr.cdn_cliente, ">>>,>>>,>>9":U)
                   tt_rpt_tit_acr_antecip_prev_acr.ttv_cod_dwb_field_rpt[v_num_idx + 2] = tt_rpt_tit_acr_antecip_prev_acr.cod_estab
                   tt_rpt_tit_acr_antecip_prev_acr.ttv_cod_dwb_field_rpt[v_num_idx + 3] = tt_rpt_tit_acr_antecip_prev_acr.cod_espec_docto
                   tt_rpt_tit_acr_antecip_prev_acr.ttv_cod_dwb_field_rpt[v_num_idx + 4] = tt_rpt_tit_acr_antecip_prev_acr.cod_ser_docto
                   tt_rpt_tit_acr_antecip_prev_acr.ttv_cod_dwb_field_rpt[v_num_idx + 5] = tt_rpt_tit_acr_antecip_prev_acr.cod_tit_acr
                   tt_rpt_tit_acr_antecip_prev_acr.ttv_cod_dwb_field_rpt[v_num_idx + 6] = tt_rpt_tit_acr_antecip_prev_acr.cod_parcela.

        when "Por T°tulo/Vencimento" /*l_por_titulovencimento*/ then
            assign tt_rpt_tit_acr_antecip_prev_acr.ttv_cod_dwb_field_rpt[v_num_idx + 1] = string (year  (tt_rpt_tit_acr_antecip_prev_acr.dat_vencto_tit_acr),"9999") +
                                                                                          string (month (tt_rpt_tit_acr_antecip_prev_acr.dat_vencto_tit_acr),"99") +
                                                                                          string (day   (tt_rpt_tit_acr_antecip_prev_acr.dat_vencto_tit_acr),"99")
                   tt_rpt_tit_acr_antecip_prev_acr.ttv_cod_dwb_field_rpt[v_num_idx + 2] = tt_rpt_tit_acr_antecip_prev_acr.cod_espec_docto.
    end /* case class_block */.

    if  v_ind_dwb_run_mode = "Batch" /*l_batch*/ 
    then do:
        assign v_cod_ult_obj_procesdo = tt_rpt_tit_acr_antecip_prev_acr.cod_estab + "," + tt_rpt_tit_acr_antecip_prev_acr.cod_espec_docto + "," +
                                        tt_rpt_tit_acr_antecip_prev_acr.cod_ser_docto + "," + tt_rpt_tit_acr_antecip_prev_acr.cod_tit_acr + "," + tt_rpt_tit_acr_antecip_prev_acr.cod_parcela.
        run prgtec/btb/btb908ze.py (Input 1,
                                    Input v_cod_ult_obj_procesdo) /*prg_api_atualizar_ult_obj*/.
    end /* if */.

END PROCEDURE. /* pi_classifica_tit_acr_antecip_prev */
/*****************************************************************************
** Procedure Interna.....: pi_lista_cta_ctbl
** Descricao.............: pi_lista_cta_ctbl
** Criado por............: Amarildo
** Criado em.............: 04/03/1997 10:21:21
** Alterado por..........: Amarildo
** Alterado em...........: 06/03/1997 10:05:22
*****************************************************************************/
PROCEDURE pi_lista_cta_ctbl:

    find first movto_tit_acr no-lock
       where movto_tit_acr.cod_estab      = tt_rpt_tit_acr_antecip_prev_acr.cod_estab
         and movto_tit_acr.num_id_tit_acr = tt_rpt_tit_acr_antecip_prev_acr.num_id_tit_acr
         no-error.
    if  available movto_tit_acr
    then do:
       find first aprop_ctbl_acr no-lock
          where aprop_ctbl_acr.cod_estab            = movto_tit_acr.cod_estab
            and aprop_ctbl_acr.num_id_movto_tit_acr = movto_tit_acr.num_id_movto_tit_acr
            and aprop_ctbl_acr.ind_tip_aprop_ctbl   = "Principal Ativo" /*l_principal_ativo*/ 
       no-error.
       if  available aprop_ctbl_acr
       then do:
          if  v_log_plano_ativ = no
          then do:
             find plano_cta_ctbl no-lock
                where plano_cta_ctbl.cod_plano_cta_ctbl = aprop_ctbl_acr.cod_plano_cta_ctbl
             no-error.
             if  available plano_cta_ctbl
             then do:
                assign v_cod_cta_ctbl = string(aprop_ctbl_acr.cod_cta_ctbl,plano_cta_ctbl.cod_format_cta_ctbl).
                assign v_log_plano_ativ = yes.
             end /* if */.
             else do:
                assign v_cod_cta_ctbl = aprop_ctbl_acr.cod_cta_ctbl.
             end /* else */.
          end /* if */.
          else do:
             assign v_cod_cta_ctbl = string(aprop_ctbl_acr.cod_cta_ctbl,plano_cta_ctbl.cod_format_cta_ctbl).
          end /* else */.
       end /* if */.
       else do:
          assign v_cod_cta_ctbl = "" /*l_null*/ .
       end /* else */.
    end /* if */.
END PROCEDURE. /* pi_lista_cta_ctbl */
/*****************************************************************************
** Procedure Interna.....: pi_lista_ped
** Descricao.............: pi_lista_ped
** Criado por............: Amarildo
** Criado em.............: 04/03/1997 11:19:36
** Alterado por..........: fut1147
** Alterado em...........: 25/07/2005 09:04:01
*****************************************************************************/
PROCEDURE pi_lista_ped:

    find first ped_vda_tit_acr no-lock
       where ped_vda_tit_acr.cod_estab      = tt_rpt_tit_acr_antecip_prev_acr.cod_estab
         and ped_vda_tit_acr.num_id_tit_acr = tt_rpt_tit_acr_antecip_prev_acr.num_id_tit_acr
       no-error.
    if  available ped_vda_tit_acr
    then do:
       pedidos:
       for
          each ped_vda_tit_acr no-lock
            where ped_vda_tit_acr.cod_estab      = tt_rpt_tit_acr_antecip_prev_acr.cod_estab
              and ped_vda_tit_acr.num_id_tit_acr = tt_rpt_tit_acr_antecip_prev_acr.num_id_tit_acr:
          assign v_cod_ped_vda = ped_vda_tit_acr.cod_ped_vda.
          if  v_log_primei_ped_vda = yes
          then do:
             if v_ind_classif = "Por T°tulo" /*l_por_titulo*/  then do:
               if (line-counter(s_1) + 1) > v_rpt_s_1_bottom then
                   page stream s_1.
               put stream s_1 unformatted 
    &IF "{&emsfin_version}" >= "" AND "{&emsfin_version}" < "5.07A" &THEN
                   tt_rpt_tit_acr_antecip_prev_acr.cod_estab at 1 format "x(3)"
    &ENDIF
    &IF "{&emsfin_version}" >= "5.07A" AND "{&emsfin_version}" < "9.99" &THEN
                   tt_rpt_tit_acr_antecip_prev_acr.cod_estab at 1 format "x(5)"
    &ENDIF
                   tt_rpt_tit_acr_antecip_prev_acr.cod_espec_docto at 7 format "x(3)".
    put stream s_1 unformatted 
                   tt_rpt_tit_acr_antecip_prev_acr.cod_ser_docto at 11 format "x(5)"
                   tt_rpt_tit_acr_antecip_prev_acr.cod_tit_acr at 17 format "x(16)"
                   "/" at 33
                   tt_rpt_tit_acr_antecip_prev_acr.cod_parcela at 34 format "x(02)"
                   tt_rpt_tit_acr_antecip_prev_acr.cdn_cliente to 47 format ">>>,>>>,>>9"
                   tt_rpt_tit_acr_antecip_prev_acr.tta_cod_unid_negoc at 49 format "x(3)"
                   tt_rpt_tit_acr_antecip_prev_acr.cod_portador at 53 format "x(5)"
                   tt_rpt_tit_acr_antecip_prev_acr.cod_cart_bcia at 59 format "x(3)"
                   tt_rpt_tit_acr_antecip_prev_acr.dat_emis_docto at 63 format "99/99/99"
                   tt_rpt_tit_acr_antecip_prev_acr.dat_vencto_tit_acr at 72 format "99/99/99".
    put stream s_1 unformatted 
                   tt_rpt_tit_acr_antecip_prev_acr.cod_indic_econ at 81 format "x(8)"
                   tt_rpt_tit_acr_antecip_prev_acr.val_sdo_tit_acr to 103 format ">>>,>>>,>>9.99"
                   tt_rpt_tit_acr_antecip_prev_acr.ttv_val_origin_tit_acr_apres to 119 format "->>>,>>>,>>9.99"
                   tt_rpt_tit_acr_antecip_prev_acr.ttv_val_sdo_tit_acr_apres to 138 format "->>>,>>>,>>9.99"
                   v_cod_cli_convenio at 140 format ">>>,>>>,>>9"
/*                    v_cod_ped_vda at 161 format "x(12)" */
                   v_cod_convenio at 161 format "x(12)" 
                    skip.
             end.
             else do:  
               if (line-counter(s_1) + 1) > v_rpt_s_1_bottom then
                   page stream s_1.
               put stream s_1 unformatted 
    &IF "{&emsfin_version}" >= "" AND "{&emsfin_version}" < "5.07A" &THEN
                   tt_rpt_tit_acr_antecip_prev_acr.cod_estab at 1 format "x(3)"
    &ENDIF
    &IF "{&emsfin_version}" >= "5.07A" AND "{&emsfin_version}" < "9.99" &THEN
                   tt_rpt_tit_acr_antecip_prev_acr.cod_estab at 1 format "x(5)"
    &ENDIF
                   tt_rpt_tit_acr_antecip_prev_acr.cod_espec_docto at 7 format "x(3)".
    put stream s_1 unformatted 
                   tt_rpt_tit_acr_antecip_prev_acr.cod_ser_docto at 11 format "x(5)"
                   tt_rpt_tit_acr_antecip_prev_acr.cod_tit_acr at 17 format "x(16)"
                   "/" at 33
                   tt_rpt_tit_acr_antecip_prev_acr.cod_parcela at 34 format "x(02)"
                   tt_rpt_tit_acr_antecip_prev_acr.tta_cod_unid_negoc at 37 format "x(3)"
                   tt_rpt_tit_acr_antecip_prev_acr.cod_portador at 41 format "x(5)"
                   tt_rpt_tit_acr_antecip_prev_acr.cod_cart_bcia at 47 format "x(3)"
                   tt_rpt_tit_acr_antecip_prev_acr.dat_emis_docto at 51 format "99/99/99"
                   tt_rpt_tit_acr_antecip_prev_acr.dat_vencto_tit_acr at 60 format "99/99/99"
                   tt_rpt_tit_acr_antecip_prev_acr.cod_indic_econ at 69 format "x(8)".
    put stream s_1 unformatted 
                   tt_rpt_tit_acr_antecip_prev_acr.val_sdo_tit_acr to 91 format ">>>,>>>,>>9.99"
                   tt_rpt_tit_acr_antecip_prev_acr.ttv_val_origin_tit_acr_apres to 108 format "->>>,>>>,>>9.99"
                   tt_rpt_tit_acr_antecip_prev_acr.ttv_val_sdo_tit_acr_apres to 128 format "->>>,>>>,>>9.99"
                   v_cod_cli_convenio at 130 format ">>>,>>>,>>9"
/*                    v_cod_ped_vda at 151 format "x(12)" */
                   v_cod_convenio  at 151 format "x(12)" 
                   skip.
             end.  
             assign v_log_primei_ped_vda = no.
          end /* if */.
          else do:
             if (line-counter(s_1) + 1) > v_rpt_s_1_bottom then
                 page stream s_1.
             put stream s_1 unformatted 
/*                  v_cod_ped_vda at 151 format "x(12)" */
                 v_cod_convenio at 151 format "x(12)" 
                 skip.
          end /* else */.
       end /* for pedidos */.
    end /* if */.
    else do:
       assign v_cod_ped_vda = "" /*l_null*/ .
       if v_ind_classif = "Por T°tulo" /*l_por_titulo*/  then do:
         if (line-counter(s_1) + 1) > v_rpt_s_1_bottom then
             page stream s_1.
         put stream s_1 unformatted 
    &IF "{&emsfin_version}" >= "" AND "{&emsfin_version}" < "5.07A" &THEN
             tt_rpt_tit_acr_antecip_prev_acr.cod_estab at 1 format "x(3)"
    &ENDIF
    &IF "{&emsfin_version}" >= "5.07A" AND "{&emsfin_version}" < "9.99" &THEN
             tt_rpt_tit_acr_antecip_prev_acr.cod_estab at 1 format "x(5)"
    &ENDIF
             tt_rpt_tit_acr_antecip_prev_acr.cod_espec_docto at 7 format "x(3)".
    put stream s_1 unformatted 
             tt_rpt_tit_acr_antecip_prev_acr.cod_ser_docto at 11 format "x(5)"
             tt_rpt_tit_acr_antecip_prev_acr.cod_tit_acr at 17 format "x(16)"
             "/" at 33
             tt_rpt_tit_acr_antecip_prev_acr.cod_parcela at 34 format "x(02)"
             tt_rpt_tit_acr_antecip_prev_acr.cdn_cliente to 47 format ">>>,>>>,>>9"
             tt_rpt_tit_acr_antecip_prev_acr.tta_cod_unid_negoc at 49 format "x(3)"
             tt_rpt_tit_acr_antecip_prev_acr.cod_portador at 53 format "x(5)"
             tt_rpt_tit_acr_antecip_prev_acr.cod_cart_bcia at 59 format "x(3)"
             tt_rpt_tit_acr_antecip_prev_acr.dat_emis_docto at 63 format "99/99/99"
             tt_rpt_tit_acr_antecip_prev_acr.dat_vencto_tit_acr at 72 format "99/99/99".
    put stream s_1 unformatted 
             tt_rpt_tit_acr_antecip_prev_acr.cod_indic_econ at 81 format "x(8)"
             tt_rpt_tit_acr_antecip_prev_acr.val_sdo_tit_acr to 103 format ">>>,>>>,>>9.99"
             tt_rpt_tit_acr_antecip_prev_acr.ttv_val_origin_tit_acr_apres to 119 format "->>>,>>>,>>9.99"
             tt_rpt_tit_acr_antecip_prev_acr.ttv_val_sdo_tit_acr_apres to 138 format "->>>,>>>,>>9.99"
             v_cod_cli_convenio at 140 format ">>>,>>>,>>9"
/*              v_cod_ped_vda at 161 format "x(12)" */
             v_cod_convenio at 161 format "x(12)" 
             skip.
       end.  
       else do:  
         if (line-counter(s_1) + 1) > v_rpt_s_1_bottom then
             page stream s_1.
         put stream s_1 unformatted 
    &IF "{&emsfin_version}" >= "" AND "{&emsfin_version}" < "5.07A" &THEN
             tt_rpt_tit_acr_antecip_prev_acr.cod_estab at 1 format "x(3)"
    &ENDIF
    &IF "{&emsfin_version}" >= "5.07A" AND "{&emsfin_version}" < "9.99" &THEN
             tt_rpt_tit_acr_antecip_prev_acr.cod_estab at 1 format "x(5)"
    &ENDIF
             tt_rpt_tit_acr_antecip_prev_acr.cod_espec_docto at 7 format "x(3)".
    put stream s_1 unformatted 
             tt_rpt_tit_acr_antecip_prev_acr.cod_ser_docto at 11 format "x(5)"
             tt_rpt_tit_acr_antecip_prev_acr.cod_tit_acr at 17 format "x(16)"
             "/" at 33
             tt_rpt_tit_acr_antecip_prev_acr.cod_parcela at 34 format "x(02)"
             tt_rpt_tit_acr_antecip_prev_acr.tta_cod_unid_negoc at 37 format "x(3)"
             tt_rpt_tit_acr_antecip_prev_acr.cod_portador at 41 format "x(5)"
             tt_rpt_tit_acr_antecip_prev_acr.cod_cart_bcia at 47 format "x(3)"
             tt_rpt_tit_acr_antecip_prev_acr.dat_emis_docto at 51 format "99/99/99"
             tt_rpt_tit_acr_antecip_prev_acr.dat_vencto_tit_acr at 60 format "99/99/99"
             tt_rpt_tit_acr_antecip_prev_acr.cod_indic_econ at 69 format "x(8)".
    put stream s_1 unformatted 
             tt_rpt_tit_acr_antecip_prev_acr.val_sdo_tit_acr to 91 format ">>>,>>>,>>9.99"
             tt_rpt_tit_acr_antecip_prev_acr.ttv_val_origin_tit_acr_apres to 108 format "->>>,>>>,>>9.99"
             tt_rpt_tit_acr_antecip_prev_acr.ttv_val_sdo_tit_acr_apres to 128 format "->>>,>>>,>>9.99"
             v_cod_cli_convenio at 130 format ">>>,>>>,>>9"
/*              v_cod_ped_vda at 151 format "x(12)" */
             v_cod_convenio at 151 format "x(12)" 
        skip.  
       end.  
    end /* else */.
END PROCEDURE. /* pi_lista_ped */
/*****************************************************************************
** Procedure Interna.....: pi_testa_quebras
** Descricao.............: pi_testa_quebras
** Criado por............: Amarildo
** Criado em.............: 04/03/1997 17:37:12
** Alterado por..........: fut1147
** Alterado em...........: 25/07/2005 09:07:55
*****************************************************************************/
PROCEDURE pi_testa_quebras:

    /************************ Parameter Definition Begin ************************/

    def Input param p_num_ocorrencia
        as integer
        format ">>>>,>>9"
        no-undo.


    /************************* Parameter Definition End *************************/

    /* quebra: */
    case p_num_ocorrencia:
        when 1 then
            if  v_ind_classif = "Por C¢digo Cliente" /*l_por_codigo_cliente*/  or
                v_ind_classif = "Por C¢digo Cliente/Representante" /*l_por_codigo_clienterepresentant*/  or
                v_ind_classif = "Por C¢digo Cliente/T°tulo" /*l_por_codigo_clientetitulo*/ 
            then do:
               if (line-counter(s_1) + 1) > v_rpt_s_1_bottom then
                   page stream s_1.
               put stream s_1 unformatted 
                   "Total Cliente:" at 78
                   v_val_tot_cr_clien to 108 format ">>,>>>,>>>,>>9.99"
                   v_val_tot_cr_clien_sdo to 128 format "->>,>>>,>>>,>>9.99" skip.
               assign v_val_tot_cr_clien     = 0
                      v_val_tot_cr_clien_sdo = 0.
            end /* if */.
        when 2 then
            quebr:
            do:
               if v_ind_classif = "Por T°tulo" /*l_por_titulo*/  then do:
                  if  v_log_tot_por_espec = yes
                  then do:
                     if (line-counter(s_1) + 1) > v_rpt_s_1_bottom then
                         page stream s_1.
                     put stream s_1 unformatted 
                         "Total EspÇcie:" at 86
                         v_val_tot_espec to 118 format "->>,>>>,>>>,>>9.99"
                         v_val_tot_espec_sdo to 138 format "->>,>>>,>>>,>>9.99" skip.
                     assign v_val_tot_espec     = 0
                            v_val_tot_espec_sdo = 0.
                  end /* if */.
               end.
               if  v_ind_classif = "Por C¢digo Cliente" /*l_por_codigo_cliente*/  or
                   v_ind_classif = "Por Vencimento/T°tulo" /*l_por_venctotitulo*/ 
               then do:
                  if  v_log_tot_por_espec = yes
                  then do:
                     if (line-counter(s_1) + 1) > v_rpt_s_1_bottom then
                         page stream s_1.
                     put stream s_1 unformatted 
                         "Total EspÇcie:" at 77
                         v_val_tot_espec to 108 format "->>,>>>,>>>,>>9.99"
                         v_val_tot_espec_sdo to 128 format "->>,>>>,>>>,>>9.99" skip.
                     assign v_val_tot_espec     = 0
                            v_val_tot_espec_sdo = 0.
                  end /* if */.
               end /* if */.

               if  v_ind_classif = "Por C¢digo Cliente/Representante" /*l_por_codigo_clienterepresentant*/ 
               then do:
                  if (line-counter(s_1) + 1) > v_rpt_s_1_bottom then
                      page stream s_1.
                  put stream s_1 unformatted 
                      "Total Representante:" at 71
                      v_val_tot_repres to 108 format "->>,>>>,>>>,>>9.99"
                      v_val_tot_repres_sdo to 128 format "->>,>>>,>>>,>>9.99" skip.
                  assign v_val_tot_repres     = 0
                         v_val_tot_repres_sdo = 0.
               end /* if */.
            end /* do quebr */.
        when 3 then
            if  v_ind_classif = "Por C¢digo Cliente/Representante" /*l_por_codigo_clienterepresentant*/  or
                v_ind_classif = "Por C¢digo Cliente/T°tulo" /*l_por_codigo_clientetitulo*/ 
            then do:
               if  v_log_tot_por_espec = yes
               then do:
                  if (line-counter(s_1) + 1) > v_rpt_s_1_bottom then
                      page stream s_1.
                  put stream s_1 unformatted 
                      "Total EspÇcie:" at 77
                      v_val_tot_espec to 108 format "->>,>>>,>>>,>>9.99"
                      v_val_tot_espec_sdo to 128 format "->>,>>>,>>>,>>9.99" skip.
                  assign v_val_tot_espec     = 0
                         v_val_tot_espec_sdo = 0.
               end /* if */.
            end /* if */.
    end /* case quebra */.
END PROCEDURE. /* pi_testa_quebras */
/*****************************************************************************
** Procedure Interna.....: pi_testa_quebras_1
** Descricao.............: pi_testa_quebras_1
** Criado por............: Amarildo
** Criado em.............: 05/03/1997 18:06:32
** Alterado por..........: Rafael
** Alterado em...........: 04/04/1998 15:07:04
*****************************************************************************/
PROCEDURE pi_testa_quebras_1:

    /************************ Parameter Definition Begin ************************/

    def Input param p_num_ocorrencia
        as integer
        format ">>>>,>>9"
        no-undo.


    /************************* Parameter Definition End *************************/

    /* quebra: */
    case p_num_ocorrencia:
        when 1 then
            /* ** CLIENTE ESTµ NA PRIMEIRA OCORR“NCIA DA TABELA ***/
            if  v_ind_classif = "Por C¢digo Cliente" /*l_por_codigo_cliente*/              or
                v_ind_classif = "Por C¢digo Cliente/Representante" /*l_por_codigo_clienterepresentant*/  or
                v_ind_classif = "Por C¢digo Cliente/T°tulo" /*l_por_codigo_clientetitulo*/ 
            then do:
               find cliente no-lock
                  where cliente.cod_empresa = v_cod_empres_usuar
                  and   cliente.cdn_cliente = tt_rpt_tit_acr_antecip_prev_acr.cdn_cliente
               no-error.
               if  available cliente
               then do:
                  assign v_nom_pessoa_cli  = cliente.nom_pessoa.
               end /* if */.
               assign v_cdn_cliente_ant = tt_rpt_tit_acr_antecip_prev_acr.cdn_cliente.
               if (line-counter(s_1) + 1) > v_rpt_s_1_bottom then
                   page stream s_1.
               put stream s_1 unformatted 
                   "Cliente: " at 7
                   v_cdn_cliente_ant to 26 format ">>>,>>>,>>9"
                   v_nom_pessoa_cli at 28 format "x(40)" skip.
            end /* if */.
        when 2 then
            /* ** REPRESENTANTE ESTµ NA SEGUNDA OCORR“NCIA DA TABELA ***/
            if  v_ind_classif = "Por C¢digo Cliente/Representante" /*l_por_codigo_clienterepresentant*/ 
            then do:
               assign v_cdn_repres_ant = tt_rpt_tit_acr_antecip_prev_acr.cdn_repres.
               find representante no-lock
                  where representante.cdn_repres = tt_rpt_tit_acr_antecip_prev_acr.cdn_repres
               no-error.
               if  available representante
               then do:
                  assign v_nom_pessoa_rep = representante.nom_pessoa.
               end /* if */.
               assign v_cdn_repres_ant = tt_rpt_tit_acr_antecip_prev_acr.cdn_repres.
               if (line-counter(s_1) + 1) > v_rpt_s_1_bottom then
                   page stream s_1.
               put stream s_1 unformatted 
                   "Representante: " at 1
                   v_cdn_repres_ant to 22 format ">>>,>>9"
                   v_nom_pessoa_rep at 24 format "x(40)" skip.
            end /* if */.
    end /* case quebra */.
END PROCEDURE. /* pi_testa_quebras_1 */
/*****************************************************************************
** Procedure Interna.....: pi_inicializa_variaveis_acr
** Descricao.............: pi_inicializa_variaveis_acr
** Criado por............: Amarildo
** Criado em.............: 06/03/1997 12:00:11
** Alterado por..........: Amarildo
** Alterado em...........: 21/03/1997 09:25:33
*****************************************************************************/
PROCEDURE pi_inicializa_variaveis_acr:

    assign v_val_tot_geral_acr     = 0
           v_val_tot_geral_acr_sdo = 0
           v_val_tot_cr_clien      = 0
           v_val_tot_cr_clien_sdo  = 0
           v_val_tot_repres        = 0
           v_val_tot_repres_sdo    = 0
           v_val_tot_espec         = 0
           v_val_tot_espec_sdo     = 0
           v_log_primei_ped_vda    = yes.
END PROCEDURE. /* pi_inicializa_variaveis_acr */
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
/*****************************************************************************
** Procedure Interna.....: pi_vld_permissao_usuar_estab_empres
** Descricao.............: pi_vld_permissao_usuar_estab_empres
** Criado por............: bre18732
** Criado em.............: 21/06/2002 16:19:21
** Alterado por..........: fut42625
** Alterado em...........: 12/08/2011 10:26:24
*****************************************************************************/
PROCEDURE pi_vld_permissao_usuar_estab_empres:

    /************************ Parameter Definition Begin ************************/

    def Input param p_cod_modul_dtsul
        as character
        format "x(3)"
        no-undo.


    /************************* Parameter Definition End *************************/

    /************************* Variable Definition Begin ************************/

    def var v_log_reg_corporat
        as logical
        format "Sim/N∆o"
        initial no
        view-as toggle-box
        label "Registro Corporativo"
        column-label "Registro Corporativo"
        no-undo.
    def var v_log_restric_estab
        as logical
        format "Sim/N∆o"
        initial no
        view-as toggle-box
        label "Usa Segur Estab"
        column-label "Usa Segur Estab"
        no-undo.
    def var v_nom_razao_social
        as character
        format "x(30)":U
        label "Raz∆o Social"
        column-label "Raz∆o Social"
        no-undo.


    /************************** Variable Definition End *************************/


    /* Begin_Include: i_vld_permissao_usuar_estab_empres */
    find last param_geral_apb no-lock no-error.
    if p_cod_modul_dtsul = "EMS2" /*l_ems_2*/  then do:
        assign v_log_reg_corporat = yes.
    end.
    else do:
        if avail param_geral_apb then 
            assign v_log_reg_corporat = param_geral_apb.log_reg_corporat.
    end.



    assign v_log_restric_estab = no.
    &IF DEFINED(BF_FIN_SEGUR_ESTABELEC) &THEN
        case p_cod_modul_dtsul:
            when "ACR" /*l_acr*/  then do:
                find last param_geral_acr no-lock no-error.
                if avail param_geral_acr then
                    assign v_log_restric_estab = param_geral_acr.log_restric_estab.
            end.
            when "APB" /*l_apb*/  then do:
                find last param_geral_apb no-lock no-error.
                if avail param_geral_apb then
                    assign v_log_restric_estab = param_geral_apb.log_restric_estab.
            end.
            when "EMS2" /*l_ems_2*/  then do:
            /* QUANDO FOR CHAMADO PELO EMS2 DEVERµ FAZER A RESTRIÄ«O DOS ESTABELECIMENTOS */        
                assign v_log_restric_estab = yes.
            end.
            otherwise
                assign v_log_restric_estab = no.
        end case.
    &ELSE
        if v_log_reg_corporat then
            assign v_log_restric_estab = yes.
    &ENDIF
    /* End_Include: i_vld_permissao_usuar_estab_empres */


    for each tt_usuar_grp_usuar.
        delete tt_usuar_grp_usuar.
    end.

    /* Cria TT com os grupos de usu†rios */
    for each usuar_grp_usuar where 
             usuar_grp_usuar.cod_usuario = v_cod_usuar_corren no-lock:
        find first tt_usuar_grp_usuar where 
                   tt_usuar_grp_usuar.cod_grp_usuar = usuar_grp_usuar.cod_grp_usuar
               and tt_usuar_grp_usuar.cod_usuario   = usuar_grp_usuar.cod_usuario no-lock no-error.
        if not avail tt_usuar_grp_usuar then do:
            create tt_usuar_grp_usuar.
            buffer-copy usuar_grp_usuar to tt_usuar_grp_usuar.
        end.
    end.
    /* Cria Grupo '*' */
    find first tt_usuar_grp_usuar where 
               tt_usuar_grp_usuar.cod_grp_usuar = "*"
           and tt_usuar_grp_usuar.cod_usuario   = v_cod_usuar_corren no-lock no-error.
    if not avail tt_usuar_grp_usuar then do:
        create tt_usuar_grp_usuar.
        assign tt_usuar_grp_usuar.cod_grp_usuar = "*"
               tt_usuar_grp_usuar.cod_usuario   = v_cod_usuar_corren.
    end.

    for each tt_empresa:
        delete tt_empresa.

    end.

    if v_log_reg_corporat = yes then do:
        for each empresa no-lock:
            for each tt_usuar_grp_usuar:
                /* Verifica se o Usu†rio tem permiss∆o na Empresa */
                if not can-find(first segur_unid_organ where
                                      segur_unid_organ.cod_unid_organ = empresa.cod_empresa 
                                 and (segur_unid_organ.cod_grp_usuar  = tt_usuar_grp_usuar.cod_grp_usuar
                                  or  segur_unid_organ.cod_grp_usuar  = "*")) then 
                   next.

                create tt_empresa.
                assign tt_empresa.tta_cod_empresa = empresa.cod_empresa.
                leave.
            end.
        end.
    end.
    else do:
        create tt_empresa.
        assign tt_empresa.tta_cod_empresa = v_cod_empres_usuar.
    end.

    for each tt_estabelecimento_empresa:
        delete tt_estabelecimento_empresa.
    end.

    for each tt_empresa no-lock:
        /* *****  ALTERACAO SOB DEMANDA PARA EVITAR MULTIPLOS ACESSOS A TABELA EMPRESA ******/
        assign v_nom_razao_social = "" /*l_*/ .
        find empresa no-lock where empresa.cod_empresa = tt_empresa.tta_cod_empresa no-error.
        if avail empresa then          
            assign v_nom_razao_social = empresa.nom_razao_social.

        for each estabelecimento where 
                 estabelecimento.cod_empresa = tt_empresa.tta_cod_empresa no-lock:
            if v_log_restric_estab then do:
                for each tt_usuar_grp_usuar:
                   /* Verifica se o Usu†rio tem permiss∆o no Estabelecimento */
                    if not can-find(first segur_unid_organ where
                                            segur_unid_organ.cod_unid_organ = estabelecimento.cod_estab
                                       and (segur_unid_organ.cod_grp_usuar  = tt_usuar_grp_usuar.cod_grp_usuar
                                         or segur_unid_organ.cod_grp_usuar  = "*")) then 
                        next.

                    create tt_estabelecimento_empresa. 
                    assign tt_estabelecimento_empresa.tta_cod_estab        = estabelecimento.cod_estab
                           tt_estabelecimento_empresa.tta_nom_pessoa       = estabelecimento.nom_pessoa
                           tt_estabelecimento_empresa.tta_cod_empresa      = estabelecimento.cod_empresa
                           /* *****  ALTERACAO SOB DEMANDA PARA EVITAR MULTIPLOS ACESSOS A TABELA EMPRESA ******/
                           tt_estabelecimento_empresa.tta_nom_razao_social = v_nom_razao_social.
                    leave.
                end.
            end.
            else do:
                create tt_estabelecimento_empresa. 
                assign tt_estabelecimento_empresa.tta_cod_estab        = estabelecimento.cod_estab
                       tt_estabelecimento_empresa.tta_nom_pessoa       = estabelecimento.nom_pessoa
                       tt_estabelecimento_empresa.tta_cod_empresa      = estabelecimento.cod_empresa
                       /* *****  ALTERACAO SOB DEMANDA PARA EVITAR MULTIPLOS ACESSOS A TABELA EMPRESA ******/
                       tt_estabelecimento_empresa.tta_nom_razao_social = v_nom_razao_social.
            end.
        end.
    end.

    assign v_des_estab_select = "".
    for each tt_estabelecimento_empresa:
        if v_des_estab_select = "" then
            assign v_des_estab_select = tt_estabelecimento_empresa.tta_cod_estab.
        else
            assign v_des_estab_select = v_des_estab_select + "," + tt_estabelecimento_empresa.tta_cod_estab.
    end.
END PROCEDURE. /* pi_vld_permissao_usuar_estab_empres */
/*****************************************************************************
** Procedure Interna.....: pi_vld_estab_select
** Descricao.............: pi_vld_estab_select
** Criado por............: fut42625_3
** Criado em.............: 14/02/2011 14:06:27
** Alterado por..........: fut42625_3
** Alterado em...........: 14/02/2011 15:41:29
*****************************************************************************/
PROCEDURE pi_vld_estab_select:

    /************************ Parameter Definition Begin ************************/

    def Input param p_cod_modul
        as character
        format "x(3)"
        no-undo.


    /************************* Parameter Definition End *************************/

    /************************* Variable Definition Begin ************************/

    def var v_des_estab_select_aux
        as character
        format "x(2000)":U
        view-as editor max-chars 2000 no-word-wrap
        size 30 by 1
        bgcolor 15 font 2
        no-undo.
    def var v_num_cont_2
        as integer
        format ">>>>,>>9":U
        no-undo.


    /************************** Variable Definition End *************************/

    /* ===  Verificar se o usu†rio possui permiss∆o nos estabelecintos selecionados  === */
    assign v_des_estab_select_aux = v_des_estab_select.

    run pi_vld_permissao_usuar_estab_empres (Input p_cod_modul).
    assign v_des_estab_select = "" /*l_null*/ .

    do v_num_cont_2 = 1 to num-entries(v_des_estab_select_aux):
        find first estabelecimento no-lock
           where estabelecimento.cod_estab = entry(v_num_cont_2, v_des_estab_select_aux) no-error.
        if avail estabelecimento then do:
            if can-find(first tt_estabelecimento_empresa 
                where tt_estabelecimento_empresa.tta_cod_estab = estabelecimento.cod_estab) then do:
                if v_des_estab_select = "" then
                    assign v_des_estab_select = estabelecimento.cod_estab.
                else
                    assign v_des_estab_select = v_des_estab_select + "," + estabelecimento.cod_estab.
            end.
        end.
    end.
END PROCEDURE. /* pi_vld_estab_select */


/************************** Internal Procedure End **************************/

/************************* External Procedure Begin *************************/



/************************** External Procedure End **************************/

/*************************************  *************************************/
/*****************************************************************************
**  Procedure Interna: pi_print_editor
**  Descricao........: Imprime editores nos relat¢rios
*****************************************************************************/
PROCEDURE pi_print_editor:

    def input param p_stream    as char    no-undo.
    def input param p1_editor   as char    no-undo.
    def input param p1_pos      as char    no-undo.
    def input param p2_editor   as char    no-undo.
    def input param p2_pos      as char    no-undo.
    def input param p3_editor   as char    no-undo.
    def input param p3_pos      as char    no-undo.

    def var c_editor as char    extent 5             no-undo.
    def var l_first  as logical extent 5 initial yes no-undo.
    def var c_at     as char    extent 5             no-undo.
    def var i_pos    as integer extent 5             no-undo.
    def var i_len    as integer extent 5             no-undo.

    def var c_aux    as char               no-undo.
    def var i_aux    as integer            no-undo.
    def var c_ret    as char               no-undo.
    def var i_ind    as integer            no-undo.

    assign c_editor [1] = p1_editor
           c_at  [1]    =         substr(p1_pos,1,2)
           i_pos [1]    = integer(substr(p1_pos,3,3))
           i_len [1]    = integer(substr(p1_pos,6,3)) - 4
           c_editor [2] = p2_editor
           c_at  [2]    =         substr(p2_pos,1,2)
           i_pos [2]    = integer(substr(p2_pos,3,3))
           i_len [2]    = integer(substr(p2_pos,6,3)) - 4
           c_editor [3] = p3_editor
           c_at  [3]    =         substr(p3_pos,1,2)
           i_pos [3]    = integer(substr(p3_pos,3,3))
           i_len [3]    = integer(substr(p3_pos,6,3)) - 4
           c_ret        = chr(255) + chr(255).

    do while c_editor [1] <> "" or c_editor [2] <> "" or c_editor [3] <> "":
        do i_ind = 1 to 3:
            if c_editor[i_ind] <> "" then do:
                assign i_aux = index(c_editor[i_ind], chr(10)).
                if i_aux > i_len[i_ind] or (i_aux = 0 and length(c_editor[i_ind]) > i_len[i_ind]) then
                    assign i_aux = r-index(c_editor[i_ind], " ", i_len[i_ind] + 1).
                if i_aux = 0 then
                    assign c_aux = substr(c_editor[i_ind], 1, i_len[i_ind])
                           c_editor[i_ind] = substr(c_editor[i_ind], i_len[i_ind] + 1).
                else
                    assign c_aux = substr(c_editor[i_ind], 1, i_aux - 1)
                           c_editor[i_ind] = substr(c_editor[i_ind], i_aux + 1).
                if i_pos[1] = 0 then
                    assign entry(i_ind, c_ret, chr(255)) = c_aux.
                else
                    if l_first[i_ind] then
                        assign l_first[i_ind] = no.
                    else
                        case p_stream:
                            when "s_1" then
                                if c_at[i_ind] = "at" then
                                    put stream s_1 unformatted c_aux at i_pos[i_ind].
                                else
                                    put stream s_1 unformatted c_aux to i_pos[i_ind].
                        end.
            end.
        end.
        case p_stream:
        when "s_1" then
            put stream s_1 unformatted skip.
        end.
        if i_pos[1] = 0 then
            return c_ret.
    end.
    return c_ret.
END PROCEDURE.  /* pi_print_editor */
&endif

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
/*******************  End of rpt_tit_acr_antecip_prev_acr *******************/
