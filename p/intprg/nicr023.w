&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
          emscad           ORACLE
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
&SCOPED-DEFINE Program              NICR023 /* Conciliacao Baixa ACR - SITEF */
&SCOPED-DEFINE Version              1.00.00.005

&SCOPED-DEFINE Folder               YES
&SCOPED-DEFINE InitialPage          1
&SCOPED-DEFINE FolderLabels         Arquivo,Conciliaá∆o

&SCOPED-DEFINE WinQueryJoinsBtn     YES
&SCOPED-DEFINE WinReportsJoinsBtn   YES
&SCOPED-DEFINE WinExitBtn           YES
&SCOPED-DEFINE WinHelpBtn           YES

&SCOPED-DEFINE page0EnableWidgets   f-arq-sitef bt-getfile-sitef bt-imp-sitef ~
                                    f-dat-trans

&SCOPED-DEFINE page1EnableWidgets   brTable1 ~
                                    tg-encontrados tg-nencontrados ~
                                    btGoPage1

&SCOPED-DEFINE page2EnableWidgets   brTable2 ~
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

DEF TEMP-TABLE tt-arq-sitef NO-UNDO
    FIELD linha                 AS INT FORMAT ">>>>>>>>9" LABEL "Linha"
    FIELD l_encontrado          AS LOGICAL COLUMN-LABEL "Conc"
    FIELD cod_estab_arq         AS CHAR FORMAT "x(20)"  COLUMN-LABEL "Est Arq"
    FIELD cod_estab_conv        AS CHAR FORMAT "x(05)"  COLUMN-LABEL "Est Conv"
    FIELD cod_res_vda           AS CHAR FORMAT "x(20)"  COLUMN-LABEL "N£mero Resumo"
    FIELD cod_comprov_vda       AS CHAR FORMAT "x(20)"  COLUMN-LABEL "N£mero Comprovante"
    FIELD cod_nsu_sitef         AS CHAR FORMAT "x(10)"  COLUMN-LABEL "NSU Sitef"
    FIELD cod_autoriz_cartao_cr AS CHAR FORMAT "x(10)"  COLUMN-LABEL "C¢d Autorizaá∆o"
    FIELD cod_cupom             AS CHAR FORMAT "x(10)"  COLUMN-LABEL "Cupom"
    FIELD cod_admdra_arq        AS CHAR FORMAT "x(10)"  COLUMN-LABEL "Admdra Arq"
    FIELD cod_admdra_conv       AS CHAR FORMAT "x(10)"  COLUMN-LABEL "Admdra Conv"
    FIELD parcela               AS CHAR FORMAT "x(2)"   COLUMN-LABEL "Pa"
    FIELD val_bruto             AS DECIMAL FORMAT "->>>,>>>,>>9.99" COLUMN-LABEL "Val Bruto"
    FIELD val_taxa              AS DECIMAL FORMAT "->>>,>>>,>>9.99" COLUMN-LABEL "Val Taxa"
    FIELD val_liquido           AS DECIMAL FORMAT "->>>,>>>,>>9.99" COLUMN-LABEL "Val Liqu°do"
    FIELD cod_banco             AS CHAR FORMAT "x(03)"  COLUMN-LABEL "Banco"
    FIELD cod_agencia           AS CHAR FORMAT "x(06)"  COLUMN-LABEL "Agància"
    FIELD cod_conta_corrente    AS CHAR FORMAT "x(12)"  COLUMN-LABEL "Conta Corrente"
    FIELD dig_conta_corrente    AS CHAR FORMAT "x(01)"  COLUMN-LABEL "Dig CC"
    FIELD cod_cta_corren_erp    AS CHAR FORMAT "x(12)"  COLUMN-LABEL "Conta Corrente ERP"
    INDEX idk_pk1 AS UNIQUE PRIMARY
    linha
    .

DEF TEMP-TABLE tt_tit_acr_cartao NO-UNDO LIKE tit_acr_cartao
    FIELD r_rowid               AS ROWID
    FIELD linha_arq             AS INT FORMAT ">>>>>>>>9" LABEL "Linha Arq"
    FIELD val_liquido           AS DECIMAL FORMAT "->>>,>>>,>>9.99" COLUMN-LABEL "Val Liqu°do"
    FIELD val_diverg            AS DECIMAL FORMAT "->>>,>>>,>>9.99" COLUMN-LABEL "Val Divergància"
    FIELD cod_portador          LIKE portad_finalid_econ.cod_portador
    FIELD cod_cart_bcia         LIKE portad_finalid_econ.cod_cart_bcia
    FIELD val_sdo_tit_acr       LIKE tit_acr.val_sdo_tit_acr
    INDEX idx_pk1
    linha_arq
    .

DEFINE BUFFER b-tit_acr_cartao FOR tit_acr_cartao .

/* Parameters Definitions ---                                               */

/* Local Variable Definitions ---                                           */

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
&Scoped-define INTERNAL-TABLES tt-arq-sitef tt_tit_acr_cartao tit_acr

