/********************************************************************************
*******************************************************************************/
{include/i-prgvrs.i NICR016RP 2.06.00.001}  
{include/i_fnctrad.i}
/******************************************************************************
**
**       PROGRAMA: NICR016RP
**
**       DATA....: 06/2017
**
**       OBJETIVO: Mostrar os Cupons CartÆo Manual e a Altera‡Æo de Portador
                   e Especie.
**
**       VERSAO..: 2.06.001
** 
******************************************************************************/
define buffer portador for ems5.portador.

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
    FIELD c-serie-ini      LIKE nota-fiscal.serie
    FIELD c-serie-fim      LIKE nota-fiscal.serie
    FIELD c-nota-ini       LIKE nota-fiscal.nr-nota-fis
    FIELD c-nota-fim       LIKE nota-fiscal.nr-nota-fis
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

DEF VAR c-cod-esp-ori      LIKE fat-duplic.cod-esp COLUMN-LABEL "Esp.Ori".
DEF VAR c-cod-esp-new      LIKE fat-duplic.cod-esp COLUMN-LABEL "Esp.Alt".
DEF VAR c-cod-portador-ori LIKE nota-fiscal.cod-portador COLUMN-LABEL "Port.Ori".
DEF VAR c-cod-portador-new LIKE nota-fiscal.cod-portador COLUMN-LABEL "Port.Alt".
DEF VAR c-cod-usuario      AS CHAR FORMAT "X(12)" COLUMN-LABEL "Usuar. Alter.".
DEF VAR d-dat-alteracao    AS CHAR FORMAT "X(19)" COLUMN-LABEL "Data Alter.".
     
   
find first param-estoq  no-lock no-error.
find first param-global no-lock no-error.
find first ems2log.empresa where 
           empresa.ep-codigo = param-global.empresa-prin no-lock no-error.

assign c-programa = "NICR008e"
       c-versao   = "2.06"
       c-revisao  = "001"
       c-empresa  = empresa.razao-social.

find first tt-param no-lock no-error.
{include/i-rpout.i}
{utp/ut-liter.i Cupom_CartÆo_Manual_ * L}
assign c-titulo-relat = trim(return-value).
{utp/ut-liter.i Contas_Receber * L}
assign c-sistema = trim(return-value).

VIEW frame f-cabec.
view frame f-rodape.

RUN utp/ut-acomp.p PERSISTENT SET h-acomp.
RUN pi-inicializar IN h-acomp (INPUT "Cupom - CartÆo Manual").

RUN pi-mostra-cupom-cartao-manual.

RUN pi-finalizar IN h-acomp.                       


{include/i-rpclo.i}   

RETURN "OK":U.

PROCEDURE pi-mostra-cupom-cartao-manual:

    FOR EACH cst_nota_fiscal NO-LOCK USE-INDEX cartao_manual
       WHERE cst_nota_fiscal.cartao_manual = TRUE
         AND cst_nota_fiscal.cod_estabel   >= tt-param.c-estab-ini
         AND cst_nota_fiscal.cod_estabel   <= tt-param.c-estab-fim
         AND cst_nota_fiscal.serie         >= tt-param.c-serie-ini
         AND cst_nota_fiscal.serie         <= tt-param.c-serie-fim
         AND cst_nota_fiscal.nr_nota_fis   >= tt-param.c-nota-ini
         AND cst_nota_fiscal.nr_nota_fis   <= tt-param.c-nota-fim,
       FIRST nota-fiscal  NO-LOCK 
           WHERE nota-fiscal.cod-estabel  = cst_nota_fiscal.cod_estabel
             AND nota-fiscal.serie        = cst_nota_fiscal.serie
             AND nota-fiscal.nr-nota-fis  = cst_nota_fiscal.nr_nota_fis
             AND nota-fiscal.dt-cancela   = ?
             AND nota-fiscal.dt-emis-nota >= tt-param.c-data-ini
             AND nota-fiscal.dt-emis-nota <= tt-param.c-data-fim,
            EACH fat-duplic NO-LOCK
           WHERE fat-duplic.cod-estabel = nota-fiscal.cod-estabel
             AND fat-duplic.serie       = nota-fiscal.serie
             AND fat-duplic.nr-fatura   = nota-fiscal.nr-nota-fis
            BREAK BY cst_nota_fiscal.cod_estabel
          BY cst_nota_fiscal.serie      
          BY cst_nota_fiscal.nr_nota_fis
           query-tuning(no-lookahead):


           RUN pi-acompanhar IN h-acomp (INPUT STRING(cst_nota_fiscal.cod_estabel) + " | " +
                                               STRING(cst_nota_fiscal.serie      ) + " | " +
                                               STRING(cst_nota_fiscal.nr_nota_fis) ).    

    

    
             ASSIGN c-cod-esp-ori      = ""
                    c-cod-esp-new      = ""
                    c-cod-portador-ori = 0
                    c-cod-portador-new = 0
                    c-cod-usuario      = ""
                    d-dat-alteracao    = "".
    
             IF SUBSTRING(fat-duplic.char-2,1,2) = "" THEN DO:
                 ASSIGN c-cod-esp-ori      = fat-duplic.cod-esp
                        c-cod-portador-ori = fat-duplic.int-1.
             END.
             ELSE DO:
    
                 ASSIGN c-cod-esp-ori      = SUBSTRING(fat-duplic.char-2,1,2)
                        c-cod-portador-ori = INT(SUBSTRING(fat-duplic.char-2,3,5)).
                 ASSIGN c-cod-esp-new      = fat-duplic.cod-esp 
                        c-cod-portador-new = fat-duplic.int-1
                        c-cod-usuario      = SUBSTRING(fat-duplic.char-2,10,12)
                        d-dat-alteracao    = SUBSTRING(fat-duplic.char-2,30,20).
    
                 IF c-cod-esp-ori      = c-cod-esp-new AND
                    c-cod-portador-ori = c-cod-portador-new  THEN DO:
    
                     ASSIGN c-cod-esp-ori      = fat-duplic.cod-esp
                            c-cod-portador-ori = fat-duplic.int-1  .
                     ASSIGN c-cod-esp-new      = ""
                            c-cod-portador-new = 0
                            c-cod-usuario      = ""
                            d-dat-alteracao    = "".
    
                 END.
             END.
    
                DISP nota-fiscal.cod-estabel
                     nota-fiscal.serie      
                     nota-fiscal.nr-nota-fis
                     nota-fiscal.dt-emis-nota
                     nota-fiscal.vl-tot-nota
                     fat-duplic.parcela
                     fat-duplic.vl-parcela COLUMN-LABEL "Val.Parcela"
                     c-cod-esp-ori
                     c-cod-portador-ori
                     c-cod-esp-new
                     c-cod-portador-new
                     c-cod-usuario
                     d-dat-alteracao
                     fat-duplic.flag-atualiz
                     WITH WIDTH 333 STREAM-IO DOWN FRAME f-cupom-manual.
                DOWN WITH FRAME f-cupom-manual.
    
        END.
    END.



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



