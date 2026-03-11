/*****************************************************************************
** Copyright DATASUL S.A. (1994)
** Todos os Direitos Reservados.
** 
** Este fonte e de propriedade exclusiva da DATASUL, sua reproducao
** parcial ou total por qualquer meio, so' podera ser feita mediante
** autorizacao expressa.
**
** Programa..............: sea_tit_acr_cartao
** Descricao.............: Pesquisa T°tulo Contas a Receber
** Versao................:  1.00.00.001
** Procedimento..........: con_tit_acr_cartao
** Nome Externo..........: prgfin/spp/spp212aa.p
** Data Geracao..........: 03/11/2008 - 12:11:00
** Criado por............: Rodrigo Costa Bett
** Criado em.............: 03/11/2008 - 12:11:00
** Alterado por..........: 
** Alterado em...........: 
** Gerado por............: Rodrigo Costa Bett
*****************************************************************************/
DEFINE BUFFER histor_exec_especial FOR ems5.histor_exec_especial.

def input param v_cod_estab as char format "x(05)" no-undo.  
def input param v_cod_espec as char format "x(03)" no-undo.  
def input param v_cod_ser   as char format "x(02)" no-undo.  
def input param v_cod_tit_acr as char format "x(10)" no-undo.
def input param v_cod_parcela as char format "x(02)" no-undo.


def var c-versao-prg as char initial " 1.00.00.001":U no-undo.

{include/i_dbinst.i}
{include/i_dbtype.i}
{include/i_fcldef.i}


&IF "{&EMSFND_VERSION}" >= "1.00" &THEN
{include/i-license-manager.i sea_tit_acr_cartao ACR}
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
                                    "sea_tit_acr_cartao","~~EMSFIN", "~~{~&emsfin_version}", "~~5.01")) /*msg_5009*/.
&else

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
def var v_cod_dat_type
    as character
    format "x(8)":U
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
&IF "{&emsfin_version}" >= "" AND "{&emsfin_version}" < "5.07A" &THEN
def var v_cod_estab_fim
    as character
    format "x(3)":U
    initial "ZZZ"
    label "atÇ"
    column-label "Estab Final"
    no-undo.
&ENDIF
&IF "{&emsfin_version}" >= "5.07A" AND "{&emsfin_version}" < "9.99" &THEN
def var v_cod_estab_fim
    as Character
    format "x(5)":U
    initial "ZZZZZ"
    label "atÇ"
    column-label "Estab Final"
    no-undo.
&ENDIF
&IF "{&emsfin_version}" >= "" AND "{&emsfin_version}" < "5.07A" &THEN
def var v_cod_estab_ini
    as character
    format "x(3)":U
    label "Estabelecimento"
    column-label "Estab Inicial"
    no-undo.
&ENDIF
&IF "{&emsfin_version}" >= "5.07A" AND "{&emsfin_version}" < "9.99" &THEN
def var v_cod_estab_ini
    as Character
    format "x(5)":U
    label "Estabelecimento"
    column-label "Estab Inicial"
    no-undo.
&ENDIF
def new global shared var v_cod_estab_usuar
    as character
    format "x(3)":U
    label "Estabelecimento"
    column-label "Estab"
    no-undo.
def var v_cod_final
    as character
    format "x(8)":U
    initial ?
    label "Final"
    no-undo.
def var v_cod_format
    as character
    format "x(8)":U
    label "Formato"
    column-label "Formato"
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
def var v_cod_initial
    as character
    format "x(8)":U
    initial ?
    label "Inicial"
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
def var v_cod_tit_acr_fim
    as character
    format "x(10)":U
    initial "ZZZZZZZZZZ"
    label "atÇ"
    column-label "atÇ"
    no-undo.
def var v_cod_tit_acr_ini
    as character
    format "x(10)":U
    label "T°tulo"
    column-label "T°tulo"
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
def var v_log_filtro
    as logical
    format "Sim/N∆o"
    initial no
    no-undo.
def var v_log_modul_vendor
    as logical
    format "Sim/N∆o"
    initial no
    no-undo.
def var v_log_sdo_tit_acr
    as logical
    format "Sim/N∆o"
    initial yes
    view-as toggle-box
    label "Tem Saldo"
    no-undo.
def var v_log_sdo_tit_acr_nao
    as logical
    format "Sim/N∆o"
    initial yes
    view-as toggle-box
    label "N∆o Tem Saldo"
    no-undo.
def var v_nom_attrib
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
def var v_rec_log
    as recid
    format ">>>>>>9":U
    no-undo.
def var v_rec_table
    as recid
    format ">>>>>>9":U
    initial ?
    no-undo.
def var v_rec_table_epc
    as recid
    format ">>>>>>9":U
    no-undo.
def var v_row_table
    as ROWID
    no-undo.
def new global shared var v_rec_tit_acr
    as recid
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

/************************** Query Definition Begin **************************/

def query qr_sea_tit_acr_cartao
    for tit_acr,
        tit_acr_cartao
    scrolling.


/*************************** Query Definition End ***************************/

/************************** Browse Definition Begin *************************/

def browse br_sea_tit_acr_cartao query qr_sea_tit_acr_cartao display
    tit_acr.cod_estab
    width-chars 03.86
        column-label "Estab"
    tit_acr_cartao.serie_cupom
    width-chars 03.43
        column-label "SÇrie"
    tit_acr_cartao.num_cupom
    WIDTH-CHARS 10.00
        COLUMN-LABEL "Cupom"
    tit_acr_cartao.cod_parc
    width-chars 5.00 column-label "Parc"
    tit_acr_cartao.num_seq
    width-chars 05.00
        column-label "Seq"
    tit_acr_cartao.cartao_manual
    width-chars 05.00
        column-label "Manual" FORMAT "Sim/N∆o"
    tit_acr_cartao.cod_admdra
    width-chars 15.00
        column-label "Administradora"
    tit_acr_cartao.cod_comprov_vda 
    width-chars 20.00
        column-label "Comprovante Vda"
    tit_acr_cartao.cod_autoriz_cartao_cr
    width-chars 20.00
        column-label "Aut Cartao"
    tit_acr_cartao.dat_vda_cartao_cr 
    width-chars 10.00
        column-label "Dt Vda"
    tit_acr_cartao.dat_cred_cartao_cr
    width-chars 10.00
        column-label "Dt Credito"
    tit_acr_cartao.val_comprov_vda
    width-chars 14.00
        column-label "Valor Comp Venda"
    tit_acr_cartao.val_des_admdra
    width-chars 14.00
        column-label "Valor ADM"
    tit_acr_cartao.ind_sit_tit_acr
    width-chars 13.00
        column-label "Ind Situaá∆o"
    tit_acr_cartao.cod_res_vda
    width-chars 20.00
        column-label "Resumo Vda"
    tit_acr_cartao.cod_estab_liq
    width-chars 05.00
        column-label "Est Liq"
    tit_acr_cartao.cod_refer_lote_liq
    width-chars 13.00
        column-label "Refer Lote Liq"
    
    with no-box separators single 
         size 88.00 by 08.00
         font 1
         bgcolor 15.


