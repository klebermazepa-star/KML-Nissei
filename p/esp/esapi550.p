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

DEF VAR cXML         AS LONGCHAR NO-UNDO.
DEF VAR dt-ult-envio AS da       NO-UNDO.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Procedure
&Scoped-define DB-AWARE no



/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



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
         HEIGHT             = 11.33
         WIDTH              = 41.14.
/* END WINDOW DEFINITION */
                                                                        */
&ANALYZE-RESUME

 


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Procedure 


/* ***************************  Main Block  *************************** */

RUN pi-inicializar IN h-acomp ("Enviando Faturas").

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

   RUN pi-acompanhar IN h-acomp ("Enviando Faturas").

   IF es-api-aplicacao.Testes  = NO
   THEN ASSIGN
      c-endereco          = es-api-URI.ent-PRD.
   ELSE ASSIGN            
      c-endereco          = es-api-URI.end-TST.


   FIND LAST es-bv-fat-duplic NO-LOCK
       WHERE es-bv-fat-duplic.dt-envio >= 1/1
       NO-ERROR.
   IF AVAIL es-bv-fat-duplic
   THEN ASSIGN
      dt-ult-envio = es-bv-fat-duplic.dt-envio.

   IF dt-ult-envio = ?
   THEN ASSIGN
      dt-ult-envio = 6/1/2021.

   /*
   FOR EACH nota-fiscal NO-LOCK
      WHERE nota-fiscal.dt-emis-nota >= dt-ult-envio,
       EACH fat-duplic NO-LOCK
      WHERE fat-duplic.cod-estabel   =  nota-fiscal.cod-estabel
        AND fat-duplic.serie         =  nota-fiscal.serie
        AND fat-duplic.nr-fatura     =  nota-fiscal.nr-fatura:
      DISP 
         nota-fiscal.dt-emis-nota.

      ASSIGN
         i = i + 1.
      IF i / 100 = INT(i / 100)
      THEN RUN pi-acompanhar IN h-acomp (
                                 STRING(nota-fiscal.dt-emis-nota)
                               + " - " 
                               + STRING(i)
                               ).

      FIND FIRST int_ds_loja_cond_pag NO-LOCK
           WHERE int_ds_loja_cond_pag.cod_cond_pag  = nota-fiscal.cod-cond-pag
             AND int_ds_loja_cond_pag.COD_PORTADOR  = nota-fiscal.cod-portador
             AND int_ds_loja_cond_pag.MODALIDADE    = nota-fiscal.modalidade
             AND int_ds_loja_cond_pag.COD_ESP       = fat-duplic.cod-esp
             AND int_ds_loja_cond_pag.log_boa_vista = YES
           NO-ERROR.
      IF AVAIL int_ds_loja_cond_pag
      THEN DO:
         FIND FIRST es-bv-fat-duplic NO-LOCK
              WHERE es-bv-fat-duplic.cod-estabel = fat-duplic.cod-estabel
                AND es-bv-fat-duplic.serie       = fat-duplic.serie      
                AND es-bv-fat-duplic.nr-fatura   = fat-duplic.nr-fatura  
                AND es-bv-fat-duplic.parcela     = fat-duplic.parcela
              NO-ERROR.
         DISP 
            int_ds_loja_cond_pag.condipag
            int_ds_loja_cond_pag.convenio
            fat-duplic.dt-emissao
            fat-duplic.cod-estabel 
            fat-duplic.serie       
            fat-duplic.nr-fatura   
            fat-duplic.parcela
            WITH SCROLLABLE.
         IF NOT AVAIL es-bv-fat-duplic
         THEN DO:
            CREATE es-bv-fat-duplic.
            ASSIGN
               es-bv-fat-duplic.cod-estabel = fat-duplic.cod-estabel 
               es-bv-fat-duplic.serie       = fat-duplic.serie       
               es-bv-fat-duplic.nr-fatura   = fat-duplic.nr-fatura   
               es-bv-fat-duplic.parcela     = fat-duplic.parcela.
         END.
         DISP
            es-bv-fat-duplic.dt-envio
            .
      END.
   END.
   */

   ASSIGN 
      cXML = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
                <VendasERP>
                   <venda>
                      <id>1</id> 
                      <autorizacao>XYZ123</autorizacao>
                      <bandeira>1</bandeira> 
                      <codigoEstabelecimento>84950</codigoEstabelecimento> 
                      <dataVenda>2012-07-02</dataVenda> 
                      <nsu>123456</nsu> 
                      <nsuHost>1035245</nsuHost> 
                      <tid>5415464654</tid> 
                      <plano>2</plano> 
                      <parcela>1</parcela> 
                      <produto>C</produto> 
                      <rede>2</rede> 
                      <valor>12.5</valor> 
                      <codigoLoja>84950</codigoLoja> 
                      <areaCliente>NF123456</areaCliente> 
                      <modoCaptura>POS</modoCaptura> 
                   </venda>
                   <venda>
                      <id>1</id> 
                      <autorizacao>XYZ123</autorizacao>
                      <bandeira>1</bandeira> 
                      <codigoEstabelecimento>84950</codigoEstabelecimento> 
                      <dataVenda>2012-07-02</dataVenda> 
                      <nsu>123456</nsu> 
                      <nsuHost>1035245</nsuHost> 
                      <tid>5415464654</tid> 
                      <plano>2</plano> 
                      <parcela>2</parcela> 
                      <produto>C</produto> 
                      <rede>2</rede> 
                      <valor>12.5</valor> 
                      <codigoLoja>84950</codigoLoja> 
                      <areaCliente>NF123456</areaCliente> 
                      <modoCaptura>POS</modoCaptura>
                   </venda>
                </VendasERP>'. 

   ASSIGN
      es-api-log.cJSON = cXML.

   RUN piHeader (10,"chaveAcesso" ,es-api-empresa.API_KEY).
   RUN piHeader (20,"chaveSecreta",es-api-empresa.API_SECRET).

   fc-chamada-4(). 

   MESSAGE STRING(es-api-log.cl-retorno)
       VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.

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

