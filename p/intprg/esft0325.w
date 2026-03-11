&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
*/
&Scoped-define WINDOW-NAME wMasterDetail


/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE tt-esp-item-entr-st NO-UNDO LIKE esp-item-entr-st
       field r-rowid as rowid.
DEFINE TEMP-TABLE tt-esp-item-nfs-st NO-UNDO LIKE esp-item-nfs-st
       field r-rowid as rowid.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS wMasterDetail 
/********************************************************************************
** Copyright DATASUL S.A. (1997)
** Todos os Direitos Reservados.
**
** Este fonte e de propriedade exclusiva da DATASUL, sua reproducao
** parcial ou total por qualquer meio, so podera ser feita mediante
** autorizacao expressa.
*******************************************************************************/
{include/i-prgvrs.i ESFT0325 2.00.00.012 } /*** "010012" ***/

&IF "{&EMSFND_VERSION}" >= "1.00" &THEN
{include/i-license-manager.i esft0325 MFT}
&ENDIF


/*:T*******************************************************************************
** Copyright DATASUL S.A. (1999)
** Todos os Direitos Reservados.
**
** Este fonte e de propriedade exclusiva da DATASUL, sua reproducao
** parcial ou total por qualquer meio, so podera ser feita mediante
** autorizacao expressa.
*******************************************************************************/

CREATE WIDGET-POOL.

/* Preprocessors Definitions ---                                      */
&GLOBAL-DEFINE Program          ESFT0325
&GLOBAL-DEFINE Version        2.00.00.011

&GLOBAL-DEFINE Folder           YES
&GLOBAL-DEFINE InitialPage      1
&GLOBAL-DEFINE FolderLabels     Sa¡das

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

&GLOBAL-DEFINE ttParent         tt-esp-item-entr-st
&GLOBAL-DEFINE hDBOParent       h-boEspItemEntrSt
&GLOBAL-DEFINE DBOParentTable   esp-item-entr-st
&GLOBAL-DEFINE DBOParentDestroy YES

&GLOBAL-DEFINE ttSon1           tt-esp-item-nfs-st
&GLOBAL-DEFINE hDBOSon1         h-boEspItemNfsSt
&GLOBAL-DEFINE DBOSon1Table     esp-item-nfs-st
&GLOBAL-DEFINE DBOSon1Destroy   YES

&GLOBAL-DEFINE page0Fields      tt-esp-item-entr-st.cod-estab tt-esp-item-entr-st.cod-docto ~
                                tt-esp-item-entr-st.cod-emitente tt-esp-item-entr-st.cod-item ~
                                tt-esp-item-entr-st.cod-natur-operac tt-esp-item-entr-st.cod-serie ~
                                tt-esp-item-entr-st.num-seq tt-esp-item-entr-st.dat-movto

&GLOBAL-DEFINE page1Fields      de-saldo

&GLOBAL-DEFINE page1Browse      brSon1

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */
DEFINE VARIABLE da-dat-movto                   AS DATE                     NO-UNDO.
DEFINE VARIABLE de-val-movto                   AS DECIMAL                  NO-UNDO.
DEFINE VARIABLE de-val-fcp                     AS DECIMAL                  NO-UNDO.
DEFINE VARIABLE de-val-icms-proprio-substituto AS DECIMAL                  NO-UNDO.
DEFINE VARIABLE cod-tipo-consumo             AS CHARACTER FORMAT "X(19)" NO-UNDO.

/* Local Variable Definitions (DBOs Handles) ---                        */
DEFINE VARIABLE {&hDBOParent} AS HANDLE  NO-UNDO.
DEFINE VARIABLE {&hDBOSon1}   AS HANDLE  NO-UNDO.

DEFINE VARIABLE h-boad098na   AS HANDLE  NO-UNDO.
DEFINE VARIABLE h-boin172     AS HANDLE  NO-UNDO.
DEFINE VARIABLE h-boin245     AS HANDLE  NO-UNDO.
DEFINE VARIABLE h-boad107na   AS HANDLE  NO-UNDO.

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
&Scoped-define INTERNAL-TABLES tt-esp-item-nfs-st

