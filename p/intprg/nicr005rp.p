/********************************************************************************
*******************************************************************************/
{include/i-prgvrs.i NICR005RP 2.06.00.001}  
{include/i_fnctrad.i}
/******************************************************************************
**
**       PROGRAMA: NICR005RP
**
**       DATA....: 04/2016
**
**       OBJETIVO: Gera‡Æo do Titulo Devolu‡Æo. 
**
**       VERSAO..: 2.06.001
** 
******************************************************************************/
DEFINE BUFFER portador       FOR ems5.portador.
DEFINE BUFFER bf-fat-duplic  FOR fat-duplic.
DEFINE BUFFER bf-nota-fiscal FOR nota-fiscal.
DEFINE BUFFER bf-estabelec   FOR estabelec.

{include/i-rpvar.i}
{include/i-rpcab.i}

/* {utp/ut-glob.i} */ 
def new Global shared var c-seg-usuario as char format "x(12)" no-undo.

{method/dbotterr.i} 
{intprg/nicr005rp.i}
/*{cdp/cd0666.i}       Definicao da temp-table de erros */

define temp-table tt-param no-undo
    field destino            as integer
    field arquivo            as char format "x(35)"
    field usuario            as char format "x(12)"
    field data-exec          as date
    field hora-exec          as integer
    field classifica         as integer
    field desc-classifica    as char format "x(40)"
    field modelo-rtf         as char format "x(35)"
    field l-habilitaRtf      as LOG
    FIELD c-estab-ini        AS CHAR FORMAT "x(05)"
    FIELD c-estab-fim        AS CHAR FORMAT "x(05)"
    FIELD c-cliente-ini      LIKE emitente.cod-emitente
    FIELD c-cliente-fim      LIKE emitente.cod-emitente
    FIELD c-portador-ini     LIKE portador.cod_portador
    FIELD c-portador-fim     LIKE portador.cod_portador
    FIELD c-data-emissao-ini LIKE nota-fiscal.dt-emis
    FIELD c-data-emissao-fim LIKE nota-fiscal.dt-emis
    FIELD l-cupons-agrup     AS LOGICAL INITIAL NO
    FIELD l-cupons-conv      AS LOGICAL INITIAL NO
    .

DEFINE VARIABLE v_log_refer_uni AS LOGICAL   NO-UNDO.

DEFINE VARIABLE iNumSeq AS INTEGER     NO-UNDO.
DEFINE VARIABLE lErro   AS LOGICAL     NO-UNDO.


DEFINE TEMP-TABLE tt-tit-criados  
    FIELD cod_estab           LIKE tit_acr.cod_estab         
    FIELD cod_espec_docto     LIKE tit_acr.cod_espec_docto   
    FIELD cod_ser_docto       LIKE tit_acr.cod_ser_docto     
    FIELD cod_tit_acr         LIKE tit_acr.cod_tit_acr       
    FIELD cod_parcela         LIKE tit_acr.cod_parcela       
    FIELD cdn_cliente         LIKE tit_acr.cdn_cliente       
    FIELD cod_portador        LIKE tit_acr.cod_portador      
    FIELD dat_transacao       LIKE tit_acr.dat_transacao     
    FIELD dat_emis_docto      LIKE tit_acr.dat_emis_docto    
    FIELD dat_vencto_tit_acr  LIKE tit_acr.dat_vencto_tit_acr
    FIELD val_origin_tit_acr  LIKE tit_acr.val_origin_tit_acr
    FIELD situacao            AS CHAR FORMAT "x(20)".

DEFINE TEMP-TABLE tt-devolucao NO-UNDO
    FIELD cod-estab      LIKE docum-est.cod-estab     
    FIELD cod-emitente   LIKE estabelec.cod-emitente  
    FIELD serie-docto    LIKE docum-est.serie-docto   
    FIELD nro-docto      LIKE docum-est.nro-docto     
    FIELD nat-operacao   LIKE docum-est.nat-operacao  
    FIELD cod-parcela    LIKE cst_fat_devol.parcela
    FIELD cod-portador   LIKE cst_fat_devol.cod_portador
    FIELD val-devolucao  LIKE cst_fat_devol.vl_devolucao
    FIELD dat-emissao    LIKE docum-est.dt-emis
    FIELD dat-trans      LIKE docum-est.dt-trans
    FIELD cod-prefixo    AS CHAR FORMAT "x(4)"
    FIELD r-fat-devol    AS ROWID
    FIELD cod-estab-ori  LIKE nota-fiscal.cod-estabel 
    FIELD serie-ori      LIKE nota-fiscal.serie       
    FIELD dat-emiss-ori  LIKE nota-fiscal.dt-emis-nota
    FIELD l-estab-dif    AS LOGICAL INITIAL NO
    FIELD l-dat-emis     LIKE portador_agrupador.ind_devol_dat_emis.
    .
DEFINE TEMP-TABLE tt-devolucao-convenio NO-UNDO
    FIELD cod-estab      LIKE docum-est.cod-estab     
    FIELD cod-emitente   LIKE estabelec.cod-emitente  
    FIELD serie-docto    LIKE docum-est.serie-docto   
    FIELD nro-docto      LIKE docum-est.nro-docto     
    FIELD nat-operacao   LIKE docum-est.nat-operacao  
    FIELD cod-parcela    LIKE cst_fat_devol.parcela
    FIELD cod-portador   LIKE cst_fat_devol.cod_portador
    FIELD val-devolucao  LIKE cst_fat_devol.vl_devolucao
    FIELD dat-emissao    LIKE docum-est.dt-emis
    FIELD dat-trans      LIKE docum-est.dt-trans
    FIELD nota-devol     LIKE nota-fiscal.nr-nota-fis
    FIELD serie-devol    LIKE nota-fiscal.serie
    FIELD r-fat-devol    AS ROWID
    FIELD cod-estab-ori  LIKE nota-fiscal.cod-estabel 
    FIELD dat-emiss-ori  LIKE nota-fiscal.dt-emis-nota
    FIELD l-estab-dif    AS LOGICAL INITIAL NO
    .

DEFINE TEMP-TABLE tt-devolucao-aux          LIKE tt-devolucao.
DEFINE TEMP-TABLE tt-devolucao-convenio-aux LIKE tt-devolucao-convenio.

def temp-table tt-raw-digita
    field raw-digita as raw.

DEF TEMP-TABLE tt-raw-param 
 FIELD raw-param  AS RAW.

DEFINE TEMP-TABLE tt-erro NO-UNDO
    FIELD i-sequen    AS INTEGER
    FIELD cd-erro     AS INTEGER
    FIELD mensagem    AS CHAR
    FIELD ajuda       AS CHAR.   

def input parameter raw-param as raw no-undo.
def input parameter table for tt-raw-digita.

create tt-param.
raw-transfer raw-param to tt-param.

def new global shared var v_cdn_empres_usuar        like mguni.empresa.ep-codigo no-undo.
def new global shared var v_cod_matriz_trad_org_ext as character format "x(8)" label "Matriz UO"  column-label "Matriz UO" no-undo. 

def var c-acompanha    as char    no-undo.
DEF VAR h-acomp        AS HANDLE  NO-UNDO.

DEFINE VARIABLE v_hdl_api_integr_acr AS HANDLE      NO-UNDO.
DEFINE VARIABLE c-estab-ems-5        AS CHARACTER   NO-UNDO.
DEFINE VARIABLE c-empresa-ems-5      AS CHARACTER   NO-UNDO.
DEFINE VARIABLE c-erro               AS CHARACTER   NO-UNDO.

DEFINE VARIABLE vlTaxaCartao  LIKE tit_acr.val_sdo_tit_acr.

find first param-estoq  no-lock no-error.
find first param-global no-lock no-error.
find first ems2mult.empresa where 
           empresa.ep-codigo = param-global.empresa-prin no-lock no-error.

assign c-programa = "nicr005rp"
       c-versao   = "2.06"
       c-revisao  = "001"
       c-empresa  = empresa.razao-social.

find first tt-param no-lock no-error.
{include/i-rpout.i}
{utp/ut-liter.i Gera‡Æo_T¡tulo_Devolu‡Æo * L}
assign c-titulo-relat = trim(return-value).
{utp/ut-liter.i Gera‡Æo_T¡tulo_Devolu‡Æo * L}
assign c-sistema = trim(return-value).

VIEW frame f-cabec.
view frame f-rodape.

/* {intprg/nicr005rp.i} */
                    
/* log-manager:logfile-name= "\\192.168.200.52\datasul\_custom_teste\Prog_QG\Geracao_Titulo_Devolucao.txt". */
/* log-manager:log-entry-types= "4gltrace".                                                                 */

EMPTY TEMP-TABLE tt-tit-criados.
EMPTY TEMP-TABLE tt-erro.
   
RUN utp/ut-acomp.p PERSISTENT SET h-acomp.
RUN pi-inicializar IN h-acomp (INPUT "Verificando Devolu‡äes").

IF l-cupons-agrup = YES THEN DO:

    FOR EACH bf-estabelec NO-LOCK
        WHERE bf-estabelec.cod-estabel   >= tt-param.c-estab-ini 
          AND bf-estabelec.cod-estabel   <= tt-param.c-estab-fim :

        /* Movimenta‡Æo de Dinheiro */
        RUN pi-seta-titulo IN h-acomp (INPUT "Devolu‡Æo - Dinheiro":U).
        RUN pi-carrega-movto-dinheiro.
        RUN pi-seta-titulo IN h-acomp (INPUT "Gerando T¡tulo - Dinheiro":U).
        RUN pi-gera-titulo-dinheiro.
        
        /* Movimenta‡Æo de CartÆo de D‚bito */
        RUN pi-seta-titulo IN h-acomp (INPUT "Devolu‡Æo - CartÆo":U).
        RUN pi-carrega-movto-cartao.
        RUN pi-seta-titulo IN h-acomp (INPUT "Gerando T¡tulo - CartÆo":U).
        RUN pi-gera-titulo-cartao.

    END.
END.

IF tt-param.l-cupons-conv = YES THEN DO:
    RUN pi-seta-titulo IN h-acomp (INPUT "Devolu‡Æo - Convˆnio":U).
    RUN pi-carrega-movto-convenio.
    RUN pi-seta-titulo IN h-acomp (INPUT "Gerando Nota Cr‚dito - Convˆnio":U).
    RUN pi-gera-titulo-convenio.
END.

RUN pi-seta-titulo IN h-acomp (INPUT "Imprimindo T¡tulos Criados":U).
RUN pi-mostra-titulos-criados.
RUN pi-seta-titulo IN h-acomp (INPUT "Imprimindo Erros":U).
RUN pi-mostra-erros.

RUN pi-finalizar IN h-acomp.     
{include/i-rpclo.i}   

/* log-manager:close-log(). */

return "OK":U.

PROCEDURE pi-gera-titulo-dinheiro:
    DEFINE VARIABLE dValorTotal LIKE cst_fat_devol.vl_devolucao  NO-UNDO.

    /*Transa‡Æo, pois, implanta tudo ou nada*/
    bloco_trans:
    DO TRANSACTION ON ERROR UNDO:

        /* INICIO -  Processa  Devolu‡Æo com Estabelecimento da Devolu‡Æo Igual da Origem */
        FOR EACH tt-devolucao
           WHERE tt-devolucao.l-estab-dif = NO
        BREAK BY tt-devolucao.cod-estab
              BY tt-devolucao.serie-docto
              BY tt-devolucao.dat-emissao
              BY tt-devolucao.dat-trans
              :

            IF FIRST-OF(tt-devolucao.dat-trans) THEN DO:
                ASSIGN dValorTotal = 0.
                EMPTY TEMP-TABLE tt-devolucao-aux.
            END.

            CREATE tt-devolucao-aux.
            BUFFER-COPY tt-devolucao TO tt-devolucao-aux.
        
            ASSIGN dValorTotal = dValorTotal + tt-devolucao.val-devolucao.
        
            IF LAST-OF(tt-devolucao.dat-trans) THEN DO:
                ASSIGN lErro = NO.

                RUN pi-cria-tit-acr(INPUT tt-devolucao.cod-estab,
                                    INPUT tt-devolucao.dat-emissao,
                                    INPUT tt-devolucao.dat-trans,
                                    INPUT tt-devolucao.cod-prefixo,
                                    INPUT tt-devolucao.cod-emitente,
                                    INPUT tt-devolucao.serie-docto,
                                    INPUT tt-devolucao.cod-portador,
                                    INPUT dValorTotal,
                                    INPUT "Dinheiro",
                                    INPUT NO,
                                    INPUT tt-devolucao.dat-emissao,
                                    OUTPUT lErro).

                ASSIGN dValorTotal = 0.

                IF lErro = YES THEN
                    UNDO bloco_trans, LEAVE bloco_trans.
            END.
        END. /* FOR EACH tt-devolucao */
        /* FIM    -  Processa  Devolu‡Æo com Estabelecimento da Devolu‡Æo Igual da Origem */

        /* INICIO -  Processa  Devolu‡Æo com Estabelecimento da Devolu‡Æo Diferente da Origem */
        FOR EACH tt-devolucao
           WHERE tt-devolucao.l-estab-dif = YES
        BREAK BY tt-devolucao.cod-estab-ori
              BY tt-devolucao.serie-ori    
              BY tt-devolucao.dat-emiss-ori:

            IF FIRST-OF(tt-devolucao.dat-emiss-ori) THEN DO:
                ASSIGN dValorTotal = 0.
                EMPTY TEMP-TABLE tt-devolucao-aux.
            END.

            CREATE tt-devolucao-aux.
            BUFFER-COPY tt-devolucao TO tt-devolucao-aux.
        
            ASSIGN dValorTotal = dValorTotal + tt-devolucao.val-devolucao.
        
            IF LAST-OF(tt-devolucao.dat-emiss-ori) THEN DO:
                ASSIGN lErro = NO.

                RUN pi-cria-tit-acr(INPUT tt-devolucao.cod-estab-ori,
                                    INPUT tt-devolucao.dat-emiss-ori,
                                    INPUT tt-devolucao.dat-trans,
                                    INPUT tt-devolucao.cod-prefixo,
                                    INPUT tt-devolucao.cod-emitente,
                                    INPUT tt-devolucao.serie-ori,
                                    INPUT tt-devolucao.cod-portador,
                                    INPUT dValorTotal,
                                    INPUT "Dinheiro",
                                    INPUT NO,
                                    INPUT tt-devolucao.dat-emiss-ori,
                                    OUTPUT lErro).

                ASSIGN dValorTotal = 0.

                IF lErro = YES THEN
                    UNDO bloco_trans, LEAVE bloco_trans.
            END.
        END. /* FOR EACH tt-devolucao */
        /* FIM    -  Processa  Devolu‡Æo com Estabelecimento da Devolu‡Æo Diferente da Origem */

    END. /* DO TRANSACTION ON ERROR UNDO */

END PROCEDURE. /* pi-gera-titulo-dinheiro */


