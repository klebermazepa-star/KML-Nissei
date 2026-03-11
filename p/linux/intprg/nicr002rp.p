/********************************************************************************
*******************************************************************************/
{include/i-prgvrs.i NICR002RP 2.06.00.001}  
{include/i_fnctrad.i}
/******************************************************************************
**
**       PROGRAMA: NICR002RP
**
**       DATA....: 04/2016
**
**       OBJETIVO: Geraá∆o do Titulo Pai. 
**
**       VERSAO..: 2.06.001
** 
******************************************************************************/
DEFINE BUFFER portador      FOR ems5.portador.
DEFINE BUFFER bf-fat-duplic FOR fat-duplic.

{include/i-rpvar.i}
{include/i-rpcab.i}

/* {utp/ut-glob.i} */ 
def new Global shared var c-seg-usuario        as char format "x(12)" no-undo.

{method/dbotterr.i} 
{intprg/nicr002rp.i}
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
    .

DEFINE VARIABLE v_log_refer_uni AS LOGICAL   NO-UNDO.

DEFINE TEMP-TABLE tt-fatura-loja NO-UNDO
    FIELD cod-estab     LIKE nota-fiscal.cod-estabel
    FIELD serie         LIKE nota-fiscal.serie
    FIELD nro-cupom     LIKE nota-fiscal.nr-nota-fis
    FIELD cod-emitente  LIKE nota-fiscal.cod-emitente
    FIELD dat-emissao   LIKE fat-duplic.dt-emissao
    FIELD dat-vencto    LIKE fat-duplic.dt-venciment 
    FIELD parcela       LIKE fat-duplic.parcela
    FIELD cod-portador  LIKE nota-fiscal.cod-portador
    FIELD cod-espec     LIKE fat-duplic.cod-esp
    FIELD vl-cupom      LIKE cst_nota_fiscal.valor_dinheiro
    FIELD prefixo       AS CHAR FORMAT "x(4)"
    FIELD conta         LIKE fat-duplic.ct-recven
    FIELD r-fatduplic   AS ROWID
    INDEX idx_001 cod-estab   
                  serie
                  nro-cupom 
                  cod-emitente
                  dat-emissao 
                  dat-vencto  
                  cod-portador
                  cod-espec  
                  parcela  .

DEFINE VARIABLE iNumSeq AS INTEGER     NO-UNDO.
DEFINE VARIABLE lErro   AS LOGICAL     NO-UNDO.

DEFINE TEMP-TABLE tt-fatura-loja-aux LIKE tt-fatura-loja .

DEFINE TEMP-TABLE tt-tit-criados  NO-UNDO
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
find first ems2log.empresa where 
           empresa.ep-codigo = param-global.empresa-prin no-lock no-error.

assign c-programa = "nicr002rp"
       c-versao   = "2.06"
       c-revisao  = "001"
       c-empresa  = empresa.razao-social.

find first tt-param no-lock no-error.
{include/i-rpout.i}
{utp/ut-liter.i Geraá∆o_T°tulo_Pai * L}
assign c-titulo-relat = trim(return-value).
{utp/ut-liter.i Geraá∆o_T°tulo_Pai * L}
assign c-sistema = trim(return-value).

VIEW frame f-cabec.
view frame f-rodape.

/* {intprg/nicr002rp.i} */
                    
/* log-manager:logfile-name= "\\192.168.200.52\datasul\_custom_teste\Prog_QG\Geracao_Titulo_Pai.txt". */
/* log-manager:log-entry-types= "4gltrace".                                                           */
     
EMPTY TEMP-TABLE tt-tit-criados.
EMPTY TEMP-TABLE tt-erro.
   
RUN utp/ut-acomp.p PERSISTENT SET h-acomp.
RUN pi-inicializar IN h-acomp (INPUT "Verificando Notas Fiscais").

/* Movimentaá∆o de Dinheiro */
RUN pi-seta-titulo IN h-acomp (INPUT "Movimentaá∆o - Dinheiro":U).
RUN pi-carrega-movto-dinheiro.
RUN pi-seta-titulo IN h-acomp (INPUT "Gerando T°tulo - Dinheiro":U).
RUN pi-gera-titulo-dinheiro.

/* /* Movimentaá∆o de Cheque */                                       */
/* RUN pi-seta-titulo IN h-acomp (INPUT "Movimentaá∆o - Cheque":U).   */
/* RUN pi-carrega-movto-cheque.                                       */
/* RUN pi-seta-titulo IN h-acomp (INPUT "Gerando T°tulo - Cheque":U). */
/* RUN pi-gera-titulo-cheque.                                         */

/* Movimentaá∆o de Cart∆o de CrÇdito */
RUN pi-seta-titulo IN h-acomp (INPUT "Movimentaá∆o - Cart∆o CrÇdito":U).
RUN pi-carrega-movto-credito.
RUN pi-seta-titulo IN h-acomp (INPUT "Gerando T°tulo - CrÇdito":U).
RUN pi-gera-titulo-credito.

/* Movimentaá∆o de Cart∆o de DÇbito */
RUN pi-seta-titulo IN h-acomp (INPUT "Movimentaá∆o - Cart∆o DÇbito":U).
RUN pi-carrega-movto-debito.
RUN pi-seta-titulo IN h-acomp (INPUT "Gerando T°tulo - DÇbito":U).
RUN pi-gera-titulo-debito.

/* Movimentaá∆o de Farm†cia Popular */
RUN pi-seta-titulo IN h-acomp (INPUT "Movimentaá∆o - Farm†cia Popular":U).
RUN pi-carrega-movto-farmacia.
RUN pi-seta-titulo IN h-acomp (INPUT "Gerando T°tulo - Farm†cia Popular":U).
RUN pi-gera-titulo-farmacia.

/* Movimentaá∆o de Dotz */
RUN pi-seta-titulo IN h-acomp (INPUT "Movimentaá∆o - Dotz":U).
RUN pi-carrega-movto-dotz.
RUN pi-seta-titulo IN h-acomp (INPUT "Gerando T°tulo - Dotz":U).
RUN pi-gera-titulo-dotz.

RUN pi-seta-titulo IN h-acomp (INPUT "Imprimindo T°tulos Criados":U).
RUN pi-mostra-titulos-criados.
RUN pi-seta-titulo IN h-acomp (INPUT "Imprimindo Erros":U).
RUN pi-mostra-erros.

RUN pi-finalizar IN h-acomp.                       


/* log-manager:close-log(). */

{include/i-rpclo.i}   

return "OK":U.

PROCEDURE pi-gera-titulo-dinheiro:
    DEFINE VARIABLE c_cod_refer   AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE d-vl-tot-tit  AS DECIMAL     NO-UNDO.
    DEFINE VARIABLE i-cod-parcela AS INTEGER     NO-UNDO.
    DEFINE VARIABLE c-cod-titulo  AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE c-tipo-fluxo  AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE lErro         AS LOGICAL     NO-UNDO.

    FOR EACH tt-fatura-loja NO-LOCK
    BREAK BY tt-fatura-loja.cod-estab 
/*           BY tt-fatura-loja.serie */
          BY tt-fatura-loja.cod-emitente
          BY tt-fatura-loja.dat-emissao 
          BY tt-fatura-loja.dat-vencto  
          BY tt-fatura-loja.cod-portador
          BY tt-fatura-loja.cod-espec  
          BY tt-fatura-loja.parcela :

            IF FIRST-OF(tt-fatura-loja.cod-espec) THEN DO:
                EMPTY TEMP-TABLE tt-fatura-loja-aux NO-ERROR.
                ASSIGN d-vl-tot-tit = 0.
            END.

            ASSIGN d-vl-tot-tit = d-vl-tot-tit + tt-fatura-loja.vl-cupom.

            /* INICIO - Atualiza Campo fat-duplic */
            CREATE tt-fatura-loja-aux.
            BUFFER-COPY tt-fatura-loja TO tt-fatura-loja-aux .
            /* FIM - Atualiza Campo fat-duplic    */

            bloco_trans:
            DO TRANSACTION ON ERROR UNDO:
    
                IF LAST-OF(tt-fatura-loja.cod-espec) THEN DO:
    
                    ASSIGN c-tipo-fluxo = "105"
                           lErro        = NO.
    
                        RUN piCriaTituloACR(INPUT tt-fatura-loja.cod-estab,  
                                            INPUT "DI", 
                                            INPUT tt-fatura-loja.dat-emissao,  
                                            INPUT tt-fatura-loja.dat-vencto,
                                            INPUT "DI", 
                                            INPUT "DINH", 
                                            INPUT "", 
                                            INPUT tt-fatura-loja.cod-emitente, 
                                            INPUT STRING(tt-fatura-loja.cod-portador), 
                                            INPUT d-vl-tot-tit, 
                                            INPUT tt-fatura-loja.parcela,
                                            INPUT tt-fatura-loja.conta, 
                                            INPUT c-tipo-fluxo, 
                                            INPUT "T°tulo do agrupamento das cupons fiscais de dinheiro do dia " + STRING(tt-fatura-loja.dat-emissao,"99/99/9999"), 
                                            OUTPUT lErro).
                        IF lErro = YES THEN
                            UNDO bloco_trans, LEAVE bloco_trans.
                END.
            END. /* bloco_trans */
        
    END.