/* Definitions for BROWSE brSon1                                        */
&Scoped-define FIELDS-IN-QUERY-brSon1 fnDataMovto() @ da-dat-movto ~
tt-esp-item-nfs-st.cod-estab-nfs tt-esp-item-nfs-st.cod-ser-nfs ~
tt-esp-item-nfs-st.cod-docto-nfs tt-esp-item-nfs-st.cod-item ~
tt-esp-item-nfs-st.num-seq-nfs 
&Scoped-define ENABLED-FIELDS-IN-QUERY-brSon1 
&Scoped-define QUERY-STRING-brSon1 FOR EACH tt-esp-item-nfs-st NO-LOCK
&Scoped-define OPEN-QUERY-brSon1 OPEN QUERY brSon1 FOR EACH tt-esp-item-nfs-st NO-LOCK.
&Scoped-define TABLES-IN-QUERY-brSon1 tt-esp-item-nfs-st
&Scoped-define FIRST-TABLE-IN-QUERY-brSon1 tt-esp-item-nfs-st


/* Definitions for FRAME fPage1                                         */
&Scoped-define OPEN-BROWSERS-IN-QUERY-fPage1 ~
    ~{&OPEN-QUERY-brSon1}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS tt-esp-item-entr-st.cod-estab ~
tt-esp-item-entr-st.cod-docto tt-esp-item-entr-st.cod-emitente ~
tt-esp-item-entr-st.cod-serie tt-esp-item-entr-st.cod-natur-operac ~
tt-esp-item-entr-st.cod-item tt-esp-item-entr-st.num-seq ~
tt-esp-item-entr-st.dat-movto
&Scoped-define ENABLED-TABLES tt-esp-item-entr-st
&Scoped-define FIRST-ENABLED-TABLE tt-esp-item-entr-st
&Scoped-Define ENABLED-OBJECTS rtToolBar rtParent btFirst btPrev btNext ~
btLast btGoTo btSearch btAdd btCopy btUpdate btDelete btQueryJoins ~
btReportsJoins btExit btHelp c-desc-estab c-desc-fornec c-desc-nat ~
c-desc-item 
&Scoped-Define DISPLAYED-FIELDS tt-esp-item-entr-st.cod-estab ~
tt-esp-item-entr-st.cod-docto tt-esp-item-entr-st.cod-emitente ~
tt-esp-item-entr-st.cod-serie tt-esp-item-entr-st.cod-natur-operac ~
tt-esp-item-entr-st.cod-item tt-esp-item-entr-st.num-seq ~
tt-esp-item-entr-st.dat-movto
&Scoped-define DISPLAYED-TABLES tt-esp-item-entr-st
&Scoped-define FIRST-DISPLAYED-TABLE tt-esp-item-entr-st
&Scoped-Define DISPLAYED-OBJECTS c-desc-estab c-desc-fornec c-desc-nat ~
c-desc-item 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD fnDataMovto wMasterDetail 
FUNCTION fnDataMovto RETURNS DATE
  ( /* parameter-definitions */ )  FORWARD.

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

DEFINE BUTTON btCopy 
     IMAGE-UP FILE "image\im-copy":U
     IMAGE-INSENSITIVE FILE "image\ii-copy":U
     LABEL "Copy" 
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

DEFINE VARIABLE c-desc-estab AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 37.29 BY .88 NO-UNDO.

DEFINE VARIABLE c-desc-fornec AS CHARACTER FORMAT "X(12)":U 
     VIEW-AS FILL-IN 
     SIZE 14 BY .88 NO-UNDO.

DEFINE VARIABLE c-desc-item AS CHARACTER FORMAT "X(60)":U 
     VIEW-AS FILL-IN 
     SIZE 37.29 BY .88 NO-UNDO.

DEFINE VARIABLE c-desc-nat AS CHARACTER FORMAT "X(35)":U 
     VIEW-AS FILL-IN 
     SIZE 37 BY .88 NO-UNDO.

DEFINE RECTANGLE rtParent
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 90 BY 4.25.

DEFINE RECTANGLE rtToolBar
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 90 BY 1.5
     BGCOLOR 7 .

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

