/********************************************************************************
*******************************************************************************/
{include/i-prgvrs.i NICR003ARP 2.06.00.002}  
{include/i_fnctrad.i}
/******************************************************************************
**
**       PROGRAMA: NICR003ARP
**
**       DATA....: 04/2016
**
**       OBJETIVO: Gera‡Æo do Titulo Convenio Geral. 
**
**       VERSAO..: 2.06.001
** 
******************************************************************************/
DEFINE BUFFER portador      FOR ems5.portador.
DEFINE BUFFER b_renegoc_acr FOR renegoc_acr.
DEFINE BUFFER cliente       FOR ems5.cliente.

{include/i-rpvar.i}
{include/i-rpcab.i}
{intprg/nicr003arp.i}
/* {utp/ut-glob.i} */ 
def new Global shared var c-seg-usuario        as char    format "x(12)"   no-undo.
def new Global shared var c-gerou-erro         as LOGICAL format "Sim/NÆo" no-undo.

{method/dbotterr.i} 
{cdp/cd0666.i}  /*     Definicao da temp-table de erros */

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
    FIELD c-estab          AS CHAR FORMAT "x(05)"
    FIELD c-cliente-ini    LIKE emitente.cod-emitente
    FIELD c-cliente-fim    LIKE emitente.cod-emitente
    FIELD c-dt-emissao     AS DATE FORMAT "99/99/9999"
    FIELD c-convenio       AS CHAR FORMAT "999999"
    .

define temp-table tt-digita no-undo
    field cod_estab          LIKE tit_acr.cod_estab
    field cod_espec_docto    LIKE tit_acr.cod_espec_docto
    FIELD cod_ser_docto      LIKE tit_acr.cod_ser_docto
    FIELD cod_tit_acr        LIKE tit_acr.cod_tit_acr
    FIELD cod_parcela        LIKE tit_acr.cod_parcela
    index id cod_estab      
             cod_espec_docto
             cod_ser_docto  
             cod_tit_acr    
             cod_parcela  .

DEFINE TEMP-TABLE tit_acr_convenio NO-UNDO LIKE tit_acr 
    FIELD cod_convenio      LIKE int_ds_convenio.cod_convenio
    FIELD cdn_cli_convenio  LIKE tit_acr.cdn_cliente
    FIELD dat_corte         LIKE tit_acr.dat_vencto_tit_acr COLUMN-LABEL "Data Corte"
    FIELD dat_vencimento    LIKE tit_acr.dat_vencto_tit_acr COLUMN-LABEL "Data Vencto".

DEFINE VARIABLE v_log_refer_uni AS LOGICAL   NO-UNDO.

DEFINE VARIABLE dt_geracao_convenio AS DATE  NO-UNDO.
DEFINE VARIABLE digNossoNumero      AS CHARACTER   NO-UNDO.

def temp-table tt-raw-digita
    field raw-digita as raw.

DEF TEMP-TABLE tt-raw-param 
 FIELD raw-param  AS RAW.

DEFINE TEMP-TABLE tt-erro-aux NO-UNDO
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

def input parameter raw-param as raw no-undo.
def input parameter table for tt-raw-digita.

create tt-param.
raw-transfer raw-param to tt-param.

FOR EACH tt-raw-digita:
    CREATE tt-digita.
    RAW-TRANSFER raw-digita TO tt-digita.
END.

def var c-acompanha    as char    no-undo.
DEF VAR h-acomp        AS HANDLE  NO-UNDO.

DEF VAR d-dt-movto-aux as char no-undo.
DEF VAR d-dt-movto     as date format "99/99/9999" no-undo.

find first param-estoq  no-lock no-error.
find first param-global no-lock no-error.
find first ems2log.empresa where 
           empresa.ep-codigo = param-global.empresa-prin no-lock no-error.

assign c-programa = "NICR003ARP"
       c-versao   = "2.07"
       c-revisao  = "000"
       c-empresa  = empresa.razao-social.

find first tt-param no-lock no-error.
{include/i-rpout.i}
{utp/ut-liter.i Gera‡Æo_T¡tulo_Convenio * L}
assign c-titulo-relat = trim(return-value).
{utp/ut-liter.i Gera‡Æo_T¡tulo_Convenio * L}
assign c-sistema = trim(return-value).

VIEW frame f-cabec.
view frame f-rodape.

FUNCTION lastday RETURNS DATE (INPUT i-month /*m¼s*/ AS INTEGER, INPUT i-year /*ano*/ AS INTEGER)  FORWARD.
FUNCTION retorna_corte RETURNS DATE (INPUT dia AS INTEGER) FORWARD.
FUNCTION retorna_vencimento RETURNS DATE (INPUT corte AS DATE ,INPUT dia AS INTEGER) FORWARD.
                    
/* log-manager:logfile-name= "\\192.168.200.52\datasul\_custom_teste\Prog_QG\Geracao_Titulo_Convenio.txt". */
/* log-manager:log-entry-types= "4gltrace".                                                                */
     
FIND FIRST tt-digita NO-LOCK NO-ERROR.


RUN utp/ut-acomp.p PERSISTENT SET h-acomp.
RUN pi-inicializar IN h-acomp (INPUT "Verificando T¡tulos").

RUN pi-processa-convenio.

RUN pi-seta-titulo IN h-acomp (INPUT "Imprimindo Erros":U).
RUN pi-mostra-titulos-criados.
RUN pi-mostra-erros.

RUN pi-finalizar IN h-acomp.                       


/* log-manager:close-log(). */

{include/i-rpclo.i}   

IF CAN-FIND(FIRST tt-digita) AND (tt-param.c-cliente-ini = tt-param.c-cliente-fim) OR tt-param.c-dt-emissao <> ? THEN DO:
    RUN winexec (INPUT "notepad.exe" + CHR(32) + tt-param.arquivo, INPUT 1).
END.

return "OK":U.

