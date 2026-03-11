//USING Progress.Json.ObjectModel.*.

USING Progress.Json.ObjectModel.JsonArray.
USING Progress.Json.ObjectModel.JsonObject.
USING Progress.Json.ObjectModel.JsonDataType.
USING Progress.Json.ObjectModel.ObjectModelParser.

{utp/ut-api.i}
{utp/ut-api-action.i pi-gera-medicao POST /~* }

{utp/ut-api-notfound.i}

{method/dbotterr.i} /*RowErrors*/

def temp-table tt-erro no-undo
    field i-sequen as int             
    field cd-erro  as int
    field mensagem as char format "x(255)"
    .

DEF TEMP-TABLE tt-medicao-input NO-UNDO SERIALIZE-NAME "medicao"
    FIELD nr-contrato     LIKE medicao-contrat.nr-contrato
    FIELD hra-medicao     LIKE medicao-contrat.hra-medicao
    FIELD dat-medicao     LIKE medicao-contrat.dat-medicao
    FIELD responsavel     LIKE medicao-contrat.responsavel
    FIELD usuar-trans       AS CHAR
    FIELD val-medicao     LIKE medicao-contrat.val-medicao
    FIELD PERIODO           AS CHAR
    FIELD DATA-VENCIMENTO   AS DATE
    .
    
DEF TEMP-TABLE tt-itens-input NO-UNDO SERIALIZE-NAME "itens"
    FIELD nr-contrato     LIKE medicao-contrat.nr-contrato //SERIALIZE-HIDDEN
    FIELD ITEM              AS CHAR
    FIELD VALOR             AS DECIMAL
    FIELD CONTA             AS CHAR
    FIELD PERCENTUAL        AS INTEGER
    .

DEFINE DATASET dsMedicao FOR tt-medicao-input , tt-itens-input
    DATA-RELATION r1 FOR tt-medicao-input, tt-itens-input
        RELATION-FIELDS(nr-contrato,nr-contrato) NESTED
        .

DEF TEMP-TABLE tt-medicao NO-UNDO LIKE medicao-contrat.
DEF TEMP-TABLE tt-rateio-medicao NO-UNDO LIKE matriz-rat-med.
    
DEFINE VARIABLE c-retorno-contrato AS CHARACTER NO-UNDO.
def var l-erro                     as logical   no-undo.
DEFINE VARIABLE l-ordem            AS LOGICAL   NO-UNDO.
DEFINE VARIABLE de-qtd-total       AS DECIMAL   NO-UNDO.
DEFINE VARIABLE Numero_Parcelas    AS INTEGER   NO-UNDO.
DEFINE VARIABLE i-parcelas         AS INTEGER   NO-UNDO.
DEFINE VARIABLE dt-vencimento      AS DATE      NO-UNDO.   /* Data de vencimento de cada parcela */
DEFINE VARIABLE dt-periodo-aux     AS DATE      NO-UNDO.
DEFINE VARIABLE valor-parcela      AS DECIMAL   NO-UNDO.
DEFINE VARIABLE i-seq-aux          AS INTEGER   NO-UNDO.
DEFINE VARIABLE i-parcela          AS INTEGER   NO-UNDO.
DEFINE VARIABLE l-gera-pendencia   AS LOGICAL   NO-UNDO.
DEFINE VARIABLE l-lib-medicao      AS LOGICAL   NO-UNDO.
DEFINE VARIABLE i-empresa          LIKE ems2mult.empresa.ep-codigo NO-UNDO.
DEFINE NEW SHARED VARIABLE c-cod-estabel LIKE ems2mult.estabelec.cod-estabel.
DEF NEW GLOBAL SHARED VAR c-seg-usuario  AS CHAR NO-UNDO.
def new global shared var r-num-ped      as rowid no-undo.

FUNCTION LongCharToJsonObject RETURN JsonObject PRIVATE (INPUT jsonChar AS LONGCHAR):
    
    DEFINE VARIABLE jsonOutput AS JsonObject        NO-UNDO.
    DEFINE VARIABLE objParse   AS ObjectModelParser NO-UNDO.

    ASSIGN jsonOutput = NEW JsonObject()
           objParse   = NEW ObjectModelParser()
           jsonOutput = CAST(objParse:Parse(jsonChar), JsonObject).

    DELETE OBJECT objParse.

    RETURN jsonOutput.

END FUNCTION.

