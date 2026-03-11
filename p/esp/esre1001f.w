&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME wWindow
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS wWindow 
/*:T*******************************************************************************
** Copyright DATASUL S.A. (1999)
** Todos os Direitos Reservados.
**
** Este fonte e de propriedade exclusiva da DATASUL, sua reproducao
** parcial ou total por qualquer meio, so podera ser feita mediante
** autorizacao expressa.
*******************************************************************************/
{include/i-prgvrs.i ESRE1001F 2.00.00.000}

&IF "{&EMSFND_VERSION}" >= "1.00"
&THEN
&ENDIF

CREATE WIDGET-POOL.

/* Preprocessors Definitions ---                                      */
&GLOBAL-DEFINE Program        ESRE1001F
&GLOBAL-DEFINE Version        2.00.00.00

&GLOBAL-DEFINE WindowType     Master

&GLOBAL-DEFINE Folder         NO
&GLOBAL-DEFINE InitialPage    1
&GLOBAL-DEFINE FolderLabels   

&GLOBAL-DEFINE page0Widgets   btOK btCancel 

&GLOBAL-DEFINE EXCLUDE-translate     YES
&GLOBAL-DEFINE EXCLUDE-translateMenu YES

DEF TEMP-TABLE tt-param NO-UNDO
    FIELD situacao AS INT INITIAL 1
    FIELD dt-valid-ini AS DATE   INIT 01/01/0001
    FIELD dt-valid-fim AS DATE   INIT 12/31/2099
    FIELD cod-estabel-ini AS CHAR
    FIELD cod-estabel-fim AS CHAR INIT "ZZZ"
    FIELD nr-contrato-ini AS INT
    FIELD nr-contrato-fim AS INT INIT 9999999
    .




/* Parameters Definitions ---                                           */

DEFINE OUTPUT PARAMETER pl-ok AS LOGICAL     NO-UNDO.
DEFINE INPUT-OUTPUT PARAM TABLE FOR tt-param.

/* Local Variable Definitions ---                                       */


def var l-ok               as logical no-undo.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Window
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME fpage0

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS rtToolBar RECT-13 IMAGE-1 IMAGE-2 IMAGE-3 ~
IMAGE-4 IMAGE-5 IMAGE-6 sit-conciliacao dt-valid-ini-aux dt-valid-fim-aux ~
c-cod-estabel-ini c-cod-estabel-fim c-contrato-ini c-contrato-fim btOK ~
btCancel 
&Scoped-Define DISPLAYED-OBJECTS sit-conciliacao dt-valid-ini-aux ~
dt-valid-fim-aux c-cod-estabel-ini c-cod-estabel-fim c-contrato-ini ~
c-contrato-fim 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR wWindow AS WIDGET-HANDLE NO-UNDO.

/* Definitions of the field level widgets                               */
DEFINE BUTTON btCancel 
     LABEL "Cancelar" 
     SIZE 10 BY 1.

DEFINE BUTTON btOK 
     LABEL "OK" 
     SIZE 10 BY 1.

DEFINE VARIABLE c-cod-estabel-fim AS CHARACTER FORMAT "X(5)":U INITIAL "ZZZ" 
     VIEW-AS FILL-IN 
     SIZE 6 BY .79 NO-UNDO.

DEFINE VARIABLE c-cod-estabel-ini AS CHARACTER FORMAT "X(5)":U 
     LABEL "Estabel" 
     VIEW-AS FILL-IN 
     SIZE 6 BY .79 NO-UNDO.

DEFINE VARIABLE c-contrato-fim AS INTEGER FORMAT "->,>>>,>>9":U INITIAL 9999999 
     VIEW-AS FILL-IN 
     SIZE 8.86 BY .79 NO-UNDO.

DEFINE VARIABLE c-contrato-ini AS INTEGER FORMAT "->,>>>,>>9":U INITIAL 0 
     LABEL "Contrato" 
     VIEW-AS FILL-IN 
     SIZE 8.86 BY .79 NO-UNDO.

DEFINE VARIABLE dt-valid-fim-aux AS DATE FORMAT "99/99/9999":U INITIAL 12/31/2099 
     VIEW-AS FILL-IN 
     SIZE 11 BY .88 NO-UNDO.

DEFINE VARIABLE dt-valid-ini-aux AS DATE FORMAT "99/99/9999":U 
     LABEL "Dt. Validade" 
     VIEW-AS FILL-IN 
     SIZE 11 BY .88 NO-UNDO.

DEFINE IMAGE IMAGE-1
     FILENAME "image\im-fir":U
     SIZE 3 BY .88.

DEFINE IMAGE IMAGE-2
     FILENAME "image\im-las":U
     SIZE 3 BY .88.

DEFINE IMAGE IMAGE-3
     FILENAME "image\im-fir":U
     SIZE 3 BY .88.

DEFINE IMAGE IMAGE-4
     FILENAME "image\im-las":U
     SIZE 3 BY .88.

