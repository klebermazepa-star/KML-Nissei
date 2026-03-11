/********************************************************************************
*******************************************************************************/
{include/i-prgvrs.i NICR020RP 2.06.00.001}  
{include/i_fnctrad.i}
/******************************************************************************
**
**       PROGRAMA: NICR020RP
**
**       DATA....: 06/2017
**
**       OBJETIVO: Mostrar a composi‡Æo das Faturas de Convˆnio(ICS)
**
**       VERSAO..: 2.06.001
** 
******************************************************************************/
DEFINE BUFFER portador   FOR ems5.portador.
DEFINE BUFFER bf_tit_acr FOR tit_acr.
DEFINE BUFFER cliente    FOR ems5.cliente.
DEFINE BUFFER bf_cliente    FOR ems5.cliente.

{include/i-rpvar.i}
/* {include/i-rpcab.i} */
/* {utp/ut-glob.i} */ 
    
 def new Global shared var c-seg-usuario        as char format "x(12)" no-undo.
DEFINE NEW GLOBAL SHARED VARIABLE v_cod_empres_usuar AS CHARACTER FORMAT "x(3)":U NO-UNDO.

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
    FIELD c-estab-ini      LIKE tit_acr.cod_estab     
    FIELD c-estab-fim      LIKE tit_acr.cod_estab
    FIELD c-serie-ini      LIKE tit_acr.cod_ser_docto
    FIELD c-serie-fim      LIKE tit_acr.cod_ser_docto
    FIELD c-especie-ini    LIKE tit_acr.cod_espec_docto
    FIELD c-especie-fim    LIKE tit_acr.cod_espec_docto
    FIELD c-fatura-ini     LIKE tit_acr.cod_tit_acr
    FIELD c-fatura-fim     LIKE tit_acr.cod_tit_acr
    FIELD c-parcela-ini    LIKE tit_acr.cod_parcela
    FIELD c-parcela-fim    LIKE tit_acr.cod_parcela
    FIELD c-emissao-ini    LIKE tit_acr.dat_emis_docto
    FIELD c-emissao-fim    LIKE tit_acr.dat_emis_docto
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

assign c-programa = "NICR020"
       c-versao   = "2.06"
       c-revisao  = "001"
       c-empresa  = empresa.razao-social.

find first tt-param no-lock no-error.
/* {include/i-rpout.i} */
{utp/ut-liter.i Fatura_Convenio_-_Composicao * L}
assign c-titulo-relat = trim(return-value).
{utp/ut-liter.i Contas_Receber * L}
assign c-sistema = trim(return-value).

/* VIEW frame f-cabec.  */
/* view frame f-rodape. */

RUN utp/ut-acomp.p PERSISTENT SET h-acomp.
RUN pi-inicializar IN h-acomp (INPUT "Fatura Convˆnio- Composi‡Æo":U).

RUN pi-mostra-composicao-fatura.

RUN pi-finalizar IN h-acomp.                       


/* {include/i-rpclo.i} */

RETURN "OK":U.

