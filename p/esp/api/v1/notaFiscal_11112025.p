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

{utp/ut-api.i}
{utp/ut-api-action.i pi-cancelamento      POST  /cancelamento/~* }
{utp/ut-api-action.i pi-recebimento       POST  /recebimento/~* }
{utp/ut-api-action.i pi-consulta-pedido   POST  /consultaPedido/~* }
{utp/ut-api-action.i pi-gera-faturamento  POST  /~* }
{utp/ut-api-action.i pi-busca-danfe-xml   GET   /danfeXML/~* }


{utp/ut-api-notfound.i}

{method/dbotterr.i} /*RowErrors*/

def new global shared var v_cdn_empres_usuar  LIKE ems2mult.empresa.ep-codigo no-undo.
DEFINE VARIABLE c-mensagem AS CHARACTER   NO-UNDO.


DEF TEMP-TABLE pedido NO-UNDO
    FIELD pedido            AS CHAR
    FIELD loja              AS CHAR
    FIELD cnpj-loja         AS CHAR
    FIELD data              AS DATE
    FIELD data_entrega      AS DATE
    FIELD nome              AS CHAR
    FIELD comissao          AS DEC                                  
    FIELD cnpj-cpf-cliente  AS CHAR
    FIELD cnpj-representante AS CHAR
    FIELD natureza-cliente  AS CHAR
    FIELD inscricao_federal AS CHAR
    FIELD cep               AS CHAR
    FIELD tipo_endereco     AS CHAR
    FIELD endereco          AS CHAR
    FIELD numero            AS INT
    FIELD complemento       AS CHAR
    FIELD bairro            AS CHAR
    FIELD cidade            AS CHAR
    FIELD cod-ibge          AS CHAR
    FIELD estado            AS CHAR
    FIELD pais              AS CHAR
    FIELD referencia        AS CHAR
    FIELD total_bruto       AS DEC
    FIELD total_desconto    AS DEC
    FIELD desconto_total    AS DEC
    FIELD frete             AS DEC
    FIELD total_liquido     AS DEC
    FIELD total_geral       AS DEC
    FIELD telefone          AS CHAR
    FIELD celular           AS CHAR
    FIELD email_boleto      AS CHAR
    FIELD observacoes       AS CHAR
    FIELD tipo_pedido       AS INT
    FIELD tipo_entrega      AS CHAR
    FIELD cnpj-transp       AS CHAR.

DEF TEMP-TABLE itens NO-UNDO
    FIELD pedido           AS CHAR
    FIELD item             AS CHAR
    FIELD ean              AS CHAR
    FIELD quantidade       AS DEC
    FIELD preco_bruto      AS DEC
    FIELD desconto         AS DEC
    FIELD preco_liquido    AS DEC
    FIELD total_item       AS DEC
    FIELD item_pbm         AS CHAR
    FIELD preco_bruto_loja AS DEC
    FIELD desconto_loja    AS DEC
    FIELD preco_bruto_pbm  AS DEC
    FIELD desconto_pbm     AS DEC
    FIELD valor_subsidio   AS DEC
    FIELD lote             AS CHAR
    FIELD validade         AS DATE
    FIELD observacao       AS CHAR.

DEF TEMP-TABLE cond-pagto NO-UNDO
    FIELD pedido         AS CHAR
    FIELD cond-pagto     AS CHAR
    FIELD vencim         AS DATE
    FIELD adm-cartao     AS INT
    FIELD nsu-admin      AS DEC
    FIELD autorizacao    AS CHAR
    FIELD taxa-admin     AS DEC
    FIELD valor          AS DEC
    FIELD parcela        AS DEC
    FIELD cod-adquirente AS DEC
    FIELD origem-pagto   AS CHAR
    FIELD CNPJ_CONVENIO  AS CHAR.

DEF TEMP-TABLE tt-nota-fiscal-rest NO-UNDO
    FIELD nr-nota   AS CHAR
    FIELD serie     AS CHAR
    FIELD cnpj-loja AS CHAR.
    
    
DEF TEMP-TABLE nota-fiscal-cancela NO-UNDO
    FIELD nr-nota   AS INT
    FIELD serie     AS CHAR
    FIELD cnpj-loja AS CHAR.    

/***** TTs int110 ******/
DEFINE TEMP-TABLE tt-cliente NO-UNDO
    FIELD CNPJ          AS CHAR
    FIELD nome          AS CHAR
    FIELD natureza      AS INT // 1 - Fisica ** 2 - Juridica
    FIELD nome-abrev    AS CHAR
    FIELD ins-estadual  AS CHAR
    FIELD cep           AS CHAR 
    FIELD endereco      AS CHAR
    FIELD numero        AS CHAR
    FIELD complemento   AS CHAR
    FIELD bairro        AS CHAR
    FIELD cidade        AS CHAR
    FIELD cod-ibge      AS CHAR
    FIELD estado        AS CHAR
    FIELD pais          AS CHAR
    FIELD telefone      AS CHAR
    FIELD email         AS CHAR.

DEFINE TEMP-TABLE tt-pedido NO-UNDO
    FIELD pedcodigo         AS DEC
    FIELD DtEmissao         AS DATE
    FIELD DtEntrega         AS DATE
    FIELD cnpj_estab        AS CHAR 
    FIELD cnpj_emitente     AS CHAR
    FIELD valorTotal        AS DEC
    FIELD desconto          AS DEC
    FIELD frete             AS DEC
    FIELD observacao        AS CHAR
    FIELD tipopedido        AS INT
    FIELD cnpj_transp       AS CHAR
    FIELD comissao              AS DEC
    FIELD cnpj-representante    AS CHAR .

DEFINE TEMP-TABLE tt-consulta-pedido NO-UNDO
    FIELD pedido            AS CHAR
    FIELD cnpj-cpf-cliente  AS CHAR.

DEFINE TEMP-TABLE tt-pedido-item NO-UNDO
    FIELD cod-item          AS CHAR
    FIELD quantidade        AS DEC
    FIELD valor-unit        AS DEC
    FIELD desconto          AS DEC
    FIELD valor-liq         AS DEC
    FIELD preco-bruto       AS DEC
    FIELD valor-total       AS DEC
    FIELD lote              AS CHAR
    FIELD dt-validade       AS DATE
    FIELD observacao        AS CHAR.

DEFINE TEMP-TABLE tt-cond-pagto-esp NO-UNDO
    FIELD cond-pagto    AS CHAR
    FIELD dt-vencto     AS DATE
    FIELD vl-parcela    AS DEC
    FIELD parcela       AS DEC
    FIELD nsu           AS CHAR
    FIELD autorizacao   AS CHAR
    FIELD adquirente    AS CHAR
    FIELD origem-pagto  AS CHAR
    FIELD CNPJ_CONVENIO AS CHAR.

DEFINE TEMP-TABLE tt-nota-fiscal NO-UNDO
    FIELD l-gerada      AS LOGICAL
    FIELD desc-erro     AS CHAR
    FIELD cod-estabel   LIKE nota-fiscal.cod-estabel
    FIELD serie         LIKE nota-fiscal.serie
    FIELD nr-nota-fis   LIKE nota-fiscal.nr-nota-fis
    FIELD chave-acesso  LIKE nota-fiscal.cod-chave-aces-nf-eletro.


DEFINE TEMP-TABLE Recebimento NO-UNDO
   FIELD NR-NOTA        AS CHAR
   FIELD TIPO-DOCUMENTO AS CHAR
   FIELD SERIE          AS CHAR
   FIELD CNPJ           AS CHAR
   FIELD XMLNota        AS CLOB.


define temp-table tt-param-int500 no-undo
    field destino          as integer
    field arquivo          as char format "x(35)":U
    field usuario          as char format "x(12)":U
    field data-exec        as date
    field hora-exec        as integer
    field classifica       as integer
    field desc-classifica  as char format "x(40)":U
    field modelo           AS char format "x(35)":U
    field l-habilitaRtf    as LOG
    FIELD dt-trans-ini     LIKE docum-est.dt-trans
    FIELD dt-trans-fin     LIKE docum-est.dt-trans
    FIELD i-nro-docto-ini  LIKE docum-est.nro-docto
    FIELD i-nro-docto-fin  LIKE docum-est.nro-docto
    FIELD i-cod-emit-ini   LIKE docum-est.cod-emitente
    FIELD i-cod-emit-fin   LIKE docum-est.cod-emitente.
    
define temp-table tt-param-int112 no-undo
    field destino          as integer
    field arquivo          as char format "x(35)"
    field usuario          as char format "x(12)"
    field data-exec        as date
    field hora-exec        as integer
    field classifica       as integer
    field desc-classifica  as char format "x(40)"
    field cnpj_origem      as CHAR
    field nro-docto        as INTEGER
    field serie-docto      as char.
    
define temp-table tt-param-int072 no-undo
    field destino          as integer
    field arquivo          as char format "x(35)"
    field usuario          as char format "x(12)"
    field data-exec        as date
    field hora-exec        as integer
    field classifica       as integer
    field desc-classifica  as char format "x(40)"
    field cod-emitente-fim as integer
    field cod-emitente-ini as integer
    field cod-estabel-fim  as char
    field cod-estabel-ini  as char
    field dt-emis-nota-fim as date
    field dt-emis-nota-ini as date
    field dt-trans-fim     as date
    field dt-trans-ini     as date
    field nro-docto-fim    as char
    field nro-docto-ini    as char
    field serie-docto-fim  as char
    field serie-docto-ini  as char.    
    
DEF TEMP-TABLE tt-INT_DS_NOTA_ENTRADA NO-UNDO SERIALIZE-NAME "INT_DS_NOTA_ENTRADA"
    FIELD TIPO_MOVTO               LIKE INT_DS_NOTA_ENTRADA.TIPO_MOVTO              
    FIELD DT_GERACAO               LIKE INT_DS_NOTA_ENTRADA.DT_GERACAO              
    FIELD HR_GERACAO               LIKE INT_DS_NOTA_ENTRADA.HR_GERACAO              
    FIELD SITUACAO                 LIKE INT_DS_NOTA_ENTRADA.SITUACAO                
    FIELD NEN_CNPJ_ORIGEM_S        LIKE INT_DS_NOTA_ENTRADA.NEN_CNPJ_ORIGEM_S       
    FIELD NEN_CNPJ_DESTINO_S       LIKE INT_DS_NOTA_ENTRADA.NEN_CNPJ_DESTINO_S      
    FIELD NEN_NOTAFISCAL_N         LIKE INT_DS_NOTA_ENTRADA.NEN_NOTAFISCAL_N        
    FIELD NEN_SERIE_S              LIKE INT_DS_NOTA_ENTRADA.NEN_SERIE_S             
    FIELD NEN_DATAEMISSAO_D        LIKE INT_DS_NOTA_ENTRADA.NEN_DATAEMISSAO_D       
    FIELD NEN_CFOP_N               LIKE INT_DS_NOTA_ENTRADA.NEN_CFOP_N              
    FIELD NEN_QUANTIDADE_N         LIKE INT_DS_NOTA_ENTRADA.NEN_QUANTIDADE_N        
    FIELD NEN_DESCONTO_N           LIKE INT_DS_NOTA_ENTRADA.NEN_DESCONTO_N          
    FIELD NEN_BASEICMS_N           LIKE INT_DS_NOTA_ENTRADA.NEN_BASEICMS_N          
    FIELD NEN_VALORICMS_N          LIKE INT_DS_NOTA_ENTRADA.NEN_VALORICMS_N         
    FIELD NEN_BASEDIFERIDO_N       LIKE INT_DS_NOTA_ENTRADA.NEN_BASEDIFERIDO_N      
    FIELD NEN_BASEISENTA_N         LIKE INT_DS_NOTA_ENTRADA.NEN_BASEISENTA_N        
    FIELD NEN_BASEIPI_N            LIKE INT_DS_NOTA_ENTRADA.NEN_BASEIPI_N           
    FIELD NEN_VALORIPI_N           LIKE INT_DS_NOTA_ENTRADA.NEN_VALORIPI_N          
    FIELD NEN_BASEST_N             LIKE INT_DS_NOTA_ENTRADA.NEN_BASEST_N            
    FIELD NEN_ICMSST_N             LIKE INT_DS_NOTA_ENTRADA.NEN_ICMSST_N            
    FIELD NEN_VALORTOTALPRODUTOS_N LIKE INT_DS_NOTA_ENTRADA.NEN_VALORTOTALPRODUTOS_N
    FIELD NEN_OBSERVACAO_S         LIKE INT_DS_NOTA_ENTRADA.NEN_OBSERVACAO_S        
    FIELD NEN_CHAVEACESSO_S        LIKE INT_DS_NOTA_ENTRADA.NEN_CHAVEACESSO_S       
    FIELD NEN_FRETE_N              LIKE INT_DS_NOTA_ENTRADA.NEN_FRETE_N             
    FIELD NEN_SEGURO_N             LIKE INT_DS_NOTA_ENTRADA.NEN_SEGURO_N            
    FIELD NEN_DESPESAS_N           LIKE INT_DS_NOTA_ENTRADA.NEN_DESPESAS_N          
    FIELD NEN_MODALIDADE_FRETE_N   LIKE INT_DS_NOTA_ENTRADA.NEN_MODALIDADE_FRETE_N  
    FIELD NEN_CONFERIDA_N          LIKE INT_DS_NOTA_ENTRADA.NEN_CONFERIDA_N         
    FIELD PED_CODIGO_N             LIKE INT_DS_NOTA_ENTRADA.PED_CODIGO_N   
    FIELD PED_PROCFIT              LIKE INT_DS_NOTA_ENTRADA.PED_PROCFIT 
    FIELD NEN_HORAMOVIMENTACAO_S   LIKE INT_DS_NOTA_ENTRADA.NEN_HORAMOVIMENTACAO_S  
    FIELD TIPO_NOTA                LIKE INT_DS_NOTA_ENTRADA.TIPO_NOTA.


