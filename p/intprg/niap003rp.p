/* include de controle de versao */
{include/i-prgvrs.i NIAP003RP.P 1.00.00.001KML}

define temp-table tt-param no-undo
    field destino                as integer
    field arquivo                as char format "x(35)"
    field usuario                as char format "x(12)"
    field data-exec              as date
    field hora-exec              as integer
    field classifica             as integer
    field desc-classifica        as char format "x(40)"
    field modelo                 AS char format "x(35)"
    field l-habilitaRtf          as log
    FIELD FornecedorInicial   as char format "x(25)":U 
    field FornecedorFinal     as char format "x(25)":U 
    field EstabInicial        as char format "x(25)":U
    field EstabFinal          as char format "x(25)":U 
    field DtEmisIncial        as char format "x(25)":U 
    field DtEmisFinal        as char format "x(25)":U
    field EspecieInicial      as char format "x(25)":U 
    field EspecieFinal        as char format "x(25)":U
    .
    
DEFINE TEMP-TABLE tt-result NO-UNDO
    FIELD dat_vencto_tit_ap AS DATE
    FIELD cdn_fornecedor    AS INTEGER
    FIELD nome_emit         AS CHARACTER
    FIELD cod_tit_ap        AS CHARACTER
    FIELD val_origin_tit_ap AS DECIMAL
    FIELD val_pagto_tit_ap  AS DECIMAL
    FIELD val_liq_tit_acr   AS DECIMAL
    FIELD val_sdo_tit_ap    AS DECIMAL
    FIELD data_baixa        AS DATE
    FIELD cod_forn          AS INT
    FIELD especie           AS CHARACTER
    FIELD serie             AS CHARACTER
    FIELD titulo            AS CHARACTER
    FIELD parcela           AS CHARACTER
    FIELD valor             AS DECIMAL
   . /* garante 1 linha por t¡tulo/parcela */    
    
    
define temp-table tt-digita no-undo
    field ordem            as integer   format ">>>>9"
    field exemplo          as character format "x(30)"
    index id ordem.
    

DEFINE VARIABLE v-data_baixa AS CHARACTER     NO-UNDO.
DEFINE VARIABLE v-cod_forn   AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-especie    AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-serie      AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-titulo     AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-parcela    AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-valor      AS CHARACTER   NO-UNDO.    
    

/* Transfer Definitions */
def temp-table tt-raw-digita
   field raw-digita      as raw.
   

/* Recebimentro de Parametros */   
def input parameter raw-param as raw no-undo.
def input parameter table for tt-raw-digita.

create tt-param.
raw-transfer raw-param to tt-param.

{include/i-rpvar.i}

def var h-acomp          as handle    no-undo.
def var i-aux            as int       no-undo.
def var c-linha          as char      no-undo.
def var c-fator          as char      no-undo.



find first param-global no-lock no-error.
assign c-programa 	  = 'NIAP003RP'
       c-versao	      = '1.00'
       c-revisao      = '.00.001KML'
       c-sistema      = 'Relatorio'
       c-titulo-relat = 'Relatorio de antecipacoes e encontro de contas'. 

  
       
{include/i-rpout.i}

/* include padrao TOTVS-11 */
/*{include/comp.i}*/

/* include com a definicao da frame de cabecalho e rodape */
//{include/i-rpcab.i}

run utp/ut-acomp.p PERSISTENT set h-acomp.
{utp/ut-liter.i Atualizando *}

run pi-inicializar in h-acomp (input return-value).



OUTPUT TO VALUE ("U:\NIAP003.csv") NO-ECHO.


EXPORT DELIMITER ";"
    "VENCIMENTO" "COD FORNECEDOR" "NOME FORNECEDOR" "TITULO NF" 
    "VALOR ORIGINAL" "VALOR ENCONTRO DE CONTAS (ACR)" "VALOR VINCULA€ÇO (APB)" "VALOR SALDO" 
    "DATA BAIXA" "COD FORN" "ESPECIE" "SERIE" "TITULO" "PARCELA" "VALOR".

    
