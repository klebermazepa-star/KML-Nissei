//USING Progress.Json.ObjectModel.*.

USING Progress.Json.ObjectModel.JsonArray.
USING Progress.Json.ObjectModel.JsonObject.
USING Progress.Json.ObjectModel.JsonDataType.
USING Progress.Json.ObjectModel.ObjectModelParser.

{utp/ut-api.i}
{utp/ut-api-action.i pi-gera-inventario  POST /~* }
{utp/ut-api-notfound.i}
 {method/dbotterr.i} /*RowErros*/
    
DEF TEMP-TABLE tt-inventario SERIALIZE-NAME "inventario"    
    FIELD centro_estoque    AS CHAR
    FIELD cnpj_filial       AS CHAR
    FIELD data              AS DATE . 
    
DEFINE TEMP-TABLE itens NO-UNDO
    FIELD centro_estoque        AS CHAR
    FIELD produto               AS CHAR
    FIELD lote                  AS CHAR 
    FIELD data_validade         AS DATE
    FIELD quantidade_contagem   AS DECIMAL
    FIELD unidade_medida        AS CHAR.

DEF NEW GLOBAL SHARED VAR c-seg-usuario AS CHAR NO-UNDO.
    
DEFINE VARIABLE c-retorno AS CHARACTER   NO-UNDO.
DEFINE VARIABLE l-erro    AS LOG   NO-UNDO.
                                             
DEFINE DATASET dsInventario FOR tt-inventario, itens
    DATA-RELATION r1 FOR tt-inventario, itens
        RELATION-FIELDS(centro_estoque,centro_estoque) NESTED .

FUNCTION LongCharToJsonObject RETURN JsonObject PRIVATE (INPUT jsonChar AS LONGCHAR):
    
    DEFINE VARIABLE jsonOutput AS JsonObject        NO-UNDO.
    DEFINE VARIABLE objParse   AS ObjectModelParser NO-UNDO.

    ASSIGN jsonOutput = NEW JsonObject()
           objParse   = NEW ObjectModelParser()
           jsonOutput = CAST(objParse:Parse(jsonChar), JsonObject).

    DELETE OBJECT objParse.

    RETURN jsonOutput.

END FUNCTION.

