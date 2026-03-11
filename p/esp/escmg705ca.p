/*****************************************************************************
** KML SISTEMAS
**
** Cliente...............: NISSEI
** Programa..............: escmg705aa
** Descricao.............: Cadastro Tipos de Transaá∆o Caixa para Aplicaá‰es e Resgates
** Versao................:  1.00.00.000
** Procedimento..........: tar_import_movto_cmg
** Nome Externo..........: esp/escmg705aa
** Criado por............: Eduardo Marcel Barth (edu_barth@hotmail.com)
** Criado em.............: 01/08/2023
******************************************************************************/
DEF VAR h_facelift AS HANDLE NO-UNDO.
DEF BUFFER histor_exec_especial FOR ems5.histor_exec_especial.
DEF BUFFER empresa FOR ems5.empresa.

/*-- Filtro Multi-idioma Aplicado --*/

def var c-versao-prg as char initial " 1.00.00.000":U no-undo.
def var c-versao-rcode as char initial "[[[1.00.00.000[[[":U no-undo. /* Controle de Versao R-CODE - Nao retirar do Fonte */

{include/i_dbinst.i}
{include/i_dbtype.i}

{include/i_fcldef.i}
{include/i_trddef.i}


/******************************* Private-Data *******************************/
assign this-procedure:private-data = "HLP=35":U.
/*************************************  *************************************/

/********************** Temporary Table Definition End **********************/

/************************** Buffer Definition Begin *************************/

&if "{&emsfin_version}" >= "5.01" &then
def buffer b_cst_tip_trans_aplic_add
    for cst_tip_trans_aplic.
&endif


/*************************** Buffer Definition End **************************/

/************************* Variable Definition Begin ************************/
def var v_log_incluir as logical no-undo init yes.

def new global shared var v_rec_tip_trans_cx
    as recid
    format ">>>>>>9":U
    initial ?
    no-undo.
def new global shared var v_rec_cta_corren
    as recid
    format ">>>>>>9":U
    initial ?
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
def var v_log_repeat
    as logical
    format "Sim/N∆o"
    initial yes
    view-as toggle-box
    no-undo.
def var v_log_save_ok
    as logical
    format "Sim/N∆o"
    initial no
    no-undo.
def var v_log_sucesso
    as logical
    format "Sim/N∆o"
    initial no
    no-undo.
def var v_nom_title_aux
    as character
    format "x(60)":U
    no-undo.
def new global shared var v_num_ped_exec_corren
    as integer
    format ">>>>9":U
    no-undo.
def new global shared var v_rec_cst_tip_trans_aplic
    as recid
    format ">>>>>>9":U
    no-undo.
def var v_rec_table
    as recid
    format ">>>>>>9":U
    initial ?
    no-undo.
def var v_rec_table_sav
    as recid
    format ">>>>>>9":U
    no-undo.
def var v_wgh_focus
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
def rectangle rt_key
    size 1 by 1
    edge-pixels 2.
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
def button bt_sav
    label "Salva"
    tooltip "Salva"
    size 1 by 1
    auto-go.

def button bt_zoo_cc
    label "Zoom"
    tooltip "Zoom"
    image-up file "image/im-zoo"
    image-insensitive file "image/ii-zoo"
    size 4 by .88.
def button bt_zoo_tip_aplic
    label "Zoom"
    tooltip "Zoom"
    image-up file "image/im-zoo"
    image-insensitive file "image/ii-zoo"
    size 4 by .88.
def button bt_zoo_tip_iof
    label "Zoom"
    tooltip "Zoom"
    image-up file "image/im-zoo"
    image-insensitive file "image/ii-zoo"
    size 4 by .88.
def button bt_zoo_tip_irrf
    label "Zoom"
    tooltip "Zoom"
    image-up file "image/im-zoo"
    image-insensitive file "image/ii-zoo"
    size 4 by .88.
def button bt_zoo_tip_rend
    label "Zoom"
    tooltip "Zoom"
    image-up file "image/im-zoo"
    image-insensitive file "image/ii-zoo"
    size 4 by .88.


/****************************** Function Button *****************************/


