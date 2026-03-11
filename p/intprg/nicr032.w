&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
*/
&Scoped-define WINDOW-NAME wWindow
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS wWindow 
/*
Author: JRA
Template Name: WWIN_FULLSCREEN
Template Library: CSTDDK
Template Version: 1.02
*/

CREATE WIDGET-POOL.

/* Preprocessors Definitions ---                                            */
&SCOPED-DEFINE Program              NICR032 /* Conciliacao Medme */
&SCOPED-DEFINE Version              1.00.00.001

&SCOPED-DEFINE Folder               YES
&SCOPED-DEFINE InitialPage          1
&SCOPED-DEFINE FolderLabels         Arquivo,Processados

&SCOPED-DEFINE WinQueryJoinsBtn     YES
&SCOPED-DEFINE WinReportsJoinsBtn   YES
&SCOPED-DEFINE WinExitBtn           YES
&SCOPED-DEFINE WinHelpBtn           YES

&SCOPED-DEFINE page0EnableWidgets   fi-data-inicial btGoPage0

&SCOPED-DEFINE page1EnableWidgets   brTable1 tg-encontrados tg-nencontrados

&SCOPED-DEFINE page2EnableWidgets   brTable2 tg-conciliados tg-nconciliados ~
                                    tg-at-acr tg-nat-acr ~
                                    tg-erros tg-serros ~
                                    tg-erro-1 tg-erro-2 tg-erro-3 tg-erro-4 tg-erro-5 ~
                                    btGoPage2
     
/* Datasul ERP Includes                                                     */
{include/i-prgvrs.i {&Program} {&Version}}

/* Template Includes                                                        */
{cstddk/include/wWinDefinitions.i}

/* ***************************  Definitions  ***************************    */
FUNCTION fnFormatDate RETURNS DATE
    (INPUT p-char AS CHAR)
    :
    RETURN DATE( INT(SUBSTRING(p-char,6,2)) , INT(SUBSTRING(p-char,9,2)) , INT(SUBSTRING(p-char,1,4))) .
END FUNCTION .


DEF BUFFER portador FOR ems5.portador.

DEF TEMP-TABLE tt-arq-sitef NO-UNDO
    FIELD linha             AS INT FORMAT ">>>>>>>>9" LABEL "Linha"
    FIELD cod_estabel       LIKE cst_fat_duplic.cod_estabel
    FIELD nr_fatura         LIKE cst_fat_duplic.nr_fatura  
    FIELD serie             AS CHAR
    FIELD parcela           LIKE cst_fat_duplic.parcela
    FIELD id-convenio       AS CHAR FORMAT "x(12)" LABEL "ID Convenio"
    FIELD tipo-movto        AS CHAR LABEL "Tp"
    FIELD origem-venda      AS CHAR
    FIELD taxa_admin        LIKE cst_fat_duplic.taxa_admin 
    FIELD vl_parcela-liq    LIKE fat-duplic.vl-parcela COLUMN-LABEL "Vl Parcela Liq" 
    FIELD vl_parcela-bruto  LIKE fat-duplic.vl-parcela COLUMN-LABEL "Vl Parcela Bruto" 
    FIELD dt-venciment      LIKE fat-duplic.dt-venciment
    FIELD l-fat-duplic      AS LOGICAL COLUMN-LABEL "Existe TOTVS"
    .

DEF TEMP-TABLE tt-sitef NO-UNDO LIKE tt-arq-sitef
    FIELD r-rowid-cst_fat_duplic    AS ROWID
    FIELD r-rowid-fat-duplic        AS ROWID
    FIELD cod-portador-at   LIKE cst_fat_duplic.cod_portador COLUMN-LABEL "Portador T"
    FIELD parcela-at        LIKE fat-duplic.parcela COLUMN-LABEL "Pa T" 
    FIELD vl_parcela-at     LIKE fat-duplic.vl-parcela COLUMN-LABEL "Vl Parcela T" 
    FIELD taxa_admin-at     LIKE cst_fat_duplic.taxa_admin COLUMN-LABEL "Taxa T"
    FIELD dt-venciment-at   LIKE fat-duplic.dt-venciment COLUMN-LABEL "Vencimento T"
    FIELD conciliado-sitef  LIKE cst_fat_duplic.conciliado_sitef COLUMN-LABEL "Conciliado T"
    FIELD flag-atualiz      LIKE fat-duplic.flag-atualiz COLUMN-LABEL "At ACR"
    FIELD flags-erros       AS CHAR FORMAT "X(50)" COLUMN-LABEL "Erros"
    .

/* Parameters Definitions ---                                               */

/* Local Variable Definitions ---                                           */
DEF NEW GLOBAL SHARED VAR v_rec_portador AS RECID INITIAL ? NO-UNDO .

DEFINE TEMP-TABLE tt-venda-medme NO-UNDO
    FIELD id                    AS INT
    FIELD TOTAL                 AS DECIMAL
    FIELD invoice_coupom_number AS CHAR
    FIELD invoice_code          AS CHAR
    FIELD serie                 AS CHAR
    FIELD cpf                   AS CHAR
  //  FIELD company_name          AS CHAR
    FIELD seller_name           AS CHAR
    FIELD origin_site           AS CHAR
    FIELD DATE                  AS CHAR
    FIELD invoice_month_year    AS CHAR.

DEFINE TEMP-TABLE payments_summary NO-UNDO
    FIELD order_id              AS INT
    FIELD METHOD                AS CHAR
    FIELD installment_number    AS INT
    FIELD subtotal              AS DECIMAL
    FIELD DATE                  AS CHAR.

DEFINE DATASET dsMedme FOR tt-venda-medme, payments_summary
    DATA-RELATION id FOR tt-venda-medme, payments_summary
    RELATION-FIELDS(id, order_id ).

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
&Scoped-define INTERNAL-TABLES tt-arq-sitef tt-sitef