PROCEDURE pi-gera-titulo-cartao:
    DEFINE VARIABLE dValorTotal LIKE cst_fat_devol.vl_devolucao  NO-UNDO.

    /*Transa‡Æo, pois, implanta tudo ou nada*/
    bloco_trans:
    DO TRANSACTION ON ERROR UNDO:

        /* INICIO -  Processa  Devolu‡Æo com Estabelecimento da Devolu‡Æo Igual da Origem */
        FOR EACH tt-devolucao
           WHERE tt-devolucao.l-estab-dif = NO
        BREAK BY tt-devolucao.cod-estab
              BY tt-devolucao.cod-portador
              BY tt-devolucao.serie-docto
              BY tt-devolucao.dat-emissao
              BY tt-devolucao.dat-trans
              :

            IF FIRST-OF(tt-devolucao.dat-trans) THEN DO:
                ASSIGN dValorTotal = 0.
                EMPTY TEMP-TABLE tt-devolucao-aux.
            END.

            CREATE tt-devolucao-aux.
            BUFFER-COPY tt-devolucao TO tt-devolucao-aux.
        
            ASSIGN dValorTotal = dValorTotal + tt-devolucao.val-devolucao.
        
            IF LAST-OF(tt-devolucao.dat-trans) THEN DO:
                ASSIGN lErro = NO.

                RUN pi-cria-tit-acr(INPUT tt-devolucao.cod-estab,
                                    INPUT tt-devolucao.dat-emissao,
                                    INPUT tt-devolucao.dat-trans,
                                    INPUT tt-devolucao.cod-prefixo,
                                    INPUT tt-devolucao.cod-emitente,
                                    INPUT tt-devolucao.serie-docto,
                                    INPUT tt-devolucao.cod-portador,
                                    INPUT dValorTotal,
                                    INPUT "Cartao",
                                    INPUT tt-devolucao.l-dat-emis,
                                    INPUT tt-devolucao.dat-emiss-ori,
                                    OUTPUT lErro).

                ASSIGN dValorTotal = 0.

                IF lErro = YES THEN
                    UNDO bloco_trans, LEAVE bloco_trans.
            END.
        END. /* FOR EACH tt-devolucao */
        /* FIM    -  Processa  Devolu‡Æo com Estabelecimento da Devolu‡Æo Igual da Origem */

        /* INICIO -  Processa  Devolu‡Æo com Estabelecimento da Devolu‡Æo Diferente da Origem */
        FOR EACH tt-devolucao
           WHERE tt-devolucao.l-estab-dif = YES
        BREAK BY tt-devolucao.cod-estab-ori
              BY tt-devolucao.cod-portador
              BY tt-devolucao.serie-ori    
              BY tt-devolucao.dat-emiss-ori:

            IF FIRST-OF(tt-devolucao.dat-emiss-ori) THEN DO:
                ASSIGN dValorTotal = 0.
                EMPTY TEMP-TABLE tt-devolucao-aux.
            END.

            CREATE tt-devolucao-aux.
            BUFFER-COPY tt-devolucao TO tt-devolucao-aux.
        
            ASSIGN dValorTotal = dValorTotal + tt-devolucao.val-devolucao.
        
            IF LAST-OF(tt-devolucao.dat-emiss-ori) THEN DO:
                ASSIGN lErro = NO.

                RUN pi-cria-tit-acr(INPUT tt-devolucao.cod-estab-ori,
                                    INPUT tt-devolucao.dat-emiss-ori,
                                    INPUT tt-devolucao.dat-trans,
                                    INPUT tt-devolucao.cod-prefixo,
                                    INPUT tt-devolucao.cod-emitente,
                                    INPUT tt-devolucao.serie-ori,
                                    INPUT tt-devolucao.cod-portador,
                                    INPUT dValorTotal,
                                    INPUT "Cartao",
                                    INPUT tt-devolucao.l-dat-emis,
                                    INPUT tt-devolucao.dat-emiss-ori,
                                    OUTPUT lErro).

                ASSIGN dValorTotal = 0.

                IF lErro = YES THEN
                    UNDO bloco_trans, LEAVE bloco_trans.
            END.
        END. /* FOR EACH tt-devolucao */
        /* FIM    -  Processa  Devolu‡Æo com Estabelecimento da Devolu‡Æo Diferente da Origem */

    END. /* DO TRANSACTION ON ERROR UNDO */

END PROCEDURE. /* pi-gera-titulo-cartao */

PROCEDURE pi-gera-titulo-convenio:
    
/*     /*Transa‡Æo, pois, implanta tudo ou nada*/ */
/*     bloco_trans:                               */
/*     DO TRANSACTION ON ERROR UNDO:              */

        FOR EACH tt-devolucao-convenio
        BREAK BY tt-devolucao-convenio.cod-estab:

            EMPTY TEMP-TABLE tt-devolucao-convenio-aux.
            CREATE tt-devolucao-convenio-aux.
            BUFFER-COPY tt-devolucao-convenio TO tt-devolucao-convenio-aux.

            RUN pi-cria-tit-acr-convenio(INPUT tt-devolucao-convenio.cod-estab,
                                         INPUT tt-devolucao-convenio.dat-emissao,
                                         INPUT tt-devolucao-convenio.dat-trans,
                                         INPUT tt-devolucao-convenio.nro-docto,
                                         INPUT tt-devolucao-convenio.cod-emitente,
                                         INPUT tt-devolucao-convenio.serie-docto,
                                         INPUT tt-devolucao-convenio.serie-devol,
                                         INPUT tt-devolucao-convenio.nota-devol,
                                         INPUT tt-devolucao-convenio.nat-operacao,
                                         INPUT tt-devolucao-convenio.val-devolucao,
                                         INPUT "Convˆnio":U,
                                         OUTPUT lErro).

            IF lErro = YES THEN
                NEXT.
/*                 UNDO bloco_trans, LEAVE bloco_trans. */

        END. /* FOR EACH tt-devolucao */
/*      END. /* DO TRANSACTION ON ERROR UNDO */ */

END PROCEDURE. /* pi-gera-titulo-convenio */

PROCEDURE pi-cria-tit-acr-convenio:
    DEFINE INPUT  PARAMETER c-cod-estab    LIKE c-estab-ems-5.
    DEFINE INPUT  PARAMETER d-dat-emissao  LIKE docum-est.dt-emis.
    DEFINE INPUT  PARAMETER d-dat-trans    LIKE docum-est.dt-trans.
    DEFINE INPUT  PARAMETER c-nro-docto    LIKE docum-est.nro-docto.
    DEFINE INPUT  PARAMETER c-cod-emitente LIKE emitente.cod-emitente.
    DEFINE INPUT  PARAMETER c-serie-docto  LIKE docum-est.serie-docto.
    DEFINE INPUT  PARAMETER c-serie-devol  LIKE nota-fiscal.serie.
    DEFINE INPUT  PARAMETER c-nota-devol   LIKE nota-fiscal.nr-nota-fis.
    DEFINE INPUT  PARAMETER nat-operacao   LIKE nota-fiscal.nat-operacao.
    DEFINE INPUT  PARAMETER d-valor-tit    LIKE tit_acr.val_sdo_tit_acr.
    DEFINE INPUT  PARAMETER c-tipo         AS CHAR.
    DEFINE OUTPUT PARAMETER l-erro         AS LOG INITIAL NO.  

    DEFINE BUFFER b_movto_tit_acr  FOR movto_tit_acr.

    DEFINE VARIABLE c_cod_refer    AS CHARACTER                 NO-UNDO.
    DEFINE VARIABLE i-cod-parcela  AS INTEGER                   NO-UNDO.
    DEFINE VARIABLE c-cod-titulo   AS CHARACTER                 NO-UNDO.

    DEFINE VARIABLE v_hdl_programa AS HANDLE      NO-UNDO.

    DEFINE VARIABLE c_cod_table   AS CHARACTER FORMAT "x(8)"   NO-UNDO.
    DEFINE VARIABLE w_estabel     AS CHARACTER FORMAT "x(3)"   NO-UNDO.
    DEFINE VARIABLE c-cod-refer   AS CHARACTER FORMAT "x(10)"  NO-UNDO.

    DEFINE VARIABLE c-cod-esp      AS CHARACTER                 NO-UNDO.
    DEFINE VARIABLE c-estab        LIKE tit_acr.cod_estab       NO-UNDO.    
    DEFINE VARIABLE c-cod-tit-acr  LIKE tit_acr.cod_tit_acr     NO-UNDO.
    DEFINE VARIABLE d-dt-transacao LIKE docum-est.dt-trans      NO-UNDO.

    DEFINE VARIABLE i              AS INTEGER     NO-UNDO.
    DEFINE BUFFER bf_tit_acr       FOR tit_acr.

    EMPTY TEMP-TABLE tt_integr_acr_item_lote_impl_8 NO-ERROR.
    EMPTY TEMP-TABLE tt_integr_acr_repres_comis_2   NO-ERROR.
    EMPTY TEMP-TABLE tt_integr_acr_aprop_ctbl_pend  NO-ERROR.
    EMPTY TEMP-TABLE tt_log_erros_atualiz           NO-ERROR.
    EMPTY TEMP-TABLE tt_integr_acr_lote_impl        NO-ERROR.
    EMPTY TEMP-TABLE tt_integr_acr_item_lote_impl_9 NO-ERROR.
    EMPTY TEMP-TABLE tt_integr_acr_repres_comis_2   NO-ERROR.
    EMPTY TEMP-TABLE tt_integr_acr_item_lote_impl_9 NO-ERROR.
    EMPTY TEMP-TABLE tt_integr_acr_aprop_relacto_2  NO-ERROR.
    EMPTY TEMP-TABLE tt_integr_acr_relacto_pend_aux NO-ERROR.
    EMPTY TEMP-TABLE tt_integr_acr_aprop_relacto_2  NO-ERROR.
    EMPTY TEMP-TABLE tt_integr_acr_aprop_relacto    NO-ERROR.
    EMPTY TEMP-TABLE tt_integr_acr_aprop_relacto_2b NO-ERROR.

    DEFINE BUFFER b_tit_acr FOR tit_acr.

    
    /*Retorna Matriz Tradu‡Æo Organizacional*/
    RUN prgint/ufn/ufn908za.py (INPUT "1":u,
                                INPUT "15":U,
                                OUTPUT v_cod_matriz_trad_org_ext).
    /*Tradu‡Æo Estabelecimento*/
    RUN pi-traduz-estab(INPUT v_cod_matriz_trad_org_ext,
                        INPUT STRING(c-cod-estab), /*Estabelecimento EMS 2*/
                        OUTPUT c-estab-ems-5,
                        OUTPUT c-erro).
    /*Tradu‡Æo Empresa*/
    RUN pi-traduz-empresa(INPUT v_cod_matriz_trad_org_ext,
                          INPUT v_cdn_empres_usuar, /*Empresa EMS 2*/
                          OUTPUT c-empresa-ems-5,
                          OUTPUT c-erro).

    ASSIGN c_cod_refer = "".
    RUN pi_retorna_sugestao_referencia (INPUT  "AE",
                                        INPUT  TODAY,
                                        OUTPUT c_cod_refer,
                                        INPUT  "tit_acr",
                                        INPUT  STRING(c-cod-estab)).

    /* Cria‡Æo do lote cont bil */
    CREATE tt_integr_acr_lote_impl. 
    ASSIGN tt_integr_acr_lote_impl.tta_cod_empresa        = c-empresa-ems-5 /*Obrigat½rio*/
           tt_integr_acr_lote_impl.ttv_cod_empresa_ext    = string(v_cdn_empres_usuar) /*Obrigat½rio*/
           tt_integr_acr_lote_impl.tta_cod_estab          = c-estab-ems-5       /*Obrigat½rio*/
           tt_integr_acr_lote_impl.tta_cod_estab_ext      = STRING(c-cod-estab) /*Obrigat½rio*/ 
           tt_integr_acr_lote_impl.tta_dat_transacao      = IF d-dat-trans >= 11/01/2016 THEN d-dat-trans ELSE 11/01/2016
           tt_integr_acr_lote_impl.tta_ind_orig_tit_acr   = "2"
           tt_integr_acr_lote_impl.tta_ind_tip_cobr_acr   = "Normal"
           tt_integr_acr_lote_impl.tta_log_liquidac_autom = NO
           tt_integr_acr_lote_impl.ttv_log_lote_impl_ok   = YES
           tt_integr_acr_lote_impl.tta_cod_refer          = c_cod_refer.
    
    ASSIGN c-cod-titulo = c-nota-devol.

    FIND LAST tit_acr
        WHERE tit_acr.cod_estab       = c-cod-estab
          AND tit_acr.cod_espec_docto = "AE"
          AND tit_acr.cod_ser_docto   = c-serie-devol
          AND tit_acr.cod_tit_acr     = c-cod-titulo  NO-LOCK NO-ERROR.
    IF AVAIL tit_acr THEN DO:
        ASSIGN i-cod-parcela = INT(tit_acr.cod_parcela) + 1 NO-ERROR.

        /* INICIO - L¢gica para nÆo dar erro quando achar uma parcela que contenha letras */
        IF i-cod-parcela = 0 THEN DO:

            DO i = 1 TO 99:
                FIND FIRST bf_tit_acr
                     WHERE bf_tit_acr.cod_estab        = tit_acr.cod_estab 
                       AND bf_tit_acr.cod_espec_docto  = tit_acr.cod_espec_docto
                       AND bf_tit_acr.cod_ser_docto    = tit_acr.cod_ser_docto
                       AND bf_tit_acr.cod_tit_acr      = tit_acr.cod_tit_acr
                       AND bf_tit_acr.cod_parcela      = STRING(i,"99") NO-LOCK NO-ERROR.
                IF AVAIL bf_tit_acr THEN DO:
                    NEXT.
                END.
                ELSE DO:
                    ASSIGN i-cod-parcela = i.
                    LEAVE.
                END.
            END.
        END.
        /* FIM    - L¢gica para nÆo dar erro quando achar uma parcela que contenha letras */

    END.
    ELSE DO:
        ASSIGN i-cod-parcela = 1.
    END.

    CREATE tt_integr_acr_item_lote_impl_9.
    ASSIGN tt_integr_acr_item_lote_impl_9.ttv_rec_lote_impl_tit_acr      = RECID(tt_integr_acr_lote_impl)
           tt_integr_acr_item_lote_impl_9.ttv_rec_item_lote_impl_tit_acr = RECID(tt_integr_acr_item_lote_impl_9)
           tt_integr_acr_item_lote_impl_9.tta_cod_refer                  = tt_integr_acr_lote_impl.tta_cod_refer
           tt_integr_acr_item_lote_impl_9.tta_cdn_cliente                = c-cod-emitente /*Obrigat½rio*/
           tt_integr_acr_item_lote_impl_9.tta_num_seq_refer              = 1
           tt_integr_acr_item_lote_impl_9.tta_cod_espec_docto            = "AE" /*Obrigat½rio*/ /*Duplicata*/  /*"AN"*/
           tt_integr_acr_item_lote_impl_9.tta_ind_tip_espec_docto        = "3":U /*Obrigat½rio*/ /*"3"*/  /*Antecipa»’o*/
           tt_integr_acr_item_lote_impl_9.tta_cod_ser_docto              = c-serie-devol
           tt_integr_acr_item_lote_impl_9.tta_cod_portador               = ""
           tt_integr_acr_item_lote_impl_9.tta_cod_portad_ext             = "" /*Obrigat½rio*/ 
           tt_integr_acr_item_lote_impl_9.tta_cod_modalid_ext            = "" /*string(nota-fiscal.modalidade)   /*Obrigat½rio*/ */
           tt_integr_acr_item_lote_impl_9.tta_cod_tit_acr                = c-cod-titulo   /*Obrigat½rio*/ 
           tt_integr_acr_item_lote_impl_9.tta_cod_parcela                = STRING(i-cod-parcela,"99") /*Obrigat½rio*/
           tt_integr_acr_item_lote_impl_9.tta_cod_indic_econ             = ""
           tt_integr_acr_item_lote_impl_9.tta_cod_cart_bcia              = "" /*"2"*/ /*Verificar este campo*/
           tt_integr_acr_item_lote_impl_9.tta_cod_finalid_econ_ext       = "0"
           tt_integr_acr_item_lote_impl_9.tta_ind_sit_tit_acr            = "Normal" /*Obrigat½rio*/
           tt_integr_acr_item_lote_impl_9.tta_cdn_repres                 = 0        
           tt_integr_acr_item_lote_impl_9.tta_dat_vencto_tit_acr         = IF d-dat-trans >= 11/01/2016 THEN d-dat-trans ELSE 11/01/2016 /*Obrigat½rio*/ /*tt-fat-duplic.dt-venciment*/
           tt_integr_acr_item_lote_impl_9.tta_dat_prev_liquidac          = IF d-dat-trans >= 11/01/2016 THEN d-dat-trans ELSE 11/01/2016 /*Obrigat½rio*/ /*tt-fat-duplic.dt-venciment*/
           tt_integr_acr_item_lote_impl_9.tta_dat_emis_docto             = IF d-dat-trans >= 11/01/2016 THEN d-dat-trans ELSE 11/01/2016 /*tt-nota-fiscal.dt-emis-nota*/
           tt_integr_acr_item_lote_impl_9.tta_des_text_histor            = "T¡tulo do agrupamento das  devolu‡äes de cupons fiscais do dia " + STRING(d-dat-emissao,"99/99/9999")
           tt_integr_acr_item_lote_impl_9.tta_cod_cond_pagto             = ""
           tt_integr_acr_item_lote_impl_9.tta_val_cotac_indic_econ       = 1
           tt_integr_acr_item_lote_impl_9.tta_ind_sit_bcia_tit_acr       = "1"
           tt_integr_acr_item_lote_impl_9.tta_ind_ender_cobr             = "1"
           tt_integr_acr_item_lote_impl_9.tta_log_liquidac_autom         = NO
           tt_integr_acr_item_lote_impl_9.ttv_cod_nota_fisc_faturam      = ""
           tt_integr_acr_item_lote_impl_9.tta_val_tit_acr                = d-valor-tit /*Obrigat½rio*/
           tt_integr_acr_item_lote_impl_9.tta_val_liq_tit_acr            = d-valor-tit /*Obrigat½rio*/
           tt_integr_acr_item_lote_impl_9.tta_des_obs_cobr               = "".

    RUN pi-acompanhar IN h-acomp (INPUT "Est/Esp/Ser/Tit./Par: ":U + STRING(tt_integr_acr_lote_impl.tta_cod_estab) + "/" +
                                                                     STRING(tt_integr_acr_item_lote_impl_9.tta_cod_espec_docto) + "/" + 
                                                                     STRING(tt_integr_acr_item_lote_impl_9.tta_cod_ser_docto)   + "/" + 
                                                                     STRING(tt_integr_acr_item_lote_impl_9.tta_cod_tit_acr) + "/" +
                                                                     STRING(tt_integr_acr_item_lote_impl_9.tta_cod_parcela)).

    CREATE tt_integr_acr_aprop_ctbl_pend.
    ASSIGN tt_integr_acr_aprop_ctbl_pend.ttv_rec_item_lote_impl_tit_acr  = tt_integr_acr_item_lote_impl_9.ttv_rec_item_lote_impl_tit_acr
           tt_integr_acr_aprop_ctbl_pend.tta_cod_plano_cta_ctbl          = "PADRAO"     /*Obrigat½rio*/  /*sch-param-vpi.cod-plano-cta-ctbl*/    /*'schulz'*/
           tt_integr_acr_aprop_ctbl_pend.tta_cod_cta_ctbl                = "32101020" /*Obrigat½rio*/
           tt_integr_acr_aprop_ctbl_pend.tta_cod_cta_ctbl_ext            = "" /*sch-param-vpi.cod-cta-ctbl*/          /*"1121995"*/
           tt_integr_acr_aprop_ctbl_pend.tta_cod_sub_cta_ctbl_ext        = "" /*sch-param-vpi.cod-ccusto*/ 
           tt_integr_acr_aprop_ctbl_pend.tta_cod_unid_negoc              = "000" /*Obrigat½rio*/ /*c-unid-negoc*/
           tt_integr_acr_aprop_ctbl_pend.tta_cod_unid_negoc_ext          = "" /*c-unid-negoc*/
           tt_integr_acr_aprop_ctbl_pend.tta_cod_plano_ccusto            = "" /* "PADRAO" Obrigat½rio*/ /*sch-param-vpi.cod-plano-ccusto*/      /*''*/ 
           tt_integr_acr_aprop_ctbl_pend.tta_cod_ccusto                  = "" /*"00697" Obrigat½rio*/ /*sch-param-vpi.cod-ccusto*/   
           tt_integr_acr_aprop_ctbl_pend.tta_cod_ccusto_ext              = ""                                  /*''*/
           tt_integr_acr_aprop_ctbl_pend.tta_cod_tip_fluxo_financ        = "105" /*Obrigat½rio*/
           tt_integr_acr_aprop_ctbl_pend.tta_cod_fluxo_financ_ext        = ""
           tt_integr_acr_aprop_ctbl_pend.tta_log_impto_val_agreg         = NO
           tt_integr_acr_aprop_ctbl_pend.tta_val_aprop_ctbl              = tt_integr_acr_item_lote_impl_9.tta_val_tit_acr. /*Obrigat½rio*/

    FIND FIRST conta-ft
         WHERE conta-ft.cod-estabel     = ?    
           AND conta-ft.cod-gr-cli      = ?   
           AND conta-ft.cod-canal-venda = ?  
           AND conta-ft.fm-com          = "" 
           AND conta-ft.nat-operacao    = ?  
           AND conta-ft.serie           = ?  
           AND conta-ft.cod-depos       = "" NO-ERROR.
    IF AVAIL conta-ft THEN DO:
        ASSIGN tt_integr_acr_aprop_ctbl_pend.tta_cod_cta_ctbl  = conta-ft.cod-cta-devol-recta. /*Obrigat½rio*/
    END.

    RUN prgfin/acr/acr900zi.py persistent set v_hdl_api_integr_acr.
    RUN pi_main_code_integr_acr_new_12 IN v_hdl_api_integr_acr (INPUT 11,
                                                                INPUT v_cod_matriz_trad_org_ext,
                                                                INPUT YES,
                                                                INPUT YES,
                                                                INPUT TABLE tt_integr_acr_repres_comis_2,
                                                                INPUT-OUTPUT TABLE tt_integr_acr_item_lote_impl_9,
                                                                INPUT TABLE tt_integr_acr_aprop_relacto_2,
                                                                INPUT-OUTPUT TABLE tt_params_generic_api,
                                                                INPUT TABLE tt_integr_acr_relacto_pend_aux).

    DELETE PROCEDURE v_hdl_api_integr_acr.

    /*Tratamento de erros*/
    IF CAN-FIND(FIRST tt_log_erros_atualiz) THEN DO:
        FIND FIRST tt_integr_acr_item_lote_impl_9 NO-LOCK NO-ERROR.
        IF AVAIL tt_integr_acr_item_lote_impl_9 THEN DO:
            RUN pi-cria-tt-erro(INPUT tt_integr_acr_item_lote_impl_9.tta_num_seq_refer,
                                INPUT 17006, 
                                INPUT "Houve erro na cria‡Æo do titulo abaixo, favor verificar.",
                                INPUT "Estab/Especie/Serie/Titulo/Parcela/Cliente/Portador : " +  STRING(c-cod-estab) + "/" +
                                                                                                  STRING(tt_integr_acr_item_lote_impl_9.tta_cod_espec_docto) + "/" +
                                                                                                  STRING(tt_integr_acr_item_lote_impl_9.tta_cod_ser_docto) + "/" +
                                                                                                  STRING(tt_integr_acr_item_lote_impl_9.tta_cod_tit_acr) + "/" +
                                                                                                  STRING(tt_integr_acr_item_lote_impl_9.tta_cod_parcela) + "/" +
                                                                                                  STRING(tt_integr_acr_item_lote_impl_9.tta_cdn_cliente) + "/"  +
                                                                                                  STRING(tt_integr_acr_item_lote_impl_9.tta_cod_portad_ext)   ). 
        END.

        FOR EACH tt_log_erros_atualiz:
            RUN pi-cria-tt-erro(INPUT tt_log_erros_atualiz.tta_num_seq_refer,
                                INPUT tt_log_erros_atualiz.ttv_num_mensagem, 
                                INPUT tt_log_erros_atualiz.ttv_des_msg_erro,
                                INPUT tt_log_erros_atualiz.ttv_des_msg_ajuda).
        END.
        ASSIGN l-erro = YES.
        RETURN "NOK".
    END.
    ELSE DO:
        ASSIGN iNumSeq = 0.
        FOR EACH tt_integr_acr_item_lote_impl_9 NO-LOCK:
            CREATE tt-tit-criados.
            ASSIGN tt-tit-criados.cod_estab          = c-cod-estab
                   tt-tit-criados.cod_espec_docto    = tt_integr_acr_item_lote_impl_9.tta_cod_espec_docto
                   tt-tit-criados.cod_ser_docto      = tt_integr_acr_item_lote_impl_9.tta_cod_ser_docto
                   tt-tit-criados.cod_tit_acr        = tt_integr_acr_item_lote_impl_9.tta_cod_tit_acr
                   tt-tit-criados.cod_parcela        = tt_integr_acr_item_lote_impl_9.tta_cod_parcela              
                   tt-tit-criados.cdn_cliente        = tt_integr_acr_item_lote_impl_9.tta_cdn_cliente
                   tt-tit-criados.cod_portador       = tt_integr_acr_item_lote_impl_9.tta_cod_portad_ext
                   tt-tit-criados.val_origin_tit_acr = tt_integr_acr_item_lote_impl_9.tta_val_tit_acr
                   tt-tit-criados.dat_transacao      = tt_integr_acr_item_lote_impl_9.tta_dat_emis_docto    
                   tt-tit-criados.dat_emis_docto     = tt_integr_acr_item_lote_impl_9.tta_dat_emis_docto    
                   tt-tit-criados.dat_vencto_tit_acr = tt_integr_acr_item_lote_impl_9.tta_dat_vencto_tit_acr
                   tt-tit-criados.situacao           = "T¡tulo Gerado".

            FIND FIRST tit_acr NO-LOCK
                 WHERE tit_acr.cod_estab       = c-cod-estab                          
                   AND tit_acr.cod_espec_docto = tt_integr_acr_item_lote_impl_9.tta_cod_espec_docto
                   AND tit_acr.cod_ser_docto   = tt_integr_acr_item_lote_impl_9.tta_cod_ser_docto  
                   AND tit_acr.cod_tit_acr     = tt_integr_acr_item_lote_impl_9.tta_cod_tit_acr    
                   AND tit_acr.cod_parcela     = tt_integr_acr_item_lote_impl_9.tta_cod_parcela     NO-ERROR.
            IF AVAIL tit_acr THEN DO:

                FOR EACH tt-devolucao-convenio-aux: 
                    ASSIGN iNumSeq = iNumSeq + 1.


                    FOR FIRST cst_fat_devol
                        WHERE ROWID(cst_fat_devol) = tt-devolucao-convenio-aux.r-fat-devol EXCLUSIVE-LOCK,
                        FIRST docum-est
                        WHERE docum-est.cod-estabel  = cst_fat_devol.cod_estabel
                          AND docum-est.serie-docto  = cst_fat_devol.serie_docto
                          AND docum-est.nro-docto    = cst_fat_devol.nro_docto
                          AND docum-est.nat-operacao = cst_fat_devol.nat_operacao
