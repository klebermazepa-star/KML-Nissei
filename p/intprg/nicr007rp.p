/********************************************************************************
*******************************************************************************/
{include/i-prgvrs.i NICR007RP 2.06.00.001}  
{include/i_fnctrad.i}
/******************************************************************************
**
**       PROGRAMA: NICR007RP
**
**       DATA....: 01/2016
**
**       OBJETIVO: Importa‡Æo das Liquida‡äes de Cheque e Dinheiro atrav‚s do
                   arquivo enviado pela empresa de transportes de valores.
**
**       VERSAO..: 2.06.001
** 
******************************************************************************/
DEFINE BUFFER portador         FOR ems5.portador.
DEFINE BUFFER bf_movto_tit_acr FOR movto_tit_acr.

{include/i-rpvar.i}
{include/i-rpcab.i}
{intprg/nicr007rp.i}
/* {utp/ut-glob.i} */ 
    
 def new Global shared var c-seg-usuario        as char format "x(12)" no-undo.

{method/dbotterr.i} 
/*{cdp/cd0666.i}       Definicao da temp-table de erros */

define temp-table tt-param no-undo
    field destino          as integer
    field arquivo          as char format "x(35)"
    field usuario          as char format "x(12)"
    field data-exec        as date
    field hora-exec        as integer
    field classifica       as integer
    field desc-classifica  as char format "x(40)"
    field modelo-rtf       as char format "x(35)"
    field l-habilitaRtf    as LOG
    FIELD estab-ini        LIKE tit_acr.cod_estab
    FIELD estab-fim        LIKE tit_acr.cod_estab
    FIELD data-ini         LIKE tit_acr.dat_emis_docto
    FIELD data-fim         LIKE tit_acr.dat_emis_docto
.

def new global shared var v_cod_usuar_corren
    as character
    format "x(12)":U
    label "Usuÿrio Corrente"
    column-label "Usuÿrio Corrente"
    no-undo.

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


def var c-acompanha    as char    no-undo.
DEF VAR h-acomp        AS HANDLE  NO-UNDO.
DEF VAR c-nom-arq      AS CHAR    NO-UNDO.
DEF VAR c-data         AS CHAR    NO-UNDO.
DEF VAR i-cont         AS INTEGER NO-UNDO.
DEF VAR i-linha        AS INTEGER NO-UNDO.

DEF VAR v_hdl_program     AS HANDLE  FORMAT ">>>>>>9":U NO-UNDO.
DEF var v_log_integr_cmg  AS LOGICAL FORMAT "Sim/NÆo":U INITIAL NO LABEL "CMG" COLUMN-LABEL "CMG" NO-UNDO.

def var c_cod_table               as character         format "x(8)"                no-undo.
def var w_estabel                 as character         format "x(3)"                no-undo.
def var c-cod-refer               as character         format "x(10)"               no-undo.
def var v_log_refer_uni           as log                                            no-undo.

DEFINE TEMP-TABLE tt-int_ds_furo_caixa LIKE int_ds_furo_caixa
    FIELD r-rowid AS ROWID.

find first param-estoq  no-lock no-error.
find first param-global no-lock no-error.
find first ems2mult.empresa where 
           empresa.ep-codigo = param-global.empresa-prin no-lock no-error.

assign c-programa = "NICR007"
       c-versao   = "2.06"
       c-revisao  = "001"
       c-empresa  = empresa.razao-social.

find first tt-param no-lock no-error.
{include/i-rpout.i}
{utp/ut-liter.i Integra‡Æo_Furo_Caixa * L}
assign c-titulo-relat = trim(return-value).
{utp/ut-liter.i Contas_Receber * L}
assign c-sistema = trim(return-value).

VIEW frame f-cabec.
view frame f-rodape.

RUN utp/ut-acomp.p PERSISTENT SET h-acomp.
RUN pi-inicializar IN h-acomp (INPUT "Integra‡Æo Furo Caixa").
                    
/* log-manager:logfile-name= "\\192.168.200.52\datasul\_custom_teste\Prog_QG\FuroCaixa.txt".  */
/* log-manager:log-entry-types= "4gltrace".                                                   */

FOR EACH int_ds_furo_caixa
   WHERE int_ds_furo_caixa.situacao     = 1 
     AND int_ds_furo_caixa.cod_estab   >= tt-param.estab-ini
     AND int_ds_furo_caixa.cod_estab   <= tt-param.estab-fim
     AND int_ds_furo_caixa.dat_bordero >= tt-param.data-ini
     AND int_ds_furo_caixa.dat_bordero <= tt-param.data-fim  NO-LOCK:

    CREATE tt-int_ds_furo_caixa.
    BUFFER-COPY int_ds_furo_caixa TO tt-int_ds_furo_caixa.
    ASSIGN tt-int_ds_furo_caixa.r-rowid = ROWID(int_ds_furo_caixa).
    
    IF int_ds_furo_caixa.cod_estab = "401" THEN
        ASSIGN tt-int_ds_furo_caixa.cod_estab = "014".

    RUN pi-acompanhar IN h-acomp (INPUT "Estab/Data/Cupom: " + STRING(int_ds_furo_caixa.cod_estab) + " - " + STRING(int_ds_furo_caixa.dat_bordero,"99/99/9999") + " - " + STRING(int_ds_furo_caixa.num_bordero)).

END.

/* RUN pi-seta-titulo IN h-acomp (INPUT "Processando - Sinistro":U). */
/* RUN pi-movto-sinistro.                                            */
RUN pi-seta-titulo IN h-acomp (INPUT "Processando - Vale":U).
RUN pi-movto-vale.
/* RUN pi-seta-titulo IN h-acomp (INPUT "Processando - Fundo Fixo":U). */
/* RUN pi-movto-fundofixo.                                             */