/* Definitions for BROWSE brTable1                                      */
&Scoped-define FIELDS-IN-QUERY-brTable1 tt-arq-sitef.linha tt-arq-sitef.id-convenio tt-arq-sitef.cod_estabel tt-arq-sitef.nr_fatura tt-arq-sitef.serie tt-arq-sitef.parcela tt-arq-sitef.tipo-movto tt-arq-sitef.origem-venda tt-arq-sitef.vl_parcela-bruto tt-arq-sitef.dt-venciment tt-arq-sitef.l-fat-duplic   
&Scoped-define ENABLED-FIELDS-IN-QUERY-brTable1   
&Scoped-define SELF-NAME brTable1
&Scoped-define QUERY-STRING-brTable1 FOR EACH tt-arq-sitef NO-LOCK     WHERE (tt-arq-sitef.l-fat-duplic = YES AND INPUT FRAME fPage1 tg-encontrados = YES OR            tt-arq-sitef.l-fat-duplic = NO AND INPUT FRAME fPage1 tg-nencontrados = YES )     INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-brTable1 OPEN QUERY {&SELF-NAME} FOR EACH tt-arq-sitef NO-LOCK     WHERE (tt-arq-sitef.l-fat-duplic = YES AND INPUT FRAME fPage1 tg-encontrados = YES OR            tt-arq-sitef.l-fat-duplic = NO AND INPUT FRAME fPage1 tg-nencontrados = YES )     INDEXED-REPOSITION .
&Scoped-define TABLES-IN-QUERY-brTable1 tt-arq-sitef
&Scoped-define FIRST-TABLE-IN-QUERY-brTable1 tt-arq-sitef


/* Definitions for BROWSE brTable2                                      */
&Scoped-define FIELDS-IN-QUERY-brTable2 tt-sitef.linha tt-sitef.id-convenio tt-sitef.cod_estabel tt-sitef.nr_fatura tt-sitef.serie tt-sitef.parcela tt-sitef.tipo-movto tt-sitef.origem-venda tt-sitef.cod-portador-at tt-sitef.vl_parcela-bruto tt-sitef.vl_parcela-at tt-sitef.dt-venciment tt-sitef.dt-venciment-at tt-sitef.flag-atualiz tt-sitef.flags-erros   
&Scoped-define ENABLED-FIELDS-IN-QUERY-brTable2   
&Scoped-define SELF-NAME brTable2
&Scoped-define QUERY-STRING-brTable2 FOR EACH tt-sitef NO-LOCK     WHERE (tt-sitef.conciliado-sitef = YES AND INPUT FRAME fPage2 tg-conciliados = YES OR            tt-sitef.conciliado-sitef = NO AND INPUT FRAME fPage2 tg-nconciliados = YES )     AND   (tt-sitef.flag-atualiz = YES AND INPUT FRAME fPage2 tg-at-acr = YES OR            tt-sitef.flag-atualiz = NO AND INPUT FRAME fPage2 tg-nat-acr = YES )     AND   ((tt-sitef.flags-erros <> "" AND INPUT FRAME fPage2 tg-erros = YES AND               (LOOKUP('1' , ~
       tt-sitef.flags-erros) > 0 AND INPUT FRAME fPage2 tg-erro-1 = YES) OR               (LOOKUP('2' , ~
       tt-sitef.flags-erros) > 0 AND INPUT FRAME fPage2 tg-erro-2 = YES) OR               (LOOKUP('3' , ~
       tt-sitef.flags-erros) > 0 AND INPUT FRAME fPage2 tg-erro-3 = YES) OR               (LOOKUP('4' , ~
       tt-sitef.flags-erros) > 0 AND INPUT FRAME fPage2 tg-erro-4 = YES) OR               (LOOKUP('5' , ~
       tt-sitef.flags-erros) > 0 AND INPUT FRAME fPage2 tg-erro-5 = YES)              ) OR            tt-sitef.flags-erros = "" AND INPUT FRAME fPage2 tg-serros = YES           )     INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-brTable2 OPEN QUERY {&SELF-NAME} FOR EACH tt-sitef NO-LOCK     WHERE (tt-sitef.conciliado-sitef = YES AND INPUT FRAME fPage2 tg-conciliados = YES OR            tt-sitef.conciliado-sitef = NO AND INPUT FRAME fPage2 tg-nconciliados = YES )     AND   (tt-sitef.flag-atualiz = YES AND INPUT FRAME fPage2 tg-at-acr = YES OR            tt-sitef.flag-atualiz = NO AND INPUT FRAME fPage2 tg-nat-acr = YES )     AND   ((tt-sitef.flags-erros <> "" AND INPUT FRAME fPage2 tg-erros = YES AND               (LOOKUP('1' , ~
       tt-sitef.flags-erros) > 0 AND INPUT FRAME fPage2 tg-erro-1 = YES) OR               (LOOKUP('2' , ~
       tt-sitef.flags-erros) > 0 AND INPUT FRAME fPage2 tg-erro-2 = YES) OR               (LOOKUP('3' , ~
       tt-sitef.flags-erros) > 0 AND INPUT FRAME fPage2 tg-erro-3 = YES) OR               (LOOKUP('4' , ~
       tt-sitef.flags-erros) > 0 AND INPUT FRAME fPage2 tg-erro-4 = YES) OR               (LOOKUP('5' , ~
       tt-sitef.flags-erros) > 0 AND INPUT FRAME fPage2 tg-erro-5 = YES)              ) OR            tt-sitef.flags-erros = "" AND INPUT FRAME fPage2 tg-serros = YES           )     INDEXED-REPOSITION .
&Scoped-define TABLES-IN-QUERY-brTable2 tt-sitef
&Scoped-define FIRST-TABLE-IN-QUERY-brTable2 tt-sitef