END PROCEDURE. /* pi-gera-titulo-dinheiro*/

PROCEDURE pi-gera-titulo-cheque:
    DEFINE VARIABLE c_cod_refer   AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE d-vl-tot-tit  AS DECIMAL     NO-UNDO.
    DEFINE VARIABLE i-cod-parcela AS INTEGER     NO-UNDO.
    DEFINE VARIABLE c-cod-titulo  AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE c-tipo-fluxo  AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE lErro         AS LOGICAL     NO-UNDO.

    FOR EACH tt-fatura-loja NO-LOCK
    BREAK BY tt-fatura-loja.cod-estab 
/*           BY tt-fatura-loja.serie */
          BY tt-fatura-loja.cod-emitente
          BY tt-fatura-loja.dat-emissao 
          BY tt-fatura-loja.dat-vencto  
          BY tt-fatura-loja.cod-portador
          BY tt-fatura-loja.cod-espec   :

            IF FIRST-OF(tt-fatura-loja.cod-espec) THEN DO:
                EMPTY TEMP-TABLE tt-fatura-loja-aux NO-ERROR.
                ASSIGN d-vl-tot-tit = 0.
            END.

            ASSIGN d-vl-tot-tit = d-vl-tot-tit + tt-fatura-loja.vl-cupom.

            /* INICIO - Atualiza Campo fat-duplic */
            CREATE tt-fatura-loja-aux.
            BUFFER-COPY tt-fatura-loja TO tt-fatura-loja-aux .
            /* FIM - Atualiza Campo fat-duplic    */    

            bloco_trans:
            DO TRANSACTION ON ERROR UNDO:
    
                IF LAST-OF(tt-fatura-loja.cod-espec) THEN DO:
    
                    ASSIGN c-tipo-fluxo = "145"
                           lErro        = NO.
    
                    RUN piCriaTituloACR(INPUT tt-fatura-loja.cod-estab,  
                                        INPUT "CE", 
                                        INPUT tt-fatura-loja.dat-emissao,  
                                        INPUT tt-fatura-loja.dat-vencto,
                                        INPUT "CE", 
                                        INPUT "CHEQ", 
                                        INPUT "", 
                                        INPUT tt-fatura-loja.cod-emitente, 
                                        INPUT STRING(tt-fatura-loja.cod-portador), 
                                        INPUT d-vl-tot-tit, 
                                        INPUT tt-fatura-loja.parcela,
                                        INPUT tt-fatura-loja.conta, 
                                        INPUT c-tipo-fluxo, 
                                        INPUT "T°tulo do agrupamento das cupons fiscais de cheques do dia " + STRING(tt-fatura-loja.dat-emissao,"99/99/9999"), 
                                        OUTPUT lErro).
                    IF lErro = YES THEN
                        UNDO bloco_trans, LEAVE bloco_trans.
                END.
            END. /* bloco_trans */
    END.
END PROCEDURE. /* pi-gera-titulo-cheque */

PROCEDURE pi-gera-titulo-credito:
    DEFINE VARIABLE c_cod_refer   AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE d-vl-tot-tit  AS DECIMAL     NO-UNDO.
    DEFINE VARIABLE i-cod-parcela AS INTEGER     NO-UNDO.
    DEFINE VARIABLE c-cod-titulo  AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE c-tipo-fluxo  AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE lErro         AS LOGICAL     NO-UNDO.

    FOR EACH tt-fatura-loja NO-LOCK
    BREAK BY tt-fatura-loja.cod-estab 
/*           BY tt-fatura-loja.serie */
          BY tt-fatura-loja.cod-emitente
          BY tt-fatura-loja.dat-emissao 
          BY tt-fatura-loja.dat-vencto  
          BY tt-fatura-loja.cod-portador
          BY tt-fatura-loja.cod-espec   :

            IF FIRST-OF(tt-fatura-loja.cod-espec) THEN DO:
                EMPTY TEMP-TABLE tt-fatura-loja-aux NO-ERROR.
                ASSIGN d-vl-tot-tit = 0.
            END.

            ASSIGN d-vl-tot-tit = d-vl-tot-tit + tt-fatura-loja.vl-cupom.

            /* INICIO - Atualiza Campo fat-duplic */
            CREATE tt-fatura-loja-aux.
            BUFFER-COPY tt-fatura-loja TO tt-fatura-loja-aux .
            /* FIM - Atualiza Campo fat-duplic    */  

            bloco_trans:
            DO TRANSACTION ON ERROR UNDO:
    
                IF LAST-OF(tt-fatura-loja.cod-espec) THEN DO:
    
                    ASSIGN c-tipo-fluxo = "120"
                           lErro        = NO.
    
                    IF tt-fatura-loja.prefixo = "REDE" THEN
                         ASSIGN c-tipo-fluxo = "115".
                    ELSE IF tt-fatura-loja.prefixo = "CIEL" THEN
                         ASSIGN c-tipo-fluxo = "110".
    
                    RUN piCriaTituloACR(INPUT tt-fatura-loja.cod-estab,  
                                        INPUT "CC", 
                                        INPUT tt-fatura-loja.dat-emissao,  
                                        INPUT tt-fatura-loja.dat-vencto,
                                        INPUT "CC", 
                                        INPUT tt-fatura-loja.prefixo, 
                                        INPUT "", 
                                        INPUT tt-fatura-loja.cod-emitente, 
                                        INPUT STRING(tt-fatura-loja.cod-portador), 
                                        INPUT d-vl-tot-tit, 
                                        INPUT tt-fatura-loja.parcela,
                                        INPUT tt-fatura-loja.conta, 
                                        INPUT c-tipo-fluxo, 
                                        INPUT "T°tulo do agrupamento das cupons fiscais de Cart‰es de CrÇdito do dia " + STRING(tt-fatura-loja.dat-emissao,"99/99/9999"), 
                                        OUTPUT lErro).
                    IF lErro = YES THEN
                        UNDO bloco_trans, LEAVE bloco_trans.
                END.
            END. /* bloco_trans */
    END.
END PROCEDURE.

PROCEDURE pi-gera-titulo-debito:
    DEFINE VARIABLE c_cod_refer   AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE d-vl-tot-tit  AS DECIMAL     NO-UNDO.
    DEFINE VARIABLE i-cod-parcela AS INTEGER     NO-UNDO.
    DEFINE VARIABLE c-cod-titulo  AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE c-tipo-fluxo  AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE lErro         AS LOGICAL     NO-UNDO.

    FOR EACH tt-fatura-loja NO-LOCK
    BREAK BY tt-fatura-loja.cod-estab 
/*           BY tt-fatura-loja.serie */
          BY tt-fatura-loja.cod-emitente
          BY tt-fatura-loja.dat-emissao 
          BY tt-fatura-loja.dat-vencto  
          BY tt-fatura-loja.cod-portador
          BY tt-fatura-loja.cod-espec   :

            IF FIRST-OF(tt-fatura-loja.cod-espec) THEN DO:
                EMPTY TEMP-TABLE tt-fatura-loja-aux NO-ERROR.
                ASSIGN d-vl-tot-tit = 0.
            END.

            ASSIGN d-vl-tot-tit = d-vl-tot-tit + tt-fatura-loja.vl-cupom.

            /* INICIO - Atualiza Campo fat-duplic */
            CREATE tt-fatura-loja-aux.
            BUFFER-COPY tt-fatura-loja TO tt-fatura-loja-aux .
            /* FIM - Atualiza Campo fat-duplic    */    

            bloco_trans:
            DO TRANSACTION ON ERROR UNDO:
                IF LAST-OF(tt-fatura-loja.cod-espec) THEN DO:
    
                    ASSIGN c-tipo-fluxo = "135"
                           lErro        = NO.
    
                    IF tt-fatura-loja.prefixo = "REDE" THEN
                         ASSIGN c-tipo-fluxo = "130".
                    ELSE IF tt-fatura-loja.prefixo = "CIEL" THEN
                         ASSIGN c-tipo-fluxo = "125".
    
                    RUN piCriaTituloACR(INPUT tt-fatura-loja.cod-estab,  
                                        INPUT "CD", 
                                        INPUT tt-fatura-loja.dat-emissao,  
                                        INPUT tt-fatura-loja.dat-vencto,
                                        INPUT "CD", 
                                        INPUT tt-fatura-loja.prefixo, 
                                        INPUT "", 
                                        INPUT tt-fatura-loja.cod-emitente, 
                                        INPUT STRING(tt-fatura-loja.cod-portador), 
                                        INPUT d-vl-tot-tit, 
                                        INPUT tt-fatura-loja.parcela,
                                        INPUT tt-fatura-loja.conta, 
                                        INPUT c-tipo-fluxo, 
                                        INPUT "T°tulo do agrupamento das cupons fiscais de Cart‰es DÇbito do dia ":U + STRING(tt-fatura-loja.dat-emissao,"99/99/9999"), 
                                        OUTPUT lErro).
                    IF lErro = YES THEN
                        UNDO bloco_trans, LEAVE bloco_trans.
                END.
            END. /* bloco_trans */
    END.
