&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
          emsesp           ORACLE
*/
&Scoped-define WINDOW-NAME wMasterDetail


/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE tt-int-ds-cenar-estoq NO-UNDO LIKE int-ds-cenar-estoq
       fields r-rowid as rowid
       fields marca as logical.
DEFINE TEMP-TABLE tt-int-ds-cenario NO-UNDO LIKE int-ds-cenario
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

{include/i-prgvrs.i int009f 2.12.00.001}

CREATE WIDGET-POOL.

/* Preprocessors Definitions ---                                      */
&GLOBAL-DEFINE Program          int009f
&GLOBAL-DEFINE Version          2.12.00.01
&GLOBAL-DEFINE Folder           YES
&GLOBAL-DEFINE InitialPage      1
&GLOBAL-DEFINE FolderLabels     Dif. Estoque


&GLOBAL-DEFINE First            YES
&GLOBAL-DEFINE Prev             YES
&GLOBAL-DEFINE Next             YES
&GLOBAL-DEFINE Last             YES
&GLOBAL-DEFINE GoTo             YES
&GLOBAL-DEFINE Search           YES

&GLOBAL-DEFINE AddParent        NO
&GLOBAL-DEFINE CopyParent       NO
&GLOBAL-DEFINE UpdateParent     NO
&GLOBAL-DEFINE DeleteParent     NO

&GLOBAL-DEFINE AddSon1          NO
&GLOBAL-DEFINE CopySon1         NO
&GLOBAL-DEFINE UpdateSon1       NO
&GLOBAL-DEFINE DeleteSon1       NO

&GLOBAL-DEFINE ttParent         tt-int-ds-cenario     
&GLOBAL-DEFINE hDBOParent       h-dbo-int-ds-cenario  
&GLOBAL-DEFINE DBOParentTable   dbo-int-ds-cenario    
&GLOBAL-DEFINE DBOParentDestroy YES                   

&GLOBAL-DEFINE ttSon1           tt-int-ds-cenar-estoq
&GLOBAL-DEFINE hDBOSon1         h-dbo-int-ds-cenar-estoq
&GLOBAL-DEFINE DBOSon1Table     dbo-int-ds-cenar-estoq
&GLOBAL-DEFINE DBOSon1Destroy   NO


DEFINE BUFFER bf-int-ds-cenar-estoq FOR int-ds-cenar-estoq.

&GLOBAL-DEFINE page0Fields      tt-int-ds-cenario.cod-cenario tt-int-ds-cenario.descricao cb-relat c-cod-estab-ini c-cod-estab-fin 

&GLOBAL-DEFINE page1Widget      tg-todos bt-movto
&GLOBAL-DEFINE page2Widget      
&GLOBAL-DEFINE page2Widget      
&GLOBAL-DEFINE page1Browse      brSon1 

DEFINE VARIABLE {&hDBOParent} AS HANDLE NO-UNDO.
DEFINE VARIABLE {&hDBOSon1}   AS HANDLE NO-UNDO.

DEF VAR c-desc-situacao AS CHAR NO-UNDO.
DEF VAR i-seq-erro      AS INT  NO-UNDO.

{cdp/cd0666.i}                     /* Definicao tt-erro */

DEFINE BUFFER b-tt-int-ds-cenar-estoq FOR tt-int-ds-cenar-estoq.

define temp-table tt-param no-undo
    field destino          as integer
    field arquivo          as char format "x(35)":U
    field usuario          as char format "x(12)":U
    field data-exec        as date
    field hora-exec        as integer
    field classifica       as integer
    field desc-classifica  as char format "x(40)":U
    field modelo           AS char format "x(35)":U
    field l-habilitaRtf    as LOG
    FIELD arq-modelo       AS CHAR
    FIELD cod-cenario-ini  LIKE int-ds-cenario.cod-cenario
    FIELD cod-cenario-fin  LIKE int-ds-cenario.cod-cenario
    FIELD cod-estab-ini    LIKE estabelec.cod-estabel 
    FIELD cod-estab-fin    LIKE estabelec.cod-estabel
    FIELD tipo-relat       AS INTEGER.

