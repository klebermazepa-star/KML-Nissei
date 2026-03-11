//USING Progress.Json.ObjectModel.*.

USING Progress.Json.ObjectModel.JsonArray.
USING Progress.Json.ObjectModel.JsonObject.
USING Progress.Json.ObjectModel.JsonDataType.
USING Progress.Json.ObjectModel.ObjectModelParser.

{utp/ut-api.i}
{utp/ut-api-action.i pi-gera-acordos-comerciais  POST  /~* }
{utp/ut-api-notfound.i}

{method/dbotterr.i} /*RowErrors*/

    
DEFINE TEMP-TABLE Acordos_Comerciais NO-UNDO
    FIELD TITULOS_RECEBER       AS INTEGER    
    FIELD DATA_HORA             AS DATETIME   
    FIELD TITULO                AS CHARACTER  
    FIELD SERIE                 AS CHARACTER  
    FIELD ESPECIE               AS CHARACTER  
    FIELD PARCELA               AS INTEGER    
    FIELD CARTEIRA              AS CHARACTER  
    FIELD TIPO_FLUXO            AS CHARACTER  
    FIELD DATA_EMISSAO          AS DATETIME   
    FIELD DATA_VENCIMENTO       AS DATETIME   
    FIELD CNPJ_EMITENTE         AS CHARACTER  
    FIELD CNPJ_FILIAL           AS CHARACTER  
    FIELD ESTABELECIMENTO       AS CHARACTER  
    FIELD PLANO_CONTAS          AS CHARACTER  
    FIELD UNIDADE_NEGOCIO       AS CHARACTER  
    FIELD CONTA_CONTABIL        AS CHARACTER  
    FIELD CENTRO_CUSTO          AS CHARACTER  
    FIELD VALOR                 AS DECIMAL.   
    .


/* Defini‡Æo temp-tables/vari veis execu‡Æo FT2200 */
DEF NEW GLOBAL SHARED VAR c-seg-usuario AS CHAR NO-UNDO.
DEFINE VARIABLE raw-param    AS RAW NO-UNDO.

DEFINE TEMP-TABLE tt-raw-digita NO-UNDO
    FIELD raw-digita      AS RAW.


define temp-table tt-valida no-undo
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

