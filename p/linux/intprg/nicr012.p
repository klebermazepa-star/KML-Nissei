/*****************************************************************************
** Programa..............: NICR012
** Descricao.............: Base Demonstrativo Motivo Movimento ACR - Vale
** Versao................: LIBERADO
** Procedimento..........: NICR012
** Nome Externo..........: intprg/nicr012.p
** Criado por............: Cleyton Ricardo Neves
** Criado em.............: 22/09/2016 
*****************************************************************************/
DEFINE BUFFER empresa              FOR emscad.empresa.
DEFINE BUFFER histor_exec_especial FOR emscad.histor_exec_especial.
DEFINE BUFFER cliente              FOR emscad.cliente.

def var c-versao-prg as char initial "NICR012":U no-undo.

{include/i_dbinst.i}
{include/i_dbtype.i}

/* Alteracao via filtro - Controle de impressao - inicio */
{include/i_prdvers.i}
/* Alteracao via filtro - Controle de impressao - fim    */

{include/i_fcldef.i}


&IF "{&EMSFND_VERSION}" >= "1.00" &THEN
{include/i-license-manager.i NICR012 ACR}
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
                                    "NICR012","~~EMSFIN", "~~{~&emsfin_version}", "~~5.01")) /*msg_5009*/.
&else

/********************* Temporary Table Definition Begin *********************/

def temp-table tt_rpt_cotac_parid no-undo
    field ttv_rec_cotac_parid              as recid format ">>>>>>9"
    field ttv_cod_dwb_field_rpt            as character extent 9 format "x(32)" label "Conjunto" column-label "Conjunto"
    field tta_cod_indic_econ_base          as character format "x(8)" label "Moeda Base" column-label "Moeda Base"
    field tta_cod_indic_econ_idx           as character format "x(8)" label "Moeda ÷ndice" column-label "Moeda ÷ndice"
    field tta_ind_tip_cotac_parid          as character format "X(09)" label "Tipo Cotaá∆o" column-label "Tipo  Cotaá∆o"
    field tta_dat_cotac_indic_econ         as date format "99/99/9999" initial ? label "Data Cotaá∆o" column-label "Data Cotaá∆o"
    field tta_val_cotac_indic_econ         as decimal format ">>>>,>>9.9999999999" decimals 10 initial 0 label "Cotaá∆o" column-label "Cotaá∆o"
    index tt_rpt_cotac_parid               is primary unique
          ttv_rec_cotac_parid              ascending
    .

def temp-table tt_rpt_motiv_movto_tit_acr_dem no-undo like motiv_movto_tit_acr
    field tta_dat_transacao                as date format "99/99/9999" initial today label "Data Transaá∆o" column-label "Dat Transac"
    field tta_cod_estab                    as character format "x(3)" label "Estabelecimento" column-label "Estab"
    field tta_cod_ser_docto                as character format "x(3)" label "SÇrie Documento" column-label "SÇrie"
    field tta_cod_parcela                  as character format "x(02)" label "Parcela" column-label "Parc"
    field tta_dat_vencto_tit_acr           as date format "99/99/9999" initial ? label "Vencimento" column-label "Vencimento"
    field tta_val_movto_tit_acr            as decimal format "->>>,>>>,>>9.99" decimals 2 initial 0 label "Vl Movimento" column-label "Vl Movimento"
    field ttv_log_ok                       as logical format "Sim/N∆o" initial yes
    field tta_nom_pessoa                   as character format "x(40)" label "Nome" column-label "Nome"
    field tta_val_origin_tit_acr           as decimal format ">>>,>>>,>>9.99" decimals 2 initial 0 label "Vl Original T°tulo" column-label "Vl Original T°tulo"
    field tta_val_juros                    as decimal format ">>>>,>>>,>>9.99" decimals 2 initial 0 label "Valor Juros" column-label "Valor Juros"
    field tta_cod_espec_docto              as character format "x(3)" label "EspÇcie Documento" column-label "EspÇcie"
    field ttv_cod_dwb_field_rpt            as character extent 9 format "x(32)" label "Conjunto" column-label "Conjunto"
    field tta_cod_tit_acr                  as character format "x(10)" label "T°tulo" column-label "T°tulo"
    field ttv_val_motiv_movto_acr          as decimal format ">>>,>>>,>>9.99" decimals 2 label "Vl Custo Motivo" column-label "Vl Custo Motivo"
    field ttv_val_perc                     as decimal format ">,>>9.99" decimals 2 initial 0 label "Valor Percentual" column-label "Valor Percentual"
    field ttv_rec_motiv_movto_tit_acr      as recid format ">>>>>>9"
    field tta_cod_indic_econ               as character format "x(8)" label "Moeda" column-label "Moeda"
    FIELD ttv_cod_colaborador              AS INTEGER FORMAT "999999" INITIAL 0 COLUMN-LABEL "Colaborador" LABEL "Colaborador"
    FIELD ttv_nom_colaborador              AS CHARACTER FORMAT "x(100)" INITIAL "" COLUMN-LABEL "Nome Colaborador" LABEL "Nome Colaborador"
    index tt_indice                        is primary unique
          ttv_rec_motiv_movto_tit_acr      ascending
    .



/********************** Temporary Table Definition End **********************/

/************************** Buffer Definition Begin *************************/

&if "{&emsbas_version}" >= "1.00" &then
def buffer b_ped_exec_style
    for ped_exec.
&endif
&if "{&emsbas_version}" >= "1.00" &then
def buffer b_servid_exec_style
    for servid_exec.
&endif


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
def var v_cod_estab_dni_final
    as character
    format "x(5)":U
    label "atÇ"
    column-label "atÇ"
    no-undo.
def var v_cod_estab_dni_inic
    as character
    format "x(5)":U
    label "Estabelecimento"
    column-label "Estab"
    no-undo.
def var v_cod_colab_inic
    as INTEGER
    format "999999":U
    label "Colaborador"
    column-label "Colab"
    no-undo.
def var v_cod_colab_final
    as INTEGER
    format "999999":U
    label "Colaborador"
    column-label "Colab"
    no-undo.
def new global shared var v_cod_estab_usuar
    as character
    format "x(3)":U
    label "Estabelecimento"
    column-label "Estab"
    no-undo.
def var v_cod_finalid_econ_apres
    as character
    format "x(10)":U
    initial "Corrente" /*l_corrente*/
    label "Finalid Apresentaá∆o"
    column-label "Finalid Apresentaá∆o"
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
def var v_cod_indic_econ
    as character
    format "x(8)":U
    label "Moeda"
    column-label "Moeda"
    no-undo.
def var v_cod_indic_econ_base
    as character
    format "x(8)":U
    label "Moeda Base"
    column-label "Moeda Base"
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
def var v_cod_motiv_movto_tit_acr_fim
    as character
    format "x(8)":U
    label "Motivo Movimento"
    column-label "Motivo Movimento"
    no-undo.
def var v_cod_motiv_movto_tit_acr_ini
    as character
    format "x(8)":U
    label "Motivo Movimento"
    column-label "Motivo Movimento"
    no-undo.
def new global shared var v_cod_pais_empres_usuar
    as character
    format "x(3)":U
    label "Pa°s Empresa Usu†rio"
    column-label "Pa°s"
    no-undo.
def new global shared var v_cod_plano_ccusto_corren
    as character
    format "x(8)":U
    label "Plano CCusto"
    column-label "Plano CCusto"
    no-undo.
def new shared var v_cod_release
    as character
    format "x(12)":U
    no-undo.
def var v_cod_return
    as character
    format "x(40)":U
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
def var v_dat_movto_fim
    as date
    format "99/99/9999":U
    label "atÇ"
    no-undo.
def var v_dat_movto_inic
    as date
    format "99/99/9999":U
    initial &IF "{&ems_dbtype}":U = "MSS":U &THEN 01/01/1800 &ELSE 01/01/0001 &ENDIF
    label "Data Movimento"
    column-label "Data"
    no-undo.
def var v_dat_transacao
    as date
    format "99/99/9999":U
    label "Data Transaá∆o"
    column-label "Data Transaá∆o"
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
def var v_des_msg_abrev
    as character
    format "x(40)":U
    label "Descriá∆o"
    column-label "Descr"
    no-undo.
def var v_des_param
    as character
    format "x(50)":U
    label "Param"
    column-label "Param"
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
def var v_ind_tip_calc_juros
    as character
    format "X(10)":U
    initial "Simples" /*l_simples*/
    view-as combo-box
    list-items "Simples","Compostos"
     /*l_simples*/ /*l_compostos*/
    inner-lines 2
    bgcolor 15 font 2
    label "Tipo C†lculo Juros"
    column-label "Tipo C†lculo Juros"
    no-undo.
def new global shared var v_log_acerto_val_cr
    as logical
    format "Sim/N∆o"
    initial no
    view-as toggle-box
    label "Acerto Val a CrÇdito"
    no-undo.
def new global shared var v_log_acerto_val_db
    as logical
    format "Sim/N∆o"
    initial no
    view-as toggle-box
    label "acerto val DÇbito"
    no-undo.
def new global shared var v_log_acerto_val_maior
    as logical
    format "Sim/N∆o"
    initial yes
    view-as toggle-box
    label "Acerto val maior"
    no-undo.
def new global shared var v_log_acerto_val_menor
    as logical
    format "Sim/N∆o"
    initial no
    view-as toggle-box
    label "Acerto val Menor"
    no-undo.
def new global shared var v_log_alter_dat_emis
    as logical
    format "Sim/N∆o"
    initial no
    view-as toggle-box
    label "Alter data Emiss∆o"
    no-undo.
def new global shared var v_log_alter_dat_vencto
    as logical
    format "Sim/N∆o"
    initial yes
    view-as toggle-box
    label "Alter Data Vencto"
    no-undo.
def new global shared var v_log_alter_nao_ctbl
    as logical
    format "Sim/N∆o"
    initial no
    view-as toggle-box
    label "Alter n∆o Cont†bil"
    no-undo.
def new global shared var v_log_calc_cust
    as logical
    format "Sim/N∆o"
    initial no
    view-as toggle-box
    label "Calcula Custo"
    column-label "Calcula Custo"
    no-undo.
def new global shared var v_log_devol
    as logical
    format "Sim/N∆o"
    initial no
    view-as toggle-box
    label "Devoluá∆o"
    no-undo.
def new global shared var v_log_execution
    as logical
    format "Sim/N∆o"
    initial yes
    no-undo.
def var v_log_funcao_tip_calc_juros
    as logical
    format "Sim/N∆o"
    initial no
    no-undo.
def new global shared var v_log_impl
    as logical
    format "Sim/N∆o"
    initial no
    view-as toggle-box
    label "Implantaá∆o"
    no-undo.
def new global shared var v_log_impl_cr
    as logical
    format "Sim/N∆o"
    initial no
    view-as toggle-box
    label "Implantaá∆o CrÇdito"
    no-undo.
def var v_log_method
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
def new global shared var v_log_renegoc
    as logical
    format "Sim/N∆o"
    initial no
    view-as toggle-box
    label "Renegociaá∆o"
    no-undo.
def var v_log_return
    as logical
    format "Sim/N∆o"
    initial no
    no-undo.
def new global shared var v_log_subst_nota_dupl
    as logical
    format "Sim/N∆o"
    initial no
    view-as toggle-box
    label "Subst nota p/ Duplic"
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
def var v_num_dias_atraso
    as integer
    format "->>>>,>>9":U
    column-label "Dias/Atraso"
    no-undo.
def new shared var v_num_entry
    as integer
    format ">>>>,>>9":U
    label "Ordem"
    column-label "Ordem"
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
def var v_num_reg_criac_acr
    as integer
    format ">>>>,>>9":U
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
def new global shared var v_rec_motiv_movto_tit_acr
    as recid
    format ">>>>>>9":U
    no-undo.
def var v_rec_table_epc
    as recid
    format ">>>>>>9":U
    no-undo.
def var v_val_cotac_indic_econ
    as decimal
    format "->>,>>>,>>>,>>9.9999999999":U
    decimals 10
    label "Cotaá∆o"
    column-label "Cotaá∆o"
    no-undo.
def var v_val_juros_aux
    as decimal
    format ">>>>,>>>,>>9.99":U
    decimals 2
    label "Valor"
    column-label "Valor"
    no-undo.
def var v_val_motiv_movto_acr
    as decimal
    format ">>>,>>>,>>9.99":U
    decimals 2
    label "Vl Custo Motivo"
    column-label "Vl Custo Motivo"
    no-undo.
def var v_val_perc
    as decimal
    format ">,>>9.99":U
    decimals 2
    initial 0
    label "Valor Percentual"
    column-label "Valor Percentual"
    no-undo.
def var v_val_total
    as decimal
    format "->>>,>>>,>>9.99":U
    decimals 2
    label "Total %"
    column-label "Valor Total"
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

def rectangle rt_004
    size 1 by 1
    edge-pixels 2.
def rectangle rt_005
    size 1 by 1
    edge-pixels 2.
def rectangle rt_006
    size 1 by 1
    edge-pixels 2.
def rectangle rt_cxcf
    size 1 by 1
    fgcolor 1 edge-pixels 2.
def rectangle rt_dimensions
    size 1 by 1
    edge-pixels 2.
def rectangle rt_mold
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
def button bt_close
    label "&Fecha"
    tooltip "Fecha"
    size 1 by 1
    auto-go.
def button bt_fil2
    label "Fil"
    tooltip "Filtro"
&if "{&window-system}" <> "TTY" &then
    image-up file "image/im-fil"
    image-insensitive file "image/ii-fil"
&endif
    size 1 by 1.
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
def button bt_nenhum
    label "Nenhum"
    tooltip "Desmarca Todas Ocorràncias"
    size 1 by 1.
def button bt_ok
    label "OK"
    tooltip "OK"
    size 1 by 1
    auto-go.
def button bt_print
    label "&Imprime"
    tooltip "Imprime"
    size 1 by 1
    auto-go.
def button bt_set_printer
    label "Define Impressora e Layout"
    tooltip "Define Impressora e Layout de Impress∆o"
&if "{&window-system}" <> "TTY" &then
    image-up file "image/im-setpr.bmp"
    image-insensitive file "image/ii-setpr"
&endif
    size 1 by 1.
def button bt_todos
    label "Todos"
    tooltip "Marca Todas Ocorràncias"
    size 1 by 1.
/****************************** Function Button *****************************/
def button bt_zoo_203567
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


/************************* Radio-Set Definition End *************************/

/************************** Report Definition Begin *************************/

def new shared var v_rpt_s_1_lines as integer initial 66.
def new shared var v_rpt_s_1_columns as integer initial 172.
def new shared var v_rpt_s_1_bottom as integer initial 65.
def new shared var v_rpt_s_1_page as integer.
def new shared var v_rpt_s_1_name as character initial "Relat¢rio Motivos de Movimento".
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
def frame f_rpt_s_1_Grp_motivo_Lay_motivo header
    /* Atributo tt_rpt_motiv_movto_tit_acr_dem.cod_motiv_movto_tit_acr ignorado */
    "-" at 20
    /* Atributo tt_rpt_motiv_movto_tit_acr_dem.des_motiv_movto_tit_acr ignorado */ skip (1)
    with no-box no-labels width 172 page-top stream-io.
