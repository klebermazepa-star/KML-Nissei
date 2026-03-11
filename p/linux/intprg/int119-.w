&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
          emsesp           PROGRESS
*/
&Scoped-define WINDOW-NAME wWindow
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS wWindow 
/********************************************************************************
** Copyright DATASUL S.A. (1999)
** Todos os Direitos Reservados.
**
** Este fonte e de propriedade exclusiva da DATASUL, sua reproducao
** parcial ou total por qualquer meio, so podera ser feita mediante
** autorizacao expressa.
*******************************************************************************/
/*******************************************************************************
**
** Programa: INT119
** Objetivo: Simula‡ao Painel Cadastros INT115
** 
** Parƒmetros:
** Especificidades:
** 
** Autor: AVB
** Data:  agosto/2017
**
*******************************************************************************/
{include/i-prgvrs.i INT119 2.12.02.AVB}
/*{include/wms.i}*/

CREATE WIDGET-POOL.

/* Preprocessors Definitions ---                                      */
&GLOBAL-DEFINE Program        INT119
&GLOBAL-DEFINE Version        2.12.02.AVB

&GLOBAL-DEFINE WindowType     Master

&GLOBAL-DEFINE Folder         YES
&GLOBAL-DEFINE InitialPage    1
&GLOBAL-DEFINE FolderLabels   Cod Trib, Nat Origem

&GLOBAL-DEFINE page0Widgets   btOK btCancel btHelp2 c-class-fiscal bt-confirma i-cod-emitente~
                              c-cod-estabel cEmitEscolha cEstEscolha c-it-codigo cItemEscolha ~
                              c-nat-origem c-operacao tg-contribuinte UF-Cliente UF-Estab
&GLOBAL-DEFINE page1Widgets   
&GLOBAL-DEFINE page2Widgets   

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */
DEF VAR h-acomp AS HANDLE.

/* ++++++++++++++++++ (Definicao Temp Tables) ++++++++++++++++++ */

def new global shared var wh-pesquisa   as widget-handle.
def new global shared var adm-broker-hdl as handle no-undo.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Window
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME fpage0

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS rtToolBar rec-ok c-cod-estabel ~
i-cod-emitente c-it-codigo c-operacao bt-confirma btOK btCancel btHelp2 
&Scoped-Define DISPLAYED-OBJECTS c-cod-estabel cEstEscolha UF-Estab ~
i-cod-emitente cEmitEscolha UF-Cliente tg-contribuinte c-it-codigo ~
cItemEscolha c-class-fiscal c-operacao c-nat-origem 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */
&Scoped-define List-1 int-ds-tp-nat-origem.nat-origem ~
int-ds-tp-trib-natur-oper.uf-origem int-ds-tp-trib-natur-oper.class-fiscal 

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
DEFINE BUTTON bt-confirma 
     IMAGE-UP FILE "image\im-sav":U
     LABEL "bt confirma 2" 
     SIZE 5.14 BY 1.17.

DEFINE BUTTON btCancel 
     LABEL "Cancelar" 
     SIZE 10 BY 1.

DEFINE BUTTON btHelp2 
     LABEL "Ajuda" 
     SIZE 10 BY 1.

DEFINE BUTTON btOK 
     LABEL "OK" 
     SIZE 10 BY 1.

DEFINE VARIABLE c-operacao AS CHARACTER FORMAT "X(256)":U INITIAL "1" 
     LABEL "Tp Pedido" 
     VIEW-AS COMBO-BOX INNER-LINES 10
     LIST-ITEM-PAIRS "TRANSFERENCIA DEPOSITO - FILIAL","1",
                     "TRANSFERENCIA FILIAL - DEPOSITO","2",
                     "BALANCO MANUAL FILIAL","3",
                     "COMPRA FORNECEDOR - FILIAL","4",
                     "COMPRA FORNECEDOR - DEPOSITO","5",
                     "TRANSFERENCIA DEPOSITO - DEPOSITO","6",
                     "ELETRONICO FORNECEDOR - FILIAL","7",
                     "ELETRONICO DEPOSITO - FILIAL","8",
                     "PBM FILIAL","9",
                     "PBM DEPOSITO","10",
                     "BALANCO MANUAL DEPOSITO","11",
                     "BALANCO COLETOR FILIAL","12",
                     "BALANCO COLETOR DEPOSITO","13",
                     "BALANCO MANUAL FILIAL - PERMITE CONSOLIDA€ÇO","14",
                     "DEVOLUCAO FILIAL - FORNECEDOR","15",
                     "DEVOLUCAO DEPOSITO - FORNECEDOR","16",
                     "TRANSFERENCIA DEPOSITO - DEPOSITO (COMERCIALIZAVEL)","17",
                     "TRANSFERENCIA DEPOSITO - DEPOSITO (AVARIA)","18",
                     "TRANSFERENCIA FILIAL - FILIAL","19",
                     "BALANCO MANUAL FILIAL - ESPECIAL (MED. CONTROLADO)","31",
                     "DEVOLUCAO FILIAL - FORNECEDOR (MED. CONTROLADO)","32",
                     "TRANSFERENCIA FILIAL - FORNECEDOR (MED. CONTROLADO)","33",
                     "BALAN€O GERAL CONTROLADOS DEPOSITO","35",
                     "BALAN€O GERAL CONTROLADOS FILIAL","36",
                     "ATIVO IMOBILIZADO DEPOSITO => FILIAL","37",
                     "ESTORNO","38",
                     "ATIVO IMOBILIZADO FILIAL => FILIAL","39",
                     "RETIRADA FILIAL => PROPRIA FILIAL","46",
                     "SUBSTITUI€ÇO DE CUPOM","48",
                     "ESTORNO","51",
                     "ESTORNO","52",
                     "ESTORNO","53"
     DROP-DOWN-LIST
     SIZE 56 BY 1 NO-UNDO.

DEFINE VARIABLE c-class-fiscal AS CHARACTER FORMAT "9999.99.99":U INITIAL "00000000" 
     VIEW-AS FILL-IN 
     SIZE 15 BY .88 NO-UNDO.

DEFINE VARIABLE c-cod-estabel AS CHARACTER FORMAT "X(3)" 
     LABEL "Estab":R7 
     VIEW-AS FILL-IN 
     SIZE 7.29 BY .88.

