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
    FIELD status-versao                 AS INT                      SERIALIZE-NAME "statusVersao" INITIAL 32
    FIELD qtd-erros                     AS INT                      SERIALIZE-NAME "quantErros"
    FIELD qtd-notas                     AS INT                      SERIALIZE-NAME "quantNotas"
.

def temp-table tt-erros no-undo serialize-name "erros"
    field seq       as inte serialize-name "seq"
    field msg-erro  as char serialize-name "mensagemErro"
.

def temp-table tt-pedido no-undo serialize-name "pedido"
    field cod-estab     as char     serialize-name "codEstab"
    field num-pedido    as integer  serialize-name "numPedido"
    field obs-nota      as char     serialize-name "obsNota"
    field nome-pasta    as char     serialize-name "nomePasta"
    field ativarTrace   as char     serialize-name "ativarTrace"
    field data-inicial  as date     serialize-name "dataInicial"
    field data-final    as date     serialize-name "dataFinal"
    field arq-int038    as char     serialize-name "arqINT038"    
.

def temp-table tt-notas no-undo serialize-name "notas"
    field cod-estab     as char     serialize-name "codEstab"
    field num-pedido    as integer  serialize-name "numPedido"
    field serie-nota    as char     serialize-name "serieNota"
    field num-nota      as char     serialize-name "numNota"
    field nat-operacao  as char     serialize-name "natOperacao"
    field val-nota      as decimal  serialize-name "valorNota"
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

def buffer b-tt-retorno for tt-retorno.

def var c-data-hora     as char no-undo.
def var i-cont-erros    as inte no-undo.
def var c-arq-aux       as char no-undo.

//****************************************************************************************************

PROCEDURE pi-main:

    CREATE tt-retorno.
    ASSIGN tt-retorno.status-cod = "NOK".
    
    FOR FIRST tt-pedido: 
    END. 

    IF  AVAIL tt-pedido THEN DO:

        assign l-trace = tt-pedido.ativarTrace = "sim".
        
        IF  L-TRACE THEN ASSIGN TT-RETORNO.STATUS-TRACE = TT-RETORNO.STATUS-TRACE + "|01".
        
        if  tt-pedido.cod-estab = ? 
        or  tt-pedido.cod-estab = "" then
            run pi-erro ("C¢digo do estabelecimento n∆o informado").
        else do:
            for first estabelec no-lock
                where estabelec.cod-estabel = tt-pedido.cod-estab:
            end.
            if  not avail estabelec then
                run pi-erro ("C¢digo do estabelecimento inv†lido").
            else do:
                if  tt-pedido.num-pedido = ? 
                or  tt-pedido.num-pedido = 0 then
                    run pi-erro ("N£mero do pedido n∆o informado").
                else do:
                    for first int_ds_pedido no-lock
                        where int_ds_pedido.ped_codigo_n = tt-pedido.num-pedido:
                    end.
                    if  not avail int_ds_pedido then
                        run pi-erro ("N£mero do pedido n∆o encontrado: " + STRING(tt-pedido.num-pedido) ).
                    else do:
                        for first user-coml no-lock
                            where user-coml.usuario = c-seg-usuario:
                        end.
                        if  not avail user-coml then
                            run pi-erro ("Usu†rio n∆o encontrado no cadastro de usu†rios comerciais (CD0812): " + c-seg-usuario).
                        else                    
                            run pi-gerar-nota.
                    end.
                end.
            end.
        end.
    END.
    ELSE
        run pi-erro ("Nenhum pedido foi informado").

    IF  L-TRACE THEN ASSIGN TT-RETORNO.STATUS-TRACE = TT-RETORNO.STATUS-TRACE + "|02".

    for first tt-erros:
        IF  L-TRACE THEN ASSIGN TT-RETORNO.STATUS-TRACE = TT-RETORNO.STATUS-TRACE + "|03".
    end.
    
    run pi-buscar-notas. // deve buscar as notas com cod-status igual a OK ou NOK

    IF  L-TRACE THEN ASSIGN TT-RETORNO.STATUS-TRACE = TT-RETORNO.STATUS-TRACE + "|04".

    for first tt-notas:
        IF  L-TRACE THEN ASSIGN TT-RETORNO.STATUS-TRACE = TT-RETORNO.STATUS-TRACE + "|05".
    end.
    
    for first tt-erros:
        IF  L-TRACE THEN ASSIGN TT-RETORNO.STATUS-TRACE = TT-RETORNO.STATUS-TRACE + "|06".
    end.
    
