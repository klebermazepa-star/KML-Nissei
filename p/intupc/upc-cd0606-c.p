/**************************************************************************************

CHOOSE DO BOTAO CD0606

***********************************************************/

def new global shared var gr-natur-oper-cd0606  as ROWID no-undo.

DEFINE VARIABLE h-escd0606 AS HANDLE      NO-UNDO.

RUN intupc/escd0606.w PERSISTENT SET h-escd0606 (INPUT gr-natur-oper-cd0606).

IF  VALID-HANDLE (h-escd0606) THEN DO:

    RUN initializeInterface IN h-escd0606.
    WAIT-FOR CLOSE OF h-escd0606 FOCUS CURRENT-WINDOW.

END