def temp-table tt-raw-digita
    field raw-digita as raw.

DEF TEMP-TABLE tt-raw-param 
 FIELD raw-param  AS RAW.

DEF TEMP-TABLE tt-digita LIKE int-ds-cenar-estoq
FIELD r-rowid AS ROW.

DEF VAR raw-param  AS RAW.

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
&Scoped-define INTERNAL-TABLES tt-int-ds-cenar-estoq

/* Definitions for BROWSE brSon1                                        */
&Scoped-define FIELDS-IN-QUERY-brSon1 tt-int-ds-cenar-estoq.marca tt-int-ds-cenar-estoq.cod-estabel tt-int-ds-cenar-estoq.it-codigo tt-int-ds-cenar-estoq.lote tt-int-ds-cenar-estoq.valor-unit tt-int-ds-cenar-estoq.qtd-loja tt-int-ds-cenar-estoq.qtd-datasul tt-int-ds-cenar-estoq.qtd-diferenca tt-int-ds-cenar-estoq.valor-dif   
&Scoped-define ENABLED-FIELDS-IN-QUERY-brSon1 tt-int-ds-cenar-estoq.marca   
&Scoped-define ENABLED-TABLES-IN-QUERY-brSon1 tt-int-ds-cenar-estoq
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-brSon1 tt-int-ds-cenar-estoq
&Scoped-define SELF-NAME brSon1
&Scoped-define QUERY-STRING-brSon1 FOR EACH tt-int-ds-cenar-estoq NO-LOCK where                                  tt-int-ds-cenar-estoq.situacao = 1                              BY tt-int-ds-cenar-estoq.cod-estabel                              BY tt-int-ds-cenar-estoq.fm-codigo                              BY tt-int-ds-cenar-estoq.ge-codigo                              BY tt-int-ds-cenar-estoq.it-codigo
&Scoped-define OPEN-QUERY-brSon1 OPEN QUERY {&SELF-NAME} FOR EACH tt-int-ds-cenar-estoq NO-LOCK where                                  tt-int-ds-cenar-estoq.situacao = 1                              BY tt-int-ds-cenar-estoq.cod-estabel                              BY tt-int-ds-cenar-estoq.fm-codigo                              BY tt-int-ds-cenar-estoq.ge-codigo                              BY tt-int-ds-cenar-estoq.it-codigo.
&Scoped-define TABLES-IN-QUERY-brSon1 tt-int-ds-cenar-estoq
&Scoped-define FIRST-TABLE-IN-QUERY-brSon1 tt-int-ds-cenar-estoq


/* Definitions for FRAME fPage1                                         */

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS tt-int-ds-cenario.cod-cenario ~
tt-int-ds-cenario.descricao 
&Scoped-define ENABLED-TABLES tt-int-ds-cenario
&Scoped-define FIRST-ENABLED-TABLE tt-int-ds-cenario
&Scoped-Define ENABLED-OBJECTS rtToolBar btFirst rtParent btPrev RECT-1 ~
btNext IMAGE-11 btLast IMAGE-12 btGoTo btSearch btAdd btUpdate btDelete ~
btQueryJoins btReportsJoins btExit btHelp cb-relat c-cod-estab-ini ~
c-cod-estab-fin btcheck 
&Scoped-Define DISPLAYED-FIELDS tt-int-ds-cenario.cod-cenario ~
tt-int-ds-cenario.descricao 
&Scoped-define DISPLAYED-TABLES tt-int-ds-cenario
&Scoped-define FIRST-DISPLAYED-TABLE tt-int-ds-cenario
&Scoped-Define DISPLAYED-OBJECTS cb-relat c-cod-estab-ini c-cod-estab-fin 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD fn-descEstab wMasterDetail 
FUNCTION fn-descEstab RETURNS CHARACTER
  ( c-cod-estabel AS char)  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD fn-descFam wMasterDetail 
FUNCTION fn-descFam RETURNS CHARACTER
  ( c-fm-codigo AS char)  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD fn-descGrupo wMasterDetail 