/*************************** Browse Definition End **************************/

/************************ Rectangle Definition Begin ************************/

def rectangle rt_001
    size 1 by 1
    edge-pixels 2.
def rectangle rt_cxcf
    size 1 by 1
    fgcolor 1 edge-pixels 2.
def rectangle rt_cxcl
    size 1 by 1
    edge-pixels 2.
def rectangle rt_mold
    size 1 by 1
    edge-pixels 2.


/************************* Rectangle Definition End *************************/

/************************** Button Definition Begin *************************/

def button bt_add2
    label "Inclui"
    tooltip "Inclui"
    size 1 by 1.
def button bt_can
    label "Cancela"
    tooltip "Cancela"
    size 1 by 1
    auto-endkey.
def button bt_det2
    label "Detalhe"
    tooltip "Detalhe"
    size 1 by 1.
def button bt_fil
    label "Filtro"
    tooltip "Filtro"
    size 1 by 1.
def button bt_hel2
    label "Ajuda"
    tooltip "Ajuda"
    size 1 by 1.
def button bt_mod2
    label "Modifica NSU"
    tooltip "Modifica NSU"
    size 1 by 1.
def button bt_ok
    label "OK"
    tooltip "OK"
    size 1 by 1
    auto-go.
def button bt_ran
    label "Faixa"
    tooltip "Faixa"
    size 1 by 1.
/****************************** Function Button *****************************/


/*************************** Button Definition End **************************/

/************************ Radio-Set Definition Begin ************************/

def var rs_sea_tit_acr_cartao
    as character
    initial "Por Num. Cupom"
    view-as radio-set Horizontal
    radio-buttons "Por Num.Cupom", "Por Num. Cupom","Por Valor Cupom", "Por Valor Cupom","Por Indicador Situaá∆o", "Por Indicador Situaá∆o","Por Cart∆o Manual", "Por Cart∆o Manual"
    bgcolor 25 
    no-undo.


/************************* Radio-Set Definition End *************************/

/************************** Frame Definition Begin **************************/

def frame f_fil_01_tit_acr
    rt_001
         at row 01.50 col 02.00
    " Saldo do T°tulo " view-as text
         at row 01.20 col 04.00 bgcolor 8 
    rt_cxcf
         at row 04.43 col 02.00 bgcolor 7 
    v_log_sdo_tit_acr
         at row 02.00 col 18.00 label "Tem Saldo"
         help "T°tulo ACR com Saldo ?"
         view-as toggle-box
    v_log_sdo_tit_acr_nao
         at row 03.00 col 18.00 label "N∆o Tem Saldo"
         help "T°tulo ACR sem Saldo ?"
         view-as toggle-box
    bt_ok
         at row 04.63 col 03.00 font ?
         help "OK"
    bt_can
         at row 04.63 col 14.00 font ?
         help "Cancela"
    bt_hel2
         at row 04.63 col 36.00 font ?
         help "Ajuda"
    with 1 down side-labels no-validate keep-tab-order three-d
         size-char 48.43 by 06.25 default-button bt_ok
         view-as dialog-box
         font 1 fgcolor ? bgcolor 8
         title "Filtro T°tulo Contas a Receber".
    /* adjust size of objects in this frame */
    assign bt_can:width-chars   in frame f_fil_01_tit_acr = 10.00
           bt_can:height-chars  in frame f_fil_01_tit_acr = 01.00
           bt_hel2:width-chars  in frame f_fil_01_tit_acr = 10.00
           bt_hel2:height-chars in frame f_fil_01_tit_acr = 01.00
           bt_ok:width-chars    in frame f_fil_01_tit_acr = 10.00
           bt_ok:height-chars   in frame f_fil_01_tit_acr = 01.00
           rt_001:width-chars   in frame f_fil_01_tit_acr = 45.00
           rt_001:height-chars  in frame f_fil_01_tit_acr = 02.50
           rt_cxcf:width-chars  in frame f_fil_01_tit_acr = 44.99
           rt_cxcf:height-chars in frame f_fil_01_tit_acr = 01.42.
    /* set private-data for the help system */
    assign v_log_sdo_tit_acr:private-data     in frame f_fil_01_tit_acr = "HLP=000024352":U
           v_log_sdo_tit_acr_nao:private-data in frame f_fil_01_tit_acr = "HLP=000024353":U
           bt_ok:private-data                 in frame f_fil_01_tit_acr = "HLP=000010721":U
           bt_can:private-data                in frame f_fil_01_tit_acr = "HLP=000011050":U
           bt_hel2:private-data               in frame f_fil_01_tit_acr = "HLP=000011326":U
           frame f_fil_01_tit_acr:private-data                          = "HLP=000024846".

def frame f_ran_01_tit_acr_chave
    rt_mold
         at row 01.21 col 02.00
    rt_cxcf
         at row 05.79 col 02.00 bgcolor 7 
&IF "{&emsfin_version}" >= "" AND "{&emsfin_version}" < "5.07A" &THEN
    v_cod_estab_ini
         at row 01.38 col 19.00 colon-aligned label "Estabelecimento"
         help "C¢digo Estabelecimento Inicial"
         view-as fill-in
         size-chars 4.14 by .88
         fgcolor ? bgcolor 15 font 2
&ENDIF
&IF "{&emsfin_version}" >= "5.07A" AND "{&emsfin_version}" < "9.99" &THEN
    v_cod_estab_ini
         at row 01.38 col 19.00 colon-aligned label "Estabelecimento"
         help "C¢digo Estabelecimento Inicial"
         view-as fill-in
         size-chars 6.14 by .88
         fgcolor ? bgcolor 15 font 2
&ENDIF
&IF "{&emsfin_version}" >= "" AND "{&emsfin_version}" < "5.07A" &THEN
    v_cod_estab_fim
         at row 01.38 col 38.00 colon-aligned label "atÇ"
         help "C¢digo Estabelecimento Final"
         view-as fill-in
         size-chars 4.14 by .88
         fgcolor ? bgcolor 15 font 2
