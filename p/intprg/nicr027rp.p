{include/i-prgvrs.i NICR027RP 1.00.00.001}  
{include/i_fnctrad.i}

/* defini»ao das temp-tables para recebimento de parametros */
def temp-table tt-param no-undo
    field destino          as integer
    field arquivo          as char format "x(35)"
    field usuario          as char format "x(12)"
    field data-exec        as date
    field hora-exec        as integer
    field classifica       as integer
    field desc-classifica  as char format "x(40)".

def temp-table tt-raw-digita
        field raw-digita	as raw.

def input parameter raw-param as raw no-undo.
def input parameter table for tt-raw-digita.  

create tt-param.                    
raw-transfer raw-param to tt-param NO-ERROR. 
IF tt-param.arquivo = "" THEN 
    ASSIGN tt-param.arquivo = "int020-1.txt"
           tt-param.destino = 3
           tt-param.data-exec = TODAY
           tt-param.hora-exec = TIME.
    
{intprg/nicr027rp.i}

def new global shared var v_cdn_empres_usuar        like mguni.empresa.ep-codigo no-undo.
def new global shared var v_cod_matriz_trad_org_ext as character format "x(8)" label "Matriz UO"  column-label "Matriz UO" no-undo. 
def new Global shared var c-seg-usuario as char format "x(12)" no-undo.


DEFINE BUFFER bf-int_dp_acordos_duplicatas FOR int_dp_acordos_duplicatas.

DEFINE VARIABLE v_hdl_api_integr_acr    AS HANDLE       NO-UNDO.
DEFINE VARIABLE c-estab-ems-5           AS CHARACTER    NO-UNDO.
DEFINE VARIABLE c-erro                  AS CHARACTER    NO-UNDO.
DEFINE VARIABLE c-empresa-ems-5         AS CHARACTER    NO-UNDO.
DEFINE VARIABLE h-acomp                 AS HANDLE       NO-UNDO.
DEFINE VARIABLE iNumSeq                 AS INTEGER      NO-UNDO.
DEFINE VARIABLE v_log_refer_uni         AS LOGICAL      NO-UNDO.

{include/i-rpvar.i}
{include/i-rpcab.i}


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
{utp/ut-liter.i Gera»’o_T­tulo_Devolu»’o * L}
assign c-titulo-relat = trim(return-value).
{utp/ut-liter.i Gera»’o_T­tulo_Devolu»’o * L}
assign c-sistema = trim(return-value).

VIEW frame f-cabec.
view frame f-rodape.


RUN utp/ut-acomp.p PERSISTENT SET h-acomp.
RUN pi-inicializar IN h-acomp (INPUT "Iniciando").

DEFINE TEMP-TABLE tt-erro NO-UNDO
    FIELD i-sequen    AS INTEGER
    FIELD cd-erro     AS INTEGER
    FIELD mensagem    AS CHAR
    FIELD ajuda       AS CHAR.   


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



