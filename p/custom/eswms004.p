USING Progress.Lang.*.
USING Progress.Json.ObjectModel.*.


USING OpenEdge.Core.*.
USING OpenEdge.Net.HTTP.*.
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
DEFINE VARIABLE lcDanfe             AS LONGCHAR NO-UNDO.

DEFINE BUFFER b-nota-fiscal FOR nota-fiscal.


.MESSAGE "entrou programa" VIEW-AS ALERT-BOX.

IF c-tipo = "Saida" THEN
    RUN pCarregaNotasSaida (INPUT r-documento,
                            INPUT c-tipoNota) .  
                            
.MESSAGE "v1" SKIP
        c-tipo
    VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
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

    ASSIGN oURI        = OpenEdge.Net.URI:Parse("https://merco-prd-datahub-api-97903554824.us-east1.run.app")  //("https://merco-prd-datahub-api-97903554824.us-east1.run.app") //"https://merco-dev-datahub-api-97903554824.us-east1.run.app
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
    oJsonsaida:ADD("danfe_pdf", lcDanfe).
    
    
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
    
    .MESSAGE "dentro procedure"
        VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
    
    FOR EACH int_ds_docto_xml
        WHERE rowid(int_ds_docto_xml) = r-nota-fiscal:
        
        .MESSAGE  "entrou"
            VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
        
        ASSIGN de-quantidade-total = 0.
        
        FOR EACH int_ds_it_docto_xml NO-LOCK
            WHERE int_ds_it_docto_xml.arquivo   = int_ds_docto_xml.arquivo
              AND int_ds_it_docto_xml.serie     = int_ds_docto_xml.serie  
              AND int_ds_it_docto_xml.nNf       = int_ds_docto_xml.nNf    
              AND int_ds_it_docto_xml.cnpj      = int_ds_docto_xml.cnpj   
              :
            
            ASSIGN de-quantidade-total  = de-quantidade-total + int_ds_it_docto_xml.qCom.
            
        END.
    
        FIND FIRST ems2mult.emitente NO-LOCK
            WHERE emitente.cgc = int_ds_docto_xml.CNPJ NO-ERROR.
               
        FIND FIRST ems2mult.estabelec NO-LOCK
            WHERE estabelec.cgc = int_ds_docto_xml.CNPJ_dest NO-ERROR. 
            
        ASSIGN c-chave-acesso = "".
        FIND FIRST item-doc-est NO-LOCK
            WHERE item-doc-est.cod-emitente = emitente.cod-emitente
              AND item-doc-est.serie-docto  = int_ds_docto_xml.serie
              AND item-doc-est.nro-docto    = string(int(int_ds_docto_xml.nNf), "9999999") NO-ERROR.
              
        IF AVAIL item-doc-est THEN DO:
                
            FIND FIRST nota-fiscal NO-LOCK
                WHERE nota-fiscal.cod-estabel   = estabelec.cod-estabel
                  AND nota-fiscal.serie         = item-doc-est.serie-comp
                  AND nota-fiscal.nr-nota-fis   = item-doc-est.nro-comp NO-ERROR.
                  
            IF AVAIL nota-fiscal THEN
                ASSIGN c-chave-acesso =  nota-fiscal.cod-chave-aces-nf-eletro.
                
            
        END.  
        
        
        CREATE nota_fiscal.
        ASSIGN nota_fiscal.nota_id              = int_ds_docto_xml.id_sequencial
               nota_fiscal.pedido_id            = int_ds_docto_xml.num_pedido 
               nota_fiscal.chave_acesso         = int_ds_docto_xml.chnfe      
               nota_fiscal.versao               = "1.0"                       
               nota_fiscal.especie              = "NF-e"                      
               nota_fiscal.modelo               = "55"                        
               nota_fiscal.numero               = INT(int_ds_docto_xml.nNf)        
               nota_fiscal.serie                = int_ds_docto_xml.serie     
               nota_fiscal.data_emissao         = STRING( STRING(YEAR(int_ds_docto_xml.dEmi), "9999") + "-" + STRING(MONTH(int_ds_docto_xml.dEmi), "99") + "-" + STRING(DAY(int_ds_docto_xml.dEmi), "99"))
               nota_fiscal.data_autorizacao     = STRING( STRING(YEAR(int_ds_docto_xml.dEmi), "9999") + "-" + STRING(MONTH(int_ds_docto_xml.dEmi), "99") + "-" + STRING(DAY(int_ds_docto_xml.dEmi), "99") + "T00:00:00Z")
               nota_fiscal.tipo_nota            = c-tiponota
               nota_fiscal.situacao             = "Autorizada"
               nota_fiscal.emitente_cnpj        = emitente.cgc
               nota_fiscal.destinatario_cnpj    = estabelec.cgc
               nota_fiscal.protocolo            = "" // Nao encontrado na nota de entrada
               nota_fiscal.cfop                 = int_ds_docto_xml.cfop
               nota_fiscal.quantidade           = de-quantidade-total
               nota_fiscal.valor_total_produtos = int_ds_docto_xml.vNF
               nota_fiscal.valor_total_nota     = int_ds_docto_xml.vNF.
           
        ASSIGN nota_fiscal.transportadora_cnpj              = "" // Nao importa hoje
               nota_fiscal.transportadora_veiculo_placa     = "" // Nao importa hoje
               nota_fiscal.transportadora_veiculo_estado    = "" // Nao importa hoje
               nota_fiscal.transportadora_reboque_placa     = ""   //buscar dados da tabela transportador
               nota_fiscal.transportadora_reboque_estado    = ""   //buscar dados da tabela transportador
               nota_fiscal.observacao                       = int_ds_docto_xml.observacao
               nota_fiscal.nota_fiscal_origem               = 0  // O vincula est† no item da nota 
               nota_fiscal.serie_origem                     = ""  // O vincula est† no item da nota 
               nota_fiscal.chave_acesso_origem              = c-chave-acesso
               nota_fiscal.tipo_ambiente_nfe                = 1 // 1 - producao 2 - homologaá∆o                
               .                
       
         ASSIGN nota_fiscal.valor_desconto                  = int_ds_docto_xml.tot_desconto
                nota_fiscal.valor_ipi                       = int_ds_docto_xml.valor_ipi
                nota_fiscal.peso_bruto                      = 0 // Peso somente a nivel item
                nota_fiscal.peso_liquido                    = 0 // Peso somente a nivel item
                nota_fiscal.valor_frete                     = int_ds_docto_xml.valor_frete
                nota_fiscal.valor_seguro                    = int_ds_docto_xml.valor_seguro
                nota_fiscal.valor_embalagem                 = 0 // Peso somente a nivel item
                nota_fiscal.valor_outras_despesas           = int_ds_docto_xml.valor_outras
                nota_fiscal.modalidade_frete                = 0
                nota_fiscal.data_entrega                    =  STRING( STRING(YEAR(TODAY), "9999") + "-" + STRING(MONTH(TODAY), "99") + "-" + STRING(DAY(TODAY), "99")).

     
        .MESSAGE "criou tt-nota" SKIP nota_fiscal.numero
            VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
        FOR EACH int_ds_it_docto_xml NO-LOCK
            WHERE int_ds_it_docto_xml.arquivo   = int_ds_docto_xml.arquivo
              AND int_ds_it_docto_xml.serie     = int_ds_docto_xml.serie  
              AND int_ds_it_docto_xml.nNf       = int_ds_docto_xml.nNf    
              AND int_ds_it_docto_xml.cnpj      = int_ds_docto_xml.cnpj   
              :
        
            CREATE itens.
            ASSIGN itens.pedido_id              = int_ds_docto_xml.num_pedido            
                   itens.sequencia              = int_ds_it_docto_xml.sequencia             
                   itens.produto                = int(int_ds_it_docto_xml.it_codigo)                 
                   itens.quantidade             = int_ds_it_docto_xml.qCom               
                   itens.cfop                   = int_ds_it_docto_xml.cfop                    
                   itens.ncm                    = string(int_ds_it_docto_xml.ncm)             
                   itens.valor_bruto            = int_ds_it_docto_xml.vProd                  
                   itens.valor_liquido          = int_ds_it_docto_xml.vProd               
                   itens.valor_total_produto    = int_ds_it_docto_xml.vProd                
                   itens.valor_aliquota_icms    = int_ds_it_docto_xml.picms              
                   itens.valor_aliquota_ipi     = int_ds_it_docto_xml.pipi                   
                   itens.valor_aliquota_pis     = int_ds_it_docto_xml.ppis                   
                   itens.valor_aliquota_cofins  = int_ds_it_docto_xml.pcofins                
                   itens.valor_cstb_pis         = string(int_ds_it_docto_xml.cst_pis)                  
                   itens.valor_cstb_cofins      = string(int_ds_it_docto_xml.cst_cofins)               
                   .
                   
            ASSIGN itens.caixa                  = 0   // Buscar da onde?                 
                   itens.lote                   = int_ds_it_docto_xml.lote                  
                   itens.valor_desconto         = 0         
                   itens.valor_base_icms        = int_ds_it_docto_xml.vbc_icms              
                   itens.valor_icms             = int_ds_it_docto_xml.vicms             
                   itens.valor_base_diferido    = 0 // N∆o encontrado        
                   itens.valor_base_isenta      = 0 // N∆o encontrado            
                   itens.valor_base_ipi         = int_ds_it_docto_xml.vbc_ipi              
                   itens.valor_ipi              = int_ds_it_docto_xml.vipi              
                   itens.valor_icms_st          = int_ds_it_docto_xml.vicmsst                
                   itens.valor_base_st          = int_ds_it_docto_xml.vbcstret
                   itens.data_validade          = STRING( STRING(YEAR(int_ds_it_docto_xml.dVal), "9999") + "-" + STRING(MONTH(int_ds_it_docto_xml.dVal), "99") + "-" + STRING(DAY(int_ds_it_docto_xml.dVal), "99"))          
                   itens.valor_despesa          = int_ds_it_docto_xml.vOutro          
                   itens.valor_tributos         = 0   // Datasul n∆o totaliza tributos                    
                   itens.valor_cstb_pis         = string(int_ds_it_docto_xml.cst_pis)                    
                   itens.valor_cstb_cofins      = string(int_ds_it_docto_xml.cst_cofins)      
                   itens.valor_base_pis         = int_ds_it_docto_xml.vbc_pis              
                   itens.valor_pis              = int_ds_it_docto_xml.vpis             
                   itens.valor_base_cofins      = int_ds_it_docto_xml.vbc_cofins             
                   itens.valor_cofins           = int_ds_it_docto_xml.vcofins          
                   itens.valor_redutor_base_icms = int_ds_it_docto_xml.predBc     
                   itens.sequencia_origem       = 0 // Procurar da onde pegar                           
                   itens.peso_bruto             = 0 // ver da onde pegar                                
                   itens.peso_liquido           = 0 // ver da onde pegar                                
                   itens.valor_frete            = 0 // frete fica no total da nota
                   itens.valor_seguro           = 0 // frete fica no total da nota                      
                   itens.valor_embalagem        = 0 // Nao encontrado                                   
                   itens.valor_outras_despesas  = 0  // N∆o encontrado                                   
                   itens.valor_cst_ipi          = int_ds_it_docto_xml.cst_ipi     
                   itens.valor_modbc_icms       = int_ds_it_docto_xml.modbc            
                   itens.valor_modb_cst         = int_ds_it_docto_xml.modbcst              
                   itens.valor_modb_ipi         = 0  // N∆o encontrado                                 
                   itens.valor_icms_substituto  = int_ds_it_docto_xml.vICMSSubs                  
                   itens.valor_base_cst_ret     = int_ds_it_docto_xml.vbcstret               
                   itens.valor_icms_ret         = int_ds_it_docto_xml.vicmsstret
                   itens.ean                    = string(int_ds_it_docto_xml.EAN)
                   //itens.volume                 = string(int_ds_docto_xml.volume)
                   .
            
        END. 
        
        ASSIGN i-parcela = 0.
        
        FIND FIRST int_ds_docto_xml_dup NO-LOCK
            WHERE int_ds_docto_xml_dup.serie     = int_ds_docto_xml.serie  
              AND int_ds_docto_xml_dup.nNf       = int_ds_docto_xml.nNf    
              AND int_ds_docto_xml_dup.cnpj_cpf  = int_ds_docto_xml.cnpj NO-ERROR.
              
        IF NOT AVAIL int_ds_nota_entrada_dup THEN
        DO:
        
            CREATE condicao_pagamento.
            ASSIGN condicao_pagamento.pedido_id             = int_ds_docto_xml.num_pedido
                   condicao_pagamento.parcela               = ""
                   condicao_pagamento.condicao_pagamento    = ""
                   condicao_pagamento.valor                 = 0.   
        
            
        END.
        
        FOR EACH int_ds_docto_xml_dup NO-LOCK
            WHERE int_ds_docto_xml_dup.serie     = int_ds_docto_xml.serie  
              AND int_ds_docto_xml_dup.nNf       = int_ds_docto_xml.nNf    
              AND int_ds_docto_xml_dup.cnpj_cpf  = int_ds_docto_xml.cnpj:   
        
            ASSIGN i-parcela = i-parcela + 1.
               
            CREATE condicao_pagamento.
            ASSIGN condicao_pagamento.pedido_id             = int_ds_docto_xml.num_pedido
                   condicao_pagamento.parcela               = string(i-parcela)
                   condicao_pagamento.condicao_pagamento    = "Entrada"
                   condicao_pagamento.valor                 = int_ds_docto_xml_dup.vDup
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
        
        FIND FIRST nota-fisc-adc NO-LOCK
             WHERE nota-fisc-adc.cod-estab      = nota-fiscal.cod-estabel 
             AND   nota-fisc-adc.cod-serie      = nota-fiscal.serie 
             AND   nota-fisc-adc.cod-nota-fisc  = nota-fiscal.nr-nota-fis
             AND   nota-fisc-adc.cdn-emitente   = nota-fiscal.cod-emitente
             AND   nota-fisc-adc.cod-natur-oper = nota-fiscal.nat-operacao NO-ERROR.
            
        FIND FIRST b-nota-fiscal NO-LOCK
             WHERE b-nota-fiscal.cod-estabel = nota-fisc-adc.cod-estab    
             AND   b-nota-fiscal.serie       = nota-fisc-adc.cod-ser-docto-referado    
             AND   b-nota-fiscal.nr-nota-fis = nota-fisc-adc.cod-docto-referado  NO-ERROR.    
            
           
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
            
        //Busca provisoria referente aos volumes da nota
            
        FIND FIRST pre-fatur NO-LOCK
            WHERE pre-fatur.nr-pedcli   = nota-fiscal.nr-pedcli 
            AND   pre-fatur.cdd-embarq  = nota-fiscal.cdd-embarq 
            AND   pre-fatur.nr-embarque = nota-fiscal.nr-embarque NO-ERROR.
            
        FIND FIRST res-emb NO-LOCK
            WHERE res-emb.cdd-embarq  = pre-fatur.cdd-embarq 
            AND   res-emb.nr-resumo   = pre-fatur.nr-resumo  NO-ERROR.
            
        IF AVAIL res-emb THEN DO:
        
            c-volume = string(res-emb.qt-volumes). 
        END.
        
        ELSE DO:
            c-volume = "".
        END.
         
        FIND FIRST ped-venda NO-LOCK
            WHERE  ped-venda.nr-pedcli = nota-fiscal.nr-pedcli NO-ERROR.
        
        FIND FIRST ems2mult.transporte NO-LOCK
            WHERE  transporte.nome-abrev =  ped-venda.nome-transp NO-ERROR.
        
       
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
               nota_fiscal.data_autorizacao     = IF AVAIL ret-nf-eletro THEN STRING( STRING(YEAR(ret-nf-eletro.dat-ret), "9999") + "-" + STRING(MONTH(ret-nf-eletro.dat-ret), "99") + "-" + STRING(DAY(ret-nf-eletro.dat-ret), "99")) + STRING(ret-nf-eletro.hra-ret, "T99:99:99Z") ELSE STRING(NOW) //data_retorno
               nota_fiscal.tipo_nota            = c-tiponota
               nota_fiscal.situacao             = IF nota-fiscal.idi-sit-nf-eletro = 3 THEN "Autorizada" ELSE "Cancelada"
               nota_fiscal.emitente_cnpj        = estabelec.cgc
               nota_fiscal.destinatario_cnpj    = emitente.cgc
               nota_fiscal.protocolo            = nota-fiscal.cod-protoc
               nota_fiscal.cfop                 = INT(natur-oper.cod-cfop)
               nota_fiscal.quantidade           = de-quantidade-total
               nota_fiscal.valor_total_produtos = nota-fiscal.vl-mercad
               .
               
        IF nota-fiscal.cod-chave-aces-nf-eletro <> ""THEN
        DO:
       
            RUN getDanfe (INPUT nota-fiscal.cod-chave-aces-nf-eletro,
                          OUTPUT lcDanfe). 
           
        END.
        
              
           
        ASSIGN nota_fiscal.transportadora_cnpj              = IF AVAIL transporte THEN transporte.cgc ELSE ""   //buscar dados da tabela transportador
               nota_fiscal.transportadora_veiculo_placa     = ""  //buscar dados da tabela transportador
               nota_fiscal.transportadora_veiculo_estado    = ""   //buscar dados da tabela transportador
               nota_fiscal.transportadora_reboque_placa     = ""   //buscar dados da tabela transportador
               nota_fiscal.transportadora_reboque_estado    = ""   //buscar dados da tabela transportador
               nota_fiscal.observacao                       = nota-fiscal.observ-nota
               nota_fiscal.nota_fiscal_origem               = IF AVAIL nota-fisc-adc THEN INT(nota-fisc-adc.cod-docto-referado)  ELSE 0     //INT(nota-fiscal.nro-nota-orig)
               nota_fiscal.serie_origem                     = IF AVAIL nota-fisc-ad THEN nota-fisc-adc.cod-ser-docto-referado    ELSE ""    //nota-fiscal.serie-orig
               nota_fiscal.chave_acesso_origem              = IF AVAIL b-nota-fiscal THEN b-nota-fiscal.cod-chave-aces-nf-eletro ELSE ""
               nota_fiscal.tipo_ambiente_nfe                = 1 // 1 - producao 2 - homologaá∆o                
               .
               
         ASSIGN nota_fiscal.valor_desconto                  = nota-fiscal.val-desconto-total  
                nota_fiscal.valor_ipi                       = nota-fiscal.vl-tot-ipi  
                nota_fiscal.peso_bruto                      = nota-fiscal.peso-bru-tot
                nota_fiscal.peso_liquido                    = nota-fiscal.peso-liq-tot
                nota_fiscal.valor_frete                     = nota-fiscal.vl-frete
                nota_fiscal.valor_seguro                    = nota-fiscal.vl-seguro
                nota_fiscal.valor_embalagem                 = nota-fiscal.vl-embalagem
                nota_fiscal.valor_outras_despesas           = nota-fiscal.val-desp-outros 
                nota_fiscal.modalidade_frete                = nota-fiscal.modalidade 
                nota_fiscal.volumes_quantidade              = int(c-volume)
                nota_fiscal.valor_total_nota                = nota-fiscal.vl-tot-nota
                nota_fiscal.destinatario_nome               = emitente.nome-emit
                nota_fiscal.destinatario_logradouro         = emitente.endereco
                nota_fiscal.destinatario_numero             = "" //nao tenho isolado, e concatenado
                nota_fiscal.destinatario_complemento        = "" //nao tenho isolado, e concatenado
                nota_fiscal.destinatario_bairro             = emitente.bairro
                nota_fiscal.destinatario_cidade             = emitente.cidade
                nota_fiscal.destinatario_estado             = emitente.estado
                nota_fiscal.destinatario_pais               = emitente.pais
                nota_fiscal.destinatario_cep                = emitente.cep
                nota_fiscal.destinatario_referencia         = "" // nao tenho
                nota_fiscal.destinatario_ddd_fone           = "" //nao tenho
                nota_fiscal.destinatario_fone               = emitente.telefone[1]
                nota_fiscal.destinatario_email              = emitente.e-mail
                nota_fiscal.data_entrega                    = STRING( STRING(YEAR(TODAY), "9999") + "-" + STRING(MONTH(TODAY), "99") + "-" + STRING(DAY(TODAY), "99"))
                .
 
        FOR FIRST ped-venda NO-LOCK
            WHERE ped-venda.nome-abrev = nota-fiscal.nome-ab-cli
            AND   ped-venda.nr-pedcli  = nota-fiscal.nr-pedcli:
            
            ASSIGN nota_fiscal.data_entrega =  STRING( STRING(YEAR(ped-venda.dt-entrega), "9999") + "-" + STRING(MONTH(ped-venda.dt-entrega), "99") + "-" + STRING(DAY(ped-venda.dt-entrega), "99")).
        END.
        
        IF natur-oper.especie-doc = "NFD" 
           AND natur-oper.transf = NO 
           AND natur-oper.tipo = 1 
                    
           OR (natur-oper.especie-doc = "NFD" 
           AND natur-oper.transf = NO 
           AND natur-oper.tipo = 2)
           
           OR (natur-oper.especie-doc = "NFD" 
           AND natur-oper.transf = NO 
           AND natur-oper.tipo = 2  
           AND natur-oper.cod-mensagem = 5) 
           
           OR (natur-oper.especie-doc = "NFS" 
           AND natur-oper.transf = NO 
           AND natur-oper.tipo = 2 
           AND natur-oper.cod-mensagem = 7)
           
           OR (natur-oper.especie-doc = "NFS" 
           AND natur-oper.transf = NO 
           AND natur-oper.tipo = 2 
           AND natur-oper.nat-vinculada <> ""
           AND natur-oper.cod-cfop = "6923")
                
            
        THEN DO:
          
            FOR EACH it-nota-fisc OF nota-fiscal NO-LOCK:
            
                FIND FIRST ITEM NO-LOCK
                    WHERE ITEM.it-codigo = it-nota-fisc.it-codigo NO-ERROR.
                    
                    
                IF AVAIL ITEM THEN DO:
                
                    FIND FIRST item-mat NO-LOCK
                        WHERE item-mat.it-codigo = ITEM.it-codigo.
                        
                END.
                
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
                       itens.volume                 = ""                               //VALIDAR FAT-SER-LOTE
                       //itens.lote                   = fat-ser-lote.nr-serlote
                       itens.valor_desconto         = it-nota-fisc.val-desconto-inform
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
                       itens.ean                    = item-mat.cod-ean
                       //wt-docto.nr-volumes
                       
                        .
                       
            END.
        END.        
        
        FOR EACH it-nota-fisc OF nota-fiscal NO-LOCK,
            EACH fat-ser-lote OF it-nota-fisc:
            
            FIND FIRST ITEM NO-LOCK
                WHERE ITEM.it-codigo = it-nota-fisc.it-codigo NO-ERROR.
                
                
            IF AVAIL ITEM THEN DO:
            
                FIND FIRST item-mat NO-LOCK
                    WHERE item-mat.it-codigo = ITEM.it-codigo.
                    
            END.
            
            FIND FIRST int_ds_pedido_retorno NO-LOCK
                WHERE int_ds_pedido_retorno.ped_codigo_n    = INT(nota-fiscal.nr-pedcli) 
                  AND int_ds_pedido_retorno.ppr_produto_n   = INT(it-nota-fisc.it-codigo)  NO-ERROR.
                
            IF AVAIL int_ds_pedido_retorno THEN
                ASSIGN c-volume = STRING(rpp_caixa_n).
       
                   
            CREATE itens.
            ASSIGN itens.pedido_id              = INT(SUBSTRING(nota-fiscal.nr-pedcli,1,6) )
                   itens.sequencia              = INT(it-nota-fisc.nr-seq-fat)
                   itens.produto                = INT(it-nota-fisc.it-codigo)
                   itens.quantidade             = fat-ser-lote.qt-baixada[1] //it-nota-fisc.qt-faturada[1]
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
                   itens.volume                 = ""                           
                   itens.lote                   = fat-ser-lote.nr-serlote
                   itens.valor_desconto         = it-nota-fisc.val-desconto-inform
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
                   itens.ean                    = item-mat.cod-ean
                   //wt-docto.nr-volumes
                   
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
        
        FIND LAST ret-nf-eletro NO-LOCK
             WHERE ret-nf-eletro.cod-estabel = nota-fiscal.cod-estabel
             AND   ret-nf-eletro.cod-serie   = nota-fiscal.serie       
             AND   ret-nf-eletro.nr-nota-fis = nota-fiscal.nr-nota-fis NO-ERROR.
        IF AVAIL ret-nf-eletro THEN
        DO:
        
            ASSIGN nota_fiscal.data_autorizacao     = IF AVAIL ret-nf-eletro THEN STRING( STRING(YEAR(ret-nf-eletro.dat-ret), "9999") + "-" + STRING(MONTH(ret-nf-eletro.dat-ret), "99") + "-" + STRING(DAY(ret-nf-eletro.dat-ret), "99")) + STRING(ret-nf-eletro.hra-ret, "T99:99:99Z") ELSE STRING(NOW).
        
            
        END.
        
    END.
    

