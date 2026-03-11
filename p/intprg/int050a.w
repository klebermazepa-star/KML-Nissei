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
{include/i-prgvrs.i INT050A 2.00.00.000}

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
&GLOBAL-DEFINE Program        INT050A
&GLOBAL-DEFINE Version        2.00.00.000

&GLOBAL-DEFINE WindowType     Detail

&GLOBAL-DEFINE page0Widgets   c-rota-ini c-rota-fim ~
                              c-filial-ini c-filial-fim ~
                              c-placa-ini c-placa-fim ~
                              i-pedido-ini i-pedido-fim ~
                              c-serie-ini c-serie-fim ~
                              d-dt-ini ~
                              rs-situacao ~
                              btHelp btOK btCancel 

/* Parameters Definitions ---                                           */
DEFINE INPUT-OUTPUT PARAM p-rota-ini      AS CHAR FORMAT "x(12)"      NO-UNDO.
DEFINE INPUT-OUTPUT PARAM p-rota-fim      AS CHAR FORMAT "x(12)"      NO-UNDO.
DEFINE INPUT-OUTPUT PARAM p-filial-ini    AS CHAR FORMAT "x(5)"       NO-UNDO.
DEFINE INPUT-OUTPUT PARAM p-filial-fim    AS CHAR FORMAT "x(5)"       NO-UNDO.                                                                     
DEFINE INPUT-OUTPUT PARAM p-placa-ini     AS CHAR FORMAT "x(10)"      NO-UNDO.
DEFINE INPUT-OUTPUT PARAM p-placa-fim     AS CHAR FORMAT "x(10)"      NO-UNDO.
DEFINE INPUT-OUTPUT PARAM p-pedido-ini    AS INT  FORMAT ">>>>>>>>9"  NO-UNDO.
DEFINE INPUT-OUTPUT PARAM p-pedido-fim    AS INT  FORMAT ">>>>>>>>9"  NO-UNDO.
DEFINE INPUT-OUTPUT PARAM p-serie-ini     AS CHAR FORMAT "x(5)"       NO-UNDO.
DEFINE INPUT-OUTPUT PARAM p-serie-fim     AS CHAR FORMAT "x(5)"       NO-UNDO.                                                                     
DEFINE INPUT-OUTPUT PARAM p-dt-ini        AS DATE FORMAT "99/99/9999" NO-UNDO.
DEFINE INPUT-OUTPUT PARAM p-situacao      AS INTEGER                  NO-UNDO.
DEFINE       OUTPUT PARAM p-l-open-query  AS LOGICAL                  NO-UNDO.

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
&Scoped-Define ENABLED-OBJECTS c-rota-ini c-rota-fim c-filial-ini ~
c-filial-fim c-placa-ini c-placa-fim i-pedido-ini i-pedido-fim c-serie-ini ~
c-serie-fim d-dt-ini rs-situacao btOK btCancel btHelp IMAGE-1 IMAGE-2 ~
IMAGE-5 IMAGE-6 rtToolBar RECT-1 IMAGE-9 IMAGE-10 IMAGE-11 IMAGE-12 ~
IMAGE-13 IMAGE-14 
&Scoped-Define DISPLAYED-OBJECTS c-rota-ini c-rota-fim c-filial-ini ~
c-filial-fim c-placa-ini c-placa-fim i-pedido-ini i-pedido-fim c-serie-ini ~
c-serie-fim d-dt-ini rs-situacao 

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

DEFINE VARIABLE c-filial-fim AS CHARACTER FORMAT "X(5)" INITIAL "ZZZZZ" 
     VIEW-AS FILL-IN 
     SIZE 6 BY .88.

DEFINE VARIABLE c-filial-ini AS CHARACTER FORMAT "X(5)" 
     LABEL "Filial":R15 
     VIEW-AS FILL-IN 
     SIZE 6 BY .88.

