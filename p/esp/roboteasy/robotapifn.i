FUNCTION fnTextToJsonObject RETURNS JsonObject (lc-aux AS LONGCHAR):

    ASSIGN oJsonAux = NEW JsonObject()
           objParse = NEW ObjectModelParser()
           oJsonAux = CAST(objParse:Parse(lc-aux), JsonObject).

    RETURN oJsonAux.

END FUNCTION.

FUNCTION fnTextToJsonArray RETURNS JsonArray (lc-aux AS LONGCHAR):

    ASSIGN oJsonArrayAux = NEW JsonArray()
           objParse      = NEW ObjectModelParser()
           oJsonArrayAux = CAST(objParse:Parse(lc-aux), JsonArray).

    RETURN oJsonArrayAux.

END FUNCTION.

FUNCTION fnGetDecimal RETURNS DEC
  ( JsonAux AS JsonObject,
    campo AS CHAR ) :
    DEFINE VARIABLE cStr AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE base AS DECIMAL     NO-UNDO.
    DEFINE VARIABLE power AS INTEGER     NO-UNDO.

    ASSIGN cStr = JsonAux:GetJsonText(campo).
    IF INDEX(cStr, "e") > 0
    THEN DO: 
        ASSIGN base = DECIMAL(SUBSTRING(cStr, 1, INDEX(cStr, "e") - 1))
               power = INTEGER(SUBSTRING(cStr, INDEX(cStr, "e") + 1 )).

        RETURN base * EXP(10, power). 
    END.
    ELSE RETURN JsonAux:GetDecimal(campo). 

END FUNCTION.