END PROCEDURE.

PROCEDURE pi-gera-titulo-farmacia:
    DEFINE VARIABLE c_cod_refer   AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE d-vl-tot-tit  AS DECIMAL     NO-UNDO.
    DEFINE VARIABLE i-cod-parcela AS INTEGER     NO-UNDO.
    DEFINE VARIABLE c-cod-titulo  AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE c-tipo-fluxo  AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE lErro         AS LOGICAL     NO-UNDO.

    FOR EACH tt-fatura-loja NO-LOCK
    BREAK BY tt-fatura-loja.cod-estab 
/*           BY tt-fatura-loja.serie */
          BY tt-fatura-loja.cod-emitente
          BY tt-fatura-loja.dat-emissao 
          BY tt-fatura-loja.dat-vencto  
          BY tt-fatura-loja.cod-portador
          BY tt-fatura-loja.cod-espec   :

            IF FIRST-OF(tt-fatura-loja.cod-espec) THEN DO:
                EMPTY TEMP-TABLE tt-fatura-loja-aux NO-ERROR.
                ASSIGN d-vl-tot-tit = 0.
            END.

            ASSIGN d-vl-tot-tit = d-vl-tot-tit + tt-fatura-loja.vl-cupom.

            /* INICIO - Atualiza Campo fat-duplic */
            CREATE tt-fatura-loja-aux.
            BUFFER-COPY tt-fatura-loja TO tt-fatura-loja-aux .
            /* FIM - Atualiza Campo fat-duplic    */ 

            bloco_trans:
            DO TRANSACTION ON ERROR UNDO:
    
                IF LAST-OF(tt-fatura-loja.cod-espec) THEN DO:
    
                    ASSIGN c-tipo-fluxo = "150"
                           lErro        = NO.
    
                    RUN piCriaTituloACR(INPUT tt-fatura-loja.cod-estab,  
                                        INPUT "PO", 
                                        INPUT tt-fatura-loja.dat-emissao,  
                                        INPUT tt-fatura-loja.dat-vencto,
                                        INPUT "PO", 
                                        INPUT tt-fatura-loja.prefixo, 
                                        INPUT "", 
                                        INPUT tt-fatura-loja.cod-emitente, 
                                        INPUT STRING(tt-fatura-loja.cod-portador), 
                                        INPUT d-vl-tot-tit, 
                                        INPUT tt-fatura-loja.parcela,
                                        INPUT tt-fatura-loja.conta, 
                                        INPUT c-tipo-fluxo, 
                                        INPUT "T°tulo do agrupamento das cupons fiscais de Farm†cia Popular do dia ":U + STRING(tt-fatura-loja.dat-emissao,"99/99/9999"), 
                                        OUTPUT lErro).
                    IF lErro = YES THEN
                        UNDO bloco_trans, LEAVE bloco_trans.
                END.
            END. /* bloco_trans */
    END.
END PROCEDURE.

PROCEDURE pi-gera-titulo-dotz:
    DEFINE VARIABLE c_cod_refer   AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE d-vl-tot-tit  AS DECIMAL     NO-UNDO.
    DEFINE VARIABLE i-cod-parcela AS INTEGER     NO-UNDO.
    DEFINE VARIABLE c-cod-titulo  AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE c-tipo-fluxo  AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE lErro         AS LOGICAL     NO-UNDO.

    FOR EACH tt-fatura-loja NO-LOCK
    BREAK BY tt-fatura-loja.cod-estab 
/*           BY tt-fatura-loja.serie */
          BY tt-fatura-loja.cod-emitente
          BY tt-fatura-loja.dat-emissao 
          BY tt-fatura-loja.dat-vencto  
          BY tt-fatura-loja.cod-portador
          BY tt-fatura-loja.cod-espec   :

            IF FIRST-OF(tt-fatura-loja.cod-espec) THEN DO:
                EMPTY TEMP-TABLE tt-fatura-loja-aux NO-ERROR.
                ASSIGN d-vl-tot-tit = 0.
            END.

            ASSIGN d-vl-tot-tit = d-vl-tot-tit + tt-fatura-loja.vl-cupom.

            /* INICIO - Atualiza Campo fat-duplic */
            CREATE tt-fatura-loja-aux.
            BUFFER-COPY tt-fatura-loja TO tt-fatura-loja-aux .
            /* FIM - Atualiza Campo fat-duplic    */    

            bloco_trans:
            DO TRANSACTION ON ERROR UNDO:
    
                IF LAST-OF(tt-fatura-loja.cod-espec) THEN DO:
    
                    ASSIGN c-tipo-fluxo = "155"
                           lErro        = NO.
    
                    RUN piCriaTituloACR(INPUT tt-fatura-loja.cod-estab,  
                                        INPUT "DZ", 
                                        INPUT tt-fatura-loja.dat-emissao,  
                                        INPUT tt-fatura-loja.dat-vencto,
                                        INPUT "DZ", 
                                        INPUT tt-fatura-loja.prefixo, 
                                        INPUT "", 
                                        INPUT tt-fatura-loja.cod-emitente, 
                                        INPUT STRING(tt-fatura-loja.cod-portador), 
                                        INPUT d-vl-tot-tit, 
                                        INPUT tt-fatura-loja.parcela,
                                        INPUT tt-fatura-loja.conta, 
                                        INPUT c-tipo-fluxo, 
                                        INPUT "T°tulo do agrupamento das cupons fiscais de Dotz(s) do dia ":U + STRING(tt-fatura-loja.dat-emissao,"99/99/9999"), 
                                        OUTPUT lErro).
                    IF lErro = YES THEN
                        UNDO bloco_trans, LEAVE bloco_trans.
                END.
            END. /* bloco_trans */
    END.
END PROCEDURE. /* pi-carrega-movto-dotz */


PROCEDURE pi-carrega-movto-dinheiro:

    FOR EACH tt-fatura-loja: DELETE tt-fatura-loja. END.

    FOR EACH fat-duplic
       WHERE fat-duplic.cod-esp       = "DI"
         AND fat-duplic.cod-estab    >= tt-param.c-estab-ini
         AND fat-duplic.cod-estab    <= tt-param.c-estab-fim
         AND fat-duplic.int-1        >= INT(tt-param.c-portador-ini)
         AND fat-duplic.int-1        <= INT(tt-param.c-portador-fim)
         AND fat-duplic.flag-atualiz  = NO NO-LOCK,
       FIRST cst_fat_duplic 
       WHERE cst_fat_duplic.cod_estabel = fat-duplic.cod-estabel
         AND cst_fat_duplic.serie       = fat-duplic.serie
         AND cst_fat_duplic.nr_fatura   = fat-duplic.nr-fatura
         AND cst_fat_duplic.parcela     = fat-duplic.parcela NO-LOCK,
       FIRST nota-fiscal NO-LOCK
       WHERE nota-fiscal.cod-estabel  = fat-duplic.cod-estabel
         AND nota-fiscal.serie        = fat-duplic.serie      
         AND nota-fiscal.nr-fatura    = fat-duplic.nr-fatura
         AND nota-fiscal.dt-emis      >= tt-param.c-data-emissao-ini
         AND nota-fiscal.dt-emis      <= tt-param.c-data-emissao-fim
         AND nota-fiscal.dt-cancel    = ?, 
       FIRST cst_nota_fiscal
       WHERE cst_nota_fiscal.cod_estabel = nota-fiscal.cod-estabel
         AND cst_nota_fiscal.serie       = nota-fiscal.serie
         AND cst_nota_fiscal.nr_nota_fis = nota-fiscal.nr-nota-fis  NO-LOCK,
       FIRST estabelec
       WHERE estabelec.cod-estabel = nota-fiscal.cod-estabel
         AND estabelec.cod-emitente >= tt-param.c-cliente-ini
         AND estabelec.cod-emitente <= tt-param.c-cliente-fim NO-LOCK
          BY fat-duplic.cod-estab :

        RUN pi-acompanhar IN h-acomp (INPUT "Estab/Data/Cupom: " + STRING(nota-fiscal.cod-estabel) + " - " + STRING(fat-duplic.dt-emissao,"99/99/9999") + " - " + STRING(nota-fiscal.nr-nota-fis)).

        CREATE tt-fatura-loja.
        ASSIGN tt-fatura-loja.cod-estab    = nota-fiscal.cod-estabel
               tt-fatura-loja.serie        = nota-fiscal.serie
               tt-fatura-loja.nro-cupom    = nota-fiscal.nr-nota-fis
               tt-fatura-loja.cod-emitente = estabelec.cod-emitente
               tt-fatura-loja.dat-emissao  = fat-duplic.dt-emissao  
               tt-fatura-loja.dat-vencto   = fat-duplic.dt-venciment
               tt-fatura-loja.cod-portador = cst_fat_duplic.cod_portador
               tt-fatura-loja.cod-espec    = fat-duplic.cod-esp
               tt-fatura-loja.vl-cupom     = fat-duplic.vl-parcela
               tt-fatura-loja.conta        = fat-duplic.ct-recven
               tt-fatura-loja.parcela      = fat-duplic.parcela
               tt-fatura-loja.r-fatduplic  = ROWID(fat-duplic).
    END.