DEFINE VARIABLE de-saldo AS DECIMAL FORMAT "->>>,>>>,>>9.9999" INITIAL 0 
     LABEL "Qtde Saldo Final" 
     VIEW-AS FILL-IN 
     SIZE 18 BY .88 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY brSon1 FOR 
      tt-esp-item-nfs-st SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE brSon1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS brSon1 wMasterDetail _STRUCTURED
  QUERY brSon1 NO-LOCK DISPLAY
      tt-esp-item-nfs-st.cod-estab-nfs COLUMN-LABEL "Estab" FORMAT "x(3)":U
            WIDTH 5.43
      tt-esp-item-nfs-st.cod-ser-nfs COLUMN-LABEL "Serie" FORMAT "x(5)":U
            WIDTH 5.43
      tt-esp-item-nfs-st.cod-docto-nfs COLUMN-LABEL "Nota Fiscal" FORMAT "x(16)":U
            WIDTH 14.43
      fnDataMovto() @ da-dat-movto COLUMN-LABEL "Data Emis" FORMAT "99/99/9999":U
            WIDTH 9.43
      tt-esp-item-nfs-st.cod-item COLUMN-LABEL "Cod Item" FORMAT "x(16)":U
            WIDTH 10.43
      tt-esp-item-nfs-st.num-seq-nfs COLUMN-LABEL "Seq" FORMAT ">>>>,>>9":U
            WIDTH 4.43
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 82 BY 9.13
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
     btCopy AT ROW 1.13 COL 35 HELP
          "Cria uma c¢pia da ocorrˆncia corrente"
     btUpdate AT ROW 1.13 COL 39 HELP
          "Altera ocorrˆncia corrente"
     btDelete AT ROW 1.13 COL 43 HELP
          "Elimina ocorrˆncia corrente"
     btQueryJoins AT ROW 1.13 COL 74.86 HELP
          "Consultas relacionadas"
     btReportsJoins AT ROW 1.13 COL 78.86 HELP
          "Relat¢rios relacionados"
     btExit AT ROW 1.13 COL 82.86 HELP
          "Sair"
     btHelp AT ROW 1.13 COL 86.86 HELP
          "Ajuda"
     tt-esp-item-entr-st.cod-estab AT ROW 2.83 COL 10.43 COLON-ALIGNED
          LABEL "Estabelec"
          VIEW-AS FILL-IN 
          SIZE 7 BY .88
     c-desc-estab AT ROW 2.83 COL 17.72 COLON-ALIGNED NO-LABEL
     tt-esp-item-entr-st.cod-docto AT ROW 2.83 COL 70.29 COLON-ALIGNED
          LABEL "Documento"
          VIEW-AS FILL-IN 
          SIZE 18 BY .88
     tt-esp-item-entr-st.cod-emitente AT ROW 3.83 COL 10.43 COLON-ALIGNED
          VIEW-AS FILL-IN 
          SIZE 14 BY .88
     c-desc-fornec AT ROW 3.83 COL 24.72 COLON-ALIGNED NO-LABEL
     tt-esp-item-entr-st.cod-serie AT ROW 3.83 COL 70.29 COLON-ALIGNED
          VIEW-AS FILL-IN 
          SIZE 7 BY .88
     tt-esp-item-entr-st.cod-natur-operac AT ROW 4.83 COL 10.43 COLON-ALIGNED
          LABEL "Nat Opera‡Æo"
          VIEW-AS FILL-IN 
          SIZE 8 BY .88
     c-desc-nat AT ROW 4.83 COL 18.72 COLON-ALIGNED NO-LABEL
     tt-esp-item-entr-st.dat-movto AT ROW 4.83 COL 70.29 COLON-ALIGNED
          LABEL "Data Movto"
          VIEW-AS FILL-IN
          SIZE 11 BY .88
     tt-esp-item-entr-st.cod-item AT ROW 5.83 COL 10.43 COLON-ALIGNED
          VIEW-AS FILL-IN 
          SIZE 18 BY .88
     c-desc-item AT ROW 5.83 COL 28.72 COLON-ALIGNED NO-LABEL
     tt-esp-item-entr-st.num-seq AT ROW 5.83 COL 70.29 COLON-ALIGNED
          LABEL "Seq"
          VIEW-AS FILL-IN 
          SIZE 8 BY .88
     rtToolBar AT ROW 1 COL 1
     rtParent AT ROW 2.67 COL 1
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 90 BY 18.75
         FONT 1.

