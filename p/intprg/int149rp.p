/********************************************************************************
*******************************************************************************/
{include/i-prgvrs.i INT149RP 2.06.00.001}  
{include/i_fnctrad.i}
/******************************************************************************
**
**       PROGRAMA: INT149RP
**
**       DATA....: 12/2017
**
**       OBJETIVO: Realizar a altera‡Æo do N£mero de Serie da Contigˆncia
**
**       VERSAO..: 2.06.001
** 
******************************************************************************/

{include/i-rpvar.i}
{include/i-rpcab.i}
/* {utp/ut-glob.i} */ 
    
 def new Global shared var c-seg-usuario        as char format "x(12)" no-undo.

{method/dbotterr.i} 
/*{cdp/cd0666.i}       Definicao da temp-table de erros */

define temp-table tt-param no-undo
    field destino          as integer
    field arquivo          as char format "x(35)"
    field usuario          as char format "x(12)"
    field data-exec        as date
    field hora-exec        as integer
    field classifica       as integer
    field desc-classifica  as char format "x(40)"
    field modelo-rtf       as char format "x(35)"
    field l-habilitaRtf    as LOG
    FIELD c-estab-ini      LIKE nota-fiscal.cod-estabel
    FIELD c-estab-fim      LIKE nota-fiscal.cod-estabel
    FIELD c-data-ini       LIKE nota-fiscal.dt-emis
    FIELD c-data-fim       LIKE nota-fiscal.dt-emis
    .

def new global shared var v_cod_usuar_corren
    as character
    format "x(12)":U
    label "Usuÿrio Corrente"
    column-label "Usuÿrio Corrente"
    no-undo.

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


DEF VAR c-acompanha    as char    no-undo.
DEF VAR h-acomp        AS HANDLE  NO-UNDO.
DEFINE VARIABLE abortado AS LOGICAL  INITIAL NO   NO-UNDO.

DEFINE VARIABLE c-cnpj AS CHARACTER   NO-UNDO.

DEF STREAM stream-a.
DEF STREAM stream-b.
DEF STREAM stream-c.
DEF STREAM stream-d.
DEF STREAM stream-e.
DEF STREAM stream-f.
DEF STREAM stream-g.
DEF STREAM stream-h.
DEF STREAM stream-i.
DEF STREAM stream-j.

DEFINE VARIABLE diretorio AS CHARACTER  FORMAT "X(1000)" NO-UNDO.
   
find first param-estoq  no-lock no-error.
find first param-global no-lock no-error.
find first ems2mult.empresa where 
           empresa.ep-codigo = param-global.empresa-prin no-lock no-error.

assign c-programa = "INT149"
       c-versao   = "2.06"
       c-revisao  = "001"
       c-empresa  = empresa.razao-social.

find first tt-param no-lock no-error.
{include/i-rpout.i}
{utp/ut-liter.i Altera_Numero_Serie_Contigencia * L}
assign c-titulo-relat = trim(return-value).
{utp/ut-liter.i Faturamento * L}
assign c-sistema = trim(return-value).

VIEW frame f-cabec.
view frame f-rodape.

RUN utp/ut-acomp.p PERSISTENT SET h-acomp.
RUN pi-inicializar IN h-acomp (INPUT "Altera N£mero S‚rie Contigˆncia").

RUN criaDiretorioBackup.
IF abortado = NO THEN
    RUN processamentoInformacoes.

RUN pi-finalizar IN h-acomp.
{include/i-rpclo.i}   

    IF abortado = NO THEN
        MESSAGE "Arquivos de Backup Gerado no diret¢rio: " + diretorio
            VIEW-AS ALERT-BOX INFO BUTTONS OK.

RETURN "OK":U.

