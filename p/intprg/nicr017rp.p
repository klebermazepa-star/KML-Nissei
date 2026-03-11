/********************************************************************************
** Programa: NICR017RP - Estorno Parcial Fatura Convenio
**
** Versao : 
**
********************************************************************************/

/* include de controle de versao */
{include/i-prgvrs.i NICR017RP 2.00.00.000}
{cdp/cdcfgdis.i}
{intprg\int021.i}

DEFINE TEMP-TABLE tt-tit-acr     LIKE tit_acr
    FIELD marca  AS LOGICAL FORMAT "*/ "
    FIELD mostra AS LOGICAL FORMAT "Sim/NÆo"
    FIELD filtro AS LOGICAL FORMAT "Sim/NÆo"
    FIELD razao-social AS CHAR FORMAT "x(50)" COLUMN-LABEL "Nome Cliente".

/* definiçao das temp-tables para recebimento de parametros */
DEFINE TEMP-TABLE tt-param NO-UNDO
    FIELD destino       AS INTEGER
    FIELD arquivo       AS CHAR FORMAT "x(35)"
    FIELD usuario       AS CHAR FORMAT "x(12)"
    FIELD data-exec     AS DATE
    FIELD hora-exec     AS INTEGER
    FIELD CodCliente    LIKE tit_acr.cdn_cliente
    FIELD NumRenegoc    LIKE tit_acr.num_renegoc_cobr_acr
    FIELD DatEmissao    LIKE tit_acr.dat_emis_docto
    FIELD DatVencto     LIKE tit_acr.dat_vencto_tit_acr
    FIELD CodEspec      LIKE tit_acr.cod_espec_docto
    FIELD SerDocto      LIKE tit_acr.cod_ser_docto
    FIELD data-emis     AS DATE
    FIELD cod-tit-acr   LIKE tit_acr.cod_tit_acr
    FIELD convenio      AS CHAR
    FIELD cod-estab     AS CHAR
    FIELD cod-cliente   AS INT
    FIELD cod-ser-docto AS CHAR
    FIELD data-vencto   AS DATE.

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

DEFINE VARIABLE cCodCliente     LIKE tit_acr.cdn_cliente             NO-UNDO. 
DEFINE VARIABLE cNumRenegoc     LIKE tit_acr.num_renegoc_cobr_acr    NO-UNDO. 
DEFINE VARIABLE dDatEmissao     LIKE tit_acr.dat_emis_docto          NO-UNDO. 
DEFINE VARIABLE dDatVencto      LIKE tit_acr.dat_vencto_tit_acr      NO-UNDO. 
DEFINE VARIABLE cCodEspec       LIKE tit_acr.cod_espec_docto         NO-UNDO. 
DEFINE VARIABLE cSerDocto       LIKE tit_acr.cod_ser_docto           NO-UNDO. 
DEFINE VARIABLE c-cod-refer     AS CHARACTER                         NO-UNDO.
DEFINE VARIABLE c-estab-ini     AS CHARACTER INITIAL ""              NO-UNDO.
DEFINE VARIABLE c-estab-fim     AS CHARACTER INITIAL "ZZZZZ"         NO-UNDO.
DEFINE VARIABLE c-especie-ini   AS CHARACTER INITIAL ""              NO-UNDO.
DEFINE VARIABLE c-especie-fim   AS CHARACTER INITIAL "ZZZ"           NO-UNDO.
DEFINE VARIABLE c-serie-ini     AS CHARACTER INITIAL ""              NO-UNDO.
DEFINE VARIABLE c-serie-fim     AS CHARACTER INITIAL "ZZZZZ"         NO-UNDO.
DEFINE VARIABLE c-titulo-ini    AS CHARACTER INITIAL ""              NO-UNDO.
DEFINE VARIABLE c-titulo-fim    AS CHARACTER INITIAL "ZZZZZZZZZZZZ"  NO-UNDO.
DEFINE VARIABLE c-data-ini      AS DATE      INITIAL "01/01/2010"    NO-UNDO.
DEFINE VARIABLE c-data-fim      AS DATE      INITIAL "12/31/2999"    NO-UNDO.
DEFINE VARIABLE c-venc-ini      AS DATE      INITIAL "01/01/2010"    NO-UNDO.
DEFINE VARIABLE c-venc-fim      AS DATE      INITIAL "12/31/2999"    NO-UNDO.
DEFINE VARIABLE c_cod_table     AS CHARACTER                         NO-UNDO.
DEFINE VARIABLE v_log_refer_uni AS LOGICAL                           NO-UNDO.

