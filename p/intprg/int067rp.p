
/* include de controle de versao */
{include/i-prgvrs.i INT067RP.P 1.00.00.001KML}

define temp-table tt-param no-undo
    field destino               as integer
    field arquivo               as char format "x(35)"
    field usuario               as char format "x(12)"
    field data-exec             as date
    field hora-exec             as integer
    field classifica            as integer
    field desc-classifica       as char format "x(40)"
    field modelo                as char format "x(35)"
    FIELD cod-estabel           AS CHAR
    FIELD serie                 AS CHAR 
    FIELD nr-nota-fis           AS CHAR
    .

define temp-table tt-digita no-undo
    field ordem            as integer   format ">>>>9"
    field exemplo          as character format "x(30)"
    index id ordem.
                                     
/* Transfer Definitions */
def temp-table tt-raw-digita
   field raw-digita      as raw.

DEFINE VARIABLE l-encontrouItem AS LOGICAL     NO-UNDO.

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
assign c-programa 	  = 'INT067RP'
       c-versao	      = '1.00'
       c-revisao      = '.00.001KML'
       c-empresa      = param-global.grupo
       c-sistema      = 'notas'
       c-titulo-relat = 'Altera CST PIS COFINS'. 

{include/i-rpout.i}

/* include padrao TOTVS-11 */
/*{include/comp.i}*/

/* include com a definicao da frame de cabecalho e rodape */
{include/i-rpcab.i}

view frame f-cabec.
view frame f-rodape.

run utp/ut-acomp.p persistent set h-acomp.
{utp/ut-liter.i Atualizando *}
run pi-inicializar in h-acomp (input return-value).

ASSIGN l-encontrouItem = NO.

FOR EACH nota-fiscal NO-LOCK
    WHERE nota-fiscal.cod-estabel   = tt-param.cod-estabel
      AND nota-fiscal.serie         = tt-param.serie
      AND nota-fiscal.nr-nota-fis   = tt-param.nr-nota-fis
      AND nota-fiscal.dt-cancel     = ?:

    FOR EACH it-nota-fisc OF nota-fiscal EXCLUSIVE-LOCK:

        IF cod-sit-tributar-pis = "04" OR cod-sit-tributar-pis = "05" THEN DO:
                    
            ASSIGN cod-sit-tributar-pis = "70"
                   cod-sit-tributar-cofins = "70".
            ASSIGN l-encontrouItem = YES.

            DISP "CST da Nota fiscal alterada com sucesso".
        END.
    END.
    RELEASE it-nota-fisc.

END.

IF l-encontrouItem = NO THEN DO:
    DISP "Nota fiscal n∆o alterada" skip
         "Nota fiscal n∆o contem itens com CST 04 ou 05 ".
END.

/* fechamento do output do relatorio */
{include/i-rpclo.i}
run pi-finalizar in h-acomp.
 
return "OK":U.


