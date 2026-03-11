&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
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
/********************************************************************************
**
** Programa: int050 - GestÆo de Faturamento Transferˆncias CD -> Filiais
**
********************************************************************************/
{include/i-prgvrs.i INT050 2.00.00.000}

CREATE WIDGET-POOL.

/* Preprocessors Definitions ---                                      */
&GLOBAL-DEFINE Program        INT050
&GLOBAL-DEFINE Version        2.00.00.000

&GLOBAL-DEFINE WindowType     Master

&GLOBAL-DEFINE Folder         NO
&GLOBAL-DEFINE InitialPage    1
&GLOBAL-DEFINE FolderLabels   Pedidos

&GLOBAL-DEFINE page0Widgets   btQueryJoins btReportsJoins btExit btHelp ~
                              btOK btCancel btHelp2 btSelecao c-intervalo btAtualiza btSerie rs-consulta btItens btIndica
&GLOBAL-DEFINE page1Widgets   brPed

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */
DEFINE VAR c-rota-ini      AS CHAR FORMAT "x(12)"      NO-UNDO.
DEFINE VAR c-rota-fim      AS CHAR FORMAT "x(12)"      NO-UNDO.
DEFINE VAR c-filial-ini    AS CHAR FORMAT "x(5)"       NO-UNDO.
DEFINE VAR c-filial-fim    AS CHAR FORMAT "x(5)"       NO-UNDO.
DEFINE VAR c-placa-ini     AS CHAR FORMAT "x(10)"      NO-UNDO.
DEFINE VAR c-placa-fim     AS CHAR FORMAT "x(10)"      NO-UNDO.
DEFINE VAR i-pedido-ini    AS INT  FORMAT ">>>>>>>>9"  NO-UNDO.
DEFINE VAR i-pedido-fim    AS INT  FORMAT ">>>>>>>>9"  NO-UNDO.
DEFINE VAR c-serie-ini     AS CHAR FORMAT "x(5)"       NO-UNDO.
DEFINE VAR c-serie-fim     AS CHAR FORMAT "x(5)"       NO-UNDO.
DEFINE VAR d-dt-ini        AS DATE FORMAT "99/99/9999" NO-UNDO.
DEFINE VAR i-situacao      AS INTEGER INITIAL 4        NO-UNDO.
DEFINE VAR c-sit-nfe       AS CHAR INIT "NF-e nÆo Gerada,Em Processamento no EAI,Uso Autorizado,Uso Denegado,Documento Rejeitado,Documento Cancelado,Documento Inutilizado,              
                                         Em Processamento Aplic. TransmissÆo,Em Processamento na SEFAZ,Em processamento no SCAN,NF-e Gerada,NF-e em Processo de Cancelamento,   
                                         NF-e em Processo de Inutiliza‡Æo,NF-e Pendente de Retorno,DPEC Recebido pelo SCE" NO-UNDO.
DEFINE VAR i-sit-nfe       AS INT NO-UNDO.

def temp-table tt-raw-digita NO-UNDO field raw-digita  as raw.

define temp-table tt-param no-undo
    field destino          as integer
    field arquivo          as char format "x(35)"
    field usuario          as char format "x(12)"
    field data-exec        as date
    field hora-exec        as integer
    field classifica       as integer
    field desc-classifica  as char format "x(40)".

DEF BUFFER b-int_ds_pedido FOR int_ds_pedido.

def var raw-param          as raw no-undo.

def var h-acomp as handle no-undo.

DEF VAR i-nr-itens       AS INT NO-UNDO.
DEF VAR i-ped-pend       AS INT NO-UNDO.
DEF VAR i-nf-ger         AS INT NO-UNDO.
DEF VAR i-nf-autor       AS INT NO-UNDO.
DEF VAR c-rota           AS CHAR NO-UNDO.
DEF VAR c-estabel        AS CHAR NO-UNDO.
DEF VAR c-nr-nf          AS CHAR NO-UNDO.
DEF VAR c-serie          AS CHAR NO-UNDO.
DEF VAR c-transp         AS CHAR NO-UNDO.
DEF VAR c-placa          AS CHAR NO-UNDO.
DEF VAR c-uf-placa       AS CHAR NO-UNDO.
DEF VAR c-ndd-envio      AS CHAR NO-UNDO.
DEF VAR c-nota-origem    AS CHAR NO-UNDO.
DEF VAR c-nota-destino   AS CHAR NO-UNDO.
DEF VAR da-dt-ger-nota   AS DATE FORMAT "99/99/9999" NO-UNDO.
DEF VAR c-hr-ger-nota    AS CHAR FORMAT "x(10)" NO-UNDO.
def var c-origem         as char no-undo.
def var c-uf-origem      as char no-undo.
DEF VAR i-ped-integrado  AS INT NO-UNDO.
DEF VAR i-ped-faturado   AS INT NO-UNDO.
DEF VAR i-item-integrado AS INT NO-UNDO.
DEF VAR i-item-faturado  AS INT NO-UNDO.
DEF VAR c-hora-ini       AS CHAR NO-UNDO.
DEF VAR c-hora-fim       AS CHAR NO-UNDO.
DEF VAR i-hora-ini       AS INT NO-UNDO.
DEF VAR i-hora-fim       AS INT NO-UNDO.
DEF VAR i-min-ini        AS INT NO-UNDO.
DEF VAR i-min-fim        AS INT NO-UNDO.
DEF VAR i-segundos       AS INT NO-UNDO.
DEF VAR i-minutos        AS INT NO-UNDO.
DEF VAR i-tot-item       AS INT NO-UNDO.
DEF VAR i-tot-tempo      AS INT NO-UNDO.
DEF VAR dat-prim-nf      AS DATE NO-UNDO.
DEF VAR dat-ult-nf       AS DATE NO-UNDO.
DEF VAR hr-prim-nf       AS INT NO-UNDO.
DEF VAR hr-ult-nf        AS INT NO-UNDO.
DEF VAR min-nf           AS DEC NO-UNDO.
DEF VAR item-min         AS DEC NO-UNDO.
DEF VAR l-serie-10       AS LOGICAL NO-UNDO.
DEF VAR l-serie-11       AS LOGICAL NO-UNDO.
DEF VAR l-serie-12       AS LOGICAL NO-UNDO.
DEF VAR l-serie-13       AS LOGICAL NO-UNDO.
DEF VAR l-serie-14       AS LOGICAL NO-UNDO.
DEF VAR i-tempo-fat      AS INT     NO-UNDO.

def buffer b-estabelec     for estabelec.
DEF BUFFER bf-int_ds_pedido FOR int_ds_pedido.

DEFINE TEMP-TABLE tt-indicador LIKE cst_monitor_fat.

