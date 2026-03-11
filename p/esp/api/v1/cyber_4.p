/* CyberBot.Script API VER 4.0, Desenvolvido por Mike, Eduardo e Luan */
/* RPA - Geraá∆o de notas de balanáo Lojas Prcfit>CyberBot>Progress4GL>int038rp.p */

USING Progress.Json.ObjectModel.JsonArray.
USING Progress.Json.ObjectModel.JsonObject.
USING Progress.Json.ObjectModel.JsonDataType.
USING Progress.Json.ObjectModel.ObjectModelParser.

{utp/ut-api.i}
{utp/ut-api-action.i pi-cyber POST /cyber/~* }
{utp/ut-api-notfound.i}

{method/dbotterr.i} /*RowErrors*/

DEF NEW GLOBAL SHARED VAR c-seg-usuario AS CHAR NO-UNDO.
DEFINE VARIABLE h-acomp AS HANDLE NO-UNDO.

define temp-table tt-param NO-UNDO
    field destino          as integer
    field arquivo          as char format "x(35)":U
    field usuario          AS char format "x(12)":U
    field data-exec        as date
    field hora-exec        as integer
    field dt-periodo-ini   as DATE format "99/99/9999"
    field dt-periodo-fim   as date format "99/99/9999"
    field cod-estabel-ini  as char format "x(03)"
    field cod-estabel-fim  as char format "x(03)"
    field pedido-ini       as integer format ">>>>>>>9"
    field pedido-fim       as integer format ">>>>>>>9"
    field txt-obs          as char format "X(300)"
    FIELD cancelar         AS LOGICAL.

def temp-table tt-raw-digita
    field raw-digita as raw.
    
DEFINE VARIABLE raw-param AS RAW NO-UNDO.

DEF TEMP-TABLE tt-pedido NO-UNDO
    FIELD pedido     AS INTEGER
    FIELD estab      AS CHAR
    FIELD obs        AS CHAR FORMAT "X(300)".

FUNCTION LongCharToJsonObject RETURN JsonObject PRIVATE (INPUT jsonChar AS LONGCHAR):
    DEFINE VARIABLE jsonOutput AS JsonObject NO-UNDO.
    DEFINE VARIABLE objParse   AS ObjectModelParser NO-UNDO.

    ASSIGN jsonOutput = NEW JsonObject()
           objParse   = NEW ObjectModelParser()
           jsonOutput = CAST(objParse:Parse(jsonChar), JsonObject).

    DELETE OBJECT objParse.
    RETURN jsonOutput.
END FUNCTION.

