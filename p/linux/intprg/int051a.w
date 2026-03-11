&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME wWindow
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS wWindow 
/********************************************************************************
** Copyright DATASUL S.A. (1997)
** Todos os Direitos Reservados.
**
** Este fonte e de propriedade exclusiva da DATASUL, sua reproducao
** parcial ou total por qualquer meio, so podera ser feita mediante
** autorizacao expressa.
*******************************************************************************/
{include/i-prgvrs.i INT051A 2.00.00.000}

/*:T*******************************************************************************
** Copyright DATASUL S.A. (1999)
** Todos os Direitos Reservados.
**
** Este fonte e de propriedade exclusiva da DATASUL, sua reproducao
** parcial ou total por qualquer meio, so podera ser feita mediante
** autorizacao expressa.
*******************************************************************************/

CREATE WIDGET-POOL.

/* Preprocessors Definitions ---                                      */
&GLOBAL-DEFINE Program        INT051A
&GLOBAL-DEFINE Version        2.00.00.000

&GLOBAL-DEFINE WindowType     Detail

&GLOBAL-DEFINE page0Widgets c-estab-orig-ini c-estab-orig-fim ~
                            c-emp-dest-ini c-emp-dest-fim ~
                            i-pedido-ini i-pedido-fim ~
                            d-dt-ped-ini d-dt-ped-fim ~
                            tg-balanco tg-dev-forn-loja ~
                            tg-estorno tg-retira-loja ~
                            tg-subst-cupom ~
                            tg-transf-loja-cd-loja rs-situacao tg-origem~
                            btHelp btOK btCancel 

/* Parameters Definitions ---                                           */
DEFINE INPUT-OUTPUT PARAM p-estab-orig-ini  AS CHAR NO-UNDO.
DEFINE INPUT-OUTPUT PARAM p-estab-orig-fim  AS CHAR NO-UNDO.
DEFINE INPUT-OUTPUT PARAM p-emp-dest-ini    AS CHAR NO-UNDO.
DEFINE INPUT-OUTPUT PARAM p-emp-dest-fim    AS CHAR NO-UNDO.                                                                     
DEFINE INPUT-OUTPUT PARAM p-pedido-ini      AS INT  NO-UNDO.
DEFINE INPUT-OUTPUT PARAM p-pedido-fim      AS INT  NO-UNDO.
DEFINE INPUT-OUTPUT PARAM p-dt-ped-ini      AS DATE NO-UNDO.
DEFINE INPUT-OUTPUT PARAM p-dt-ped-fim      AS DATE NO-UNDO.
DEFINE INPUT-OUTPUT PARAM p-balanco         AS LOG  NO-UNDO.
DEFINE INPUT-OUTPUT PARAM p-dev-forn-loja   AS LOG  NO-UNDO.
DEFINE INPUT-OUTPUT PARAM p-estorno         AS LOG  NO-UNDO.
DEFINE INPUT-OUTPUT PARAM p-retira-loja     AS LOG  NO-UNDO.
DEFINE INPUT-OUTPUT PARAM p-subst-cupom     AS LOG  NO-UNDO.
DEFINE INPUT-OUTPUT PARAM p-transf-loja-cd-loja  AS LOG  NO-UNDO.
DEFINE INPUT-OUTPUT PARAM p-situacao        AS INT  NO-UNDO.
DEFINE INPUT-OUTPUT PARAM p-origem          AS INT  NO-UNDO.
DEFINE       OUTPUT PARAM p-l-open-query    AS LOG  NO-UNDO.

/* Local Variable Definitions ---                                       */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Window
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME fpage0

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS tg-origem c-estab-orig-ini c-estab-orig-fim ~
c-emp-dest-ini c-emp-dest-fim i-pedido-ini i-pedido-fim d-dt-ped-ini ~
d-dt-ped-fim tg-balanco tg-dev-forn-loja tg-estorno tg-retira-loja ~
tg-subst-cupom tg-transf-loja-cd-loja rs-situacao btOK btCancel btHelp ~
IMAGE-5 IMAGE-6 rtToolBar RECT-1 IMAGE-9 IMAGE-12 IMAGE-15 IMAGE-16 ~
IMAGE-17 IMAGE-18 RECT-2 RECT-3 RECT-4 
&Scoped-Define DISPLAYED-OBJECTS tg-origem c-estab-orig-ini ~
c-estab-orig-fim c-emp-dest-ini c-emp-dest-fim i-pedido-ini i-pedido-fim ~
d-dt-ped-ini d-dt-ped-fim tg-balanco tg-dev-forn-loja tg-estorno ~
tg-retira-loja tg-subst-cupom tg-transf-loja-cd-loja rs-situacao 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR wWindow AS WIDGET-HANDLE NO-UNDO.

