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
&SCOPED-DEFINE Program              NICR022 /* Conciliacao Arquivo SITEF */
&SCOPED-DEFINE Version              1.00.00.002

&SCOPED-DEFINE Folder               YES
&SCOPED-DEFINE InitialPage          1
&SCOPED-DEFINE FolderLabels         Arquivo,Processados

&SCOPED-DEFINE WinQueryJoinsBtn     YES
&SCOPED-DEFINE WinReportsJoinsBtn   YES
&SCOPED-DEFINE WinExitBtn           YES
&SCOPED-DEFINE WinHelpBtn           YES

&SCOPED-DEFINE page0EnableWidgets   f-cod-portador-credito f-cod-portador-debito c-layout~
                                    f-arquivo-sitef btGetFile1Page0 ~
                                    btGoPage0

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
    RETURN DATE( INT(SUBSTRING(p-char,5,2)) , INT(SUBSTRING(p-char,7,2)) , INT(SUBSTRING(p-char,1,4))) .
END FUNCTION .


DEF BUFFER portador FOR ems5.portador.

DEF TEMP-TABLE tt-arq-sitef NO-UNDO
    FIELD linha             AS INT FORMAT ">>>>>>>>9" LABEL "Linha"
    FIELD cod_estabel       LIKE cst_fat_duplic.cod_estabel
    FIELD nr_fatura         LIKE cst_fat_duplic.nr_fatura  
    FIELD parcela           LIKE cst_fat_duplic.parcela
    FIELD nsu_numero        LIKE cst_fat_duplic.nsu_numero FORMAT "x(12)"
    FIELD tipo-movto        AS CHAR LABEL "Tp"
    FIELD taxa_admin        LIKE cst_fat_duplic.taxa_admin 
    FIELD vl_parcela-liq    LIKE fat-duplic.vl-parcela COLUMN-LABEL "Vl Parcela Liq" 
    FIELD vl_parcela-bruto  LIKE fat-duplic.vl-parcela COLUMN-LABEL "Vl Parcela Bruto" 
    FIELD dt-venciment      LIKE fat-duplic.dt-venciment
    FIELD l-fat-duplic      AS LOGICAL COLUMN-LABEL "Existe TOTVS"
    .

DEF TEMP-TABLE tt-sitef NO-UNDO LIKE tt-arq-sitef
    FIELD r-rowid-cst_fat_duplic    AS ROWID
    FIELD r-rowid-fat-duplic        AS ROWID
    FIELD serie             LIKE cst_fat_duplic.serie COLUMN-LABEL "Serie T"
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
&Scoped-define FIELDS-IN-QUERY-brTable1 tt-arq-sitef.linha tt-arq-sitef.cod_estabel tt-arq-sitef.nr_fatura tt-arq-sitef.tipo-movto tt-arq-sitef.parcela tt-arq-sitef.nsu_numero tt-arq-sitef.taxa_admin tt-arq-sitef.vl_parcela-liq tt-arq-sitef.vl_parcela-bruto tt-arq-sitef.dt-venciment tt-arq-sitef.l-fat-duplic   
&Scoped-define ENABLED-FIELDS-IN-QUERY-brTable1   
&Scoped-define SELF-NAME brTable1
&Scoped-define QUERY-STRING-brTable1 FOR EACH tt-arq-sitef NO-LOCK     WHERE (tt-arq-sitef.l-fat-duplic = YES AND INPUT FRAME fPage1 tg-encontrados = YES OR            tt-arq-sitef.l-fat-duplic = NO AND INPUT FRAME fPage1 tg-nencontrados = YES )     INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-brTable1 OPEN QUERY {&SELF-NAME} FOR EACH tt-arq-sitef NO-LOCK     WHERE (tt-arq-sitef.l-fat-duplic = YES AND INPUT FRAME fPage1 tg-encontrados = YES OR            tt-arq-sitef.l-fat-duplic = NO AND INPUT FRAME fPage1 tg-nencontrados = YES )     INDEXED-REPOSITION .
&Scoped-define TABLES-IN-QUERY-brTable1 tt-arq-sitef
&Scoped-define FIRST-TABLE-IN-QUERY-brTable1 tt-arq-sitef


