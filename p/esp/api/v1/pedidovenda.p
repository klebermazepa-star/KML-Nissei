//USING Progress.Json.ObjectModel.*.

USING Progress.Json.ObjectModel.JsonArray.
USING Progress.Json.ObjectModel.JsonObject.
USING Progress.Json.ObjectModel.JsonDataType.
USING Progress.Json.ObjectModel.ObjectModelParser.

{utp/ut-api.i}
{utp/ut-api-action.i piGeraPedido  POST  /geraPedido/~* }
{utp/ut-api-notfound.i}
{method/dbotterr.i} /*RowErros*/
{dibo/bodi159.i tt-ped-venda}
{dibo/bodi154.i tt-ped-item}

DEFINE TEMP-TABLE pedidos_venda NO-UNDO
    FIELD id              AS INTEGER
    FIELD origem          AS CHARACTER
    FIELD filial_cnpj     AS CHARACTER
    FIELD filial_id       AS CHARACTER
    FIELD data_emissao    AS DATE
    FIELD pedido_tipo     AS INTEGER
    FIELD obs             AS CHARACTER
    FIELD pedido_num      AS Integer 
    FIELD valor_pedido    AS DECIMAL
    FIELD cliente_id      AS CHARACTER
    FIELD entidade_tipo   AS INTEGER
    FIELD base_origem     AS INTEGER
    FIELD pedido_info     AS CHARACTER
    FIELD codigo_etapa    AS INTEGER
    FIELD descricao_etapa AS CHARACTER
    FIELD data_etapa      AS DATETIME
    FIELD ordem_compra_id AS CHARACTER
    FIELD log_status      AS LOGICAL
    FIELD data_criacao    AS DATETIME
    FIELD data_alteracao  AS DATETIME
    .

DEFINE TEMP-TABLE itens NO-UNDO
    FIELD id                    AS INTEGER
    FIELD sequencia_id          AS INTEGER
    FIELD produto_id            AS INTEGER
    FIELD lote_id               AS INTEGER
    FIELD lote                  AS CHARACTER
    FIELD lote_cdi              AS INTEGER
    FIELD lote_quantidade_saida AS DECIMAL
    FIELD documento_num         AS INTEGER
    FIELD numero_fornecedor     AS CHARACTER
    FIELD data_validade         AS DATE
    FIELD data_fabricacao       AS DATE
    FIELD quantidade_convertida AS DECIMAL
    FIELD quantidade_faturar    AS DECIMAL
    FIELD quantidade_reservada  AS DECIMAL
    FIELD tipo_embalagem        AS CHARACTER
    FIELD valor_unitario        AS DECIMAL
    FIELD valor_desconto        AS DECIMAL
    FIELD observacao            AS CHARACTER
    FIELD data_alteracao        AS DATE
    FIELD valor_frete           AS DECIMAL
    FIELD data_entrega          AS DATE
    .
    
DEFINE TEMP-TABLE tt-retorno NO-UNDO
    FIELD l-erro    AS INT 
    field desc-erro as char format "x(60)".
    

DEFINE VARIABLE hbodi159     AS HANDLE NO-UNDO.
DEFINE VARIABLE hbodi159sdf  AS HANDLE NO-UNDO.
DEFINE VARIABLE hbodi154     AS HANDLE NO-UNDO.
DEFINE VARIABLE hbodi154sdf  AS HANDLE NO-UNDO.

DEFINE BUFFER bf-emitente FOR ems2mult.emitente.

DEF DATASET dsPedido FOR pedidos_venda, itens
    DATA-RELATION r1 FOR pedidos_venda, itens
        RELATION-FIELDS(id,id) NESTED.

FUNCTION LongCharToJsonObject RETURN JsonObject PRIVATE (INPUT jsonChar AS LONGCHAR):
    
    DEFINE VARIABLE jsonOutput AS JsonObject        NO-UNDO.
    DEFINE VARIABLE objParse   AS ObjectModelParser NO-UNDO.

    ASSIGN jsonOutput = NEW JsonObject()
           objParse   = NEW ObjectModelParser()
           jsonOutput = CAST(objParse:Parse(jsonChar), JsonObject).

    DELETE OBJECT objParse.

    RETURN jsonOutput.

END FUNCTION.

PROCEDURE piRetornaErro:
    RETURN  "".
END PROCEDURE.

