/*****************************************************************************
** Programa..............: rpt_tit_acr_emitidos_convenio
** Descricao.............: Base Demonstrativo T°tulo Contas a Receber Convànio
** Versao................:  1.00.00.039
** Procedimento..........: rel_tit_emit_acr_convenio
** Nome Externo..........: intprg/nicr011.p
** Criado por............: cleyton.neves
** Criado em.............: 06/09/2016 
*****************************************************************************/
define buffer empresa              for ems5.empresa.
define buffer histor_exec_especial for ems5.histor_exec_especial.
define buffer cliente              for ems5.cliente.
define buffer pais                 for ems5.pais.
define buffer segur_unid_organ     for ems5.segur_unid_organ.

def var c-versao-prg as char initial " 1.00.00.039":U no-undo.

{include/i_dbinst.i}
{include/i_dbtype.i}

/* Alteracao via filtro - Controle de impressao - inicio */
{include/i_prdvers.i}
/* Alteracao via filtro - Controle de impressao - fim    */

{include/i_fcldef.i}


&IF "{&EMSFND_VERSION}" >= "1.00" &THEN
{include/i-license-manager.i rpt_tit_acr_emitidos ACR}
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
                                    "RPT_TIT_ACR_EMITIDOS","~~EMSFIN", "~~{~&emsfin_version}", "~~5.01")) /*msg_5009*/.
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

def temp-table tt_rpt_tit_acr_emit no-undo
    field tta_cod_estab                    as character format "x(3)" label "Estabelecimento" column-label "Estab"
    field tta_num_id_tit_acr               as integer format "9999999999" initial 0 label "Token Cta Receber" column-label "Token Cta Receber"
    field tta_cod_espec_docto              as character format "x(3)" label "EspÇcie Documento" column-label "EspÇcie"
    field tta_cod_ser_docto                as character format "x(3)" label "SÇrie Documento" column-label "SÇrie"
    field tta_cod_tit_acr                  as character format "x(10)" label "T°tulo" column-label "T°tulo"
    field tta_cod_parcela                  as character format "x(02)" label "Parcela" column-label "Parc"
    field tta_cdn_cliente                  as Integer format ">>>,>>>,>>9" initial 0 label "Cliente" column-label "Cliente"
    field tta_cod_portador                 as character format "x(5)" label "Portador" column-label "Portador"
    field tta_cod_cart_bcia                as character format "x(3)" label "Carteira" column-label "Carteira"
    field tta_dat_emis_docto               as date format "99/99/9999" initial today label "Data  Emiss∆o" column-label "Dt Emiss∆o"
    field tta_dat_vencto_tit_acr           as date format "99/99/9999" initial ? label "Vencimento" column-label "Vencimento"
    field tta_val_origin_tit_acr           as decimal format ">>>,>>>,>>9.99" decimals 2 initial 0 label "Vl Original T°tulo" column-label "Vl Original T°tulo"
    field ttv_cod_dwb_field_rpt            as character extent 9 format "x(32)" label "Conjunto" column-label "Conjunto"
    field tta_cod_grp_clien                as character format "x(4)" label "Grupo Cliente" column-label "Grupo Cliente"
    field tta_nom_pessoa                   as character format "x(40)" label "Nome" column-label "Nome"
    index tt_rpt_tit_acr_emit_id           is primary unique
          tta_cod_estab                    ascending
          tta_num_id_tit_acr               ascending
    .

def temp-table tt_usuar_grp_usuar no-undo like usuar_grp_usuar
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


def var v_cdn_cliente_fim
    as Integer
    format ">>>,>>>,>>9":U
    initial 999999999
    label "atÇ"
    column-label "Cliente Final"
    no-undo.
def var v_cdn_cliente_ini
    as Integer
    format ">>>,>>>,>>9":U
    initial 0
    label "Cliente"
    column-label "Cliente Inicial"
    no-undo.
def var v_cdn_estab
    as Integer
    format ">>9":U
    label "N£mero Estabelec"
    column-label "N£mero Estab"
    no-undo.
def new global shared var v_cod_aplicat_dtsul_corren
    as character
    format "x(3)":U
    no-undo.
def var v_cod_cart_bcia_fim
    as character
    format "x(3)":U
    initial "ZZZ"
    label "atÇ"
    column-label "Carteira"
    no-undo.
def var v_cod_cart_bcia_ini
    as character
    format "x(3)":U
    label "Carteira"
    column-label "Carteira"
    no-undo.
def new global shared var v_cod_ccusto_corren
    as character
    format "x(11)":U
    label "Centro Custo"
    column-label "Centro Custo"
    no-undo.
def var v_cod_cep
    as character
    format "x(20)":U
    label "CEP"
    column-label "CEP"
    no-undo.
def var v_cod_cep_dest_cobr
    as character
    format "x(20)":U
    label "CEP"
    column-label "CEP"
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
def var v_cod_espec_docto_fim
    as character
    format "x(3)":U
    initial "ZZZ"
    label "atÇ"
    column-label "C¢digo Final"
    no-undo.
def var v_cod_espec_docto_ini
    as character
    format "x(3)":U
    label "EspÇcie"
    column-label "C¢digo Inicial"
    no-undo.
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
def new global shared var v_cod_funcao_negoc_empres
    as character
    format "x(50)":U
    no-undo.
def var v_cod_grp_clien_fim
    as character
    format "x(4)":U
    initial "ZZZZ"
    label "atÇ"
    column-label "Grupo Cliente"
    no-undo.
def var v_cod_grp_clien_ini
    as character
    format "x(4)":U
    label "Grupo Cliente"
    column-label "Grupo Cliente"
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
def new global shared var v_cod_plano_ccusto_corren
    as character
    format "x(8)":U
    label "Plano CCusto"
    column-label "Plano CCusto"
    no-undo.
def var v_cod_portador_fim
    as character
    format "x(5)":U
    initial "ZZZZZ"
    label "atÇ"
    column-label "Portador Final"
    no-undo.
def var v_cod_portador_ini
    as character
    format "x(5)":U
    label "Portador"
    column-label "Portador Inicial"
    no-undo.
def var v_cod_release
    as character
    format "x(12)":U
    no-undo.
def var v_cod_ser_docto_fim
    as character
    format "x(3)":U
    initial "ZZZ"
    label "atÇ"
    column-label "SÇrie"
    no-undo.
def var v_cod_ser_docto_ini
    as character
    format "x(3)":U
    label "SÇrie"
    column-label "SÇrie"
    no-undo.
def var v_cod_tit_acr
    as character
    format "x(10)":U
    label "T°tulo"
    column-label "T°tulo"
    no-undo.
def var v_cod_unid_federac
    as character
    format "x(3)":U
    label "Unidade Federaá∆o"
    column-label "Unidade Federaá∆o"
    no-undo.
def var v_cod_convenio
    as character
    format "x(6)":U
    label "Convànio"
    column-label "Convànio"
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
&IF "{&emsfin_version}" >= "" AND "{&emsfin_version}" < "5.07A" &THEN
def var v_cod_unid_organ
    as character
    format "x(3)":U
    label "Unid Organizacional"
    column-label "Unid Organizacional"
    no-undo.
&ENDIF
&IF "{&emsfin_version}" >= "5.07A" AND "{&emsfin_version}" < "9.99" &THEN
def var v_cod_unid_organ
    as Character
    format "x(5)":U
    label "Unid Organizacional"
    column-label "Unid Organizacional"
    no-undo.
&ENDIF
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
def var v_dat_emis_docto_fim
    as date
    format "99/99/9999":U
    initial 12/31/9999
    label "atÇ"
    column-label "atÇ"
    no-undo.
def var v_dat_emis_docto_ini
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
def var v_dat_vencto_tit_acr_fim
    as date
    format "99/99/9999":U
    initial 12/31/9999
    label "atÇ"
    column-label "Vencto Final"
    no-undo.
def var v_dat_vencto_tit_acr_ini
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
def var v_des_termo_abert
    as character
    format "x(2000)":U
    view-as editor max-chars 2000 scrollbar-vertical
    size 60 by 3
    bgcolor 15 font 2
    label "Termo Abertura"
    column-label "Termo Abertura"
    no-undo.
def var v_des_termo_encert
    as character
    format "x(2000)":U
    view-as editor max-chars 2000 scrollbar-vertical
    size 60 by 3
    bgcolor 15 font 2
    label "Termo Encerramento"
    column-label "Termo Encerramento"
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
def var v_ind_classif_tit_acr_emitid
    as character
    format "X(15)":U
    initial "Por Emiss∆o" /*l_por_emissao*/
    view-as radio-set Horizontal
    radio-buttons "Por Emiss∆o", "Por Emiss∆o", "Por T°tulo", "Por T°tulo", "Por Cliente", "Por Cliente", "Por Grupo Cliente", "Por Grupo Cliente", "Por Vencimento", "Por Vencimento"
     /*l_por_emissao*/ /*l_por_emissao*/ /*l_por_titulo*/ /*l_por_titulo*/ /*l_por_cliente*/ /*l_por_cliente*/ /*l_por_grupo_cliente*/ /*l_por_grupo_cliente*/ /*l_por_vencimento*/ /*l_por_vencimento*/
    bgcolor 8 
    label "Classificaá∆o"
    column-label "Classificaá∆o"
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
def var v_ind_ender_complet
    as character
    format "X(20)":U
    initial "Endereáo" /*l_endereco*/
    view-as radio-set Vertical
    radio-buttons "Endereáo", "Endereáo", "Endereáo Completo", "Endereáo Completo"
     /*l_endereco*/ /*l_endereco*/ /*l_endereco_completo*/ /*l_endereco_completo*/
    bgcolor 8 
    no-undo.
def var v_log_answer
    as logical
    format "Sim/N∆o"
    initial yes
    view-as toggle-box
    no-undo.
def var v_log_atualiz_numer_pag
    as logical
    format "Sim/N∆o"
    initial no
    view-as toggle-box
    label "Atualiza P†gina"
    column-label "Atualiza P†gina"
    no-undo.
def var v_log_aviso_db
    as logical
    format "Sim/N∆o"
    initial no
    view-as toggle-box
    label "Aviso de DÇbito"
    column-label "Aviso de DÇbito"
    no-undo.
def var v_log_cheq_recbdo
    as logical
    format "Sim/N∆o"
    initial no
    view-as toggle-box
    label "Cheques Recebidos"
    column-label "Cheques Recebidos"
    no-undo.
def var v_log_emit_termo
    as logical
    format "Sim/N∆o"
    initial no
    view-as toggle-box
    label "Emite Termo Encert"
    column-label "Termo Encerramento"
    no-undo.
def new global shared var v_log_execution
    as logical
    format "Sim/N∆o"
    initial yes
    no-undo.
def var v_log_impl_1
    as logical
    format "Sim/N∆o"
    initial yes
    view-as toggle-box
    label "Implantaá∆o"
    no-undo.
def var v_log_method
    as logical
    format "Sim/N∆o"
    initial yes
    no-undo.
def var v_log_modul_Vendor
    as logical
    format "Sim/N∆o"
    initial no
    no-undo.
def var v_log_mostra_docto_vendor
    as logical
    format "Sim/N∆o"
    initial yes
    view-as toggle-box
    label "Vendor"
    column-label "Vendor"
    no-undo.
def var v_log_mostra_docto_vendor_repac
    as logical
    format "Sim/N∆o"
    initial yes
    view-as toggle-box
    label "Vendor Repactuado"
    column-label "Vendor Repactuado"
    no-undo.
def var v_log_normal
    as logical
    format "Sim/N∆o"
    initial yes
    view-as toggle-box
    label "Normal"
    column-label "Normal"
    no-undo.
def var v_log_pessoa_fisic_cobr
    as logical
    format "Sim/N∆o"
    initial no
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
def var v_log_renegoc
    as logical
    format "Sim/N∆o"
    initial no
    view-as toggle-box
    label "Renegociaá∆o"
    no-undo.
def var v_log_tit_acr_estordo
    as logical
    format "Sim/N∆o"
    initial yes
    view-as toggle-box
    label "Estornados"
    column-label "Estornados"
    no-undo.
def var v_log_transf_estab_1
    as logical
    format "Sim/N∆o"
    initial no
    view-as toggle-box
    label "Transf. Estabelec"
    column-label "Transf. Establec"
    no-undo.
def var v_log_transf_unid_negoc_1
    as logical
    format "Sim/N∆o"
    initial no
    view-as toggle-box
    label "Transf. UN"
    column-label "Transf. UN"
    no-undo.
def var v_nom_bairro
    as character
    format "x(20)":U
    label "Bairro"
    column-label "Bairro"
    no-undo.
def var v_nom_cidade
    as character
    format "x(32)":U
    label "Cidade"
    column-label "Cidade"
    no-undo.
def var v_nom_cidad_cobr
    as character
    format "x(30)":U
    label "Cidade Cobranáa"
    column-label "Cidade Cobranáa"
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
def var v_nom_endereco
    as character
    format "x(40)":U
    label "Endereáo"
    column-label "Endereáo"
    no-undo.