DEF TEMP-TABLE tt-INT_DS_NOTA_ENTRADA_PRODUT NO-UNDO SERIALIZE-NAME "INT_DS_NOTA_ENTRADA_PRODUT"
    FIELD CEST                   LIKE INT_DS_NOTA_ENTRADA_PRODUT.CEST                   
    FIELD NEN_CNPJ_ORIGEM_S      LIKE INT_DS_NOTA_ENTRADA_PRODUT.NEN_CNPJ_ORIGEM_S      
    FIELD NEN_NOTAFISCAL_N       LIKE INT_DS_NOTA_ENTRADA_PRODUT.NEN_NOTAFISCAL_N       
    FIELD NEN_SERIE_S            LIKE INT_DS_NOTA_ENTRADA_PRODUT.NEN_SERIE_S            
    FIELD NEP_SEQUENCIA_N        LIKE INT_DS_NOTA_ENTRADA_PRODUT.NEP_SEQUENCIA_N        
    FIELD NEP_PRODUTO_N          LIKE INT_DS_NOTA_ENTRADA_PRODUT.NEP_PRODUTO_N          
    FIELD NEP_LOTE_S             LIKE INT_DS_NOTA_ENTRADA_PRODUT.NEP_LOTE_S             
    FIELD NEP_QUANTIDADE_N       LIKE INT_DS_NOTA_ENTRADA_PRODUT.NEP_QUANTIDADE_N       
    FIELD NEN_CFOP_N             LIKE INT_DS_NOTA_ENTRADA_PRODUT.NEN_CFOP_N             
    FIELD NEP_VALORBRUTO_N       LIKE INT_DS_NOTA_ENTRADA_PRODUT.NEP_VALORBRUTO_N       
    FIELD NEP_VALORDESCONTO_N    LIKE INT_DS_NOTA_ENTRADA_PRODUT.NEP_VALORDESCONTO_N    
    FIELD NEP_BASEICMS_N         LIKE INT_DS_NOTA_ENTRADA_PRODUT.NEP_BASEICMS_N         
    FIELD NEP_VALORICMS_N        LIKE INT_DS_NOTA_ENTRADA_PRODUT.NEP_VALORICMS_N        
    FIELD NEP_BASEDIFERIDO_N     LIKE INT_DS_NOTA_ENTRADA_PRODUT.NEP_BASEDIFERIDO_N     
    FIELD NEP_BASEISENTA_N       LIKE INT_DS_NOTA_ENTRADA_PRODUT.NEP_BASEISENTA_N       
    FIELD NEP_BASEIPI_N          LIKE INT_DS_NOTA_ENTRADA_PRODUT.NEP_BASEIPI_N          
    FIELD NEP_VALORIPI_N         LIKE INT_DS_NOTA_ENTRADA_PRODUT.NEP_VALORIPI_N         
    FIELD NEP_ICMSST_N           LIKE INT_DS_NOTA_ENTRADA_PRODUT.NEP_ICMSST_N           
    FIELD NEP_BASEST_N           LIKE INT_DS_NOTA_ENTRADA_PRODUT.NEP_BASEST_N           
    FIELD NEP_VALORLIQUIDO_N     LIKE INT_DS_NOTA_ENTRADA_PRODUT.NEP_VALORLIQUIDO_N     
    FIELD NEP_PERCENTUALICMS_N   LIKE INT_DS_NOTA_ENTRADA_PRODUT.NEP_PERCENTUALICMS_N   
    FIELD NEP_PERCENTUALIPI_N    LIKE INT_DS_NOTA_ENTRADA_PRODUT.NEP_PERCENTUALIPI_N    
    FIELD NEP_PERCENTUALPIS_N    LIKE INT_DS_NOTA_ENTRADA_PRODUT.NEP_PERCENTUALPIS_N    
    FIELD NEP_PERCENTUALCOFINS_N LIKE INT_DS_NOTA_ENTRADA_PRODUT.NEP_PERCENTUALCOFINS_N 
    FIELD NEP_VALORDESPESA_N     LIKE INT_DS_NOTA_ENTRADA_PRODUT.NEP_VALORDESPESA_N     
    FIELD NEP_BASEPIS_N          LIKE INT_DS_NOTA_ENTRADA_PRODUT.NEP_BASEPIS_N          
    FIELD NEP_VALORPIS_N         LIKE INT_DS_NOTA_ENTRADA_PRODUT.NEP_VALORPIS_N         
    FIELD NEP_BASECOFINS_N       LIKE INT_DS_NOTA_ENTRADA_PRODUT.NEP_BASECOFINS_N       
    FIELD NEP_VALORCOFINS_N      LIKE INT_DS_NOTA_ENTRADA_PRODUT.NEP_VALORCOFINS_N      
    FIELD PED_CODIGO_N           LIKE INT_DS_NOTA_ENTRADA_PRODUT.PED_CODIGO_N           
    FIELD NEP_CSTA_N             LIKE INT_DS_NOTA_ENTRADA_PRODUT.NEP_CSTA_N             
    FIELD NEP_CSTB_ICM_N         LIKE INT_DS_NOTA_ENTRADA_PRODUT.NEP_CSTB_ICM_N         
    FIELD NEP_CSTB_IPI_N         LIKE INT_DS_NOTA_ENTRADA_PRODUT.NEP_CSTB_IPI_N         
    FIELD NEP_REDUTORBASEICMS_N  LIKE INT_DS_NOTA_ENTRADA_PRODUT.NEP_REDUTORBASEICMS_N  
    FIELD ALTERNATIVO_FORNECEDOR LIKE INT_DS_NOTA_ENTRADA_PRODUT.ALTERNATIVO_FORNECEDOR 
    FIELD NEP_VALOR_OUTRAS_N     LIKE INT_DS_NOTA_ENTRADA_PRODUT.NEP_VALOR_OUTRAS_N     
    FIELD NEP_VALOR_ICMS_DES_N   LIKE INT_DS_NOTA_ENTRADA_PRODUT.NEP_VALOR_ICMS_DES_N   
    FIELD NPX_DESCRICAOPRODUTO_S LIKE INT_DS_NOTA_ENTRADA_PRODUT.NPX_DESCRICAOPRODUTO_S 
    FIELD NPX_EAN_N              LIKE INT_DS_NOTA_ENTRADA_PRODUT.NPX_EAN_N              
    FIELD NEP_NCM_N              LIKE INT_DS_NOTA_ENTRADA_PRODUT.NEP_NCM_N              
    FIELD NEP_MODBCICMS_N        LIKE INT_DS_NOTA_ENTRADA_PRODUT.NEP_MODBCICMS_N        
    FIELD NEP_MODBCST_N          LIKE INT_DS_NOTA_ENTRADA_PRODUT.NEP_MODBCST_N          
    FIELD NEP_PMVAST_N           LIKE INT_DS_NOTA_ENTRADA_PRODUT.NEP_PMVAST_N           
    FIELD NEP_CENQ_N             LIKE INT_DS_NOTA_ENTRADA_PRODUT.NEP_CENQ_N             
    FIELD NEP_CSTPIS_N           LIKE INT_DS_NOTA_ENTRADA_PRODUT.NEP_CSTPIS_N           
    FIELD NEP_CSTCOFINS_N        LIKE INT_DS_NOTA_ENTRADA_PRODUT.NEP_CSTCOFINS_N        
    FIELD NEP_VPMC_N             LIKE INT_DS_NOTA_ENTRADA_PRODUT.NEP_VPMC_N             
    FIELD NEP_UCOMFORN_S         LIKE INT_DS_NOTA_ENTRADA_PRODUT.NEP_UCOMFORN_S         
    FIELD NEP_QCOMFORN_N         LIKE INT_DS_NOTA_ENTRADA_PRODUT.NEP_QCOMFORN_N         
    FIELD NEP_UCOM_S             LIKE INT_DS_NOTA_ENTRADA_PRODUT.NEP_UCOM_S             
    FIELD NEP_VUNCOM_N           LIKE INT_DS_NOTA_ENTRADA_PRODUT.NEP_VUNCOM_N           
    FIELD DE-VBCSTRET            LIKE INT_DS_NOTA_ENTRADA_PRODUT.DE-VBCSTRET            
    FIELD DE-VICMSSTRET          LIKE INT_DS_NOTA_ENTRADA_PRODUT.DE-VICMSSTRET
    FIELD NEP_DATAVALIDADE_D     LIKE INT_DS_NOTA_ENTRADA_PRODUT.NEP_DATAVALIDADE_D.          

DEFINE DATASET nfloja FOR tt-INT_DS_NOTA_ENTRADA, tt-INT_DS_NOTA_ENTRADA_PRODUT
    DATA-RELATION r1 FOR tt-INT_DS_NOTA_ENTRADA, tt-INT_DS_NOTA_ENTRADA_PRODUT
        RELATION-FIELDS(nen_cnpj_origem_s,nen_cnpj_origem_s,nen_serie_s,nen_serie_s,nen_notafiscal_n ,nen_notafiscal_n) NESTED.
        
DEF TEMP-TABLE tt-INT_DS_DOCTO_XML NO-UNDO SERIALIZE-NAME "INT_DS_DOCTO_XML"
    FIELD ARQUIVO        AS CHAR
    FIELD CFOP           AS INT
    FIELD CHNFE          AS CHAR
    FIELD CHNFT          AS CHAR
    FIELD CNPJ           AS CHAR
    FIELD CNPJ_DEST      AS CHAR
    FIELD COD_EMITENTE   AS INT
    FIELD COD_ESTAB      AS CHAR
    FIELD COD_USUARIO    AS CHAR 
    FIELD DEMI           AS DATE
    FIELD DESPESA_NOTA   AS DEC
    FIELD DT_ATUALIZA    AS DATE
    FIELD DT_TRANS       AS DATE
    FIELD EP_CODIGO      AS INT
    FIELD ESTAB_DE_OR    AS CHAR
    FIELD MODFRETE       AS INT
    FIELD NAT_OPERACAO   AS CHAR
    FIELD NNF            AS CHAR
    FIELD NUM_PEDIDO     AS INT
    FIELD OBSERVACAO     AS CHAR
    FIELD SERIE          AS CHAR
    FIELD SIT_RE         AS INT
    FIELD SITUACAO       AS INT
    FIELD TIPO_DOCTO     AS INT
    FIELD TIPO_ESTAB     AS INT
    FIELD TIPO_NOTA      AS INT
    FIELD TOT_DESCONTO   AS DEC
    FIELD VALOR_COFINS   AS DEC
    FIELD VALOR_FRETE    AS DEC
    FIELD VALOR_ICMS     AS DEC
    FIELD VALOR_ICMS_DES AS DEC
    FIELD VALOR_II       AS DEC
    FIELD VALOR_IPI      AS DEC
    FIELD VALOR_MERCAD   AS DEC
    FIELD VALOR_OUTRAS   AS DEC
    FIELD VALOR_PIS      AS DEC
    FIELD VALOR_SEGURO   AS DEC
    FIELD VALOR_ST       AS DEC
    FIELD VBC            AS DEC
    FIELD VBC_CST        AS DEC
    FIELD VNF            AS DEC
    FIELD VOLUME         AS CHAR
    FIELD XNOME          AS CHAR
    FIELD VALOR_GUIA_ST  AS DEC
    FIELD BASE_GUIA_ST   AS DEC
    FIELD PERC_RED_ICMS  AS DEC.


