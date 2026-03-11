

USING OpenEdge.Core.*.
USING OpenEdge.Net.HTTP.*.
USING OpenEdge.Net.HTTP.RequestBuilder.
USING OpenEdge.Net.HTTP.IHttpClient.
USING OpenEdge.Net.HTTP.IHttpRequest.
USING OpenEdge.Net.HTTP.IHttpResponse.
USING OpenEdge.Net.HTTP.ClientBuilder.
USING OpenEdge.Net.HTTP.lib.ClientLibraryBuilder.
USING OpenEdge.Net.URI.
USING Progress.Lang.*.
USING Progress.Json.ObjectModel.*.  


USING com.totvs.framework.api.*.

USING Progress.Json.ObjectModel.JsonArray.
USING Progress.Json.ObjectModel.JsonObject.
USING Progress.Json.ObjectModel.JsonDataType.
USING Progress.Json.ObjectModel.ObjectModelParser.

/* defini‡Æo das temp-tables para recebimento de parƒmetros */
def temp-table tt-param no-undo
    field destino          as integer
    field arquivo          as char format "x(35)"
    field usuario          as char format "x(12)"
    field data-exec        as date
    field hora-exec        as integer
    field classifica       as integer
    field desc-classifica  as char format "x(40)".
    
/* recebimento de parƒmetros */
def temp-table tt-raw-digita
        field raw-digita	as raw.

def input parameter raw-param as raw no-undo.
def input parameter TABLE for tt-raw-digita.

create tt-param.                    
raw-transfer raw-param to tt-param NO-ERROR. 

IF tt-param.arquivo = "" THEN 
    ASSIGN tt-param.arquivo = "int082.txt"
           tt-param.destino = 3
           tt-param.data-exec = TODAY
           tt-param.hora-exec = TIME.
    

DEFINE VARIABLE c-token     AS CHARACTER   NO-UNDO.
DEFINE VARIABLE d-validade  AS DATETIME   NO-UNDO.
DEFINE VARIABLE c-mensagem AS CHARACTER   NO-UNDO.  
DEF VAR json_statusOperacoes    AS JsonArray  NO-UNDO.
    
DEFINE TEMP-TABLE tt-antecipacoes NO-UNDO
    FIELD tipoOperacao              AS INT      //status
    FIELD numeroOperacao            AS CHAR
    FIELD codigoOcorrencia          AS CHAR
    FIELD codigoAgenteFinanceiro    AS CHAR     //status
    FIELD numeroInscricaocomprador  AS CHAR     //comprador
    FIELD numeroInscricaofornecedor AS CHAR     //fornecedor
    FIELD codigoFornecedorERP       AS CHAR     //fornecedor
    FIELD tipoTitulo                AS CHAR
    FIELD codigoIdentificadorTitulo AS CHAR
    FIELD numeroNotaFiscal          AS CHAR
    FIELD tipoMoeda                 AS CHAR
    FIELD valorSolicitadoTitulo     AS DEC
    FIELD valorLiquidoAPagar        AS DEC
    FIELD dataEmissao               AS CHAR
    FIELD dataVencimento            AS CHAR
    FIELD dtVencimentoAlongado      AS CHAR
    FIELD valorTotalDescontado      AS DEC
    FIELD taxaDeJurosAplicada       AS DEC
    FIELD chaveNfe                  AS CHAR
    FIELD origemChaveXML            AS CHAR 
    FIELD nrCnpjPagador             AS CHAR. 
    
DEFINE TEMP-TABLE tt-acertocontas NO-UNDO
    FIELD codigoFornecedorERP       AS CHAR
    FIELD codigoIdentificadorTitulo AS CHAR
    FIELD tipoAjuste                AS CHAR
    FIELD descricaoAjuste           AS CHAR
    FIELD valorAjuste               AS DEC
    FIELD numeroDocumentoAbatido    AS CHAR
    INDEX idx-chave
       codigoFornecedorERP
       codigoIdentificadorTitulo.
    
