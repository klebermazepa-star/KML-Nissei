{intprg/nicr008.i}

DEFINE VARIABLE c-cod-refer      AS CHARACTER   NO-UNDO.
DEFINE VARIABLE v_log_refer_uni  AS LOGICAL            .
DEFINE VARIABLE v_log_integr_cmg AS LOGICAL            .
DEFINE VARIABLE v_hdl_program    AS HANDLE      NO-UNDO.


def input parameter d-data-estorno as DATE no-undo.

def new global shared var gr-movto-furo as rowid no-undo.

DEFINE TEMP-TABLE tt-erro NO-UNDO
    FIELD i-sequen    AS INTEGER
    FIELD cd-erro     AS INTEGER
    FIELD mensagem    AS CHAR
    FIELD ajuda       AS CHAR. 

DEFINE BUFFER b_movto_tit_acr FOR movto_tit_acr.
DEFINE BUFFER b1_movto_tit_acr FOR movto_tit_acr.

movto_maior_block:
DO TRANSACTION ON ERROR UNDO:

        EMPTY TEMP-TABLE tt-erro.
    
        FIND FIRST b_movto_tit_acr NO-LOCK
             WHERE ROWID(b_movto_tit_acr) = gr-movto-furo NO-ERROR.
        IF AVAIL b_movto_tit_acr THEN DO:

          /*  MESSAGE "1" skip
               b_movto_tit_acr.dat_transacao skip
               b_movto_tit_acr.val_movto_tit_acr skip
               b_movto_tit_acr.cod_refer
            VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.

            FIND LAST b1_movto_tit_acr NO-LOCK USE-INDEX mvtttcr_estab_dat_trans
                WHERE b1_movto_tit_acr.cod_estab      = b_movto_tit_acr.cod_estab
                  AND b1_movto_tit_acr.num_id_tit_acr = b_movto_tit_acr.num_id_tit_acr NO-ERROR.
    
            MESSAGE "1.5" skip
                   b1_movto_tit_acr.dat_transacao skip
                   b1_movto_tit_acr.val_movto_tit_acr skip
                   b1_movto_tit_acr.cod_refer
                VIEW-AS ALERT-BOX INFORMATION BUTTONS OK. */


            RUN pi-movto-maior-especifico(INPUT b_movto_tit_acr.cod_estab,
                                          INPUT b_movto_tit_acr.num_id_tit_acr,
                                          INPUT b_movto_tit_acr.num_id_movto_tit_acr,
                                          INPUT d-data-estorno,
                                          INPUT "Estorno do Vale - Conferˆncia Furo Caixa").
        END.
END.