/*************************** Button Definition End **************************/

/************************** Frame Definition Begin **************************/

def frame f_adc_tipo
    rt_mold
         at row 03.13 col 02.00
    rt_key
         at row 01.21 col 02.00
    rt_cxcf
         at row 9.29 col 02.00 bgcolor 7 
    cst_tip_trans_aplic.cod_cta_corren
         at row 01.81 col 25.00 colon-aligned label "Conta Corrente"
         view-as fill-in
         size-chars 11.14 by .88
         fgcolor ? bgcolor 15 font 2
    bt_zoo_cc
         at row 01.81 col 38.14
    cta_corren.nom_abrev
         at row 01.81 col 42.72 no-label
         view-as fill-in
         size-chars 16.14 by .88
         fgcolor ? bgcolor 15 font 2
    cst_tip_trans_aplic.cod_tip_aplic
         at row 03.88 col 25.00 colon-aligned 
         view-as fill-in
         size-chars 14.14 by .88
         fgcolor ? bgcolor 15 font 2
    bt_zoo_tip_aplic
         at row 03.88 col 42
    cst_tip_trans_aplic.cod_tip_iof
         at row 04.88 col 25.00 colon-aligned 
         view-as fill-in
         size-chars 14.14 by .88
         fgcolor ? bgcolor 15 font 2
    bt_zoo_tip_iof
         at row 04.88 col 42
    cst_tip_trans_aplic.cod_tip_irrf
         at row 05.88 col 25.00 colon-aligned 
         view-as fill-in
         size-chars 14.14 by .88
         fgcolor ? bgcolor 15 font 2
    bt_zoo_tip_irrf
         at row 05.88 col 42
    cst_tip_trans_aplic.cod_tip_rend
         at row 06.88 col 25.00 colon-aligned 
         view-as fill-in
         size-chars 14.14 by .88
         fgcolor ? bgcolor 15 font 2
    bt_zoo_tip_rend
         at row 06.88 col 42
    bt_ok
         at row 9.50 col 03.00 font ?
         help "OK"
    bt_sav
         at row 9.50 col 14.00 font ?
         help "Salva"
    bt_can
         at row 9.50 col 25.00 font ?
         help "Cancela"
    bt_hel2
         at row 9.50 col 63.14 font ?
         help "Ajuda"
    with 1 down side-labels no-validate keep-tab-order three-d
         size-char 75.57 by 11.13 default-button bt_sav
         view-as dialog-box
         font 1 fgcolor ? bgcolor 8
         title "Tipo Transaá∆o Aplicaá∆o".
    /* adjust size of objects in this frame */
    assign bt_can:width-chars   in frame f_adc_tipo = 10.00
           bt_can:height-chars  in frame f_adc_tipo = 01.00
           bt_hel2:width-chars  in frame f_adc_tipo = 10.00
           bt_hel2:height-chars in frame f_adc_tipo = 01.00
           bt_ok:width-chars    in frame f_adc_tipo = 10.00
           bt_ok:height-chars   in frame f_adc_tipo = 01.00
           bt_sav:width-chars   in frame f_adc_tipo = 10.00
           bt_sav:height-chars  in frame f_adc_tipo = 01.00
           rt_cxcf:width-chars  in frame f_adc_tipo = 72.14
           rt_cxcf:height-chars in frame f_adc_tipo = 01.42
           rt_key:width-chars   in frame f_adc_tipo = 72.14
           rt_key:height-chars  in frame f_adc_tipo = 01.83
           rt_mold:width-chars  in frame f_adc_tipo = 72.14
           rt_mold:height-chars in frame f_adc_tipo = 05.96.
    
{include/i_fclfrm.i f_adc_tipo }
/*************************** Frame Definition End ***************************/

/*********************** User Interface Trigger Begin ***********************/

ON LEAVE OF cst_tip_trans_aplic.cod_cta_corren IN FRAME f_adc_tipo
DO:

    find first cta_corren no-lock
        where cta_corren.cod_cta_corren = input frame f_adc_tipo cst_tip_trans_aplic.cod_cta_corren no-error.
    if  avail cta_corren then do:
        display cta_corren.nom_abrev
                with frame f_adc_tipo.
    end.
    else do:
        display "" @ cta_corren.nom_abrev
                with frame f_adc_tipo.
    end.
