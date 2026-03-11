/**
*
* INCLUDE:
*   utils/geraRefTamEMS5.p
*
* FINALIDADE:
*   Gera referencia para o EMS 5 com o tamanho especificado.
*
*/
&SCOPED-DEFINE pivot-date DATE(1, 1, 2004)

DEFINE INPUT  PARAMETER iTam AS INTEGER    NO-UNDO.
DEFINE OUTPUT PARAMETER cRef AS CHARACTER  NO-UNDO.

DEFINE VARIABLE iCont   AS INTEGER    NO-UNDO.
DEFINE VARIABLE iTamRef AS INTEGER    NO-UNDO.
DEFINE VARIABLE iRandom AS INTEGER    NO-UNDO.
DEFINE VARIABLE iHandle AS INTEGER    NO-UNDO.

ASSIGN iHandle = INTEGER(THIS-PROCEDURE:HANDLE).

ASSIGN cRef    = SUBSTRING(STRING(ETIME), LENGTH(STRING(ETIME))) +
                 CHR(RANDOM(65, 90))
       iTamRef = LENGTH(cRef).

IF iTamRef >= iTam THEN
    ASSIGN cRef = SUBSTRING(cRef, 1, iTam).
ELSE DO:
    /* Completa com caracteres randomicos */
    DO iCont = 1 TO iTam - iTamRef:
        ASSIGN iRandom = (RANDOM(0, iHandle) MOD 26) + 97
               cRef    = cRef + CHR(iRandom).
    END.
END.
