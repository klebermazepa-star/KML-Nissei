USING Progress.Json.ObjectModel.*.

{utp/ut-api.i}
{utp/ut-api-action.i pi-get-grupo-estoq     GET   /grEstoq/~* }
{utp/ut-api-action.i pi-get-fam-comerc      GET   /famComerc/~* }
{utp/ut-api-action.i pi-get-fam-material    GET   /famMat/~* }
{utp/ut-api-action.i pi-get-caracteristicas GET   /caratceristicas/~* }
{utp/ut-api-action.i pi-get-cest            GET   /cest/~* }
{utp/ut-api-action.i pi-get-ncm             GET   /ncm/~* }
{utp/ut-api-action.i pi-post-item-fornec    POST  /ItemFornec/~* }
{utp/ut-api-action.i pi-get-item            GET   /~* }
{utp/ut-api-action.i pi-post-item           POST  /~* }
{utp/ut-api-notfound.i}



{cdp/cdapi1001.i}
DEF VAR h-cdapi1001             AS WIDGET-HANDLE NO-UNDO.

{method/dbotterr.i} /*RowErrors*/

DEF TEMP-TABLE tt-ncm NO-UNDO SERIALIZE-NAME "ncm"
    FIELD ncm           LIKE classif-fisc.class-fiscal
    FIELD descricao     LIKE classif-fisc.descricao
    INDEX id IS PRIMARY ncm.

DEF TEMP-TABLE item_cest  NO-UNDO SERIALIZE-NAME "cest"
    FIELD it-codigo LIKE item.it-codigo
    FIELD cest      AS CHAR
    INDEX id IS PRIMARY it-codigo.


DEF TEMP-TABLE grupo_estoque NO-UNDO
    FIELD ge-codigo LIKE grup-estoque.ge-codigo
    FIELD descricao LIKE grup-estoque.descricao
    INDEX id IS PRIMARY ge-codigo.

DEF TEMP-TABLE familia_material NO-UNDO
    FIELD fm-codigo LIKE familia.fm-codigo
    FIELD descricao LIKE familia.descricao
    FIELD un        LIKE familia.un       
    INDEX id IS PRIMARY fm-codigo.

DEF TEMP-TABLE familia_comercial NO-UNDO
    FIELD fm-cod-com LIKE ems2dis.fam-comerc.fm-cod-com
    FIELD descricao  LIKE ems2dis.fam-comerc.descricao 
    FIELD un         LIKE ems2dis.fam-comerc.un        
    INDEX id IS PRIMARY fm-cod-com.

DEF TEMP-TABLE caracteristicas NO-UNDO
    FIELD cd-folha       LIKE comp-folh.cd-folha      
    FIELD cd-comp        LIKE comp-folh.cd-comp       
    FIELD descricao      LIKE comp-folh.descricao     
    FIELD tipo-result    LIKE comp-folh.tipo-result   
    FIELD vl-minimo      LIKE comp-folh.vl-minimo     
    FIELD vl-maximo      LIKE comp-folh.vl-maximo     
    FIELD nr-tabela      LIKE comp-folh.nr-tabela     
    FIELD nr-max-esc     LIKE comp-folh.nr-max-esc    
    FIELD inf-compl      LIKE comp-folh.inf-compl     
    FIELD un-medida      LIKE comp-folh.un-medida     
    FIELD seq-de-impres  LIKE comp-folh.seq-de-impres 
    FIELD abreviatura    LIKE comp-folh.abreviatura   
    FIELD ajuda          LIKE comp-folh.ajuda         
    FIELD dt-maxima      LIKE comp-folh.dt-maxima     
    FIELD dt-minima      LIKE comp-folh.dt-minima     
    FIELD formato        LIKE comp-folh.formato       
    FIELD nr-casa-dec    LIKE comp-folh.nr-casa-dec   
    FIELD forma-verif    LIKE comp-folh.forma-verif   
    FIELD nr-min-igual   LIKE comp-folh.nr-min-igual  
    FIELD cod-exame      LIKE comp-folh.cod-exame     
    FIELD cod-comp       LIKE comp-folh.cod-comp      
    FIELD gera-narrativa LIKE comp-folh.gera-narrativa
    FIELD gera-texto     LIKE comp-folh.gera-texto    
    INDEX id IS PRIMARY cd-folha cd-comp.

