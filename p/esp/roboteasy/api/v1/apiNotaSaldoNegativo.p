{utp/ut-api.i} 
{utp/ut-api-utils.i}

{utp/ut-glob.i}

//****************************************************************************************************
//****************************************************************************************************

def var l-trace as logical initial no.

// MODELO = definir parametros retornados
DEF TEMP-TABLE tt-retorno NO-UNDO SERIALIZE-NAME "retorno" 
    FIELD status-cod                    AS CHAR INITIAL "NOK"       SERIALIZE-NAME "statusCodigo" 
    FIELD status-obs                    AS CHAR                     SERIALIZE-NAME "statusObs" 
    FIELD status-trace                  AS CHAR                     SERIALIZE-NAME "statusTrace" 
    FIELD status-versao                 AS INT                      SERIALIZE-NAME "statusVersao" INITIAL 4
.
    
def temp-table tt-pedido no-undo serialize-name "pedido"
    field cod-estab     as char     serialize-name "codEstab"
    field num-pedido    as integer  serialize-name "numPedido"
    field obs-nota      as char     serialize-name "obsNota"
    field nome-pasta    as char     serialize-name "nomePasta"
    field ativarTrace   as char     serialize-name "ativarTrace"
    field data-inicial  as date     serialize-name "dataInicial"
    field data-final    as date     serialize-name "dataFinal"
    field serie-nota    as char     serialize-name "serieNota"
    field num-nota      as char     serialize-name "numNota"
    field nat-operacao  as char     serialize-name "natOperacao"
    field val-nota      as decimal  serialize-name "valorNota"
    field arq-int038    as char     serialize-name "arqINT038"
.

//--------------------------------------------------------------------------------

define temp-table tt-param no-undo
    field destino          as integer
    field arquivo          as char format "x(35)":U
    field usuario          as char format "x(12)":U
    field data-exec        as date
    field hora-exec        as integer
    FIELD dt-periodo-ini   AS DATE FORMAT "99/99/9999"
    FIELD dt-periodo-fim   AS DATE FORMAT "99/99/9999"
    FIELD cod-estabel-ini  AS CHAR format "x(03)"
    FIELD cod-estabel-fim  AS CHAR FORMAT "x(03)"
    FIELD pedido-ini       AS INTEGER FORMAT ">>>>>>>9"
    FIELD pedido-fim       AS INTEGER FORMAT ">>>>>>>9"
    FIELD txt-obs          AS CHAR    FORMAT "X(300)"
    FIELD cancelar         AS LOGICAL        .                          .                               
. 

DEFINE TEMP-TABLE tt-digita NO-UNDO
    FIELD r-docum-est AS ROWID.

DEF VAR raw-param AS RAW no-undo.

DEF TEMP-TABLE tt-raw-digita NO-UNDO
   FIELD raw-digita   as raw.

//****************************************************************************************************

PROCEDURE pi-main:

    // replicar parametro do JSON de entrada no JSON de saida
    CREATE tt-retorno.
    ASSIGN tt-retorno.status-cod = "NOK".
    
    FOR FIRST tt-pedido: 
    END. 

    IF  AVAIL tt-pedido THEN DO:

        assign l-trace = tt-pedido.ativarTrace = "sim".
        
        if  tt-pedido.cod-estab = ? 
        or  tt-pedido.cod-estab = "" then
            assign tt-retorno.status-cod = "NOK"
                   tt-retorno.status-obs = "C¢digo do estabelecimento n∆o informado".
        else do:
            for first estabelec no-lock
                where estabelec.cod-estabel = tt-pedido.cod-estab:
            end.
            if  not avail estabelec then
                assign tt-retorno.status-cod = "NOK"
                       tt-retorno.status-obs = "C¢digo do estabelecimento inv†lido".
            else do:
                if  tt-pedido.num-pedido = ? 
                or  tt-pedido.num-pedido = 0 then
                    assign tt-retorno.status-cod = "NOK"
                           tt-retorno.status-obs = "N£mero do pedido n∆o informado".
                else do:
                    for first int_ds_pedido no-lock
                        where int_ds_pedido.ped_codigo_n = tt-pedido.num-pedido:
                    end.
                    if  not avail int_ds_pedido then
                        assign tt-retorno.status-cod = "NOK"
                               tt-retorno.status-obs = "N£mero do pedido n∆o encontrado: " + STRING(tt-pedido.num-pedido).
                    else do:
                        for first user-coml no-lock
                            where user-coml.usuario = c-seg-usuario:
                        end.
                        if  not avail user-coml then
                            assign tt-retorno.status-cod = "NOK"
                                   tt-retorno.status-obs = "Usu†rio n∆o encontrado no cadastro de usu†rios comerciais (CD0812): " + c-seg-usuario.
                        else                    
                            run pi-gerar-nota.
                    end.
                end.
            end.
        end.
    END.
    ELSE
        ASSIGN tt-retorno.status-cod = "NOK"
               tt-retorno.status-obs = "Nenhum pedido foi informado".
   
