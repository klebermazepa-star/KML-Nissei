TRIGGER PROCEDURE FOR WRITE OF int_ds_it_docto_xml OLD BUFFER b-int_ds_it_docto_xml.

{utp/ut-glob.i}

IF  NEW int_ds_it_docto_xml AND
    int_ds_it_docto_xml.nnf <> "0001799" AND
    int_ds_it_docto_xml.serie <> "1" AND
    int_ds_it_docto_xml.cod_emitente <> 7098
THEN DO:
    CREATE int_ds_it_docto_xml_orig.
    BUFFER-COPY int_ds_it_docto_xml TO int_ds_it_docto_xml_orig.
END.

RETURN "OK".