DEF TEMP-TABLE tt-INT_DS_IT_DOCTO_XML NO-UNDO SERIALIZE-NAME "INT_DS_IT_DOCTO_XML"
    FIELD ARQUIVO AS CHAR
    FIELD CENQ AS INT
    FIELD CFOP AS INT
    FIELD CNPJ AS CHAR
    FIELD COD_EMITENTE AS INT
    FIELD CST_COFINS AS INT
    FIELD CST_ICMS AS INT
    FIELD CST_IPI AS INT
    FIELD CST_PIS AS INT
    FIELD IT_CODIGO AS CHAR
    FIELD ITEM_DO_FORN AS CHAR
    FIELD LOTE AS CHAR
    FIELD MODBC AS INT
    FIELD MODBCST AS INT
    FIELD NARRATIVA AS CHAR
    FIELD NAT_OPERACAO AS CHAR
    FIELD NCM AS INT
    FIELD NNF AS CHAR
    FIELD NUM_PEDIDO AS INT
    FIELD NUMERO_ORDEM AS INT
    FIELD ORIG_ICMS AS INT
    FIELD PCOFINS AS DEC
    FIELD PICMS AS DEC
    FIELD PICMSST AS DEC
    FIELD PIPI AS DEC
    FIELD PMVAST AS DEC
    FIELD PPIS AS DEC
    FIELD QCOM AS DEC
    FIELD QCOM_FORN AS DEC
    FIELD QORDEM AS DEC
    FIELD SEQUENCIA AS INT
    FIELD SERIE AS CHAR
    FIELD SITUACAO AS INT
    FIELD TIPO_CONTR AS INT
    FIELD TIPO_NOTA AS INT
    FIELD UCOM AS CHAR
    FIELD UCOM_FORN AS CHAR
    FIELD VBC_COFINS AS DEC
    FIELD VBC_ICMS AS DEC
    FIELD VBC_IPI AS DEC
    FIELD VBC_PIS AS DEC
    FIELD VBCST AS DEC
    FIELD VBCSTRET AS DEC
    FIELD VCOFINS AS DEC
    FIELD VDESC AS DEC
    FIELD VICMS AS DEC
    FIELD VICMSST AS DEC
    FIELD VICMSSTRET AS DEC
    FIELD VIPI AS DEC
    FIELD VPIS AS DEC
    FIELD VPROD AS DEC
    FIELD VTOTTRIB AS DEC
    FIELD VUNCOM AS DEC
    FIELD XPROD AS CHAR
    FIELD VOUTRO AS DEC
    FIELD VICMSDESON AS DEC
    FIELD PREDBC AS DEC
    FIELD VPMC AS DEC
    FIELD VICMSSUBS AS DEC
    FIELD VALOR_FCP_ST_RET AS DEC
    FIELD dVal AS DATE.

DEFINE DATASET nfCD FOR tt-INT_DS_DOCTO_XML, tt-INT_DS_IT_DOCTO_XML
    DATA-RELATION r1 FOR tt-INT_DS_DOCTO_XML, tt-INT_DS_IT_DOCTO_XML
        RELATION-FIELDS(serie,serie,nNF,nNF,cod_emitente,cod_emitente,tipo_nota,tipo_nota) NESTED.
    
DEFINE VARIABLE c-retorno AS CHARACTER   NO-UNDO.

def var cSerie  as char no-undo.
def var cNF     as char no-undo.
def var cEmit   as char no-undo.
def var cDest   as char no-undo.
def var cData   as char no-undo.

/* Defini‡Æo temp-tables/vari veis execu‡Æo FT2200 */
DEF NEW GLOBAL SHARED VAR c-seg-usuario AS CHAR NO-UNDO.
DEFINE VARIABLE raw-param    AS RAW NO-UNDO.

DEFINE TEMP-TABLE tt-raw-digita NO-UNDO
    FIELD raw-digita      AS RAW.

DEFINE TEMP-TABLE tt-param NO-UNDO
    FIELD destino           AS INTEGER
    FIELD arquivo           AS CHARACTER FORMAT "x(35)"
    FIELD usuario           AS CHARACTER FORMAT "x(12)"
    FIELD data-exec         AS DATE
    FIELD hora-exec         AS INTEGER
    FIELD cod-estabel       LIKE nota-fiscal.cod-estabel
    FIELD serie             LIKE nota-fiscal.serie
    FIELD nr-nota-fis       LIKE nota-fiscal.nr-nota-fis
    FIELD dt-cancela        LIKE nota-fiscal.dt-cancela
    FIELD desc-cancela      LIKE nota-fiscal.desc-cancela
    FIELD arquivo-estoq     AS CHARACTER
    FIELD reabre-resumo     AS LOGICAL
    FIELD cancela-titulos   AS LOGICAL
    FIELD imprime-ajuda     AS LOGICAL
    FIELD l-valida-dt-saida AS LOGICAL
    FIELD elimina-nota-nfse AS LOGICAL.

define temp-table tt-erros no-undo
       field identifi-msg                   as char format "x(60)"
       field cod-erro                       as int  format "99999"
       field desc-erro                      as char format "x(60)"
       field tabela                         as char format "x(20)"
       field l-erro                         as logical initial yes.
/* FIM - Defini‡Æo temp-tables/vari veis execu‡Æo FT2200 */

DEFINE VARIABLE oResponse    AS JsonAPIResponse NO-UNDO.

DEF DATASET dsPedido FOR pedido, itens, cond-pagto
    DATA-RELATION r1 FOR pedido, itens
        RELATION-FIELDS(pedido,pedido) NESTED
    DATA-RELATION r2 FOR pedido, cond-pagto
        RELATION-FIELDS(pedido,pedido) NESTED.

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

PROCEDURE pi-gera-faturamento:
    DEF INPUT  PARAM jsonInput  AS JsonObject NO-UNDO.
    DEF OUTPUT PARAM jsonOutput AS JsonObject NO-UNDO.
    //DEF INPUT  PARAMETER TABLE FOR tt-mp-titulos-baixa-ok. 

    DEFINE VARIABLE oRequestParser AS JsonAPIRequestParser NO-UNDO.
    DEFINE VARIABLE lcPayload      AS LONGCHAR             NO-UNDO.

    oRequestParser = NEW JsonAPIRequestParser(jsonInput).
     
    ASSIGN lcPayload = oRequestParser:getPayloadLongChar().

    DEF VAR jsonAux  AS JsonObject NO-UNDO.
    jsonAux = LongCharToJsonObject(lcPayload).

    //MESSAGE string(jsonAux:GetJsonArray("PEDIDO"):getJsonText())
        //VIEW-AS ALERT-BOX INFO BUTTONS OK.
        
    //jsonAux:WriteFile("/mnt/shares/p/cjem8f/TEMP/recebimento_PEDIDO.json") NO-ERROR.    

    DATASET dsPedido:HANDLE:READ-JSON('JsonObject',jsonAux).
    
    MESSAGE jsonAux:GetJsonArray("PEDIDO"):GetJsonObject(1):GetDecimal("PEDIDO") SKIP
            jsonAux:GetJsonArray("PEDIDO"):GetJsonObject(1):Getcharacter("CNPJ-CPF-CLIENTE")
        VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
    
    log-manager:write-message("KML - longchar json - " + string(lcPayload)) no-error.
    

    FOR FIRST pedido:
    
        CREATE tt-cliente.
        ASSIGN tt-cliente.CNPJ         = pedido.cnpj-cpf-cliente
               tt-cliente.nome         = pedido.nome
               tt-cliente.natureza     = IF pedido.natureza-cliente = "fisica" THEN 1 ELSE 2
               tt-cliente.ins-estadual = pedido.inscricao_federal
               tt-cliente.cep          = pedido.cep
               tt-cliente.endereco     = pedido.endereco
               tt-cliente.numero       = string(pedido.numero)
               tt-cliente.complemento  = pedido.complemento
               tt-cliente.bairro       = pedido.bairro
               tt-cliente.cidade       = pedido.cidade
               tt-cliente.cod-ibge     = pedido.cod-ibge
               tt-cliente.estado       = pedido.estado
               tt-cliente.pais         = pedido.pais
               tt-cliente.telefone     = pedido.telefone
               tt-cliente.email        = pedido.email.

        log-manager:write-message("KML - antes API - pedido.cnpj-loja - " + pedido.cnpj-loja) no-error.
        log-manager:write-message("KML - antes API - INT(pedido.pedido) - " + STRING(pedido.pedido)) no-error.
        log-manager:write-message("KML - antes API - pedido.cnpj-cpf-cliente - " + pedido.cnpj-cpf-cliente) no-error.

        CREATE tt-pedido.
        ASSIGN tt-pedido.pedcodigo     = DEC(pedido.pedido)
               tt-pedido.DtEmissao     = pedido.data
               tt-pedido.DtEntrega     = pedido.data_entrega
               tt-pedido.cnpj_estab    = pedido.cnpj-loja
               tt-pedido.cnpj_emitente = pedido.cnpj-cpf-cliente
               tt-pedido.valorTotal    = pedido.total_geral
               tt-pedido.desconto      = pedido.total_desconto
               tt-pedido.frete         = pedido.frete
               tt-pedido.observacao    = pedido.observacoes
               tt-pedido.tipopedido    = pedido.tipo_pedido
               tt-pedido.cnpj_transp   = pedido.cnpj-transp                
               tt-pedido.comissao      = pedido.comissao
               tt-pedido.cnpj-representante   = pedido.cnpj-representante.
    END.

    FOR EACH itens:
        CREATE tt-pedido-item.
        ASSIGN tt-pedido-item.cod-item    = itens.item
               tt-pedido-item.quantidade  = itens.quantidade
               tt-pedido-item.valor-unit  = itens.total_item / itens.quantidade
               tt-pedido-item.desconto    = itens.desconto
               tt-pedido-item.valor-liq   = itens.preco_liquido
               tt-pedido-item.preco-bruto = itens.preco_bruto
               tt-pedido-item.valor-total = itens.total_item
               tt-pedido-item.lote        = itens.lote
               tt-pedido-item.dt-validade = itens.validade
               tt-pedido-item.observacao  = itens.observacao.
    END.

    FOR EACH cond-pagto:
        CREATE tt-cond-pagto-esp.
        ASSIGN tt-cond-pagto-esp.cond-pagto     = cond-pagto.cond-pagto
               tt-cond-pagto-esp.dt-vencto      = cond-pagto.vencim                                                                
               tt-cond-pagto-esp.vl-parcela     = cond-pagto.valor
               tt-cond-pagto-esp.parcela        = cond-pagto.parcela
               tt-cond-pagto-esp.nsu            = string(cond-pagto.nsu-admin)
               tt-cond-pagto-esp.autorizacao    = cond-pagto.autorizacao
               tt-cond-pagto-esp.adquirente     = string(cond-pagto.cod-adquirente)
               tt-cond-pagto-esp.origem-pagto   = cond-pagto.origem-pagto
               tt-cond-pagto-esp.CNPJ_CONVENIO  = cond-pagto.CNPJ_CONVENIO
            .
    END.

    log-manager:write-message("KML - 2 antes API CNPJ CONVENIO" + cond-pagto.CNPJ_CONVENIO) no-error.
    log-manager:write-message("KML - 2 antes API convenio" + tt-cond-pagto-esp.CNPJ_CONVENIO) no-error.
    log-manager:write-message("KML - 2 antes API - pedido.cnpj-loja - " + pedido.cnpj-loja) no-error.

    
    FIND FIRST es-pedidos-ecom NO-LOCK
        WHERE es-pedidos-ecom.pedcodigo = pedido.pedido
          AND es-pedidos-ecom.situacao  = 1 NO-ERROR.
        
    IF AVAIL es-pedidos-ecom THEN
    DO:
    
        CREATE tt-nota-fiscal.
        ASSIGN tt-nota-fiscal.l-gerada = NO
               tt-nota-fiscal.desc-erro = "Pedido j  est  em processo de integra‡Æo".
    
        
    END.
    ELSE DO:
    
    
        FIND FIRST es-pedidos-ecom EXCLUSIVE-LOCK
            WHERE es-pedidos-ecom.pedcodigo = pedido.pedido NO-ERROR.
            
        IF NOT AVAIL es-pedidos-ecom THEN DO:
            CREATE es-pedidos-ecom.
            ASSIGN es-pedidos-ecom.pedcodigo    = pedido.pedido
                   es-pedidos-ecom.dataEmissao  = pedido.data.
            
        END.        

            ASSIGN es-pedidos-ecom.situacao     = 1.
               
        RELEASE es-pedidos-ecom.
    
        
        RUN intprg/int092API.p (INPUT TABLE tt-cliente,
                                INPUT TABLE tt-pedido,
                                INPUT TABLE tt-pedido-item,
                                INPUT TABLE tt-cond-pagto-esp,
                                OUTPUT TABLE tt-nota-fiscal).
                                
    END.

    jsonOutput = NEW JSONObject().
    FOR FIRST tt-nota-fiscal:
        IF tt-nota-fiscal.l-gerada THEN DO:
        
        
            FIND FIRST es-pedidos-ecom EXCLUSIVE-LOCK
                WHERE es-pedidos-ecom.pedcodigo = pedido.pedido
                  AND es-pedidos-ecom.situacao  = 1 NO-ERROR.
            IF AVAIL es-pedidos-ecom THEN
            DO:
                ASSIGN es-pedidos-ecom.situacao  = 2.
                
            END.
            RELEASE  es-pedidos-ecom.
        
            jsonOutput:ADD("cod-estabel",tt-nota-fiscal.cod-estabel).
            jsonOutput:ADD("serie"      ,tt-nota-fiscal.serie      ).
            jsonOutput:ADD("nr-nota-fis",tt-nota-fiscal.nr-nota-fis).
            jsonOutput:ADD("chave-acesso",tt-nota-fiscal.chave-acesso).
        END.
        ELSE DO:
        
            FIND FIRST es-pedidos-ecom EXCLUSIVE-LOCK
                WHERE es-pedidos-ecom.pedcodigo = pedido.pedido
                  AND es-pedidos-ecom.situacao  = 1 NO-ERROR.
            IF AVAIL es-pedidos-ecom THEN
            DO:
                ASSIGN es-pedidos-ecom.situacao  = 3.
                
            END.
            RELEASE  es-pedidos-ecom.        

            jsonOutput:ADD("serie"      ,tt-nota-fiscal.serie      ).
            jsonOutput:ADD("nr-nota-fis",tt-nota-fiscal.nr-nota-fis).
            jsonOutput:ADD("chave-acesso",tt-nota-fiscal.chave-acesso).
            jsonOutput:ADD("ERRO",tt-nota-fiscal.desc-erro).


        END.
            
    END.

    IF NOT CAN-FIND(FIRST tt-nota-fiscal) THEN  DO:
    
    
         FIND FIRST es-pedidos-ecom EXCLUSIVE-LOCK
                WHERE es-pedidos-ecom.pedcodigo = pedido.pedido
                  AND es-pedidos-ecom.situacao  = 1 NO-ERROR.
            IF AVAIL es-pedidos-ecom THEN
            DO:
                ASSIGN es-pedidos-ecom.situacao  = 3.
                
            END.
            RELEASE  es-pedidos-ecom.   
         jsonOutput:ADD("ERRO","Erro na execu‡Æo da rotina!").
    
    END.
        

    RETURN "OK".
