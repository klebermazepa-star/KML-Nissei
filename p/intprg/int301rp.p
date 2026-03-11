USING Progress.Lang.*.
USING Progress.Json.ObjectModel.*.


USING OpenEdge.Core.*.
USING OpenEdge.Net.HTTP.RequestBuilder.
USING OpenEdge.Net.HTTP.IHttpClient.
USING OpenEdge.Net.HTTP.IHttpRequest.
USING OpenEdge.Net.HTTP.IHttpResponse.
USING OpenEdge.Net.HTTP.ClientBuilder.
USING OpenEdge.Net.HTTP.lib.ClientLibraryBuilder.
USING OpenEdge.Net.URI.
USING Progress.Json.ObjectModel.*.

USING com.totvs.framework.api.*.

USING Progress.Json.ObjectModel.JsonArray.
USING Progress.Json.ObjectModel.JsonObject.
USING Progress.Json.ObjectModel.JsonDataType.
USING Progress.Json.ObjectModel.ObjectModelParser.

DEFINE BUFFER b-nota-fiscal FOR nota-fiscal.
DEFINE BUFFER b-emitente FOR ems2mult.emitente. 

DEFINE VARIABLE c-chave-acesso      AS CHARACTER   NO-UNDO.
DEFINE VARIABLE chave_acesso_origem AS CHARACTER   NO-UNDO.
DEFINE VARIABLE docum-origem        AS CHARACTER   NO-UNDO.
DEFINE VARIABLE docum-serie-orig    AS CHARACTER   NO-UNDO.
DEFINE VARIABLE valor_custo         AS DECIMAL     NO-UNDO.
DEFINE VARIABLE c-condipag          AS CHAR        NO-UNDO.
DEFINE VARIABLE c-nsu-num           AS CHAR        NO-UNDO.
DEFINE VARIABLE c-adquirente        AS INT         NO-UNDO.
DEFINE VARIABLE c-vencimento        AS DATE        NO-UNDO.
DEFINE VARIABLE c-origem            AS CHARACTER   NO-UNDO.
DEFINE VARIABLE c-cstb              AS INT   NO-UNDO.
DEFINE VARIABLE l-sub               as logical no-undo.

{intprg/int301.i}    

DEFINE INPUT PARAMETER c-tipo       AS CHAR NO-UNDO.
DEFINE INPUT PARAMETER c-tipoNota   AS CHAR NO-UNDO.
DEFINE INPUT PARAMETER r-documento  AS ROWID NO-UNDO.


IF c-tipo = "Saida" THEN
    RUN pCarregaNotasSaida (INPUT r-documento,
                            INPUT c-tipoNota) .  
IF c-tipo = "Entrada" THEN
    RUN pCarregaNotasEntrada (INPUT r-documento,
                              INPUT c-tipoNota) .      

RUN pEnviaNotasHub.


PROCEDURE pEnviaNotasHub:

    DEFINE VARIABLE oJson     AS JsonObject    NO-UNDO.
    DEFINE VARIABLE oJsonsaida AS JsonObject    NO-UNDO.
    DEFINE VARIABLE oJsonResp AS JsonObject    NO-UNDO.
    DEFINE VARIABLE oClient   AS IHttpClient   NO-UNDO.
    DEFINE VARIABLE oURI      AS URI           NO-UNDO.
    DEFINE VARIABLE oRequest  AS IHttpRequest  NO-UNDO.
    DEFINE VARIABLE hXmlDoc   AS HANDLE        NO-UNDO.
    DEFINE VARIABLE mData     AS MEMPTR        NO-UNDO.
    DEFINE VARIABLE oDocument AS CLASS MEMPTR  NO-UNDO.
    DEFINE VARIABLE oResponse AS IHttpResponse NO-UNDO.
    DEFINE VARIABLE c-token   AS CHARACTER     NO-UNDO.
    DEFINE VARIABLE oLib      AS OpenEdge.Net.HTTP.IHttpClientLibrary NO-UNDO.
    define variable vJsonAsString as CHAR no-undo.
    DEFINE VARIABLE myParser    AS ObjectModelParser NO-UNDO.


        
    RUN pGeraToken (OUTPUT c-token). 
    
    ASSIGN oURI        = OpenEdge.Net.URI:Parse("https://datahub-api-production-97903554824.us-east1.run.app") //https://datahub-api.nisseilabs.com.br //"https://dev-datahub-api.nisseilabs.com.br"
           oURI:Path   = '/datasul/pub/notafiscal'.

    ASSIGN oLib = ClientLibraryBuilder:Build()
                                      :sslVerifyHost(FALSE)
                                      :ServerNameIndicator(oURI:host)
                                      :library.   
                                      
    ASSIGN oJson = JsonAPIUtils:convertTempTableToJsonObject(DATASET dsnotas:HANDLE, NO).
    oJson = oJson:getJsonObject("dsnotas").
    
    oJson = oJson:GetJsonArray("nota_fiscal"):GetJsonObject(1). 
    
    oJsonsaida = NEW JsonObject().
    oJsonsaida:ADD("nota_fiscal",oJson).         
    
    oJsonsaida:WriteFile("U:\KML\envioNota.json") NO-ERROR.  
    
    oRequest  = RequestBuilder:POST(oURI, oJsonsaida )
                :AddHeader("Content-Type", "application/json")
                :AddHeader("Authorization","Bearer " + c-token)
                :Request
    .                                      
    ASSIGN oResponse = ClientBuilder:Build():UsingLibrary(oLib):Client:Execute(oRequest) NO-ERROR.  
    
    oJsonResp = CAST(oResponse:Entity, JsonObject) NO-ERROR. 
    
    oJsonResp:WriteFile("U:\KML\RetornoEnvioNota.json") NO-ERROR.
    
    .MESSAGE oResponse:statuscode  SKIP
            oResponse:Entity
        VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
    

END PROCEDURE.