/*                           AND docum-est.cod-emitente = cst_fat_devol.cod-emitente */
                        EXCLUSIVE-LOCK:

                        ASSIGN cst_fat_devol.flag_atualiz = YES
                               docum-est.cr-atual         = YES.
                        
/*                         CREATE tit_acr_cartao.                                                                   */
/*                         ASSIGN tit_acr_cartao.num_id_tit_acr         = tit_acr.num_id_tit_acr                    */
/*                                tit_acr_cartao.num_seq                = iNumSeq.                                  */
/*                         ASSIGN tit_acr_cartao.cod_admdra             = ""                                        */
/*                                tit_acr_cartao.cod_autoriz_cartao_cr  = ""                                        */
/*                                tit_acr_cartao.cod_comprov_vda        = ""                                        */
/*                                tit_acr_cartao.cod_empresa            = tit_acr.cod_empresa                       */
/*                                tit_acr_cartao.cod_estab              = tit_acr.cod_estab                         */
/*                                tit_acr_cartao.cod_parc               = tit_acr.cod_parcela                       */
/*                                tit_acr_cartao.dat_atualiz            = TODAY                                     */
/*                                tit_acr_cartao.dat_cred_cartao_cr     = ?                                         */
/*                                tit_acr_cartao.dat_vda_cartao_cr      = tit_acr.dat_emis_docto                    */
/*                                tit_acr_cartao.hra_atualiz            = REPLACE(STRING(TIME, "HH:MM:SS"), ":","") */
/*                                tit_acr_cartao.val_comprov_vda        = cst_fat_devol.vl-devolucao                */
/*                                tit_acr_cartao.val_des_admdra         = 0                                         */
/*                                tit_acr_cartao.num_cupom              = docum-est.nro-docto                       */
/*                                tit_acr_cartao.cartao-manual          = NO.                                       */
/*                             .                                                                                    */
                            
                            FIND FIRST nota_devol_tit_acr NO-LOCK
                                 WHERE nota_devol_tit_acr.cod_estab          = tit_acr.cod_estab
                                   AND nota_devol_tit_acr.cod_espec_docto    = tit_acr.cod_espec_docto
                                   AND nota_devol_tit_acr.cod_ser_docto      = tit_acr.cod_ser_docto
                                   AND nota_devol_tit_acr.cod_tit_acr        = tit_acr.cod_tit_acr
                                   AND nota_devol_tit_acr.cod_parcela        = tit_acr.cod_parcela NO-ERROR.
                            IF NOT AVAIL nota_devol_tit_acr THEN DO:
                                CREATE nota_devol_tit_acr.
                                ASSIGN nota_devol_tit_acr.cod_estab          = tit_acr.cod_estab
                                       nota_devol_tit_acr.cod_espec_docto    = tit_acr.cod_espec_docto
                                       nota_devol_tit_acr.cod_ser_docto      = tit_acr.cod_ser_docto
                                       nota_devol_tit_acr.cod_tit_acr        = tit_acr.cod_tit_acr
                                       nota_devol_tit_acr.cod_parcela        = tit_acr.cod_parcela.
                           
                                ASSIGN nota_devol_tit_acr.cdn_cliente            = docum-est.cod-emitente
                                       nota_devol_tit_acr.cod_natur_operac_devol = cst_fat_devol.nat_operacao
                                       nota_devol_tit_acr.cod_nota_devol         = docum-est.nro-docto
                                       nota_devol_tit_acr.cod_ser_nota_devol     = docum-est.serie-docto
                                       nota_devol_tit_acr.dat_emis_docto         = docum-est.dt-emis.
                            END.

                            ASSIGN c-cod-esp     = ""
                                   c-estab       = ""
                                   c-cod-tit-acr = "".

                            ASSIGN c-cod-esp = cst_fat_devol.cod_esp .

                            /* INICIO - Regra devido a Estabelecimento Devolu‡Æo Diferente do Estabelecimento de Origem*/
                            IF tt-devolucao-convenio-aux.l-estab-dif = YES THEN DO:
                                ASSIGN c-estab       = cst_fat_devol.cod_estab_comp .
                                       c-cod-tit-acr = cst_fat_devol.nro_comp.
                            END.
                            ELSE DO:
                                ASSIGN c-estab       = tit_acr.cod_estab 
                                       c-cod-tit-acr = tit_acr.cod_tit_acr.
                            END.
                            /* INICIO - Regra devido a Estabelecimento Devolu‡Æo Diferente do Estabelecimento de Origem*/


                            /* INICIO - Devolu‡Æo - Nova - Realiza‡Æo da Baixa da Antecipa‡Æo Criada Anteriormente */
                            FIND FIRST b_tit_acr NO-LOCK
                                 WHERE b_tit_acr.cod_estab        = c-estab
                                   AND b_tit_acr.cod_espec_docto  = c-cod-esp                         
                                   AND b_tit_acr.cod_tit_acr      = c-cod-tit-acr NO-ERROR.
                            IF NOT AVAIL b_tit_acr THEN DO:                
                                 RUN pi-cria-tt-erro(INPUT 1,
                                                     INPUT 17006,
                                                     INPUT "Estab/Especie/Titulo Nr.: " + string(c-estab) + "/" + STRING(c-cod-esp) + "/" + string(c-cod-tit-acr) + " , nÆo foi encontrado.",
                                                     INPUT "Estab/Especie/Titulo Nr.: " + string(c-estab) + "/" + STRING(c-cod-esp) + "/" + string(c-cod-tit-acr) + " , nÆo foi encontrado.").                
                                 NEXT.
                            END. 

                            IF AVAIL b_tit_acr AND log_sdo_tit_acr = NO THEN DO:
                                FIND FIRST b_tit_acr NO-LOCK
                                     WHERE b_tit_acr.cod_estab        = c-estab                  
                                       AND b_tit_acr.cod_espec_docto  = c-cod-esp    
                                       AND b_tit_acr.cod_tit_acr      = c-cod-tit-acr  
                                       AND log_sdo_tit_acr          = YES    NO-ERROR.
                                IF NOT AVAIL b_tit_acr THEN DO:                
                                     RUN pi-cria-tt-erro(INPUT 1,
                                                         INPUT 17006,
                                                         INPUT "Estab/Especie/Titulo Nr.: " + string(c-estab) + "/" + STRING(c-cod-esp) + "/" + string(c-cod-tit-acr) + " , nÆo foi encontrado com saldo pra realizar a Liquida‡Æo.",
                                                         INPUT "Estab/Especie/Titulo Nr.: " + string(c-estab) + "/" + STRING(c-cod-esp) + "/" + string(c-cod-tit-acr) + " , nÆo foi encontrado com saldo pra realizar a Liquida‡Æo.").                
                                     NEXT.                   
                                END. 
                            END.

                            EMPTY temp-table tt_integr_acr_liquidac_lote    no-error.
                            EMPTY temp-table tt_integr_acr_liq_item_lote_3  no-error.
                            EMPTY temp-table tt_integr_acr_abat_antecip     no-error.
                            EMPTY temp-table tt_integr_acr_abat_prev        no-error.
                            EMPTY temp-table tt_integr_acr_cheq             no-error.
                            EMPTY temp-table tt_integr_acr_liquidac_impto_2 no-error.
                            EMPTY temp-table tt_integr_acr_rel_pend_cheq    no-error.
                            EMPTY temp-table tt_integr_acr_liq_aprop_ctbl   no-error.
                            EMPTY temp-table tt_integr_acr_liq_desp_rec     no-error.
                            EMPTY temp-table tt_integr_acr_aprop_liq_antec  no-error.
                            EMPTY temp-table tt_log_erros_import_liquidac   no-error.

                            assign c_cod_table = "lote_liquidac_acr"
                                   w_estabel   = tit_acr.cod_estab. 

                            ASSIGN c-cod-refer = "".

                            run pi_retorna_sugestao_referencia (INPUT  "LD",
                                                                INPUT  TODAY,
                                                                OUTPUT c-cod-refer,
                                                                INPUT  c_cod_table,
                                                                INPUT  w_estabel).

                            /* INICIO - Verifica‡Æo da Data de Transa‡Æo, para sempre pegar £ltima */
                            ASSIGN d-dt-transacao = ?.
                            FIND LAST b_movto_tit_acr NO-LOCK
                                WHERE b_movto_tit_acr.cod_estab             = b_tit_acr.cod_estab
                                  AND b_movto_tit_acr.num_id_tit_acr        = b_tit_acr.num_id_tit_acr
                                  AND b_movto_tit_acr.num_id_movto_tit_acr >  0
                                  AND b_movto_tit_acr.dat_transacao         > tit_acr.dat_transacao
                                  AND b_movto_tit_acr.log_ctbz_aprop_ctbl   = yes
                                  AND b_movto_tit_acr.log_movto_estordo     = no 
                                  AND NOT b_movto_tit_acr.ind_trans_acr begins "Estorno" /*l_estorno*/  NO-ERROR.
                            IF NOT AVAIL b_movto_tit_acr THEN DO:
                                ASSIGN d-dt-transacao = tit_acr.dat_transacao.
                            END.
                            ELSE DO:
                                ASSIGN d-dt-transacao = b_movto_tit_acr.dat_transacao.
                            END.
                            RELEASE b_movto_tit_acr.
                            /* FIM    - Verifica‡Æo da Data de Transa‡Æo, para sempre pegar £ltima */


                            create tt_integr_acr_liquidac_lote.
                            assign tt_integr_acr_liquidac_lote.tta_cod_empresa                 = b_tit_acr.cod_empresa
                                   tt_integr_acr_liquidac_lote.tta_cod_estab_refer             = b_tit_acr.cod_estab
                                   tt_integr_acr_liquidac_lote.tta_cod_usuario                 = c-seg-usuario
                                   tt_integr_acr_liquidac_lote.tta_cod_portador                = b_tit_acr.cod_portador
                                   tt_integr_acr_liquidac_lote.tta_cod_cart_bcia               = b_tit_acr.cod_cart_bcia
                                   tt_integr_acr_liquidac_lote.tta_dat_gerac_lote_liquidac     = d-dt-transacao
                                   tt_integr_acr_liquidac_lote.tta_dat_transacao               = d-dt-transacao
                                   tt_integr_acr_liquidac_lote.tta_val_tot_lote_liquidac_infor = 0 
                                   tt_integr_acr_liquidac_lote.tta_val_tot_lote_liquidac_efetd = 0  
                                   tt_integr_acr_liquidac_lote.tta_val_tot_despes_bcia         = 0
                                   tt_integr_acr_liquidac_lote.tta_ind_tip_liquidac_acr        = "lote"
                                   tt_integr_acr_liquidac_lote.tta_ind_sit_lote_liquidac_acr   = "Em digita‡Æo":U
                                   tt_integr_acr_liquidac_lote.tta_nom_arq_movimen_bcia        = ""
                                   tt_integr_acr_liquidac_lote.tta_cdn_cliente                 = b_tit_acr.cdn_cliente
                                   tt_integr_acr_liquidac_lote.tta_log_enctro_cta              = no   
                                   tt_integr_acr_liquidac_lote.ttv_log_atualiz_refer           = YES
                                   tt_integr_acr_liquidac_lote.ttv_log_gera_lote_parcial       = yes 
                                   tt_integr_acr_liquidac_lote.ttv_rec_lote_liquidac_acr       = recid(tt_integr_acr_liquidac_lote)
                                   tt_integr_acr_liquidac_lote.tta_cod_refer                   = c-cod-refer
                                   tt_integr_acr_liquidac_lote.ttv_cod_indic_econ              = "" /*tit_acr.cod_indic_econ*/ . 

                            create tt_integr_acr_liq_item_lote_3.
                            assign tt_integr_acr_liq_item_lote_3.tta_cod_empresa              = b_tit_acr.cod_empresa
                                   tt_integr_acr_liq_item_lote_3.tta_cod_estab                = b_tit_acr.cod_estab
                                   tt_integr_acr_liq_item_lote_3.tta_cod_espec_docto          = b_tit_acr.cod_espec_docto
                                   tt_integr_acr_liq_item_lote_3.tta_cod_ser_docto            = b_tit_acr.cod_ser_docto
                                   tt_integr_acr_liq_item_lote_3.tta_cod_tit_acr              = b_tit_acr.cod_tit_acr
                                   tt_integr_acr_liq_item_lote_3.tta_cod_parcela              = b_tit_acr.cod_parcela
                                   tt_integr_acr_liq_item_lote_3.tta_cdn_cliente              = b_tit_acr.cdn_cliente
                                   tt_integr_acr_liq_item_lote_3.tta_cod_portad_ext           = ""
                                   tt_integr_acr_liq_item_lote_3.tta_cod_modalid_ext          = ""
                                   tt_integr_acr_liq_item_lote_3.tta_cod_portador             = b_tit_acr.cod_portador
                                   tt_integr_acr_liq_item_lote_3.tta_cod_cart_bcia            = b_tit_acr.cod_cart_bcia
                                   tt_integr_acr_liq_item_lote_3.tta_cod_finalid_econ         = "Corrente"
                                   tt_integr_acr_liq_item_lote_3.tta_cod_indic_econ           = b_tit_acr.cod_indic_econ 
                                   tt_integr_acr_liq_item_lote_3.tta_val_tit_acr              = b_tit_acr.val_sdo_tit_acr /* tt-titulo.vl-movto */
                                   tt_integr_acr_liq_item_lote_3.tta_val_liquidac_tit_acr     = cst_fat_devol.vl_devolucao
                                   tt_integr_acr_liq_item_lote_3.tta_dat_cr_liquidac_tit_acr  = d-dt-transacao
                                   tt_integr_acr_liq_item_lote_3.tta_dat_cr_liquidac_calc     = d-dt-transacao
                                   tt_integr_acr_liq_item_lote_3.tta_dat_liquidac_tit_acr     = d-dt-transacao
                                   tt_integr_acr_liq_item_lote_3.tta_cod_autoriz_bco          = ""
                                   tt_integr_acr_liq_item_lote_3.tta_val_abat_tit_acr         = 0
                                   tt_integr_acr_liq_item_lote_3.tta_val_despes_bcia          = 0
                                   tt_integr_acr_liq_item_lote_3.tta_val_multa_tit_acr        = 0
                                   tt_integr_acr_liq_item_lote_3.tta_val_juros                = 0
                                   tt_integr_acr_liq_item_lote_3.tta_val_cm_tit_acr           = 0
                                   tt_integr_acr_liq_item_lote_3.tta_val_liquidac_orig        = 0
                                   tt_integr_acr_liq_item_lote_3.tta_val_desc_tit_acr_orig    = 0  
                                   tt_integr_acr_liq_item_lote_3.tta_val_abat_tit_acr_orig    = 0 
                                   tt_integr_acr_liq_item_lote_3.tta_val_despes_bcia_orig     = 0
                                   tt_integr_acr_liq_item_lote_3.tta_val_multa_tit_acr_origin = 0
                                   tt_integr_acr_liq_item_lote_3.tta_val_juros_tit_acr_orig   = 0
                                   tt_integr_acr_liq_item_lote_3.tta_val_cm_tit_acr_orig      = 0
                                   tt_integr_acr_liq_item_lote_3.tta_val_nota_db_orig         = 0
                                   tt_integr_acr_liq_item_lote_3.tta_log_gera_antecip         = NO
                                   tt_integr_acr_liq_item_lote_3.tta_des_text_histor          = ""
                                   tt_integr_acr_liq_item_lote_3.tta_ind_sit_item_lote_liquidac = ""
                                   tt_integr_acr_liq_item_lote_3.tta_log_gera_avdeb           = NO
                                   tt_integr_acr_liq_item_lote_3.tta_cod_indic_econ_avdeb     = ""
                                   tt_integr_acr_liq_item_lote_3.tta_cod_portad_avdeb         = ""
                                   tt_integr_acr_liq_item_lote_3.tta_cod_cart_bcia_avdeb      = "" 
                                   tt_integr_acr_liq_item_lote_3.tta_dat_vencto_avdeb         = ?
                                   tt_integr_acr_liq_item_lote_3.tta_val_perc_juros_avdeb     = 0
                                   tt_integr_acr_liq_item_lote_3.tta_val_avdeb                = 0
                                   tt_integr_acr_liq_item_lote_3.tta_log_movto_comis_estordo  = no
                                   tt_integr_acr_liq_item_lote_3.tta_ind_tip_item_liquidac_acr = "Pagamento"
                                   tt_integr_acr_liq_item_lote_3.tta_ind_tip_calc_juros       = "Compostos"
                                   tt_integr_acr_liq_item_lote_3.ttv_rec_lote_liquidac_acr    = tt_integr_acr_liquidac_lote.ttv_rec_lote_liquidac_acr
                                   tt_integr_acr_liq_item_lote_3.ttv_rec_item_lote_liquidac_acr = recid(tt_integr_acr_liq_item_lote_3)
                                   tt_integr_acr_liq_item_lote_3.tta_val_cotac_indic_econ = 1.

                            CREATE tt_integr_acr_abat_antecip.
                            ASSIGN tt_integr_acr_abat_antecip.ttv_rec_item_lote_impl_tit_acr = tt_integr_acr_liq_item_lote_3.ttv_rec_item_lote_liquidac_acr
                                   tt_integr_acr_abat_antecip.ttv_rec_abat_antecip_acr       = RECID(tt_integr_acr_abat_antecip)
                                   tt_integr_acr_abat_antecip.tta_cod_estab                  = tit_acr.cod_estab
                                   tt_integr_acr_abat_antecip.tta_cod_estab_ext              = tit_acr.cod_estab
                                   tt_integr_acr_abat_antecip.tta_cod_espec_docto            = tit_acr.cod_espec_docto
                                   tt_integr_acr_abat_antecip.tta_cod_ser_docto              = tit_acr.cod_ser_docto
                                   tt_integr_acr_abat_antecip.tta_cod_tit_acr                = tit_acr.cod_tit_acr
                                   tt_integr_acr_abat_antecip.tta_cod_parcela                = tit_acr.cod_parcela
                                   tt_integr_acr_abat_antecip.tta_val_abtdo_antecip_tit_abat = cst_fat_devol.vl_devolucao.

                            RUN prgfin/acr/acr901zf.py PERSISTENT SET v_hdl_programa.
                            RUN pi_main_code_api_integr_acr_liquidac_5 IN v_hdl_programa (INPUT 1,
                                                                                          INPUT TABLE tt_integr_acr_liquidac_lote,
                                                                                          INPUT TABLE tt_integr_acr_liq_item_lote_3,
                                                                                          INPUT TABLE tt_integr_acr_abat_antecip,
                                                                                          INPUT TABLE tt_integr_acr_abat_prev,
                                                                                          INPUT TABLE tt_integr_acr_cheq,
                                                                                          INPUT TABLE tt_integr_acr_liquidac_impto_2,
                                                                                          INPUT TABLE tt_integr_acr_rel_pend_cheq,
                                                                                          INPUT TABLE tt_integr_acr_liq_aprop_ctbl,
                                                                                          INPUT TABLE tt_integr_acr_liq_desp_rec,
                                                                                          INPUT TABLE tt_integr_acr_aprop_liq_antec,
                                                                                          INPUT "EMS",
                                                                                          OUTPUT TABLE tt_log_erros_import_liquidac,
                                                                                          INPUT TABLE tt_integr_cambio_ems5).
                           DELETE PROCEDURE v_hdl_programa.

                           IF CAN-FIND(FIRST tt_log_erros_import_liquidac) THEN DO:
                               FOR EACH tt_log_erros_import_liquidac NO-LOCK:

                                   FIND FIRST tt_integr_acr_liq_item_lote_3 NO-LOCK NO-ERROR.
                                   IF AVAIL tt_integr_acr_liq_item_lote_3 THEN DO:
                                       RUN pi-cria-tt-erro(INPUT tt_integr_acr_liq_item_lote_3.tta_num_seq_refer,
                                                           INPUT 17006,
                                                           INPUT "Houve erro na vincula‡Æo da AE com o T¡tulo Abaixo, favor verificar.",
                                                           INPUT "Estab/Especie/Serie/Titulo/Parcela/Cliente/Portador : " +  STRING(b_tit_acr.cod_estab)       + "/" +
                                                                                                                             STRING(b_tit_acr.cod_espec_docto) + "/" +
                                                                                                                             STRING(b_tit_acr.cod_ser_docto)   + "/" +
                                                                                                                             STRING(b_tit_acr.cod_tit_acr)     + "/" +
                                                                                                                             STRING(b_tit_acr.cod_parcela)     + "/" +
                                                                                                                             STRING(b_tit_acr.cdn_cliente)     + "/"  +
                                                                                                                             STRING(b_tit_acr.cod_portador)   ).
                                   END.

                                   RUN pi-cria-tt-erro(INPUT  tt_log_erros_import_liquidac.tta_num_seq,
                                                       INPUT  tt_log_erros_import_liquidac.ttv_num_erro_log,    
                                                       INPUT  tt_log_erros_import_liquidac.ttv_des_msg_erro,
                                                       INPUT  tt_log_erros_import_liquidac.ttv_des_msg_erro).
                               END.                     
                               NEXT.
                           END. 
                            /* FIM    - Devolu‡Æo - Nova - Realiza‡Æo da Baixa da Antecipa‡Æo Criada Anteriormente */
                    END.
                END.
                ASSIGN iNumSeq = 0.
            END.    
        END.
    END. /* ELSE Erros Importa‡Æo*/

