//USING Progress.Json.ObjectModel.*.

USING Progress.Json.ObjectModel.JsonArray.
USING Progress.Json.ObjectModel.JsonObject.
USING Progress.Json.ObjectModel.JsonDataType.
USING Progress.Json.ObjectModel.ObjectModelParser.

{utp/ut-api.i}
{utp/ut-api-action.i pi-gera-furo-caixa  POST  /geraFuroCaixa/~* }
{utp/ut-api-notfound.i}

{method/dbotterr.i} /*RowErrors*/

    
DEF TEMP-TABLE furo-caixa NO-UNDO
    FIELD cnpj-estab        AS CHAR
    FIELD num-bordero       AS CHAR
    FIELD dat-bordero       AS DATE
    FIELD matricula-colab   AS INT
    FIELD valor-furo        AS DEC
    FIELD tipo-furo         AS CHAR
    FIELD origem            AS CHAR
    FIELD nome-colab        AS CHAR.


/* Definição temp-tables/variáveis execução FT2200 */
DEF NEW GLOBAL SHARED VAR c-seg-usuario AS CHAR NO-UNDO.
DEFINE VARIABLE raw-param    AS RAW NO-UNDO.

DEFINE TEMP-TABLE tt-raw-digita NO-UNDO
    FIELD raw-digita      AS RAW.


define temp-table tt-erros no-undo
       field identifi-msg                   as char format "x(60)"
       field cod-erro                       as int  format "99999"
       field desc-erro                      as char format "x(60)"
       field tabela                         as char format "x(20)"
       field l-erro                         as logical initial yes.




FUNCTION LongCharToJsonObject RETURN JsonObject PRIVATE (INPUT jsonChar AS LONGCHAR):
    
    DEFINE VARIABLE jsonOutput AS JsonObject        NO-UNDO.
    DEFINE VARIABLE objParse   AS ObjectModelParser NO-UNDO.

    ASSIGN jsonOutput = NEW JsonObject()
           objParse   = NEW ObjectModelParser()
           jsonOutput = CAST(objParse:Parse(jsonChar), JsonObject).

    DELETE OBJECT objParse.

    RETURN jsonOutput.

END FUNCTION.

