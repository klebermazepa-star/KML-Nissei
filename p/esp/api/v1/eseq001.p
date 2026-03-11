//USING Progress.Json.ObjectModel.*.

USING Progress.Json.ObjectModel.JsonArray.
USING Progress.Json.ObjectModel.JsonObject.
USING Progress.Json.ObjectModel.JsonDataType.
USING Progress.Json.ObjectModel.ObjectModelParser.

{utp/ut-api.i}
{utp/ut-api-action.i piGeraEmbarque  POST  /geraembarque/~* }
{utp/ut-api-notfound.i}
{method/dbotterr.i} /*RowErros*/

{eqp/eqapi300.i}
{cdp/cd0667.i -embarque}

DEFINE VARIABLE hApi         AS HANDLE      NO-UNDO.
DEFINE VARIABLE h-bodi154can AS HANDLE      NO-UNDO.
DEFINE VARIABLE h-bodi159com AS HANDLE      NO-UNDO.
DEFINE VARIABLE c-quantidade AS DEC         NO-UNDO.

DEFINE NEW GLOBAL SHARED VARIABLE c-seg-usuario AS CHARACTER NO-UNDO.

DEFINE BUFFER bf-embarque   FOR embarque.
DEFINE BUFFER bf-ped-venda  FOR ped-venda.
DEFINE BUFFER bf-ped-item   FOR ped-item.

DEFINE TEMP-TABLE MessageContent NO-UNDO
    FIELD REGISTRO_CONTROLE            AS INTEGER
    FIELD DATAEMISSAO                  AS DATETIME
    FIELD QUANTIDADE_VOLUMES_ESPERADOS AS INTEGER
    FIELD FINALIZADO                   AS CHARACTER
    .

DEFINE TEMP-TABLE VOLUMES NO-UNDO
    FIELD REGISTRO_CONTROLE   AS INTEGER
    FIELD CODIGO_VOLUME       AS INTEGER
    FIELD QUANTIDADE_VOLUMES  AS INTEGER
    FIELD VOLUME_UNICO        AS CHARACTER
    FIELD TIPO_VOLUME         AS CHARACTER
    FIELD GRUPO_FATURAMENTO   AS INTEGER
    .

DEFINE TEMP-TABLE PRODUTOS NO-UNDO
    FIELD CODIGO_VOLUME         AS INTEGER
    FIELD PRODUTO               AS INTEGER
    FIELD BARRAS                AS CHARACTER
    FIELD LOTE                  AS CHARACTER
    FIELD DATAVALIDADE          AS DATETIME
    FIELD DATAFABRICACAO        AS DATETIME
    FIELD QUANTIDADE_CONVERTIDA AS INTEGER
    .
    
DEFINE TEMP-TABLE tt-retorno NO-UNDO
    FIELD l-erro    AS INT 
    field desc-erro as char format "x(60)".
    
def temp-table tt-aloc-man-aux no-undo
    field cdd-embarq-aux   as dec
    field nr-resumo-aux    as int
    field nome-abrev-aux   as char
    field nr-pedcli-aux    as char
    field nr-sequencia-aux as int
    field it-codigo-aux    as char
    field cod-estabel-aux  as char
    field cod-depos-aux    as char
    field cod-localiz-aux  as char
    field lote-aux         as char
    field cod-refer-aux    as char
    field qt-a-alocar-aux  as deci
    field i-sequen-aux     as int
    field nr-entrega-aux   as int.    
    
DEF DATASET dsEmbarque FOR MessageContent, VOLUMES, PRODUTOS 
    DATA-RELATION r1 FOR MessageContent, VOLUMES
        RELATION-FIELDS(REGISTRO_CONTROLE,REGISTRO_CONTROLE) NESTED
    DATA-RELATION r2 FOR VOLUMES, PRODUTOS
        RELATION-FIELDS(CODIGO_VOLUME,CODIGO_VOLUME) NESTED.

FUNCTION LongCharToJsonObject RETURN JsonObject PRIVATE (INPUT jsonChar AS LONGCHAR):
    
    DEFINE VARIABLE jsonOutput AS JsonObject        NO-UNDO.
    DEFINE VARIABLE objParse   AS ObjectModelParser NO-UNDO.

    ASSIGN jsonOutput = NEW JsonObject()
           objParse   = NEW ObjectModelParser()
           jsonOutput = CAST(objParse:Parse(jsonChar), JsonObject).

    DELETE OBJECT objParse.

    RETURN jsonOutput.

