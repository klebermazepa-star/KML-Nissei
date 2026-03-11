/*****************************************************************************
* Autor: Eduardo Barth
* Data : outubro/2022
*
* UPC dos programas: add_item_lote_impl_ap - apb704da.p
*                    mod_item_lote_impl_ap_base - apb704fb.p
*                    mod_tit_ap_alteracao_base
*
* Registra informacoes de pagamentos de tributos sem codigo de barras e FGTS/IPTU com codigo de barras.
* Tais informacoes sao enviadas via EDI para o pagamento Bradesco. 
******************************************************************************/

{include/i_fcldef.i}
{include/i_trddef.i}

DEFINE INPUT PARAMETER p-cod-table  AS CHARACTER.
DEFINE INPUT PARAMETER p-rec-table  AS RECID.  // recid(item_lote_impl_ap / tit_ap)

def var c-versao-prg as char initial " 1.00.00.000":U no-undo.
def var c-versao-rcode as char initial "[[[1.00.00.000[[[":U no-undo. /* Controle de Versao R-CODE - Nao retirar do Fonte */

/************************* Variable Definition Begin ************************/

def new global shared var v_cod_usuar_corren
    as character
    format "x(12)":U
    label "Usu†rio Corrente"
    column-label "Usu†rio Corrente"
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
def var v_nom_title_aux
    as character
    format "x(60)":U
    no-undo.
def var v_rec_table
    as recid
    format ">>>>>>9":U
    initial ?
    no-undo.
def var v_wgh_focus
    as widget-handle
    format ">>>>>>9":U
    no-undo.
DEF VAR v_periodo AS CHAR NO-UNDO FORMAT "99/9999" LABEL "Competància" INIT ?.
DEF VAR i-mes AS INT NO-UNDO.
DEF VAR i-ano AS INT NO-UNDO.

/************************** Variable Definition End *************************/

/************************ Rectangle Definition Begin ************************/

def rectangle rt_cxcf
    size 1 by 1
    fgcolor 1 edge-pixels 2.
def rectangle rt_key
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


// Retorna somente os digitos numericos de uma string.
FUNCTION SomenteNumeros RETURNS CHARACTER( input p_string as character ):
    def var i as int no-undo.
    def var c as char no-undo init "".
    def var cretorno as char no-undo init "".
    DO i = 1 to LENGTH(p_string):
       if index("0123456789",substr(p_string,i,1)) > 0 then
          assign cretorno = cretorno + substr(p_string,i,1).
    end.
    return cretorno.
END FUNCTION.


/************************** Frame Definition Begin **************************/

def frame f_adp_01_cst_tit_ap_tributo
    rt_key
         at row 01.21 col 02.00
    rt_cxcf
         at row 10.25 col 02.00 bgcolor 7 
    cst_tit_ap_tributo.tip_tributo
         at row 02.00 col 21.00 COLON-ALIGNED
         view-as TEXT
         size-chars 8.14 by .88
         fgcolor ? bgcolor 15 font 2
    cst_tit_ap_tributo.cod_receita
         at row 03.38 col 21.00 COLON-ALIGNED
         view-as fill-in
         size-chars 7.14 by .88
         fgcolor ? bgcolor 15 font 2
    cst_tit_ap_tributo.dat_competencia
        at row 04.38 col 21.00 COLON-ALIGNED
        view-as fill-in
        size-chars 12.14 by .88
        fgcolor ? bgcolor 15 font 2
    v_periodo
        at row 04.38 col 21.00 COLON-ALIGNED
        view-as fill-in
        size-chars 9.14 by .88
        fgcolor ? bgcolor 15 font 2
    cst_tit_ap_tributo.cod_identificador_fgts FORMAT "X(16)"
        at row 05.38 col 21.00 COLON-ALIGNED
        view-as fill-in
        size-chars 23 by .88
        fgcolor ? bgcolor 15 font 2
    cst_tit_ap_tributo.tip_identificador_gps
        at row 05.38 col 21.00 COLON-ALIGNED
        //size-chars 19 by .88
        fgcolor ? bgcolor 15 font 2
        LABEL "Identificador"
    cst_tit_ap_tributo.cod_identificador_gps FORMAT "X(14)"
        at row 05.38 col 40.00 COLON-ALIGNED
        VIEW-AS FILL-IN 
        size-chars 21 by 0.88
        fgcolor ? bgcolor 15 font 2
        NO-LABELS
    cst_tit_ap_tributo.val_outras_entidades_gps
        at row 06.38 col 21.00 COLON-ALIGNED
        view-as fill-in
        size-chars 18 by .88
        fgcolor ? bgcolor 15 font 2
    cst_tit_ap_tributo.num_referencia_darf FORMAT "x(17)" 
        at row 05.38 col 21.00 COLON-ALIGNED
        view-as fill-in
        size-chars 25 by .88
        fgcolor ? bgcolor 15 font 2
    bt_ok
         at row 10.46 col 03.00 font ?
         help "OK"
    bt_can
         at row 10.46 col 14.00 font ?
         help "Cancela"
    bt_hel2
         at row 10.46 col 47.00 font ?
         help "Ajuda"
    with 1 down side-labels no-validate keep-tab-order three-d
         size-char 71.00 by 12.20 default-button bt_ok
         view-as dialog-box
         font 1 fgcolor ? bgcolor 8
         title "Informaá‰es da Guia de Tributo".
    /* adjust size of objects in this frame */
    assign bt_can:width-chars   in frame f_adp_01_cst_tit_ap_tributo = 10.00
           bt_can:height-chars  in frame f_adp_01_cst_tit_ap_tributo = 01.00
           bt_hel2:width-chars  in frame f_adp_01_cst_tit_ap_tributo = 10.00
           bt_hel2:height-chars in frame f_adp_01_cst_tit_ap_tributo = 01.00
           bt_ok:width-chars    in frame f_adp_01_cst_tit_ap_tributo = 10.00
           bt_ok:height-chars   in frame f_adp_01_cst_tit_ap_tributo = 01.00
           rt_cxcf:width-chars  in frame f_adp_01_cst_tit_ap_tributo = 68.00
           rt_cxcf:height-chars in frame f_adp_01_cst_tit_ap_tributo = 01.42
           rt_key:width-chars   in frame f_adp_01_cst_tit_ap_tributo = 68.00
           rt_key:height-chars  in frame f_adp_01_cst_tit_ap_tributo = 08.70
           .

