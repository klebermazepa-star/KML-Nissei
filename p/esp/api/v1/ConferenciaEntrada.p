//USING Progress.Json.ObjectModel.*.

USING Progress.Json.ObjectModel.JsonArray.
USING Progress.Json.ObjectModel.JsonObject.
USING Progress.Json.ObjectModel.JsonDataType.
USING Progress.Json.ObjectModel.ObjectModelParser.

{utp/ut-api.i}
{utp/ut-api-action.i pi-gera-conferencia  POST  /~* }
{utp/ut-api-notfound.i}
 {method/dbotterr.i} /*RowErros*/
    
DEF Temp-table MessageContent NO-UNDO
    FIELD registro_controle    AS Int
    FIELD cnpj_empresa  AS Char
    FIELD movimento  AS CHAR
    FIELD origem_pedido AS Int. 
    
Define Temp-table notas No-undo
    FIELD registro_controle     AS Int
    Field chave_acesso          As Char
    Field notafiscal            As Char
    Field serie                 As Char
    Field tipo_entidade         As Char
    Field codigo_entidade       As Char
    Field base_origem           As Char
    Field tipo_conferencia      As Char
    Field lote_entrada_rfid     As Char
    Field turno_rfid            As Char.
    
Define Temp-table produtos  No-undo
    FIELD CHAVE_ACESSO          AS Int
    Field produto               As Int
    Field barras                As Char
    Field lote                  As Char
    Field datavalidade          As Date
    Field datafabricacao        As Date
    Field QUANTIDADE_CONVERTIDA As Dec.
    
Define Temp-table divergencias No-undo
    FIELD CHAVE_ACESSO          AS Int
    Field produto               As Int
    Field barras                As Char
    Field QUANTIDADE_CONVERTIDA As Dec
    Field motivo                As Char
    Field centro_estoque        As Char
    Field observacao            As Char.
    
    
DEF DATASET dsconferencia FOR MessageContent, notas, produtos, divergencias
    DATA-RELATION r1 FOR MessageContent, notas
        RELATION-FIELDS(registro_controle,registro_controle) NESTED
    DATA-RELATION r2 FOR notas, produtos
        RELATION-FIELDS(CHAVE_ACESSO,CHAVE_ACESSO) NESTED
    DATA-RELATION r3 FOR notas, divergencias
        RELATION-FIELDS(CHAVE_ACESSO,CHAVE_ACESSO) NESTED        .    

/* Definiá∆o temp-tables/vari†veis execuá∆o FT2200 */
DEF NEW GLOBAL SHARED VAR c-seg-usuario AS CHAR NO-UNDO.
DEFINE VARIABLE raw-param    AS RAW NO-UNDO.

DEFINE TEMP-TABLE tt-raw-digita NO-UNDO
    FIELD raw-digita      AS RAW.

define temp-table tt-param no-undo
    field destino          as integer
    field arquivo          as char format "x(35)"
    field usuario          as char format "x(12)"
    field data-exec        as date
    field hora-exec        as integer
    field classifica       as integer
    field desc-classifica  as char format "x(40)"
    field cod-emitente     as INTEGER
    field cod-estabel      as CHAR
    field dt-emis-nota     as DATE
    field nro-docto        as INTEGER
    field serie-docto      as CHAR.
    
    
define temp-table tt-param-int112 no-undo
    field destino          as integer
    field arquivo          as char format "x(35)"
    field usuario          as char format "x(12)"
    field data-exec        as date
    field hora-exec        as integer
    field classifica       as integer
    field desc-classifica  as char format "x(40)"
    field r-int_ds_nota_entrada as Rowid.
    
DEFINE VARIABLE c-retorno AS CHARACTER   NO-UNDO.


FUNCTION LongCharToJsonObject RETURN JsonObject PRIVATE (INPUT jsonChar AS LONGCHAR):
    
    DEFINE VARIABLE jsonOutput AS JsonObject        NO-UNDO.
    DEFINE VARIABLE objParse   AS ObjectModelParser NO-UNDO.

    ASSIGN jsonOutput = NEW JsonObject()
           objParse   = NEW ObjectModelParser()
           jsonOutput = CAST(objParse:Parse(jsonChar), JsonObject).

    DELETE OBJECT objParse.

    RETURN jsonOutput.

END FUNCTION.

PROCEDURE pi-gera-conferencia:
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
        
    DATASET dsconferencia:HANDLE:READ-JSON('JsonObject',jsonAux).
        
     jsonOutput = NEW JSONObject().
     
     FOR FIRST notas: 
     
        log-manager:write-message("KML - conferencia - notas.nen_notafiscal - " + string(notas.NOTAFISCAL)) no-error.
        log-manager:write-message("KML - conferencia - STRING(notas.nen_cnpj_origem_s)) - " + STRING(notas.CODIGO_ENTIDADE)) no-error.
        log-manager:write-message("KML - conferencia - notas.nen_serie_s - " + notas.serie) NO-ERROR.
        
       
        FIND FIRST ems2mult.emitente NO-LOCK
            WHERE emitente.cod-emitente = INT64(notas.CODIGO_ENTIDADE) NO-ERROR.
            
        IF LENGTH(TRIM(notas.NOTAFISCAL)) < 7 THEN ASSIGN notas.NOTAFISCAL = TRIM(STRING(INTEGER(notas.NOTAFISCAL),">>9999999")).     
     
        CREATE int_ds_docto_wms.
        ASSIGN int_ds_docto_wms.doc_numero_n        = notas.NOTAFISCAL                          
               int_ds_docto_wms.doc_serie_s         = notas.serie                                                   
               int_ds_docto_wms.doc_origem_n        = IF AVAIL emitente THEN emitente.cod-emitente ELSE 0           
               int_ds_docto_wms.cnpj_cpf            = emitente.cgc                                  
               int_ds_docto_wms.tipo_fornecedor     = if emitente.natureza = 1 then "F" else "J"                     
               int_ds_docto_wms.situacao            = 40 /* Inclus∆o */                                              
               int_ds_docto_wms.datamovimentacao_d  = TODAY                                                          
               int_ds_docto_wms.horamovimentacao_s  = string(NOW)                                                            
               int_ds_docto_wms.ID_SEQUENCIAL       = NEXT-VALUE(seq-int-ds-docto-wms)                               
               int_ds_docto_wms.tipo_nota           = 2 /* notas de entrada */
               .
               
        ASSIGN c-retorno = "OK".
      
        IF c-retorno = "OK" THEN DO:
        
            jsonOutput:ADD("Serie"  , notas.serie).
            jsonOutput:ADD("nen_cnpj_origem_s", notas.CODIGO_ENTIDADE).
            jsonOutput:ADD("nen_notafiscal_n" ,notas.NOTAFISCAL).
            jsonOutput:ADD("Retorno", c-retorno).                               
            
        END.
        ELSE DO:

            CREATE RowErrors.
            ASSIGN RowErrors.ErrorNumber = 17001
                   RowErrors.ErrorDescription = c-retorno
                   RowErrors.ErrorHelp = c-retorno
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
         
    END.

    IF NOT CAN-FIND(FIRST notas) THEN  DO:
    
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
    
    jsonOutput:ADD("message", "Erro na conferencia da nota de entrada" ). 

    RETURN "OK".
    
END PROCEDURE.
