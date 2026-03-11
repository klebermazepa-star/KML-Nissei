&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI ADM1
&ANALYZE-RESUME
/* Connected Databases 
          custom           PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS B-table-Win 
/*:T *******************************************************************************
** Copyright TOTVS S.A. (2009)
** Todos os Direitos Reservados.
**
** Este fonte e de propriedade exclusiva da TOTVS, sua reproducao
** parcial ou total por qualquer meio, so podera ser feita mediante
** autorizacao expressa.
*******************************************************************************/
USING Progress.Json.ObjectModel.JsonObject.
USING Progress.Json.ObjectModel.ObjectModelParser.
USING Progress.Lang.Object.
USING OpenEdge.Core.WidgetHandle.
USING OpenEdge.Core.String.


{include/i-prgvrs.i B99XX999 9.99.99.999}

DEF TEMP-TABLE ttRetorno NO-UNDO
    FIELD Retorno AS c FORMAT "x(38)"
    INDEX i Retorno.

/* Chamada a include do gerenciador de licen»as. Necessario alterar os parametros */
/*                                                                                */
/* <programa>:  Informar qual o nome do programa.                                 */
/* <m½dulo>:  Informar qual o m½dulo a qual o programa pertence.                  */
/*                                                                                */
/* OBS: Para os smartobjects o parametro m½dulo deverÿ ser MUT                    */

&IF "{&EMSFND_VERSION}" >= "1.00" &THEN
    {include/i-license-manager.i <programa> MUT}
&ENDIF

/* Create an unnamed pool to store all the widgets created 
     by this procedure. This is a good default which assures
     that this procedure's triggers and internal procedures 
     will execute in this procedure's storage, and that proper
     cleanup will occur on deletion of the procedure. */

CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */
&Scop adm-attribute-dlg support/browserd.w

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */
define variable c-lista-valor as character init '':U no-undo.

DEF VAR wh-pesquisa AS HANDLE NO-UNDO.