def var v_nom_ender_lin_1
    as character
    format "x(50)":U
    initial """"
    label "Endereáo Completo"
    column-label "Endereáo Completo"
    no-undo.
def var v_nom_ender_lin_2
    as character
    format "x(50)":U
    no-undo.
def var v_nom_ender_lin_3
    as character
    format "x(50)":U
    no-undo.
def var v_nom_ender_lin_4
    as character
    format "x(50)":U
    no-undo.
def new shared var v_nom_enterprise
    as character
    format "x(40)":U
    no-undo.
def var v_nom_integer
    as character
    format "x(30)":U
    no-undo.
def var v_nom_prog
    as character
    format "x(8)":U
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
def var v_num_cont_entry
    as integer
    format ">>9":U
    initial 0
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
def var v_num_pessoa_jurid
    as integer
    format ">>>,>>>,>>9":U
    label "Pessoa Jur°dica"
    column-label "Pessoa Jur°dica"
    no-undo.
def var v_num_ult_pag
    as integer
    format ">>>,>>9":U
    label "Èltima P†gina"
    column-label "Èltima P†gina"
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
def var v_qtd_tit_espec
    as decimal
    format "->>>>,>>9":U
    decimals 0
    label "Qtde T°tulos EspÇcie"
    column-label "Qtde T°tulos EspÇcie"
    no-undo.
def var v_qtd_tot_clien
    as decimal
    format "->>>>,>>9":U
    decimals 0
    label "Qtde T°tulos Cliente"
    column-label "Qtde T°tulos Cliente"
    no-undo.
def var v_qtd_tot_grp_clien
    as decimal
    format "->>>>,>>9":U
    decimals 0
    label "Qtde Tit Grp Cliente"
    column-label "Qtde Tit Grp Cliente"
    no-undo.
def var v_qtd_tot_period
    as decimal
    format "->>>>,>>9":U
    decimals 0
    label "Qtde Total T°tulos"
    column-label "Qtde Total T°tulos"
    no-undo.
def new global shared var v_rec_clien_financ
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
def var v_val_tot_clien
    as decimal
    format "->>,>>>,>>>,>>9.99":U
    decimals 2
    label "Total do Cliente"
    column-label "Total do Cliente"
    no-undo.
def var v_val_tot_espec
    as decimal
    format "->>,>>>,>>>,>>9.99":U
    decimals 2
    label "Total EspÇcie"
    column-label "Total EspÇcie"
    no-undo.
def var v_val_tot_grp_clien
    as decimal
    format "->>,>>>,>>>,>>9.99":U
    decimals 2
    label "Total Grupo Cliente"
    column-label "Total Grupo Cliente"
    no-undo.
def var v_val_tot_period
    as decimal
    format "->>,>>>,>>>,>>9.99":U
    decimals 2
    label "Total do Per°odo"
    column-label "Total do Per°odo"
    no-undo.
def var v_wgh_focus
    as widget-handle
    format ">>>>>>9":U
    no-undo.
def var v_wgh_frame_epc
    as widget-handle
    format ">>>>>>9":U
    no-undo.
def var v_log_reemis                     as logical         no-undo. /*local*/
def var v_num_livro                      as integer         no-undo. /*local*/
def var v_num_pag                        as integer         no-undo. /*local*/


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
def rectangle rt_006
    size 1 by 1
    edge-pixels 2.
def rectangle rt_007
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
def button bt_todos_img
    label "Todos"
    tooltip "Seleciona Todos"
&if "{&window-system}" <> "TTY" &then
    image file "image/im-ran_a.bmp"
&endif
    size 1 by 1.
/****************************** Function Button *****************************/
def button bt_zoo_185300
    label "Zoom"
    tooltip "Zoom"
&if "{&window-system}" <> "TTY" &then
    image-up file "image/im-zoo"
    image-insensitive file "image/ii-zoo"
&endif
    size 4 by .88.
def button bt_zoo_185301
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
def new shared var v_rpt_s_1_name as character initial "T°tulos Emitidos ACR".
def frame f_rpt_s_1_header_period header
    "---------------------------------------------------------------------------------------------------------------------------------------------" at 1
    "P†gina:" at 143
    (page-number (s_1) + v_rpt_s_1_page) at 150 format ">>>>>9" skip
    v_nom_enterprise at 1 format "x(40)"
    v_nom_report_title at 115 format "x(40)" skip
    "Per°odo: " at 1
    v_dat_inic_period at 10 format "99/99/9999"
    "A" at 21
    v_dat_fim_period at 23 format "99/99/9999"
    "-------------------------------------------------------------------------------------------------------" at 34
    v_dat_execution at 138 format "99/99/9999" "- "
    v_hra_execution at 151 format "99:99" skip (1)
    with no-box no-labels width 155 page-top stream-io.
def frame f_rpt_s_1_header_unique header
    "---------------------------------------------------------------------------------------------------------------------------------------------" at 1
    'P†gina:' at 143
    (page-number (s_1) + v_rpt_s_1_page) at 150 format '>>>>>9' skip
    v_nom_enterprise at 1 format 'x(40)'
    v_nom_report_title at 116 format 'x(40)' skip
    '----------------------------------------------------------------------------------------------------------------------------------------' at 1
    v_dat_execution at 138 format '99/99/9999' '- '
    v_hra_execution at 151 format "99:99" skip (1)
    with no-box no-labels width 155 page-top stream-io.
def frame f_rpt_s_1_footer_last_page header
    "Èltima p†gina " at 1
    "---------------------------------------------------------------------------------------------------------------------" at 15
    v_nom_prog_ext at 133 format "x(08)" "- "
    v_cod_release at 144 format "x(12)" skip
    with no-box no-labels width 155 page-bottom stream-io.
def frame f_rpt_s_1_footer_normal header
    "----------------------------------------------------------------------------------------------------------------------------------" at 1
    "- " at 131
    v_nom_prog_ext at 133 format "x(08)" "- "
    v_cod_release at 144 format "x(12)" skip
    with no-box no-labels width 155 page-bottom stream-io.
def frame f_rpt_s_1_footer_param_page header
    "P†gina ParÉmetros " at 1
    "-----------------------------------------------------------------------------------------------------------------" at 19
    v_nom_prog_ext at 133 format "x(08)" "- "
    v_cod_release at 144 format "x(12)" skip
    with no-box no-labels width 155 page-bottom stream-io.
def frame f_rpt_s_1_Grp_detalhe_Lay_cliente header
    "Cliente" to 11
    "T°tulo" at 13
    "/P" at 30
&IF "{&emsfin_version}" >= "" AND "{&emsfin_version}" < "5.07A" &THEN
    "Estab" at 33
&ENDIF
&IF "{&emsfin_version}" >= "5.07A" AND "{&emsfin_version}" < "9.99" &THEN
    "Estab" at 33
&ENDIF
    "EspÇcie" at 39
    "SÇrie" at 47
    "Emiss∆o" at 53
    "Vencimento" at 64
    "Portador" at 75
    "Cart" at 84
    "Nome" at 89
    "Convànio" at 130
    "Vl Original" to 155 skip
    "-----------" to 11
    "----------------" at 13
    "--" at 30
&IF "{&emsfin_version}" >= "" AND "{&emsfin_version}" < "5.07A" &THEN
    "-----" at 33
&ENDIF
&IF "{&emsfin_version}" >= "5.07A" AND "{&emsfin_version}" < "9.99" &THEN
    "-----" at 33
&ENDIF
    "-------" at 39
    "-----" at 47
    "----------" at 53
    "----------" at 64
    "--------" at 75
    "----" at 84
    "----------------------------------------" at 89
    "---------" at 130
    "--------------" to 155 skip
    with no-box no-labels width 155 page-top stream-io.
def frame f_rpt_s_1_Grp_detalhe_Lay_emissao header
    "Emiss∆o" at 1
    "T°tulo" at 12
    "/P" at 29
&IF "{&emsfin_version}" >= "" AND "{&emsfin_version}" < "5.07A" &THEN
    "Estab" at 32
&ENDIF
&IF "{&emsfin_version}" >= "5.07A" AND "{&emsfin_version}" < "9.99" &THEN
    "Estab" at 32
&ENDIF
    "EspÇcie" at 38
    "SÇrie" at 46
    "Vencimento" at 52
    "Portador" at 63
    "Cart" at 72
    "Cliente" to 87
    "Nome" at 89
    "Convànio" at 130
    "Vl Original" to 155 skip
    "----------" at 1
    "----------------" at 12
    "--" at 29
&IF "{&emsfin_version}" >= "" AND "{&emsfin_version}" < "5.07A" &THEN
    "-----" at 32
&ENDIF
&IF "{&emsfin_version}" >= "5.07A" AND "{&emsfin_version}" < "9.99" &THEN
    "-----" at 32
&ENDIF
    "-------" at 38
    "-----" at 46
    "----------" at 52
    "--------" at 63
    "----" at 72
    "-----------" to 87
    "----------------------------------------" at 89
    "---------" at 130
    "--------------" to 155 skip
    with no-box no-labels width 155 page-top stream-io.
def frame f_rpt_s_1_Grp_detalhe_Lay_grp_cliente header
    "Grp Cliente" at 1
    "T°tulo" at 13
    "/P" at 30
&IF "{&emsfin_version}" >= "" AND "{&emsfin_version}" < "5.07A" &THEN
    "Estab" at 33
&ENDIF
&IF "{&emsfin_version}" >= "5.07A" AND "{&emsfin_version}" < "9.99" &THEN
    "Estab" at 33
&ENDIF
    "EspÇcie" at 39
    "SÇrie" at 47
    "Vencimento" at 53
    "Portador" at 64
    "Cart" at 73
    "Cliente" to 88
    "Nome" at 90
    "Convànio" at 131
    "Vl Original" to 155 skip
    "-----------" at 1
    "----------------" at 13
    "--" at 30
&IF "{&emsfin_version}" >= "" AND "{&emsfin_version}" < "5.07A" &THEN
    "-----" at 33
&ENDIF
&IF "{&emsfin_version}" >= "5.07A" AND "{&emsfin_version}" < "9.99" &THEN
    "-----" at 33
&ENDIF
    "-------" at 39
    "-----" at 47
    "----------" at 53
    "--------" at 64
    "----" at 73
    "-----------" to 88
    "----------------------------------------" at 90
    "---------" at 131
    "--------------" to 155 skip
    with no-box no-labels width 155 page-top stream-io.
def frame f_rpt_s_1_Grp_detalhe_Lay_titulo header
    "T°tulo" at 1
    "/P" at 18
&IF "{&emsfin_version}" >= "" AND "{&emsfin_version}" < "5.07A" &THEN
    "Estab" at 21
&ENDIF
&IF "{&emsfin_version}" >= "5.07A" AND "{&emsfin_version}" < "9.99" &THEN
    "Estab" at 21
&ENDIF
    "EspÇcie" at 27
    "SÇrie" at 35
    "Emiss∆o" at 41
    "Vencimento" at 52
    "Portador" at 63
    "Cart" at 72
    "Cliente" to 87
    "Nome" at 89
    "Convànio" at 130
    "Vl Original" to 155 skip
    "----------------" at 1
    "--" at 18
&IF "{&emsfin_version}" >= "" AND "{&emsfin_version}" < "5.07A" &THEN
    "-----" at 21
&ENDIF
&IF "{&emsfin_version}" >= "5.07A" AND "{&emsfin_version}" < "9.99" &THEN
    "-----" at 21
&ENDIF
    "-------" at 27
    "-----" at 35
    "----------" at 41
    "----------" at 52
    "--------" at 63
    "----" at 72
    "-----------" to 87
    "----------------------------------------" at 89
    "---------" at 130
    "--------------" to 155 skip
    with no-box no-labels width 155 page-top stream-io.
def frame f_rpt_s_1_Grp_detalhe_Lay_vencimento header
    "Vencimento" at 1
    "/P" at 12
&IF "{&emsfin_version}" >= "" AND "{&emsfin_version}" < "5.07A" &THEN
    "Estab" at 15
&ENDIF
&IF "{&emsfin_version}" >= "5.07A" AND "{&emsfin_version}" < "9.99" &THEN
    "Estab" at 15
&ENDIF
    "EspÇcie" at 21
    "SÇrie" at 29
    "Emiss∆o" at 35
    "Portador" at 46
    "Cart" at 55
    "Cliente" to 70
    "T°tulo" at 72
    "Nome" at 89
    "Convànio" at 130
    "Vl Original" to 155 skip
    "----------" at 1
    "--" at 12
&IF "{&emsfin_version}" >= "" AND "{&emsfin_version}" < "5.07A" &THEN
    "-----" at 15
&ENDIF
&IF "{&emsfin_version}" >= "5.07A" AND "{&emsfin_version}" < "9.99" &THEN
    "-----" at 15
&ENDIF
    "-------" at 21
    "-----" at 29
    "----------" at 35
    "--------" at 46
    "----" at 55
    "-----------" to 70
    "----------------" at 72
    "----------------------------------------" at 89
    "---------" at 130
    "--------------" to 155 skip
    with no-box no-labels width 155 page-top stream-io.
def frame f_rpt_s_1_Grp_livro_Lay_abert header
    skip (3)
    "T E R M O  D E  A B E R T U R A     " at 51
    skip (1)
    entry(1, return-value, chr(255)) at 38 format "x(60)" skip
    with no-box no-labels width 155 page-top stream-io.
def frame f_rpt_s_1_Grp_livro_Lay_encert header
    skip (3)
    "T E R M O  D E  E N C E R R A M E N T O     " at 47
    skip (1)
    entry(1, return-value, chr(255)) at 39 format "x(60)" skip
    with no-box no-labels width 155 page-top stream-io.
def frame f_rpt_s_1_Grp_parametros_Lay_filtro header
    skip (1)
    skip (1)
    "-----------------------------------" at 24
    "Filtro " at 60
    "-----------------------------------" at 74
    skip (1)
    "  Normal: " at 46
    v_log_normal at 56 format "Sim/N∆o" view-as text
    "  Transf. UN: " at 71
    v_log_transf_unid_negoc_1 at 85 format "Sim/N∆o" view-as text skip
    "  Cheques: " at 45
    v_log_cheq_recbdo at 56 format "Sim/N∆o" view-as text
    "   Transf. Est: " at 69
    v_log_transf_estab_1 at 85 format "Sim/N∆o" view-as text skip
    "   Aviso de DB: " at 40
    v_log_aviso_db at 56 format "Sim/N∆o" view-as text
    "   Renegociaá∆o: " at 68
    v_log_renegoc at 85 format "Sim/N∆o" view-as text skip
    "Estornados: " at 44
    v_log_tit_acr_estordo at 56 format "Sim/N∆o" view-as text
    "   Implantaá∆o: " at 69
    v_log_impl_1 at 85 format "Sim/N∆o" view-as text skip
    with no-box no-labels width 155 page-top stream-io.
def frame f_rpt_s_1_Grp_parametros_Lay_filtro_vdr header
    skip (1)
    "  Vendor: " at 46
    v_log_mostra_docto_vendor at 56 format "Sim/N∆o" view-as text skip
    "    Vendor Repactuado: " at 33
    v_log_mostra_docto_vendor_repac at 56 format "Sim/N∆o" view-as text skip
    with no-box no-labels width 155 page-top stream-io.
def frame f_rpt_s_1_Grp_parametros_Lay_param header
    skip (1)
    skip (1)
    "-----------------------------------" at 24
    "ParÉmetros" at 60
    "-----------------------------------" at 73
    /* Vari†vel v_cod_empres_usuar ignorada. N∆o esta definida no programa */
    skip (2)
    "   Atualiza P†gina: " at 47
    v_log_atualiz_numer_pag at 67 format "Sim/N∆o" view-as text skip
    "    Emite Termo Encert: " at 43
    v_log_emit_termo at 67 format "Sim/N∆o" view-as text skip
    "Estornados: " at 55
    v_log_tit_acr_estordo at 67 format "Sim/N∆o" view-as text skip
    "  Emiss∆o: " at 56
    v_dat_emis_docto_ini at 67 format "99/99/9999" view-as text skip
    "atÇ: " at 62
    v_dat_emis_docto_fim at 67 format "99/99/9999" view-as text
    skip (1)
    "-----------------------------------" at 23
    "Classificaá∆o" at 59
    "-----------------------------------" at 73
    skip (1)
    "   Classificaá∆o: " at 49
    v_ind_classif_tit_acr_emitid at 67 format "x(20)" view-as text skip
    with no-box no-labels width 155 page-top stream-io.
def frame f_rpt_s_1_Grp_parametros_Lay_selec header
    skip (1)
    skip (1)
    "-----------------------------------" at 26
    "Seleá∆o" at 62
    "-----------------------------------" at 72
    skip (1)
    "   Estab Selec: " at 41
    entry(1, return-value, chr(255)) at 57 format "x(30)" skip
    "  EspÇcie: " at 46
    v_cod_espec_docto_ini at 57 format "x(3)" view-as text
    "atÇ: " at 75
    v_cod_espec_docto_fim at 80 format "x(3)" view-as text skip
    "  SÇrie: " at 48
    v_cod_ser_docto_ini at 57 format "x(5)" view-as text
    "atÇ: " at 75
    v_cod_ser_docto_fim at 80 format "x(5)" view-as text skip
    "  Cliente: " at 46
    v_cdn_cliente_ini to 67 format ">>>,>>>,>>9" view-as text
    "atÇ: " at 75
    v_cdn_cliente_fim to 90 format ">>>,>>>,>>9" view-as text skip
    "Grupo Cliente: " at 42
    v_cod_grp_clien_ini at 57 format "x(4)" view-as text
    "atÇ: " at 75
    v_cod_grp_clien_fim at 80 format "x(4)" view-as text skip
    " Portador: " at 46
    v_cod_portador_ini at 57 format "x(5)" view-as text
    "atÇ: " at 75
    v_cod_portador_fim at 80 format "x(5)" view-as text skip
    "Carteira: " at 47
    v_cod_cart_bcia_ini at 57 format "x(3)" view-as text
    "atÇ: " at 75
    v_cod_cart_bcia_fim at 80 format "x(3)" view-as text skip
    "Vencimento: " at 45
    v_dat_vencto_tit_acr_ini at 57 format "99/99/9999" view-as text
    "atÇ: " at 75
    v_dat_vencto_tit_acr_fim at 80 format "99/99/9999" view-as text skip
    with no-box no-labels width 155 page-top stream-io.
def frame f_rpt_s_1_Grp_total_Lay_clien header
    "--------------" at 142 skip
    "    Qtde T°tulos Cliente: " at 73
    v_qtd_tot_clien to 107 format "->>>>,>>9" view-as text
    "    Total do Cliente: " at 109
    v_val_tot_clien to 155 format "->>,>>>,>>>,>>9.99" view-as text skip (1)
    with no-box no-labels width 155 page-top stream-io.
def frame f_rpt_s_1_Grp_total_Lay_espec header
    "--------------" at 142 skip
    "    Qtde T°tulos EspÇcie: " at 77
    v_qtd_tit_espec to 111 format "->>>>,>>9" view-as text
    "   Total EspÇcie: " at 113
    v_val_tot_espec to 155 format "->>,>>>,>>>,>>9.99" view-as text skip (1)
    with no-box no-labels width 155 page-top stream-io.
def frame f_rpt_s_1_Grp_total_Lay_period header
    "--------------" at 142 skip
    "    Qtde Total T°tulos: " at 76
    v_qtd_tot_period to 108 format "->>>>,>>9" view-as text
    "   Total do Per°odo: " at 110
    v_val_tot_period to 155 format "->>,>>>,>>>,>>9.99" view-as text skip
    with no-box no-labels width 155 page-top stream-io.
def frame f_rpt_s_1_Grp_total_Lay_tot_grp_cli header
    "--------------" at 142 skip
    "    Qtde Tit Grp Cliente: " at 70
    v_qtd_tot_grp_clien to 104 format "->>>>,>>9" view-as text
    "    Total Grupo Cliente: " at 106
    v_val_tot_grp_clien to 155 format "->>,>>>,>>>,>>9.99" view-as text skip (1)
    with no-box no-labels width 155 page-top stream-io.


/*************************** Report Definition End **************************/

/************************** Frame Definition Begin **************************/

def frame f_fil_01_tit_acr_emitidos
    rt_002
         at row 01.50 col 31.00
    " Transaá∆o " view-as text
         at row 01.20 col 33.00 bgcolor 8 
    rt_001
         at row 01.50 col 02.00
    " Espec. Docto. " view-as text
         at row 01.20 col 04.00 bgcolor 8 
    rt_003
         at row 07.88 col 01.86
    " Considera T°tulos " view-as text
         at row 07.58 col 03.86 bgcolor 8 
    rt_cxcf
         at row 10.63 col 02.00 bgcolor 7 
    v_log_normal
         at row 02.25 col 03.14 label "Normal"
         view-as toggle-box
    v_log_cheq_recbdo
         at row 03.25 col 03.14 label "Cheques Recebidos"
         view-as toggle-box
    v_log_aviso_db
         at row 04.25 col 03.14 label "Aviso de DÇbito"
         help "Aviso de DÇbito"
         view-as toggle-box
    v_log_mostra_docto_vendor
         at row 05.25 col 03.14 label "Vendor"
         help "T°tulos de EspÇcie Vendor"
         view-as toggle-box
    v_log_mostra_docto_vendor_repac
         at row 06.25 col 03.14 label "Vendor Repactuado"
         help "T°tulos com EspÇcie Vendor Repactuado"
         view-as toggle-box
    v_log_tit_acr_estordo
         at row 08.83 col 03.14 label "Estornados que n∆o Contabilizam"
         view-as toggle-box
    v_log_transf_unid_negoc_1
         at row 02.50 col 32.14 label "Transf Unid Neg¢cio"
         view-as toggle-box
    v_log_transf_estab_1
         at row 03.75 col 32.14 label "Transf Estabelecimento"
         view-as toggle-box
    v_log_renegoc
         at row 05.00 col 32.14 label "Renegociaá∆o"
         view-as toggle-box
    v_log_impl_1
         at row 06.25 col 32.14 label "Implantaá∆o"
         view-as toggle-box
    bt_ok
         at row 10.83 col 03.00 font ?
         help "OK"
    bt_can
         at row 10.83 col 14.00 font ?
         help "Cancela"
    bt_hel2
         at row 10.83 col 48.57 font ?
         help "Ajuda"
    with 1 down side-labels no-validate keep-tab-order three-d
         size-char 61.00 by 12.46 default-button bt_ok
         view-as dialog-box
         font 1 fgcolor ? bgcolor 8
         title "Filtro T°tulo Contas a Receber".
    /* adjust size of objects in this frame */
    assign bt_can:width-chars   in frame f_fil_01_tit_acr_emitidos = 10.00
           bt_can:height-chars  in frame f_fil_01_tit_acr_emitidos = 01.00
           bt_hel2:width-chars  in frame f_fil_01_tit_acr_emitidos = 10.00
           bt_hel2:height-chars in frame f_fil_01_tit_acr_emitidos = 01.00
           bt_ok:width-chars    in frame f_fil_01_tit_acr_emitidos = 10.00
           bt_ok:height-chars   in frame f_fil_01_tit_acr_emitidos = 01.00
           rt_001:width-chars   in frame f_fil_01_tit_acr_emitidos = 28.00
           rt_001:height-chars  in frame f_fil_01_tit_acr_emitidos = 05.88
           rt_002:width-chars   in frame f_fil_01_tit_acr_emitidos = 28.57
           rt_002:height-chars  in frame f_fil_01_tit_acr_emitidos = 05.88
           rt_003:width-chars   in frame f_fil_01_tit_acr_emitidos = 58.00
           rt_003:height-chars  in frame f_fil_01_tit_acr_emitidos = 02.00
           rt_cxcf:width-chars  in frame f_fil_01_tit_acr_emitidos = 57.57
           rt_cxcf:height-chars in frame f_fil_01_tit_acr_emitidos = 01.42.
    /* set private-data for the help system */
    assign v_log_normal:private-data                    in frame f_fil_01_tit_acr_emitidos = "HLP=000022923":U
           v_log_cheq_recbdo:private-data               in frame f_fil_01_tit_acr_emitidos = "HLP=000024099":U
           v_log_aviso_db:private-data                  in frame f_fil_01_tit_acr_emitidos = "HLP=000024098":U
           v_log_mostra_docto_vendor:private-data       in frame f_fil_01_tit_acr_emitidos = "HLP=000016651":U
           v_log_mostra_docto_vendor_repac:private-data in frame f_fil_01_tit_acr_emitidos = "HLP=000016651":U
           v_log_tit_acr_estordo:private-data           in frame f_fil_01_tit_acr_emitidos = "HLP=000023771":U
           v_log_transf_unid_negoc_1:private-data       in frame f_fil_01_tit_acr_emitidos = "HLP=000016651":U
           v_log_transf_estab_1:private-data            in frame f_fil_01_tit_acr_emitidos = "HLP=000024101":U
           v_log_renegoc:private-data                   in frame f_fil_01_tit_acr_emitidos = "HLP=000024094":U
           v_log_impl_1:private-data                    in frame f_fil_01_tit_acr_emitidos = "HLP=000024100":U
           bt_ok:private-data                           in frame f_fil_01_tit_acr_emitidos = "HLP=000010721":U
           bt_can:private-data                          in frame f_fil_01_tit_acr_emitidos = "HLP=000011050":U
           bt_hel2:private-data                         in frame f_fil_01_tit_acr_emitidos = "HLP=000011326":U
           frame f_fil_01_tit_acr_emitidos:private-data                                    = "HLP=000016651".

def frame f_rpt_41_tit_acr_emitidos
    rt_004
         at row 01.50 col 41.57
    " Seleá∆o " view-as text
         at row 01.20 col 43.57 bgcolor 8 
    rt_001
         at row 01.50 col 02.00
    " ParÉmetros " view-as text
         at row 01.20 col 04.00 bgcolor 8 
    rt_006
         at row 02.46 col 03.29
    " Relat¢rio " view-as text
         at row 02.16 col 05.29 bgcolor 8 
    rt_target
         at row 12.46 col 02.00
    " Destino " view-as text
         at row 12.16 col 04.00 bgcolor 8 
    rt_run
         at row 12.46 col 48.00
    " Execuá∆o " view-as text
         at row 12.16 col 50.00
    rt_dimensions
         at row 12.46 col 72.72
    " Dimens‰es " view-as text
         at row 12.16 col 74.72
    rt_005
         at row 06.75 col 03.29
    " Emiss∆o " view-as text
         at row 06.45 col 05.29 bgcolor 8 
    rt_002
         at row 10.38 col 01.86
    " Classificaá∆o " view-as text
         at row 10.08 col 03.86 bgcolor 8 
    rt_007
         at row 10.38 col 82.72 bgcolor 8 
    rt_cxcf
         at row 15.96 col 02.00 bgcolor 7 
    v_log_atualiz_numer_pag
         at row 03.50 col 04.43 label "Atualiza P†gina"
         help "Atualiza a Numeraá∆o das P†ginas?"
         view-as toggle-box
    v_num_ult_pag
         at row 03.50 col 29.00 colon-aligned label "Ult Pag"
         help "Èltima P†gina j† emitida."
         view-as fill-in
         size-chars 8.14 by .88
         fgcolor ? bgcolor 15 font 2
    v_log_emit_termo
         at row 04.75 col 04.43 label "Emite Termo Encerramento"
         help "Emite o Termo de Encerramento ?"
         view-as toggle-box
    v_dat_emis_docto_ini
         at row 07.67 col 10.43 colon-aligned label "Inicial"
         help "Data Emiss∆o Documento"
         view-as fill-in
         size-chars 11.14 by .88
         fgcolor ? bgcolor 15 font 2
    v_dat_emis_docto_fim
         at row 07.67 col 25.86 colon-aligned label "atÇ"
         help "Data Emiss∆o Documento"
         view-as fill-in
         size-chars 11.14 by .88
         fgcolor ? bgcolor 15 font 2
    v_des_estab_select
         at row 01.79 col 50.57 colon-aligned label "Estab Selec"
         help "Estabelecimentos selecionados"
         view-as editor max-chars 2000 no-word-wrap
         size 30 by 1
         bgcolor 15 font 2
    bt_todos_img
         at row 01.79 col 82.57 font ?
         help "Seleciona Todos"
    v_cod_espec_docto_ini
         at row 02.88 col 50.57 colon-aligned label "EspÇcie"
         help "C¢digo Inicial"
         view-as fill-in
         size-chars 4.14 by .88
         fgcolor ? bgcolor 15 font 2
    v_cod_espec_docto_fim
         at row 02.88 col 70.00 colon-aligned label "atÇ"
         help "C¢digo Final"
         view-as fill-in
         size-chars 4.14 by .88
         fgcolor ? bgcolor 15 font 2
    v_cod_ser_docto_ini
         at row 03.88 col 50.57 colon-aligned label "SÇrie"
         help "C¢digo SÇrie Documento"
         view-as fill-in
         size-chars 4.14 by .88
         fgcolor ? bgcolor 15 font 2
    v_cod_ser_docto_fim
         at row 03.88 col 70.00 colon-aligned label "atÇ"
         help "C¢digo SÇrie Documento"
         view-as fill-in
         size-chars 4.14 by .88
         fgcolor ? bgcolor 15 font 2
    v_cdn_cliente_ini
         at row 04.88 col 50.57 colon-aligned label "Cliente"
         help "C¢digo do Cliente Inicial"
         view-as fill-in
         size-chars 12.14 by .88
         fgcolor ? bgcolor 15 font 2
    bt_zoo_185301
         at row 04.88 col 64.71
    v_cdn_cliente_fim
         at row 04.88 col 70.00 colon-aligned label "atÇ"
         help "C¢digo do Cliente Final"
         view-as fill-in
         size-chars 12.14 by .88
         fgcolor ? bgcolor 15 font 2
    bt_zoo_185300
         at row 04.88 col 84.14
    v_cod_grp_clien_ini
         at row 05.88 col 50.57 colon-aligned label "Grp Cliente"
         help "C¢digo Grupo Cliente"
         view-as fill-in
         size-chars 5.14 by .88
         fgcolor ? bgcolor 15 font 2
    v_cod_grp_clien_fim
         at row 05.88 col 70.00 colon-aligned label "atÇ"
         help "C¢digo Grupo Cliente"
         view-as fill-in
         size-chars 5.14 by .88
         fgcolor ? bgcolor 15 font 2
    v_cod_portador_ini
         at row 06.88 col 50.57 colon-aligned label "Portador"
         help "C¢digo Portador Inicial"
         view-as fill-in
         size-chars 6.14 by .88
         fgcolor ? bgcolor 15 font 2
    v_cod_portador_fim
         at row 06.88 col 70.00 colon-aligned label "atÇ"
         help "C¢digo Portador"
         view-as fill-in
         size-chars 6.14 by .88
         fgcolor ? bgcolor 15 font 2
    v_cod_cart_bcia_ini
         at row 07.88 col 50.57 colon-aligned label "Carteira"
         help "Carteira Banc†ria"
         view-as fill-in
         size-chars 4.14 by .88
         fgcolor ? bgcolor 15 font 2
    v_cod_cart_bcia_fim
         at row 07.88 col 70.00 colon-aligned label "atÇ"
         help "Carteira Banc†ria"
         view-as fill-in
         size-chars 4.14 by .88
         fgcolor ? bgcolor 15 font 2
    v_dat_vencto_tit_acr_ini
         at row 08.88 col 50.57 colon-aligned label "Vencto"
         help "Data Vencimento T°tulo"
         view-as fill-in
         size-chars 11.14 by .88
         fgcolor ? bgcolor 15 font 2
    v_dat_vencto_tit_acr_fim
         at row 08.88 col 70.00 colon-aligned label "atÇ"
         help "Data Vencimento T°tulo"
         view-as fill-in
         size-chars 11.14 by .88
         fgcolor ? bgcolor 15 font 2
    v_ind_classif_tit_acr_emitid
         at row 10.83 col 02.29 no-label
         help "Classificaá∆o dos T°tulos Emitidos"
         view-as radio-set Horizontal
         radio-buttons "Por Emiss∆o", "Por Emiss∆o", "Por T°tulo", "Por T°tulo", "Por Cliente", "Por Cliente", "Por Grupo Cliente", "Por Grupo Cliente", "Por Vencimento", "Por Vencimento"
          /*l_por_emissao*/ /*l_por_emissao*/ /*l_por_titulo*/ /*l_por_titulo*/ /*l_por_cliente*/ /*l_por_cliente*/ /*l_por_grupo_cliente*/ /*l_por_grupo_cliente*/ /*l_por_vencimento*/ /*l_por_vencimento*/
         bgcolor 8 
    bt_fil2
         at row 10.67 col 83.57 font ?
         help "Filtro"
    rs_cod_dwb_output
         at row 13.17 col 03.00
         help "" no-label
    ed_1x40
         at row 14.13 col 03.00
         help "" no-label
    bt_get_file
         at row 14.13 col 42.00 font ?
         help "Pesquisa Arquivo"
    bt_set_printer
         at row 14.13 col 42.00 font ?
         help "Define Impressora e Layout de Impress∆o"
    rs_ind_run_mode
         at row 13.17 col 49.00
         help "" no-label
    v_log_print_par
         at row 14.17 col 49.00 label "Imprime ParÉmetros"
         view-as toggle-box
    v_qtd_line
         at row 13.17 col 81.00 colon-aligned
         view-as fill-in
         size-chars 4.14 by .88
         fgcolor ? bgcolor 15 font 2
    v_qtd_column
         at row 14.17 col 81.00 colon-aligned
         view-as fill-in
         size-chars 4.14 by .88
         fgcolor ? bgcolor 15 font 2
    bt_close
         at row 16.17 col 03.00 font ?
         help "Fecha"
    bt_print
         at row 16.17 col 14.00 font ?
         help "Imprime"
    bt_can
         at row 16.17 col 25.00 font ?
         help "Cancela"
    bt_hel2
         at row 16.17 col 77.57 font ?
         help "Ajuda"
    with 1 down side-labels no-validate keep-tab-order three-d
         size-char 90.00 by 17.79
         view-as dialog-box
         font 1 fgcolor ? bgcolor 8
         title "Relat¢rio T°tulos Emitidos Contas a Receber".
    /* adjust size of objects in this frame */
    assign bt_can:width-chars          in frame f_rpt_41_tit_acr_emitidos = 10.00
           bt_can:height-chars         in frame f_rpt_41_tit_acr_emitidos = 01.00
           bt_close:width-chars        in frame f_rpt_41_tit_acr_emitidos = 10.00
           bt_close:height-chars       in frame f_rpt_41_tit_acr_emitidos = 01.00
           bt_fil2:width-chars         in frame f_rpt_41_tit_acr_emitidos = 04.00
           bt_fil2:height-chars        in frame f_rpt_41_tit_acr_emitidos = 01.13
           bt_get_file:width-chars     in frame f_rpt_41_tit_acr_emitidos = 04.00
           bt_get_file:height-chars    in frame f_rpt_41_tit_acr_emitidos = 01.08
           bt_hel2:width-chars         in frame f_rpt_41_tit_acr_emitidos = 10.00
           bt_hel2:height-chars        in frame f_rpt_41_tit_acr_emitidos = 01.00
           bt_print:width-chars        in frame f_rpt_41_tit_acr_emitidos = 10.00
           bt_print:height-chars       in frame f_rpt_41_tit_acr_emitidos = 01.00
           bt_set_printer:width-chars  in frame f_rpt_41_tit_acr_emitidos = 04.00
           bt_set_printer:height-chars in frame f_rpt_41_tit_acr_emitidos = 01.08
           bt_todos_img:width-chars    in frame f_rpt_41_tit_acr_emitidos = 04.00
           bt_todos_img:height-chars   in frame f_rpt_41_tit_acr_emitidos = 01.13
           ed_1x40:width-chars         in frame f_rpt_41_tit_acr_emitidos = 38.00
           ed_1x40:height-chars        in frame f_rpt_41_tit_acr_emitidos = 01.00
           rt_001:width-chars          in frame f_rpt_41_tit_acr_emitidos = 39.43
           rt_001:height-chars         in frame f_rpt_41_tit_acr_emitidos = 08.46
           rt_002:width-chars          in frame f_rpt_41_tit_acr_emitidos = 80.29
           rt_002:height-chars         in frame f_rpt_41_tit_acr_emitidos = 01.63
           rt_004:width-chars          in frame f_rpt_41_tit_acr_emitidos = 47.00
           rt_004:height-chars         in frame f_rpt_41_tit_acr_emitidos = 08.46
           rt_005:width-chars          in frame f_rpt_41_tit_acr_emitidos = 37.00
           rt_005:height-chars         in frame f_rpt_41_tit_acr_emitidos = 02.71
           rt_006:width-chars          in frame f_rpt_41_tit_acr_emitidos = 37.00
           rt_006:height-chars         in frame f_rpt_41_tit_acr_emitidos = 03.79
           rt_007:width-chars          in frame f_rpt_41_tit_acr_emitidos = 05.57
           rt_007:height-chars         in frame f_rpt_41_tit_acr_emitidos = 01.63
           rt_cxcf:width-chars         in frame f_rpt_41_tit_acr_emitidos = 86.57
           rt_cxcf:height-chars        in frame f_rpt_41_tit_acr_emitidos = 01.42
           rt_dimensions:width-chars   in frame f_rpt_41_tit_acr_emitidos = 15.72
           rt_dimensions:height-chars  in frame f_rpt_41_tit_acr_emitidos = 03.00
           rt_run:width-chars          in frame f_rpt_41_tit_acr_emitidos = 23.86
           rt_run:height-chars         in frame f_rpt_41_tit_acr_emitidos = 03.00
           rt_target:width-chars       in frame f_rpt_41_tit_acr_emitidos = 45.00
           rt_target:height-chars      in frame f_rpt_41_tit_acr_emitidos = 03.00.
    /* set return-inserted = yes for editors */
    assign v_des_estab_select:return-inserted in frame f_rpt_41_tit_acr_emitidos = yes
           ed_1x40:return-inserted            in frame f_rpt_41_tit_acr_emitidos = yes.
    /* set private-data for the help system */
    assign v_log_atualiz_numer_pag:private-data      in frame f_rpt_41_tit_acr_emitidos = "HLP=000019253":U
           v_num_ult_pag:private-data                in frame f_rpt_41_tit_acr_emitidos = "HLP=000019255":U
           v_log_emit_termo:private-data             in frame f_rpt_41_tit_acr_emitidos = "HLP=000024096":U
           v_dat_emis_docto_ini:private-data         in frame f_rpt_41_tit_acr_emitidos = "HLP=000014636":U
           v_dat_emis_docto_fim:private-data         in frame f_rpt_41_tit_acr_emitidos = "HLP=000014637":U
           v_des_estab_select:private-data           in frame f_rpt_41_tit_acr_emitidos = "HLP=000016651":U
           bt_todos_img:private-data                 in frame f_rpt_41_tit_acr_emitidos = "HLP=000021504":U
           v_cod_espec_docto_ini:private-data        in frame f_rpt_41_tit_acr_emitidos = "HLP=000016628":U
           v_cod_espec_docto_fim:private-data        in frame f_rpt_41_tit_acr_emitidos = "HLP=000016629":U
           v_cod_ser_docto_ini:private-data          in frame f_rpt_41_tit_acr_emitidos = "HLP=000016635":U
           v_cod_ser_docto_fim:private-data          in frame f_rpt_41_tit_acr_emitidos = "HLP=000016636":U
           bt_zoo_185301:private-data                in frame f_rpt_41_tit_acr_emitidos = "HLP=000009431":U
           v_cdn_cliente_ini:private-data            in frame f_rpt_41_tit_acr_emitidos = "HLP=000022353":U
           bt_zoo_185300:private-data                in frame f_rpt_41_tit_acr_emitidos = "HLP=000009431":U
           v_cdn_cliente_fim:private-data            in frame f_rpt_41_tit_acr_emitidos = "HLP=000022352":U
           v_cod_grp_clien_ini:private-data          in frame f_rpt_41_tit_acr_emitidos = "HLP=000023781":U
           v_cod_grp_clien_fim:private-data          in frame f_rpt_41_tit_acr_emitidos = "HLP=000023782":U
           v_cod_portador_ini:private-data           in frame f_rpt_41_tit_acr_emitidos = "HLP=000014638":U
           v_cod_portador_fim:private-data           in frame f_rpt_41_tit_acr_emitidos = "HLP=000014647":U
           v_cod_cart_bcia_ini:private-data          in frame f_rpt_41_tit_acr_emitidos = "HLP=000023778":U
           v_cod_cart_bcia_fim:private-data          in frame f_rpt_41_tit_acr_emitidos = "HLP=000016642":U
           v_dat_vencto_tit_acr_ini:private-data     in frame f_rpt_41_tit_acr_emitidos = "HLP=000023783":U
           v_dat_vencto_tit_acr_fim:private-data     in frame f_rpt_41_tit_acr_emitidos = "HLP=000023784":U
           v_ind_classif_tit_acr_emitid:private-data in frame f_rpt_41_tit_acr_emitidos = "HLP=000024097":U
           bt_fil2:private-data                      in frame f_rpt_41_tit_acr_emitidos = "HLP=000008766":U
           rs_cod_dwb_output:private-data            in frame f_rpt_41_tit_acr_emitidos = "HLP=000016651":U
           ed_1x40:private-data                      in frame f_rpt_41_tit_acr_emitidos = "HLP=000016651":U
           bt_get_file:private-data                  in frame f_rpt_41_tit_acr_emitidos = "HLP=000008782":U
           bt_set_printer:private-data               in frame f_rpt_41_tit_acr_emitidos = "HLP=000008785":U
           rs_ind_run_mode:private-data              in frame f_rpt_41_tit_acr_emitidos = "HLP=000016651":U
           v_log_print_par:private-data              in frame f_rpt_41_tit_acr_emitidos = "HLP=000024662":U
           v_qtd_line:private-data                   in frame f_rpt_41_tit_acr_emitidos = "HLP=000024737":U
           v_qtd_column:private-data                 in frame f_rpt_41_tit_acr_emitidos = "HLP=000024669":U
           bt_close:private-data                     in frame f_rpt_41_tit_acr_emitidos = "HLP=000009420":U
           bt_print:private-data                     in frame f_rpt_41_tit_acr_emitidos = "HLP=000010815":U
           bt_can:private-data                       in frame f_rpt_41_tit_acr_emitidos = "HLP=000011050":U
           bt_hel2:private-data                      in frame f_rpt_41_tit_acr_emitidos = "HLP=000011326":U
           frame f_rpt_41_tit_acr_emitidos:private-data                                 = "HLP=000016651".
    /* enable function buttons */
    assign bt_zoo_185301:sensitive in frame f_rpt_41_tit_acr_emitidos = yes
           bt_zoo_185300:sensitive in frame f_rpt_41_tit_acr_emitidos = yes.
    /* move buttons to top */
    bt_zoo_185301:move-to-top().
    bt_zoo_185300:move-to-top().



{include/i_fclfrm.i f_fil_01_tit_acr_emitidos f_rpt_41_tit_acr_emitidos }
/*************************** Frame Definition End ***************************/

/* tech38629 - Alteraá∆o efetuada via filtro */
&if '{&emsbas_version}':U >= '5.05':U &then
def var v_prog_filtro_pdf as handle no-undo.

function getCodTipoRelat returns character in v_prog_filtro_pdf.

run prgtec/btb/btb920aa.py persistent set v_prog_filtro_pdf.

run pi_define_objetos in v_prog_filtro_pdf (frame f_rpt_41_tit_acr_emitidos:handle,
                       rs_cod_dwb_output:handle in frame f_rpt_41_tit_acr_emitidos,
                       bt_get_file:row in frame f_rpt_41_tit_acr_emitidos,
                       bt_get_file:col in frame f_rpt_41_tit_acr_emitidos).

&endif
/* tech38629 - Fim da alteraá∆o */


/*********************** User Interface Trigger Begin ***********************/


ON CHOOSE OF bt_hel2 IN FRAME f_fil_01_tit_acr_emitidos
DO:


    /* Begin_Include: i_context_help_frame */
    run prgtec/men/men900za.py (Input self:frame,
                                Input this-procedure:handle) /*prg_fnc_chamar_help_context*/.


    /* End_Include: i_context_help_frame */

END. /* ON CHOOSE OF bt_hel2 IN FRAME f_fil_01_tit_acr_emitidos */

ON CHOOSE OF bt_fil2 IN FRAME f_rpt_41_tit_acr_emitidos
DO:

    define var wgh_popup_menu         as widget-handle no-undo.
    define var wgh_popup_menu_content as widget-handle no-undo.
    define var wgh_popup_menu_about   as widget-handle no-undo.
    define var wgh_popup_menu_rule    as widget-handle no-undo.

    create menu wgh_popup_menu
           assign popup-only = yes.

    create menu-item wgh_popup_menu_content
           assign label   = "Conte£do" /*l_conteudo*/  
                  parent  = wgh_popup_menu
           triggers :
                  on choose persistent
                     run prgtec/men/men900za.py (Input bt_hel2:frame in frame f_fil_01_tit_acr_emitidos,
                                                 Input this-procedure:handle) /* prg_fnc_chamar_help_context*/. /* fnc_chamar_help_context*/
           end triggers.


    create menu-item wgh_popup_menu_about
           assign label   = "Sobre" /*l_sobre*/  
                  parent  = wgh_popup_menu
           triggers :
                 on choose do:

                    /* Begin_Include: i_about_call */
                    assign v_nom_prog     = substring(current-window:title, 1, max(1, length(current-window:title) - 10))
                                          + chr(10)
                                          + "rpt_tit_acr_emitidos_convenio":U
                           v_nom_prog_ext = "intprg/nicr011.p":U
                           v_cod_release  = trim(" 1.00.00.039":U).
/*                    run prgtec/btb/btb901zb.p (Input v_nom_prog,
                                               Input v_nom_prog_ext,
                                               Input v_cod_release) /*prg_fnc_about*/. */
{include/sobre5.i}
                    /* End_Include: i_about_call */

                 end.
           end triggers.

    assign bt_hel2:POPUP-MENU IN FRAME f_fil_01_tit_acr_emitidos = wgh_popup_menu.

    view frame f_fil_01_tit_acr_emitidos.

    filter_block:
    do on error undo filter_block, retry filter_block:

        assign v_log_mostra_docto_vendor      :sensitive in frame f_fil_01_tit_acr_emitidos = v_log_modul_vendor.
               v_log_mostra_docto_vendor_repac:sensitive in frame f_fil_01_tit_acr_emitidos = v_log_modul_vendor.

        update v_log_normal
               v_log_cheq_recbdo
               v_log_aviso_db
               v_log_tit_acr_estordo
               v_log_mostra_docto_vendor       when v_log_modul_vendor
               v_log_mostra_docto_vendor_repac when v_log_modul_vendor
               v_log_transf_unid_negoc_1
               v_log_transf_estab_1
               v_log_renegoc
               v_log_impl_1
               bt_ok
               bt_can
               bt_hel2
               with frame f_fil_01_tit_acr_emitidos.

        assign input frame f_fil_01_tit_acr_emitidos v_log_normal
               input frame f_fil_01_tit_acr_emitidos v_log_cheq_recbdo
               input frame f_fil_01_tit_acr_emitidos v_log_aviso_db
               input frame f_fil_01_tit_acr_emitidos v_log_tit_acr_estordo
               input frame f_fil_01_tit_acr_emitidos v_log_transf_unid_negoc_1
               input frame f_fil_01_tit_acr_emitidos v_log_transf_estab_1
               input frame f_fil_01_tit_acr_emitidos v_log_renegoc
               input frame f_fil_01_tit_acr_emitidos v_log_impl_1.

        if  v_log_modul_vendor then
            assign input frame f_fil_01_tit_acr_emitidos v_log_mostra_docto_vendor
                   input frame f_fil_01_tit_acr_emitidos v_log_mostra_docto_vendor_repac.

    end /* do filter_block */.

    hide frame f_fil_01_tit_acr_emitidos.


END. /* ON CHOOSE OF bt_fil2 IN FRAME f_rpt_41_tit_acr_emitidos */

ON CHOOSE OF bt_get_file IN FRAME f_rpt_41_tit_acr_emitidos
DO:

    system-dialog get-file v_cod_dwb_file
        title "Imprimir" /*l_imprimir*/ 
        filters '*.rpt' '*.rpt',
                "*.*"   "*.*"
        save-as
        create-test-file
        ask-overwrite.
        assign dwb_rpt_param.cod_dwb_file             = v_cod_dwb_file
               ed_1x40:screen-value in frame f_rpt_41_tit_acr_emitidos = v_cod_dwb_file.

END. /* ON CHOOSE OF bt_get_file IN FRAME f_rpt_41_tit_acr_emitidos */

ON CHOOSE OF bt_hel2 IN FRAME f_rpt_41_tit_acr_emitidos
DO:


    /* Begin_Include: i_context_help_frame */
    run prgtec/men/men900za.py (Input self:frame,
                                Input this-procedure:handle) /*prg_fnc_chamar_help_context*/.


    /* End_Include: i_context_help_frame */

END. /* ON CHOOSE OF bt_hel2 IN FRAME f_rpt_41_tit_acr_emitidos */

ON CHOOSE OF bt_print IN FRAME f_rpt_41_tit_acr_emitidos
DO:

    assign input frame f_rpt_41_tit_acr_emitidos v_cdn_cliente_fim
           input frame f_rpt_41_tit_acr_emitidos v_cdn_cliente_ini
           input frame f_rpt_41_tit_acr_emitidos v_cod_grp_clien_ini
           input frame f_rpt_41_tit_acr_emitidos v_cod_grp_clien_fim
           input frame f_rpt_41_tit_acr_emitidos v_des_estab_select
           input frame f_rpt_41_tit_acr_emitidos v_cod_espec_docto_fim
           input frame f_rpt_41_tit_acr_emitidos v_cod_espec_docto_ini
           input frame f_rpt_41_tit_acr_emitidos v_cod_ser_docto_fim
           input frame f_rpt_41_tit_acr_emitidos v_cod_ser_docto_ini
           input frame f_rpt_41_tit_acr_emitidos v_dat_emis_docto_fim
           input frame f_rpt_41_tit_acr_emitidos v_dat_emis_docto_ini
           input frame f_rpt_41_tit_acr_emitidos v_dat_vencto_tit_acr_fim
           input frame f_rpt_41_tit_acr_emitidos v_dat_vencto_tit_acr_ini
           input frame f_rpt_41_tit_acr_emitidos v_ind_classif_tit_acr_emitid
           input frame f_rpt_41_tit_acr_emitidos v_log_atualiz_numer_pag
           input frame f_rpt_41_tit_acr_emitidos v_log_emit_termo
           input frame f_rpt_41_tit_acr_emitidos v_cod_portador_ini
           input frame f_rpt_41_tit_acr_emitidos v_cod_portador_fim
           input frame f_rpt_41_tit_acr_emitidos v_cod_cart_bcia_ini
           input frame f_rpt_41_tit_acr_emitidos v_cod_cart_bcia_fim.


    if  v_dat_emis_docto_ini > v_dat_emis_docto_fim
    then do:
        /* In°cio Per°odo maior que Fim Per°odo ! */
        run pi_messages (input "show",
                         input 1371,
                         input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")) /*msg_1371*/.
        return no-apply.
    end /* if */.

    if  v_log_normal      = no
    and v_log_cheq_recbdo = no
    and v_log_aviso_db    = no
    and v_log_mostra_docto_vendor       = no
    and v_log_mostra_docto_vendor_repac = no
    then do:    
        /* Tipo EspÇcie deve ser informado. */
        run pi_messages (input "show",
                         input 4320,
                         input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")) /*msg_4320*/.
        return no-apply. 
    end. 

    if  v_log_transf_unid_negoc_1 = no and
        v_log_transf_estab_1      = no and
        v_log_renegoc             = no and
        v_log_impl_1              = no
    then do:

        /* Transaá∆o deve ser informada. */
        run pi_messages (input "show",
                         input 4321,
                         input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")) /*msg_4321*/.
        return no-apply. 
    end.

    assign v_log_reemis = no.

    if  v_log_atualiz_numer_pag = yes
    then do:
        if  avail pag_livro_fisc
        then do:
            if  v_dat_emis_docto_ini > pag_livro_fisc.dat_fim_emis + 1
            then do:
                /* Data In°cio emiss∆o Ç incompat°vel com a £ltima emiss∆o ! */
                run pi_messages (input "show",
                                 input 2443,
                                 input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9",
                                                    v_dat_emis_docto_ini, pag_livro_fisc.dat_fim_emis)) /*msg_2443*/.
                return no-apply.
            end /* if */.
            if  v_dat_emis_docto_ini < pag_livro_fisc.dat_fim_emis + 1
            then do:
                if  not can-find(first pag_livro_fisc
                    where pag_livro_fisc.cod_unid_organ = livro_fisc.cod_unid_organ
                      and pag_livro_fisc.cod_modul_dtsul = livro_fisc.cod_modul_dtsul
                      and pag_livro_fisc.ind_tip_livro_fisc = livro_fisc.ind_tip_livro_fisc
                      and pag_livro_fisc.dat_inic_emis = v_dat_emis_docto_ini
                    use-index pglvrfs_dat_inic)
                then do:
                    /* Data In°cio diferente de outras emiss‰es j† efetuadas ! */
                    run pi_messages (input "show",
                                     input 2444,
                                     input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")) /*msg_2444*/.
                    return no-apply.
                 end /* if */.

                 assign v_log_reemis = yes.
            end /* if */.
        end /* if */.
    end /* if */.

    if  v_log_reemis = yes
    then do:
        run pi_messages (input "show",
                         input 3261,
                         input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")).
        assign v_log_answer = (if   return-value = "yes" then yes
                               else if return-value = "no" then no
                               else ?) /*msg_3261*/.
        if  v_log_answer = no
        then do:
            return no-apply.
        end /* if */.
    end /* if */.

do:
/* tech38629 - Alteraá∆o efetuada via filtro */
&if '{&emsbas_version}':U >= '5.05':U &then
    run pi_restricoes in v_prog_filtro_pdf (input rs_cod_dwb_output:screen-value in frame f_rpt_41_tit_acr_emitidos).
    if return-value = 'nok' then 
        return no-apply.
&endif
/* tech38629 - Fim da alteraá∆o */
    assign v_log_print = yes.
end.
END. /* ON CHOOSE OF bt_print IN FRAME f_rpt_41_tit_acr_emitidos */

ON CHOOSE OF bt_set_printer IN FRAME f_rpt_41_tit_acr_emitidos
DO:

    assign v_nom_dwb_printer      = ""
           v_cod_dwb_print_layout = "".

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
    if  v_nom_dwb_printer <> ""
    and  v_cod_dwb_print_layout <> ""
    then do:

        assign dwb_rpt_param.nom_dwb_printer      = v_nom_dwb_printer
               dwb_rpt_param.cod_dwb_print_layout = v_cod_dwb_print_layout.

        assign ed_1x40:screen-value in frame f_rpt_41_tit_acr_emitidos = v_nom_dwb_printer
                                                      + ":"
                                                      + v_cod_dwb_print_layout.

    end /* if */.


END. /* ON CHOOSE OF bt_set_printer IN FRAME f_rpt_41_tit_acr_emitidos */

ON CHOOSE OF bt_todos_img IN FRAME f_rpt_41_tit_acr_emitidos
DO:

    assign input frame f_rpt_41_tit_acr_emitidos v_des_estab_select.
    if  search('prgint/utb/utb071za.r') = ? and search('prgint/utb/utb071za.p') = ? then do:
        if  v_cod_dwb_user begins 'es_' then
            return 'Programa execut†vel n∆o foi encontrado:' /* l_programa_nao_encontrado*/  + 'prgint/utb/utb071za.p'.
        else do:
            message 'Programa execut†vel n∆o foi encontrado:' /* l_programa_nao_encontrado*/  'prgint/utb/utb071za.p'
                   view-as alert-box error buttons ok.
            return.
        end.
    end.
    else
        run prgint/utb/utb071za.p (Input "ACR" /*l_acr*/ ) /* prg_fnc_estabelecimento_selec_espec*/.

    display v_des_estab_select with frame f_rpt_41_tit_acr_emitidos.

END. /* ON CHOOSE OF bt_todos_img IN FRAME f_rpt_41_tit_acr_emitidos */

ON LEAVE OF ed_1x40 IN FRAME f_rpt_41_tit_acr_emitidos
DO:

    /************************* Variable Definition Begin ************************/

    def var v_cod_filename_final             as character       no-undo. /*local*/
    def var v_cod_filename_initial           as character       no-undo. /*local*/


    /************************** Variable Definition End *************************/

    block:
    do with frame f_rpt_41_tit_acr_emitidos:
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

END. /* ON LEAVE OF ed_1x40 IN FRAME f_rpt_41_tit_acr_emitidos */

ON VALUE-CHANGED OF rs_cod_dwb_output IN FRAME f_rpt_41_tit_acr_emitidos
DO:

    initout:
    do with frame f_rpt_41_tit_acr_emitidos:
        /* block: */
        case self:screen-value:
            when "Terminal" /*l_terminal*/ then ter:
             do:
                if  rs_cod_dwb_output <> "Impressora" /*l_printer*/ 
                then do:
                    assign v_qtd_line_ant = input frame f_rpt_41_tit_acr_emitidos v_qtd_line.
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
                        with frame f_rpt_41_tit_acr_emitidos.
                assign ed_1x40:screen-value   = ""
                       ed_1x40:sensitive      = no
                       bt_get_file:visible    = no
                       bt_set_printer:visible = no.
            end /* do ter */.
            when "Arquivo" /*l_file*/ then fil:
             do:
                if  rs_cod_dwb_output <> "Impressora" /*l_printer*/ 
                then do:
                    assign v_qtd_line_ant = input frame f_rpt_41_tit_acr_emitidos v_qtd_line.
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
                        with frame f_rpt_41_tit_acr_emitidos.
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

                    if  rs_ind_run_mode:screen-value in frame f_rpt_41_tit_acr_emitidos <> "Batch" /*l_batch*/ 
                    then do:
                        if  usuar_mestre.nom_dir_spool <> ""
                        then do:
                            assign dwb_rpt_param.cod_dwb_file = usuar_mestre.nom_dir_spool
                                                              + "~/".
                        end /* if */.
                    end /* if */.
                    if  usuar_mestre.nom_subdir_spool <> ""
                    then do:
                        assign dwb_rpt_param.cod_dwb_file = dwb_rpt_param.cod_dwb_file
                                                          + usuar_mestre.nom_subdir_spool
                                                          + "~/".
                    end /* if */.
                    if  v_cod_dwb_file_temp = ""
                    then do:
                        assign dwb_rpt_param.cod_dwb_file = dwb_rpt_param.cod_dwb_file
                                                          + caps("NICR011":U)
                                                          + '.rpt'.
                    end /* if */.
                    else do:
                        assign dwb_rpt_param.cod_dwb_file = dwb_rpt_param.cod_dwb_file
                                                          + v_cod_dwb_file_temp.
                    end /* else */.
                    assign ed_1x40:screen-value               = dwb_rpt_param.cod_dwb_file
                           dwb_rpt_param.cod_dwb_print_layout = ""
                           v_qtd_line                         = (if v_qtd_line_ant > 0 then v_qtd_line_ant else v_rpt_s_1_lines).
                end.     
            end /* do fil */.
            when "Impressora" /*l_printer*/ then prn:
             do:
                if  rs_cod_dwb_output <> "Impressora" /*l_printer*/  and rs_ind_run_mode <> "Batch" /*l_batch*/ 
                then do: 
                    assign v_qtd_line_ant = input frame f_rpt_41_tit_acr_emitidos v_qtd_line.
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
                        with frame f_rpt_41_tit_acr_emitidos.
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
                with frame f_rpt_41_tit_acr_emitidos.
    end /* if */.
    else do:
        enable v_qtd_line
               with frame f_rpt_41_tit_acr_emitidos.
    end /* else */.
    assign rs_cod_dwb_output.
END. /* ON VALUE-CHANGED OF rs_cod_dwb_output IN FRAME f_rpt_41_tit_acr_emitidos */

ON VALUE-CHANGED OF rs_ind_run_mode IN FRAME f_rpt_41_tit_acr_emitidos
DO:

    do  transaction:
        find dwb_rpt_param
            where dwb_rpt_param.cod_dwb_user    = v_cod_usuar_corren
            and   dwb_rpt_param.cod_dwb_program = v_cod_dwb_program
            exclusive-lock no-error.
        assign dwb_rpt_param.ind_dwb_run_mode = input frame f_rpt_41_tit_acr_emitidos rs_ind_run_mode.

        if  dwb_rpt_param.ind_dwb_run_mode = "Batch" /*l_batch*/ 
        then do:
            if  rs_cod_dwb_output:disable("Terminal" /*l_terminal*/ ) in frame f_rpt_41_tit_acr_emitidos
            then do:
            end /* if */.
        end /* if */.
        else do:
            if  rs_cod_dwb_output:enable("Terminal" /*l_terminal*/ ) in frame f_rpt_41_tit_acr_emitidos
            then do:
            end /* if */.
        end /* else */.
        if  rs_ind_run_mode = "Batch" /*l_batch*/ 
        then do:
           assign v_qtd_line = v_qtd_line_ant.
           display v_qtd_line
                   with frame f_rpt_41_tit_acr_emitidos.
        end /* if */.
        assign rs_ind_run_mode.
        apply "value-changed" to rs_cod_dwb_output in frame f_rpt_41_tit_acr_emitidos.
    end.    

END. /* ON VALUE-CHANGED OF rs_ind_run_mode IN FRAME f_rpt_41_tit_acr_emitidos */

ON VALUE-CHANGED OF v_log_atualiz_numer_pag IN FRAME f_rpt_41_tit_acr_emitidos
DO:

    if  v_log_atualiz_numer_pag:checked = yes
    then do:
        enable v_log_emit_termo
               with frame f_rpt_41_tit_acr_emitidos.
        assign v_cdn_cliente_ini       :screen-value in frame f_rpt_41_tit_acr_emitidos = string( 0 )
               v_cdn_cliente_fim       :screen-value in frame f_rpt_41_tit_acr_emitidos = string( 999999999 )
               v_cod_cart_bcia_ini     :screen-value in frame f_rpt_41_tit_acr_emitidos = "":U
               v_cod_cart_bcia_fim     :screen-value in frame f_rpt_41_tit_acr_emitidos = "ZZZ":U
               v_cod_espec_docto_ini   :screen-value in frame f_rpt_41_tit_acr_emitidos = "":U
               v_cod_espec_docto_fim   :screen-value in frame f_rpt_41_tit_acr_emitidos = "ZZZ":U
               v_cod_portador_ini      :screen-value in frame f_rpt_41_tit_acr_emitidos = "":U
               v_cod_portador_fim      :screen-value in frame f_rpt_41_tit_acr_emitidos = "ZZZZZ":U
               v_cod_ser_docto_ini     :screen-value in frame f_rpt_41_tit_acr_emitidos = "":U
               v_cod_ser_docto_fim     :screen-value in frame f_rpt_41_tit_acr_emitidos = "ZZZ":U
               v_dat_vencto_tit_acr_ini:screen-value in frame f_rpt_41_tit_acr_emitidos = string( &IF "{&ems_dbtype}":U = "MSS":U &THEN 01/01/1800 &ELSE 01/01/0001 &ENDIF )
               v_dat_vencto_tit_acr_fim:screen-value in frame f_rpt_41_tit_acr_emitidos = string( 12/31/9999 ).
        disable v_cdn_cliente_fim
                v_cdn_cliente_ini
                v_cod_cart_bcia_fim
                v_cod_cart_bcia_ini
                v_cod_espec_docto_fim
                v_cod_espec_docto_ini
                v_des_estab_select
                v_cod_portador_fim
                v_cod_portador_ini
                v_cod_ser_docto_fim
                v_cod_ser_docto_ini
                v_dat_vencto_tit_acr_fim
                v_dat_vencto_tit_acr_ini
                bt_fil2
                with frame f_rpt_41_tit_acr_emitidos.
         message "Filtro Desabilitado, Espec.: Normal e Transacao: Impl." /*l_filtro_desab*/ 
                view-as alert-box warning buttons ok.
    end /* if */.
    else do:
        assign v_log_emit_termo:checked = no.
        disable v_log_emit_termo
                with frame f_rpt_41_tit_acr_emitidos.
        enable v_cdn_cliente_fim
               v_cdn_cliente_ini
               v_cod_cart_bcia_fim
               v_cod_cart_bcia_ini
               v_cod_espec_docto_fim
               v_cod_espec_docto_ini
               v_cod_portador_fim
               v_cod_portador_ini
               v_cod_ser_docto_fim
               v_cod_ser_docto_ini
               v_dat_vencto_tit_acr_fim
               v_dat_vencto_tit_acr_ini
               bt_fil2
               with frame f_rpt_41_tit_acr_emitidos.
    end /* else */.

END. /* ON VALUE-CHANGED OF v_log_atualiz_numer_pag IN FRAME f_rpt_41_tit_acr_emitidos */


/************************ User Interface Trigger End ************************/

/************************** Function Trigger Begin **************************/


ON  CHOOSE OF bt_zoo_185300 IN FRAME f_rpt_41_tit_acr_emitidos
OR F5 OF v_cdn_cliente_fim IN FRAME f_rpt_41_tit_acr_emitidos DO:

    /* fn_generic_zoom_variable */
    if  search("prgint/ufn/ufn011ka.r") = ? and search("prgint/ufn/ufn011ka.p") = ? then do:
        if  v_cod_dwb_user begins 'es_' then
            return "Programa execut†vel n∆o foi encontrado:" /*l_programa_nao_encontrado*/  + "prgint/ufn/ufn011ka.p".
        else do:
            message "Programa execut†vel n∆o foi encontrado:" /*l_programa_nao_encontrado*/  "prgint/ufn/ufn011ka.p"
                   view-as alert-box error buttons ok.
            return.
        end.
    end.
    else
        run prgint/ufn/ufn011ka.p /*prg_sea_clien_financ*/.
    if  v_rec_clien_financ <> ?
    then do:
        find clien_financ where recid(clien_financ) = v_rec_clien_financ no-lock no-error.
        assign v_cdn_cliente_fim:screen-value in frame f_rpt_41_tit_acr_emitidos =
               string(clien_financ.cdn_cliente).

        apply "entry" to v_cdn_cliente_fim in frame f_rpt_41_tit_acr_emitidos.
    end /* if */.

end. /* ON  CHOOSE OF bt_zoo_185300 IN FRAME f_rpt_41_tit_acr_emitidos */

ON  CHOOSE OF bt_zoo_185301 IN FRAME f_rpt_41_tit_acr_emitidos
OR F5 OF v_cdn_cliente_ini IN FRAME f_rpt_41_tit_acr_emitidos DO:

    /* fn_generic_zoom_variable */
    if  search("prgint/ufn/ufn011ka.r") = ? and search("prgint/ufn/ufn011ka.p") = ? then do:
        if  v_cod_dwb_user begins 'es_' then
            return "Programa execut†vel n∆o foi encontrado:" /*l_programa_nao_encontrado*/  + "prgint/ufn/ufn011ka.p".
        else do:
            message "Programa execut†vel n∆o foi encontrado:" /*l_programa_nao_encontrado*/  "prgint/ufn/ufn011ka.p"
                   view-as alert-box error buttons ok.
            return.
        end.
    end.
    else
        run prgint/ufn/ufn011ka.p /*prg_sea_clien_financ*/.
    if  v_rec_clien_financ <> ?
    then do:
        find clien_financ where recid(clien_financ) = v_rec_clien_financ no-lock no-error.
        assign v_cdn_cliente_ini:screen-value in frame f_rpt_41_tit_acr_emitidos =
               string(clien_financ.cdn_cliente).

        apply "entry" to v_cdn_cliente_ini in frame f_rpt_41_tit_acr_emitidos.
    end /* if */.

end. /* ON  CHOOSE OF bt_zoo_185301 IN FRAME f_rpt_41_tit_acr_emitidos */


/*************************** Function Trigger End ***************************/

/**************************** Frame Trigger Begin ***************************/


ON HELP OF FRAME f_fil_01_tit_acr_emitidos ANYWHERE
DO:


    /* Begin_Include: i_context_help */
    run prgtec/men/men900za.py (Input self:handle,
                                Input this-procedure:handle) /*prg_fnc_chamar_help_context*/.
    /* End_Include: i_context_help */

END. /* ON HELP OF FRAME f_fil_01_tit_acr_emitidos */

ON RIGHT-MOUSE-DOWN OF FRAME f_fil_01_tit_acr_emitidos ANYWHERE
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

END. /* ON RIGHT-MOUSE-DOWN OF FRAME f_fil_01_tit_acr_emitidos */

ON RIGHT-MOUSE-UP OF FRAME f_fil_01_tit_acr_emitidos ANYWHERE
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

END. /* ON RIGHT-MOUSE-UP OF FRAME f_fil_01_tit_acr_emitidos */

ON WINDOW-CLOSE OF FRAME f_fil_01_tit_acr_emitidos
DO:

    apply "end-error" to self.
END. /* ON WINDOW-CLOSE OF FRAME f_fil_01_tit_acr_emitidos */

ON GO OF FRAME f_rpt_41_tit_acr_emitidos
DO:

    do transaction:
        find dwb_rpt_param
            where dwb_rpt_param.cod_dwb_user    = v_cod_usuar_corren
            and   dwb_rpt_param.cod_dwb_program = v_cod_dwb_program
            exclusive-lock no-error.
        assign dwb_rpt_param.cod_dwb_output     = rs_cod_dwb_output:screen-value in frame f_rpt_41_tit_acr_emitidos
               dwb_rpt_param.qtd_dwb_line       = input frame f_rpt_41_tit_acr_emitidos v_qtd_line
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

    assign input frame f_rpt_41_tit_acr_emitidos v_cdn_cliente_fim
           input frame f_rpt_41_tit_acr_emitidos v_cdn_cliente_ini
           input frame f_rpt_41_tit_acr_emitidos v_cod_grp_clien_ini
           input frame f_rpt_41_tit_acr_emitidos v_cod_grp_clien_fim
           input frame f_rpt_41_tit_acr_emitidos v_des_estab_select
           input frame f_rpt_41_tit_acr_emitidos v_cod_espec_docto_fim
           input frame f_rpt_41_tit_acr_emitidos v_cod_espec_docto_ini
           input frame f_rpt_41_tit_acr_emitidos v_cod_ser_docto_fim
           input frame f_rpt_41_tit_acr_emitidos v_cod_ser_docto_ini
           input frame f_rpt_41_tit_acr_emitidos v_dat_emis_docto_fim
           input frame f_rpt_41_tit_acr_emitidos v_dat_emis_docto_ini
           input frame f_rpt_41_tit_acr_emitidos v_dat_vencto_tit_acr_fim
           input frame f_rpt_41_tit_acr_emitidos v_dat_vencto_tit_acr_ini
           input frame f_rpt_41_tit_acr_emitidos v_ind_classif_tit_acr_emitid
           input frame f_rpt_41_tit_acr_emitidos v_log_atualiz_numer_pag
           input frame f_rpt_41_tit_acr_emitidos v_log_emit_termo
           input frame f_rpt_41_tit_acr_emitidos v_cod_portador_ini
           input frame f_rpt_41_tit_acr_emitidos v_cod_portador_fim
           input frame f_rpt_41_tit_acr_emitidos v_cod_cart_bcia_ini
           input frame f_rpt_41_tit_acr_emitidos v_cod_cart_bcia_fim.


END. /* ON GO OF FRAME f_rpt_41_tit_acr_emitidos */

ON ENDKEY OF FRAME f_rpt_41_tit_acr_emitidos
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

END. /* ON ENDKEY OF FRAME f_rpt_41_tit_acr_emitidos */

ON HELP OF FRAME f_rpt_41_tit_acr_emitidos ANYWHERE
DO:


    /* Begin_Include: i_context_help */
    run prgtec/men/men900za.py (Input self:handle,
                                Input this-procedure:handle) /*prg_fnc_chamar_help_context*/.
    /* End_Include: i_context_help */

END. /* ON HELP OF FRAME f_rpt_41_tit_acr_emitidos */

ON RIGHT-MOUSE-DOWN OF FRAME f_rpt_41_tit_acr_emitidos ANYWHERE
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

END. /* ON RIGHT-MOUSE-DOWN OF FRAME f_rpt_41_tit_acr_emitidos */

ON RIGHT-MOUSE-UP OF FRAME f_rpt_41_tit_acr_emitidos ANYWHERE
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

END. /* ON RIGHT-MOUSE-UP OF FRAME f_rpt_41_tit_acr_emitidos */

ON WINDOW-CLOSE OF FRAME f_rpt_41_tit_acr_emitidos
DO:

    apply "end-error" to self.
END. /* ON WINDOW-CLOSE OF FRAME f_rpt_41_tit_acr_emitidos */


/***************************** Frame Trigger End ****************************/

/**************************** Menu Trigger Begin ****************************/


ON CHOOSE OF MENU-ITEM mi_conteudo IN MENU m_help
DO:


        apply "choose" to bt_hel2 in frame f_rpt_41_tit_acr_emitidos.





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


        assign v_nom_prog     = substring(frame f_rpt_41_tit_acr_emitidos:title, 1, max(1, length(frame f_rpt_41_tit_acr_emitidos:title) - 10)).
        if  v_nom_prog = ? then
            assign v_nom_prog = "".

        assign v_nom_prog     = v_nom_prog
                              + chr(10)
                              + "rpt_tit_acr_emitidos_convenio":U.




    assign v_nom_prog_ext = "intprg/nicr011.p":U
           v_cod_release  = trim(" 1.00.00.039":U).
/*    run prgtec/btb/btb901zb.p (Input v_nom_prog,
                               Input v_nom_prog_ext,
                               Input v_cod_release) /*prg_fnc_about*/. */
{include/sobre5.i}
END. /* ON CHOOSE OF MENU-ITEM mi_sobre IN MENU m_help */


/***************************** Menu Trigger End *****************************/


/****************************** Main Code Begin *****************************/


/* Begin_Include: i_version_extract */
{include/i-ctrlrp5.i rpt_tit_acr_emitidos}


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
    run pi_version_extract ('rpt_tit_acr_emitidos':U, 'intprg/nicr011.p':U, '1.00.00.039':U, 'pro':U).
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
    run prgtec/men/men901za.py (Input 'rpt_tit_acr_emitidos') /*prg_fnc_verify_security*/.
if  return-value = "2014"
then do:
    /* Programa a ser executado n∆o Ç um programa v†lido Datasul ! */
    run pi_messages (input "show",
                     input 2014,
                     input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9",
                                       'rpt_tit_acr_emitidos')) /*msg_2014*/.
    return.
end /* if */.
if  return-value = "2012"
then do:
    /* Usu†rio sem permiss∆o para acessar o programa. */
    run pi_messages (input "show",
                     input 2012,
                     input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9",
                                       'rpt_tit_acr_emitidos')) /*msg_2012*/.
    return.
end /* if */.
/* End_Include: i_verify_security */



/* Begin_Include: i_log_exec_prog_dtsul_ini */
assign v_rec_log = ?.

if can-find(prog_dtsul
       where prog_dtsul.cod_prog_dtsul = 'rpt_tit_acr_emitidos' 
         and prog_dtsul.log_gera_log_exec = yes) then do transaction:
    create log_exec_prog_dtsul.
    assign log_exec_prog_dtsul.cod_prog_dtsul           = 'rpt_tit_acr_emitidos'
           log_exec_prog_dtsul.cod_usuario              = v_cod_usuar_corren
           log_exec_prog_dtsul.dat_inic_exec_prog_dtsul = today
           log_exec_prog_dtsul.hra_inic_exec_prog_dtsul = replace(string(time,"hh:mm:ss" /*l_hh:mm:ss*/ ),":":U,"":U).
    assign v_rec_log = recid(log_exec_prog_dtsul).
    release log_exec_prog_dtsul no-error.
end.


/* End_Include: i_log_exec_prog_dtsul_ini */

/* tech38629 - Alteraá∆o efetuada via filtro */
&if '{&emsbas_version}':U >= '5.05':U &then
run pi_permissoes in v_prog_filtro_pdf (input 'rpt_tit_acr_emitidos':U).
&endif
/* tech38629 - Fim da alteraá∆o */




/* Begin_Include: i_verify_program_epc */
&if '{&emsbas_version}' > '1.00' &then
assign v_rec_table_epc = ?
       v_wgh_frame_epc = ?.

find prog_dtsul
    where prog_dtsul.cod_prog_dtsul = "rpt_tit_acr_emitidos":U
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


assign v_wgh_frame_epc = frame f_rpt_41_tit_acr_emitidos:handle.



assign v_nom_table_epc = 'tit_acr':U
       v_rec_table_epc = recid(tit_acr).

&endif

/* End_Include: i_verify_program_epc */


/* redefiniá‰es do frame */

/* Begin_Include: i_std_dialog_box */
/* tratamento do titulo e vers∆o */
assign frame f_rpt_41_tit_acr_emitidos:title = frame f_rpt_41_tit_acr_emitidos:title
                            + chr(32)
                            + chr(40)
                            + trim(" 1.00.00.039":U)
                            + chr(41).
/* menu pop-up de ajuda e sobre */
assign menu m_help:popup-only = yes
       bt_hel2:popup-menu in frame f_rpt_41_tit_acr_emitidos = menu m_help:handle.


/* End_Include: i_std_dialog_box */
{include/title5.i f_rpt_41_tit_acr_emitidos FRAME}


/* inicializa vari†veis */
find empresa no-lock
     where empresa.cod_empresa = v_cod_empres_usuar /*cl_empres_usuar of empresa*/ no-error.
find dwb_rpt_param
     where dwb_rpt_param.cod_dwb_program = "rel_tit_emit_acr":U
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
assign v_cod_dwb_proced   = "rel_tit_emit_acr":U
       v_cod_dwb_program  = "rel_tit_emit_acr":U
       v_cod_release      = trim(" 1.00.00.039":U)
       v_ind_dwb_run_mode = "On-Line" /*l_online*/ 
       v_qtd_column       = v_rpt_s_1_columns
       v_qtd_bottom       = v_rpt_s_1_bottom.
if (avail empresa) then
    assign v_nom_enterprise   = empresa.nom_razao_social.
else
    assign v_nom_enterprise   = 'DATASUL'.


/* Begin_Include: ix_p00_rpt_tit_acr_emitidos */

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


/* Begin_Include: i_declara_GetDefinedFunction */
FUNCTION GetDefinedFunction RETURNS LOGICAL (INPUT SPP AS CHARACTER):

    DEF VAR v_log_retorno AS LOGICAL INITIAL NO NO-UNDO.

    IF CAN-FIND (FIRST histor_exec_especial NO-LOCK
         WHERE histor_exec_especial.cod_modul_dtsul = "UFN" /* l_ufn*/ 
           AND histor_exec_especial.cod_prog_dtsul  = SPP) THEN
        ASSIGN v_log_retorno = YES.


    /* Begin_Include: i_funcao_extract */
    if  v_cod_arq <> '' and v_cod_arq <> ?
    then do:

        output stream s-arq to value(v_cod_arq) append.

        put stream s-arq unformatted
            SPP      at 1 
            v_log_retorno  at 43 skip.

        output stream s-arq close.

    end /* if */.
    /* End_Include: i_funcao_extract */
    .

    RETURN v_log_retorno.
END FUNCTION.
/* End_Include: i_declara_GetDefinedFunction */


run pi_verifica_vendor /*pi_verifica_vendor*/.
assign v_log_mostra_docto_vendor       = no
       v_log_mostra_docto_vendor_repac = no.

assign v_log_pessoa_fisic_cobr = &IF DEFINED (BF_FIN_ENDER_COB_PESSOA_FISIC) &THEN YES &ELSE GetDefinedFunction('SPP_ENDER_COB_PESSOA_FISIC':U) &ENDIF.

assign v_cod_ser_docto_ini:width  in frame f_rpt_41_tit_acr_emitidos = 06.14
       v_cod_ser_docto_fim:width  in frame f_rpt_41_tit_acr_emitidos = 06.14
       v_cod_ser_docto_ini:format in frame f_rpt_41_tit_acr_emitidos = 'x(5)'
       v_cod_ser_docto_fim:format in frame f_rpt_41_tit_acr_emitidos = 'x(5)'.

/* End_Include: i_declara_GetDefinedFunction */


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
    if (ped_exec.cod_release_prog_dtsul <> trim(" 1.00.00.039":U)) then
        return "Vers‰es do programa diferente." /*1994*/ + " (" + "1994" + ")" + chr(10)
                                     + substitute("A vers∆o do programa (&3) que gerou o pedido de execuá∆o batch (&1) Ç diferente da vers∆o do programa que deveria executar o pedido batch (&2)." /*1994*/,ped_exec.cod_release_prog_dtsul,
                                                  trim(" 1.00.00.039":U),
                                                  "intprg/nicr011.p":U).
    assign v_nom_prog_ext     = caps("acr302aa":U)
           v_dat_execution    = today
           v_hra_execution    = replace(string(time, "hh:mm:ss" /*l_hh:mm:ss*/ ), ":", "")
           v_cod_dwb_file     = dwb_rpt_param.cod_dwb_file
           v_nom_report_title = fill(" ", 40 - length(v_rpt_s_1_name)) + v_rpt_s_1_name
           v_ind_dwb_run_mode = "Batch" /*l_batch*/ .


    /* Begin_Include: ix_p02_rpt_tit_acr_emitidos */
    assign v_log_atualiz_numer_pag      = (entry(3, dwb_rpt_param.cod_dwb_parameters, chr(10)) = "yes" /*l_yes*/ )
           v_log_emit_termo             = (entry(4, dwb_rpt_param.cod_dwb_parameters, chr(10)) = "yes" /*l_yes*/ )
           v_dat_emis_docto_ini         = date(entry(5, dwb_rpt_param.cod_dwb_parameters, chr(10)))
           v_dat_emis_docto_fim         = date(entry(6, dwb_rpt_param.cod_dwb_parameters, chr(10)))
           v_ind_classif_tit_acr_emitid = entry(7, dwb_rpt_param.cod_dwb_parameters, chr(10))
           v_cod_espec_docto_ini        = entry(8, dwb_rpt_param.cod_dwb_parameters, chr(10))
           v_cod_espec_docto_fim        = entry(9, dwb_rpt_param.cod_dwb_parameters, chr(10))
           v_cod_ser_docto_ini          = entry(10, dwb_rpt_param.cod_dwb_parameters, chr(10))
           v_cod_ser_docto_fim          = entry(11, dwb_rpt_param.cod_dwb_parameters, chr(10))
           v_cdn_cliente_ini            = integer(entry(12, dwb_rpt_param.cod_dwb_parameters, chr(10)))
           v_cdn_cliente_fim            = integer(entry(13, dwb_rpt_param.cod_dwb_parameters, chr(10)))
           v_dat_vencto_tit_acr_ini     = date(entry(14, dwb_rpt_param.cod_dwb_parameters, chr(10)))
           v_dat_vencto_tit_acr_fim     = date(entry(15, dwb_rpt_param.cod_dwb_parameters, chr(10)))
           v_cod_portador_ini           = entry(16, dwb_rpt_param.cod_dwb_parameters, chr(10))
           v_cod_portador_fim           = entry(17, dwb_rpt_param.cod_dwb_parameters, chr(10))
           v_cod_cart_bcia_ini          = entry(18, dwb_rpt_param.cod_dwb_parameters, chr(10))
           v_cod_cart_bcia_fim          = entry(19, dwb_rpt_param.cod_dwb_parameters, chr(10))
           v_log_reemis                 = entry(20, dwb_rpt_param.cod_dwb_parameters, chr(10)) = "yes" /*l_yes*/ 
           v_log_tit_acr_estordo        = entry(21, dwb_rpt_param.cod_dwb_parameters, chr(10)) = "yes" /*l_yes*/ 
           v_log_normal                 = entry(22, dwb_rpt_param.cod_dwb_parameters, chr(10)) = "yes" /*l_yes*/ 
           v_log_cheq_recbdo            = entry(23, dwb_rpt_param.cod_dwb_parameters, chr(10)) = "yes" /*l_yes*/ 
           v_log_aviso_db               = entry(24, dwb_rpt_param.cod_dwb_parameters, chr(10)) = "yes" /*l_yes*/ 
           v_log_transf_unid_negoc_1    = entry(25, dwb_rpt_param.cod_dwb_parameters, chr(10)) = "yes" /*l_yes*/ 
           v_log_transf_estab_1         = entry(26, dwb_rpt_param.cod_dwb_parameters, chr(10)) = "yes" /*l_yes*/ 
           v_log_renegoc                = entry(27, dwb_rpt_param.cod_dwb_parameters, chr(10)) = "yes" /*l_yes*/ 
           v_log_impl_1                 = entry(28, dwb_rpt_param.cod_dwb_parameters, chr(10)) = "yes" /*l_yes*/ 
           v_cod_grp_clien_ini          = entry(29, dwb_rpt_param.cod_dwb_parameters, chr(10))
           v_cod_grp_clien_fim          = entry(30, dwb_rpt_param.cod_dwb_parameters, chr(10)).

    if  dwb_rpt_param.cod_dwb_parameters <> ""
    and num-entries(dwb_rpt_param.cod_dwb_parameters, chr(10)) >= 31
    and v_log_modul_vendor then     
        assign v_log_mostra_docto_vendor       = (entry(31,dwb_rpt_param.cod_dwb_parameters, chr(10)) = "yes" /*l_yes*/ )
               v_log_mostra_docto_vendor_repac = (entry(32,dwb_rpt_param.cod_dwb_parameters, chr(10)) = "yes" /*l_yes*/ ) no-error.

    if  dwb_rpt_param.cod_dwb_parameters <> ""
    and num-entries(dwb_rpt_param.cod_dwb_parameters, chr(10)) >= 33 then
        assign v_des_estab_select = entry(33,dwb_rpt_param.cod_dwb_parameters, chr(10)).

    find livro_fisc no-lock
         where livro_fisc.cod_unid_organ     = v_cod_empres_usuar
           and livro_fisc.cod_modul_dtsul    = "ACR" /*l_acr*/ 
           and livro_fisc.ind_tip_livro_fisc = "T°tulos Emitidos" /*l_titulos_emitidos*/ 
         use-index lvrfsca_id no-error.

    /* **
     Retorna Finalidade do Estabelecimento Corrente
    ***/
    run pi_retornar_finalid_econ_corren_estab (Input v_cod_estab_usuar,
                                               output v_cod_finalid_econ) /*pi_retornar_finalid_econ_corren_estab*/.                                          
    /* End_Include: ix_p02_rpt_tit_acr_emitidos */


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

        /* ix_p29_rpt_tit_acr_emitidos */

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


        /* Begin_Include: ix_p30_rpt_tit_acr_emitidos */
        if (line-counter(s_1) + 14) > v_rpt_s_1_bottom then
            page stream s_1.
        put stream s_1 unformatted 
            skip (1)
            skip (1)
            "-----------------------------------" at 24
            "ParÉmetros" at 60
            "-----------------------------------" at 73
            skip (1)
            "Empresa: " at 58.
        put stream s_1 unformatted 
            v_cod_empres_usuar at 67 format "x(3)" skip
            "   Atualiza P†gina: " at 47
            v_log_atualiz_numer_pag at 67 format "Sim/N∆o" skip
            "    Emite Termo Encert: " at 43
            v_log_emit_termo at 67 format "Sim/N∆o" skip
            "Estornados: " at 55
            v_log_tit_acr_estordo at 67 format "Sim/N∆o" skip
            "  Emiss∆o: " at 56
            v_dat_emis_docto_ini at 67 format "99/99/9999" skip
            "atÇ: " at 62.
        put stream s_1 unformatted 
            v_dat_emis_docto_fim at 67 format "99/99/9999"
            skip (1)
            "-----------------------------------" at 23
            "Classificaá∆o" at 59
            "-----------------------------------" at 73
            skip (1)
            "   Classificaá∆o: " at 49
            v_ind_classif_tit_acr_emitid at 67 format "x(20)" skip.
        if (line-counter(s_1) + 8) > v_rpt_s_1_bottom then
            page stream s_1.
        put stream s_1 unformatted 
            skip (1)
            skip (1)
            "-----------------------------------" at 24
            "Filtro " at 60
            "-----------------------------------" at 74
            skip (1)
            "  Normal: " at 46.
        put stream s_1 unformatted 
            v_log_normal at 56 format "Sim/N∆o"
            "  Transf. UN: " at 71
            v_log_transf_unid_negoc_1 at 85 format "Sim/N∆o" skip
            "  Cheques: " at 45
            v_log_cheq_recbdo at 56 format "Sim/N∆o"
            "   Transf. Est: " at 69
            v_log_transf_estab_1 at 85 format "Sim/N∆o" skip
            "   Aviso de DB: " at 40
            v_log_aviso_db at 56 format "Sim/N∆o"
            "   Renegociaá∆o: " at 68.
        put stream s_1 unformatted 
            v_log_renegoc at 85 format "Sim/N∆o" skip
            "Estornados: " at 44
            v_log_tit_acr_estordo at 56 format "Sim/N∆o"
            "   Implantaá∆o: " at 69
            v_log_impl_1 at 85 format "Sim/N∆o" skip.
        if  v_log_modul_vendor then do:
            if (line-counter(s_1) + 3) > v_rpt_s_1_bottom then
                page stream s_1.
            put stream s_1 unformatted 
                skip (1)
                "  Vendor: " at 46
                v_log_mostra_docto_vendor at 56 format "Sim/N∆o" skip
                "    Vendor Repactuado: " at 33
                v_log_mostra_docto_vendor_repac at 56 format "Sim/N∆o" skip.
        end.
        run pi_print_editor ("s_1", v_des_estab_select, "     030", "", "     ", "", "     ").
        put stream s_1 unformatted 
            skip (1)
            skip (1)
            "-----------------------------------" at 26
            "Seleá∆o" at 62
            "-----------------------------------" at 72
            skip (1)
            "   Estab Selec: " at 41
            entry(1, return-value, chr(255)) at 57 format "x(30)" skip.
        run pi_print_editor ("s_1", v_des_estab_select, "at057030", "", "", "", "").
        put stream s_1 unformatted 
            "  EspÇcie: " at 46
            v_cod_espec_docto_ini at 57 format "x(3)"
            "atÇ: " at 75
            v_cod_espec_docto_fim at 80 format "x(3)" skip
            "  SÇrie: " at 48
            v_cod_ser_docto_ini at 57 format "x(5)"
            "atÇ: " at 75
            v_cod_ser_docto_fim at 80 format "x(5)" skip
            "  Cliente: " at 46
            v_cdn_cliente_ini to 67 format ">>>,>>>,>>9".
        put stream s_1 unformatted 
            "atÇ: " at 75
            v_cdn_cliente_fim to 90 format ">>>,>>>,>>9" skip
            "Grupo Cliente: " at 42
            v_cod_grp_clien_ini at 57 format "x(4)"
            "atÇ: " at 75
            v_cod_grp_clien_fim at 80 format "x(4)" skip
            " Portador: " at 46
            v_cod_portador_ini at 57 format "x(5)"
            "atÇ: " at 75
            v_cod_portador_fim at 80 format "x(5)" skip.
        put stream s_1 unformatted 
            "Carteira: " at 47
            v_cod_cart_bcia_ini at 57 format "x(3)"
            "atÇ: " at 75
            v_cod_cart_bcia_fim at 80 format "x(3)" skip
            "Vencimento: " at 45
            v_dat_vencto_tit_acr_ini at 57 format "99/99/9999"
            "atÇ: " at 75
            v_dat_vencto_tit_acr_fim at 80 format "99/99/9999" skip.

        /* End_Include: ix_p30_rpt_tit_acr_emitidos */


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
view frame f_rpt_41_tit_acr_emitidos.

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
    do with frame f_rpt_41_tit_acr_emitidos:
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
                with frame f_rpt_41_tit_acr_emitidos.
    end /* do init */.

    display v_qtd_column
            v_qtd_line
            with frame f_rpt_41_tit_acr_emitidos.


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
           bt_get_file
           bt_set_printer
           bt_close
           bt_print
           bt_can
           bt_hel2
           bt_fil2
           with frame f_rpt_41_tit_acr_emitidos.


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



    apply "value-changed" to rs_cod_dwb_output in frame f_rpt_41_tit_acr_emitidos.


    if  yes = yes
    then do:
       enable rs_ind_run_mode
              with frame f_rpt_41_tit_acr_emitidos.
       apply "value-changed" to rs_ind_run_mode in frame f_rpt_41_tit_acr_emitidos.
    end /* if */.



    /* Begin_Include: ix_p10_rpt_tit_acr_emitidos */
    if  dwb_rpt_param.cod_dwb_parameters <> ''
    and (num-entries( dwb_rpt_param.cod_dwb_parameters, chr(10) ) = 30
    or num-entries(dwb_rpt_param.cod_dwb_parameters, chr(10))  >= 31
    or num-entries(dwb_rpt_param.cod_dwb_parameters, chr(10))  >= 33) then do:
        assign v_log_atualiz_numer_pag      = (entry(3, dwb_rpt_param.cod_dwb_parameters, chr(10)) = "yes" /*l_yes*/ )
               v_log_emit_termo             = (entry(4, dwb_rpt_param.cod_dwb_parameters, chr(10)) = "yes" /*l_yes*/ )
               v_dat_emis_docto_ini         = date(entry(5, dwb_rpt_param.cod_dwb_parameters, chr(10)))
               v_dat_emis_docto_fim         = date(entry(6, dwb_rpt_param.cod_dwb_parameters, chr(10)))
               v_ind_classif_tit_acr_emitid = entry(7, dwb_rpt_param.cod_dwb_parameters, chr(10))
               v_cod_espec_docto_ini        = entry(8, dwb_rpt_param.cod_dwb_parameters, chr(10))
               v_cod_espec_docto_fim        = entry(9, dwb_rpt_param.cod_dwb_parameters, chr(10))
               v_cod_ser_docto_ini          = entry(10, dwb_rpt_param.cod_dwb_parameters, chr(10))
               v_cod_ser_docto_fim          = entry(11, dwb_rpt_param.cod_dwb_parameters, chr(10))
               v_cdn_cliente_ini            = integer(entry(12, dwb_rpt_param.cod_dwb_parameters, chr(10)))
               v_cdn_cliente_fim            = integer(entry(13, dwb_rpt_param.cod_dwb_parameters, chr(10)))
               v_dat_vencto_tit_acr_ini     = date(entry(14, dwb_rpt_param.cod_dwb_parameters, chr(10)))
               v_dat_vencto_tit_acr_fim     = date(entry(15, dwb_rpt_param.cod_dwb_parameters, chr(10)))
               v_cod_portador_ini           = entry(16, dwb_rpt_param.cod_dwb_parameters, chr(10))
               v_cod_portador_fim           = entry(17, dwb_rpt_param.cod_dwb_parameters, chr(10))
               v_cod_cart_bcia_ini          = entry(18, dwb_rpt_param.cod_dwb_parameters, chr(10))
               v_cod_cart_bcia_fim          = entry(19, dwb_rpt_param.cod_dwb_parameters, chr(10))
               v_log_reemis                 = entry(20, dwb_rpt_param.cod_dwb_parameters, chr(10)) = "yes" /*l_yes*/ 
               v_log_tit_acr_estordo        = entry(21, dwb_rpt_param.cod_dwb_parameters, chr(10)) = "yes" /*l_yes*/ 
               v_log_normal                 = entry(22, dwb_rpt_param.cod_dwb_parameters, chr(10)) = "yes" /*l_yes*/ 
               v_log_cheq_recbdo            = entry(23, dwb_rpt_param.cod_dwb_parameters, chr(10)) = "yes" /*l_yes*/ 
               v_log_aviso_db               = entry(24, dwb_rpt_param.cod_dwb_parameters, chr(10)) = "yes" /*l_yes*/ 
               v_log_transf_unid_negoc_1    = entry(25, dwb_rpt_param.cod_dwb_parameters, chr(10)) = "yes" /*l_yes*/ 
               v_log_transf_estab_1         = entry(26, dwb_rpt_param.cod_dwb_parameters, chr(10)) = "yes" /*l_yes*/ 
               v_log_renegoc                = entry(27, dwb_rpt_param.cod_dwb_parameters, chr(10)) = "yes" /*l_yes*/ 
               v_log_impl_1                 = entry(28, dwb_rpt_param.cod_dwb_parameters, chr(10)) = "yes" /*l_yes*/ 
               v_cod_grp_clien_ini          = entry(29, dwb_rpt_param.cod_dwb_parameters, chr(10))
               v_cod_grp_clien_fim          = entry(30, dwb_rpt_param.cod_dwb_parameters, chr(10)).

        if  num-entries(dwb_rpt_param.cod_dwb_parameters, chr(10)) >= 31
        and v_log_modul_vendor then     
            assign v_log_mostra_docto_vendor       = (entry(31,dwb_rpt_param.cod_dwb_parameters, chr(10)) = "yes" /*l_yes*/ )
                   v_log_mostra_docto_vendor_repac = (entry(32,dwb_rpt_param.cod_dwb_parameters, chr(10)) = "yes" /*l_yes*/ ) no-error.
        if num-entries(dwb_rpt_param.cod_dwb_parameters , chr(10)) >= 33 then do:
            if entry(33, dwb_rpt_param.cod_dwb_parameters, chr(10)) <> "" then do:
                assign v_des_estab_select = entry(33, dwb_rpt_param.cod_dwb_parameters, chr(10)).
                run pi_vld_estab_select (input "ACR" /*l_acr*/ ).
            end.
            else do:
               assign v_des_estab_select = "".
               run pi_vld_permissao_usuar_estab_empres (Input "ACR" /*l_acr*/ ).
            end.
        end.               
    end.
    else do:
        assign v_log_atualiz_numer_pag      = no
               v_log_emit_termo             = no
               v_dat_emis_docto_ini         = today
               v_dat_emis_docto_fim         = today
               v_ind_classif_tit_acr_emitid = "Por Emiss∆o" /*l_por_emissao*/ 
               v_cod_espec_docto_ini        = "":U
               v_cod_espec_docto_fim        = "ZZZ":U
               v_cod_ser_docto_ini          = "":U
               v_cod_ser_docto_fim          = 'ZZZZZ':U
               v_cdn_cliente_ini            = 0
               v_cdn_cliente_fim            = 999999999
               v_cod_grp_clien_ini          = "":U
               v_cod_grp_clien_fim          = "ZZZZ":U
               v_dat_vencto_tit_acr_ini     = &IF "{&ems_dbtype}":U = "MSS":U &THEN 01/01/1800 &ELSE 01/01/0001 &ENDIF
               v_dat_vencto_tit_acr_fim     = 12/31/9999
               v_cod_portador_ini           = "":U
               v_cod_portador_fim           = "ZZZZZ":U
               v_cod_cart_bcia_ini          = "":U
               v_cod_cart_bcia_fim          = "ZZZ":U
               v_log_reemis                 = no
               v_log_tit_acr_estordo        = no
               v_log_normal                 = yes
               v_log_cheq_recbdo            = no
               v_log_aviso_db               = no
               v_log_transf_unid_negoc_1    = no
               v_log_transf_estab_1         = no
               v_log_renegoc                = no
               v_log_impl_1                 = yes.
    end.

    find empresa no-lock
         where empresa.cod_empresa = v_cod_empres_usuar /*cl_empres_usuar of empresa*/ no-error.

    find livro_fisc no-lock
         where livro_fisc.cod_unid_organ     = v_cod_empres_usuar
           and livro_fisc.cod_modul_dtsul    = "ACR" /*l_acr*/ 
           and livro_fisc.ind_tip_livro_fisc = "T°tulos Emitidos" /*l_titulos_emitidos*/ 
         use-index lvrfsca_id no-error.
    if  not avail livro_fisc
    then do:
        if  not avail livro_fisc
        then do:
            /* Livro Fiscal inexistente ! */
            run pi_messages (input "show",
                             input 2437,
                             input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9",
                                                "T°tulos Emitidos" /*l_titulos_emitidos*/ , v_cod_empres_usuar, "ACR" /*l_acr*/)) /*msg_2437*/.
            return.
        end /* if */.
    end /* if */.

    find first pag_livro_fisc no-lock
         where pag_livro_fisc.cod_modul_dtsul = livro_fisc.cod_modul_dtsul
           and pag_livro_fisc.cod_unid_organ = livro_fisc.cod_unid_organ
           and pag_livro_fisc.ind_tip_livro_fisc = livro_fisc.ind_tip_livro_fisc
          no-error.
    if  avail pag_livro_fisc
    then do:
        assign v_num_ult_pag        = pag_livro_fisc.num_ult_pag
               v_dat_emis_docto_ini = pag_livro_fisc.dat_fim_emis + 1.
    end /* if */.
    else do:
        assign v_num_ult_pag = 0.
    end /* else */.
    run pi_retornar_ult_dia_mes (Input v_dat_emis_docto_ini,
                                 output v_dat_emis_docto_fim) /*pi_retornar_ult_dia_mes*/.

    display v_des_estab_select
            bt_todos_img
            v_cdn_cliente_fim
            v_cdn_cliente_ini
            v_cod_grp_clien_ini
            v_cod_grp_clien_fim
            v_cod_espec_docto_fim
            v_cod_espec_docto_ini
            v_cod_ser_docto_fim
            v_cod_ser_docto_ini
            v_dat_emis_docto_fim
            v_dat_emis_docto_ini
            v_dat_vencto_tit_acr_fim
            v_dat_vencto_tit_acr_ini
            v_cod_portador_ini
            v_cod_portador_fim
            v_cod_cart_bcia_ini
            v_cod_cart_bcia_fim
            v_ind_classif_tit_acr_emitid
            v_log_atualiz_numer_pag
            v_log_emit_termo
            v_num_ult_pag
            with frame f_rpt_41_tit_acr_emitidos.
    enable bt_todos_img
           v_cdn_cliente_fim
           v_cdn_cliente_ini
           v_cod_grp_clien_ini
           v_cod_grp_clien_fim
           v_cod_espec_docto_fim
           v_cod_espec_docto_ini
           v_cod_ser_docto_fim
           v_cod_ser_docto_ini
           v_dat_emis_docto_fim
           v_dat_emis_docto_ini
           v_dat_vencto_tit_acr_fim
           v_dat_vencto_tit_acr_ini
           v_cod_portador_ini
           v_cod_portador_fim
           v_cod_cart_bcia_ini
           v_cod_cart_bcia_fim
           v_ind_classif_tit_acr_emitid
           v_log_atualiz_numer_pag
           with frame f_rpt_41_tit_acr_emitidos.

    disable v_des_estab_select
            with frame f_rpt_41_tit_acr_emitidos.

    apply "value-changed" to v_log_atualiz_numer_pag in frame f_rpt_41_tit_acr_emitidos.
    /* End_Include: ix_p10_rpt_tit_acr_emitidos */


    block1:
    repeat on error undo block1, retry block1:

        main_block:
        repeat on error undo super_block, retry super_block
                        on endkey undo super_block, leave super_block
                        on stop undo super_block, retry super_block
                        with frame f_rpt_41_tit_acr_emitidos:

            if (retry) then
                output stream s_1 close.
            assign v_log_print = no.
            if  valid-handle(v_wgh_focus) then
                wait-for go of frame f_rpt_41_tit_acr_emitidos focus v_wgh_focus.
            else
                wait-for go of frame f_rpt_41_tit_acr_emitidos.

            param_block:
            do transaction:

                /* Begin_Include: ix_p15_rpt_tit_acr_emitidos */
                assign dwb_rpt_param.cod_dwb_parameters = ""                                + chr(10) +
                                                          ""                                + chr(10) +
                                                          string(v_log_atualiz_numer_pag)   + chr(10) +
                                                          string(v_log_emit_termo)          + chr(10) +
                                                          string(v_dat_emis_docto_ini)      + chr(10) +
                                                          string(v_dat_emis_docto_fim)      + chr(10) +
                                                          v_ind_classif_tit_acr_emitid      + chr(10) +
                                                          v_cod_espec_docto_ini             + chr(10) +
                                                          v_cod_espec_docto_fim             + chr(10) +
                                                          v_cod_ser_docto_ini               + chr(10) +
                                                          v_cod_ser_docto_fim               + chr(10) +
                                                          string(v_cdn_cliente_ini)         + chr(10) +
                                                          string(v_cdn_cliente_fim)         + chr(10) +
                                                          string(v_dat_vencto_tit_acr_ini)  + chr(10) +
                                                          string(v_dat_vencto_tit_acr_fim)  + chr(10) +
                                                          v_cod_portador_ini                + chr(10) +
                                                          v_cod_portador_fim                + chr(10) +
                                                          v_cod_cart_bcia_ini               + chr(10) +
                                                          v_cod_cart_bcia_fim               + chr(10) +
                                                          string(v_log_reemis)              + chr(10) +
                                                          string(v_log_tit_acr_estordo)     + chr(10) +                                          
                                                          string(v_log_normal)              + chr(10) +                                          
                                                          string(v_log_cheq_recbdo)         + chr(10) +
                                                          string(v_log_aviso_db)            + chr(10) +
                                                          string(v_log_transf_unid_negoc_1) + chr(10) +
                                                          string(v_log_transf_estab_1)      + chr(10) +
                                                          string(v_log_renegoc)             + chr(10) +
                                                          string(v_log_impl_1)              + chr(10) +
                                                          v_cod_grp_clien_ini               + chr(10) +
                                                          v_cod_grp_clien_fim.

                /* ==> MODULO VENDOR <== */
                assign dwb_rpt_param.cod_dwb_parameters = if v_log_modul_vendor = yes then dwb_rpt_param.cod_dwb_parameters + chr(10) + string(v_log_mostra_docto_vendor) + chr(10) + string(v_log_mostra_docto_vendor_repac)
                                                          else dwb_rpt_param.cod_dwb_parameters + chr(10) + "" + chr(10) + "".

                assign dwb_rpt_param.cod_dwb_parameters = dwb_rpt_param.cod_dwb_parameters + chr(10) + v_des_estab_select.
                /* **
                 Retorna Finalidade do Estabelecimento Corrente
                ***/
                run pi_retornar_finalid_econ_corren_estab (Input v_cod_estab_usuar,
                                                           output v_cod_finalid_econ) /*pi_retornar_finalid_econ_corren_estab*/.

                /* **
                 Valida faixa e FE para relat¢rios fiscais
                ***/
                vld_block:
                do on error undo main_block, retry main_block:
                    if  v_cod_grp_clien_ini           > v_cod_grp_clien_fim              then do:
                        /* &1 Inicial deve ser menor ou igual a(o) &1 Final ! */
                        run pi_messages (input "show",
                                         input 5123,
                                         input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9",
                                                            "Grupo Cliente")) /*msg_5123*/.
                        assign v_wgh_focus = v_cod_grp_clien_ini:handle in frame f_rpt_41_tit_acr_emitidos.
                        undo main_block.
                    end.
                    run pi_vld_valores_relatorio_fiscal_acr /*pi_vld_valores_relatorio_fiscal_acr*/.
                end /* do vld_block */.
                /* End_Include: ix_p15_rpt_tit_acr_emitidos */

                assign dwb_rpt_param.log_dwb_print_parameters = input frame f_rpt_41_tit_acr_emitidos v_log_print_par
                       dwb_rpt_param.ind_dwb_run_mode         = input frame f_rpt_41_tit_acr_emitidos rs_ind_run_mode
                       input frame f_rpt_41_tit_acr_emitidos v_qtd_line.

                assign dwb_rpt_param.cod_dwb_parameters = ""                                + chr(10) +
""                                + chr(10) +
string(v_log_atualiz_numer_pag)   + chr(10) +
string(v_log_emit_termo)          + chr(10) +
string(v_dat_emis_docto_ini)      + chr(10) +
string(v_dat_emis_docto_fim)      + chr(10) +
v_ind_classif_tit_acr_emitid      + chr(10) +
v_cod_espec_docto_ini             + chr(10) +
v_cod_espec_docto_fim             + chr(10) +
v_cod_ser_docto_ini               + chr(10) +
v_cod_ser_docto_fim               + chr(10) +
string(v_cdn_cliente_ini)         + chr(10) +
string(v_cdn_cliente_fim)         + chr(10) +
string(v_dat_vencto_tit_acr_ini)  + chr(10) +
string(v_dat_vencto_tit_acr_fim)  + chr(10) +
v_cod_portador_ini                + chr(10) +
v_cod_portador_fim                + chr(10) +
v_cod_cart_bcia_ini               + chr(10) +
v_cod_cart_bcia_fim               + chr(10) +
string(v_log_reemis)              + chr(10) +
string(v_log_tit_acr_estordo)     + chr(10) +
string(v_log_normal)              + chr(10) +
string(v_log_cheq_recbdo)         + chr(10) +
string(v_log_aviso_db)            + chr(10) +
string(v_log_transf_unid_negoc_1) + chr(10) +
string(v_log_transf_estab_1)      + chr(10) +
string(v_log_renegoc)             + chr(10) +
string(v_log_impl_1)              + chr(10) +
v_cod_grp_clien_ini               + chr(10) +
v_cod_grp_clien_fim               + chr(10) +
string(v_log_mostra_docto_vendor) + chr(10) +
string(v_log_mostra_docto_vendor_repac) + chr(10) +
v_des_estab_select.

                /* ix_p20_rpt_tit_acr_emitidos */
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
                            assign v_cod_dwb_file   = session:temp-directory + 'nicr011.tmp'
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
                    assign v_nom_prog_ext  = caps(substring("nicr011.p",1,8))
                           v_cod_release   = trim(" 1.00.00.039":U)
                           v_dat_execution = today
                           v_hra_execution = replace(string(time,"hh:mm:ss" /*l_hh:mm:ss*/ ),":","").
                    run pi_rpt_tit_acr_emitidos /*pi_rpt_tit_acr_emitidos*/.
                end /* else */.
                if  dwb_rpt_param.log_dwb_print_parameters = yes
                then do:
                    if (page-number (s_1) > 0) then
                        page stream s_1.
                    /* ix_p29_rpt_tit_acr_emitidos */    
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

                    /* Begin_Include: ix_p30_rpt_tit_acr_emitidos */
                    if (line-counter(s_1) + 14) > v_rpt_s_1_bottom then
                        page stream s_1.
                    put stream s_1 unformatted 
                        skip (1)
                        skip (1)
                        "-----------------------------------" at 24
                        "ParÉmetros" at 60
                        "-----------------------------------" at 73
                        skip (1)
                        "Empresa: " at 58.
                    put stream s_1 unformatted 
                        v_cod_empres_usuar at 67 format "x(3)" skip
                        "   Atualiza P†gina: " at 47
                        v_log_atualiz_numer_pag at 67 format "Sim/N∆o" skip
                        "    Emite Termo Encert: " at 43
                        v_log_emit_termo at 67 format "Sim/N∆o" skip
                        "Estornados: " at 55
                        v_log_tit_acr_estordo at 67 format "Sim/N∆o" skip
                        "  Emiss∆o: " at 56
                        v_dat_emis_docto_ini at 67 format "99/99/9999" skip
                        "atÇ: " at 62.
                    put stream s_1 unformatted 
                        v_dat_emis_docto_fim at 67 format "99/99/9999"
                        skip (1)
                        "-----------------------------------" at 23
                        "Classificaá∆o" at 59
                        "-----------------------------------" at 73
                        skip (1)
                        "   Classificaá∆o: " at 49
                        v_ind_classif_tit_acr_emitid at 67 format "x(20)" skip.
                    if (line-counter(s_1) + 8) > v_rpt_s_1_bottom then
                        page stream s_1.
                    put stream s_1 unformatted 
                        skip (1)
                        skip (1)
                        "-----------------------------------" at 24
                        "Filtro " at 60
                        "-----------------------------------" at 74
                        skip (1)
                        "  Normal: " at 46.
                    put stream s_1 unformatted 
                        v_log_normal at 56 format "Sim/N∆o"
                        "  Transf. UN: " at 71
                        v_log_transf_unid_negoc_1 at 85 format "Sim/N∆o" skip
                        "  Cheques: " at 45
                        v_log_cheq_recbdo at 56 format "Sim/N∆o"
                        "   Transf. Est: " at 69
                        v_log_transf_estab_1 at 85 format "Sim/N∆o" skip
                        "   Aviso de DB: " at 40
                        v_log_aviso_db at 56 format "Sim/N∆o"
                        "   Renegociaá∆o: " at 68.
                    put stream s_1 unformatted 
                        v_log_renegoc at 85 format "Sim/N∆o" skip
                        "Estornados: " at 44
                        v_log_tit_acr_estordo at 56 format "Sim/N∆o"
                        "   Implantaá∆o: " at 69
                        v_log_impl_1 at 85 format "Sim/N∆o" skip.
                    if  v_log_modul_vendor then do:
                        if (line-counter(s_1) + 3) > v_rpt_s_1_bottom then
                            page stream s_1.
                        put stream s_1 unformatted 
                            skip (1)
                            "  Vendor: " at 46
                            v_log_mostra_docto_vendor at 56 format "Sim/N∆o" skip
                            "    Vendor Repactuado: " at 33
                            v_log_mostra_docto_vendor_repac at 56 format "Sim/N∆o" skip.
                    end.
                    run pi_print_editor ("s_1", v_des_estab_select, "     030", "", "     ", "", "     ").
                    put stream s_1 unformatted 
                        skip (1)
                        skip (1)
                        "-----------------------------------" at 26
                        "Seleá∆o" at 62
                        "-----------------------------------" at 72
                        skip (1)
                        "   Estab Selec: " at 41
                        entry(1, return-value, chr(255)) at 57 format "x(30)" skip.
                    run pi_print_editor ("s_1", v_des_estab_select, "at057030", "", "", "", "").
                    put stream s_1 unformatted 
                        "  EspÇcie: " at 46
                        v_cod_espec_docto_ini at 57 format "x(3)"
                        "atÇ: " at 75
                        v_cod_espec_docto_fim at 80 format "x(3)" skip
                        "  SÇrie: " at 48
                        v_cod_ser_docto_ini at 57 format "x(5)"
                        "atÇ: " at 75
                        v_cod_ser_docto_fim at 80 format "x(5)" skip
                        "  Cliente: " at 46
                        v_cdn_cliente_ini to 67 format ">>>,>>>,>>9".
                    put stream s_1 unformatted 
                        "atÇ: " at 75
                        v_cdn_cliente_fim to 90 format ">>>,>>>,>>9" skip
                        "Grupo Cliente: " at 42
                        v_cod_grp_clien_ini at 57 format "x(4)"
                        "atÇ: " at 75
                        v_cod_grp_clien_fim at 80 format "x(4)" skip
                        " Portador: " at 46
                        v_cod_portador_ini at 57 format "x(5)"
                        "atÇ: " at 75
                        v_cod_portador_fim at 80 format "x(5)" skip
                        "Carteira: " at 47
                        v_cod_cart_bcia_ini at 57 format "x(3)"
                        "atÇ: " at 75
                        v_cod_cart_bcia_fim at 80 format "x(3)" skip
                        "Vencimento: " at 45
                        v_dat_vencto_tit_acr_ini at 57 format "99/99/9999"
                        "atÇ: " at 75
                        v_dat_vencto_tit_acr_fim at 80 format "99/99/9999" skip.

                    /* End_Include: ix_p30_rpt_tit_acr_emitidos */

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
                                                 input rs_cod_dwb_output:screen-value in frame f_rpt_41_tit_acr_emitidos,
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
                if (dwb_rpt_param.cod_dwb_output = "Terminal" /*l_terminal*/ ) then do:
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
                end.


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

        /* ix_p32_rpt_tit_acr_emitidos */

        if  v_num_ped_exec <> 0
        then do:
            /* Criado pedido &1 para execuá∆o batch. */
            run pi_messages (input "show",
                             input 3556,
                             input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9",
                                                v_num_ped_exec)) /*msg_3556*/.
            assign v_num_ped_exec = 0.
        end /* if */.

        /* ix_p35_rpt_tit_acr_emitidos */

    end /* repeat block1 */.
end /* repeat super_block */.

/* ix_p40_rpt_tit_acr_emitidos */

hide frame f_rpt_41_tit_acr_emitidos.

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
        end /* if */.
    end /* repeat 2_block */.
    assign v_cod_2 = substring(v_cod_1, v_num_1).

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
    do with frame f_rpt_41_tit_acr_emitidos:

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

    run pi_rpt_tit_acr_emitidos /*pi_rpt_tit_acr_emitidos*/.
END PROCEDURE. /* pi_output_reports */
/*****************************************************************************
** Procedure Interna.....: pi_rpt_tit_acr_emitidos
** Descricao.............: pi_rpt_tit_acr_emitidos
** Criado por............: celso
** Criado em.............: 16/09/1996 19:15:46
** Alterado por..........: fut12197
** Alterado em...........: 28/10/2004 16:57:13
*****************************************************************************/
PROCEDURE pi_rpt_tit_acr_emitidos:

    /************************** Buffer Definition Begin *************************/

    &if "{&emsfin_version}" >= "5.01" &then
    def buffer b_tit_acr_aux
        for tit_acr.
    &endif


    /*************************** Buffer Definition End **************************/

    run pi_ler_tt_rpt_tit_acr_emitidos /*pi_ler_tt_rpt_tit_acr_emitidos*/.

    if  not can-find(first tt_rpt_tit_acr_emit)
            then do:
        if  v_cod_dwb_user begins "es_" /*l_es_*/ 
        then do:
            return substitute("N∆o existem &1 Ö serem emitidos !" /*3244*/, "T°tulos Emitidos" /*l_titulos_emitidos*/ ) +
                   " (" + "3244" + ")" + chr(10) +
                   substitute("Segundo os parÉmetros e/ou seleá∆o informados, n∆o foram encontrados &1 aptos a impress∆o." /*3244*/, "T°tulos Emitidos" /*l_titulos_emitidos*/ ).
        end /* if */.
        else do:
           /* N∆o existem &1 Ö serem emitidos ! */
           run pi_messages (input "show",
                            input 3244,
                            input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9",
                                               "T°tulos Emitidos" /*l_titulos_emitidos*/)) /*msg_3244*/.
           return.
        end /* else */.
    end /* if */.

    assign v_dat_inic_period   = v_dat_emis_docto_ini
           v_dat_fim_period    = v_dat_emis_docto_fim
           v_val_tot_espec     = 0
           v_qtd_tit_espec     = 0
           v_val_tot_period    = 0
           v_qtd_tot_period    = 0
           v_val_tot_clien     = 0
           v_qtd_tot_clien     = 0
           v_val_tot_grp_clien = 0
           v_qtd_tot_grp_clien = 0.

    /* ATUALIZAÄ«O DE PµGINA, CONFORME A ÈLTIMA EMISS«O */
    if  v_log_atualiz_numer_pag = yes
    then do:
        if  v_log_reemis = yes
        then do:
            run pi_eliminar_pag_livro_fisc (buffer livro_fisc,
                                            Input v_dat_emis_docto_ini) /*pi_eliminar_pag_livro_fisc*/.

            livro_block:
            for each livro_fisc_movto_tit_acr exclusive-lock
                where livro_fisc_movto_tit_acr.cod_unid_organ     = livro_fisc.cod_unid_organ
                and   livro_fisc_movto_tit_acr.cod_modul_dtsul    = livro_fisc.cod_modul_dtsul
                and   livro_fisc_movto_tit_acr.ind_tip_livro_fisc = livro_fisc.ind_tip_livro_fisc
                and   livro_fisc_movto_tit_acr.dat_inic_emis     >= v_dat_emis_docto_ini
                use-index lvrfscmv_lvrfsca:

                delete livro_fisc_movto_tit_acr.
            end /* for livro_block */.
        end /* if */.

        find first pag_livro_fisc no-lock
             where pag_livro_fisc.cod_modul_dtsul = livro_fisc.cod_modul_dtsul
               and pag_livro_fisc.cod_unid_organ = livro_fisc.cod_unid_organ
               and pag_livro_fisc.ind_tip_livro_fisc = livro_fisc.ind_tip_livro_fisc
              no-error.
        if  avail pag_livro_fisc
        then do:
            assign v_rpt_s_1_page = pag_livro_fisc.num_ult_pag
                   v_num_pag      = pag_livro_fisc.num_ult_pag + 1
                   v_num_livro    = pag_livro_fisc.num_livro_fisc.

            if  pag_livro_fisc.num_ult_pag = livro_fisc.num_pag_livro
            or  pag_livro_fisc.log_livro_fisc_encerdo = yes
            then do:
                assign v_rpt_s_1_page   = 1
                       v_num_pag        = 1
                       v_num_livro      = v_num_livro + 1.
            end /* if */.
        end /* if */.
        else do:
            if livro_fisc.num_primei_pag > 2 then
               assign v_rpt_s_1_page   = livro_fisc.num_primei_pag - 1 
                      v_num_pag        = livro_fisc.num_primei_pag
                      v_num_livro      = livro_fisc.num_primei_livro_fisc.
            else
               assign v_rpt_s_1_page   = livro_fisc.num_primei_pag
                      v_num_pag        = livro_fisc.num_primei_pag
                      v_num_livro      = livro_fisc.num_primei_livro_fisc.
        end /* else */.

        assign v_nom_report_title = v_rpt_s_1_name + "  " + "Livro" /*l_livro*/  + ": " + string(v_num_livro,">>>9").

        create pag_livro_fisc.
        assign 
               pag_livro_fisc.cod_unid_organ     = livro_fisc.cod_unid_organ
               pag_livro_fisc.cod_modul_dtsul    = livro_fisc.cod_modul_dtsul
               pag_livro_fisc.ind_tip_livro_fisc = livro_fisc.ind_tip_livro_fisc.
        assign pag_livro_fisc.dat_inic_emis          = v_dat_emis_docto_ini
               pag_livro_fisc.dat_fim_emis           = v_dat_emis_docto_fim
               pag_livro_fisc.num_livro_fisc         = v_num_livro
               pag_livro_fisc.num_primei_pag         = v_num_pag
               pag_livro_fisc.num_ult_pag            = v_num_pag
               pag_livro_fisc.log_livro_fisc_encerdo = no
               pag_livro_fisc.cod_usuar_gerac_movto  = v_cod_usuar_corren
               pag_livro_fisc.dat_gerac_movto        = today
               pag_livro_fisc.hra_gerac_movto        = replace(string(time,"hh:mm:ss" /*l_hh:mm:ss*/ ),":","").
    end /* if */.

    hide stream s_1 frame f_rpt_s_1_header_unique.
    view stream s_1 frame f_rpt_s_1_header_period.
    hide stream s_1 frame f_rpt_s_1_footer_last_page.
    hide stream s_1 frame f_rpt_s_1_footer_param_page.
    view stream s_1 frame f_rpt_s_1_footer_normal.

    /* case_block: */
    case v_ind_classif_tit_acr_emitid:
        when "Por Emiss∆o" /*l_por_emissao*/ then code_block:
         do:
            if (line-counter(s_1) + 3) > v_rpt_s_1_bottom then
                page stream s_1.
            put stream s_1 unformatted 
                "Emiss∆o" at 1
                "T°tulo" at 12
                "/P" at 29
    &IF "{&emsfin_version}" >= "" AND "{&emsfin_version}" < "5.07A" &THEN
                "Estab" at 32
    &ENDIF
    &IF "{&emsfin_version}" >= "5.07A" AND "{&emsfin_version}" < "9.99" &THEN
                "Estab" at 32
    &ENDIF
                "EspÇcie" at 38
                "SÇrie" at 46
                "Vencimento" at 52
                "Portador" at 63
                "Cart" at 72
                "Cliente" to 87
                "Nome" at 89
                "Convànio" at 130
                "Vl Original" to 155 skip
                "----------" at 1
                "----------------" at 12
                "--" at 29
    &IF "{&emsfin_version}" >= "" AND "{&emsfin_version}" < "5.07A" &THEN
                "-----" at 32
    &ENDIF
    &IF "{&emsfin_version}" >= "5.07A" AND "{&emsfin_version}" < "9.99" &THEN
                "-----" at 32
    &ENDIF
                "-------" at 38
                "-----" at 46
                "----------" at 52
                "--------" at 63
                "----" at 72
                "-----------" to 87
                "----------------------------------------" at 89
                "---------" at 130
                "--------------" to 155 skip.
            hide stream s_1 frame f_rpt_s_1_Grp_detalhe_Lay_cliente.
            hide stream s_1 frame f_rpt_s_1_Grp_detalhe_Lay_grp_cliente.
            hide stream s_1 frame f_rpt_s_1_Grp_detalhe_Lay_titulo.
            hide stream s_1 frame f_rpt_s_1_Grp_detalhe_Lay_vencimento.
            view stream s_1 frame f_rpt_s_1_Grp_detalhe_Lay_emissao.
        end /* do code_block */.

        when "Por T°tulo" /*l_por_titulo*/ then code_block:
         do:
            if (line-counter(s_1) + 3) > v_rpt_s_1_bottom then
                page stream s_1.
            put stream s_1 unformatted 
                "T°tulo" at 1
                "/P" at 18
    &IF "{&emsfin_version}" >= "" AND "{&emsfin_version}" < "5.07A" &THEN
                "Estab" at 21
    &ENDIF
    &IF "{&emsfin_version}" >= "5.07A" AND "{&emsfin_version}" < "9.99" &THEN
                "Estab" at 21
    &ENDIF
                "EspÇcie" at 27
                "SÇrie" at 35
                "Emiss∆o" at 41
                "Vencimento" at 52
                "Portador" at 63
                "Cart" at 72
                "Cliente" to 87
                "Nome" at 89
                "Convànio" at 130
                "Vl Original" to 155 skip
                "----------------" at 1
                "--" at 18
    &IF "{&emsfin_version}" >= "" AND "{&emsfin_version}" < "5.07A" &THEN
                "-----" at 21
    &ENDIF
    &IF "{&emsfin_version}" >= "5.07A" AND "{&emsfin_version}" < "9.99" &THEN
                "-----" at 21
    &ENDIF
                "-------" at 27
                "-----" at 35
                "----------" at 41
                "----------" at 52
                "--------" at 63
                "----" at 72
                "-----------" to 87
                "----------------------------------------" at 89
                "---------" at 130
                "--------------" to 155 skip.
            hide stream s_1 frame f_rpt_s_1_Grp_detalhe_Lay_cliente.
            hide stream s_1 frame f_rpt_s_1_Grp_detalhe_Lay_emissao.
            hide stream s_1 frame f_rpt_s_1_Grp_detalhe_Lay_grp_cliente.
            hide stream s_1 frame f_rpt_s_1_Grp_detalhe_Lay_vencimento.
            view stream s_1 frame f_rpt_s_1_Grp_detalhe_Lay_titulo.
        end /* do code_block */.

        when "Por Cliente" /*l_por_cliente*/ then code_block:
         do:
            if (line-counter(s_1) + 3) > v_rpt_s_1_bottom then
                page stream s_1.
            put stream s_1 unformatted 
                "Cliente" to 11
                "T°tulo" at 13
                "/P" at 30
    &IF "{&emsfin_version}" >= "" AND "{&emsfin_version}" < "5.07A" &THEN
                "Estab" at 33
    &ENDIF
    &IF "{&emsfin_version}" >= "5.07A" AND "{&emsfin_version}" < "9.99" &THEN
                "Estab" at 33
    &ENDIF
                "EspÇcie" at 39
                "SÇrie" at 47
                "Emiss∆o" at 53
                "Vencimento" at 64
                "Portador" at 75
                "Cart" at 84
                "Nome" at 89
                "Convànio" at 130
                "Vl Original" to 155 skip
                "-----------" to 11
                "----------------" at 13
                "--" at 30
    &IF "{&emsfin_version}" >= "" AND "{&emsfin_version}" < "5.07A" &THEN
                "-----" at 33
    &ENDIF
    &IF "{&emsfin_version}" >= "5.07A" AND "{&emsfin_version}" < "9.99" &THEN
                "-----" at 33
    &ENDIF
                "-------" at 39
                "-----" at 47
                "----------" at 53
                "----------" at 64
                "--------" at 75
                "----" at 84
                "----------------------------------------" at 89
                "---------" at 130
                "--------------" to 155 skip.
            hide stream s_1 frame f_rpt_s_1_Grp_detalhe_Lay_emissao.
            hide stream s_1 frame f_rpt_s_1_Grp_detalhe_Lay_grp_cliente.
            hide stream s_1 frame f_rpt_s_1_Grp_detalhe_Lay_titulo.
            hide stream s_1 frame f_rpt_s_1_Grp_detalhe_Lay_vencimento.
            view stream s_1 frame f_rpt_s_1_Grp_detalhe_Lay_cliente.
        end /* do code_block */.

        when "Por Grupo Cliente" /*l_por_grupo_cliente*/ then code_block:
         do:
            if (line-counter(s_1) + 3) > v_rpt_s_1_bottom then
                page stream s_1.
            put stream s_1 unformatted 
                "Grp Cliente" at 1
                "T°tulo" at 13
                "/P" at 30
    &IF "{&emsfin_version}" >= "" AND "{&emsfin_version}" < "5.07A" &THEN
                "Estab" at 33
    &ENDIF
    &IF "{&emsfin_version}" >= "5.07A" AND "{&emsfin_version}" < "9.99" &THEN
                "Estab" at 33
    &ENDIF
                "EspÇcie" at 39
                "SÇrie" at 47
                "Vencimento" at 53
                "Portador" at 64
                "Cart" at 73
                "Cliente" to 88
                "Nome" at 90
                "Convànio" at 131
                "Vl Original" to 155 skip
                "-----------" at 1
                "----------------" at 13
                "--" at 30
    &IF "{&emsfin_version}" >= "" AND "{&emsfin_version}" < "5.07A" &THEN
                "-----" at 33
    &ENDIF
    &IF "{&emsfin_version}" >= "5.07A" AND "{&emsfin_version}" < "9.99" &THEN
                "-----" at 33
    &ENDIF
                "-------" at 39
                "-----" at 47
                "----------" at 53
                "--------" at 64
                "----" at 73
                "-----------" to 88
                "----------------------------------------" at 90
                "---------" at 131
                "--------------" to 155 skip.
            hide stream s_1 frame f_rpt_s_1_Grp_detalhe_Lay_cliente.
            hide stream s_1 frame f_rpt_s_1_Grp_detalhe_Lay_emissao.
            hide stream s_1 frame f_rpt_s_1_Grp_detalhe_Lay_titulo.
            hide stream s_1 frame f_rpt_s_1_Grp_detalhe_Lay_vencimento.
            view stream s_1 frame f_rpt_s_1_Grp_detalhe_Lay_grp_cliente.
        end /* do code_block */.

        when "Por Vencimento" /*l_por_vencimento*/ then code_block:
         do:
            if (line-counter(s_1) + 3) > v_rpt_s_1_bottom then
                page stream s_1.
            put stream s_1 unformatted 
                "Vencimento" at 1
                "/P" at 12
    &IF "{&emsfin_version}" >= "" AND "{&emsfin_version}" < "5.07A" &THEN
                "Estab" at 15
    &ENDIF
    &IF "{&emsfin_version}" >= "5.07A" AND "{&emsfin_version}" < "9.99" &THEN
                "Estab" at 15
    &ENDIF
                "EspÇcie" at 21
                "SÇrie" at 29
                "Emiss∆o" at 35
                "Portador" at 46
                "Cart" at 55
                "Cliente" to 70
                "T°tulo" at 72
                "Nome" at 89
                "Convànio" at 130
                "Vl Original" to 155 skip
                "----------" at 1
                "--" at 12
    &IF "{&emsfin_version}" >= "" AND "{&emsfin_version}" < "5.07A" &THEN
                "-----" at 15
    &ENDIF
    &IF "{&emsfin_version}" >= "5.07A" AND "{&emsfin_version}" < "9.99" &THEN
                "-----" at 15
    &ENDIF
                "-------" at 21
                "-----" at 29
                "----------" at 35
                "--------" at 46
                "----" at 55
                "-----------" to 70
                "----------------" at 72
                "----------------------------------------" at 89
                "---------" at 130
                "--------------" to 155 skip.
            hide stream s_1 frame f_rpt_s_1_Grp_detalhe_Lay_cliente.
            hide stream s_1 frame f_rpt_s_1_Grp_detalhe_Lay_emissao.
            hide stream s_1 frame f_rpt_s_1_Grp_detalhe_Lay_grp_cliente.
            hide stream s_1 frame f_rpt_s_1_Grp_detalhe_Lay_titulo.
            view stream s_1 frame f_rpt_s_1_Grp_detalhe_Lay_vencimento.
        end /* do code_block */.
    end /* case case_block */.

    assign v_num_pag = page-number(s_1) + v_rpt_s_1_page.

    grp_block:
    for each tt_rpt_tit_acr_emit no-lock
        break by tt_rpt_tit_acr_emit.ttv_cod_dwb_field_rpt[1]
              by tt_rpt_tit_acr_emit.ttv_cod_dwb_field_rpt[2]:

        find first b_tit_acr_aux no-lock
             where b_tit_acr_aux.cod_estab      = tt_rpt_tit_acr_emit.tta_cod_estab
             and   b_tit_acr_aux.num_id_tit_acr = tt_rpt_tit_acr_emit.tta_num_id_tit_acr no-error.


        run pi_tratar_endereco_cobr (Input tt_rpt_tit_acr_emit.tta_cdn_cliente,
                                     Input b_tit_acr_aux.cod_empresa) /*pi_tratar_endereco_cobr*/.
        assign v_nom_cidad_cobr = v_nom_cidade
               v_cod_tit_acr    = tt_rpt_tit_acr_emit.tta_cod_tit_acr.
               
        run pi_verifica_codigo_convenio(Input tt_rpt_tit_acr_emit.tta_cod_estab,
                                        Input tt_rpt_tit_acr_emit.tta_cod_espec_docto,
                                        Input tt_rpt_tit_acr_emit.tta_cod_ser_docto,
                                        Input tt_rpt_tit_acr_emit.tta_cod_tit_acr,
                                        Input tt_rpt_tit_acr_emit.tta_cod_parcela). 

        /* TESTA A QUEBRA DA ESPêCIE PARA A IMPRESS«O DO TOTAL */
        if  last-of(tt_rpt_tit_acr_emit.ttv_cod_dwb_field_rpt[1])
        and ((line-counter(s_1) + 4) > v_rpt_s_1_bottom)
        then do:
            page stream s_1.
        end /* if */.

        /* IMPRESS«O DO T÷TULO EMITIDO */
        /* case_block: */
        case v_ind_classif_tit_acr_emitid:
            when "Por Emiss∆o" /*l_por_emissao*/ then code_block:
             do:
                if (line-counter(s_1) + 1) > v_rpt_s_1_bottom then
                    page stream s_1.
                put stream s_1 unformatted 
                    tt_rpt_tit_acr_emit.tta_dat_emis_docto at 1 format "99/99/9999"
                    v_cod_tit_acr at 12 format "x(16)"
                    tt_rpt_tit_acr_emit.tta_cod_parcela at 29 format "x(02)"
    &IF "{&emsfin_version}" >= "" AND "{&emsfin_version}" < "5.07A" &THEN
                    tt_rpt_tit_acr_emit.tta_cod_estab at 32 format "x(3)"
    &ENDIF
    &IF "{&emsfin_version}" >= "5.07A" AND "{&emsfin_version}" < "9.99" &THEN.
    put stream s_1 unformatted 
                    tt_rpt_tit_acr_emit.tta_cod_estab at 32 format "x(5)"
    &ENDIF
                    tt_rpt_tit_acr_emit.tta_cod_espec_docto at 38 format "x(3)"
                    tt_rpt_tit_acr_emit.tta_cod_ser_docto at 46 format "x(5)"
                    tt_rpt_tit_acr_emit.tta_dat_vencto_tit_acr at 52 format "99/99/9999"
                    tt_rpt_tit_acr_emit.tta_cod_portador at 63 format "x(5)"
                    tt_rpt_tit_acr_emit.tta_cod_cart_bcia at 72 format "x(3)"
                    tt_rpt_tit_acr_emit.tta_cdn_cliente to 87 format ">>>,>>>,>>9"
                    tt_rpt_tit_acr_emit.tta_nom_pessoa at 89 format "x(40)"
                    v_cod_convenio at 130 format "x(6)".
    put stream s_1 unformatted 
                    tt_rpt_tit_acr_emit.tta_val_origin_tit_acr to 155 format ">>>,>>>,>>9.99" skip.
            end /* do code_block */.

            when "Por T°tulo" /*l_por_titulo*/ then code_block:
             do:
                if (line-counter(s_1) + 1) > v_rpt_s_1_bottom then
                    page stream s_1.
                put stream s_1 unformatted 
                    v_cod_tit_acr at 1 format "x(16)"
                    tt_rpt_tit_acr_emit.tta_cod_parcela at 18 format "x(02)"
    &IF "{&emsfin_version}" >= "" AND "{&emsfin_version}" < "5.07A" &THEN
                    tt_rpt_tit_acr_emit.tta_cod_estab at 21 format "x(3)"
    &ENDIF
    &IF "{&emsfin_version}" >= "5.07A" AND "{&emsfin_version}" < "9.99" &THEN
                    tt_rpt_tit_acr_emit.tta_cod_estab at 21 format "x(5)".
    put stream s_1 unformatted 
    &ENDIF
                    tt_rpt_tit_acr_emit.tta_cod_espec_docto at 27 format "x(3)"
                    tt_rpt_tit_acr_emit.tta_cod_ser_docto at 35 format "x(5)"
                    tt_rpt_tit_acr_emit.tta_dat_emis_docto at 41 format "99/99/9999"
                    tt_rpt_tit_acr_emit.tta_dat_vencto_tit_acr at 52 format "99/99/9999"
                    tt_rpt_tit_acr_emit.tta_cod_portador at 63 format "x(5)"
                    tt_rpt_tit_acr_emit.tta_cod_cart_bcia at 72 format "x(3)"
                    tt_rpt_tit_acr_emit.tta_cdn_cliente to 87 format ">>>,>>>,>>9"
                    tt_rpt_tit_acr_emit.tta_nom_pessoa at 89 format "x(40)"
                    v_cod_convenio at 130 format "x(6)".
    put stream s_1 unformatted 
                    tt_rpt_tit_acr_emit.tta_val_origin_tit_acr to 155 format ">>>,>>>,>>9.99" skip.
            end /* do code_block */.

            when "Por Cliente" /*l_por_cliente*/ then code_block:
             do:
                if (line-counter(s_1) + 1) > v_rpt_s_1_bottom then
                    page stream s_1.
                put stream s_1 unformatted 
                    tt_rpt_tit_acr_emit.tta_cdn_cliente to 11 format ">>>,>>>,>>9"
                    v_cod_tit_acr at 13 format "x(16)"
                    tt_rpt_tit_acr_emit.tta_cod_parcela at 30 format "x(02)"
    &IF "{&emsfin_version}" >= "" AND "{&emsfin_version}" < "5.07A" &THEN
                    tt_rpt_tit_acr_emit.tta_cod_estab at 33 format "x(3)"
    &ENDIF
    &IF "{&emsfin_version}" >= "5.07A" AND "{&emsfin_version}" < "9.99" &THEN.
    put stream s_1 unformatted 
                    tt_rpt_tit_acr_emit.tta_cod_estab at 33 format "x(5)"
    &ENDIF
                    tt_rpt_tit_acr_emit.tta_cod_espec_docto at 39 format "x(3)"
                    tt_rpt_tit_acr_emit.tta_cod_ser_docto at 47 format "x(5)"
                    tt_rpt_tit_acr_emit.tta_dat_emis_docto at 53 format "99/99/9999"
                    tt_rpt_tit_acr_emit.tta_dat_vencto_tit_acr at 64 format "99/99/9999"
                    tt_rpt_tit_acr_emit.tta_cod_portador at 75 format "x(5)"
                    tt_rpt_tit_acr_emit.tta_cod_cart_bcia at 84 format "x(3)"
                    tt_rpt_tit_acr_emit.tta_nom_pessoa at 89 format "x(40)"
                    v_cod_convenio at 130 format "x(6)".
    put stream s_1 unformatted 
                    tt_rpt_tit_acr_emit.tta_val_origin_tit_acr to 155 format ">>>,>>>,>>9.99" skip.
            end /* do code_block */.

            when "Por Grupo Cliente" /*l_por_grupo_cliente*/ then code_block:
             do:
                if (line-counter(s_1) + 1) > v_rpt_s_1_bottom then
                    page stream s_1.
                put stream s_1 unformatted 
                    tt_rpt_tit_acr_emit.tta_cod_grp_clien at 1 format "x(4)"
                    v_cod_tit_acr at 13 format "x(16)"
                    tt_rpt_tit_acr_emit.tta_cod_parcela at 30 format "x(02)"
    &IF "{&emsfin_version}" >= "" AND "{&emsfin_version}" < "5.07A" &THEN
                    tt_rpt_tit_acr_emit.tta_cod_estab at 33 format "x(3)"
    &ENDIF
    &IF "{&emsfin_version}" >= "5.07A" AND "{&emsfin_version}" < "9.99" &THEN.
    put stream s_1 unformatted 
                    tt_rpt_tit_acr_emit.tta_cod_estab at 33 format "x(5)"
    &ENDIF
                    tt_rpt_tit_acr_emit.tta_cod_espec_docto at 39 format "x(3)"
                    tt_rpt_tit_acr_emit.tta_cod_ser_docto at 47 format "x(5)"
                    tt_rpt_tit_acr_emit.tta_dat_vencto_tit_acr at 53 format "99/99/9999"
                    tt_rpt_tit_acr_emit.tta_cod_portador at 64 format "x(5)"
                    tt_rpt_tit_acr_emit.tta_cod_cart_bcia at 73 format "x(3)"
                    tt_rpt_tit_acr_emit.tta_cdn_cliente to 88 format ">>>,>>>,>>9"
                    tt_rpt_tit_acr_emit.tta_nom_pessoa at 90 format "x(40)"
                    v_cod_convenio at 131 format "x(6)".
    put stream s_1 unformatted 
                    tt_rpt_tit_acr_emit.tta_val_origin_tit_acr to 155 format ">>>,>>>,>>9.99" skip.
            end /* do code_block */.

            when "Por Vencimento" /*l_por_vencimento*/ then code_block:
             do:
                if (line-counter(s_1) + 1) > v_rpt_s_1_bottom then
                    page stream s_1.
                put stream s_1 unformatted 
                    tt_rpt_tit_acr_emit.tta_dat_vencto_tit_acr at 1 format "99/99/9999"
                    tt_rpt_tit_acr_emit.tta_cod_parcela at 12 format "x(02)"
    &IF "{&emsfin_version}" >= "" AND "{&emsfin_version}" < "5.07A" &THEN
                    tt_rpt_tit_acr_emit.tta_cod_estab at 15 format "x(3)"
    &ENDIF
    &IF "{&emsfin_version}" >= "5.07A" AND "{&emsfin_version}" < "9.99" &THEN
                    tt_rpt_tit_acr_emit.tta_cod_estab at 15 format "x(5)".
    put stream s_1 unformatted 
    &ENDIF
                    tt_rpt_tit_acr_emit.tta_cod_espec_docto at 21 format "x(3)"
                    tt_rpt_tit_acr_emit.tta_cod_ser_docto at 29 format "x(5)"
                    tt_rpt_tit_acr_emit.tta_dat_emis_docto at 35 format "99/99/9999"
                    tt_rpt_tit_acr_emit.tta_cod_portador at 46 format "x(5)"
                    tt_rpt_tit_acr_emit.tta_cod_cart_bcia at 55 format "x(3)"
                    tt_rpt_tit_acr_emit.tta_cdn_cliente to 70 format ">>>,>>>,>>9"
                    v_cod_tit_acr at 72 format "x(16)"
                    tt_rpt_tit_acr_emit.tta_nom_pessoa at 89 format "x(40)"
                    v_cod_convenio at 130 format "x(6)".
    put stream s_1 unformatted 
                    tt_rpt_tit_acr_emit.tta_val_origin_tit_acr to 155 format ">>>,>>>,>>9.99" skip.
            end /* do code_block */.
        end /* case case_block */.

        assign v_val_tot_espec      = v_val_tot_espec  + tt_rpt_tit_acr_emit.tta_val_origin_tit_acr
               v_qtd_tit_espec      = v_qtd_tit_espec  + 1
               v_val_tot_period     = v_val_tot_period + tt_rpt_tit_acr_emit.tta_val_origin_tit_acr
               v_qtd_tot_period     = v_qtd_tot_period + 1
               v_val_tot_clien      = v_val_tot_clien  + tt_rpt_tit_acr_emit.tta_val_origin_tit_acr
               v_qtd_tot_clien      = v_qtd_tot_clien  + 1
               v_val_tot_grp_clien  = v_val_tot_grp_clien  + tt_rpt_tit_acr_emit.tta_val_origin_tit_acr
               v_qtd_tot_grp_clien  = v_qtd_tot_grp_clien  + 1.

        /* ATUALIZAÄ«O DO LIVRO/PµGINA DO T÷TULO NA TABELA LIVRO_FISC_MOVTO_TIT_ACR */
        if  v_log_atualiz_numer_pag = yes
        then do:
            find first movto_tit_acr no-lock
                where movto_tit_acr.cod_estab         = tt_rpt_tit_acr_emit.tta_cod_estab
                and   movto_tit_acr.num_id_tit_acr    = tt_rpt_tit_acr_emit.tta_num_id_tit_acr
                and  (movto_tit_acr.ind_trans_acr_abrev  = "REN" /*l_ren*/               
                 or    movto_tit_acr.ind_trans_acr_abrev = "TRES" /*l_tres*/              
                 or    movto_tit_acr.ind_trans_acr_abrev = "IMPL" /*l_impl*/ )
                and   movto_tit_acr.log_movto_estordo = no
                no-error.
            if  avail movto_tit_acr
            then do:
                create livro_fisc_movto_tit_acr.
                assign 
                       livro_fisc_movto_tit_acr.cod_unid_organ     = livro_fisc.cod_unid_organ
                       livro_fisc_movto_tit_acr.cod_modul_dtsul    = livro_fisc.cod_modul_dtsul
                       livro_fisc_movto_tit_acr.ind_tip_livro_fisc = livro_fisc.ind_tip_livro_fisc.
                assign 
                       livro_fisc_movto_tit_acr.cod_estab            = movto_tit_acr.cod_estab
                       livro_fisc_movto_tit_acr.num_id_movto_tit_acr = movto_tit_acr.num_id_movto_tit_acr.
                assign livro_fisc_movto_tit_acr.num_id_aprop_ctbl_acr = 0
                       livro_fisc_movto_tit_acr.dat_inic_emis         = v_dat_emis_docto_ini
                       livro_fisc_movto_tit_acr.num_livro_fisc        = v_num_livro
                       livro_fisc_movto_tit_acr.num_pag_livro_fisc    = page-number(s_1) + v_rpt_s_1_page.
            end /* if */.
        end /* if */.

        /* IMPRESS«O DO TOTAL DA ESPêCIE */
        /* case_block: */
        case v_ind_classif_tit_acr_emitid:
            when "Por Emiss∆o" /*l_por_emissao*/  or
            when "Por Vencimento" /*l_por_vencimento*/ then code_block:
             do:
                if  last-of(tt_rpt_tit_acr_emit.ttv_cod_dwb_field_rpt[2])
                then do:
                    if (line-counter(s_1) + 3) > v_rpt_s_1_bottom then
                        page stream s_1.
                    put stream s_1 unformatted 
                        "--------------" at 142 skip
                        "    Qtde T°tulos EspÇcie: " at 77
                        v_qtd_tit_espec to 111 format "->>>>,>>9"
                        "   Total EspÇcie: " at 113
                        v_val_tot_espec to 155 format "->>,>>>,>>>,>>9.99" skip (1).

                    assign v_val_tot_espec = 0
                           v_qtd_tit_espec = 0.
                end /* if */.
            end /* do code_block */.

            when "Por T°tulo" /*l_por_titulo*/ then code_block:
             do:
            end /* do code_block */.

            when "Por Cliente" /*l_por_cliente*/ then code_block:
             do:
                if  last-of(tt_rpt_tit_acr_emit.ttv_cod_dwb_field_rpt[2])
                then do:
                    if (line-counter(s_1) + 3) > v_rpt_s_1_bottom then
                        page stream s_1.
                    put stream s_1 unformatted 
                        "--------------" at 142 skip
                        "    Qtde T°tulos Cliente: " at 73
                        v_qtd_tot_clien to 107 format "->>>>,>>9"
                        "    Total do Cliente: " at 109
                        v_val_tot_clien to 155 format "->>,>>>,>>>,>>9.99" skip (1).

                    assign v_val_tot_clien = 0
                           v_qtd_tot_clien = 0.
                end /* if */.
            end /* do code_block */.

            when "Por Grupo Cliente" /*l_por_grupo_cliente*/ then code_block:
             do:
                if  last-of(tt_rpt_tit_acr_emit.ttv_cod_dwb_field_rpt[2])
                then do:
                    if (line-counter(s_1) + 3) > v_rpt_s_1_bottom then
                        page stream s_1.
                    put stream s_1 unformatted 
                        "--------------" at 142 skip
                        "    Qtde T°tulos Cliente: " at 73
                        v_qtd_tot_clien to 107 format "->>>>,>>9"
                        "    Total do Cliente: " at 109
                        v_val_tot_clien to 155 format "->>,>>>,>>>,>>9.99" skip (1).

                    assign v_val_tot_clien = 0
                           v_qtd_tot_clien = 0.
                end /* if */.

                if  last-of(tt_rpt_tit_acr_emit.ttv_cod_dwb_field_rpt[1])
                then do:
                    if (line-counter(s_1) + 3) > v_rpt_s_1_bottom then
                        page stream s_1.
                    put stream s_1 unformatted 
                        "--------------" at 142 skip
                        "    Qtde Tit Grp Cliente: " at 70
                        v_qtd_tot_grp_clien to 104 format "->>>>,>>9"
                        "    Total Grupo Cliente: " at 106
                        v_val_tot_grp_clien to 155 format "->>,>>>,>>>,>>9.99" skip (1).

                    assign v_val_tot_grp_clien = 0
                           v_qtd_tot_grp_clien = 0.
                end /* if */.

            end /* do code_block */.

        end /* case case_block */.

        /* VERIFICA A NECESSIDADE DE IMPRESS«O DOS TERMOS DO LIVRO */
        if  v_log_atualiz_numer_pag = yes
        then do:
            if  v_num_pag = livro_fisc.num_pag_livro - 1
            and ((line-counter(s_1) + 7) > v_rpt_s_1_bottom)
            then do:
                page stream s_1.
            end /* if */.

            run pi_imprimir_termos_tit_acr_emitidos /*pi_imprimir_termos_tit_acr_emitidos*/.
        end /* if */.

        delete tt_rpt_tit_acr_emit.
    end /* for grp_block */.

    if (line-counter(s_1) + 2) > v_rpt_s_1_bottom then
        page stream s_1.
    put stream s_1 unformatted 
        "--------------" at 142 skip
        "    Qtde Total T°tulos: " at 76
        v_qtd_tot_period to 108 format "->>>>,>>9"
        "   Total do Per°odo: " at 110
        v_val_tot_period to 155 format "->>,>>>,>>>,>>9.99" skip.

    hide stream s_1 frame f_rpt_s_1_Grp_detalhe_Lay_emissao.
    hide stream s_1 frame f_rpt_s_1_Grp_detalhe_Lay_titulo.
    hide stream s_1 frame f_rpt_s_1_Grp_detalhe_Lay_cliente.
    hide stream s_1 frame f_rpt_s_1_Grp_detalhe_Lay_grp_cliente.
    hide stream s_1 frame f_rpt_s_1_Grp_detalhe_Lay_vencimento.

    /* ATUALIZAÄ«O FINAL, PODENDO ENCERRAR O LIVRO */
    if  v_log_atualiz_numer_pag = yes
    then do:
        assign v_num_pag = page-number(s_1) + v_rpt_s_1_page.

        if  v_num_pag = livro_fisc.num_pag_livro - 1
        or  v_log_emit_termo = yes
        then do:
            assign pag_livro_fisc.log_livro_fisc_encerdo = yes
                   v_des_termo_abert  = replace(livro_fisc.des_termo_abert,'@' + 'pag' + '@',string(v_num_pag + 1))
                   v_des_termo_encert = replace(livro_fisc.des_termo_encert,'@' + 'pag' + '@',string(v_num_pag + 1))
                   no-error.

            page stream s_1.
            run pi_print_editor ("s_1", v_des_termo_encert, "     060", "", "     ", "", "     ").
            put stream s_1 unformatted 
                skip (3)
                "T E R M O  D E  E N C E R R A M E N T O     " at 47
                skip (1)
                entry(1, return-value, chr(255)) at 39 format "x(60)" skip.
            run pi_print_editor ("s_1", v_des_termo_encert, "at039060", "", "", "", "").
            assign v_num_pag      = page-number(s_1) + v_rpt_s_1_page
                   v_rpt_s_1_page = ((page-number(s_1)) * - 1).

            page stream s_1.
            run pi_print_editor ("s_1", v_des_termo_abert, "     060", "", "     ", "", "     ").
            put stream s_1 unformatted 
                skip (3)
                "T E R M O  D E  A B E R T U R A     " at 51
                skip (1)
                entry(1, return-value, chr(255)) at 38 format "x(60)" skip.
            run pi_print_editor ("s_1", v_des_termo_abert, "at038060", "", "", "", "").
        end /* if */.

        assign pag_livro_fisc.num_ult_pag = v_num_pag.
    end /* if */.

    /* Tratamento para a poss°vel impress∆o dos parÉmetros do programa */
    if  v_log_atualiz_numer_pag = yes
    then do:
        assign v_rpt_s_1_page     = - 1 - page-number(s_1)
               v_nom_report_title = v_rpt_s_1_name.
    end /* if */.
END PROCEDURE. /* pi_rpt_tit_acr_emitidos */
/*****************************************************************************
** Procedure Interna.....: pi_ler_tt_rpt_tit_acr_emitidos
** Descricao.............: pi_ler_tt_rpt_tit_acr_emitidos
** Criado por............: celso
** Criado em.............: 17/09/1996 08:03:36
** Alterado por..........: corp45598
** Alterado em...........: 15/04/2013 16:46:08
*****************************************************************************/
PROCEDURE pi_ler_tt_rpt_tit_acr_emitidos:

    /************************* Variable Definition Begin ************************/

    def var v_log_enctro
        as logical
        format "Sim/N∆o"
        initial yes
        no-undo.


    /************************** Variable Definition End *************************/

    block_estab:
    for each estabelecimento no-lock
        where lookup(estabelecimento.cod_estab, v_des_estab_select) > 0:

        if v_log_atualiz_numer_pag = no then do:
            for each tit_acr no-lock
                where tit_acr.cod_estab           = estabelecimento.cod_estab
                  and tit_acr.dat_emis_docto     >= v_dat_emis_docto_ini
                  and tit_acr.dat_emis_docto     <= v_dat_emis_docto_fim
                  and tit_acr.cod_espec_docto    >= v_cod_espec_docto_ini
                  and tit_acr.cod_espec_docto    <= v_cod_espec_docto_fim
                  and tit_acr.cod_ser_docto      >= v_cod_ser_docto_ini
                  and tit_acr.cod_ser_docto      <= v_cod_ser_docto_fim
                  and tit_acr.cdn_cliente        >= v_cdn_cliente_ini
                  and tit_acr.cdn_cliente        <= v_cdn_cliente_fim
                  and tit_acr.cod_portador       >= v_cod_portador_ini
                  and tit_acr.cod_portador       <= v_cod_portador_fim
                  and tit_acr.cod_cart_bcia      >= v_cod_cart_bcia_ini
                  and tit_acr.cod_cart_bcia      <= v_cod_cart_bcia_fim
                  and tit_acr.dat_vencto_tit_acr >= v_dat_vencto_tit_acr_ini
                  and tit_acr.dat_vencto_tit_acr <= v_dat_vencto_tit_acr_fim
                  and ((v_log_normal      = yes and tit_acr.ind_tip_espec_docto  = "Normal" /*l_normal*/ )
                   or  (v_log_cheq_recbdo = yes and tit_acr.ind_tip_espec_docto  = "Cheques Recebidos" /*l_cheques_recebidos*/ )
                   or  (v_log_aviso_db    = yes and tit_acr.ind_tip_espec_docto  = "Aviso DÇbito" /*l_aviso_debito*/ )
                   or  (v_log_mostra_docto_vendor       = yes and tit_acr.ind_tip_espec_docto  = "Vendor" /*l_Vendor*/ )
                   or  (v_log_mostra_docto_vendor_repac = yes and tit_acr.ind_tip_espec_docto  = "Vendor Repactuado" /*l_Vendor_Repac*/ ))
                  use-index titacr_emis:

                find cliente no-lock
                    where cliente.cod_empresa = tit_acr.cod_empresa
                    and   cliente.cdn_cliente = tit_acr.cdn_cliente
                    no-error.
                if cliente.cod_grp_clien < v_cod_grp_clien_ini
                or cliente.cod_grp_clien > v_cod_grp_clien_fim then
                    next.  

                assign v_log_enctro = no.
                if  v_log_renegoc = yes 
                and v_log_enctro = no  then do:
                    find first movto_tit_acr no-lock where
                               movto_tit_acr.cod_estab           = tit_acr.cod_estab      and
                               movto_tit_acr.num_id_tit_acr      = tit_acr.num_id_tit_acr and
                               movto_tit_acr.ind_trans_acr_abrev = "REN" /*l_ren*/ 
                    use-index mvtttcr_id no-error.
                    if avail movto_tit_acr then 
                        assign v_log_enctro = yes.
                end.
                if  v_log_transf_unid_negoc_1 = yes
                and v_log_enctro              = no  then do:
                    find first movto_tit_acr no-lock where
                               movto_tit_acr.cod_estab           = tit_acr.cod_estab      and
                               movto_tit_acr.num_id_tit_acr      = tit_acr.num_id_tit_acr and
                               movto_tit_acr.ind_trans_acr_abrev = "TRUN" /*l_trun*/ 
                    use-index mvtttcr_id no-error.
                    if avail movto_tit_acr then
                        assign v_log_enctro = yes.
                end.
                if  v_log_transf_estab_1 = yes
                and v_log_enctro         = no  then do:
                    find first movto_tit_acr no-lock where
                               movto_tit_acr.cod_estab           = tit_acr.cod_estab      and
                               movto_tit_acr.num_id_tit_acr      = tit_acr.num_id_tit_acr and
                               movto_tit_acr.ind_trans_acr_abrev = "TRES" /*l_tres*/  
                    use-index mvtttcr_id no-error.
                    if avail movto_tit_acr then
                        assign v_log_enctro = yes.
                end.
                if  v_log_impl_1 = yes
                and v_log_enctro = no  then do:
                    find first movto_tit_acr no-lock where
                               movto_tit_acr.cod_estab           = tit_acr.cod_estab      and
                               movto_tit_acr.num_id_tit_acr      = tit_acr.num_id_tit_acr and
                               movto_tit_acr.ind_trans_acr_abrev = "IMPL" /*l_impl*/ 
                    use-index mvtttcr_id no-error.
                    if avail movto_tit_acr then
                         assign v_log_enctro = yes.
                end.
                if  v_log_enctro = yes then do:
                    if  v_log_tit_acr_estordo = no
                    and movto_tit_acr.log_movto_estordo = yes
                    and movto_tit_acr.log_ctbz_aprop_ctbl = no then 
                        next.
                    else
                        run pi_tratar_tt_rpt_tit_acr_emitidos /*pi_tratar_tt_rpt_tit_acr_emitidos*/.
                end.
            end.
        end.
        else do:
            for each tit_acr no-lock
                where tit_acr.cod_estab           = estabelecimento.cod_estab
                  and tit_acr.dat_emis_docto     >= v_dat_emis_docto_ini
                  and tit_acr.dat_emis_docto     <= v_dat_emis_docto_fim
                  and tit_acr.cod_espec_docto    >= v_cod_espec_docto_ini
                  and tit_acr.cod_espec_docto    <= v_cod_espec_docto_fim
                  and tit_acr.cod_ser_docto      >= v_cod_ser_docto_ini
                  and tit_acr.cod_ser_docto      <= v_cod_ser_docto_fim
                  and tit_acr.cdn_cliente        >= v_cdn_cliente_ini
                  and tit_acr.cdn_cliente        <= v_cdn_cliente_fim
                  and tit_acr.cod_portador       >= v_cod_portador_ini
                  and tit_acr.cod_portador       <= v_cod_portador_fim
                  and tit_acr.cod_cart_bcia      >= v_cod_cart_bcia_ini
                  and tit_acr.cod_cart_bcia      <= v_cod_cart_bcia_fim
                  and tit_acr.dat_vencto_tit_acr >= v_dat_vencto_tit_acr_ini
                  and tit_acr.dat_vencto_tit_acr <= v_dat_vencto_tit_acr_fim
                  and tit_acr.ind_tip_espec_docto = "Normal" /*l_normal*/ 
                  use-index titacr_emis:

                find cliente no-lock
                    where cliente.cod_empresa = tit_acr.cod_empresa
                    and   cliente.cdn_cliente = tit_acr.cdn_cliente
                    no-error.
                if cliente.cod_grp_clien < v_cod_grp_clien_ini
                or cliente.cod_grp_clien > v_cod_grp_clien_fim then
                    next.  

                assign v_log_enctro = no.
                find first movto_tit_acr no-lock where
                           movto_tit_acr.cod_estab           = tit_acr.cod_estab      and
                           movto_tit_acr.num_id_tit_acr      = tit_acr.num_id_tit_acr and
                           movto_tit_acr.ind_trans_acr_abrev = "IMPL" /*l_impl*/ 
                           use-index mvtttcr_id no-error.
                if avail movto_tit_acr then
                    assign v_log_enctro = yes.

                if v_log_enctro = yes then do:                       
                    if  v_log_tit_acr_estordo = no
                    and movto_tit_acr.log_movto_estordo = yes
                    and movto_tit_acr.log_ctbz_aprop_ctbl = no then 
                        next.
                    else
                        run pi_tratar_tt_rpt_tit_acr_emitidos /*pi_tratar_tt_rpt_tit_acr_emitidos*/.
                end.
            end.
        end.
    end /* for block_estab */.
END PROCEDURE. /* pi_ler_tt_rpt_tit_acr_emitidos */
/*****************************************************************************
** Procedure Interna.....: pi_tratar_tt_rpt_tit_acr_emitidos
** Descricao.............: pi_tratar_tt_rpt_tit_acr_emitidos
** Criado por............: celso
** Criado em.............: 17/09/1996 08:28:57
** Alterado por..........: bre17205
** Alterado em...........: 09/12/2003 08:47:06
*****************************************************************************/
PROCEDURE pi_tratar_tt_rpt_tit_acr_emitidos:

    create tt_rpt_tit_acr_emit.
    assign tt_rpt_tit_acr_emit.tta_cod_estab          = tit_acr.cod_estab
           tt_rpt_tit_acr_emit.tta_num_id_tit_acr     = tit_acr.num_id_tit_acr
           tt_rpt_tit_acr_emit.tta_cod_espec_docto    = tit_acr.cod_espec_docto
           tt_rpt_tit_acr_emit.tta_cod_ser_docto      = tit_acr.cod_ser_docto
           tt_rpt_tit_acr_emit.tta_cod_tit_acr        = tit_acr.cod_tit_acr
           tt_rpt_tit_acr_emit.tta_cod_parcela        = tit_acr.cod_parcela
           tt_rpt_tit_acr_emit.tta_cdn_cliente        = tit_acr.cdn_cliente
           tt_rpt_tit_acr_emit.tta_cod_grp_clien      = cliente.cod_grp_clien
           tt_rpt_tit_acr_emit.tta_cod_portador       = tit_acr.cod_portador
           tt_rpt_tit_acr_emit.tta_cod_cart_bcia      = tit_acr.cod_cart_bcia
           tt_rpt_tit_acr_emit.tta_dat_emis_docto     = tit_acr.dat_emis_docto
           tt_rpt_tit_acr_emit.tta_nom_pessoa         = cliente.nom_pessoa
           tt_rpt_tit_acr_emit.tta_dat_vencto_tit_acr = tit_acr.dat_vencto_tit_acr
           tt_rpt_tit_acr_emit.tta_val_origin_tit_acr = 0.
           
    

    /* **
     Valor original na FE do Pa°s
    ***/
    for each val_tit_acr no-lock
        where val_tit_acr.cod_estab        = tit_acr.cod_estab
          and val_tit_acr.num_id_tit_acr   = tit_acr.num_id_tit_acr
          and val_tit_acr.cod_finalid_econ = v_cod_finalid_econ:

        assign tt_rpt_tit_acr_emit.tta_val_origin_tit_acr = tt_rpt_tit_acr_emit.tta_val_origin_tit_acr + val_tit_acr.val_origin_tit_acr.
    end.

    /* case_block: */
    case v_ind_classif_tit_acr_emitid:
        when "Por Emiss∆o" /*l_por_emissao*/ then
            assign tt_rpt_tit_acr_emit.ttv_cod_dwb_field_rpt[1] = string(year(tt_rpt_tit_acr_emit.tta_dat_emis_docto),"9999") +
                                                                  string(month(tt_rpt_tit_acr_emit.tta_dat_emis_docto),"99") +
                                                                  string(day(tt_rpt_tit_acr_emit.tta_dat_emis_docto),"99")
                   tt_rpt_tit_acr_emit.ttv_cod_dwb_field_rpt[2] = tt_rpt_tit_acr_emit.tta_cod_espec_docto.

        when "Por T°tulo" /*l_por_titulo*/ then
            assign tt_rpt_tit_acr_emit.ttv_cod_dwb_field_rpt[1] = tt_rpt_tit_acr_emit.tta_cod_espec_docto + tt_rpt_tit_acr_emit.tta_cod_estab + tt_rpt_tit_acr_emit.tta_cod_ser_docto + tt_rpt_tit_acr_emit.tta_cod_tit_acr + tt_rpt_tit_acr_emit.tta_cod_parcela.

        when "Por Cliente" /*l_por_cliente*/ then
            assign tt_rpt_tit_acr_emit.ttv_cod_dwb_field_rpt[1] = string(tt_rpt_tit_acr_emit.tta_cdn_cliente, ">>>,>>>,>>9":U)
                   tt_rpt_tit_acr_emit.ttv_cod_dwb_field_rpt[2] = tt_rpt_tit_acr_emit.tta_cod_espec_docto.

        when "Por Grupo Cliente" /*l_por_grupo_cliente*/ then
            assign tt_rpt_tit_acr_emit.ttv_cod_dwb_field_rpt[1] = string(tt_rpt_tit_acr_emit.tta_cod_grp_clien, "x(4)":U)
                   tt_rpt_tit_acr_emit.ttv_cod_dwb_field_rpt[2] = string(tt_rpt_tit_acr_emit.tta_cdn_cliente, ">>>,>>>,>>9":U).

        when "Por Vencimento" /*l_por_vencimento*/ then
            assign tt_rpt_tit_acr_emit.ttv_cod_dwb_field_rpt[1] = string(year(tt_rpt_tit_acr_emit.tta_dat_vencto_tit_acr),"9999") +
                                                                  string(month(tt_rpt_tit_acr_emit.tta_dat_vencto_tit_acr),"99") +
                                                                  string(day(tt_rpt_tit_acr_emit.tta_dat_vencto_tit_acr),"99")
                   tt_rpt_tit_acr_emit.ttv_cod_dwb_field_rpt[2] = tt_rpt_tit_acr_emit.tta_cod_espec_docto.
    end /* case case_block */.
END PROCEDURE. /* pi_tratar_tt_rpt_tit_acr_emitidos */
/*****************************************************************************
** Procedure Interna.....: pi_retornar_ult_dia_mes
** Descricao.............: pi_retornar_ult_dia_mes
** Criado por............: Uno
** Criado em.............: 30/04/1996 11:00:43
** Alterado por..........: Uno
** Alterado em...........: 30/04/1996 13:42:24
*****************************************************************************/
PROCEDURE pi_retornar_ult_dia_mes:

    /************************ Parameter Definition Begin ************************/

    def Input param p_dat_inic
        as date
        format "99/99/9999"
        no-undo.
    def output param p_dat_fim
        as date
        format "99/99/9999"
        no-undo.


    /************************* Parameter Definition End *************************/

    assign p_dat_fim = date(month(p_dat_inic), 15, year(p_dat_inic)) + 30
           p_dat_fim = date(month(p_dat_fim), 01, year(p_dat_fim)) - 1.

END PROCEDURE. /* pi_retornar_ult_dia_mes */
/*****************************************************************************
** Procedure Interna.....: pi_converter_para_inteiro
** Descricao.............: pi_converter_para_inteiro
** Criado por............: vanei
** Criado em.............: 24/11/1995 14:34:38
** Alterado por..........: fut1236
** Alterado em...........: 23/06/2005 15:25:06
*****************************************************************************/
PROCEDURE pi_converter_para_inteiro:

    /************************ Parameter Definition Begin ************************/

    def Input param p_cod_initial
        as character
        format "x(8)"
        no-undo.
    def output param p_num_return
        as integer
        format ">>>>,>>9"
        no-undo.


    /************************* Parameter Definition End *************************/

    /************************* Variable Definition Begin ************************/

    def var v_cod_count                      as character       no-undo. /*local*/
    def var v_num_count                      as integer         no-undo. /*local*/


    /************************** Variable Definition End *************************/

    assign p_num_return = 0.
    if  p_cod_initial = ""
    then do:
        return.
    end /* if */.

    verifica_block:
    do v_num_count = 1 to length(p_cod_initial):
        assign v_cod_count = substring(p_cod_initial, v_num_count, 1).
        if  index("0123456789", v_cod_count) = 0
        then do:
            return.
        end /* if */.
    end /* do verifica_block */.
    /* * PI Alterada sob demanda n∆o retirar o "no-error" * **/
    assign p_num_return = integer(p_cod_initial) no-error.
END PROCEDURE. /* pi_converter_para_inteiro */
/*****************************************************************************
** Procedure Interna.....: pi_imprimir_termos_tit_acr_emitidos
** Descricao.............: pi_imprimir_termos_tit_acr_emitidos
** Criado por............: Uno
** Criado em.............: 05/12/1996 09:08:52
** Alterado por..........: fut12197
** Alterado em...........: 28/10/2004 16:58:27
*****************************************************************************/
PROCEDURE pi_imprimir_termos_tit_acr_emitidos:

    if  v_num_pag <> (page-number(s_1) + v_rpt_s_1_page)
    then do:
        assign v_num_pag = page-number(s_1) + v_rpt_s_1_page.
        if  v_num_pag = livro_fisc.num_pag_livro
        then do:
            hide stream s_1 frame f_rpt_s_1_Grp_detalhe_Lay_emissao.
            hide stream s_1 frame f_rpt_s_1_Grp_detalhe_Lay_titulo.
            hide stream s_1 frame f_rpt_s_1_Grp_detalhe_Lay_cliente.
            hide stream s_1 frame f_rpt_s_1_Grp_detalhe_Lay_vencimento.

            assign pag_livro_fisc.num_ult_pag            = v_num_pag
                   pag_livro_fisc.log_livro_fisc_encerdo = yes.

            assign v_des_termo_abert  = replace(livro_fisc.des_termo_abert,'@' + 'pag' + '@',string(v_num_pag))
                   v_des_termo_encert = replace(livro_fisc.des_termo_encert,'@' + 'pag' + '@',string(v_num_pag))
                   no-error.

            run pi_print_editor ("s_1", v_des_termo_encert, "     060", "", "     ", "", "     ").
            put stream s_1 unformatted 
                skip (3)
                "T E R M O  D E  E N C E R R A M E N T O     " at 47
                skip (1)
                entry(1, return-value, chr(255)) at 39 format "x(60)" skip.
            run pi_print_editor ("s_1", v_des_termo_encert, "at039060", "", "", "", "").
            assign v_rpt_s_1_page = page-number(s_1) * (- 1)
                   v_num_livro    = v_num_livro + 1.
            page stream s_1.
            run pi_print_editor ("s_1", v_des_termo_abert, "     060", "", "     ", "", "     ").
            put stream s_1 unformatted 
                skip (3)
                "T E R M O  D E  A B E R T U R A     " at 51
                skip (1)
                entry(1, return-value, chr(255)) at 38 format "x(60)" skip.
            run pi_print_editor ("s_1", v_des_termo_abert, "at038060", "", "", "", "").
            page stream s_1.

            create pag_livro_fisc.
            assign 
                   pag_livro_fisc.cod_unid_organ     = livro_fisc.cod_unid_organ
                   pag_livro_fisc.cod_modul_dtsul    = livro_fisc.cod_modul_dtsul
                   pag_livro_fisc.ind_tip_livro_fisc = livro_fisc.ind_tip_livro_fisc.
            assign pag_livro_fisc.dat_inic_emis          = v_dat_emis_docto_ini
                   pag_livro_fisc.dat_fim_emis           = v_dat_emis_docto_fim
                   pag_livro_fisc.num_livro_fisc         = v_num_livro
                   pag_livro_fisc.num_primei_pag         = page-number(s_1) + v_rpt_s_1_page - 1
                   pag_livro_fisc.num_ult_pag            = page-number(s_1) + v_rpt_s_1_page - 1
                   pag_livro_fisc.log_livro_fisc_encerdo = no
                   pag_livro_fisc.cod_usuar_gerac_movto  = v_cod_usuar_corren
                   pag_livro_fisc.dat_gerac_movto        = today
                   pag_livro_fisc.hra_gerac_movto        = replace(string(time,"hh:mm:ss" /*l_hh:mm:ss*/ ),":","").

            assign v_nom_report_title = v_rpt_s_1_name + "  " + "Livro" /*l_livro*/  + ": " + string(v_num_livro,">>>9")
                   v_num_pag          = page-number(s_1) + v_rpt_s_1_page.

            /* case_block: */
            case v_ind_classif_tit_acr_emitid:
                when "Por Emiss∆o" /*l_por_emissao*/ then code_block:
                 do:
                    if (line-counter(s_1) + 3) > v_rpt_s_1_bottom then
                        page stream s_1.
                    put stream s_1 unformatted 
                        "Emiss∆o" at 1
                        "T°tulo" at 12
                        "/P" at 29
    &IF "{&emsfin_version}" >= "" AND "{&emsfin_version}" < "5.07A" &THEN
                        "Estab" at 32
    &ENDIF
    &IF "{&emsfin_version}" >= "5.07A" AND "{&emsfin_version}" < "9.99" &THEN
                        "Estab" at 32
    &ENDIF
                        "EspÇcie" at 38
                        "SÇrie" at 46
                        "Vencimento" at 52
                        "Portador" at 63
                        "Cart" at 72
                        "Cliente" to 87
                        "Nome" at 89
                        "Convànio" at 130
                        "Vl Original" to 155 skip
                        "----------" at 1
                        "----------------" at 12
                        "--" at 29
    &IF "{&emsfin_version}" >= "" AND "{&emsfin_version}" < "5.07A" &THEN
                        "-----" at 32
    &ENDIF
    &IF "{&emsfin_version}" >= "5.07A" AND "{&emsfin_version}" < "9.99" &THEN
                        "-----" at 32
    &ENDIF
                        "-------" at 38
                        "-----" at 46
                        "----------" at 52
                        "--------" at 63
                        "----" at 72
                        "-----------" to 87
                        "----------------------------------------" at 89
                        "---------" at 130
                        "--------------" to 155 skip.
                    hide stream s_1 frame f_rpt_s_1_Grp_detalhe_Lay_cliente.
                    hide stream s_1 frame f_rpt_s_1_Grp_detalhe_Lay_grp_cliente.
                    hide stream s_1 frame f_rpt_s_1_Grp_detalhe_Lay_titulo.
                    hide stream s_1 frame f_rpt_s_1_Grp_detalhe_Lay_vencimento.
                    view stream s_1 frame f_rpt_s_1_Grp_detalhe_Lay_emissao.
                end /* do code_block */.

                when "Por T°tulo" /*l_por_titulo*/ then code_block:
                 do:
                    if (line-counter(s_1) + 3) > v_rpt_s_1_bottom then
                        page stream s_1.
                    put stream s_1 unformatted 
                        "T°tulo" at 1
                        "/P" at 18
    &IF "{&emsfin_version}" >= "" AND "{&emsfin_version}" < "5.07A" &THEN
                        "Estab" at 21
    &ENDIF
    &IF "{&emsfin_version}" >= "5.07A" AND "{&emsfin_version}" < "9.99" &THEN
                        "Estab" at 21
    &ENDIF
                        "EspÇcie" at 27
                        "SÇrie" at 35
                        "Emiss∆o" at 41
                        "Vencimento" at 52
                        "Portador" at 63
                        "Cart" at 72
                        "Cliente" to 87
                        "Nome" at 89
                        "Convànio" at 130
                        "Vl Original" to 155 skip
                        "----------------" at 1
                        "--" at 18
    &IF "{&emsfin_version}" >= "" AND "{&emsfin_version}" < "5.07A" &THEN
                        "-----" at 21
    &ENDIF
    &IF "{&emsfin_version}" >= "5.07A" AND "{&emsfin_version}" < "9.99" &THEN
                        "-----" at 21
    &ENDIF
                        "-------" at 27
                        "-----" at 35
                        "----------" at 41
                        "----------" at 52
                        "--------" at 63
                        "----" at 72
                        "-----------" to 87
                        "----------------------------------------" at 89
                        "---------" at 130
                        "--------------" to 155 skip.
                    hide stream s_1 frame f_rpt_s_1_Grp_detalhe_Lay_cliente.
                    hide stream s_1 frame f_rpt_s_1_Grp_detalhe_Lay_emissao.
                    hide stream s_1 frame f_rpt_s_1_Grp_detalhe_Lay_grp_cliente.
                    hide stream s_1 frame f_rpt_s_1_Grp_detalhe_Lay_vencimento.
                    view stream s_1 frame f_rpt_s_1_Grp_detalhe_Lay_titulo.
                end /* do code_block */.

                when "Por Cliente" /*l_por_cliente*/ then code_block:
                 do:
                    if (line-counter(s_1) + 3) > v_rpt_s_1_bottom then
                        page stream s_1.
                    put stream s_1 unformatted 
                        "Cliente" to 11
                        "T°tulo" at 13
                        "/P" at 30
    &IF "{&emsfin_version}" >= "" AND "{&emsfin_version}" < "5.07A" &THEN
                        "Estab" at 33
    &ENDIF
    &IF "{&emsfin_version}" >= "5.07A" AND "{&emsfin_version}" < "9.99" &THEN
                        "Estab" at 33
    &ENDIF
                        "EspÇcie" at 39
                        "SÇrie" at 47
                        "Emiss∆o" at 53
                        "Vencimento" at 64
                        "Portador" at 75
                        "Cart" at 84
                        "Nome" at 89
                        "Convànio" at 130
                        "Vl Original" to 155 skip
                        "-----------" to 11
                        "----------------" at 13
                        "--" at 30
    &IF "{&emsfin_version}" >= "" AND "{&emsfin_version}" < "5.07A" &THEN
                        "-----" at 33
    &ENDIF
    &IF "{&emsfin_version}" >= "5.07A" AND "{&emsfin_version}" < "9.99" &THEN
                        "-----" at 33
    &ENDIF
                        "-------" at 39
                        "-----" at 47
                        "----------" at 53
                        "----------" at 64
                        "--------" at 75
                        "----" at 84
                        "----------------------------------------" at 89
                        "---------" at 130
                        "--------------" to 155 skip.
                    hide stream s_1 frame f_rpt_s_1_Grp_detalhe_Lay_emissao.
                    hide stream s_1 frame f_rpt_s_1_Grp_detalhe_Lay_grp_cliente.
                    hide stream s_1 frame f_rpt_s_1_Grp_detalhe_Lay_titulo.
                    hide stream s_1 frame f_rpt_s_1_Grp_detalhe_Lay_vencimento.
                    view stream s_1 frame f_rpt_s_1_Grp_detalhe_Lay_cliente.
                end /* do code_block */.

                when "Por Vencimento" /*l_por_vencimento*/ then code_block:
                 do:
                    if (line-counter(s_1) + 3) > v_rpt_s_1_bottom then
                        page stream s_1.
                    put stream s_1 unformatted 
                        "Vencimento" at 1
                        "/P" at 12
    &IF "{&emsfin_version}" >= "" AND "{&emsfin_version}" < "5.07A" &THEN
                        "Estab" at 15
    &ENDIF
    &IF "{&emsfin_version}" >= "5.07A" AND "{&emsfin_version}" < "9.99" &THEN
                        "Estab" at 15
    &ENDIF
                        "EspÇcie" at 21
                        "SÇrie" at 29
                        "Emiss∆o" at 35
                        "Portador" at 46
                        "Cart" at 55
                        "Cliente" to 70
                        "T°tulo" at 72
                        "Nome" at 89
                        "Convànio" at 130
                        "Vl Original" to 155 skip
                        "----------" at 1
                        "--" at 12
    &IF "{&emsfin_version}" >= "" AND "{&emsfin_version}" < "5.07A" &THEN
                        "-----" at 15
    &ENDIF
    &IF "{&emsfin_version}" >= "5.07A" AND "{&emsfin_version}" < "9.99" &THEN
                        "-----" at 15
    &ENDIF
                        "-------" at 21
                        "-----" at 29
                        "----------" at 35
                        "--------" at 46
                        "----" at 55
                        "-----------" to 70
                        "----------------" at 72
                        "----------------------------------------" at 89
                        "---------" at 130
                        "--------------" to 155 skip.
                    hide stream s_1 frame f_rpt_s_1_Grp_detalhe_Lay_cliente.
                    hide stream s_1 frame f_rpt_s_1_Grp_detalhe_Lay_emissao.
                    hide stream s_1 frame f_rpt_s_1_Grp_detalhe_Lay_grp_cliente.
                    hide stream s_1 frame f_rpt_s_1_Grp_detalhe_Lay_titulo.
                    view stream s_1 frame f_rpt_s_1_Grp_detalhe_Lay_vencimento.
                end /* do code_block */.
            end /* case case_block */.
        end /* if */.
    end /* if */.

END PROCEDURE. /* pi_imprimir_termos_tit_acr_emitidos */
/*****************************************************************************
** Procedure Interna.....: pi_eliminar_pag_livro_fisc
** Descricao.............: pi_eliminar_pag_livro_fisc
** Criado por............: Uno
** Criado em.............: 07/05/1996 11:35:30
** Alterado por..........: Uno
** Alterado em...........: 13/05/1996 08:07:52
*****************************************************************************/
PROCEDURE pi_eliminar_pag_livro_fisc:

    /************************ Parameter Definition Begin ************************/

    def param buffer p_livro_fisc
        for livro_fisc.
    def Input param p_dat_transacao
        as date
        format "99/99/9999"
        no-undo.


    /************************* Parameter Definition End *************************/

    del_pag_block:
    for
    each pag_livro_fisc exclusive-lock
    where pag_livro_fisc.cod_modul_dtsul = p_livro_fisc.cod_modul_dtsul
      and pag_livro_fisc.cod_unid_organ = p_livro_fisc.cod_unid_organ
      and pag_livro_fisc.ind_tip_livro_fisc = p_livro_fisc.ind_tip_livro_fisc

      and pag_livro_fisc.dat_inic_emis >= p_dat_transacao
    &if "{&emsuni_version}" >= "5.01" &then
    use-index pglvrfs_dat_inic
    &endif
     /*cl_eliminar_pag_livro_fisc of pag_livro_fisc*/:
        delete pag_livro_fisc.
    end /* for del_pag_block */.
END PROCEDURE. /* pi_eliminar_pag_livro_fisc */
/*****************************************************************************
** Procedure Interna.....: pi_tratar_endereco_cobr
** Descricao.............: pi_tratar_endereco_cobr
** Criado por............: Alexsandra
** Criado em.............: 16/09/1996 19:18:45
** Alterado por..........: corp45598
** Alterado em...........: 29/05/2013 14:45:07
*****************************************************************************/
PROCEDURE pi_tratar_endereco_cobr:

    /************************ Parameter Definition Begin ************************/

    def Input param p_cdn_cliente
        as Integer
        format ">>>,>>>,>>9"
        no-undo.
    def Input param p_cod_empresa
        as character
        format "x(3)"
        no-undo.


    /************************* Parameter Definition End *************************/

    /************************* Variable Definition Begin ************************/

    def var v_num_pessoa_fisic
        as integer
        format ">>>,>>>,>>9":U
        label "Pessoa F°sica"
        column-label "Pessoa F°sica"
        no-undo.


    /************************** Variable Definition End *************************/

    find cliente no-lock
        where cliente.cod_empresa = p_cod_empresa
          and cliente.cdn_cliente = p_cdn_cliente
          no-error.
    if avail cliente then do:
        if  cliente.num_pessoa mod 2 = 0
        then do:
            find pessoa_fisic no-lock
                where pessoa_fisic.num_pessoa_fisic = cliente.num_pessoa
                no-error.
            if  avail pessoa_fisic
            then do:
                find pais no-lock
                    where pais.cod_pais = pessoa_fisic.cod_pais
                    no-error.
                if  v_log_pessoa_fisic_cobr
                then do:
                    if  v_ind_ender_complet = "Endereáo" /*l_Endereáo*/ 
                    then do:
                      &if '{&emsfin_version}' >= '5.07' &then
                         if  pessoa_fisic.nom_ender_cobr = ""
                         then do:
                      &else
                         find first tab_livre_emsuni no-lock
                              where tab_livre_emsuni.cod_modul_dtsul      = "utb" /*l_utb*/ 
                                and tab_livre_emsuni.cod_tab_dic_dtsul    = 'pessoa_fisic':U
                                and tab_livre_emsuni.cod_compon_1_idx_tab = STRING(0)
                                and tab_livre_emsuni.cod_compon_2_idx_tab = STRING(pessoa_fisic.num_pessoa_fisic) no-error.
                         if not avail tab_livre_emsuni then do:
                              find first tab_livre_emsuni no-lock
                                   where tab_livre_emsuni.cod_modul_dtsul      = "utb" /*l_utb*/ 
                                     and tab_livre_emsuni.cod_tab_dic_dtsul    = 'pessoa_fisic':U
                                     and tab_livre_emsuni.cod_compon_2_idx_tab = STRING(pessoa_fisic.num_pessoa_fisic) no-error.                                                   
                         end.              
                         if  (avail tab_livre_emsuni and (GetEntryField(4, tab_livre_emsuni.cod_livre_1, chr(10))) = "") or
                             not avail tab_livre_emsuni
                         then do:
                      &endif
                            run pi_vrf_nom_ender_cobr_fisic_1. /* nova PI*/
                        end.
                        else do:
                            run pi_vrf_nom_ender_cobr_fisic. /* nova PI*/
                        end.
                    end.
                    else do:
                        &if defined(BF_FIN_4LINHAS_END) &then
                          &if '{&emsfin_version}' >= '5.07' &then
                            if  pessoa_fisic.nom_ender_cobr_text = ""
                            then do:
                          &else
                            find first tab_livre_emsuni no-lock
                                 where tab_livre_emsuni.cod_modul_dtsul      = "utb" /*l_utb*/ 
                                   and tab_livre_emsuni.cod_tab_dic_dtsul    = 'pessoa_fisic':U
                                   and tab_livre_emsuni.cod_compon_1_idx_tab = STRING(0)
                                   and tab_livre_emsuni.cod_compon_2_idx_tab = STRING(pessoa_fisic.num_pessoa_fisic) no-error.
                            if not avail tab_livre_emsuni then do:
                                 find first tab_livre_emsuni no-lock
                                      where tab_livre_emsuni.cod_modul_dtsul      = "utb" /*l_utb*/ 
                                        and tab_livre_emsuni.cod_tab_dic_dtsul    = 'pessoa_fisic':U
                                        and tab_livre_emsuni.cod_compon_2_idx_tab = STRING(pessoa_fisic.num_pessoa_fisic) no-error.                                                   
                            end.        
                            if  avail tab_livre_emsuni and (GetEntryField(4, tab_livre_emsuni.cod_livre_1, chr(10))) = ""
                            then do:
                          &endif                    
                                run pi_vrf_nom_ender_cobr_fisic_1. /* nova PI*/
                            end.
                            else do:
                                run pi_vrf_nom_ender_cobr_fisic. /* nova PI*/
                            end.
                        &endif
                    end.
                end /* if */.
                else do:
                    run pi_vrf_nom_ender_cobr_fisic_1. /* nova PI*/ 
                end.
            end /* if */.
        end /* if */.
        else do:
            find pessoa_jurid no-lock
                where pessoa_jurid.num_pessoa_jurid = cliente.num_pessoa
                no-error.
            if  avail pessoa_jurid
                and pessoa_jurid.num_pessoa_jurid_cobr <> pessoa_jurid.num_pessoa_jurid
                and pessoa_jurid.num_pessoa_jurid_cobr <> ?
                and pessoa_jurid.num_pessoa_jurid_cobr <> 0
            then do:
                assign v_num_pessoa_jurid = pessoa_jurid.num_pessoa_jurid_cobr.
                find pessoa_jurid no-lock
                    where pessoa_jurid.num_pessoa_jurid = v_num_pessoa_jurid
                    no-error.
            end /* if */.
            if  avail pessoa_jurid
            then do:
                find pais no-lock
                    where pais.cod_pais = pessoa_jurid.cod_pais
                    no-error.
                if  v_ind_ender_complet = "Endereáo" /*l_endereco*/  then do:
                    if  pessoa_jurid.nom_ender_cobr = ""
                    then do:
                        run pi_vrf_nom_ender_cobr /*pi_vrf_nom_ender_cobr*/.
                    end /* if */.
                    else do:
                        run pi_vrf_nom_ender_cobr_1 /*pi_vrf_nom_ender_cobr_1*/.
                    end /* else */.
                end.
                else do:
                    &if defined(BF_FIN_4LINHAS_END) &then
                        if  pessoa_jurid.nom_ender_cobr_text = ""
                        then do:
                            run pi_vrf_nom_ender_cobr /*pi_vrf_nom_ender_cobr*/.
                        end /* if */.
                        else do:
                            run pi_vrf_nom_ender_cobr_1 /*pi_vrf_nom_ender_cobr_1*/.
                        end /* else */.
                    &endif
                end.
            end /* if */.
        end /* else */.
    end.
END PROCEDURE. /* pi_tratar_endereco_cobr */
/*****************************************************************************
** Procedure Interna.....: pi_vld_valores_relatorio_fiscal_acr
** Descricao.............: pi_vld_valores_relatorio_fiscal_acr
** Criado por............: Roberto
** Criado em.............: 27/10/1997 17:36:58
** Alterado por..........: fut41675
** Alterado em...........: 18/02/2011 18:12:12
*****************************************************************************/
PROCEDURE pi_vld_valores_relatorio_fiscal_acr:

    /* **
     Valida troca do indicador econìmico da FE da empresa corrente.
    ***/
    find histor_finalid_econ no-lock
         where histor_finalid_econ.cod_finalid_econ        = v_cod_finalid_econ
           and histor_finalid_econ.dat_inic_valid_finalid >= v_dat_emis_docto_ini
           and histor_finalid_econ.dat_inic_valid_finalid <= v_dat_emis_docto_fim
         no-error.
    if  avail histor_finalid_econ then do:
        /* Troca de Indicador Econìmico na faixa de Emiss∆o Informada ! */
        run pi_messages (input "show",
                         input 5121,
                         input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9",
                                            histor_finalid_econ.dat_inic_valid_finalid - 1)) /*msg_5121*/.
        return error.
    end.

    /* **
     Valida Faixas
    ***/
    if  v_dat_emis_docto_ini          > v_dat_emis_docto_fim           then do:
        /* &1 Inicial deve ser menor ou igual a &1 Final ! */
        run pi_messages (input "show",
                         input 5123,
                         input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9",
                                            "Emiss∆o")) /*msg_5123*/.
        assign v_wgh_focus = v_dat_emis_docto_ini:handle in frame f_rpt_41_tit_acr_emitidos.
        return error.
    end.
    if  v_cod_espec_docto_ini         > v_cod_espec_docto_fim          then do:
        /* &1 Inicial deve ser menor ou igual a(o) &1 Final ! */
        run pi_messages (input "show",
                         input 5123,
                         input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9",
                                            "EspÇcie")) /*msg_5123*/.
        assign v_wgh_focus = v_cod_espec_docto_ini:handle in frame f_rpt_41_tit_acr_emitidos.
        return error.
    end.
    if  v_cod_ser_docto_ini           > v_cod_ser_docto_fim            then do:
        /* &1 Inicial deve ser menor ou igual a(o) &1 Final ! */
        run pi_messages (input "show",
                         input 5123,
                         input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9",
                                            "SÇrie")) /*msg_5123*/.
        assign v_wgh_focus = v_cod_ser_docto_ini:handle in frame f_rpt_41_tit_acr_emitidos.
        return error.
    end.
    if  v_cdn_cliente_ini             > v_cdn_cliente_fim              then do:
        /* &1 Inicial deve ser menor ou igual a(o) &1 Final ! */
        run pi_messages (input "show",
                         input 5123,
                         input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9",
                                            "Cliente")) /*msg_5123*/.
        assign v_wgh_focus = v_cdn_cliente_ini:handle in frame f_rpt_41_tit_acr_emitidos.
        return error.
    end.
    if  v_cod_portador_ini            > v_cod_portador_fim             then do:
        /* &1 Inicial deve ser menor ou igual a(o) &1 Final ! */
        run pi_messages (input "show",
                         input 5123,
                         input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9",
                                            "Portador")) /*msg_5123*/.
        assign v_wgh_focus = v_cod_portador_ini:handle in frame f_rpt_41_tit_acr_emitidos.
        return error.
    end.
    if  v_cod_cart_bcia_ini           > v_cod_cart_bcia_fim            then do:
        /* &1 Inicial deve ser menor ou igual a(o) &1 Final ! */
        run pi_messages (input "show",
                         input 5123,
                         input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9",
                                            "Carteira")) /*msg_5123*/.
        assign v_wgh_focus = v_cod_cart_bcia_ini:handle in frame f_rpt_41_tit_acr_emitidos.
        return error.
    end.
    if  v_dat_vencto_tit_acr_ini      > v_dat_vencto_tit_acr_fim       then do:
        /* &1 Inicial deve ser menor ou igual a(o) &1 Final ! */
        run pi_messages (input "show",
                         input 5123,
                         input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9",
                                            "Vencimento")) /*msg_5123*/.
        assign v_wgh_focus = v_dat_vencto_tit_acr_ini:handle in frame f_rpt_41_tit_acr_emitidos.
        return error.
    end.
END PROCEDURE. /* pi_vld_valores_relatorio_fiscal_acr */
/*****************************************************************************
** Procedure Interna.....: pi_retornar_finalid_econ_corren_estab
** Descricao.............: pi_retornar_finalid_econ_corren_estab
** Criado por............: 
** Criado em.............: // 
** Alterado por..........: fut41061
** Alterado em...........: 27/04/2009 08:43:48
*****************************************************************************/
PROCEDURE pi_retornar_finalid_econ_corren_estab:

    /************************ Parameter Definition Begin ************************/

    def Input param p_cod_estab
    &IF "{&emsfin_version}" >= "" AND "{&emsfin_version}" < "5.07A" &THEN
        as character
        format "x(3)"
    &ENDIF
    &IF "{&emsfin_version}" >= "5.07A" AND "{&emsfin_version}" < "9.99" &THEN
        as Character
        format "x(5)"
    &ENDIF
        no-undo.
    def output param p_cod_finalid_econ
        as character
        format "x(10)"
        no-undo.

    /************************* Parameter Definition End *************************/
    
    find estabelecimento no-lock
         where estabelecimento.cod_estab = p_cod_estab
         use-index stblcmnt_id no-error.
    if  avail estabelecimento
    then do:
       find pais no-lock
            where pais.cod_pais = estabelecimento.cod_pais
             no-error.
       assign p_cod_finalid_econ = pais.cod_finalid_econ_pais.
    end.
    
END PROCEDURE. /* pi_retornar_finalid_econ_corren_estab */
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
** Procedure Interna.....: pi_vrf_nom_ender_cobr
** Descricao.............: pi_vrf_nom_ender_cobr
** Criado por............: brf12302
** Criado em.............: 20/03/2001 16:23:22
** Alterado por..........: brf12302
** Alterado em...........: 04/04/2001 11:28:16
*****************************************************************************/
PROCEDURE pi_vrf_nom_ender_cobr:

    /* ## A vari†vel v_cod_cep_dest_cobr ser† usada pelo programa Destinaá∆o de Cobranáa,
          sem o formato do cep. ## */
    assign v_nom_endereco      = pessoa_jurid.nom_endereco
           v_nom_bairro        = pessoa_jurid.nom_bairro
           v_cod_cep           = string(pessoa_jurid.cod_cep, pais.cod_format_cep)
           v_cod_cep_dest_cobr = pessoa_jurid.cod_cep
           v_nom_cidade        = pessoa_jurid.nom_cidade
           v_cod_unid_federac  = pessoa_jurid.cod_unid_federac.

    &if defined(BF_FIN_4LINHAS_END) &then
        cont_block:
        REPEAT v_num_cont_entry = 1 TO NUM-ENTRIES(pessoa_jurid.nom_ender_text, chr(10)):
            if  v_num_cont_entry = 1 then assign v_nom_ender_lin_1 = entry( 1, pessoa_jurid.nom_ender_text, chr(10)).
            if  v_num_cont_entry = 2 then assign v_nom_ender_lin_2 = entry( 2, pessoa_jurid.nom_ender_text, chr(10)).
            if  v_num_cont_entry = 3 then assign v_nom_ender_lin_3 = entry( 3, pessoa_jurid.nom_ender_text, chr(10)).
            if  v_num_cont_entry = 4 then assign v_nom_ender_lin_4 = entry( 4, pessoa_jurid.nom_ender_text, chr(10)).
            if  v_num_cont_entry = 4 then
                leave cont_block.
        end.
    &endif

END PROCEDURE. /* pi_vrf_nom_ender_cobr */
/*****************************************************************************
** Procedure Interna.....: pi_vrf_nom_ender_cobr_1
** Descricao.............: pi_vrf_nom_ender_cobr_1
** Criado por............: brf12302
** Criado em.............: 20/03/2001 16:25:54
** Alterado por..........: brf12302
** Alterado em...........: 20/03/2001 16:27:20
*****************************************************************************/
PROCEDURE pi_vrf_nom_ender_cobr_1:

    /* ## A vari†vel v_cod_cep_dest_cobr ser† usada pelo programa Destinaá∆o de Cobranáa,
         sem o formato do cep. ##*/
    assign v_nom_endereco      = pessoa_jurid.nom_ender_cobr
           v_nom_bairro        = pessoa_jurid.nom_bairro_cobr
           v_cod_cep           = string(pessoa_jurid.cod_cep_cobr, pais.cod_format_cep)
           v_cod_cep_dest_cobr = pessoa_jurid.cod_cep_cobr
           v_nom_cidade        = pessoa_jurid.nom_cidad_cobr
           v_cod_unid_federac  = pessoa_jurid.cod_unid_federac_cobr.

    &if defined(BF_FIN_4LINHAS_END) &then
        cont_block:
        REPEAT v_num_cont_entry = 1 TO NUM-ENTRIES(pessoa_jurid.nom_ender_cobr_text, chr(10)):
            if  v_num_cont_entry = 1 then assign v_nom_ender_lin_1 = entry( 1, pessoa_jurid.nom_ender_cobr_text, chr(10)).
            if  v_num_cont_entry = 2 then assign v_nom_ender_lin_2 = entry( 2, pessoa_jurid.nom_ender_cobr_text, chr(10)).
            if  v_num_cont_entry = 3 then assign v_nom_ender_lin_3 = entry( 3, pessoa_jurid.nom_ender_cobr_text, chr(10)).
            if  v_num_cont_entry = 4 then assign v_nom_ender_lin_4 = entry( 4, pessoa_jurid.nom_ender_cobr_text, chr(10)).
            if  v_num_cont_entry = 4 then
                leave cont_block.
        end.
    &endif

END PROCEDURE. /* pi_vrf_nom_ender_cobr_1 */
/*****************************************************************************
** Procedure Interna.....: pi_verifica_vendor
** Descricao.............: pi_verifica_vendor
** Criado por............: bre19062
** Criado em.............: 15/09/2002 17:37:36
** Alterado por..........: bre19062
** Alterado em...........: 15/09/2002 17:38:53
*****************************************************************************/
PROCEDURE pi_verifica_vendor:


    /* Begin_Include: i_vrf_modul_vendor */
    /* ==> MODULO VENDOR <== */
    /* alteraá∆o por demanda, favor manter a alteraá∆o abaixo*/
    /* Verifica liberaªío do mΩdulo Vendor */
    assign v_log_modul_vendor = no.
    &IF '{&emsfin_version}' >= '5.05'  AND '{&emsfin_version}' <= '5.06'   &THEN 
        run prgfin/acr/acr930za.py (output v_log_modul_vendor) /* prg_fnc_verifica_liberacao_vendor*/.
    &ELSE
        Assign v_log_modul_vendor = Yes.
    &ENDIF
    /* End_Include: i_vrf_modul_vendor */

END PROCEDURE. /* pi_verifica_vendor */
/*****************************************************************************
** Procedure Interna.....: pi_vrf_nom_ender_cobr_fisic
** Descricao.............: pi_vrf_nom_ender_cobr_fisic
** Criado por............: its35892_3
** Criado em.............: 21/11/2006 13:55:23
** Alterado por..........: corp45598
** Alterado em...........: 21/05/2013 16:53:22
*****************************************************************************/
PROCEDURE pi_vrf_nom_ender_cobr_fisic:

    /* ## A vari†vel v_cod_cep_dest_cobr ser† usada pelo programa Destinaá∆o de Cobranáa,
         sem o formato do cep. ##*/
    &if '{&emsfin_version}' >= '5.07' &then
        assign v_nom_endereco      = pessoa_fisic.nom_ender_cobr
               v_nom_bairro        = pessoa_fisic.nom_bairro_cobr
               v_cod_cep           = string(pessoa_fisic.cod_cep_cobr, pais.cod_format_cep)
               v_cod_cep_dest_cobr = pessoa_fisic.cod_cep_cobr
               v_nom_cidade        = pessoa_fisic.nom_cidad_cobr
               v_cod_unid_federac  = pessoa_fisic.cod_unid_federac_cobr.

        &if defined(BF_FIN_4LINHAS_END) &then
            cont_block:
            REPEAT v_num_cont_entry = 1 TO NUM-ENTRIES(pessoa_fisic.nom_ender_cobr_text, chr(10)):
                if  v_num_cont_entry = 1 then assign v_nom_ender_lin_1 = GetEntryField(1, pessoa_fisic.nom_ender_cobr_text, chr(10)).
                if  v_num_cont_entry = 2 then assign v_nom_ender_lin_2 = GetEntryField(2, pessoa_fisic.nom_ender_cobr_text, chr(10)).
                if  v_num_cont_entry = 3 then assign v_nom_ender_lin_3 = GetEntryField(3, pessoa_fisic.nom_ender_cobr_text, chr(10)).
                if  v_num_cont_entry = 4 then assign v_nom_ender_lin_4 = GetEntryField(4, pessoa_fisic.nom_ender_cobr_text, chr(10)).
                if  v_num_cont_entry = 4 then
                    leave cont_block.
            end.
        &endif
    &else
       if avail tab_livre_emsuni then do:
          assign v_nom_endereco      = GetEntryField(4, tab_livre_emsuni.cod_livre_1, chr(10))
                 v_nom_bairro        = GetEntryField(7, tab_livre_emsuni.cod_livre_1, chr(10))
                 v_cod_cep           = GetEntryField(8, tab_livre_emsuni.cod_livre_1, chr(10)) + "," + GetEntryField(2, tab_livre_emsuni.cod_livre_1, chr(10))
                 v_cod_cep_dest_cobr = GetEntryField(8, tab_livre_emsuni.cod_livre_1, chr(10))
                 v_nom_cidade        = GetEntryField(9, tab_livre_emsuni.cod_livre_1, chr(10))
                 v_cod_unid_federac  = GetEntryField(3, tab_livre_emsuni.cod_livre_1, chr(10)).

          &if defined(BF_FIN_4LINHAS_END) &then
              cont_block:
              REPEAT v_num_cont_entry = 1 TO NUM-ENTRIES(GetEntryField(5, tab_livre_emsuni.cod_livre_1, chr(10)), '&'):
                  if  v_num_cont_entry = 1 then assign v_nom_ender_lin_1 = GetEntryField(1, GetEntryField(5, tab_livre_emsuni.cod_livre_1, chr(10)), '&').
                  if  v_num_cont_entry = 2 then assign v_nom_ender_lin_2 = GetEntryField(2, GetEntryField(5, tab_livre_emsuni.cod_livre_1, chr(10)), '&').
                  if  v_num_cont_entry = 3 then assign v_nom_ender_lin_3 = GetEntryField(3, GetEntryField(5, tab_livre_emsuni.cod_livre_1, chr(10)), '&').
                  if  v_num_cont_entry = 4 then assign v_nom_ender_lin_4 = GetEntryField(4, GetEntryField(5, tab_livre_emsuni.cod_livre_1, chr(10)), '&').
                  if  v_num_cont_entry = 4 then
                      leave cont_block.
              end.
          &endif
       end.
       else do:
          /* Os programas que chamam essa procedure interna j† fazem o find na tab_libre_emsuni e apenas executam caso ela exista. 
             A l¢gica foi inserida para que caso seja feita uma chamada a essa pi e n∆o realizado o find antes da execuá∆o         */   
          find first tab_livre_emsuni no-lock
             where tab_livre_emsuni.cod_modul_dtsul      = "utb" /*l_utb*/ 
               and tab_livre_emsuni.cod_tab_dic_dtsul    = 'pessoa_fisic':U
               and tab_livre_emsuni.cod_compon_1_idx_tab = STRING(0)
               and tab_livre_emsuni.cod_compon_2_idx_tab = STRING(pessoa_fisic.num_pessoa_fisic) no-error.
          if not avail tab_livre_emsuni then do:
              find first tab_livre_emsuni no-lock
                   where tab_livre_emsuni.cod_modul_dtsul      = "utb" /*l_utb*/ 
                     and tab_livre_emsuni.cod_tab_dic_dtsul    = 'pessoa_fisic':U
                     and tab_livre_emsuni.cod_compon_2_idx_tab = STRING(pessoa_fisic.num_pessoa_fisic) no-error.                                                
          end.                        
          if avail tab_livre_emsuni then do:
             assign v_nom_endereco      = GetEntryField(4, tab_livre_emsuni.cod_livre_1, chr(10))
                    v_nom_bairro        = GetEntryField(7, tab_livre_emsuni.cod_livre_1, chr(10))
                    v_cod_cep           = GetEntryField(8, tab_livre_emsuni.cod_livre_1, chr(10)) + "," + GetEntryField(2, tab_livre_emsuni.cod_livre_1, chr(10))
                    v_cod_cep_dest_cobr = GetEntryField(8, tab_livre_emsuni.cod_livre_1, chr(10))
                    v_nom_cidade        = GetEntryField(9, tab_livre_emsuni.cod_livre_1, chr(10))
                    v_cod_unid_federac  = GetEntryField(3, tab_livre_emsuni.cod_livre_1, chr(10)).

             &if defined(BF_FIN_4LINHAS_END) &then
                 cont_block:
                 REPEAT v_num_cont_entry = 1 TO NUM-ENTRIES(GetEntryField(5, tab_livre_emsuni.cod_livre_1, chr(10)), '&'):
                     if  v_num_cont_entry = 1 then assign v_nom_ender_lin_1 = GetEntryField(1, GetEntryField(5, tab_livre_emsuni.cod_livre_1, chr(10)), '&').
                     if  v_num_cont_entry = 2 then assign v_nom_ender_lin_2 = GetEntryField(2, GetEntryField(5, tab_livre_emsuni.cod_livre_1, chr(10)), '&').
                     if  v_num_cont_entry = 3 then assign v_nom_ender_lin_3 = GetEntryField(3, GetEntryField(5, tab_livre_emsuni.cod_livre_1, chr(10)), '&').
                     if  v_num_cont_entry = 4 then assign v_nom_ender_lin_4 = GetEntryField(4, GetEntryField(5, tab_livre_emsuni.cod_livre_1, chr(10)), '&').
                     if  v_num_cont_entry = 4 then
                         leave cont_block.
                 end.
             &endif
          end.
       end.
    &endif
END PROCEDURE. /* pi_vrf_nom_ender_cobr_fisic */
/*****************************************************************************
** Procedure Interna.....: pi_vrf_nom_ender_cobr_fisic_1
** Descricao.............: pi_vrf_nom_ender_cobr_fisic_1
** Criado por............: its35892_3
** Criado em.............: 21/11/2006 13:57:13
** Alterado por..........: its35892_3
** Alterado em...........: 11/12/2006 08:39:20
*****************************************************************************/
PROCEDURE pi_vrf_nom_ender_cobr_fisic_1:

    /* ## A vari†vel v_cod_cep_dest_cobr ser† usada pelo programa Destinaá∆o de Cobranáa,
         sem o formato do cep. ##*/
    assign v_nom_endereco      = pessoa_fisic.nom_endereco
           v_nom_bairro        = pessoa_fisic.nom_bairro
           v_cod_cep           = string(pessoa_fisic.cod_cep, pais.cod_format_cep)
           v_cod_cep_dest_cobr = pessoa_fisic.cod_cep
           v_nom_cidade        = pessoa_fisic.nom_cidade
           v_cod_unid_federac  = pessoa_fisic.cod_unid_federac.

    &if defined(BF_FIN_4LINHAS_END) &then
        cont_block:
        REPEAT v_num_cont_entry = 1 TO NUM-ENTRIES(pessoa_fisic.nom_ender_text, chr(10)):
            if  v_num_cont_entry = 1 then assign v_nom_ender_lin_1 = GetEntryField(1, pessoa_fisic.nom_ender_text, chr(10)).
            if  v_num_cont_entry = 2 then assign v_nom_ender_lin_2 = GetEntryField(2, pessoa_fisic.nom_ender_text, chr(10)).
            if  v_num_cont_entry = 3 then assign v_nom_ender_lin_3 = GetEntryField(3, pessoa_fisic.nom_ender_text, chr(10)).
            if  v_num_cont_entry = 4 then assign v_nom_ender_lin_4 = GetEntryField(4, pessoa_fisic.nom_ender_text, chr(10)).
            if  v_num_cont_entry = 4 then
                leave cont_block.
        end.
    &endif

END PROCEDURE. /* pi_vrf_nom_ender_cobr_fisic_1 */
/*****************************************************************************
** Procedure Interna.....: pi_vld_permissao_usuar_estab_empres
** Descricao.............: pi_vld_permissao_usuar_estab_empres
** Criado por............: bre18732
** Criado em.............: 21/06/2002 16:19:21
** Alterado por..........: fut42625
** Alterado em...........: 25/01/2011 16:50:44
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


    /************************** Variable Definition End *************************/


    /* Begin_Include: i_vld_permissao_usuar_estab_empres */
    find last param_geral_apb no-lock no-error.
    if avail param_geral_apb then 
        assign v_log_reg_corporat = param_geral_apb.log_reg_corporat.

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
                    assign tt_estabelecimento_empresa.tta_cod_estab   = estabelecimento.cod_estab
                           tt_estabelecimento_empresa.tta_nom_pessoa  = estabelecimento.nom_pessoa
                           tt_estabelecimento_empresa.tta_cod_empresa = estabelecimento.cod_empresa. 
                    leave.
                end.
            end.
            else do:
                create tt_estabelecimento_empresa. 
                assign tt_estabelecimento_empresa.tta_cod_estab   = estabelecimento.cod_estab
                       tt_estabelecimento_empresa.tta_nom_pessoa  = estabelecimento.nom_pessoa
                       tt_estabelecimento_empresa.tta_cod_empresa = estabelecimento.cod_empresa. 
            end.
        end.
    end.

    assign v_des_estab_select = "".
    for each tt_estabelecimento_empresa:
        if v_des_estab_select = " " then
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
        label "Estab"
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

/*************************************  *************************************/
/*****************************************************************************
**  Procedure Interna: pi_verifica_codigo_convenio
**  Descricao........: Busca o numero do Convànio
*****************************************************************************/
PROCEDURE pi_verifica_codigo_convenio:
    def input param c_estab     like tt_rpt_tit_acr_emit.tta_cod_estab       no-undo.
    def input param c_especie   like tt_rpt_tit_acr_emit.tta_cod_espec_docto no-undo.
    def input param c_serie     like tt_rpt_tit_acr_emit.tta_cod_ser_docto   no-undo.
    def input param c_titulo    like tt_rpt_tit_acr_emit.tta_cod_tit_acr     no-undo.
    def input param c_parcela   like tt_rpt_tit_acr_emit.tta_cod_parcela     no-undo.
    
    define buffer b_tit_acr  for tit_acr.
    define buffer bf_tit_acr for tit_acr.

    
    DEFINE BUFFER b2_movto_tit_acr FOR movto_tit_acr.
    DEFINE BUFFER bf_movto_tit_acr FOR movto_tit_acr.
    DEFINE BUFFER b2_tit_acr       FOR tit_acr.

    ASSIGN v_cod_convenio = "".
    
    if c_especie = "CV" then do:
        FIND FIRST cst_nota_fiscal NO-LOCK
             WHERE cst_nota_fiscal.cod_estabel = c_estab 
               AND cst_nota_fiscal.serie       = c_serie 
               AND cst_nota_fiscal.nr_nota_fis = c_titulo    NO-ERROR.
        IF AVAIL cst_nota_fiscal THEN DO:
            ASSIGN v_cod_convenio = cst_nota_fiscal.convenio.       
        END.    
    end.
    else if c_especie = "CF" then do:
    
        FIND FIRST b_tit_acr NO-LOCK
             WHERE b_tit_acr.cod_estab       = c_estab
               AND b_tit_acr.cod_espec_docto = c_especie
               AND b_tit_acr.cod_ser_docto   = c_serie 
               AND b_tit_acr.cod_tit_acr     = c_titulo
               AND b_tit_acr.cod_parcela     = c_parcela  NO-ERROR.
        IF AVAIL b_tit_acr THEN DO:     
            FIND FIRST renegoc_acr NO-LOCK
                 WHERE renegoc_acr.num_renegoc_cobr_acr = b_tit_acr.num_renegoc_cobr_acr NO-ERROR.
            IF AVAIL renegoc_acr THEN DO:
    
                estab_block: 
                FOR EACH estabelecimento NO-LOCK
                   WHERE estabelecimento.cod_empresa = v_cod_empres_usuar:
                   
                   movto_tit_block:
                   FOR FIRST movto_tit_acr no-lock 
                       WHERE movto_tit_acr.cod_estab           = estabelecimento.cod_estab
                         AND movto_tit_acr.cod_refer           = renegoc_acr.cod_refer
                         AND movto_tit_acr.ind_trans_acr_abrev = "LQRN" /*l_lqrn*/ 
                   USE-INDEX mvtttcr_refer:
    
                        FIND FIRST bf_tit_acr USE-INDEX titacr_token 
                             WHERE bf_tit_acr.cod_estab      = movto_tit_acr.cod_estab 
                               AND bf_tit_acr.num_id_tit_acr = movto_tit_acr.num_id_tit_acr NO-ERROR.
                        IF AVAIL bf_tit_acr THEN DO:
    
                            FOR FIRST cst_nota_fiscal NO-LOCK                                              
                                WHERE cst_nota_fiscal.cod_estabel = bf_tit_acr.cod_estab           
                                  AND cst_nota_fiscal.serie       = bf_tit_acr.cod_ser_docto 
                                  AND cst_nota_fiscal.nr_nota_fis = bf_tit_acr.cod_tit_acr:
    
                                ASSIGN v_cod_convenio = cst_nota_fiscal.convenio.
                                LEAVE estab_block.
    
                            END.                       
                        END.

                        IF v_cod_convenio = "" THEN DO:

                            FIND FIRST bf_movto_tit_acr OF bf_tit_acr 
                                 WHERE bf_movto_tit_acr.ind_trans_acr_abrev = "TRES" NO-ERROR.
                            IF AVAIL bf_movto_tit_acr THEN DO:

                                FOR FIRST b2_movto_tit_acr no-lock
                                    where b2_movto_tit_acr.cod_estab            = bf_movto_tit_acr.cod_estab_tit_acr_pai
                                      and b2_movto_tit_acr.num_id_movto_tit_acr = bf_movto_tit_acr.num_id_movto_tit_acr_pai
                                      AND b2_movto_tit_acr.ind_trans_acr_abrev  = "LQTE" :
    
                                     FIND FIRST b2_tit_acr USE-INDEX titacr_token 
                                          WHERE b2_tit_acr.cod_estab      = b2_movto_tit_acr.cod_estab 
                                            AND b2_tit_acr.num_id_tit_acr = b2_movto_tit_acr.num_id_tit_acr NO-ERROR.
                                     IF AVAIL b2_tit_acr THEN DO:
    
                                         FOR FIRST cst_nota_fiscal NO-LOCK                                              
                                             WHERE cst_nota_fiscal.cod_estabel = b2_tit_acr.cod_estab           
                                               AND cst_nota_fiscal.serie       = b2_tit_acr.cod_ser_docto 
                                               AND cst_nota_fiscal.nr_nota_fis = b2_tit_acr.cod_tit_acr:
    
                                             ASSIGN v_cod_convenio = cst_nota_fiscal.convenio.
                                             LEAVE estab_block.
    
                                         END.                       
                                     END.
                                END.
                            END.

                        END.
                    END.
                END.
            END.  
        END.     
    end.
    else assign v_cod_convenio = "".       

END PROCEDURE.  /* pi_verifica_codigo_convenio */
/***********************  End of rpt_tit_acr_emitidos ***********************/
