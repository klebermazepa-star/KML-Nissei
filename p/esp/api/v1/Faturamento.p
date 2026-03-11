//USING Progress.Json.ObjectModel.*.

USING Progress.Json.ObjectModel.JsonArray.
USING Progress.Json.ObjectModel.JsonObject.
USING Progress.Json.ObjectModel.JsonDataType.
USING Progress.Json.ObjectModel.ObjectModelParser.

{utp/ut-api.i}
{utp/ut-api-action.i pi-gera-faturamento  POST  /geraNotaFaturamento/~* }

{utp/ut-api-notfound.i}
 
{method/dbotterr.i} /*RowErros*/
    
DEF TEMP-TABLE PEDIDO NO-UNDO
    FIELD PEDIDO_ID     AS INT
    FIELD PEDIDO        AS INT
    FIELD TIPO_PEDIDO   AS INT
    FIELD DATA_PEDIDO   AS DATE
    FIELD DATA_ENTREGA  AS DATE
    FIELD CNPJ_LOJA_ORIGEM AS CHAR
    FIELD CNPJ_LOJA_DESTINO AS CHAR
    FIELD QUANTIDADE        AS DEC
    FIELD VALOR_TOTAL       AS DEC
    FIELD CNPJ_TRANSPORTADORA AS CHAR
    FIELD PLACA               AS CHAR
    FIELD ESTADO_PLACA        AS CHAR
    FIELD OBSERVACOES       AS CHAR.

DEF TEMP-TABLE ITENS NO-UNDO
    FIELD PEDIDO_ID     AS INT
    FIELD ITEM        AS INT
    FIELD QUANTIDADE  AS DEC
    FIELD VALOR_LIQUIDO   AS DEC
    FIELD VALOR_BRUTO AS DEC
    FIELD VALOR_TOTAL AS DEC 
    FIELD DESCONTO_PERCENTUAL AS DEC 
    FIELD DESCRICAO_COMPLEMENTAR AS CHAR.
    
DEF TEMP-TABLE LOTE NO-UNDO
    //FIELD PEDIDO_ID     AS INT
    FIELD ITEM          AS INT
    FIELD CAIXA         AS INT
    FIELD LOTE          AS CHAR
    FIELD VALIDADE         AS DATE
    FIELD QUANTIDADE    AS DEC.
    
DEFINE TEMP-TABLE tt-pedido NO-UNDO
    FIELD pedcodigo         AS INT
    FIELD tipo_pedido       AS INT
    FIELD DtEmissao         AS DATE 
    FIELD cnpj_emitente     AS CHAR.
    
DEFINE TEMP-TABLE tt-pedido-item NO-UNDO
    FIELD CODIGO_PRODUTO        AS INT
    FIELD CAIXA                 AS INT
    FIELD LOTE                  AS CHAR
    FIELD VALIDADE_LOTE         AS DATE
    FIELD QUANTIDADE_ESTOQUE    AS DEC
    FIELD QUANTIDADE_SEPARADA   AS DEC
    FIELD QUANTIDADE_INVENTARIO AS DEC.
    
DEFINE TEMP-TABLE TT_INT_DS_PEDIDO LIKE INT_DS_PEDIDO.


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
       
    
DEFINE VARIABLE c-retorno AS CHARACTER   NO-UNDO.

DEF DATASET dsFatura FOR PEDIDO, ITENS, LOTE 
    DATA-RELATION r1 FOR PEDIDO, ITENS
        RELATION-FIELDS(PEDIDO_ID,PEDIDO_ID) NESTED
     DATA-RELATION r2 FOR ITENS, LOTE
        RELATION-FIELDS(ITEM,ITEM) NESTED.
        
