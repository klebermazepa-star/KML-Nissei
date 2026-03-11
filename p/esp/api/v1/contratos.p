//USING Progress.Json.ObjectModel.*.

USING Progress.Json.ObjectModel.JsonArray.
USING Progress.Json.ObjectModel.JsonObject.
USING Progress.Json.ObjectModel.JsonDataType.
USING Progress.Json.ObjectModel.ObjectModelParser.

{utp/ut-api.i}
{utp/ut-api-action.i pi-gera-contrato      POST  /~* }

{utp/ut-api-notfound.i}

{method/dbotterr.i} /*RowErrors*/

DEF TEMP-TABLE tt-contrato NO-UNDO SERIALIZE-NAME "contrato"
    FIELD nr-contrato       AS INT
    FIELD descricao         AS CHAR
    FIELD cnpj-fornecedor   AS CHAR
    FIELD estab-origem      AS CHAR
    FIELD modalidade        AS CHAR
    //FIELD ITEM              AS CHAR
    FIELD data-emissao      AS DATE
    FIELD data-validade     AS DATE
    FIELD data-termino      AS DATE
    FIELD especie           AS CHAR
    FIELD tipo-despesa      AS CHAR
    FIELD moeda             AS CHAR
    FIELD cond-pagamento    AS CHAR
    FIELD cond-faturamento  AS CHAR
    FIELD mensagem          AS CHAR
    FIELD estab-gestor      AS CHAR
    FIELD email-alerta      AS CHAR
    FIELD transportador     AS CHAR
    FIELD via-transporte    AS CHAR   
    FIELD frete             AS CHAR
    FIELD natureza          AS CHAR
    FIELD controle-contrato AS CHAR
    FIELD contato           AS CHAR
    FIELD comprador         AS CHAR
    FIELD gestor-tecnico    AS CHAR
    FIELD mes-aniversario   AS CHAR
    FIELD variacao          AS CHAR
    FIELD cod-projeto       AS CHAR
    FIELD data-revisao      AS DATE
    FIELD limite-qtde       AS DEC
    FIELD limite-valor      AS DEC
    FIELD tipo-pagamento    AS CHAR
    FIELD texto             AS CHAR
    .
    
DEF TEMP-TABLE tt-itens    NO-UNDO SERIALIZE-NAME "ITENS"
    FIELD nr-contrato      AS INT
    FIELD ITEM             AS CHAR
    FIELD valor            AS DEC
    FIELD conta            AS CHAR
    FIELD percentual       AS DEC.
    
DEF TEMP-TABLE tt-parcelas NO-UNDO   SERIALIZE-NAME "PARCELAS"
    FIELD nr-contrato       AS INT
    FIELD qtd-parcela       AS INT
    FIELD valor             AS DEC.
    
DEF TEMP-TABLE tt-fornecedores  NO-UNDO SERIALIZE-NAME "FORNECEDORES"
    FIELD nr-contrato       AS INT
    FIELD cnpj              AS CHAR
    FIELD nome              AS CHAR
    FIELD porcentagem       AS DEC.
    
    
    
DEF TEMP-TABLE tt-contrato-rest NO-UNDO
    FIELD nr-contrato   AS CHAR
    FIELD data-emissao  AS DATE
    FIELD comprador     AS CHAR.


    
    
DEFINE VARIABLE c-retorno-contrato AS CHARACTER NO-UNDO.
def var l-erro                     as logical   no-undo.
DEFINE VARIABLE l-ordem            AS LOGICAL   NO-UNDO.
DEFINE VARIABLE de-qtd-total       AS DECIMAL   NO-UNDO.
DEFINE VARIABLE Numero_Parcelas    AS INTEGER   NO-UNDO.
DEFINE VARIABLE i-parcelas         AS INTEGER   NO-UNDO.
DEFINE VARIABLE dt-vencimento      AS DATE      NO-UNDO.   /* Data de vencimento de cada parcela */
DEFINE VARIABLE dt-periodo-aux     AS DATE      NO-UNDO.
DEFINE VARIABLE valor-parcela      AS DECIMAL   NO-UNDO.
DEFINE VARIABLE i-seq-aux          AS INTEGER   NO-UNDO.
DEFINE VARIABLE i-parcela          AS INTEGER   NO-UNDO.
DEFINE VARIABLE l-gera-pendencia   AS LOGICAL   NO-UNDO.
DEFINE VARIABLE l-lib-medicao      AS LOGICAL   NO-UNDO.
DEFINE VARIABLE i-empresa          LIKE ems2mult.empresa.ep-codigo NO-UNDO.
DEFINE NEW SHARED VARIABLE c-cod-estabel LIKE estabelec.cod-estabel.
DEF NEW GLOBAL SHARED VAR c-seg-usuario  AS CHAR NO-UNDO.
def new global shared var r-num-ped      as rowid no-undo.

DEFINE DATASET dsContrato FOR tt-contrato, tt-itens, tt-parcelas, tt-fornecedores
    DATA-RELATION r1 FOR tt-contrato, tt-itens 
        RELATION-FIELDS(nr-contrato,nr-contrato) NESTED       
    DATA-RELATION r2 FOR tt-contrato, tt-parcelas
        RELATION-FIELDS(nr-contrato,nr-contrato) NESTED        
    DATA-RELATION r3 FOR tt-contrato, tt-fornecedores
        RELATION-FIELDS(nr-contrato,nr-contrato) NESTED.

FUNCTION LongCharToJsonObject RETURN JsonObject PRIVATE (INPUT jsonChar AS LONGCHAR):
    
    DEFINE VARIABLE jsonOutput AS JsonObject        NO-UNDO.
    DEFINE VARIABLE objParse   AS ObjectModelParser NO-UNDO.

    ASSIGN jsonOutput = NEW JsonObject()
           objParse   = NEW ObjectModelParser()
           jsonOutput = CAST(objParse:Parse(jsonChar), JsonObject).

    DELETE OBJECT objParse.

    RETURN jsonOutput.

END FUNCTION.