PROCEDURE pi-processa-individual:
    DEFINE VARIABLE i-num-reneg AS INTEGER     NO-UNDO.
    DEFINE VARIABLE c-cod-refer AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE d-vl-total  AS DECIMAL     NO-UNDO.

    EMPTY TEMP-TABLE tt_integr_acr_renegoc.      
    EMPTY TEMP-TABLE tt_integr_acr_item_renegoc.
    EMPTY TEMP-TABLE tt_integr_acr_item_lote_impl.
    EMPTY TEMP-TABLE tt_integr_acr_fiador_renegoc.
    EMPTY TEMP-TABLE tt_pessoa_fisic_integr.     
    EMPTY TEMP-TABLE tt_pessoa_jurid_integr.
    EMPTY TEMP-TABLE tt_log_erros_renegoc_acr. 

    FIND FIRST int_ds_convenio NO-LOCK
         WHERE int_ds_convenio.cod_convenio = INT(tt-param.c-convenio) NO-ERROR.

    FIND estabelecimento where estabelecimento.cod_estab = tt-param.c-estab NO-LOCK NO-ERROR.
    IF AVAIL estabelecimento THEN DO:
        FIND LAST b_renegoc_acr USE-INDEX rngccr_id
            WHERE b_renegoc_acr.cod_estab = estabelecimento.cod_estab NO-LOCK NO-ERROR.
        IF AVAIL b_renegoc_acr THEN
             ASSIGN i-num-reneg = b_renegoc_acr.num_renegoc_cobr_acr + 1.
        ELSE ASSIGN i-num-reneg = 1.
    END.

    RUN pi_retorna_sugestao_referencia(Input  "RE",
                                       Input  TODAY,
                                       output c-cod-refer,
                                       Input  "renegociacao_acr",
                                       input  STRING(tt-param.c-estab)).

    CREATE tt_integr_acr_renegoc.
    ASSIGN tt_integr_acr_renegoc.tta_cod_empresa                 = estabelecimento.cod_empresa
           tt_integr_acr_renegoc.tta_cod_estab                   = STRING(tt-param.c-estab)
           tt_integr_acr_renegoc.tta_cod_refer                   = c-cod-refer
           tt_integr_acr_renegoc.tta_num_renegoc_cobr_acr        = i-num-reneg
           tt_integr_acr_renegoc.tta_dat_transacao               = tt-param.c-dt-emissao
           tt_integr_acr_renegoc.tta_cdn_cliente                 = tt-param.c-cliente-ini
           tt_integr_acr_renegoc.tta_cod_ser_docto               = ""
           tt_integr_acr_renegoc.tta_dat_primei_vencto_renegoc   = retorna_vencimento(tt-param.c-dt-emissao,int_ds_convenio.dia_vencimento)
           tt_integr_acr_renegoc.tta_cod_espec_docto             = "CF"
           tt_integr_acr_renegoc.tta_cod_indic_econ_val_pres     = "REAL"
           tt_integr_acr_renegoc.tta_cod_indic_econ              = "REAL"
           tt_integr_acr_renegoc.tta_cod_indic_econ_reaj_renegoc = "REAL"
           tt_integr_acr_renegoc.tta_cod_portador                = '99501'
           tt_integr_acr_renegoc.tta_cod_cart_bcia               = "CAR"
           tt_integr_acr_renegoc.tta_ind_vencto_renegoc          = "Mensal"
           tt_integr_acr_renegoc.tta_cdn_repres                  = 1
           tt_integr_acr_renegoc.ttv_log_atualiza_renegoc        = YES.
        .

    FOR FIRST clien_financ NO-LOCK
        WHERE clien_financ.cod_empresa = estabelecimento.cod_empresa
        AND   clien_financ.cdn_cliente = tt_integr_acr_renegoc.tta_cdn_cliente 
        :
        IF clien_financ.cod_portad_prefer = "99501" AND
           clien_financ.cod_cart_bcia_prefer = "DEP" 
        THEN DO:
            ASSIGN
                tt_integr_acr_renegoc.tta_cod_portador  = '99501'
                tt_integr_acr_renegoc.tta_cod_cart_bcia = "DEP"
                .
        END.
    END.

    ASSIGN d-vl-total = 0.

    FOR EACH tt-digita:

        FIND FIRST tit_acr OF tt-digita NO-LOCK NO-ERROR.
        IF AVAIL tit_acr THEN DO:
            CREATE tt_integr_acr_item_renegoc.
            ASSIGN tt_integr_acr_item_renegoc.tta_cod_estab               = tt-digita.cod_estab
                   tt_integr_acr_item_renegoc.tta_num_renegoc_cobr_acr    = tt_integr_acr_renegoc.tta_num_renegoc_cobr_acr
                   tt_integr_acr_item_renegoc.tta_cod_estab_tit_acr       = tit_acr.cod_estab
                   tt_integr_acr_item_renegoc.tta_num_id_tit_acr          = tit_acr.num_id_tit_acr
                   tt_integr_acr_item_renegoc.tta_dat_novo_vencto_tit_acr = retorna_vencimento(tt-param.c-dt-emissao,int_ds_convenio.dia_vencimento).
                .

            ASSIGN d-vl-total = d-vl-total + tit_acr.val_sdo_tit_acr.
        END.
    END.

    CREATE tt_integr_acr_item_lote_impl.
    ASSIGN tt_integr_acr_item_lote_impl.tta_num_seq_refer      = 1
           tt_integr_acr_item_lote_impl.tta_cdn_cliente        = tt-param.c-cliente-ini
           tt_integr_acr_item_lote_impl.tta_cod_espec_docto    = "CF"
           tt_integr_acr_item_lote_impl.tta_cod_ser_docto      = ""
           tt_integr_acr_item_lote_impl.tta_cod_tit_acr        = STRING(NEXT-VALUE(seq-num-fat-convenio),"9999999999")
           tt_integr_acr_item_lote_impl.tta_cod_parcela        = "01"
           tt_integr_acr_item_lote_impl.tta_dat_emis_docto     = tt-param.c-dt-emissao
           tt_integr_acr_item_lote_impl.tta_dat_vencto_tit_acr = retorna_vencimento(tt-param.c-dt-emissao,int_ds_convenio.dia_vencimento)
           tt_integr_acr_item_lote_impl.tta_cod_indic_econ     = "REAL"
           tt_integr_acr_item_lote_impl.tta_cod_portador       = "99501"
           tt_integr_acr_item_lote_impl.tta_cod_cart_bcia      = "CAR"
           tt_integr_acr_item_lote_impl.tta_dat_prev_liquidac  = retorna_vencimento(tt-param.c-dt-emissao,int_ds_convenio.dia_vencimento)
           tt_integr_acr_item_lote_impl.tta_val_tit_acr        = d-vl-total
           tt_integr_acr_item_lote_impl.tta_cdn_repres         = 1
           /*tt_integr_acr_item_lote_impl.tta_cod_tit_acr_bco    = "97" + STRING(INT(tt_integr_acr_item_lote_impl.tta_cod_tit_acr),"999999999")*/
        .

    FOR FIRST clien_financ NO-LOCK
        WHERE clien_financ.cod_empresa = estabelecimento.cod_empresa
        AND   clien_financ.cdn_cliente = tt_integr_acr_item_lote_impl.tta_cdn_cliente
        :
        IF clien_financ.cod_portad_prefer = "99501" AND
           clien_financ.cod_cart_bcia_prefer = "DEP" 
        THEN DO:
            ASSIGN
                tt_integr_acr_item_lote_impl.tta_cod_portador  = '99501'
                tt_integr_acr_item_lote_impl.tta_cod_cart_bcia = "DEP"
                .
        END.
    END.
    /*
    ASSIGN digNossoNumero = "".
    RUN pi-retorna-digito-verificador-bradesco(INPUT "02",
                                               INPUT "97" + STRING(INT(tt_integr_acr_item_lote_impl.tta_cod_tit_acr),"999999999"),
                                               OUTPUT digNossoNumero).
    ASSIGN tt_integr_acr_item_lote_impl.tta_cod_tit_acr_bco   = "97" + STRING(INT(tt_integr_acr_item_lote_impl.tta_cod_tit_acr),"999999999") + digNossoNumero.

    ASSIGN digNossoNumero = "".
    RUN pi-retorna-digito-verificador-bradesco(INPUT "02",
                                               INPUT "97" + STRING(INT(tt_integr_acr_item_lote_impl.tta_cod_tit_acr),"999999999"),
                                               OUTPUT digNossoNumero).
    ASSIGN tt_integr_acr_item_lote_impl.tta_cod_tit_acr_bco   = "97" + STRING(INT(tt_integr_acr_item_lote_impl.tta_cod_tit_acr),"999999999") + digNossoNumero.
    */

    Run prgfin/acr/acr902za.py(1,
                               INPUT-OUTPUT TABLE tt_integr_acr_renegoc,
                               INPUT-OUTPUT TABLE tt_integr_acr_item_renegoc,
                               INPUT-OUTPUT TABLE tt_integr_acr_item_lote_impl,
                               INPUT-OUTPUT TABLE tt_integr_acr_fiador_renegoc,
                               INPUT TABLE        tt_pessoa_fisic_integr,
                               INPUT TABLE        tt_pessoa_jurid_integr,
                               INPUT "EMS",
                               OUTPUT TABLE       tt_log_erros_renegoc_acr).

    IF CAN-FIND(FIRST tt_log_erros_renegoc_acr) THEN DO:
        FOR EACH tt_log_erros_renegoc_acr NO-LOCK:
            FIND FIRST tt_integr_acr_item_lote_impl NO-LOCK NO-ERROR.
            IF AVAIL tt_integr_acr_item_lote_impl THEN DO:
                RUN pi-cria-tt-erro-aux(INPUT tt_integr_acr_item_lote_impl.tta_num_seq_refer,
                                    INPUT 17006, 
                                    INPUT "Houve erro na cria‡Æo do titulo abaixo, favor verificar.",
                                    INPUT "Estab/Especie/Serie/Titulo/Parcela/Cliente : " +  STRING(tt-param.c-estab) + "/" +
                                                                                             STRING(tt_integr_acr_item_lote_impl.tta_cod_espec_docto) + "/" +
                                                                                             STRING(tt_integr_acr_item_lote_impl.tta_cod_ser_docto) + "/" +
                                                                                             STRING(tt_integr_acr_item_lote_impl.tta_cod_tit_acr) + "/" +
                                                                                             STRING(tt_integr_acr_item_lote_impl.tta_cod_parcela) + "/" +
                                                                                             STRING(tt_integr_acr_item_lote_impl.tta_cdn_cliente) ). 
            END.

            RUN pi-cria-tt-erro-aux(INPUT tt_log_erros_renegoc_acr.tta_num_renegoc_cobr_acr,
                                INPUT tt_log_erros_renegoc_acr.tta_num_mensagem,
                                INPUT tt_log_erros_renegoc_acr.ttv_des_msg,
                                INPUT tt_log_erros_renegoc_acr.ttv_des_msg).
        END.
   END.
   ELSE DO:
       FOR EACH tt_integr_acr_item_lote_impl:
           CREATE tt-tit-criados.
           ASSIGN tt-tit-criados.cod_estab          = STRING(tt-param.c-estab)
                  tt-tit-criados.cod_espec_docto    = tt_integr_acr_item_lote_impl.tta_cod_espec_docto
                  tt-tit-criados.cod_ser_docto      = tt_integr_acr_item_lote_impl.tta_cod_ser_docto
                  tt-tit-criados.cod_tit_acr        = tt_integr_acr_item_lote_impl.tta_cod_tit_acr
                  tt-tit-criados.cod_parcela        = tt_integr_acr_item_lote_impl.tta_cod_parcela              
                  tt-tit-criados.cdn_cliente        = tt_integr_acr_item_lote_impl.tta_cdn_cliente
                  tt-tit-criados.cod_portador       = tt_integr_acr_item_lote_impl.tta_cod_portad_ext
                  tt-tit-criados.val_origin_tit_acr = tt_integr_acr_item_lote_impl.tta_val_tit_acr
                  tt-tit-criados.dat_transacao      = tt_integr_acr_item_lote_impl.tta_dat_emis_docto    
                  tt-tit-criados.dat_emis_docto     = tt_integr_acr_item_lote_impl.tta_dat_emis_docto    
                  tt-tit-criados.dat_vencto_tit_acr = tt_integr_acr_item_lote_impl.tta_dat_vencto_tit_acr
                  tt-tit-criados.situacao           = "T¡tulo Gerado"
                        .
            /*
           FIND FIRST tit_acr EXCLUSIVE-LOCK
                WHERE tit_acr.cod_estab          = STRING(tt-param.c-estab)                        
                  AND tit_acr.cod_espec_docto    = tt_integr_acr_item_lote_impl.tta_cod_espec_docto
                  AND tit_acr.cod_ser_docto      = tt_integr_acr_item_lote_impl.tta_cod_ser_docto  
                  AND tit_acr.cod_tit_acr        = tt_integr_acr_item_lote_impl.tta_cod_tit_acr    
                  AND tit_acr.cod_parcela        = tt_integr_acr_item_lote_impl.tta_cod_parcela      NO-ERROR.
           IF AVAIL tit_acr THEN DO:
               ASSIGN digNossoNumero = "".
               RUN pi-retorna-digito-verificador-bradesco(INPUT "02",
                                                          INPUT "97" + STRING(INT(tt_integr_acr_item_lote_impl.tta_cod_tit_acr),"999999999"),
                                                          OUTPUT digNossoNumero).

               ASSIGN tit_acr.cod_tit_acr_bco    = "97" + STRING(INT(tt_integr_acr_item_lote_impl.tta_cod_tit_acr),"999999999") + digNossoNumero.
           END.
           */
       END.
   END.