END FUNCTION.

PROCEDURE piGeraEmbarque:
    DEF INPUT  PARAM jsonInput  AS JsonObject NO-UNDO.
    DEF OUTPUT PARAM jsonOutput AS JsonObject NO-UNDO.

    DEFINE VARIABLE oRequestParser AS JsonAPIRequestParser NO-UNDO.
    DEFINE VARIABLE lcPayload      AS LONGCHAR             NO-UNDO.
    DEFINE VARIABLE oResponse      AS JsonAPIResponse      NO-UNDO.

    DEFINE VARIABLE v-embarque AS INTEGER NO-UNDO.
    
    oRequestParser = NEW JsonAPIRequestParser(jsonInput).
     
    ASSIGN lcPayload = oRequestParser:getPayloadLongChar().

    DEF VAR jsonAux  AS JsonObject NO-UNDO.
    jsonAux = LongCharToJsonObject(lcPayload).

    /*MESSAGE string(jsonAux:GetJsonArray("PEDIDOS_VENDA"):getJsonText())
        VIEW-AS ALERT-BOX INFO BUTTONS OK.*/

    DATASET dsEmbarque:HANDLE:READ-JSON('JsonObject',jsonAux).

    oResponse   = NEW JsonAPIResponse(jsonInput).
    oResponse:setHasNext(FALSE).

    oResponse:setStatus(200).
    jsonOutput = oResponse:createJsonResponse().

    alocacao: DO TRANSACTION ON ERROR UNDO, LEAVE ON STOP UNDO, LEAVE:
        RUN piInicializaBO.
             
        FOR FIRST MessageContent:
            //RUN piCriaEmbarque(OUTPUT v-embarque).
            RUN piAdicionaEmbarque(OUTPUT v-embarque).
            
           /* //bloco inteiro de teste
            FOR EACH produtos:
                   
                MESSAGE "Entrou antes SALDO KML 123"
                    VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
            
                FIND FIRST saldo-estoq NO-LOCK
                    WHERE saldo-estoq.cod-depos = "EXP"
                    AND   saldo-estoq.cod-estabel = bf-ped-venda.cod-estabel
                    AND   saldo-estoq.cod-localiz = "" 
                    AND   saldo-estoq.lote        = produtos.lote
                    AND   saldo-estoq.it-codigo   = string(produtos.produto) 
                    AND   saldo-estoq.cod-refer   = "" NO-ERROR.
                    
                IF NOT AVAIL saldo-estoq  THEN
                DO:
                
                    MESSAGE "Entrou produto sem lote"
                        VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.

                    CREATE RowErrors.
                    ASSIGN RowErrors.ErrorNumber = 17006
                           RowErrors.ErrorDescription = "Produto sem Lote Ativo"
                           RowErrors.ErrorHelp = "Produto sem Lote Ativo - " + produtos.lote + " - Item " +  STRING(produtos.produto)
                           RowErrors.ErrorSubType = "ERROR".
                    
                    oResponse = NEW JsonAPIResponse(jsonInput).
                    oResponse:setHasNext(FALSE).
                    oResponse:setStatus(400).
                    oResponse:setRowErrors(JsonAPIUtils:convertTempTableToJsonObject(TEMP-TABLE RowErrors:HANDLE):getJsonArray("RowErrors")).
                    jsonOutput = oResponse:createJsonResponse().

                    RUN piFinalizaBO.
                    UNDO alocacao, RETURN "NOK".
                    
                END.
            END.
            
            //fim bloco teste
            */
            
            IF RETURN-VALUE = "NOK" THEN DO:
            
                FIND FIRST tt-retorno NO-LOCK NO-ERROR.
            
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

                RUN piFinalizaBO.
                UNDO alocacao, RETURN "NOK".
            END.
            ELSE DO:
                FOR EACH produtos:
                
                    ASSIGN c-quantidade = 0.
                
                    MESSAGE "Entrou antes SALDO KML 123"
                        VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
                
                    FIND FIRST saldo-estoq NO-LOCK
                        WHERE saldo-estoq.cod-depos = "EXP"
                        AND   saldo-estoq.cod-estabel = bf-ped-venda.cod-estabel
                        AND   saldo-estoq.cod-localiz = "" 
                        AND   saldo-estoq.lote        = produtos.lote
                        AND   saldo-estoq.it-codigo   = string(produtos.produto) 
                        AND   saldo-estoq.cod-refer   = "" NO-ERROR.
                        
                    IF AVAIL saldo-estoq THEN
                    DO:
                        
                        ASSIGN c-quantidade = saldo-estoq.qtidade-atu - saldo-estoq.qt-alocada.
                        
                    END.
           
                    IF NOT AVAIL saldo-estoq OR (saldo-estoq.qtidade-atu < produtos.QUANTIDADE_CONVERTIDA OR c-quantidade < produtos.QUANTIDADE_CONVERTIDA)   THEN
                    DO:
                    
                        MESSAGE "Entrou produto sem lote"
                            VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
          
                        CREATE RowErrors.
                        ASSIGN RowErrors.ErrorNumber = 17006
                               RowErrors.ErrorDescription = "Produto sem Saldo/Lote Ativo"
                               RowErrors.ErrorHelp = "Produto sem Saldo/Lote Ativo - " + produtos.lote + " - Item " +  STRING(produtos.produto) + " - Quantidade Pedida " + STRING(produtos.QUANTIDADE_CONVERTIDA) + " - Quantidade Atual " + string(c-quantidade)
                               RowErrors.ErrorSubType = "ERROR".
                        
                        oResponse = NEW JsonAPIResponse(jsonInput).
                        oResponse:setHasNext(FALSE).
                        oResponse:setStatus(400).
                        oResponse:setRowErrors(JsonAPIUtils:convertTempTableToJsonObject(TEMP-TABLE RowErrors:HANDLE):getJsonArray("RowErrors")).
                        jsonOutput = oResponse:createJsonResponse().

                        RUN piFinalizaBO.
                        UNDO alocacao, RETURN "NOK".
                        
                    END.
                    
                          
                    MESSAGE "ANTES DE DAR RUN piALOCAR KML " SKIP
                             v-embarque SKIP
                             produtos.produto SKIP
                             produtos.lote
                             saldo-estoq.cod-depos
                        VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
                    
                    RUN piAlocar(INPUT v-embarque).
                    
                    MESSAGE "KML AP‡S ALOCAR" SKIP
                             RETURN-VALUE
                        VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
                    
                    IF RETURN-VALUE = "NOK"  THEN DO:
                        
                        FIND FIRST tt-retorno NO-LOCK NO-ERROR.
            
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

                        RUN piFinalizaBO.
                        UNDO alocacao, RETURN "NOK".                        
                    END.
                END.
                
                IF RETURN-VALUE = "NOK"  THEN DO:
            
                    FIND FIRST tt-retorno NO-LOCK NO-ERROR.

                    CREATE RowErrors.
                    ASSIGN RowErrors.ErrorNumber      = tt-retorno.l-erro
                           RowErrors.ErrorDescription = tt-retorno.desc-erro
                           RowErrors.ErrorHelp        = tt-retorno.desc-erro
                           RowErrors.ErrorSubType     = "ERROR".
                            
                    oResponse = NEW JsonAPIResponse(jsonInput).
                    oResponse:setHasNext(FALSE).
                    oResponse:setStatus(400).
                    oResponse:setRowErrors(JsonAPIUtils:convertTempTableToJsonObject(TEMP-TABLE RowErrors:HANDLE):getJsonArray("RowErrors")).
                    jsonOutput = oResponse:createJsonResponse().

                    RUN piFinalizaBO.
                    UNDO alocacao, RETURN "NOK".                        
                END.
                
                IF RETURN-VALUE = "OK"  THEN
                DO:
                    MESSAGE "Chegou no fim 05 KML"
                             v-embarque
                    VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
                
                    jsonOutput:ADD("Retorno","Embarque criado com sucesso!").
                    jsonOutput:ADD("Embarque",v-embarque).
                    
                END.

            END.
        END.
    END.