function findTag returns longchar
    (pSource as longchar, pTag as char, pStart as int64):

    LOG-MANAGER:WRITE-MESSAGE("findTag _ " + pTag) NO-ERROR.

    def var cTagIni as char no-undo.
    def var cTagFim as char no-undo.

    if length(trim(pSource)) > 0 and length(trim(pTag)) > 0 and pStart >= 1 then do:
        assign  cTagIni = '<'  + trim(pTag) + '>'
                cTagFim = '</' + trim(pTag) + '>'.

        LOG-MANAGER:WRITE-MESSAGE("findTag _ " + STRING(index(pSource,cTagIni,pStart))) NO-ERROR.
        LOG-MANAGER:WRITE-MESSAGE("findTag _ " + STRING(index(pSource,cTagFim,pStart))) NO-ERROR.
        LOG-MANAGER:WRITE-MESSAGE("findTag _ " + STRING(index(pSource,cTagFim,pStart) - ( index(pSource,cTagIni,pStart) + length(cTagIni) ))) NO-ERROR.
        IF index(pSource,cTagIni,pStart) < 0
        OR index(pSource,cTagFim,pStart) < 0 
        OR index(pSource,cTagFim,pStart) - ( index(pSource,cTagIni,pStart) + length(cTagIni) ) < 0 THEN RETURN "".

        return trim(substring(pSource,
                              index(pSource,cTagIni,pStart) + length(cTagIni), 
                              index(pSource,cTagFim,pStart) - ( index(pSource,cTagIni,pStart) + length(cTagIni) ) 
                              ) 
                    ).
    end.
    return "".
end.

function OnlyNumbers returns char
    (p-char as char):

    def var i-ind as integer no-undo.
    def var c-aux as char no-undo.
    do i-ind = 1 to length (p-char):
        if lookup (substring(p-char,i-ind,1),"1,2,3,4,5,6,7,8,9,0") > 0 then
            assign c-aux = c-aux + substring(p-char,i-ind,1).
    end.
    if c-aux <> ? then return c-aux. else return "".
end.

FUNCTION LongCharToJsonObject RETURN JsonObject PRIVATE (INPUT jsonChar AS LONGCHAR):
    
    DEFINE VARIABLE jsonOutput AS JsonObject        NO-UNDO.
    DEFINE VARIABLE objParse   AS ObjectModelParser NO-UNDO.

    ASSIGN jsonOutput = NEW JsonObject()
           objParse   = NEW ObjectModelParser()
           jsonOutput = CAST(objParse:Parse(jsonChar), JsonObject).

    DELETE OBJECT objParse.

    RETURN jsonOutput.

END FUNCTION.