{method/dbotterr.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE SmartBrowser
&Scoped-define DB-AWARE no

&Scoped-define ADM-SUPPORTED-LINKS Record-Source,Record-Target,TableIO-Target

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME F-Main
&Scoped-define BROWSE-NAME br-table

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES es-api-log es-api-aplicacao es-api-empresa ~
es-api-URI ttRetorno

/* Define KEY-PHRASE in case it is used by any query. */
&Scoped-define KEY-PHRASE TRUE

/* Definitions for BROWSE br-table                                      */
&Scoped-define FIELDS-IN-QUERY-br-table es-api-log.id-api-log es-api-aplicacao.nome es-api-empresa.nome es-api-URI.nome es-api-log.dh-request es-api-log.dh-envio es-api-log.dh-retorno es-api-log.flg-processado ttRetorno.Retorno   
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-table   
&Scoped-define SELF-NAME br-table
&Scoped-define QUERY-STRING-br-table FOR EACH es-api-log       NO-LOCK        WHERE es-api-log.id-api-log   >= i-ID-inicial          AND es-api-log.id-api-log   <= i-ID-final          AND es-api-log.id-aplicacao >= c-aplicacao-inicial          AND es-api-log.id-aplicacao <= c-aplicacao-final          AND es-api-log.id-codigo    >= c-empresa-inicial          AND es-api-log.id-codigo    <= c-empresa-final          AND es-api-log.id-URI       >= c-URI-inicial          AND es-api-log.id-URI       <= c-URI-final          AND es-api-log.dh-request   >= dh-pedido-inicial          AND es-api-log.dh-request   <= dh-pedido-final         /*          AND es-api-log.dh-envio     >= dh-envio-inicial          AND es-api-log.dh-envio     <= dh-envio-final*/          /*AND es-api-log.dh-retorno   >= dh-retorno-inicial          AND es-api-log.dh-retorno   <= dh-retorno-final */ , ~
              FIRST es-api-aplicacao NO-LOCK           OF es-api-log, ~
              FIRST es-api-empresa   NO-LOCK           OF es-api-log, ~
              FIRST es-api-URI       NO-LOCK           OF es-api-log, ~
              FIRST ttRetorno OUTER-JOIN        WHERE SUBSTR(ttRetorno.Retorno, ~
      1, ~
      3) = es-api-log.cod-retorno           BY es-api-log.id-api-log        INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-br-table OPEN QUERY {&SELF-NAME}     FOR EACH es-api-log       NO-LOCK        WHERE es-api-log.id-api-log   >= i-ID-inicial          AND es-api-log.id-api-log   <= i-ID-final          AND es-api-log.id-aplicacao >= c-aplicacao-inicial          AND es-api-log.id-aplicacao <= c-aplicacao-final          AND es-api-log.id-codigo    >= c-empresa-inicial          AND es-api-log.id-codigo    <= c-empresa-final          AND es-api-log.id-URI       >= c-URI-inicial          AND es-api-log.id-URI       <= c-URI-final          AND es-api-log.dh-request   >= dh-pedido-inicial          AND es-api-log.dh-request   <= dh-pedido-final         /*          AND es-api-log.dh-envio     >= dh-envio-inicial          AND es-api-log.dh-envio     <= dh-envio-final*/          /*AND es-api-log.dh-retorno   >= dh-retorno-inicial          AND es-api-log.dh-retorno   <= dh-retorno-final */ , ~
              FIRST es-api-aplicacao NO-LOCK           OF es-api-log, ~
              FIRST es-api-empresa   NO-LOCK           OF es-api-log, ~
              FIRST es-api-URI       NO-LOCK           OF es-api-log, ~
              FIRST ttRetorno OUTER-JOIN        WHERE SUBSTR(ttRetorno.Retorno, ~
      1, ~
      3) = es-api-log.cod-retorno           BY es-api-log.id-api-log        INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-br-table es-api-log es-api-aplicacao ~
es-api-empresa es-api-URI ttRetorno
&Scoped-define FIRST-TABLE-IN-QUERY-br-table es-api-log
&Scoped-define SECOND-TABLE-IN-QUERY-br-table es-api-aplicacao
&Scoped-define THIRD-TABLE-IN-QUERY-br-table es-api-empresa
&Scoped-define FOURTH-TABLE-IN-QUERY-br-table es-api-URI
&Scoped-define FIFTH-TABLE-IN-QUERY-br-table ttRetorno


/* Definitions for FRAME F-Main                                         */

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS IMAGE-1 IMAGE-2 IMAGE-3 IMAGE-4 IMAGE-5 ~
IMAGE-6 IMAGE-7 IMAGE-8 IMAGE-9 IMAGE-10 IMAGE-11 IMAGE-12 IMAGE-13 ~
IMAGE-14 c-aplicacao-inicial c-aplicacao-final dh-pedido-inicial ~
dh-pedido-final c-empresa-inicial c-empresa-final c-URI-inicial c-URI-final ~
bt-confirma i-ID-inicial i-ID-final br-table bt-chamada bt-envio bt-retorno ~
bt-erros bt-executar bt-record 
&Scoped-Define DISPLAYED-OBJECTS c-aplicacao-inicial c-aplicacao-final ~
dh-pedido-inicial dh-pedido-final c-empresa-inicial c-empresa-final ~
dh-envio-inicial dh-envio-final c-URI-inicial c-URI-final ~
dh-retorno-inicial dh-retorno-final i-ID-inicial i-ID-final 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _XFTR "Foreign Keys" B-table-Win _INLINE
/* Actions: ? adm/support/keyedit.w ? ? ? */
/* STRUCTURED-DATA
<KEY-OBJECT>
&BROWSE-NAME
</KEY-OBJECT>
<FOREIGN-KEYS></FOREIGN-KEYS> 
<EXECUTING-CODE>
**************************
* Set attributes related to FOREIGN KEYS
*/
RUN set-attribute-list (
    'Keys-Accepted = ,
     Keys-Supplied = ':U).

/* Tell the ADM to use the OPEN-QUERY-CASES. */
&Scoped-define OPEN-QUERY-CASES RUN dispatch ('open-query-cases':U).
/**************************
</EXECUTING-CODE> */
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _XFTR "Advanced Query Options" B-table-Win _INLINE
/* Actions: ? adm/support/advqedit.w ? ? ? */
/* STRUCTURED-DATA
<KEY-OBJECT>
&BROWSE-NAME
</KEY-OBJECT>
<SORTBY-OPTIONS>
</SORTBY-OPTIONS>
<SORTBY-RUN-CODE>
************************
* Set attributes related to SORTBY-OPTIONS */
RUN set-attribute-list (
    'SortBy-Options = ""':U).
/************************
</SORTBY-RUN-CODE>
<FILTER-ATTRIBUTES>
************************
* Initialize Filter Attributes */
RUN set-attribute-list IN THIS-PROCEDURE ('
  Filter-Value=':U).
/************************
</FILTER-ATTRIBUTES> */   

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */
DEFINE BUTTON bt-chamada 
     LABEL "Dados Chamada" 
     SIZE 15 BY 1.13.

DEFINE BUTTON bt-confirma 
     IMAGE-UP FILE "image\im-sav":U
     LABEL "Button 1" 
     SIZE 5.14 BY 1.

DEFINE BUTTON bt-envio 
     LABEL "Dados Envio" 
     SIZE 15 BY 1.13.

DEFINE BUTTON bt-erros 
     LABEL "Erros" 
     SIZE 15 BY 1.13.

DEFINE BUTTON bt-executar 
     LABEL "Executar" 
     SIZE 15 BY 1.13.

DEFINE BUTTON bt-record 
     LABEL "LOG de Execu‡Æo" 
     SIZE 15 BY 1.13.

DEFINE BUTTON bt-retorno 
     LABEL "Dados Retorno" 
     SIZE 15 BY 1.13.

DEFINE VARIABLE c-aplicacao-final AS CHARACTER FORMAT "X(256)" INITIAL "ZZZZZZZZZZZZZZZZZZZ" 
     VIEW-AS FILL-IN 
     SIZE 20.43 BY .88 NO-UNDO.

DEFINE VARIABLE c-aplicacao-inicial AS CHARACTER FORMAT "X(256)" 
     LABEL "Aplicacao" 
     VIEW-AS FILL-IN 
     SIZE 20.43 BY .88 NO-UNDO.

DEFINE VARIABLE c-empresa-final AS CHARACTER FORMAT "X(256)" INITIAL "ZZZZZZZZZZZZZZZZZZZ" 
     VIEW-AS FILL-IN 
     SIZE 20.43 BY .88 NO-UNDO.

DEFINE VARIABLE c-empresa-inicial AS CHARACTER FORMAT "X(256)" 
     LABEL "Empresa" 
     VIEW-AS FILL-IN 
     SIZE 20.43 BY .88 NO-UNDO.

DEFINE VARIABLE c-URI-final AS CHARACTER FORMAT "X(256)" INITIAL "ZZZZZZZZZZZZZZZZZZZ" 
     VIEW-AS FILL-IN 
     SIZE 20.43 BY .88 NO-UNDO.

DEFINE VARIABLE c-URI-inicial AS CHARACTER FORMAT "X(256)" 
     LABEL "URI" 
     VIEW-AS FILL-IN 
     SIZE 20.43 BY .88 NO-UNDO.

DEFINE VARIABLE dh-envio-final AS DATETIME FORMAT "99/99/9999 HH:MM:SS" INITIAL "12/31/9999 00:00:00.000" 
     VIEW-AS FILL-IN 
     SIZE 20.43 BY .88 NO-UNDO.

DEFINE VARIABLE dh-envio-inicial AS DATETIME FORMAT "99/99/9999 HH:MM:SS" INITIAL "01/01/001 00:00:00.000" 
     LABEL "Envio" 
     VIEW-AS FILL-IN 
     SIZE 20.43 BY .88 NO-UNDO.

DEFINE VARIABLE dh-pedido-final AS DATETIME FORMAT "99/99/9999 HH:MM:SS" INITIAL "12/31/9999 00:00:00.000" 
     VIEW-AS FILL-IN 
     SIZE 20.43 BY .88 NO-UNDO.

DEFINE VARIABLE dh-pedido-inicial AS DATETIME FORMAT "99/99/9999 HH:MM:SS" INITIAL "01/01/001 00:00:00.000" 
     LABEL "Pedido" 
     VIEW-AS FILL-IN 
     SIZE 20.43 BY .88 NO-UNDO.

DEFINE VARIABLE dh-retorno-final AS DATETIME FORMAT "99/99/9999 HH:MM:SS" INITIAL "12/31/9999 00:00:00.000" 
     VIEW-AS FILL-IN 
     SIZE 20.43 BY .88 NO-UNDO.

DEFINE VARIABLE dh-retorno-inicial AS DATETIME FORMAT "99/99/9999 HH:MM:SS" INITIAL "01/01/001 00:00:00.000" 
     LABEL "Retorno" 
     VIEW-AS FILL-IN 
     SIZE 20.43 BY .88 NO-UNDO.

DEFINE VARIABLE i-ID-final AS INT64 FORMAT ">>>,>>>,>>>,>>9" INITIAL 999999999999 
     VIEW-AS FILL-IN 
     SIZE 20.43 BY .88 NO-UNDO.

DEFINE VARIABLE i-ID-inicial AS INT64 FORMAT ">>>,>>>,>>>,>>9" INITIAL 0 
     LABEL "ID" 
     VIEW-AS FILL-IN 
     SIZE 20.43 BY .88 NO-UNDO.

DEFINE IMAGE IMAGE-1
     FILENAME "image\ii-fir":U
     SIZE 2.86 BY 1.

DEFINE IMAGE IMAGE-10
     FILENAME "image\ii-las":U
     SIZE 2.86 BY 1.

DEFINE IMAGE IMAGE-11
     FILENAME "image\ii-fir":U
     SIZE 2.86 BY 1.

DEFINE IMAGE IMAGE-12
     FILENAME "image\ii-las":U
     SIZE 2.86 BY 1.

DEFINE IMAGE IMAGE-13
     FILENAME "image\ii-fir":U
     SIZE 2.86 BY 1.

DEFINE IMAGE IMAGE-14
     FILENAME "image\ii-las":U
     SIZE 2.86 BY 1.

DEFINE IMAGE IMAGE-2
     FILENAME "image\ii-las":U
     SIZE 2.86 BY 1.

DEFINE IMAGE IMAGE-3
     FILENAME "image\ii-fir":U
     SIZE 2.86 BY 1.

DEFINE IMAGE IMAGE-4
     FILENAME "image\ii-las":U
     SIZE 2.86 BY 1.

DEFINE IMAGE IMAGE-5
     FILENAME "image\ii-fir":U
     SIZE 2.86 BY 1.

DEFINE IMAGE IMAGE-6
     FILENAME "image\ii-las":U
     SIZE 2.86 BY 1.

DEFINE IMAGE IMAGE-7
     FILENAME "image\ii-fir":U
     SIZE 2.86 BY 1.

DEFINE IMAGE IMAGE-8
     FILENAME "image\ii-las":U
     SIZE 2.86 BY 1.

DEFINE IMAGE IMAGE-9
     FILENAME "image\ii-fir":U
     SIZE 2.86 BY 1.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-table FOR 
      es-api-log, 
      es-api-aplicacao, 
      es-api-empresa, 
      es-api-URI, 
      ttRetorno SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-table
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-table B-table-Win _FREEFORM
  QUERY br-table NO-LOCK DISPLAY
      es-api-log.id-api-log     COLUMN-LABEL "ID"
      es-api-aplicacao.nome     COLUMN-LABEL "Aplica‡Æo"  FORMAT "x(15)"
      es-api-empresa.nome       COLUMN-LABEL "Empresa"
      es-api-URI.nome           COLUMN-LABEL "URI"
      es-api-log.dh-request     COLUMN-LABEL "Pedido"     FORMAT "99/99/9999 HH:MM:SS":U
      es-api-log.dh-envio       COLUMN-LABEL "Envio"      FORMAT "99/99/9999 HH:MM:SS":U
      es-api-log.dh-retorno     COLUMN-LABEL "Retorno"    FORMAT "99/99/9999 HH:MM:SS":U
      es-api-log.flg-processado
      ttRetorno.Retorno         COLUMN-LABEL "C½digo Retorno"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ASSIGN SEPARATORS SIZE 165 BY 12
         FONT 1.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME F-Main
     c-aplicacao-inicial AT ROW 1 COL 7.43 COLON-ALIGNED
     c-aplicacao-final AT ROW 1 COL 37.86 COLON-ALIGNED NO-LABEL
     dh-pedido-inicial AT ROW 1 COL 66.14 COLON-ALIGNED WIDGET-ID 58
     dh-pedido-final AT ROW 1 COL 96.57 COLON-ALIGNED NO-LABEL WIDGET-ID 56
     c-empresa-inicial AT ROW 1.96 COL 7.43 COLON-ALIGNED WIDGET-ID 8
     c-empresa-final AT ROW 1.96 COL 37.86 COLON-ALIGNED NO-LABEL WIDGET-ID 6
     dh-envio-inicial AT ROW 1.96 COL 66.14 COLON-ALIGNED WIDGET-ID 24
     dh-envio-final AT ROW 1.96 COL 96.57 COLON-ALIGNED NO-LABEL WIDGET-ID 22
     c-URI-inicial AT ROW 2.92 COL 7.43 COLON-ALIGNED WIDGET-ID 16
     c-URI-final AT ROW 2.92 COL 37.86 COLON-ALIGNED NO-LABEL WIDGET-ID 14
     dh-retorno-inicial AT ROW 2.92 COL 66.14 COLON-ALIGNED WIDGET-ID 28
     dh-retorno-final AT ROW 2.92 COL 96.57 COLON-ALIGNED NO-LABEL WIDGET-ID 26
     bt-confirma AT ROW 3.79 COL 160.72
     i-ID-inicial AT ROW 3.88 COL 66.14 COLON-ALIGNED WIDGET-ID 50
     i-ID-final AT ROW 3.88 COL 96.57 COLON-ALIGNED NO-LABEL WIDGET-ID 48
     br-table AT ROW 4.83 COL 1
     bt-chamada AT ROW 16.92 COL 1 WIDGET-ID 38
     bt-envio AT ROW 16.92 COL 16.14 WIDGET-ID 2
     bt-retorno AT ROW 16.92 COL 31.29 WIDGET-ID 4
     bt-erros AT ROW 16.92 COL 46.57 WIDGET-ID 40
     bt-executar AT ROW 16.92 COL 77.57 WIDGET-ID 46
     bt-record AT ROW 16.92 COL 92.86 WIDGET-ID 44
     IMAGE-1 AT ROW 1 COL 30.29
     IMAGE-2 AT ROW 1 COL 36.43
     IMAGE-3 AT ROW 1.96 COL 30.29 WIDGET-ID 10
     IMAGE-4 AT ROW 1.96 COL 36.43 WIDGET-ID 12
     IMAGE-5 AT ROW 2.92 COL 30.29 WIDGET-ID 18
     IMAGE-6 AT ROW 2.92 COL 36.43 WIDGET-ID 20
     IMAGE-7 AT ROW 1.96 COL 89 WIDGET-ID 30
     IMAGE-8 AT ROW 1.96 COL 95.14 WIDGET-ID 32
     IMAGE-9 AT ROW 2.92 COL 89 WIDGET-ID 34
     IMAGE-10 AT ROW 2.92 COL 95.14 WIDGET-ID 36
     IMAGE-11 AT ROW 3.88 COL 89 WIDGET-ID 54
     IMAGE-12 AT ROW 3.88 COL 95.14 WIDGET-ID 52
     IMAGE-13 AT ROW 1 COL 89 WIDGET-ID 60
     IMAGE-14 AT ROW 1 COL 95.14 WIDGET-ID 62
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1 SCROLLABLE 
         BGCOLOR 8 FGCOLOR 0 FONT 1 WIDGET-ID 100.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: SmartBrowser
   Allow: Basic,Browse
   Frames: 1
   Add Fields to: EXTERNAL-TABLES
   Other Settings: PERSISTENT-ONLY COMPILE
 */

/* This procedure should always be RUN PERSISTENT.  Report the error,  */
/* then cleanup and return.                                            */
IF NOT THIS-PROCEDURE:PERSISTENT THEN DO:
  MESSAGE "{&FILE-NAME} should only be RUN PERSISTENT.":U
          VIEW-AS ALERT-BOX ERROR BUTTONS OK.
  RETURN.
END.

&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
/* DESIGN Window definition (used by the UIB) 
  CREATE WINDOW B-table-Win ASSIGN
         HEIGHT             = 17.04
         WIDTH              = 165.57.
/* END WINDOW DEFINITION */
                                                                        */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _INCLUDED-LIB B-table-Win 
/* ************************* Included-Libraries *********************** */

{src/adm/method/browser.i}
{include/c-brwzoo.i}
{utp/ut-glob.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME




/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW B-table-Win
  NOT-VISIBLE,,RUN-PERSISTENT                                           */
/* SETTINGS FOR FRAME F-Main
   NOT-VISIBLE FRAME-NAME Size-to-Fit L-To-R                            */
/* BROWSE-TAB br-table i-ID-final F-Main */
ASSIGN 
       FRAME F-Main:SCROLLABLE       = FALSE
       FRAME F-Main:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN dh-envio-final IN FRAME F-Main
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN dh-envio-inicial IN FRAME F-Main
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN dh-retorno-final IN FRAME F-Main
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN dh-retorno-inicial IN FRAME F-Main
   NO-ENABLE                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-table
/* Query rebuild information for BROWSE br-table
     _START_FREEFORM
OPEN QUERY {&SELF-NAME}
    FOR EACH es-api-log       NO-LOCK
       WHERE es-api-log.id-api-log   >= i-ID-inicial
         AND es-api-log.id-api-log   <= i-ID-final
         AND es-api-log.id-aplicacao >= c-aplicacao-inicial
         AND es-api-log.id-aplicacao <= c-aplicacao-final
         AND es-api-log.id-codigo    >= c-empresa-inicial
         AND es-api-log.id-codigo    <= c-empresa-final
         AND es-api-log.id-URI       >= c-URI-inicial
         AND es-api-log.id-URI       <= c-URI-final
         AND es-api-log.dh-request   >= dh-pedido-inicial
         AND es-api-log.dh-request   <= dh-pedido-final
        /*
         AND es-api-log.dh-envio     >= dh-envio-inicial
         AND es-api-log.dh-envio     <= dh-envio-final*/
         /*AND es-api-log.dh-retorno   >= dh-retorno-inicial
         AND es-api-log.dh-retorno   <= dh-retorno-final */ ,
       FIRST es-api-aplicacao NO-LOCK
          OF es-api-log,
       FIRST es-api-empresa   NO-LOCK
          OF es-api-log,
       FIRST es-api-URI       NO-LOCK
          OF es-api-log,
       FIRST ttRetorno OUTER-JOIN
       WHERE SUBSTR(ttRetorno.Retorno,1,3) = es-api-log.cod-retorno
          BY es-api-log.id-api-log
       INDEXED-REPOSITION.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION KEY-PHRASE SORTBY-PHRASE"
     _Query            is NOT OPENED
*/  /* BROWSE br-table */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK FRAME F-Main
/* Query rebuild information for FRAME F-Main
     _Options          = "NO-LOCK"
     _Query            is NOT OPENED
*/  /* FRAME F-Main */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define BROWSE-NAME br-table
&Scoped-define SELF-NAME br-table
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-table B-table-Win
ON MOUSE-SELECT-DBLCLICK OF br-table IN FRAME F-Main
DO:
    RUN New-State('DblClick':U).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-table B-table-Win
ON ROW-ENTRY OF br-table IN FRAME F-Main
DO:
  /* This code displays initial values for newly added or copied rows. */
  {src/adm/template/brsentry.i}
  
  run new-state('New-Line|':U + string(rowid({&FIRST-TABLE-IN-QUERY-{&BROWSE-NAME}}))).
  run seta-valor.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-table B-table-Win
ON ROW-LEAVE OF br-table IN FRAME F-Main
DO:
    /* Do not disable this code or no updates will take place except
     by pressing the Save button on an Update SmartPanel. */
   {src/adm/template/brsleave.i}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-table B-table-Win
ON VALUE-CHANGED OF br-table IN FRAME F-Main
DO:
  /* This ADM trigger code must be preserved in order to notify other
     objects when the browser's current row changes. */
  {src/adm/template/brschnge.i}
  run new-state('New-Line|':U + string(rowid({&FIRST-TABLE-IN-QUERY-{&BROWSE-NAME}}))).
  run new-state('Value-Changed|':U + string(this-procedure)).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-chamada
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-chamada B-table-Win
ON CHOOSE OF bt-chamada IN FRAME F-Main /* Dados Chamada */
DO:
   IF AVAIL es-api-log
   THEN RUN esp/esapi504b.w (ROWID(es-api-log)).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-confirma
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-confirma B-table-Win
ON CHOOSE OF bt-confirma IN FRAME F-Main /* Button 1 */
DO:
   assign input frame {&frame-name} 
       c-aplicacao-inicial 
       c-aplicacao-final
       
       c-empresa-inicial
       c-empresa-final
       
       c-URI-inicial
       c-URI-final

       dh-pedido-inicial
       dh-pedido-final
       
       dh-envio-inicial
       dh-envio-final

       dh-retorno-inicial
       dh-retorno-final

       i-ID-inicial
       i-ID-final
       .
   
   RUN dispatch IN THIS-PROCEDURE ('open-query':U).
   apply 'value-changed':U to {&browse-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-envio
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-envio B-table-Win
ON CHOOSE OF bt-envio IN FRAME F-Main /* Dados Envio */
DO:

   DEF VAR lcEnvio AS LONGCHAR NO-UNDO.

   IF AVAIL es-api-log
   THEN DO:
      COPY-LOB es-api-log.cl-envio TO lcEnvio.
      RUN esp/esapi504a.w (lcEnvio).
   END.

   /*
   DEF VAR mJson       AS MEMPTR            NO-UNDO.
   DEF VAR myParser    AS ObjectModelParser NO-UNDO. 

   DEF VAR oEntity     AS LONGCHAR          NO-UNDO.
   DEF VAR cLongJson   AS LONGCHAR          NO-UNDO.
   DEF VAR jsonObject  AS JsonObject        NO-UNDO.
   DEF VAR pJsonInput  AS JsonObject        NO-UNDO.

   DEF VAR cArquivo    AS c                 NO-UNDO.

   ASSIGN
      cArquivo = SESSION:TEMP-DIRECTORY + "RET" + STRING(TIME) + STRING(RANDOM(1,1000)) + ".json".

   FIX-CODEPAGE(cLongJson) = "UTF-8".
   COPY-LOB es-api-log.cl-envio TO mJson.
   COPY-LOB mJson TO cLongJson NO-CONVERT.

   COPY-LOB mJson TO FILE cArquivo NO-CONVERT.

   /*
   myParser = NEW ObjectModelParser(). 
   pJsonInput = CAST(myParser:Parse(cLongJson),JsonObject).
   CAST(myParser:Parse(cLongJson),JsonObject):WriteFile(cArquivo, true).
   */

   RUN OpenDocument (cArquivo).

   //OS-COMMAND SILENT (START VALUE("C:\~"Program Files~"\~"Internet Explorer~"\iexplore.exe " + cArquivo)).
   */
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-erros
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-erros B-table-Win
ON CHOOSE OF bt-erros IN FRAME F-Main /* Erros */
DO:
   DEF         VAR hShowMsg     AS HANDLE    NO-UNDO.

   IF AVAIL es-api-log
   THEN DO:
      EMPTY TEMP-TABLE RowErrors.
      FOR EACH es-api-aux NO-LOCK
            OF es-api-log
         WHERE es-api-aux.tipo = "RowErrors":
          CREATE RowErrors.
          RAW-TRANSFER es-api-aux.raw-aux TO RowErrors NO-ERROR. 
      END.
         
      IF CAN-FIND(FIRST RowErrors) 
      THEN DO:
         {method/showmessage.i1}
         {method/showmessage.i2}
         RETURN "NOK".
      END.
   END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-executar
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-executar B-table-Win
ON CHOOSE OF bt-executar IN FRAME F-Main /* Executar */
DO:
   DEF VAR cArquivo    AS c                 NO-UNDO.
   DEF VAR h-acomp     AS HANDLE            NO-UNDO.

   RUN utp/ut-msgs.p ("show",27100,"Executar pedido?").

   IF  RETURN-VALUE = "yes"
   AND AVAIL es-api-log
   THEN DO ON STOP UNDO, LEAVE:
      RUN utp/ut-acomp.p PERSISTENT SET h-acomp.  
      RUN pi-inicializar IN h-acomp (""). 
      RUN pi-acompanhar IN h-acomp ("Executando").
      MESSAGE es-api-URI.nom-programa-env
          VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
      RUN VALUE(es-api-URI.nom-programa-env) (h-acomp,
                                              1,
                                              ROWID(es-api-log)).
      RUN utp/ut-msgs.p ("show",15825,"Processamento concluido").
      BROWSE br-table:REFRESH().
   END.
   IF VALID-HANDLE(h-acomp) 
   THEN RUN pi-finalizar IN h-acomp.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-record
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-record B-table-Win
ON CHOOSE OF bt-record IN FRAME F-Main /* LOG de Execu‡Æo */
DO:
   DEF VAR cArquivo AS c        NO-UNDO.
   DEF VAR cAux     AS LONGCHAR NO-UNDO.

   IF AVAIL es-api-log
   THEN DO:
      
      FOR  EACH es-api-aux NO-LOCK
          WHERE es-api-aux.id-api-log =  es-api-log.id-api-log
            AND es-api-aux.Tipo       =  "Record"
             BY es-api-aux.id-api-log
             BY es-api-aux.Tipo      
             BY es-api-aux.seq:
         cAux = CODEPAGE-CONVERT(cAux, "UTF-8":U).
         cAux = es-api-aux.cl-aux NO-ERROR.
         cAux = REPLACE(cAux,CHR(10),CHR(13) + CHR(10)) NO-ERROR.
      END.
      IF cAux <> ""
      THEN DO:
         ASSIGN
            cArquivo = SESSION:TEMP-DIRECTORY + "RET" + STRING(TIME) + STRING(RANDOM(1,1000)) + ".lst".
         COPY-LOB cAux TO FILE cArquivo.
         RUN OpenDocument (cArquivo).
      END.

   END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-retorno
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-retorno B-table-Win
ON CHOOSE OF bt-retorno IN FRAME F-Main /* Dados Retorno */
DO:

   DEF VAR lcEnvio AS LONGCHAR NO-UNDO.

   IF AVAIL es-api-log
   THEN DO:
      COPY-LOB es-api-log.cl-retorno TO lcEnvio.
      RUN esp/esapi504a.w (lcEnvio).
   END.


   /*
   DEF VAR mJson       AS MEMPTR            NO-UNDO.
   DEF VAR myParser    AS ObjectModelParser NO-UNDO. 

   DEF VAR oEntity     AS LONGCHAR          NO-UNDO.
   DEF VAR cLongJson   AS LONGCHAR          NO-UNDO.
   DEF VAR jsonObject  AS JsonObject        NO-UNDO.
   DEF VAR pJsonInput  AS JsonObject        NO-UNDO.

   DEF VAR cArquivo    AS c                 NO-UNDO.

   ASSIGN
      cArquivo = SESSION:TEMP-DIRECTORY + "RET" + STRING(TIME) + STRING(RANDOM(1,1000)) + ".json".

   FIX-CODEPAGE(cLongJson) = "UTF-8".
   COPY-LOB es-api-log.cl-retorno TO mJson.
   COPY-LOB mJson TO cLongJson NO-CONVERT.

   COPY-LOB mJson TO FILE cArquivo NO-CONVERT.

   /*
   myParser = NEW ObjectModelParser(). 
   pJsonInput = CAST(myParser:Parse(cLongJson),JsonObject).
   CAST(myParser:Parse(cLongJson),JsonObject):WriteFile(cArquivo, true).
   */

   RUN OpenDocument (cArquivo).

   //OS-COMMAND SILENT (START VALUE("C:\~"Program Files~"\~"Internet Explorer~"\iexplore.exe " + cArquivo)).
   */
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME c-aplicacao-final
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL c-aplicacao-final B-table-Win
ON F5 OF c-aplicacao-final IN FRAME F-Main
DO:
   {include/zoomvar.i &prog-zoom  = esp/esapi502-z01.w
                      &campo      = c-aplicacao-final
                      &campozoom  = id-aplicacao
                      }  
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL c-aplicacao-final B-table-Win
ON MOUSE-SELECT-DBLCLICK OF c-aplicacao-final IN FRAME F-Main
DO:
   APPLY "F5" TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME c-aplicacao-inicial
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL c-aplicacao-inicial B-table-Win
ON F5 OF c-aplicacao-inicial IN FRAME F-Main /* Aplicacao */
DO:
   {include/zoomvar.i &prog-zoom  = esp/esapi502-z01.w
                      &campo      = c-aplicacao-inicial
                      &campozoom  = id-aplicacao
                      }  
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL c-aplicacao-inicial B-table-Win
ON MOUSE-SELECT-DBLCLICK OF c-aplicacao-inicial IN FRAME F-Main /* Aplicacao */
DO:
   APPLY "F5" TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME c-empresa-final
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL c-empresa-final B-table-Win
ON F5 OF c-empresa-final IN FRAME F-Main
DO:
   {include/zoomvar.i &prog-zoom  = esp/esapi501-z01.w
                      &campo      = c-empresa-final
                      &campozoom  = id-codigo
                      }  
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL c-empresa-final B-table-Win
ON MOUSE-SELECT-DBLCLICK OF c-empresa-final IN FRAME F-Main
DO:
   APPLY "F5" TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME c-empresa-inicial
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL c-empresa-inicial B-table-Win
ON F5 OF c-empresa-inicial IN FRAME F-Main /* Empresa */
DO:
   {include/zoomvar.i &prog-zoom  = esp/esapi501-z01.w
                      &campo      = c-empresa-inicial
                      &campozoom  = id-codigo
                      }  
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL c-empresa-inicial B-table-Win
ON MOUSE-SELECT-DBLCLICK OF c-empresa-inicial IN FRAME F-Main /* Empresa */
DO:
   APPLY "F5" TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME c-URI-final
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL c-URI-final B-table-Win
ON F5 OF c-URI-final IN FRAME F-Main
DO:
    {include/zoomvar.i &prog-zoom  = esp/esapi503-z01.w
                       &campo      = c-uri-final
                       &campozoom  = id-URI
                       }  
  
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL c-URI-final B-table-Win
ON MOUSE-SELECT-DBLCLICK OF c-URI-final IN FRAME F-Main
DO:
   APPLY "F5" TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME c-URI-inicial
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL c-URI-inicial B-table-Win
ON F5 OF c-URI-inicial IN FRAME F-Main /* URI */
DO:
     {include/zoomvar.i &prog-zoom  = esp/esapi503-z01.w
                      &campo      = c-uri-inicial
                      &campozoom  = id-URI
                      }  
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL c-URI-inicial B-table-Win
ON MOUSE-SELECT-DBLCLICK OF c-URI-inicial IN FRAME F-Main /* URI */
DO:
   APPLY "F5" TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK B-table-Win 


/* ***************************  Main Block  *************************** */

&IF DEFINED(UIB_IS_RUNNING) <> 0 &THEN          
RUN dispatch IN THIS-PROCEDURE ('initialize':U).        
&ENDIF



c-aplicacao-final  :LOAD-MOUSE-POINTER("image/lupa.cur") IN FRAME {&FRAME-NAME}.
c-aplicacao-inicial:LOAD-MOUSE-POINTER("image/lupa.cur") IN FRAME {&FRAME-NAME}.
c-empresa-final    :LOAD-MOUSE-POINTER("image/lupa.cur") IN FRAME {&FRAME-NAME}.
c-empresa-inicial  :LOAD-MOUSE-POINTER("image/lupa.cur") IN FRAME {&FRAME-NAME}.
c-URI-final        :LOAD-MOUSE-POINTER("image/lupa.cur") IN FRAME {&FRAME-NAME}.
c-URI-inicial      :LOAD-MOUSE-POINTER("image/lupa.cur") IN FRAME {&FRAME-NAME}.
dh-envio-final     :LOAD-MOUSE-POINTER("image/lupa.cur") IN FRAME {&FRAME-NAME}.
dh-envio-inicial   :LOAD-MOUSE-POINTER("image/lupa.cur") IN FRAME {&FRAME-NAME}.
dh-retorno-final   :LOAD-MOUSE-POINTER("image/lupa.cur") IN FRAME {&FRAME-NAME}.
dh-retorno-inicial :LOAD-MOUSE-POINTER("image/lupa.cur") IN FRAME {&FRAME-NAME}.

PROCEDURE OpenDocument:

    def input param c-doc as char  no-undo.
    def var c-exec as char  no-undo.
    def var h-Inst as int  no-undo.

    assign c-exec = fill("x",255).
    run FindExecutableA (input c-doc,
                         input "",
                         input-output c-exec,
                         output h-inst).

    if h-inst >= 0 and h-inst <=32 then
      run ShellExecuteA (input 0,
                         input "open",
                         input "rundll32.exe",
                         input "shell32.dll,OpenAs_RunDLL " + c-doc,
                         input "",
                         input 1,
                         output h-inst).

    run ShellExecuteA (input 0,
                       input "open",
                       input c-doc,
                       input "",
                       input "",
                       input 1,
                       output h-inst).

    if h-inst < 0 or h-inst > 32 then return "OK".
    else return "NOK".

END PROCEDURE.

PROCEDURE FindExecutableA EXTERNAL "Shell32.dll" persistent:

    define input parameter lpFile as char  no-undo.
    define input parameter lpDirectory as char  no-undo.
    define input-output parameter lpResult as char  no-undo.
    define return parameter hInstance as long.

END.

PROCEDURE ShellExecuteA EXTERNAL "Shell32.dll" persistent:

    define input parameter hwnd as long.
    define input parameter lpOperation as char  no-undo.
    define input parameter lpFile as char  no-undo.
    define input parameter lpParameters as char  no-undo.
    define input parameter lpDirectory as char  no-undo.
    define input parameter nShowCmd as long.
    define return parameter hInstance as long.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE adm-open-query-cases B-table-Win  adm/support/_adm-opn.p
PROCEDURE adm-open-query-cases :
/*------------------------------------------------------------------------------
  Purpose:     Opens different cases of the query based on attributes
               such as the 'Key-Name', or 'SortBy-Case'
  Parameters:  <none>
------------------------------------------------------------------------------*/
  DEF VAR Filter-Value AS CHAR NO-UNDO.

  /* Copy 'Filter-Attributes' into local variables. */
  RUN get-attribute ('Filter-Value':U).
  Filter-Value = RETURN-VALUE.

  /* No Foreign keys are accepted by this SmartObject. */

  {&OPEN-QUERY-{&BROWSE-NAME}}

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE adm-row-available B-table-Win  _ADM-ROW-AVAILABLE
PROCEDURE adm-row-available :
/*------------------------------------------------------------------------------
  Purpose:     Dispatched to this procedure when the Record-
               Source has a new row available.  This procedure
               tries to get the new row (or foriegn keys) from
               the Record-Source and process it.
  Parameters:  <none>
------------------------------------------------------------------------------*/

  /* Define variables needed by this internal procedure.             */
  {src/adm/template/row-head.i}

  /* Process the newly available records (i.e. display fields,
     open queries, and/or pass records on to any RECORD-TARGETS).    */
  {src/adm/template/row-end.i}

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI B-table-Win  _DEFAULT-DISABLE
PROCEDURE disable_UI :
/*------------------------------------------------------------------------------
  Purpose:     DISABLE the User Interface
  Parameters:  <none>
  Notes:       Here we clean-up the user-interface by deleting
               dynamic widgets we have created and/or hide 
               frames.  This procedure is usually called when
               we are ready to "clean-up" after running.
------------------------------------------------------------------------------*/
  /* Hide all frames. */
  HIDE FRAME F-Main.
  IF THIS-PROCEDURE:PERSISTENT THEN DELETE PROCEDURE THIS-PROCEDURE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-view B-table-Win 
PROCEDURE local-view :
/*------------------------------------------------------------------------------
  Purpose:     Override standard ADM method
  Notes:       
------------------------------------------------------------------------------*/
   DEF VAR i AS i NO-UNDO.
   DEF VAR r AS c NO-UNDO.
   ASSIGN
      r = "    None                    ,"
        + "200 Ok                      ,"
        + "201 Created                 ,"
        + "202 Accepted                ,"
        + "204 No Content              ,"
        + "400 Bad Request             ,"
        + "401 Unauthorized            ,"
        + "403 Forbidden               ,"
        + "404 Not Found               ,"
        + "405 Method not Allowed      ,"
        + "413 Request Entity Too large,"
        + "422 Unprocessable Entity    ,"
        + "429 Too many requests       ,"
        + "500 Internal Server Error   ,"
        + "502 Bad Gateway             ,"
        + "504 Gateway Timeout         ,"
        .
   DO i = 1 TO NUM-ENTRIES(r):
      CREATE ttRetorno.
      ASSIGN
         ttRetorno.Retorno = ENTRY(i,r).
   END.
  
   /* Code placed here will execute PRIOR to standard behavior. */
 
   /* Dispatch standard ADM method.                             */
   RUN dispatch IN THIS-PROCEDURE ( INPUT 'view':U ) .
 
   /* Code placed here will execute AFTER standard behavior.    */
   apply 'value-changed':U to {&browse-name} in frame {&frame-name}.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE send-key B-table-Win  adm/support/_key-snd.p
PROCEDURE send-key :
/*------------------------------------------------------------------------------
  Purpose:     Sends a requested KEY value back to the calling
               SmartObject.
  Parameters:  <see adm/template/sndkytop.i>
------------------------------------------------------------------------------*/

  /* There are no foreign keys supplied by this SmartObject. */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE send-records B-table-Win  _ADM-SEND-RECORDS
PROCEDURE send-records :
/*------------------------------------------------------------------------------
  Purpose:     Send record ROWID's for all tables used by
               this file.
  Parameters:  see template/snd-head.i
------------------------------------------------------------------------------*/

  /* Define variables needed by this internal procedure.               */
  {src/adm/template/snd-head.i}

  /* For each requested table, put it's ROWID in the output list.      */
  {src/adm/template/snd-list.i "es-api-log"}
  {src/adm/template/snd-list.i "es-api-aplicacao"}
  {src/adm/template/snd-list.i "es-api-empresa"}
  {src/adm/template/snd-list.i "es-api-URI"}
  {src/adm/template/snd-list.i "ttRetorno"}

  /* Deal with any unexpected table requests before closing.           */
  {src/adm/template/snd-end.i}

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE state-changed B-table-Win 
PROCEDURE state-changed :
/* -----------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
-------------------------------------------------------------*/
  DEFINE INPUT PARAMETER p-issuer-hdl AS HANDLE    NO-UNDO.
  DEFINE INPUT PARAMETER p-state      AS CHARACTER NO-UNDO.

  CASE p-state:
      /* Object instance CASEs can go here to replace standard behavior
         or add new cases. */
      {src/adm/template/bstates.i}
  END CASE.
  run pi-trata-state (p-issuer-hdl, p-state).
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _XFTR "RetornaValorCampo" B-table-Win _INLINE
/* Actions: ? ? ? ? support/brwrtval.p */
/* Procedure desativada */
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