PROCEDURE pCarregaNotasEntrada:

    DEFINE INPUT PARAMETER r-nota-fiscal    AS ROWID no-undo.  
    DEFINE INPUT PARAMETER c-tiponota       AS CHAR NO-UNDO.
    
    DEFINE VARIABLE de-quantidade-total AS DECIMAL     NO-UNDO.
    DEFINE VARIABLE i-parcela           AS INTEGER     NO-UNDO.
    
    FOR FIRST int_ds_nota_entrada NO-LOCK
        WHERE ROWID(int_ds_nota_entrada) = r-nota-fiscal:
        
        ASSIGN de-quantidade-total = 0.
        
        FOR EACH int_ds_nota_entrada_produt OF int_ds_nota_entrada NO-LOCK:
            
            ASSIGN de-quantidade-total  = de-quantidade-total + int_ds_nota_entrada_produt.nep_quantidade_n.
            
        END.
    
        FIND FIRST emitente NO-LOCK
            WHERE emitente.cgc = int_ds_nota_entrada.nen_cnpj_origem_s NO-ERROR.
               
        FIND FIRST estabelec NO-LOCK
            WHERE estabelec.cgc = int_ds_nota_entrada.nen_cnpj_destino_s NO-ERROR.           
         
         
        ASSIGN c-chave-acesso = "".
        FIND FIRST item-doc-est NO-LOCK
            WHERE item-doc-est.cod-emitente = emitente.cod-emitente
              AND item-doc-est.serie-docto  = int_ds_nota_entrada.nen_serie_s
              AND item-doc-est.nro-docto    = string(int(int_ds_nota_entrada.nen_notafiscal_n), "9999999") NO-ERROR.
              
        IF AVAIL item-doc-est THEN DO:
                
            FIND FIRST nota-fiscal NO-LOCK
                WHERE nota-fiscal.cod-estabel   = estabelec.cod-estabel
                  AND nota-fiscal.serie         = item-doc-est.serie-comp
                  AND nota-fiscal.nr-nota-fis   = item-doc-est.nro-comp NO-ERROR.
                  
            IF AVAIL nota-fiscal THEN
                ASSIGN c-chave-acesso =  cod-chave-aces-nf-eletro.
                
            
        END.
        
        CREATE nota_fiscal.
        ASSIGN nota_fiscal.pedido_id            = int_ds_nota_entrada.ped_procfit
               nota_fiscal.chave_acesso         = int_ds_nota_entrada.nen_chaveacesso_s
               nota_fiscal.versao               = "1.0"
               nota_fiscal.especie              = "NF-e"
               nota_fiscal.modelo               = "55"
               nota_fiscal.numero               = int_ds_nota_entrada.nen_notafiscal_n
               nota_fiscal.serie                = int_ds_nota_entrada.nen_serie_s
               nota_fiscal.data_emissao         = STRING( STRING(YEAR(int_ds_nota_entrada.nen_dataemissao_d), "9999") + "-" + STRING(MONTH(int_ds_nota_entrada.nen_dataemissao_d), "99") + "-" + STRING(DAY(int_ds_nota_entrada.nen_dataemissao_d), "99"))
               nota_fiscal.tipo_nota            = c-tiponota
               nota_fiscal.situacao             = "Autorizada"
               nota_fiscal.emitente_cnpj        = emitente.cgc
               nota_fiscal.destinatario_cnpj    = estabelec.cgc
               nota_fiscal.protocolo            = "" // Nao encontrado na nota de entrada
               nota_fiscal.cfop                 = int_ds_nota_entrada.nen_cfop_n
               nota_fiscal.quantidade           = de-quantidade-total
               nota_fiscal.valor_total_produtos = int_ds_nota_entrada.nen_valortotalprodutos_n.
           
        ASSIGN nota_fiscal.transportadora_cnpj              = "" // Nao importa hoje
               nota_fiscal.transportadora_veiculo_placa     = "" // Nao importa hoje
               nota_fiscal.transportadora_veiculo_estado    = "" // Nao importa hoje
               nota_fiscal.transportadora_reboque_placa     = ""   //buscar dados da tabela transportador
               nota_fiscal.transportadora_reboque_estado    = ""   //buscar dados da tabela transportador
               nota_fiscal.observacao                       = int_ds_nota_entrada.nen_observacao_s
               nota_fiscal.nota_fiscal_origem               = 0  // O vincula est  no item da nota 
               nota_fiscal.serie_origem                     = ""  // O vincula est  no item da nota 
               nota_fiscal.chave_acesso_origem              = c-chave-acesso
               nota_fiscal.tipo_ambiente_nfe                = 1 // 1 - producao 2 - homologa‡Æo                
               .                
       
         ASSIGN nota_fiscal.valor_desconto                  = int_ds_nota_entrada.nen_desconto_n
                nota_fiscal.valor_ipi                       = int_ds_nota_entrada.nen_valoripi_n
                nota_fiscal.peso_bruto                      = 0 // Peso somente a nivel item
                nota_fiscal.peso_liquido                    = 0 // Peso somente a nivel item
                nota_fiscal.valor_frete                     = int_ds_nota_entrada.nen_frete_n
                nota_fiscal.valor_seguro                    = int_ds_nota_entrada.nen_seguro_n
                nota_fiscal.valor_embalagem                 = 0 // Peso somente a nivel item
                nota_fiscal.valor_outras_despesas           = int_ds_nota_entrada.nen_despesas_n
                nota_fiscal.modalidade_frete                = int_ds_nota_entrada.nen_modalidade_frete_n              
                .            
            
            
        FOR EACH int_ds_nota_entrada_produt OF int_ds_nota_entrada NO-LOCK:
        
            CREATE itens.
            ASSIGN itens.pedido_id              = int_ds_nota_entrada.ped_procfit
                   itens.sequencia              = int_ds_nota_entrada_produt.nep_sequencia_n              
                   itens.produto                = int_ds_nota_entrada_produt.nep_produto_n 
                   itens.ean                    = string(int_ds_nota_entrada_produt.npx_ean_n)
                   itens.quantidade             = int_ds_nota_entrada_produt.nep_quantidade_n              
                   itens.cfop                   = int_ds_nota_entrada_produt.nen_cfop_n                    
                   itens.ncm                    = string(int_ds_nota_entrada_produt.nep_ncm_n)             
                   itens.valor_bruto            = int_ds_nota_entrada_produt.nep_valorbruto_n                  
                   itens.valor_liquido          = int_ds_nota_entrada_produt.nep_valorliquido_n                
                   itens.valor_total_produto    = int_ds_nota_entrada_produt.nep_valorliquido_n                
                   itens.valor_aliquota_icms    = int_ds_nota_entrada_produt.nep_percentualicms_n              
                   itens.valor_aliquota_ipi     = int_ds_nota_entrada_produt.nep_percentualipi_n                   
                   itens.valor_aliquota_pis     = int_ds_nota_entrada_produt.nep_percentualpis_n                   
                   itens.valor_aliquota_cofins  = int_ds_nota_entrada_produt.nep_percentualcofins_n                
                   itens.valor_cstb_pis         = string(int_ds_nota_entrada_produt.nep_cstpis_n)                  
                   itens.valor_cstb_cofins      = string(int_ds_nota_entrada_produt.nep_cstcofins_n)               
                   .
                   
            ASSIGN itens.caixa                  = 0   // Buscar da onde?                 
                   itens.lote                   = int_ds_nota_entrada_produt.nep_lote_s                  
                   itens.valor_desconto         = int_ds_nota_entrada_produt.nep_valordesconto_n         
                   itens.valor_base_icms        = int_ds_nota_entrada_produt.nep_baseicms_n              
                   itens.valor_icms             = int_ds_nota_entrada_produt.nep_valoricms_n             
                   itens.valor_base_diferido    = int_ds_nota_entrada_produt.nep_basediferido_n          
                   itens.valor_base_isenta      = int_ds_nota_entrada_produt.nep_baseisenta_n            
                   itens.valor_base_ipi         = int_ds_nota_entrada_produt.nep_baseipi_n               
                   itens.valor_ipi              = int_ds_nota_entrada_produt.nep_valoripi_n              
                   itens.valor_icms_st          = int_ds_nota_entrada_produt.nep_icmsst_n                
                   itens.valor_base_st          = int_ds_nota_entrada_produt.nep_basest_n                
                   itens.valor_liquido          = int_ds_nota_entrada_produt.nep_valorliquido_n          
                   itens.valor_total_produto    = int_ds_nota_entrada_produt.nep_valorbruto_n            
                   itens.data_validade          = STRING( STRING(YEAR(int_ds_nota_entrada_produt.nep_datavalidade_d), "9999") + "-" + STRING(MONTH(int_ds_nota_entrada_produt.nep_datavalidade_d), "99") + "-" + STRING(DAY(int_ds_nota_entrada_produt.nep_datavalidade_d), "99"))          
                   itens.valor_despesa          = int_ds_nota_entrada_produt.nep_valordespesa_n          
                   itens.valor_tributos         = 0   // Datasul nÆo totaliza tributos                    
                   itens.valor_cstb_pis         = string(int_ds_nota_entrada_produt.nep_cstpis_n)                    
                   itens.valor_cstb_cofins      = string(int_ds_nota_entrada_produt.nep_cstcofins_n)      
                   itens.valor_base_pis         = int_ds_nota_entrada_produt.nep_basepis_n              
                   itens.valor_pis              = int_ds_nota_entrada_produt.nep_valorpis_n             
                   itens.valor_base_cofins      = int_ds_nota_entrada_produt.nep_valorpis_n             
                   itens.valor_cofins           = int_ds_nota_entrada_produt.nep_valorcofins_n          
                   itens.valor_redutor_base_icms = int_ds_nota_entrada_produt.nep_redutorbaseicms_n     
                   itens.sequencia_origem       = 0 // Procurar da onde pegar                           
                   itens.peso_bruto             = 0 // ver da onde pegar                                
                   itens.peso_liquido           = 0 // ver da onde pegar                                
                   itens.valor_frete            = 0 // frete fica no total da nota
                   itens.valor_seguro           = 0 // frete fica no total da nota                      
                   itens.valor_embalagem        = 0 // Nao encontrado                                   
                   itens.valor_outras_despesas  = 0  // NÆo encontrado                                   
                   itens.valor_cst_ipi          = int_ds_nota_entrada_produt.nep_cstb_ipi_n     
                   itens.valor_modbc_icms       = int_ds_nota_entrada_produt.nep_modbcicms_n            
                   itens.valor_modb_cst         = int_ds_nota_entrada_produt.nep_modbcst_n              
                   itens.valor_modb_ipi         = 0  // NÆo encontrado                                 
                   itens.valor_icms_substituto  = int_ds_nota_entrada_produt.vICMSSubs                  
                   itens.valor_base_cst_ret     = int_ds_nota_entrada_produt.de-vbcstret                
                   itens.valor_icms_ret         = int_ds_nota_entrada_produt.de-vicmsstret              
                   .
                           
            
            
        END. 
        
        
        ASSIGN i-parcela = 0.
        
        FIND FIRST int_ds_nota_entrada_dup OF int_ds_nota_entrada NO-LOCK NO-ERROR.
              
        IF NOT AVAIL int_ds_nota_entrada_dup THEN
        DO:
        
            CREATE condicao_pagamento.
            ASSIGN condicao_pagamento.pedido_id             = int_ds_nota_entrada.ped_procfit
                   condicao_pagamento.parcela               = ""
                   condicao_pagamento.condicao_pagamento    = ""
                   condicao_pagamento.valor                 = 0.   
        
            
        END.
              
              
        
        
        FOR EACH int_ds_nota_entrada_dup OF int_ds_nota_entrada NO-LOCK:     
        
            ASSIGN i-parcela = i-parcela + 1.
              
        
               
            CREATE condicao_pagamento.
            ASSIGN condicao_pagamento.pedido_id             = int_ds_nota_entrada.ped_procfit
                   condicao_pagamento.parcela               = string(i-parcela)
                   condicao_pagamento.condicao_pagamento    = "Entrada"
                   condicao_pagamento.valor                 = int_ds_nota_entrada_dup.nen_valor_duplicata_n
                   .   
               
        END.        
            
        
    END.