RUN pi-seta-titulo IN h-acomp (INPUT "Imprimindo Erros":U).
RUN pi-mostra-erros.

RUN intprg/int888.p (INPUT "FuroCX",
                     INPUT "NICR007RP.P").

RUN pi-finalizar IN h-acomp.                       


/* log-manager:close-log().  */

{include/i-rpclo.i}   

return "OK":U.

PROCEDURE pi-movto-sinistro:
    DEFINE VARIABLE indSeq AS INTEGER     NO-UNDO.

    FOR EACH tt-int_ds_furo_caixa
       WHERE tt-int_ds_furo_caixa.tip_furo = "SINISTRO":

        FIND FIRST tit_acr NO-LOCK 
             WHERE tit_acr.cod_estab       = tt-int_ds_furo_caixa.cod_estab
               AND tit_acr.cod_espec_docto = "DI"
               AND tit_acr.cod_tit_acr     = "DINH" + REPLACE(STRING(tt-int_ds_furo_caixa.dat_bordero,"99/99/99"),"/","") NO-ERROR.
        IF AVAIL tit_acr THEN DO:

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

            RUN pi_retorna_sugestao_referencia (INPUT  "SN",
                                                INPUT  TODAY,
                                                OUTPUT c-cod-refer,
                                                INPUT  "tit_acr",
                                                INPUT  STRING(tit_acr.cod_estab)).

            ASSIGN tt_alter_tit_acr_base_5.tta_dat_transacao               = tit_acr.dat_transacao
                   tt_alter_tit_acr_base_5.tta_cod_refer                   = c-cod-refer
                   tt_alter_tit_acr_base_5.ttv_cod_motiv_movto_tit_acr_imp = ?
                   tt_alter_tit_acr_base_5.tta_val_sdo_tit_acr             = tit_acr.val_sdo_tit_acr - tt-int_ds_furo_caixa.vl_furo
                   tt_alter_tit_acr_base_5.ttv_cod_motiv_movto_tit_acr_alt = "SINISTRO"
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
                   tt_alter_tit_acr_base_5.ttv_des_text_histor             = "Colaborador: " + STRING(tt-int_ds_furo_caixa.mat_colabor)
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


                    RUN intprg/int999.p (INPUT "FuroCX", 
                                         INPUT string(tt-int_ds_furo_caixa.cod_estab) + "-" + string(tt-int_ds_furo_caixa.num_bordero) + "-" + string(tt-int_ds_furo_caixa.mat_colab),
                                         INPUT "Registro nÆo Integrado." + " Estab.: " + string(tt-int_ds_furo_caixa.cod_estab) + 
                                                                           " Nr. Border“: " + string(tt-int_ds_furo_caixa.num_bordero) + 
                                                                           " Matr¡cula: " + string(tt-int_ds_furo_caixa.mat_colab)     +
                                                                           " Data Movto: " + STRING(tt-int_ds_furo_caixa.dat_bordero)     + ".  " +
                                                                           " Valor: " + STRING(tt-int_ds_furo_caixa.vl_furo) +    
                                                                           " . Erro: " + STRING(tt_log_erros_alter_tit_acr.ttv_num_mensagem)         + " - " +
                                                                           STRING(tt_log_erros_alter_tit_acr.ttv_des_msg_erro) + STRING(tt_log_erros_alter_tit_acr.ttv_des_msg_ajuda)
                                                                               ,
                                         INPUT 1, /* 1 - Pendente ou 2 - Integrado */
                                         INPUT c-seg-usuario,
                                         INPUT "NICR007RP.P").
                END.



            END.
            ELSE DO:
                FIND FIRST int_ds_furo_caixa EXCLUSIVE-LOCK
                     WHERE ROWID(int_ds_furo_caixa) = tt-int_ds_furo_caixa.r-rowid NO-ERROR.
                IF AVAIL int_ds_furo_caixa THEN DO:

                    ASSIGN int_ds_furo_caixa.situacao = 2.

                    RUN intprg/int999.p (INPUT "FuroCX", 
                                         INPUT string(tt-int_ds_furo_caixa.cod_estab) + "-" + string(tt-int_ds_furo_caixa.num_bordero)+ "-" + string(tt-int_ds_furo_caixa.mat_colab),
                                         INPUT "Registro Integrado." + " Estab.: " + string(tt-int_ds_furo_caixa.cod_estab) + 
                                                                       " Nr. Border“: " + string(tt-int_ds_furo_caixa.num_bordero) + 
                                                                       " Matr¡cula: " + string(tt-int_ds_furo_caixa.mat_colab)     +
                                                                       " Data Movto: " + STRING(tt-int_ds_furo_caixa.dat_bordero)  +
                                                                       " Valor: " + STRING(tt-int_ds_furo_caixa.vl_furo)    ,
                                         INPUT 2, /* 1 - Pendente ou 2 - Integrado */
                                         INPUT c-seg-usuario,
                                         INPUT "NICR007RP.P").

                    /* INICIO - Gera Tabela Conferencia do Furo de Caixa */
                    FIND LAST bf_movto_tit_acr NO-LOCK
                        WHERE bf_movto_tit_acr.num_id_tit_acr = tit_acr.num_id_tit_acr 
                          AND bf_movto_tit_acr.ind_trans_acr_abrev = "AVMN"       NO-ERROR.
                    IF AVAIL bf_movto_tit_acr THEN DO:

                        ASSIGN indSeq = 1.

                        FOR LAST cst_furo_caixa
                           WHERE cst_furo_caixa.codigo= INT(int_ds_furo_caixa.num_bordero) NO-LOCK:
                            ASSIGN indSeq = cst_furo_caixa.ind_sequencia + 1.
                        END.
                        
                        CREATE cst_furo_caixa.
                        ASSIGN cst_furo_caixa.codigo               = INT(int_ds_furo_caixa.num_bordero)
                               cst_furo_caixa.cod_estab            = int_ds_furo_caixa.cod_estab    
                               cst_furo_caixa.dat_bordero          = int_ds_furo_caixa.dat_bordero   
                               cst_furo_caixa.des_observ           = int_ds_furo_caixa.des_observ   
                               cst_furo_caixa.ind_sequencia        = indSeq
                               cst_furo_caixa.mat_colabor          = int_ds_furo_caixa.mat_colabor
                               cst_furo_caixa.num_bo               = 0
                               cst_furo_caixa.num_bordero          = int_ds_furo_caixa.num_bordero  
                               cst_furo_caixa.num_id_movto_tit_acr = bf_movto_tit_acr.num_id_movto_tit_acr
                               cst_furo_caixa.num_id_tit_acr       = bf_movto_tit_acr.num_id_tit_acr     
                               cst_furo_caixa.situacao             = 1
                               cst_furo_caixa.tip_furo             = int_ds_furo_caixa.tip_furo
                               cst_furo_caixa.vl_furo              = int_ds_furo_caixa.vl_furo
                               cst_furo_caixa.nome_func            = int_ds_furo_caixa.nome_func
                            .
                    END.
                    /* FIM - Gera Tabela Conferencia do Furo de Caixa */
                    
                    DISP tt-int_ds_furo_caixa.cod_estab
                         tt-int_ds_furo_caixa.num_bordero
                         tt-int_ds_furo_caixa.dat_bordero
                         tt-int_ds_furo_caixa.tip_furo
                         tt-int_ds_furo_caixa.vl_furo
                         "SIM" COLUMN-LABEL "Gerada Movto.?"
                        WITH WIDTH 333 STREAM-IO DOWN FRAME f-inv.
                    DOWN WITH FRAME f-inv.

                    RELEASE int_ds_furo_caixa.
                END.
            END. /* */
        END.
        ELSE DO:
            RUN pi-cria-tt-erro(INPUT 1,
                                INPUT 17006,
                                INPUT "Estab/Especie/Titulo: " + string(tt-int_ds_furo_caixa.cod_estab) + "/DI/" + "DINH" + REPLACE(STRING(tt-int_ds_furo_caixa.dat_bordero,"99/99/99"),"/","") + " , nÆo foi encontrado.",
                                INPUT "Estab/Especie/Titulo: " + string(tt-int_ds_furo_caixa.cod_estab) + "/DI/" + "DINH" + REPLACE(STRING(tt-int_ds_furo_caixa.dat_bordero,"99/99/99"),"/","") + " , nÆo foi encontrado.").                
        END.



    END.