/* Definitions for FRAME fPage1                                         */

/* Definitions for FRAME fPage2                                         */

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS rtToolBar btQueryJoins btReportsJoins btExit ~
btHelp btGoPage0 fi-data-inicial 
&Scoped-Define DISPLAYED-OBJECTS fi-data-inicial 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD numeros wWindow 
FUNCTION numeros RETURNS LOGICAL
  ( INPUT texto AS CHARACTER)  FORWARD.

/* _UIB-CODE-BLOCK-END */
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

DEFINE VARIABLE fi-data-inicial AS DATE FORMAT "99/99/9999":U 
     LABEL "Data Concilia‡Æo" 
     VIEW-AS FILL-IN 
     SIZE 10.57 BY .79 NO-UNDO.

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
     LABEL "NÆo Encontrados" 
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
     LABEL "Gravar Corre‡äes" 
     SIZE 15 BY 1.

DEFINE VARIABLE f-tot-at-acr AS INTEGER FORMAT ">>>,>>>,>>9":U INITIAL 0 
     LABEL "At ACR" 
     VIEW-AS FILL-IN 
     SIZE 10 BY .88 NO-UNDO.

DEFINE VARIABLE f-tot-conciliados AS INTEGER FORMAT ">>>,>>>,>>9":U INITIAL 0 
     LABEL "Conciliados" 
     VIEW-AS FILL-IN 
     SIZE 10 BY .88 NO-UNDO.

DEFINE VARIABLE f-tot-erros AS INTEGER FORMAT ">>>,>>>,>>9":U INITIAL 0 
     LABEL "Com Erros" 
     VIEW-AS FILL-IN 
     SIZE 10 BY .88 NO-UNDO.

DEFINE VARIABLE f-tot-faturas AS INTEGER FORMAT ">>>,>>>,>>9":U INITIAL 0 
     LABEL "Tot Faturas" 
     VIEW-AS FILL-IN 
     SIZE 10 BY .88 NO-UNDO.

DEFINE VARIABLE f-tot-nat-acr AS INTEGER FORMAT ">>>,>>>,>>9":U INITIAL 0 
     LABEL "NÆo At ACR" 
     VIEW-AS FILL-IN 
     SIZE 10 BY .88 NO-UNDO.

DEFINE VARIABLE f-tot-nconciliados AS INTEGER FORMAT ">>>,>>>,>>9":U INITIAL 0 
     LABEL "NÆo Conciliados" 
     VIEW-AS FILL-IN 
     SIZE 10 BY .88 NO-UNDO.

DEFINE VARIABLE f-tot-serros AS INTEGER FORMAT ">>>,>>>,>>9":U INITIAL 0 
     LABEL "Sem Erros" 
     VIEW-AS FILL-IN 
     SIZE 10 BY .88 NO-UNDO.

DEFINE RECTANGLE rt-2
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 114 BY 3.25
     BGCOLOR 7 .

DEFINE VARIABLE tg-at-acr AS LOGICAL INITIAL yes 
     LABEL "" 
     VIEW-AS TOGGLE-BOX
     SIZE 3 BY .88 NO-UNDO.

DEFINE VARIABLE tg-conciliados AS LOGICAL INITIAL yes 
     LABEL "" 
     VIEW-AS TOGGLE-BOX
     SIZE 3 BY .88 NO-UNDO.

DEFINE VARIABLE tg-erro-1 AS LOGICAL INITIAL yes 
     LABEL "Erro 1 - Valor Taxa" 
     VIEW-AS TOGGLE-BOX
     SIZE 16 BY .88 NO-UNDO.

DEFINE VARIABLE tg-erro-2 AS LOGICAL INITIAL yes 
     LABEL "Erro 2 - Valor Parcela" 
     VIEW-AS TOGGLE-BOX
     SIZE 17.14 BY .88 NO-UNDO.

DEFINE VARIABLE tg-erro-3 AS LOGICAL INITIAL yes 
     LABEL "Erro 3 - Portador DB" 
     VIEW-AS TOGGLE-BOX
     SIZE 16 BY .88 NO-UNDO.

DEFINE VARIABLE tg-erro-4 AS LOGICAL INITIAL yes 
     LABEL "Erro 4 - Portador CR" 
     VIEW-AS TOGGLE-BOX
     SIZE 17.14 BY .88 NO-UNDO.

DEFINE VARIABLE tg-erro-5 AS LOGICAL INITIAL yes 
     LABEL "Erro 5 - Dt Vencto" 
     VIEW-AS TOGGLE-BOX
     SIZE 16 BY .88 NO-UNDO.

DEFINE VARIABLE tg-erros AS LOGICAL INITIAL yes 
     LABEL "" 
     VIEW-AS TOGGLE-BOX
     SIZE 3 BY .88 NO-UNDO.

DEFINE VARIABLE tg-nat-acr AS LOGICAL INITIAL yes 
     LABEL "" 
     VIEW-AS TOGGLE-BOX
     SIZE 3 BY .88 NO-UNDO.

DEFINE VARIABLE tg-nconciliados AS LOGICAL INITIAL yes 
     LABEL "" 
     VIEW-AS TOGGLE-BOX
     SIZE 3 BY .88 NO-UNDO.

DEFINE VARIABLE tg-serros AS LOGICAL INITIAL yes 
     LABEL "" 
     VIEW-AS TOGGLE-BOX
     SIZE 3 BY .88 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY brTable1 FOR 
      tt-arq-sitef SCROLLING.