DEFINE VARIABLE c-it-codigo AS CHARACTER FORMAT "x(16)" 
     LABEL "Item":R5 
     VIEW-AS FILL-IN 
     SIZE 18.57 BY .88.

DEFINE VARIABLE c-nat-origem AS CHARACTER FORMAT "X(8)":U 
     LABEL "Nat Orig" 
     VIEW-AS FILL-IN 
     SIZE 12 BY .88 NO-UNDO.

DEFINE VARIABLE cEmitEscolha AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 61 BY .88 NO-UNDO.

DEFINE VARIABLE cEstEscolha AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 63.57 BY .88 NO-UNDO.

DEFINE VARIABLE cItemEscolha AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 56 BY .88 NO-UNDO.

DEFINE VARIABLE i-cod-emitente AS INTEGER FORMAT ">>>>>>>>9" INITIAL 0 
     LABEL "Cliente":R10 
     VIEW-AS FILL-IN 
     SIZE 9 BY .88.

DEFINE VARIABLE UF-Cliente AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 4.57 BY .88 NO-UNDO.

DEFINE VARIABLE UF-Estab AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 4.57 BY .88 NO-UNDO.

DEFINE RECTANGLE rec-ok
     EDGE-PIXELS 2 GRAPHIC-EDGE    ROUNDED 
     SIZE 4.86 BY 1.04.

DEFINE RECTANGLE rtToolBar
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 101 BY 1.42
     BGCOLOR 7 .

DEFINE VARIABLE tg-contribuinte AS LOGICAL INITIAL no 
     LABEL "Contribuinte" 
     VIEW-AS TOGGLE-BOX
     SIZE 14 BY .83 NO-UNDO.

DEFINE VARIABLE cNatEntEst AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 61 BY .88 NO-UNDO.

DEFINE VARIABLE cNatEntEstNAO AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 61 BY .88 NO-UNDO.

DEFINE VARIABLE cNatEntInter AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 61 BY .88 NO-UNDO.

DEFINE VARIABLE cNatEntInterNAO AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 61 BY .88 NO-UNDO.

DEFINE VARIABLE cNatSaiEst AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 61 BY .88 NO-UNDO.

DEFINE VARIABLE cNatSaiEstNAO AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 61 BY .88 NO-UNDO.

DEFINE VARIABLE cNatSaiInter AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 61 BY .88 NO-UNDO.

DEFINE VARIABLE cNatSaiInterNAO AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 61 BY .88 NO-UNDO.

DEFINE VARIABLE cNCM AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 60 BY .88 NO-UNDO.

DEFINE RECTANGLE RECT-19
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 91 BY 3.75.

DEFINE RECTANGLE RECT-22
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 91 BY 2.75.

DEFINE RECTANGLE RECT-23
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 91 BY 2.75.

DEFINE RECTANGLE RECT-24
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 91 BY 2.75.

DEFINE RECTANGLE RECT-25
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 91 BY 2.75.

DEFINE VARIABLE cNatEntrada AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 61 BY .88 NO-UNDO.

DEFINE VARIABLE cNatEntradaNC AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 61 BY .88 NO-UNDO.

DEFINE VARIABLE cNatOrigem AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 61 BY .88 NO-UNDO.

DEFINE VARIABLE cNatSaida AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 61 BY .88 NO-UNDO.

DEFINE VARIABLE cNatSaidaNC AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 61 BY .88 NO-UNDO.

DEFINE RECTANGLE rt-key
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 88.57 BY 1.75.

DEFINE RECTANGLE rt-mold
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 88.57 BY 2.75.

DEFINE RECTANGLE rt-mold-2
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 88.57 BY 2.75.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME fpage0
     c-cod-estabel AT ROW 1.5 COL 10 COLON-ALIGNED HELP
          "C¢digo do estabelecimento" WIDGET-ID 100
     cEstEscolha AT ROW 1.5 COL 16.57 COLON-ALIGNED NO-LABEL WIDGET-ID 102
     UF-Estab AT ROW 1.5 COL 80 COLON-ALIGNED NO-LABEL WIDGET-ID 112
     i-cod-emitente AT ROW 2.5 COL 10 COLON-ALIGNED WIDGET-ID 98
     cEmitEscolha AT ROW 2.5 COL 19 COLON-ALIGNED NO-LABEL WIDGET-ID 104
     UF-Cliente AT ROW 2.5 COL 80 COLON-ALIGNED NO-LABEL WIDGET-ID 114
     tg-contribuinte AT ROW 2.63 COL 87 WIDGET-ID 132
     c-it-codigo AT ROW 3.54 COL 10 COLON-ALIGNED HELP
          "C¢digo do item" WIDGET-ID 96
     cItemEscolha AT ROW 3.54 COL 28.57 COLON-ALIGNED NO-LABEL WIDGET-ID 106
     c-class-fiscal AT ROW 3.54 COL 84.72 COLON-ALIGNED NO-LABEL WIDGET-ID 134
     c-operacao AT ROW 4.46 COL 10 COLON-ALIGNED WIDGET-ID 138
     bt-confirma AT ROW 4.46 COL 90 WIDGET-ID 124
     c-nat-origem AT ROW 4.58 COL 75 COLON-ALIGNED WIDGET-ID 136
     btOK AT ROW 24.75 COL 3
     btCancel AT ROW 24.75 COL 14
     btHelp2 AT ROW 24.75 COL 92
     rtToolBar AT ROW 24.5 COL 2
     rec-ok AT ROW 4.5 COL 97 WIDGET-ID 126
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 103.29 BY 25.08
         FONT 1.

DEFINE FRAME fPage1
     int-ds-tp-trib-natur-oper.cd-trib-icm AT ROW 1.75 COL 20 NO-LABEL WIDGET-ID 232
          VIEW-AS RADIO-SET HORIZONTAL
          RADIO-BUTTONS 
                    "Tributado":U, 1,
