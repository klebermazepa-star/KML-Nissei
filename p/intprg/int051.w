&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
          emsesp           ORACLE
*/
&Scoped-define WINDOW-NAME wWindow


/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE tt-int_ds_pedido NO-UNDO LIKE int_ds_pedido
       field cod-estabel as char format "x(4)"
       field qtde-itens as int format ">>,>>9"
       field serie as char format "x(5)"
       field nr-nota-fis as char format "x(16)"
       field sit-ped as char format "x(20)"
       field dt-ger-ped as date format "99/99/9999"
       field hr-ger-ped as char format "x(10)"
       field dt-ger-nota as date format "99/99/9999"
       field hr-ger-nota as char format "x(10)"
       field ndd-envio as char
       field sit-nfe as char
       FIELD nota-origem AS CHAR
       FIELD nota-destino AS CHAR
       FIELD nome-abrev AS CHAR FORMAT "X(14)"
       FIELD modal-ped AS CHAR FORMAT "X(15)"
       FIELD tipo-ped AS INT FORMAT ">>9"
       field sistema as char format "x(10)"
       index situacao serie dt-ger-ped hr-ger-ped ped_codigo_n
       INDEX hora-gera hr-ger-nota.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS wWindow 
/********************************************************************************
** Copyright DATASUL S.A. (1999)
** Todos os Direitos Reservados.
**
** Este fonte e de propriedade exclusiva da DATASUL, sua reproducao
** parcial ou total por qualquer meio, so podera ser feita mediante
** autorizacao expressa.
*******************************************************************************/
/********************************************************************************
**
** Programa: int051 - Gest∆o de Faturamento Transferàncias CD -> Filiais
**
********************************************************************************/
{include/i-prgvrs.i INT051 2.00.00.000}

CREATE WIDGET-POOL.

/* Preprocessors Definitions ---                                      */
&GLOBAL-DEFINE Program        INT051
&GLOBAL-DEFINE Version        2.00.00.000

&GLOBAL-DEFINE WindowType     Master

&GLOBAL-DEFINE Folder         NO
&GLOBAL-DEFINE InitialPage    1
&GLOBAL-DEFINE FolderLabels   Pedidos

&GLOBAL-DEFINE page0Widgets   btQueryJoins btReportsJoins btExit btHelp ~
                              btOK btCancel btHelp2 btSelecao c-intervalo btAtualiza rs-consulta btItens btAlteraSit btErros
&GLOBAL-DEFINE page1Widgets   brPed

/* Parameters Definitions ---                                           */
/*
DEFINE TEMP-TABLE tt-int_ds_pedido NO-UNDO LIKE int_ds_pedido
      field cod-estabel as char 
      field qtde-itens as int format ">>,>>9"
      field serie as char format "x(5)"
      field nr-nota-fis as char format "x(16)"
      field sit-ped as char format "x(20)"
      field dt-ger-ped as date format "99/99/9999"
      field hr-ger-ped as char format "x(10)"
      field dt-ger-nota as date format "99/99/9999"
      field hr-ger-nota as char format "x(10)"
      field ndd-envio as char
      field sit-nfe as char
      FIELD nota-origem AS CHAR
      FIELD nota-destino AS CHAR
      FIELD nome-abrev AS CHAR FORMAT "X(14)"
      FIELD modal-ped AS CHAR FORMAT "X(15)"
      FIELD tipo-ped AS INT FORMAT ">>9"
      index situacao serie dt-ger-ped hr-ger-ped ped_codigo_n
      INDEX hora-gera hr-ger-nota.
*/

/* Local Variable Definitions --- */       

DEFINE VAR c-estab-orig-ini AS CHAR NO-UNDO.
DEFINE VAR c-estab-orig-fim AS CHAR NO-UNDO.
DEFINE VAR c-emp-dest-ini AS CHAR NO-UNDO.  
DEFINE VAR c-emp-dest-fim AS CHAR NO-UNDO.  
DEFINE VAR i-pedido-ini AS INT NO-UNDO.    
DEFINE VAR i-pedido-fim AS INT NO-UNDO.    
DEFINE VAR d-dt-ped-ini AS DATE NO-UNDO.    
DEFINE VAR d-dt-ped-fim AS DATE NO-UNDO.    
DEFINE VAR l-balanco AS LOG NO-UNDO.      
DEFINE VAR l-dev-forn-loja AS LOG NO-UNDO.
DEFINE VAR l-estorno AS LOG NO-UNDO.      
DEFINE VAR l-retira-loja AS LOG NO-UNDO.  
DEFINE VAR l-subst-cupom AS LOG NO-UNDO.  
DEFINE VAR l-transf-loja-cd-loja AS LOG NO-UNDO.                             
DEFINE VAR i-situacao      AS INTEGER INITIAL 5 NO-UNDO.
DEFINE VAR i-orig-ped      AS INTEGER INITIAL 3 NO-UNDO.
DEFINE VAR c-sit-nfe       AS CHAR INIT "NF-e n∆o Gerada,Em Processamento no EAI,Uso Autorizado,Uso Denegado,Documento Rejeitado,Documento Cancelado,Documento Inutilizado,              
                                         Em Processamento Aplic. Transmiss∆o,Em Processamento na SEFAZ,Em processamento no SCAN,NF-e Gerada,NF-e em Processo de Cancelamento,   
                                         NF-e em Processo de Inutilizaá∆o,NF-e Pendente de Retorno,DPEC Recebido pelo SCE" NO-UNDO.
DEFINE VAR i-sit-nfe       AS INT NO-UNDO.
DEFINE VAR l-emp-dest      AS LOG NO-UNDO.

def temp-table tt-raw-digita NO-UNDO field raw-digita  as raw.

define temp-table tt-param no-undo
    field destino          as integer
    field arquivo          as char format "x(35)"
    field usuario          as char format "x(12)"
    field data-exec        as date
    field hora-exec        as integer
    field classifica       as integer
    field desc-classifica  as char format "x(40)".

def var raw-param          as raw no-undo.

def var h-acomp as handle no-undo.

DEF VAR i-nr-itens       AS INT NO-UNDO.
DEF VAR i-ped-pend       AS INT NO-UNDO.
DEF VAR i-ped-canc       AS INT NO-UNDO.
DEF VAR i-nf-ger         AS INT NO-UNDO.
DEF VAR i-nf-autor       AS INT NO-UNDO.
DEF VAR c-estabel        AS CHAR NO-UNDO.
DEF VAR c-nr-nf          AS CHAR NO-UNDO.
DEF VAR c-serie          AS CHAR NO-UNDO.
DEF VAR c-ndd-envio      AS CHAR NO-UNDO.
DEF VAR c-nota-origem    AS CHAR NO-UNDO.
DEF VAR c-nota-destino   AS CHAR NO-UNDO.
DEF VAR da-dt-ger-nota   AS DATE FORMAT "99/99/9999" NO-UNDO.
DEF VAR c-hr-ger-nota    AS CHAR FORMAT "x(10)" NO-UNDO.
define var c-sistema     as char no-undo.

DEF TEMP-TABLE tt-tp_pedido
    FIELD tp_pedido AS INT
    FIELD mod-pedido AS CHAR
    INDEX tipo
            tp_pedido.

DEF TEMP-TABLE tt-emp-dest 
    FIELD cnpj AS CHAR
    INDEX codigo
             cnpj.

DEF TEMP-TABLE tt-erro
    FIELD ped_codigo_n LIKE int_ds_pedido.ped_codigo_n
    FIELD desc-erro    AS CHAR FORMAT "X(500)"
    INDEX pedido
            ped_codigo_n.

DEF TEMP-TABLE tt-int_ds_pedido-aux LIKE int_ds_pedido
    FIELD mod-pedido  AS CHAR
    FIELD tp_pedido   AS INT
    FIELD cod-estabel AS CHAR
    FIELD nome-abrev  AS CHAR
    field sistema     as char.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Window
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME fpage0
&Scoped-define BROWSE-NAME brPed

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-int_ds_pedido

