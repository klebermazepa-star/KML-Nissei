//USING Progress.Json.ObjectModel.*.

USING Progress.Json.ObjectModel.JsonArray.
USING Progress.Json.ObjectModel.JsonObject.
USING Progress.Json.ObjectModel.JsonDataType.
USING Progress.Json.ObjectModel.ObjectModelParser.

{utp/ut-api.i}
{utp/ut-api-action.i pi-gera-cupom  POST  /~* }
{utp/ut-api-notfound.i}

{method/dbotterr.i} /*RowErrors*/

DEF TEMP-TABLE cupom_Fiscal NO-UNDO
    FIELD message_id        AS CHAR
    FIELD venda_id          AS CHAR
    FIELD emitente_cnpj     AS CHAR
    FIELD numero            AS int
    FIELD serie             AS CHAR
    FIELD data_emissao      AS DATE
    FIELD cliente_id        AS CHAR
    FIELD valor_total       AS DEC
    FIELD terminal_id       AS CHAR
    FIELD identificador_id  AS CHAR
    FIELD status_cupom      AS CHAR
    FIELD convenio_id       AS CHAR
    FIELD pdv_versao          AS CHAR
    FIELD transmissao_sefaz         AS CHAR
    FIELD chave_Acesso        AS CHAR
    FIELD protocolo   AS CHAR
    FIELD status_sefaz          AS CHAR
    FIELD convenio_categoria         AS CHAR
    FIELD convenio_orgao AS CHAR
    FIELD convenio_pedidoid       AS CHAR
    FIELD filial_id   AS CHAR
    FIELD caixa      AS CHAR
    FIELD movimento AS CHAR.  
    

DEF TEMP-TABLE itens NO-UNDO
    FIELD message_id        AS CHAR
    FIELD venda_id           AS CHAR
    FIELD sequencia         AS INT
    FIELD produto_id        AS CHAR
    FIELD valor_desconto       AS DEC
    FIELD preco_unitario             AS DEC
    FIELD quantidade       AS DEC
    FIELD preco_liquido      AS DEC
    FIELD base_icms       AS DEC
    FIELD cfop            AS CHAR
    FIELD lote        AS CHAR
    FIELD cstb_pis             AS CHAR
    FIELD cstb_cofins          AS DEC
    FIELD cstb_icms       AS DEC
    FIELD cstb_ipi         AS DEC
    FIELD modbc_icms          AS DEC
    FIELD modbc_st        AS DEC
    FIELD modb_ipi          AS DEC
    FIELD valor_icms          AS DEC
    FIELD percentual_icms     AS DEC
    FIELD percentual_pis        AS DEC
    FIELD percentual_cofins    AS DEC
    FIELD base_pis  AS DEC
    FIELD valor_pis          AS DEC
    FIELD base_cofins         AS DEC
    FIELD valor_cofins       AS DEC
    FIELD redutor_base_icms      AS DEC
    FIELD vl_cst_60  AS DEC
    FIELD valor_ICMS_Substituto         AS DEC
    FIELD base_icms_st_retido  AS DEC
    FIELD valor_icms_st_retido         AS DEC
    FIELD cartao_presente_id AS CHAR
    INDEX idx_itens
         message_id.
  

DEF TEMP-TABLE condicao_pagamento NO-UNDO
    FIELD message_id            AS CHAR
    FIELD venda_id              AS CHAR
    FIELD CONDICAO_PAGAMENTO    AS CHAR
    FIELD debito_credito        AS CHAR
    FIELD valor                 AS DEC
    FIELD VENCIMENTO            AS DATE
    FIELD ADM_ID                AS INT 
    FIELD NSU                   AS CHAR
    FIELD AUTORIZACAO           AS CHAR
    FIELD adm_taxa              AS DEC //KML - Ajuste 26/02/2026 - Alterado campo de INT para DEC
    FIELD PARCELA               AS INT
    FIELD ADQUIRENTE_ID         AS INT
    FIELD pbm_codigo            AS INT
    FIELD cod_bandeira          AS CHAR
    FIELD ORIGEM_PAGAMENTO      AS CHAR
    FIELD CONVENIO              AS CHAR
    INDEX idx_cond_pagto
        message_id.
    
