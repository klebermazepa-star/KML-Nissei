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

def temp-table tt-raw-digita
    field raw-digita as raw.

define temp-table tt-param no-undo
    field destino          as integer
    field arquivo          as char format "x(35)":U
    field usuario          as char format "x(12)":U
    field data-exec        as date
    field hora-exec        as integer
    field classifica       as integer
    field desc-classifica  as char format "x(40)":U
    field modelo           AS char format "x(35)":U
    /*Alterado 15/02/2005 - tech1007 - Criado campo l¢gico para verificar se o RTF foi habilitado*/
    field l-habilitaRtf    as LOG
    FIELD cod-fornec-ini   AS INT
    FIELD cod-fornec-fim   AS INT.
    /*Fim alteracao 15/02/2005*/
    

def input parameter raw-param as raw no-undo.
def input parameter table for tt-raw-digita.    
    
create tt-param.
raw-transfer raw-param to tt-param.  

FIND FIRST tt-param NO-ERROR.

DEFINE TEMP-TABLE comprador NO-UNDO
    FIELD tipoInscricao         AS CHAR
    FIELD numeroIncricao        AS CHAR
    FIELD razaoSocial           AS CHAR
    FIELD codigoEmpresaERP      AS CHAR .

DEFINE TEMP-TABLE fornecedores NO-UNDO
    FIELD tipoIncricao          AS CHAR
    FIELD numeroIncricao        AS CHAR
    FIELD razaosocial           AS CHAR
    FIELD codigoFornecedorERP   AS CHAR .
    
DEFINE TEMP-TABLE notas NO-UNDO
    FIELD cliente-fornecedor        AS INT
    FIELD r-ext_tit_acr_totalfor    AS ROWID
    FIELD codigoIdentificadorTitulo AS CHAR
    FIELD tipoTitulo                AS CHAR
    FIELD numeroNotaFiscal          AS CHAR
    FIELD serieNotaFiscal           AS CHAR
    FIELD tipoMoeda                 AS CHAR
    FIELD valorNominal              AS DEC
    FIELD saldoAtualizadoTitulo     AS DEC
    FIELD dataEmissao               AS DATE
    FIELD dataVencimento            AS DATE
    FIELD chaveAcessoNfe            AS CHAR
    INDEX idx-fornec
         cliente-fornecedor .
    
DEFINE VARIABLE c-token     AS CHARACTER   NO-UNDO.
DEFINE VARIABLE d-validade  AS DATETIME   NO-UNDO.
DEFINE VARIABLE c-mensagem AS CHARACTER   NO-UNDO.
DEFINE BUFFER bnotas FOR notas.

FUNCTION qtdMinutos RETURNS INT
    (d-data-ini as DATETIME,
     d-data-fim AS DATETIME):
     
    DEF VAR i-time-ini      AS INTEGER.
    DEF VAR i-time-fim      AS INTEGER.
    DEF VAR c-hora-ini      AS CHARACTER    LABEL "HR INI"      FORMAT "xx:xx:xx".
    DEF VAR c-hora-fim      AS CHARACTER    LABEL "HR FIM"      FORMAT "xx:xx:xx".    
    DEF VAR c-nr-hrs        AS CHARACTER    FORMAT "x(08)".
                                                                     
   
    ASSIGN c-hora-ini = replace(substring(string(d-data-ini),12,08), ":", "")
           c-hora-fim = replace(substring(string(d-data-fim),12,08), ":", "") .

    
    ASSIGN i-time-ini = (INT(SUBSTRING(c-hora-ini,1,2)) * 3600) + 
                (INT(SUBSTRING(c-hora-ini,3,2)) * 60  ) + 
                 INT(SUBSTRING(c-hora-ini,5,2))
           i-time-fim = (INT(SUBSTRING(c-hora-fim,1,2)) * 3600) + 
                (INT(SUBSTRING(c-hora-fim,3,2)) * 60  ) + 
                 INT(SUBSTRING(c-hora-fim,5,2)).
                     
    ASSIGN c-nr-hrs     = STRING(i-time-fim - i-time-ini,"hh:mm:ss") .

    RETURN int(SUBSTRING(c-nr-hrs,4,2)) + (int(SUBSTRING(c-nr-hrs,1,2)) * 60).      
    
    
