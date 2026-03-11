DEFINE VARIABLE h-acomp AS HANDLE NO-UNDO.
RUN utp/ut-acomp.p PERSISTENT SET h-acomp.
RUN pi-inicializar IN h-acomp (INPUT 'contando {1}') .

DEF VAR cont AS INT NO-UNDO INIT 0 .

FOR EACH {1} FIELDS() NO-LOCK {2}:
    IF cont MOD 1000 = 0 THEN DO:
        RUN pi-acompanhar IN h-acomp (INPUT cont ) .
    END.
    ASSIGN cont = cont + 1 .
END.

MESSAGE cont VIEW-AS ALERT-BOX .

RUN pi-finalizar IN h-acomp.