END PROCEDURE. /* pi-processa-individual */

PROCEDURE pi-processa-coletivo:

    RUN pi-seta-titulo IN h-acomp (INPUT "Convˆnio - Geral":U).

    FOR EACH tit_acr  NO-LOCK
       WHERE tit_acr.cod_espec_docto = "CV"
         AND tit_acr.log_sdo_tit_acr = YES,
       FIRST cst_nota_fiscal NO-LOCK
       WHERE cst_nota_fiscal.cod_estabel = tit_acr.cod_estab           
         AND cst_nota_fiscal.serie       = tit_acr.cod_ser_docto 
         AND cst_nota_fiscal.nr_nota_fis = tit_acr.cod_tit_acr,
/*        FIRST cst_nota_fiscal OF nota-fiscal NO-LOCK,  */
       FIRST int_ds_convenio
       WHERE int_ds_convenio.cod_convenio = INT(cst_nota_fiscal.convenio)
/*          AND int_ds_convenio.dia-fechamento = DAY(DATE(dt_geracao_convenio)) */
         AND int_ds_convenio.log_envia_cupom = NO NO-LOCK

       :  

        RUN pi-acompanhar IN h-acomp (INPUT "Estab/Serie/Titulo: " + STRING(tit_acr.cod_estab) + "/" + STRING(tit_acr.cod_ser_docto ) + "/" + STRING(tit_acr.cod_tit_acr)).
        
        
        FIND FIRST cliente 
             WHERE cliente.cod_id_feder  = int_ds_convenio.cnpj
               AND cliente.cdn_cliente  >= tt-param.c-cliente-ini
               AND cliente.cdn_cliente  <= tt-param.c-cliente-fim NO-LOCK NO-ERROR.
        IF NOT AVAIL cliente THEN NEXT.       


       /* INICIO - Logica para pegar convˆnio com data de fechamento 29 e 30, por causa do mˆs de fevereiro */
       IF (DAY(DATE(dt_geracao_convenio)) = 1 AND MONTH(DATE(dt_geracao_convenio)) = 3) THEN DO:
           IF DAY(DATE(DATE(dt_geracao_convenio) - 1)) = 28 THEN DO:
               IF int_ds_convenio.dia_fechamento <> 1  AND 
                  int_ds_convenio.dia_fechamento <> 29 AND
                  int_ds_convenio.dia_fechamento <> 30 THEN NEXT.
           END.
           ELSE IF DAY(DATE(DATE(dt_geracao_convenio) - 1)) = 29 THEN DO:
               IF int_ds_convenio.dia_fechamento <> 1  AND 
                  int_ds_convenio.dia_fechamento <> 30 THEN NEXT.
           END.
       END.
       ELSE DO:
           IF int_ds_convenio.dia_fechamento <> DAY(DATE(dt_geracao_convenio)) THEN NEXT.
       END.
       /* FIM - Logica para pegar convˆnio com data de fechamento 29 e 30, por causa do mˆs de fevereiro */

       RUN pi-acompanhar IN h-acomp (INPUT "Estab/Serie/Titulo: " + STRING(tit_acr.cod_estab) + "/" + STRING(tit_acr.cod_ser_docto ) + "/" + STRING(tit_acr.cod_tit_acr)).
    
       CREATE tit_acr_convenio.
       BUFFER-COPY tit_acr TO tit_acr_convenio.
       ASSIGN tit_acr_convenio.cod_convenio     = int_ds_convenio.cod_convenio
              tit_acr_convenio.cdn_cli_convenio = cliente.cdn_cliente.

    END.

    RUN pi-verifica-corte-convenio.
    RUN pi-gera-titulo-convenio.