DEFINE FRAME fPage1
     brSon1 AT ROW 1.17 COL 2
     btAddSon1 AT ROW 10.33 COL 2
     btCopySon1 AT ROW 10.33 COL 12
     btUpdateSon1 AT ROW 10.33 COL 22
     btDeleteSon1 AT ROW 10.33 COL 32
     de-saldo AT ROW 10.5 COL 64 COLON-ALIGNED
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 3.5 ROW 8.38
         SIZE 84.43 BY 10.63
         FONT 1.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: MasterDetail
   Allow: Basic,Browse,DB-Fields,Window,Query
   Add Fields to: Neither
   Temp-Tables and Buffers:
      TABLE: tt-esp-item-entr-st T "?" NO-UNDO st esp-item-entr-st
      ADDITIONAL-FIELDS:
          field r-rowid as rowid
      END-FIELDS.
      TABLE: tt-esp-item-nfs-st T "?" NO-UNDO st esp-item-nfs-st
      ADDITIONAL-FIELDS:
          field r-rowid as rowid
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
         HEIGHT             = 18.75
         WIDTH              = 90
         MAX-HEIGHT         = 18.75
         MAX-WIDTH          = 90
         VIRTUAL-HEIGHT     = 18.75
         VIRTUAL-WIDTH      = 90
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
/* SETTINGS FOR FILL-IN tt-esp-item-entr-st.cod-docto IN FRAME fPage0
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-esp-item-entr-st.cod-estab IN FRAME fPage0
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-esp-item-entr-st.cod-natur-operac IN FRAME fPage0
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-esp-item-entr-st.num-seq IN FRAME fPage0
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
     _TblList          = "Temp-Tables.tt-esp-item-nfs-st"
     _Options          = "NO-LOCK"
     _FldNameList[1]   > "_<CALC>"
"fnDataMovto() @ da-dat-movto" "Data Emis" "99/99/9999" ? ? ? ? ? ? ? no ? no no "9.43" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[2]   > Temp-Tables.tt-esp-item-nfs-st.cod-estab-nfs
"tt-esp-item-nfs-st.cod-estab-nfs" "Estab" ? "character" ? ? ? ? ? ? no ? no no "5.43" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[3]   > Temp-Tables.tt-esp-item-nfs-st.cod-ser-nfs
"tt-esp-item-nfs-st.cod-ser-nfs" "Serie" ? "character" ? ? ? ? ? ? no ? no no "5.43" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[4]   > Temp-Tables.tt-esp-item-nfs-st.cod-docto-nfs
"tt-esp-item-nfs-st.cod-docto-nfs" "Nota Fiscal" ? "character" ? ? ? ? ? ? no ? no no "14.43" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[5]   > Temp-Tables.tt-esp-item-nfs-st.cod-item
"tt-esp-item-nfs-st.cod-item" "Cod Item" ? "character" ? ? ? ? ? ? no ? no no "10.43" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[6]   > Temp-Tables.tt-esp-item-nfs-st.num-seq-nfs
"tt-esp-item-nfs-st.num-seq-nfs" "Seq" ? "integer" ? ? ? ? ? ? no ? no no "4.43" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
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


&Scoped-define SELF-NAME btAdd
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btAdd wMasterDetail
ON CHOOSE OF btAdd IN FRAME fPage0 /* Add */
OR CHOOSE OF MENU-ITEM miAdd IN MENU mbMain DO:
    RUN addRecord IN THIS-PROCEDURE (INPUT "intprg/esft0325a.w":U).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME fPage0
&Scoped-define SELF-NAME btCopy
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btCopy wMasterDetail
ON CHOOSE OF btCopy IN FRAME fPage0 /* Copy */
OR CHOOSE OF MENU-ITEM miCopy IN MENU mbMain DO:
    RUN copyRecord (INPUT "intprg/esft0325a.w":U).
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
    {method/zoomreposition.i &ProgramZoom="intprg/esft0325z.w"}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btUpdate
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btUpdate wMasterDetail
ON CHOOSE OF btUpdate IN FRAME fPage0 /* Update */
OR CHOOSE OF MENU-ITEM miUpdate IN MENU mbMain DO:
    RUN updateRecord IN THIS-PROCEDURE (INPUT "intprg/esft0325a.w":U).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME fPage1
&Scoped-define SELF-NAME btUpdateSon1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btUpdateSon1 wMasterDetail
ON CHOOSE OF btUpdateSon1 IN FRAME fPage1 /* Alterar */
DO:
  /*  {masterdetail/updateson.i &ProgramSon="<ProgramName>"
                              &PageNumber="1"}*/
                              
    RUN setParametersSon IN THIS-PROCEDURE (INPUT 3). /* Alterar */

    RETURN "OK":U.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME fPage0