def temp-table tt-raw-digita
   field raw-digita   as raw.

/* recebimento de parametros */
def input parameter raw-param as raw no-undo.
def input parameter table for tt-raw-digita.  

create tt-param.                    
raw-transfer raw-param to tt-param NO-ERROR. 
if tt-param.arquivo = "" then 
assign tt-param.arquivo = "nicr017.txt"
       tt-param.destino = 3
       tt-param.data-exec = TODAY
       tt-param.hora-exec = TIME.

FOR EACH tt-raw-digita:
    CREATE tt-tit-acr.
    RAW-TRANSFER tt-raw-digita.raw-digita TO tt-tit-acr NO-ERROR.
END.

ASSIGN cCodCliente = tt-param.CodCliente
       cNumRenegoc = tt-param.NumRenegoc
       dDatEmissao = tt-param.DatEmissao
       dDatVencto  = tt-param.DatVencto
       cCodEspec   = tt-param.CodEspec
       cSerDocto   = tt-param.SerDocto.

/* include padrao para variáveis de relatório  */
{include/i-rpvar.i}

{utp/ut-glob.i}
{cdp/cd0666.i}

form
    tt-erro.cd-erro
    tt-erro.mensagem FORMAT "x(110)"
with down width 132 stream-io frame f-erro-geral.

/* Inicio -- Projeto Internacional -- ut-trfrrp.p adicionado */
RUN utp/ut-trfrrp.p (INPUT FRAME f-erro-geral:HANDLE).

{utp/ut-liter.i C¢digo * r}
assign tt-erro.cd-erro:label in frame f-erro-geral = trim(return-value).

{utp/ut-liter.i Mensagem * r}
assign tt-erro.mensagem:label in frame f-erro-geral = trim(return-value).


FORM "Fatura foi gerada com sucesso.Foi gerado o t¡tulo abaixo:~~" SKIP
   tt-tit-criados.cod_estab          COLUMN-LABEL "Estab"
   tt-tit-criados.cod_espec_docto    COLUMN-LABEL "Especie"
   tt-tit-criados.cod_ser_docto      COLUMN-LABEL "Serie"
   tt-tit-criados.cod_tit_acr        COLUMN-LABEL "Titulo"
   tt-tit-criados.cod_parcela        COLUMN-LABEL "Parcela"
   tt-tit-criados.cdn_cliente        COLUMN-LABEL "Cliente"
   tt-tit-criados.val_origin_tit_acr COLUMN-LABEL "Valor"
    with down width 132 stream-io frame f-titulo.


/* include com a definiçao da frame de cabeçalho e rodapé */
{include/i-rpcab.i}
/* bloco principal do programa */

find first tt-param no-lock no-error.
assign c-programa       = "NICR017RP"
       c-versao         = "2.00"
       c-revisao        = ".00.000"
       c-empresa        = "* Nao Definido *"
       c-sistema        = "Faturamento"
       c-titulo-relat   = "Estorno Parcial Fatura Convenio".

/* ----- inicio do programa ----- */
for first param-global no-lock: end.
for mgadm.empresa fields (razao-social) where
    empresa.ep-codigo = param-global.empresa-prin no-lock: end.
assign c-empresa = mgadm.empresa.razao-social.

