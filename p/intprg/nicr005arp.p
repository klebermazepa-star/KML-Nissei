/********************************************************************************

*******************************************************************************/
{include/i-prgvrs.i RE0411RP 2.00.00.010 } /*** 010010 ***/

/* &IF "{&EMSFND_VERSION}" >= "1.00" &THEN        */
/*     {include/i-license-manager.i re0411rp MRE} */
/* &ENDIF                                         */

    {include/i_fnctrad.i}
/******************************************************************************
**
**       Programa: re0411
**
**       Objetivo: Integraá∆o Devoluá∆o Convànio com Contas a Receber
**
******************************************************************************/
DEFINE BUFFER empresa FOR ems2mult.empresa.

{cdp/cdcfgmat.i}
{rep/re1005.i22} /* Funá∆o Integraá∆o RE X EMS 5 */

/* A variavel abaixo Ç utilizada para identificar se o relatorio de erros deve ser impresso ou n∆o, nas includes re1005.i21 e .i15.
   ê necess†ria pq as includes s∆o executadas pelo programa re0411, e neste n∆o devem ser impressos os erros no layout do re1005. */
DEF VAR l-rel-erros AS LOG INIT NO NO-UNDO.
DEF NEW GLOBAL SHARED VAR lContaFtPorCliente AS LOG NO-UNDO INIT ?.

IF  lContaFtPorCliente = ? THEN
    ASSIGN lContaFtPorCliente = 
              CAN-FIND(funcao 
                        WHERE funcao.cd-funcao = "spp-ContaFtCli":U
                        AND   funcao.ativo NO-LOCK).

define temp-table tt-param no-undo
    field destino          as integer
    field arquivo          as char format "x(35)":U
    field usuario          as char format "x(12)":U
    field data-exec        as date
    field hora-exec        as integer
    field classifica       as integer
    field desc-classifica  as char format "x(40)":U
    field modelo           AS char format "x(35)":U
    field l-habilitaRtf    as LOG
    FIELD c-destino        AS CHAR FORMAT "x(12)"
    FIELD dt-trans-ini     AS DATE FORMAT "99/99/9999"
    FIELD dt-trans-fim     AS DATE FORMAT "99/99/9999"
    FIELD c-estab-ini      AS CHAR FORMAT "x(3)"
    FIELD c-estab-fim      AS CHAR FORMAT "x(3)".

def temp-table tt-raw-digita 
    field raw-digita as raw.

def input param raw-param as raw no-undo.
def input param table for tt-raw-digita.

{crp/crapi017.i}  /* 2.03 - Definicao TT-TOT-TIT/TT-TITULO/TT-TOT-TIT-MP/TT-TITULO-MP */
{crp/crapi017.i2} /* Definicao TT-TOT-TIT-DEVOL E TT-TOT-TIT-MP-DEVOL */
{ftp/ft0603b.i}                     /* DefiniØ o tt-tot-tit-ext         - Internacional */

{utp/ut-glob.i}
{cdp/cd0666.i}    /** Definicao TT-ERRO      * */
{rep/re0104.i}    /** Verifica funcao Unid-Neg-Devol-Cli **/
{rep/re0104.i1}   /** Definicao da tt-un-devol **/
{rep/re1005.i01}  /** Variaveis p/ Impress∆o **/
{rep/re1005.i05}  /** Definicao TT-RATEIO    **/
{cdp/cd7300.i1}   /** multi-planta **/
{btb/btb009za.i}  /** tt_erros_conexao **/
{rep/re1005b.i NEW} /** tt-movto - Utilizada no re1005b5.p **/

{include/i-epc200.i re0411rp} /** Upc **/