END PROCEDURE.

PROCEDURE pi-cancelamento:

    DEF INPUT  PARAM jsonInput  AS JsonObject NO-UNDO.
    DEF OUTPUT PARAM jsonOutput AS JsonObject NO-UNDO.
    //DEF INPUT  PARAMETER TABLE FOR tt-mp-titulos-baixa-ok. 

    DEFINE VARIABLE oRequestParser AS JsonAPIRequestParser NO-UNDO.
    DEFINE VARIABLE lcPayload      AS LONGCHAR             NO-UNDO.

    DEFINE VARIABLE cArqLogEstoque      AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE cArqLogCancelamento AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE c-msg               AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE h-ft2200            AS HANDLE      NO-UNDO.

    DEFINE VARIABLE jsonArrayErros AS JsonArray NO-UNDO.

    DEFINE VARIABLE l-cancel-ok AS LOGICAL     NO-UNDO.
    
    log-manager:write-message("KML - Cancelamento - inicio") no-error.
     
    oRequestParser = NEW JsonAPIRequestParser(jsonInput).
     
    ASSIGN lcPayload = oRequestParser:getPayloadLongChar().

    DEF VAR jsonAux  AS JsonObject NO-UNDO.
    jsonAux = LongCharToJsonObject(lcPayload).

    log-manager:write-message("KML - Cancelamento - inicio 2 ") no-error.
    
    TEMP-TABLE nota-fiscal-cancela:HANDLE:READ-JSON('JsonArray',jsonAux:GetJsonArray("NOTA-FISCAL")).
    
    FIND FIRST nota-fiscal-cancela NO-ERROR.
    log-manager:write-message("KML - Cancelamento - inicio 3.1 - " + STRING(AVAIL nota-fiscal-cancela) + "-" + nota-fiscal-cancela.cnpj-loja) no-error.                                                                                   

    ASSIGN l-cancel-ok = NO.

    LOG-MANAGER:write-message("KML - Cancelamento - antes for each ") no-error.
    
    FOR FIRST nota-fiscal-cancela,
        FIRST estabelec NO-LOCK
        WHERE estabelec.cgc = nota-fiscal-cancela.cnpj-loja:
        
        log-manager:write-message("KML - Cancelamento - entrou temp-table") no-error.

        FIND FIRST nota-fiscal EXCLUSIVE-LOCK
            WHERE nota-fiscal.cod-estabel = estabelec.cod-estabel
            AND   nota-fiscal.serie       = nota-fiscal-cancela.serie
            AND   nota-fiscal.nr-nota-fis = string(nota-fiscal-cancela.nr-nota, "9999999") NO-ERROR.
            
        log-manager:write-message("KML - Cancelamento - depois for each nota fiscal") no-error.

        IF NOT AVAIL nota-fiscal THEN DO:
        
            CREATE RowErrors.
            ASSIGN RowErrors.ErrorNumber = 17001
                   RowErrors.ErrorDescription = "Nota Fiscal n’o encontrada!"
                   RowErrors.ErrorHelp = "Nota Fiscal n’o encontrada!"
                   RowErrors.ErrorSubType = "ERROR". 
                                 
            IF CAN-FIND(FIRST RowErrors) THEN DO:
            
               jsonOutput = NEW JSONObject().
               oResponse = NEW JsonAPIResponse(jsonInput).
               oResponse:setHasNext(FALSE).
               oResponse:setStatus(400).
               oResponse:setRowErrors(JsonAPIUtils:convertTempTableToJsonObject(TEMP-TABLE RowErrors:HANDLE):getJsonArray("RowErrors")).
               jsonOutput = oResponse:createJsonResponse().
            END.         
            RETURN "OK".
        END.

        IF nota-fiscal.dt-cancela <> ? THEN DO:
        
            CREATE RowErrors.
            ASSIGN RowErrors.ErrorNumber = 17001
                   RowErrors.ErrorDescription = "Nota Fiscal jÿ cancelada ou em processo de cancelamento!"
                   RowErrors.ErrorHelp = "Nota Fiscal jÿ cancelada ou em processo de cancelamento!"
                   RowErrors.ErrorSubType = "ERROR". 
                                 
            IF CAN-FIND(FIRST RowErrors) THEN DO:
               jsonOutput = NEW JSONObject().
               oResponse = NEW JsonAPIResponse(jsonInput).
               oResponse:setHasNext(FALSE).
               oResponse:setStatus(400).
               oResponse:setRowErrors(JsonAPIUtils:convertTempTableToJsonObject(TEMP-TABLE RowErrors:HANDLE):getJsonArray("RowErrors")).
               jsonOutput = oResponse:createJsonResponse().
            END.        
            RETURN "OK".
        END.

        FIND FIRST para-fat NO-LOCK NO-ERROR.

        ASSIGN cArqLogEstoque      = SESSION:TEMP-DIRECTORY + "FT2100.LST":U
               cArqLogCancelamento = SESSION:TEMP-DIRECTORY + "FT2200.LST":U.
        
        EMPTY TEMP-TABLE tt-param.

        CREATE tt-param.
        ASSIGN tt-param.usuario             = c-seg-usuario
               tt-param.destino             = 2 /* arquivo */
               tt-param.data-exec           = TODAY
               tt-param.hora-exec           = TIME
               tt-param.cod-estabel         = nota-fiscal.cod-estabel
               tt-param.serie               = nota-fiscal.serie
               tt-param.nr-nota-fis         = nota-fiscal.nr-nota-fis
               tt-param.dt-cancela          = TODAY
               tt-param.desc-cancela        = "Cancelamento da Nota Fiscal a partir da API REST"
               tt-param.arquivo-estoq       = cArqLogEstoque
               tt-param.reabre-resumo       = NO
               tt-param.cancela-titulos     = SUBSTRING(para-fat.char-1, 27, 1) <> "N":U
               tt-param.imprime-ajuda       = YES
               tt-param.l-valida-dt-saida   = YES
               //tt-param.destino             = 2 
               tt-param.arquivo             = cArqLogCancelamento
               tt-param.elimina-nota-nfse   = NO.
         
        
        RAW-TRANSFER tt-param TO raw-param.
        RUN ftp/ft2200rp.p PERSISTENT SET h-ft2200 (INPUT raw-param, INPUT TABLE tt-raw-digita).
        RUN retornaErros IN h-ft2200 (OUTPUT TABLE RowErrors).
        
        log-manager:write-message("KML - Cancelamento - depois ft2200") no-error.
        
        FOR EACH RowErrors:

            CREATE tt-erros.
            ASSIGN tt-erros.cod-erro  = RowErrors.ErrorNumber
                   tt-erros.desc-erro = RowErrors.ErrorDescription
                   tt-erros.l-erro    = IF RowErrors.ErrorSubType = "Erro" THEN YES ELSE NO.
                   
            log-manager:write-message("KML - Cancelamento - rowerros - " + RowErrors.ErrorDescription) no-error. 
            log-manager:write-message("KML - Cancelamento - SubType - " + RowErrors.ErrorSubType) no-error.
        
            IF  RowErrors.ErrorNumber = 17006 OR RowErrors.ErrorNumber = 19439 OR RowErrors.ErrorNumber = 19574 
            AND (   RowErrors.ErrorDescription BEGINS "NF-e em processo de Cancelamento"
                 OR RowErrors.ErrorDescription BEGINS "NF-e em processo de Inutiliza?Êo"
                 OR RowErrors.ErrorDescription BEGINS "Emiss?Êo da nota fiscal ocorreu hÿ mais de 3 dias"
                 OR RowErrors.ErrorDescription BEGINS "N?Êo foi poss­vel desatualizar") THEN
                
                ASSIGN tt-erros.l-erro = NO
                       l-cancel-ok     = YES.

            IF RowErrors.ErrorNumber = 19568 THEN
                ASSIGN tt-erros.l-erro = YES
                       l-cancel-ok = NO.
        END.
    END.
    
    
    log-manager:write-message("KML - NOVO FT2200 - "  + string(l-cancel-ok)) no-error.
    log-manager:write-message("KML - Cancelamento - depois ft2200 - "  + string(l-cancel-ok)) no-error.
    
    jsonOutput = NEW JSONObject().
    FOR FIRST tt-erros:
    
        IF l-cancel-ok   = NO THEN DO:
        
            ASSIGN nota-fiscal.idi-sit-nf-eletro = 6.
        
        
            jsonOutput:ADD("COD",tt-erros.cod-erro).
            jsonOutput:ADD("Descri»’o",tt-erros.desc-erro).
            jsonOutput:ADD("CANCELAMENTO","OK").

            RETURN "OK".
        END.    
        
        ELSE DO:
            EMPTY TEMP-TABLE RowErrors.

            CREATE RowErrors.
            ASSIGN RowErrors.ErrorNumber = tt-erros.cod-erro
                   RowErrors.ErrorDescription = tt-erros.desc-erro
                   RowErrors.ErrorHelp = tt-erros.desc-erro
                   RowErrors.ErrorSubType = "ERROR". 
                             
            IF CAN-FIND(FIRST RowErrors) THEN DO:
               jsonOutput = NEW JSONObject().
               oResponse = NEW JsonAPIResponse(jsonInput).
               oResponse:setHasNext(FALSE).
               oResponse:setStatus(400).
               oResponse:setRowErrors(JsonAPIUtils:convertTempTableToJsonObject(TEMP-TABLE RowErrors:HANDLE):getJsonArray("RowErrors")).
               jsonOutput = oResponse:createJsonResponse().
            END. 
            
            RETURN "OK".
       END.     
        
   END. 
             
END PROCEDURE.

PROCEDURE pi-busca-danfe-xml:
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

    TEMP-TABLE tt-nota-fiscal-rest:HANDLE:READ-JSON('JsonArray',jsonAux:GetJsonArray("NOTA-FISCAL")).
    
    jsonOutput = NEW JSONObject().
    ASSIGN l-ok = NO.

    FOR FIRST tt-nota-fiscal-rest,
        FIRST estabelec NO-LOCK
        WHERE estabelec.cgc = tt-nota-fiscal-rest.cnpj-loja,
        FIRST ext-nota-fiscal-danfe NO-LOCK
        WHERE ext-nota-fiscal-danfe.cod-estabel = estabelec.cod-estabel
        AND   ext-nota-fiscal-danfe.serie       = tt-nota-fiscal-rest.serie
        AND   ext-nota-fiscal-danfe.nr-nota-fis = tt-nota-fiscal-rest.nr-nota:

        IF ext-nota-fiscal-danfe.doc-xml <> ? THEN DO:
            COPY-LOB FROM ext-nota-fiscal-danfe.doc-xml TO memptr-aux.
            jsonOutput:ADD("XML", memptr-aux).
        END.
        ELSE
            jsonOutput:ADD("XML", "").

        IF ext-nota-fiscal-danfe.doc-danfe <> ? THEN DO:
            COPY-LOB FROM ext-nota-fiscal-danfe.doc-danfe TO lc-aux.
            memptr-aux = BASE64-DECODE(lc-aux).
            jsonOutput:ADD("DANFE", memptr-aux).
        END.
        ELSE
            jsonOutput:ADD("DANFE", "").

        ASSIGN l-ok = YES.
    END.

    IF NOT l-ok THEN
        jsonOutput:ADD("ERRO", "NÆo encontrado Danfe/XML para essa nota.").

    RETURN "OK".
