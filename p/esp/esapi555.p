&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12
&ANALYZE-RESUME
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Procedure 
/*------------------------------------------------------------------------
    File        : 
    Purpose     :

    Syntax      :

    Description :

    Author(s)   :
    Created     :
    Notes       :
  ----------------------------------------------------------------------*/
/*          This .W file was created with the Progress AppBuilder.      */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

{esp/esapi505.i}

DEF INPUT PARAM h-acomp       AS HANDLE   NO-UNDO.    
DEF INPUT PARAM i-acao        AS i        NO-UNDO.
DEF INPUT PARAM rw-registro   AS ROWID    NO-UNDO.

DEF          VAR t            AS i        NO-UNDO.
DEF          VAR i-pag        AS i        NO-UNDO.
DEF          VAR httCust      AS HANDLE   NO-UNDO.
DEF          VAR lReturnValue AS LOGICAL  NO-UNDO.

DEF NEW GLOBAL SHARED VAR l-esapi550 AS l NO-UNDO.

SESSION:DEBUG-ALERT = YES.

ASSIGN
   t = TIME.

{esp/esapi505x.i &OPC="OPEN"}


IF i-acao = 0
THEN DO:
   l-esapi550 = NO.
   {esp/esapi505x.i &OPC="CLOSE"}
   RETURN "OK".
END.

DEF TEMP-TABLE RetornoResponse NO-UNDO
    FIELD paginaAtual            AS i
    FIELD totalPaginas           AS i.

DEF TEMP-TABLE Vendas NO-UNDO
    FIELD tipo AS c INIT "Vendas".

DEF TEMP-TABLE venda NO-UNDO
    FIELD rec                    AS RECID
    FIELD agencia                AS c COLUMN-LABEL "Ag"
    FIELD areaCliente            AS c FORMAT "x(22)"    
    FIELD autorizacao            AS c 
    FIELD banco                  AS c COLUMN-LABEL ""
    FIELD bandeira               AS c COLUMN-LABEL ""
    FIELD codigoEstabelecimento  AS c COLUMN-LABEL "Est"
    FIELD codigoLojaErp          AS c COLUMN-LABEL "Loja"     
    FIELD conta                  AS c COLUMN-LABEL ""         
    FIELD dataVenda              AS c COLUMN-LABEL ""        FORMAT "x(10)"
    FIELD nsu                    AS c COLUMN-LABEL ""
    FIELD numeroLote             AS c COLUMN-LABEL "Lote"
    FIELD plano                  AS c COLUMN-LABEL ""
    FIELD produto                AS c COLUMN-LABEL ""
    FIELD rede                   AS c COLUMN-LABEL ""
    FIELD statusConciliacao      AS c COLUMN-LABEL "Status"
    FIELD dataCredito            AS c COLUMN-LABEL "Credito" FORMAT "x(10)"
    FIELD numeroCartao           AS c COLUMN-LABEL ""
    FIELD parcela                AS c COLUMN-LABEL ""
    FIELD taxaAdministracao      AS c COLUMN-LABEL "Taxa"
    FIELD valorVenda             AS c COLUMN-LABEL "Valor"
    FIELD horaVenda              AS c COLUMN-LABEL "Hora"
    FIELD modoCaptura            AS c COLUMN-LABEL ""
    FIELD tid                    AS c COLUMN-LABEL ""
    FIELD codigoProduto          AS c COLUMN-LABEL "Produto"
    FIELD maquinaLoja            AS c COLUMN-LABEL "Maquina"
    FIELD valorTaxaAdministracao AS c COLUMN-LABEL "Valor!Taxa"
    FIELD valorLiquidoParcela    AS c COLUMN-LABEL "Valor!Liquido"
    FIELD valorParcela           AS c COLUMN-LABEL "Valor"
    FIELD situacao               AS c COLUMN-LABEL "" SERIALIZE-NAME "status"
    .


DEF DATASET RetornoResponse 
        FOR vendas, venda
    PARENT-ID-RELATION con FOR vendas, venda
        PARENT-ID-FIELD rec
    .