DEFINE TEMP-TABLE tt-int_ds_pedido NO-UNDO LIKE int_ds_pedido
       field cod-rota as char
       field cod-estabel as char format "x(4)"
       field qtde-itens as int format ">>,>>9"
       field transport as char format "x(12)"
       field placa as char format "x(10)"
       field uf-placa as char format "x(4)"
       field serie as char format "x(5)"
       field nr-nota-fis as char format "x(16)"
       field sit-ped as char format "x(20)"
       field dt-ger-ped as date format "99/99/9999"
       field hr-ger-ped as char format "x(10)"
       field dt-ger-nota as date format "99/99/9999"
       field hr-ger-nota as char format "x(10)"
       field ordem       as int
       field ndd-envio as char
       field sit-nfe as char
       FIELD nota-origem AS CHAR
       FIELD nota-destino AS CHAR
       FIELD nome-ab-cli AS CHAR
       index situacao 
                serie 
                ordem 
                dt-ger-ped 
                hr-ger-ped 
                ped_codigo_n
       INDEX hora-gera 
                hr-ger-nota
       INDEX sit-ped
                situacao.

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
&Scoped-define FIELDS-IN-QUERY-brPed tt-int_ds_pedido.cod-rota tt-int_ds_pedido.cod-estabel tt-int_ds_pedido.ped_codigo_n tt-int_ds_pedido.dt-ger-ped tt-int_ds_pedido.hr-ger-ped tt-int_ds_pedido.qtde-itens tt-int_ds_pedido.transport tt-int_ds_pedido.placa tt-int_ds_pedido.uf-placa tt-int_ds_pedido.serie tt-int_ds_pedido.nr-nota-fis tt-int_ds_pedido.dt-ger-nota tt-int_ds_pedido.hr-ger-nota tt-int_ds_pedido.ndd-envio tt-int_ds_pedido.sit-ped tt-int_ds_pedido.sit-nfe tt-int_ds_pedido.nota-destino tt-int_ds_pedido.nota-origem   
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
rtToolBar-3 RECT-1 RECT-consulta-3 btQueryJoins btReportsJoins btExit ~
btHelp btSelecao btAtualiza rs-consulta btSerie btOK btCancel btItens ~
btIndica btHelp2 
&Scoped-Define DISPLAYED-OBJECTS tot-ped-integrado tot-ped-faturado ~
i-nr-ped-pend i-nr-nf-gerada c-serie-10 c-serie-11 c-serie-12 c-serie-13 ~
c-serie-14 rs-consulta tot-item-integrado tot-item-faturado c-intervalo ~
i-nr-ped-erro i-nr-nf-autoriz i-serie-10 i-serie-11 i-serie-12 i-serie-13 ~
i-serie-14 media-item-ped-int media-item-ped-fat 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD fnRefresh wWindow 
FUNCTION fnRefresh returns logical () FORWARD.

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
DEFINE BUTTON btAtualiza 
     IMAGE-UP FILE "image/im-relo.bmp":U
     IMAGE-INSENSITIVE FILE "image/ii-relo.bmp":U
     LABEL "Query Joins" 
     SIZE 4 BY 1.21
     FONT 4.

DEFINE BUTTON btCancel 
     LABEL "Cancelar" 
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

DEFINE BUTTON btIndica 
     LABEL "Indicadores" 
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
     LABEL "Sele‡Æo" 
     SIZE 4 BY 1.21
     FONT 4.

DEFINE BUTTON btSerie 
     IMAGE-UP FILE "image/im-relo.bmp":U
     IMAGE-INSENSITIVE FILE "image/ii-relo.bmp":U
     LABEL "Query Joins" 
     SIZE 4 BY 1.25
     FONT 4.

DEFINE VARIABLE c-intervalo AS INTEGER FORMAT ">,>>>,>>9":U INITIAL 10 
     VIEW-AS FILL-IN 
     SIZE 4 BY .79 NO-UNDO.

DEFINE VARIABLE c-serie-10 AS CHARACTER FORMAT "x(8)":U INITIAL "S‚rie 10" 
     VIEW-AS FILL-IN 
     SIZE 7.43 BY .88 NO-UNDO.

DEFINE VARIABLE c-serie-11 AS CHARACTER FORMAT "x(8)":U INITIAL "S‚rie 11" 
     VIEW-AS FILL-IN 
     SIZE 7.43 BY .88 NO-UNDO.

DEFINE VARIABLE c-serie-12 AS CHARACTER FORMAT "x(8)":U INITIAL "S‚rie 12" 
     VIEW-AS FILL-IN 
     SIZE 7.43 BY .88 NO-UNDO.

DEFINE VARIABLE c-serie-13 AS CHARACTER FORMAT "x(8)":U INITIAL "S‚rie 13" 
     VIEW-AS FILL-IN 
     SIZE 7.43 BY .88 NO-UNDO.

DEFINE VARIABLE c-serie-14 AS CHARACTER FORMAT "x(8)":U INITIAL "S‚rie 14" 
     VIEW-AS FILL-IN 
     SIZE 7.43 BY .88 NO-UNDO.

DEFINE VARIABLE i-nr-nf-autoriz AS INTEGER FORMAT ">,>>>,>>9":U INITIAL 0 
     LABEL "Nr. Notas Autorizadas" 
     VIEW-AS FILL-IN 
     SIZE 10 BY .88 NO-UNDO.

DEFINE VARIABLE i-nr-nf-gerada AS INTEGER FORMAT ">,>>>,>>9":U INITIAL 0 
     LABEL "Nr. Notas Geradas" 
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

DEFINE VARIABLE i-serie-10 AS INTEGER FORMAT "->,>>>,>>9":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 7.43 BY .88 NO-UNDO.

DEFINE VARIABLE i-serie-11 AS INTEGER FORMAT "->,>>>,>>9":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 7.43 BY .88 NO-UNDO.

DEFINE VARIABLE i-serie-12 AS INTEGER FORMAT "->,>>>,>>9":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 7.43 BY .88 NO-UNDO.

DEFINE VARIABLE i-serie-13 AS INTEGER FORMAT "->,>>>,>>9":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 7.43 BY .88 NO-UNDO.

DEFINE VARIABLE i-serie-14 AS INTEGER FORMAT "->,>>>,>>9":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 7.43 BY .88 NO-UNDO.

DEFINE VARIABLE media-item-ped-fat AS DECIMAL FORMAT "->>,>>9.99":U INITIAL 0 
     LABEL "M‚dia Itens/Pedido" 
     VIEW-AS FILL-IN 
     SIZE 8.86 BY .88 NO-UNDO.

DEFINE VARIABLE media-item-ped-int AS DECIMAL FORMAT "->>,>>9.99":U INITIAL 0 
     LABEL "M‚dia Itens/Pedido" 
     VIEW-AS FILL-IN 
     SIZE 8.86 BY .88 NO-UNDO.

DEFINE VARIABLE tot-item-faturado AS INTEGER FORMAT "->,>>>,>>9":U INITIAL 0 
     LABEL "Itens Faturados" 
     VIEW-AS FILL-IN 
     SIZE 8.86 BY .88 NO-UNDO.

DEFINE VARIABLE tot-item-integrado AS INTEGER FORMAT "->,>>>,>>9":U INITIAL 0 
     LABEL "Itens Integrados" 
     VIEW-AS FILL-IN 
     SIZE 8.86 BY .88 NO-UNDO.

DEFINE VARIABLE tot-ped-faturado AS INTEGER FORMAT "->,>>>,>>9":U INITIAL 0 
     LABEL "Pedidos Faturados" 
     VIEW-AS FILL-IN 
     SIZE 8.86 BY .88 NO-UNDO.

DEFINE VARIABLE tot-ped-integrado AS INTEGER FORMAT "->,>>>,>>9":U INITIAL 0 
     LABEL "Pedidos Integrados" 
     VIEW-AS FILL-IN 
     SIZE 8.86 BY .88 NO-UNDO.

DEFINE VARIABLE rs-consulta AS INTEGER INITIAL 2 
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS 
          "Manual", 1,
"Autom tico", 2
     SIZE 11.57 BY 1.5 NO-UNDO.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 51 BY 3.58.

DEFINE RECTANGLE RECT-consulta
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 28.29 BY 2.58.

DEFINE RECTANGLE RECT-consulta-2
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 57.72 BY 2.58.

DEFINE RECTANGLE RECT-consulta-3
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 42.72 BY 2.58.

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
      tt-int_ds_pedido.cod-rota              COLUMN-LABEL "Rota" 