PROCEDURE pi-gera-faturamento:  
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

    MESSAGE string(jsonAux:GetJsonArray("PEDIDO"):getJsonText())
    VIEW-AS ALERT-BOX INFO BUTTONS OK.

    DATASET dsFatura:HANDLE:READ-JSON('JsonObject',jsonAux).


    jsonOutput = NEW JSONObject().

    FIND FIRST PEDIDO NO-LOCK.
    
    IF pedido.tipo_pedido = 53 THEN
    DO:

        FIND FIRST emitente NO-LOCK
        WHERE emitente.cgc = PEDIDO.CNPJ_LOJA_DESTINO NO-ERROR.
            
        IF NOT AVAIL emitente THEN DO:

            CREATE RowErrors.
            ASSIGN RowErrors.ErrorNumber = 17001
                   RowErrors.ErrorDescription = "Emitente n∆o Cadastrado, CNPJ INVALIDO"
                   RowErrors.ErrorHelp = "Emitente n∆o Cadastrado, CNPJ INVALIDO"
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
    
    ELSE DO:

        FIND FIRST estabelec NO-LOCK
        WHERE estabelec.cgc = PEDIDO.CNPJ_LOJA_DESTINO NO-ERROR.
        
        IF NOT AVAIL estabelec THEN
        DO:
        
            CREATE RowErrors.
            ASSIGN RowErrors.ErrorNumber = 17001
                   RowErrors.ErrorDescription = "Estabalecimento n∆o Cadastrado, CNPJ INVALIDO"
                   RowErrors.ErrorHelp = "Estabalecimento n∆o Cadastrado, CNPJ INVALIDO"
                   RowErrors.ErrorSubType = "ERROR".
                
                               
            IF CAN-FIND(FIRST RowErrors) THEN DO:
            
                oResponse = NEW JsonAPIResponse(jsonInput).
                oResponse:setHasNext(FALSE).
                oResponse:setStatus(400).
                oResponse:setRowErrors(JsonAPIUtils:convertTempTableToJsonObject(TEMP-TABLE RowErrors:HANDLE):getJsonArray("RowErrors")).
                jsonOutput = oResponse:createJsonResponse().
            END.
            
            RETURN "NOK".      
        END.   
    END.
      //END.

    FOR EACH ITENS:
        

        log-manager:write-message("KML - Antes Itens " + STRING(ITENS.ITEM)) no-error.

        FIND FIRST ITEM NO-LOCK
            WHERE ITEM.it-codigo = STRING(ITENS.ITEM) NO-ERROR.
        
        IF NOT AVAIL ITEM  THEN
        DO:

            CREATE RowErrors.
            ASSIGN RowErrors.ErrorNumber = 17001
                   RowErrors.ErrorDescription = "Item N∆o Cadastrado, C¢digo do item Invalido!"
                   RowErrors.ErrorHelp = "Item N∆o Cadastrado, C¢digo do item Invalido!"
                   RowErrors.ErrorSubType = "ERROR".
                    
                                   
            IF CAN-FIND(FIRST RowErrors) THEN DO:     

                oResponse = NEW JsonAPIResponse(jsonInput).
                oResponse:setHasNext(FALSE).
                oResponse:setStatus(400).
                oResponse:setRowErrors(JsonAPIUtils:convertTempTableToJsonObject(TEMP-TABLE RowErrors:HANDLE):getJsonArray("RowErrors")).
                jsonOutput = oResponse:createJsonResponse().
            END.                    
               
        //RETURN "OK".
          
        END.
    END.

    //FOR EACH PEDIDO:
    
    find first int_ds_tipo_pedido no-lock
     where int_ds_tipo_pedido.tp_pedido = string(PEDIDO.TIPO_PEDIDO) no-error. 

    IF not AVAIL int_ds_tipo_pedido  THEN
    DO:

        CREATE RowErrors.
        ASSIGN RowErrors.ErrorNumber = 17001
               RowErrors.ErrorDescription = "Tipo de Pedido inexistente no int115"
               RowErrors.ErrorHelp = "Tipo de Pedido inexistente no int115"
               RowErrors.ErrorSubType = "ERROR".       
                           
        IF CAN-FIND(FIRST RowErrors) THEN DO:
        
            oResponse = NEW JsonAPIResponse(jsonInput).
            oResponse:setHasNext(FALSE).
            oResponse:setStatus(400).
            oResponse:setRowErrors(JsonAPIUtils:convertTempTableToJsonObject(TEMP-TABLE RowErrors:HANDLE):getJsonArray("RowErrors")).
            jsonOutput = oResponse:createJsonResponse().
        END.                       

        //RETURN "NOK".
    END.
   
    FIND FIRST int_ds_pedido NO-LOCK
     WHERE int_ds_pedido.ped_codigo_n = PEDIDO.PEDIDO NO-ERROR.
     
    IF AVAIL int_ds_pedido  THEN
    DO:
    
        CREATE RowErrors.
        ASSIGN RowErrors.ErrorNumber = 17001
               RowErrors.ErrorDescription = "Pedido ja existe na base"
               RowErrors.ErrorHelp = "Pedido ja existe na base"
               RowErrors.ErrorSubType = "ERROR".
            
                           
        IF CAN-FIND(FIRST RowErrors) THEN DO:
        
            oResponse = NEW JsonAPIResponse(jsonInput).
            oResponse:setHasNext(FALSE).
            oResponse:setStatus(400).
            oResponse:setRowErrors(JsonAPIUtils:convertTempTableToJsonObject(TEMP-TABLE RowErrors:HANDLE):getJsonArray("RowErrors")).
            jsonOutput = oResponse:createJsonResponse().
        END.                       

    //RETURN "NOK".
    END.
    
    ELSE DO:
    
        CREATE INT_DS_PEDIDO.
        ASSIGN int_ds_pedido.situacao              = 1
               int_ds_pedido.ped_codigo_n          = PEDIDO.PEDIDO    
               int_ds_pedido.dt_geracao            = PEDIDO.DATA_PEDIDO
               int_ds_pedido.ped_data_d            = PEDIDO.DATA_PEDIDO
               int_ds_pedido.ped_dataentrega_d     = PEDIDO.DATA_ENTREGA
               int_ds_pedido.ped_cnpj_origem_s     = PEDIDO.CNPJ_LOJA_ORIGEM
               int_ds_pedido.ped_cnpj_destino_s    = PEDIDO.CNPJ_LOJA_DESTINO
               int_ds_pedido.ped_quantidade_n      = PEDIDO.QUANTIDADE
               int_ds_pedido.ped_valortotalbruto_n = PEDIDO.VALOR_TOTAL
               int_ds_pedido.ped_tipopedido_n      = PEDIDO.TIPO_PEDIDO
               int_ds_pedido.envio_status          = 1.
    END.

    FOR EACH ITENS:

        FIND FIRST PEDIDO NO-ERROR.
      
        CREATE int_ds_pedido_produto.
        ASSIGN int_ds_pedido_produto.ped_codigo_n     = PEDIDO.PEDIDO
               int_ds_pedido_produto.ppr_produto_n    = ITENS.ITEM
               int_ds_pedido_produto.ppr_quantidade_n = ITENS.QUANTIDADE
               int_ds_pedido_produto.ppr_valorbruto_n = ITENS.VALOR_BRUTO
               int_ds_pedido_produto.ppr_percentualdesconto_n = ITENS.DESCONTO_PERCENTUAL
               int_ds_pedido_produto.ppr_valorliquido_n       = ITENS.VALOR_LIQUIDO
               int_ds_pedido_produto.ppr_descricaocompl_s     = ITENS.DESCRICAO_COMPLEMENTAR
               int_ds_pedido_produto.nen_notafiscal_n         = ?
               int_ds_pedido_produto.nen_serie                = ?
               int_ds_pedido_produto.nep_sequencia_n          = 0.
               
     
               
        FOR EACH LOTE
            WHERE lote.ITEM = itens.ITEM:
            
            //FIND FIRST pedido NO-ERROR.

                CREATE int_ds_pedido_retorno.
                ASSIGN int_ds_pedido_retorno.ped_codigo_n         = PEDIDO.PEDIDO
                       int_ds_pedido_retorno.rpp_lote_s           = lote.lote
                       int_ds_pedido_retorno.ppr_produto_n        = ITENS.ITEM
                       int_ds_pedido_retorno.rpp_caixa_n          = LOTE.caixa  
                       int_ds_pedido_retorno.rpp_validade_d       = LOTE.validade 
                       int_ds_pedido_retorno.rpp_quantidade_n     = LOTE.quantidade
                       int_ds_pedido_retorno.rpp_qtd_inventario_n = LOTE.quantidade. 

            
            
           log-manager:write-message("KML - antes API - Antes do IF CAN FIND- " + PEDIDO.CNPJ_LOJA_DESTINO) no-error.
           
        END.         
    END.       
        
     
    jsonOutput:ADD("Pedido",pedido.pedido).
    jsonOutput:ADD("Data-Pedido",pedido.DATA_PEDIDO).
    jsonOutput:ADD("CNPJ Filial",PEDIDO.CNPJ_LOJA_ORIGEM).
    //jsonOutput:ADD("Status","200").
    jsonOutput:ADD("Retorno","Pedido recepcionado e dado inicio no processo de faturamento").    
                  

    IF NOT CAN-FIND(FIRST PEDIDO) THEN DO:

        jsonOutput:ADD("ERRO","Erro na execuá∆o da rotina!").

        CREATE RowErrors.
        ASSIGN RowErrors.ErrorNumber = 17001
               RowErrors.ErrorDescription = "Erro de execuá∆o da rotina"
               RowErrors.ErrorHelp = "Erro de execuá∆o da rotina"
               RowErrors.ErrorSubType = "ERROR".

        IF CAN-FIND(FIRST RowErrors) THEN DO:

            oResponse = NEW JsonAPIResponse(jsonInput).
            oResponse:setHasNext(FALSE).
            oResponse:setStatus(400).
            oResponse:setRowErrors(JsonAPIUtils:convertTempTableToJsonObject(TEMP-TABLE RowErrors:HANDLE):getJsonArray("RowErrors")).
            jsonOutput = oResponse:createJsonResponse().
        END.                                                                                                                         

    RETURN "NOK".
    END.
        
    RETURN "OK".
END PROCEDURE.

