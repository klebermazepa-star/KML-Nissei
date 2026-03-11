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
** Programa: int080 - Tratamento Devolu‡Æo Fornecedor Loja
**
********************************************************************************/
{include/i-prgvrs.i INT080 2.00.00.000}

CREATE WIDGET-POOL.

/* Preprocessors Definitions ---                                      */
&GLOBAL-DEFINE Program        INT080
&GLOBAL-DEFINE Version        2.00.00.000

&GLOBAL-DEFINE WindowType     Master

&GLOBAL-DEFINE Folder         NO
&GLOBAL-DEFINE InitialPage    1
&GLOBAL-DEFINE FolderLabels   Pedidos

&GLOBAL-DEFINE page0Widgets   btQueryJoins btReportsJoins btExit btHelp ~
                              btOK btCancel btHelp2 btSelecao c-intervalo btAtualiza rs-consulta btAlterar
&GLOBAL-DEFINE page1Widgets   brPed

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */
DEFINE VAR c-filial-ini    AS CHAR FORMAT "x(5)"       NO-UNDO.
DEFINE VAR c-filial-fim    AS CHAR FORMAT "x(5)"       NO-UNDO.
DEFINE VAR i-pedido-ini    AS INT  FORMAT ">>>>>>>>9"  NO-UNDO.
DEFINE VAR i-pedido-fim    AS INT  FORMAT ">>>>>>>>9"  NO-UNDO.
DEFINE VAR d-dt-ini        AS DATE FORMAT "99/99/9999" NO-UNDO.
DEFINE VAR d-dt-fim        AS DATE FORMAT "99/99/9999" NO-UNDO.

def temp-table tt-raw-digita NO-UNDO field raw-digita  as raw.

define temp-table tt-param no-undo
    field destino          as integer
    field arquivo          as char format "x(35)"
    field usuario          as char format "x(12)"
    field data-exec        as date
    field hora-exec        as integer
    field classifica       as integer
    field desc-classifica  as char format "x(40)".

/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE tt-int-ds-pedido NO-UNDO LIKE int-ds-pedido
       field cod-emitente     LIKE emitente.cod-emitente
       FIELD cod-estabel      LIKE estabelec.cod-estabel
       FIELD nen-notafiscal-n LIKE int-ds-pedido-produto.nen-notafiscal-n    
       FIELD nen-serie-s      LIKE int-ds-pedido-produto.nen-serie-s
       index codigo ped-codigo-n.

def var raw-param as raw no-undo.

def var h-acomp as handle no-undo.

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
&Scoped-define FIELDS-IN-QUERY-brPed tt-int-ds-pedido.ped-codigo-n tt-int-ds-pedido.cod-estabel tt-int-ds-pedido.ped-data-d tt-int-ds-pedido.dt-geracao tt-int-ds-pedido.hr-geracao tt-int-ds-pedido.ped-dataentrega-d tt-int-ds-pedido.ped-cnpj-origem-s tt-int-ds-pedido.ped-cnpj-destino-s tt-int-ds-pedido.cod-emitente tt-int-ds-pedido.ped-quantidade-n tt-int-ds-pedido.ped-valortotalbruto-n tt-int-ds-pedido.ped-placaveiculo-s tt-int-ds-pedido.nen-notafiscal-n tt-int-ds-pedido.nen-serie-s   
&Scoped-define ENABLED-FIELDS-IN-QUERY-brPed   
&Scoped-define SELF-NAME brPed
&Scoped-define QUERY-STRING-brPed FOR EACH tt-int-ds-pedido NO-LOCK
&Scoped-define OPEN-QUERY-brPed OPEN QUERY {&SELF-NAME} FOR EACH tt-int-ds-pedido NO-LOCK.
&Scoped-define TABLES-IN-QUERY-brPed tt-int-ds-pedido
&Scoped-define FIRST-TABLE-IN-QUERY-brPed tt-int-ds-pedido


/* Definitions for FRAME fPage1                                         */
&Scoped-define OPEN-BROWSERS-IN-QUERY-fPage1 ~
    ~{&OPEN-QUERY-brPed}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS rtToolBar-2 RECT-consulta rtToolBar-3 ~
btQueryJoins btReportsJoins btExit btHelp btSelecao rs-consulta btAtualiza ~
btOK btCancel btAlterar btHelp2 
&Scoped-Define DISPLAYED-OBJECTS rs-consulta c-intervalo 

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
DEFINE BUTTON btAlterar 
     LABEL "Alterar" 
     SIZE 10 BY 1.

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

DEFINE BUTTON btHelp 
     IMAGE-UP FILE "image\im-hel":U
     IMAGE-INSENSITIVE FILE "image\ii-hel":U
     LABEL "Help" 
     SIZE 4 BY 1.25
     FONT 4.

DEFINE BUTTON btHelp2 
     LABEL "Ajuda" 
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

DEFINE VARIABLE c-intervalo AS INTEGER FORMAT ">,>>>,>>9":U INITIAL 60 
     VIEW-AS FILL-IN 
     SIZE 4 BY .79 NO-UNDO.

