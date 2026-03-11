//USING Progress.Json.ObjectModel.*.

USING Progress.Json.ObjectModel.JsonArray.
USING Progress.Json.ObjectModel.JsonObject.
USING Progress.Json.ObjectModel.JsonDataType.
USING Progress.Json.ObjectModel.ObjectModelParser.

{utp/ut-api.i}
{utp/ut-api-action.i pi-gera-cartao-presente  POST  /~* }
{utp/ut-api-notfound.i}

{method/dbotterr.i} /*RowErrors*/

    
DEF TEMP-TABLE cartao NO-UNDO
    FIELD Transaction_ID    AS INT
    FIELD Cnpj_estabel      AS CHAR
    FIELD Data_venda        AS DATE
    FIELD Data_credito      AS DATE
    FIELD Data_vencimento   AS DATE
    FIELD Tipo_venda        AS CHAR
    FIELD Valor_bruto       AS DEC
    FIELD Valor_liquido     AS DEC
    FIELD Taxa              AS DEC.


/* Defini‡Æo temp-tables/vari veis execu‡Æo FT2200 */
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

PROCEDURE pi-gera-cartao-presente:

    DEF INPUT  PARAM jsonInput  AS JsonObject NO-UNDO.
    DEF OUTPUT PARAM jsonOutput AS JsonObject NO-UNDO.
    //DEF INPUT  PARAMETER TABLE FOR tt-mp-titulos-baixa-ok. 

    DEFINE VARIABLE oRequestParser AS JsonAPIRequestParser NO-UNDO.
    DEFINE VARIABLE lcPayload      AS LONGCHAR             NO-UNDO.

    oRequestParser = NEW JsonAPIRequestParser(jsonInput).
     
    ASSIGN lcPayload = oRequestParser:getPayloadLongChar().

    DEF VAR jsonAux  AS JsonObject NO-UNDO.
    jsonAux = LongCharToJsonObject(lcPayload).
        
    TEMP-TABLE cartao:HANDLE:READ-JSON('JsonArray',jsonAux:GetJsonArray("cartao")).
        
    jsonOutput = NEW JSONObject().
     
    FOR FIRST cartao:   
    
    
        FIND FIRST cst_movto_cartao_presente NO-LOCK 
            WHERE cst_movto_cartao_presente.transID_cartao_presente = cartao.Transaction_ID NO-ERROR.
            
        IF NOT AVAIL cst_movto_cartao_presente THEN DO:
        
            CREATE cst_movto_cartao_presente.
            ASSIGN cst_movto_cartao_presente.transID_cartao_presente    = cartao.Transaction_ID
                   cst_movto_cartao_presente.cnpj_estabel               = cartao.Cnpj_estabel
                   cst_movto_cartao_presente.data_venda                 = cartao.Data_venda
                   cst_movto_cartao_presente.data_credito               = cartao.Data_credito
                   cst_movto_cartao_presente.data_vencimento            = cartao.Data_vencimento
                   cst_movto_cartao_presente.tipo_venda                 = cartao.Tipo_venda
                   cst_movto_cartao_presente.valor_bruto                = cartao.Valor_bruto
                   cst_movto_cartao_presente.valor_liquido              = cartao.Valor_liquido
                   cst_movto_cartao_presente.taxa                       = cartao.Taxa.
            
            
            jsonOutput:ADD("Retorno", "Movimento Cartao presente armazenado com sucesso").
            jsonOutput:ADD("Transaction ID", cartao.Transaction_ID).            
            
        END.
        ELSE DO:
        
            ASSIGN cst_movto_cartao_presente.cnpj_estabel               = cartao.Cnpj_estabel
                   cst_movto_cartao_presente.data_venda                 = cartao.Data_venda
                   cst_movto_cartao_presente.data_credito               = cartao.Data_credito
                   cst_movto_cartao_presente.data_vencimento            = cartao.Data_vencimento
                   cst_movto_cartao_presente.tipo_venda                 = cartao.Tipo_venda
                   cst_movto_cartao_presente.valor_bruto                = cartao.Valor_bruto
                   cst_movto_cartao_presente.valor_liquido              = cartao.Valor_liquido
                   cst_movto_cartao_presente.taxa                       = cartao.Taxa.  
                   
            jsonOutput:ADD("Retorno", "Movimento Cartao presente atualizado com sucesso").
            jsonOutput:ADD("Transaction ID", cartao.Transaction_ID). 
        
        END.



    END.
                     
   

    IF NOT CAN-FIND(FIRST cartao) THEN
        jsonOutput:ADD("ERRO","Erro na execu‡Æo da rotina!").

    RETURN "OK".
    
END PROCEDURE.


/*
    
DEF TEMP-TABLE cartao NO-UNDO
    FIELD Transaction_ID    AS CHAR
    FIELD Cnpj_estabel      AS CHAR
    FIELD Data_venda        AS DATE
    FIELD Data_credito      AS DATE
    FIELD Data_vencimento   AS DATE
    FIELD Tipo_venda        AS CHAR
    FIELD Valor_bruto       AS DEC
    FIELD Valor_liquido     AS DEC
    FIELD Taxa              AS DEC.

*/ 
