/*****************************************************************************
** Copyright DATASUL S.A. (1994)
** Todos os Direitos Reservados.
** 
** Este fonte e de propriedade exclusiva da DATASUL, sua reproducao
** parcial ou total por qualquer meio, so' podera ser feita mediante
** autorizacao expressa.
**
** Programa..............: fnc_tit_acr_em_aber_faixa
** Descricao.............: Faixa - T¡tulos em Aberto ACR
** Versao................:  1.00.00.015
** Procedimento..........: rel_tit_acr_em_aber
** Nome Externo..........: prgfin/acr/acr303za.p
** Data Geracao..........: 11/05/2011 - 10:59:58
** Criado por............: Uno
** Criado em.............: 26/12/1996 10:08:57
** Alterado por..........: fut42625_3
** Alterado em...........: 15/02/2011 14:34:04
** Gerado por............: fut42625_3
*****************************************************************************/
DEFINE BUFFER empresa               FOR ems5.empresa.
DEFINE BUFFER histor_exec_especial  FOR ems5.histor_exec_especial.
DEFINE BUFFER cliente               FOR ems5.cliente.
DEFINE BUFFER portador              FOR ems5.portador.
DEFINE BUFFER espec_docto           FOR ems5.espec_docto.
DEFINE BUFFER unid_negoc            FOR ems5.unid_negoc.
DEFINE BUFFER pais                  FOR ems5.pais.
DEFINE BUFFER segur_unid_organ      FOR ems5.segur_unid_organ.

def var c-versao-prg as char initial " 1.00.00.015":U no-undo.

{include/i_dbinst.i}
{include/i_dbtype.i}
{include/i_fcldef.i}


&IF "{&EMSFND_VERSION}" >= "1.00" &THEN
{include/i-license-manager.i fnc_tit_acr_em_aber_faixa ACR}
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
                                    "FNC_TIT_ACR_EM_ABER_FAIXA","~~EMSFIN", "~~{~&emsfin_version}", "~~5.01")) /*msg_5009*/.
&else

/************************* Variable Definition Begin ************************/

def NEW shared var v_cdn_cliente_fim
    as Integer
    format ">>>,>>>,>>9":U
    initial 999999999
    label "at‚"
    column-label "Cliente Final"
    no-undo.
def NEW shared var v_cdn_cliente_ini
    as Integer
    format ">>>,>>>,>>9":U
    initial 0
    label "Cliente"
    column-label "Cliente Inicial"
    no-undo.
def NEW shared var v_cdn_clien_matriz_fim
    as Integer
    format ">>>,>>>,>>9":U
    initial 999999999
    label "at‚"
    column-label "at‚"
    no-undo.
def NEW shared var v_cdn_clien_matriz_ini
    as Integer
    format ">>>,>>>,>>9":U
    initial 0
    label "Cliente Matriz"
    column-label "Cliente Matriz"
    no-undo.
def NEW shared var v_cdn_repres_fim
    as Integer
    format ">>>,>>9":U
    initial 999999
    label "at‚"
    column-label "Repres Final"
    no-undo.
def NEW shared var v_cdn_repres_ini
    as Integer
    format ">>>,>>9":U
    initial 0
    label "Representante"
    column-label "Repres Inicial"
    no-undo.
def new global shared var v_cod_aplicat_dtsul_corren
    as character
    format "x(3)":U
    no-undo.
def shared var v_cod_cart_bcia_fim
    as character
    format "x(3)":U
    initial "ZZZ"
    label "at‚"
    column-label "Carteira"
    no-undo.
def shared var v_cod_cart_bcia_ini
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
def shared var v_cod_cond_cobr_fim
    as character
    format "x(8)":U
    initial "ZZZZZZZZ"
    label "at‚"
    column-label "at‚"
    no-undo.
def shared var v_cod_cond_cobr_ini
    as character
    format "x(8)":U
    label "Condi‡Æo Cobran‡a"
    column-label "Cond Cobran‡a"
    no-undo.
def shared var v_cod_cta_ctbl_final
    as character
    format "x(20)":U
    initial "ZZZZZZZZZZZZZZZZZZZZ"
    label "at‚"
    column-label "at‚"
    no-undo.
def shared var v_cod_cta_ctbl_ini
    as character
    format "x(20)":U
    label "Conta Inicial"
    column-label "Inicial"
    no-undo.
def new global shared var v_cod_dwb_user
    as character
    format "x(21)":U
    label "Usu rio"
    column-label "Usu rio"
    no-undo.
def new global shared var v_cod_empres_usuar
    as character
    format "x(3)":U
    label "Empresa"
    column-label "Empresa"
    no-undo.
def NEW shared var v_cod_espec_docto_fim
    as character
    format "x(3)":U
    initial "CV"
    label "at‚"
    column-label "C¢digo Final"
    no-undo.
def NEW shared var v_cod_espec_docto_ini
    as character
    format "x(3)":U
    label "Esp‚cie"
    column-label "C¢digo Inicial"
    INITIAL "CF"
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
def NEW shared var v_cod_grp_clien_fim
    as character
    format "x(4)":U
    initial "ZZZZ"
    label "at‚"
    column-label "Grupo Cliente"
    no-undo.
def NEW shared var v_cod_grp_clien_ini
    as character
    format "x(4)":U
    label "Grupo Cliente"
    column-label "Grupo Cliente"
    no-undo.
def new global shared var v_cod_grp_usuar_lst
    as character
    format "x(3)":U
    label "Grupo Usu rios"
    column-label "Grupo"
    no-undo.
def new global shared var v_cod_idiom_usuar
    as character
    format "x(8)":U
    label "Idioma"
    column-label "Idioma"
    no-undo.
def NEW shared var v_cod_indic_econ_fim
    as character
    format "x(8)":U
    initial "ZZZZZZZZ"
    label "at‚"
    column-label "Final"
    no-undo.
def NEW shared var v_cod_indic_econ_ini
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
def new global shared var v_cod_pais_empres_usuar
    as character
    format "x(3)":U
    label "Pa¡s Empresa Usu rio"
    column-label "Pa¡s"
    no-undo.
def new global shared var v_cod_plano_ccusto_corren
    as character
    format "x(8)":U
    label "Plano CCusto"
    column-label "Plano CCusto"
    no-undo.
def NEW shared var v_cod_plano_cta_ctbl_final
    as character
    format "x(8)":U
    initial "ZZZZZZZZ"
    label "Final"
    column-label "Final"
    no-undo.
def NEW shared var v_cod_plano_cta_ctbl_inic
    as character
    format "x(8)":U
    label "Plano Conta"
    column-label "Plano Cta"
    no-undo.
def NEW shared var v_cod_portador_fim
    as character
    format "x(5)":U
    initial "ZZZZZ"
    label "at‚"
    column-label "Portador Final"
    no-undo.
def NEW shared var v_cod_portador_ini
    as character
    format "x(5)":U
    label "Portador"
    column-label "Portador Inicial"
    no-undo.
def NEW shared var v_cod_proces_export_fim
    as character
    format "x(12)":U
    initial "ZZZZZZZZZZZZ"
    label "at‚"
    column-label "Proc Exp Final"
    no-undo.
def NEW shared var v_cod_proces_export_ini
    as character
    format "x(12)":U
    label "Processo Exporta‡Æo"
    column-label "Proc Exp Inicial"
    no-undo.
def NEW shared var v_cod_unid_negoc_fim
    as character
    format "x(3)":U
    initial "ZZZ"
    label "at‚"
    column-label "Final"
    no-undo.
def NEW shared var v_cod_unid_negoc_ini
    as character
    format "x(3)":U
    label "Unid Neg¢cio"
    column-label "Unid Neg"
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
    label "Usu rio Corrente"
    column-label "Usu rio Corrente"
    no-undo.
def new global shared var v_cod_usuar_corren_criptog
    as character
    format "x(16)":U
    no-undo.
def NEW shared var v_dat_emis_docto_fim
    as date
    format "99/99/9999":U
    initial 12/31/9999
    label "at‚"
    column-label "at‚"
    no-undo.
def NEW shared var v_dat_emis_docto_ini
    as date
    format "99/99/9999":U
    initial &IF "{&ems_dbtype}":U = "MSS":U &THEN 01/01/1800 &ELSE 01/01/0001 &ENDIF
    label "Data EmissÆo"
    column-label "EmissÆo"
    no-undo.