&ENDIF
&IF "{&emsfin_version}" >= "5.07A" AND "{&emsfin_version}" < "9.99" &THEN
    v_cod_estab_fim
         at row 01.38 col 38.00 colon-aligned label "atÇ"
         help "C¢digo Estabelecimento Final"
         view-as fill-in
         size-chars 6.14 by .88
         fgcolor ? bgcolor 15 font 2
&ENDIF
    v_cod_espec_docto_ini
         at row 02.38 col 19.00 colon-aligned label "EspÇcie"
         help "C¢digo Inicial"
         view-as fill-in
         size-chars 4.14 by .88
         fgcolor ? bgcolor 15 font 2
    v_cod_espec_docto_fim
         at row 02.38 col 38.00 colon-aligned label "atÇ"
         help "C¢digo Final"
         view-as fill-in
         size-chars 4.14 by .88
         fgcolor ? bgcolor 15 font 2
    v_cod_ser_docto_ini
         at row 03.38 col 19.00 colon-aligned label "SÇrie"
         help "C¢digo SÇrie Documento"
         view-as fill-in
         size-chars 4.14 by .88
         fgcolor ? bgcolor 15 font 2
    v_cod_ser_docto_fim
         at row 03.38 col 38.00 colon-aligned label "atÇ"
         help "C¢digo SÇrie Documento"
         view-as fill-in
         size-chars 4.14 by .88
         fgcolor ? bgcolor 15 font 2
    v_cod_tit_acr_ini
         at row 04.38 col 19.00 colon-aligned label "T°tulo"
         help "C¢digo T°tulo Contas a Receber"
         view-as fill-in
         size-chars 11.14 by .88
         fgcolor ? bgcolor 15 font 2
    v_cod_tit_acr_fim
         at row 04.38 col 38.00 colon-aligned label "atÇ"
         help "C¢digo T°tulo Contas a Receber"
         view-as fill-in
         size-chars 11.14 by .88
         fgcolor ? bgcolor 15 font 2
    bt_ok
         at row 06.00 col 03.00 font ?
         help "OK"
    bt_can
         at row 06.00 col 14.00 font ?
         help "Cancela"
    bt_hel2
         at row 06.00 col 46.00 font ?
         help "Ajuda"
    with 1 down side-labels no-validate keep-tab-order three-d
         size-char 58.43 by 07.63 default-button bt_ok
         view-as dialog-box
         font 1 fgcolor ? bgcolor 8
         title "Faixa - T°tulo Contas a Receber".
    /* adjust size of objects in this frame */
    assign bt_can:width-chars   in frame f_ran_01_tit_acr_chave = 10.00
           bt_can:height-chars  in frame f_ran_01_tit_acr_chave = 01.00
           bt_hel2:width-chars  in frame f_ran_01_tit_acr_chave = 10.00
           bt_hel2:height-chars in frame f_ran_01_tit_acr_chave = 01.00
           bt_ok:width-chars    in frame f_ran_01_tit_acr_chave = 10.00
           bt_ok:height-chars   in frame f_ran_01_tit_acr_chave = 01.00
           rt_cxcf:width-chars  in frame f_ran_01_tit_acr_chave = 55.00
           rt_cxcf:height-chars in frame f_ran_01_tit_acr_chave = 01.42
           rt_mold:width-chars  in frame f_ran_01_tit_acr_chave = 55.00
           rt_mold:height-chars in frame f_ran_01_tit_acr_chave = 04.21.
    /* set private-data for the help system */
    assign v_cod_estab_ini:private-data       in frame f_ran_01_tit_acr_chave = "HLP=000016633":U
           v_cod_estab_fim:private-data       in frame f_ran_01_tit_acr_chave = "HLP=000016634":U
           v_cod_espec_docto_ini:private-data in frame f_ran_01_tit_acr_chave = "HLP=000016628":U
           v_cod_espec_docto_fim:private-data in frame f_ran_01_tit_acr_chave = "HLP=000016629":U
           v_cod_ser_docto_ini:private-data   in frame f_ran_01_tit_acr_chave = "HLP=000016635":U
           v_cod_ser_docto_fim:private-data   in frame f_ran_01_tit_acr_chave = "HLP=000016636":U
           v_cod_tit_acr_ini:private-data     in frame f_ran_01_tit_acr_chave = "HLP=000016637":U
           v_cod_tit_acr_fim:private-data     in frame f_ran_01_tit_acr_chave = "HLP=000016638":U
           bt_ok:private-data                 in frame f_ran_01_tit_acr_chave = "HLP=000010721":U
           bt_can:private-data                in frame f_ran_01_tit_acr_chave = "HLP=000011050":U
           bt_hel2:private-data               in frame f_ran_01_tit_acr_chave = "HLP=000011326":U
           frame f_ran_01_tit_acr_chave:private-data                          = "HLP=000024846".

def frame f_sea_01_tit_acr
    rt_cxcf
         at row 12.25 col 02.00 bgcolor 7 
    rt_cxcl
         at row 01.00 col 01.00 bgcolor 15 
    rs_sea_tit_acr_cartao
         at row 01.21 col 03.00
         help "" no-label
    br_sea_tit_acr_cartao
         at row 02.25 col 01.00
         help "T°tulos ACR"
    bt_add2
         at row 10.75 col 02.00 font ?
         help "Inclui"
    bt_mod2
         at row 10.75 col 13.00 font ?
         help "Modifica"
    bt_det2
         at row 10.75 col 26.00 font ?
         help "Detalhe"
    bt_ran
         at row 10.75 col 38.00 font ?
         help "Faixa"
    bt_fil
         at row 10.75 col 50.00 font ?
         help "Filtro"
    bt_ok
         at row 12.46 col 03.00 font ?
         help "OK"
    bt_can
         at row 12.46 col 14.00 font ?
         help "Cancela"
    bt_hel2
         at row 12.46 col 77.14 font ?
         help "Ajuda"
    with 1 down side-labels no-validate keep-tab-order three-d
         size-char 89.57 by 14.08 default-button bt_ok
         view-as dialog-box
         font 1 fgcolor ? bgcolor 8
         title "Consulta Cupom Relacionados".
    /* adjust size of objects in this frame */
    assign bt_add2:width-chars  in frame f_sea_01_tit_acr = 10.00
           bt_add2:height-chars in frame f_sea_01_tit_acr = 01.00
           bt_can:width-chars   in frame f_sea_01_tit_acr = 10.00
           bt_can:height-chars  in frame f_sea_01_tit_acr = 01.00
           bt_det2:width-chars  in frame f_sea_01_tit_acr = 10.00
           bt_det2:height-chars in frame f_sea_01_tit_acr = 01.00
           bt_fil:width-chars   in frame f_sea_01_tit_acr = 10.00
           bt_fil:height-chars  in frame f_sea_01_tit_acr = 01.00
           bt_hel2:width-chars  in frame f_sea_01_tit_acr = 10.00
           bt_hel2:height-chars in frame f_sea_01_tit_acr = 01.00
           bt_mod2:width-chars  in frame f_sea_01_tit_acr = 12.00
           bt_mod2:height-chars in frame f_sea_01_tit_acr = 01.00
           bt_ok:width-chars    in frame f_sea_01_tit_acr = 10.00
           bt_ok:height-chars   in frame f_sea_01_tit_acr = 01.00
           bt_ran:width-chars   in frame f_sea_01_tit_acr = 10.00
           bt_ran:height-chars  in frame f_sea_01_tit_acr = 01.00
           rt_cxcf:width-chars  in frame f_sea_01_tit_acr = 86.14
           rt_cxcf:height-chars in frame f_sea_01_tit_acr = 01.42
           rt_cxcl:width-chars  in frame f_sea_01_tit_acr = 88.00
           rt_cxcl:height-chars in frame f_sea_01_tit_acr = 01.25.
