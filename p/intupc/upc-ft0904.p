/********************************************************************************
** Copyright DATASUL S.A. (1997)
** Todos os Direitos Reservados.
**
** Este fonte e de propriedade exclusiva da DATASUL, sua reproducao
** parcial ou total por qualquer meio, so podera ser feita mediante
** autorizacao expressa.
*******************************************************************************/
{include/i-prgvrs.i UPC-FT0904 2.12.00.001}  /*** 010000 ***/

/******************************************************************************
**  upc-FT0904.P - Desconto do cartão
**               
******************************************************************************/
{include/i_dbvers.i}
{utp/ut-glob.i}

DEF INPUT PARAM P-IND-EVENT        AS CHAR           NO-UNDO.
DEF INPUT PARAM P-IND-OBJECT       AS CHAR           NO-UNDO.
DEF INPUT PARAM P-WGH-OBJECT       AS HANDLE         NO-UNDO.
DEF INPUT PARAM P-WGH-FRAME        AS WIDGET-HANDLE  NO-UNDO.
DEF INPUT PARAM P-COD-TABLE        AS CHAR           NO-UNDO.
DEF INPUT PARAM P-ROW-TABLE        AS ROWID          NO-UNDO.

DEF NEW GLOBAL SHARED VAR wh-cod-estabel-ft0904   AS WIDGET-HANDLE NO-UNDO.
DEF NEW GLOBAL SHARED VAR wh-serie-ft0904         AS WIDGET-HANDLE NO-UNDO.
DEF NEW GLOBAL SHARED VAR wh-nr-nota-fis-ft0904   AS WIDGET-HANDLE NO-UNDO.
DEF NEW GLOBAL SHARED VAR row-ft0904              AS ROWID NO-UNDO.
DEF NEW GLOBAL SHARED VAR wh-br-ft0904            AS HANDLE NO-UNDO.

DEFINE VARIABLE h-cd9500            AS HANDLE                    NO-UNDO.
DEFINE VARIABLE r-conta-ft          AS ROWID                     NO-UNDO.
DEFINE VARIABLE de-vl-desconto      LIKE nota-fiscal.vl-desconto NO-UNDO.
DEFINE VARIABLE h_api_cta           as handle                    no-undo.
define variable v_cod_cta           as char                      no-undo.
define variable v_des_cta           as char                      no-undo.
define variable v_num_tip_cta       as int                       no-undo.
define variable v_num_sit_cta       as int                       no-undo.
define variable v_ind_finalid_cta   as char                      no-undo.
DEFINE VARIABLE v_cod_formato       AS CHAR                      NO-UNDO.

DEFINE VARIABLE wh-bt-esocial-ft0904 AS WIDGET-HANDLE NO-UNDO.
DEFINE VARIABLE wh-bt-cupom-ft0904 AS WIDGET-HANDLE NO-UNDO.

/*
MESSAGE p-ind-event              "p-ind-event  " skip 
         p-ind-object             "p-ind-object " skip
         p-wgh-object:FILE-NAME   "p-wgh-object " skip
         p-wgh-frame:NAME         "p-wgh-frame  " skip
         p-cod-table              "p-cod-table  " skip
        string(p-row-table)      "p-row-table  " skip 
 VIEW-AS ALERT-BOX INFO BUTTONS OK.                   
*/
/* define variable  v_cod_ccust             as char   no-undo.
define variable  v_des_ccust             as char   no-undo.
define variable  v_cod_format_cta        as char   no-undo.
define variable  v_cod_finalid           as char   no-undo.
define variable  v_cod_modul             as char   no-undo.
define variable  v_cod_format_ccust      as char   no-undo.
define variable  v_cod_format_inic       as char   no-undo.
define variable  v_cod_format_fim        as char   no-undo.


define variable  v_log_utz_ccust         as log    no-undo.
define variable  v_cod_format_inic_ccust as char   no-undo.
define variable  v_cod_format_fim_ccust  as char   no-undo.
define variable  l-utiliza-ccusto        as log    no-undo.
*/

