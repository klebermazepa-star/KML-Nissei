/********************************************************************************
*******************************************************************************/
{include/i-prgvrs.i NICR025RP 2.06.00.001}  
{include/i_fnctrad.i}
/******************************************************************************
**
**       PROGRAMA: NICR025RP
**
**       DATA....: 10/2018
**
**       OBJETIVO: Realizar a Verifica‡Æo e a Corre‡Æo do ID PEdido Convenio 
                   na tabela de cst_nota_fiscal.
**
**       VERSAO..: 2.06.001
** 
******************************************************************************/
DEFINE BUFFER cliente FOR ems5.cliente.
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
    FIELD dia-vencimento   AS INT
    FIELD convenio-ini     AS INT  
    FIELD convenio-fim     AS INT  
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


def var c-acompanha    as char    no-undo.
DEF VAR h-acomp        AS HANDLE  NO-UNDO.
DEF VAR c-nom-arq      AS CHAR    NO-UNDO.
DEF VAR c-data         AS CHAR    NO-UNDO.
DEF VAR i-cont         AS INTEGER NO-UNDO.
DEF VAR i-linha        AS INTEGER NO-UNDO.
    
find first param-estoq  no-lock no-error.
find first param-global no-lock no-error.
find first ems2mult.empresa where 
           empresa.ep-codigo = param-global.empresa-prin no-lock no-error.

assign c-programa = "NICR025"
       c-versao   = "2.06"
       c-revisao  = "001"
       c-empresa  = empresa.razao-social.

DEFINE TEMP-TABLE tt-convenio NO-UNDO LIKE int_ds_convenio.

find first tt-param no-lock no-error.
{include/i-rpout.i}
{utp/ut-liter.i Verifica‡Æo_ID_Pedido * L}
assign c-titulo-relat = trim(return-value).
{utp/ut-liter.i Contas_Receber * L}
assign c-sistema = trim(return-value).

VIEW frame f-cabec.
view frame f-rodape.

RUN utp/ut-acomp.p PERSISTENT SET h-acomp.
RUN pi-inicializar IN h-acomp (INPUT "Verifica‡Æo ID Pedido").
                    
/* log-manager:logfile-name= "\\192.168.200.52\datasul\_custom_teste\Prog_QG\FuroCaixa.txt".  */
/* log-manager:log-entry-types= "4gltrace".                                                   */
    
FOR EACH int_ds_convenio
   WHERE int_ds_convenio.cod_convenio   >=  tt-param.convenio-ini 
     AND int_ds_convenio.cod_convenio   <=  tt-param.convenio-fim  
     AND int_ds_convenio.dia_fechamento  =  tt-param.dia-vencimento NO-LOCK
      BY int_ds_convenio.cod_convenio:

    RUN pi-acompanhar IN h-acomp(INPUT STRING(int_ds_convenio.cod_convenio)).

    CREATE tt-convenio.
    BUFFER-COPY int_ds_convenio TO tt-convenio.
END.

