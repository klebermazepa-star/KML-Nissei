&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
*/
&Scoped-define WINDOW-NAME wWindow
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS wWindow 
CREATE WIDGET-POOL.

/* Preprocessors Definitions ---                                            */
&SCOPED-DEFINE Program              NIAP001 /* Conciliacao Arquivo AGW - COPEL */
&SCOPED-DEFINE Version              1.00.00.002

&SCOPED-DEFINE Folder               YES
&SCOPED-DEFINE InitialPage          1
&SCOPED-DEFINE FolderLabels         Arquivo,Processados

&SCOPED-DEFINE WinQueryJoinsBtn     YES
&SCOPED-DEFINE WinReportsJoinsBtn   YES
&SCOPED-DEFINE WinExitBtn           YES
&SCOPED-DEFINE WinHelpBtn           YES

&SCOPED-DEFINE page0EnableWidgets   f-arquivo-agw btGetFile1Page0 ~
                                    btGoPage0

&SCOPED-DEFINE page1EnableWidgets   brTable1 tg-encontrados tg-nencontrados

&SCOPED-DEFINE page2EnableWidgets   brTable2 tg-conciliados tg-nconciliados ~
                                    btGoPage2
     
/* Datasul ERP Includes                                                     */
{include/i-prgvrs.i {&Program} {&Version}}

/* Template Includes                                                        */
{cstddk/include/wWinDefinitions.i}

/* ***************************  Definitions  ***************************    */
FUNCTION fnFormatDate RETURNS DATE
    (INPUT p-char AS CHAR)
    :
    RETURN DATE( INT(SUBSTRING(p-char,5,2)) , INT(SUBSTRING(p-char,7,2)) , INT(SUBSTRING(p-char,1,4))) .
END FUNCTION .


DEF BUFFER portador FOR ems5.portador.

DEF TEMP-TABLE tt-arq-agw NO-UNDO
    FIELD linha             AS INT FORMAT ">>>>>>>>9" COLUMN-LABEL "Linha"
    FIELD nr-fatura         AS CHAR FORMAT "X(18)" COLUMN-LABEL "Fatura COPEL"
    FIELD vl-fatura         LIKE fat-duplic.vl-parcela COLUMN-LABEL "Vl Fatura" 
    FIELD dt-arrecad        LIKE fat-duplic.dt-venciment COLUMN-LABEL "Arrecadaá∆o":U
    FIELD l-fat-duplic      AS LOGICAL COLUMN-LABEL "Existe TOTVS"
    FIELD cod-barras        AS CHAR FORMAT "X(60)" COLUMN-LABEL "C¢digo de Barras - Fatura":U
    .

DEF TEMP-TABLE tt-agw NO-UNDO LIKE tt-arq-agw
    FIELD r-rowid-cst_nota_copel    AS ROWID
    FIELD r-rowid-nota-fiscal       AS ROWID
    FIELD cod-estabel               LIKE nota-fiscal.cod-estabel
    FIELD serie                     LIKE nota-fiscal.serie      
    FIELD nr-nota-fis               LIKE nota-fiscal.nr-nota-fis
    FIELD conciliado-agw            AS LOGICAL COLUMN-LABEL "Conciliado"
    .
    
/*     FIELD serie             LIKE cst-fat-duplic.serie COLUMN-LABEL "Serie T"           */
/*     FIELD cod-portador-at   LIKE cst-fat-duplic.cod-portador COLUMN-LABEL "Portador T" */
/*     FIELD parcela-at        LIKE fat-duplic.parcela COLUMN-LABEL "Pa T"                */
/*     FIELD vl-parcela-at     LIKE fat-duplic.vl-parcela COLUMN-LABEL "Vl Parcela T"     */
/*     FIELD taxa-admin-at     LIKE cst-fat-duplic.taxa-admin COLUMN-LABEL "Taxa T"       */
/*     FIELD dt-venciment-at   LIKE fat-duplic.dt-venciment COLUMN-LABEL "Vencimento T"   */
/*     FIELD flag-atualiz      LIKE fat-duplic.flag-atualiz COLUMN-LABEL "At ACR"         */
/*     FIELD flags-erros       AS CHAR FORMAT "X(50)" COLUMN-LABEL "Erros"                */
/*     .                                                                                  */
    .

/* Parameters Definitions ---                                               */

/* Local Variable Definitions ---                                           */
DEF NEW GLOBAL SHARED VAR v_rec_portador AS RECID INITIAL ? NO-UNDO .


DEFINE VARIABLE pOEstab      AS CHAR NO-UNDO.
DEFINE VARIABLE pOFornec     AS INT NO-UNDO.
DEFINE VARIABLE pOEmissao    AS DATE FORMAT "99/99/9999" NO-UNDO.
DEFINE VARIABLE pOVencimento AS DATE FORMAT "99/99/9999" NO-UNDO.

DEFINE VARIABLE pOAcao AS CHARACTER   NO-UNDO.

DEFINE VARIABLE v_log_refer_uni AS LOGICAL   NO-UNDO.

DEF NEW GLOBAL SHARED VAR v_rec_clien_financ
    AS RECID
    FORMAT ">>>>>>9":U
    INITIAL ?
    NO-UNDO.

