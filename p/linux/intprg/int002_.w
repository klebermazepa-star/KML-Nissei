&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
*/
&Scoped-define WINDOW-NAME wMasterDetail


/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE tt-int-ds-docto-xml NO-UNDO LIKE int-ds-docto-xml
       fields r-rowid as rowid.
DEFINE TEMP-TABLE tt-int-ds-it-docto-xml NO-UNDO LIKE int-ds-it-docto-xml
       fields r-rowid as rowid.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS wMasterDetail 
/*:T*******************************************************************************
** Copyright DATASUL S.A. (1999)
** Todos os Direitos Reservados.
**
** Este fonte e de propriedade exclusiva da DATASUL, sua reproducao
** parcial ou total por qualquer meio, so podera ser feita mediante
** autorizacao expressa.
*******************************************************************************/

{include/i-prgvrs.i int002 2.06.00.001}

CREATE WIDGET-POOL.

/* Preprocessors Definitions ---                                      */
&GLOBAL-DEFINE Program          int002
&GLOBAL-DEFINE Version          2.06.00.01
&GLOBAL-DEFINE Folder           YES
&GLOBAL-DEFINE InitialPage      1
&GLOBAL-DEFINE FolderLabels     ITEM


&GLOBAL-DEFINE First            YES
&GLOBAL-DEFINE Prev             YES
&GLOBAL-DEFINE Next             YES
&GLOBAL-DEFINE Last             YES
&GLOBAL-DEFINE GoTo             YES
&GLOBAL-DEFINE Search           YES

&GLOBAL-DEFINE AddParent        YES
&GLOBAL-DEFINE CopyParent       NO
&GLOBAL-DEFINE UpdateParent     YES
&GLOBAL-DEFINE DeleteParent     YES

&GLOBAL-DEFINE AddSon1          YES
&GLOBAL-DEFINE CopySon1         YES
&GLOBAL-DEFINE UpdateSon1       YES
&GLOBAL-DEFINE DeleteSon1       YES



&GLOBAL-DEFINE ttParent         tt-int-ds-docto-xml     
&GLOBAL-DEFINE hDBOParent       h-dbo-int-ds-docto-xml  
&GLOBAL-DEFINE DBOParentTable   dbo-int-ds-docto-xml    
&GLOBAL-DEFINE DBOParentDestroy YES                   

&GLOBAL-DEFINE ttSon1           tt-int-ds-it-docto-xml
&GLOBAL-DEFINE hDBOSon1         h-dbo-int-ds-it-docto-xml
&GLOBAL-DEFINE DBOSon1Table     dbo-int-ds-it-docto-xml
&GLOBAL-DEFINE DBOSon1Destroy   NO

DEFINE BUFFER bf-int-ds-it-docto-xml    FOR int-ds-it-docto-xml.
DEFINE BUFFER bf-tt-int-ds-it-docto-xml FOR tt-int-ds-it-docto-xml.

&GLOBAL-DEFINE page0Fields      tt-int-ds-docto-xml.cod-estab tt-int-ds-docto-xml.serie ~
                                tt-int-ds-docto-xml.nNF tt-int-ds-docto-xml.cod-emitente tt-int-ds-docto-xml.cnpj tt-int-ds-docto-xml.dEmi tt-int-ds-docto-xml.nat-operacao 

&GLOBAL-DEFINE page1Widget      bt-erros bt-natureza bt-refresh 

&GLOBAL-DEFINE page1Browse      brSon1 
  
DEFINE VARIABLE {&hDBOParent} AS HANDLE NO-UNDO.
DEFINE VARIABLE {&hDBOSon1}   AS HANDLE NO-UNDO.

DEF VAR c-desc-situacao AS CHAR    NO-UNDO.
DEF VAR i-seq-erro      AS INT     NO-UNDO.
DEF VAR l-ok            AS LOGICAL NO-UNDO.
DEF VAR r-row-atual     AS ROWID   NO-UNDO.
DEF VAR r-row-item      AS ROWID   NO-UNDO.
DEF VAR i-seq-item      AS INT     NO-UNDO.

{cdp/cd0666.i}                     /* Definicao tt-erro */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE MasterDetail
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME fPage0
&Scoped-define BROWSE-NAME brSon1

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-int-ds-it-docto-xml

/* Definitions for BROWSE brSon1                                        */
&Scoped-define FIELDS-IN-QUERY-brSon1 tt-int-ds-it-docto-xml.sequencia tt-int-ds-it-docto-xml.it-codigo tt-int-ds-it-docto-xml.item-do-forn tt-int-ds-it-docto-xml.xprod tt-int-ds-it-docto-xml.numero-ordem tt-int-ds-it-docto-xml.num-pedido tt-int-ds-it-docto-xml.qCom-forn tt-int-ds-it-docto-xml.nat-operacao fn-situacao(tt-int-ds-it-docto-xml.situacao) @ c-desc-situacao tt-int-ds-it-docto-xml.cfop fn-descclass(tt-int-ds-it-docto-xml.it-codigo)   
&Scoped-define ENABLED-FIELDS-IN-QUERY-brSon1   
&Scoped-define SELF-NAME brSon1
&Scoped-define QUERY-STRING-brSon1 FOR EACH tt-int-ds-it-docto-xml NO-LOCK
&Scoped-define OPEN-QUERY-brSon1 OPEN QUERY {&SELF-NAME} FOR EACH tt-int-ds-it-docto-xml NO-LOCK.
&Scoped-define TABLES-IN-QUERY-brSon1 tt-int-ds-it-docto-xml
&Scoped-define FIRST-TABLE-IN-QUERY-brSon1 tt-int-ds-it-docto-xml


/* Definitions for FRAME fPage1                                         */
&Scoped-define OPEN-BROWSERS-IN-QUERY-fPage1 ~
    ~{&OPEN-QUERY-brSon1}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS tt-int-ds-docto-xml.cod-emitente ~