def temp-table tt-param no-undo
    field destino               as integer
    field arquivo               as char format "x(35)"
    field usuario               as char format "x(12)"
    field data-exec             as date
    field hora-exec             as integer
    field classifica            as integer
    field desc-classifica       as char format "x(40)"
    FIELD r-int_ds_nota_loja    AS ROWID.
    
 DEF TEMP-TABLE tt-processados NO-UNDO
    FIELD r-int-ds-nota-loja    AS ROWID
    FIELD message_id            AS CHAR
    FIELD retorno               AS CHAR
    FIELD status_cupom          AS INT.
    
DEFINE VARIABLE i-status AS INTEGER   NO-UNDO.
DEFINE VARIABLE c-retorno AS CHARACTER   NO-UNDO.   
DEFINE VARIABLE r-int-ds-nota-loja AS ROWID       NO-UNDO.

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

DEF DATASET DScupom FOR cupom_fiscal, itens , condicao_pagamento
    DATA-RELATION r1 FOR cupom_fiscal, itens
        RELATION-FIELDS(message_id,message_id) NESTED
    DATA-RELATION r2 FOR cupom_fiscal, condicao_pagamento
        RELATION-FIELDS(message_id,message_id) NESTED.

 function findTag returns longchar
    (pSource as longchar, pTag as char, pStart as int64):

    LOG-MANAGER:WRITE-MESSAGE("findTag _ " + pTag) NO-ERROR.

    def var cTagIni as char no-undo.
    def var cTagFim as char no-undo.

    if length(trim(pSource)) > 0 and length(trim(pTag)) > 0 and pStart >= 1 then do:
        assign  cTagIni = '<'  + trim(pTag) + '>'
                cTagFim = '</' + trim(pTag) + '>'.

        LOG-MANAGER:WRITE-MESSAGE("findTag _ " + STRING(index(pSource,cTagIni,pStart))) NO-ERROR.
        LOG-MANAGER:WRITE-MESSAGE("findTag _ " + STRING(index(pSource,cTagFim,pStart))) NO-ERROR.
        LOG-MANAGER:WRITE-MESSAGE("findTag _ " + STRING(index(pSource,cTagFim,pStart) - ( index(pSource,cTagIni,pStart) + length(cTagIni) ))) NO-ERROR.
        IF index(pSource,cTagIni,pStart) < 0
        OR index(pSource,cTagFim,pStart) < 0 
        OR index(pSource,cTagFim,pStart) - ( index(pSource,cTagIni,pStart) + length(cTagIni) ) < 0 THEN RETURN "".

        return trim(substring(pSource,
                              index(pSource,cTagIni,pStart) + length(cTagIni), 
                              index(pSource,cTagFim,pStart) - ( index(pSource,cTagIni,pStart) + length(cTagIni) ) 
                              ) 
                    ).
    end.
    return "".
end.


function OnlyNumbers returns char
    (p-char as char):

    def var i-ind as integer no-undo.
    def var c-aux as char no-undo.
    do i-ind = 1 to length (p-char):
        if lookup (substring(p-char,i-ind,1),"1,2,3,4,5,6,7,8,9,0") > 0 then
            assign c-aux = c-aux + substring(p-char,i-ind,1).
    end.
    if c-aux <> ? then return c-aux. else return "".
end.

FUNCTION LongCharToJsonObject RETURN JsonObject PRIVATE (INPUT jsonChar AS LONGCHAR):
    
    DEFINE VARIABLE jsonOutput AS JsonObject        NO-UNDO.
    DEFINE VARIABLE objParse   AS ObjectModelParser NO-UNDO.

    ASSIGN jsonOutput = NEW JsonObject()
           objParse   = NEW ObjectModelParser()
           jsonOutput = CAST(objParse:Parse(jsonChar), JsonObject).

    DELETE OBJECT objParse.

    RETURN jsonOutput.

END FUNCTION.