def frame f_rpt_s_1_Grp_parametros_Lay_param header
    "-----------------------------------" at 45
    "Apresentaá∆o  " at 81
    "-----------------------------------" at 96
    skip (1)
    "Apresentaá∆o: " at 77
    v_cod_finalid_econ_apres at 91 format "x(10)" view-as text
    skip (1)
    "Data Cotaá∆o: " at 77
    v_dat_cotac_indic_econ at 91 format "99/99/9999" view-as text
    skip (1)
    "------------------------------------" at 46
    "ParÉmetros" at 83
    "-----------------------------------" at 96
    skip (1)
    "-----------------------------" at 54
    "Transaá‰es" at 84
    "----------------------------" at 95
    skip (1)
    "    Acerto Val a CrÇdito: " at 54
    v_log_acerto_val_cr at 80 format "Sim/N∆o" view-as text
    "    Alter n∆o Cont†bil: " at 96
    v_log_alter_nao_ctbl at 120 format "Sim/N∆o" view-as text
    skip (1)
    "    acerto val DÇbito: " at 57
    v_log_acerto_val_db at 80 format "Sim/N∆o" view-as text
    "  Devoluá∆o: " at 107
    v_log_devol at 120 format "Sim/N∆o" view-as text
    skip (1)
    "    Acerto val maior: " at 58
    v_log_acerto_val_maior at 80 format "Sim/N∆o" view-as text
    "   Implantaá∆o: " at 104
    v_log_impl at 120 format "Sim/N∆o" view-as text
    skip (1)
    "    Acerto val Menor: " at 58
    v_log_acerto_val_menor at 80 format "Sim/N∆o" view-as text
    "    Implantaá∆o CrÇdito: " at 95
    v_log_impl_cr at 120 format "Sim/N∆o" view-as text
    skip (1)
    "    Alter data Emiss∆o: " at 56
    v_log_alter_dat_emis at 80 format "Sim/N∆o" view-as text
    "   Renegociaá∆o: " at 103
    v_log_renegoc at 120 format "Sim/N∆o" view-as text
    skip (1)
    "    Alter Data Vencto: " at 57
    v_log_alter_dat_vencto at 80 format "Sim/N∆o" view-as text
    "    Subst nota p/ Duplic: " at 94
    v_log_subst_nota_dupl at 120 format "Sim/N∆o" view-as text skip (9)
    with no-box no-labels width 172 page-top stream-io.
def frame f_rpt_s_1_Grp_parametros_Lay_parametros header skip (30)
    with no-box no-labels width 172 page-top stream-io.
def frame f_rpt_s_1_Grp_principal_Lay_Principal header
    "Dat Transac" at 1
&IF "{&emsfin_version}" >= "" AND "{&emsfin_version}" < "5.07A" &THEN
    "Estab" at 13
&ENDIF
&IF "{&emsfin_version}" >= "5.07A" AND "{&emsfin_version}" < "9.99" &THEN
    "Estab" at 13
&ENDIF
    "SÇrie" at 19
    "Esp" at 25
    "T°tulo" at 29
    "/P" at 46
    "Vl Original" to 63
    "Vl Movto" to 78 
    "Colaborador" TO 90 
    "Nome Colaborador" AT 92 
    SKIP
    "-----------" at 1
&IF "{&emsfin_version}" >= "" AND "{&emsfin_version}" < "5.07A" &THEN
    "-----" at 13
&ENDIF
&IF "{&emsfin_version}" >= "5.07A" AND "{&emsfin_version}" < "9.99" &THEN
    "-----" at 13
&ENDIF
    "-----" at 19
    "---" at 25
    "----------------" at 29
    "--" at 46
    "--------------" to 63
    "--------------" to 78 
    "-----------" to 90 
    "-----------------------------------------------------------------" AT 92
    skip
    with no-box no-labels width 172 page-top stream-io.
def frame f_rpt_s_1_Grp_total_Lay_total header
    "Total Geral" at 109
    v_num_reg_criac_acr to 128 format ">>>>,>>9" view-as text
    v_val_total to 147 format "->>>,>>>,>>9.99" view-as text skip
    with no-box no-labels width 172 page-top stream-io.


/*************************** Report Definition End **************************/

/************************** Frame Definition Begin **************************/

def frame f_ran_01_motiv_movto_tit_acr_dem
    rt_mold
         at row 01.21 col 02.00
    rt_cxcf
         at row 10.25 col 02.00 bgcolor 7 
    v_log_acerto_val_cr
         at row 02.25 col 07.14 label "Acerto Valor a CrÇdito"
         view-as toggle-box
    v_log_impl
         at row 02.25 col 47.29 label "Implantaá∆o"
         view-as toggle-box
    v_log_acerto_val_db
         at row 03.25 col 07.14 label "Acerto Valor a DÇbito"
         view-as toggle-box
    v_log_impl_cr
         at row 03.25 col 47.29 label "Implantaá∆o a crÇdito"
         view-as toggle-box
    v_log_acerto_val_maior
         at row 04.25 col 07.14 label "Acerto Valor Maior"
         view-as toggle-box
    v_log_devol
         at row 04.25 col 47.29 label "Devoluá∆o"
         view-as toggle-box
    v_log_acerto_val_menor
         at row 05.25 col 07.14 label "Acerto valor Menor"
         view-as toggle-box
    v_log_renegoc
         at row 05.25 col 47.29 label "Renegociaá∆o"
         view-as toggle-box
    v_log_alter_nao_ctbl
         at row 06.17 col 47.43 label "Alteraá∆o n∆o cont†bil"
         view-as toggle-box
    v_log_alter_dat_emis
         at row 06.25 col 07.14 label "Alteraá∆o Data Emiss∆o"
         view-as toggle-box
    v_log_subst_nota_dupl
         at row 07.17 col 07.14 label "Subtituiá∆o Nota por Duplicata"
         view-as toggle-box
    v_log_alter_dat_vencto
         at row 07.17 col 47.43 label "Alteraá∆o Data vencimento"
         view-as toggle-box
    bt_todos
         at row 08.29 col 07.43 font ?
         help "Marca Todas Ocorràncias"
    bt_nenhum
         at row 08.33 col 19.14 font ?
         help "Desmarca Todas Ocorràncias"
    bt_ok
         at row 10.46 col 03.00 font ?
         help "OK"
    bt_can
         at row 10.46 col 14.00 font ?
         help "Cancela"
    bt_hel2
         at row 10.46 col 66.72 font ?
         help "Ajuda"
    with 1 down side-labels no-validate keep-tab-order three-d
         size-char 79.14 by 12.08 default-button bt_ok
         view-as dialog-box
         font 1 fgcolor ? bgcolor 8
         title "Faixa - Motivo Movimento ACR".
    /* adjust size of objects in this frame */
    assign bt_can:width-chars     in frame f_ran_01_motiv_movto_tit_acr_dem = 10.00
           bt_can:height-chars    in frame f_ran_01_motiv_movto_tit_acr_dem = 01.00
           bt_hel2:width-chars    in frame f_ran_01_motiv_movto_tit_acr_dem = 10.00
           bt_hel2:height-chars   in frame f_ran_01_motiv_movto_tit_acr_dem = 01.00
           bt_nenhum:width-chars  in frame f_ran_01_motiv_movto_tit_acr_dem = 10.00
           bt_nenhum:height-chars in frame f_ran_01_motiv_movto_tit_acr_dem = 01.00
           bt_ok:width-chars      in frame f_ran_01_motiv_movto_tit_acr_dem = 10.00
           bt_ok:height-chars     in frame f_ran_01_motiv_movto_tit_acr_dem = 01.00
           bt_todos:width-chars   in frame f_ran_01_motiv_movto_tit_acr_dem = 10.00
           bt_todos:height-chars  in frame f_ran_01_motiv_movto_tit_acr_dem = 01.00
           rt_cxcf:width-chars    in frame f_ran_01_motiv_movto_tit_acr_dem = 75.72
           rt_cxcf:height-chars   in frame f_ran_01_motiv_movto_tit_acr_dem = 01.42
           rt_mold:width-chars    in frame f_ran_01_motiv_movto_tit_acr_dem = 75.72
           rt_mold:height-chars   in frame f_ran_01_motiv_movto_tit_acr_dem = 08.50.
    /* set private-data for the help system */
    assign v_log_acerto_val_cr:private-data    in frame f_ran_01_motiv_movto_tit_acr_dem = "HLP=000024084":U
           v_log_impl:private-data             in frame f_ran_01_motiv_movto_tit_acr_dem = "HLP=000024092":U
           v_log_acerto_val_db:private-data    in frame f_ran_01_motiv_movto_tit_acr_dem = "HLP=000024085":U
           v_log_impl_cr:private-data          in frame f_ran_01_motiv_movto_tit_acr_dem = "HLP=000024093":U
           v_log_acerto_val_maior:private-data in frame f_ran_01_motiv_movto_tit_acr_dem = "HLP=000024086":U
           v_log_devol:private-data            in frame f_ran_01_motiv_movto_tit_acr_dem = "HLP=000024091":U
           v_log_acerto_val_menor:private-data in frame f_ran_01_motiv_movto_tit_acr_dem = "HLP=000024087":U
           v_log_renegoc:private-data          in frame f_ran_01_motiv_movto_tit_acr_dem = "HLP=000024094":U
           v_log_alter_nao_ctbl:private-data   in frame f_ran_01_motiv_movto_tit_acr_dem = "HLP=000024090":U
           v_log_alter_dat_emis:private-data   in frame f_ran_01_motiv_movto_tit_acr_dem = "HLP=000024088":U
           v_log_subst_nota_dupl:private-data  in frame f_ran_01_motiv_movto_tit_acr_dem = "HLP=000024095":U
           v_log_alter_dat_vencto:private-data in frame f_ran_01_motiv_movto_tit_acr_dem = "HLP=000024089":U
           bt_todos:private-data               in frame f_ran_01_motiv_movto_tit_acr_dem = "HLP=000013336":U
           bt_nenhum:private-data              in frame f_ran_01_motiv_movto_tit_acr_dem = "HLP=000013335":U
           bt_ok:private-data                  in frame f_ran_01_motiv_movto_tit_acr_dem = "HLP=000010721":U
           bt_can:private-data                 in frame f_ran_01_motiv_movto_tit_acr_dem = "HLP=000011050":U
           bt_hel2:private-data                in frame f_ran_01_motiv_movto_tit_acr_dem = "HLP=000011326":U
           frame f_ran_01_motiv_movto_tit_acr_dem:private-data                           = "HLP=000018563".

