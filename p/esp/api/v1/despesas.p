//USING Progress.Json.ObjectModel.*.

USING Progress.Json.ObjectModel.JsonArray.
USING Progress.Json.ObjectModel.JsonObject.
USING Progress.Json.ObjectModel.JsonDataType.
USING Progress.Json.ObjectModel.ObjectModelParser.

{utp/ut-api.i}
{utp/ut-api-action.i pi-despesas  POST  /geraFundoFixo/~* }
{utp/ut-api-notfound.i}

{method/dbotterr.i} /*RowErrors*/

DEF TEMP-TABLE DESPESAS NO-UNDO
    FIELD CNPJ_FILIAL AS CHAR
    FIELD CENTRO_CUSTO AS CHAR
    FIELD CODIGO_DOCUMENTO AS CHAR
    FIELD EMPRESA          AS CHAR
    FIELD UNIDADE_NEGOCIO  AS CHAR
    FIELD CONTA_CONTABIL   AS CHAR
    FIELD DATA_MOVIMENTO   AS DATE
    FIELD HISTORICO        AS CHAR
    FIELD NATUREZA         AS CHAR
    FIELD VALOR_MOVIMENTO  AS DEC
    FIELD TIPO_MOVIMENTO   AS INT. // 1 Ç SAIDA (D) 2 Ç entrada(C) 
    
DEF TEMP-TABLE tt-despesas NO-UNDO
    FIELD CNPJ_FILIAL       AS CHAR
    FIELD CENTRO_CUSTO     AS CHAR
    FIELD CODIGO_DOCUMENTO AS CHAR
    FIELD EMPRESA          AS CHAR
    FIELD UNIDADE_NEGOCIO  AS CHAR
    FIELD CONTA_CONTABIL   AS CHAR
    FIELD DATA_MOVIMENTO   AS DATE
    FIELD HISTORICO        AS CHAR
    FIELD NATUREZA         AS CHAR
    FIELD VALOR_MOVIMENTO  AS DEC
    FIELD TIPO_MOVIMENTO   AS CHAR. // 1 Ç SAIDA (D) 2 Ç entrada(C)

DEF TEMP-TABLE tt-retorno NO-UNDO
    FIELD docto-ff AS CHAR
    //FIELD conta         AS CHAR
    FIELD cnpj-loja     AS CHAR
    FIELD chave-acesso AS CHAR
    FIELD l-gerada      AS LOG
    FIELD desc-erro     AS CHAR.
    
DEFINE VARIABLE c_tipo_movto  AS CHARACTER   NO-UNDO.
    
FUNCTION findTag returns longchar
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

PROCEDURE pi-despesas:
    DEF INPUT  PARAM jsonInput  AS JsonObject NO-UNDO.
    DEF OUTPUT PARAM jsonOutput AS JsonObject NO-UNDO.
    
    DEFINE VARIABLE oRequestParser AS JsonAPIRequestParser NO-UNDO.
    DEFINE VARIABLE lcPayload      AS LONGCHAR             NO-UNDO.
    DEFINE VARIABLE oResponse    AS JsonAPIResponse NO-UNDO.

    oRequestParser = NEW JsonAPIRequestParser(jsonInput).
     
    ASSIGN lcPayload = oRequestParser:getPayloadLongChar().

    log-manager:write-message("KML - entrou procedure despesa") no-error.
        
    DEF VAR jsonAux  AS JsonObject NO-UNDO.
    jsonAux = LongCharToJsonObject(lcPayload).
    
    TEMP-TABLE DESPESAS:HANDLE:READ-JSON('JsonArray',jsonAux:GetJsonArray("DESPESAS")).

    MESSAGE string(jsonAux:GetJsonArray("DESPESAS"):getJsonText())
        VIEW-AS ALERT-BOX INFO BUTTONS OK.
    
    FOR FIRST despesas :
    
        IF despesas.tipo_movimento = 1 THEN
           ASSIGN c_tipo_movto = "D".
        ELSE IF despesas.tipo_movimento = 2 THEN
           ASSIGN c_tipo_movto = "C".

        CREATE tt-despesas.
        ASSIGN tt-despesas.CNPJ_FILIAL      = DESPESAS.CNPJ_FILIAL      
               tt-despesas.CENTRO_CUSTO     = DESPESAS.CENTRO_CUSTO   
               tt-despesas.CODIGO_DOCUMENTO = DESPESAS.CODIGO_DOCUMENT
               tt-despesas.EMPRESA          = DESPESAS.EMPRESA        
               tt-despesas.UNIDADE_NEGOCIO  = DESPESAS.UNIDADE_NEGOCIO
               tt-despesas.CONTA_CONTABIL   = DESPESAS.CONTA_CONTABIL 
               tt-despesas.DATA_MOVIMENTO   = DESPESAS.DATA_MOVIMENTO 
               tt-despesas.HISTORICO        = DESPESAS.HISTORICO      
               tt-despesas.NATUREZA         = DESPESAS.NATUREZA       
               tt-despesas.VALOR_MOVIMENTO  = DESPESAS.VALOR_MOVIMENTO
               tt-despesas.TIPO_MOVIMENTO   = c_tipo_movto. 
        
    END.
    
    log-manager:write-message("KML - FORA API - CNPJ - " + tt-despesas.cnpj_filial) no-error.
    log-manager:write-message("ANTES RUN tt-despesas") no-error.
    //log-manager:write-message("KML - Dentro API - Nome - " + tt-cliente.nome) no-error.
    //log-manager:write-message("encontrou" + tt-cliente.cnpj) no-error.
    
    RUN intprg/int001-ecom.p (INPUT TABLE tt-despesas,
                              OUTPUT TABLE tt-retorno).
    
    jsonOutput = NEW JSONObject().                          
    FOR EACH tt-retorno:
    
        IF tt-retorno.l-gerada = NO THEN
        DO:
            
            CREATE RowErrors.                                                                                                             
            ASSIGN RowErrors.ErrorNumber = 17001                                                                                          
                   RowErrors.ErrorDescription = tt-retorno.desc-erro                                                              
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
        
        ELSE DO:
            jsonOutput:ADD("Retorno","Despesa recepcionada e dado o inicio no processo de inclus∆o no modulo caixas e bancos").
            jsonOutput:ADD("Integraá∆o",tt-retorno.desc-erro). 
        
        END.
            
                      
            
    END.
          
    IF NOT CAN-FIND(FIRST DESPESAS) THEN DO:                                                                                         
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
                                                                                                                                                                                                                                 
END PROCEDURE.
