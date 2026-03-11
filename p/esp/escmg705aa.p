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

/************************** Window Definition Begin *************************/

def var wh_w_program
    as widget-handle
    no-undo.

IF session:window-system <> "TTY" THEN
DO:
create window wh_w_program
    assign row                  = 01.00
         col                  = 01.00
         height-chars         = 01.00
         width-chars          = 01.00
         min-width-chars      = 01.00
         min-height-chars     = 01.00
         max-width-chars      = 01.00
         max-height-chars     = 01.00
         virtual-width-chars  = 300.00
         virtual-height-chars = 200.00
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

/************************** Buffer Definition Begin *************************/

&if "{&emsfin_version}" >= "5.01" &then
def buffer b_cst_tip_trans_aplic_enter
    for cst_tip_trans_aplic.
&endif


/*************************** Buffer Definition End **************************/

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
def new global shared var v_cod_cenar_ctbl_aux
    as character
    format "x(8)":U
    label "Cen†rio Cont†bil"
    column-label "Cen†rio Cont†bil"
    no-undo.
def new global shared var v_cod_cta_corren_ini
    as character
    format "x(10)":U
    label "Cta Corrente"
    column-label "Cta Corrente"
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
def var v_cod_return
    as character
    format "x(40)":U
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
def var v_img_image_file
    as Character
    format "x(40)":U
    no-undo.
def var v_nom_attrib
    as character
    format "x(30)":U
    no-undo.
def var v_nom_title_aux
    as character
    format "x(60)":U
    no-undo.
def new global shared var v_rec_cta_corren
    as recid
    format ">>>>>>9":U
    initial ?
    no-undo.
def new global shared var v_rec_cst_tip_trans_aplic
    as recid
    format ">>>>>>9":U
    initial ?
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

/************************** Variable Definition End *************************/

/*************************** Menu Definition Begin **************************/


def sub-menu  mi_table
    menu-item mi_fir               label "Primeiro"        accelerator "ALT-HOME"
    menu-item mi_pre               label "Anterior"        accelerator "ALT-CURSOR-LEFT"
    menu-item mi_nex               label "Pr¢ximo"         accelerator "ALT-CURSOR-RIGHT"
    menu-item mi_las               label "Èltimo"          accelerator "ALT-END"
    RULE
    menu-item mi_add               label "Inclui"          accelerator "ALT-INS"
    menu-item mi_mod               label "Modifica"        accelerator "ALT-ENTER"
    menu-item mi_era               label "Elimina"         accelerator "ALT-DEL"
    RULE
    menu-item mi_sea               label "Pesquisa"        accelerator "ALT-Z"
    RULE
    menu-item mi_exi               label "Sa°da".

def sub-menu  mi_hel
    menu-item mi_contents          label "Conte£do"
    RULE
    menu-item mi_about             label "Sobre".

def menu      m_03                  menubar
    sub-menu  mi_table              label "Tabela"
    sub-menu  mi_hel                label "Ajuda".



/**************************** Menu Definition End ***************************/

/************************** Query Definition Begin **************************/

/*************************** Query Definition End ***************************/

/************************** Browse Definition Begin *************************/



/*************************** Browse Definition End **************************/

/************************ Rectangle Definition Begin ************************/

def rectangle rt_key
    size 1 by 1
    edge-pixels 2.
def rectangle rt_mold
    size 1 by 1
    edge-pixels 2.
def rectangle rt_rgf
    size 1 by 1
    edge-pixels 2.


/************************* Rectangle Definition End *************************/

/************************** Image Definition Begin **************************/


/*************************** Image Definition End ***************************/

/************************** Button Definition Begin *************************/

def button bt_add1
    label "Inc"
    tooltip "Inclui"
&if "{&window-system}" <> "TTY" &then
    image-up file "image/im-add"
    image-insensitive file "image/ii-add"
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
def button bt_era1
    label "Eli"
    tooltip "Elimina"
&if "{&window-system}" <> "TTY" &then
    image-up file "image/im-era1"
    image-insensitive file "image/ii-era1"
&endif
    size 1 by 1.
def button bt_exi
    label "Sa°da"
    tooltip "Sa°da"