def NEW shared var v_dat_vencto_tit_acr_fim
    as date
    format "99/99/9999":U
    initial 12/31/9999
    label "at‚"
    column-label "Vencto Final"
    no-undo.
def NEW shared var v_dat_vencto_tit_acr_ini
    as date
    format "99/99/9999":U
    initial &IF "{&ems_dbtype}":U = "MSS":U &THEN 01/01/1800 &ELSE 01/01/0001 &ENDIF
    label "Vencimento"
    column-label "Vencto Inicial"
    no-undo.
def shared var v_des_estab_select
    as character
    format "x(2000)":U
    view-as editor max-chars 2000 no-word-wrap
    size 30 by 1
    bgcolor 15 font 2
    label "Selecionados"
    column-label "Selecionados"
    no-undo.
def var v_hdl_campo_1
    as Handle
    format ">>>>>>9":U
    no-undo.
def var v_hdl_campo_2
    as Handle
    format ">>>>>>9":U
    no-undo.
def var v_hdl_campo_3
    as Handle
    format ">>>>>>9":U
    no-undo.
def var v_hdl_campo_4
    as Handle
    format ">>>>>>9":U
    no-undo.
def NEW shared var v_ind_classif_tit_acr_em_aber
    as character
    format "X(30)":U
    initial "Por Representante/Cliente" /*l_por_representantecliente*/
    view-as radio-set Vertical
    radio-buttons "Por Representante/Cliente", "Por Representante/Cliente", "Por Portador/Carteira", "Por Portador/Carteira", "Por Cliente/Vencimento", "Por Cliente/Vencimento", "Por Nome do Cliente/Vencimento", "Por Nome Cliente/Vencimento", "Por Grupo Cliente/Cliente", "Por Grupo Cliente/Cliente", "Por Vencimento/Nome Cliente", "Por Vencimento/Nome Cliente", "Por Matriz", "Por Matriz", "Por Condi‡Æo Cobran‡a/Cliente", "Por Condi‡Æo Cobran‡a/Cliente", "Por Esp‚cie/Vencto/Nome Cliente", "Por Esp‚cie/Vencto/Nome Cliente"
     /*l_por_representantecliente*/ /*l_por_representantecliente*/ /*l_por_portadorcarteira*/ /*l_por_portadorcarteira*/ /*l_por_clientevencimento*/ /*l_por_clientevencimento*/ /*l_por_nome_do_clientevencimento*/ /*l_por_nome_clientevencimento*/ /*l_por_grupo_clientecliente*/ /*l_por_grupo_clientecliente*/ /*l_por_vencimentonome_cliente*/ /*l_por_vencimentonome_cliente*/ /*l_por_matriz*/ /*l_por_matriz*/ /*l_por_condcobranca_cliente*/ /*l_por_condcobranca_cliente*/ /*l_por_espec_Vencto_nomcli*/ /*l_por_espec_Vencto_nomcli*/
    bgcolor 8 
    label "Classifica‡Æo"
    column-label "Classifica‡Æo"
    no-undo.
def var v_ind_var_final
    as character
    format "X(08)":U
    no-undo.
def var v_ind_var_inicial
    as character
    format "X(08)":U
    no-undo.
def NEW shared var v_ind_visualiz_tit_acr_vert
    as character
    format "X(20)":U
    initial "Por Estabelecimento" /*l_por_estabelecimento*/
    view-as radio-set Vertical
    radio-buttons "Por Estabelecimento", "Por Estabelecimento", "Por Unidade Neg¢cio", "Por Unidade Neg¢cio"
     /*l_por_estabelecimento*/ /*l_por_estabelecimento*/ /*l_por_unid_negoc*/ /*l_por_unid_negoc*/
    bgcolor 8 
    label "Visualiza T¡tulo"
    column-label "Visualiza T¡tulo"
    no-undo.
def var v_log_aumento_tela
    as logical
    format "Sim/NÆo"
    initial no
    no-undo.
def var v_log_funcao_melhoria_tit_aber
    as logical
    format "Sim/NÆo"
    initial no
    no-undo.
def var v_log_funcao_proces_export
    as logical
    format "Sim/NÆo"
    initial no
    no-undo.
def NEW shared var v_log_habilita_con_corporat
    as logical
    format "Sim/NÆo"
    initial no
    label "Habilita Consulta"
    column-label "Habilita Consulta"
    no-undo.
def var v_log_integr_mec
    as logical
    format "Sim/NÆo"
    initial no
    no-undo.
def var v_log_return_epc
    as logical
    format "Sim/NÆo"
    initial ?
    no-undo.
def var v_log_vers_50_6
    as logical
    format "Sim/NÆo"
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
def new global shared var v_num_ped_exec_corren
    as integer
    format ">>>>9":U
    no-undo.
def var v_num_var_erro
    as integer
    format ">>>>,>>9":U
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

def rectangle rt_cxcf
    size 1 by 1
    fgcolor 1 edge-pixels 2.
def rectangle rt_mold
    size 1 by 1
    edge-pixels 2.


/************************* Rectangle Definition End *************************/

/************************** Button Definition Begin *************************/

def button bt_can
    label "Cancela"
    tooltip "Cancela"
    size 1 by 1
    auto-endkey.
def button bt_hel2
    label "Ajuda"
    tooltip "Ajuda"
    size 1 by 1.
def button bt_ok
    label "OK"
    tooltip "OK"
    size 1 by 1
    auto-go.
def button bt_todos_img
    label "Todos"
    tooltip "Seleciona Todos"
&if "{&window-system}" <> "TTY" &then
    image file "image/im-ran_a.bmp"
&endif
    size 1 by 1.
/****************************** Function Button *****************************/
def button bt_zoo_188473
    label "Zoom"
    tooltip "Zoom"
&if "{&window-system}" <> "TTY" &then
    image-up file "image/im-zoo"
    image-insensitive file "image/ii-zoo"
&endif
    size 4 by .88.
def button bt_zoo_188474
    label "Zoom"
    tooltip "Zoom"
&if "{&window-system}" <> "TTY" &then
    image-up file "image/im-zoo"
    image-insensitive file "image/ii-zoo"
&endif
    size 4 by .88.


/*************************** Button Definition End **************************/

/************************** Frame Definition Begin **************************/