DEFINE VARIABLE rs-consulta AS INTEGER 
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS 
          "Manual", 1,
"Autom tico", 2
     SIZE 11.57 BY 1.5 NO-UNDO.

DEFINE RECTANGLE RECT-consulta
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 30.57 BY 2.58.

DEFINE RECTANGLE rtToolBar-2
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 141 BY 1.5
     BGCOLOR 7 .

DEFINE RECTANGLE rtToolBar-3
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 140.43 BY 1.5
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
      tt-int-ds-pedido.ped-codigo-n           COLUMN-LABEL "Nr. Pedido"
tt-int-ds-pedido.cod-estabel            COLUMN-LABEL "Estab."
tt-int-ds-pedido.ped-data-d             COLUMN-LABEL "Data Pedido"
tt-int-ds-pedido.dt-geracao             COLUMN-LABEL "Data Gera‡Æo"
tt-int-ds-pedido.hr-geracao             COLUMN-LABEL "Hora Gera‡Æo"
tt-int-ds-pedido.ped-dataentrega-d      COLUMN-LABEL "Data Entrega"
tt-int-ds-pedido.ped-cnpj-origem-s      COLUMN-LABEL "CNPJ Origem" FORMAT "X(20)"
tt-int-ds-pedido.ped-cnpj-destino-s     COLUMN-LABEL "CNPJ Destino" FORMAT "X(20)"
tt-int-ds-pedido.cod-emitente           COLUMN-LABEL "Fornecedor"
tt-int-ds-pedido.ped-quantidade-n       COLUMN-LABEL "Quantidade"                                             
tt-int-ds-pedido.ped-valortotalbruto-n  COLUMN-LABEL "Valor Bruto"
tt-int-ds-pedido.ped-placaveiculo-s     COLUMN-LABEL "Placa" FORMAT "X(10)"
tt-int-ds-pedido.nen-notafiscal-n       COLUMN-LABEL "Nota Fiscal"
tt-int-ds-pedido.nen-serie-s            COLUMN-LABEL "S‚rie"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS NO-COLUMN-SCROLLING SEPARATORS SIZE 140 BY 16.42
         FONT 1 NO-EMPTY-SPACE.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME fpage0
     btQueryJoins AT ROW 1.13 COL 125.57 HELP
          "Consultas relacionadas"
     btReportsJoins AT ROW 1.13 COL 129.57 HELP
          "Relat¢rios relacionados"
     btExit AT ROW 1.13 COL 133.57 HELP
          "Sair"
     btHelp AT ROW 1.13 COL 137.57 HELP
          "Ajuda"
     btSelecao AT ROW 1.17 COL 3.72 HELP
          "Relat¢rios relacionados" WIDGET-ID 2
     rs-consulta AT ROW 3.42 COL 3.86 NO-LABEL WIDGET-ID 10
     btAtualiza AT ROW 3.42 COL 26.72 HELP
          "Consultas relacionadas" WIDGET-ID 4
     c-intervalo AT ROW 3.67 COL 14.86 COLON-ALIGNED NO-LABEL WIDGET-ID 6
     btOK AT ROW 22.42 COL 3.57
     btCancel AT ROW 22.42 COL 14.57
     btAlterar AT ROW 22.42 COL 25.57 WIDGET-ID 30
     btHelp2 AT ROW 22.42 COL 131.14
     " Consulta" VIEW-AS TEXT
          SIZE 7.72 BY .54 AT ROW 2.54 COL 4.29 WIDGET-ID 14
     "seg" VIEW-AS TEXT
          SIZE 4.29 BY .54 AT ROW 3.75 COL 21.29 WIDGET-ID 16
     rtToolBar-2 AT ROW 1 COL 2.14
     RECT-consulta AT ROW 2.75 COL 2.43 WIDGET-ID 8
     rtToolBar-3 AT ROW 22.17 COL 2.14 WIDGET-ID 32
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 142.14 BY 23.08
         FONT 1 WIDGET-ID 100.

DEFINE FRAME fPage1
     brPed AT ROW 1 COL 1 WIDGET-ID 600
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 2.29 ROW 5.54
         SIZE 140.29 BY 16.5
         FONT 1 WIDGET-ID 100.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Window
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
IF SESSION:DISPLAY-TYPE = "GUI":U THEN
  CREATE WINDOW wWindow ASSIGN
         HIDDEN             = YES
         TITLE              = ""
         HEIGHT             = 22.83
         WIDTH              = 142.57
         MAX-HEIGHT         = 25.75
         MAX-WIDTH          = 195.14
         VIRTUAL-HEIGHT     = 25.75
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
OPEN QUERY {&SELF-NAME} FOR EACH tt-int-ds-pedido NO-LOCK.
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