def temp-table tt_log_erro no-undo
    field ttv_num_cod_erro  as integer format ">>>>,>>9" label "N£mero" column-label "N£mero"
    field ttv_des_msg_ajuda as character format "x(40)" label "Mensagem Ajuda" column-label "Mensagem Ajuda"
    field ttv_des_msg_erro  as character format "x(60)" label "Mensagem Erro" column-label "Inconsistˆncia".

FUNCTION buscarHandleCampo RETURNS WIDGET-HANDLE (INPUT pcCampo   AS CHARACTER,
                                                  INPUT whPointer AS WIDGET-HANDLE).
    DEFINE VARIABLE wh-grupo AS WIDGET-HANDLE NO-UNDO.
    DEFINE VARIABLE wh-child AS WIDGET-HANDLE NO-UNDO.
    IF  whPointer <> ? THEN
        wh-grupo = whPointer:FIRST-CHILD.
    ELSE 
        wh-grupo = p-wgh-frame:FIRST-CHILD.
    DO  WHILE VALID-HANDLE(wh-grupo):
        CASE wh-grupo:NAME:
             WHEN pcCampo THEN RETURN wh-grupo.
        END.
        IF wh-grupo:TYPE = "field-group" THEN
           wh-grupo = wh-grupo:FIRST-CHILD.
        ELSE
           wh-grupo = wh-grupo:NEXT-SIBLING.
    END.                                             
END FUNCTION.

IF p-ind-event  = "initialize" AND  
   p-ind-object = "viewer" AND
   p-wgh-object:FILE-NAME = "divwr/v02di135.w"
THEN DO:  
    wh-cod-estabel-ft0904 = buscarHandleCampo("cod-estabel", p-wgh-frame).
    wh-serie-ft0904       = buscarHandleCampo("serie", p-wgh-frame).
    wh-nr-nota-fis-ft0904 = buscarHandleCampo("nr-nota-fis", p-wgh-frame).
END.
IF p-ind-event  = "initialize" AND  
   p-ind-object = "container" THEN DO:
    wh-bt-esocial-ft0904 = buscarHandleCampo("bt-esocial", p-wgh-frame).
    IF VALID-HANDLE (wh-bt-esocial-ft0904) THEN DO:

       CREATE BUTTON wh-bt-cupom-ft0904
       ASSIGN FRAME     = wh-bt-esocial-ft0904:FRAME                        
              LABEL     = wh-bt-esocial-ft0904:LABEL                            
              FONT      = wh-bt-esocial-ft0904:FONT
              WIDTH     = wh-bt-esocial-ft0904:WIDTH
              HEIGHT    = wh-bt-esocial-ft0904:HEIGHT
              ROW       = wh-bt-esocial-ft0904:ROW
              COL       = wh-bt-esocial-ft0904:COL - 20
              FGCOLOR   = ?
              BGCOLOR   = ?
              CONVERT-3D-COLORS = wh-bt-esocial-ft0904:convert-3D-COLORS
              TOOLTIP   = "Informa‡äes adicionais CUPOM Fiscal"
              VISIBLE   = wh-bt-esocial-ft0904:VISIBLE                                        
              SENSITIVE = wh-bt-esocial-ft0904:SENSITIVE
              TRIGGERS:
                  ON CHOOSE PERSISTENT RUN intprg/int020a.w.
              END TRIGGERS.

              /*
              wh-bt-cupom-ft0904:LOAD-IMAGE-UP(wh-bt-esocial-ft0904:IMAGE-UP).
              wh-bt-cupom-ft0904:LOAD-IMAGE-INSENSITIVE(wh-bt-esocial-ft0904:IMAGE-INSENSITIVE).
              */
              wh-bt-cupom-ft0904:MOVE-TO-TOP().
    END.   