FOR EACH int_dp_acordos_duplicatas NO-LOCK
    WHERE int_dp_acordos_duplicatas.situacao = 1:


    FIND FIRST emitente NO-LOCK
        WHERE emitente.cgc = int_dp_acordos_duplicatas.CNPJ_emitente NO-ERROR.

    IF NOT AVAIL emitente THEN DO:

        MESSAGE "Emitente nÆo encontrado"
            VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
        NEXT.

    END.

    RUN pi-cria-tit-acr ( INPUT int_dp_acordos_duplicatas.estabelecimento,   // c-cod-estab   
                          INPUT int_dp_acordos_duplicatas.emissao        ,   // d-dat-emissao 
                          INPUT TODAY                                    ,   // d-dat-trans   
                          INPUT int_dp_acordos_duplicatas.vencimento     ,   // d-dat-venc    
                          INPUT emitente.cod-emitente                    ,   // c-cod-emitente
                          INPUT int_dp_acordos_duplicatas.titulo         ,   // titulo
                          INPUT IF int_dp_acordos_duplicatas.serie = ? THEN "" ELSE int_dp_acordos_duplicatas.serie          ,   // c-serie-docto 
                          INPUT INT(int_dp_acordos_duplicatas.parcela)   ,   // parcela
                          INPUT int_dp_acordos_duplicatas.portador       ,   // c-cod-portador
                          INPUT int_dp_acordos_duplicatas.valor          ,   // d-valor-tit   
                          INPUT int_dp_acordos_duplicatas.especie        ,   // esp‚cie        
                          INPUT int_dp_acordos_duplicatas.carteira       ,   // carteira
                          INPUT int_dp_acordos_duplicatas.tipo_fluxo     ,   // tipo fluxo
                          INPUT int_dp_acordos_duplicatas.conta_contabil ,   // c-cta_ctbl
                          INPUT IF int_dp_acordos_duplicatas.centro_custo = ? THEN "" ELSE int_dp_acordos_duplicatas.centro_custo   ,   // c-ccusto
                          OUTPUT c-erro                                      // l-erro        
                        ).

    IF c-erro = "no" THEN DO:

        FIND FIRST bf-int_dp_acordos_duplicatas EXCLUSIVE-LOCK
            WHERE ROWID(bf-int_dp_acordos_duplicatas) = ROWID(int_dp_acordos_duplicatas) NO-ERROR.

        IF AVAIL bf-int_dp_acordos_duplicatas THEN 
            ASSIGN bf-int_dp_acordos_duplicatas.situacao = 2.

        RUN pi-cria-tt-erro(INPUT "",
                            INPUT 17006, 
                            INPUT "Titulo criado com sucesso",
                            INPUT "Estab/Especie/Serie/Titulo/Parcela/Cliente/Portador : " +  int_dp_acordos_duplicatas.estabelecimento + "/" +
                                                                                              STRING(int_dp_acordos_duplicatas.especie) + "/" +
                                                                                              STRING(int_dp_acordos_duplicatas.serie)   + "/" +
                                                                                              STRING(int_dp_acordos_duplicatas.titulo) + "/" +
                                                                                              STRING(int_dp_acordos_duplicatas.parcela) + "/" +
                                                                                              STRING(emitente.nome-abrev) ). 
    
        RELEASE bf-int_dp_acordos_duplicatas. 

    END.

END.


RUN pi-mostra-erros.

RUN pi-finalizar IN h-acomp.  
{include/i-rpclo.i} 