END PROCEDURE. /* pi-cria-tit-acr-convenio */

PROCEDURE pi-cria-tit-acr:
    DEFINE INPUT  PARAMETER c-cod-estab    LIKE c-estab-ems-5.
    DEFINE INPUT  PARAMETER d-dat-emissao  LIKE docum-est.dt-emis.
    DEFINE INPUT  PARAMETER d-dat-trans    LIKE docum-est.dt-trans.
    DEFINE INPUT  PARAMETER c-prefixo      LIKE portador_agrupador.prefixo.
    DEFINE INPUT  PARAMETER c-cod-emitente LIKE emitente.cod-emitente.
    DEFINE INPUT  PARAMETER c-serie-docto  LIKE docum-est.serie-docto.
    DEFINE INPUT  PARAMETER c-cod-portador LIKE cst_fat_devol.cod_portador.
    DEFINE INPUT  PARAMETER d-valor-tit    LIKE tit_acr.val_sdo_tit_acr.
    DEFINE INPUT  PARAMETER c-tipo         AS CHAR.
    DEFINE INPUT  PARAMETER lDataEmis      AS LOGICAL.
    DEFINE INPUT  PARAMETER dDatEmisOrigem LIKE docum-est.dt-emis.
    DEFINE OUTPUT PARAMETER l-erro         AS LOG INITIAL NO.

    DEFINE BUFFER b_movto_tit_acr  FOR movto_tit_acr.

    DEFINE VARIABLE c_cod_refer    AS CHARACTER                 NO-UNDO.
    DEFINE VARIABLE i-cod-parcela  AS INTEGER                   NO-UNDO.
    DEFINE VARIABLE c-cod-titulo   AS CHARACTER                 NO-UNDO.

    DEFINE VARIABLE v_hdl_programa AS HANDLE      NO-UNDO.

    DEFINE VARIABLE c_cod_table   AS CHARACTER FORMAT "x(8)"   NO-UNDO.
    DEFINE VARIABLE w_estabel     AS CHARACTER FORMAT "x(3)"   NO-UNDO.
    DEFINE VARIABLE c-cod-refer   AS CHARACTER FORMAT "x(10)"  NO-UNDO.

    DEFINE VARIABLE c-cod-esp      AS CHARACTER                 NO-UNDO.
    DEFINE VARIABLE c-estab        LIKE tit_acr.cod_estab       NO-UNDO.    
    DEFINE VARIABLE c-cod-tit-acr  LIKE tit_acr.cod_tit_acr     NO-UNDO.
    DEFINE VARIABLE d-dt-transacao LIKE docum-est.dt-trans      NO-UNDO.

    DEFINE VARIABLE i              AS INTEGER     NO-UNDO.
    DEFINE BUFFER bf_tit_acr       FOR tit_acr.

    EMPTY TEMP-TABLE tt_integr_acr_item_lote_impl_8 NO-ERROR.
    EMPTY TEMP-TABLE tt_integr_acr_repres_comis_2   NO-ERROR.
    EMPTY TEMP-TABLE tt_integr_acr_aprop_ctbl_pend  NO-ERROR.
    EMPTY TEMP-TABLE tt_log_erros_atualiz           NO-ERROR.
    EMPTY TEMP-TABLE tt_integr_acr_lote_impl        NO-ERROR.
    EMPTY TEMP-TABLE tt_integr_acr_item_lote_impl_9 NO-ERROR.
    EMPTY TEMP-TABLE tt_integr_acr_repres_comis_2   NO-ERROR.
    EMPTY TEMP-TABLE tt_integr_acr_item_lote_impl_9 NO-ERROR.
    EMPTY TEMP-TABLE tt_integr_acr_aprop_relacto_2  NO-ERROR.
    EMPTY TEMP-TABLE tt_integr_acr_relacto_pend_aux NO-ERROR.
    EMPTY TEMP-TABLE tt_integr_acr_aprop_relacto_2  NO-ERROR.
    EMPTY TEMP-TABLE tt_integr_acr_aprop_relacto    NO-ERROR.
    EMPTY TEMP-TABLE tt_integr_acr_aprop_relacto_2b NO-ERROR.

    DEFINE BUFFER b_tit_acr FOR tit_acr.

    /*Retorna Matriz Tradu‡Æo Organizacional*/
    RUN prgint/ufn/ufn908za.py (INPUT "1":u,
                                INPUT "15":U,
                                OUTPUT v_cod_matriz_trad_org_ext).
    /*Tradu‡Æo Estabelecimento*/
    RUN pi-traduz-estab(INPUT v_cod_matriz_trad_org_ext,
                        INPUT STRING(c-cod-estab), /*Estabelecimento EMS 2*/
                        OUTPUT c-estab-ems-5,
                        OUTPUT c-erro).

    /*Tradu‡Æo Empresa*/
    RUN pi-traduz-empresa(INPUT v_cod_matriz_trad_org_ext,
                          INPUT v_cdn_empres_usuar, /*Empresa EMS 2*/
                          OUTPUT c-empresa-ems-5,
                          OUTPUT c-erro).

    ASSIGN c_cod_refer = "".
    RUN pi_retorna_sugestao_referencia (INPUT  "AE",
                                        INPUT  TODAY,
                                        OUTPUT c_cod_refer,
                                        INPUT  "tit_acr",
                                        INPUT  STRING(c-cod-estab)).

    /* Cria‡Æo do lote cont bil */
    CREATE tt_integr_acr_lote_impl. 
    ASSIGN tt_integr_acr_lote_impl.tta_cod_empresa        = c-empresa-ems-5 /*Obrigat½rio*/
           tt_integr_acr_lote_impl.ttv_cod_empresa_ext    = string(v_cdn_empres_usuar) /*Obrigat½rio*/
           tt_integr_acr_lote_impl.tta_cod_estab          = c-estab-ems-5       /*Obrigat½rio*/
           tt_integr_acr_lote_impl.tta_cod_estab_ext      = STRING(c-cod-estab) /*Obrigat½rio*/ 
           tt_integr_acr_lote_impl.tta_dat_transacao      = IF d-dat-trans >= 11/01/2016 THEN d-dat-trans ELSE 11/01/2016
           tt_integr_acr_lote_impl.tta_ind_orig_tit_acr   = "2"
           tt_integr_acr_lote_impl.tta_ind_tip_cobr_acr   = "Normal"
           tt_integr_acr_lote_impl.tta_log_liquidac_autom = NO
           tt_integr_acr_lote_impl.ttv_log_lote_impl_ok   = YES
           tt_integr_acr_lote_impl.tta_cod_refer          = c_cod_refer.

    IF lDataEmis = NO THEN
         ASSIGN c-cod-titulo = c-prefixo + REPLACE(STRING(d-dat-emissao,"99/99/99"),"/","").
    ELSE ASSIGN c-cod-titulo = c-prefixo + REPLACE(STRING(dDatEmisOrigem,"99/99/99"),"/","").

    FIND LAST tit_acr
        WHERE tit_acr.cod_estab       = c-cod-estab
          AND tit_acr.cod_espec_docto = "AE"
          AND tit_acr.cod_ser_docto   = c-serie-docto
          AND tit_acr.cod_tit_acr     = c-cod-titulo  NO-LOCK NO-ERROR.
    IF AVAIL tit_acr THEN DO:
        
        ASSIGN i-cod-parcela = INT(tit_acr.cod_parcela) + 1 NO-ERROR.

        /* INICIO - L¢gica para nÆo dar erro quando achar uma parcela que contenha letras */
        IF i-cod-parcela = 0 THEN DO:

            DO i = 1 TO 99:
                FIND FIRST bf_tit_acr
                     WHERE bf_tit_acr.cod_estab        = tit_acr.cod_estab 
                       AND bf_tit_acr.cod_espec_docto  = tit_acr.cod_espec_docto
                       AND bf_tit_acr.cod_ser_docto    = tit_acr.cod_ser_docto
                       AND bf_tit_acr.cod_tit_acr      = tit_acr.cod_tit_acr
                       AND bf_tit_acr.cod_parcela      = STRING(i,"99") NO-LOCK NO-ERROR.
                IF AVAIL bf_tit_acr THEN DO:
                    NEXT.
                END.
                ELSE DO:
                    ASSIGN i-cod-parcela = i.
                    LEAVE.
                END.
            END.
        END.
        /* FIM    - L¢gica para nÆo dar erro quando achar uma parcela que contenha letras */
    END.
    ELSE DO:
        ASSIGN i-cod-parcela = 1.
    END.

    CREATE tt_integr_acr_item_lote_impl_9.
    ASSIGN tt_integr_acr_item_lote_impl_9.ttv_rec_lote_impl_tit_acr      = RECID(tt_integr_acr_lote_impl)
           tt_integr_acr_item_lote_impl_9.ttv_rec_item_lote_impl_tit_acr = RECID(tt_integr_acr_item_lote_impl_9)
           tt_integr_acr_item_lote_impl_9.tta_cod_refer                  = tt_integr_acr_lote_impl.tta_cod_refer
           tt_integr_acr_item_lote_impl_9.tta_cdn_cliente                = c-cod-emitente /*Obrigat½rio*/
           tt_integr_acr_item_lote_impl_9.tta_num_seq_refer              = 1
           tt_integr_acr_item_lote_impl_9.tta_cod_espec_docto            = "AE" /*Obrigat½rio*/ /*Duplicata*/  /*"AN"*/
           tt_integr_acr_item_lote_impl_9.tta_ind_tip_espec_docto        = "3":U /*Obrigat½rio*/ /*"3"*/  /*Antecipa»’o*/
           tt_integr_acr_item_lote_impl_9.tta_cod_ser_docto              = c-serie-docto
           tt_integr_acr_item_lote_impl_9.tta_cod_portador               = ""
           tt_integr_acr_item_lote_impl_9.tta_cod_portad_ext             = "" /*Obrigat½rio*/ 
           tt_integr_acr_item_lote_impl_9.tta_cod_modalid_ext            = "" /*string(nota-fiscal.modalidade)   /*Obrigat½rio*/ */
           tt_integr_acr_item_lote_impl_9.tta_cod_tit_acr                = c-cod-titulo   /*Obrigat½rio*/ 
           tt_integr_acr_item_lote_impl_9.tta_cod_parcela                = STRING(i-cod-parcela,"99") /*Obrigat½rio*/
           tt_integr_acr_item_lote_impl_9.tta_cod_indic_econ             = ""
           tt_integr_acr_item_lote_impl_9.tta_cod_cart_bcia              = "" /*"2"*/ /*Verificar este campo*/
           tt_integr_acr_item_lote_impl_9.tta_cod_finalid_econ_ext       = "0"
           tt_integr_acr_item_lote_impl_9.tta_ind_sit_tit_acr            = "Normal" /*Obrigat½rio*/
           tt_integr_acr_item_lote_impl_9.tta_cdn_repres                 = 0        
           tt_integr_acr_item_lote_impl_9.tta_dat_vencto_tit_acr         = IF d-dat-trans >= 11/01/2016 THEN d-dat-trans ELSE 11/01/2016 /*Obrigat½rio*/ /*tt-fat-duplic.dt-venciment*/
           tt_integr_acr_item_lote_impl_9.tta_dat_prev_liquidac          = IF d-dat-trans >= 11/01/2016 THEN d-dat-trans ELSE 11/01/2016 /*Obrigat½rio*/ /*tt-fat-duplic.dt-venciment*/
           tt_integr_acr_item_lote_impl_9.tta_dat_emis_docto             = IF d-dat-trans >= 11/01/2016 THEN d-dat-trans ELSE 11/01/2016 /*tt-nota-fiscal.dt-emis-nota*/
           tt_integr_acr_item_lote_impl_9.tta_des_text_histor            = "T¡tulo do agrupamento das  devolu‡äes de cupons fiscais do dia " + STRING(d-dat-emissao,"99/99/9999")
           tt_integr_acr_item_lote_impl_9.tta_cod_cond_pagto             = ""
           tt_integr_acr_item_lote_impl_9.tta_val_cotac_indic_econ       = 1
           tt_integr_acr_item_lote_impl_9.tta_ind_sit_bcia_tit_acr       = "1"
           tt_integr_acr_item_lote_impl_9.tta_ind_ender_cobr             = "1"
           tt_integr_acr_item_lote_impl_9.tta_log_liquidac_autom         = NO
           tt_integr_acr_item_lote_impl_9.ttv_cod_nota_fisc_faturam      = ""
           tt_integr_acr_item_lote_impl_9.tta_val_tit_acr                = d-valor-tit /*Obrigat½rio*/
           tt_integr_acr_item_lote_impl_9.tta_val_liq_tit_acr            = d-valor-tit /*Obrigat½rio*/
           tt_integr_acr_item_lote_impl_9.tta_des_obs_cobr               = "".

    RUN pi-acompanhar IN h-acomp (INPUT "Est/Esp/Ser/Tit./Par: ":U + STRING(tt_integr_acr_lote_impl.tta_cod_estab) + "/" +
                                                                     STRING(tt_integr_acr_item_lote_impl_9.tta_cod_espec_docto) + "/" + 
                                                                     STRING(tt_integr_acr_item_lote_impl_9.tta_cod_ser_docto)   + "/" + 
                                                                     STRING(tt_integr_acr_item_lote_impl_9.tta_cod_tit_acr) + "/" +
                                                                     STRING(tt_integr_acr_item_lote_impl_9.tta_cod_parcela)).

    CREATE tt_integr_acr_aprop_ctbl_pend.
    ASSIGN tt_integr_acr_aprop_ctbl_pend.ttv_rec_item_lote_impl_tit_acr  = tt_integr_acr_item_lote_impl_9.ttv_rec_item_lote_impl_tit_acr
           tt_integr_acr_aprop_ctbl_pend.tta_cod_plano_cta_ctbl          = "PADRAO"     /*Obrigat½rio*/  /*sch-param-vpi.cod-plano-cta-ctbl*/    /*'schulz'*/
           tt_integr_acr_aprop_ctbl_pend.tta_cod_cta_ctbl                = "32101020" /*Obrigat½rio*/
           tt_integr_acr_aprop_ctbl_pend.tta_cod_cta_ctbl_ext            = "" /*sch-param-vpi.cod-cta-ctbl*/          /*"1121995"*/
           tt_integr_acr_aprop_ctbl_pend.tta_cod_sub_cta_ctbl_ext        = "" /*sch-param-vpi.cod-ccusto*/ 
           tt_integr_acr_aprop_ctbl_pend.tta_cod_unid_negoc              = "000" /*Obrigat½rio*/ /*c-unid-negoc*/
           tt_integr_acr_aprop_ctbl_pend.tta_cod_unid_negoc_ext          = "" /*c-unid-negoc*/
           tt_integr_acr_aprop_ctbl_pend.tta_cod_plano_ccusto            = "" /* "PADRAO" Obrigat½rio*/ /*sch-param-vpi.cod-plano-ccusto*/      /*''*/ 
           tt_integr_acr_aprop_ctbl_pend.tta_cod_ccusto                  = "" /*"00697" Obrigat½rio*/ /*sch-param-vpi.cod-ccusto*/   
           tt_integr_acr_aprop_ctbl_pend.tta_cod_ccusto_ext              = ""                                  /*''*/
           tt_integr_acr_aprop_ctbl_pend.tta_cod_tip_fluxo_financ        = "105" /*Obrigat½rio*/
           tt_integr_acr_aprop_ctbl_pend.tta_cod_fluxo_financ_ext        = ""
           tt_integr_acr_aprop_ctbl_pend.tta_log_impto_val_agreg         = NO
           tt_integr_acr_aprop_ctbl_pend.tta_val_aprop_ctbl              = tt_integr_acr_item_lote_impl_9.tta_val_tit_acr. /*Obrigat½rio*/

    FIND FIRST conta-ft
         WHERE conta-ft.cod-estabel     = ?    
           AND conta-ft.cod-gr-cli      = ?   
           AND conta-ft.cod-canal-venda = ?  
           AND conta-ft.fm-com          = "" 
           AND conta-ft.nat-operacao    = ?  
           AND conta-ft.serie           = ?  
           AND conta-ft.cod-depos       = "" NO-ERROR.
    IF AVAIL conta-ft THEN DO:
        ASSIGN tt_integr_acr_aprop_ctbl_pend.tta_cod_cta_ctbl  = conta-ft.cod-cta-devol-recta. /*Obrigat½rio*/
    END.

    IF c-tipo = "Cartao" THEN DO:
        IF c-prefixo = "REDE" THEN
             ASSIGN tt_integr_acr_aprop_ctbl_pend.tta_cod_tip_fluxo_financ = "115".
        ELSE IF c-prefixo = "CIEL" THEN
             ASSIGN tt_integr_acr_aprop_ctbl_pend.tta_cod_tip_fluxo_financ = "110".
    END.

    RUN prgfin/acr/acr900zi.py persistent set v_hdl_api_integr_acr.
    RUN pi_main_code_integr_acr_new_12 IN v_hdl_api_integr_acr (INPUT 11,
                                                                INPUT v_cod_matriz_trad_org_ext,
                                                                INPUT YES,
                                                                INPUT YES,
                                                                INPUT TABLE tt_integr_acr_repres_comis_2,
                                                                INPUT-OUTPUT TABLE tt_integr_acr_item_lote_impl_9,
                                                                INPUT TABLE tt_integr_acr_aprop_relacto_2,
                                                                INPUT-OUTPUT TABLE tt_params_generic_api,
                                                                INPUT TABLE tt_integr_acr_relacto_pend_aux).

    DELETE PROCEDURE v_hdl_api_integr_acr.

    /*Tratamento de erros*/
    IF CAN-FIND(FIRST tt_log_erros_atualiz) THEN DO:
        FIND FIRST tt_integr_acr_item_lote_impl_9 NO-LOCK NO-ERROR.
        IF AVAIL tt_integr_acr_item_lote_impl_9 THEN DO:
            RUN pi-cria-tt-erro(INPUT tt_integr_acr_item_lote_impl_9.tta_num_seq_refer,
                                INPUT 17006, 
                                INPUT "Houve erro na cria‡Æo do titulo abaixo, favor verificar.",
                                INPUT "Estab/Especie/Serie/Titulo/Parcela/Cliente/Portador : " +  STRING(c-cod-estab) + "/" +
                                                                                                  STRING(tt_integr_acr_item_lote_impl_9.tta_cod_espec_docto) + "/" +
                                                                                                  STRING(tt_integr_acr_item_lote_impl_9.tta_cod_ser_docto) + "/" +
                                                                                                  STRING(tt_integr_acr_item_lote_impl_9.tta_cod_tit_acr) + "/" +
                                                                                                  STRING(tt_integr_acr_item_lote_impl_9.tta_cod_parcela) + "/" +
                                                                                                  STRING(tt_integr_acr_item_lote_impl_9.tta_cdn_cliente) + "/"  +
                                                                                                  STRING(tt_integr_acr_item_lote_impl_9.tta_cod_portad_ext)   ). 
        END.

        FOR EACH tt_log_erros_atualiz:
            RUN pi-cria-tt-erro(INPUT tt_log_erros_atualiz.tta_num_seq_refer,
                                INPUT tt_log_erros_atualiz.ttv_num_mensagem, 
                                INPUT tt_log_erros_atualiz.ttv_des_msg_erro,
                                INPUT tt_log_erros_atualiz.ttv_des_msg_ajuda).
        END.
        ASSIGN l-erro = YES.
        RETURN "NOK".
    END.
    ELSE DO:
        ASSIGN iNumSeq = 0.
        FOR EACH tt_integr_acr_item_lote_impl_9 NO-LOCK:
            CREATE tt-tit-criados.
            ASSIGN tt-tit-criados.cod_estab          = c-cod-estab
                   tt-tit-criados.cod_espec_docto    = tt_integr_acr_item_lote_impl_9.tta_cod_espec_docto
                   tt-tit-criados.cod_ser_docto      = tt_integr_acr_item_lote_impl_9.tta_cod_ser_docto
                   tt-tit-criados.cod_tit_acr        = tt_integr_acr_item_lote_impl_9.tta_cod_tit_acr
                   tt-tit-criados.cod_parcela        = tt_integr_acr_item_lote_impl_9.tta_cod_parcela              
                   tt-tit-criados.cdn_cliente        = tt_integr_acr_item_lote_impl_9.tta_cdn_cliente
                   tt-tit-criados.cod_portador       = tt_integr_acr_item_lote_impl_9.tta_cod_portad_ext
                   tt-tit-criados.val_origin_tit_acr = tt_integr_acr_item_lote_impl_9.tta_val_tit_acr
                   tt-tit-criados.dat_transacao      = tt_integr_acr_item_lote_impl_9.tta_dat_emis_docto    
                   tt-tit-criados.dat_emis_docto     = tt_integr_acr_item_lote_impl_9.tta_dat_emis_docto    
                   tt-tit-criados.dat_vencto_tit_acr = tt_integr_acr_item_lote_impl_9.tta_dat_vencto_tit_acr
                   tt-tit-criados.situacao           = "T¡tulo Gerado".

            FIND FIRST tit_acr NO-LOCK
                 WHERE tit_acr.cod_estab       = c-cod-estab                          
                   AND tit_acr.cod_espec_docto = tt_integr_acr_item_lote_impl_9.tta_cod_espec_docto
                   AND tit_acr.cod_ser_docto   = tt_integr_acr_item_lote_impl_9.tta_cod_ser_docto  
                   AND tit_acr.cod_tit_acr     = tt_integr_acr_item_lote_impl_9.tta_cod_tit_acr    
                   AND tit_acr.cod_parcela     = tt_integr_acr_item_lote_impl_9.tta_cod_parcela     NO-ERROR.
            IF AVAIL tit_acr THEN DO:

                FOR EACH tt-devolucao-aux: 
                    ASSIGN iNumSeq = iNumSeq + 1.


                    FOR FIRST cst_fat_devol
                        WHERE ROWID(cst_fat_devol) = tt-devolucao-aux.r-fat-devol EXCLUSIVE-LOCK,
                        FIRST docum-est
                        WHERE docum-est.cod-estabel  = cst_fat_devol.cod_estabel
                          AND docum-est.serie-docto  = cst_fat_devol.serie_docto
                          AND docum-est.nro-docto    = cst_fat_devol.nro_docto
                          AND docum-est.nat-operacao = cst_fat_devol.nat_operacao