def temp-table tt-erro-cr no-undo  /* conforme prgfin/acr/acr779za.py */
    field cod-estab        as character format "x(3)" label "Estabelecimento" column-label "Estab" 
    field cod-refer        as character format "x(10)" label "Referància" column-label "Referància" 
    field num-seq-refer    as integer format ">>>9" initial 0 label "Sequància" column-label "Seq" 
    field num-mensagem     as integer format ">>>>,>>9" label "N£mero" column-label "N£mero Mensagem" 
    field des-msg-erro     as character format "x(60)" label "Mensagem Erro" column-label "Inconsistància" 
    field des-msg-ajuda    as character format "x(40)" label "Mensagem Ajuda" column-label "Mensagem Ajuda" 
    field ind-tip-relacto  as character format "X(15)" label "Tipo Relacionamento" column-label "Tipo Relac" 
    field num-relacto      as integer format ">>>>,>>9" label "Relacionamento" column-label "Relacionamento".     

def var h-acomp            as handle  no-undo.
def var h-btb009za         as handle  no-undo.

def var l-ja-conectado          as logical no-undo.
def var l-conec-bas             as logical no-undo.
def var l-conec-fin             as logical no-undo.
def var l-conec-uni             as logical no-undo.
DEF VAR l-erro                  AS LOGICAL NO-UNDO.
DEF VAR h-cd9500                AS HANDLE  NO-UNDO.
DEF VAR rw-conta-ft             AS ROWID   NO-UNDO.
DEF VAR c-cab1 AS CHAR FORMAT "x(132)" NO-UNDO.
DEF VAR c-cab2 AS CHAR FORMAT "x(132)" NO-UNDO.
DEF VAR c-cab3 AS CHAR FORMAT "x(132)" NO-UNDO.
DEF VAR c-msg  AS CHAR FORMAT "x(120)" NO-UNDO.
DEF VAR c-texto AS CHAR FORMAT "x(20)" NO-UNDO.

def var c-lb-inicial as char no-undo.
def var c-lb-final   as char no-undo.
def var c-lb-data    as char no-undo.
def var c-lb-estab   as char no-undo.
def var c-lb-selec   as char no-undo.
def var c-lb-impr    as char no-undo.
def var c-lb-dest    as char no-undo.
def var c-lb-usuar   as char no-undo.

DEF BUFFER b-docum-est    FOR docum-est.
DEF BUFFER b-item-doc-est FOR item-doc-est.

def var i-empresa like param-global.empresa-prin no-undo.

DEFINE VARIABLE h-re1005b5  AS HANDLE NO-UNDO.

{include/i-rpvar.i}
{include/tt-edit.i}

run utp/ut-acomp.p persistent set h-acomp.
{utp/ut-liter.i Integraá∆o_com_Contas_a_Receber *}
run pi-inicializar in h-acomp ( Return-value ).

find first param-global no-lock no-error.
assign i-empresa = param-global.empresa-prin.

find empresa where
     empresa.ep-codigo = i-empresa no-lock no-error.

create tt-param.
raw-transfer raw-param to tt-param.

assign c-empresa  = (if avail param-global then param-global.grupo else "")
       c-programa = "RE/0411"
       c-versao   = "1.00"
       c-revisao  = "000".

{utp/ut-liter.i Integraá∆o_com_Contas_a_Receber * r}
assign c-titulo-relat = trim(return-value).
{utp/ut-liter.i RECEBIMENTO * r}
assign c-sistema = trim(return-value).

