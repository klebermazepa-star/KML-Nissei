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



{custom/eswms004.i}    

DEFINE INPUT PARAMETER c-tipo       AS CHAR NO-UNDO.
DEFINE INPUT PARAMETER c-tipoNota   AS CHAR NO-UNDO.
DEFINE INPUT PARAMETER r-documento  AS ROWID NO-UNDO.

DEF VAR EstaOK     AS LOGICAL.
DEF VAR Token      AS CHAR.
DEF VAR retornoAPI AS CHAR.


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
        
    RUN getToken .

    ASSIGN oURI        = OpenEdge.Net.URI:Parse("https://merco-prd-datahub-api-97903554824.us-east1.run.app")
           oURI:Path   = '/datasul/pub/notas_fiscais'.  
           
    ASSIGN oLib = ClientLibraryBuilder:Build()
                                      :sslVerifyHost(FALSE)
                                      :ServerNameIndicator(oURI:host)
                                      :library.   
                                      
    ASSIGN oJson = JsonAPIUtils:convertTempTableToJsonObject(DATASET dsnotas:HANDLE, NO).
    oJson = oJson:getJsonObject("dsnotas").
    
    oJson = oJson:GetJsonArray("nota_fiscal"):GetJsonObject(1). 
    
    oJsonsaida = NEW JsonObject().
    oJsonsaida:ADD("nota_fiscal",oJson).         
    
    oJsonsaida:WriteFile("u:\envioNota.json") NO-ERROR.  
    
    oRequest  = RequestBuilder:POST(oURI, oJsonsaida )
                :AddHeader("Content-Type", "application/json")
                :AddHeader("Authorization","Bearer " + token)
                :Request
    .                                      
    ASSIGN oResponse = ClientBuilder:Build():UsingLibrary(oLib):Client:Execute(oRequest) NO-ERROR.  
    
    
    oJsonResp = CAST(oResponse:Entity, JsonObject) NO-ERROR. 
    
    oJsonResp:WriteFile("u:\RetornoEnvioNota.json") NO-ERROR.
    
      

END PROCEDURE.