/* Definitions for BROWSE brTable2                                      */
&Scoped-define FIELDS-IN-QUERY-brTable2 tt-sitef.linha tt-sitef.cod_estabel tt-sitef.nr_fatura tt-sitef.tipo-movto tt-sitef.parcela tt-sitef.nsu_numero tt-sitef.taxa_admin tt-sitef.vl_parcela-liq tt-sitef.vl_parcela-bruto tt-sitef.dt-venciment tt-sitef.serie tt-sitef.cod-portador-at tt-sitef.parcela-at tt-sitef.vl_parcela-at tt-sitef.taxa_admin-at tt-sitef.dt-venciment-at tt-sitef.conciliado-sitef tt-sitef.flag-atualiz tt-sitef.flags-erros   
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
btHelp f-cod-portador-credito f-cod-portador-debito btGetFile1Page0 ~
btGoPage0 c-layout 
&Scoped-Define DISPLAYED-OBJECTS f-cod-portador-credito ~
f-nom-portador-credito f-cod-portador-debito f-nom-portador-debito c-layout ~
f-arquivo-sitef 

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

DEFINE VARIABLE c-layout AS INTEGER FORMAT ">9":U INITIAL 1 
     LABEL "layout" 
     VIEW-AS COMBO-BOX INNER-LINES 4
     LIST-ITEM-PAIRS "Sitef",1,
                     "Vidalink",2,
                     "Epharma",3,
                     "Funcional",4
     DROP-DOWN-LIST
     SIZE 16 BY 1 NO-UNDO.

DEFINE VARIABLE f-arquivo-sitef AS CHARACTER FORMAT "X(256)":U 
     LABEL "Arquivo SITEF" 
     VIEW-AS FILL-IN 
     SIZE 68.57 BY .88 NO-UNDO.

DEFINE VARIABLE f-cod-portador-credito AS CHARACTER FORMAT "X(256)":U 
     LABEL "Portador CrÇdito" 
     VIEW-AS FILL-IN 
     SIZE 6 BY .88 NO-UNDO.

DEFINE VARIABLE f-cod-portador-debito AS CHARACTER FORMAT "X(256)":U 
     LABEL "Portador DÇbito" 
     VIEW-AS FILL-IN 
     SIZE 6 BY .88 NO-UNDO.

DEFINE VARIABLE f-nom-portador-credito AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 22 BY .88 NO-UNDO.

DEFINE VARIABLE f-nom-portador-debito AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 22 BY .88 NO-UNDO.

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
     LABEL "Gravar Correá‰es" 
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
     LABEL "N∆o At ACR" 
     VIEW-AS FILL-IN 
     SIZE 10 BY .88 NO-UNDO.

DEFINE VARIABLE f-tot-nconciliados AS INTEGER FORMAT ">>>,>>>,>>9":U INITIAL 0 
     LABEL "N∆o Conciliados" 
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
 tt-arq-sitef.cod_estabel      
 tt-arq-sitef.nr_fatura   
 tt-arq-sitef.tipo-movto
 tt-arq-sitef.parcela          
 tt-arq-sitef.nsu_numero FORMAT "x(12)"      
 tt-arq-sitef.taxa_admin       
 tt-arq-sitef.vl_parcela-liq     
 tt-arq-sitef.vl_parcela-bruto 
 tt-arq-sitef.dt-venciment
 tt-arq-sitef.l-fat-duplic VIEW-AS TOGGLE-BOX
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 114 BY 14.75
         FONT 1.