{utp/ut-liter.i Documento     * R} ASSIGN c-cab1 =          TRIM(RETURN-VALUE) + "        ". 
{utp/ut-liter.i Ser           * R} ASSIGN c-cab1 = c-cab1 + TRIM(RETURN-VALUE) + "   ". 
{utp/ut-liter.i Nat_Oper      * R} ASSIGN c-cab1 = c-cab1 + TRIM(RETURN-VALUE) + "    ". 
{utp/ut-liter.i Emitente      * R} ASSIGN c-cab1 = c-cab1 + TRIM(RETURN-VALUE) + "   ". 
{utp/ut-liter.i Nome_Abrev    * R} ASSIGN c-cab1 = c-cab1 + TRIM(RETURN-VALUE) + "     ". 
{utp/ut-liter.i Nota_Fatur    * R} ASSIGN c-cab1 = c-cab1 + TRIM(RETURN-VALUE) + "       ". 
{utp/ut-liter.i Ser           * R} ASSIGN c-cab1 = c-cab1 + TRIM(RETURN-VALUE) + "     ". 
{utp/ut-liter.i Est           * R} ASSIGN c-cab1 = c-cab1 + TRIM(RETURN-VALUE) + " ". 
{utp/ut-liter.i PA            * R} ASSIGN c-cab1 = c-cab1 + TRIM(RETURN-VALUE) + " ". 
{utp/ut-liter.i Esp           * R} ASSIGN c-cab1 = c-cab1 + TRIM(RETURN-VALUE) + "  ". 
{utp/ut-liter.i Emiss∆o       * R} ASSIGN c-cab1 = c-cab1 + TRIM(RETURN-VALUE) + "    ". 
{utp/ut-liter.i Transaá∆o     * R} ASSIGN c-cab1 = c-cab1 + TRIM(RETURN-VALUE).

{utp/ut-liter.i Erro     * R} ASSIGN c-cab2 =          TRIM(RETURN-VALUE) + "   ".
{utp/ut-liter.i Mensagem * R} ASSIGN c-cab2 = c-cab2 + TRIM(RETURN-VALUE).

ASSIGN c-cab3 = FILL("-",132).

{include/i-rpcab.i}
{include/i-rpout.i}

IF  NOT VALID-HANDLE(h-cd9500) THEN
    RUN cdp/cd9500.p PERSISTENT SET h-cd9500.

if  l-acr-ems50 then do:
    run pi-conecta-ems50 ( 1 ). /* 1 = conecta */
    if l-erro then do:
       {include/i-rpclo.i}
       run pi-finalizar in h-acomp.
       undo, return "NOK".
    end.  
end.   

DEFINE VARIABLE c-cgc AS CHARACTER   NO-UNDO.
DEFINE VARIABLE c-cod-emitente LIKE nota-fiscal.cod-emitente.
  
find param-re where param-re.usuario = c-seg-usuario no-lock no-error.

view frame f-cabec.
view frame f-rodape.

{utp/ut-liter.i Atualizando_Nota * R}


 FOR EACH cst_fat_devol
    WHERE cst_fat_devol.modo_devolucao = "Nenhum"
      AND cst_fat_devol.nro_comp       <> "" EXCLUSIVE-LOCK,
    FIRST b-item-doc-est NO-LOCK
    WHERE b-item-doc-est.nro-comp   = cst_fat_devol.nro_comp
      AND b-item-doc-est.serie-comp = cst_fat_devol.serie_comp,
    FIRST b-docum-est OF b-item-doc-est NO-LOCK
    WHERE b-docum-est.cod-estab    = cst_fat_devol.cod_estab_comp
      AND b-docum-est.dt-trans    >= tt-param.dt-trans-ini
      AND b-docum-est.dt-trans    <= tt-param.dt-trans-fim
      AND b-docum-est.cod-estabel >= tt-param.c-estab-ini
      AND b-docum-est.cod-estabel <= tt-param.c-estab-fim
      AND b-docum-est.ce-atual     = YES
      AND b-docum-est.esp-docto    = 20
      AND b-docum-est.cr-atual     = NO
    :
    
    FIND FIRST estabelec
         WHERE estabelec.cod-estabel = b-docum-est.cod-estabel NO-LOCK NO-ERROR.

    FIND FIRST emitente 
         WHERE emitente.cod-emitente = b-docum-est.cod-emitente NO-LOCK NO-ERROR.
    
    ASSIGN c-cgc = ''.
    FIND FIRST cst_nota_fiscal 
         WHERE cst_nota_fiscal.nr_nota_fis  = cst_fat_devol.nro_comp  
           AND cst_nota_fiscal.serie        = cst_fat_devol.serie_comp       
           AND cst_nota_fiscal.cod_estabel  = cst_fat_devol.cod_estab_comp NO-LOCK NO-ERROR.
    IF AVAIL cst_nota_fiscal THEN DO:
    
        ASSIGN c-cod-emitente = b-docum-est.cod-emitente.
        ASSIGN c-cgc = replace(cst_nota_fiscal.cpf_cupom,".","").
        ASSIGN c-cgc = replace(c-cgc,"/","").
        ASSIGN c-cgc = replace(c-cgc,"-","").
        IF emitente.cgc <> c-cgc THEN DO:
            FIND FIRST emitente WHERE emitente.cgc =  c-cgc NO-LOCK NO-ERROR.
            IF AVAIL emitente THEN DO:
                ASSIGN c-cod-emitente = emitente.cod-emitente.
            END.
            ELSE DO:
               FIND FIRST emitente 
                    WHERE emitente.cod-emitente = b-docum-est.cod-emitente NO-LOCK NO-ERROR.
            END.
        END.
    END.

    FIND FIRST natur-oper
         WHERE natur-oper.nat-operacao = b-docum-est.nat-operacao NO-LOCK NO-ERROR.

    if  valid-handle (h-acomp) THEN
        run pi-acompanhar in h-acomp (input c-texto + ": " + STRING(b-docum-est.nro-docto)).

