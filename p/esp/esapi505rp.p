&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12
&ANALYZE-RESUME
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Procedure 
/*:T *******************************************************************************
** Copyright TOTVS S.A. (2009)
** Todos os Direitos Reservados.
**
** Este fonte e de propriedade exclusiva da TOTVS, sua reproducao
** parcial ou total por qualquer meio, so podera ser feita mediante
** autorizacao expressa.
*******************************************************************************/
{include/i-prgvrs.i RELATOR 2.00.10.000 } /*** 01010000 ***/

/* Chamada a include do gerenciador de licen‡as. Necessario alterar os parametros */
/*                                                                                */
/* <programa>:  Informar qual o nome do programa.                                 */
/* <m¢dulo>:  Informar qual o m¢dulo a qual o programa pertence.                  */

&IF "{&EMSFND_VERSION}" >= "1.00" &THEN
    {include/i-license-manager.i <programa> <m¢dulo>}
&ENDIF

/* ***************************  Definitions  ************************** */
&GLOBAL-DEFINE programa esapi505RP

/* Pré-Processador para ativar ou não a saída para RTF */


/* Pré-Processador para setar o tamanho da página */
&SCOPED-DEFINE pagesize 65

/* Include padrão para variáveis de relatório */
{include/i-rpvar.i}

/* Definição das variáveis */
DEF VAR c-liter-par          AS CHARACTER FORMAT "x(13)":U.
DEF VAR c-liter-sel          AS CHARACTER FORMAT "x(10)":U.
DEF VAR c-liter-imp          AS CHARACTER FORMAT "x(12)":U.    
DEF VAR c-destino            AS CHARACTER FORMAT "x(15)":U.
/* Fim definição variáveis */

/* Definição das Temp Tables */
DEF temp-table tt-param no-undo
    field destino          as integer
    field arquivo          as char format "x(35)"
    field usuario          as char format "x(12)"
    field data-exec        as date
    field hora-exec        as integer.

DEF temp-table tt-digita no-undo
    field ordem            as integer   format ">>>>9"
    field exemplo          as character format "x(30)"
    index id ordem.

DEF TEMP-TABLE tt-raw-digita
    FIELD raw-digita AS RAW.
/* Fim Definição das Temp Tables */

/* Parâmetros de entrada para relatório */
DEF INPUT PARAMETER raw-param AS RAW NO-UNDO.
DEF INPUT PARAMETER TABLE FOR tt-raw-digita.
/* Fim parâmetros de entrada */

/* Handle de acompanhamento */
DEF VAR h-acomp         AS HANDLE NO-UNDO.    

/* Definição das Frames do relatório */
FORM
    SKIP(1)
    c-liter-sel         NO-LABEL
    SKIP(1)
    SKIP(1)

    SKIP(1)
    c-liter-par         NO-LABEL
    SKIP(1)
    SKIP(1)

    SKIP(1)
    c-liter-imp         NO-LABEL
    SKIP(1)
    c-destino           COLON 40 "-"
    tt-param.arquivo    NO-LABEL
    tt-param.usuario    COLON 40
    SKIP(1)
    WITH STREAM-IO SIDE-LABELS NO-ATTR-SPACE NO-BOX WIDTH 132 FRAME f-impressao.

FORM
    WITH NO-BOX WIDTH 132 DOWN STREAM-IO FRAME f-relat.

{include/i-rpcab.i}

DEF VAR c-endereco AS c  NO-UNDO.
DEF VAR c-erro     AS c  NO-UNDO.
DEF VAR i-seq      AS de NO-UNDO.
DEF VAR l          AS l  NO-UNDO.

DEF BUFFER bf-api-log FOR es-api-log.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Procedure
&Scoped-define DB-AWARE no



/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&IF DEFINED(EXCLUDE-fc-retorno) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD fc-retorno Procedure 
FUNCTION fc-retorno RETURNS CHARACTER
  ( cCod AS CHARACTER )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Procedure Template
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
         HEIGHT             = 9.13
         WIDTH              = 40.
/* END WINDOW DEFINITION */
                                                                        */
