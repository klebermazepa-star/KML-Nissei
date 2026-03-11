&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
*/
&Scoped-define WINDOW-NAME wWindow

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DECLARATIONS wWindow 

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS wWindow 
/*
Author: Carlos Daniel de Almeida
Template Name: WWIN_MAINTENANCE_DBO
Template Library: CSTDDK
Template Version: 1.03
*/

CREATE WIDGET-POOL.

/* Template Definitions                                                     */
&SCOPED-DEFINE Program              CSPD0001
&SCOPED-DEFINE Version              1.00.00.000

&SCOPED-DEFINE WinFullScreen        NO
&SCOPED-DEFINE Folder               NO
&SCOPED-DEFINE InitialPage          1
&SCOPED-DEFINE FolderLabels         

&SCOPED-DEFINE WinParameterBtn      YES

&SCOPED-DEFINE WinQueryJoinsBtn     no
&SCOPED-DEFINE WinReportsJoinsBtn   no
&SCOPED-DEFINE WinExitBtn           YES
&SCOPED-DEFINE WinHelpBtn           YES

&SCOPED-DEFINE page0EnableWidgets   btRefresh brTable rs-cod-sit-ped rs-status-ped ~
                                    rs-ind-sit-nota btItens
&SCOPED-DEFINE page0KeyFields              
&SCOPED-DEFINE page0DisplayFields   


/**/

/* Datasul ERP Includes                                                     */
{include/i-prgvrs.i {&Program} {&Version}}

/* Template Includes                                                        */

/* ***************************  Definitions  ***************************    */
{cstddk/include/wWinDefinitions.i}
{cstp/cspd0001param.i} /* tt-param */

DEFINE TEMP-TABLE tt-pedido-venda LIKE ped-venda
    FIELD nome-emit    LIKE ems2mult.emitente.nome-emit
    FIELD cds-sit-ped  AS CHARACTER
    FIELD cds-sit-aval AS CHARACTER
    FIELD nr-nota-fis  LIKE nota-fiscal.nr-nota-fis
    FIELD ind-sit-nota LIKE nota-fiscal.ind-sit-nota
    FIELD cds-sit-nota AS CHARACTER
    FIELD dt-emis-nota LIKE nota-fiscal.dt-emis-nota
    FIELD qtd-volumes  AS DEC
    FIELD ped-portal   AS CHARACTER
    FIELD crm          LIKE ext-ped-venda.crm
    FIELD cdd-embarq   LIKE pre-fatur.cdd-embarq
    FIELD hora-pedido  AS CHAR
    FIELD log-alocado  AS LOGICAL
    FIELD log-faturado AS LOGICAL
    FIELD r-rowid      AS ROWID
    .

DEF NEW GLOBAL SHARED VAR gr-ped-venda AS ROWID NO-UNDO.

/* Parameters Definitions ---                                               */

/* Local Variable Definitions ---                                           */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Window
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME fPage0
&Scoped-define BROWSE-NAME brTable

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-pedido-venda tt-param