PROCEDURE pi-mostra-composicao-fatura:

    OUTPUT TO VALUE(SESSION:TEMP-DIRECTORY + "NICR020.csv.") NO-CONVERT.

    PUT UNFORMATTED
        "Estab.Fatura"     +  ";"
        "Espec.Fatura"     +  ";"
        "Serie.Fatura"     +  ";"
        "Num.Fatura"       +  ";"
        "Parc.Fatura"      +  ";"
        "Cliente Convˆnio" +  ";"
        "CNPJ Convˆnio"    +  ";"
        "Cod. Convˆnio"    +  ";"
        "Emissao.Fatura"   +  ";"
        "Vencto.Fatura"    +  ";"
        "Estab.Cupom"      +  ";"
        "Espec.Cupom"      +  ";"
        "Serie.Cupom"      +  ";"
        "Num.Cupom"        +  ";"
        "Parcela.Cupom"    +  ";"
        "ID Pedido"        +  ";"
        "Data Cupom"       +  ";" 
        "CodigoEMS_Func"   +  ";"
        "CPF_Func"         +  ";"
        "Nome_Func"        +  ";"
        "Valor Cupom"      +  ";"
        "OrgÆo"            +  ";"
        "Categoria"        +  ";"
        SKIP.
        

    FOR EACH tit_acr NO-LOCK
       WHERE tit_acr.cod_estab       >= tt-param.c-estab-ini  
         AND tit_acr.cod_estab       <= tt-param.c-estab-fim  
         AND tit_acr.cod_ser_docto   >= tt-param.c-serie-ini  
         AND tit_acr.cod_ser_docto   <= tt-param.c-serie-fim  
         AND tit_acr.cod_espec_docto >= tt-param.c-especie-ini
         AND tit_acr.cod_espec_docto <= tt-param.c-especie-fim
         AND tit_acr.cod_tit_acr     >= tt-param.c-fatura-ini 
         AND tit_acr.cod_tit_acr     <= tt-param.c-fatura-fim 
         AND tit_acr.cod_parcela     >= tt-param.c-parcela-ini
         AND tit_acr.cod_parcela     <= tt-param.c-parcela-fim
         AND tit_acr.dat_emis_docto  >= tt-param.c-emissao-ini
         AND tit_acr.dat_emis_docto  <= tt-param.c-emissao-fim  QUERY-TUNING(NO-LOOKAHEAD):

        RUN pi-seta-titulo IN h-acomp (INPUT STRING("Fatura: ") + 
                                             STRING(tit_acr.cod_tit_acr) + " | " +
                                             STRING(tit_acr.cod_parcela) ).

        FIND FIRST cliente NO-LOCK
             WHERE cliente.cdn_cliente = tit_acr.cdn_cliente NO-ERROR.

        FIND FIRST renegoc_acr NO-LOCK
             WHERE renegoc_acr.num_renegoc_cobr_acr = tit_acr.num_renegoc_cobr_acr NO-ERROR.
        IF AVAIL renegoc_acr THEN DO:

            FOR EACH estabelecimento NO-LOCK
               WHERE estabelecimento.cod_empresa = v_cod_empres_usuar 
                QUERY-TUNING(NO-LOOKAHEAD):

                movto_tit_block:
                FOR EACH movto_tit_acr NO-LOCK 
                   WHERE movto_tit_acr.cod_estab           = estabelecimento.cod_estab
                     AND movto_tit_acr.cod_refer           = renegoc_acr.cod_refer
                     AND movto_tit_acr.ind_trans_acr_abrev = "LQRN" /*l_lqrn*/ 
               USE-INDEX mvtttcr_refer
               QUERY-TUNING(NO-LOOKAHEAD):

                    IF movto_tit_acr.cod_estab_proces_bxa <> renegoc_acr.cod_estab THEN NEXT.

                    FIND FIRST bf_tit_acr USE-INDEX titacr_token 
                         WHERE bf_tit_acr.cod_estab      = movto_tit_acr.cod_estab 
                           AND bf_tit_acr.num_id_tit_acr = movto_tit_acr.num_id_tit_acr NO-ERROR.

                    IF AVAIL bf_tit_acr THEN DO:

                        FOR FIRST cst_nota_fiscal NO-LOCK                                              
                            WHERE cst_nota_fiscal.cod_estabel = bf_tit_acr.cod_estab           
                              AND cst_nota_fiscal.serie       = bf_tit_acr.cod_ser_docto 
                              AND cst_nota_fiscal.nr_nota_fis = bf_tit_acr.cod_tit_acr
                           query-tuning(no-lookahead):
                            
                            FIND FIRST bf_cliente NO-LOCK
                                 WHERE bf_cliente.cdn_cliente = bf_tit_acr.cdn_cliente NO-ERROR.

                            RUN pi-acompanhar IN h-acomp (INPUT STRING("Cupom: ") + 
                                                                STRING(bf_tit_acr.cod_tit_acr) + " | " +
                                                                STRING(bf_tit_acr.cod_parcela) ).

                                PUT UNFORMATTED
                                    tit_acr.cod_estab                  ";"  
                                    tit_acr.cod_espec_docto            ";"
                                    tit_acr.cod_ser_docto              ";"
                                    tit_acr.cod_tit_acr                ";"
                                    tit_acr.cod_parcela                ";"
                                    cliente.cdn_cliente                ";"
                                    cliente.cod_id_feder               ";"
                                    cst_nota_fiscal.convenio           ";"
                                    tit_acr.dat_emis_docto             ";"
                                    tit_acr.dat_vencto_tit_acr         ";"
                                    bf_tit_acr.cod_estab               ";"
                                    bf_tit_acr.cod_espec_docto         ";"
                                    bf_tit_acr.cod_ser_docto           ";"
                                    bf_tit_acr.cod_tit_acr             ";"
                                    bf_tit_acr.cod_parcela             ";"
                                    cst_nota_fiscal.id_pedido_convenio ";"
                                    bf_tit_acr.dat_emis_docto          ";"
                                    bf_cliente.cdn_cliente             ";"
                                    bf_cliente.cod_id_feder            ";"
                                    bf_cliente.nom_pessoa              ";"
                                    bf_tit_acr.val_origin_tit_acr      ";"
                                    cst_nota_fiscal.orgao              ";"
                                    cst_nota_fiscal.categoria          ";"
                                    SKIP.

                        END.
                        
                    END.
                END.
            END.
        END.

    END.
    OUTPUT CLOSE.

    OS-COMMAND NO-WAIT VALUE('start '+ SESSION:TEMP-DIR + "NICR020.csv"). 

    