END PROCEDURE.

PROCEDURE pi-consulta-pedido:
    DEF INPUT  PARAM jsonInput  AS JsonObject NO-UNDO.
    DEF OUTPUT PARAM jsonOutput AS JsonObject NO-UNDO. 

    DEFINE VARIABLE oRequestParser AS JsonAPIRequestParser NO-UNDO.
    DEFINE VARIABLE lcPayload      AS LONGCHAR             NO-UNDO.

    DEFINE VARIABLE memptr-aux AS MEMPTR      NO-UNDO.
    DEFINE VARIABLE lc-aux     AS LONGCHAR    NO-UNDO.
    DEFINE VARIABLE l-ok       AS LOGICAL     NO-UNDO.

    oRequestParser = NEW JsonAPIRequestParser(jsonInput).
     
    ASSIGN lcPayload = oRequestParser:getPayloadLongChar().

    DEF VAR jsonAux  AS JsonObject NO-UNDO.
    jsonAux = LongCharToJsonObject(lcPayload).

    TEMP-TABLE tt-consulta-pedido:HANDLE:READ-JSON('JsonArray',jsonAux:GetJsonArray("PEDIDO")).


    RUN intprg/int098api.p ( INPUT TABLE tt-consulta-pedido,
                             OUTPUT TABLE tt-nota-fiscal).

    jsonOutput = NEW JSONObject().

    FOR FIRST tt-nota-fiscal:
          IF tt-nota-fiscal.l-gerada THEN DO:
              jsonOutput:ADD("cod-estabel",tt-nota-fiscal.cod-estabel).
              jsonOutput:ADD("serie"      ,tt-nota-fiscal.serie      ).
              jsonOutput:ADD("nr-nota-fis",tt-nota-fiscal.nr-nota-fis).
              jsonOutput:ADD("chave-acesso",tt-nota-fiscal.chave-acesso).
          END.
          ELSE DO:

              jsonOutput:ADD("serie"      ,tt-nota-fiscal.serie      ).
              jsonOutput:ADD("nr-nota-fis",tt-nota-fiscal.nr-nota-fis).
              jsonOutput:ADD("chave-acesso",tt-nota-fiscal.chave-acesso).
              jsonOutput:ADD("ERRO",tt-nota-fiscal.desc-erro).


          END.

      END.

      IF NOT CAN-FIND(FIRST tt-nota-fiscal) THEN
          jsonOutput:ADD("ERRO","Erro na execu‡Æo da rotina!").

    RETURN "OK".
END PROCEDURE.


PROCEDURE pi-recebimento:  //KML


    DEF INPUT  PARAM jsonInput  AS JsonObject NO-UNDO.
    DEF OUTPUT PARAM jsonOutput AS JsonObject NO-UNDO.

    DEFINE VARIABLE l-ok-procfit AS LOGICAL     NO-UNDO.

    DEFINE VARIABLE ResultObject AS JsonObject        NO-UNDO.
    DEFINE VARIABLE JsonParser   AS ObjectModelParser NO-UNDO.
    DEFINE VARIABLE FieldNames   AS CHARACTER         NO-UNDO EXTENT.

    DEFINE VARIABLE oRequestParser AS JsonAPIRequestParser NO-UNDO.
    DEFINE VARIABLE lcPayload      AS LONGCHAR             NO-UNDO.
    DEFINE VARIABLE lcxml          AS LONGCHAR     NO-UNDO.

    DEFINE VARIABLE xmlBase64           AS LONGCHAR     NO-UNDO.
    DEFINE VARIABLE xmlBase64Decoded    AS MEMPTR       NO-UNDO.
    DEFINE VARIABLE h_int500a           AS HANDLE      NO-UNDO.
    DEFINE VARIABLE h_int500b           AS HANDLE      NO-UNDO.
    DEFINE VARIABLE c-result            AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE i-statuscode        AS INTEGER     NO-UNDO.
    DEFINE VARIABLE oResponse    AS JsonAPIResponse NO-UNDO.

    log-manager:write-message("KML - entrou api recebimento") no-error.

    if not valid-handle (h_int500a)    then run intprg/int500a-get.p    persistent set h_int500a.
    
    if not valid-handle (h_int500b)    then run intprg/int500a-get-CTE.p    persistent set h_int500b.

    oRequestParser = NEW JsonAPIRequestParser(jsonInput).
     
    ASSIGN lcPayload = oRequestParser:getPayloadLongChar().

    DEF VAR jsonAux  AS JsonObject NO-UNDO.
    jsonAux = LongCharToJsonObject(lcPayload).
    
    TEMP-TABLE Recebimento:READ-JSON("longchar", lcPayload, "empty").
     
    FOR EACH Recebimento:

        bl_nota:
        DO TRANS ON ERROR UNDO, LEAVE:
            COPY-LOB FROM Recebimento.XMLNota TO xmlBase64 .
            xmlBase64Decoded = BASE64-DECODE(xmlBase64).
            COPY-LOB FROM xmlBase64Decoded TO  lcxml  .
            
            COPY-LOB FROM lcxml TO  Recebimento.XMLNota  .
    
            log-manager:write-message("KMLR - ANTES PROCESSA v2") no-error.
            log-manager:write-message("KMLR TAMANHO - " + STRING(LENGTH(lcxml)) ) no-error.
    
            //   COPY-LOB FROM lcxml TO FILE "xml1.xml" .
            
            IF recebimento.tipo-documento = "CTE" THEN DO: 
                
                RUN gera_ndd_entryintegration IN h_int500b (INPUT lcxml, 
                                                            OUTPUT c-result).
            END.
            
            ELSE DO:
                
                  RUN gera_ndd_entryintegration IN h_int500a (INPUT lcxml, 
                                                              OUTPUT c-result).
            END.
                                                        
            ASSIGN c-result = "Totvs - " + c-result.                                                        
    
            log-manager:write-message("KMLR - DEPOIS PROCESSA - " + c-result ) no-error.
    

            if lcxml matches "*CNPJ*" then do: 
                /* destinatario */
                assign cDest = string(findTag(lcxml,'CNPJ',index(lcxml,'CNPJ') + 25)) no-error.
            end.

            FIND FIRST estabelec NO-LOCK
                WHERE estabelec.cgc = cDest NO-ERROR.
                
            ASSIGN i-statuscode = 200.
            
            IF recebimento.tipo-documento = "CTE" THEN
            DO:
                
                ASSIGN c-result = "Totvs CTE - " .

                // KML - colocar filtro por estabelecimento
                RUN PI-CTE (INPUT lcxml, OUTPUT l-ok-procfit, OUTPUT i-statuscode).

                IF c-mensagem = "" THEN
                DO:
                    ASSIGN c-result = "Totvs - CTE RE1001 " .
                    
                END.
                ELSE
                    ASSIGN c-result = "Totvs CTE - " + c-mensagem.
                     
            END.
            
            IF v_cdn_empres_usuar = "1" THEN DO:
                        IF AVAIL estabelec AND
                            (estabelec.cod-estabel < "973" )    // tirado  todas as filiais pois a api da procfit ficou fora do ar
                            THEN DO:  
                            
                            ASSIGN c-result = "Procfit - " .

                            // KML - colocar filtro por estabelecimento
                            RUN pi-procfit (INPUT lcxml, OUTPUT l-ok-procfit, OUTPUT i-statuscode).

                            IF c-mensagem = "" THEN
                            DO:
                                ASSIGN c-result = "Procfit - retorno vazio" .
                                
                            END.
                            ELSE
                                ASSIGN c-result = "Procfit - " + c-mensagem.
                        END.
                        ELSE DO:

                            ASSIGN l-ok-procfit = YES. // como nÆo sera integrado via api marca como ok
                            ASSIGN c-result = c-result.  // apenas para refor‡ar que ele manter  a mensagem de retorno do int500 e nÆo da procfit

                        END.

                        IF l-ok-procfit = NO THEN DO:
                            UNDO, LEAVE bl_nota.
                        END.
                    END.
                END.      
            END.

            
    
 //   ASSIGN c-result = "teste".

    FIND FIRST Recebimento NO-LOCK NO-ERROR.
    
    jsonOutput = NEW JSONObject(). 
    
    /*
    jsonOutput = NEW JSONObject(). 
    IF AVAIL recebimento THEN
        jsonOutput:ADD("message",c-result).
    ELSE 
        jsonOutput:ADD("message",c-result).  */
        
    log-manager:write-message("KML antes retorno json - i-statuscode- " + STRING(i-statuscode) + " c-result- " + c-result ) no-error.    
        
    IF i-statuscode <> 200 THEN
    DO:
    
        CREATE RowErrors.
        ASSIGN RowErrors.ErrorNumber = 17001
               RowErrors.ErrorDescription = c-result
               RowErrors.ErrorHelp = c-result
               RowErrors.ErrorSubType = "ERROR". 
                             
        IF CAN-FIND(FIRST RowErrors) THEN DO:
        
           oResponse = NEW JsonAPIResponse(jsonInput).
           oResponse:setHasNext(FALSE).
           oResponse:setStatus(i-statuscode).
           oResponse:setRowErrors(JsonAPIUtils:convertTempTableToJsonObject(TEMP-TABLE RowErrors:HANDLE):getJsonArray("RowErrors")).
           jsonOutput = oResponse:createJsonResponse().
        END.    
     END.
     ELSE DO:
     
         jsonOutput:ADD("message",c-result).
     
     END.

    RETURN "OK".
    
END PROCEDURE.


PROCEDURE pi-recebimento-post:  //KML

    DEF INPUT  PARAM jsonInput  AS JsonObject NO-UNDO.
    DEF OUTPUT PARAM jsonOutput AS JsonObject NO-UNDO.

    DEFINE VARIABLE oRequestParser AS JsonAPIRequestParser NO-UNDO.
    DEFINE VARIABLE lcPayload      AS LONGCHAR             NO-UNDO.

    oRequestParser = NEW JsonAPIRequestParser(jsonInput).
     
    ASSIGN lcPayload = oRequestParser:getPayloadLongChar().

    DEF VAR jsonAux  AS JsonObject NO-UNDO.
    jsonAux = LongCharToJsonObject(lcPayload).

    jsonOutput = NEW JSONObject().
    
    TEMP-TABLE Recebimento:READ-JSON("longchar", lcPayload, "empty").

    jsonOutput = NEW JSONObject().
 /*   FOR FIRST recebimento:
            jsonOutput:ADD("cod-estabel",recebimento.NR-NOTA).
            jsonOutput:ADD("serie"      ,recebimento.SERIE  ).
            jsonOutput:ADD("nr-nota-fis",recebimento.CNPJ   ).
    END.

    IF NOT CAN-FIND(FIRST recebimento) THEN*/
    jsonOutput:ADD("ERRO","Erro na execu‡Æo da rotina!").


    RETURN "OK".


/*
    log-manager:write-message("KML - entrou api recebimento") no-error.

    if not valid-handle (h_int500a)    then run intprg/int500a-get.p    persistent set h_int500a.

    oRequestParser = NEW JsonAPIRequestParser(jsonInput).
     
    ASSIGN lcPayload = oRequestParser:getPayloadLongChar().

    DEF VAR jsonAux  AS JsonObject NO-UNDO.
    jsonAux = LongCharToJsonObject(lcPayload).
    
    TEMP-TABLE Recebimento:READ-JSON("longchar", lcPayload, "empty").
    
    FOR EACH Recebimento:

        COPY-LOB FROM Recebimento.XMLNota TO xmlBase64 .
         xmlBase64Decoded = BASE64-DECODE(xmlBase64).
         COPY-LOB FROM xmlBase64Decoded TO  lcxml  .
         
         COPY-LOB FROM lcxml TO  Recebimento.XMLNota  .

         log-manager:write-message("KMLR - ANTES PROCESSA v2") no-error.
         log-manager:write-message("KMLR TAMANHO - " + STRING(LENGTH(lcxml)) ) no-error.

      //   COPY-LOB FROM lcxml TO FILE "xml1.xml" .

         RUN gera_ndd_entryintegration IN h_int500a (INPUT lcxml, 
                                                     OUTPUT c-result).

         log-manager:write-message("KMLR - DEPOIS PROCESSA") no-error.
    END.

    FIND FIRST Recebimento NO-LOCK NO-ERROR.

    jsonOutput = NEW JSONObject(). 
    IF AVAIL recebimento THEN
        jsonOutput:ADD("ERRO",c-result).
    ELSE 
        jsonOutput:ADD("ERRO",c-result).
*/

END PROCEDURE.