END.


ON  CHOOSE OF bt_zoo_cc IN FRAME f_adc_tipo
OR F5 OF cst_tip_trans_aplic.cod_cta_corren IN FRAME f_adc_tipo DO:

    /* fn_generic_zoom */
    run prgint/utb/utb099ka.p /*prg_sea_cta_corren*/.
    
    if  v_rec_cta_corren <> ?
    then do:
        find cta_corren where recid(cta_corren) = v_rec_cta_corren no-lock no-error.
        assign cst_tip_trans_aplic.cod_cta_corren:screen-value in frame f_adc_tipo =
               string(cta_corren.cod_cta_corren).

        display cta_corren.nom_abrev
                with frame f_adc_tipo.

    end /* if */.
    apply "entry" to cst_tip_trans_aplic.cod_cta_corren in frame f_adc_tipo.
end. /* ON  CHOOSE OF bt_zoo_166376 IN FRAME f_tipo */

ON  CHOOSE OF bt_zoo_tip_aplic IN FRAME f_adc_tipo
OR F5 OF cst_tip_trans_aplic.cod_tip_aplic IN FRAME f_adc_tipo DO:

    assign v_rec_tip_trans_cx = ?.
    
    run prgfin/cmg/cmg003ka.p /*prg_sea_tip_trans_cx*/.
    
    if  v_rec_tip_trans_cx <> ? then do:
        find tip_trans_cx
            where recid(tip_trans_cx) = v_rec_tip_trans_cx
            no-lock no-error.
        IF AVAIL tip_trans_cx then
           disp tip_trans_cx.cod_tip_trans_cx @ cst_tip_trans_aplic.cod_tip_aplic with frame f_adc_tipo.
    end.
    apply "entry" to cst_tip_trans_aplic.cod_tip_aplic in frame f_adc_tipo.
end.

ON  CHOOSE OF bt_zoo_tip_iof IN FRAME f_adc_tipo
OR F5 OF cst_tip_trans_aplic.cod_tip_iof IN FRAME f_adc_tipo DO:

    assign v_rec_tip_trans_cx = ?.
    
    run prgfin/cmg/cmg003ka.p /*prg_sea_tip_trans_cx*/.
    
    if  v_rec_tip_trans_cx <> ? then do:
        find tip_trans_cx
            where recid(tip_trans_cx) = v_rec_tip_trans_cx
            no-lock no-error.
        IF AVAIL tip_trans_cx then
           disp tip_trans_cx.cod_tip_trans_cx @ cst_tip_trans_aplic.cod_tip_iof with frame f_adc_tipo.
    end.
    apply "entry" to cst_tip_trans_aplic.cod_tip_iof in frame f_adc_tipo.
end.

ON  CHOOSE OF bt_zoo_tip_irrf IN FRAME f_adc_tipo
OR F5 OF cst_tip_trans_aplic.cod_tip_irrf IN FRAME f_adc_tipo DO:

    assign v_rec_tip_trans_cx = ?.
    
    run prgfin/cmg/cmg003ka.p /*prg_sea_tip_trans_cx*/.
    
    if  v_rec_tip_trans_cx <> ? then do:
        find tip_trans_cx
            where recid(tip_trans_cx) = v_rec_tip_trans_cx
            no-lock no-error.
        IF AVAIL tip_trans_cx then
           disp tip_trans_cx.cod_tip_trans_cx @ cst_tip_trans_aplic.cod_tip_irrf with frame f_adc_tipo.
    end.
    apply "entry" to cst_tip_trans_aplic.cod_tip_irrf in frame f_adc_tipo.
end.