PROCEDURE pi-gera-medicao:

    DEF INPUT  PARAM jsonInput  AS JsonObject NO-UNDO.
    DEF OUTPUT PARAM jsonOutput AS JsonObject NO-UNDO.
    //DEF INPUT  PARAMETER TABLE FOR tt-mp-titulos-baixa-ok. 
    
    DEFINE VARIABLE oResponse   AS JsonAPIResponse  NO-UNDO.
    DEFINE VARIABLE c-it-codigo AS CHARACTER        NO-UNDO.
    DEFINE VARIABLE c-usuar-ant AS CHARACTER        NO-UNDO.
    
    DEFINE VARIABLE i-seq-medicao-contrat LIKE medicao-contrat.num-seq-medicao NO-UNDO.        

    DEFINE VARIABLE oRequestParser AS JsonAPIRequestParser NO-UNDO.
    DEFINE VARIABLE lcPayload      AS LONGCHAR             NO-UNDO.
    DEFINE VARIABLE lcDados        AS LONGCHAR             NO-UNDO.
    
    DEFINE VARIABLE l-pendente AS LOGICAL  NO-UNDO.

    oRequestParser = NEW JsonAPIRequestParser(jsonInput).
     
    ASSIGN lcPayload = oRequestParser:getPayloadLongChar().

    DEF VAR jsonAux  AS JsonObject NO-UNDO.
    
    jsonAux = LongCharToJsonObject(lcPayload).
    
    jsonAux:WRITE(lcDados).
    
    MESSAGE "JSON Dados: "
            STRING(lcDados)
        VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.

    .MESSAGE string(jsonAux:GetJsonArray("tt-medicao"):getJsonText())
        VIEW-AS ALERT-BOX INFO BUTTONS OK.
                       
    DATASET dsMedicao:HANDLE:READ-JSON('JsonObject',jsonAux).
    
    jsonOutput = NEW JSONObject().
    
    //log-manager:write-message("KML - dentro for each - tt-medicao.nr-contrato - " + string(tt-medicao.nr-contrato)) no-error.
    //log-manager:write-message("KML - dentro for each - tt-medicao.emissao - " + string(tt-medicao.data-emissao)) no-error.*/
    IF  CAN-FIND(FIRST tt-medicao-input) THEN DO:        
    
        bloco_input:
        FOR EACH tt-medicao-input:
        
            FOR FIRST contrato-for NO-LOCK
                WHERE contrato-for.nr-contrato = tt-medicao-input.nr-contrato:
            END.
            
            IF  NOT AVAIL contrato-for THEN DO:
                
                RUN pi-retorna-erro (17006, "Contrato " + STRING(tt-medicao-input.nr-contrato) + " n∆o encontrado!").
                
                LEAVE bloco_input.
            END.

            FOR EACH tt-itens-input 
               WHERE tt-itens-input.nr-contrato = tt-medicao-input.nr-contrato:
               
               ASSIGN c-it-codigo = "".
               CASE tt-itens-input.item:
                    WHEN "ALUGUEL PF"   THEN ASSIGN c-it-codigo = "CONT.007".
                    WHEN "ALUGUEL PJ"   THEN ASSIGN c-it-codigo = "CONT.0070".
                    WHEN "IPTU"         THEN ASSIGN c-it-codigo = "CONT.003".
                    WHEN "ENERGIA"      THEN ASSIGN c-it-codigo = "CONT.002".
                    WHEN "AGUA"         THEN ASSIGN c-it-codigo = "CONT.001".
                    WHEN "FC"           THEN ASSIGN c-it-codigo = "CONT.005".
                    WHEN "SEGURO"       THEN ASSIGN c-it-codigo = "CONT.008".
                    WHEN "TAXA DE LIXO" THEN ASSIGN c-it-codigo = "CONT.006".
                    WHEN "CONDOMINIO"   THEN ASSIGN c-it-codigo = "CONT.004".
                END.
             
                IF  NOT CAN-FIND (FIRST item-contrat NO-LOCK
                                  WHERE item-contrat.nr-contrato = tt-medicao-input.nr-contrato
                                    AND item-contrat.it-codigo   = c-it-codigo) THEN DO:
                    
                    RUN pi-retorna-erro (17006, "Item " + c-it-codigo + " n∆o encontrado para o contrato " + STRING(tt-medicao-input.nr-contrato)).
                    
                    NEXT bloco_input.
                END.
                
                FOR FIRST item-contrat NO-LOCK
                    WHERE item-contrat.nr-contrato = tt-medicao-input.nr-contrato
                      AND item-contrat.it-codigo   = c-it-codigo:
                    
                END.        
                    
                CREATE tt-medicao.
                BUFFER-COPY tt-medicao-input TO tt-medicao.
                BUFFER-COPY contrato-for     TO tt-medicao.
                BUFFER-COPY item-contrat     TO tt-medicao.
                
                ASSIGN tt-medicao.dat-prev-medicao = tt-medicao-input.DATA-VENCIMENTO
                       //tt-medicao.val-previsto     = tt-medicao-input.val-medicao
                       tt-medicao.val-previsto     = tt-itens-input.VALOR.
                
                ASSIGN i-seq-medicao-contrat = 1.
                
                FOR LAST medicao-contrat OF item-contrat NO-LOCK:
                
                    ASSIGN i-seq-medicao-contrat = medicao-contrat.num-seq-medicao + 1.
                END.
                
                ASSIGN tt-medicao.num-seq-medicao = i-seq-medicao-contrat.
                IF  tt-medicao-input.usuar-trans <> '' THEN
                    ASSIGN tt-medicao-input.responsavel = tt-medicao-input.usuar-trans.
                
                CREATE tt-rateio-medicao.
                BUFFER-COPY tt-medicao     TO tt-rateio-medicao.
                BUFFER-COPY tt-itens-input TO tt-rateio-medicao.
                
                ASSIGN tt-rateio-medicao.conta-contabil = tt-itens-input.conta
                       tt-rateio-medicao.perc-rateio    = tt-itens-input.percentual
                       .
            END.    
        END. //bloco_input
        
        IF  CAN-FIND (FIRST RowErrors) OR
            NOT CAN-FIND(FIRST tt-medicao) THEN DO:
            
            IF  NOT CAN-FIND(FIRST RowErrors) THEN
                RUN pi-retorna-erro (17006, "Mediá∆o n∆o gerada!").
            
        END.
        ELSE DO:
            run cnp/cnapi040.p (input table tt-medicao,
                                input table tt-rateio-medicao,
                                input 0,
                               output table tt-erro).
                            
            RELEASE medicao-contrat NO-ERROR.
            
            FOR EACH tt-erro:        
                RUN pi-retorna-erro (tt-erro.cd-erro, tt-erro.mensagem).
            END.

            IF  NOT CAN-FIND (FIRST tt-erro) THEN DO:

                run cdp/cdapi172.p (10, rowid(contrato-for), output l-pendente).
                IF NOT l-pendente THEN DO:

                    run cdp/cdapi172.p (8, rowid(contrato-for), output l-pendente).
                    IF NOT l-pendente THEN DO:

                        find first param-aprov no-lock no-error.
                        
                        if  param-aprov.aprova-medic AND 
                            param-aprov.aprova-total-medic then do:

                            FOR LAST medicao-contrat OF item-contrat NO-LOCK:
                            
                            END.

                            run cdp/cdapi172.p (12, ROWID(medicao-contrat), OUTPUT l-pendente).

                            ASSIGN c-cod-estabel = medicao-contrat.cod-estabel.
                            IF  medicao-contrat.responsavel <> '' THEN
                                ASSIGN c-usuar-ant   = c-seg-usuario
                                       c-seg-usuario = medicao-contrat.responsavel.

                            RUN lap/mlaapi010l.p (INPUT  1,
                                                  INPUT  ROWID(medicao-contrat),
                                                  OUTPUT TABLE tt-erro).
                                                  
                            IF  medicao-contrat.responsavel <> '' THEN
                                ASSIGN c-seg-usuario = c-usuar-ant.

                            FOR EACH tt-erro:
                            
                                RUN pi-retorna-erro (tt-erro.cd-erro, tt-erro.mensagem).
                            END.                                          
                        END.
                    END.
                END.    
            END.
        END.
    END.
    ELSE DO: //else if can-find tt-medicao-input
        RUN pi-retorna-erro (17006, "N∆o enviado mediá∆o para integraá∆o!").
    END.
    
    IF  CAN-FIND (FIRST RowErrors) THEN DO:
    
        oResponse = NEW JsonAPIResponse(jsonInput).
        oResponse:setHasNext(FALSE).
        oResponse:setStatus(400).
        oResponse:setRowErrors(JsonAPIUtils:convertTempTableToJsonObject(TEMP-TABLE RowErrors:HANDLE):getJsonArray("RowErrors")).
        jsonOutput = oResponse:createJsonResponse().
        
        RETURN "NOK".
    END.
    ELSE
        jsonOutput:ADD("retorno","Mediá∆o integrada").

    RETURN "OK".
    
END PROCEDURE.

PROCEDURE pi-retorna-erro:

    DEFINE INPUT PARAMETER pCodErro  AS INT  NO-UNDO.
    DEFINE INPUT PARAMETER pMensagem AS CHAR NO-UNDO.
    
    CREATE RowErrors.
    ASSIGN RowErrors.ErrorNumber      = pCodErro
           RowErrors.ErrorDescription = pMensagem
           RowErrors.ErrorHelp        = STRING(pCodErro) + " - " + pMensagem
           RowErrors.ErrorSubType     = "ERROR".
    
END PROCEDURE.