/* Definitions for BROWSE brPed                                         */
&Scoped-define FIELDS-IN-QUERY-brPed tt-int_ds_pedido.cod-estabel tt-int_ds_pedido.sistema tt-int_ds_pedido.nome-abrev tt-int_ds_pedido.ped_codigo_n tt-int_ds_pedido.modal-ped tt-int_ds_pedido.tipo-ped tt-int_ds_pedido.dt-ger-ped tt-int_ds_pedido.hr-ger-ped tt-int_ds_pedido.qtde-itens tt-int_ds_pedido.serie tt-int_ds_pedido.nr-nota-fis tt-int_ds_pedido.dt-ger-nota tt-int_ds_pedido.hr-ger-nota tt-int_ds_pedido.ndd-envio tt-int_ds_pedido.sit-ped tt-int_ds_pedido.sit-nfe tt-int_ds_pedido.nota-destino tt-int_ds_pedido.nota-origem   
&Scoped-define ENABLED-FIELDS-IN-QUERY-brPed   
&Scoped-define SELF-NAME brPed
&Scoped-define QUERY-STRING-brPed FOR EACH tt-int_ds_pedido USE-INDEX situacao NO-LOCK
&Scoped-define OPEN-QUERY-brPed OPEN QUERY {&SELF-NAME} FOR EACH tt-int_ds_pedido USE-INDEX situacao NO-LOCK.
&Scoped-define TABLES-IN-QUERY-brPed tt-int_ds_pedido
&Scoped-define FIRST-TABLE-IN-QUERY-brPed tt-int_ds_pedido


/* Definitions for FRAME fPage1                                         */
&Scoped-define OPEN-BROWSERS-IN-QUERY-fPage1 ~
    ~{&OPEN-QUERY-brPed}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS rtToolBar-2 RECT-consulta RECT-consulta-2 ~
rtToolBar-3 btQueryJoins btReportsJoins btExit btHelp btSelecao rs-consulta ~
btAtualiza btOK btCancel btItens btAlteraSit btErros btHelp2 
&Scoped-Define DISPLAYED-OBJECTS i-nr-ped-pend i-nr-nf-gerada rs-consulta ~
i-nr-ped-canc c-intervalo i-nr-nf-autoriz i-nr-ped-erro 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD fnRefresh wWindow 
FUNCTION fnRefresh returns logical ( )  FORWARD.

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


/* Definitions of handles for OCX Containers                            */
DEFINE VARIABLE CtrlFrame AS WIDGET-HANDLE NO-UNDO.
DEFINE VARIABLE chCtrlFrame AS COMPONENT-HANDLE NO-UNDO.

/* Definitions of the field level widgets                               */
DEFINE BUTTON btAlteraSit 
     LABEL "Alterar Situaá∆o" 
     SIZE 12 BY 1.

DEFINE BUTTON btAtualiza 
     IMAGE-UP FILE "image/im-relo.bmp":U
     IMAGE-INSENSITIVE FILE "image/ii-relo.bmp":U
     LABEL "Query Joins" 
     SIZE 4 BY 1.25
     FONT 4.

DEFINE BUTTON btCancel 
     LABEL "Cancelar" 
     SIZE 10 BY 1.

DEFINE BUTTON btErros 
     LABEL "Listar Erros" 
     SIZE 10 BY 1.

DEFINE BUTTON btExit 
     IMAGE-UP FILE "image\im-exi":U
     IMAGE-INSENSITIVE FILE "image\ii-exi":U
     LABEL "Exit" 
     SIZE 4 BY 1.25
     FONT 4.

DEFINE BUTTON btHelp 
     IMAGE-UP FILE "image\im-hel":U
     IMAGE-INSENSITIVE FILE "image\ii-hel":U
     LABEL "Help" 
     SIZE 4 BY 1.25
     FONT 4.

DEFINE BUTTON btHelp2 
     LABEL "Ajuda" 
     SIZE 10 BY 1.

DEFINE BUTTON btItens 
     LABEL "Itens Pedido" 
     SIZE 10 BY 1.

DEFINE BUTTON btOK 
     LABEL "OK" 
     SIZE 10 BY 1.

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

DEFINE BUTTON btSelecao 
     IMAGE-UP FILE "image\im-ran":U
     IMAGE-INSENSITIVE FILE "image\ii-ran":U
     LABEL "Seleá∆o" 
     SIZE 4 BY 1.21
     FONT 4.

DEFINE VARIABLE c-intervalo AS INTEGER FORMAT ">,>>>,>>9":U INITIAL 60 
     VIEW-AS FILL-IN 
     SIZE 4 BY .79 NO-UNDO.

DEFINE VARIABLE i-nr-nf-autoriz AS INTEGER FORMAT ">,>>>,>>9":U INITIAL 0 
     LABEL "Nr. Notas Autorizadas" 
     VIEW-AS FILL-IN 
     SIZE 10 BY .88 NO-UNDO.

DEFINE VARIABLE i-nr-nf-gerada AS INTEGER FORMAT ">,>>>,>>9":U INITIAL 0 
     LABEL "Nr. Notas Geradas" 
     VIEW-AS FILL-IN 
     SIZE 10 BY .88 NO-UNDO.

DEFINE VARIABLE i-nr-ped-canc AS INTEGER FORMAT ">,>>>,>>9":U INITIAL 0 
     LABEL "Nr. Pedidos Cancelados" 
     VIEW-AS FILL-IN 
     SIZE 10 BY .88 NO-UNDO.

DEFINE VARIABLE i-nr-ped-erro AS INTEGER FORMAT ">,>>>,>>9":U INITIAL 0 
     LABEL "Nr. Pedidos com Erro" 
     VIEW-AS FILL-IN 
     SIZE 10 BY .88 NO-UNDO.

DEFINE VARIABLE i-nr-ped-pend AS INTEGER FORMAT ">,>>>,>>9":U INITIAL 0 
     LABEL "Nr. Pedidos Pendentes" 
     VIEW-AS FILL-IN 
     SIZE 10 BY .88 NO-UNDO.

DEFINE VARIABLE rs-consulta AS INTEGER 
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS 
          "Manual", 1,
"Autom†tico", 2
     SIZE 11.57 BY 1.5 NO-UNDO.

DEFINE RECTANGLE RECT-consulta
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 30.57 BY 2.58.

DEFINE RECTANGLE RECT-consulta-2
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 58.29 BY 3.5.

DEFINE RECTANGLE rtToolBar-2
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 187.43 BY 1.5
     BGCOLOR 7 .

DEFINE RECTANGLE rtToolBar-3
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 187.29 BY 1.42
     BGCOLOR 7 .

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY brPed FOR 
      tt-int_ds_pedido SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE brPed
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS brPed wWindow _FREEFORM
  QUERY brPed NO-LOCK DISPLAY
      tt-int_ds_pedido.cod-estabel           COLUMN-LABEL "Origem" FORMAT "X(4)"