/***
    if  not avail tt-notas then
        ASSIGN tt-retorno.status-cod = "NOK"
               tt-retorno.status-obs = "N∆o foram geradas notas para o pedido: " + trim(string(tt-pedido.num-pedido)).
   else
        ASSIGN tt-retorno.status-cod = "OK"
               tt-retorno.status-obs = "Notas do pedido " + trim(string(tt-pedido.num-pedido)) + " form emitidas com sucesso".
***/
       
    IF  L-TRACE THEN ASSIGN TT-RETORNO.STATUS-TRACE = TT-RETORNO.STATUS-TRACE + "|07".
   
END PROCEDURE.

//****************************************************************************************************
//****************************************************************************************************

DEF DATASET dsPrincipal SERIALIZE-HIDDEN 
    FOR tt-retorno.
                    
RUN pi-post (INPUT jsonInput, OUTPUT jsonOutput).

assign c-data-hora = substring(string(year(today),"9999"),3,2) + string(month(today),"99") + string(day(today),"99") + "_" + REPLACE(STRING(TIME,"HH:MM:SS"),":", "").

RUN pi-main.

// GRAVAR MENSAGENS DE ERROS DO PROGRESS
/* for first tt-retorno where tt-retorno.status-cod = "NOK": */
/*     assign c-arq-aux = replace(tt-pedido.arq-int038, ".txt", "_LOG.txt"). */
/*     OUTPUT TO VALUE(c-arq-aux) CONVERT TARGET "iso8859-1". */
/*     put unformatted "Quantidade de erros = " ERROR-STATUS:NUM-MESSAGES skip(1). */
/*     IF  ERROR-STATUS:ERROR OR ERROR-STATUS:NUM-MESSAGES > 0 THEN DO: */
/*         DO  i-cont-erros = 1 TO ERROR-STATUS:NUM-MESSAGES: */
/*             put unformatted "(" ERROR-STATUS:GET-NUMBER(i-cont-erros) ") - " ERROR-STATUS:GET-MESSAGE(i-cont-erros) skip. */
/*         END. */
/*     END. */
/*     output close. */
/* end. */
    
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
//            ASSIGN tt-retorno.status-cod = "NOK"
//                   tt-retorno.status-obs = "Ocorreu um erro n∆o identificado na pi-post".
            run pi-erro ("Ocorreu um erro n∆o identificado na pi-post").
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

    DEF VAR jsonObjectOutput    AS JsonObject NO-UNDO.
    DEF VAR iRet                AS i          NO-UNDO.
    DEF VAR lcOutput            AS LONGCHAR   NO-UNDO.
    DEF VAR oJsonArrayAux       AS JsonArray  NO-UNDO.

    def var i-qt-erros      as inte     no-undo.
    def var i-qt-notas      as inte     no-undo.
    
    jsonObjectOutput = NEW JsonObject().
    
    //--------------------------------------------------------------------------------

    IF  TEMP-TABLE tt-erros:HAS-RECORDS
    OR  TEMP-TABLE tt-notas:HAS-RECORDS THEN DO:
        ASSIGN iRet = 200.
        // verificar se tem registro c/ NOK
        for first b-tt-retorno
            where b-tt-retorno.status-cod = "NOK":
        end.    
        // criar OK copiando trace 
        create tt-retorno.
        assign tt-retorno.status-cod   = "OK"
               tt-retorno.status-trace = if  avail b-tt-retorno
                                         then b-tt-retorno.status-trace
                                         else "".
        // excluir registro c/ NOK       
        delete b-tt-retorno.       
    END.          
    ELSE DO:
        ASSIGN iRet = 500.
        // usar registro c/ NOK se j† existir (vai existir)
        for first tt-retorno
            where tt-retorno.status-cod = "NOK":
        end.    
        
        // criar registro c/ NOK se n∆o existir
        IF  NOT AVAIL tt-retorno THEN DO:
            // criar NOK 
            create tt-retorno.
            assign tt-retorno.status-cod = "NOK".
        END.        
    END.

    // sempre vai atualizar para retorno OK ou NOK                
    
    assign tt-retorno.qtd-erros = 0.
    for each tt-erros:
        assign tt-retorno.qtd-erros = tt-retorno.qtd-erros + 1.
    end.

    assign tt-retorno.qtd-notas = 0.
    for each tt-notas:
        assign tt-retorno.qtd-notas = tt-retorno.qtd-notas + 1.
    end.
    
    //--------------------------------------------------------------------------------
    
    // ADICIONAR DADOS NO JSON DE RETORNO
    oJsonArrayAux = NEW JsonArray().
    oJsonArrayAux:READ(TEMP-TABLE tt-pedido:HANDLE).
    jsonObjectOutput:ADD("pedido", oJsonArrayAux).

    //--------------------------------------------------------------------------------
    
    // ADICIONAR DADOS NO JSON DE RETORNO
    oJsonArrayAux = NEW JsonArray().
    oJsonArrayAux:READ(TEMP-TABLE tt-notas:HANDLE).
    jsonObjectOutput:ADD("notas", oJsonArrayAux).

    //--------------------------------------------------------------------------------
    
    // ADICIONAR DADOS NO JSON DE RETORNO
    oJsonArrayAux = NEW JsonArray().
    oJsonArrayAux:READ(TEMP-TABLE tt-erros:HANDLE).
    jsonObjectOutput:ADD("erros", oJsonArrayAux).

    //--------------------------------------------------------------------------------
    
    // ADICIONAR DADOS NO JSON DE RETORNO
    oJsonArrayAux = NEW JsonArray().
    oJsonArrayAux:READ(TEMP-TABLE tt-retorno:HANDLE).
    jsonObjectOutput:ADD("retorno", oJsonArrayAux).

    //--------------------------------------------------------------------------------

    jsonOutput = JsonAPIResponseBuilder:ok(jsonObjectOutput, iRet).
    