&if "{&window-system}" <> "TTY" &then
    image-up file "image/im-exi"
    image-insensitive file "image/ii-exi"
&endif
    size 1 by 1.
def button bt_fir
    label "<<"
    tooltip "Primeira Ocorrància da Tabela"
&if "{&window-system}" <> "TTY" &then
    image-up file "image/im-fir"
    image-insensitive file "image/ii-fir"
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
def button bt_las
    label ">>"
    tooltip "Èltima Ocorrància da Tabela"
&if "{&window-system}" <> "TTY" &then
    image-up file "image/im-las"
    image-insensitive file "image/ii-las"
&endif
    size 1 by 1.
def button bt_mod1
    label "Mod"
    tooltip "Modifica"
&if "{&window-system}" <> "TTY" &then
    image-up file "image/im-mod"
    image-insensitive file "image/ii-mod"
&endif
    size 1 by 1.
def button bt_nex1
    label ">"
    tooltip "Pr¢xima Ocorrància da Tabela"
&if "{&window-system}" <> "TTY" &then
    image-up file "image/im-nex1"
    image-insensitive file "image/ii-nex1"
&endif
    size 1 by 1.
def button bt_pre1
    label "<"
    tooltip "Ocorrància Anterior da Tabela"
&if "{&window-system}" <> "TTY" &then
    image-up file "image/im-pre1"
    image-insensitive file "image/ii-pre1"
&endif
    size 1 by 1.
def button bt_sea1
    label "Psq"
    tooltip "Pesquisa"
&if "{&window-system}" <> "TTY" &then
    image-up file "image/im-sea1"
    image-insensitive file "image/ii-sea1"
&endif
    size 1 by 1.
/****************************** Function Button *****************************/
def button bt_zoo_166376
    label "Zoom"
    tooltip "Zoom"
&if "{&window-system}" <> "TTY" &then
    image-up file "image/im-zoo"
    image-insensitive file "image/ii-zoo"
&endif
    size 4 by .88.


/*************************** Button Definition End **************************/

/************************** Frame Definition Begin **************************/