tt-int_ds_pedido.sistema               COLUMN-LABEL "Sistema"  
tt-int_ds_pedido.nome-abrev            COLUMN-LABEL "Destino             "  
tt-int_ds_pedido.ped_codigo_n          COLUMN-LABEL "Pedido" 
tt-int_ds_pedido.modal-ped             COLUMN-LABEL "Modalidade Pedido"
tt-int_ds_pedido.tipo-ped              COLUMN-LABEL "Tipo Pedido"
tt-int_ds_pedido.dt-ger-ped            COLUMN-LABEL "Data Ger Ped"
tt-int_ds_pedido.hr-ger-ped            COLUMN-LABEL "Hora Ger Ped"
tt-int_ds_pedido.qtde-itens            COLUMN-LABEL " Nr. Itens" FORMAT ">>,>>9"
tt-int_ds_pedido.serie                 COLUMN-LABEL "SÇrie" FORMAT "x(5)"
tt-int_ds_pedido.nr-nota-fis           COLUMN-LABEL "Nota Fiscal" FORMAT "x(16)"
tt-int_ds_pedido.dt-ger-nota           COLUMN-LABEL "Data Ger NF"
tt-int_ds_pedido.hr-ger-nota           COLUMN-LABEL "Hora Ger NF" 
tt-int_ds_pedido.ndd-envio             COLUMN-LABEL "NDD Envio" FORMAT "X(12)" 
tt-int_ds_pedido.sit-ped               COLUMN-LABEL "Situaá∆o Pedido" FORMAT "x(25)"
tt-int_ds_pedido.sit-nfe               COLUMN-LABEL "Situaá∆o NF-e" FORMAT "x(37)"
tt-int_ds_pedido.nota-destino          COLUMN-LABEL "Procfit" FORMAT "X(12)"
tt-int_ds_pedido.nota-origem           COLUMN-LABEL "Oblak" FORMAT "X(12)"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS NO-COLUMN-SCROLLING SEPARATORS SIZE 186.43 BY 17.83
         FONT 1 NO-EMPTY-SPACE.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME fpage0
     btQueryJoins AT ROW 1.13 COL 171.86 HELP
          "Consultas relacionadas"
     btReportsJoins AT ROW 1.13 COL 175.86 HELP
          "Relat¢rios relacionados"
     btExit AT ROW 1.13 COL 179.86 HELP
          "Sair"
     btHelp AT ROW 1.13 COL 183.86 HELP
          "Ajuda"
     btSelecao AT ROW 1.17 COL 2.57 HELP
          "Relat¢rios relacionados" WIDGET-ID 2
     i-nr-ped-pend AT ROW 3.04 COL 56.86 COLON-ALIGNED WIDGET-ID 20
     i-nr-nf-gerada AT ROW 3.58 COL 85 COLON-ALIGNED WIDGET-ID 22
     rs-consulta AT ROW 3.88 COL 7.43 NO-LABEL WIDGET-ID 10
     btAtualiza AT ROW 3.88 COL 30.29 HELP
          "Consultas relacionadas" WIDGET-ID 4
     i-nr-ped-canc AT ROW 4.04 COL 56.86 COLON-ALIGNED WIDGET-ID 60
     c-intervalo AT ROW 4.13 COL 18.43 COLON-ALIGNED NO-LABEL WIDGET-ID 6
     i-nr-nf-autoriz AT ROW 4.58 COL 85 COLON-ALIGNED WIDGET-ID 24
     i-nr-ped-erro AT ROW 5.04 COL 56.86 COLON-ALIGNED WIDGET-ID 26
     btOK AT ROW 24.71 COL 3.29
     btCancel AT ROW 24.71 COL 14.29
     btItens AT ROW 24.71 COL 25.29 WIDGET-ID 56
     btAlteraSit AT ROW 24.71 COL 36.29 WIDGET-ID 58
     btErros AT ROW 24.71 COL 49.29 WIDGET-ID 62
     btHelp2 AT ROW 24.71 COL 177.86
     "seg" VIEW-AS TEXT
          SIZE 4.29 BY .54 AT ROW 4.21 COL 24.86 WIDGET-ID 16
     " Consulta" VIEW-AS TEXT
          SIZE 7.14 BY .54 AT ROW 2.92 COL 7.72 WIDGET-ID 14
     rtToolBar-2 AT ROW 1 COL 1.57
     RECT-consulta AT ROW 3.21 COL 5.86 WIDGET-ID 8
     RECT-consulta-2 AT ROW 2.75 COL 40.86 WIDGET-ID 28
     rtToolBar-3 AT ROW 24.5 COL 2 WIDGET-ID 32
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 189.57 BY 25.21
         FONT 1 WIDGET-ID 100.

DEFINE FRAME fPage1
     brPed AT ROW 1 COL 1 WIDGET-ID 600
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 2.29 ROW 6.46
         SIZE 186.72 BY 17.92
         FONT 1 WIDGET-ID 100.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Window
   Allow: Basic,Browse,DB-Fields,Window,Query
   Add Fields to: Neither
   Other Settings: COMPILE
   Temp-Tables and Buffers:
      TABLE: tt-int_ds_pedido T "?" NO-UNDO emsesp int_ds_pedido
      ADDITIONAL-FIELDS:
          field cod-estabel as char format "x(4)"
          field qtde-itens as int format ">>,>>9"
          field serie as char format "x(5)"
          field nr-nota-fis as char format "x(16)"
          field sit-ped as char format "x(20)"
          field dt-ger-ped as date format "99/99/9999"
          field hr-ger-ped as char format "x(10)"
          field dt-ger-nota as date format "99/99/9999"
          field hr-ger-nota as char format "x(10)"
          field ndd-envio as char
          field sit-nfe as char
          FIELD nota-origem AS CHAR
          FIELD nota-destino AS CHAR
          FIELD nome-abrev AS CHAR FORMAT "X(14)"
          FIELD modal-ped AS CHAR FORMAT "X(15)"
          FIELD tipo-ped AS INT FORMAT ">>9"
          field sistema as char format "x(10)"
          index situacao serie dt-ger-ped hr-ger-ped ped_codigo_n
          INDEX hora-gera hr-ger-nota
      END-FIELDS.
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
IF SESSION:DISPLAY-TYPE = "GUI":U THEN
  CREATE WINDOW wWindow ASSIGN
         HIDDEN             = YES
         TITLE              = "Monitor de Notas Fiscais de Sa°da de Loja"
         HEIGHT             = 25.08
         WIDTH              = 188.72
         MAX-HEIGHT         = 27.5
         MAX-WIDTH          = 195.14
         VIRTUAL-HEIGHT     = 27.5
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
ASSIGN FRAME fPage1:FRAME = FRAME fpage0:HANDLE.

/* SETTINGS FOR FRAME fpage0
   FRAME-NAME                                                           */
/* SETTINGS FOR FILL-IN c-intervalo IN FRAME fpage0
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN i-nr-nf-autoriz IN FRAME fpage0
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN i-nr-nf-gerada IN FRAME fpage0
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN i-nr-ped-canc IN FRAME fpage0
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN i-nr-ped-erro IN FRAME fpage0
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN i-nr-ped-pend IN FRAME fpage0
   NO-ENABLE                                                            */
/* SETTINGS FOR FRAME fPage1
                                                                        */
/* BROWSE-TAB brPed 1 fPage1 */
IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(wWindow)
THEN wWindow:HIDDEN = yes.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE brPed
/* Query rebuild information for BROWSE brPed
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH tt-int_ds_pedido USE-INDEX situacao NO-LOCK.
     _END_FREEFORM
     _Options          = "NO-LOCK"
     _TblOptList       = "USED"
     _Query            is OPENED
*/  /* BROWSE brPed */
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

 


/* **********************  Create OCX Containers  ********************** */

&ANALYZE-SUSPEND _CREATE-DYNAMIC

&IF "{&OPSYS}" = "WIN32":U AND "{&WINDOW-SYSTEM}" NE "TTY":U &THEN

CREATE CONTROL-FRAME CtrlFrame ASSIGN
       FRAME           = FRAME fpage0:HANDLE
       ROW             = 1
       COLUMN          = 165
       HEIGHT          = 1.5
       WIDTH           = 6
       WIDGET-ID       = 18
       HIDDEN          = yes
       SENSITIVE       = yes.
/* CtrlFrame OCXINFO:CREATE-CONTROL from: {F0B88A90-F5DA-11CF-B545-0020AF6ED35A} type: PSTimer */

&ENDIF

&ANALYZE-RESUME /* End of _CREATE-DYNAMIC */


/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME wWindow
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL wWindow wWindow
ON END-ERROR OF wWindow /* Monitor de Notas Fiscais de Sa°da de Loja */
OR ENDKEY OF {&WINDOW-NAME} ANYWHERE DO:
  /* This case occurs when the user presses the "Esc" key.
     In a persistently run window, just ignore this.  If we did not, the
     application would exit. */
  IF THIS-PROCEDURE:PERSISTENT THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL wWindow wWindow
ON WINDOW-CLOSE OF wWindow /* Monitor de Notas Fiscais de Sa°da de Loja */
DO:
  /* This event will close the window and terminate the procedure.  */
  APPLY "CLOSE":U TO THIS-PROCEDURE.
  RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME brPed
&Scoped-define FRAME-NAME fPage1
&Scoped-define SELF-NAME brPed
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL brPed wWindow
ON MOUSE-SELECT-DBLCLICK OF brPed IN FRAME fPage1
DO:
  IF AVAIL tt-int_ds_pedido THEN DO:
     RUN intprg/int051c.w (INPUT tt-int_ds_pedido.ped_codigo_n).
  END.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL brPed wWindow
