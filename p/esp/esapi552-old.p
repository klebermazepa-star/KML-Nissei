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


DEF BUFFER bf-fat-duplic   FOR fat-duplic.
                           
DEF VAR lcRetorno          AS LONGCHAR        NO-UNDO.
                                              
DEF VAR cXML               AS LONGCHAR        NO-UNDO.
DEF VAR dt-ult-envio       AS da              NO-UNDO.
DEF VAR iReg               AS i        INIT 1 NO-UNDO.                           
DEF VAR iPlano             AS i               NO-UNDO.

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
         HEIGHT             = 11.33
         WIDTH              = 41.14.
/* END WINDOW DEFINITION */
                                                                        */
&ANALYZE-RESUME

 


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Procedure 


/* ***************************  Main Block  *************************** */

RUN pi-inicializar IN h-acomp ("Enviando Faturas").

blk: FOR FIRST es-api-log NO-LOCK
   WHERE ROWID(es-api-log) = rw-registro,
   FIRST es-api-URI       NO-LOCK
      OF es-api-log,
   FIRST es-api-empresa   NO-LOCK
      OF es-api-log,
   FIRST es-api-aplicacao NO-LOCK
      OF es-api-log
      BY es-api-log.flg-processado
      BY es-api-log.dh-request:

   FOR FIRST bf-api-log
       WHERE ROWID(bf-api-log) = ROWID(es-api-log):
      ASSIGN
         bf-api-log.dh-envio       = NOW
         bf-api-log.flg-processado = YES.
      RELEASE bf-api-log.
   END.

   RUN pi-acompanhar IN h-acomp ("Enviando Faturas").

   IF es-api-aplicacao.Testes  = NO
   THEN ASSIGN
      c-endereco          = es-api-URI.ent-PRD.
   ELSE ASSIGN            
      c-endereco          = es-api-URI.end-TST.

   FIND LAST es-bv-fat-duplic NO-LOCK
       WHERE es-bv-fat-duplic.dt-envio >= 1/1/1
       NO-ERROR.
   IF AVAIL es-bv-fat-duplic
   THEN ASSIGN
      dt-ult-envio = es-bv-fat-duplic.dt-envio.

   IF dt-ult-envio = ?
   THEN ASSIGN
      dt-ult-envio = 12/13/2021.
   FOR EACH nota-fiscal NO-LOCK
//      WHERE nota-fiscal.cod-estabel = "025"
//        AND nota-fiscal.serie       = "51"
//        AND nota-fiscal.nr-nota-fis = "0139332",
      WHERE nota-fiscal.dt-emis-nota   >= dt-ult-envio
      //WHERE nota-fiscal.dt-emis-nota   =  11/1
        //AND nota-fiscal.dt-emis-nota   <=  11/8
       ,
       EACH fat-duplic NO-LOCK         
      WHERE fat-duplic.cod-estabel     =  nota-fiscal.cod-estabel
        AND fat-duplic.serie           =  nota-fiscal.serie
        AND fat-duplic.nr-fatura       =  nota-fiscal.nr-fatura,
      FIRST cst_fat_duplic NO-LOCK 
      WHERE cst_fat_duplic.cod_estabel =  fat-duplic.cod-estabel 
        AND cst_fat_duplic.serie       =  fat-duplic.serie 
        AND cst_fat_duplic.nr_fatura   =  fat-duplic.nr-fatura
        AND cst_fat_duplic.parcela     =  fat-duplic.parcela
         BY nota-fiscal.dt-emis-nota
         BY nota-fiscal.cod-estabel
         BY nota-fiscal.serie
         BY nota-fiscal.nr-nota-fis
       //ON ERROR UNDO, LEAVE
       :
      
      ASSIGN
         i = i + 1.
      IF i / 100 = INT(i / 100)
      THEN RUN pi-acompanhar IN h-acomp (
                                 STRING(nota-fiscal.dt-emis-nota)
                               + " - " 
                               + STRING(i)
                               + " - "
                               + STRING(iReg)
                               ).

      IF cst_fat_duplic.nsu_numero = ? 
      THEN NEXT.

      FIND FIRST es-bv-param NO-LOCK
           WHERE es-bv-param.cod-portador = nota-fiscal.cod-portador
             AND es-bv-param.modalidade   = nota-fiscal.modalidade
             AND es-bv-param.ativo        = YES
           NO-ERROR.
      IF AVAIL es-bv-param
      THEN DO:
         /*IF i / 100 = INT(i / 100)
         THEN*/ RUN pi-acompanhar IN h-acomp (
                                    STRING(nota-fiscal.dt-emis-nota)
                                  + " - " 
                                  + STRING(i)
                                  + " - "
                                  + STRING(iReg)
                                  ).
         FIND FIRST es-bv-fat-duplic NO-LOCK
              WHERE es-bv-fat-duplic.cod-estabel = fat-duplic.cod-estabel
                AND es-bv-fat-duplic.serie       = fat-duplic.serie      
                AND es-bv-fat-duplic.nr-fatura   = fat-duplic.nr-fatura  
                AND es-bv-fat-duplic.parcela     = fat-duplic.parcela
              NO-ERROR.
         IF NOT AVAIL es-bv-fat-duplic
         THEN DO:
            DISP 
               nota-fiscal.cod-portador
               nota-fiscal.modalidade  
               fat-duplic.dt-emissao
               fat-duplic.cod-estabel 
               fat-duplic.serie       
               fat-duplic.nr-fatura   
               fat-duplic.parcela
               WITH SCROLLABLE STREAM-IO.

            CREATE es-bv-fat-duplic.
            ASSIGN
               es-bv-fat-duplic.cod-estabel  = fat-duplic.cod-estabel 
               es-bv-fat-duplic.serie        = fat-duplic.serie       
               es-bv-fat-duplic.nr-fatura    = fat-duplic.nr-fatura   
               es-bv-fat-duplic.parcela      = fat-duplic.parcela
               es-bv-fat-duplic.areaCliente  = fat-duplic.cod-estabel
                                             + "/" 
                                             + fat-duplic.serie      
                                             + "/" 
                                             + fat-duplic.nr-fatura  
                                             + "/" 
                                             + fat-duplic.parcela    
               es-bv-fat-duplic.ind-envio    = 1
               es-bv-fat-duplic.dt-emissao   = nota-fiscal.dt-emis-nota
               es-bv-fat-duplic.cod-portador = nota-fiscal.cod-portador
               es-bv-fat-duplic.modalidade   = nota-fiscal.modalidade
               es-bv-fat-duplic.dt-venciment = fat-duplic.dt-vencimen
               es-bv-fat-duplic.vl-parcela   = fat-duplic.vl-parcela
               es-bv-fat-duplic.vl-taxa      = cst_fat_duplic.taxa_admin
               es-bv-fat-duplic.adm_cartao   = cst_fat_duplic.adm_cartao
               .
            ASSIGN
               es-bv-fat-duplic.dt-envio = nota-fiscal.dt-emis-nota
               iPlano                    = 0.
     
            FOR EACH bf-fat-duplic NO-LOCK
               WHERE bf-fat-duplic.cod-estabel   =  nota-fiscal.cod-estabel
                 AND bf-fat-duplic.serie         =  nota-fiscal.serie
                 AND bf-fat-duplic.nr-fatura     =  nota-fiscal.nr-fatura:
               ASSIGN
                  iPlano = iPlano + 1.
            END.