FUNCTION FndeParaCondPagto RETURNS CHAR (INPUT p-cond-pagto     AS CHAR ,
                                         INPUT p-tipo-cartao    AS CHAR ,
                                         INPUT p-adquirente     AS INT  ,
                                         INPUT p-pbm            AS INT  ,
                                         INPUT p-bandeira       AS CHAR):
                                         
    MESSAGE "ANTES TUDO"
        VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
                                         
    IF p-cond-pagto = "cartao" THEN DO:     
    
        FIND FIRST esp-cond-pagto-integracao NO-LOCK
            WHERE esp-cond-pagto-integracao.forma-pagto-integracao  = p-cond-pagto
              AND esp-cond-pagto-integracao.tipo-cartao             = p-tipo-cartao 
              AND esp-cond-pagto-integracao.cod-adquirente          = p-adquirente
              AND esp-cond-pagto-integracao.cod-bandeira            = INT(p-bandeira)
              NO-ERROR.
        IF AVAIL esp-cond-pagto-integracao THEN DO:
        
             RETURN STRING(esp-cond-pagto-integracao.cond-pagto, "99").    
            
        END.
        ELSE DO:
            
            FIND FIRST esp-cond-pagto-integracao NO-LOCK
                WHERE esp-cond-pagto-integracao.forma-pagto-integracao  = p-cond-pagto
                  AND esp-cond-pagto-integracao.tipo-cartao             = p-tipo-cartao 
                  AND esp-cond-pagto-integracao.cod-adquirente          = p-adquirente
                  NO-ERROR.
            
            IF AVAIL esp-cond-pagto-integracao THEN DO:
            
                 MESSAGE "DENTRO IF AVAIL" SKIP
                         esp-cond-pagto-integracao.cond-pagto
                     VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
            
                 RETURN STRING(esp-cond-pagto-integracao.cond-pagto, "99").    
                
            END.  
        END.
    END.
    
    ELSE IF p-cond-pagto = "convenio" THEN DO:     
    
        FIND FIRST esp-cond-pagto-integracao NO-LOCK
            WHERE esp-cond-pagto-integracao.forma-pagto-integracao  = p-cond-pagto
              AND esp-cond-pagto-integracao.cod-pbm                 = p-pbm
              AND p-pbm > 0 
              NO-ERROR.
        IF AVAIL esp-cond-pagto-integracao THEN DO:
        
             RETURN STRING(esp-cond-pagto-integracao.cond-pagto, "99").    
            
        END.
        ELSE DO:
        
            FIND FIRST esp-cond-pagto-integracao NO-LOCK
                WHERE esp-cond-pagto-integracao.forma-pagto-integracao =  p-cond-pagto NO-ERROR.
                
            IF AVAIL esp-cond-pagto-integracao THEN DO:
                RETURN STRING(esp-cond-pagto-integracao.cond-pagto, "99").              
            END. 
        
        END.

    END.    
    ELSE DO:
    
        FIND FIRST esp-cond-pagto-integracao NO-LOCK
            WHERE esp-cond-pagto-integracao.forma-pagto-integracao =  p-cond-pagto NO-ERROR.
            
        IF AVAIL esp-cond-pagto-integracao THEN DO:
            RETURN STRING(esp-cond-pagto-integracao.cond-pagto, "99").              
        END. 
    END.

    RETURN "NOK".
    
END FUNCTION.


