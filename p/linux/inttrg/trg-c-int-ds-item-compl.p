/***************************************************************************************
**   Programa: trg-w-int_ds_item_compl.p - 
***************************************************************************************/
TRIGGER PROCEDURE FOR CREATE OF int_ds_item_compl.

ASSIGN int_ds_item_compl.id_sequencial = NEXT-VALUE(seq-int-ds-item-compl).

RETURN "OK".