END PROCEDURE. /* pi-processa-coletivo  */

PROCEDURE pi-verifica-corte-convenio:

    RUN pi-seta-titulo IN h-acomp (INPUT "Convˆnio - Data Corte":U).

    FOR EACH tit_acr_convenio EXCLUSIVE-LOCK,
       FIRST int_ds_convenio
       WHERE int_ds_convenio.cod_convenio = tit_acr_convenio.cod_convenio NO-LOCK
       BREAK BY tit_acr_convenio.cod_convenio :

        RUN pi-acompanhar IN h-acomp (INPUT "Convˆnio: ":U + STRING(tit_acr_convenio.cod_convenio)).
    
        ASSIGN dat_corte = retorna_corte(int_ds_convenio.dia_fechamento).

        IF tit_acr_convenio.dat_vencto_tit_acr >= dat_corte OR INT(dat_corte - tit_acr_convenio.dat_vencto_tit_acr) > 90 THEN DO: 
            DELETE tit_acr_convenio.
            NEXT.
        END.
        ELSE DO:
            ASSIGN tit_acr_convenio.dat_corte = dat_corte.
        END.

        RUN pi-acompanhar IN h-acomp (INPUT STRING(tit_acr_convenio.cod_convenio) + "/" + STRING(tit_acr_convenio.dat_vencto_tit_acr,"99/99/9999")).
    
        ASSIGN tit_acr_convenio.dat_vencimento = retorna_vencimento(dat_corte,int_ds_convenio.dia_vencimento).
    END.

END PROCEDURE.

