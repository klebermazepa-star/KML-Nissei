//USING Progress.Json.ObjectModel.*.

USING Progress.Json.ObjectModel.JsonArray.
USING Progress.Json.ObjectModel.JsonObject.
USING Progress.Json.ObjectModel.JsonDataType.
USING Progress.Json.ObjectModel.ObjectModelParser.

{utp/ut-api.i}
{utp/ut-api-action.i pi-gera-devolucao  POST  /~* }
{utp/ut-api-notfound.i}

{method/dbotterr.i} /*RowErrors*/

DEF TEMP-TABLE devolucao NO-UNDO
    FIELD pedido            AS CHAR
    FIELD cnpj-devolucao    AS CHAR
    FIELD desconto          AS DEC
    FIELD observacao        AS CHAR
    FIELD cpf-cliente       AS CHAR
    FIELD cnpj-loja-origem  AS CHAR
    FIELD nota-origem       AS CHAR
    FIELD serie-origem      AS CHAR.

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
    
DEFINE TEMP-TABLE tt-cliente NO-UNDO
    FIELD CNPJ          AS CHAR
    FIELD nome          AS CHAR
    FIELD natureza      AS INT // 1 - Fisica ** 2 - Juridica
    FIELD nome-abrev    AS CHAR
    FIELD ins-estadual  AS CHAR
    FIELD cep           AS CHAR 
    FIELD endereco      AS CHAR
    FIELD numero        AS CHAR
    FIELD complemento   AS CHAR
    FIELD bairro        AS CHAR
    FIELD cidade        AS CHAR
    FIELD cod-ibge      AS CHAR
    FIELD estado        AS CHAR
    FIELD pais          AS CHAR
    FIELD telefone      AS CHAR
    FIELD email         AS CHAR.

DEFINE TEMP-TABLE tt-pedido NO-UNDO
    FIELD pedcodigo         AS DEC
    FIELD DtEmissao         AS DATE
    FIELD DtEntrega         AS DATE
    FIELD cnpj_estab        AS CHAR 
    FIELD cnpj_emitente     AS CHAR
    FIELD valorTotal        AS DEC
    FIELD desconto          AS DEC
    FIELD frete             AS DEC
    FIELD observacao        AS CHAR
    FIELD tipopedido        AS INT
    FIELD cnpj_transp       AS CHAR
    FIELD comissao              AS DEC
    FIELD cnpj-representante    AS CHAR .

DEFINE TEMP-TABLE tt-pedido-item NO-UNDO
    FIELD cod-item          AS CHAR
    FIELD quantidade        AS DEC
    FIELD valor-unit        AS DEC
    FIELD desconto          AS DEC
    FIELD valor-liq         AS DEC
    FIELD preco-bruto       AS DEC
    FIELD valor-total       AS DEC
    FIELD lote              AS CHAR
    FIELD dt-validade       AS DATE
    FIELD observacao        AS CHAR.

DEFINE TEMP-TABLE tt-cond-pagto-esp NO-UNDO
    FIELD cond-pagto    AS CHAR
    FIELD dt-vencto     AS DATE
    FIELD vl-parcela    AS DEC
    FIELD parcela       AS DEC
    FIELD nsu           AS CHAR
    FIELD autorizacao   AS CHAR
    FIELD adquirente    AS CHAR
    FIELD origem-pagto  AS CHAR
    FIELD CNPJ_CONVENIO AS CHAR.

DEFINE TEMP-TABLE tt-nota-fiscal NO-UNDO
    FIELD l-gerada      AS LOGICAL
    FIELD desc-erro     AS CHAR
    FIELD cod-estabel   LIKE nota-fiscal.cod-estabel
    FIELD serie         LIKE nota-fiscal.serie
    FIELD nr-nota-fis   LIKE nota-fiscal.nr-nota-fis
    FIELD chave-acesso  LIKE nota-fiscal.cod-chave-aces-nf-eletro.    



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
/* FIM - Defini‡Æo temp-tables/vari veis execu‡Æo FT2200 */

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
    //DEF INPUT  PARAMETER TABLE FOR tt-mp-titulos-baixa-ok. 

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
    

/*     FOR FIRST devolucao:                                                       */
/*                                                                                */
/*         log-manager:write-message("KML - achou cabecalho devolucao") no-error. */
/*                                                                                */
/*                                                                                */
/*     END.                                                                       */
/*                                                                                */
/*     FOR EACH itens:                                                            */
/*                                                                                */
/*         log-manager:write-message("KML - achou itens devolucao") no-error.     */
/*                                                                                */
/*     END.                                                                       */
/*                                                                                */
/*     FOR EACH cond-pagto:                                                       */
/*                                                                                */
/*         log-manager:write-message("KML - achou condi‡ao pagamento") no-error.  */
/*                                                                                */
/*     END.                                                                       */

    
    RUN intprg/int096API.p (INPUT TABLE devolucao,
                         INPUT TABLE itens,
                         INPUT TABLE cond-pagto,
                         OUTPUT TABLE tt-nota-devolucao).

    jsonOutput = NEW JSONObject().
    FIND FIRST tt-nota-devolucao NO-ERROR.
    
    MESSAGE "tt-nota-devolucao" SKIP
             tt-nota-devolucao.cnpj-loja SKIP
             tt-nota-devolucao.serie     SKIP
             tt-nota-devolucao.nr-nota 
        VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.

    IF tt-nota-devolucao.l-gerada = NO THEN
    DO: 
    
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
        END.           
            
    END.
    ELSE DO:
    
        FIND FIRST devolucao NO-ERROR.
    
        IF devolucao.CNPJ-LOJA-ORIGEM <> devolucao.CNPJ-DEVOLUCAO THEN
        DO:
        
            MESSAGE "Entrou IF <>" 
                VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
        
            FIND FIRST estabelec NO-LOCK
                WHERE estabelec.cgc = tt-nota-devolucao.cnpj-loja  NO-ERROR.
        
            FIND FIRST nota-fiscal NO-LOCK
                WHERE nota-fiscal.cod-estabel   = estabelec.cod-estabel
                  AND nota-fiscal.serie         = tt-nota-devolucao.serie
                  AND nota-fiscal.nr-nota-fis   = tt-nota-devolucao.nr-nota NO-ERROR.
                  
            MESSAGE "nota-fiscal encontrada" SKIP
                     nota-fiscal.nr-nota-fis
                VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
                
                  
            CREATE tt-cliente.
            ASSIGN tt-cliente.CNPJ         = devolucao.CNPJ-LOJA-ORIGEM.