END PROCEDURE.

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
    DEF          VAR jJsonAux            AS JsonObject NO-UNDO. 
    DEF          VAR jParam              AS JsonObject NO-UNDO. 
    DEF          VAR lOk                 AS l          NO-UNDO.

    bloco-post:
    DO ON ERROR UNDO, RETRY:
       
        IF  RETRY THEN DO:
            ASSIGN tt-retorno.status-cod = "NOK"
                   tt-retorno.status-obs = "Ocorreu um erro n∆o identificado na pi-post".
            LEAVE bloco-post.
        END.
        
        ASSIGN jsonObjectPayload = jsonInput:GetJsonObject("payload").
        
        //--------------------------------------------------------------------------------

        // JSON com "pedido"
        ASSIGN jJsonAux = jsonObjectPayload:GetJsonObject("pedido") 
               lOk      = TEMP-TABLE tt-pedido:READ-JSON("JsonObject", jJsonAux) NO-ERROR.

        //--------------------------------------------------------------------------------

        FIND FIRST tt-pedido NO-ERROR.
        IF  NOT AVAIL tt-pedido THEN
            // JSON com "Pedido"
            ASSIGN jJsonAux = jsonObjectPayload:GetJsonObject("Pedido") 
                   lOk      = TEMP-TABLE tt-pedido:READ-JSON("JsonObject", jJsonAux) NO-ERROR.
    END. // bloco-post

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
    
    //--------------------------------------------------------------------------------

    IF  TEMP-TABLE tt-retorno:HAS-RECORDS THEN DO:
        ASSIGN iRet = 200.
        jsonObjectOutput:READ(DATASET dsPrincipal:HANDLE).
        ASSIGN lPassou = YES.
    END.
    
    IF  lPassou = NO THEN DO:
        CREATE tt-retorno.
        ASSIGN tt-retorno.status-cod = "NOK"
               tt-retorno.status-obs = "Erro na execuá∆o da API".
        jsonObjectOutput:READ(TEMP-TABLE tt-retorno:HANDLE).
    END.

    //--------------------------------------------------------------------------------
    
    DEFINE VARIABLE oJsonArrayPedidos AS JsonArray         NO-UNDO.

    // ADICIONAR DADOS NO JSON DE RETORNO
    oJsonArrayPedidos = NEW JsonArray().
    oJsonArrayPedidos:READ(TEMP-TABLE tt-pedido:HANDLE).
    jsonObjectOutput:ADD("pedidos", oJsonArrayPedidos).

    //--------------------------------------------------------------------------------

    jsonOutput = JsonAPIResponseBuilder:ok(jsonObjectOutput, iRet).
    
END PROCEDURE.

//****************************************************************************************************