END PROCEDURE.

PROCEDURE getToken.
    DEF VAR chHttp        AS COM-HANDLE        NO-UNDO .
    DEF VAR cHost         AS CHARACTER         NO-UNDO INIT "https://merco-prd-datahub-api-97903554824.us-east1.run.app/auth/token" . //"https://merco-prd-datahub-api-97903554824.us-east1.run.app/auth/token" 
    DEF VAR oJsonResponse AS JsonObject        NO-UNDO.                                                                               //"https://merco-dev-datahub-api-97903554824.us-east1.run.app
    DEF VAR myParser      AS ObjectModelParser NO-UNDO. 

    CREATE "Msxml2.ServerXMLHTTP" chHttp .

    chHttp:OPEN("POST",cHost, false) .
    chHttp:setRequestHeader("Content-Type"    , 'application/x-www-form-urlencoded') .         
    chHttp:SEND("username=datasul&password=kLEB3qJieSQK3YPEFKh"). //("username=datasul&password=kLEB3qJieSQK3YPEFKh") //zyoCZQcpWyEMtWU
    
    myParser = NEW ObjectModelParser(). 
    oJsonResponse = CAST(myParser:Parse(chHttp:responseText),JsonObject).    
    
    IF oJsonResponse:has("access_token") THEN DO: 
       EstaOK = TRUE.
       ASSIGN Token = oJsonResponse:GetCharacter("access_token").
    END.
    ELSE retornoAPI = STRING(oJsonResponse:getJsonText()).
    