PROCEDURE pi-gera-titulo-convenio:
    DEFINE VARIABLE i-num-reneg AS INTEGER     NO-UNDO.
    DEFINE VARIABLE c-cod-refer AS CHARACTER FORMAT "x(12)" NO-UNDO.

    DEFINE VARIABLE d-vl-total AS DECIMAL     NO-UNDO.

    RUN pi-seta-titulo IN h-acomp (INPUT "Convˆnio - Gerando T¡tulo":U).

    FOR EACH tit_acr_convenio
    BREAK BY tit_acr_convenio.cod_convenio :

        RUN pi-seta-titulo IN h-acomp (INPUT "Convˆnio: ":U + STRING(tit_acr_convenio.cod_convenio)).
    
        IF FIRST-OF(tit_acr_convenio.cod_convenio) THEN DO:
            EMPTY TEMP-TABLE tt_integr_acr_renegoc.      
            EMPTY TEMP-TABLE tt_integr_acr_item_renegoc.
            EMPTY TEMP-TABLE tt_integr_acr_item_lote_impl.
            EMPTY TEMP-TABLE tt_integr_acr_fiador_renegoc.
            EMPTY TEMP-TABLE tt_pessoa_fisic_integr.     
            EMPTY TEMP-TABLE tt_pessoa_jurid_integr.
            EMPTY TEMP-TABLE tt_log_erros_renegoc_acr.  

            ASSIGN d-vl-total = 0.
        
            FIND estabelecimento where estabelecimento.cod_estab = tt-param.c-estab NO-LOCK NO-ERROR.
            IF AVAIL estabelecimento THEN DO:
                FIND LAST b_renegoc_acr USE-INDEX rngccr_id
                    WHERE b_renegoc_acr.cod_estab = estabelecimento.cod_estab NO-LOCK NO-ERROR.
                IF AVAIL b_renegoc_acr THEN
                     ASSIGN i-num-reneg = b_renegoc_acr.num_renegoc_cobr_acr + 1.
                ELSE ASSIGN i-num-reneg = 1.
            END.
        
            RUN pi_retorna_sugestao_referencia(Input  "RE",
                                               Input  TODAY,
                                               output c-cod-refer,
                                               Input  "renegociacao_acr",
                                               input  STRING(tt-param.c-estab)).
        
            CREATE tt_integr_acr_renegoc.
            ASSIGN tt_integr_acr_renegoc.tta_cod_empresa                 = estabelecimento.cod_empresa
                   tt_integr_acr_renegoc.tta_cod_estab                   = STRING(estabelecimento.cod_estab)
                   tt_integr_acr_renegoc.tta_cod_refer                   = c-cod-refer
                   tt_integr_acr_renegoc.tta_num_renegoc_cobr_acr        = i-num-reneg
                   tt_integr_acr_renegoc.tta_dat_transacao               = tit_acr_convenio.dat_corte
                   tt_integr_acr_renegoc.tta_cod_ser_docto               = ""
                   tt_integr_acr_renegoc.tta_cdn_cliente                 = tit_acr_convenio.cdn_cli_convenio
                   tt_integr_acr_renegoc.tta_dat_primei_vencto_renegoc   = tit_acr_convenio.dat_vencto_tit_acr
                   tt_integr_acr_renegoc.tta_cod_espec_docto             = "CF"
                   tt_integr_acr_renegoc.tta_cod_indic_econ_val_pres     = "REAL"
                   tt_integr_acr_renegoc.tta_cod_indic_econ              = "REAL"
                   tt_integr_acr_renegoc.tta_cod_indic_econ_reaj_renegoc = "REAL"
                   tt_integr_acr_renegoc.tta_cod_portador                = tit_acr_convenio.cod_portador
                   tt_integr_acr_renegoc.tta_cod_cart_bcia               = tit_acr_convenio.cod_cart_bcia
                   tt_integr_acr_renegoc.tta_ind_vencto_renegoc          = "Mensal"
                   tt_integr_acr_renegoc.tta_qtd_parc_renegoc            = 1
                   tt_integr_acr_renegoc.tta_cdn_repres                  = 1
                   tt_integr_acr_renegoc.ttv_log_atualiza_renegoc        = YES.     

            FOR FIRST clien_financ NO-LOCK
                WHERE clien_financ.cod_empresa = estabelecimento.cod_empresa
                AND   clien_financ.cdn_cliente = tt_integr_acr_renegoc.tta_cdn_cliente 
                :
                IF clien_financ.cod_portad_prefer = "99501" AND
                   clien_financ.cod_cart_bcia_prefer = "DEP" 
                THEN DO:
                    ASSIGN
                        tt_integr_acr_renegoc.tta_cod_portador  = '99501'
                        tt_integr_acr_renegoc.tta_cod_cart_bcia = "DEP"
                        .
                END.
            END.

        END.

        FIND FIRST tit_acr USE-INDEX titacr_token
             WHERE tit_acr.cod_estab      = tit_acr_convenio.cod_estab
               AND tit_acr.num_id_tit_acr = tit_acr_convenio.num_id_tit_acr NO-LOCK NO-ERROR.
        IF AVAIL tit_acr THEN DO:

            RUN pi-acompanhar IN h-acomp (INPUT "Estab/ID: " + STRING(tit_acr_convenio.cod_estab) + "/" + STRING(tit_acr_convenio.num_id_tit_acr)).

            CREATE tt_integr_acr_item_renegoc.
            ASSIGN tt_integr_acr_item_renegoc.tta_cod_estab               = tit_acr.cod_estab
                   tt_integr_acr_item_renegoc.tta_num_renegoc_cobr_acr    = tt_integr_acr_renegoc.tta_num_renegoc_cobr_acr
                   tt_integr_acr_item_renegoc.tta_cod_estab_tit_acr       = tit_acr.cod_estab
                   tt_integr_acr_item_renegoc.tta_num_id_tit_acr          = tit_acr.num_id_tit_acr
                   tt_integr_acr_item_renegoc.tta_dat_novo_vencto_tit_acr = tit_acr_convenio.dat_vencimento.
                .

            ASSIGN d-vl-total = d-vl-total + tit_acr.val_sdo_tit_acr.
        END.
        
        IF LAST-OF(tit_acr_convenio.cod_convenio) THEN DO:
            CREATE tt_integr_acr_item_lote_impl.
            ASSIGN tt_integr_acr_item_lote_impl.tta_num_seq_refer      = 1
                   tt_integr_acr_item_lote_impl.tta_cdn_cliente        = tit_acr_convenio.cdn_cli_convenio
                   tt_integr_acr_item_lote_impl.tta_cod_espec_docto    = "CF"
                   tt_integr_acr_item_lote_impl.tta_cod_ser_docto      = ""
                   tt_integr_acr_item_lote_impl.tta_cod_tit_acr        = STRING(NEXT-VALUE(seq-num-fat-convenio),"9999999999")
                   tt_integr_acr_item_lote_impl.tta_cod_parcela        = "01"
                   tt_integr_acr_item_lote_impl.tta_dat_emis_docto     = tit_acr_convenio.dat_corte
                   tt_integr_acr_item_lote_impl.tta_dat_vencto_tit_acr = tit_acr_convenio.dat_vencimento
                   tt_integr_acr_item_lote_impl.tta_cod_indic_econ     = "REAL"
                   tt_integr_acr_item_lote_impl.tta_cod_portador       = tit_acr_convenio.cod_portador 
                   tt_integr_acr_item_lote_impl.tta_cod_cart_bcia      = tit_acr_convenio.cod_cart_bcia
                   tt_integr_acr_item_lote_impl.tta_dat_prev_liquidac  = tit_acr_convenio.dat_vencimento
                   tt_integr_acr_item_lote_impl.tta_val_tit_acr        = d-vl-total
                   tt_integr_acr_item_lote_impl.tta_cdn_repres         = 1
                   /*tt_integr_acr_item_lote_impl.tta_cod_tit_acr_bco    = "97" + STRING(INT(tt_integr_acr_item_lote_impl.tta_cod_tit_acr),"999999999")*/
                .

            FOR FIRST clien_financ NO-LOCK
                WHERE clien_financ.cod_empresa = estabelecimento.cod_empresa
                AND   clien_financ.cdn_cliente = tt_integr_acr_item_lote_impl.tta_cdn_cliente
                :
                IF clien_financ.cod_portad_prefer = "99501" AND
                   clien_financ.cod_cart_bcia_prefer = "DEP" 
                THEN DO:
                    ASSIGN
                        tt_integr_acr_item_lote_impl.tta_cod_portador  = '99501'
                        tt_integr_acr_item_lote_impl.tta_cod_cart_bcia = "DEP"
                        .
                END.
            END.

            RUN pi-acompanhar IN h-acomp (INPUT "Esperando Retorno API...").

            RUN prgfin/acr/acr902za.py(1,
                                       INPUT-OUTPUT TABLE tt_integr_acr_renegoc,
                                       INPUT-OUTPUT TABLE tt_integr_acr_item_renegoc,
                                       INPUT-OUTPUT TABLE tt_integr_acr_item_lote_impl,
                                       INPUT-OUTPUT TABLE tt_integr_acr_fiador_renegoc,
                                       INPUT TABLE        tt_pessoa_fisic_integr,
                                       INPUT TABLE        tt_pessoa_jurid_integr,
                                       INPUT "EMS",
                                       OUTPUT TABLE       tt_log_erros_renegoc_acr).

            RUN pi-acompanhar IN h-acomp (INPUT "Verificando Retorno API...").
            
            IF CAN-FIND(FIRST tt_log_erros_renegoc_acr) THEN DO:
                FOR EACH tt_log_erros_renegoc_acr NO-LOCK:
                    FIND FIRST tt_integr_acr_item_lote_impl NO-LOCK NO-ERROR.
                    IF AVAIL tt_integr_acr_item_lote_impl THEN DO:
                        RUN pi-cria-tt-erro-aux(INPUT tt_integr_acr_item_lote_impl.tta_num_seq_refer,
                                            INPUT 17006, 
                                            INPUT "Houve erro na cria‡Æo do titulo abaixo, favor verificar.",
                                            INPUT "Estab/Especie/Serie/Titulo/Parcela/Cliente/Portador : " +  STRING(estabelecimento.cod_estab) + "/" +
                                                                                                              STRING(tt_integr_acr_item_lote_impl.tta_cod_espec_docto) + "/" +
                                                                                                              STRING(tt_integr_acr_item_lote_impl.tta_cod_ser_docto) + "/" +
                                                                                                              STRING(tt_integr_acr_item_lote_impl.tta_cod_tit_acr) + "/" +
                                                                                                              STRING(tt_integr_acr_item_lote_impl.tta_cod_parcela) + "/" +
                                                                                                              STRING(tt_integr_acr_item_lote_impl.tta_cdn_cliente) + "/"  +
                                                                                                              STRING(tt_integr_acr_item_lote_impl.tta_cod_portador)   ). 
                    END.
    
                    RUN pi-cria-tt-erro-aux(INPUT tt_log_erros_renegoc_acr.tta_num_renegoc_cobr_acr,
                                            INPUT tt_log_erros_renegoc_acr.tta_num_mensagem,
                                            INPUT tt_log_erros_renegoc_acr.ttv_des_msg,
                                            INPUT tt_log_erros_renegoc_acr.ttv_des_msg).
                END.
           END.
           ELSE DO:

               FOR EACH tt_integr_acr_item_lote_impl:
                   CREATE tt-tit-criados.
                   ASSIGN tt-tit-criados.cod_estab          = estabelecimento.cod_estab
                          tt-tit-criados.cod_espec_docto    = tt_integr_acr_item_lote_impl.tta_cod_espec_docto
                          tt-tit-criados.cod_ser_docto      = tt_integr_acr_item_lote_impl.tta_cod_ser_docto
                          tt-tit-criados.cod_tit_acr        = tt_integr_acr_item_lote_impl.tta_cod_tit_acr
                          tt-tit-criados.cod_parcela        = tt_integr_acr_item_lote_impl.tta_cod_parcela              
                          tt-tit-criados.cdn_cliente        = tt_integr_acr_item_lote_impl.tta_cdn_cliente
                          tt-tit-criados.cod_portador       = tt_integr_acr_item_lote_impl.tta_cod_portad_ext
                          tt-tit-criados.val_origin_tit_acr = tt_integr_acr_item_lote_impl.tta_val_tit_acr
                          tt-tit-criados.dat_transacao      = tt_integr_acr_item_lote_impl.tta_dat_emis_docto    
                          tt-tit-criados.dat_emis_docto     = tt_integr_acr_item_lote_impl.tta_dat_emis_docto    
                          tt-tit-criados.dat_vencto_tit_acr = tt_integr_acr_item_lote_impl.tta_dat_vencto_tit_acr
                          tt-tit-criados.situacao           = "T¡tulo Gerado".
                    /*
                   FIND FIRST tit_acr EXCLUSIVE-LOCK
                        WHERE tit_acr.cod_estab          = STRING(tt-param.c-estab)                        
                          AND tit_acr.cod_espec_docto    = tt_integr_acr_item_lote_impl.tta_cod_espec_docto
                          AND tit_acr.cod_ser_docto      = tt_integr_acr_item_lote_impl.tta_cod_ser_docto  
                          AND tit_acr.cod_tit_acr        = tt_integr_acr_item_lote_impl.tta_cod_tit_acr    
                          AND tit_acr.cod_parcela        = tt_integr_acr_item_lote_impl.tta_cod_parcela      NO-ERROR.
                   IF AVAIL tit_acr THEN DO:
                       ASSIGN digNossoNumero = "".
                       RUN pi-retorna-digito-verificador-bradesco(INPUT "02",
                                                                  INPUT "97" + STRING(INT(tt_integr_acr_item_lote_impl.tta_cod_tit_acr),"999999999"),
                                                                  OUTPUT digNossoNumero).


                       ASSIGN tit_acr.cod_tit_acr_bco    = "97" + STRING(INT(tt_integr_acr_item_lote_impl.tta_cod_tit_acr),"999999999") + digNossoNumero .
                   END.
                   */
               END.
           END.
        END.
    END.

