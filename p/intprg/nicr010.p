/*****************************************************************************
** Copyright DATASUL S.A. (1994)
** Todos os Direitos Reservados.
** 
** Este fonte e de propriedade exclusiva da DATASUL, sua reproducao
** parcial ou total por qualquer meio, so' podera ser feita mediante
** autorizacao expressa.
**
** Programa..............: fnc_conc_oper_acr_fat_novo
** Descricao.............: FunØ¥es
** Versao................:  1.00.00.001
** Procedimento..........: sp2_concilia_acr_fat_n
** Nome Externo..........: prgfin/acr/acr427za.p
** Data Geracao..........: 25/04/2013 - 14:18:38
** Criado por............: fut42929
** Criado em.............: 02/10/2012 11:24:13
** Alterado por..........: fut41675_4
** Alterado em...........: 25/04/2013 14:01:15
** Gerado por............: fut41675_4
*****************************************************************************/
DEFINE BUFFER unid_organ       FOR ems5.unid_organ.
DEFINE BUFFER pais             FOR ems5.pais.
DEFINE BUFFER empresa          FOR ems5.empresa.
DEFINE BUFFER segur_unid_organ FOR ems5.segur_unid_organ.

def var c-versao-prg as char initial " 1.00.00.001":U no-undo.

{include/i_dbinst.i}
{include/i_dbtype.i}
{include/i_fcldef.i}


/******************************* Private-Data *******************************/
assign this-procedure:private-data = "HLP=37":U.
/*************************************  *************************************/

&if "{&emsfin_version}" < "5.08" &then
run pi_messages (input "show",
                 input 5135,
                 input substitute ("&1~&2~&3~&4~&5~&6~&7~&8~&9", 
                                    "INICIAL","~~MAIOR","~~FNC_CONC_OPER_ACR_FAT_NOVO","~~5.08","~~EMSFIN","~~{&emsfin_version}")) /*msg_5135*/.
&else

/********************* Temporary Table Definition Begin *********************/

def temp-table tt_acr no-undo
    field ttv_dat_trans                    as date format "99/99/9999" initial ?
    field ttv_cod_estab                    as character format "x(3)" label "Estabelecimento" column-label "Estabelecimento"
    field ttv_cdn_cliente                  as Integer format ">>>,>>>,>>9" initial 0 label "Cliente" column-label "Cliente"
    field ttv_cod_espec_docto              as character format "x(3)" label "EspÇcie Documento" column-label "EspÇcie"
    field ttv_cod_ser_docto                as character format "x(3)" label "SÇrie Docto" column-label "SÇrie"
    field ttv_cod_tit_acr                  as character format "x(10)" label "T°tulo" column-label "T°tulo"
    field ttv_cod_parcela                  as character format "x(02)" label "Parcela" column-label "Parc"
    field ttv_val_origin_tit_acr           as decimal format "->>>,>>>,>>9.99" decimals 2 label "Valor Original" column-label "Valor Original"
    field ttv_val_fgl                      as decimal format "->>,>>>,>>>,>>9.99" decimals 2
    field ttv_log_estordo                  as logical format "Sim/n∆o" initial no label "Estornado" column-label "Estornado"
    index tt_codigo                       
          ttv_cod_estab                    ascending
          ttv_cdn_cliente                  ascending
          ttv_cod_espec_docto              ascending
          ttv_cod_ser_docto                ascending
          ttv_cod_tit_acr                  ascending
          ttv_cod_parcela                  ascending
    index tt_ordem                        
          ttv_dat_trans                    ascending
          ttv_cod_tit_acr                  ascending
    index tt_tudo                         
          ttv_dat_trans                    ascending
          ttv_cod_estab                    ascending
          ttv_cdn_cliente                  ascending
          ttv_cod_espec_docto              ascending
          ttv_cod_ser_docto                ascending
          ttv_cod_tit_acr                  ascending
          ttv_cod_parcela                  ascending
    .

def temp-table tt_concil_acr_fat no-undo
    field tta_cod_estab                    as character format "x(3)" label "Estabelecimento" column-label "Estab"
    field tta_cdn_cliente                  as Integer format ">>>,>>>,>>9" initial 0 label "Cliente" column-label "Cliente"
    field tta_cod_espec_docto              as character format "x(3)" label "EspÇcie Documento" column-label "EspÇcie"
    field tta_cod_ser_docto                as character format "x(3)" label "SÇrie Documento" column-label "SÇrie"
    field tta_cod_tit_acr                  as character format "x(10)" label "T°tulo" column-label "T°tulo"
    field tta_cod_parcela                  as character format "x(02)" label "Parcela" column-label "Parc"
    field ttv_val_acr                      as decimal format "->>,>>>,>>>,>>9.99" decimals 2 label "Valor ACR" column-label "Valor ACR"
    field ttv_val_faturam                  as decimal format "->>,>>>,>>>,>>9.99" decimals 2 label "Valor FAT" column-label "Valor FAT"
    field ttv_val_dif_acr_faturam          as decimal format "->>,>>>,>>>,>>9.99" decimals 2 label "Valor Diferenáa" column-label "Valor Diferenáa"
    field ttv_log_erro                     as logical format "Sim/n∆o" initial yes
    field ttv_des_erro                     as character format "x(50)" label "Inconsist¨ncia" column-label "Inconsist¨ncia"
    field ttv_num_nota_concil_faturam_dif  as integer format ">>>,>>>,>>9" label "Total FAT"
    field ttv_num_tit_acr_concil           as integer format ">>>,>>>,>>9" label "Total ACR"
    field ttv_num_tit_acr_concil_dif       as integer format ">>>,>>>,>>9" label "Total ACR"
    .


def temp-table tt_concil_tit_agrupa no-undo
    field cod_estab                    as character format "x(3)" label "Estabelecimento" column-label "Estab"
    field cdn_cliente                  as Integer format ">>>,>>>,>>9" initial 0 label "Cliente" column-label "Cliente"
    field cod_espec_docto              as character format "x(3)" label "EspÇcie Documento" column-label "EspÇcie"
    field cod_ser_docto                as character format "x(3)" label "SÇrie Documento" column-label "SÇrie"
    field cod_tit_acr                  as character format "x(10)" label "T°tulo" column-label "T°tulo"
    field cod_parcela                  as character format "x(02)" label "Parcela" column-label "Parc"
    field val_titulo                   as decimal format "->>,>>>,>>>,>>9.99" decimals 2 label "Valor" column-label "Valor"
    field log_erro                     as logical format "Sim/N∆o" initial yes
    field des_erro                     as character format "x(50)" label "Inconsistància" column-label "Inconsistància"
    FIELD row_concil_acr_fat           AS ROWID
    .

def temp-table tt_cta_ctbl_concilia_acr no-undo
    field tta_cod_plano_cta_ctbl           as character format "x(8)" label "Plano Contas" column-label "Plano Contas"
    field tta_cod_cta_ctbl                 as character format "x(20)" label "Conta Cont†bil" column-label "Conta Cont†bil"
    field tta_des_cta_ctbl_ext             as character format "x(40)" label "Descriá∆o" column-label "Descriá∆o"
    .

def temp-table tt_empresa no-undo
    field tta_cod_empresa                  as character format "x(3)" label "Empresa" column-label "Empresa"
    index tt_id                           
          tta_cod_empresa                  ascending
    .

def temp-table tt_estabelecimento_empresa no-undo like estabelecimento
    field tta_cod_estab                    as character format "x(3)" label "Estabelecimento" column-label "Estab"
    field tta_nom_pessoa                   as character format "x(40)" label "Nome" column-label "Nome"
    field tta_cod_empresa                  as character format "x(3)" label "Empresa" column-label "Empresa"
    field tta_nom_razao_social             as character format "x(40)" label "Raz o Social" column-label "Raz o Social"
    field ttv_log_selec                    as logical format "Sim/n∆o" initial no column-label "Gera"
    index tt_cod_estab                     is primary unique
          tta_cod_estab                    ascending
    .

def temp-table tt_fat no-undo
    field ttv_cod_estab                    as character format "x(3)" label "Estabelecimento" column-label "Estabelecimento"
    field ttv_cdn_cliente                  as Integer format ">>>,>>>,>>9" initial 0 label "Cliente" column-label "Cliente"
    field ttv_cod_espec_docto              as character format "x(3)" label "EspÇcie Documento" column-label "EspÇcie"
    field ttv_cod_ser_docto                as character format "x(3)" label "SÇrie Docto" column-label "SÇrie"
    field ttv_cod_tit_acr                  as character format "x(10)" label "T°tulo" column-label "T°tulo"
    field ttv_cod_parcela                  as character format "x(02)" label "Parcela" column-label "Parc"
    field ttv_ind_origin_tit_acr           as character format "X(08)" label "Origem Tit Cta Rec" column-label "Origem Tit Cta Rec"
    field ttv_nom_natur                    as character format "x(30)" label "Natur. de Operaá∆o" column-label "Natur. de Operaá∆o"
    field ttv_val_orig                     as decimal format "->>,>>>,>>>,>>9.99" decimals 2
    field ttv_dat_emis_docto               as date format "99/99/9999" label "Data Emiss o" column-label "Dt Emiss o"
    field ttv_log_cancelado                as logical format "Sim/n∆o" initial no label "Cancelado" column-label "Cancelado"
    field ttv_cod_proces_export            as character format "x(12)" label "Processo Exportaá∆o" column-label "Processo Exportaá∆o"
    .

def temp-table tt_tit_acr_concilicao no-undo
    field tta_cod_estab                    as character format "x(3)" label "Estabelecimento" column-label "Estab"
    field tta_cdn_cliente                  as Integer format ">>>,>>>,>>9" initial 0 label "Cliente" column-label "Cliente"
    field tta_cod_espec_docto              as character format "x(3)" label "EspÇcie Documento" column-label "EspÇcie"
    field tta_cod_ser_docto                as character format "x(3)" label "SÇrie Documento" column-label "SÇrie"
    field tta_cod_tit_acr                  as character format "x(10)" label "T°tulo" column-label "T°tulo"
    field tta_cod_parcela                  as character format "x(02)" label "Parcela" column-label "Parc"
    field tta_val_original                 as decimal format "->>>>>,>>>,>>9.99" decimals 4 initial 0 label "Valor Original" column-label "Valor Original"
    field tta_dat_emis_docto               as date format "99/99/9999" initial today label "Data  Emiss o" column-label "Dt Emiss o"
    field tta_cod_estab_tit_acr            as character format "x(8)" label "Estab T°tulo ACR" column-label "Estab T°tulo ACR"
    .

def temp-table tt_usuar_grp_usuar no-undo like usuar_grp_usuar
    .



/********************** Temporary Table Definition End **********************/

/************************** Window Definition Begin *************************/

def var wh_w_program
    as widget-handle
    no-undo.

IF session:window-system <> "TTY" THEN
DO:
create window wh_w_program
    assign
         row                  = 01.00
         col                  = 01.00
         height-chars         = 01.00
         width-chars          = 01.00
         min-width-chars      = 01.00
         min-height-chars     = 01.00
         max-width-chars      = 01.00
         max-height-chars     = 01.00
         virtual-width-chars  = 350.00
         virtual-height-chars = 250.00
         title                = "Program"
&if '{&emsbas_version}' >= '5.06' &then
         resize               = no
&else
         resize               = yes
&endif
         scroll-bars          = no
         status-area          = yes
         status-area-font     = ?
         message-area         = no
         message-area-font    = ?
         fgcolor              = ?
         bgcolor              = ?.
END.




{include/i_fclwin.i wh_w_program }
/*************************** Window Definition End **************************/

/************************** Stream Definition Begin *************************/

def stream s_planilha.


/*************************** Stream Definition End **************************/

/************************* Variable Definition Begin ************************/

def new global shared var v_cod_aplicat_dtsul_corren
    as character
    format "x(3)":U
    no-undo.
def new shared var v_cod_arq_modul
    as character
    format "x(8)":U
    no-undo.
def new shared var v_cod_arq_planilha
    as character
    format "x(40)":U
    label "Arq Planilha"
    column-label "Arq Planilha"
    no-undo.
def new shared var v_cod_carac_lim
    as character
    format "x(1)":U
    initial ";"
    label "Caracter Delimitador"
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
def new global shared var v_cod_dwb_user
    as character
    format "x(21)":U
    label "Usuòrio"
    column-label "Usuòrio"
    no-undo.
def new global shared var v_cod_empres_usuar
    as character
    format "x(3)":U
    label "Empresa"
    column-label "Empresa"
    no-undo.
&IF "{&emsuni_version}" >= "" AND "{&emsuni_version}" < "5.07A" &THEN
def var v_cod_estab_fim
    as character
    format "x(3)":U
    initial "ZZZ"
    label "atÇ"
    column-label "Estab Final"
    no-undo.
&ENDIF
&IF "{&emsuni_version}" >= "5.07A" AND "{&emsuni_version}" < "9.99" &THEN
def var v_cod_estab_fim
    as Character
    format "x(5)":U
    initial "ZZZZZ"
    label "atÇ"
    column-label "Estab Final"
    no-undo.
&ENDIF
&IF "{&emsuni_version}" >= "" AND "{&emsuni_version}" < "5.07A" &THEN
def var v_cod_estab_inicial
    as character
    format "x(3)":U
    label "Estabelecimento"
    column-label "Estabelecimento"
    no-undo.
&ENDIF
&IF "{&emsuni_version}" >= "5.07A" AND "{&emsuni_version}" < "9.99" &THEN
def var v_cod_estab_inicial
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
    label "Finalidade Econ”mica"
    column-label "Finalidade Econ”mica"
    no-undo.
def new global shared var v_cod_funcao_negoc_empres
    as character
    format "x(50)":U
    no-undo.
def new global shared var v_cod_grp_usuar_lst
    as character
    format "x(3)":U
    label "Grupo Usuòrios"
    column-label "Grupo"
    no-undo.
def new global shared var v_cod_idiom_usuar
    as character
    format "x(8)":U
    label "Idioma"
    column-label "Idioma"
    no-undo.
def var v_cod_lista
    as character
    format "x(8)":U
    label "Idioma"
    no-undo.
def var v_cod_matriz_trad_org_ext
    as character
    format "x(8)":U
    label "Matriz UO"
    column-label "Matriz UO"
    no-undo.
def new global shared var v_cod_modul_dtsul_corren
    as character
    format "x(3)":U
    label "M´dulo Corrente"
    column-label "M´dulo Corrente"
    no-undo.
def new global shared var v_cod_modul_dtsul_empres
    as character
    format "x(100)":U
    no-undo.
def new global shared var v_cod_pais_empres_usuar
    as character
    format "x(3)":U
    label "Pas Empresa Usuòrio"
    column-label "Pas"
    no-undo.
def new global shared var v_cod_plano_ccusto_corren
    as character
    format "x(8)":U
    label "Plano CCusto"
    column-label "Plano CCusto"
    no-undo.
def new global shared var v_cod_unid_negoc_usuar
    as character
    format "x(3)":U
    view-as combo-box
    list-items ""
    inner-lines 5
    bgcolor 15 font 2
    label "Unidade Neg´cio"
    column-label "Unid Neg´cio"
    no-undo.
&IF "{&emsuni_version}" >= "" AND "{&emsuni_version}" < "5.07A" &THEN
def var v_cod_unid_organ
    as character
    format "x(3)":U
    label "Unid Organizacional"
    column-label "Unid Organizacional"
    no-undo.
&ENDIF
&IF "{&emsuni_version}" >= "5.07A" AND "{&emsuni_version}" < "9.99" &THEN
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
    label "Usuòrio Corrente"
    column-label "Usuòrio Corrente"
    no-undo.
def new global shared var v_cod_usuar_corren_criptog
    as character
    format "x(16)":U
    no-undo.
def var v_dat_aux
    as date
    format "99/99/9999":U
    no-undo.
def var v_dat_fim
    as date
    format "99/99/9999":U
    initial 12/31/9999
    label "atÇ"
    column-label "Final"
    no-undo.
def var v_dat_inicial
    as date
    format "99/99/9999":U
    label "Data Inicial"
    no-undo.
def var v_des_erro_3
    as character
    format "x(2000)":U
    view-as editor max-chars 2000 scrollbar-vertical
    size 89 by 3
    bgcolor 15 font 2
    label "Inconsist¨ncia"
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
def var v_hdl_prog_ems2
    as Handle
    format ">>>>>>9":U
    no-undo.
def new shared var v_ind_run_mode
    as character
    format "X(08)":U
    initial "On-Line" /*l_online*/
    no-undo.
def var v_log_connect
    as logical
    format "Sim/n∆o"
    initial no
    no-undo.
def var v_log_connect_ems2_ok
    as logical
    format "Sim/n∆o"
    initial no
    no-undo.
def var v_log_cta_transit
    as logical
    format "Sim/n∆o"
    initial no
    no-undo.
def var v_log_erro
    as logical
    format "Sim/n∆o"
    initial yes
    no-undo.
def var v_log_erro_tela
    as logical
    format "Sim/n∆o"
    initial yes
    no-undo.
def new global shared var v_log_gerac_planilha
    as logical
    format "Sim/n∆o"
    initial no
    view-as toggle-box
    label "Gera Planilha"
    no-undo.
def var v_log_method
    as logical
    format "Sim/n∆o"
    initial yes
    no-undo.
def var v_log_mostra_erro
    as logical
    format "Sim/n∆o"
    initial no
    no-undo.
def var v_log_return_epc
    as logical
    format "Sim/n∆o"
    initial no
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
def var v_nom_prog_upc
    as character
    format "X(50)":U
    label "Programa UPC"
    column-label "Programa UPC"
    no-undo.
def var v_nom_table_epc
    as character
    format "x(30)":U
    no-undo.
def var v_nom_title_aux
    as character
    format "x(60)":U
    no-undo.
def var v_num_cont_aux
    as integer
    format ">9":U
    no-undo.
def var v_num_nota_concil_faturam
    as integer
    format ">>>,>>>,>>9":U
    label "Total FAT"
    no-undo.
def var v_num_nota_concil_faturam_aux
    as integer
    format ">>>,>>>,>>9":U
    label "Total FAT"
    no-undo.
def new global shared var v_num_ped_exec_corren
    as integer
    format ">>>>9":U
    no-undo.
def var v_num_tit_acr_concil
    as integer
    format ">>>,>>>,>>9":U
    label "Total ACR"
    no-undo.
def var v_num_tot_dif_concil_faturam
    as integer
    format ">>>,>>>,>>9":U
    label "Total Dif ACR x FAT"
    no-undo.
def new global shared var v_rec_cta_ctbl
    as recid
    format ">>>>>>9":U
    no-undo.
def new shared var v_rec_estabelecimento
    as recid
    format ">>>>>>9":U
    no-undo.
def var v_rec_log
    as recid
    format ">>>>>>9":U
    no-undo.
def new global shared var v_rec_plano_cta_ctbl
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
def var v_Val_dif_concil_acr_faturam
    as decimal
    format "->>,>>>,>>>,>>9.99":U
    decimals 2
    label "Dif ACR x FAT"
    no-undo.
def var v_val_tit_acr_concil
    as decimal
    format "->>,>>>,>>>,>>9.99":U
    decimals 2
    label "Total ACR"
    no-undo.
def var v_val_tot_nota_concil_faturam
    as decimal
    format "->>,>>>,>>>,>>9.99":U
    decimals 2
    label "Total FAT"
    no-undo.
def var v_wgh_focus
    as widget-handle
    format ">>>>>>9":U
    no-undo.
def var v_wgh_frame_epc
    as widget-handle
    format ">>>>>>9":U
    no-undo.
def var v_num_cont                       as integer         no-undo. /*local*/
def var v_num_lin                        as integer         no-undo. /*local*/
def var v_num_row_a                      as integer         no-undo. /*local*/
def var v_num_select_row                 as integer         no-undo. /*local*/


