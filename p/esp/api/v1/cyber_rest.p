/* api_cyber.p - API para processamento de pedidos via int038rp.p */
USING Progress.Json.ObjectModel.*.
USING Progress.Lang.*.

{utp/ut-api.i}
{utp/ut-api-action.i pi-cyber POST /cyber_aps/~*}
{utp/ut-api-notfound.i}

{method/dbotterr.i}

DEF NEW GLOBAL SHARED VAR c-seg-usuario AS CHAR NO-UNDO.

DEFINE TEMP-TABLE tt-param NO-UNDO
    FIELD destino          AS INTEGER
    FIELD arquivo          AS CHAR 
    FIELD usuario          AS CHAR 
    FIELD data-exec        AS DATE
    FIELD hora-exec        AS INTEGER
    FIELD dt-periodo-ini   AS DATE
    FIELD dt-periodo-fim   AS DATE
    FIELD cod-estabel-ini  AS CHAR
    FIELD cod-estabel-fim  AS CHAR
    FIELD pedido-ini       AS INTEGER
    FIELD pedido-fim       AS INTEGER
    FIELD txt-obs          AS CHAR
    FIELD cancelar         AS LOGICAL.

DEFINE TEMP-TABLE tt-pedido NO-UNDO
    FIELD pedido     AS INTEGER
    FIELD estab      AS CHAR
    FIELD obs        AS CHAR.

DEFINE TEMP-TABLE tt-raw-digita NO-UNDO
    FIELD raw-digita AS RAW.

FUNCTION LongCharToJsonObject RETURN JsonObject PRIVATE (INPUT jsonChar AS LONGCHAR):
    DEFINE VARIABLE objParse   AS ObjectModelParser NO-UNDO.
    DEFINE VARIABLE jsonReturn AS JsonObject NO-UNDO.
    
    objParse = NEW ObjectModelParser().
    jsonReturn = CAST(objParse:Parse(jsonChar), JsonObject).
    DELETE OBJECT objParse.
    
    RETURN jsonReturn.
END FUNCTION.

PROCEDURE pi-cyber:
    DEFINE INPUT  PARAMETER jsonInput   AS JsonObject NO-UNDO.
    DEFINE OUTPUT PARAMETER jsonOutput  AS JsonObject NO-UNDO.

    DEFINE VARIABLE oParser     AS JsonAPIRequestParser NO-UNDO.
    DEFINE VARIABLE oPedidos    AS JsonArray         NO-UNDO.
    DEFINE VARIABLE oPedido     AS JsonObject        NO-UNDO.
    DEFINE VARIABLE lcPayload   AS LONGCHAR          NO-UNDO.
    DEFINE VARIABLE jsonAux     AS JsonObject        NO-UNDO.
    
    /* Inicializa‡Æo segura dos objetos JSON */
    jsonOutput = NEW JsonObject().
    oPedidos = NEW JsonArray().
    jsonOutput:Add("resultados", oPedidos).

    DO ON ERROR UNDO, LEAVE:
        oParser = NEW JsonAPIRequestParser(jsonInput).
        lcPayload = oParser:getPayloadLongChar().
        
        /* ConversÆo segura do payload */
        jsonAux = LongCharToJsonObject(lcPayload).
        
        /* Valida‡Æo da estrutura do JSON */
        IF NOT VALID-OBJECT(jsonAux) OR NOT jsonAux:Has("ped") THEN
            UNDO, THROW NEW AppError("Estrutura JSON inv lida", 100).

        /* Leitura dos pedidos com tratamento de erro */
        TEMP-TABLE tt-pedido:HANDLE:READ-JSON(
            "JsonArray", 
            jsonAux:GetJsonArray("ped"),
            "EMPTY"
        ) NO-ERROR.
        
        IF ERROR-STATUS:ERROR THEN
            UNDO, THROW NEW AppError("Falha ao ler dados dos pedidos", 101).

        /* Processamento principal */
        PedidoBLOCK:
        FOR EACH tt-pedido:
            oPedido = NEW JsonObject().  // Novo objeto para cada pedido
            
            /* Bloco protegido para cada pedido */
            DO ON ERROR UNDO, LEAVE:
                FIND FIRST int_ds_pedido NO-LOCK 
                    WHERE int_ds_pedido.ped_codigo_n = tt-pedido.pedido NO-ERROR.

                CASE TRUE:
                    WHEN AVAILABLE int_ds_pedido AND int_ds_pedido.situacao = 2 THEN DO:
                        RUN pi-consulta-nf (
                            INPUT  tt-pedido.estab,
                            INPUT  STRING(tt-pedido.pedido),
                            OUTPUT oPedido
                        ).
                        IF NOT oPedido:Has("status") THEN
                            oPedido:Add("status", "1").
                    END.

                    OTHERWISE DO:
                        DO TRANSACTION ON ERROR UNDO, LEAVE:
                            RUN pi-processa-pedido (
                                INPUT  tt-pedido.pedido,
                                INPUT  tt-pedido.estab,
                                INPUT  tt-pedido.obs,
                                OUTPUT oPedido
                            ).
                            
                            /* Verifica‡Æo p¢s-processamento */
                            FIND FIRST int_ds_pedido NO-LOCK 
                                WHERE int_ds_pedido.ped_codigo_n = tt-pedido.pedido NO-ERROR.

                            IF AVAILABLE int_ds_pedido AND int_ds_pedido.situacao = 2 THEN
                                RUN pi-consulta-nf (
                                    INPUT  tt-pedido.estab,
                                    INPUT  STRING(tt-pedido.pedido),
                                    OUTPUT oPedido
                                ).
                            ELSE IF NOT oPedido:Has("status") THEN
                                oPedido:Add("status", "0").
                        END.
                    END.
                END CASE.
                
                CATCH err AS Progress.Lang.Error:
                    oPedido:Add("status", "0").
                    oPedido:Add("erro", err:GetMessage(1)).
                END CATCH.
            END.
            
            oPedidos:Add(oPedido).
        END. /* Fim do FOR EACH tt-pedido */

        CATCH err AS Progress.Lang.Error:
            jsonOutput:Add("status", "0").
            jsonOutput:Add("erro", err:GetMessage(1)).
        END CATCH.
        
        FINALLY:
            /* Limpeza de recursos */
            DELETE OBJECT oParser NO-ERROR.
            DELETE OBJECT jsonAux NO-ERROR.
            EMPTY TEMP-TABLE tt-pedido.
        END FINALLY.
    END.
