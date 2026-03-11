DEF TEMP-TABLE tt-int_ds_doc NO-UNDO LIKE int_ds_doc 
FIELD nome-emit    LIKE emitente.nome-emit
FIELD r-rowid      AS ROWID
FIELD marca        AS CHAR FORMAT "x(01)".

DEF TEMP-TABLE tt-int_ds_it_doc NO-UNDO LIKE int_ds_it_doc
    field desc-item like ITEM.desc-item
    field qt-do-forn like it-doc-fisico.qt-do-forn
    FIELD r-rowid   AS ROWID.

