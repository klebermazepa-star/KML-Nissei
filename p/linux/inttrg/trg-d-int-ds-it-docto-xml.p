TRIGGER PROCEDURE FOR DELETE OF int_ds_it_docto_xml.

{utp/ut-glob.i}

IF  AVAIL int_ds_it_docto_xml
THEN DO:
    FOR FIRST int_ds_it_docto_xml_orig EXCLUSIVE-LOCK
        WHERE int_ds_it_docto_xml_orig.cod_emitente = int_ds_it_docto_xml.cod_emitente
          AND int_ds_it_docto_xml_orig.serie        = int_ds_it_docto_xml.serie
          AND int_ds_it_docto_xml_orig.nnf          = int_ds_it_docto_xml.nnf
          AND int_ds_it_docto_xml_orig.tipo_nota    = int_ds_it_docto_xml.tipo_nota
          AND int_ds_it_docto_xml_orig.sequencia    = int_ds_it_docto_xml.sequencia:
        DELETE int_ds_it_docto_xml_orig.
    END.

END.

RETURN "OK".