DEFINE BROWSE brTable2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS brTable2 wWindow _FREEFORM
  QUERY brTable2 DISPLAY
      tt-sitef.linha            
 tt-sitef.cod_estabel      
 tt-sitef.nr_fatura 
 tt-sitef.tipo-movto
 tt-sitef.parcela          
 tt-sitef.nsu_numero FORMAT "x(12)"      
 tt-sitef.taxa_admin       
 tt-sitef.vl_parcela-liq     
 tt-sitef.vl_parcela-bruto 
 tt-sitef.dt-venciment
 tt-sitef.serie             
 tt-sitef.cod-portador-at   
 tt-sitef.parcela-at
 tt-sitef.vl_parcela-at     
 tt-sitef.taxa_admin-at     
 tt-sitef.dt-venciment-at   
 tt-sitef.conciliado-sitef VIEW-AS TOGGLE-BOX
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
     f-cod-portador-credito AT ROW 2.88 COL 13 COLON-ALIGNED WIDGET-ID 28
     f-nom-portador-credito AT ROW 2.88 COL 19.14 COLON-ALIGNED NO-LABEL WIDGET-ID 32
     f-cod-portador-debito AT ROW 2.88 COL 53.43 COLON-ALIGNED WIDGET-ID 30
     f-nom-portador-debito AT ROW 2.88 COL 59.57 COLON-ALIGNED NO-LABEL WIDGET-ID 34
     btGetFile1Page0 AT ROW 3.25 COL 84.57 WIDGET-ID 4
     btGoPage0 AT ROW 3.25 COL 113.57 WIDGET-ID 14
     c-layout AT ROW 3.5 COL 94.29 COLON-ALIGNED WIDGET-ID 36
     f-arquivo-sitef AT ROW 3.88 COL 13 COLON-ALIGNED WIDGET-ID 10
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
     brTable1 AT ROW 1 COL 1 WIDGET-ID 200
     f-tot-linhas AT ROW 16.25 COL 9 COLON-ALIGNED WIDGET-ID 54
     f-tot-encontrados AT ROW 16.25 COL 30 COLON-ALIGNED WIDGET-ID 50
     tg-encontrados AT ROW 16.25 COL 43 WIDGET-ID 56
     f-tot-nencontrados AT ROW 16.25 COL 58 COLON-ALIGNED WIDGET-ID 52
     tg-nencontrados AT ROW 16.25 COL 71 WIDGET-ID 58
     rt1 AT ROW 16 COL 1 WIDGET-ID 48
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 3.57 ROW 6.15
         SIZE 115 BY 16.5
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
/* SETTINGS FOR FILL-IN f-arquivo-sitef IN FRAME fpage0
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN f-nom-portador-credito IN FRAME fpage0
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN f-nom-portador-debito IN FRAME fpage0
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
        ASSIGN f-arquivo-sitef:SCREEN-VALUE IN FRAME fPage0 = v_file .
    END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btGoPage0
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btGoPage0 wWindow
ON CHOOSE OF btGoPage0 IN FRAME fpage0 /* Processar */
DO:
    IF INPUT FRAME fPage0 f-cod-portador-credito = "" THEN DO:
        RUN utp/ut-msgs.p(INPUT "show":U, INPUT 17006, 
                          INPUT "Portador CrÇdito n∆o informado.~~" + "") 
            .
        RETURN NO-APPLY. 
    END.
    IF INPUT FRAME fPage0 f-cod-portador-debito = "" THEN DO:
        RUN utp/ut-msgs.p(INPUT "show":U, INPUT 17006, 
                          INPUT "Portador DÇbito n∆o informado.~~" + "") 
            .
        RETURN NO-APPLY. 
    END.
    IF INPUT FRAME fPage0 f-arquivo-sitef = "" THEN DO:
        RUN utp/ut-msgs.p(INPUT "show":U, INPUT 17006, 
                          INPUT "Arquivo SITEF n∆o informado.~~" + "") 
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
ON CHOOSE OF btGoPage2 IN FRAME fPage2 /* Gravar Correá‰es */
DO:
    RUN pi-goPage2 .
    RUN utp/ut-msgs.p ("show" , "15825" , "Dados Gravados com Sucesso.").
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
f-cod-portador-credito:LOAD-MOUSE-POINTER("image/lupa.cur") IN FRAME fPage0 .
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

DEFINE VARIABLE c-cnpj AS CHARACTER   NO-UNDO.

ASSIGN f-tot-linhas = 0 .
ASSIGN f-tot-encontrados = 0 .
ASSIGN f-tot-nencontrados = 0 .
EMPTY TEMP-TABLE tt-arq-sitef .
EMPTY TEMP-TABLE tt-sitef .

INPUT FROM VALUE(INPUT FRAME fPage0 f-arquivo-sitef) NO-CONVERT .