FUNCTION fn-descGrupo RETURNS CHARACTER
  ( i-ge-codigo AS integer)  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD fn-Situacao wMasterDetail 
FUNCTION fn-Situacao RETURNS CHARACTER
  ( p-situacao AS INT)  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD fnCliente wMasterDetail 
FUNCTION fnCliente RETURNS CHARACTER
  ( i-emitente AS INTEGER )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD fnContrato wMasterDetail 
FUNCTION fnContrato RETURNS CHARACTER
  ( p-ts AS INTEGER , p-versao AS INTEGER /* parameter-definitions */ )  FORWARD.

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
DEFINE BUTTON btAdd 
     IMAGE-UP FILE "image\im-add":U
     IMAGE-INSENSITIVE FILE "image\ii-add":U
     LABEL "Add" 
     SIZE 4 BY 1.25
     FONT 4.

DEFINE BUTTON btcheck 
     IMAGE-UP FILE "image\im-sav":U
     LABEL "Atualiza‡Æo" 
     SIZE 5.14 BY 1 TOOLTIP "Sa¡da Relat¢rio".

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

DEFINE VARIABLE cb-relat AS CHARACTER FORMAT "X(256)":U 
     LABEL "Visualizar" 
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEM-PAIRS "1- éltima Conferˆncia","1 ",
                     "2- Verificar Diferen‡as","2",
                     "3- Atualizar Diferen‡as","3"
     DROP-DOWN-LIST
     SIZE 19 BY 1 NO-UNDO.

DEFINE VARIABLE c-cod-estab-fin AS CHARACTER FORMAT "X(03)":U INITIAL "999" 
     VIEW-AS FILL-IN 
     SIZE 5 BY .88 NO-UNDO.

DEFINE VARIABLE c-cod-estab-ini AS CHARACTER FORMAT "X(03)":U INITIAL "0" 
     LABEL "Estabel" 
     VIEW-AS FILL-IN 
     SIZE 5 BY .88 NO-UNDO.

DEFINE IMAGE IMAGE-11
     FILENAME "image\im-fir":U
     SIZE 3 BY .88.

DEFINE IMAGE IMAGE-12
     FILENAME "image\im-las":U
     SIZE 3 BY .88.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 54 BY 2.75.

DEFINE RECTANGLE rtParent
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 68.14 BY 2.75.

DEFINE RECTANGLE rtToolBar
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 126 BY 1.5
     BGCOLOR 7 .

DEFINE BUTTON bt-movto 
     LABEL "Atualiza Estoque Datasul" 
     SIZE 19 BY 1.13.

DEFINE VARIABLE tg-todos AS LOGICAL INITIAL no 
     LABEL "" 
     VIEW-AS TOGGLE-BOX
     SIZE 2 BY .83 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY brSon1 FOR 
      tt-int-ds-cenar-estoq SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE brSon1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS brSon1 wMasterDetail _FREEFORM
  QUERY brSon1 NO-LOCK DISPLAY
      tt-int-ds-cenar-estoq.marca COLUMN-LABEL "" VIEW-AS TOGGLE-BOX 