/* Definitions for BROWSE brTable1                                      */
&Scoped-define FIELDS-IN-QUERY-brTable1 tt-arq-sitef.linha tt-arq-sitef.l_encontrado tt-arq-sitef.cod_estab_arq tt-arq-sitef.cod_estab_conv tt-arq-sitef.cod_res_vda tt-arq-sitef.cod_comprov_vda tt-arq-sitef.cod_nsu_sitef tt-arq-sitef.cod_autoriz_cartao_cr tt-arq-sitef.cod_cupom tt-arq-sitef.cod_admdra_arq tt-arq-sitef.cod_admdra_conv tt-arq-sitef.parcela tt-arq-sitef.val_bruto tt-arq-sitef.val_taxa tt-arq-sitef.val_liquido tt-arq-sitef.cod_banco tt-arq-sitef.cod_agencia tt-arq-sitef.cod_conta_corrente tt-arq-sitef.dig_conta_corrente tt-arq-sitef.cod_cta_corren_erp   
&Scoped-define ENABLED-FIELDS-IN-QUERY-brTable1   
&Scoped-define SELF-NAME brTable1
&Scoped-define QUERY-STRING-brTable1 FOR EACH tt-arq-sitef NO-LOCK     WHERE (tt-arq-sitef.l_encontrado = YES AND INPUT FRAME fPage1 tg-encontrados = YES OR            tt-arq-sitef.l_encontrado = NO AND INPUT FRAME fPage1 tg-nencontrados = YES )     INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-brTable1 OPEN QUERY {&SELF-NAME} FOR EACH tt-arq-sitef NO-LOCK     WHERE (tt-arq-sitef.l_encontrado = YES AND INPUT FRAME fPage1 tg-encontrados = YES OR            tt-arq-sitef.l_encontrado = NO AND INPUT FRAME fPage1 tg-nencontrados = YES )     INDEXED-REPOSITION .
&Scoped-define TABLES-IN-QUERY-brTable1 tt-arq-sitef
&Scoped-define FIRST-TABLE-IN-QUERY-brTable1 tt-arq-sitef


/* Definitions for BROWSE brTable2                                      */
&Scoped-define FIELDS-IN-QUERY-brTable2 tt_tit_acr_cartao.linha_arq tt_tit_acr_cartao.cod_comprov_vda tt_tit_acr_cartao.cod_autoriz_cartao_cr tt_tit_acr_cartao.cod_admdra tt_tit_acr_cartao.cod_parc tt-arq-sitef.val_bruto tt-arq-sitef.val_taxa tt-arq-sitef.val_liquido tt_tit_acr_cartao.val_comprov_vda tt_tit_acr_cartao.val_des_admdra tt_tit_acr_cartao.val_liquido tt_tit_acr_cartao.val_diverg tit_acr.cod_estab tit_acr.cod_espec_docto tit_acr.cod_ser_docto tit_acr.cod_tit_acr tit_acr.cod_parcela tt_tit_acr_cartao.val_sdo_tit_acr tt_tit_acr_cartao.cod_portador tt_tit_acr_cartao.cod_cart_bcia tt_tit_acr_cartao.cod_estab_liq tt_tit_acr_cartao.cod_refer_lote_liq   
&Scoped-define ENABLED-FIELDS-IN-QUERY-brTable2   
&Scoped-define SELF-NAME brTable2
&Scoped-define QUERY-STRING-brTable2 FOR EACH tt_tit_acr_cartao NO-LOCK , ~
           FIRST tt-arq-sitef NO-LOCK WHERE     tt-arq-sitef.linha = tt_tit_acr_cartao.linha_arq , ~
           FIRST tit_acr NO-LOCK WHERE     tit_acr.cod_estab = tt_tit_acr_cartao.cod_estab AND     tit_acr.num_id_tit_acr = tt_tit_acr_cartao.num_id_tit_acr     BY tt_tit_acr_cartao.linha_arq     INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-brTable2 OPEN QUERY {&SELF-NAME} FOR EACH tt_tit_acr_cartao NO-LOCK , ~
           FIRST tt-arq-sitef NO-LOCK WHERE     tt-arq-sitef.linha = tt_tit_acr_cartao.linha_arq , ~
           FIRST tit_acr NO-LOCK WHERE     tit_acr.cod_estab = tt_tit_acr_cartao.cod_estab AND     tit_acr.num_id_tit_acr = tt_tit_acr_cartao.num_id_tit_acr     BY tt_tit_acr_cartao.linha_arq     INDEXED-REPOSITION .
&Scoped-define TABLES-IN-QUERY-brTable2 tt_tit_acr_cartao tt-arq-sitef ~
tit_acr
&Scoped-define FIRST-TABLE-IN-QUERY-brTable2 tt_tit_acr_cartao
&Scoped-define SECOND-TABLE-IN-QUERY-brTable2 tt-arq-sitef
&Scoped-define THIRD-TABLE-IN-QUERY-brTable2 tit_acr


/* Definitions for FRAME fPage1                                         */

/* Definitions for FRAME fPage2                                         */

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS rtToolBar btQueryJoins btReportsJoins btExit ~
btHelp bt-getfile-sitef bt-imp-sitef f-dat-trans 
&Scoped-Define DISPLAYED-OBJECTS f-arq-sitef f-dat-trans 

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
DEFINE BUTTON bt-getfile-sitef 
     IMAGE-UP FILE "image/toolbar/im-open.bmp":U
     LABEL "Button 1" 
     SIZE 5.14 BY 1.46.