END PROCEDURE.

PROCEDURE pi-processa-convenio:

    IF tt-param.c-dt-emissao = ? THEN
         ASSIGN dt_geracao_convenio = TODAY - 1.
    ELSE ASSIGN dt_geracao_convenio = tt-param.c-dt-emissao.

    IF CAN-FIND(FIRST tt-digita) AND (tt-param.c-cliente-ini = tt-param.c-cliente-fim) THEN DO:
        RUN pi-processa-individual.
    END.
    ELSE DO:
        RUN pi-processa-coletivo.
    END.

END PROCEDURE. /* pi-processa-convenio */


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
                       + substring(v_des_dat,1,2)
                       
           v_num_aux_2 = integer(this-procedure:handle).

    do  v_num_cont = 1 to 2:
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

PROCEDURE pi-cria-tt-erro-aux:

    DEFINE INPUT PARAMETER p-i-sequen    AS INTEGER   NO-UNDO.
    DEFINE INPUT PARAMETER p-cd-erro     AS INTEGER   NO-UNDO.
    DEFINE INPUT PARAMETER p-mensagem    AS CHARACTER NO-UNDO.
    DEFINE INPUT PARAMETER p-ajuda       AS CHARACTER NO-UNDO.

    CREATE tt-erro-aux.
    ASSIGN tt-erro-aux.i-sequen    = p-i-sequen
           tt-erro-aux.cd-erro     = p-cd-erro 
           tt-erro-aux.mensagem    = p-mensagem
           tt-erro-aux.ajuda       = p-ajuda.