DEFINE VARIABLE c-placa-fim AS CHARACTER FORMAT "X(10)":U INITIAL "ZZZZZZZZZZ" 
     VIEW-AS FILL-IN 
     SIZE 11 BY .88 NO-UNDO.

DEFINE VARIABLE c-placa-ini AS CHARACTER FORMAT "X(10)":U 
     LABEL "Placa" 
     VIEW-AS FILL-IN 
     SIZE 11 BY .88 NO-UNDO.

DEFINE VARIABLE c-rota-fim AS CHARACTER FORMAT "X(12)":U INITIAL "ZZZZZZZZZZZZ" 
     VIEW-AS FILL-IN 
     SIZE 13 BY .88 NO-UNDO.

DEFINE VARIABLE c-rota-ini AS CHARACTER FORMAT "X(12)":U 
     LABEL "Rota" 
     VIEW-AS FILL-IN 
     SIZE 13 BY .88 NO-UNDO.

DEFINE VARIABLE c-serie-fim AS CHARACTER FORMAT "X(5)":U INITIAL "ZZZZZ" 
     VIEW-AS FILL-IN 
     SIZE 6 BY .88 NO-UNDO.

DEFINE VARIABLE c-serie-ini AS CHARACTER FORMAT "X(256)":U 
     LABEL "S‚rie" 
     VIEW-AS FILL-IN 
     SIZE 6 BY .88 NO-UNDO.

DEFINE VARIABLE d-dt-ini AS DATE FORMAT "99/99/9999" INITIAL 01/01/00 
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

DEFINE IMAGE IMAGE-1
     FILENAME "image\im-fir":U
     SIZE 3 BY .88.

DEFINE IMAGE IMAGE-10
     FILENAME "image\im-fir":U
     SIZE 3 BY .88.

DEFINE IMAGE IMAGE-11
     FILENAME "image\im-las":U
     SIZE 3 BY .88.

DEFINE IMAGE IMAGE-12
     FILENAME "image\im-las":U
     SIZE 3 BY .88.

DEFINE IMAGE IMAGE-13
     FILENAME "image\im-fir":U
     SIZE 3 BY .88.

DEFINE IMAGE IMAGE-14
     FILENAME "image\im-las":U
     SIZE 3 BY .88.

DEFINE IMAGE IMAGE-2
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

DEFINE VARIABLE rs-situacao AS INTEGER INITIAL 4 
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS 
          "Pedido Pendente", 1,
"NF Gerada", 2,
"NF Autorizada", 3,
"Todos", 4
     SIZE 44.86 BY .88 NO-UNDO.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 58 BY .21.