tt-int-ds-docto-xml.cod-estab tt-int-ds-docto-xml.CNPJ ~
tt-int-ds-docto-xml.dEmi tt-int-ds-docto-xml.serie tt-int-ds-docto-xml.nNF ~
tt-int-ds-docto-xml.nat-operacao 
&Scoped-define ENABLED-TABLES tt-int-ds-docto-xml
&Scoped-define FIRST-ENABLED-TABLE tt-int-ds-docto-xml
&Scoped-Define ENABLED-OBJECTS rtToolBar rtParent btFirst btPrev btNext ~
btLast btGoTo btSearch btAdd btUpdate btDelete bt-refresh btQueryJoins ~
btReportsJoins btExit btHelp c-emitente 
&Scoped-Define DISPLAYED-FIELDS tt-int-ds-docto-xml.cod-emitente ~
tt-int-ds-docto-xml.cod-estab tt-int-ds-docto-xml.CNPJ ~
tt-int-ds-docto-xml.dEmi tt-int-ds-docto-xml.serie tt-int-ds-docto-xml.nNF ~
tt-int-ds-docto-xml.nat-operacao 
&Scoped-define DISPLAYED-TABLES tt-int-ds-docto-xml
&Scoped-define FIRST-DISPLAYED-TABLE tt-int-ds-docto-xml
&Scoped-Define DISPLAYED-OBJECTS c-emitente c-estab 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD fn-descclass wMasterDetail 
FUNCTION fn-descclass RETURNS CHARACTER
  ( c-it-codigo AS char)  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD fn-descitem wMasterDetail 
FUNCTION fn-descitem RETURNS CHARACTER
  ( c-it-codigo AS char)  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD fn-Situacao wMasterDetail 
FUNCTION fn-Situacao RETURNS CHARACTER
  ( p-situacao AS INT)  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD fnItem wMasterDetail 
FUNCTION fnItem RETURNS CHARACTER
  ( p-it-codigo AS char,p-cod-emitente AS INTEGER)  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD fnItem-fornec wMasterDetail 
FUNCTION fnItem-fornec RETURNS CHARACTER
  ( p-it-codigo AS char, p-cod-emitente AS INTEGER)  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD fnPedido wMasterDetail 
FUNCTION fnPedido RETURNS CHARACTER
  (p-ts AS INTEGER , p-versao AS INTEGER /* parameter-definitions */ )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD fnQuantidade wMasterDetail 
FUNCTION fnQuantidade RETURNS DECIMAL
  (p-ts AS INTEGER , p-versao AS INTEGER /* parameter-definitions */ )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR wMasterDetail AS WIDGET-HANDLE NO-UNDO.

/* Menu Definitions                                                     */
DEFINE SUB-MENU smFile 
       MENU-ITEM miFirst        LABEL "&Primeiro"      ACCELERATOR "CTRL-HOME"
       MENU-ITEM miPrev         LABEL "&Anterior"      ACCELERATOR "CTRL-CURSOR-LEFT"
       MENU-ITEM miNext         LABEL "&Pr¢ximo"       ACCELERATOR "CTRL-CURSOR-RIGHT"
       MENU-ITEM miLast         LABEL "&éltimo"        ACCELERATOR "CTRL-END"
       RULE
       MENU-ITEM miGoTo         LABEL "&V  Para"       ACCELERATOR "CTRL-T"
       MENU-ITEM miSearch       LABEL "&Pesquisa"      ACCELERATOR "CTRL-F5"
       RULE
       MENU-ITEM miAdd          LABEL "&Incluir"       ACCELERATOR "CTRL-INS"
       MENU-ITEM miCopy         LABEL "&Copiar"        ACCELERATOR "CTRL-C"
       MENU-ITEM miUpdate       LABEL "&Alterar"       ACCELERATOR "CTRL-A"
       MENU-ITEM miDelete       LABEL "&Eliminar"      ACCELERATOR "CTRL-DEL"
       RULE
       MENU-ITEM miQueryJoins   LABEL "&Consultas"    
       MENU-ITEM miReportsJoins LABEL "&Relat¢rios"   
       RULE
       MENU-ITEM miExit         LABEL "&Sair"          ACCELERATOR "CTRL-X".

DEFINE SUB-MENU smHelp 
       MENU-ITEM miContents     LABEL "&Conte£do"     
       RULE
       MENU-ITEM miAbout        LABEL "&Sobre..."     .

DEFINE MENU mbMain MENUBAR
       SUB-MENU  smFile         LABEL "&Arquivo"      
       SUB-MENU  smHelp         LABEL "&Ajuda"        .


/* Definitions of the field level widgets                               */
DEFINE BUTTON bt-refresh 
     IMAGE-UP FILE "image/im-carga.bmp":U
     IMAGE-INSENSITIVE FILE "image/ii-carga.bmp":U
     LABEL "Hel" 
     SIZE 4 BY 1.25 TOOLTIP "Atualiza Registros"
     FONT 4.

DEFINE BUTTON btAdd 
     IMAGE-UP FILE "image\im-add":U
     IMAGE-INSENSITIVE FILE "image\ii-add":U
     LABEL "Add" 
     SIZE 4 BY 1.25
     FONT 4.

DEFINE BUTTON btDelete 
     IMAGE-UP FILE "image\im-era":U
     IMAGE-INSENSITIVE FILE "image\ii-era":U
     LABEL "Delete" 
     SIZE 4 BY 1.25
     FONT 4.

DEFINE BUTTON btExit 
     IMAGE-UP FILE "image\im-exi":U
     IMAGE-INSENSITIVE FILE "image\ii-exi":U
     LABEL "Exit" 
     SIZE 4 BY 1.25
     FONT 4.

DEFINE BUTTON btFirst 
     IMAGE-UP FILE "image\im-fir":U
     IMAGE-INSENSITIVE FILE "image\ii-fir":U
     LABEL "First":L 
     SIZE 4 BY 1.25.

DEFINE BUTTON btGoTo 
     IMAGE-UP FILE "image\im-enter":U
     IMAGE-INSENSITIVE FILE "image\ii-enter":U
     LABEL "Go To" 
     SIZE 4 BY 1.25.

DEFINE BUTTON btHelp 
     IMAGE-UP FILE "image\im-hel":U
     IMAGE-INSENSITIVE FILE "image\ii-hel":U
     LABEL "Help" 
     SIZE 4 BY 1.25
     FONT 4.

DEFINE BUTTON btLast 
     IMAGE-UP FILE "image\im-las":U
     IMAGE-INSENSITIVE FILE "image\ii-las":U
     LABEL "Last":L 
     SIZE 4 BY 1.25.

