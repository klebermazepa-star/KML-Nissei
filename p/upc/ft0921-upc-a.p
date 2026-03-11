define new global shared variable wh-brDoctoMDFE              as handle           no-undo.

DEFINE VARIABLE hBTT AS HANDLE      NO-UNDO.

ASSIGN hBTT = wh-brDoctoMDFE:QUERY:GET-BUFFER-HANDLE(1).

IF hBTT:BUFFER-FIELD("idi-sit-mdfe"):BUFFER-VALUE = 3 
OR hBTT:BUFFER-FIELD("idi-sit-mdfe"):BUFFER-VALUE = 7 THEN
    RUN int/wsinventti0010.p (INPUT "RecepcionarMDFe",
                              INPUT hBTT:BUFFER-FIELD("r-rowid"):BUFFER-VALUE).
