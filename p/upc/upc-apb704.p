/*****************************************************************************
* Autor: Eduardo Barth
* Data : outubro/2022
*
* UPC dos programas: add_item_lote_impl_ap
*                    mod_item_lote_impl_ap_base
*                    mod_tit_ap_alteracao_base
*
* Registra informacoes de pagamentos de tributos sem codigo de barras.
* Tais informacoes sao enviadas via EDI para o pagamento Bradesco. 
******************************************************************************/

/* *** DEFINICAO DE PARAMETROS *** */
DEFINE INPUT PARAMETER p-ind-event  AS CHARACTER.
DEFINE INPUT PARAMETER p-ind-object AS CHARACTER.
DEFINE INPUT PARAMETER p-wgh-object AS HANDLE.
DEFINE INPUT PARAMETER p-wgh-frame  AS WIDGET-HANDLE.
DEFINE INPUT PARAMETER p-cod-table  AS CHARACTER.
DEFINE INPUT PARAMETER p-rec-table  AS RECID.

IF p-ind-event = "VALIDATE" THEN 
DO:
    IF p-cod-table = "tit_ap" THEN DO:
        FIND tit_ap WHERE RECID(tit_ap) = p-rec-table
            NO-LOCK NO-ERROR.
        IF NOT AVAIL tit_ap THEN RETURN "".

        FIND cst_espec_tributo OF tit_ap
            NO-LOCK NO-ERROR.
    END.
    ELSE DO:
        FIND item_lote_impl_ap WHERE RECID(item_lote_impl_ap) = p-rec-table
            NO-LOCK NO-ERROR.
        IF NOT AVAIL item_lote_impl_ap THEN RETURN "".

        FIND cst_espec_tributo OF item_lote_impl_ap
            NO-LOCK NO-ERROR.
    END.

    IF NOT AVAIL cst_espec_tributo THEN RETURN "OK".
    IF cst_espec_tributo.tip_tributo = "" THEN RETURN "OK".
    IF cst_espec_tributo.tip_tributo = "IPTU" THEN RETURN "OK".

    RUN upc\upc-apb704-tela.p (INPUT p-cod-table,
                               INPUT p-rec-table).
    IF  RETURN-VALUE = "NOK" THEN
        RETURN "NOK".
END.

RETURN 'OK'.