/* Definitions of the field level widgets                               */
DEFINE BUTTON btCancel 
     LABEL "&Cancelar" 
     SIZE 10 BY 1.

DEFINE BUTTON btHelp 
     LABEL "&Ajuda" 
     SIZE 10 BY 1.

DEFINE BUTTON btOK 
     LABEL "&OK" 
     SIZE 10 BY 1.

DEFINE VARIABLE c-emp-dest-fim AS CHARACTER FORMAT "X(12)" INITIAL "ZZZZZZZZZZZZ" 
     VIEW-AS FILL-IN 
     SIZE 13 BY .88.

DEFINE VARIABLE c-emp-dest-ini AS CHARACTER FORMAT "X(12)" 
     LABEL "Empresa Destino":R15 
     VIEW-AS FILL-IN 
     SIZE 13 BY .88.

DEFINE VARIABLE c-estab-orig-fim AS CHARACTER FORMAT "X(5)" INITIAL "ZZZZZ" 
     VIEW-AS FILL-IN 
     SIZE 6 BY .88.

DEFINE VARIABLE c-estab-orig-ini AS CHARACTER FORMAT "X(5)" 
     LABEL "Estab. Origem":R15 
     VIEW-AS FILL-IN 
     SIZE 6 BY .88.

DEFINE VARIABLE d-dt-ped-fim AS DATE FORMAT "99/99/9999" INITIAL 12/31/9999 
     VIEW-AS FILL-IN 
     SIZE 11 BY .88.

DEFINE VARIABLE d-dt-ped-ini AS DATE FORMAT "99/99/9999" INITIAL 01/01/00 
     LABEL "Data Pedido":R15 
     VIEW-AS FILL-IN 
     SIZE 11 BY .88.

DEFINE VARIABLE i-pedido-fim AS INTEGER FORMAT ">>>>>>>>9":U INITIAL 999999999 
     VIEW-AS FILL-IN 
     SIZE 8.86 BY .88 NO-UNDO.

DEFINE VARIABLE i-pedido-ini AS INTEGER FORMAT ">>>>>>>>9":U INITIAL 0 
     LABEL "Pedido" 
     VIEW-AS FILL-IN 
     SIZE 8.86 BY .88 NO-UNDO.

DEFINE IMAGE IMAGE-12
     FILENAME "image\im-las":U
     SIZE 3 BY .88.

DEFINE IMAGE IMAGE-15
     FILENAME "image\im-fir":U
     SIZE 3 BY .88.

DEFINE IMAGE IMAGE-16
     FILENAME "image\im-las":U
     SIZE 3 BY .88.

DEFINE IMAGE IMAGE-17
     FILENAME "image\im-fir":U
     SIZE 3 BY .88.

DEFINE IMAGE IMAGE-18
     FILENAME "image\im-las":U
     SIZE 3 BY .88.

DEFINE IMAGE IMAGE-5
     FILENAME "image\im-fir":U
     SIZE 3 BY .88.

DEFINE IMAGE IMAGE-6
     FILENAME "image\im-las":U
     SIZE 3 BY .88.

DEFINE IMAGE IMAGE-9
     FILENAME "image\im-fir":U
     SIZE 3 BY .88.

DEFINE VARIABLE rs-situacao AS INTEGER INITIAL 5 
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS 
          "Pedido Pendente", 1,
"Pedido Cancelado", 4,
"NF Gerada", 2,
"NF Autorizada", 3,
"Todos", 5
     SIZE 16.14 BY 5 NO-UNDO.

DEFINE VARIABLE tg-origem AS INTEGER INITIAL 3 
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS 
          "Oblak", 1,
"Procfit", 2,
"Ambos", 3
     SIZE 23.86 BY .79 NO-UNDO.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 53.86 BY 4.71.

DEFINE RECTANGLE RECT-2
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 26.43 BY 7.83.

DEFINE RECTANGLE RECT-3
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 26.43 BY 5.79.

DEFINE RECTANGLE RECT-4
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 26.43 BY 1.5.

DEFINE RECTANGLE rtToolBar
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 54 BY 1.42
     BGCOLOR 7 .

DEFINE VARIABLE tg-balanco AS LOGICAL INITIAL no 
     LABEL "Balan‡o" 
     VIEW-AS TOGGLE-BOX
     SIZE 9 BY .88 NO-UNDO.

DEFINE VARIABLE tg-dev-forn-loja AS LOGICAL INITIAL no 
     LABEL "Devolu‡Æo Fornecedor - Loja" 
     VIEW-AS TOGGLE-BOX
     SIZE 23 BY .88 NO-UNDO.