DEF VAR lcRetorno          AS LONGCHAR NO-UNDO.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Procedure
&Scoped-define DB-AWARE no



/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&IF DEFINED(EXCLUDE-fc-data) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD fc-data Procedure 
FUNCTION fc-data RETURNS CHARACTER
  ( d AS DATE )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-fc-valor) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD fc-valor Procedure 
FUNCTION fc-valor RETURNS CHARACTER
  ( v LIKE fat-duplic.vl-parcela )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Procedure
   Allow: 
   Frames: 0
   Add Fields to: Neither
   Other Settings: CODE-ONLY COMPILE
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
/* DESIGN Window definition (used by the UIB) 
  CREATE WINDOW Procedure ASSIGN
         HEIGHT             = 13.63
         WIDTH              = 55.72.
/* END WINDOW DEFINITION */
                                                                        */
&ANALYZE-RESUME

 


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Procedure 


/* ***************************  Main Block  *************************** */

blk: FOR FIRST es-api-log
   WHERE ROWID(es-api-log) = rw-registro,
   FIRST es-api-URI       NO-LOCK
      OF es-api-log,
   FIRST es-api-empresa   NO-LOCK
      OF es-api-log,
   FIRST es-api-aplicacao NO-LOCK
      OF es-api-log
      BY es-api-log.flg-processado
      BY es-api-log.dh-request:

   ASSIGN
      es-api-log.dh-envio       = NOW
      es-api-log.flg-processado = YES.

   IF es-api-aplicacao.Testes  = NO
   THEN ASSIGN
      c-endereco          = es-api-URI.ent-PRD.
   ELSE ASSIGN            
      c-endereco          = es-api-URI.end-TST.

   MESSAGE "Pagina Enviada ==> " ENTRY(2,es-api-log.aux).

   RUN piHeader (10,"chaveAcesso" ,es-api-empresa.API_KEY).
   RUN piHeader (20,"chaveSecreta",es-api-empresa.API_SECRET).

   fc-chamada-4(). 

   lcRetorno = es-api-log.cl-retorno.

