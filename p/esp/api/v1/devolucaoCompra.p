//USING Progress.Json.ObjectModel.*.

USING Progress.Json.ObjectModel.JsonArray.
USING Progress.Json.ObjectModel.JsonObject.
USING Progress.Json.ObjectModel.JsonDataType.
USING Progress.Json.ObjectModel.ObjectModelParser.

{utp/ut-api.i}
{utp/ut-api-action.i pi-gera-devolucao  POST  /geraDevolucao/~* }
{utp/ut-api-notfound.i}

{method/dbotterr.i} /*RowErrors*/

DEFINE VARIABLE c-pedido AS INT.

DEF TEMP-TABLE devolucao NO-UNDO
    FIELD pedido              AS CHAR
    FIELD tipo-pedido         AS INT
    FIELD cnpj-devolucao      AS CHAR
    FIELD desconto            AS DEC
    FIELD observacao          AS CHAR
    FIELD cpf-cliente         AS CHAR
    FIELD cnpj-loja-origem    AS CHAR
    FIELD nota-origem         AS CHAR
    FIELD serie-origem        AS CHAR
    FIELD placa               AS CHAR 
    FIELD uf-placa            AS CHAR 
    FIELD dt-entrega          AS DATE
    FIELD cnpj-transportadora AS CHAR.

DEF TEMP-TABLE itens NO-UNDO
    FIELD pedido           AS CHAR
    FIELD cod-item         AS CHAR
    FIELD sequencia        AS DEC
    FIELD quantidade       AS DEC
    FIELD lote             AS CHAR
    FIELD valor-unid       AS DEC.

DEF TEMP-TABLE cond-pagto NO-UNDO
    FIELD pedido         AS CHAR
    FIELD cond-pagto     AS CHAR
    FIELD valor          AS DEC.
    
DEFINE TEMP-TABLE tt-pedido NO-UNDO
    FIELD pedcodigo           AS INT
    FIELD tipo_pedido         AS INT
    FIELD DtEmissao           AS DATE 
    FIELD cnpj-devolucao      AS CHAR
    FIELD cnpj-loja-origem    AS CHAR
    FIELD desconto            AS DEC
    FIELD observacao          AS CHAR
    FIELD cpf-cliente         AS CHAR
    FIELD nota-origem         AS CHAR
    FIELD serie-origem        AS CHAR
    FIELD placa               AS CHAR 
    FIELD uf-placa            AS CHAR 
    FIELD dt-entrega          AS DATE
    FIELD cnpj-transportadora AS CHAR.    
    
DEFINE TEMP-TABLE tt-pedido-item NO-UNDO
    FIELD pedido           AS CHAR
    FIELD cod-item         AS CHAR
    FIELD sequencia        AS DEC
    FIELD quantidade       AS DEC
    FIELD lote             AS CHAR
    FIELD valor-unid       AS DEC.
    
DEF TEMP-TABLE tt-cond-pagto NO-UNDO
    FIELD pedido         AS CHAR
    FIELD cond-pagto     AS CHAR
    FIELD valor          AS DEC.
   
DEF TEMP-TABLE devolucao-rest NO-UNDO
    FIELD nr-nota   AS CHAR
    FIELD serie     AS CHAR
    FIELD cnpj-loja AS CHAR.

DEF TEMP-TABLE tt-nota-devolucao NO-UNDO
    FIELD nr-nota       AS CHAR
    FIELD serie         AS CHAR
    FIELD cnpj-loja     AS CHAR
    FIELD chave-acesso AS CHAR
    FIELD l-gerada      AS LOG
    FIELD desc-erro     AS CHAR.


DEF DATASET dsDevolucao FOR devolucao, itens, cond-pagto
    DATA-RELATION r1 FOR devolucao, itens
        RELATION-FIELDS(pedido,pedido) NESTED
    DATA-RELATION r2 FOR devolucao, cond-pagto
        RELATION-FIELDS(pedido,pedido) NESTED.
        
 

FUNCTION LongCharToJsonObject RETURN JsonObject PRIVATE (INPUT jsonChar AS LONGCHAR):
    
    DEFINE VARIABLE jsonOutput AS JsonObject        NO-UNDO.
    DEFINE VARIABLE objParse   AS ObjectModelParser NO-UNDO.

    ASSIGN jsonOutput = NEW JsonObject()
           objParse   = NEW ObjectModelParser()
           jsonOutput = CAST(objParse:Parse(jsonChar), JsonObject).

    DELETE OBJECT objParse.

    RETURN jsonOutput.

END FUNCTION.