DEFINE BUTTON btNext 
     IMAGE-UP FILE "image\im-nex":U
     IMAGE-INSENSITIVE FILE "image\ii-nex":U
     LABEL "Next":L 
     SIZE 4 BY 1.25.

DEFINE BUTTON btPrev 
     IMAGE-UP FILE "image\im-pre":U
     IMAGE-INSENSITIVE FILE "image\ii-pre":U
     LABEL "Prev":L 
     SIZE 4 BY 1.25.

DEFINE BUTTON btQueryJoins 
     IMAGE-UP FILE "image\im-joi":U
     IMAGE-INSENSITIVE FILE "image\ii-joi":U
     LABEL "Query Joins" 
     SIZE 4 BY 1.25
     FONT 4.

DEFINE BUTTON btReportsJoins 
     IMAGE-UP FILE "image\im-pri":U
     IMAGE-INSENSITIVE FILE "image\ii-pri":U
     LABEL "Reports Joins" 
     SIZE 4 BY 1.25
     FONT 4.

DEFINE BUTTON btSearch 
     IMAGE-UP FILE "image\im-sea":U
     IMAGE-INSENSITIVE FILE "image\ii-sea":U
     LABEL "Search" 
     SIZE 4 BY 1.25.

DEFINE BUTTON btUpdate 
     IMAGE-UP FILE "image\im-mod":U
     IMAGE-INSENSITIVE FILE "image\ii-mod":U
     LABEL "Update" 
     SIZE 4 BY 1.25
     FONT 4.

DEFINE VARIABLE c-emitente AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 44.72 BY .88 NO-UNDO.

DEFINE VARIABLE c-estab AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 33.43 BY .88 NO-UNDO.

DEFINE RECTANGLE rtParent
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 124 BY 3.5.

DEFINE RECTANGLE rtToolBar
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 126 BY 1.5
     BGCOLOR 7 .

DEFINE BUTTON bt-erros 
     LABEL "Erros" 
     SIZE 10 BY 1.

DEFINE BUTTON bt-natureza 
     LABEL "Natureza" 
     SIZE 10 BY 1.

DEFINE BUTTON btAddSon1 
     LABEL "Incluir" 
     SIZE 10 BY 1.

DEFINE BUTTON btCopySon1 
     LABEL "Copiar" 
     SIZE 10 BY 1.

DEFINE BUTTON btDeleteSon1 
     LABEL "Eliminar" 
     SIZE 10 BY 1.

DEFINE BUTTON btUpdateSon1 
     LABEL "Alterar" 
     SIZE 10 BY 1.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY brSon1 FOR 
      tt-int-ds-it-docto-xml SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE brSon1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS brSon1 wMasterDetail _FREEFORM
  QUERY brSon1 NO-LOCK DISPLAY
      tt-int-ds-it-docto-xml.sequencia    FORMAT ">>>>>9" COLUMN-LABEL "Seq" WIDTH 3
      tt-int-ds-it-docto-xml.it-codigo    FORMAT "x(16)":U   WIDTH 12 COLUMN-LABEL "Item"
      tt-int-ds-it-docto-xml.item-do-forn FORMAT "x(20)":U   WIDTH 12 COLUMN-LABEL "Item fornec"
      tt-int-ds-it-docto-xml.xprod        FORMAT "X(30)" COLUMN-LABEL "Descri‡Æo"
      tt-int-ds-it-docto-xml.numero-ordem   
      tt-int-ds-it-docto-xml.num-pedido   COLUMN-LABEL "Pedido" FORMAT ">>>>>>>>>9"    
      tt-int-ds-it-docto-xml.qCom-forn    COLUMN-LABEL "Quantidade" FORMAT ">>>,>>>,>>>,>>9.99":U WIDTH 13
      tt-int-ds-it-docto-xml.nat-operacao
      fn-situacao(tt-int-ds-it-docto-xml.situacao) @ c-desc-situacao LABEL "Situa‡Æo" FORMAT "x(12)"
      tt-int-ds-it-docto-xml.cfop
      fn-descclass(tt-int-ds-it-docto-xml.it-codigo) FORMAT "X(30)" COLUMN-LABEL "Class.Fiscal"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 116 BY 12
         FONT 2.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME fPage0
     btFirst AT ROW 1.13 COL 1.57 HELP
          "Primeira ocorrˆncia"
     btPrev AT ROW 1.13 COL 5.57 HELP
          "Ocorrˆncia anterior"
     btNext AT ROW 1.13 COL 9.57 HELP
          "Pr¢xima ocorrˆncia"
     btLast AT ROW 1.13 COL 13.57 HELP
          "éltima ocorrˆncia"
     btGoTo AT ROW 1.13 COL 17.57 HELP
          "V  Para"
     btSearch AT ROW 1.13 COL 21.57 HELP
          "Pesquisa"
     btAdd AT ROW 1.13 COL 31 HELP
          "Inclui nova ocorrˆncia"
     btUpdate AT ROW 1.13 COL 34.86 HELP
          "Altera ocorrˆncia corrente"
     btDelete AT ROW 1.13 COL 38.86 HELP
          "Elimina ocorrˆncia corrente"
     bt-refresh AT ROW 1.13 COL 75.86 HELP
          "Importar XML" WIDGET-ID 14
     btQueryJoins AT ROW 1.13 COL 109.86 HELP
          "Consultas relacionadas"
     btReportsJoins AT ROW 1.13 COL 113.86 HELP
          "Relat¢rios relacionados"
     btExit AT ROW 1.13 COL 117.86 HELP
          "Sair"
     btHelp AT ROW 1.13 COL 121.86 HELP
          "Ajuda"
     tt-int-ds-docto-xml.cod-emitente AT ROW 3 COL 66 COLON-ALIGNED WIDGET-ID 74
          VIEW-AS FILL-IN 
          SIZE 10 BY .88
     c-emitente AT ROW 3 COL 76.29 COLON-ALIGNED NO-LABEL WIDGET-ID 42
     tt-int-ds-docto-xml.cod-estab AT ROW 3.08 COL 14 COLON-ALIGNED WIDGET-ID 6
          VIEW-AS FILL-IN 
          SIZE 5 BY .88
     c-estab AT ROW 3.08 COL 19.14 COLON-ALIGNED NO-LABEL WIDGET-ID 34
     tt-int-ds-docto-xml.CNPJ AT ROW 4 COL 66 COLON-ALIGNED WIDGET-ID 80
          VIEW-AS FILL-IN 
          SIZE 15.43 BY .88
     tt-int-ds-docto-xml.dEmi AT ROW 4 COL 110 COLON-ALIGNED WIDGET-ID 78
          VIEW-AS FILL-IN 
          SIZE 11 BY .88
     tt-int-ds-docto-xml.serie AT ROW 4.08 COL 14 COLON-ALIGNED WIDGET-ID 54
          VIEW-AS FILL-IN 
          SIZE 5 BY .88
     tt-int-ds-docto-xml.nNF AT ROW 5.08 COL 14 COLON-ALIGNED WIDGET-ID 76
          LABEL "Nota"
          VIEW-AS FILL-IN 
          SIZE 12.57 BY .88
     tt-int-ds-docto-xml.nat-operacao AT ROW 5.08 COL 66 COLON-ALIGNED WIDGET-ID 80
          VIEW-AS FILL-IN 
          SIZE 12 BY .88
     rtToolBar AT ROW 1 COL 1
     rtParent AT ROW 2.75 COL 1.86
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 126 BY 21.25
         FONT 1 WIDGET-ID 100.

