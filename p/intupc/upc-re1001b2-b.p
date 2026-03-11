DEFINE NEW GLOBAL SHARED VAR wh-btSave-re1001b2         AS WIDGET-HANDLE no-undo.
DEFINE NEW GLOBAL SHARED VAR wh-btSave-re1001b2-new     AS WIDGET-HANDLE no-undo.
DEFINE NEW GLOBAL SHARED VAR r-row-item-re1001b       AS ROWID NO-UNDO.
DEFINE NEW GLOBAL SHARED VAR wh-cod-emitente-re1001   AS WIDGET-HANDLE no-undo.
DEFINE NEW GLOBAL SHARED VAR wh-serie-re1001          AS WIDGET-HANDLE no-undo.
DEFINE NEW GLOBAL SHARED VAR wh-nro-docto-re1001      AS WIDGET-HANDLE no-undo.
DEFINE NEW GLOBAL SHARED VAR wh-nat-oper-re1001       AS WIDGET-HANDLE no-undo.


FOR FIRST docum-est FIELDS (serie-docto nro-docto cod-emitente tipo-nota)
    NO-LOCK WHERE 
    docum-est.cod-emitente = int(wh-cod-emitente-re1001:SCREEN-VALUE) AND
    docum-est.serie-docto  = wh-serie-re1001:SCREEN-VALUE AND
    docum-est.nro-docto    = wh-nro-docto-re1001:SCREEN-VALUE AND
    docum-est.nat-operacao = wh-nat-oper-re1001:SCREEN-VALUE:

    if  /* Notas de Servi‡os */
        docum-est.nat-operacao <> "1933A3" AND
        docum-est.nat-operacao <> "2933A3" AND
        /* Notas de venda */ 
        docum-est.nat-operacao <> "1556A3" AND
        docum-est.nat-operacao <> "2556A3" AND
        /* Notas Manipula‡Æo */
        docum-est.nat-operacao <> "1102M1" AND
        docum-est.nat-operacao <> "2102M1" AND
        /* Energia El‚trica */
        docum-est.nat-operacao <> "1253A3" AND
        docum-est.nat-operacao <> "2253A3" then 
    FOR FIRST int_ds_docto_xml WHERE
        int_ds_docto_xml.serie        = docum-est.serie-docto    AND
        int(int_ds_docto_xml.nNF)     = int(docum-est.nro-docto) AND
        int_ds_docto_xml.cod_emitente = docum-est.cod-emitente   AND 
        int_ds_docto_xml.tipo_nota    = docum-est.tipo-nota      NO-LOCK:
        IF (docum-est.cod-estabel = "973" AND
            int_ds_docto_xml.situacao > 1 AND
            int_ds_docto_xml.situacao <> 9) OR
            docum-est.cod-estabel <> "973" THEN DO:
            MESSAGE "Documento oriundo de XML. Altera‡Æo nÆo Permitida!"
                VIEW-AS ALERT-BOX ERROR.
            RETURN "OK".
        END.
    END.
END.

IF VALID-HANDLE(wh-btSave-re1001b2) AND wh-btSave-re1001b2:SENSITIVE THEN
    APPLY "choose":U TO wh-btSave-re1001b2.

RETURN "OK".