PROCEDURE pi-movto-maior-especifico. /* pi-estorno-movto-especifico */
/***********************************************************************
    * Procedure     : pi-estorno-movto-especifico
    * Descricao     : Estorno de movimentos especifico
    ***********************************************************************/

    DEF INPUT PARAM p-cod-estab         AS CHAR                    NO-UNDO.
    DEF INPUT PARAM p-tit-acr           AS INT                     NO-UNDO.
    DEF INPUT PARAM p-movto             AS INT                     NO-UNDO.
    DEF INPUT PARAM p-data              AS DATE                    NO-UNDO.
    DEF INPUT PARAM p-historico         AS CHAR  FORMAT "x(2000)"  NO-UNDO.

    DEFINE VARIABLE iSeq                AS INTEGER     NO-UNDO.

    FIND FIRST tit_acr NO-LOCK
         WHERE tit_Acr.cod_estab       = p-cod-estab
           AND tit_acr.num_id_tit_acr   = p-tit-acr NO-ERROR.

    FIND FIRST movto_tit_acr NO-LOCK
         WHERE movto_tit_acr.cod_estab            = p-cod-estab
           AND movto_tit_acr.num_id_movto_tit_acr = p-movto NO-ERROR.

 /*   MESSAGE "2" skip
           movto_tit_acr.dat_transacao skip
           movto_tit_acr.val_movto_tit_acr skip
           movto_tit_acr.cod_refer
        VIEW-AS ALERT-BOX INFORMATION BUTTONS OK. */

    EMPTY TEMP-TABLE tt_alter_tit_acr_base_5         NO-ERROR.
    EMPTY TEMP-TABLE tt_alter_tit_acr_rateio         NO-ERROR.
    EMPTY TEMP-TABLE tt_alter_tit_acr_ped_vda        NO-ERROR.
    EMPTY TEMP-TABLE tt_alter_tit_acr_comis_1        NO-ERROR.
    EMPTY TEMP-TABLE tt_alter_tit_acr_cheq           NO-ERROR.      
    EMPTY TEMP-TABLE tt_alter_tit_acr_iva            NO-ERROR.          
    EMPTY TEMP-TABLE tt_alter_tit_acr_impto_retid_2  NO-ERROR.
    EMPTY TEMP-TABLE tt_alter_tit_acr_cobr_espec_2   NO-ERROR. 
    EMPTY TEMP-TABLE tt_alter_tit_acr_rat_desp_rec   NO-ERROR. 
    EMPTY TEMP-TABLE tt_log_erros_alter_tit_acr      NO-ERROR.    

    FIND FIRST tt_alter_tit_acr_base_5 EXCLUSIVE-LOCK
         WHERE tt_alter_tit_acr_base_5.tta_cod_estab      = tit_acr.cod_estab
           AND tt_alter_tit_acr_base_5.tta_num_id_tit_acr = tit_acr.num_id_tit_acr NO-ERROR.
    IF NOT AVAIL tt_alter_tit_acr_base_5 THEN DO:
        CREATE tt_alter_tit_acr_base_5.
        ASSIGN tt_alter_tit_acr_base_5.tta_cod_estab      = tit_acr.cod_estab
               tt_alter_tit_acr_base_5.tta_num_id_tit_acr = tit_acr.num_id_tit_acr.
    END.

    RUN pi_retorna_sugestao_referencia (INPUT  "CF",
                                        INPUT  TODAY,
                                        OUTPUT c-cod-refer,
                                        INPUT  "tit_acr",
                                        INPUT  STRING(tit_acr.cod_estab)).

    ASSIGN tt_alter_tit_acr_base_5.tta_dat_transacao               = p-data
           tt_alter_tit_acr_base_5.tta_cod_refer                   = CAPS(c-cod-refer)
           tt_alter_tit_acr_base_5.ttv_cod_motiv_movto_tit_acr_imp = ?
           tt_alter_tit_acr_base_5.tta_val_sdo_tit_acr             = tit_acr.val_sdo_tit_acr + movto_tit_acr.val_movto_tit_acr
           tt_alter_tit_acr_base_5.ttv_cod_motiv_movto_tit_acr_alt = ? 
           tt_alter_tit_acr_base_5.ttv_ind_motiv_acerto_val        = "Altera‡Æo":U
           tt_alter_tit_acr_base_5.tta_cod_portador                = tit_acr.cod_portador
           tt_alter_tit_acr_base_5.tta_cod_cart_bcia               = tit_acr.cod_cart_bcia
           tt_alter_tit_acr_base_5.tta_val_despes_bcia             = tit_acr.val_despes_bcia
           tt_alter_tit_acr_base_5.tta_cod_agenc_cobr_bcia         = ""
           tt_alter_tit_acr_base_5.tta_cod_tit_acr_bco             = ""
           tt_alter_tit_acr_base_5.tta_dat_emis_docto              = tit_acr.dat_emis_docto
           tt_alter_tit_acr_base_5.tta_dat_vencto_tit_acr          = tit_acr.dat_vencto_tit_acr
           tt_alter_tit_acr_base_5.tta_dat_prev_liquidac           = tit_acr.dat_prev_liquidac
           tt_alter_tit_acr_base_5.tta_dat_fluxo_tit_acr           = tit_acr.dat_fluxo_tit_acr
           tt_alter_tit_acr_base_5.tta_ind_sit_tit_acr             = tit_acr.ind_sit_tit_acr
           tt_alter_tit_acr_base_5.tta_cod_cond_cobr               = tit_acr.cod_cond_cobr
           tt_alter_tit_acr_base_5.tta_log_tip_cr_perda_dedut_tit  = tit_acr.log_tip_cr_perda_dedut_tit
           tt_alter_tit_acr_base_5.tta_log_tit_acr_destndo         = tit_acr.log_tit_acr_destndo
           tt_alter_tit_acr_base_5.ttv_cod_portador_mov            = ""
           tt_alter_tit_acr_base_5.tta_ind_tip_cobr_acr            = tit_acr.ind_tip_cobr_acr
           &if '{&emsfin_version}' >= "5.02" &then
               tt_alter_tit_acr_base_5.tta_des_obs_cobr            = tit_acr.des_obs_cobr
           &endif
           tt_alter_tit_acr_base_5.ttv_log_estorn_impto_retid      = NO
           tt_alter_tit_acr_base_5.tta_cod_histor_padr             = ""
           tt_alter_tit_acr_base_5.ttv_des_text_histor             = p-historico
           tt_alter_tit_acr_base_5.tta_cdn_repres                  = tit_acr.cdn_repres
           tt_alter_tit_acr_base_5.tta_cod_instruc_bcia_1_movto    = tit_acr.cod_instruc_bcia_1_acr  
           tt_alter_tit_acr_base_5.tta_cod_instruc_bcia_2_movto    = tit_acr.cod_instruc_bcia_2_acr
           .

    ASSIGN iSeq =  10.
    FOR EACH aprop_ctbl_acr NO-LOCK
       WHERE aprop_ctbl_acr.cod_estab             = p-cod-estab
         AND aprop_ctbl_acr.num_id_movto_tit_acr  = p-movto
         AND aprop_ctbl_acr.ind_natur_lancto_ctbl = "DB" :

         CREATE tt_alter_tit_acr_rateio.
         ASSIGN tt_alter_tit_acr_rateio.tta_cod_estab                    = tt_alter_tit_acr_base_5.tta_cod_estab     
                tt_alter_tit_acr_rateio.tta_num_id_tit_acr               = tt_alter_tit_acr_base_5.tta_num_id_tit_acr
                tt_alter_tit_acr_rateio.ttv_ind_tip_rat_tit_acr          = "Altera‡Æo":U
                tt_alter_tit_acr_rateio.tta_cod_refer                    = c-cod-refer
                tt_alter_tit_acr_rateio.tta_num_seq_refer                = iSeq
                tt_alter_tit_acr_rateio.tta_cod_plano_cta_ctbl           = aprop_ctbl_acr.cod_plano_cta_ctbl   
                tt_alter_tit_acr_rateio.tta_cod_cta_ctbl                 = aprop_ctbl_acr.cod_cta_ctbl
                tt_alter_tit_acr_rateio.tta_cod_unid_negoc               = aprop_ctbl_acr.cod_unid_negoc 
                tt_alter_tit_acr_rateio.tta_cod_plano_ccusto             = aprop_ctbl_acr.cod_plano_ccusto
                tt_alter_tit_acr_rateio.tta_cod_ccusto                   = aprop_ctbl_acr.cod_ccusto
                tt_alter_tit_acr_rateio.tta_cod_tip_fluxo_financ         = "105"
                tt_alter_tit_acr_rateio.tta_num_seq_aprop_ctbl_pend_acr  = iSeq
                tt_alter_tit_acr_rateio.tta_val_aprop_ctbl               = aprop_ctbl_acr.val_aprop_ctbl
                tt_alter_tit_acr_rateio.tta_log_impto_val_agreg          = NO
                tt_alter_tit_acr_rateio.tta_cod_pais                     = ""
                tt_alter_tit_acr_rateio.tta_cod_unid_federac             = ""
                tt_alter_tit_acr_rateio.tta_cod_imposto                  = ""
                tt_alter_tit_acr_rateio.tta_cod_classif_impto            = ""
                tt_alter_tit_acr_rateio.tta_dat_transacao                = TODAY.

         ASSIGN iSeq = iSeq + 10.

    END.

    run prgfin/acr/acr711zv.py persistent set v_hdl_program /*prg_api_integr_acr_alter_tit_acr_novo_7*/.
    RUN pi_main_code_integr_acr_alter_tit_acr_novo_12 in v_hdl_program (Input 12,
                                                                        Input table  tt_alter_tit_acr_base_5,
                                                                        Input table  tt_alter_tit_acr_rateio,
                                                                        Input table  tt_alter_tit_acr_ped_vda,
                                                                        Input table  tt_alter_tit_acr_comis_1,
                                                                        Input table  tt_alter_tit_acr_cheq,
                                                                        Input table  tt_alter_tit_acr_iva,
                                                                        Input table  tt_alter_tit_acr_impto_retid_2,
                                                                        Input table  tt_alter_tit_acr_cobr_espec_2,
                                                                        Input table  tt_alter_tit_acr_rat_desp_rec,
                                                                        output table tt_log_erros_alter_tit_acr,
                                                                        Input v_log_integr_cmg) /*pi_main_code_integr_acr_alter_tit_acr_novo_12*/.
    delete procedure v_hdl_program.

    /*Tratamento de erros*/
    IF CAN-FIND(FIRST tt_log_erros_alter_tit_acr) THEN DO:
        FIND FIRST tt_alter_tit_acr_base_5 NO-LOCK NO-ERROR.
        IF AVAIL tt_alter_tit_acr_base_5 THEN DO:
            RUN pi-cria-tt-erro(INPUT 1,
                                INPUT 17006,
                                INPUT "Estab/Especie/Titulo: " + string(tt_alter_tit_acr_base_5.tta_cod_estab) + "/DI/" + STRING(tit_acr.cod_tit_acr) + " , apresentou os erros abaixo.",
                                INPUT "Estab/Especie/Titulo: " + string(tt_alter_tit_acr_base_5.tta_cod_estab) + "/DI/" + STRING(tit_acr.cod_tit_acr) + " , apresentou os erros abaixo.").                
        END.

        FOR EACH tt_log_erros_alter_tit_acr:
            RUN pi-cria-tt-erro(INPUT tt_log_erros_alter_tit_acr.tta_num_id_tit_acr,
                                INPUT tt_log_erros_alter_tit_acr.ttv_num_mensagem, 
                                INPUT tt_log_erros_alter_tit_acr.ttv_des_msg_erro,
                                INPUT tt_log_erros_alter_tit_acr.ttv_des_msg_ajuda).
        END.

        IF CAN-FIND(FIRST tt-erro) THEN DO:
            OUTPUT TO VALUE(SESSION:TEMP-DIR + "NICR008_estorno_movto.txt") NO-CONVERT.
                FOR EACH tt-erro:
                    DISP tt-erro.cd-erro
                         tt-erro.mensagem FORMAT "x(100)" SKIP
                         tt-erro.ajuda    FORMAT "x(150)" NO-LABEL
                         WITH WIDTH 333 STREAM-IO DOWN FRAME f-erro.
                   DOWN WITH FRAME f-erro.
                END.
            OUTPUT CLOSE.

            RUN winexec (INPUT "notepad.exe" + CHR(32) + SESSION:TEMP-DIR + "NICR008_estorno_movto.txt", INPUT 1).
        END.