"Isento":U, 2,
"Cesta B sica":U, 3,
"ST":U, 9,
"Outros":U, 4,
"Nenhum":U, 0
          SIZE 62 BY .75
     int-ds-tp-trib-natur-oper.uf-origem AT ROW 2.75 COL 18 COLON-ALIGNED HELP
          "Unidade da federa‡Æo origem (somente para exce‡äes)" WIDGET-ID 296
          VIEW-AS FILL-IN 
          SIZE 4 BY .88
     int-ds-tp-trib-natur-oper.class-fiscal AT ROW 3.75 COL 18 COLON-ALIGNED WIDGET-ID 240
          LABEL "NCM" FORMAT "9999.99.99"
          VIEW-AS FILL-IN 
          SIZE 11.14 BY .88
     cNCM AT ROW 3.75 COL 29 COLON-ALIGNED NO-LABEL WIDGET-ID 258
     int-ds-tp-trib-natur-oper.nat-saida-est AT ROW 5.75 COL 17 COLON-ALIGNED WIDGET-ID 268
          LABEL "Nat. Estadual"
          VIEW-AS FILL-IN 
          SIZE 10 BY .88
     cNatSaiEst AT ROW 5.75 COL 27 COLON-ALIGNED NO-LABEL WIDGET-ID 250
     int-ds-tp-trib-natur-oper.nat-saida-inter AT ROW 6.75 COL 17 COLON-ALIGNED WIDGET-ID 272
          LABEL "Nat. Interestadual"
          VIEW-AS FILL-IN 
          SIZE 10 BY .88
     cNatSaiInter AT ROW 6.75 COL 27 COLON-ALIGNED NO-LABEL WIDGET-ID 254
     int-ds-tp-trib-natur-oper.nat-entrada-est AT ROW 8.75 COL 17 COLON-ALIGNED WIDGET-ID 260
          LABEL "Nat. Estadual"
          VIEW-AS FILL-IN 
          SIZE 10 BY .88
     cNatEntEst AT ROW 8.75 COL 27 COLON-ALIGNED NO-LABEL WIDGET-ID 242
     int-ds-tp-trib-natur-oper.nat-entrada-inter AT ROW 9.75 COL 17 COLON-ALIGNED WIDGET-ID 264
          LABEL "Nat. Interestadual"
          VIEW-AS FILL-IN 
          SIZE 10 BY .88
     cNatEntInter AT ROW 9.75 COL 27 COLON-ALIGNED NO-LABEL WIDGET-ID 246
     int-ds-tp-trib-natur-oper.nat-saida-est-nao-contrib AT ROW 11.75 COL 17 COLON-ALIGNED WIDGET-ID 270
          LABEL "Nat. Estadual"
          VIEW-AS FILL-IN 
          SIZE 10 BY .88
     cNatSaiEstNAO AT ROW 11.75 COL 27 COLON-ALIGNED NO-LABEL WIDGET-ID 252
     int-ds-tp-trib-natur-oper.nat-saida-inter-nao-contrib AT ROW 12.75 COL 17 COLON-ALIGNED WIDGET-ID 274
          LABEL "Nat. Interestadual"
          VIEW-AS FILL-IN 
          SIZE 10 BY .88
     cNatSaiInterNAO AT ROW 12.75 COL 27 COLON-ALIGNED NO-LABEL WIDGET-ID 256
     int-ds-tp-trib-natur-oper.nat-entrada-est-nao-contrib AT ROW 14.75 COL 17 COLON-ALIGNED WIDGET-ID 262
          LABEL "Nat. Estadual"
          VIEW-AS FILL-IN 
          SIZE 10 BY .88
     cNatEntEstNAO AT ROW 14.75 COL 27 COLON-ALIGNED NO-LABEL WIDGET-ID 244
     int-ds-tp-trib-natur-oper.nat-entrada-inter-nao-contrib AT ROW 15.75 COL 17 COLON-ALIGNED WIDGET-ID 266
          LABEL "Nat. Interestadual"
          VIEW-AS FILL-IN 
          SIZE 10 BY .88
     cNatEntInterNAO AT ROW 15.75 COL 27 COLON-ALIGNED NO-LABEL WIDGET-ID 248
     "Sa¡das p/ Contribuinte" VIEW-AS TEXT
          SIZE 20 BY .67 AT ROW 5 COL 4 WIDGET-ID 294
     "Tributa‡Æo ICMS:" VIEW-AS TEXT
          SIZE 15 BY .67 AT ROW 1.75 COL 5 WIDGET-ID 292
     "Entradas NAO Contribuinte" VIEW-AS TEXT
          SIZE 23 BY .67 AT ROW 14 COL 4 WIDGET-ID 290
     "Entradas p/ Contribuinte" VIEW-AS TEXT
          SIZE 21 BY .67 AT ROW 8 COL 4 WIDGET-ID 288
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 3.57 ROW 7
         SIZE 99.43 BY 17.25
         FONT 1.

/* DEFINE FRAME statement is approaching 4K Bytes.  Breaking it up   */
DEFINE FRAME fPage1
     "Sa¡das NAO Contribuinte" VIEW-AS TEXT
          SIZE 22 BY .67 AT ROW 11 COL 4 WIDGET-ID 286
     RECT-19 AT ROW 1.25 COL 2 WIDGET-ID 276
     RECT-22 AT ROW 5.25 COL 2 WIDGET-ID 278
     RECT-24 AT ROW 8.25 COL 2 WIDGET-ID 282
     RECT-23 AT ROW 11.25 COL 2 WIDGET-ID 280
     RECT-25 AT ROW 14.25 COL 2 WIDGET-ID 284
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 3.57 ROW 7
         SIZE 99.43 BY 17.25
         FONT 1.