/*                           AND docum-est.cod-emitente = cst_fat_devol.cod-emitente */
                        EXCLUSIVE-LOCK:

                        ASSIGN cst_fat_devol.flag_atualiz = YES
                               docum-est.cr-atual         = YES.
                        
                        CREATE tit_acr_cartao.
                        ASSIGN tit_acr_cartao.num_id_tit_acr         = tit_acr.num_id_tit_acr
                               tit_acr_cartao.num_seq                = iNumSeq.
                        ASSIGN tit_acr_cartao.cod_admdra             = ""
                               tit_acr_cartao.cod_autoriz_cartao_cr  = ""
                               tit_acr_cartao.cod_comprov_vda        = ""
                               tit_acr_cartao.cod_empresa            = tit_acr.cod_empresa
                               tit_acr_cartao.cod_estab              = tit_acr.cod_estab
                               tit_acr_cartao.cod_parc               = tit_acr.cod_parcela 
                               tit_acr_cartao.dat_atualiz            = TODAY
                               tit_acr_cartao.dat_cred_cartao_cr     = ?
                               tit_acr_cartao.dat_vda_cartao_cr      = tit_acr.dat_emis_docto 
                               tit_acr_cartao.hra_atualiz            = REPLACE(STRING(TIME, "HH:MM:SS"), ":","")
                               tit_acr_cartao.val_comprov_vda        = cst_fat_devol.vl_devolucao
                               tit_acr_cartao.val_des_admdra         = 0
                               tit_acr_cartao.num_cupom              = docum-est.nro-docto
                               tit_acr_cartao.cartao_manual          = NO.
                            .

                            ASSIGN c-cod-esp     = ""
                                   c-estab       = ""
                                   c-cod-tit-acr = "".

                            IF c-tipo = "Dinheiro" THEN 
                                 ASSIGN c-cod-esp = "DI".
                            ELSE ASSIGN c-cod-esp = cst_fat_devol.cod_esp .

                            /* INICIO - Regra devido a Estabelecimento Devolu‡Æo Diferente do Estabelecimento de Origem*/
                            IF c-tipo = "Dinheiro" AND tt-devolucao-aux.l-estab-dif = YES THEN DO:
                                ASSIGN c-estab       = docum-est.cod-estab.
                                       c-cod-tit-acr = c-prefixo + REPLACE(STRING(docum-est.dt-emis,"99/99/99"),"/","").
                            END.
                            ELSE DO:
                                ASSIGN c-estab       = tit_acr.cod_estab 
                                       c-cod-tit-acr = tit_acr.cod_tit_acr.
                            END.
                            /* INICIO - Regra devido a Estabelecimento Devolu‡Æo Diferente do Estabelecimento de Origem*/


                            /* INICIO - Devolu‡Æo - Nova - Realiza‡Æo da Baixa da Antecipa‡Æo Criada Anteriormente */
                            FIND FIRST b_tit_acr NO-LOCK
                                 WHERE b_tit_acr.cod_estab        = c-estab
                                   AND b_tit_acr.cod_espec_docto  = c-cod-esp                         
                                   AND b_tit_acr.cod_tit_acr      = c-cod-tit-acr NO-ERROR.
                            IF NOT AVAIL b_tit_acr THEN DO:                
                                 RUN pi-cria-tt-erro(INPUT 1,
                                                     INPUT 17006,
                                                     INPUT "Estab/Especie/Titulo Nr.: " + string(c-estab) + "/" + STRING(c-cod-esp) + "/" + string(c-cod-tit-acr) + " , nÆo foi encontrado.",
                                                     INPUT "Estab/Especie/Titulo Nr.: " + string(c-estab) + "/" + STRING(c-cod-esp) + "/" + string(c-cod-tit-acr) + " , nÆo foi encontrado.").                
                                 NEXT.
                            END. 

                            IF AVAIL b_tit_acr AND log_sdo_tit_acr = NO THEN DO:
                                FIND FIRST b_tit_acr NO-LOCK
                                     WHERE b_tit_acr.cod_estab        = c-estab                  
                                       AND b_tit_acr.cod_espec_docto  = c-cod-esp    
                                       AND b_tit_acr.cod_tit_acr      = c-cod-tit-acr  
                                       AND log_sdo_tit_acr          = YES    NO-ERROR.
                                IF NOT AVAIL b_tit_acr THEN DO:                
                                     RUN pi-cria-tt-erro(INPUT 1,
                                                         INPUT 17006,
                                                         INPUT "Estab/Especie/Titulo Nr.: " + string(c-estab) + "/" + STRING(c-cod-esp) + "/" + string(c-cod-tit-acr) + " , nÆo foi encontrado com saldo pra realizar a Liquida‡Æo.",
                                                         INPUT "Estab/Especie/Titulo Nr.: " + string(c-estab) + "/" + STRING(c-cod-esp) + "/" + string(c-cod-tit-acr) + " , nÆo foi encontrado com saldo pra realizar a Liquida‡Æo.").                
                                     NEXT.                   
                                END. 
                            END.

                            EMPTY temp-table tt_integr_acr_liquidac_lote    no-error.
                            EMPTY temp-table tt_integr_acr_liq_item_lote_3  no-error.
                            EMPTY temp-table tt_integr_acr_abat_antecip     no-error.
                            EMPTY temp-table tt_integr_acr_abat_prev        no-error.
                            EMPTY temp-table tt_integr_acr_cheq             no-error.
                            EMPTY temp-table tt_integr_acr_liquidac_impto_2 no-error.
                            EMPTY temp-table tt_integr_acr_rel_pend_cheq    no-error.
                            EMPTY temp-table tt_integr_acr_liq_aprop_ctbl   no-error.
                            EMPTY temp-table tt_integr_acr_liq_desp_rec     no-error.
                            EMPTY temp-table tt_integr_acr_aprop_liq_antec  no-error.
                            EMPTY temp-table tt_log_erros_import_liquidac   no-error.

                            assign c_cod_table = "lote_liquidac_acr"
                                   w_estabel   = tit_acr.cod_estab. 

                            ASSIGN c-cod-refer = "".

                            run pi_retorna_sugestao_referencia (INPUT  "LD",
                                                                INPUT  TODAY,
                                                                OUTPUT c-cod-refer,
                                                                INPUT  c_cod_table,
                                                                INPUT  w_estabel).

                            /* INICIO - Verifica‡Æo da Data de Transa‡Æo, para sempre pegar £ltima */
                            ASSIGN d-dt-transacao = ?.
                            FIND LAST b_movto_tit_acr NO-LOCK
                                WHERE b_movto_tit_acr.cod_estab             = b_tit_acr.cod_estab
                                  AND b_movto_tit_acr.num_id_tit_acr        = b_tit_acr.num_id_tit_acr
                                  AND b_movto_tit_acr.num_id_movto_tit_acr >  0
                                  AND b_movto_tit_acr.dat_transacao         > tit_acr.dat_transacao
                                  AND b_movto_tit_acr.log_ctbz_aprop_ctbl   = yes
                                  AND b_movto_tit_acr.log_movto_estordo     = no 
                                  AND NOT b_movto_tit_acr.ind_trans_acr begins "Estorno" /*l_estorno*/  NO-ERROR.
                            IF NOT AVAIL b_movto_tit_acr THEN DO:
                                ASSIGN d-dt-transacao = tit_acr.dat_transacao.
                            END.
                            ELSE DO:
                                ASSIGN d-dt-transacao = b_movto_tit_acr.dat_transacao.
                            END.
                            RELEASE b_movto_tit_acr.
                            /* FIM    - Verifica‡Æo da Data de Transa‡Æo, para sempre pegar £ltima */


                            create tt_integr_acr_liquidac_lote.
                            assign tt_integr_acr_liquidac_lote.tta_cod_empresa                 = b_tit_acr.cod_empresa
                                   tt_integr_acr_liquidac_lote.tta_cod_estab_refer             = b_tit_acr.cod_estab
                                   tt_integr_acr_liquidac_lote.tta_cod_usuario                 = c-seg-usuario
                                   tt_integr_acr_liquidac_lote.tta_cod_portador                = b_tit_acr.cod_portador
                                   tt_integr_acr_liquidac_lote.tta_cod_cart_bcia               = b_tit_acr.cod_cart_bcia
                                   tt_integr_acr_liquidac_lote.tta_dat_gerac_lote_liquidac     = d-dt-transacao
                                   tt_integr_acr_liquidac_lote.tta_dat_transacao               = d-dt-transacao
                                   tt_integr_acr_liquidac_lote.tta_val_tot_lote_liquidac_infor = 0 
                                   tt_integr_acr_liquidac_lote.tta_val_tot_lote_liquidac_efetd = 0  
                                   tt_integr_acr_liquidac_lote.tta_val_tot_despes_bcia         = 0
                                   tt_integr_acr_liquidac_lote.tta_ind_tip_liquidac_acr        = "lote"
                                   tt_integr_acr_liquidac_lote.tta_ind_sit_lote_liquidac_acr   = "Em digita‡Æo":U
                                   tt_integr_acr_liquidac_lote.tta_nom_arq_movimen_bcia        = ""
                                   tt_integr_acr_liquidac_lote.tta_cdn_cliente                 = b_tit_acr.cdn_cliente
                                   tt_integr_acr_liquidac_lote.tta_log_enctro_cta              = no   
                                   tt_integr_acr_liquidac_lote.ttv_log_atualiz_refer           = YES
                                   tt_integr_acr_liquidac_lote.ttv_log_gera_lote_parcial       = yes 
                                   tt_integr_acr_liquidac_lote.ttv_rec_lote_liquidac_acr       = recid(tt_integr_acr_liquidac_lote)
                                   tt_integr_acr_liquidac_lote.tta_cod_refer                   = c-cod-refer
                                   tt_integr_acr_liquidac_lote.ttv_cod_indic_econ              = "" /*tit_acr.cod_indic_econ*/ . 

                            create tt_integr_acr_liq_item_lote_3.
                            assign tt_integr_acr_liq_item_lote_3.tta_cod_empresa              = b_tit_acr.cod_empresa
                                   tt_integr_acr_liq_item_lote_3.tta_cod_estab                = b_tit_acr.cod_estab
                                   tt_integr_acr_liq_item_lote_3.tta_cod_espec_docto          = b_tit_acr.cod_espec_docto
                                   tt_integr_acr_liq_item_lote_3.tta_cod_ser_docto            = b_tit_acr.cod_ser_docto
                                   tt_integr_acr_liq_item_lote_3.tta_cod_tit_acr              = b_tit_acr.cod_tit_acr
                                   tt_integr_acr_liq_item_lote_3.tta_cod_parcela              = b_tit_acr.cod_parcela
                                   tt_integr_acr_liq_item_lote_3.tta_cdn_cliente              = b_tit_acr.cdn_cliente
                                   tt_integr_acr_liq_item_lote_3.tta_cod_portad_ext           = ""
                                   tt_integr_acr_liq_item_lote_3.tta_cod_modalid_ext          = ""
                                   tt_integr_acr_liq_item_lote_3.tta_cod_portador             = b_tit_acr.cod_portador
                                   tt_integr_acr_liq_item_lote_3.tta_cod_cart_bcia            = b_tit_acr.cod_cart_bcia
                                   tt_integr_acr_liq_item_lote_3.tta_cod_finalid_econ         = "Corrente"
                                   tt_integr_acr_liq_item_lote_3.tta_cod_indic_econ           = b_tit_acr.cod_indic_econ 
                                   tt_integr_acr_liq_item_lote_3.tta_val_tit_acr              = b_tit_acr.val_sdo_tit_acr /* tt-titulo.vl-movto */
                                   tt_integr_acr_liq_item_lote_3.tta_val_liquidac_tit_acr     = cst_fat_devol.vl_devolucao
                                   tt_integr_acr_liq_item_lote_3.tta_dat_cr_liquidac_tit_acr  = d-dt-transacao
                                   tt_integr_acr_liq_item_lote_3.tta_dat_cr_liquidac_calc     = d-dt-transacao
                                   tt_integr_acr_liq_item_lote_3.tta_dat_liquidac_tit_acr     = d-dt-transacao
                                   tt_integr_acr_liq_item_lote_3.tta_cod_autoriz_bco          = ""
                                   tt_integr_acr_liq_item_lote_3.tta_val_abat_tit_acr         = 0
                                   tt_integr_acr_liq_item_lote_3.tta_val_despes_bcia          = 0
                                   tt_integr_acr_liq_item_lote_3.tta_val_multa_tit_acr        = 0
                                   tt_integr_acr_liq_item_lote_3.tta_val_juros                = 0
                                   tt_integr_acr_liq_item_lote_3.tta_val_cm_tit_acr           = 0
                                   tt_integr_acr_liq_item_lote_3.tta_val_liquidac_orig        = 0
                                   tt_integr_acr_liq_item_lote_3.tta_val_desc_tit_acr_orig    = 0  
                                   tt_integr_acr_liq_item_lote_3.tta_val_abat_tit_acr_orig    = 0 
                                   tt_integr_acr_liq_item_lote_3.tta_val_despes_bcia_orig     = 0
                                   tt_integr_acr_liq_item_lote_3.tta_val_multa_tit_acr_origin = 0
                                   tt_integr_acr_liq_item_lote_3.tta_val_juros_tit_acr_orig   = 0
                                   tt_integr_acr_liq_item_lote_3.tta_val_cm_tit_acr_orig      = 0
                                   tt_integr_acr_liq_item_lote_3.tta_val_nota_db_orig         = 0
                                   tt_integr_acr_liq_item_lote_3.tta_log_gera_antecip         = NO
                                   tt_integr_acr_liq_item_lote_3.tta_des_text_histor          = ""
                                   tt_integr_acr_liq_item_lote_3.tta_ind_sit_item_lote_liquidac = ""
                                   tt_integr_acr_liq_item_lote_3.tta_log_gera_avdeb           = NO
                                   tt_integr_acr_liq_item_lote_3.tta_cod_indic_econ_avdeb     = ""
                                   tt_integr_acr_liq_item_lote_3.tta_cod_portad_avdeb         = ""
                                   tt_integr_acr_liq_item_lote_3.tta_cod_cart_bcia_avdeb      = "" 
                                   tt_integr_acr_liq_item_lote_3.tta_dat_vencto_avdeb         = ?
                                   tt_integr_acr_liq_item_lote_3.tta_val_perc_juros_avdeb     = 0
                                   tt_integr_acr_liq_item_lote_3.tta_val_avdeb                = 0
                                   tt_integr_acr_liq_item_lote_3.tta_log_movto_comis_estordo  = no
                                   tt_integr_acr_liq_item_lote_3.tta_ind_tip_item_liquidac_acr = "Pagamento"
                                   tt_integr_acr_liq_item_lote_3.tta_ind_tip_calc_juros       = "Compostos"
                                   tt_integr_acr_liq_item_lote_3.ttv_rec_lote_liquidac_acr    = tt_integr_acr_liquidac_lote.ttv_rec_lote_liquidac_acr
                                   tt_integr_acr_liq_item_lote_3.ttv_rec_item_lote_liquidac_acr = recid(tt_integr_acr_liq_item_lote_3)
                                   tt_integr_acr_liq_item_lote_3.tta_val_cotac_indic_econ = 1.

                            CREATE tt_integr_acr_abat_antecip.
                            ASSIGN tt_integr_acr_abat_antecip.ttv_rec_item_lote_impl_tit_acr = tt_integr_acr_liq_item_lote_3.ttv_rec_item_lote_liquidac_acr
                                   tt_integr_acr_abat_antecip.ttv_rec_abat_antecip_acr       = RECID(tt_integr_acr_abat_antecip)
                                   tt_integr_acr_abat_antecip.tta_cod_estab                  = tit_acr.cod_estab
                                   tt_integr_acr_abat_antecip.tta_cod_estab_ext              = tit_acr.cod_estab
                                   tt_integr_acr_abat_antecip.tta_cod_espec_docto            = tit_acr.cod_espec_docto
                                   tt_integr_acr_abat_antecip.tta_cod_ser_docto              = tit_acr.cod_ser_docto
                                   tt_integr_acr_abat_antecip.tta_cod_tit_acr                = tit_acr.cod_tit_acr
                                   tt_integr_acr_abat_antecip.tta_cod_parcela                = tit_acr.cod_parcela
                                   tt_integr_acr_abat_antecip.tta_val_abtdo_antecip_tit_abat = cst_fat_devol.vl_devolucao.

                            RUN prgfin/acr/acr901zf.py PERSISTENT SET v_hdl_programa.
                            RUN pi_main_code_api_integr_acr_liquidac_5 IN v_hdl_programa (INPUT 1,
                                                                                          INPUT TABLE tt_integr_acr_liquidac_lote,
                                                                                          INPUT TABLE tt_integr_acr_liq_item_lote_3,
                                                                                          INPUT TABLE tt_integr_acr_abat_antecip,
                                                                                          INPUT TABLE tt_integr_acr_abat_prev,
                                                                                          INPUT TABLE tt_integr_acr_cheq,
                                                                                          INPUT TABLE tt_integr_acr_liquidac_impto_2,
                                                                                          INPUT TABLE tt_integr_acr_rel_pend_cheq,
                                                                                          INPUT TABLE tt_integr_acr_liq_aprop_ctbl,
                                                                                          INPUT TABLE tt_integr_acr_liq_desp_rec,
                                                                                          INPUT TABLE tt_integr_acr_aprop_liq_antec,
                                                                                          INPUT "EMS",
                                                                                          OUTPUT TABLE tt_log_erros_import_liquidac,
                                                                                          INPUT TABLE tt_integr_cambio_ems5).
                           DELETE PROCEDURE v_hdl_programa.

                           IF CAN-FIND(FIRST tt_log_erros_import_liquidac) THEN DO:
                               FOR EACH tt_log_erros_import_liquidac NO-LOCK:

                                   FIND FIRST tt_integr_acr_liq_item_lote_3 NO-LOCK NO-ERROR.
                                   IF AVAIL tt_integr_acr_liq_item_lote_3 THEN DO:
                                       RUN pi-cria-tt-erro(INPUT tt_integr_acr_liq_item_lote_3.tta_num_seq_refer,
                                                           INPUT 17006,
                                                           INPUT "Houve erro na vincula‡Æo da AE com o T¡tulo Abaixo, favor verificar.",
                                                           INPUT "Estab/Especie/Serie/Titulo/Parcela/Cliente/Portador : " +  STRING(b_tit_acr.cod_estab)       + "/" +
                                                                                                                             STRING(b_tit_acr.cod_espec_docto) + "/" +
                                                                                                                             STRING(b_tit_acr.cod_ser_docto)   + "/" +
                                                                                                                             STRING(b_tit_acr.cod_tit_acr)     + "/" +
                                                                                                                             STRING(b_tit_acr.cod_parcela)     + "/" +
                                                                                                                             STRING(b_tit_acr.cdn_cliente)     + "/"  +
                                                                                                                             STRING(b_tit_acr.cod_portador)   ).
                                   END.

                                   RUN pi-cria-tt-erro(INPUT  tt_log_erros_import_liquidac.tta_num_seq,
                                                       INPUT  tt_log_erros_import_liquidac.ttv_num_erro_log,    
                                                       INPUT  tt_log_erros_import_liquidac.ttv_des_msg_erro,
                                                       INPUT  tt_log_erros_import_liquidac.ttv_des_msg_erro).
                               END.                     
                               NEXT.
                           END. 
                            /* FIM    - Devolu‡Æo - Nova - Realiza‡Æo da Baixa da Antecipa‡Æo Criada Anteriormente */
                    END.
                END.
                ASSIGN iNumSeq = 0.
            END.    
        END.
    END. /* ELSE Erros Importa‡Æo*/
