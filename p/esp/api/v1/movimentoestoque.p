//USING Progress.Json.ObjectModel.*.

USING Progress.Json.ObjectModel.JsonArray.
USING Progress.Json.ObjectModel.JsonObject.
USING Progress.Json.ObjectModel.JsonDataType.
USING Progress.Json.ObjectModel.ObjectModelParser.

{utp/ut-api.i}
{utp/ut-api-action.i piGeraMovimento  POST  /~* }
{utp/ut-api-notfound.i}
{method/dbotterr.i} /*RowErros*/


/**/ 
{cdp/cd0666.i &1=" " &excludeFrameDefinition=YES} /*tt-erro*/
{cep/ceapi001k.i} /*tt-movto*/

DEF VAR hApi    AS HANDLE NO-UNDO .

DEFINE TEMP-TABLE MessageContent NO-UNDO
    FIELD REGISTRO_CONTROLE AS INTEGER
    FIELD CNPJ_EMPRESA      AS CHARACTER
    FIELD DATAEMISSAO       AS DATE
    FIELD FINALIZADO        AS CHARACTER
    .

DEFINE TEMP-TABLE PRODUTOS NO-UNDO
    FIELD REGISTRO_CONTROLE     AS INTEGER
    FIELD PRODUTO               AS INTEGER
    FIELD DOCUMENTO             AS INTEGER
    FIELD TIPO_MOVIMENTO        AS CHARACTER
    FIELD QUANTIDADE_CONVERTIDA AS DECIMAL
    FIELD LOTE                  AS CHARACTER
    FIELD DATAVALIDADE          AS DATE
    FIELD CENTRO_ESTOQUE        AS CHARACTER
    .
    
DEFINE TEMP-TABLE tt-retorno NO-UNDO
    FIELD l-erro    AS INT 
    field desc-erro as char format "x(60)".    

DEF DATASET dsMovimento FOR messagecontent, produtos
    DATA-RELATION r1 FOR messagecontent, produtos
        RELATION-FIELDS(registro_controle,registro_controle) NESTED.

FUNCTION LongCharToJsonObject RETURN JsonObject PRIVATE (INPUT jsonChar AS LONGCHAR):
    
    DEFINE VARIABLE jsonOutput AS JsonObject        NO-UNDO.
    DEFINE VARIABLE objParse   AS ObjectModelParser NO-UNDO.

    ASSIGN jsonOutput = NEW JsonObject()
           objParse   = NEW ObjectModelParser()
           jsonOutput = CAST(objParse:Parse(jsonChar), JsonObject).

    DELETE OBJECT objParse.

    RETURN jsonOutput.

END FUNCTION.

