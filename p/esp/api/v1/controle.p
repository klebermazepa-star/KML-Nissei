USING Progress.Json.ObjectModel.JsonArray.
USING Progress.Json.ObjectModel.JsonObject.
USING Progress.Json.ObjectModel.ObjectModelParser.

{utp/ut-api.i}
{utp/ut-api-action.i pi-consulta-item  POST  /consultaItem/~* }
{utp/ut-api-notfound.i}

{method/dbotterr.i} /*RowErrors*/  

FUNCTION LongCharToJsonObject RETURN JsonObject PRIVATE (INPUT jsonChar AS LONGCHAR):
    DEFINE VARIABLE jsonOutput AS JsonObject        NO-UNDO.
    DEFINE VARIABLE objParse   AS ObjectModelParser NO-UNDO.

    ASSIGN jsonOutput = NEW JsonObject()
           objParse   = NEW ObjectModelParser()
           jsonOutput = CAST(objParse:Parse(jsonChar), JsonObject).

    DELETE OBJECT objParse.

    RETURN jsonOutput.
END FUNCTION.

PROCEDURE pi-consulta-item:
    DEF INPUT PARAM jsonInput AS JsonObject NO-UNDO.
    DEF OUTPUT PARAM jsonOutput AS JsonObject NO-UNDO.
    DEFINE VARIABLE oRequestParser AS JsonAPIRequestParser NO-UNDO.
    DEFINE VARIABLE lcPayload      AS LONGCHAR             NO-UNDO.
    DEFINE VARIABLE jsonAux        AS JsonObject           NO-UNDO.
    DEFINE VARIABLE itemsArray     AS JsonArray            NO-UNDO.
    DEFINE VARIABLE item           AS JsonObject           NO-UNDO.
    DEFINE VARIABLE i              AS INTEGER              NO-UNDO.

    oRequestParser = NEW JsonAPIRequestParser(jsonInput).
    ASSIGN lcPayload = oRequestParser:getPayloadLongChar().

    jsonAux = LongCharToJsonObject(lcPayload).
    
    jsonOutput = NEW JsonObject().  

   IF jsonAux:HAS("items") THEN DO:
      itemsArray = jsonAux:GetJsonArray("items").
      IF itemsArray:length > 0 THEN DO:
        DO i = 1 TO itemsArray:length:
         item = CAST(itemsArray:GetJsonObject(i), JsonObject).

          FOR EACH ITEM WHERE ITEM.it-codigo = item:GetCharacter("it-codigo") EXCLUSIVE-LOCK:
              ASSIGN ITEM.tipo-contr = INTEGER(item:GetCharacter("tipo-contr")).
          END.
          
        END.
        
        jsonOutput:ADD("status", "success").
        jsonOutput:ADD("message", "Tipo Controle Dos Itens Foram Alterados!"). 
        
      END. 
      
      ELSE DO:
        /* Mensagem se o array de itens estiver vazio */
        jsonOutput:ADD("status", "warning").
        jsonOutput:ADD("message", "O array de itens est† vazio. Nenhuma atualizaá∆o foi realizada.").
      END.
      
   END.
   
   ELSE DO: 
    jsonOutput:ADD("status", "error").
    jsonOutput:ADD("message", "Item n∆o encontrado").
   END.
    
END PROCEDURE.
