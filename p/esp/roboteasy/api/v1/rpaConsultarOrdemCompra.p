
{utp/ut-api.i} 
{utp/ut-api-utils.i}

//****************************************************************************************************
//****************************************************************************************************
//****************************************************************************************************

// MODELO = definir parametros retornados
DEF TEMP-TABLE tt-retorno NO-UNDO SERIALIZE-NAME "retorno" 
    FIELD status-cod                    AS CHAR INITIAL "NOK"       SERIALIZE-NAME "statusCodigo" 
    FIELD status-obs                    AS CHAR                     SERIALIZE-NAME "statusObs" 
    FIELD status-versao                 AS INT                      SERIALIZE-NAME "statusVersao" INITIAL 31
    .

DEF TEMP-TABLE tt-ordens NO-UNDO SERIALIZE-NAME "ordens"
    FIELD numero-ordem      LIKE ordem-compra.numero-ordem      SERIALIZE-NAME "numeroOrdem"
    FIELD cod-comprado      LIKE ordem-compra.cod-comprado      SERIALIZE-NAME "codComprador"
    FIELD cod-cond-pag      LIKE ordem-compra.cod-cond-pag      SERIALIZE-NAME "codCondPag"
    FIELD cod-emitente      LIKE ordem-compra.cod-emitente      SERIALIZE-NAME "codEmitente"
    FIELD cod-estabel       LIKE ordem-compra.cod-estabel       SERIALIZE-NAME "codEstabel"
    FIELD cod-refer         LIKE ordem-compra.cod-refer         SERIALIZE-NAME "codRefer"
    FIELD conta-contabil    LIKE ordem-compra.conta-contabil    SERIALIZE-NAME "contaContabil"    
    FIELD ct-codigo         LIKE ordem-compra.ct-codigo         SERIALIZE-NAME "ctCodigo"
    FIELD dat-ordem         LIKE ordem-compra.dat-ordem         SERIALIZE-NAME "datOrdem"
    FIELD data-emissao      LIKE ordem-compra.data-emissao      SERIALIZE-NAME "dataEmissao"
    FIELD data-pedido       LIKE ordem-compra.data-pedido       SERIALIZE-NAME "dataPedido"
    FIELD ep-codigo         LIKE ordem-compra.ep-codigo         SERIALIZE-NAME "epCodigo"
    FIELD it-codigo         LIKE ordem-compra.it-codigo         SERIALIZE-NAME "itCodigo"
    FIELD mo-codigo         LIKE ordem-compra.mo-codigo         SERIALIZE-NAME "moCodigo"
    FIELD natureza          LIKE ordem-compra.natureza          SERIALIZE-NAME "natureza"
    FIELD nr-requisicao     LIKE ordem-compra.nr-requisicao     SERIALIZE-NAME "nrRequisicao"
    FIELD origem            LIKE ordem-compra.origem            SERIALIZE-NAME "origem"
    FIELD pre-unit-for      LIKE ordem-compra.pre-unit-for      SERIALIZE-NAME "preUnitFor"
    FIELD preco-fornec      LIKE ordem-compra.preco-fornec      SERIALIZE-NAME "precoFornec"
    FIELD preco-orig        LIKE ordem-compra.preco-orig        SERIALIZE-NAME "precoOrig"
    FIELD preco-unit        LIKE ordem-compra.preco-unit        SERIALIZE-NAME "precoUnit"
    FIELD qt-acum-rec       LIKE ordem-compra.qt-acum-rec       SERIALIZE-NAME "qtAcumRec"
    FIELD qt-solic          LIKE ordem-compra.qt-solic          SERIALIZE-NAME "qtSolic"
    FIELD requisitante      LIKE ordem-compra.requisitante      SERIALIZE-NAME "requisitante"
    FIELD sc-codigo         LIKE ordem-compra.sc-codigo         SERIALIZE-NAME "scCodigo"
    FIELD situacao          LIKE ordem-compra.situacao          SERIALIZE-NAME "situacao"
    FIELD usuario           LIKE ordem-compra.usuario           SERIALIZE-NAME "usuario"
    FIELD status-cod        AS   CHAR                           SERIALIZE-NAME "statusCod"
    .

DEFINE TEMP-TABLE tt-erros NO-UNDO SERIALIZE-NAME "erros" 
    FIELD identif-segment AS CHARACTER SERIALIZE-NAME "seqErro"               
    FIELD cd-erro         AS INTEGER   SERIALIZE-NAME "codErro" 
    FIELD desc-erro       AS CHARACTER SERIALIZE-NAME "descErro" 
    .

//****************************************************************************************************

