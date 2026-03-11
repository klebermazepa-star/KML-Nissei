//****************************************************************************************************
// vers∆o = v20
//****************************************************************************************************

{utp/ut-api.i} 
{utp/ut-api-utils.i}
{utp/ut-glob.i}

//****************************************************************************************************
//****************************************************************************************************
//****************************************************************************************************

// definiá∆o tt-dados-nota, tt-ordens e tt-erros
{esp\roboteasy\apiCriarNotaEntrada.i}

DEF TEMP-TABLE tt-duplicatas NO-UNDO SERIALIZE-NAME "duplicatas"
    FIELD num-parcela       AS INTE SERIALIZE-NAME "numParcela"
    FIELD data-venc         AS DATE SERIALIZE-NAME "dataVencimento"
    FIELD valor-parcela     AS DECI SERIALIZE-NAME "valorParcela"
    .

DEF TEMP-TABLE tt-param NO-UNDO SERIALIZE-NAME "param"
    FIELD prazo-minimo-pagto AS INTE    SERIALIZE-NAME "prazoMinimoPagamento"
    FIELD erro-val-dup       AS LOGICAL SERIALIZE-NAME "erroValorDup"
    FIELD erro-venc-dup      AS LOGICAL SERIALIZE-NAME "erroVencimentoDup"
    FIELD erro-prazo-minimo  AS LOGICAL SERIALIZE-NAME "erroPrazoMinimo"
    .

// MODELO = definir parametros retornados
DEF TEMP-TABLE tt-retorno NO-UNDO SERIALIZE-NAME "retorno" 
    FIELD status-cod                    AS CHAR INITIAL "NOK"       SERIALIZE-NAME "statusCodigo" 
    FIELD status-obs                    AS CHAR                     SERIALIZE-NAME "statusObs" 
    FIELD status-versao                 AS INT                      SERIALIZE-NAME "statusVersao" INITIAL 31
    .

DEF VAR c-aux AS CHAR.

//--------------------------------------------------
// definiá‰es para executar RE1005RP

DEFINE TEMP-TABLE tt-param-re1005 NO-UNDO
    FIELD destino            AS INTEGER 
    FIELD arquivo            AS CHAR 
    FIELD usuario            AS CHAR 
    FIELD data-exec          AS DATE 
    FIELD hora-exec          AS INTEGER 
    FIELD classifica         AS INTEGER 
    FIELD c-cod-estabel-ini  AS CHAR 
    FIELD c-cod-estabel-fim  AS CHAR 
    FIELD i-cod-emitente-ini AS INTEGER 
    FIELD i-cod-emitente-fim AS INTEGER 
    FIELD c-nro-docto-ini    AS CHAR 
    FIELD c-nro-docto-fim    AS CHAR 
    FIELD c-serie-docto-ini  AS CHAR 
    FIELD c-serie-docto-fim  AS CHAR
    field c-nat-operacao-ini AS CHAR 
    FIELD c-nat-operacao-fim AS CHAR 
    FIELD da-dt-trans-ini    AS DATE   
    FIELD da-dt-trans-fim    AS DATE. 

DEFINE TEMP-TABLE tt-digita NO-UNDO
    FIELD r-docum-est AS ROWID.

DEF VAR raw-param AS RAW no-undo.

DEF TEMP-TABLE tt-raw-digita NO-UNDO
   FIELD raw-digita   as raw.

DEF TEMP-TABLE tt-relat-erro NO-UNDO
    FIELD cod-erro  AS INTE
    FIELD desc-erro AS CHAR
    FIELD tipo      AS INTE.

//****************************************************************************************************

DEF VAR i-cod-erro AS INTE NO-UNDO.

PROCEDURE pi-main:

    bloco-main:
    DO TRANS ON ERROR UNDO, RETRY:
    
        assign tt-retorno.status-obs = tt-retorno.status-obs + "|01".

        if  retry then do:
        
            assign tt-retorno.status-obs = tt-retorno.status-obs + "|02".
                
            FIND FIRST tt-retorno NO-ERROR.
            IF  NOT AVAIL tt-retorno THEN DO:
                CREATE tt-retorno.
            END.
            ASSIGN tt-retorno.status-cod = "NOK".
            CREATE tt-erros.
            ASSIGN tt-erros.cd-erro   = 0
                   tt-erros.desc-erro = "Ocorreu um erro n∆o identificado na rotina: pi-main".
            leave bloco-main.
        end.

        //--------------------------------------------------
        IF  tt-dados-nota.obs = "oc inf" THEN DO:
            FOR FIRST tt-ordens: END.
            FOR FIRST ordem-compra NO-LOCK WHERE ordem-compra.numero-ordem = tt-ordens.num-ordem. END.
            FOR FIRST emitente NO-LOCK WHERE emitente.cod-emitente = ordem-compra.cod-emitente: END.
            FOR FIRST estabelec NO-LOCK WHERE estabelec.cod-estabel = ordem-compra.cod-estabel. END.
            ASSIGN tt-dados-nota.cnpj-fornec = emitente.cgc
                   tt-dados-nota.cnpj-estab  = estabelec.cgc
                   tt-dados-nota.dat-emis    = TODAY
                   tt-ordens.quantidade            = ordem-compra.qt-solic
                   tt-ordens.preco-unit            = ordem-compra.preco-unit
                   tt-ordens.val-mercad            = round(ordem-compra.qt-solic * ordem-compra.preco-unit, 2).
        END.
        //--------------------------------------------------
    