/* Definitions for BROWSE brTable                                       */
&Scoped-define FIELDS-IN-QUERY-brTable tt-pedido-venda.nr-pedido tt-pedido-venda.cod-estabel tt-pedido-venda.ped-portal tt-pedido-venda.cod-emitente tt-pedido-venda.nome-abrev tt-pedido-venda.cidade tt-pedido-venda.estado tt-pedido-venda.nome-emit tt-pedido-venda.qtd-volumes tt-pedido-venda.vl-tot-ped tt-pedido-venda.cod-cond-pag tt-pedido-venda.no-ab-reppri tt-pedido-venda.nome-transp tt-pedido-venda.cds-sit-ped tt-pedido-venda.dt-emissao tt-pedido-venda.hora-pedido tt-pedido-venda.dt-useralt tt-pedido-venda.cds-sit-aval tt-pedido-venda.dt-apr-cred tt-pedido-venda.crm tt-pedido-venda.cdd-embarq tt-pedido-venda.nr-nota-fis tt-pedido-venda.cds-sit-nota tt-pedido-venda.dt-emis-nota tt-pedido-venda.observacoes   
&Scoped-define ENABLED-FIELDS-IN-QUERY-brTable   
&Scoped-define SELF-NAME brTable
&Scoped-define QUERY-STRING-brTable FOR EACH tt-pedido-venda, ~
           FIRST tt-param     WHERE tt-pedido-venda.nr-nota-fis  >= tt-param.nr-nota-fis-ini     AND   tt-pedido-venda.nr-nota-fis  <= tt-param.nr-nota-fis-fim     AND   tt-pedido-venda.dt-emis-nota >= tt-param.dt-emis-nota-ini     AND   tt-pedido-venda.dt-emis-nota <= tt-param.dt-emis-nota-fim     AND   (IF tt-param.ind-sit-nota   <> 0 THEN tt-pedido-venda.ind-sit-nota   = tt-param.ind-sit-nota ELSE TRUE)     AND   (IF tt-param.ind-status-ped  = 1 THEN tt-pedido-venda.log-alocado  ELSE TRUE)     AND   (IF tt-param.ind-status-ped  = 2 THEN tt-pedido-venda.log-faturado ELSE TRUE)     INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-brTable OPEN QUERY {&SELF-NAME} FOR EACH tt-pedido-venda, ~
           FIRST tt-param     WHERE tt-pedido-venda.nr-nota-fis  >= tt-param.nr-nota-fis-ini     AND   tt-pedido-venda.nr-nota-fis  <= tt-param.nr-nota-fis-fim     AND   tt-pedido-venda.dt-emis-nota >= tt-param.dt-emis-nota-ini     AND   tt-pedido-venda.dt-emis-nota <= tt-param.dt-emis-nota-fim     AND   (IF tt-param.ind-sit-nota   <> 0 THEN tt-pedido-venda.ind-sit-nota   = tt-param.ind-sit-nota ELSE TRUE)     AND   (IF tt-param.ind-status-ped  = 1 THEN tt-pedido-venda.log-alocado  ELSE TRUE)     AND   (IF tt-param.ind-status-ped  = 2 THEN tt-pedido-venda.log-faturado ELSE TRUE)     INDEXED-REPOSITION .
&Scoped-define TABLES-IN-QUERY-brTable tt-pedido-venda tt-param
&Scoped-define FIRST-TABLE-IN-QUERY-brTable tt-pedido-venda
&Scoped-define SECOND-TABLE-IN-QUERY-brTable tt-param


/* Definitions for FRAME fPage0                                         */

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS rtToolBar RECT-1 RECT-2 RECT-3 btRefresh ~
btParam btItens btQueryJoins btReportsJoins btExit btHelp rs-cod-sit-ped ~
rs-ind-sit-nota rs-status-ped brTable 
&Scoped-Define DISPLAYED-OBJECTS rs-cod-sit-ped rs-ind-sit-nota ~
rs-status-ped 

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

DEFINE BUTTON btHelp 
     IMAGE-UP FILE "image\im-hel":U
     IMAGE-INSENSITIVE FILE "image\ii-hel":U
     LABEL "Help" 
     SIZE 4 BY 1.25 TOOLTIP "Ajuda"
     FONT 4.

DEFINE BUTTON btItens 
     IMAGE-UP FILE "adeicon/cscomb-u.bmp":U
     LABEL "Itens Pedido" 
     SIZE 4 BY 1.25.

DEFINE BUTTON btParam 
     IMAGE-UP FILE "image/im-param.bmp":U
     LABEL "Parƒmetros" 
     SIZE 4 BY 1.25 TOOLTIP "Parƒmetros"
     FONT 4.

DEFINE BUTTON btQueryJoins 
     IMAGE-UP FILE "image\im-joi":U
     IMAGE-INSENSITIVE FILE "image\ii-joi":U
     LABEL "Query Joins" 
     SIZE 4 BY 1.25 TOOLTIP "Consultas Relacionadas"
     FONT 4.