def frame f_tipo
    rt_mold
         at row 04.12 col 02.00
    rt_key
         at row 02.50 col 02.00
    rt_rgf
         at row 01.00 col 01.00 bgcolor 7 
    bt_fir
         at row 01.08 col 01.14 font ?
         help "Primeira Ocorrància da Tabela"
    bt_pre1
         at row 01.08 col 05.14 font ?
         help "Ocorrància Anterior da Tabela"
    bt_nex1
         at row 01.08 col 09.14 font ?
         help "Pr¢xima Ocorrància da Tabela"
    bt_las
         at row 01.08 col 13.14 font ?
         help "Èltima Ocorrància da Tabela"
    bt_add1
         at row 01.08 col 18.14 font ?
         help "Inclui"
    bt_mod1
         at row 01.08 col 22.14 font ?
         help "Modifica"
    bt_era1
         at row 01.08 col 26.14 font ?
         help "Elimina"
    bt_sea1
         at row 01.08 col 40.14 font ?
         help "Pesquisa"
    bt_exi
         at row 01.08 col 82.57 font ?
         help "Sa°da"
    bt_hel1
         at row 01.08 col 86.57 font ?
         help "Ajuda"
    cst_tip_trans_aplic.cod_cta_corren
         at row 02.81 col 25.00 colon-aligned label "Conta Corrente"
         view-as fill-in
         size-chars 11.14 by .88
         fgcolor ? bgcolor 15 font 2
    bt_zoo_166376
         at row 02.81 col 38.14
    bt_enter
         at row 02.81 col 42 font ?
         help "Entra"
    cta_corren.nom_abrev
         at row 02.81 col 46.72 no-label
         view-as fill-in
         size-chars 16.14 by .88
         fgcolor ? bgcolor 15 font 2
    cst_tip_trans_aplic.cod_tip_aplic
         at row 04.88 col 25.00 colon-aligned 
         view-as fill-in
         size-chars 14.14 by .88
         fgcolor ? bgcolor 15 font 2
    cst_tip_trans_aplic.cod_tip_iof
         at row 05.88 col 25.00 colon-aligned 
         view-as fill-in
         size-chars 14.14 by .88
         fgcolor ? bgcolor 15 font 2
    cst_tip_trans_aplic.cod_tip_irrf
         at row 06.88 col 25.00 colon-aligned 
         view-as fill-in
         size-chars 14.14 by .88
         fgcolor ? bgcolor 15 font 2
    cst_tip_trans_aplic.cod_tip_rend
         at row 07.88 col 25.00 colon-aligned 
         view-as fill-in
         size-chars 14.14 by .88
         fgcolor ? bgcolor 15 font 2
    with 1 down side-labels no-validate keep-tab-order three-d
         size-char 90.00 by 9.46
         at row 01.33 col 01.00
         font 1 fgcolor ? bgcolor 8
         title "Manutená∆o Tipo Transaá∆o Aplicaá∆o".
    /* adjust size of objects in this frame */
    assign bt_add1:width-chars        in frame f_tipo = 04.00
           bt_add1:height-chars       in frame f_tipo = 01.13
           bt_enter:width-chars       in frame f_tipo = 04.00
           bt_enter:height-chars      in frame f_tipo = 00.88
           bt_era1:width-chars        in frame f_tipo = 04.00
           bt_era1:height-chars       in frame f_tipo = 01.13
           bt_exi:width-chars         in frame f_tipo = 04.00
           bt_exi:height-chars        in frame f_tipo = 01.13
           bt_fir:width-chars         in frame f_tipo = 04.00
           bt_fir:height-chars        in frame f_tipo = 01.13
           bt_hel1:width-chars        in frame f_tipo = 04.00
           bt_hel1:height-chars       in frame f_tipo = 01.13
           bt_las:width-chars         in frame f_tipo = 04.00
           bt_las:height-chars        in frame f_tipo = 01.13
           bt_mod1:width-chars        in frame f_tipo = 04.00
           bt_mod1:height-chars       in frame f_tipo = 01.13
           bt_nex1:width-chars        in frame f_tipo = 04.00
           bt_nex1:height-chars       in frame f_tipo = 01.13
           bt_pre1:width-chars        in frame f_tipo = 04.00
           bt_pre1:height-chars       in frame f_tipo = 01.13
           bt_sea1:width-chars        in frame f_tipo = 04.00
           bt_sea1:height-chars       in frame f_tipo = 01.13
           rt_key:width-chars         in frame f_tipo = 87.72
           rt_key:height-chars        in frame f_tipo = 01.49
           rt_mold:width-chars        in frame f_tipo = 87.72
           rt_mold:height-chars       in frame f_tipo = 05.29
           rt_rgf:width-chars         in frame f_tipo = 89.72
           rt_rgf:height-chars        in frame f_tipo = 01.29.

    /* enable function buttons */
    assign bt_zoo_166376:sensitive in frame f_tipo = yes.
    /* move buttons to top */
    bt_zoo_166376:move-to-top().



{include/i_fclfrm.i f_tipo }
/*************************** Frame Definition End ***************************/

/*********************** User Interface Trigger Begin ***********************/

ON CHOOSE OF bt_mod1 IN FRAME f_tipo
DO:

    if  not avail cst_tip_trans_aplic then
        return no-apply.
        
    assign v_rec_cst_tip_trans_aplic = v_rec_table.
    
    run esp/escmg705ca.p.

    if  v_rec_cst_tip_trans_aplic <> ?
    then do:
        assign v_rec_table = v_rec_cst_tip_trans_aplic.
        run pi_disp_fields /*pi_disp_fields*/.
    end /* if */.
    else do:
        assign v_rec_cst_tip_trans_aplic = v_rec_table.
    end /* else */.

END.


ON CHOOSE OF bt_add1 IN FRAME f_tipo
DO:

    assign v_rec_cst_tip_trans_aplic = ? // faz com que o escmg705ca funcione no modo Incluir.
           v_rec_cta_corren = recid(cta_corren).
    run esp/escmg705ca.p.

    if  v_rec_cst_tip_trans_aplic <> ?
    then do:
        assign v_rec_table = v_rec_cst_tip_trans_aplic.
        run pi_disp_fields /*pi_disp_fields*/.
    end /* if */.
    else do:
        assign v_rec_cst_tip_trans_aplic = v_rec_table.
    end /* else */.