END.

PROCEDURE piInicializaBO:
    IF NOT VALID-HANDLE(hApi) THEN
        RUN eqp/eqapi300.p PERSISTENT SET hApi.

    IF NOT VALID-HANDLE (h-bodi154can) THEN
        RUN dibo/bodi154can.p PERSISTENT SET h-bodi154can.
        
     IF NOT VALID-HANDLE (h-bodi159com) THEN
         RUN dibo/bodi159com.p PERSISTENT SET h-bodi159com.
        
    RETURN "OK":u. 
END PROCEDURE.

PROCEDURE piFinalizaBO:
    IF VALID-HANDLE(hApi) THEN
        DELETE PROCEDURE hApi.
        
    IF VALID-HANDLE(h-bodi154can) THEN
        DELETE PROCEDURE h-bodi154can.
        
    IF VALID-HANDLE(h-bodi159com) THEN
        DELETE PROCEDURE h-bodi159com.    
               
END PROCEDURE.

PROCEDURE piCriaErro:
    DEF INPUT PARAM c-mensagem AS CHAR NO-UNDO.
    DEF INPUT PARAM c-help     AS CHAR NO-UNDO.
    DEF INPUT PARAM i-erro     AS INT  NO-UNDO.

    IF c-help = "" THEN
        ASSIGN c-help = c-mensagem.