END PROCEDURE. /* pi-cria-tit-acr */

PROCEDURE pi-carrega-movto-dinheiro:
    
    EMPTY TEMP-TABLE tt-devolucao NO-ERROR.
    
    FOR EACH cst_fat_devol NO-LOCK 
       WHERE cst_fat_devol.cod_estabel   = bf-estabelec.cod-estabel
         AND cst_fat_devol.modo_devolucao = "Dinheiro"
         AND cst_fat_devol.cod_portador  >= INT(tt-param.c-portador-ini)
         AND cst_fat_devol.cod_portador  <= INT(tt-param.c-portador-fim)
         AND cst_fat_devol.flag_atualiz   = NO,
       FIRST docum-est
       WHERE docum-est.cod-estabel  = cst_fat_devol.cod_estabel
         AND docum-est.serie-docto  = cst_fat_devol.serie_docto
         AND docum-est.nro-docto    = cst_fat_devol.nro_docto
         AND docum-est.nat-operacao = cst_fat_devol.nat_operacao
         AND docum-est.cod-emitente = cst_fat_devol.cod_emitente 
         AND docum-est.ce-atual     = YES
         AND docum-est.esp-docto    = 20
         AND docum-est.cr-atual     = NO
         AND docum-est.dt-emis     >= tt-param.c-data-emissao-ini
         AND docum-est.dt-emis     <= tt-param.c-data-emissao-fim  NO-LOCK,