if tt-param.arquivo <> "" then do:
    {include/i-rpout.i}
                     
    view frame f-cabec.
    view frame f-rodape.
end.
    
RUN piEstornaFaturaAtual.

IF RETURN-VALUE <> "NOK" THEN DO:
    DEFINE VARIABLE opcao AS LOGICAL   NO-UNDO.
    
    ASSIGN c-estab-ini   = "" 
           c-estab-fim   = "ZZZZZ"
           c-especie-ini = ""
           c-especie-fim = "ZZZZZ"
           c-serie-ini   = ""
           c-serie-fim   = "ZZZZZ"
           c-titulo-ini  = ""
           c-titulo-fim  = "ZZZZZZZZZZZZZZ"
           c-data-ini    = 01/01/2010
           c-data-fim    = 12/31/2999
           c-venc-ini    = 01/01/2010
           c-venc-fim    = 12/31/2999
           .

    //RUN pi-carrega-titulo-filtro.
    RUN piGeraFaturaConvenio.
END.

IF CAN-FIND(FIRST tt-erro) THEN DO:
    FOR EACH tt-erro:
        DISP tt-erro.cd-erro
             tt-erro.mensagem WITH FRAME f-erro-geral.
    END.
END.
ELSE DO:
    FOR EACH tt-tit-criados :

        DISP tt-tit-criados.cod_estab         
             tt-tit-criados.cod_espec_docto   
             tt-tit-criados.cod_ser_docto     
             tt-tit-criados.cod_tit_acr       
             tt-tit-criados.cod_parcela       
             tt-tit-criados.cdn_cliente       
             tt-tit-criados.val_origin_tit_acr
            WITH FRAME f-titulo.
    END.
END.

if tt-param.arquivo <> "" then do:
    /* fechamento do output do relatorio  */
    {include/i-rpclo.i }
end.
/* elimina BO's */
return "OK".

PROCEDURE piEstornaFaturaAtual:
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    IF cNumRenegoc <> 0 AND cNumRenegoc<> ? THEN DO:
    
        FIND FIRST renegoc_acr NO-LOCK
             WHERE renegoc_acr.num_renegoc_cobr_acr = cNumRenegoc NO-ERROR.
        IF AVAIL renegoc_acr THEN DO:
    
            RUN pi-retorna-sugestao-referencia(INPUT  "RE",
                                               INPUT  tt-param.data-emis,
                                               OUTPUT c-cod-refer,
                                               INPUT  "renegociacao_acr",
                                               INPUT  STRING(renegoc_acr.cod_estab)).
    
            RUN prgfin/acr/acr718za.py (INPUT RECID(renegoc_acr),
                                        INPUT  TODAY,
                                        INPUT  c-cod-refer,
                                        INPUT  "Estorno Parcial da Fatura pelo NICR017.",
                                        OUTPUT table tt_log_erros_estorn_cancel).
    
            IF CAN-FIND(FIRST tt_log_erros_estorn_cancel) THEN DO:
    
                FOR EACH tt_log_erros_estorn_cancel:
    
                    RUN pi-cria-tt-erro-aux(INPUT tt_log_erros_estorn_cancel.tta_num_id_tit_acr,
                                            INPUT tt_log_erros_estorn_cancel.ttv_num_mensagem,
                                            INPUT tt_log_erros_estorn_cancel.ttv_des_msg_erro + " " + tt_log_erros_estorn_cancel.ttv_des_msg_ajuda,
                                            INPUT tt_log_erros_estorn_cancel.ttv_des_msg_ajuda).
                END.
    
                RETURN "NOK".
            END.
            ELSE DO:
                FIND FIRST int_ds_fat_convenio EXCLUSIVE-LOCK
                     WHERE int_ds_fat_convenio.nro_fatura   = tt-param.cod-tit-acr  NO-ERROR.
                IF  AVAIL int_ds_fat_convenio THEN DO:
                    ASSIGN int_ds_fat_convenio.tipo_movto         = 3 
                           int_ds_fat_convenio.situacao           = 1.
                END.
                RELEASE int_ds_fat_convenio.
            END.
        END.    
    
    END.
    ELSE DO:
        RUN pi-cria-tt-erro-aux(INPUT 1,
                                INPUT 17006,
                                INPUT "Numero da Renegocia‡Æo ‚ inv lido!" + "Favor verificar o titulo informado pois o numero da renegocia‡Æo ‚ inv lido",
                                INPUT "Favor verificar o titulo informado pois o numero da renegocia‡Æo ‚ inv lido").
        RETURN "NOK".
    END.

    RETURN "OK".