/*     bloco_trans:                  */
/*     DO TRANSACTION ON ERROR UNDO: */

        FOR EACH tt-tot-tit-devol: 
            DELETE tt-tot-tit-devol. 
        END.
        FOR EACH tt-tot-tit: 
            DELETE tt-tot-tit. 
        END.
        FOR EACH tt-titulo: 
            DELETE tt-titulo. 
        END.

        EMPTY TEMP-TABLE tt-erro.
        EMPTY TEMP-TABLE tt-un-devol.
    
        FIND FIRST docum-est EXCLUSIVE-LOCK
            WHERE ROWID(docum-est) = ROWID(b-docum-est) NO-ERROR.

        FOR EACH item-doc-est NO-LOCK
            WHERE item-doc-est.serie-docto  = b-docum-est.serie-docto
              AND item-doc-est.nro-docto    = b-docum-est.nro-docto
              AND item-doc-est.cod-emitente = b-docum-est.cod-emitente
              AND item-doc-est.nat-operacao = b-docum-est.nat-operacao:
    
            FIND FIRST ITEM
                 WHERE ITEM.it-codigo = item-doc-est.it-codigo NO-LOCK NO-ERROR.
    
            /* CONSISTENCIAS DA NOTA FISCAL */
            assign l-erro        = no.

            /* Leitura contas do Faturamento */
            RUN pi-leitura-conta-ft.
      
            /* ATUALIZACAO DOS ITENS DA NOTA FISCAL */
            run rep/re1005b5.p  PERSISTENT SET h-re1005b5
                            ( ROWID(item-doc-est),
                            INPUT-OUTPUT TABLE tt-tot-tit,
                            INPUT-OUTPUT TABLE tt-titulo,
                            INPUT-OUTPUT TABLE tt-erro,
                            INPUT rw-conta-ft,
                            INPUT-OUTPUT TABLE tt-un-devol).
                
            IF h-re1005b5:GET-SIGNATURE ("pi-retorna-tt-impto-retid-fat") <> "" THEN DO:
                RUN pi-retorna-tt-impto-retid-fat IN h-re1005b5 (OUTPUT TABLE tt-impto-retid-fat APPEND).  
            END.
                
            DELETE PROCEDURE h-re1005b5.
            ASSIGN h-re1005b5 = ?.

        END. /* for each item-docum-est */

        /* Atualiza Contas a Receber */
        IF  can-find (first tt-tot-tit) then do:
            run pi-atualiza-cr ( output l-erro ).

            FOR EACH tt-tot-tit, 
                EACH tt-titulo                                      
                     where tt-titulo.sequencia = tt-tot-tit.sequencia:
        
                if  line-counter > 62 then
                     page.

                if  line-counter <= 5 then do:
                    put c-cab1 at 0 SKIP
                        c-cab2 at 0 skip
                        c-cab3 AT 0 SKIP.
                end.

                PUT docum-est.nro-docto    SPACE(1)
                    docum-est.serie-docto  SPACE(1)
                    docum-est.nat-operacao SPACE(5)
                    docum-est.cod-emitente SPACE(3)
                    emitente.nome-abrev    SPACE(3)
                    tt-tot-tit.nr-docto    SPACE(1)
                    tt-tot-tit.serie       SPACE(3)
                    tt-tot-tit.cod-estabel SPACE(1)
                    tt-titulo.parcela      SPACE(2)
                    tt-tot-tit.cod-esp     SPACE(2)
                    docum-est.dt-emissao   SPACE(1)
                    tt-tot-tit.dt-trans
                    SKIP. 

                IF  CAN-FIND(FIRST tt-erro) THEN
                    FOR EACH tt-erro:
                        PUT tt-erro.cd-erro FORMAT ">>>>>9" SPACE(1).

                        run pi-print-editor (input tt-erro.mensagem, input 120).
                        for each tt-editor:
                            put tt-editor.conteudo at 10 format "X(120)" skip.
                        end.
                    END.
                ELSE DO:
                    run utp/ut-msgs.p ( input "msg",
                                        input 4070,
                                        input "" ).  

                    ASSIGN c-msg = TRIM(RETURN-VALUE).
                    put string(4070,">>>>>9") FORMAT "x(6)" SPACE(1)
                        c-msg
                        skip.
                END.
            END.