DEFINE FRAME fPage2
     int-ds-tp-nat-origem.nat-origem AT ROW 2.75 COL 15 COLON-ALIGNED WIDGET-ID 2
          VIEW-AS FILL-IN 
          SIZE 12.14 BY .88
     cNatOrigem AT ROW 2.75 COL 27 COLON-ALIGNED NO-LABEL WIDGET-ID 112
     int-ds-tp-nat-origem.nat-saida AT ROW 4.75 COL 15 COLON-ALIGNED WIDGET-ID 208
          VIEW-AS FILL-IN 
          SIZE 12.14 BY .88
     cNatSaida AT ROW 4.75 COL 27 COLON-ALIGNED NO-LABEL WIDGET-ID 204
     int-ds-tp-nat-origem.nat-entrada AT ROW 5.75 COL 15 COLON-ALIGNED WIDGET-ID 114
          VIEW-AS FILL-IN 
          SIZE 12.14 BY .88
     cNatEntrada AT ROW 5.75 COL 27 COLON-ALIGNED NO-LABEL WIDGET-ID 200
     int-ds-tp-nat-origem.nat-saida-nao-contrib AT ROW 7.75 COL 15 COLON-ALIGNED WIDGET-ID 210
          LABEL "Nat. Saida"
          VIEW-AS FILL-IN 
          SIZE 12.14 BY .88
     cNatSaidaNC AT ROW 7.75 COL 27 COLON-ALIGNED NO-LABEL WIDGET-ID 206
     int-ds-tp-nat-origem.nat-entrada-nao-contrib AT ROW 8.75 COL 15 COLON-ALIGNED WIDGET-ID 116
          LABEL "Nat. Entrada"
          VIEW-AS FILL-IN 
          SIZE 12.14 BY .88
     cNatEntradaNC AT ROW 8.75 COL 27 COLON-ALIGNED NO-LABEL WIDGET-ID 202
     "Naturezas NÇO Contribuinte" VIEW-AS TEXT
          SIZE 24 BY .67 AT ROW 7 COL 6 WIDGET-ID 216
     "Naturezas Contribuinte" VIEW-AS TEXT
          SIZE 20 BY .67 AT ROW 4 COL 6 WIDGET-ID 218
     rt-key AT ROW 2.25 COL 4 WIDGET-ID 212
     rt-mold AT ROW 7.25 COL 4 WIDGET-ID 214
     rt-mold-2 AT ROW 4.25 COL 4 WIDGET-ID 194
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 3.57 ROW 7
         SIZE 99.43 BY 17.25
         FONT 1.


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
         TITLE              = ""
         HEIGHT             = 25.08
         WIDTH              = 104
         MAX-HEIGHT         = 29.46
         MAX-WIDTH          = 182.86
         VIRTUAL-HEIGHT     = 29.46
         VIRTUAL-WIDTH      = 182.86
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _INCLUDED-LIB wWindow 
/* ************************* Included-Libraries *********************** */

{window/window.i}

/* _UIB-CODE-BLOCK-END */
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
/* SETTINGS FOR FILL-IN c-class-fiscal IN FRAME fpage0
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN c-nat-origem IN FRAME fpage0
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN cEmitEscolha IN FRAME fpage0
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN cEstEscolha IN FRAME fpage0
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN cItemEscolha IN FRAME fpage0
   NO-ENABLE                                                            */
/* SETTINGS FOR TOGGLE-BOX tg-contribuinte IN FRAME fpage0
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN UF-Cliente IN FRAME fpage0
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN UF-Estab IN FRAME fpage0
   NO-ENABLE                                                            */
/* SETTINGS FOR FRAME fPage1
                                                                        */
/* SETTINGS FOR RADIO-SET int-ds-tp-trib-natur-oper.cd-trib-icm IN FRAME fPage1
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN int-ds-tp-trib-natur-oper.class-fiscal IN FRAME fPage1
   NO-ENABLE 1 EXP-LABEL EXP-FORMAT                                     */
/* SETTINGS FOR FILL-IN cNatEntEst IN FRAME fPage1
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN cNatEntEstNAO IN FRAME fPage1
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN cNatEntInter IN FRAME fPage1
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN cNatEntInterNAO IN FRAME fPage1
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN cNatSaiEst IN FRAME fPage1
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN cNatSaiEstNAO IN FRAME fPage1
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN cNatSaiInter IN FRAME fPage1
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN cNatSaiInterNAO IN FRAME fPage1
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN cNCM IN FRAME fPage1
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN int-ds-tp-trib-natur-oper.nat-entrada-est IN FRAME fPage1
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN int-ds-tp-trib-natur-oper.nat-entrada-est-nao-contrib IN FRAME fPage1
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN int-ds-tp-trib-natur-oper.nat-entrada-inter IN FRAME fPage1
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN int-ds-tp-trib-natur-oper.nat-entrada-inter-nao-contrib IN FRAME fPage1
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN int-ds-tp-trib-natur-oper.nat-saida-est IN FRAME fPage1
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN int-ds-tp-trib-natur-oper.nat-saida-est-nao-contrib IN FRAME fPage1
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN int-ds-tp-trib-natur-oper.nat-saida-inter IN FRAME fPage1
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN int-ds-tp-trib-natur-oper.nat-saida-inter-nao-contrib IN FRAME fPage1
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN int-ds-tp-trib-natur-oper.uf-origem IN FRAME fPage1
   NO-ENABLE 1 EXP-HELP                                                 */
/* SETTINGS FOR FRAME fPage2
                                                                        */
/* SETTINGS FOR FILL-IN cNatEntrada IN FRAME fPage2
   NO-DISPLAY NO-ENABLE                                                 */
/* SETTINGS FOR FILL-IN cNatEntradaNC IN FRAME fPage2
   NO-DISPLAY NO-ENABLE                                                 */
/* SETTINGS FOR FILL-IN cNatOrigem IN FRAME fPage2
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN cNatSaida IN FRAME fPage2
   NO-DISPLAY NO-ENABLE                                                 */
/* SETTINGS FOR FILL-IN cNatSaidaNC IN FRAME fPage2
   NO-DISPLAY NO-ENABLE                                                 */
/* SETTINGS FOR FILL-IN int-ds-tp-nat-origem.nat-entrada IN FRAME fPage2
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN int-ds-tp-nat-origem.nat-entrada-nao-contrib IN FRAME fPage2
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN int-ds-tp-nat-origem.nat-origem IN FRAME fPage2
   NO-ENABLE 1                                                          */
/* SETTINGS FOR FILL-IN int-ds-tp-nat-origem.nat-saida IN FRAME fPage2
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN int-ds-tp-nat-origem.nat-saida-nao-contrib IN FRAME fPage2
   NO-ENABLE EXP-LABEL                                                  */
IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(wWindow)
THEN wWindow:HIDDEN = yes.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

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
     _Query            is NOT OPENED
