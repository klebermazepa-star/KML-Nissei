/********************************************************************************
** Copyright DATASUL S.A. (1997)
** Todos os Direitos Reservados.
**
** Este fonte e de propriedade exclusiva da DATASUL, sua reproducao
** parcial ou total por qualquer meio, so podera ser feita mediante
** autorizacao expressa.
*******************************************************************************/

{include/i-prgvrs.i NI0304 2.00.00.000}  /*** 010010 ***/

define temp-table tt-param
    field destino     as integer
    field arquivo     as char
    field usuario     as char format "x(12)"
    field data-exec   as date
    field hora-exec   as integer
    field estab-ini   as CHAR
    field estab-fim   as CHAR
    field uf-ini      as CHAR
    field uf-fim      as CHAR
    field sistema     as INT
    field sit-estab   as INT.

def temp-table tt-raw-digita
    field raw-digita as raw.

def input param raw-param as raw no-undo.
def input param table for tt-raw-digita.

def var h-acomp AS handle  no-undo.
DEF VAR l-ativo AS LOGICAL NO-UNDO.
DEF VAR c-ativo AS CHAR NO-UNDO.
DEF VAR c-sis-filial AS CHAR NO-UNDO.

{include/i-rpvar.i}

run utp/ut-acomp.p persistent set h-acomp.
run pi-inicializar in h-acomp ("Estab. x Sistema").

create tt-param.
raw-transfer raw-param to tt-param.

{include/i-rpcab.i}

find first param-global no-lock no-error.
if avail param-global then
   assign c-empresa = param-global.grupo.

{include/i-rpout.i}

assign c-programa     = "NI0304"
       c-versao       = "2.00"
       c-revisao      = "000".
       c-sistema      = "Espec¡fico".
       c-titulo-relat = "Relat¢rio de Estabelecimento x Sistema".

view frame f-cabec.
view frame f-rodape.

FOR EACH estabelec WHERE
         estabelec.cod-estabel >= tt-param.estab-ini AND
         estabelec.cod-estabel <= tt-param.estab-fim AND
         estabelec.estado      >= tt-param.uf-ini    AND
         estabelec.estado      <= tt-param.uf-fim NO-LOCK:
    
    RUN pi-acompanhar IN h-acomp (INPUT "Estabelecimento: " + estabelec.cod-estabel).

    FOR FIRST cst_estabelec WHERE
              cst_estabelec.cod_estabel = estabelec.cod-estabel NO-LOCK:
    END.
    IF NOT AVAIL cst_estabelec THEN
       NEXT.

    IF tt-param.sistema <> 3 THEN DO:
       IF  tt-param.sistema = 1
       AND cst_estabelec.sistema = NO THEN
           NEXT.

       IF  tt-param.sistema = 2
       AND cst_estabelec.sistema = YES THEN
           NEXT.
    END.

    ASSIGN l-ativo = YES.

    IF cst_estabelec.dt_fim_operacao < TODAY THEN
       ASSIGN l-ativo = NO.
    
    IF tt-param.sit-estab <> 3 THEN DO:
       IF  tt-param.sit-estab = 1
       AND l-ativo            = NO THEN
           NEXT.

       IF  tt-param.sit-estab = 2
       AND l-ativo            = YES THEN
           NEXT.
    END.

    IF l-ativo = YES THEN
       ASSIGN c-ativo = "Sim".
    ELSE
       ASSIGN c-ativo = "NÆo".

    IF cst_estabelec.sistema = YES THEN
       ASSIGN c-sis-filial = "Oblak".
    ELSE
       ASSIGN c-sis-filial = "Procfit".

    DISP estabelec.cod-estabel         COLUMN-LABEL "Estab"
         estabelec.cgc                 COLUMN-LABEL "CNPJ"
         estabelec.ins-estadual        COLUMN-LABEL "Inscri‡Æo Estadual"
         estabelec.estado
         estabelec.cidade
         c-ativo                       COLUMN-LABEL "Ativo"
         cst_estabelec.dt_fim_operacao COLUMN-LABEL "Dt Fim Oper"
         c-sis-filial                  COLUMN-LABEL "Sistema"
         cst_estabelec.dt_inicio_oper  COLUMN-LABEL "Dt Ini Procfit"
         cst_estabelec.dt_alter        COLUMN-LABEL "Dt Altera‡Æo"
         cst_estabelec.cod_usuario     WHEN cst_estabelec.cod_usuario <> ? AND cst_estabelec.cod_usuario <> "" COLUMN-LABEL "Usu rio Alter."
         WITH STREAM-IO NO-BOX DOWN WIDTH 300 FRAME f-estab.
END.


run pi-finalizar in h-acomp.

{include/i-rpclo.i}