def frame f_ran_01_tit_acr_em_aberto
    rt_mold
         at row 01.21 col 02.00
    rt_cxcf
         at row 15.25 col 02.00 bgcolor 7 
    v_des_estab_select
         at row 01.50 col 20.00 colon-aligned label "Estab Selec"
         help "Estabelecimentos selecionados"
         view-as editor max-chars 2000 no-word-wrap
         size 30 by 1
         bgcolor 15 font 2
    bt_todos_img
         at row 01.46 col 52.14 font ?
         help "Seleciona Todos"
    v_cod_unid_negoc_ini
         at row 02.50 col 20.00 colon-aligned label "Unid Neg¢cio"
         help "Unidade de Neg¢cio Inicial"
         view-as fill-in
         size-chars 4.14 by .88
         fgcolor ? bgcolor 15 font 2
    v_cod_unid_negoc_fim
         at row 02.50 col 46.86 colon-aligned label "at‚"
         help "Unidade de Neg¢cio Final"
         view-as fill-in
         size-chars 4.14 by .88
         fgcolor ? bgcolor 15 font 2
    v_cod_espec_docto_ini
         at row 03.50 col 19.86 colon-aligned label "Esp‚cie"
         help "C¢digo Inicial"
         view-as fill-in
         size-chars 4.14 by .88
         fgcolor ? bgcolor 15 font 2
    v_cod_espec_docto_fim
         at row 03.50 col 46.86 colon-aligned label "at‚"
         help "C¢digo Final"
         view-as fill-in
         size-chars 4.14 by .88
         fgcolor ? bgcolor 15 font 2
    v_cdn_cliente_ini
         at row 04.50 col 19.86 colon-aligned label "Cliente"
         help "C¢digo do Cliente Inicial"
         view-as fill-in
         size-chars 12.14 by .88
         fgcolor ? bgcolor 15 font 2
    bt_zoo_188474
         at row 04.50 col 34.00
    v_cdn_cliente_fim
         at row 04.50 col 46.86 colon-aligned label "at‚"
         help "C¢digo do Cliente Final"
         view-as fill-in
         size-chars 12.14 by .88
         fgcolor ? bgcolor 15 font 2
    bt_zoo_188473
         at row 04.50 col 61.00
    v_cod_grp_clien_ini
         at row 05.50 col 19.86 colon-aligned label "Grupo Cliente"
         help "C¢digo Grupo Cliente"
         view-as fill-in
         size-chars 5.14 by .88
         fgcolor ? bgcolor 15 font 2
    v_cod_grp_clien_fim
         at row 05.50 col 46.86 colon-aligned label "at‚"
         help "C¢digo Grupo Cliente"
         view-as fill-in
         size-chars 5.14 by .88
         fgcolor ? bgcolor 15 font 2
    v_cod_portador_ini
         at row 06.50 col 19.86 colon-aligned label "Portador"
         help "C¢digo Portador Inicial"
         view-as fill-in
         size-chars 6.14 by .88
         fgcolor ? bgcolor 15 font 2
    v_cod_portador_fim
         at row 06.50 col 46.86 colon-aligned label "at‚"
         help "C¢digo Portador"
         view-as fill-in
         size-chars 6.14 by .88
         fgcolor ? bgcolor 15 font 2
    v_cod_cart_bcia_ini
         at row 07.50 col 19.86 colon-aligned label "Carteira"
         help "Carteira Banc ria"
         view-as fill-in
         size-chars 4.14 by .88
         fgcolor ? bgcolor 15 font 2
    v_cod_cart_bcia_fim
         at row 07.50 col 46.86 colon-aligned label "at‚"
         help "Carteira Banc ria"
         view-as fill-in
         size-chars 4.14 by .88
         fgcolor ? bgcolor 15 font 2
    v_cdn_repres_ini
         at row 08.50 col 19.86 colon-aligned label "Representante"
         help "C¢digo Representante"
         view-as fill-in
         size-chars 8.14 by .88
         fgcolor ? bgcolor 15 font 2
    v_cdn_repres_fim
         at row 08.50 col 46.86 colon-aligned label "at‚"
         help "C¢digo Representante"
         view-as fill-in
         size-chars 8.14 by .88
         fgcolor ? bgcolor 15 font 2
    v_dat_vencto_tit_acr_ini
         at row 09.50 col 19.86 colon-aligned label "Vencimento"
         help "Data Vencimento T¡tulo"
         view-as fill-in
         size-chars 11.14 by .88
         fgcolor ? bgcolor 15 font 2
    v_dat_vencto_tit_acr_fim
         at row 09.50 col 46.86 colon-aligned label "at‚"
         help "Data Vencimento T¡tulo"
         view-as fill-in
         size-chars 11.14 by .88
         fgcolor ? bgcolor 15 font 2
    v_cdn_clien_matriz_ini
         at row 10.50 col 19.86 colon-aligned label "Matriz"
         help "C¢digo - Num‚rico Cliente Matriz"
         view-as fill-in
         size-chars 12.14 by .88
         fgcolor ? bgcolor 15 font 2
    v_cdn_clien_matriz_fim
         at row 10.50 col 46.86 colon-aligned label "at‚"
         help "C¢digo - Num‚rico Cliente Matriz"
         view-as fill-in
         size-chars 12.14 by .88
         fgcolor ? bgcolor 15 font 2
    v_cod_cond_cobr_ini
         at row 11.50 col 19.86 colon-aligned label "Condi‡Æo Cobran‡a"
         help "C¢digo Condi‡Æo Cobran‡a"
         view-as fill-in
         size-chars 9.14 by .88
         fgcolor ? bgcolor 15 font 2
    v_cod_cond_cobr_fim
         at row 11.50 col 46.86 colon-aligned label "at‚"
         help "C¢digo Condi‡Æo Cobran‡a"
         view-as fill-in
         size-chars 9.14 by .88
         fgcolor ? bgcolor 15 font 2
    v_cod_indic_econ_ini
         at row 12.50 col 19.86 colon-aligned label "Moeda"
         help "Indicador Econ“mico Inicial"
         view-as fill-in
         size-chars 9.14 by .88
         fgcolor ? bgcolor 15 font 2
    v_cod_indic_econ_fim
         at row 12.50 col 46.86 colon-aligned label "at‚"
         help "Indicador Econ“mico Final"
         view-as fill-in
         size-chars 9.14 by .88
         fgcolor ? bgcolor 15 font 2
    v_cod_proces_export_ini
         at row 13.50 col 19.86 colon-aligned label "Processo Exporta‡Æo"
         help "Processo Exporta‡Æo Inicial"
         view-as fill-in
         size-chars 13.14 by .88
         fgcolor ? bgcolor 15 font 2
    v_cod_proces_export_fim
         at row 13.50 col 46.86 colon-aligned label "at‚"
         help "Processo Exporta‡Æo Final"
         view-as fill-in
         size-chars 13.14 by .88
         fgcolor ? bgcolor 15 font 2
    v_dat_emis_docto_ini
         at row 14.50 col 19.86 colon-aligned label "Data EmissÆo"
         help "Data EmissÆo Documento"
         view-as fill-in
         size-chars 11.14 by .88
         fgcolor ? bgcolor 15 font 2
    v_dat_emis_docto_fim
         at row 14.50 col 46.86 colon-aligned label "at‚"
         help "Data EmissÆo Documento"
         view-as fill-in
         size-chars 11.14 by .88
         fgcolor ? bgcolor 15 font 2
    v_cod_plano_cta_ctbl_inic
         at row 14.50 col 19.86 colon-aligned label "Plano Conta"
         view-as fill-in
         size-chars 9.14 by .88
         fgcolor ? bgcolor 15 font 2
    v_cod_plano_cta_ctbl_final
         at row 14.50 col 46.86 colon-aligned label "at‚"
         help "C¢digo Plano Contas"
         view-as fill-in
         size-chars 9.14 by .88
         fgcolor ? bgcolor 15 font 2
    v_cod_cta_ctbl_ini
         at row 14.50 col 19.86 colon-aligned label "Conta Inicial"
         help "C¢digo Conta Cont bil"
         view-as fill-in
         size-chars 21.14 by .88
         fgcolor ? bgcolor 15 font 2
    v_cod_cta_ctbl_final
         at row 14.50 col 46.86 colon-aligned label "at‚"
         help "C¢digo Conta Cont bil"
         view-as fill-in
         size-chars 21.14 by .88
         fgcolor ? bgcolor 15 font 2
    bt_ok
         at row 15.46 col 03.00 font ?
         help "OK"
    bt_can
         at row 15.46 col 14.00 font ?
         help "Cancela"
    bt_hel2
         at row 15.46 col 60.57 font ?
         help "Ajuda"
    with 1 down side-labels no-validate keep-tab-order three-d
         size-char 73.00 by 17.08 default-button bt_ok
         view-as dialog-box
         font 1 fgcolor ? bgcolor 8
         title "Faixa - T¡tulos em Aberto".
    /* adjust size of objects in this frame */
    assign bt_can:width-chars        in frame f_ran_01_tit_acr_em_aberto = 10.00
           bt_can:height-chars       in frame f_ran_01_tit_acr_em_aberto = 01.00
           bt_hel2:width-chars       in frame f_ran_01_tit_acr_em_aberto = 10.00
           bt_hel2:height-chars      in frame f_ran_01_tit_acr_em_aberto = 01.00
           bt_ok:width-chars         in frame f_ran_01_tit_acr_em_aberto = 10.00
           bt_ok:height-chars        in frame f_ran_01_tit_acr_em_aberto = 01.00
           bt_todos_img:width-chars  in frame f_ran_01_tit_acr_em_aberto = 04.00
           bt_todos_img:height-chars in frame f_ran_01_tit_acr_em_aberto = 01.13
           rt_cxcf:width-chars       in frame f_ran_01_tit_acr_em_aberto = 69.57
           rt_cxcf:height-chars      in frame f_ran_01_tit_acr_em_aberto = 01.42
           rt_mold:width-chars       in frame f_ran_01_tit_acr_em_aberto = 69.57
           rt_mold:height-chars      in frame f_ran_01_tit_acr_em_aberto = 13.79.
    /* set return-inserted = yes for editors */
    assign v_des_estab_select:return-inserted in frame f_ran_01_tit_acr_em_aberto = yes.
    /* set private-data for the help system */
    assign v_des_estab_select:private-data         in frame f_ran_01_tit_acr_em_aberto = "HLP=000000000":U
           bt_todos_img:private-data               in frame f_ran_01_tit_acr_em_aberto = "HLP=000021504":U
           v_cod_unid_negoc_ini:private-data       in frame f_ran_01_tit_acr_em_aberto = "HLP=000019459":U
           v_cod_unid_negoc_fim:private-data       in frame f_ran_01_tit_acr_em_aberto = "HLP=000019460":U
           v_cod_espec_docto_ini:private-data      in frame f_ran_01_tit_acr_em_aberto = "HLP=000016628":U
           v_cod_espec_docto_fim:private-data      in frame f_ran_01_tit_acr_em_aberto = "HLP=000016629":U
           bt_zoo_188474:private-data              in frame f_ran_01_tit_acr_em_aberto = "HLP=000009431":U
           v_cdn_cliente_ini:private-data          in frame f_ran_01_tit_acr_em_aberto = "HLP=000022353":U
           bt_zoo_188473:private-data              in frame f_ran_01_tit_acr_em_aberto = "HLP=000009431":U
           v_cdn_cliente_fim:private-data          in frame f_ran_01_tit_acr_em_aberto = "HLP=000022352":U
           v_cod_grp_clien_ini:private-data        in frame f_ran_01_tit_acr_em_aberto = "HLP=000023781":U
           v_cod_grp_clien_fim:private-data        in frame f_ran_01_tit_acr_em_aberto = "HLP=000023782":U
           v_cod_portador_ini:private-data         in frame f_ran_01_tit_acr_em_aberto = "HLP=000014638":U
           v_cod_portador_fim:private-data         in frame f_ran_01_tit_acr_em_aberto = "HLP=000014647":U
           v_cod_cart_bcia_ini:private-data        in frame f_ran_01_tit_acr_em_aberto = "HLP=000023778":U
           v_cod_cart_bcia_fim:private-data        in frame f_ran_01_tit_acr_em_aberto = "HLP=000016642":U
           v_cdn_repres_ini:private-data           in frame f_ran_01_tit_acr_em_aberto = "HLP=000023776":U
           v_cdn_repres_fim:private-data           in frame f_ran_01_tit_acr_em_aberto = "HLP=000023777":U
           v_dat_vencto_tit_acr_ini:private-data   in frame f_ran_01_tit_acr_em_aberto = "HLP=000023783":U
           v_dat_vencto_tit_acr_fim:private-data   in frame f_ran_01_tit_acr_em_aberto = "HLP=000023784":U
           v_cdn_clien_matriz_ini:private-data     in frame f_ran_01_tit_acr_em_aberto = "HLP=000000000":U
           v_cdn_clien_matriz_fim:private-data     in frame f_ran_01_tit_acr_em_aberto = "HLP=000000000":U
           v_cod_cond_cobr_ini:private-data        in frame f_ran_01_tit_acr_em_aberto = "HLP=000023779":U
           v_cod_cond_cobr_fim:private-data        in frame f_ran_01_tit_acr_em_aberto = "HLP=000023780":U
           v_cod_indic_econ_ini:private-data       in frame f_ran_01_tit_acr_em_aberto = "HLP=000018872":U
           v_cod_indic_econ_fim:private-data       in frame f_ran_01_tit_acr_em_aberto = "HLP=000018873":U
           v_cod_proces_export_ini:private-data    in frame f_ran_01_tit_acr_em_aberto = "HLP=000000000":U
           v_cod_proces_export_fim:private-data    in frame f_ran_01_tit_acr_em_aberto = "HLP=000000000":U
           v_dat_emis_docto_ini:private-data       in frame f_ran_01_tit_acr_em_aberto = "HLP=000014636":U
           v_dat_emis_docto_fim:private-data       in frame f_ran_01_tit_acr_em_aberto = "HLP=000014637":U
           v_cod_plano_cta_ctbl_inic:private-data  in frame f_ran_01_tit_acr_em_aberto = "HLP=000000000":U
           v_cod_plano_cta_ctbl_final:private-data in frame f_ran_01_tit_acr_em_aberto = "HLP=000019273":U
           v_cod_cta_ctbl_ini:private-data         in frame f_ran_01_tit_acr_em_aberto = "HLP=000019246":U
           v_cod_cta_ctbl_final:private-data       in frame f_ran_01_tit_acr_em_aberto = "HLP=000019275":U
           bt_ok:private-data                      in frame f_ran_01_tit_acr_em_aberto = "HLP=000010721":U
           bt_can:private-data                     in frame f_ran_01_tit_acr_em_aberto = "HLP=000011050":U
           bt_hel2:private-data                    in frame f_ran_01_tit_acr_em_aberto = "HLP=000011326":U
           frame f_ran_01_tit_acr_em_aberto:private-data                               = "HLP=000000000".
    /* enable function buttons */
    assign bt_zoo_188474:sensitive in frame f_ran_01_tit_acr_em_aberto = yes
           bt_zoo_188473:sensitive in frame f_ran_01_tit_acr_em_aberto = yes.
    /* move buttons to top */
    bt_zoo_188474:move-to-top().
    bt_zoo_188473:move-to-top().



