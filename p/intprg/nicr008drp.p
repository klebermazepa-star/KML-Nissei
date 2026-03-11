/********************************************************************************
*******************************************************************************/
{include/i-prgvrs.i NICR008DRP 2.06.00.001}  
{include/i_fnctrad.i}
/******************************************************************************
**
**       PROGRAMA: NICR008DRP
**
**       DATA....: 06/2016
**
**       OBJETIVO: Relÿtorio da Conferencia do Furo de Caixa
**
**       VERSAO..: 2.06.001
** 
******************************************************************************/
DEFINE BUFFER portador         FOR ems5.portador.
DEFINE BUFFER bf_movto_tit_acr FOR movto_tit_acr.


{include/i-rpvar.i}
{include/i-rpcab.i}
/* {utp/ut-glob.i} */ 
    
 def new Global shared var c-seg-usuario        as char format "x(12)" no-undo.

{method/dbotterr.i} 
/*{cdp/cd0666.i}       Definicao da temp-table de erros */

{include/tt-edit.i}
{include/pi-edit.i}

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
    FIELD estab-ini        AS CHAR FORMAT "x(05)"
    FIELD estab-fim        AS CHAR FORMAT "x(05)"
    FIELD matricula-ini    LIKE vale_manual.mat_funcionario
    FIELD matricula-fim    LIKE vale_manual.mat_funcionario
    FIELD data-ini         LIKE nota-fiscal.dt-emis
    FIELD data-fim         LIKE nota-fiscal.dt-emis
    FIELD l-tg-gerado      AS LOG INITIAL YES
    FIELD l-tg-estornado   AS LOG INITIAL YES
    FIELD l-tg-pendente    AS LOG INITIAL YES
    FIELD l-tg-enviadoFP   AS LOG INITIAL YES
    FIELD l-tg-vale        AS LOG INITIAL YES
    FIELD l-tg-valeger     AS LOG INITIAL YES
    FIELD l-tg-sinistro    AS LOG INITIAL YES
    FIELD l-tg-perda       AS LOG INITIAL YES
    FIELD motivo           AS CHAR 
    FIELD historico        AS LOG
    FIELD classif          AS INT
.

def new global shared var v_cod_usuar_corren
    as character
    format "x(12)":U
    label "Usu˜rio Corrente"
    column-label "Usu˜rio Corrente"
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


def var c-acompanha    as char    no-undo.
DEF VAR h-acomp        AS HANDLE  NO-UNDO.
DEF VAR c-nom-arq      AS CHAR    NO-UNDO.
DEF VAR c-data         AS CHAR    NO-UNDO.
DEF VAR i-cont         AS INTEGER NO-UNDO.
DEF VAR i-linha        AS INTEGER NO-UNDO.

DEF VAR v_hdl_program     AS HANDLE  FORMAT ">>>>>>9":U NO-UNDO.
DEF var v_log_integr_cmg  AS LOGICAL FORMAT "Sim/N’o":U INITIAL NO LABEL "CMG" COLUMN-LABEL "CMG" NO-UNDO.

def var c_cod_table               as character         format "x(8)"                no-undo.
def var w_estabel                 as character         format "x(3)"                no-undo.
def var c-cod-refer               as character         format "x(10)"               no-undo.
def var v_log_refer_uni           as log                                            no-undo.

DEF VAR d-vlTotalVale             LIKE cst_furo_caixa.vl_furo.
DEF VAR d-vlTotalSinistro         LIKE cst_furo_caixa.vl_furo.
DEF VAR d-vlTotalPerda            LIKE cst_furo_caixa.vl_furo.
DEF VAR d-vlTotalGeral            LIKE cst_furo_caixa.vl_furo.

DEFINE TEMP-TABLE tt-int_ds_furo_caixa LIKE int_ds_furo_caixa
    FIELD r-rowid AS ROWID.

find first param-estoq  no-lock no-error.
find first param-global no-lock no-error.
find first ems2mult.empresa where 
           empresa.ep-codigo = param-global.empresa-prin no-lock no-error.

assign c-programa = "NICR008D"
       c-versao   = "2.06"
       c-revisao  = "001"
       c-empresa  = empresa.razao-social.