/*          AND docum-est.dt-emis      = tt-param.c-data-emissao  NO-LOCK, */
       FIRST bf-nota-fiscal NO-LOCK
       WHERE bf-nota-fiscal.cod-estabel       = cst_fat_devol.cod_estabel
         AND bf-nota-fiscal.serie             = cst_fat_devol.serie_docto
         AND bf-nota-fiscal.nr-nota-fis       = cst_fat_devol.nro_docto
         AND bf-nota-fiscal.cod-emitente      = cst_fat_devol.cod_emitente
         AND bf-nota-fiscal.idi-sit-nf-eletro = 3,
       FIRST estabelec NO-LOCK
       WHERE estabelec.cod-estabel   = docum-est.cod-estabel
         AND estabelec.cod-emitente >= tt-param.c-cliente-ini
         AND estabelec.cod-emitente <= tt-param.c-cliente-fim,
       FIRST nota-fiscal NO-LOCK
       WHERE nota-fiscal.cod-estabel  = cst_fat_devol.cod_estab_comp  
         AND nota-fiscal.serie        = cst_fat_devol.serie_comp
         AND nota-fiscal.nr-nota-fis  = cst_fat_devol.nro_comp
    BREAK BY docum-est.cod-estab  query-tuning(no-lookahead):

        RUN pi-acompanhar IN h-acomp (INPUT "Data/Cupom: " + STRING(docum-est.dt-emissao,"99/99/9999") + " - " + STRING(docum-est.nro-docto)).
    
        CREATE tt-devolucao.
        ASSIGN tt-devolucao.cod-estab     = docum-est.cod-estab    
               tt-devolucao.cod-emitente  = estabelec.cod-emitente 
               tt-devolucao.serie-docto   = docum-est.serie-docto  
               tt-devolucao.nro-docto     = docum-est.nro-docto    
               tt-devolucao.nat-operacao  = docum-est.nat-operacao 
               tt-devolucao.cod-parcela   = cst_fat_devol.parcela
               tt-devolucao.cod-portador  = cst_fat_devol.cod_portador
               tt-devolucao.val-devolucao = cst_fat_devol.vl_devolucao
               tt-devolucao.dat-emissao   = docum-est.dt-emis
               tt-devolucao.dat-trans     = docum-est.dt-trans
               tt-devolucao.cod-prefixo   = "DINH"
               tt-devolucao.r-fat-devol   = ROWID(cst_fat_devol)
               tt-devolucao.cod-estab-ori = nota-fiscal.cod-estabel
               tt-devolucao.serie-ori     = nota-fiscal.serie
               tt-devolucao.dat-emiss-ori = nota-fiscal.dt-emis-nota
            .

        IF tt-devolucao.cod-estab-ori <> tt-devolucao.cod-estab THEN
             ASSIGN tt-devolucao.l-estab-dif = YES.
        ELSE ASSIGN tt-devolucao.l-estab-dif = NO.
        
    END.
END PROCEDURE. /* pi-carrega-movto-dinheiro */

PROCEDURE pi-carrega-movto-cartao:

    EMPTY TEMP-TABLE tt-devolucao NO-ERROR.
    
    FOR EACH cst_fat_devol NO-LOCK
       WHERE cst_fat_devol.cod_estabel   = bf-estabelec.cod-estabel
         AND cst_fat_devol.modo_devolucao = "Cartao"
         AND cst_fat_devol.cod_portador  >= INT(tt-param.c-portador-ini)
         AND cst_fat_devol.cod_portador  <= INT(tt-param.c-portador-fim)
         AND cst_fat_devol.flag_atualiz   = NO,
       FIRST docum-est 
       WHERE docum-est.cod-estabel  = cst_fat_devol.cod_estabel
         AND docum-est.serie-docto  = cst_fat_devol.serie_docto
         AND docum-est.nro-docto    = cst_fat_devol.nro_docto
         AND docum-est.nat-operacao = cst_fat_devol.nat_operacao
         AND docum-est.cod-emitente = cst_fat_devol.cod_emitente 
         AND docum-est.ce-atual     = YES
         AND docum-est.esp-docto    = 20
         AND docum-est.cr-atual     = NO
         AND docum-est.dt-emis     >= tt-param.c-data-emissao-ini
         AND docum-est.dt-emis     <= tt-param.c-data-emissao-fim  NO-LOCK,