ON ROW-DISPLAY OF brPed IN FRAME fPage1
DO: 
   IF tt-int_ds_pedido.sit-ped = "NF Gerada" THEN 
      assign tt-int_ds_pedido.cod-estabel:bgcolor in browse brPed = 14 
             tt-int_ds_pedido.sistema:bgcolor in browse brPed = 14 
             tt-int_ds_pedido.nome-abrev:bgcolor in browse brPed = 14
             tt-int_ds_pedido.modal-ped:bgcolor in browse brPed = 14
             tt-int_ds_pedido.tipo-ped:bgcolor in browse brPed = 14
             tt-int_ds_pedido.ped_codigo_n:bgcolor in browse brPed = 14     
             tt-int_ds_pedido.dt-ger-ped:bgcolor in browse brPed = 14
             tt-int_ds_pedido.hr-ger-ped:bgcolor in browse brPed = 14
             tt-int_ds_pedido.qtde-itens:bgcolor in browse brPed = 14           
             tt-int_ds_pedido.serie:bgcolor in browse brPed = 14                
             tt-int_ds_pedido.nr-nota-fis:bgcolor in browse brPed = 14      
             tt-int_ds_pedido.dt-ger-nota:bgcolor in browse brPed = 14
             tt-int_ds_pedido.hr-ger-nota:bgcolor in browse brPed = 14
             tt-int_ds_pedido.ndd-envio:bgcolor in browse brPed = 14
             tt-int_ds_pedido.sit-nfe:bgcolor in browse brPed = 14     
             tt-int_ds_pedido.sit-ped:bgcolor in browse brPed = 14
             tt-int_ds_pedido.nota-origem:bgcolor in browse brPed = 14
             tt-int_ds_pedido.nota-destino:bgcolor in browse brPed = 14.

   IF tt-int_ds_pedido.sit-ped = "NF Autorizada" THEN 
      assign tt-int_ds_pedido.cod-estabel:bgcolor in browse brPed = 10 
             tt-int_ds_pedido.sistema:bgcolor in browse brPed = 10
             tt-int_ds_pedido.nome-abrev:bgcolor in browse brPed = 10
             tt-int_ds_pedido.modal-ped:bgcolor in browse brPed = 10
             tt-int_ds_pedido.tipo-ped:bgcolor in browse brPed = 10
             tt-int_ds_pedido.ped_codigo_n:bgcolor in browse brPed = 10
             tt-int_ds_pedido.dt-ger-ped:bgcolor in browse brPed = 10
             tt-int_ds_pedido.hr-ger-ped:bgcolor in browse brPed = 10
             tt-int_ds_pedido.qtde-itens:bgcolor in browse brPed = 10           
             tt-int_ds_pedido.serie:bgcolor in browse brPed = 10                
             tt-int_ds_pedido.nr-nota-fis:bgcolor in browse brPed = 10          
             tt-int_ds_pedido.dt-ger-nota:bgcolor in browse brPed = 10
             tt-int_ds_pedido.hr-ger-nota:bgcolor in browse brPed = 10
             tt-int_ds_pedido.ndd-envio:bgcolor in browse brPed = 10
             tt-int_ds_pedido.sit-nfe:bgcolor in browse brPed = 10            
             tt-int_ds_pedido.sit-ped:bgcolor in browse brPed = 10
             tt-int_ds_pedido.nota-origem:bgcolor in browse brPed = 10
             tt-int_ds_pedido.nota-destino:bgcolor in browse brPed = 10.

   IF tt-int_ds_pedido.sit-ped = "Pedido c/ Erro" THEN 
      assign tt-int_ds_pedido.cod-estabel:bgcolor in browse brPed = 12 
             tt-int_ds_pedido.sistema:bgcolor in browse brPed = 12
             tt-int_ds_pedido.nome-abrev:bgcolor in browse brPed = 12
             tt-int_ds_pedido.modal-ped:bgcolor in browse brPed = 12
             tt-int_ds_pedido.tipo-ped:bgcolor in browse brPed = 12
             tt-int_ds_pedido.ped_codigo_n:bgcolor in browse brPed = 12     
             tt-int_ds_pedido.dt-ger-ped:bgcolor in browse brPed = 12
             tt-int_ds_pedido.hr-ger-ped:bgcolor in browse brPed = 12
             tt-int_ds_pedido.qtde-itens:bgcolor in browse brPed = 12           
             tt-int_ds_pedido.serie:bgcolor in browse brPed = 12                
             tt-int_ds_pedido.nr-nota-fis:bgcolor in browse brPed = 12      
             tt-int_ds_pedido.dt-ger-nota:bgcolor in browse brPed = 12
             tt-int_ds_pedido.hr-ger-nota:bgcolor in browse brPed = 12
             tt-int_ds_pedido.ndd-envio:bgcolor in browse brPed = 12
             tt-int_ds_pedido.sit-nfe:bgcolor in browse brPed = 12     
             tt-int_ds_pedido.sit-ped:bgcolor in browse brPed = 12
             tt-int_ds_pedido.nota-origem:bgcolor in browse brPed = 12
             tt-int_ds_pedido.nota-destino:bgcolor in browse brPed = 12.

   IF tt-int_ds_pedido.sit-ped = "Pedido Cancelado" THEN 
      assign tt-int_ds_pedido.cod-estabel:bgcolor in browse brPed = 8 
             tt-int_ds_pedido.sistema:bgcolor in browse brPed = 8
             tt-int_ds_pedido.nome-abrev:bgcolor in browse brPed = 8
             tt-int_ds_pedido.modal-ped:bgcolor in browse brPed = 8
             tt-int_ds_pedido.tipo-ped:bgcolor in browse brPed = 8
             tt-int_ds_pedido.ped_codigo_n:bgcolor in browse brPed = 8     
             tt-int_ds_pedido.dt-ger-ped:bgcolor in browse brPed = 8
             tt-int_ds_pedido.hr-ger-ped:bgcolor in browse brPed = 8
             tt-int_ds_pedido.qtde-itens:bgcolor in browse brPed = 8           
             tt-int_ds_pedido.serie:bgcolor in browse brPed = 8                
             tt-int_ds_pedido.nr-nota-fis:bgcolor in browse brPed = 8      
             tt-int_ds_pedido.dt-ger-nota:bgcolor in browse brPed = 8
             tt-int_ds_pedido.hr-ger-nota:bgcolor in browse brPed = 8
             tt-int_ds_pedido.ndd-envio:bgcolor in browse brPed = 8
             tt-int_ds_pedido.sit-nfe:bgcolor in browse brPed = 8     
             tt-int_ds_pedido.sit-ped:bgcolor in browse brPed = 8
             tt-int_ds_pedido.nota-origem:bgcolor in browse brPed = 8
             tt-int_ds_pedido.nota-destino:bgcolor in browse brPed = 8.

   IF  tt-int_ds_pedido.sit-ped <> "Pedido Pendente" THEN DO:
      IF tt-int_ds_pedido.nota-origem = "" OR
         tt-int_ds_pedido.nota-origem = "Enviada" THEN
         ASSIGN tt-int_ds_pedido.nota-origem:bgcolor in browse brPed = 14.

      IF tt-int_ds_pedido.nota-destino = "" OR
         tt-int_ds_pedido.nota-destino = "Enviada" THEN
         ASSIGN tt-int_ds_pedido.nota-destino:bgcolor in browse brPed = 14.

      IF tt-int_ds_pedido.ndd-envio = "" OR
         tt-int_ds_pedido.ndd-envio = "Enviada" THEN
         ASSIGN tt-int_ds_pedido.ndd-envio:bgcolor in browse brPed = 14.
   END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME fpage0
&Scoped-define SELF-NAME btAlteraSit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btAlteraSit wWindow
ON CHOOSE OF btAlteraSit IN FRAME fpage0 /* Alterar Situaá∆o */
DO:  
  IF AVAIL tt-int_ds_pedido THEN DO:
     IF  tt-int_ds_pedido.situacao <> 1 
     AND tt-int_ds_pedido.situacao <> 3 THEN DO:
         MESSAGE "Situaá∆o do Pedido n∆o pode ser alterada. Situaá∆o atual: 2 - Integrado"
             VIEW-AS ALERT-BOX INFO BUTTONS OK.
         RETURN "NO-APPLY".
     END.
     RUN intprg/int051d.w (INPUT tt-int_ds_pedido.ped_codigo_n).
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btAtualiza
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btAtualiza wWindow
ON CHOOSE OF btAtualiza IN FRAME fpage0 /* Query Joins */
OR CHOOSE OF btAtualiza DO:
    fnRefresh().

    RUN pi-openQueryPed.
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