end.
    
RUN p-gera-titulos-apagar.
RUN p-gera-titulos-encontro-contas.

PROCEDURE p-gera-titulos-encontro-contas:

    DEFINE VARIABLE oJson            AS JsonObject   NO-UNDO.
    DEFINE VARIABLE oJsonObject      AS JsonObject   NO-UNDO.
    DEFINE VARIABLE jcompradorArray  AS JsonArray   NO-UNDO.
    DEFINE VARIABLE jcomprador       AS JsonObject  NO-UNDO.
    DEFINE VARIABLE jfornecedorarray AS JsonArray   NO-UNDO.
    DEFINE VARIABLE jfornecedor      AS JsonObject  NO-UNDO.
    DEFINE VARIABLE jnotasarray      AS JsonArray   NO-UNDO.
    DEFINE VARIABLE jnota            AS Jsonobject  NO-UNDO.
    DEFINE VARIABLE d-agora          AS DATETIME        NO-UNDO.
    
    DEFINE VARIABLE CONT AS INTEGER     NO-UNDO.

    // Encontro de contas - ACR       
    
    FOR EACH ext_tit_acr_totalfor NO-LOCK
        WHERE ext_tit_acr_totalfor.integrado       = NO
          AND ext_tit_acr_totalfor.num_id_tit_acr  > 0 
          AND ext_tit_acr_totalfor.num_id_tit_ap   = 0 :
          
        FIND FIRST tit_acr NO-LOCK
            WHERE tit_acr.cod_estab         = ext_tit_acr_totalfor.cod_estab
              AND tit_acr.num_id_tit_acr    = ext_tit_acr_totalfor.num_id_tit_acr 
              AND tit_acr.cdn_cliente      >= tt-param.cod-fornec-ini  
              AND tit_acr.cdn_cliente      <= tt-param.cod-fornec-fim NO-ERROR.
              
        IF AVAIL tit_acr THEN DO:
        
            CREATE notas.
            ASSIGN notas.cliente-fornecedor         = tit_acr.cdn_cliente
                   notas.r-ext_tit_acr_totalfor     = ROWID(ext_tit_acr_totalfor)
                   notas.tipoTitulo                 = "RECEBER"
                   notas.codigoIdentificadorTitulo  = STRING(string(tit_acr.cod_estab, "999") + STRING( tit_acr.cod_espec_docto, "99") + string(tit_acr.cod_ser_docto, "999") + string(tit_acr.cod_tit_acr, "999999999999999") + string(tit_acr.cod_parcela, "99"))
                   notas.numeroNotaFiscal           = STRING(tit_acr.cod_tit_acr + tit_acr.cod_parcela)
                   notas.serieNotaFiscal            = tit_acr.cod_ser_docto
                   notas.tipoMoeda                  = "BRL"
                   notas.valorNominal               = tit_acr.val_origin_tit_acr 
                   notas.saldoAtualizadoTitulo      = tit_acr.val_sdo_tit_acr
                   notas.dataEmissao                = tit_acr.dat_emis_docto
                   notas.dataVencimento             = tit_acr.dat_vencto_tit_acr  + 420
                   notas.chaveAcessoNfe             = "". // Acordo comercial nÆo tem chave de acesso
                
        
            
        END.
                
    END.
     
    // Encontro de contas - APB   
    FOR EACH ext_tit_acr_totalfor NO-LOCK
        WHERE ext_tit_acr_totalfor.integrado       = NO
          AND ext_tit_acr_totalfor.num_id_tit_ap   > 0 
          AND ext_tit_acr_totalfor.num_id_tit_acr  = 0 :
          
        FIND FIRST tit_ap NO-LOCK
            WHERE tit_ap.cod_estab         = ext_tit_acr_totalfor.cod_estab
              AND tit_ap.num_id_tit_ap     = ext_tit_acr_totalfor.num_id_tit_ap 
              AND tit_ap.cdn_fornec       >= tt-param.cod-fornec-ini  
              AND tit_ap.cdn_fornec       <= tt-param.cod-fornec-fim NO-ERROR.
        IF AVAIL tit_ap THEN DO:
        
            CREATE notas.
            ASSIGN notas.cliente-fornecedor         = tit_ap.cdn_fornecedor
                   notas.r-ext_tit_acr_totalfor     = ROWID(ext_tit_acr_totalfor)
                   notas.tipoTitulo                 = "RECEBER"
                   notas.codigoIdentificadorTitulo  = STRING(string(tit_ap.cod_estab, "999") + STRING( tit_ap.cod_espec_docto, "99") + string(tit_ap.cod_ser_docto, "999") + string(tit_ap.cod_tit_ap, "999999999999999") + string(tit_ap.cod_parcela, "99"))
                   notas.numeroNotaFiscal           = STRING(tit_ap.cod_tit_ap + tit_ap.cod_parcela)
                   notas.serieNotaFiscal            = tit_ap.cod_ser_docto
                   notas.tipoMoeda                  = "BRL"
                   notas.valorNominal               = tit_ap.val_origin_tit_ap 
                   notas.saldoAtualizadoTitulo      = tit_ap.val_sdo_tit_ap
                   notas.dataEmissao                = tit_ap.dat_emis_docto
                   notas.dataVencimento             = tit_ap.dat_vencto_tit_ap // + 420
                   notas.chaveAcessoNfe             = "". // Acordo comercial nÆo tem chave de acesso
                
        
            
        END.
                
     END. 
     
     FOR EACH bnotas
        BREAK BY bnotas.cliente-fornecedor:
        
        IF FIRST-OF(bnotas.cliente-fornecedor) THEN
        DO: 
            jfornecedorarray = NEW JsonArray().
            
            FIND FIRST ems5.fornecedor NO-LOCK
                WHERE fornecedor.cdn_fornecedor = bnotas.cliente-fornecedor NO-ERROR.
                
            IF NOT AVAIL fornecedor THEN NEXT.                
            
            FIND FIRST estabelecimento NO-LOCK
                WHERE estabelecimento.cod_estab = "973" NO-ERROR.  // sempre CD
                    
            jfornecedor = NEW JSONObject().  
            jfornecedor:ADD("tipoInscricao", "02").
            jfornecedor:ADD("numeroInscricao", fornecedor.cod_id_feder).
            jfornecedor:ADD("codigoFornecedorERP", string(fornecedor.cdn_fornecedor) ).
            jfornecedor:ADD("razaoSocial", fornecedor.nom_pessoa).
            
            jnotasarray = NEW JsonArray().
            
            FOR EACH notas
                WHERE notas.cliente-fornecedor = bnotas.cliente-fornecedor:
           
                jnota = NEW JsonObject().
                jnota:ADD("tipoTitulo"                  , notas.tipoTitulo)  .  
                jnota:ADD("codigoIdentificadorTitulo"   , notas.codigoIdentificadorTitulo)  . 
                jnota:ADD("numeroNotaFiscal"            , notas.numeroNotaFiscal)  . 
                jnota:ADD("serieNotaFiscal"             , notas.serieNotaFiscal)  . 
                jnota:ADD("tipoMoeda"                   , notas.tipoMoeda)  . 
                jnota:ADD("valorNominalTitulo"          , notas.valorNominal)  . 
                jnota:ADD("saldoAtualizadoTitulo"       , notas.saldoAtualizadoTitulo)  . 
                jnota:ADD("dataEmissao"                 , notas.dataEmissao)  . 
                jnota:ADD("dataVencimento"              , notas.dataVencimento)  . 
                JNOTA:ADD("chaveAcessoNfe"              , notas.chaveAcessoNfe) .
                jnotasarray:ADD(jnota).

                
                                    
            END.
            jfornecedor:ADD("notas",jnotasarray). 
            jfornecedorarray:ADD(jfornecedor).
            
            
            jcomprador = NEW JSONObject().  
            jcomprador:ADD("tipoInscricao", "02").
            jcomprador:ADD("numeroInscricao"     , estabelecimento.cod_id_feder).
            jcomprador:ADD("razaoSocial"        , estabelecimento.nom_pessoa ).
            jcomprador:ADD("codigoEmpresaERP"   , estabelecimento.cod_estab).
            jcomprador:ADD("fornecedores",jfornecedorarray).
                
            oJsonObject = NEW JSONObject(). 
            oJsonObject:ADD("comprador",jcomprador).
           // oJsonObject:WriteFile("u:\sarfaty\notas_object_encontro_contas" + STRING(bnotas.cliente-fornecedor) + ".json").

            d-agora = NOW.
            
            IF c-token = "" OR
                qtdMinutos( d-agora, d-validade) >= 5 THEN DO:                         

                RUN intprg/int081b.p ( OUTPUT c-token ,
                OUTPUT d-validade).  
                
            END.
            
            RUN intprg/int081c.p ( INPUT c-token ,
                                  INPUT oJsonObject ,
                                  OUTPUT c-mensagem).
            
            IF substring(c-mensagem,1,2) = "OK" THEN
            DO:            
                FOR EACH notas
                    WHERE notas.cliente-fornecedor = bnotas.cliente-fornecedor:
                    
                    FIND FIRST ext_tit_acr_totalfor EXCLUSIVE-LOCK
                        WHERE rowid(ext_tit_acr_totalfor) = notas.r-ext_tit_acr_totalfor  NO-ERROR.
                        
                    IF AVAIL ext_tit_acr_totalfor THEN DO:
                        ASSIGN ext_tit_acr_totalfor.integrado       = YES
                               ext_tit_acr_totalfor.dt-integracao   = TODAY.
                    END.
                    RELEASE ext_tit_acr_totalfor.
                END.
                
            END.

            
        END.
        
    END.
    
    EMPTY TEMP-TABLE notas.
   