DEFINE BUTTON bt-imp-sitef 
     IMAGE-UP FILE "image/toolbar/im-tick.bmp":U
     LABEL "" 
     SIZE 5.14 BY 1.46.

DEFINE BUTTON btExit 
     IMAGE-UP FILE "image\im-exi":U
     IMAGE-INSENSITIVE FILE "image\ii-exi":U
     LABEL "Exit" 
     SIZE 4 BY 1.25 TOOLTIP "Sair"
     FONT 4.

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

DEFINE VARIABLE f-arq-sitef AS CHARACTER FORMAT "X(256)":U INITIAL "C:~\temp~\det_Cielo2_02.05.18_part1.csv" 
     LABEL "Arquivo SITEF" 
     VIEW-AS FILL-IN 
     SIZE 84 BY .88 NO-UNDO.

DEFINE VARIABLE f-dat-trans AS DATE FORMAT "99/99/9999":U 
     LABEL "Data Liquidaá∆o" 
     VIEW-AS FILL-IN 
     SIZE 10 BY .88 NO-UNDO.

DEFINE RECTANGLE rtToolBar
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 120 BY 1.5
     BGCOLOR 7 .

DEFINE BUTTON btGoPage1 
     LABEL "Buscar Titulos" 
     SIZE 15 BY 1.

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
     LABEL "Gerar Lotes Liquidac" 
     SIZE 15 BY 1.

DEFINE RECTANGLE rt2
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 114 BY 1.25
     BGCOLOR 7 .

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY brTable1 FOR 
      tt-arq-sitef SCROLLING.

DEFINE QUERY brTable2 FOR 
      tt_tit_acr_cartao, 
      tt-arq-sitef, 
      tit_acr SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE brTable1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS brTable1 wWindow _FREEFORM
  QUERY brTable1 DISPLAY
      tt-arq-sitef.linha 
        tt-arq-sitef.l_encontrado VIEW-AS TOGGLE-BOX 
        tt-arq-sitef.cod_estab_arq     
        tt-arq-sitef.cod_estab_conv       
        tt-arq-sitef.cod_res_vda           
        tt-arq-sitef.cod_comprov_vda       
        tt-arq-sitef.cod_nsu_sitef         
        tt-arq-sitef.cod_autoriz_cartao_cr 
        tt-arq-sitef.cod_cupom             
        tt-arq-sitef.cod_admdra_arq        
        tt-arq-sitef.cod_admdra_conv            
        tt-arq-sitef.parcela   
        tt-arq-sitef.val_bruto 
        tt-arq-sitef.val_taxa  
        tt-arq-sitef.val_liquido           
        tt-arq-sitef.cod_banco             
        tt-arq-sitef.cod_agencia           
        tt-arq-sitef.cod_conta_corrente
        tt-arq-sitef.dig_conta_corrente
        tt-arq-sitef.cod_cta_corren_erp
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 114 BY 14.75
         FONT 1.

DEFINE BROWSE brTable2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS brTable2 wWindow _FREEFORM
  QUERY brTable2 DISPLAY
      tt_tit_acr_cartao.linha_arq
    tt_tit_acr_cartao.cod_comprov_vda
    tt_tit_acr_cartao.cod_autoriz_cartao_cr
    tt_tit_acr_cartao.cod_admdra
    tt_tit_acr_cartao.cod_parc
    tt-arq-sitef.val_bruto COLUMN-LABEL "Vl Venda Arquivo"
    tt-arq-sitef.val_taxa COLUMN-LABEL "Vl Taxa Arquivo" 
    tt-arq-sitef.val_liquido COLUMN-LABEL "Vl Liq Arquivo"
    tt_tit_acr_cartao.val_comprov_vda COLUMN-LABEL "Vl Venda Sistema"
    tt_tit_acr_cartao.val_des_admdra COLUMN-LABEL "Vl Taxa Sistema"
    tt_tit_acr_cartao.val_liquido COLUMN-LABEL "Vl Liq Sistema"
    tt_tit_acr_cartao.val_diverg
    tit_acr.cod_estab
    tit_acr.cod_espec_docto
    tit_acr.cod_ser_docto
    tit_acr.cod_tit_acr
    tit_acr.cod_parcela
    tt_tit_acr_cartao.val_sdo_tit_acr
    tt_tit_acr_cartao.cod_portador
    tt_tit_acr_cartao.cod_cart_bcia
    tt_tit_acr_cartao.cod_estab_liq
    tt_tit_acr_cartao.cod_refer_lote_liq WIDTH 9
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 114 BY 14.75
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
     f-arq-sitef AT ROW 2.88 COL 16 COLON-ALIGNED WIDGET-ID 10
     bt-getfile-sitef AT ROW 2.88 COL 102.57 WIDGET-ID 4
     bt-imp-sitef AT ROW 2.88 COL 112 WIDGET-ID 14
     f-dat-trans AT ROW 4.25 COL 88 COLON-ALIGNED WIDGET-ID 16
     rtToolBar AT ROW 1 COL 1
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 120 BY 22
         FONT 1 WIDGET-ID 100.