PROCEDURE pCarregaNotasEntrada:

    DEFINE INPUT PARAMETER r-nota-fiscal    AS ROWID no-undo.  
    DEFINE INPUT PARAMETER c-tiponota       AS CHAR NO-UNDO.
    
    DEFINE VARIABLE de-quantidade-total AS DECIMAL     NO-UNDO.
    DEFINE VARIABLE i-parcela           AS INTEGER     NO-UNDO.
    DEFINE VARIABLE c-chave-acesso      AS CHARACTER   NO-UNDO.
    
    FOR FIRST int_ds_nota_entrada NO-LOCK
        WHERE ROWID(int_ds_nota_entrada) = r-nota-fiscal:
        
        ASSIGN de-quantidade-total = 0.
        
        FOR EACH int_ds_nota_entrada_produt OF int_ds_nota_entrada NO-LOCK:
            
            ASSIGN de-quantidade-total  = de-quantidade-total + int_ds_nota_entrada_produt.nep_quantidade_n.
            
        END.
    
        FIND FIRST ems2mult.emitente NO-LOCK
            WHERE emitente.cgc = int_ds_nota_entrada.nen_cnpj_origem_s NO-ERROR.
               
        FIND FIRST ems2mult.estabelec NO-LOCK
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
        ASSIGN nota_fiscal.nota_id              = int_ds_nota_entrada.ped_codigo_n
               nota_fiscal.pedido_id            = int_ds_nota_entrada.ped_codigo_n
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
               nota_fiscal.nota_fiscal_origem               = 0  // O vincula est† no item da nota 
               nota_fiscal.serie_origem                     = ""  // O vincula est† no item da nota 
               nota_fiscal.chave_acesso_origem              = c-chave-acesso
               nota_fiscal.tipo_ambiente_nfe                = 1 // 1 - producao 2 - homologaá∆o                
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
            ASSIGN itens.pedido_id              = int_ds_nota_entrada.ped_codigo_n
                   itens.sequencia              = int_ds_nota_entrada_produt.nep_sequencia_n              
                   itens.produto                = int_ds_nota_entrada_produt.nep_produto_n                 
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
                   itens.valor_tributos         = 0   // Datasul n∆o totaliza tributos                    
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
                   itens.valor_outras_despesas  = 0  // N∆o encontrado                                   
                   itens.valor_cst_ipi          = int_ds_nota_entrada_produt.nep_cstb_ipi_n     
                   itens.valor_modbc_icms       = int_ds_nota_entrada_produt.nep_modbcicms_n            
                   itens.valor_modb_cst         = int_ds_nota_entrada_produt.nep_modbcst_n              
                   itens.valor_modb_ipi         = 0  // N∆o encontrado                                 
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
            ASSIGN condicao_pagamento.pedido_id             = int_ds_nota_entrada.ped_codigo_n
                   condicao_pagamento.parcela               = ""
                   condicao_pagamento.condicao_pagamento    = ""
                   condicao_pagamento.valor                 = 0.   
        
            
        END.
        
        FOR EACH int_ds_nota_entrada_dup OF int_ds_nota_entrada NO-LOCK:     
        
            ASSIGN i-parcela = i-parcela + 1.
               
            CREATE condicao_pagamento.
            ASSIGN condicao_pagamento.pedido_id             = int_ds_nota_entrada.ped_codigo_n
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

    FOR FIRST nota-fiscal NO-LOCK
        WHERE rowid(nota-fiscal) = r-nota-fiscal:
        
        ASSIGN de-quantidade-total = 0.
        
        FOR EACH it-nota-fisc OF nota-fiscal NO-LOCK:
            
            ASSIGN de-quantidade-total = de-quantidade-total + it-nota-fisc.qt-faturada[1].
        END.
    
        FIND FIRST ems2mult.emitente NO-LOCK
            WHERE emitente.nome-abrev = nota-fiscal.nome-ab-cli NO-ERROR.
            
        FIND FIRST ems2mult.estabelec NO-LOCK
            WHERE estabelec.cod-estabel = nota-fiscal.cod-estabel NO-ERROR.
            
        FIND FIRST natur-oper NO-LOCK
            WHERE natur-oper.nat-operacao   = nota-fiscal.nat-operacao NO-ERROR.
        

        CREATE nota_fiscal.
        ASSIGN nota_fiscal.nota_id              = INT(SUBSTRING(nota-fiscal.nr-pedcli,1,6) )
               nota_fiscal.pedido_id            = INT(SUBSTRING(nota-fiscal.nr-pedcli,1,6) )
               nota_fiscal.chave_acesso         = nota-fiscal.cod-chave-aces-nf-eletro
               nota_fiscal.versao               = "1.0"
               nota_fiscal.especie              = "NF-e"
               nota_fiscal.modelo               = "55"
               nota_fiscal.numero               = int(nota-fiscal.nr-nota-fis)
               nota_fiscal.serie                = nota-fiscal.serie
               nota_fiscal.data_emissao         = STRING( STRING(YEAR(nota-fiscal.dt-emis-nota), "9999") + "-" + STRING(MONTH(nota-fiscal.dt-emis-nota), "99") + "-" + STRING(DAY(nota-fiscal.dt-emis-nota), "99"))
               nota_fiscal.tipo_nota            = c-tiponota
               nota_fiscal.situacao             = IF nota-fiscal.idi-sit-nf-eletro = 3 THEN "Autorizada" ELSE "Cancelada"
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
               nota_fiscal.nota_fiscal_origem               = INT(nota-fiscal.nro-nota-orig) 
               nota_fiscal.serie_origem                     = nota-fiscal.serie-orig
               nota_fiscal.chave_acesso_origem              = ""
               nota_fiscal.tipo_ambiente_nfe                = 1 // 1 - producao 2 - homologaá∆o                
               .                
       
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
 
        FOR EACH it-nota-fisc OF nota-fiscal NO-LOCK:
            
            c-volume = "".
            
            FIND FIRST int_ds_pedido_retorno NO-LOCK
                WHERE int_ds_pedido_retorno.ped_codigo_n    = INT(nota-fiscal.nr-pedcli) 
                  AND int_ds_pedido_retorno.ppr_produto_n   = INT(it-nota-fisc.it-codigo)  NO-ERROR.
                
            IF AVAIL int_ds_pedido_retorno THEN
                ASSIGN c-volume = STRING(rpp_caixa_n).
       
                   
            CREATE itens.
            ASSIGN itens.pedido_id              = INT(SUBSTRING(nota-fiscal.nr-pedcli,1,6) )
                   itens.sequencia              = INT(it-nota-fisc.nr-seq-fat)
                   itens.produto                = INT(it-nota-fisc.it-codigo)
                   itens.quantidade             = it-nota-fisc.qt-faturada[1]
                   itens.cfop                   = INT(SUBSTRING(it-nota-fisc.nat-operacao,1,4))
                   itens.ncm                    = "12345678"
                   itens.valor_bruto            = it-nota-fisc.vl-tot-item
                   itens.valor_liquido          = it-nota-fisc.vl-merc-liq
                   itens.valor_total_produto    = it-nota-fisc.vl-merc-liq
                   itens.valor_aliquota_icms    = it-nota-fisc.aliquota-icm
                   itens.valor_aliquota_ipi     = it-nota-fisc.aliquota-ipi
                   itens.valor_aliquota_pis     = 1.65    // buscar via api
                   itens.valor_aliquota_cofins  = 7.6     // buscar via api
                   itens.valor_cstb_pis         = "01"    // buscar via api
                   itens.valor_cstb_cofins      = "01"   // buscar via api
                   .
                   
            ASSIGN itens.caixa                  = 0   // Buscar da onde?  
                   itens.volume                 = c-volume
                   itens.lote                   = ""  // buscar da fat-ser-lote
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
                   itens.valor_tributos         = 0  // Datasul n∆o totaliza tributos
                   itens.valor_cstb_pis         = it-nota-fisc.cod-sit-tributar-pis 
                   itens.valor_cstb_cofins      = it-nota-fisc.cod-sit-tributar-cofins 
                   itens.valor_base_pis         = it-nota-fisc.vl-bicms-it  // utilizado mesma base do icms
                   itens.valor_pis              = it-nota-fisc.val-unit-pis
                   itens.valor_base_cofins      = it-nota-fisc.vl-bicms-it  // utilizado mesma base do icms 
                   itens.valor_cofins           = it-nota-fisc.val-unit-cofins 
                   itens.valor_redutor_base_icms = it-nota-fisc.val-unit-cofins  
                   itens.sequencia_origem       = 0 // Procurar da onde pegar
                   itens.peso_bruto             = it-nota-fisc.peso-bruto
                   itens.peso_liquido           = it-nota-fisc.peso-liq-fat 
                   itens.valor_frete            = it-nota-fisc.vl-frete-it 
                   itens.valor_seguro           = 0 // Seguro Ç a nivel nota n∆o a nivel item 
                   itens.valor_embalagem        = 0 
                   itens.valor_outras_despesas  = 0  
                   itens.valor_cst_ipi          = it-nota-fisc.cd-trib-ipi 
                   itens.valor_modbc_icms       = 0 // Buscar da onde? 
                   itens.valor_modb_cst         = 0 // Buscar da onde? 
                   itens.valor_modb_ipi         = 0 // Buscar da onde? 
                   itens.valor_icms_substituto  = it-nota-fisc.vl-icmsub-it 
                   itens.valor_base_cst_ret     = 0 
                   itens.data_validade          = STRING( STRING(YEAR(nota-fiscal.dt-emis-nota), "9999") + "-" + STRING(MONTH(nota-fiscal.dt-emis-nota), "99") + "-" + STRING(DAY(nota-fiscal.dt-emis-nota), "99"))
                   itens.valor_icms_ret         = 0 
                    .
                   
        END.
        
       
        FIND FIRST fat-duplic NO-LOCK
            WHERE fat-duplic.nr-fatura      = nota-fiscal.nr-nota-fis
              AND fat-duplic.cod-estabel    = nota-fiscal.cod-estabel
              AND fat-duplic.serie          = nota-fiscal.serie NO-ERROR.
              
        IF NOT AVAIL fat-duplic THEN
        DO:
        
            CREATE condicao_pagamento.
            ASSIGN condicao_pagamento.pedido_id             = INT(SUBSTRING(nota-fiscal.nr-pedcli,1,6) )
                   condicao_pagamento.parcela               = ""
                   condicao_pagamento.condicao_pagamento    = ""
                   condicao_pagamento.valor                 = 0.   
        
            
        END.
              
              
        
        
        FOR EACH fat-duplic NO-LOCK
            WHERE fat-duplic.nr-fatura      = nota-fiscal.nr-nota-fis
              AND fat-duplic.cod-estabel    = nota-fiscal.cod-estabel
              AND fat-duplic.serie          = nota-fiscal.serie: 
               
            CREATE condicao_pagamento.
            ASSIGN condicao_pagamento.pedido_id             = INT(SUBSTRING(nota-fiscal.nr-pedcli,1,6) )
                   condicao_pagamento.parcela               = fat-duplic.parcela
                   condicao_pagamento.condicao_pagamento    = "credito"
                   condicao_pagamento.valor                 = fat-duplic.vl-parcela.   
               
        END.
    END.
    

END PROCEDURE.

PROCEDURE getToken.
    DEF VAR chHttp        AS COM-HANDLE        NO-UNDO .
    DEF VAR cHost         AS CHARACTER         NO-UNDO INIT "https://merco-prd-datahub-api-97903554824.us-east1.run.app/auth/token" .
    DEF VAR oJsonResponse AS JsonObject        NO-UNDO.
    DEF VAR myParser      AS ObjectModelParser NO-UNDO. 

    CREATE "Msxml2.ServerXMLHTTP" chHttp .

    chHttp:OPEN("POST",cHost, false) .
    chHttp:setRequestHeader("Content-Type"    , 'application/x-www-form-urlencoded') .         
    chHttp:SEND("username=datasul&password=kLEB3qJieSQK3YPEFKh"). 
    
    myParser = NEW ObjectModelParser(). 
    oJsonResponse = CAST(myParser:Parse(chHttp:responseText),JsonObject).

    IF oJsonResponse:has("access_token") THEN DO: 
       EstaOK = TRUE.
       ASSIGN Token = oJsonResponse:GetCharacter("access_token").
    END.
    ELSE retornoAPI = STRING(oJsonResponse:getJsonText()).
END PROCEDURE.