DEF TEMP-TABLE tt-item NO-UNDO SERIALIZE-NAME "items"
    FIELD it-codigo    LIKE ITEM.it-codigo
    FIELD desc-item    LIKE item.desc-item 
    FIELD ge-codigo    LIKE item.ge-codigo 
    FIELD fm-codigo    LIKE item.fm-codigo 
    FIELD fm-cod-com   LIKE item.fm-cod-com 
    FIELD class-fiscal LIKE ITEM.class-fiscal
    FIELD un           LIKE item.un
    FIELD cod-estabel  LIKE item.cod-estabel
    FIELD cod-obsoleto LIKE item.cod-obsoleto
    FIELD data-implant LIKE item.data-implant
    FIELD data-liberac LIKE item.data-liberac
    FIELD cd-folh-item LIKE item.cd-folh-item
    FIELD lote-economi LIKE item.lote-economi
    FIELD codigo-refer LIKE item.codigo-refer
    FIELD inform-compl LIKE item.inform-compl
    FIELD cod-imagem   LIKE item.cod-imagem  
    FIELD narrativa    LIKE item.narrativa   
    FIELD cod-ean      AS CHAR
    FIELD preco-base        AS DEC
    FIELD preco-ult-entrada AS DEC
    INDEX id IS PRIMARY it-codigo.
    
DEF TEMP-TABLE tt-item-fornec NO-UNDO 
    FIELD cod-fornec    AS INT
    FIELD it-codigo         AS CHAR
    FIELD item-fornecedor   AS CHAR
    FIELD cnpj-fornecedor   AS CHAR
    FIELD un-medida         AS CHAR
    FIELD cond-pagto        AS CHAR
    FIELD fator-conversao   AS CHAR
    FIELD casas-decimais    AS CHAR.   
    
    
    
DEF TEMP-TABLE tt-it-carac-tec NO-UNDO SERIALIZE-NAME "caracteristicas"
    FIELD it-codigo   LIKE it-carac-tec.it-codigo SERIALIZE-HIDDEN
    FIELD nr-tabela   LIKE it-carac-tec.nr-tabela 
    FIELD cd-comp     LIKE it-carac-tec.cd-comp 
    FIELD cd-folha    LIKE it-carac-tec.cd-folha 
    FIELD cod-comp    LIKE it-carac-tec.cod-comp 
    FIELD cod-exame   LIKE it-carac-tec.cod-exame 
    FIELD dt-result   LIKE it-carac-tec.dt-result 
    FIELD vl-result   LIKE it-carac-tec.vl-result
    FIELD tipo-result LIKE it-carac-tec.tipo-result 
    FIELD observacao  LIKE it-carac-tec.observacao 
    FIELD complemento LIKE it-carac-tec.complemento 
    INDEX id IS PRIMARY it-codigo.

DEF TEMP-TABLE tt-item-uni-estab NO-UNDO SERIALIZE-NAME "estabelecimentos"
    FIELD it-codigo   LIKE item-uni-estab.it-codigo SERIALIZE-HIDDEN
    FIELD cod-estabel LIKE item-uni-estab.cod-estabel
    INDEX id IS PRIMARY it-codigo cod-estabel.

DEFINE DATASET dsCest FOR item_cest.

DEFINE DATASET dsItem FOR tt-item, tt-it-carac-tec, tt-item-uni-estab
    DATA-RELATION r1 FOR tt-item, tt-it-carac-tec
        RELATION-FIELDS(it-codigo,it-codigo) NESTED
    DATA-RELATION r2 FOR tt-item, tt-item-uni-estab
        RELATION-FIELDS(it-codigo,it-codigo) NESTED.
    