&Scoped-define SELF-NAME tt-esp-item-entr-st.cod-emitente
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-esp-item-entr-st.cod-emitente wMasterDetail
ON LEAVE OF tt-esp-item-entr-st.cod-emitente IN FRAME fPage0 /* Fornecedor */
DO:
    {METHOD/ReferenceFields.i   &HandleDBOLeave="h-boad098na"
                                &KeyValue1="{&ttParent}.cod-emitente:screen-value in frame fPage0"
                                &FieldName1="nome-abrev"
                                &FieldScreen1="c-desc-fornec"
                                &Frame1="fPage0"}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-esp-item-entr-st.cod-estab
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-esp-item-entr-st.cod-estab wMasterDetail
ON LEAVE OF tt-esp-item-entr-st.cod-estab IN FRAME fPage0 /* Estabelec */
DO:
    {METHOD/ReferenceFields.i   &HandleDBOLeave="h-boad107na"
                                &KeyValue1="{&ttParent}.cod-estab:screen-value in frame fPage0"
                                &FieldName1="nome"
                                &FieldScreen1="c-desc-estab"
                                &Frame1="fPage0"}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-esp-item-entr-st.cod-item
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-esp-item-entr-st.cod-item wMasterDetail
ON LEAVE OF tt-esp-item-entr-st.cod-item IN FRAME fPage0 /* Item */
DO:
    {METHOD/ReferenceFields.i   &HandleDBOLeave="h-boin172"
                                &KeyValue1="{&ttParent}.cod-item:screen-value in frame fPage0"
                                &FieldName1="desc-item"
                                &FieldScreen1="c-desc-item"
                                &Frame1="fPage0"}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-esp-item-entr-st.cod-natur-operac
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-esp-item-entr-st.cod-natur-operac wMasterDetail
ON LEAVE OF tt-esp-item-entr-st.cod-natur-operac IN FRAME fPage0 /* Nat Opera‡Æo */
DO:
    {METHOD/ReferenceFields.i   &HandleDBOLeave="h-boin245"
                                &KeyValue1="{&ttParent}.cod-natur-operac:screen-value in frame fPage0"
                                &FieldName1="denominacao"
                                &FieldScreen1="c-desc-nat"
                                &Frame1="fPage0"}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME brSon1
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK wMasterDetail 