def frame f_rpt_41_motiv_movto_tit_acr_dem
    rt_005
         at row 01.42 col 02.14
    " Seleá∆o " view-as text
         at row 01.12 col 04.14 bgcolor 8 
    rt_006
         at row 01.42 col 82.29
    rt_004
         at row 01.46 col 44.14
    " Apresentaá∆o " view-as text
         at row 01.16 col 46.14 bgcolor 8 
    rt_target
         at row 05.63 col 02.00
    " Destino " view-as text
         at row 05.33 col 04.00 bgcolor 8 
    rt_run
         at row 05.63 col 48.00
    " Execuá∆o " view-as text
         at row 05.33 col 50.00
    rt_dimensions
         at row 05.63 col 72.72
    " Dimens‰es " view-as text
         at row 05.33 col 74.72
    rt_cxcf
         at row 09.13 col 02.00 bgcolor 7 
    v_cod_estab_dni_inic
         at row 01.68 col 13.43 colon-aligned label "Estab"
         help "Estabelecimento Inicial"
         view-as fill-in
         size-chars 6 by .80
         fgcolor ? bgcolor 15 font 2
    v_cod_estab_dni_final
         at row 01.68 col 28.72 colon-aligned label "atÇ"
         help "Estabelecimento Final"
         view-as fill-in
         size-chars 6 by .80
         fgcolor ? bgcolor 15 font 2
    v_dat_movto_inic
         at row 02.55 col 13.43 colon-aligned label "Data Movto"
         view-as fill-in
         size-chars 11.14 by .80
         fgcolor ? bgcolor 15 font 2
    v_dat_movto_fim
         at row 02.55 col 28.72 colon-aligned label "atÇ"
         view-as fill-in
         size-chars 11.14 by .80
         fgcolor ? bgcolor 15 font 2
    v_cod_motiv_movto_tit_acr_ini
         at row 03.45 col 13.43 colon-aligned label "Motivo"
         help "C¢digo Motivo Movimento T°tulo"
         view-as fill-in
         size-chars 9.14 by .80
         fgcolor ? bgcolor 15 font 2
    v_cod_motiv_movto_tit_acr_fim
         at row 03.45 col 28.57 colon-aligned label "atÇ"
         help "C¢digo Motivo Movimento T°tulo"
         view-as fill-in
         size-chars 9.14 by .80
         fgcolor ? bgcolor 15 font 2
    v_cod_colab_inic
         at row 04.35 col 13.43 colon-aligned label "Colaborador"
         help "C¢digo do Colaborador do Vale"
         view-as fill-in
         size-chars 8 by .80
         fgcolor ? bgcolor 15 font 2
    v_cod_colab_final
         at row 04.35 col 28.57 colon-aligned label "atÇ"
         help "C¢digo do Colaborador do Vale"
         view-as fill-in
         SIZE-CHARS 8 by .80
         fgcolor ? bgcolor 15 font 2
    v_cod_finalid_econ_apres
         at row 02.58 col 63.86 colon-aligned label "Finalid Apresentaá∆o"
         view-as fill-in
         size-chars 11.14 by .88
         fgcolor ? bgcolor 15 font 2
    bt_zoo_203567
         at row 02.58 col 77.00
    v_dat_cotac_indic_econ
         at row 03.67 col 63.72 colon-aligned label "Data Cotaá∆o"
         view-as fill-in
         size-chars 11.14 by .88
         fgcolor ? bgcolor 15 font 2
    rs_cod_dwb_output
         at row 06.33 col 03.00
         help "" no-label
    rs_ind_run_mode
         at row 06.33 col 49.00
         help "" no-label
    v_qtd_line
         at row 06.33 col 81.00 colon-aligned
         view-as fill-in
         size-chars 4.14 by .88
         fgcolor ? bgcolor 15 font 2
    ed_1x40
         at row 07.29 col 03.00
         help "" no-label
    bt_set_printer
         at row 07.29 col 42.00 font ?
         help "Define Impressora e Layout de Impress∆o"
    bt_get_file
         at row 07.29 col 42.00 font ?
         help "Pesquisa Arquivo"
    v_log_print_par
         at row 07.33 col 49.00 label "Imprime ParÉmetros"
         view-as toggle-box
    v_qtd_column
         at row 07.33 col 81.00 colon-aligned
         view-as fill-in
         size-chars 4.14 by .88
         fgcolor ? bgcolor 15 font 2
    bt_close
         at row 09.33 col 03.00 font ?
         help "Fecha"
    bt_print
         at row 09.33 col 14.00 font ?
         help "Imprime"
    bt_can
         at row 09.33 col 25.00 font ?
         help "Cancela"
    bt_hel2
         at row 09.33 col 77.57 font ?
         help "Ajuda"
    bt_fil2
         at row 02.83 col 83.29 font ?
         help "Filtro"
    with 1 down side-labels no-validate keep-tab-order three-d
         size-char 90.00 by 10.96
         view-as dialog-box
         font 1 fgcolor ? bgcolor 8
         title "Demonstrativo Motivo Movimento ACR".
    /* adjust size of objects in this frame */
    assign bt_can:width-chars          in frame f_rpt_41_motiv_movto_tit_acr_dem = 10.00
           bt_can:height-chars         in frame f_rpt_41_motiv_movto_tit_acr_dem = 01.00
           bt_close:width-chars        in frame f_rpt_41_motiv_movto_tit_acr_dem = 10.00
           bt_close:height-chars       in frame f_rpt_41_motiv_movto_tit_acr_dem = 01.00
           bt_fil2:width-chars         in frame f_rpt_41_motiv_movto_tit_acr_dem = 04.00
           bt_fil2:height-chars        in frame f_rpt_41_motiv_movto_tit_acr_dem = 01.13
           bt_get_file:width-chars     in frame f_rpt_41_motiv_movto_tit_acr_dem = 04.00
           bt_get_file:height-chars    in frame f_rpt_41_motiv_movto_tit_acr_dem = 01.08
           bt_hel2:width-chars         in frame f_rpt_41_motiv_movto_tit_acr_dem = 10.00
           bt_hel2:height-chars        in frame f_rpt_41_motiv_movto_tit_acr_dem = 01.00
           bt_print:width-chars        in frame f_rpt_41_motiv_movto_tit_acr_dem = 10.00
           bt_print:height-chars       in frame f_rpt_41_motiv_movto_tit_acr_dem = 01.00
           bt_set_printer:width-chars  in frame f_rpt_41_motiv_movto_tit_acr_dem = 04.00
           bt_set_printer:height-chars in frame f_rpt_41_motiv_movto_tit_acr_dem = 01.08
           ed_1x40:width-chars         in frame f_rpt_41_motiv_movto_tit_acr_dem = 38.00
           ed_1x40:height-chars        in frame f_rpt_41_motiv_movto_tit_acr_dem = 01.00
           rt_004:width-chars          in frame f_rpt_41_motiv_movto_tit_acr_dem = 37.72
           rt_004:height-chars         in frame f_rpt_41_motiv_movto_tit_acr_dem = 03.79
           rt_005:width-chars          in frame f_rpt_41_motiv_movto_tit_acr_dem = 41.00
           rt_005:height-chars         in frame f_rpt_41_motiv_movto_tit_acr_dem = 03.83
           rt_006:width-chars          in frame f_rpt_41_motiv_movto_tit_acr_dem = 06.14
           rt_006:height-chars         in frame f_rpt_41_motiv_movto_tit_acr_dem = 03.83
           rt_cxcf:width-chars         in frame f_rpt_41_motiv_movto_tit_acr_dem = 86.57
           rt_cxcf:height-chars        in frame f_rpt_41_motiv_movto_tit_acr_dem = 01.42
           rt_dimensions:width-chars   in frame f_rpt_41_motiv_movto_tit_acr_dem = 15.72
           rt_dimensions:height-chars  in frame f_rpt_41_motiv_movto_tit_acr_dem = 03.00
           rt_run:width-chars          in frame f_rpt_41_motiv_movto_tit_acr_dem = 23.86
           rt_run:height-chars         in frame f_rpt_41_motiv_movto_tit_acr_dem = 03.00
           rt_target:width-chars       in frame f_rpt_41_motiv_movto_tit_acr_dem = 45.00
           rt_target:height-chars      in frame f_rpt_41_motiv_movto_tit_acr_dem = 03.00.
    /* set return-inserted = yes for editors */
    assign ed_1x40:return-inserted in frame f_rpt_41_motiv_movto_tit_acr_dem = yes.
    /* set private-data for the help system */
    assign v_cod_estab_dni_inic:private-data          in frame f_rpt_41_motiv_movto_tit_acr_dem = "HLP=000023852":U
           v_cod_estab_dni_final:private-data         in frame f_rpt_41_motiv_movto_tit_acr_dem = "HLP=000023853":U
           v_dat_movto_inic:private-data              in frame f_rpt_41_motiv_movto_tit_acr_dem = "HLP=000023978":U
           v_dat_movto_fim:private-data               in frame f_rpt_41_motiv_movto_tit_acr_dem = "HLP=000023979":U
           v_cod_motiv_movto_tit_acr_ini:private-data in frame f_rpt_41_motiv_movto_tit_acr_dem = "HLP=000024083":U
           v_cod_motiv_movto_tit_acr_fim:private-data in frame f_rpt_41_motiv_movto_tit_acr_dem = "HLP=000024071":U
           bt_zoo_203567:private-data                 in frame f_rpt_41_motiv_movto_tit_acr_dem = "HLP=000009431":U
           v_cod_finalid_econ_apres:private-data      in frame f_rpt_41_motiv_movto_tit_acr_dem = "HLP=000014663":U
           v_dat_cotac_indic_econ:private-data        in frame f_rpt_41_motiv_movto_tit_acr_dem = "HLP=000012264":U
           rs_cod_dwb_output:private-data             in frame f_rpt_41_motiv_movto_tit_acr_dem = "HLP=000018563":U
           rs_ind_run_mode:private-data               in frame f_rpt_41_motiv_movto_tit_acr_dem = "HLP=000018563":U
           v_qtd_line:private-data                    in frame f_rpt_41_motiv_movto_tit_acr_dem = "HLP=000024737":U
           ed_1x40:private-data                       in frame f_rpt_41_motiv_movto_tit_acr_dem = "HLP=000018563":U
           bt_set_printer:private-data                in frame f_rpt_41_motiv_movto_tit_acr_dem = "HLP=000008785":U
           bt_get_file:private-data                   in frame f_rpt_41_motiv_movto_tit_acr_dem = "HLP=000008782":U
           v_log_print_par:private-data               in frame f_rpt_41_motiv_movto_tit_acr_dem = "HLP=000024662":U
           v_qtd_column:private-data                  in frame f_rpt_41_motiv_movto_tit_acr_dem = "HLP=000024669":U
           bt_close:private-data                      in frame f_rpt_41_motiv_movto_tit_acr_dem = "HLP=000009420":U
           bt_print:private-data                      in frame f_rpt_41_motiv_movto_tit_acr_dem = "HLP=000010815":U
           bt_can:private-data                        in frame f_rpt_41_motiv_movto_tit_acr_dem = "HLP=000011050":U
           bt_hel2:private-data                       in frame f_rpt_41_motiv_movto_tit_acr_dem = "HLP=000011326":U
           bt_fil2:private-data                       in frame f_rpt_41_motiv_movto_tit_acr_dem = "HLP=000008766":U
           frame f_rpt_41_motiv_movto_tit_acr_dem:private-data                                  = "HLP=000018563".
    /* enable function buttons */
    assign bt_zoo_203567:sensitive in frame f_rpt_41_motiv_movto_tit_acr_dem = yes.




{include/i_fclfrm.i f_ran_01_motiv_movto_tit_acr_dem f_rpt_41_motiv_movto_tit_acr_dem }
/*************************** Frame Definition End ***************************/

/* tech38629 - Alteraá∆o efetuada via filtro */
&if '{&emsbas_version}':U >= '5.05':U &then
def var v_prog_filtro_pdf as handle no-undo.

function getCodTipoRelat returns character in v_prog_filtro_pdf.

run prgtec/btb/btb920aa.py persistent set v_prog_filtro_pdf.

run pi_define_objetos in v_prog_filtro_pdf (frame f_rpt_41_motiv_movto_tit_acr_dem:handle,
                       rs_cod_dwb_output:handle in frame f_rpt_41_motiv_movto_tit_acr_dem,
                       bt_get_file:row in frame f_rpt_41_motiv_movto_tit_acr_dem,
                       bt_get_file:col in frame f_rpt_41_motiv_movto_tit_acr_dem).

&endif
/* tech38629 - Fim da alteraá∆o */


/*********************** User Interface Trigger Begin ***********************/


ON CHOOSE OF bt_hel2 IN FRAME f_ran_01_motiv_movto_tit_acr_dem
DO:


    /* Begin_Include: i_context_help_frame */
    run prgtec/men/men900za.py (Input self:frame,
                                Input this-procedure:handle) /*prg_fnc_chamar_help_context*/.


    /* End_Include: i_context_help_frame */

END. /* ON CHOOSE OF bt_hel2 IN FRAME f_ran_01_motiv_movto_tit_acr_dem */

ON CHOOSE OF bt_nenhum IN FRAME f_ran_01_motiv_movto_tit_acr_dem
DO:

    assign
          v_log_acerto_val_cr:checked = no
          v_log_acerto_val_db:checked = no
          v_log_acerto_val_maior:checked = no
          v_log_acerto_val_menor:checked = no
          v_log_alter_dat_emis:checked = no
          v_log_alter_dat_vencto:checked = no
          v_log_alter_nao_ctbl:checked = no
          v_log_devol:checked = no
          v_log_impl:checked = no
          v_log_impl_cr:checked = no
          v_log_renegoc:checked = no
          v_log_subst_nota_dupl:checked = no.
END. /* ON CHOOSE OF bt_nenhum IN FRAME f_ran_01_motiv_movto_tit_acr_dem */

ON CHOOSE OF bt_ok IN FRAME f_ran_01_motiv_movto_tit_acr_dem
DO:

    assign input frame f_ran_01_motiv_movto_tit_acr_dem v_log_acerto_val_cr
           input frame f_ran_01_motiv_movto_tit_acr_dem v_log_acerto_val_db
           input frame f_ran_01_motiv_movto_tit_acr_dem v_log_acerto_val_maior
           input frame f_ran_01_motiv_movto_tit_acr_dem v_log_acerto_val_menor
           input frame f_ran_01_motiv_movto_tit_acr_dem v_log_alter_dat_emis
           input frame f_ran_01_motiv_movto_tit_acr_dem v_log_alter_dat_vencto
           input frame f_ran_01_motiv_movto_tit_acr_dem v_log_alter_nao_ctbl
           input frame f_ran_01_motiv_movto_tit_acr_dem v_log_devol
           input frame f_ran_01_motiv_movto_tit_acr_dem v_log_impl
           input frame f_ran_01_motiv_movto_tit_acr_dem v_log_impl_cr
           input frame f_ran_01_motiv_movto_tit_acr_dem v_log_renegoc
           input frame f_ran_01_motiv_movto_tit_acr_dem v_log_subst_nota_dupl.

END. /* ON CHOOSE OF bt_ok IN FRAME f_ran_01_motiv_movto_tit_acr_dem */

ON CHOOSE OF bt_todos IN FRAME f_ran_01_motiv_movto_tit_acr_dem
DO:

    assign
          v_log_acerto_val_cr:checked = yes
          v_log_acerto_val_db:checked = yes
          v_log_acerto_val_maior:checked = yes
          v_log_acerto_val_menor:checked = yes
          v_log_alter_dat_emis:checked = yes
          v_log_alter_dat_vencto:checked = yes
          v_log_alter_nao_ctbl:checked = yes
          v_log_devol:checked = yes
          v_log_impl:checked = yes
          v_log_impl_cr:checked = yes
          v_log_renegoc:checked = yes
          v_log_subst_nota_dupl:checked = yes.


END. /* ON CHOOSE OF bt_todos IN FRAME f_ran_01_motiv_movto_tit_acr_dem */

ON CHOOSE OF bt_fil2 IN FRAME f_rpt_41_motiv_movto_tit_acr_dem
DO:

    view frame f_ran_01_motiv_movto_tit_acr_dem.

    filter_block:
    do on error undo filter_block, retry filter_block:
        update bt_todos
               bt_nenhum
               bt_can
               bt_hel2
               bt_ok
               v_log_acerto_val_cr
               v_log_acerto_val_db
               v_log_acerto_val_maior
               v_log_acerto_val_menor
               v_log_alter_dat_emis
               v_log_alter_dat_vencto
               v_log_alter_nao_ctbl
               v_log_devol
               v_log_impl
               v_log_impl_cr
               v_log_renegoc
               v_log_subst_nota_dupl
               with frame f_ran_01_motiv_movto_tit_acr_dem.


    end /* do filter_block */.


    hide frame  f_ran_01_motiv_movto_tit_acr_dem.



END. /* ON CHOOSE OF bt_fil2 IN FRAME f_rpt_41_motiv_movto_tit_acr_dem */

ON CHOOSE OF bt_get_file IN FRAME f_rpt_41_motiv_movto_tit_acr_dem
DO:

    system-dialog get-file v_cod_dwb_file
        title "Imprimir" /*l_imprimir*/ 
        filters '*.rpt' '*.rpt',
                "*.*"   "*.*"
        save-as
        create-test-file
        ask-overwrite.
        assign dwb_rpt_param.cod_dwb_file             = v_cod_dwb_file
               ed_1x40:screen-value in frame f_rpt_41_motiv_movto_tit_acr_dem = v_cod_dwb_file.

END. /* ON CHOOSE OF bt_get_file IN FRAME f_rpt_41_motiv_movto_tit_acr_dem */

ON CHOOSE OF bt_hel2 IN FRAME f_rpt_41_motiv_movto_tit_acr_dem
DO:


    /* Begin_Include: i_context_help_frame */
    run prgtec/men/men900za.py (Input self:frame,
                                Input this-procedure:handle) /*prg_fnc_chamar_help_context*/.


    /* End_Include: i_context_help_frame */

END. /* ON CHOOSE OF bt_hel2 IN FRAME f_rpt_41_motiv_movto_tit_acr_dem */

ON CHOOSE OF bt_print IN FRAME f_rpt_41_motiv_movto_tit_acr_dem
DO:

    if  v_log_acerto_val_cr = no and
        v_log_acerto_val_db = no and
        v_log_acerto_val_maior = no and
        v_log_acerto_val_menor = no and
        v_log_alter_dat_emis = no and
        v_log_alter_dat_vencto = no and
        v_log_alter_nao_ctbl = no and
        v_log_devol = no and
        v_log_impl = no and
        v_log_impl_cr = no and
        v_log_renegoc = no and
        v_log_subst_nota_dupl = no
    then do:

        /* &1 deve ser informado(a). */
        run pi_messages (input "show",
                         input 9612,
                         input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9",
                                            "Motivo Movimento" /*l_motivo_movimento*/)) /*msg_9612*/.
        return no-apply.
    end.

do:
/* tech38629 - Alteraá∆o efetuada via filtro */
&if '{&emsbas_version}':U >= '5.05':U &then
    run pi_restricoes in v_prog_filtro_pdf (input rs_cod_dwb_output:screen-value in frame f_rpt_41_motiv_movto_tit_acr_dem).
    if return-value = 'nok' then 
        return no-apply.
&endif
/* tech38629 - Fim da alteraá∆o */
    assign v_log_print = yes.
end.
END. /* ON CHOOSE OF bt_print IN FRAME f_rpt_41_motiv_movto_tit_acr_dem */

ON CHOOSE OF bt_set_printer IN FRAME f_rpt_41_motiv_movto_tit_acr_dem
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
               ed_1x40:screen-value in frame f_rpt_41_motiv_movto_tit_acr_dem = v_nom_dwb_printer
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
                with frame f_rpt_41_motiv_movto_tit_acr_dem.
    end /* if */.

END. /* ON CHOOSE OF bt_set_printer IN FRAME f_rpt_41_motiv_movto_tit_acr_dem */

ON LEAVE OF ed_1x40 IN FRAME f_rpt_41_motiv_movto_tit_acr_dem
DO:

    /************************* Variable Definition Begin ************************/

    def var v_cod_filename_final             as character       no-undo. /*local*/
    def var v_cod_filename_initial           as character       no-undo. /*local*/


    /************************** Variable Definition End *************************/

    block:
    do with frame f_rpt_41_motiv_movto_tit_acr_dem:
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

END. /* ON LEAVE OF ed_1x40 IN FRAME f_rpt_41_motiv_movto_tit_acr_dem */