IF INPUT FRAME fPage0 c-layout = 1 /* CIELO */ THEN DO:
    
    REPEAT ON ERROR UNDO , LEAVE ON STOP UNDO , LEAVE
        :
        IMPORT UNFORMATTED c-linha .
        ASSIGN c-linha = REPLACE(c-linha,'"',"") .
        IF c-linha = "" THEN NEXT .
        IF ENTRY(1,c-linha,";") <> "1" THEN NEXT .
        /**/
        ASSIGN f-tot-linhas = f-tot-linhas + 1 .
        IF f-tot-linhas MOD 100 = 0 THEN DO:
            RUN pi-acompanhar IN h-acomp (INPUT "Lendo Arquivo... Linha: " + STRING(f-tot-linhas) ) .
        END.
        CREATE tt-arq-sitef . ASSIGN
            tt-arq-sitef.linha              = f-tot-linhas
            tt-arq-sitef.cod_estabel        = SUBSTRING(ENTRY(22,c-linha,";") , 6 , 3)
            tt-arq-sitef.nr_fatura          = STRING(INT(ENTRY(24,c-linha,";"))  , "9999999") /* cNroCupom */
            tt-arq-sitef.parcela            = ENTRY(13,c-linha,";")
            tt-arq-sitef.nsu_numero         = ENTRY(06,c-linha,";")
            tt-arq-sitef.tipo-movto         = ENTRY(14,c-linha,";")
            tt-arq-sitef.taxa_admin         = DEC(ENTRY(20,c-linha,";")) / 100
            tt-arq-sitef.vl_parcela-liq     = DEC(ENTRY(11,c-linha,";")) / 100
            tt-arq-sitef.vl_parcela-bruto   = DEC(ENTRY(09,c-linha,";")) / 100
            tt-arq-sitef.dt-venciment       = fnFormatDate(ENTRY(12,c-linha,";"))
            .
        IF tt-arq-sitef.cod_estabel = "" THEN DO:
            ASSIGN tt-arq-sitef.cod_estabel = STRING(INT(ENTRY(22,c-linha,";")) , "999") .
        END.
        IF tt-arq-sitef.parcela = "00" THEN DO:
            ASSIGN tt-arq-sitef.parcela = "01" .
        END.
    END.
    
    INPUT CLOSE .

END. // Fim importaá∆o arquivo CIELO 

IF INPUT FRAME fPage0 c-layout = 2 /* VIDALINK */ THEN DO:

   

    REPEAT ON ERROR UNDO , LEAVE ON STOP UNDO , LEAVE:

        IMPORT UNFORMATTED c-linha .
        ASSIGN c-linha = REPLACE(c-linha,'"',"") .
        IF c-linha = "" THEN NEXT .
        IF ENTRY(1,c-linha,";") = "SEQ" THEN NEXT .
        IF substring(c-linha, 1,3) = ";;;" THEN NEXT .
        /**/
        ASSIGN f-tot-linhas = f-tot-linhas + 1 .
        IF f-tot-linhas MOD 100 = 0 THEN DO:
            RUN pi-acompanhar IN h-acomp (INPUT "Lendo Arquivo... Linha: " + STRING(f-tot-linhas) ) .
        END.

        ASSIGN c-cnpj = REPLACE(ENTRY(4,c-linha,";"), "/", "").
        ASSIGN c-cnpj = REPLACE(c-cnpj, ".", "").
        ASSIGN c-cnpj = REPLACE(c-cnpj, "-", "").

        FIND FIRST estabelec NO-LOCK
            WHERE estabelec.cgc = c-cnpj NO-ERROR.
        
        CREATE tt-arq-sitef . 
        ASSIGN
            tt-arq-sitef.linha              = f-tot-linhas
            tt-arq-sitef.cod_estabel        = IF AVAIL estabelec THEN estabelec.cod-estabel ELSE ""
            tt-arq-sitef.nr_fatura          = STRING(INT(ENTRY(16,c-linha,";"))  , "9999999") /* cNroCupom */
            tt-arq-sitef.parcela            = "01"
            tt-arq-sitef.nsu_numero         = ENTRY(07,c-linha,";")
            tt-arq-sitef.tipo-movto         = ENTRY(13,c-linha,";")
            tt-arq-sitef.taxa_admin         = 0
            tt-arq-sitef.vl_parcela-liq     = DEC( replace(ENTRY(28,c-linha,";") , "R$ ","") )
            tt-arq-sitef.vl_parcela-bruto   = DEC( replace(ENTRY(28,c-linha,";") , "R$ ","") )
            tt-arq-sitef.dt-venciment       = date(ENTRY(06,c-linha,";"))
                .
    END.
    
    INPUT CLOSE .

