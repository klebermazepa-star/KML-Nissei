TRIGGER PROCEDURE FOR WRITE OF int_ds_it_docto_xml OLD BUFFER b-int_ds_it_docto_xml.

{utp/ut-glob.i}

// Verifica se o novo registro existe e atende aos crit‚rios espec¡ficos
IF NEW int_ds_it_docto_xml AND
   int_ds_it_docto_xml.nnf <> "0001799" AND
   int_ds_it_docto_xml.serie <> "1" AND
   int_ds_it_docto_xml.cod_emitente <> 7098
THEN DO:
    CREATE int_ds_it_docto_xml_orig.
    BUFFER-COPY int_ds_it_docto_xml TO int_ds_it_docto_xml_orig.
END.

// Verifica se o novo registro existe para a segunda parte da l¢gica
IF NEW int_ds_it_docto_xml THEN DO:
   .MESSAGE "entrou trigger v2"
       VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
    
    CREATE esp-alteracao-bi.
    ASSIGN esp-alteracao-bi.tabela = "int_ds_it_docto_xml"
           esp-alteracao-bi.dt-alteracao = TODAY
           esp-alteracao-bi.cod_emitente = b-int_ds_it_docto_xml.cod_emitente
           esp-alteracao-bi.serie = b-int_ds_it_docto_xml.serie
           esp-alteracao-bi.nr-nota-fis = b-int_ds_it_docto_xml.nnf
           esp-alteracao-bi.tipo_nota = b-int_ds_it_docto_xml.tipo_nota
           esp-alteracao-bi.sequencia = b-int_ds_it_docto_xml.sequencia.
           
           
END.

RETURN "OK".