&if '{&emsbas_version}' >= '5.06' &then
if OPSYS = 'WIN32':U then do:
assign br_sea_tit_acr_cartao:ALLOW-COLUMN-SEARCHING in frame f_sea_01_tit_acr = no
       br_sea_tit_acr_cartao:COLUMN-MOVABLE in frame f_sea_01_tit_acr = no.
end.
&endif
    /* set private-data for the help system */
    assign rs_sea_tit_acr_cartao:private-data in frame f_sea_01_tit_acr = "HLP=000024846":U
           br_sea_tit_acr_cartao:private-data in frame f_sea_01_tit_acr = "HLP=000024846":U
           bt_add2:private-data        in frame f_sea_01_tit_acr = "HLP=000010825":U
           bt_mod2:private-data        in frame f_sea_01_tit_acr = "HLP=000010827":U
           bt_det2:private-data        in frame f_sea_01_tit_acr = "HLP=000010805":U
           bt_ran:private-data         in frame f_sea_01_tit_acr = "HLP=000008967":U
           bt_fil:private-data         in frame f_sea_01_tit_acr = "HLP=000008966":U
           bt_ok:private-data          in frame f_sea_01_tit_acr = "HLP=000010721":U
           bt_can:private-data         in frame f_sea_01_tit_acr = "HLP=000011050":U
           bt_hel2:private-data        in frame f_sea_01_tit_acr = "HLP=000011326":U
           frame f_sea_01_tit_acr:private-data                   = "HLP=000024846".



{include/i_fclfrm.i f_fil_01_tit_acr f_ran_01_tit_acr_chave f_sea_01_tit_acr }
/*************************** Frame Definition End ***************************/

/*********************** User Interface Trigger Begin ***********************/


ON CHOOSE OF bt_hel2 IN FRAME f_fil_01_tit_acr
DO:


    /* Begin_Include: i_context_help_frame */
    run prgtec/men/men900za.py (Input self:frame,
                                Input this-procedure:handle) /*prg_fnc_chamar_help_context*/.


    /* End_Include: i_context_help_frame */

END. /* ON CHOOSE OF bt_hel2 IN FRAME f_fil_01_tit_acr */

ON CHOOSE OF bt_hel2 IN FRAME f_ran_01_tit_acr_chave
DO:


    /* Begin_Include: i_context_help_frame */
    run prgtec/men/men900za.py (Input self:frame,
                                Input this-procedure:handle) /*prg_fnc_chamar_help_context*/.


    /* End_Include: i_context_help_frame */

END. /* ON CHOOSE OF bt_hel2 IN FRAME f_ran_01_tit_acr_chave */

ON INS OF br_sea_tit_acr_cartao IN FRAME f_sea_01_tit_acr
DO:

    if  bt_add2:sensitive in frame f_sea_01_tit_acr
    then do:
        apply "choose" to bt_add2 in frame f_sea_01_tit_acr.
    end /* if */.

END. /* ON INS OF br_sea_tit_acr_cartao IN FRAME f_sea_01_tit_acr */

ON CHOOSE OF bt_add2 IN FRAME f_sea_01_tit_acr
DO:

    assign v_rec_tit_acr = v_rec_table.
    if  search("add_tit_acr") = ? then do:
        if  v_cod_dwb_user begins 'es_' then
            return "Programa execut†vel n∆o foi encontrado:" /*l_programa_nao_encontrado*/  + "add_tit_acr".
        else do:
            message "Programa execut†vel n∆o foi encontrado:" /*l_programa_nao_encontrado*/  "add_tit_acr"
                   view-as alert-box error buttons ok.
            return.
        end.
    end.
    else
        run add_tit_acr /*prg_add_tit_acr*/.
    assign v_rec_table = v_rec_tit_acr.
    run pi_open_sea_tit_acr_cartao /*pi_open_sea_tit_acr_cartao*/.
    reposition qr_sea_tit_acr_cartao to RECID v_rec_table no-error.


END. /* ON CHOOSE OF bt_add2 IN FRAME f_sea_01_tit_acr */

ON CHOOSE OF bt_can IN FRAME f_sea_01_tit_acr
DO:

    apply "end-error" to self.
END. /* ON CHOOSE OF bt_can IN FRAME f_sea_01_tit_acr */

ON CHOOSE OF bt_det2 IN FRAME f_sea_01_tit_acr
DO:

    if  avail tit_acr
    then do:
        assign v_rec_tit_acr = recid(tit_acr).
        if  search("prgfin/acr/acr212ia.r") = ? and search("prgfin/acr/acr212ia.p") = ? then do:
            if  v_cod_dwb_user begins 'es_' then
                return "Programa execut†vel n∆o foi encontrado:" /*l_programa_nao_encontrado*/  + "prgfin/acr/acr212ia.p".
            else do:
                message "Programa execut†vel n∆o foi encontrado:" /*l_programa_nao_encontrado*/  "prgfin/acr/acr212ia.p"
                       view-as alert-box error buttons ok.
                return.
            end.
        end.
        else
            run prgfin/acr/acr212ia.p /*prg_det_tit_acr*/.
        if  v_rec_tit_acr <> ?
        then do:
            assign v_rec_table = v_rec_tit_acr.
            reposition qr_sea_tit_acr_cartao to recid v_rec_table no-error.
        end /* if */.
    end /* if */.
END. /* ON CHOOSE OF bt_det2 IN FRAME f_sea_01_tit_acr */