END PROCEDURE.

PROCEDURE pCarregaNotasSaida:

    DEFINE INPUT PARAMETER r-nota-fiscal    AS ROWID no-undo. 
    DEFINE INPUT PARAMETER c-tiponota       AS CHAR NO-UNDO.

    DEFINE VARIABLE de-quantidade-total AS DECIMAL     NO-UNDO.
    DEFINE VARIABLE c-volume            AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE c-lote              AS CHARACTER   NO-UNDO.

    FOR FIRST nota-fiscal NO-LOCK
        WHERE rowid(nota-fiscal) = r-nota-fiscal:
          
        ASSIGN de-quantidade-total = 0.
        
        FOR EACH it-nota-fisc OF nota-fiscal NO-LOCK:
            
            ASSIGN de-quantidade-total = de-quantidade-total + it-nota-fisc.qt-faturada[1].
        END.
    
        FIND FIRST emitente NO-LOCK
            WHERE emitente.nome-abrev = nota-fiscal.nome-ab-cli NO-ERROR.
            
        FIND FIRST estabelec NO-LOCK
            WHERE estabelec.cod-estabel = nota-fiscal.cod-estabel NO-ERROR.
            
        FIND FIRST natur-oper NO-LOCK
            WHERE natur-oper.nat-operacao   = nota-fiscal.nat-operacao NO-ERROR.
            
        ASSIGN c-chave-acesso = "" .
                    
        FOR FIRST it-nota-fisc OF nota-fiscal,
            FIRST b-nota-fiscal NO-LOCK
            WHERE b-nota-fiscal.cod-estabel   = estabelec.cod-estabel
              AND b-nota-fiscal.serie         = it-nota-fisc.serie-docum
              AND b-nota-fiscal.nr-nota-fis   = it-nota-fisc.nr-docum:         
            
                ASSIGN c-chave-acesso =  trim(b-nota-fiscal.cod-chave-aces-nf-eletro).

            
                 ASSIGN chave_acesso_origem =  trim(b-nota-fiscal.cod-chave-aces-nf-eletro)
                        docum-origem        = b-nota-fiscal.nr-nota-fis  
                        docum-serie-orig    = b-nota-fiscal.serie.
             

        END.
         
        FOR FIRST it-nota-fisc OF nota-fiscal,
            FIRST docum-est NO-LOCK
            WHERE docum-est.nro-docto = it-nota-fisc.nr-docum
            AND   docum-est.serie-docto = it-nota-fisc.serie-docum
            AND   docum-est.cod-emitente = emitente.cod-emitente:

            ASSIGN chave_acesso_origem = docum-est.cod-chave-aces-nf-eletro
                   docum-origem        = docum-est.nro-docto   
                   docum-serie-orig    = docum-est.serie-docto.
                    
        END.
                       
        CREATE nota_fiscal.
        ASSIGN nota_fiscal.pedido_id            = IF nota-fiscal.serie = "402" THEN 0 ELSE INT(nota-fiscal.nr-pedcli)
               nota_fiscal.chave_acesso         = nota-fiscal.cod-chave-aces-nf-eletro
               nota_fiscal.versao               = "1.0"
               nota_fiscal.especie              = "NF-e"
               nota_fiscal.modelo               = "55"
               nota_fiscal.numero               = int(nota-fiscal.nr-nota-fis)
               nota_fiscal.serie                = nota-fiscal.serie
               nota_fiscal.data_emissao         = STRING( STRING(YEAR(nota-fiscal.dt-emis-nota), "9999") + "-" + STRING(MONTH(nota-fiscal.dt-emis-nota), "99") + "-" + STRING(DAY(nota-fiscal.dt-emis-nota), "99"))
               nota_fiscal.tipo_nota            = c-tiponota
               nota_fiscal.situacao             = IF (nota-fiscal.idi-sit-nf-eletro = 3 OR nota-fiscal.serie = "402") THEN "Autorizada" ELSE "Cancelada"
               nota_fiscal.emitente_cnpj        = estabelec.cgc
               nota_fiscal.destinatario_cnpj    = emitente.cgc
               nota_fiscal.protocolo            = nota-fiscal.cod-protoc
               nota_fiscal.cfop                 = INT(natur-oper.cod-cfop)
               nota_fiscal.quantidade           = de-quantidade-total
               nota_fiscal.valor_total_produtos = nota-fiscal.vl-mercad.
           
        ASSIGN nota_fiscal.transportadora_cnpj              = ""   //buscar dados da tabela transportador
               nota_fiscal.transportadora_veiculo_placa     = ""  //buscar dados da tabela transportador
               nota_fiscal.transportadora_veiculo_estado    = ""   //buscar dados da tabela transportador
               nota_fiscal.transportadora_reboque_placa     = ""   //buscar dados da tabela transportador
               nota_fiscal.transportadora_reboque_estado    = ""   //buscar dados da tabela transportador
               nota_fiscal.observacao                       = nota-fiscal.observ-nota
               nota_fiscal.tipo_ambiente_nfe                = 1. // 1 - producao 2 - homologa‡Æo.
        
            ASSIGN nota_fiscal.nota_fiscal_origem               = int(docum-origem)    
                   nota_fiscal.serie_origem                     = docum-serie-orig
                   nota_fiscal.chave_acesso_origem              = chave_acesso_origem .   
        

       
         ASSIGN nota_fiscal.valor_desconto                  = nota-fiscal.vl-desconto  
                nota_fiscal.valor_ipi                       = nota-fiscal.vl-tot-ipi  
                nota_fiscal.peso_bruto                      = nota-fiscal.peso-bru-tot
                nota_fiscal.peso_liquido                    = nota-fiscal.peso-liq-tot
                nota_fiscal.valor_frete                     = nota-fiscal.vl-frete
                nota_fiscal.valor_seguro                    = nota-fiscal.vl-seguro
                nota_fiscal.valor_embalagem                 = nota-fiscal.vl-embalagem
                nota_fiscal.valor_outras_despesas           = nota-fiscal.val-desp-outros 
                nota_fiscal.modalidade_frete                = nota-fiscal.modalidade                 
                .
               
               
               /*
                    esses campos sÆo alimentados somente no item da nota nÆo precisa enviar no cabe‡alho
                    
                nota_fiscal.volumes_marca                   =
                nota_fiscal.volumes_quantidade              =
                nota_fiscal.valor_base_icms                 =
                nota_fiscal.valor_icms                      =
                nota_fiscal.valor_base_diferido             =
                nota_fiscal.valor_base_isenta               =
                nota_fiscal.valor_base_ipi                  =
                nota_fiscal.valor_base_st                   =
                nota_fiscal.valor_icms_st                   =
                nota_fiscal.data_cancelamento               =
                
                */
       
        FOR EACH it-nota-fisc OF nota-fiscal NO-LOCK:
            
            ASSIGN c-volume = string(int(it-nota-fisc.nr-seq-ped))
                   c-lote = "".
            
            FIND FIRST int_ds_pedido_retorno NO-LOCK
                WHERE int_ds_pedido_retorno.ped_codigo_n    = INT64(nota-fiscal.nr-pedcli) 
                  AND int_ds_pedido_retorno.ppr_produto_n   = INT(it-nota-fisc.it-codigo)  NO-ERROR.
                
            IF AVAIL int_ds_pedido_retorno THEN  DO:
                ASSIGN //c-volume = STRING(int_ds_pedido_retorno.rpp_caixa_n)
                       c-lote    = int_ds_pedido_retorno.rpp_lote_s.
            END.
            
            valor_custo = 0.
            c-cstb      = 0.
            
            RUN pi-custo-grade (OUTPUT valor_custo).
            
            run ftp/ft0515a.p (input  rowid(it-nota-fisc),
                               output c-cstb,
                               output l-sub).
            
            FIND FIRST ITEM NO-LOCK
                WHERE ITEM.it-codigo = it-nota-fisc.it-codigo NO-ERROR.
            
            FIND FIRST int_ds_ean_item NO-LOCK
                WHERE int_ds_ean_item.it_codigo = ITEM.it-codigo NO-ERROR.
                
                            
                    
                   
            CREATE itens.
            ASSIGN itens.pedido_id              = IF nota-fiscal.serie = "402" THEN 0 ELSE INT(nota-fiscal.nr-pedcli)
                   itens.sequencia              = INT(it-nota-fisc.nr-seq-fat) / 10
                   itens.produto                = INT(it-nota-fisc.it-codigo)
                   itens.ean                    = IF AVAIL int_ds_ean_item THEN string(int_ds_ean_item.codigo_ean) ELSE ""
                   itens.quantidade             = it-nota-fisc.qt-faturada[1]
                   itens.cfop                   = INT(SUBSTRING(it-nota-fisc.nat-operacao,1,4))
                   itens.ncm                    = IF AVAIL ITEM THEN ITEM.class-fiscal ELSE ""
                   itens.valor_bruto            = it-nota-fisc.vl-tot-item
                   itens.valor_liquido          = it-nota-fisc.vl-merc-liq
                   itens.valor_total_produto    = it-nota-fisc.vl-merc-liq
                   itens.valor_aliquota_icms    = it-nota-fisc.aliquota-icm
                   itens.valor_aliquota_ipi     = it-nota-fisc.aliquota-ipi
                   itens.valor_aliquota_pis     = 1.65    // buscar via api
                   itens.valor_aliquota_cofins  = 7.6     // buscar via api
                   itens.valor_cstb_pis         = "01"    // buscar via api
                   itens.valor_cstb_cofins      = "01"   // buscar via api
                   itens.custo_transferencia    = valor_custo.  /* "DIVISÇO, DA O VALOR DE ICMS"/ itens.quantidade.*/
                   

            ASSIGN itens.caixa                  = 0   // Buscar da onde?  
                   itens.volume                 = c-volume
                   itens.lote                   = c-lote
                   itens.valor_desconto         = it-nota-fisc.vl-desconto
                   itens.valor_base_icms        = it-nota-fisc.vl-bicms-it 
                   itens.valor_icms             = it-nota-fisc.vl-icms-it   
                   itens.valor_base_diferido    = it-nota-fisc.val-perc-icms-diferim
                   itens.valor_base_isenta      = it-nota-fisc.vl-bicms-it           
                   itens.valor_base_ipi         = it-nota-fisc.vl-bipi-it             
                   itens.valor_ipi              = it-nota-fisc.vl-ipi-it               
                   itens.valor_icms_st          = 0  // Procurar da onde pegar           
                   itens.valor_base_st          = 0  // Procurar da onde pegar
                   itens.valor_liquido          = it-nota-fisc.vl-merc-liq
                   itens.valor_total_produto    = it-nota-fisc.vl-tot-item 
                   itens.data_validade          = ""  // buscar da fat-ser-lote
                   itens.valor_despesa          = it-nota-fisc.vl-despes-it      
                   itens.valor_tributos         = 0  // Datasul nÆo totaliza tributos
                   itens.valor_cstb_pis         = it-nota-fisc.cod-sit-tributar-pis 
                   itens.valor_cstb_cofins      = it-nota-fisc.cod-sit-tributar-cofins 
                   itens.valor_base_pis         = it-nota-fisc.vl-bicms-it  // utilizado mesma base do icms
                   itens.valor_pis              = it-nota-fisc.val-unit-pis
                   itens.valor_base_cofins      = it-nota-fisc.vl-bicms-it  // utilizado mesma base do icms 
                   itens.valor_cofins           = it-nota-fisc.val-unit-cofins 
                   itens.valor_redutor_base_icms = it-nota-fisc.val-unit-cofins
                   itens.valor_cstb             = string(c-cstb)
                   itens.valor_csta             = IF AVAIL ITEM THEN STRING(item.codigo-orig) ELSE ""
                   itens.sequencia_origem       = it-nota-fisc.nr-seq-ped / 10
                   itens.peso_bruto             = it-nota-fisc.peso-bruto
                   itens.peso_liquido           = it-nota-fisc.peso-liq-fat 
                   itens.valor_frete            = it-nota-fisc.vl-frete-it 
                   itens.valor_seguro           = 0 // Seguro ‚ a nivel nota nÆo a nivel item 
                   itens.valor_embalagem        = 0 
                   itens.valor_outras_despesas  = 0  
                   itens.valor_cst_ipi          = it-nota-fisc.cd-trib-ipi 
                   itens.valor_modbc_icms       = 0 // Buscar da onde? 
                   itens.valor_modb_cst         = 0 // Buscar da onde? 
                   itens.valor_modb_ipi         = 0 // Buscar da onde? 
                   itens.valor_icms_substituto  = it-nota-fisc.vl-icmsub-it 
                   itens.valor_base_cst_ret     = 0 // Buscar da onde? 
                   itens.valor_icms_ret         = 0 // Buscar da onde?
                   .
                   
      
        END.
        
        
        
        FIND FIRST fat-duplic NO-LOCK
            WHERE fat-duplic.nr-fatura      = nota-fiscal.nr-nota-fis
              AND fat-duplic.cod-estabel    = nota-fiscal.cod-estabel
              AND fat-duplic.serie          = nota-fiscal.serie NO-ERROR.
              
        IF NOT AVAIL fat-duplic THEN
        DO:
        
            CREATE condicao_pagamento.
            ASSIGN condicao_pagamento.pedido_id             = IF nota-fiscal.serie = "402" THEN 0 ELSE INT(nota-fiscal.nr-pedcli)
                   condicao_pagamento.parcela               = ""
                   condicao_pagamento.condicao_pagamento    = ""
                   condicao_pagamento.valor                 = 0.   
        
            
        END.
        
        FOR EACH fat-duplic NO-LOCK
            WHERE fat-duplic.nr-fatura      = nota-fiscal.nr-nota-fis
              AND fat-duplic.cod-estabel    = nota-fiscal.cod-estabel
              AND fat-duplic.serie          = nota-fiscal.serie:
              
                FIND FIRST INT_DS_NOTA_SAIDA_PARCELAS NO-LOCK
                    WHERE  INT_DS_NOTA_SAIDA_PARCELAS.NSA_CNPJ_ORIGEM_S  = estabelec.cgc
                    AND    INT_DS_NOTA_SAIDA_PARCELAS.NSA_NOTAFISCAL_N   = int(nota-fiscal.nr-nota-fis)
                    AND    INT_DS_NOTA_SAIDA_PARCELAS.NSA_SERIE_S        = nota-fiscal.serie NO-ERROR.
                    
                    
                IF AVAIL INT_DS_NOTA_SAIDA_PARCELAS  THEN
                DO:
                    
                    ASSIGN c-nsu-num    = INT_DS_NOTA_SAIDA_PARCELAS.nsu. 
                    ASSIGN c-adquirente = INT_DS_NOTA_SAIDA_PARCELAS.cod-adquirente.
                    ASSIGN c-vencimento = INT_DS_NOTA_SAIDA_PARCELAS.VENCIMENTO.
                    ASSIGN c-origem     = INT_DS_NOTA_SAIDA_PARCELAS.ORIGEM_PAGTO.
                    
                                       
                END.

                ELSE DO:
                
                    FIND FIRST cst_fat_duplic NO-LOCK  // KML ALTERA
                         WHERE cst_fat_duplic.cod_estabel   = fat-duplic.cod-estabel
                         AND   cst_fat_duplic.serie         = fat-duplic.serie 
                         AND   cst_fat_duplic.nr_fatura     = fat-duplic.nr-fatura
                         AND   cst_fat_duplic.parcela       = fat-duplic.parcela
                         NO-ERROR.                
                
                    ASSIGN c-nsu-num    = IF AVAIL cst_fat_duplic THEN cst_fat_duplic.nsu_admin ELSE "".
                    ASSIGN c-adquirente = IF AVAIL cst_fat_duplic THEN int(cst_fat_duplic.adm_cartao) ELSE 0.
                    ASSIGN c-vencimento = fat-duplic.dt-venciment.
                    ASSIGN c-origem     = "Datasul".
                   
                    
                END.
               
              
                FIND FIRST int_ds_loja_cond_pag NO-LOCK  // KML ALTERA
                     WHERE int_ds_loja_cond_pag.cod_portador = fat-duplic.int-1
                     AND   int_ds_loja_cond_pag.cod_esp      = fat-duplic.cod-esp NO-ERROR.
                            
                IF AVAIL int_ds_loja_cond_pag THEN
                DO:
                    
                    ASSIGN c-condipag = int_ds_loja_cond_pag.condipag.
                    
                    
                END.
                
                ELSE DO:
                    
                    c-condipag = "0".
                    
                END.
                
                CREATE condicao_pagamento.
                
                
                ASSIGN condicao_pagamento.pedido_id             = IF nota-fiscal.serie = "402" THEN 0 ELSE INT(nota-fiscal.nr-pedcli)  //INT64(SUBSTRING(nota-fiscal.nr-pedcli,1,6))
                       condicao_pagamento.parcela               = fat-duplic.parcela
                       condicao_pagamento.condicao_pagamento    = "credito"
                       condicao_pagamento.valor                 = fat-duplic.vl-parcela
                       condicao_pagamento.condicao_pagamento_id = int(c-condipag)
                       condicao_pagamento.adquirente_id         = string(c-adquirente)
                       condicao_pagamento.nsu                   = c-nsu-num
                       condicao_pagamento.origem_pagamento      = c-origem
                       condicao_pagamento.vencimento            = c-vencimento
                       .
        END.    
        
    END.
    