FUNCTION LongCharToJsonObject RETURN JsonObject PRIVATE (INPUT jsonChar AS LONGCHAR):
    
    DEFINE VARIABLE jsonOutput AS JsonObject        NO-UNDO.
    DEFINE VARIABLE objParse   AS ObjectModelParser NO-UNDO.

    ASSIGN jsonOutput = NEW JsonObject()
           objParse   = NEW ObjectModelParser()
           jsonOutput = CAST(objParse:Parse(jsonChar), JsonObject).

    DELETE OBJECT objParse.

    RETURN jsonOutput.

END FUNCTION.

PROCEDURE pi-get-cest:
    DEF INPUT  PARAM jsonInput  AS JsonObject NO-UNDO.
    DEF OUTPUT PARAM jsonOutput AS JsonObject NO-UNDO.
    //DEF INPUT  PARAMETER TABLE FOR tt-mp-titulos-baixa-ok. 

    DEFINE VARIABLE oRequestParser AS JsonAPIRequestParser NO-UNDO.
    DEFINE VARIABLE lcPayload      AS LONGCHAR             NO-UNDO.

    DEFINE VARIABLE memptr-aux AS MEMPTR      NO-UNDO.
    DEFINE VARIABLE lc-aux     AS LONGCHAR    NO-UNDO.
    DEFINE VARIABLE l-ok       AS LOGICAL     NO-UNDO.

    oRequestParser = NEW JsonAPIRequestParser(jsonInput).
     
    ASSIGN lcPayload = oRequestParser:getPayloadLongChar().

    DEF VAR jsonAux  AS JsonObject NO-UNDO.
    jsonAux = LongCharToJsonObject(lcPayload).

    TEMP-TABLE item_cest:HANDLE:READ-JSON('JsonArray',jsonAux:GetJsonArray("Cest")).
    
    jsonOutput = NEW JSONObject().
    ASSIGN l-ok = NO.

    IF NOT VALID-HANDLE(h-cdapi1001) THEN
        RUN cdp/cdapi1001.p     PERSISTENT SET h-cdapi1001.

    FOR EACH ITEM_cest:

        FIND FIRST ITEM NO-LOCK
            WHERE ITEM.it-codigo = item_cest.it-codigo NO-ERROR.

        IF AVAIL ITEM THEN DO:

            EMPTY TEMP-TABLE tt-sit-tribut.
            RUN pi-seta-tributos IN h-cdapi1001 (input "11").
            RUN pi-retorna-sit-tribut IN h-cdapi1001 (INPUT  2,
                                                    INPUT  "*",
                                                    INPUT  "*",
                                                    INPUT  ITEM.class-fiscal,
                                                    INPUT  ITEM.it-codigo,
                                                    INPUT  "*",
                                                    INPUT  "0",
                                                    INPUT  TODAY,
                                                    OUTPUT TABLE tt-sit-tribut).
            
            FOR FIRST tt-sit-tribut:
                IF string(tt-sit-tribut.cdn-sit-tribut) <> "0" THEN DO:
                    ASSIGN item_cest.cest   =  string(tt-sit-tribut.cdn-sit-tribut).
                END.
    
            END.
        END.

        
    END.

    jsonOutput = NEW JSONObject().

    ASSIGN jsonOutput = JsonAPIUtils:convertTempTableToJsonObject(TEMP-TABLE item_cest:HANDLE, NO).

    RETURN "OK".
END PROCEDURE.