PROCEDURE piGeraPedido:
    DEF INPUT  PARAM jsonInput  AS JsonObject NO-UNDO.
    DEF OUTPUT PARAM jsonOutput AS JsonObject NO-UNDO.

    DEFINE VARIABLE oRequestParser AS JsonAPIRequestParser NO-UNDO.
    DEFINE VARIABLE lcPayload      AS LONGCHAR             NO-UNDO.
    DEFINE VARIABLE oResponse      AS JsonAPIResponse      NO-UNDO.

    oRequestParser = NEW JsonAPIRequestParser(jsonInput).
     
    ASSIGN lcPayload = oRequestParser:getPayloadLongChar().

    DEF VAR jsonAux  AS JsonObject NO-UNDO.
    jsonAux = LongCharToJsonObject(lcPayload).

    /*MESSAGE string(jsonAux:GetJsonArray("PEDIDOS_VENDA"):getJsonText())
        VIEW-AS ALERT-BOX INFO BUTTONS OK.*/

    DATASET dsPedido:HANDLE:READ-JSON('JsonObject',jsonAux).

    oResponse   = NEW JsonAPIResponse(jsonInput).
    oResponse:setHasNext(FALSE).

    oResponse:setStatus(200).
    jsonOutput = oResponse:createJsonResponse().

    FOR FIRST pedidos_venda:
        RUN piAdicionaPedido.
                  
        IF RETURN-VALUE = "NOK" THEN DO:
        
            FIND FIRST tt-retorno NO-LOCK NO-ERROR.
            
            IF AVAIL tt-retorno  THEN
            DO:
            
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

                MESSAGE "depois inicia pedido 3" SKIP
                        RETURN-VALUE
                    VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
            
                
                RUN piFinalizaBO.
                
                RETURN "NOK".
        
            END.
            
            ELSE DO:    
            
                FIND FIRST RowErrors NO-ERROR.
                
                oResponse = NEW JsonAPIResponse(jsonInput).
                oResponse:setHasNext(FALSE).
                oResponse:setStatus(400).
                oResponse:setRowErrors(JsonAPIUtils:convertTempTableToJsonObject(TEMP-TABLE RowErrors:HANDLE):getJsonArray("RowErrors")).
                jsonOutput = oResponse:createJsonResponse().

            END.
        END.
     
        FOR EACH itens:
            RUN piAdicionaItemPedido.

            IF RETURN-VALUE = "NOK" THEN DO:
                         
                FIND FIRST tt-retorno NO-LOCK NO-ERROR.
            
                IF AVAIL tt-retorno  THEN
                DO:
            
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

                    MESSAGE "depois inicia pedido 3" SKIP
                            RETURN-VALUE
                        VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
                
                    
                    RUN piFinalizaBO.
                    
                    RETURN "NOK".
                END.
                
                ELSE DO:    
            
                    FIND FIRST RowErrors NO-ERROR.

                    oResponse = NEW JsonAPIResponse(jsonInput).
                    oResponse:setHasNext(FALSE).
                    oResponse:setStatus(400).
                    oResponse:setRowErrors(JsonAPIUtils:convertTempTableToJsonObject(TEMP-TABLE RowErrors:HANDLE):getJsonArray("RowErrors")).
                    jsonOutput = oResponse:createJsonResponse().

                END.     
            END.
  
            FOR EACH ped-venda
                WHERE ped-venda.nome-abrev = tt-ped-venda.nome-abrev
                AND   ped-venda.nr-pedcli  = tt-ped-venda.nr-pedcli   :

                     RUN custom/eswms003rp.p (INPUT ROWID(ped-venda), "Pedido Criado" ).

            END.        
        END.
    END.    
    Message "cdaniel85 - if"  + Return-value + String(Error-status:Error) View-as Alert-box.
    If Return-value = "OK" Then Do:
        oResponse:setStatus(200).
        jsonOutput = oResponse:createJsonResponse().
    END.
END.