ON CHOOSE OF bt_fil IN FRAME f_sea_01_tit_acr
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


    /* Begin_Include: i_sea_filter */

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
                     run prgtec/men/men900za.py (Input bt_hel2:frame in frame f_fil_01_tit_acr,
                                                 Input this-procedure:handle) /*prg_fnc_chamar_help_context*/. /* fnc_chamar_help_context*/
           end triggers.


    create menu-item wgh_popup_menu_about
           assign label   = "Sobre" /*l_sobre*/ 
                  parent  = wgh_popup_menu
           triggers :
                 on choose do:

                    /* Begin_Include: i_about_call */
                    assign v_nom_prog     = substring(current-window:title, 1, max(1, length(current-window:title) - 10))
                                          + chr(10)
                                          + "sea_tit_acr_cartao":U
                           v_nom_prog_ext = "prgfin/spp/spp212aa.p":U
                           v_cod_release  = trim(" 1.00.00.001":U).
                    run prgtec/btb/btb901zb.p (Input v_nom_prog,
                                               Input v_nom_prog_ext,
                                               Input v_cod_release) /*prg_fnc_about*/.
                    /* End_Include: i_about_call */

                 end.
           end triggers.

    assign bt_hel2:POPUP-MENU IN FRAME f_fil_01_tit_acr = wgh_popup_menu.



    view frame f_fil_01_tit_acr.

    filter_block:
    do on error undo filter_block, retry filter_block:
        update v_log_sdo_tit_acr
               v_log_sdo_tit_acr_nao
               bt_ok
               bt_can
               bt_hel2
               with frame f_fil_01_tit_acr.
        assign input frame f_fil_01_tit_acr v_log_sdo_tit_acr
               input frame f_fil_01_tit_acr v_log_sdo_tit_acr_nao.
        run pi_open_sea_tit_acr_cartao /*pi_open_sea_tit_acr_cartao*/.
    end /* do filter_block */.

    hide frame f_fil_01_tit_acr.
    /* End_Include: i_about_call */


END. /* ON CHOOSE OF bt_fil IN FRAME f_sea_01_tit_acr */

ON CHOOSE OF bt_hel2 IN FRAME f_sea_01_tit_acr
DO:


    /* Begin_Include: i_context_help_frame */
    run prgtec/men/men900za.py (Input self:frame,
                                Input this-procedure:handle) /*prg_fnc_chamar_help_context*/.


    /* End_Include: i_context_help_frame */

END. /* ON CHOOSE OF bt_hel2 IN FRAME f_sea_01_tit_acr */

ON CHOOSE OF bt_mod2 IN FRAME f_sea_01_tit_acr
DO:
    DEFINE BUFFER bf-tit_acr_cartao FOR tit_acr_cartao.

    DEFINE VARIABLE iNumLinha AS INTEGER                   NO-UNDO.
    DEFINE VARIABLE c-num-nsu AS CHARACTER FORMAT "x(10)"  NO-UNDO.

    if  AVAIL tit_acr AND AVAIL tit_acr_cartao 
    then do:
        ASSIGN iNumLinha = br_sea_tit_acr_cartao:FOCUSED-ROW.

        ASSIGN c-num-nsu = tit_acr_cartao.cod_comprov_vda.
/*         RUN prgfin/spp/spp212ab.r(INPUT-OUTPUT c-num-nsu) NO-ERROR.  */

        run prgfin/spp/spp212ab.p (Input "character",
                                   Input "x(15)",
                                   Input "NSU",
                                   input-output c-num-nsu,
                                   input-output c-num-nsu) /*prg_fnc_generic_range*/.

        IF RETURN-VALUE = "OK" THEN DO:
            FIND FIRST bf-tit_acr_cartao EXCLUSIVE-LOCK
                 WHERE ROWID(bf-tit_acr_cartao)           = ROWID(tit_acr_cartao)
                   AND bf-tit_acr_cartao.cod_comprov_vda <> c-num-nsu NO-ERROR.
            IF AVAIL bf-tit_acr_cartao THEN DO:
                ASSIGN bf-tit_acr_cartao.cod_comprov_vda = c-num-nsu.
            END.
            RELEASE bf-tit_acr_cartao.
        END.
        
        assign v_rec_tit_acr = recid(tit_acr)
               v_rec_table    = recid(tit_acr)
               v_row_table    = ROWID(tit_acr_cartao).
/*         if  search("prgfin/acr/acr040ea.r") = ? and search("prgfin/acr/acr040ea.p") = ? then do:                           */
/*             if  v_cod_dwb_user begins 'es_' then                                                                           */
/*                 return "Programa execut†vel n∆o foi encontrado:" /*l_programa_nao_encontrado*/  + "prgfin/acr/acr040ea.p". */
/*             else do:                                                                                                       */
/*                 message "Programa execut†vel n∆o foi encontrado:" /*l_programa_nao_encontrado*/  "prgfin/acr/acr040ea.p"   */
/*                        view-as alert-box error buttons ok.                                                                 */
/*                 return.                                                                                                    */
/*             end.                                                                                                           */
/*         end.                                                                                                               */
/*         else                                                                                                               */
/*             run prgfin/acr/acr040ea.p /*prg_mod_tit_acr*/.                                                                 */
/*         if  v_rec_tit_acr <> ?                  */
/*         then do:                                */
/*             assign v_rec_table = v_rec_tit_acr. */
/*         end /* if */.                           */
        run pi_open_sea_tit_acr_cartao /*pi_open_sea_tit_acr_cartao*/.
/*         reposition qr_sea_tit_acr_cartao to RECID v_rec_table no-error. */

        br_sea_tit_acr_cartao:SELECT-ROW(iNumLinha).
      
    end /* if */.
END. /* ON CHOOSE OF bt_mod2 IN FRAME f_sea_01_tit_acr */

ON CHOOSE OF bt_ok IN FRAME f_sea_01_tit_acr
DO:

    if  avail tit_acr
    then do:
        assign v_rec_tit_acr = recid(tit_acr).
    end /* if */.
END. /* ON CHOOSE OF bt_ok IN FRAME f_sea_01_tit_acr */

ON CHOOSE OF bt_ran IN FRAME f_sea_01_tit_acr
DO:

    if  search("prgtec/btb/btb901za.r") = ? and search("prgtec/btb/btb901za.p") = ? then do:
        if  v_cod_dwb_user begins 'es_' then
            return "Programa execut†vel n∆o foi encontrado:" /*l_programa_nao_encontrado*/  + "prgtec/btb/btb901za.p".
        else do:
            message "Programa execut†vel n∆o foi encontrado:" /*l_programa_nao_encontrado*/  "prgtec/btb/btb901za.p"
                view-as alert-box error buttons ok.
            return.
        end.
    end.
    else
        run prgtec/btb/btb901za.p (Input v_cod_dat_type,
                                   Input v_cod_format,
                                   Input v_nom_attrib,
                                   input-output v_cod_initial,
                                   input-output v_cod_final) /*prg_fnc_generic_range*/.
    
    if  return-value <> 'NOK' then
        run pi_open_sea_tit_acr_cartao /*pi_open_sea_tit_acr_cartao*/.
    