DEFINE QUERY brTable2 FOR 
      tt-sitef SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE brTable1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS brTable1 wWindow _FREEFORM
  QUERY brTable1 DISPLAY
      tt-arq-sitef.linha  
 tt-arq-sitef.id-convenio
 tt-arq-sitef.cod_estabel      
 tt-arq-sitef.nr_fatura  
 tt-arq-sitef.serie
 tt-arq-sitef.parcela   
 tt-arq-sitef.tipo-movto        COLUMN-LABEL "MEDME C Pagto"
 tt-arq-sitef.origem-venda      COLUMN-LABEL "MEDME C Pagto"
 tt-arq-sitef.vl_parcela-bruto  COLUMN-LABEL "MEDME Origem venda"
 tt-arq-sitef.dt-venciment      COLUMN-LABEL "MEDME DT Venc"
 tt-arq-sitef.l-fat-duplic VIEW-AS TOGGLE-BOX
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 114 BY 14.5
         FONT 1.

DEFINE BROWSE brTable2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS brTable2 wWindow _FREEFORM
  QUERY brTable2 DISPLAY
      tt-sitef.linha       
 tt-sitef.id-convenio   
 tt-sitef.cod_estabel      
 tt-sitef.nr_fatura 
 tt-sitef.serie
 tt-sitef.parcela   
 tt-sitef.tipo-movto        COLUMN-LABEL "MEDME C Pagto"
 tt-sitef.origem-venda      COLUMN-LABEL "MEDME Orig Venda"
 tt-sitef.cod-portador-at   COLUMN-LABEL "TOTVS Portador"
 tt-sitef.vl_parcela-bruto  COLUMN-LABEL "MEDME Valor"
 tt-sitef.vl_parcela-at     COLUMN-LABEL "TOTVS Valor"
 tt-sitef.dt-venciment      COLUMN-LABEL "MEDME DT Venc"
 tt-sitef.dt-venciment-at   COLUMN-LABEL "TOTVS DT Venc"
 tt-sitef.flag-atualiz VIEW-AS TOGGLE-BOX
 tt-sitef.flags-erros
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 114 BY 12.75
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
     btGoPage0 AT ROW 2.71 COL 111 WIDGET-ID 14
     fi-data-inicial AT ROW 3 COL 14.43 COLON-ALIGNED WIDGET-ID 38
     rtToolBar AT ROW 1 COL 1
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 120 BY 22
         FONT 1 WIDGET-ID 100.

DEFINE FRAME fPage2
     brTable2 AT ROW 1 COL 1 WIDGET-ID 200
     f-tot-faturas AT ROW 14.17 COL 9 COLON-ALIGNED WIDGET-ID 54
     f-tot-conciliados AT ROW 14.17 COL 33 COLON-ALIGNED WIDGET-ID 50
     tg-conciliados AT ROW 14.17 COL 46 WIDGET-ID 56
     f-tot-nconciliados AT ROW 14.17 COL 61 COLON-ALIGNED WIDGET-ID 52
     tg-nconciliados AT ROW 14.17 COL 74 WIDGET-ID 58
     tg-erro-1 AT ROW 14.17 COL 79 WIDGET-ID 80
     tg-erro-2 AT ROW 14.17 COL 97 WIDGET-ID 82
     f-tot-at-acr AT ROW 15.17 COL 33 COLON-ALIGNED WIDGET-ID 68
     tg-at-acr AT ROW 15.17 COL 46 WIDGET-ID 72
     f-tot-nat-acr AT ROW 15.17 COL 61 COLON-ALIGNED WIDGET-ID 70
     tg-nat-acr AT ROW 15.17 COL 74 WIDGET-ID 74
     tg-erro-3 AT ROW 15.17 COL 79 WIDGET-ID 84
     tg-erro-4 AT ROW 15.17 COL 97 WIDGET-ID 86
     btGoPage2 AT ROW 15.75 COL 2.43 WIDGET-ID 90
     f-tot-erros AT ROW 16.17 COL 33 COLON-ALIGNED WIDGET-ID 64
     tg-erros AT ROW 16.17 COL 46 WIDGET-ID 66
     f-tot-serros AT ROW 16.17 COL 61 COLON-ALIGNED WIDGET-ID 76
     tg-serros AT ROW 16.17 COL 74 WIDGET-ID 78
     tg-erro-5 AT ROW 16.17 COL 79 WIDGET-ID 88
     rt-2 AT ROW 14 COL 1 WIDGET-ID 48
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 3.57 ROW 6.15
         SIZE 115 BY 16.5
         FONT 1 WIDGET-ID 300.

DEFINE FRAME fPage1
     brTable1 AT ROW 1.25 COL 1 WIDGET-ID 200
     f-tot-linhas AT ROW 16.25 COL 9 COLON-ALIGNED WIDGET-ID 54
     f-tot-encontrados AT ROW 16.25 COL 30 COLON-ALIGNED WIDGET-ID 50
     tg-encontrados AT ROW 16.25 COL 43 WIDGET-ID 56
     f-tot-nencontrados AT ROW 16.25 COL 58 COLON-ALIGNED WIDGET-ID 52
     tg-nencontrados AT ROW 16.25 COL 71 WIDGET-ID 58
     rt1 AT ROW 16 COL 1 WIDGET-ID 48
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 3.57 ROW 6.25
         SIZE 115.43 BY 16.42
         FONT 1 WIDGET-ID 100.


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
         HEIGHT             = 22
         WIDTH              = 120
         MAX-HEIGHT         = 320
         MAX-WIDTH          = 365.72
         VIRTUAL-HEIGHT     = 320
         VIRTUAL-WIDTH      = 365.72
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
/* SETTINGS FOR FRAME fPage1
                                                                        */
/* BROWSE-TAB brTable1 rt1 fPage1 */
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

/* SETTINGS FOR BUTTON btGoPage2 IN FRAME fPage2
   NO-ENABLE                                                            */
ASSIGN 
       btGoPage2:HIDDEN IN FRAME fPage2           = TRUE.

IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(wWindow)
THEN wWindow:HIDDEN = yes.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE brTable1
/* Query rebuild information for BROWSE brTable1
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH tt-arq-sitef NO-LOCK
    WHERE (tt-arq-sitef.l-fat-duplic = YES AND INPUT FRAME fPage1 tg-encontrados = YES OR
           tt-arq-sitef.l-fat-duplic = NO AND INPUT FRAME fPage1 tg-nencontrados = YES )
    INDEXED-REPOSITION .
     _END_FREEFORM
     _Query            is NOT OPENED
*/  /* BROWSE brTable1 */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE brTable2
/* Query rebuild information for BROWSE brTable2
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH tt-sitef NO-LOCK
    WHERE (tt-sitef.conciliado-sitef = YES AND INPUT FRAME fPage2 tg-conciliados = YES OR
           tt-sitef.conciliado-sitef = NO AND INPUT FRAME fPage2 tg-nconciliados = YES )
    AND   (tt-sitef.flag-atualiz = YES AND INPUT FRAME fPage2 tg-at-acr = YES OR
           tt-sitef.flag-atualiz = NO AND INPUT FRAME fPage2 tg-nat-acr = YES )
    AND   ((tt-sitef.flags-erros <> "" AND INPUT FRAME fPage2 tg-erros = YES AND
              (LOOKUP('1' , tt-sitef.flags-erros) > 0 AND INPUT FRAME fPage2 tg-erro-1 = YES) OR
              (LOOKUP('2' , tt-sitef.flags-erros) > 0 AND INPUT FRAME fPage2 tg-erro-2 = YES) OR
              (LOOKUP('3' , tt-sitef.flags-erros) > 0 AND INPUT FRAME fPage2 tg-erro-3 = YES) OR
              (LOOKUP('4' , tt-sitef.flags-erros) > 0 AND INPUT FRAME fPage2 tg-erro-4 = YES) OR
              (LOOKUP('5' , tt-sitef.flags-erros) > 0 AND INPUT FRAME fPage2 tg-erro-5 = YES)
             ) OR
           tt-sitef.flags-erros = "" AND INPUT FRAME fPage2 tg-serros = YES
          )
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


&Scoped-define SELF-NAME btGoPage0
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btGoPage0 wWindow
ON CHOOSE OF btGoPage0 IN FRAME fpage0 /* Processar */
DO:

    RUN busca-dados-medme (INPUT FRAME fPage0 fi-data-inicial).
    RUN pi-goPage0 .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME fPage2
&Scoped-define SELF-NAME btGoPage2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btGoPage2 wWindow
ON CHOOSE OF btGoPage2 IN FRAME fPage2 /* Gravar Corre‡äes */
DO:
   // RUN pi-goPage2 .
   // RUN utp/ut-msgs.p ("show" , "15825" , "Dados Gravados com Sucesso.").
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
&Scoped-define SELF-NAME tg-at-acr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tg-at-acr wWindow
ON VALUE-CHANGED OF tg-at-acr IN FRAME fPage2
DO:
    {&open-query-brTable2}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


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
&Scoped-define SELF-NAME tg-erro-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tg-erro-1 wWindow
ON VALUE-CHANGED OF tg-erro-1 IN FRAME fPage2 /* Erro 1 - Valor Taxa */
DO:
    {&open-query-brTable2}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tg-erro-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tg-erro-2 wWindow
ON VALUE-CHANGED OF tg-erro-2 IN FRAME fPage2 /* Erro 2 - Valor Parcela */
DO:
    {&open-query-brTable2}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tg-erro-3
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tg-erro-3 wWindow
ON VALUE-CHANGED OF tg-erro-3 IN FRAME fPage2 /* Erro 3 - Portador DB */
DO:
    {&open-query-brTable2}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tg-erro-4
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tg-erro-4 wWindow
ON VALUE-CHANGED OF tg-erro-4 IN FRAME fPage2 /* Erro 4 - Portador CR */
DO:
    {&open-query-brTable2}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tg-erro-5
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tg-erro-5 wWindow
ON VALUE-CHANGED OF tg-erro-5 IN FRAME fPage2 /* Erro 5 - Dt Vencto */
DO:
    {&open-query-brTable2}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tg-erros
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tg-erros wWindow
ON VALUE-CHANGED OF tg-erros IN FRAME fPage2
DO:
    {&open-query-brTable2}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tg-nat-acr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tg-nat-acr wWindow
ON VALUE-CHANGED OF tg-nat-acr IN FRAME fPage2
DO:
    {&open-query-brTable2}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


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


&Scoped-define FRAME-NAME fPage2
&Scoped-define SELF-NAME tg-serros
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tg-serros wWindow
ON VALUE-CHANGED OF tg-serros IN FRAME fPage2
DO:
    {&open-query-brTable2}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME fpage0
&Scoped-define BROWSE-NAME brTable1
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK wWindow 


/**/
//f-cod-portador-credito:LOAD-MOUSE-POINTER("image/lupa.cur") IN FRAME fPage0 .