&if '{&emsbas_version}' >= '5.06' &then
def temp-table tt_maximizacao no-undo
    field hdl-widget             as widget-handle
    field tipo-widget            as character 
    field row-original           as decimal
    field col-original           as decimal
    field width-original         as decimal
    field height-original        as decimal
    field log-posiciona-row      as logical
    field log-posiciona-col      as logical
    field log-calcula-width      as logical
    field log-calcula-height     as logical
    field log-button-right       as logical
    field frame-width-original   as decimal
    field frame-height-original  as decimal
    field window-width-original  as decimal
    field window-height-original as decimal.
&endif
/************************** Variable Definition End *************************/

/*************************** Menu Definition Begin **************************/


def sub-menu  mi_table
    menu-item mi_exi               label "Sair".

def sub-menu  mi_hel
    menu-item mi_contents          label "Conteﬂdo"
    RULE
    menu-item mi_about             label "Sobre".

def menu      m_10                  menubar
    sub-menu  mi_table              label "Tabela"
    sub-menu  mi_hel                label "Ajuda".

.

def menu      m_detalhe             menubar
    menu-item mi_detalhe_titulo     label "Detalhe T°tulo"
    menu-item mi_detalhe_nota       label "Detalhe Nota".



/**************************** Menu Definition End ***************************/

/************************** Query Definition Begin **************************/

def query qr_concil_acr_fat
    for tt_concil_acr_fat
    scrolling.
def query qr_tt_cta_ctbl_concilia_acr
    for tt_cta_ctbl_concilia_acr
    scrolling.

DEF QUERY qr_tt_concil_tit_agrupa
    FOR tt_concil_tit_agrupa
    SCROLLING.


/*************************** Query Definition End ***************************/

/************************** Browse Definition Begin *************************/

def browse br_concil_acr_fat query qr_concil_acr_fat display 
&IF "{&emsuni_version}" >= "" AND "{&emsuni_version}" < "5.07A" &THEN
    tt_concil_acr_fat.tta_cod_estab
    width-chars 03.00
        column-label "Est"
&ENDIF
&IF "{&emsuni_version}" >= "5.07A" AND "{&emsuni_version}" < "9.99" &THEN
    tt_concil_acr_fat.tta_cod_estab
    width-chars 03.00
        column-label "Est"
&ENDIF
    tt_concil_acr_fat.tta_cod_espec_docto
    width-chars 03.00
        column-label "Esp"
    tt_concil_acr_fat.tta_cod_ser_docto
    width-chars 03.00
        column-label "Ser"
    tt_concil_acr_fat.tta_cod_tit_acr
&if defined(BF_FIN_AUMENTO_DIGITO_NF) &then
    format "x(16)"
    width-chars 16.00
&else
    format "x(10)"
    width-chars 10.00
&endif
 column-label "T°tulo"
    tt_concil_acr_fat.tta_cod_parcela
    width-chars 02.00
        column-label "/P"
    tt_concil_acr_fat.ttv_val_acr
    width-chars 14.00
        column-label "Valor ACR"
    tt_concil_acr_fat.ttv_val_faturam
    width-chars 14.00
        column-label "Valor FAT"
    tt_concil_acr_fat.ttv_val_dif_acr_faturam
    width-chars 14.00
        column-label "Valor Diferenáa"
    with separators single 
         size 89.00 by 10.46
         font 1
         bgcolor 15
         title "Conciliaá∆o Operacional ACR x FAT".
def browse br_tt_cta_ctbl_concilia_acr query qr_tt_cta_ctbl_concilia_acr display 
    tt_cta_ctbl_concilia_acr.tta_cod_plano_cta_ctbl
    width-chars 08.00
        column-label "Plano Ctas"
    tt_cta_ctbl_concilia_acr.tta_cod_cta_ctbl
    width-chars 20.00
        column-label "Conta Cont†bil"
    tt_cta_ctbl_concilia_acr.tta_des_cta_ctbl_ext
    width-chars 40.00
        column-label "Descriá∆o"
    with separators multiple 
         size 74.00 by 06.29
         font 1
         bgcolor 15
         title "Conta EMS5".

DEFINE BROWSE br_concil_tit_agrupa QUERY qr_tt_concil_tit_agrupa DISPLAY
    tt_concil_tit_agrupa.cod_estab
    width-chars 03.00
        column-label "Est"
    tt_concil_tit_agrupa.cod_espec_docto
    width-chars 03.00
        column-label "Esp"
    tt_concil_tit_agrupa.cod_ser_docto
    width-chars 03.00
        column-label "Ser"
    tt_concil_tit_agrupa.cod_tit_acr
    format "x(16)"
        width-chars 16.00
    tt_concil_tit_agrupa.cod_parcela
    width-chars 02.00
        column-label "/P"
    tt_concil_tit_agrupa.cdn_cliente
    tt_concil_tit_agrupa.val_titulo
    with separators multiple 
         size 89.00 by 9
         font 1
         bgcolor 15
         title "Detalhamento - Agrupamento Cupom Fiscal".



/*************************** Browse Definition End **************************/

/************************ Rectangle Definition Begin ************************/

def rectangle rt_002
    size 1 by 1
    edge-pixels 2.
def rectangle rt_003
    size 1 by 1
    edge-pixels 2.
def rectangle rt_cxcf
    size 1 by 1
    fgcolor 1 edge-pixels 2.
def rectangle rt_mold
    size 1 by 1
    edge-pixels 2.
def rectangle rt_rgf
    size 1 by 1
    edge-pixels 2.


/************************* Rectangle Definition End *************************/

/************************** Button Definition Begin *************************/

def button bt_atz
    label "Atualiza"
    tooltip "Atualiza"
&if "{&window-system}" <> "TTY" &then
    image-up file "image/im-tick.bmp"
    image-insensitive file "image/ii-tic-i.bmp"
&endif
    size 1 by 1.
def button bt_can
    label "Cancela"
    tooltip "Cancela"
    size 1 by 1
    auto-endkey.
def button bt_des_todos_bord
    label "Desmarca Tudo"
    tooltip ""
&if "{&window-system}" <> "TTY" &then
    image file "image/im-ran_n.bmp"
&endif
    size 1 by 1.
def button bt_elimina_linhas
    label "Elimina Linha Selecionada"
    tooltip "Elimina Linha Selecionada"
&if "{&window-system}" <> "TTY" &then
    image file "image/im-era1"
&endif
    size 1 by 1.
def button bt_enter
    label "Entra"
    tooltip "Entra"
&if "{&window-system}" <> "TTY" &then
    image-up file "image/im-enter"
    image-insensitive file "image/ii-enter"
&endif
    size 1 by 1.
def button bt_exi
    label "Sada"
    tooltip "Sada"
&if "{&window-system}" <> "TTY" &then
    image-up file "image/im-exi"
    image-insensitive file "image/ii-exi"
&endif
    size 1 by 1.
def button bt_fil2
    label "Fil"
    tooltip "Filtro"
&if "{&window-system}" <> "TTY" &then
    image-up file "image/im-fil"
    image-insensitive file "image/ii-fil"
&endif
    size 1 by 1.
def button bt_hel1
    label " ?"
    tooltip "Ajuda"
&if "{&window-system}" <> "TTY" &then
    image-up file "image/im-hel"
    image-insensitive file "image/ii-hel"
&endif
    size 1 by 1.
def button bt_hel2
    label "Ajuda"
    tooltip "Ajuda"
    size 1 by 1.
def button bt_nao_pula_linha
    label "n∆o Pula Linha"
    tooltip "n∆o Pula Linha"
&if "{&window-system}" <> "TTY" &then
    image file "image/im-npula.bmp"
&endif
    size 1 by 1.
def button bt_ok
    label "OK"
    tooltip "OK"
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
def button bt_todos_img
    label "Todos"
    tooltip "Seleciona Todos"
&if "{&window-system}" <> "TTY" &then
    image file "image/im-ran_a.bmp"
&endif
    size 1 by 1.
def button bt_tot
    label "Tot"
    tooltip "Totais"
&if "{&window-system}" <> "TTY" &then
    image-up file "image/im-total"
    image-insensitive file "image/ii-total"
&endif
    size 1 by 1.
def button bt_zoo
    label "Zoom"
    tooltip "Zoom"
&if "{&window-system}" <> "TTY" &then
    image-up file "image/im-zoo"
    image-insensitive file "image/ii-zoo"
&endif
    size 1 by 1.
/****************************** Function Button *****************************/
def button bt_zoo_376196
    label "Zoom"
    tooltip "Zoom"
&if "{&window-system}" <> "TTY" &then
    image-up file "image/im-zoo"
    image-insensitive file "image/ii-zoo"
&endif
    size 4 by .88.


/*************************** Button Definition End **************************/

/************************** Frame Definition Begin **************************/

def frame f_bas_10_concilia_acr_fat
    rt_rgf
         at row 01.00 col 01.00 bgcolor 7 
    rt_mold
         at row 02.50 col 01.29
    bt_fil2
         at row 01.13 col 01.57 font ?
         help "Filtro"
    bt_ran2
         at row 01.13 col 05.43 font ?
         help "Faixa"
    bt_atz
         at row 01.13 col 12.14 font ?
         help "Atualiza"
    bt_tot
         at row 01.13 col 18.72 font ?
         help "Totais"
    bt_nao_pula_linha
         at row 01.13 col 22.57 font ?
         help "n∆o Pula Linha"
    bt_exi
         at row 01.08 col 82.57 font ?
         help "Sada"
    bt_hel1
         at row 01.08 col 86.57 font ?
         help "Ajuda"
    br_concil_acr_fat
         at row 02.33 col 01.00
    v_des_erro_3
         at row 13.00 col 01.29 no-label
         help "Inconsistàncias Encontradas"
         view-as editor max-chars 2000 scrollbar-vertical
         size 89 by 3
         bgcolor 15 font 2
    br_concil_tit_agrupa
         at row 16.00 col 01.00
    with 1 down side-labels no-validate keep-tab-order three-d
         size-char 90 by 25.00
         at row 02.00 col 01.00
         font 1 fgcolor ? bgcolor 8
         title "Conciliaá∆o Operacional ACR x FAT".
    /* adjust size of objects in this frame */
    assign bt_atz:width-chars             in frame f_bas_10_concilia_acr_fat = 04.00
           bt_atz:height-chars            in frame f_bas_10_concilia_acr_fat = 01.13
           bt_exi:width-chars             in frame f_bas_10_concilia_acr_fat = 04.00
           bt_exi:height-chars            in frame f_bas_10_concilia_acr_fat = 01.13
           bt_fil2:width-chars            in frame f_bas_10_concilia_acr_fat = 04.00
           bt_fil2:height-chars           in frame f_bas_10_concilia_acr_fat = 01.13
           bt_hel1:width-chars            in frame f_bas_10_concilia_acr_fat = 04.00
           bt_hel1:height-chars           in frame f_bas_10_concilia_acr_fat = 01.13
           bt_nao_pula_linha:width-chars  in frame f_bas_10_concilia_acr_fat = 04.00
           bt_nao_pula_linha:height-chars in frame f_bas_10_concilia_acr_fat = 01.13
           bt_ran2:width-chars            in frame f_bas_10_concilia_acr_fat = 04.00
           bt_ran2:height-chars           in frame f_bas_10_concilia_acr_fat = 01.13
           bt_tot:width-chars             in frame f_bas_10_concilia_acr_fat = 04.00
           bt_tot:height-chars            in frame f_bas_10_concilia_acr_fat = 01.13
           rt_mold:width-chars            in frame f_bas_10_concilia_acr_fat = 04.29
           rt_mold:height-chars           in frame f_bas_10_concilia_acr_fat = 01.25
           rt_rgf:width-chars             in frame f_bas_10_concilia_acr_fat = 89.72
           rt_rgf:height-chars            in frame f_bas_10_concilia_acr_fat = 01.29.
&if '{&emsbas_version}' >= '5.06' &then
if OPSYS = 'WIN32':U then do:
assign br_concil_acr_fat:ALLOW-COLUMN-SEARCHING in frame f_bas_10_concilia_acr_fat = no
       br_concil_acr_fat:COLUMN-MOVABLE in frame f_bas_10_concilia_acr_fat = no.
end.
&endif
    /* set return-inserted = yes for editors */
    assign v_des_erro_3:return-inserted in frame f_bas_10_concilia_acr_fat = yes.
    /* set private-data for the help system */
    assign bt_fil2:private-data           in frame f_bas_10_concilia_acr_fat = "HLP=000008766":U
           bt_ran2:private-data           in frame f_bas_10_concilia_acr_fat = "HLP=000008773":U
           bt_atz:private-data            in frame f_bas_10_concilia_acr_fat = "HLP=000021479":U
           bt_tot:private-data            in frame f_bas_10_concilia_acr_fat = "HLP=000010220":U
           bt_nao_pula_linha:private-data in frame f_bas_10_concilia_acr_fat = "HLP=000024021":U
           bt_exi:private-data            in frame f_bas_10_concilia_acr_fat = "HLP=000004665":U
           bt_hel1:private-data           in frame f_bas_10_concilia_acr_fat = "HLP=000004666":U
           br_concil_acr_fat:private-data in frame f_bas_10_concilia_acr_fat = "HLP=000000000":U
           v_des_erro_3:private-data      in frame f_bas_10_concilia_acr_fat = "HLP=000000000":U
           frame f_bas_10_concilia_acr_fat:private-data                      = "HLP=000000000".

def frame f_dlg_03_concilia_acr_fat_totais
    rt_002
         at row 01.42 col 02.00
    " T°tulos/Notas " view-as text
         at row 01.12 col 04.00 bgcolor 8 
    rt_003
         at row 01.46 col 28.43
    " Valores " view-as text
         at row 01.16 col 30.43 bgcolor 8 
    rt_cxcf
         at row 06.53 col 02.00 bgcolor 7 
    v_num_tit_acr_concil
         at row 02.00 col 12.86 colon-aligned label "Total ACR"
         help "Total de T°tulos do ACR"
         view-as fill-in
         size-chars 12.14 by .88
         fgcolor ? bgcolor 15 font 2
    v_val_tit_acr_concil
         at row 02.00 col 39.43 colon-aligned label "Total ACR"
         help "Valor Total ACR"
         view-as fill-in
         size-chars 19.14 by .88
         fgcolor ? bgcolor 15 font 2
    v_num_nota_concil_faturam
         at row 03.08 col 12.86 colon-aligned label "Total FAT"
         help "Total de Notas do Faturamento"
         view-as fill-in
         size-chars 12.14 by .88
         fgcolor ? bgcolor 15 font 2
    v_val_tot_nota_concil_faturam
         at row 03.08 col 39.43 colon-aligned label "Total FAT"
         help "Valor Total do Faturamento"
         view-as fill-in
         size-chars 19.14 by .88
         fgcolor ? bgcolor 15 font 2
    v_num_tot_dif_concil_faturam
         at row 04.50 col 12.86 colon-aligned label "Dif ACRxFAT"
         help "Diferenáa Total entre T°tulos e Notas"
         view-as fill-in
         size-chars 12.14 by .88
         fgcolor ? bgcolor 15 font 2
    v_val_dif_concil_acr_faturam
         at row 04.50 col 39.57 colon-aligned label "Dif ACRxFAT"
         help "Diferenáa de Valor na Conciliaá∆o ACR x FAT"
         view-as fill-in
         size-chars 19.14 by .88
         fgcolor ? bgcolor 15 font 2
    bt_ok
         at row 06.75 col 03.00 font ?
         help "OK"
    bt_can
         at row 06.75 col 14.00 font ?
         help "Cancela"
    bt_hel2
         at row 06.75 col 50.42 font ?
         help "Ajuda"
    with 1 down side-labels no-validate keep-tab-order three-d
         size-char 62.86 by 08.46 default-button bt_ok
         view-as dialog-box
         font 1 fgcolor ? bgcolor 8
         title "Total de Conciliaá∆o".
    /* adjust size of objects in this frame */
    assign bt_can:width-chars   in frame f_dlg_03_concilia_acr_fat_totais = 10.00
           bt_can:height-chars  in frame f_dlg_03_concilia_acr_fat_totais = 01.00
           bt_hel2:width-chars  in frame f_dlg_03_concilia_acr_fat_totais = 10.00
           bt_hel2:height-chars in frame f_dlg_03_concilia_acr_fat_totais = 01.00
           bt_ok:width-chars    in frame f_dlg_03_concilia_acr_fat_totais = 10.00
           bt_ok:height-chars   in frame f_dlg_03_concilia_acr_fat_totais = 01.00
           rt_002:width-chars   in frame f_dlg_03_concilia_acr_fat_totais = 25.86
           rt_002:height-chars  in frame f_dlg_03_concilia_acr_fat_totais = 04.83
           rt_003:width-chars   in frame f_dlg_03_concilia_acr_fat_totais = 33.14
           rt_003:height-chars  in frame f_dlg_03_concilia_acr_fat_totais = 04.75
           rt_cxcf:width-chars  in frame f_dlg_03_concilia_acr_fat_totais = 59.42
           rt_cxcf:height-chars in frame f_dlg_03_concilia_acr_fat_totais = 01.40.
    /* set private-data for the help system */
    assign v_num_tit_acr_concil:private-data          in frame f_dlg_03_concilia_acr_fat_totais = "HLP=000000000":U
           v_val_tit_acr_concil:private-data          in frame f_dlg_03_concilia_acr_fat_totais = "HLP=000000000":U
           v_num_nota_concil_faturam:private-data     in frame f_dlg_03_concilia_acr_fat_totais = "HLP=000000000":U
           v_val_tot_nota_concil_faturam:private-data in frame f_dlg_03_concilia_acr_fat_totais = "HLP=000000000":U
           v_num_tot_dif_concil_faturam:private-data  in frame f_dlg_03_concilia_acr_fat_totais = "HLP=000000000":U
           v_val_dif_concil_acr_faturam:private-data  in frame f_dlg_03_concilia_acr_fat_totais = "HLP=000000000":U
           bt_ok:private-data                         in frame f_dlg_03_concilia_acr_fat_totais = "HLP=000010721":U
           bt_can:private-data                        in frame f_dlg_03_concilia_acr_fat_totais = "HLP=000011050":U
           bt_hel2:private-data                       in frame f_dlg_03_concilia_acr_fat_totais = "HLP=000011326":U
           frame f_dlg_03_concilia_acr_fat_totais:private-data                                  = "HLP=000000000".

def frame f_fil_01_concilia_acr_fat
    rt_cxcf
         at row 07.58 col 02.00 bgcolor 7 
&IF "{&emsuni_version}" >= "" AND "{&emsuni_version}" < "5.07A" &THEN
    v_cod_unid_organ
         at row 02.00 col 16.00 colon-aligned label "Unid Organizacional"
         help "C´digo Unidade Organizacional"
         view-as fill-in
         size-chars 4.14 by .88
         fgcolor ? bgcolor 15 font 2
&ENDIF
&IF "{&emsuni_version}" >= "5.07A" AND "{&emsuni_version}" < "9.99" &THEN
    v_cod_unid_organ
         at row 02.00 col 16.00 colon-aligned label "Unid Organizacional"
         help "C´digo Unidade Organizacional"
         view-as fill-in
         size-chars 6.14 by .88
         fgcolor ? bgcolor 15 font 2