END PROCEDURE.


PROCEDURE getDanfe.

    DEFINE VARIABLE oRequest        AS IHttpRequest NO-UNDO.
    DEFINE VARIABLE oResponse       AS IHttpResponse NO-UNDO.
    DEFINE VARIABLE oByteBucket     AS ByteBucket NO-UNDO.
    DEFINE VARIABLE vURL            AS URI           NO-UNDO.     
    DEFINE VARIABLE oLib            AS IHttpClientLibrary NO-UNDO.
    DEFINE VARIABLE cSSLProtocols   AS CHARACTER          NO-UNDO EXTENT.
    DEFINE VARIABLE cSSLCiphers     AS CHARACTER          NO-UNDO EXTENT. 
    DEFINE VARIABLE mDanfe          AS MEMPTR     NO-UNDO.
   
    DEF INPUT PARAMETER c-chave-acesso   AS CHAR NO-UNDO.
    DEF OUTPUT PARAMETER lcDanfeBase64   AS LONGCHAR   NO-UNDO.  
    
    ASSIGN vURL        = OpenEdge.Net.URI:Parse("https://nissei.inventti.app")
           vURL:Path   = '/nfe/api/PDF/DANFeEmissao?chave=' + c-chave-acesso.                  
    
    EXTENT(cSSLProtocols) = 1.
    EXTENT(cSSLCiphers) = 3.     

    ASSIGN cSSLProtocols[1] = 'TLSv1.2'
           cSSLCiphers[1]   = 'ECDHE-RSA-AES256-GCM-SHA384'
           cSSLCiphers[2]   = 'ECDHE-RSA-CHACHA20-POLY1305'
           cSSLCiphers[3]   = 'ECDHE-RSA-AES128-GCM-SHA256' .  
           
    ASSIGN oLib = ClientLibraryBuilder:Build()
                                      :SetSSLProtocols(cSSLProtocols)
                                      :SetSSLCiphers(cSSLCiphers)
                                      :sslVerifyHost(FALSE)
                                      :ServerNameIndicator(vURL:host)
                                      :library.  

    oRequest = RequestBuilder:Get(vURL):Request.

    ASSIGN oResponse = ClientBuilder:Build():UsingLibrary(oLib):Client:Execute(oRequest).
    
    IF TYPE-OF(oResponse:Entity, ByteBucket) THEN
    DO:     
        
        oByteBucket     = CAST(oResponse:Entity, ByteBucket).         
        mDanfe          = oByteBucket:GetBytes():Value.
        lcDanfeBase64   = BASE64-ENCODE(mDanfe).
    
    END.
    
END PROCEDURE.