PROCEDURE pi-gera-cupom:
    DEF INPUT  PARAM jsonInput  AS JsonObject NO-UNDO.
    DEF OUTPUT PARAM jsonOutput AS JsonObject NO-UNDO.
    //DEF INPUT  PARAMETER TABLE FOR tt-mp-titulos-baixa-ok. 

    DEFINE VARIABLE oRequestParser  AS JsonAPIRequestParser NO-UNDO.
    DEFINE VARIABLE lcPayload       AS LONGCHAR             NO-UNDO.
    DEFINE VARIABLE oResponse       AS JsonAPIResponse NO-UNDO.
    DEFINE VARIABLE Ojsonretorno    AS JsonObject NO-UNDO.
    DEFINE VARIABLE Ajsonretorno    AS JsonArray NO-UNDO.

    oRequestParser = NEW JsonAPIRequestParser(jsonInput).
     
    ASSIGN lcPayload = oRequestParser:getPayloadLongChar().

    log-manager:write-message("KML - entrou procedure cupom - versao 28/03/2024 - 11:35") no-error.
        
    DEF VAR jsonAux  AS JsonObject NO-UNDO.
    jsonAux = LongCharToJsonObject(lcPayload).

    DATASET DScupom:HANDLE:READ-JSON('JsonObject',jsonAux).   

    jsonOutput = NEW JSONObject().
    
    FOR EACH condicao_pagamento:

        log-manager:write-message("KML - condicao mensage_id- " + condicao_pagamento.message_id + "condicao " + string(condicao_pagamento.PARCELA)) no-error.                                        
                      
    END.
    
    IF CAN-FIND(FIRST cupom_fiscal) THEN DO:
    
        FOR EACH itens:
            IF itens.percentual_icms = ? THEN
            DO:
                CREATE RowErrors.
                ASSIGN RowErrors.ErrorNumber = 17001
                       RowErrors.ErrorDescription = "Percentual_ICMS ‚ mandat¢rio e est  com valor NULL"
                       RowErrors.ErrorHelp = "Percentual_ICMS ‚ mandat¢rio e est  com valor NULL"
                       RowErrors.ErrorSubType = "ERROR". 
                                     
                IF CAN-FIND(FIRST RowErrors) THEN DO:
                   oResponse = NEW JsonAPIResponse(jsonInput).
                   oResponse:setHasNext(FALSE).
                   oResponse:setStatus(400).
                   oResponse:setRowErrors(JsonAPIUtils:convertTempTableToJsonObject(TEMP-TABLE RowErrors:HANDLE):getJsonArray("RowErrors")).
                   jsonOutput = oResponse:createJsonResponse().
                END. 
                
                RETURN "OK".
            
            END.
            
        END.
        
        RUN gera-int-ds-nota-loja.
        
        FOR EACH tt-processados:
        
            EMPTY TEMP-TABLE tt-param.
            CREATE tt-param.
            ASSIGN tt-param.destino         = 1
                   tt-param.arquivo         = ""
                   tt-param.usuario         = "RPW"
                   tt-param.data-exec       = date(TODAY)
                   tt-param.hora-exec       = 0
                   tt-param.classifica      = 0
                   tt-param.desc-classifica = ""
                   tt-param.r-int_ds_nota_loja = tt-processados.r-int-ds-nota-loja.   
                   
             IF AVAIL tt-param THEN DO:
             
                raw-transfer tt-param to raw-param.
                
                
                log-manager:write-message("KML - antes int020-vnda rowid - " + STRING(tt-param.r-int_ds_nota_loja)) no-error.
                
                RUN intprg/int020-vndarp.p (INPUT raw-param ,
                                            OUTPUT i-status ,
                                            OUTPUT c-retorno).    
                                            
                                            
                log-manager:write-message("KML - depois int020-vnda status - " + STRING(i-status) + "  Retorno - " + c-retorno) no-error.                                        
             
                 
             END. 
             
             IF i-status = 1 THEN DO:
             
                ASSIGN tt-processados.retorno       = c-retorno
                       tt-processados.status_cupom  = 200.
                 
             END.
             ELSE DO:
             
                ASSIGN tt-processados.retorno       = c-retorno
                       tt-processados.status_cupom  = 400.
                /*CREATE RowErrors.
                ASSIGN RowErrors.ErrorNumber = i-status
                       RowErrors.ErrorDescription = c-retorno
                       RowErrors.ErrorHelp = c-retorno
                       RowErrors.ErrorSubType = "ERROR".    */
                                     
             
             END.
             
         END.
        /* 
         FOR EACH tt-processados:
         
            log-manager:write-message("KML - retorno - " + tt-processados.message_id + "  Retorno - " + tt-processados.retorno) no-error.                                        
           
            Ojsonretorno = NEW JSONObject().
            
            Ojsonretorno:ADD("message_id", tt-processados.message_id).
            Ojsonretorno:ADD("Retorno", tt-processados.retorno).
           
         END.   */
         
         temp-table tt-processados:WRITE-JSON("jsonObject",jsonOutput).
         
         
         IF CAN-FIND(FIRST RowErrors) THEN DO:
         
               oResponse = NEW JsonAPIResponse(jsonInput).
               oResponse:setHasNext(FALSE).
               oResponse:setStatus(400).
               oResponse:setRowErrors(JsonAPIUtils:convertTempTableToJsonObject(TEMP-TABLE RowErrors:HANDLE):getJsonArray("RowErrors")).
               jsonOutput = oResponse:createJsonResponse().
         END.  
           
    END.   
        
    IF NOT CAN-FIND(FIRST cupom_fiscal) THEN DO:
               
        CREATE RowErrors.
        ASSIGN RowErrors.ErrorNumber = 17001
               RowErrors.ErrorDescription = "Erro na integra‡Æo de cupom fiscal"
               RowErrors.ErrorHelp = "Erro na integra‡Æo de cupom fiscal"
               RowErrors.ErrorSubType = "ERROR". 
                             
        IF CAN-FIND(FIRST RowErrors) THEN DO:
           oResponse = NEW JsonAPIResponse(jsonInput).
           oResponse:setHasNext(FALSE).
           oResponse:setStatus(400).
           oResponse:setRowErrors(JsonAPIUtils:convertTempTableToJsonObject(TEMP-TABLE RowErrors:HANDLE):getJsonArray("RowErrors")).
           jsonOutput = oResponse:createJsonResponse().
        END.    
    END.



    RETURN "OK".