/*   
            MESSAGE 
               "fat-duplic.cod-estabel           " fat-duplic.cod-estabel            SKIP
               "fc-data(nota-fiscal.dt-emis-nota)" fc-data(nota-fiscal.dt-emis-nota) SKIP
               "cst_fat_duplic.nsu_numero        " cst_fat_duplic.nsu_numero         SKIP
               "STRING(iPlano)                   " STRING(iPlano)                    SKIP
               "fat-duplic.parcela               " fat-duplic.parcela                SKIP
               "fc-valor(fat-duplic.vl-parcela)  " fc-valor(fat-duplic.vl-parcela)   SKIP
               "fat-duplic.cod-estabel           " fat-duplic.cod-estabel            SKIP
               "es-bv-fat-duplic.areaCliente     " es-bv-fat-duplic.areaCliente      SKIP
               VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
*/   
            IF iReg = 1
            THEN ASSIGN
               cXML = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
                       <VendasERP>'
                       .
            ASSIGN 
               cXML = cXML
                    + '<venda>
                            <id>1</id> 
                            <autorizacao></autorizacao>
                            <bandeira></bandeira> 
                            <codigoEstabelecimento>' + fat-duplic.cod-estabel + '</codigoEstabelecimento> 
                            <dataVenda>' + fc-data(nota-fiscal.dt-emis-nota) + '</dataVenda> 
                            <nsu>' + cst_fat_duplic.nsu_numero + '</nsu> 
                            <nsuHost></nsuHost> 
                            <tid></tid> 
                            <plano>' + STRING(iPlano) + '</plano> 
                            <parcela>' + fat-duplic.parcela + '</parcela> 
                            <produto></produto> 
                            <rede></rede> 
                            <valor>' + fc-valor(fat-duplic.vl-parcela) + '</valor> 
                            <codigoLoja>' + fat-duplic.cod-estabel + '</codigoLoja> 
                            <areaCliente>' + es-bv-fat-duplic.areaCliente + '</areaCliente> 
                            <modoCaptura></modoCaptura> 
                         </venda>'. 
            IF iReg = 300
            THEN DO:
               ASSIGN
                  cXML = cXML + '</VendasERP>'.
               
               RUN pi-criar-log ("Envio Fat BV",
                                 ">>> " + STRING(nota-fiscal.dt-emis-nota)
                                        + " - " 
                                        + STRING(i)
                                        + " - "
                                        + STRING(iReg),
                                 cXML
                                 ).
               ASSIGN
                  iReg = 0.
               //LEAVE blk.
            END.
            ASSIGN
               iReg = iReg + 1.

         END.
         RELEASE es-bv-fat-duplic.
      END.
   END.

   IF iReg > 1
   THEN DO:
      ASSIGN
         cXML = cXML + '</VendasERP>'.

      RUN pi-criar-log ("Envio Fat BV",
                        ">>> " + STRING(nota-fiscal.dt-emis-nota)
                               + " - " 
                               + STRING(i)
                               + " - "
                               + STRING(iReg),
                        cXML
                       ).
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
   DEF INPUT PARAM cURI      AS  c        NO-UNDO.
   DEF INPUT PARAM cCod      AS  c        NO-UNDO.
   DEF INPUT PARAM cJson     AS  LONGCHAR NO-UNDO.

   DEF BUFFER bf-api-URI FOR es-api-URI.

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
      bf-new-api-log.cl-Envio       = cJson
      .

   IF NOT AVAIL bf-las-api-log 
   THEN ASSIGN
      bf-new-api-log.id-api-log = 1.
   ELSE ASSIGN
      bf-new-api-log.id-api-log = bf-las-api-log.id-api-log + 1.

   FIND FIRST bf-api-URI NO-LOCK
        WHERE bf-api-URI.id-URI = cURI
        NO-ERROR.

   RUN VALUE(bf-api-URI.nom-programa-env) (h-acomp,
                                           1,
                                           ROWID(bf-new-api-log)).
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