END PROCEDURE.

PROCEDURE pi-mostra-erros:

    EMPTY TEMP-TABLE tt-erro.

    ASSIGN c-gerou-erro = NO.

    FOR EACH tt-erro-aux:

           ASSIGN c-gerou-erro = YES.

           CREATE tt-erro.
           ASSIGN tt-erro.i-sequen = tt-erro-aux.i-sequen
                  tt-erro.cd-erro  = tt-erro-aux.cd-erro 
                  tt-erro.mensagem = tt-erro-aux.mensagem.

           IF tt-erro-aux.ajuda <> tt-erro-aux.mensagem THEN DO:
               ASSIGN tt-erro.mensagem = tt-erro.mensagem + tt-erro-aux.ajuda.
           END.

           DISP tt-erro-aux.cd-erro
                tt-erro-aux.mensagem FORMAT "x(100)" SKIP
                tt-erro-aux.ajuda    FORMAT "x(150)" NO-LABEL
                 WITH WIDTH 333 STREAM-IO DOWN FRAME f-erro.
           DOWN WITH FRAME f-erro.
    END.  

    IF CAN-FIND(FIRST tt-digita) AND (tt-param.c-cliente-ini = tt-param.c-cliente-fim) THEN DO:
        IF CAN-FIND(FIRST tt-erro) THEN
/*             RUN cdp/cd0666.p (INPUT TABLE tt-erro). */
    END.
END.

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

FUNCTION retorna_vencimento RETURNS DATE (INPUT corte AS DATE ,INPUT dia AS INTEGER):
    DEFINE VARIABLE dt     AS DATE    NO-UNDO.
    DEFINE VARIABLE dt_aux AS DATE    NO-UNDO.

    IF MONTH(corte) = 2 AND dia > 28 THEN DO:
        ASSIGN dt = DATE(STRING(01) + "/" + STRING(03) + "/" + STRING(YEAR(corte))).
    END.
    ELSE DO:
        ASSIGN dt = DATE(STRING(dia) + "/" + STRING(MONTH(corte)) + "/" + STRING(YEAR(corte))).
    END.

    IF dt > corte THEN DO:
        RETURN dt.
    END.
    ELSE DO:
        ASSIGN dt_aux = lastday(MONTH(corte),YEAR(corte)) + 1.
        
        IF MONTH(dt_aux) = 2 AND dia > 28 THEN DO:
           ASSIGN dt_aux = DATE(STRING(01) + "/" + STRING(03) + "/" + STRING(YEAR(dt_aux))).
        END.
        ELSE DO:
            ASSIGN dt_aux = DATE(STRING(dia) + "/" + STRING(MONTH(dt_aux)) + "/" + STRING(YEAR(dt_aux))).
        END.

        RETURN dt_aux.
    END.
END FUNCTION.