&ENDIF
    v_cod_matriz_trad_org_ext
         at row 03.00 col 16.00 colon-aligned label "Matriz UO"
         help "Matriz de OrganizaØ¥es Externas"
         view-as fill-in
         size-chars 9.14 by .88
         fgcolor ? bgcolor 15 font 2
    plano_cta_ctbl.cod_plano_cta_ctbl
         at row 04.00 col 16.00 colon-aligned label "Plano Contas"
         view-as fill-in
         size-chars 9.14 by .88
         fgcolor ? bgcolor 15 font 2
    bt_zoo_376196
         at row 04.00 col 27.14
    v_dat_inicial
         at row 05.00 col 16.00 colon-aligned label "Data"
         view-as fill-in
         size-chars 11.14 by .88
         fgcolor ? bgcolor 15 font 2
    v_dat_fim
         at row 05.00 col 32.00 colon-aligned label "atÇ"
         help "Data Final"
         view-as fill-in
         size-chars 11.14 by .88
         fgcolor ? bgcolor 15 font 2
    v_des_estab_select
         at row 06.00 col 16.00 colon-aligned label "Selecionados"
         help "Estabelecimentos selecionados"
         view-as editor max-chars 2000 no-word-wrap
         size 30 by 1
         bgcolor 15 font 2
&IF "{&emsuni_version}" >= "" AND "{&emsuni_version}" < "5.07A" &THEN
    v_cod_estab_inicial
         at row 06.00 col 16.00 colon-aligned label "Estabelec"
         help "C´digo Estabelecimento Inicial"
         view-as fill-in
         size-chars 4.14 by .88
         fgcolor ? bgcolor 15 font 2
&ENDIF
&IF "{&emsuni_version}" >= "5.07A" AND "{&emsuni_version}" < "9.99" &THEN
    v_cod_estab_inicial
         at row 06.00 col 16.00 colon-aligned label "Estabelec"
         help "C´digo Estabelecimento Inicial"
         view-as fill-in
         size-chars 6.14 by .88
         fgcolor ? bgcolor 15 font 2
&ENDIF
&IF "{&emsuni_version}" >= "" AND "{&emsuni_version}" < "5.07A" &THEN
    v_cod_estab_fim
         at row 06.00 col 32.00 colon-aligned label "atÇ"
         help "C´digo Estabelecimento Final"
         view-as fill-in
         size-chars 4.14 by .88
         fgcolor ? bgcolor 15 font 2
&ENDIF
&IF "{&emsuni_version}" >= "5.07A" AND "{&emsuni_version}" < "9.99" &THEN
    v_cod_estab_fim
         at row 06.00 col 32.00 colon-aligned label "atÇ"
         help "C´digo Estabelecimento Final"
         view-as fill-in
         size-chars 6.14 by .88
         fgcolor ? bgcolor 15 font 2
&ENDIF
    bt_todos_img
         at row 06.00 col 48.00 font ?
         help "Seleciona Todos"
    bt_ok
         at row 07.79 col 03.00 font ?
         help "OK"
    bt_can
         at row 07.79 col 14.00 font ?
         help "Cancela"
    bt_hel2
         at row 07.79 col 41.86 font ?
         help "Ajuda"
    with 1 down side-labels no-validate keep-tab-order three-d
         size-char 54.29 by 09.42 default-button bt_ok
         view-as dialog-box
         font 1 fgcolor ? bgcolor 8
         title "Filtro".
    /* adjust size of objects in this frame */
    assign bt_can:width-chars        in frame f_fil_01_concilia_acr_fat = 10.00
           bt_can:height-chars       in frame f_fil_01_concilia_acr_fat = 01.00
           bt_hel2:width-chars       in frame f_fil_01_concilia_acr_fat = 10.00
           bt_hel2:height-chars      in frame f_fil_01_concilia_acr_fat = 01.00
           bt_ok:width-chars         in frame f_fil_01_concilia_acr_fat = 10.00
           bt_ok:height-chars        in frame f_fil_01_concilia_acr_fat = 01.00
           bt_todos_img:width-chars  in frame f_fil_01_concilia_acr_fat = 04.00
           bt_todos_img:height-chars in frame f_fil_01_concilia_acr_fat = 01.13
           rt_cxcf:width-chars       in frame f_fil_01_concilia_acr_fat = 50.86
           rt_cxcf:height-chars      in frame f_fil_01_concilia_acr_fat = 01.42.
    /* set return-inserted = yes for editors */
    assign v_des_estab_select:return-inserted in frame f_fil_01_concilia_acr_fat = yes.
    /* set private-data for the help system */
    assign v_cod_unid_organ:private-data                  in frame f_fil_01_concilia_acr_fat = "HLP=000024181":U
           v_cod_matriz_trad_org_ext:private-data         in frame f_fil_01_concilia_acr_fat = "HLP=000019013":U
           bt_zoo_376196:private-data                     in frame f_fil_01_concilia_acr_fat = "HLP=000009431":U
           plano_cta_ctbl.cod_plano_cta_ctbl:private-data in frame f_fil_01_concilia_acr_fat = "HLP=000011125":U
           v_dat_inicial:private-data                     in frame f_fil_01_concilia_acr_fat = "HLP=000000000":U
           v_dat_fim:private-data                         in frame f_fil_01_concilia_acr_fat = "HLP=000018542":U
           v_des_estab_select:private-data                in frame f_fil_01_concilia_acr_fat = "HLP=000000000":U
           v_cod_estab_inicial:private-data               in frame f_fil_01_concilia_acr_fat = "HLP=000019263":U
           v_cod_estab_fim:private-data                   in frame f_fil_01_concilia_acr_fat = "HLP=000016634":U
           bt_todos_img:private-data                      in frame f_fil_01_concilia_acr_fat = "HLP=000021504":U
           bt_ok:private-data                             in frame f_fil_01_concilia_acr_fat = "HLP=000010721":U
           bt_can:private-data                            in frame f_fil_01_concilia_acr_fat = "HLP=000011050":U
           bt_hel2:private-data                           in frame f_fil_01_concilia_acr_fat = "HLP=000011326":U
           frame f_fil_01_concilia_acr_fat:private-data                                      = "HLP=000000000".
    /* enable function buttons */
    assign bt_zoo_376196:sensitive in frame f_fil_01_concilia_acr_fat = yes.
    /* move buttons to top */
    bt_zoo_376196:move-to-top().

def frame f_ran_01_concilia_acr_fat
    rt_mold
         at row 01.21 col 02.00
    rt_cxcf
         at row 09.79 col 02.00 bgcolor 7 
    cta_ctbl.cod_cta_ctbl
         at row 02.00 col 14.57 colon-aligned label "Conta Cont†bil"
         view-as fill-in
         size-chars 21.14 by .88
         fgcolor ? bgcolor 15 font 2
    bt_zoo
         at row 02.00 col 37.57 font ?
         help "Zoom"
    bt_enter
         at row 02.00 col 41.57 font ?
         help "Entra"
    br_tt_cta_ctbl_concilia_acr
         at row 03.00 col 03.00
    bt_todos_img
         at row 04.00 col 78.00 font ?
         help "Seleciona Todos"
    bt_des_todos_bord
         at row 05.08 col 78.00 font ?
    bt_elimina_linhas
         at row 06.21 col 78.00 font ?
         help "Elimina Linha Selecionada"
    bt_ok
         at row 10.00 col 03.00 font ?
         help "OK"
    bt_can
         at row 10.00 col 14.00 font ?
         help "Cancela"
    bt_hel2
         at row 10.00 col 71.72 font ?
         help "Ajuda"
    with 1 down side-labels no-validate keep-tab-order three-d
         size-char 84.14 by 11.63 default-button bt_ok
         view-as dialog-box
         font 1 fgcolor ? bgcolor 8
         title "Faixa".
    /* adjust size of objects in this frame */
    assign bt_can:width-chars             in frame f_ran_01_concilia_acr_fat = 10.00
           bt_can:height-chars            in frame f_ran_01_concilia_acr_fat = 01.00
           bt_des_todos_bord:width-chars  in frame f_ran_01_concilia_acr_fat = 04.00
           bt_des_todos_bord:height-chars in frame f_ran_01_concilia_acr_fat = 01.13
           bt_elimina_linhas:width-chars  in frame f_ran_01_concilia_acr_fat = 04.00
           bt_elimina_linhas:height-chars in frame f_ran_01_concilia_acr_fat = 01.13
           bt_enter:width-chars           in frame f_ran_01_concilia_acr_fat = 04.00
           bt_enter:height-chars          in frame f_ran_01_concilia_acr_fat = 00.88
           bt_hel2:width-chars            in frame f_ran_01_concilia_acr_fat = 10.00
           bt_hel2:height-chars           in frame f_ran_01_concilia_acr_fat = 01.00
           bt_ok:width-chars              in frame f_ran_01_concilia_acr_fat = 10.00
           bt_ok:height-chars             in frame f_ran_01_concilia_acr_fat = 01.00
           bt_todos_img:width-chars       in frame f_ran_01_concilia_acr_fat = 04.00
           bt_todos_img:height-chars      in frame f_ran_01_concilia_acr_fat = 01.13
           bt_zoo:width-chars             in frame f_ran_01_concilia_acr_fat = 04.00
           bt_zoo:height-chars            in frame f_ran_01_concilia_acr_fat = 00.88
           rt_cxcf:width-chars            in frame f_ran_01_concilia_acr_fat = 80.72
           rt_cxcf:height-chars           in frame f_ran_01_concilia_acr_fat = 01.42
           rt_mold:width-chars            in frame f_ran_01_concilia_acr_fat = 80.72
           rt_mold:height-chars           in frame f_ran_01_concilia_acr_fat = 08.29.
&if '{&emsbas_version}' >= '5.06' &then
if OPSYS = 'WIN32':U then do:
assign br_tt_cta_ctbl_concilia_acr:ALLOW-COLUMN-SEARCHING in frame f_ran_01_concilia_acr_fat = no
       br_tt_cta_ctbl_concilia_acr:COLUMN-MOVABLE in frame f_ran_01_concilia_acr_fat = no.
end.
&endif
    /* set private-data for the help system */
    assign cta_ctbl.cod_cta_ctbl:private-data       in frame f_ran_01_concilia_acr_fat = "HLP=000011308":U
           bt_zoo:private-data                      in frame f_ran_01_concilia_acr_fat = "HLP=000009431":U
           bt_enter:private-data                    in frame f_ran_01_concilia_acr_fat = "HLP=000000000":U
           br_tt_cta_ctbl_concilia_acr:private-data in frame f_ran_01_concilia_acr_fat = "HLP=000000000":U
           bt_todos_img:private-data                in frame f_ran_01_concilia_acr_fat = "HLP=000021504":U
           bt_des_todos_bord:private-data           in frame f_ran_01_concilia_acr_fat = "HLP=000000000":U
           bt_elimina_linhas:private-data           in frame f_ran_01_concilia_acr_fat = "HLP=000000000":U
           bt_ok:private-data                       in frame f_ran_01_concilia_acr_fat = "HLP=000010721":U
           bt_can:private-data                      in frame f_ran_01_concilia_acr_fat = "HLP=000011050":U
           bt_hel2:private-data                     in frame f_ran_01_concilia_acr_fat = "HLP=000011326":U
           frame f_ran_01_concilia_acr_fat:private-data                                = "HLP=000000000".



{include/i_fclfrm.i f_bas_10_concilia_acr_fat f_dlg_03_concilia_acr_fat_totais f_fil_01_concilia_acr_fat f_ran_01_concilia_acr_fat }
/*************************** Frame Definition End ***************************/
&if '{&emsbas_version}' >= '5.06' &then
ON WINDOW-MAXIMIZED OF wh_w_program
DO:
def var v_whd_widget as widget-handle no-undo.
assign frame f_bas_10_concilia_acr_fat:width-chars  = wh_w_program:width-chars
       frame f_bas_10_concilia_acr_fat:height-chars = wh_w_program:height-chars no-error.

for each tt_maximizacao:
    assign v_whd_widget = tt_maximizacao.hdl-widget.

    if tt_maximizacao.log-posiciona-row = yes then do:
        assign v_whd_widget:row = wh_w_program:height - (tt_maximizacao.window-height-original - tt_maximizacao.row-original).
    end.
    if tt_maximizacao.log-calcula-width = yes then do:
        assign v_whd_widget:width = wh_w_program:width - ( tt_maximizacao.window-width-original - tt_maximizacao.width-original ).
    end.
    if tt_maximizacao.log-calcula-height = yes then do:
        assign v_whd_widget:height = wh_w_program:height - ( tt_maximizacao.window-height-original - tt_maximizacao.height-original ).
    end.
    if tt_maximizacao.log-posiciona-col = yes then do:
        assign v_whd_widget:col = wh_w_program:width - (tt_maximizacao.window-width-original - tt_maximizacao.col-original).
    end.
    if tt_maximizacao.tipo-widget = 'button'
    and tt_maximizacao.log-button-right = yes then do:
        assign v_whd_widget:col = wh_w_program:width - (tt_maximizacao.window-width-original - tt_maximizacao.col-original).
    end.
end.

end. /* ON WINDOW-MAXIMIZED OF wh_w_program */
&endif
&if '{&emsbas_version}' >= '5.06' &then
ON WINDOW-RESTORED OF wh_w_program
DO:
def var v_whd_widget as widget-handle no-undo.

for each tt_maximizacao:
    assign v_whd_widget = tt_maximizacao.hdl-widget.

    if can-query(v_whd_widget,'row') then
        assign v_whd_widget:row    = tt_maximizacao.row-original    no-error.

    if can-query(v_whd_widget,'col') then
        assign v_whd_widget:col    = tt_maximizacao.col-original    no-error.

    if can-query(v_whd_widget,'width') then
        assign v_whd_widget:width  = tt_maximizacao.width-original  no-error.

    if can-query(v_whd_widget,'height') then
        assign v_whd_widget:height = tt_maximizacao.height-original no-error.
end.

end. /* ON WINDOW-RESTORED OF wh_w_program */
&endif

/*********************** User Interface Trigger Begin ***********************/


ON ROW-DISPLAY OF br_concil_acr_fat IN FRAME f_bas_10_concilia_acr_fat
DO:

    if avail tt_concil_acr_fat then do:
        assign tt_concil_acr_fat.ttv_val_acr:BGCOLOR IN BROWSE br_concil_acr_fat = 10
               tt_concil_acr_fat.ttv_val_faturam:BGCOLOR IN BROWSE br_concil_acr_fat = 10.
        if tt_concil_acr_fat.ttv_log_erro THEN
            assign tt_concil_acr_fat.ttv_val_dif_acr_faturam:BGCOLOR IN BROWSE br_concil_acr_fat = 12.
    end.

END. /* ON ROW-DISPLAY OF br_concil_acr_fat IN FRAME f_bas_10_concilia_acr_fat */

ON START-SEARCH OF br_concil_acr_fat IN FRAME f_bas_10_concilia_acr_fat
DO:

    DEF VAR hTemp1 AS WIDGET-HANDLE NO-UNDO. 
    DEF VAR hTemp2 AS WIDGET-HANDLE NO-UNDO. 
    ASSIGN hTemp1 = br_concil_acr_fat:CURRENT-COLUMN 
           hTemp2 = br_concil_acr_fat:QUERY. 
    if v_log_mostra_erro then
        hTemp2:QUERY-PREPARE('for each tt_concil_acr_fat ' + 
                                'where tt_concil_acr_fat.ttv_log_erro = yes ' +
                                'OUTER-JOIN by ' + hTemp1:NAME). 
    else
        hTemp2:QUERY-PREPARE('for each tt_concil_acr_fat OUTER-JOIN by ' + hTemp1:NAME). 

    hTemp2:QUERY-OPEN(). 

END. /* ON START-SEARCH OF br_concil_acr_fat IN FRAME f_bas_10_concilia_acr_fat */

ON VALUE-CHANGED OF br_concil_acr_fat IN FRAME f_bas_10_concilia_acr_fat
DO:

    IF AVAIL tt_concil_acr_fat THEN DO:
        ASSIGN v_des_erro_3:SCREEN-VALUE IN FRAME f_bas_10_concilia_acr_fat = tt_concil_acr_fat.ttv_des_erro.

        OPEN QUERY qr_tt_concil_tit_agrupa
            FOR EACH tt_concil_tit_agrupa
               WHERE tt_concil_tit_agrupa.row_concil_acr_fat = ROWID(tt_concil_acr_fat).
    END.


END. /* ON VALUE-CHANGED OF br_concil_acr_fat IN FRAME f_bas_10_concilia_acr_fat */

ON CHOOSE OF bt_atz IN FRAME f_bas_10_concilia_acr_fat
DO:

    /************************* Variable Definition Begin ************************/

    def var v_cod_estab_fim_ext              as character       no-undo. /*local*/
    def var v_cod_estab_inicial_ext          as character       no-undo. /*local*/


    /************************** Variable Definition End *************************/

    assign v_log_method = session:set-wait-state('general').

    for each tt_acr:
        delete tt_acr.
    end.
    for each tt_fat:
        delete tt_fat.
    end.
    for each tt_concil_acr_fat:
        delete tt_concil_acr_fat.
    end.

    FOR EACH tt_concil_tit_agrupa:
        DELETE tt_concil_tit_agrupa.
    END.
    assign v_des_erro_3:screen-value in frame f_bas_10_concilia_acr_fat = ""
           v_num_tit_acr_concil          = 0
           v_num_nota_concil_faturam     = 0
           v_val_tit_acr_concil          = 0
           v_val_tot_nota_concil_faturam = 0
           v_num_nota_concil_faturam_aux = 0
           v_log_erro                    = yes.
    open query qr_concil_acr_fat for
        each tt_concil_acr_fat.

    &if defined(BF_FIN_CONCIL_CONTABEIS) &then
        run pi_monta_estab_ems2_fat.
        run pi_monta_temp_table_concil_acr_lista.
    &else
        if v_cod_estab_inicial <> "" then do:
            find first trad_org_ext no-lock
                 where trad_org_ext.cod_matriz_trad_org_ext = param_integr_ems.des_contdo_param_integr_ems and
                       trad_org_ext.cod_tip_unid_organ      = tip_unid_organ.cod_tip_unid_organ            and 
                       trad_org_ext.cod_unid_organ_ext      >= v_cod_estab_inicial no-error.
            if avail trad_org_ext then
                assign v_cod_estab_inicial_ext = trad_org_ext.cod_unid_organ.
        end.
        else
            assign v_cod_estab_inicial_ext = "".
        if v_cod_estab_fim <> "ZZZ" /*l_zzz*/  then do:
            find last trad_org_ext no-lock
                       where trad_org_ext.cod_matriz_trad_org_ext = param_integr_ems.des_contdo_param_integr_ems and
                       trad_org_ext.cod_tip_unid_organ            = tip_unid_organ.cod_tip_unid_organ            and 
                       trad_org_ext.cod_unid_organ_ext           <= v_cod_estab_fim no-error.
            if avail trad_org_ext then
                assign v_cod_estab_fim_ext = trad_org_ext.cod_unid_organ.
        end.
        else
            assign v_cod_estab_fim_ext = "ZZZ" /*l_zzz*/ .

        run pi_monta_temp_table_concil_fat in v_hdl_prog_ems2 (input  v_dat_inicial,
                                                               input  v_dat_fim,
                                                               input  v_cod_estab_inicial_ext,
                                                               input  v_cod_estab_fim_ext,
                                                               input-output v_num_nota_concil_faturam_aux,
                                                               input-output table tt_fat).
        run pi_monta_temp_table_concil_acr.                                                           
    &endif                                 
                                                                             
    run pi_monta_temp_table_concil_acr_fat.

    if v_log_gerac_planilha then do:
        output stream s_planilha to value(v_cod_arq_planilha) convert target 'iso8859-1'.
        put stream s_planilha unformatted
            "Estab" /*l_estabe*/  v_cod_carac_lim "Espec" /*l_espec*/  v_cod_carac_lim "SÇrie" /*l_serie*/  v_cod_carac_lim
            "T°tulo" /*l_titulo*/  v_cod_carac_lim "Parc" /*l_parc*/  v_cod_carac_lim "Val ACR" /*l_val_acr*/  v_cod_carac_lim "Val FAT" /*l_val_fat*/  v_cod_carac_lim
            "Val Diferenáa" /*l_val_difer*/  v_cod_carac_lim "Descriá∆o do Erro" /*l_descricao_erro*/  skip.
        for each tt_concil_acr_fat:
            put stream s_planilha unformatted
                tt_concil_acr_fat.tta_cod_estab v_cod_carac_lim
                tt_concil_acr_fat.tta_cod_espec_docto v_cod_carac_lim
                tt_concil_acr_fat.tta_cod_ser_docto v_cod_carac_lim
                tt_concil_acr_fat.tta_cod_tit_acr v_cod_carac_lim
                tt_concil_acr_fat.tta_cod_parcela v_cod_carac_lim
                tt_concil_acr_fat.ttv_val_acr v_cod_carac_lim
                tt_concil_acr_fat.ttv_val_faturam v_cod_carac_lim
                tt_concil_acr_fat.ttv_val_dif_acr_faturam v_cod_carac_lim 
                tt_concil_acr_fat.ttv_des_erro skip.
        end.
        output stream s_planilha close.
    end.

    open query qr_concil_acr_fat
        for each tt_concil_acr_fat.

    assign v_log_method = session:set-wait-state('').