ON  CHOOSE OF bt_zoo_tip_rend IN FRAME f_adc_tipo
OR F5 OF cst_tip_trans_aplic.cod_tip_rend IN FRAME f_adc_tipo DO:

    assign v_rec_tip_trans_cx = ?.
    
    run prgfin/cmg/cmg003ka.p /*prg_sea_tip_trans_cx*/.
    
    if  v_rec_tip_trans_cx <> ? then do:
        find tip_trans_cx
            where recid(tip_trans_cx) = v_rec_tip_trans_cx
            no-lock no-error.
        IF AVAIL tip_trans_cx then
           disp tip_trans_cx.cod_tip_trans_cx @ cst_tip_trans_aplic.cod_tip_rend with frame f_adc_tipo.
    end.
    apply "entry" to cst_tip_trans_aplic.cod_tip_rend in frame f_adc_tipo.
end.

ON CHOOSE OF bt_can IN FRAME f_adc_tipo
DO:

    apply "end-error" to self.
END. /* ON CHOOSE OF bt_can IN FRAME f_adc_tipo */

ON CHOOSE OF bt_hel2 IN FRAME f_adc_tipo
DO:


    /* Begin_Include: i_context_help_frame */
    run prgtec/men/men900za.py (Input self:frame,
                                Input this-procedure:handle) /*prg_fnc_chamar_help_context*/.


    /* End_Include: i_context_help_frame */

END. /* ON CHOOSE OF bt_hel2 IN FRAME f_adc_tipo */

ON CHOOSE OF bt_ok IN FRAME f_adc_tipo
DO:

    assign v_log_repeat = no.
    

END. /* ON CHOOSE OF bt_ok IN FRAME f_adc_tipo */

ON CHOOSE OF bt_sav IN FRAME f_adc_tipo
DO:

    assign v_log_repeat = yes.
    

END. /* ON CHOOSE OF bt_sav IN FRAME f_adc_tipo */

/************************ User Interface Trigger End ************************/

/**************************** Frame Trigger Begin ***************************/

ON END-ERROR OF FRAME f_adc_tipo
DO:

    assign v_rec_cst_tip_trans_aplic = v_rec_table_sav.

END. /* ON END-ERROR OF FRAME f_adc_tipo */

ON HELP OF FRAME f_adc_tipo ANYWHERE
DO:


    /* Begin_Include: i_context_help */
    run prgtec/men/men900za.py (Input self:handle,
                                Input this-procedure:handle) /*prg_fnc_chamar_help_context*/.
    /* End_Include: i_context_help */

END. /* ON HELP OF FRAME f_adc_tipo */

ON RIGHT-MOUSE-DOWN OF FRAME f_adc_tipo ANYWHERE
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

END. /* ON RIGHT-MOUSE-DOWN OF FRAME f_adc_tipo */

ON RIGHT-MOUSE-UP OF FRAME f_adc_tipo ANYWHERE
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

END. /* ON RIGHT-MOUSE-UP OF FRAME f_adc_tipo */

ON WINDOW-CLOSE OF FRAME f_adc_tipo
DO:

    apply "end-error" to self.

END. /* ON WINDOW-CLOSE OF FRAME f_adc_tipo */


/***************************** Frame Trigger End ****************************/

/**************************** Menu Trigger Begin ****************************/


ON CHOOSE OF MENU-ITEM mi_conteudo IN MENU m_help
DO:


        apply "choose" to bt_hel2 in frame f_adc_tipo.





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


        assign v_nom_prog     = substring(frame f_adc_tipo:title, 1, max(1, length(frame f_adc_tipo:title) - 10)).
        if  v_nom_prog = ? then
            assign v_nom_prog = "".

        assign v_nom_prog     = v_nom_prog
                              + chr(10)
                              + "escmg705ca":U.




    assign v_nom_prog_ext = "esp/escmg705ca.p":U
           v_cod_release  = trim(" 1.00.00.000":U).
/*    run prgtec/btb/btb901zb.p (Input v_nom_prog,
                               Input v_nom_prog_ext,
                               Input v_cod_release) /*prg_fnc_about*/. */

{include/sobre5.i}
END. /* ON CHOOSE OF MENU-ITEM mi_sobre IN MENU m_help */


/***************************** Menu Trigger End *****************************/


/****************************** Main Code Begin *****************************/