/*         ASSIGN lErro = YES. */
    END.
    ELSE DO:
        FIND FIRST cst_furo_caixa EXCLUSIVE-LOCK
             WHERE cst_furo_caixa.num_id_tit_acr       = tit_acr.num_id_tit_acr
               AND cst_furo_caixa.num_id_movto_tit_acr = movto_tit_acr.num_id_movto_tit_acr NO-ERROR.
        IF AVAIL cst_furo_caixa THEN DO:
            ASSIGN cst_furo_caixa.situacao = 5. /* Estornado */
        END.
        RELEASE cst_furo_caixa. 

/*         ASSIGN lErro = NO. */
    END. /* */

/*     ASSIGN lErro = YES. */



END PROCEDURE. /* pi-estorno-movto-especifico */

PROCEDURE pi_retorna_sugestao_referencia :
/************************ Parameter Definition Begin ************************/

    def Input param p_ind_tip_atualiz
        as character
        format "X(08)"
        no-undo.
    def Input param p_dat_refer
        as date
        format "99/99/9999"
        no-undo.
    def output param p_cod_refer
        as character
        format "x(10)"
        no-undo.
    def Input param p_cod_table
        as character
        format "x(8)"
        no-undo.
    def input param p_estabel
        as character
        format "x(3)"
        no-undo.

    /************************* Parameter Definition End *************************/

    /************************* Variable Definition Begin ************************/

    def var v_des_dat                        as character       no-undo. /*local*/
    def var v_num_aux                        as integer         no-undo. /*local*/
    def var v_num_aux_2                      as integer         no-undo. /*local*/
    def var v_num_cont                       as integer         no-undo. /*local*/


    /************************** Variable Definition End *************************/

    assign v_des_dat   = string(p_dat_refer,"99999999")
           p_cod_refer = substring(p_ind_tip_atualiz,1,2)
                       + substring(v_des_dat,3,2)
                       + substring(v_des_dat,1,2)
                       
           v_num_aux_2 = integer(this-procedure:handle).

    do  v_num_cont = 1 to 4:
        assign v_num_aux   = (random(0,v_num_aux_2) mod 26) + 97
               p_cod_refer = p_cod_refer + chr(v_num_aux).
    end.
    
    run pi_verifica_refer_unica_acr (Input p_estabel,
                                     Input p_cod_refer,
                                     Input p_cod_table,
                                     Input ?,
                                     output v_log_refer_uni) /*pi_verifica_refer_unica_acr*/.

    IF v_log_refer_uni = NO THEN
            run pi_retorna_sugestao_referencia (Input  "BP",
                                                Input  today,
                                                output p_cod_refer,
                                                Input  p_cod_table,
                                                input  p_estabel).
    
    

