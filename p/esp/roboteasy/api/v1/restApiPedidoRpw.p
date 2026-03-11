USING Progress.Lang.*.
USING Progress.Json.ObjectModel.*.
USING OpenEdge.Core.*. 
USING OpenEdge.Net.HTTP.*. 
USING OpenEdge.Net.HTTP.Lib.ClientLibraryBuilder. 

{utp/ut-api.i}
{utp/ut-api-action.i pi-cria-pedido    POST /criaPedido/~*  }
{utp/ut-api-action.i pi-busca-pedido   POST /buscaPedido/~* }
{utp/ut-api-action.i pi-move-relatorio POST /moveRelatorio/~* }
{utp/ut-api-notfound.i}

DEFINE VARIABLE oJsonArrayAux AS JsonArray         NO-UNDO.
DEFINE VARIABLE oJsonAux      AS JsonObject        NO-UNDO.
DEFINE VARIABLE objParse      AS ObjectModelParser NO-UNDO.

{esp/roboteasy/robotapi032.i}
{esp/roboteasy/robotapifn032.i}

DEFINE DATASET dsResultadoCriacao
    FOR tt-resultado-criacao.

DEFINE DATASET dsResultadoConsulta
    FOR tt-resultado-consulta.

DEFINE DATASET dsResultadoArquivo
    FOR tt-resultado-arquivo.

PROCEDURE pi-cria-pedido:

    DEF INPUT  PARAM jsonInput  AS JsonObject NO-UNDO.
    DEF OUTPUT PARAM jsonOutput AS JsonObject NO-UNDO.

    DEFINE VARIABLE oRequestParser   AS JsonAPIRequestParser NO-UNDO.
    DEFINE VARIABLE lcPayload        AS LONGCHAR             NO-UNDO.
    DEFINE VARIABLE oJsonPayLoad     AS JsonObject           NO-UNDO.
    DEFINE VARIABLE jsonObjectOutput AS JsonObject           NO-UNDO.

    DEFINE VARIABLE apiHandler       AS HANDLE               NO-UNDO.
    DEFINE VARIABLE iRet             AS INTEGER              NO-UNDO.
    DEFINE VARIABLE lPassou          AS LOGICAL              NO-UNDO.

    oRequestParser = NEW JsonAPIRequestParser(jsonInput).
     
    ASSIGN lcPayload = oRequestParser:getPayloadLongChar().
   
    oJsonPayLoad = fnTextToJsonObject(lcPayload).

    RUN pi-read-input (INPUT oJsonPayLoad).

    IF NOT VALID-HANDLE(apiHandler) THEN DO:
        RUN esp/roboteasy/robotapi032.p PERSISTENT SET apiHandler.
    END.

    RUN pi-cria-pedido-rpw IN apiHandler (INPUT  TABLE tt-cria-pedido,          
                                          INPUT  TABLE tt-param-ce0403,
                                          INPUT  TABLE tt-param-ft0708,
                                          INPUT  TABLE tt-param-ft0709,
                                          INPUT  TABLE tt-param-of0410,
                                          INPUT  TABLE tt-param-of0520,
                                          INPUT  TABLE tt-param-of0620,
                                          INPUT  TABLE tt-param-of0770,
                                          INPUT  TABLE tt-param-re0530,
                                          OUTPUT TABLE tt-resultado-criacao).

    DELETE PROCEDURE apiHandler NO-ERROR.

    jsonOutput = NEW JSONObject().

    ASSIGN iRet = 500.
    jsonObjectOutput = NEW JsonObject().

    IF  TEMP-TABLE tt-resultado-criacao:HAS-RECORDS THEN DO:
        ASSIGN iRet = 200.
        jsonObjectOutput:READ(DATASET dsResultadoCriacao:HANDLE).
        ASSIGN lPassou = YES.
    END.
    
    IF  lPassou = NO THEN DO:
        ASSIGN iRet = 204.
        jsonObjectOutput:READ(TEMP-TABLE tt-resultado-criacao:HANDLE).
    END.

    jsonOutput = JsonAPIResponseBuilder:ok(jsonObjectOutput, iRet).

    RETURN "OK":U.

END PROCEDURE.


PROCEDURE pi-busca-pedido:

    DEF INPUT  PARAM jsonInput  AS JsonObject NO-UNDO.
    DEF OUTPUT PARAM jsonOutput AS JsonObject NO-UNDO.

    DEFINE VARIABLE oRequestParser   AS JsonAPIRequestParser NO-UNDO.
    DEFINE VARIABLE lcPayload        AS LONGCHAR             NO-UNDO.
    DEFINE VARIABLE oJsonPayLoad     AS JsonObject           NO-UNDO.
    DEFINE VARIABLE jsonObjectOutput AS JsonObject           NO-UNDO.

    DEFINE VARIABLE apiHandler       AS HANDLE               NO-UNDO.
    DEFINE VARIABLE iRet             AS INTEGER              NO-UNDO.
    DEFINE VARIABLE lPassou          AS LOGICAL              NO-UNDO.

    oRequestParser = NEW JsonAPIRequestParser(jsonInput).
     
    ASSIGN lcPayload = oRequestParser:getPayloadLongChar().
   
    oJsonPayLoad = fnTextToJsonObject(lcPayload).

    RUN pi-read-input (INPUT oJsonPayLoad).

    IF NOT VALID-HANDLE(apiHandler) THEN DO:
        RUN esp/roboteasy/robotapi032.p PERSISTENT SET apiHandler.
    END.

    RUN pi-busca-pedido-rpw IN apiHandler (INPUT  TABLE tt-consulta-pedido,
                                           OUTPUT TABLE tt-resultado-consulta).

    DELETE PROCEDURE apiHandler NO-ERROR.

    jsonOutput = NEW JSONObject().

    ASSIGN iRet = 500.
    jsonObjectOutput = NEW JsonObject().

    IF  TEMP-TABLE tt-resultado-consulta:HAS-RECORDS THEN DO:
        ASSIGN iRet = 200.
        jsonObjectOutput:READ(DATASET dsResultadoConsulta:HANDLE).
        ASSIGN lPassou = YES.
    END.
    
    IF  lPassou = NO THEN DO:
        ASSIGN iRet = 204.
        jsonObjectOutput:READ(TEMP-TABLE tt-resultado-consulta:HANDLE).
    END.

    jsonOutput = JsonAPIResponseBuilder:ok(jsonObjectOutput, iRet).

    RETURN "OK":U.

END PROCEDURE.


PROCEDURE pi-move-relatorio:

    DEF INPUT  PARAM jsonInput  AS JsonObject NO-UNDO.
    DEF OUTPUT PARAM jsonOutput AS JsonObject NO-UNDO.

    DEFINE VARIABLE oRequestParser   AS JsonAPIRequestParser NO-UNDO.
    DEFINE VARIABLE lcPayload        AS LONGCHAR             NO-UNDO.
    DEFINE VARIABLE oJsonPayLoad     AS JsonObject           NO-UNDO.
    DEFINE VARIABLE jsonObjectOutput AS JsonObject           NO-UNDO.

    DEFINE VARIABLE apiHandler       AS HANDLE               NO-UNDO.
    DEFINE VARIABLE iRet             AS INTEGER              NO-UNDO.
    DEFINE VARIABLE lPassou          AS LOGICAL              NO-UNDO.

    oRequestParser = NEW JsonAPIRequestParser(jsonInput).
     
    ASSIGN lcPayload = oRequestParser:getPayloadLongChar().
   
    oJsonPayLoad = fnTextToJsonObject(lcPayload).

    RUN pi-read-input (INPUT oJsonPayLoad).

    IF NOT VALID-HANDLE(apiHandler) THEN DO:
        RUN esp/roboteasy/robotapi032.p PERSISTENT SET apiHandler.
    END.

    RUN pi-move-relatorios-rpw IN apiHandler (INPUT  TABLE tt-move-arquivo,
                                              OUTPUT TABLE tt-resultado-arquivo).

    DELETE PROCEDURE apiHandler NO-ERROR.

    jsonOutput = NEW JSONObject().

    ASSIGN iRet = 500.
    jsonObjectOutput = NEW JsonObject().

    IF  TEMP-TABLE tt-resultado-arquivo:HAS-RECORDS THEN DO:
        ASSIGN iRet = 200.
        jsonObjectOutput:READ(DATASET dsResultadoArquivo:HANDLE).
        ASSIGN lPassou = YES.
    END.
    
    IF  lPassou = NO THEN DO:
        ASSIGN iRet = 204.
        jsonObjectOutput:READ(TEMP-TABLE tt-resultado-arquivo:HANDLE).
    END.

    jsonOutput = JsonAPIResponseBuilder:ok(jsonObjectOutput, iRet).

    RETURN "OK":U.