END PROCEDURE.

PROCEDURE pGeraToken:


    DEFINE OUTPUT PARAMETER p-token AS CHAR                                 NO-UNDO.  
    
    DEFINE VARIABLE chHttp          AS COM-HANDLE                           NO-UNDO.
    DEFINE VARIABLE oJson           AS JsonObject                           NO-UNDO.
    DEFINE VARIABLE oJsonResponse   AS JsonObject                           NO-UNDO.
    DEFINE VARIABLE myParser        AS ObjectModelParser NO-UNDO. 
    DEFINE VARIABLE oURI            AS URI           NO-UNDO.
    DEFINE VARIABLE oLib            AS OpenEdge.Net.HTTP.IHttpClientLibrary NO-UNDO.
    DEFINE VARIABLE oRequest        AS IHttpRequest  NO-UNDO.
    DEFINE VARIABLE oResponse       AS IHttpResponse NO-UNDO.
    DEFINE VARIABLE oRequestBody    AS String NO-UNDO.        
    DEFINE VARIABLE cSSLProtocols   AS CHARACTER          NO-UNDO EXTENT.
    DEFINE VARIABLE cSSLCiphers     AS CHARACTER          NO-UNDO EXTENT.   
    
    oRequestBody = new String('username=datasul&password=lnb0uD8xbWLS1t'). // //Rrpj7DTkq%26Kt!%24
    
    ASSIGN oURI        = OpenEdge.Net.URI:Parse("https://datahub-api-production-97903554824.us-east1.run.app") //https://datahub-api.nisseilabs.com.br //https://dev-datahub-api.nisseilabs.com.br
           oURI:Path   = '/auth/token?username=datasul&password=lnb0uD8xbWLS1t'.    
           
    ASSIGN oLib = ClientLibraryBuilder:Build()
                                      :sslVerifyHost(FALSE)
                                      :ServerNameIndicator(oURI:host)
                                      :library.  

    oRequest  = RequestBuilder:POST(oURI , oRequestBody)
                :AddHeader("Content-Type", "application/x-www-form-urlencoded")
                :Request  .
                
    ASSIGN oResponse = ClientBuilder:Build():UsingLibrary(oLib):Client:Execute(oRequest) .   
    
    oJsonResponse = CAST(oResponse:Entity, JsonObject) NO-ERROR.   
    
    ASSIGN p-token =  oJsonResponse:GetCharacter("access_token").