&Scoped-define SELF-NAME btErros
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btErros wWindow
ON CHOOSE OF btErros IN FRAME fpage0 /* Listar Erros */
DO:  
  IF AVAIL tt-int_ds_pedido THEN DO:
     IF tt-int_ds_pedido.sit-ped = "Pedido c/ Erro" THEN DO:
        RUN intprg/int051e.w (INPUT tt-int_ds_pedido.ped_codigo_n,
                              INPUT TABLE tt-erro).
     END.
  END.
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


&Scoped-define SELF-NAME btHelp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btHelp wWindow
ON CHOOSE OF btHelp IN FRAME fpage0 /* Help */
OR CHOOSE OF MENU-ITEM miContents IN MENU mbMain DO:
    {include/ajuda.i}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btHelp2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btHelp2 wWindow
ON CHOOSE OF btHelp2 IN FRAME fpage0 /* Ajuda */
DO:
    {include/ajuda.i}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btItens
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btItens wWindow
ON CHOOSE OF btItens IN FRAME fpage0 /* Itens Pedido */
DO:  
  IF AVAIL tt-int_ds_pedido THEN DO:
     RUN intprg/int051b.w (INPUT tt-int_ds_pedido.ped_codigo_n,
                           INPUT tt-int_ds_pedido.tipo-ped).
  END.
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


&Scoped-define SELF-NAME btSelecao
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btSelecao wWindow
ON CHOOSE OF btSelecao IN FRAME fpage0 /* Seleá∆o */
OR CHOOSE OF btSelecao DO:
   fnRefresh().
   DEF VAR l-openquery AS LOG NO-UNDO.

   RUN intprg/int051a.w (INPUT-OUTPUT c-estab-orig-ini,  
                         INPUT-OUTPUT c-estab-orig-fim,  
                         INPUT-OUTPUT c-emp-dest-ini,
                         INPUT-OUTPUT c-emp-dest-fim,
                         INPUT-OUTPUT i-pedido-ini,
                         INPUT-OUTPUT i-pedido-fim,
                         INPUT-OUTPUT d-dt-ped-ini,
                         INPUT-OUTPUT d-dt-ped-fim,
                         INPUT-OUTPUT l-balanco,
                         INPUT-OUTPUT l-dev-forn-loja,
                         INPUT-OUTPUT l-estorno,    
                         INPUT-OUTPUT l-retira-loja,    
                         INPUT-OUTPUT l-subst-cupom,    
                         INPUT-OUTPUT l-transf-loja-cd-loja,    
                         INPUT-OUTPUT i-situacao,  
                         INPUT-OUTPUT i-orig-ped,
                         OUTPUT l-openquery ).

    if l-openquery and rs-consulta:SCREEN-VALUE IN FRAME fPage0 = "2" then do:
       RUN pi-OpenQueryPed.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME c-intervalo
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL c-intervalo wWindow
ON LEAVE OF c-intervalo IN FRAME fpage0
DO: 
  IF INT(c-intervalo:SCREEN-VALUE IN FRAME fPage0) <> 0 THEN
      chCtrlFrame:PSTimer:interval = INT(c-intervalo:SCREEN-VALUE IN FRAME fPage0) * 1000.
  ELSE
      run utp/ut-msgs.p (input "show", 
                         input 17006, 
                         input "O intervalo de atualizaá∆o deve ser informado!").    
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME CtrlFrame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL CtrlFrame wWindow OCX.Tick
PROCEDURE CtrlFrame.PSTimer.Tick .
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  None required for OCX.
  Notes:       
------------------------------------------------------------------------------*/
    APPLY "CHOOSE" TO btAtualiza IN FRAME fPage0.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME rs-consulta
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL rs-consulta wWindow
ON VALUE-CHANGED OF rs-consulta IN FRAME fpage0
DO:
  IF rs-consulta:SCREEN-VALUE IN FRAME fPage0 = "2" THEN DO:
      ENABLE c-intervalo WITH FRAME fPage0.
      DISABLE btAtualiza WITH FRAME fPage0.
      display c-intervalo WITH FRAME fPage0.
      chCtrlFrame:PSTimer:interval = INT(c-intervalo:SCREEN-VALUE IN FRAME fPage0) * 1000.
  END.
  ELSE DO:
      DISABLE c-intervalo WITH FRAME fPage0. 
      ENABLE btAtualiza WITH FRAME fPage0.
      ASSIGN chCtrlFrame:PSTimer:interval = 0
             c-intervalo:SCREEN-VALUE IN FRAME fPage0 = "".
  END.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK wWindow 


/*--- L¢gica para inicializaá∆o do programam ---*/
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
    apply "VALUE-CHANGED":U to rs-consulta in frame fPage0.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE beforeInitializeInterface wWindow 
PROCEDURE beforeInitializeInterface :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    ASSIGN c-estab-orig-ini      = ""
           c-estab-orig-fim      = "ZZZZZ"
           c-emp-dest-ini        = ""
           c-emp-dest-fim        = "ZZZZZZZZZZZZ"
           i-pedido-ini          = 0
           i-pedido-fim          = 999999999
           d-dt-ped-ini          = TODAY
           d-dt-ped-fim          = TODAY
           l-balanco             = YES
           l-dev-forn-loja       = YES
           l-estorno             = YES
           l-retira-loja         = YES
           l-subst-cupom         = YES
           l-transf-loja-cd-loja = YES
           i-situacao            = 5.

    assign i-nr-nf-gerada:bgcolor in frame {&FRAME-NAME}  = 14
           i-nr-ped-erro:bgcolor in frame {&FRAME-NAME}   = 12
           i-nr-nf-autoriz:bgcolor in frame {&FRAME-NAME} = 10
           i-nr-ped-pend:bgcolor in frame {&FRAME-NAME}   = 15
           i-nr-ped-canc:bgcolor in frame {&FRAME-NAME}   = 8.

    DISP i-nr-ped-pend
         i-nr-ped-canc
         i-nr-ped-erro
         i-nr-nf-gerada
         i-nr-nf-autoriz 
         WITH FRAME {&FRAME-NAME}.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE control_load wWindow  _CONTROL-LOAD
PROCEDURE control_load :
/*------------------------------------------------------------------------------
  Purpose:     Load the OCXs    
  Parameters:  <none>
  Notes:       Here we load, initialize and make visible the 
               OCXs in the interface.                        
------------------------------------------------------------------------------*/

&IF "{&OPSYS}" = "WIN32":U AND "{&WINDOW-SYSTEM}" NE "TTY":U &THEN
DEFINE VARIABLE UIB_S    AS LOGICAL    NO-UNDO.
DEFINE VARIABLE OCXFile  AS CHARACTER  NO-UNDO.

OCXFile = SEARCH( "int051.wrx":U ).
IF OCXFile = ? THEN
  OCXFile = SEARCH(SUBSTRING(THIS-PROCEDURE:FILE-NAME, 1,
                     R-INDEX(THIS-PROCEDURE:FILE-NAME, ".":U), "CHARACTER":U) + "wrx":U).

IF OCXFile <> ? THEN
DO:
  ASSIGN
    chCtrlFrame = CtrlFrame:COM-HANDLE
    UIB_S = chCtrlFrame:LoadControls( OCXFile, "CtrlFrame":U)
    CtrlFrame:NAME = "CtrlFrame":U
  .
  RUN initialize-controls IN THIS-PROCEDURE NO-ERROR.
END.
ELSE MESSAGE "int051.wrx":U SKIP(1)
             "The binary control file could not be found. The controls cannot be loaded."
             VIEW-AS ALERT-BOX TITLE "Controls Not Loaded".

&ENDIF

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-openQueryPed wWindow 
PROCEDURE pi-openQueryPed :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

ASSIGN i-nr-ped-pend = 0 i-nr-ped-canc = 0 i-nr-nf-gerada = 0 i-nr-ped-erro = 0 i-nr-nf-autoriz = 0.