PROCEDURE pi-gera-acordos-comerciais:

    DEF INPUT  PARAM jsonInput  AS JsonObject NO-UNDO.
    DEF OUTPUT PARAM jsonOutput AS JsonObject NO-UNDO.
    //DEF INPUT  PARAMETER TABLE FOR tt-mp-titulos-baixa-ok. 

    DEFINE VARIABLE oRequestParser AS JsonAPIRequestParser NO-UNDO.
    DEFINE VARIABLE lcPayload      AS LONGCHAR             NO-UNDO.
    DEFINE VARIABLE oResponse      AS JsonAPIResponse      NO-UNDO.

    oRequestParser = NEW JsonAPIRequestParser(jsonInput).
     
    ASSIGN lcPayload = oRequestParser:getPayloadLongChar().

    DEF VAR jsonAux  AS JsonObject NO-UNDO.
    jsonAux = LongCharToJsonObject(lcPayload).
        
    TEMP-TABLE Acordos_Comerciais:HANDLE:READ-JSON('JsonArray',jsonAux:GetJsonArray("ACORDOS_COMERCIAIS")).
    
    
    jsonOutput = NEW JSONObject().
     
    FOR FIRST acordos_comerciais:
        CREATE int_dp_acordos_duplicatas.
        ASSIGN int_dp_acordos_duplicatas.titulo_receber     = acordos_comerciais.TITULOS_RECEBER          
               int_dp_acordos_duplicatas.data_hora          = acordos_comerciais.DATA_HORA               
               int_dp_acordos_duplicatas.titulo             = acordos_comerciais.TITULO                  
               int_dp_acordos_duplicatas.especie            = acordos_comerciais.especie                   
               int_dp_acordos_duplicatas.parcela            = string(acordos_comerciais.PARCELA)                 
               int_dp_acordos_duplicatas.portador           = "99999"                
               int_dp_acordos_duplicatas.carteira           = acordos_comerciais.CARTEIRA                  
               int_dp_acordos_duplicatas.tipo_fluxo         = acordos_comerciais.TIPO_FLUXO              
               int_dp_acordos_duplicatas.emissao            = acordos_comerciais.DATA_EMISSAO            
               int_dp_acordos_duplicatas.vencimento         = acordos_comerciais.DATA_VENCIMENTO         
               int_dp_acordos_duplicatas.CNPJ_emitente      = acordos_comerciais.CNPJ_EMITENTE         
               int_dp_acordos_duplicatas.CNPJ_filial        = acordos_comerciais.CNPJ_FILIAL             
               int_dp_acordos_duplicatas.estabelecimento    = acordos_comerciais.ESTABELECIMENTO         
               int_dp_acordos_duplicatas.plano_contas       = acordos_comerciais.PLANO_CONTAS            
               int_dp_acordos_duplicatas.unidade_negocio    = acordos_comerciais.UNIDADE_NEGOCIO         
               int_dp_acordos_duplicatas.conta_contabil     = acordos_comerciais.CONTA_CONTABIL          
               int_dp_acordos_duplicatas.centro_custo       = acordos_comerciais.CENTRO_CUSTO            
               int_dp_acordos_duplicatas.valor              = acordos_comerciais.VALOR                   
               int_dp_acordos_duplicatas.situacao           = 1         
               int_dp_acordos_duplicatas.id_sequencial      = ? //fazer for last?         
               int_dp_acordos_duplicatas.envio_status       = 1         
               int_dp_acordos_duplicatas.envio_data_hora    = TODAY         
               int_dp_acordos_duplicatas.envio_erro         = ""         
               int_dp_acordos_duplicatas.retorno_validacao  = ""     
               int_dp_acordos_duplicatas.retorno_data_hora  = TODAY      
               int_dp_acordos_duplicatas.serie              = acordos_comerciais.SERIE.
               
           
            //jsonOutput:ADD("Transaction ID", cartao.Transaction_ID).

    END.
    run intprg/nicr027HUBrp.p (INPUT TABLE acordos_comerciais, // criar tt para envio?
                                    OUTPUT table tt-valida).
                                        
        jsonOutput = NEW JSONObject().
        FOR FIRST tt-valida:
            
            IF tt-valida.l-erro = YES THEN
            DO:
                jsonOutput:ADD("C¢digo", tt-valida.cod-erro).
                jsonOutput:ADD("Idenficica‡Æo", tt-valida.identifi-msg).
                jsonOutput:ADD("Descri‡Æo", tt-valida.desc-erro).
                //jsonOutput:ADD("Retorno", "Movimento de Acordo Comercial realizado com sucesso").
                jsonOutput:ADD("Retorno", "Movimento de Acordo Comercial realizado com sucesso").

                
            END.
            ELSE DO:
                CREATE RowErrors.
                ASSIGN RowErrors.ErrorNumber = 17001
                       RowErrors.ErrorDescription =  tt-valida.identifi-msg
                       RowErrors.ErrorHelp =  string(tt-valida.cod-erro)
                       RowErrors.ErrorSubType = "ERROR".

                IF CAN-FIND(FIRST RowErrors) THEN DO:
                   oResponse = NEW JsonAPIResponse(jsonInput).
                   oResponse:setHasNext(FALSE).
                   oResponse:setStatus(400).
                   oResponse:setRowErrors(JsonAPIUtils:convertTempTableToJsonObject(TEMP-TABLE RowErrors:HANDLE):getJsonArray("RowErrors")).
                   jsonOutput = oResponse:createJsonResponse().
                   
                   DELETE int_dp_acordos_duplicatas.
                   
            
                END.
            END.
        END.
        
        RELEASE int_dp_acordos_duplicatas. 
                 


        IF NOT CAN-FIND(FIRST acordos_comerciais) THEN
        jsonOutput:ADD("ERRO","Erro na execu‡Æo da rotina!").

        RETURN "OK".

END PROCEDURE.