DEFINE TEMP-TABLE tt-titulos NO-UNDO
    FIELD cod_estab         AS CHAR
    FIELD cod_espec_docto   AS CHAR
    FIELD cod_ser_docto     AS CHAR
    FIELD cod_tit_ap        AS CHAR
    FIELD cod_parcela       AS CHAR
    FIELD numeroOperacao    AS CHAR.
      

FUNCTION LongCharToJsonObject RETURN JsonObject PRIVATE (INPUT jsonChar AS LONGCHAR):
    
    DEFINE VARIABLE jsonOutput AS JsonObject        NO-UNDO.
    DEFINE VARIABLE objParse   AS ObjectModelParser NO-UNDO.

    ASSIGN jsonOutput = NEW JsonObject()
           objParse   = NEW ObjectModelParser()
           jsonOutput = CAST(objParse:Parse(jsonChar), JsonObject).

    DELETE OBJECT objParse.

    RETURN jsonOutput.

END FUNCTION.



RUN pi-buscar-antecipacoes.
RUN pi-confirma-antecipacoes (INPUT 0,
                              INPUT "") .
RUN pi-substitui-titulo. 

PROCEDURE pi-buscar-antecipacoes: 


    DEFINE VARIABLE oClient     AS IHttpClient NO-UNDO.
    DEFINE VARIABLE oRequest    AS IHttpRequest NO-UNDO. 
    DEFINE VARIABLE oResponse   AS IHttpResponse NO-UNDO.
    DEFINE VARIABLE oJsonObject AS JsonObject NO-UNDO.
    DEFINE VARIABLE vURL        AS URI           NO-UNDO.
    DEFINE VARIABLE JsonString  AS CHAR NO-UNDO.
    DEFINE VARIABLE oLib        AS IHttpClientLibrary NO-UNDO.
    DEFINE VARIABLE cSSLProtocols  AS CHARACTER          NO-UNDO EXTENT.
    DEFINE VARIABLE cSSLCiphers    AS CHARACTER          NO-UNDO EXTENT.
    
    DEFINE VARIABLE oRequestParser  AS JsonAPIRequestParser NO-UNDO.
    DEFINE VARIABLE lcPayload       AS LONGCHAR             NO-UNDO.
    DEF VAR idxStatus AS INTEGER.
    DEFINE VARIABLE idxfornecedores AS INTEGER     NO-UNDO.
    DEFINE VARIABLE idxtitulos      AS INTEGER     NO-UNDO.
    DEFINE VARIABLE idxajustes      AS INTEGER     NO-UNDO.
    DEF VAR jsonStatus              AS JsonObject NO-UNDO.
    DEF VAR jsonComprador           AS JsonObject NO-UNDO.
    DEF VAR jsonfornecedores        AS Jsonarray NO-UNDO.
    DEF VAR jsonfornecedor          AS JsonObject NO-UNDO.
    DEF VAR jsontitulos             AS Jsonarray NO-UNDO.
    DEF VAR jsontitulo              AS JsonObject NO-UNDO.
    DEF VAR jsonajustes             AS JsonArray NO-UNDO.
    DEF VAR jsonajuste              AS JsonObject NO-UNDO.
    
    EXTENT(cSSLProtocols) = 1.
    EXTENT(cSSLCiphers) = 3.     

    // Supported ciphers and protocols at https://documentation.progress.com/output/ua/OpenEdge_latest/gscsv/supported-protocols,-ciphers,-and-certificates-f.html# 
    ASSIGN cSSLProtocols[1] = 'TLSv1.2'
           cSSLCiphers[1]   = 'ECDHE-RSA-AES256-GCM-SHA384'
           cSSLCiphers[2]   = 'ECDHE-RSA-CHACHA20-POLY1305'
           cSSLCiphers[3]   = 'ECDHE-RSA-AES128-GCM-SHA256' .       

    RUN intprg/int081b.p ( OUTPUT c-token ,
                           OUTPUT d-validade).  
   
    ASSIGN vURL        = OpenEdge.Net.URI:Parse("https://api.totalfor.com.br")
           vURL:Path   = 'BcoTotApiNissei/nissei/pub/fi/rempagador/v130'.   
   
    ASSIGN oLib = ClientLibraryBuilder:Build()
                                      :SetSSLProtocols(cSSLProtocols)
                                      :SetSSLCiphers(cSSLCiphers)
                                      :sslVerifyHost(FALSE)
                                      :ServerNameIndicator(vURL:host)
                                      :library.
        
    oRequest  = RequestBuilder:POST(vURL )
                :AddHeader("Content-Type", "application/json")
                :AddHeader("Authorization",'Bearer ' + c-token)
                :REQUEST.                                      

    ASSIGN oResponse = ClientBuilder:Build():UsingLibrary(oLib):Client:Execute(oRequest).
    
    .MESSAGE "status busca rempagador"  skip 
             oResponse:StatusCode
        VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
        
   IF oResponse:StatusCode < 200 OR oResponse:StatusCode >= 300 THEN     DO:
       oJsonObject = CAST(oResponse:Entity, JsonObject).
       c-mensagem = oJsonObject:getCharacter("token").
       
   end.
   ELSE DO:   
        
        oJsonObject = CAST(oResponse:Entity, JsonObject).
        //oJsonObject:WriteFile("u:\sarfaty\json_recebido_antecipacao.json") NO-ERROR.

        json_statusOperacoes = oJsonObject:GetJsonArray("statusOperacoes").

        DO idxStatus = 1 TO json_statusOperacoes:LENGTH:
        
            jsonStatus = json_statusOperacoes:GetJsonObject(idxStatus).
            jsonComprador = jsonStatus:getJsonObject("comprador").
            jsonfornecedores = jsonComprador:getJsonArray("fornecedores").
            
            //IF jsonStatus:Getinteger("tipoOperacao") <> 2 THEN NEXT.
               
           
            DO idxfornecedores = 1 TO jsonfornecedores:LENGTH:
            
                jsonfornecedor = jsonfornecedores:GetJsonObject(idxfornecedores).
                jsontitulos = jsonfornecedor:getJsonArray("titulos").
                DO idxtitulos = 1 TO jsontitulos:LENGTH:
                
                    jsontitulo = jsontitulos:GetJsonObject(idxtitulos).
                     
                    CREATE tt-antecipacoes.
                    ASSIGN tt-antecipacoes.tipoOperacao                = jsonStatus:GetInteger("tipoOperacao")
                           tt-antecipacoes.numeroOperacao              = jsonStatus:GetCharacter("numeroOperacao")
                           tt-antecipacoes.codigoAgenteFinanceiro      = jsonStatus:GetCharacter("codigoAgenteFinanceiro")
                           tt-antecipacoes.numeroInscricaocomprador    = jsonComprador:GetCharacter("numeroInscricao")
                           tt-antecipacoes.numeroInscricaofornecedor   = jsonFornecedor:GetCharacter("numeroInscricao")
                           tt-antecipacoes.codigoFornecedorERP         = jsonFornecedor:GetCharacter("codigoFornecedorERP")
                           tt-antecipacoes.tipoTitulo                  = jsonTitulo:GetCharacter("tipoTitulo")
                           tt-antecipacoes.codigoIdentificadorTitulo   = jsonTitulo:GetCharacter("codigoIdentificadorTitulo")
                           tt-antecipacoes.numeroNotaFiscal            = jsonTitulo:GetCharacter("numeroNotaFiscal")
                           tt-antecipacoes.tipoMoeda                   = jsonTitulo:GetCharacter("tipoMoeda")
                           tt-antecipacoes.valorSolicitadoTitulo       = jsonTitulo:GetDecimal("valorSolicitadoTitulo")
                           tt-antecipacoes.valorLiquidoAPagar          = jsonTitulo:GetDecimal("valorLiquidoAPagar")
                           tt-antecipacoes.dataEmissao                 = jsonTitulo:GetCharacter("dataEmissao")
                           tt-antecipacoes.dataVencimento              = jsonTitulo:GetCharacter("dataVencimento")
                           tt-antecipacoes.dtVencimentoAlongado        = jsonTitulo:GetCharacter("dtVencimentoAlongado")
                           tt-antecipacoes.valorTotalDescontado        = jsonTitulo:GetDecimal("valorTotalDescontado")
                           tt-antecipacoes.taxaDeJurosAplicada         = jsonTitulo:GetDecimal("taxaDeJurosAplicada")
                           tt-antecipacoes.chaveNfe                    = jsonTitulo:GetCharacter("chaveNfe")
                           tt-antecipacoes.origemChaveXML              = jsonTitulo:GetCharacter("origemChaveXML")
                           tt-antecipacoes.codigoOcorrencia            = jsonTitulo:GetCharacter("codigoOcorrencia")
                           tt-antecipacoes.nrCnpjPagador               = jsonTitulo:GetCharacter("nrCnpjPagador").      
                    
                    jsonajustes = jsontitulo:getJsonArray("ajustes").
                    
                    DO idxajustes = 1 TO jsonajustes:LENGTH:
                    
                        jsonajuste = jsonajustes:GetJsonObject(idxajustes).
                        
                        .MESSAGE "cria acerto" SKIP
                                jsonTitulo:GetCharacter("codigoIdentificadorTitulo")
                            VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
                        
                        CREATE tt-acertocontas.
                        ASSIGN tt-acertocontas.codigoFornecedorERP          = jsonFornecedor:GetCharacter("codigoFornecedorERP")     
                               tt-acertocontas.codigoIdentificadorTitulo    = jsonTitulo:GetCharacter("codigoIdentificadorTitulo")
                               tt-acertocontas.tipoAjuste                   = jsonajuste:GetCharacter("tipoAjuste")
                               tt-acertocontas.descricaoAjuste              = jsonajuste:GetCharacter("descricaoAjuste")
                               tt-acertocontas.valorAjuste                  = jsonajuste:GetDecimal("valorAjuste")
                               tt-acertocontas.numeroDocumentoAbatido       = jsonajuste:GetCharacter("numeroDocumentoAbatido")
                               .
                        
                    END.                 
                END.                   
            END.                 
        END.         
   END.        