tt-int-ds-cenar-estoq.cod-estabel   COLUMN-LABEL "Estab" WIDTH 5
tt-int-ds-cenar-estoq.it-codigo 
tt-int-ds-cenar-estoq.lote 
tt-int-ds-cenar-estoq.valor-unit
tt-int-ds-cenar-estoq.qtd-loja    COLUMN-LABEL "Qtd Frente Loja" FORMAT "->>>>,>>>,>>9.99"  
tt-int-ds-cenar-estoq.qtd-datasul                                FORMAT "->>>>,>>>,>>9.99"  
tt-int-ds-cenar-estoq.qtd-diferenca                              FORMAT "->>>>,>>>,>>9.99"  
tt-int-ds-cenar-estoq.valor-dif                                  FORMAT "->>>>,>>>,>>9.99"  
ENABLE 
tt-int-ds-cenar-estoq.marca
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 118.86 BY 12
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
     btQueryJoins AT ROW 1.13 COL 109.86 HELP
          "Consultas relacionadas"
     btReportsJoins AT ROW 1.13 COL 113.86 HELP
          "Relat¢rios relacionados"
     btExit AT ROW 1.13 COL 117.86 HELP
          "Sair"
     btHelp AT ROW 1.13 COL 121.86 HELP
          "Ajuda"
     tt-int-ds-cenario.cod-cenario AT ROW 3.17 COL 13 COLON-ALIGNED WIDGET-ID 74
          VIEW-AS FILL-IN 
          SIZE 19 BY .88
     tt-int-ds-cenario.descricao AT ROW 3.17 COL 32.57 COLON-ALIGNED NO-LABEL WIDGET-ID 6
          VIEW-AS FILL-IN 
          SIZE 34.43 BY .88
     cb-relat AT ROW 4.25 COL 13 COLON-ALIGNED WIDGET-ID 76
     c-cod-estab-ini AT ROW 3.33 COL 76.14 WIDGET-ID 82
     c-cod-estab-fin AT ROW 3.25 COL 97.57 COLON-ALIGNED NO-LABEL WIDGET-ID 80
     btcheck AT ROW 4.21 COL 35.14 WIDGET-ID 18
     rtToolBar AT ROW 1 COL 1
     rtParent AT ROW 2.75 COL 1.86
     RECT-1 AT ROW 2.75 COL 71 WIDGET-ID 78
     IMAGE-11 AT ROW 3.29 COL 89.57 WIDGET-ID 84
     IMAGE-12 AT ROW 3.29 COL 95.57 WIDGET-ID 72
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 126 BY 21.08
         FONT 1 WIDGET-ID 100.

DEFINE FRAME fPage1
     tg-todos AT ROW 1.75 COL 3.72 WIDGET-ID 2
     brSon1 AT ROW 1.83 COL 3.14
     bt-movto AT ROW 14.25 COL 3 WIDGET-ID 6
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 2 ROW 6.75
         SIZE 123 BY 15
         FONT 1 WIDGET-ID 100.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: MasterDetail
   Allow: Basic,Browse,DB-Fields,Window,Query
   Add Fields to: Neither
   Other Settings: COMPILE
   Temp-Tables and Buffers:
      TABLE: tt-int-ds-cenar-estoq T "?" NO-UNDO emsesp int-ds-cenar-estoq
      ADDITIONAL-FIELDS:
          fields r-rowid as rowid
          fields marca as logical
      END-FIELDS.
      TABLE: tt-int-ds-cenario T "?" NO-UNDO emsespe int-ds-cenario
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
         HEIGHT             = 21.08
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
   FRAME-NAME Custom                                                    */
/* SETTINGS FOR FILL-IN c-cod-estab-ini IN FRAME fPage0
   ALIGN-L                                                              */
/* SETTINGS FOR FRAME fPage1
                                                                        */
