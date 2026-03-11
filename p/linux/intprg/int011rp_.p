/********************************************************************************
** Programa: int011 - Exporta‡Æo de Notas de Sa¡da p/ Toturial/PRS
**
** Versao : 12 - 09/02/2016 - Alessandro V Baccin
**
********************************************************************************/
{utp/ut-glob.i}
/* include de controle de versÆo */
{include/i-prgvrs.i INT011RP 2.12.01.AVB}

/*** Defini‡äes atualiza documento no recebimento */
 define temp-table tt-digita-re
    field r-docum-est        as rowid.

def temp-table tt-raw-digita-re
   field raw-digita   as raw.

DEF TEMP-TABLE tt-arquivo-erro
    FIELD c-linha AS CHAR.

DEF TEMP-TABLE tt-erro-nota NO-UNDO
    FIELD serie        AS CHAR FORMAT "x(03)"
    FIELD nro-docto    AS CHAR FORMAT "9999999"
    FIELD cod-emitente AS INTEGER FORMAT ">>>>>>>>9"
    FIELD cod-erro     AS INTEGER FORMAT ">>>>>9"
    FIELD descricao    AS CHAR.

define temp-table tt-param-re
    field destino            as integer
    field arquivo            as char
    field usuario            as char
    field data-exec          as date
    field hora-exec          as integer
    field classifica         as integer
    field c-cod-estabel-ini  as char
    field c-cod-estabel-fim  as char
    field i-cod-emitente-ini as integer
    field i-cod-emitente-fim as integer
    field c-nro-docto-ini    as char
    field c-nro-docto-fim    as char
    field c-serie-docto-ini  as char
    field c-serie-docto-fim  as char
    field c-nat-operacao-ini as char
    field c-nat-operacao-fim as char
    field da-dt-trans-ini    as date
    field da-dt-trans-fim    as date.

DEF VAR i-pos-arq            AS INTEGER                   NO-UNDO.
DEF VAR c-nr-nota            AS CHAR FORMAT "x(10)"       NO-UNDO.
DEF VAR c-linha              AS CHAR.
DEF VAR i-cont               AS INTEGER.
DEF VAR i-erro               AS INTEGER.
def var c-informacao         as char format "X(100)" no-undo.
DEF VAR de-quantidade        LIKE int-ds-pedido-retorno.rpp-quantidade-n.

DEFINE BUFFER b-docum-est   FOR docum-est.
DEFINE BUFFER b-nota-fiscal FOR nota-fiscal.

/* defini‡Æo das temp-tables para recebimento de parƒmetros */
define temp-table tt-param no-undo
    field destino          as integer
    field arquivo          as char format "x(35)"
    field usuario          as char format "x(12)"
    field data-exec        as date
    field hora-exec        as integer
    field classifica       as integer
    field desc-classifica  as char format "x(40)"
    field cod-estabel-ini  as char format "x(5)"
    field cod-estabel-fim  as char format "x(5)"
    field dt-cancela-ini   as date format "99/99/9999"
    field dt-cancela-fim   as date format "99/99/9999"
    field dt-emis-nota-ini as date format "99/99/9999"
    field dt-emis-nota-fim as date format "99/99/9999".

def temp-table tt-raw-digita
    	field raw-digita	as raw.

/* recebimento de parƒmetros */
def input parameter raw-param as raw no-undo.
def input parameter table for tt-raw-digita.
create tt-param.
raw-transfer raw-param to tt-param NO-ERROR.

if tt-param.dt-emis-nota-ini = ? then
    assign tt-param.dt-emis-nota-ini = today - 7
           tt-param.dt-emis-nota-fim = today.

if tt-param.dt-cancela-ini   = ? then
    assign tt-param.dt-cancela-ini   = today - 7
           tt-param.dt-cancela-fim   = today.

if tt-param.cod-estabel-fim  = "" then
    assign tt-param.cod-estabel-ini  = ""
           tt-param.cod-estabel-fim  = "ZZZZZ".

/* include padrÆo para vari veis de relat¢rio  */
{include/i-rpvar.i}

/* defini‡Æo de vari veis  */
def var h-acomp as handle no-undo.
def var l-sub as logical no-undo.
DEF VAR i-nr-pedido AS INT NO-UNDO.
def var c-nat-operacao as char no-undo.
/* defini‡Æo de frames do relat¢rio */

form
    nota-fiscal.cod-estabel
    nota-fiscal.serie
    nota-fiscal.nr-nota-fis
    nota-fiscal.dt-emis-nota
    nota-fiscal.dt-cancela
  with frame f-rel down stream-io width 300.