END PROCEDURE. /* pi-carrega-movto-dinheiro */

PROCEDURE pi-carrega-movto-cheque:

    FOR EACH tt-fatura-loja: DELETE tt-fatura-loja. END.

    FOR EACH fat-duplic
       WHERE fat-duplic.cod-esp       = "CE"
         AND fat-duplic.cod-estab    >= tt-param.c-estab-ini
         AND fat-duplic.cod-estab    <= tt-param.c-estab-fim
         AND fat-duplic.int-1        >= INT(tt-param.c-portador-ini)
         AND fat-duplic.int-1        <= INT(tt-param.c-portador-fim)
         AND fat-duplic.flag-atualiz  = NO NO-LOCK,
       FIRST cst_fat_duplic 
       WHERE cst_fat_duplic.cod_estabel = fat-duplic.cod-estabel
         AND cst_fat_duplic.serie       = fat-duplic.serie
         AND cst_fat_duplic.nr_fatura   = fat-duplic.nr-fatura
         AND cst_fat_duplic.parcela     = fat-duplic.parcela NO-LOCK,
       FIRST nota-fiscal NO-LOCK
       WHERE nota-fiscal.cod-estabel  = fat-duplic.cod-estabel
         AND nota-fiscal.serie        = fat-duplic.serie      
         AND nota-fiscal.nr-fatura    = fat-duplic.nr-fatura
         AND nota-fiscal.dt-emis      >= tt-param.c-data-emissao-ini
         AND nota-fiscal.dt-emis      <= tt-param.c-data-emissao-fim
         AND nota-fiscal.dt-cancel    = ?, 
       FIRST cst_nota_fiscal
       WHERE cst_nota_fiscal.cod_estabel = nota-fiscal.cod-estabel
         AND cst_nota_fiscal.serie       = nota-fiscal.serie
         AND cst_nota_fiscal.nr_nota_fis = nota-fiscal.nr-nota-fis  NO-LOCK,
       FIRST estabelec
       WHERE estabelec.cod-estabel = nota-fiscal.cod-estabel
         AND estabelec.cod-emitente >= tt-param.c-cliente-ini
         AND estabelec.cod-emitente <= tt-param.c-cliente-fim NO-LOCK
          BY fat-duplic.cod-estab :

        RUN pi-acompanhar IN h-acomp (INPUT "Estab/Data/Cupom: " + STRING(nota-fiscal.cod-estabel) + " - " + STRING(fat-duplic.dt-emissao,"99/99/9999") + " - " + STRING(nota-fiscal.nr-nota-fis)).

        CREATE tt-fatura-loja.
        ASSIGN tt-fatura-loja.cod-estab    = nota-fiscal.cod-estabel
               tt-fatura-loja.serie        = nota-fiscal.serie
               tt-fatura-loja.nro-cupom    = nota-fiscal.nr-nota-fis
               tt-fatura-loja.cod-emitente = estabelec.cod-emitente
               tt-fatura-loja.dat-emissao  = fat-duplic.dt-emissao  
               tt-fatura-loja.dat-vencto   = fat-duplic.dt-venciment
               tt-fatura-loja.cod-portador = cst_fat_duplic.cod_portador
               tt-fatura-loja.cod-espec    = fat-duplic.cod-esp
               tt-fatura-loja.vl-cupom     = fat-duplic.vl-parcela
               tt-fatura-loja.conta        = fat-duplic.ct-recven
               tt-fatura-loja.parcela      = fat-duplic.parcela
               tt-fatura-loja.r-fatduplic  = ROWID(fat-duplic).
    END.

END PROCEDURE. /* pi-carrega-movto-cheque */

PROCEDURE pi-carrega-movto-farmacia:
    FOR EACH tt-fatura-loja: DELETE tt-fatura-loja. END.

    FOR EACH fat-duplic
       WHERE fat-duplic.cod-esp       = "PO"
         AND fat-duplic.cod-estab    >= tt-param.c-estab-ini
         AND fat-duplic.cod-estab    <= tt-param.c-estab-fim
         AND fat-duplic.int-1        >= INT(tt-param.c-portador-ini)
         AND fat-duplic.int-1        <= INT(tt-param.c-portador-fim)
         AND fat-duplic.flag-atualiz  = NO NO-LOCK,
       FIRST cst_fat_duplic 
       WHERE cst_fat_duplic.cod_estabel = fat-duplic.cod-estabel
         AND cst_fat_duplic.serie       = fat-duplic.serie
         AND cst_fat_duplic.nr_fatura   = fat-duplic.nr-fatura
         AND cst_fat_duplic.parcela     = fat-duplic.parcela NO-LOCK,
       FIRST nota-fiscal NO-LOCK
       WHERE nota-fiscal.cod-estabel  = fat-duplic.cod-estabel
         AND nota-fiscal.serie        = fat-duplic.serie      
         AND nota-fiscal.nr-fatura    = fat-duplic.nr-fatura
         AND nota-fiscal.dt-emis      >= tt-param.c-data-emissao-ini
         AND nota-fiscal.dt-emis      <= tt-param.c-data-emissao-fim
         AND nota-fiscal.dt-cancel    = ?, 
       FIRST cst_nota_fiscal
       WHERE cst_nota_fiscal.cod_estabel = nota-fiscal.cod-estabel
         AND cst_nota_fiscal.serie       = nota-fiscal.serie
         AND cst_nota_fiscal.nr_nota_fis = nota-fiscal.nr-nota-fis  NO-LOCK,
       FIRST portador_agrupador
       WHERE portador_agrupador.cod_portador = STRING(fat-duplic.int-1)
         AND portador_agrupador.cod_emitente >= tt-param.c-cliente-ini
         AND portador_agrupador.cod_emitente <= tt-param.c-cliente-fim NO-LOCK
          BY fat-duplic.cod-estab :

        RUN pi-acompanhar IN h-acomp (INPUT "Estab/Data/Cupom: " + STRING(nota-fiscal.cod-estabel) + " - " + STRING(fat-duplic.dt-emissao,"99/99/9999") + " - " + STRING(nota-fiscal.nr-nota-fis)).

        CREATE tt-fatura-loja.
        ASSIGN tt-fatura-loja.cod-estab    = nota-fiscal.cod-estabel
               tt-fatura-loja.serie        = nota-fiscal.serie
               tt-fatura-loja.nro-cupom    = nota-fiscal.nr-nota-fis
               tt-fatura-loja.cod-emitente = portador_agrupador.cod_emitente
               tt-fatura-loja.dat-emissao  = fat-duplic.dt-emissao  
               tt-fatura-loja.dat-vencto   = fat-duplic.dt-venciment
               tt-fatura-loja.cod-portador = cst_fat_duplic.cod_portador
               tt-fatura-loja.cod-espec    = fat-duplic.cod-esp
               tt-fatura-loja.vl-cupom     = fat-duplic.vl-parcela
               tt-fatura-loja.prefixo      = portador_agrupador.prefixo
               tt-fatura-loja.conta        = fat-duplic.ct-recven
               tt-fatura-loja.parcela      = fat-duplic.parcela
               tt-fatura-loja.r-fatduplic  = ROWID(fat-duplic).
    END.
END PROCEDURE. /* pi-carrega-movto-farmacia */