/* BROWSE-TAB brSon1 tg-todos fPage1 */
IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(wMasterDetail)
THEN wMasterDetail:HIDDEN = yes.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE brSon1
/* Query rebuild information for BROWSE brSon1
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH tt-int-ds-cenar-estoq NO-LOCK where
                                 tt-int-ds-cenar-estoq.situacao = 1
                             BY tt-int-ds-cenar-estoq.cod-estabel
                             BY tt-int-ds-cenar-estoq.fm-codigo
                             BY tt-int-ds-cenar-estoq.ge-codigo
                             BY tt-int-ds-cenar-estoq.it-codigo
     _END_FREEFORM
     _Options          = "NO-LOCK"
     _Query            is NOT OPENED
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


&Scoped-define FRAME-NAME fPage1
&Scoped-define SELF-NAME bt-movto
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-movto wMasterDetail
ON CHOOSE OF bt-movto IN FRAME fPage1 /* Atualiza Estoque Datasul */
DO:
  
    EMPTY TEMP-TABLE tt-raw-digita.
    EMPTY TEMP-TABLE tt-param.
    EMPTY TEMP-TABLE tt-digita.

    CREATE tt-param.
    ASSIGN tt-param.destino         = 3                              
           tt-param.arquivo         = SESSION:TEMP-DIRECTORY + "\" + "int009f.txt"       
           tt-param.usuario         = c-seg-usuario       
           tt-param.data-exec       = TODAY  
           tt-param.hora-exec       = TIME 
           tt-param.cod-cenario-ini = INPUT FRAME fpage0 tt-int-ds-cenario.cod-cenario
           tt-param.cod-cenario-fin = INPUT FRAME fpage0 tt-int-ds-cenario.cod-cenario
           tt-param.tipo-relat      = 4
           tt-param.arq-modelo      = SEARCH("modelo/int009f-modelo.xls").
   
    raw-transfer tt-param  to raw-param.
    
    FOR EACH tt-int-ds-cenar-estoq WHERE
             tt-int-ds-cenar-estoq.marca    = YES AND 
             tt-int-ds-cenar-estoq.situacao = 1:

        CREATE tt-digita.
        BUFFER-COPY tt-int-ds-cenar-estoq TO tt-digita.
        ASSIGN tt-digita.r-rowid  = tt-int-ds-cenar-estoq.r-rowid.
               
    END.
     
    for each tt-digita:
         create tt-raw-digita.
         raw-transfer tt-digita to tt-raw-digita.raw-digita.
    end.

    run intprg/int009frp.p (input raw-param, 
                            input table tt-raw-digita).
    
    RUN openqueriesSon.
    

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME fPage0
&Scoped-define SELF-NAME btAdd
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btAdd wMasterDetail
ON CHOOSE OF btAdd IN FRAME fPage0 /* Add */
OR CHOOSE OF MENU-ITEM miAdd IN MENU mbMain DO:
    RUN addRecord IN THIS-PROCEDURE (INPUT "intprg\int009a.w":U). 
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btcheck
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btcheck wMasterDetail
ON CHOOSE OF btcheck IN FRAME fPage0 /* Atualiza‡Æo */
DO:
   
    EMPTY TEMP-TABLE tt-raw-digita.
    EMPTY TEMP-TABLE tt-param.

    CREATE tt-param.
    ASSIGN tt-param.destino         = 3                              
           tt-param.arquivo         = SESSION:TEMP-DIRECTORY + "\" + "int009f.txt"       
           tt-param.usuario         = c-seg-usuario       
           tt-param.data-exec       = TODAY  
           tt-param.hora-exec       = TIME 
           tt-param.cod-cenario-ini = INPUT FRAME fpage0 tt-int-ds-cenario.cod-cenario
           tt-param.cod-cenario-fin = INPUT FRAME fpage0 tt-int-ds-cenario.cod-cenario
           tt-param.cod-estab-ini   = INPUT FRAME fpage0 c-cod-estab-ini
           tt-param.cod-estab-fin   = INPUT FRAME fpage0 c-cod-estab-fin
           tt-param.tipo-relat      = INT(cb-relat:SCREEN-VALUE IN FRAME fpage0)
           tt-param.arq-modelo      = SEARCH("modelo/int009f-modelo.xls").
   
     raw-transfer tt-param  to raw-param.
    
    run intprg/int009frp.p (input raw-param, 
                            input table tt-raw-digita).

    {include/i-rptrm.i}

                                 
    IF tt-param.tipo-relat <> 2 
    THEN DO:
          
        RUN openQueriesSon IN THIS-PROCEDURE.

    END.
  
END.

PROCEDURE WinExec EXTERNAL "kernel32.dll":U:
  DEF INPUT  PARAM prg_name                          AS CHARACTER.
  DEF INPUT  PARAM prg_style                         AS SHORT.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btDelete
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btDelete wMasterDetail
ON CHOOSE OF btDelete IN FRAME fPage0 /* Delete */
OR CHOOSE OF MENU-ITEM miDelete IN MENU mbMain DO:
    RUN deleteRecord IN THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


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
    {method/zoomreposition.i &ProgramZoom="intprg\int009zoom.w"}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btUpdate
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btUpdate wMasterDetail
ON CHOOSE OF btUpdate IN FRAME fPage0 /* Update */
OR CHOOSE OF MENU-ITEM miUpdate IN MENU mbMain DO:
    RUN updateRecord IN THIS-PROCEDURE (INPUT "intprg\int009a.w":U).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME fPage1