*/  /* FRAME fPage2 */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME wWindow
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL wWindow wWindow
ON END-ERROR OF wWindow
OR ENDKEY OF {&WINDOW-NAME} ANYWHERE DO:
  /* This case occurs when the user presses the "Esc" key.
     In a persistently run window, just ignore this.  If we did not, the
     application would exit. */
  IF THIS-PROCEDURE:PERSISTENT THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL wWindow wWindow
ON WINDOW-CLOSE OF wWindow
DO:
    /* This event will close the window and terminate the procedure.  */
  APPLY "CLOSE":U TO THIS-PROCEDURE.
  RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-confirma
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-confirma wWindow
ON CHOOSE OF bt-confirma IN FRAME fpage0 /* bt confirma 2 */
DO:
    def var c-natureza as character no-undo.
    def var c-natur-ent as character no-undo.
    def var r-rowid as rowid no-undo.

    assign frame fPage0
           c-cod-estabel
           UF-cliente
           UF-Estab
           c-nat-origem
           i-cod-emitente
           c-class-fiscal
           c-operacao.

    run intprg/int115a.p ( input c-operacao    ,
                           input uf-cliente  ,
                           input uf-estab   ,
                           input c-nat-origem  ,
                           input i-cod-emitente,
                           input c-class-fiscal,
                           output c-natureza   ,
                           output c-natur-ent  ,
                           output r-rowid).

    if r-rowid = ? then 
        assign rec-ok:bgcolor = 12.
    else
        assign rec-ok:bgcolor = 10.


    assign  int-ds-tp-trib-natur-oper.uf-origem                         :screen-value in frame fPage1 = ""
            int-ds-tp-trib-natur-oper.class-fiscal                      :screen-value in frame fPage1 = ""
            int-ds-tp-trib-natur-oper.nat-saida-est                     :screen-value in frame fPage1 = ""
            int-ds-tp-trib-natur-oper.nat-saida-inter                   :screen-value in frame fPage1 = ""
            int-ds-tp-trib-natur-oper.nat-entrada-est                   :screen-value in frame fPage1 = ""
            int-ds-tp-trib-natur-oper.nat-entrada-inter                 :screen-value in frame fPage1 = ""
            int-ds-tp-trib-natur-oper.nat-saida-est-nao-contrib         :screen-value in frame fPage1 = ""
            int-ds-tp-trib-natur-oper.nat-saida-inter-nao-contrib       :screen-value in frame fPage1 = ""
            int-ds-tp-trib-natur-oper.nat-entrada-est-nao-contrib       :screen-value in frame fPage1 = ""
            int-ds-tp-trib-natur-oper.nat-entrada-inter-nao-contrib     :screen-value in frame fPage1 = "".

    apply "LEAVE":U to int-ds-tp-trib-natur-oper.nat-saida-est   in frame fPage1.
    apply "LEAVE":U to int-ds-tp-trib-natur-oper.nat-saida-inter in frame fPage1.
    apply "LEAVE":U to int-ds-tp-trib-natur-oper.nat-entrada-est in frame fPage1.
    apply "LEAVE":U to int-ds-tp-trib-natur-oper.nat-entrada-inter in frame fPage1.
    apply "LEAVE":U to int-ds-tp-trib-natur-oper.nat-saida-est-nao-contrib in frame fPage1.
    apply "LEAVE":U to int-ds-tp-trib-natur-oper.nat-saida-inter-nao-contrib in frame fPage1.
    apply "LEAVE":U to int-ds-tp-trib-natur-oper.nat-entrada-est-nao-contrib in frame fPage1.
    apply "LEAVE":U to int-ds-tp-trib-natur-oper.nat-entrada-inter-nao-contrib in frame fPage1.
    apply "LEAVE":U to int-ds-tp-trib-natur-oper.class-fiscal in frame fPage1.

    assign  int-ds-tp-nat-origem.nat-origem             :screen-value in frame fPage2 = ""
            int-ds-tp-nat-origem.nat-saida              :screen-value in frame fPage2 = ""
            int-ds-tp-nat-origem.nat-entrada            :screen-value in frame fPage2 = ""
            int-ds-tp-nat-origem.nat-saida-nao-contrib  :screen-value in frame fPage2 = ""
            int-ds-tp-nat-origem.nat-entrada-nao-contrib:screen-value in frame fPage2 = "".

    apply "LEAVE":U to int-ds-tp-nat-origem.nat-saida   in frame fPage2.
    apply "LEAVE":U to int-ds-tp-nat-origem.nat-saida-nao-contrib in frame fPage2.
    apply "LEAVE":U to int-ds-tp-nat-origem.nat-entrada in frame fPage2.
    apply "LEAVE":U to int-ds-tp-nat-origem.nat-entrada-nao-contrib in frame fPage2.
    apply "LEAVE":U to int-ds-tp-nat-origem.nat-origem in frame fPage2.

    for first int-ds-tp-trib-natur-oper no-lock where 
        rowid(int-ds-tp-trib-natur-oper) = r-rowid:
        run setEnabled in hFolder (input 1, input true).
        run setEnabled in hFolder (input 2, input false).

        display int-ds-tp-trib-natur-oper.cd-trib-icm
                int-ds-tp-trib-natur-oper.uf-origem
                int-ds-tp-trib-natur-oper.class-fiscal
                int-ds-tp-trib-natur-oper.nat-saida-est
                int-ds-tp-trib-natur-oper.nat-saida-inter
                int-ds-tp-trib-natur-oper.nat-entrada-est
                int-ds-tp-trib-natur-oper.nat-entrada-inter
                int-ds-tp-trib-natur-oper.nat-saida-est-nao-contrib
                int-ds-tp-trib-natur-oper.nat-saida-inter-nao-contrib
                int-ds-tp-trib-natur-oper.nat-entrada-est-nao-contrib
                int-ds-tp-trib-natur-oper.nat-entrada-inter-nao-contrib
            with frame fPage1.
    end.

    for first int-ds-tp-nat-origem no-lock where 
        rowid(int-ds-tp-nat-origem) = r-rowid:
        run setEnabled in hFolder (input 1, input false).
        run setEnabled in hFolder (input 2, input true).
        display int-ds-tp-nat-origem.nat-origem
                int-ds-tp-nat-origem.nat-saida
                int-ds-tp-nat-origem.nat-entrada
                int-ds-tp-nat-origem.nat-saida-nao-contrib
                int-ds-tp-nat-origem.nat-entrada-nao-contrib
            with frame fPage2.
        apply "LEAVE":U to int-ds-tp-nat-origem.nat-saida   in frame fPage2.
        apply "LEAVE":U to int-ds-tp-nat-origem.nat-saida-nao-contrib in frame fPage2.
        apply "LEAVE":U to int-ds-tp-nat-origem.nat-entrada in frame fPage2.
        apply "LEAVE":U to int-ds-tp-nat-origem.nat-entrada-nao-contrib in frame fPage2.
        apply "LEAVE":U to int-ds-tp-nat-origem.nat-origem in frame fPage2.

    end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btCancel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btCancel wWindow