find first tt-param no-lock no-error.
{include/i-rpout.i}
{utp/ut-liter.i Confer¼ncia_Furo_Caixa * L}
assign c-titulo-relat = trim(return-value).
{utp/ut-liter.i Contas_Receber * L}
assign c-sistema = trim(return-value).

VIEW frame f-cabec.
view frame f-rodape.

RUN utp/ut-acomp.p PERSISTENT SET h-acomp.
RUN pi-inicializar IN h-acomp (INPUT "Confer¼ncia Furo Caixa").
                    
IF tt-param.classif = 1 THEN DO:
    RUN pi-imprime-por-matricula.
END.
ELSE DO:
    RUN pi-imprime-por-bordero.
END.

RUN pi-finalizar IN h-acomp.

{include/i-rpclo.i}   

return "OK":U.

PROCEDURE pi-imprime-por-bordero:
    DEFINE VARIABLE numBo       AS CHARACTER FORMAT "x(12)" COLUMN-LABEL "Num. B.O"         NO-UNDO.
    DEFINE VARIABLE nomeColab   AS CHARACTER FORMAT "x(40)" COLUMN-LABEL "Nome Colaborador" NO-UNDO.
    DEFINE VARIABLE indSituacao AS CHARACTER FORMAT "x(15)" COLUMN-LABEL "Situa»’o":U       NO-UNDO.

    ASSIGN d-vlTotalVale     = 0   //KML
           d-vlTotalSinistro = 0
           d-vlTotalPerda    = 0
           d-vlTotalGeral    = 0.

    FOR EACH cst_furo_caixa 
       WHERE cst_furo_caixa.cod_estab        >= tt-param.estab-ini    
         AND cst_furo_caixa.cod_estab        <= tt-param.estab-fim    
         AND INT(cst_furo_caixa.mat_colabor) >= tt-param.matricula-ini
         AND INT(cst_furo_caixa.mat_colabor) <= tt-param.matricula-fim
         AND cst_furo_caixa.dat_bordero      >= tt-param.data-ini     
         AND cst_furo_caixa.dat_bordero      <= tt-param.data-fim      NO-LOCK
          BY cst_furo_caixa.num_bordero :

        RUN pi-acompanhar IN h-acomp(INPUT "Bordero: " + STRING(cst_furo_caixa.num_bordero)).

        IF tt-param.l-tg-gerado = NO THEN DO:
            IF cst_furo_caixa.situacao  = 1 THEN NEXT.
        END.
        
        IF tt-param.l-tg-estornado = NO THEN DO:
            IF cst_furo_caixa.situacao  = 2 THEN NEXT.
        END.
        
        IF tt-param.l-tg-pendente = NO THEN DO:
            IF cst_furo_caixa.situacao  = 5 THEN NEXT.
        END.
        
        IF tt-param.l-tg-enviadoFP = NO THEN DO:
            IF cst_furo_caixa.situacao  = 3 THEN NEXT.
        END.

        IF tt-param.l-tg-vale = NO THEN DO:
            IF cst_furo_caixa.tip_furo = "VALE" THEN NEXT.
        END.
		
		IF tt-param.l-tg-valeger = NO THEN DO:
            IF cst_furo_caixa.tip_furo = "VALEGER" THEN NEXT.
        END.
        
        IF tt-param.l-tg-sinistro = NO THEN DO:
            IF cst_furo_caixa.tip_furo = "SINISTRO" THEN NEXT.
        END.
        
        IF tt-param.l-tg-perda = NO THEN DO:
            IF cst_furo_caixa.tip_furo = "PERDA" THEN NEXT.
        END.