ON VALUE-CHANGED OF rs_cod_dwb_output IN FRAME f_rpt_41_motiv_movto_tit_acr_dem
DO:

    initout:
    do with frame f_rpt_41_motiv_movto_tit_acr_dem:
        /* block: */
        case self:screen-value:
            when "Terminal" /*l_terminal*/ then ter:
             do:
                if  rs_cod_dwb_output <> "Impressora" /*l_printer*/ 
                then do:
                    assign v_qtd_line_ant = input frame f_rpt_41_motiv_movto_tit_acr_dem v_qtd_line.
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
                        with frame f_rpt_41_motiv_movto_tit_acr_dem.
                assign ed_1x40:screen-value   = ""
                       ed_1x40:sensitive      = no
                       bt_get_file:visible    = no
                       bt_set_printer:visible = no.
            end /* do ter */.
            when "Arquivo" /*l_file*/ then fil:
             do:
                if  rs_cod_dwb_output <> "Impressora" /*l_printer*/ 
                then do:
                    assign v_qtd_line_ant = input frame f_rpt_41_motiv_movto_tit_acr_dem v_qtd_line.
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
                        with frame f_rpt_41_motiv_movto_tit_acr_dem.
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

                    if  rs_ind_run_mode:screen-value in frame f_rpt_41_motiv_movto_tit_acr_dem <> "Batch" /*l_batch*/ 
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
                                                          + caps("nicr012":U)
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
                    assign v_qtd_line_ant = input frame f_rpt_41_motiv_movto_tit_acr_dem v_qtd_line.
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
                        with frame f_rpt_41_motiv_movto_tit_acr_dem.
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
                with frame f_rpt_41_motiv_movto_tit_acr_dem.
    end /* if */.
    else do:
        enable v_qtd_line
               with frame f_rpt_41_motiv_movto_tit_acr_dem.
    end /* else */.
    assign rs_cod_dwb_output.
END. /* ON VALUE-CHANGED OF rs_cod_dwb_output IN FRAME f_rpt_41_motiv_movto_tit_acr_dem */

ON VALUE-CHANGED OF rs_ind_run_mode IN FRAME f_rpt_41_motiv_movto_tit_acr_dem
DO:

    do  transaction:
        find dwb_rpt_param
            where dwb_rpt_param.cod_dwb_user    = v_cod_usuar_corren
            and   dwb_rpt_param.cod_dwb_program = v_cod_dwb_program
            exclusive-lock no-error.
        assign dwb_rpt_param.ind_dwb_run_mode = input frame f_rpt_41_motiv_movto_tit_acr_dem rs_ind_run_mode.

        if  dwb_rpt_param.ind_dwb_run_mode = "Batch" /*l_batch*/ 
        then do:
            if  rs_cod_dwb_output:disable("Terminal" /*l_terminal*/ ) in frame f_rpt_41_motiv_movto_tit_acr_dem
            then do:
            end /* if */.
        end /* if */.
        else do:
            if  rs_cod_dwb_output:enable("Terminal" /*l_terminal*/ ) in frame f_rpt_41_motiv_movto_tit_acr_dem
            then do:
            end /* if */.
        end /* else */.
        if  rs_ind_run_mode = "Batch" /*l_batch*/ 
        then do:
           assign v_qtd_line = v_qtd_line_ant.
           display v_qtd_line
                   with frame f_rpt_41_motiv_movto_tit_acr_dem.
        end /* if */.
        assign rs_ind_run_mode.
        apply "value-changed" to rs_cod_dwb_output in frame f_rpt_41_motiv_movto_tit_acr_dem.
    end.    

END. /* ON VALUE-CHANGED OF rs_ind_run_mode IN FRAME f_rpt_41_motiv_movto_tit_acr_dem */


/************************ User Interface Trigger End ************************/

/************************** Function Trigger Begin **************************/


ON  CHOOSE OF bt_zoo_203567 IN FRAME f_rpt_41_motiv_movto_tit_acr_dem
OR F5 OF v_cod_finalid_econ_apres IN FRAME f_rpt_41_motiv_movto_tit_acr_dem DO:

    /* Zoom de vari†vel sem referencia para o usuario */
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
        assign v_cod_finalid_econ_apres:screen-value in frame f_rpt_41_motiv_movto_tit_acr_dem =
               string(finalid_econ.cod_finalid_econ).
        apply "entry" to v_cod_finalid_econ_apres in frame f_rpt_41_motiv_movto_tit_acr_dem.
    end /* if */.

end. /* ON  CHOOSE OF bt_zoo_203567 IN FRAME f_rpt_41_motiv_movto_tit_acr_dem */


/*************************** Function Trigger End ***************************/

/**************************** Frame Trigger Begin ***************************/


ON HELP OF FRAME f_ran_01_motiv_movto_tit_acr_dem ANYWHERE
DO:


    /* Begin_Include: i_context_help */
    run prgtec/men/men900za.py (Input self:handle,
                                Input this-procedure:handle) /*prg_fnc_chamar_help_context*/.
    /* End_Include: i_context_help */

END. /* ON HELP OF FRAME f_ran_01_motiv_movto_tit_acr_dem */

ON RIGHT-MOUSE-DOWN OF FRAME f_ran_01_motiv_movto_tit_acr_dem ANYWHERE
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

END. /* ON RIGHT-MOUSE-DOWN OF FRAME f_ran_01_motiv_movto_tit_acr_dem */

ON RIGHT-MOUSE-UP OF FRAME f_ran_01_motiv_movto_tit_acr_dem ANYWHERE
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

END. /* ON RIGHT-MOUSE-UP OF FRAME f_ran_01_motiv_movto_tit_acr_dem */

ON WINDOW-CLOSE OF FRAME f_ran_01_motiv_movto_tit_acr_dem
DO:

    apply "end-error" to self.
END. /* ON WINDOW-CLOSE OF FRAME f_ran_01_motiv_movto_tit_acr_dem */

ON ENDKEY OF FRAME f_rpt_41_motiv_movto_tit_acr_dem
DO:


    /* Begin_Include: i_exec_program_epc */
    &if '{&emsbas_version}' > '1.00' &then
    if  v_nom_prog_upc <> '' then
    do:
        assign v_rec_table_epc = recid(motiv_movto_tit_acr).
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
        assign v_rec_table_epc = recid(motiv_movto_tit_acr).
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
        assign v_rec_table_epc = recid(motiv_movto_tit_acr).
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

END. /* ON ENDKEY OF FRAME f_rpt_41_motiv_movto_tit_acr_dem */