PROCEDURE pi-gera-furo-caixa:
    DEF INPUT  PARAM jsonInput  AS JsonObject NO-UNDO.
    DEF OUTPUT PARAM jsonOutput AS JsonObject NO-UNDO.
    //DEF INPUT  PARAMETER TABLE FOR tt-mp-titulos-baixa-ok. 

    DEFINE VARIABLE oRequestParser AS JsonAPIRequestParser NO-UNDO.
    DEFINE VARIABLE lcPayload      AS LONGCHAR             NO-UNDO.
    DEFINE VARIABLE oResponse    AS JsonAPIResponse NO-UNDO.

    oRequestParser = NEW JsonAPIRequestParser(jsonInput).
     
    ASSIGN lcPayload = oRequestParser:getPayloadLongChar().

    DEF VAR jsonAux  AS JsonObject NO-UNDO.
    jsonAux = LongCharToJsonObject(lcPayload).
        
    TEMP-TABLE furo-caixa:HANDLE:READ-JSON('JsonArray',jsonAux:GetJsonArray("Furo-caixa")).
        
     jsonOutput = NEW JSONObject().
     
    FOR EACH furo-caixa:
        
        log-manager:write-message("KML - 2 MATRICULA COLAB" + STRING(furo-caixa.matricula-colab) ) no-error.
    
        IF furo-caixa.matricula-colab = 0 OR furo-caixa.matricula-colab = ?  THEN DO:
            
                    
            CREATE RowErrors.
            ASSIGN RowErrors.ErrorNumber = 17001
                   RowErrors.ErrorDescription = "Furo de Caixa não integrado, devido a Matricula Invalida"
                   RowErrors.ErrorHelp = "Furo de Caixa não integrado, devido a Matricula Invalida"
                   RowErrors.ErrorSubType = "ERROR". 
                                 
            IF CAN-FIND(FIRST RowErrors) THEN DO:
               oResponse = NEW JsonAPIResponse(jsonInput).
               oResponse:setHasNext(FALSE).
               oResponse:setStatus(400).
               oResponse:setRowErrors(JsonAPIUtils:convertTempTableToJsonObject(TEMP-TABLE RowErrors:HANDLE):getJsonArray("RowErrors")).
               jsonOutput = oResponse:createJsonResponse().
            END. 
         END.
                
        log-manager:write-message("KML - 2 salvando api furo de caixa - cnpj - " + furo-caixa.cnpj-estab ) no-error.
                
        
        
        FIND FIRST estabelec no-lock
            WHERE estabelec.cgc = furo-caixa.cnpj-estab NO-ERROR.
            
        IF NOT AVAIL ESTABELEC THEN
            
        FIND FIRST estabelec no-lock
            WHERE estabelec.cod-estabel = furo-caixa.cnpj-estab NO-ERROR.
       
        IF NOT AVAIL estabelec THEN
        DO:
        
            CREATE RowErrors.
            ASSIGN RowErrors.ErrorNumber = 17001
                   RowErrors.ErrorDescription = "Estabelecimento nÆo encontrado"
                   RowErrors.ErrorHelp = "Estabelecimento nÆo encontrado"
                   RowErrors.ErrorSubType = "ERROR". 
                                 
            IF CAN-FIND(FIRST RowErrors) THEN DO:
               oResponse = NEW JsonAPIResponse(jsonInput).
               oResponse:setHasNext(FALSE).
               oResponse:setStatus(400).
               oResponse:setRowErrors(JsonAPIUtils:convertTempTableToJsonObject(TEMP-TABLE RowErrors:HANDLE):getJsonArray("RowErrors")).
               jsonOutput = oResponse:createJsonResponse().
            END. 
            
            
        END.
            
        FIND FIRST int_ds_furo_caixa NO-LOCK
            WHERE int_ds_furo_caixa.cod_estab   = estabelec.cod-estabel
            AND   int_ds_furo_caixa.num_bordero = furo-caixa.num-bordero  NO-ERROR.
            
        IF NOT AVAIL int_ds_furo_caixa THEN
        DO:
            CREATE int_ds_furo_caixa.
            ASSIGN int_ds_furo_caixa.cod_estab      = estabelec.cod-estabel          
                   int_ds_furo_caixa.num_bordero    = furo-caixa.num-bordero         
                   int_ds_furo_caixa.dat_bordero    = furo-caixa.dat-bordero         
                   int_ds_furo_caixa.mat_colabor    = string(furo-caixa.matricula-colab, "999999")     
                   int_ds_furo_caixa.vl_furo        = furo-caixa.valor-furo          
                   int_ds_furo_caixa.tip_furo       = furo-caixa.tipo-furo           
                   int_ds_furo_caixa.des_observ     = ""                             
                   int_ds_furo_caixa.situacao       = 1                              
                   int_ds_furo_caixa.cnpj_estab     = estabelec.cgc                  
                   int_ds_furo_caixa.dat_geracao    = TODAY                          
                   int_ds_furo_caixa.hor_geracao    = string(NOW)                            
                   int_ds_furo_caixa.origem         = furo-caixa.origem              
                   int_ds_furo_caixa.nome_func      = furo-caixa.nome-colab .
               
        RELEASE int_ds_furo_caixa.
                

        
            
        END. 
        
        jsonOutput:ADD("Retorno", "Movimento Furo de caixa armazenado com sucesso").
        jsonOutput:ADD("cnpj-estab", furo-caixa.cnpj-estab).
        jsonOutput:ADD("Num-bordero", furo-caixa.num-bordero).
           
    END.
                  
                  
        
   

    IF NOT CAN-FIND(FIRST furo-caixa) THEN
        jsonOutput:ADD("ERRO","Erro na execu‡Æo da rotina!").

    RETURN "OK".
END PROCEDURE.