{include/i_fclfrm.i f_adp_01_cst_tit_ap_tributo }

/*************************** Frame Definition End ***************************/

/*********************** User Interface Trigger Begin ***********************/


ON CHOOSE OF bt_can IN FRAME f_adp_01_cst_tit_ap_tributo
DO:

    apply "end-error" to self.
END. /* ON CHOOSE OF bt_can IN FRAME f_adp_01_cst_tit_ap_tributo */

ON CHOOSE OF bt_hel2 IN FRAME f_adp_01_cst_tit_ap_tributo
DO:


    /* Begin_Include: i_context_help_frame */
    run prgtec/men/men900za.py (Input self:frame,
                                Input this-procedure:handle) /*prg_fnc_chamar_help_context*/.


    /* End_Include: i_context_help_frame */

END. /* ON CHOOSE OF bt_hel2 IN FRAME f_adp_01_cst_tit_ap_tributo */

ON CHOOSE OF bt_ok IN FRAME f_adp_01_cst_tit_ap_tributo
DO:

    assign v_log_repeat = no.
    /* ix_g20_add_cst_tit_ap_tributo */

END. /* ON CHOOSE OF bt_ok IN FRAME f_adp_01_cst_tit_ap_tributo */

/************************ User Interface Trigger End ************************/

/**************************** Frame Trigger Begin ***************************/

ON HELP OF FRAME f_adp_01_cst_tit_ap_tributo ANYWHERE
DO:


    /* Begin_Include: i_context_help */
    run prgtec/men/men900za.py (Input self:handle,
                                Input this-procedure:handle) /*prg_fnc_chamar_help_context*/.
    /* End_Include: i_context_help */

END. /* ON HELP OF FRAME f_adp_01_cst_tit_ap_tributo */

ON RIGHT-MOUSE-DOWN OF FRAME f_adp_01_cst_tit_ap_tributo ANYWHERE
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
        end .
        assign v_nom_title_aux    = v_wgh_frame:title
               v_wgh_frame:title  = self:help.
    end .
    /* End_Include: i_right_mouse_down_dialog_box */

END. /* ON RIGHT-MOUSE-DOWN OF FRAME f_adp_01_cst_tit_ap_tributo */

ON RIGHT-MOUSE-UP OF FRAME f_adp_01_cst_tit_ap_tributo ANYWHERE
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
        end .
        assign v_wgh_frame:title  = v_nom_title_aux.
    end .

    /* End_Include: i_right_mouse_up_dialog_box */

END. /* ON RIGHT-MOUSE-UP OF FRAME f_adp_01_cst_tit_ap_tributo */

ON WINDOW-CLOSE OF FRAME f_adp_01_cst_tit_ap_tributo
DO:

    apply "end-error" to self.
END. /* ON WINDOW-CLOSE OF FRAME f_adp_01_cst_tit_ap_tributo */


/***************************** Frame Trigger End ****************************/