run utp/ut-acomp.p persistent set h-acomp.
run pi-inicializar in h-acomp ("Faturamento Notas Sa°da Loja").

session:SET-WAIT-STATE ("GENERAL").

EMPTY TEMP-TABLE tt-tp_pedido. EMPTY TEMP-TABLE tt-emp-dest. EMPTY TEMP-TABLE tt-erro. empty temp-table tt-int_ds_pedido. empty temp-table tt-int_ds_pedido-aux.

FOR EACH int_ds_tipo_pedido NO-LOCK:
    IF (l-balanco             = YES AND int_ds_tipo_pedido.cod_mod_pedido = "BALANCO")
    OR (l-dev-forn-loja       = YES AND int_ds_tipo_pedido.cod_mod_pedido = "DEV FORN LJ")
    OR (l-estorno             = YES AND int_ds_tipo_pedido.cod_mod_pedido = "ESTORNO") 
    OR (l-retira-loja         = YES AND int_ds_tipo_pedido.cod_mod_pedido = "RETIRADA")
    OR (l-subst-cupom         = YES AND int_ds_tipo_pedido.cod_mod_pedido = "SUBS CUPOM")
    OR (l-transf-loja-cd-loja = YES AND int_ds_tipo_pedido.cod_mod_pedido = "TRANSF LJ") THEN DO:  

       RUN pi-acompanhar IN h-acomp (INPUT "Carregando Tipo Pedido: " + int_ds_tipo_pedido.tp_pedido).

       FIND FIRST tt-tp_pedido WHERE
                  tt-tp_pedido.tp_pedido = int(int_ds_tipo_pedido.tp_pedido) NO-ERROR.
       IF NOT AVAIL tt-tp_pedido THEN DO:
          CREATE tt-tp_pedido.
          ASSIGN tt-tp_pedido.tp_pedido  = int(int_ds_tipo_pedido.tp_pedido)
                 tt-tp_pedido.mod-pedido = int_ds_tipo_pedido.cod_mod_pedido.
       END.
    END.
END.

ASSIGN l-emp-dest = NO.

IF c-emp-dest-ini <> "" 
OR c-emp-dest-fim <> "ZZZZZZZZZZZZ" THEN DO:
   FOR EACH emitente FIELDS(emitente.nome-abrev emitente.cgc) WHERE
            emitente.nome-abrev >= c-emp-dest-ini AND
            emitente.nome-abrev <= c-emp-dest-fim NO-LOCK:

       RUN pi-acompanhar IN h-acomp (INPUT "Carregando Emp. Destino: " + emitente.nome-abrev ).

       CREATE tt-emp-dest.
       ASSIGN tt-emp-dest.cnpj = emitente.cgc
              l-emp-dest       = YES.
   END.
END.

FOR EACH tt-tp_pedido NO-LOCK:

    RUN pi-acompanhar IN h-acomp (INPUT "Tipo Pedido: " + string(tt-tp_pedido.tp_pedido)).

    for each int_ds_pedido no-lock where
             int_ds_pedido.ped_tipopedido_n = tt-tp_pedido.tp_pedido AND
             int_ds_pedido.dt_geracao      >= d-dt-ped-ini AND 
             int_ds_pedido.dt_geracao      <= d-dt-ped-fim AND 
             int_ds_pedido.ped_codigo_n    >= i-pedido-ini AND 
             int_ds_pedido.ped_codigo_n    <= i-pedido-fim QUERY-TUNING(NO-LOOKAHEAD) on stop undo, leave:

        RUN pi-acompanhar IN h-acomp (INPUT "Carregando Pedido: " + string(int_ds_pedido.ped_codigo_n) + " - " + string(int_ds_pedido.dt_geracao,"99/99/9999")).

        IF l-emp-dest = YES THEN DO:
           FOR FIRST tt-emp-dest USE-INDEX codigo WHERE
                     tt-emp-dest.cnpj = int_ds_pedido.ped_cnpj_destino_s NO-LOCK:     
           END.
           IF NOT AVAIL tt-emp-dest THEN
              NEXT.
        END.

        ASSIGN c-estabel = "" 
               c-sistema = "".
        for each estabelec fields (cod-estabel) no-lock WHERE estabelec.cgc = int_ds_pedido.ped_cnpj_origem_s,
            first cst_estabelec no-lock where cst_estabelec.cod_estabel = estabelec.cod-estabel and cst_estabelec.dt_fim_operacao >= int_ds_pedido.ped_data_d
            QUERY-TUNING(NO-LOOKAHEAD):
            ASSIGN c-estabel = estabelec.cod-estabel
                   c-sistema = if cst_estabelec.dt_inicio_oper <= int_ds_pedido.ped_data_d then "PROCFIT" else "OBLAK".
        end.

        if c-estab-orig-ini > c-estabel
        or c-estab-orig-fim < c-estabel then 
           NEXT.

        IF i-orig-ped = 1 AND c-sistema = "PROCFIT" THEN NEXT.
        IF i-orig-ped = 2 AND c-sistema = "OBLAK"   THEN NEXT.

        FOR FIRST estabelec fields (estabelec.cod-estabel estabelec.estado) WHERE
                  estabelec.cod-estabel = c-estabel NO-LOCK: 
        END.
        for first emitente no-lock where
                  emitente.cgc = trim(int_ds_pedido.ped_cnpj_destino_s) QUERY-TUNING(NO-LOOKAHEAD):
        END.
        CREATE tt-int_ds_pedido-aux.
        BUFFER-COPY int_ds_pedido TO tt-int_ds_pedido-aux NO-ERROR.
        ASSIGN tt-int_ds_pedido-aux.mod-pedido  = tt-tp_pedido.mod-pedido
               tt-int_ds_pedido-aux.tp_pedido   = tt-tp_pedido.tp_pedido
               tt-int_ds_pedido-aux.cod-estabel = IF AVAIL estabelec THEN estabelec.cod-estabel ELSE ""
               tt-int_ds_pedido-aux.nome-abrev  = IF AVAIL emitente THEN emitente.nome-abrev ELSE ""
               tt-int_ds_pedido-aux.sistema     = c-sistema.
    END.

    for each int_ds_pedido_subs no-lock where
             int_ds_pedido_subs.ped_tipopedido_n = tt-tp_pedido.tp_pedido AND
             int_ds_pedido_subs.dt_geracao      >= d-dt-ped-ini AND 
             int_ds_pedido_subs.dt_geracao      <= d-dt-ped-fim AND 
             int_ds_pedido_subs.ped_codigo_n    >= i-pedido-ini AND 
             int_ds_pedido_subs.ped_codigo_n    <= i-pedido-fim QUERY-TUNING(NO-LOOKAHEAD) on stop undo, leave:

        RUN pi-acompanhar IN h-acomp (INPUT "Carregando Pedido: " + string(int_ds_pedido_subs.ped_codigo_n) + " - " + string(int_ds_pedido_subs.dt_geracao,"99/99/9999")).

        IF l-emp-dest = YES THEN DO:
           FOR FIRST tt-emp-dest USE-INDEX codigo WHERE
                     tt-emp-dest.cnpj = int_ds_pedido_subs.ped_cnpj_destino_s NO-LOCK:     
           END.
           IF NOT AVAIL tt-emp-dest THEN
              NEXT.
        END.

        ASSIGN c-estabel = "" 
               c-sistema = "".
        for each estabelec fields (cod-estabel) no-lock WHERE estabelec.cgc = int_ds_pedido_subs.ped_cnpj_origem_s,
            first cst_estabelec no-lock where cst_estabelec.cod_estabel = estabelec.cod-estabel and cst_estabelec.dt_fim_operacao >= int_ds_pedido_subs.ped_data_d
            QUERY-TUNING(NO-LOOKAHEAD):
            ASSIGN c-estabel = estabelec.cod-estabel
                   c-sistema = if cst_estabelec.dt_inicio_oper <= int_ds_pedido_subs.ped_data_d then "PROCFIT" else "OBLAK".
        end.

        if c-estab-orig-ini > c-estabel
        or c-estab-orig-fim < c-estabel then 
           NEXT.
        
        IF i-orig-ped = 1 AND c-sistema = "PROCFIT" THEN NEXT.
        IF i-orig-ped = 2 AND c-sistema = "OBLAK"   THEN NEXT.

        FOR FIRST estabelec fields (estabelec.cod-estabel estabelec.estado) WHERE
                  estabelec.cod-estabel = c-estabel NO-LOCK: 
        END.

        for first emitente no-lock where
                  emitente.cgc = trim(int_ds_pedido_subs.ped_cnpj_destino_s) QUERY-TUNING(NO-LOOKAHEAD):
        END.

        CREATE tt-int_ds_pedido-aux.
        BUFFER-COPY int_ds_pedido_subs TO tt-int_ds_pedido-aux NO-ERROR.
        ASSIGN tt-int_ds_pedido-aux.mod-pedido  = tt-tp_pedido.mod-pedido
               tt-int_ds_pedido-aux.tp_pedido   = tt-tp_pedido.tp_pedido
               tt-int_ds_pedido-aux.cod-estabel = IF AVAIL estabelec THEN estabelec.cod-estabel ELSE ""
               tt-int_ds_pedido-aux.nome-abrev  = IF AVAIL emitente THEN emitente.nome-abrev ELSE ""
               tt-int_ds_pedido-aux.sistema     = c-sistema.
    END.