/*         gerar-nota: */
/*         DO ON ERROR UNDO, RETRY: */
/*    */
/*             assign tt-retorno.status-obs = tt-retorno.status-obs + "|03". */
/*    */
/*             if  retry then do: */
/*                 assign tt-retorno.status-obs = tt-retorno.status-obs + "|04". */
/*    */
/*                 ASSIGN tt-retorno.status-cod = "NOK". */
/*                 CREATE tt-erros. */
/*                 ASSIGN tt-erros.cd-erro   = 0 */
/*                        tt-erros.desc-erro = "Ocorreu um erro n∆o identificado no bloco gerar-nota". */
/*                 leave gerar-nota. */
/*             end. */

assign tt-retorno.status-obs = tt-retorno.status-obs + "|05".
    
            RUN esp/roboteasy/ApiCriarNotaEntrada.p (INPUT TABLE  tt-dados-nota,
                                                     INPUT TABLE  tt-ordens,
                                                     OUTPUT TABLE tt-erros).
                                                     
assign tt-retorno.status-obs = tt-retorno.status-obs + "|06".

            FOR FIRST tt-erros:
                assign tt-retorno.status-obs = tt-retorno.status-obs + "|07".
                //UNDO gerar-nota, LEAVE gerar-nota.
                UNDO bloco-main, LEAVE bloco-main.
            END.
        
            FOR FIRST docum-est NO-LOCK
                WHERE docum-est.cod-chave-aces-nf-eletro = tt-dados-nota.chave-nfe:
                assign tt-retorno.status-obs = tt-retorno.status-obs + "|08".
            END.
        
            assign tt-retorno.status-obs = tt-retorno.status-obs + "|09".
            RUN pi-validar-duplicatas.
            assign tt-retorno.status-obs = tt-retorno.status-obs + "|10".

    
            FOR FIRST tt-erros:
                assign tt-retorno.status-obs = tt-retorno.status-obs + "|11".

                //UNDO gerar-nota, LEAVE gerar-nota.
                UNDO bloco-main, LEAVE bloco-main.
            END.
    
        // alterei para bloco-main END. // DO TRANS ON ERROR UNDO, RETRY: - gerar-nota
    
        assign tt-retorno.status-obs = tt-retorno.status-obs + "|12".

        FOR FIRST tt-erros:
        END.
    
        IF  NOT AVAIL tt-erros THEN DO:
  
            //--------------------------------------------------
            RUN pi-atualizar-nota.
  
            FOR FIRST tt-erros: END.
            IF  NOT AVAIL tt-erros THEN DO:
  
                IF i-cod-erro = 4070 THEN DO:
                    ASSIGN tt-retorno.status-cod = "OK".
                    CREATE tt-erros.
                    ASSIGN tt-erros.cd-erro   = 0
                           tt-erros.desc-erro = "Documento criado com sucesso".
                END.
                ELSE DO:
                    CREATE tt-erros.
                    ASSIGN tt-erros.cd-erro = 0.
                    FOR FIRST docum-est NO-LOCK
                        WHERE docum-est.cod-chave-aces-nf-eletro = tt-dados-nota.chave-nfe:
                    END.
                    IF  AVAIL docum-est THEN
                        ASSIGN tt-erros.desc-erro = "[Atualizar Nota] Nota ficou pendente no RE1001. Ocorreu um erro n∆o identificado na atualizaá∆o da nota".
                    ELSE
                        ASSIGN tt-erros.desc-erro = "[Atualizar Nota] Nota n∆o ficou pendente no RE1001. Ocorreu um erro n∆o identificado na atualizaá∆o da nota".
                END.
  
            END.
        END. // IF  NOT AVAIL tt-erros THEN DO:


assign tt-retorno.status-obs = tt-retorno.status-obs + "|13".