END.
    
PROCEDURE p-gera-titulos-apagar:

   DEFINE VARIABLE oJson            AS JsonObject   NO-UNDO.
   DEFINE VARIABLE oJsonObject      AS JsonObject   NO-UNDO.
   DEFINE VARIABLE jcompradorArray  AS JsonArray   NO-UNDO.
   DEFINE VARIABLE jcomprador       AS JsonObject  NO-UNDO.
   DEFINE VARIABLE jfornecedorarray AS JsonArray   NO-UNDO.
   DEFINE VARIABLE jfornecedor      AS JsonObject  NO-UNDO.
   DEFINE VARIABLE jnotasarray      AS JsonArray   NO-UNDO.
   DEFINE VARIABLE jnota            AS Jsonobject  NO-UNDO.
   DEFINE VARIABLE d-agora          AS DATETIME        NO-UNDO.
   
   DEFINE VARIABLE CONT AS INTEGER     NO-UNDO.   
       
    FOR FIRST estabelecimento NO-LOCK
        WHERE estabelecimento.cod_estab = "973":

        FOR EACH ems5.fornecedor  NO-LOCK // Colocar tabela dos fornecedores ativos (UPC) 
                WHERE fornecedor.cdn_fornecedor     >= tt-param.cod-fornec-ini
                  AND fornecedor.cdn_fornecedor     <= tt-param.cod-fornec-fim:  
            
            // Colocar tabela extenî–o da tit_ap a ser alimentada por trigger de titulos alterados
            FOR EACH tit_ap
                WHERE tit_ap.cod_espec_docto    = "NF"
                  AND tit_ap.cod_empresa        = "1" /* Apenas Nissei */ 
                  AND tit_ap.cdn_fornecedor     = fornecedor.cdn_fornecedor
                  AND tit_ap.cod_estab          = estabelecimento.cod_estab
                  AND tit_ap.val_sdo_tit_ap     > 0
                  AND tit_ap.dat_vencto_tit_ap  >= TODAY
                  BREAK BY tit_ap.cod_estab
                        BY tit_ap.cdn_fornecedor :   
                        
                FIND FIRST docum-est NO-LOCK
                    WHERE docum-est.nro-docto       = tit_ap.cod_tit_ap
                      AND docum-est.cod-emitente    = tit_ap.cdn_fornecedor
                      AND docum-est.serie-docto     = tit_ap.cod_ser_docto
                      AND docum-est.cod-estabel     = tit_ap.cod_estab NO-ERROR.
                
                
                CREATE notas.
                ASSIGN notas.tipoTitulo                 = "PAGAR"
                       notas.codigoIdentificadorTitulo  = STRING(string(tit_ap.cod_estab, "999") + STRING( tit_ap.cod_espec_docto, "99") + string(tit_ap.cod_ser_docto, "999") + string(tit_ap.cod_tit_ap, "999999999999999") + string(tit_ap.cod_parcela, "99"))
                       notas.numeroNotaFiscal           = STRING(tit_ap.cod_tit_ap + tit_ap.cod_parcela)
                       notas.serieNotaFiscal            = tit_ap.cod_ser_docto
                       notas.tipoMoeda                  = "BRL"
                       notas.valorNominal               = tit_ap.val_origin_tit_ap 
                       notas.saldoAtualizadoTitulo      = tit_ap.val_sdo_tit_ap
                       notas.dataEmissao                = tit_ap.dat_emis_docto
                       notas.dataVencimento             = tit_ap.dat_vencto_tit_ap 
                       notas.chaveAcessoNfe             = IF AVAIL docum-est THEN docum-est.cod-chave-aces-nf-eletro ELSE "".
                
                IF LAST-OF(tit_ap.cdn_fornecedor) THEN DO:   
                
                    jfornecedorarray = NEW JsonArray().
                
                    jfornecedor = NEW JSONObject().  
                    jfornecedor:ADD("tipoInscricao", "02").
                    jfornecedor:ADD("numeroInscricao", fornecedor.cod_id_feder).
                    jfornecedor:ADD("codigoFornecedorERP", string(fornecedor.cdn_fornecedor) ).
                    jfornecedor:ADD("razaoSocial", fornecedor.nom_pessoa).
                    
                    jnotasarray = NEW JsonArray().
                    
                    FOR EACH notas:
                   
                        jnota = NEW JsonObject().
                        jnota:ADD("tipoTitulo"                  , notas.tipoTitulo)  .  
                        jnota:ADD("codigoIdentificadorTitulo"   , notas.codigoIdentificadorTitulo)  . 
                        jnota:ADD("numeroNotaFiscal"            , notas.numeroNotaFiscal)  . 
                        jnota:ADD("serieNotaFiscal"             , notas.serieNotaFiscal)  . 
                        jnota:ADD("tipoMoeda"                   , notas.tipoMoeda)  . 
                        jnota:ADD("valorNominalTitulo"          , notas.valorNominal)  . 
                        jnota:ADD("saldoAtualizadoTitulo"       , notas.saldoAtualizadoTitulo)  . 
                        jnota:ADD("dataEmissao"                 , notas.dataEmissao)  . 
                        jnota:ADD("dataVencimento"              , notas.dataVencimento)  . 
                        JNOTA:ADD("chaveAcessoNfe"              , notas.chaveAcessoNfe) .
                        jnotasarray:ADD(jnota).
 
                        
                                            
                    END.
                    jfornecedor:ADD("notas",jnotasarray). 
                    jfornecedorarray:ADD(jfornecedor).
                    
                    
                    jcomprador = NEW JSONObject().  
                    jcomprador:ADD("tipoInscricao", "02").
                    jcomprador:ADD("numeroInscricao"     , estabelecimento.cod_id_feder).
                    jcomprador:ADD("razaoSocial"        , estabelecimento.nom_pessoa ).
                    jcomprador:ADD("codigoEmpresaERP"   , estabelecimento.cod_estab).
                    jcomprador:ADD("fornecedores",jfornecedorarray).
                        
                    oJsonObject = NEW JSONObject(). 
                    oJsonObject:ADD("comprador",jcomprador).
                    //oJsonObject:WriteFile("u:\sarfaty\notas_carga_apb" + STRING(tit_ap.cdn_fornecedor) + ".json").

                    d-agora = NOW.
                    
                    IF c-token = "" OR
                        qtdMinutos( d-agora, d-validade) >= 15 THEN DO:                         
            
                        RUN intprg/int081b.p ( OUTPUT c-token ,
                        OUTPUT d-validade).

                        
                    END.
                    
                    CURRENT-LANGUAGE = CURRENT-LANGUAGE.
                    RUN intprg/int081c.p ( INPUT c-token ,
                                          INPUT oJsonObject ,
                                          OUTPUT c-mensagem).
                                          
                                          
                    .MESSAGE c-mensagem
                        VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
                                     
                    FOR EACH notas:
                        DELETE notas.
                    END.
                           
                           
                    
                END.                       
                
                  
            END.
        END.
        
    END. 


END.




