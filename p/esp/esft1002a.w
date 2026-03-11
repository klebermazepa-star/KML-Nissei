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
{include/i-prgvrs.i ESFT1002A 2.00.01.GCJ}

&IF "{&EMSFND_VERSION}" >= "1.00"
&THEN
&ENDIF

CREATE WIDGET-POOL.

/* Preprocessors Definitions ---                                      */
&GLOBAL-DEFINE Program        ESFT1002A
&GLOBAL-DEFINE Version        2.00.01.GCJ

&GLOBAL-DEFINE WindowType     Master

&GLOBAL-DEFINE Folder         NO
&GLOBAL-DEFINE InitialPage    1
&GLOBAL-DEFINE FolderLabels   

&GLOBAL-DEFINE page0Widgets   btOK btCancel 

&GLOBAL-DEFINE EXCLUDE-translate     YES
&GLOBAL-DEFINE EXCLUDE-translateMenu YES

DEF TEMP-TABLE tt-selecao NO-UNDO
    FIELD cod-estabel                LIKE es-fat-duplic-nexxera.cod-estabel       EXTENT 2
    FIELD nr-fatura                  LIKE es-fat-duplic-nexxera.nr-fatura         EXTENT 2  
    FIELD cod-portador               LIKE es-fat-duplic-nexxera.cod-portador      EXTENT 2  
    FIELD dt-venciment               LIKE es-fat-duplic-nexxera.dt-venciment      EXTENT 2  

    .


/* Parameters Definitions ---                                           */

DEFINE OUTPUT PARAMETER pl-ok AS LOGICAL     NO-UNDO.
DEFINE INPUT-OUTPUT PARAM TABLE FOR tt-selecao.

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
&Scoped-Define ENABLED-OBJECTS rtToolBar IMAGE-5 IMAGE-6 IMAGE-7 IMAGE-8 ~
IMAGE-9 IMAGE-10 IMAGE-17 IMAGE-18 c-cod-estabel-ini c-cod-estabel-fim ~
c-nr-fatura-ini c-nr-fatura-fim i-cod-portador-ini i-cod-portador-fim ~
dt-venciment-ini dt-venciment-fim btOK btCancel 
&Scoped-Define DISPLAYED-OBJECTS c-cod-estabel-ini c-cod-estabel-fim ~
c-nr-fatura-ini c-nr-fatura-fim i-cod-portador-ini i-cod-portador-fim ~
dt-venciment-ini dt-venciment-fim 

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

DEFINE VARIABLE c-cod-estabel-fim AS CHARACTER FORMAT "X(5)":U 
     VIEW-AS FILL-IN 
     SIZE 15 BY .88
     FONT 1 NO-UNDO.

DEFINE VARIABLE c-cod-estabel-ini AS CHARACTER FORMAT "X(5)":U 
     LABEL "Estabelecimento" 
     VIEW-AS FILL-IN 
     SIZE 15 BY .88
     FONT 1 NO-UNDO.

DEFINE VARIABLE c-nr-fatura-fim AS CHARACTER FORMAT "X(16)":U 
     VIEW-AS FILL-IN 
     SIZE 15 BY .88
     FONT 1 NO-UNDO.

DEFINE VARIABLE c-nr-fatura-ini AS CHARACTER FORMAT "X(16)":U 
     LABEL "Fatura" 
     VIEW-AS FILL-IN 
     SIZE 15 BY .88
     FONT 1 NO-UNDO.

DEFINE VARIABLE dt-venciment-fim AS DATE FORMAT "99/99/9999":U 
     VIEW-AS FILL-IN 
     SIZE 15 BY .88
     FONT 1 NO-UNDO.

DEFINE VARIABLE dt-venciment-ini AS DATE FORMAT "99/99/9999":U 
     LABEL "Data Vencimento" 
     VIEW-AS FILL-IN 
     SIZE 15 BY .88
     FONT 1 NO-UNDO.

DEFINE VARIABLE i-cod-portador-fim AS INTEGER FORMAT "->,>>>,>>9":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 15 BY .88
     FONT 1 NO-UNDO.

DEFINE VARIABLE i-cod-portador-ini AS INTEGER FORMAT "->,>>>,>>9":U INITIAL 0 
     LABEL "Portador" 
     VIEW-AS FILL-IN 
     SIZE 15 BY .88
     FONT 1 NO-UNDO.

DEFINE IMAGE IMAGE-10
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

DEFINE IMAGE IMAGE-7
     FILENAME "image\im-fir":U
     SIZE 3 BY .88.

DEFINE IMAGE IMAGE-8
     FILENAME "image\im-las":U
     SIZE 3 BY .88.

DEFINE IMAGE IMAGE-9
     FILENAME "image\im-fir":U
     SIZE 3 BY .88.