/*     CREATE RowErrors.                              */
/*     ASSIGN RowErrors.errorNumber      = i-erro     */
/*            RowErrors.errorDescription = c-mensagem */
/*            RowErrors.errorType        = "ERROR":u  */
/*            RowErrors.errorHelp        = c-help.    */

    CREATE tt-retorno.
    ASSIGN tt-retorno.l-erro    = i-erro
           tt-retorno.desc-erro = c-mensagem.
    
END PROCEDURE.

PROCEDURE piAdicionaEmbarque:
    DEFINE OUTPUT PARAMETER p-embarque AS INTEGER NO-UNDO.
    DEFINE VARIABLE i-cod-sit-aval     AS INT     NO-UNDO.
    DEFINE VARIABLE l-item-cancelado   AS LOGICAL NO-UNDO.
    
    
    
    EMPTY TEMP-TABLE tt-embarque.

    FIND FIRST bf-ped-venda NO-LOCK
        WHERE bf-ped-venda.nr-pedido = messagecontent.registro_controle NO-ERROR.
    
    IF NOT AVAIL bf-ped-venda THEN DO:
        RUN piCriaErro (INPUT SUBSTITUTE("Pedido &1 n∆o encontrado",messagecontent.registro_controle),
                        INPUT "",
                        INPUT 17006).
        RETURN "NOK":u.
    END.
    
    ASSIGN i-cod-sit-aval = bf-ped-venda.cod-sit-aval
           l-item-cancelado = NO.
     
               

    
    FOR EACH bf-ped-item OF bf-ped-venda NO-LOCK:
    
        MESSAGE "PROCURANDO ITEM KML"
                bf-ped-item.it-codigo
            VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.

        IF NOT CAN-FIND(FIRST produtos
                        WHERE produtos.produto = INT(bf-ped-item.it-codigo)) THEN DO:
                        
            MESSAGE "Antes pi cancela KML"
                VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
                        
            RUN piCancelaItem.
            
            ASSIGN l-item-cancelado = YES.
            
            
        END.
        
    END.
    
    IF l-item-cancelado = YES THEN
    DO:
    
        RUN piInicializaBo.
        run completeOrder in h-bodi159com (INPUT ROWID (bf-ped-venda) ,
                                           output table rowErrors).
                                           
        FOR FIRST rowErrors
            WHERE RowErrors.errorNumber <> 18295:
        
            RUN piCriaErro(INPUT RowErrors.errorDescription,
                           INPUT "",
                           INPUT RowErrors.errorNumber).
            
            RUN piFinalizaBO.
            RETURN "NOK".
        
        END.
    
        ASSIGN bf-ped-venda.cod-sit-aval = i-cod-sit-aval.
        
    END.
       
    CREATE tt-embarque.

    FIND LAST bf-embarque
        WHERE bf-embarque.cdd-embarq > 0 NO-LOCK NO-ERROR.

    ASSIGN
        tt-embarque.nr-embarque = 0
        tt-embarque.dt-embarque = TODAY
        tt-embarque.cod-estabel = bf-ped-venda.cod-estabel
        tt-embarque.ind-oper    = 1
        tt-embarque.cdd-embarq  = IF AVAIL bf-embarque THEN bf-embarque.cdd-embarq + 1 ELSE 1
        .

    RUN pi-recebe-tt-embarque IN hApi (TABLE tt-embarque).

    RUN pi-trata-tt-embarque  IN hApi ("notShow", YES).

    FIND FIRST embarque
        WHERE embarque.cdd-embarq = tt-embarque.cdd-embarq NO-LOCK NO-ERROR.

    IF NOT AVAIL embarque THEN DO:
        RUN piCriaErro (INPUT SUBSTITUTE("Embarque &1 n∆o encontrado",tt-embarque.cdd-embarq),
                        INPUT "",
                        INPUT 17006).
        RETURN "NOK":u.
    END.
    ELSE
        ASSIGN p-embarque = embarque.cdd-embarq.

    RUN piFinalizaBO.
    RETURN "OK".
