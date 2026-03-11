/********************************************************************************
*******************************************************************************/
{include/i-prgvrs.i NICR007RP 2.06.00.001}  
{include/i_fnctrad.i}
/******************************************************************************
**
**       PROGRAMA: NICR007RP
**
**       DATA....: 01/2016
**
**       OBJETIVO: Importa‡Æo das Liquida‡äes de Cheque e Dinheiro atrav‚s do
                   arquivo enviado pela empresa de transportes de valores.
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
    FIELD c-data-ini       LIKE nota-fiscal.dt-emis
    FIELD c-data-fim       LIKE nota-fiscal.dt-emis
    FIELD i-processa       AS INT FORMAT 9
    FIELD i-codFunc        LIKE VR034FUN.NUMCAD.
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

DEFINE BUFFER bf_movto_tit_acr FOR movto_tit_acr.

def input parameter raw-param as raw no-undo.
def input parameter table for tt-raw-digita.

create tt-param.
raw-transfer raw-param to tt-param.


def var c-acompanha    as char    no-undo.
DEF VAR h-acomp        AS HANDLE  NO-UNDO.
DEF VAR c-nom-arq      AS CHAR    NO-UNDO.
DEF VAR c-data         AS CHAR    NO-UNDO.
DEF VAR i-cont         AS INTEGER NO-UNDO.
DEF VAR i-linha        AS INTEGER NO-UNDO.

DEF VAR v_hdl_program     AS HANDLE  FORMAT ">>>>>>9":U NO-UNDO.
DEF var v_log_integr_cmg  AS LOGICAL FORMAT "Sim/NÆo":U INITIAL NO LABEL "CMG" COLUMN-LABEL "CMG" NO-UNDO.

def var c_cod_table               as character         format "x(8)"                no-undo.
def var w_estabel                 as character         format "x(3)"                no-undo.
def var c-cod-refer               as character         format "x(10)"               no-undo.
def var v_log_refer_uni           as log                                            no-undo.

DEFINE TEMP-TABLE tt-int_ds_furo_caixa LIKE int_ds_furo_caixa
    FIELD r-rowid AS ROWID.

DEFINE STREAM               s-pedido. 

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
{utp/ut-liter.i Exporta‡Æo_Vale_Folha_Pagamento * L}
assign c-titulo-relat = trim(return-value).
{utp/ut-liter.i Contas_Receber * L}
assign c-sistema = trim(return-value).

VIEW frame f-cabec.
view frame f-rodape.

RUN utp/ut-acomp.p PERSISTENT SET h-acomp.
RUN pi-inicializar IN h-acomp (INPUT "Exportar Vale - FP").

DO TRANSACTION:
    RUN pi-envia-vale-folha.
END.

RUN pi-finalizar IN h-acomp.                       


{include/i-rpclo.i}   

return "OK":U.

PROCEDURE pi-envia-vale-folha:
    DEFINE VARIABLE nomeColab   AS CHARACTER FORMAT "x(40)" COLUMN-LABEL "Nome Colaborador" NO-UNDO.
    DEFINE VARIABLE indSituacao AS CHARACTER FORMAT "x(15)" COLUMN-LABEL "Situa‡Æo":U       NO-UNDO.

    DISP FILL("-",50) FORMAT "x(50)"
         " VALES INTEGRADOS " FORMAT "x(19)"
         FILL("-",50) FORMAT "x(50)"
    WITH WIDTH 333 STREAM-IO DOWN FRAME f-tit-enviado.
           DOWN WITH FRAME f-tit-enviado.

    IF tt-param.i-processa = 2 THEN DO:
        FOR EACH cst_furo_caixa 
           WHERE cst_furo_caixa.dat_bordero >= tt-param.c-data-ini 
             AND cst_furo_caixa.dat_bordero <= tt-param.c-data-fim 
             AND cst_furo_caixa.tip_furo = "VALE"
             AND cst_furo_caixa.situacao = 1:
    
             ASSIGN cst_furo_caixa.situacao = 3.

             FIND FIRST bf_movto_tit_acr EXCLUSIVE-LOCK
                  WHERE bf_movto_tit_acr.cod_estab             = cst_furo_caixa.cod_estab
                    AND bf_movto_tit_acr.num_id_tit_acr        = cst_furo_caixa.num_id_tit_acr      
                    AND bf_movto_tit_acr.num_id_movto_tit_acr  = cst_furo_caixa.num_id_movto_tit_acr NO-ERROR.
             IF AVAIL bf_movto_tit_acr THEN DO:
                 ASSIGN bf_movto_tit_acr.log_livre_2 = YES.
             END.
             RELEASE bf_movto_tit_acr.            
            CREATE VUSU_TFURCAI.
            ASSIGN VUSU_TFURCAI.USU_BORDERO   = INT(cst_furo_caixa.num_bordero)
                   VUSU_TFURCAI.USU_CODFIL    = INT(cst_furo_caixa.cod_estab)
                   VUSU_TFURCAI.USU_DATEMI    = cst_furo_caixa.dat_bordero.
            ASSIGN VUSU_TFURCAI.USU_DATENT    = cst_furo_caixa.dat_bordero
                   VUSU_TFURCAI.USU_INTFOL    = "N".
            ASSIGN VUSU_TFURCAI.USU_NUMCAD    = INT(cst_furo_caixa.mat_colabor)
                   VUSU_TFURCAI.USU_NUMEMP    = 1
                   VUSU_TFURCAI.USU_ORIGEM    = "F".
            ASSIGN VUSU_TFURCAI.USU_TIPCOL    = YES.
            ASSIGN VUSU_TFURCAI.USU_USUARIO   = v_cod_usuar_corren
                   VUSU_TFURCAI.USU_VALFUR    = cst_furo_caixa.vl_furo
                .
    
            ASSIGN indSituacao = "Integrado FP".
    
/*             FIND FIRST VR034FUN NO-LOCK                                            */
/*                  WHERE VR034FUN.NUMCAD = INT(cst_furo_caixa.mat_colabor) NO-ERROR. */
/*             IF AVAIL VR034FUN THEN DO:                                             */
/*                 ASSIGN nomeColab = CAPS(VR034FUN.NOMFUN).                          */
/*             END.                                                                   */
    
            DISP cst_furo_caixa.cod_estab
                 cst_furo_caixa.num_bordero
                 cst_furo_caixa.dat_bordero
                 cst_furo_caixa.tip_furo
                 cst_furo_caixa.mat_colabor FORMAT "x(12)"
                 nomeColab
                 cst_furo_caixa.vl_furo
                 indSituacao
                 WITH WIDTH 333 STREAM-IO DOWN FRAME f-bordero.
            DOWN WITH FRAME f-bordero.
        END.
    END.
    ELSE IF tt-param.i-processa = 1 THEN DO:

        FOR EACH cst_furo_caixa 
           WHERE INT(cst_furo_caixa.mat_colabor) = tt-param.i-codFun
             AND cst_furo_caixa.tip_furo = "VALE"
             AND cst_furo_caixa.situacao = 1:
    
             ASSIGN cst_furo_caixa.situacao = 3.

             FIND FIRST bf_movto_tit_acr EXCLUSIVE-LOCK
                  WHERE bf_movto_tit_acr.cod_estab             = cst_furo_caixa.cod_estab
                    AND bf_movto_tit_acr.num_id_tit_acr        = cst_furo_caixa.num_id_tit_acr      
                    AND bf_movto_tit_acr.num_id_movto_tit_acr  = cst_furo_caixa.num_id_movto_tit_acr NO-ERROR.
             IF AVAIL bf_movto_tit_acr THEN DO:
                 ASSIGN bf_movto_tit_acr.log_livre_2 = YES.
             END.
             RELEASE bf_movto_tit_acr.
            
            CREATE VUSU_TFURCAI.
            ASSIGN VUSU_TFURCAI.USU_BORDERO   = INT(cst_furo_caixa.num_bordero)
                   VUSU_TFURCAI.USU_CODFIL    = INT(cst_furo_caixa.cod_estab)
                   VUSU_TFURCAI.USU_DATEMI    = cst_furo_caixa.dat_bordero.
            ASSIGN VUSU_TFURCAI.USU_DATENT    = cst_furo_caixa.dat_bordero
                   VUSU_TFURCAI.USU_INTFOL    = "N".
            ASSIGN VUSU_TFURCAI.USU_NUMCAD    = INT(cst_furo_caixa.mat_colabor)
                   VUSU_TFURCAI.USU_NUMEMP    = 1
                   VUSU_TFURCAI.USU_ORIGEM    = "F".
            ASSIGN VUSU_TFURCAI.USU_TIPCOL    = YES.
            ASSIGN VUSU_TFURCAI.USU_USUARIO   = v_cod_usuar_corren
                   VUSU_TFURCAI.USU_VALFUR    = cst_furo_caixa.vl_furo
                .
    
            ASSIGN indSituacao = "Integrado FP".
    
/*             FIND FIRST VR034FUN NO-LOCK                                            */
/*                  WHERE VR034FUN.NUMCAD = INT(cst_furo_caixa.mat_colabor) NO-ERROR. */
/*             IF AVAIL VR034FUN THEN DO:                                             */
/*                 ASSIGN nomeColab = CAPS(VR034FUN.NOMFUN).                          */
/*             END.                                                                   */
    
            DISP cst_furo_caixa.cod_estab
                 cst_furo_caixa.num_bordero
                 cst_furo_caixa.dat_bordero
                 cst_furo_caixa.tip_furo
                 cst_furo_caixa.mat_colabor FORMAT "x(12)"
                 nomeColab
                 cst_furo_caixa.vl_furo
                 indSituacao
                 WITH WIDTH 333 STREAM-IO DOWN FRAME f-bordero-func.
            DOWN WITH FRAME f-bordero-func.
        END.
    END.

END PROCEDURE.