tt-int_ds_pedido.cod-estabel           COLUMN-LABEL "Filial" 
tt-int_ds_pedido.ped_codigo_n          COLUMN-LABEL "Pedido" 
tt-int_ds_pedido.dt-ger-ped            COLUMN-LABEL "Data Ger Ped"
tt-int_ds_pedido.hr-ger-ped            COLUMN-LABEL "Hora Ger Ped"
tt-int_ds_pedido.qtde-itens            COLUMN-LABEL " Nr. Itens" FORMAT ">>,>>9"
tt-int_ds_pedido.transport             COLUMN-LABEL "Transportador" FORMAT "x(12)"
tt-int_ds_pedido.placa                 COLUMN-LABEL "Placa" FORMAT "x(10)"                                                       
tt-int_ds_pedido.uf-placa              COLUMN-LABEL "UF Placa" FORMAT "x(4)"
tt-int_ds_pedido.serie                 COLUMN-LABEL "S‚rie" FORMAT "x(5)"
tt-int_ds_pedido.nr-nota-fis           COLUMN-LABEL "Nota Fiscal" FORMAT "x(16)"
tt-int_ds_pedido.dt-ger-nota           COLUMN-LABEL "Data Ger NF"
tt-int_ds_pedido.hr-ger-nota           COLUMN-LABEL "Hora Ger NF" 
tt-int_ds_pedido.ndd-envio             COLUMN-LABEL "NDD Envio" FORMAT "X(12)" 
tt-int_ds_pedido.sit-ped               COLUMN-LABEL "Situa‡Æo Pedido" FORMAT "x(25)"
tt-int_ds_pedido.sit-nfe               COLUMN-LABEL "Situa‡Æo NF-e" FORMAT "x(37)"
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
     btAtualiza AT ROW 1.17 COL 7.43 WIDGET-ID 70
     tot-ped-integrado AT ROW 3.04 COL 149.14 COLON-ALIGNED WIDGET-ID 34
     tot-ped-faturado AT ROW 3.04 COL 174.43 COLON-ALIGNED WIDGET-ID 36
     i-nr-ped-pend AT ROW 3.58 COL 18.29 COLON-ALIGNED WIDGET-ID 20
     i-nr-nf-gerada AT ROW 3.58 COL 46.43 COLON-ALIGNED WIDGET-ID 22
     c-serie-10 AT ROW 3.67 COL 61.14 COLON-ALIGNED NO-LABEL WIDGET-ID 72
     c-serie-11 AT ROW 3.67 COL 69.29 COLON-ALIGNED NO-LABEL WIDGET-ID 60
     c-serie-12 AT ROW 3.67 COL 77.43 COLON-ALIGNED NO-LABEL WIDGET-ID 62
     c-serie-13 AT ROW 3.67 COL 85.57 COLON-ALIGNED NO-LABEL WIDGET-ID 64
     c-serie-14 AT ROW 3.67 COL 93.72 COLON-ALIGNED NO-LABEL WIDGET-ID 66
     rs-consulta AT ROW 3.88 COL 107 NO-LABEL WIDGET-ID 10
     btSerie AT ROW 3.88 COL 127.72 WIDGET-ID 4
     tot-item-integrado AT ROW 4.04 COL 149.14 COLON-ALIGNED WIDGET-ID 38
     tot-item-faturado AT ROW 4.04 COL 174.43 COLON-ALIGNED WIDGET-ID 40
     c-intervalo AT ROW 4.13 COL 116.86 COLON-ALIGNED NO-LABEL WIDGET-ID 6
     i-nr-ped-erro AT ROW 4.58 COL 18.29 COLON-ALIGNED WIDGET-ID 26
     i-nr-nf-autoriz AT ROW 4.58 COL 46.43 COLON-ALIGNED WIDGET-ID 24
     i-serie-10 AT ROW 4.67 COL 61.14 COLON-ALIGNED NO-LABEL WIDGET-ID 74
     i-serie-11 AT ROW 4.67 COL 69.29 COLON-ALIGNED NO-LABEL WIDGET-ID 76
     i-serie-12 AT ROW 4.67 COL 77.43 COLON-ALIGNED NO-LABEL WIDGET-ID 78
     i-serie-13 AT ROW 4.67 COL 85.57 COLON-ALIGNED NO-LABEL WIDGET-ID 80
     i-serie-14 AT ROW 4.67 COL 93.72 COLON-ALIGNED NO-LABEL WIDGET-ID 82
     media-item-ped-int AT ROW 5.04 COL 149.14 COLON-ALIGNED WIDGET-ID 42
     media-item-ped-fat AT ROW 5.04 COL 174.43 COLON-ALIGNED WIDGET-ID 44
     btOK AT ROW 24.71 COL 3.29
     btCancel AT ROW 24.71 COL 14.29
     btItens AT ROW 24.71 COL 25.29 WIDGET-ID 56
     btIndica AT ROW 24.71 COL 36.29 WIDGET-ID 30
     btHelp2 AT ROW 24.71 COL 177.86
     " S‚ries / Nr. Pedidos" VIEW-AS TEXT
          SIZE 14.57 BY .54 AT ROW 2.92 COL 75.14 WIDGET-ID 84
     "seg." VIEW-AS TEXT
          SIZE 3.57 BY .54 AT ROW 4.21 COL 123.29 WIDGET-ID 16
     " Atualiza Faturamento S‚ries" VIEW-AS TEXT
          SIZE 20 BY .54 AT ROW 2.92 COL 107.29 WIDGET-ID 14
     rtToolBar-2 AT ROW 1 COL 1.57
     RECT-consulta AT ROW 3.21 COL 105.43 WIDGET-ID 8
     RECT-consulta-2 AT ROW 3.21 COL 2.29 WIDGET-ID 28
     rtToolBar-3 AT ROW 24.5 COL 2 WIDGET-ID 32
     RECT-1 AT ROW 2.71 COL 135.86 WIDGET-ID 46
     RECT-consulta-3 AT ROW 3.21 COL 61.72 WIDGET-ID 68
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
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
IF SESSION:DISPLAY-TYPE = "GUI":U THEN
  CREATE WINDOW wWindow ASSIGN
         HIDDEN             = YES
         TITLE              = ""
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
/* SETTINGS FOR FILL-IN c-serie-10 IN FRAME fpage0
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN c-serie-11 IN FRAME fpage0
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN c-serie-12 IN FRAME fpage0
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN c-serie-13 IN FRAME fpage0
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN c-serie-14 IN FRAME fpage0
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN i-nr-nf-autoriz IN FRAME fpage0
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN i-nr-nf-gerada IN FRAME fpage0
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN i-nr-ped-erro IN FRAME fpage0
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN i-nr-ped-pend IN FRAME fpage0
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN i-serie-10 IN FRAME fpage0
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN i-serie-11 IN FRAME fpage0
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN i-serie-12 IN FRAME fpage0
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN i-serie-13 IN FRAME fpage0
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN i-serie-14 IN FRAME fpage0
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN media-item-ped-fat IN FRAME fpage0
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN media-item-ped-int IN FRAME fpage0
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN tot-item-faturado IN FRAME fpage0
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN tot-item-integrado IN FRAME fpage0
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN tot-ped-faturado IN FRAME fpage0
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN tot-ped-integrado IN FRAME fpage0
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


&Scoped-define BROWSE-NAME brPed
&Scoped-define FRAME-NAME fPage1
&Scoped-define SELF-NAME brPed
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL brPed wWindow
ON MOUSE-SELECT-DBLCLICK OF brPed IN FRAME fPage1
DO:
  IF AVAIL tt-int_ds_pedido THEN DO:
     RUN intprg/int050c.w (INPUT tt-int_ds_pedido.ped_codigo_n).
  END.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL brPed wWindow
ON ROW-DISPLAY OF brPed IN FRAME fPage1
DO: 
   IF tt-int_ds_pedido.sit-ped = "NF Gerada" THEN 
      assign tt-int_ds_pedido.cod-rota:bgcolor in browse brPed = 14
             tt-int_ds_pedido.cod-estabel:bgcolor in browse brPed = 14          
             tt-int_ds_pedido.ped_codigo_n:bgcolor in browse brPed = 14     
             tt-int_ds_pedido.dt-ger-ped:bgcolor in browse brPed = 14
             tt-int_ds_pedido.hr-ger-ped:bgcolor in browse brPed = 14
             tt-int_ds_pedido.qtde-itens:bgcolor in browse brPed = 14           
             tt-int_ds_pedido.transport:bgcolor in browse brPed = 14            
             tt-int_ds_pedido.placa:bgcolor in browse brPed = 14                
             tt-int_ds_pedido.uf-placa:bgcolor in browse brPed = 14             
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
      assign tt-int_ds_pedido.cod-rota:bgcolor in browse brPed = 10
             tt-int_ds_pedido.cod-estabel:bgcolor in browse brPed = 10          
             tt-int_ds_pedido.ped_codigo_n:bgcolor in browse brPed = 10
             tt-int_ds_pedido.dt-ger-ped:bgcolor in browse brPed = 10
             tt-int_ds_pedido.hr-ger-ped:bgcolor in browse brPed = 10
             tt-int_ds_pedido.qtde-itens:bgcolor in browse brPed = 10           
             tt-int_ds_pedido.transport:bgcolor in browse brPed = 10            
             tt-int_ds_pedido.placa:bgcolor in browse brPed = 10                
             tt-int_ds_pedido.uf-placa:bgcolor in browse brPed = 10             
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
      assign tt-int_ds_pedido.cod-rota:bgcolor in browse brPed = 12
             tt-int_ds_pedido.cod-estabel:bgcolor in browse brPed = 12          
             tt-int_ds_pedido.ped_codigo_n:bgcolor in browse brPed = 12     
             tt-int_ds_pedido.dt-ger-ped:bgcolor in browse brPed = 12
             tt-int_ds_pedido.hr-ger-ped:bgcolor in browse brPed = 12
             tt-int_ds_pedido.qtde-itens:bgcolor in browse brPed = 12           
             tt-int_ds_pedido.transport:bgcolor in browse brPed = 12            
             tt-int_ds_pedido.placa:bgcolor in browse brPed = 12                
             tt-int_ds_pedido.uf-placa:bgcolor in browse brPed = 12             
             tt-int_ds_pedido.serie:bgcolor in browse brPed = 12                
             tt-int_ds_pedido.nr-nota-fis:bgcolor in browse brPed = 12      
             tt-int_ds_pedido.dt-ger-nota:bgcolor in browse brPed = 12
             tt-int_ds_pedido.hr-ger-nota:bgcolor in browse brPed = 12
             tt-int_ds_pedido.ndd-envio:bgcolor in browse brPed = 12
             tt-int_ds_pedido.sit-nfe:bgcolor in browse brPed = 12     
             tt-int_ds_pedido.sit-ped:bgcolor in browse brPed = 12
             tt-int_ds_pedido.nota-origem:bgcolor in browse brPed = 12
             tt-int_ds_pedido.nota-destino:bgcolor in browse brPed = 12.

   IF tt-int_ds_pedido.sit-ped <> "Pedido Pendente" THEN DO:
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
&Scoped-define SELF-NAME btAtualiza
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btAtualiza wWindow
ON CHOOSE OF btAtualiza IN FRAME fpage0 /* Query Joins */
RUN pi-openQueryPed.

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