PROCEDURE pi-cyber:
    DEF INPUT PARAM jsonInput       AS JsonObject NO-UNDO.
    DEF OUTPUT PARAM jsonOutput     AS JsonObject NO-UNDO.
    
    DEFINE VARIABLE oRequestParser  AS JsonAPIRequestParser NO-UNDO.
    DEFINE VARIABLE lcPayload       AS LONGCHAR NO-UNDO.
    DEFINE VARIABLE oResponseArray  AS JsonArray NO-UNDO.
    DEFINE VARIABLE oPedidoObj      AS JsonObject NO-UNDO.
    
    DEFINE VARIABLE nota-processada AS LOGICAL NO-UNDO.
    DEFINE VARIABLE erro-pedido     AS LOGICAL NO-UNDO.
    DEFINE VARIABLE erro-json       AS LOGICAL NO-UNDO.
    DEFINE BUFFER   buf_pedido      FOR int_ds_pedido.
    
    /* Inicializa estrutura de resposta */
    jsonOutput = NEW JsonObject().
    oResponseArray = NEW JsonArray().
    jsonOutput:Add("resultados", oResponseArray).

    RUN utp/ut-acomp.p PERSISTENT SET h-acomp.
    LOG-MANAGER:WRITE-MESSAGE("Componente persistente ut-acomp.p iniciado").

    oRequestParser = NEW JsonAPIRequestParser(jsonInput).
    ASSIGN lcPayload = oRequestParser:getPayloadLongChar().
    
    DEFINE VARIABLE jsonAux AS JsonObject NO-UNDO.
    jsonAux = LongCharToJsonObject(lcPayload).
                                            
    TEMP-TABLE tt-pedido:HANDLE:READ-JSON('JsonArray', jsonAux:GetJsonArray("ped")).

    FOR EACH tt-pedido:

         oPedidoObj = NEW JsonObject().  // Instanciaá∆o correta
        
        ASSIGN 
            erro-json = FALSE
            nota-processada = FALSE
            erro-pedido = FALSE.

        LOG-MANAGER:WRITE-MESSAGE("Verificando int_ds_pedido pedido: " + STRING(tt-pedido.pedido)).

        FOR EACH buf_pedido NO-LOCK WHERE 
                    buf_pedido.ped_codigo_n = tt-pedido.pedido:
                    
                    IF buf_pedido.situacao = 2 THEN
                        nota-processada = TRUE.
                        LOG-MANAGER:WRITE-MESSAGE("Pedido j† tem nota, call procedure consulta " + STRING(tt-pedido.pedido)).
                        
                        RUN pi-consulta-nf (tt-pedido.estab, STRING(tt-pedido.pedido), oPedidoObj).
        END.
        
        RELEASE buf_pedido.
        
        IF NOT nota-processada THEN DO:
            LOG-MANAGER:WRITE-MESSAGE("Pedido n∆o processado " + STRING(tt-pedido.pedido)).
            EMPTY TEMP-TABLE tt-param.
            CREATE tt-param.
                                                            
            ASSIGN
                tt-param.usuario         = c-seg-usuario
                tt-param.destino         = 3 
                tt-param.arquivo         = SESSION:TEMP-DIRECTORY + "API_CYBER.TXT"                       
                tt-param.data-exec       = TODAY
                tt-param.hora-exec       = TIME
                tt-param.dt-periodo-ini  = TODAY - 30
                tt-param.dt-periodo-fim  = TODAY
                tt-param.cod-estabel-ini = tt-pedido.estab
                tt-param.cod-estabel-fim = tt-pedido.estab
                tt-param.pedido-ini      = tt-pedido.pedido
                tt-param.pedido-fim      = tt-pedido.pedido
                tt-param.txt-obs         = tt-pedido.obs
                tt-param.cancelar        = FALSE.

            RAW-TRANSFER tt-param TO raw-param.

            DO ON ERROR UNDO, LEAVE:
                LOG-MANAGER:WRITE-MESSAGE("Chamando int038rp.p " + STRING(tt-pedido.pedido)).
                RUN intprg/int038rp.p (INPUT raw-param, INPUT TABLE tt-raw-digita) NO-ERROR.
                
                IF ERROR-STATUS:ERROR THEN DO:
                    LOG-MANAGER:WRITE-MESSAGE("ERRO na execuá∆o: " + ERROR-STATUS:GET-MESSAGE(1)).
                    oPedidoObj:Add("Erro", "Falha na execuá∆o do int038rp.p").
                     UNDO, NEXT.
                END.
                
                LOG-MANAGER:WRITE-MESSAGE("Finalizado int038 consultando int_ds_pedido " + STRING(tt-pedido.pedido)).
                
                DEFINE VARIABLE lFoundPedido AS LOGICAL NO-UNDO INIT FALSE.  /* Vari†vel de controle */

                FOR EACH int_ds_pedido NO-LOCK WHERE 
                         int_ds_pedido.ped_codigo_n = tt-pedido.pedido:
                    
                    ASSIGN lFoundPedido = TRUE.  /* Marca como encontrado */
                    
                    IF int_ds_pedido.situacao = 2 THEN DO:         
                        RUN pi-consulta-nf (tt-pedido.estab, STRING(tt-pedido.pedido), oPedidoObj).
                    END.
                    ELSE DO:         
                        oPedidoObj:Add("Aviso", "Pedido lanáado no int038, mas sem retorno de NF.").
                    END.  
                    
                END.

                /* Verifica se nenhum registro foi encontrado */
                IF NOT lFoundPedido THEN
                    oPedidoObj:Add("Erro", "Erro ao consultar int_ds_pedido ap¢s int038rp.p").

                CATCH e AS Progress.Lang.Error:
                    oPedidoObj:Add("Erro", e:GetMessage(1)).
                END CATCH.
            END.
        END.
        
        oResponseArray:Add(oPedidoObj).
    END.

     IF ERROR-STATUS:ERROR THEN
        oPedidoObj:Add("status", "0").  // Cria a propriedade
    ELSE
        oPedidoObj:Add("status", "1").  // Cria a propriedade

    IF VALID-HANDLE(h-acomp) THEN
        DELETE OBJECT h-acomp.

    RETURN "OK".
END PROCEDURE.

PROCEDURE pi-consulta-nf:
    DEFINE INPUT PARAMETER p-estab    AS CHAR NO-UNDO.
    DEFINE INPUT PARAMETER p-pedido   AS CHAR NO-UNDO.
    DEFINE INPUT PARAMETER pPedidoObj AS JsonObject NO-UNDO.
    
    DEFINE VARIABLE lFound AS LOGICAL NO-UNDO INIT FALSE.  /* Vari†vel de controle */
    
    LOG-MANAGER:WRITE-MESSAGE("Consultando nota na tabela Nota-Fiscal").
    
    FOR EACH nota-fiscal NO-LOCK WHERE
              nota-fiscal.cod-estabel = p-estab AND
              nota-fiscal.nr-pedcli   = p-pedido AND
              nota-fiscal.serie       = "1":
              
        LOG-MANAGER:WRITE-MESSAGE("Nota encontrada retornando via json request.").
        
        ASSIGN lFound = TRUE.  /* Marca como encontrado */
        
        pPedidoObj:Add("NF", nota-fiscal.nr-nota-fis).
        pPedidoObj:Add("Emissao", nota-fiscal.dt-emis-nota). 
        pPedidoObj:Add("Natureza", nota-fiscal.nat-operacao). 
        pPedidoObj:Add("OBS", nota-fiscal.observ-nota). 
        pPedidoObj:Add("CHAVE", nota-fiscal.cod-chave-aces-nf-eletro). 
        pPedidoObj:Add("Situacao", SUBSTRING(STRING(nota-fiscal.idi-sit-nf-eletro), 1, 1)). 
        pPedidoObj:Add("Valor_Nota", nota-fiscal.vl-tot-nota).
        pPedidoObj:SET("status", "1").  
    END.
    
    IF NOT lFound THEN DO:  
        pPedidoObj:Add("return", "Algo deu errado na consulta!").
        pPedidoObj:SET("status", "0").
    END.
    
END PROCEDURE.