DEFINE FRAME fPage2
     brTable2 AT ROW 1 COL 1 WIDGET-ID 200
     btGoPage2 AT ROW 16.13 COL 97 WIDGET-ID 62
     f-tot-encontrados AT ROW 16.25 COL 15 COLON-ALIGNED WIDGET-ID 64
          LABEL "Tot Encontrados" FORMAT ">>>,>>>,>>9":U
          VIEW-AS FILL-IN 
          SIZE 10 BY .88
     rt2 AT ROW 16 COL 1 WIDGET-ID 48
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 3.57 ROW 6.15
         SIZE 115 BY 16.5
         FONT 1 WIDGET-ID 300.

DEFINE FRAME fPage1
     brTable1 AT ROW 1 COL 1 WIDGET-ID 200
     btGoPage1 AT ROW 16.13 COL 97 WIDGET-ID 62
     f-tot-linhas AT ROW 16.25 COL 15 COLON-ALIGNED WIDGET-ID 60
     f-tot-encontrados AT ROW 16.25 COL 37.14 COLON-ALIGNED WIDGET-ID 50
     tg-encontrados AT ROW 16.25 COL 50.14 WIDGET-ID 56
     f-tot-nencontrados AT ROW 16.25 COL 65.14 COLON-ALIGNED WIDGET-ID 52
     tg-nencontrados AT ROW 16.25 COL 78.14 WIDGET-ID 58
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
/* SETTINGS FOR FILL-IN f-arq-sitef IN FRAME fpage0
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
    WHERE (tt-arq-sitef.l_encontrado = YES AND INPUT FRAME fPage1 tg-encontrados = YES OR
           tt-arq-sitef.l_encontrado = NO AND INPUT FRAME fPage1 tg-nencontrados = YES )
    INDEXED-REPOSITION .
     _END_FREEFORM
     _Query            is NOT OPENED
*/  /* BROWSE brTable1 */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE brTable2
/* Query rebuild information for BROWSE brTable2
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH tt_tit_acr_cartao NO-LOCK ,
    FIRST tt-arq-sitef NO-LOCK WHERE
    tt-arq-sitef.linha = tt_tit_acr_cartao.linha_arq ,
    FIRST tit_acr NO-LOCK WHERE
    tit_acr.cod_estab = tt_tit_acr_cartao.cod_estab AND
    tit_acr.num_id_tit_acr = tt_tit_acr_cartao.num_id_tit_acr
    BY tt_tit_acr_cartao.linha_arq
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


&Scoped-define SELF-NAME bt-getfile-sitef
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-getfile-sitef wWindow
ON CHOOSE OF bt-getfile-sitef IN FRAME fpage0 /* Button 1 */
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
        ASSIGN f-arq-sitef:SCREEN-VALUE IN FRAME fPage0 = v_file .
    END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-imp-sitef
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-imp-sitef wWindow
ON CHOOSE OF bt-imp-sitef IN FRAME fpage0
DO:
    IF INPUT FRAME fPage0 f-arq-sitef = "" THEN DO:
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


&Scoped-define SELF-NAME btExit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btExit wWindow
ON CHOOSE OF btExit IN FRAME fpage0 /* Exit */
OR CHOOSE OF MENU-ITEM miExit IN MENU mbMain DO:
    APPLY "CLOSE":U TO THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME fPage1
&Scoped-define SELF-NAME btGoPage1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btGoPage1 wWindow
ON CHOOSE OF btGoPage1 IN FRAME fPage1 /* Buscar Titulos */
DO:
    RUN pi-goPage1 .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME fPage2
&Scoped-define SELF-NAME btGoPage2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btGoPage2 wWindow
ON CHOOSE OF btGoPage2 IN FRAME fPage2 /* Gerar Lotes Liquidac */
DO:
    RUN pi-goPage2 .
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


&Scoped-define FRAME-NAME fPage1
&Scoped-define SELF-NAME tg-encontrados
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tg-encontrados wWindow
ON VALUE-CHANGED OF tg-encontrados IN FRAME fPage1
DO:
    {&open-query-brTable1}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


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
RUN setEnabled IN hFolder(INPUT 2 , INPUT NO) .

DO WITH FRAME fPage0
    :
    ASSIGN f-dat-trans:SCREEN-VALUE = STRING(TODAY) .
END.

APPLY "ENTRY" TO f-arq-sitef IN FRAME fPage0 .

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
DEF VAR i-msg       AS INT NO-UNDO .

EMPTY TEMP-TABLE tt-arq-sitef .
EMPTY TEMP-TABLE tt_tit_acr_cartao .
ASSIGN f-tot-linhas = 0 .
ASSIGN f-tot-encontrados = 0 .
ASSIGN f-tot-nencontrados = 0 .

INPUT FROM VALUE(INPUT FRAME fPage0 f-arq-sitef) NO-CONVERT .