/*
ON 'F5':U , "MOUSE-SELECT-DBLCLICK":U OF f-cod-portador-credito IN FRAME fPage0
DO:
    RUN prgint/ufn/ufn008na.p(INPUT "001") .
    IF v_rec_portador <> ? THEN DO:
        FOR FIRST portador FIELDS(cod_portador nom_pessoa) NO-LOCK
            WHERE RECID(portador) = v_rec_portador
            :
            ASSIGN SELF:SCREEN-VALUE IN FRAME fPage0 = STRING(portador.cod_portador) .
            ASSIGN f-nom-portador-credito:SCREEN-VALUE IN FRAME fPage0 = portador.nom_pessoa .
        END.
    END.
END.
ON 'LEAVE':U OF f-cod-portador-credito IN FRAME fPage0
DO:
    ASSIGN f-nom-portador-credito:SCREEN-VALUE IN FRAME fPage0 = "" .
    FOR FIRST portador FIELDS(cod_portador nom_pessoa) NO-LOCK
        WHERE portador.cod_portador = SELF:SCREEN-VALUE
        :
        ASSIGN f-nom-portador-credito:SCREEN-VALUE IN FRAME fPage0 = portador.nom_pessoa .
    END.
END.

f-cod-portador-debito:LOAD-MOUSE-POINTER("image/lupa.cur") IN FRAME fPage0 .
ON 'F5':U , "MOUSE-SELECT-DBLCLICK":U OF f-cod-portador-debito IN FRAME fPage0
DO:
    RUN prgint/ufn/ufn008na.p(INPUT "001") .
    IF v_rec_portador <> ? THEN DO:
        FOR FIRST portador FIELDS(cod_portador nom_pessoa) NO-LOCK
            WHERE RECID(portador) = v_rec_portador
            :
            ASSIGN SELF:SCREEN-VALUE IN FRAME fPage0 = STRING(portador.cod_portador) .
            ASSIGN f-nom-portador-debito:SCREEN-VALUE IN FRAME fPage0 = portador.nom_pessoa .
        END.
    END.
END.
ON 'LEAVE':U OF f-cod-portador-debito IN FRAME fPage0
DO:
    ASSIGN f-nom-portador-debito:SCREEN-VALUE IN FRAME fPage0 = "" .
    FOR FIRST portador FIELDS(cod_portador nom_pessoa) NO-LOCK
        WHERE portador.cod_portador = SELF:SCREEN-VALUE
        :
        ASSIGN f-nom-portador-debito:SCREEN-VALUE IN FRAME fPage0 = portador.nom_pessoa .
    END.
END.
*/
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

ASSIGN fi-data-inicial:SCREEN-VALUE IN FRAME fpage0 = STRING(TODAY - 1 ).

/**/
RETURN "OK":U .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Busca-dados-medme wWindow 
PROCEDURE Busca-dados-medme :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    DEFINE INPUT PARAMETER da-dataConciliacao AS DATE.
    
    DEFINE VARIABLE chHttp    AS COM-HANDLE NO-UNDO.
    DEFINE VARIABLE c-token   AS CHARACTER  NO-UNDO.
    DEFINE VARIABLE chost     AS CHARACTER  NO-UNDO.
    DEFINE VARIABLE cUrl      AS CHARACTER  NO-UNDO.
    DEFINE VARIABLE c-alias   AS CHARACTER  NO-UNDO.
    DEFINE VARIABLE ljson     AS LONGCHAR   NO-UNDO.

    CREATE "MSXML2.XMLHTTP.6.0" chHttp .

    ASSIGN chost  = "https://medmefarmacias.com.br/".
    ASSIGN cUrl  = "/api/v1/get-orders-to-reconcile-by-period?dateStart=" + 
                          STRING(year(da-dataConciliacao)) + "-" + string(MONTH(da-dataConciliacao), "99") + "-" + string(DAY(da-dataConciliacao), "99") + 
                         "&dateEnd=" + 
                         STRING(year(da-dataConciliacao)) + "-" + string(MONTH(da-dataConciliacao), "99") + "-" + string(DAY(da-dataConciliacao), "99") .

    ASSIGN c-token =  "K90f75ef4544a24ded8c45a98728f366e34fa113a8f2e5c03ada116cc945006b48" .

    chHttp:OPEN("GET", cHost + cUrl) .
    chHttp:setRequestHeader("Authorization", "Bearer " + c-token).
    chHttp:SEND() .

    IF chHttp:responseText <> "" THEN DO:
                   
        ASSIGN ljson = "~{" + QUOTER("tt-venda-medme") + ":" + chHttp:responseText + "}" .
        DATASET dsMedme:READ-JSON("longchar",ljson).

    END.
    ELSE DO:
        MESSAGE " Erro ao conectar no servidor" 
            VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.

    END.      

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

DEFINE VARIABLE c-cnpj AS CHARACTER   NO-UNDO.

ASSIGN f-tot-linhas = 0 .
ASSIGN f-tot-encontrados = 0 .
ASSIGN f-tot-nencontrados = 0 .
EMPTY TEMP-TABLE tt-arq-sitef .
EMPTY TEMP-TABLE tt-sitef .


FOR EACH tt-venda-medme
    , EACH payments_summary
    WHERE payments_summary.order_id = tt-venda-medme.id:

    ASSIGN f-tot-linhas = f-tot-linhas + 1.

    FIND FIRST estabelec NO-LOCK
        WHERE estabelec.cgc = substring(tt-venda-medme.invoice_code,7, 14) NO-ERROR.

    CREATE tt-arq-sitef . 
    ASSIGN
        tt-arq-sitef.linha              = f-tot-linhas
        tt-arq-sitef.cod_estabel        = IF AVAIL estabelec THEN estabelec.cod-estabel ELSE substring(tt-venda-medme.invoice_code,7, 14)
        tt-arq-sitef.nr_fatura          = IF DEC(tt-venda-medme.invoice_coupom_number) < 9999999 THEN STRING(DEC(tt-venda-medme.invoice_coupom_number)  , "9999999") ELSE STRING(DEC(tt-venda-medme.invoice_coupom_number))
        tt-arq-sitef.serie              = string(int(substring(tt-venda-medme.invoice_code,23, 3)))
        tt-arq-sitef.parcela            = string(int(payments_summary.installment_number), "99").
        tt-arq-sitef.id-convenio        = string(payments_summary.order_id).
        tt-arq-sitef.tipo-movto         = payments_summary.METHOD .
        tt-arq-sitef.origem-venda       = tt-venda-medme.origin_site  .
        tt-arq-sitef.taxa_admin         = 0.
        tt-arq-sitef.vl_parcela-liq     = payments_summary.subtotal.
        tt-arq-sitef.vl_parcela-bruto   = payments_summary.subtotal.
        tt-arq-sitef.dt-venciment       = fnFormatDate(payments_summary.DATE).
        .



