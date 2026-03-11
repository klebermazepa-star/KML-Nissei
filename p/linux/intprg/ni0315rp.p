/********************************************************************************
** Copyright DATASUL S.A. (1997)
** Todos os Direitos Reservados.
**
** Este fonte e de propriedade exclusiva da DATASUL, sua reproducao
** parcial ou total por qualquer meio, so podera ser feita mediante
** autorizacao expressa.
*******************************************************************************/

{include/i-prgvrs.i NI0315RP 2.00.00.000}  /*** 010000 ***/

{utp/ut-glob.i}

/***Defini‡äes***/
def var h-acomp  as handle no-undo.

define temp-table tt-param no-undo
    field destino          as integer
    field arquivo          as char format "x(35)"
    field usuario          as char format "x(12)"
    field data-exec        as date
    field hora-exec        as integer
    field estab-ini        as char 
    field estab-fim        as char 
    field uf-ini           as CHAR 
    field uf-fim           as CHAR
    FIELD dt-congela       AS DATE FORMAT "99/99/9999".

def temp-table tt-digita
    field ordem            as integer   format ">>>>9"
    field exemplo          as character format "x(30)"
    index id is primary unique
        ordem. 

def temp-table tt-raw-digita                   
    field raw-digita as raw.

def input parameter raw-param as raw no-undo.
def input parameter table for tt-raw-digita.

create tt-param.
raw-transfer raw-param to tt-param.

find first param-global no-lock no-error.

find first tt-param NO-LOCK NO-ERROR.

{include/i-rpvar.i}

assign c-titulo-relat = "Congelamento de Per¡odos Fiscais por Estab/UF"
       c-sistema      = "Espec¡fico"
       c-empresa      = param-global.grupo.

run utp/ut-acomp.p persistent set h-acomp.

run pi-inicializar in h-acomp (input "Processando").
                        
{include/i-rpcab.i}
{include/i-rpout.i}

view frame f-cabec.
view frame f-rodape.
   
FOR EACH estabelec WHERE
         estabelec.cod-estabel >= tt-param.estab-ini AND
         estabelec.cod-estabel <= tt-param.estab-fim AND
         estabelec.estado      >= tt-param.uf-ini    AND
         estabelec.estado      <= tt-param.uf-fim NO-LOCK:
       
    RUN pi-acompanhar IN h-acomp (INPUT "Estabelecimento: " + estabelec.cod-estabel). 

    FOR FIRST param-of WHERE  
              param-of.cod-estabel = estabelec.cod-estabel EXCLUSIVE-LOCK:
    END.
    IF AVAIL param-of THEN
       ASSIGN param-of.dt-congela = tt-param.dt-congela.

    RELEASE param-of.

    DISP estabelec.cod-estabel COLUMN-LABEL "Estab."
         estabelec.nome
         estabelec.estado
         tt-param.dt-congela COLUMN-LABEL "Data Congelamento"
         WITH STREAM-IO NO-BOX DOWN FRAME f-estab.
END.

{include/i-rpclo.i}

run pi-finalizar in h-acomp.

return 'OK'.

