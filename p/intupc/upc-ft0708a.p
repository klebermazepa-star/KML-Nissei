/********************************************************************************
** Copyright DATASUL S.A. (1997)
** Todos os Direitos Reservados.
**
** Este fonte e de propriedade exclusiva da DATASUL, sua reproducao
** parcial ou total por qualquer meio, so podera ser feita mediante
** autorizacao expressa.
*******************************************************************************/
{include/i-prgvrs.i UPC-FT0708A 2.12.00.001 } /*** 010001 ***/
/****************************************************************************
** Programa: upc-ft0708a.p
*****************************************************************************/

{include/i-epc200.i1} /* Definicao da temp-table tt-epc */

def input param p-ind-event as char no-undo.
def input-output param table for tt-epc.

DEFINE VARIABLE de-valor-contab AS DECIMAL                 NO-UNDO.
DEFINE VARIABLE h-cd9500        AS HANDLE                  NO-UNDO.
DEFINE VARIABLE h-ft0708a       AS HANDLE                  NO-UNDO.
DEFINE VARIABLE r-conta-ft      AS ROWID                   NO-UNDO.
DEFINE VARIABLE v-val-titulo    LIKE fat-duplic.vl-parcela NO-UNDO.

DEFINE VARIABLE r-nota-fiscal AS ROWID       NO-UNDO.
DEFINE VARIABLE i-empresa     AS INTEGER     NO-UNDO.

DEFINE TEMP-TABLE tt-sumar-ft
    FIELD ct-desc-deb    LIKE estabelec.conta-recven
    FIELD ct-desc-cred   LIKE conta-ft.ct-recven
    FIELD val-titulo     LIKE fat-duplic.vl-parcela
    FIELD cod-unid-negoc LIKE it-nota-fisc.cod-unid-negoc.

/**********************************************************************/

IF p-ind-event = "contabiliz-espec" THEN 
DO:
    FOR FIRST tt-epc 
        WHERE tt-epc.cod-event = p-ind-event
        AND   tt-epc.cod-parameter = "h-ft0708a":
        ASSIGN h-ft0708a = WIDGET-HANDLE(tt-epc.val-parameter).
    END.

    FOR FIRST tt-epc 
        WHERE tt-epc.cod-event     = p-ind-event
        AND   tt-epc.cod-parameter = "rowid_nota-fiscal",
        FIRST nota-fiscal NO-LOCK WHERE 
        rowid(nota-fiscal) = to-rowid(tt-epc.val-parameter),
        FIRST emitente NO-LOCK WHERE 
              emitente.cod-emitente = nota-fiscal.cod-emitente:
        
        RUN cdp/cd9500.p PERSISTENT SET h-cd9500.

        FOR FIRST it-nota-fisc OF nota-fiscal NO-LOCK,
            FIRST ITEM FIELDS(it-codigo) NO-LOCK 
            WHERE ITEM.it-codigo = it-nota-fisc.it-codigo:
            RUN pi-cd9500 in h-cd9500 (nota-fiscal.cod-estabel,
                                       emitente.cod-gr-cli,
                                       rowid(item),
                                       it-nota-fisc.nat-oper,
                                       it-nota-fisc.serie,
                                       it-nota-fisc.cod-depos,
                                       nota-fiscal.cod-canal-venda,
                                       output r-conta-ft).
        END.

        FIND FIRST conta-ft NO-LOCK WHERE 
             rowid(conta-ft) = r-conta-ft NO-ERROR.
       
        FOR FIRST conta-ft NO-LOCK WHERE 
            rowid(conta-ft) = r-conta-ft,
            FIRST int_ds_conta_ft NO-LOCK WHERE
                  int_ds_conta_ft.cod_estabel      = conta-ft.cod-estabel       AND 
                  int_ds_conta_ft.cod_gr_cli       = conta-ft.cod-gr-cli        AND
                  int_ds_conta_ft.cod_canal_venda  = conta-ft.cod-canal-venda   AND 
                  int_ds_conta_ft.ge_codigo        = conta-ft.ge-codigo         AND
                  int_ds_conta_ft.fm_codigo        = conta-ft.fm-codigo         AND
                  int_ds_conta_ft.nat_operacao     = conta-ft.nat-operacao      AND
                  int_ds_conta_ft.serie            = conta-ft.serie             AND
                  int_ds_conta_ft.cod_depos        = conta-ft.cod-depos ,                   
            FIRST estabelec NO-LOCK WHERE 
                  estabelec.cod-estabel = nota-fiscal.cod-estabel:

            FIND FIRST tt-sumar-ft
                 WHERE tt-sumar-ft.ct-desc-cred   = int_ds_conta_ft.ct_desc_cartao
                 AND   tt-sumar-ft.ct-desc-deb    = estabelec.conta-recven
                 AND   tt-sumar-ft.cod-unid-negoc = it-nota-fisc.cod-unid-negoc NO-ERROR.
            IF NOT AVAIL tt-sumar-ft THEN
            DO:
                CREATE tt-sumar-ft.
                ASSIGN tt-sumar-ft.ct-desc-cred   = int_ds_conta_ft.ct_desc_cartao     
                       tt-sumar-ft.ct-desc-deb    = estabelec.conta-recven 
                       tt-sumar-ft.cod-unid-negoc = it-nota-fisc.cod-unid-negoc NO-ERROR.
            END.

            /**** Calcular o desconto da nota 
            
                 find first cst-nota-fiscal no-lock where
                            cst-nota-fiscal.nr-nota-fis = nota-fiscal.nr-nota-fis and 
                            cst-nota-fiscal.serie       = nota-fiscal.serie       and
                            cst-nota-fiscal.cod-estabel = nota-fiscal.cod-estabel no-error.
                 if avail cst-nota-fiscal then do:
                 
                 
                 end.             
            
            ****/

            ASSIGN tt-sumar-ft.val-titulo = tt-sumar-ft.val-titulo + 10.


        END. /* FOR EACH it-nota-fisc OF nota-fiscal NO-LOCK, */
        DELETE PROCEDURE h-cd9500.

        IF VALID-HANDLE(h-ft0708a) THEN
        DO:
            FOR EACH tt-sumar-ft:
                RUN pi-gera-lcto IN h-ft0708a (input "conta-ft.ct-recven", 
                                               input tt-sumar-ft.ct-desc-cred, 
                                               input "estabelec.conta-recven",
                                               input tt-sumar-ft.ct-desc-deb,
                                               input tt-sumar-ft.val-titulo,
                                               input 8, /* Desconto */
                                               INPUT 1,   /*** indicador faturamento - COMEX  1 - faturamento, 2 - exporta»’o ***/
                                               INPUT nota-fiscal.dt-emis-nota,
                                               INPUT tt-sumar-ft.cod-unid-negoc).
            END. /* FOR EACH tt-sumar-ft: */
        END. /* IF VALID-HANDLE(h-ft0708a) THEN */
    END. /* FOR FIRST tt-epc  */
END. /* IF p-ind-event = "contabiliz-espec" THEN  */