DEFINE IMAGE IMAGE-5
     FILENAME "image\im-fir":U
     SIZE 3 BY .88.

DEFINE IMAGE IMAGE-6
     FILENAME "image\im-las":U
     SIZE 3 BY .88.

DEFINE VARIABLE sit-conciliacao AS INTEGER 
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS 
          "Todos", 1,
"Gerados", 2,
"Pendentes", 3
     SIZE 31 BY 1 NO-UNDO.

DEFINE RECTANGLE RECT-13
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 34 BY 1.71.

DEFINE RECTANGLE rtToolBar
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 46 BY 1.42
     BGCOLOR 7 .


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME fpage0
     sit-conciliacao AT ROW 2.08 COL 6.57 NO-LABEL WIDGET-ID 92
     dt-valid-ini-aux AT ROW 4 COL 10.29 COLON-ALIGNED WIDGET-ID 100
     dt-valid-fim-aux AT ROW 4 COL 28.29 COLON-ALIGNED NO-LABEL WIDGET-ID 102
     c-cod-estabel-ini AT ROW 5 COL 15.29 COLON-ALIGNED WIDGET-ID 108
     c-cod-estabel-fim AT ROW 5 COL 28.29 COLON-ALIGNED NO-LABEL WIDGET-ID 114
     c-contrato-ini AT ROW 5.96 COL 12.43 COLON-ALIGNED WIDGET-ID 116
     c-contrato-fim AT ROW 5.96 COL 28.29 COLON-ALIGNED NO-LABEL WIDGET-ID 122
     btOK AT ROW 9.96 COL 3
     btCancel AT ROW 9.96 COL 14
     "Situa‡Æo Documentos" VIEW-AS TEXT
          SIZE 17.14 BY .54 AT ROW 1.38 COL 6.86 WIDGET-ID 98
     rtToolBar AT ROW 9.75 COL 2
     RECT-13 AT ROW 1.71 COL 5 WIDGET-ID 96
     IMAGE-1 AT ROW 4 COL 23.72 WIDGET-ID 104
     IMAGE-2 AT ROW 4 COL 27 WIDGET-ID 106
     IMAGE-3 AT ROW 4.96 COL 23.72 WIDGET-ID 110
     IMAGE-4 AT ROW 4.96 COL 27 WIDGET-ID 112
     IMAGE-5 AT ROW 5.92 COL 23.72 WIDGET-ID 118
     IMAGE-6 AT ROW 5.92 COL 27 WIDGET-ID 120
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 47.86 BY 10.46
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
         HEIGHT             = 10.58
         WIDTH              = 49.14
         MAX-HEIGHT         = 22.42
         MAX-WIDTH          = 95
         VIRTUAL-HEIGHT     = 22.42
         VIRTUAL-WIDTH      = 95
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
   FRAME-NAME                                                           */
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

    ASSIGN pl-ok = NO.
    APPLY "CLOSE":U TO THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btOK
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btOK wWindow
ON CHOOSE OF btOK IN FRAME fpage0 /* OK */
DO:                   

    DO WITH FRAME fPage0:
        
        ASSIGN tt-param.situacao     = INPUT sit-conciliacao
               tt-param.dt-valid-ini = INPUT dt-valid-ini-aux
               tt-param.dt-valid-fim = INPUT dt-valid-fim-aux
               tt-param.cod-estabel-ini = INPUT c-cod-estabel-ini
               tt-param.cod-estabel-fim = INPUT c-cod-estabel-fim
               tt-param.nr-contrato-ini = INPUT c-contrato-ini
               tt-param.nr-contrato-fim = INPUT c-contrato-fim.
    END.

    ASSIGN pl-ok = YES.      
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

    FIND FIRST tt-param NO-ERROR.
  
    DO WITH FRAME fPage0:
        ENABLE sit-conciliacao
               dt-valid-ini-aux
               dt-valid-fim-aux
               c-cod-estabel-ini
               c-cod-estabel-fim
               c-contrato-ini
               c-contrato-fim.
    
        ASSIGN sit-conciliacao:SCREEN-VALUE  = STRING(tt-param.situacao)
               dt-valid-ini-aux:SCREEN-VALUE = STRING(tt-param.dt-valid-ini)
               dt-valid-fim-aux:SCREEN-VALUE = STRING(tt-param.dt-valid-fim)
               c-cod-estabel-ini:SCREEN-VALUE = tt-param.cod-estabel-ini
               c-cod-estabel-fim:SCREEN-VALUE = tt-param.cod-estabel-fim
               c-contrato-ini:SCREEN-VALUE    = string(tt-param.nr-contrato-ini)
               c-contrato-fim:SCREEN-VALUE    = string(tt-param.nr-contrato-fim).
    END.
    
    ASSIGN pl-ok = NO.
  
    RETURN "OK".
  
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Translate wWindow 
PROCEDURE Translate :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

 RETURN "OK".

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