PROCEDURE pi-carrega-movto-dotz:
    FOR EACH tt-fatura-loja: DELETE tt-fatura-loja. END.

    FOR EACH fat-duplic
       WHERE fat-duplic.cod-esp       = "DZ"
         AND fat-duplic.cod-estab    >= tt-param.c-estab-ini
         AND fat-duplic.cod-estab    <= tt-param.c-estab-fim
         AND fat-duplic.int-1        >= INT(tt-param.c-portador-ini)
         AND fat-duplic.int-1        <= INT(tt-param.c-portador-fim)
         AND fat-duplic.flag-atualiz  = NO NO-LOCK,
       FIRST cst_fat_duplic 
       WHERE cst_fat_duplic.cod_estabel = fat-duplic.cod-estabel
         AND cst_fat_duplic.serie       = fat-duplic.serie
         AND cst_fat_duplic.nr_fatura   = fat-duplic.nr-fatura
         AND cst_fat_duplic.parcela     = fat-duplic.parcela NO-LOCK,
       FIRST nota-fiscal NO-LOCK
       WHERE nota-fiscal.cod-estabel  = fat-duplic.cod-estabel
         AND nota-fiscal.serie        = fat-duplic.serie      
         AND nota-fiscal.nr-fatura    = fat-duplic.nr-fatura
         AND nota-fiscal.dt-emis      >= tt-param.c-data-emissao-ini
         AND nota-fiscal.dt-emis      <= tt-param.c-data-emissao-fim
         AND nota-fiscal.dt-cancel    = ?, 
       FIRST cst_nota_fiscal
       WHERE cst_nota_fiscal.cod_estabel = nota-fiscal.cod-estabel
         AND cst_nota_fiscal.serie       = nota-fiscal.serie
         AND cst_nota_fiscal.nr_nota_fis = nota-fiscal.nr-nota-fis  NO-LOCK,
       FIRST portador_agrupador
       WHERE portador_agrupador.cod_portador = STRING(fat-duplic.int-1)
         AND portador_agrupador.cod_emitente >= tt-param.c-cliente-ini
         AND portador_agrupador.cod_emitente <= tt-param.c-cliente-fim NO-LOCK
          BY fat-duplic.cod-estab :

        RUN pi-acompanhar IN h-acomp (INPUT "Estab/Data/Cupom: " + STRING(nota-fiscal.cod-estabel) + " - " + STRING(fat-duplic.dt-emissao,"99/99/9999") + " - " + STRING(nota-fiscal.nr-nota-fis)).

        CREATE tt-fatura-loja.
        ASSIGN tt-fatura-loja.cod-estab    = nota-fiscal.cod-estabel
               tt-fatura-loja.serie        = nota-fiscal.serie
               tt-fatura-loja.nro-cupom    = nota-fiscal.nr-nota-fis
               tt-fatura-loja.cod-emitente = portador_agrupador.cod_emitente
               tt-fatura-loja.dat-emissao  = fat-duplic.dt-emissao  
               tt-fatura-loja.dat-vencto   = fat-duplic.dt-venciment
               tt-fatura-loja.cod-portador = cst_fat_duplic.cod_portador
               tt-fatura-loja.cod-espec    = fat-duplic.cod-esp
               tt-fatura-loja.vl-cupom     = fat-duplic.vl-parcela
               tt-fatura-loja.prefixo      = portador_agrupador.prefixo
               tt-fatura-loja.conta        = fat-duplic.ct-recven
               tt-fatura-loja.parcela      = fat-duplic.parcela
               tt-fatura-loja.r-fatduplic  = ROWID(fat-duplic).
    END.
END PROCEDURE. /* pi-carrega-movto-dotz */

PROCEDURE pi-carrega-movto-credito:
    FOR EACH tt-fatura-loja: DELETE tt-fatura-loja. END.

    FOR EACH fat-duplic
       WHERE fat-duplic.cod-esp       = "CC"
         AND fat-duplic.cod-estab    >= tt-param.c-estab-ini
         AND fat-duplic.cod-estab    <= tt-param.c-estab-fim
         AND fat-duplic.int-1        >= INT(tt-param.c-portador-ini)
         AND fat-duplic.int-1        <= INT(tt-param.c-portador-fim)
         AND fat-duplic.flag-atualiz  = NO NO-LOCK,
       FIRST cst_fat_duplic 
       WHERE cst_fat_duplic.cod_estabel = fat-duplic.cod-estabel
         AND cst_fat_duplic.serie       = fat-duplic.serie
         AND cst_fat_duplic.nr_fatura   = fat-duplic.nr-fatura
         AND cst_fat_duplic.parcela     = fat-duplic.parcela NO-LOCK,
       FIRST nota-fiscal NO-LOCK
       WHERE nota-fiscal.cod-estabel  = fat-duplic.cod-estabel
         AND nota-fiscal.serie        = fat-duplic.serie      
         AND nota-fiscal.nr-fatura    = fat-duplic.nr-fatura
         AND nota-fiscal.dt-emis      >= tt-param.c-data-emissao-ini
         AND nota-fiscal.dt-emis      <= tt-param.c-data-emissao-fim
         AND nota-fiscal.dt-cancel    = ?, 
       FIRST cst_nota_fiscal
       WHERE cst_nota_fiscal.cod_estabel = nota-fiscal.cod-estabel
         AND cst_nota_fiscal.serie       = nota-fiscal.serie
         AND cst_nota_fiscal.nr_nota_fis = nota-fiscal.nr-nota-fis  NO-LOCK,
       FIRST portador_agrupador
       WHERE portador_agrupador.cod_portador = STRING(fat-duplic.int-1)
         AND portador_agrupador.cod_emitente >= tt-param.c-cliente-ini
         AND portador_agrupador.cod_emitente <= tt-param.c-cliente-fim NO-LOCK
          BY fat-duplic.cod-estab :

        RUN pi-acompanhar IN h-acomp (INPUT "Estab/Data/Cupom: " + STRING(nota-fiscal.cod-estabel) + " - " + STRING(fat-duplic.dt-emissao,"99/99/9999") + " - " + STRING(nota-fiscal.nr-nota-fis)).

        CREATE tt-fatura-loja.
        ASSIGN tt-fatura-loja.cod-estab    = nota-fiscal.cod-estabel
               tt-fatura-loja.serie        = nota-fiscal.serie
               tt-fatura-loja.nro-cupom    = nota-fiscal.nr-nota-fis
               tt-fatura-loja.cod-emitente = portador_agrupador.cod_emitente
               tt-fatura-loja.dat-emissao  = fat-duplic.dt-emissao  
               tt-fatura-loja.dat-vencto   = fat-duplic.dt-venciment
               tt-fatura-loja.cod-portador = cst_fat_duplic.cod_portador
               tt-fatura-loja.cod-espec    = fat-duplic.cod-esp
               tt-fatura-loja.vl-cupom     = fat-duplic.vl-parcela
               tt-fatura-loja.prefixo      = portador_agrupador.prefixo
               tt-fatura-loja.conta        = fat-duplic.ct-recven
               tt-fatura-loja.parcela      = fat-duplic.parcela
               tt-fatura-loja.r-fatduplic  = ROWID(fat-duplic).
    END.

END PROCEDURE. /* pi-carrega-movto-credito */

PROCEDURE pi-carrega-movto-debito:

    FOR EACH tt-fatura-loja: DELETE tt-fatura-loja. END.

    FOR EACH fat-duplic
       WHERE fat-duplic.cod-esp       = "CD"
         AND fat-duplic.cod-estab    >= tt-param.c-estab-ini
         AND fat-duplic.cod-estab    <= tt-param.c-estab-fim
         AND fat-duplic.int-1        >= INT(tt-param.c-portador-ini)
         AND fat-duplic.int-1        <= INT(tt-param.c-portador-fim)
         AND fat-duplic.flag-atualiz  = NO NO-LOCK,
       FIRST cst_fat_duplic 
       WHERE cst_fat_duplic.cod_estabel = fat-duplic.cod-estabel
         AND cst_fat_duplic.serie       = fat-duplic.serie
         AND cst_fat_duplic.nr_fatura   = fat-duplic.nr-fatura
         AND cst_fat_duplic.parcela     = fat-duplic.parcela NO-LOCK,
       FIRST nota-fiscal NO-LOCK
       WHERE nota-fiscal.cod-estabel  = fat-duplic.cod-estabel
         AND nota-fiscal.serie        = fat-duplic.serie      
         AND nota-fiscal.nr-fatura    = fat-duplic.nr-fatura
         AND nota-fiscal.dt-emis      >= tt-param.c-data-emissao-ini
         AND nota-fiscal.dt-emis      <= tt-param.c-data-emissao-fim
         AND nota-fiscal.dt-cancel    = ?,
       FIRST cst_nota_fiscal
       WHERE cst_nota_fiscal.cod_estabel = nota-fiscal.cod-estabel
         AND cst_nota_fiscal.serie       = nota-fiscal.serie
         AND cst_nota_fiscal.nr_nota_fis = nota-fiscal.nr-nota-fis  NO-LOCK,
       FIRST portador_agrupador
       WHERE portador_agrupador.cod_portador = STRING(fat-duplic.int-1)
         AND portador_agrupador.cod_emitente >= tt-param.c-cliente-ini
         AND portador_agrupador.cod_emitente <= tt-param.c-cliente-fim NO-LOCK
          BY fat-duplic.cod-estab :

        RUN pi-acompanhar IN h-acomp (INPUT "Estab/Data/Cupom: " + STRING(nota-fiscal.cod-estabel) + " - " + STRING(fat-duplic.dt-emissao,"99/99/9999") + " - " + STRING(nota-fiscal.nr-nota-fis)).

        CREATE tt-fatura-loja.
        ASSIGN tt-fatura-loja.cod-estab    = nota-fiscal.cod-estabel
               tt-fatura-loja.serie        = nota-fiscal.serie
               tt-fatura-loja.nro-cupom    = nota-fiscal.nr-nota-fis
               tt-fatura-loja.cod-emitente = portador_agrupador.cod_emitente
               tt-fatura-loja.dat-emissao  = fat-duplic.dt-emissao  
               tt-fatura-loja.dat-vencto   = fat-duplic.dt-venciment
               tt-fatura-loja.cod-portador = fat-duplic.int-1
               tt-fatura-loja.cod-espec    = fat-duplic.cod-esp
               tt-fatura-loja.vl-cupom     = fat-duplic.vl-parcela
               tt-fatura-loja.prefixo      = portador_agrupador.prefixo
               tt-fatura-loja.conta        = fat-duplic.ct-recven
               tt-fatura-loja.parcela      = fat-duplic.parcela
               tt-fatura-loja.r-fatduplic  = ROWID(fat-duplic).


    END.