PROCEDURE pi-cria-tit-acr:
    DEFINE INPUT  PARAMETER c-cod-estab    AS CHAR.
    DEFINE INPUT  PARAMETER d-dat-emissao  LIKE docum-est.dt-emis.
    DEFINE INPUT  PARAMETER d-dat-trans    LIKE docum-est.dt-trans.
    DEFINE INPUT  PARAMETER d-dat-venc     AS DATE.
    DEFINE INPUT  PARAMETER c-cod-emitente LIKE emitente.cod-emitente.
    DEFINE INPUT  PARAMETER c-cod-titulo   AS CHAR.
    DEFINE INPUT  PARAMETER c-serie-docto  AS CHAR.
    DEFINE INPUT  PARAMETER i-cod-parcela  AS INTEGER.
    DEFINE INPUT  PARAMETER c-cod-portador AS CHAR.
    DEFINE INPUT  PARAMETER d-valor-tit    LIKE tit_acr.val_sdo_tit_acr.
    DEFINE INPUT  PARAMETER c-cod-esp      AS CHAR.
    DEFINE INPUT  PARAMETER c-carteira     AS CHAR.
    DEFINE INPUT  PARAMETER c-tip-fluxo    AS CHAR.
    DEFINE INPUT  PARAMETER c-cta_ctbl     AS CHAR.
    DEFINE INPUT  PARAMETER c-ccusto       AS CHAR.
    DEFINE OUTPUT PARAMETER l-erro         AS LOG INITIAL NO.

    DEFINE BUFFER b_movto_tit_acr  FOR movto_tit_acr.

    DEFINE VARIABLE c_cod_refer    AS CHARACTER                 NO-UNDO.

    DEFINE VARIABLE v_hdl_programa AS HANDLE      NO-UNDO.

    DEFINE VARIABLE c_cod_table   AS CHARACTER FORMAT "x(8)"   NO-UNDO.
    DEFINE VARIABLE w_estabel     AS CHARACTER FORMAT "x(3)"   NO-UNDO.
    DEFINE VARIABLE c-cod-refer   AS CHARACTER FORMAT "x(10)"  NO-UNDO.

    DEFINE VARIABLE c-estab        LIKE tit_acr.cod_estab       NO-UNDO.    
    DEFINE VARIABLE c-cod-tit-acr  LIKE tit_acr.cod_tit_acr     NO-UNDO.

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

    /*Retorna Matriz Tradu»’o Organizacional*/
    RUN prgint/ufn/ufn908za.py (INPUT "1":u,
                                INPUT "15":U,
                                OUTPUT v_cod_matriz_trad_org_ext).
    /*Tradu»’o Estabelecimento*/
    RUN pi-traduz-estab(INPUT v_cod_matriz_trad_org_ext,
                        INPUT STRING(c-cod-estab), /*Estabelecimento EMS 2*/
                        OUTPUT c-estab-ems-5,
                        OUTPUT c-erro).

    /*Tradu»’o Empresa*/
    RUN pi-traduz-empresa(INPUT v_cod_matriz_trad_org_ext,
                          INPUT v_cdn_empres_usuar, /*Empresa EMS 2*/
                          OUTPUT c-empresa-ems-5,
                          OUTPUT c-erro).

    ASSIGN c_cod_refer = "".
    RUN pi_retorna_sugestao_referencia (INPUT  "AV",
                                        INPUT  TODAY,
                                        OUTPUT c_cod_refer,
                                        INPUT  "tit_acr",
                                        INPUT  STRING(c-cod-estab)). 

    /* Cria»’o do lote contÿbil */
    CREATE tt_integr_acr_lote_impl. 
    ASSIGN tt_integr_acr_lote_impl.tta_cod_empresa        = c-empresa-ems-5 /*Obrigat«rio*/
           tt_integr_acr_lote_impl.ttv_cod_empresa_ext    = string(v_cdn_empres_usuar) /*Obrigat«rio*/
           tt_integr_acr_lote_impl.tta_cod_estab          = c-estab-ems-5       /*Obrigat«rio*/
           tt_integr_acr_lote_impl.tta_cod_estab_ext      = STRING(c-cod-estab) /*Obrigat«rio*/ 
           tt_integr_acr_lote_impl.tta_dat_transacao      = d-dat-trans
           tt_integr_acr_lote_impl.tta_ind_orig_tit_acr   = "2"
           tt_integr_acr_lote_impl.tta_ind_tip_cobr_acr   = "Normal"
           tt_integr_acr_lote_impl.tta_log_liquidac_autom = NO
           tt_integr_acr_lote_impl.ttv_log_lote_impl_ok   = YES
           tt_integr_acr_lote_impl.tta_cod_refer          = c_cod_refer.


    CREATE tt_integr_acr_item_lote_impl_9.
    ASSIGN tt_integr_acr_item_lote_impl_9.ttv_rec_lote_impl_tit_acr      = RECID(tt_integr_acr_lote_impl)
           tt_integr_acr_item_lote_impl_9.ttv_rec_item_lote_impl_tit_acr = RECID(tt_integr_acr_item_lote_impl_9)
           tt_integr_acr_item_lote_impl_9.tta_cod_refer                  = tt_integr_acr_lote_impl.tta_cod_refer
           tt_integr_acr_item_lote_impl_9.tta_cdn_cliente                = c-cod-emitente /*Obrigat«rio*/
           tt_integr_acr_item_lote_impl_9.tta_num_seq_refer              = 1
           tt_integr_acr_item_lote_impl_9.tta_cod_espec_docto            = c-cod-esp   
           tt_integr_acr_item_lote_impl_9.tta_ind_tip_espec_docto        = "2":U /*Obrigat«rio*/ /*"3"*/  /*Antecipa¯Êo*/
           tt_integr_acr_item_lote_impl_9.tta_cod_ser_docto              = c-serie-docto
           tt_integr_acr_item_lote_impl_9.tta_cod_portador               = c-cod-portador
           tt_integr_acr_item_lote_impl_9.tta_cod_portad_ext             = "" /*Obrigat«rio*/ 
           tt_integr_acr_item_lote_impl_9.tta_cod_modalid_ext            = "" /*string(nota-fiscal.modalidade)   /*Obrigat«rio*/ */
           tt_integr_acr_item_lote_impl_9.tta_cod_tit_acr                = c-cod-titulo   /*Obrigat«rio*/ 
           tt_integr_acr_item_lote_impl_9.tta_cod_parcela                = STRING(i-cod-parcela,"99") /*Obrigat«rio*/
           tt_integr_acr_item_lote_impl_9.tta_cod_indic_econ             = ""
           tt_integr_acr_item_lote_impl_9.tta_cod_cart_bcia              = c-carteira
           tt_integr_acr_item_lote_impl_9.tta_cod_finalid_econ_ext       = "0"
           tt_integr_acr_item_lote_impl_9.tta_ind_sit_tit_acr            = "Normal" /*Obrigat«rio*/
           tt_integr_acr_item_lote_impl_9.tta_cdn_repres                 = 0        
           tt_integr_acr_item_lote_impl_9.tta_dat_vencto_tit_acr         = IF d-dat-venc  >= 11/01/2016 THEN d-dat-venc  ELSE 11/01/2016 /*Obrigat«rio*/ /*tt-fat-duplic.dt-venciment*/
           tt_integr_acr_item_lote_impl_9.tta_dat_prev_liquidac          = IF d-dat-venc  >= 11/01/2016 THEN d-dat-venc  ELSE 11/01/2016 /*Obrigat«rio*/ /*tt-fat-duplic.dt-venciment*/
           tt_integr_acr_item_lote_impl_9.tta_dat_emis_docto             = IF d-dat-emissao >= 11/01/2016 THEN d-dat-emissao ELSE 11/01/2016 /*tt-nota-fiscal.dt-emis-nota*/
           tt_integr_acr_item_lote_impl_9.tta_des_text_histor            = "Titulo de acordo comercial " + STRING(d-dat-emissao,"99/99/9999")
           tt_integr_acr_item_lote_impl_9.tta_cod_cond_pagto             = ""
           tt_integr_acr_item_lote_impl_9.tta_val_cotac_indic_econ       = 1
           tt_integr_acr_item_lote_impl_9.tta_ind_sit_bcia_tit_acr       = "1"
           tt_integr_acr_item_lote_impl_9.tta_ind_ender_cobr             = "1"
           tt_integr_acr_item_lote_impl_9.tta_log_liquidac_autom         = NO
           tt_integr_acr_item_lote_impl_9.ttv_cod_nota_fisc_faturam      = ""
           tt_integr_acr_item_lote_impl_9.tta_val_tit_acr                = d-valor-tit /*Obrigat«rio*/
           tt_integr_acr_item_lote_impl_9.tta_val_liq_tit_acr            = d-valor-tit /*Obrigat«rio*/
           tt_integr_acr_item_lote_impl_9.tta_des_obs_cobr               = "".

    RUN pi-acompanhar IN h-acomp (INPUT "Est/Esp/Ser/Tit./Par: ":U + STRING(tt_integr_acr_lote_impl.tta_cod_estab) + "/" +
                                                                     STRING(tt_integr_acr_item_lote_impl_9.tta_cod_espec_docto) + "/" + 
                                                                     STRING(tt_integr_acr_item_lote_impl_9.tta_cod_ser_docto)   + "/" + 
                                                                     STRING(tt_integr_acr_item_lote_impl_9.tta_cod_tit_acr)).

    CREATE tt_integr_acr_aprop_ctbl_pend.
    ASSIGN tt_integr_acr_aprop_ctbl_pend.ttv_rec_item_lote_impl_tit_acr  = tt_integr_acr_item_lote_impl_9.ttv_rec_item_lote_impl_tit_acr
           tt_integr_acr_aprop_ctbl_pend.tta_cod_plano_cta_ctbl          = "PADRAO"     /*Obrigat«rio*/  /*sch-param-vpi.cod-plano-cta-ctbl*/    /*'schulz'*/
           tt_integr_acr_aprop_ctbl_pend.tta_cod_cta_ctbl                = c-cta_ctbl  /*Obrigat«rio*/
           tt_integr_acr_aprop_ctbl_pend.tta_cod_cta_ctbl_ext            = "" /*sch-param-vpi.cod-cta-ctbl*/          /*"1121995"*/
           tt_integr_acr_aprop_ctbl_pend.tta_cod_sub_cta_ctbl_ext        = "" /*sch-param-vpi.cod-ccusto*/ 
           tt_integr_acr_aprop_ctbl_pend.tta_cod_unid_negoc              = "000" /*Obrigat«rio*/ /*c-unid-negoc*/
           tt_integr_acr_aprop_ctbl_pend.tta_cod_unid_negoc_ext          = "" /*c-unid-negoc*/
           tt_integr_acr_aprop_ctbl_pend.tta_cod_plano_ccusto            = "" /* "PADRAO" Obrigat«rio*/ /*sch-param-vpi.cod-plano-ccusto*/      /*''*/ 
           tt_integr_acr_aprop_ctbl_pend.tta_cod_ccusto                  = c-ccusto /*"00697" Obrigat«rio*/ /*sch-param-vpi.cod-ccusto*/   
           tt_integr_acr_aprop_ctbl_pend.tta_cod_ccusto_ext              = ""                                  /*''*/
           tt_integr_acr_aprop_ctbl_pend.tta_cod_tip_fluxo_financ        = c-tip-fluxo /*Obrigat«rio*/
           tt_integr_acr_aprop_ctbl_pend.tta_cod_fluxo_financ_ext        = ""
           tt_integr_acr_aprop_ctbl_pend.tta_log_impto_val_agreg         = NO
           tt_integr_acr_aprop_ctbl_pend.tta_val_aprop_ctbl              = tt_integr_acr_item_lote_impl_9.tta_val_tit_acr. /*Obrigat«rio*/

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
                                INPUT "Houve erro na cria»’o do titulo abaixo, favor verificar.",
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