DEFINE BUTTON btRefresh 
     IMAGE-UP FILE "adeicon/reset-ai.bmp":U
     LABEL "Atualiza‡ao" 
     SIZE 4 BY 1.25 TOOLTIP "Parƒmetros"
     FONT 4.

DEFINE BUTTON btReportsJoins 
     IMAGE-UP FILE "image\im-pri":U
     IMAGE-INSENSITIVE FILE "image\ii-pri":U
     LABEL "Reports Joins" 
     SIZE 4 BY 1.25 TOOLTIP "Relat¢rios Relacionados"
     FONT 4.

DEFINE VARIABLE rs-cod-sit-ped AS INTEGER 
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS 
          "Todos os Pedidos", 0,
"Aberto", 1,
"Atendido Parcial", 2,
"Atendido Total", 3,
"Pendente", 4,
"Suspenso", 5,
"Cancelado", 6,
"Fatur BalcÆo", 7
     SIZE 16 BY 5 NO-UNDO.

DEFINE VARIABLE rs-ind-sit-nota AS INTEGER 
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS 
          "Todas as Notas", 0,
"Calculada", 1,
"Impressa", 2,
"Confirmada", 3,
"Cancelada", 4,
"Atual CR", 5,
"Atual OF", 6,
"Atual Estat", 7
     SIZE 16 BY 5 NO-UNDO.

DEFINE VARIABLE rs-status-ped AS INTEGER 
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS 
          "Todos os Pedidos", 0,
"Pedidos Alocados", 1,
"Pedidos j  Faturados", 2
     SIZE 18.29 BY 2.42 NO-UNDO.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 33 BY 5.75.

DEFINE RECTANGLE RECT-2
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 33 BY 5.75.

DEFINE RECTANGLE RECT-3
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 33 BY 5.75.

