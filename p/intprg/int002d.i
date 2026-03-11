DEF TEMP-TABLE tt-docum-est-xml NO-UNDO LIKE int-ds-docto-xml 
FIELD nome-emit    LIKE emitente.nome-emit
FIELD r-rowid      AS ROWID
FIELD marca        AS CHAR FORMAT "x(01)".

DEF TEMP-TABLE tt-item-doc-est-xml NO-UNDO LIKE int-ds-it-docto-xml
FIELD desc-item LIKE ITEM.desc-item
FIELD r-rowid   AS ROWID.