{intprg/niap001.i}
{cdp/cd0666.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Window
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME fpage0
&Scoped-define BROWSE-NAME brTable1

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-arq-agw tt-agw

/* Definitions for BROWSE brTable1                                      */
&Scoped-define FIELDS-IN-QUERY-brTable1 tt-arq-agw.linha tt-arq-agw.nr-fatura tt-arq-agw.vl-fatura tt-arq-agw.dt-arrecad tt-arq-agw.cod-barras tt-arq-agw.l-fat-duplic   
&Scoped-define ENABLED-FIELDS-IN-QUERY-brTable1   
&Scoped-define SELF-NAME brTable1
&Scoped-define QUERY-STRING-brTable1 FOR EACH tt-arq-agw NO-LOCK     WHERE (tt-arq-agw.l-fat-duplic = YES AND INPUT FRAME fPage1 tg-encontrados = YES OR            tt-arq-agw.l-fat-duplic = NO AND INPUT FRAME fPage1 tg-nencontrados = YES )     INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-brTable1 OPEN QUERY {&SELF-NAME} FOR EACH tt-arq-agw NO-LOCK     WHERE (tt-arq-agw.l-fat-duplic = YES AND INPUT FRAME fPage1 tg-encontrados = YES OR            tt-arq-agw.l-fat-duplic = NO AND INPUT FRAME fPage1 tg-nencontrados = YES )     INDEXED-REPOSITION .
&Scoped-define TABLES-IN-QUERY-brTable1 tt-arq-agw
&Scoped-define FIRST-TABLE-IN-QUERY-brTable1 tt-arq-agw


/* Definitions for BROWSE brTable2                                      */
&Scoped-define FIELDS-IN-QUERY-brTable2 tt-agw.linha tt-agw.cod-estabel tt-agw.serie tt-agw.nr-nota-fis tt-agw.nr-fatura tt-agw.vl-fatura tt-agw.dt-arrecad tt-agw.conciliado-agw tt-agw.cod-barras   
&Scoped-define ENABLED-FIELDS-IN-QUERY-brTable2   
&Scoped-define SELF-NAME brTable2
&Scoped-define QUERY-STRING-brTable2 FOR EACH tt-agw NO-LOCK     WHERE (tt-agw.conciliado-agw = YES AND INPUT FRAME fPage2 tg-conciliados = YES OR            tt-agw.conciliado-agw = NO AND INPUT FRAME fPage2 tg-nconciliados = YES ) /*     AND   (tt-agw.flag-atualiz = YES AND INPUT FRAME fPage2 tg-at-acr = YES OR                 */ /*            tt-agw.flag-atualiz = NO AND INPUT FRAME fPage2 tg-nat-acr = YES )                  */ /*     AND   ((tt-agw.flags-erros <> "" AND INPUT FRAME fPage2 tg-erros = YES AND                 */ /*               (LOOKUP('1' , ~
       tt-agw.flags-erros) > 0 AND INPUT FRAME fPage2 tg-erro-1 = YES) OR */ /*               (LOOKUP('2' , ~
       tt-agw.flags-erros) > 0 AND INPUT FRAME fPage2 tg-erro-2 = YES) OR */ /*               (LOOKUP('3' , ~
       tt-agw.flags-erros) > 0 AND INPUT FRAME fPage2 tg-erro-3 = YES) OR */ /*               (LOOKUP('4' , ~
       tt-agw.flags-erros) > 0 AND INPUT FRAME fPage2 tg-erro-4 = YES) OR */ /*               (LOOKUP('5' , ~
       tt-agw.flags-erros) > 0 AND INPUT FRAME fPage2 tg-erro-5 = YES)    */ /*              ) OR                                                                              */ /*            tt-agw.flags-erros = "" AND INPUT FRAME fPage2 tg-serros = YES                      */ /*           )                                                                                    */     INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-brTable2 OPEN QUERY {&SELF-NAME} FOR EACH tt-agw NO-LOCK     WHERE (tt-agw.conciliado-agw = YES AND INPUT FRAME fPage2 tg-conciliados = YES OR            tt-agw.conciliado-agw = NO AND INPUT FRAME fPage2 tg-nconciliados = YES ) /*     AND   (tt-agw.flag-atualiz = YES AND INPUT FRAME fPage2 tg-at-acr = YES OR                 */ /*            tt-agw.flag-atualiz = NO AND INPUT FRAME fPage2 tg-nat-acr = YES )                  */ /*     AND   ((tt-agw.flags-erros <> "" AND INPUT FRAME fPage2 tg-erros = YES AND                 */ /*               (LOOKUP('1' , ~
       tt-agw.flags-erros) > 0 AND INPUT FRAME fPage2 tg-erro-1 = YES) OR */ /*               (LOOKUP('2' , ~
       tt-agw.flags-erros) > 0 AND INPUT FRAME fPage2 tg-erro-2 = YES) OR */ /*               (LOOKUP('3' , ~
       tt-agw.flags-erros) > 0 AND INPUT FRAME fPage2 tg-erro-3 = YES) OR */ /*               (LOOKUP('4' , ~
       tt-agw.flags-erros) > 0 AND INPUT FRAME fPage2 tg-erro-4 = YES) OR */ /*               (LOOKUP('5' , ~
       tt-agw.flags-erros) > 0 AND INPUT FRAME fPage2 tg-erro-5 = YES)    */ /*              ) OR                                                                              */ /*            tt-agw.flags-erros = "" AND INPUT FRAME fPage2 tg-serros = YES                      */ /*           )                                                                                    */     INDEXED-REPOSITION .
&Scoped-define TABLES-IN-QUERY-brTable2 tt-agw
&Scoped-define FIRST-TABLE-IN-QUERY-brTable2 tt-agw


/* Definitions for FRAME fPage1                                         */

/* Definitions for FRAME fPage2                                         */

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS rtToolBar btQueryJoins btReportsJoins btExit ~
btHelp btGetFile1Page0 btGoPage0 
&Scoped-Define DISPLAYED-OBJECTS f-arquivo-agw 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR wWindow AS WIDGET-HANDLE NO-UNDO.

/* Menu Definitions                                                     */
DEFINE SUB-MENU smFile 
       MENU-ITEM miQueryJoins   LABEL "&Consultas"    
       MENU-ITEM miReportsJoins LABEL "&Relat¢rios"   
       RULE
       MENU-ITEM miExit         LABEL "&Sair"          ACCELERATOR "CTRL-X".

DEFINE SUB-MENU smHelp 
       MENU-ITEM miContents     LABEL "&Conte£do"     
       MENU-ITEM miAbout        LABEL "&Sobre..."     .

DEFINE MENU mbMain MENUBAR
       SUB-MENU  smFile         LABEL "&Arquivo"      
       SUB-MENU  smHelp         LABEL "&Ajuda"        .


/* Definitions of the field level widgets                               */
DEFINE BUTTON btExit 
     IMAGE-UP FILE "image\im-exi":U
     IMAGE-INSENSITIVE FILE "image\ii-exi":U
     LABEL "Exit" 
     SIZE 4 BY 1.25 TOOLTIP "Sair"
     FONT 4.

DEFINE BUTTON btGetFile1Page0 
     IMAGE-UP FILE "image/toolbar/im-open.bmp":U
     LABEL "Button 1" 
     SIZE 5.14 BY 1.46.

DEFINE BUTTON btGoPage0 
     IMAGE-UP FILE "image/toolbar/im-tick.bmp":U
     LABEL "Processar" 
     SIZE 5.14 BY 1.46.

DEFINE BUTTON btHelp 
     IMAGE-UP FILE "image\im-hel":U
     IMAGE-INSENSITIVE FILE "image\ii-hel":U
     LABEL "Help" 
     SIZE 4 BY 1.25 TOOLTIP "Ajuda"
     FONT 4.

DEFINE BUTTON btQueryJoins 
     IMAGE-UP FILE "image\im-joi":U
     IMAGE-INSENSITIVE FILE "image\ii-joi":U
     LABEL "Query Joins" 
     SIZE 4 BY 1.25 TOOLTIP "Consultas Relacionadas"
     FONT 4.

DEFINE BUTTON btReportsJoins 
     IMAGE-UP FILE "image\im-pri":U
     IMAGE-INSENSITIVE FILE "image\ii-pri":U
     LABEL "Reports Joins" 
     SIZE 4 BY 1.25 TOOLTIP "Relat¢rios Relacionados"
     FONT 4.

DEFINE VARIABLE f-arquivo-agw AS CHARACTER FORMAT "X(256)":U 
     LABEL "Arquivo AGW" 
     VIEW-AS FILL-IN 
     SIZE 86.57 BY .88 NO-UNDO.

DEFINE RECTANGLE rtToolBar
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 120 BY 1.5
     BGCOLOR 7 .

DEFINE VARIABLE f-tot-encontrados AS INTEGER FORMAT ">>>,>>>,>>9":U INITIAL 0 
     LABEL "Encontrados" 
     VIEW-AS FILL-IN 
     SIZE 10 BY .88 NO-UNDO.

DEFINE VARIABLE f-tot-linhas AS INTEGER FORMAT ">>>,>>>,>>9":U INITIAL 0 
     LABEL "Tot Linhas" 
     VIEW-AS FILL-IN 
     SIZE 10 BY .88 NO-UNDO.

DEFINE VARIABLE f-tot-nencontrados AS INTEGER FORMAT ">>>,>>>,>>9":U INITIAL 0 
     LABEL "N∆o Encontrados" 
     VIEW-AS FILL-IN 
     SIZE 10 BY .88 NO-UNDO.

DEFINE RECTANGLE rt1
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 114 BY 1.25
     BGCOLOR 7 .

DEFINE VARIABLE tg-encontrados AS LOGICAL INITIAL yes 
     LABEL "" 
     VIEW-AS TOGGLE-BOX
     SIZE 3 BY .88 NO-UNDO.

DEFINE VARIABLE tg-nencontrados AS LOGICAL INITIAL yes 
     LABEL "" 
     VIEW-AS TOGGLE-BOX
     SIZE 3 BY .88 NO-UNDO.

DEFINE BUTTON btGoPage2 
     LABEL "Gerar T°tulo APB" 
     SIZE 15 BY 1.

DEFINE VARIABLE f-tot-conciliados AS INTEGER FORMAT ">>>,>>>,>>9":U INITIAL 0 
     LABEL "Conciliados" 
     VIEW-AS FILL-IN 
     SIZE 10 BY .88 NO-UNDO.

DEFINE VARIABLE f-tot-faturas AS INTEGER FORMAT ">>>,>>>,>>9":U INITIAL 0 
     LABEL "Tot Faturas" 
     VIEW-AS FILL-IN 
     SIZE 10 BY .88 NO-UNDO.

DEFINE VARIABLE f-tot-nconciliados AS INTEGER FORMAT ">>>,>>>,>>9":U INITIAL 0 
     LABEL "N∆o Conciliados" 
     VIEW-AS FILL-IN 
     SIZE 10 BY .88 NO-UNDO.

DEFINE VARIABLE f-vl-tot-conciliados AS DECIMAL FORMAT "->>,>>>,>>9.99":U INITIAL 0 
     LABEL "Total Conciliados" 
     VIEW-AS FILL-IN 
     SIZE 15 BY .88 NO-UNDO.

DEFINE VARIABLE f-vl-tot-nao-conciliados AS DECIMAL FORMAT "->>,>>>,>>9.99":U INITIAL 0 
     LABEL "Total N∆o Conciliados" 
     VIEW-AS FILL-IN 
     SIZE 15 BY .88 NO-UNDO.

DEFINE RECTANGLE rt-2
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 114 BY 2.5
     BGCOLOR 7 .

DEFINE VARIABLE tg-conciliados AS LOGICAL INITIAL yes 
     LABEL "" 
     VIEW-AS TOGGLE-BOX
     SIZE 3 BY .88 NO-UNDO.

DEFINE VARIABLE tg-nconciliados AS LOGICAL INITIAL yes 
     LABEL "" 
     VIEW-AS TOGGLE-BOX
     SIZE 3 BY .88 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY brTable1 FOR 
      tt-arq-agw SCROLLING.

DEFINE QUERY brTable2 FOR 
      tt-agw SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE brTable1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS brTable1 wWindow _FREEFORM
  QUERY brTable1 DISPLAY
      tt-arq-agw.linha         
 tt-arq-agw.nr-fatura  WIDTH 18
 tt-arq-agw.vl-fatura   
 tt-arq-agw.dt-arrecad    
 tt-arq-agw.cod-barras    
 tt-arq-agw.l-fat-duplic VIEW-AS TOGGLE-BOX
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 114 BY 14.75
         FONT 1.

DEFINE BROWSE brTable2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS brTable2 wWindow _FREEFORM
  QUERY brTable2 DISPLAY
      tt-agw.linha
 tt-agw.cod-estabel
 tt-agw.serie
 tt-agw.nr-nota-fis
 tt-agw.nr-fatura   WIDTH 17
 tt-agw.vl-fatura   
 tt-agw.dt-arrecad
 tt-agw.conciliado-agw VIEW-AS TOGGLE-BOX 
 tt-agw.cod-barras
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 114 BY 13.75
         FONT 1.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME fpage0
     btQueryJoins AT ROW 1.13 COL 104.29 HELP
          "Consultas Relacionadas"
     btReportsJoins AT ROW 1.13 COL 108.29 HELP
          "Relat¢rios Relacionados"
     btExit AT ROW 1.13 COL 112.29 HELP
          "Sair"
     btHelp AT ROW 1.13 COL 116.29 HELP
          "Ajuda"
     btGetFile1Page0 AT ROW 2.63 COL 102.57 WIDGET-ID 4
     btGoPage0 AT ROW 2.63 COL 112 WIDGET-ID 14
     f-arquivo-agw AT ROW 3 COL 13.43 COLON-ALIGNED WIDGET-ID 10
     rtToolBar AT ROW 1 COL 1
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 120 BY 21.29
         FONT 1 WIDGET-ID 100.

DEFINE FRAME fPage1
     brTable1 AT ROW 1 COL 1 WIDGET-ID 200
     f-tot-linhas AT ROW 16.25 COL 9 COLON-ALIGNED WIDGET-ID 54
     f-tot-encontrados AT ROW 16.25 COL 30 COLON-ALIGNED WIDGET-ID 50
     tg-encontrados AT ROW 16.25 COL 43 WIDGET-ID 56
     f-tot-nencontrados AT ROW 16.25 COL 58 COLON-ALIGNED WIDGET-ID 52
     tg-nencontrados AT ROW 16.25 COL 71 WIDGET-ID 58
     rt1 AT ROW 16 COL 1 WIDGET-ID 48
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 3.57 ROW 5.17
         SIZE 115 BY 16.5
         FONT 1 WIDGET-ID 100.

DEFINE FRAME fPage2
     brTable2 AT ROW 1 COL 1 WIDGET-ID 200
     f-tot-faturas AT ROW 15 COL 9 COLON-ALIGNED WIDGET-ID 54
     f-tot-conciliados AT ROW 15 COL 30.29 COLON-ALIGNED WIDGET-ID 50
     tg-conciliados AT ROW 15 COL 43.29 WIDGET-ID 56
     f-tot-nconciliados AT ROW 15 COL 61 COLON-ALIGNED WIDGET-ID 52
     tg-nconciliados AT ROW 15 COL 74 WIDGET-ID 58
     btGoPage2 AT ROW 15.96 COL 98.57 WIDGET-ID 90
     f-vl-tot-conciliados AT ROW 16 COL 30.29 COLON-ALIGNED WIDGET-ID 92
     f-vl-tot-nao-conciliados AT ROW 16 COL 61 COLON-ALIGNED WIDGET-ID 94
     rt-2 AT ROW 14.75 COL 1 WIDGET-ID 48
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 3.57 ROW 5.17
         SIZE 115 BY 16.5
         FONT 1 WIDGET-ID 300.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Window
   Allow: Basic,Browse,DB-Fields,Window,Query
   Add Fields to: Neither
   Other Settings: COMPILE
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
IF SESSION:DISPLAY-TYPE = "GUI":U THEN
  CREATE WINDOW wWindow ASSIGN
         HIDDEN             = YES
         TITLE              = "wWindow"
         HEIGHT             = 21.29
         WIDTH              = 120
         MAX-HEIGHT         = 320
         MAX-WIDTH          = 320
         VIRTUAL-HEIGHT     = 320
         VIRTUAL-WIDTH      = 320
         RESIZE             = no
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



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW wWindow
  NOT-VISIBLE,,RUN-PERSISTENT                                           */
/* REPARENT FRAME */
ASSIGN FRAME fPage1:FRAME = FRAME fpage0:HANDLE
       FRAME fPage2:FRAME = FRAME fpage0:HANDLE.

/* SETTINGS FOR FRAME fpage0
   FRAME-NAME                                                           */
/* SETTINGS FOR FILL-IN f-arquivo-agw IN FRAME fpage0
   NO-ENABLE                                                            */
/* SETTINGS FOR FRAME fPage1
                                                                        */
/* BROWSE-TAB brTable1 1 fPage1 */
ASSIGN 
       brTable1:ALLOW-COLUMN-SEARCHING IN FRAME fPage1 = TRUE
       brTable1:COLUMN-RESIZABLE IN FRAME fPage1       = TRUE
       brTable1:COLUMN-MOVABLE IN FRAME fPage1         = TRUE.

/* SETTINGS FOR FRAME fPage2
                                                                        */
/* BROWSE-TAB brTable2 1 fPage2 */
ASSIGN 
       brTable2:ALLOW-COLUMN-SEARCHING IN FRAME fPage2 = TRUE
       brTable2:COLUMN-RESIZABLE IN FRAME fPage2       = TRUE
       brTable2:COLUMN-MOVABLE IN FRAME fPage2         = TRUE.

IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(wWindow)
THEN wWindow:HIDDEN = yes.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE brTable1
/* Query rebuild information for BROWSE brTable1
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH tt-arq-agw NO-LOCK
    WHERE (tt-arq-agw.l-fat-duplic = YES AND INPUT FRAME fPage1 tg-encontrados = YES OR
           tt-arq-agw.l-fat-duplic = NO AND INPUT FRAME fPage1 tg-nencontrados = YES )
    INDEXED-REPOSITION .
     _END_FREEFORM
     _Query            is NOT OPENED
*/  /* BROWSE brTable1 */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE brTable2
/* Query rebuild information for BROWSE brTable2
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH tt-agw NO-LOCK
    WHERE (tt-agw.conciliado-agw = YES AND INPUT FRAME fPage2 tg-conciliados = YES OR
           tt-agw.conciliado-agw = NO AND INPUT FRAME fPage2 tg-nconciliados = YES )
/*     AND   (tt-agw.flag-atualiz = YES AND INPUT FRAME fPage2 tg-at-acr = YES OR                 */
/*            tt-agw.flag-atualiz = NO AND INPUT FRAME fPage2 tg-nat-acr = YES )                  */
/*     AND   ((tt-agw.flags-erros <> "" AND INPUT FRAME fPage2 tg-erros = YES AND                 */
/*               (LOOKUP('1' , tt-agw.flags-erros) > 0 AND INPUT FRAME fPage2 tg-erro-1 = YES) OR */
/*               (LOOKUP('2' , tt-agw.flags-erros) > 0 AND INPUT FRAME fPage2 tg-erro-2 = YES) OR */
/*               (LOOKUP('3' , tt-agw.flags-erros) > 0 AND INPUT FRAME fPage2 tg-erro-3 = YES) OR */
/*               (LOOKUP('4' , tt-agw.flags-erros) > 0 AND INPUT FRAME fPage2 tg-erro-4 = YES) OR */
/*               (LOOKUP('5' , tt-agw.flags-erros) > 0 AND INPUT FRAME fPage2 tg-erro-5 = YES)    */
/*              ) OR                                                                              */
/*            tt-agw.flags-erros = "" AND INPUT FRAME fPage2 tg-serros = YES                      */
/*           )                                                                                    */
    INDEXED-REPOSITION .
     _END_FREEFORM
     _Query            is NOT OPENED
*/  /* BROWSE brTable2 */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK FRAME fpage0
/* Query rebuild information for FRAME fpage0
     _Options          = "SHARE-LOCK KEEP-EMPTY"
     _Query            is NOT OPENED
*/  /* FRAME fpage0 */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK FRAME fPage1
/* Query rebuild information for FRAME fPage1
     _Options          = "SHARE-LOCK KEEP-EMPTY"
     _Query            is NOT OPENED
*/  /* FRAME fPage1 */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK FRAME fPage2
/* Query rebuild information for FRAME fPage2
     _Options          = "SHARE-LOCK KEEP-EMPTY"
     _Query            is NOT OPENED
*/  /* FRAME fPage2 */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME wWindow
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL wWindow wWindow
ON END-ERROR OF wWindow /* wWindow */
OR ENDKEY OF {&WINDOW-NAME} ANYWHERE DO:
  /* This case occurs when the user presses the "Esc" key.
     In a persistently run window, just ignore this.  If we did not, the
     application would exit. */
  IF THIS-PROCEDURE:PERSISTENT THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL wWindow wWindow
ON WINDOW-CLOSE OF wWindow /* wWindow */
DO:
  /* This event will close the window and terminate the procedure.  */
  APPLY "CLOSE":U TO THIS-PROCEDURE.
  RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL wWindow wWindow
ON WINDOW-MAXIMIZED OF wWindow /* wWindow */
DO:
    &IF "{&WinFullScreen}":U = "YES":U &THEN 
    RUN windowMaximized IN THIS-PROCEDURE .
    &ENDIF
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL wWindow wWindow
ON WINDOW-RESTORED OF wWindow /* wWindow */
DO:
    &IF "{&WinFullScreen}":U = "YES":U &THEN 
    RUN windowRestored IN THIS-PROCEDURE .
    &ENDIF
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btExit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btExit wWindow
ON CHOOSE OF btExit IN FRAME fpage0 /* Exit */
OR CHOOSE OF MENU-ITEM miExit IN MENU mbMain DO:
    APPLY "CLOSE":U TO THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btGetFile1Page0
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btGetFile1Page0 wWindow
ON CHOOSE OF btGetFile1Page0 IN FRAME fpage0 /* Button 1 */
DO:
    DEF VAR v_file  AS CHAR NO-UNDO .
    DEF VAR v_ok    AS LOGICAL NO-UNDO .

    SYSTEM-DIALOG GET-FILE v_file
        FILTERS "*.csv" "*.csv",
                "*.*" "*.*"
        INITIAL-DIR SESSION:TEMP-DIR 
        MUST-EXIST
        USE-FILENAME
        UPDATE v_ok
        .
    IF v_ok = TRUE THEN DO:
        ASSIGN f-arquivo-agw:SCREEN-VALUE IN FRAME fPage0 = v_file .
    END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btGoPage0
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btGoPage0 wWindow
ON CHOOSE OF btGoPage0 IN FRAME fpage0 /* Processar */
DO:

    IF INPUT FRAME fPage0 f-arquivo-agw = "" THEN DO:
        RUN utp/ut-msgs.p(INPUT "show":U, INPUT 17006, 
                          INPUT "Arquivo agw n∆o informado.~~" + "") 
            .
        RETURN NO-APPLY. 
    END.
    /**/
    RUN pi-goPage0 .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME fPage2
&Scoped-define SELF-NAME btGoPage2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btGoPage2 wWindow
ON CHOOSE OF btGoPage2 IN FRAME fPage2 /* Gerar T°tulo APB */
DO:
/*     RUN pi-goPage2 . */
    RUN intprg/niap001a.w(OUTPUT pOEstab  ,
                          OUTPUT pOFornec ,
                          OUTPUT pOEmissao,
                          OUTPUT pOVencimento,
                          OUTPUT pOAcao   ).

    IF pOAcao = "OK" THEN DO:
        empty temp-table tt_integr_apb_abat_antecip_vouc no-error.
        empty temp-table tt_integr_apb_abat_prev_provis no-error.
        empty temp-table tt_integr_apb_aprop_ctbl_pend no-error.
        empty temp-table tt_integr_apb_aprop_relacto no-error.
        empty temp-table tt_integr_apb_impto_impl_pend no-error.
        empty temp-table tt_integr_apb_item_lote_impl3v no-error.
        empty temp-table tt_integr_apb_lote_impl no-error.
        empty temp-table tt_integr_apb_relacto_pend no-error.
        empty temp-table tt_log_erros_atualiz no-error.
        empty temp-table tt_integr_apb_item_lote_impl3v no-error.

        RUN piGeraTituloAPB_Conciliador.
    END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME fpage0
&Scoped-define SELF-NAME btHelp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btHelp wWindow
ON CHOOSE OF btHelp IN FRAME fpage0 /* Help */
OR CHOOSE OF MENU-ITEM miContents IN MENU mbMain DO:
    {include/ajuda.i}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btQueryJoins
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btQueryJoins wWindow
ON CHOOSE OF btQueryJoins IN FRAME fpage0 /* Query Joins */
OR CHOOSE OF MENU-ITEM miQueryJoins IN MENU mbMain DO:
    RUN showQueryJoins IN THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btReportsJoins
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btReportsJoins wWindow
ON CHOOSE OF btReportsJoins IN FRAME fpage0 /* Reports Joins */
OR CHOOSE OF MENU-ITEM miReportsJoins IN MENU mbMain DO:
    RUN showReportsJoins IN THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME miAbout
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL miAbout wWindow
ON CHOOSE OF MENU-ITEM miAbout /* Sobre... */
DO:
  {include/sobre.i}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME fPage2
&Scoped-define SELF-NAME tg-conciliados
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tg-conciliados wWindow
ON VALUE-CHANGED OF tg-conciliados IN FRAME fPage2
DO:
    {&open-query-brTable2}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME fPage1
&Scoped-define SELF-NAME tg-encontrados
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tg-encontrados wWindow
ON VALUE-CHANGED OF tg-encontrados IN FRAME fPage1
DO:
    {&open-query-brTable1}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME fPage2
&Scoped-define SELF-NAME tg-nconciliados
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tg-nconciliados wWindow
ON VALUE-CHANGED OF tg-nconciliados IN FRAME fPage2
DO:
    {&open-query-brTable2}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME fPage1
&Scoped-define SELF-NAME tg-nencontrados
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tg-nencontrados wWindow
ON VALUE-CHANGED OF tg-nencontrados IN FRAME fPage1
DO:
    {&open-query-brTable1}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME fpage0
&Scoped-define BROWSE-NAME brTable1
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK wWindow 


/**/

/* ***************************** MAIN BLOCK *************************** */
{cstddk/include/wWinMainBlock.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE afterInitializeInterface wWindow 
PROCEDURE afterInitializeInterface :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
RUN setEnabled IN hFolder(INPUT 1 , INPUT YES) .
RUN setEnabled IN hFolder(INPUT 2 , INPUT NO) .

/**/
RETURN "OK":U .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-goPage0 wWindow 
PROCEDURE pi-goPage0 :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
DEF VAR h-acomp AS HANDLE NO-UNDO .
RUN utp/ut-acomp.p PERSISTENT SET h-acomp .
RUN pi-inicializar IN h-acomp (INPUT "Processando") .
RUN pi-acompanhar IN h-acomp (INPUT "Lendo Arquivo...") .

DEF VAR c-linha     AS CHAR NO-UNDO .
DEF VAR i-cont      AS INT NO-UNDO .

ASSIGN f-tot-linhas             = 0 .
ASSIGN f-tot-encontrados        = 0 .
ASSIGN f-tot-nencontrados       = 0 .
ASSIGN f-vl-tot-nao-conciliados = 0 .
ASSIGN f-vl-tot-conciliados     = 0 .
EMPTY TEMP-TABLE tt-arq-agw .
EMPTY TEMP-TABLE tt-agw .

INPUT FROM VALUE(INPUT FRAME fPage0 f-arquivo-agw) NO-CONVERT .


REPEAT ON ERROR UNDO , LEAVE ON STOP UNDO , LEAVE
    :

    
    IMPORT UNFORMATTED c-linha .
    ASSIGN c-linha = REPLACE(c-linha,'"',"") .
    IF c-linha = "" THEN NEXT .
    IF ENTRY(03,c-linha,";") = "N.S.A." THEN NEXT.
    /**/
    ASSIGN f-tot-linhas = f-tot-linhas + 1 .
    IF f-tot-linhas MOD 10 = 0 THEN DO:
        RUN pi-acompanhar IN h-acomp (INPUT "Lendo Arquivo... Linha: " + STRING(f-tot-linhas) ) .
    END.



    CREATE tt-arq-agw . 
    ASSIGN tt-arq-agw.linha          = f-tot-linhas
           tt-arq-agw.nr-fatura      = ENTRY(07,c-linha,";")
           tt-arq-agw.vl-fatura      = DEC(ENTRY(08,c-linha,";"))
           tt-arq-agw.dt-arrecad     = DATE(ENTRY(06,c-linha,";"))
           tt-arq-agw.cod-barras     = ENTRY(12,c-linha,";")
           tt-arq-agw.l-fat-duplic   = NO.
        .
        DO WHILE LENGTH(tt-arq-agw.nr-fatura) < 17:
            ASSIGN tt-arq-agw.nr-fatura = "0" + tt-arq-agw.nr-fatura.
        END.

END.

INPUT CLOSE .

RUN pi-acompanhar IN h-acomp (INPUT "Processando Arquivo... ") .

ASSIGN i-cont = 0 .
ASSIGN f-tot-faturas = 0 .
ASSIGN f-tot-conciliados = 0 .
ASSIGN f-tot-nconciliados = 0 .

FOR EACH tt-arq-agw
    :
    ASSIGN i-cont = i-cont + 1 .
    IF i-cont MOD 100 = 0 THEN DO:
        RUN pi-acompanhar IN h-acomp (INPUT "Processando Arquivo... " + STRING(i-cont) + " de " + STRING(f-tot-linhas) ) .
    END.

    FOR EACH cst_nota_copel NO-LOCK
       WHERE cst_nota_copel.COR_NUM_FATURA = tt-arq-agw.nr-fatura
         AND cst_nota_copel.log_conciliado = NO  :

        RUN pi-goPage0-cria-tt-agw.

    END.

    /**/
/*     FOR EACH cst-fat-duplic NO-LOCK                                                                                         */
/*         WHERE cst-fat-duplic.cod-estabel    = tt-arq-agw.cod-estabel                                                        */
/*           AND cst-fat-duplic.nr-fatura      = tt-arq-agw.nr-fatura                                                          */
/*           AND cst-fat-duplic.nsu-numero     = tt-arq-agw.nsu-numero                                                         */
/*           AND cst-fat-duplic.parcela        = tt-arq-agw.parcela                                                            */
/*         :                                                                                                                   */
/*         RUN pi-goPage0-cria-tt-agw .                                                                                        */
/*     END.                                                                                                                    */
/*                                                                                                                             */
/*     IF tt-arq-agw.l-fat-duplic = NO THEN DO:                                                                                */
/*         FOR EACH cst-fat-duplic NO-LOCK                                                                                     */
/*             WHERE cst-fat-duplic.cod-estabel    = tt-arq-agw.cod-estabel                                                    */
/*               AND cst-fat-duplic.nr-fatura      = tt-arq-agw.nr-fatura                                                      */
/*               AND cst-fat-duplic.nsu-numero     = tt-arq-agw.nsu-numero                                                     */
/*             :                                                                                                               */
/*             RUN pi-goPage0-cria-tt-agw .                                                                                    */
/*         END.                                                                                                                */
/*     END.                                                                                                                    */
/*                                                                                                                             */
    IF tt-arq-agw.l-fat-duplic = YES THEN DO:
        ASSIGN f-tot-encontrados = f-tot-encontrados + 1 .
    END.
    ELSE DO:
        ASSIGN f-tot-nencontrados = f-tot-nencontrados + 1 
               .
    END.
END.

RUN pi-acompanhar IN h-acomp (INPUT "Realizando Validaá‰es... ") .
RUN pi-goPage0-valida-agw .

{&open-query-brTable1}

DISPLAY
    f-tot-linhas
    f-tot-encontrados
    f-tot-nencontrados
    WITH FRAME fPage1 .


{&open-query-brTable2}

DISPLAY
    f-tot-faturas
    f-tot-conciliados
    f-tot-nconciliados
    f-vl-tot-conciliados
    f-vl-tot-nao-conciliados
    WITH FRAME fPage2 .

/**/
RUN setEnabled IN hFolder(INPUT 1 , INPUT YES) .
RUN setEnabled IN hFolder(INPUT 2 , INPUT YES) .
RUN setFolder IN hFolder(INPUT 2) . 

/**/
RUN pi-finalizar IN h-acomp.
RETURN "OK":U .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-goPage0-cria-tt-agw wWindow 
PROCEDURE pi-goPage0-cria-tt-agw :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
FOR FIRST nota-fiscal
    WHERE nota-fiscal.cod-estabel = cst_nota_copel.cod_estabel  
      AND nota-fiscal.serie       = cst_nota_copel.serie
      AND nota-fiscal.nr-nota-fis = cst_nota_copel.nr_nota_fis :

    ASSIGN tt-arq-agw.l-fat-duplic = YES . 

    CREATE tt-agw.
    BUFFER-COPY tt-arq-agw TO tt-agw. 
    
    ASSIGN tt-agw.r-rowid-cst_nota_copel = ROWID(cst_nota_copel)
           tt-agw.r-rowid-nota-fiscal    = ROWID(nota-fiscal)
           tt-agw.cod-estabel            = nota-fiscal.cod-estabel
           tt-agw.serie                  = nota-fiscal.serie      
           tt-agw.nr-nota-fis            = nota-fiscal.nr-nota-fis
           tt-agw.conciliado-agw         = cst_nota_copel.log_conciliado.

    IF tt-agw.conciliado-agw = ? THEN DO:
        ASSIGN tt-agw.conciliado-agw = NO .
    END.

    ASSIGN f-tot-faturas = f-tot-faturas + 1 .
    IF tt-agw.conciliado-agw = YES THEN DO:
        ASSIGN f-tot-conciliados        = f-tot-conciliados + 1
               f-vl-tot-conciliados     = f-vl-tot-conciliados + tt-arq-agw.vl-fatura .
    END.
    ELSE DO:
        ASSIGN f-tot-nconciliados       = f-tot-nconciliados + 1
               f-vl-tot-nao-conciliados = f-vl-tot-nao-conciliados + tt-arq-agw.vl-fatura .
    END.

/*     IF tt-agw.flag-atualiz = YES THEN DO:          */
/*         ASSIGN f-tot-at-acr = f-tot-at-acr + 1 .   */
/*     END.                                           */
/*     ELSE DO:                                       */
/*         ASSIGN f-tot-nat-acr = f-tot-nat-acr + 1 . */
/*     END.                                           */
END.
/**/
RETURN "OK":U .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-goPage0-valida-agw wWindow 
PROCEDURE pi-goPage0-valida-agw :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
/* ASSIGN f-tot-erros = 0 .                                                           */
/* ASSIGN f-tot-serros = 0 .                                                          */
/* FOR EACH tt-agw                                                                  */
/*     :                                                                              */
/*     ASSIGN tt-agw.flags-erros = "" .                                             */
/*     IF tt-agw.taxa-admin <> tt-agw.taxa-admin-at THEN DO:                      */
/*         ASSIGN tt-agw.flags-erros = tt-agw.flags-erros + ",1" .                */
/*     END.                                                                           */
/*     IF tt-agw.vl-parcela-bruto <> tt-agw.vl-parcela-at THEN DO:                */
/*         ASSIGN tt-agw.flags-erros = tt-agw.flags-erros + ",2" .                */
/*     END.                                                                           */
/*     IF tt-agw.tipo-movto = "D" AND                                               */
/*        tt-agw.cod-portador-at <> INT(INPUT FRAME fPage0 f-cod-portador-debito)   */
/*     THEN DO:                                                                       */
/*         ASSIGN tt-agw.flags-erros = tt-agw.flags-erros + ",3" .                */
/*     END.                                                                           */
/*     IF tt-agw.tipo-movto = "C" AND                                               */
/*        tt-agw.cod-portador-at <> INT(INPUT FRAME fPage0 f-cod-portador-credito)  */
/*     THEN DO:                                                                       */
/*         ASSIGN tt-agw.flags-erros = tt-agw.flags-erros + ",4" .                */
/*     END.                                                                           */
/*     IF tt-agw.dt-venciment <> tt-agw.dt-venciment-at THEN DO:                  */
/*         ASSIGN tt-agw.flags-erros = tt-agw.flags-erros + ",5" .                */
/*     END.                                                                           */
/*                                                                                    */
/*     ASSIGN tt-agw.flags-erros = SUBSTRING(tt-agw.flags-erros , 2) .            */
/*     IF tt-agw.flags-erros <> "" THEN DO:                                         */
/*         ASSIGN f-tot-erros = f-tot-erros + 1 .                                     */
/*     END.                                                                           */
/*     ELSE DO:                                                                       */
/*         ASSIGN f-tot-serros = f-tot-serros + 1 .                                   */
/*     END.                                                                           */
/* END.                                                                               */

/**/
RETURN "OK":U .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-goPage2 wWindow 
PROCEDURE pi-goPage2 :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
/* DEF VAR h-acomp AS HANDLE NO-UNDO .                                                            */
/* RUN utp/ut-acomp.p PERSISTENT SET h-acomp .                                                    */
/* RUN pi-inicializar IN h-acomp (INPUT "Processando") .                                          */
/* RUN pi-acompanhar IN h-acomp (INPUT "Gravando Alteraá‰es...") .                                */
/*                                                                                                */
/* FOR EACH tt-agw                                                                              */
/*     :                                                                                          */
/*     IF INPUT FRAME fPage2 tg-erro-1 = YES AND                                                  */
/*        LOOKUP('1' , tt-agw.flags-erros) > 0                                                  */
/*     THEN DO:                                                                                   */
/*         FIND FIRST cst-fat-duplic WHERE                                                        */
/*             ROWID(cst-fat-duplic) = tt-agw.r-rowid-cst-fat-duplic                            */
/*             .                                                                                  */
/*         ASSIGN cst-fat-duplic.taxa-admin = tt-agw.taxa-admin .                               */
/*         ASSIGN tt-agw.taxa-admin-at = tt-agw.taxa-admin .                                  */
/*     END.                                                                                       */
/*     IF INPUT FRAME fPage2 tg-erro-2 = YES AND                                                  */
/*        LOOKUP('2' , tt-agw.flags-erros) > 0                                                  */
/*     THEN DO:                                                                                   */
/*         FIND FIRST fat-duplic WHERE                                                            */
/*             ROWID(fat-duplic) = tt-agw.r-rowid-fat-duplic                                    */
/*             .                                                                                  */
/*         ASSIGN fat-duplic.vl-parcela = tt-agw.vl-parcela-bruto .                             */
/*         ASSIGN tt-agw.vl-parcela-at = tt-agw.vl-parcela-bruto .                            */
/*     END.                                                                                       */
/*     IF INPUT FRAME fPage2 tg-erro-3 = YES AND                                                  */
/*        LOOKUP('3' , tt-agw.flags-erros) > 0                                                  */
/*     THEN DO:                                                                                   */
/*         FIND FIRST cst-fat-duplic WHERE                                                        */
/*             ROWID(cst-fat-duplic) = tt-agw.r-rowid-cst-fat-duplic                            */
/*             .                                                                                  */
/*         ASSIGN cst-fat-duplic.cod-portador = INT(INPUT FRAME fPage0 f-cod-portador-debito) .   */
/*         ASSIGN tt-agw.cod-portador-at = INT(INPUT FRAME fPage0 f-cod-portador-debito).       */
/*     END.                                                                                       */
/*     IF INPUT FRAME fPage2 tg-erro-4 = YES AND                                                  */
/*        LOOKUP('4' , tt-agw.flags-erros) > 0                                                  */
/*     THEN DO:                                                                                   */
/*         FIND FIRST cst-fat-duplic WHERE                                                        */
/*             ROWID(cst-fat-duplic) = tt-agw.r-rowid-cst-fat-duplic                            */
/*             .                                                                                  */
/*         ASSIGN cst-fat-duplic.cod-portador = INT(INPUT FRAME fPage0 f-cod-portador-credito) .  */
/*         ASSIGN tt-agw.cod-portador-at = INT(INPUT FRAME fPage0 f-cod-portador-credito).      */
/*     END.                                                                                       */
/*     IF INPUT FRAME fPage2 tg-erro-5 = YES AND                                                  */
/*        LOOKUP('5' , tt-agw.flags-erros) > 0                                                  */
/*     THEN DO:                                                                                   */
/*         FIND FIRST fat-duplic WHERE                                                            */
/*             ROWID(fat-duplic) = tt-agw.r-rowid-fat-duplic                                    */
/*             .                                                                                  */
/*         ASSIGN fat-duplic.dt-venciment = tt-agw.dt-venciment .                               */
/*         ASSIGN tt-agw.dt-venciment-at = tt-agw.dt-venciment .                              */
/*     END.                                                                                       */
/* END.                                                                                           */
/*                                                                                                */
/* RUN pi-goPage0-valida-agw .                                                                  */
/*                                                                                                */
/* /**/                                                                                           */
/* FOR EACH tt-agw                                                                              */
/*     WHERE tt-agw.flags-erros = ""                                                            */
/*     :                                                                                          */
/*     FIND FIRST cst-fat-duplic WHERE                                                            */
/*         ROWID(cst-fat-duplic) = tt-agw.r-rowid-cst-fat-duplic                                */
/*         .                                                                                      */
/*     ASSIGN cst-fat-duplic.conciliado-agw = YES .                                             */
/*     ASSIGN tt-agw.conciliado-agw = YES .                                                   */
/* END.                                                                                           */
/*                                                                                                */
/* ASSIGN f-tot-conciliados = 0 .                                                                 */
/* ASSIGN f-tot-nconciliados = 0 .                                                                */
/* FOR EACH tt-agw NO-LOCK                                                                      */
/*     :                                                                                          */
/*     IF tt-agw.conciliado-agw = YES THEN DO:                                                */
/*         ASSIGN f-tot-conciliados = f-tot-conciliados + 1 .                                     */
/*     END.                                                                                       */
/*     ELSE DO:                                                                                   */
/*         ASSIGN f-tot-nconciliados = f-tot-nconciliados + 1 .                                   */
/*     END.                                                                                       */
/* END.                                                                                           */
/* /**/                                                                                           */
/*                                                                                                */
/*                                                                                                */
/*                                                                                                */
/* DISPLAY                                                                                        */
/*     f-tot-conciliados                                                                          */
/*     f-tot-nconciliados                                                                         */
/*     f-tot-erros                                                                                */
/*     f-tot-serros                                                                               */
/*     WITH FRAME fPage2 .                                                                        */
/*                                                                                                */
/* {&open-query-brTable2}                                                                         */
/*                                                                                                */
/* /**/                                                                                           */
/* RUN pi-finalizar IN h-acomp.                                                                   */
RETURN "OK":U .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE piGeraTituloAPB_Conciliador wWindow 
PROCEDURE piGeraTituloAPB_Conciliador :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
DEFINE VARIABLE c_CodTitAp   AS CHARACTER   NO-UNDO.
DEFINE VARIABLE c_CodParcela AS INTEGER     NO-UNDO.
DEFINE VARIABLE c_CodRefer   AS CHARACTER   NO-UNDO.

ASSIGN c_CodTitAp = STRING(pOVencimento,"99999999"). 

FIND LAST tit_ap USE-INDEX titap_id NO-LOCK
     WHERE tit_ap.cod_estab        = pOEstab
       AND tit_ap.cdn_fornecedor   = pOFornec
       AND tit_ap.cod_espec_docto  = "CO"
       AND tit_ap.cod_ser_docto    = ""
       AND tit_ap.cod_tit_ap       = c_CodTitAp NO-ERROR.
IF AVAIL tit_ap THEN DO:
    ASSIGN c_CodParcela = INT(tit_ap.cod_parcela) + 1.
END.
ELSE DO:
    ASSIGN c_CodParcela = 1.
END.

RUN pi_retorna_sugestao_referencia (INPUT  "CO",
                                    INPUT  TODAY,
                                    OUTPUT c_CodRefer,
                                    INPUT  "tit_ap",
                                    INPUT  STRING(pOEstab)).

CREATE tt_integr_apb_lote_impl.
ASSIGN tt_integr_apb_lote_impl.tta_cod_estab = pOEstab
       tt_integr_apb_lote_impl.tta_cod_refer = c_CodRefer
       tt_integr_apb_lote_impl.tta_cod_espec_docto = ''
       tt_integr_apb_lote_impl.tta_dat_transacao = pOEmissao
       tt_integr_apb_lote_impl.tta_ind_origin_tit_ap = 'APB'
       tt_integr_apb_lote_impl.tta_cod_estab_ext = ''
       tt_integr_apb_lote_impl.tta_val_tot_lote_impl_tit_ap = INPUT FRAME fPage2 f-vl-tot-nao-conciliados
       tt_integr_apb_lote_impl.tta_cod_empresa = '001'
       tt_integr_apb_lote_impl.ttv_cod_empresa_ext = ''
       tt_integr_apb_lote_impl.tta_cod_finalid_econ_ext = ''
       tt_integr_apb_lote_impl.tta_cod_indic_econ = ''
    .

CREATE tt_integr_apb_item_lote_impl3v.
ASSIGN tt_integr_apb_item_lote_impl3v.ttv_rec_integr_apb_lote_impl = RECID(tt_integr_apb_lote_impl)
    tt_integr_apb_item_lote_impl3v.tta_num_seq_refer = 1
    tt_integr_apb_item_lote_impl3v.tta_cdn_fornecedor = pOFornec
    tt_integr_apb_item_lote_impl3v.tta_cod_espec_docto = 'CO'
    tt_integr_apb_item_lote_impl3v.tta_cod_ser_docto = ''
    tt_integr_apb_item_lote_impl3v.tta_cod_tit_ap = c_CodTitAp
    tt_integr_apb_item_lote_impl3v.tta_cod_parcela = STRING(c_CodParcela,"99")
    tt_integr_apb_item_lote_impl3v.tta_dat_emis_docto = pOEmissao
    tt_integr_apb_item_lote_impl3v.tta_dat_vencto_tit_ap = pOVencimento
    tt_integr_apb_item_lote_impl3v.tta_dat_prev_pagto = pOVencimento
    tt_integr_apb_item_lote_impl3v.tta_dat_desconto = ?
    tt_integr_apb_item_lote_impl3v.tta_cod_indic_econ = 'Real'
    tt_integr_apb_item_lote_impl3v.tta_val_tit_ap = INPUT FRAME fPage2 f-vl-tot-nao-conciliados
    tt_integr_apb_item_lote_impl3v.tta_val_desconto = 0
    tt_integr_apb_item_lote_impl3v.tta_val_perc_desc = 0
    tt_integr_apb_item_lote_impl3v.tta_num_dias_atraso = 0
    tt_integr_apb_item_lote_impl3v.tta_val_juros_dia_atraso = 0
    tt_integr_apb_item_lote_impl3v.tta_val_perc_juros_dia_atraso = 0
    tt_integr_apb_item_lote_impl3v.tta_val_perc_multa_atraso = 0
    tt_integr_apb_item_lote_impl3v.tta_cod_portador = '99901'
    tt_integr_apb_item_lote_impl3v.tta_cod_apol_seguro = ''
    tt_integr_apb_item_lote_impl3v.tta_cod_seguradora = ''
    tt_integr_apb_item_lote_impl3v.tta_cod_arrendador = ''
    tt_integr_apb_item_lote_impl3v.tta_cod_contrat_leas = ''
    tt_integr_apb_item_lote_impl3v.tta_des_text_histor = ''
    tt_integr_apb_item_lote_impl3v.tta_num_id_tit_ap = 0
    tt_integr_apb_item_lote_impl3v.tta_num_id_movto_tit_ap = 0
    tt_integr_apb_item_lote_impl3v.tta_num_id_movto_cta_corren = 0
    tt_integr_apb_item_lote_impl3v.ttv_qtd_parc_tit_ap = 1
    tt_integr_apb_item_lote_impl3v.ttv_num_dias = 0
    tt_integr_apb_item_lote_impl3v.ttv_ind_vencto_previs = 'Màs'
    tt_integr_apb_item_lote_impl3v.ttv_log_gerad = NO
    tt_integr_apb_item_lote_impl3v.tta_cod_finalid_econ_ext = ''
    tt_integr_apb_item_lote_impl3v.tta_cod_portad_ext = ''
    tt_integr_apb_item_lote_impl3v.tta_cod_modalid_ext = ''
    tt_integr_apb_item_lote_impl3v.tta_cod_cart_bcia = ''
    tt_integr_apb_item_lote_impl3v.tta_cod_forma_pagto = 'BOL'
    tt_integr_apb_item_lote_impl3v.tta_val_cotac_indic_econ = 0
    tt_integr_apb_item_lote_impl3v.ttv_num_ord_invest = 0
    tt_integr_apb_item_lote_impl3v.tta_cod_livre_1 = ''
    tt_integr_apb_item_lote_impl3v.tta_cod_livre_2 = ''
    tt_integr_apb_item_lote_impl3v.tta_dat_livre_1 = ?
    tt_integr_apb_item_lote_impl3v.tta_dat_livre_2 = ?
    tt_integr_apb_item_lote_impl3v.tta_log_livre_1 = no
    tt_integr_apb_item_lote_impl3v.tta_log_livre_2 = no
    tt_integr_apb_item_lote_impl3v.tta_num_livre_1 = 0
    tt_integr_apb_item_lote_impl3v.tta_num_livre_2 = 0
    tt_integr_apb_item_lote_impl3v.tta_val_livre_1 = 0
    tt_integr_apb_item_lote_impl3v.tta_val_livre_2 = 0
    tt_integr_apb_item_lote_impl3v.ttv_rec_integr_apb_item_lote = RECID(tt_integr_apb_item_lote_impl3v)
    tt_integr_apb_item_lote_impl3v.ttv_val_1099 = 0
    tt_integr_apb_item_lote_impl3v.tta_cod_tax_ident_number = ''
    tt_integr_apb_item_lote_impl3v.tta_ind_tip_trans_1099 = 'Rendas'
    tt_integr_apb_item_lote_impl3v.ttv_ind_tip_cod_barra = ''
    tt_integr_apb_item_lote_impl3v.tta_cb4_tit_ap_bco_cobdor = ''
    tt_integr_apb_item_lote_impl3v.tta_cod_tit_ap_bco_cobdor = ''
.

CREATE tt_integr_apb_aprop_ctbl_pend.
ASSIGN 
     tt_integr_apb_aprop_ctbl_pend.ttv_rec_integr_apb_item_lote = RECID(tt_integr_apb_item_lote_impl3v)
     tt_integr_apb_aprop_ctbl_pend.ttv_rec_antecip_pef_pend = ?
     tt_integr_apb_aprop_ctbl_pend.ttv_rec_integr_apb_impto_pend = 0
     tt_integr_apb_aprop_ctbl_pend.tta_cod_plano_cta_ctbl = 'PADRAO'
     tt_integr_apb_aprop_ctbl_pend.tta_cod_cta_ctbl = '21106100'
     tt_integr_apb_aprop_ctbl_pend.tta_cod_unid_negoc = '000'
     tt_integr_apb_aprop_ctbl_pend.tta_cod_plano_ccusto = ''
     tt_integr_apb_aprop_ctbl_pend.tta_cod_ccusto = ''
     tt_integr_apb_aprop_ctbl_pend.tta_cod_tip_fluxo_financ = '399'
     tt_integr_apb_aprop_ctbl_pend.tta_val_aprop_ctbl = INPUT FRAME fPage2 f-vl-tot-nao-conciliados
     tt_integr_apb_aprop_ctbl_pend.tta_cod_pais = ''
     tt_integr_apb_aprop_ctbl_pend.tta_cod_unid_federac = ''
     tt_integr_apb_aprop_ctbl_pend.tta_cod_imposto = ''
     tt_integr_apb_aprop_ctbl_pend.tta_cod_classif_impto = '00000'
     tt_integr_apb_aprop_ctbl_pend.ttv_cod_tip_fluxo_financ_ext = ''
     tt_integr_apb_aprop_ctbl_pend.tta_cod_cta_ctbl_ext = ''
     tt_integr_apb_aprop_ctbl_pend.tta_cod_sub_cta_ctbl_ext = ''
     tt_integr_apb_aprop_ctbl_pend.tta_cod_ccusto_ext = ''
     tt_integr_apb_aprop_ctbl_pend.tta_cod_unid_negoc_ext = ''
    .

run prgfin/apb/apb900zg.py persistent set v_hdl_aux.
run pi_main_block_api_tit_ap_cria_9 in v_hdl_aux (input 9,
                                                  input "EMS",
                                                  input-output table tt_integr_apb_item_lote_impl3v,
                                                  input-output table tt_params_generic_api,
                                                  input table tt_integr_apb_relacto_pend_aux,
                                                  input table tt_integr_apb_aprop_relacto_2,
                                                  input table tt_docum_est_esoc_api,
                                                  input table tt_item_doc_est_esoc_api,
                                                  input table tt_integr_apb_nota_pend_cart).

IF CAN-FIND(FIRST tt_log_erros_atualiz) THEN DO:
    FOR EACH tt_log_erros_atualiz NO-LOCK:
        CREATE tt-erro.
        ASSIGN tt-erro.i-sequen = tt_log_erros_atualiz.tta_num_seq_refer
               tt-erro.cd-erro  = tt_log_erros_atualiz.ttv_num_mensagem
               tt-erro.mensagem = tt_log_erros_atualiz.ttv_des_msg_erro + " - " + tt_log_erros_atualiz.ttv_des_msg_ajuda.
    END.


    IF CAN-FIND(FIRST tt-erro) THEN DO:
       RUN cdp/cd0666.w(INPUT TABLE tt-erro).
    END.
END.
ELSE DO:
    RUN utp/ut-msgs.p ("show" , "15825" , 
                       "Titulo Gerado com Sucesso." + 
                       STRING(pOEstab)               + "/" +      
                       STRING(pOFornec)   + "/" +
                       STRING("CO")  + "/" +
                       STRING("")    + "/" +
                       STRING(c_CodTitAp)       + "/" +
                       STRING(c_CodParcela,"99")
                       ). 

    FIND LAST tit_ap USE-INDEX titap_id NO-LOCK
         WHERE tit_ap.cod_estab        = pOEstab
           AND tit_ap.cdn_fornecedor   = pOFornec
           AND tit_ap.cod_espec_docto  = "CO"
           AND tit_ap.cod_ser_docto    = ""
           AND tit_ap.cod_tit_ap       = c_CodTitAp
           AND tit_ap.cod_parcela      = STRING(c_CodParcela,"99") NO-ERROR.
    IF AVAIL tit_ap THEN DO:

        FOR EACH tt-agw 
           WHERE tt-agw.conciliado-agw = NO:

            FIND FIRST cst_nota_copel EXCLUSIVE-LOCK
                 WHERE ROWID(cst_nota_copel) = tt-agw.r-rowid-cst_nota_copel NO-ERROR.
            IF AVAIL cst_nota_copel THEN DO:
                ASSIGN cst_nota_copel.log_conciliado   = YES
                       cst_nota_copel.cod_estab_tit_ap = tit_ap.cod_estab
                       cst_nota_copel.num_id_tit_ap    = tit_ap.num_id_tit_ap.

            END.
            RELEASE cst_nota_copel.
            
        END.

    END.

         

    APPLY "CHOOSE" TO btGoPage0 IN FRAME Fpage0.
END.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi_retorna_sugestao_referencia wWindow 
PROCEDURE pi_retorna_sugestao_referencia :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/



    /************************ Parameter Definition Begin ************************/

    def Input param p_ind_tip_atualiz
        as character
        format "X(08)"
        no-undo.
    def Input param p_dat_refer
        as date
        format "99/99/9999"
        no-undo.
    def output param p_cod_refer
        as character
        format "x(10)"
        no-undo.
    def Input param p_cod_table
        as character
        format "x(8)"
        no-undo.
    def input param p_estabel
        as character
        format "x(3)"
        no-undo.

    /************************* Parameter Definition End *************************/

    /************************* Variable Definition Begin ************************/

    def var v_des_dat                        as character       no-undo. /*local*/
    def var v_num_aux                        as integer         no-undo. /*local*/
    def var v_num_aux_2                      as integer         no-undo. /*local*/
    def var v_num_cont                       as integer         no-undo. /*local*/


    /************************** Variable Definition End *************************/

    assign v_des_dat   = string(p_dat_refer,"99999999")
           p_cod_refer = substring(p_ind_tip_atualiz,1,2)
                       + substring(v_des_dat,7,2)
                       + substring(v_des_dat,3,2)
/*                        + substring(v_des_dat,1,2) */
                       
           v_num_aux_2 = integer(this-procedure:handle).

    do  v_num_cont = 1 to 4:
        assign v_num_aux   = (random(0,v_num_aux_2) mod 26) + 97
               p_cod_refer = p_cod_refer + CAPS(chr(v_num_aux)).
    end.
    
    /*
    run pi_verifica_refer_unica_acr (Input p_estabel,
                                     Input p_cod_refer,
                                     Input p_cod_table,
                                     Input ?,
                                     output v_log_refer_uni) /*pi_verifica_refer_unica_acr*/.
      */

    ASSIGN v_log_refer_uni = YES.

    FIND FIRST movto_tit_ap NO-LOCK
        WHERE movto_tit_ap.cod_estab =  p_estabel
          AND movto_tit_ap.cod_refer =  p_cod_refer   NO-ERROR.

    IF AVAIL movto_tit_ap THEN v_log_refer_uni = NO.


    IF v_log_refer_uni = NO THEN
            run pi_retorna_sugestao_referencia (Input  "BP",
                                                Input  today,
                                                output p_cod_refer,
                                                Input  p_cod_table,
                                                input  p_estabel).

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi_verifica_refer_unica_acr wWindow 
PROCEDURE pi_verifica_refer_unica_acr :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    /************************ Parameter Definition Begin ************************/

    def Input param p_cod_estab
        as character
        format "x(3)"
        no-undo.
    def Input param p_cod_refer
        as character
        format "x(10)"
        no-undo.
    def Input param p_cod_table
        as character
        format "x(8)"
        no-undo.
    def Input param p_rec_tabela
        as recid
        format ">>>>>>9"
        no-undo.
    def output param p_log_refer_uni
        as logical
        format "Sim/Nío"
        no-undo.


    /************************* Parameter Definition End *************************/

    /************************** Buffer Definition Begin *************************/

    def buffer b_cobr_especial_acr
        for cobr_especial_acr.
    def buffer b_lote_impl_tit_acr
        for lote_impl_tit_acr.
    def buffer b_lote_liquidac_acr
        for lote_liquidac_acr.
    def buffer b_movto_tit_acr
        for movto_tit_acr.
    def buffer b_renegoc_acr
        for renegoc_acr.


    /*************************** Buffer Definition End **************************/

    /************************* Variable Definition Begin ************************/

    def var v_cod_return
        as character
        format "x(40)"
        no-undo.


    /************************** Variable Definition End *************************/

    assign p_log_refer_uni = yes.

    if  p_cod_table <> "lote_impl_tit_acr" /*l_lote_impl_tit_acr*/  then do:
        find first b_lote_impl_tit_acr no-lock
             where b_lote_impl_tit_acr.cod_estab = p_cod_estab
               and b_lote_impl_tit_acr.cod_refer = p_cod_refer
               and recid( b_lote_impl_tit_acr ) <> p_rec_tabela
             use-index ltmplttc_id no-error.
        if  avail b_lote_impl_tit_acr then
            assign p_log_refer_uni = no.
    end.

    if  p_cod_table <> "lote_liquidac_acr" /*l_lote_liquidac_acr*/  then do:
        find first b_lote_liquidac_acr no-lock
             where b_lote_liquidac_acr.cod_estab_refer = p_cod_estab
               and b_lote_liquidac_acr.cod_refer       = p_cod_refer
               and recid( b_lote_liquidac_acr )       <> p_rec_tabela
             use-index ltlqdccr_id no-error.
        if  avail b_lote_liquidac_acr then
            assign p_log_refer_uni = no.
    end.

    if  p_cod_table = 'cobr_especial_acr' then do:
        find first b_cobr_especial_acr no-lock
             where b_cobr_especial_acr.cod_estab = p_cod_estab
               and b_cobr_especial_acr.cod_refer = p_cod_refer
               and recid( b_cobr_especial_acr ) <> p_rec_tabela
             use-index cbrspclc_id no-error.
        if  avail b_cobr_especial_acr then
            assign p_log_refer_uni = no.
    end.

    if  p_log_refer_uni = yes then do:
        find first b_renegoc_acr no-lock
            where b_renegoc_acr.cod_estab = p_cod_estab
            and   b_renegoc_acr.cod_refer = p_cod_refer
            and   recid(b_renegoc_acr)   <> p_rec_tabela
            no-error.
        if  avail b_renegoc_acr then
            assign p_log_refer_uni = no.
        else do:
            find first b_movto_tit_acr no-lock
                 where b_movto_tit_acr.cod_estab = p_cod_estab
                   and b_movto_tit_acr.cod_refer = p_cod_refer
                   and recid(b_movto_tit_acr)   <> p_rec_tabela
                 use-index mvtttcr_refer
                 no-error.
            if  avail b_movto_tit_acr then
                assign p_log_refer_uni = no.
        end.
    end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