{include/i_fclfrm.i f_ran_01_tit_acr_em_aberto }
/*************************** Frame Definition End ***************************/

/*********************** User Interface Trigger Begin ***********************/


ON CHOOSE OF bt_can IN FRAME f_ran_01_tit_acr_em_aberto
DO:


END. /* ON CHOOSE OF bt_can IN FRAME f_ran_01_tit_acr_em_aberto */

ON CHOOSE OF bt_hel2 IN FRAME f_ran_01_tit_acr_em_aberto
DO:


    /* Begin_Include: i_context_help_frame */
    run prgtec/men/men900za.py (Input self:frame,
                                Input this-procedure:handle) /*prg_fnc_chamar_help_context*/.


    /* End_Include: i_context_help_frame */

END. /* ON CHOOSE OF bt_hel2 IN FRAME f_ran_01_tit_acr_em_aberto */

ON CHOOSE OF bt_todos_img IN FRAME f_ran_01_tit_acr_em_aberto
DO:

    assign input frame f_ran_01_tit_acr_em_aberto v_des_estab_select.
    if  search('prgint/utb/utb071za.r') = ? and search('prgint/utb/utb071za.p') = ? then do:
        if  v_cod_dwb_user begins 'es_' then
            return 'Programa execut vel nÆo foi encontrado:' /* l_programa_nao_encontrado*/  + 'prgint/utb/utb071za.p'.
        else do:
            message 'Programa execut vel nÆo foi encontrado:' /* l_programa_nao_encontrado*/  'prgint/utb/utb071za.p'
                   view-as alert-box error buttons ok.
            return.
        end.
    end.
    else
        run prgint/utb/utb071za.p (Input "ACR" /*l_acr*/ ) /* prg_fnc_estabelecimento_selec_espec*/.

    display v_des_estab_select with frame f_ran_01_tit_acr_em_aberto.
END. /* ON CHOOSE OF bt_todos_img IN FRAME f_ran_01_tit_acr_em_aberto */


/************************ User Interface Trigger End ************************/

/************************** Function Trigger Begin **************************/


ON  CHOOSE OF bt_zoo_188473 IN FRAME f_ran_01_tit_acr_em_aberto
OR F5 OF v_cdn_cliente_fim IN FRAME f_ran_01_tit_acr_em_aberto DO:

    /* fn_generic_zoom_variable */
    if  search("prgint/ufn/ufn011ka.r") = ? and search("prgint/ufn/ufn011ka.p") = ? then do:
        if  v_cod_dwb_user begins 'es_' then
            return "Programa execut vel nÆo foi encontrado:" /*l_programa_nao_encontrado*/  + "prgint/ufn/ufn011ka.p".
        else do:
            message "Programa execut vel nÆo foi encontrado:" /*l_programa_nao_encontrado*/  "prgint/ufn/ufn011ka.p"
                   view-as alert-box error buttons ok.
            return.
        end.
    end.
    else
        run prgint/ufn/ufn011ka.p /*prg_sea_clien_financ*/.
    if  v_rec_clien_financ <> ?
    then do:
        find clien_financ where recid(clien_financ) = v_rec_clien_financ no-lock no-error.
        assign v_cdn_cliente_fim:screen-value in frame f_ran_01_tit_acr_em_aberto =
               string(clien_financ.cdn_cliente).

        apply "entry" to v_cdn_cliente_fim in frame f_ran_01_tit_acr_em_aberto.
    end /* if */.

end. /* ON  CHOOSE OF bt_zoo_188473 IN FRAME f_ran_01_tit_acr_em_aberto */