ON GO OF FRAME f_rpt_41_motiv_movto_tit_acr_dem
DO:

    do transaction:
        find dwb_rpt_param
            where dwb_rpt_param.cod_dwb_user    = v_cod_usuar_corren
            and   dwb_rpt_param.cod_dwb_program = v_cod_dwb_program
            exclusive-lock no-error.
        assign dwb_rpt_param.cod_dwb_output     = rs_cod_dwb_output:screen-value in frame f_rpt_41_motiv_movto_tit_acr_dem
               dwb_rpt_param.qtd_dwb_line       = input frame f_rpt_41_motiv_movto_tit_acr_dem v_qtd_line
    &if '{&emsbas_version}' > '1.00' &then
    &if '{&emsbas_version}' >= '5.03' &then
               dwb_rpt_param.nom_dwb_print_file = v_nom_dwb_print_file
    &else
               dwb_rpt_param.cod_livre_1 = v_nom_dwb_print_file
    &endif
    &endif
    .
        if  dwb_rpt_param.cod_dwb_output = "Arquivo" /*l_file*/ 
        then do:
             run pi_filename_validation (Input dwb_rpt_param.cod_dwb_file) /*pi_filename_validation*/.
             if  dwb_rpt_param.ind_dwb_run_mode <> "Batch" /*l_batch*/ 
             then do:
                 if  index  ( dwb_rpt_param.cod_dwb_file ,'~\') <> 0
                 then do:
                      assign file-info:file-name= substring( dwb_rpt_param.cod_dwb_file ,
                                                             1,
                                                             r-index  ( dwb_rpt_param.cod_dwb_file ,'~\') - 1
                                                            ).
                 end /* if */.
                 else do:
                      assign file-info:file-name= substring( dwb_rpt_param.cod_dwb_file ,
                                                             1,
                                                             r-index  ( dwb_rpt_param.cod_dwb_file ,'/') - 1
                                                            ).
                 end /* else */.
                 if  (  file-info:file-type = ? )
                 and    (  index  ( dwb_rpt_param.cod_dwb_file ,'~\') <> 0
                              or
                           index  ( dwb_rpt_param.cod_dwb_file ,'/')  <> 0
                              or
                           index  ( dwb_rpt_param.cod_dwb_file ,':')  <> 0
                         )
                 then do:
                     /* O diret¢rio &1 n∆o existe ! */
                     run pi_messages (input "show",
                                      input 4354,
                                      input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9",
                                                         file-info:file-name)) /*msg_4354*/.
                     return no-apply.
                  end /* if */.
             end /* if */.
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
                if  not avail layout_impres
                then do:
                   /* Layout de impress∆o inexistente ! */
                   run pi_messages (input "show",
                                    input 4366,
                                    input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")) /*msg_4366*/.
                   return no-apply.
                end /* if */.
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
    end.    

END. /* ON GO OF FRAME f_rpt_41_motiv_movto_tit_acr_dem */

ON HELP OF FRAME f_rpt_41_motiv_movto_tit_acr_dem ANYWHERE
DO:


    /* Begin_Include: i_context_help */
    run prgtec/men/men900za.py (Input self:handle,
                                Input this-procedure:handle) /*prg_fnc_chamar_help_context*/.
    /* End_Include: i_context_help */

END. /* ON HELP OF FRAME f_rpt_41_motiv_movto_tit_acr_dem */

ON RIGHT-MOUSE-DOWN OF FRAME f_rpt_41_motiv_movto_tit_acr_dem ANYWHERE
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

END. /* ON RIGHT-MOUSE-DOWN OF FRAME f_rpt_41_motiv_movto_tit_acr_dem */

ON RIGHT-MOUSE-UP OF FRAME f_rpt_41_motiv_movto_tit_acr_dem ANYWHERE
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

END. /* ON RIGHT-MOUSE-UP OF FRAME f_rpt_41_motiv_movto_tit_acr_dem */

ON WINDOW-CLOSE OF FRAME f_rpt_41_motiv_movto_tit_acr_dem
DO:

    apply "end-error" to self.
END. /* ON WINDOW-CLOSE OF FRAME f_rpt_41_motiv_movto_tit_acr_dem */


/***************************** Frame Trigger End ****************************/

/**************************** Menu Trigger Begin ****************************/


ON CHOOSE OF MENU-ITEM mi_conteudo IN MENU m_help
DO:


        apply "choose" to bt_hel2 in frame f_rpt_41_motiv_movto_tit_acr_dem.





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


        assign v_nom_prog     = substring(frame f_rpt_41_motiv_movto_tit_acr_dem:title, 1, max(1, length(frame f_rpt_41_motiv_movto_tit_acr_dem:title) - 10)).
        if  v_nom_prog = ? then
            assign v_nom_prog = "".

        assign v_nom_prog     = v_nom_prog
                              + chr(10)
                              + "NICR012":U.




    assign v_nom_prog_ext = "intprg/nicr012.p":U
           v_cod_release  = trim(" FURO_CAIXA":U).
/*    run prgtec/btb/btb901zb.p (Input v_nom_prog,
                               Input v_nom_prog_ext,
                               Input v_cod_release) /*prg_fnc_about*/. */
{include/sobre5.i}
END. /* ON CHOOSE OF MENU-ITEM mi_sobre IN MENU m_help */


/***************************** Menu Trigger End *****************************/


/****************************** Main Code Begin *****************************/


/* Begin_Include: i_version_extract */
{include/i-ctrlrp5.i NICR012}


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
    run pi_version_extract ('NICR012':U, 'intprg/nicr012.p':U, 'FURO_CAIXA':U, 'pro':U).
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
    run prgtec/men/men901za.py (Input 'NICR012') /*prg_fnc_verify_security*/.
if  return-value = "2014"
then do:
    /* Programa a ser executado n∆o Ç um programa v†lido Datasul ! */
    run pi_messages (input "show",
                     input 2014,
                     input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9",
                                       'NICR012')) /*msg_2014*/.
    return.
end /* if */.
if  return-value = "2012"
then do:
    /* Usu†rio sem permiss∆o para acessar o programa. */
    run pi_messages (input "show",
                     input 2012,
                     input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9",
                                       'NICR012')) /*msg_2012*/.
    return.
end /* if */.
/* End_Include: i_verify_security */



/* Begin_Include: i_log_exec_prog_dtsul_ini */
assign v_rec_log = ?.

if can-find(prog_dtsul
       where prog_dtsul.cod_prog_dtsul = 'NICR012' 
         and prog_dtsul.log_gera_log_exec = yes) then do transaction:
    create log_exec_prog_dtsul.
    assign log_exec_prog_dtsul.cod_prog_dtsul           = 'NICR012'
           log_exec_prog_dtsul.cod_usuario              = v_cod_usuar_corren
           log_exec_prog_dtsul.dat_inic_exec_prog_dtsul = today
           log_exec_prog_dtsul.hra_inic_exec_prog_dtsul = replace(string(time,"hh:mm:ss" /*l_hh:mm:ss*/ ),":":U,"":U).
    assign v_rec_log = recid(log_exec_prog_dtsul).
    release log_exec_prog_dtsul no-error.
end.


/* End_Include: i_log_exec_prog_dtsul_ini */

/* tech38629 - Alteraá∆o efetuada via filtro */
&if '{&emsbas_version}':U >= '5.05':U &then
run pi_permissoes in v_prog_filtro_pdf (input 'NICR012':U).
&endif
/* tech38629 - Fim da alteraá∆o */




/* Begin_Include: i_verify_program_epc */
&if '{&emsbas_version}' > '1.00' &then
assign v_rec_table_epc = ?
       v_wgh_frame_epc = ?.

find prog_dtsul
    where prog_dtsul.cod_prog_dtsul = "NICR012":U
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


assign v_wgh_frame_epc = frame f_rpt_41_motiv_movto_tit_acr_dem:handle.



assign v_nom_table_epc = 'motiv_movto_tit_acr':U
       v_rec_table_epc = recid(motiv_movto_tit_acr).

&endif

/* End_Include: i_verify_program_epc */


/* redefiniá‰es do frame */

/* Begin_Include: i_std_dialog_box */
/* tratamento do titulo e vers∆o */
assign frame f_rpt_41_motiv_movto_tit_acr_dem:title = frame f_rpt_41_motiv_movto_tit_acr_dem:title
                            + chr(32)
                            + chr(40)
                            + trim(" FURO_CAIXA":U)
                            + chr(41).
/* menu pop-up de ajuda e sobre */
assign menu m_help:popup-only = yes
       bt_hel2:popup-menu in frame f_rpt_41_motiv_movto_tit_acr_dem = menu m_help:handle.


/* End_Include: i_std_dialog_box */
{include/title5.i f_rpt_41_motiv_movto_tit_acr_dem FRAME}


/* inicializa vari†veis */
find empresa no-lock
     where empresa.cod_empresa = v_cod_empres_usuar /*cl_empres_usuar of empresa*/ no-error.
find dwb_rpt_param
     where dwb_rpt_param.cod_dwb_program = "rel_movto_acr_motiv":U
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
assign v_cod_dwb_proced   = "rel_movto_acr_motiv":U
       v_cod_dwb_program  = "rel_movto_acr_motiv":U
       v_cod_release      = trim(" FURO_CAIXA":U)
       v_ind_dwb_run_mode = "On-Line" /*l_online*/ 
       v_qtd_column       = v_rpt_s_1_columns
       v_qtd_bottom       = v_rpt_s_1_bottom.
if (avail empresa) then
    assign v_nom_enterprise   = empresa.nom_razao_social.
else
    assign v_nom_enterprise   = 'DATASUL'.


/* Begin_Include: ix_p00_rpt_motiv_movto_tit_acr_dem */
assign v_cod_estab_dni_inic           = ""
       v_cod_estab_dni_final          = "zzzzz" /*l_zzz*/ 
       v_cod_motiv_movto_tit_acr_fim  = ""
       v_cod_motiv_movto_tit_acr_fim  = "ZZZZZZZZ" /*l_zzzzzzzz*/ 
       v_dat_movto_inic               = today
       v_dat_movto_fim                = today
       v_cod_finalid_econ_apres       = "Corrente" /*l_corrente*/ 
       v_dat_cotac_indic_econ         = today
       v_cod_colab_inic               = 0
       v_cod_colab_final              = 999999 .

/* Begin_Include: i_verifica_funcao_tip_calc_juros */
&if defined(bf_fin_tip_calc_juros) &then
    assign v_log_funcao_tip_calc_juros = yes.
&else
    find histor_exec_especial no-lock
        where histor_exec_especial.cod_modul_dtsul = "UFN" /*l_ufn*/ 
          and histor_exec_especial.cod_prog_dtsul  = "spp_tip_calc_juros" /*l_spp_tip_cal_juros*/  no-error.
    if  avail histor_exec_especial then
        assign v_log_funcao_tip_calc_juros = yes.

    /* Begin_Include: i_funcao_extract */
    if  v_cod_arq <> '' and v_cod_arq <> ?
    then do:

        output stream s-arq to value(v_cod_arq) append.

        put stream s-arq unformatted
            "spp_tip_calc_juros" /* l_spp_tip_cal_juros*/      at 1 
            v_log_funcao_tip_calc_juros  at 43 skip.

        output stream s-arq close.

    end /* if */.
    /* End_Include: i_funcao_extract */

&endif
/* End_Include: i_funcao_extract */

/* End_Include: i_funcao_extract */


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
    if (ped_exec.cod_release_prog_dtsul <> trim(" FURO_CAIXA":U)) then
        return "Vers‰es do programa diferente." /*1994*/ + " (" + "1994" + ")" + chr(10)
                                     + substitute("A vers∆o do programa (&3) que gerou o pedido de execuá∆o batch (&1) Ç diferente da vers∆o do programa que deveria executar o pedido batch (&2)." /*1994*/,ped_exec.cod_release_prog_dtsul,
                                                  trim(" FURO_CAIXA":U),
                                                  "intprg/nicr012.p":U).
    assign v_nom_prog_ext     = caps("nicr012":U)
           v_dat_execution    = today
           v_hra_execution    = replace(string(time, "hh:mm:ss" /*l_hh:mm:ss*/ ), ":", "")
           v_cod_dwb_file     = dwb_rpt_param.cod_dwb_file
           v_nom_report_title = fill(" ", 40 - length(v_rpt_s_1_name)) + v_rpt_s_1_name
           v_ind_dwb_run_mode = "Batch" /*l_batch*/ .


    /* Begin_Include: ix_p02_rpt_motiv_movto_tit_acr_dem */
    assign v_cod_estab_dni_final         = entry(1, dwb_rpt_param.cod_dwb_parameters, chr(10))
           v_cod_estab_dni_inic          = entry(2, dwb_rpt_param.cod_dwb_parameters, chr(10))
           v_cod_finalid_econ_apres      = entry(3, dwb_rpt_param.cod_dwb_parameters, chr(10))
           v_cod_motiv_movto_tit_acr_fim = entry(4, dwb_rpt_param.cod_dwb_parameters, chr(10))
           v_cod_motiv_movto_tit_acr_ini = entry(5, dwb_rpt_param.cod_dwb_parameters, chr(10))
           v_dat_cotac_indic_econ        = date(entry(6, dwb_rpt_param.cod_dwb_parameters, chr(10))) 
           v_dat_movto_fim               = date(entry(7, dwb_rpt_param.cod_dwb_parameters, chr(10)))
           v_dat_movto_inic              = date(entry(8, dwb_rpt_param.cod_dwb_parameters, chr(10)))
           v_log_acerto_val_cr           = (entry(9, dwb_rpt_param.cod_dwb_parameters, chr(10)) = "yes" /*l_yes*/ )
           v_log_acerto_val_db           = (entry(10, dwb_rpt_param.cod_dwb_parameters, chr(10)) = "yes" /*l_yes*/ )
           v_log_acerto_val_maior        = (entry(11, dwb_rpt_param.cod_dwb_parameters, chr(10)) = "yes" /*l_yes*/ )
           v_log_acerto_val_menor        = (entry(12, dwb_rpt_param.cod_dwb_parameters, chr(10)) = "yes" /*l_yes*/ )
           v_log_alter_dat_emis          = (entry(13, dwb_rpt_param.cod_dwb_parameters, chr(10)) = "yes" /*l_yes*/ )
           v_log_alter_dat_vencto        = (entry(14, dwb_rpt_param.cod_dwb_parameters, chr(10)) = "yes" /*l_yes*/ )
           v_log_alter_nao_ctbl          = (entry(15, dwb_rpt_param.cod_dwb_parameters, chr(10)) = "yes" /*l_yes*/ )
           v_log_devol                   = (entry(16, dwb_rpt_param.cod_dwb_parameters, chr(10)) = "yes" /*l_yes*/ )
           v_log_impl                    = (entry(17, dwb_rpt_param.cod_dwb_parameters, chr(10)) = "yes" /*l_yes*/ )
           v_log_impl_cr                 = (entry(18, dwb_rpt_param.cod_dwb_parameters, chr(10)) = "yes" /*l_yes*/ )
           v_log_renegoc                 = (entry(19, dwb_rpt_param.cod_dwb_parameters, chr(10)) = "yes" /*l_yes*/ )
           v_log_subst_nota_dupl         = (entry(20, dwb_rpt_param.cod_dwb_parameters, chr(10)) = "yes" /*l_yes*/ ).

    /* End_Include: ix_p02_rpt_motiv_movto_tit_acr_dem */


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

        /* ix_p29_rpt_motiv_movto_tit_acr_dem */

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


        /* Begin_Include: ix_p30_rpt_motiv_movto_tit_acr_dem */
        if (line-counter(s_1) + 30) > v_rpt_s_1_bottom then
            page stream s_1.
        put stream s_1 unformatted 
            "-----------------------------------" at 45
            "Apresentaá∆o  " at 81
            "-----------------------------------" at 96
            skip (1)
            "Apresentaá∆o: " at 77
            v_cod_finalid_econ_apres at 91 format "x(10)"
            skip (1).
        put stream s_1 unformatted 
            "Data Cotaá∆o: " at 77
            v_dat_cotac_indic_econ at 91 format "99/99/9999"
            skip (1)
            "------------------------------------" at 46
            "ParÉmetros" at 83
            "-----------------------------------" at 96
            skip (1)
            "-----------------------------" at 54
            "Transaá‰es" at 84
            "----------------------------" at 95.
        put stream s_1 unformatted 
            skip (1)
            "    Acerto Val a CrÇdito: " at 54
            v_log_acerto_val_cr at 80 format "Sim/N∆o"
            "    Alter n∆o Cont†bil: " at 96
            v_log_alter_nao_ctbl at 120 format "Sim/N∆o"
            skip (1)
            "    acerto val DÇbito: " at 57
            v_log_acerto_val_db at 80 format "Sim/N∆o"
            "  Devoluá∆o: " at 107
            v_log_devol at 120 format "Sim/N∆o".
        put stream s_1 unformatted 
            skip (1)
            "    Acerto val maior: " at 58
            v_log_acerto_val_maior at 80 format "Sim/N∆o"
            "   Implantaá∆o: " at 104
            v_log_impl at 120 format "Sim/N∆o"
            skip (1)
            "    Acerto val Menor: " at 58
            v_log_acerto_val_menor at 80 format "Sim/N∆o"
            "    Implantaá∆o CrÇdito: " at 95
            v_log_impl_cr at 120 format "Sim/N∆o".
        put stream s_1 unformatted 
            skip (1)
            "    Alter data Emiss∆o: " at 56
            v_log_alter_dat_emis at 80 format "Sim/N∆o"
            "   Renegociaá∆o: " at 103
            v_log_renegoc at 120 format "Sim/N∆o"
            skip (1)
            "    Alter Data Vencto: " at 57
            v_log_alter_dat_vencto at 80 format "Sim/N∆o"
            "    Subst nota p/ Duplic: " at 94
            v_log_subst_nota_dupl at 120 format "Sim/N∆o" skip (9).
        /* End_Include: ix_p30_rpt_motiv_movto_tit_acr_dem */


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
view frame f_rpt_41_motiv_movto_tit_acr_dem.

/* Begin_Include: i_exec_program_epc */
&if '{&emsbas_version}' > '1.00' &then
if  v_nom_prog_upc <> '' then
do:
    assign v_rec_table_epc = recid(motiv_movto_tit_acr).
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
    assign v_rec_table_epc = recid(motiv_movto_tit_acr).
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
    assign v_rec_table_epc = recid(motiv_movto_tit_acr).
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
    do with frame f_rpt_41_motiv_movto_tit_acr_dem:
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
                with frame f_rpt_41_motiv_movto_tit_acr_dem.
    end /* do init */.

    display v_qtd_column
            v_qtd_line
            with frame f_rpt_41_motiv_movto_tit_acr_dem.


    /* Begin_Include: i_exec_program_epc */
    &if '{&emsbas_version}' > '1.00' &then
    if  v_nom_prog_upc <> '' then
    do:
        assign v_rec_table_epc = recid(motiv_movto_tit_acr).
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
        assign v_rec_table_epc = recid(motiv_movto_tit_acr).
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
        assign v_rec_table_epc = recid(motiv_movto_tit_acr).
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
           bt_get_file
           bt_set_printer
           bt_close
           bt_print
           bt_can
           bt_hel2
           v_cod_estab_dni_inic
           v_cod_estab_dni_final
           v_dat_movto_inic
           v_cod_colab_inic
           v_cod_colab_final
           v_dat_movto_fim
           v_cod_motiv_movto_tit_acr_ini
           v_cod_motiv_movto_tit_acr_fim
           v_cod_finalid_econ_apres
           v_dat_cotac_indic_econ
           bt_fil2
           with frame f_rpt_41_motiv_movto_tit_acr_dem.


    /* Begin_Include: i_exec_program_epc */
    &if '{&emsbas_version}' > '1.00' &then
    if  v_nom_prog_upc <> '' then
    do:
        assign v_rec_table_epc = recid(motiv_movto_tit_acr).
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
        assign v_rec_table_epc = recid(motiv_movto_tit_acr).
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
        assign v_rec_table_epc = recid(motiv_movto_tit_acr).
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



    apply "value-changed" to rs_cod_dwb_output in frame f_rpt_41_motiv_movto_tit_acr_dem.


    if  yes = yes
    then do:
       enable rs_ind_run_mode
              with frame f_rpt_41_motiv_movto_tit_acr_dem.
       apply "value-changed" to rs_ind_run_mode in frame f_rpt_41_motiv_movto_tit_acr_dem.
    end /* if */.



    /* Begin_Include: ix_p10_rpt_motiv_movto_tit_acr_dem */
    if  dwb_rpt_param.cod_dwb_parameters <> " " and num-entries(dwb_rpt_param.cod_dwb_parameters, chr(10))= 20
    then do:
    assign v_cod_estab_dni_final         = entry(1, dwb_rpt_param.cod_dwb_parameters, chr(10))
           v_cod_estab_dni_inic          = entry(2, dwb_rpt_param.cod_dwb_parameters, chr(10))
           v_cod_finalid_econ_apres      = entry(3, dwb_rpt_param.cod_dwb_parameters, chr(10))
           v_cod_motiv_movto_tit_acr_fim = entry(4, dwb_rpt_param.cod_dwb_parameters, chr(10))
           v_cod_motiv_movto_tit_acr_ini = entry(5, dwb_rpt_param.cod_dwb_parameters, chr(10))
           v_dat_cotac_indic_econ        = date(entry(6, dwb_rpt_param.cod_dwb_parameters, chr(10))) 
           v_dat_movto_fim               = date(entry(7, dwb_rpt_param.cod_dwb_parameters, chr(10)))
           v_dat_movto_inic              = date(entry(8, dwb_rpt_param.cod_dwb_parameters, chr(10)))
           v_log_acerto_val_cr           = (entry(9, dwb_rpt_param.cod_dwb_parameters, chr(10)) = "yes" /*l_yes*/ )
           v_log_acerto_val_db           = (entry(10, dwb_rpt_param.cod_dwb_parameters, chr(10)) = "yes" /*l_yes*/ )
           v_log_acerto_val_maior        = (entry(11, dwb_rpt_param.cod_dwb_parameters, chr(10)) = "yes" /*l_yes*/ )
           v_log_acerto_val_menor        = (entry(12, dwb_rpt_param.cod_dwb_parameters, chr(10)) = "yes" /*l_yes*/ )
           v_log_alter_dat_emis          = (entry(13, dwb_rpt_param.cod_dwb_parameters, chr(10)) = "yes" /*l_yes*/ )
           v_log_alter_dat_vencto        = (entry(14, dwb_rpt_param.cod_dwb_parameters, chr(10)) = "yes" /*l_yes*/ )
           v_log_alter_nao_ctbl          = (entry(15, dwb_rpt_param.cod_dwb_parameters, chr(10)) = "yes" /*l_yes*/ )
           v_log_devol                   = (entry(16, dwb_rpt_param.cod_dwb_parameters, chr(10)) = "yes" /*l_yes*/ )
           v_log_impl                    = (entry(17, dwb_rpt_param.cod_dwb_parameters, chr(10)) = "yes" /*l_yes*/ )
           v_log_impl_cr                 = (entry(18, dwb_rpt_param.cod_dwb_parameters, chr(10)) = "yes" /*l_yes*/ )
           v_log_renegoc                 = (entry(19, dwb_rpt_param.cod_dwb_parameters, chr(10)) = "yes" /*l_yes*/ )
           v_log_subst_nota_dupl         = (entry(20, dwb_rpt_param.cod_dwb_parameters, chr(10)) = "yes" /*l_yes*/ ).

    end /* if */.

    display v_cod_estab_dni_final
            v_cod_estab_dni_inic
            v_cod_finalid_econ_apres
            v_cod_motiv_movto_tit_acr_fim
            v_cod_motiv_movto_tit_acr_ini
            v_dat_cotac_indic_econ
            v_dat_movto_fim
            v_dat_movto_inic
            v_cod_colab_inic
            v_cod_colab_final
            with frame f_rpt_41_motiv_movto_tit_acr_dem.       


    /* End_Include: ix_p10_rpt_motiv_movto_tit_acr_dem */


    block1:
    repeat on error undo block1, retry block1:

        main_block:
        repeat on error undo super_block, retry super_block
                        on endkey undo super_block, leave super_block
                        on stop undo super_block, retry super_block
                        with frame f_rpt_41_motiv_movto_tit_acr_dem:

            if (retry) then
                output stream s_1 close.
            assign v_log_print = no.
            if  valid-handle(v_wgh_focus) then
                wait-for go of frame f_rpt_41_motiv_movto_tit_acr_dem focus v_wgh_focus.
            else
                wait-for go of frame f_rpt_41_motiv_movto_tit_acr_dem.

            param_block:
            do transaction:

                /* Begin_Include: ix_p15_rpt_motiv_movto_tit_acr_dem */
                assign input frame f_rpt_41_motiv_movto_tit_acr_dem v_cod_estab_dni_final
                       input frame f_rpt_41_motiv_movto_tit_acr_dem v_cod_estab_dni_inic
                       input frame f_rpt_41_motiv_movto_tit_acr_dem v_cod_finalid_econ_apres
                       input frame f_rpt_41_motiv_movto_tit_acr_dem v_cod_motiv_movto_tit_acr_fim
                       input frame f_rpt_41_motiv_movto_tit_acr_dem v_cod_motiv_movto_tit_acr_ini
                       input frame f_rpt_41_motiv_movto_tit_acr_dem v_dat_cotac_indic_econ
                       input frame f_rpt_41_motiv_movto_tit_acr_dem v_dat_movto_fim
                       input frame f_rpt_41_motiv_movto_tit_acr_dem v_dat_movto_inic
                       input frame f_rpt_41_motiv_movto_tit_acr_dem v_cod_colab_inic
                       input frame f_rpt_41_motiv_movto_tit_acr_dem v_cod_colab_final
                    .

                find finalid_econ no-lock where
                     finalid_econ.cod_finalid_econ = input frame f_rpt_41_motiv_movto_tit_acr_dem v_cod_finalid_econ_apres no-error.

                if  not avail finalid_econ
                then do:
                    /* &1 inexistente ! */
                    run pi_messages (input "show",
                                     input 1284,
                                     input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9",
                                                       "Finalidade Econìmica","Finalidades Econìmicas")) /*msg_1284*/.
                    assign v_wgh_focus = v_cod_finalid_econ_apres:handle in frame f_rpt_41_motiv_movto_tit_acr_dem.
                    undo main_block, retry main_block.
                end /* if */.

                assign v_cod_indic_econ_base = "".
                run pi_retornar_indic_econ_finalid (Input input frame f_rpt_41_motiv_movto_tit_acr_dem v_cod_finalid_econ_apres,
                                                    Input input frame f_rpt_41_motiv_movto_tit_acr_dem v_dat_cotac_indic_econ,
                                                    output v_cod_indic_econ_base) /*pi_retornar_indic_econ_finalid*/.

                /* **
                 Valida faixas
                ***/
                if  v_cod_estab_dni_inic > v_cod_estab_dni_final then do:
                    /* &1 Inicial deve ser menor ou igual a &1 Final ! */
                    run pi_messages (input "show",
                                     input 5123,
                                     input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9",
                                                        "Estabelecimento")) /*msg_5123*/.
                    assign v_wgh_focus = v_cod_estab_dni_inic:handle in frame f_rpt_41_motiv_movto_tit_acr_dem.
                    undo main_block, retry main_block.
                end.
                if  v_dat_movto_inic > v_dat_movto_fim then do:
                    /* &1 Inicial deve ser menor ou igual a &1 Final ! */
                    run pi_messages (input "show",
                                     input 5123,
                                     input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9",
                                                        "Data Movimento")) /*msg_5123*/.
                    assign v_wgh_focus = v_dat_movto_inic:handle in frame f_rpt_41_motiv_movto_tit_acr_dem.
                    undo main_block, retry main_block.
                end.
                if  v_cod_motiv_movto_tit_acr_ini > v_cod_motiv_movto_tit_acr_fim then do:
                    /* &1 Inicial deve ser menor ou igual a &1 Final ! */
                    run pi_messages (input "show",
                                     input 5123,
                                     input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9",
                                                        "Motivo Movimento")) /*msg_5123*/.
                    assign v_wgh_focus = v_cod_motiv_movto_tit_acr_ini:handle in frame f_rpt_41_motiv_movto_tit_acr_dem.
                    undo main_block, retry main_block.
                end.
                /* End_Include: ix_p15_rpt_motiv_movto_tit_acr_dem */

                assign dwb_rpt_param.log_dwb_print_parameters = input frame f_rpt_41_motiv_movto_tit_acr_dem v_log_print_par
                       dwb_rpt_param.ind_dwb_run_mode         = input frame f_rpt_41_motiv_movto_tit_acr_dem rs_ind_run_mode
                       input frame f_rpt_41_motiv_movto_tit_acr_dem v_qtd_line.

                assign dwb_rpt_param.cod_dwb_parameters =        v_cod_estab_dni_final + chr(10) +         
       v_cod_estab_dni_inic  + chr(10) +          
       v_cod_finalid_econ_apres  + chr(10) +     
       v_cod_motiv_movto_tit_acr_fim  + chr(10) +
       v_cod_motiv_movto_tit_acr_ini  + chr(10) +
