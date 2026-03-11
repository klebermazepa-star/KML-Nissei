&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
          emsesp           ORACLE
*/
&Scoped-define WINDOW-NAME wWindow


/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE tt-int-ds-pedido NO-UNDO LIKE int-ds-pedido
       field cod-rota as char format "x(12)"
       field cod-estabel as char format "x(5)"
       field qtde-itens as int format ">>,>>9"
       field transport as char format "x(12)"
       field placa as char format "x(10)"
       field uf-placa as char format "x(4)"
       field serie as char format "x(5)"
       field nr-nota-fis as char format "x(16)"
       field sit-ped as char format "x(25)"
       field dt-ger-ped as date format "99/99/9999"
       field hr-ger-ped as char format "x(10)"
       field dt-ger-nota as date format "99/99/9999"
       field hr-ger-nota as char format "x(10)"
       field ordem       as int
       index situacao serie ordem dt-ger-ped hr-ger-ped ped-codigo-n.



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
** Programa: int050 - Gest∆o de Faturamento Transferàncias CD -> Filiais
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
                              btOK btCancel btHelp2 btSelecao c-intervalo btAtualiza rs-consulta btItens btFaturar
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
DEFINE VAR d-dt-fim        AS DATE FORMAT "99/99/9999" NO-UNDO.
DEFINE VAR i-situacao      AS INTEGER                  NO-UNDO.

def temp-table tt-raw-digita NO-UNDO field raw-digita  as raw.

DEFINE temp-table tt-param no-undo
    field destino          as integer
    field arquivo          as char format "x(35)"
    field usuario          as char format "x(12)"
    field data-exec        as date
    field hora-exec        as integer
    field classifica       as integer
    field desc-classifica  as char format "x(40)"
    field pedido           as INT
    FIELD serie            AS CHAR.

def var raw-param          as raw no-undo.

def var h-acomp as handle no-undo.

DEF BUFFER b-emitente FOR emitente.

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
&Scoped-define INTERNAL-TABLES tt-int-ds-pedido

/* Definitions for BROWSE brPed                                         */
&Scoped-define FIELDS-IN-QUERY-brPed tt-int-ds-pedido.cod-rota tt-int-ds-pedido.cod-estabel tt-int-ds-pedido.ped-codigo-n tt-int-ds-pedido.dt-ger-ped tt-int-ds-pedido.hr-ger-ped tt-int-ds-pedido.qtde-itens tt-int-ds-pedido.transport tt-int-ds-pedido.placa tt-int-ds-pedido.uf-placa tt-int-ds-pedido.serie tt-int-ds-pedido.nr-nota-fis tt-int-ds-pedido.dt-ger-nota tt-int-ds-pedido.hr-ger-nota tt-int-ds-pedido.sit-ped   
&Scoped-define ENABLED-FIELDS-IN-QUERY-brPed   
&Scoped-define SELF-NAME brPed
&Scoped-define QUERY-STRING-brPed FOR EACH tt-int-ds-pedido USE-INDEX situacao NO-LOCK
&Scoped-define OPEN-QUERY-brPed OPEN QUERY {&SELF-NAME} FOR EACH tt-int-ds-pedido USE-INDEX situacao NO-LOCK.
&Scoped-define TABLES-IN-QUERY-brPed tt-int-ds-pedido
&Scoped-define FIRST-TABLE-IN-QUERY-brPed tt-int-ds-pedido


/* Definitions for FRAME fPage1                                         */
&Scoped-define OPEN-BROWSERS-IN-QUERY-fPage1 ~
    ~{&OPEN-QUERY-brPed}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS rtToolBar-2 rtToolBar RECT-consulta ~
RECT-consulta-2 btQueryJoins btReportsJoins btExit btHelp btSelecao ~
rs-consulta btAtualiza btOK btCancel btItens btFaturar btHelp2 
&Scoped-Define DISPLAYED-OBJECTS i-nr-ped-pend i-nr-ped-fatur ~
i-nr-nf-autoriz rs-consulta c-intervalo i-nr-ped-erro i-nr-nf-gerada ~
i-tot-reg 

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
DEFINE BUTTON btAtualiza 
     IMAGE-UP FILE "image/im-relo.bmp":U
     IMAGE-INSENSITIVE FILE "image/ii-relo.bmp":U
     LABEL "Query Joins" 
     SIZE 4 BY 1.25
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

DEFINE BUTTON btFaturar 
     LABEL "Faturar Pedido" 
     SIZE 12 BY 1.

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