PROCEDURE pi-gera-inventario:

    DEF INPUT  PARAM jsonInput  AS JsonObject NO-UNDO.
    DEF OUTPUT PARAM jsonOutput     AS JsonObject NO-UNDO.

    DEFINE VARIABLE oRequestParser  AS JsonAPIRequestParser NO-UNDO.
    DEFINE VARIABLE lcPayload       AS LONGCHAR             NO-UNDO.
    
    DEFINE VARIABLE qtd-lote        AS DECIMAL     NO-UNDO.
    DEFINE VARIABLE nr-ficha        AS INTEGER     NO-UNDO.
    
    log-manager:write-message("KML - entrou inventario - V2") no-error.
    log-manager:write-message("KML - V2 Sem No-Lock") no-error.
    
    DEFINE VARIABLE oResponse    AS JsonAPIResponse NO-UNDO.

    oRequestParser = NEW JsonAPIRequestParser(jsonInput).
     
    ASSIGN lcPayload = oRequestParser:getPayloadLongChar().

    DEF VAR jsonAux  AS JsonObject NO-UNDO.
    jsonAux = LongCharToJsonObject(lcPayload).
        
    DATASET dsInventario:HANDLE:READ-JSON('JsonObject',jsonAux).
    jsonOutput = NEW JSONObject().
    
    ASSIGN nr-ficha = 1.
    
    FIND LAST inventario
        WHERE inventario.dt-saldo = tt-inventario.data NO-ERROR.
    
    IF AVAIL inventario THEN DO:
    
        ASSIGN nr-ficha = inventario.nr-ficha + 1.
    END.    
    
    log-manager:write-message(" KML - Antes for each inventario") no-error.
    FOR EACH tt-inventario,
        EACH itens
          //  WHERE itens.centro-estoque = tt-inventario.centro-estoque
            : 
        
        ASSIGN l-erro = NO.
           
        log-manager:write-message(" KML - Dentro for each - " + itens.produto + " - " + tt-inventario.cnpj_filial    ) no-error.
                   
        FIND FIRST ITEM NO-LOCK
            WHERE ITEM.it-codigo = trim(itens.produto) NO-ERROR.
        
        IF NOT AVAIL ITEM THEN
        DO:
            
            CREATE RowErrors.
            ASSIGN RowErrors.ErrorNumber = 17001
                   RowErrors.ErrorDescription = STRING("Inventario n∆o realizado, Item n∆o encontrado - Item: " + trim(itens.produto))
                   RowErrors.ErrorHelp = STRING("Inventario n∆o realizado, Item n∆o encontrado - Item: " + trim(itens.produto))
                   RowErrors.ErrorSubType = "ERROR". 
          
            ASSIGN l-erro = YES.
        END.
        
        FIND FIRST ems2mult.estabelec NO-LOCK
            WHERE estabelec.cgc = tt-inventario.cnpj_filial NO-ERROR.
 
        IF NOT AVAIL estabelec THEN
        DO:
            
            CREATE RowErrors.
            ASSIGN RowErrors.ErrorNumber = 17001
                   RowErrors.ErrorDescription = "Inventario n∆o realizado, Estabelecimento n∆o encontrado"
                   RowErrors.ErrorHelp = "Inventario n∆o realizado, Estabelecimento n∆o encontrado"
                   RowErrors.ErrorSubType = "ERROR". 
                   
            IF CAN-FIND(FIRST RowErrors) THEN DO:
               oResponse = NEW JsonAPIResponse(jsonInput).
               oResponse:setHasNext(FALSE).
               oResponse:setStatus(400).
               oResponse:setRowErrors(JsonAPIUtils:convertTempTableToJsonObject(TEMP-TABLE RowErrors:HANDLE):getJsonArray("RowErrors")).
               jsonOutput = oResponse:createJsonResponse().
            END. 
            
           // RETURN "OK".                   
          
            ASSIGN l-erro = YES.
        END. 
        
        FIND FIRST deposito NO-LOCK
            WHERE trim(SUBSTRING(deposito.char-1, 120,10)) = trim(STRING(tt-inventario.centro_estoque)) NO-ERROR.
            
        IF NOT AVAIL deposito THEN
        DO:
            CREATE RowErrors.
            ASSIGN RowErrors.ErrorNumber = 17001
                   RowErrors.ErrorDescription = "Inventario n∆o realizado, Dep¢sito n∆o encontrado"
                   RowErrors.ErrorHelp = "Inventario n∆o realizado, Dep¢sito n∆o encontrado"
                   RowErrors.ErrorSubType = "ERROR". 
                   
            IF CAN-FIND(FIRST RowErrors) THEN DO:
               oResponse = NEW JsonAPIResponse(jsonInput).
               oResponse:setHasNext(FALSE).
               oResponse:setStatus(400).
               oResponse:setRowErrors(JsonAPIUtils:convertTempTableToJsonObject(TEMP-TABLE RowErrors:HANDLE):getJsonArray("RowErrors")).
               jsonOutput = oResponse:createJsonResponse().
            END. 
            
           // RETURN "OK".                   
          
            ASSIGN l-erro = YES.
            
        END.        
            
        
        IF l-erro = NO THEN DO:
        
            FIND FIRST saldo-estoq NO-LOCK
                WHERE saldo-estoq.cod-estabel   = estabelec.cod-estabel
                  AND saldo-estoq.cod-depos     = deposito.cod-depos
                  AND saldo-estoq.it-codigo     = ITEM.it-codigo
                  AND saldo-estoq.cod-localiz   = ""
                  AND saldo-estoq.lote          = trim(itens.lote) NO-ERROR.
            
            log-manager:write-message(" KML - criando inventario - " + STRING(tt-inventario.data) + " - " + string(nr-ficha)   ) no-error.
            
            
            FIND FIRST inventario
                WHERE inventario.it-codigo         = ITEM.it-codigo
                  AND inventario.cod-estabel       = estabelec.cod-estabel
                  AND inventario.cod-depos         = deposito.cod-depos
                  AND inventario.lote              = trim(itens.lote)
                  AND inventario.dt-saldo          = tt-inventario.data NO-ERROR.
                  
            IF NOT AVAIL inventario THEN
            DO:
            
                CREATE inventario.
                ASSIGN inventario.it-codigo         = ITEM.it-codigo
                       inventario.cod-estabel       = estabelec.cod-estabel
                       inventario.cod-depos         = deposito.cod-depos
                       inventario.lote              = trim(itens.lote)
                       inventario.qtidade-atu       = IF AVAIL saldo-estoq THEN saldo-estoq.qtidade-atu  ELSE 0
                       inventario.dt-saldo          = tt-inventario.data
                       inventario.dt-ult-entra      = itens.data_validade
                       inventario.dt-ult-saida      = ?
                       inventario.situacao          = 4    
                       inventario.val-apurado[1]    = itens.quantidade_contagem
                       inventario.nr-ficha          = nr-ficha
                       inventario.cod-confte-contag-1 = "RPW"
                       inventario.dt-atualiza       = ?
                       inventario.ind-sit-invent-wms    = 1.            
                
            END.
            
            ASSIGN inventario.it-codigo         = ITEM.it-codigo
                   inventario.cod-estabel       = estabelec.cod-estabel
                   inventario.cod-depos         = deposito.cod-depos
                   inventario.lote              = trim(itens.lote)
                   inventario.qtidade-atu       = IF AVAIL saldo-estoq THEN saldo-estoq.qtidade-atu  ELSE 0
                   inventario.dt-saldo          = tt-inventario.data
                   inventario.dt-ult-entra      = itens.data_validade
                   inventario.dt-ult-saida      = ?
                   inventario.situacao          = 4    
                   inventario.val-apurado[1]    = itens.quantidade_contagem
                   inventario.nr-ficha          = nr-ficha
                   inventario.cod-confte-contag-1 = "RPW"
                   inventario.dt-atualiza       = ?
                   inventario.ind-sit-invent-wms    = 1.                        
            
            
                
                
                
 
                   
             ASSIGN nr-ficha = nr-ficha + 1.
             ASSIGN qtd-lote = 0.                 
            
        END.
    
        IF l-erro = YES THEN DO:
        
            IF CAN-FIND(FIRST RowErrors) THEN DO:
               oResponse = NEW JsonAPIResponse(jsonInput).
               oResponse:setHasNext(FALSE).
               oResponse:setStatus(400).
               oResponse:setRowErrors(JsonAPIUtils:convertTempTableToJsonObject(TEMP-TABLE RowErrors:HANDLE):getJsonArray("RowErrors")).
               jsonOutput = oResponse:createJsonResponse().
            END. 
            
            RETURN "OK".
        END.   
        
    END.  
    
    log-manager:write-message(" KML - Depois for each inventario") no-error.
    
    jsonOutput = NEW JSONObject().
    
    jsonOutput:ADD("Status", "Ficha de invent†rio importada com sucesso").
        
    IF NOT CAN-FIND(FIRST inventario) THEN  DO:
    
        CREATE RowErrors.
        ASSIGN RowErrors.ErrorNumber = 17001
               RowErrors.ErrorDescription = "Erro na execuá∆o da rotina!"
               RowErrors.ErrorHelp = "Erro na execuá∆o da rotina!"
               RowErrors.ErrorSubType = "ERROR". 
                             
        IF CAN-FIND(FIRST RowErrors) THEN DO:
           oResponse = NEW JsonAPIResponse(jsonInput).
           oResponse:setHasNext(FALSE).
           oResponse:setStatus(400).
           oResponse:setRowErrors(JsonAPIUtils:convertTempTableToJsonObject(TEMP-TABLE RowErrors:HANDLE):getJsonArray("RowErrors")).
           jsonOutput = oResponse:createJsonResponse().
        END.       
    
    
    END.

    RETURN "OK".
END PROCEDURE.
