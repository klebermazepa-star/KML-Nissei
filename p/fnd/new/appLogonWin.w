&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME w-win
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS w-win 
/*
*/

{utp/ut-glob.i}

{include/i-prgvrs.i appLogonWin 2.08.00.001}

CREATE WIDGET-POOL.

/**/
DEF NEW GLOBAL SHARED VAR h-facelift        AS HANDLE NO-UNDO .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Window
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME fPage0

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS f-usuario f-senha b-con b-sair 
&Scoped-Define DISPLAYED-OBJECTS f-empresa f-usuario f-senha f-programa 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR w-win AS WIDGET-HANDLE NO-UNDO.

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-con 
     LABEL "Login" 
     SIZE 12 BY 1.

DEFINE BUTTON b-sair 
     LABEL "Sair" 
     SIZE 12 BY 1.

DEFINE VARIABLE f-empresa AS CHARACTER FORMAT "X(3)":U 
     LABEL "Empresa" 
     VIEW-AS FILL-IN 
     SIZE 4 BY .88 NO-UNDO.

DEFINE VARIABLE f-programa AS CHARACTER FORMAT "X(256)":U 
     LABEL "Programa" 
     VIEW-AS FILL-IN 
     SIZE 20 BY .88 NO-UNDO.

DEFINE VARIABLE f-senha AS CHARACTER FORMAT "X(256)":U 
     LABEL "Senha" 
     VIEW-AS FILL-IN 
     SIZE 20 BY .88 NO-UNDO.

DEFINE VARIABLE f-usuario AS CHARACTER FORMAT "X(256)":U 
     LABEL "Usuario" 
     VIEW-AS FILL-IN 
     SIZE 20 BY .88 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME fPage0
     f-empresa AT ROW 1.25 COL 10 COLON-ALIGNED WIDGET-ID 6
     f-usuario AT ROW 2.25 COL 10 COLON-ALIGNED WIDGET-ID 14
     f-senha AT ROW 3.25 COL 10 COLON-ALIGNED WIDGET-ID 16 PASSWORD-FIELD 
     f-programa AT ROW 4.5 COL 10 COLON-ALIGNED WIDGET-ID 28
     b-con AT ROW 6 COL 6 WIDGET-ID 26
     b-sair AT ROW 6 COL 28.72 WIDGET-ID 30
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 45 BY 6
         FONT 7 WIDGET-ID 100.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Window
   Allow: Basic,Browse,DB-Fields,Window,Query
   Other Settings: COMPILE
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
IF SESSION:DISPLAY-TYPE = "GUI":U THEN
  CREATE WINDOW w-win ASSIGN
         HIDDEN             = YES
         TITLE              = "APPLOGON - TOTVS12 - 2.08.00.000"
         HEIGHT             = 6
         WIDTH              = 45
         MAX-HEIGHT         = 29.38
         MAX-WIDTH          = 194.29
         VIRTUAL-HEIGHT     = 29.38
         VIRTUAL-WIDTH      = 194.29
         RESIZE             = no
         SCROLL-BARS        = no
         STATUS-AREA        = no
         BGCOLOR            = ?
         FGCOLOR            = ?
         KEEP-FRAME-Z-ORDER = yes
         THREE-D            = yes
         MESSAGE-AREA       = no
         SENSITIVE          = yes.
ELSE {&WINDOW-NAME} = CURRENT-WINDOW.
/* END WINDOW DEFINITION                                                */
&ANALYZE-RESUME



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW w-win
  VISIBLE,,RUN-PERSISTENT                                               */
/* SETTINGS FOR FRAME fPage0
   FRAME-NAME                                                           */
/* SETTINGS FOR FILL-IN f-empresa IN FRAME fPage0
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN f-programa IN FRAME fPage0
   NO-ENABLE                                                            */
IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(w-win)
THEN w-win:HIDDEN = no.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME w-win
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL w-win w-win
ON END-ERROR OF w-win /* APPLOGON - TOTVS12 - 2.08.00.000 */
OR ENDKEY OF {&WINDOW-NAME} ANYWHERE DO:
  /* This case occurs when the user presses the "Esc" key.
     In a persistently run window, just ignore this.  If we did not, the
     application would exit. */
  IF THIS-PROCEDURE:PERSISTENT THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL w-win w-win
ON WINDOW-CLOSE OF w-win /* APPLOGON - TOTVS12 - 2.08.00.000 */
DO:
  /* This event will close the window and terminate the procedure.  */
  APPLY "CLOSE":U TO THIS-PROCEDURE.
  RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-con
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-con w-win
ON CHOOSE OF b-con IN FRAME fPage0 /* Login */
DO:
    RUN pi-login .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sair
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sair w-win
ON CHOOSE OF b-sair IN FRAME fPage0 /* Sair */
DO:
    APPLY "WINDOW-CLOSE" TO {&WINDOW-NAME} .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK w-win 