END. /* ON CHOOSE OF bt_atz IN FRAME f_bas_10_concilia_acr_fat */

ON CHOOSE OF bt_exi IN FRAME f_bas_10_concilia_acr_fat
DO:

    run pi_close_program /*pi_close_program*/.
END. /* ON CHOOSE OF bt_exi IN FRAME f_bas_10_concilia_acr_fat */

ON CHOOSE OF bt_fil2 IN FRAME f_bas_10_concilia_acr_fat
DO:

    view frame f_fil_01_concilia_acr_fat.
    enable all
        with frame f_fil_01_concilia_acr_fat.
    disable v_cod_unid_organ
            v_cod_matriz_trad_org_ext
        with frame f_fil_01_concilia_acr_fat.

    DISP v_dat_inicial
         v_dat_fim
         v_cod_estab_inicial
         v_cod_estab_fim
         v_cod_unid_organ
         v_cod_matriz_trad_org_ext
        with frame f_fil_01_concilia_acr_fat.

    &if defined(BF_FIN_CONCIL_CONTABEIS) &then
        assign v_cod_matriz_trad_org_ext:visible in frame f_fil_01_concilia_acr_fat = no
               v_cod_estab_inicial:visible in frame f_fil_01_concilia_acr_fat = no
               v_cod_estab_fim:visible in frame f_fil_01_concilia_acr_fat = no.
        disable v_des_estab_select with frame f_fil_01_concilia_acr_fat.
        display v_des_estab_select with frame f_fil_01_concilia_acr_fat.
    &else
        assign v_des_estab_select:visible in frame f_fil_01_concilia_acr_fat = no
               bt_todos_img:visible in frame f_fil_01_concilia_acr_fat = no.    
    &endif      

    assign v_log_erro_tela = yes.
    repeat while v_log_erro_tela = yes:

        if  valid-handle(v_wgh_focus)
        then do:
            wait-for go of frame f_fil_01_concilia_acr_fat focus v_wgh_focus.
        end.
        else do:  
            wait-for go of frame f_fil_01_concilia_acr_fat.
        end.

        if  return-value = "NOK" /*l_nok*/  
        then do:
            assign v_log_erro_tela = yes.
        end.
        else do:
            assign v_log_erro_tela = no.
        end.
    end.
    hide frame f_fil_01_concilia_acr_fat.

END. /* ON CHOOSE OF bt_fil2 IN FRAME f_bas_10_concilia_acr_fat */

ON CHOOSE OF bt_hel1 IN FRAME f_bas_10_concilia_acr_fat
DO:


    /* Begin_Include: i_context_help_frame */
    run prgtec/men/men900za.py (Input self:frame,
                                Input this-procedure:handle) /*prg_fnc_chamar_help_context*/.


    /* End_Include: i_context_help_frame */

END. /* ON CHOOSE OF bt_hel1 IN FRAME f_bas_10_concilia_acr_fat */

ON CHOOSE OF bt_nao_pula_linha IN FRAME f_bas_10_concilia_acr_fat
DO:

    if v_log_erro then do:
        assign v_log_erro        = no
               v_log_mostra_erro = yes.           

        open query qr_concil_acr_fat for
            each tt_concil_acr_fat
            where tt_concil_acr_fat.ttv_log_erro = yes no-lock.
    end.
    else do:
        assign v_log_erro = yes
               v_log_mostra_erro = no.

        open query qr_concil_acr_fat for
            each tt_concil_acr_fat no-lock.
    end.    

END. /* ON CHOOSE OF bt_nao_pula_linha IN FRAME f_bas_10_concilia_acr_fat */

/* ON CHOOSE OF bt_planilha_excel IN FRAME f_bas_10_concilia_acr_fat                                                      */
/* DO:                                                                                                                    */
/*                                                                                                                        */
/*     assign v_cod_dwb_file  = session:temp-directory                                                                    */
/*            v_cod_arq_modul = "plan" /*l_plan*/  + "-" + lc("concil" /*l_concil*/ ) + '.tmp'                            */
/*            v_ind_run_mode  = "On-Line" /*l_online*/ .                                                                  */
/*                                                                                                                        */
/*     if  search("prgint/ufn/ufn902za.r") = ? and search("prgint/ufn/ufn902za.p") = ? then do:                           */
/*         if  v_cod_dwb_user begins 'es_' then                                                                           */
/*             return "Programa executòvel n∆o foi encontrado:" /*l_programa_nao_encontrado*/  + "prgint/ufn/ufn902za.p". */
/*         else do:                                                                                                       */
/*             message "Programa executòvel n∆o foi encontrado:" /*l_programa_nao_encontrado*/  "prgint/ufn/ufn902za.p"   */
/*                    view-as alert-box error buttons ok.                                                                 */
/*             stop.                                                                                                      */
/*         end.                                                                                                           */
/*     end.                                                                                                               */
/*     else                                                                                                               */
/*         run prgint/ufn/ufn902za.p /*prg_fnc_info_planilha*/.                                                           */
/* END. /* ON CHOOSE OF bt_planilha_excel IN FRAME f_bas_10_concilia_acr_fat */                                           */