DEFINE VARIABLE i-nr-ped-erro AS INTEGER FORMAT ">,>>>,>>9":U INITIAL 0 
     LABEL "Nr. Pedidos com Erro" 
     VIEW-AS FILL-IN 
     SIZE 10 BY .88 NO-UNDO.

DEFINE VARIABLE i-nr-ped-fatur AS INTEGER FORMAT ">,>>>,>>9":U INITIAL 0 
     LABEL "Nr. Pedidos em Faturamento" 
     VIEW-AS FILL-IN 
     SIZE 10 BY .88 NO-UNDO.

DEFINE VARIABLE i-nr-ped-pend AS INTEGER FORMAT ">,>>>,>>9":U INITIAL 0 
     LABEL "Nr. Pedidos Pendentes" 
     VIEW-AS FILL-IN 
     SIZE 10 BY .88 NO-UNDO.

DEFINE VARIABLE i-tot-reg AS INTEGER FORMAT ">,>>>,>>9":U INITIAL 0 
     LABEL "Total de Registros" 
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
     SIZE 90.29 BY 2.58.

DEFINE RECTANGLE rtToolBar
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 134.29 BY 1.42
     BGCOLOR 7 .

DEFINE RECTANGLE rtToolBar-2
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 134.43 BY 1.5
     BGCOLOR 7 .

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY brPed FOR 
      tt-int-ds-pedido SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE brPed
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS brPed wWindow _FREEFORM
  QUERY brPed NO-LOCK DISPLAY
      tt-int-ds-pedido.cod-rota              COLUMN-LABEL "Rota" FORMAT "x(13)"
tt-int-ds-pedido.cod-estabel           COLUMN-LABEL "Filial" FORMAT "x(6)"
tt-int-ds-pedido.ped-codigo-n          COLUMN-LABEL "Pedido" 
tt-int-ds-pedido.dt-ger-ped            COLUMN-LABEL "Data Ger Ped"
tt-int-ds-pedido.hr-ger-ped            COLUMN-LABEL "Hora Ger Ped"
tt-int-ds-pedido.qtde-itens            COLUMN-LABEL " Nr. Itens" FORMAT ">>,>>9"
tt-int-ds-pedido.transport             COLUMN-LABEL "Transportador" FORMAT "x(12)"
tt-int-ds-pedido.placa                 COLUMN-LABEL "Placa" FORMAT "x(10)"                                                       
tt-int-ds-pedido.uf-placa              COLUMN-LABEL "UF Placa" FORMAT "x(4)"
tt-int-ds-pedido.serie                 COLUMN-LABEL "SÇrie" FORMAT "x(5)"
tt-int-ds-pedido.nr-nota-fis           COLUMN-LABEL "Nota Fiscal" FORMAT "x(16)"
tt-int-ds-pedido.dt-ger-nota           COLUMN-LABEL "Data Ger NF"
tt-int-ds-pedido.hr-ger-nota           COLUMN-LABEL "Hora Ger NF" 
tt-int-ds-pedido.sit-ped               COLUMN-LABEL "Situaá∆o" FORMAT "x(25)"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS NO-COLUMN-SCROLLING SEPARATORS SIZE 132 BY 16.42
         FONT 1 NO-EMPTY-SPACE.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME fpage0
     btQueryJoins AT ROW 1.13 COL 119.43 HELP
          "Consultas relacionadas"
     btReportsJoins AT ROW 1.13 COL 123.43 HELP
          "Relat¢rios relacionados"
     btExit AT ROW 1.13 COL 127.43 HELP
          "Sair"
     btHelp AT ROW 1.13 COL 131.43 HELP
          "Ajuda"
     btSelecao AT ROW 1.17 COL 2.57 HELP
          "Relat¢rios relacionados" WIDGET-ID 2
     i-nr-ped-pend AT ROW 3.13 COL 56.86 COLON-ALIGNED WIDGET-ID 20
     i-nr-ped-fatur AT ROW 3.13 COL 89.14 COLON-ALIGNED WIDGET-ID 36
     i-nr-nf-autoriz AT ROW 3.13 COL 116.72 COLON-ALIGNED WIDGET-ID 24
     rs-consulta AT ROW 3.42 COL 7.29 NO-LABEL WIDGET-ID 10
     btAtualiza AT ROW 3.42 COL 30.14 HELP
          "Consultas relacionadas" WIDGET-ID 4
     c-intervalo AT ROW 3.67 COL 18.29 COLON-ALIGNED NO-LABEL WIDGET-ID 6
     i-nr-ped-erro AT ROW 4.13 COL 56.86 COLON-ALIGNED WIDGET-ID 26
     i-nr-nf-gerada AT ROW 4.13 COL 89.14 COLON-ALIGNED WIDGET-ID 22
     i-tot-reg AT ROW 4.13 COL 116.72 COLON-ALIGNED WIDGET-ID 38
     btOK AT ROW 22.42 COL 2.86
     btCancel AT ROW 22.42 COL 13.86
     btItens AT ROW 22.42 COL 24.86 WIDGET-ID 30
     btFaturar AT ROW 22.42 COL 35.86 WIDGET-ID 32
     btHelp2 AT ROW 22.42 COL 124.57
     " Consulta" VIEW-AS TEXT
          SIZE 6.86 BY .54 AT ROW 2.54 COL 9 WIDGET-ID 14
     "seg" VIEW-AS TEXT
          SIZE 4.29 BY .54 AT ROW 3.75 COL 24.72 WIDGET-ID 16
     rtToolBar-2 AT ROW 1 COL 1.57
     rtToolBar AT ROW 22.21 COL 1.57
     RECT-consulta AT ROW 2.75 COL 5.72 WIDGET-ID 8
     RECT-consulta-2 AT ROW 2.75 COL 40.72 WIDGET-ID 28
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 135.14 BY 22.88
         FONT 1 WIDGET-ID 100.