END PROCEDURE.

PROCEDURE pi-cria-tt-erro-aux:
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    DEFINE INPUT PARAMETER p-i-sequen    AS INTEGER   NO-UNDO.
    DEFINE INPUT PARAMETER p-cd-erro     AS INTEGER   NO-UNDO.
    DEFINE INPUT PARAMETER p-mensagem    AS CHARACTER NO-UNDO.
    DEFINE INPUT PARAMETER p-ajuda       AS CHARACTER NO-UNDO.

    CREATE tt-erro.
    ASSIGN tt-erro.i-sequen    = p-i-sequen
           tt-erro.cd-erro     = p-cd-erro 
           tt-erro.mensagem    = p-mensagem
           .

    RETURN "OK".
END PROCEDURE.


PROCEDURE piGeraFaturaConvenio :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    DEFINE BUFFER b_renegoc_acr FOR renegoc_acr.
    DEFINE BUFFER bf_tit_acr FOR tit_acr.

    DEFINE VARIABLE iSeq        AS INTEGER     NO-UNDO.
    DEFINE VARIABLE codConvenio AS INTEGER     NO-UNDO.

    DEFINE VARIABLE i-num-reneg AS INTEGER     NO-UNDO.
    DEFINE VARIABLE c-cod-refer AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE d-vl-total  AS DECIMAL     NO-UNDO.

    DEFINE VARIABLE digNossoNumero AS CHARACTER   NO-UNDO.

    EMPTY TEMP-TABLE tt_integr_acr_renegoc.      
    EMPTY TEMP-TABLE tt_integr_acr_item_renegoc.
    EMPTY TEMP-TABLE tt_integr_acr_item_lote_impl.
    EMPTY TEMP-TABLE tt_integr_acr_fiador_renegoc.
    EMPTY TEMP-TABLE tt_pessoa_fisic_integr.     
    EMPTY TEMP-TABLE tt_pessoa_jurid_integr.
    EMPTY TEMP-TABLE tt_log_erros_renegoc_acr. 

    FIND FIRST int_ds_convenio NO-LOCK
         WHERE int_ds_convenio.cod_convenio = INT(tt-param.convenio) NO-ERROR.

    FIND estabelecimento where estabelecimento.cod_estab = tt-param.cod-estab NO-LOCK NO-ERROR.
    IF AVAIL estabelecimento THEN DO:
        FIND LAST b_renegoc_acr USE-INDEX rngccr_id
            WHERE b_renegoc_acr.cod_estab = estabelecimento.cod_estab NO-LOCK NO-ERROR.
        IF AVAIL b_renegoc_acr THEN
             ASSIGN i-num-reneg = b_renegoc_acr.num_renegoc_cobr_acr + 1.
        ELSE ASSIGN i-num-reneg = 1.
    END.

    RUN pi-retorna-sugestao-referencia(Input  "RE",
                                       Input  TODAY,
                                       output c-cod-refer,
                                       Input  "renegociacao_acr",
                                       input  tt-param.cod-estab).

    CREATE tt_integr_acr_renegoc.
    ASSIGN tt_integr_acr_renegoc.tta_cod_empresa                 = estabelecimento.cod_empresa
           tt_integr_acr_renegoc.tta_cod_estab                   = tt-param.cod-estab
           tt_integr_acr_renegoc.tta_cod_refer                   = c-cod-refer
           tt_integr_acr_renegoc.tta_num_renegoc_cobr_acr        = i-num-reneg
           tt_integr_acr_renegoc.tta_dat_transacao               = tt-param.data-emis
           tt_integr_acr_renegoc.tta_cdn_cliente                 = tt-param.cod-cliente
           tt_integr_acr_renegoc.tta_cod_ser_docto               = tt-param.cod-ser-docto
           tt_integr_acr_renegoc.tta_dat_primei_vencto_renegoc   = tt-param.data-vencto
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
    ASSIGN d-vl-total = 0.

    FOR EACH tt-tit-acr
       WHERE tt-tit-acr.mostra = YES:

        FIND FIRST tit_acr NO-LOCK  
             WHERE tit_acr.cod_estab        = tt-tit-acr.cod_estab       
               AND tit_acr.cod_espec_docto  = tt-tit-acr.cod_espec_docto 
               AND tit_acr.cod_ser_docto    = tt-tit-acr.cod_ser_docto   
               AND tit_acr.cod_tit_acr      = tt-tit-acr.cod_tit_acr     
               AND tit_acr.cod_parcela      = tt-tit-acr.cod_parcela      NO-ERROR.
        IF AVAIL tit_acr THEN DO:
            CREATE tt_integr_acr_item_renegoc.
            ASSIGN tt_integr_acr_item_renegoc.tta_cod_estab               = tit_acr.cod_estab
                   tt_integr_acr_item_renegoc.tta_num_renegoc_cobr_acr    = tt_integr_acr_renegoc.tta_num_renegoc_cobr_acr
                   tt_integr_acr_item_renegoc.tta_cod_estab_tit_acr       = tit_acr.cod_estab
                   tt_integr_acr_item_renegoc.tta_num_id_tit_acr          = tit_acr.num_id_tit_acr
                   tt_integr_acr_item_renegoc.tta_dat_novo_vencto_tit_acr = tt-param.data-vencto.
                .

            ASSIGN d-vl-total = d-vl-total + tit_acr.val_sdo_tit_acr.
        END.
    END.

    CREATE tt_integr_acr_item_lote_impl.
    ASSIGN tt_integr_acr_item_lote_impl.tta_num_seq_refer      = 1
           tt_integr_acr_item_lote_impl.tta_cdn_cliente        = tt-param.cod-cliente
           tt_integr_acr_item_lote_impl.tta_cod_espec_docto    = "CF"
           tt_integr_acr_item_lote_impl.tta_cod_ser_docto      = tt-param.cod-ser-docto
           tt_integr_acr_item_lote_impl.tta_cod_tit_acr        = STRING(NEXT-VALUE(seq-num-fat-convenio),"9999999999")
           tt_integr_acr_item_lote_impl.tta_cod_parcela        = "01"
           tt_integr_acr_item_lote_impl.tta_dat_emis_docto     = tt-param.data-emis
           tt_integr_acr_item_lote_impl.tta_dat_vencto_tit_acr = tt-param.data-vencto
           tt_integr_acr_item_lote_impl.tta_cod_indic_econ     = "REAL"
           tt_integr_acr_item_lote_impl.tta_cod_portador       = "99501"
           tt_integr_acr_item_lote_impl.tta_cod_cart_bcia      = "CAR"
           tt_integr_acr_item_lote_impl.tta_dat_prev_liquidac  = tt-param.data-vencto
           tt_integr_acr_item_lote_impl.tta_val_tit_acr        = d-vl-total
           tt_integr_acr_item_lote_impl.tta_cdn_repres         = 1
           tt_integr_acr_item_lote_impl.tta_cod_tit_acr_bco    = "97" + STRING(INT(tt_integr_acr_item_lote_impl.tta_cod_tit_acr),"999999999")
        .

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
                                        INPUT "Houve erro na cria‡Æo do titulo abaixo, favor verificar." +
                                              "Estab/Especie/Serie/Titulo/Parcela/Cliente : " +  tt-param.cod-estab + "/" +
                                                                                                 STRING(tt_integr_acr_item_lote_impl.tta_cod_espec_docto) + "/" +
                                                                                                 STRING(tt_integr_acr_item_lote_impl.tta_cod_ser_docto) + "/" +
                                                                                                 STRING(tt_integr_acr_item_lote_impl.tta_cod_tit_acr) + "/" +
                                                                                                 STRING(tt_integr_acr_item_lote_impl.tta_cod_parcela) + "/" +
                                                                                                 STRING(tt_integr_acr_item_lote_impl.tta_cdn_cliente),
                                        INPUT ""). 
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
           ASSIGN tt-tit-criados.cod_estab          = tt-param.cod-estab
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
       END.
   END.

   RETURN "OK".