END.
/*
IF  p-ind-event  = "AFTER-OPEN-QUERY" AND 
    p-ind-object = "BROWSER"          AND 
    P-WGH-OBJECT:NAME  = "dibrw/b32di135.w" 
THEN DO: 
    DEF VAR h-query-ft0904 AS HANDLE.
    DEF VAR hField         AS HANDLE.
    DEF VAR i-cont         AS INT.
    
    DEFINE VARIABLE hTTped-curva    AS HANDLE    NO-UNDO.
    DEFINE VARIABLE hQuery          AS HANDLE    NO-UNDO.
    DEFINE VARIABLE hBufferTT       AS HANDLE    NO-UNDO.
   
    def temp-table tt-ped-curva
    field it-codigo   as char format 'x(16)' label "item"
    field codigo      AS CHARACTER FORMAT "x(20)" 
    field desc-conta  AS CHARACTER FORMAT "x(32)" 
    FIELD ccusto      AS CHARACTER FORMAT "x(20)" 
    FIELD desc-centro AS CHARACTER FORMAT "x(32)" 
    field serie       like it-nota-fisc.serie
    field nr-nota-fis like it-nota-fisc.nr-nota-fis
    field cont        as int
    field dec-1       as dec format '>>>>>>>>>>>9.99'
    field vl-credito  as dec format '>>>>>>>>>>>9.99' label 'Cr‚dito'
    field vl-debito   as dec format '>>>>>>>>>>>9.99' label 'D‚bito'
    FIELD cod-unid-negoc LIKE unid-negoc.cod-unid-negoc.
    
    FOR FIRST nota-fiscal NO-LOCK WHERE 
              ROWID(nota-fiscal) = row-ft0904,
        FIRST emitente NO-LOCK WHERE 
              emitente.cod-emitente = nota-fiscal.cod-emitente:
           
        ASSIGN de-vl-desconto = 0.

        RUN pi-gera-ped-curva.

    END.

    IF de-vl-desconto > 0 
    THEN DO:
    
        ASSIGN wh-br-ft0904 =  buscarHandleCampo("br_table", p-wgh-frame).
        
        ASSIGN h-query-ft0904 = wh-br-ft0904:QUERY:HANDLE.
    
        h-query-ft0904:QUERY-CLOSE().
        
        ASSIGN hTTped-curva = h-query-ft0904:GET-BUFFER-HANDLE().
                  
        CREATE BUFFER hBufferTT FOR TABLE hTTped-curva BUFFER-NAME "b-tt-ped-curva".
                  
        CREATE QUERY hQuery.
        hQuery:SET-BUFFERS(hBufferTT).
        hQuery:QUERY-PREPARE("for each b-tt-ped-curva").
        hQuery:QUERY-OPEN.
        hQuery:GET-FIRST().
    
        IF AVAIL tt-ped-curva 
        THEN DO:
           hBufferTT:BUFFER-CREATE().                     
           hBufferTT:BUFFER-COPY(BUFFER tt-ped-curva:HANDLE).
        END. 
    
        h-query-ft0904:QUERY-PREPARE("for each tt-ped-curva").
        APPLY "value-changed" TO wh-br-ft0904. 
        h-query-ft0904:QUERY-OPEN(). 

    END.

END.   

IF p-ind-event  = "display"  AND
   p-ind-object = "viewer"   AND 
   P-WGH-OBJECT:NAME  = "divwr/v02di135.w" 
THEN DO:
    
   ASSIGN wh-cod-estabel-ft0904 =  buscarHandleCampo("cod-estabel", p-wgh-frame).
          wh-serie-ft0904       =  buscarHandleCampo("serie"      , p-wgh-frame).
          wh-nr-nota-fis-ft0904 =  buscarHandleCampo("nr-nota-fis", p-wgh-frame).

   IF VALID-HANDLE(wh-cod-estabel-ft0904) THEN
      ASSIGN row-ft0904 = P-ROW-TABLE.

END.

PROCEDURE pi-gera-ped-curva:
    
        
    RUN cdp/cd9500.p PERSISTENT SET h-cd9500.

    FOR FIRST it-nota-fisc OF nota-fiscal NO-LOCK,
        FIRST ITEM FIELDS(it-codigo) NO-LOCK 
        WHERE ITEM.it-codigo = it-nota-fisc.it-codigo:

        RUN pi-cd9500 in h-cd9500 (nota-fiscal.cod-estabel,
                                   emitente.cod-gr-cli,
                                   rowid(item),
                                   it-nota-fisc.nat-oper,
                                   it-nota-fisc.serie,
                                   it-nota-fisc.cod-depos,
                                   nota-fiscal.cod-canal-venda,
                                   output r-conta-ft).
    END.

  /**** Calcular o desconto da nota ***/

     find first cst-nota-fiscal no-lock where
                cst-nota-fiscal.nr-nota-fis = nota-fiscal.nr-nota-fis and 
                cst-nota-fiscal.serie       = nota-fiscal.serie       and
                cst-nota-fiscal.cod-estabel = nota-fiscal.cod-estabel no-error.
     if avail cst-nota-fiscal then do:
     
          FOR EACH cst-fat-duplic no-lock where 
                   cst-fat-duplic.cod-estabel = nota-fiscal.cod-estabel and
                   cst-fat-duplic.serie       = nota-fiscal.serie and
                   cst-fat-duplic.nr-fatura   = nota-fiscal.nr-fatura:
             
               ASSIGN de-vl-desconto = de-vl-desconto +  cst-fat-duplic.taxa-admin. 
                     
          END. 
     end.    
    
    IF de-vl-desconto > 0 
    THEN DO:
        FIND FIRST param-global NO-LOCK NO-ERROR.
    
        FOR FIRST conta-ft NO-LOCK WHERE 
                rowid(conta-ft) = r-conta-ft,
                FIRST int-ds-conta-ft NO-LOCK WHERE
                      int-ds-conta-ft.cod-estabel      = conta-ft.cod-estabel       AND 
                      int-ds-conta-ft.cod-gr-cli       = conta-ft.cod-gr-cli        AND
                      int-ds-conta-ft.cod-canal-venda  = conta-ft.cod-canal-venda   AND 
                      int-ds-conta-ft.ge-codigo        = conta-ft.ge-codigo         AND
                      int-ds-conta-ft.fm-codigo        = conta-ft.fm-codigo         AND
                      int-ds-conta-ft.nat-operacao     = conta-ft.nat-operacao      AND
                      int-ds-conta-ft.serie            = conta-ft.serie             AND
                      int-ds-conta-ft.cod-depos        = conta-ft.cod-depos ,                   
                FIRST estabelec NO-LOCK WHERE 
                      estabelec.cod-estabel = nota-fiscal.cod-estabel:
            
            RUN prgint\utb\utb743za.py PERSISTENT SET h_api_cta.
    
            ASSIGN v_cod_cta = int-ds-conta-ft.ct-desc-cartao. 
            
            RUN pi_busca_dados_cta_ctbl IN h_api_cta (INPUT        param-global.empresa-prin, /* EMPRESA EMS2 */
                                                      INPUT        "",                  /* PLANO DE CONTAS */
                                                      INPUT-OUTPUT v_cod_cta,           /* CONTA */
                                                      INPUT        TODAY,               /* DATA TRANSACAO */   
                                                      OUTPUT       v_des_cta,           /* DESCRICAO CONTA */
                                                      OUTPUT       v_num_tip_cta,       /* TIPO DA CONTA */
                                                      OUTPUT       v_num_sit_cta,       /* SITUA€ÇO DA CONTA */
                                                      OUTPUT       v_ind_finalid_cta,   /* FINALIDADES DA CONTA */
                                                      OUTPUT TABLE tt_log_erro).        /* ERROS */
    
    
         
                     
            IF NOT CAN-FIND(tt_log_erro) OR RETURN-VALUE = "OK" 
            THEN DO:
               CREATE tt-ped-curva.
               ASSIGN tt-ped-curva.codigo         = v_cod_cta
                      tt-ped-curva.desc-conta     = v_des_cta 
                      tt-ped-curva.it-codigo      = ""
                      tt-ped-curva.serie          = nota-fiscal.serie
                      tt-ped-curva.nr-nota-fis    = nota-fiscal.nr-nota-fis
                      tt-ped-curva.cont           = 0
                      tt-ped-curva.dec-1          = 0
                      tt-ped-curva.vl-credito     = 0
                      tt-ped-curva.vl-debito      = de-vl-desconto /* calcular o valor do desconto */
                      tt-ped-curva.cod-unid-negoc = "".  
            END.
    
        END.
    END.

END PROCEDURE.
*/