END PROCEDURE.

PROCEDURE pi-confirma-antecipacoes:

    DEFINE INPUT PARAMETER p-tipoOperacao       AS INT NO-UNDO.
    DEFINE INPUT PARAMETER p-numeroOperacao     AS CHAR NO-UNDO.

    DEFINE VARIABLE oJson            AS JsonObject   NO-UNDO.
    DEFINE VARIABLE oJsonObject      AS JsonObject   NO-UNDO.
    DEFINE VARIABLE jcompradorArray  AS JsonArray   NO-UNDO.
    DEFINE VARIABLE jcomprador       AS JsonObject  NO-UNDO.
    DEFINE VARIABLE jfornecedorarray AS JsonArray   NO-UNDO.
    DEFINE VARIABLE jfornecedor      AS JsonObject  NO-UNDO.
    DEFINE VARIABLE jnotasarray      AS JsonArray   NO-UNDO.
    DEFINE VARIABLE jnota            AS Jsonobject  NO-UNDO.
    DEFINE VARIABLE d-agora          AS DATETIME        NO-UNDO.
    
    DEFINE VARIABLE oLib             AS IHttpClientLibrary NO-UNDO.
    DEFINE VARIABLE cSSLProtocols    AS CHARACTER          NO-UNDO EXTENT.
    DEFINE VARIABLE cSSLCiphers      AS CHARACTER          NO-UNDO EXTENT.  
    DEFINE VARIABLE vURL             AS URI           NO-UNDO.
    DEFINE VARIABLE oRequest         AS IHttpRequest NO-UNDO.
    DEFINE VARIABLE oResponse        AS IHttpResponse NO-UNDO.
    
    DEFINE VARIABLE l-aprova AS LOGICAL     NO-UNDO.
    
    FOR EACH tt-antecipacoes
        WHERE tt-antecipacoes.tipoOperacao = p-tipoOperacao: // Pendente confirma‡Æo
        
        IF tt-antecipacoes.tipoOperacao = 2 AND
           tt-antecipacoes.numeroOperacao <> p-numeroOperacao THEN NEXT.
        
        
        .MESSAGE "encontrou antecipacao"
            VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
        
        EMPTY TEMP-TABLE tt-titulos.
        ASSIGN l-aprova = YES.
        
        CREATE tt-titulos.
        ASSIGN tt-titulos.cod_estab          = SUBSTRING(tt-antecipacoes.codigoIdentificadorTitulo,1,3)   
               tt-titulos.cod_espec_docto    = SUBSTRING(tt-antecipacoes.codigoIdentificadorTitulo,4,2)
               tt-titulos.cod_ser_docto      = SUBSTRING(tt-antecipacoes.codigoIdentificadorTitulo,6,3)
               tt-titulos.cod_tit_ap         = SUBSTRING(tt-antecipacoes.numeroNotaFiscal,1,7)
               tt-titulos.cod_parcela        = SUBSTRING(tt-antecipacoes.numeroNotaFiscal,8,2).        
            
        FIND FIRST tit_ap NO-LOCK
            WHERE tit_ap.cod_estab          = tt-titulos.cod_estab         
              AND tit_ap.cod_espec_docto    = tt-titulos.cod_espec_docto
              AND tit_ap.cod_ser_docto      = tt-titulos.cod_ser_docto  
              AND tit_ap.cod_tit_ap         = tt-titulos.cod_tit_ap     
              AND tit_ap.cod_parcela        = tt-titulos.cod_parcela  NO-ERROR.
                         
                  
        IF AVAIL tit_ap THEN DO:   
        
            .MESSAGE "encontrou titulo"  SKIP tit_ap.cod_tit_ap
                VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
                
            //se tiverencontro de contas deve validar antecipa‡Æo tambem.            
            FOR EACH tt-acertocontas
                WHERE tt-acertocontas.codigoFornecedorERP       = tt-antecipacoes.codigoFornecedorERP
                  AND tt-acertocontas.codigoIdentificadorTitulo = tt-antecipacoes.codigoIdentificadorTitulo
                  :
                  
                  
                  .MESSAGE SUBSTRING(tt-acertocontas.numeroDocumentoAbatido,1,3)
                          SUBSTRING(tt-acertocontas.numeroDocumentoAbatido,4,2)
                          SUBSTRING(tt-acertocontas.numeroDocumentoAbatido,6,3)
                          SUBSTRING(tt-acertocontas.numeroDocumentoAbatido,9,15)
                          SUBSTRING(tt-acertocontas.numeroDocumentoAbatido,24,2)
                      VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
                FIND FIRST tit_acr NO-LOCK
                    WHERE tit_acr.cod_estab          = SUBSTRING(tt-acertocontas.numeroDocumentoAbatido,1,3)         
                      AND tit_acr.cod_espec_docto    = SUBSTRING(tt-acertocontas.numeroDocumentoAbatido,4,2)
                      AND tit_acr.cod_ser_docto      = SUBSTRING(tt-acertocontas.numeroDocumentoAbatido,6,3)  
                      AND tit_acr.cod_tit_acr        = SUBSTRING(tt-acertocontas.numeroDocumentoAbatido,9,15)    
                      AND tit_acr.cod_parcela        = SUBSTRING(tt-acertocontas.numeroDocumentoAbatido,24,2)  NO-ERROR.
                      
                      /* KML - Colocar regras aprova‡…o do titulo encontro de contas */
                      
                IF NOT AVAIL tit_acr THEN
                    ASSIGN l-aprova = NO.
                 
            END.
            
            
            /* KML - Colocar regras aprova‡Æo do titulo a pagar  */
            
            IF l-aprova THEN DO:
            
                .MESSAGE  "aprovou"
                    VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
            
                jfornecedorarray = NEW JsonArray().
                
                FIND FIRST ems5.fornecedor NO-LOCK
                    WHERE fornecedor.cdn_fornecedor = int(tt-antecipacoes.codigoFornecedorERP) NO-ERROR.
                    
                IF NOT AVAIL fornecedor THEN NEXT.                
                
                FIND FIRST estabelecimento NO-LOCK
                    WHERE estabelecimento.cod_estab = "973" NO-ERROR.  // sempre CD
                        
                jfornecedor = NEW JSONObject().  
                jfornecedor:ADD("tipoInscricao", "2").
                jfornecedor:ADD("numeroInscricao", fornecedor.cod_id_feder).
                jfornecedor:ADD("codigoFornecedorERP", string(fornecedor.cdn_fornecedor) ).
                jfornecedor:ADD("razaoSocial", fornecedor.nom_pessoa).
                
                jnotasarray = NEW JsonArray().

           
                jnota = NEW JsonObject().
                jnota:ADD("tipoTitulo"                  , "PAGAR")  .  
                jnota:ADD("codigoIdentificadorTitulo"   , tt-antecipacoes.codigoIdentificadorTitulo)  . 
                jnota:ADD("numeroNotaFiscal"            , tt-antecipacoes.numeroNotaFiscal)  . 
                jnota:ADD("tipoMoeda"                   , tt-antecipacoes.tipoMoeda)  . 
                jnota:ADD("valorSolicitadoTitulo"       , tt-antecipacoes.valorSolicitadoTitulo)  . 
                jnota:ADD("dataEmissao"                 , tt-antecipacoes.dataEmissao )  . 
                jnota:ADD("dataVencimento"              , tt-antecipacoes.dataVencimento)  . 
                JNOTA:ADD("codigoOcorrencia"            , "BD") .
                jnotasarray:ADD(jnota).

                jfornecedor:ADD("titulos",jnotasarray). 
                jfornecedorarray:ADD(jfornecedor).
                
                
                jcomprador = NEW JSONObject().  
                jcomprador:ADD("tipoInscricao", "2").
                jcomprador:ADD("numeroInscricao"     , estabelecimento.cod_id_feder).
                jcomprador:ADD("razaoSocial"        , estabelecimento.nom_pessoa ).
                jcomprador:ADD("codigoEmpresaERP"   , estabelecimento.cod_estab).
                jcomprador:ADD("fornecedores",jfornecedorarray).
                    
                oJsonObject = NEW JSONObject(). 
                
                oJsonObject:ADD("tipoOperacao", p-tipoOperacao).
                oJsonObject:ADD("comprador",jcomprador).
                //oJsonObject:WriteFile("u:\sarfaty\notas_object_confirma_antecipacao" + STRING(fornecedor.cdn_fornecedor) + STRING(tt-antecipacoes.numeroNotaFiscal) + ".json").
                
                EXTENT(cSSLProtocols) = 1.
                EXTENT(cSSLCiphers) = 3.     

                // Supported ciphers and protocols at https://documentation.progress.com/output/ua/OpenEdge_latest/gscsv/supported-protocols,-ciphers,-and-certificates-f.html# 
                ASSIGN cSSLProtocols[1] = 'TLSv1.2'
                       cSSLCiphers[1]   = 'ECDHE-RSA-AES256-GCM-SHA384'
                       cSSLCiphers[2]   = 'ECDHE-RSA-CHACHA20-POLY1305'
                       cSSLCiphers[3]   = 'ECDHE-RSA-AES128-GCM-SHA256' .       

                RUN intprg/int081b.p ( OUTPUT c-token ,
                                       OUTPUT d-validade).  
               
                ASSIGN vURL        = OpenEdge.Net.URI:Parse("https://api.totalfor.com.br")
                       vURL:Path   = 'BcoTotApiNissei/nissei/pub/fi/retpagador/v110'.   
               
                ASSIGN oLib = ClientLibraryBuilder:Build()
                                                  :SetSSLProtocols(cSSLProtocols)
                                                  :SetSSLCiphers(cSSLCiphers)
                                                  :sslVerifyHost(FALSE)
                                                  :ServerNameIndicator(vURL:host)
                                                  :library.
                    
                oRequest  = RequestBuilder:POST(vURL, oJsonObject )
                            :AddHeader("Content-Type", "application/json")
                            :AddHeader("Authorization",'Bearer ' + c-token)
                            :REQUEST.   
                            
                ASSIGN oResponse = ClientBuilder:Build():UsingLibrary(oLib):Client:Execute(oRequest).
                
                .MESSAGE "aprovou" oResponse:StatusCode
                    VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
                    
                IF oResponse:StatusCode = 200 THEN DO:
                
                    FOR EACH tt-acertocontas
                        WHERE tt-acertocontas.codigoFornecedorERP       = tt-antecipacoes.codigoFornecedorERP
                          AND tt-acertocontas.codigoIdentificadorTitulo = tt-antecipacoes.codigoIdentificadorTitulo:
                          
                        FIND FIRST tit_acr NO-LOCK
                            WHERE tit_acr.cod_estab          = SUBSTRING(tt-acertocontas.numeroDocumentoAbatido,1,3)         
                              AND tit_acr.cod_espec_docto    = SUBSTRING(tt-acertocontas.numeroDocumentoAbatido,4,2)
                              AND tit_acr.cod_ser_docto      = SUBSTRING(tt-acertocontas.numeroDocumentoAbatido,6,3)  
                              AND tit_acr.cod_tit_acr        = SUBSTRING(tt-acertocontas.numeroDocumentoAbatido,9,15)    
                              AND tit_acr.cod_parcela        = SUBSTRING(tt-acertocontas.numeroDocumentoAbatido,24,2)  NO-ERROR.
                        
                        IF AVAIL tit_acr THEN  DO:
                        
                            FIND FIRST ext_tit_acr_totalfor EXCLUSIVE-LOCK
                                WHERE ext_tit_acr_totalfor.cod_estab        = tit_acr.cod_estab
                                  AND ext_tit_acr_totalfor.num_id_tit_acr   = tit_acr.num_id_tit_acr NO-ERROR.
                                  
                            IF AVAIL ext_tit_acr_totalfor THEN DO:
                                ASSIGN ext_tit_acr_totalfor.dt-solicita-antec   = TODAY
                                       ext_tit_acr_totalfor.solic-antec         = TRUE. 
                                
                            END.
                                  
                            RELEASE ext_tit_acr_totalfor.
                            
                        END.
                            
                    END.
                    
                END.  
                
                
            END.        
        END.
        
    END.
    

