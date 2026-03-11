//USING Progress.Json.ObjectModel.*.

USING Progress.Json.ObjectModel.JsonArray.
USING Progress.Json.ObjectModel.JsonObject.
USING Progress.Json.ObjectModel.JsonDataType.
USING Progress.Json.ObjectModel.ObjectModelParser.

{utp/ut-api.i}
{utp/ut-api-action.i pi-gera-balanco  POST  /geraNotaBalanco/~* }

{utp/ut-api-notfound.i}
 
{method/dbotterr.i} /*RowErros*/
    
DEF TEMP-TABLE BALANCO NO-UNDO
    FIELD pedido_id     AS INT
    FIELD PEDIDO        AS INT
    FIELD TIPO_PEDIDO   AS INT
    FIELD DATA_PEDIDO   AS DATE
    FIELD CNPJ_FILIAL   AS CHAR.

DEF TEMP-TABLE itens NO-UNDO
    FIELD pedido_id             AS INT
    FIELD CODIGO_PRODUTO        AS INT
    FIELD CAIXA                 AS INT
    FIELD LOTE                  AS CHAR
    FIELD VALIDADE_LOTE         AS DATE
    FIELD QUANTIDADE_ESTOQUE    AS DEC
    FIELD QUANTIDADE_SEPARADA   AS DEC
    FIELD QUANTIDADE_INVENTARIO AS DEC.
    
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

DEF DATASET dsBalanco FOR BALANCO, itens 
    DATA-RELATION r1 FOR BALANCO, itens
        RELATION-FIELDS( pedido_id,pedido_id) NESTED.
        
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