END. /* ON CHOOSE OF bt_add1 IN FRAME f_tipo */

ON CHOOSE OF bt_enter IN FRAME f_tipo
DO:

    find b_cst_tip_trans_aplic_enter no-lock
        where b_cst_tip_trans_aplic_enter.cod_cta_corren = input frame f_tipo cst_tip_trans_aplic.cod_cta_corren
       no-error.
    if  avail b_cst_tip_trans_aplic_enter then do:
        assign v_rec_table = recid(b_cst_tip_trans_aplic_enter).
        run pi_disp_fields.
    end.
    else do:
        message "Tipo Transaá∆o Aplicaá∆o Inexistente para esta Conta."
               view-as alert-box warning buttons ok.
        find cst_tip_trans_aplic where recid(cst_tip_trans_aplic) = v_rec_table no-lock no-error.
    end.

END. /* ON CHOOSE OF bt_enter IN FRAME f_tipo */

ON CHOOSE OF bt_era1 IN FRAME f_tipo
DO:
    def var v_log_answer as log.

    assign v_rec_cst_tip_trans_aplic = v_rec_table.
    if  avail cst_tip_trans_aplic
    then do:

        assign v_log_answer   = no.
        
        message "Confirme eliminaá∆o de Tipo Transaá∆o Aplicaá∆o da Conta?"
               view-as alert-box question buttons yes-no-cancel title "Confirma?" update v_log_answer.
        
        if  v_log_answer = yes
        then do:
            find current cst_tip_trans_aplic EXCLUSIVE-LOCK.
    
            delete cst_tip_trans_aplic.
    
            assign v_rec_cst_tip_trans_aplic = ?
                   v_rec_table               = ?.
        end.
    end.

    if  v_rec_table <> ?
    then do:
        run pi_disp_fields /*pi_disp_fields*/.
    end /* if */.
    else do:
        apply "choose" to  bt_nex1 in frame  f_tipo.
    end /* else */.
END. /* ON CHOOSE OF bt_era1 IN FRAME f_tipo */

ON CHOOSE OF bt_exi IN FRAME f_tipo
DO:

    run pi_close_program /*pi_close_program*/.

END. /* ON CHOOSE OF bt_exi IN FRAME f_tipo */

ON CHOOSE OF bt_fir IN FRAME f_tipo
DO:

    find FIRST cst_tip_trans_aplic no-lock no-error.
    if  avail cst_tip_trans_aplic then do:
        assign v_rec_table = recid(cst_tip_trans_aplic).
        run pi_disp_fields.
    end.
    else do:
        message "N∆o existem ocorràncias na tabela."
               view-as alert-box warning buttons ok.
    end.

END. /* ON CHOOSE OF bt_fir IN FRAME f_tipo */

ON CHOOSE OF bt_hel1 IN FRAME f_tipo
DO:

    /* Begin_Include: i_context_help_frame */
    run prgtec/men/men900za.py (Input self:frame,
                                Input this-procedure:handle) /*prg_fnc_chamar_help_context*/.
    /* End_Include: i_context_help_frame */

END. /* ON CHOOSE OF bt_hel1 IN FRAME f_tipo */

ON CHOOSE OF bt_las IN FRAME f_tipo
DO:
    find LAST cst_tip_trans_aplic no-lock no-error.
    if  avail cst_tip_trans_aplic then do:
        assign v_rec_table = recid(cst_tip_trans_aplic).
        run pi_disp_fields.
    end.
    else do:
        message "N∆o existem ocorràncias na tabela."
               view-as alert-box warning buttons ok.
    end.
END. /* ON CHOOSE OF bt_las IN FRAME f_tipo */

ON CHOOSE OF bt_nex1 IN FRAME f_tipo
DO:

    find NEXT cst_tip_trans_aplic no-lock no-error.
    if  avail cst_tip_trans_aplic then do:
        assign v_rec_table = recid(cst_tip_trans_aplic).
        run pi_disp_fields.
    end.
    else do:
        message "Èltima ocorrància da tabela."
               view-as alert-box warning buttons ok.
        run pi_disp_fields.
    end.