/*         IF tt-param.motivo = "VALE" THEN DO:                    */
/*             IF cst_furo_caixa.tip_furo <> "VALE" THEN NEXT.     */
/*         END.                                                    */
/*         ELSE IF tt-param.motivo = "SINISTRO" THEN DO:           */
/*             IF cst_furo_caixa.tip_furo <> "SINISTRO" THEN NEXT. */
/*         END.                                                    */
/*         ELSE IF tt-param.motivo = "PERDA" THEN DO:              */
/*             IF cst_furo_caixa.tip_furo <> "PERDA" THEN NEXT.    */
/*         END.                                                    */

        IF cst_furo_caixa.situacao = 1 THEN
            ASSIGN indSituacao = "Gerado".
        ELSE IF cst_furo_caixa.situacao = 2 THEN
            ASSIGN indSituacao = "Estornado".
        ELSE IF cst_furo_caixa.situacao = 5 THEN
            ASSIGN indSituacao = "Pendente".
        ELSE IF cst_furo_caixa.situacao = 3 THEN
            ASSIGN indSituacao = "Enviado FP".
        ELSE ASSIGN indSituacao = "Outro Verificar".

        IF cst_furo_caixa.tip_furo = "SINISTRO" THEN
             ASSIGN numBo = STRING(cst_furo_caixa.num_bo).
        ELSE ASSIGN numBo = "".

/*         FIND FIRST VR034FUN NO-LOCK                                            */
/*              WHERE VR034FUN.NUMCAD = INT(cst_furo_caixa.mat_colabor) NO-ERROR. */
/*         IF AVAIL VR034FUN THEN DO:                                             */
/*             ASSIGN nomeColab = CAPS(VR034FUN.NOMFUN).                          */
/*         END.                                                                   */
        
        IF cst_furo_caixa.tip_furo = "VALE" THEN DO:
            ASSIGN d-vlTotalVale = d-vlTotalVale + cst_furo_caixa.vl_furo.
        END.
        ELSE IF cst_furo_caixa.tip_furo = "SINISTRO" THEN DO:
            ASSIGN d-vlTotalSinistro = d-vlTotalSinistro + cst_furo_caixa.vl_furo.
        END.
        ELSE IF cst_furo_caixa.tip_furo = "PERDA" THEN DO:
            ASSIGN d-vlTotalPerda = d-vlTotalPerda + cst_furo_caixa.vl_furo.
        END.  
    
       ELSE IF cst_furo_caixa.tip_furo = "VALEGER" THEN DO:
            ASSIGN d-vlTotalVale = d-vlTotalVale + cst_furo_caixa.vl_furo.
        END.  

        FIND FIRST tit_acr NO-LOCK
             WHERE tit_acr.cod_estab      = cst_furo_caixa.cod_estab
               AND tit_acr.num_id_tit_acr = cst_furo_caixa.num_id_tit_acr NO-ERROR.
        IF AVAIL tit_acr THEN DO:
            DISP cst_furo_caixa.cod_estab
                 cst_furo_caixa.num_bordero
                 cst_furo_caixa.dat_bordero
                 cst_furo_caixa.tip_furo
                 numBo
                 cst_furo_caixa.mat_colabor FORMAT "x(12)"
                 cst_furo_caixa.nome_func /* nomeColab */
                 cst_furo_caixa.vl_furo
                 indSituacao
                 tit_acr.cod_estab
                 tit_acr.cod_espec_docto 
                 tit_acr.cod_ser_docto 
                 tit_acr.cod_tit_acr 
                 tit_acr.cod_parcela
                 WITH WIDTH 333 STREAM-IO DOWN FRAME f-bordero.
            DOWN WITH FRAME f-bordero.       
        END.
        ELSE DO:
            DISP cst_furo_caixa.cod_estab
                 cst_furo_caixa.num_bordero
                 cst_furo_caixa.dat_bordero
                 cst_furo_caixa.tip_furo
                 numBo
                 cst_furo_caixa.mat_colabor FORMAT "x(12)"
                 cst_furo_caixa.nome_func
                 cst_furo_caixa.vl_furo
                 indSituacao
                 WITH WIDTH 333 STREAM-IO DOWN FRAME f-bordero.
            DOWN WITH FRAME f-bordero.       
        END.

        IF tt-param.historico = YES THEN DO:

            EMPTY TEMP-TABLE tt-editor.

            run pi-print-editor (cst_furo_caixa.des_observ, 120).

            DISP "" FORMAT "x(133)" COLUMN-LABEL "Hist½rico"
                 WITH WIDTH 555 STREAM-IO DOWN FRAME f-historico.
            DOWN WITH FRAME f-historico.

            FOR EACH tt-editor:
                PUT tt-editor.conteudo FORMAT "x(125)"  SKIP.
            END.
        END.

    END.

    ASSIGN d-vlTotalGeral = 0.
           d-vlTotalGeral = d-vlTotalVale + d-vlTotalSinistro + d-vlTotalPerda.

    /* Mostrando o Totalizador */
    DISP "Valor Total Vale.......:  " AT  80  d-vlTotalVale     TO 124
         "Valor Total Sinistro...:  " AT  80  d-vlTotalSinistro TO 124
         "Valor Total Perda......:  " AT  80  d-vlTotalPerda    TO 124
         "Valor Total Geral......:  " AT  80  d-vlTotalGeral    TO 124
        WITH WIDTH 333 STREAM-IO DOWN FRAME  f-Total.
        DOWN WITH FRAME  f-Total NO-LABEL.