/* Begin_Include: i_std_dialog_box */
/* tratamento do titulo e vers∆o */
assign frame f_adc_tipo:title = frame f_adc_tipo:title
                            + chr(32)
                            + chr(40)
                            + trim(" 1.00.00.000":U)
                            + chr(41).
/* menu pop-up de ajuda e sobre */
assign menu m_help:popup-only = yes
       bt_hel2:popup-menu in frame f_adc_tipo = menu m_help:handle.


/* End_Include: i_std_dialog_box */


pause 0 before-hide.
view frame f_adc_tipo.

assign v_log_repeat   = yes
       v_rec_table    = v_rec_cst_tip_trans_aplic.

if  v_rec_cst_tip_trans_aplic = ? then
    assign v_log_incluir = yes.
else do:
    assign v_log_incluir = no.
    find cst_tip_trans_aplic
        where recid(cst_tip_trans_aplic) = v_rec_cst_tip_trans_aplic
        EXCLUSIVE-LOCK no-error.
    if  not avail cst_tip_trans_aplic then
        apply "end-error" to self.
end.

main_block:
repeat while v_log_repeat:
    
    assign v_log_repeat  = no
           v_log_save_ok = no.
    
    if  v_log_incluir then
        create cst_tip_trans_aplic.

    if  not retry
    then do:
        assign v_rec_table_sav = v_rec_table.
        display cst_tip_trans_aplic.cod_cta_corren
                cst_tip_trans_aplic.cod_tip_aplic
                cst_tip_trans_aplic.cod_tip_iof  
                cst_tip_trans_aplic.cod_tip_irrf 
                cst_tip_trans_aplic.cod_tip_rend 
                with frame f_adc_tipo.
        apply "leave" to cst_tip_trans_aplic.cod_cta_corren in frame f_adc_tipo.
    end /* if */.

    if  v_log_incluir = yes then
        enable cst_tip_trans_aplic.cod_cta_corren
               bt_zoo_cc
               bt_sav
               with frame f_adc_tipo.

    enable cst_tip_trans_aplic.cod_tip_aplic
           cst_tip_trans_aplic.cod_tip_iof  
           cst_tip_trans_aplic.cod_tip_irrf 
           cst_tip_trans_aplic.cod_tip_rend
           bt_ok
           bt_can
           bt_zoo_tip_aplic
           bt_zoo_tip_iof
           bt_zoo_tip_irrf
           bt_zoo_tip_rend
           bt_hel2
           with frame f_adc_tipo.

    wait_block:
    repeat on endkey undo main_block, leave main_block while v_log_save_ok = no:
        if  valid-handle(v_wgh_focus)
        then do:
            wait-for go of frame f_adc_tipo focus v_wgh_focus.
        end.
        else do:
            wait-for go of frame f_adc_tipo.
        end.
        save_block:
        do on error undo save_block, leave save_block:

            run pi_save.

            assign v_log_save_ok = yes.
        end.
    end.
    assign v_rec_table    = recid(cst_tip_trans_aplic)
           v_rec_cst_tip_trans_aplic = recid(cst_tip_trans_aplic).
           
end /* repeat main_block */.

hide frame f_adc_tipo.

/******************************* Main Code End ******************************/

/************************* Internal Procedure Begin *************************/