REPEAT ON ERROR UNDO , LEAVE ON STOP UNDO , LEAVE
    :
    IMPORT UNFORMATTED c-linha .
    ASSIGN c-linha = REPLACE(c-linha,'"',"") .
    IF c-linha = "" THEN NEXT .
    IF ENTRY(1,c-linha,";") <> "10" THEN NEXT .
    /**/
    ASSIGN f-tot-linhas = f-tot-linhas + 1 .
    IF f-tot-linhas MOD 100 = 0 THEN DO:
        RUN pi-acompanhar IN h-acomp (INPUT "Lendo Arquivo... Linha: " + STRING(f-tot-linhas) ) .
    END.
    CREATE tt-arq-sitef . ASSIGN
        tt-arq-sitef.linha                  = f-tot-linhas
        tt-arq-sitef.l_encontrado           = NO
        tt-arq-sitef.cod_estab_arq          = ENTRY(03 , c-linha , ';')
        tt-arq-sitef.cod_estab_conv         = STRING(INT(ENTRY(24 , c-linha , ';')) , "999")
        tt-arq-sitef.cod_res_vda            = ENTRY(05 , c-linha , ';')
        tt-arq-sitef.cod_comprov_vda        = ENTRY(06 , c-linha , ';')
        tt-arq-sitef.cod_nsu_sitef          = ENTRY(07 , c-linha , ';')
        tt-arq-sitef.cod_autoriz_cartao_cr  = ENTRY(25 , c-linha , ';')
        tt-arq-sitef.cod_cupom              = ENTRY(26 , c-linha , ';')
        tt-arq-sitef.cod_admdra_arq         = ENTRY(27 , c-linha , ';')
        tt-arq-sitef.cod_admdra_conv        = ""
        tt-arq-sitef.parcela                = ENTRY(15 , c-linha , ';')
        tt-arq-sitef.val_bruto              = DECIMAL(ENTRY(09 , c-linha , ';')) / 100
        tt-arq-sitef.val_taxa               = DECIMAL(ENTRY(22 , c-linha , ';')) / 100
        tt-arq-sitef.val_liquido            = DECIMAL(ENTRY(11 , c-linha , ';')) / 100
        tt-arq-sitef.cod_banco              = STRING(DECIMAL(ENTRY(19 , c-linha , ';')) , "999")
        tt-arq-sitef.cod_agencia            = STRING(DECIMAL(ENTRY(20 , c-linha , ';')) , "9999")
        tt-arq-sitef.cod_conta_corrente     = STRING(DECIMAL(ENTRY(21 , c-linha , ';')) , "999999999")
        tt-arq-sitef.dig_conta_corrente     = SUBSTRING(tt-arq-sitef.cod_conta_corrente , LENGTH(tt-arq-sitef.cod_conta_corrente) , 1)
        tt-arq-sitef.cod_conta_corrente     = SUBSTRING(tt-arq-sitef.cod_conta_corrente , 1 , LENGTH(tt-arq-sitef.cod_conta_corrente) - 1)
        .
    ASSIGN f-tot-nencontrados = f-tot-nencontrados + 1 .
    IF tt-arq-sitef.parcela = "00" THEN DO:
        ASSIGN tt-arq-sitef.parcela = "01" .
    END.

    FOR FIRST tit_acr_cartao NO-LOCK
        WHERE tit_acr_cartao.num_cupom                   = ("0" + tt-arq-sitef.cod_cupom)
        AND   TRIM(tit_acr_cartao.cod_autoriz_cartao_cr) = tt-arq-sitef.cod_autoriz_cartao_cr
        AND   tit_acr_cartao.cod_parc                    = tt-arq-sitef.parcela query-tuning(no-lookahead).
    END.

    IF NOT AVAIL tit_acr_cartao THEN DO:

        FOR FIRST b-tit_acr_cartao NO-LOCK
            WHERE b-tit_acr_cartao.num_cupom                   = ("0" + tt-arq-sitef.cod_cupom)
            AND   TRIM(b-tit_acr_cartao.cod_autoriz_cartao_cr) = tt-arq-sitef.cod_autoriz_cartao_cr ,
            FIRST fat-duplic NO-LOCK
            WHERE fat-duplic.cod-estabel    = b-tit_acr_cartao.cod_estab
              AND fat-duplic.serie          = b-tit_acr_cartao.serie_cupom
              AND fat-duplic.nr-fatura      = b-tit_acr_cartao.num_cupom
              AND fat-duplic.cod-esp        = "CC"  query-tuning(no-lookahead)
            BY fat-duplic.parcela :
                ASSIGN tt-arq-sitef.parcela = "0" + STRING(INT(tt-arq-sitef.parcela) + INT(fat-duplic.parcela) - 1).
        END.

    END.

    /* Busca da Conta Corrente */
    FOR FIRST cta_corren NO-LOCK 
        WHERE cta_corren.cod_banco              = tt-arq-sitef.cod_banco
        AND   cta_corren.cod_agenc_bcia         = tt-arq-sitef.cod_agencia
        AND   cta_corren.cod_cta_corren_bco     = tt-arq-sitef.cod_conta_corrente
        AND   cta_corren.cod_digito_cta_corren  = tt-arq-sitef.dig_conta_corrente
        :
        ASSIGN tt-arq-sitef.cod_cta_corren_erp = cta_corren.cod_cta_corren .
    END.
    IF tt-arq-sitef.cod_cta_corren_erp = "" THEN DO:
        ASSIGN i-msg = 1 .
        LEAVE .
    END.