ON  CHOOSE OF bt_zoo_188474 IN FRAME f_ran_01_tit_acr_em_aberto
OR F5 OF v_cdn_cliente_ini IN FRAME f_ran_01_tit_acr_em_aberto DO:

    /* fn_generic_zoom_variable */
    if  search("prgint/ufn/ufn011ka.r") = ? and search("prgint/ufn/ufn011ka.p") = ? then do:
        if  v_cod_dwb_user begins 'es_' then
            return "Programa execut vel nÆo foi encontrado:" /*l_programa_nao_encontrado*/  + "prgint/ufn/ufn011ka.p".
        else do:
            message "Programa execut vel nÆo foi encontrado:" /*l_programa_nao_encontrado*/  "prgint/ufn/ufn011ka.p"
                   view-as alert-box error buttons ok.
            return.
        end.
    end.
    else
        run prgint/ufn/ufn011ka.p /*prg_sea_clien_financ*/.
    if  v_rec_clien_financ <> ?
    then do:
        find clien_financ where recid(clien_financ) = v_rec_clien_financ no-lock no-error.
        assign v_cdn_cliente_ini:screen-value in frame f_ran_01_tit_acr_em_aberto =
               string(clien_financ.cdn_cliente).

        apply "entry" to v_cdn_cliente_ini in frame f_ran_01_tit_acr_em_aberto.
    end /* if */.

end. /* ON  CHOOSE OF bt_zoo_188474 IN FRAME f_ran_01_tit_acr_em_aberto */


/*************************** Function Trigger End ***************************/

/**************************** Frame Trigger Begin ***************************/


ON HELP OF FRAME f_ran_01_tit_acr_em_aberto ANYWHERE
DO:


    /* Begin_Include: i_context_help */
    run prgtec/men/men900za.py (Input self:handle,
                                Input this-procedure:handle) /*prg_fnc_chamar_help_context*/.
    /* End_Include: i_context_help */

END. /* ON HELP OF FRAME f_ran_01_tit_acr_em_aberto */

ON RIGHT-MOUSE-DOWN OF FRAME f_ran_01_tit_acr_em_aberto ANYWHERE
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

END. /* ON RIGHT-MOUSE-DOWN OF FRAME f_ran_01_tit_acr_em_aberto */

ON RIGHT-MOUSE-UP OF FRAME f_ran_01_tit_acr_em_aberto ANYWHERE
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

END. /* ON RIGHT-MOUSE-UP OF FRAME f_ran_01_tit_acr_em_aberto */

ON WINDOW-CLOSE OF FRAME f_ran_01_tit_acr_em_aberto
DO:

    apply "end-error" to self.
END. /* ON WINDOW-CLOSE OF FRAME f_ran_01_tit_acr_em_aberto */


/***************************** Frame Trigger End ****************************/

/**************************** Menu Trigger Begin ****************************/


ON CHOOSE OF MENU-ITEM mi_conteudo IN MENU m_help
DO:


        apply "choose" to bt_hel2 in frame f_ran_01_tit_acr_em_aberto.





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


        assign v_nom_prog     = substring(frame f_ran_01_tit_acr_em_aberto:title, 1, max(1, length(frame f_ran_01_tit_acr_em_aberto:title) - 10)).
        if  v_nom_prog = ? then
            assign v_nom_prog = "".

        assign v_nom_prog     = v_nom_prog
                              + chr(10)
                              + "fnc_tit_acr_em_aber_faixa":U.




    assign v_nom_prog_ext = "prgfin/acr/acr303za.p":U
           v_cod_release  = trim(" 1.00.00.015":U).
/*    run prgtec/btb/btb901zb.p (Input v_nom_prog,
                               Input v_nom_prog_ext,
                               Input v_cod_release) /*prg_fnc_about*/. */
{include/sobre5.i}
END. /* ON CHOOSE OF MENU-ITEM mi_sobre IN MENU m_help */


/***************************** Menu Trigger End *****************************/


/****************************** Main Code Begin *****************************/


/* Begin_Include: i_version_extract */
{include/i-ctrlrp5.i fnc_tit_acr_em_aber_faixa}


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
    run pi_version_extract ('fnc_tit_acr_em_aber_faixa':U, 'prgfin/acr/acr303za.p':U, '1.00.00.015':U, 'pro':U).
end /* if */.



/* End_Include: i_version_extract */

if  search("prgtec/btb/btb906za.r") = ? and search("prgtec/btb/btb906za.py") = ? then do:
    if  v_cod_dwb_user begins 'es_' then
        return "Programa execut vel nÆo foi encontrado:" /*l_programa_nao_encontrado*/  + "prgtec/btb/btb906za.py".
    else do:
        message "Programa execut vel nÆo foi encontrado:" /*l_programa_nao_encontrado*/  "prgtec/btb/btb906za.py"
               view-as alert-box error buttons ok.
        stop.
    end.
end.
else
    run prgtec/btb/btb906za.py /*prg_fnc_verify_controls*/.

/* Begin_Include: i_verify_security */
if  search("prgtec/men/men901za.r") = ? and search("prgtec/men/men901za.py") = ? then do:
    if  v_cod_dwb_user begins 'es_' then
        return "Programa execut vel nÆo foi encontrado:" /*l_programa_nao_encontrado*/  + "prgtec/men/men901za.py".
    else do:
        message "Programa execut vel nÆo foi encontrado:" /*l_programa_nao_encontrado*/  "prgtec/men/men901za.py"
               view-as alert-box error buttons ok.
        return.
    end.
end.
else
    run prgtec/men/men901za.py (Input 'fnc_tit_acr_em_aber_faixa') /*prg_fnc_verify_security*/.
if  return-value = "2014"
then do:
    /* Programa a ser executado nÆo ‚ um programa v lido Datasul ! */
    run pi_messages (input "show",
                     input 2014,
                     input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9",
                                       'fnc_tit_acr_em_aber_faixa')) /*msg_2014*/.
    return.
end /* if */.
if  return-value = "2012"
then do:
    /* Usu rio sem permissÆo para acessar o programa. */
    run pi_messages (input "show",
                     input 2012,
                     input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9",
                                       'fnc_tit_acr_em_aber_faixa')) /*msg_2012*/.
    return.
end /* if */.
/* End_Include: i_verify_security */



/* Begin_Include: i_verify_program_epc */
&if '{&emsbas_version}' > '1.00' &then
assign v_rec_table_epc = ?
       v_wgh_frame_epc = ?.

find prog_dtsul
    where prog_dtsul.cod_prog_dtsul = "fnc_tit_acr_em_aber_faixa":U
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


assign v_wgh_frame_epc = frame f_ran_01_tit_acr_em_aberto:handle.



assign v_nom_table_epc = 'tit_acr':U
       v_rec_table_epc = recid(tit_acr).

&endif

/* End_Include: i_verify_program_epc */



/* Begin_Include: i_log_exec_prog_dtsul_ini */
assign v_rec_log = ?.

if can-find(prog_dtsul
       where prog_dtsul.cod_prog_dtsul = 'fnc_tit_acr_em_aber_faixa' 
         and prog_dtsul.log_gera_log_exec = yes) then do transaction:
    create log_exec_prog_dtsul.
    assign log_exec_prog_dtsul.cod_prog_dtsul           = 'fnc_tit_acr_em_aber_faixa'
           log_exec_prog_dtsul.cod_usuario              = v_cod_usuar_corren
           log_exec_prog_dtsul.dat_inic_exec_prog_dtsul = today
           log_exec_prog_dtsul.hra_inic_exec_prog_dtsul = replace(string(time,"hh:mm:ss" /*l_hh:mm:ss*/ ),":":U,"":U).
    assign v_rec_log = recid(log_exec_prog_dtsul).
    release log_exec_prog_dtsul no-error.
end.


/* End_Include: i_log_exec_prog_dtsul_ini */



/* Begin_Include: i_std_dialog_box */
/* tratamento do titulo e versÆo */
assign frame f_ran_01_tit_acr_em_aberto:title = frame f_ran_01_tit_acr_em_aberto:title
                            + chr(32)
                            + chr(40)
                            + trim(" 1.00.00.015":U)
                            + chr(41).
/* menu pop-up de ajuda e sobre */
assign menu m_help:popup-only = yes
       bt_hel2:popup-menu in frame f_ran_01_tit_acr_em_aberto = menu m_help:handle.


/* End_Include: i_std_dialog_box */
{include/title5.i f_ran_01_tit_acr_em_aberto FRAME}



/* Begin_Include: i_vrf_funcao_integr_mec_ems5 */
IF  can-find(first param_integr_ems no-lock
    where param_integr_ems.ind_param_integr_ems = "Cƒmbio 2.00 X FIN EMS 5" /*l_cambio_2.00_x_fin_ems_5*/ ) THEN
    assign v_log_integr_mec = YES.