END PROCEDURE.

PROCEDURE pi-movto-vale:
    DEFINE VARIABLE indSeq AS INTEGER     NO-UNDO.
    DEFINE VARIABLE d-dt-transacao LIKE tit_acr.dat_transacao NO-UNDO.

    DEFINE BUFFER b_movto_tit_acr FOR movto_tit_acr.

    FOR EACH tt-int_ds_furo_caixa
       WHERE tt-int_ds_furo_caixa.tip_furo = "VALE" OR
             tt-int_ds_furo_caixa.tip_furo = "VALEGER"  :

        RUN pi-acompanhar IN h-acomp (INPUT "Estab/Data/Cupom: " + STRING(tt-int_ds_furo_caixa.cod_estab) + " - " + STRING(tt-int_ds_furo_caixa.dat_bordero,"99/99/9999") + " - " + STRING(tt-int_ds_furo_caixa.num_bordero)).

        /* INICIO - Valida‡Æo da Matricula do Funcionario que fez o FURO de Caixa */
        IF AVAIL tt-int_ds_furo_caixa THEN DO:
            IF tt-int_ds_furo_caixa.mat_colabor = "0" OR tt-int_ds_furo_caixa.mat_colabor = ? OR tt-int_ds_furo_caixa.mat_colabor = "" THEN DO:
                RUN pi-cria-tt-erro(INPUT 1,
                                    INPUT 17006,
                                    INPUT " Estab.: " + string(tt-int_ds_furo_caixa.cod_estab) + 
                                          " Nr. Border“: " + string(tt-int_ds_furo_caixa.num_bordero) + 
                                          " Matr¡cula: " + string(tt-int_ds_furo_caixa.mat_colab)     +
                                          " Data Movto: " + STRING(tt-int_ds_furo_caixa.dat_bordero)     + ".  " +
                                          " Valor: "  + STRING(tt-int_ds_furo_caixa.vl_furo) +    
                                          " . Erro: " + STRING(17006)         + " - " +
                                          " - Furo de Caixa nÆo integrado, devido a Matricula Invalida.",
                                    INPUT " Estab.: " + string(tt-int_ds_furo_caixa.cod_estab) + 
                                          " Nr. Border“: " + string(tt-int_ds_furo_caixa.num_bordero) + 
                                          " Matr¡cula: " + string(tt-int_ds_furo_caixa.mat_colab)     +
                                          " Data Movto: " + STRING(tt-int_ds_furo_caixa.dat_bordero)     + ".  " +
                                          " Valor: "  + STRING(tt-int_ds_furo_caixa.vl_furo) +    
                                          " . Erro: " + STRING(17006)         + " - " +
                                          " - Furo de Caixa nÆo integrado, devido a Matricula Invalida.").               

                RUN intprg/int999.p (INPUT "FuroCX", 
                                     INPUT string(tt-int_ds_furo_caixa.cod_estab) + "-" + string(tt-int_ds_furo_caixa.num_bordero) + "-" + string(tt-int_ds_furo_caixa.mat_colab),
                                     INPUT "Registro nÆo Integrado." + " Estab.: " + string(tt-int_ds_furo_caixa.cod_estab) + 
                                                                       " Nr. Border“: " + string(tt-int_ds_furo_caixa.num_bordero) + 
                                                                       " Matr¡cula: " + string(tt-int_ds_furo_caixa.mat_colab)     +
                                                                       " Data Movto: " + STRING(tt-int_ds_furo_caixa.dat_bordero)     + ".  " +
                                                                       " Valor: "  + STRING(tt-int_ds_furo_caixa.vl_furo) +    
                                                                       " . Erro: " + STRING(17006)         + " - " +
                                                                       " - Furo de Caixa nÆo integrado, devido a Matricula Invalida."
                                                                           ,
                                     INPUT 1, /* 1 - Pendente ou 2 - Integrado */
                                     INPUT c-seg-usuario,
                                     INPUT "NICR007RP.P").

                NEXT.
            END.
            ELSE DO:
/*                 FIND FIRST VR034FUN NO-LOCK                                                                                                                                            */
/*                      WHERE VR034FUN.NUMCAD = INT(tt-int_ds_furo_caixa.mat_colabor) NO-ERROR.                                                                                           */
/*                 IF NOT AVAIL VR034FUN THEN DO:                                                                                                                                         */
/*                     RUN pi-cria-tt-erro(INPUT 1,                                                                                                                                       */
/*                                         INPUT 17006,                                                                                                                                   */
/*                                         INPUT " Estab.: " + string(tt-int_ds_furo_caixa.cod_estab) +                                                                                   */
/*                                               " Nr. Border“: " + string(tt-int_ds_furo_caixa.num_bordero) +                                                                            */
/*                                               " Matr¡cula: " + string(tt-int_ds_furo_caixa.mat_colab)     +                                                                            */
/*                                               " Data Movto: " + STRING(tt-int_ds_furo_caixa.dat_bordero)     + ".  " +                                                                 */
/*                                               " Valor: "  + STRING(tt-int_ds_furo_caixa.vl_furo) +                                                                                     */
/*                                               " . Erro: " + STRING(17006)         + " - " +                                                                                            */
/*                                               " - Furo de Caixa nÆo integrado, devido a Matricula Invalida.",                                                                          */
/*                                         INPUT " Estab.: " + string(tt-int_ds_furo_caixa.cod_estab) +                                                                                   */
/*                                               " Nr. Border“: " + string(tt-int_ds_furo_caixa.num_bordero) +                                                                            */
/*                                               " Matr¡cula: " + string(tt-int_ds_furo_caixa.mat_colab)     +                                                                            */
/*                                               " Data Movto: " + STRING(tt-int_ds_furo_caixa.dat_bordero)     + ".  " +                                                                 */
/*                                               " Valor: "  + STRING(tt-int_ds_furo_caixa.vl_furo) +                                                                                     */
/*                                               " . Erro: " + STRING(17006)         + " - " +                                                                                            */
/*                                               " - Furo de Caixa nÆo integrado, devido a Matricula Invalida.").                                                                         */
/*                                                                                                                                                                                        */
/*                     RUN intprg/int999.p (INPUT "FuroCX",                                                                                                                               */
/*                                          INPUT string(tt-int_ds_furo_caixa.cod_estab) + "-" + string(tt-int_ds_furo_caixa.num_bordero) + "-" + string(tt-int_ds_furo_caixa.mat_colab), */
/*                                          INPUT "Registro nÆo Integrado." + " Estab.: " + string(tt-int_ds_furo_caixa.cod_estab) +                                                      */
/*                                                                            " Nr. Border“: " + string(tt-int_ds_furo_caixa.num_bordero) +                                               */
/*                                                                            " Matr¡cula: " + string(tt-int_ds_furo_caixa.mat_colab)     +                                               */
/*                                                                            " Data Movto: " + STRING(tt-int_ds_furo_caixa.dat_bordero)     + ".  " +                                    */
/*                                                                            " Valor: "  + STRING(tt-int_ds_furo_caixa.vl_furo) +                                                        */
/*                                                                            " . Erro: " + STRING(17006)         + " - " +                                                               */
/*                                                                            " - Furo de Caixa nÆo integrado, devido a Matricula Invalida."                                              */
/*                                                                                ,                                                                                                       */
/*                                          INPUT 1, /* 1 - Pendente ou 2 - Integrado */                                                                                                  */
/*                                          INPUT c-seg-usuario,                                                                                                                          */
/*                                          INPUT "NICR007RP.P").                                                                                                                         */
/*                                                                                                                                                                                        */
/*                     NEXT.                                                                                                                                                              */
/*                 END.                                                                                                                                                                   */
            END.
        END.
        /* FIM    - Valida‡Æo da Matricula do Funcionario que fez o FURO de Caixa */

        FIND FIRST tit_acr NO-LOCK USE-INDEX titacr_id
             WHERE tit_acr.cod_estab           = tt-int_ds_furo_caixa.cod_estab
               AND tit_acr.cod_espec_docto     = "DI"
               AND tit_acr.cod_tit_acr         = "DINH" + REPLACE(STRING(tt-int_ds_furo_caixa.dat_bordero,"99/99/99"),"/","")
               AND tit_acr.log_tit_acr_estordo = NO
               AND tit_acr.log_sdo_tit_acr     = YES 
               AND tit_acr.val_sdo_tit_acr    >= tt-int_ds_furo_caixa.vl_furo
            NO-ERROR.
        IF AVAIL tit_acr THEN DO:

            RUN pi-acompanhar IN h-acomp (INPUT "Estab/Data/Cupom: " + STRING(tt-int_ds_furo_caixa.cod_estab) + " - " + STRING(tt-int_ds_furo_caixa.dat_bordero,"99/99/9999") + " - " + STRING(tt-int_ds_furo_caixa.num_bordero) + " - 1 ").

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

            RUN pi_retorna_sugestao_referencia (INPUT  "VL",
                                                INPUT  TODAY,
                                                OUTPUT c-cod-refer,
                                                INPUT  "tit_acr",
                                                INPUT  STRING(tit_acr.cod_estab)).

            RUN pi-acompanhar IN h-acomp (INPUT "Estab/Data/Cupom: " + STRING(tt-int_ds_furo_caixa.cod_estab) + " - " + STRING(tt-int_ds_furo_caixa.dat_bordero,"99/99/9999") + " - " + STRING(tt-int_ds_furo_caixa.num_bordero) + " - 2 ").

            /* INICIO - Verifica‡Æo da Data de Transa‡Æo, para sempre pegar £ltima */
            ASSIGN d-dt-transacao = ?.
            FIND LAST b_movto_tit_acr NO-LOCK
                WHERE b_movto_tit_acr.cod_estab             = tit_acr.cod_estab
                  AND b_movto_tit_acr.num_id_tit_acr        = tit_acr.num_id_tit_acr
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

            RUN pi-acompanhar IN h-acomp (INPUT "Estab/Data/Cupom: " + STRING(tt-int_ds_furo_caixa.cod_estab) + " - " + STRING(tt-int_ds_furo_caixa.dat_bordero,"99/99/9999") + " - " + STRING(tt-int_ds_furo_caixa.num_bordero) + " - 3 ").


            ASSIGN tt_alter_tit_acr_base_5.tta_dat_transacao               = d-dt-transacao
                   tt_alter_tit_acr_base_5.tta_cod_refer                   = c-cod-refer
                   tt_alter_tit_acr_base_5.ttv_cod_motiv_movto_tit_acr_imp = ?
                   tt_alter_tit_acr_base_5.tta_val_sdo_tit_acr             = tit_acr.val_sdo_tit_acr - tt-int_ds_furo_caixa.vl_furo
                   tt_alter_tit_acr_base_5.ttv_cod_motiv_movto_tit_acr_alt = tt-int_ds_furo_caixa.tip_furo
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
                   tt_alter_tit_acr_base_5.ttv_des_text_histor             = "Colaborador: " + STRING(tt-int_ds_furo_caixa.mat_colabor)
                   tt_alter_tit_acr_base_5.tta_cdn_repres                  = tit_acr.cdn_repres
                   tt_alter_tit_acr_base_5.tta_cod_instruc_bcia_1_movto    = tit_acr.cod_instruc_bcia_1_acr  
                   tt_alter_tit_acr_base_5.tta_cod_instruc_bcia_2_movto    = tit_acr.cod_instruc_bcia_2_acr
                   .

            RUN pi-acompanhar IN h-acomp (INPUT "Estab/Data/Cupom: " + STRING(tt-int_ds_furo_caixa.cod_estab) + " - " + STRING(tt-int_ds_furo_caixa.dat_bordero,"99/99/9999") + " - " + STRING(tt-int_ds_furo_caixa.num_bordero) + " - 4 ").
            
            run prgfin/acr/acr711zv.py persistent set v_hdl_program /*prg_api_integr_acr_alter_tit_acr_novo_7*/.
            RUN pi_main_code_integr_acr_alter_tit_acr_novo_12 in v_hdl_program (Input 12,
                                                                                Input table tt_alter_tit_acr_base_5,
                                                                                Input table tt_alter_tit_acr_rateio,
                                                                                Input table tt_alter_tit_acr_ped_vda,
                                                                                Input table tt_alter_tit_acr_comis_1,
                                                                                Input table tt_alter_tit_acr_cheq,
                                                                                Input table tt_alter_tit_acr_iva,
                                                                                Input table tt_alter_tit_acr_impto_retid_2,
                                                                                Input table tt_alter_tit_acr_cobr_espec_2,
                                                                                Input table tt_alter_tit_acr_rat_desp_rec,
                                                                                output table tt_log_erros_alter_tit_acr,
                                                                                Input v_log_integr_cmg) /*pi_main_code_integr_acr_alter_tit_acr_novo_12*/.
            delete procedure v_hdl_program.

            RUN pi-acompanhar IN h-acomp (INPUT "Estab/Data/Cupom: " + STRING(tt-int_ds_furo_caixa.cod_estab) + " - " + STRING(tt-int_ds_furo_caixa.dat_bordero,"99/99/9999") + " - " + STRING(tt-int_ds_furo_caixa.num_bordero) + " - 5 ").

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


                    RUN intprg/int999.p (INPUT "FuroCX", 
                                         INPUT string(tt-int_ds_furo_caixa.cod_estab) + "-" + string(tt-int_ds_furo_caixa.num_bordero) + "-" + string(tt-int_ds_furo_caixa.mat_colab),
                                         INPUT "Registro nÆo Integrado." + " Estab.: " + string(tt-int_ds_furo_caixa.cod_estab) + 
                                                                           " Nr. Border“: " + string(tt-int_ds_furo_caixa.num_bordero) + 
                                                                           " Matr¡cula: " + string(tt-int_ds_furo_caixa.mat_colab)     +
                                                                           " Data Movto: " + STRING(tt-int_ds_furo_caixa.dat_bordero)     + ".  " +
                                                                           " Valor: "  + STRING(tt-int_ds_furo_caixa.vl_furo) +    
                                                                           " . Erro: " + STRING(tt_log_erros_alter_tit_acr.ttv_num_mensagem)         + " - " +
                                                                           STRING(tt_log_erros_alter_tit_acr.ttv_des_msg_erro) + STRING(tt_log_erros_alter_tit_acr.ttv_des_msg_ajuda)
                                                                               ,
                                         INPUT 1, /* 1 - Pendente ou 2 - Integrado */
                                         INPUT c-seg-usuario,
                                         INPUT "NICR007RP.P").
                END.

            END.
            ELSE DO:
                FIND FIRST int_ds_furo_caixa EXCLUSIVE-LOCK
                     WHERE ROWID(int_ds_furo_caixa) = tt-int_ds_furo_caixa.r-rowid NO-ERROR.
                IF AVAIL int_ds_furo_caixa THEN DO:

                    ASSIGN int_ds_furo_caixa.situacao = 2.


                    RUN intprg/int999.p (INPUT "FuroCX", 
                                         INPUT string(tt-int_ds_furo_caixa.cod_estab) + "-" + string(tt-int_ds_furo_caixa.num_bordero) + "-" + string(tt-int_ds_furo_caixa.mat_colab),
                                         INPUT "Registro nÆo Integrado." + " Estab.: " + string(tt-int_ds_furo_caixa.cod_estab) + 
                                                                           " Nr. Border“: " + string(tt-int_ds_furo_caixa.num_bordero) + 
                                                                           " Matr¡cula: " + string(tt-int_ds_furo_caixa.mat_colab)     +
                                                                           " Data Movto: " + STRING(tt-int_ds_furo_caixa.dat_bordero)     + ".  " +
                                                                           " Valor: " + STRING(tt-int_ds_furo_caixa.vl_furo),    
                                         INPUT 2, /* 1 - Pendente ou 2 - Integrado */
                                         INPUT c-seg-usuario,
                                         INPUT "NICR007RP.P").

                    /* INICIO - Gera Tabela Conferencia do Furo de Caixa */
                    FIND LAST bf_movto_tit_acr NO-LOCK
                        WHERE bf_movto_tit_acr.cod_estab      = tit_acr.cod_estab
                          AND bf_movto_tit_acr.num_id_tit_acr = tit_acr.num_id_tit_acr 
                          AND bf_movto_tit_acr.ind_trans_acr_abrev = "AVMN"       NO-ERROR.
                    IF AVAIL bf_movto_tit_acr THEN DO:
                        
                        ASSIGN indSeq = 1.

                        FOR LAST cst_furo_caixa
                           WHERE cst_furo_caixa.codigo= INT(int_ds_furo_caixa.num_bordero) NO-LOCK:
                            ASSIGN indSeq = cst_furo_caixa.ind_sequencia + 1.
                        END.
                        
                        CREATE cst_furo_caixa.
                        ASSIGN cst_furo_caixa.codigo               = INT(int_ds_furo_caixa.num_bordero)
                               cst_furo_caixa.cod_estab            = int_ds_furo_caixa.cod_estab    
                               cst_furo_caixa.dat_bordero          = int_ds_furo_caixa.dat_bordero   
                               cst_furo_caixa.des_observ           = int_ds_furo_caixa.des_observ   
                               cst_furo_caixa.ind_sequencia        = indSeq
                               cst_furo_caixa.mat_colabor          = int_ds_furo_caixa.mat_colabor
                               cst_furo_caixa.num_bo               = 0
                               cst_furo_caixa.num_bordero          = int_ds_furo_caixa.num_bordero  
                               cst_furo_caixa.num_id_movto_tit_acr = bf_movto_tit_acr.num_id_movto_tit_acr
                               cst_furo_caixa.num_id_tit_acr       = bf_movto_tit_acr.num_id_tit_acr     
                               cst_furo_caixa.situacao             = 1
                               cst_furo_caixa.tip_furo             = int_ds_furo_caixa.tip_furo
                               cst_furo_caixa.vl_furo              = int_ds_furo_caixa.vl_furo 
                               cst_furo_caixa.nome_func            = int_ds_furo_caixa.nome_func
                            .
                    END.
                    /* FIM - Gera Tabela Conferencia do Furo de Caixa */
                    
                    DISP tt-int_ds_furo_caixa.cod_estab
                         tt-int_ds_furo_caixa.num_bordero
                         tt-int_ds_furo_caixa.dat_bordero
                         tt-int_ds_furo_caixa.tip_furo
                         tt-int_ds_furo_caixa.vl_furo
                         "SIM" COLUMN-LABEL "Gerada Movto.?"
                        WITH WIDTH 333 STREAM-IO DOWN FRAME f-inv.
                    DOWN WITH FRAME f-inv.

                    RELEASE int_ds_furo_caixa.
                END.
            END. /* */
        END.
        ELSE DO:
            RUN pi-cria-tt-erro(INPUT 1,
                                INPUT 17006,
                                INPUT "Estab/Especie/Titulo/Valor: " + string(tt-int_ds_furo_caixa.cod_estab) + "/DI/" + "DINH" + REPLACE(STRING(tt-int_ds_furo_caixa.dat_bordero,"99/99/99"),"/","") + "/" + STRING(tt-int_ds_furo_caixa.vl_furo) + ", nÆo foi encontrado.",
                                INPUT "Estab/Especie/Titulo/Valor: " + string(tt-int_ds_furo_caixa.cod_estab) + "/DI/" + "DINH" + REPLACE(STRING(tt-int_ds_furo_caixa.dat_bordero,"99/99/99"),"/","") + "/" + STRING(tt-int_ds_furo_caixa.vl_furo) + " , nÆo foi encontrado.").                
        END.

    END.