string(v_dat_cotac_indic_econ) + chr(10) +
string(v_dat_movto_fim) + chr(10) +      
string(v_dat_movto_inic) + chr(10) +      
string(v_log_acerto_val_cr) + chr(10) +          
string(v_log_acerto_val_db) + chr(10) +          
string(v_log_acerto_val_maior) + chr(10) +        
string(v_log_acerto_val_menor) + chr(10) +       
string(v_log_alter_dat_emis) + chr(10) +         
string(v_log_alter_dat_vencto) + chr(10) +       
string(v_log_alter_nao_ctbl) + chr(10) +        
string(v_log_devol) + chr(10) +                  
string(v_log_impl) + chr(10) +                   
string(v_log_impl_cr) + chr(10) +                
string(v_log_renegoc) + chr(10) +                
string(v_log_subst_nota_dupl)   
.

                /* ix_p20_rpt_motiv_movto_tit_acr_dem */
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
                            assign v_cod_dwb_file   = session:temp-directory + "nicr012" + '.tmp'
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
                    assign v_nom_prog_ext  = "nicr012"
                           v_cod_release   = trim(" FURO_CAIXA":U)
                           v_dat_execution = today
                           v_hra_execution = replace(string(time,"hh:mm:ss" /*l_hh:mm:ss*/ ),":","").
                    run pi_rpt_motiv_movto_tit_acr_dem /*pi_rpt_motiv_movto_tit_acr_dem*/.
                end /* else */.
                if  dwb_rpt_param.log_dwb_print_parameters = yes
                then do:
                    if (page-number (s_1) > 0) then
                        page stream s_1.
                    /* ix_p29_rpt_motiv_movto_tit_acr_dem */    
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

                    /* Begin_Include: ix_p30_rpt_motiv_movto_tit_acr_dem */
                    if (line-counter(s_1) + 30) > v_rpt_s_1_bottom then
                        page stream s_1.
                    put stream s_1 unformatted 
                        "-----------------------------------" at 45
                        "Apresentaá∆o  " at 81
                        "-----------------------------------" at 96
                        skip (1)
                        "Apresentaá∆o: " at 77
                        v_cod_finalid_econ_apres at 91 format "x(10)"
                        skip (1).
                    put stream s_1 unformatted 
                        "Data Cotaá∆o: " at 77
                        v_dat_cotac_indic_econ at 91 format "99/99/9999"
                        skip (1)
                        "------------------------------------" at 46
                        "ParÉmetros" at 83
                        "-----------------------------------" at 96
                        skip (1)
                        "-----------------------------" at 54
                        "Transaá‰es" at 84
                        "----------------------------" at 95.
                    put stream s_1 unformatted 
                        skip (1)
                        "    Acerto Val a CrÇdito: " at 54
                        v_log_acerto_val_cr at 80 format "Sim/N∆o"
                        "    Alter n∆o Cont†bil: " at 96
                        v_log_alter_nao_ctbl at 120 format "Sim/N∆o"
                        skip (1)
                        "    acerto val DÇbito: " at 57
                        v_log_acerto_val_db at 80 format "Sim/N∆o"
                        "  Devoluá∆o: " at 107
                        v_log_devol at 120 format "Sim/N∆o".
                    put stream s_1 unformatted 
                        skip (1)
                        "    Acerto val maior: " at 58
                        v_log_acerto_val_maior at 80 format "Sim/N∆o"
                        "   Implantaá∆o: " at 104
                        v_log_impl at 120 format "Sim/N∆o"
                        skip (1)
                        "    Acerto val Menor: " at 58
                        v_log_acerto_val_menor at 80 format "Sim/N∆o"
                        "    Implantaá∆o CrÇdito: " at 95
                        v_log_impl_cr at 120 format "Sim/N∆o".
                    put stream s_1 unformatted 
                        skip (1)
                        "    Alter data Emiss∆o: " at 56
                        v_log_alter_dat_emis at 80 format "Sim/N∆o"
                        "   Renegociaá∆o: " at 103
                        v_log_renegoc at 120 format "Sim/N∆o"
                        skip (1)
                        "    Alter Data Vencto: " at 57
                        v_log_alter_dat_vencto at 80 format "Sim/N∆o"
                        "    Subst nota p/ Duplic: " at 94
                        v_log_subst_nota_dupl at 120 format "Sim/N∆o" skip (9).
                    /* End_Include: ix_p30_rpt_motiv_movto_tit_acr_dem */

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
                                                 input rs_cod_dwb_output:screen-value in frame f_rpt_41_motiv_movto_tit_acr_dem,
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

        /* ix_p32_rpt_motiv_movto_tit_acr_dem */

        if  v_num_ped_exec <> 0
        then do:
            /* Criado pedido &1 para execuá∆o batch. */
            run pi_messages (input "show",
                             input 3556,
                             input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9",
                                                v_num_ped_exec)) /*msg_3556*/.
            assign v_num_ped_exec = 0.
        end /* if */.

        /* ix_p35_rpt_motiv_movto_tit_acr_dem */

    end /* repeat block1 */.
end /* repeat super_block */.

/* ix_p40_rpt_motiv_movto_tit_acr_dem */

hide frame f_rpt_41_motiv_movto_tit_acr_dem.

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

    if  index(v_cod_1, "~/~/") > 0
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
    do with frame f_rpt_41_motiv_movto_tit_acr_dem:

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

    run pi_rpt_motiv_movto_tit_acr_dem /*pi_rpt_motiv_movto_tit_acr_dem*/.
END PROCEDURE. /* pi_output_reports */
/*****************************************************************************
** Procedure Interna.....: pi_rpt_motiv_movto_tit_acr_dem
** Descricao.............: pi_rpt_motiv_movto_tit_acr_dem
** Criado por............: borba
** Criado em.............: 07/05/1997 09:17:55
** Alterado por..........: Claudia
** Alterado em...........: 13/08/1997 17:17:33
*****************************************************************************/
PROCEDURE pi_rpt_motiv_movto_tit_acr_dem:

    run pi_ler_tt_motiv_movto_tit_acr_dem.

    assign v_des_mensagem      = ""
           v_num_reg_criac_acr = 0
           v_val_total = 0.

    hide stream s_1 frame f_rpt_s_1_header_period.
    view stream s_1 frame f_rpt_s_1_header_unique.
    hide stream s_1 frame f_rpt_s_1_footer_last_page.
    hide stream s_1 frame f_rpt_s_1_footer_param_page.
    view stream s_1 frame f_rpt_s_1_footer_normal.

    /* ************************IMPRIME REGISTROS SEM PROBLEMA********************************/

    for each tt_rpt_motiv_movto_tit_acr_dem where tt_rpt_motiv_movto_tit_acr_dem.ttv_log_ok = yes
        break by tt_rpt_motiv_movto_tit_acr_dem.cod_motiv_movto_tit_acr
              by tt_rpt_motiv_movto_tit_acr_dem.tta_dat_transacao:

      if  (line-counter(s_1) + 6) > v_rpt_s_1_bottom
      then do:
                    page stream s_1.
      end /* if */.
      if line-counter(s_1) = 1 
           then do:    
        if (line-counter(s_1) + 2) > v_rpt_s_1_bottom then
            page stream s_1.
        put stream s_1 unformatted 
            "  Motivo: " at 1
            tt_rpt_motiv_movto_tit_acr_dem.cod_motiv_movto_tit_acr at 11 format "x(8)"
            "-" at 20
            tt_rpt_motiv_movto_tit_acr_dem.des_motiv_movto_tit_acr at 22 format "x(40)" skip (1).


        if (line-counter(s_1) + 3) > v_rpt_s_1_bottom then
            page stream s_1.
        put stream s_1 unformatted 
            "Dat Transac" at 1
    &IF "{&emsfin_version}" >= "" AND "{&emsfin_version}" < "5.07A" &THEN
            "Estab" at 13
    &ENDIF
    &IF "{&emsfin_version}" >= "5.07A" AND "{&emsfin_version}" < "9.99" &THEN
            "Estab" at 13
    &ENDIF
            "SÇrie" at 19
            "Esp" at 25
            "T°tulo" at 29
            "/P" at 46
            "Vl Original" to 63
            "Vl Movto" TO 78 
            "Colaborador" TO 90
            "Nome Colaborador" AT 92
            skip
            "-----------" at 1
    &IF "{&emsfin_version}" >= "" AND "{&emsfin_version}" < "5.07A" &THEN
            "-----" at 13
    &ENDIF
    &IF "{&emsfin_version}" >= "5.07A" AND "{&emsfin_version}" < "9.99" &THEN
            "-----" at 13
    &ENDIF
            "-----" at 19
            "---" at 25
            "----------------" at 29
            "--" at 46
            "--------------" to 63
/*             "--------------" to 114   */
/*             "----------------" to 132 */
            "--------------" TO 78 
            "-----------" to 90 
            "-----------------------------------------------------------------" AT 92
            skip.
      end.    
        if (line-counter(s_1) + 1) > v_rpt_s_1_bottom then
            page stream s_1.
        put stream s_1 unformatted 
            tt_rpt_motiv_movto_tit_acr_dem.tta_dat_transacao at 1 format "99/99/9999"
    &IF "{&emsfin_version}" >= "" AND "{&emsfin_version}" < "5.07A" &THEN
            tt_rpt_motiv_movto_tit_acr_dem.tta_cod_estab at 13 format "x(3)"
    &ENDIF
    &IF "{&emsfin_version}" >= "5.07A" AND "{&emsfin_version}" < "9.99" &THEN
            tt_rpt_motiv_movto_tit_acr_dem.tta_cod_estab at 13 format "x(5)"
    &ENDIF.
    put stream s_1 unformatted 
            tt_rpt_motiv_movto_tit_acr_dem.tta_cod_ser_docto at 19 format "x(5)"
            tt_rpt_motiv_movto_tit_acr_dem.tta_cod_espec_docto at 25 format "x(3)"
            tt_rpt_motiv_movto_tit_acr_dem.tta_cod_tit_acr at 29 format "x(16)"
            tt_rpt_motiv_movto_tit_acr_dem.tta_cod_parcela at 46 format "x(02)"
/*             tt_rpt_motiv_movto_tit_acr_dem.tta_nom_pessoa at 49 format "x(40)" */
/*             tt_rpt_motiv_movto_tit_acr_dem.tta_dat_vencto_tit_acr at 90 format "99/99/9999" */
            tt_rpt_motiv_movto_tit_acr_dem.tta_val_origin_tit_acr to 63 format ">>>,>>>,>>9.99"