FOR EACH tt-convenio
      BY tt-convenio.cod_convenio:

    RUN pi-seta-titulo IN h-acomp(INPUT "Convˆnio: " + STRING(INT(tt-convenio.cod_convenio),"999999")).
    RUN pi-acompanhar  IN h-acomp(INPUT "Carregando....").

    FIND FIRST cliente
        WHERE cliente.cod_id_feder = tt-convenio.cnpj NO-LOCK NO-ERROR.

    FOR EACH cst_nota_fiscal EXCLUSIVE-LOCK
       WHERE cst_nota_fiscal.convenio = STRING(INT(tt-convenio.cod_convenio),"999999"),
       FIRST nota-fiscal
       WHERE nota-fiscal.cod-estabel = cst_nota_fiscal.cod_estabel
         AND nota-fiscal.serie       = cst_nota_fiscal.serie      
         AND nota-fiscal.nr-nota-fis = cst_nota_fiscal.nr_nota_fis NO-LOCK
          BY cst_nota_fiscal.cod_estabel
          BY cst_nota_fiscal.serie      
          BY cst_nota_fiscal.nr_nota_fis :

        RUN pi-acompanhar IN h-acomp(INPUT STRING(cst_nota_fiscal.cod_estabel) + "/" +
                                           STRING(cst_nota_fiscal.serie) + "/" + 
                                           STRING(cst_nota_fiscal.nr_nota_fis)).
       
         FIND FIRST tit_acr NO-LOCK
           WHERE tit_acr.cod_estab       = cst_nota_fiscal.cod_estabel
             AND tit_acr.cod_ser_docto   = cst_nota_fiscal.serie      
             AND tit_acr.cod_tit_acr     = cst_nota_fiscal.nr_nota_fis
             AND tit_acr.cod_espec_docto = "CV"
             AND tit_acr.log_sdo_tit_acr = YES NO-ERROR.
         IF AVAIL tit_acr THEN DO:
    
    /*     FOR EACH tit_acr NO-LOCK                                                               */
    /*        WHERE tit_acr.cod_espec_docto = "CV"                                                */
    /*          AND tit_acr.log_sdo_tit_acr = YES,                                                */
    /*        FIRST cst_nota_fiscal EXCLUSIVE-LOCK                                                */
    /*        WHERE cst_nota_fiscal.cod-estabel = tit_acr.cod_estab                               */
    /*          AND cst_nota_fiscal.serie       = tit_acr.cod_ser_docto                           */
    /*          AND cst_nota_fiscal.nr-nota-fis = tit_acr.cod_tit_acr                             */
    /*          AND cst_nota_fiscal.convenio    = STRING(INT(tt-convenio.cod_convenio),"999999"), */
    /*        FIRST nota-fiscal OF cst_nota_fiscal NO-LOCK :                                      */
    
    
            FIND FIRST estabelec
                 WHERE estabelec.cod-estabel = cst_nota_fiscal.cod_estabel NO-LOCK NO-ERROR.
            IF AVAIL estabelec THEN DO:
        
        
                FIND FIRST int_ds_nota_loja USE-INDEX nota_loja
                     WHERE int_ds_nota_loja.cnpj_filial   = estabelec.cgc
                       AND int_ds_nota_loja.serie         = cst_nota_fiscal.serie
                       AND INT(int_ds_nota_loja.num_nota) = INT(cst_nota_fiscal.nr_nota_fis) NO-LOCK NO-ERROR.
                IF AVAIL int_ds_nota_loja THEN DO:
        
        
        
                    IF cst_nota_fiscal.id_pedido_convenio <> int_ds_nota_loja.id_pedido_convenio AND
                       int_ds_nota_loja.id_pedido_convenio <> ? THEN DO:
        
        
        
                        DISP cst_nota_fiscal.cod_estabel         SPACE
                             cst_nota_fiscal.serie               SPACE
                             cst_nota_fiscal.nr_nota_fis         SPACE
                             nota-fiscal.dt-emis                 SPACE
                             STRING(INT(tt-convenio.cod_convenio),"999999") COLUMN-LABEL "Convˆnio" SPACE
                             cst_nota_fiscal.id_pedido_convenio  COLUMN-LABEL "ID Pedido CST" SPACE   SPACE
                             int_ds_nota_loja.id_pedido_convenio COLUMN-LABEL "ID Pedido Barramento"  WITH WIDTH 555 .
        
                        ASSIGN cst_nota_fiscal.id_pedido_convenio = int_ds_nota_loja.id_pedido_convenio.
                    END.
                END.
            END.
        END.
    END.
END.