DEFINE VARIABLE tg-estorno AS LOGICAL INITIAL no 
     LABEL "Estorno" 
     VIEW-AS TOGGLE-BOX
     SIZE 9 BY .88 NO-UNDO.

DEFINE VARIABLE tg-retira-loja AS LOGICAL INITIAL no 
     LABEL "Retirada de Loja" 
     VIEW-AS TOGGLE-BOX
     SIZE 15 BY .88 NO-UNDO.

DEFINE VARIABLE tg-subst-cupom AS LOGICAL INITIAL no 
     LABEL "Substitui‡Æo de Cupom" 
     VIEW-AS TOGGLE-BOX
     SIZE 19 BY .88 NO-UNDO.

DEFINE VARIABLE tg-transf-loja-cd-loja AS LOGICAL INITIAL no 
     LABEL "Transferˆncia Loja -> CD/Loja" 
     VIEW-AS TOGGLE-BOX
     SIZE 23.72 BY .88 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME fpage0
     tg-origem AT ROW 12.96 COL 30.14 NO-LABEL WIDGET-ID 102
     c-estab-orig-ini AT ROW 1.5 COL 13.57 COLON-ALIGNED
     c-estab-orig-fim AT ROW 1.5 COL 37.72 COLON-ALIGNED NO-LABEL WIDGET-ID 36
     c-emp-dest-ini AT ROW 2.5 COL 13.57 COLON-ALIGNED WIDGET-ID 64
     c-emp-dest-fim AT ROW 2.5 COL 37.72 COLON-ALIGNED NO-LABEL WIDGET-ID 66
     i-pedido-ini AT ROW 3.5 COL 13.57 COLON-ALIGNED WIDGET-ID 52
     i-pedido-fim AT ROW 3.5 COL 37.72 COLON-ALIGNED NO-LABEL WIDGET-ID 54
     d-dt-ped-ini AT ROW 4.5 COL 13.57 COLON-ALIGNED WIDGET-ID 24
     d-dt-ped-fim AT ROW 4.5 COL 37.72 COLON-ALIGNED NO-LABEL WIDGET-ID 38
     tg-balanco AT ROW 7.13 COL 3.14 WIDGET-ID 76
     tg-dev-forn-loja AT ROW 8.13 COL 3.14 WIDGET-ID 78
     tg-estorno AT ROW 9.13 COL 3.14 WIDGET-ID 80
     tg-retira-loja AT ROW 10.13 COL 3.14 WIDGET-ID 82
     tg-subst-cupom AT ROW 11.13 COL 3.14 WIDGET-ID 84
     tg-transf-loja-cd-loja AT ROW 12.13 COL 3.14 WIDGET-ID 90
     rs-situacao AT ROW 6.75 COL 31.57 NO-LABEL WIDGET-ID 8
     btOK AT ROW 14.46 COL 1.86
     btCancel AT ROW 14.46 COL 12.86
     btHelp AT ROW 14.46 COL 43.86
     "  Situa‡Æo" VIEW-AS TEXT
          SIZE 7.86 BY .71 AT ROW 5.83 COL 29.86 WIDGET-ID 14
     "  Modalidades" VIEW-AS TEXT
          SIZE 10.43 BY .71 AT ROW 5.83 COL 2.43 WIDGET-ID 94
     "  Origem Pedido" VIEW-AS TEXT
          SIZE 11.57 BY .71 AT ROW 12.17 COL 29.86 WIDGET-ID 100
     IMAGE-5 AT ROW 1.5 COL 29.14
     IMAGE-6 AT ROW 1.5 COL 36.43
     rtToolBar AT ROW 14.21 COL 1
     RECT-1 AT ROW 1.04 COL 1.14 WIDGET-ID 30
     IMAGE-9 AT ROW 3.5 COL 29.14 WIDGET-ID 40
     IMAGE-12 AT ROW 3.5 COL 36.43 WIDGET-ID 46
     IMAGE-15 AT ROW 2.5 COL 29.14 WIDGET-ID 68
     IMAGE-16 AT ROW 2.5 COL 36.43 WIDGET-ID 70
     IMAGE-17 AT ROW 4.5 COL 29.14 WIDGET-ID 72
     IMAGE-18 AT ROW 4.5 COL 36.43 WIDGET-ID 74
     RECT-2 AT ROW 6.21 COL 1.14 WIDGET-ID 92
     RECT-3 AT ROW 6.21 COL 28.57 WIDGET-ID 96
     RECT-4 AT ROW 12.54 COL 28.57 WIDGET-ID 98
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 54.72 BY 14.67
         FONT 1
         DEFAULT-BUTTON btOK.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Window
   Other Settings: COMPILE
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
IF SESSION:DISPLAY-TYPE = "GUI":U THEN
  CREATE WINDOW wWindow ASSIGN
         HIDDEN             = YES
         TITLE              = ""
         HEIGHT             = 14.75
         WIDTH              = 54.29
         MAX-HEIGHT         = 20.75
         MAX-WIDTH          = 128.29
         VIRTUAL-HEIGHT     = 20.75
         VIRTUAL-WIDTH      = 128.29
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
/* SETTINGS FOR FRAME fpage0
   FRAME-NAME Custom                                                    */
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