PROCEDURE pi-get-grupo-estoq:
    DEF INPUT  PARAM jsonInput  AS JsonObject NO-UNDO.
    DEF OUTPUT PARAM jsonOutput AS JsonObject NO-UNDO.

    DEFINE VARIABLE oRequestParser AS JsonAPIRequestParser NO-UNDO.
    DEFINE VARIABLE lcPayload      AS LONGCHAR             NO-UNDO.

    jsonOutput = NEW JSONObject().

    FOR EACH grup-estoque NO-LOCK:

        CREATE grupo_estoque.
        ASSIGN grupo_estoque.ge-codigo = grup-estoque.ge-codigo
               grupo_estoque.descricao = grup-estoque.descricao.
    END.

    ASSIGN jsonOutput = JsonAPIUtils:convertTempTableToJsonObject(TEMP-TABLE grupo_estoque:HANDLE, NO).

    RETURN "OK".
END PROCEDURE.

PROCEDURE pi-get-ncm: //kml
    DEF INPUT  PARAM jsonInput  AS JsonObject NO-UNDO.
    DEF OUTPUT PARAM jsonOutput AS JsonObject NO-UNDO.

    DEFINE VARIABLE oRequestParser AS JsonAPIRequestParser NO-UNDO.
    DEFINE VARIABLE lcPayload      AS LONGCHAR             NO-UNDO.

    jsonOutput = NEW JSONObject().

    FOR EACH classif-fisc NO-LOCK:

        CREATE tt-ncm.
        ASSIGN tt-ncm.ncm       = classif-fisc.class-fiscal
               tt-ncm.descricao = classif-fisc.descricao.
    END.

    ASSIGN jsonOutput = JsonAPIUtils:convertTempTableToJsonObject(TEMP-TABLE tt-ncm:HANDLE, NO).

    RETURN "OK".
END PROCEDURE.

PROCEDURE pi-get-fam-comerc:
    DEF INPUT  PARAM jsonInput  AS JsonObject NO-UNDO.
    DEF OUTPUT PARAM jsonOutput AS JsonObject NO-UNDO.

    DEFINE VARIABLE oRequestParser AS JsonAPIRequestParser NO-UNDO.
    DEFINE VARIABLE lcPayload      AS LONGCHAR             NO-UNDO.

    jsonOutput = NEW JSONObject().

    FOR EACH ems2dis.fam-comerc NO-LOCK:

        CREATE familia_comercial.
        ASSIGN familia_comercial.fm-cod-com = fam-comerc.fm-cod-com
               familia_comercial.descricao  = fam-comerc.descricao 
               familia_comercial.un         = fam-comerc.un        .
    END.

    ASSIGN jsonOutput = JsonAPIUtils:convertTempTableToJsonObject(TEMP-TABLE familia_comercial:HANDLE, NO).

    RETURN "OK".
END PROCEDURE.

PROCEDURE pi-get-fam-material:
    DEF INPUT  PARAM jsonInput  AS JsonObject NO-UNDO.
    DEF OUTPUT PARAM jsonOutput AS JsonObject NO-UNDO.

    DEFINE VARIABLE oRequestParser AS JsonAPIRequestParser NO-UNDO.
    DEFINE VARIABLE lcPayload      AS LONGCHAR             NO-UNDO.

    jsonOutput = NEW JSONObject().

    FOR EACH familia NO-LOCK:

        CREATE familia_material.
        ASSIGN familia_material.fm-codigo = familia.fm-codigo
               familia_material.descricao = familia.descricao
               familia_material.un        = familia.un       .
    END.

    ASSIGN jsonOutput = JsonAPIUtils:convertTempTableToJsonObject(TEMP-TABLE familia_material:HANDLE, NO).

    RETURN "OK".
END PROCEDURE.

PROCEDURE pi-get-caracteristicas:
    DEF INPUT  PARAM jsonInput  AS JsonObject NO-UNDO.
    DEF OUTPUT PARAM jsonOutput AS JsonObject NO-UNDO.

    DEFINE VARIABLE oRequestParser AS JsonAPIRequestParser NO-UNDO.
    DEFINE VARIABLE lcPayload      AS LONGCHAR             NO-UNDO.

    jsonOutput = NEW JSONObject().

    FOR EACH comp-folh NO-LOCK
        WHERE comp-folh.log-estado = YES:
        CREATE caracteristicas.
        BUFFER-COPY comp-folh TO caracteristicas.
    END.

    ASSIGN jsonOutput = JsonAPIUtils:convertTempTableToJsonObject(TEMP-TABLE caracteristicas:HANDLE, NO).

    RETURN "OK".