END.



RUN pi-acompanhar IN h-acomp (INPUT "Processando Arquivo... ") .

ASSIGN i-cont = 0 .
ASSIGN f-tot-faturas = 0 .
ASSIGN f-tot-conciliados = 0 .
ASSIGN f-tot-nconciliados = 0 .
ASSIGN f-tot-at-acr = 0 .
ASSIGN f-tot-nat-acr = 0 .
FOR EACH tt-arq-sitef
    :
    ASSIGN i-cont = i-cont + 1 .
    IF i-cont MOD 10 = 0 THEN DO:
        RUN pi-acompanhar IN h-acomp (INPUT "Processando Arquivo... " + STRING(i-cont) + " de " + STRING(f-tot-linhas) ) .
    END.
    /**/

    FOR EACH nota-fiscal NO-LOCK
        WHERE nota-fiscal.cod-estabel   = tt-arq-sitef.cod_estabel
          AND nota-fiscal.serie         = tt-arq-sitef.serie
          AND nota-fiscal.nr-nota-fis   = tt-arq-sitef.nr_fatura:
        
        RUN pi-goPage0-cria-tt-sitef .    
        
    END.

    IF tt-arq-sitef.l-fat-duplic = YES THEN DO:
        ASSIGN f-tot-encontrados = f-tot-encontrados + 1 .
    END.
    ELSE DO:
        ASSIGN f-tot-nencontrados = f-tot-nencontrados + 1 .
    END.
END.

RUN pi-acompanhar IN h-acomp (INPUT "Realizando Valida‡äes... ") .
RUN pi-goPage0-valida-sitef .

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
    f-tot-at-acr
    f-tot-nat-acr
    f-tot-erros
    f-tot-serros
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-goPage0-cria-tt-sitef wWindow 
PROCEDURE pi-goPage0-cria-tt-sitef :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
FOR FIRST fat-duplic NO-LOCK
    WHERE fat-duplic.cod-estabel        = nota-fiscal.cod-estabel
      AND fat-duplic.serie              = nota-fiscal.serie
      AND fat-duplic.nr-fatura          = nota-fiscal.nr-nota-fis
      AND fat-duplic.parcela            = tt-arq-sitef.parcela  
    :
    ASSIGN tt-arq-sitef.l-fat-duplic = YES .

    CREATE tt-sitef .
    BUFFER-COPY tt-arq-sitef TO tt-sitef .
    ASSIGN
        tt-sitef.r-rowid-cst_fat_duplic = ROWID(cst_fat_duplic)
        tt-sitef.r-rowid-fat-duplic = ROWID(fat-duplic)
        tt-sitef.serie              = fat-duplic.serie  
        tt-sitef.cod-portador-at    = fat-duplic.int-1
        tt-sitef.parcela-at         = fat-duplic.parcela
        tt-sitef.vl_parcela-at      = fat-duplic.vl-parcela
        tt-sitef.taxa_admin-at      = 0 // cst_fat_duplic.taxa_admin
        tt-sitef.dt-venciment-at    = fat-duplic.dt-venciment
        tt-sitef.conciliado-sitef   = NO //cst_fat_duplic.conciliado_sitef
        tt-sitef.flag-atualiz       = fat-duplic.flag-atualiz
        .
    IF tt-sitef.conciliado-sitef = ? THEN DO:
        ASSIGN tt-sitef.conciliado-sitef = NO .
    END.

    ASSIGN f-tot-faturas = f-tot-faturas + 1 .
    IF tt-sitef.conciliado-sitef = YES THEN DO:
        ASSIGN f-tot-conciliados = f-tot-conciliados + 1 .
    END.
    ELSE DO:
        ASSIGN f-tot-nconciliados = f-tot-nconciliados + 1 .
    END.
    IF tt-sitef.flag-atualiz = YES THEN DO:
        ASSIGN f-tot-at-acr = f-tot-at-acr + 1 .
    END.
    ELSE DO:
        ASSIGN f-tot-nat-acr = f-tot-nat-acr + 1 .
    END.
END.

/**/
RETURN "OK":U .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-goPage0-valida-sitef wWindow 
PROCEDURE pi-goPage0-valida-sitef :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
ASSIGN f-tot-erros = 0 .
ASSIGN f-tot-serros = 0 .


