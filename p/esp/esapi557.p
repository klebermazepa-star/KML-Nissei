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

DEF TEMP-TABLE pagamentos NO-UNDO
    FIELD tipo AS c INIT "pagamento".

DEF TEMP-TABLE pagamento NO-UNDO
    FIELD rec                    AS RECID
    FIELD agencia                AS c COLUMN-LABEL "Ag"                       
    FIELD areaCliente            AS c FORMAT "x(22)"                          
    FIELD autorizacao            AS c                                         
    FIELD banco                  AS c COLUMN-LABEL "Bco"                         
    FIELD bandeira               AS c COLUMN-LABEL "Band"                         
    FIELD codigoEstabelecimento  AS c COLUMN-LABEL "Est"                      
    FIELD codigoLojaErp          AS c COLUMN-LABEL "Loja"                     
    FIELD conta                  AS c COLUMN-LABEL "Conta"                         
    FIELD dataVenda              AS c COLUMN-LABEL "Dt!Venda"                         
    FIELD nsu                    AS c COLUMN-LABEL "NSU"                         
    FIELD numeroLote             AS c COLUMN-LABEL "Lote"                     
    FIELD plano                  AS c COLUMN-LABEL "Plano"                         
    FIELD produto                AS c COLUMN-LABEL "Prod"                         
    FIELD rede                   AS c COLUMN-LABEL "Rede"                         
    FIELD statusConciliacao      AS c COLUMN-LABEL "Status"                   
    FIELD parcela                AS c COLUMN-LABEL "Parc"                       
    FIELD situacao               AS c COLUMN-LABEL "Sit" SERIALIZE-NAME "status"
    FIELD valorAdministracao     AS c COLUMN-LABEL "Vl!Admin"                   
    FIELD valorAntecipacao       AS c COLUMN-LABEL "Vl!Antec"                   
    FIELD valorBruto             AS c COLUMN-LABEL "Vl!Bruto"                   
    FIELD horaVenda              AS c COLUMN-LABEL "Hr!Venda"                   
    FIELD modoCaptura            AS c COLUMN-LABEL "Capt"                       
    FIELD tid                    AS c COLUMN-LABEL "TID"                        
    FIELD codigoProduto          AS c COLUMN-LABEL "Cod!Prod"                   
    FIELD dataPagamento          AS c COLUMN-LABEL "Dt!Pagto"                   
    FIELD taxaAntecipacao        AS c COLUMN-LABEL "Taxa!Antec"                   
    FIELD valorLiquido           AS c COLUMN-LABEL "Vl!Liq"                     
    FIELD taxaAdministracao      AS c COLUMN-LABEL "Taxa!Adm"                   
    FIELD valorPago              AS c COLUMN-LABEL "Vl!Pago"                    
    .


DEF DATASET RetornoResponse 
        FOR pagamentos, pagamento
    PARENT-ID-RELATION con FOR pagamentos, pagamento
        PARENT-ID-FIELD rec
    .

DEF VAR lcRetorno          AS LONGCHAR NO-UNDO.


