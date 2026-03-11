/**
*
* INCLUDE:
*   utils/geraReferenciaEMS5.p
*
* FINALIDADE:
*   Gera referencia para o EMS 5.
*
*/
&SCOPED-DEFINE pivot-date DATE(1, 1, 2004)

DEFINE OUTPUT PARAMETER cRef AS CHARACTER  NO-UNDO.

DEFINE VARIABLE iCont   AS INTEGER    NO-UNDO.
DEFINE VARIABLE iTamRef AS INTEGER    NO-UNDO.
DEFINE VARIABLE iRandom AS INTEGER    NO-UNDO.
DEFINE VARIABLE iHandle AS INTEGER    NO-UNDO.

ASSIGN iHandle = INTEGER(THIS-PROCEDURE:HANDLE).

ASSIGN cRef    = STRING(ABS(TODAY - {&pivot-date})) +
                 SUBSTRING(STRING(ETIME), LENGTH(STRING(ETIME))) +
                 CHR(RANDOM(65, 90))
       iTamRef = LENGTH(cRef).

/* Completa ate o 9o caractere com caracteres randomicos */
DO iCont = 1 TO 10 - iTamRef:
    ASSIGN iRandom = (RANDOM(0, iHandle) MOD 26) + 97
           cRef    = cRef + CHR(iRandom).
END.