assign tt-retorno.status-obs = tt-retorno.status-obs + "|14".

    END. // bloco-main
    
assign tt-retorno.status-obs = tt-retorno.status-obs + "|15".
   
    // algumas mensagem da API retornavam com espaáos adicionais
    FOR EACH tt-erros:
        ASSIGN tt-erros.desc-erro = TRIM(tt-erros.desc-erro).
    END.
    
END PROCEDURE.

//****************************************************************************************************
//****************************************************************************************************
//****************************************************************************************************

DEF DATASET dsPrincipal SERIALIZE-HIDDEN 
    FOR tt-retorno.
                    
RUN pi-post (INPUT jsonInput, OUTPUT jsonOutput).

// replicar parametro do JSON de entrada no JSON de saida
CREATE tt-retorno.
ASSIGN tt-retorno.status-cod = "NOK".
       tt-retorno.status-obs = "".

//--------------------------------------------------
// tt-param
FIND FIRST tt-param NO-ERROR.
IF  NOT AVAIL tt-param THEN DO:
    ASSIGN tt-retorno.status-obs = "Parametros nao foram informados".
//    RETURN.
END.

//--------------------------------------------------

// tt-dados-nota
FIND FIRST tt-dados-nota NO-ERROR.
IF  NOT AVAIL tt-dados-nota THEN DO:
    ASSIGN tt-retorno.status-obs = "Dados da nota nao foram informados".
//    RETURN.
END.

//--------------------------------------------------
// tt-ordens
FIND FIRST tt-ordens NO-ERROR.
IF  NOT AVAIL tt-ordens THEN DO:
    ASSIGN tt-retorno.status-obs = "Ordens de compra foram informadas".
//    RETURN.
END.

//--------------------------------------------------
// tt-duplicatas
FIND FIRST tt-duplicatas NO-ERROR.
IF  NOT AVAIL tt-duplicatas 
AND AVAIL tt-param
AND NOT tt-param.erro-val-dup
AND NOT tt-param.erro-venc-dup THEN DO:
    ASSIGN tt-retorno.status-obs = "Duplicatas nao foram informadas".

    CREATE tt-erros.
    ASSIGN tt-erros.cd-erro   = 0
           tt-erros.desc-erro = "Duplicatas nao foram informadas".
    
//    RETURN.
END.

//--------------------------------------------------

IF  tt-retorno.status-obs = "" THEN 
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
    DEF          VAR jOrdens             AS JsonObject NO-UNDO. 
    DEF          VAR jAux                AS JsonObject NO-UNDO. 
    DEF          VAR lOk                 AS l          NO-UNDO.
    DEFINE VARIABLE jsonArrayAux  AS JsonArray            NO-UNDO.

    DEF VAR i-length AS INTE NO-UNDO.
    DEF VAR i-aux AS INTE NO-UNDO.

    bloco-post:
    DO ON ERROR UNDO, RETRY:
    
    IF  RETRY THEN DO:
        CREATE tt-erros.
        ASSIGN tt-erros.cd-erro   = 0
               tt-erros.desc-erro = "Ocorreu um erro n∆o identificado na pi-post".
        LEAVE bloco-post.
    END.
    
    ASSIGN jsonObjectPayload = jsonInput:GetJsonObject("payload").

    //--------------------------------------------------
    // param
    ASSIGN jAux = jsonObjectPayload:GetJsonObject("param") 
           lOk  = TEMP-TABLE tt-param:READ-JSON("JsonObject", jAux) NO-ERROR.
    
    FIND FIRST tt-param NO-ERROR.
    IF  NOT AVAIL tt-param THEN
        // JSON com "Param"
        ASSIGN jParam = jsonObjectPayload:GetJsonObject("Param") 
               lOk = TEMP-TABLE tt-param:READ-JSON("JsonObject", jAux) NO-ERROR.

    //--------------------------------------------------
    // dadosNota
    ASSIGN jAux = jsonObjectPayload:GetJsonObject("dadosNota") 
           lOk  = TEMP-TABLE tt-dados-nota:READ-JSON("JsonObject", jAux) NO-ERROR.
    
    //--------------------------------------------------
    // ordens
    IF jsonObjectPayload:Has("ordens") THEN DO:
        
        jsonArrayAux = jsonObjectPayload:GetJsonArray("ordens").
        ASSIGN i-length = jsonArrayAux:LENGTH.

        IF i-length > 0 THEN
        DO i-aux = 1 TO i-length:
            jAux = jsonArrayAux:GetJsonObject(i-aux).
            CREATE tt-ordens.
            ASSIGN tt-ordens.num-ordem    = IF jAux:has("numOrdem")    THEN jAux:GetInteger("numOrdem")      ELSE ? NO-ERROR.  
                   tt-ordens.nat-operacao = IF jAux:has("natOperacao") THEN jAux:GetCharacter("natOperacao") ELSE ? NO-ERROR.   
                   tt-ordens.quantidade   = IF jAux:has("quantidade")  THEN jAux:GetDecimal("quantidade")    ELSE ? NO-ERROR.   
                   tt-ordens.preco-unit   = IF jAux:has("precoUnit")   THEN jAux:GetDecimal("precoUnit")     ELSE ? NO-ERROR.   
                   tt-ordens.val-mercad   = IF jAux:has("valorMercad") THEN jAux:GetDecimal("valorMercad")   ELSE ? NO-ERROR.   
        END.
    END.

    //--------------------------------------------------
    // duplicatas
    IF jsonObjectPayload:Has("duplicatas") THEN DO:
        
        jsonArrayAux = jsonObjectPayload:GetJsonArray("duplicatas").
        ASSIGN i-length = jsonArrayAux:LENGTH.

        IF i-length > 0 THEN
        DO i-aux = 1 TO i-length:
            jAux = jsonArrayAux:GetJsonObject(i-aux).
            CREATE tt-duplicatas.
            ASSIGN tt-duplicatas.num-parcela   = IF jAux:has("numParcela")     THEN jAux:GetInteger("numParcela")   ELSE ? NO-ERROR.  
                   tt-duplicatas.data-venc     = IF jAux:has("dataVencimento") THEN jAux:GetDate("dataVencimento")  ELSE ? NO-ERROR.   
                   tt-duplicatas.valor-parcela = IF jAux:has("valorParcela")   THEN jAux:GetDecimal("valorParcela") ELSE ? NO-ERROR.   
        END.
    END.
    
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