END.

INPUT CLOSE .

{&open-query-brTable1}

{&open-query-brTable2}

DISPLAY
    f-tot-linhas
    f-tot-nencontrados
    f-tot-encontrados
    WITH FRAME fPage1 .

IF VALID-HANDLE(h-acomp) THEN RUN pi-finalizar IN h-acomp.

IF i-msg = 0 THEN DO:
    RUN setEnabled IN hFolder(INPUT 2 , INPUT NO) .
    RUN setFolder IN hFolder(INPUT 1) . 
END.
IF i-msg = 1 THEN DO:
    RUN utp/ut-msgs.p 
        ("show" , "17242" , "N∆o encontrado conta corrente" + "~~" + 
         "Com os dados do arquivo n∆o foi possivel encontrar a conta corrente do sistema." + "~n" +
         "Linha: " + STRING(f-tot-linhas) )
        .
END.

/**/
RETURN "OK":U .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-goPage1 wWindow 
PROCEDURE pi-goPage1 :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
DEF VAR h-acomp AS HANDLE NO-UNDO .
RUN utp/ut-acomp.p PERSISTENT SET h-acomp .
RUN pi-inicializar IN h-acomp (INPUT "Processando") .
RUN pi-acompanhar IN h-acomp (INPUT "Buscando Titulos...") .

DEF VAR i-cont  AS INT NO-UNDO .

EMPTY TEMP-TABLE tt_tit_acr_cartao .
ASSIGN f-tot-encontrados = 0 .

FOR EACH tt-arq-sitef
    :
    ASSIGN i-cont = i-cont + 1 .
    IF i-cont MOD 100 = 0 THEN DO:
        RUN pi-acompanhar IN h-acomp (INPUT "Buscando Titulos... Cont: " + STRING(i-cont) ) .
    END.

    FOR EACH tit_acr_cartao NO-LOCK
        WHERE tit_acr_cartao.num_cupom                   = ("0" + tt-arq-sitef.cod_cupom)
        AND   TRIM(tit_acr_cartao.cod_autoriz_cartao_cr) = tt-arq-sitef.cod_autoriz_cartao_cr
        AND   tit_acr_cartao.cod_parc                    = tt-arq-sitef.parcela  ,  
        FIRST tit_acr NO-LOCK 
        WHERE tit_acr.cod_estab = tit_acr_cartao.cod_estab
        AND   tit_acr.num_id_tit_acr = tit_acr_cartao.num_id_tit_acr
        :

        IF tit_acr_cartao.cod_refer_lote_liq <> "" THEN DO:
            IF NOT CAN-FIND(FIRST movto_tit_acr
                        WHERE movto_tit_acr.cod_estab = tit_acr_cartao.cod_estab_liq
                        AND   movto_tit_acr.cod_refer = tit_acr_cartao.cod_refer_lote_liq
                        AND   movto_tit_acr.num_id_tit_acr = tt_tit_acr_cartao.num_id_tit_acr ) AND
               NOT CAN-FIND(FIRST item_lote_liquidac_acr
                        WHERE item_lote_liquidac_acr.cod_estab_refer    = tit_acr_cartao.cod_estab_liq
                        AND   item_lote_liquidac_acr.cod_refer          = tit_acr_cartao.cod_refer_lote_liq
                        AND   item_lote_liquidac_acr.cod_estab          = tit_acr.cod_estab       
                        AND   item_lote_liquidac_acr.cod_espec_docto    = tit_acr.cod_espec_docto 
                        AND   item_lote_liquidac_acr.cod_ser_docto      = tit_acr.cod_ser_docto   
                        AND   item_lote_liquidac_acr.cod_tit_acr        = tit_acr.cod_tit_acr     
                        AND   item_lote_liquidac_acr.cod_parcela        = tit_acr.cod_parcela )    
            THEN DO:
                BUFFER tit_acr_cartao:FIND-CURRENT(EXCLUSIVE) .
                ASSIGN
                    tit_acr_cartao.cod_estab_liq = ""
                    tit_acr_cartao.cod_refer_lote_liq = ""
                    .
            END.
        END.
        ASSIGN tt-arq-sitef.l_encontrado = YES .
        CREATE tt_tit_acr_cartao . 
        BUFFER-COPY tit_acr_cartao TO tt_tit_acr_cartao .
        ASSIGN
            tt_tit_acr_cartao.r_rowid = ROWID(tit_acr_cartao)
            tt_tit_acr_cartao.linha_arq = tt-arq-sitef.linha
            tt_tit_acr_cartao.val_liquido = tt_tit_acr_cartao.val_comprov_vda - tt_tit_acr_cartao.val_des_admdra
            tt_tit_acr_cartao.val_diverg = tt-arq-sitef.val_liquido - tt_tit_acr_cartao.val_liquido
            tt_tit_acr_cartao.val_sdo_tit_acr = tit_acr.val_sdo_tit_acr 
            .

        FOR FIRST portad_finalid_econ NO-LOCK
            WHERE portad_finalid_econ.cod_estab = tit_acr_cartao.cod_estab
            AND   portad_finalid_econ.cod_cta_corren = tt-arq-sitef.cod_cta_corren_erp
            AND   portad_finalid_econ.cod_cart_bcia = "CAR"
            :
            ASSIGN
                tt_tit_acr_cartao.cod_portador = portad_finalid_econ.cod_portador
                tt_tit_acr_cartao.cod_cart_bcia = portad_finalid_econ.cod_cart_bcia
                .
        END.

        ASSIGN f-tot-encontrados = f-tot-encontrados + 1 .
        ASSIGN f-tot-nencontrados = f-tot-nencontrados - 1 .
    END.