ELSE
    assign v_log_integr_mec = NO.


/* Begin_Include: i_funcao_extract */
if  v_cod_arq <> '' and v_cod_arq <> ?
then do:

    output stream s-arq to value(v_cod_arq) append.

    put stream s-arq unformatted
        'spp_integr_mec_ems5'      at 1 
        v_log_integr_mec  at 43 skip.

    output stream s-arq close.

end /* if */.
/* End_Include: i_funcao_extract */


/* End_Include: i_funcao_extract */



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


&if '{&emsfin_version}' >= '5.06' &then
    assign v_log_vers_50_6 = yes.
&endif
assign v_log_funcao_proces_export = &IF DEFINED(BF_FIN_NUM_PROC_EXP_REL_CON) &THEN YES
                                    &ELSE GetDefinedFunction('SPP_NUM_PROC_EXP_REL_CON':U) &ENDIF.
assign v_log_funcao_melhoria_tit_aber = &IF DEFINED(BF_FIN_MELHORIAS_TIT_EM_ABERTO) &THEN YES
                                        &ELSE GetDefinedFunction('SPP_MELHORIAS_TIT_EM_ABERTO':U) &ENDIF.

pause 0 before-hide.
view frame f_ran_01_tit_acr_em_aberto.

/* Begin_Include: i_executa_pi_epc_fin */
run pi_exec_program_epc_FIN (Input 'INITIALIZE',
                             Input 'no',
                             output v_log_return_epc) /*pi_exec_program_epc_FIN*/.
if v_log_return_epc then /* epc retornou erro*/
    undo, retry.
/* End_Include: i_executa_pi_epc_fin */


