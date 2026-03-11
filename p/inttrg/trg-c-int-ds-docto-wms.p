/***************************************************************************************
**   Programa: trg-w-int_ds_docto_wms.p - 
***************************************************************************************/
TRIGGER PROCEDURE FOR CREATE OF int_ds_docto_wms.
IF int_ds_docto_wms.id_sequencial = ? OR int_ds_docto_wms.id_sequencial = 0 THEN DO:

    ASSIGN int_ds_docto_wms.id_sequencial = NEXT-VALUE(seq-int-ds-docto-wms).

END.
    
RETURN "OK".