PROCEDURE pi-gera-contrato:

    DEF INPUT  PARAM jsonInput  AS JsonObject NO-UNDO.
    DEF OUTPUT PARAM jsonOutput AS JsonObject NO-UNDO.
    //DEF INPUT  PARAMETER TABLE FOR tt-mp-titulos-baixa-ok. 
    
    DEFINE VARIABLE oResponse    AS JsonAPIResponse NO-UNDO.

    DEFINE VARIABLE oRequestParser AS JsonAPIRequestParser NO-UNDO.
    DEFINE VARIABLE lcPayload      AS LONGCHAR             NO-UNDO.
    DEFINE VARIABLE NICHELE        AS LONGCHAR             NO-UNDO.

    oRequestParser = NEW JsonAPIRequestParser(jsonInput).
     
    ASSIGN lcPayload = oRequestParser:getPayloadLongChar().

    DEF VAR jsonAux  AS JsonObject NO-UNDO.
    jsonAux = LongCharToJsonObject(lcPayload).
    
    jsonAux:WRITE(NICHELE).
    
    MESSAGE "JSON TESTE2"
            STRING(NICHELE)
        VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.

    .MESSAGE string(jsonAux:GetJsonArray("tt-contrato"):getJsonText())
        VIEW-AS ALERT-BOX INFO BUTTONS OK.
                       
    DATASET dsContrato:HANDLE:READ-JSON('JsonObject',jsonAux).
    
    jsonOutput = NEW JSONObject().
    
   
    FOR FIRST tt-contrato:    
    
        log-manager:write-message("KML - dentro for each - tt-contrato.nr-contrato - " + string(tt-contrato.nr-contrato)) no-error.
        log-manager:write-message("KML - dentro for each - tt-contrato.emissao - " + string(tt-contrato.data-emissao)) no-error.

        /* ENVIAR DADOS PARA CRIAR CONTRATO AQUI */ 
        
        RUN pi-cria-contratos (OUTPUT c-retorno-contrato) NO-ERROR.

        CREATE tt-contrato-rest NO-ERROR.
        ASSIGN tt-contrato-rest.nr-contrato   = string(tt-contrato.nr-contrato)
               tt-contrato-rest.data-emissao  = tt-contrato.data-emissao
               tt-contrato-rest.comprador     = tt-contrato.comprador NO-ERROR.

        jsonOutput:ADD("retorno","Contrato integrado").
        jsonOutput:ADD("contrato",c-retorno-contrato).

      
    END.

    IF NOT CAN-FIND(FIRST tt-contrato) THEN DO:
    
      CREATE RowErrors.
      ASSIGN RowErrors.ErrorNumber = 17001
             RowErrors.ErrorDescription = "Contrato n∆o criado"
             RowErrors.ErrorHelp = "Contrato n∆o criado"
             RowErrors.ErrorSubType = "ERROR".    
    
       oResponse = NEW JsonAPIResponse(jsonInput).
       oResponse:setHasNext(FALSE).
       oResponse:setStatus(400).
       oResponse:setRowErrors(JsonAPIUtils:convertTempTableToJsonObject(TEMP-TABLE RowErrors:HANDLE):getJsonArray("RowErrors")).
       jsonOutput = oResponse:createJsonResponse().
 
    
    END.
       

    RETURN "OK".
END PROCEDURE.