DEFINE RECTANGLE rtToolBar
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 180 BY 1.5
     BGCOLOR 7 .

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY brTable FOR 
      tt-pedido-venda, 
      tt-param SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE brTable
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS brTable wWindow _FREEFORM
  QUERY brTable DISPLAY
      tt-pedido-venda.nr-pedido
    tt-pedido-venda.cod-estabel
    tt-pedido-venda.ped-portal    COLUMN-LABEL "Pedido Portal"
    tt-pedido-venda.cod-emitente
    tt-pedido-venda.nome-abrev     WIDTH 16
    tt-pedido-venda.cidade 
    tt-pedido-venda.estado
    tt-pedido-venda.nome-emit
    tt-pedido-venda.qtd-volumes 
    tt-pedido-venda.vl-tot-ped
    tt-pedido-venda.cod-cond-pag
    tt-pedido-venda.no-ab-reppri
    tt-pedido-venda.nome-transp     COLUMN-LABEL "Transportadora"  FORMAT "X(20)"
    tt-pedido-venda.cds-sit-ped     COLUMN-LABEL "Situa‡Æo Pedido"  FORMAT "X(20)"
    tt-pedido-venda.dt-emissao
    tt-pedido-venda.hora-pedido     COLUMN-LABEL "Hr Pedido"
    tt-pedido-venda.dt-useralt      COLUMN-LABEL "Dt.Efetiva‡ao Pedido"
    tt-pedido-venda.cds-sit-aval    COLUMN-LABEL "Situa‡Æo Cr‚dito"
    tt-pedido-venda.dt-apr-cred
    tt-pedido-venda.crm
    tt-pedido-venda.cdd-embarq
    tt-pedido-venda.nr-nota-fis
    tt-pedido-venda.cds-sit-nota    COLUMN-LABEL "Situa‡Æo NF"      FORMAT "X(20)"
    tt-pedido-venda.dt-emis-nota
    tt-pedido-venda.observacoes
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 178 BY 18.75
         FONT 1 ROW-HEIGHT-CHARS .54.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME fPage0
     btRefresh AT ROW 1.13 COL 7.86 HELP
          "Parƒmetros" WIDGET-ID 14
     btParam AT ROW 1.13 COL 12.29 HELP
          "Parƒmetros" WIDGET-ID 12
     btItens AT ROW 1.13 COL 63 WIDGET-ID 60
     btQueryJoins AT ROW 1.13 COL 164.72 HELP
          "Consultas Relacionadas"
     btReportsJoins AT ROW 1.13 COL 168.72 HELP
          "Relat¢rios Relacionados"
     btExit AT ROW 1.13 COL 172.72 HELP
          "Sair"
     btHelp AT ROW 1.13 COL 176.72 HELP
          "Ajuda"
     rs-cod-sit-ped AT ROW 3.33 COL 36 NO-LABEL WIDGET-ID 16
     rs-ind-sit-nota AT ROW 3.33 COL 121.43 NO-LABEL WIDGET-ID 46
     rs-status-ped AT ROW 4.33 COL 78.72 NO-LABEL WIDGET-ID 32
     brTable AT ROW 10 COL 2 WIDGET-ID 300
     "Situa‡Æo Nota Fiscal" VIEW-AS TEXT
          SIZE 22.86 BY .54 AT ROW 2.5 COL 115.14 WIDGET-ID 56
          FGCOLOR 1 FONT 0
     "Status Pedido" VIEW-AS TEXT
          SIZE 16 BY .54 AT ROW 2.5 COL 72.29 WIDGET-ID 42
          FGCOLOR 1 FONT 0
     "Situa‡Æo Pedido" VIEW-AS TEXT
          SIZE 18 BY .54 AT ROW 2.5 COL 29.43 WIDGET-ID 26
          FGCOLOR 1 FONT 0
     rtToolBar AT ROW 1 COL 1
     RECT-1 AT ROW 2.75 COL 27 WIDGET-ID 28
     RECT-2 AT ROW 2.75 COL 69.72 WIDGET-ID 30
     RECT-3 AT ROW 2.75 COL 112.43 WIDGET-ID 44
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 180 BY 28.17
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
         HEIGHT             = 28.17
         WIDTH              = 180
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
/* SETTINGS FOR FRAME fPage0
   FRAME-NAME                                                           */
/* BROWSE-TAB brTable rs-status-ped fPage0 */
ASSIGN 
       brTable:ALLOW-COLUMN-SEARCHING IN FRAME fPage0 = TRUE
       brTable:COLUMN-RESIZABLE IN FRAME fPage0       = TRUE
       brTable:COLUMN-MOVABLE IN FRAME fPage0         = TRUE.

IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(wWindow)
THEN wWindow:HIDDEN = yes.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE brTable
/* Query rebuild information for BROWSE brTable
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH tt-pedido-venda,
    FIRST tt-param
    WHERE tt-pedido-venda.nr-nota-fis  >= tt-param.nr-nota-fis-ini
    AND   tt-pedido-venda.nr-nota-fis  <= tt-param.nr-nota-fis-fim
    AND   tt-pedido-venda.dt-emis-nota >= tt-param.dt-emis-nota-ini
    AND   tt-pedido-venda.dt-emis-nota <= tt-param.dt-emis-nota-fim
    AND   (IF tt-param.ind-sit-nota   <> 0 THEN tt-pedido-venda.ind-sit-nota   = tt-param.ind-sit-nota ELSE TRUE)
    AND   (IF tt-param.ind-status-ped  = 1 THEN tt-pedido-venda.log-alocado  ELSE TRUE)
    AND   (IF tt-param.ind-status-ped  = 2 THEN tt-pedido-venda.log-faturado ELSE TRUE)
    INDEXED-REPOSITION .
     _END_FREEFORM
     _Query            is NOT OPENED
*/  /* BROWSE brTable */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK FRAME fPage0
/* Query rebuild information for FRAME fPage0
     _Options          = "SHARE-LOCK KEEP-EMPTY"
     _Query            is NOT OPENED
*/  /* FRAME fPage0 */
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
ON CHOOSE OF btExit IN FRAME fPage0 /* Exit */
OR CHOOSE OF MENU-ITEM miExit IN MENU mbMain DO:
    APPLY "CLOSE":U TO THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btHelp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btHelp wWindow