/*          AND docum-est.dt-emis      = tt-param.c-data-emissao  NO-LOCK, */
       FIRST bf-nota-fiscal NO-LOCK
       WHERE bf-nota-fiscal.cod-estabel       = cst_fat_devol.cod_estabel
         AND bf-nota-fiscal.serie             = cst_fat_devol.serie_docto
         AND bf-nota-fiscal.nr-nota-fis       = cst_fat_devol.nro_docto
         AND bf-nota-fiscal.cod-emitente      = cst_fat_devol.cod_emitente
         AND bf-nota-fiscal.idi-sit-nf-eletro = 3,
       FIRST portador_agrupador
       WHERE portador_agrupador.cod_portador  = STRING(cst_fat_devol.cod_portador)
         AND portador_agrupador.cod_emitente >= tt-param.c-cliente-ini 
         AND portador_agrupador.cod_emitente <= tt-param.c-cliente-fim,
       FIRST nota-fiscal NO-LOCK
       WHERE nota-fiscal.cod-estabel  = cst_fat_devol.cod_estab_comp  
         AND nota-fiscal.serie        = cst_fat_devol.serie_comp
         AND nota-fiscal.nr-nota-fis  = cst_fat_devol.nro_comp
    BREAK BY docum-est.cod-estab query-tuning(no-lookahead):
    
        RUN pi-acompanhar IN h-acomp (INPUT "Data/Cupom: " + STRING(docum-est.dt-emissao,"99/99/9999") + " - " + STRING(docum-est.nro-docto)).

        CREATE tt-devolucao.
        ASSIGN tt-devolucao.cod-estab     = docum-est.cod-estab    
               tt-devolucao.cod-emitente  = portador_agrupador.cod_emitente 
               tt-devolucao.serie-docto   = docum-est.serie-docto  
               tt-devolucao.nro-docto     = docum-est.nro-docto    
               tt-devolucao.nat-operacao  = docum-est.nat-operacao 
               tt-devolucao.cod-parcela   = cst_fat_devol.parcela
               tt-devolucao.cod-portador  = cst_fat_devol.cod_portador
               tt-devolucao.val-devolucao = cst_fat_devol.vl_devolucao
               tt-devolucao.dat-emissao   = docum-est.dt-emis
               tt-devolucao.dat-trans     = docum-est.dt-trans
               tt-devolucao.cod-prefixo   = portador_agrupador.prefixo
               tt-devolucao.r-fat-devol   = ROWID(cst_fat_devol)
               tt-devolucao.cod-estab-ori = nota-fiscal.cod-estabel
               tt-devolucao.serie-ori     = nota-fiscal.serie
               tt-devolucao.dat-emiss-ori = nota-fiscal.dt-emis-nota 
               tt-devolucao.l-dat-emis    = portador_agrupador.ind_devol_dat_emis.
            .

        IF tt-devolucao.cod-estab-ori <> tt-devolucao.cod-estab THEN
             ASSIGN tt-devolucao.l-estab-dif = YES.
        ELSE ASSIGN tt-devolucao.l-estab-dif = NO.
        
    END.

END PROCEDURE. /* pi-carrega-movto-debito */

PROCEDURE pi-carrega-movto-convenio:

    EMPTY TEMP-TABLE tt-devolucao NO-ERROR.
    
    FOR EACH cst_fat_devol NO-LOCK
       WHERE cst_fat_devol.cod_estabel   >= tt-param.c-estab-ini 
         AND cst_fat_devol.cod_estabel   <= tt-param.c-estab-fim 
         AND cst_fat_devol.modo_devolucao = "Nenhum"
         AND cst_fat_devol.cod_portador  >= INT(tt-param.c-portador-ini)
         AND cst_fat_devol.cod_portador  <= INT(tt-param.c-portador-fim)
         AND cst_fat_devol.flag_atualiz   = NO,
       FIRST docum-est 
       WHERE docum-est.cod-estabel  = cst_fat_devol.cod_estabel
         AND docum-est.serie-docto  = cst_fat_devol.serie_docto
         AND docum-est.nro-docto    = cst_fat_devol.nro_docto
         AND docum-est.nat-operacao = cst_fat_devol.nat_operacao
         AND docum-est.cod-emitente = cst_fat_devol.cod_emitente 
         AND docum-est.ce-atual      = YES
         AND docum-est.esp-docto     = 20
         AND docum-est.cr-atual      = NO
         AND docum-est.dt-emis     >= tt-param.c-data-emissao-ini
         AND docum-est.dt-emis     <= tt-param.c-data-emissao-fim
/*          AND docum-est.dt-emis      = tt-param.c-data-emissao */
         AND docum-est.cod-emitente >= tt-param.c-cliente-ini
         AND docum-est.cod-emitente <= tt-param.c-cliente-fim  NO-LOCK,
       FIRST bf-nota-fiscal NO-LOCK
       WHERE bf-nota-fiscal.cod-estabel       = cst_fat_devol.cod_estabel
         AND bf-nota-fiscal.serie             = cst_fat_devol.serie_docto
         AND bf-nota-fiscal.nr-nota-fis       = cst_fat_devol.nro_docto
         AND bf-nota-fiscal.cod-emitente      = cst_fat_devol.cod_emitente
         AND bf-nota-fiscal.idi-sit-nf-eletro = 3,
       FIRST estabelec NO-LOCK
       WHERE estabelec.cod-estabel   = docum-est.cod-estabel,
       FIRST nota-fiscal NO-LOCK
       WHERE nota-fiscal.cod-estabel  = cst_fat_devol.cod_estab_comp  
         AND nota-fiscal.serie        = cst_fat_devol.serie_comp
         AND nota-fiscal.nr-nota-fis  = cst_fat_devol.nro_comp,
       FIRST cst_nota_fiscal NO-LOCK
       WHERE cst_nota_fiscal.cod_estabel = nota-fiscal.cod-estabel 
         AND cst_nota_fiscal.serie       = nota-fiscal.serie       
         AND cst_nota_fiscal.nr_nota_fis = nota-fiscal.nr-nota-fis,
       FIRST emitente NO-LOCK
       WHERE emitente.cgc = cst_nota_fiscal.cpf_cupom
    BREAK BY docum-est.cod-estab:

        RUN pi-acompanhar IN h-acomp (INPUT "Data/Cupom: " + STRING(docum-est.dt-emissao,"99/99/9999") + " - " + STRING(docum-est.nro-docto)).

        CREATE tt-devolucao-convenio.
        ASSIGN tt-devolucao-convenio.cod-estab     = docum-est.cod-estab    
               tt-devolucao-convenio.cod-emitente  = emitente.cod-emitente 
               tt-devolucao-convenio.serie-docto   = docum-est.serie-docto  
               tt-devolucao-convenio.nro-docto     = docum-est.nro-docto    
               tt-devolucao-convenio.nat-operacao  = docum-est.nat-operacao 
               tt-devolucao-convenio.cod-parcela   = cst_fat_devol.parcela
               tt-devolucao-convenio.cod-portador  = cst_fat_devol.cod_portador
               tt-devolucao-convenio.val-devolucao = cst_fat_devol.vl_devolucao
               tt-devolucao-convenio.dat-emissao   = docum-est.dt-emis
               tt-devolucao-convenio.dat-trans     = docum-est.dt-trans
               tt-devolucao-convenio.nota-devol    = cst_fat_devol.nro_comp
               tt-devolucao-convenio.serie-devol   = cst_fat_devol.serie_comp
               tt-devolucao-convenio.r-fat-devol   = ROWID(cst_fat_devol)
               tt-devolucao-convenio.cod-estab-ori = cst_fat_devol.cod_estab_comp
               tt-devolucao-convenio.dat-emiss-ori = nota-fiscal.dt-emis-nota
            .                                                                

        IF tt-devolucao-convenio.cod-estab-ori <> tt-devolucao-convenio.cod-estab THEN
             ASSIGN tt-devolucao-convenio.l-estab-dif = YES.
        ELSE ASSIGN tt-devolucao-convenio.l-estab-dif = NO.
        
    END.
END PROCEDURE. /* pi-carrega-movto-convenio */


PROCEDURE pi_retorna_sugestao_referencia:

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
                       + substring(v_des_dat,7,2)
                       + substring(v_des_dat,3,2)
/*                        + substring(v_des_dat,1,2) */
                       
           v_num_aux_2 = integer(this-procedure:handle).

    do  v_num_cont = 1 to 4:
        assign v_num_aux   = (random(0,v_num_aux_2) mod 26) + 97
               p_cod_refer = p_cod_refer + CAPS(chr(v_num_aux)).
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

PROCEDURE pi_verifica_refer_unica_acr:

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

PROCEDURE pi-cria-tt-erro:

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

PROCEDURE pi-mostra-titulos-criados:

    FOR EACH tt-tit-criados:
        DISP tt-tit-criados.cod_estab          
             tt-tit-criados.cod_espec_docto   
             tt-tit-criados.cod_ser_docto     
             tt-tit-criados.cod_tit_acr       
             tt-tit-criados.cod_parcela       
             tt-tit-criados.cdn_cliente       
             tt-tit-criados.cod_portador      
             tt-tit-criados.dat_transacao     
             tt-tit-criados.dat_emis_docto    
             tt-tit-criados.dat_vencto_tit_acr
             tt-tit-criados.val_origin_tit_acr
             tt-tit-criados.situacao          
             WITH WIDTH 555 STREAM-IO DOWN FRAME f-titulo.
                                 DOWN WITH FRAME f-titulo.  

    END.

END PROCEDURE. /* pi-mostra-titulos-criados */

PROCEDURE pi-mostra-erros:

    FOR EACH tt-erro:
           DISP tt-erro.cd-erro
                tt-erro.mensagem FORMAT "x(100)" SKIP
                fill(" ",11) tt-erro.ajuda    FORMAT "x(150)" NO-LABEL
                 WITH WIDTH 333 STREAM-IO DOWN FRAME f-erro.
           DOWN WITH FRAME f-erro.
    END.    
END.


PROCEDURE pi-traduz-estab:

    DEFINE INPUT  PARAM p-cod_matriz_trad_org_ext AS CHARACTER FORMAT "x(8)" NO-UNDO.
    DEFINE INPUT  PARAM p-cod-estab-ems-2         AS CHARACTER               NO-UNDO.
    DEFINE OUTPUT PARAM p-cod-estab-ems-5         AS CHARACTER               NO-UNDO.
    DEFINE OUTPUT PARAM c-erro                    AS CHAR                    NO-UNDO.

    FIND FIRST tip_unid_organ 
         where tip_unid_organ.num_niv_unid_organ = 999 no-lock no-error.
    IF AVAIL tip_unid_organ then do:
        FIND FIRST trad_org_ext USE-INDEX trdrgxt_id 
            WHERE  trad_org_ext.cod_matriz_trad_org_ext = p-cod_matriz_trad_org_ext 
              AND  trad_org_ext.cod_tip_unid_organ      = tip_unid_organ.cod_tip_unid_organ 
              AND  trad_org_ext.cod_unid_organ          = p-cod-estab-ems-2 NO-LOCK NO-ERROR.
        IF AVAIL trad_org_ext THEN
            assign p-cod-estab-ems-5 = trad_org_ext.cod_unid_organ_ext.
        ELSE DO:
            ASSIGN c-erro = "Matriz Tradu»’o Estabelecimento N’o Cadastrado. Estab: " + STRING(p-cod-estab-ems-2).

            RETURN "NOK".
        END.
    END.

    RETURN "OK".

END PROCEDURE.

PROCEDURE pi-traduz-empresa:
    
    DEFINE INPUT  PARAM p-cod_matriz_trad_org_ext AS CHARACTER FORMAT "x(8)" NO-UNDO.
    DEFINE INPUT  PARAM p-empresa-ems2            AS INTEGER   FORMAT ">>9"  NO-UNDO.
    DEFINE OUTPUT PARAM p-empresa-ems5            AS CHARACTER               NO-UNDO.
    DEFINE OUTPUT PARAM c-erro                    AS CHAR                    NO-UNDO.

    FOR FIRST trad_org_ext FIELDS(cod_unid_organ) NO-LOCK USE-INDEX trdrgxt_id
        WHERE trad_org_ext.cod_matriz_trad_org_ext = p-cod_matriz_trad_org_ext
          AND trad_org_ext.cod_tip_unid_organ      = "998"
          AND trad_org_ext.cod_unid_organ_ext      = STRING(p-empresa-ems2):
        
        ASSIGN p-empresa-ems5 = trad_org_ext.cod_unid_organ.
    END.

    IF p-empresa-ems5 = "" THEN DO:
        ASSIGN c-erro = "Matriz Tradu»’o Empresa N’o Cadastrada. Empresa: " + string(p-empresa-ems2).

        RETURN "NOK".
    END.

    RETURN "OK".

END PROCEDURE.

PROCEDURE piCriaAlteracaoTaxaCartao:
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    DEF INPUT  PARAM p-cod-estab         AS CHAR                                 NO-UNDO.
    DEF INPUT  PARAM p-tit-acr           AS INT                                  NO-UNDO.
    DEF INPUT  PARAM p-tipo              AS CHAR                                 NO-UNDO.
    DEF INPUT  PARAM p-valor             AS DECIMAL                              NO-UNDO.
    DEF INPUT  PARAM p-historico         AS CHAR  FORMAT "x(2000)"               NO-UNDO.
    DEF OUTPUT PARAM l-erro              AS LOGICAL  INITIAL NO                  NO-UNDO.

    DEFINE VARIABLE c_cod_refer       AS CHARACTER                    NO-UNDO.
    DEFINE VARIABLE v_hdl_program     AS HANDLE    FORMAT ">>>>>>9":U NO-UNDO.
    DEFINE VARIABLE v_log_integr_cmg  AS LOGICAL   FORMAT "Sim/NÆo":U INITIAL NO LABEL "CMG" COLUMN-LABEL "CMG" NO-UNDO.

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

    ASSIGN c_cod_refer = "".
    RUN pi_retorna_sugestao_referencia (INPUT  "TX",
                                        INPUT  TODAY,
                                        OUTPUT c_cod_refer,
                                        INPUT  "tit_acr",
                                        INPUT  STRING(tit_acr.cod_estab)).

    ASSIGN tt_alter_tit_acr_base_5.tta_dat_transacao               = tit_acr.dat_transacao
           tt_alter_tit_acr_base_5.tta_cod_refer                   = CAPS(c_cod_refer)
           tt_alter_tit_acr_base_5.ttv_cod_motiv_movto_tit_acr_imp = ?
           tt_alter_tit_acr_base_5.tta_val_sdo_tit_acr             = tit_acr.val_sdo_tit_acr - p-valor
           tt_alter_tit_acr_base_5.tta_val_liq_tit_acr             = tt_alter_tit_acr_base_5.tta_val_sdo_tit_acr
           tt_alter_tit_acr_base_5.ttv_cod_motiv_movto_tit_acr_alt = p-tipo
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
        ASSIGN l-erro = YES.
    END.
    ELSE ASSIGN l-erro = NO.
END PROCEDURE. /* piCriaAlteracaoTaxaCartao */

PROCEDURE WinExec EXTERNAL "kernel32" :
    DEF INPUT PARAM lpszCmdLine AS CHAR.
    DEF INPUT PARAM fuCmdShow AS LONG.
END PROCEDURE.