/*             tt_rpt_motiv_movto_tit_acr_dem.ttv_val_perc to 132 format ">,>>9.99" */
            tt_rpt_motiv_movto_tit_acr_dem.ttv_val_motiv_movto_acr to 78 format ">>>,>>>,>>9.99" 
            tt_rpt_motiv_movto_tit_acr_dem.ttv_cod_colaborador     TO 90 FORMAT "999999"
            tt_rpt_motiv_movto_tit_acr_dem.ttv_nom_colaborador     AT 92 FORMAT "x(100)"
            skip.

        if  first-of(tt_rpt_motiv_movto_tit_acr_dem.cod_motiv_movto_tit_acr)
        then do:

            assign v_val_total                  = 0
                   v_num_reg_criac_acr          = 0.

        end /* if */.

        assign v_num_reg_criac_acr = v_num_reg_criac_acr + 1.
        assign v_val_total = v_val_total + tt_rpt_motiv_movto_tit_acr_dem.ttv_val_motiv_movto_acr.

        if  last-of(tt_rpt_motiv_movto_tit_acr_dem.cod_motiv_movto_tit_acr)
        then do:

              put stream s_1 unformatted skip(1).
              if (line-counter(s_1) + 1) > v_rpt_s_1_bottom then
                  page stream s_1.
              put stream s_1 unformatted 
                  "Total Geral" at 109
                  v_num_reg_criac_acr to 128 format ">>>>,>>9"
                  v_val_total to 147 format "->>>,>>>,>>9.99" skip.
              page stream s_1.

       end /* if */.     




        delete tt_rpt_motiv_movto_tit_acr_dem.
    end.    




    /* *************************IMPRIME REGISTROS COM PROBLEMA*********************************/



    for each tt_rpt_motiv_movto_tit_acr_dem where tt_rpt_motiv_movto_tit_acr_dem.ttv_log_ok = no
        break by tt_rpt_motiv_movto_tit_acr_dem.tta_cod_indic_econ
              by tt_rpt_motiv_movto_tit_acr_dem.tta_dat_transacao:

        if  v_cod_dwb_user begins 'es_'
        then do:
            run prgtec/btb/btb908ze.py (Input 1,
                                        Input tt_rpt_motiv_movto_tit_acr_dem.ttv_cod_dwb_field_rpt[2]) /*prg_api_atualizar_ult_obj*/.
        end /* if */.


        if  v_num_reg_criac_acr > 0 and
             first(tt_rpt_motiv_movto_tit_acr_dem.tta_cod_indic_econ)
        then do:
            page stream s_1.
            assign v_num_reg_criac_acr = 0.
        end /* if */.

        if  first-of(tt_rpt_motiv_movto_tit_acr_dem.tta_cod_indic_econ)
        then do:

            /* Begin_Include: i_grava_msg */
            assign v_des_param = substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9", tt_rpt_motiv_movto_tit_acr_dem.tta_cod_indic_econ, v_cod_indic_econ_base, v_dat_cotac_indic_econ) + "~~~~~~~~~~~~~~~~".
            run pi_messages (input "msg",
                             input 784,
                             input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")).
            assign v_des_mensagem = return-value /*msg_784*/.
            v_des_mensagem = substitute(v_des_mensagem, entry(1, v_des_param, "~~"), 
                                              entry(2, v_des_param, "~~"), 
                                              entry(3, v_des_param, "~~"), 
                                              entry(4, v_des_param, "~~"), 
                                              entry(5, v_des_param, "~~"), 
                                              entry(6, v_des_param, "~~"), 
                                              entry(7, v_des_param, "~~"), 
                                              entry(8, v_des_param, "~~"), 
                                              entry(9, v_des_param, "~~")).
            /* End_Include: i_grava_msg */


            if  (line-counter(s_1) + 8 > v_rpt_s_1_bottom)
            then do:
                page stream s_1.
            end /* if */.

            put stream s_1 unformatted v_des_msg_abrev skip.
            put stream s_1 unformatted v_des_mensagem  skip(1).


        end /* if */.

        if  (line-counter(s_1) + 3) > v_rpt_s_1_bottom
        then do:
            page stream s_1.
            put stream s_1 unformatted v_des_msg_abrev skip.
            put stream s_1 unformatted v_des_mensagem  skip(1).
            if (line-counter(s_1) + 3) > v_rpt_s_1_bottom then
                page stream s_1.
            put stream s_1 unformatted 
                "Dat Transac" at 1
    &IF "{&emsfin_version}" >= "" AND "{&emsfin_version}" < "5.07A" &THEN
                "Estab" at 13
    &ENDIF
    &IF "{&emsfin_version}" >= "5.07A" AND "{&emsfin_version}" < "9.99" &THEN
                "Estab" at 13
    &ENDIF
                "SÇrie" at 19
                "Esp" at 25
                "T°tulo" at 29
                "/P" at 46
                "Vl Original" to 63
                "Vl Custo" to 78 
                "Colaborador" 
                skip
                "-----------" at 1
    &IF "{&emsfin_version}" >= "" AND "{&emsfin_version}" < "5.07A" &THEN
                "-----" at 13
    &ENDIF
    &IF "{&emsfin_version}" >= "5.07A" AND "{&emsfin_version}" < "9.99" &THEN
                "-----" at 13
    &ENDIF
                "-----" at 19
                "---" at 25
                "----------------" at 29
                "--" at 46
                "--------------" to 63
                "--------------" to 78
                "-----------" to 90  
                "-----------------------------------------------------------------" AT 92
                skip.

        end /* if */.

        delete tt_rpt_motiv_movto_tit_acr_dem.

    end.


    hide stream s_1 frame f_rpt_s_1_footer_normal.
    hide stream s_1 frame f_rpt_s_1_footer_param_page.
    view stream s_1 frame f_rpt_s_1_footer_last_page.

    hide stream s_1 frame f_rpt_s_1_Grp_motivo_Lay_motivo.
    hide stream s_1 frame f_rpt_s_1_Grp_principal_Lay_Principal.

END PROCEDURE. /* pi_rpt_motiv_movto_tit_acr_dem */
/*****************************************************************************
** Procedure Interna.....: pi_ler_tt_motiv_movto_tit_acr_dem
** Descricao.............: pi_ler_tt_motiv_movto_tit_acr_dem
** Criado por............: borba
** Criado em.............: 08/05/1997 16:34:54
** Alterado por..........: bre18732
** Alterado em...........: 18/08/2004 16:45:59
*****************************************************************************/
PROCEDURE pi_ler_tt_motiv_movto_tit_acr_dem:

    /************************* Variable Definition Begin ************************/

    def var v_val_motiv_movto_acr_cot
        as decimal
        format ">>>,>>>,>>9.99":U
        decimals 2
        label "Vl Custo Motivo"
        column-label "Vl Custo Motivo"
        no-undo.
    def var v_val_movto_tit_acr_cot
        as decimal
        format "->>>,>>>,>>9.99":U
        decimals 2
        label "Vl Movimento"
        column-label "Vl Movimento"
        no-undo.


    /************************** Variable Definition End *************************/

    assign v_des_msg_abrev = "Motivos dos Movimentos n∆o impressos conforme erro abaixo !" /*4503*/.

    Establecimento:
    for
       each estabelecimento no-lock
            where estabelecimento.cod_empresa = v_cod_empres_usuar
            and estabelecimento.cod_estab >= v_cod_estab_dni_inic
            and estabelecimento.cod_estab <= v_cod_estab_dni_final /* cl_ler_rpt_estabelecimento of estabelecimento*/.

        Motivo:
        for
           each motiv_movto_tit_acr no-lock
                where motiv_movto_tit_acr.cod_estab = Estabelecimento.cod_estab 
                  and motiv_movto_tit_acr.cod_motiv_movto_tit_acr >= v_cod_motiv_movto_tit_acr_ini 
                  and motiv_movto_tit_acr.cod_motiv_movto_tit_acr <= v_cod_motiv_movto_tit_acr_fim
                  and motiv_movto_tit_acr.dat_inic_valid <= v_dat_cotac_indic_econ
                  and motiv_movto_tit_acr.dat_fim_valid >= v_dat_cotac_indic_econ
 .
           v_val_motiv_movto_acr_cot = 1.        

           run pi_retornar_indic_econ_finalid (Input motiv_movto_tit_acr.cod_finalid_econ,
                                               Input v_dat_cotac_indic_econ,
                                               output v_cod_indic_econ) /*pi_retornar_indic_econ_finalid*/.

           if v_cod_indic_econ <> v_cod_indic_econ_base and
              motiv_movto_tit_acr.val_motiv_movto_acr >  0 then do:
               find tt_rpt_cotac_parid where
                        tt_rpt_cotac_parid.tta_cod_indic_econ_base = v_cod_indic_econ_base and  
                        tt_rpt_cotac_parid.tta_cod_indic_econ_idx = v_cod_indic_econ /* and
                        tt_rpt_cotac_parid.tta_dat_cotac_indic_econ = v_dat_cotac_indic_econ*/ no-lock no-error.
                if not avail tt_rpt_cotac_parid then do:
                    run pi_achar_cotac_indic_econ (Input v_cod_indic_econ_base,
                                                   Input v_cod_indic_econ,
                                                   Input v_dat_cotac_indic_econ,
                                                   Input "Real" /*l_real*/,
                                                   output v_dat_conver,
                                                   output v_val_cotac_indic_econ,
                                                   output v_cod_return) /*pi_achar_cotac_indic_econ*/.
                            if v_cod_return = "" or v_val_cotac_indic_econ = 0
                                then do:
                                create tt_rpt_motiv_movto_tit_acr_dem.
                                assign tt_rpt_motiv_movto_tit_acr_dem.ttv_rec_motiv_movto_tit_acr = recid(tt_rpt_motiv_movto_tit_acr_dem)
                                       tt_rpt_motiv_movto_tit_acr_dem.tta_cod_estab           = estabelecimento.cod_estab
                                       tt_rpt_motiv_movto_tit_acr_dem.cod_motiv_movto_tit_acr = motiv_movto_tit_acr.cod_motiv_movto_tit_acr
                                       tt_rpt_motiv_movto_tit_acr_dem.tta_cod_indic_econ      = v_cod_indic_econ
                                       tt_rpt_motiv_movto_tit_acr_dem.ttv_log_ok              = no.                          
                                       next motivo.
                            end /* se*/.

                            create tt_rpt_cotac_parid.
                            assign tt_rpt_cotac_parid.ttv_rec_cotac_parid      = recid(tt_rpt_cotac_parid)
                                   tt_rpt_cotac_parid.tta_cod_indic_econ_base  = v_cod_indic_econ_base
                                   tt_rpt_cotac_parid.tta_cod_indic_econ_idx   = v_cod_indic_econ
                                   tt_rpt_cotac_parid.tta_ind_tip_cotac_parid  = "Real" /*l_real*/ 
                                   tt_rpt_cotac_parid.tta_dat_cotac_indic_econ = v_dat_cotac_indic_econ
                                   tt_rpt_cotac_parid.tta_val_cotac_indic_econ = v_val_cotac_indic_econ.
                end /* se*/.             
              assign v_val_motiv_movto_acr_cot = tt_rpt_cotac_parid.tta_val_cotac_indic_econ.
           end.          

           movimento:
           for       
              each movto_tit_acr no-lock
                   where movto_tit_acr.cod_estab = Estabelecimento.cod_estab 
                     and movto_tit_acr.cod_motiv_movto_tit_acr = motiv_movto_tit_acr.cod_motiv_movto_tit_acr
                     and movto_tit_acr.dat_transacao >= v_dat_movto_inic 
                     and movto_tit_acr.dat_transacao <= v_dat_movto_fim,
                   FIRST cst-furo-caixa NO-LOCK
                   WHERE cst-furo-caixa.cod-estab            = movto_tit_acr.cod_estab
                     AND cst-furo-caixa.num_id_tit_acr       = movto_tit_acr.num_id_tit_acr
                     AND cst-furo-caixa.num_id_movto_tit_acr = movto_tit_acr.num_id_movto_tit_acr
                     AND INT(cst-furo-caixa.mat-colabor) >= v_cod_colab_inic 
                     AND INT(cst-furo-caixa.mat-colabor) <= v_cod_colab_final:

              if (movto_tit_acr.ind_trans_acr = "Acerto Valor a CrÇdito" /*l_acerto_valor_a_Credito*/     and v_log_acerto_val_cr    = no)
              or (movto_tit_acr.ind_trans_acr = "Acerto Valor a DÇbito" /*l_acerto_valor_a_debito*/      and v_log_acerto_val_db    = no)
              or (movto_tit_acr.ind_trans_acr = "Acerto Valor a Maior" /*l_acerto_valor_a_maior*/       and v_log_acerto_val_maior = no)
              or (movto_tit_acr.ind_trans_acr = "Acerto Valor a Menor" /*l_acerto_valor_a_menor*/       and v_log_acerto_val_menor = no)
              or (movto_tit_acr.ind_trans_acr = "Alteraá∆o Data Emiss∆o" /*l_alteracao_data_emissao*/     and v_log_alter_dat_emis   = no)
              or (movto_tit_acr.ind_trans_acr = "Alteraá∆o Data Vencimento" /*l_alteracao_data_vencimento*/  and v_log_alter_dat_vencto = no)
              or (movto_tit_acr.ind_trans_acr = "Alteraá∆o n∆o Cont†bil" /*l_alteracao_nao_contabil*/     and v_log_alter_nao_ctbl   = no)
              or (movto_tit_acr.ind_trans_acr = "Implantaá∆o a CrÇdito" /*l_implantacao_a_credito*/      and v_log_impl_cr          = no)
              or (movto_tit_acr.ind_trans_acr = "Devoluá∆o" /*l_devolucao*/                  and v_log_devol            = no)
              or (movto_tit_acr.ind_trans_acr = "Implantaá∆o" /*l_implantacao*/                and v_log_impl             = no)
              or (movto_tit_acr.ind_trans_acr = "Implantaá∆o a CrÇdito" /*l_implantacao_a_credito*/      and v_log_impl_cr          = no)
              or (movto_tit_acr.ind_trans_acr = "Renegociaá∆o" /*l_renegociacao*/               and v_log_renegoc          = no)
              or (movto_tit_acr.ind_trans_acr = "Subst Nota por Duplicata" /*l_subst_nota_por_duplicata*/   and v_log_subst_nota_dupl  = no) then do:
                  next movimento.
              end.

              assign v_val_movto_tit_acr_cot = 1.

              find first tit_acr no-lock
                  where tit_acr.cod_estab      = movto_tit_acr.cod_estab
                    and tit_acr.num_id_tit_acr = movto_tit_acr.num_id_tit_acr
                  no-error.
              if tit_acr.cod_indic_econ <> v_cod_indic_econ_base then do:
                  find tt_rpt_cotac_parid where
                        tt_rpt_cotac_parid.tta_cod_indic_econ_base = v_cod_indic_econ_base and  
                        tt_rpt_cotac_parid.tta_cod_indic_econ_idx = tit_acr.cod_indic_econ /* and
                        tt_rpt_cotac_parid.tta_dat_cotac_indic_econ = v_dat_cotac_indic_econ*/ no-lock no-error.
                  if not avail tt_rpt_cotac_parid then do:
                   run pi_achar_cotac_indic_econ (Input v_cod_indic_econ_base,
                                                  Input v_cod_indic_econ,
                                                  Input v_dat_cotac_indic_econ,
                                                  Input "Real" /*l_real*/,
                                                  output v_dat_conver,
                                                  output v_val_cotac_indic_econ,
                                                  output v_cod_return) /*pi_achar_cotac_indic_econ*/.
                            if v_cod_return = "" or v_val_cotac_indic_econ = 0
                                then do:
                                create tt_rpt_motiv_movto_tit_acr_dem.
                                assign tt_rpt_motiv_movto_tit_acr_dem.ttv_rec_motiv_movto_tit_acr = recid(tt_rpt_motiv_movto_tit_acr_dem)
                                       tt_rpt_motiv_movto_tit_acr_dem.tta_cod_estab           = estabelecimento.cod_estab
                                       tt_rpt_motiv_movto_tit_acr_dem.cod_motiv_movto_tit_acr = motiv_movto_tit_acr.cod_motiv_movto_tit_acr
                                       tt_rpt_motiv_movto_tit_acr_dem.tta_cod_indic_econ      = v_cod_indic_econ
                                       tt_rpt_motiv_movto_tit_acr_dem.ttv_log_ok              = no.                            
                                       next motivo.
                            end /* se*/.
                            create tt_rpt_cotac_parid.
                            assign tt_rpt_cotac_parid.ttv_rec_cotac_parid      = recid(tt_rpt_cotac_parid)
                                   tt_rpt_cotac_parid.tta_cod_indic_econ_base  = v_cod_indic_econ_base
                                   tt_rpt_cotac_parid.tta_cod_indic_econ_idx   = v_cod_indic_econ
                                   tt_rpt_cotac_parid.tta_ind_tip_cotac_parid  = "Real" /*l_real*/ 
                                   tt_rpt_cotac_parid.tta_dat_cotac_indic_econ = v_dat_cotac_indic_econ
                                   tt_rpt_cotac_parid.tta_val_cotac_indic_econ = v_val_cotac_indic_econ.
                  end /* se*/.
                  assign v_val_movto_tit_acr_cot = tt_rpt_cotac_parid.tta_val_cotac_indic_econ.
              end /* se*/. 
              find first cliente no-lock
              where cliente.cdn_cliente = movto_tit_acr.cdn_cliente no-error.
              if (movto_tit_acr.ind_trans_acr = "Alteraá∆o Data Vencimento" /*l_alteracao_data_vencimento*/  and v_log_alter_dat_vencto = yes) then do:
                  v_val_motiv_movto_acr = ((tit_acr.dat_vencto_tit_acr - dat_vencto_origin_tit_acr) 
                                                    * tit_acr.val_perc_juros_dia_atraso * movto_tit_acr.val_movto_tit_acr * v_val_movto_tit_acr_cot).
                  if  v_log_funcao_tip_calc_juros then do:                                                      
                      &if '{&emsfin_version}' >= "5.05" &then
                          assign v_ind_tip_calc_juros = tit_acr.ind_tip_calc_juros.                                                
                      &else
                          assign v_ind_tip_calc_juros = entry(3, tit_acr.cod_livre_1, chr(24)).
                      &endif
                      assign v_num_dias_atraso = tit_acr.dat_vencto_tit_acr - dat_vencto_origin_tit_acr.    
                      run pi_retorna_juros_compostos (Input v_ind_tip_calc_juros,
                                                      Input tit_acr.val_perc_juros_dia_atraso,
                                                      Input movto_tit_acr.val_movto_tit_acr,
                                                      Input v_num_dias_atraso,
                                                      output v_val_juros_aux) /*pi_retorna_juros_compostos*/.
                      if  v_val_juros_aux <> ? then
                          assign v_val_motiv_movto_acr = v_val_juros_aux * v_val_motiv_movto_acr_cot.
                  end.                                                                                            
              end /* se */. 
              else do:

                  v_val_motiv_movto_acr = motiv_movto_tit_acr.val_motiv_movto_acr * v_val_motiv_movto_acr_cot.

              end /* else*/.

              FIND FIRST VR034FUN NO-LOCK
                   WHERE VR034FUN.NUMCAD = INT(cst-furo-caixa.mat-colabor) NO-ERROR.

              create tt_rpt_motiv_movto_tit_acr_dem.
              assign tt_rpt_motiv_movto_tit_acr_dem.ttv_rec_motiv_movto_tit_acr = recid(tt_rpt_motiv_movto_tit_acr_dem)
                     tt_rpt_motiv_movto_tit_acr_dem.tta_cod_estab           = estabelecimento.cod_estab
                     tt_rpt_motiv_movto_tit_acr_dem.des_motiv_movto_tit_acr = motiv_movto_tit_acr.des_motiv_movto_tit_acr
                     tt_rpt_motiv_movto_tit_acr_dem.cod_motiv_movto_tit_acr = motiv_movto_tit_acr.cod_motiv_movto_tit_acr
                     tt_rpt_motiv_movto_tit_acr_dem.tta_dat_transacao       = movto_tit_acr.dat_transacao
                     tt_rpt_motiv_movto_tit_acr_dem.tta_cod_ser_docto       = tit_acr.cod_ser_docto
                     tt_rpt_motiv_movto_tit_acr_dem.tta_cod_espec_docto     = tit_acr.cod_espec_docto
                     tt_rpt_motiv_movto_tit_acr_dem.tta_cod_parcela         = tit_acr.cod_parcela
                     tt_rpt_motiv_movto_tit_acr_dem.tta_nom_pessoa          = cliente.nom_pessoa
                     tt_rpt_motiv_movto_tit_acr_dem.tta_dat_vencto_tit_acr  = tit_acr.dat_vencto_tit_acr
                     tt_rpt_motiv_movto_tit_acr_dem.tta_val_origin_tit_acr  = tit_acr.val_origin_tit_acr
                     tt_rpt_motiv_movto_tit_acr_dem.tta_cod_indic_econ      = v_cod_indic_econ
                     tt_rpt_motiv_movto_tit_acr_dem.tta_cod_tit_acr         = tit_acr.cod_tit_acr
                     tt_rpt_motiv_movto_tit_acr_dem.ttv_val_perc            = 0
                     tt_rpt_motiv_movto_tit_acr_dem.ttv_val_motiv_movto_acr = movto_tit_acr.val_movto_tit_acr
                     tt_rpt_motiv_movto_tit_acr_dem.ttv_cod_colaborador     = INT(cst-furo-caixa.mat-colabor)
                     tt_rpt_motiv_movto_tit_acr_dem.ttv_nom_colaborador     = IF AVAIL VR034FUN THEN CAPS(VR034FUN.NOMFUN) ELSE "N∆o Encontrado!"
                     tt_rpt_motiv_movto_tit_acr_dem.ttv_log_ok              = yes.
           end /* movimento*/.
        end /* Motivo*/.
        if v_log_alter_nao_ctbl
        and v_cod_motiv_movto_tit_acr_ini = '' 
        then do:
               movimento_alter:
               for each movto_tit_acr no-lock
                     where movto_tit_acr.cod_estab = estabelecimento.cod_estab 
                       and movto_tit_acr.cod_motiv_movto_tit_acr = ""
                       and movto_tit_acr.dat_transacao >= v_dat_movto_inic 
                       and movto_tit_acr.dat_transacao <= v_dat_movto_fim,
                     FIRST cst-furo-caixa NO-LOCK
                     WHERE cst-furo-caixa.cod-estab             = movto_tit_acr.cod_estab
                       AND cst-furo-caixa.num_id_tit_acr        = movto_tit_acr.num_id_tit_acr
                       AND cst-furo-caixa.num_id_movto_tit_acr  = movto_tit_acr.num_id_movto_tit_acr
                       AND INT(cst-furo-caixa.mat-colabor)     >= v_cod_colab_inic 
                       AND INT(cst-furo-caixa.mat-colabor)     <= v_cod_colab_final                   
                   :

                  if movto_tit_acr.ind_trans_acr <> "Alteraá∆o n∆o Cont†bil" /*l_alteracao_nao_contabil*/  then next movimento_alter.

                  assign v_val_movto_tit_acr_cot = 1.

                  find first tit_acr no-lock
                      where tit_acr.cod_estab      = movto_tit_acr.cod_estab
                        and tit_acr.num_id_tit_acr = movto_tit_acr.num_id_tit_acr no-error.

                  find first cliente no-lock
                       where cliente.cdn_cliente = movto_tit_acr.cdn_cliente no-error.                  

                  assign v_val_motiv_movto_acr = 0.
                  
                  FIND FIRST VR034FUN NO-LOCK
                       WHERE VR034FUN.NUMCAD = INT(cst-furo-caixa.mat-colabor) NO-ERROR.

                  create tt_rpt_motiv_movto_tit_acr_dem.
                  assign tt_rpt_motiv_movto_tit_acr_dem.ttv_rec_motiv_movto_tit_acr = recid(tt_rpt_motiv_movto_tit_acr_dem)
                         tt_rpt_motiv_movto_tit_acr_dem.tta_cod_estab           = estabelecimento.cod_estab
                         tt_rpt_motiv_movto_tit_acr_dem.des_motiv_movto_tit_acr = "Alteraá∆o n∆o Cont†bil" /*l_alteracao_nao_contabil*/ 
                         tt_rpt_motiv_movto_tit_acr_dem.cod_motiv_movto_tit_acr = ''
                         tt_rpt_motiv_movto_tit_acr_dem.tta_dat_transacao       = movto_tit_acr.dat_transacao
                         tt_rpt_motiv_movto_tit_acr_dem.tta_cod_ser_docto       = tit_acr.cod_ser_docto
                         tt_rpt_motiv_movto_tit_acr_dem.tta_cod_parcela         = tit_acr.cod_parcela
                         tt_rpt_motiv_movto_tit_acr_dem.tta_cod_espec_docto     = tit_acr.cod_espec_docto
                         tt_rpt_motiv_movto_tit_acr_dem.tta_nom_pessoa          = cliente.nom_pessoa
                         tt_rpt_motiv_movto_tit_acr_dem.tta_dat_vencto_tit_acr  = tit_acr.dat_vencto_tit_acr
                         tt_rpt_motiv_movto_tit_acr_dem.tta_val_origin_tit_acr  = tit_acr.val_origin_tit_acr
                         tt_rpt_motiv_movto_tit_acr_dem.tta_cod_indic_econ      = v_cod_indic_econ
                         tt_rpt_motiv_movto_tit_acr_dem.tta_cod_tit_acr         = tit_acr.cod_tit_acr
                         tt_rpt_motiv_movto_tit_acr_dem.ttv_val_perc            = (v_val_motiv_movto_acr * 100) / tit_acr.val_origin_tit_acr
                         tt_rpt_motiv_movto_tit_acr_dem.ttv_val_motiv_movto_acr = movto_tit_acr.val_movto_tit_acr
                         tt_rpt_motiv_movto_tit_acr_dem.ttv_cod_colaborador     = INT(cst-furo-caixa.mat-colabor)
                         tt_rpt_motiv_movto_tit_acr_dem.ttv_nom_colaborador     = IF AVAIL VR034FUN THEN CAPS(VR034FUN.NOMFUN) ELSE "N∆o Encontrado!"
                         tt_rpt_motiv_movto_tit_acr_dem.ttv_log_ok              = yes.
             end.
        end.    
    end /* for estabelecimento */.
END PROCEDURE. /* pi_ler_tt_motiv_movto_tit_acr_dem */
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

    def var v_cod_indic_econ_orig            as character       no-undo. /*local*/
    def var v_dat_cotac_mes                  as date            no-undo. /*local*/
    def var v_val_cotac_indic_econ_base      as decimal         no-undo. /*local*/
    def var v_val_cotac_indic_econ_idx       as decimal         no-undo. /*local*/


    /************************** Variable Definition End *************************/

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
            /* period_block: */
            case parid_indic_econ.ind_periodic_cotac:
                when "Di†ria" /*l_diaria*/ then
                    diaria_block:
                    do:
                        find cotac_parid no-lock
                             where cotac_parid.cod_indic_econ_base = p_cod_indic_econ_base
                               and cotac_parid.cod_indic_econ_idx = p_cod_indic_econ_idx
                               and cotac_parid.dat_cotac_indic_econ = p_dat_transacao
                               and cotac_parid.ind_tip_cotac_parid = p_ind_tip_cotac_parid
                             use-index ctcprd_id no-error.
                        if  not avail cotac_parid or cotac_parid.val_cotac_indic_econ = 0
                        then do:
                            find parid_indic_econ no-lock
                                 where parid_indic_econ.cod_indic_econ_base = p_cod_indic_econ_base
                                   and parid_indic_econ.cod_indic_econ_idx = p_cod_indic_econ_idx
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
                             where cotac_parid.cod_indic_econ_base = p_cod_indic_econ_base
                               and cotac_parid.cod_indic_econ_idx = p_cod_indic_econ_idx
                               and cotac_parid.dat_cotac_indic_econ = v_dat_cotac_mes
                               and cotac_parid.ind_tip_cotac_parid = p_ind_tip_cotac_parid
                             use-index ctcprd_id no-error.
                        if  not avail cotac_parid or cotac_parid.val_cotac_indic_econ = 0
                        then do:
                            /* block: */
                            case parid_indic_econ.ind_criter_busca:
                                when "Anterior" /*l_anterior*/ then
                                find prev cotac_parid no-lock
                                                   where cotac_parid.cod_indic_econ_base = p_cod_indic_econ_base
                                                     and cotac_parid.cod_indic_econ_idx = p_cod_indic_econ_idx
                                                     and cotac_parid.dat_cotac_indic_econ < v_dat_cotac_mes
                                                     and cotac_parid.ind_tip_cotac_parid = p_ind_tip_cotac_parid
                                                     and cotac_parid.val_cotac_indic_econ <> 0.0
                                                   use-index ctcprd_id no-error.
                                when "Pr¢ximo" /*l_proximo*/ then
                                find next cotac_parid no-lock
                                                   where cotac_parid.cod_indic_econ_base = p_cod_indic_econ_base
                                                     and cotac_parid.cod_indic_econ_idx = p_cod_indic_econ_idx
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
    end /* else */.
END PROCEDURE. /* pi_achar_cotac_indic_econ */
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
** Procedure Interna.....: pi_retorna_juros_compostos
** Descricao.............: pi_retorna_juros_compostos
** Criado por............: bre18490
** Criado em.............: 12/01/2001 21:09:04
** Alterado por..........: bre18490
** Alterado em...........: 21/05/2001 11:27:35
*****************************************************************************/
PROCEDURE pi_retorna_juros_compostos:

    /************************ Parameter Definition Begin ************************/

    def Input param p_ind_tip_calc_juros
        as character
        format "X(10)"
        no-undo.
    def Input param p_val_perc_juros_acr
        as decimal
        format ">>9.99"
        decimals 2
        no-undo.
    def Input param p_val_principal
        as decimal
        format ">>>>,>>>,>>9.99"
        decimals 2
        no-undo.
    def Input param p_num_dias_atraso
        as integer
        format ">9"
        no-undo.
    def output param p_val_juros_aux
        as decimal
        format ">>>>,>>>,>>9.99"
        decimals 2
        no-undo.


    /************************* Parameter Definition End *************************/

    /************************* Variable Definition Begin ************************/

    def var v_num_cont
        as integer
        format ">,>>9":U
        initial 0
        no-undo.
    def var v_val_juros_calc_aux
        as decimal
        format "->>,>>>,>>9.999999":U
        decimals 6
        no-undo.


    /************************** Variable Definition End *************************/

    if  p_ind_tip_calc_juros <> "Compostos" /*l_compostos*/  then do:
        assign p_val_juros_aux = ?.
        return.
    end.

    do  v_num_cont = 1 to p_num_dias_atraso:
        assign v_val_juros_calc_aux = v_val_juros_calc_aux + ((p_val_principal + v_val_juros_calc_aux) * p_val_perc_juros_acr / 100 ).
    end.

    assign p_val_juros_aux = v_val_juros_calc_aux.

END PROCEDURE. /* pi_retorna_juros_compostos */


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
/********************  End of rpt_motiv_movto_tit_acr_dem *******************/