ON CHOOSE OF btHelp IN FRAME fPage0 /* Help */
OR CHOOSE OF MENU-ITEM miContents IN MENU mbMain DO:
    {include/ajuda.i}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btItens
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btItens wWindow
ON CHOOSE OF btItens IN FRAME fPage0 /* Itens Pedido */
DO:
    ASSIGN gr-ped-venda = tt-pedido-venda.r-rowid.
    
    RUN pdp\pd1001a.w.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btParam
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btParam wWindow
ON CHOOSE OF btParam IN FRAME fPage0 /* Parƒmetros */
DO:
    RUN cstp/cspd0001a.w (INPUT-OUTPUT TABLE tt-param ). 
        .

    APPLY "CHOOSE" TO btRefresh.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btQueryJoins
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btQueryJoins wWindow
ON CHOOSE OF btQueryJoins IN FRAME fPage0 /* Query Joins */
OR CHOOSE OF MENU-ITEM miQueryJoins IN MENU mbMain DO:
    RUN showQueryJoins IN THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btRefresh
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btRefresh wWindow
ON CHOOSE OF btRefresh IN FRAME fPage0 /* Atualiza‡ao */
DO:
    RUN piBuscaPedido. 
        .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btReportsJoins
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btReportsJoins wWindow
ON CHOOSE OF btReportsJoins IN FRAME fPage0 /* Reports Joins */
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


&Scoped-define BROWSE-NAME brTable
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

    
/**/
RETURN "OK":U .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE piBuscaPedido wWindow 
PROCEDURE piBuscaPedido :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
DEFINE VARIABLE h-acomp AS HANDLE      NO-UNDO.

EMPTY TEMP-TABLE tt-pedido-venda.

FIND FIRST tt-param NO-ERROR.

IF NOT AVAIL tt-param THEN
    CREATE tt-param.

ASSIGN
    tt-param.cod-sit-ped    = INPUT FRAME fPage0 rs-cod-sit-ped
    tt-param.ind-status-ped = INPUT FRAME fPage0 rs-status-ped
    tt-param.ind-sit-nota   = INPUT FRAME fPage0 rs-ind-sit-nota
    .

RUN utp/ut-acomp.p PERSISTENT SET h-acomp.
RUN pi-inicializar IN h-acomp (INPUT "Buscando Pedidos...":U).