END PROCEDURE. /* pi-imprime-por-bordero */

PROCEDURE pi-imprime-por-matricula:
    DEFINE VARIABLE numBo       AS CHARACTER FORMAT "x(12)" COLUMN-LABEL "Num. B.O"         NO-UNDO.
    DEFINE VARIABLE nomeColab   AS CHARACTER FORMAT "x(40)" COLUMN-LABEL "Nome Colaborador" NO-UNDO.
    DEFINE VARIABLE indSituacao AS CHARACTER FORMAT "x(15)" COLUMN-LABEL "Situa»’o":U       NO-UNDO.

    ASSIGN d-vlTotalVale     = 0
           d-vlTotalSinistro = 0
           d-vlTotalPerda    = 0
           d-vlTotalGeral    = 0.

    FOR EACH cst_furo_caixa 
       WHERE cst_furo_caixa.cod_estab        >= tt-param.estab-ini    
         AND cst_furo_caixa.cod_estab        <= tt-param.estab-fim    
         AND INT(cst_furo_caixa.mat_colabor) >= tt-param.matricula-ini
         AND INT(cst_furo_caixa.mat_colabor) <= tt-param.matricula-fim
         AND cst_furo_caixa.dat_bordero      >= tt-param.data-ini     
         AND cst_furo_caixa.dat_bordero      <= tt-param.data-fim      NO-LOCK
          BY cst_furo_caixa.mat_colabor :

        RUN pi-acompanhar IN h-acomp(INPUT "Colaborador: " + STRING(cst_furo_caixa.mat_colabor)).

        IF tt-param.l-tg-gerado = NO THEN DO:
            IF cst_furo_caixa.situacao  = 1 THEN NEXT.
        END.
        
        IF tt-param.l-tg-estornado = NO THEN DO:
            IF cst_furo_caixa.situacao  = 2 THEN NEXT.
        END.
        
        IF tt-param.l-tg-pendente = NO THEN DO:
            IF cst_furo_caixa.situacao  = 5 THEN NEXT.
        END.
        
        IF tt-param.l-tg-enviadoFP = NO THEN DO:
            IF cst_furo_caixa.situacao  = 3 THEN NEXT.
        END.

        IF tt-param.l-tg-vale = NO THEN DO:
            IF cst_furo_caixa.tip_furo = "VALE" THEN NEXT.
        END.
		
		IF tt-param.l-tg-valeger = NO THEN DO:
            IF cst_furo_caixa.tip_furo = "VALEGER" THEN NEXT.
        END.
        
        IF tt-param.l-tg-sinistro = NO THEN DO:
            IF cst_furo_caixa.tip_furo = "SINISTRO" THEN NEXT.
        END.
        
        IF tt-param.l-tg-perda = NO THEN DO:
            IF cst_furo_caixa.tip_furo = "PERDA" THEN NEXT.
        END.

        IF cst_furo_caixa.situacao = 1 THEN
            ASSIGN indSituacao = "Gerado".
        ELSE IF cst_furo_caixa.situacao = 2 THEN
            ASSIGN indSituacao = "Estornado".
        ELSE IF cst_furo_caixa.situacao = 5 THEN
            ASSIGN indSituacao = "Pendente".
        ELSE IF cst_furo_caixa.situacao = 3 THEN
            ASSIGN indSituacao = "Enviado FP".
        ELSE ASSIGN indSituacao = "Outro Verificar".

        IF cst_furo_caixa.tip_furo = "SINISTRO" THEN
             ASSIGN numBo = STRING(cst_furo_caixa.num_bo).
        ELSE ASSIGN numBo = "".