PROCEDURE pi-gera-devolucao:
    DEF INPUT  PARAM jsonInput  AS JsonObject NO-UNDO.
    DEF OUTPUT PARAM jsonOutput AS JsonObject NO-UNDO.
    
    DEFINE VARIABLE oRequestParser AS JsonAPIRequestParser NO-UNDO.
    DEFINE VARIABLE lcPayload      AS LONGCHAR             NO-UNDO.
    DEFINE VARIABLE oResponse    AS JsonAPIResponse NO-UNDO.

    oRequestParser = NEW JsonAPIRequestParser(jsonInput).
     
    ASSIGN lcPayload = oRequestParser:getPayloadLongChar().

    log-manager:write-message("KML - entrou procedure devolucao") no-error.
        
    DEF VAR jsonAux  AS JsonObject NO-UNDO.
    jsonAux = LongCharToJsonObject(lcPayload).


    MESSAGE string(jsonAux:GetJsonArray("DEVOLUCAO"):getJsonText())
        VIEW-AS ALERT-BOX INFO BUTTONS OK.

    DATASET dsDevolucao:HANDLE:READ-JSON('JsonObject',jsonAux).
    
    //jsonOutput = NEW JSONObject().    
    FOR FIRST devolucao:
        CREATE tt-pedido.
        ASSIGN tt-pedido.pedcodigo        = int(DEVOLUCAO.PEDIDO)
               tt-pedido.tipo_pedido      = DEVOLUCAO.TIPO-PEDIDO
               tt-pedido.DtEmissao        = TODAY //DEVOLUCAO.DT-ENTREGA
               tt-pedido.cnpj-devolucao   = DEVOLUCAO.CNPJ-DEVOLUCAO
               tt-pedido.cnpj-loja-origem = DEVOLUCAO.CNPJ-LOJA-ORIGEM
               tt-pedido.nota-origem      = DEVOLUCAO.NOTA-ORIGEM
               tt-pedido.serie-origem     = DEVOLUCAO.SERIE-ORIGEM
               tt-pedido.observacao       = devolucao.observacao.

    log-manager:write-message("KML - antes API - pedido.cnpj-loja - " + DEVOLUCAO.CNPJ-DEVOLUCAO) no-error.
    log-manager:write-message("KML - antes API - INT(pedido.pedido) - " + STRING(DEVOLUCAO.PEDIDO)) no-error.
        
        
    RELEASE tt-pedido.

    END.

    FOR EACH itens:
    
        CREATE tt-pedido-item.
        ASSIGN tt-pedido-item.cod-item              = ITENS.cod-item
               //tt-pedido-item.caixa                 = ITENS.CAIXA
               tt-pedido-item.lote                  = ITENS.LOTE
               //tt-pedido-item.validade_lote         = ITENS.VALIDADE_LOTE
               tt-pedido-item.quantidade            = ITENS.QUANTIDADE
               tt-pedido-item.sequencia             = ITENS.SEQUENCIA
               tt-pedido-item.valor-unid            = ITENS.VALOR-UNID.
           
          
    RELEASE tt-pedido-item.

    END.

    FOR EACH tt-pedido:
    

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
    END.
        
    FOR EACH tt-pedido:
    
        CREATE INT_DS_PEDIDO. 
        ASSIGN int_ds_pedido.situacao              = 1
               int_ds_pedido.ped_codigo_n          = tt-pedido.pedcodigo
               int_ds_pedido.dt_geracao            = tt-pedido.DtEmissao
               int_ds_pedido.ped_data_d            = tt-pedido.DtEmissao
               int_ds_pedido.ped_dataentrega_d     = tt-pedido.DtEmissao
               int_ds_pedido.ped_cnpj_origem_s     = tt-pedido.cnpj-loja-origem
               int_ds_pedido.ped_cnpj_destino_s    = tt-pedido.cnpj-devolucao
               int_ds_pedido.ped_quantidade_n      = ?
               int_ds_pedido.ped_valortotalbruto_n = ?
               int_ds_pedido.ped_tipopedido_n      = tt-pedido.tipo_pedido
               int_ds_pedido.envio_status          = 1
               int_ds_pedido.ped_observacao_s      = tt-pedido.observacao.
    END.
        
    FOR EACH tt-pedido-item:
          
        FIND first tt-pedido NO-ERROR.
          
        log-manager:write-message("KML - antes API - Valor item - " + string(tt-pedido-item.valor-unid)) no-error.
   
        CREATE int_ds_pedido_produto.
        ASSIGN int_ds_pedido_produto.ped_codigo_n     = tt-pedido.pedcodigo
               int_ds_pedido_produto.ppr_produto_n    = int(tt-pedido-item.cod-item)
               int_ds_pedido_produto.ppr_quantidade_n = tt-pedido-item.quantidade
               int_ds_pedido_produto.ppr_valorbruto_n = tt-pedido-item.valor-unid
               int_ds_pedido_produto.ppr_percentualdesconto_n = ?
               int_ds_pedido_produto.ppr_valorliquido_n       = tt-pedido-item.valor-unid
               int_ds_pedido_produto.ppr_descricaocompl_s     = ?
               int_ds_pedido_produto.nen_notafiscal_n         = INT(tt-pedido.nota-origem)
               int_ds_pedido_produto.nen_serie                = tt-pedido.serie-origem
               int_ds_pedido_produto.nep_sequencia_n          = 0 //tt-pedido-item.sequencia
               . 

        CREATE int_ds_pedido_retorno.
        ASSIGN int_ds_pedido_retorno.ped_codigo_n         = tt-pedido.pedcodigo
               int_ds_pedido_retorno.ppr_produto_n        = int(tt-pedido-item.cod-item)
               int_ds_pedido_retorno.rpp_caixa_n          = 0
               //int_ds_pedido_retorno.rpp_validade_d       = tt-pedido-item.validade_lote
               int_ds_pedido_retorno.rpp_quantidade_n     =  tt-pedido-item.quantidade
               int_ds_pedido_retorno.rpp_lote_s           = "0".            
    END.
    
    FIND FIRST tt-pedido NO-ERROR.
    
    IF AVAIL tt-pedido AND tt-pedido.cnpj-loja-origem = "79430682025540"  THEN
    DO:
    
        FIND FIRST int_ds_pedido NO-LOCK
         WHERE int_ds_pedido.ped_codigo_n = tt-pedido.pedcodigo NO-ERROR.
         
         IF AVAIL int_ds_pedido  THEN
         DO:
            
             
            jsonOutput = NEW JSONObject().
            
         
            jsonOutput:ADD("CNPJ-ORIGEM",tt-pedido.cnpj-loja-origem).
            jsonOutput:ADD("Informa‡Æo","Pedido Criado com Sucesso").

         END.
         RETURN "OK".
    END.   
         
    log-manager:write-message("KML - antes API - int_ds_pedido_retorno - " + string(int_ds_pedido_retorno.ped_codigo_n)) no-error.  

   
    RUN intprg/int081api.p ( INPUT TABLE tt-pedido, 
                             OUTPUT TABLE tt-nota-devolucao).
                                                         
    jsonOutput = NEW JSONObject().                                  
    FOR FIRST tt-nota-devolucao:
      
        IF tt-nota-devolucao.l-gerada = YES THEN
        DO:
        
            jsonOutput:ADD("CNPJ-ORIGEM",tt-pedido.cnpj-loja-origem).
            jsonOutput:ADD("serie"      ,tt-nota-devolucao.serie).
            jsonOutput:ADD("nr-nota-fis",tt-nota-devolucao.nr-nota).
            jsonOutput:ADD("chave-acesso",tt-nota-devolucao.chave-acesso).
            //jsonOutput:ADD("gerada",tt-nota-devolucao.l-gerada).
            jsonOutput:ADD("Informa‡Æo",tt-nota-devolucao.desc-erro).

        END.
        ELSE DO:

            CREATE RowErrors.
            ASSIGN RowErrors.ErrorNumber = 17001
                   RowErrors.ErrorDescription = tt-nota-devolucao.desc-erro
                   RowErrors.ErrorHelp = tt-nota-devolucao.desc-erro
                   RowErrors.ErrorSubType = "ERROR".

            IF CAN-FIND(FIRST RowErrors) THEN DO:
                   oResponse = NEW JsonAPIResponse(jsonInput).
                   oResponse:setHasNext(FALSE).
                   oResponse:setStatus(400).
                   oResponse:setRowErrors(JsonAPIUtils:convertTempTableToJsonObject(TEMP-TABLE RowErrors:HANDLE):getJsonArray("RowErrors")).
                   jsonOutput = oResponse:createJsonResponse().
                   
                   DELETE int_ds_pedido.
                   DELETE int_ds_pedido_produto. 
                   DELETE int_ds_pedido_retorno.
            END.
        END.
       
        IF NOT CAN-FIND(FIRST DEVOLUCAO) THEN DO:
            jsonOutput:ADD("ERRO","Erro na execu‡Æo da rotina!").

            CREATE RowErrors.
            ASSIGN RowErrors.ErrorNumber = 17001
                   RowErrors.ErrorDescription = "Erro de execu‡Æo da rotina"
                   RowErrors.ErrorHelp = "Erro de execu‡Æo da rotina"
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
END PROCEDURE.
