/***************************************************************************************
**   Programa: trg-w-int_ds_docto_wms.p - 
***************************************************************************************/
TRIGGER PROCEDURE FOR CREATE OF int_ds_docto_wms.
ASSIGN int_ds_docto_wms.id_sequencial = NEXT-VALUE(seq-int-ds-docto-wms).
RETURN "OK".