END PROCEDURE.


PROCEDURE gera-int-ds-nota-loja:

            
    FOR EACH cupom_fiscal:
    
        FIND FIRST int_ds_nota_loja EXCLUSIVE-LOCK
            WHERE int_ds_nota_loja.cnpj_filial      = cupom_Fiscal.emitente_cnpj  
              AND int_ds_nota_loja.num_nota         = string(cupom_Fiscal.numero, "9999999")
              AND int_ds_nota_loja.serie            = cupom_Fiscal.serie  NO-ERROR.
         
        IF AVAIL int_ds_nota_loja THEN
        DO:
        
            FOR EACH int_ds_nota_loja_item EXCLUSIVE-LOCK
                WHERE int_ds_nota_loja_item.cnpj_filial      = int_ds_nota_loja.cnpj_filial  
                  AND int_ds_nota_loja_item.num_nota         = int_ds_nota_loja.num_nota
                  AND int_ds_nota_loja_item.serie            = int_ds_nota_loja.serie:

                  DELETE int_ds_nota_loja_item.
            END.
            
        
            FOR EACH int_ds_nota_loja_cartao EXCLUSIVE-LOCK
                WHERE int_ds_nota_loja_cartao.cnpj_filial      = int_ds_nota_loja.cnpj_filial  
                  AND int_ds_nota_loja_cartao.num_nota         = int_ds_nota_loja.num_nota
                  AND int_ds_nota_loja_cartao.serie            = int_ds_nota_loja.serie:

                  DELETE int_ds_nota_loja_cartao.
            END.
                        
            
        END.            
          
        IF NOT AVAIL int_ds_nota_loja THEN
        DO:
          
            CREATE int_ds_nota_loja.                 
            ASSIGN int_ds_nota_loja.cnpj_filial             = cupom_Fiscal.emitente_cnpj            
                   int_ds_nota_loja.num_nota                = string(cupom_Fiscal.numero, "9999999")
                   int_ds_nota_loja.serie                   = cupom_Fiscal.serie   .
               
              
        END. 
               
        ASSIGN int_ds_nota_loja.tipo_movto              = 1                                     
               int_ds_nota_loja.dt_geracao              = TODAY                                 
               int_ds_nota_loja.hr_geracao              = STRING(TIME)                             
               int_ds_nota_loja.situacao                = 1  
               int_ds_nota_loja.emissao                 = cupom_Fiscal.data_emissao             
               int_ds_nota_loja.total_qtde              = 0 /* validar se ‚ preciso */          
               int_ds_nota_loja.valor_total             = cupom_Fiscal.valor_total              
               int_ds_nota_loja.valor_item              = 0 /* validar se ‚ preciso */          
               int_ds_nota_loja.valor_icms              = 0 /* validar se ‚ preciso */          
               int_ds_nota_loja.base_icms               = 0 /* validar se ‚ preciso */          
               int_ds_nota_loja.condipag                = "" /* validar se ‚ preciso */          
               int_ds_nota_loja.hora_emiss              = "" /* validar se ‚ preciso */          
               int_ds_nota_loja.indterminal             = cupom_Fiscal.terminal_id              
               int_ds_nota_loja.num_identi              = cupom_Fiscal.identificador_id         
               int_ds_nota_loja.bordero                 = "" /* validar se ‚ preciso */          
               int_ds_nota_loja.tipo_clien              = "" /* validar se ‚ preciso */          
               int_ds_nota_loja.istatus                 = cupom_Fiscal.status_cupom             
               int_ds_nota_loja.convenio                = cupom_Fiscal.convenio_id              
               int_ds_nota_loja.cupom_ecf               = string(cupom_Fiscal.numero, "9999999")                    
               int_ds_nota_loja.televendas              = "" /* validar se ‚ preciso */          
               int_ds_nota_loja.data_movim              = TODAY                                 
               int_ds_nota_loja.impcont                 = "" /* validar se ‚ preciso */          
               int_ds_nota_loja.valor_dinheiro          = 0 /* validar se ‚ preciso */          
               int_ds_nota_loja.valor_cartaoc           = 0 /* validar se ‚ preciso */          
               int_ds_nota_loja.valor_cartaod           = 0 /* validar se ‚ preciso */          
               int_ds_nota_loja.valor_chq               = 0 /* validar se ‚ preciso */          
               int_ds_nota_loja.valor_chq_pre           = 0 /* validar se ‚ preciso */          
               int_ds_nota_loja.valor_vale              = 0 /* validar se ‚ preciso */          
               int_ds_nota_loja.valor_convenio          = 0 /* validar se ‚ preciso */          
               int_ds_nota_loja.valor_ticket            = 0 /* validar se ‚ preciso */          
               int_ds_nota_loja.valor_din_venda         = 0 /* validar se ‚ preciso */          
               int_ds_nota_loja.valor_din_mov           = 0 /* validar se ‚ preciso */          
               int_ds_nota_loja.valor_troco             = 0 /* validar se ‚ preciso */          
               int_ds_nota_loja.impressora              = ""                                    
               int_ds_nota_loja.reducao                 = ""                                      
               int_ds_nota_loja.horainicio              = ""                                      
               int_ds_nota_loja.hora_final              = ""                                      
               int_ds_nota_loja.hora_canc               = ""                                      
               int_ds_nota_loja.hora_ecf                = ""                                     
               int_ds_nota_loja.cnpjcpf_imp_cup         = ""                                      
               int_ds_nota_loja.nome_imp_cup            = ""                                      
               int_ds_nota_loja.end_imp_cup             = ""                                      
               int_ds_nota_loja.data_ecf                = cupom_Fiscal.data_emissao                                      
               int_ds_nota_loja.sit_doct_fiscal_icms    = ""      
               int_ds_nota_loja.doc_fiscal_icms         = ""                                     
               int_ds_nota_loja.versaopdv               = cupom_Fiscal.pdv_versao                                       
               int_ds_nota_loja.nfce_transmissao_d      = cupom_Fiscal.data_emissao                                      
               int_ds_nota_loja.nfce_chave_s            = cupom_Fiscal.chave_Acesso                                      
               int_ds_nota_loja.nfce_protocolo_s        = cupom_Fiscal.protocolo                                      
               int_ds_nota_loja.nfce_status_s           = substring(cupom_Fiscal.status_sefaz,1,1)                                     
               int_ds_nota_loja.nfce_transmissao_s      = cupom_Fiscal.transmissao_sefaz                                       
               int_ds_nota_loja.valor_desc_cupom        = 0                                      
               int_ds_nota_loja.cpf_cliente             = cupom_Fiscal.cliente_id                                      
               int_ds_nota_loja.cartao_manual           = 0                                      
               int_ds_nota_loja.ID_SEQUENCIAL           = NEXT-VALUE(SEQ-INT-DS-NOTA-LOJA)      
               int_ds_nota_loja.ENVIO_STATUS            = 8                                       
               int_ds_nota_loja.ENVIO_DATA_HORA         = NOW                                      
               int_ds_nota_loja.ENVIO_ERRO              = ""                                      
               int_ds_nota_loja.categoria               = cupom_Fiscal.convenio_categoria                                      
               int_ds_nota_loja.orgao                   = cupom_Fiscal.convenio_orgao                                      
               int_ds_nota_loja.id_pedido_convenio      = INT(cupom_Fiscal.convenio_pedidoid)                                      
               int_ds_nota_loja.venda                   = 0                                      
               int_ds_nota_loja.loja                    = INT(cupom_Fiscal.filial_id)                                      
               int_ds_nota_loja.caixa                   = 0                                      
               int_ds_nota_loja.movimento               = ?                                     
               int_ds_nota_loja.retorno_validacao       = ""                                    
               .
               
               
               ASSIGN int_ds_nota_loja.nfce_status_s    = substring(int_ds_nota_loja.nfce_status_s,1,1) .
               
               
               log-manager:write-message("KML - criou int_ds_nota_loja rowid - " + cupom_fiscal.message_id ) no-error.
               
               CREATE tt-processados.
               ASSIGN tt-processados.r-int-ds-nota-loja = ROWID(int_ds_nota_loja)
                      tt-processados.message_id         = cupom_fiscal.message_id.
               
   
    
        FOR EACH itens
            WHERE itens.message_id    = cupom_fiscal.message_id:
        
            FIND FIRST int_ds_nota_loja_item EXCLUSIVE-LOCK
                WHERE int_ds_nota_loja_item.cnpj_filial      = cupom_Fiscal.emitente_cnpj  
                  AND int_ds_nota_loja_item.num_nota         = string(cupom_Fiscal.numero, "9999999")
                  AND int_ds_nota_loja_item.serie            = cupom_Fiscal.serie  
                  AND int_ds_nota_loja_item.sequencia        = STRING(itens.sequencia) 
                  AND int_ds_nota_loja_item.produto          = itens.produto_id
                  NO-ERROR.
                  
            IF NOT AVAIL int_ds_nota_loja_item THEN
            DO:
              
                CREATE int_ds_nota_loja_item.                 
                ASSIGN int_ds_nota_loja_item.cnpj_filial        = cupom_Fiscal.emitente_cnpj            
                       int_ds_nota_loja_item.num_nota           = string(cupom_Fiscal.numero, "9999999")
                       int_ds_nota_loja_item.serie              = cupom_Fiscal.serie  
                       int_ds_nota_loja_item.sequencia          = STRING(itens.sequencia)                            
                       int_ds_nota_loja_item.produto            = itens.produto_id  .
                   
                  
            END.        
        
            ASSIGN int_ds_nota_loja_item.desconto                = itens.valor_desconto                               
                   int_ds_nota_loja_item.preco_unit              = itens.preco_unitario                               
                   int_ds_nota_loja_item.quantidade              = itens.quantidade                                   
                   int_ds_nota_loja_item.aliq_icms               = itens.percentual_icms                                                  
                   int_ds_nota_loja_item.preco_liqu              = itens.preco_liquido                               
                   int_ds_nota_loja_item.base_icms               = itens.base_icms                                    
                   int_ds_nota_loja_item.vendedor                = ""                                                 
                   int_ds_nota_loja_item.tipo_desco              = ""                                                 
                   int_ds_nota_loja_item.plantao                 = ""                                                 
                   int_ds_nota_loja_item.comissao                = 0                                                  
                   int_ds_nota_loja_item.resumos                 = ""                                                 
                   int_ds_nota_loja_item.trib_icms               = "1"                                                 
                   int_ds_nota_loja_item.cfop                    = itens.cfop                                         
                   int_ds_nota_loja_item.datafabricacao          = ?                                                  
                   int_ds_nota_loja_item.datavalidade            = ?                                                  
                   int_ds_nota_loja_item.lote                    = itens.lote                                         
                   int_ds_nota_loja_item.origem                  = ""                                                 
                   int_ds_nota_loja_item.preco_rateio            = 0                                                  
                   int_ds_nota_loja_item.preco_desc              = 0                                                  
                   int_ds_nota_loja_item.preco_desc_original     = 0                                                 
                   int_ds_nota_loja_item.valortrib               = 0                                                  
                   int_ds_nota_loja_item.valortribestadual       = 0                                                 
                   int_ds_nota_loja_item.CEST                    = ""  // Porque nao ta vindo?                         
                   int_ds_nota_loja_item.cstbpis                 = STRING(itens.cstb_pis )                            
                   int_ds_nota_loja_item.cstbcofins              = STRING(itens.cstb_cofins )                        
                   int_ds_nota_loja_item.cstbicms                = 0                                                 
                   int_ds_nota_loja_item.cstbipi                 = itens.cstb_ipi                                     
                   int_ds_nota_loja_item.modbcicms               = itens.modbc_icms                                   
                   int_ds_nota_loja_item.modbipi                 = itens.modb_ipi                                     
                   int_ds_nota_loja_item.valoricms               = itens.valor_icms 
                   int_ds_nota_loja_item.percentualpis           = itens.percentual_pis                               
                   int_ds_nota_loja_item.percentualcofins        = itens.percentual_cofins                            
                   int_ds_nota_loja_item.basepis                 = itens.base_pis
                   int_ds_nota_loja_item.valorpis                = itens.valor_pis
                   int_ds_nota_loja_item.valorcofins             = itens.valor_cofins                                 
                   int_ds_nota_loja_item.redutorbaseicms         = itens.redutor_base_icms                            
                   int_ds_nota_loja_item.vl_cst60                = itens.vl_cst_60                                    
                   int_ds_nota_loja_item.vICMSSubstituto         = itens.valor_ICMS_Substituto                        
                   int_ds_nota_loja_item.vBCSTRet                = itens.base_icms_st_retido                          
                   int_ds_nota_loja_item.vICMSSRet               = itens.valor_icms_st_retido                         
                   int_ds_nota_loja_item.transID_cartao_presente = itens.cartao_presente_id.
                                                            
        END.
    
        FOR EACH condicao_pagamento
            WHERE condicao_pagamento.message_id = cupom_fiscal.message_id:       
        
           // IF condicao_pagamento.message_id = "14194844014209087" THEN
         //   DO:
                log-manager:write-message("KML - condicao mensage_id- " + condicao_pagamento.message_id + "  cupom - " + string(cupom_Fiscal.numero) + "condicao " + string(condicao_pagamento.PARCELA)) no-error.                                        
                 
                
           // END.
                     
            FIND FIRST int_ds_nota_loja_cartao EXCLUSIVE-LOCK
                WHERE int_ds_nota_loja_cartao.cnpj_filial      = cupom_Fiscal.emitente_cnpj  
                  AND int_ds_nota_loja_cartao.num_nota         = string(cupom_Fiscal.numero, "9999999")
                  AND int_ds_nota_loja_cartao.serie            = cupom_Fiscal.serie 
                  AND int_ds_nota_loja_cartao.parcela          = condicao_pagamento.PARCELA NO-ERROR.
              
            IF NOT AVAIL int_ds_nota_loja_cartao THEN
            DO:
              
                CREATE int_ds_nota_loja_cartao.                 
                ASSIGN int_ds_nota_loja_cartao.cnpj_filial      = cupom_Fiscal.emitente_cnpj            
                       int_ds_nota_loja_cartao.num_nota         = string(cupom_Fiscal.numero, "9999999")
                       int_ds_nota_loja_cartao.serie            = cupom_Fiscal.serie   
                       int_ds_nota_loja_cartao.parcela          = condicao_pagamento.PARCELA .
                   
                  
            END.    
           
            
            ASSIGN int_ds_nota_loja_cartao.emissao          = cupom_Fiscal.data_emissao                      
                   int_ds_nota_loja_cartao.condipag         = FndeParaCondPagto(condicao_pagamento.CONDICAO_PAGAMENTO, condicao_pagamento.debito_credito, condicao_pagamento.ADQUIRENTE_ID, condicao_pagamento.pbm_codigo , condicao_pagamento.cod_bandeira)          
                   int_ds_nota_loja_cartao.vencimento       = condicao_pagamento.VENCIMENTO                  
                   int_ds_nota_loja_cartao.adm_cartao       = ""                                             
                   int_ds_nota_loja_cartao.nsu_admin        = condicao_pagamento.NSU                         
                   int_ds_nota_loja_cartao.nsu_numero       = condicao_pagamento.NSU                         
                   int_ds_nota_loja_cartao.autorizacao      = condicao_pagamento.AUTORIZACAO                 
                   int_ds_nota_loja_cartao.taxa_admin       = condicao_pagamento.adm_taxa                    
                   int_ds_nota_loja_cartao.valor            = condicao_pagamento.valor                      
                   int_ds_nota_loja_cartao.cod_adquirente   = condicao_pagamento.ADQUIRENTE_ID               
                   .
            //KML - 13/01/2026 - ITAIPU convertida para Medme       
            //IF condicao_pagamento.convenio = "00395988001298"  THEN DO:
            //    
            //    ASSIGN int_ds_nota_loja_cartao.condipag = "65".
               
            //END.       
                   

        END.
        
    END.
    


END PROCEDURE.