/*:T--- L¢gica para inicializa‡Æo do programam ---*/
{masterdetail/mainblock.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE afterDestroyInterface wMasterDetail 
PROCEDURE afterDestroyInterface :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    
    IF VALID-HANDLE(h-boad098na) THEN DO:
        DELETE PROCEDURE h-boad098na.
        ASSIGN h-boad098na = ?.
    END.

    IF VALID-HANDLE(h-boad107na) THEN DO:
        DELETE PROCEDURE h-boad107na.
        ASSIGN h-boad107na = ?.
    END.

    IF VALID-HANDLE(h-boin172) THEN DO:
        DELETE PROCEDURE h-boin172.
        ASSIGN h-boin172 = ?.
    END.

    IF VALID-HANDLE(h-boin245) THEN DO:
        DELETE PROCEDURE h-boin245.
        ASSIGN h-boin245 = ?.
    END.

    RETURN "OK":U.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE afterDisplayFields wMasterDetail 
PROCEDURE afterDisplayFields :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    APPLY "LEAVE":U TO {&ttParent}.cod-estab        IN FRAME fPage0.
    APPLY "LEAVE":U TO {&ttParent}.cod-emitente     IN FRAME fPage0.
    APPLY "LEAVE":U TO {&ttParent}.cod-natur-operac IN FRAME fPage0.
    APPLY "LEAVE":U TO {&ttParent}.cod-item         IN FRAME fPage0.

    ASSIGN btCopySon1:SENSITIVE IN FRAME fPage1 = NO.

    RETURN "OK":U.
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

    ASSIGN  btAddSon1:HELP       IN FRAME fPage1 = "Inserir Itens de Notas Fiscais de Sa¡da"
            btCopySon1:SENSITIVE IN FRAME fPage1 = NO
            btUpdateSon1:HELP    IN FRAME fPage1 = "Modificar Itens de Notas Fiscais de Sa¡da"
            btDeleteSon1:HELP    IN FRAME fPage1 = "Eliminar Itens de Notas Fiscais de Sa¡da"
            de-saldo:SENSITIVE   IN FRAME fPage1 = NO.

    RUN atualizaSaldoFim.

    RETURN "OK":U.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE atualizaSaldoFim wMasterDetail 
PROCEDURE atualizaSaldoFim :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    DEFINE VARIABLE p-sdo-fim AS DECIMAL NO-UNDO.

    IF AVAIL({&ttParent}) THEN DO:
        ASSIGN p-sdo-fim = {&ttParent}.qtd-sdo-orig.
        
        RUN calculaSaldoFim IN h-boEspItemNfsSt (INPUT-OUTPUT p-sdo-fim, INPUT h-boEspItemEntrSt).
        
        ASSIGN de-saldo:SCREEN-VALUE IN FRAME fPage1 = STRING(p-sdo-fim).
    END.



    RETURN "OK":U.
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
    
    DEFINE VARIABLE c-cod-estab LIKE {&ttParent}.cod-estab          VIEW-AS FILL-IN SIZE 7  BY .88  NO-UNDO.
    DEFINE VARIABLE c-cod-emit  LIKE {&ttParent}.cod-emitente       VIEW-AS FILL-IN SIZE 14 BY .88  NO-UNDO.
    DEFINE VARIABLE c-nat-oper  LIKE {&ttParent}.cod-natur-operac   VIEW-AS FILL-IN SIZE 8  BY .88  NO-UNDO.
    DEFINE VARIABLE c-cod-item  LIKE {&ttParent}.cod-item           VIEW-AS FILL-IN SIZE 18 BY .88  NO-UNDO.
    DEFINE VARIABLE c-cod-docto LIKE {&ttParent}.cod-docto          VIEW-AS FILL-IN SIZE 18 BY .88  NO-UNDO.
    DEFINE VARIABLE c-cod-serie LIKE {&ttParent}.cod-serie          VIEW-AS FILL-IN SIZE 7  BY .88  NO-UNDO.
    DEFINE VARIABLE i-num-seq   LIKE {&ttParent}.num-seq            VIEW-AS FILL-IN SIZE 8  BY .88  NO-UNDO.
    
    DEFINE FRAME fGoToRecord
        c-cod-estab AT ROW 1.21 COL 17.72 COLON-ALIGNED
        c-cod-serie AT ROW 2.21 COL 17.72 COLON-ALIGNED
        c-cod-docto AT ROW 3.21 COL 17.72 COLON-ALIGNED
        c-nat-oper  AT ROW 4.21 COL 17.72 COLON-ALIGNED
        c-cod-emit  AT ROW 5.21 COL 17.72 COLON-ALIGNED
        c-cod-item  AT ROW 6.21 COL 17.72 COLON-ALIGNED
        i-num-seq   AT ROW 7.21 COL 17.72 COLON-ALIGNED
        btGoToOK          AT ROW 8.63 COL 2.14
        btGoToCancel      AT ROW 8.63 COL 13
        rtGoToButton      AT ROW 8.38 COL 1
        SPACE(0.28)
        WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER SIDE-LABELS NO-UNDERLINE 
             THREE-D SCROLLABLE TITLE "V  Para Item Doc Entrada" FONT 1
             DEFAULT-BUTTON btGoToOK CANCEL-BUTTON btGoToCancel.
    
/*tech1139 - FO 1338.917 - 10/07/2006  */
    RUN utp/ut-trfrrp.p (input Frame fGoToRecord:Handle).
    {utp/ut-liter.i "V _Para_Item_Doc_Entrada"}
    ASSIGN FRAME fGoToRecord:TITLE = RETURN-VALUE.
/*tech1139 - FO 1338.917 - 10/07/2006  */
                                         
    ON "CHOOSE":U OF btGoToOK IN FRAME fGoToRecord DO:
        ASSIGN c-cod-estab c-cod-emit c-nat-oper c-cod-item c-cod-docto c-cod-serie i-num-seq.
        
        /*:T Posiciona query, do DBO, atrav‚s dos valores do ¡ndice £nico */
        RUN goToKey IN {&hDBOParent} (INPUT c-cod-estab,
                                      INPUT c-cod-serie,
                                      INPUT c-cod-docto,
                                      INPUT c-nat-oper,
                                      INPUT c-cod-emit,
                                      INPUT c-cod-item,
                                      INPUT i-num-seq).
        IF RETURN-VALUE = "NOK":U THEN DO:
            RUN utp/ut-msgs.p (INPUT "SHOW":U, INPUT 2, INPUT "esp-item-entr-st":U).
            
            RETURN NO-APPLY.
        END.
        
        /*:T Retorna rowid do registro corrente do DBO */
        RUN getRowid IN {&hDBOParent} (OUTPUT rGoTo).
        
        /*:T Reposiciona registro com base em um rowid */
        RUN repositionRecord IN THIS-PROCEDURE (INPUT rGoTo).
        
        APPLY "GO":U TO FRAME fGoToRecord.
    END.
    
    ENABLE c-cod-estab c-cod-emit c-nat-oper c-cod-item c-cod-docto c-cod-serie i-num-seq btGoToOK btGoToCancel 
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
    IF NOT VALID-HANDLE({&hDBOParent}) OR
       {&hDBOParent}:TYPE <> "PROCEDURE":U OR
       {&hDBOParent}:FILE-NAME <> "intprg/boEspItemEntrSt.p":U THEN DO:
        {btb/btb008za.i1 intprg/boEspItemEntrSt.p YES}
        {btb/btb008za.i2 intprg/boEspItemEntrSt.p '' {&hDBOParent}} 
    END.
    
    /*RUN setConstraint<Description> IN {&hDBOParent} (<pamameters>) NO-ERROR.*/
    RUN openQueryStatic IN {&hDBOParent} (INPUT "Main":U) NO-ERROR.
    
    /*:T--- Verifica se o DBO j  est  inicializado ---*/
    IF NOT VALID-HANDLE({&hDBOSon1}) OR 
       {&hDBOSon1}:TYPE <> "PROCEDURE":U OR
       {&hDBOSon1}:FILE-NAME <> "intprg/boEspItemNfsSt.p":U THEN DO:
        {btb/btb008za.i1 intprg/boEspItemNfsSt.p YES}
        {btb/btb008za.i2 intprg/boEspItemNfsSt.p '' {&hDBOSon1}} 
    END.

    IF NOT VALID-HANDLE(h-boad098na) THEN DO:
        {btb/btb008za.i1 adbo/boad098na.p YES}
        {btb/btb008za.i2 adbo/boad098na.p '' h-boad098na}
    END.
    RUN openQueryStatic IN h-boad098na (INPUT "Main":U) NO-ERROR.

    IF NOT VALID-HANDLE(h-boin172) THEN DO:
        {btb/btb008za.i1 inbo/boin172.p YES}
        {btb/btb008za.i2 inbo/boin172.p '' h-boin172}
    END.
    RUN openQueryStatic IN h-boin172 (INPUT "Main":U) NO-ERROR.

    IF NOT VALID-HANDLE(h-boin245) THEN DO:
        {btb/btb008za.i1 inbo/boin245.p YES}
        {btb/btb008za.i2 inbo/boin245.p '' h-boin245}
    END.
    RUN openQueryStatic IN h-boin245 (INPUT "Main":U) NO-ERROR.

    IF NOT VALID-HANDLE(h-boad107na) THEN DO:
        {btb/btb008za.i1 adbo/boad107na.p YES}
        {btb/btb008za.i2 adbo/boad107na.p '' h-boad107na}
    END.
    RUN openQueryStatic IN h-boad107na (INPUT "Main":U) NO-ERROR.

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
    
    {masterdetail/openqueriesson.i &Parent="ByEntrada"
                                   &Query="ByEntrada"
                                   &PageNumber="1"}
                                   
    RUN atualizaSaldoFim.
    
    ASSIGN btCopySon1:SENSITIVE IN FRAME fPage1 = NO.

    RETURN "OK":U.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION fnDataMovto wMasterDetail 
FUNCTION fnDataMovto RETURNS DATE
  ( /* parameter-definitions */ ) :
/*------------------------------------------------------------------------------
  Purpose:  
    Notes:  
------------------------------------------------------------------------------*/

    ASSIGN da-dat-movto = ?.
    FOR FIRST nota-fiscal NO-LOCK
        WHERE nota-fiscal.cod-estabel = {&ttSon1}.cod-estab-nfs
          AND nota-fiscal.serie       = {&ttSon1}.cod-ser-nfs  
          AND nota-fiscal.nr-nota-fis = {&ttSon1}.cod-docto-nfs:

        ASSIGN da-dat-movto = nota-fiscal.dt-emis-nota.
    END.

  RETURN da-dat-movto.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