&Scoped-define SELF-NAME btAlterar
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btAlterar wWindow
ON CHOOSE OF btAlterar IN FRAME fpage0 /* Alterar */
DO:  
  IF AVAIL tt-int-ds-pedido THEN DO:
     RUN intprg/int080b.w (INPUT tt-int-ds-pedido.ped-codigo-n,
                           INPUT tt-int-ds-pedido.cod-emitente,
                           INPUT tt-int-ds-pedido.ped-placaveiculo-s).
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

   RUN intprg/int080a.w (INPUT-OUTPUT c-filial-ini,
                         INPUT-OUTPUT c-filial-fim,
                         INPUT-OUTPUT i-pedido-ini,
                         INPUT-OUTPUT i-pedido-fim,
                         INPUT-OUTPUT d-dt-ini,    
                         INPUT-OUTPUT d-dt-fim,    
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


&Scoped-define BROWSE-NAME brPed
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
    ASSIGN c-filial-ini = ""
           c-filial-fim = "ZZZZZ"
           i-pedido-ini = 0
           i-pedido-fim = 999999999
           d-dt-ini     = TODAY
           d-dt-fim     = TODAY.

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

OCXFile = SEARCH( "int080.wrx":U ).
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
ELSE MESSAGE "int080.wrx":U SKIP(1)
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
DEF VAR c-estabel   AS CHAR NO-UNDO.

empty temp-table tt-int-ds-pedido.

run utp/ut-acomp.p persistent set h-acomp.
run pi-inicializar in h-acomp ("Devolu‡Æo Fornecedor Loja").

session:SET-WAIT-STATE ("GENERAL").

for each int-ds-pedido no-lock where
         int-ds-pedido.ped-tipopedido-n = 15 AND
         int-ds-pedido.situacao         = 1  AND 
         int-ds-pedido.ped-data-d       >= d-dt-ini AND 
         int-ds-pedido.ped-data-d       <= d-dt-fim AND 
         int-ds-pedido.ped-codigo-n     >= i-pedido-ini AND 
         int-ds-pedido.ped-codigo-n     <= i-pedido-fim
    QUERY-TUNING(NO-LOOKAHEAD) on stop undo, leave:

    RUN pi-acompanhar IN h-acomp (INPUT "Pedido: " + string(int-ds-pedido.ped-codigo-n) + " Data: " + string(int-ds-pedido.ped-data-d,"99/99/9999")).

    ASSIGN c-estabel = "".

    for first emitente no-lock where
              emitente.cgc = trim(int-ds-pedido.ped-cnpj-destino-s) QUERY-TUNING(NO-LOOKAHEAD):
    END.
    IF NOT AVAIL emitente THEN 
       NEXT.            

    for each estabelec 
        fields (cod-estabel) 
        no-lock where
        estabelec.cgc = int-ds-pedido.ped-cnpj-origem-s QUERY-TUNING(NO-LOOKAHEAD):
        ASSIGN c-estabel = estabelec.cod-estabel.
        leave.
    end.
    IF c-filial-ini > c-estabel
    OR c-filial-fim < c-estabel THEN
       NEXT.
       
    FOR FIRST int-ds-pedido-produto OF int-ds-pedido NO-LOCK QUERY-TUNING(NO-LOOKAHEAD):
    END.

    create tt-int-ds-pedido.
    ASSIGN tt-int-ds-pedido.dt-geracao            = int-ds-pedido.dt-geracao
           tt-int-ds-pedido.hr-geracao            = int-ds-pedido.hr-geracao
           tt-int-ds-pedido.ped-codigo-n          = int-ds-pedido.ped-codigo-n
           tt-int-ds-pedido.cod-estabel           = c-estabel
           tt-int-ds-pedido.ped-data-d            = int-ds-pedido.ped-data-d
           tt-int-ds-pedido.ped-dataentrega-d     = int-ds-pedido.ped-dataentrega-d   
           tt-int-ds-pedido.ped-cnpj-origem-s     = int-ds-pedido.ped-cnpj-origem-s
           tt-int-ds-pedido.ped-cnpj-destino-s    = int-ds-pedido.ped-cnpj-destino-s 
           tt-int-ds-pedido.cod-emitente          = emitente.cod-emitente
           tt-int-ds-pedido.ped-quantidade-n      = int-ds-pedido.ped-quantidade-n
           tt-int-ds-pedido.ped-valortotalbruto-n = int-ds-pedido.ped-valortotalbruto-n 
           tt-int-ds-pedido.ped-placaveiculo-s    = int-ds-pedido.ped-placaveiculo-s
           tt-int-ds-pedido.nen-notafiscal-n      = IF AVAIL int-ds-pedido-produto THEN int-ds-pedido-produto.nen-notafiscal-n ELSE 0
           tt-int-ds-pedido.nen-serie-s           = IF AVAIL int-ds-pedido-produto THEN int-ds-pedido-produto.nen-serie-s      ELSE "".

end.

run pi-finalizar in h-acomp.

session:SET-WAIT-STATE ("").

if can-find (first tt-int-ds-pedido) then do:
   OPEN QUERY brPed FOR EACH tt-int-ds-pedido USE-INDEX codigo NO-LOCK
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

