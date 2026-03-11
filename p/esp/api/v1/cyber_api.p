/*mybot api ver.10 desenvolvido por Mike/Eduardo/Luan*/

USING Progress.Json.ObjectModel.JsonArray.
USING Progress.Json.ObjectModel.JsonObject.
USING Progress.Json.ObjectModel.JsonDataType.
USING Progress.Json.ObjectModel.ObjectModelParser.

{utp/ut-api.i}
{utp/ut-api-action.i pi-consulta     POST /cyber_p/~* }
{utp/ut-api-action.i pi-consulta_pdv POST /valida_serie/~* }

{utp/ut-api-notfound.i}

{method/dbotterr.i} /*RowErrors*/

DEF TEMP-TABLE tt-pedido NO-UNDO
    FIELD pedido     AS INTEGER
    FIELD dt_geracao AS CHAR
    FIELD estab      AS CHAR
    FIELD obs        AS char format "X(300)"
    .

DEF TEMP-TABLE tt-pdv NO-UNDO
    FIELD estab      AS CHAR
    FIELD serie      AS CHAR.
    
FUNCTION LongCharToJsonObject RETURN JsonObject PRIVATE (INPUT jsonChar AS LONGCHAR):
    DEFINE VARIABLE jsonOutput AS JsonObject        NO-UNDO.
    DEFINE VARIABLE objParse   AS ObjectModelParser NO-UNDO.

    ASSIGN jsonOutput = NEW JsonObject()
           objParse   = NEW ObjectModelParser()
           jsonOutput = CAST(objParse:Parse(jsonChar), JsonObject).

    DELETE OBJECT objParse.

    RETURN jsonOutput.
END FUNCTION.

PROCEDURE pi-consulta:
    DEF INPUT PARAM jsonInput AS JsonObject NO-UNDO.
    DEF OUTPUT PARAM jsonOutput AS JsonObject NO-UNDO.
    DEFINE VARIABLE oRequestParser AS JsonAPIRequestParser NO-UNDO.
    DEFINE VARIABLE lcPayload      AS LONGCHAR             NO-UNDO.
    DEFINE VARIABLE situacao_nf    AS CHAR NO-UNDO.
    
    oRequestParser = NEW JsonAPIRequestParser(jsonInput).

    ASSIGN lcPayload = oRequestParser:getPayloadLongChar().
    
    DEFINE VARIABLE jsonAux   AS JsonObject NO-UNDO.
    jsonAux = LongCharToJsonObject(lcPayload).
                                            
    TEMP-TABLE tt-pedido:HANDLE:READ-JSON('JsonArray', jsonAux:GetJsonArray("ped")).

    jsonOutput = NEW JsonObject().

    FOR EACH tt-pedido:        
           
      FOR EACH int_ds_pedido EXCLUSIVE-LOCK WHERE int_ds_pedido.ped_codigo_n = tt-pedido.pedido.  
        
        IF int_ds_pedido.situacao = 2 THEN DO:           
                                     
                FOR EACH nota-fiscal NO-LOCK WHERE
                    nota-fiscal.cod-estabel = tt-pedido.estab  AND
                    nota-fiscal.nr-pedcli   = STRING(tt-pedido.pedido) AND
                    nota-fiscal.serie = "1" :
                     
                    ASSIGN situacao_nf = SUBSTRING(STRING(nota-fiscal.idi-sit-nf-eletro), 1, 1).
                       
                    jsonOutput:ADD("NF", nota-fiscal.nr-nota-fis).
                    jsonOutput:ADD("Emissao", nota-fiscal.dt-emis-nota).
                    jsonOutput:ADD("Natureza", nota-fiscal.nat-operacao).
                    jsonOutput:ADD("OBS", nota-fiscal.observ-nota).
                    jsonOutput:ADD("CHAVE", nota-fiscal.cod-chave-aces-nf-eletro).
                    jsonOutput:ADD("Situacao", situacao_nf).
                    jsonOutput:ADD("Valor_Nota", vl-tot-nota).
                    jsonOutput:ADD("status", "1").

               END.  
                               
       
            IF NOT AVAIL nota-fiscal THEN DO:
               ASSIGN int_ds_pedido.situacao = 1.
    
               jsonOutput:ADD("Erro", "Sem retorno de Nota na Nota-Fiscal").
               jsonOutput:ADD("status", "0").

            END.
         END.  
         
         ELSE DO:
         
           FOR EACH nota-fiscal NO-LOCK WHERE
                    nota-fiscal.cod-estabel = tt-pedido.estab AND
                    nota-fiscal.nr-pedcli   = STRING(tt-pedido.pedido) AND
                    nota-fiscal.idi-sit-nf-eletro = 3 AND
                    nota-fiscal.serie = "1":
                    
                    ASSIGN situacao_nf = SUBSTRING(STRING(nota-fiscal.idi-sit-nf-eletro), 1, 1).
                    ASSIGN int_ds_pedido.situacao = 2. 
                    
                    jsonOutput:ADD("NF", nota-fiscal.nr-nota-fis).
                    jsonOutput:ADD("Emissao", nota-fiscal.dt-emis-nota).
                    jsonOutput:ADD("Natureza", nota-fiscal.nat-operacao).
                    jsonOutput:ADD("OBS", nota-fiscal.observ-nota).
                    jsonOutput:ADD("CHAVE", nota-fiscal.cod-chave-aces-nf-eletro).
                    jsonOutput:ADD("Situacao", situacao_nf).
                    jsonOutput:ADD("Valor_Nota", vl-tot-nota).
                    jsonOutput:ADD("status", "1").
    
           END.
           
           IF NOT AVAIL nota-fiscal THEN           
           DO:
           
           jsonOutput:ADD("Erro", "Pedido nao encontrado ou nao faturado").
           jsonOutput:ADD("status", "0").
           
           END.
 		   
         END.
      END.
      
      IF NOT AVAIL int_ds_pedido THEN
      DO:
         jsonOutput:ADD("Erro", "Pedido: " + string(tt-pedido.pedido) + " nao encontrado na int_ds_pedido").
         jsonOutput:ADD("status", "0").
      END. 
   END.
   