PROCEDURE piInicializaBO:
    // Instancia da DBO ped-venda
    IF NOT VALID-HANDLE(hbodi159) THEN
        RUN dibo/bodi159.p    PERSISTENT SET hbodi159.
    
    IF NOT VALID-HANDLE(hbodi159sdf) THEN
        RUN dibo/bodi159sdf.p PERSISTENT SET hbodi159sdf.
    
    IF VALID-HANDLE(hbodi159) THEN
        RUN openQueryStatic IN hbodi159 (INPUT "ChPedido":U).
    ELSE DO:
        RUN piFinalizaBO.
        RETURN "NOK":u.
    END.

   // Instancia da DBO ped-item
    IF NOT VALID-HANDLE(hbodi154) THEN
        RUN dibo/bodi154.p    PERSISTENT SET hbodi154.

    IF NOT VALID-HANDLE(hbodi154sdf) THEN
        RUN dibo/bodi154sdf.p PERSISTENT SET hbodi154sdf.

    IF VALID-HANDLE(hbodi154) THEN
       RUN openQueryStatic IN hbodi154 (INPUT "DEFAULT":U).
    ELSE DO:
        RUN piFinalizaBO.
        RETURN "NOK":u.
    END.

    RETURN "OK":u. 
END PROCEDURE.

PROCEDURE piFinalizaBO:
    IF VALID-HANDLE(hbodi159) THEN DO:
        RUN destroyBo IN hbodi159.
        IF VALID-HANDLE(hbodi159) THEN DO:
            DELETE PROCEDURE hbodi159.
            ASSIGN hbodi159 = ?.
        END.
    END.

    IF  VALID-HANDLE(hbodi159sdf) THEN DO:
        DELETE PROCEDURE hbodi159sdf.
        ASSIGN hbodi159sdf = ?.
    END.

    IF VALID-HANDLE(hbodi154) THEN DO:
        RUN destroyBo IN hbodi154.
        IF VALID-HANDLE(hbodi154) THEN DO:
            DELETE PROCEDURE hbodi154.
            ASSIGN hbodi154 = ?.
        END.
    END.

    IF VALID-HANDLE(hbodi154sdf) THEN DO:
        DELETE PROCEDURE hbodi154sdf.
        ASSIGN hbodi154sdf = ?.
    END.

    RELEASE ped-venda.
    RELEASE ped-item.
END PROCEDURE.

PROCEDURE piCriaErro:
    DEF INPUT PARAM c-mensagem AS CHAR NO-UNDO.
    DEF INPUT PARAM c-help     AS CHAR NO-UNDO.
    DEF INPUT PARAM i-erro     AS INT  NO-UNDO.

    IF c-help = "" THEN
        ASSIGN c-help = c-mensagem.
        
        MESSAGE "C-mensagem" SKIP      
            c-help
            VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
  
    CREATE tt-retorno.
    ASSIGN tt-retorno.l-erro    = i-erro
           tt-retorno.desc-erro = c-mensagem.
           //RowErrors.errorType        = "ERROR":u
           //RowErrors.errorHelp        = c-help.
           
END PROCEDURE.