END PROCEDURE. /* pi-cria-tit-acr */


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
            ASSIGN c-erro = "Matriz Tradu¯Êo Estabelecimento NÊo Cadastrado. Estab: " + STRING(p-cod-estab-ems-2).

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
        ASSIGN c-erro = "Matriz Tradu¯Êo Empresa NÊo Cadastrada. Empresa: " + string(p-empresa-ems2).

        RETURN "NOK".
    END.

    RETURN "OK".

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
        format "Sim/NÊo"
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


PROCEDURE pi-mostra-erros:

    FOR EACH tt-erro:

          /* INICIO - Grava»’o LOG Tabela para a PROCFIT */
           FIND CURRENT int_dp_acordos_duplicatas EXCLUSIVE-LOCK NO-ERROR.
           IF AVAIL int_dp_acordos_duplicatas THEN DO:
               IF int_dp_acordos_duplicatas.situacao = 2 THEN DO:
                   ASSIGN int_dp_acordos_duplicatas.envio_status      = 8
                          int_dp_acordos_duplicatas.retorno_validacao = "".
               END.
               ELSE IF int_dp_acordos_duplicatas.situacao = 1 THEN DO:
                   ASSIGN int_dp_acordos_duplicatas.envio_status      = 9
                          int_dp_acordos_duplicatas.retorno_validacao = substring(string(tt-erro.cd-erro) + " - " + tt-erro.mensagem,1,500).
               END.
           END.
           /* FIM    - Grava»’o LOG Tabela para a PROCFIT */

           FIND CURRENT int_dp_acordos_duplicatas NO-LOCK NO-ERROR.

           DISP tt-erro.cd-erro
                tt-erro.mensagem FORMAT "x(100)" SKIP
                fill(" ",11) tt-erro.ajuda    FORMAT "x(150)" NO-LABEL
                 WITH WIDTH 333 STREAM-IO DOWN FRAME f-erro.
           DOWN WITH FRAME f-erro.
    END.    
END.

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
