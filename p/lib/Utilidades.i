
/*recompila‡Æo*/
FUNCTION tratarString RETURNS CHARACTER
    (INPUT pcString AS CHAR):

    IF pcString <> ? THEN RETURN pcString. ELSE RETURN "".

END FUNCTION.

FUNCTION Stamp RETURNS CHARACTER:

    RETURN STRING(YEAR(TODAY), "9999") + STRING(MONTH(TODAY), "99") + STRING(DAY(TODAY), "99") + REPLACE(STRING(TIME, "HH:MM:SS"), ":", "").

END FUNCTION.

FUNCTION timeStamp RETURNS CHARACTER:

    RETURN SUBSTITUTE("[&1-&2]", STRING(TODAY, "99/99/9999"), STRING(TIME, "HH:MM:SS")).

END FUNCTION.

FUNCTION tratarArquivo RETURNS CHARACTER
    (INPUT cArquivo AS CHAR):

DEFINE VARIABLE cRetorno AS CHARACTER   NO-UNDO.

    ASSIGN cRetorno = REPLACE (REPLACE(cArquivo, "\", "/"), "//", "/").

/*     MESSAGE cRetorno SKIP                  */
/*         cretorno BEGINS "/"                */
/*         VIEW-AS ALERT-BOX INFO BUTTONS OK. */

    IF cRetorno BEGINS "/" THEN
        ASSIGN cRetorno = "/" + cRetorno.

    RETURN cRetorno.

END FUNCTION.


FUNCTION converterHora RETURNS INTEGER
  (INPUT cHora AS CHARACTER) :
/*------------------------------------------------------------------------------
  Purpose:  
    Notes:  
------------------------------------------------------------------------------*/
DEFINE VARIABLE iHora           AS INTEGER     NO-UNDO.
DEFINE VARIABLE iMinuto         AS INTEGER     NO-UNDO.
DEFINE VARIABLE iSegundo        AS INTEGER     NO-UNDO.

DEFINE VARIABLE iSegundos       AS INTEGER     NO-UNDO.


    IF NUM-ENTRIES(cHora, ":") > 1 THEN
    DO:
        
        ASSIGN  iHora       = INTEGER(ENTRY(1, cHOra, ":"))
                iMinuto     = INTEGER(ENTRY(2, cHora, ":"))
                iSegundo    = INTEGER(IF(NUM-ENTRIES(cHora, ":") >= 3 ) THEN INTEGER(ENTRY(3, cHora, ":")) ELSE 0) 
            NO-ERROR.
     
    END.
    ELSE
    DO:

        ASSIGN  iHora       = INTEGER(SUBSTRING(cHora, 1, 2))
                iMinuto     = INTEGER(SUBSTRING(cHora, 3, 2))
                iSegundo    = INTEGER(SUBSTRING(cHora, 5, 2)).

    END.


    IF iHora >  23 THEN
        RETURN ?.

    IF iMinuto > 59 THEN
        RETURN ?.

    IF iSegundo > 59 THEN
        RETURN ?.

    ASSIGN iSegundos    = (iHora * 3600) + (iMinuto * 60) + iSegundo.
    

    RETURN iSegundos.   /* Function return value. */

END FUNCTION.

FUNCTION converterDateTimeParaTime RETURNS INTEGER 
    (INPUT daDatetime AS DATETIME):

    RETURN INTEGER(MTIME(daDateTime) / 1000).


END FUNCTION.


/*             DATETIME(                                                          */
/*                         INTEGER(SUBSTRING(ttColeta.DATA_OCORRENCIA, 6, 2) ) ,  */
/*                         INTEGER(SUBSTRING(ttColeta.DATA_OCORRENCIA, 1, 2) ) ,  */
/*                         INTEGER(SUBSTRING(ttColeta.DATA_OCORRENCIA, 7, 4) ) ,  */
/*                         INTEGER(SUBSTRING(ttColeta.DATA_OCORRENCIA, 12, 2))  , */
/*                         INTEGER(SUBSTRING(ttColeta.DATA_OCORRENCIA, 15, 2))  , */
/*                         INTEGER(SUBSTRING(ttColeta.DATA_OCORRENCIA, 18, 2))    */
/*                      )                                                         */