PROCEDURE processamentoInformacoes:

    OUTPUT STREAM stream-a TO VALUE(diretorio + "dwf-docto-homolog.d")                  CONVERT TARGET "iso8859-1".
    OUTPUT STREAM stream-b TO VALUE(diretorio + "dwf-docto-compl-homolog.d")            CONVERT TARGET "iso8859-1".
    OUTPUT STREAM stream-c TO VALUE(diretorio + "dwf-docto-cupom-referado-homolog.d")   CONVERT TARGET "iso8859-1".
    OUTPUT STREAM stream-d TO VALUE(diretorio + "dwf-docto-fatur-homolog.d")            CONVERT TARGET "iso8859-1".
    OUTPUT STREAM stream-e TO VALUE(diretorio + "dwf-docto-fatur-parc-homolog.d")       CONVERT TARGET "iso8859-1".
    OUTPUT STREAM stream-f TO VALUE(diretorio + "dwf-docto-fisc-refer-homolog.d")       CONVERT TARGET "iso8859-1".
    OUTPUT STREAM stream-g TO VALUE(diretorio + "dwf-docto-item-homolog.d")             CONVERT TARGET "iso8859-1".
    OUTPUT STREAM stream-h TO VALUE(diretorio + "dwf-docto-item-imp-analit-homolog.d")  CONVERT TARGET "iso8859-1".
    OUTPUT STREAM stream-i TO VALUE(diretorio + "dwf-docto-item-impto-homolog.d")       CONVERT TARGET "iso8859-1".
    OUTPUT STREAM stream-j TO VALUE(diretorio + "dwf-docto-transp-homolog.d")           CONVERT TARGET "iso8859-1".

    PAUSE 0 BEFORE-HIDE.

    FOR EACH  dwf-docto 
       WHERE dwf-docto.cod-estab      >= tt-param.c-estab-ini 
         AND dwf-docto.cod-estab      <= tt-param.c-estab-fim 
         AND dwf-docto.dat-entr-saida >= tt-param.c-data-ini  
         AND dwf-docto.dat-entr-saida <= tt-param.c-data-fim  
       /* AND dwf-docto.idi-tip-docto = 2*/
    /*       AND dwf-docto.cod-serie  = "2"       */  
         /*  AND dwf-docto.cod-docto  = "0186583" */
        query-tuning(no-lookahead) :

        RUN pi-acompanhar IN h-acomp (INPUT STRING(dwf-docto.cod-estab)    + " | " +
                                            STRING(dwf-docto.cod-serie)    + " | " +
                                            STRING(dwf-docto.cod-docto)    + " | " +
                                            STRING(dwf-docto.cod-emitente) + " | " + 
                                            STRING(dwf-docto.cod-natur-operac)).


        

        IF dwf-docto.idi-tip-docto <> 2 THEN
            NEXT.

        IF  SUBSTR(dwf-docto.cod-chave-aces-nf-eletro,23,03) BEGINS "8"
        THEN DO:
            IF  dwf-docto.cod-serie <> SUBSTR(dwf-docto.cod-chave-aces-nf-eletro,23,03) OR 
                dwf-docto.cod-docto <> SUBSTR(dwf-docto.cod-chave-aces-nf-eletro,28,07) 
            THEN DO:
                ASSIGN c-cnpj = SUBSTR(dwf-docto.cod-chave-aces-nf-eletro,7,14).

                FIND FIRST emitente NO-LOCK
                    WHERE  emitente.cgc = c-cnpj NO-ERROR.

                RUN pi-acompanhar IN h-acomp (INPUT STRING(dwf-docto.cod-estab)    + " | " +
                                                    STRING(dwf-docto.cod-serie)    + " | " +
                                                    STRING(dwf-docto.cod-docto)    + " | " +
                                                    STRING(dwf-docto.cod-emitente) + " | " + 
                                                    STRING(dwf-docto.cod-natur-operac)).

                DISP dwf-docto.cod-estab
                     dwf-docto.cod-serie
                     dwf-docto.cod-docto
                     dwf-docto.cod-emitente
                     dwf-docto.cod-natur-operac
    /*                  emitente.cod-emitente */
                     SUBSTR(dwf-docto.cod-chave-aces-nf-eletro,23,03) FORMAT "X(03)"
                     SUBSTR(dwf-docto.cod-chave-aces-nf-eletro,28,07) FORMAT "X(09)".

                FOR EACH  dwf-docto-compl
                    WHERE dwf-docto-compl.cod-estab        = dwf-docto.cod-estab       
                      AND dwf-docto-compl.cod-serie        = dwf-docto.cod-serie       
                      AND dwf-docto-compl.cod-docto        = dwf-docto.cod-docto       
                      AND dwf-docto-compl.cod-emitente     = dwf-docto.cod-emitente    
                      AND dwf-docto-compl.cod-natur-operac = dwf-docto.cod-natur-operac:

                    EXPORT STREAM stream-b dwf-docto-compl.

                    ASSIGN dwf-docto-compl.cod-serie = SUBSTR(dwf-docto.cod-chave-aces-nf-eletro,23,03) 
                           dwf-docto-compl.cod-docto = SUBSTR(dwf-docto.cod-chave-aces-nf-eletro,28,07).
                END.

                FOR EACH  dwf-docto-cupom-referado
                    WHERE dwf-docto-cupom-referado.cod-estab        = dwf-docto.cod-estab       
                      AND dwf-docto-cupom-referado.cod-serie        = dwf-docto.cod-serie       
                      AND dwf-docto-cupom-referado.cod-docto        = dwf-docto.cod-docto       
                      AND dwf-docto-cupom-referado.cod-emitente     = dwf-docto.cod-emitente    
                      AND dwf-docto-cupom-referado.cod-natur-operac = dwf-docto.cod-natur-operac:

                    EXPORT STREAM stream-c dwf-docto-cupom-referado.

                    ASSIGN dwf-docto-cupom-referado.cod-serie = SUBSTR(dwf-docto.cod-chave-aces-nf-eletro,23,03) 
                           dwf-docto-cupom-referado.cod-docto = SUBSTR(dwf-docto.cod-chave-aces-nf-eletro,28,07).
                END.

                FOR EACH  dwf-docto-fatur
                    WHERE dwf-docto-fatur.cod-estab        = dwf-docto.cod-estab       
                      AND dwf-docto-fatur.cod-serie        = dwf-docto.cod-serie       
                      AND dwf-docto-fatur.cod-docto        = dwf-docto.cod-docto       
                      AND dwf-docto-fatur.cod-emitente     = dwf-docto.cod-emitente    
                      AND dwf-docto-fatur.cod-natur-operac = dwf-docto.cod-natur-operac:

                    EXPORT STREAM stream-d dwf-docto-fatur.

                    ASSIGN dwf-docto-fatur.cod-serie = SUBSTR(dwf-docto.cod-chave-aces-nf-eletro,23,03) 
                           dwf-docto-fatur.cod-docto = SUBSTR(dwf-docto.cod-chave-aces-nf-eletro,28,07).
                END.

                FOR EACH  dwf-docto-fatur-parc
                    WHERE dwf-docto-fatur-parc.cod-estab        = dwf-docto.cod-estab       
                      AND dwf-docto-fatur-parc.cod-serie        = dwf-docto.cod-serie       
                      AND dwf-docto-fatur-parc.cod-docto        = dwf-docto.cod-docto       
                      AND dwf-docto-fatur-parc.cod-emitente     = dwf-docto.cod-emitente    
                      AND dwf-docto-fatur-parc.cod-natur-operac = dwf-docto.cod-natur-operac:

                    EXPORT STREAM stream-e dwf-docto-fatur-parc.

                    ASSIGN dwf-docto-fatur-parc.cod-serie = SUBSTR(dwf-docto.cod-chave-aces-nf-eletro,23,03) 
                           dwf-docto-fatur-parc.cod-docto = SUBSTR(dwf-docto.cod-chave-aces-nf-eletro,28,07).
                END.

                FOR EACH  dwf-docto-fisc-refer
                    WHERE dwf-docto-fisc-refer.cod-estab        = dwf-docto.cod-estab       
                      AND dwf-docto-fisc-refer.cod-serie        = dwf-docto.cod-serie       
                      AND dwf-docto-fisc-refer.cod-docto        = dwf-docto.cod-docto       
                      AND dwf-docto-fisc-refer.cod-emitente     = dwf-docto.cod-emitente    
                      AND dwf-docto-fisc-refer.cod-natur-operac = dwf-docto.cod-natur-operac:

                    EXPORT STREAM stream-f dwf-docto-fisc-refer.

                    ASSIGN dwf-docto-fisc-refer.cod-serie = SUBSTR(dwf-docto.cod-chave-aces-nf-eletro,23,03) 
                           dwf-docto-fisc-refer.cod-docto = SUBSTR(dwf-docto.cod-chave-aces-nf-eletro,28,07).
                END.

                FOR EACH  dwf-docto-item
                    WHERE dwf-docto-item.cod-estab        = dwf-docto.cod-estab       
                      AND dwf-docto-item.cod-serie        = dwf-docto.cod-serie       
                      AND dwf-docto-item.cod-docto        = dwf-docto.cod-docto       
                      AND dwf-docto-item.cod-emitente     = dwf-docto.cod-emitente    
                      AND dwf-docto-item.cod-natur-operac = dwf-docto.cod-natur-operac:

                    EXPORT STREAM stream-g dwf-docto-item.

                    ASSIGN dwf-docto-item.cod-serie = SUBSTR(dwf-docto.cod-chave-aces-nf-eletro,23,03) 
                           dwf-docto-item.cod-docto = SUBSTR(dwf-docto.cod-chave-aces-nf-eletro,28,07).
                END.

                FOR EACH  dwf-docto-item-imp-analit
                    WHERE dwf-docto-item-imp-analit.cod-estab        = dwf-docto.cod-estab       
                      AND dwf-docto-item-imp-analit.cod-serie        = dwf-docto.cod-serie       
                      AND dwf-docto-item-imp-analit.cod-docto        = dwf-docto.cod-docto       
                      AND dwf-docto-item-imp-analit.cdn-emitente     = INT(dwf-docto.cod-emitente)    
                      AND dwf-docto-item-imp-analit.cod-natur-operac = dwf-docto.cod-natur-operac:

                    EXPORT STREAM stream-h dwf-docto-item-imp-analit.

                    ASSIGN dwf-docto-item-imp-analit.cod-serie = SUBSTR(dwf-docto.cod-chave-aces-nf-eletro,23,03) 
                           dwf-docto-item-imp-analit.cod-docto = SUBSTR(dwf-docto.cod-chave-aces-nf-eletro,28,07).
                END.

                FOR EACH  dwf-docto-item-impto
                    WHERE dwf-docto-item-impto.cod-estab        = dwf-docto.cod-estab       
                      AND dwf-docto-item-impto.cod-serie        = dwf-docto.cod-serie       
                      AND dwf-docto-item-impto.cod-docto        = dwf-docto.cod-docto       
                      AND dwf-docto-item-impto.cod-emitente     = dwf-docto.cod-emitente    
                      AND dwf-docto-item-impto.cod-natur-operac = dwf-docto.cod-natur-operac:

                    EXPORT STREAM stream-i dwf-docto-item-impto.

                    ASSIGN dwf-docto-item-impto.cod-serie = SUBSTR(dwf-docto.cod-chave-aces-nf-eletro,23,03) 
                           dwf-docto-item-impto.cod-docto = SUBSTR(dwf-docto.cod-chave-aces-nf-eletro,28,07).
                END.

                FOR EACH  dwf-docto-transp
                    WHERE dwf-docto-transp.cod-estab        = dwf-docto.cod-estab       
                      AND dwf-docto-transp.cod-serie        = dwf-docto.cod-serie       
                      AND dwf-docto-transp.cod-docto        = dwf-docto.cod-docto       
                      AND dwf-docto-transp.cod-emitente     = dwf-docto.cod-emitente    
                      AND dwf-docto-transp.cod-natur-operac = dwf-docto.cod-natur-operac:

                    EXPORT STREAM stream-j dwf-docto-transp.

                    ASSIGN dwf-docto-transp.cod-serie = SUBSTR(dwf-docto.cod-chave-aces-nf-eletro,23,03) 
                           dwf-docto-transp.cod-docto = SUBSTR(dwf-docto.cod-chave-aces-nf-eletro,28,07).
                END.

                EXPORT STREAM stream-a dwf-docto.
                ASSIGN dwf-docto.cod-serie = SUBSTR(dwf-docto.cod-chave-aces-nf-eletro,23,03)
                       dwf-docto.cod-docto = SUBSTR(dwf-docto.cod-chave-aces-nf-eletro,28,07).
            END.
        END.
    END.

    OUTPUT STREAM stream-a close.
    OUTPUT STREAM stream-b close.
    OUTPUT STREAM stream-c close.
    OUTPUT STREAM stream-d close.
    OUTPUT STREAM stream-e close.
    OUTPUT STREAM stream-f close.
    OUTPUT STREAM stream-g close.
    OUTPUT STREAM stream-h close.
    OUTPUT STREAM stream-i close.
    OUTPUT STREAM stream-j close.