&Scoped-define SELF-NAME btCancel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btCancel wWindow
ON CHOOSE OF btCancel IN FRAME fpage0 /* Cancelar */
DO:
    ASSIGN p-l-open-query = NO.

    APPLY "CLOSE":U TO THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btHelp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btHelp wWindow
ON CHOOSE OF btHelp IN FRAME fpage0 /* Ajuda */
DO:
    {include/ajuda.i}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btOK
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btOK wWindow
ON CHOOSE OF btOK IN FRAME fpage0 /* OK */
DO:
    assign frame fPage0 c-estab-orig-ini 
                        c-estab-orig-fim
                        c-emp-dest-ini 
                        c-emp-dest-fim
                        i-pedido-ini 
                        i-pedido-fim
                        d-dt-ped-ini 
                        d-dt-ped-fim
                        tg-balanco 
                        tg-dev-forn-loja
                        tg-estorno 
                        tg-retira-loja
                        tg-subst-cupom 
                        tg-transf-loja-cd-loja
                        rs-situacao
                        tg-origem.

    assign p-estab-orig-ini  = c-estab-orig-ini 
           p-estab-orig-fim  = c-estab-orig-fim 
           p-emp-dest-ini    = c-emp-dest-ini   
           p-emp-dest-fim    = c-emp-dest-fim   
           p-pedido-ini      = i-pedido-ini     
           p-pedido-fim      = i-pedido-fim     
           p-dt-ped-ini      = d-dt-ped-ini     
           p-dt-ped-fim      = d-dt-ped-fim     
           p-balanco         = tg-balanco       
           p-dev-forn-loja   = tg-dev-forn-loja 
           p-estorno         = tg-estorno       
           p-retira-loja     = tg-retira-loja   
           p-subst-cupom     = tg-subst-cupom   
           p-transf-loja-cd-loja = tg-transf-loja-cd-loja
           p-situacao        = rs-situacao
           p-origem          = tg-origem.

    assign p-l-open-query = yes.

    APPLY "CLOSE":U TO THIS-PROCEDURE.  
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME d-dt-ped-ini
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL d-dt-ped-ini wWindow
ON LEAVE OF d-dt-ped-ini IN FRAME fpage0 /* Data Pedido */
DO:
  ASSIGN d-dt-ped-fim = INPUT FRAME fpage0 d-dt-ped-ini.
  DISPLAY d-dt-ped-fim WITH FRAME fpage0.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK wWindow 


/*:T--- L¢gica para inicializa‡Æo do programam ---*/
{window/mainblock.i}

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
   
   ASSIGN c-estab-orig-ini:screen-value in frame fPage0 = p-estab-orig-ini 
          c-estab-orig-fim:screen-value in frame fPage0 = p-estab-orig-fim 
          c-emp-dest-ini:screen-value in frame fPage0 = p-emp-dest-ini 
          c-emp-dest-fim:screen-value in frame fPage0 = p-emp-dest-fim  
          i-pedido-ini:screen-value in frame fPage0 = string(p-pedido-ini)    
          i-pedido-fim:screen-value in frame fPage0 = string(p-pedido-fim)   
          d-dt-ped-ini:screen-value in frame fPage0 = string(p-dt-ped-ini,"99/99/9999")   
          d-dt-ped-fim:screen-value in frame fPage0 = string(p-dt-ped-fim,"99/99/9999")   
          tg-balanco:screen-value in frame fPage0 = string(p-balanco)     
          tg-dev-forn-loja:screen-value in frame fPage0 = string(p-dev-forn-loja)
          tg-estorno:screen-value in frame fPage0 = string(p-estorno)    
          tg-retira-loja:screen-value in frame fPage0 = string(p-retira-loja)
          tg-subst-cupom:screen-value in frame fPage0 = string(p-subst-cupom) 
          tg-transf-loja-cd-loja:screen-value in frame fPage0 = string(p-transf-loja-cd-loja)
          rs-situacao:screen-value in frame fPage0 = string(p-situacao)
          tg-origem:screen-value in frame fPage0 = string(p-origem).
    RETURN "OK":U.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