END PROCEDURE.

PROCEDURE piAlocar:
    DEFINE INPUT PARAMETER p-embarque AS INTEGER NO-UNDO.
    
    EMPTY TEMP-TABLE tt-aloc-man.
        
    FIND FIRST bf-ped-venda NO-LOCK                                                      
        WHERE bf-ped-venda.nr-pedido = messagecontent.registro_controle NO-ERROR. //teste 
    
    FOR EACH ped-item OF bf-ped-venda
        WHERE ped-item.cod-sit-item <= 2
        AND   ped-item.it-codigo     = STRING(produtos.produto) NO-LOCK,
        EACH ped-ent OF ped-item
        WHERE ped-ent.cod-sit-ent <= 2  // "alterado para 3 para teste mas e 2"
        //AND   ped-ent.dt-entrega  <= TODAY 
        //AND   (ped-ent.qt-pedida - ped-ent.qt-atendida) > 0
        NO-LOCK:
        
        IF (ped-ent.qt-pedida - ped-ent.qt-atendida) <= 0  THEN
        DO:
            
            RUN piCriaErro (INPUT "Pedido sem saldo para o item",
                            INPUT "",
                            INPUT 17001).
        
            RETURN "NOK".
           
        END.
        
        MESSAGE  "ped_item KML" SKIP
                 ped-item.it-codigo SKIP
                 produtos.lote
            VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
        
        CREATE tt-aloc-man.
        ASSIGN
            tt-aloc-man.cdd-embarq   = p-embarque
            tt-aloc-man.nome-abrev   = ped-ent.nome-abrev
            tt-aloc-man.nr-pedcli    = ped-ent.nr-pedcli
            tt-aloc-man.nr-sequencia = ped-ent.nr-sequencia
            tt-aloc-man.it-codigo    = ped-ent.it-codigo
            tt-aloc-man.nr-entrega   = ped-ent.nr-entrega
            tt-aloc-man.cod-estabel  = bf-ped-venda.cod-estabel
            tt-aloc-man.cod-depos    = "EXP"
            tt-aloc-man.cod-localiz  = ""
            tt-aloc-man.lote         = produtos.lote
            tt-aloc-man.cod-refer    = ped-item.cod-refer
            tt-aloc-man.qt-a-alocar  = produtos.quantidade_convertida
            tt-aloc-man.i-sequen     = ped-item.nr-sequencia.
    END.
    
    FOR EACH tt-aloc-man:
    
        MESSAGE "Dentro tt-aloc-man KML 2" SKIP
                tt-aloc-man.it-codigo SKIP
                tt-aloc-man.lote
            VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
        
        IF NOT AVAIL tt-aloc-man  THEN
        DO:
            RUN piCriaErro (INPUT "Erro criacao",
                            INPUT "",
                            INPUT 17001).
        
            RETURN "NOK".
            
        END.
        
        EMPTY TEMP-TABLE rowErrors.
        
        RUN piInicializaBO.
          
        RUN pi-recebe-tt-aloc-man  IN hApi (INPUT TABLE tt-aloc-man).
             
        RUN pi-trata-tt-aloc-man   IN hApi (TRUE).
        
        
        
        IF CAN-FIND (FIRST rowErrors
                     WHERE RowErrors.ErrorType <> "INTERNAL"
                     AND RowErrors.ErrorSubType = "Error":U) /* AND NOT ped-venda.completo */ THEN DO:
                     
                    RUN piCriaErro(INPUT RowErrors.errorDescription,
                                   INPUT "",
                                   INPUT RowErrors.errorNumber).
                                   
                    RETURN "NOK".                 
        END.
        
        EMPTY TEMP-TABLE tt-embarque.
        
        CREATE tt-embarque.
        ASSIGN tt-embarque.nr-embarque = 0
               tt-embarque.dt-embarque = TODAY
               tt-embarque.cod-estabel = bf-ped-venda.cod-estabel
               tt-embarque.ind-oper    = 1
               tt-embarque.cdd-embarq  = p-embarque.
               
        RUN pi-recebe-tt-embarque IN hApi (TABLE tt-embarque).
       
        RUN pi-encerra-embarque IN hApi(INPUT YES).

        RUN pi-devolve-tt-erro in hApi (OUTPUT TABLE tt-erro-embarque).
        
        FIND FIRST tt-erro-embarque NO-ERROR. 
       
        MESSAGE "KML TT_ERRO" SKIP
                AVAIL tt-erro-embarque 
            VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
        
        