END PROCEDURE.

PROCEDURE criaDiretorioBackup:
    
    ASSIGN diretorio = SESSION:TEMP-DIRECTORY + "SPED-Contrib_BKP\"         .

    ASSIGN FILE-INFO:FILE-NAME = diretorio.
    IF FILE-INFO:FULL-PATHNAME = ? THEN DO:
        os-create-dir value(diretorio).
    END.

    ASSIGN diretorio = diretorio
                     + REPLACE(STRING(tt-param.c-data-ini,"99/99/9999"),"/","-")
                     + "-ate-" +  REPLACE(STRING(tt-param.c-data-fim,"99/99/9999"),"/","-") + "\".

    ASSIGN FILE-INFO:FILE-NAME = diretorio.
    IF FILE-INFO:FULL-PATHNAME = ? THEN DO:
        os-create-dir value(diretorio).
    END.

    RUN utp/ut-msgs.p (INPUT "show",
                       INPUT 27100,
                       INPUT "Sobrepor Arquivos de BACKUP?~~Caso j  exista os arquivos backup para essa faixa de data, os mesmo serÆo eliminados. Deseja Continuar?").
    IF  RETURN-VALUE = "NO" THEN DO:
        ASSIGN abortado = YES.
        RETURN "NOK".
    END.
    