DEFINE FRAME fPage1
     brPed AT ROW 1 COL 1 WIDGET-ID 600
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 2.29 ROW 5.54
         SIZE 132.57 BY 16.5
         FONT 1 WIDGET-ID 100.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Window
   Allow: Basic,Browse,DB-Fields,Window,Query
   Add Fields to: Neither
   Other Settings: COMPILE
   Temp-Tables and Buffers:
      TABLE: tt-int-ds-pedido T "?" NO-UNDO emsesp int-ds-pedido
      ADDITIONAL-FIELDS:
          field cod-rota as char format "x(12)"
          field cod-estabel as char format "x(5)"
          field qtde-itens as int format ">>,>>9"
          field transport as char format "x(12)"
          field placa as char format "x(10)"
          field uf-placa as char format "x(4)"
          field serie as char format "x(5)"
          field nr-nota-fis as char format "x(16)"
          field sit-ped as char format "x(25)"
          field dt-ger-ped as date format "99/99/9999"
          field hr-ger-ped as char format "x(10)"
          field dt-ger-nota as date format "99/99/9999"
          field hr-ger-nota as char format "x(10)"
          field ordem       as int
          index situacao serie ordem dt-ger-ped hr-ger-ped ped-codigo-n
      END-FIELDS.
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
IF SESSION:DISPLAY-TYPE = "GUI":U THEN
  CREATE WINDOW wWindow ASSIGN
         HIDDEN             = YES
         TITLE              = ""
         HEIGHT             = 22.71
         WIDTH              = 135.14
         MAX-HEIGHT         = 24.04
         MAX-WIDTH          = 135.14
         VIRTUAL-HEIGHT     = 24.04
         VIRTUAL-WIDTH      = 135.14
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
/* SETTINGS FOR FILL-IN i-nr-ped-erro IN FRAME fpage0
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN i-nr-ped-fatur IN FRAME fpage0
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN i-nr-ped-pend IN FRAME fpage0
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN i-tot-reg IN FRAME fpage0
   NO-ENABLE                                                            */