ON CHOOSE OF bt_ran2 IN FRAME f_bas_10_concilia_acr_fat
DO:

    &if defined(BF_FIN_CONCIL_CONTABEIS) = 0 &then
        if not avail unid_organ
        and not avail matriz_trad_org_ext then do:
            /* Matriz de Traduá∆o Organizacional n∆o informado. */
            run pi_messages (input "show",
                             input 21262,
                             input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")) /*msg_21262*/.
            return no-apply.
        end.
    &endif
    if not avail plano_cta_ctbl then do:
        /* Plano de Contas Invòlido. */
        run pi_messages (input "show",
                         input 21275,
                         input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")) /*msg_21275*/.
        return no-apply.
    end.

    view frame f_ran_01_concilia_acr_fat.
    enable all
        with frame f_ran_01_concilia_acr_fat.
    assign v_log_erro_tela = yes.
    repeat while v_log_erro_tela = yes:

        if  valid-handle(v_wgh_focus)
        then do:
            wait-for go of frame  f_ran_01_concilia_acr_fat focus v_wgh_focus.
        end.
        else do:  
            wait-for go of frame f_ran_01_concilia_acr_fat.
        end.

        if  return-value = "NOK" /*l_nok*/ 
        then do:
            assign v_log_erro_tela = yes.
        end.
        else do:
            assign v_log_erro_tela = no.
        end.
    end.
    hide frame f_ran_01_concilia_acr_fat.

END. /* ON CHOOSE OF bt_ran2 IN FRAME f_bas_10_concilia_acr_fat */

ON CHOOSE OF bt_tot IN FRAME f_bas_10_concilia_acr_fat
DO:

    assign v_val_tot_nota_concil_faturam = 0
           v_val_tit_acr_concil          = 0
           v_num_tit_acr_concil          = 0
           v_num_nota_concil_faturam     = 0.
    &if defined(BF_FIN_CONCIL_CONTABEIS) &then
        for each tt_concil_acr_fat:
           assign v_val_tot_nota_concil_faturam = v_val_tot_nota_concil_faturam + tt_concil_acr_fat.ttv_val_faturam
                  v_val_tit_acr_concil          = v_val_tit_acr_concil          + tt_concil_acr_fat.ttv_val_acr
                  v_num_tit_acr_concil          = v_num_tit_acr_concil          + tt_concil_acr_fat.ttv_num_tit_acr_concil.
        end.
        assign v_num_nota_concil_faturam = v_num_nota_concil_faturam_aux.

    &else

        if  not v_log_erro
        then do:
            for each tt_concil_acr_fat
               where tt_concil_acr_fat.ttv_log_erro = yes:
               assign v_val_tot_nota_concil_faturam = v_val_tot_nota_concil_faturam + tt_concil_acr_fat.ttv_val_faturam
                      v_val_tit_acr_concil          = v_val_tit_acr_concil          + tt_concil_acr_fat.ttv_val_acr
                      v_num_tit_acr_concil          = if tt_concil_acr_fat.ttv_val_acr     <> 0 then v_num_tit_acr_concil      + 1 else v_num_tit_acr_concil
                      v_num_nota_concil_faturam     = if tt_concil_acr_fat.ttv_val_faturam <> 0 then v_num_nota_concil_faturam + 1 else v_num_nota_concil_faturam.
            end.
        end /* if */.
        else do:
            for each tt_concil_acr_fat:
               assign v_val_tot_nota_concil_faturam = v_val_tot_nota_concil_faturam + tt_concil_acr_fat.ttv_val_faturam
                      v_val_tit_acr_concil          = v_val_tit_acr_concil          + tt_concil_acr_fat.ttv_val_acr
                      v_num_tit_acr_concil          = v_num_tit_acr_concil          + tt_concil_acr_fat.ttv_num_tit_acr_concil.
            end.
            assign v_num_nota_concil_faturam = v_num_nota_concil_faturam_aux.
        end /* else */.

     &endif   

    view frame f_dlg_03_concilia_acr_fat_totais.
    assign v_val_tit_acr_concil:sensitive in frame f_dlg_03_concilia_acr_fat_totais = no
           v_val_tot_nota_concil_faturam:sensitive in frame f_dlg_03_concilia_acr_fat_totais = no
           v_val_dif_concil_acr_faturam:sensitive in frame f_dlg_03_concilia_acr_fat_totais = no
           v_num_tot_dif_concil_faturam:sensitive in frame f_dlg_03_concilia_acr_fat_totais = no
           v_num_nota_concil_faturam:sensitive in frame f_dlg_03_concilia_acr_fat_totais = no
           v_num_tit_acr_concil:sensitive in frame f_dlg_03_concilia_acr_fat_totais = no.
    enable bt_ok
           bt_can
        with frame f_dlg_03_concilia_acr_fat_totais.


    /* Calcula a diferená∆o entre notas e duplicatas */
    assign v_num_tot_dif_concil_faturam = v_num_nota_concil_faturam - v_num_tit_acr_concil.
    if v_num_tot_dif_concil_faturam < 0 then
        assign v_num_tot_dif_concil_faturam = v_num_tot_dif_concil_faturam * (-1).

    /* Calcula a Diferenáa entre o valor das notas e duplicatas*/
    assign v_val_dif_concil_acr_faturam = v_val_tit_acr_concil - v_val_tot_nota_concil_faturam.
    if v_val_dif_concil_acr_faturam < 0 then
        assign v_val_dif_concil_acr_faturam = v_val_dif_concil_acr_faturam * (-1).


    disp v_val_tit_acr_concil
         v_val_tot_nota_concil_faturam
         v_val_dif_concil_acr_faturam
         v_num_tot_dif_concil_faturam
         v_num_nota_concil_faturam
         v_num_tit_acr_concil
        with frame f_dlg_03_concilia_acr_fat_totais.
    assign v_log_erro_tela = yes.
    repeat while v_log_erro_tela = yes:

        if  valid-handle(v_wgh_focus)
        then do:
            wait-for go of frame  f_dlg_03_concilia_acr_fat_totais focus v_wgh_focus.
        end.
        else do:  
            wait-for go of frame f_dlg_03_concilia_acr_fat_totais.
        end.

        if  return-value = "NOK" /*l_nok*/ 
        then do:
            assign v_log_erro_tela = yes.
        end.
        else do:
            assign v_log_erro_tela = no.
        end.
    end.
    hide frame f_dlg_03_concilia_acr_fat_totais.

END. /* ON CHOOSE OF bt_tot IN FRAME f_bas_10_concilia_acr_fat */

ON CHOOSE OF bt_hel2 IN FRAME f_dlg_03_concilia_acr_fat_totais
DO:


    /* Begin_Include: i_context_help_frame */
    run prgtec/men/men900za.py (Input self:frame,
                                Input this-procedure:handle) /*prg_fnc_chamar_help_context*/.


    /* End_Include: i_context_help_frame */

END. /* ON CHOOSE OF bt_hel2 IN FRAME f_dlg_03_concilia_acr_fat_totais */

ON CHOOSE OF bt_hel2 IN FRAME f_fil_01_concilia_acr_fat
DO:


    /* Begin_Include: i_context_help_frame */
    run prgtec/men/men900za.py (Input self:frame,
                                Input this-procedure:handle) /*prg_fnc_chamar_help_context*/.


    /* End_Include: i_context_help_frame */

END. /* ON CHOOSE OF bt_hel2 IN FRAME f_fil_01_concilia_acr_fat */

ON CHOOSE OF bt_ok IN FRAME f_fil_01_concilia_acr_fat
DO:

    assign input frame f_fil_01_concilia_acr_fat v_dat_inicial
           input frame f_fil_01_concilia_acr_fat v_dat_fim.

    &if defined(BF_FIN_CONCIL_CONTABEIS) &then
        assign input frame f_fil_01_concilia_acr_fat v_des_estab_select.
        if v_dat_inicial > v_dat_fim then do:
            /* &1 maior que &2 ! */
            run pi_messages (input "show",
                             input 1633,
                             input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9",
                                               "Data Inicial" /*l_data_inicial*/ ,"Data Final" /*l_data_final*/)) /*msg_1633*/.
            return no-apply.
        end.
    &else
        assign input frame f_fil_01_concilia_acr_fat v_cod_estab_inicial
               input frame f_fil_01_concilia_acr_fat v_cod_estab_fim.
    &endif


END. /* ON CHOOSE OF bt_ok IN FRAME f_fil_01_concilia_acr_fat */

ON CHOOSE OF bt_todos_img IN FRAME f_fil_01_concilia_acr_fat
DO:

    assign input frame f_fil_01_concilia_acr_fat v_des_estab_select.
    if  search('prgint/utb/utb071za.r') = ? and search('prgint/utb/utb071za.p') = ? then do:
        if  v_cod_dwb_user begins 'es_' then
            return 'Programa executòvel n∆o foi encontrado:' /* l_programa_nao_encontrado*/  + 'prgint/utb/utb071za.p'.
        else do:
            message 'Programa executòvel n∆o foi encontrado:' /* l_programa_nao_encontrado*/  'prgint/utb/utb071za.p'
                   view-as alert-box error buttons ok.
            return.
        end.
    end.
    else
        run prgint/utb/utb071za.p (Input "ACR" /*l_acr*/ ) /* prg_fnc_estabelecimento_selec_espec*/.

    display v_des_estab_select with frame f_fil_01_concilia_acr_fat.
END. /* ON CHOOSE OF bt_todos_img IN FRAME f_fil_01_concilia_acr_fat */

ON LEAVE OF plano_cta_ctbl.cod_plano_cta_ctbl IN FRAME f_fil_01_concilia_acr_fat
DO:

    if plano_cta_ctbl.cod_plano_cta_ctbl:screen-value in frame f_fil_01_concilia_acr_fat <> "" then do:
        find first plano_cta_ctbl 
            where plano_cta_ctbl.cod_plano_cta_ctbl = plano_cta_ctbl.cod_plano_cta_ctbl:screen-value in frame f_fil_01_concilia_acr_fat no-lock no-error.
        if avail plano_cta_ctbl then do:
            assign plano_cta_ctbl.cod_plano_cta_ctbl:screen-value in frame f_fil_01_concilia_acr_fat =
                    string(plano_cta_ctbl.cod_plano_cta_ctbl).
        end /* if */.
        else do:
            /* Plano Contas n∆o encontrado. */
            run pi_messages (input "show",
                             input 12463,
                             input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")) /*msg_12463*/.
            return no-apply.
        end.
    end.

END. /* ON LEAVE OF plano_cta_ctbl.cod_plano_cta_ctbl IN FRAME f_fil_01_concilia_acr_fat */

ON CHOOSE OF bt_des_todos_bord IN FRAME f_ran_01_concilia_acr_fat
DO:

    if  can-find( first tt_cta_ctbl_concilia_acr )
    and br_tt_cta_ctbl_concilia_acr:num-selected-rows > 0 then do:
        assign v_log_method = browse br_tt_cta_ctbl_concilia_acr:deselect-rows().
    end.

END. /* ON CHOOSE OF bt_des_todos_bord IN FRAME f_ran_01_concilia_acr_fat */

ON CHOOSE OF bt_elimina_linhas IN FRAME f_ran_01_concilia_acr_fat
DO:

    assign v_num_select_row = browse br_tt_cta_ctbl_concilia_acr:num-selected-rows.
    do v_num_row_a = 1 to v_num_select_row:
        assign v_log_method = browse br_tt_cta_ctbl_concilia_acr:fetch-selected-row(v_num_row_a).
        delete tt_cta_ctbl_concilia_acr.
    end.
    open query qr_tt_cta_ctbl_concilia_acr for 
        each tt_cta_ctbl_concilia_acr.

END. /* ON CHOOSE OF bt_elimina_linhas IN FRAME f_ran_01_concilia_acr_fat */

ON CHOOSE OF bt_enter IN FRAME f_ran_01_concilia_acr_fat
DO:

    /************************* Variable Definition Begin ************************/

    def var v_cod_cta_ctbl                   as character       no-undo. /*local*/
    def var v_num_cont                       as integer         no-undo. /*local*/


    /************************** Variable Definition End *************************/

    assign v_log_method = session:set-wait-state('general').
    assign v_cod_cta_ctbl = "".
    cta_block:       
    do v_num_cont = 1 to length(input frame f_ran_01_concilia_acr_fat cta_ctbl.cod_cta_ctbl):
        if substring(input frame f_ran_01_concilia_acr_fat cta_ctbl.cod_cta_ctbl,v_num_cont,1) = "." then
            next cta_block.
        assign v_cod_cta_ctbl = v_cod_cta_ctbl +  substring(input frame f_ran_01_concilia_acr_fat cta_ctbl.cod_cta_ctbl,v_num_cont,1).
    end.
    if not avail cta_ctbl then do:
        find first cta_ctbl no-lock
            where cta_ctbl.cod_plano_cta_ctbl = plano_cta_ctbl.cod_plano_cta_ctbl
            and   cta_ctbl.cod_cta_ctbl = v_cod_cta_ctbl no-error.
    end.
    if avail cta_ctbl then do:


        &if defined(BF_FIN_CONCIL_CONTABEIS) &then
            assign v_cod_lista = "" /*l_*/ .

            run pi_monta_estab_ems2_fat_2.

            run pi_valida_conta_transitoria in v_hdl_prog_ems2(input v_cod_lista,
                                                               input v_cod_cta_ctbl,
                                                               output v_log_cta_transit).
        &endif




        if not can-find (first tt_cta_ctbl_concilia_acr
            where tt_cta_ctbl_concilia_acr.tta_cod_plano_cta_ctbl = plano_cta_ctbl.cod_plano_cta_ctbl
            and   tt_cta_ctbl_concilia_acr.tta_cod_cta_ctbl = v_cod_cta_ctbl) then do:
            create tt_cta_ctbl_concilia_acr.
            assign tt_cta_ctbl_concilia_acr.tta_cod_plano_cta_ctbl = plano_cta_ctbl.cod_plano_cta_ctbl
                   tt_cta_ctbl_concilia_acr.tta_des_cta_ctbl = cta_ctbl.des_tit_ctbl
                   tt_cta_ctbl_concilia_acr.tta_cod_cta_ctbl = v_cod_cta_ctbl.
            open query qr_tt_cta_ctbl_concilia_acr for 
                each tt_cta_ctbl_concilia_acr.

        end.
        else
            /* Conta jò informada. */
            run pi_messages (input "show",
                             input 21264,
                             input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")) /*msg_21264*/.
    end.
    else
        /* &1 &2 invòlida ! */
        run pi_messages (input "show",
                         input 1764,
                         input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9",
                                           "Conta" /*l_conta*/ ,"Informada" /*l_informada*/)) /*msg_1764*/.    


    assign v_log_method = session:set-wait-state('').
END. /* ON CHOOSE OF bt_enter IN FRAME f_ran_01_concilia_acr_fat */

ON CHOOSE OF bt_hel2 IN FRAME f_ran_01_concilia_acr_fat
DO:


    /* Begin_Include: i_context_help_frame */
    run prgtec/men/men900za.py (Input self:frame,
                                Input this-procedure:handle) /*prg_fnc_chamar_help_context*/.


    /* End_Include: i_context_help_frame */

END. /* ON CHOOSE OF bt_hel2 IN FRAME f_ran_01_concilia_acr_fat */

ON CHOOSE OF bt_todos_img IN FRAME f_ran_01_concilia_acr_fat
DO:

    if  not can-find(first tt_cta_ctbl_concilia_acr) then
        return no-apply. 

    assign v_log_method = session:set-wait-state('general')
           v_num_lin = br_tt_cta_ctbl_concilia_acr:num-iterations.
           br_tt_cta_ctbl_concilia_acr:deselect-rows().
    apply "home" to br_tt_cta_ctbl_concilia_acr in frame f_ran_01_concilia_acr_fat.
    do  v_num_cont = 1 to v_num_lin:
        if  br_tt_cta_ctbl_concilia_acr:is-row-selected(v_num_lin) then leave.
        if  br_tt_cta_ctbl_concilia_acr:select-row(v_num_cont) then.
        if  v_num_cont mod v_num_lin = 0 then do:
            apply "page-down" to br_tt_cta_ctbl_concilia_acr in frame f_ran_01_concilia_acr_fat.
            assign v_num_cont = 0.
        end.  
    end.  
    assign v_log_method = session:set-wait-state('').
END. /* ON CHOOSE OF bt_todos_img IN FRAME f_ran_01_concilia_acr_fat */

ON CHOOSE OF bt_zoo IN FRAME f_ran_01_concilia_acr_fat
DO:

    assign v_rec_plano_cta_ctbl = recid(plano_cta_ctbl).
    if  search("prgint/utb/utb080nc.r") = ? and search("prgint/utb/utb080nc.p") = ? then do:
        if  v_cod_dwb_user begins 'es_' then
            return "Programa executòvel n∆o foi encontrado:" /*l_programa_nao_encontrado*/  + "prgint/utb/utb080nc.p".
        else do:
            message "Programa executòvel n∆o foi encontrado:" /*l_programa_nao_encontrado*/  "prgint/utb/utb080nc.p"
                   view-as alert-box error buttons ok.
            return.
        end.
    end.
    else
        run prgint/utb/utb080nc.p /*prg_see_cta_ctbl_plano*/.
    if  v_rec_cta_ctbl <> ? then do:
        find cta_ctbl where recid(cta_ctbl) = v_rec_cta_ctbl no-lock no-error.
        assign cta_ctbl.cod_cta_ctbl:screen-value = string(cta_ctbl.cod_cta_ctbl,plano_cta_ctbl.cod_format_cta_ctbl).
        apply 'entry' to cta_ctbl.cod_cta_ctbl in frame f_ran_01_concilia_acr_fat.
    end.

END. /* ON CHOOSE OF bt_zoo IN FRAME f_ran_01_concilia_acr_fat */

ON LEAVE OF cta_ctbl.cod_cta_ctbl IN FRAME f_ran_01_concilia_acr_fat
DO:

    /************************* Variable Definition Begin ************************/

    def var v_cod_cta_ctbl                   as character       no-undo. /*local*/
    def var v_num_cont                       as integer         no-undo. /*local*/


    /************************** Variable Definition End *************************/

    if cta_ctbl.cod_cta_ctbl:screen-value <> "" then do:
        if not avail plano_cta_ctbl then do:
            /* Plano de Contas Invòlido. */
            run pi_messages (input "show",
                             input 21263,
                             input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")) /*msg_21263*/.
            return no-apply.
        end.

        assign v_cod_cta_ctbl = "".
        cta_block:       
        do v_num_cont = 1 to length(input frame f_ran_01_concilia_acr_fat cta_ctbl.cod_cta_ctbl):
            if substring(input frame f_ran_01_concilia_acr_fat cta_ctbl.cod_cta_ctbl,v_num_cont,1) = "." then
                next cta_block.
            assign v_cod_cta_ctbl = v_cod_cta_ctbl +  substring(input frame f_ran_01_concilia_acr_fat cta_ctbl.cod_cta_ctbl,v_num_cont,1).
        end.
        find cta_ctbl no-lock
            where cta_ctbl.cod_plano_cta_ctbl = plano_cta_ctbl.cod_plano_cta_ctbl
            and   cta_ctbl.cod_cta_ctbl = v_cod_cta_ctbl no-error.
        if avail cta_ctbl then do:
            assign cta_ctbl.cod_cta_ctbl:screen-value = string(cta_ctbl.cod_cta_ctbl,plano_cta_ctbl.cod_format_cta_ctbl).
            apply 'entry' to cta_ctbl.cod_cta_ctbl in frame f_ran_01_concilia_acr_fat.
        end.
    end.
END. /* ON LEAVE OF cta_ctbl.cod_cta_ctbl IN FRAME f_ran_01_concilia_acr_fat */


/************************ User Interface Trigger End ************************/

/************************** Function Trigger Begin **************************/


ON  CHOOSE OF bt_zoo_376196 IN FRAME f_fil_01_concilia_acr_fat
OR F5 OF plano_cta_ctbl.cod_plano_cta_ctbl IN FRAME f_fil_01_concilia_acr_fat DO:

    /* fn_generic_zoom */
    if  search("prgint/utb/utb080ka.r") = ? and search("prgint/utb/utb080ka.p") = ? then do:
        if  v_cod_dwb_user begins 'es_' then
            return "Programa executòvel n∆o foi encontrado:" /*l_programa_nao_encontrado*/  + "prgint/utb/utb080ka.p".
        else do:
            message "Programa executòvel n∆o foi encontrado:" /*l_programa_nao_encontrado*/  "prgint/utb/utb080ka.p"
                   view-as alert-box error buttons ok.
            return.
        end.
    end.
    else
        run prgint/utb/utb080ka.p /*prg_sea_plano_cta_ctbl*/.
    if  v_rec_plano_cta_ctbl <> ?
    then do:
        find plano_cta_ctbl where recid(plano_cta_ctbl) = v_rec_plano_cta_ctbl no-lock no-error.
        assign plano_cta_ctbl.cod_plano_cta_ctbl:screen-value in frame f_fil_01_concilia_acr_fat =
               string(plano_cta_ctbl.cod_plano_cta_ctbl).

    end /* if */.
    apply "entry" to plano_cta_ctbl.cod_plano_cta_ctbl in frame f_fil_01_concilia_acr_fat.
end. /* ON  CHOOSE OF bt_zoo_376196 IN FRAME f_fil_01_concilia_acr_fat */


/*************************** Function Trigger End ***************************/

/**************************** Frame Trigger Begin ***************************/


ON ENDKEY OF FRAME f_bas_10_concilia_acr_fat
DO:


END. /* ON ENDKEY OF FRAME f_bas_10_concilia_acr_fat */

ON END-ERROR OF FRAME f_bas_10_concilia_acr_fat
DO:

    run pi_close_program /*pi_close_program*/.
END. /* ON END-ERROR OF FRAME f_bas_10_concilia_acr_fat */

ON HELP OF FRAME f_bas_10_concilia_acr_fat ANYWHERE
DO:


    /* Begin_Include: i_context_help */
    run prgtec/men/men900za.py (Input self:handle,
                                Input this-procedure:handle) /*prg_fnc_chamar_help_context*/.
    /* End_Include: i_context_help */

END. /* ON HELP OF FRAME f_bas_10_concilia_acr_fat */

ON RIGHT-MOUSE-DOWN OF FRAME f_bas_10_concilia_acr_fat ANYWHERE
DO:

    /************************* Variable Definition Begin ************************/

    def var v_wgh_frame
        as widget-handle
        format ">>>>>>9":U
        no-undo.


    /************************** Variable Definition End *************************/


    /* Begin_Include: i_right_mouse_down_window */
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

        assign v_nom_title_aux       = current-window:title
               current-window:title  = self:help.
    end /* if */.

    /* End_Include: i_right_mouse_down_window */

END. /* ON RIGHT-MOUSE-DOWN OF FRAME f_bas_10_concilia_acr_fat */

ON RIGHT-MOUSE-UP OF FRAME f_bas_10_concilia_acr_fat ANYWHERE
DO:

    /************************* Variable Definition Begin ************************/

    def var v_wgh_frame
        as widget-handle
        format ">>>>>>9":U
        no-undo.


    /************************** Variable Definition End *************************/


    /* Begin_Include: i_right_mouse_up_window */
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

        assign current-window:title  = v_nom_title_aux.
    end /* if */.

    /* End_Include: i_right_mouse_up_window */

END. /* ON RIGHT-MOUSE-UP OF FRAME f_bas_10_concilia_acr_fat */

ON HELP OF FRAME f_dlg_03_concilia_acr_fat_totais ANYWHERE
DO:


    /* Begin_Include: i_context_help */
    run prgtec/men/men900za.py (Input self:handle,
                                Input this-procedure:handle) /*prg_fnc_chamar_help_context*/.
    /* End_Include: i_context_help */

END. /* ON HELP OF FRAME f_dlg_03_concilia_acr_fat_totais */

ON RIGHT-MOUSE-DOWN OF FRAME f_dlg_03_concilia_acr_fat_totais ANYWHERE
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

END. /* ON RIGHT-MOUSE-DOWN OF FRAME f_dlg_03_concilia_acr_fat_totais */

ON RIGHT-MOUSE-UP OF FRAME f_dlg_03_concilia_acr_fat_totais ANYWHERE
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

END. /* ON RIGHT-MOUSE-UP OF FRAME f_dlg_03_concilia_acr_fat_totais */

ON WINDOW-CLOSE OF FRAME f_dlg_03_concilia_acr_fat_totais
DO:

    apply "end-error" to self.

END. /* ON WINDOW-CLOSE OF FRAME f_dlg_03_concilia_acr_fat_totais */

ON HELP OF FRAME f_fil_01_concilia_acr_fat ANYWHERE
DO:


    /* Begin_Include: i_context_help */
    run prgtec/men/men900za.py (Input self:handle,
                                Input this-procedure:handle) /*prg_fnc_chamar_help_context*/.
    /* End_Include: i_context_help */

END. /* ON HELP OF FRAME f_fil_01_concilia_acr_fat */

ON RIGHT-MOUSE-DOWN OF FRAME f_fil_01_concilia_acr_fat ANYWHERE
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

END. /* ON RIGHT-MOUSE-DOWN OF FRAME f_fil_01_concilia_acr_fat */

ON RIGHT-MOUSE-UP OF FRAME f_fil_01_concilia_acr_fat ANYWHERE
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

END. /* ON RIGHT-MOUSE-UP OF FRAME f_fil_01_concilia_acr_fat */

ON WINDOW-CLOSE OF FRAME f_fil_01_concilia_acr_fat
DO:

    apply "end-error" to self.
END. /* ON WINDOW-CLOSE OF FRAME f_fil_01_concilia_acr_fat */

ON HELP OF FRAME f_ran_01_concilia_acr_fat ANYWHERE
DO:


    /* Begin_Include: i_context_help */
    run prgtec/men/men900za.py (Input self:handle,
                                Input this-procedure:handle) /*prg_fnc_chamar_help_context*/.
    /* End_Include: i_context_help */

END. /* ON HELP OF FRAME f_ran_01_concilia_acr_fat */

ON RIGHT-MOUSE-DOWN OF FRAME f_ran_01_concilia_acr_fat ANYWHERE
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

END. /* ON RIGHT-MOUSE-DOWN OF FRAME f_ran_01_concilia_acr_fat */

ON RIGHT-MOUSE-UP OF FRAME f_ran_01_concilia_acr_fat ANYWHERE
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

END. /* ON RIGHT-MOUSE-UP OF FRAME f_ran_01_concilia_acr_fat */

ON WINDOW-CLOSE OF FRAME f_ran_01_concilia_acr_fat
DO:

    apply "end-error" to self.
END. /* ON WINDOW-CLOSE OF FRAME f_ran_01_concilia_acr_fat */


/***************************** Frame Trigger End ****************************/

/*************************** Window Trigger Begin ***************************/

IF session:window-system <> "TTY" THEN
DO:

ON ENTRY OF wh_w_program
DO:
&if '{&emsbas_version}' >= '5.06' &then
    def var v_whd_field_group   as widget-handle no-undo.
    def var v_whd_widget        as widget-handle no-undo.
    def buffer b_tt_maximizacao for tt_maximizacao.
    find first tt_maximizacao no-error.
    if not avail tt_maximizacao then do:
        assign v_whd_field_group = frame f_bas_10_concilia_acr_fat:first-child.
        repeat while valid-handle(v_whd_field_group):
            assign v_whd_widget = v_whd_field_group:first-child.
            repeat while valid-handle(v_whd_widget):
                create tt_maximizacao.
                if can-query(v_whd_widget,'handle') then
                    assign tt_maximizacao.hdl-widget            = v_whd_widget:handle no-error.
                if can-query(v_whd_widget,'type') then
                    assign tt_maximizacao.tipo-widget           = v_whd_widget:type no-error.
                if can-query(v_whd_widget,'row') then
                    assign tt_maximizacao.row-original          = v_whd_widget:row no-error.
                if can-query(v_whd_widget,'col') then
                    assign tt_maximizacao.col-original          = v_whd_widget:col no-error.
                if can-query(v_whd_widget,'width') then
                    assign tt_maximizacao.width-original        = v_whd_widget:width no-error.
                if can-query(v_whd_widget,'height') then
                    assign tt_maximizacao.height-original       = v_whd_widget:height no-error.
                assign tt_maximizacao.frame-width-original   = frame f_bas_10_concilia_acr_fat:width.
                assign tt_maximizacao.frame-height-original  = frame f_bas_10_concilia_acr_fat:height.
                assign tt_maximizacao.window-width-original  = wh_w_program:width.
                assign tt_maximizacao.window-height-original = wh_w_program:height.
                assign tt_maximizacao.log-posiciona-row  = no.
                assign tt_maximizacao.log-posiciona-col  = no.
                assign tt_maximizacao.log-calcula-width  = no.
                assign tt_maximizacao.log-calcula-height = no.
                assign tt_maximizacao.log-button-right   = no.
                if can-query(v_whd_widget,'flat-button') then do:
                    if v_whd_widget:flat-button = yes then do:
                        assign tt_maximizacao.log-posiciona-col  = no.
                        if v_whd_widget:name = 'bt_exi' or
                           v_whd_widget:name = 'bt_hel1' then do:
                            assign tt_maximizacao.log-button-right   = yes.
                        end.
                    end.
                end.
                if can-query(v_whd_widget,'type') then do:
                    if v_whd_widget:type = 'browse' then 
                        assign tt_maximizacao.log-calcula-height = yes.
                end.
                assign v_whd_widget = v_whd_widget:next-sibling.
            end.
            assign v_whd_field_group = v_whd_field_group:next-sibling.
        end.
    end.
    for each tt_maximizacao
       where tt_maximizacao.tipo-widget = 'browse'
          by tt_maximizacao.row-original:
        find first b_tt_maximizacao
             where b_tt_maximizacao.tipo-widget = 'browse'
               and b_tt_maximizacao.hdl-widget = tt_maximizacao.hdl-widget
            no-error.
        if avail b_tt_maximizacao then do:
            leave.
        end.
    end.
    if avail b_tt_maximizacao then do:
        for each tt_maximizacao
            where tt_maximizacao.row-original >=  b_tt_maximizacao.row-original + 
                                                  b_tt_maximizacao.height-original - 1:
            assign tt_maximizacao.log-calcula-height = no.
            assign tt_maximizacao.log-posiciona-row  = yes.
            assign tt_maximizacao.log-posiciona-col  = no.
        end.
    end.
    for each b_tt_maximizacao
        where b_tt_maximizacao.tipo-widget = 'browse':
        assign b_tt_maximizacao.log-calcula-width = yes.
        for each tt_maximizacao
            where tt_maximizacao.row-original + tt_maximizacao.height-original >= 
                  b_tt_maximizacao.row-original + b_tt_maximizacao.height-original 
              and tt_maximizacao.row-original < b_tt_maximizacao.row-original + b_tt_maximizacao.height-original 
              and tt_maximizacao.tipo-widget = 'rectangle'
              and b_tt_maximizacao.log-calcula-height = yes:
            assign tt_maximizacao.log-calcula-height = yes.
        end.
        for each tt_maximizacao
           where tt_maximizacao.tipo-widget <> 'browse'
             and not (    tt_maximizacao.row-original >= b_tt_maximizacao.row-original
                      and tt_maximizacao.row-original + tt_maximizacao.height-original < b_tt_maximizacao.row-original + b_tt_maximizacao.height-original
                      and tt_maximizacao.col-original >= b_tt_maximizacao.col-original
                      and tt_maximizacao.col-original + tt_maximizacao.width-original < b_tt_maximizacao.col-original + b_tt_maximizacao.width-original )
             and ((    tt_maximizacao.row-original >= b_tt_maximizacao.row-original
                   and tt_maximizacao.row-original < b_tt_maximizacao.row-original + b_tt_maximizacao.height-original - 0.5 )
              or (     tt_maximizacao.row-original < b_tt_maximizacao.row-original
                   and tt_maximizacao.row-original + tt_maximizacao.height-original > b_tt_maximizacao.row-original )):
            assign tt_maximizacao.log-posiciona-col = yes.
        end.
    end. 
    for each tt_maximizacao
       where tt_maximizacao.tipo-widget = 'rectangle':
        if tt_maximizacao.frame-width-original - tt_maximizacao.width-original < 4 then do:
            assign tt_maximizacao.log-posiciona-col  = no.
            assign tt_maximizacao.log-calcula-width  = yes.
        end.
    end.
    assign wh_w_program:max-width-chars = 300 
           wh_w_program:max-height-chars = 300.

&endif

    if  valid-handle (wh_w_program)
    then do:
        assign current-window = wh_w_program:handle.
    end /* if */.
END. /* ON ENTRY OF wh_w_program */

ON WINDOW-CLOSE OF wh_w_program
DO:

    apply "choose" to bt_exi in frame f_bas_10_concilia_acr_fat.

END. /* ON WINDOW-CLOSE OF wh_w_program */

END.

/**************************** Window Trigger End ****************************/

/**************************** Menu Trigger Begin ****************************/


ON CHOOSE OF MENU-ITEM mi_exi IN MENU m_10
DO:

    apply "choose" to bt_exi in frame f_bas_10_concilia_acr_fat.

END. /* ON CHOOSE OF MENU-ITEM mi_exi IN MENU m_10 */

ON CHOOSE OF MENU-ITEM mi_contents IN MENU m_10
DO:

    apply "choose" to bt_hel1 in frame f_bas_10_concilia_acr_fat.

END. /* ON CHOOSE OF MENU-ITEM mi_contents IN MENU m_10 */

ON CHOOSE OF MENU-ITEM mi_about IN MENU m_10
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


    /* Begin_Include: i_about_call */
    assign v_nom_prog     = substring(current-window:title, 1, max(1, length(current-window:title) - 10))
                          + chr(10)
                          + "fnc_conc_oper_acr_fat_novo":U
           v_nom_prog_ext = "prgfin/acr/acr427za.p":U
           v_cod_release  = trim(" 1.00.00.001":U).
/*    run prgtec/btb/btb901zb.p (Input v_nom_prog,
                               Input v_nom_prog_ext,
                               Input v_cod_release) /*prg_fnc_about*/. */
{include/sobre5.i}
    /* End_Include: i_about_call */

END. /* ON CHOOSE OF MENU-ITEM mi_about IN MENU m_10 */

ON CHOOSE OF MENU-ITEM mi_detalhe_titulo IN MENU m_detalhe
DO:

    if avail tt_concil_acr_fat then do:
        find first tit_acr no-lock
            where tit_acr.cod_estab = tt_concil_acr_fat.tta_cod_estab
            and   tit_acr.cod_espec_docto = tt_concil_acr_fat.tta_cod_espec_docto
            and   tit_acr.cod_ser_docto = tt_concil_acr_fat.tta_cod_ser_docto
            and   tit_acr.cod_tit_acr = tt_concil_acr_fat.tta_cod_tit_acr
            and   tit_acr.cod_parcela = tt_concil_acr_fat.tta_cod_parcela no-error.
        if avail tit_acr then do:
            assign v_rec_tit_acr = recid(tit_acr).
            if  search("prgfin/acr/acr212aa.r") = ? and search("prgfin/acr/acr212aa.p") = ? then do:
                if  v_cod_dwb_user begins 'es_' then
                    return "Programa executòvel n∆o foi encontrado:" /*l_programa_nao_encontrado*/  + "prgfin/acr/acr212aa.p".
                else do:
                    message "Programa executòvel n∆o foi encontrado:" /*l_programa_nao_encontrado*/  "prgfin/acr/acr212aa.p"
                           view-as alert-box error buttons ok.
                    return.
                end.
            end.
            else
                run prgfin/acr/acr212aa.p /*prg_bas_tit_acr_fin*/.
        end.
    end.
END. /* ON CHOOSE OF MENU-ITEM mi_detalhe_titulo IN MENU m_detalhe */

ON CHOOSE OF MENU-ITEM mi_detalhe_nota IN MENU m_detalhe
DO:

    if avail tt_concil_acr_fat then do:
        run pi_detalhe_nota_fiscal in v_hdl_prog_ems2 (input  tt_concil_acr_fat.tta_cod_estab,
                                                       input  tt_concil_acr_fat.tta_cod_espec_docto,
                                                       input  tt_concil_acr_fat.tta_cod_ser_docto,
                                                       input  tt_concil_acr_fat.tta_cod_tit_acr,
                                                       input  tt_concil_acr_fat.tta_cod_parcela,
                                                       input this-procedure:handle).
    end.

END. /* ON CHOOSE OF MENU-ITEM mi_detalhe_nota IN MENU m_detalhe */


/***************************** Menu Trigger End *****************************/


/****************************** Main Code Begin *****************************/


/* Begin_Include: i_version_extract */
{include/i-ctrlrp5.i fnc_conc_oper_acr_fat_novo}


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
    run pi_version_extract ('fnc_conc_oper_acr_fat_novo':U, 'prgfin/acr/acr427za.p':U, '1.00.00.001':U, 'pro':U).
end /* if */.



/* End_Include: i_version_extract */

if  search("prgtec/btb/btb906za.r") = ? and search("prgtec/btb/btb906za.py") = ? then do:
    if  v_cod_dwb_user begins 'es_' then
        return "Programa executòvel n∆o foi encontrado:" /*l_programa_nao_encontrado*/  + "prgtec/btb/btb906za.py".
    else do:
        message "Programa executòvel n∆o foi encontrado:" /*l_programa_nao_encontrado*/  "prgtec/btb/btb906za.py"
               view-as alert-box error buttons ok.
        stop.
    end.
end.
else
    run prgtec/btb/btb906za.py /*prg_fnc_verify_controls*/.

/* Begin_Include: i_verify_security */
if  search("prgtec/men/men901za.r") = ? and search("prgtec/men/men901za.py") = ? then do:
    if  v_cod_dwb_user begins 'es_' then
        return "Programa executòvel n∆o foi encontrado:" /*l_programa_nao_encontrado*/  + "prgtec/men/men901za.py".
    else do:
        message "Programa executòvel n∆o foi encontrado:" /*l_programa_nao_encontrado*/  "prgtec/men/men901za.py"
               view-as alert-box error buttons ok.
        return.
    end.
end.
else
    run prgtec/men/men901za.py (Input 'fnc_conc_oper_acr_fat_novo') /*prg_fnc_verify_security*/.
if  return-value = "2014"
then do:
    /* Programa a ser executado n∆o Ç um programa vòlido Datasul ! */
    run pi_messages (input "show",
                     input 2014,
                     input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9",
                                       'fnc_conc_oper_acr_fat_novo')) /*msg_2014*/.
    return.
end /* if */.
if  return-value = "2012"
then do:
    /* Usuòrio sem permiss o para acessar o programa. */
    run pi_messages (input "show",
                     input 2012,
                     input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9",
                                       'fnc_conc_oper_acr_fat_novo')) /*msg_2012*/.
    return.
end /* if */.
/* End_Include: i_verify_security */



/* Begin_Include: i_log_exec_prog_dtsul_ini */
assign v_rec_log = ?.

if can-find(prog_dtsul
       where prog_dtsul.cod_prog_dtsul = 'fnc_conc_oper_acr_fat_novo' 
         and prog_dtsul.log_gera_log_exec = yes) then do transaction:
    create log_exec_prog_dtsul.
    assign log_exec_prog_dtsul.cod_prog_dtsul           = 'fnc_conc_oper_acr_fat_novo'
           log_exec_prog_dtsul.cod_usuario              = v_cod_usuar_corren
           log_exec_prog_dtsul.dat_inic_exec_prog_dtsul = today
           log_exec_prog_dtsul.hra_inic_exec_prog_dtsul = replace(string(time,"hh:mm:ss" /*l_hh:mm:ss*/ ),":":U,"":U).
    assign v_rec_log = recid(log_exec_prog_dtsul).
    release log_exec_prog_dtsul no-error.
end.


/* End_Include: i_log_exec_prog_dtsul_ini */


/* Begin_Include: i_verify_program_epc */
&if '{&emsbas_version}' > '1.00' &then
assign v_rec_table_epc = ?
       v_wgh_frame_epc = ?.

find prog_dtsul
    where prog_dtsul.cod_prog_dtsul = "fnc_conc_oper_acr_fat_novo":U
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


assign v_wgh_frame_epc = frame f_bas_10_concilia_acr_fat:handle.



assign v_nom_table_epc = 'cta_ctbl':U
       v_rec_table_epc = recid(cta_ctbl).

&endif

/* End_Include: i_verify_program_epc */


/* Begin_Include: i_declara_SetEntryField */
FUNCTION SetEntryField RETURNS CHARACTER (input p_num_posicao     AS INTEGER,
                                          input p_cod_campo       AS CHARACTER,
                                          input p_cod_separador   AS CHARACTER,
                                          input p_cod_valor       AS CHARACTER):

/* ************* Parametros da FUN¯∞O *******************************
** Funá∆o para tratamento dos Entries dos c´digos livres
** 
**  p_num_posicao     - Nﬂmero do Entry / Posiá∆o que serò atualizado
**  p_cod_campo       - Campo / Variòvel que serò atualizada
**  p_cod_separador   - Separador que serò utilizado
**  p_cod_valor       - Valor que serò atualizado no Entry passado 
*******************************************************************/

    def var v_num_cont        as integer initial 0 no-undo.
    def var v_num_entries_ini as integer initial 0 no-undo.

    /* ** No progress a menor Entry Ç 1 ***/
    if p_num_posicao <= 0 then 
       assign p_num_posicao = 1.       

    /* ** Caso o Campo contenha um valor invòlido, este valor serò convertido para Branco
         para possibilitar os còlculo ***/
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


/* Begin_Include: i_declara_GetEntryField */
FUNCTION GetEntryField RETURNS CHARACTER (input p_num_posicao     AS INTEGER,
                                          INPUT p_cod_campo       AS CHARACTER,
                                          input p_cod_separador   AS CHARACTER):

/* ************* Parametros da FUN¯∞O *******************************
** Funá∆o para tratamento dos Entries dos c´digos livres
** 
**  p_num_posicao     - Nﬂmero do Entry que serò atualizado
**  p_cod_campo       - Campo / Variòvel que serò atualizada
**  p_cod_separador   - Separador que serò utilizado
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



/* Begin_Include: i_std_window */
/* tratamento do T°tulo, menu, vers o e dimens¥es */
assign wh_w_program:title         = frame f_bas_10_concilia_acr_fat:title
                                  + chr(32)
                                  + chr(40)
                                  + trim(" 1.00.00.001":U)
                                  + chr(41)
       frame f_bas_10_concilia_acr_fat:title       = ?
       wh_w_program:width-chars   = frame f_bas_10_concilia_acr_fat:width-chars
       wh_w_program:height-chars  = frame f_bas_10_concilia_acr_fat:height-chars - 0.85
       frame f_bas_10_concilia_acr_fat:row         = 1
       frame f_bas_10_concilia_acr_fat:col         = 1
       wh_w_program:menubar       = menu m_10:handle
       wh_w_program:col           = max((session:width-chars - wh_w_program:width-chars) / 2, 1)
       wh_w_program:row           = max((session:height-chars - wh_w_program:height-chars) / 2, 1)
       current-window             = wh_w_program.

find first modul_dtsul
    where modul_dtsul.cod_modul_dtsul = v_cod_modul_dtsul_corren
    no-lock no-error.
if  avail modul_dtsul
then do:
    if  wh_w_program:load-icon (modul_dtsul.img_icone) = yes
    then do:
        /* Utiliza como cone sempre o cone do m´dulo corrente */
    end /* if */.
end /* if */.

/* End_Include: i_std_window */
{include/title5.i wh_w_program}

assign menu m_detalhe:popup-only = yes
       br_concil_acr_fat:POPUP-MENU IN FRAME f_bas_10_concilia_acr_fat = MENU m_detalhe:HANDLE.

&if defined(BF_FIN_CONCIL_CONTABEIS) &then
    assign cta_ctbl.cod_cta_ctbl:label in frame f_ran_01_concilia_acr_fat = "Conta Transit´ria" /*l_cta_transit*/ .
&endif

find param_integr_ems no-lock where param_integr_ems.ind_param_integr_ems = "Faturamento 2.00" /*l_faturamento_2.00*/  no-error.
if not avail param_integr_ems then do:
    /* Par¸metro de integraá∆o com faturamento n∆o encontrado ! */
    run pi_messages (input "show",
                     input 12483,
                     input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")) /*msg_12483*/.
    return.
end.
else assign v_cod_matriz_trad_org_ext = param_integr_ems.des_contdo_param_integr_ems.

find tip_unid_organ no-lock where tip_unid_organ.num_niv_unid_organ = 999 no-error. 
if not avail tip_unid_organ then do:
    /* Tipo de Unidade Organizacional Inexistente ! */
    run pi_messages (input "show",
                     input 301,
                     input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")) /*msg_301*/.
    return.
end.
find first matriz_trad_org_ext no-lock
    where matriz_trad_org_ext.cod_matriz_trad_org_ext = v_cod_matriz_trad_org_ext no-error.
find first unid_organ no-lock
    where unid_organ.cod_unid_organ = v_cod_empres_usuar no-error.
if avail unid_organ then
    assign v_cod_unid_organ = unid_organ.cod_unid_organ.

if v_dat_inicial = ? then
    assign v_dat_inicial = today - 30.
if v_dat_fim = ? then 
    assign v_dat_fim = today.
/* * Conecta Bases Externas **/
if  search("prgint/utb/utb720za.r") = ? and search("prgint/utb/utb720za.py") = ? then do:
    if  v_cod_dwb_user begins 'es_' then
        return "Programa executòvel n∆o foi encontrado:" /*l_programa_nao_encontrado*/  + "prgint/utb/utb720za.py".
    else do:
        message "Programa executòvel n∆o foi encontrado:" /*l_programa_nao_encontrado*/  "prgint/utb/utb720za.py"
               view-as alert-box error buttons ok.
        return.
    end.
end.
else
    run prgint/utb/utb720za.py (Input 1,
                            Input "On-Line" /*l_online*/,
                            output v_log_connect_ems2_ok,
                            output v_log_connect) /*prg_fnc_conecta_bases_externas*/.
if  v_log_connect         = no
and v_log_connect_ems2_ok = no then do:
    if  search("prgint/utb/utb720za.r") = ? and search("prgint/utb/utb720za.py") = ? then do:
        if  v_cod_dwb_user begins 'es_' then
            return "Programa executòvel n∆o foi encontrado:" /*l_programa_nao_encontrado*/  + "prgint/utb/utb720za.py".
        else do:
            message "Programa executòvel n∆o foi encontrado:" /*l_programa_nao_encontrado*/  "prgint/utb/utb720za.py"
                   view-as alert-box error buttons ok.
            return.
        end.
    end.
    else
        run prgint/utb/utb720za.py (Input 2,
                                Input "On-Line" /*l_online*/,
                                output v_log_connect_ems2_ok,
                                output v_log_connect) /*prg_fnc_conecta_bases_externas*/.
    return.
end.
&if defined(BF_FIN_CONCIL_CONTABEIS) &then
    assign v_des_estab_select = ''.
    run pi_vld_permissao_usuar_estab_empres (Input "ACR" /*l_acr*/  ).
&endif 

/* Evitar erro ao executar direto o relat´rio caso o esteja selecionado pra gerar Excel */
assign v_log_gerac_planilha = no.

/* * Roda persistente programa de conciliaÓ“o do faturamento **/
run intprg/nicr010a.p persistent set v_hdl_prog_ems2.

pause 0 before-hide.
view frame f_bas_10_concilia_acr_fat.

/* Begin_Include: i_executa_pi_epc_fin */
run pi_exec_program_epc_FIN (Input 'INITIALIZE',
                             Input 'no',
                             output v_log_return_epc) /*pi_exec_program_epc_FIN*/.
if v_log_return_epc then /* epc retornou erro*/
    undo, retry.
/* End_Include: i_executa_pi_epc_fin */

enable all
    with frame f_bas_10_concilia_acr_fat.
&if defined(BF_FIN_CONCIL_CONTABEIS) &then
    assign bt_pri:visible in frame f_bas_10_concilia_acr_fat = no.         
&endif        

/* Begin_Include: i_executa_pi_epc_fin */
run pi_exec_program_epc_FIN (Input 'ENABLE',
                             Input 'no',
                             output v_log_return_epc) /*pi_exec_program_epc_FIN*/.
if v_log_return_epc then /* epc retornou erro*/
    undo, retry.
/* End_Include: i_executa_pi_epc_fin */

assign br_concil_acr_fat:allow-column-searching in frame f_bas_10_concilia_acr_fat = yes.

if v_dat_inicial = ? then do:
    assign v_dat_aux = date(month(today), 01, year(today)).
    assign v_dat_inicial = v_dat_aux.
end.

if v_dat_fim = 12/31/9999 then 
    assign v_dat_fim = today.

main_block:
do on endkey undo main_block, leave main_block
                on error undo main_block, leave main_block.
    if  this-procedure:persistent = no
    then do:
        wait-for choose of bt_exi in frame f_bas_10_concilia_acr_fat.
    end.
end /* do main_block */.


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

return.


/******************************* Main Code End ******************************/

/************************* Internal Procedure Begin *************************/

/*****************************************************************************
** Procedure Interna.....: pi_exec_program_epc_FIN
** Descricao.............: pi_exec_program_epc_FIN
** Criado por............: src388
** Criado em.............: 09/09/2003 10:48:55
** Alterado por..........: fut1309
** Alterado em...........: 15/02/2006 09:44:03
*****************************************************************************/
PROCEDURE pi_exec_program_epc_FIN:

    /************************ Parameter Definition Begin ************************/

    def Input param p_cod_event
        as character
        format "x(100)"
        no-undo.
    def Input param p_cod_return
        as character
        format "x(40)"
        no-undo.
    def output param p_log_return_epc
        as logical
        format "Sim/n∆o"
        no-undo.


    /************************* Parameter Definition End *************************/

    /* *******************************************************************************************
    ** Objetivo..............: Substituir o c´digo gerado pela include i_exec_program_epc,
    **                         muitas vezes repetido, com o intuito de evitar estouro de segmento.
    **
    ** Utilizaá∆o............: A utilizaá∆o desta procedure funciona exatamente como a include
    **                         anteriormente utilizada para este fim, para chamar ela deve ser 
    **                         includa a include i_executa_pi_epc_fin no programa, que ira executar 
    **                         esta pi e fazer tratamento para os retornos. Deve ser declarada a 
    **                         variavel v_log_return_epc (caso o parametro ela seja verdade, Ç 
    **                         porque a EPC retornou "NOK". 
    **
    **                         @i(i_executa_pi_epc_fin &event='INITIALIZE' &return='NO')
    **
    **                         Para se ter uma idÇia de como se usa, favor olhar o fonte do apb008za.p
    **
    **
    *********************************************************************************************/

    assign p_log_return_epc = no.
    /* ix_iz1_fnc_conc_oper_acr_fat_novo */


    /* Begin_Include: i_exec_program_epc_pi_fin */
    if  v_nom_prog_upc <> ''    
    or  v_nom_prog_appc <> ''
    or  v_nom_prog_dpc <> '' then do:
        &if 'cta_ctbl' <> '' &then
            assign v_rec_table_epc = recid(cta_ctbl)
                   v_nom_table_epc = 'cta_ctbl'.
        &else
            assign v_rec_table_epc = ?
                   v_nom_table_epc = "".
        &endif
    end.
    &if '{&emsbas_version}' > '1.00' &then
    if  v_nom_prog_upc <> '' and not p_log_return_epc
    then do:
        run value(v_nom_prog_upc) (input p_cod_event,
                                   input 'viewer',
                                   input this-procedure,
                                   input v_wgh_frame_epc,
                                   input v_nom_table_epc,
                                   input v_rec_table_epc).
        if  p_cod_return = "yes" /*l_yes*/ 
        and return-value = "NOK" /*l_nok*/  then
            assign p_log_return_epc = yes.
    end /* if */.

    if  v_nom_prog_appc <> '' and not p_log_return_epc
    then do:
        run value(v_nom_prog_appc) (input p_cod_event,
                                    input 'viewer',
                                    input this-procedure,
                                    input v_wgh_frame_epc,
                                    input v_nom_table_epc,
                                    input v_rec_table_epc).
        if  p_cod_return = "yes" /*l_yes*/ 
        and return-value = "NOK" /*l_nok*/  then
            assign p_log_return_epc = yes.
    end /* if */.

    &if '{&emsbas_version}' > '5.00' &then
    if  v_nom_prog_dpc <> '' and not p_log_return_epc
    then do:
        run value(v_nom_prog_dpc) (input p_cod_event,
                                    input 'viewer',
                                    input this-procedure,
                                    input v_wgh_frame_epc,
                                    input v_nom_table_epc,
                                    input v_rec_table_epc).
        if  p_cod_return = "yes" /*l_yes*/ 
        and return-value = "NOK" /*l_nok*/  then
            assign p_log_return_epc = yes.
    end /* if */.
    &endif
    &endif

    /* End_Include: i_exec_program_epc_pi_fin */


    /* ix_iz2_fnc_conc_oper_acr_fat_novo */
END PROCEDURE. /* pi_exec_program_epc_FIN */
/*****************************************************************************
** Procedure Interna.....: pi_traduz_estabelecimento
** Descricao.............: pi_traduz_estabelecimento
** Criado por............: fut1090
** Criado em.............: 11/10/2004 12:19:31
** Alterado por..........: fut1090
** Alterado em...........: 02/12/2004 13:35:19
*****************************************************************************/
PROCEDURE pi_traduz_estabelecimento:

    /************************ Parameter Definition Begin ************************/

    def Input param p_num_tip_trad
        as integer
        format ">>9"
        no-undo.
    def Input param p_cod_estab
    &IF "{&emsuni_version}" >= "" AND "{&emsuni_version}" < "5.07A" &THEN
        as character
        format "x(3)"
    &ENDIF
    &IF "{&emsuni_version}" >= "5.07A" AND "{&emsuni_version}" < "9.99" &THEN
        as Character
        format "x(5)"
    &ENDIF
        no-undo.
    def output param p_cod_estab_ext
        as character
        format "x(8)"
        no-undo.


    /************************* Parameter Definition End *************************/

    /* p_num_tip_trad   
       Case 1 - Traduz o estabelecimento que veio no par¸metro, encontrando o estabelecimento do EMS2
       Case 2 - Traduz o estabelecimento que veio no par¸metro, encontrando o estabelecimento do EMS5
    */

    if p_num_tip_trad = 1 then do:
        find first trad_org_ext no-lock
             where trad_org_ext.cod_matriz_trad_org_ext = param_integr_ems.des_contdo_param_integr_ems
             and   trad_org_ext.cod_tip_unid_organ      = tip_unid_organ.cod_tip_unid_organ
             and   trad_org_ext.cod_unid_organ          = p_cod_estab no-error.
        if avail trad_org_ext then
            assign p_cod_estab_ext = trad_org_ext.cod_unid_organ_ext.
    end.
    else do:    
        find first trad_org_ext no-lock
             where trad_org_ext.cod_matriz_trad_org_ext = param_integr_ems.des_contdo_param_integr_ems
             and   trad_org_ext.cod_tip_unid_organ      = tip_unid_organ.cod_tip_unid_organ
             and   trad_org_ext.cod_unid_organ_ext      = p_cod_estab   no-error.
        if avail trad_org_ext then
            assign p_cod_estab_ext = trad_org_ext.cod_unid_organ.
    end.

END PROCEDURE. /* pi_traduz_estabelecimento */
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
    &IF "{&emsuni_version}" >= "" AND "{&emsuni_version}" < "5.07A" &THEN
        as character
        format "x(3)"
    &ENDIF
    &IF "{&emsuni_version}" >= "5.07A" AND "{&emsuni_version}" < "9.99" &THEN
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
** Procedure Interna.....: pi_monta_temp_table_concil_acr_fat
** Descricao.............: pi_monta_temp_table_concil_acr_fat
** Criado por............: fut1090
** Criado em.............: 23/08/2004 14:15:25
** Alterado por..........: fut42929
** Alterado em...........: 01/02/2013 10:14:26
*****************************************************************************/
PROCEDURE pi_monta_temp_table_concil_acr_fat:

    /************************* Variable Definition Begin ************************/

    def var v_des_help
        as character
        format "x(40)":U
        view-as editor max-chars 2000 scrollbar-vertical
        size 70 by 5
        bgcolor 15 font 2
        label "Ajuda"
        column-label "Ajuda"
        no-undo.
    def var v_cod_estab                      as character       no-undo. /*local*/
    def var v_cod_estab_aux                  as character       no-undo. /*local*/
    def var v_log_fatur                      as logical         no-undo. /*local*/
    def var v_log_nota                       as logical         no-undo. /*local*/
    def var v_val_origin_tit_acr             as decimal         no-undo. /*local*/

    DEF VAR valTotAgrupados                  LIKE tit_acr_cartao.val_comprov_vda NO-UNDO. /*local*/


    /************************** Variable Definition End *************************/

    assign v_num_tit_acr_concil = 0.

    for each tt_fat:
        find first trad_org_ext no-lock
             where trad_org_ext.cod_matriz_trad_org_ext = param_integr_ems.des_contdo_param_integr_ems and
                   trad_org_ext.cod_tip_unid_organ      = tip_unid_organ.cod_tip_unid_organ            and 
                   trad_org_ext.cod_unid_organ_ext      = tt_fat.ttv_cod_estab                 no-error.
        if avail trad_org_ext then
            assign v_cod_estab = trad_org_ext.cod_unid_organ.
        else do:
            create tt_concil_acr_fat.
            assign tt_concil_acr_fat.tta_cod_estab       = tt_fat.ttv_cod_estab
                   tt_concil_acr_fat.tta_cod_espec_docto = tt_fat.ttv_cod_espec_docto
                   tt_concil_acr_fat.tta_cod_ser_docto   = tt_fat.ttv_cod_ser_docto
                   tt_concil_acr_fat.tta_cod_tit_acr     = tt_fat.ttv_cod_tit_acr
                   tt_concil_acr_fat.tta_cod_parcela     = tt_fat.ttv_cod_parcela
                   tt_concil_acr_fat.ttv_log_erro        = yes
                   tt_concil_acr_fat.ttv_des_erro        = "Traduá∆o do estabelecimento n∆o encontrada." /*l_traducao_estabelecimento*/ .
            next.
        end.

        create tt_concil_acr_fat.
        assign tt_concil_acr_fat.tta_cod_estab = v_cod_estab
               tt_concil_acr_fat.tta_cod_espec_docto = tt_fat.ttv_cod_espec_docto
               tt_concil_acr_fat.tta_cod_ser_docto   = tt_fat.ttv_cod_ser_docto
               tt_concil_acr_fat.tta_cod_tit_acr     = tt_fat.ttv_cod_tit_acr
               tt_concil_acr_fat.tta_cod_parcela     = tt_fat.ttv_cod_parcela
               tt_concil_acr_fat.ttv_val_acr = 0
               tt_concil_acr_fat.ttv_val_faturam = 0
               tt_concil_acr_fat.ttv_val_dif_acr_faturam = 0
               tt_concil_acr_fat.ttv_log_erro = no.

            find first tt_acr
                 where tt_acr.ttv_cod_estab   = v_cod_estab
                 and   tt_acr.ttv_cod_espec_docto = tt_fat.ttv_cod_espec_docto
                 and   tt_acr.ttv_cod_ser_docto = tt_fat.ttv_cod_ser_docto
                 and   tt_acr.ttv_cod_tit_acr = tt_fat.ttv_cod_proces_export
                 and   tt_acr.ttv_cod_parcela = tt_fat.ttv_cod_parcela no-error.
            if  not avail tt_acr then
                find first tit_acr no-lock
                     where tit_acr.cod_estab   = v_cod_estab
                     and   tit_acr.cod_esp     = tt_fat.ttv_cod_espec_docto
                     and   tit_acr.cod_ser     = tt_fat.ttv_cod_ser_docto
                     and   tit_acr.cod_tit_acr = tt_fat.ttv_cod_proces_export
                     and   tit_acr.cod_parcela = tt_fat.ttv_cod_parcela no-error. 
            if not avail tit_acr then
                find first tt_acr
                 where tt_acr.ttv_cod_estab   = v_cod_estab
                 and   tt_acr.ttv_cod_espec_docto = tt_fat.ttv_cod_espec_docto
                 and   tt_acr.ttv_cod_ser_docto = tt_fat.ttv_cod_ser_docto
                 and   tt_acr.ttv_cod_tit_acr = tt_fat.ttv_cod_tit_acr
                 and   tt_acr.ttv_cod_parcela = tt_fat.ttv_cod_parcela no-error.
            if not avail tt_acr then do:
                find first tit_acr no-lock
                     where tit_acr.cod_estab   = v_cod_estab
                     and   tit_acr.cod_esp     = tt_fat.ttv_cod_espec_docto
                     and   tit_acr.cod_ser     = tt_fat.ttv_cod_ser_docto
                     and   tit_acr.cod_tit_acr = tt_fat.ttv_cod_tit_acr
                     and   tit_acr.cod_parcela = tt_fat.ttv_cod_parcela no-error.             
                if avail tit_acr then do:
                assign v_val_origin_tit_acr = 0
                       tt_concil_acr_fat.ttv_num_tit_acr_concil = tt_concil_acr_fat.ttv_num_tit_acr_concil + 1.
                for each tt_cta_ctbl_concilia_acr:
                    find first movto_tit_acr no-lock
                        where movto_tit_acr.cod_estab = tit_acr.cod_estab
                        and   movto_tit_acr.num_id_tit_acr = tit_acr.num_id_tit_acr no-error.
                    if avail movto_tit_acr then do:
                        for each aprop_ctbl_acr of movto_tit_acr no-lock
                            where aprop_ctbl_acr.ind_natur_lancto_ctbl = "CR" /*l_cr*/ 
                            and   aprop_ctbl_acr.cod_cta_ctbl = tt_cta_ctbl_concilia_acr.tta_cod_cta_ctbl:
                            run pi_retornar_finalid_econ_corren_estab (Input tit_acr.cod_estab,
                                                                       output v_cod_finalid_econ) .                         
                            for each val_aprop_ctbl_acr of aprop_ctbl_acr no-lock
                                where val_aprop_ctbl_acr.cod_finalid_econ = v_cod_finalid_econ:
                                assign v_val_origin_tit_acr = v_val_origin_tit_acr + val_aprop_ctbl_acr.val_aprop_ctbl.
                            end.
                        END.
                    END.
                end.
                if  tt_fat.ttv_val_orig <> v_val_origin_tit_acr then do:
                    run pi_messages (input 'help',
                                     input 21290,
                                     input substitute ('&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9')).
                    assign v_des_help = substitute(return-value, STRING(v_val_origin_tit_acr, '-zzzz,zzz,zz9.99'), STRING(tt_fat.ttv_val_orig, '-zzzz,zzz,zz9.99')).
                    assign tt_concil_acr_fat.ttv_val_acr = v_val_origin_tit_acr
                           tt_concil_acr_fat.ttv_val_faturam = tt_fat.ttv_val_orig
                           tt_concil_acr_fat.ttv_val_dif_acr_faturam = tt_fat.ttv_val_orig - v_val_origin_tit_acr
                           tt_concil_acr_fat.ttv_log_erro = yes
                           tt_concil_acr_fat.ttv_des_erro = v_des_help.
                end.
                if tit_acr.ind_orig_tit_acr <> "FATEMS20" /*l_fatems20*/  then do:
                    run pi_messages (input 'help',
                                     input 21291,
                                     input substitute ('&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9')).
                    assign v_des_help = substitute(return-value, tit_acr.ind_orig_tit_acr).
                    assign tt_concil_acr_fat.ttv_des_erro               = tt_concil_acr_fat.ttv_des_erro + chr(10) + v_des_help
                           tt_concil_acr_fat.ttv_num_tit_acr_concil_dif = tt_concil_acr_fat.ttv_num_tit_acr_concil_dif + 1.
                end.
                else do:
                    find first movto_tit_acr no-lock
                        where movto_tit_acr.cod_estab = tit_acr.cod_estab
                        and   movto_tit_acr.num_id_tit_acr = tit_acr.num_id_tit_acr no-error.
                    if avail movto_tit_acr then do:
                        find first aprop_ctbl_acr of movto_tit_acr no-lock
                            where aprop_ctbl_acr.ind_natur_lancto_ctbl = "CR" /*l_cr*/  no-error.
                        if avail aprop_ctbl_acr then do:
                            run pi_messages (input 'help',
                                             input 21292,
                                             input substitute ('&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9')).
                            assign v_des_help = substitute(return-value, string(aprop_ctbl_acr.cod_cta_ctbl,plano_cta_ctbl.cod_format_cta_ctbl)).
                            assign tt_concil_acr_fat.ttv_des_erro = v_des_help
                                   tt_concil_acr_fat.ttv_val_faturam = tt_fat.ttv_val_orig
                                   tt_concil_acr_fat.ttv_val_acr = tit_acr.val_origin_tit_acr
                                   tt_concil_acr_fat.ttv_val_dif_acr_faturam = tt_fat.ttv_val_orig - tit_acr.val_origin_tit_acr
                                   v_val_tit_acr_concil = v_val_tit_acr_concil + tit_acr.val_origin_tit_acr
                                   v_val_tot_nota_concil_faturam = v_val_tot_nota_concil_faturam + tt_fat.ttv_val_orig.

                            if tit_acr.val_origin_tit_acr <> tt_fat.ttv_val_orig then
                                assign tt_concil_acr_fat.ttv_log_erro = yes.
                            else 
                                assign tt_concil_acr_fat.ttv_log_erro = no.                       
                        end.
                    end.
                end.
            end.
            else do:
                find item_lote_impl_tit_acr no-lock
                    where item_lote_impl_tit_acr.cod_estab       = v_cod_estab
                      and item_lote_impl_tit_acr.cod_espec_docto = tt_fat.ttv_cod_espec_docto
                      and item_lote_impl_tit_acr.cod_ser_docto   = tt_fat.ttv_cod_ser_docto
                      and item_lote_impl_tit_acr.cod_tit_acr     = tt_fat.ttv_cod_proces_export
                      and item_lote_impl_tit_acr.cod_parcela     = tt_fat.ttv_cod_parcela 
                    no-error.
                if not avail item_lote_impl_tit_acr then
                    find item_lote_impl_tit_acr no-lock
                        where item_lote_impl_tit_acr.cod_estab       = v_cod_estab
                          and item_lote_impl_tit_acr.cod_espec_docto = tt_fat.ttv_cod_espec_docto
                          and item_lote_impl_tit_acr.cod_ser_docto   = tt_fat.ttv_cod_ser_docto
                          and item_lote_impl_tit_acr.cod_tit_acr     = tt_fat.ttv_cod_tit_acr
                          and item_lote_impl_tit_acr.cod_parcela     = tt_fat.ttv_cod_parcela
                        no-error.
                run pi_messages (input 'help',
                                 input 21293,
                                 input substitute ('&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9')).
                assign v_des_help = return-value.        
                if not avail item_lote_impl_tit_acr THEN
                    assign tt_concil_acr_fat.ttv_log_erro                    = yes
                           tt_concil_acr_fat.ttv_des_erro                    = v_des_help
                           tt_concil_acr_fat.ttv_val_faturam                 = tt_fat.ttv_val_orig
                           tt_concil_acr_fat.ttv_val_dif_acr_faturam         = tt_fat.ttv_val_orig
                           v_val_tot_nota_concil_faturam                     = v_val_tot_nota_concil_faturam + tt_fat.ttv_val_orig
                           tt_concil_acr_fat.ttv_num_nota_concil_faturam_dif = tt_concil_acr_fat.ttv_num_nota_concil_faturam_dif + 1.
                ELSE DO:
                    run pi_messages (input 'help',
                                     input 21294,
                                     input substitute ('&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9')).
                    assign v_des_help = return-value.
                    assign tt_concil_acr_fat.ttv_log_erro                = yes
                           tt_concil_acr_fat.ttv_des_erro                = v_des_help
                           tt_concil_acr_fat.ttv_val_faturam             = tt_fat.ttv_val_orig
                           tt_concil_acr_fat.ttv_val_dif_acr_faturam     = tt_fat.ttv_val_orig
                           tt_concil_acr_fat.ttv_val_acr                 = item_lote_impl_tit_acr.val_tit_acr
                           v_val_tit_acr_concil                          = v_val_tit_acr_concil + item_lote_impl_tit_acr.val_tit_acr
                           v_val_tot_nota_concil_faturam                 = v_val_tot_nota_concil_faturam + tt_fat.ttv_val_orig
                           tt_concil_acr_fat.ttv_num_tit_acr_concil      = tt_concil_acr_fat.ttv_num_tit_acr_concil + 1.
                END.           
            end.
        end.
        else do:
            assign tt_concil_acr_fat.ttv_num_tit_acr_concil      = tt_concil_acr_fat.ttv_num_tit_acr_concil + 1.
            if  tt_fat.ttv_val_orig <> tt_acr.ttv_val_origin_tit_acr then do:
                assign tt_concil_acr_fat.ttv_val_faturam = tt_fat.ttv_val_orig
                       tt_concil_acr_fat.ttv_val_dif_acr_faturam = tt_fat.ttv_val_orig.

                run pi_messages (input 'help',
                                 input 21290,
                                 input substitute ('&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9')).
                assign v_des_help = substitute(return-value, STRING(tt_acr.ttv_val_origin_tit_acr, '-zzzz,zzz,zz9.99'), STRING(tt_fat.ttv_val_orig, '-zzzz,zzz,zz9.99')).
                assign tt_concil_acr_fat.ttv_val_acr = tt_acr.ttv_val_origin_tit_acr
                       tt_concil_acr_fat.ttv_val_faturam = tt_fat.ttv_val_orig
                       tt_concil_acr_fat.ttv_val_dif_acr_faturam = tt_fat.ttv_val_orig - tt_acr.ttv_val_origin_tit_acr
                       tt_concil_acr_fat.ttv_log_erro = yes
                       tt_concil_acr_fat.ttv_des_erro = v_des_help
                       v_val_tit_acr_concil = v_val_tit_acr_concil + tt_acr.ttv_val_origin_tit_acr
                       v_val_tot_nota_concil_faturam = v_val_tot_nota_concil_faturam + tt_fat.ttv_val_orig.
            end.
            else do:
                    ASSIGN tt_concil_acr_fat.ttv_val_acr = tt_acr.ttv_val_origin_tit_acr
                           tt_concil_acr_fat.ttv_val_faturam  = tt_fat.ttv_val_orig
                           tt_concil_acr_fat.ttv_log_erro = no
                           tt_concil_acr_fat.ttv_des_erro = "Integraá∆o OK" /*l_integracao_ok*/ 
                           v_val_tit_acr_concil = v_val_tit_acr_concil + tt_acr.ttv_val_origin_tit_acr
                           v_val_tot_nota_concil_faturam = v_val_tot_nota_concil_faturam + tt_fat.ttv_val_orig.
            end.
        end.
    end.

    &if defined(BF_FIN_CONCIL_CONTABEIS) &then
        run pi_monta_temp_table_concilia_fat_lista in v_hdl_prog_ems2 (input  v_dat_inicial,
                                                                       input  v_dat_fim,
                                                                       input  v_des_estab_select,
                                                                       input table tt_acr,
                                                                       input table tt_fat,
                                                                       input this-procedure:handle,
                                                                       input-output table tt_concil_acr_fat,
                                                                       input-output v_val_tit_acr_concil,
                                                                       input-output v_val_tot_nota_concil_faturam).
    &else                                                         
        run pi_monta_temp_table_concilia_fat in v_hdl_prog_ems2 (input  v_dat_inicial,
                                                                 input  v_dat_fim,
                                                                 input  v_cod_estab_inicial,
                                                                 input  v_cod_estab_fim,
                                                                 input table tt_acr,
                                                                 input table tt_fat,
                                                                 input this-procedure:handle,
                                                                 input-output table tt_concil_acr_fat,
                                                                 input-output v_val_tit_acr_concil,
                                                                 input-output v_val_tot_nota_concil_faturam).
    &endif   
                                                          
    /* INICIO -  REALIZA A VERIFICAÄ«O DO AGRUPAMENTO DE CUPOM FISCAL QUE ê REALIZADO DE FORMA ESPECIFICA PARA ATENDER A REGRA DA NISSEI */


    FOR EACH tt_concil_acr_fat
       WHERE tt_concil_acr_fat.tta_cod_espec_docto <> "CV":

        IF CAN-FIND(FIRST tit_acr_cartao NO-LOCK
                    WHERE tit_acr_cartao.cod_estab = tt_concil_acr_fat.tta_cod_estab
                      AND tit_acr_cartao.num_cupom = tt_concil_acr_fat.tta_cod_tit_acr) THEN DO:

           FOR EACH tit_acr_cartao NO-LOCK
               WHERE tit_acr_cartao.cod_estab       = tt_concil_acr_fat.tta_cod_estab
                 AND tit_acr_cartao.num_cupom       = tt_concil_acr_fat.tta_cod_tit_acr
                 AND tit_acr_cartao.val_comprov_vda = tt_concil_acr_fat.ttv_val_faturam,
               FIRST tit_acr NO-LOCK
               WHERE tit_acr.num_id_tit_acr  = tit_acr_cartao.num_id_tit_acr 
                 AND tit_acr.cod_espec_docto = tt_concil_acr_fat.tta_cod_espec_docto :
                  
                
                ASSIGN tt_concil_acr_fat.ttv_des_erro = "Essa Duplicata faz parte do T°tulo Abaixo, devido ao agrupamento realizado.".
                
                ASSIGN tt_concil_acr_fat.ttv_val_acr             = tit_acr_cartao.val_comprov_vda
                       tt_concil_acr_fat.ttv_val_dif_acr_faturam = tt_concil_acr_fat.ttv_val_faturam - tt_concil_acr_fat.ttv_val_acr .
                
                IF tt_concil_acr_fat.ttv_val_dif_acr_faturam = 0 THEN
                    ASSIGN tt_concil_acr_fat.ttv_log_erro = NO.

                /* INICIO - Cria temp-table grid consolidaá∆o agrupamento */
                CREATE tt_concil_tit_agrupa.
                ASSIGN tt_concil_tit_agrupa.cod_estab          = tit_acr.cod_estab      
                       tt_concil_tit_agrupa.cdn_cliente        = tit_acr.cdn_cliente    
                       tt_concil_tit_agrupa.cod_espec_docto    = tit_acr.cod_espec_docto
                       tt_concil_tit_agrupa.cod_ser_docto      = tit_acr.cod_ser_docto  
                       tt_concil_tit_agrupa.cod_tit_acr        = tit_acr.cod_tit_acr    
                       tt_concil_tit_agrupa.cod_parcela        = tit_acr.cod_parcela    
                       tt_concil_tit_agrupa.val_titulo         = tit_acr.val_origin_tit_acr
                       tt_concil_tit_agrupa.row_concil_acr_fat = ROWID(tt_concil_acr_fat)   .
                /* FIM    - Cria temp-table grid consolidaá∆o agrupamento */
            END.
        END.
        ELSE DO:
            IF CAN-FIND(FIRST tit_acr
                        WHERE tit_acr.cod_estab       = tt_concil_acr_fat.tta_cod_estab
                          AND tit_acr.cod_espec_docto = tt_concil_acr_fat.tta_cod_espec_docto
                          AND tit_acr.cod_ser_docto   = tt_concil_acr_fat.tta_cod_ser_docto  
                          AND tit_acr.cod_tit_acr     = tt_concil_acr_fat.tta_cod_tit_acr    
                          AND tit_acr.cod_parcela     = tt_concil_acr_fat.tta_cod_parcela)    THEN DO:

                FIND FIRST tit_acr NO-LOCK
                     WHERE tit_acr.cod_estab       = tt_concil_acr_fat.tta_cod_estab
                       AND tit_acr.cod_espec_docto = tt_concil_acr_fat.tta_cod_espec_docto
                       AND tit_acr.cod_ser_docto   = tt_concil_acr_fat.tta_cod_ser_docto  
                       AND tit_acr.cod_tit_acr     = tt_concil_acr_fat.tta_cod_tit_acr    
                       AND tit_acr.cod_parcela     = tt_concil_acr_fat.tta_cod_parcela    NO-ERROR.
                IF AVAIL tit_acr THEN DO:

                    ASSIGN valTotAgrupados = 0.
                    FOR EACH tit_acr_cartao NO-LOCK
                       WHERE tit_acr_cartao.cod_estab       = tit_acr.cod_estab 
                         AND tit_acr_cartao.num_id_tit_acr  = tit_acr.num_id_tit_acr:

                        ASSIGN valTotAgrupados = valTotAgrupados + tit_acr_cartao.val_comprov_vda.

                        /* INICIO - Cria temp-table grid consolidaá∆o agrupamento */
                        CREATE tt_concil_tit_agrupa.
                        ASSIGN tt_concil_tit_agrupa.cod_estab          = tit_acr.cod_estab      
                               tt_concil_tit_agrupa.cdn_cliente        = tit_acr.cdn_cliente    
                               tt_concil_tit_agrupa.cod_espec_docto    = tit_acr.cod_espec_docto
                               tt_concil_tit_agrupa.cod_ser_docto      = tit_acr.cod_ser_docto  
                               tt_concil_tit_agrupa.cod_tit_acr        = tit_acr_cartao.num_cupom    
                               tt_concil_tit_agrupa.cod_parcela        = tit_acr.cod_parcela    
                               tt_concil_tit_agrupa.val_titulo         = tit_acr_cartao.val_comprov_vda
                               tt_concil_tit_agrupa.row_concil_acr_fat = ROWID(tt_concil_acr_fat)   .
                        /* FIM    - Cria temp-table grid consolidaá∆o agrupamento */

                    END.

                    ASSIGN tt_concil_acr_fat.ttv_des_erro = "Esse T°tulo Ç o agrupamento dos cupons de venda, conforme abaixo.".

                    ASSIGN tt_concil_acr_fat.ttv_val_faturam         = valTotAgrupados
                           tt_concil_acr_fat.ttv_val_dif_acr_faturam = tt_concil_acr_fat.ttv_val_acr - tt_concil_acr_fat.ttv_val_faturam .

                    IF tt_concil_acr_fat.ttv_val_dif_acr_faturam = 0 THEN
                        ASSIGN tt_concil_acr_fat.ttv_log_erro = NO.
                END.
            END.
            ELSE DO:
                ASSIGN tt_concil_acr_fat.ttv_des_erro = tt_concil_acr_fat.ttv_des_erro + " - " + "N∆o foi encontrado agrupamento de titulo para o cupom no ACR.".
            END.
        END.
        
        FIND FIRST fat-duplic NO-LOCK
             WHERE fat-duplic.cod-estabel  = tt_concil_acr_fat.tta_cod_estab          
               AND fat-duplic.cod-esp      = tt_concil_acr_fat.tta_cod_espec_docto   
               AND fat-duplic.serie        = tt_concil_acr_fat.tta_cod_ser_docto     
               AND fat-duplic.nr-fatura    = tt_concil_acr_fat.tta_cod_tit_acr       
               AND fat-duplic.parcela      = tt_concil_acr_fat.tta_cod_parcela 
               AND fat-duplic.flag-atualiz = NO                                     NO-ERROR.
        IF AVAIL fat-duplic THEN DO:
            ASSIGN tt_concil_acr_fat.ttv_des_erro = "Ainda n∆o foi realizado o AGRUPAMENTO para essa duplicata ou o mesmo apresentou ERROS. Favor verificar.".        
        END.       
                
    END.
    /* FIM    -  REALIZA A VERIFICAÄ«O DO AGRUPAMENTO DE CUPOM FISCAL QUE ê REALIZADO DE FORMA ESPECIFICA PARA ATENDER A REGRA DA NISSEI */

END PROCEDURE. /* pi_monta_temp_table_concil_acr_fat */
/*****************************************************************************
** Procedure Interna.....: pi_monta_temp_table_concil_acr
** Descricao.............: pi_monta_temp_table_concil_acr
** Criado por............: fut1090
** Criado em.............: 16/08/2004 19:59:55
** Alterado por..........: fut12235
** Alterado em...........: 06/10/2008 17:05:33
*****************************************************************************/
PROCEDURE pi_monta_temp_table_concil_acr:

    for each tt_cta_ctbl_concilia_acr: 
        for each estabelecimento
            where estabelecimento.cod_estab >= v_cod_estab_inicial
            and   estabelecimento.cod_estab <= v_cod_estab_fim no-lock:
            for each movto_tit_acr no-lock
                where movto_tit_acr.cod_estab = estabelecimento.cod_estab
                and   movto_tit_acr.ind_trans_acr_abrev = "IMPL" /*l_impl*/ 
                and   movto_tit_acr.dat_trans >= v_dat_inicial
                and   movto_tit_acr.dat_trans <= v_dat_fim
                and   movto_tit_acr.log_ctbz_aprop_ctbl = yes:

                find first tit_acr of movto_tit_acr no-lock no-error.            

                for each aprop_ctbl_acr of movto_tit_acr no-lock
                    where aprop_ctbl_acr.ind_natur_lancto_ctbl = "CR" /*l_cr*/ 
                    and   aprop_ctbl_acr.cod_cta_ctbl = tt_cta_ctbl_concilia_acr.tta_cod_cta_ctbl:

                    run pi_retornar_finalid_econ_corren_estab (Input tit_acr.cod_estab,
                                                               output v_cod_finalid_econ). 

                    for each val_aprop_ctbl_acr of aprop_ctbl_acr no-lock
                        where val_aprop_ctbl_acr.cod_finalid_econ = v_cod_finalid_econ:

                        find first tt_acr
                             where tt_acr.ttv_dat_trans   = movto_tit_acr.dat_trans
                             and   tt_acr.ttv_cod_estab   = tit_acr.cod_estab
                             and   tt_acr.ttv_cod_espec_docto = tit_acr.cod_espec_docto
                             and   tt_acr.ttv_cod_ser_docto = tit_acr.cod_ser_docto
                             and   tt_acr.ttv_cod_tit_acr = tit_acr.cod_tit_acr
                             and   tt_acr.ttv_cod_parcela = tit_acr.cod_parcela
                             no-error.
                        if  not avail tt_acr then do:
                            create tt_acr.
                            assign tt_acr.ttv_dat_trans   = movto_tit_acr.dat_trans
                                   tt_acr.ttv_cod_estab   = tit_acr.cod_estab
                                   tt_acr.ttv_cod_espec_docto = tit_acr.cod_espec_docto
                                   tt_acr.ttv_cod_ser_docto = tit_acr.cod_ser_docto
                                   tt_acr.ttv_cod_tit_acr = tit_acr.cod_tit_acr
                                   tt_acr.ttv_cod_parcela = tit_acr.cod_parcela
                                   tt_acr.ttv_val_origin_tit_acr = val_aprop_ctbl_acr.val_aprop_ctbl
                                   tt_acr.ttv_log_estordo = movto_tit_acr.log_movto_estordo.
                        end.
                        else
                            assign tt_acr.ttv_val_origin_tit_acr = tt_acr.ttv_val_origin_tit_acr + val_aprop_ctbl_acr.val_aprop_ctbl.
                    end.
                end.
            end.
        end.
    end.
END PROCEDURE. /* pi_monta_temp_table_concil_acr */
/*****************************************************************************
** Procedure Interna.....: pi_close_program
** Descricao.............: pi_close_program
** Criado por............: 
** Criado em.............: // 
** Alterado por..........: vanei
** Alterado em...........: 14/05/1998 15:13:54
*****************************************************************************/
PROCEDURE pi_close_program:


        if  avail cta_ctbl
        then do:
            assign v_rec_cta_ctbl = recid(cta_ctbl).
        end /* if */.
        else do:
            assign v_rec_cta_ctbl = ?.
        end /* else */.



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


    delete widget wh_w_program.
    if  this-procedure:persistent = yes
    then do:
        delete procedure this-procedure.
    end /* if */.
END PROCEDURE. /* pi_close_program */
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
        format "Sim/n∆o"
        initial no
        view-as toggle-box
        label "Registro Corporativo"
        column-label "Registro Corporativo"
        no-undo.
    def var v_log_restric_estab
        as logical
        format "Sim/n∆o"
        initial no
        view-as toggle-box
        label "Usa Segur Estab"
        column-label "Usa Segur Estab"
        no-undo.
    def var v_nom_razao_social
        as character
        format "x(30)":U
        label "Raz o Social"
        column-label "Raz o Social"
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
            /* QUANDO FOR CHAMADO PELO EMS2 DEVERë FAZER A RESTRI¯∞O DOS ESTABELECIMENTOS */        
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

    /* Cria TT com os grupos de usuòrios */
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
                /* Verifica se o Usuòrio tem permiss o na Empresa */
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
                   /* Verifica se o Usuòrio tem permiss o no Estabelecimento */
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
** Procedure Interna.....: pi_monta_estab_ems2_fat
** Descricao.............: pi_monta_estab_ems2_fat
** Criado por............: fut42929
** Criado em.............: 01/02/2013 14:21:21
** Alterado por..........: fut42929
** Alterado em...........: 28/02/2013 10:17:35
*****************************************************************************/
PROCEDURE pi_monta_estab_ems2_fat:

    assign v_cod_lista = "" /*l_*/ .

    des_estab_block:
    do v_num_cont_aux = 1 to num-entries(v_des_estab_select):
        FIND FIRST trad_org_ext
            WHERE trad_org_ext.cod_matriz_trad_org_ext = param_integr_ems.des_contdo_param_integr_ems
              and trad_org_ext.cod_tip_unid_organ      = tip_unid_organ.cod_tip_unid_organ
              and trad_org_ext.cod_unid_organ          = GetEntryField(v_num_cont_aux, v_des_estab_select, ',') NO-LOCK NO-ERROR.
        IF AVAIL trad_org_ext THEN DO:
            if v_cod_lista = "" /*l_*/   then
                assign v_cod_lista = trad_org_ext.cod_unid_organ_ext.
            else
                assign v_cod_lista = v_cod_lista + ',' + trad_org_ext.cod_unid_organ_ext.
        END.
    END.
    for each tt_cta_ctbl_concilia_acr:
        run pi_monta_temp_table_concil_fat_lista in v_hdl_prog_ems2 (input  v_dat_inicial,
                                                                     input  v_dat_fim,
                                                                     input  v_cod_lista,
                                                                     input-output v_num_nota_concil_faturam_aux,
                                                                     input-output table tt_fat).
    end.                                                             

END PROCEDURE. /* pi_monta_estab_ems2_fat */
/*****************************************************************************
** Procedure Interna.....: pi_monta_temp_table_concil_acr_lista
** Descricao.............: pi_monta_temp_table_concil_acr_lista
** Criado por............: fut42929
** Criado em.............: 01/02/2013 17:24:07
** Alterado por..........: fut42929
** Alterado em...........: 01/02/2013 17:31:26
*****************************************************************************/
PROCEDURE pi_monta_temp_table_concil_acr_lista:

    for each tt_cta_ctbl_concilia_acr: 
        des_estab_block:
        do v_num_cont_aux = 1 to num-entries(v_des_estab_select):
            for each movto_tit_acr no-lock
                where movto_tit_acr.cod_estab = GetEntryField(v_num_cont_aux, v_des_estab_select, ',')
                and   movto_tit_acr.ind_trans_acr_abrev = "IMPL" /*l_impl*/ 
                and   movto_tit_acr.dat_trans >= v_dat_inicial
                and   movto_tit_acr.dat_trans <= v_dat_fim
                and   movto_tit_acr.log_ctbz_aprop_ctbl = yes:

                find first tit_acr of movto_tit_acr no-lock no-error.            

                for each aprop_ctbl_acr of movto_tit_acr no-lock
                    where aprop_ctbl_acr.ind_natur_lancto_ctbl = "CR" /*l_cr*/ 
                    and   aprop_ctbl_acr.cod_cta_ctbl = tt_cta_ctbl_concilia_acr.tta_cod_cta_ctbl:

                    run pi_retornar_finalid_econ_corren_estab (Input tit_acr.cod_estab,
                                                               output v_cod_finalid_econ). 

                    for each val_aprop_ctbl_acr of aprop_ctbl_acr no-lock
                        where val_aprop_ctbl_acr.cod_finalid_econ = v_cod_finalid_econ:

                        find first tt_acr
                             where tt_acr.ttv_dat_trans   = movto_tit_acr.dat_trans
                             and   tt_acr.ttv_cod_estab   = tit_acr.cod_estab
                             and   tt_acr.ttv_cod_espec_docto = tit_acr.cod_espec_docto
                             and   tt_acr.ttv_cod_ser_docto = tit_acr.cod_ser_docto
                             and   tt_acr.ttv_cod_tit_acr = tit_acr.cod_tit_acr
                             and   tt_acr.ttv_cod_parcela = tit_acr.cod_parcela
                             no-error.
                        if  not avail tt_acr then do:
                            create tt_acr.
                            assign tt_acr.ttv_dat_trans   = movto_tit_acr.dat_trans
                                   tt_acr.ttv_cod_estab   = tit_acr.cod_estab
                                   tt_acr.ttv_cod_espec_docto = tit_acr.cod_espec_docto
                                   tt_acr.ttv_cod_ser_docto = tit_acr.cod_ser_docto
                                   tt_acr.ttv_cod_tit_acr = tit_acr.cod_tit_acr
                                   tt_acr.ttv_cod_parcela = tit_acr.cod_parcela
                                   tt_acr.ttv_val_origin_tit_acr = val_aprop_ctbl_acr.val_aprop_ctbl
                                   tt_acr.ttv_log_estordo = movto_tit_acr.log_movto_estordo.
                        end.
                        else
                            assign tt_acr.ttv_val_origin_tit_acr = tt_acr.ttv_val_origin_tit_acr + val_aprop_ctbl_acr.val_aprop_ctbl.
                    end.
                end.
            end.
        end.
    end.
END PROCEDURE. /* pi_monta_temp_table_concil_acr_lista */
/*****************************************************************************
** Procedure Interna.....: pi_monta_estab_ems2_fat_2
** Descricao.............: pi_monta_estab_ems2_fat_2
** Criado por............: fut42929
** Criado em.............: 28/02/2013 15:45:54
** Alterado por..........: fut42929
** Alterado em...........: 28/02/2013 15:46:56
*****************************************************************************/
PROCEDURE pi_monta_estab_ems2_fat_2:

    des_estab_block:
    do v_num_cont_aux = 1 to num-entries(v_des_estab_select):
        FIND FIRST trad_org_ext
            WHERE trad_org_ext.cod_matriz_trad_org_ext = param_integr_ems.des_contdo_param_integr_ems
              and trad_org_ext.cod_tip_unid_organ      = tip_unid_organ.cod_tip_unid_organ
              and trad_org_ext.cod_unid_organ          = GetEntryField(v_num_cont_aux, v_des_estab_select, ',') NO-LOCK NO-ERROR.
        IF AVAIL trad_org_ext THEN DO:
            if v_cod_lista = "" /*l_*/    then
                assign v_cod_lista = trad_org_ext.cod_unid_organ_ext.
            else
                assign v_cod_lista = v_cod_lista + ',' + trad_org_ext.cod_unid_organ_ext.
        END.
    END.
END PROCEDURE. /* pi_monta_estab_ems2_fat_2 */


/************************** Internal Procedure End **************************/

/************************* External Procedure Begin *************************/



/************************** External Procedure End **************************/

/*************************************  *************************************/
/*****************************************************************************
**  Procedure Interna: pi_print_editor
**  Descricao........: Imprime editores nos relat´rios
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
                            when "s_planilha" then
                                if c_at[i_ind] = "at" then
                                    put stream s_planilha unformatted c_aux at i_pos[i_ind].
                                else
                                    put stream s_planilha unformatted c_aux to i_pos[i_ind].
                        end.
            end.
        end.
        case p_stream:
        when "s_planilha" then
            put stream s_planilha unformatted skip.
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
/********************  End of fnc_conc_oper_acr_fat_novo ********************/