PROCEDURE pi-gerar-nota:

    def var c-linha         as char     no-undo.
    def var c-num-nota      as char     no-undo.
    def var i-num-nota      as inte     no-undo.
    def var l-erro          as logi     no-undo.

    IF  L-TRACE THEN ASSIGN TT-RETORNO.STATUS-TRACE = TT-RETORNO.STATUS-TRACE + "|10".

    bloco-gerar-nota:
    DO TRANS ON ERROR UNDO, RETRY:
       
        IF  RETRY THEN DO:
            ASSIGN tt-retorno.status-cod = "NOK"
                   tt-retorno.status-obs = "Ocorreu um erro n∆o identificado na pi-gerar-nota".
            LEAVE bloco-gerar-nota.
        END.

        CREATE tt-param.
        
        assign tt-param.dt-periodo-ini  = date(month(int_ds_pedido.dt_geracao), 1, year(int_ds_pedido.dt_geracao))
               tt-param.dt-periodo-fim  = tt-param.dt-periodo-ini + 40
               tt-param.dt-periodo-fim  = date(month(tt-param.dt-periodo-fim), 1, year(tt-param.dt-periodo-fim)) - 1
               tt-param.cod-estabel-ini = tt-pedido.cod-estab
               tt-param.cod-estabel-fim = tt-pedido.cod-estab
               tt-param.pedido-ini      = tt-pedido.num-pedido
               tt-param.pedido-fim      = tt-pedido.num-pedido
               tt-param.txt-obs         = tt-pedido.obs-nota.
        
        ASSIGN tt-param.usuario   = c-seg-usuario // tt-param.cod-usuario
               tt-param.destino   = 2
               tt-param.data-exec = TODAY
               tt-param.hora-exec = TIME.
    
        assign tt-pedido.data-inicial = tt-param.dt-periodo-ini
               tt-pedido.data-final   = tt-param.dt-periodo-fim.
    
        IF  L-TRACE THEN ASSIGN TT-RETORNO.STATUS-TRACE = TT-RETORNO.STATUS-TRACE + "|20".
    
        //--------------------------------------------------------------------------------
        // nome da pasta
        //--------------------------------------------------------------------------------
        
        FIND FIRST usuar_mestre
             WHERE usuar_mestre.cod_usuario = c-seg-usuario NO-LOCK NO-ERROR.
                
        assign tt-param.arquivo   = IF AVAIL usuar_mestre AND usuar_mestre.nom_dir_spool <> "" 
                                    THEN (usuar_mestre.nom_dir_spool + "/")
                                    ELSE if  tt-pedido.nome-pasta <> "" AND tt-pedido.nome-pasta <> ?
                                         then tt-pedido.nome-pasta + "/"
                                         else SESSION:TEMP-DIRECTORY + "/".
    
        IF  OPSYS BEGINS "WIN" THEN
            ASSIGN tt-param.arquivo = replace(tt-param.arquivo, "/", "\")
                   tt-param.arquivo = replace(tt-param.arquivo, "\\", "\").
        ELSE
            ASSIGN tt-param.arquivo = replace(tt-param.arquivo, "\", "/")
                   tt-param.arquivo = replace(tt-param.arquivo, "//", "/").
        
        //--------------------------------------------------------------------------------
        // nome do arquivo
        //--------------------------------------------------------------------------------
        ASSIGN tt-param.arquivo   = tt-param.arquivo 
                                    + "RPA_INT038RP_" 
                                    + substring(string(year(today),"9999"),3,2) + string(month(today),"99") + string(day(today),"99") + "_" 
                                    + REPLACE(STRING(TIME,"HH:MM:SS"),":", "") 
                                    + ".txt":U.
    
        assign tt-pedido.arq-int038 = tt-param.arquivo.
        
        IF  L-TRACE THEN ASSIGN TT-RETORNO.STATUS-TRACE = TT-RETORNO.STATUS-TRACE + "|30".
    
        //--------------------------------------------------------------------------------
        // teste
        //--------------------------------------------------------------------------------
        //--------------------------------------------------------------------------------
        //output to value(tt-param.arquivo).
        //put unformatted "x" skip.
        //output close.
        //--------------------------------------------------------------------------------
        //--------------------------------------------------------------------------------
    
        RAW-TRANSFER tt-param TO raw-param.
        
        //if  tt-pedido.obs-nota = "executar" then
            RUN intprg/int038rp.p (INPUT raw-param, INPUT TABLE tt-raw-digita).
    
        IF  L-TRACE THEN ASSIGN TT-RETORNO.STATUS-TRACE = TT-RETORNO.STATUS-TRACE + "|40".
    
        IF  SEARCH(tt-param.arquivo) = ? THEN DO:
            IF  L-TRACE THEN ASSIGN TT-RETORNO.STATUS-TRACE = TT-RETORNO.STATUS-TRACE + "|50".
            ASSIGN tt-retorno.status-cod = "NOK"
                   tt-retorno.status-obs = "Arquivo do INT038RP n∆o encontrado: " + tt-param.arquivo.
            RETURN.
        END.
    
        //--------------------------------------------------------------------------------
    
        IF  L-TRACE THEN ASSIGN TT-RETORNO.STATUS-TRACE = TT-RETORNO.STATUS-TRACE + "|60".
    
        assign l-erro = no.
    
        INPUT FROM VALUE(tt-param.arquivo) CONVERT TARGET "iso8859-1".
        bloco-ler-arq:
        REPEAT:
            IF  L-TRACE THEN ASSIGN TT-RETORNO.STATUS-TRACE = TT-RETORNO.STATUS-TRACE + "|70".
            IMPORT UNFORMATTED c-linha.
            IF  L-TRACE THEN ASSIGN TT-RETORNO.STATUS-TRACE = TT-RETORNO.STATUS-TRACE + "|80".
            
            if  c-linha matches "*ERRO*" then do:
                assign i-num-nota = 0
                       l-erro     = yes.
                LEAVE bloco-ler-arq.
            end.
            
            ASSIGN c-num-nota = TRIM(SUBSTRING(c-linha, 75, 16)).
            ASSIGN i-num-nota = ?.
            ASSIGN i-num-nota = INT(c-num-nota) NO-ERROR.
            IF  i-num-nota <> ? AND i-num-nota <> 0 THEN
                LEAVE bloco-ler-arq.
            IF  L-TRACE THEN ASSIGN TT-RETORNO.STATUS-TRACE = TT-RETORNO.STATUS-TRACE + "|90".
        END.
        INPUT CLOSE.
    
        IF  L-TRACE THEN ASSIGN TT-RETORNO.STATUS-TRACE = TT-RETORNO.STATUS-TRACE + "|100".
        
        //--------------------------------------------------------------------------------
        
        IF  i-num-nota <> ? AND i-num-nota <> 0 THEN DO:
            IF  L-TRACE THEN ASSIGN TT-RETORNO.STATUS-TRACE = TT-RETORNO.STATUS-TRACE + "|110".
            ASSIGN tt-pedido.num-nota     = c-num-nota
                   tt-pedido.serie-nota   = TRIM(SUBSTRING(c-linha, 69, 5))
                   tt-pedido.nat-operacao = TRIM(SUBSTRING(c-linha, 92, 8)).
    
            IF  L-TRACE THEN ASSIGN TT-RETORNO.STATUS-TRACE = TT-RETORNO.STATUS-TRACE + "|120".
            ASSIGN tt-pedido.val-nota = DECIMAL(TRIM(SUBSTRING(c-linha, 101, 17))) NO-ERROR.
    
            ASSIGN tt-retorno.status-cod = "OK"
                   tt-retorno.status-obs = "Nota gerada com sucesso: " + tt-pedido.num-nota.
            IF  L-TRACE THEN ASSIGN TT-RETORNO.STATUS-TRACE = TT-RETORNO.STATUS-TRACE + "|130".
        END.
        ELSE
            ASSIGN tt-retorno.status-cod = "NOK"
                   tt-retorno.status-obs = if  l-erro
                                           then "Ocorreu um erro na geraá∆o da nota para o pedido: "
                                           else "N∆o foi gerada a nota para o pedido: " 
                   tt-retorno.status-obs = tt-retorno.status-obs + STRING(tt-pedido.num-pedido).

        //--------------------------------------------------------------------------------

        FOR FIRST tt-retorno
            WHERE tt-retorno.status-cod = "NOK":
            UNDO bloco-gerar-nota, LEAVE bloco-gerar-nota.        
        END.
                           
    END. // bloco-gerar-nota    
    
    IF  L-TRACE THEN ASSIGN TT-RETORNO.STATUS-TRACE = TT-RETORNO.STATUS-TRACE + "|140".
       
END PROCEDURE.
