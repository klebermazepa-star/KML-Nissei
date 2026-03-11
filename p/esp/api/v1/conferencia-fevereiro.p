//USING Progress.Json.ObjectModel.*.

USING Progress.Json.ObjectModel.JsonArray.
USING Progress.Json.ObjectModel.JsonObject.
USING Progress.Json.ObjectModel.JsonDataType.
USING Progress.Json.ObjectModel.ObjectModelParser.

{utp/ut-api.i}
{utp/ut-api-action.i pi-gera-conferencia  POST  /geraConferencia/~* }
{utp/ut-api-notfound.i}
 {method/dbotterr.i} /*RowErros*/
    
DEF TEMP-TABLE nota NO-UNDO
    FIELD tipo_nota    AS CHAR
    FIELD nota_fiscal  AS INT64
    FIELD cnpj_origem  AS CHAR
    FIELD cnpj_destino AS CHAR
    FIELD serie        AS CHAR. 
    
DEFINE TEMP-TABLE itens NO-UNDO
    FIELD nota_fiscal           AS INT
    FIELD codigo_interno        AS CHAR 
    FIELD ean                   AS CHAR
    FIELD quantidade_convertida AS DEC
    FIELD lote                  AS CHAR
    FIELD validade              AS DATE.

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
    field nro-docto        as INT64
    field serie-docto      as CHAR.
    
    
define temp-table tt-param-int112 no-undo
    field destino          as integer
    field arquivo          as char format "x(35)"
    field usuario          as char format "x(12)"
    field data-exec        as date
    field hora-exec        as integer
    field classifica       as integer
    field desc-classifica  as char format "x(40)"
    field cnpj_origem      as CHAR
    field nro-docto        as INT64
    field serie-docto      as char. 
    
DEFINE VARIABLE c-retorno AS CHARACTER   NO-UNDO.
DEFINE VARIABLE c-erro    AS LOG   NO-UNDO.