ON CHOOSE OF btCancel IN FRAME fpage0 /* Cancelar */
DO:
    APPLY "CLOSE":U TO THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btHelp2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btHelp2 wWindow
ON CHOOSE OF btHelp2 IN FRAME fpage0 /* Ajuda */
DO:
    {include/ajuda.i}
  /* MESSAGE " vai rodar o programa"
        VIEW-AS ALERT-BOX INFO BUTTONS OK.
    RUN men/men900za.p (INPUT SELF:FRAME, INPUT THIS-PROCEDURE:HANDLE).*/
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btOK
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btOK wWindow
ON CHOOSE OF btOK IN FRAME fpage0 /* OK */
DO:
    APPLY "CLOSE":U TO THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME c-cod-estabel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL c-cod-estabel wWindow
ON F5 OF c-cod-estabel IN FRAME fpage0 /* Estab */
OR MOUSE-SELECT-DBLCLICK OF c-cod-estabel in frame {&FRAME-NAME} DO:
        {include/zoomvar.i &prog-zoom=adzoom/z01ad107.w
                                &campo=c-cod-estabel
                                &campozoom=cod-estabel}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL c-cod-estabel wWindow
ON LEAVE OF c-cod-estabel IN FRAME fpage0 /* Estab */
DO:
    display "" @ cEstEscolha 
            "" @ UF-Estab
        with frame {&FRAME-NAME}.

    for first mgadm.estabelec 
        fields (cod-estabel nome estado)
        no-lock where
        mgadm.estabelec.cod-estabel = input frame {&FRAME-NAME} c-cod-estabel.
    end.
    if avail estabelec then
    do:
        display estabelec.nome @ cEstEscolha 
                estabelec.estado @ UF-Estab
            with frame {&FRAME-NAME}.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME c-it-codigo
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL c-it-codigo wWindow
ON F5 OF c-it-codigo IN FRAME fpage0 /* Item */
OR MOUSE-SELECT-DBLCLICK OF c-it-codigo in frame {&FRAME-NAME} DO:
        {include/zoomvar.i &prog-zoom=inzoom/z01in172.w
                                &campo=c-it-codigo
                                &campozoom=it-codigo}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL c-it-codigo wWindow
ON LEAVE OF c-it-codigo IN FRAME fpage0 /* Item */
DO:
    display "" @ cItemEscolha 
            "" @ c-Class-Fiscal
        with frame {&FRAME-NAME}.
    for first item 
        fields (it-codigo desc-item compr-fabric class-fiscal)
        no-lock where
        item.it-codigo = input frame {&FRAME-NAME} c-it-codigo:
    end.
    if avail item then
    do:
        display item.desc-item @ cItemEscolha 
                item.class-fiscal @ c-Class-Fiscal
            with frame {&FRAME-NAME}.
    end.  
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME c-operacao
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL c-operacao wWindow
ON VALUE-CHANGED OF c-operacao IN FRAME fpage0 /* Tp Pedido */
DO:
    run setEnabled in hFolder (input 1, input yes).
    run setEnabled in hFolder (input 2, input no).
    run SetFolder IN hFolder (INPUT 1).
    
    assign c-nat-origem:sensitive in FRAME {&FRAME-NAME} = no.
    for each int-ds-tipo-pedido no-lock where 
        int-ds-tipo-pedido.tp-pedido = c-operacao:screen-value in FRAME {&FRAME-NAME}:
        for each int-ds-mod-pedido no-lock where 
            int-ds-mod-pedido.cod-mod-pedido = int-ds-tipo-pedido.cod-mod-pedido:
            assign c-nat-origem:sensitive in FRAME {&FRAME-NAME} = int-ds-mod-pedido.log-nat-origem.

            if int-ds-mod-pedido.log-nat-origem then do:
                run setEnabled in hFolder (input 1, input no).
                run setEnabled in hFolder (input 2, input yes).
                run SetFolder IN hFolder (INPUT 2).
            end.
            else do:
                run setEnabled in hFolder (input 1, input yes).
                run setEnabled in hFolder (input 2, input no).
                run SetFolder IN hFolder (INPUT 1).
            end.
        end.
    end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME fPage1
&Scoped-define SELF-NAME int-ds-tp-trib-natur-oper.class-fiscal
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL int-ds-tp-trib-natur-oper.class-fiscal wWindow
ON LEAVE OF int-ds-tp-trib-natur-oper.class-fiscal IN FRAME fPage1 /* NCM */
DO:
    cNCM:screen-value in frame fPage1 = "".
    for first classif-fisc 
        fields (class-fiscal descricao)
        no-lock where 
        classif-fisc.class-fiscal = input frame fPage1 int-ds-tp-trib-natur-oper.class-fiscal.
        display classif-fisc.descricao @ cNCM with frame fPage1.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME fpage0
&Scoped-define SELF-NAME i-cod-emitente
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL i-cod-emitente wWindow
ON F5 OF i-cod-emitente IN FRAME fpage0 /* Cliente */
OR MOUSE-SELECT-DBLCLICK OF i-cod-emitente in frame {&FRAME-NAME} DO:
        {include/zoomvar.i &prog-zoom=adzoom/z01ad098.w
                                &campo=i-cod-emitente
                                &campozoom=cod-emitente}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL i-cod-emitente wWindow