PROCEDURE piGeraMovimento:
    DEF INPUT  PARAM jsonInput  AS JsonObject NO-UNDO.
    DEF OUTPUT PARAM jsonOutput AS JsonObject NO-UNDO.

    DEFINE VARIABLE oRequestParser AS JsonAPIRequestParser NO-UNDO.
    DEFINE VARIABLE lcPayload      AS LONGCHAR             NO-UNDO.
    DEFINE VARIABLE oResponse      AS JsonAPIResponse      NO-UNDO.

    oRequestParser = NEW JsonAPIRequestParser(jsonInput).
     
    ASSIGN lcPayload = oRequestParser:getPayloadLongChar().

    DEF VAR jsonAux  AS JsonObject NO-UNDO.
    jsonAux = LongCharToJsonObject(lcPayload).

    DATASET dsMovimento:HANDLE:READ-JSON('JsonObject',jsonAux).

    oResponse   = NEW JsonAPIResponse(jsonInput).
    oResponse:setHasNext(FALSE).

    //oResponse:setStatus(200).
    jsonOutput = oResponse:createJsonResponse().

    DO TRANSACTION ON ERROR UNDO , LEAVE:

        RUN cep/ceapi001k.p PERSISTENT SET hApi.
 
        EMPTY TEMP-TABLE tt-movto .
        EMPTY TEMP-TABLE tt-erro.

        FOR FIRST messagecontent:
            
            RUN piCriaMovimento.
            
        END.    
            
        FIND FIRST RowErrors NO-LOCK
            WHERE RowErrors.ErrorSubType <> "WARNING" NO-ERROR. 
        IF AVAIL RowErrors THEN DO:
        
            CREATE tt-retorno.
            ASSIGN tt-retorno.l-erro    = RowErrors.errorNumber
                   tt-retorno.desc-erro = RowErrors.errorDescription.
                   
        
 
            EMPTY TEMP-TABLE RowErrors.

            CREATE RowErrors.
            ASSIGN RowErrors.ErrorNumber = tt-retorno.l-erro
                   RowErrors.ErrorDescription = tt-retorno.desc-erro
                   RowErrors.ErrorHelp = tt-retorno.desc-erro
                   RowErrors.ErrorSubType = "ERROR".  
 
        
            oResponse = NEW JsonAPIResponse(jsonInput).
            oResponse:setHasNext(FALSE).
            oResponse:setStatus(400).
            oResponse:setRowErrors(JsonAPIUtils:convertTempTableToJsonObject(TEMP-TABLE RowErrors:HANDLE):getJsonArray("RowErrors")).
            jsonOutput = oResponse:createJsonResponse().
            
            UNDO, LEAVE.
        END.
        
        RUN pi-execute IN hApi (INPUT-OUTPUT TABLE tt-movto ,
                                INPUT-OUTPUT TABLE tt-erro ,
                                INPUT NO) .
        IF CAN-FIND(FIRST tt-erro) THEN DO:
            FOR EACH tt-erro:
                RUN piCriaErro(INPUT tt-erro.mensagem,
                               INPUT "",
                               INPUT tt-erro.cd-erro).
            END.
            
            FIND FIRST RowErrors NO-LOCK NO-ERROR. 
            IF AVAIL RowErrors THEN DO:
            
                CREATE tt-retorno.
                ASSIGN tt-retorno.l-erro    = RowErrors.errorNumber
                       tt-retorno.desc-erro = RowErrors.errorDescription.
            END.  
            
            EMPTY TEMP-TABLE RowErrors.

            CREATE RowErrors.
            ASSIGN RowErrors.ErrorNumber = tt-retorno.l-erro
                   RowErrors.ErrorDescription = tt-retorno.desc-erro
                   RowErrors.ErrorHelp = tt-retorno.desc-erro
                   RowErrors.ErrorSubType = "ERROR".              
            
            
            oResponse = NEW JsonAPIResponse(jsonInput).
            oResponse:setHasNext(FALSE).
            oResponse:setStatus(400).
            oResponse:setRowErrors(JsonAPIUtils:convertTempTableToJsonObject(TEMP-TABLE RowErrors:HANDLE):getJsonArray("RowErrors")).
            jsonOutput = oResponse:createJsonResponse().
            
            UNDO , LEAVE.
        END.
    END.
    
    IF VALID-HANDLE(hApi) THEN
        DELETE PROCEDURE hApi.
    
    jsonOutput = NEW JSONObject().
    
    If Return-value = "OK" Then Do:
         jsonOutput:ADD("message","Movimento integrado com sucesso").
    End.
END.

PROCEDURE piCriaErro:
    DEF INPUT PARAM c-mensagem AS CHAR NO-UNDO.
    DEF INPUT PARAM c-help     AS CHAR NO-UNDO.
    DEF INPUT PARAM i-erro     AS INT  NO-UNDO.

    IF c-help = "" THEN
        ASSIGN c-help = c-mensagem.

    CREATE RowErrors.
    ASSIGN RowErrors.errorNumber      = i-erro
           RowErrors.errorDescription = c-mensagem
           RowErrors.errorType        = "ERROR":u
           RowErrors.errorHelp        = c-help.
END PROCEDURE.