END PROCEDURE. /* pi-carrega-movto-debito */


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
        format "Sim/Nío"
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
           tt-erro.ajuda       = p-ajuda.

    RETURN "OK".

END PROCEDURE.

PROCEDURE pi-mostra-titulos-criados:
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

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
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    FOR EACH tt-erro:
           DISP tt-erro.cd-erro
                tt-erro.mensagem FORMAT "x(100)" SKIP
                FILL(" ",13) tt-erro.ajuda    FORMAT "x(150)" NO-LABEL
                 WITH WIDTH 333 STREAM-IO DOWN FRAME f-erro.
           DOWN WITH FRAME f-erro.
    END.    
END PROCEDURE.


PROCEDURE pi-traduz-estab:
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
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
            ASSIGN c-erro = "Matriz Traduªío Estabelecimento Nío Cadastrado. Estab: " + STRING(p-cod-estab-ems-2).

            RETURN "NOK".
        END.
    END.

    RETURN "OK".

END PROCEDURE.

PROCEDURE pi-traduz-empresa:
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
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
        ASSIGN c-erro = "Matriz Traduá∆o Empresa N∆o Cadastrada. Empresa: " + string(p-empresa-ems2).

        RETURN "NOK".
    END.

    RETURN "OK".

END PROCEDURE.

PROCEDURE piCriaTituloACR:
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
DEFINE INPUT  PARAM p-cod-estab       LIKE tit_acr.cod_estab        NO-UNDO. /* C¢digo do Estabelecimento      */ 
DEFINE INPUT  PARAM p-cod-ini-refer   LIKE tit_acr.cod_refer        NO-UNDO. /* C¢digo de Inicio da Referància */ 
DEFINE INPUT  PARAM p-dat-emissao     LIKE tit_acr.dat_emis_docto   NO-UNDO. /* Data de Emiss∆o                */ 
DEFINE INPUT  PARAM p-dat-vencto      LIKE tit_acr.dat_emis_docto   NO-UNDO. /* Data de Vencimento             */ 
DEFINE INPUT  PARAM p-cod-espec-docto LIKE tit_acr.cod_espec_docto  NO-UNDO. /* C¢digo Especie do Docto        */ 
DEFINE INPUT  PARAM p-cod-ini-titulo  LIKE tit_acr.cod_tit_acr      NO-UNDO. /* C¢digo Inicio Codigo do T°tulo */ 
DEFINE INPUT  PARAM p-cod-serie       LIKE tit_acr.cod_ser_docto    NO-UNDO. /* Codigo da Serie                */ 
DEFINE INPUT  PARAM p-cod-emitente    LIKE tit_acr.cdn_cliente      NO-UNDO. /* Codigo do Emitente             */ 
DEFINE INPUT  PARAM p-cod-portador    LIKE tit_acr.cod_portador     NO-UNDO. /* Codigo do Portador             */ 
DEFINE INPUT  PARAM p-valor-movto     LIKE tit_acr.val_sdo_tit_acr  NO-UNDO. /* Valor do Movimento             */
DEFINE INPUT  PARAM p-parcela         LIKE tit_acr.cod_parcela      NO-UNDO. /* C¢digo da parcela              */
DEFINE INPUT  PARAM p-conta-contabil  AS CHAR FORMAT "x(20)"        NO-UNDO. /* Codigo Conta Contabil          */
DEFINE INPUT  PARAM p-cod-fluxo       AS CHAR FORMAT "x(10)"        NO-UNDO. /* Codigo Fluxo Financeiro        */
DEFINE INPUT  PARAM p-observacao      AS CHAR FORMAT "x(200)"       NO-UNDO. /* Descriá∆o do Movimento         */
DEFINE OUTPUT PARAM p-log-erro        AS LOGICAL                    NO-UNDO. /* Existe Erros na Implantaá∆o    */