&ANALYZE-RESUME

 


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Procedure 


CREATE tt-param.
RAW-TRANSFER raw-param TO tt-param.

FOR EACH tt-raw-digita:
   CREATE tt-digita.
   RAW-TRANSFER tt-raw-digita.raw-digita TO tt-digita.
END.

FIND FIRST param-global NO-LOCK
     NO-ERROR.

/* Bloco principal do programa */
{utp/ut-liter.i titulo_sistema * }
ASSIGN c-sistema = RETURN-VALUE.
{utp/ut-liter.i titulo_relatorio * }
ASSIGN c-titulo-relat = RETURN-VALUE.
ASSIGN c-empresa     = param-global.grupo
       c-programa    = "{&programa}":U
       c-versao      = "1.00":U
       c-revisao     = "000"
       c-destino     = {varinc/var00002.i 04 tt-param.destino}.

/* Fim bloco principal */

RUN utp/ut-acomp.p PERSISTENT SET h-acomp.  
RUN pi-inicializar IN h-acomp ("Fase 1"). 

{include/i-rpout.i}

//IF NO THEN
DO ON STOP UNDO, LEAVE: 
   
   PUT UNFORMATTED
      "Processamento de chamadas de API - esapi505RP"  SKIP
      NOW                                              SKIP(1).

   //MESSAGE 0.1 VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
   
   /**/
   FOR EACH es-api-aplicacao NO-LOCK:
      IF es-api-aplicacao.ativo = NO
      THEN NEXT.
      RUN pi-inicializar IN h-acomp (es-api-aplicacao.id-aplicacao + " " + es-api-aplicacao.nome). 
      DISP 
         es-api-aplicacao.id-aplicacao COLUMN-LABEL "Aplica‡Æo"
         es-api-aplicacao.nome
         es-api-aplicacao.Testes
         WITH STREAM-IO DOWN.
      FOR EACH es-api-app-URI NO-LOCK
            OF es-api-aplicacao,
         FIRST es-api-URI NO-LOCK
            OF es-api-app-URI
            BY es-api-app-URI.seqexec:
         IF es-api-app-URI.ativo = NO
         THEN NEXT.
         IF es-api-URI.ativo     = NO
         THEN NEXT.
         IF es-api-URI.flg-batch = NO
         THEN NEXT.
         FOR EACH es-api-app-empresa NO-LOCK
               OF es-api-app-URI,
             EACH es-api-empresa     NO-LOCK
               OF es-api-app-empresa:
            IF es-api-app-empresa.ativo = NO
            THEN NEXT.
            IF es-api-empresa.ativo     = NO
            THEN NEXT.

            RUN pi-acompanhar IN h-acomp ("Gerando pedidos").
            FIND LAST bf-api-log NO-LOCK
                WHERE bf-api-log.id-api-log > 0
                NO-ERROR.
            CREATE es-api-log.
            ASSIGN
               i-seq                     = i-seq + 10
               es-api-log.seqexec        = i-seq
               es-api-log.id-aplicacao   = es-api-aplicacao.id-aplicacao
               es-api-log.id-codigo      = es-api-empresa.id-codigo
               es-api-log.id-URI         = es-api-URI.id-URI
               es-api-log.dh-request     = NOW
               es-api-log.end-envio      = c-endereco
               es-api-log.flg-processado = NO
               es-api-log.Origem         = "BATCH"
               .
            IF NOT AVAIL bf-api-log 
            THEN ASSIGN
               es-api-log.id-api-log = 1.
            ELSE ASSIGN
               es-api-log.id-api-log = bf-api-log.id-api-log + 1.

            RUN VALUE(es-api-URI.nom-programa-env) (h-acomp,
                                                          0,
                                                          ROWID(es-api-log)).
            RELEASE es-api-log.
         END.
         //RUN pi-execucao (es-api-URI.id-URI).
      END.
   END.
   /**/
   
   /*
   FOR EACH es-api-log NO-LOCK
      WHERE es-api-log.id-api-log     > 0
        AND es-api-log.flg-processado = NO,
      FIRST es-api-URI NO-LOCK
         OF es-api-log
      WHERE es-api-URI.flg-batch      = YES,
      FIRST es-api-empresa NO-LOCK
         OF es-api-log,
      FIRST es-api-aplicacao NO-LOCK
         OF es-api-log
         BY es-api-log.id-api-log:
      RUN VALUE(es-api-URI.nom-programa-env) (h-acomp,
                                              0,
                                              ROWID(es-api-log)).
   END.
   */