END. // Fim importaá∆o arquivo Vidalink 


IF INPUT FRAME fPage0 c-layout = 3 /* EPHARMA */ THEN DO:


    DEFINE VARIABLE c-nr-fatura AS CHARACTER    NO-UNDO.
    DEFINE VARIABLE c-estabel   AS CHARACTER    NO-UNDO.
    DEFINE VARIABLE de-valor    AS DECIMAL      NO-UNDO.
    DEFINE VARIABLE c-nsu       AS CHARACTER    NO-UNDO.
    DEFINE VARIABLE dt-Venc     AS DATE        NO-UNDO.


    REPEAT ON ERROR UNDO , LEAVE ON STOP UNDO , LEAVE
        :
        IMPORT UNFORMATTED c-linha .
        ASSIGN c-linha = REPLACE(c-linha,'"',"") .
        IF c-linha = "" THEN NEXT .


        IF ENTRY(8,c-linha,";") <> "Compra de medicamento" THEN NEXT .
        IF ENTRY(16,c-linha,";") = "" THEN NEXT .

        .MESSAGE ENTRY(12,c-linha,";") SKIP
                ENTRY(3,c-linha,";") SKIP
                REPLACE (replace(ENTRY(15,c-linha,";"),'"', ""), "/", "")
            VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.

        ASSIGN c-nr-fatura = STRING(INT( ENTRY(12,c-linha,";"))  , "9999999") 
               c-estabel   = STRING(INT(ENTRY(3,c-linha,";")), "999")
               de-valor    = DEC(REPLACE (ENTRY(15,c-linha,";"), "/", ""))
               c-nsu       = ENTRY(23,c-linha,";")
               dt-Venc     = DATE(ENTRY(1,c-linha,";")).
        
        IF f-tot-linhas MOD 100 = 0 THEN DO:
            RUN pi-acompanhar IN h-acomp (INPUT "Lendo Arquivo... Linha: " + STRING(f-tot-linhas) ) .
        END.


        FIND FIRST estabelec NO-LOCK
            WHERE estabelec.cod-estabel = c-estabel NO-ERROR.

        IF AVAIL estabelec THEN DO:

            FIND FIRST tt-arq-sitef 
                WHERE tt-arq-sitef.cod_estabel = estabelec.cod-estabel                             
                  AND tt-arq-sitef.nr_fatura   = c-nr-fatura NO-ERROR.
            
            IF AVAIL tt-arq-sitef THEN DO:

                ASSIGN tt-arq-sitef.vl_parcela-liq    = tt-arq-sitef.vl_parcela-liq    + de-valor / 100     
                       tt-arq-sitef.vl_parcela-bruto  = tt-arq-sitef.vl_parcela-bruto  + de-valor / 100   
                    .   

            END.
            IF NOT AVAIL tt-arq-sitef  THEN DO:

                ASSIGN f-tot-linhas = f-tot-linhas + 1 .
    
                CREATE tt-arq-sitef . ASSIGN
                    tt-arq-sitef.linha              = f-tot-linhas
                    tt-arq-sitef.cod_estabel        = IF AVAIL estabelec THEN estabelec.cod-estabel ELSE ""
                    tt-arq-sitef.nr_fatura          = c-nr-fatura
                    tt-arq-sitef.parcela            = "01"
                    tt-arq-sitef.nsu_numero         = c-nsu
                    tt-arq-sitef.tipo-movto         = ENTRY(7,c-linha,";")
                    tt-arq-sitef.taxa_admin         = 0
                    tt-arq-sitef.vl_parcela-liq     = de-valor
                    tt-arq-sitef.vl_parcela-bruto   = de-valor
                    tt-arq-sitef.dt-venciment       = dt-Venc
                    .
            END.
    
        END.


    END.
    
    INPUT CLOSE .