ASSIGN 
       rtToolBar:HIDDEN IN FRAME fpage0           = TRUE.

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
OPEN QUERY {&SELF-NAME} FOR EACH tt-int-ds-pedido USE-INDEX situacao NO-LOCK.
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
       COLUMN          = 112.57
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
ON ROW-DISPLAY OF brPed IN FRAME fPage1
DO: 
   IF tt-int-ds-pedido.sit-ped = "NF Gerada" THEN 
      assign tt-int-ds-pedido.cod-rota:bgcolor in browse brPed = 14
             tt-int-ds-pedido.cod-estabel:bgcolor in browse brPed = 14          
             tt-int-ds-pedido.ped-codigo-n:bgcolor in browse brPed = 14     
             tt-int-ds-pedido.dt-ger-ped:bgcolor in browse brPed = 14
             tt-int-ds-pedido.hr-ger-ped:bgcolor in browse brPed = 14
             tt-int-ds-pedido.qtde-itens:bgcolor in browse brPed = 14           
             tt-int-ds-pedido.transport:bgcolor in browse brPed = 14            
             tt-int-ds-pedido.placa:bgcolor in browse brPed = 14                
             tt-int-ds-pedido.uf-placa:bgcolor in browse brPed = 14             
             tt-int-ds-pedido.serie:bgcolor in browse brPed = 14                
             tt-int-ds-pedido.nr-nota-fis:bgcolor in browse brPed = 14      
             tt-int-ds-pedido.dt-ger-nota:bgcolor in browse brPed = 14
             tt-int-ds-pedido.hr-ger-nota:bgcolor in browse brPed = 14
             tt-int-ds-pedido.sit-ped:bgcolor in browse brPed = 14.              

   IF tt-int-ds-pedido.sit-ped = "NF Autorizada" THEN 
      assign tt-int-ds-pedido.cod-rota:bgcolor in browse brPed = 10
             tt-int-ds-pedido.cod-estabel:bgcolor in browse brPed = 10          
             tt-int-ds-pedido.ped-codigo-n:bgcolor in browse brPed = 10
             tt-int-ds-pedido.dt-ger-ped:bgcolor in browse brPed = 10
             tt-int-ds-pedido.hr-ger-ped:bgcolor in browse brPed = 10
             tt-int-ds-pedido.qtde-itens:bgcolor in browse brPed = 10           
             tt-int-ds-pedido.transport:bgcolor in browse brPed = 10            
             tt-int-ds-pedido.placa:bgcolor in browse brPed = 10                
             tt-int-ds-pedido.uf-placa:bgcolor in browse brPed = 10             
             tt-int-ds-pedido.serie:bgcolor in browse brPed = 10                
             tt-int-ds-pedido.nr-nota-fis:bgcolor in browse brPed = 10          
             tt-int-ds-pedido.dt-ger-nota:bgcolor in browse brPed = 10
             tt-int-ds-pedido.hr-ger-nota:bgcolor in browse brPed = 10
             tt-int-ds-pedido.sit-ped:bgcolor in browse brPed = 10.              

   IF tt-int-ds-pedido.sit-ped = "Pedido em Faturamento" THEN 
      assign tt-int-ds-pedido.cod-rota:bgcolor in browse brPed = 8
             tt-int-ds-pedido.cod-estabel:bgcolor in browse brPed = 8          
             tt-int-ds-pedido.ped-codigo-n:bgcolor in browse brPed = 8
             tt-int-ds-pedido.dt-ger-ped:bgcolor in browse brPed = 8
             tt-int-ds-pedido.hr-ger-ped:bgcolor in browse brPed = 8
             tt-int-ds-pedido.qtde-itens:bgcolor in browse brPed = 8           
             tt-int-ds-pedido.transport:bgcolor in browse brPed = 8            
             tt-int-ds-pedido.placa:bgcolor in browse brPed = 8                
             tt-int-ds-pedido.uf-placa:bgcolor in browse brPed = 8             
             tt-int-ds-pedido.serie:bgcolor in browse brPed = 8                
             tt-int-ds-pedido.nr-nota-fis:bgcolor in browse brPed = 8          
             tt-int-ds-pedido.dt-ger-nota:bgcolor in browse brPed = 8
             tt-int-ds-pedido.hr-ger-nota:bgcolor in browse brPed = 8
             tt-int-ds-pedido.sit-ped:bgcolor in browse brPed = 8.              

   IF tt-int-ds-pedido.sit-ped = "Lista Erro do INT030" THEN 
      assign tt-int-ds-pedido.cod-rota:bgcolor in browse brPed = 12
             tt-int-ds-pedido.cod-estabel:bgcolor in browse brPed = 12         
             tt-int-ds-pedido.ped-codigo-n:bgcolor in browse brPed = 12
             tt-int-ds-pedido.dt-ger-ped:bgcolor in browse brPed = 12
             tt-int-ds-pedido.hr-ger-ped:bgcolor in browse brPed = 12
             tt-int-ds-pedido.qtde-itens:bgcolor in browse brPed = 12          
             tt-int-ds-pedido.transport:bgcolor in browse brPed = 12           
             tt-int-ds-pedido.placa:bgcolor in browse brPed = 12               
             tt-int-ds-pedido.uf-placa:bgcolor in browse brPed = 12            
             tt-int-ds-pedido.serie:bgcolor in browse brPed = 12               
             tt-int-ds-pedido.nr-nota-fis:bgcolor in browse brPed = 12         
             tt-int-ds-pedido.dt-ger-nota:bgcolor in browse brPed = 12
             tt-int-ds-pedido.hr-ger-nota:bgcolor in browse brPed = 12
             tt-int-ds-pedido.sit-ped:bgcolor in browse brPed = 12.             
   
   IF tt-int-ds-pedido.sit-ped = "Pedido Pendente" THEN 
      assign tt-int-ds-pedido.cod-rota:bgcolor in browse brPed = 15
             tt-int-ds-pedido.cod-estabel:bgcolor in browse brPed = 15         
             tt-int-ds-pedido.ped-codigo-n:bgcolor in browse brPed = 15
             tt-int-ds-pedido.dt-ger-ped:bgcolor in browse brPed = 15
             tt-int-ds-pedido.hr-ger-ped:bgcolor in browse brPed = 15
             tt-int-ds-pedido.qtde-itens:bgcolor in browse brPed = 15          
             tt-int-ds-pedido.transport:bgcolor in browse brPed = 15           
             tt-int-ds-pedido.placa:bgcolor in browse brPed = 15               
             tt-int-ds-pedido.uf-placa:bgcolor in browse brPed = 15            
             tt-int-ds-pedido.serie:bgcolor in browse brPed = 15               
             tt-int-ds-pedido.nr-nota-fis:bgcolor in browse brPed = 15         
             tt-int-ds-pedido.dt-ger-nota:bgcolor in browse brPed = 15
             tt-int-ds-pedido.hr-ger-nota:bgcolor in browse brPed = 15
             tt-int-ds-pedido.sit-ped:bgcolor in browse brPed = 15.             
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME fpage0
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