END. /* ON CHOOSE OF bt_nex1 IN FRAME f_tipo */

ON CHOOSE OF bt_pre1 IN FRAME f_tipo
DO:
    find PREV cst_tip_trans_aplic no-lock no-error.
    if  avail cst_tip_trans_aplic then do:
        assign v_rec_table = recid(cst_tip_trans_aplic).
        run pi_disp_fields.
    end.
    else do:
        message "Primeira ocorrància da tabela."
               view-as alert-box warning buttons ok.
    end.
END. /* ON CHOOSE OF bt_pre1 IN FRAME f_tipo */

ON CHOOSE OF bt_sea1 IN FRAME f_tipo
DO:

    assign v_rec_cst_tip_trans_aplic = v_rec_table.

    run esp/escmg705ka.p /*prg_sea_cst_tip_trans_aplic*/.
    if  v_rec_cst_tip_trans_aplic <> ?
    then do:
        assign v_rec_table = v_rec_cst_tip_trans_aplic.
        run pi_disp_fields /*pi_disp_fields*/.
    end /* if */.
    else do:
        assign v_rec_cst_tip_trans_aplic = v_rec_table.
    end /* else */.

END. /* ON CHOOSE OF bt_sea1 IN FRAME f_tipo */

ON LEAVE OF cst_tip_trans_aplic.cod_cta_corren IN FRAME f_tipo
DO:

    find first cta_corren no-lock
        where cta_corren.cod_cta_corren = input frame f_tipo cst_tip_trans_aplic.cod_cta_corren no-error.
    display cta_corren.nom_abrev when avail cta_corren
            "" when not avail cta_corren @ cta_corren.nom_abrev
            with frame f_tipo.
END. /* ON LEAVE OF cst_tip_trans_aplic.cod_cta_corren IN FRAME f_tipo */


/************************ User Interface Trigger End ************************/

/************************** Function Trigger Begin **************************/


ON  CHOOSE OF bt_zoo_166376 IN FRAME f_tipo
OR F5 OF cst_tip_trans_aplic.cod_cta_corren IN FRAME f_tipo DO:

    /* fn_generic_zoom */
    run prgint/utb/utb099ka.p /*prg_sea_cta_corren*/.
    
    if  v_rec_cta_corren <> ?
    then do:
        find cta_corren where recid(cta_corren) = v_rec_cta_corren no-lock no-error.
        assign cst_tip_trans_aplic.cod_cta_corren:screen-value in frame f_tipo =
               string(cta_corren.cod_cta_corren).

        display cta_corren.nom_abrev
                with frame f_tipo.

    end /* if */.
    apply "entry" to cst_tip_trans_aplic.cod_cta_corren in frame f_tipo.
end. /* ON  CHOOSE OF bt_zoo_166376 IN FRAME f_tipo */


/*************************** Function Trigger End ***************************/

/**************************** Frame Trigger Begin ***************************/


ON END-ERROR OF FRAME f_tipo
DO:

    run pi_close_program /*pi_close_program*/.
END. /* ON END-ERROR OF FRAME f_tipo */

ON HELP OF FRAME f_tipo ANYWHERE
DO:


    /* Begin_Include: i_context_help */
    run prgtec/men/men900za.py (Input self:handle,
                                Input this-procedure:handle) /*prg_fnc_chamar_help_context*/.
    /* End_Include: i_context_help */

END. /* ON HELP OF FRAME f_tipo */

ON RIGHT-MOUSE-DOWN OF FRAME f_tipo ANYWHERE
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

END. /* ON RIGHT-MOUSE-DOWN OF FRAME f_tipo */

ON RIGHT-MOUSE-UP OF FRAME f_tipo ANYWHERE
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

END. /* ON RIGHT-MOUSE-UP OF FRAME f_tipo */


/***************************** Frame Trigger End ****************************/

/*************************** Window Trigger Begin ***************************/

IF session:window-system <> "TTY" THEN
DO:

