/***************************************************************************************
**   Programa: trg-w-int_ds_docto_xml.p - 
***************************************************************************************/
TRIGGER PROCEDURE FOR CREATE OF int_ds_docto_xml.
ASSIGN int_ds_docto_xml.id_sequencial = NEXT-VALUE(seq-int-ds-docto-xml).
RETURN "OK".