PROCEDURE pi-cria-contratos:

    DEFINE OUTPUT PARAMETER c-retorno AS CHAR             NO-UNDO.
                                                    
    DEFINE VARIABLE nr-ult-contrato AS INTEGER            NO-UNDO.
    DEFINE VARIABLE i-pedido like pedido-compr.num-pedido.
    DEFINE VARIABLE i-cont  as integer                    no-undo.
    DEFINE VARIABLE i-frete AS INTEGER                    NO-UNDO.
    DEFINE VARIABLE i-natur AS INTEGER                    NO-UNDO.
    DEFINE VARIABLE i-item  AS CHARACTER                  NO-UNDO.
    DEFINE VARIABLE i-valor AS DEC                        NO-UNDO.
    DEFINE VARIABLE i-sequencia AS INT                    NO-UNDO.
    
  

    DEF buffer b-pedido-compr for pedido-compr.

    find first param-compra no-lock no-error.

    FOR EACH tt-contrato:
    
        IF tt-contrato.frete = "PAGO" THEN
            ASSIGN i-frete = 1.
        
        ELSE IF tt-contrato.frete = "A PAGAR" THEN
            ASSIGN i-frete = 2.
       
        IF tt-contrato.natureza = "COMPRA" THEN
            ASSIGN i-natur = 1.
        
        ELSE IF tt-contrato.natureza = "SERVIÄO" THEN
            ASSIGN i-natur = 2.
        
        ELSE IF tt-contrato.natureza = "BENEFICIAMENTO" THEN
            ASSIGN i-natur = 3.
            
            
        FOR EACH tt-itens :
        
            log-manager:write-message("KML - cria contrato - itens do contrato - " + tt-itens.ITEM) no-error.
            
                
               
               
        END.       
                      
        IF tt-contrato.nr-contrato = 0 THEN
        DO:
            FIND LAST contrato-for NO-LOCK NO-ERROR.
                
            IF AVAIL contrato-for THEN
            DO:
            
                ASSIGN nr-ult-contrato = contrato-for.nr-contrato + 1.
                
            END.
            
        END.
        ELSE DO:
        
            ASSIGN nr-ult-contrato = tt-contrato.nr-contrato.
        END.
        
        log-manager:write-message("KML - cria contrato - nr-ult-contrato - " + string(nr-ult-contrato)) no-error.
        log-manager:write-message("KML - cria contrato 2 - tt-contrato.nr-contrato - " + string(tt-contrato.nr-contrato)) no-error.
    
        FIND FIRST emitente NO-LOCK
            WHERE emitente.cgc  =    tt-contrato.cnpj-fornecedor NO-ERROR.
            
        IF NOT AVAIL emitente THEN DO:
        
            ASSIGN c-retorno = "Fornecedor n∆o cadastrado"  .
            RETURN "NOK".
            
            
        END.
        
        FIND FIRST contrato-for 
            WHERE contrato-for.nr-contrato                 = nr-ult-contrato NO-ERROR.
         
        IF NOT AVAIL contrato-for THEN
        DO:
        
             CREATE contrato-for.
             ASSIGN contrato-for.nr-contrato                 =  nr-ult-contrato.
            
        END.
               
        ASSIGN contrato-for.des-contrat                 = tt-contrato.descricao
               contrato-for.cod-emitente                = emitente.cod-emitente                  
               contrato-for.dt-contrato                 = tt-contrato.data-emissao
               contrato-for.dt-ini-validade             = tt-contrato.data-validade              
               contrato-for.dt-ter-validade             = tt-contrato.data-termino               
               contrato-for.cod-comprado                = tt-contrato.comprador                  
               contrato-for.cod-cond-pag                = int(tt-contrato.cond-pagamento)             
               contrato-for.via-transp                  = int(tt-contrato.via-transporte)             
               contrato-for.cod-transp                  = 99999 //int(tt-contrato.transportador )             
               contrato-for.frete                       = i-frete                 
               contrato-for.natureza                    = i-natur              
               contrato-for.cod-mensagem                = int(tt-contrato.mensagem )                  
               contrato-for.moeda                       = IF tt-contrato.moeda = "REAL" THEN 0 ELSE 0                     
               contrato-for.cod-estabel                 = tt-contrato.estab-origem               
               contrato-for.gestor-tecnico              = tt-contrato.gestor-tecnico             
               contrato-for.contato                     = tt-contrato.contato                    
               contrato-for.cod-estab-gestor            = tt-contrato.estab-gestor               
               contrato-for.cod-cond-pag                = int(tt-contrato.cond-pagamento)             
               contrato-for.cod-projeto                 = tt-contrato.cod-projeto                
               contrato-for.cod-cond-fatur              = int(tt-contrato.cond-faturamento)           
               contrato-for.dat-revisao                 = tt-contrato.data-revisao               
               contrato-for.email-alert                 = tt-contrato.email-alerta               
               contrato-for.cod-tipo-contrat            = int(tt-contrato.modalidade)                
               contrato-for.ind-control-rec             = 2                                      
               contrato-for.variacao-qtd                = int(tt-contrato.variacao )                  
               contrato-for.dec-1                       = tt-contrato.limite-qtde                
               contrato-for.dec-2                       = tt-contrato.limite-valor
               contrato-for.narrat-contrat              = tt-contrato.texto
               //contrato-for.cod-transp                  = 99.999
               contrato-for.via-transp                  = 01
               contrato-for.impr-contrat                = YES
               contrato-for.ind-sit-contrat             = 2. 
               
        FOR FIRST es-contrato-for EXCLUSIVE-LOCK
            WHERE es-contrato-for.nr-contrato     = contrato-for.nr-contrato: END.
            IF NOT AVAIL es-contrato-for THEN DO:
                CREATE es-contrato-for.
                ASSIGN es-contrato-for.nr-contrato     = contrato-for.nr-contrato.
            END.
            
        ASSIGN es-contrato-for.cod-esp = ""
               es-contrato-for.tp-desp = ?.
        
        LOG-MANAGER:write-message("KML CRIADO CONTRATO FOR  - es-contrato0for - " + STRING(es-contrato-for.nr-contrato)) no-error.
        LOG-MANAGER:write-message("KML Antes For each - pedido-compr - " + STRING(contrato-for.nr-contrato)) no-error.
        LOG-MANAGER:write-message("KML Antes For each - EMITIDO? - " + STRING(contrato-for.ind-sit-contrat)) no-error.
               
        FIND FIRST pedido-compr EXCLUSIVE-LOCK 
            WHERE pedido-compr.nr-contrato = contrato-for.nr-contrato NO-ERROR.

        IF NOT AVAIL pedido-compr  THEN
        DO: 
        
            FIND FIRST estabelec NO-LOCK
                WHERE estabelec.cod-estabel = contrato-for.cod-estabel NO-ERROR.
            
            FIND FIRST centro-custo NO-LOCK
                WHERE centro-custo.cod-estabel = estabelec.cod-estabel NO-ERROR.
             
            FIND FIRST emitente NO-LOCK 
                WHERE emitente.cgc = estabelec.cgc NO-ERROR.

            CREATE pedido-compr.
            ASSIGN pedido-compr.cod-estabel   = estabelec.cod-estabel
                   pedido-compr.nr-contrato   = contrato-for.nr-contrato
                   pedido-compr.end-entrega   = contrato-for.cod-estabel
                   pedido-compr.end-cobranca  = contrato-for.cod-estabel
                   pedido-compr.cod-cond-pag  = contrato-for.cod-cond-pag
                   pedido-compr.cod-emit-terc = emitente.cod-emitente.
                   pedido-compr.cod-emitente  = emitente.cod-emitente.
                
            log-manager:write-message("KML Hora de Criar Pedido 1 - pedido-compr - " + STRING(pedido-compr.nr-contrato)) no-error. 

            /*------------------ Calcula proximo numero do pedido --------------------------*/

            find last b-pedido-compr no-lock no-error.
            if avail b-pedido-compr and 
                  b-pedido-compr.num-pedido <= param-compra.num-pedido-fim and
                  b-pedido-compr.num-pedido >= param-compra.num-pedido-ini then do:

                    ASSIGN i-cont = 0.
                    if b-pedido-compr.num-pedido = 0 then do:
                        assign i-cont = 1.
                        repeat:
                            find prev b-pedido-compr no-lock no-error.
                            if avail b-pedido-compr then do:
                                if b-pedido-compr.num-pedido = 0 then
                                assign i-cont = i-cont + 1.
                                else leave.
                        end.
                        else do:
                            find last b-pedido-compr 
                                where b-pedido-compr.num-pedido <= param-compra.num-pedido-fim and
                                      b-pedido-compr.num-pedido >= param-compra.num-pedido-ini 
                            no-lock no-error.                                        
                            leave.
                        end.
                    end.
            end.

            if i-cont > 0 then do:
                if available b-pedido-compr then do:
                    
                    if (b-pedido-compr.num-pedido + i-cont + 1) > param-compra.num-pedido-fim or 
                       (b-pedido-compr.num-pedido + i-cont + 1) < param-compra.num-pedido-ini then do:
                        assign i-pedido = param-compra.num-pedido-ini.
                    end.
                    else                
                    assign i-pedido = b-pedido-compr.num-pedido + i-cont + 1.  
                end.                                  
                else 
                assign i-pedido = param-compra.num-pedido-ini.
            end.
            else do:
                if available b-pedido-compr then do:   
                    if (b-pedido-compr.num-pedido + 1) > param-compra.num-pedido-fim or 
                       (b-pedido-compr.num-pedido + 1) < param-compra.num-pedido-ini then do:         
                        assign i-pedido = param-compra.num-pedido-ini.
                    end.
                    else
                    assign i-pedido = b-pedido-compr.num-pedido + 1.  
                end.                                  
                else
                assign i-pedido = param-compra.num-pedido-ini.
                end.                                                          
            end.
            else 
            assign i-pedido = param-compra.num-pedido-ini.

            /* acha proximo numero disponivel ao chegar ao ultimo parametrizado */
            if  i-pedido = param-compra.num-pedido-ini then do:            
                repeat:
                    find b-pedido-compr
                    where b-pedido-compr.num-pedido = i-pedido no-lock no-error.
                    if  avail b-pedido-compr then do: 
                        ASSIGN i-pedido = i-pedido + 1.
                        /* if  i-pedido > param-compra.num-pedido-fim then do:
                         assign pedido-compr.num-pedido.
                         /* Nao h† N£mero de Pedidos dispon°veis na faixa */
                         run utp/ut-msgs.p (input "show":U, input 15218, input "").
                                                 
                         return "adm-error".
                        end. */
                    end.
                    else leave.
                end.
            end.

            log-manager:write-message("KML Hora de Criar Pedido - pedido-compr 2 - " + STRING(pedido-compr.nr-contrato)) no-error. 

            ASSIGN pedido-compr.num-pedido = i-pedido.
            
            FIND FIRST item-contrat EXCLUSIVE-LOCK
                WHERE item-contrat.nr-contrato = contrato-for.nr-contrato NO-ERROR.
            
            log-manager:write-message("KML CRIA ITEM - item-contrat - " + "Antes IF NOT AVAIL") no-error.
            
            IF NOT AVAIL item-contrat THEN DO:
            
                find FIRST  tt-parcelas NO-ERROR.
                
                i-sequencia = 1.
                
                FOR EACH tt-itens:
                    
                
                    ASSIGN i-valor = tt-itens.valor.  
            
                    IF tt-itens.ITEM = "ALUGUEL PF" THEN
                       ASSIGN i-item = "CONT.007".
                       
                    ELSE IF tt-itens.ITEM = "ALUGUEL PJ" THEN
                       ASSIGN i-item = "CONT.0070".
                        
                    ELSE IF tt-itens.ITEM = "IPTU" THEN
                       ASSIGN i-item = "CONT.003".
                       
                    ELSE IF tt-itens.ITEM = "ENERGIA" THEN
                       ASSIGN i-item = "CONT.002".
                    
                    ELSE IF tt-itens.ITEM = "AGUA" THEN
                       ASSIGN i-item = "CONT.001".
                       
                    ELSE IF tt-itens.ITEM = "FC" THEN
                       ASSIGN i-item = "CONT.005".
                       
                    ELSE IF tt-itens.ITEM = "SEGURO" THEN
                       ASSIGN i-item = "CONT.008".
                       
                    ELSE IF tt-itens.ITEM = "TAXA DE LIXO" THEN
                       ASSIGN i-item = "CONT.006".
                       
                    ELSE IF tt-itens.ITEM = "CONDOMINIO" THEN
                       ASSIGN i-item = "CONT.004".
                       
                    CREATE item-contrat.
                    ASSIGN //contrato-for.dec-2                 = tt-contrato.limite-valor * tt-parcelas.qtd-parcela 
                           item-contrat.cod-emitente          = contrato-for.cod-emitente
                           item-contrat.nr-contrato           = contrato-for.nr-contrato
                           item-contrat.preco-unit            = contrato-for.dec-2
                           item-contrat.qtd-minima            = 1.0000
                           item-contrat.sld-val               = 1.0000
                           item-contrat.val-fatur-minimo      = 0.0000
                           item-contrat.mo-codigo             = contrato-for.moeda
                           item-contrat.log-libera            = YES
                           item-contrat.it-codigo             = i-item
                           item-contrat.cod-refer             = ""
                           item-contrat.codigo-ipi            = YES
                           item-contrat.codigo-icm            = 1          
                           item-contrat.un                    = "UN"
                           item-contrat.contato               = "" 
                           item-contrat.num-seq-item          = i-sequencia //criar variavel para calculo de num-seq-item
                           item-contrat.frequencia            = 1
                           item-contrat.qtd-total             = 1 //tt-parcelas.qtd-parcela
                           item-contrat.ind-un-contrato       = 1 //Un Mediá∆o
                           item-contrat.log-control-event     = NO
                           item-contrat.log-obrig-item        = NO
                           item-contrat.narrat-item           = tt-contrato.texto
                           item-contrat.log-ind-multa         = NO
                           item-contrat.perc-multa-dia        = 0.00
                           item-contrat.perc-multa-limite     = 0.00
                           item-contrat.cod-depos             = IF contrato-for.cod-estabel = "973" THEN  "973" ELSE "LOJ" // Criar variavel para validar o deposito que esta vindo
                           item-contrat.aliquota-icm          = 0.00
                           item-contrat.aliquota-ipi          = 0.00
                           item-contrat.aliquota-iss          = 0.00
                           item-contrat.cod-cond-pag          = contrato-for.cod-cond-pag
                           item-contrat.preco-fornec          = i-valor //* tt-parcelas.qtd-parcela //tt-contrato.limite-valor  ALTERADO 02/12/2025
                           item-contrat.taxa-financ           = YES
                           item-contrat.val-frete             = 0.000
                           item-contrat.val-taxa              = 0.000
                           item-contrat.prazo-ent             = 0
                           item-contrat.dat-cotac             = TODAY
                           item-contrat.preco-base            = 0.00
                           item-contrat.cod-comprado          = contrato-for.cod-comprado
                           item-contrat.perc-desconto         = 0
                           item-contrat.narrat-compra         = ""
                           item-contrat.pre-unit-for          = 0.000 //criar variavel
                           item-contrat.dat-base              = TODAY
                           item-contrat.sld-qtd-receb         = 0.000
                           item-contrat.sld-val-receb         = 0.000
                           item-contrat.ordem-base            = 0.000
                           item-contrat.ind-tipo-control      = 1 // Tipo de Controle 
                           item-contrat.ind-tipo-control-val  = 3 // Controle preáo/qtde
                           item-contrat.ind-caract-item       = 1 // Caracteristica item
                           item-contrat.ind-sit-item          = 2 // Emitido
                           item-contrat.nr-dias-taxa          = 0 
                           item-contrat.nr-tab                = ""
                           item-contrat.valor-descto          = 0.0000
                           item-contrat.ep-codigo             = ""
                           item-contrat.tp-despesa            = 407
                           item-contrat.data-1                = TODAY
                           item-contrat.data-2                = TODAY
                           item-contrat.frete                 = NO
                           item-contrat.char-1                = ""
                           item-contrat.char-2                = ""
                           item-contrat.dec-1                 = 0.0000
                           item-contrat.dec-2                 = 0.0000
                           item-contrat.int-1                 = 00000
                           item-contrat.int-2                 = 00000
                           item-contrat.log-1                 = NO
                           item-contrat.log-2                 = NO
                           item-contrat.check-sum             = ""
                           item-contrat.num-ord-inv           = 0.00
                           item-contrat.cdn-fabrican          = ?
                           item-contrat.des-referencia        = ""
                           item-contrat.num-ord-invest        = 0
                           item-contrat.val-total             = i-valor //* tt-parcelas.qtd-parcela //item-contrat.preco-fornec * item-contrat.qtd-total // criacar variavel para calculo.
                           item-contrat.sld-qtd               = i-valor //* tt-parcelas.qtd-parcela //item-contrat.preco-fornec * item-contrat.qtd-total
                           item-contrat.acum-rec-val          = 0.0000
                           item-contrat.acum-rec-qtd          = 0.0000
                           item-contrat.sld-qtd-liber         = 0.0000 //item-contrat.preco-fornec * item-contrat.qtd-total // era 0.0000
                           item-contrat.sld-val-liber         = 0.0000 //item-contrat.preco-fornec * item-contrat.qtd-total // era 0.0000
                           //contrato-for.dec-2                 = item-contrat.val-total //LINHA TESTE VALOR TOTAL CONTRATO
                           .
                       
                    log-manager:write-message("KML item-contrat  - " + STRING(item-contrat.sld-qtd)) NO-ERROR.
                        
                    log-manager:write-message("KML matriz-rat-contr - " + STRING(tt-itens.percentual)) NO-ERROR.

                    IF (tt-itens.ITEM = "ALUGUEL PF" OR
                        tt-itens.ITEM = "ALUGUEL PJ") THEN DO:

                         CREATE matriz-rat-contr.
                         ASSIGN matriz-rat-contr.nr-contrato    = contrato-for.nr-contrato
                                matriz-rat-contr.sc-codigo      = IF AVAIL centro-custo THEN centro-custo.cc-codigo ELSE "" 
                                matriz-rat-contr.ct-codigo      = tt-itens.conta
                                matriz-rat-contr.perc-rateio    = tt-itens.percentual.
                        
                    END.
                
                           
                    CREATE matriz-rat-item.
                    ASSIGN matriz-rat-item.nr-contrato    = contrato-for.nr-contrato
                           matriz-rat-item.sc-codigo      = IF AVAIL centro-custo THEN centro-custo.cc-codigo ELSE "" 
                           matriz-rat-item.ct-codigo      = tt-itens.conta
                           matriz-rat-item.perc-rateio    = tt-itens.percentual
                           matriz-rat-item.num-seq-item   = i-sequencia
                           matriz-rat-item.it-codigo      = i-item.



                    i-sequencia = item-contrat.num-seq-item  + 1.       
                    
                    if  item-contrat.ind-tipo-control = 1 then do:
                        if  contrato-for.ind-control-rec = 1 then do:
                            assign l-erro = no.
                            for each pedido-compr no-lock
                                where pedido-compr.nr-contrato = item-contrat.nr-contrato:
                            /* Rotina de Geracao de Ordens */
                                find first ordem-compra
                                    where ordem-compra.nr-contrato = contrato-for.nr-contrato
                                    and   ordem-compra.cod-estabel = pedido-compr.cod-estabel
                                    and   ordem-compra.it-codigo   = param-contrat.it-codigo
                                    no-lock no-error.
                                                                          
                                log-manager:write-message("KML ESTABELEC  - " + STRING(ordem-compra.cod-estabel)) no-error.

                                if  not avail ordem-compra then do:
                                    assign r-num-ped = rowid(pedido-compr).
                                    run cnp/cn0201c1.p (input rowid(tt-itens) , output l-erro).
                                    if  l-erro then
                                        leave.
                                end.
                            end.
                            if  l-erro then
                                undo, return "adm-error".       
                        end.      
                        else do:
                            IF  NOT l-ordem THEN do:
                                
                                assign l-erro = no.
                                for each pedido-compr no-lock
                                    where pedido-compr.nr-contrato = item-contrat.nr-contrato:
                                        find first ordem-compra
                                            where ordem-compra.nr-contrato  = contrato-for.nr-contrato
                                            and   ordem-compra.num-pedido   = pedido-compr.num-pedido
                                            and   ordem-compra.it-codigo    = item-contrat.it-codigo
                                            and   ordem-compra.num-seq-item = item-contrat.num-seq-item
                                            no-lock no-error.
                                        if  not avail ordem-compra then do:
                                            
                                            assign r-num-ped = rowid(pedido-compr).
                                            run cnp/cn0201c1.p (input rowid(item-contrat) , output l-erro).
                                            if l-erro then
                                            
                                                log-manager:write-message("KML ENTROU IF NOT  - " + STRING(ordem-compra.cod-estabel)) no-error.
                                                
                                                leave.
                                        end.
                                end.
                                if  l-erro then
                                    undo, return "adm-error".
                            END.
                        end.
                
                   END.
                END.         
            END.
               
        END.
        ELSE DO:
            
            FIND FIRST estabelec NO-LOCK
                WHERE estabelec.cod-estabel = contrato-for.cod-estabel NO-ERROR.
        
            FIND FIRST centro-custo NO-LOCK
                WHERE centro-custo.cod-estabel = estabelec.cod-estabel NO-ERROR.
             
            FIND FIRST emitente NO-LOCK 
            WHERE emitente.cgc = estabelec.cgc NO-ERROR.

            FIND FIRST item-contrat EXCLUSIVE-LOCK
                WHERE item-contrat.nr-contrato = contrato-for.nr-contrato NO-ERROR.
            
            log-manager:write-message("KML CRIA ITEM - item-contrat2  - " + "Antes IF NOT AVAIL") no-error.

            find FIRST  tt-parcelas NO-ERROR.
            
            i-sequencia = 1.
            
            FOR EACH tt-itens :
            
                ASSIGN i-valor = tt-itens.valor.  
        
                IF tt-itens.ITEM = "ALUGUEL PF" THEN
                   ASSIGN i-item = "CONT.007".
                   
                ELSE IF tt-itens.ITEM = "ALUGUEL PJ" THEN
                   ASSIGN i-item = "CONT.0070".
                    
                ELSE IF tt-itens.ITEM = "IPTU" THEN
                   ASSIGN i-item = "CONT.003".
                   
                ELSE IF tt-itens.ITEM = "ENERGIA" THEN
                   ASSIGN i-item = "CONT.002".
                
                ELSE IF tt-itens.ITEM = "AGUA" THEN
                   ASSIGN i-item = "CONT.001".
                   
                ELSE IF tt-itens.ITEM = "FC" THEN
                   ASSIGN i-item = "CONT.005".
                   
                ELSE IF tt-itens.ITEM = "SEGURO" THEN
                   ASSIGN i-item = "CONT.008".
                   
                ELSE IF tt-itens.ITEM = "TAXA DE LIXO" THEN
                   ASSIGN i-item = "CONT.006".
                   
                ELSE IF tt-itens.ITEM = "CONDOMINIO" THEN
                   ASSIGN i-item = "CONT.004".
                   
                
                ASSIGN //contrato-for.dec-2                 = tt-contrato.limite-valor * tt-parcelas.qtd-parcela 
                       item-contrat.cod-emitente          = contrato-for.cod-emitente
                       item-contrat.nr-contrato           = contrato-for.nr-contrato
                       item-contrat.preco-unit            = contrato-for.dec-2
                       item-contrat.qtd-minima            = 1.0000
                       item-contrat.sld-val               = 1.0000
                       item-contrat.val-fatur-minimo      = 0.0000
                       item-contrat.mo-codigo             = contrato-for.moeda
                       item-contrat.log-libera            = YES
                       item-contrat.it-codigo             = i-item
                       item-contrat.cod-refer             = ""
                       item-contrat.codigo-ipi            = YES
                       item-contrat.codigo-icm            = 1          
                       item-contrat.un                    = "UN"
                       item-contrat.contato               = "" 
                       item-contrat.num-seq-item          = i-sequencia //criar variavel para calculo de num-seq-item
                       item-contrat.frequencia            = 1
                       item-contrat.qtd-total             = 1 //tt-parcelas.qtd-parcela
                       item-contrat.ind-un-contrato       = 1 //Un Mediá∆o
                       item-contrat.log-control-event     = NO
                       item-contrat.log-obrig-item        = NO
                       item-contrat.narrat-item           = tt-contrato.texto
                       item-contrat.log-ind-multa         = NO
                       item-contrat.perc-multa-dia        = 0.00
                       item-contrat.perc-multa-limite     = 0.00
                       item-contrat.cod-depos             = IF contrato-for.cod-estabel = "973" THEN  "973" ELSE "LOJ" // Criar variavel para validar o deposito que esta vindo
                       item-contrat.aliquota-icm          = 0.00
                       item-contrat.aliquota-ipi          = 0.00
                       item-contrat.aliquota-iss          = 0.00
                       item-contrat.cod-cond-pag          = contrato-for.cod-cond-pag
                       item-contrat.preco-fornec          = i-valor //* tt-parcelas.qtd-parcela //tt-contrato.limite-valor  ALTERADO 02/12/2025
                       item-contrat.taxa-financ           = YES
                       item-contrat.val-frete             = 0.000
                       item-contrat.val-taxa              = 0.000
                       item-contrat.prazo-ent             = 0
                       item-contrat.dat-cotac             = TODAY
                       item-contrat.preco-base            = 0.00
                       item-contrat.cod-comprado          = contrato-for.cod-comprado
                       item-contrat.perc-desconto         = 0
                       item-contrat.narrat-compra         = ""
                       item-contrat.pre-unit-for          = 0.000 //criar variavel
                       item-contrat.dat-base              = TODAY
                       item-contrat.sld-qtd-receb         = 0.000
                       item-contrat.sld-val-receb         = 0.000
                       item-contrat.ordem-base            = 0.000
                       item-contrat.ind-tipo-control      = 1 // Tipo de Controle 
                       item-contrat.ind-tipo-control-val  = 3 // Controle preáo/qtde
                       item-contrat.ind-caract-item       = 1 // Caracteristica item
                       item-contrat.ind-sit-item          = 2 // Emitido
                       item-contrat.nr-dias-taxa          = 0 
                       item-contrat.nr-tab                = ""
                       item-contrat.valor-descto          = 0.0000
                       item-contrat.ep-codigo             = ""
                       item-contrat.tp-despesa            = 407
                       item-contrat.data-1                = TODAY
                       item-contrat.data-2                = TODAY
                       item-contrat.frete                 = NO
                       item-contrat.char-1                = ""
                       item-contrat.char-2                = ""
                       item-contrat.dec-1                 = 0.0000
                       item-contrat.dec-2                 = 0.0000
                       item-contrat.int-1                 = 00000
                       item-contrat.int-2                 = 00000
                       item-contrat.log-1                 = NO
                       item-contrat.log-2                 = NO
                       item-contrat.check-sum             = ""
                       item-contrat.num-ord-inv           = 0.00
                       item-contrat.cdn-fabrican          = ?
                       item-contrat.des-referencia        = ""
                       item-contrat.num-ord-invest        = 0
                       item-contrat.val-total             = i-valor //* tt-parcelas.qtd-parcela //item-contrat.preco-fornec * item-contrat.qtd-total // criacar variavel para calculo.
                       item-contrat.sld-qtd               = i-valor //* tt-parcelas.qtd-parcela //item-contrat.preco-fornec * item-contrat.qtd-total
                       item-contrat.acum-rec-val          = 0.0000
                       item-contrat.acum-rec-qtd          = 0.0000
                       item-contrat.sld-qtd-liber         = 0.0000 //item-contrat.preco-fornec * item-contrat.qtd-total // era 0.0000
                       item-contrat.sld-val-liber         = 0.0000 //item-contrat.preco-fornec * item-contrat.qtd-total // era 0.0000
                       //contrato-for.dec-2                 = item-contrat.val-total //LINHA TESTE VALOR TOTAL CONTRATO
                       .
                   
                    log-manager:write-message("KML item-contrat  - " + STRING(item-contrat.sld-qtd)) NO-ERROR.
                    
                    log-manager:write-message("KML matriz-rat-contr - " + STRING(tt-itens.percentual)) NO-ERROR.

                    IF (tt-itens.ITEM = "ALUGUEL PF" OR
                        tt-itens.ITEM = "ALUGUEL PJ") THEN DO:
                        
                        
                        FIND FIRST matriz-rat-contr
                            WHERE matriz-rat-contr.nr-contrato = contrato-for.nr-contrato NO-ERROR.
                            
                        IF AVAIL matriz-rat-contr  THEN
                        DO:
                            ASSIGN matriz-rat-contr.nr-contrato    = contrato-for.nr-contrato
                                   matriz-rat-contr.sc-codigo      = IF AVAIL centro-custo THEN centro-custo.cc-codigo ELSE "" 
                                   matriz-rat-contr.ct-codigo      = tt-itens.conta
                                   matriz-rat-contr.perc-rateio    = tt-itens.percentual.
                            
                        END.

                         
                        
                    END.
                    
                    FIND FIRST matriz-rat-item
                            WHERE matriz-rat-item.nr-contrato = contrato-for.nr-contrato NO-ERROR.
                            
                        IF AVAIL matriz-rat-item  THEN
                        DO:
                        
                            ASSIGN matriz-rat-item.nr-contrato    = contrato-for.nr-contrato
                                   matriz-rat-item.sc-codigo      = IF AVAIL centro-custo THEN centro-custo.cc-codigo ELSE "" 
                                   matriz-rat-item.ct-codigo      = tt-itens.conta
                                   matriz-rat-item.perc-rateio    = tt-itens.percentual
                                   matriz-rat-item.num-seq-item   = i-sequencia
                                   matriz-rat-item.it-codigo      = i-item.

                           
                
                        END.
                        
                        i-sequencia = item-contrat.num-seq-item  + 1.
                    END.                                                       
        END.
        
        i-valor = 0.
        i-item  = "".
        
        
        
        /*
        FIND FIRST item-contrat NO-LOCK
             WHERE item-contrat.nr-contrato = nr-ult-contrato NO-ERROR.
             
        FIND FIRST pedido-compr NO-LOCK
             WHERE pedido-compr.nr-contrato = item-contrat.nr-contrato NO-ERROR.
                
        ASSIGN de-qtd-total = item-contrat.val-total.
               
        ASSIGN Numero_Parcelas = item-contrat.qtd-total
               valor-parcela = de-qtd-total / Numero_Parcelas.
               
        ASSIGN dt-periodo-aux = contrato-for.dt-contrato.
        
        ASSIGN l-gera-pendencia = YES.
        
        
        log-manager:write-message("KML MEDICAO  - " + STRING(dt-periodo-aux)) no-error.
        log-manager:write-message("KML MEDICAO1  - " + STRING(pedido-compr.cod-estabel)) no-error.

       
        FOR EACH ordem-compra NO-LOCK
            WHERE ordem-compra.nr-contrato = item-contrat.nr-contrato
            AND   ordem-compra.cod-estabel = pedido-compr.cod-estabel
            AND   ordem-compra.it-codigo   = item-contrat.it-codigo:
            
                ASSIGN c-cod-estabel = ordem-compra.cod-estabel
                       i-empresa = "".
                
                //inserir aqui o DO
                
                DO i-parcela = 1 TO Numero_Parcelas:

                    IF MONTH(dt-periodo-aux) = 12 THEN

                        ASSIGN dt-periodo-aux = DATE(1, 1, YEAR(dt-periodo-aux) + 1).
                    ELSE
                        ASSIGN dt-periodo-aux = DATE(MONTH(dt-periodo-aux) + 1, 1, YEAR(dt-periodo-aux)).

                    ASSIGN i-seq-aux = i-seq-aux + 1.
                    
                    RUN pi-verifica-dia     (INPUT  dt-periodo-aux,
                                             INPUT  ordem-compra.cod-estabel,
                                             OUTPUT dt-periodo-aux).

                    FIND FIRST medicao-contrat NO-LOCK
                         WHERE medicao-contrat.nr-contrato = ordem-compra.nr-contrato
                         AND   medicao-contrat.numero-ordem = ordem-compra.numero-ordem 
                         AND   medicao-contrat.num-seq-medicao = i-parcela NO-ERROR.
                        
                    IF NOT AVAIL medicao-contrat THEN
                    DO:

                        ASSIGN dt-vencimento = ADD-INTERVAL(dt-periodo-aux, i-parcela - 1, "MONTH").
                                  
                        CREATE medicao-contrat.
                        ASSIGN medicao-contrat.num-seq-medicao = i-parcela //IF AVAIL medicao-contrat THEN medicao-contrat.num-seq-medicao + 1 else 1
                               medicao-contrat.nr-contrato = ordem-compra.nr-contrato
                               //medicao-contrat.cod-estabel = ordem-compra.cod-estabel
                               medicao-contrat.numero-ordem = ordem-compra.numero-ordem
                               medicao-contrat.num-seq-event = 0
                               medicao-contrat.num-seq-item  = ordem-compra.num-seq-item
                               //medicao-contrat.it-codigo     = ordem-compra.It-codigo
                               medicao-contrat.qtd-medicao    = 1
                               medicao-contrat.un            = "UN"
                               medicao-contrat.val-previsto   = ordem-compra.preco-fornec
                               medicao-contrat.val-medicao    = ordem-compra.preco-fornec
                               medicao-contrat.sld-val-medicao = ordem-compra.preco-fornec
                               medicao-contrat.dat-prev-medicao = dt-periodo-aux
                               //medicao-contrat.hra-medicao      = "16:17:00"
                               //medicao-contrat.dt-valid         = 09/30/2024
                               medicao-contrat.ep-codigo        = ordem-compra.ep-codigo
                               medicao-contrat.responsavel      = item-contrat.cod-comprado
                               medicao-contrat.ind-sit-medicao  = 1
                               medicao-contrat.qtd-prevista      = ?
                               medicao-contrat.perc-medicao      =  medicao-contrat.val-previsto * 100 / de-qtd-total
                               medicao-contrat.perc-lib-previsto =  medicao-contrat.val-previsto * 100 / de-qtd-total.    
                               
                         IF l-gera-pendencia THEN DO: 
                            RUN cdp/cdapi171.p (12, 2, ROWID(medicao-contrat)).

                             IF RETURN-VALUE = 'ADM-ERROR':U THEN
                                ASSIGN l-lib-medicao = NO.
                                
                         END.
                         
                         FOR FIRST es-medicao-contrat EXCLUSIVE-LOCK
                             WHERE es-medicao-contrat.nr-contrato     = medicao-contrat.nr-contrato  
                             AND   es-medicao-contrat.num-seq-item    = medicao-contrat.num-seq-item
                             AND   es-medicao-contrat.numero-ordem    = medicao-contrat.numero-ordem
                             AND   es-medicao-contrat.num-seq-event   = medicao-contrat.num-seq-event 
                             AND   es-medicao-contrat.num-seq-medicao = medicao-contrat.num-seq-medicao: 
                         END.   
                            IF NOT AVAIL es-medicao-contrat THEN DO:
                                CREATE es-medicao-contrat.
                                ASSIGN es-medicao-contrat.nr-contrato     = medicao-contrat.nr-contrato  
                                       es-medicao-contrat.num-seq-item    = medicao-contrat.num-seq-item
                                       es-medicao-contrat.numero-ordem    = medicao-contrat.numero-ordem
                                       es-medicao-contrat.num-seq-event   = medicao-contrat.num-seq-event 
                                       es-medicao-contrat.num-seq-medicao = medicao-contrat.num-seq-medicao
                                       es-medicao-contrat.dt-valid        = dt-periodo-aux.
                                       
                                       log-manager:write-message("KML es-medicao-contrat  - " + STRING(es-medicao-contrat.nr-contrato)) no-error.
                                       log-manager:write-message("KML es-medicao-contrat  - " + STRING(es-medicao-contrat.dt-valid)) no-error.
                            END.
                            
                          //RUN intupc/upc-cn0302a.p (INPUT ROWID(medicao-contrat)).  
                    END.            
                END.
         END.
        */

        
        log-manager:write-message("KML MEDICAO  - " + STRING(ordem-compra.nr-contrato)) no-error.
        
        log-manager:write-message("KML FIM  - " + STRING(pedido-compr.nr-contrato)) no-error.

        ASSIGN c-retorno = string(contrato-for.nr-contrato).

        RELEASE contrato-for.
        RELEASE item-contrat.
        RELEASE pedido-compr.
        //RELEASE medicao-contrat.
        //RELEASE es-contrato-for.
        //RELEASE es-medicao-contrat.
        RELEASE matriz-rat-contr.
        RELEASE matriz-rat-item.
     
        RETURN "OK".

        //END.
                                
    END.

END PROCEDURE.

procedure pi-verifica-dia:
 
    def input  param p-data          as date no-undo.
    def input  param p-cod-estabel   as char no-undo.
    def output param p-data-nova     as date no-undo.
 
    find first calen-coml
         where calen-coml.ep-codigo   = "1"
         AND   calen-coml.cod-estabel = p-cod-estabel
         and   calen-coml.data        = p-data
         no-lock no-error.
    if  avail calen-coml then do:
 
        if  calen-coml.tipo-dia = 1 then
            assign p-data-nova = p-data.
        else do:
            assign p-data = p-data + 1.
 
            run pi-verifica-dia (input p-data,
                                 input p-cod-estabel,
                                 output p-data-nova).
        end.
    end.
    else
        assign p-data-nova = p-data.
 
end procedure.