END PROCEDURE.

PROCEDURE pi-substitui-titulo:

    EMPTY TEMP-TABLE tt-titulos.

    FOR EACH tt-antecipacoes
        WHERE tt-antecipacoes.tipoOperacao = 2
          AND tt-antecipacoes.codigoOcorrencia <> "03"  // Somente para testes
          : // Recebe aprova‡Æo da antecipa‡Æo
    
        
        .MESSAGE "antecipa‡oes" skip
                SUBSTRING(tt-antecipacoes.numeroNotaFiscal,1,7)
            VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
            
        CREATE tt-titulos.
        ASSIGN tt-titulos.cod_estab          = SUBSTRING(tt-antecipacoes.codigoIdentificadorTitulo,1,3)   
               tt-titulos.cod_espec_docto    = SUBSTRING(tt-antecipacoes.codigoIdentificadorTitulo,4,2)
               tt-titulos.cod_ser_docto      = SUBSTRING(tt-antecipacoes.codigoIdentificadorTitulo,6,3)
               tt-titulos.cod_tit_ap         = SUBSTRING(tt-antecipacoes.numeroNotaFiscal,1,7)
               tt-titulos.cod_parcela        = SUBSTRING(tt-antecipacoes.numeroNotaFiscal,8,2)
               tt-titulos.numeroOperacao     = tt-antecipacoes.numeroOperacao.

        .MESSAGE "apos criar tt-titulo" SKIP
                tt-titulos.cod_tit_ap
            VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
        
               
               /* Substituir titulos do contas a receber ou contas a pagar */ 
        FOR EACH tt-acertocontas
            WHERE tt-acertocontas.codigoFornecedorERP       = tt-antecipacoes.codigoFornecedorERP
              AND tt-acertocontas.codigoIdentificadorTitulo = tt-antecipacoes.codigoIdentificadorTitulo:
              
              
              
              .MESSAGE  SUBSTRING(tt-acertocontas.numeroDocumentoAbatido,1,3) 
                       SUBSTRING(tt-acertocontas.numeroDocumentoAbatido,4,2)
                       SUBSTRING(tt-acertocontas.numeroDocumentoAbatido,6,3) 
                       SUBSTRING(tt-acertocontas.numeroDocumentoAbatido,9,7) 
                       SUBSTRING(tt-acertocontas.numeroDocumentoAbatido,16,2)               
                  VIEW-AS ALERT-BOX INFORMATION BUTTONS OK. 
                  
                  
            FIND FIRST tit_acr NO-LOCK
                WHERE tit_acr.cod_estab          = SUBSTRING(tt-acertocontas.numeroDocumentoAbatido,1,3)         
                  AND tit_acr.cod_espec_docto    = SUBSTRING(tt-acertocontas.numeroDocumentoAbatido,4,2)
                  AND tit_acr.cod_ser_docto      = SUBSTRING(tt-acertocontas.numeroDocumentoAbatido,6,3)  
                  AND tit_acr.cod_tit_acr        = SUBSTRING(tt-acertocontas.numeroDocumentoAbatido,9,15)    
                  AND tit_acr.cod_parcela        = SUBSTRING(tt-acertocontas.numeroDocumentoAbatido,24,2)  NO-ERROR.
            
            IF AVAIL tit_acr THEN  DO:
            
                .MESSAGE "Altera esp‚cie contas a receber ACERTO CONTAS" SKIP 
                        tit_acr.cod_estab         SKIP
                        tit_acr.cod_espec_docto   SKIP
                        tit_acr.cod_ser_docto     SKIP
                        tit_acr.cod_tit_acr        SKIP
                        tit_acr.cod_parcela    
                    VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
    
                RUN intprg\int082c.p ( INPUT tit_acr.cod_estab ,
                                       INPUT tit_acr.num_id_tit_acr).   
                                
                            
            END.
            
        END.

        FOR EACH tt-titulos:

            .MESSAGE "antes alterar especie" skip  
                 tt-titulos.cod_estab  SKIP
                 tt-titulos.cod_ser_docto   SKIP
                 tt-titulos.cod_espec_docto SKIP
                 tt-titulos.cod_tit_ap SKIP 
                 tt-titulos.cod_parcela
            VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
        
            //DISP tt-titulos WITH WIDTH 200.
        
            FIND FIRST tit_ap NO-LOCK
                WHERE tit_ap.cod_estab          = tt-titulos.cod_estab         
                  AND tit_ap.cod_espec_docto    = tt-titulos.cod_espec_docto
                  AND tit_ap.cod_ser_docto      = tt-titulos.cod_ser_docto  
                  AND tit_ap.cod_tit_ap         = tt-titulos.cod_tit_ap     
                  AND tit_ap.cod_parcela        = tt-titulos.cod_parcela  NO-ERROR.
                             
                      
            IF AVAIL tit_ap THEN DO:
            
                

                .MESSAGE "altera especie contas a pagar TITILO APAGAR" skip
                        tit_ap.cod_estab         SKIP
                        tit_ap.cod_espec_docto   SKIP
                        tit_ap.cod_ser_docto     SKIP
                        tit_ap.cod_tit_ap        SKIP
                        tit_ap.cod_parcela    
                    VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
               
                IF tit_ap.val_sdo_tit_ap > 0 THEN DO:
                
                    RUN intprg\int082b.p ( INPUT tit_ap.cod_estab ,
                                           INPUT tit_ap.num_id_tit_ap).    
                END.

                RUN pi-confirma-antecipacoes (INPUT 2,
                                              INPUT tt-titulos.numeroOperacao) .       
                
            END.                                      
        END. 
    END.


END PROCEDURE.