DEFINE VARIABLE c_cod_refer           AS CHARACTER                  NO-UNDO.
DEFINE VARIABLE i-cod-parcela         AS INTEGER                    NO-UNDO.
DEFINE VARIABLE c-cod-titulo          AS CHARACTER                  NO-UNDO.

     EMPTY TEMP-TABLE tt_integr_acr_item_lote_impl_8 NO-ERROR.
     EMPTY TEMP-TABLE tt_integr_acr_repres_comis_2   NO-ERROR.
     EMPTY TEMP-TABLE tt_integr_acr_aprop_ctbl_pend  NO-ERROR.
     EMPTY TEMP-TABLE tt_log_erros_atualiz           NO-ERROR.
     EMPTY TEMP-TABLE tt_integr_acr_lote_impl        NO-ERROR.

     /*Retorna Matriz Traduá∆o Organizacional*/
     RUN prgint/ufn/ufn908za.py (INPUT "1":u,
                                 INPUT "15":U,
                                 OUTPUT v_cod_matriz_trad_org_ext).
     /*Traduá∆o Estabelecimento*/
     RUN pi-traduz-estab(INPUT  v_cod_matriz_trad_org_ext,
                         INPUT  p-cod-estab, /*Estabelecimento EMS 2*/
                         OUTPUT c-estab-ems-5,
                         OUTPUT c-erro).
     /*Traduá∆o Empresa*/
     RUN pi-traduz-empresa(INPUT  v_cod_matriz_trad_org_ext,
                           INPUT  v_cdn_empres_usuar, /*Empresa EMS 2*/
                           OUTPUT c-empresa-ems-5,
                           OUTPUT c-erro).
    
     ASSIGN c_cod_refer = "".
     RUN pi_retorna_sugestao_referencia (INPUT  p-cod-ini-refer,
                                         INPUT  TODAY,
                                         OUTPUT c_cod_refer,
                                         INPUT  "tit_acr",
                                         INPUT  STRING(tt-fatura-loja.cod-estab)).

     /* Criaá∆o do lote cont†bil */
     CREATE tt_integr_acr_lote_impl. 
     ASSIGN tt_integr_acr_lote_impl.tta_cod_empresa        = c-empresa-ems-5            /*ObrigatΩrio*/
            tt_integr_acr_lote_impl.ttv_cod_empresa_ext    = string(v_cdn_empres_usuar) /*ObrigatΩrio*/
            tt_integr_acr_lote_impl.tta_cod_estab          = c-estab-ems-5              /*ObrigatΩrio*/
            tt_integr_acr_lote_impl.tta_cod_estab_ext      = p-cod-estab                /*ObrigatΩrio*/ 
            tt_integr_acr_lote_impl.tta_dat_transacao      = p-dat-emissao
            tt_integr_acr_lote_impl.tta_ind_orig_tit_acr   = "2"
            tt_integr_acr_lote_impl.tta_ind_tip_cobr_acr   = "Normal"
            tt_integr_acr_lote_impl.tta_log_liquidac_autom = NO
            tt_integr_acr_lote_impl.ttv_log_lote_impl_ok   = YES
            tt_integr_acr_lote_impl.tta_cod_refer          = c_cod_refer.

     ASSIGN c-cod-titulo  = p-cod-ini-titulo + REPLACE(STRING(p-dat-emissao,"99/99/99"),"/","")
            i-cod-parcela = 1.

     FIND LAST tit_acr
         WHERE tit_acr.cod_estab       = p-cod-estab
           AND tit_acr.cod_espec_docto = p-cod-espec-docto
           AND tit_acr.cod_ser_docto   = p-cod-serie
           AND tit_acr.cod_tit_acr     = c-cod-titulo NO-LOCK NO-ERROR.

     IF AVAIL tit_acr THEN DO:
         ASSIGN i-cod-parcela = INT(tit_acr.cod_parcela) + 1.
     END.

     CREATE tt_integr_acr_item_lote_impl_8.
     ASSIGN tt_integr_acr_item_lote_impl_8.ttv_rec_lote_impl_tit_acr      = RECID(tt_integr_acr_lote_impl)
            tt_integr_acr_item_lote_impl_8.ttv_rec_item_lote_impl_tit_acr = RECID(tt_integr_acr_item_lote_impl_8)
            tt_integr_acr_item_lote_impl_8.tta_cod_refer                  = tt_integr_acr_lote_impl.tta_cod_refer
            tt_integr_acr_item_lote_impl_8.tta_cdn_cliente                = p-cod-emitente                        
            tt_integr_acr_item_lote_impl_8.tta_num_seq_refer              = 1
            tt_integr_acr_item_lote_impl_8.tta_cod_espec_docto            = p-cod-espec-docto 
            tt_integr_acr_item_lote_impl_8.tta_ind_tip_espec_docto        = "2" 
            tt_integr_acr_item_lote_impl_8.tta_cod_ser_docto              = p-cod-serie
            tt_integr_acr_item_lote_impl_8.tta_cod_portad_ext             = p-cod-portador
            tt_integr_acr_item_lote_impl_8.tta_cod_modalid_ext            = "6"
            tt_integr_acr_item_lote_impl_8.tta_cod_tit_acr                = c-cod-titulo
            tt_integr_acr_item_lote_impl_8.tta_cod_parcela                = STRING(i-cod-parcela,"99") 
            tt_integr_acr_item_lote_impl_8.tta_cod_indic_econ             = ""
            tt_integr_acr_item_lote_impl_8.tta_cod_cart_bcia              = "CAR" 
            tt_integr_acr_item_lote_impl_8.tta_cod_finalid_econ_ext       = "0"
            tt_integr_acr_item_lote_impl_8.tta_ind_sit_tit_acr            = "Normal" /*ObrigatΩrio*/
            tt_integr_acr_item_lote_impl_8.tta_cdn_repres                 = 0        
            tt_integr_acr_item_lote_impl_8.tta_dat_vencto_tit_acr         = p-dat-vencto
            tt_integr_acr_item_lote_impl_8.tta_dat_prev_liquidac          = p-dat-vencto
            tt_integr_acr_item_lote_impl_8.tta_dat_emis_docto             = p-dat-emissao
            tt_integr_acr_item_lote_impl_8.tta_des_text_histor            = p-observacao
            tt_integr_acr_item_lote_impl_8.tta_cod_cond_pagto             = ""
            tt_integr_acr_item_lote_impl_8.tta_val_cotac_indic_econ       = 1
            tt_integr_acr_item_lote_impl_8.tta_ind_sit_bcia_tit_acr       = "1"
            tt_integr_acr_item_lote_impl_8.tta_ind_ender_cobr             = "1"
            tt_integr_acr_item_lote_impl_8.tta_log_liquidac_autom         = NO
            tt_integr_acr_item_lote_impl_8.ttv_cod_nota_fisc_faturam      = ""
            tt_integr_acr_item_lote_impl_8.tta_val_tit_acr                = p-valor-movto
            tt_integr_acr_item_lote_impl_8.tta_val_liq_tit_acr            = p-valor-movto
            tt_integr_acr_item_lote_impl_8.tta_des_obs_cobr               = "".

     RUN pi-acompanhar IN h-acomp (INPUT "Est/Esp/Ser/Tit./Par: ":U + STRING(tt_integr_acr_lote_impl.tta_cod_estab) + "/" +
                                                                      STRING(tt_integr_acr_item_lote_impl_8.tta_cod_espec_docto) + "/" + 
                                                                      STRING(tt_integr_acr_item_lote_impl_8.tta_cod_ser_docto)   + "/" + 
                                                                      STRING(tt_integr_acr_item_lote_impl_8.tta_cod_tit_acr) + "/" +
                                                                      STRING(tt_integr_acr_item_lote_impl_8.tta_cod_parcela)).

     CREATE tt_integr_acr_aprop_ctbl_pend.
     ASSIGN tt_integr_acr_aprop_ctbl_pend.ttv_rec_item_lote_impl_tit_acr  = tt_integr_acr_item_lote_impl_8.ttv_rec_item_lote_impl_tit_acr
            tt_integr_acr_aprop_ctbl_pend.tta_cod_plano_cta_ctbl          = "PADRAO"     
            tt_integr_acr_aprop_ctbl_pend.tta_cod_cta_ctbl                = p-conta-contabil 
            tt_integr_acr_aprop_ctbl_pend.tta_cod_cta_ctbl_ext            = "" 
            tt_integr_acr_aprop_ctbl_pend.tta_cod_sub_cta_ctbl_ext        = "" 
            tt_integr_acr_aprop_ctbl_pend.tta_cod_unid_negoc              = "000" 
            tt_integr_acr_aprop_ctbl_pend.tta_cod_unid_negoc_ext          = "" 
            tt_integr_acr_aprop_ctbl_pend.tta_cod_plano_ccusto            = "" 
            tt_integr_acr_aprop_ctbl_pend.tta_cod_ccusto                  = "" 
            tt_integr_acr_aprop_ctbl_pend.tta_cod_ccusto_ext              = "" 
            tt_integr_acr_aprop_ctbl_pend.tta_cod_tip_fluxo_financ        = p-cod-fluxo
            tt_integr_acr_aprop_ctbl_pend.tta_cod_fluxo_financ_ext        = ""
            tt_integr_acr_aprop_ctbl_pend.tta_log_impto_val_agreg         = NO
            tt_integr_acr_aprop_ctbl_pend.tta_val_aprop_ctbl              = tt_integr_acr_item_lote_impl_8.tta_val_tit_acr. 


     /* INICIO - ATUALIZAÄ«O DO FINANCEIRO */
     RUN prgfin/acr/acr900zi.py persistent set v_hdl_api_integr_acr.
     RUN pi_main_code_integr_acr_new_9 IN v_hdl_api_integr_acr (INPUT 11,
                                                                INPUT v_cod_matriz_trad_org_ext, /*Matriz Trad Org Ext*/
                                                                INPUT YES,                       /*Log Atualiz Refer*/
                                                                INPUT NO,                       /*Assume Data Emiss*/
                                                                INPUT TABLE tt_integr_acr_repres_comis_2,
                                                                INPUT-OUTPUT TABLE tt_integr_acr_item_lote_impl_8,
                                                                INPUT TABLE tt_integr_acr_aprop_relacto_2).

     DELETE PROCEDURE v_hdl_api_integr_acr.
     /* FIM    - ATUALIZAÄ«O DO FINANCEIRO */

     /*Tratamento de erros*/
     IF CAN-FIND(FIRST tt_log_erros_atualiz) THEN DO:
         FIND FIRST tt_integr_acr_item_lote_impl_8 NO-LOCK NO-ERROR.
         IF AVAIL tt_integr_acr_item_lote_impl_8 THEN DO:
             RUN pi-cria-tt-erro(INPUT tt_integr_acr_item_lote_impl_8.tta_num_seq_refer,
                                 INPUT 17006, 
                                 INPUT "Houve erro na criaá∆o do titulo abaixo, favor verificar.",
                                 INPUT "Estab/Especie/Serie/Titulo/Parcela/Cliente/Portador : " +  STRING(p-cod-estab) + "/" +
                                                                                                   STRING(tt_integr_acr_item_lote_impl_8.tta_cod_espec_docto) + "/" +
                                                                                                   STRING(tt_integr_acr_item_lote_impl_8.tta_cod_ser_docto) + "/" +
                                                                                                   STRING(tt_integr_acr_item_lote_impl_8.tta_cod_tit_acr) + "/" +
                                                                                                   STRING(tt_integr_acr_item_lote_impl_8.tta_cod_parcela) + "/" +
                                                                                                   STRING(tt_integr_acr_item_lote_impl_8.tta_cdn_cliente) + "/"  +
                                                                                                   STRING(tt_integr_acr_item_lote_impl_8.tta_cod_portad_ext)   ). 
         END.

         FOR EACH tt_log_erros_atualiz:
             RUN pi-cria-tt-erro(INPUT tt_log_erros_atualiz.tta_num_seq_refer,
                                 INPUT tt_log_erros_atualiz.ttv_num_mensagem, 
                                 INPUT tt_log_erros_atualiz.ttv_des_msg_erro,
                                 INPUT tt_log_erros_atualiz.ttv_des_msg_ajuda).
         END.

         ASSIGN p-log-erro = YES.
         RETURN "OK".
     END.
     ELSE DO:
         ASSIGN iNumSeq = 0.

         ASSIGN vlTaxaCartao = 0.
         FOR EACH tt_integr_acr_item_lote_impl_8 NO-LOCK:
             CREATE tt-tit-criados.
             ASSIGN tt-tit-criados.cod_estab          = p-cod-estab
                    tt-tit-criados.cod_espec_docto    = tt_integr_acr_item_lote_impl_8.tta_cod_espec_docto
                    tt-tit-criados.cod_ser_docto      = tt_integr_acr_item_lote_impl_8.tta_cod_ser_docto
                    tt-tit-criados.cod_tit_acr        = tt_integr_acr_item_lote_impl_8.tta_cod_tit_acr
                    tt-tit-criados.cod_parcela        = tt_integr_acr_item_lote_impl_8.tta_cod_parcela              
                    tt-tit-criados.cdn_cliente        = tt_integr_acr_item_lote_impl_8.tta_cdn_cliente
                    tt-tit-criados.cod_portador       = tt_integr_acr_item_lote_impl_8.tta_cod_portad_ext
                    tt-tit-criados.val_origin_tit_acr = tt_integr_acr_item_lote_impl_8.tta_val_tit_acr
                    tt-tit-criados.dat_transacao      = tt_integr_acr_item_lote_impl_8.tta_dat_emis_docto    
                    tt-tit-criados.dat_emis_docto     = tt_integr_acr_item_lote_impl_8.tta_dat_emis_docto    
                    tt-tit-criados.dat_vencto_tit_acr = tt_integr_acr_item_lote_impl_8.tta_dat_vencto_tit_acr
                    tt-tit-criados.situacao           = "T°tulo Gerado"
                 .

             FIND FIRST tit_acr NO-LOCK
                  WHERE tit_acr.cod_estab       = p-cod-estab
                    AND tit_acr.cod_espec_docto = tt_integr_acr_item_lote_impl_8.tta_cod_espec_docto
                    AND tit_acr.cod_ser_docto   = tt_integr_acr_item_lote_impl_8.tta_cod_ser_docto  
                    AND tit_acr.cod_tit_acr     = tt_integr_acr_item_lote_impl_8.tta_cod_tit_acr    
                    AND tit_acr.cod_parcela     = tt_integr_acr_item_lote_impl_8.tta_cod_parcela     NO-ERROR.
             IF AVAIL tit_acr THEN DO:
                 FOR EACH tt-fatura-loja-aux: 
                     ASSIGN iNumSeq = iNumSeq + 1.
                     FOR FIRST fat-duplic
                         WHERE ROWID(fat-duplic) = tt-fatura-loja-aux.r-fatduplic NO-LOCK,
                         FIRST cst_fat_duplic 
                         WHERE cst_fat_duplic.cod_estabel = fat-duplic.cod-estabel
                           AND cst_fat_duplic.serie       = fat-duplic.serie
                           AND cst_fat_duplic.nr_fatura   = fat-duplic.nr-fatura
                           AND cst_fat_duplic.parcela     = fat-duplic.parcela EXCLUSIVE-LOCK,
                         FIRST nota-fiscal EXCLUSIVE-LOCK
                         WHERE nota-fiscal.cod-estabel  = fat-duplic.cod-estabel
                           AND nota-fiscal.serie        = fat-duplic.serie      
                           AND nota-fiscal.nr-fatura    = fat-duplic.nr-fatura,
                         FIRST cst_nota_fiscal
                         WHERE cst_nota_fiscal.cod_estabel = nota-fiscal.cod-estabel
                           AND cst_nota_fiscal.serie       = nota-fiscal.serie
                           AND cst_nota_fiscal.nr_nota_fis = nota-fiscal.nr-nota-fis  NO-LOCK:

                         ASSIGN cst_fat_duplic.num_id_tit_acr = tit_acr.num_id_tit_acr.

                         ASSIGN vlTaxaCartao = vlTaxaCartao + cst_fat_duplic.taxa_admin.

                         CREATE tit_acr_cartao.
                         ASSIGN tit_acr_cartao.num_id_tit_acr         = tit_acr.num_id_tit_acr
                                tit_acr_cartao.num_seq                = iNumSeq
                                tit_acr_cartao.cod_admdra             = IF cst_fat_duplic.adm_cartao = ? THEN "" ELSE cst_fat_duplic.adm_cartao
                                tit_acr_cartao.cod_autoriz_cartao_cr  = IF cst_fat_duplic.autorizacao = "" OR cst_fat_duplic.autorizacao = ? THEN "0" ELSE cst_fat_duplic.autorizacao 
                                tit_acr_cartao.cod_comprov_vda        = IF cst_fat_duplic.nsu_num = "" OR cst_fat_duplic.nsu_num = ? THEN "0" ELSE cst_fat_duplic.nsu_num
                                tit_acr_cartao.cod_empresa            = tit_acr.cod_empresa
                                tit_acr_cartao.cod_estab              = tit_acr.cod_estab
                                tit_acr_cartao.cod_parc               = fat-duplic.parcela 
                                tit_acr_cartao.dat_atualiz            = TODAY
                                tit_acr_cartao.dat_cred_cartao_cr     = ?
                                tit_acr_cartao.dat_vda_cartao_cr      = tit_acr.dat_emis_docto 
                                tit_acr_cartao.hra_atualiz            = REPLACE(STRING(TIME, "HH:MM:SS"), ":","")
                                tit_acr_cartao.val_comprov_vda        = fat-duplic.vl-parcela
                                tit_acr_cartao.val_des_admdra         = IF cst_fat_duplic.taxa_admin = ? THEN 0 ELSE cst_fat_duplic.taxa_admin
                                tit_acr_cartao.num_cupom              = cst_nota_fiscal.nr_nota_fis
                                tit_acr_cartao.cartao_manual          = cst_nota_fiscal.cartao_manual
                                tit_acr_cartao.serie_cupom            = cst_nota_fiscal.serie
                             .

                          
                         FIND FIRST bf-fat-duplic EXCLUSIVE-LOCK
                              WHERE ROWID(bf-fat-duplic) = ROWID(fat-duplic) NO-ERROR.
                         IF AVAIL bf-fat-duplic THEN DO:
                             ASSIGN bf-fat-duplic.flag-atualiz = YES.
                         END.
                         RELEASE bf-fat-duplic.
                         

                         /* INICIO - Atualiza Campo Atualizado CR, da tabela Nota-Fiscal  */
                         IF NOT CAN-FIND(FIRST bf-fat-duplic
                                         WHERE bf-fat-duplic.cod-estabel  = nota-fiscal.cod-estabel
                                           AND bf-fat-duplic.serie        = nota-fiscal.serie
                                           AND bf-fat-duplic.nr-fatura    = nota-fiscal.nr-nota-fis 
                                           AND bf-fat-duplic.flag-atualiz = NO) AND nota-fiscal.dt-atual-cr = ? THEN DO:
                             ASSIGN nota-fiscal.dt-atual-cr = TODAY.
                         END.
                         /* FIM    - Atualiza Campo Atualizado CR, da tabela Nota-Fiscal  */

                     END.
                     RELEASE cst_fat_duplic.
                 END.
                 ASSIGN iNumSeq = 0.

                 /* INICIO - Criaá∆o da Taxa Cart∆o - Alteraá∆o do T°tulo */
                 IF vlTaxaCartao > 0 AND (p-cod-espec-docto = "CC" OR p-cod-espec-docto = "CD") THEN DO:
                     ASSIGN lErro = NO.
                     RUN piCriaAlteracaoTaxaCartao(INPUT tit_acr.cod_estab,
                                                   INPUT tit_acr.num_id_tit_acr,
                                                   INPUT "TAXA",
                                                   INPUT vlTaxaCartao,
                                                   INPUT "Alteraá∆o do T°tulo devido a TAXA do Cart∆o",
                                                   OUTPUT lErro).


                     IF lErro = YES THEN DO:
                         FIND FIRST tt-tit-criados EXCLUSIVE-LOCK
                              WHERE tt-tit-criados.cod_estab          = p-cod-estab                                       
                                AND tt-tit-criados.cod_espec_docto    = tt_integr_acr_item_lote_impl_8.tta_cod_espec_docto
                                AND tt-tit-criados.cod_ser_docto      = tt_integr_acr_item_lote_impl_8.tta_cod_ser_docto  
                                AND tt-tit-criados.cod_tit_acr        = tt_integr_acr_item_lote_impl_8.tta_cod_tit_acr    
                                AND tt-tit-criados.cod_parcela        = tt_integr_acr_item_lote_impl_8.tta_cod_parcela    
                                AND tt-tit-criados.cdn_cliente        = tt_integr_acr_item_lote_impl_8.tta_cdn_cliente     NO-ERROR.
                         IF AVAIL tt-tit-criados THEN DO:
                             DELETE tt-tit-criados.
                         END.

                         ASSIGN p-log-erro = YES.
                         RETURN "OK".
                     END.
                 END.
                 /* FIM    - Criaá∆o da Taxa Cart∆o - Alteraá∆o do T°tulo */
             END.    
         END.
     END. /* ELSE Erros Importaá∆o*/
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
    DEFINE VARIABLE v_log_integr_cmg  AS LOGICAL   FORMAT "Sim/N∆o":U INITIAL NO LABEL "CMG" COLUMN-LABEL "CMG" NO-UNDO.

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
           tt_alter_tit_acr_base_5.ttv_ind_motiv_acerto_val        = "Alteraá∆o":U
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
                                INPUT "Houve erro na alteraá∆o do titulo abaixo, favor verificar.",
                                INPUT "Estab/Especie/Serie/Titulo/Parcela/Cliente: " +  STRING(tit_acr.cod_estab) + "/" +
                                                                                        STRING(tit_acr.cod_espec_docto) + "/" +
                                                                                        STRING(tit_acr.cod_ser_docto) + "/" +
                                                                                        STRING(tit_acr.cod_tit_acr) + "/" +
                                                                                        STRING(tit_acr.cod_parcela) + "/" +
                                                                                        STRING(tit_acr.cdn_cliente)). 
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