PROCEDURE pi-procfit:
    DEFINE INPUT  PARAMETER pxml AS LONGCHAR.
    DEFINE OUTPUT PARAMETER p-ok AS LOGICAL     NO-UNDO.   
    DEFINE OUTPUT PARAMETER p-statuscode AS INTEGER     NO-UNDO. 
   
     log-manager:write-message("KML - dentro pi-procfit") no-error.
    /* tratar s‚rie */
    if  pXML matches "*serie*" then do:     
        assign cSerie = OnlyNumbers(string(int(findTag(pXML,'serie',1)))) no-error.
        if length(cSerie) > 3 then assign cSerie = substring(cSerie,1,3) no-error.
    end.
    
    if  pXML matches "*nNF*" then 
        assign cNF   = OnlyNumbers(string(int64(findTag(pXML,'nNF',1)),">>>9999999")) no-error.
    if pXML matches "*dhEmi*" then do:
        assign cData = substring(findTag(pXML,'dhEmi',1),1,10) 
               cData = entry(3,cData,"-") + "/" + entry(2,cData,"-")  + "/" + entry(1,cData,"-") no-error.
    end.
    
    if pXML matches "*CNPJ*" then do: 
        /* emitente do documento */
        assign cEmit = string(findTag(pXML,'CNPJ',1)) no-error. 
    
        /* destinatario */
        assign cDest = string(findTag(pXML,'CNPJ',index(pXML,'CNPJ') + 25)) no-error.
    end.

    FIND FIRST emitente NO-LOCK
        WHERE emitente.cgc = cEmit NO-ERROR.
        
    IF NOT AVAIL emitente THEN
    DO:
    
        ASSIGN p-statuscode = 400
               p-ok = NO
               c-mensagem = "Emitente nÆo cadastrado na base de dados, nÆo foi possivel integra‡Æo"  .
        
        RETURN "OK".
    END.

    
    log-manager:write-message("KML - antes int500 ") no-error.
    
    EMPTY TEMP-TABLE tt-param-int500.
    create tt-param-int500.
    assign tt-param-int500.usuario         = c-seg-usuario
           tt-param-int500.destino         = 3
           tt-param-int500.arquivo         = "INT002brp.txt"
           tt-param-int500.data-exec       = today
           tt-param-int500.hora-exec       = time
           tt-param-int500.classifica      = 1
           tt-param-int500.dt-trans-ini    = date(cData)
           tt-param-int500.dt-trans-fin    = DATE(cData)
           tt-param-int500.i-nro-docto-ini = cNF 
           tt-param-int500.i-nro-docto-fin = cNF
           tt-param-int500.i-cod-emit-ini  = emitente.cod-emitente
           tt-param-int500.i-cod-emit-fin  = emitente.cod-emitente.

    RAW-TRANSFER tt-param-int500 TO raw-param.

    RUN intprg/int500rp.p(INPUT raw-param, INPUT TABLE tt-raw-digita).


    log-manager:write-message("KML - depois int500 - cnpj - " + cEmit) no-error.
    log-manager:write-message("KML - depois int500 - nota-fiscal - " + cNF) no-error.
    log-manager:write-message("KML - depois int500 - serie - " + cserie) no-error.

    IF CAN-FIND(FIRST int_ds_docto_xml NO-LOCK 
                WHERE int_ds_docto_xml.CNPJ  = cEmit
                AND   int_ds_docto_xml.serie = cSerie
                AND   int_ds_docto_xml.nNF   = cNF) THEN DO:

        log-manager:write-message("KML - criou int_ds_docto_xml ") no-error.

        RUN pi-integra-cd (OUTPUT p-ok).
        IF p-ok = NO THEN RETURN "OK".
    END.

    IF CAN-FIND(FIRST int_ds_nota_entrada 
                WHERE int_ds_nota_entrada.nen_cnpj_origem_s = cEmit
                AND   int_ds_nota_entrada.nen_serie_s       = cSerie
                AND   int_ds_nota_entrada.nen_notafiscal_n  = int(cNF)) THEN DO:
                        
                FOR FIRST int_ds_nota_entrada NO-LOCK 
                    WHERE int_ds_nota_entrada.nen_cnpj_origem_s = cEmit
                    AND   int_ds_nota_entrada.nen_serie_s       = cSerie
                    AND   int_ds_nota_entrada.nen_notafiscal_n  = int(cNF):

                    IF int_ds_nota_entrada.nen_cnpj_destino_s = "79430682014344" THEN     // era apenas if sem avail
                    DO:
                        
                        RUN intprg/int301rp.p ( INPUT "Entrada"  ,
                                                INPUT "Entrada-compra-Fornecedor" ,
                                                INPUT ROWID(int_ds_nota_entrada) ).
                        
                        
                    END.
                END.
                 
                log-manager:write-message("KML - achou int_ds_nota_entrada ") no-error.
                RUN pi-integra-loja (OUTPUT p-ok, OUTPUT p-statuscode).
                log-manager:write-message("KML - depois pi-integra-loja - p-ok -  " + STRING(p-ok) + " statuscode - " + STRING(p-statuscode) ) no-error.
                
                
                
                
        IF p-ok = NO THEN RETURN "OK".
    END.
    
    RETURN "OK".
END PROCEDURE.

PROCEDURE PI-CTE:
    DEFINE INPUT  PARAMETER pxml AS LONGCHAR.
    DEFINE OUTPUT PARAMETER p-ok AS LOGICAL     NO-UNDO.   
    DEFINE OUTPUT PARAMETER p-statuscode AS INTEGER     NO-UNDO. 
   
     log-manager:write-message("KML - dentro PI-CTE") no-error.
    /* tratar s‚rie */
    if  pXML matches "*serie*" then do:     
        assign cSerie = OnlyNumbers(string(int(findTag(pXML,'serie',1)))) no-error.
        if length(cSerie) > 3 then assign cSerie = substring(cSerie,1,3) no-error.
    end.
    
    IF  pXML matches "*nCT*" then 
        assign cNF   = OnlyNumbers(string(int64(findTag(pXML,'nCT',1)),">>>9999999")) no-error.
    
    if pXML matches "*dhEmi*" then do:
        assign cData = substring(findTag(pXML,'dhEmi',1),1,10) 
               cData = entry(3,cData,"-") + "/" + entry(2,cData,"-")  + "/" + entry(1,cData,"-") no-error.
    end.
    
    if pXML matches "*CNPJ*" then do: 
        /* emitente do documento */
        assign cEmit = string(findTag(pXML,'CNPJ',1)) no-error. 
    
        /* destinatario */
        assign cDest = string(findTag(pXML,'CNPJ',index(pXML,'CNPJ') + 25)) no-error.
    end.

    FIND FIRST emitente NO-LOCK
        WHERE emitente.cgc = cEmit NO-ERROR.
        
    IF NOT AVAIL emitente THEN
    DO:
    
        MESSAGE "EMIT E DEST" SKIP
                cEmit SKIP
                cDest    
            VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
    
        ASSIGN p-statuscode = 400
               p-ok = NO
               c-mensagem = "Emitente nÆo cadastrado na base de dados, nÆo foi possivel integra‡Æo"  .
        
        RETURN "OK".
    END.

    
    log-manager:write-message("KML - antes int500 - PI-CTE ") no-error.
    
    EMPTY TEMP-TABLE tt-param-int500.
    create tt-param-int500.
    assign tt-param-int500.usuario         = c-seg-usuario
           tt-param-int500.destino         = 3
           tt-param-int500.arquivo         = "INT002brp.txt"
           tt-param-int500.data-exec       = today
           tt-param-int500.hora-exec       = time
           tt-param-int500.classifica      = 1
           tt-param-int500.dt-trans-ini    = date(cData)
           tt-param-int500.dt-trans-fin    = DATE(cData)
           tt-param-int500.i-nro-docto-ini = cNF 
           tt-param-int500.i-nro-docto-fin = cNF
           tt-param-int500.i-cod-emit-ini  = emitente.cod-emitente
           tt-param-int500.i-cod-emit-fin  = emitente.cod-emitente.

    RAW-TRANSFER tt-param-int500 TO raw-param.
    
    IF v_cdn_empres_usuar = "10" THEN DO:
    
        RUN intprg/int500-CTErp-merco.p(INPUT raw-param, INPUT TABLE tt-raw-digita).
        
    END.
    
    ELSE DO:
        
         RUN intprg/int500-CTErp.p(INPUT raw-param, INPUT TABLE tt-raw-digita).
        
    END.

    log-manager:write-message("KML - depois int500 - PI-CTE V2 - cnpj - " + cEmit) no-error.
    log-manager:write-message("KML - depois int500 - PI-CTE - nota-fiscal - " + cNF) no-error.
    //log-manager:write-message("KML - depois int500 - nota-fiscal - " + nCT) no-error.
    log-manager:write-message("KML - depois int500 - PI-CTE - serie - " + cserie) no-error.
    
    IF CAN-FIND(FIRST int_ds_docto_xml NO-LOCK 
                WHERE int_ds_docto_xml.CNPJ  = cEmit
                AND   int_ds_docto_xml.serie = cSerie
                AND   int_ds_docto_xml.nNF   = cNF) THEN DO:     
                
                    FOR FIRST int_ds_docto_xml EXCLUSIVE-LOCK 
                        WHERE int_ds_docto_xml.CNPJ  = cEmit
                        AND   int_ds_docto_xml.serie = cSerie
                        AND   int_ds_docto_xml.nNF   = cNF:
                        
        //log-manager:write-message("KML - criou int_ds_docto_xml - PI-CTE" + string(int_ds_docto_xml.CNPJ)).
        
                            FIND FIRST recebimento NO-ERROR.
                            
                            IF recebimento.tipo-documento = "CTE" THEN
                            DO:
                            
                         
                                CREATE tt-INT_DS_DOCTO_XML.
                                BUFFER-COPY INT_DS_DOCTO_XML TO tt-INT_DS_DOCTO_XML.

                                    
                           
                
                //criar a tt-param do int072 e chama-lo por parametro
                                create tt-param-int072.
                                ASSIGN tt-param-int072.destino          = 2
                                       tt-param-int072.arquivo          = "INT072brp.txt"
                                       tt-param-int072.usuario          = c-seg-usuario
                                       tt-param-int072.data-exec        = TODAY
                                       tt-param-int072.hora-exec        = TIME
                                       tt-param-int072.classifica       = 1
                                       tt-param-int072.desc-classifica  = "zzzzzzzz"
                                       tt-param-int072.cod-emitente-fim = int_ds_docto_xml.cod_emitente
                                       tt-param-int072.cod-emitente-ini = int_ds_docto_xml.cod_emitente
                                       tt-param-int072.cod-estabel-fim  = int_ds_docto_xml.cod_estab
                                       tt-param-int072.cod-estabel-ini  = int_ds_docto_xml.cod_estab
                                       tt-param-int072.dt-emis-nota-fim = int_ds_docto_xml.dEmi
                                       tt-param-int072.dt-emis-nota-ini = int_ds_docto_xml.dEmi
                                       tt-param-int072.dt-trans-fim     = int_ds_docto_xml.dt_trans
                                       tt-param-int072.dt-trans-ini     = int_ds_docto_xml.dt_trans
                                       tt-param-int072.nro-docto-fim    = int_ds_docto_xml.nNF
                                       tt-param-int072.nro-docto-ini    = int_ds_docto_xml.nNF
                                       tt-param-int072.serie-docto-fim  = int_ds_docto_xml.serie
                                       tt-param-int072.serie-docto-ini  = int_ds_docto_xml.serie.
                                       
                             
                               raw-transfer tt-param-int072 to raw-param.     
                                
                                RUN intprg/APICTE001-merco.p ( INPUT raw-param,
                                                               INPUT TABLE tt-raw-digita ,
                                                               OUTPUT c-retorno).
                                                             
                                IF c-retorno = "OK" THEN
                                DO:
                                
                                    ASSIGN p-statuscode = 200
                                           p-ok = YES.

        /*                             jsonOutput:ADD("Serie"  , int_ds_nota_entrada.nen_serie_s).                 */
        /*                             jsonOutput:ADD("nen_cnpj_origem_s", int_ds_nota_entrada.nen_cnpj_origem_s). */
        /*                             jsonOutput:ADD("CTE_NUM" ,int_ds_nota_entrada.nen_notafiscal_n).            */
        /*                             jsonOutput:ADD("Retorno", c-retorno).                                       */
        /*                                                                                                         */
        /*                             RETURN "OK".                                                                */
                                    
                                END.
                                
                                ELSE DO:
                                    
                                   ASSIGN p-statuscode = 400
                                          p-ok = NO.
          
                                END.        
                                //RETURN "OK".
                  
                            END.
                
                    END.
                //RUN pi-integra-cd (OUTPUT p-ok).
                IF p-ok = NO THEN RETURN "OK".
    END.

    IF CAN-FIND(FIRST int_ds_nota_entrada 
                WHERE int_ds_nota_entrada.nen_cnpj_origem_s = cEmit
                AND   int_ds_nota_entrada.nen_serie_s       = cSerie
                AND   int_ds_nota_entrada.nen_notafiscal_n  = int(cNF)) THEN DO:
                        
                FOR FIRST int_ds_nota_entrada EXCLUSIVE-LOCK 
                    WHERE int_ds_nota_entrada.nen_cnpj_origem_s = cEmit
                    AND   int_ds_nota_entrada.nen_serie_s       = cSerie
                    AND   int_ds_nota_entrada.nen_notafiscal_n  = int(cNF):
                    
                    FIND FIRST recebimento NO-ERROR.
                    
                    IF recebimento.tipo-documento = "CTE" THEN
                    DO:
                    
                        log-manager:write-message("KML - ENTROU NO CTE") no-error.
                        
                        CREATE tt-INT_DS_NOTA_ENTRADA.
                        BUFFER-COPY INT_DS_NOTA_ENTRADA TO tt-INT_DS_NOTA_ENTRADA .
                        
                        log-manager:write-message("KML 1 - dentro conexao - criou tabela nota  " + cEmit + " - " + cSerie + " - " + cNF ) NO-ERROR.
                        
                        ASSIGN tt-INT_DS_NOTA_ENTRADA.situacao = 1.
                    
                        FOR EACH INT_DS_NOTA_ENTRADA_PRODUT EXCLUSIVE-LOCK
                            WHERE INT_DS_NOTA_ENTRADA_PRODUT.nen_cnpj_origem_s = INT_DS_NOTA_ENTRADA.nen_cnpj_origem_s
                            AND   INT_DS_NOTA_ENTRADA_PRODUT.nen_serie_s       = INT_DS_NOTA_ENTRADA.nen_serie_s      
                            AND   INT_DS_NOTA_ENTRADA_PRODUT.nen_notafiscal_n  = INT_DS_NOTA_ENTRADA.nen_notafiscal_n :
                    
                            CREATE tt-INT_DS_NOTA_ENTRADA_PRODUT.
                            BUFFER-COPY INT_DS_NOTA_ENTRADA_PRODUT TO tt-INT_DS_NOTA_ENTRADA_PRODUT.
                            
                            log-manager:write-message("KML 2 - dentro conexao - criou tabela produtos  " + cEmit + " - " + cSerie + " - " + cNF ) NO-ERROR.
                        END.
                        
                        ASSIGN INT_DS_NOTA_ENTRADA.situacao = 2
                               INT_DS_NOTA_ENTRADA.envio_status = 8.
     
                        log-manager:write-message("KML 3 - ANTES DO INT112"  ) NO-ERROR.
                        
                        //criar a tt-param do int112 e chama-lo por parametro
                        create tt-param-int112.
                        assign tt-param-int112.usuario         = "RPW"
                               tt-param-int112.destino         = 2
                               tt-param-int112.data-exec       = today
                               tt-param-int112.hora-exec       = time
                               tt-param-int112.cnpj_origem     = int_ds_nota_entrada.nen_cnpj_origem_s
                               tt-param-int112.nro-docto       = int_ds_nota_entrada.nen_notafiscal_n
                               tt-param-int112.serie-docto     = int_ds_nota_entrada.nen_serie_s .
                               
                       
                       raw-transfer tt-param-int112 to raw-param.     
                        
                        RUN intprg/APICTE001.p ( INPUT raw-param,
                                                 INPUT TABLE tt-raw-digita ,
                                                 OUTPUT c-retorno).
                                                     
                        IF c-retorno = "OK" THEN
                        DO:
                        
                            ASSIGN p-statuscode = 200
                                   p-ok = YES.