/* tratamento do titulo e vers∆o */
assign frame f_adp_01_cst_tit_ap_tributo:title = frame f_adp_01_cst_tit_ap_tributo:title
                            + chr(32)
                            + chr(40)
                            + trim(" 1.00.00.000":U)
                            + chr(41).
pause 0 before-hide.
view frame f_adp_01_cst_tit_ap_tributo.

assign v_log_repeat   = yes.

IF p-cod-table = "tit_ap" THEN DO:
    FIND tit_ap WHERE RECID(tit_ap) = p-rec-table NO-LOCK NO-ERROR.
    IF NOT AVAIL tit_ap THEN RETURN "".
    FIND cst_espec_tributo OF tit_ap NO-LOCK NO-ERROR.
    FIND cst_tit_ap_tributo OF tit_ap EXCLUSIVE-LOCK NO-ERROR.
END.
ELSE DO:
    FIND item_lote_impl_ap WHERE RECID(item_lote_impl_ap) = p-rec-table NO-LOCK NO-ERROR.
    IF NOT AVAIL item_lote_impl_ap THEN RETURN "".
    FIND cst_espec_tributo OF item_lote_impl_ap NO-LOCK NO-ERROR.
    FIND cst_tit_ap_tributo OF ITEM_lote_impl_ap EXCLUSIVE-LOCK NO-ERROR.
END.

IF NOT AVAIL cst_espec_tributo THEN RETURN "".
IF cst_espec_tributo.tip_tributo = "" THEN RETURN "".
IF cst_espec_tributo.tip_tributo = "IPTU" THEN RETURN "".