END PROCEDURE.

PROCEDURE pi-post-item-fornec:


    DEF INPUT  PARAM jsonInput  AS JsonObject NO-UNDO.
    DEF OUTPUT PARAM jsonOutput AS JsonObject NO-UNDO.

    DEFINE VARIABLE oRequestParser AS JsonAPIRequestParser NO-UNDO.
    DEFINE VARIABLE lcPayload      AS LONGCHAR             NO-UNDO.

    DEFINE VARIABLE jsonArrayErros AS JsonArray NO-UNDO.
         
    oRequestParser = NEW JsonAPIRequestParser(jsonInput).
     
    ASSIGN lcPayload = oRequestParser:getPayloadLongChar().

    DEF VAR jsonAux  AS JsonObject NO-UNDO.
    jsonAux = LongCharToJsonObject(lcPayload).
    

    TEMP-TABLE tt-item-fornec:HANDLE:READ-JSON('JsonArray',jsonAux:GetJsonArray("itens")).
    
         
    jsonOutput = NEW JSONObject().      
         
    FOR EACH tt-item-fornec:
    
    
        FIND FIRST ITEM
            WHERE ITEM.it-codigo = tt-item-fornec.it-codigo NO-ERROR.
            
        IF NOT AVAIL ITEM THEN
        DO:
            jsonOutput:ADD("message", "C¢digo do item n√∆o encontrado" ). 
            RETURN "OK".  
            
        END.
        
        IF tt-item-fornec.cod-fornec = 0  THEN
        DO:
            FIND FIRST emitente NO-LOCK
                WHERE emitente.cgc = tt-item-fornec.cnpj-fornecedor NO-ERROR.
            
        END.
        ELSE DO: 
        
            FIND FIRST emitente NO-LOCK
                WHERE emitente.cod-emitente = tt-item-fornec.cod-fornec NO-ERROR.
        END.
            
        LOG-MANAGER:WRITE-MESSAGE("KML - COD EMITENTE - " + string(emitente.cod-emitente)) NO-ERROR.
            
        IF NOT AVAIL emitente THEN
        DO:
        
            jsonOutput:ADD("message", "Fornecedor n√∆o encontrado" ). 
            RETURN "OK".  
        
            
        END.
        
        FIND FIRST tab-unidade NO-LOCK
            WHERE tab-unidade.un = tt-item-fornec.un-medida NO-ERROR.
            
        IF NOT AVAIL tab-unidade THEN
        DO:
        
            jsonOutput:ADD("message", "Unidade de medida n√∆o encontrado" ). 
            RETURN "OK".  
        
            
        END.       
        
        FIND FIRST item-fornec
            WHERE item-fornec.cod-emitente  = emitente.cod-emitente
              AND item-fornec.it-codigo     = ITEM.it-codigo NO-ERROR.
              
        IF NOT AVAIL item-fornec THEN
        DO:
            CREATE item-fornec.
            ASSIGN item-fornec.cod-emitente = emitente.cod-emitente
                   item-fornec.it-codigo    = ITEM.it-codigo.
                           
        END.        

        
        ASSIGN item-fornec.item-do-forn     = tt-item-fornec.item-fornecedor
               item-fornec.unid-med-for     = tt-item-fornec.un-medida
               item-fornec.fator-conver     = dec(tt-item-fornec.fator-conversao) //(1 / dec(tt-item-fornec.fator-conversao)) * 1000000000   
               item-fornec.num-casa-dec     = INT(tt-item-fornec.casas-decimais) //9
               item-fornec.cod-cond-pag     = int(tt-item-fornec.cond-pagto).
               
    
    
        jsonOutput:ADD("message","Importaá∆o item fornec - OK !").
        
    
    
    END.
    
    FIND FIRST tt-item-fornec NO-ERROR.
    IF NOT AVAIL tt-item-fornec THEN
    DO:
        jsonOutput:ADD("message","Importaá∆o item fornec - OK !").
        
    END.
             

    RETURN "OK".    
    