&Scoped-define SELF-NAME btIndica
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btIndica wWindow
ON CHOOSE OF btIndica IN FRAME fpage0 /* Indicadores */
DO:  
  IF AVAIL tt-int_ds_pedido THEN DO:
     RUN intprg/int050d.w (INPUT min-nf,            
                           INPUT item-min,          
                           INPUT INPUT FRAME fPage0 tot-ped-integrado, 
                           INPUT INPUT FRAME fPage0 tot-item-integrado,
                           INPUT INPUT FRAME fPage0 media-item-ped-int,
                           INPUT INPUT FRAME fPage0 tot-ped-faturado,  
                           INPUT INPUT FRAME fPage0 tot-item-faturado, 
                           INPUT INPUT FRAME fPage0 media-item-ped-fat,
                           INPUT /*d-dt-ini*/ dat-prim-nf,        
                           INPUT /*c-hora-ini*/ hr-prim-nf,        
                           INPUT 0,    
                           INPUT /*d-dt-ini*/ dat-ult-nf,         
                           INPUT /*c-hora-fim*/hr-ult-nf,         
                           INPUT i-tempo-fat).   
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btItens
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btItens wWindow
ON CHOOSE OF btItens IN FRAME fpage0 /* Itens Pedido */
DO:  
  IF AVAIL tt-int_ds_pedido THEN DO:
     RUN intprg/int050b.w (INPUT tt-int_ds_pedido.ped_codigo_n).
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
ON CHOOSE OF btSelecao IN FRAME fpage0 /* Sele‡Æo */
OR CHOOSE OF btSelecao DO:
   fnRefresh().
   DEF VAR l-openquery AS LOG NO-UNDO.

   RUN intprg/int050a.w (INPUT-OUTPUT c-rota-ini,  
                         INPUT-OUTPUT c-rota-fim,  
                         INPUT-OUTPUT c-filial-ini,
                         INPUT-OUTPUT c-filial-fim,
                         INPUT-OUTPUT c-placa-ini,
                         INPUT-OUTPUT c-placa-fim,
                         INPUT-OUTPUT i-pedido-ini,
                         INPUT-OUTPUT i-pedido-fim,
                         INPUT-OUTPUT c-serie-ini,
                         INPUT-OUTPUT c-serie-fim,
                         INPUT-OUTPUT d-dt-ini,    
                         INPUT-OUTPUT i-situacao,  
                         OUTPUT l-openquery ).

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btSerie
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btSerie wWindow
ON CHOOSE OF btSerie IN FRAME fpage0 /* Query Joins */
OR CHOOSE OF btSerie DO:
    fnRefresh().
    RUN pi-atualiza-serie.
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
                         input "O intervalo de atualiza‡Æo deve ser informado!").    
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
    APPLY "CHOOSE" TO btSerie IN FRAME fPage0.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME rs-consulta
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL rs-consulta wWindow
ON VALUE-CHANGED OF rs-consulta IN FRAME fpage0
DO:
  IF rs-consulta:SCREEN-VALUE IN FRAME fPage0 = "2" THEN DO:
      ENABLE c-intervalo WITH FRAME fPage0.
      DISABLE btSerie WITH FRAME fPage0.
      display c-intervalo WITH FRAME fPage0.
      chCtrlFrame:PSTimer:interval = INT(c-intervalo:SCREEN-VALUE IN FRAME fPage0) * 1000.
  END.
  ELSE DO:
      DISABLE c-intervalo WITH FRAME fPage0. 
      ENABLE btSerie WITH FRAME fPage0.
      ASSIGN chCtrlFrame:PSTimer:interval = 0
             c-intervalo:SCREEN-VALUE IN FRAME fPage0 = "".
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


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
    CURRENT-LANGUAGE = CURRENT-LANGUAGE.
    
    ASSIGN c-rota-ini   = ""
           c-rota-fim   = "ZZZZZZZZZZZZ"
           c-filial-ini = ""
           c-filial-fim = "ZZZZZ"
           c-placa-ini  = ""
           c-placa-fim  = "ZZZZZZZZZZ"
           i-pedido-ini = 0
           i-pedido-fim = 999999999
           c-serie-ini  = ""
           c-serie-fim  = "ZZZZZ"
           d-dt-ini     = TODAY
           i-situacao   = 4.

    assign i-nr-nf-gerada:bgcolor in frame {&FRAME-NAME}  = 14
           i-nr-ped-erro:bgcolor in frame {&FRAME-NAME}   = 12
           i-nr-nf-autoriz:bgcolor in frame {&FRAME-NAME} = 10
           i-nr-ped-pend:bgcolor in frame {&FRAME-NAME}   = 15.

    DISP i-nr-ped-pend
         i-nr-ped-erro
         i-nr-nf-gerada
         i-nr-nf-autoriz 
         tot-ped-integrado
         tot-ped-faturado
         tot-item-integrado
         tot-item-faturado
         media-item-ped-int
         media-item-ped-fat      
         WITH FRAME {&FRAME-NAME}.

    RUN pi-atualiza-serie.

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