main_block:
do on endkey undo main_block, leave main_block on error undo main_block, retry main_block:

    if  not retry then do:
        display bt_can
                bt_hel2
                bt_ok
                bt_todos_img
                v_cdn_cliente_fim
                v_cdn_cliente_ini
                v_cdn_clien_matriz_fim
                v_cdn_clien_matriz_ini
                v_cdn_repres_fim
                v_cdn_repres_ini
                v_cod_cart_bcia_fim
                v_cod_cart_bcia_ini
                v_cod_cond_cobr_fim
                v_cod_cond_cobr_ini
                v_cod_espec_docto_fim
                v_cod_espec_docto_ini
                v_des_estab_select
                v_cod_grp_clien_fim
                v_cod_grp_clien_ini
                v_cod_portador_fim
                v_cod_portador_ini
                v_cod_unid_negoc_fim
                v_cod_unid_negoc_ini
                v_dat_vencto_tit_acr_fim
                v_dat_vencto_tit_acr_ini
                v_cod_indic_econ_ini
                v_cod_indic_econ_fim
                with frame f_ran_01_tit_acr_em_aberto.                    
        enable bt_can
               bt_hel2
               bt_ok
               bt_todos_img
               v_cdn_cliente_fim
               v_cdn_cliente_ini
               v_cdn_clien_matriz_fim
               v_cdn_clien_matriz_ini
               v_cdn_repres_fim
               v_cdn_repres_ini
               v_cod_cart_bcia_fim
               v_cod_cart_bcia_ini
               v_cod_cond_cobr_fim
               v_cod_cond_cobr_ini
               v_des_estab_select
               v_cod_grp_clien_fim
               v_cod_grp_clien_ini
               v_cod_portador_fim
               v_cod_portador_ini
               v_cod_unid_negoc_fim
               v_cod_unid_negoc_ini
               v_dat_vencto_tit_acr_fim
               v_dat_vencto_tit_acr_ini
               v_cod_indic_econ_ini
               v_cod_indic_econ_fim
               with frame f_ran_01_tit_acr_em_aberto.                   
        disable v_des_estab_select
                v_cod_espec_docto_fim
                v_cod_espec_docto_ini
                with frame f_ran_01_tit_acr_em_aberto.
        if (v_log_integr_mec and v_log_funcao_proces_export) or v_log_vers_50_6 then do:
            display v_cod_proces_export_ini
                    v_cod_proces_export_fim
                    with frame f_ran_01_tit_acr_em_aberto.         
            if v_ind_visualiz_tit_acr_vert = "Por Processo Exporta‡Æo" /*l_por_processo_exportacao*/  then        
                enable v_cod_proces_export_ini
                       v_cod_proces_export_fim
                       with frame f_ran_01_tit_acr_em_aberto.       
        end.
        else 
            assign v_cod_proces_export_ini:visible in frame f_ran_01_tit_acr_em_aberto = no
                   v_cod_proces_export_fim:visible in frame f_ran_01_tit_acr_em_aberto = no.

        if v_log_funcao_melhoria_tit_aber then do:
            if not v_log_aumento_tela then do:
                  assign frame f_ran_01_tit_acr_em_aberto:height-chars                  = (frame f_ran_01_tit_acr_em_aberto:height-chars)            + 3
                               rt_cxcf:row in frame f_ran_01_tit_acr_em_aberto          = (rt_cxcf:row in frame f_ran_01_tit_acr_em_aberto)          + 3
                               bt_ok:row in frame f_ran_01_tit_acr_em_aberto            = (bt_ok:row in frame f_ran_01_tit_acr_em_aberto)            + 3
                               bt_can:row in frame f_ran_01_tit_acr_em_aberto           = (bt_can:row in frame f_ran_01_tit_acr_em_aberto)           + 3  
                               bt_hel2:row in frame f_ran_01_tit_acr_em_aberto          = (bt_hel2:row in frame f_ran_01_tit_acr_em_aberto)          + 3
                               rt_mold:height-chars in frame f_ran_01_tit_acr_em_aberto = (rt_mold:height-chars in frame f_ran_01_tit_acr_em_aberto) + 3
                               v_hdl_campo_1      = v_cod_plano_cta_ctbl_inic:side-label-handle in frame f_ran_01_tit_acr_em_aberto
                               v_hdl_campo_2      = v_cod_plano_cta_ctbl_final:side-label-handle in frame f_ran_01_tit_acr_em_aberto
                               v_hdl_campo_3      = v_cod_cta_ctbl_ini:side-label-handle in frame f_ran_01_tit_acr_em_aberto
                               v_hdl_campo_4      = v_cod_cta_ctbl_final:side-label-handle in frame f_ran_01_tit_acr_em_aberto                                    
                               v_hdl_campo_1:row  = v_hdl_campo_1:row + 1
                               v_hdl_campo_2:row  = v_hdl_campo_2:row + 1
                               v_hdl_campo_3:row  = v_hdl_campo_3:row + 2
                               v_hdl_campo_4:row  = v_hdl_campo_4:row + 2
                               v_cod_plano_cta_ctbl_inic:row  = v_cod_plano_cta_ctbl_inic:row + 1
                               v_cod_plano_cta_ctbl_final:row = v_cod_plano_cta_ctbl_final:row + 1
                               v_cod_cta_ctbl_ini:row         = v_cod_cta_ctbl_ini:row + 2
                               v_cod_cta_ctbl_final:row       = v_cod_cta_ctbl_final:row + 2
                               v_log_aumento_tela = yes.
            end.

            display v_dat_emis_docto_ini
                    v_dat_emis_docto_fim
                    v_cod_plano_cta_ctbl_inic
                    v_cod_plano_cta_ctbl_final
                    v_cod_cta_ctbl_ini
                    v_cod_cta_ctbl_final
                    with frame f_ran_01_tit_acr_em_aberto.
            enable v_dat_emis_docto_ini
                   v_dat_emis_docto_fim
                   with frame f_ran_01_tit_acr_em_aberto.

            if v_ind_classif_tit_acr_em_aber = "Por Conta Cont bil/Esp‚cie/Grupo Cliente/Cliente" /*l_por_conta_contabilgrupocliente*/  then
                enable v_cod_plano_cta_ctbl_inic
                       v_cod_plano_cta_ctbl_final
                       v_cod_cta_ctbl_ini
                       v_cod_cta_ctbl_final
                       with frame f_ran_01_tit_acr_em_aberto.
            else
                assign v_cod_plano_cta_ctbl_inic:screen-value in frame f_ran_01_tit_acr_em_aberto  = ""
                       v_cod_plano_cta_ctbl_final:screen-value in frame f_ran_01_tit_acr_em_aberto = "ZZZZZZZZ" /*l_zzzzzzzz*/ 
                       v_cod_cta_ctbl_ini:screen-value in frame f_ran_01_tit_acr_em_aberto         = ""
                       v_cod_cta_ctbl_final:screen-value in frame f_ran_01_tit_acr_em_aberto       = "ZZZZZZZZZZZZZZZZZZZZ" /*l_zzzzzzzzzzzzzzzzzzzz*/ 
                       input frame f_ran_01_tit_acr_em_aberto v_cod_cta_ctbl_final
                       input frame f_ran_01_tit_acr_em_aberto v_cod_cta_ctbl_ini
                       input frame f_ran_01_tit_acr_em_aberto v_cod_plano_cta_ctbl_final
                       input frame f_ran_01_tit_acr_em_aberto v_cod_plano_cta_ctbl_inic.    
        end.
        else do:
            disable v_dat_emis_docto_ini
                    v_dat_emis_docto_fim
                    v_cod_plano_cta_ctbl_inic
                    v_cod_plano_cta_ctbl_final
                    v_cod_cta_ctbl_ini
                    v_cod_cta_ctbl_final
                    with frame f_ran_01_tit_acr_em_aberto.
            hide v_dat_emis_docto_ini in frame f_ran_01_tit_acr_em_aberto
                 v_dat_emis_docto_fim in frame f_ran_01_tit_acr_em_aberto
                 v_cod_plano_cta_ctbl_inic in frame f_ran_01_tit_acr_em_aberto
                 v_cod_plano_cta_ctbl_final in frame f_ran_01_tit_acr_em_aberto
                 v_cod_cta_ctbl_ini in frame f_ran_01_tit_acr_em_aberto
                 v_cod_cta_ctbl_final in frame f_ran_01_tit_acr_em_aberto.
        end.


        /* Begin_Include: i_executa_pi_epc_fin */
        run pi_exec_program_epc_FIN (Input 'DISPLAY',
                                     Input 'no',
                                     output v_log_return_epc) /*pi_exec_program_epc_FIN*/.
        if v_log_return_epc then /* epc retornou erro*/
            undo, retry.
        /* End_Include: i_executa_pi_epc_fin */


        /* Begin_Include: i_executa_pi_epc_fin */
        run pi_exec_program_epc_FIN (Input 'ENABLE',
                                     Input 'no',
                                     output v_log_return_epc) /*pi_exec_program_epc_FIN*/.
        if v_log_return_epc then /* epc retornou erro*/
            undo, retry.
        /* End_Include: i_executa_pi_epc_fin */


        if  v_ind_visualiz_tit_acr_vert = "Por Estabelecimento" /*l_por_estabelecimento*/ 
        then do:
            disable v_cod_unid_negoc_ini
                    v_cod_unid_negoc_fim
                    with frame f_ran_01_tit_acr_em_aberto.
        end /* if */.
    end.

    if  valid-handle( v_wgh_focus ) then do:
        wait-for go of frame f_ran_01_tit_acr_em_aberto focus v_wgh_focus.
    end.
    else do:
        wait-for go of frame f_ran_01_tit_acr_em_aberto.
    end.
    if v_des_estab_select = "" /*l_null*/  then do:
        /* No m¡nimo um Estabelecimento deve ser selecionado ! */
        run pi_messages (input "show",
                         input 8642,
                         input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9")) /*msg_8642*/.
        assign v_wgh_focus = bt_todos_img:handle in frame f_ran_01_tit_acr_em_aberto.
        undo main_block, retry main_block.
    end.
    if  input frame f_ran_01_tit_acr_em_aberto v_cod_unid_negoc_ini > input frame f_ran_01_tit_acr_em_aberto v_cod_unid_negoc_fim then do:
        assign v_wgh_focus = v_cod_unid_negoc_ini:handle in frame f_ran_01_tit_acr_em_aberto.
        /* &1 Inicial deve ser menor ou igual a(o) &1 Final ! */
        run pi_messages (input "show",
                         input 5123,
                         input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9",
                                            "Unid Neg¢cio")) /*msg_5123*/.
        undo main_block, retry main_block.
    end.
    if  input frame f_ran_01_tit_acr_em_aberto v_cod_espec_docto_ini > input frame f_ran_01_tit_acr_em_aberto v_cod_espec_docto_fim          then do:
        assign v_wgh_focus = v_cod_espec_docto_ini:handle in frame f_ran_01_tit_acr_em_aberto.
        /* &1 Inicial deve ser menor ou igual a(o) &1 Final ! */
        run pi_messages (input "show",
                         input 5123,
                         input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9",
                                            "Esp‚cie")) /*msg_5123*/.
        undo main_block, retry main_block.
    end.
    if  input frame f_ran_01_tit_acr_em_aberto v_cdn_cliente_ini > input frame f_ran_01_tit_acr_em_aberto v_cdn_cliente_fim then do:
        assign v_wgh_focus = v_cdn_cliente_ini:handle in frame f_ran_01_tit_acr_em_aberto.
        /* &1 Inicial deve ser menor ou igual a(o) &1 Final ! */
        run pi_messages (input "show",
                         input 5123,
                         input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9",
                                            "Cliente")) /*msg_5123*/.
        undo main_block, retry main_block.
    end.
    if  input frame f_ran_01_tit_acr_em_aberto v_cod_grp_clien_ini > input frame f_ran_01_tit_acr_em_aberto v_cod_grp_clien_fim then do:
        assign v_wgh_focus = v_cod_grp_clien_ini:handle in frame f_ran_01_tit_acr_em_aberto.
        /* &1 Inicial deve ser menor ou igual a(o) &1 Final ! */
        run pi_messages (input "show",
                         input 5123,
                         input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9",
                                            "Grupo Cliente")) /*msg_5123*/.
        undo main_block, retry main_block.
    end.
    if  input frame f_ran_01_tit_acr_em_aberto v_cod_portador_ini > input frame f_ran_01_tit_acr_em_aberto v_cod_portador_fim then do:
        assign v_wgh_focus = v_cod_portador_ini:handle in frame f_ran_01_tit_acr_em_aberto.
        /* &1 Inicial deve ser menor ou igual a(o) &1 Final ! */
        run pi_messages (input "show",
                         input 5123,
                         input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9",
                                            "Portador")) /*msg_5123*/.
        undo main_block, retry main_block.
    end.
    if  input frame f_ran_01_tit_acr_em_aberto v_cod_cart_bcia_ini > input frame f_ran_01_tit_acr_em_aberto v_cod_cart_bcia_fim then do:
        assign v_wgh_focus = v_cod_cart_bcia_ini:handle in frame f_ran_01_tit_acr_em_aberto.
        /* &1 Inicial deve ser menor ou igual a(o) &1 Final ! */
        run pi_messages (input "show",
                         input 5123,
                         input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9",
                                            "Carteira")) /*msg_5123*/.
        undo main_block, retry main_block.
    end.
    if  input frame f_ran_01_tit_acr_em_aberto v_cdn_repres_ini > input frame f_ran_01_tit_acr_em_aberto v_cdn_repres_fim then do:
        assign v_wgh_focus = v_cdn_repres_ini:handle in frame f_ran_01_tit_acr_em_aberto.
        /* &1 Inicial deve ser menor ou igual a(o) &1 Final ! */
        run pi_messages (input "show",
                         input 5123,
                         input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9",
                                            "Representante")) /*msg_5123*/.
        undo main_block, retry main_block.
    end.
    if  input frame f_ran_01_tit_acr_em_aberto v_dat_vencto_tit_acr_ini > input frame f_ran_01_tit_acr_em_aberto v_dat_vencto_tit_acr_fim then do:
        assign v_wgh_focus = v_dat_vencto_tit_acr_ini:handle in frame f_ran_01_tit_acr_em_aberto.
        /* &1 Inicial deve ser menor ou igual a(o) &1 Final ! */
        run pi_messages (input "show",
                         input 5123,
                         input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9",
                                            "Vencimento")) /*msg_5123*/.
        undo main_block, retry main_block.
    end.
    if  input frame f_ran_01_tit_acr_em_aberto v_cdn_clien_matriz_ini > input frame f_ran_01_tit_acr_em_aberto v_cdn_clien_matriz_fim then do:
        assign v_wgh_focus = v_cdn_clien_matriz_ini:handle in frame f_ran_01_tit_acr_em_aberto.
        /* &1 Inicial deve ser menor ou igual a(o) &1 Final ! */
        run pi_messages (input "show",
                         input 5123,
                         input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9",
                                            "Cliente Matriz")) /*msg_5123*/.
        undo main_block, retry main_block.
    end.
    if  input frame f_ran_01_tit_acr_em_aberto v_cod_cond_cobr_ini > input frame f_ran_01_tit_acr_em_aberto v_cod_cond_cobr_fim then do:
        assign v_wgh_focus = v_cod_cond_cobr_ini:handle in frame f_ran_01_tit_acr_em_aberto.
        /* &1 Inicial deve ser menor ou igual a(o) &1 Final ! */
        run pi_messages (input "show",
                         input 5123,
                         input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9",
                                            "Condi‡Æo Cobran‡a")) /*msg_5123*/.
        undo main_block, retry main_block.
    end.
    if  input frame f_ran_01_tit_acr_em_aberto v_cod_proces_export_ini > input frame f_ran_01_tit_acr_em_aberto v_cod_proces_export_fim then do:
        assign v_wgh_focus = v_cod_proces_export_ini:handle in frame f_ran_01_tit_acr_em_aberto.
        /* &1 Inicial deve ser menor ou igual a(o) &1 Final ! */
        run pi_messages (input "show",
                         input 5123,
                         input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9",
                                            "Processo Exporta‡Æo")) /*msg_5123*/.
        undo main_block, retry main_block.
    end.
    if  input frame f_ran_01_tit_acr_em_aberto v_dat_emis_docto_ini > input frame f_ran_01_tit_acr_em_aberto v_dat_emis_docto_fim then do:
        assign v_wgh_focus = v_dat_emis_docto_ini:handle in frame f_ran_01_tit_acr_em_aberto.
        /* &1 Inicial deve ser menor ou igual a(o) &1 Final ! */
        run pi_messages (input "show",
                         input 5123,
                         input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9",
                                            "Data EmissÆo")) /*msg_5123*/.
        undo main_block, retry main_block.
    end.
    if  input frame f_ran_01_tit_acr_em_aberto v_cod_cta_ctbl_ini > input frame f_ran_01_tit_acr_em_aberto v_cod_cta_ctbl_final then do:
        assign v_wgh_focus = v_cod_cta_ctbl_ini:handle in frame f_ran_01_tit_acr_em_aberto.
        /* &1 Inicial deve ser menor ou igual a(o) &1 Final ! */
        run pi_messages (input "show",
                         input 5123,
                         input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9",
                                            "Conta Inicial")) /*msg_5123*/.
        undo main_block, retry main_block.
    end.
    if  input frame f_ran_01_tit_acr_em_aberto v_cod_plano_cta_ctbl_inic > input frame f_ran_01_tit_acr_em_aberto v_cod_plano_cta_ctbl_final then do:
        assign v_wgh_focus = v_cod_plano_cta_ctbl_inic:handle in frame f_ran_01_tit_acr_em_aberto.
        /* &1 Inicial deve ser menor ou igual a(o) &1 Final ! */
        run pi_messages (input "show",
                         input 5123,
                         input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9",
                                            "Plano Conta")) /*msg_5123*/.
        undo main_block, retry main_block.
    end.
    assign input frame f_ran_01_tit_acr_em_aberto v_cdn_cliente_fim
           input frame f_ran_01_tit_acr_em_aberto v_cdn_cliente_ini
           input frame f_ran_01_tit_acr_em_aberto v_cdn_clien_matriz_fim
           input frame f_ran_01_tit_acr_em_aberto v_cdn_clien_matriz_ini
           input frame f_ran_01_tit_acr_em_aberto v_cdn_repres_fim
           input frame f_ran_01_tit_acr_em_aberto v_cdn_repres_ini
           input frame f_ran_01_tit_acr_em_aberto v_cod_cart_bcia_fim
           input frame f_ran_01_tit_acr_em_aberto v_cod_cart_bcia_ini
           input frame f_ran_01_tit_acr_em_aberto v_cod_cond_cobr_fim
           input frame f_ran_01_tit_acr_em_aberto v_cod_cond_cobr_ini
           input frame f_ran_01_tit_acr_em_aberto v_cod_cta_ctbl_final
           input frame f_ran_01_tit_acr_em_aberto v_cod_cta_ctbl_ini
           input frame f_ran_01_tit_acr_em_aberto v_cod_espec_docto_fim
           input frame f_ran_01_tit_acr_em_aberto v_cod_espec_docto_ini
           input frame f_ran_01_tit_acr_em_aberto v_cod_grp_clien_fim
           input frame f_ran_01_tit_acr_em_aberto v_cod_grp_clien_ini
           input frame f_ran_01_tit_acr_em_aberto v_cod_indic_econ_fim
           input frame f_ran_01_tit_acr_em_aberto v_cod_indic_econ_ini
           input frame f_ran_01_tit_acr_em_aberto v_cod_plano_cta_ctbl_final
           input frame f_ran_01_tit_acr_em_aberto v_cod_plano_cta_ctbl_inic
           input frame f_ran_01_tit_acr_em_aberto v_cod_portador_fim
           input frame f_ran_01_tit_acr_em_aberto v_cod_portador_ini
           input frame f_ran_01_tit_acr_em_aberto v_cod_proces_export_fim
           input frame f_ran_01_tit_acr_em_aberto v_cod_proces_export_ini
           input frame f_ran_01_tit_acr_em_aberto v_cod_unid_negoc_fim
           input frame f_ran_01_tit_acr_em_aberto v_cod_unid_negoc_ini
           input frame f_ran_01_tit_acr_em_aberto v_dat_emis_docto_fim
           input frame f_ran_01_tit_acr_em_aberto v_dat_emis_docto_ini
           input frame f_ran_01_tit_acr_em_aberto v_dat_vencto_tit_acr_fim
           input frame f_ran_01_tit_acr_em_aberto v_dat_vencto_tit_acr_ini
           input frame f_ran_01_tit_acr_em_aberto v_des_estab_select.