END PROCEDURE.

PROCEDURE pi-post-item:
    DEF INPUT  PARAM jsonInput  AS JsonObject NO-UNDO.
    DEF OUTPUT PARAM jsonOutput AS JsonObject NO-UNDO.

    DEFINE VARIABLE oRequestParser AS JsonAPIRequestParser NO-UNDO.
    DEFINE VARIABLE lcPayload      AS LONGCHAR             NO-UNDO.

    DEFINE VARIABLE oRequest AS JsonAPIRequestParser NO-UNDO.
    DEFINE VARIABLE oParam   AS JsonObject           NO-UNDO.
    DEFINE VARIABLE oPayload AS JsonObject           NO-UNDO.

    ASSIGN oRequest = NEW JsonAPIRequestParser(jsonInput).
    ASSIGN oParam   = oRequest:getQueryParams().
    ASSIGN oPayload = oRequest:getPayload().

    DEFINE VARIABLE i-sequencia AS INTEGER     NO-UNDO.

    LOG-MANAGER:WRITE-MESSAGE("KML - Json Item - " + string(oPayload:GetJsonText()) ) NO-ERROR.

   DISABLE TRIGGERS FOR LOAD OF it-carac-tec.
   DISABLE TRIGGERS FOR LOAD OF ITEM.

    /* Par≥metros */
    IF oPayload:has("items")  THEN DO:    
        DATASET dsItem:HANDLE:READ-JSON("JsonObject",oPayload) .
    END.

    bl_item:
    FOR EACH tt-item:

        LOG-MANAGER:WRITE-MESSAGE("ITEM - " + tt-item.it-codigo) NO-ERROR.

        FIND FIRST ITEM EXCLUSIVE-LOCK    //KML Lohan retirado For first
            WHERE item.it-codigo = tt-item.it-codigo NO-ERROR.

        IF NOT AVAIL ITEM THEN
            CREATE ITEM.

       // LOG-MANAGER:WRITE-MESSAGE("KML - NCM - " + tt-item.class-fiscal) NO-ERROR.

        BUFFER-COPY tt-item  EXCEPT preco-base preco-ult-entrada  TO ITEM.

      //  LOG-MANAGER:WRITE-MESSAGE("KML - NCM LENDO ITEM- " + ITEM.class-fiscal) NO-ERROR.

        ASSIGN ITEM.class-fiscal = tt-item.class-fiscal.

       // LOG-MANAGER:WRITE-MESSAGE("KML - NCM LENDO APOS FORCAR- " + ITEM.class-fiscal) NO-ERROR.

        ASSIGN item.perm-saldo-neg      = 3
               ITEM.ind-item-fat        = YES
               ITEM.deposito-pad        = "LOJ"
               ITEM.fator-reaj-icms     = 1
               ITEM.ft-conversao        = 1
               ITEM.ft-conv-fmcoml      = 1
               ITEM.curva-abc           = YES.
               
        
        //KML - Cravar origem Al°quota em Item
        ASSIGN  substring(item.char-2,52,1) = "1"
                substring(item.char-2,53,1) = "1".

                                          
        FOR EACH tt-it-carac-tec
            WHERE tt-it-carac-tec.it-codigo = tt-item.it-codigo:
            FIND FIRST it-carac-tec EXCLUSIVE-LOCK  //KML Lohan retirado For first
                WHERE it-carac-tec.it-codigo = tt-it-carac-tec.it-codigo
                AND   it-carac-tec.cd-folha  = tt-it-carac-tec.cd-folha 
                AND   it-carac-tec.cd-comp   = tt-it-carac-tec.cd-comp NO-ERROR.
            IF NOT AVAIL it-carac-tec THEN
                CREATE it-carac-tec.
            BUFFER-COPY tt-it-carac-tec TO it-carac-tec.

            IF  it-carac-tec.tipo-result = 1 THEN DO:

                ASSIGN it-carac-tec.vl-result = dec(it-carac-tec.observacao).

            END.

            FOR EACH c-tab-res NO-LOCK
                WHERE c-tab-res.nr-tabela = it-carac-tec.nr-tabela:
            
                IF c-tab-res.descricao       = it-carac-tec.observacao  THEN DO:
            
                    ASSIGN i-sequencia = c-tab-res.sequencia.
            
                END.

            END.

            FIND FIRST it-res-carac EXCLUSIVE-LOCK
                WHERE it-res-carac.it-codigo       = it-carac-tec.it-codigo 
                  AND it-res-carac.cd-folha        = it-carac-tec.cd-folha  
                  AND it-res-carac.cd-comp         = it-carac-tec.cd-comp   
                  AND it-res-carac.nr-tabela       = it-carac-tec.nr-tabela NO-ERROR.
        
            IF NOT AVAIL it-res-carac THEN DO:
        
                CREATE it-res-carac.
                ASSIGN it-res-carac.it-codigo       = it-carac-tec.it-codigo     
                       it-res-carac.cd-folha        = it-carac-tec.cd-folha   
                       it-res-carac.cd-comp         = it-carac-tec.cd-comp    
                       it-res-carac.nr-tabela       = it-carac-tec.nr-tabela  
                       it-res-carac.tipo-result     = it-carac-tec.tipo-result
                       it-res-carac.vl-result       = it-carac-tec.vl-result  
                       it-res-carac.complemento     = it-carac-tec.complemento.
            
        
            END.
        
            ASSIGN it-res-carac.sequencia       = i-sequencia.
        
        
            RELEASE it-res-carac. 

            LOG-MANAGER:WRITE-MESSAGE("listando dados de caracteristicas") NO-ERROR.
            LOG-MANAGER:WRITE-MESSAGE(string(it-carac-tec.cd-comp)) NO-ERROR.
            LOG-MANAGER:WRITE-MESSAGE(it-carac-tec.observacao) NO-ERROR.

        END.

        FOR EACH estabelec:
            FIND FIRST item-uni-estab EXCLUSIVE-LOCK        //KML Lohan retirado For first
                WHERE item-uni-estab.it-codigo   =  tt-item.it-codigo  
                AND   item-uni-estab.cod-estabel = estabelec.cod-estabel no-error.
            IF NOT AVAIL item-uni-estab THEN DO:

                CREATE item-uni-estab.
                ASSIGN item-uni-estab.it-codigo   = tt-item.it-codigo   
                       item-uni-estab.cod-estabel = estabelec.cod-estabel
                       item-uni-estab.perm-saldo-neg = 3.

            END.

            ASSIGN item-uni-estab.preco-base   = tt-item.preco-base        
                   item-uni-estab.preco-ul-ent = tt-item.preco-ult-entrada 
                   item-uni-estab.data-base    = TODAY
                   item-uni-estab.data-ult-ent = TODAY.
        END.

        // RE0106
        IF NOT CAN-FIND(FIRST item-mat
                        WHERE item-mat.it-codigo = tt-item.it-codigo) THEN DO:
            CREATE item-mat.
            ASSIGN item-mat.it-codigo = tt-item.it-codigo.
        END.

        FIND FIRST int_ds_ean_item EXCLUSIVE-LOCK   ////KML Lohan retirado For first  
            WHERE int_ds_ean_item.codigo_ean = DEC(TT-ITEM.cod-ean) NO-ERROR.
    
        IF NOT AVAIL int_ds_ean_item THEN DO:
            CREATE int_ds_ean_item.
            ASSIGN int_ds_ean_item.it_codigo  = tt-item.it-codigo       
                   int_ds_ean_item.codigo_ean = DEC(TT-ITEM.cod-ean).
        END.
        ASSIGN int_ds_ean_item.lote_multiplo  = 1
               int_ds_ean_item.altura         = 0       
               int_ds_ean_item.largura        = 0       
               int_ds_ean_item.profundidade   = 0  
               int_ds_ean_item.peso           = 0        
               int_ds_ean_item.data_cadastro  = TODAY  
               int_ds_ean_item.principal      = YES.


        FIND FIRST item-dist EXCLUSIVE-LOCK
            WHERE item-dist.it-codigo = tt-item.it-codigo  NO-ERROR.
    
        IF NOT AVAIL item-dist THEN DO:
            CREATE item-dist.
            ASSIGN item-dist.it-codigo = tt-item.it-codigo .
        END.
        ASSIGN item-dist.log-aloc-neg = YES.

        ASSIGN ITEM.class-fiscal = tt-item.class-fiscal.

        //LOG-MANAGER:WRITE-MESSAGE("KML - NCM LENDO APOS FORCAR SEGUNDA VEZ- " + ITEM.class-fiscal) NO-ERROR.
        
        FIND FIRST esp-itens-integracao EXCLUSIVE-LOCK
             WHERE esp-itens-integracao.it-codigo = tt-item.it-codigo NO-ERROR.
             
             IF AVAIL esp-itens-integracao THEN
             DO:
             
              ASSIGN esp-itens-integracao.it-codigo = tt-item.it-codigo
                     esp-itens-integracao.dt-integracao = TODAY
                     esp-itens-integracao.hr-integracao = string(time, 'HH:MM:SS')
                     esp-itens-integracao.situacao      = 1.
                 
             END.
             
             ELSE DO:

             CREATE esp-itens-integracao.
             ASSIGN esp-itens-integracao.it-codigo = tt-item.it-codigo
                    esp-itens-integracao.dt-integracao = TODAY
                    esp-itens-integracao.hr-integracao = string(time, 'HH:MM:SS')
                    esp-itens-integracao.situacao      = 1.
         
             END.

        RELEASE ITEM.
    END.

    jsonOutput = NEW JSONObject().
    jsonOutput:ADD("message","Importaá∆o OK!").

    RETURN "OK".