OCXFile = SEARCH( "int050.wrx":U ).
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
ELSE MESSAGE "int050.wrx":U SKIP(1)
             "The binary control file could not be found. The controls cannot be loaded."
             VIEW-AS ALERT-BOX TITLE "Controls Not Loaded".

&ENDIF

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-atualiza-serie wWindow 
PROCEDURE pi-atualiza-serie :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

ASSIGN c-serie-10:bgcolor in frame {&FRAME-NAME} = 15                                  
       c-serie-11:bgcolor in frame {&FRAME-NAME} = 15                                  
       c-serie-12:bgcolor in frame {&FRAME-NAME} = 15                                  
       c-serie-13:bgcolor in frame {&FRAME-NAME} = 15                                  
       c-serie-14:bgcolor in frame {&FRAME-NAME} = 15
       l-serie-10 = NO
       l-serie-11 = NO
       l-serie-12 = NO
       l-serie-13 = NO
       l-serie-14 = NO
       i-serie-10 = 0 
       i-serie-11 = 0 
       i-serie-12 = 0 
       i-serie-13 = 0 
       i-serie-14 = 0.

for first b-estabelec fields (cod-estabel estado cgc)
    no-lock where b-estabelec.cod-estabel = "973" QUERY-TUNING(NO-LOOKAHEAD): 
end.

for each bf-int_ds_pedido no-lock where
         (bf-int_ds_pedido.ped_tipopedido_n = 1 OR 
         bf-int_ds_pedido.ped_tipopedido_n  = 8 OR 
         bf-int_ds_pedido.ped_tipopedido_n  = 37) AND
         bf-int_ds_pedido.situacao          = 1 AND
         bf-int_ds_pedido.ped_cnpj_origem_s = b-estabelec.cgc AND
         bf-int_ds_pedido.dt_geracao        = d-dt-ini AND 
         bf-int_ds_pedido.ped_codigo_n     >= i-pedido-ini AND 
         bf-int_ds_pedido.ped_codigo_n     <= i-pedido-fim QUERY-TUNING(NO-LOOKAHEAD):
    for first emitente no-lock where
              emitente.cgc = trim(bf-int_ds_pedido.ped_cnpj_destino_s) QUERY-TUNING(NO-LOOKAHEAD): 
    END.
    if not avail emitente then 
       next.
    FOR FIRST loc-entr WHERE
              loc-entr.nome-abrev = emitente.nome-abrev NO-LOCK QUERY-TUNING(NO-LOOKAHEAD): 
    END.
    IF NOT AVAIL loc-entr THEN
       NEXT.

    for first estab-rota-entreg WHERE   
              estab-rota-entreg.cod-estabel = "973" AND
              estab-rota-entreg.cod-rota    = loc-entr.cod-rota AND
              estab-rota-entreg.nome-abrev  = emitente.nome-abrev NO-LOCK QUERY-TUNING(NO-LOOKAHEAD):
    END.
    IF AVAIL estab-rota-entreg THEN DO:
       IF estab-rota-entreg.cod-livre-2 = "10" THEN
          ASSIGN l-serie-10 = YES
                 i-serie-10 = i-serie-10 + 1.
       IF estab-rota-entreg.cod-livre-2 = "11" THEN
          ASSIGN l-serie-11 = YES
                 i-serie-11 = i-serie-11 + 1.
       IF estab-rota-entreg.cod-livre-2 = "12" THEN
          ASSIGN l-serie-12 = YES
                 i-serie-12 = i-serie-12 + 1.
       IF estab-rota-entreg.cod-livre-2 = "13" THEN
          ASSIGN l-serie-13 = YES
                 i-serie-13 = i-serie-13 + 1.
       IF estab-rota-entreg.cod-livre-2 = "14" THEN
          ASSIGN l-serie-14 = YES
                 i-serie-14 = i-serie-14 + 1.
    END.
END.
                                  
FOR FIRST cst_mon_fat_serie NO-LOCK QUERY-TUNING(NO-LOOKAHEAD):
END.
IF AVAIL cst_mon_fat_serie THEN DO:
   IF cst_mon_fat_serie.serie_10 = YES THEN
      ASSIGN c-serie-10:bgcolor in frame {&FRAME-NAME} = 10.
   IF cst_mon_fat_serie.serie_11 = YES THEN
      ASSIGN c-serie-11:bgcolor in frame {&FRAME-NAME} = 10.
   IF cst_mon_fat_serie.serie_12 = YES THEN
      ASSIGN c-serie-12:bgcolor in frame {&FRAME-NAME} = 10.
   IF cst_mon_fat_serie.serie_13 = YES THEN
      ASSIGN c-serie-13:bgcolor in frame {&FRAME-NAME} = 10.
   IF cst_mon_fat_serie.serie_14 = YES THEN
      ASSIGN c-serie-14:bgcolor in frame {&FRAME-NAME} = 10.  
   IF  cst_mon_fat_serie.serie_10 = NO 
   AND l-serie-10 = YES THEN
       ASSIGN c-serie-10:bgcolor in frame {&FRAME-NAME} = 12.
   IF  cst_mon_fat_serie.serie_11 = NO 
   AND l-serie-11 = YES THEN
       ASSIGN c-serie-11:bgcolor in frame {&FRAME-NAME} = 12.
   IF  cst_mon_fat_serie.serie_12 = NO 
   AND l-serie-12 = YES THEN
       ASSIGN c-serie-12:bgcolor in frame {&FRAME-NAME} = 12.
   IF  cst_mon_fat_serie.serie_13 = NO 
   AND l-serie-13 = YES THEN
       ASSIGN c-serie-13:bgcolor in frame {&FRAME-NAME} = 12.
   IF  cst_mon_fat_serie.serie_14 = NO 
   AND l-serie-14 = YES THEN
       ASSIGN c-serie-14:bgcolor in frame {&FRAME-NAME} = 12.
END.

DISP c-serie-10
     c-serie-11
     c-serie-12
     c-serie-13
     c-serie-14
     i-serie-10
     i-serie-11
     i-serie-12
     i-serie-13
     i-serie-14
     WITH FRAME {&FRAME-NAME}.

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
empty temp-table tt-int_ds_pedido.
EMPTY TEMP-TABLE tt-indicador.

ASSIGN i-nr-ped-pend    = 0 
       i-nr-ped-erro    = 0
       i-nr-nf-gerada   = 0 
       i-nr-nf-autoriz  = 0
       i-ped-integrado  = 0 
       i-ped-faturado   = 0
       i-item-integrado = 0 
       i-item-faturado  = 0.

run utp/ut-acomp.p persistent set h-acomp.
run pi-inicializar in h-acomp ("Faturamento Transf. CD -> Filiais").

session:SET-WAIT-STATE ("GENERAL").
for first b-estabelec fields (cod-estabel estado cgc)
    no-lock where b-estabelec.cod-estabel = "973" QUERY-TUNING(NO-LOOKAHEAD): 
end.

RUN pi-processa-pedidos.

DISP i-nr-ped-pend
     i-nr-ped-erro
     i-nr-nf-gerada
     i-nr-nf-autoriz WITH FRAME {&FRAME-NAME}.

ASSIGN i-ped-integrado = i-nr-ped-pend  + i-nr-ped-erro
       i-ped-faturado  = i-nr-nf-gerada + i-nr-nf-autoriz
       c-hora-ini      = ""
       c-hora-fim      = ""
       dat-prim-nf     = ?
       dat-ult-nf      = ?
       hr-prim-nf      = 0
       hr-ult-nf       = 0
       i-tempo-fat     = 0
       i-tot-item      = 0
       i-tot-tempo     = 0.