PROCEDURE pi-gera-balanco:
      DEF INPUT  PARAM jsonInput  AS JsonObject NO-UNDO.
      DEF OUTPUT PARAM jsonOutput AS JsonObject NO-UNDO.
      //DEF INPUT  PARAMETER TABLE FOR tt-mp-titulos-baixa-ok. 

      DEFINE VARIABLE oRequestParser AS JsonAPIRequestParser NO-UNDO.
      DEFINE VARIABLE lcPayload      AS LONGCHAR             NO-UNDO.

      DEFINE VARIABLE oResponse    AS JsonAPIResponse NO-UNDO.
      DEFINE VARIABLE cont         AS INT.

      oRequestParser = NEW JsonAPIRequestParser(jsonInput).

      ASSIGN lcPayload = oRequestParser:getPayloadLongChar().

      DEF VAR jsonAux  AS JsonObject NO-UNDO.
      jsonAux = LongCharToJsonObject(lcPayload).

      MESSAGE string(jsonAux:GetJsonArray("BALANCO"):getJsonText())
        VIEW-AS ALERT-BOX INFO BUTTONS OK.

      DATASET dsBALANCO:HANDLE:READ-JSON('JsonObject',jsonAux).


      jsonOutput = NEW JSONObject().

      FOR FIRST BALANCO:
        
        CREATE tt-pedido.
        ASSIGN tt-pedido.pedcodigo     = BALANCO.PEDIDO
               tt-pedido.tipo_pedido   = BALANCO.TIPO_PEDIDO
               tt-pedido.DtEmissao     = BALANCO.DATA_PEDIDO
               tt-pedido.cnpj_emitente = BALANCO.CNPJ_FILIAL.
               
        log-manager:write-message("KML - antes API - pedido.cnpj-loja - " + BALANCO.CNPJ_FILIAL) no-error.
        log-manager:write-message("KML - antes API - INT(pedido.pedido) - " + STRING(BALANCO.PEDIDO)) no-error.
        log-manager:write-message("KML - antes API - BALANCO.CODIGO_PRODUTO - " + string(ITENS.CODIGO_PRODUTO)) no-error.

      RELEASE tt-pedido.
      END.

      FOR EACH itens:
        CREATE tt-pedido-item.
        ASSIGN tt-pedido-item.codigo_produto        = ITENS.CODIGO_PRODUTO
               tt-pedido-item.caixa                 = ITENS.CAIXA     
               tt-pedido-item.lote                  = ITENS.LOTE
               tt-pedido-item.validade_lote         = ITENS.VALIDADE_LOTE
               tt-pedido-item.quantidade_estoque    = ITENS.QUANTIDADE_ESTOQUE
               tt-pedido-item.quantidade_separada   = ITENS.QUANTIDADE_SEPARADA
               tt-pedido-item.quantidade_inventario = ITENS.QUANTIDADE_INVENTARIO.
               
               ASSIGN cont = cont + 1.

      RELEASE tt-pedido-item.           
      END.
      
      log-manager:write-message("KML - antes API - CONTAGEM ITEM - " + string(cont)) no-error.
      
      FOR EACH tt-pedido:

        FIND FIRST estabelec NO-LOCK
            WHERE estabelec.cgc = tt-pedido.cnpj_emitente NO-ERROR.
            
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

      FOR EACH tt-pedido-item:

        FIND FIRST ITEM NO-LOCK
            WHERE ITEM.it-codigo = string(tt-pedido-item.codigo_produto) NO-ERROR.
            
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
               
        RETURN "NOK".
          
        END.
      END.

      FOR EACH tt-pedido:

      find first int_ds_tipo_pedido no-lock
         where int_ds_tipo_pedido.tp_pedido = string(tt-pedido.tipo_pedido) no-error. 
         
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

        RETURN "NOK".
        END.
       
        FIND FIRST int_ds_pedido NO-LOCK
         WHERE int_ds_pedido.ped_codigo_n = tt-pedido.pedcodigo NO-ERROR.
         
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

        RETURN "NOK".
        END.


        CREATE INT_DS_PEDIDO.
        ASSIGN int_ds_pedido.situacao              = 1
              int_ds_pedido.ped_codigo_n          = tt-pedido.pedcodigo    
              int_ds_pedido.dt_geracao            = tt-pedido.DtEmissao
              int_ds_pedido.ped_data_d            = tt-pedido.DtEmissao
              int_ds_pedido.ped_dataentrega_d     = tt-pedido.DtEmissao
              int_ds_pedido.ped_cnpj_origem_s     = tt-pedido.cnpj_emitente
              int_ds_pedido.ped_cnpj_destino_s    = tt-pedido.cnpj_emitente
              int_ds_pedido.ped_quantidade_n      = ?
              int_ds_pedido.ped_valortotalbruto_n = ?
              int_ds_pedido.ped_tipopedido_n      = tt-pedido.tipo_pedido
              int_ds_pedido.envio_status          = 1.
      END.

      FOR EACH tt-pedido-item:
        
        FIND FIRST tt-pedido NO-ERROR.
          
        CREATE int_ds_pedido_produto.
        ASSIGN int_ds_pedido_produto.ped_codigo_n     = tt-pedido.pedcodigo
               int_ds_pedido_produto.ppr_produto_n    = tt-pedido-item.codigo_produto
               int_ds_pedido_produto.ppr_quantidade_n = tt-pedido-item.quantidade_estoque
               int_ds_pedido_produto.ppr_valorbruto_n = ?
               int_ds_pedido_produto.ppr_percentualdesconto_n = ?
               int_ds_pedido_produto.ppr_valorliquido_n       = ?
               int_ds_pedido_produto.ppr_descricaocompl_s     = ?
               int_ds_pedido_produto.nen_notafiscal_n         = ?
               int_ds_pedido_produto.nen_serie                = ?
               int_ds_pedido_produto.nep_sequencia_n          = 0.
         
        CREATE int_ds_pedido_retorno.
        ASSIGN int_ds_pedido_retorno.ped_codigo_n         = tt-pedido.pedcodigo
               int_ds_pedido_retorno.ppr_produto_n        = tt-pedido-item.codigo_produto
               int_ds_pedido_retorno.rpp_caixa_n          = tt-pedido-item.caixa  
               int_ds_pedido_retorno.rpp_validade_d       = tt-pedido-item.validade_lote 
               int_ds_pedido_retorno.rpp_quantidade_n     = tt-pedido-item.quantidade_estoque
               int_ds_pedido_retorno.rpp_qtd_inventario_n = dec(tt-pedido-item.quantidade_inventario).
                     
               
         
        log-manager:write-message("KML - antes API - Antes do IF CAN FIND- " + BALANCO.CNPJ_FILIAL) no-error.

      END.
      
      jsonOutput:ADD("Pedido",int_ds_pedido.ped_codigo_n).
      jsonOutput:ADD("Data-Pedido",int_ds_pedido.dt_geracao).
      jsonOutput:ADD("CNPJ Filial",int_ds_pedido.ped_cnpj_origem_s).
      jsonOutput:ADD("Situacao",int_ds_pedido.situacao).
      //jsonOutput:ADD("Status","200").
      jsonOutput:ADD("Retorno","Pedido recepcionado e dado inicio no processo de faturamento").  
                  

      IF NOT CAN-FIND(FIRST BALANCO) THEN DO:

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
