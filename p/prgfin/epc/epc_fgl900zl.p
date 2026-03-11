/*****************************************************************************
** Copyright DATASUL S.A. (1994)
** Todos os Direitos Reservados.
** 
** Este fonte e de propriedade exclusiva da DATASUL, sua reproducao
** parcial ou total por qualquer meio, so' podera ser feita mediante
** autorizacao expressa.
**
** Programa..............: epc_apb900zg
** Descricao.............: EPC - Cria temp-table de erros
** Programa Chamador.....: api_lote_ctbl_recebto_1 - prgfin/apb/apb900zg.py
** Criado por............: fut40695 - Paulo Roberto Barth
** Criado em.............: 16/12/2008
*****************************************************************************/
def var c-versao-prg as char initial " 1.00.00.000":U no-undo.

/******************************* Private-Data *******************************/
assign this-procedure:private-data = "HLP=0":U.
/*************************************  *************************************/

define temp-table tt_epc no-undo 
    field cod_event        as character 
    field cod_parameter    as character 
    field val_parameter    as character 
    index id is primary cod_parameter cod_event ascending. 

DEF NEW GLOBAL SHARED TEMP-TABLE tt_erro_contab_nissei no-undo
    field ttv_num_mensagem as integer   format ">>>>,>>9" label "N£mero"
    field ttv_des_mensagem as character format "X(08)"    label "Posi‡Æo".

DEF SHARED TEMP-TABLE tt_integr_ctbl_valid_1 no-undo
    field ttv_rec_integr_ctbl              as recid format ">>>>>>9"
    field ttv_num_mensagem                 as integer format ">>>>,>>9" label "N£mero" column-label "N£mero Mensagem"
    field ttv_ind_pos_erro                 as character format "X(08)" label "Posi‡Æo"
    index tt_id                            is primary unique
          ttv_rec_integr_ctbl              ascending
          ttv_num_mensagem                 ascending
    .

/************************* Parameter Definition Begin ************************/
Define Input parameter p_ind_event
    as character
    format 'x(50)'
    no-undo.

DEF INPUT-OUTPUT PARAM TABLE FOR tt_epc.
/************************** Parameter Definition End *************************/

/************************* Variable Definition Begin ************************/
DEF VAR h_prg_msg     AS WIDGET-HANDLE NO-UNDO.
def var v_des_mensagem
    as character
    format "x(50)":U
    view-as editor max-chars 2000 scrollbar-vertical
    size 50 by 4
    bgcolor 15 font 2
    label "Mensagem"
    column-label "Mensagem"
    no-undo.

def var v_des_ajuda
    as character
    format "x(50)":U
    view-as editor max-chars 2000 scrollbar-vertical
    size 50 by 3
    bgcolor 15 font 2
    label "Ajuda"
    column-label "Ajuda"
    no-undo.

/************************** Variable Definition End *************************/

FIND tt_epc WHERE tt_epc.cod_event     = "FGL900ZG"
              AND tt_epc.cod_parameter = "Entrada" NO-ERROR.

if p_ind_event = "fgl900zg" AND AVAIL tt_epc then do:

    FOR EACH tt_erro_contab_nissei:
        DELETE tt_erro_contab_nissei.
    END.

    RUN prgfin/spp/spp900zl.p PERSISTENT SET h_prg_msg.

    FOR EACH tt_integr_ctbl_valid_1:

        CREATE tt_erro_contab_nissei.

        RUN pi_msg_lote_ctbl_recebto_1 IN h_prg_msg (INPUT tt_integr_ctbl_valid_1.ttv_rec_integr_ctbl,
                                                     Input tt_integr_ctbl_valid_1.ttv_num_mensagem,
                                                     output v_des_mensagem,
                                                     output v_des_ajuda).

        ASSIGN tt_erro_contab_nissei.ttv_num_mensagem = tt_integr_ctbl_valid_1.ttv_num_mensagem
               tt_erro_contab_nissei.ttv_des_mensagem = v_des_ajuda + " - " + v_des_mensagem.
    END.
END.