end /* do main_block */.


/* Begin_Include: i_executa_pi_epc_fin */
run pi_exec_program_epc_FIN (Input 'VALIDATE',
                             Input 'yes',
                             output v_log_return_epc) /*pi_exec_program_epc_FIN*/.
if v_log_return_epc then /* epc retornou erro*/
    undo, retry.
/* End_Include: i_executa_pi_epc_fin */


hide frame f_ran_01_tit_acr_em_aberto.


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
        format "Sim/NÆo"
        no-undo.


    /************************* Parameter Definition End *************************/

    /* *******************************************************************************************
    ** Objetivo..............: Substituir o c¢digo gerado pela include i_exec_program_epc,
    **                         muitas vezes repetido, com o intuito de evitar estouro de segmento.
    **
    ** Utiliza‡Æo............: A utiliza‡Æo desta procedure funciona exatamente como a include
    **                         anteriormente utilizada para este fim, para chamar ela deve ser 
    **                         includa a include i_executa_pi_epc_fin no programa, que ira executar 
    **                         esta pi e fazer tratamento para os retornos. Deve ser declarada a 
    **                         variavel v_log_return_epc (caso o parametro ela seja verdade, ‚ 
    **                         porque a EPC retornou "NOK". 
    **
    **                         @i(i_executa_pi_epc_fin &event='INITIALIZE' &return='NO')
    **
    **                         Para se ter uma id‚ia de como se usa, favor olhar o fonte do apb008za.p
    **
    **
    *********************************************************************************************/

    assign p_log_return_epc = no.
    /* ix_iz1_fnc_tit_acr_em_aber_faixa */


    /* Begin_Include: i_exec_program_epc_pi_fin */
    if  v_nom_prog_upc <> ''    
    or  v_nom_prog_appc <> ''
    or  v_nom_prog_dpc <> '' then do:
        &if 'tit_acr' <> '' &then
            assign v_rec_table_epc = recid(tit_acr)
                   v_nom_table_epc = 'tit_acr'.
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


    /* ix_iz2_fnc_tit_acr_em_aber_faixa */
END PROCEDURE. /* pi_exec_program_epc_FIN */


/************************** Internal Procedure End **************************/

/************************* External Procedure Begin *************************/



/************************** External Procedure End **************************/
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
                "Programa Mensagem" c_prg_msg "nÆo encontrado."
                view-as alert-box error.
        return error.
    end.

    run value(c_prg_msg + ".p":U) (input c_action, input c_param).
    return return-value.
END PROCEDURE.  /* pi_messages */
/*********************  End of fnc_tit_acr_em_aber_faixa ********************/