END PROCEDURE. /* pi-mostra-composicao-fatura */

/* PROCEDURE pi-mostra-cupom-cartao-manual:                                                      */
/*                                                                                               */
/*     FOR EACH cst_nota_fiscal NO-LOCK USE-INDEX cartao_manual                                  */
/*        WHERE cst_nota_fiscal.cartao-manual = TRUE                                             */
/*          AND cst_nota_fiscal.cod-estabel   >= tt-param.c-estab-ini                            */
/*          AND cst_nota_fiscal.cod-estabel   <= tt-param.c-estab-fim                            */
/*          AND cst_nota_fiscal.serie         >= tt-param.c-serie-ini                            */
/*          AND cst_nota_fiscal.serie         <= tt-param.c-serie-fim                            */
/*          AND cst_nota_fiscal.nr-nota-fis   >= tt-param.c-nota-ini                             */
/*          AND cst_nota_fiscal.nr-nota-fis   <= tt-param.c-nota-fim,                            */
/*        FIRST nota-fiscal  NO-LOCK                                                             */
/*            WHERE nota-fiscal.cod-estabel  = cst_nota_fiscal.cod-estabel                       */
/*              AND nota-fiscal.serie        = cst_nota_fiscal.serie                             */
/*              AND nota-fiscal.nr-nota-fis  = cst_nota_fiscal.nr-nota-fis                       */
/*              AND nota-fiscal.dt-cancela   = ?                                                 */
/*              AND nota-fiscal.dt-emis-nota >= tt-param.c-data-ini                              */
/*              AND nota-fiscal.dt-emis-nota <= tt-param.c-data-fim,                             */
/*             EACH fat-duplic NO-LOCK                                                           */
/*            WHERE fat-duplic.cod-estabel = nota-fiscal.cod-estabel                             */
/*              AND fat-duplic.serie       = nota-fiscal.serie                                   */
/*              AND fat-duplic.nr-fatura   = nota-fiscal.nr-nota-fis                             */
/*             BREAK BY cst_nota_fiscal.cod-estabel                                              */
/*           BY cst_nota_fiscal.serie                                                            */
/*           BY cst_nota_fiscal.nr-nota-fis                                                      */
/*            query-tuning(no-lookahead):                                                        */
/*                                                                                               */
/*                                                                                               */
/*            RUN pi-acompanhar IN h-acomp (INPUT STRING(cst_nota_fiscal.cod-estabel) + " | " +  */
/*                                                STRING(cst_nota_fiscal.serie      ) + " | " +  */
/*                                                STRING(cst_nota_fiscal.nr-nota-fis) ).         */
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


/* Procedure External ***********************************************************************************************************************************************************************/     
procedure WinExec external "kernel32.dll":

define input parameter prog_name    as character.                                     
define input parameter visual_style as short.    

end procedure.                                                                        
/* Procedure External ***********************************************************************************************************************************************************************/     