main_block:
repeat while v_log_repeat:

    assign v_log_repeat  = no
           v_log_save_ok = no.
    IF  NOT AVAIL cst_tit_ap_tributo THEN DO:
        create cst_tit_ap_tributo.
        ASSIGN cst_tit_ap_tributo.tip_identificador_gps = 1.
        IF p-cod-table = "tit_ap"
            THEN BUFFER-COPY tit_ap TO cst_tit_ap_tributo.
            ELSE BUFFER-COPY ITEM_lote_impl_ap TO cst_tit_ap_tributo.
    END.

    IF  cst_tit_ap_tributo.dat_competencia = ? THEN
        ASSIGN cst_tit_ap_tributo.dat_competencia = IF p-cod-table = "tit_ap"
            THEN tit_ap.dat_emis_docto ELSE item_lote_impl_ap.dat_emis_docto.

    IF  v_periodo = ? THEN
        ASSIGN v_periodo = STRING(MONTH(cst_tit_ap_tributo.dat_competencia),"99")
                         + STRING(YEAR(cst_tit_ap_tributo.dat_competencia),"9999").

    IF  cst_tit_ap_tributo.tip_tributo = ?
    OR  cst_tit_ap_tributo.tip_tributo = "" THEN
        ASSIGN cst_tit_ap_tributo.tip_tributo = cst_espec_tributo.tip_tributo.
    HIDE cst_tit_ap_tributo.tip_tributo
         cst_tit_ap_tributo.cod_receita
         cst_tit_ap_tributo.dat_competencia
         v_periodo
         cst_tit_ap_tributo.num_referencia_darf   
         cst_tit_ap_tributo.cod_identificador_fgts
         cst_tit_ap_tributo.tip_identificador_gps
         cst_tit_ap_tributo.cod_identificador_gps
         cst_tit_ap_tributo.val_outras_entidades_gps
         IN frame f_adp_01_cst_tit_ap_tributo.

    DISPLAY
        cst_tit_ap_tributo.tip_tributo
        cst_tit_ap_tributo.cod_receita
        with frame f_adp_01_cst_tit_ap_tributo.

    IF  cst_tit_ap_tributo.tip_tributo = "GPS" THEN DO:
        DISPLAY v_periodo
                cst_tit_ap_tributo.tip_identificador_gps
                cst_tit_ap_tributo.cod_identificador_gps
                cst_tit_ap_tributo.val_outras_entidades_gps
                with frame f_adp_01_cst_tit_ap_tributo.
        ENABLE  v_periodo
                cst_tit_ap_tributo.tip_identificador_gps
                cst_tit_ap_tributo.cod_identificador_gps
                cst_tit_ap_tributo.val_outras_entidades_gps
                with frame f_adp_01_cst_tit_ap_tributo.
        ASSIGN  v_periodo:LABEL IN FRAME f_adp_01_cst_tit_ap_tributo = "Competància".
        ASSIGN  cst_tit_ap_tributo.cod_receita:LABEL IN FRAME f_adp_01_cst_tit_ap_tributo = "C¢digo de Pagamento".
    END.
    
    IF  cst_tit_ap_tributo.tip_tributo = "DARF" THEN DO:
        DISPLAY cst_tit_ap_tributo.dat_competencia
                cst_tit_ap_tributo.num_referencia_darf 
                with frame f_adp_01_cst_tit_ap_tributo.
        ENABLE  cst_tit_ap_tributo.dat_competencia
                cst_tit_ap_tributo.num_referencia_darf 
                with frame f_adp_01_cst_tit_ap_tributo.
        ASSIGN  cst_tit_ap_tributo.dat_competencia:LABEL IN FRAME f_adp_01_cst_tit_ap_tributo = "Per°odo de Apuraá∆o".
    END.

    IF  cst_tit_ap_tributo.tip_tributo = "GARE-SP" THEN DO:
        DISPLAY v_periodo
                with frame f_adp_01_cst_tit_ap_tributo.
        ENABLE  v_periodo
                with frame f_adp_01_cst_tit_ap_tributo.
        ASSIGN v_periodo:LABEL IN FRAME f_adp_01_cst_tit_ap_tributo = "Per°odo de Referància".
    END.

    IF  cst_tit_ap_tributo.tip_tributo = "FGTS" THEN DO:
        DISPLAY cst_tit_ap_tributo.cod_identificador_fgts
                with frame f_adp_01_cst_tit_ap_tributo.
        ENABLE  cst_tit_ap_tributo.cod_identificador_fgts
                with frame f_adp_01_cst_tit_ap_tributo.
    END.

    ENABLE cst_tit_ap_tributo.cod_receita
           bt_ok
           bt_can
           bt_hel2
           with frame f_adp_01_cst_tit_ap_tributo.

    wait_block:
    repeat on endkey undo main_block, leave main_block while v_log_save_ok = no:
        if  valid-handle(v_wgh_focus)
        then do:
            wait-for go of frame f_adp_01_cst_tit_ap_tributo focus v_wgh_focus.
        end .
        else do:
            wait-for go of frame f_adp_01_cst_tit_ap_tributo.
        end /* else */.
        save_block:
        do on error undo save_block, leave save_block:
            ASSIGN INPUT FRAME f_adp_01_cst_tit_ap_tributo cst_tit_ap_tributo.cod_receita
                   INPUT FRAME f_adp_01_cst_tit_ap_tributo v_periodo
                   INPUT FRAME f_adp_01_cst_tit_ap_tributo cst_tit_ap_tributo.num_referencia_darf 
                   INPUT FRAME f_adp_01_cst_tit_ap_tributo cst_tit_ap_tributo.dat_competencia
                   INPUT FRAME f_adp_01_cst_tit_ap_tributo cst_tit_ap_tributo.cod_identificador_fgts
                   INPUT FRAME f_adp_01_cst_tit_ap_tributo cst_tit_ap_tributo.tip_identificador_gps
                   INPUT FRAME f_adp_01_cst_tit_ap_tributo cst_tit_ap_tributo.cod_identificador_gps
                   INPUT FRAME f_adp_01_cst_tit_ap_tributo cst_tit_ap_tributo.val_outras_entidades_gps.
            
            ASSIGN cst_tit_ap_tributo.num_referencia_darf     = SomenteNumeros(cst_tit_ap_tributo.num_referencia_darf   ) 
                   cst_tit_ap_tributo.cod_identificador_fgts  = SomenteNumeros(cst_tit_ap_tributo.cod_identificador_fgts)
                   cst_tit_ap_tributo.cod_identificador_gps   = SomenteNumeros(cst_tit_ap_tributo.cod_identificador_gps ).

            IF  cst_tit_ap_tributo.tip_tributo <> "DARF"
            AND cst_tit_ap_tributo.tip_tributo <> "FGTS" THEN DO:
                ASSIGN i-mes = INTEGER(SUBSTR(v_periodo,1,2)) NO-ERROR.
                IF  NOT ERROR-STATUS:ERROR THEN 
                    ASSIGN i-ano = int(SUBSTR(v_periodo,3,4)) NO-ERROR.
                IF  NOT ERROR-STATUS:ERROR THEN
                    ASSIGN cst_tit_ap_tributo.dat_competencia = DATE( i-mes, 01, i-ano ) NO-ERROR.
                IF  ERROR-STATUS:ERROR THEN DO:
                    RUN utp/ut-msgs.p (INPUT 'show':U,
                                       INPUT 17006,
                                       INPUT 'Màs/Ano inv†lido~~Informe corretamente o màs/ano').
                    UNDO, NEXT.
                END.
            END.

            assign v_log_save_ok = yes.
        end /* do save_block */.
    end /* repeat wait_block */.
    assign v_rec_table    = recid(cst_tit_ap_tributo).
end /* repeat main_block */.

hide frame f_adp_01_cst_tit_ap_tributo.

RETURN "OK".


/******************************* Main Code End ******************************/