END.

//IF NO THEN
DO: //ON STOP UNDO, LEAVE: 
   RUN pi-inicializar IN h-acomp ("Fase 2"). 
   blk: DO WHILE TRUE:
//      MESSAGE 2.1 VIEW-AS ALERT-BOX INFORMATION BUTTONS YES-NO UPDATE ll AS l. IF ll THEN STOP.
      RUN pi-execucao-1.
      ASSIGN
         l = NO.
      FIND FIRST bf-api-log NO-LOCK
           WHERE bf-api-log.flg-processado = NO
           NO-ERROR.
      FOR  EACH bf-api-log NO-LOCK
          WHERE bf-api-log.flg-processado = NO,
          FIRST es-api-URI NO-LOCK
             OF bf-api-log
          WHERE es-api-URI.flg-batch = YES:
         ASSIGN
            l = YES.
      END.
//      MESSAGE 2.2 l VIEW-AS ALERT-BOX INFORMATION BUTTONS YES-NO UPDATE ll. IF ll THEN STOP.
      IF l = NO
      THEN LEAVE.
   END.

END.

{include/i-rpclo.i}
RUN pi-finalizar IN h-acomp.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&IF DEFINED(EXCLUDE-pi-execucao) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-execucao Procedure 
PROCEDURE pi-execucao :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
   DEF INPUT PARAM c-id-URI LIKE es-api-URI.id-URI NO-UNDO.

   blk: DO WHILE TRUE:
      FIND  NEXT es-api-log NO-LOCK
           WHERE es-api-log.flg-processado = NO
           NO-ERROR.
      
      IF AVAIL es-api-log
      THEN DO:
         
         IF c-id-URI <> ""
         THEN DO:
            IF c-id-URI <> es-api-log.id-URI
            THEN NEXT.
         END.

         FIND FIRST es-api-URI NO-LOCK
                 OF es-api-log
              NO-ERROR.
         FIND FIRST es-api-empresa NO-LOCK
                 OF es-api-log
              NO-ERROR.
         FIND FIRST es-api-aplicacao NO-LOCK
                 OF es-api-log
              NO-ERROR.
         
         RUN pi-acompanhar IN h-acomp ("Executando pedidos 1").
   
         ASSIGN
            c-endereco          = "".
      
         IF es-api-aplicacao.Testes  = NO
         THEN ASSIGN
            c-endereco          = es-api-URI.ent-PRD.
         ELSE ASSIGN            
            c-endereco          = es-api-URI.end-TST.
   
         DISP 
            es-api-log.id-api-log    COLUMN-LABEL "ID"
            es-api-URI.id-URI        COLUMN-LABEL "Cod URI"
            es-api-URI.nome
            c-endereco               COLUMN-LABEL "URI"
                                     FORMAT "x(90)"
            es-api-empresa.id-codigo COLUMN-LABEL "Empresa"
            es-api-empresa.nome
            es-api-log.dh-request    FORMAT "99/99/9999 HH:MM:SS":U
                                     COLUMN-LABEL "Request"
            es-api-log.dh-envio      FORMAT "99/99/9999 HH:MM:SS":U
            WITH FRAME _1 STREAM-IO DOWN WIDTH 500.
      
         RUN VALUE(es-api-URI.nom-programa-env) (h-acomp,
                                                 1,
                                                 ROWID(es-api-log)).
         IF RETURN-VALUE = "NOK" 
         THEN LEAVE blk.
   
         DISP
            es-api-log.dh-retorno    FORMAT "99/99/9999 HH:MM:SS":U
            fc-retorno(es-api-log.cod-retorno)
                                     COLUMN-LABEL "Cod Retorno"
                                     FORMAT "x(22)"
            WITH FRAME _1.
      END.
      ELSE LEAVE.
   END.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-pi-execucao-1) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-execucao-1 Procedure 
