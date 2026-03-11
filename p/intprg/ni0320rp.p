/********************************************************************************
** Copyright DATASUL S.A. (1997)
** Todos os Direitos Reservados.
**
** Este fonte e de propriedade exclusiva da DATASUL, sua reproducao
** parcial ou total por qualquer meio, so podera ser feita mediante
** autorizacao expressa.
*******************************************************************************/

{include/i-prgvrs.i NI0320RP 2.00.00.000}  /*** 010000 ***/

{utp/ut-glob.i}

/***Defini‡äes***/
def var h-acomp      as handle no-undo.
DEF VAR i-tp-imposto AS INT NO-UNDO.

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
    FIELD dt-apur-ini      AS DATE
    FIELD dt-apur-fim      AS DATE
    FIELD tp-imposto       AS CHAR
    FIELD acao             AS INT.

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

assign c-titulo-relat = "Automatiza‡Æo de Per¡odos Fiscais"
       c-sistema      = "Espec¡fico"
       c-empresa      = param-global.grupo.

run utp/ut-acomp.p persistent set h-acomp.

run pi-inicializar in h-acomp (input "Processando").
                        
{include/i-rpcab.i}
{include/i-rpout.i}

view frame f-cabec.
view frame f-rodape.
   
IF tt-param.tp-imposto = "ICMS" THEN
   ASSIGN i-tp-imposto = 1.
IF tt-param.tp-imposto = "IPI" THEN
   ASSIGN i-tp-imposto = 2.
IF tt-param.tp-imposto = "ICMS Incentivado (PE)" THEN
   ASSIGN i-tp-imposto = 3.
IF tt-param.tp-imposto = "ICMS Substituto Interno" THEN
   ASSIGN i-tp-imposto = 4.

IF tt-param.acao = 1 THEN DO:  /* InclusÆo */
   FOR EACH estabelec WHERE
            estabelec.cod-estabel >= tt-param.estab-ini AND
            estabelec.cod-estabel <= tt-param.estab-fim AND
            estabelec.estado      >= tt-param.uf-ini    AND
            estabelec.estado      <= tt-param.uf-fim NO-LOCK:
       
      RUN pi-acompanhar IN h-acomp (INPUT "Estabelecimento: " + estabelec.cod-estabel). 

      FOR FIRST apur-imposto WHERE
                apur-imposto.cod-estabel = estabelec.cod-estabel AND
                apur-imposto.dt-apur-ini = tt-param.dt-apur-ini  AND
                apur-imposto.dt-apur-fim = tt-param.dt-apur-fim  AND
                apur-imposto.tp-imposto  = i-tp-imposto:
      END.
      IF NOT AVAIL apur-imposto THEN DO:
         CREATE apur-imposto.
         ASSIGN apur-imposto.cod-estabel = estabelec.cod-estabel
                apur-imposto.dt-apur-ini = tt-param.dt-apur-ini 
                apur-imposto.dt-apur-fim = tt-param.dt-apur-fim 
                apur-imposto.tp-imposto  = i-tp-imposto.        

         DISP estabelec.cod-estabel COLUMN-LABEL "Estab."
              estabelec.nome
              estabelec.estado
              tt-param.dt-apur-ini  COLUMN-LABEL "Dt. Apur. Ini."
              tt-param.dt-apur-fim  COLUMN-LABEL "Dt. Apur. Fim"
              tt-param.tp-imposto   COLUMN-LABEL "Tipo Imposto"
              WITH STREAM-IO NO-BOX DOWN WIDTH 120 FRAME f-per-inc.
      END.
   END.
END.

IF tt-param.acao = 2 THEN DO:  /* ExclusÆo */
   FOR EACH estabelec WHERE
            estabelec.cod-estabel >= tt-param.estab-ini AND
            estabelec.cod-estabel <= tt-param.estab-fim AND
            estabelec.estado      >= tt-param.uf-ini    AND
            estabelec.estado      <= tt-param.uf-fim NO-LOCK:
       
      RUN pi-acompanhar IN h-acomp (INPUT "Estabelecimento: " + estabelec.cod-estabel). 

      FOR FIRST apur-imposto WHERE
                apur-imposto.cod-estabel = estabelec.cod-estabel AND
                apur-imposto.dt-apur-ini = tt-param.dt-apur-ini  AND
                apur-imposto.dt-apur-fim = tt-param.dt-apur-fim  AND
                apur-imposto.tp-imposto  = i-tp-imposto:
      END.
      IF AVAIL apur-imposto THEN DO:
         FOR EACH dwf-apurac-impto-ajust WHERE
                  dwf-apurac-impto-ajust.cod-estab                 = apur-imposto.cod-estabel AND
                  dwf-apurac-impto-ajust.dat-apurac-inicial-impto >= apur-imposto.dt-apur-ini AND
                  dwf-apurac-impto-ajust.dat-apurac-final-impto   <= apur-imposto.dt-apur-fim AND
                  dwf-apurac-impto-ajust.cod-uf                    = "" EXCLUSIVE-LOCK:
             DELETE dwf-apurac-impto-ajust.
         END.

         FOR EACH dwf-apurac-impto-recolh WHERE 
                  dwf-apurac-impto-recolh.cod-estab                 = apur-imposto.cod-estabel AND
                  dwf-apurac-impto-recolh.dat-apurac-inicial-impto >= apur-imposto.dt-apur-ini AND
                  dwf-apurac-impto-recolh.dat-apurac-final-impto   <= apur-imposto.dt-apur-fim AND
                  dwf-apurac-impto-recolh.cod-uf                    = ""  EXCLUSIVE-LOCK:
             DELETE dwf-apurac-impto-recolh.
         END.

         for each imp-valor OF apur-imposto EXCLUSIVE-LOCK:
             delete imp-valor.
         end.

         for each imposto-guia OF apur-imposto EXCLUSIVE-LOCK:
             delete imposto-guia.
         end.  

         DELETE apur-imposto.

         DISP estabelec.cod-estabel COLUMN-LABEL "Estab."
              estabelec.nome
              estabelec.estado
              tt-param.dt-apur-ini  COLUMN-LABEL "Dt. Apur. Ini."
              tt-param.dt-apur-fim  COLUMN-LABEL "Dt. Apur. Fim"
              tt-param.tp-imposto   COLUMN-LABEL "Tipo Imposto"
              WITH STREAM-IO NO-BOX DOWN WIDTH 120 FRAME f-per-exc.
      END.
   END.
END.

{include/i-rpclo.i}

run pi-finalizar in h-acomp.

return 'OK'.