ON ENTRY OF wh_w_program
DO:
    if  valid-handle (wh_w_program)
    then do:
        assign current-window = wh_w_program:handle.
    end /* if */.
END. /* ON ENTRY OF wh_w_program */

ON WINDOW-CLOSE OF wh_w_program
DO:

    apply "choose" to bt_exi in frame f_tipo.

END. /* ON WINDOW-CLOSE OF wh_w_program */

END.

/**************************** Window Trigger End ****************************/

/**************************** Menu Trigger Begin ****************************/


ON CHOOSE OF MENU-ITEM mi_fir IN MENU m_03
DO:

    apply "choose" to bt_fir in frame f_tipo.

END. /* ON CHOOSE OF MENU-ITEM mi_fir IN MENU m_03 */

ON CHOOSE OF MENU-ITEM mi_pre IN MENU m_03
DO:

    apply "choose" to bt_pre1 in frame f_tipo.

END. /* ON CHOOSE OF MENU-ITEM mi_pre IN MENU m_03 */

ON CHOOSE OF MENU-ITEM mi_nex IN MENU m_03
DO:

    apply "choose" to bt_nex1 in frame f_tipo.

END. /* ON CHOOSE OF MENU-ITEM mi_nex IN MENU m_03 */

ON CHOOSE OF MENU-ITEM mi_las IN MENU m_03
DO:

    apply "choose" to bt_las in frame f_tipo.

END. /* ON CHOOSE OF MENU-ITEM mi_las IN MENU m_03 */

ON CHOOSE OF MENU-ITEM mi_add IN MENU m_03
DO:

    apply "choose" to bt_add1 in frame f_tipo.

END. /* ON CHOOSE OF MENU-ITEM mi_add IN MENU m_03 */

ON CHOOSE OF MENU-ITEM mi_mod IN MENU m_03
DO:

    apply "choose" to bt_mod1 in frame f_tipo.

END. /* ON CHOOSE OF MENU-ITEM mi_mod IN MENU m_03 */

ON CHOOSE OF MENU-ITEM mi_era IN MENU m_03
DO:

    apply "choose" to bt_era1 in frame f_tipo.

END. /* ON CHOOSE OF MENU-ITEM mi_era IN MENU m_03 */

ON CHOOSE OF MENU-ITEM mi_sea IN MENU m_03
DO:

    apply "choose" to bt_sea1 in frame f_tipo.

END. /* ON CHOOSE OF MENU-ITEM mi_sea IN MENU m_03 */

ON CHOOSE OF MENU-ITEM mi_exi IN MENU m_03
DO:

    apply "choose" to bt_exi in frame f_tipo.

END. /* ON CHOOSE OF MENU-ITEM mi_exi IN MENU m_03 */

ON CHOOSE OF MENU-ITEM mi_contents IN MENU m_03
DO:

    apply "choose" to bt_hel1 in frame f_tipo.

END. /* ON CHOOSE OF MENU-ITEM mi_contents IN MENU m_03 */

ON CHOOSE OF MENU-ITEM mi_about IN MENU m_03
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
                          + "escmg705aa":U
           v_nom_prog_ext = "esp/escmg705aa.p":U
           v_cod_release  = trim(" 1.00.00.000":U).
/*    run prgtec/btb/btb901zb.p (Input v_nom_prog,
                               Input v_nom_prog_ext,
                               Input v_cod_release) /*prg_fnc_about*/. */
{include/sobre5.i}
    /* End_Include: i_about_call */


END. /* ON CHOOSE OF MENU-ITEM mi_about IN MENU m_03 */


/***************************** Menu Trigger End *****************************/


/****************************** Main Code Begin *****************************/


if  search("prgtec/btb/btb906za.r") = ? and search("prgtec/btb/btb906za.py") = ? then do:
    if  v_cod_dwb_user begins 'es_' then
        return "Programa execut†vel n∆o foi encontrado:" /*l_programa_nao_encontrado*/  + "prgtec/btb/btb906za.py".
    else do:
        message getStrTrans("Programa execut†vel n∆o foi encontrado:", "CMG") /*l_programa_nao_encontrado*/  "prgtec/btb/btb906za.py"
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
        message getStrTrans("Programa execut†vel n∆o foi encontrado:", "CMG") /*l_programa_nao_encontrado*/  "prgtec/men/men901za.py"
               view-as alert-box error buttons ok.
        return.
    end.