//****************************************************************************************************

    DEFINE VARIABLE oJsonArrayErros AS JsonArray         NO-UNDO.

    // ADICIONAR DADOS NO JSON DE RETORNO
    oJsonArrayErros = NEW JsonArray().
    oJsonArrayErros:READ(TEMP-TABLE tt-erros:HANDLE).
    jsonObjectOutput:ADD("erros", oJsonArrayErros).

//****************************************************************************************************    

    jsonOutput = JsonAPIResponseBuilder:ok(jsonObjectOutput, iRet).
    
END PROCEDURE.

//****************************************************************************************************

PROCEDURE pi-atualizar-nota:

    DEF VAR c-linha AS CHAR FORMAT "x(70)".
    DEF VAR c-desc-erro AS CHAR NO-UNDO.

    bloco-atualizar-nota:
    DO ON ERROR UNDO, RETRY:
    
        IF  RETRY THEN DO:
            CREATE tt-erros.
            ASSIGN tt-erros.cd-erro   = 0
                   tt-erros.desc-erro = "Ocorreu um erro n∆o identificado na pi-atualizar-nota".
            LEAVE bloco-atualizar-nota.
        END.
            
        //--------------------------------------------------
        // executar RE1005RP
    
        ASSIGN i-cod-erro = 0.
    
        bloco-atualizar:    
        DO ON ERROR UNDO, LEAVE:
    
            FIND FIRST usuar_mestre
                 WHERE usuar_mestre.cod_usuario = c-seg-usuario NO-LOCK NO-ERROR.
                    
            EMPTY TEMP-TABLE tt-param-re1005.
                    
            CREATE tt-param-re1005.
            ASSIGN tt-param-re1005.usuario   = c-seg-usuario // tt-param.cod-usuario
                   tt-param-re1005.destino   = 2
                   tt-param-re1005.data-exec = TODAY
                   tt-param-re1005.hora-exec = TIME
                   tt-param-re1005.arquivo   = IF AVAIL usuar_mestre AND usuar_mestre.nom_dir_spool <> "" 
                                               THEN (usuar_mestre.nom_dir_spool + "/")
                                               ELSE SESSION:TEMP-DIRECTORY + "/".

            IF  OPSYS BEGINS "WIN" THEN
                ASSIGN tt-param-re1005.arquivo = replace(tt-param-re1005.arquivo, "/", "\")
                       tt-param-re1005.arquivo = replace(tt-param-re1005.arquivo, "\\", "\").
            ELSE
                ASSIGN tt-param-re1005.arquivo = replace(tt-param-re1005.arquivo, "\", "/")
                       tt-param-re1005.arquivo = replace(tt-param-re1005.arquivo, "//", "/").

            ASSIGN tt-param-re1005.arquivo   = tt-param-re1005.arquivo 
                                               + "RE1005-RPA-" 
                                               + substring(string(year(today),"9999"),3,2)  + string(month(today),"99") + string(day(today),"99") + "-" 
                                               + REPLACE(STRING(TIME,"HH:MM:SS"),":", "") 
                                               + ".txt":U.

            RAW-TRANSFER tt-param-re1005 TO raw-param.
        
            FOR EACH tt-raw-digita EXCLUSIVE-LOCK:
                DELETE tt-raw-digita.
            END.
        
            CREATE tt-digita.
            ASSIGN tt-digita.r-docum-est = ROWID(docum-est).
            
            FOR EACH tt-digita EXCLUSIVE-LOCK:
                CREATE tt-raw-digita.
                RAW-TRANSFER tt-digita TO tt-raw-digita.raw-digita.
            END.
        
            RUN rep/re1005rp.p (INPUT raw-param, INPUT TABLE tt-raw-digita).
        
            //--------------------------------------------------
            // tratar mensagens de erro
        
            ASSIGN tt-retorno.status-obs = "[Atualizar Nota] Arq = " + tt-param-re1005.arquivo.
    
            PAUSE 10 NO-MESSAGE.
            IF  SEARCH(tt-param-re1005.arquivo) = ? THEN DO:
                CREATE tt-erros.
                ASSIGN tt-erros.cd-erro   = 0
                       tt-erros.desc-erro = "[Atualizar Nota] Nota ficou pendente no RE1001. Arquivo n∆o encontrado: " + tt-param-re1005.arquivo.
                RETURN.
            END.
    
            INPUT FROM VALUE(tt-param-re1005.arquivo) CONVERT TARGET "iso8859-1".
        
            REPEAT:
        
                IMPORT UNFORMATTED c-linha.
        
                ASSIGN i-cod-erro = ?.
                ASSIGN i-cod-erro = INT(SUBSTRING(c-linha, 44, 8)) NO-ERROR.
        
                IF  i-cod-erro = ? OR i-cod-erro = 0 OR i-cod-erro = 6505 THEN NEXT. // 6505 = nota possui advertencias
        
                IF  i-cod-erro = 4070 THEN NEXT.
        
                CREATE tt-relat-erro.
                ASSIGN tt-relat-erro.cod-erro = i-cod-erro
                       tt-relat-erro.desc-erro = TRIM(SUBSTRING(c-linha, 53, 100)).
        
                FOR FIRST cadast_msg NO-LOCK 
                    WHERE cadast_msg.cdn_msg = tt-relat-erro.cod-erro:
                    ASSIGN tt-relat-erro.tipo = cadast_msg.idi_tip_msg.
                END.
            END.
        
            INPUT CLOSE.
        END. // DO ON ERROR UNDO, LEAVE: // bloco-atualizar

        //--------------------------------------------------
        // verificar se a nota foi atualizada

        FOR FIRST docum-est NO-LOCK
            WHERE docum-est.cod-chave-aces-nf-eletro = tt-dados-nota.chave-nfe:
        END.

        ASSIGN c-desc-erro = "".

        IF  AVAIL docum-est
        AND docum-est.ce-atual = NO THEN DO:
            FOR FIRST tt-relat-erro
                WHERE tt-relat-erro.tipo = 1:
                ASSIGN c-desc-erro = tt-relat-erro.desc-erro.
            END.
            IF  c-desc-erro = "" THEN DO:
                FOR FIRST tt-relat-erro
                    WHERE tt-relat-erro.tipo = 2:
                    ASSIGN c-desc-erro = tt-relat-erro.desc-erro.
                END.
                IF  c-desc-erro = "" THEN DO:
                    FOR FIRST tt-relat-erro
                        WHERE tt-relat-erro.tipo = 4:
                        ASSIGN c-desc-erro = tt-relat-erro.desc-erro.
                    END.
                    IF  c-desc-erro = "" THEN DO:
                        FOR FIRST tt-relat-erro
                            WHERE tt-relat-erro.tipo = 3:
                            ASSIGN c-desc-erro = tt-relat-erro.desc-erro.
                        END.
                        IF  c-desc-erro = "" THEN DO:
                            ASSIGN c-desc-erro = "Erro na Geraá∆o do Arquivo na atualizaá∆o da nota pelo RE1005RP".
                        END.
                    END.
                END.
            END.
        END.
    
        IF  c-desc-erro <> "" THEN DO: 
            CREATE tt-erros.
            ASSIGN tt-erros.cd-erro      = IF AVAIL tt-relat-erro THEN tt-relat-erro.cod-erro ELSE 0
                   tt-erros.desc-erro    = "[Atualizar Nota] " + c-desc-erro.
                   
            ASSIGN tt-retorno.status-obs = "[Atualizar Nota] Nota ficou pendente no RE1001. Arq = " + tt-param-re1005.arquivo.
        END.
    
    END. // bloco-atualizar-nota
    
END PROCEDURE.

//****************************************************************************************************    

PROCEDURE pi-validar-duplicatas:
    
    DEF VAR c-erro-val-dup      AS CHAR NO-UNDO.
    DEF VAR c-erro-venc-dup     AS CHAR NO-UNDO.
    DEF VAR i-cont-1            AS INTE NO-UNDO.
    DEF VAR i-cont-2            AS INTE NO-UNDO.
    DEF VAR i-empresa           AS CHAR NO-UNDO.

assign tt-retorno.status-obs = tt-retorno.status-obs + "|16".

    validar-dup:
    DO ON ERROR UNDO, RETRY:
    
    IF  RETRY THEN DO:
        assign tt-retorno.status-obs = tt-retorno.status-obs + "|17".

        CREATE tt-erros.
        ASSIGN tt-erros.cd-erro   = 0
               tt-erros.desc-erro = "[Duplicatas] Ocorreu um erro n∆o identificado na pi-validar-duplicatas".
        LEAVE validar-dup.
    END.

    assign tt-retorno.status-obs = tt-retorno.status-obs + "|18".

    FIND FIRST param-re WHERE param-re.usuario = c-seg-usuario NO-LOCK NO-ERROR.

    FOR FIRST estabelec WHERE estabelec.cod-estabel = docum-est.cod-estabel NO-LOCK:
        run cdp/cd9970.p (INPUT  ROWID(estabelec),
                          OUTPUT i-empresa). 
    END.

    //----------------------------------------------------------------------
    // validar quantidade de duplicatas
    //----------------------------------------------------------------------
    
    ASSIGN i-cont-1 = 0
           i-cont-2 = 0.
    FOR EACH dupli-apagar NO-LOCK
        WHERE dupli-apagar.serie-docto  = docum-est.serie-docto 
        AND   dupli-apagar.nro-docto    = docum-est.nro-docto   
        AND   dupli-apagar.cod-emitente = docum-est.cod-emitente
        AND   dupli-apagar.nat-operacao = docum-est.nat-operacao:
        ASSIGN i-cont-1 = i-cont-1 + 1.
    END.
    ASSIGN i-cont-2 = 0.
    FOR EACH tt-duplicatas:
        ASSIGN i-cont-2 = i-cont-2 + 1.
    END.

assign tt-retorno.status-obs = tt-retorno.status-obs + "|19".

    IF  i-cont-1 <> i-cont-2 THEN DO:
        assign tt-retorno.status-obs = tt-retorno.status-obs + "|20".

        IF  tt-param.erro-val-dup  = NO
        OR  tt-param.erro-venc-dup = NO THEN DO:

            assign tt-retorno.status-obs = tt-retorno.status-obs + "|21".

            // quando um dos dois parÉmetros estiverem igual a NO ent∆o valida a quant duplicatas
            // para aprovar uma nota com divergància na quant de duplicatas tem que liberar "erro valor" e "erro vencimento"
            //    - tt-param.erro-val-dup 
            //    - tt-param.erro-venc-dup 
            CREATE tt-erros.
            ASSIGN tt-erros.cd-erro   = 0
                   tt-erros.desc-erro = "[Duplicatas] A quantidade de duplicatas informada no XML Ç diferente da quantidade de duplicatas gerada na nota".
        END.
        ELSE DO:
            assign tt-retorno.status-obs = tt-retorno.status-obs + "|22".

            FOR FIRST tt-ordens:
                FIND FIRST ordem-compra WHERE ordem-compra.numero-ordem = tt-ordens.num-ordem NO-LOCK NO-ERROR.
            END.
            
            for first tt-duplicatas:
            end.
            
            //----------------------------------------------------------------------
            // tem diferenáa na quant de duplicatas
            // mas tem autorizaáo de vencto e valor
            // foi enviada a tt-duplicatas no JSON
            // ento vai copiar as duplicatas informadas p/ anota
            //----------------------------------------------------------------------
            
            if  avail tt-duplicatas then do:

                FOR EACH dupli-apagar EXCLUSIVE-LOCK
                    WHERE dupli-apagar.serie-docto  = docum-est.serie-docto 
                    AND   dupli-apagar.nro-docto    = docum-est.nro-docto   
                    AND   dupli-apagar.cod-emitente = docum-est.cod-emitente
                    AND   dupli-apagar.nat-operacao = docum-est.nat-operacao:
                    DELETE dupli-apagar.
                END.
    
                FOR EACH tt-duplicatas:
                    CREATE dupli-apagar.
                    ASSIGN dupli-apagar.ep-codigo        = i-empresa
                           dupli-apagar.cod-estabel      = docum-est.cod-estabel
                           dupli-apagar.cod-emitente     = docum-est.cod-emitente
                           dupli-apagar.dt-emissao       = docum-est.dt-emissao
                           dupli-apagar.dt-trans         = docum-est.dt-trans
                           dupli-apagar.dt-vencim        = tt-duplicatas.data-venc
                           dupli-apagar.esp-movto        = 1
                           dupli-apagar.nat-operacao     = docum-est.nat-operacao
                           dupli-apagar.nro-docto        = docum-est.nro-docto
                           dupli-apagar.parcela          = STRING(tt-duplicatas.num-parcela,"99")
                           dupli-apagar.serie-docto      = docum-est.serie-docto
                           dupli-apagar.nr-duplic        = docum-est.nro-docto
                           dupli-apagar.tp-despesa       = ordem-compra.tp-despesa
                           dupli-apagar.cod-esp          = IF docum-est.nff THEN param-re.esp-def-nff ELSE param-re.esp-def-dup
                           dupli-apagar.vl-a-pagar       = tt-duplicatas.valor-parcela
                           dupli-apagar.valor-a-pagar-me = tt-duplicatas.valor-parcela.
                END.
                assign tt-retorno.status-obs = tt-retorno.status-obs + "|23".
    
                RETURN.
            end. // if  avail tt-duplicatas then do:

        END. // ELSE .. IF  tt-param.erro-val-dup  = NO

        assign tt-retorno.status-obs = tt-retorno.status-obs + "|24".

    END. // IF  i-cont-1 <> i-cont-2 THEN DO:

    assign tt-retorno.status-obs = tt-retorno.status-obs + "|25".

    //----------------------------------------------------------------------
    // validar vencto e valor de cad parcela (quando tem duplicatas)
    //----------------------------------------------------------------------

    assign tt-retorno.status-obs = tt-retorno.status-obs + "|26".

    FOR FIRST tt-duplicatas 
        WHERE tt-duplicatas.num-parcela = INT(dupli-apagar.parcela):
    END.
    
    if  avail tt-duplicatas then do:

        ASSIGN c-erro-val-dup  = ""
               c-erro-venc-dup = "".
    
        FOR EACH dupli-apagar NO-LOCK
            WHERE dupli-apagar.serie-docto  = docum-est.serie-docto 
            AND   dupli-apagar.nro-docto    = docum-est.nro-docto   
            AND   dupli-apagar.cod-emitente = docum-est.cod-emitente
            AND   dupli-apagar.nat-operacao = docum-est.nat-operacao:
            
            IF  tt-duplicatas.valor-parcela <> dupli-apagar.vl-a-pagar THEN
                ASSIGN c-erro-val-dup = dupli-apagar.parcela.
            IF  tt-duplicatas.data-venc <> dupli-apagar.dt-vencim THEN
                ASSIGN c-erro-venc-dup = dupli-apagar.parcela.
        END.
    
        IF  c-erro-val-dup <> "" THEN DO:
        
            assign tt-retorno.status-obs = tt-retorno.status-obs + "|27".
    
            IF  tt-param.erro-val-dup = NO THEN DO:
                FOR FIRST dupli-apagar NO-LOCK
                    WHERE dupli-apagar.serie-docto  = docum-est.serie-docto 
                    AND   dupli-apagar.nro-docto    = docum-est.nro-docto   
                    AND   dupli-apagar.cod-emitente = docum-est.cod-emitente
                    AND   dupli-apagar.nat-operacao = docum-est.nat-operacao
                    AND   dupli-apagar.parcela      = c-erro-val-dup:
                END.
                CREATE tt-erros.
                ASSIGN tt-erros.cd-erro   = 0
                       tt-erros.desc-erro = "[Duplicatas] O valor da duplicata " + c-erro-val-dup + " no XML est† diferente do valor calculado p/ a duplicata da nota. Valor no XML = " + TRIM(STRING(tt-duplicatas.valor-parcela)) + " Valor Calculado = " + TRIM(STRING(dupli-apagar.vl-a-pagar)).
                                            
            END.
            ELSE DO:
                FOR EACH dupli-apagar EXCLUSIVE-LOCK
                    WHERE dupli-apagar.serie-docto  = docum-est.serie-docto 
                    AND   dupli-apagar.nro-docto    = docum-est.nro-docto   
                    AND   dupli-apagar.cod-emitente = docum-est.cod-emitente
                    AND   dupli-apagar.nat-operacao = docum-est.nat-operacao:
                    FOR FIRST tt-duplicatas 
                        WHERE tt-duplicatas.num-parcela = INT(dupli-apagar.parcela):
                    END.
                    IF  NOT AVAIL tt-duplicatas THEN DO:
                        CREATE tt-erros.
                        ASSIGN tt-erros.cd-erro   = 0
                               tt-erros.desc-erro = "[Duplicatas] Erro na atualizaá∆o do valor da parcela (parc " + TRIM(dupli-apagar.parcela) + ")".
                    END.
                    ELSE
                        ASSIGN dupli-apagar.vl-a-pagar = tt-duplicatas.valor-parcela.
                END.
            END.
        END.
    
        IF  c-erro-venc-dup <> "" THEN DO:
            assign tt-retorno.status-obs = tt-retorno.status-obs + "|28".
        
            IF  tt-param.erro-venc-dup = NO THEN DO:
                FOR FIRST dupli-apagar NO-LOCK
                    WHERE dupli-apagar.serie-docto  = docum-est.serie-docto 
                    AND   dupli-apagar.nro-docto    = docum-est.nro-docto   
                    AND   dupli-apagar.cod-emitente = docum-est.cod-emitente
                    AND   dupli-apagar.nat-operacao = docum-est.nat-operacao
                    AND   dupli-apagar.parcela      = c-erro-venc-dup:
                END.
                CREATE tt-erros.
                ASSIGN tt-erros.cd-erro   = 0
                       tt-erros.desc-erro = "[Duplicatas] O vencimento da duplicata " + c-erro-venc-dup + " no XML est† diferente do vencimento calculado p/ a duplicata da nota. Data Venc XML = " + TRIM(STRING(tt-duplicatas.data-venc)) + " Data Venc Calculada = " + TRIM(STRING(dupli-apagar.dt-vencim)).
                
            END.
            ELSE DO:
                FOR EACH dupli-apagar EXCLUSIVE-LOCK
                    WHERE dupli-apagar.serie-docto  = docum-est.serie-docto 
                    AND   dupli-apagar.nro-docto    = docum-est.nro-docto   
                    AND   dupli-apagar.cod-emitente = docum-est.cod-emitente
                    AND   dupli-apagar.nat-operacao = docum-est.nat-operacao:
                    FOR FIRST tt-duplicatas 
                        WHERE tt-duplicatas.num-parcela = INT(dupli-apagar.parcela):
                    END.
                    IF  NOT AVAIL tt-duplicatas THEN DO:
                        CREATE tt-erros.
                        ASSIGN tt-erros.cd-erro   = 0
                               tt-erros.desc-erro = "[Duplicatas] Erro na atualizaá∆o da data do vencimento (parc " + TRIM(dupli-apagar.parcela) + ")".
                    END.
                    ELSE
                        ASSIGN dupli-apagar.dt-vencim = tt-duplicatas.data-venc.
                END.
            END.
        END.
    
    end. // if  avail tt-duplicatas then do:

    assign tt-retorno.status-obs = tt-retorno.status-obs + "|29".

    FOR FIRST tt-erros:
        assign tt-retorno.status-obs = tt-retorno.status-obs + "|30".

        RETURN.
    END.

    //--------------------------------------------------
    // validar prazo minimo para pagamento

    IF  tt-param.erro-prazo-minimo = NO THEN DO: 

assign tt-retorno.status-obs = tt-retorno.status-obs + "|31".

        ler-dup:
        FOR EACH dupli-apagar EXCLUSIVE-LOCK
            WHERE dupli-apagar.serie-docto  = docum-est.serie-docto 
            AND   dupli-apagar.nro-docto    = docum-est.nro-docto   
            AND   dupli-apagar.cod-emitente = docum-est.cod-emitente
            AND   dupli-apagar.nat-operacao = docum-est.nat-operacao:
    
            IF  dupli-apagar.dt-vencim < TODAY + tt-param.prazo-minimo-pagto THEN DO:
                CREATE tt-erros.
                ASSIGN tt-erros.cd-erro   = 0
                       tt-erros.desc-erro = "[Duplicatas] A data vencimento " + STRING(dupli-apagar.dt-vencim, "99/99/99") + " da duplicata " + dupli-apagar.parcela + " est† menor do que a data m°nima para pagamento " + STRING(TODAY + tt-param.prazo-minimo-pagto, "99/99/99") + ". Prazo m°nimo informado = " + STRING(tt-param.prazo-minimo-pagto).
                LEAVE ler-dup.
            END.
        END.

    END.

assign tt-retorno.status-obs = tt-retorno.status-obs + "|32".

    end. // bloco validar-dup
    
END PROCEDURE.

//****************************************************************************************************