END PROCEDURE.

PROCEDURE pi-custo-grade:
    DEFINE OUTPUT PARAMETER de-vl-custo-grade AS DECIMAL     NO-UNDO.
    def var i-mo        as int init 1                               no-undo.
    def var i-mo-fasb   as int                                      no-undo.
    def var i-mo-cmi    as int                                      no-undo.
    def var i-moeda     as int format 9                             no-undo.
    DEF VAR l-moed-ifrs-1 AS LOG                                    NO-UNDO.
    DEF VAR l-moed-ifrs-2 AS LOG                                    NO-UNDO.
    DEF VAR de-vl-ipi         AS DEC /*LIKE movto-estoq.valor-ipi */ NO-UNDO.
    DEF VAR de-vl-icms        AS DEC /*LIKE movto-estoq.valor-icm */ NO-UNDO.
    DEF VAR de-vl-pis         AS DEC /*LIKE movto-estoq.valor-pis */ NO-UNDO.
    DEF VAR de-vl-cofins      AS DEC /*LIKE movto-estoq.val-cofins*/ NO-UNDO.
    DEF VAR de-vl-icms-stret  AS DEC /*LIKE movto-estoq.valor-icm */ NO-UNDO.
    DEFINE VARIABLE de-vl-bonificacao AS DECIMAL     NO-UNDO.
    DEFINE VARIABLE de-vl-importados AS DECIMAL     NO-UNDO.

    ASSIGN de-vl-bonificacao = 0.
    
    find first param-global no-lock no-error.
    find first param-estoq  no-lock no-error.
    find FIRST param-fasb   
       where param-fasb.ep-codigo = "RPW" no-lock no-error.
    
    assign i-mo-fasb = if avail param-fasb
                       then if param-estoq.moeda1 = param-fasb.moeda-fasb 
                            then 2
                            else if param-estoq.moeda2 = param-fasb.moeda-fasb 
                                 then 3
                                 else 0
                       else 0
           i-mo-cmi  = if avail param-fasb
                       then if param-estoq.moeda1 = param-fasb.moeda-cmi 
                            then 2                     
                            else if param-estoq.moeda2 = param-fasb.moeda-cmi 
                                 then 3
                                 else 0
                       else 0.
    IF can-find(first ems2log.funcao 
                where funcao.cd-funcao = "spp-ifrs-contab-estoq":U 
                  and funcao.ativo     = yes) THEN
        ASSIGN l-moed-ifrs-1 = param-estoq.log-moed-ifrs-1 
               l-moed-ifrs-2 = param-estoq.log-moed-ifrs-2.

    ASSIGN de-vl-custo-grade = 0
           de-vl-importados  = 0.

    FOR FIRST ITEM NO-LOCK
        WHERE ITEM.it-codigo = it-nota-fisc.it-codigo,
        EACH movto-estoq NO-LOCK
        WHERE movto-estoq.cod-estabel  = it-nota-fisc.cod-estabel
        AND   movto-estoq.serie-docto  = it-nota-fisc.serie      
        AND   movto-estoq.nro-docto    = it-nota-fisc.nr-nota-fis
        AND   movto-estoq.cod-emitente = nota-fiscal.cod-emitente
        AND   movto-estoq.sequen-nf    = it-nota-fisc.nr-seq-fat
        AND   movto-estoq.it-codigo    = it-nota-fisc.it-codigo:
    
        ASSIGN de-vl-ipi        = it-nota-fisc.vl-ipi-it  
               de-vl-icms       = it-nota-fisc.vl-icms-it 
               de-vl-pis        = dec(substr(item.char-2,31,5)) * it-nota-fisc.vl-merc-liq / 100
               de-vl-cofins     = dec(substr(item.char-2,36,5)) * it-nota-fisc.vl-merc-liq / 100
               de-vl-icms-stret = 0.

        FOR FIRST esp-item-nfs-st NO-LOCK
            WHERE esp-item-nfs-st.cod-estab-nfs = it-nota-fisc.cod-estabel
            AND   esp-item-nfs-st.cod-ser-nfs   = it-nota-fisc.serie      
            AND   esp-item-nfs-st.cod-docto-nfs = it-nota-fisc.nr-nota-fis
            AND   esp-item-nfs-st.num-seq-nfs   = it-nota-fisc.nr-seq-fat
            AND   esp-item-nfs-st.cod-item      = it-nota-fisc.it-codigo,
            FIRST ems2mult.emitente NO-LOCK
            WHERE emitente.cod-emitente = INT(esp-item-nfs-st.cod-emitente-entr):

            FOR FIRST int_ds_it_docto_xml EXCLUSIVE-LOCK
                WHERE int_ds_it_docto_xml.nnf       = esp-item-nfs-st.cod-nota-entr
                AND   int_ds_it_docto_xml.serie     = esp-item-nfs-st.cod-ser-entr
                AND   int_ds_it_docto_xml.cnpj      = emitente.cgc
                AND   int_ds_it_docto_xml.sequencia = esp-item-nfs-st.num-seq-item-entr
                AND   int_ds_it_docto_xml.it_codigo = esp-item-nfs-st.cod-item:

                ASSIGN de-vl-custo-grade = de-vl-custo-grade
                                        - (((int_ds_it_docto_xml.vicmsstret + IF int_ds_it_docto_xml.vICMSSubs = ? THEN 0 ELSE int_ds_it_docto_xml.vICMSSubs ) / int_ds_it_docto_xml.qCom) * it-nota-fisc.qt-faturada[1]).


                ASSIGN de-vl-custo-grade = de-vl-custo-grade + IF int_ds_it_docto_xml.cst_icms = 60 THEN it-nota-fisc.vl-icms-it ELSE 0.
    
                 FIND FIRST b-emitente NO-LOCK
                        WHERE b-emitente.cod-emitente = nota-fiscal.cod-emitente NO-ERROR.

                IF int_ds_it_docto_xml.picms = 4 AND 
                   b-emitente.estado = "PR" THEN DO:

                    ASSIGN de-vl-importados = ((int_ds_it_docto_xml.vbc_icms / int_ds_it_docto_xml.qcom * 12 / 100) - 
                                          (int_ds_it_docto_xml.vbc_icms / int_ds_it_docto_xml.qcom * int_ds_it_docto_xml.picms / 100)) * it-nota-fisc.qt-faturada[1].

                END.
 

                FIND FIRST int_ds_natur_oper NO-LOCK
                    WHERE int_ds_natur_oper.log_bonificacao = YES
                      AND INT_ds_natur_oper.nat_operacao    = int_ds_it_docto_xml.nat_operacao  NO-ERROR.

                IF AVAIL int_ds_natur_oper THEN DO:


                    FIND FIRST item-doc-est NO-LOCK
                        WHERE item-doc-est.nro-docto    = int_ds_it_docto_xml.nnf       
                          AND item-doc-est.serie-docto  = int_ds_it_docto_xml.serie     
                          AND item-doc-est.cod-emitente = emitente.cod-emitente               
                          AND item-doc-est.sequencia    = int_ds_it_docto_xml.sequencia 
                          AND item-doc-est.it-codigo    = int_ds_it_docto_xml.it_codigo NO-ERROR.

                    IF AVAIL item-doc-est THEN DO:

                        ASSIGN de-vl-bonificacao = ROUND(((item-doc-est.preco-total[1] + item-doc-est.despesas[1] - item-doc-est.desconto[1] )
                                                     / item-doc-est.quantidade * it-nota-fisc.qt-faturada[1] ),2) - it-nota-fisc.vl-icms-it.


                        ASSIGN de-vl-pis     = 0
                               de-vl-cofins  = 0.


                    END.

                END.


            END.

            FOR FIRST int_ds_nota_entrada_produt NO-LOCK
                WHERE int_ds_nota_entrada_produt.nen_cnpj_origem_s      = emitente.cgc
                AND   int_ds_nota_entrada_produt.nen_notafiscal_n       = INT(esp-item-nfs-st.cod-nota-entr)
                AND   int_ds_nota_entrada_produt.nen_serie_s            = esp-item-nfs-st.cod-ser-entr
                AND   int_ds_nota_entrada_produt.nep_sequencia_n        = esp-item-nfs-st.num-seq-item-entr
                AND   int_ds_nota_entrada_produt.nep_produto_n          = int(esp-item-nfs-st.cod-item):
    
                ASSIGN de-vl-icms-stret = int_ds_nota_entrada_produt.de-vicmsstret.
            END.
        END.
    
        IF (i-mo = 2 AND l-moed-ifrs-1)
        OR (i-mo = 3 AND l-moed-ifrs-2) THEN DO:
            run cdp/cd0813.p (input  0,
                              input  i-mo - 1,
                              input  de-vl-ipi,
                              input  movto-estoq.dt-trans,
                              output de-vl-ipi).
            run cdp/cd0813.p (input  0,
                              input  i-mo - 1,
                              input  de-vl-icms,
                              input  movto-estoq.dt-trans,
                              output de-vl-icms).
            run cdp/cd0813.p (input  0,
                              input  i-mo - 1,
                              input  de-vl-pis,
                              input  movto-estoq.dt-trans,
                              output de-vl-pis).
            run cdp/cd0813.p (input  0,
                              input  i-mo - 1,
                              input  de-vl-cofins,
                              input  movto-estoq.dt-trans,
                              output de-vl-cofins).
    
            if  de-vl-ipi    = ? then de-vl-ipi    = 0.
            if  de-vl-icms   = ? then de-vl-icms   = 0.
            if  de-vl-pis    = ? then de-vl-pis    = 0.
            if  de-vl-cofins = ? then de-vl-cofins = 0.
        END.

        if  movto-estoq.tipo-trans = 1 then  do:
            if  movto-estoq.valor-nota > 0 then do:
                assign de-vl-custo-grade = de-vl-custo-grade 
                                         - if  i-mo = 1 then 
                                               movto-estoq.valor-nota
                                           else 
                                                 ( movto-estoq.valor-mat-m[i-mo] 
                                                 + movto-estoq.valor-mob-m[i-mo] 
                                                 + movto-estoq.valor-ggf-m[i-mo]) +
        
                                               if  i-mo = i-mo-fasb then
                                                   (movto-estoq.vl-ipi-fasb[1] +
                                                    movto-estoq.vl-icm-fasb[1] +
                                                    DEC(movto-estoq.vl-pis-fasb) +
                                                    DEC(movto-estoq.val-cofins-fasb) )
                                               else
                                                   if  i-mo = i-mo-cmi then
                                                       (movto-estoq.vl-ipi-fasb[2] +
                                                        movto-estoq.vl-icm-fasb[2] +
                                                        DEC(movto-estoq.vl-pis-cmi) +
                                                        DEC(movto-estoq.val-cofins-cmi) )
                                                   ELSE
                                                       IF (i-mo = 2 AND l-moed-ifrs-1)
                                                       OR (i-mo = 3 AND l-moed-ifrs-2) THEN
                                                           ( de-vl-ipi   
                                                           + de-vl-icms  
                                                           + de-vl-pis   
                                                           + de-vl-cofins)
                                                       else 0.
            end.
            else do:
                assign de-vl-custo-grade = de-vl-custo-grade 
                                         - (  movto-estoq.valor-mat-m[i-mo] 
                                            + movto-estoq.valor-mob-m[i-mo] 
                                            + movto-estoq.valor-ggf-m[i-mo]).
            END.
        
        end.
        
        else do:
            if  movto-estoq.valor-nota > 0 then
                assign de-vl-custo-grade = de-vl-custo-grade 
                                         + if  i-mo = 1 then 
                                               movto-estoq.valor-nota
                                           else 
                                               if  i-mo = i-mo-fasb then
                                                   movto-estoq.vl-nota-fasb[1]
                                               else
                                                   if  i-mo = i-mo-cmi then
                                                       movto-estoq.vl-nota-fasb[2] 
                                                   else
                                                       ( movto-estoq.valor-mat-m[i-mo] 
                                                       + movto-estoq.valor-mob-m[i-mo] 
                                                       + movto-estoq.valor-ggf-m[i-mo]) + 
        
                                                       IF (i-mo = 2 AND l-moed-ifrs-1)
                                                       OR (i-mo = 3 AND l-moed-ifrs-2) THEN
                                                           ( de-vl-ipi   
                                                           + de-vl-icms  
                                                           + de-vl-pis   
                                                           + de-vl-cofins)
                                                       else 0.
            else do:
              assign de-vl-custo-grade = de-vl-custo-grade 
                                       + (  movto-estoq.valor-mat-m[i-mo] 
                                          + movto-estoq.valor-mob-m[i-mo] 
                                          + movto-estoq.valor-ggf-m[i-mo]).
            END.
    
        end.

        IF it-nota-fisc.nat-operacao = "5409a5" or
           it-nota-fisc.nat-operacao = "6409a5" or
		   it-nota-fisc.nat-operacao BEGINS "6152" THEN
            assign de-vl-custo-grade = de-vl-custo-grade 
                                     - de-vl-pis
                                     - de-vl-cofins.
    END.

    IF it-nota-fisc.nat-operacao BEGINS "6152" THEN DO:
        assign de-vl-custo-grade = de-vl-custo-grade     
                             + it-nota-fisc.vl-icmsub-it.

    END.
    ELSE DO:
    
        assign de-vl-custo-grade = de-vl-custo-grade 
                             + it-nota-fisc.vl-icms-it
                             + it-nota-fisc.vl-icmsub-it.
    END.
    
    
    /*Colocada valida‡Æo do flag cst60 na natureza de opera‡Æo, para validar e diminuir o valor de ICMS enviado para procfit*/
    /*30/01/2026*/
    FIND FIRST natur-oper NO-LOCK
        WHERE natur-oper.nat-operacao = it-nota-fisc.nat-operacao NO-ERROR.
        
    IF AVAIL natur-oper AND log-icms-substto-antecip = YES THEN
    DO:

         assign de-vl-custo-grade = de-vl-custo-grade
                                  - it-nota-fisc.vl-icms-it.

    END.
    /*FIM ALTERA€ÇO 30/01/2026*/
    

    ASSIGN de-vl-custo-grade = de-vl-custo-grade - de-vl-bonificacao + de-vl-importados.


    RETURN "NOK".
END PROCEDURE.