PROCEDURE piAdicionaPedido:
    DEF VAR c-nr-tabpre AS CHAR  NO-UNDO.

    EMPTY TEMP-TABLE tt-ped-venda.

    RUN piInicializaBO.

    IF RETURN-VALUE = "NOK" THEN DO:
        RUN piCriaErro (INPUT "Erro Inesperado. N∆o carregou BO, informar o TI.",
                        INPUT "",
                        INPUT 17006).
        RETURN "NOK":u.
    END.

    // ->
    RUN emptyRowErrors IN hbodi159.
    RUN emptyRowObject IN hbodi159.

    RUN newRecord IN hbodi159.
    RUN getRecord IN hbodi159 (OUTPUT TABLE tt-ped-venda).

    FOR FIRST bf-emitente FIELDS(cod-gr-cli tp-rec-padrao cod-cond-pag portador port-pref
                              endereco bairro cidade estado cep pais cgc modalidade nome-abrev) NO-LOCK
        WHERE bf-emitente.cgc = pedidos_venda.cliente_id: END.
    IF NOT AVAIL bf-emitente THEN DO:
        RUN piCriaErro (INPUT "ID Cliente inv†lido.",
                        INPUT "",
                        INPUT 17006).
        RETURN "NOK":u.        
    END.

    FIND FIRST tt-ped-venda NO-ERROR.
    ASSIGN tt-ped-venda.nome-abrev = bf-emitente.nome-abrev.

    RUN setDefaultOrderNumber   IN hbodi159sdf(OUTPUT tt-ped-venda.nr-pedido).
    RUN inputTable IN hbodi159sdf (INPUT TABLE tt-ped-venda).
    RUN setDefaultCustomerName IN hbodi159sdf.
    RUN setDefaultCentralSales IN hbodi159sdf.
    RUN outputTable IN hbodi159sdf (OUTPUT TABLE tt-ped-venda).

    FIND FIRST ems2mult.estabelec NO-LOCK
        WHERE estabelec.cgc = pedidos_venda.filial_cnpj NO-ERROR.
    IF NOT AVAIL estabelec THEN DO:
        RUN piCriaErro (INPUT "CNPJ da filial inv†lido.",
                        INPUT "",
                        INPUT 17006).
        RETURN "NOK":u.        
    END.
    
    FIND FIRST ems2mult.emitente NO-LOCK
        WHERE emitente.cgc = pedidos_venda.cliente_id NO-ERROR.
        
    IF emitente.estado <> estabelec.estado  THEN DO:
    
        FIND FIRST natur-oper 
        WHERE natur-oper.nat-operacao = emitente.nat-ope-ext NO-ERROR.
        IF NOT AVAIL natur-oper THEN DO:
            RUN piCriaErro (INPUT "Natureza de Operaá∆o inv†lida.",
                        INPUT "",
                        INPUT 17006).
        RETURN "NOK":u.        
        END.      
        
    END.
    
    ELSE DO:
   
        FIND FIRST natur-oper 
            WHERE natur-oper.nat-operacao = emitente.nat-operacao  NO-ERROR.
        IF NOT AVAIL natur-oper THEN DO:
            RUN piCriaErro (INPUT "Natureza de Operaá∆o inv†lida.",
                            INPUT "",
                            INPUT 17006).
            RETURN "NOK":u.        
        END.
    END.
        
    FIND FIRST tt-ped-venda NO-ERROR.
    ASSIGN  tt-ped-venda.nr-pedcli       = STRING(tt-ped-venda.nr-pedido) 
            tt-ped-venda.cod-estabel     = IF AVAIL estabelec THEN estabelec.cod-estabel ELSE ""
            tt-ped-venda.nr-pedrep       = ""
            tt-ped-venda.contato         = ""
            tt-ped-venda.cod-gr-cli      = bf-emitente.cod-gr-cli
            tt-ped-venda.no-ab-reppri    = "Nissei"
            tt-ped-venda.cod-mensagem    = natur-oper.cod-mensagem
            tt-ped-venda.esp-ped         = 1 /* 1 = pedido simples,  2 = programacao entrega */
            tt-ped-venda.origem          = 1 /* padr∆o: 1 */
            tt-ped-venda.cd-origem       = 3 /* 3 = Sistema */
            tt-ped-venda.tp-preco        = 1 /* 1 = preÁo informado. */
            tt-ped-venda.nr-tab-finan    = 1 /* padr∆o: 0, mas Ç obrigat¢rio */
            tt-ped-venda.nr-ind-finan    = 0 /* padr∆o: 0, mas Ç obrigat¢rio */
            tt-ped-venda.tab-ind-fin     = 0 /* padr∆o: mesmo que nr-tab-finan */ 
            tt-ped-venda.mo-codigo       = 0 /* 0 = moeda corrente */
            tt-ped-venda.cod-sit-aval    = 1 /* padr∆o: 1 */
            tt-ped-venda.cod-sit-pre     = 1 /* padr∆o: 1 */
            tt-ped-venda.cod-sit-ped     = 1 /* padr∆o: 1 */
            tt-ped-venda.cod-sit-com     = 1 /* padr∆o: 1 */
            tt-ped-venda.proc-edi        = 1 /* padr∆o: ? */
            tt-ped-venda.cod-des-merc    = 2 /*Consumidor Pr¢prio/Ativo*/
            tt-ped-venda.ind-aprov       = YES
            tt-ped-venda.tp-receita      = bf-emitente.tp-rec-padrao
            tt-ped-venda.tp-pedido       = ""
            tt-ped-venda.nat-operacao    = natur-oper.nat-operacao
            tt-ped-venda.cod-canal-venda = 0
            tt-ped-venda.cod-cond-pag    = bf-emitente.cod-cond-pag
            tt-ped-venda.cod-portador    = bf-emitente.portador
            tt-ped-venda.modalidade      = bf-emitente.modalidade
            tt-ped-venda.cod-entrega     = "Padr∆o"
            tt-ped-venda.local-entreg    = bf-emitente.endereco
            tt-ped-venda.bairro          = bf-emitente.bairro
            tt-ped-venda.cidade          = bf-emitente.cidade
            tt-ped-venda.estado          = bf-emitente.estado
            tt-ped-venda.cep             = bf-emitente.cep
            tt-ped-venda.caixa-postal    = ""
            tt-ped-venda.pais            = bf-emitente.pais
            tt-ped-venda.cgc             = bf-emitente.cgc
            tt-ped-venda.nome-transp     = "" // (n„o obrigat¢rio) 
            tt-ped-venda.dt-emissao      = TODAY
            tt-ped-venda.dt-implant      = TODAY
            tt-ped-venda.observacoes     = pedidos_venda.obs
            tt-ped-venda.nome-abrev-tri  = ""
            OVERLAY(tt-ped-venda.char-1, 100,10) = string(pedidos_venda.pedido_num) //Ou o campo que for...
            .

    IF c-nr-tabpre <> "" THEN DO:
        ASSIGN tt-ped-venda.nr-tabpre = c-nr-tabpre.

        FOR FIRST ems2mult.tb-preco FIELDS(mo-codigo) NO-LOCK
            WHERE tb-preco.nr-tabpre = c-nr-tabpre:

            ASSIGN tt-ped-venda.mo-codigo = tb-preco.mo-codigo.
        END.
    END.

    /*IF bf-emitente.port-pref <> 0 THEN
        ASSIGN
            tt-ped-venda.cod-portador  = bf-emitente.port-pref.
            tt-ped-venda.modalidade    = bf-emitente.mod-pref
            .   */

    /* transportador da atulizaá∆o clientes do estabelecimento - PD0507 */
    FOR FIRST estab-cli FIELDS(nome-transp) NO-LOCK
        WHERE estab-cli.cod-estabel = estabelec.cod-estabel
        AND   estab-cli.nome-abrev  = bf-emitente.nome-abrev:

        ASSIGN tt-ped-venda.nome-transp = estab-cli.nome-transp.
    END.
    
    RUN setRecord IN hbodi159 (INPUT TABLE tt-ped-venda).
    RUN createRecord IN hbodi159.
    RUN getRowErrors IN hbodi159 (OUTPUT TABLE RowErrors).

    FIND FIRST RowErrors NO-LOCK
        WHERE RowErrors.ErrorSubType <> 'WARNING' NO-ERROR.
    IF AVAIL RowErrors THEN
        RETURN "NOK":u.
    
    RUN getRecord IN hbodi159 (OUTPUT TABLE tt-ped-venda).

    DEF VAR i-nr-pedido AS INTEGER NO-UNDO.
    FIND FIRST tt-ped-venda NO-LOCK NO-ERROR.
    IF AVAIL tt-ped-venda THEN
        ASSIGN i-nr-pedido = tt-ped-venda.nr-pedido.

    DEF VAR rw-pedido AS ROWID NO-UNDO.
    RUN getRowid IN hbodi159 (OUTPUT rw-pedido).
    

    RETURN "OK".
    
    