&Scoped-define SELF-NAME btExit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btExit wWindow
ON CHOOSE OF btExit IN FRAME fpage0 /* Exit */
OR CHOOSE OF MENU-ITEM miExit IN MENU mbMain DO:
    APPLY "CLOSE":U TO THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btFaturar
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btFaturar wWindow
ON CHOOSE OF btFaturar IN FRAME fpage0 /* Faturar Pedido */
DO:  
  IF AVAIL tt-int-ds-pedido THEN DO:
     IF tt-int-ds-pedido.ordem = 5 THEN DO:
        run utp/ut-msgs.p("show",27100,substitute ("Deseja Faturar o Pedido &1 da SÇrie &2 ?~~Certifique-se que o programa int110-&2 n∆o est† sendo executado.", tt-int-ds-pedido.ped-codigo-n, tt-int-ds-pedido.serie)). 
        IF RETURN-VALUE = "YES" THEN DO:
           EMPTY TEMP-TABLE tt-param.
           create tt-param.
           assign tt-param.usuario   = c-seg-usuario
                  tt-param.destino   = 3
                  tt-param.arquivo   = ""
                  tt-param.data-exec = today
                  tt-param.hora-exec = time
                  tt-param.pedido    = tt-int-ds-pedido.ped-codigo-n
                  tt-param.serie     = tt-int-ds-pedido.serie.

           raw-transfer tt-param to raw-param.
           run intprg/int110rp.p (input raw-param, input table tt-raw-digita).
        END.
     END.
     ELSE DO:
         MESSAGE "Somente Pedidos Pendentes podem ser Faturados." 
                 VIEW-AS ALERT-BOX INFO BUTTONS OK.
     END.
  END.
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
  IF AVAIL tt-int-ds-pedido THEN DO:
     RUN intprg/int050b.w (INPUT tt-int-ds-pedido.ped-codigo-n).
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
                         INPUT-OUTPUT d-dt-fim,    
                         INPUT-OUTPUT i-situacao,  
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
           d-dt-fim     = TODAY
           i-situacao   = 1.


    assign i-nr-nf-gerada:bgcolor in frame {&FRAME-NAME}  = 14
           i-nr-ped-erro:bgcolor in frame {&FRAME-NAME}   = 12
           i-nr-nf-autoriz:bgcolor in frame {&FRAME-NAME} = 10
           i-nr-ped-pend:bgcolor in frame {&FRAME-NAME}   = 15
           i-nr-ped-fatur:bgcolor in frame {&FRAME-NAME}  = 8
           i-tot-reg:bgcolor in frame {&FRAME-NAME}       = 11.

    DISP i-nr-ped-pend
         i-nr-ped-fatur
         i-nr-ped-erro
         i-nr-nf-gerada
         i-nr-nf-autoriz 
         i-tot-reg WITH FRAME {&FRAME-NAME}.

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

OCXFile = SEARCH( "int050-new.wrx":U ).
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
ELSE MESSAGE "int050-new.wrx":U SKIP(1)
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