DEFINE RECTANGLE rtToolBar
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 74 BY 1.42
     BGCOLOR 7 .


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME fpage0
     c-cod-estabel-ini AT ROW 2.5 COL 4 WIDGET-ID 84
     c-cod-estabel-fim AT ROW 2.5 COL 49.14 NO-LABEL WIDGET-ID 82
     c-nr-fatura-ini AT ROW 3.5 COL 10.86 WIDGET-ID 92
     c-nr-fatura-fim AT ROW 3.5 COL 49.14 NO-LABEL WIDGET-ID 90
     i-cod-portador-ini AT ROW 4.5 COL 9.43 WIDGET-ID 100
     i-cod-portador-fim AT ROW 4.5 COL 49.14 NO-LABEL WIDGET-ID 98
     dt-venciment-ini AT ROW 5.54 COL 3.43 WIDGET-ID 132
     dt-venciment-fim AT ROW 5.54 COL 49.14 NO-LABEL WIDGET-ID 130
     btOK AT ROW 8.71 COL 2
     btCancel AT ROW 8.71 COL 13
     rtToolBar AT ROW 8.5 COL 1
     IMAGE-5 AT ROW 2.5 COL 30.86 WIDGET-ID 86
     IMAGE-6 AT ROW 2.5 COL 46.14 WIDGET-ID 88
     IMAGE-7 AT ROW 3.5 COL 30.86 WIDGET-ID 94
     IMAGE-8 AT ROW 3.5 COL 46.14 WIDGET-ID 96
     IMAGE-9 AT ROW 4.5 COL 30.86 WIDGET-ID 102
     IMAGE-10 AT ROW 4.5 COL 46.14 WIDGET-ID 104
     IMAGE-17 AT ROW 5.54 COL 30.86 WIDGET-ID 134
     IMAGE-18 AT ROW 5.54 COL 46.14 WIDGET-ID 136
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 74.86 BY 15.71
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
         HEIGHT             = 9
         WIDTH              = 75.57
         MAX-HEIGHT         = 18.88
         MAX-WIDTH          = 95
         VIRTUAL-HEIGHT     = 18.88
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
/* SETTINGS FOR FILL-IN c-cod-estabel-fim IN FRAME fpage0
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN c-cod-estabel-ini IN FRAME fpage0
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN c-nr-fatura-fim IN FRAME fpage0
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN c-nr-fatura-ini IN FRAME fpage0
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN dt-venciment-fim IN FRAME fpage0
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN dt-venciment-ini IN FRAME fpage0
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN i-cod-portador-fim IN FRAME fpage0
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN i-cod-portador-ini IN FRAME fpage0
   ALIGN-L                                                              */
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

    ASSIGN tt-selecao.cod-estabel[1]               = input frame fPage0 c-cod-estabel-ini              
           tt-selecao.cod-estabel[2]               = input frame fPage0 c-cod-estabel-fim              
           tt-selecao.nr-fatura[1]                   = input frame fPage0 c-nr-fatura-ini              
           tt-selecao.nr-fatura[2]                   = input frame fPage0 c-nr-fatura-fim              
           tt-selecao.cod-portador[1]                     = input frame fPage0 i-cod-portador-ini      
           tt-selecao.cod-portador[2]                     = input frame fPage0 i-cod-portador-fim      
           tt-selecao.dt-venciment[1]               = input frame fPage0 dt-venciment-ini              
           tt-selecao.dt-venciment[2]               = input frame fPage0 dt-venciment-fim              
           .
                                                                                     
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

 FIND FIRST tt-selecao NO-ERROR.

 DO WITH FRAME fpage0:          

     ASSIGN c-cod-estabel-ini                 :SENSITIVE = YES
            c-cod-estabel-fim                 :SENSITIVE = YES
            c-nr-fatura-ini           :SENSITIVE = YES
            c-nr-fatura-fim           :SENSITIVE = YES
            i-cod-portador-ini             :SENSITIVE = YES
            i-cod-portador-fim             :SENSITIVE = YES
            dt-venciment-ini               :SENSITIVE = YES
            dt-venciment-fim               :SENSITIVE = YES
            .


     DISP tt-selecao.cod-estabel[1]               @ c-cod-estabel-ini   
          tt-selecao.cod-estabel[2]               @ c-cod-estabel-fim   
          tt-selecao.nr-fatura[1]                   @ c-nr-fatura-ini     
          tt-selecao.nr-fatura[2]                   @ c-nr-fatura-fim     
          tt-selecao.cod-portador[1]                     @ i-cod-portador-ini  
          tt-selecao.cod-portador[2]                     @ i-cod-portador-fim  
          tt-selecao.dt-venciment[1]               @ dt-venciment-ini    
          tt-selecao.dt-venciment[2]               @ dt-venciment-fim    
          .
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