/*
            <agencia>3306</agencia>
            <areaCliente>228/53/0068234/01</areaCliente>
            <autorizacao>020285</autorizacao>
            <banco>001</banco>
            <bandeira>7</bandeira>
            <codigoEstabelecimento>1038841914</codigoEstabelecimento>
            <codigoLojaErp>10132.0228</codigoLojaErp>
            <conta>110000</conta>
            <dataVenda>2021-11-01</dataVenda>
            <nsu>1</nsu>
            <numeroLote>213055010188461</numeroLote>
            <plano>1</plano>
            <produto>D</produto>
            <rede>2</rede>
            <statusConciliacao>1</statusConciliacao>
            <parcela>1</parcela>
            <status>PAG</status>
            <valorAdministracao>0.25</valorAdministracao>
            <valorAntecipacao>0.00</valorAntecipacao>
            <valorBruto>32.70</valorBruto>
            <horaVenda>08:48:29</horaVenda>
            <modoCaptura>TEF/PDV</modoCaptura>
            <tid>                    </tid>
            <codigoProduto>197</codigoProduto>
            <dataPagamento>2021-11-03</dataPagamento>
            <taxaAntecipacao>0.00</taxaAntecipacao>
            <valorLiquido>32.45</valorLiquido>
            <taxaAdministracao>0.75</taxaAdministracao>
            <valorPago>32.45</valorPago>
*/

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
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<RetornoResponse>
    <pagamentos>
        <pagamento>
            <agencia>3306</agencia>
            <areaCliente>228/53/0068234/01</areaCliente>
            <autorizacao>020285</autorizacao>
            <banco>001</banco>
            <bandeira>7</bandeira>
            <codigoEstabelecimento>1038841914</codigoEstabelecimento>
            <codigoLojaErp>10132.0228</codigoLojaErp>
            <conta>110000</conta>
            <dataVenda>2021-11-01</dataVenda>
            <nsu>1</nsu>
            <numeroLote>213055010188461</numeroLote>
            <plano>1</plano>
            <produto>D</produto>
            <rede>2</rede>
            <statusConciliacao>1</statusConciliacao>
            <parcela>1</parcela>
            <status>PAG</status>
            <valorAdministracao>0.25</valorAdministracao>
            <valorAntecipacao>0.00</valorAntecipacao>
            <valorBruto>32.70</valorBruto>
            <horaVenda>08:48:29</horaVenda>
            <modoCaptura>TEF/PDV</modoCaptura>
            <tid>                    </tid>
            <codigoProduto>197</codigoProduto>
            <dataPagamento>2021-11-03</dataPagamento>
            <taxaAntecipacao>0.00</taxaAntecipacao>
            <valorLiquido>32.45</valorLiquido>
            <taxaAdministracao>0.75</taxaAdministracao>
            <valorPago>32.45</valorPago>
        </pagamento>
        <pagamento>
            <agencia>9</agencia>
            <areaCliente>085/53/0212741/01</areaCliente>
            <autorizacao>919234</autorizacao>
            <banco>422</banco>
            <bandeira>1</bandeira>
            <codigoEstabelecimento>1017273747</codigoEstabelecimento>
            <codigoLojaErp>8556.085</codigoLojaErp>
            <conta>117313</conta>
            <dataVenda>2021-11-01</dataVenda>
            <nsu>1</nsu>
            <numeroLote>213051120054588</numeroLote>
            <plano>1</plano>
            <produto>D</produto>
            <rede>2</rede>
            <statusConciliacao>1</statusConciliacao>
            <parcela>1</parcela>
            <status>PAG</status>
            <valorAdministracao>0.17</valorAdministracao>
            <valorAntecipacao>0.00</valorAntecipacao>
            <valorBruto>24.62</valorBruto>
            <horaVenda>07:06:36</horaVenda>
            <modoCaptura>TEF/PDV</modoCaptura>
            <tid>                    </tid>
            <codigoProduto>2</codigoProduto>
            <dataPagamento>2021-11-03</dataPagamento>
            <taxaAntecipacao>0.00</taxaAntecipacao>
            <valorLiquido>24.45</valorLiquido>
            <taxaAdministracao>0.70</taxaAdministracao>
            <valorPago>24.45</valorPago>
        </pagamento>
    </pagamentos>
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
   
   FOR EACH pagamentos:
       DISP 
         pagamentos
         WITH FRAME _1.

      FOR EACH pagamento 
         WHERE pagamento.rec = RECID(pagamentos):
         IF pagamento.situacao = "PAG" 
         THEN DO:
            DISP 
               pagamento EXCEPT rec codigoLojaErp        
               WITH FRAME _2 DOWN STREAM-IO SCROLLABLE.
            FIND FIRST es-bv-fat-duplic 
                 WHERE es-bv-fat-duplic.areaCliente = pagamento.areaCliente
                 NO-ERROR.
            DISP 
               AVAIL es-bv-fat-duplic
               WITH FRAME _2.
            DOWN WITH FRAME _2.
            IF AVAIL es-bv-fat-duplic
            THEN DO:
               IF es-bv-fat-duplic.ind-envio   = 2
               THEN DO:
                   ASSIGN
                      es-bv-fat-duplic.dt-pagto         = DATE(INT(ENTRY(2,pagamento.dataPagamento ,"-")),
                                                               INT(ENTRY(3,pagamento.dataPagamento ,"-")),
                                                               INT(ENTRY(1,pagamento.dataPagamento ,"-")))
                      es-bv-fat-duplic.ret-vl-pago      = DEC(REPLACE(pagamento.valorPago          ,".",","))
                      es-bv-fat-duplic.banco            = INT(pagamento.banco)
                      es-bv-fat-duplic.agencia          = pagamento.agencia
                      es-bv-fat-duplic.conta            = pagamento.conta
          
                      es-bv-fat-duplic.ind-envio        = 3.
          
          
                   RELEASE es-bv-fat-duplic.
               END.
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