FUNCTION retorna_corte RETURNS DATE (INPUT dia AS INTEGER):
    DEFINE VARIABLE dt     AS DATE        NO-UNDO.
    DEFINE VARIABLE dt_aux AS DATE        NO-UNDO.
    DEFINE VARIABLE dt_ret AS DATE        NO-UNDO.

    IF MONTH(dt_geracao_convenio) = 2 AND dia > 28 THEN DO:
        IF INT(YEAR(dt_geracao_convenio)) MOD 4 = 0 THEN DO:
            ASSIGN dt = DATE(STRING(29) + "/" + STRING(MONTH(dt_geracao_convenio)) + "/" + STRING(YEAR(dt_geracao_convenio))).
        END.
        ELSE DO:
            ASSIGN dt = DATE(STRING(28) + "/" + STRING(MONTH(dt_geracao_convenio)) + "/" + STRING(YEAR(dt_geracao_convenio))).
        END.
    END.
    ELSE DO:
        ASSIGN dt = DATE(STRING(dia) + "/" + STRING(MONTH(dt_geracao_convenio)) + "/" + STRING(YEAR(dt_geracao_convenio))).
    END.
    
    IF dt <= dt_geracao_convenio THEN DO:
        RETURN dt.
    END.
    ELSE DO:
    
        ASSIGN dt_aux = DATE(STRING(01) + "/" + STRING(MONTH(dt_geracao_convenio)) + "/" + STRING(YEAR(dt_geracao_convenio)))
               dt_aux = dt_aux - 1.

        IF MONTH(dt_aux) = 2 AND dia > 28 THEN DO:
            IF INT(YEAR(dt_aux)) MOD 4 = 0 THEN DO:
                ASSIGN dt_aux = DATE(STRING(29) + "/" + STRING(MONTH(dt_aux)) + "/" + STRING(YEAR(dt_aux))).
            END.
            ELSE DO:
                ASSIGN dt_aux = DATE(STRING(28) + "/" + STRING(MONTH(dt_aux)) + "/" + STRING(YEAR(dt_aux))).
            END.
        END.
        ELSE DO:
            ASSIGN dt_aux = DATE(STRING(dia) + "/" + STRING(MONTH(dt_aux)) + "/" + STRING(YEAR(dt_aux))).
        END.

        RETURN dt_aux.
                   .
    END.
END FUNCTION.

FUNCTION lastday RETURN DATE
    (INPUT i-month AS INTEGER, INPUT i-year  AS INTEGER):
    DEFINE VARIABLE i-day AS INTEGER NO-UNDO EXTENT
        INITIAL [31,28,31,30,31,30,31,31,30,31,30,31].

    IF i-month >= 1 AND i-month <= 12 THEN DO:
        RETURN DATE(i-month,
                    i-day[i-month] + IF i-year MOD 4 = 0 AND i-month = 2 THEN 1 ELSE 0,
                    i-year).
    END.
    ELSE DO:
        RETURN ?.
    END.

END FUNCTION.

PROCEDURE WinExec EXTERNAL "kernel32" :
    DEF INPUT PARAM lpszCmdLine AS CHAR.
    DEF INPUT PARAM fuCmdShow AS LONG.
END PROCEDURE.

PROCEDURE pi-retorna-digito-verificador-bradesco:
    DEF INPUT  PARAM p-carteira           AS CHAR.
    DEF INPUT  PARAM p-nosso-numero       AS CHAR.
    DEF OUTPUT PARAM p-digito-verificador AS CHAR.

    DEF VAR i-valor01          AS INTEGER NO-UNDO.
    DEF VAR i-valor02          AS INTEGER NO-UNDO.
    DEF VAR i-valor03          AS INTEGER NO-UNDO.
    DEF VAR i-valor04          AS INTEGER NO-UNDO.
    DEF VAR i-valor05          AS INTEGER NO-UNDO.
    DEF VAR i-valor06          AS INTEGER NO-UNDO.
    DEF VAR i-valor07          AS INTEGER NO-UNDO.
    DEF VAR i-valor08          AS INTEGER NO-UNDO.
    DEF VAR i-valor09          AS INTEGER NO-UNDO.
    DEF VAR i-valor10          AS INTEGER NO-UNDO.
    DEF VAR i-valor11          AS INTEGER NO-UNDO.
    DEF VAR i-valor12          AS INTEGER NO-UNDO.
    DEF VAR i-valor13          AS INTEGER NO-UNDO.
    DEF VAR i-soma             AS INTEGER NO-UNDO.
    DEF VAR i-resto            AS INTEGER NO-UNDO.
    
    ASSIGN i-valor01 = 2 * INTEGER(SUBSTRING(p-carteira    ,01,1))
           i-valor02 = 7 * INTEGER(SUBSTRING(p-carteira    ,02,1))
           i-valor03 = 6 * INTEGER(SUBSTRING(p-nosso-numero,01,1))
           i-valor04 = 5 * INTEGER(SUBSTRING(p-nosso-numero,02,1))
           i-valor05 = 4 * INTEGER(SUBSTRING(p-nosso-numero,03,1))
           i-valor06 = 3 * INTEGER(SUBSTRING(p-nosso-numero,04,1))
           i-valor07 = 2 * INTEGER(SUBSTRING(p-nosso-numero,05,1))
           i-valor08 = 7 * INTEGER(SUBSTRING(p-nosso-numero,06,1))
           i-valor09 = 6 * INTEGER(SUBSTRING(p-nosso-numero,07,1))
           i-valor10 = 5 * INTEGER(SUBSTRING(p-nosso-numero,08,1))
           i-valor11 = 4 * INTEGER(SUBSTRING(p-nosso-numero,09,1))
           i-valor12 = 3 * INTEGER(SUBSTRING(p-nosso-numero,10,1))
           i-valor13 = 2 * INTEGER(SUBSTRING(p-nosso-numero,11,1)).

    ASSIGN i-soma = i-valor01 + i-valor02 + i-valor03 + i-valor04 + i-valor05 + i-valor06 + i-valor07 + 
                    i-valor08 + i-valor09 + i-valor10 + i-valor11 + i-valor12 + i-valor13.

    /* fut1074 - 08/06/2004 */
    /* Validar antes se resto da divisao for zero, entao considera 0 como digito */

    IF (i-soma MODULO 11) = 0 THEN DO:
        ASSIGN p-digito-verificador = "0".
    END.
    ELSE DO:
        ASSIGN i-resto = 11 - (i-soma MODULO 11).
        
        IF i-resto = 10 THEN
           ASSIGN p-digito-verificador = 'P'.
        ELSE
           ASSIGN p-digito-verificador = STRING(i-resto).
    END.

END PROCEDURE.




