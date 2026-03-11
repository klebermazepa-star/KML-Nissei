/*****************************************************************************
** KML SISTEMAS
**
** Cliente...............: NISSEI
** Programa..............: escmg705ka
** Descricao.............: Zoom Tipos de Transaá∆o Caixa para Aplicaá‰es e Resgates
** Versao................:  1.00.00.000
** Procedimento..........: tar_import_movto_cmg
** Nome Externo..........: esp/escmg705ka
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
def var v_cod_cta_corren_fim
    as character
    format "x(10)":U
    initial "ZZZZZZZZZZ"
    label "atÇ"
    column-label "atÇ"
    no-undo.
def var v_cod_cta_corren_inic
    as character
    format "x(10)":U
    label "Conta Corrente"
    column-label "Conta Corrente"
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
def new global shared var v_cod_unid_fechto_cx
    as character
    format "x(8)":U
    label "Unidade Fechto Caixa"
    column-label "Unid Fechto Caixa"
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
def var v_nom_title_aux
    as character
    format "x(60)":U
    no-undo.
def new global shared var v_rec_cst_tip_trans_aplic
    as recid
    format ">>>>>>9":U
    initial ?
    no-undo.
def var v_rec_table
    as recid
    format ">>>>>>9":U
    initial ?
    no-undo.

/************************** Variable Definition End *************************/

/*************************** Menu Definition Begin **************************/

.

def menu      m_help                menubar
    menu-item mi_conteudo           label "&Conte£do"
    menu-item mi_sobre              label "&Sobre".



/**************************** Menu Definition End ***************************/

/************************** Query Definition Begin **************************/

def query qr_sea_cst_tip_trans_aplic
    for cst_tip_trans_aplic
    scrolling.


/*************************** Query Definition End ***************************/

/************************** Browse Definition Begin *************************/

def browse br_sea_cst_tip_trans_aplic query qr_sea_cst_tip_trans_aplic display 
    cst_tip_trans_aplic.cod_cta_corren
    width-chars 10.00
        column-label "Cta Corren"
    cst_tip_trans_aplic.cod_tip_aplic
    width-chars 09.00
        column-label "Tp Aplic"
    cst_tip_trans_aplic.cod_tip_iof
    width-chars 09.00
        column-label "Tp IOF"
    cst_tip_trans_aplic.cod_tip_irrf
    width-chars 09.00
        column-label "Tp IRRF"
    cst_tip_trans_aplic.cod_tip_rend
    width-chars 09.00
        column-label "Tp Rendimento"
    with no-box separators single 
         size 82.00 by 08.30
         font 1
         bgcolor 15.


/*************************** Browse Definition End **************************/

/************************ Rectangle Definition Begin ************************/

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
/****************************** Function Button *****************************/


/*************************** Button Definition End **************************/

/************************ Radio-Set Definition Begin ************************/

def var rs_sea_cst_tip_trans_aplic
    as character
    initial "Por Conta Corrente"
    view-as radio-set Horizontal
    radio-buttons "Por Conta Corrente", "Por Conta Corrente"
    bgcolor 15 
    no-undo.


/************************* Radio-Set Definition End *************************/

/************************** Frame Definition Begin **************************/
def frame f_sea_tipo
    rt_cxcf
         at row 11.25 col 02.00 bgcolor 7 
    rt_cxcl
         at row 01.00 col 01.00 bgcolor 15 
    rs_sea_cst_tip_trans_aplic
         at row 01.21 col 03.00
         help "" no-label
    br_sea_cst_tip_trans_aplic
         at row 02.25 col 02.00
    bt_ok
         at row 11.46 col 03.00 font ?
         help "OK"
    bt_can
         at row 11.46 col 14.00 font ?
         help "Cancela"
    bt_hel2
         at row 11.46 col 72.14 font ?
         help "Ajuda"
    with 1 down side-labels no-validate keep-tab-order three-d
         size-char 84.57 by 13.08 default-button bt_ok
         view-as dialog-box
         font 1 fgcolor ? bgcolor 8
         title "Pesquisa Tipo Trans Aplicaá∆o".
    /* adjust size of objects in this frame */
    assign bt_can:width-chars                    in frame f_sea_tipo = 10.00
           bt_can:height-chars                   in frame f_sea_tipo = 01.00
           bt_hel2:width-chars                   in frame f_sea_tipo = 10.00
           bt_hel2:height-chars                  in frame f_sea_tipo = 01.00
           bt_ok:width-chars                     in frame f_sea_tipo = 10.00
           bt_ok:height-chars                    in frame f_sea_tipo = 01.00
           rt_cxcf:width-chars                   in frame f_sea_tipo = 81.14
           rt_cxcf:height-chars                  in frame f_sea_tipo = 01.42
           rt_cxcl:width-chars                   in frame f_sea_tipo = 83.00
           rt_cxcl:height-chars                  in frame f_sea_tipo = 01.25.

{include/i_fclfrm.i f_sea_tipo }
/*************************** Frame Definition End ***************************/

/*********************** User Interface Trigger Begin ***********************/

ON CHOOSE OF bt_can IN FRAME f_sea_tipo
DO:

    apply "end-error" to self.