/*             if  NOT docum-est.cr-atual then do: */
/*                 UNDO bloco_trans, NEXT.         */
/*             end.                                */
       
        END.
    

END. /* for each docum-est */

if  l-acr-ems50 then
    run pi-conecta-ems50 ( 2 ). /* Disconecta bancos do EMS 5.0 */

{utp/ut-liter.i Data_Transaá∆o  * r} assign c-lb-data    = trim(return-value).
{utp/ut-liter.i Estabelecimento * r} assign c-lb-estab   = trim(return-value).
{utp/ut-liter.i Inicial         * r} assign c-lb-inicial = trim(return-value).
{utp/ut-liter.i Final           * r} assign c-lb-final   = trim(return-value).
{utp/ut-liter.i Destino         * r} assign c-lb-dest    = trim(return-value).
{utp/ut-liter.i Usu†rio         * r} assign c-lb-usuar   = trim(return-value).
{utp/ut-liter.i SELEÄ«O         * r} assign c-lb-selec   = trim(return-value).
{utp/ut-liter.i IMPRESS«O       * r} assign c-lb-impr    = trim(return-value).

page.
put unformatted
    c-lb-selec           skip(1)
    c-lb-inicial AT 23 c-lb-final AT 39 
    "-------"    AT 23 "-----" AT 39 
    c-lb-data            at 5  ":"
    tt-param.dt-trans-ini format "99/99/9999" at 23 tt-param.dt-trans-fim format "99/99/9999" AT 39
    c-lb-estab           at 5  ":"
    tt-param.c-estab-ini at 23  tt-param.c-estab-fim AT 39
    skip(1).

put unformatted
    c-lb-impr            skip(1)
    c-lb-dest            at 5  ": " tt-param.c-destino " - " tt-param.arquivo
    c-lb-usuar           at 5  ": " tt-param.usuario.

IF  VALID-HANDLE(h-acomp) THEN
    run pi-finalizar in h-acomp.

{include/i-rpclo.i}

IF  VALID-HANDLE(h-cd9500) THEN
    DELETE PROCEDURE h-cd9500.
ASSIGN h-cd9500 = ?.

return "OK".

DEF TEMP-TABLE tt-impto-retid-fat-aux NO-UNDO LIKE tt-impto-retid-fat.

/*** Procedures Internas  ***/

{rep/re1005.i10} /* pi-leitura-conta-ft */
{rep/re1005.i14} /* Pi-conecta-ems50 */ 
{rep/re1005.i15} /* Pi-conecta-ems50-cr */
{rep/re1005.i21} /* pi-atualiza-cr */

{include/pi-edit.i}

/* Fim do Programa */