END PROCEDURE.

PROCEDURE pi-consulta_pdv:
    DEF INPUT PARAM jsonInput      AS JsonObject NO-UNDO.
    DEF OUTPUT PARAM jsonOutput    AS JsonObject NO-UNDO.
    DEFINE VARIABLE oRequestParser AS JsonAPIRequestParser NO-UNDO.
    DEFINE VARIABLE lcPayload      AS LONGCHAR             NO-UNDO.
    DEFINE VARIABLE situacao_nf    AS CHAR NO-UNDO.
    DEFINE BUFFER b-nota-fiscal    FOR nota-fiscal.
    
    oRequestParser = NEW JsonAPIRequestParser(jsonInput).

    ASSIGN lcPayload = oRequestParser:getPayloadLongChar().
    
    DEFINE VARIABLE jsonAux   AS JsonObject NO-UNDO.
    jsonAux = LongCharToJsonObject(lcPayload).
                                            
    TEMP-TABLE tt-pdv:HANDLE:READ-JSON('JsonArray', jsonAux:GetJsonArray("pdv")).

    jsonOutput = NEW JsonObject().

    FOR EACH tt-pdv:
    
      for first b-nota-fiscal no-lock where
        b-nota-fiscal.cod-estabel = tt-pdv.estab  and
        b-nota-fiscal.serie       = tt-pdv.serie  and 
        b-nota-fiscal.nr-nota-fis > "0000001":
      end.
      
    if avail b-nota-fiscal then do:
    
           jsonOutput:ADD("Erro", "J† existe cupom emitido para a filial " + tt-pdv.estab + "com a serie informada!").
           jsonOutput:ADD("status", "0").
           
    END.
    
    ELSE DO: 
    
     for first ser-estab no-lock where
        ser-estab.serie       = tt-pdv.serie and
        ser-estab.cod-estabel = tt-pdv.estab. END.
        
        if not avail ser-estab then do:
        
          jsonOutput:ADD("Erro", "Serie " + tt-pdv.serie + "n∆o cadastrada no datasul para filial " + tt-pdv.estab).
          jsonOutput:ADD("status", "0").
          
        END.
        
        ELSE DO:
        
          jsonOutput:ADD("Success", "Serie " + tt-pdv.serie + "liberada para a filial " + tt-pdv.estab).
          jsonOutput:ADD("status", "1").
          
        END.
        
    END.
    
   END.
     
END.  

    
    
    
    
    
    
    
    
    
    
    
    
