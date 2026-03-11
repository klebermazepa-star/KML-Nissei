USING Progress.Json.ObjectModel.*.

{utp/ut-api.i}
{utp/ut-api-action.i pi-teste            GET   /~* }
{utp/ut-api-notfound.i}



PROCEDURE pi-teste:
    DEF INPUT  PARAM jsonInput  AS JsonObject NO-UNDO.
    DEF OUTPUT PARAM jsonOutput AS JsonObject NO-UNDO.
    //DEF INPUT  PARAMETER TABLE FOR tt-mp-titulos-baixa-ok. 

   

    jsonOutput = NEW JSONObject().
    jsonOutput:ADD("message","Importa‡Æo OK!").

    RETURN "OK".
END PROCEDURE.