PROCEDURE piCriaMovimento:


    
    
    FOR EACH produtos
        WHERE produtos.tipo_movimento = "S":

        FIND FIRST ITEM NO-LOCK
            WHERE ITEM.it-codigo = STRING(produtos.produto) NO-ERROR.
        IF NOT AVAIL ITEM THEN DO:
            RUN piCriaErro(INPUT "Produto inv†ido.",
                           INPUT "",
                           INPUT 17006).
            RETURN "NOK".
        END.
           
        FIND FIRST ems2mult.estabelec NO-LOCK
            WHERE estabelec.cgc = messagecontent.cnpj_empresa NO-ERROR.
        IF NOT AVAIL estabelec THEN DO:
            RUN piCriaErro(INPUT "CNPJ Empresa inv†ido.",
                           INPUT "",
                           INPUT 17006).
            RETURN "NOK".
        END. 
        
        FIND FIRST deposito NO-LOCK
            WHERE trim(SUBSTRING(deposito.char-1, 120,10)) = trim(STRING(produtos.CENTRO_ESTOQUE)) NO-ERROR.
            
        IF NOT AVAIL deposito THEN
        DO:
            RUN piCriaErro(INPUT "Dep¢sito de saida n∆o encontrado.",
                           INPUT "",
                           INPUT 17005).
            RETURN "NOK".
            
        END.
    
        CREATE tt-movto.
        ASSIGN
            tt-movto.cod-versao-integracao = 1
            tt-movto.cod-prog-orig  = "MovimentoEstoque"
            tt-movto.dt-trans       = messagecontent.dataemissao
            tt-movto.lote           = produtos.lote
            tt-movto.dt-vali-lote   = produtos.datavalidade
            tt-movto.nro-docto      = ""
            tt-movto.serie          = ""
            tt-movto.cod-depos      = deposito.cod-depos
            tt-movto.cod-localiz    = ""
            tt-movto.cod-estabel    = estabelec.cod-estabel
            tt-movto.it-codigo      = ITEM.it-codigo
            tt-movto.quantidade     = produtos.quantidade_convertida
            tt-movto.un             = item.un
            tt-movto.tipo-trans     = 2       
            tt-movto.esp-docto      = 33      
            tt-movto.ct-codigo      = "91107003"
            tt-movto.sc-codigo      = ""
            tt-movto.usuario        = "rpw"
            .    
 
    END.
    FOR EACH produtos
        WHERE produtos.tipo_movimento = "E":
        
        FIND FIRST deposito NO-LOCK
            WHERE trim(SUBSTRING(deposito.char-1, 120,10)) = trim(STRING(produtos.CENTRO_ESTOQUE)) NO-ERROR.
            
        IF NOT AVAIL deposito THEN
        DO:
            RUN piCriaErro(INPUT "Dep¢sito de entrada n∆o encontrado.",
                           INPUT "",
                           INPUT 17006).
            RETURN "NOK".
            
        END.        

    
        CREATE tt-movto.
        ASSIGN
            tt-movto.cod-versao-integracao = 1
            tt-movto.cod-prog-orig  = "MovimentoEstoque"
            tt-movto.dt-trans       = messagecontent.dataemissao
            tt-movto.lote           = produtos.lote
            tt-movto.dt-vali-lote   = produtos.datavalidade
            tt-movto.nro-docto      = ""
            tt-movto.serie          = ""
            tt-movto.cod-depos      = deposito.cod-depos
            tt-movto.cod-localiz    = ""
            tt-movto.cod-estabel    = estabelec.cod-estabel
            tt-movto.it-codigo      = ITEM.it-codigo
            tt-movto.quantidade     = produtos.quantidade_convertida
            tt-movto.un             = item.un
            tt-movto.tipo-trans     = 1       
            tt-movto.esp-docto      = 33  
            tt-movto.Ct-codigo      = "91107003"
            tt-movto.Sc-codigo      = ""
            tt-movto.usuario        = "rpw"
            .                
    END.
    
    
    RETURN "OK".
END PROCEDURE.

