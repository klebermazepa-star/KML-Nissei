/********************************************************************************
** Copyright DATASUL S.A. (1997)
** Todos os Direitos Reservados.
**
** Este fonte e de propriedade exclusiva da DATASUL, sua reproducao
** parcial ou total por qualquer meio, so podera ser feita mediante
** autorizacao expressa.
*******************************************************************************/
{include/i-prgvrs.i ESP004RP 2.00.00.000}  /*** 010000 ***/

/*DEF TEMP-TABLE cst_cest_itens NO-UNDO
    FIELD pro_codigo_n     AS INT  FORMAT ">>>>>>>>9"
    FIELD pro_ncm_s        AS CHAR FORMAT "X(8)"
    FIELD pro_cest_entr_s  AS CHAR FORMAT "X(8)"
    FIELD pro_cest_saida_s AS CHAR FORMAT "X(8)".
    */

{cdp/cdcfgdis.i}
  
define temp-table tt-param no-undo
    field destino          as integer
    field arquivo          as char format "x(35)":U
    field usuario          as char format "x(12)":U
    field data-exec        as date
    field hora-exec        as integer
    field classifica       as integer
    field desc-classifica  as char format "x(40)":U
    field modelo           AS char format "x(35)":U
    /*Alterado 15/02/2005 - tech1007 - Criado campo l¢gico para verificar se o RTF foi habilitado*/
    field l-habilitaRtf    as LOG
    /*Fim alteracao 15/02/2005*/
    FIELD item-ini AS CHAR
    FIELD item-fim AS CHAR
    FIELD ncm-ini  AS CHAR
    FIELD ncm-fim  AS CHAR.

def temp-table tt-raw-digita
    field raw-digita as raw.

def input parameter raw-param as raw no-undo.
def input parameter table for tt-raw-digita.

def var h-acomp         as handle       no-undo.

run utp/ut-acomp.p persistent set h-acomp.
run pi-inicializar in h-acomp (input "Aguarde !").

{include/i-rpvar.i}

create tt-param.
raw-transfer raw-param to tt-param.                    
find first param-global no-lock no-error.

assign c-empresa  = param-global.grupo
       c-programa = "ESP004"
       c-versao   = "2.00"
       c-revisao  = "000".

form
    cst_cest_itens.pro_codigo_n      COLUMN-LABEL "Item"          AT 2
    cst_cest_itens.pro_ncm_s         COLUMN-LABEL "NCM"           AT 13
    cst_cest_itens.pro_cest_entr_s   COLUMN-LABEL "CEST Entrada"  AT 24 
    cst_cest_itens.pro_cest_saida_s  COLUMN-LABEL "CEST Sa¡da"    AT 38 
    WITH STREAM-IO WIDTH 200 DOWN NO-BOX FRAME f-ncm.

assign c-titulo-relat = "EXPORTA€ÇO CEST ITENS".
assign c-sistema      = "CADASTROS".

{utp/ut-glob.i}

{include/i-rpcab.i}
{include/i-rpout.i}

view frame f-rodape.
view frame f-cabec.

{cdp/cdapi1001.i}
DEF VAR h-cdapi1001             AS WIDGET-HANDLE NO-UNDO.

IF NOT VALID-HANDLE(h-cdapi1001) THEN
    RUN cdp/cdapi1001.p     PERSISTENT SET h-cdapi1001.

FOR EACH ITEM NO-LOCK
    WHERE ITEM.it-codigo    >= tt-param.item-ini
    AND   ITEM.it-codigo    <= tt-param.item-fim
    AND   ITEM.class-fiscal >= tt-param.ncm-ini 
    AND   ITEM.class-fiscal <= tt-param.ncm-fim:
    run pi-acompanhar in h-acomp (input "Item : " + ITEM.it-codigo).

    EMPTY TEMP-TABLE tt-sit-tribut.
    RUN pi-seta-tributos IN h-cdapi1001 (input "11").
    RUN pi-retorna-sit-tribut IN h-cdapi1001 (INPUT  1,
                                              INPUT  "*",
                                              INPUT  "*",
                                              INPUT  ITEM.class-fiscal,
                                              INPUT  ITEM.it-codigo,
                                              INPUT  "*",
                                              INPUT  0,
                                              INPUT  TODAY,
                                              OUTPUT TABLE tt-sit-tribut).

    FOR FIRST cst_cest_itens EXCLUSIVE-LOCK
        WHERE cst_cest_itens.pro_codigo_n = INT(ITEM.it-codigo)
        AND   cst_cest_itens.pro_ncm_s    = ITEM.class-fiscal: END.

    IF NOT AVAIL cst_cest_itens THEN DO:
        CREATE cst_cest_itens.
        ASSIGN cst_cest_itens.pro_codigo_n     = INT(ITEM.it-codigo)
               cst_cest_itens.pro_ncm_s        = ITEM.class-fiscal.
    END.

    FOR FIRST tt-sit-tribut:
        IF string(tt-sit-tribut.cdn-sit-tribut) <> "0" THEN DO:
             ASSIGN cst_cest_itens.pro_cest_entr_s = string(tt-sit-tribut.cdn-sit-tribut).
        END.
        ELSE DO:
            FOR FIRST sit-tribut-relacto NO-LOCK
                WHERE sit-tribut-relacto.cod-item = ITEM.it-codigo
                  AND sit-tribut-relacto.idi-tip-docto = 1:
                ASSIGN cst_cest_itens.pro_cest_entr_s = string(sit-tribut-relacto.cdn-sit-tribut).
           END.
        END.
    END.

    EMPTY TEMP-TABLE tt-sit-tribut.
    RUN pi-seta-tributos IN h-cdapi1001 (input "11").
    RUN pi-retorna-sit-tribut IN h-cdapi1001 (INPUT  2,
                                              INPUT  "*",
                                              INPUT  "*",
                                              INPUT  ITEM.class-fiscal,
                                              INPUT  ITEM.it-codigo,
                                              INPUT  "*",
                                              INPUT  0,
                                              INPUT  TODAY,
                                              OUTPUT TABLE tt-sit-tribut).

    FOR FIRST tt-sit-tribut:
        IF string(tt-sit-tribut.cdn-sit-tribut) <> "0" THEN DO:
            ASSIGN cst_cest_itens.pro_cest_saida_s = string(tt-sit-tribut.cdn-sit-tribut).
        END.
        ELSE DO:
            FOR FIRST sit-tribut-relacto NO-LOCK
                WHERE sit-tribut-relacto.cod-item = ITEM.it-codigo
                  AND sit-tribut-relacto.idi-tip-docto = 2:
                ASSIGN cst_cest_itens.pro_cest_saida_s = string(sit-tribut-relacto.cdn-sit-tribut).
           END.
        END.
    END.

    DISP cst_cest_itens.pro_codigo_n    
         cst_cest_itens.pro_ncm_s       
         cst_cest_itens.pro_cest_entr_s 
         cst_cest_itens.pro_cest_saida_s
        WITH FRAME f-ncm. 
    DOWN WITH FRAME f-ncm.
END.

IF VALID-HANDLE(h-cdapi1001) THEN
    DELETE PROCEDURE h-cdapi1001.

run pi-finalizar in h-acomp.

{include/i-rpclo.i}

return "OK":U.