END.

FOR EACH tt-int_ds_pedido-aux:

    RUN pi-acompanhar IN h-acomp (INPUT "Processando Pedido: " + string(tt-int_ds_pedido-aux.ped_codigo_n) + " - " + string(tt-int_ds_pedido-aux.dt_geracao,"99/99/9999")).

    ASSIGN i-ped-pend     = 0  i-ped-canc = 0 i-nf-ger = 0 i-nf-autor = 0 c-nr-nf = "" c-serie = "" da-dt-ger-nota = ? c-hr-ger-nota = "" c-ndd-envio = ""  
           c-nota-origem  = "" c-nota-destino = "" c-sistema = "".

    IF (tt-int_ds_pedido-aux.situacao = 1 AND i-situacao = 1)
    OR i-situacao = 5 THEN DO:
       IF tt-int_ds_pedido-aux.situacao = 1 THEN DO:
          for-retorno:
          for each int_ds_pedido_retorno no-lock of tt-int_ds_pedido-aux:
              FOR FIRST ITEM WHERE 
                        ITEM.it-codigo = STRING(int_ds_pedido_retorno.ppr_produto_n) NO-LOCK QUERY-TUNING(NO-LOOKAHEAD): 
                  if item.class-fiscal = "" 
                  or ITEM.class-fiscal = "00000000" then do:
                     assign i-ped-pend    = 4
                            i-nr-ped-erro = i-nr-ped-erro + 1.
                     CREATE tt-erro.
                     ASSIGN tt-erro.ped_codigo_n = tt-int_ds_pedido-aux.ped_codigo_n
                            tt-erro.desc-erro    = "Classificaá∆o Fiscal: " + item.class-fiscal + " do Item: " + ITEM.it-codigo + " inv†lida.".
                     leave for-retorno.
                  end.                       
                  for first item-uni-estab no-lock where 
                            item-uni-estab.it-codigo = trim(STRING(int_ds_pedido_retorno.ppr_produto_n)) and
                            item-uni-estab.cod-estabel = tt-int_ds_pedido-aux.cod-estabel:                               
                  end.
                  if not avail item-uni-estab then do:
                     assign i-ped-pend    = 4
                            i-nr-ped-erro = i-nr-ped-erro + 1.
                     CREATE tt-erro.
                     ASSIGN tt-erro.ped_codigo_n = tt-int_ds_pedido-aux.ped_codigo_n
                            tt-erro.desc-erro    = "Item Uni. Estab. n∆o cadastrada. Item: " + ITEM.it-codigo + " Estabelecimento: " + tt-int_ds_pedido-aux.cod-estabel.
                     leave for-retorno.
                  end.
              end.
              if not avail item then do:
                 assign i-ped-pend    = 4
                        i-nr-ped-erro = i-nr-ped-erro + 1.
                 CREATE tt-erro.
                 ASSIGN tt-erro.ped_codigo_n = tt-int_ds_pedido-aux.ped_codigo_n
                        tt-erro.desc-erro    = "Item: " + STRING(int_ds_pedido_retorno.ppr_produto_n) + " n∆o cadastrado.".
                 leave for-retorno.
              end.
          end.
          if i-ped-pend <> 4 then do:
             FOR FIRST int_ds_log USE-INDEX orig_chave_sit_dt WHERE
                       int_ds_log.origem   = "NF PED" AND 
                       int_ds_log.chave    = trim(string(tt-int_ds_pedido-aux.ped_codigo_n)) AND
                       int_ds_log.situacao <> 2 NO-LOCK: 
                 ASSIGN i-ped-pend    = 4
                        i-nr-ped-erro = i-nr-ped-erro + 1.
             END.
             IF NOT AVAIL int_ds_log THEN DO:
                ASSIGN i-ped-pend    = 1
                       i-nr-ped-pend = i-nr-ped-pend + 1.
             END.
             IF i-ped-pend = 4 THEN DO:
                FOR EACH int_ds_log USE-INDEX orig_chave_sit_dt WHERE
                         int_ds_log.origem   = "NF PED" AND 
                         int_ds_log.chave    = trim(string(tt-int_ds_pedido-aux.ped_codigo_n)) AND
                         int_ds_log.situacao <> 2 NO-LOCK:
                    CREATE tt-erro.
                    ASSIGN tt-erro.ped_codigo_n = tt-int_ds_pedido-aux.ped_codigo_n
                           tt-erro.desc-erro    = int_ds_log.desc_ocorrencia.                       
                END.
             END.                 
          END.
       end.
    END.
    IF (tt-int_ds_pedido-aux.situacao = 3 AND i-situacao = 4)
    OR i-situacao = 5 THEN DO:
       IF tt-int_ds_pedido-aux.situacao = 3 THEN DO:
          ASSIGN i-nr-ped-canc = i-nr-ped-canc + 1
                 i-ped-canc    = 5.
       END.
    END.

    IF (i-situacao <> 1 AND i-situacao <> 4)
    OR i-situacao  = 5 THEN DO:     
       IF i-situacao = 2 
       OR i-situacao = 5 THEN DO:
          ASSIGN i-sit-nfe = 0.
          FOR FIRST nota-fiscal USE-INDEX ch-pedido WHERE 
                    nota-fiscal.nome-ab-cli        = tt-int_ds_pedido-aux.nome-abrev AND
                    nota-fiscal.nr-pedcli          = trim(string(tt-int_ds_pedido-aux.ped_codigo_n)) AND 
                    nota-fiscal.idi-sit-nf-eletro <> 3 AND 
                    nota-fiscal.idi-sit-nf-eletro <> 6 AND
                    nota-fiscal.idi-sit-nf-eletro <> 7 NO-LOCK QUERY-TUNING(NO-LOOKAHEAD): 

             ASSIGN i-nf-ger       = 2                        
                    i-nr-nf-gerada = i-nr-nf-gerada + 1
                    c-nr-nf        = nota-fiscal.nr-nota-fis
                    c-serie        = nota-fiscal.serie        
                    da-dt-ger-nota = nota-fiscal.dt-emis-nota
                    c-hr-ger-nota  = nota-fiscal.hr-atualiza.

             FOR FIRST int_ndd_envio WHERE 
                       int_ndd_envio.cod_estabel = nota-fiscal.cod-estabel AND
                       int_ndd_envio.serie       = nota-fiscal.serie       AND
                       int_ndd_envio.nr_nota_fis = nota-fiscal.nr-nota-fis NO-LOCK: 
                IF int_ndd_envio.statusnumber = 0 THEN
                   ASSIGN c-ndd-envio = "Enviada".
                IF int_ndd_envio.statusnumber = 1 THEN
                   ASSIGN c-ndd-envio = "Processada".
             END.
             ASSIGN i-sit-nfe = nota-fiscal.idi-sit-nf-eletro.
             if i-sit-nfe = 0 then 
                assign i-sit-nfe = 99.

             FOR FIRST estabelec WHERE
                       estabelec.cod-estabel = nota-fiscal.cod-estabel NO-LOCK: 
                FOR each int_ds_nota_saida WHERE 
                         int_ds_nota_saida.nsa_notafiscal_n  = int(nota-fiscal.nr-nota-fis) AND
                         int_ds_nota_saida.nsa_serie_s       = nota-fiscal.serie AND 
                         int_ds_nota_saida.nsa_cnpj_origem_s = estabelec.cgc NO-LOCK: 
                   IF int_ds_nota_saida.situacao = 1 THEN
                      ASSIGN c-nota-origem = "Enviada".
                   IF int_ds_nota_saida.situacao = 2 THEN
                      ASSIGN c-nota-origem = "Processada".
                   /*PROCFIT */
                   IF int_ds_nota_saida.envio_Status = 1 THEN
                      ASSIGN c-nota-destino = "Enviada".
                   IF int_ds_nota_saida.envio_Status = 2 THEN
                      ASSIGN c-nota-destino = "Processada".
                END.
             END.
          END.
       END.
  
       IF i-situacao = 3 
       OR i-situacao = 5 THEN DO:
          ASSIGN i-sit-nfe = 0.
          FOR FIRST nota-fiscal USE-INDEX ch-pedido WHERE 
                    nota-fiscal.nome-ab-cli       = tt-int_ds_pedido-aux.nome-abrev AND
                    nota-fiscal.nr-pedcli         = trim(string(tt-int_ds_pedido-aux.ped_codigo_n)) AND 
                    nota-fiscal.idi-sit-nf-eletro = 3 NO-LOCK QUERY-TUNING(NO-LOOKAHEAD): 

             ASSIGN i-nf-autor      = 3                        
                    i-nr-nf-autoriz = i-nr-nf-autoriz + 1
                    c-nr-nf         = nota-fiscal.nr-nota-fis
                    c-serie         = nota-fiscal.serie        
                    da-dt-ger-nota  = nota-fiscal.dt-emis-nota
                    c-hr-ger-nota   = nota-fiscal.hr-atualiza.

             FOR FIRST int_ndd_envio WHERE 
                       int_ndd_envio.cod_estabel = nota-fiscal.cod-estabel AND
                       int_ndd_envio.serie       = nota-fiscal.serie       AND
                       int_ndd_envio.nr_nota_fis = nota-fiscal.nr-nota-fis NO-LOCK: 
                IF int_ndd_envio.statusnumber = 0 THEN
                   ASSIGN c-ndd-envio = "Enviada".
                IF int_ndd_envio.statusnumber = 1 THEN
                   ASSIGN c-ndd-envio = "Processada".
             END.

             ASSIGN i-sit-nfe = nota-fiscal.idi-sit-nf-eletro.
             IF i-sit-nfe = 0 THEN 
                ASSIGN i-sit-nfe = 99.

             FOR FIRST estabelec WHERE
                       estabelec.cod-estabel = nota-fiscal.cod-estabel NO-LOCK: 
                FOR FIRST int_ds_nota_saida WHERE 
                          int_ds_nota_saida.nsa_notafiscal_n  = int(nota-fiscal.nr-nota-fis) AND
                          int_ds_nota_saida.nsa_serie_s       = nota-fiscal.serie AND 
                          int_ds_nota_saida.nsa_cnpj_origem_s = estabelec.cgc NO-LOCK: 
                   IF int_ds_nota_saida.situacao = 1 THEN
                      ASSIGN c-nota-origem = "Enviada".
                   IF int_ds_nota_saida.situacao = 2 THEN
                      ASSIGN c-nota-origem = "Processada".
                   /*PROCFIT */
                   IF int_ds_nota_saida.envio_Status = 1 THEN
                      ASSIGN c-nota-destino = "Enviada".
                   IF int_ds_nota_saida.envio_Status = 2 THEN
                      ASSIGN c-nota-destino = "Processada".
                END.
             END.
          END.
       END.
    END.

    ASSIGN i-nr-itens = 0.
    IF tt-int_ds_pedido-aux.tp_pedido = 48 THEN DO:
       FOR EACH int_ds_pedido_produto_subs OF tt-int_ds_pedido-aux NO-LOCK QUERY-TUNING(NO-LOOKAHEAD):
           ASSIGN i-nr-itens = i-nr-itens + 1.
       END.       
    END.
    ELSE DO:
        FOR EACH int_ds_pedido_retorno OF tt-int_ds_pedido-aux NO-LOCK QUERY-TUNING(NO-LOOKAHEAD):
            ASSIGN i-nr-itens = i-nr-itens + 1.
        END.       
    END.

    IF i-ped-pend <> 0 OR i-ped-canc <> 0
    OR i-nf-ger   <> 0 OR i-nf-autor <> 0 THEN DO:   

       if i-sit-nfe = 0 then 
          assign i-sit-nfe = 99.        

       create tt-int_ds_pedido.
       buffer-copy tt-int_ds_pedido-aux to tt-int_ds_pedido.
       ASSIGN tt-int_ds_pedido.qtde-itens   = i-nr-itens
              tt-int_ds_pedido.cod-estabel  = tt-int_ds_pedido-aux.cod-estabel
              tt-int_ds_pedido.nr-nota-fis  = c-nr-nf
              tt-int_ds_pedido.serie        = c-serie
              tt-int_ds_pedido.dt-ger-ped   = tt-int_ds_pedido-aux.dt_geracao
              tt-int_ds_pedido.hr-ger-ped   = substr(tt-int_ds_pedido-aux.hr_geracao,1,5)
              tt-int_ds_pedido.dt-ger-nota  = da-dt-ger-nota
              tt-int_ds_pedido.hr-ger-nota  = c-hr-ger-nota
              tt-int_ds_pedido.ndd-envio    = c-ndd-envio
              tt-int_ds_pedido.nota-origem  = c-nota-origem
              tt-int_ds_pedido.nota-destino = c-nota-destino
              tt-int_ds_pedido.nome-abrev   = tt-int_ds_pedido-aux.nome-abrev 
              tt-int_ds_pedido.modal-ped    = tt-int_ds_pedido-aux.mod-pedido 
              tt-int_ds_pedido.tipo-ped     = tt-int_ds_pedido-aux.tp_pedido.

       IF i-sit-nfe = 99 THEN
          ASSIGN tt-int_ds_pedido.sit-nfe = "".
       ELSE
          ASSIGN tt-int_ds_pedido.sit-nfe = ENTRY(i-sit-nfe,c-sit-nfe).
       IF i-ped-pend = 1 THEN
          ASSIGN tt-int_ds_pedido.sit-ped = "Pedido Pendente".
       IF i-nf-ger = 2 THEN
          ASSIGN tt-int_ds_pedido.sit-ped = "NF Gerada".
       IF i-nf-autor = 3 THEN
          ASSIGN tt-int_ds_pedido.sit-ped = "NF Autorizada".
       IF i-ped-pend = 4 THEN
          ASSIGN tt-int_ds_pedido.sit-ped = "Pedido c/ Erro".
       IF i-ped-canc = 5 THEN
          ASSIGN tt-int_ds_pedido.sit-ped = "Pedido Cancelado".
    END.
END.

DISP i-nr-ped-pend i-nr-ped-canc
     i-nr-ped-erro i-nr-nf-gerada
     i-nr-nf-autoriz WITH FRAME {&FRAME-NAME}.

run pi-finalizar in h-acomp.

session:SET-WAIT-STATE ("").

if can-find (first tt-int_ds_pedido) then do:
   OPEN QUERY brPed FOR EACH tt-int_ds_pedido USE-INDEX situacao NO-LOCK
       max-rows 100000 .
   enable all with frame fPage1.
   brPed:SELECT-ROW(1) in frame fPage1.
   apply "VALUE-CHANGED":U to brPed in frame fPage1.
end.
else do:
   close query brPed.
   disable all with frame fPage1.
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION fnRefresh wWindow 
FUNCTION fnRefresh returns logical ( ) :
    IF rs-consulta:SCREEN-VALUE IN FRAME fPage0 = "2" THEN DO:
        chCtrlFrame:PSTimer:interval = 0.
        APPLY "LEAVE" TO c-intervalo IN FRAME fPage0.
    END.

    RETURN FALSE.   

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