FOR EACH tt-int_ds_pedido NO-LOCK QUERY-TUNING(NO-LOOKAHEAD):

    RUN pi-acompanhar IN h-acomp (INPUT "Calculando Indicadores. Pedido: " + string(tt-int_ds_pedido.ped_codigo_n)).

    FOR FIRST cst_monitor_fat USE-INDEX pedido WHERE
              cst_monitor_fat.ped_codigo_n = tt-int_ds_pedido.ped_codigo_n AND 
              cst_monitor_fat.cod_estabel <> "" AND 
              cst_monitor_fat.serie       <> "" AND 
              cst_monitor_fat.nr_nota_fis <> "" NO-LOCK QUERY-TUNING(NO-LOOKAHEAD):
    END.
    IF AVAIL cst_monitor_fat THEN DO:
       CREATE tt-indicador.
       BUFFER-COPY cst_monitor_fat TO tt-indicador.
    END.

    FOR EACH int_ds_pedido_retorno WHERE
             int_ds_pedido_retorno.ped_codigo_n = tt-int_ds_pedido.ped_codigo_n NO-LOCK QUERY-TUNING(NO-LOOKAHEAD):
        IF tt-int_ds_pedido.ordem = 1
        OR tt-int_ds_pedido.ordem = 4 THEN
           ASSIGN i-item-integrado = i-item-integrado + 1.
        IF tt-int_ds_pedido.ordem = 2
        OR tt-int_ds_pedido.ordem = 3 THEN
           ASSIGN i-item-faturado = i-item-faturado + 1.
    END.       
END.

FOR EACH tt-indicador QUERY-TUNING(NO-LOOKAHEAD):
    ASSIGN i-tot-item  = i-tot-item + tt-indicador.qtde_itens.
    IF tt-indicador.dt_ini_fat = tt-indicador.dt_fim_fat THEN
       ASSIGN i-tot-tempo = i-tot-tempo + (tt-indicador.hr_fim_fat - tt-indicador.hr_ini_fat).
    IF tt-indicador.dt_fim_fat > tt-indicador.dt_ini_fat THEN 
       ASSIGN i-tot-tempo = i-tot-tempo + ((86400 - tt-indicador.hr_ini_fat) + tt-indicador.hr_fim_fat).
END.

FOR FIRST tt-indicador USE-INDEX ini_fat QUERY-TUNING(NO-LOOKAHEAD):
    ASSIGN dat-prim-nf = tt-indicador.dt_ini_fat
           hr-prim-nf  = tt-indicador.hr_ini_fat.
END.

FOR LAST tt-indicador USE-INDEX fim_fat QUERY-TUNING(NO-LOOKAHEAD):
    ASSIGN dat-ult-nf = tt-indicador.dt_fim_fat
           hr-ult-nf  = tt-indicador.hr_fim_fat.
END.

ASSIGN i-minutos   = (i-tot-tempo / 5) / 60
       min-nf      = i-minutos / i-ped-faturado
       item-min    = i-tot-item / i-minutos
       i-tempo-fat = i-tot-tempo / 5.

IF i-tempo-fat < 0 
OR i-tempo-fat = ? THEN
   ASSIGN i-tempo-fat = 0.                          
IF min-nf = ? THEN 
   ASSIGN min-nf = 0.
IF item-min = ? THEN 
   ASSIGN item-min = 0.

DISP i-ped-integrado  @ tot-ped-integrado  FORMAT ">,>>>,>>9"
     i-ped-faturado   @ tot-ped-faturado   FORMAT ">,>>>,>>9"
     i-item-integrado @ tot-item-integrado FORMAT ">,>>>,>>9"
     i-item-faturado  @ tot-item-faturado  FORMAT ">,>>>,>>9"
     (i-item-integrado / i-ped-integrado) @ media-item-ped-int FORMAT ">>>,>>9.99"
     (i-item-faturado / i-ped-faturado)   @ media-item-ped-fat FORMAT ">>>,>>9.99"
     WITH FRAME {&FRAME-NAME}.

IF INPUT FRAME {&FRAME-NAME} media-item-ped-int = ? THEN DO:
   ASSIGN media-item-ped-int = 0.
   DISP media-item-ped-int WITH FRAME {&FRAME-NAME}.
END.

IF INPUT FRAME {&FRAME-NAME} media-item-ped-fat = ? THEN DO:
   ASSIGN media-item-ped-fat = 0.
   DISP media-item-ped-fat WITH FRAME {&FRAME-NAME}.
END.

run pi-finalizar in h-acomp.

session:SET-WAIT-STATE ("").

if can-find (first tt-int_ds_pedido) then do:
   OPEN QUERY brPed FOR EACH tt-int_ds_pedido USE-INDEX situacao NO-LOCK QUERY-TUNING(NO-LOOKAHEAD)
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-processa-pedidos wWindow 
PROCEDURE pi-processa-pedidos :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

for-ped:
for each int_ds_pedido no-lock where
         (int_ds_pedido.ped_tipopedido_n = 1 OR 
          int_ds_pedido.ped_tipopedido_n = 8 OR 
          int_ds_pedido.ped_tipopedido_n = 37) AND
         int_ds_pedido.ped_cnpj_origem_s = b-estabelec.cgc AND
         int_ds_pedido.dt_geracao        = d-dt-ini AND 
         int_ds_pedido.ped_codigo_n     >= i-pedido-ini AND 
         int_ds_pedido.ped_codigo_n     <= i-pedido-fim
    QUERY-TUNING(NO-LOOKAHEAD) on stop undo, leave:

    RUN pi-acompanhar IN h-acomp (INPUT "Pedido: " + string(int_ds_pedido.ped_codigo_n) + "  Gera‡Æo: " + string(int_ds_pedido.dt_geracao,"99/99/9999")).

    ASSIGN i-ped-pend     = 0   
           i-nf-ger       = 0
           i-nf-autor     = 0   
           c-rota         = ""
           c-estabel      = ""  
           c-nr-nf        = ""
           c-serie        = ""  
           c-transp       = ""
           c-placa        = "" 
           c-uf-placa     = ""
           da-dt-ger-nota = ?   
           c-hr-ger-nota  = ""  
           c-ndd-envio    = ""  
           c-nota-origem  = ""
           c-nota-destino = "".

    for first emitente no-lock where
              emitente.cgc = trim(int_ds_pedido.ped_cnpj_destino_s) QUERY-TUNING(NO-LOOKAHEAD): 
    END.
    if not avail emitente then 
       next for-ped.

    for each estabelec 
        fields (cod-estabel) 
        no-lock where
        estabelec.cgc = int_ds_pedido.ped_cnpj_destino_s,
        first cst_estabelec no-lock where 
        cst_estabelec.cod_estabel = estabelec.cod-estabel and
        cst_estabelec.dt_fim_operacao >= int_ds_pedido.ped_data_d
        QUERY-TUNING(NO-LOOKAHEAD):
        c-estabel = estabelec.cod-estabel.
        leave.
    end.
    if c-filial-ini > c-estabel
    or c-filial-fim < c-estabel then 
       next for-ped.

    FOR FIRST estabelec fields (cod-estabel estado) WHERE
              estabelec.cod-estabel = c-estabel NO-LOCK QUERY-TUNING(NO-LOOKAHEAD): 
    END.