END PROCEDURE.

PROCEDURE pi-movto-fundofixo:

    FOR EACH tt-int_ds_furo_caixa
       WHERE tt-int_ds_furo_caixa.tip_furo = "FUNDOFIXO":

        FIND FIRST tit_acr NO-LOCK 
             WHERE tit_acr.cod_estab       = tt-int_ds_furo_caixa.cod_estab
               AND tit_acr.cod_espec_docto = "DI"
               AND tit_acr.cod_tit_acr     = "DINH" + REPLACE(STRING(tt-int_ds_furo_caixa.dat_bordero,"99/99/99"),"/","") NO-ERROR.
        IF AVAIL tit_acr THEN DO:

            empty temp-table tt_integr_acr_liquidac_lote    no-error.
            empty temp-table tt_integr_acr_liq_item_lote    no-error.
            empty temp-table tt_integr_acr_abat_antecip     no-error.
            empty temp-table tt_integr_acr_abat_prev        no-error.
            empty temp-table tt_integr_acr_cheq             no-error.
            empty temp-table tt_integr_acr_liquidac_impto   no-error.
            empty temp-table tt_integr_acr_rel_pend_cheq    no-error.
            empty temp-table tt_integr_acr_liq_aprop_ctbl   no-error.
            empty temp-table tt_integr_acr_liq_desp_rec     no-error.
            empty temp-table tt_integr_acr_aprop_liq_antec  no-error.
            empty temp-table tt_log_erros_import_liquidac   no-error.

            RUN pi_retorna_sugestao_referencia (INPUT  "FC",
                                                INPUT  TODAY,
                                                OUTPUT c-cod-refer,
                                                INPUT  "tit_acr",
                                                INPUT  STRING(tit_acr.cod_estab)).

            create tt_integr_acr_liquidac_lote. 
            assign tt_integr_acr_liquidac_lote.tta_cod_empresa             = tit_acr.cod_empresa
                   tt_integr_acr_liquidac_lote.tta_cod_estab_refer         = tit_acr.cod_estab
                   tt_integr_acr_liquidac_lote.tta_cod_refer               = c-cod-refer
                   tt_integr_acr_liquidac_lote.tta_cod_usuario             = v_cod_usuar_corren
                   tt_integr_acr_liquidac_lote.tta_dat_transacao           = tit_acr.dat_transacao 
                   tt_integr_acr_liquidac_lote.tta_dat_gerac_lote_liquidac = tit_acr.dat_transacao 
                   tt_integr_acr_liquidac_lote.tta_ind_tip_liquidac_acr    = "lote" /*l_lote*/ 
                   tt_integr_acr_liquidac_lote.ttv_rec_lote_liquidac_acr   = recid(tt_integr_acr_liquidac_lote)
                   tt_integr_acr_liquidac_lote.ttv_log_atualiz_refer       = YES  .

            create tt_integr_acr_liq_item_lote.
            assign tt_integr_acr_liq_item_lote.tta_cod_empresa                     = tit_acr.cod_empresa
                   tt_integr_acr_liq_item_lote.tta_cod_estab                       = tit_acr.cod_estab
                   tt_integr_acr_liq_item_lote.tta_cod_espec_docto                 = tit_acr.cod_espec_docto
                   tt_integr_acr_liq_item_lote.tta_cod_ser_docto                   = tit_acr.cod_ser_docto
                   tt_integr_acr_liq_item_lote.tta_num_seq_refer                   = 1
                   tt_integr_acr_liq_item_lote.tta_cod_tit_acr                     = tit_acr.cod_tit_acr
                   tt_integr_acr_liq_item_lote.tta_cod_parcela                     = tit_acr.cod_parcela
                   tt_integr_acr_liq_item_lote.tta_cod_indic_econ                  = tit_acr.cod_indic_econ
                   tt_integr_acr_liq_item_lote.tta_dat_cr_liquidac_tit_acr         = tt-int_ds_furo_caixa.dat_bordero
                   tt_integr_acr_liq_item_lote.tta_dat_liquidac_tit_acr            = tt-int_ds_furo_caixa.dat_bordero
                   tt_integr_acr_liq_item_lote.tta_dat_cr_liquidac_calc            = tt-int_ds_furo_caixa.dat_bordero
                   tt_integr_acr_liq_item_lote.tta_val_tit_acr                     = tit_acr.val_sdo_tit_acr - tt-int_ds_furo_caixa.vl_furo 
                   tt_integr_acr_liq_item_lote.tta_val_liquidac_tit_acr            = tt-int_ds_furo_caixa.vl_furo 
                   tt_integr_acr_liq_item_lote.tta_val_desc_tit_acr                = 0
                   tt_integr_acr_liq_item_lote.tta_val_abat_tit_acr                = 0
                   tt_integr_acr_liq_item_lote.tta_val_despes_bcia                 = 0
                   tt_integr_acr_liq_item_lote.tta_val_multa_tit_acr               = 0
                   tt_integr_acr_liq_item_lote.tta_val_juros                       = 0
                   tt_integr_acr_liq_item_lote.ttv_rec_lote_liquidac_acr           = recid(tt_integr_acr_liquidac_lote)
                   tt_integr_acr_liq_item_lote.ttv_rec_item_lote_liquidac_acr      = recid(tt_integr_acr_liq_item_lote)
                   tt_integr_acr_liq_item_lote.tta_ind_tip_item_liquidac_acr       = "Pagamento" 
                   tt_integr_acr_liq_item_lote.tta_cdn_cliente                     = tit_acr.cdn_cliente
                   tt_integr_acr_liq_item_lote.tta_cod_portador                    = tit_acr.cod_portador
                   tt_integr_acr_liq_item_lote.tta_cod_cart_bcia                   = "CAR"
                   tt_integr_acr_liq_item_lote.tta_log_gera_antecip                = NO 
                   tt_integr_acr_liq_item_lote.tta_des_text_histor                 = "Liquida‡Æo devido ao furo de caixa"
                   tt_integr_acr_liq_item_lote.tta_log_gera_avdeb                  = NO 
                   tt_integr_acr_liq_item_lote.tta_log_movto_comis_estordo         = NO .

                   run prgfin/acr/acr901zc.py (Input 1,
                                              Input table tt_integr_acr_liquidac_lote,
                                              Input table tt_integr_acr_liq_item_lote,
                                              Input table tt_integr_acr_abat_antecip,
                                              Input table tt_integr_acr_abat_prev,
                                              Input table tt_integr_acr_cheq,
                                              Input table tt_integr_acr_liquidac_impto,
                                              Input table tt_integr_acr_rel_pend_cheq,
                                              Input table tt_integr_acr_liq_aprop_ctbl,
                                              Input table tt_integr_acr_liq_desp_rec,
                                              Input table tt_integr_acr_aprop_liq_antec,
                                              Input "",
                                              output table tt_log_erros_import_liquidac) /*prg_api_integr_acr_liquidac_new*/.
    
    
                    IF can-find(first tt_log_erros_import_liquidac) then do:
                        FIND FIRST tt_integr_acr_liq_item_lote NO-LOCK NO-ERROR.
                        IF AVAIL tt_integr_acr_liq_item_lote THEN DO:
                            RUN pi-cria-tt-erro(INPUT 1,
                                                INPUT 17006,
                                                INPUT "Estab/Especie/Titulo: " + string(tt_integr_acr_liq_item_lote.tta_cod_estab) + "/DI/" + STRING(tt_integr_acr_liq_item_lote.tta_cod_tit_acr) + " , apresentou os erros abaixo.",
                                                INPUT "Estab/Especie/Titulo: " + string(tt_integr_acr_liq_item_lote.tta_cod_estab) + "/DI/" + STRING(tt_integr_acr_liq_item_lote.tta_cod_tit_acr) + " , apresentou os erros abaixo.").                
                        END.

                        FOR EACH tt_log_erros_import_liquidac:
                            RUN pi-cria-tt-erro(INPUT 1,
                                                INPUT tt_log_erros_import_liquidac.ttv_num_erro_log, 
                                                INPUT tt_log_erros_import_liquidac.ttv_des_msg_erro,
                                                INPUT tt_log_erros_import_liquidac.ttv_des_msg_erro).
                        END.

                        RUN intprg/int999.p (INPUT "FuroCX", 
                                             INPUT string(tt-int_ds_furo_caixa.cod_estab) + "-" + string(tt-int_ds_furo_caixa.num_bordero)+ "-" + string(tt-int_ds_furo_caixa.mat_colab),
                                             INPUT "Registro nÆo Integrado." + " Estab.: " + string(tt-int_ds_furo_caixa.cod_estab) + 
                                                                           " Nr. Border“: " + string(tt-int_ds_furo_caixa.num_bordero) + 
                                                                           " Matr¡cula: " + string(tt-int_ds_furo_caixa.mat_colab),
                                             INPUT 1, /* 1 - Pendente ou 2 - Integrado */
                                             INPUT c-seg-usuario,
                                             INPUT "NICR007RP.P").
            
                    END.
                    ELSE DO:
                        FIND FIRST int_ds_furo_caixa EXCLUSIVE-LOCK
                             WHERE ROWID(int_ds_furo_caixa) = tt-int_ds_furo_caixa.r-rowid NO-ERROR.
                        IF AVAIL int_ds_furo_caixa THEN DO:
        
                            ASSIGN int_ds_furo_caixa.situacao = 2.
        
                            RELEASE int_ds_furo_caixa.
        
                            RUN intprg/int999.p (INPUT "FuroCX", 
                                                 INPUT string(tt-int_ds_furo_caixa.cod_estab) + "-" + string(tt-int_ds_furo_caixa.num_bordero)+ "-" + string(tt-int_ds_furo_caixa.mat_colab),
                                                 INPUT "Registro Integrado." + " Estab.: " + string(tt-int_ds_furo_caixa.cod_estab) + 
                                                                               " Nr. Border“: " + string(tt-int_ds_furo_caixa.num_bordero) + 
                                                                               " Matr¡cula: " + string(tt-int_ds_furo_caixa.mat_colab),
                                                 INPUT 2, /* 1 - Pendente ou 2 - Integrado */
                                                 INPUT c-seg-usuario,
                                                 INPUT "NICR007RP.P").
                            
                            DISP tt-int_ds_furo_caixa.cod_estab
                                 tt-int_ds_furo_caixa.num_bordero
                                 tt-int_ds_furo_caixa.dat_bordero
                                 tt-int_ds_furo_caixa.tip_furo
                                 tt-int_ds_furo_caixa.vl_furo
                                 "SIM" COLUMN-LABEL "Gerada Movto.?"
                                WITH WIDTH 333 STREAM-IO DOWN FRAME f-inv.
                            DOWN WITH FRAME f-inv.
        
                        END.

                    END.
        END.
        ELSE DO:
             RUN pi-cria-tt-erro(INPUT 1,
                                 INPUT 17006,
                                 INPUT "Estab/Especie/Titulo: " + string(tt-int_ds_furo_caixa.cod_estab) + "/DI/" + "DINH" + REPLACE(STRING(tt-int_ds_furo_caixa.dat_bordero,"99/99/99"),"/","") + " , nÆo foi encontrado.",
                                 INPUT "Estab/Especie/Titulo: " + string(tt-int_ds_furo_caixa.cod_estab) + "/DI/" + "DINH" + REPLACE(STRING(tt-int_ds_furo_caixa.dat_bordero,"99/99/99"),"/","") + " , nÆo foi encontrado.").                
        END.

    END.


END PROCEDURE.


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

PROCEDURE pi-mostra-erros:

    FOR EACH tt-erro:
           DISP tt-erro.cd-erro
                tt-erro.mensagem  FORMAT "x(100)"
                WITH WIDTH 333 STREAM-IO DOWN FRAME f-erro.
           DOWN WITH FRAME f-erro.             
    END.   
END.