/*                    tt-cliente.nome         = ""                                                  */
/*                    tt-cliente.natureza     = IF pedido.natureza-cliente = "fisica" THEN 1 ELSE 2 */
/*                    tt-cliente.ins-estadual = pedido.inscricao_federal                            */
/*                    tt-cliente.cep          = pedido.cep                                          */
/*                    tt-cliente.endereco     = pedido.endereco                                     */
/*                    tt-cliente.numero       = string(pedido.numero)                               */
/*                    tt-cliente.complemento  = pedido.complemento                                  */
/*                    tt-cliente.bairro       = pedido.bairro                                       */
/*                    tt-cliente.cidade       = pedido.cidade                                       */
/*                    tt-cliente.cod-ibge     = pedido.cod-ibge                                     */
/*                    tt-cliente.estado       = pedido.estado                                       */
/*                    tt-cliente.pais         = pedido.pais                                         */
/*                    tt-cliente.telefone     = pedido.telefone                                     */
/*                    tt-cliente.email        = pedido.email.                                       */

            
                
            CREATE tt-pedido.
            ASSIGN tt-pedido.pedcodigo     = int(nota-fiscal.nr-pedcli)
                   tt-pedido.DtEmissao     = TODAY
                   tt-pedido.DtEntrega     = TODAY
                   tt-pedido.cnpj_estab    = devolucao.CNPJ-DEVOLUCAO
                   tt-pedido.cnpj_emitente = devolucao.CNPJ-LOJA-ORIGEM
                   tt-pedido.valorTotal    = 0 //nota-fiscal.vl-tot-nota
                   tt-pedido.desconto      = 0 //nota-fiscal.vl-desconto
                   tt-pedido.frete         = 0 //nota-fiscal.vl-frete
                   tt-pedido.observacao    = nota-fiscal.observ-nota
                   tt-pedido.tipopedido    = 19
                   tt-pedido.cnpj_transp   = "12345678912"                
                   tt-pedido.comissao      = 0
                   tt-pedido.cnpj-representante = ""
               . 
               
               
            FOR EACH it-nota-fisc OF nota-fiscal NO-LOCK:
            
            MESSAGE "ACHOU IT-NOTA-FISC"
                VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.


            CREATE tt-pedido-item.
            ASSIGN tt-pedido-item.cod-item    = it-nota-fisc.it-codigo
                   tt-pedido-item.quantidade  = it-nota-fisc.qt-faturada[1]
                   tt-pedido-item.valor-unit  = it-nota-fisc.vl-tot-item / it-nota-fisc.qt-faturada[1] //itens.total_item / itens.quantidade
                   tt-pedido-item.desconto    = it-nota-fisc.vl-desconto
                   tt-pedido-item.valor-liq   = it-nota-fisc.vl-preuni
                   tt-pedido-item.preco-bruto = it-nota-fisc.vl-preori
                   tt-pedido-item.valor-total = it-nota-fisc.vl-tot-item
                   tt-pedido-item.lote        = ""
                   tt-pedido-item.dt-validade = ?
                   tt-pedido-item.observacao  = "".

            END.
            
            MESSAGE "ANTES RUN"
                VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
               
                
            RUN intprg/int092API.p (INPUT TABLE tt-cliente,
                                    INPUT TABLE tt-pedido,
                                    INPUT TABLE tt-pedido-item,
                                    INPUT TABLE tt-cond-pagto-esp,
                                    OUTPUT TABLE tt-nota-fiscal).
                                
            
            
        END.
        
        FIND FIRST tt-nota-fiscal NO-ERROR.
    
        jsonOutput:ADD("cod-estabel",tt-nota-devolucao.cnpj-loja).
        jsonOutput:ADD("serie"      ,tt-nota-devolucao.serie      ).
        jsonOutput:ADD("nr-nota-fis",tt-nota-devolucao.nr-nota).
        jsonOutput:ADD("chave-acesso",tt-nota-devolucao.chave-acesso).
        jsonOutput:ADD("gerada",tt-nota-devolucao.l-gerada).
        jsonOutput:ADD("Status",tt-nota-devolucao.desc-erro). 
        
        
    
        jsonOutput:ADD("NOTA_TRANSFERENCIA",tt-nota-fiscal.nr-nota-fis).
        jsonOutput:ADD("SERIE",tt-nota-fiscal.serie).
        jsonOutput:ADD("DESCRI€ÇO",tt-nota-fiscal.desc-erro).
        jsonOutput:ADD("CHAVE_TRANSF",tt-nota-fiscal.chave-acesso). 
    
    END.
     
    IF NOT CAN-FIND(FIRST devolucao) THEN DO:
        
        jsonOutput:ADD("ERRO","Erro na execu‡Æo da rotina de devolucao!").

        MESSAGE "TESTE 2"
            VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
            
    END.
        

     
END PROCEDURE.
