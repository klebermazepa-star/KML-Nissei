/****************************************************************************
** Programa: upc-cd0606-a.p
** Objetivo: Chamar zoom para campo espec¡fico "Conta Bonifica‡Æo"
*****************************************************************************/

{utp/ut-glob.i}

DEFINE NEW GLOBAL SHARED VAR wh-cod-cta-bonif-cd0606   AS WIDGET-HANDLE NO-UNDO.

DEFINE VARIABLE v_cod_cta_ctbl    AS CHARACTER   NO-UNDO.
DEFINE VARIABLE v_titulo_cta_ctbl AS CHARACTER   NO-UNDO.
DEFINE VARIABLE v_ind_finalid_cta AS CHARACTER   NO-UNDO.
DEFINE VARIABLE h_api_cta_ctbl    AS HANDLE      NO-UNDO.

def temp-table tt_log_erro no-undo
    field ttv_num_cod_erro   as int  format ">>>>,>>9" label "N£mero"         column-label "N£mero"
    field ttv_des_msg_ajuda  as char format "x(40)"    label "Mensagem Ajuda" column-label "Mensagem Ajuda"
    field ttv_des_msg_erro   as char format "x(60)"    label "Mensagem Erro"  column-label "Inconsistˆncia".

RUN prgint\utb\utb743za.py PERSISTENT SET h_api_cta_ctbl.

RUN pi_zoom_cta_ctbl_integr in h_api_cta_ctbl (INPUT  string(i-ep-codigo-usuario),  /* EMPRESA EMS2 */
                                               INPUT  "CEP",                        /* MODULO */
                                               INPUT  "",                           /* PLANO DE CONTAS */
                                               INPUT  "(nenhum)",                   /* FINALIDADES */
                                               INPUT  TODAY,                        /* DATA TRANSACAO */
                                               OUTPUT v_cod_cta_ctbl,               /* CODIGO CONTA */
                                               OUTPUT v_titulo_cta_ctbl,            /* DESCRICAO CONTA */
                                               OUTPUT v_ind_finalid_cta,            /* FINALIDADE DA CONTA */
                                               OUTPUT TABLE tt_log_erro).           /* ERROS */
DELETE OBJECT h_api_cta_ctbl.

IF RETURN-VALUE = "OK" 
THEN
    ASSIGN wh-cod-cta-bonif-cd0606:SCREEN-VALUE = v_cod_cta_ctbl.

RETURN "OK".


