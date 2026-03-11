//USING Progress.Json.ObjectModel.*.

USING Progress.Json.ObjectModel.JsonArray.
USING Progress.Json.ObjectModel.JsonObject.
USING Progress.Json.ObjectModel.JsonDataType.
USING Progress.Json.ObjectModel.ObjectModelParser.

{utp/ut-api.i}
{utp/ut-api-action.i pi-gera-clientes  POST  /geraClientes/~* }
{utp/ut-api-notfound.i} 
{method/dbotterr.i} /*RowErros*/

DEFINE TEMP-TABLE CLIENTES NO-UNDO
    FIELD CNPJ-CPF-CLIENTE AS CHAR
    FIELD nome              AS CHAR
    FIELD NATUREZA-CLIENTE  AS CHAR // 1 - Fisica ** 2 - Juridica
    FIELD INCRICAO_FEDERAL  AS CHAR
    FIELD cep               AS CHAR
    FIELD tipo_endereco     AS CHAR
    FIELD endereco          AS CHAR
    FIELD numero            AS CHAR
    FIELD complemento       AS CHAR
    FIELD bairro            AS CHAR
    FIELD cidade            AS CHAR
    FIELD cod_ibge          AS CHAR
    FIELD estado            AS CHAR
    FIELD pais              AS CHAR
    FIELD referencia        AS CHAR
    FIELD telefone          AS CHAR
    FIELD celular           AS CHAR.

DEFINE TEMP-TABLE tt-cliente NO-UNDO
    FIELD CNPJ          AS CHAR
    FIELD nome          AS CHAR
    FIELD nome-abrev    AS CHAR
    FIELD natureza      AS INT // 1 - Fisica ** 2 - Juridica
    FIELD ins-estadual  AS CHAR
    FIELD cep           AS CHAR
    FIELD tipo_endereco AS CHAR
    FIELD endereco      AS CHAR
    FIELD numero        AS CHAR
    FIELD complemento   AS CHAR
    FIELD bairro        AS CHAR
    FIELD cidade        AS CHAR
    FIELD cod-ibge      AS CHAR
    FIELD estado        AS CHAR
    FIELD pais          AS CHAR
    FIELD referencia    AS CHAR
    FIELD telefone      AS CHAR
    FIELD celular       AS CHAR.
    
DEFINE TEMP-TABLE tt-valida NO-UNDO
    FIELD desc-erro     AS CHAR
    FIELD Nome_abrev    AS CHAR
    FIELD l-erro        AS LOGICAL.
    

/* Defini‡Æo temp-tables/vari veis execu‡Æo FT2200 */
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
DEFINE VARIABLE natur_cli AS INT NO-UNDO.

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

//DEFINE DATASET dsCli FOR clientes.

FUNCTION LongCharToJsonObject RETURN JsonObject PRIVATE (INPUT jsonChar AS LONGCHAR):
    
    DEFINE VARIABLE jsonOutput AS JsonObject        NO-UNDO.
    DEFINE VARIABLE objParse   AS ObjectModelParser NO-UNDO.

    ASSIGN jsonOutput = NEW JsonObject()
           objParse   = NEW ObjectModelParser()
           jsonOutput = CAST(objParse:Parse(jsonChar), JsonObject).

    DELETE OBJECT objParse.

    RETURN jsonOutput.

END FUNCTION.

PROCEDURE pi-gera-clientes:
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
    
    TEMP-TABLE CLIENTES:HANDLE:READ-JSON('JsonArray',jsonAux:GetJsonArray("CLIENTES")).

/*     MESSAGE string(jsonAux:GetJsonArray("CLIENTES"):getJsonText()) */
/*         VIEW-AS ALERT-BOX INFO BUTTONS OK.                         */
        
    log-manager:write-message("KML - antes API - Cliente - " + clientes.nome) no-error.
    log-manager:write-message("KML - antes API - CIDADE - " + clientes.cidade) no-error.
    log-manager:write-message("KML - antes API - CNPJ - " + clientes.CNPJ) no-error.
    log-manager:write-message("KML - antes API - NATUREZA - " + clientes.natureza) no-error.
        
    FOR FIRST CLIENTES:
    
        IF CLIENTES.NATUREZA      = "FISICA" THEN
            ASSIGN natur_cli  = 1.
        ELSE IF CLIENTES.NATUREZA = "JURIDICA" THEN
            ASSIGN natur_cli = 2.
                
        CREATE tt-cliente.
        ASSIGN tt-cliente.CNPJ          = CLIENTES.CNPJ-CPF-CLIENTE         
               tt-cliente.nome          = CLIENTES.nome          
               tt-cliente.natureza      = natur_cli
               tt-cliente.ins-estadual  = CLIENTES.INCRICAO_FEDERAL 
               tt-cliente.cep           = CLIENTES.cep           
               tt-cliente.tipo_endereco = CLIENTES.tipo_endereco 
               tt-cliente.endereco      = CLIENTES.endereco      
               tt-cliente.numero        = CLIENTES.numero        
               tt-cliente.complemento   = CLIENTES.complemento   
               tt-cliente.bairro        = CLIENTES.bairro        
               tt-cliente.cidade        = CLIENTES.cidade        
               tt-cliente.cod-ibge      = CLIENTES.cod_ibge      
               tt-cliente.estado        = CLIENTES.estado        
               tt-cliente.pais          = CLIENTES.pais          
               tt-cliente.referencia    = CLIENTES.referencia    
               tt-cliente.telefone      = CLIENTES.telefone      
               tt-cliente.celular       = CLIENTES.celular.
     
    END.
    
    log-manager:write-message("KML - antes API CNPJ - CNPJ - " + tt-cliente.cnpj) no-error.  
    log-manager:write-message("KML - antes API2 - Cliente - " + clientes.nome) no-error.
   
    RUN intprg/int083API.p (INPUT TABLE tt-cliente,
                            OUTPUT TABLE tt-valida).
                               
    jsonOutput = NEW JSONObject().
    FOR FIRST tt-valida:
        
        IF tt-valida.l-erro THEN DO:
            
            jsonOutput:ADD("Retorno","Cliente cadastrado com sucesso!").
            jsonOutput:ADD("Nome Abrev",tt-valida.nome_abrev).
        END.      
    
        ELSE DO:
            
            CREATE RowErrors.                                                                                                           
            ASSIGN RowErrors.ErrorNumber = 17001                                                                                        
                   RowErrors.ErrorDescription = TT-VALIDA.DESC-ERRO                                         
                   RowErrors.ErrorHelp = TT-VALIDA.DESC-ERRO                                               
                   RowErrors.ErrorSubType = "ERROR".                                                                                    
                                                                                                                                       
            IF CAN-FIND(FIRST RowErrors) THEN DO:
            
                 oResponse = NEW JsonAPIResponse(jsonInput).                                                                               jsonOutput:ADD("Descri‡Æo",tt-valida.desc-erro). 
                 oResponse:setHasNext(FALSE).                                                                                              END.
                 oResponse:setStatus(400).                                                                                                 
                 oResponse:setRowErrors(JsonAPIUtils:convertTempTableToJsonObject(TEMP-TABLE RowErrors:HANDLE):getJsonArray("RowErrors")). 
                 jsonOutput = oResponse:createJsonResponse().
             
            RETURN "NOK".
            END.
        END.
       
        IF NOT CAN-FIND(FIRST CLIENTES) THEN
        jsonOutput:ADD("ERRO","Erro na execu‡Æo da rotina!").
                                                                                                                                      
     RETURN "OK".
END PROCEDURE.