&Scoped-define SELF-NAME tg-todos
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tg-todos wMasterDetail
ON VALUE-CHANGED OF tg-todos IN FRAME fPage1
DO:

  FOR EACH b-tt-int-ds-cenar-estoq:

      ASSIGN b-tt-int-ds-cenar-estoq.marca = tg-todos:CHECKED.

  END.

  {&OPEN-QUERY-brSon1}

  /* RUN openQueriesSon. */
          
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME fPage0
&Scoped-define BROWSE-NAME brSon1
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
  
    IF AVAIL tt-int-ds-cenario THEN DO:
     
    END.

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
   
    ASSIGN cb-relat:SENSITIVE IN FRAME fpage0           = YES
           cb-relat:SCREEN-VALUE IN FRAME fpage0        = "1" 
           c-cod-estab-ini:SENSITIVE IN FRAME fpage0    = YES
           c-cod-estab-ini:SCREEN-VALUE IN FRAME fpage0 = ""
           c-cod-estab-fin:SENSITIVE IN FRAME fpage0    = YES
           c-cod-estab-fin:SCREEN-VALUE IN FRAME fpage0 = "ZZZ"
           btcheck:SENSITIVE IN FRAME fpage0            = YES 
           bt-movto:SENSITIVE IN FRAME fpage1           = YES 
           tg-todos:SENSITIVE IN FRAME fpage1           = YES.

    tg-todos:MOVE-TO-TOP().

    RETURN "Ok".

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
    
    DEFINE VARIABLE c-cod-cenario LIKE {&ttParent}.cod-cenario NO-UNDO.

    DEFINE FRAME fGoToRecord
        c-cod-cenario AT ROW 1.7 COL 17.72 COLON-ALIGNED
        btGoToOK       AT ROW 3.63 COL 2.14
        btGoToCancel   AT ROW 3.63 COL 13
        rtGoToButton   AT ROW 3.38 COL 1
        SPACE(0.28)
        WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER SIDE-LABELS NO-UNDERLINE 
             THREE-D SCROLLABLE TITLE "V  Para Cen rio" FONT 1
             DEFAULT-BUTTON btGoToOK CANCEL-BUTTON btGoToCancel.

/*tech1139 - FO 1338.917 - 10/07/2006  */
    RUN utp/ut-trfrrp.p (input Frame fGoToRecord:Handle).
    {utp/ut-liter.i "V _Para_Cen rio"}
    ASSIGN FRAME fGoToRecord:TITLE = RETURN-VALUE.