ON LEAVE OF i-cod-emitente IN FRAME fpage0 /* Cliente */
DO:
    display "" @ cEmitEscolha 
            "" @ uf-Cliente
            
        with frame {&FRAME-NAME}.
    tg-contribuinte:screen-value = "No".
    for first mgadm.emitente 
        fields (cod-emitente nome-emit estado cidade contrib-icms)
        no-lock where
        mgadm.emitente.cod-emitente = input frame {&FRAME-NAME} i-cod-emitente.
    end.
    if avail emitente then
    do:
        display emitente.nome-emit @ cEmitEscolha 
                emitente.estado @ uf-Cliente
                
            with frame {&FRAME-NAME}.
        tg-contribuinte:screen-value = string(emitente.contrib-icms).
    end.  
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME fPage2
&Scoped-define SELF-NAME int-ds-tp-nat-origem.nat-entrada
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL int-ds-tp-nat-origem.nat-entrada wWindow
ON LEAVE OF int-ds-tp-nat-origem.nat-entrada IN FRAME fPage2 /* Nat. Entrada */
DO:
    cNatEntrada:screen-value in frame fPage2 = "".
    for first mgind.natur-oper 
        fields (nat-operacao denominacao)
        no-lock where
        mgind.natur-oper.nat-operacao = input frame fPage2 int-ds-tp-nat-origem.nat-entrada:
        display natur-oper.denominacao @ cNatEntrada with frame fPage2.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME fPage1
&Scoped-define SELF-NAME int-ds-tp-trib-natur-oper.nat-entrada-est
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL int-ds-tp-trib-natur-oper.nat-entrada-est wWindow
ON LEAVE OF int-ds-tp-trib-natur-oper.nat-entrada-est IN FRAME fPage1 /* Nat. Estadual */
DO:
    cNatEntEst:screen-value in frame fPage1 = "".
    for first mgind.natur-oper 
        fields (nat-operacao denominacao)
        no-lock where
        mgind.natur-oper.nat-operacao = input frame fPage1 int-ds-tp-trib-natur-oper.nat-Entrada-Est.
        display natur-oper.denominacao @ cNatEntEst with frame fPage1.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME int-ds-tp-trib-natur-oper.nat-entrada-est-nao-contrib
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL int-ds-tp-trib-natur-oper.nat-entrada-est-nao-contrib wWindow
ON LEAVE OF int-ds-tp-trib-natur-oper.nat-entrada-est-nao-contrib IN FRAME fPage1 /* Nat. Estadual */
DO:
    cNatEntEstNAO:screen-value in frame fPage1 = "".
    for first mgind.natur-oper 
        fields (nat-operacao denominacao)
        no-lock where
        mgind.natur-oper.nat-operacao = input frame fPage1 int-ds-tp-trib-natur-oper.nat-entrada-est-nao-contrib.
        display natur-oper.denominacao @ cNatEntEstNAO with frame fPage1.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME int-ds-tp-trib-natur-oper.nat-entrada-inter
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL int-ds-tp-trib-natur-oper.nat-entrada-inter wWindow
ON LEAVE OF int-ds-tp-trib-natur-oper.nat-entrada-inter IN FRAME fPage1 /* Nat. Interestadual */
DO:
    cNatEntInter:screen-value in frame fPage1 = "".
    for first mgind.natur-oper 
        fields (nat-operacao denominacao)
        no-lock where
        mgind.natur-oper.nat-operacao = input frame fPage1 int-ds-tp-trib-natur-oper.nat-Entrada-inter.
        display natur-oper.denominacao @ cNatEntInter with frame fPage1.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME int-ds-tp-trib-natur-oper.nat-entrada-inter-nao-contrib
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL int-ds-tp-trib-natur-oper.nat-entrada-inter-nao-contrib wWindow
ON LEAVE OF int-ds-tp-trib-natur-oper.nat-entrada-inter-nao-contrib IN FRAME fPage1 /* Nat. Interestadual */
DO:
    cNatEntInterNAO:screen-value in frame fPage1 = "".
    for first mgind.natur-oper 
        fields (nat-operacao denominacao)
        no-lock where
        mgind.natur-oper.nat-operacao = input frame fPage1 int-ds-tp-trib-natur-oper.nat-Entrada-Inter-nao-contrib.
        display natur-oper.denominacao @ cNatEntInterNAO with frame fPage1.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME fPage2
&Scoped-define SELF-NAME int-ds-tp-nat-origem.nat-entrada-nao-contrib
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL int-ds-tp-nat-origem.nat-entrada-nao-contrib wWindow
ON LEAVE OF int-ds-tp-nat-origem.nat-entrada-nao-contrib IN FRAME fPage2 /* Nat. Entrada */
DO:
    cNatEntradaNC:screen-value in frame fPage2 = "".
    for first mgind.natur-oper 
        fields (nat-operacao denominacao)
        no-lock where
        mgind.natur-oper.nat-operacao = input frame fPage2 int-ds-tp-nat-origem.nat-Entrada-nao-contrib.
        display natur-oper.denominacao @ cNatEntradaNC with frame fPage2.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME int-ds-tp-nat-origem.nat-origem
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL int-ds-tp-nat-origem.nat-origem wWindow
ON LEAVE OF int-ds-tp-nat-origem.nat-origem IN FRAME fPage2 /* Nat. Origem */
DO:
    cNatOrigem:screen-value in frame fPage2 = "".
    for first mgind.natur-oper 
        fields (nat-operacao denominacao)
        no-lock where
        mgind.natur-oper.nat-operacao = input frame fPage2 int-ds-tp-nat-origem.nat-origem:
        display natur-oper.denominacao @ cNatOrigem with frame fPage2.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME int-ds-tp-nat-origem.nat-saida
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL int-ds-tp-nat-origem.nat-saida wWindow
ON LEAVE OF int-ds-tp-nat-origem.nat-saida IN FRAME fPage2 /* Nat. Saida */
DO:
    cNatSaida:screen-value in frame fPage2 = "".
    for first mgind.natur-oper 
        fields (nat-operacao denominacao)
        no-lock where
        mgind.natur-oper.nat-operacao = input frame fPage2 int-ds-tp-nat-origem.nat-saida:
        display natur-oper.denominacao @ cNatSaida with frame fPage2.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME fPage1