FOR EACH tt-sitef
    :
    ASSIGN tt-sitef.flags-erros = "" .
    IF tt-sitef.taxa_admin <> tt-sitef.taxa_admin-at THEN DO:
        ASSIGN tt-sitef.flags-erros = tt-sitef.flags-erros + ",1" .
    END.
    IF tt-sitef.vl_parcela-bruto <> tt-sitef.vl_parcela-at THEN DO:
        ASSIGN tt-sitef.flags-erros = tt-sitef.flags-erros + ",2" .
    END.
    IF tt-sitef.origem-venda = "MEDME" AND 
       (tt-sitef.cod-portador-at <> 93101 OR 
        tt-sitef.cod-portador-at <> 93102)
    THEN DO:
        ASSIGN tt-sitef.flags-erros = tt-sitef.flags-erros + ",3" .
    END. 
    IF tt-sitef.origem-venda = "NISSEI" AND 
       tt-sitef.tipo-movto = "balance" AND 
       tt-sitef.cod-portador-at <> 93102
    THEN DO:
        ASSIGN tt-sitef.flags-erros = tt-sitef.flags-erros + ",3" .
    END.                           
    IF tt-sitef.origem-venda = "NISSEI" AND 
       tt-sitef.tipo-movto = "Credit_c" AND 
       ( tt-sitef.cod-portador-at <> 90101 OR
         tt-sitef.cod-portador-at <> 90401 OR
         tt-sitef.cod-portador-at <> 91501 OR
         tt-sitef.cod-portador-at <> 90501 OR
         tt-sitef.cod-portador-at <> 90801 OR
         tt-sitef.cod-portador-at <> 90301 OR
         tt-sitef.cod-portador-at <> 90901 OR
         tt-sitef.cod-portador-at <> 91001 OR
         tt-sitef.cod-portador-at <> 91702 )
    THEN DO:
        ASSIGN tt-sitef.flags-erros = tt-sitef.flags-erros + ",3" .
    END. 
    IF tt-sitef.origem-venda = "NISSEI" AND 
       tt-sitef.tipo-movto = "debit_ca" AND 
       ( tt-sitef.cod-portador-at <> 90102 OR
         tt-sitef.cod-portador-at <> 91502 )
    THEN DO:
        ASSIGN tt-sitef.flags-erros = tt-sitef.flags-erros + ",3" .
    END.   
    IF tt-sitef.origem-venda = "NISSEI" AND 
       tt-sitef.tipo-movto = "Money" AND 
       ( tt-sitef.cod-portador-at <> 99901)
    THEN DO:
        ASSIGN tt-sitef.flags-erros = tt-sitef.flags-erros + ",3" .
    END.  
    IF tt-sitef.origem-venda = "NISSEI" AND 
       tt-sitef.tipo-movto = "pix" AND 
       ( tt-sitef.cod-portador-at <> 92101)
    THEN DO:
        ASSIGN tt-sitef.flags-erros = tt-sitef.flags-erros + ",3" .
    END. 
    IF tt-sitef.dt-venciment <> tt-sitef.dt-venciment-at THEN DO:
        ASSIGN tt-sitef.flags-erros = tt-sitef.flags-erros + ",5" .
    END.

    ASSIGN tt-sitef.flags-erros = SUBSTRING(tt-sitef.flags-erros , 2) .
    IF tt-sitef.flags-erros <> "" THEN DO:
        ASSIGN f-tot-erros = f-tot-erros + 1 .
    END.
    ELSE DO:
        ASSIGN f-tot-serros = f-tot-serros + 1 .
    END.
END.

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
DEF VAR h-acomp AS HANDLE NO-UNDO .
RUN utp/ut-acomp.p PERSISTENT SET h-acomp .
RUN pi-inicializar IN h-acomp (INPUT "Processando") .
RUN pi-acompanhar IN h-acomp (INPUT "Gravando Altera‡äes...") .

FOR EACH tt-sitef
    :
    IF INPUT FRAME fPage2 tg-erro-1 = YES AND 
       LOOKUP('1' , tt-sitef.flags-erros) > 0
    THEN DO:
        FIND FIRST cst_fat_duplic WHERE 
            ROWID(cst_fat_duplic) = tt-sitef.r-rowid-cst_fat_duplic
            .
        ASSIGN cst_fat_duplic.taxa_admin = tt-sitef.taxa_admin .
        ASSIGN tt-sitef.taxa_admin-at = tt-sitef.taxa_admin .
    END.
    IF INPUT FRAME fPage2 tg-erro-2 = YES AND 
       LOOKUP('2' , tt-sitef.flags-erros) > 0
    THEN DO:
        FIND FIRST fat-duplic WHERE 
            ROWID(fat-duplic) = tt-sitef.r-rowid-fat-duplic
            .
      //  ASSIGN fat-duplic.vl-parcela = tt-sitef.vl_parcela-bruto .
        ASSIGN tt-sitef.vl_parcela-at = tt-sitef.vl_parcela-bruto .
    END.

    IF INPUT FRAME fPage2 tg-erro-5 = YES AND 
       LOOKUP('5' , tt-sitef.flags-erros) > 0
    THEN DO:
        FIND FIRST fat-duplic WHERE 
            ROWID(fat-duplic) = tt-sitef.r-rowid-fat-duplic
            .
        ASSIGN fat-duplic.dt-venciment = tt-sitef.dt-venciment .
        ASSIGN tt-sitef.dt-venciment-at = tt-sitef.dt-venciment .
    END.
END.

RUN pi-goPage0-valida-sitef .

/**/
FOR EACH tt-sitef 
    WHERE tt-sitef.flags-erros = ""
    :
    FIND FIRST cst_fat_duplic WHERE 
        ROWID(cst_fat_duplic) = tt-sitef.r-rowid-cst_fat_duplic
        .
    ASSIGN cst_fat_duplic.conciliado_sitef = YES .
    ASSIGN tt-sitef.conciliado-sitef = YES .
END.

ASSIGN f-tot-conciliados = 0 .
ASSIGN f-tot-nconciliados = 0 .
FOR EACH tt-sitef NO-LOCK
    :
    IF tt-sitef.conciliado-sitef = YES THEN DO:
        ASSIGN f-tot-conciliados = f-tot-conciliados + 1 .
    END.
    ELSE DO:
        ASSIGN f-tot-nconciliados = f-tot-nconciliados + 1 .
    END.
END.
/**/



DISPLAY
    f-tot-conciliados
    f-tot-nconciliados
    f-tot-erros
    f-tot-serros
    WITH FRAME fPage2 .

{&open-query-brTable2}

/**/
RUN pi-finalizar IN h-acomp.
RETURN "OK":U .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION numeros wWindow 
FUNCTION numeros RETURNS LOGICAL
  ( INPUT texto AS CHARACTER) :

    DEFINE VARIABLE loop AS INTEGER NO-UNDO.

    DO loop = 1 TO LENGTH(texto):
        IF INDEX("0123456789.,":U,SUBSTRING(texto,loop,1)) = 0 THEN
        RETURN NO.
    END.
    RETURN YES.

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