END PROCEDURE.

/* PROCEDURE pi-mostra-cupom-cartao-manual:                                                      */
/*                                                                                               */
/*     FOR EACH cst-nota-fiscal NO-LOCK USE-INDEX cartao_manual                                  */
/*        WHERE cst-nota-fiscal.cartao-manual = TRUE                                             */
/*          AND cst-nota-fiscal.cod-estabel   >= tt-param.c-estab-ini                            */
/*          AND cst-nota-fiscal.cod-estabel   <= tt-param.c-estab-fim                            */
/*          AND cst-nota-fiscal.serie         >= tt-param.c-serie-ini                            */
/*          AND cst-nota-fiscal.serie         <= tt-param.c-serie-fim                            */
/*          AND cst-nota-fiscal.nr-nota-fis   >= tt-param.c-nota-ini                             */
/*          AND cst-nota-fiscal.nr-nota-fis   <= tt-param.c-nota-fim,                            */
/*        FIRST nota-fiscal  NO-LOCK                                                             */
/*            WHERE nota-fiscal.cod-estabel  = cst-nota-fiscal.cod-estabel                       */
/*              AND nota-fiscal.serie        = cst-nota-fiscal.serie                             */
/*              AND nota-fiscal.nr-nota-fis  = cst-nota-fiscal.nr-nota-fis                       */
/*              AND nota-fiscal.dt-cancela   = ?                                                 */
/*              AND nota-fiscal.dt-emis-nota >= tt-param.c-data-ini                              */
/*              AND nota-fiscal.dt-emis-nota <= tt-param.c-data-fim,                             */
/*             EACH fat-duplic NO-LOCK                                                           */
/*            WHERE fat-duplic.cod-estabel = nota-fiscal.cod-estabel                             */
/*              AND fat-duplic.serie       = nota-fiscal.serie                                   */
/*              AND fat-duplic.nr-fatura   = nota-fiscal.nr-nota-fis                             */
/*             BREAK BY cst-nota-fiscal.cod-estabel                                              */
/*           BY cst-nota-fiscal.serie                                                            */
/*           BY cst-nota-fiscal.nr-nota-fis                                                      */
/*            query-tuning(no-lookahead):                                                        */
/*                                                                                               */
/*                                                                                               */
/*            RUN pi-acompanhar IN h-acomp (INPUT STRING(cst-nota-fiscal.cod-estabel) + " | " +  */
/*                                                STRING(cst-nota-fiscal.serie      ) + " | " +  */
/*                                                STRING(cst-nota-fiscal.nr-nota-fis) ).         */
/*                                                                                               */
/*                                                                                               */
/*                                                                                               */
/*                                                                                               */
/*              ASSIGN c-cod-esp-ori      = ""                                                   */
/*                     c-cod-esp-new      = ""                                                   */
/*                     c-cod-portador-ori = 0                                                    */
/*                     c-cod-portador-new = 0                                                    */
/*                     c-cod-usuario      = ""                                                   */
/*                     d-dat-alteracao    = "".                                                  */
/*                                                                                               */
/*              IF SUBSTRING(fat-duplic.char-2,1,2) = "" THEN DO:                                */
/*                  ASSIGN c-cod-esp-ori      = fat-duplic.cod-esp                               */
/*                         c-cod-portador-ori = fat-duplic.int-1.                                */
/*              END.                                                                             */
/*              ELSE DO:                                                                         */
/*                                                                                               */
/*                  ASSIGN c-cod-esp-ori      = SUBSTRING(fat-duplic.char-2,1,2)                 */
/*                         c-cod-portador-ori = INT(SUBSTRING(fat-duplic.char-2,3,5)).           */
/*                  ASSIGN c-cod-esp-new      = fat-duplic.cod-esp                               */
/*                         c-cod-portador-new = fat-duplic.int-1                                 */
/*                         c-cod-usuario      = SUBSTRING(fat-duplic.char-2,10,12)               */
/*                         d-dat-alteracao    = SUBSTRING(fat-duplic.char-2,30,20).              */
/*                                                                                               */
/*                  IF c-cod-esp-ori      = c-cod-esp-new AND                                    */
/*                     c-cod-portador-ori = c-cod-portador-new  THEN DO:                         */
/*                                                                                               */
/*                      ASSIGN c-cod-esp-ori      = fat-duplic.cod-esp                           */
/*                             c-cod-portador-ori = fat-duplic.int-1  .                          */
/*                      ASSIGN c-cod-esp-new      = ""                                           */
/*                             c-cod-portador-new = 0                                            */
/*                             c-cod-usuario      = ""                                           */
/*                             d-dat-alteracao    = "".                                          */
/*                                                                                               */
/*                  END.                                                                         */
/*              END.                                                                             */
/*                                                                                               */
/*                 DISP nota-fiscal.cod-estabel                                                  */
/*                      nota-fiscal.serie                                                        */
/*                      nota-fiscal.nr-nota-fis                                                  */
/*                      nota-fiscal.dt-emis-nota                                                 */
/*                      nota-fiscal.vl-tot-nota                                                  */
/*                      fat-duplic.parcela                                                       */
/*                      fat-duplic.vl-parcela COLUMN-LABEL "Val.Parcela"                         */
/*                      c-cod-esp-ori                                                            */
/*                      c-cod-portador-ori                                                       */
/*                      c-cod-esp-new                                                            */
/*                      c-cod-portador-new                                                       */
/*                      c-cod-usuario                                                            */
/*                      d-dat-alteracao                                                          */
/*                      fat-duplic.flag-atualiz                                                  */
/*                      WITH WIDTH 333 STREAM-IO DOWN FRAME f-cupom-manual.                      */
/*                 DOWN WITH FRAME f-cupom-manual.                                               */
/*                                                                                               */
/*         END.                                                                                  */
/*     END.                                                                                      */