end.
else
    run prgtec/men/men901za.py (Input 'escmg705aa') /*prg_fnc_verify_security*/.
if  return-value = "2014"
then do:
    /* Programa a ser executado n∆o Ç um programa v†lido Datasul ! */
    run pi_messages (input "show",
                     input 2014,
                     input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9",
                                       'escmg705aa')) /*msg_2014*/.
    return.
end /* if */.
if  return-value = "2012"
then do:
    /* Usu†rio sem permiss∆o para acessar o programa. */
    run pi_messages (input "show",
                     input 2012,
                     input substitute ("&1~~&2~~&3~~&4~~&5~~&6~~&7~~&8~~&9",
                                       'escmg705aa')) /*msg_2012*/.
    return.
end /* if */.
/* End_Include: i_verify_security */



/* Begin_Include: i_log_exec_prog_dtsul_ini */
assign v_rec_log = ?.

if can-find(prog_dtsul
       where prog_dtsul.cod_prog_dtsul = 'escmg705aa' 
         and prog_dtsul.log_gera_log_exec = yes) then do transaction:
    create log_exec_prog_dtsul.
    assign log_exec_prog_dtsul.cod_prog_dtsul           = 'escmg705aa'
           log_exec_prog_dtsul.cod_usuario              = v_cod_usuar_corren
           log_exec_prog_dtsul.dat_inic_exec_prog_dtsul = today
           log_exec_prog_dtsul.hra_inic_exec_prog_dtsul = replace(string(time,"hh:mm:ss" /*l_hh:mm:ss*/ ),":":U,"":U).
    assign v_rec_log = recid(log_exec_prog_dtsul).
    release log_exec_prog_dtsul no-error.
end.


/* End_Include: i_log_exec_prog_dtsul_ini */


/* Begin_Include: ix_p00_escmg705aa */

/* redefiniá‰es do menu */
assign sub-menu mi_table:label in menu m_03 = "Arquivo" /*l_file*/ .

/* redefiniá‰es de window, frame e menu */

/* Begin_Include: i_std_window */
/* tratamento do t°tulo, menu, vers∆o e dimens‰es */
assign wh_w_program:title         = frame f_tipo:title
                                  + chr(32)
                                  + chr(40)
                                  + trim(" 1.00.00.000":U)
                                  + chr(41)
       frame f_tipo:title       = ?
       wh_w_program:width-chars   = frame f_tipo:width-chars
       wh_w_program:height-chars  = frame f_tipo:height-chars - 0.85
       frame f_tipo:row         = 1
       frame f_tipo:col         = 1
       wh_w_program:menubar       = menu m_03:handle
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
        /* Utiliza como °cone sempre o °cone do m¢dulo corrente */
    end /* if */.
end /* if */.

/* End_Include: i_std_window */
{include/title5.i wh_w_program}


run pi_frame_settings (Input frame f_tipo:handle) /*pi_frame_settings*/.

pause 0 before-hide.


view frame f_tipo.

enable bt_fir
       bt_pre1
       bt_nex1
       bt_las
       bt_add1
       bt_mod1
       bt_era1
       bt_sea1
       bt_exi
       bt_hel1
       bt_enter
       cst_tip_trans_aplic.cod_cta_corren
       with frame f_tipo.

if  v_rec_cst_tip_trans_aplic <> ?
then do:
    find cst_tip_trans_aplic where recid(cst_tip_trans_aplic) = v_rec_cst_tip_trans_aplic no-lock no-error.
    if  not avail cst_tip_trans_aplic
    then do:
        apply "choose" to bt_fir in frame f_tipo.
    end /* if */.
    else do:

            assign v_rec_table = v_rec_cst_tip_trans_aplic.
            run pi_disp_fields /*pi_disp_fields*/.

    end /* else */.
end /* if */.
else do:
    apply "choose" to bt_fir in frame f_tipo.
