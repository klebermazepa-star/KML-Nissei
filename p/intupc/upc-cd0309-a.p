/****************************************************************************
** Programa: upc-cd0309-a.p
** Objetivo: Criar conta de desconto cartÆo
*****************************************************************************/
DEF NEW GLOBAL SHARED VAR wh-ct-desc-cartao   AS WIDGET-HANDLE NO-UNDO.

/*Inicio Unifica‡Æo de Conceitos CONTA CONTABIL 2011*/
DEF VAR i-empresaCtContabel LIKE param-global.empresa-prin NO-UNDO.
def var h_api_cta               as handle no-undo.
def var h_api_ccust             as handle no-undo.
def var v_cod_cta               as char   no-undo.
def var v_des_cta               as char   no-undo.
def var v_cod_ccust             as char   no-undo.
def var v_des_ccust             as char   no-undo.
def var v_cod_format_cta        as char   no-undo.
def var v_cod_finalid           as char   no-undo.
def var v_cod_modul             as char   no-undo.
def var v_cod_format_ccust      as char   no-undo.
def var v_cod_format_inic       as char   no-undo.
def var v_cod_format_fim        as char   no-undo.
def var v_ind_finalid_cta       as char   no-undo.
def var v_num_tip_cta           as int    no-undo.
def var v_num_sit_cta           as int    no-undo.
def var v_log_utz_ccust         as log    no-undo.
def var v_cod_format_inic_ccust as char   no-undo.
def var v_cod_format_fim_ccust  as char   no-undo.
def var l-utiliza-ccusto        as log    no-undo.

def temp-table tt_log_erro no-undo
    field ttv_num_cod_erro  as integer format ">>>>,>>9" label "N£mero" column-label "N£mero"
    field ttv_des_msg_ajuda as character format "x(40)" label "Mensagem Ajuda" column-label "Mensagem Ajuda"
    field ttv_des_msg_erro  as character format "x(60)" label "Mensagem Erro" column-label "Inconsistˆncia".

DEF INPUT PARAMETER p-opcao AS CHAR.

IF p-opcao = "leave" 
THEN DO:

  RUN pi-inicia.

  IF wh-ct-desc-cartao:SCREEN-VALUE <> "" THEN DO: 

        RUN limpaErros.
        ASSIGN v_cod_cta = wh-ct-desc-cartao:SCREEN-VALUE NO-ERROR.

        RUN pi_busca_dados_cta_ctbl IN h_api_cta (INPUT        i-empresaCtContabel, /* EMPRESA EMS2 */
                                                  INPUT        "",                  /* PLANO DE CONTAS */
                                                  INPUT-OUTPUT v_cod_cta,           /* CONTA */
                                                  INPUT        TODAY,               /* DATA TRANSACAO */   
                                                  OUTPUT       v_des_cta,           /* DESCRICAO CONTA */
                                                  OUTPUT       v_num_tip_cta,       /* TIPO DA CONTA */
                                                  OUTPUT       v_num_sit_cta,       /* SITUA€ÇO DA CONTA */
                                                  OUTPUT       v_ind_finalid_cta,   /* FINALIDADES DA CONTA */
                                                  OUTPUT TABLE tt_log_erro).        /* ERROS */ 
        
        IF NOT CAN-FIND(tt_log_erro) OR RETURN-VALUE = "OK" THEN DO:
            
            ASSIGN wh-ct-desc-cartao:FORMAT        = v_cod_format_fim
                   wh-ct-desc-cartao:SCREEN-VALUE  = v_cod_cta NO-ERROR.
        
        END.

  END. 

END.

IF p-opcao = "entry" THEN DO:

  ASSIGN wh-ct-desc-cartao:FORMAT = "x(20)".

END.

IF p-opcao = "F5" THEN DO:

    RUN pi-inicia.

    RUN limpaErros.
    run pi_zoom_cta_ctbl_integr in h_api_cta (input  i-empresaCtContabel,   /* EMPRESA EMS2 */
                                              input  "FTP",                 /* M…DULO */
                                              input  "",                    /* PLANO DE CONTAS */
                                              input  "(nenhum)",            /* FINALIDADES */
                                              input  today,                 /* DATA TRANSACAO */
                                              output v_cod_cta,             /* CODIGO CONTA */
                                              output v_des_cta,             /* DESCRICAO CONTA */
                                              output v_ind_finalid_cta,     /* FINALIDADE DA CONTA */
                                              output table tt_log_erro).    /* ERROS */ 

   IF NOT CAN-FIND(FIRST tt_log_erro) OR RETURN-VALUE = "OK" THEN 
       IF v_cod_cta <> "" THEN
       ASSIGN wh-ct-desc-cartao:screen-value = v_cod_cta.

END.

PROCEDURE pi-inicia:

    FIND FIRST param-global NO-LOCK NO-ERROR. 

     /*Inicio Unifica‡Æo de Conceitos CONTA CONTABIL 2011*/

    RUN prgint\utb\utb743za.py PERSISTENT SET h_api_cta.

    ASSIGN i-empresaCtContabel = param-global.empresa-prin.
    
    /* ---------------- CONTA ---------------------------------------------------------------------------------------*/
     RUN limpaErros.
     
     RUN pi_retorna_formato_cta_ctbl in h_api_cta (input i-empresaCtContabel, /* EMPRESA EMS2 */
                                                   input  "",                 /* PLANO CONTAS */
                                                   input  today,              /* DATA DE TRANSACAO */
                                                   output v_cod_format_cta,   /* FORMATO cta */
                                                   output table tt_log_erro). /* ERROS */

     IF NOT CAN-FIND(tt_log_erro)
     OR RETURN-VALUE = "OK" THEN 
        ASSIGN v_cod_format_fim = v_cod_format_cta.

END.

PROCEDURE limpaErros:

    ASSIGN  v_des_cta         = ""   /* DESCRICAO CONTA */
            v_ind_finalid_cta = ""   /* FINALIDADE DA CONTA */
            v_cod_ccust       = ""   /* CODIGO CCUSTO */
            v_des_ccust       = "".  /* DESCRICAO CCUSTO */

    FOR EACH tt_log_erro:
      DELETE tt_log_erro.
    END.

END PROCEDURE. 