END. /* ON CHOOSE OF bt_can IN FRAME f_sea_tipo */

ON CHOOSE OF bt_hel2 IN FRAME f_sea_tipo
DO:


    /* Begin_Include: i_context_help_frame */
    run prgtec/men/men900za.py (Input self:frame,
                                Input this-procedure:handle) /*prg_fnc_chamar_help_context*/.


    /* End_Include: i_context_help_frame */

END. /* ON CHOOSE OF bt_hel2 IN FRAME f_sea_tipo */

ON CHOOSE OF bt_ok IN FRAME f_sea_tipo
DO:

    if  avail cst_tip_trans_aplic
    then do:
        assign v_rec_cst_tip_trans_aplic = recid(cst_tip_trans_aplic).
    end /* if */.
END. /* ON CHOOSE OF bt_ok IN FRAME f_sea_tipo */

/************************ User Interface Trigger End ************************/

/**************************** Frame Trigger Begin ***************************/

ON END-ERROR OF FRAME f_sea_tipo
DO:

    assign v_rec_cst_tip_trans_aplic = ?.
END. /* ON END-ERROR OF FRAME f_sea_tipo */

ON ENTRY OF FRAME f_sea_tipo
DO:

    run pi_open_sea_cst_tip_trans_aplic.
 
END. /* ON ENTRY OF FRAME f_sea_tipo */

ON HELP OF FRAME f_sea_tipo ANYWHERE
DO:


    /* Begin_Include: i_context_help */
    run prgtec/men/men900za.py (Input self:handle,
                                Input this-procedure:handle) /*prg_fnc_chamar_help_context*/.
    /* End_Include: i_context_help */

END. /* ON HELP OF FRAME f_sea_tipo */

ON RIGHT-MOUSE-DOWN OF FRAME f_sea_tipo ANYWHERE
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

END. /* ON RIGHT-MOUSE-DOWN OF FRAME f_sea_tipo */

ON RIGHT-MOUSE-UP OF FRAME f_sea_tipo ANYWHERE
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

END. /* ON RIGHT-MOUSE-UP OF FRAME f_sea_tipo */

ON WINDOW-CLOSE OF FRAME f_sea_tipo
DO:

    apply "end-error" to self.
END. /* ON WINDOW-CLOSE OF FRAME f_sea_tipo */


/***************************** Frame Trigger End ****************************/

/**************************** Menu Trigger Begin ****************************/


ON CHOOSE OF MENU-ITEM mi_conteudo IN MENU m_help
DO:


        apply "choose" to bt_hel2 in frame f_sea_tipo.





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


        assign v_nom_prog     = substring(frame f_sea_tipo:title, 1, max(1, length(frame f_sea_tipo:title) - 10)).
        if  v_nom_prog = ? then
            assign v_nom_prog = "".

        assign v_nom_prog     = v_nom_prog
                              + chr(10)
                              + "sea_cst_tip_trans_aplic":U.




    assign v_nom_prog_ext = "prgfin/cmg/cmg705ka.p":U
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
assign frame f_sea_tipo:title = frame f_sea_tipo:title
                            + chr(32)
                            + chr(40)
                            + trim(" 1.00.00.000":U)
                            + chr(41).
/* menu pop-up de ajuda e sobre */
assign menu m_help:popup-only = yes
       bt_hel2:popup-menu in frame f_sea_tipo = menu m_help:handle.


/* End_Include: i_std_dialog_box */

{include/title5.i f_sea_tipo FRAME}


assign br_sea_cst_tip_trans_aplic:num-locked-columns in frame f_sea_tipo = 0.

pause 0 before-hide.
view frame f_sea_tipo.

assign v_rec_table    = v_rec_cst_tip_trans_aplic.

main_block:
do on endkey undo main_block, leave main_block on error undo main_block, leave main_block.

    enable rs_sea_cst_tip_trans_aplic
           br_sea_cst_tip_trans_aplic
           bt_ok
           bt_can
           bt_hel2
           with frame f_sea_tipo.

    wait-for go of frame f_sea_tipo
          or default-action of br_sea_cst_tip_trans_aplic
          or mouse-select-dblclick of br_sea_cst_tip_trans_aplic focus browse br_sea_cst_tip_trans_aplic.
    if  avail cst_tip_trans_aplic
    then do:
        assign v_rec_cst_tip_trans_aplic = recid(cst_tip_trans_aplic).

    end .
    else do:
        assign v_rec_cst_tip_trans_aplic = ?.
        
    end .
end /* do main_block */.

hide frame f_sea_tipo.



/******************************* Main Code End ******************************/

/************************* Internal Procedure Begin *************************/

/*****************************************************************************
** Procedure Interna.....: pi_open_sea_cst_tip_trans_aplic
*****************************************************************************/
PROCEDURE pi_open_sea_cst_tip_trans_aplic:

    open query qr_sea_cst_tip_trans_aplic for each cst_tip_trans_aplic no-lock
         by cst_tip_trans_aplic.cod_cta_corren.

END PROCEDURE. /* pi_open_sea_cst_tip_trans_aplic */

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
/***********************  End of sea_cst_tip_trans_aplic **********************/