/* ***************************  Main Block  *************************** */
ASSIGN 
    CURRENT-WINDOW                = {&WINDOW-NAME} 
    THIS-PROCEDURE:CURRENT-WINDOW = {&WINDOW-NAME}
    .

ON CLOSE OF THIS-PROCEDURE 
   RUN disable_UI.

PAUSE 0 BEFORE-HIDE .

MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
    :
    RUN enable_UI.
    RUN pi-initialize .
    IF NOT THIS-PROCEDURE:PERSISTENT THEN WAIT-FOR CLOSE OF THIS-PROCEDURE .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI w-win  _DEFAULT-DISABLE
PROCEDURE disable_UI :
/*------------------------------------------------------------------------------
  Purpose:     DISABLE the User Interface
  Parameters:  <none>
  Notes:       Here we clean-up the user-interface by deleting
               dynamic widgets we have created and/or hide 
               frames.  This procedure is usually called when
               we are ready to "clean-up" after running.
------------------------------------------------------------------------------*/
  /* Delete the WINDOW we created */
  IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(w-win)
  THEN DELETE WIDGET w-win.
  IF THIS-PROCEDURE:PERSISTENT THEN DELETE PROCEDURE THIS-PROCEDURE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI w-win  _DEFAULT-ENABLE
PROCEDURE enable_UI :
/*------------------------------------------------------------------------------
  Purpose:     ENABLE the User Interface
  Parameters:  <none>
  Notes:       Here we display/view/enable the widgets in the
               user-interface.  In addition, OPEN all queries
               associated with each FRAME and BROWSE.
               These statements here are based on the "Other 
               Settings" section of the widget Property Sheets.
------------------------------------------------------------------------------*/
  DISPLAY f-empresa f-usuario f-senha f-programa 
      WITH FRAME fPage0 IN WINDOW w-win.
  ENABLE f-usuario f-senha b-con b-sair 
      WITH FRAME fPage0 IN WINDOW w-win.
  {&OPEN-BROWSERS-IN-QUERY-fPage0}
  VIEW w-win.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-initialize w-win 
PROCEDURE pi-initialize :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
IF NOT VALID-HANDLE(h-facelift) THEN RUN btb/btb901zo.p PERSISTENT SET h-facelift.
RUN pi_aplica_facelift_thin IN h-facelift ( INPUT FRAME fPage0:HANDLE ).

ASSIGN 
    f-empresa:SCREEN-VALUE IN FRAME fPage0  = ENTRY(3 , SESSION:PARAMETER)
    f-usuario:SCREEN-VALUE IN FRAME fPage0  = ENTRY(1 , SESSION:PARAMETER) 
    f-senha:SCREEN-VALUE IN FRAME fPage0    = ENTRY(2 , SESSION:PARAMETER)
    f-programa:SCREEN-VALUE IN FRAME fPage0 = ENTRY(4 , SESSION:PARAMETER)
    .

IF f-empresa:SCREEN-VALUE IN FRAME fPage0 <> "" AND 
   f-usuario:SCREEN-VALUE IN FRAME fPage0 <> "" AND
   f-senha:SCREEN-VALUE IN FRAME fPage0 <> "" AND
   f-programa:SCREEN-VALUE IN FRAME fPage0 <> ""
THEN DO:
    RUN pi-login .
END.

IF f-programa:SCREEN-VALUE IN FRAME fPage0 <> "" THEN DO:
    f-programa:SENSITIVE IN FRAME fPage0 = NO .
END.

/**/
RETURN "OK":U .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-login w-win 
PROCEDURE pi-login :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
DEF VAR h-acomp AS HANDLE NO-UNDO .
RUN utp/ut-acomp.p PERSISTENT SET h-acomp.
RUN pi-inicializar IN h-acomp ("Realizando Login...") .
RUN pi-acompanhar IN h-acomp ("Aguarde...") .

RUN fnd\new\login.p 
    (INPUT f-usuario:SCREEN-VALUE IN FRAME fPage0 ,
     INPUT f-senha:SCREEN-VALUE IN FRAME fPage0 ,
     INPUT f-empresa:SCREEN-VALUE IN FRAME fPage0 )
    .

/**/
FIND prog_dtsul NO-LOCK WHERE
    prog_dtsul.cod_prog_dtsul = INPUT f-programa:SCREEN-VALUE IN FRAME fPage0
    .

/*
CURRENT-WINDOW:VISIBLE = NO .
RUN VALUE(prog_dtsul.nom_prog_ext) .
*/
DEF VAR hProg   AS HANDLE NO-UNDO .
RUN VALUE (prog_dtsul.nom_prog_ext) PERSISTENT SET hProg .
IF LOOKUP("dispatch" , hProg:INTERNAL-ENTRIES) > 0 THEN DO:
    RUN dispatch IN hProg (INPUT 'initialize':U ) .
END.
ELSE IF LOOKUP("initializeInterface" , hProg:INTERNAL-ENTRIES) > 0 THEN DO:
    RUN initializeInterface IN hProg .
END.

/**/
APPLY "WINDOW-CLOSE" TO {&WINDOW-NAME} .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