DEFINE RECTANGLE rtToolBar
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 58 BY 1.42
     BGCOLOR 7 .


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME fpage0
     c-rota-ini AT ROW 1.58 COL 10.72 COLON-ALIGNED WIDGET-ID 32
     c-rota-fim AT ROW 1.58 COL 36.14 COLON-ALIGNED NO-LABEL WIDGET-ID 34
     c-filial-ini AT ROW 2.58 COL 10.72 COLON-ALIGNED
     c-filial-fim AT ROW 2.58 COL 36.14 COLON-ALIGNED NO-LABEL WIDGET-ID 36
     c-placa-ini AT ROW 3.58 COL 10.72 COLON-ALIGNED WIDGET-ID 48
     c-placa-fim AT ROW 3.58 COL 36.14 COLON-ALIGNED NO-LABEL WIDGET-ID 50
     i-pedido-ini AT ROW 4.58 COL 10.72 COLON-ALIGNED WIDGET-ID 52
     i-pedido-fim AT ROW 4.58 COL 36.14 COLON-ALIGNED NO-LABEL WIDGET-ID 54
     c-serie-ini AT ROW 5.58 COL 10.72 COLON-ALIGNED WIDGET-ID 56
     c-serie-fim AT ROW 5.58 COL 36.14 COLON-ALIGNED NO-LABEL WIDGET-ID 62
     d-dt-ini AT ROW 6.58 COL 10.72 COLON-ALIGNED WIDGET-ID 24
     rs-situacao AT ROW 7.75 COL 12.14 NO-LABEL WIDGET-ID 8
     btOK AT ROW 9.33 COL 2
     btCancel AT ROW 9.33 COL 13
     btHelp AT ROW 9.33 COL 47.29
     "Situa‡Æo:" VIEW-AS TEXT
          SIZE 6.86 BY .88 AT ROW 7.71 COL 5.14 WIDGET-ID 14
     IMAGE-1 AT ROW 1.58 COL 26.14
     IMAGE-2 AT ROW 1.58 COL 34.86
     IMAGE-5 AT ROW 2.58 COL 26.14
     IMAGE-6 AT ROW 2.58 COL 34.86
     rtToolBar AT ROW 9.08 COL 1.14
     RECT-1 AT ROW 1.04 COL 1.14 WIDGET-ID 30
     IMAGE-9 AT ROW 4.58 COL 26.14 WIDGET-ID 40
     IMAGE-10 AT ROW 3.58 COL 26.14 WIDGET-ID 42
     IMAGE-11 AT ROW 3.58 COL 34.86 WIDGET-ID 44
     IMAGE-12 AT ROW 4.58 COL 34.86 WIDGET-ID 46
     IMAGE-13 AT ROW 5.58 COL 26.14 WIDGET-ID 58
     IMAGE-14 AT ROW 5.58 COL 34.86 WIDGET-ID 60
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 79.14 BY 12.46
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
         HEIGHT             = 9.63
         WIDTH              = 58.43
         MAX-HEIGHT         = 18.71
         MAX-WIDTH          = 101
         VIRTUAL-HEIGHT     = 18.71
         VIRTUAL-WIDTH      = 101
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
    assign frame fPage0 c-rota-ini  
                        c-rota-fim  
                        c-filial-ini
                        c-filial-fim
                        c-placa-ini
                        c-placa-fim
                        i-pedido-ini
                        i-pedido-fim
                        c-serie-ini
                        c-serie-fim
                        d-dt-ini
                        rs-situacao.  

    assign  p-rota-ini   = c-rota-ini  
            p-rota-fim   = c-rota-fim  
            p-filial-ini = c-filial-ini  
            p-filial-fim = c-filial-fim 
            p-placa-ini  = c-placa-ini
            p-placa-fim  = c-placa-fim
            p-pedido-ini = i-pedido-ini
            p-pedido-fim = i-pedido-fim
            p-serie-ini  = c-serie-ini
            p-serie-fim  = c-serie-fim
            p-dt-ini     = d-dt-ini    
            p-situacao   = rs-situacao.

    assign p-l-open-query = yes.

    APPLY "CLOSE":U TO THIS-PROCEDURE.  
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

    assign  c-rota-ini:screen-value in frame fPage0   = p-rota-ini  
            c-rota-fim:screen-value in frame fPage0   = p-rota-fim 
            c-filial-ini:screen-value in frame fPage0 = p-filial-ini
            c-filial-fim:screen-value in frame fPage0 = p-filial-fim
            c-placa-ini:screen-value in frame fPage0  = p-placa-ini
            c-placa-fim:screen-value in frame fPage0  = p-placa-fim
            i-pedido-ini:screen-value in frame fPage0 = string(p-pedido-ini)
            i-pedido-fim:screen-value in frame fPage0 = string(p-pedido-fim)
            c-serie-ini:screen-value in frame fPage0  = p-serie-ini
            c-serie-fim:screen-value in frame fPage0  = p-serie-fim
            d-dt-ini:screen-value in frame fPage0     = string(p-dt-ini,"99/99/9999")
            rs-situacao:screen-value in frame fPage0  = string(p-situacao).

    RETURN "OK":U.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