/* FOR EACH fat-duplic                                                                                             */
/*    WHERE fat-duplic.cod-estabel >= tt-param.estab-ini                                                           */
/*      AND fat-duplic.cod-estabel <= tt-param.estab-fim                                                           */
/*      AND fat-duplic.dt-emis     >= tt-param.data-ini                                                            */
/*      AND fat-duplic.dt-emis     <= tt-param.data-fim                                                            */
/*      AND fat-duplic.cod-esp      = "CV"                                                                         */
/* /*      AND fat-duplic.flag-atualiz = NO */                                                                     */
/*     NO-LOCK,                                                                                                    */
/*    FIRST nota-fiscal                                                                                            */
/*    WHERE nota-fiscal.cod-estabel = fat-duplic.cod-estabel                                                       */
/*      AND nota-fiscal.serie       = fat-duplic.serie                                                             */
/*      AND nota-fiscal.nr-fatura   = fat-duplic.nr-fatura NO-LOCK,                                                */
/*    FIRST cst_nota_fiscal OF nota-fiscal EXCLUSIVE-LOCK:                                                         */
/*                                                                                                                 */
/*     RUN pi-acompanhar IN h-acomp(INPUT  STRING(nota-fiscal.cod-estabel) + "/" +                                 */
/*                                         STRING(nota-fiscal.serie)       + "/" +                                 */
/*                                         STRING(cst_nota_fiscal.nr-nota-fis)).                                   */
/*                                                                                                                 */
/* /*     DISP cst_nota_fiscal.cod-estabel                        */                                               */
/* /*          cst_nota_fiscal.serie                              */                                               */
/* /*          cst_nota_fiscal.nr-nota-fis                        */                                               */
/* /*          cst_nota_fiscal.id_pedido_convenio WITH WIDTH 555. */                                               */
/*     FIND FIRST estabelec                                                                                        */
/*          WHERE estabelec.cod-estabel = cst_nota_fiscal.cod-estabel NO-LOCK NO-ERROR.                            */
/*     IF AVAIL estabelec THEN DO:                                                                                 */
/*                                                                                                                 */
/*                                                                                                                 */
/*         FIND FIRST int_ds_nota_loja                                                                             */
/*              WHERE int_ds_nota_loja.cnpj_filial   = estabelec.cgc                                               */
/*                AND int_ds_nota_loja.serie         = cst_nota_fiscal.serie                                       */
/*                AND INT(int_ds_nota_loja.num_nota) = INT(cst_nota_fiscal.nr-nota-fis) NO-LOCK NO-ERROR.          */
/*         IF AVAIL int_ds_nota_loja THEN DO:                                                                      */
/*                                                                                                                 */
/*                                                                                                                 */
/*                                                                                                                 */
/*             IF cst_nota_fiscal.id_pedido_convenio <> int_ds_nota_loja.id_pedido_convenio AND                    */
/*                int_ds_nota_loja.id_pedido_convenio <> ? THEN DO:                                                */
/*                                                                                                                 */
/*                                                                                                                 */
/*                                                                                                                 */
/*                 DISP cst_nota_fiscal.cod-estabel         SPACE                                                  */
/*                      cst_nota_fiscal.serie               SPACE                                                  */
/*                      cst_nota_fiscal.nr-nota-fis         SPACE                                                  */
/*                      nota-fiscal.dt-emis                 SPACE                                                  */
/*                      cst_nota_fiscal.id_pedido_convenio  COLUMN-LABEL "ID Pedido CST" SPACE   SPACE             */
/*                      int_ds_nota_loja.id_pedido_convenio COLUMN-LABEL "ID Pedido Barramento"  WITH WIDTH 555 .  */
/*                                                                                                                 */
/*                 ASSIGN cst_nota_fiscal.id_pedido_convenio = int_ds_nota_loja.id_pedido_convenio.                */
/*             END.                                                                                                */
/*                                                                                                                 */
/*             IF cst_nota_fiscal.id_pedido_convenio = 0 OR cst_nota_fiscal.id_pedido_convenio = ? THEN DO:        */
/*                 DISP cst_nota_fiscal.cod-estabel         SPACE                                                  */
/*                      cst_nota_fiscal.serie               SPACE                                                  */
/*                      cst_nota_fiscal.nr-nota-fis         SPACE                                                  */
/*                      nota-fiscal.dt-emis                 SPACE                                                  */
/*                      cst_nota_fiscal.id_pedido_convenio  COLUMN-LABEL "ID Pedido CST" SPACE                     */
/*                      int_ds_nota_loja.id_pedido_convenio COLUMN-LABEL "ID Pedido Barramento" WITH WIDTH 555 .   */
/*             END.                                                                                                */
/*                                                                                                                 */
/*         END.                                                                                                    */
/*     END.                                                                                                        */
/* END.                                                                                                            */

RUN pi-finalizar IN h-acomp.                       


/* log-manager:close-log().  */

{include/i-rpclo.i}   

return "OK":U.


PROCEDURE pi-cria-tt-erro:

    DEFINE INPUT PARAMETER p-i-sequen    AS INTEGER   NO-UNDO.
    DEFINE INPUT PARAMETER p-cd-erro     AS INTEGER   NO-UNDO.
    DEFINE INPUT PARAMETER p-mensagem    AS CHARACTER NO-UNDO.
    DEFINE INPUT PARAMETER p-ajuda       AS CHARACTER NO-UNDO.
    
    CREATE tt-erro.
    ASSIGN tt-erro.i-sequen    = p-i-sequen
           tt-erro.cd-erro     = p-cd-erro 
           tt-erro.mensagem    = p-mensagem
           tt-erro.ajuda       = p-ajuda.

    RETURN "OK".

END PROCEDURE.

PROCEDURE pi-mostra-erros:

    FOR EACH tt-erro:
           DISP tt-erro.cd-erro
                tt-erro.mensagem  FORMAT "x(100)"
                WITH WIDTH 333 STREAM-IO DOWN FRAME f-erro.
           DOWN WITH FRAME f-erro.             
    END.   
END.