END PROCEDURE.

PROCEDURE pi-retorna-sugestao-referencia :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    /************************ Parameter Definition Begin ************************/
    DEF INPUT  PARAM p_ind_tip_atualiz AS CHAR FORMAT "X(08)"      NO-UNDO.
    DEF INPUT  PARAM p_dat_refer       AS DATE FORMAT "99/99/9999" NO-UNDO.
    DEF OUTPUT PARAM p_cod_refer       AS CHAR FORMAT "x(10)"      NO-UNDO.
    DEF INPUT  PARAM p_cod_table       AS CHAR FORMAT "x(8)"       NO-UNDO.
    DEF INPUT  PARAM p_estabel         AS CHAR FORMAT "x(3)"       NO-UNDO.

    /************************* Parameter Definition End *************************/

    /************************* Variable Definition Begin ************************/

    DEF VAR v_des_dat   AS CHAR NO-UNDO. /*local*/
    DEF VAR v_num_aux   AS INT  NO-UNDO. /*local*/
    DEF VAR v_num_aux_2 AS INT  NO-UNDO. /*local*/
    DEF VAR v_num_cont  AS INT  NO-UNDO. /*local*/

    /************************** Variable Definition End *************************/

    ASSIGN v_des_dat   = STRING(p_dat_refer,"99999999")
           p_cod_refer = SUBSTRING(p_ind_tip_atualiz,1,2) + SUBSTRING(v_des_dat,7,2)
                       + SUBSTRING(v_des_dat,3,2) + SUBSTRING(v_des_dat,1,2)
           v_num_aux_2 = INT(this-PROCEDURE:HANDLE).

    DO v_num_cont = 1 TO 2:
        ASSIGN v_num_aux   = (RANDOM(0,v_num_aux_2) MOD 26) + 97
               p_cod_refer = p_cod_refer + CHR(v_num_aux).
    END.
    
    RUN pi-verifica-refer-unica-acr (INPUT p_estabel,
                                     INPUT p_cod_refer,
                                     INPUT p_cod_table,
                                     INPUT ?,
                                     OUTPUT v_log_refer_uni) /*pi-verifica-refer-unica-acr*/.

    IF v_log_refer_uni = NO THEN
            RUN pi-retorna-sugestao-referencia (INPUT  "BP",
                                                INPUT  TODAY,
                                                OUTPUT p_cod_refer,
                                                INPUT  p_cod_table,
                                                INPUT  p_estabel).
    
