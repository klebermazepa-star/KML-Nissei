def new global shared var wh-gbr-table-cn0302       as widget-handle no-undo.
def new global shared var wh-dt-valid-cn0302        as widget-handle no-undo.
def new global shared var wh-num-seq-item-cn0302    as widget-handle no-undo. 
def new global shared var wh-num-seq-event-cn0302   as widget-handle no-undo. 
def new global shared var wh-num-seq-medicao-cn0302 as widget-handle no-undo. 
def new global shared var r-seq-ordem-compra        AS ROWID       NO-UNDO.

DEFINE VARIABLE hTTBuffer AS WIDGET-HANDLE      NO-UNDO.

IF VALID-HANDLE(wh-gbr-table-cn0302) THEN DO:

    FOR FIRST ordem-compra NO-LOCK
        WHERE ROWID(ordem-compra) = r-seq-ordem-compra,
        FIRST es-medicao-contrat NO-LOCK
        WHERE es-medicao-contrat.nr-contrato     = ordem-compra.nr-contrato
        AND   es-medicao-contrat.num-seq-item    = wh-num-seq-item-cn0302   :BUFFER-VALUE
        AND   es-medicao-contrat.numero-ordem    = ordem-compra.numero-ordem
        AND   es-medicao-contrat.num-seq-event   = wh-num-seq-event-cn0302  :BUFFER-VALUE
        AND   es-medicao-contrat.num-seq-medicao = wh-num-seq-medicao-cn0302:BUFFER-VALUE:

        ASSIGN wh-dt-valid-cn0302:SCREEN-VALUE = STRING(es-medicao-contrat.dt-valid,"99/99/9999").
    END.
END.


RETURN "OK".