END.

{&open-query-brTable1}

{&open-query-brTable2}

DISPLAY
    f-tot-linhas
    f-tot-nencontrados
    f-tot-encontrados
    WITH FRAME fPage1 .

DISPLAY
    f-tot-encontrados
    WITH FRAME fPage2 .

RUN setEnabled IN hFolder(INPUT 2 , INPUT YES) .
RUN setFolder IN hFolder(INPUT 2) . 

/**/
IF VALID-HANDLE(h-acomp) THEN RUN pi-finalizar IN h-acomp.
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
RUN pi-acompanhar IN h-acomp (INPUT "Criando Lotes Liquidaá∆o...") .

DEF VAR i-cont  AS INT NO-UNDO .

DEF VAR v_cod_refer             AS CHAR NO-UNDO .
DEF VAR v_num_seq_refer         AS INT NO-UNDO .
DEF VAR v_val_liquidac_tit_acr  AS DECIMAL NO-UNDO .
DEF VAR v_val_sdo_tit_acr       AS DECIMAL NO-UNDO .

TRA1:
DO TRANSACTION ON ERROR UNDO , LEAVE ON STOP UNDO , LEAVE
    :
    FOR EACH tt_tit_acr_cartao 
        WHERE tt_tit_acr_cartao.cod_refer_lote_liq = ""
        AND   tt_tit_acr_cartao.val_sdo_tit_acr > 0
        AND   tt_tit_acr_cartao.cod_portador <> ""
        AND   tt_tit_acr_cartao.cod_cart_bcia <> ""
        BREAK         
        BY tt_tit_acr_cartao.cod_portador        
        BY tt_tit_acr_cartao.cod_cart_bcia
        BY tt_tit_acr_cartao.num_id_tit_acr
        :
        IF FIRST-OF(tt_tit_acr_cartao.cod_cart_bcia) THEN DO:
            RUN utils/geraReferenciaEMS5_v2.p(INPUT "L" , INPUT TODAY , OUTPUT v_cod_refer) .
            CREATE lote_liquidac_acr . ASSIGN
                lote_liquidac_acr.cod_empresa               = i-ep-codigo-usuario
                lote_liquidac_acr.cod_estab_refer           = "973"
                lote_liquidac_acr.cod_refer                 = v_cod_refer
                lote_liquidac_acr.cod_usuario               = c-seg-usuario
                lote_liquidac_acr.cod_portador              = tt_tit_acr_cartao.cod_portador
                lote_liquidac_acr.cod_cart_bcia             = tt_tit_acr_cartao.cod_cart_bcia
                lote_liquidac_acr.dat_gerac_lote_liquidac   = TODAY
                lote_liquidac_acr.ind_tip_liquidac_acr      = "Lote"
                lote_liquidac_acr.ind_sit_lote_liquidac_acr = "Em Digitaá∆o"
                lote_liquidac_acr.log_liq_varios_estab      = YES
                .
            ASSIGN v_num_seq_refer = 0 .
            ASSIGN i-cont = i-cont + 1 .
        END.

        FOR FIRST tit_acr_cartao
            WHERE ROWID(tit_acr_cartao) = tt_tit_acr_cartao.r_rowid
            :
            ASSIGN
                tt_tit_acr_cartao.cod_estab_liq         = lote_liquidac_acr.cod_estab_refer
                tt_tit_acr_cartao.cod_refer_lote_liq    = lote_liquidac_acr.cod_refer
                .
            ASSIGN
                tit_acr_cartao.cod_estab_liq            = tt_tit_acr_cartao.cod_estab_liq
                tit_acr_cartao.cod_refer_lote_liq       = tt_tit_acr_cartao.cod_refer_lote_liq
                .
        END.

        IF FIRST-OF(tt_tit_acr_cartao.num_id_tit_acr) THEN DO:
            ASSIGN v_val_liquidac_tit_acr = 0 .
        END.

        FIND FIRST tt-arq-sitef NO-LOCK WHERE
            tt-arq-sitef.linha = tt_tit_acr_cartao.linha_arq
            .
        ASSIGN v_val_liquidac_tit_acr = v_val_liquidac_tit_acr + tt-arq-sitef.val_liquido .
        
        IF LAST-OF(tt_tit_acr_cartao.num_id_tit_acr) THEN DO:
            FIND FIRST tit_acr NO-LOCK
                WHERE tit_acr.cod_estab = tt_tit_acr_cartao.cod_estab
                AND   tit_acr.num_id_tit_acr = tt_tit_acr_cartao.num_id_tit_acr
                .

            ASSIGN v_val_sdo_tit_acr = tit_acr.val_sdo_tit_acr .
            FOR EACH item_lote_liquidac_acr NO-LOCK
                WHERE item_lote_liquidac_acr.cod_estab              = tit_acr.cod_estab
                AND   item_lote_liquidac_acr.cod_espec_docto        = tit_acr.cod_espec_docto
                AND   item_lote_liquidac_acr.cod_ser_docto          = tit_acr.cod_ser_docto                               
                AND   item_lote_liquidac_acr.cod_tit_acr            = tit_acr.cod_tit_acr
                AND   item_lote_liquidac_acr.cod_parcela            = tit_acr.cod_parcela
                :
                ASSIGN v_val_sdo_tit_acr = v_val_sdo_tit_acr - item_lote_liquidac_acr.val_liquidac_tit_acr .
            END.

            ASSIGN v_num_seq_refer = v_num_seq_refer + 1 .
            CREATE item_lote_liquidac_acr . ASSIGN
                item_lote_liquidac_acr.cod_empresa                  = lote_liquidac_acr.cod_empresa
                item_lote_liquidac_acr.cod_estab_refer              = lote_liquidac_acr.cod_estab_refer
                item_lote_liquidac_acr.cod_refer                    = lote_liquidac_acr.cod_refer
                item_lote_liquidac_acr.num_seq_refer                = v_num_seq_refer 
                item_lote_liquidac_acr.cod_estab                    = tit_acr.cod_estab
                item_lote_liquidac_acr.cod_espec_docto              = tit_acr.cod_espec_docto
                item_lote_liquidac_acr.cod_ser_docto                = tit_acr.cod_ser_docto                               
                item_lote_liquidac_acr.cod_tit_acr                  = tit_acr.cod_tit_acr
                item_lote_liquidac_acr.cod_parcela                  = tit_acr.cod_parcela
                item_lote_liquidac_acr.cdn_cliente                  = tit_acr.cdn_cliente
                item_lote_liquidac_acr.dat_vencto_tit_acr           = tit_acr.dat_vencto_tit_acr
                item_lote_liquidac_acr.cod_portador                 = tt_tit_acr_cartao.cod_portador
                item_lote_liquidac_acr.cod_cart_bcia                = tt_tit_acr_cartao.cod_cart_bcia
                item_lote_liquidac_acr.cod_finalid_econ             = "Corrente"
                item_lote_liquidac_acr.cod_indic_econ               = "Real"
                item_lote_liquidac_acr.dat_cotac_indic_econ         = TODAY
                item_lote_liquidac_acr.val_cotac_indic_econ         = 1
                item_lote_liquidac_acr.dat_prev_liquidac            = tit_acr.dat_prev_liquidac
                item_lote_liquidac_acr.dat_desconto                 = ?
                item_lote_liquidac_acr.dat_cr_liquidac_tit_acr      = INPUT FRAME fPage0 f-dat-trans
                item_lote_liquidac_acr.dat_cr_liquidac_calc         = INPUT FRAME fPage0 f-dat-trans
                item_lote_liquidac_acr.dat_liquidac_tit_acr         = INPUT FRAME fPage0 f-dat-trans
                item_lote_liquidac_acr.val_liquidac_tit_acr         = v_val_liquidac_tit_acr
                item_lote_liquidac_acr.val_desc_tit_acr             = 0
                item_lote_liquidac_acr.val_abat_tit_acr             = 0
                item_lote_liquidac_acr.val_despes_bcia              = 0
                item_lote_liquidac_acr.val_multa_tit_acr            = 0
                item_lote_liquidac_acr.val_juros                    = 0
                item_lote_liquidac_acr.val_cm_tit_acr               = 0
                item_lote_liquidac_acr.val_liquidac_orig            = v_val_liquidac_tit_acr
                item_lote_liquidac_acr.log_gera_antecip             = NO
                item_lote_liquidac_acr.ind_sit_item_lote_liquidac   = "Gerado"
                item_lote_liquidac_acr.ind_tip_item_liquidac_acr    = "Pagamento"
                item_lote_liquidac_acr.ind_tip_calc_juros           = "Simples"
                .
            IF v_val_liquidac_tit_acr > v_val_sdo_tit_acr THEN DO:
                ASSIGN
                    item_lote_liquidac_acr.val_liquidac_tit_acr         = v_val_sdo_tit_acr
                    item_lote_liquidac_acr.val_liquidac_orig            = v_val_sdo_tit_acr
                    item_lote_liquidac_acr.log_gera_antecip             = YES 
                    item_lote_liquidac_acr.val_antecip_gerad            = (v_val_liquidac_tit_acr - v_val_sdo_tit_acr)
                    .
            END.
        END.
    END.
END.

{&open-query-brTable2}

RUN setFolder IN hFolder(INPUT 2) . 

/**/
IF VALID-HANDLE(h-acomp) THEN RUN pi-finalizar IN h-acomp.

RUN utp/ut-msgs.p ("show" , "15825" , "Lotes Gerador: " + STRING (i-cont) ).

RETURN "OK":U .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