/*     IF int_ds_pedido.situacao = 1 THEN DO:                                                                              */
/*        FOR FIRST nota-fiscal USE-INDEX ch-pedido WHERE                                                                  */
/*                  nota-fiscal.nome-ab-cli = emitente.nome-abrev AND                                                      */
/*                  nota-fiscal.nr-pedcli   = trim(string(int_ds_pedido.ped_codigo_n)) NO-LOCK QUERY-TUNING(NO-LOOKAHEAD): */
/*        END.                                                                                                             */
/*        IF AVAIL nota-fiscal THEN DO:                                                                                    */
/*           IF nota-fiscal.idi-sit-nf-eletro = 3 THEN DO:                                                                 */
/*              FOR FIRST b-int_ds_pedido WHERE                                                                            */
/*                        b-int_ds_pedido.ped_codigo_n = int_ds_pedido.ped_codigo_n QUERY-TUNING(NO-LOOKAHEAD):            */
/*              END.                                                                                                       */
/*              IF AVAIL b-int_ds_pedido THEN DO:                                                                          */
/*                 ASSIGN b-int_ds_pedido.situacao = 2.                                                                    */
/*                 RELEASE b-int_ds_pedido.                                                                                */
/*              END.                                                                                                       */
/*           END.                                                                                                          */
/*        END.                                                                                                             */
/*     END.                                                                                                                */
/* COMENTADO POR RICARDO CLAUSEN - 19/11/2018                                                                              */

    IF i-situacao = 1 
    OR i-situacao = 4 THEN DO:
       IF int_ds_pedido.situacao = 1 THEN DO:
          FOR FIRST loc-entr WHERE
                    loc-entr.nome-abrev = emitente.nome-abrev NO-LOCK QUERY-TUNING(NO-LOOKAHEAD): 
             if c-rota-ini > loc-entr.cod-rota  
             or c-rota-fim < loc-entr.cod-rota then 
                next for-ped.

             ASSIGN c-rota   = loc-entr.cod-rota
                    c-transp = loc-entr.nome-transp.

             IF AVAIL estabelec THEN DO:
                for-retorno:
                for each int_ds_pedido_retorno no-lock of int_ds_pedido QUERY-TUNING(NO-LOOKAHEAD):
                    FOR FIRST ITEM WHERE 
                              ITEM.it-codigo = STRING(int_ds_pedido_retorno.ppr_produto_n) NO-LOCK QUERY-TUNING(NO-LOOKAHEAD): 
                        if item.class-fiscal = "" or item.class-fiscal = "00000000" then do:
                            assign i-ped-pend    = 4
                                   i-nr-ped-erro = i-nr-ped-erro + 1.
                            leave for-retorno.
                        end.                       
                        for first item-uni-estab no-lock where 
                            item-uni-estab.it-codigo = trim(STRING(int_ds_pedido_retorno.ppr_produto_n)) and
                            item-uni-estab.cod-estabel = b-estabelec.cod-estabel QUERY-TUNING(NO-LOOKAHEAD):

                            if b-estabelec.estado = estabelec.estado and item-uni-estab.preco-base <= 0 then do:
                                assign i-ped-pend    = 4
                                       i-nr-ped-erro = i-nr-ped-erro + 1.
                                leave for-retorno.
                            end.
                            if b-estabelec.estado <> estabelec.estado and item-uni-estab.preco-ul-ent <= 0 then do:
                                assign i-ped-pend    = 4
                                       i-nr-ped-erro = i-nr-ped-erro + 1.
                                leave for-retorno.
                            end.
                        end.
                        if not avail item-uni-estab then do:
                            assign i-ped-pend    = 4
                                   i-nr-ped-erro = i-nr-ped-erro + 1.
                            leave for-retorno.
                        end.
                    end.
                    if not avail item then do:
                        assign i-ped-pend    = 4
                               i-nr-ped-erro = i-nr-ped-erro + 1.
                        leave for-retorno.
                    end.
                end.
             end.
             FIND FIRST int_ds_rota_veic WHERE
                        int_ds_rota_veic.cod_rota = loc-entr.cod-rota NO-LOCK NO-ERROR.
             IF AVAIL int_ds_rota_veic THEN DO:
                IF c-placa-ini > int_ds_rota_veic.placa
                OR c-placa-fim < int_ds_rota_veic.placa THEN NEXT.
                ASSIGN c-placa    = int_ds_rota_veic.placa
                       c-uf-placa = int_ds_rota_veic.uf_placa.  
             END.
             for first estab-rota-entreg WHERE   
                       estab-rota-entreg.cod-estabel = "973" AND
                       estab-rota-entreg.cod-rota    = loc-entr.cod-rota AND 
                       estab-rota-entreg.nome-abrev  = emitente.nome-abrev NO-LOCK QUERY-TUNING(NO-LOOKAHEAD):
                if c-serie-ini > estab-rota-entreg.cod-livre-2
                or c-serie-fim < estab-rota-entreg.cod-livre-2 then 
                   next for-ped.
                ASSIGN c-serie = estab-rota-entreg.cod-livre-2.
             END.
          END.
          if i-ped-pend <> 4 then do:
              FOR FIRST int_ds_log USE-INDEX orig_chave_sit_dt WHERE
                        int_ds_log.origem   = "NF PED" AND 
                        int_ds_log.chave    = trim(string(int_ds_pedido.ped_codigo_n)) AND
                        int_ds_log.situacao <> 2 NO-LOCK QUERY-TUNING(NO-LOOKAHEAD): 
                 ASSIGN i-ped-pend    = 4
                        i-nr-ped-erro = i-nr-ped-erro + 1.
              END.
              IF not AVAIL int_ds_log THEN DO:
                 ASSIGN i-ped-pend    = 1
                        i-nr-ped-pend = i-nr-ped-pend + 1.
              END.
          end.
       END.
    END.

    IF i-situacao <> 1 
    OR i-situacao  = 4 THEN DO:     
       IF i-situacao = 2 
       OR i-situacao = 4 THEN DO:
          ASSIGN i-sit-nfe = 0.
          FOR FIRST nota-fiscal USE-INDEX ch-pedido WHERE 
                    nota-fiscal.nome-ab-cli        = emitente.nome-abrev AND
                    nota-fiscal.nr-pedcli          = trim(string(int_ds_pedido.ped_codigo_n)) AND 
                    nota-fiscal.idi-sit-nf-eletro <> 3 AND 
                    nota-fiscal.idi-sit-nf-eletro <> 6 AND
                    nota-fiscal.idi-sit-nf-eletro <> 7 NO-LOCK QUERY-TUNING(NO-LOOKAHEAD): 
             if c-rota-ini > nota-fiscal.cod-rota  
             or c-rota-fim < nota-fiscal.cod-rota then 
                next for-ped.

             if c-placa-ini > nota-fiscal.placa
             or c-placa-fim < nota-fiscal.placa then 
                next for-ped.

             if c-serie-ini > nota-fiscal.serie
             or c-serie-fim < nota-fiscal.serie then 
                next for-ped.

             ASSIGN i-nf-ger       = 2                        
                    i-nr-nf-gerada = i-nr-nf-gerada + 1
                    c-rota         = nota-fiscal.cod-rota     
                    c-nr-nf        = nota-fiscal.nr-nota-fis
                    c-serie        = nota-fiscal.serie       
                    c-placa        = nota-fiscal.placa
                    c-uf-placa     = nota-fiscal.uf-placa     
                    da-dt-ger-nota = nota-fiscal.dt-emis-nota
                    c-hr-ger-nota  = nota-fiscal.hr-atualiza.

             FOR FIRST cst_monitor_fat WHERE 
                       cst_monitor_fat.cod_estabel = nota-fiscal.cod-estabel AND
                       cst_monitor_fat.serie       = nota-fiscal.serie       AND 
                       cst_monitor_fat.nr_nota_fis = nota-fiscal.nr-nota-fis NO-LOCK QUERY-TUNING(NO-LOOKAHEAD):
             END.
             IF AVAIL cst_monitor_fat THEN
                ASSIGN da-dt-ger-nota = cst_monitor_fat.dt_fim_fat
                       c-hr-ger-nota  = STRING(cst_monitor_fat.hr_fim_fat,"hh:mm:ss").

             FOR FIRST int_ndd_envio WHERE 
                       int_ndd_envio.cod_estabel = nota-fiscal.cod-estabel AND
                       int_ndd_envio.serie       = nota-fiscal.serie       AND
                       int_ndd_envio.nr_nota_fis = nota-fiscal.nr-nota-fis NO-LOCK QUERY-TUNING(NO-LOOKAHEAD): 
                IF int_ndd_envio.statusnumber = 0 THEN
                   ASSIGN c-ndd-envio = "Enviada".
                IF int_ndd_envio.statusnumber = 2 THEN
                   ASSIGN c-ndd-envio = "Processada".
             END.
             ASSIGN i-sit-nfe = nota-fiscal.idi-sit-nf-eletro.
             if i-sit-nfe = 0 then 
                assign i-sit-nfe = 99.

             FOR FIRST estabelec WHERE
                       estabelec.cod-estabel = nota-fiscal.cod-estabel NO-LOCK QUERY-TUNING(NO-LOOKAHEAD): 
                FOR FIRST int_ds_nota_saida WHERE 
                          int_ds_nota_saida.nsa_notafiscal_n  = int(nota-fiscal.nr-nota-fis) AND
                          int_ds_nota_saida.nsa_serie_s       = nota-fiscal.serie AND 
                          int_ds_nota_saida.nsa_cnpj_origem_s = estabelec.cgc NO-LOCK QUERY-TUNING(NO-LOOKAHEAD): 
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
       OR i-situacao = 4 THEN DO:
          ASSIGN i-sit-nfe = 0.
          FOR FIRST nota-fiscal USE-INDEX ch-pedido WHERE 
                    nota-fiscal.nome-ab-cli       = emitente.nome-abrev AND
                    nota-fiscal.nr-pedcli         = trim(string(int_ds_pedido.ped_codigo_n)) AND 
                    nota-fiscal.idi-sit-nf-eletro = 3 NO-LOCK QUERY-TUNING(NO-LOOKAHEAD): 
             if c-rota-ini > nota-fiscal.cod-rota  
             or c-rota-fim < nota-fiscal.cod-rota then 
                next for-ped.
             if c-placa-ini > nota-fiscal.placa
             or c-placa-fim < nota-fiscal.placa then 
                next for-ped.
             if c-serie-ini > nota-fiscal.serie
             or c-serie-fim < nota-fiscal.serie then 
                next for-ped.

             ASSIGN i-nf-autor      = 3                        
                    i-nr-nf-autoriz = i-nr-nf-autoriz + 1
                    c-rota          = nota-fiscal.cod-rota     
                    c-nr-nf         = nota-fiscal.nr-nota-fis
                    c-serie         = nota-fiscal.serie        
                    c-placa         = nota-fiscal.placa
                    c-uf-placa      = nota-fiscal.uf-placa     
                    da-dt-ger-nota  = nota-fiscal.dt-emis-nota
                    c-hr-ger-nota   = nota-fiscal.hr-atualiza.

             FOR FIRST cst_monitor_fat WHERE 
                       cst_monitor_fat.cod_estabel = nota-fiscal.cod-estabel AND
                       cst_monitor_fat.serie       = nota-fiscal.serie       AND 
                       cst_monitor_fat.nr_nota_fis = nota-fiscal.nr-nota-fis NO-LOCK QUERY-TUNING(NO-LOOKAHEAD):
             END.
             IF AVAIL cst_monitor_fat THEN
                ASSIGN da-dt-ger-nota = cst_monitor_fat.dt_fim_fat
                       c-hr-ger-nota  = STRING(cst_monitor_fat.hr_fim_fat,"hh:mm:ss").

             FOR FIRST int_ndd_envio WHERE 
                       int_ndd_envio.cod_estabel = nota-fiscal.cod-estabel AND
                       int_ndd_envio.serie       = nota-fiscal.serie       AND
                       int_ndd_envio.nr_nota_fis = nota-fiscal.nr-nota-fis NO-LOCK QUERY-TUNING(NO-LOOKAHEAD): 
                IF int_ndd_envio.statusnumber = 0 THEN
                   ASSIGN c-ndd-envio = "Enviada".
                IF int_ndd_envio.statusnumber = 2 THEN
                   ASSIGN c-ndd-envio = "Processada".
             END.

             ASSIGN i-sit-nfe = nota-fiscal.idi-sit-nf-eletro.
             IF i-sit-nfe = 0 THEN 
                ASSIGN i-sit-nfe = 99.

             FOR FIRST estabelec WHERE
                       estabelec.cod-estabel = nota-fiscal.cod-estabel NO-LOCK QUERY-TUNING(NO-LOOKAHEAD): 
                FOR FIRST int_ds_nota_saida WHERE 
                          int_ds_nota_saida.nsa_notafiscal_n  = int(nota-fiscal.nr-nota-fis) AND
                          int_ds_nota_saida.nsa_serie_s       = nota-fiscal.serie AND 
                          int_ds_nota_saida.nsa_cnpj_origem_s = estabelec.cgc NO-LOCK QUERY-TUNING(NO-LOOKAHEAD): 
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
    FOR EACH int_ds_pedido_retorno OF int_ds_pedido NO-LOCK QUERY-TUNING(NO-LOOKAHEAD):
        ASSIGN i-nr-itens = i-nr-itens + 1.
    END.       
    for first loc-entr where 
              loc-entr.nome-abrev = emitente.nome-abrev no-lock query-tuning(no-lookahead):
       assign c-transp = loc-entr.nome-transp.
    end.

    IF i-ped-pend <> 0
    OR i-nf-ger   <> 0 
    OR i-nf-autor <> 0 THEN DO:   

       if i-sit-nfe = 0 then 
          assign i-sit-nfe = 99.        

       create tt-int_ds_pedido.
       buffer-copy int_ds_pedido to tt-int_ds_pedido.
       ASSIGN tt-int_ds_pedido.qtde-itens   = i-nr-itens
              tt-int_ds_pedido.cod-rota     = c-rota
              tt-int_ds_pedido.cod-estabel  = c-estabel
              tt-int_ds_pedido.nr-nota-fis  = c-nr-nf
              tt-int_ds_pedido.serie        = c-serie
              tt-int_ds_pedido.placa        = c-placa
              tt-int_ds_pedido.uf-placa     = c-uf-placa
              tt-int_ds_pedido.transport    = c-transp
              tt-int_ds_pedido.dt-ger-ped   = int_ds_pedido.dt_geracao
              tt-int_ds_pedido.hr-ger-ped   = substr(int_ds_pedido.hr_geracao,1,5)
              tt-int_ds_pedido.dt-ger-nota  = da-dt-ger-nota
              tt-int_ds_pedido.hr-ger-nota  = c-hr-ger-nota
              tt-int_ds_pedido.ndd-envio    = c-ndd-envio
              tt-int_ds_pedido.nota-origem  = c-nota-origem
              tt-int_ds_pedido.nota-destino = c-nota-destino
              tt-int_ds_pedido.nome-ab-cli  = emitente.nome-abrev.

       IF i-sit-nfe = 99 THEN
          ASSIGN tt-int_ds_pedido.sit-nfe = "".
       ELSE
          ASSIGN tt-int_ds_pedido.sit-nfe = ENTRY(i-sit-nfe,c-sit-nfe).
       IF i-ped-pend = 1 THEN
          ASSIGN tt-int_ds_pedido.sit-ped = "Pedido Pendente"
                 tt-int_ds_pedido.ordem   = 4.
       IF i-nf-ger = 2 THEN
          ASSIGN tt-int_ds_pedido.sit-ped = "NF Gerada"
                 tt-int_ds_pedido.ordem   = 3.                
       IF i-nf-autor = 3 THEN
          ASSIGN tt-int_ds_pedido.sit-ped = "NF Autorizada"
                 tt-int_ds_pedido.ordem   = 2.
       IF i-ped-pend = 4 THEN
          ASSIGN tt-int_ds_pedido.sit-ped = "Pedido c/ Erro"
                 tt-int_ds_pedido.ordem   = 1.
    END.
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION fnRefresh wWindow 
FUNCTION fnRefresh returns logical ():
    IF rs-consulta:SCREEN-VALUE IN FRAME fPage0 = "2" THEN DO:
        chCtrlFrame:PSTimer:interval = 0.
        APPLY "LEAVE" TO c-intervalo IN FRAME fPage0.
    END.

    RETURN FALSE.   

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