END. /* ON CHOOSE OF bt_ran IN FRAME f_sea_01_tit_acr */

ON VALUE-CHANGED OF rs_sea_tit_acr_cartao IN FRAME f_sea_01_tit_acr
DO:

    /* inifim: */
    case input frame f_sea_01_tit_acr  rs_sea_tit_acr_cartao:
        when "Por Num. Cupom" then block_1:
         do:
            assign v_cod_dat_type        = "character"
                   v_cod_format          = "x(20)":U
                   v_nom_attrib          = "N£mero Cupom"
                   v_cod_initial         = string("":U)
                   v_cod_final           = string("ZZZZZZZZZZZZZ":U).
                   
        end /* do block_2 */.
        
        when "Por Valor Cupom" then block_1:
         do:
            assign v_cod_dat_type = "decimal"
                   v_cod_format   = ">>>,>>>,>>9.99":U
                   v_nom_attrib   = "Valor Cupom"
                   v_cod_initial  = string(0)
                   v_cod_final    = string(999999999).
        end /* do block_1 */.

        when "Por Indicador Situaá∆o" then block_3:
         do:
            assign v_cod_dat_type        = "character"
                   v_cod_format          = "x(13)":U
                   v_nom_attrib          = "Indicador Situaá∆o"
                   v_cod_initial         = string("":U)
                   v_cod_final           = string("ZZZZZZZZZZZZZ":U).
                   
        end /* do block_2 */.

        when "Por Cart∆o Manual":U then block_1:
         do:
            assign v_cod_dat_type        = "character"
               v_cod_format          = "x(20)":U
               v_nom_attrib          = "N£mero Cupom"
               v_cod_initial         = string("":U)
               v_cod_final           = string("ZZZZZZZZZZZZZ":U).
        end /* do block_2 */.

        
    end /* case inifim */.

    apply "choose" to bt_ran in frame f_sea_01_tit_acr.

END. /* ON VALUE-CHANGED OF rs_sea_tit_acr_cartao IN FRAME f_sea_01_tit_acr */


/************************ User Interface Trigger End ************************/

/**************************** Frame Trigger Begin ***************************/


ON HELP OF FRAME f_fil_01_tit_acr ANYWHERE
DO:


    /* Begin_Include: i_context_help */
    run prgtec/men/men900za.py (Input self:handle,
                                Input this-procedure:handle) /*prg_fnc_chamar_help_context*/.
    /* End_Include: i_context_help */

END. /* ON HELP OF FRAME f_fil_01_tit_acr */

ON RIGHT-MOUSE-DOWN OF FRAME f_fil_01_tit_acr ANYWHERE
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

END. /* ON RIGHT-MOUSE-DOWN OF FRAME f_fil_01_tit_acr */

ON RIGHT-MOUSE-UP OF FRAME f_fil_01_tit_acr ANYWHERE
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

END. /* ON RIGHT-MOUSE-UP OF FRAME f_fil_01_tit_acr */

ON WINDOW-CLOSE OF FRAME f_fil_01_tit_acr
DO:

    apply "end-error" to self.
END. /* ON WINDOW-CLOSE OF FRAME f_fil_01_tit_acr */

ON HELP OF FRAME f_ran_01_tit_acr_chave ANYWHERE
DO:


    /* Begin_Include: i_context_help */
    run prgtec/men/men900za.py (Input self:handle,
                                Input this-procedure:handle) /*prg_fnc_chamar_help_context*/.
    /* End_Include: i_context_help */

END. /* ON HELP OF FRAME f_ran_01_tit_acr_chave */

ON RIGHT-MOUSE-DOWN OF FRAME f_ran_01_tit_acr_chave ANYWHERE
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

END. /* ON RIGHT-MOUSE-DOWN OF FRAME f_ran_01_tit_acr_chave */

ON RIGHT-MOUSE-UP OF FRAME f_ran_01_tit_acr_chave ANYWHERE
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

END. /* ON RIGHT-MOUSE-UP OF FRAME f_ran_01_tit_acr_chave */

ON WINDOW-CLOSE OF FRAME f_ran_01_tit_acr_chave
DO:

    apply "end-error" to self.
END. /* ON WINDOW-CLOSE OF FRAME f_ran_01_tit_acr_chave */

ON END-ERROR OF FRAME f_sea_01_tit_acr
DO:

    assign v_rec_tit_acr = ?.
END. /* ON END-ERROR OF FRAME f_sea_01_tit_acr */

ON ENTRY OF FRAME f_sea_01_tit_acr
DO:

    apply "value-changed" to rs_sea_tit_acr_cartao in frame f_sea_01_tit_acr.
END. /* ON ENTRY OF FRAME f_sea_01_tit_acr */

ON HELP OF FRAME f_sea_01_tit_acr ANYWHERE
DO:


    /* Begin_Include: i_context_help */
    run prgtec/men/men900za.py (Input self:handle,
                                Input this-procedure:handle) /*prg_fnc_chamar_help_context*/.
    /* End_Include: i_context_help */

END. /* ON HELP OF FRAME f_sea_01_tit_acr */

ON RIGHT-MOUSE-DOWN OF FRAME f_sea_01_tit_acr ANYWHERE
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

END. /* ON RIGHT-MOUSE-DOWN OF FRAME f_sea_01_tit_acr */

ON RIGHT-MOUSE-UP OF FRAME f_sea_01_tit_acr ANYWHERE
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

END. /* ON RIGHT-MOUSE-UP OF FRAME f_sea_01_tit_acr */

ON WINDOW-CLOSE OF FRAME f_sea_01_tit_acr
DO:

    apply "end-error" to self.
END. /* ON WINDOW-CLOSE OF FRAME f_sea_01_tit_acr */


/***************************** Frame Trigger End ****************************/

/**************************** Menu Trigger Begin ****************************/