DEF VAR i-nr-itens  AS INT  NO-UNDO.
DEF VAR i-ped-pend  AS INT  NO-UNDO.
DEF VAR i-nf-ger    AS INT  NO-UNDO.
DEF VAR i-nf-autor  AS INT  NO-UNDO.
DEF VAR c-rota      AS CHAR NO-UNDO.
DEF VAR c-estabel   AS CHAR NO-UNDO.
DEF VAR c-nr-nf     AS CHAR NO-UNDO.
DEF VAR c-serie     AS CHAR NO-UNDO.
DEF VAR c-transp    AS CHAR NO-UNDO.
DEF VAR c-placa     AS CHAR NO-UNDO.
DEF VAR c-uf-placa  AS CHAR NO-UNDO.
DEF VAR da-dt-ger-nota AS DATE FORMAT "99/99/9999" NO-UNDO.
DEF VAR c-hr-ger-nota AS CHAR FORMAT "x(10)" NO-UNDO.

empty temp-table tt-int-ds-pedido.

ASSIGN i-nr-ped-pend   = 0
       i-nr-ped-erro   = 0
       i-nr-nf-gerada  = 0
       i-nr-nf-autoriz = 0
       i-nr-ped-fatur  = 0
       i-tot-reg       = 0.

run utp/ut-acomp.p persistent set h-acomp.
run pi-inicializar in h-acomp ("Faturamento Transf. CD -> Filiais").