END PROCEDURE. /* pi_retorna_sugestao_referencia */

PROCEDURE pi-verifica-refer-unica-acr :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/


    /************************ Parameter Definition Begin ************************/

    DEF INPUT  PARAM p_cod_estab     AS CHAR FORMAT "x(3)"    NO-UNDO.
    DEF INPUT  PARAM p_cod_refer     AS CHAR FORMAT "x(10)"   NO-UNDO.
    DEF INPUT  PARAM p_cod_table     AS CHAR FORMAT "x(8)"    NO-UNDO.
    DEF INPUT  PARAM p_rec_tabela    AS RECID     FORMAT ">>>>>>9" NO-UNDO.
    DEF OUTPUT PARAM p_log_refer_uni AS LOGICAL   FORMAT "Sim/Nao" NO-UNDO.

    /************************* Parameter Definition End *************************/

    /************************** Buffer Definition Begin *************************/

    DEF BUFFER b_cobr_especial_acr FOR cobr_especial_acr.
    DEF BUFFER b_lote_impl_tit_acr FOR lote_impl_tit_acr.
    DEF BUFFER b_lote_liquidac_acr FOR lote_liquidac_acr.
    DEF BUFFER b_movto_tit_acr     FOR movto_tit_acr.
    DEF BUFFER b_renegoc_acr       FOR renegoc_acr.

    /*************************** Buffer Definition End **************************/

    /************************* Variable Definition Begin ************************/

    DEF VAR v_cod_return AS CHAR FORMAT "x(40)" NO-UNDO.

    /************************** Variable Definition End *************************/

    ASSIGN p_log_refer_uni = YES.

    IF p_cod_table <> "lote_impl_tit_acr" /*l_lote_impl_tit_acr*/  THEN DO:
        FIND FIRST b_lote_impl_tit_acr NO-LOCK USE-INDEX ltmplttc_id
             WHERE b_lote_impl_tit_acr.cod_estab = p_cod_estab
               AND b_lote_impl_tit_acr.cod_refer = p_cod_refer
               AND RECID( b_lote_impl_tit_acr ) <> p_rec_tabela NO-ERROR.
        IF AVAIL b_lote_impl_tit_acr THEN
            ASSIGN p_log_refer_uni = NO.
    END.

    IF p_cod_table <> "lote_liquidac_acr" /*l_lote_liquidac_acr*/  THEN DO:
        FIND FIRST b_lote_liquidac_acr NO-LOCK USE-INDEX ltlqdccr_id
             where b_lote_liquidac_acr.cod_estab_refer = p_cod_estab
               and b_lote_liquidac_acr.cod_refer       = p_cod_refer
               and recid( b_lote_liquidac_acr )       <> p_rec_tabela NO-ERROR.
        IF AVAIL b_lote_liquidac_acr THEN
            ASSIGN p_log_refer_uni = NO.
    END.

    IF p_cod_table = 'cobr_especial_acr' THEN DO:
        FIND FIRST b_cobr_especial_acr NO-LOCK USE-INDEX cbrspclc_id
             WHERE b_cobr_especial_acr.cod_estab = p_cod_estab
               AND b_cobr_especial_acr.cod_refer = p_cod_refer
               AND RECID( b_cobr_especial_acr ) <> p_rec_tabela NO-ERROR.
        IF AVAIL b_cobr_especial_acr THEN
            ASSIGN p_log_refer_uni = NO.
    END.

    IF p_log_refer_uni = YES THEN DO:
        FIND FIRST b_renegoc_acr NO-LOCK
             WHERE b_renegoc_acr.cod_estab = p_cod_estab
               AND b_renegoc_acr.cod_refer = p_cod_refer
               AND RECID(b_renegoc_acr)   <> p_rec_tabela NO-ERROR.
        IF AVAIL b_renegoc_acr THEN
            ASSIGN p_log_refer_uni = NO.
        ELSE DO:
            FIND FIRST b_movto_tit_acr NO-LOCK USE-INDEX mvtttcr_refer
                 WHERE b_movto_tit_acr.cod_estab = p_cod_estab
                   AND b_movto_tit_acr.cod_refer = p_cod_refer
                   AND RECID(b_movto_tit_acr)   <> p_rec_tabela NO-ERROR.
            IF AVAIL b_movto_tit_acr THEN
                ASSIGN p_log_refer_uni = NO.
        END.
    END.

END PROCEDURE. /* pi_verifica_refer_unica_acr */

PROCEDURE pi-retorna-digito-verificador-bradesco :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

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