/*
   lcRetorno = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<RetornoResponse>
    <vendas>
        <venda>
            <agencia>1</agencia>
            <areaCliente>001/51/0103621/01</areaCliente>
            <autorizacao>563547</autorizacao>
            <banco>246</banco>
            <bandeira>2</bandeira>
            <codigoEstabelecimento>1038841914</codigoEstabelecimento>
            <codigoLojaErp>10132.0228</codigoLojaErp>
            <conta>2207412</conta>
            <dataVenda>2020-09-29</dataVenda>
            <nsu>126</nsu>
            <numeroLote>202745060261726</numeroLote>
            <plano>1</plano>
            <produto>D</produto>
            <rede>2</rede>
            <statusConciliacao>2</statusConciliacao>
            <dataCredito>2020-10-01</dataCredito>
            <numeroCartao>502121******1007000</numeroCartao>
            <parcela>1</parcela>
            <taxaAdministracao>0.80</taxaAdministracao>
            <valorVenda>26.89</valorVenda>
            <horaVenda></horaVenda>
            <modoCaptura>TEF/PDV</modoCaptura>
            <tid>                    </tid>
            <codigoProduto>343</codigoProduto>
            <maquinaLoja>42215240</maquinaLoja>
            <valorTaxaAdministracao>1.10</valorTaxaAdministracao>
            <valorLiquidoParcela>26.67</valorLiquidoParcela>
            <valorParcela>10.10</valorParcela>
            <status>PAG</status>
        </venda>
        <venda>
            <agencia>7285</agencia>
            <areaCliente>001/51/0103682/01</areaCliente>
            <autorizacao>684867</autorizacao>
            <banco>341</banco>
            <bandeira>1</bandeira>
            <codigoEstabelecimento>1030940549</codigoEstabelecimento>
            <codigoLojaErp>8626.0185</codigoLojaErp>
            <conta>9511</conta>
            <dataVenda>2020-09-29</dataVenda>
            <nsu>147</nsu>
            <numeroLote>202741170100371</numeroLote>
            <plano>1</plano>
            <produto>D</produto>
            <rede>2</rede>
            <statusConciliacao>2</statusConciliacao>
            <dataCredito>2020-10-01</dataCredito>
            <numeroCartao>498442******9048000</numeroCartao>
            <parcela>1</parcela>
            <taxaAdministracao>0.70</taxaAdministracao>
            <valorVenda>16.92</valorVenda>
            <horaVenda></horaVenda>
            <modoCaptura>TEF/PDV</modoCaptura>
            <tid>                    </tid>
            <codigoProduto>2</codigoProduto>
            <maquinaLoja>42171877</maquinaLoja>
            <valorTaxaAdministracao>2.20</valorTaxaAdministracao>
            <valorLiquidoParcela>16.80</valorLiquidoParcela>
            <valorParcela>20.20</valorParcela>
            <status>PAG</status>
        </venda>
    </vendas>
    <paginaAtual>1</paginaAtual>
    <totalPaginas>13879</totalPaginas>
</RetornoResponse>'.
*/

   TEMP-TABLE RetornoResponse:READ-XML("longchar",lcRetorno,?,?,?).
   DATASET RetornoResponse:READ-XML("longchar",lcRetorno,?,?,?).

   FOR EACH RetornoResponse:
      DISP 
         RetornoResponse
         WITH STREAM-IO.

      FIND FIRST bf-api-log 
           WHERE bf-api-log.id-api-log = INT(ENTRY(1,es-api-log.aux))
           NO-ERROR.
      ASSIGN
         bf-api-log.aux = STRING(bf-api-log.id-api-log)
                        + ","
                        + STRING(RetornoResponse.paginaAtual)
                        + ","
                        + STRING(RetornoResponse.totalPaginas)
         .
      RUN pi-acompanhar IN h-acomp (STRING(RetornoResponse.paginaAtual)
                                  + "/"
                                  + STRING(RetornoResponse.totalPaginas)).
   END.
   
   FOR EACH vendas:
      FOR EACH venda 
         WHERE venda.rec = RECID(vendas):
         DISP 
            vendas.
         DISP 
            venda
            WITH STREAM-IO SCROLLABLE.
         FIND FIRST es-bv-fat-duplic 
              WHERE es-bv-fat-duplic.areaCliente = venda.areaCliente
              NO-ERROR.
         DISP AVAIL es-bv-fat-duplic.
         IF AVAIL es-bv-fat-duplic
         THEN DO:
            IF es-bv-fat-duplic.ind-envio   = 1
            THEN DO:
                FIND FIRST fat-duplic 
                     WHERE fat-duplic.cod-estabel       = es-bv-fat-duplic.cod-estabel 
                       AND fat-duplic.serie             = es-bv-fat-duplic.serie 
                       AND fat-duplic.nr-fatura         = es-bv-fat-duplic.nr-fatura
                       AND fat-duplic.parcela           = es-bv-fat-duplic.parcela
                     NO-ERROR.
                FIND FIRST cst_fat_duplic 
                     WHERE cst_fat_duplic.cod_estabel   = es-bv-fat-duplic.cod-estabel 
                       AND cst_fat_duplic.serie         = es-bv-fat-duplic.serie 
                       AND cst_fat_duplic.nr_fatura     = es-bv-fat-duplic.nr-fatura
                       AND cst_fat_duplic.parcela       = es-bv-fat-duplic.parcela
                     NO-ERROR.
       
                ASSIGN
                   es-bv-fat-duplic.ret-dt-venciment = DATE(INT(ENTRY(2,venda.dataCredito      ,"-")),
                                                            INT(ENTRY(3,venda.dataCredito      ,"-")),
                                                            INT(ENTRY(1,venda.dataCredito      ,"-")))
                   es-bv-fat-duplic.ret-vl-parcela   = DEC(REPLACE(venda.valorParcela          ,".",","))
                   es-bv-fat-duplic.ret-vl-taxa      = DEC(REPLACE(venda.valorTaxaAdministracao,".",","))
       
                   es-bv-fat-duplic.ind-envio        = 2.
       
                ASSIGN
                   es-bv-fat-duplic.ind-conciliacao  = 1.
       
                IF (es-bv-fat-duplic.ret-dt-venciment <> es-bv-fat-duplic.dt-venciment 
                OR  es-bv-fat-duplic.ret-vl-parcela   <> es-bv-fat-duplic.vl-parcela   
                OR  es-bv-fat-duplic.ret-vl-taxa      <> es-bv-fat-duplic.vl-taxa      )
                THEN ASSIGN
                   es-bv-fat-duplic.ind-conciliacao  = 3.
       
                IF  es-bv-fat-duplic.ret-dt-venciment <> es-bv-fat-duplic.dt-venciment 
                THEN ASSIGN
                   fat-duplic.dt-vencimen    = es-bv-fat-duplic.ret-dt-venciment.
       
                IF  es-bv-fat-duplic.ret-vl-parcela   <> es-bv-fat-duplic.vl-parcela   
                THEN ASSIGN
                   fat-duplic.vl-parcela     = es-bv-fat-duplic.ret-vl-parcela.
       
                IF  es-bv-fat-duplic.ret-vl-taxa      <> es-bv-fat-duplic.vl-taxa
                THEN ASSIGN
                   cst_fat_duplic.taxa_admin = es-bv-fat-duplic.ret-vl-taxa.
       
                RELEASE es-bv-fat-duplic.
                RELEASE fat-duplic.
                RELEASE cst_fat_duplic.
            END.
         END.
      END.
   END.

   RELEASE es-api-log.