END. // Fim importaá∆o arquivo Epharma

IF INPUT FRAME fPage0 c-layout = 4 /* FUNCIONAL */ THEN DO:


    REPEAT ON ERROR UNDO , LEAVE ON STOP UNDO , LEAVE
        :
        IMPORT UNFORMATTED c-linha .
        ASSIGN c-linha = REPLACE(c-linha,'"',"") .
        IF c-linha = "" THEN NEXT .


        IF ENTRY(8,c-linha,";") <> "Compra de medicamento" THEN NEXT .
        IF ENTRY(22,c-linha,";") = "" THEN NEXT .

        ASSIGN c-nr-fatura = STRING(INT( ENTRY(12,c-linha,";"))  , "9999999") 
               c-estabel   = STRING(INT(ENTRY(3,c-linha,";")), "999")
               de-valor    = DEC(REPLACE (ENTRY(15,c-linha,";"), "/", ""))
               c-nsu       = ENTRY(23,c-linha,";")
               dt-Venc     = DATE(ENTRY(1,c-linha,";")).
        
        IF f-tot-linhas MOD 100 = 0 THEN DO:
            RUN pi-acompanhar IN h-acomp (INPUT "Lendo Arquivo... Linha: " + STRING(f-tot-linhas) ) .
        END.


        FIND FIRST estabelec NO-LOCK
            WHERE estabelec.cod-estabel = c-estabel NO-ERROR.

        IF AVAIL estabelec THEN DO:

            FIND FIRST tt-arq-sitef 
                WHERE tt-arq-sitef.cod_estabel = estabelec.cod-estabel                             
                  AND tt-arq-sitef.nr_fatura   = c-nr-fatura NO-ERROR.
            
            IF AVAIL tt-arq-sitef THEN DO:

                ASSIGN tt-arq-sitef.vl_parcela-liq    = tt-arq-sitef.vl_parcela-liq    + de-valor / 100     
                       tt-arq-sitef.vl_parcela-bruto  = tt-arq-sitef.vl_parcela-bruto  + de-valor / 100   
                    .   

            END.
            IF NOT AVAIL tt-arq-sitef  THEN DO:

                ASSIGN f-tot-linhas = f-tot-linhas + 1 .
    
                CREATE tt-arq-sitef . ASSIGN
                    tt-arq-sitef.linha              = f-tot-linhas
                    tt-arq-sitef.cod_estabel        = IF AVAIL estabelec THEN estabelec.cod-estabel ELSE ""
                    tt-arq-sitef.nr_fatura          = c-nr-fatura
                    tt-arq-sitef.parcela            = "01"
                    tt-arq-sitef.nsu_numero         = c-nsu
                    tt-arq-sitef.tipo-movto         = ENTRY(7,c-linha,";")
                    tt-arq-sitef.taxa_admin         = 0
                    tt-arq-sitef.vl_parcela-liq     = de-valor
                    tt-arq-sitef.vl_parcela-bruto   = de-valor
                    tt-arq-sitef.dt-venciment       = dt-Venc
                    .
            END.
    
        END.


    END.
    
    INPUT CLOSE .

END. // Fim importaá∆o arquivo Epharma 

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

    FOR EACH cst_fat_duplic NO-LOCK
        WHERE cst_fat_duplic.cod_estabel        = tt-arq-sitef.cod_estabel
          AND cst_fat_duplic.nr_fatura          = tt-arq-sitef.nr_fatura
          AND cst_fat_duplic.parcela            = tt-arq-sitef.parcela
        :

        IF numeros(cst_fat_duplic.nsu_numero) = YES THEN DO:
            IF string(dec(cst_fat_duplic.nsu_numero)) = STRING(dec(tt-arq-sitef.nsu_numero)) THEN DO:
                RUN pi-goPage0-cria-tt-sitef .                                                       
            END.
        END.

        
    END.

    IF tt-arq-sitef.l-fat-duplic = NO THEN DO:
        FOR EACH cst_fat_duplic NO-LOCK
            WHERE cst_fat_duplic.cod_estabel    = tt-arq-sitef.cod_estabel
              AND cst_fat_duplic.nr_fatura      = tt-arq-sitef.nr_fatura:

            IF numeros(cst_fat_duplic.nsu_numero) = YES THEN DO:
                IF string(dec(cst_fat_duplic.nsu_numero)) = STRING(dec(tt-arq-sitef.nsu_numero)) THEN DO:
                    RUN pi-goPage0-cria-tt-sitef .                                                       
                END.
            END.


        END.
    END.

    IF tt-arq-sitef.l-fat-duplic = YES THEN DO:
        ASSIGN f-tot-encontrados = f-tot-encontrados + 1 .
    END.
    ELSE DO:
        ASSIGN f-tot-nencontrados = f-tot-nencontrados + 1 .
    END.