/*                             jsonOutput:ADD("Serie"  , int_ds_nota_entrada.nen_serie_s).                 */
/*                             jsonOutput:ADD("nen_cnpj_origem_s", int_ds_nota_entrada.nen_cnpj_origem_s). */
/*                             jsonOutput:ADD("CTE_NUM" ,int_ds_nota_entrada.nen_notafiscal_n).            */
/*                             jsonOutput:ADD("Retorno", c-retorno).                                       */
/*                                                                                                         */
/*                             RETURN "OK".                                                                */
                            
                        END.
                        
                        ELSE DO:
                            
                           ASSIGN p-statuscode = 400
                                  p-ok = NO.
  
                        END.        
                        //RETURN "OK".
          
                    END.
                END. 
                log-manager:write-message("KML - achou int_ds_nota_entrada ") no-error.
                log-manager:write-message("KML - depois pi-integra-loja - p-ok -  " + STRING(p-ok) + " statuscode - " + STRING(p-statuscode) ) no-error.
                
                
                
                
        IF p-ok = NO THEN RETURN "OK".
    END.
    
    RETURN "OK".
END PROCEDURE.

DEFINE VARIABLE c-token AS CHAR NO-UNDO.
PROCEDURE pi-token:

    DEFINE VARIABLE oClient   AS IHttpClient   NO-UNDO.
    DEFINE VARIABLE oURI      AS URI           NO-UNDO.
    DEFINE VARIABLE oRequest  AS IHttpRequest  NO-UNDO.
    DEFINE VARIABLE hXmlDoc   AS HANDLE        NO-UNDO.
    DEFINE VARIABLE mData     AS MEMPTR        NO-UNDO.
    DEFINE VARIABLE oDocument AS CLASS MEMPTR  NO-UNDO.
    DEFINE VARIABLE oResponse AS IHttpResponse NO-UNDO.
    DEFINE VARIABLE oJson     AS JsonObject    NO-UNDO.
    DEFINE VARIABLE oMemptr   AS OpenEdge.Core.MEMPTR NO-UNDO.
    
    
    DEFINE VARIABLE lc-aux AS LONGCHAR NO-UNDO.
    DEFINE VARIABLE sData  AS STRING        NO-UNDO.
    
    DEFINE VARIABLE oLib           AS OpenEdge.Net.HTTP.IHttpClientLibrary NO-UNDO.
    DEFINE VARIABLE cSSLProtocols  AS CHARACTER          NO-UNDO EXTENT.
    DEFINE VARIABLE cSSLCiphers    AS CHARACTER          NO-UNDO EXTENT.

  //  IF c-token = "" THEN RUN pi-token.
    
    EXTENT(cSSLProtocols) = 3.
    EXTENT(cSSLCiphers) = 12.
    // Supported ciphers and protocols at https://documentation.progress.com/output/ua/OpenEdge_latest/gscsv/supported-protocols,-ciphers,-and-certificates-f.html# 
    ASSIGN cSSLProtocols[1] = 'TLSv1.2'
           cSSLProtocols[2] = 'TLSv1.1'
           cSSLProtocols[3] = 'TLSv1.3'
           cSSLCiphers[1]   = 'AES128-SHA256'
           cSSLCiphers[2]   = 'DHE-RSA-AES128-SHA256'
           cSSLCiphers[3]   = 'AES128-GCM-SHA256' 
           cSSLCiphers[4]   = 'DHE-RSA-AES128-GCM-SHA256'
           cSSLCiphers[5]   = 'ADH-AES128-SHA256'
           cSSLCiphers[6]   = 'ADH-AES128-GCM-SHA256'
           cSSLCiphers[7]   = 'ADH-AES256-SHA256'
           cSSLCiphers[8]   = 'AES256-SHA256' 
           cSSLCiphers[9]   = 'DHE-RSA-AES256-SHA256'
           cSSLCiphers[10]  = 'AES128-SHA'
           cSSLCiphers[11]  = 'ECDHE-RSA-AES128-GCM-SHA256'
           cSSLCiphers[12]  = 'TLS_AES_128_GCM_SHA256'.
    
    //Build a request
    //oURI = URI:Parse('https://nissei.inventti.app/nfe/api/destinadas/Obter';).
    
        ASSIGN oURI        = OpenEdge.Net.URI:Parse("https://portal.cosmospro.com.br:9191")
               oURI:Path   = 'api/login/autenticar?api-version=1.0&Content-Type=application/json&Accept=application/json'.
    
    //https://portal.cosmospro.com.br:9191/api/login/autenticar?api-version=1.0&Content-Type=application/json&Accept=application/json
            
        /*ASSIGN oLib = ClientLibraryBuilder:Build()
                                          :SetSSLProtocols(cSSLProtocols)
                                          :SetSSLCiphers(cSSLCiphers)
                                          :sslVerifyHost(FALSE)
                                          :ServerNameIndicator(oURI:host)
                                          :library.*/

        ASSIGN oLib = ClientLibraryBuilder:Build()
                                          :sslVerifyHost(FALSE)
                                          :ServerNameIndicator(oURI:host)
                                          :library.
         
        ASSIGN oJson = NEW JsonObject().
        oJson:ADD("login","integracaodatasul").
        oJson:ADD("senha","@integracaonissei2023").
    
        //{"login":"integracaodatasul","senha":"@integracaonissei2023"}
                                          
        oRequest  = RequestBuilder:POST(oURI, oJson )
                    :AddHeader("Content-Type", "application/json")
                    :Request.                                      
    
    log-manager:write-message("KML - antes chamada token "  ) NO-ERROR.

    
           //oResponse = ClientBuilder:Build():Client:Execute(oRequest).
    ASSIGN oResponse = ClientBuilder:Build():UsingLibrary(oLib):Client:Execute(oRequest).
    
    IF TYPE-OF(oResponse:Entity,JsonObject) THEN DO:
        oMemptr = CAST(oResponse:Entity, MEMPTR).
    
        c-token = string(oMemptr:GetString(1)).
    END.

    log-manager:write-message("KML - depois chamada token - " + c-token ) NO-ERROR.
    
    RETURN "OK".
END PROCEDURE.

PROCEDURE pi-integra-cd:

    DEFINE OUTPUT PARAMETER p-ok AS LOGICAL     NO-UNDO.

    DEFINE VARIABLE oJson        AS JsonObject    NO-UNDO.
    DEFINE VARIABLE oClient      AS IHttpClient   NO-UNDO.
    DEFINE VARIABLE oURI         AS URI           NO-UNDO.
    DEFINE VARIABLE oRequest     AS IHttpRequest  NO-UNDO.
    DEFINE VARIABLE hXmlDoc      AS HANDLE        NO-UNDO.
    DEFINE VARIABLE mData        AS MEMPTR        NO-UNDO.
    DEFINE VARIABLE oDocument    AS CLASS MEMPTR  NO-UNDO.
    DEFINE VARIABLE oResponse    AS IHttpResponse NO-UNDO.
    DEFINE VARIABLE oJsonRetorno AS JsonObject    NO-UNDO.
    
    DEFINE VARIABLE lc-aux AS LONGCHAR NO-UNDO.
    DEFINE VARIABLE sData  AS STRING        NO-UNDO.
    
    DEFINE VARIABLE oLib           AS OpenEdge.Net.HTTP.IHttpClientLibrary NO-UNDO.
    DEFINE VARIABLE cSSLProtocols  AS CHARACTER          NO-UNDO EXTENT.
    DEFINE VARIABLE cSSLCiphers    AS CHARACTER          NO-UNDO EXTENT.

    p-ok = NO.

    IF c-token = "" THEN RUN pi-token.  // KML arrumar para pegar token automatico

    //IF c-token = "" THEN c-token = "fe38bcda-045c-4e69-9d8c-30c77977d725".
    
    EXTENT(cSSLProtocols) = 3.
    EXTENT(cSSLCiphers) = 12.
    // Supported ciphers and protocols at https://documentation.progress.com/output/ua/OpenEdge_latest/gscsv/supported-protocols,-ciphers,-and-certificates-f.html# 
    ASSIGN cSSLProtocols[1] = 'TLSv1.2'
           cSSLProtocols[2] = 'TLSv1.1'
           cSSLProtocols[3] = 'TLSv1.3'
           cSSLCiphers[1]   = 'AES128-SHA256'
           cSSLCiphers[2]   = 'DHE-RSA-AES128-SHA256'
           cSSLCiphers[3]   = 'AES128-GCM-SHA256' 
           cSSLCiphers[4]   = 'DHE-RSA-AES128-GCM-SHA256'
           cSSLCiphers[5]   = 'ADH-AES128-SHA256'
           cSSLCiphers[6]   = 'ADH-AES128-GCM-SHA256'
           cSSLCiphers[7]   = 'ADH-AES256-SHA256'
           cSSLCiphers[8]   = 'AES256-SHA256' 
           cSSLCiphers[9]   = 'DHE-RSA-AES256-SHA256'
           cSSLCiphers[10]  = 'AES128-SHA'
           cSSLCiphers[11]  = 'ECDHE-RSA-AES128-GCM-SHA256'
           cSSLCiphers[12]  = 'TLS_AES_128_GCM_SHA256'.
    
    //https://api.cosmospro.com.br/api/ExecuteCustomAction/ExecuteAction?ActionName=NotasFiscaisCompra&api-version=1.0&token=84d19f58-716a-4686-9531-8b167c2f1e1e
    ASSIGN oURI        = OpenEdge.Net.URI:Parse("https://api.cosmospro.com.br")
           oURI:Path   = '/api/ExecuteCustomAction/ExecuteAction?ActionName=NotasFiscaisCompra&api-version=1.0&token=' + c-token.

    ASSIGN oLib = ClientLibraryBuilder:Build()
                                      :SetSSLProtocols(cSSLProtocols)
                                      :SetSSLCiphers(cSSLCiphers)
                                      :sslVerifyHost(FALSE)
                                      :ServerNameIndicator(oURI:host)
                                      :library.

    FOR FIRST INT_DS_DOCTO_XML NO-LOCK 
        WHERE INT_DS_DOCTO_XML.CNPJ  = cEmit
        AND   INT_DS_DOCTO_XML.serie = cSerie
        AND   INT_DS_DOCTO_XML.nNF   = cNF:
        CREATE tt-INT_DS_DOCTO_XML.
        BUFFER-COPY INT_DS_DOCTO_XML TO tt-INT_DS_DOCTO_XML.
    
        FOR EACH INT_DS_IT_DOCTO_XML NO-LOCK
            WHERE INT_DS_IT_DOCTO_XML.serie        = INT_DS_DOCTO_XML.serie       
            AND   INT_DS_IT_DOCTO_XML.nNF          = INT_DS_DOCTO_XML.nNF         
            AND   INT_DS_IT_DOCTO_XML.cod_emitente = INT_DS_DOCTO_XML.cod_emitente
            AND   INT_DS_IT_DOCTO_XML.tipo_nota    = INT_DS_DOCTO_XML.tipo_nota   :
    
            CREATE tt-INT_DS_IT_DOCTO_XML.
            BUFFER-COPY INT_DS_IT_DOCTO_XML to tt-INT_DS_IT_DOCTO_XML.
        END.
    END.

    assign oJson = JsonAPIUtils:convertTempTableToJsonObject(DATASET nfCD:HANDLE, NO).
    oJson = oJson:getJsonObject("nfCD").

    //oJson:WriteFile("/totvs/temp/envioCD.json") NO-ERROR.
                                      
    oRequest  = RequestBuilder:POST(oURI, oJson )
                :AddHeader("Content-Type", "application/json")
                :Request
    .                                      
    
    ASSIGN oResponse = ClientBuilder:Build():UsingLibrary(oLib):Client:Execute(oRequest).

    DEFINE VARIABLE c-retorno AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE c-aux AS CHARACTER   NO-UNDO.
    
    ASSIGN c-retorno = STRING(oResponse:Entity).
    //ASSIGN oJsonRetorno = CAST(oResponse:Entity, JsonObject).
    ASSIGN c-aux = "sucesso".

    //LOG-MANAGER:WRITE-MESSAGE("retorno cd - " + STRING(oJsonRetorno:getJsonText())) NO-ERROR.
    //LOG-MANAGER:WRITE-MESSAGE("retorno cd - " + STRING(oJsonRetorno:GetCharacter(c-aux))) NO-ERROR.
    
    LOG-MANAGER:WRITE-MESSAGE("retorno cd - " + c-retorno) NO-ERROR.

    ASSIGN p-ok = LOGICAL(ENTRY(1,SUBSTR(c-retorno,INDEX(c-retorno,c-aux) + 10),'"')) NO-ERROR.
    IF p-ok = ? THEN p-ok = NO.

    ASSIGN c-mensagem = ENTRY(1,SUBSTR(c-retorno,INDEX(c-retorno,"mensagem_processamento") + 25),'"') NO-ERROR.
    
    RETURN "OK".