FOR EACH tit_ap NO-LOCK
    WHERE tit_ap.cod_estab      >=   tt-param.EstabInicial
    AND   tit_ap.cod_estab      <=   tt-param.EstabInicial
    AND   tit_ap.cdn_fornecedor >= int(tt-param.FornecedorInicial)
    AND   tit_ap.cdn_fornecedor <= int(tt-param.FornecedorFinal)
    AND   tit_ap.dat_emis_docto >= date(tt-param.DtEmisIncial)
    AND   tit_ap.dat_emis_docto <= date(tt-param.DtEmisFinal)
    AND   tit_ap.cod_espec_docto >= tt-param.EspecieInicial
    AND   tit_ap.cod_espec_docto <= tt-param.EspecieFinal
    :

    FIND FIRST ext_tit_acr_totalfor EXCLUSIVE-LOCK
        WHERE ext_tit_acr_totalfor.cod_estab       = tit_ap.cod_estab
          AND ext_tit_acr_totalfor.num_id_tit_ap  = tit_ap.num_id_tit_ap NO-ERROR.
                                                                           
    FIND FIRST ems2mult.emitente NO-LOCK
        WHERE emitente.cod-emitente = tit_ap.cdn_fornecedor NO-ERROR.

    FIND FIRST tit_acr NO-LOCK
        WHERE tit_acr.cod_tit_acr   = tit_ap.cod_tit_ap
        AND tit_acr.cod_ser_docto = tit_ap.cod_ser_docto
        AND tit_acr.cod_estab     = tit_ap.cod_estab NO-ERROR.

    FIND FIRST movto_tit_ap NO-LOCK
        WHERE movto_tit_ap.cod_estab = tit_ap.cod_estab
        AND movto_tit_ap.num_id_tit_ap = tit_ap.num_id_tit_ap NO-ERROR.

    FIND FIRST movto_tit_acr NO-LOCK
        WHERE AVAILABLE tit_acr
        AND movto_tit_acr.cod_estab     = tit_acr.cod_estab
        AND movto_tit_acr.num_id_tit_acr = tit_acr.num_id_tit_acr NO-ERROR.

    IF AVAIL ext_tit_acr_totalfor THEN
    DO:
        run pi-acompanhar in h-acomp (INPUT tit_ap.cod_tit_ap).              
                  
        CREATE tt-result.
        ASSIGN
            tt-result.dat_vencto_tit_ap = tit_ap.dat_vencto_tit_ap
            tt-result.cdn_fornecedor    = tit_ap.cdn_fornecedor
            tt-result.nome_emit         = IF AVAIL emitente THEN emitente.nome-emit ELSE ""
            tt-result.cod_tit_ap        = tit_ap.cod_tit_ap
            tt-result.val_origin_tit_ap = tit_ap.val_origin_tit_ap
            tt-result.val_pagto_tit_ap  = tit_ap.val_pagto_tit_ap
            tt-result.val_liq_tit_acr   = IF AVAIL tit_acr THEN tit_acr.val_liq_tit_acr ELSE 0
            tt-result.val_sdo_tit_ap    = tit_ap.val_sdo_tit_ap.
            
        IF tit_ap.cod_espec_docto = "AE" THEN DO:
            ASSIGN  tt-result.data_baixa = IF AVAIL movto_tit_acr THEN movto_tit_ap.dat_gerac_movto ELSE ?
                    tt-result.cod_forn   = tit_ap.cdn_fornecedor
                    tt-result.especie    = tit_ap.cod_espec_docto
                    tt-result.serie      = tit_ap.cod_ser_docto
                    tt-result.titulo     = tit_ap.cod_tit_ap
                    tt-result.parcela    = tit_ap.cod_parcela
                    tt-result.valor      = tit_ap.val_sdo_tit_ap.
        END.

        IF AVAILABLE tit_acr
           AND tit_acr.cod_espec_docto = "AV"
           THEN DO:
            ASSIGN  tt-result.data_baixa = IF AVAIL movto_tit_acr THEN movto_tit_acr.dat_gerac_movto ELSE ?
                    tt-result.cod_forn   = tit_ap.cdn_fornecedor
                    tt-result.especie    = tit_acr.cod_espec_docto
                    tt-result.serie      = tit_acr.cod_ser_docto
                    tt-result.titulo     = tit_acr.cod_tit_acr
                    tt-result.parcela    = tit_acr.cod_parcela
                    tt-result.valor      = tit_acr.val_sdo_tit_acr.
        END.
        
    END.
        
        
        