/* PROCEDURE pi-envia-vale-folha:                                                                        */
/*     DEFINE VARIABLE nomeColab   AS CHARACTER FORMAT "x(40)" COLUMN-LABEL "Nome Colaborador" NO-UNDO.  */
/*     DEFINE VARIABLE indSituacao AS CHARACTER FORMAT "x(15)" COLUMN-LABEL "Situa‡Æo":U       NO-UNDO.  */
/*                                                                                                       */
/*     DISP FILL("-",50) FORMAT "x(50)"                                                                  */
/*          " VALES INTEGRADOS " FORMAT "x(19)"                                                          */
/*          FILL("-",50) FORMAT "x(50)"                                                                  */
/*     WITH WIDTH 333 STREAM-IO DOWN FRAME f-tit-enviado.                                                */
/*            DOWN WITH FRAME f-tit-enviado.                                                             */
/*                                                                                                       */
/*     IF tt-param.i-processa = 2 THEN DO:                                                               */
/*         FOR EACH cst-furo-caixa                                                                       */
/*            WHERE cst-furo-caixa.dat-bordero >= tt-param.c-data-ini                                    */
/*              AND cst-furo-caixa.dat-bordero <= tt-param.c-data-fim                                    */
/*              AND cst-furo-caixa.tip-furo = "VALE"                                                     */
/*              AND cst-furo-caixa.situacao = 1:                                                         */
/*                                                                                                       */
/*              ASSIGN cst-furo-caixa.situacao = 3.                                                      */
/*                                                                                                       */
/*             CREATE VUSU_TFURCAI.                                                                      */
/*             ASSIGN VUSU_TFURCAI.USU_BORDERO   = INT(cst-furo-caixa.num-bordero)                       */
/*                    VUSU_TFURCAI.USU_CODFIL    = INT(cst-furo-caixa.cod-estab)                         */
/*                    VUSU_TFURCAI.USU_DATEMI    = cst-furo-caixa.dat-bordero.                           */
/*             ASSIGN VUSU_TFURCAI.USU_DATENT    = cst-furo-caixa.dat-bordero                            */
/*                    VUSU_TFURCAI.USU_INTFOL    = "N".                                                  */
/*             ASSIGN VUSU_TFURCAI.USU_NUMCAD    = INT(cst-furo-caixa.mat-colabor)                       */
/*                    VUSU_TFURCAI.USU_NUMEMP    = 1                                                     */
/*                    VUSU_TFURCAI.USU_ORIGEM    = "F".                                                  */
/*             ASSIGN VUSU_TFURCAI.USU_TIPCOL    = YES.                                                  */
/*             ASSIGN VUSU_TFURCAI.USU_USUARIO   = v_cod_usuar_corren                                    */
/*                    VUSU_TFURCAI.USU_VALFUR    = cst-furo-caixa.vl-furo                                */
/*                 .                                                                                     */
/*                                                                                                       */
/*             ASSIGN indSituacao = "Integrado FP".                                                      */
/*                                                                                                       */
/*             FIND FIRST VR034FUN NO-LOCK                                                               */
/*                  WHERE VR034FUN.NUMCAD = INT(cst-furo-caixa.mat-colabor) NO-ERROR.                    */
/*             IF AVAIL VR034FUN THEN DO:                                                                */
/*                 ASSIGN nomeColab = CAPS(VR034FUN.NOMFUN).                                             */
/*             END.                                                                                      */
/*                                                                                                       */
/*             DISP cst-furo-caixa.cod-estab                                                             */
/*                  cst-furo-caixa.num-bordero                                                           */
/*                  cst-furo-caixa.dat-bordero                                                           */
/*                  cst-furo-caixa.tip-furo                                                              */
/*                  cst-furo-caixa.mat-colabor FORMAT "x(12)"                                            */
/*                  nomeColab                                                                            */
/*                  cst-furo-caixa.vl-furo                                                               */
/*                  indSituacao                                                                          */
/*                  WITH WIDTH 333 STREAM-IO DOWN FRAME f-bordero.                                       */
/*             DOWN WITH FRAME f-bordero.                                                                */
/*         END.                                                                                          */
/*     END.                                                                                              */
/*     ELSE IF tt-param.i-processa = 1 THEN DO:                                                          */
/*                                                                                                       */
/*         FOR EACH cst-furo-caixa                                                                       */
/*            WHERE INT(cst-furo-caixa.mat-colabor) = tt-param.i-codFun                                  */
/*              AND cst-furo-caixa.tip-furo = "VALE"                                                     */
/*              AND cst-furo-caixa.situacao = 1:                                                         */
/*                                                                                                       */
/*              ASSIGN cst-furo-caixa.situacao = 3.                                                      */
/*                                                                                                       */
/*             CREATE VUSU_TFURCAI.                                                                      */
/*             ASSIGN VUSU_TFURCAI.USU_BORDERO   = INT(cst-furo-caixa.num-bordero)                       */
/*                    VUSU_TFURCAI.USU_CODFIL    = INT(cst-furo-caixa.cod-estab)                         */
/*                    VUSU_TFURCAI.USU_DATEMI    = cst-furo-caixa.dat-bordero.                           */
/*             ASSIGN VUSU_TFURCAI.USU_DATENT    = cst-furo-caixa.dat-bordero                            */
/*                    VUSU_TFURCAI.USU_INTFOL    = "N".                                                  */
/*             ASSIGN VUSU_TFURCAI.USU_NUMCAD    = INT(cst-furo-caixa.mat-colabor)                       */
/*                    VUSU_TFURCAI.USU_NUMEMP    = 1                                                     */
/*                    VUSU_TFURCAI.USU_ORIGEM    = "F".                                                  */
/*             ASSIGN VUSU_TFURCAI.USU_TIPCOL    = YES.                                                  */
/*             ASSIGN VUSU_TFURCAI.USU_USUARIO   = v_cod_usuar_corren                                    */
/*                    VUSU_TFURCAI.USU_VALFUR    = cst-furo-caixa.vl-furo                                */
/*                 .                                                                                     */
/*                                                                                                       */
/*             ASSIGN indSituacao = "Integrado FP".                                                      */
/*                                                                                                       */
/*             FIND FIRST VR034FUN NO-LOCK                                                               */
/*                  WHERE VR034FUN.NUMCAD = INT(cst-furo-caixa.mat-colabor) NO-ERROR.                    */
/*             IF AVAIL VR034FUN THEN DO:                                                                */
/*                 ASSIGN nomeColab = CAPS(VR034FUN.NOMFUN).                                             */
/*             END.                                                                                      */
/*                                                                                                       */
/*             DISP cst-furo-caixa.cod-estab                                                             */
/*                  cst-furo-caixa.num-bordero                                                           */
/*                  cst-furo-caixa.dat-bordero                                                           */
/*                  cst-furo-caixa.tip-furo                                                              */
/*                  cst-furo-caixa.mat-colabor FORMAT "x(12)"                                            */
/*                  nomeColab                                                                            */
/*                  cst-furo-caixa.vl-furo                                                               */
/*                  indSituacao                                                                          */
/*                  WITH WIDTH 333 STREAM-IO DOWN FRAME f-bordero-func.                                  */
/*             DOWN WITH FRAME f-bordero-func.                                                           */
/*         END.                                                                                          */
/*     END.                                                                                              */
/*                                                                                                       */
/* END PROCEDURE.                                                                                        */