END PROCEDURE.

PROCEDURE pi-integra-loja:

    DEFINE OUTPUT PARAMETER p-ok            AS LOGICAL     NO-UNDO.
    DEFINE OUTPUT PARAMETER p-statuscode    AS INTEGER     NO-UNDO.
    
    DEFINE VARIABLE oJson     AS JsonObject    NO-UNDO.
    DEFINE VARIABLE oClient   AS IHttpClient   NO-UNDO.
    DEFINE VARIABLE oURI      AS URI           NO-UNDO.
    DEFINE VARIABLE oRequest  AS IHttpRequest  NO-UNDO.
    DEFINE VARIABLE hXmlDoc   AS HANDLE        NO-UNDO.
    DEFINE VARIABLE mData     AS MEMPTR        NO-UNDO.
    DEFINE VARIABLE oDocument AS CLASS MEMPTR  NO-UNDO.
    DEFINE VARIABLE oResponse AS IHttpResponse NO-UNDO.
    
    DEFINE VARIABLE lc-aux AS LONGCHAR NO-UNDO.
    DEFINE VARIABLE sData  AS STRING        NO-UNDO.
    
    DEFINE VARIABLE oLib           AS OpenEdge.Net.HTTP.IHttpClientLibrary NO-UNDO.
    DEFINE VARIABLE cSSLProtocols  AS CHARACTER          NO-UNDO EXTENT.
    DEFINE VARIABLE cSSLCiphers    AS CHARACTER          NO-UNDO EXTENT.
    DEFINE VARIABLE c-sucesso       AS CHARACTER   NO-UNDO.

    log-manager:write-message("KML - antes pi-token " ) NO-ERROR.
    
  //  ASSIGN c-mensagem = c-mensagem + "1 ".

   // IF c-token = "" THEN RUN pi-token.  // KML arrumar para pegar token automatico

    IF c-token = "" THEN c-token = "fe38bcda-045c-4e69-9d8c-30c77977d725".   //0aec3d27-87dd-4477-9021-d6ff780e23c8

    log-manager:write-message("KML - depois pi-token -  " + c-token ) NO-ERROR.
    
    EXTENT(cSSLProtocols) = 3.
    EXTENT(cSSLCiphers) = 3.
    // Supported ciphers and protocols at https://documentation.progress.com/output/ua/OpenEdge_latest/gscsv/supported-protocols,-ciphers,-and-certificates-f.html# 
    ASSIGN cSSLProtocols[1] = 'TLSv1.2'
           cSSLProtocols[2] = 'TLSv1.1'
          // cSSLProtocols[3] = 'TLSv1.3'
           cSSLCiphers[1]   = 'ECDHE-RSA-AES128-GCM-SHA256'
           cSSLCiphers[2]   = 'ECDHE-RSA-AES256-GCM-SHA384'
           cSSLCiphers[3]   = 'ECDHE-RSA-CHACHA20-POLY1305' .
    
    
  //  ASSIGN c-mensagem = c-mensagem + "1.1 ".
    //https://api.cosmospro.com.br/api/ExecuteCustomAction/ExecuteAction?ActionName=NotasFiscaisCompra&api-version=1.0&token=84d19f58-716a-4686-9531-8b167c2f1e1e
    ASSIGN oURI        = OpenEdge.Net.URI:Parse("https://api.cosmospro.com.br")
           //oURI:Path   = '/api/ExecuteCustomAction/ExecuteAction?ActionName=NotasFiscaisCompra&api-version=1.0&token=' + c-token.
           oURI:Path   = '/api/ExecuteCustomAction/ExecuteAction?ActionName=NotasFiscaisCompra&api-version=1.0&token=' + c-token.

  //  ASSIGN c-mensagem = c-mensagem + "1.2 ".

    log-manager:write-message("KML - dentro conexao -  " + oURI:Path ) NO-ERROR.

    ASSIGN oLib = ClientLibraryBuilder:Build()
                                      :sslVerifyHost(FALSE)
                                      :ServerNameIndicator(oURI:host)
                                      :SetSSLProtocols(cSSLProtocols)
                                      :SetSSLCiphers(cSSLCiphers)
                                      :library.
                                      
  //  ASSIGN c-mensagem = c-mensagem + "1.3 ".    
  
  
  log-manager:write-message("KML - dentro conexao -  " + cEmit + " - " + cSerie + " - " + cNF ) NO-ERROR.

    FOR FIRST INT_DS_NOTA_ENTRADA NO-LOCK
        WHERE INT_DS_NOTA_ENTRADA.nen_cnpj_origem_s = cEmit
        AND   INT_DS_NOTA_ENTRADA.nen_serie_s       = cSerie
        AND   INT_DS_NOTA_ENTRADA.nen_notafiscal_n  = int(cNF):

        CREATE tt-INT_DS_NOTA_ENTRADA.
        BUFFER-COPY INT_DS_NOTA_ENTRADA TO tt-INT_DS_NOTA_ENTRADA .
        
        
        log-manager:write-message("KML - dentro conexao - criou tabela nota  " + cEmit + " - " + cSerie + " - " + cNF ) NO-ERROR.
        
        ASSIGN tt-INT_DS_NOTA_ENTRADA.situacao = 1.
    
        FOR EACH INT_DS_NOTA_ENTRADA_PRODUT NO-LOCK
            WHERE INT_DS_NOTA_ENTRADA_PRODUT.nen_cnpj_origem_s = INT_DS_NOTA_ENTRADA.nen_cnpj_origem_s
            AND   INT_DS_NOTA_ENTRADA_PRODUT.nen_serie_s       = INT_DS_NOTA_ENTRADA.nen_serie_s      
            AND   INT_DS_NOTA_ENTRADA_PRODUT.nen_notafiscal_n  = INT_DS_NOTA_ENTRADA.nen_notafiscal_n :
    
            CREATE tt-INT_DS_NOTA_ENTRADA_PRODUT.
            BUFFER-COPY INT_DS_NOTA_ENTRADA_PRODUT TO tt-INT_DS_NOTA_ENTRADA_PRODUT.
            
            log-manager:write-message("KML - dentro conexao - criou tabela produtos  " + cEmit + " - " + cSerie + " - " + cNF ) NO-ERROR.
        END.

        
    END.
    
  //  ASSIGN c-mensagem = c-mensagem + "2 ".
    
    
    log-manager:write-message("KML - antes enviar procfit  " + cEmit + " - " + cSerie + " - " + cNF ) NO-ERROR.
    assign oJson = JsonAPIUtils:convertTempTableToJsonObject(DATASET nfloja:HANDLE, NO).
    oJson = oJson:getJsonObject("nfloja").
         
    log-manager:write-message("KML - antes enviar procfit 2 " + cEmit + " - " + cSerie + " - " + cNF ) NO-ERROR.
    oRequest  = RequestBuilder:POST(oURI, oJson )
                :AddHeader("Content-Type", "application/json")
                :REQUEST. 
                
    log-manager:write-message("KML - antes enviar procfit 3 - teste erro link 2" + cEmit + " - " + cSerie + " - " + cNF ) NO-ERROR.
    ASSIGN oResponse = ClientBuilder:Build():UsingLibrary(oLib):Client:Execute(oRequest). 
    
    
    log-manager:write-message("KML - depois envio procfit 1 ") NO-ERROR.

    DEFINE VARIABLE c-retorno AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE c-aux AS CHARACTER   NO-UNDO.
    
    ASSIGN c-aux = "sucesso".
    ASSIGN c-retorno = STRING(oResponse:Entity) NO-ERROR.  
    ASSIGN p-statuscode = oResponse:statuscode.          
    
    ASSIGN c-sucesso = ENTRY(1,SUBSTR(c-retorno,INDEX(c-retorno,c-aux) + 10),'"') NO-ERROR.
    ASSIGN c-mensagem = ENTRY(1,SUBSTR(c-retorno,INDEX(c-retorno,"mensagem_processamento") + 25),'"') NO-ERROR.

    
    LOG-MANAGER:WRITE-MESSAGE("KML - c-sucesso - " + c-sucesso) NO-ERROR. 
    
    IF c-sucesso = "false" THEN 
        ASSIGN p-statuscode = 400.
    
    IF p-statuscode <> 200 THEN DO:
    
        ASSIGN c-retorno = c-mensagem.
        ASSIGN p-ok = NO.
        RETURN "OK".
       
    END.      

    LOG-MANAGER:WRITE-MESSAGE("KML - retorno conexÆo procfit - " + c-retorno) NO-ERROR.
    
  //  ASSIGN c-mensagem = c-mensagem + "4 ".
    
    ASSIGN p-ok = LOGICAL(ENTRY(1,SUBSTR(c-retorno,INDEX(c-retorno,c-aux) + 10),'"')) NO-ERROR.
    IF p-ok = ? THEN p-ok = NO.

    // KML - Se integrou via api marca como integrado no barramento
    IF p-ok = YES THEN DO:

        FOR FIRST INT_DS_NOTA_ENTRADA EXCLUSIVE-LOCK
            WHERE INT_DS_NOTA_ENTRADA.nen_cnpj_origem_s = cEmit
            AND   INT_DS_NOTA_ENTRADA.nen_serie_s       = cSerie
            AND   INT_DS_NOTA_ENTRADA.nen_notafiscal_n  = int(cNF):

            ASSIGN INT_DS_NOTA_ENTRADA.situacao = 2
                   INT_DS_NOTA_ENTRADA.envio_status = 8.

        END.
            RELEASE INT_DS_NOTA_ENTRADA.

    END.

    ASSIGN c-mensagem = ENTRY(1,SUBSTR(c-retorno,INDEX(c-retorno,"mensagem_processamento") + 25),'"') NO-ERROR.
    
    LOG-MANAGER:WRITE-MESSAGE("KML - depois conexÆo procfit - " + c-mensagem) NO-ERROR.
    RETURN "OK".
END PROCEDURE.