/*tech1139 - FO 1338.917 - 10/07/2006  */
                                         
    ON "CHOOSE":U OF btGoToOK IN FRAME fGoToRecord DO:
        ASSIGN c-cod-cenario.

      /*:T Posiciona query, do DBO, atrav‚s dos valores do ¡ndice £nico */
        RUN goToKey IN {&hDBOParent} (INPUT c-cod-cenario). 
                                               
        IF RETURN-VALUE = "NOK":U THEN DO:
            RUN utp/ut-msgs.p (INPUT "SHOW":U, INPUT 2, INPUT "Cen rio":U).
            
            RETURN NO-APPLY.
        END.
        
        /*:T Retorna rowid do registro corrente do DBO */
        RUN getRowid IN {&hDBOParent} (OUTPUT rGoTo).
        
        /*:T Reposiciona registro com base em um rowid */
        RUN repositionRecord IN THIS-PROCEDURE (INPUT rGoTo).
        
        APPLY "GO":U TO FRAME fGoToRecord.
    END.
    
    ENABLE c-cod-cenario btGoToOK btGoToCancel 
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
        {btb/btb008za.i1 intprg\intbo009a.p YES}
        {btb/btb008za.i2 intprg\intbo009a.p '' {&hDBOParent}} 
    END.
    
    RUN openQueryStatic IN {&hDBOParent} (INPUT "Main":U) NO-ERROR.
    
    /*:T--- Verifica se o DBO j  est  inicializado ---*/
    IF NOT VALID-HANDLE({&hDBOSon1}) THEN DO:
        {btb/btb008za.i1 intprg\intbo009f.p YES}
        {btb/btb008za.i2 intprg\intbo009f.p '' {&hDBOSon1}} 
    END.
    
    RUN LinktoCenario   IN {&hDBOSon1} (INPUT {&hDBOParent}) NO-ERROR.
    RUN openQueryStatic IN {&hDBOSon1} (INPUT "Cenario":U) NO-ERROR.
    
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
    
    {masterdetail/openqueriesson.i &Parent="Cenario"
                                   &Query="Cenario"
                                   &PageNumber="1"}
    
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

    IF AVAIL tt-int-ds-cenario THEN
        RUN repositionRecord IN THIS-PROCEDURE (INPUT tt-int-ds-cenario.r-rowid).

    RETURN "ok".

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION fn-descEstab wMasterDetail 
FUNCTION fn-descEstab RETURNS CHARACTER
  ( c-cod-estabel AS char) :
/*------------------------------------------------------------------------------
  Purpose:  
    Notes:  
------------------------------------------------------------------------------*/
DEF VAR c-desc-estab AS CHAR.

 FIND FIRST estabelec NO-LOCK WHERE
            estabelec.cod-estabel = c-cod-estabel NO-ERROR.
 IF AVAIL estabelec THEN
    ASSIGN c-desc-estab = estabelec.nome.
 ELSE 
    ASSIGN c-desc-estab = "". 
                    
  RETURN c-desc-estab.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION fn-descFam wMasterDetail 
FUNCTION fn-descFam RETURNS CHARACTER
  ( c-fm-codigo AS char) :
/*------------------------------------------------------------------------------
  Purpose:  
    Notes:  
------------------------------------------------------------------------------*/
DEF VAR c-desc-fam AS CHAR.

 FIND FIRST familia NO-LOCK WHERE
            familia.fm-codigo = c-fm-codigo NO-ERROR.
 IF AVAIL familia THEN
    ASSIGN c-desc-fam = familia.descricao.
 ELSE 
    ASSIGN c-desc-fam = "". 
                    
  RETURN c-desc-fam.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION fn-descGrupo wMasterDetail 
FUNCTION fn-descGrupo RETURNS CHARACTER
  ( i-ge-codigo AS integer) :
/*------------------------------------------------------------------------------
  Purpose:  
    Notes:  
------------------------------------------------------------------------------*/
DEF VAR c-desc-grupo AS CHAR.

 FIND FIRST grup-estoq NO-LOCK WHERE
            grup-estoq.ge-codigo = i-ge-codigo NO-ERROR.
 IF AVAIL grup-estoq THEN
    ASSIGN c-desc-grupo = grup-estoq.descricao.
 ELSE 
    ASSIGN c-desc-grupo = "". 
                    
  RETURN c-desc-grupo.   /* Function return value. */

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


END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION fnCliente wMasterDetail 
FUNCTION fnCliente RETURNS CHARACTER
  ( i-emitente AS INTEGER ) :
/*------------------------------------------------------------------------------
  Purpose:  
    Notes:  
------------------------------------------------------------------------------*/

  FIND FIRST emitente NO-LOCK
       WHERE emitente.cod-emitente = i-emitente NO-ERROR.
  IF AVAIL emitente THEN
      RETURN emitente.nome-abrev.
  ELSE 
      RETURN "".

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION fnContrato wMasterDetail 
FUNCTION fnContrato RETURNS CHARACTER
  ( p-ts AS INTEGER , p-versao AS INTEGER /* parameter-definitions */ ) :
/*------------------------------------------------------------------------------
  Purpose:  
    Notes:  
------------------------------------------------------------------------------*/
 RETURN "".
   
  
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