/*         IF CAN-FIND (FIRST rowErrors                                                                   */
/*                      WHERE RowErrors.ErrorType <> "INTERNAL"                                           */
/*                      AND RowErrors.ErrorSubType = "Error":U) /* AND NOT ped-venda.completo */ THEN DO: */
/*                                                                                                        */
/*                     RUN piCriaErro(INPUT RowErrors.errorDescription,                                   */
/*                                    INPUT "",                                                           */
/*                                    INPUT RowErrors.errorNumber).                                       */
/*                                                                                                        */
/*                     RETURN "NOK".                                                                      */
/*         END.                                                                                           */
                
        FOR FIRST tt-erro-embarque:

            RUN piCriaErro (INPUT tt-erro-embarque.mensagem,
                            INPUT "",
                            INPUT tt-erro-embarque.cd-erro).

            RUN piFinalizaBO.
            RETURN "NOK".
        END.
        
        RETURN "OK".
    END.
        
END PROCEDURE.

PROCEDURE piCancelaItem:
    
    RUN setUserLog in h-bodi154can (INPUT c-seg-usuario).
    
    MESSAGE "KML Antes validate"
        VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
    
    RUN validateCancelation in h-bodi154can (INPUT ROWID(bf-ped-item),
                                             INPUT "Cancelamento realizado pela rotina de Alocaá∆o Embarque",
                                             INPUT-OUTPUT TABLE RowErrors).
                                                                               
    IF NOT CAN-FIND (FIRST rowErrors
                     WHERE RowErrors.ErrorType <> "INTERNAL"
                     AND RowErrors.ErrorSubType = "Error":U) THEN DO:
                     
       
        MESSAGE "KML Antes UPDATE CANCELATION" SKIP 
                 bf-ped-item.it-codigo
            VIEW-AS ALERT-BOX INFORMATION BUTTONS OK
            
            .
            
            EMPTY TEMP-TABLE RowErrors.
            
            RUN updateCancelation IN h-bodi154can (INPUT ROWID(bf-ped-item),                                                              
                                                      INPUT "Cancelamento realizado pela rotina de Alocaá∆o Embarque",
                                                      INPUT TODAY,                                                                        
                                                      INPUT 1). 
                                                      //INPUT-OUTPUT TABLE RowErrors). 
                                                      
            MESSAGE "KML DEPOIS UPDATE CANCELATION" SKIP 
                    bf-ped-item.it-codigo SKIP
                    AVAIL RowErrors  
            VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
    END.
   
    IF CAN-FIND (FIRST rowErrors
                     WHERE RowErrors.ErrorType <> "INTERNAL"
                     AND RowErrors.ErrorSubType = "Error":U) /* AND NOT ped-venda.completo */ THEN DO:
                     
        MESSAGE " KML Entrou rowError" SKIP
                 RowErrors.errorDescription
            VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
   
        RUN piCriaErro(INPUT RowErrors.errorDescription,
                       INPUT "",
                       INPUT RowErrors.errorNumber).
                       
        RETURN "NOK".                 
    END.
 
END PROCEDURE.