end /* else */.

{include/i_trdmnu.i wh_w_program:menubar}
main_block:
do on endkey undo main_block, leave main_block on error undo main_block, leave main_block:

    if  this-procedure:persistent = no
    then do:
        wait-for choose of bt_exi in frame f_tipo.
    end /* if */.
end /* do main_block */.



/******************************* Main Code End ******************************/

/************************* Internal Procedure Begin *************************/

/*****************************************************************************
** Procedure Interna.....: pi_disp_fields
** Descricao.............: pi_disp_fields
** Criado por............: 
** Criado em.............: // 
** Alterado por..........: Vanei
** Alterado em...........: 28/08/1997 09:50:04
*****************************************************************************/
PROCEDURE pi_disp_fields:

    find cst_tip_trans_aplic where recid(cst_tip_trans_aplic) = v_rec_table no-lock no-error.

    if available cst_tip_trans_aplic then do:


        /* Begin_Include: i_ref_cst_tip_trans_aplic */
        find first cta_corren no-lock
            where cta_corren.cod_cta_corren = cst_tip_trans_aplic.cod_cta_corren no-error.
        /* End_Include: i_ref_cst_tip_trans_aplic */



        /* ix_i05_escmg705aa */
        display cst_tip_trans_aplic.cod_cta_corren
                cst_tip_trans_aplic.cod_tip_aplic
                cst_tip_trans_aplic.cod_tip_iof
                cst_tip_trans_aplic.cod_tip_irrf
                cst_tip_trans_aplic.cod_tip_rend
                with frame f_tipo.
        display cta_corren.nom_abrev when avail cta_corren
                "" when not avail cta_corren @ cta_corren.nom_abrev
                with frame f_tipo.
        /* ix_i10_escmg705aa */

    end.

END PROCEDURE. /* pi_disp_fields */
/*****************************************************************************
** Procedure Interna.....: pi_close_program
** Descricao.............: pi_close_program
** Criado por............: 
** Criado em.............: // 
** Alterado por..........: vanei
** Alterado em...........: 14/05/1998 15:13:54
*****************************************************************************/
PROCEDURE pi_close_program:


    if  avail cst_tip_trans_aplic
    then do:
        assign v_rec_cst_tip_trans_aplic = recid(cst_tip_trans_aplic).
    end /* if */.
    else do:
        assign v_rec_cst_tip_trans_aplic = ?.
    end /* else */.


    delete widget wh_w_program.
    if  this-procedure:persistent = yes
    then do:
        delete procedure this-procedure.
    end /* if */.
END PROCEDURE. /* pi_close_program */
/*****************************************************************************
** Procedure Interna.....: pi_frame_settings
** Descricao.............: pi_frame_settings
** Criado por............: Gilsinei
** Criado em.............: 27/10/1995 08:24:12
** Alterado por..........: Gilsinei
** Alterado em...........: 27/10/1995 08:49:51
*****************************************************************************/
PROCEDURE pi_frame_settings:

    /************************ Parameter Definition Begin ************************/

    def Input param p_wgh_frame
        as widget-handle
        format ">>>>>>9"
        no-undo.


    /************************* Parameter Definition End *************************/

    /************************* Variable Definition Begin ************************/

    def var v_wgh_child                      as widget-handle   no-undo. /*local*/
    def var v_wgh_group                      as widget-handle   no-undo. /*local*/


    /************************** Variable Definition End *************************/

    assign v_wgh_group = p_wgh_frame:first-child.
    block_group:
    do while v_wgh_group <> ?:

        assign v_wgh_child = v_wgh_group:first-child.

        block_child:
        do while v_wgh_child <> ?:
            if  v_wgh_child:type = "editor" /*l_editor*/ 
            then do:
                assign v_wgh_child:read-only = yes
                       v_wgh_child:sensitive = yes.
            end /* if */.
            assign v_wgh_child = v_wgh_child:next-sibling.
        end /* do block_child */.

        assign v_wgh_group = v_wgh_group:next-sibling.
    end /* do block_group */.

END PROCEDURE. /* pi_frame_settings */

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
/***********************  End of escmg705aa **********************/