/*         FIND FIRST VR034FUN NO-LOCK                                            */
/*              WHERE VR034FUN.NUMCAD = INT(cst_furo_caixa.mat_colabor) NO-ERROR. */
/*         IF AVAIL VR034FUN THEN DO:                                             */
/*             ASSIGN nomeColab = CAPS(VR034FUN.NOMFUN).                          */
/*         END.                                                                   */

        IF cst_furo_caixa.tip_furo = "VALE" THEN DO:
            ASSIGN d-vlTotalVale = d-vlTotalVale + cst_furo_caixa.vl_furo.
        END.
        ELSE IF cst_furo_caixa.tip_furo = "SINISTRO" THEN DO:
            ASSIGN d-vlTotalSinistro = d-vlTotalSinistro + cst_furo_caixa.vl_furo.
        END.
        ELSE IF cst_furo_caixa.tip_furo = "PERDA" THEN DO:
            ASSIGN d-vlTotalPerda = d-vlTotalPerda + cst_furo_caixa.vl_furo.
        END. 
		
		ELSE IF cst_furo_caixa.tip_furo = "VALEGER" THEN DO:
            ASSIGN d-vlTotalVale = d-vlTotalVale + cst_furo_caixa.vl_furo.
        END. 

        FIND FIRST tit_acr NO-LOCK
             WHERE tit_acr.cod_estab      = cst_furo_caixa.cod_estab
               AND tit_acr.num_id_tit_acr = cst_furo_caixa.num_id_tit_acr NO-ERROR.
        IF AVAIL tit_acr THEN DO:
            DISP cst_furo_caixa.cod_estab
                 cst_furo_caixa.num_bordero
                 cst_furo_caixa.dat_bordero
                 cst_furo_caixa.tip_furo
                 numBo
                 cst_furo_caixa.mat_colabor FORMAT "x(12)"
                 cst_furo_caixa.nome_func
                 cst_furo_caixa.vl_furo
                 indSituacao
                 tit_acr.cod_estab
                 tit_acr.cod_espec_docto 
                 tit_acr.cod_ser_docto 
                 tit_acr.cod_tit_acr 
                 tit_acr.cod_parcela
                 WITH WIDTH 333 STREAM-IO DOWN FRAME f-bordero.
            DOWN WITH FRAME f-bordero.       
        END.
        ELSE DO:
            DISP cst_furo_caixa.cod_estab
                 cst_furo_caixa.num_bordero
                 cst_furo_caixa.dat_bordero
                 cst_furo_caixa.tip_furo
                 numBo
                 cst_furo_caixa.mat_colabor FORMAT "x(12)"
                 cst_furo_caixa.nome_func
                 cst_furo_caixa.vl_furo
                 indSituacao
                 WITH WIDTH 333 STREAM-IO DOWN FRAME f-bordero.
            DOWN WITH FRAME f-bordero.       
        END.

        IF tt-param.historico = YES THEN DO:

            EMPTY TEMP-TABLE tt-editor.

            run pi-print-editor (cst_furo_caixa.des_observ, 120).

            DISP "" FORMAT "x(133)" COLUMN-LABEL "Hist½rico"
                 WITH WIDTH 555 STREAM-IO DOWN FRAME f-historico.
            DOWN WITH FRAME f-historico.

            FOR EACH tt-editor:
                PUT tt-editor.conteudo FORMAT "x(125)"  SKIP.
            END.
        END.

    END.

    ASSIGN d-vlTotalGeral = 0.
           d-vlTotalGeral = d-vlTotalVale + d-vlTotalSinistro + d-vlTotalPerda.

    /* Mostrando o Totalizador */
    DISP "Valor Total Vale.......:  " AT  80  d-vlTotalVale     TO 124
         "Valor Total Sinistro...:  " AT  80  d-vlTotalSinistro TO 124
         "Valor Total Perda......:  " AT  80  d-vlTotalPerda    TO 124
         "Valor Total Geral......:  " AT  80  d-vlTotalGeral    TO 124
        WITH WIDTH 333 STREAM-IO DOWN FRAME f-Total.
        DOWN WITH FRAME f-Total NO-LABEL.


END PROCEDURE. /* pi-imprime-por-matricula */