/*****************************************************************************
** Procedure Interna.....: pi_save
*****************************************************************************/
PROCEDURE pi_save:

    /************************* Variable Definition Begin ************************/

    def var v_log_msg
        as logical
        format "Sim/N∆o"
        initial no
        no-undo.
    def var v_rec_table_aux
        as recid
        format ">>>>>>9":U
        no-undo.


    /************************** Variable Definition End *************************/

    assign_block:
    do on error undo assign_block, return error:
    
        if  v_log_incluir = yes then do:
            find b_cst_tip_trans_aplic_add
                 where b_cst_tip_trans_aplic_add.cod_cta_corren = input frame f_adc_tipo cst_tip_trans_aplic.cod_cta_corren
                 and   recid(b_cst_tip_trans_aplic_add) <> recid(cst_tip_trans_aplic)
                 no-lock no-error.
            if  avail b_cst_tip_trans_aplic_add
            then do:
                /* &1 j† existente ! */
                run pi_messages (input "show",
                                 input 1,
                                 input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9",
                                                    "Tipo Aplicaá∆o da Conta Corrente")) /*msg_1*/.
                assign v_wgh_focus = cst_tip_trans_aplic.cod_cta_corren:handle.
                undo assign_block, return error.
            end /* if */.
    
            find cta_corren
                where cta_corren.cod_cta_corren = input frame f_adc_tipo cst_tip_trans_aplic.cod_cta_corren
                no-lock no-error.
            if  not avail cta_corren then do:
                run pi_messages (input "show",
                                 input 524,
                                 input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9",
                                                   "Conta corrente informada n∆o existe !")).
                assign v_wgh_focus = cst_tip_trans_aplic.cod_tip_aplic:handle.
                undo assign_block, return error.        
            end.
        end.
        
        find tip_trans_cx
            where tip_trans_cx.cod_tip_trans_cx = input frame f_adc_tipo cst_tip_trans_aplic.cod_tip_aplic
            no-lock no-error.
        if  not avail tip_trans_cx then do:
            run pi_messages (input "show",
                             input 524,
                             input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9",
                                               "Tipo Transaá∆o Caixa informado para Aplicaá∆o n∆o existe!")).
            assign v_wgh_focus = cst_tip_trans_aplic.cod_tip_aplic:handle.
            undo assign_block, return error.
        end.
        find tip_trans_cx
            where tip_trans_cx.cod_tip_trans_cx = input frame f_adc_tipo cst_tip_trans_aplic.cod_tip_iof
            no-lock no-error.
        if  not avail tip_trans_cx then do:
            run pi_messages (input "show",
                             input 524,
                             input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9",
                                               "Tipo Transaá∆o Caixa informado para IOF n∆o existe!")).
            assign v_wgh_focus = cst_tip_trans_aplic.cod_tip_iof:handle.
            undo assign_block, return error.
        end.
        find tip_trans_cx
            where tip_trans_cx.cod_tip_trans_cx = input frame f_adc_tipo cst_tip_trans_aplic.cod_tip_irrf
            no-lock no-error.
        if  not avail tip_trans_cx then do:
            run pi_messages (input "show",
                             input 524,
                             input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9",
                                               "Tipo Transaá∆o Caixa informado para IRRF n∆o existe!")).
            assign v_wgh_focus = cst_tip_trans_aplic.cod_tip_irrf:handle.
            undo assign_block, return error.
        end.
        find tip_trans_cx
            where tip_trans_cx.cod_tip_trans_cx = input frame f_adc_tipo cst_tip_trans_aplic.cod_tip_rend
            no-lock no-error.
        if  not avail tip_trans_cx then do:
            run pi_messages (input "show",
                             input 524,
                             input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9",
                                               "Tipo Transaá∆o Caixa informado para Rendimentos n∆o existe!")).
            assign v_wgh_focus = cst_tip_trans_aplic.cod_tip_rend:handle.
            undo assign_block, return error.
        end.

        assign input frame f_adc_tipo cst_tip_trans_aplic.cod_cta_corren
               input frame f_adc_tipo cst_tip_trans_aplic.cod_tip_aplic
               input frame f_adc_tipo cst_tip_trans_aplic.cod_tip_iof  
               input frame f_adc_tipo cst_tip_trans_aplic.cod_tip_irrf 
               input frame f_adc_tipo cst_tip_trans_aplic.cod_tip_rend.

        assign v_wgh_focus = ?
               v_rec_cst_tip_trans_aplic = recid(cst_tip_trans_aplic).
                
    end /* do assign_block */.

END PROCEDURE. /* pi_save_key */
/************************** Internal Procedure End **************************/


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
        message getStrTrans("Mensagem nr. ", "CMG") i_msg "!!!":U skip
                getStrTrans("Programa Mensagem", "CMG") c_prg_msg getStrTrans("n∆o encontrado.", "CMG")
                view-as alert-box error.
        return error.
    end.

    run value(c_prg_msg + ".p":U) (input c_action, input c_param).
    return return-value.
END PROCEDURE.  /* pi_messages */