IF tt-param.arquivo <> "" THEN DO:
    /* include padrÆo para output de relat¢rios */
    {include/i-rpout.i /*&STREAM="stream str-rp"*/}

    /* include com a defini‡Æo da frame de cabe‡alho e rodap‚ */
    {include/i-rpcab.i /*&STREAM="str-rp"*/}
END.


for first param-global fields (empresa-prin) no-lock: end.
for first mguni.empresa fields (razao-social) no-lock where
    empresa.ep-codigo = param-global.empresa-prin : end.

/* bloco principal do programa */
assign  c-programa 	    = "INT011RP"
	    c-versao	    = "2.12"
	    c-revisao	    = ".01.AVB"
        c-empresa       = mguni.empresa.razao-social
	    c-sistema	    = "Faturamento"
	    c-titulo-relat  = "Integra‡Æo Notas Fiscais Sa¡da - Tutorial/PRS".

IF tt-param.arquivo <> "" THEN DO:
    view /*stream str-rp*/ frame f-cabec.
    view /*stream str-rp*/ frame f-rodape.
END.
run utp/ut-acomp.p persistent set h-acomp.
run pi-inicializar in h-acomp (input "Imprimindo").

DEFINE TEMP-TABLE tt-nota LIKE nota-fiscal INDEX chave serie nr-nota-fis.
DEFINE BUFFER bestabelec FOR estabelec.
/*
INPUT FROM t:\docum-est-apagados-transferencia-IPI-05.txt.
REPEAT:
    CREATE tt-nota.
    IMPORT DELIMITER " "
        tt-nota.serie
        tt-nota.nr-nota-fis
        tt-nota.cod-emitente
        tt-nota.nat-operacao.

END.
INPUT CLOSE.

INPUT FROM t:\transf-reenviar-int011.txt.
REPEAT:
    CREATE tt-nota.
    IMPORT DELIMITER " "
        tt-nota.nome-ab-cli /* cgc origem */
        tt-nota.serie
        tt-nota.nr-nota-fis.
END.
INPUT CLOSE.

79430682025540/10/0536115/5409 - Documento nÆo possui Itens. Docto: 536115 S‚rie: 10 Estab.: 048
79430682025540/10/0539326/5409 - Documento nÆo possui Itens. Docto: 539326 S‚rie: 10 Estab.: 035

79430682025540/10/0536115/5409 - Documento nÆo possui Itens. Docto: 536115 S‚rie: 10 Estab.: 048
79430682025540/10/0539326/5409 - Documento nÆo possui Itens. Docto: 539326 S‚rie: 10 Estab.: 035
*/

CREATE tt-nota.
ASSIGN tt-nota.serie = "11"
       tt-nota.nr-nota-fis = "0026950".

FOR EACH tt-nota, 
    EACH bestabelec NO-LOCK WHERE 
    bestabelec.cgc = "79430682025540":
    for each nota-fiscal no-lock where 
        nota-fiscal.cod-estabel = bestabelec.cod-estabel AND
        nota-fiscal.serie       = tt-nota.serie AND
        nota-fiscal.nr-nota-fis = tt-nota.nr-nota-fis AND
        /*
        nota-fiscal.dt-emis-nota >= tt-param.dt-emis-nota-ini and
        nota-fiscal.dt-emis-nota <= tt-param.dt-emis-nota-fim and
        nota-fiscal.cod-estabel >= tt-param.cod-estabel-ini and
        nota-fiscal.cod-estabel <= tt-param.cod-estabel-fim AND
        */
        nota-fiscal.esp-docto = 23
        on stop undo, leave:
    
        ASSIGN i-nr-pedido = 0.
        if nota-fiscal.idi-sit-nf-eletro <> 3 and
           nota-fiscal.dt-cancel = ? then next.

        if nota-fiscal.dt-cancel <> ? then next.

        /* transferˆncia de impostos */
        if nota-fiscal.nat-operacao begins "5605" then next.
        /*if nota-fiscal.nat-operacao begins "5929" then next.*/
      
        for first ser-estab no-lock where 
            ser-estab.serie = nota-fiscal.serie and
            ser-estab.cod-estabel = nota-fiscal.cod-estabel and
            ser-estab.log-nf-eletro = yes: end.
        if not avail ser-estab then next.
        
        run pi-acompanhar in h-acomp (input nota-fiscal.cod-estabel + "/" +
                                            nota-fiscal.serie + "/" +
                                            nota-fiscal.nr-nota-fis).
        
       {intprg/int011rp_.i}  /* Notas de Sa¡da/entrada balan‡o lojas */
    
    end.
END.

IF tt-param.arquivo <> "" THEN DO:
    /* fechamento do output do relat¢rio  */
    {include/i-rpclo.i /*&STREAM="stream str-rp"*/}
END.
run pi-finalizar in h-acomp.
return "OK":U.