END PROCEDURE.

//****************************************************************************************************

PROCEDURE pi-gerar-nota:

    def var c-linha         as char     no-undo.
    def var c-num-nota      as char     no-undo.
    def var l-erro          as logi     no-undo.

    IF  L-TRACE THEN ASSIGN TT-RETORNO.STATUS-TRACE = TT-RETORNO.STATUS-TRACE + "|10".

    bloco-gerar-nota:
    DO TRANS ON ERROR UNDO, RETRY:
       
        IF  RETRY THEN DO:
            IF  L-TRACE THEN ASSIGN TT-RETORNO.STATUS-TRACE = TT-RETORNO.STATUS-TRACE + "|20".
//            ASSIGN tt-retorno.status-cod = "NOK"
//                   tt-retorno.status-obs = "Ocorreu um erro n∆o identificado na pi-gerar-nota".
            run pi-erro ("Ocorreu u erro n∆o identificado na pi-gerar-nota").
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
    
        IF  L-TRACE THEN ASSIGN TT-RETORNO.STATUS-TRACE = TT-RETORNO.STATUS-TRACE + "|30".
    
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
                                    + "RPA_INT038RP_v" + trim(string(tt-retorno.status-versao)) 
                                    + "_" + c-data-hora
                                    + "_" + tt-pedido.cod-estab 
                                    + "_" + trim(string(tt-pedido.num-pedido))
                                    + ".txt":U.
    
        assign tt-pedido.arq-int038 = tt-param.arquivo.
        
        IF  L-TRACE THEN ASSIGN TT-RETORNO.STATUS-TRACE = TT-RETORNO.STATUS-TRACE + "|40".
    
        RAW-TRANSFER tt-param TO raw-param.
        
        RUN intprg/int038rp.p (INPUT raw-param, INPUT TABLE tt-raw-digita).
    
        IF  L-TRACE THEN ASSIGN TT-RETORNO.STATUS-TRACE = TT-RETORNO.STATUS-TRACE + "|50".
    
        IF  SEARCH(tt-param.arquivo) = ? THEN DO:
            IF  L-TRACE THEN ASSIGN TT-RETORNO.STATUS-TRACE = TT-RETORNO.STATUS-TRACE + "|60".