session:SET-WAIT-STATE ("GENERAL").
for each int-ds-pedido no-lock where
         (int-ds-pedido.ped-tipopedido-n = 1 OR int-ds-pedido.ped-tipopedido-n = 8) AND
         int-ds-pedido.ped-cnpj-origem-s = "79430682025540" AND
         int-ds-pedido.dt-geracao       >= d-dt-ini AND 
         int-ds-pedido.dt-geracao       <= d-dt-fim AND 
         int-ds-pedido.ped-codigo-n     >= i-pedido-ini AND 
         int-ds-pedido.ped-codigo-n     <= i-pedido-fim QUERY-TUNING(NO-LOOKAHEAD) on stop undo, leave:

    RUN pi-acompanhar IN h-acomp (INPUT "Pedido: " + string(int-ds-pedido.ped-codigo-n) + "  Geraá∆o: " + string(int-ds-pedido.dt-geracao,"99/99/9999")).

    for first emitente no-lock where
              emitente.cgc = trim(int-ds-pedido.ped-cnpj-destino-s) QUERY-TUNING(NO-LOOKAHEAD):
    END.
    IF NOT AVAIL emitente THEN 
       NEXT.            

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
           c-hr-ger-nota  = "".

    IF i-situacao = 1 
    OR i-situacao = 4 THEN DO:
       IF int-ds-pedido.situacao = 1 
       OR int-ds-pedido.situacao = 9 THEN DO:
          FOR FIRST loc-entr WHERE
                    loc-entr.nome-abrev = emitente.nome-abrev NO-LOCK QUERY-TUNING(NO-LOOKAHEAD):
          END.
          IF AVAIL loc-entr THEN DO:
             IF c-rota-ini > loc-entr.cod-rota  
             OR c-rota-fim < loc-entr.cod-rota THEN
                NEXT.

             ASSIGN c-rota   = loc-entr.cod-rota
                    c-transp = loc-entr.nome-transp.

             FOR FIRST estabelec WHERE
                       estabelec.cod-emitente = emitente.cod-emitente NO-LOCK:
             END.
             IF AVAIL estabelec THEN DO:
                IF c-filial-ini > estabelec.cod-estabel
                OR c-filial-fim < estabelec.cod-estabel THEN
                   NEXT.
                ASSIGN c-estabel = estabelec.cod-estabel.
             END.

             FIND FIRST int-ds-rota-veic WHERE
                        int-ds-rota-veic.cod-rota = loc-entr.cod-rota NO-LOCK NO-ERROR.
             IF AVAIL int-ds-rota-veic THEN DO:
                IF c-placa-ini > int-ds-rota-veic.placa
                OR c-placa-fim < int-ds-rota-veic.placa THEN
                   NEXT.
                ASSIGN c-placa    = int-ds-rota-veic.placa
                       c-uf-placa = int-ds-rota-veic.uf-placa.  
             END.

             for first estab-rota-entreg WHERE   
                       estab-rota-entreg.nome-abrev  = emitente.nome-abrev  and
                       estab-rota-entreg.cod-rota    = loc-entr.cod-rota NO-LOCK QUERY-TUNING(NO-LOOKAHEAD):
             end.
             if AVAIL estab-rota-entreg THEN DO:
                IF c-serie-ini > estab-rota-entreg.cod-livre-2
                OR c-serie-fim < estab-rota-entreg.cod-livre-2 THEN
                   NEXT.
                ASSIGN c-serie = estab-rota-entreg.cod-livre-2.
             END.
          END.
          FOR FIRST int-ds-log USE-INDEX orig-chave-sit-dt WHERE
                    int-ds-log.origem   = "PED" AND 
                    int-ds-log.chave    = trim(string(int-ds-pedido.ped-codigo-n)) AND
                    int-ds-log.situacao = 1 NO-LOCK:
          END.
          IF AVAIL int-ds-log THEN DO:
             ASSIGN i-ped-pend    = 4
                    i-nr-ped-erro = i-nr-ped-erro + 1.
          END.
          ELSE DO:
             IF int-ds-pedido.situacao = 1 THEN
                ASSIGN i-ped-pend    = 1
                       i-nr-ped-pend = i-nr-ped-pend + 1.
             ELSE 
                ASSIGN i-ped-pend     = 5
                       i-nr-ped-fatur = i-nr-ped-fatur + 1.
          END.
       END.
    END.

    IF i-situacao <> 1 
    OR i-situacao  = 4 THEN DO:     

       IF i-situacao = 2 
       OR i-situacao = 4 THEN DO:
          FOR FIRST nota-fiscal USE-INDEX ch-pedido WHERE 
                    nota-fiscal.nome-ab-cli        = emitente.nome-abrev AND
                    nota-fiscal.nr-pedcli          = trim(string(int-ds-pedido.ped-codigo-n)) AND 
                    nota-fiscal.idi-sit-nf-eletro <> 3 AND 
                    nota-fiscal.idi-sit-nf-eletro <> 6 AND
                    nota-fiscal.idi-sit-nf-eletro <> 7 NO-LOCK QUERY-TUNING(NO-LOOKAHEAD):
          END.
          IF AVAIL nota-fiscal THEN DO:    
             IF c-rota-ini > nota-fiscal.cod-rota  
             OR c-rota-fim < nota-fiscal.cod-rota THEN
                NEXT.

             IF c-placa-ini > nota-fiscal.placa
             OR c-placa-fim < nota-fiscal.placa THEN
                NEXT.

             FOR FIRST b-emitente WHERE
                       b-emitente.nome-abrev = nota-fiscal.nome-ab-cli NO-LOCK:
             END.
             IF AVAIL b-emitente THEN DO:
                FOR FIRST estabelec WHERE
                          estabelec.cod-emitente = b-emitente.cod-emitente NO-LOCK:
                END.
                IF AVAIL estabelec THEN DO:
                   IF c-filial-ini > estabelec.cod-estabel
                   OR c-filial-fim < estabelec.cod-estabel THEN
                      NEXT.
                   ASSIGN c-estabel = estabelec.cod-estabel.
                END.
             END.

             IF c-serie-ini > nota-fiscal.serie
             OR c-serie-fim < nota-fiscal.serie THEN
                NEXT.

             ASSIGN i-nf-ger       = 2
                    i-nr-nf-gerada = i-nr-nf-gerada + 1
                    c-rota         = nota-fiscal.cod-rota
                    c-nr-nf        = nota-fiscal.nr-nota-fis
                    c-serie        = nota-fiscal.serie
                    c-placa        = nota-fiscal.placa
                    c-uf-placa     = nota-fiscal.uf-placa
                    da-dt-ger-nota = nota-fiscal.dt-emis-nota
                    c-hr-ger-nota  = nota-fiscal.hr-atualiza.
          END.
       END.

       IF i-situacao = 3 
       OR i-situacao = 4 THEN DO:
          FOR FIRST nota-fiscal USE-INDEX ch-pedido WHERE 
                    nota-fiscal.nome-ab-cli       = emitente.nome-abrev AND
                    nota-fiscal.nr-pedcli         = trim(string(int-ds-pedido.ped-codigo-n)) AND 
                    nota-fiscal.idi-sit-nf-eletro = 3 NO-LOCK QUERY-TUNING(NO-LOOKAHEAD):
          END.
          IF AVAIL nota-fiscal THEN DO: 
             IF c-rota-ini > nota-fiscal.cod-rota  
             OR c-rota-fim < nota-fiscal.cod-rota THEN
                NEXT.
             
             IF c-placa-ini > nota-fiscal.placa
             OR c-placa-fim < nota-fiscal.placa THEN
                NEXT.

             FOR FIRST b-emitente WHERE
                       b-emitente.nome-abrev = nota-fiscal.nome-ab-cli NO-LOCK:
             END.
             IF AVAIL b-emitente THEN DO:
                FOR FIRST estabelec WHERE
                          estabelec.cod-emitente = b-emitente.cod-emitente NO-LOCK:
                END.
                IF AVAIL estabelec THEN DO:
                   IF c-filial-ini > estabelec.cod-estabel
                   OR c-filial-fim < estabelec.cod-estabel THEN
                      NEXT.
                   ASSIGN c-estabel = estabelec.cod-estabel.
                END.
             END.

             IF c-serie-ini > nota-fiscal.serie
             OR c-serie-fim < nota-fiscal.serie THEN
                NEXT.

             ASSIGN i-nf-autor      = 3
                    i-nr-nf-autoriz = i-nr-nf-autoriz + 1
                    c-rota          = nota-fiscal.cod-rota
                    c-nr-nf         = nota-fiscal.nr-nota-fis
                    c-serie         = nota-fiscal.serie
                    c-placa         = nota-fiscal.placa
                    c-uf-placa      = nota-fiscal.uf-placa
                    da-dt-ger-nota  = nota-fiscal.dt-emis-nota
                    c-hr-ger-nota   = nota-fiscal.hr-atualiza.
          END.
       END.
    END.

    ASSIGN i-nr-itens = 0.
    FOR EACH int-ds-pedido-retorno OF int-ds-pedido NO-LOCK QUERY-TUNING(NO-LOOKAHEAD):
        ASSIGN i-nr-itens = i-nr-itens + 1.
    END.       

    FOR FIRST loc-entr WHERE
              loc-entr.nome-abrev = emitente.nome-abrev NO-LOCK QUERY-TUNING(NO-LOOKAHEAD):
    END.
    IF AVAIL loc-entr THEN
       ASSIGN c-transp = loc-entr.nome-transp.

    IF i-ped-pend  <> 0
    OR i-nf-ger    <> 0 
    OR i-nf-autor  <> 0 THEN DO:
       
       create tt-int-ds-pedido.
       buffer-copy int-ds-pedido to tt-int-ds-pedido.
       ASSIGN tt-int-ds-pedido.qtde-itens  = i-nr-itens
              tt-int-ds-pedido.cod-rota    = c-rota
              tt-int-ds-pedido.cod-estabel = c-estabel
              tt-int-ds-pedido.nr-nota-fis = c-nr-nf
              tt-int-ds-pedido.serie       = c-serie
              tt-int-ds-pedido.placa       = c-placa
              tt-int-ds-pedido.uf-placa    = c-uf-placa
              tt-int-ds-pedido.transport   = c-transp
              tt-int-ds-pedido.dt-ger-ped  = int-ds-pedido.dt-geracao
              tt-int-ds-pedido.hr-ger-ped  = substr(int-ds-pedido.hr-geracao,1,5)
              tt-int-ds-pedido.dt-ger-nota = da-dt-ger-nota
              tt-int-ds-pedido.hr-ger-nota = c-hr-ger-nota.

       IF i-ped-pend = 1 THEN
          ASSIGN tt-int-ds-pedido.sit-ped = "Pedido Pendente"
                 tt-int-ds-pedido.ordem   = 5.

       IF i-nf-ger = 2 THEN
          ASSIGN tt-int-ds-pedido.sit-ped = "NF Gerada"
                 tt-int-ds-pedido.ordem   = 3.
                 
       IF i-nf-autor = 3 THEN
          ASSIGN tt-int-ds-pedido.sit-ped = "NF Autorizada"
                 tt-int-ds-pedido.ordem   = 2.

       IF i-ped-pend = 4 THEN
          ASSIGN tt-int-ds-pedido.sit-ped = "Lista Erro do INT030"
                 tt-int-ds-pedido.ordem   = 1.

       IF i-ped-pend = 5 THEN 
          ASSIGN tt-int-ds-pedido.sit-ped = "Pedido em Faturamento"
                 tt-int-ds-pedido.ordem   = 4.
    END.
end.

ASSIGN i-tot-reg = i-nr-ped-pend + i-nr-ped-erro + i-nr-nf-gerada + i-nr-nf-autoriz + i-nr-ped-fatur.

DISP i-nr-ped-pend
     i-nr-ped-erro
     i-nr-nf-gerada
     i-nr-nf-autoriz
     i-nr-ped-fatur 
     i-tot-reg
     WITH FRAME {&FRAME-NAME}.

run pi-finalizar in h-acomp.

session:SET-WAIT-STATE ("").

if can-find (first tt-int-ds-pedido) then do:
   OPEN QUERY brPed FOR EACH tt-int-ds-pedido USE-INDEX situacao NO-LOCK
       max-rows 100000.
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

