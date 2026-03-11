&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI ADM2
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME wWin
{adecomm/appserv.i}
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS wWin 
/*------------------------------------------------------------------------

  File: 

  Description: from cntnrwin.w - ADM SmartWindow Template

  Input Parameters:
      <none>

  Output Parameters:
      <none>

  History: New V9 Version - January 15, 1998
          
------------------------------------------------------------------------*/
/*          This .W file was created with the Progress AB.              */
/*----------------------------------------------------------------------*/

/* Create an unnamed pool to store all the widgets created 
     by this procedure. This is a good default which assures
     that this procedure's triggers and internal procedures 
     will execute in this procedure's storage, and that proper
     cleanup will occur on deletion of the procedure. */

CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */

define new global shared VAR c-usuario-cd0821   as CHAR no-undo.

{src/adm2/widgetprto.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE SmartWindow
&Scoped-define DB-AWARE no

&Scoped-define ADM-CONTAINER WINDOW

&Scoped-define ADM-SUPPORTED-LINKS Data-Target,Data-Source,Page-Target,Update-Source,Update-Target,Filter-target,Filter-Source

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME fMain

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS RECT-1 FILL-IN-1 bt10001 bt10002 bt10003 ~
bt10004 bt10005 bt10006 bt10007 bt10008 BUTTON-2 
&Scoped-Define DISPLAYED-OBJECTS FILL-IN-1 bt10001 bt10002 bt10003 bt10004 ~
bt10005 bt10006 bt10007 bt10008 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR wWin AS WIDGET-HANDLE NO-UNDO.

/* Definitions of the field level widgets                               */
DEFINE BUTTON BUTTON-2 
     LABEL "OK" 
     SIZE 15 BY 1.13.

DEFINE VARIABLE FILL-IN-1 AS CHARACTER FORMAT "X(256)":U 
     LABEL "Usuario" 
     VIEW-AS FILL-IN 
     SIZE 14 BY 1 NO-UNDO.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 41 BY 9.25.

DEFINE VARIABLE bt10001 AS LOGICAL INITIAL yes 
     LABEL "10001" 
     VIEW-AS TOGGLE-BOX
     SIZE 11.57 BY .83 NO-UNDO.

DEFINE VARIABLE bt10002 AS LOGICAL INITIAL yes 
     LABEL "10002" 
     VIEW-AS TOGGLE-BOX
     SIZE 11.57 BY .83 NO-UNDO.

DEFINE VARIABLE bt10003 AS LOGICAL INITIAL yes 
     LABEL "10003" 
     VIEW-AS TOGGLE-BOX
     SIZE 11.57 BY .83 NO-UNDO.

DEFINE VARIABLE bt10004 AS LOGICAL INITIAL yes 
     LABEL "10004" 
     VIEW-AS TOGGLE-BOX
     SIZE 11.57 BY .83 NO-UNDO.

DEFINE VARIABLE bt10005 AS LOGICAL INITIAL yes 
     LABEL "10005" 
     VIEW-AS TOGGLE-BOX
     SIZE 11.57 BY .83 NO-UNDO.

DEFINE VARIABLE bt10006 AS LOGICAL INITIAL yes 
     LABEL "10006" 
     VIEW-AS TOGGLE-BOX
     SIZE 11.57 BY .83 NO-UNDO.

DEFINE VARIABLE bt10007 AS LOGICAL INITIAL yes 
     LABEL "10007" 
     VIEW-AS TOGGLE-BOX
     SIZE 11.57 BY .83 NO-UNDO.

DEFINE VARIABLE bt10008 AS LOGICAL INITIAL yes 
     LABEL "10008" 
     VIEW-AS TOGGLE-BOX
     SIZE 11.57 BY .83 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME fMain
     FILL-IN-1 AT ROW 1.75 COL 11 COLON-ALIGNED WIDGET-ID 24
     bt10001 AT ROW 4.75 COL 5 WIDGET-ID 2
     bt10002 AT ROW 5.75 COL 5 WIDGET-ID 4
     bt10003 AT ROW 6.75 COL 5 WIDGET-ID 6
     bt10004 AT ROW 7.75 COL 5 WIDGET-ID 8
     bt10005 AT ROW 8.75 COL 5 WIDGET-ID 10
     bt10006 AT ROW 9.75 COL 5 WIDGET-ID 12
     bt10007 AT ROW 10.75 COL 5 WIDGET-ID 14
     bt10008 AT ROW 11.75 COL 5 WIDGET-ID 16
     BUTTON-2 AT ROW 13.5 COL 3 WIDGET-ID 22
     "Estabelecimento Principal" VIEW-AS TEXT
          SIZE 26 BY .67 AT ROW 3.5 COL 4 WIDGET-ID 20
     RECT-1 AT ROW 4 COL 3 WIDGET-ID 18
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 45.29 BY 14.17 WIDGET-ID 100.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: SmartWindow
   Allow: Basic,Browse,DB-Fields,Query,Smart,Window
   Container Links: Data-Target,Data-Source,Page-Target,Update-Source,Update-Target,Filter-target,Filter-Source
   Other Settings: APPSERVER
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
IF SESSION:DISPLAY-TYPE = "GUI":U THEN
  CREATE WINDOW wWin ASSIGN
         HIDDEN             = YES
         TITLE              = "<insert SmartWindow title>"
         HEIGHT             = 14.17
         WIDTH              = 45.29
         MAX-HEIGHT         = 28.79
         MAX-WIDTH          = 146.14
         VIRTUAL-HEIGHT     = 28.79
         VIRTUAL-WIDTH      = 146.14
         RESIZE             = no
         SCROLL-BARS        = no
         STATUS-AREA        = no
         BGCOLOR            = ?
         FGCOLOR            = ?
         THREE-D            = yes
         MESSAGE-AREA       = no
         SENSITIVE          = yes.
ELSE {&WINDOW-NAME} = CURRENT-WINDOW.
/* END WINDOW DEFINITION                                                */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _INCLUDED-LIB wWin 
/* ************************* Included-Libraries *********************** */

{src/adm2/containr.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME




/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW wWin
  VISIBLE,,RUN-PERSISTENT                                               */
/* SETTINGS FOR FRAME fMain
   FRAME-NAME                                                           */
IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(wWin)
THEN wWin:HIDDEN = yes.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME wWin
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL wWin wWin
ON END-ERROR OF wWin /* <insert SmartWindow title> */
OR ENDKEY OF {&WINDOW-NAME} ANYWHERE DO:
  /* This case occurs when the user presses the "Esc" key.
     In a persistently run window, just ignore this.  If we did not, the
     application would exit. */
  IF THIS-PROCEDURE:PERSISTENT THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL wWin wWin
ON WINDOW-CLOSE OF wWin /* <insert SmartWindow title> */
DO:
  /* This ADM code must be left here in order for the SmartWindow
     and its descendents to terminate properly on exit. */
  APPLY "CLOSE":U TO THIS-PROCEDURE.
  RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt10001
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt10001 wWin
ON LEAVE OF bt10001 IN FRAME fMain /* 10001 */
DO:
  APPLY "leave" TO bt10001.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt10001 wWin
ON VALUE-CHANGED OF bt10001 IN FRAME fMain /* 10001 */
DO:
  .MESSAGE  bt10001
      VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt10002
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt10002 wWin
ON LEAVE OF bt10002 IN FRAME fMain /* 10002 */
DO:
  APPLY "leave" TO bt10002.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt10002 wWin
ON VALUE-CHANGED OF bt10002 IN FRAME fMain /* 10002 */
DO:
  APPLY "leave" TO bt10002.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt10003
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt10003 wWin
ON VALUE-CHANGED OF bt10003 IN FRAME fMain /* 10003 */
DO:
  APPLY "leave" TO bt10003.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME BUTTON-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BUTTON-2 wWin
ON CHOOSE OF BUTTON-2 IN FRAME fMain /* OK */
DO:
    APPLY "leave" TO bt10001.
    APPLY "leave" TO bt10002.
    APPLY "leave" TO bt10003.
    APPLY "leave" TO bt10004.
    APPLY "leave" TO bt10005.
    APPLY "leave" TO bt10006.
    APPLY "leave" TO bt10007.
    APPLY "leave" TO bt10008.
 
   
   
    FIND FIRST esp-estab-principal
        WHERE esp-estab-principal.cod-user = c-usuario-cd0821 NO-ERROR. 
   
  
    IF AVAILABLE esp-estab-principal THEN DO:

        IF bt10001:CHECKED = YES THEN 
            ASSIGN esp-estab-principal.estab-principal[1] = "10001".
        ELSE 
            ASSIGN esp-estab-principal.estab-principal[1] = "".

        IF bt10002:CHECKED = YES THEN 
            ASSIGN esp-estab-principal.estab-principal[2] = "10002".
        ELSE 
            ASSIGN esp-estab-principal.estab-principal[2] = "".

        IF bt10003:CHECKED = YES THEN 
            ASSIGN esp-estab-principal.estab-principal[3] = "10003".
        ELSE 
            ASSIGN esp-estab-principal.estab-principal[3] = "".

        IF bt10004:CHECKED = YES THEN 
            ASSIGN esp-estab-principal.estab-principal[4] = "10004".
        ELSE 
            ASSIGN esp-estab-principal.estab-principal[4] = "".

        IF bt10005:CHECKED = YES THEN 
            ASSIGN esp-estab-principal.estab-principal[5] = "10005".
        ELSE 
            ASSIGN esp-estab-principal.estab-principal[5] = "".

        IF bt10006:CHECKED = YES THEN 
            ASSIGN esp-estab-principal.estab-principal[6] = "10006".
        ELSE 
            ASSIGN esp-estab-principal.estab-principal[6] = "".

        IF bt10007:CHECKED = YES THEN 
            ASSIGN esp-estab-principal.estab-principal[7] = "10007".
        ELSE 
            ASSIGN esp-estab-principal.estab-principal[7] = "".

        IF bt10008:CHECKED = YES THEN 
            ASSIGN esp-estab-principal.estab-principal[8] = "10008".
        ELSE 
            ASSIGN esp-estab-principal.estab-principal[8] = "".

        
        APPLY "leave" TO bt10001.
        APPLY "leave" TO bt10002.
        APPLY "leave" TO bt10003.
        APPLY "leave" TO bt10004.
        APPLY "leave" TO bt10005.
        APPLY "leave" TO bt10006.
        APPLY "leave" TO bt10007.
        APPLY "leave" TO bt10008.
        
        
            
    END.
    ELSE DO:
    
        CREATE esp-estab-principal.
        ASSIGN esp-estab-principal.cod-user = c-usuario-cd0821 .
        
        
        IF bt10001:CHECKED = YES THEN 
            ASSIGN esp-estab-principal.estab-principal[1] = "10001".
        ELSE 
            ASSIGN esp-estab-principal.estab-principal[1] = "".

        IF bt10002:CHECKED = YES THEN 
            ASSIGN esp-estab-principal.estab-principal[2] = "10002".
        ELSE 
            ASSIGN esp-estab-principal.estab-principal[2] = "".

        IF bt10003:CHECKED = YES THEN 
            ASSIGN esp-estab-principal.estab-principal[3] = "10003".
        ELSE 
            ASSIGN esp-estab-principal.estab-principal[3] = "".

        IF bt10004:CHECKED = YES THEN 
            ASSIGN esp-estab-principal.estab-principal[4] = "10004".
        ELSE 
            ASSIGN esp-estab-principal.estab-principal[4] = "".

        IF bt10005:CHECKED = YES THEN 
            ASSIGN esp-estab-principal.estab-principal[5] = "10005".
        ELSE 
            ASSIGN esp-estab-principal.estab-principal[5] = "".

        IF bt10006:CHECKED = YES THEN 
            ASSIGN esp-estab-principal.estab-principal[6] = "10006".
        ELSE 
            ASSIGN esp-estab-principal.estab-principal[6] = "".

        IF bt10007:CHECKED = YES THEN 
            ASSIGN esp-estab-principal.estab-principal[7] = "10007".
        ELSE 
            ASSIGN esp-estab-principal.estab-principal[7] = "".

        IF bt10008:CHECKED = YES THEN 
            ASSIGN esp-estab-principal.estab-principal[8] = "10008".
        ELSE 
            ASSIGN esp-estab-principal.estab-principal[8] = "".
    
    END.
    
    
    MESSAGE "Dados salvos com sucesso!"
        VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
  
    //RUN saveRecord IN THIS-PROCEDURE.
    APPLY "CLOSE":U TO THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME FILL-IN-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL FILL-IN-1 wWin
ON ENTRY OF FILL-IN-1 IN FRAME fMain /* Usuario */
DO:
  ASSIGN FILL-IN-1:SCREEN-VALUE   = c-usuario-cd0821
           FILL-IN-1:SENSITIVE = no  .
           
  FIND FIRST esp-estab-principal
        WHERE esp-estab-principal.cod-user = c-usuario-cd0821 NO-ERROR. 
        
    
        
  
  
    IF AVAILABLE esp-estab-principal THEN DO:

        IF esp-estab-principal.estab-principal[1] <> "" THEN 
            ASSIGN bt10001:CHECKED = YES.
        ELSE 
            ASSIGN bt10001:CHECKED = NO.

        IF esp-estab-principal.estab-principal[2] <> "" THEN 
            ASSIGN bt10002:CHECKED = YES.
        ELSE 
            ASSIGN bt10002:CHECKED = NO.

        IF esp-estab-principal.estab-principal[3] <> "" THEN 
            ASSIGN bt10003:CHECKED = YES.
        ELSE 
            ASSIGN bt10003:CHECKED = NO.

        IF esp-estab-principal.estab-principal[4] <> "" THEN 
            ASSIGN bt10004:CHECKED = YES.
        ELSE 
            ASSIGN bt10004:CHECKED = NO.

        IF esp-estab-principal.estab-principal[5] <> "" THEN 
            ASSIGN bt10005:CHECKED = YES.
        ELSE 
            ASSIGN bt10005:CHECKED = NO.

        IF esp-estab-principal.estab-principal[6] <> "" THEN 
            ASSIGN bt10006:CHECKED = YES.
        ELSE 
            ASSIGN bt10006:CHECKED = NO.

        IF esp-estab-principal.estab-principal[7] <> "" THEN 
            ASSIGN bt10007:CHECKED = YES.
        ELSE 
            ASSIGN bt10007:CHECKED = NO.

        IF esp-estab-principal.estab-principal[8] <> "" THEN 
            ASSIGN bt10008:CHECKED = YES.
        ELSE 
            ASSIGN bt10008:CHECKED = NO.

    END.         
           
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL FILL-IN-1 wWin
ON LEAVE OF FILL-IN-1 IN FRAME fMain /* Usuario */
DO:
  //  ASSIGN FILL-IN-1:SCREEN-VALUE   = c-usuario-cd0821
   //        FILL-IN-1:SENSITIVE = no  .
  
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK wWin 


/* ***************************  Main Block  *************************** */

/* Include custom  Main Block code for SmartWindows. */
{src/adm2/windowmn.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE adm-create-objects wWin  _ADM-CREATE-OBJECTS
PROCEDURE adm-create-objects :
/*------------------------------------------------------------------------------
  Purpose:     Create handles for all SmartObjects used in this procedure.
               After SmartObjects are initialized, then SmartLinks are added.
  Parameters:  <none>
------------------------------------------------------------------------------*/

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI wWin  _DEFAULT-DISABLE
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
  IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(wWin)
  THEN DELETE WIDGET wWin.
  IF THIS-PROCEDURE:PERSISTENT THEN DELETE PROCEDURE THIS-PROCEDURE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI wWin  _DEFAULT-ENABLE
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
  DISPLAY FILL-IN-1 bt10001 bt10002 bt10003 bt10004 bt10005 bt10006 bt10007 
          bt10008 
      WITH FRAME fMain IN WINDOW wWin.
  ENABLE RECT-1 FILL-IN-1 bt10001 bt10002 bt10003 bt10004 bt10005 bt10006 
         bt10007 bt10008 BUTTON-2 
      WITH FRAME fMain IN WINDOW wWin.
  {&OPEN-BROWSERS-IN-QUERY-fMain}
  VIEW wWin.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE exitObject wWin 
PROCEDURE exitObject :
/*------------------------------------------------------------------------------
  Purpose:  Window-specific override of this procedure which destroys 
            its contents and itself.
    Notes:  
------------------------------------------------------------------------------*/

  APPLY "CLOSE":U TO THIS-PROCEDURE.
  RETURN.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