&Scoped-define SELF-NAME int-ds-tp-trib-natur-oper.nat-saida-est
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL int-ds-tp-trib-natur-oper.nat-saida-est wWindow
ON LEAVE OF int-ds-tp-trib-natur-oper.nat-saida-est IN FRAME fPage1 /* Nat. Estadual */
DO:
    cNatSaiEst:screen-value in frame fPage1 = "".
    for first mgind.natur-oper 
        fields (nat-operacao denominacao)
        no-lock where
        mgind.natur-oper.nat-operacao = input frame fPage1 int-ds-tp-trib-natur-oper.nat-saida-est.
        display natur-oper.denominacao @ cNatSaiEst with frame fPage1.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME int-ds-tp-trib-natur-oper.nat-saida-est-nao-contrib
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL int-ds-tp-trib-natur-oper.nat-saida-est-nao-contrib wWindow
ON LEAVE OF int-ds-tp-trib-natur-oper.nat-saida-est-nao-contrib IN FRAME fPage1 /* Nat. Estadual */
DO:
    cNatSaiEstNAO:screen-value in frame fPage1 = "".
    for first mgind.natur-oper 
        fields (nat-operacao denominacao)
        no-lock where
        mgind.natur-oper.nat-operacao = input frame fPage1 int-ds-tp-trib-natur-oper.nat-saida-est-nao-contrib.
        display natur-oper.denominacao @ cNatSaiEstNAO with frame fPage1.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME int-ds-tp-trib-natur-oper.nat-saida-inter
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL int-ds-tp-trib-natur-oper.nat-saida-inter wWindow
ON LEAVE OF int-ds-tp-trib-natur-oper.nat-saida-inter IN FRAME fPage1 /* Nat. Interestadual */
DO:
    cNatSaiInter:screen-value in frame fPage1 = "".
    for first mgind.natur-oper 
        fields (nat-operacao denominacao)
        no-lock where
        mgind.natur-oper.nat-operacao = input frame fPage1 int-ds-tp-trib-natur-oper.nat-saida-inter.
        display natur-oper.denominacao @ cNatSaiInter with frame fPage1.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME int-ds-tp-trib-natur-oper.nat-saida-inter-nao-contrib
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL int-ds-tp-trib-natur-oper.nat-saida-inter-nao-contrib wWindow
ON LEAVE OF int-ds-tp-trib-natur-oper.nat-saida-inter-nao-contrib IN FRAME fPage1 /* Nat. Interestadual */
DO:
    cNatSaiInterNAO:screen-value in frame fPage1 = "".
    for first mgind.natur-oper 
        fields (nat-operacao denominacao)
        no-lock where
        mgind.natur-oper.nat-operacao = input frame fPage1 int-ds-tp-trib-natur-oper.nat-saida-Inter-nao-contrib.
        display natur-oper.denominacao @ cNatSaiInterNAO with frame fPage1.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME fPage2
&Scoped-define SELF-NAME int-ds-tp-nat-origem.nat-saida-nao-contrib
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL int-ds-tp-nat-origem.nat-saida-nao-contrib wWindow
ON LEAVE OF int-ds-tp-nat-origem.nat-saida-nao-contrib IN FRAME fPage2 /* Nat. Saida */
DO:
    cNatSaidaNC:screen-value in frame fPage2 = "".
    for first mgind.natur-oper 
        fields (nat-operacao denominacao)
        no-lock where
        mgind.natur-oper.nat-operacao = input frame fPage2 int-ds-tp-nat-origem.nat-Saida-nao-contrib:
        display natur-oper.denominacao @ cNatSaidaNC with frame fPage2.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME fpage0
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK wWindow 


/*--- L¢gica para inicializa‡Æo do programam ---*/
{window/MainBlock.i}

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
    /* desabilita folders de itens calculados */
    run setEnabled in hFolder (input 1, input false).
    run setEnabled in hFolder (input 2, input false).

    
    int-ds-tp-trib-natur-oper.nat-saida-est:LOAD-MOUSE-POINTER("image/lupa.cur":U) IN FRAME fPage1.
    int-ds-tp-trib-natur-oper.nat-saida-inter :LOAD-MOUSE-POINTER("image/lupa.cur":U) IN FRAME fPage1.
    int-ds-tp-trib-natur-oper.nat-entrada-est :LOAD-MOUSE-POINTER("image/lupa.cur":U) IN FRAME fPage1.
    int-ds-tp-trib-natur-oper.nat-entrada-inter :LOAD-MOUSE-POINTER("image/lupa.cur":U) IN FRAME fPage1.
    int-ds-tp-trib-natur-oper.nat-saida-est-nao-contrib :LOAD-MOUSE-POINTER("image/lupa.cur":U) IN FRAME fPage1.
    int-ds-tp-trib-natur-oper.nat-saida-inter-nao-contrib :LOAD-MOUSE-POINTER("image/lupa.cur":U) IN FRAME fPage1.
    int-ds-tp-trib-natur-oper.nat-entrada-est-nao-contrib :LOAD-MOUSE-POINTER("image/lupa.cur":U) IN FRAME fPage1.
    int-ds-tp-trib-natur-oper.nat-entrada-inter-nao-contrib :LOAD-MOUSE-POINTER("image/lupa.cur":U) IN FRAME fPage1.
    int-ds-tp-trib-natur-oper.class-fiscal :LOAD-MOUSE-POINTER("image/lupa.cur":U) IN FRAME fPage1.

    int-ds-tp-nat-origem.nat-saida   :LOAD-MOUSE-POINTER("image/lupa.cur":U) IN FRAME fPage2.
    int-ds-tp-nat-origem.nat-saida-nao-contrib :LOAD-MOUSE-POINTER("image/lupa.cur":U) IN FRAME fPage2.
    int-ds-tp-nat-origem.nat-entrada :LOAD-MOUSE-POINTER("image/lupa.cur":U) IN FRAME fPage2.
    int-ds-tp-nat-origem.nat-entrada-nao-contrib :LOAD-MOUSE-POINTER("image/lupa.cur":U) IN FRAME fPage2.
    int-ds-tp-nat-origem.nat-origem :LOAD-MOUSE-POINTER("image/lupa.cur":U) IN FRAME fPage2.

    apply "value-changed":u to c-operacao in frame fPage0.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