END.

{esp/esapi505x.i &OPC="CLOSE"}

RETURN "OK".

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&IF DEFINED(EXCLUDE-pi-criar-log) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-criar-log Procedure 
PROCEDURE pi-criar-log :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
   DEF BUFFER bf-las-api-log FOR es-api-log.
   DEF BUFFER bf-new-api-log FOR es-api-log.
   DEF INPUT PARAM cURI      AS  c NO-UNDO.
   DEF INPUT PARAM cCod      AS  c NO-UNDO.
   DEF INPUT PARAM cJson     AS  c NO-UNDO.

   IF cJSON = ""
   THEN RETURN.

   FIND LAST bf-las-api-log NO-LOCK
       WHERE bf-las-api-log.id-api-log > 0
       NO-ERROR.
   CREATE bf-new-api-log.
   ASSIGN
      bf-new-api-log.seqexec        = es-api-log.seqexec     
      bf-new-api-log.id-aplicacao   = es-api-log.id-aplicacao
      bf-new-api-log.id-codigo      = es-api-log.id-codigo   
      bf-new-api-log.id-URI         = cURI
      bf-new-api-log.dh-request     = NOW
      bf-new-api-log.end-envio      = es-api-log.end-envio
      bf-new-api-log.flg-processado = NO
      bf-new-api-log.Origem         = es-api-log.Origem
      bf-new-api-log.aux            = cCod
      bf-new-api-log.cJSON          = cJson
      .

   IF NOT AVAIL bf-las-api-log 
   THEN ASSIGN
      bf-new-api-log.id-api-log = 1.
   ELSE ASSIGN
      bf-new-api-log.id-api-log = bf-las-api-log.id-api-log + 1.

   RELEASE bf-new-api-log.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

/* ************************  Function Implementations ***************** */

&IF DEFINED(EXCLUDE-fc-data) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION fc-data Procedure 
FUNCTION fc-data RETURNS CHARACTER
  ( d AS DATE ) :
/*------------------------------------------------------------------------------
  Purpose:  
    Notes:  
------------------------------------------------------------------------------*/

  RETURN STRING(YEAR(d)) + "-" + STRING(MONTH(d),"99") + "-" + STRING(DAY(d),"99").

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-fc-valor) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION fc-valor Procedure 
FUNCTION fc-valor RETURNS CHARACTER
  ( v LIKE fat-duplic.vl-parcela ) :
/*------------------------------------------------------------------------------
  Purpose:  
    Notes:  
------------------------------------------------------------------------------*/

  RETURN REPLACE(STRING(v),",",".").

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