END PROCEDURE.


PROCEDURE pi-read-input:

    DEFINE INPUT PARAMETER oJsonPayLoad AS JsonObject NO-UNDO.

    DEFINE VARIABLE oJsonAux      AS JsonObject NO-UNDO.
    DEFINE VARIABLE oJsonArrayAux AS JsonArray  NO-UNDO.
    DEFINE VARIABLE i-length      AS INTEGER    NO-UNDO.
    DEFINE VARIABLE i-aux         AS INTEGER    NO-UNDO.

    IF oJsonPayLoad:Has("criaPedidos") THEN DO:
        oJsonArrayAux = oJsonPayLoad:GetJsonArray("criaPedidos").
    
        ASSIGN i-length = oJsonArrayAux:LENGTH.
    
        IF i-length > 0 THEN
        DO i-aux = 1 TO i-length:
            oJsonAux = oJsonArrayAux:GetJsonObject(i-aux).

            CREATE tt-cria-pedido.
            ASSIGN tt-cria-pedido.cod_prog_dtsul           = IF oJsonAux:Has("codPrograma")        THEN oJsonAux:GetCharacter("codPrograma")        ELSE "" NO-ERROR.
            ASSIGN tt-cria-pedido.dat_criac_ped_exec       = IF oJsonAux:Has("dataPedido")         THEN oJsonAux:GetDate("dataPedido")              ELSE ?  NO-ERROR.
            ASSIGN tt-cria-pedido.hra_criac_ped_exec       = IF oJsonAux:Has("horaPedido")         THEN oJsonAux:GetCharacter("horaPedido")         ELSE "" NO-ERROR.
            ASSIGN tt-cria-pedido.cod_servid_exec          = IF oJsonAux:Has("servidor")           THEN oJsonAux:GetCharacter("servidor")           ELSE "" NO-ERROR.
            ASSIGN tt-cria-pedido.nom_prog_ext             = IF oJsonAux:Has("programaExterno")    THEN oJsonAux:GetCharacter("programaExterno")    ELSE "" NO-ERROR.
            ASSIGN tt-cria-pedido.cdn_estil_dwb            = IF oJsonAux:Has("estiloDwb")          THEN oJsonAux:GetInteger("estiloDwb")            ELSE 0  NO-ERROR.
            ASSIGN tt-cria-pedido.cod_dwb_output           = IF oJsonAux:Has("destino")            THEN oJsonAux:GetCharacter("destino")            ELSE "" NO-ERROR.
            ASSIGN tt-cria-pedido.nom_dwb_printer          = IF oJsonAux:Has("nomeArquivo")        THEN oJsonAux:GetCharacter("nomeArquivo")        ELSE "" NO-ERROR.
            ASSIGN tt-cria-pedido.log_dwb_print_parameters = IF oJsonAux:Has("imprimeParam")       THEN oJsonAux:GetLogical("imprimeParam")         ELSE ?  NO-ERROR.
            ASSIGN tt-cria-pedido.cod_empresa              = IF oJsonAux:Has("empresa")            THEN oJsonAux:GetCharacter("empresa")            ELSE "" NO-ERROR.
            ASSIGN tt-cria-pedido.cod_estab                = IF oJsonAux:Has("estabelecimento")    THEN oJsonAux:GetCharacter("estabelecimento")    ELSE "" NO-ERROR.
            ASSIGN tt-cria-pedido.cod_usuario              = IF oJsonAux:Has("codigoUsuario")      THEN oJsonAux:GetCharacter("codigoUsuario")      ELSE "" NO-ERROR.
            ASSIGN tt-cria-pedido.cod_unid_negoc           = IF oJsonAux:Has("unidNegocio")        THEN oJsonAux:GetCharacter("unidNegocio")        ELSE "" NO-ERROR.
            ASSIGN tt-cria-pedido.cod_funcao_negoc_empres  = IF oJsonAux:Has("funcaoNegocEmpresa") THEN oJsonAux:GetCharacter("funcaoNegocEmpresa") ELSE "" NO-ERROR.
            ASSIGN tt-cria-pedido.cod_plano_ccusto         = IF oJsonAux:Has("planoCusto")         THEN oJsonAux:GetCharacter("planoCusto")         ELSE "" NO-ERROR.
            ASSIGN tt-cria-pedido.cod_ccusto               = IF oJsonAux:Has("centroCusto")        THEN oJsonAux:GetCharacter("centroCusto")        ELSE "" NO-ERROR.
            ASSIGN tt-cria-pedido.cod_agrpdor              = IF oJsonAux:Has("codigoAgrupador")    THEN oJsonAux:GetCharacter("codigoAgrupador")    ELSE "" NO-ERROR.
        END.
    END.

    IF oJsonPayLoad:Has("campos") THEN DO:
        oJsonArrayAux = oJsonPayLoad:GetJsonArray("campos").
    
        ASSIGN i-length = oJsonArrayAux:LENGTH.
    
        IF i-length > 0 THEN
        DO i-aux = 1 TO i-length:
            oJsonAux = oJsonArrayAux:GetJsonObject(i-aux).

            CREATE tt-campos.
            ASSIGN tt-campos.campo = IF oJsonAux:Has("campo") THEN oJsonAux:GetCharacter("campo") ELSE "" NO-ERROR.
            ASSIGN tt-campos.tipo  = IF oJsonAux:Has("tipo")  THEN oJsonAux:GetCharacter("tipo")  ELSE "" NO-ERROR.
            ASSIGN tt-campos.valor = IF oJsonAux:Has("valor") THEN oJsonAux:GetCharacter("valor") ELSE "" NO-ERROR.
        END.
    END.

    IF oJsonPayLoad:Has("CE0403") THEN DO:
        oJsonArrayAux = oJsonPayLoad:GetJsonArray("CE0403").
    
        ASSIGN i-length = oJsonArrayAux:LENGTH.
    
        IF i-length > 0 THEN
        DO i-aux = 1 TO i-length:
            oJsonAux = oJsonArrayAux:GetJsonObject(i-aux).

            CREATE tt-param-ce0403.
            ASSIGN tt-param-ce0403.destino           = IF oJsonAux:Has("destino")           THEN oJsonAux:GetInteger("destino")           ELSE ? NO-ERROR.
            ASSIGN tt-param-ce0403.arquivo           = IF oJsonAux:Has("arquivo")           THEN oJsonAux:GetCharacter("arquivo")         ELSE ? NO-ERROR.
            ASSIGN tt-param-ce0403.usuario           = IF oJsonAux:Has("usuario")           THEN oJsonAux:GetCharacter("usuario")         ELSE ? NO-ERROR.
            ASSIGN tt-param-ce0403.data-exec         = IF oJsonAux:Has("data-exec")         THEN oJsonAux:GetDate("data-exec")            ELSE ? NO-ERROR.
            ASSIGN tt-param-ce0403.hora-exec         = IF oJsonAux:Has("hora-exec")         THEN oJsonAux:GetInteger("hora-exec")         ELSE ? NO-ERROR.
            ASSIGN tt-param-ce0403.dt-ini            = IF oJsonAux:Has("dt-ini")            THEN oJsonAux:GetDate("dt-ini")               ELSE ? NO-ERROR.
            ASSIGN tt-param-ce0403.dt-fim            = IF oJsonAux:Has("dt-fim")            THEN oJsonAux:GetDate("dt-fim")               ELSE ? NO-ERROR.
            ASSIGN tt-param-ce0403.c-conta-ini       = IF oJsonAux:Has("c-conta-ini")       THEN oJsonAux:GetCharacter("c-conta-ini")     ELSE ? NO-ERROR.
            ASSIGN tt-param-ce0403.c-conta-fim       = IF oJsonAux:Has("c-conta-fim")       THEN oJsonAux:GetCharacter("c-conta-fim")     ELSE ? NO-ERROR.
            ASSIGN tt-param-ce0403.c-ccusto-ini      = IF oJsonAux:Has("c-ccusto-ini")      THEN oJsonAux:GetCharacter("c-ccusto-ini")    ELSE ? NO-ERROR.
            ASSIGN tt-param-ce0403.c-ccusto-fim      = IF oJsonAux:Has("c-ccusto-fim")      THEN oJsonAux:GetCharacter("c-ccusto-fim")    ELSE ? NO-ERROR.
            ASSIGN tt-param-ce0403.i-ge-ini          = IF oJsonAux:Has("i-ge-ini")          THEN oJsonAux:GetInteger("i-ge-ini")          ELSE ? NO-ERROR.
            ASSIGN tt-param-ce0403.i-ge-fim          = IF oJsonAux:Has("i-ge-fim")          THEN oJsonAux:GetInteger("i-ge-fim")          ELSE ? NO-ERROR.
            ASSIGN tt-param-ce0403.c-estab-ini       = IF oJsonAux:Has("c-estab-ini")       THEN oJsonAux:GetCharacter("c-estab-ini")     ELSE ? NO-ERROR.
            ASSIGN tt-param-ce0403.c-estab-fim       = IF oJsonAux:Has("c-estab-fim")       THEN oJsonAux:GetCharacter("c-estab-fim")     ELSE ? NO-ERROR.
            ASSIGN tt-param-ce0403.c-unid-neg-ini    = IF oJsonAux:Has("c-unid-neg-ini")    THEN oJsonAux:GetCharacter("c-unid-neg-ini")  ELSE ? NO-ERROR.
            ASSIGN tt-param-ce0403.c-unid-neg-fim    = IF oJsonAux:Has("c-unid-neg-fim")    THEN oJsonAux:GetCharacter("c-unid-neg-fim")  ELSE ? NO-ERROR.
            ASSIGN tt-param-ce0403.i-nr-page         = IF oJsonAux:Has("i-nr-page")         THEN oJsonAux:GetInteger("i-nr-page")         ELSE ? NO-ERROR.
            ASSIGN tt-param-ce0403.i-abertura        = IF oJsonAux:Has("i-abertura")        THEN oJsonAux:GetInteger("i-abertura")        ELSE ? NO-ERROR.
            ASSIGN tt-param-ce0403.i-fechamento      = IF oJsonAux:Has("i-fechamento")      THEN oJsonAux:GetInteger("i-fechamento")      ELSE ? NO-ERROR.
            ASSIGN tt-param-ce0403.i-tipo-custo      = IF oJsonAux:Has("i-tipo-custo")      THEN oJsonAux:GetInteger("i-tipo-custo")      ELSE ? NO-ERROR.
            ASSIGN tt-param-ce0403.i-impr-cabecalho  = IF oJsonAux:Has("i-impr-cabecalho")  THEN oJsonAux:GetInteger("i-impr-cabecalho ") ELSE ? NO-ERROR.
            ASSIGN tt-param-ce0403.c-tipo-custo      = IF oJsonAux:Has("c-tipo-custo")      THEN oJsonAux:GetCharacter("c-tipo-custo")    ELSE ? NO-ERROR.
            ASSIGN tt-param-ce0403.i-cenario         = IF oJsonAux:Has("i-cenario")         THEN oJsonAux:GetInteger("i-cenario")         ELSE ? NO-ERROR.
            ASSIGN tt-param-ce0403.c-cenario         = IF oJsonAux:Has("c-cenario")         THEN oJsonAux:GetCharacter("c-cenario")       ELSE ? NO-ERROR.
            ASSIGN tt-param-ce0403.c-destino         = IF oJsonAux:Has("c-destino")         THEN oJsonAux:GetCharacter("c-destino")       ELSE ? NO-ERROR.
            ASSIGN tt-param-ce0403.l-imp-param       = IF oJsonAux:Has("l-imp-param")       THEN oJsonAux:GetLogical("l-imp-param")       ELSE ? NO-ERROR.
            ASSIGN tt-param-ce0403.nao-formata-excel = IF oJsonAux:Has("nao-formata-excel") THEN oJsonAux:GetLogical("nao-formata-excel") ELSE ? NO-ERROR.
        END.
    END.

    IF oJsonPayLoad:Has("FT0708") THEN DO:
        oJsonArrayAux = oJsonPayLoad:GetJsonArray("FT0708").
    
        ASSIGN i-length = oJsonArrayAux:LENGTH.
    
        IF i-length > 0 THEN
        DO i-aux = 1 TO i-length:
            oJsonAux = oJsonArrayAux:GetJsonObject(i-aux).

            CREATE tt-param-ft0708.
            ASSIGN tt-param-ft0708.destino                = IF oJsonAux:Has("destino")                THEN oJsonAux:GetInteger("destino")                ELSE ? NO-ERROR.
            ASSIGN tt-param-ft0708.arquivo                = IF oJsonAux:Has("arquivo")                THEN oJsonAux:GetCharacter("arquivo")              ELSE ? NO-ERROR.
            ASSIGN tt-param-ft0708.usuario                = IF oJsonAux:Has("usuario")                THEN oJsonAux:GetCharacter("usuario")              ELSE ? NO-ERROR.
            ASSIGN tt-param-ft0708.data-exec              = IF oJsonAux:Has("data-exec")              THEN oJsonAux:GetDate("data-exec")                 ELSE ? NO-ERROR.
            ASSIGN tt-param-ft0708.hora-exec              = IF oJsonAux:Has("hora-exec")              THEN oJsonAux:GetInteger("hora-exec")              ELSE ? NO-ERROR.
            ASSIGN tt-param-ft0708.classifica             = IF oJsonAux:Has("classifica")             THEN oJsonAux:GetInteger("classifica")             ELSE ? NO-ERROR.
            ASSIGN tt-param-ft0708.desc-classifica        = IF oJsonAux:Has("desc-classifica")        THEN oJsonAux:GetCharacter("desc-classifica")      ELSE ? NO-ERROR.
            ASSIGN tt-param-ft0708.c-estabel-ini          = IF oJsonAux:Has("c-estabel-ini")          THEN oJsonAux:GetCharacter("c-estabel-ini")        ELSE ? NO-ERROR.
            ASSIGN tt-param-ft0708.c-estabel-fim          = IF oJsonAux:Has("c-estabel-fim")          THEN oJsonAux:GetCharacter("c-estabel-fim")        ELSE ? NO-ERROR.
            ASSIGN tt-param-ft0708.da-emissao-ini         = IF oJsonAux:Has("da-emissao-ini")         THEN oJsonAux:GetDate("da-emissao-ini")            ELSE ? NO-ERROR.
            ASSIGN tt-param-ft0708.da-emissao-fim         = IF oJsonAux:Has("da-emissao-fim")         THEN oJsonAux:GetDate("da-emissao-fim")            ELSE ? NO-ERROR.
            ASSIGN tt-param-ft0708.c-conta-ini            = IF oJsonAux:Has("c-conta-ini")            THEN oJsonAux:GetCharacter("c-conta-ini")          ELSE ? NO-ERROR.
            ASSIGN tt-param-ft0708.c-conta-fim            = IF oJsonAux:Has("c-conta-fim")            THEN oJsonAux:GetCharacter("c-conta-fim")          ELSE ? NO-ERROR.
            ASSIGN tt-param-ft0708.c-cc-conta-ini         = IF oJsonAux:Has("c-cc-conta-ini")         THEN oJsonAux:GetCharacter("c-cc-conta-ini")       ELSE ? NO-ERROR.
            ASSIGN tt-param-ft0708.c-cc-conta-fim         = IF oJsonAux:Has("c-cc-conta-fim")         THEN oJsonAux:GetCharacter("c-cc-conta-fim")       ELSE ? NO-ERROR.
            ASSIGN tt-param-ft0708.c-pais-ini             = IF oJsonAux:Has("c-pais-ini")             THEN oJsonAux:GetCharacter("c-pais-ini")           ELSE ? NO-ERROR.
            ASSIGN tt-param-ft0708.c-pais-fim             = IF oJsonAux:Has("c-pais-fim")             THEN oJsonAux:GetCharacter("c-pais-fim")           ELSE ? NO-ERROR.
            ASSIGN tt-param-ft0708.c-uf-ini               = IF oJsonAux:Has("c-uf-ini")               THEN oJsonAux:GetCharacter("c-uf-ini")             ELSE ? NO-ERROR.
            ASSIGN tt-param-ft0708.c-uf-fim               = IF oJsonAux:Has("c-uf-fim")               THEN oJsonAux:GetCharacter("c-uf-fim")             ELSE ? NO-ERROR.
            ASSIGN tt-param-ft0708.l-vcto-impostos        = IF oJsonAux:Has("l-vcto-impostos")        THEN oJsonAux:GetLogical("l-vcto-impostos")        ELSE ? NO-ERROR.
            ASSIGN tt-param-ft0708.da-ipi                 = IF oJsonAux:Has("da-ipi")                 THEN oJsonAux:GetDate("da-ipi")                    ELSE ? NO-ERROR.
            ASSIGN tt-param-ft0708.da-icms                = IF oJsonAux:Has("da-icms")                THEN oJsonAux:GetDate("da-icms")                   ELSE ? NO-ERROR.
            ASSIGN tt-param-ft0708.da-iss                 = IF oJsonAux:Has("da-iss")                 THEN oJsonAux:GetDate("da-iss")                    ELSE ? NO-ERROR.
            ASSIGN tt-param-ft0708.da-irrf                = IF oJsonAux:Has("da-irrf")                THEN oJsonAux:GetDate("da-irrf")                   ELSE ? NO-ERROR.
            ASSIGN tt-param-ft0708.da-pis                 = IF oJsonAux:Has("da-pis")                 THEN oJsonAux:GetDate("da-pis")                    ELSE ? NO-ERROR.
            ASSIGN tt-param-ft0708.da-cofins              = IF oJsonAux:Has("da-cofins")              THEN oJsonAux:GetDate("da-cofins")                 ELSE ? NO-ERROR.
            ASSIGN tt-param-ft0708.da-icms-subs           = IF oJsonAux:Has("da-icms-subs")           THEN oJsonAux:GetDate("da-icms-subs")              ELSE ? NO-ERROR.
            ASSIGN tt-param-ft0708.da-inss-ret            = IF oJsonAux:Has("da-inss-ret")            THEN oJsonAux:GetDate("da-inss-ret ")              ELSE ? NO-ERROR.
            ASSIGN tt-param-ft0708.da-fet                 = IF oJsonAux:Has("da-fet")                 THEN oJsonAux:GetDate("da-fet")                    ELSE ? NO-ERROR.
            ASSIGN tt-param-ft0708.rs-tipo                = IF oJsonAux:Has("rs-tipo")                THEN oJsonAux:GetInteger("rs-tipo")                ELSE ? NO-ERROR.
            ASSIGN tt-param-ft0708.rs-moeda               = IF oJsonAux:Has("rs-moeda")               THEN oJsonAux:GetInteger("rs-moeda")               ELSE ? NO-ERROR.
            ASSIGN tt-param-ft0708.rs-vencimento          = IF oJsonAux:Has("rs-vencimento")          THEN oJsonAux:GetInteger("rs-vencimento")          ELSE ? NO-ERROR.
            ASSIGN tt-param-ft0708.rs-cotacao             = IF oJsonAux:Has("rs-cotacao")             THEN oJsonAux:GetInteger("rs-cotacao")             ELSE ? NO-ERROR.
            ASSIGN tt-param-ft0708.l-notas-fisc           = IF oJsonAux:Has("l-notas-fisc")           THEN oJsonAux:GetLogical("l-notas-fisc")           ELSE ? NO-ERROR.
            ASSIGN tt-param-ft0708.l-proc-exp             = IF oJsonAux:Has("l-proc-exp")             THEN oJsonAux:GetLogical("l-proc-exp")             ELSE ? NO-ERROR.
            ASSIGN tt-param-ft0708.l-processa-ifrs        = IF oJsonAux:Has("l-processa-ifrs")        THEN oJsonAux:GetLogical("l-processa-ifrs")        ELSE ? NO-ERROR.
            ASSIGN tt-param-ft0708.desc-tipo              = IF oJsonAux:Has("desc-tipo")              THEN oJsonAux:GetCharacter("desc-tipo")            ELSE ? NO-ERROR.
            ASSIGN tt-param-ft0708.rs-execucao            = IF oJsonAux:Has("rs-execucao")            THEN oJsonAux:GetInteger("rs-execucao")            ELSE ? NO-ERROR.
            ASSIGN tt-param-ft0708.l-imprime-centro-custo = IF oJsonAux:Has("l-imprime-centro-custo") THEN oJsonAux:GetLogical("l-imprime-centro-custo") ELSE ? NO-ERROR.
            ASSIGN tt-param-ft0708.l-valida-conta         = IF oJsonAux:Has("l-valida-conta")         THEN oJsonAux:GetLogical("l-valida-conta")         ELSE ? NO-ERROR.        
        END.
    END.

    IF oJsonPayLoad:Has("FT0709") THEN DO:
        oJsonArrayAux = oJsonPayLoad:GetJsonArray("FT0709").
    
        ASSIGN i-length = oJsonArrayAux:LENGTH.
    
        IF i-length > 0 THEN
        DO i-aux = 1 TO i-length:
            oJsonAux = oJsonArrayAux:GetJsonObject(i-aux).

            CREATE tt-param-ft0709.
            ASSIGN tt-param-ft0709.destino          = IF oJsonAux:Has("destino")          THEN oJsonAux:GetInteger("destino")            ELSE ? NO-ERROR.
            ASSIGN tt-param-ft0709.arquivo          = IF oJsonAux:Has("arquivo")          THEN oJsonAux:GetCharacter("arquivo")          ELSE ? NO-ERROR.
            ASSIGN tt-param-ft0709.usuario          = IF oJsonAux:Has("usuario")          THEN oJsonAux:GetCharacter("usuario")          ELSE ? NO-ERROR.
            ASSIGN tt-param-ft0709.data-exec        = IF oJsonAux:Has("data-exec")        THEN oJsonAux:GetDate("data-exec")             ELSE ? NO-ERROR.
            ASSIGN tt-param-ft0709.hora-exec        = IF oJsonAux:Has("hora-exec")        THEN oJsonAux:GetInteger("hora-exec")          ELSE ? NO-ERROR.
            ASSIGN tt-param-ft0709.classifica       = IF oJsonAux:Has("classifica")       THEN oJsonAux:GetInteger("classifica")         ELSE ? NO-ERROR.
            ASSIGN tt-param-ft0709.desc-classifica  = IF oJsonAux:Has("desc-classifica")  THEN oJsonAux:GetCharacter("desc-classifica")  ELSE ? NO-ERROR.
            ASSIGN tt-param-ft0709.c-estabel-ini    = IF oJsonAux:Has("c-estabel-ini")    THEN oJsonAux:GetCharacter("c-estabel-ini")    ELSE ? NO-ERROR.
            ASSIGN tt-param-ft0709.c-estabel-fim    = IF oJsonAux:Has("c-estabel-fim")    THEN oJsonAux:GetCharacter("c-estabel-fim")    ELSE ? NO-ERROR.
            ASSIGN tt-param-ft0709.da-emissao-ini   = IF oJsonAux:Has("da-emissao-ini")   THEN oJsonAux:GetDate("da-emissao-ini")        ELSE ? NO-ERROR.
            ASSIGN tt-param-ft0709.da-emissao-fim   = IF oJsonAux:Has("da-emissao-fim")   THEN oJsonAux:GetDate("da-emissao-fim")        ELSE ? NO-ERROR.
            ASSIGN tt-param-ft0709.c-conta-ini      = IF oJsonAux:Has("c-conta-ini")      THEN oJsonAux:GetCharacter("c-conta-ini")      ELSE ? NO-ERROR.
            ASSIGN tt-param-ft0709.c-conta-fim      = IF oJsonAux:Has("c-conta-fim")      THEN oJsonAux:GetCharacter("c-conta-fim")      ELSE ? NO-ERROR.
            ASSIGN tt-param-ft0709.c-cc-conta-ini   = IF oJsonAux:Has("c-cc-conta-ini")   THEN oJsonAux:GetCharacter("c-cc-conta-ini")   ELSE ? NO-ERROR.
            ASSIGN tt-param-ft0709.c-cc-conta-fim   = IF oJsonAux:Has("c-cc-conta-fim")   THEN oJsonAux:GetCharacter("c-cc-conta-fim")   ELSE ? NO-ERROR.
            ASSIGN tt-param-ft0709.c-unid-negoc-ini = IF oJsonAux:Has("c-unid-negoc-ini") THEN oJsonAux:GetCharacter("c-unid-negoc-ini") ELSE ? NO-ERROR.
            ASSIGN tt-param-ft0709.c-unid-negoc-fim = IF oJsonAux:Has("c-unid-negoc-fim") THEN oJsonAux:GetCharacter("c-unid-negoc-fim") ELSE ? NO-ERROR.
            ASSIGN tt-param-ft0709.i-termo-abe      = IF oJsonAux:Has("i-termo-abe")      THEN oJsonAux:GetInteger("i-termo-abe")        ELSE ? NO-ERROR.
            ASSIGN tt-param-ft0709.i-termo-enc      = IF oJsonAux:Has("i-termo-enc")      THEN oJsonAux:GetInteger("i-termo-enc")        ELSE ? NO-ERROR.
            ASSIGN tt-param-ft0709.i-pag-ini        = IF oJsonAux:Has("i-pag-ini")        THEN oJsonAux:GetInteger("i-pag-ini")          ELSE ? NO-ERROR.
            ASSIGN tt-param-ft0709.elimina-sumario  = IF oJsonAux:Has("elimina-sumario")  THEN oJsonAux:GetLogical("elimina-sumario")    ELSE ? NO-ERROR.
            ASSIGN tt-param-ft0709.elimina-fat-ant  = IF oJsonAux:Has("elimina-fat-ant")  THEN oJsonAux:GetLogical("elimina-fat-ant")    ELSE ? NO-ERROR.
            ASSIGN tt-param-ft0709.sumariar         = IF oJsonAux:Has("sumariar")         THEN oJsonAux:GetLogical("sumariar")           ELSE ? NO-ERROR.
            ASSIGN tt-param-ft0709.quebra-pagina    = IF oJsonAux:Has("quebra-pagina")    THEN oJsonAux:GetLogical("quebra-pagina")      ELSE ? NO-ERROR.
            ASSIGN tt-param-ft0709.l-diario-normal  = IF oJsonAux:Has("l-diario-normal")  THEN oJsonAux:GetLogical("l-diario-normal")    ELSE ? NO-ERROR.
            ASSIGN tt-param-ft0709.l-diario-ifrs    = IF oJsonAux:Has("l-diario-ifrs")    THEN oJsonAux:GetLogical("l-diario-ifrs")      ELSE ? NO-ERROR.
            ASSIGN tt-param-ft0709.i-nome-pag       = IF oJsonAux:Has("i-nome-pag")       THEN oJsonAux:GetInteger("i-nome-pag")         ELSE ? NO-ERROR.
        END.
    END.

    IF oJsonPayLoad:Has("OF0410") THEN DO:
        oJsonArrayAux = oJsonPayLoad:GetJsonArray("OF0410").
    
        ASSIGN i-length = oJsonArrayAux:LENGTH.
    
        IF i-length > 0 THEN
        DO i-aux = 1 TO i-length:
            oJsonAux = oJsonArrayAux:GetJsonObject(i-aux).

            CREATE tt-param-of0410.
            ASSIGN tt-param-of0410.destino         = IF oJsonAux:Has("destino")          THEN oJsonAux:GetInteger("destino")           ELSE ? NO-ERROR.
            ASSIGN tt-param-of0410.arquivo         = IF oJsonAux:Has("arquivo")          THEN oJsonAux:GetCharacter("arquivo")         ELSE ? NO-ERROR.
            ASSIGN tt-param-of0410.usuario         = IF oJsonAux:Has("usuario")          THEN oJsonAux:GetCharacter("usuario")         ELSE ? NO-ERROR.
            ASSIGN tt-param-of0410.data-exec       = IF oJsonAux:Has("data-exec")        THEN oJsonAux:GetDate("data-exec")            ELSE ? NO-ERROR.
            ASSIGN tt-param-of0410.hora-exec       = IF oJsonAux:Has("hora-exec")        THEN oJsonAux:GetInteger("hora-exec")         ELSE ? NO-ERROR.
            ASSIGN tt-param-of0410.classifica      = IF oJsonAux:Has("classifica")       THEN oJsonAux:GetInteger("classifica")        ELSE ? NO-ERROR.
            ASSIGN tt-param-of0410.desc-classifica = IF oJsonAux:Has("desc-classifica")  THEN oJsonAux:GetCharacter("desc-classifica") ELSE ? NO-ERROR.
            ASSIGN tt-param-of0410.modelo          = IF oJsonAux:Has("modelo")           THEN oJsonAux:GetCharacter("modelo")          ELSE ? NO-ERROR.
            ASSIGN tt-param-of0410.cEstab          = IF oJsonAux:Has("cEstab")           THEN oJsonAux:GetCharacter("cEstab")          ELSE ? NO-ERROR.
            ASSIGN tt-param-of0410.cDtIni          = IF oJsonAux:Has("cDtIni")           THEN oJsonAux:GetDate("cDtIni")               ELSE ? NO-ERROR.
            ASSIGN tt-param-of0410.cDtFim          = IF oJsonAux:Has("cDtFim")           THEN oJsonAux:GetDate("cDtFim")               ELSE ? NO-ERROR.
            ASSIGN tt-param-of0410.cEstadoIni      = IF oJsonAux:Has("cEstadoIni")       THEN oJsonAux:GetCharacter("cEstadoIni")      ELSE ? NO-ERROR.
            ASSIGN tt-param-of0410.cEstadoFim      = IF oJsonAux:Has("cEstadoFim")       THEN oJsonAux:GetCharacter("cEstadoFim")      ELSE ? NO-ERROR.
            ASSIGN tt-param-of0410.cEmitIni        = IF oJsonAux:Has("cEmitIni")         THEN oJsonAux:GetInteger("cEmitIni")          ELSE ? NO-ERROR.
            ASSIGN tt-param-of0410.cEmitFim        = IF oJsonAux:Has("cEmitFim")         THEN oJsonAux:GetInteger("cEmitFim")          ELSE ? NO-ERROR.
            ASSIGN tt-param-of0410.cDocIni         = IF oJsonAux:Has("cDocIni")          THEN oJsonAux:GetCharacter("cDocIni")         ELSE ? NO-ERROR.
            ASSIGN tt-param-of0410.cDocFim         = IF oJsonAux:Has("cDocFim")          THEN oJsonAux:GetCharacter("cDocFim")         ELSE ? NO-ERROR.
            ASSIGN tt-param-of0410.cModIni         = IF oJsonAux:Has("cModIni")          THEN oJsonAux:GetCharacter("cModIni")         ELSE ? NO-ERROR.
            ASSIGN tt-param-of0410.cModFim         = IF oJsonAux:Has("cModFim")          THEN oJsonAux:GetCharacter("cModFim")         ELSE ? NO-ERROR.
        END.
    END.

    IF oJsonPayLoad:Has("OF0520") THEN DO:
        oJsonArrayAux = oJsonPayLoad:GetJsonArray("OF0520").
    
        ASSIGN i-length = oJsonArrayAux:LENGTH.
    
        IF i-length > 0 THEN
        DO i-aux = 1 TO i-length:
            oJsonAux = oJsonArrayAux:GetJsonObject(i-aux).

            CREATE tt-param-of0520.
            ASSIGN tt-param-of0520.destino          = IF oJsonAux:Has("destino")         THEN oJsonAux:GetInteger("destino")           ELSE ? NO-ERROR.
            ASSIGN tt-param-of0520.arquivo          = IF oJsonAux:Has("arquivo")         THEN oJsonAux:GetCharacter("arquivo")         ELSE ? NO-ERROR.
            ASSIGN tt-param-of0520.usuario          = IF oJsonAux:Has("usuario")         THEN oJsonAux:GetCharacter("usuario")         ELSE ? NO-ERROR.
            ASSIGN tt-param-of0520.data-exec        = IF oJsonAux:Has("data-exec")       THEN oJsonAux:GetDate("data-exec")            ELSE ? NO-ERROR.
            ASSIGN tt-param-of0520.hora-exec        = IF oJsonAux:Has("hora-exec")       THEN oJsonAux:GetInteger("hora-exec")         ELSE ? NO-ERROR.
            ASSIGN tt-param-of0520.cod-estabel-ini  = IF oJsonAux:Has("cod-estabel-ini") THEN oJsonAux:GetCharacter("cod-estabel-ini") ELSE ? NO-ERROR.
            ASSIGN tt-param-of0520.cod-estabel-fim  = IF oJsonAux:Has("cod-estabel-fim") THEN oJsonAux:GetCharacter("cod-estabel-fim") ELSE ? NO-ERROR.
            ASSIGN tt-param-of0520.dt-docto-ini     = IF oJsonAux:Has("dt-docto-ini")    THEN oJsonAux:GetDate("dt-docto-ini")         ELSE ? NO-ERROR.
            ASSIGN tt-param-of0520.dt-docto-fim     = IF oJsonAux:Has("dt-docto-fim")    THEN oJsonAux:GetDate("dt-docto-fim")         ELSE ? NO-ERROR.
            ASSIGN tt-param-of0520.resumo           = IF oJsonAux:Has("resumo")          THEN oJsonAux:GetLogical("resumo")            ELSE ? NO-ERROR.
            ASSIGN tt-param-of0520.resumo-mes       = IF oJsonAux:Has("resumo-mes")      THEN oJsonAux:GetLogical("resumo-mes")        ELSE ? NO-ERROR.
            ASSIGN tt-param-of0520.tot-icms         = IF oJsonAux:Has("tot-icms")        THEN oJsonAux:GetLogical("tot-icms")          ELSE ? NO-ERROR.
            ASSIGN tt-param-of0520.imp-for          = IF oJsonAux:Has("imp-for")         THEN oJsonAux:GetLogical("imp-for")           ELSE ? NO-ERROR.
            ASSIGN tt-param-of0520.periodo-ant      = IF oJsonAux:Has("periodo-ant")     THEN oJsonAux:GetLogical("periodo-ant")       ELSE ? NO-ERROR.
            ASSIGN tt-param-of0520.imp-ins          = IF oJsonAux:Has("imp-ins")         THEN oJsonAux:GetLogical("imp-ins")           ELSE ? NO-ERROR.
            ASSIGN tt-param-of0520.conta-contabil   = IF oJsonAux:Has("conta-contabil")  THEN oJsonAux:GetLogical("conta-contabil ")   ELSE ? NO-ERROR.
            ASSIGN tt-param-of0520.at-perm          = IF oJsonAux:Has("at-perm")         THEN oJsonAux:GetLogical("at-perm")           ELSE ? NO-ERROR.
            ASSIGN tt-param-of0520.separadores      = IF oJsonAux:Has("separadores")     THEN oJsonAux:GetLogical("separadores")       ELSE ? NO-ERROR.
            ASSIGN tt-param-of0520.previa           = IF oJsonAux:Has("previa")          THEN oJsonAux:GetCharacter("previa")          ELSE ? NO-ERROR.
            ASSIGN tt-param-of0520.documentos       = IF oJsonAux:Has("documentos ")     THEN oJsonAux:GetCharacter("documentos")      ELSE ? NO-ERROR.
            ASSIGN tt-param-of0520.da-icms-ini      = IF oJsonAux:Has("da-icms-ini")     THEN oJsonAux:GetDate("da-icms-ini")          ELSE ? NO-ERROR.
            ASSIGN tt-param-of0520.da-icms-fim      = IF oJsonAux:Has("da-icms-fim")     THEN oJsonAux:GetDate("da-icms-fim")          ELSE ? NO-ERROR.
            ASSIGN tt-param-of0520.incentivado      = IF oJsonAux:Has("incentivado")     THEN oJsonAux:GetLogical("incentivado")       ELSE ? NO-ERROR.
            ASSIGN tt-param-of0520.relat            = IF oJsonAux:Has("relat")           THEN oJsonAux:GetCharacter("relat")           ELSE ? NO-ERROR.
            ASSIGN tt-param-of0520.eliqui           = IF oJsonAux:Has("eliqui")          THEN oJsonAux:GetLogical("eliqui")            ELSE ? NO-ERROR.
            ASSIGN tt-param-of0520.c-nomest         = IF oJsonAux:Has("c-nomest")        THEN oJsonAux:GetCharacter("c-nomest")        ELSE ? NO-ERROR.
            ASSIGN tt-param-of0520.c-estado         = IF oJsonAux:Has("c-estado")        THEN oJsonAux:GetCharacter("c-estado")        ELSE ? NO-ERROR.
            ASSIGN tt-param-of0520.c-cgc            = IF oJsonAux:Has("c-cgc")           THEN oJsonAux:GetCharacter("c-cgc")           ELSE ? NO-ERROR.
            ASSIGN tt-param-of0520.c-insestad       = IF oJsonAux:Has("c-insestad")      THEN oJsonAux:GetCharacter("c-insestad")      ELSE ? NO-ERROR.
            ASSIGN tt-param-of0520.c-cgc-1          = IF oJsonAux:Has("c-cgc-1")         THEN oJsonAux:GetCharacter("c-cgc-1")         ELSE ? NO-ERROR.
            ASSIGN tt-param-of0520.c-fornecedor     = IF oJsonAux:Has("c-fornecedor")    THEN oJsonAux:GetCharacter("c-fornecedor")    ELSE ? NO-ERROR.
            ASSIGN tt-param-of0520.c-ins-est        = IF oJsonAux:Has("c-ins-est")       THEN oJsonAux:GetCharacter("c-ins-est")       ELSE ? NO-ERROR.
            ASSIGN tt-param-of0520.c-titulo         = IF oJsonAux:Has("c-titulo")        THEN oJsonAux:GetCharacter("c-titulo")        ELSE ? NO-ERROR.
            ASSIGN tt-param-of0520.imp-cnpj         = IF oJsonAux:Has("imp-cnpj")        THEN oJsonAux:GetLogical("imp-cnpj")          ELSE ? NO-ERROR.
            ASSIGN tt-param-of0520.imp-cab          = IF oJsonAux:Has("imp-cab")         THEN oJsonAux:GetCharacter("imp-cab")         ELSE ? NO-ERROR.
            ASSIGN tt-param-of0520.l-cfop-serv      = IF oJsonAux:Has("l-cfop-serv")     THEN oJsonAux:GetLogical("l-cfop-serv")       ELSE ? NO-ERROR.
            
        END.
    END.    

    IF oJsonPayLoad:Has("OF0620") THEN DO:
        oJsonArrayAux = oJsonPayLoad:GetJsonArray("OF0620").
    
        ASSIGN i-length = oJsonArrayAux:LENGTH.
    
        IF i-length > 0 THEN
        DO i-aux = 1 TO i-length:
            oJsonAux = oJsonArrayAux:GetJsonObject(i-aux).

            CREATE tt-param-of0620.                                                           
            ASSIGN tt-param-of0620.destino                = IF oJsonAux:Has("destino")               THEN oJsonAux:GetInteger("destino")               ELSE ? NO-ERROR.
            ASSIGN tt-param-of0620.arquivo                = IF oJsonAux:Has("arquivo")               THEN oJsonAux:GetCharacter("arquivo")             ELSE ? NO-ERROR.
            ASSIGN tt-param-of0620.usuario                = IF oJsonAux:Has("usuario")               THEN oJsonAux:GetCharacter("usuario")             ELSE ? NO-ERROR.
            ASSIGN tt-param-of0620.data-exec              = IF oJsonAux:Has("data-exec")             THEN oJsonAux:GetDate("data-exec")                ELSE ? NO-ERROR.
            ASSIGN tt-param-of0620.hora-exec              = IF oJsonAux:Has("hora-exec")             THEN oJsonAux:GetInteger("hora-exec")             ELSE ? NO-ERROR.
            ASSIGN tt-param-of0620.c-est-ini              = IF oJsonAux:Has("c-est-ini")             THEN oJsonAux:GetCharacter("c-est-ini")           ELSE ? NO-ERROR.
            ASSIGN tt-param-of0620.c-est-fim              = IF oJsonAux:Has("c-est-fim")             THEN oJsonAux:GetCharacter("c-est-fim")           ELSE ? NO-ERROR.
            ASSIGN tt-param-of0620.da-est-ini             = IF oJsonAux:Has("da-est-ini")            THEN oJsonAux:GetDate("da-est-ini")               ELSE ? NO-ERROR.
            ASSIGN tt-param-of0620.da-est-fim             = IF oJsonAux:Has("da-est-fim")            THEN oJsonAux:GetDate("da-est-fim")               ELSE ? NO-ERROR.
            ASSIGN tt-param-of0620.da-icm-ini             = IF oJsonAux:Has("da-icm-ini")            THEN oJsonAux:GetDate("da-icm-ini")               ELSE ? NO-ERROR.
            ASSIGN tt-param-of0620.da-icm-fim             = IF oJsonAux:Has("da-icm-fim")            THEN oJsonAux:GetDate("da-icm-fim")               ELSE ? NO-ERROR.
            ASSIGN tt-param-of0620.c-importacao           = IF oJsonAux:Has("c-importacao")          THEN oJsonAux:GetCharacter("c-importacao")        ELSE ? NO-ERROR.
            ASSIGN tt-param-of0620.l-resumo               = IF oJsonAux:Has("l-resumo")              THEN oJsonAux:GetLogical("l-resumo")              ELSE ? NO-ERROR.
            ASSIGN tt-param-of0620.l-resumo-mes           = IF oJsonAux:Has("l-resumo-mes")          THEN oJsonAux:GetLogical("l-resumo-mes")          ELSE ? NO-ERROR.
            ASSIGN tt-param-of0620.l-tot-icm              = IF oJsonAux:Has("l-tot-icm")             THEN oJsonAux:GetLogical("l-tot-icm")             ELSE ? NO-ERROR.
            ASSIGN tt-param-of0620.l-sumario              = IF oJsonAux:Has("l-sumario")             THEN oJsonAux:GetLogical("l-sumario")             ELSE ? NO-ERROR.
            ASSIGN tt-param-of0620.l-periodo-ant          = IF oJsonAux:Has("l-periodo-ant")         THEN oJsonAux:GetLogical("l-periodo-ant")         ELSE ? NO-ERROR.
            ASSIGN tt-param-of0620.l-conta-contab         = IF oJsonAux:Has("l-conta-contab")        THEN oJsonAux:GetLogical("l-conta-contab")        ELSE ? NO-ERROR.
            ASSIGN tt-param-of0620.l-separadores          = IF oJsonAux:Has("l-separadores")         THEN oJsonAux:GetLogical("l-separadores")         ELSE ? NO-ERROR.
            ASSIGN tt-param-of0620.l-incentivado          = IF oJsonAux:Has("l-incentivado")         THEN oJsonAux:GetLogical("l-incentivado")         ELSE ? NO-ERROR.
            ASSIGN tt-param-of0620.l-eliqui               = IF oJsonAux:Has("l-eliqui")              THEN oJsonAux:GetLogical("l-eliqui")              ELSE ? NO-ERROR.
            ASSIGN tt-param-of0620.l-linha-st             = IF oJsonAux:Has("l-linha-st")            THEN oJsonAux:GetLogical("l-linha-st")            ELSE ? NO-ERROR.
            ASSIGN tt-param-of0620.i-documentos           = IF oJsonAux:Has("i-documentos")          THEN oJsonAux:GetInteger("i-documentos")          ELSE ? NO-ERROR.
            ASSIGN tt-param-of0620.i-relat                = IF oJsonAux:Has("i-relat")               THEN oJsonAux:GetInteger("i-relat")               ELSE ? NO-ERROR.
            ASSIGN tt-param-of0620.i-previa               = IF oJsonAux:Has("i-previa")              THEN oJsonAux:GetInteger("i-previa")              ELSE ? NO-ERROR.
            ASSIGN tt-param-of0620.l-icms-subst           = IF oJsonAux:Has("l-icms-subst")          THEN oJsonAux:GetLogical("l-icms-subst")          ELSE ? NO-ERROR.
            ASSIGN tt-param-of0620.c-destino              = IF oJsonAux:Has("c-destino")             THEN oJsonAux:GetCharacter("c-destino")           ELSE ? NO-ERROR.
            ASSIGN tt-param-of0620.i-imp-cab              = IF oJsonAux:Has("i-imp-cab")             THEN oJsonAux:GetInteger("i-imp-cab")             ELSE ? NO-ERROR.
            ASSIGN tt-param-of0620.l-cfop-serv            = IF oJsonAux:Has("l-cfop-serv")           THEN oJsonAux:GetLogical("l-cfop-serv")           ELSE ? NO-ERROR.  
            ASSIGN tt-param-of0620.l-subs                 = IF oJsonAux:Has("l-subs")                THEN oJsonAux:GetLogical("l-subs")                ELSE ? NO-ERROR.
            ASSIGN tt-param-of0620.de-aliq-subs-trib-ant  = IF oJsonAux:Has("de-aliq-subs-trib-ant") THEN oJsonAux:GetDecimal("de-aliq-subs-trib-ant") ELSE ? NO-ERROR.
        END.
    END.

    IF oJsonPayLoad:Has("OF0770") THEN DO:
        oJsonArrayAux = oJsonPayLoad:GetJsonArray("OF0770").
    
        ASSIGN i-length = oJsonArrayAux:LENGTH.
    
        IF i-length > 0 THEN
        DO i-aux = 1 TO i-length:
            oJsonAux = oJsonArrayAux:GetJsonObject(i-aux).

            CREATE tt-param-of0770.
            ASSIGN tt-param-of0770.destino         = IF oJsonAux:Has("destino")        THEN oJsonAux:GetInteger("destino")       ELSE ? NO-ERROR.
            ASSIGN tt-param-of0770.arquivo         = IF oJsonAux:Has("arquivo")        THEN oJsonAux:GetCharacter("arquivo")     ELSE ? NO-ERROR.
            ASSIGN tt-param-of0770.usuario         = IF oJsonAux:Has("usuario")        THEN oJsonAux:GetCharacter("usuario")     ELSE ? NO-ERROR.
            ASSIGN tt-param-of0770.data-exec       = IF oJsonAux:Has("data-exec")      THEN oJsonAux:GetDate("data-exec")        ELSE ? NO-ERROR.
            ASSIGN tt-param-of0770.hora-exec       = IF oJsonAux:Has("hora-exec")      THEN oJsonAux:GetInteger("hora-exec")     ELSE ? NO-ERROR.
            ASSIGN tt-param-of0770.dt-periodo-ini  = IF oJsonAux:Has("dt-periodo-ini") THEN oJsonAux:GetDate("dt-periodo-ini")   ELSE ? NO-ERROR.
            ASSIGN tt-param-of0770.dt-periodo-fim  = IF oJsonAux:Has("dt-periodo-fim") THEN oJsonAux:GetDate("dt-periodo-fim")   ELSE ? NO-ERROR.
            ASSIGN tt-param-of0770.cod-estabel     = IF oJsonAux:Has("cod-estabel")    THEN oJsonAux:GetCharacter("cod-estabel") ELSE ? NO-ERROR.
            ASSIGN tt-param-of0770.rs-modo         = IF oJsonAux:Has("rs-modo")        THEN oJsonAux:GetInteger("rs-modo")       ELSE ? NO-ERROR.
            ASSIGN tt-param-of0770.rs-relatorio    = IF oJsonAux:Has("rs-relatorio")   THEN oJsonAux:GetInteger("rs-relatorio")  ELSE ? NO-ERROR.
        END.
    END.

    IF oJsonPayLoad:Has("RE0530") THEN DO:
        oJsonArrayAux = oJsonPayLoad:GetJsonArray("RE0530").
    
        ASSIGN i-length = oJsonArrayAux:LENGTH.
    
        IF i-length > 0 THEN
        DO i-aux = 1 TO i-length:
            oJsonAux = oJsonArrayAux:GetJsonObject(i-aux).

            CREATE tt-param-re0530.
            ASSIGN tt-param-re0530.destino           = IF oJsonAux:Has("destino")            THEN oJsonAux:GetInteger("destino")            ELSE ? NO-ERROR.
            ASSIGN tt-param-re0530.arquivo           = IF oJsonAux:Has("arquivo")            THEN oJsonAux:GetCharacter("arquivo")          ELSE ? NO-ERROR.
            ASSIGN tt-param-re0530.usuario           = IF oJsonAux:Has("usuario")            THEN oJsonAux:GetCharacter("usuario")          ELSE ? NO-ERROR.
            ASSIGN tt-param-re0530.data-exec         = IF oJsonAux:Has("data-exec")          THEN oJsonAux:GetDate("data-exec")             ELSE ? NO-ERROR.
            ASSIGN tt-param-re0530.hora-exec         = IF oJsonAux:Has("hora-exec")          THEN oJsonAux:GetInteger("hora-exec")          ELSE ? NO-ERROR.
            ASSIGN tt-param-re0530.cod-emitente-ini  = IF oJsonAux:Has("cod-emitente-ini")   THEN oJsonAux:GetInteger("cod-emitente-ini")   ELSE ? NO-ERROR.
            ASSIGN tt-param-re0530.cod-emitente-fim  = IF oJsonAux:Has("cod-emitente-fim")   THEN oJsonAux:GetInteger("cod-emitente-fim")   ELSE ? NO-ERROR.
            ASSIGN tt-param-re0530.dt-trans-ini      = IF oJsonAux:Has("dt-trans-ini")       THEN oJsonAux:GetDate("dt-trans-ini")          ELSE ? NO-ERROR.
            ASSIGN tt-param-re0530.dt-trans-fim      = IF oJsonAux:Has("dt-trans-fim")       THEN oJsonAux:GetDate("dt-trans-fim")          ELSE ? NO-ERROR.
            ASSIGN tt-param-re0530.dt-emiss-ini      = IF oJsonAux:Has("dt-emiss-ini")       THEN oJsonAux:GetDate("dt-emiss-ini")          ELSE ? NO-ERROR.
            ASSIGN tt-param-re0530.dt-emiss-fim      = IF oJsonAux:Has("dt-emiss-fim")       THEN oJsonAux:GetDate("dt-emiss-fim")          ELSE ? NO-ERROR.
            ASSIGN tt-param-re0530.cod-estab-ini     = IF oJsonAux:Has("cod-estab-ini")      THEN oJsonAux:GetCharacter("cod-estab-ini")    ELSE ? NO-ERROR.
            ASSIGN tt-param-re0530.cod-estab-fim     = IF oJsonAux:Has("cod-estab-fim")      THEN oJsonAux:GetCharacter("cod-estab-fim")    ELSE ? NO-ERROR.
            ASSIGN tt-param-re0530.nro-docto-ini     = IF oJsonAux:Has("nro-docto-ini")      THEN oJsonAux:GetCharacter("nro-docto-ini")    ELSE ? NO-ERROR.
            ASSIGN tt-param-re0530.nro-docto-fim     = IF oJsonAux:Has("nro-docto-fim")      THEN oJsonAux:GetCharacter("nro-docto-fim")    ELSE ? NO-ERROR.
            ASSIGN tt-param-re0530.serie-docto-ini   = IF oJsonAux:Has("serie-docto-ini")    THEN oJsonAux:GetCharacter("serie-docto-ini")  ELSE ? NO-ERROR.
            ASSIGN tt-param-re0530.serie-docto-fim   = IF oJsonAux:Has("serie-docto-fim")    THEN oJsonAux:GetCharacter("serie-docto-fim")  ELSE ? NO-ERROR.
            ASSIGN tt-param-re0530.nat-operacao-ini  = IF oJsonAux:Has("nat-operacao-ini")   THEN oJsonAux:GetCharacter("nat-operacao-ini") ELSE ? NO-ERROR.
            ASSIGN tt-param-re0530.nat-operacao-fim  = IF oJsonAux:Has("nat-operacao-fim")   THEN oJsonAux:GetCharacter("nat-operacao-fim") ELSE ? NO-ERROR.
            ASSIGN tt-param-re0530.imp-param         = IF oJsonAux:Has("imp-param")          THEN oJsonAux:GetLogical("imp-param")          ELSE ? NO-ERROR.
            ASSIGN tt-param-re0530.tg-doc-pendente   = IF oJsonAux:Has("tg-doc-pendente")    THEN oJsonAux:GetLogical("tg-doc-pendente")    ELSE ? NO-ERROR.
            ASSIGN tt-param-re0530.tg-doc-atualizado = IF oJsonAux:Has("tg-doc-atualizado")  THEN oJsonAux:GetLogical("tg-doc-atualizado")  ELSE ? NO-ERROR.
                   
        END.
    END.

    IF oJsonPayLoad:Has("consultaPedidos") THEN DO:
        oJsonArrayAux = oJsonPayLoad:GetJsonArray("consultaPedidos").
    
        ASSIGN i-length = oJsonArrayAux:LENGTH.
    
        IF i-length > 0 THEN
        DO i-aux = 1 TO i-length:
            oJsonAux = oJsonArrayAux:GetJsonObject(i-aux).

            CREATE tt-consulta-pedido.
            ASSIGN tt-consulta-pedido.num-ped-exec = IF oJsonAux:Has("numPedido") THEN oJsonAux:GetInteger("numPedido") ELSE ? NO-ERROR.
        END.
    END.

    IF oJsonPayLoad:Has("moveArquivos") THEN DO:
        oJsonArrayAux = oJsonPayLoad:GetJsonArray("moveArquivos").
    
        ASSIGN i-length = oJsonArrayAux:LENGTH.
    
        IF i-length > 0 THEN
        DO i-aux = 1 TO i-length:
            oJsonAux = oJsonArrayAux:GetJsonObject(i-aux).

            CREATE tt-move-arquivo.
            ASSIGN tt-move-arquivo.num-ped-exec = IF oJsonAux:Has("numPedido")      THEN oJsonAux:GetInteger("numPedido")        ELSE ? NO-ERROR.
            ASSIGN tt-move-arquivo.origem       = IF oJsonAux:Has("arquivoOrigem")  THEN oJsonAux:GetCharacter("arquivoOrigem")  ELSE ? NO-ERROR.
            ASSIGN tt-move-arquivo.destino      = IF oJsonAux:Has("arquivoDestino") THEN oJsonAux:GetCharacter("arquivoDestino") ELSE ? NO-ERROR.

        END.
    END.

END PROCEDURE.