//            ASSIGN tt-retorno.status-cod = "NOK"
//                   tt-retorno.status-obs = "Arquivo do INT038RP n∆o encontrado: " + tt-param.arquivo.
            run pi-erro ("Arquivo do INT038RP n∆o encontrado: " + tt-param.arquivo).

            UNDO bloco-gerar-nota, LEAVE bloco-gerar-nota.
        END.
    
        //--------------------------------------------------------------------------------
    
        IF  L-TRACE THEN ASSIGN TT-RETORNO.STATUS-TRACE = TT-RETORNO.STATUS-TRACE + "|70".
    
        assign l-erro = no.
    
        INPUT FROM VALUE(tt-param.arquivo) CONVERT TARGET "iso8859-1".
        bloco-ler-arq:
        REPEAT:
            IF  L-TRACE THEN ASSIGN TT-RETORNO.STATUS-TRACE = TT-RETORNO.STATUS-TRACE + "|80".
            IMPORT UNFORMATTED c-linha.

            IF  L-TRACE THEN ASSIGN TT-RETORNO.STATUS-TRACE = TT-RETORNO.STATUS-TRACE + "|90".
            
            if  c-linha matches "*ERRO*" then do:
                IF  L-TRACE THEN ASSIGN TT-RETORNO.STATUS-TRACE = TT-RETORNO.STATUS-TRACE + "|100".

                assign l-erro     = yes.
                LEAVE bloco-ler-arq.
            end.
            
            IF  L-TRACE THEN ASSIGN TT-RETORNO.STATUS-TRACE = TT-RETORNO.STATUS-TRACE + "|110".
        END.
        INPUT CLOSE.
    
        IF  L-TRACE THEN ASSIGN TT-RETORNO.STATUS-TRACE = TT-RETORNO.STATUS-TRACE + "|120".
        
        //--------------------------------------------------------------------------------
        
        IF  l-erro THEN DO:

            IF  L-TRACE THEN ASSIGN TT-RETORNO.STATUS-TRACE = TT-RETORNO.STATUS-TRACE + "|130".
            run pi-erro ("Verificar relt¢rio da execuá∆o porque ocorreu um erro na geraá∆o da nota para o pedido: " + STRING(tt-pedido.num-pedido)).

            UNDO bloco-gerar-nota, LEAVE bloco-gerar-nota.        
        end.    

        //--------------------------------------------------------------------------------
        
        IF  L-TRACE THEN ASSIGN TT-RETORNO.STATUS-TRACE = TT-RETORNO.STATUS-TRACE + "|160".

    END. // bloco-gerar-nota    
    
    IF  L-TRACE THEN ASSIGN TT-RETORNO.STATUS-TRACE = TT-RETORNO.STATUS-TRACE + "|170".
    
END PROCEDURE.

//****************************************************************************************************

PROCEDURE pi-buscar-notas:

    IF  L-TRACE THEN ASSIGN TT-RETORNO.STATUS-TRACE = TT-RETORNO.STATUS-TRACE + "|180".

    for first emitente no-lock 
        where emitente.cgc = trim(int_ds_pedido.ped_cnpj_destino_s):
    end.   
        
    for first estabelec no-lock
        where estabelec.cgc = trim(int_ds_pedido.ped_cnpj_origem_s):
    end.
    
    if  avail estabelec
    and avail emitente then do:
    
        IF  L-TRACE THEN ASSIGN TT-RETORNO.STATUS-TRACE = TT-RETORNO.STATUS-TRACE + "|190".
       
        empty temp-table tt-notas.
        
        for each nota-fiscal FIELDS (cod-estabel nr-nota-fis serie nat-operacao vl-tot-nota) USE-INDEX ch-distancia no-lock // ler notas da data corrente
            where nota-fiscal.cod-estabel  = estabelec.cod-estabel
            and   nota-fiscal.cod-emitente = emitente.cod-emitente
            and   nota-fiscal.dt-emis-nota = today
            and   nota-fiscal.dt-cancela   = ? 
            and   nota-fiscal.nr-pedcli    = trim(string(tt-pedido.num-pedido)):
        
            IF  L-TRACE THEN ASSIGN TT-RETORNO.STATUS-TRACE = TT-RETORNO.STATUS-TRACE + "|200".
         
            create tt-notas.
            ASSIGN tt-notas.cod-estab    = nota-fiscal.cod-estabel
                   tt-notas.num-pedido   = tt-pedido.num-pedido
                   tt-notas.num-nota     = nota-fiscal.nr-nota-fis
                   tt-notas.serie-nota   = nota-fiscal.serie
                   tt-notas.nat-operacao = nota-fiscal.nat-operacao
                   tt-notas.val-nota     = nota-fiscal.vl-tot-nota.
        end.        
        
        IF  L-TRACE THEN ASSIGN TT-RETORNO.STATUS-TRACE = TT-RETORNO.STATUS-TRACE + "|210".
    end.     
    
    IF  L-TRACE THEN ASSIGN TT-RETORNO.STATUS-TRACE = TT-RETORNO.STATUS-TRACE + "|220".
    
END PROCEDURE.

PROCEDURE pi-erro:

    def input param p-c-msg-erro    as char     no-undo.

    def var i-seq as inte no-undo.
    
    for last tt-erros:
    end.
    
    ASSIGN i-seq = IF NOT AVAIL tt-erros THEN 1 ELSE tt-erros.seq + 1.
    
    create tt-erros.
    assign tt-erros.seq      = i-seq
           tt-erros.msg-erro = p-c-msg-erro.

END PROCEDURE.