DEFINE DATASET dsConferencia FOR nota, itens
    DATA-RELATION r1 FOR nota, itens
        RELATION-FIELDS(nota_fiscal,nota_fiscal) NESTED .

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
        
    DATASET dsConferencia:HANDLE:READ-JSON('JsonObject',jsonAux).
    jsonOutput = NEW JSONObject().
     
    FOR FIRST nota: 
     
        log-manager:write-message("KML - conferencia - nota.nen_notafiscal - " + string(nota.nota_fiscal)) no-error.
        log-manager:write-message("KML - conferencia - STRING(nota.nen_cnpj_origem_s)) - " + STRING(nota.cnpj_origem)) no-error.
        log-manager:write-message("KML - conferencia - nota.nen_serie_s - " + nota.serie) NO-ERROR.
        
        
        FIND FIRST int_ds_nota_entrada NO-LOCK
             WHERE int_ds_nota_entrada.nen_notafiscal_n  = nota.nota_fiscal          
               AND int_ds_nota_entrada.nen_serie_s       = nota.serie   
               AND int_ds_nota_entrada.nen_cnpj_origem_s = STRING(nota.cnpj_origem) NO-ERROR.
               
        IF AVAIL int_ds_nota_entrada THEN DO:
        
            FIND FIRST emitente NO-LOCK
                 WHERE emitente.cgc = nota.cnpj_origem NO-ERROR.
                 
            IF AVAIL emitente  THEN
            DO:
            
                FIND FIRST docum-est NO-LOCK
                    WHERE docum-est.cod-emitente  = emitente.cod-emitente
                    AND   docum-est.nro-docto     = STRING(int(nota.nota_fiscal), "9999999")
                    AND   docum-est.serie-docto   = nota.serie NO-ERROR.
                    
                IF AVAIL docum-est THEN
                DO:
                
                    CREATE RowErrors.
                    ASSIGN RowErrors.ErrorNumber = 17001
                           RowErrors.ErrorDescription = "Situaá∆o - " + string(int_ds_nota_entrada.situacao) + "- nen_conferida_n - " + STRING(int_ds_nota_entrada.nen_conferida_n)
                           RowErrors.ErrorHelp = "Nota j† encontra-se integrada"
                           RowErrors.ErrorSubType = "ERROR".

                               
                    IF CAN-FIND(FIRST RowErrors) THEN DO:

                        oResponse = NEW JsonAPIResponse(jsonInput).
                        oResponse:setHasNext(FALSE).
                        oResponse:setStatus(400).
                        oResponse:setRowErrors(JsonAPIUtils:convertTempTableToJsonObject(TEMP-TABLE RowErrors:HANDLE):getJsonArray("RowErrors")).
                        jsonOutput = oResponse:createJsonResponse().
                        
                    END.   
                END.
            END.
        END.       
        
        IF nota.tipo_nota = "Transferencia" THEN
        DO:
            
            FIND FIRST estabelec NO-LOCK
                WHERE estabelec.cgc = nota.cnpj_origem NO-ERROR.
         
            FIND FIRST nota-fiscal NO-LOCK
                WHERE nota-fiscal.cod-estabel   = estabelec.cod-estabel
                  AND nota-fiscal.serie         = nota.serie
                  AND nota-fiscal.nr-nota-fis   = STRING(int(nota.nota_fiscal), "9999999") NO-ERROR.
          
            IF AVAIL nota-fiscal THEN DO:
            
                FIND FIRST emitente NO-LOCK
                    WHERE emitente.nome-abrev = nota-fiscal.nome-abrev NO-ERROR.
            
                create tt-param.
                assign tt-param.usuario         = "RPW"
                       tt-param.destino         = 2
                       tt-param.data-exec       = today
                       tt-param.hora-exec       = time
                       tt-param.cod-emitente    = emitente.cod-emitente
                       tt-param.cod-estabel     = nota-fiscal.cod-estabel
                       tt-param.dt-emis-nota    = nota-fiscal.dt-emis-nota
                       tt-param.nro-docto       = INT64(nota-fiscal.nr-nota-fis)
                       tt-param.serie-docto     = nota-fiscal.serie.
                       
                raw-transfer tt-param to raw-param.     
                RUN intprg/int142rp-ecom-fevereiro.p ( INPUT raw-param,
                                           INPUT TABLE tt-raw-digita ,
                                           OUTPUT c-retorno).                   
              
              
                IF c-retorno = "OK" OR c-retorno = ""  THEN   //era c-erro no
                DO:
                    jsonOutput:ADD("Serie"  , nota.serie).
                    jsonOutput:ADD("nen_cnpj_origem_s", nota.cnpj_origem).
                    jsonOutput:ADD("nen_notafiscal_n" ,nota.nota_fiscal).
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
                  

            CREATE RowErrors.
            ASSIGN RowErrors.ErrorNumber = 17001
                   RowErrors.ErrorDescription = "Nota Fiscal origem n∆o encontrada"
                   RowErrors.ErrorHelp = "Nota Fiscal origem n∆o encontrada"
                   RowErrors.ErrorSubType = "ERROR". 
                                 
            IF CAN-FIND(FIRST RowErrors) THEN DO:
               oResponse = NEW JsonAPIResponse(jsonInput).
               oResponse:setHasNext(FALSE).
               oResponse:setStatus(400).
               oResponse:setRowErrors(JsonAPIUtils:convertTempTableToJsonObject(TEMP-TABLE RowErrors:HANDLE):getJsonArray("RowErrors")).
               jsonOutput = oResponse:createJsonResponse().
            END.
            
         /*
         
                CREATE RowErrors.
                    ASSIGN RowErrors.ErrorNumber = 17001
                           RowErrors.ErrorDescription = "Em reprocessamento"
                           RowErrors.ErrorHelp = "Em reprocessamento"
                           RowErrors.ErrorSubType = "ERROR". 
                                         
                    IF CAN-FIND(FIRST RowErrors) THEN DO:
                       oResponse = NEW JsonAPIResponse(jsonInput).
                       oResponse:setHasNext(FALSE).
                       oResponse:setStatus(400).
                       oResponse:setRowErrors(JsonAPIUtils:convertTempTableToJsonObject(TEMP-TABLE RowErrors:HANDLE):getJsonArray("RowErrors")).
                       jsonOutput = oResponse:createJsonResponse().
                    END.   
                */    
                RETURN "OK". 
            
        END.
   
        
        IF nota.tipo_nota = "entrada" THEN DO:
        
            /* KML - Kleber Mazepa - 19/02/2025 - Correá∆o do c¢digo interno do datasul com base no retorno da conferància */
            
            FOR EACH itens:
            
               log-manager:write-message("KML - conf - dentro do for each - " +  nota.cnpj_origem ) NO-ERROR.
               log-manager:write-message("KML - conf - dentro do for each - " +  nota.serie ) NO-ERROR.
               log-manager:write-message("KML - conf - dentro do for each - " +  string(nota.nota_fiscal)) NO-ERROR.
               log-manager:write-message("KML - conf - dentro do for each - " +  itens.ean) NO-ERROR.
           
                FIND FIRST int_ds_nota_entrada_produt EXCLUSIVE-LOCK
                    WHERE int_ds_nota_entrada_produt.nen_cnpj_origem_s  = nota.cnpj_origem 
                      AND int_ds_nota_entrada_produt.nen_serie_s        = nota.serie
                      AND int_ds_nota_entrada_produt.nen_notafiscal_n   = nota.nota_fiscal
                      AND int_ds_nota_entrada_produt.npx_ean_n          = INT64(itens.ean) 
                      AND int_ds_nota_entrada_produt.nep_lote_s         = itens.lote NO-ERROR.
                      
                log-manager:write-message("KML - conf - RESPOSTA 1 - " +  string(int_ds_nota_entrada_produt.nen_notafiscal_n)) NO-ERROR. 
                
                 /*Realizada alteraá∆o para quando a procfit envia CAIXAS*/
                IF AVAIL int_ds_nota_entrada_produt  THEN
                DO: 
                     
                     ASSIGN int_ds_nota_entrada_produt.nep_quantidade_n = itens.quantidade_convertida.
                    
                END.
                 
               
                      
                IF AVAIL int_ds_nota_entrada_produt AND 
                   (int_ds_nota_entrada_produt.nep_produto_n = 0 OR
                    int_ds_nota_entrada_produt.nep_produto_n = ? )THEN
                DO:
                    log-manager:write-message("KML - conf - DENTRO DO DO - " +  string(int_ds_nota_entrada_produt.nen_notafiscal_n)) NO-ERROR. 
               
                    
                    ASSIGN int_ds_nota_entrada_produt.nep_produto_n = int(itens.codigo_interno).
                    
                END.
                IF NOT AVAIL int_ds_nota_entrada_produt THEN
                DO:
                
                    FIND FIRST int_ds_nota_entrada_produt EXCLUSIVE-LOCK
                        WHERE int_ds_nota_entrada_produt.nen_cnpj_origem_s  = nota.cnpj_origem 
                          AND int_ds_nota_entrada_produt.nen_serie_s        = nota.serie
                          AND int_ds_nota_entrada_produt.nen_notafiscal_n   = nota.nota_fiscal
                          AND int_ds_nota_entrada_produt.npx_ean_n          = INT64(itens.ean) NO-ERROR.
                          
                    log-manager:write-message("KML - conf - RESPOSTA 2 - " +  string(int_ds_nota_entrada_produt.nen_notafiscal_n)) NO-ERROR. 
                    
                     /*Realizada alteraá∆o para quando a procfit envia CAIXAS*/
                    IF AVAIL int_ds_nota_entrada_produt  THEN
                    DO: 
                         
                         ASSIGN int_ds_nota_entrada_produt.nep_quantidade_n = itens.quantidade_convertida.
                        
                    END.
                     
                   
                          
                    IF AVAIL int_ds_nota_entrada_produt AND 
                       (int_ds_nota_entrada_produt.nep_produto_n = 0 OR
                        int_ds_nota_entrada_produt.nep_produto_n = ? )THEN
                    DO:
                        log-manager:write-message("KML - conf - RESPOSTA 3- " +  string(int_ds_nota_entrada_produt.nen_notafiscal_n)) NO-ERROR. 
               
                        
                        ASSIGN int_ds_nota_entrada_produt.nep_produto_n = int(itens.codigo_interno).
                        
                    END.
                END.       
            END.
            
           log-manager:write-message("KML - conf - RESPOSTA 4 - " +  string(nota.nota_fiscal)) NO-ERROR. 
           

            create tt-param-int112.
            assign tt-param-int112.usuario         = "RPW"
                   tt-param-int112.destino         = 2
                   tt-param-int112.data-exec       = today
                   tt-param-int112.hora-exec       = time
                   tt-param-int112.cnpj_origem     = nota.cnpj_origem 
                   tt-param-int112.nro-docto       = nota.nota_fiscal
                   tt-param-int112.serie-docto     = nota.serie.
                   
            raw-transfer tt-param-int112 to raw-param.     
            RUN intprg/int112rp-ecom.p ( INPUT raw-param,
                                         INPUT TABLE tt-raw-digita ,
                                         OUTPUT c-retorno).
                                         
            log-manager:write-message("KML - conf - RESPOSTA 5 - " +  string(nota.nota_fiscal) + "RETORNO - " + C-RETORNO) NO-ERROR. 
                                                        
                                         
            IF c-retorno = "OK" THEN
            DO:
                jsonOutput:ADD("Serie"  , nota.serie).
                jsonOutput:ADD("nen_cnpj_origem_s", nota.cnpj_origem).
                jsonOutput:ADD("nen_notafiscal_n" ,nota.nota_fiscal).
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
                     
    END.
    
    

    IF NOT CAN-FIND(FIRST nota) THEN  DO:
    
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
    
    DEFINE VARIABLE cMessageID AS CHARACTER NO-UNDO. 
    DEFINE VARIABLE cRowid AS CHARACTER NO-UNDO.
    
    ASSIGN cRowid = string(ROWID(nota-fiscal)). 
    
    jsonOutput:WriteFile(cMessageID) NO-ERROR.
    log-manager:write-message("KML - conferencia - messageId recebido: " + cMessageID) NO-ERROR.
    
    
/*     FIND FIRST esp_message_id                                                                   */
/*         WHERE  esp_message_id.tabela_referencia = "nota-fiscal"                                 */
/*         AND    esp_message_id.rowid_referencia  = cRowid NO-ERROR.                              */
/*                                                                                                 */
/*     IF NOT AVAIL esp_message_id THEN                                                            */
/*     DO:                                                                                         */
/*                                                                                                 */
/*         log-manager:write-message("KML - conferencia - entrou create esp_message_id") NO-ERROR. */
/*                                                                                                 */
/*         CREATE esp_message_id.                                                                  */
/*         ASSIGN esp_message_id.programa_origem   = "Conferencia"                                 */
/*                esp_message_id.tabela_referencia = "nota-fiscal"                                 */
/*                esp_message_id.rowid_referencia  = cRowid                                        */
/*                esp_message_id.message_id        = cMessageID                                    */
/*                .                                                                                */
/*                                                                                                 */
/*     END.                                                                                        */


    RETURN "OK".
END PROCEDURE.
