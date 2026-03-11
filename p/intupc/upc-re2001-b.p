/******************************************************************************************
**  Programa: upc-re2001-b.p
**  
**  Data....: Gravar a tabela espec°fica int_ds_docto_wms 
**            Libera documento para conferància no WMS
******************************************************************************************/

DEF NEW GLOBAL SHARED VAR c-cod-table-wms-re2001 AS CHAR     NO-UNDO.
DEF NEW GLOBAL SHARED VAR r-row-table-wms-re2001 AS ROWID    NO-UNDO.
DEFINE NEW GLOBAL SHARED VAR wh-tb-conf-wms-re2001    AS WIDGET-HANDLE no-undo.
DEFINE NEW GLOBAL SHARED VAR wh-btconf-orig-re2001    AS WIDGET-HANDLE no-undo.

DEF VAR l-erro AS LOGICAL NO-UNDO.

RUN utp/ut-msgs.p (INPUT "SHOW",
                   INPUT 27100,
                   INPUT "Confirma envio do Documento para Contagem F°sica no WMS?").
IF RETURN-VALUE = "yes" THEN DO:
   ASSIGN l-erro = NO.
   FIND FIRST doc-fisico WHERE 
              ROWID(doc-fisico) = r-row-table-wms-re2001 NO-LOCK NO-ERROR. 
   IF AVAIL doc-fisico THEN DO:
      FIND FIRST int_ds_docto_xml WHERE
                 int(int_ds_docto_xml.nNF)     = int(doc-fisico.nro-docto) AND
                 int_ds_docto_xml.serie        = doc-fisico.serie-docto    AND
                 int_ds_docto_xml.tipo_nota    = doc-fisico.tipo-nota      AND 
                 int_ds_docto_xml.cod_emitente = doc-fisico.cod-emitente NO-LOCK NO-ERROR.
      IF AVAIL int_ds_docto_xml 
      THEN DO:
         
             IF int_ds_docto_xml.num_pedido = 0 THEN DO:
                RUN utp/ut-msgs.p (INPUT "show",
                                   INPUT 17006,
                                   INPUT "Documento n∆o enviado para Contagem F°sica no WMS." + "~~" + "O documento n∆o tem Pedido de Compra e n∆o pode ser enviado para contagem.").
                ASSIGN l-erro = YES.
             END.
    
             IF int_ds_docto_xml.tipo_nota <> 3  /* NFT */
             THEN DO:
                 IF l-erro = NO THEN DO:
                    bloco:
                    FOR EACH int_ds_it_docto_xml WHERE 
                             int_ds_it_docto_xml.serie        = int_ds_docto_xml.serie        AND
                             int(int_ds_it_docto_xml.nNF)     = int(int_ds_docto_xml.nNF)     AND
                             int_ds_it_docto_xml.cod_emitente = int_ds_docto_xml.cod_emitente AND
                             int_ds_it_docto_xml.tipo_nota    = int_ds_docto_xml.tipo_nota    NO-LOCK:
        
                        FOR FIRST item-fornec WHERE 
                                  item-fornec.cod-emitente = int_ds_it_docto_xml.cod_emitente AND
                                  item-fornec.it-codigo    = int_ds_it_docto_xml.it_codigo    AND
                                  item-fornec.item-do-forn = int_ds_it_docto_xml.item_do_forn NO-LOCK:
                        END.
                        IF NOT AVAIL item-fornec THEN DO:
                           RUN utp/ut-msgs.p (INPUT "show",
                                              INPUT 17006,
                                              INPUT "Documento n∆o enviado para Contagem F°sica no WMS." + "~~" + "Relacionamento Item x Fornecedor (Alternativo) n∆o cadastrado." +
                                                    "                       Fornecedor: " + string(int_ds_it_docto_xml.cod_emitente) + "  Item Nissei: " + int_ds_it_docto_xml.it_codigo + 
                                                    "  Item Fornecedor: " + int_ds_it_docto_xml.item_do_forn).
                            ASSIGN l-erro = YES.
                            LEAVE bloco.
                        END.
                    END.
                 END.
    
             END.

      END.
      
      IF l-erro = NO THEN DO:
         FIND FIRST int_ds_docto_wms WHERE
                    int_ds_docto_wms.doc_numero_n = doc-fisico.nro-docto    AND
                    int_ds_docto_wms.doc_serie_s  = doc-fisico.serie-docto  AND
                    int_ds_docto_wms.doc_origem_n = doc-fisico.cod-emitente NO-ERROR.
        IF NOT AVAIL int_ds_docto_wms THEN DO:
           CREATE int_ds_docto_wms.
           ASSIGN int_ds_docto_wms.doc_numero_n   = doc-fisico.nro-docto
                  int_ds_docto_wms.doc_serie_s    = doc-fisico.serie-docto   
                  int_ds_docto_wms.doc_origem_n   = doc-fisico.cod-emitente
                  /*int_ds_docto_wms.id_sequencial  = NEXT-VALUE(seq-int-ds-docto-wms) /* Preparaá∆o para integraá∆o com Procfit */*/
                  wh-tb-conf-wms-re2001:CHECKED   = YES
                  wh-btconf-orig-re2001:SENSITIVE = NO.

           FIND FIRST param-re WHERE 
                      param-re.usuario = doc-fisico.usuario NO-LOCK NO-ERROR.
           IF AVAIL param-re THEN DO:      
              FIND FIRST int_ds_ext_param_re WHERE 
                         int_ds_ext_param_re.usuario = param-re.usuario NO-LOCK NO-ERROR.
              IF AVAIL int_ds_ext_param_re THEN DO:
                 IF int_ds_ext_param_re.lib_conf_wms = YES THEN 
                    ASSIGN wh-btconf-orig-re2001:SENSITIVE = YES.
              END.
           END.

           FIND FIRST emitente WHERE
                      emitente.cod-emitente = doc-fisico.cod-emitente NO-LOCK NO-ERROR.
           IF AVAIL emitente THEN DO:
              ASSIGN int_ds_docto_wms.cnpj_cpf        = emitente.cgc 
                     int_ds_docto_wms.tipo_fornecedor = IF emitente.natureza = 1 THEN "F" ELSE "J"
                     int_ds_docto_wms.situacao        = 1. /* Em Conferància */
           END.
        END.
        ELSE DO:
           MESSAGE "Documento j† enviado para Contagem F°sica no WMS."
               VIEW-AS ALERT-BOX INFO BUTTONS OK.
        END.
      END.
   END.
END.