END.

RUN pi-acompanhar IN h-acomp (INPUT "Realizando Validaá‰es... ") .
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
    WHERE fat-duplic.cod-estabel        = cst_fat_duplic.cod_estabel
      AND fat-duplic.serie              = cst_fat_duplic.serie
      AND fat-duplic.nr-fatura          = cst_fat_duplic.nr_fatura
      AND fat-duplic.parcela            = cst_fat_duplic.parcela
    :
    ASSIGN tt-arq-sitef.l-fat-duplic = YES .

    CREATE tt-sitef .
    BUFFER-COPY tt-arq-sitef TO tt-sitef .
    ASSIGN
        tt-sitef.r-rowid-cst_fat_duplic = ROWID(cst_fat_duplic)
        tt-sitef.r-rowid-fat-duplic = ROWID(fat-duplic)
        tt-sitef.serie              = cst_fat_duplic.serie  
        tt-sitef.cod-portador-at    = cst_fat_duplic.cod_portador
        tt-sitef.parcela-at         = fat-duplic.parcela
        tt-sitef.vl_parcela-at      = fat-duplic.vl-parcela
        tt-sitef.taxa_admin-at      = cst_fat_duplic.taxa_admin
        tt-sitef.dt-venciment-at    = fat-duplic.dt-venciment
        tt-sitef.conciliado-sitef   = cst_fat_duplic.conciliado_sitef
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
    IF tt-sitef.tipo-movto = "D" AND 
       tt-sitef.cod-portador-at <> INT(INPUT FRAME fPage0 f-cod-portador-debito)
    THEN DO:
        ASSIGN tt-sitef.flags-erros = tt-sitef.flags-erros + ",3" .
    END.
    IF tt-sitef.tipo-movto = "C" AND 
       tt-sitef.cod-portador-at <> INT(INPUT FRAME fPage0 f-cod-portador-credito)
    THEN DO:
        ASSIGN tt-sitef.flags-erros = tt-sitef.flags-erros + ",4" .
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
RUN pi-acompanhar IN h-acomp (INPUT "Gravando Alteraá‰es...") .

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
  /*  IF INPUT FRAME fPage2 tg-erro-3 = YES AND 
       LOOKUP('3' , tt-sitef.flags-erros) > 0
    THEN DO:
        FIND FIRST cst_fat_duplic WHERE 
            ROWID(cst_fat_duplic) = tt-sitef.r-rowid-cst_fat_duplic
            .
        ASSIGN cst_fat_duplic.cod_portador = INT(INPUT FRAME fPage0 f-cod-portador-debito) .
        ASSIGN tt-sitef.cod-portador-at = INT(INPUT FRAME fPage0 f-cod-portador-debito).
    END.
    IF INPUT FRAME fPage2 tg-erro-4 = YES AND 
       LOOKUP('4' , tt-sitef.flags-erros) > 0
    THEN DO:
        FIND FIRST cst_fat_duplic WHERE 
            ROWID(cst_fat_duplic) = tt-sitef.r-rowid-cst_fat_duplic
            .
        ASSIGN cst_fat_duplic.cod_portador = INT(INPUT FRAME fPage0 f-cod-portador-credito) .
        ASSIGN tt-sitef.cod-portador-at = INT(INPUT FRAME fPage0 f-cod-portador-credito).
    END.*/
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