Pedidos:
FOR EACH ped-venda NO-LOCK
    WHERE ped-venda.nr-pedido    >= tt-param.nr-pedido-ini
    AND   ped-venda.nr-pedido    <= tt-param.nr-pedido-fim
    AND   ped-venda.nome-abrev   >= tt-param.nome-abrev-ini
    AND   ped-venda.nome-abrev   <= tt-param.nome-abrev-fim
    AND   ped-venda.no-ab-reppri >= tt-param.no-ab-reppri-ini
    AND   ped-venda.no-ab-reppri <= tt-param.no-ab-reppri-fim
    AND   ped-venda.cod-estabel  >= tt-param.cod-estabel-ini
    AND   ped-venda.cod-estabel  <= tt-param.cod-estabel-fim
    AND   ped-venda.dt-implant   >= tt-param.dt-implant-ini
    AND   ped-venda.dt-implant   <= tt-param.dt-implant-fim:

    RUN pi-acompanhar IN h-acomp (INPUT "Pedido: " + TRIM(STRING(ped-venda.nr-pedido))).

    IF tt-param.cod-sit-ped <> 0 THEN DO:
        IF tt-param.cod-sit-ped <> ped-venda.cod-sit-ped THEN
            NEXT.
    END.
    
    CREATE tt-pedido-venda.
    ASSIGN
        tt-pedido-venda.nr-pedido    = ped-venda.nr-pedido
        tt-pedido-venda.nome-abrev   = ped-venda.nome-abrev
        tt-pedido-venda.cod-emitente = ped-venda.cod-emitente
        tt-pedido-venda.nr-pedcli    = ped-venda.nr-pedcli
        tt-pedido-venda.cod-estabel  = ped-venda.cod-estabel
        tt-pedido-venda.no-ab-reppri = ped-venda.no-ab-reppri
        tt-pedido-venda.vl-tot-ped   = ped-venda.vl-tot-ped
        tt-pedido-venda.cod-cond-pag = ped-venda.cod-cond-pag
        tt-pedido-venda.cds-sit-ped  = {diinc/i03di149.i 04 ped-venda.cod-sit-ped}
        tt-pedido-venda.dt-emissao   = ped-venda.dt-emissao
        tt-pedido-venda.hora-pedido  = ped-venda.hra-atualiz
        tt-pedido-venda.cds-sit-aval = {diinc/i03di159.i 04 ped-venda.cod-sit-aval}
        tt-pedido-venda.dt-apr-cred  = ped-venda.dt-apr-cred
        tt-pedido-venda.observacoes  = ped-venda.observacoes
        tt-pedido-venda.r-rowid      = ROWID(ped-venda)
        .

    IF ped-venda.user-impl = "RPW" OR ped-venda.user-impl = "integramerco" THEN
        ASSIGN tt-pedido-venda.ped-portal = "SIM".
    ELSE 
        ASSIGN tt-pedido-venda.ped-portal = "NO".
    
    IF ped-venda.completo THEN
        ASSIGN tt-pedido-venda.dt-useralt = ped-venda.dt-useralt.
        
    FOR FIRST ems2mult.emitente NO-LOCK
        WHERE emitente.nome-abrev = ped-venda.nome-abrev:
        
        ASSIGN
            tt-pedido-venda.nome-emit = emitente.nome-emit
            .
            
        ASSIGN tt-pedido-venda.cidade = emitente.cidade
               tt-pedido-venda.estado = emitente.estado.            
    END.

   FOR EACH ext-ped-venda NO-LOCK
        WHERE ext-ped-venda.nr-pedido = ped-venda.nr-pedido:
        
        ASSIGN tt-pedido-venda.crm = ext-ped-venda.crm.
    END.

    
    ASSIGN tt-pedido-venda.qtd-volumes = 0.
    FOR EACH ped-item OF ped-venda NO-LOCK:
        ASSIGN tt-pedido-venda.qtd-volumes = tt-pedido-venda.qtd-volumes + ped-item.qt-pedida. 
    END.

    FOR FIRST pre-fatur FIELDS(cdd-embarq) NO-LOCK
        WHERE pre-fatur.nome-abrev = ped-venda.nome-abrev
        AND   pre-fatur.nr-pedcli  = ped-venda.nr-pedcli:

        ASSIGN
            tt-pedido-venda.cdd-embarq  = pre-fatur.cdd-embarq
            tt-pedido-venda.log-alocado = YES.
            
    END.
    
    FOR FIRST nota-fiscal FIELDS(nr-nota-fis ind-sit-nota dt-emis-nota) NO-LOCK
        WHERE nota-fiscal.nome-ab-cli   = ped-venda.nome-abrev
        AND   nota-fiscal.nr-pedcli     = ped-venda.nr-pedcli:
        
        ASSIGN
            tt-pedido-venda.nr-nota-fis  = nota-fiscal.nr-nota-fis
            tt-pedido-venda.cds-sit-nota = {diinc/i04di087.i 04 nota-fiscal.ind-sit-nota}
            tt-pedido-venda.dt-emis-nota = nota-fiscal.dt-emis-nota
            tt-pedido-venda.ind-sit-nota = nota-fiscal.ind-sit-nota
            tt-pedido-venda.log-faturado = YES
            .          
    END.
END.

RUN pi-finalizar IN h-acomp.

{&OPEN-QUERY-brTable}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