DEFINE FRAME fPage1
     brSon1 AT ROW 1.75 COL 4
     btAddSon1 AT ROW 14 COL 3.57
     btCopySon1 AT ROW 14 COL 13.57
     btUpdateSon1 AT ROW 14 COL 23.57
     btDeleteSon1 AT ROW 14 COL 33.57
     bt-natureza AT ROW 14 COL 63.72 WIDGET-ID 74
     bt-erros AT ROW 14 COL 74 WIDGET-ID 72
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 2 ROW 7.46
         SIZE 123 BY 14.38
         FONT 1 WIDGET-ID 100.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: MasterDetail
   Allow: Basic,Browse,DB-Fields,Window,Query
   Add Fields to: Neither
   Other Settings: COMPILE
   Temp-Tables and Buffers:
      TABLE: tt-int-ds-docto-xml T "?" NO-UNDO emsespe int-ds-docto-xml
      ADDITIONAL-FIELDS:
          fields r-rowid as rowid
      END-FIELDS.
      TABLE: tt-int-ds-it-docto-xml T "?" NO-UNDO emsespe int-ds-it-docto-xml
      ADDITIONAL-FIELDS:
          fields r-rowid as rowid
      END-FIELDS.
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
IF SESSION:DISPLAY-TYPE = "GUI":U THEN
  CREATE WINDOW wMasterDetail ASSIGN
         HIDDEN             = YES
         TITLE              = ""
         HEIGHT             = 21.25
         WIDTH              = 126
         MAX-HEIGHT         = 29.38
         MAX-WIDTH          = 195.14
         VIRTUAL-HEIGHT     = 29.38
         VIRTUAL-WIDTH      = 195.14
         RESIZE             = yes
         SCROLL-BARS        = no
         STATUS-AREA        = yes
         BGCOLOR            = ?
         FGCOLOR            = ?
         KEEP-FRAME-Z-ORDER = yes
         THREE-D            = yes
         MESSAGE-AREA       = no
         SENSITIVE          = yes.
ELSE {&WINDOW-NAME} = CURRENT-WINDOW.

ASSIGN {&WINDOW-NAME}:MENUBAR    = MENU mbMain:HANDLE.
/* END WINDOW DEFINITION                                                */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _INCLUDED-LIB wMasterDetail 
/* ************************* Included-Libraries *********************** */