PROCEDURE pi-main:

    // replicar parametro do JSON de entrada no JSON de saida
    CREATE tt-retorno.
    ASSIGN tt-retorno.status-cod = "NOK".
    assign tt-retorno.status-obs = session:temp-directory.
    
    //--------------------------------------------------
    FOR FIRST tt-ordens: 
    END. 

    IF  AVAIL tt-ordens THEN DO:
        ASSIGN tt-retorno.status-cod = "OK".
        FOR EACH tt-ordens:
            FOR FIRST ordem-compra NO-LOCK 
                WHERE ordem-compra.numero-ordem = tt-ordens.numero-ordem.
            END.
            IF  AVAIL ordem-compra THEN DO:
                BUFFER-COPY ordem-compra TO tt-ordens.
                ASSIGN tt-ordens.status-cod = "OK".
            END.
            ELSE
                ASSIGN tt-ordens.status-cod = "NOK".
        END.

        FOR FIRST tt-ordens
            WHERE tt-ordens.status-cod = "NOK":
            ASSIGN tt-retorno.status-cod = "NOK"
                   tt-retorno.status-obs = "Erro na leitura de uma ou mais ordens de compra".
        END.
    END.
    ELSE
        ASSIGN tt-retorno.status-cod = "NOK"
               tt-retorno.status-obs = "Nenhuma ordem de compra foi informada".
    //--------------------------------------------------

END PROCEDURE.

//****************************************************************************************************
//****************************************************************************************************
//****************************************************************************************************

DEF DATASET dsPrincipal SERIALIZE-HIDDEN 
    FOR tt-retorno.
                    
RUN pi-post (INPUT jsonInput, OUTPUT jsonOutput).
RUN pi-main.
RUN pi-input-json-retorno (OUTPUT jsonOutput).
jsonOutput:WRITE (INPUT-OUTPUT lcOutput, INPUT YES, INPUT "UTF-8").
   
RETURN.

//****************************************************************************************************

PROCEDURE pi-post:

    DEF INPUT  PARAM jsonInput           AS JsonObject NO-UNDO. 
    DEF OUTPUT PARAM jsonOutput          AS JsonObject NO-UNDO.
    
    DEF          VAR jsonString          AS LONGCHAR   NO-UNDO.
    DEF          VAR jsonObjectPayload   AS JsonObject NO-UNDO.
    DEF          VAR jParam              AS JsonObject NO-UNDO. 
    DEF          VAR jOrdens             AS JsonObject NO-UNDO. 
    DEF          VAR jAux                AS JsonObject NO-UNDO. 
    DEF          VAR lOk                 AS l          NO-UNDO.
    DEFINE VARIABLE jsonArrayAux  AS JsonArray            NO-UNDO.

    DEF VAR i-length AS INTE NO-UNDO.
    DEF VAR i-aux AS INTE NO-UNDO.

    ASSIGN jsonObjectPayload = jsonInput:GetJsonObject("payload").
    
    IF jsonObjectPayload:Has("ordens") THEN DO:
        
        jsonArrayAux = jsonObjectPayload:GetJsonArray("ordens").

        ASSIGN i-length = jsonArrayAux:LENGTH.
        IF i-length > 0 THEN
        DO i-aux = 1 TO i-length:
            jAux = jsonArrayAux:GetJsonObject(i-aux).
            CREATE tt-ordens.
            ASSIGN tt-ordens.numero-ordem = IF jAux:has("numeroOrdem") THEN jAux:GetInteger("numeroOrdem") ELSE ? NO-ERROR.  
        END.
    END.

    RETURN "OK".

END PROCEDURE.

//****************************************************************************************************

PROCEDURE pi-input-json-retorno :

    DEF OUTPUT PARAM jsonOutput        AS JsonObject NO-UNDO.
    DEF          VAR jsonObjectOutput  AS JsonObject NO-UNDO.
    DEF          VAR iRet              AS i          NO-UNDO.
    DEF          VAR lcOutput          AS LONGCHAR   NO-UNDO.
    DEF          VAR lPassou           AS l          NO-UNDO.
    
    ASSIGN iRet = 500.
    jsonObjectOutput = NEW JsonObject().
    
    IF  TEMP-TABLE tt-retorno:HAS-RECORDS THEN DO:
        ASSIGN iRet = 200.
        jsonObjectOutput:READ(DATASET dsPrincipal:HANDLE).
        ASSIGN lPassou = YES.
    END.
    
    IF  lPassou = NO THEN DO:
        CREATE tt-retorno.
        ASSIGN tt-retorno.status-cod = "NOK"
               tt-retorno.status-obs = "Erro na execu‡Æo da API".
        jsonObjectOutput:READ(TEMP-TABLE tt-retorno:HANDLE).
    END.

//****************************************************************************************************

    DEFINE VARIABLE oJsonArrayOrdens AS JsonArray         NO-UNDO.

    // ADICIONAR DADOS NO JSON DE RETORNO
    oJsonArrayOrdens = NEW JsonArray().
    oJsonArrayOrdens:READ(TEMP-TABLE tt-ordens:HANDLE).
    jsonObjectOutput:ADD("ordens", oJsonArrayOrdens).

//****************************************************************************************************

    jsonOutput = JsonAPIResponseBuilder:ok(jsonObjectOutput, iRet).
    
END PROCEDURE.

//****************************************************************************************************