END PROCEDURE.

PROCEDURE pi-get-item:
    DEF INPUT  PARAM jsonInput  AS JsonObject NO-UNDO.
    DEF OUTPUT PARAM jsonOutput AS JsonObject NO-UNDO.

    DEFINE VARIABLE oRequestParser AS JsonAPIRequestParser NO-UNDO.
    DEFINE VARIABLE lcPayload      AS LONGCHAR             NO-UNDO.

    DEF VAR oJsonArrayAux AS JsonArray NO-UNDO.

    FOR EACH ITEM NO-LOCK:

        CREATE tt-item.
        BUFFER-COPY ITEM TO tt-item.

        FOR EACH it-carac-tec NO-LOCK
            WHERE it-carac-tec.it-codigo = ITEM.it-codigo:
            CREATE tt-it-carac-tec.
            BUFFER-COPY it-carac-tec TO tt-it-carac-tec.
        END.
        
        FOR EACH item-uni-estab NO-LOCK
            WHERE item-uni-estab.it-codigo = ITEM.it-codigo:
            CREATE tt-item-uni-estab.
            BUFFER-COPY item-uni-estab TO tt-item-uni-estab.
        END.
    END.
    
    jsonOutput = NEW JSONObject().

    oJsonArrayAux = NEW JSONArray().

    oJsonArrayAux = JsonAPIUtils:convertDataSetToJsonArray(DATASET dsItem:HANDLE, FALSE).

    jsonOutput:ADD("items",oJsonArrayAux).


    RETURN "OK".
END PROCEDURE.