PROCEDURE pi-execucao-1 :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

//   MESSAGE 23 VIEW-AS ALERT-BOX INFORMATION BUTTONS YES-NO UPDATE ll AS l. IF ll THEN STOP.   
   blk: 
   FOR EACH es-api-log NO-LOCK
      WHERE es-api-log.id-api-log     > 0
        AND es-api-log.flg-processado = NO,
      FIRST es-api-URI NO-LOCK
         OF es-api-log
      WHERE es-api-URI.flg-batch      = YES,
      FIRST es-api-empresa NO-LOCK
         OF es-api-log,
      FIRST es-api-aplicacao NO-LOCK
         OF es-api-log
         BY es-api-log.id-api-log:

      RUN pi-acompanhar IN h-acomp ("Executando pedidos").
   
      ASSIGN
         c-endereco          = "".
      
      IF es-api-aplicacao.Testes  = NO
      THEN ASSIGN
         c-endereco          = es-api-URI.ent-PRD.
      ELSE ASSIGN            
         c-endereco          = es-api-URI.end-TST.
   
      DISP 
         es-api-log.id-api-log    COLUMN-LABEL "ID"
         es-api-URI.id-URI        COLUMN-LABEL "Cod URI"
         es-api-URI.nome
         c-endereco               COLUMN-LABEL "URI"
                                  FORMAT "x(90)"
         es-api-empresa.id-codigo COLUMN-LABEL "Empresa"
         es-api-empresa.nome
         es-api-log.dh-request    FORMAT "99/99/9999 HH:MM:SS":U
                                  COLUMN-LABEL "Request"
         es-api-log.dh-envio      FORMAT "99/99/9999 HH:MM:SS":U
         WITH FRAME _1 STREAM-IO DOWN WIDTH 500.

//      MESSAGE 24 VIEW-AS ALERT-BOX INFORMATION BUTTONS YES-NO UPDATE ll . IF ll THEN STOP.   

      
      RUN VALUE(es-api-URI.nom-programa-env) (h-acomp,
                                              1,
                                              ROWID(es-api-log)).

      IF RETURN-VALUE = "NOK" 
      THEN LEAVE blk.
   
      DISP
         es-api-log.dh-retorno    FORMAT "99/99/9999 HH:MM:SS":U
         fc-retorno(es-api-log.cod-retorno)
                                  COLUMN-LABEL "Cod Retorno"
                                  FORMAT "x(22)"
         WITH FRAME _1.
   END.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

/* ************************  Function Implementations ***************** */

&IF DEFINED(EXCLUDE-fc-retorno) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION fc-retorno Procedure 
FUNCTION fc-retorno RETURNS CHARACTER
  ( cCod AS CHARACTER ) :
/*------------------------------------------------------------------------------
  Purpose:  
    Notes:  
------------------------------------------------------------------------------*/
  DEF VAR cRet AS c NO-UNDO.

  IF cCod = "200" THEN ASSIGN cRet = "OK".
  IF cCod = "202" THEN ASSIGN cRet = "Accepted".
  IF cCod = "201" THEN ASSIGN cRet = "Created".
  IF cCod = "401" THEN ASSIGN cRet = "Unauthorized".
  IF cCod = "402" THEN ASSIGN cRet = "Payment Required".
  IF cCod = "403" THEN ASSIGN cRet = "Forbidden".
  IF cCod = "404" THEN ASSIGN cRet = "Not Found".
  IF cCod = "406" THEN ASSIGN cRet = "Not Acceptable".
  IF cCod = "422" THEN ASSIGN cRet = "Unprocessable Entity".
  IF cCod = "429" THEN ASSIGN cRet = "Too Many Requests".
  IF cCod = "400" THEN ASSIGN cRet = "Bad Request".
  IF cCod = "500" THEN ASSIGN cRet = "Internal Server Error".

  ASSIGN
     cRet = cCod 
          + " - "
          + cRet.
  
  RETURN cRet. 

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