END PROCEDURE.

PROCEDURE pi-processa-pedido PRIVATE:
    DEFINE INPUT  PARAMETER pi-pedido   AS INTEGER   NO-UNDO.
    DEFINE INPUT  PARAMETER pc-estab    AS CHARACTER NO-UNDO.
    DEFINE INPUT  PARAMETER pc-obs      AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER po-result   AS JsonObject NO-UNDO.

    DEFINE VARIABLE rawParam  AS RAW        NO-UNDO.
    //DEFINE VARIABLE hBuffer   AS HANDLE     NO-UNDO.
    
    po-result = NEW JsonObject().

    DO ON ERROR UNDO, THROW:
        EMPTY TEMP-TABLE tt-param.
        CREATE tt-param.
        ASSIGN
            tt-param.destino         = 3
            tt-param.usuario         = c-seg-usuario
            tt-param.data-exec       = TODAY
            tt-param.hora-exec       = TIME
            tt-param.dt-periodo-ini  = TODAY - 30
            tt-param.dt-periodo-fim  = TODAY
            tt-param.cod-estabel-ini = pc-estab
            tt-param.cod-estabel-fim = pc-estab
            tt-param.pedido-ini      = pi-pedido
            tt-param.pedido-fim      = pi-pedido
            tt-param.txt-obs         = pc-obs
            tt-param.cancelar        = FALSE.

/*         hBuffer = TEMP-TABLE tt-param:DEFAULT-BUFFER-HANDLE. */
/*         hBuffer:WRITE-JSON("RAW", rawParam) NO-ERROR.        */
        
        RAW-TRANSFER tt-param TO rawParam.
        
        IF ERROR-STATUS:ERROR THEN
            UNDO, THROW NEW AppError("Falha na serializa‡Æo dos parƒmetros", 101).

        RUN intprg/int038rp.p (
            INPUT rawParam, 
            INPUT TABLE tt-raw-digita
        ) NO-ERROR.

        IF ERROR-STATUS:ERROR THEN DO:
            DEFINE VARIABLE iError AS INTEGER NO-UNDO.
            DEFINE VARIABLE cMsg   AS CHARACTER NO-UNDO.
            
            DO iError = 1 TO ERROR-STATUS:NUM-MESSAGES:
                cMsg = cMsg + ERROR-STATUS:GET-MESSAGE(iError) + " | ".
            END.
            
            UNDO, THROW NEW AppError(SUBST("Erro no processamento: &1", cMsg), 102).
        END.

        //po-result:Add("status", "1").
           
        CATCH err AS Progress.Lang.Error:
            po-result:Add("status", "0").
            po-result:Add("erro", err:GetMessage(1)).
            UNDO, THROW err.
        END CATCH.
        
       
        FINALLY:
            /* Bloco de limpeza */
            EMPTY TEMP-TABLE tt-param.
            EMPTY TEMP-TABLE tt-raw-digita.
        END FINALLY.
        
    END.
END PROCEDURE.

PROCEDURE pi-consulta-nf PRIVATE:
    DEFINE INPUT  PARAMETER pc-estab    AS CHARACTER NO-UNDO.
    DEFINE INPUT  PARAMETER pc-pedido   AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER po-result   AS JsonObject NO-UNDO.

    DEFINE BUFFER bNota FOR nota-fiscal.  // Buffer definido aqui
    
    po-result = NEW JsonObject().

    DO ON ERROR UNDO, THROW:
        FIND FIRST bNota NO-LOCK 
            WHERE bNota.cod-estabel = pc-estab
            AND bNota.nr-pedcli    = pc-pedido
            AND bNota.serie        = "1" NO-ERROR.

        IF AVAILABLE bNota THEN DO:
            po-result:Add("nf", bNota.nr-nota-fis).            // Usando bNota
            po-result:Add("emissao", bNota.dt-emis-nota).       // Campo formatado como string
            po-result:Add("natureza", bNota.nat-operacao). 
            po-result:Add("obs", bNota.observ-nota). 
            po-result:Add("chave", bNota.cod-chave-aces-nf-eletro). 
            po-result:Add("situacao", SUBSTRING(STRING(bNota.idi-sit-nf-eletro), 1, 1)). 
            po-result:Add("valor_nota", bNota.vl-tot-nota).
            po-result:Add("status", "1").
        END.
        ELSE
            po-result:Add("status", "0").  

        CATCH err AS Progress.Lang.Error:
            po-result:Add("status", "0").
            po-result:Add("erro", err:GetMessage(1)).
        END CATCH.
    END.
END PROCEDURE.