END PROCEDURE.

PROCEDURE piAdicionaItemPedido:
    DEF VAR i-sequencia AS INTEGER  NO-UNDO.

    EMPTY TEMP-TABLE RowErrors.

    FOR FIRST item FIELDS(it-codigo) NO-LOCK
        WHERE ITEM.it-codigo = STRING(itens.produto_id): END.
    IF NOT AVAIL item THEN DO:
        RUN piCriaErro (INPUT "Produto ID inv†lido.",
                        INPUT "",
                        INPUT 17006).
        RETURN "NOK":u.
    END.

    ASSIGN i-sequencia = 0.
    FOR EACH ped-item NO-LOCK
        WHERE ped-item.nome-abrev = tt-ped-venda.nome-abrev
        AND   ped-item.nr-pedcli  = tt-ped-venda.nr-pedcli:

        IF i-sequencia < ped-item.nr-sequencia THEN
            ASSIGN i-sequencia = ped-item.nr-sequencia.
    END.
    ASSIGN i-sequencia = i-sequencia + 10.
    
    // ->
    EMPTY TEMP-TABLE tt-ped-item.

    RUN emptyRowErrors IN hbodi154.
    RUN emptyRowObject IN hbodi154.

    RUN newRecord IN hbodi154.
    RUN getRecord IN hbodi154 (OUTPUT TABLE tt-ped-item).

    FIND FIRST tt-ped-item NO-ERROR.
    ASSIGN tt-ped-item.nome-abrev   = bf-emitente.nome-abrev
           tt-ped-item.nr-pedcli    = tt-ped-venda.nr-pedcli
           tt-ped-item.it-codigo    = item.it-codigo
           tt-ped-item.nr-sequencia = i-sequencia
           tt-ped-item.cd-origem    = 3.

    RUN inputTable IN hbodi154sdf (INPUT TABLE tt-ped-item).
    RUN setDefaultItem             IN hbodi154sdf.
    RUN setDefaultPriceTable       IN hbodi154sdf.
    RUN setDefaultTransactionType  IN hbodi154sdf.
    RUN outputTable IN hbodi154sdf(OUTPUT TABLE tt-ped-item).

    FIND FIRST tt-ped-item NO-ERROR.
    
    /* retorna erro se cabeáalho do pedido (ped-venda) n∆o existe. */
    EMPTY TEMP-TABLE tt-ped-venda.
    FIND ped-venda OF tt-ped-item NO-ERROR.
    IF NOT AVAIL ped-venda THEN DO:
        RUN piCriaErro (INPUT "Pedido de Venda n∆o existe.",
                        INPUT "",
                        INPUT 17006).
        RETURN "NOK":u.
    END.

    BUFFER-COPY ped-venda TO tt-ped-venda.
    ASSIGN tt-ped-venda.r-rowid = ROWID(tt-ped-venda).

    ASSIGN tt-ped-item.esp-ped        = tt-ped-venda.esp-ped
           tt-ped-item.cd-origem      = 3 /* 3 = Sistema */ 
           tt-ped-item.nr-sequencia   = i-sequencia // adiciona novamente? pq? 
           tt-ped-item.nr-ordem       = 0
           tt-ped-item.dt-entorig     = tt-ped-venda.dt-implant
           tt-ped-item.dt-entrega     = tt-ped-venda.dt-implant
           tt-ped-item.qt-pedida      = itens.quantidade_faturar
           tt-ped-item.qt-un-fat      = itens.quantidade_faturar
           tt-ped-item.qt-atendida    = 0
           tt-ped-item.vl-pretab      = itens.valor_unitario
           tt-ped-item.vl-preori      = itens.valor_unitario
           tt-ped-item.vl-preuni      = itens.valor_unitario
           tt-ped-item.vl-liq-it      = itens.valor_unitario
           tt-ped-item.vl-liq-abe     = itens.valor_unitario 
           tt-ped-item.vl-desconto    = itens.valor_desconto
           tt-ped-item.val-desconto-inform = 0           
           tt-ped-item.tp-adm-lote    = 1 // padr∆o: 1 
           tt-ped-item.tp-aloc-lote   = 1 // padr∆o: 1 
           tt-ped-item.tipo-atend     = 1 // parcial: 2
           tt-ped-item.cod-sit-item   = 1 // padr∆o: 1 
           tt-ped-item.cod-sit-pre    = tt-ped-venda.cod-sit-pre
           tt-ped-item.cod-sit-com    = tt-ped-venda.cod-sit-com
           tt-ped-item.cod-entrega    = tt-ped-venda.cod-entrega
           tt-ped-item.observacao     = itens.observacao
           tt-ped-item.nat-oper       = natur-oper.nat-operacao
           .


    FOR FIRST ems2mult.preco-item FIELDS (nr-tabpre) NO-LOCK
        WHERE preco-item.it-codigo = tt-ped-item.it-codigo
        AND   preco-item.situacao  = 1,
        FIRST ems2mult.tb-preco FIELDS (nr-tabpre) OF preco-item NO-LOCK
        WHERE tb-preco.situacao = 1:

        ASSIGN tt-ped-item.nr-tabpre = tb-preco.nr-tabpre.
    END.

    RUN setRecord IN hbodi154 (INPUT TABLE tt-ped-item).

    RUN createRecord IN hbodi154.
    RUN getRowErrors IN hbodi154 (OUTPUT TABLE RowErrors).

    FIND FIRST RowErrors NO-LOCK
        WHERE RowErrors.ErrorSubType <> 'WARNING' NO-ERROR.
    IF AVAIL RowErrors THEN DO:
        RETURN "NOK":u.
    END.
    
    RETURN "OK":u.
END.