END PROCEDURE. /* pi_retorna_sugestao_referencia */

PROCEDURE pi_verifica_refer_unica_acr :
/************************ Parameter Definition Begin ************************/

    def Input param p_cod_estab
        as character
        format "x(3)"
        no-undo.
    def Input param p_cod_refer
        as character
        format "x(10)"
        no-undo.
    def Input param p_cod_table
        as character
        format "x(8)"
        no-undo.
    def Input param p_rec_tabela
        as recid
        format ">>>>>>9"
        no-undo.
    def output param p_log_refer_uni
        as logical
        format "Sim/N’o"
        no-undo.


    /************************* Parameter Definition End *************************/

    /************************** Buffer Definition Begin *************************/

    def buffer b_cobr_especial_acr
        for cobr_especial_acr.
    def buffer b_lote_impl_tit_acr
        for lote_impl_tit_acr.
    def buffer b_lote_liquidac_acr
        for lote_liquidac_acr.
    def buffer b_movto_tit_acr
        for movto_tit_acr.
    def buffer b_renegoc_acr
        for renegoc_acr.


    /*************************** Buffer Definition End **************************/

    /************************* Variable Definition Begin ************************/

    def var v_cod_return
        as character
        format "x(40)"
        no-undo.


    /************************** Variable Definition End *************************/

    assign p_log_refer_uni = yes.

    if  p_cod_table <> "lote_impl_tit_acr" /*l_lote_impl_tit_acr*/  then do:
        find first b_lote_impl_tit_acr no-lock
             where b_lote_impl_tit_acr.cod_estab = p_cod_estab
               and b_lote_impl_tit_acr.cod_refer = p_cod_refer
               and recid( b_lote_impl_tit_acr ) <> p_rec_tabela
             use-index ltmplttc_id no-error.
        if  avail b_lote_impl_tit_acr then
            assign p_log_refer_uni = no.
    end.

    if  p_cod_table <> "lote_liquidac_acr" /*l_lote_liquidac_acr*/  then do:
        find first b_lote_liquidac_acr no-lock
             where b_lote_liquidac_acr.cod_estab_refer = p_cod_estab
               and b_lote_liquidac_acr.cod_refer       = p_cod_refer
               and recid( b_lote_liquidac_acr )       <> p_rec_tabela
             use-index ltlqdccr_id no-error.
        if  avail b_lote_liquidac_acr then
            assign p_log_refer_uni = no.
    end.

    if  p_cod_table = 'cobr_especial_acr' then do:
        find first b_cobr_especial_acr no-lock
             where b_cobr_especial_acr.cod_estab = p_cod_estab
               and b_cobr_especial_acr.cod_refer = p_cod_refer
               and recid( b_cobr_especial_acr ) <> p_rec_tabela
             use-index cbrspclc_id no-error.
        if  avail b_cobr_especial_acr then
            assign p_log_refer_uni = no.
    end.

    if  p_log_refer_uni = yes then do:
        find first b_renegoc_acr no-lock
            where b_renegoc_acr.cod_estab = p_cod_estab
            and   b_renegoc_acr.cod_refer = p_cod_refer
            and   recid(b_renegoc_acr)   <> p_rec_tabela
            no-error.
        if  avail b_renegoc_acr then
            assign p_log_refer_uni = no.
        else do:
            find first b_movto_tit_acr no-lock
                 where b_movto_tit_acr.cod_estab = p_cod_estab
                   and b_movto_tit_acr.cod_refer = p_cod_refer
                   and recid(b_movto_tit_acr)   <> p_rec_tabela
                 use-index mvtttcr_refer
                 no-error.
            if  avail b_movto_tit_acr then
                assign p_log_refer_uni = no.
        end.
    end.

END PROCEDURE. /* pi_verifica_refer_unica_acr */

PROCEDURE pi-cria-tt-erro :
DEFINE INPUT PARAMETER p-i-sequen    AS INTEGER   NO-UNDO.
DEFINE INPUT PARAMETER p-cd-erro     AS INTEGER   NO-UNDO.
DEFINE INPUT PARAMETER p-mensagem    AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-ajuda       AS CHARACTER NO-UNDO.
    
    CREATE tt-erro.
    ASSIGN tt-erro.i-sequen    = p-i-sequen
           tt-erro.cd-erro     = p-cd-erro 
           tt-erro.mensagem    = p-mensagem
           tt-erro.ajuda       = p-ajuda.

    RETURN "OK".

END PROCEDURE.

/* Procedure External ***********************************************************************************************************************************************************************/     
procedure WinExec external "kernel32.dll":

define input parameter prog_name    as character.                                     
define input parameter visual_style as short.    

end procedure.                                                                        
/* Procedure External ***********************************************************************************************************************************************************************/     