ON CHOOSE OF MENU-ITEM mi_conteudo IN MENU m_help
DO:


        apply "choose" to bt_hel2 in frame f_sea_01_tit_acr.





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


        assign v_nom_prog     = substring(frame f_sea_01_tit_acr:title, 1, max(1, length(frame f_sea_01_tit_acr:title) - 10)).
        if  v_nom_prog = ? then
            assign v_nom_prog = "".

        assign v_nom_prog     = v_nom_prog
                              + chr(10)
                              + "sea_tit_acr_cartao":U.




    assign v_nom_prog_ext = "prgfin/spp/spp212aa.p":U
           v_cod_release  = trim(" 1.00.00.001":U).
    run prgtec/btb/btb901zb.p (Input v_nom_prog,
                               Input v_nom_prog_ext,
                               Input v_cod_release) /*prg_fnc_about*/.
END. /* ON CHOOSE OF MENU-ITEM mi_sobre IN MENU m_help */


/***************************** Menu Trigger End *****************************/


/****************************** Main Code Begin *****************************/


/* Begin_Include: i_version_extract */
/* {include/i-ctrlrp5.i sea_tit_acr_cartao} */


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
    run pi_version_extract ('sea_tit_acr_cartao':U, 'prgfin/spp/spp212aa.p':U, '1.00.00.001':U, 'pro':U).
end /* if */.



/* End_Include: i_version_extract */

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
    run prgtec/men/men901za.py (Input 'sea_tit_acr_cartao') /*prg_fnc_verify_security*/.
if  return-value = "2014"
then do:
    /* Programa a ser executado n∆o Ç um programa v†lido Datasul ! */
    run pi_messages (input "show",
                     input 2014,
                     input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9",
                                       'sea_tit_acr_cartao')) /*msg_2014*/.
    return.
end /* if */.
if  return-value = "2012"
then do:
    /* Usu†rio sem permiss∆o para acessar o programa. */
    run pi_messages (input "show",
                     input 2012,
                     input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9",
                                       'sea_tit_acr_cartao')) /*msg_2012*/.
    return.
end /* if */.
/* End_Include: i_verify_security */



/* Begin_Include: i_log_exec_prog_dtsul_ini */
assign v_rec_log = ?.

if can-find(prog_dtsul
       where prog_dtsul.cod_prog_dtsul = 'sea_tit_acr_cartao' 
         and prog_dtsul.log_gera_log_exec = yes) then do transaction:
    create log_exec_prog_dtsul.
    assign log_exec_prog_dtsul.cod_prog_dtsul           = 'sea_tit_acr_cartao'
           log_exec_prog_dtsul.cod_usuario              = v_cod_usuar_corren
           log_exec_prog_dtsul.dat_inic_exec_prog_dtsul = today
           log_exec_prog_dtsul.hra_inic_exec_prog_dtsul = replace(string(time,"hh:mm:ss" /*l_hh:mm:ss*/ ),":":U,"":U).
    assign v_rec_log = recid(log_exec_prog_dtsul).
    release log_exec_prog_dtsul no-error.
end.


/* End_Include: i_log_exec_prog_dtsul_ini */


/* Begin_Include: ix_p00_sea_tit_acr_cartao */

/* Begin_Include: i_vrf_modul_vendor */

/* ** Verifica se o m¢dulo de vendor por ser utilizado ***/
/* VALIDAÄ«O DE LICENÄA DO M‡DULO VENDOR */
/* Trecho de c¢digo comentado em 08/08/2014
assign v_log_modul_vendor = no.
&IF  "{&emsfin_version}" /*l_{&emsfin_version}*/  >= '5.05' &THEN 
    find first licenc_produt_dtsul no-lock no-error. 
    if  avail licenc_produt_dtsul
    and licenc_produt_dtsul.cod_modul_dtsul_licenc <> ""
    and licenc_produt_dtsul.cod_modul_dtsul_licenc <> ?    then do: 
        if  substring(licenc_produt_dtsul.cod_modul_dtsul_licenc,29 /* posiá∆o do Vendor */,1) <> '0' THEN DO:
  */
            /* Begin_Include: i_testa_funcao_geral */
            &IF DEFINED(BF_FIN_VENDOR) &THEN
                assign v_log_modul_vendor = yes.
            &ELSE
                if  can-find (first histor_exec_especial no-lock
                     where histor_exec_especial.cod_modul_dtsul = "UFN" /*l_ufn*/ 
                     and   histor_exec_especial.cod_prog_dtsul  = 'SPP_VENDOR':U)
                then do:
                    assign v_log_modul_vendor = yes.
                end /* if */.

                /* Begin_Include: i_funcao_extract */
                if  v_cod_arq <> '' and v_cod_arq <> ?
                then do:

                    output stream s-arq to value(v_cod_arq) append.

                    put stream s-arq unformatted
                        'SPP_VENDOR'      at 1 
                        v_log_modul_vendor  at 43 skip.

                    output stream s-arq close.

                end /* if */.
                /* End_Include: i_funcao_extract */
                .
            &ENDIF
            /* End_Include: i_funcao_extract */
/*
        end.
    end.
&ENDIF
/* End_Include: i_funcao_extract */
Fim do trecho de c¢digo comentado em 08/08/2014 */ 

IF v_log_modul_vendor AND
   INDEX(PROGRAM-NAME(2), 'prgfin/acr/acr916zc.py') <> 0 THEN
    ASSIGN v_log_filtro = YES.
/* End_Include: i_funcao_extract */



/* Begin_Include: i_std_dialog_box */
/* tratamento do titulo e vers∆o */
assign frame f_sea_01_tit_acr:title = frame f_sea_01_tit_acr:title
                            + chr(32)
                            + chr(40)
                            + trim(" 1.00.00.001":U)
                            + chr(41).
/* menu pop-up de ajuda e sobre */
assign menu m_help:popup-only = yes
       bt_hel2:popup-menu in frame f_sea_01_tit_acr = menu m_help:handle.


/* End_Include: i_std_dialog_box */


assign br_sea_tit_acr_cartao:num-locked-columns in frame f_sea_01_tit_acr = 0.

pause 0 before-hide.
view frame f_sea_01_tit_acr.

assign v_rec_table    = v_rec_tit_acr.