END.
  
    

/* FOR EACH ext_tit_acr_totalfor NO-LOCK                                                                           */
/*     WHERE ext_tit_acr_totalfor.cod_estab  >=   tt-param.EstabInicial                                            */
/*     AND   ext_tit_acr_totalfor.cod_estab  <=   tt-param.EstabInicial:                                           */
/*                                                                                                                 */
/*                                                                                                                 */
/*     FOR EACH tit_ap NO-LOCK                                                                                     */
/*         WHERE tit_ap.cod_estab      =  ext_tit_acr_totalfor.cod_estab                                           */
/*         AND   tit_ap.cdn_fornecedor >= int(tt-param.FornecedorInicial)                                          */
/*         AND   tit_ap.cdn_fornecedor <= int(tt-param.FornecedorFinal)                                            */
/*         AND   tit_ap.dat_emis_docto >= date(tt-param.DtEmisIncial)                                              */
/*         AND   tit_ap.dat_emis_docto <= date(tt-param.DtEmisFinal)                                               */
/*         AND   tit_ap.cod_espec_docto >= tt-param.EspecieInicial                                                 */
/*         AND   tit_ap.cod_espec_docto <= tt-param.EspecieFinal                                                   */
/*         :                                                                                                       */
/*                                                                                                                 */
/*         FIND FIRST ems2mult.emitente NO-LOCK                                                                    */
/*             WHERE emitente.cod-emitente = tit_ap.cdn_fornecedor NO-ERROR.                                       */
/*                                                                                                                 */
/*         FIND FIRST tit_acr NO-LOCK                                                                              */
/*             WHERE tit_acr.cod_tit_acr   = tit_ap.cod_tit_ap                                                     */
/*             AND tit_acr.cod_ser_docto = tit_ap.cod_ser_docto                                                    */
/*             AND tit_acr.cod_estab     = tit_ap.cod_estab NO-ERROR.                                              */
/*                                                                                                                 */
/*         FIND FIRST movto_tit_ap NO-LOCK                                                                         */
/*             WHERE movto_tit_ap.cod_estab = tit_ap.cod_estab                                                     */
/*             AND movto_tit_ap.num_id_tit_ap = tit_ap.num_id_tit_ap NO-ERROR.                                     */
/*                                                                                                                 */
/*         FIND FIRST movto_tit_acr NO-LOCK                                                                        */
/*             WHERE AVAILABLE tit_acr                                                                             */
/*             AND movto_tit_acr.cod_estab     = tit_acr.cod_estab                                                 */
/*             AND movto_tit_acr.num_id_tit_acr = tit_acr.num_id_tit_acr NO-ERROR.                                 */
/*                                                                                                                 */
/*         IF FIRST-OF(ext_tit_acr_totalfor.num_id_tit_acr) THEN DO:                                               */
/*                                                                                                                 */
/*             run pi-acompanhar in h-acomp (INPUT tit_ap.cod_tit_ap).                                             */
/*                                                                                                                 */
/*             CREATE tt-result.                                                                                   */
/*             ASSIGN                                                                                              */
/*                 tt-result.dat_vencto_tit_ap = tit_ap.dat_vencto_tit_ap                                          */
/*                 tt-result.cdn_fornecedor    = tit_ap.cdn_fornecedor                                             */
/*                 tt-result.nome_emit         = IF AVAIL emitente THEN emitente.nome-emit ELSE ""                 */
/*                 tt-result.cod_tit_ap        = tit_ap.cod_tit_ap                                                 */
/*                 tt-result.val_origin_tit_ap = tit_ap.val_origin_tit_ap                                          */
/*                 tt-result.val_pagto_tit_ap  = tit_ap.val_pagto_tit_ap                                           */
/*                 tt-result.val_liq_tit_acr   = IF AVAIL tit_acr THEN tit_acr.val_liq_tit_acr ELSE 0              */
/*                 tt-result.val_sdo_tit_ap    = tit_ap.val_sdo_tit_ap.                                            */
/*                                                                                                                 */
/*             IF tit_ap.cod_espec_docto = "AV" THEN DO:                                                           */
/*                 ASSIGN  tt-result.data_baixa = IF AVAIL movto_tit_acr THEN movto_tit_ap.dat_gerac_movto ELSE ?  */
/*                         tt-result.cod_forn   = tit_ap.cdn_fornecedor                                            */
/*                         tt-result.especie    = tit_ap.cod_espec_docto                                           */
/*                         tt-result.serie      = tit_ap.cod_ser_docto                                             */
/*                         tt-result.titulo     = tit_ap.cod_tit_ap                                                */
/*                         tt-result.parcela    = tit_ap.cod_parcela                                               */
/*                         tt-result.valor      = tit_ap.val_sdo_tit_ap.                                           */
/*             END.                                                                                                */
/*                                                                                                                 */
/*             IF AVAILABLE tit_acr                                                                                */
/*                AND tit_acr.cod_espec_docto = "AE"                                                               */
/*                THEN DO:                                                                                         */
/*                 ASSIGN  tt-result.data_baixa = IF AVAIL movto_tit_acr THEN movto_tit_acr.dat_gerac_movto ELSE ? */
/*                         tt-result.cod_forn   = tit_ap.cdn_fornecedor                                            */
/*                         tt-result.especie    = tit_acr.cod_espec_docto                                          */
/*                         tt-result.serie      = tit_acr.cod_ser_docto                                            */
/*                         tt-result.titulo     = tit_acr.cod_tit_acr                                              */
/*                         tt-result.parcela    = tit_acr.cod_parcela                                              */
/*                         tt-result.valor      = tit_acr.val_sdo_tit_acr.                                         */
/*             END.                                                                                                */
/*                                                                                                                 */
/*         END.                                                                                                    */
/*                                                                                                                 */
/* /*         EXPORT DELIMITER ";"                                           */                                    */
/* /*             tit_ap.dat_vencto_tit_ap                                   */                                    */
/* /*             tit_ap.cdn_fornecedor                                      */                                    */
/* /*             emitente.nome-emit                                         */                                    */
/* /*             tit_ap.cod_tit_ap                                          */                                    */
/* /*             tit_ap.val_origin_tit_ap                                   */                                    */
/* /*             tit_ap.val_pagto_tit_ap                                    */                                    */
/* /*             (IF AVAILABLE tit_acr THEN tit_acr.val_liq_tit_acr ELSE 0) */                                    */
/* /*             tit_ap.val_sdo_tit_ap                                      */                                    */
/* /*             IF v-data_baixa <> ? THEN v-data_baixa ELSE ?              */                                    */
/* /*             IF v-cod_forn  <> ? THEN v-cod_forn ELSE ?                 */                                    */
/* /*             IF v-especie   <> ? THEN v-especie ELSE ""                 */                                    */
/* /*             IF v-serie <> ? THEN v-serie ELSE ""                       */                                    */
/* /*             IF v-titulo <> ? THEN v-titulo ELSE ""                     */                                    */
/* /*             IF v-parcela <> ? THEN v-parcela ELSE ""                   */                                    */
/* /*             IF v-valor <> ? THEN v-valor ELSE ?.                       */                                    */
/*                                                                                                                 */
/*     END.                                                                                                        */
/* END.                                                                                                            */

FOR EACH tt-result:

    run pi-acompanhar in h-acomp (INPUT "Criando Excel..." + tt-result.cod_tit_ap).
    
    EXPORT DELIMITER ";"
        tt-result.dat_vencto_tit_ap
        tt-result.cdn_fornecedor
        tt-result.nome_emit
        tt-result.cod_tit_ap
        tt-result.val_origin_tit_ap
        tt-result.val_pagto_tit_ap
        tt-result.val_liq_tit_acr
        tt-result.val_sdo_tit_ap
        tt-result.data_baixa
        tt-result.cod_forn
        tt-result.especie
        tt-result.serie
        tt-result.titulo
        tt-result.parcela
        tt-result.valor.
END.

/* /* fechamento do output do relatorio */ */
/* {include/i-rpclo.i}                     */
run pi-finalizar in h-acomp.


OS-COMMAND NO-WAIT VALUE("U:\NIAP003.csv").
 
return "OK":U.