{masterdetail/masterdetail.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME




/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW wMasterDetail
  NOT-VISIBLE,,RUN-PERSISTENT                                           */
/* REPARENT FRAME */
ASSIGN FRAME fPage1:FRAME = FRAME fPage0:HANDLE.

/* SETTINGS FOR FRAME fPage0
   FRAME-NAME                                                           */
/* SETTINGS FOR FILL-IN c-estab IN FRAME fPage0
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN tt-int-ds-docto-xml.nNF IN FRAME fPage0
   EXP-LABEL                                                            */
/* SETTINGS FOR FRAME fPage1
                                                                        */
/* BROWSE-TAB brSon1 1 fPage1 */
IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(wMasterDetail)
THEN wMasterDetail:HIDDEN = yes.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE brSon1
/* Query rebuild information for BROWSE brSon1
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH tt-int-ds-it-docto-xml NO-LOCK.
     _END_FREEFORM
     _Options          = "NO-LOCK"
     _Query            is OPENED
*/  /* BROWSE brSon1 */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK FRAME fPage0
/* Query rebuild information for FRAME fPage0
     _Options          = "SHARE-LOCK KEEP-EMPTY"
     _Query            is NOT OPENED
*/  /* FRAME fPage0 */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK FRAME fPage1
/* Query rebuild information for FRAME fPage1
     _Query            is NOT OPENED
*/  /* FRAME fPage1 */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME wMasterDetail
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL wMasterDetail wMasterDetail
ON END-ERROR OF wMasterDetail
OR ENDKEY OF {&WINDOW-NAME} ANYWHERE DO:
  /* This case occurs when the user presses the "Esc" key.
     In a persistently run window, just ignore this.  If we did not, the
     application would exit. */
  IF THIS-PROCEDURE:PERSISTENT THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL wMasterDetail wMasterDetail
ON WINDOW-CLOSE OF wMasterDetail
DO:
  /* This event will close the window and terminate the procedure.  */
  APPLY "CLOSE":U TO THIS-PROCEDURE.
  RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME brSon1
&Scoped-define FRAME-NAME fPage1
&Scoped-define SELF-NAME brSon1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL brSon1 wMasterDetail
ON ROW-DISPLAY OF brSon1 IN FRAME fPage1
DO:
  
    IF AVAIL tt-int-ds-it-docto-xml THEN DO:

      IF tt-int-ds-it-docto-xml.situacao = 1 THEN
         ASSIGN c-desc-situacao:BGCOLOR IN BROWSE brSon1 = 12.
      ELSE IF tt-int-ds-it-docto-xml.situacao = 2 THEN
         ASSIGN c-desc-situacao:BGCOLOR IN BROWSE brSon1 = 14.
      ELSE IF tt-int-ds-it-docto-xml.situacao = 3 THEN
         ASSIGN c-desc-situacao:BGCOLOR IN BROWSE brSon1 = 2.
      ELSE 
          ASSIGN c-desc-situacao:BGCOLOR IN BROWSE brSon1 = 4.
   
  END.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL brSon1 wMasterDetail
ON VALUE-CHANGED OF brSon1 IN FRAME fPage1
DO:

  IF AVAIL tt-int-ds-it-docto-xml THEN
     ASSIGN i-seq-item = tt-int-ds-it-docto-xml.sequencia.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-erros
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-erros wMasterDetail
ON CHOOSE OF bt-erros IN FRAME fPage1 /* Erros */
DO:
  
  IF brSon1:NUM-ITERATIONS > 0
  THEN DO:
        brSon1:SELECT-FOCUSED-ROW().
        
        if AVAIL tt-int-ds-docto-xml then do:
           EMPTY TEMP-TABLE tt-erro.
           
           ASSIGN i-seq-erro = 0.

           FOR EACH int-ds-doc-erro NO-LOCK WHERE
                    int-ds-doc-erro.serie-docto  = tt-int-ds-docto-xml.serie        AND 
                    int-ds-doc-erro.cod-emitente = tt-int-ds-docto-xml.cod-emitente AND
                    int-ds-doc-erro.CNPJ         = tt-int-ds-docto-xml.CNPJ         AND        
                    int-ds-doc-erro.nro-docto    = tt-int-ds-docto-xml.nNF          AND 
                    int-ds-doc-erro.tipo-nota    = tt-int-ds-docto-xml.tipo-nota
               BY int-ds-doc-erro.cod-erro :
                 
                CREATE tt-erro.
                ASSIGN i-seq-erro        = i-seq-erro + 1 
                       tt-erro.i-sequen  = i-seq-erro
                       tt-erro.cd-erro   = int-ds-doc-erro.cod-erro
                       tt-erro.mensagem  = int-ds-doc-erro.descricao. 

           END. 

           IF i-seq-erro > 0 THEN  
               run cdp/cd0666.w (input table tt-erro).
        
        END.
  END.
 
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-natureza
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-natureza wMasterDetail
ON CHOOSE OF bt-natureza IN FRAME fPage1 /* Natureza */
DO:
  
  IF brSon1:NUM-ITERATIONS > 0
  THEN DO:
        brSon1:SELECT-FOCUSED-ROW().
        
        if AVAIL tt-int-ds-docto-xml 
        then do:
            
            RUN intprg/int002h.w (INPUT tt-int-ds-docto-xml.r-rowid,
                                  OUTPUT l-ok). 

            IF l-ok THEN DO:
               APPLY "choose" TO bt-refresh IN FRAME fpage0.
            END.
               
        
        END.
  END.

 
 
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME fPage0
&Scoped-define SELF-NAME bt-refresh
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-refresh wMasterDetail
ON CHOOSE OF bt-refresh IN FRAME fPage0 /* Hel */
DO:
  
  IF AVAIL tt-int-ds-docto-xml 
  THEN DO:
  
      ASSIGN r-row-atual = tt-int-ds-docto-xml.r-rowid.  
              
      RUN initializeDBOs.

      RUN repositionRecord IN THIS-PROCEDURE (r-row-atual).
      
  END.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btAdd
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btAdd wMasterDetail
ON CHOOSE OF btAdd IN FRAME fPage0 /* Add */
OR CHOOSE OF MENU-ITEM miAdd IN MENU mbMain DO:
    RUN addRecord IN THIS-PROCEDURE (INPUT "intprg\int002a-01.w":U). 
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME fPage1
&Scoped-define SELF-NAME btAddSon1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btAddSon1 wMasterDetail
ON CHOOSE OF btAddSon1 IN FRAME fPage1 /* Incluir */
DO:
    {masterdetail/addson.i &ProgramSon="intprg\int002b-01.w"
                           &PageNumber="1"}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btCopySon1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btCopySon1 wMasterDetail
ON CHOOSE OF btCopySon1 IN FRAME fPage1 /* Copiar */
DO:
    {masterdetail/copyson.i &ProgramSon="intprg\int002b-01.w"
                            &PageNumber="1"}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME fPage0
&Scoped-define SELF-NAME btDelete
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btDelete wMasterDetail
ON CHOOSE OF btDelete IN FRAME fPage0 /* Delete */
OR CHOOSE OF MENU-ITEM miDelete IN MENU mbMain DO:
    RUN deleteRecord IN THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME fPage1
&Scoped-define SELF-NAME btDeleteSon1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btDeleteSon1 wMasterDetail
ON CHOOSE OF btDeleteSon1 IN FRAME fPage1 /* Eliminar */
DO:
    
   {masterdetail/deleteson.i &PageNumber="1"}
    
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME fPage0
&Scoped-define SELF-NAME btExit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btExit wMasterDetail
ON CHOOSE OF btExit IN FRAME fPage0 /* Exit */
OR CHOOSE OF MENU-ITEM miExit IN MENU mbMain DO:
    APPLY "CLOSE":U TO THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btFirst
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btFirst wMasterDetail
ON CHOOSE OF btFirst IN FRAME fPage0 /* First */
OR CHOOSE OF MENU-ITEM miFirst IN MENU mbMain DO:
    RUN getFirst IN THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btGoTo
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btGoTo wMasterDetail
ON CHOOSE OF btGoTo IN FRAME fPage0 /* Go To */
OR CHOOSE OF MENU-ITEM miGoTo IN MENU mbMain DO:
    RUN goToRecord IN THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btHelp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btHelp wMasterDetail
ON CHOOSE OF btHelp IN FRAME fPage0 /* Help */
OR CHOOSE OF MENU-ITEM miContents IN MENU mbMain DO:
    {include/ajuda.i}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btLast
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btLast wMasterDetail
ON CHOOSE OF btLast IN FRAME fPage0 /* Last */
OR CHOOSE OF MENU-ITEM miLast IN MENU mbMain DO:
    RUN getLast IN THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btNext
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btNext wMasterDetail
ON CHOOSE OF btNext IN FRAME fPage0 /* Next */
OR CHOOSE OF MENU-ITEM miNext IN MENU mbMain DO:
    RUN getNext IN THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btPrev
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btPrev wMasterDetail
ON CHOOSE OF btPrev IN FRAME fPage0 /* Prev */
OR CHOOSE OF MENU-ITEM miPrev IN MENU mbMain DO:
    RUN getPrev IN THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btQueryJoins
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btQueryJoins wMasterDetail
ON CHOOSE OF btQueryJoins IN FRAME fPage0 /* Query Joins */
OR CHOOSE OF MENU-ITEM miQueryJoins IN MENU mbMain DO:
    RUN showQueryJoins IN THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btReportsJoins
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btReportsJoins wMasterDetail
ON CHOOSE OF btReportsJoins IN FRAME fPage0 /* Reports Joins */
OR CHOOSE OF MENU-ITEM miReportsJoins IN MENU mbMain DO:
    RUN showReportsJoins IN THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btSearch
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btSearch wMasterDetail
ON CHOOSE OF btSearch IN FRAME fPage0 /* Search */
OR CHOOSE OF MENU-ITEM miSearch IN MENU mbMain DO:
    {method/zoomreposition.i &ProgramZoom="intprg\int002zoom.w"}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btUpdate
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btUpdate wMasterDetail
ON CHOOSE OF btUpdate IN FRAME fPage0 /* Update */
OR CHOOSE OF MENU-ITEM miUpdate IN MENU mbMain DO:
    RUN updateRecord IN THIS-PROCEDURE (INPUT "intprg\int002a-01.w":U).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME fPage1
&Scoped-define SELF-NAME btUpdateSon1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btUpdateSon1 wMasterDetail
ON CHOOSE OF btUpdateSon1 IN FRAME fPage1 /* Alterar */
DO:
    
    ASSIGN i-seq-item =  tt-int-ds-it-docto-xml.sequencia.
           
    {masterdetail/updateson.i &ProgramSon="intprg\int002b-01.w"
                              &PageNumber="1"}
   

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME fPage0
&Scoped-define SELF-NAME tt-int-ds-docto-xml.cod-emitente
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-int-ds-docto-xml.cod-emitente wMasterDetail
ON LEAVE OF tt-int-ds-docto-xml.cod-emitente IN FRAME fPage0 /* Emitente */
DO:
  FIND FIRST emitente WHERE 
             emitente.cod-emitente = tt-int-ds-docto-xml.cod-emitente NO-LOCK NO-ERROR.
  IF AVAIL emitente THEN DO:
      ASSIGN c-emitente:SCREEN-VALUE IN FRAME fpage0 = emitente.nome-emit.
  END.
  ELSE DO:
      ASSIGN c-emitente:SCREEN-VALUE IN FRAME fpage0 = "".
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-int-ds-docto-xml.cod-estab
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-int-ds-docto-xml.cod-estab wMasterDetail
ON LEAVE OF tt-int-ds-docto-xml.cod-estab IN FRAME fPage0 /* Estabelecimento */
DO:
   FIND FIRST estabelec WHERE 
              estabelec.cod-estabel = INPUT FRAME fpage0 tt-int-ds-docto-xml.cod-estab NO-LOCK NO-ERROR.
  IF AVAIL estabelec THEN DO:
      ASSIGN c-estab:SCREEN-VALUE IN FRAME fpage0 = estabelec.nome.
  END.
  ELSE DO:
      ASSIGN c-estab:SCREEN-VALUE IN FRAME fpage0 = "".
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK wMasterDetail 


/*:T--- L¢gica para inicializa‡Æo do programam ---*/
{masterdetail/mainblock.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE afterdisplayfields wMasterDetail 
PROCEDURE afterdisplayfields :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
  
    IF AVAIL tt-int-ds-docto-xml THEN DO:

         IF tt-int-ds-docto-xml.arquivo <> "" THEN DO:
          ASSIGN btDeleteSon1:SENSITIVE IN FRAME fpage1 = NO
                 btAddSon1:SENSITIVE IN FRAME fpage1 = NO
                 btCopySon1:SENSITIVE IN FRAME fpage1 = NO.
      END.
      ELSE DO:
          ASSIGN btDeleteSon1:SENSITIVE IN FRAME fpage1 = YES
                 btAddSon1:SENSITIVE IN FRAME fpage1 = YES
                 btCopySon1:SENSITIVE IN FRAME fpage1 = YES.
      END.
       

    END.

    APPLY 'leave' TO tt-int-ds-docto-xml.cod-estab      IN FRAME fpage0.
    APPLY 'leave' TO tt-int-ds-docto-xml.cod-emitente   IN FRAME fpage0.

   RETURN "ok".

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE afterInitializeInterface wMasterDetail 
PROCEDURE afterInitializeInterface :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    ASSIGN bt-refresh:SENSITIVE IN FRAME fpage0  = YES 
           bt-erros:SENSITIVE IN FRAME fpage1    = YES
           bt-natureza:SENSITIVE IN FRAME fpage1 = YES.

    RETURN "Ok".

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE AfterOpenQueriesSon wMasterDetail 
PROCEDURE AfterOpenQueriesSon :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

       

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE goToRecord wMasterDetail 
PROCEDURE goToRecord :
/*:T------------------------------------------------------------------------------
  Purpose:     Exibe dialog de V  Para
  Parameters:  
  Notes:       
------------------------------------------------------------------------------*/
    DEFINE BUTTON btGoToCancel AUTO-END-KEY 
         LABEL "&Cancelar" 
         SIZE 10 BY 1
         BGCOLOR 8.
    
    DEFINE BUTTON btGoToOK AUTO-GO 
         LABEL "&OK" 
         SIZE 10 BY 1
         BGCOLOR 8.
    
    DEFINE RECTANGLE rtGoToButton
         EDGE-PIXELS 2 GRAPHIC-EDGE  
         SIZE 58 BY 1.42
         BGCOLOR 7.
    
    DEFINE VARIABLE rGoTo AS ROWID NO-UNDO.
    
    DEFINE VARIABLE i-cod-emitente LIKE {&ttParent}.cod-emitente NO-UNDO.
    DEFINE VARIABLE c-serie        LIKE {&ttParent}.serie        NO-UNDO.
    DEFINE VARIABLE c-nro-docto    LIKE {&ttParent}.nnf          NO-UNDO.

    DEF VAR i-tipo-nota LIKE int-ds-docto-xml.tipo-nota NO-UNDO.
    DEFINE VARIABLE cb-tipo-nota AS CHARACTER FORMAT "X(256)":U 
     LABEL "Tipo Nota" 
     VIEW-AS COMBO-BOX INNER-LINES 4
     LIST-ITEMS "Nota de Compra","Devolu‡Æo","Transferˆncia","Remessa Entr. Futura"
     DROP-DOWN-LIST 
     SIZE 16 BY 1  NO-UNDO.
    
    DEFINE FRAME fGoToRecord
        i-cod-emitente AT ROW 1.21 COL 17.72 COLON-ALIGNED
        c-serie        AT ROW 2.21 COL 17.72 COLON-ALIGNED
        c-nro-docto    AT ROW 3.21 COL 17.72 COLON-ALIGNED LABEL "Nota"
        cb-tipo-nota   AT ROW 4.21 COL 17.72 COLON-ALIGNED
        btGoToOK       AT ROW 6.63 COL 2.14
        btGoToCancel   AT ROW 6.63 COL 13
        rtGoToButton   AT ROW 6.38 COL 1
        SPACE(0.28)
        WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER SIDE-LABELS NO-UNDERLINE 
             THREE-D SCROLLABLE TITLE "V  Para Nota" FONT 1
             DEFAULT-BUTTON btGoToOK CANCEL-BUTTON btGoToCancel.
    
    ASSIGN cb-tipo-nota:SCREEN-VALUE IN FRAME fGoToRecord = "Nota de Compra".

/*tech1139 - FO 1338.917 - 10/07/2006  */
    RUN utp/ut-trfrrp.p (input Frame fGoToRecord:Handle).
    {utp/ut-liter.i "V _Para_Nota_DDD"}
    ASSIGN FRAME fGoToRecord:TITLE = RETURN-VALUE.
/*tech1139 - FO 1338.917 - 10/07/2006  */
                                         
    ON "CHOOSE":U OF btGoToOK IN FRAME fGoToRecord DO:
        ASSIGN i-cod-emitente c-serie c-nro-docto cb-tipo-nota.

         CASE cb-tipo-nota:
            WHEN "Nota de Compra"       THEN ASSIGN i-tipo-nota = 1.
            WHEN "Devolu‡Æo"            THEN ASSIGN i-tipo-nota = 2.
            WHEN "Transferˆncia"        THEN ASSIGN i-tipo-nota = 3.
            WHEN "Remessa Entr. Futura" THEN ASSIGN i-tipo-nota = 4.
            OTHERWISE ASSIGN i-tipo-nota = INT(cb-tipo-nota).
    
        END CASE.

        /*:T Posiciona query, do DBO, atrav‚s dos valores do ¡ndice £nico */
        RUN goToKey IN {&hDBOParent} (INPUT i-cod-emitente,
                                            c-serie ,      
                                            c-nro-docto,      
                                            i-tipo-nota). 
                                               
        IF RETURN-VALUE = "NOK":U THEN DO:
            RUN utp/ut-msgs.p (INPUT "SHOW":U, INPUT 2, INPUT "Nota_DDD":U).
            
            RETURN NO-APPLY.
        END.
        
        /*:T Retorna rowid do registro corrente do DBO */
        RUN getRowid IN {&hDBOParent} (OUTPUT rGoTo).
        
        /*:T Reposiciona registro com base em um rowid */
        RUN repositionRecord IN THIS-PROCEDURE (INPUT rGoTo).
        
        APPLY "GO":U TO FRAME fGoToRecord.
    END.
    
    ENABLE i-cod-emitente c-serie c-nro-docto cb-tipo-nota  btGoToOK btGoToCancel 
        WITH FRAME fGoToRecord. 
    
    WAIT-FOR "GO":U OF FRAME fGoToRecord.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE initializeDBOs wMasterDetail 
PROCEDURE initializeDBOs :
/*:T------------------------------------------------------------------------------
  Purpose:     Inicializa DBOs
  Parameters:  
  Notes:       
------------------------------------------------------------------------------*/
    
    /*:T--- Verifica se o DBO j  est  inicializado ---*/
    IF NOT VALID-HANDLE({&hDBOParent})  THEN DO:
        {btb/btb008za.i1 intprg\intbo002a.p YES}
        {btb/btb008za.i2 intprg\intbo002a.p '' {&hDBOParent}} 
    END.   
   
    
    RUN openQueryStatic IN {&hDBOParent} (INPUT "Main":U) NO-ERROR.
    
    /*:T--- Verifica se o DBO j  est  inicializado ---*/
    IF NOT VALID-HANDLE({&hDBOSon1}) THEN DO:        
       
          
        {btb/btb008za.i1 intprg\intbo002b.p YES}
        {btb/btb008za.i2 intprg\intbo002b.p '' {&hDBOSon1}}       
       
         
    END.    
     
      
    RUN LinktoNota      IN {&hDBOSon1} (INPUT {&hDBOParent}) NO-ERROR. 
    
      
    RUN openQueryStatic IN {&hDBOSon1} (INPUT "item":U) NO-ERROR.  
    
   
    
    RETURN "OK":U.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE openQueriesSon wMasterDetail 
PROCEDURE openQueriesSon :
/*:T------------------------------------------------------------------------------
  Purpose:     Atualiza browsers filhos
  Parameters:  
  Notes:       
------------------------------------------------------------------------------*/
    
    {masterdetail/openqueriesson.i &Parent="Nota"
                                   &Query="Item"
                                   &PageNumber="1"}
                                   
  IF i-seq-item > 0 
  THEN DO:

     FOR FIRST bf-tt-int-ds-it-docto-xml NO-LOCK WHERE
               bf-tt-int-ds-it-docto-xml.nnf       = tt-int-ds-docto-xml.nnf       AND 
               bf-tt-int-ds-it-docto-xml.serie     = tt-int-ds-docto-xml.serie     AND
               bf-tt-int-ds-it-docto-xml.cnpj      = tt-int-ds-docto-xml.cnpj      AND 
               bf-tt-int-ds-it-docto-xml.tipo-nota = tt-int-ds-docto-xml.tipo-nota AND
               bf-tt-int-ds-it-docto-xml.sequencia =  i-seq-item :

     END.
              
     IF AVAIL bf-tt-int-ds-it-docto-xml THEN DO:
      
/*         IF c-seg-usuario = "super" THEN                  */
/*            MESSAGE "vai reposicionar" VIEW-AS ALERT-BOX. */

        REPOSITION brSon1 TO ROWID ROWID(bf-tt-int-ds-it-docto-xml).

     END. 

  END.

  RETURN "OK":U.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-reposiciona-filho wMasterDetail 
PROCEDURE pi-reposiciona-filho :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    IF AVAIL tt-int-ds-docto-xml THEN
        RUN repositionRecord IN THIS-PROCEDURE (INPUT tt-int-ds-docto-xml.r-rowid).

    RETURN "ok".

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION fn-descclass wMasterDetail 
FUNCTION fn-descclass RETURNS CHARACTER
  ( c-it-codigo AS char) :
/*------------------------------------------------------------------------------
  Purpose:  
    Notes:  
------------------------------------------------------------------------------*/
DEF VAR c-desc-class AS CHAR.

 FIND FIRST ITEM NO-LOCK WHERE
            ITEM.it-codigo = tt-int-ds-it-docto-xml.it-codigo NO-ERROR.
 IF AVAIL ITEM THEN DO:

    FIND FIRST classif-fisc NO-LOCK WHERE
               classif-fisc.class-fiscal = ITEM.class-fiscal NO-ERROR.
    IF AVAIL classif-fisc THEN
       ASSIGN c-desc-class = classif-fisc.class-fiscal + "-" +  classif-fisc.descricao.
    ELSE
       ASSIGN c-desc-class = "".

 END.    
 ELSE 
    ASSIGN c-desc-class = "". 


  RETURN c-desc-class.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION fn-descitem wMasterDetail 
FUNCTION fn-descitem RETURNS CHARACTER
  ( c-it-codigo AS char) :
/*------------------------------------------------------------------------------
  Purpose:  
    Notes:  
------------------------------------------------------------------------------*/
DEF VAR c-desc-item AS CHAR.

 /* FIND FIRST ITEM NO-LOCK WHERE
            ITEM.it-codigo = tt-int-ds-it-docto-xml.it-codigo NO-ERROR.
 IF AVAIL ITEM THEN
    ASSIGN c-desc-item = ITEM.DESC-item.
 ELSE */

  ASSIGN c-desc-item = tt-int-ds-it-docto-xml.xprod. 
                    
  RETURN c-desc-item.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION fn-Situacao wMasterDetail 
FUNCTION fn-Situacao RETURNS CHARACTER
  ( p-situacao AS INT) :
/*------------------------------------------------------------------------------
  Purpose:  
    Notes:  
------------------------------------------------------------------------------*/
IF p-situacao = 1 THEN
   RETURN "Pendente".   
IF p-situacao = 2 THEN
   RETURN "Liberado".   
IF p-situacao = 3 THEN
   RETURN "Atualizado". 
IF p-situacao = 4 THEN
   RETURN "Devolvido".

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION fnItem wMasterDetail 
FUNCTION fnItem RETURNS CHARACTER
  ( p-it-codigo AS char,p-cod-emitente AS INTEGER) :
/*------------------------------------------------------------------------------
  Purpose:  
    Notes:  
------------------------------------------------------------------------------*/
DEF VAR c-it-codigo LIKE item.it-codigo.
 


/* FIND FIRST ITEM NO-LOCK WHERE
           ITEM.it-codigo = p-it-codigo NO-ERROR.
IF NOT AVAIL ITEM 
THEN DO:
   ASSIGN c-it-codigo = "".
END.    
ELSE DO: 
  ASSIGN c-it-codigo = ITEM.it-codigo.

  /* FIND FIRST item-fornec NO-LOCK WHERE
             item-fornec.cod-emitente = tt-int-ds-it-docto-xml.cod-emitente AND 
             item-fornec.item-do-forn = ITEM.it-codigo NO-ERROR.
  IF NOT AVAIL item-fornec THEN  
     ASSIGN c-it-codigo = "". */  
  
     
END. */

RETURN c-it-codigo.   /* Function return value. */


END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION fnItem-fornec wMasterDetail 
FUNCTION fnItem-fornec RETURNS CHARACTER
  ( p-it-codigo AS char, p-cod-emitente AS INTEGER) :
/*------------------------------------------------------------------------------
  Purpose:  
    Notes:  
------------------------------------------------------------------------------*/
DEF VAR c-it-codigo LIKE item.it-codigo.

    /* FIND FIRST item-fornec NO-LOCK WHERE
               item-fornec.cod-emitente = p-cod-emitente AND 
               ITEM-fornec.item-do-forn = p-it-codigo NO-ERROR.
    IF AVAIL item-fornec THEN DO:

       ASSIGN c-it-codigo = ITEM-fornec.item-do-forn.
     
    END.
    ELSE DO: 
       ASSIGN c-it-codigo = p-it-codigo.    
    END. */

    ASSIGN c-it-codigo = tt-int-ds-it-docto-xml.item-do-forn.

RETURN c-it-codigo.   /* Function return value. */


END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION fnPedido wMasterDetail 
FUNCTION fnPedido RETURNS CHARACTER
  (p-ts AS INTEGER , p-versao AS INTEGER /* parameter-definitions */ ) :
/*------------------------------------------------------------------------------
  Purpose:  
    Notes:  
------------------------------------------------------------------------------*/

RETURN "".   /* Function return value. */

  

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION fnQuantidade wMasterDetail 
FUNCTION fnQuantidade RETURNS DECIMAL
  (p-ts AS INTEGER , p-versao AS INTEGER /* parameter-definitions */ ) :
/*------------------------------------------------------------------------------
  Purpose:  
    Notes:  
------------------------------------------------------------------------------*/

RETURN 0.00.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