main_block:
do on endkey undo main_block, leave main_block on error undo main_block, leave main_block.
    enable rs_sea_tit_acr_cartao
           br_sea_tit_acr_cartao
           bt_add2
           bt_mod2
           bt_det2
           bt_ran
           bt_fil
           bt_ok
           bt_can
           bt_hel2
           with frame f_sea_01_tit_acr.


    assign bt_fil:sensitive in frame f_sea_01_tit_acr = yes.
    if  index(program-name(2), "add_tit_acr") <> 0
    or   index(program-name(2), "prgfin/acr/acr040ea.p") <> 0
    or   index(program-name(2), "prgfin/acr/acr212ia.p") <> 0
    or   index(program-name(2), "era_tit_acr") <> 0
    then do:
         assign bt_add2:sensitive in frame f_sea_01_tit_acr = no
                bt_mod2:sensitive in frame f_sea_01_tit_acr = no
                bt_det2:sensitive in frame f_sea_01_tit_acr = no.
    end /* if */.


    /* Begin_Include: ix_p10_sea_tit_acr_cartao */
    /* Se este ZOOM for executado a partir do Vendor, foráa a pesquisa apenas dos
       t°tulos com saldo  */
    IF v_log_modul_vendor AND v_log_filtro = YES THEN
        ASSIGN bt_fil:SENSITIVE IN FRAME f_sea_01_tit_acr = NO
               v_log_sdo_tit_acr     = YES
               v_log_sdo_tit_acr_nao = NO.
    /* End_Include: ix_p10_sea_tit_acr_cartao */


/* **************
    @do(security_block) with frame @&(frame):
        @i(i_verify_security_button_sea &table=@&(table) &program_complement=@&(program_complement))
    @end_do(security_block).
***************/


    /* Begin_Include: ix_p15_sea_tit_acr_cartao */
    disable bt_add2
            bt_det2
            bt_fil
/*             bt_mod2 */
            with frame f_sea_01_tit_acr.
    /* End_Include: ix_p15_sea_tit_acr_cartao */


    wait-for go of frame f_sea_01_tit_acr
          or default-action of br_sea_tit_acr_cartao
          or mouse-select-dblclick of br_sea_tit_acr_cartao focus browse br_sea_tit_acr_cartao.

    /* ix_p20_sea_tit_acr_cartao */

    if  avail tit_acr
    then do:
        assign v_rec_tit_acr = recid(tit_acr).
    end /* if */.
end /* do main_block */.

hide frame f_sea_01_tit_acr.

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



/******************************* Main Code End ******************************/

/************************* Internal Procedure Begin *************************/

/*****************************************************************************
** Procedure Interna.....: pi_open_sea_tit_acr_cartao
** Descricao.............: pi_open_sea_tit_acr_cartao
** Criado por............: SARDI
** Criado em.............: 21/10/1996 10:38:40
** Alterado por..........: fut12180
** Alterado em...........: 11/11/2002 10:57:05
*****************************************************************************/
PROCEDURE pi_open_sea_tit_acr_cartao:

    if session:set-wait-state ("General" /*l_general*/ ) then.
    
    case input frame f_sea_01_tit_acr rs_sea_tit_acr_cartao:
         when "Por Num. Cupom" then
            cupom_block:
            do:                    
                open query qr_sea_tit_acr_cartao for
                each tit_acr no-lock
                    where tit_acr.cod_estab       = v_cod_estab
                      and tit_acr.cod_espec_docto = v_cod_espec 
                      and tit_acr.cod_ser_docto   = v_cod_ser
                      and tit_acr.cod_tit_acr     = v_cod_tit_acr
                      and tit_acr.cod_parcela     = v_cod_parcela,
                each tit_acr_cartao no-lock
                    where tit_acr_cartao.cod_estab        = v_cod_estab
                      and tit_acr_cartao.num_id_tit_acr   = tit_acr.num_id_tit_acr
                      and tit_acr_cartao.num_cupom >= v_cod_initial
                      and tit_acr_cartao.num_cupom <= v_cod_final
                       BY tit_acr_cartao.num_cupom.
        end.
        when "Por Valor Cupom" then
            emissao_block:
            do:                    
                open query qr_sea_tit_acr_cartao for
                each tit_acr no-lock
                    where tit_acr.cod_estab       = v_cod_estab
                      and tit_acr.cod_espec_docto = v_cod_espec 
                      and tit_acr.cod_ser_docto   = v_cod_ser
                      and tit_acr.cod_tit_acr     = v_cod_tit_acr
                      and tit_acr.cod_parcela     = v_cod_parcela,
                each tit_acr_cartao no-lock
                    where tit_acr_cartao.cod_estab        = v_cod_estab
                      and tit_acr_cartao.num_id_tit_acr   = tit_acr.num_id_tit_acr
                      and tit_acr_cartao.val_comprov_vda >= decimal(v_cod_initial)
                      and tit_acr_cartao.val_comprov_vda <= decimal(v_cod_final)
                       BY tit_acr_cartao.val_comprov_vda.
        end.
        when "Por Indicador Situaá∆o" then
            estab_block:
            do:
                open query qr_sea_tit_acr_cartao for
                each tit_acr no-lock
                    where tit_acr.cod_estab       = v_cod_estab
                      and tit_acr.cod_espec_docto = v_cod_espec 
                      and tit_acr.cod_ser_docto   = v_cod_ser
                      and tit_acr.cod_tit_acr     = v_cod_tit_acr
                      and tit_acr.cod_parcela     = v_cod_parcela,
                each tit_acr_cartao no-lock
                    where tit_acr_cartao.cod_estab        = v_cod_estab
                      and tit_acr_cartao.num_id_tit_acr   = tit_acr.num_id_tit_acr
                      and tit_acr_cartao.ind_sit_tit_acr >= v_cod_initial 
                      and tit_acr_cartao.ind_sit_tit_acr <= v_cod_final
                       BY tit_acr_cartao.ind_sit_tit_acr.
            end.
         when "Por Cart∆o Manual":U then
            cupom_block:
            do:                    
                open query qr_sea_tit_acr_cartao for
                each tit_acr no-lock
                    where tit_acr.cod_estab       = v_cod_estab
                      and tit_acr.cod_espec_docto = v_cod_espec 
                      and tit_acr.cod_ser_docto   = v_cod_ser
                      and tit_acr.cod_tit_acr     = v_cod_tit_acr
                      and tit_acr.cod_parcela     = v_cod_parcela,
                each tit_acr_cartao no-lock
                    where tit_acr_cartao.cod_estab        = v_cod_estab
                      and tit_acr_cartao.num_id_tit_acr   = tit_acr.num_id_tit_acr
                      and tit_acr_cartao.num_cupom >= v_cod_initial
                      and tit_acr_cartao.num_cupom <= v_cod_final
                       BY tit_acr_cartao.cartao_manual DESC.
           END.
       
    end /* case case_block */.
    
    
    if session:set-wait-state ("") then.
END PROCEDURE. /* pi_open_sea_tit_acr_cartao */
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
                "Programa Mensagem" c_prg_msg "n∆o encontrado."
                view-as alert-box error.
        return error.
    end.

    run value(c_prg_msg + ".p":U) (input c_action, input c_param).
    return return-value.
END PROCEDURE.  /* pi_messages */
/****************************  End of sea_tit_acr_cartao ***************************/
