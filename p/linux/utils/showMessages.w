&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v9r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame 
/*------------------------------------------------------------------------

  File: 

  Description: 

  Input Parameters:
      <none>

  Output Parameters:
      <none>

  Author: 

  Created: 
------------------------------------------------------------------------*/
/*          This .W file was created with the Progress AppBuilder.       */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */
{method/dbotterr.i}

/* Parameters Definitions ---                                           */
define input parameter table for RowErrors.

/* Local Variable Definitions ---                                       */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME brRowErrors

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES RowErrors

/* Definitions for BROWSE brRowErrors                                   */
&Scoped-define FIELDS-IN-QUERY-brRowErrors RowErrors.ErrorSequence RowErrors.ErrorNumber RowErrors.ErrorDescription RowErrors.ErrorSubType   
&Scoped-define ENABLED-FIELDS-IN-QUERY-brRowErrors   
&Scoped-define SELF-NAME brRowErrors
&Scoped-define QUERY-STRING-brRowErrors FOR EACH RowErrors NO-LOCK
&Scoped-define OPEN-QUERY-brRowErrors OPEN QUERY {&SELF-NAME} FOR EACH RowErrors NO-LOCK.
&Scoped-define TABLES-IN-QUERY-brRowErrors RowErrors
&Scoped-define FIRST-TABLE-IN-QUERY-brRowErrors RowErrors


/* Definitions for FRAME fPage0                                         */
&Scoped-define OPEN-BROWSERS-IN-QUERY-fPage0 ~
    ~{&OPEN-QUERY-brRowErrors}

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON btHelp 
     LABEL "Ajuda" 
     SIZE 10 BY 1 TOOLTIP "Ajuda".

DEFINE BUTTON btOK AUTO-GO 
     LABEL "OK" 
     SIZE 10 BY 1 TOOLTIP "OK".

DEFINE VARIABLE edErrorHelp AS CHARACTER 
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 62 BY 4.17 TOOLTIP "Texto de ajuda da descri‡Æo do erro"
     BGCOLOR 15  NO-UNDO.

DEFINE IMAGE imErrorSubType
     FILENAME "image\im-mqerr":U
     SIZE 5 BY 1.5.

DEFINE RECTANGLE rtToolBar
     EDGE-PIXELS 2 GRAPHIC-EDGE  
     SIZE 67 BY 1.42
     BGCOLOR 7 .

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY brRowErrors FOR 
      RowErrors SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE brRowErrors
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS brRowErrors Dialog-Frame _FREEFORM
  QUERY brRowErrors DISPLAY
      RowErrors.ErrorSequence    column-label '#':u       format ">>,>>9":u
    RowErrors.ErrorNumber      column-label 'N§':u      format ">>,>>9":u
    RowErrors.ErrorDescription column-label 'Descri‡Æo' format "x(200)":u
    RowErrors.ErrorSubType     column-label 'Tipo'
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-COLUMN-SCROLLING SEPARATORS SIZE 62 BY 4.5
         FONT 1 TOOLTIP "Erros".


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     SPACE(67.15) SKIP(10.47)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Erros/Advertˆncias".

DEFINE FRAME fPage0
     brRowErrors AT ROW 1 COL 6
     edErrorHelp AT ROW 5.67 COL 6 NO-LABEL
     btOK AT ROW 10.25 COL 2
     btHelp AT ROW 10.25 COL 57
     imErrorSubType AT ROW 1 COL 1
     rtToolBar AT ROW 10 COL 1
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 67.14 BY 10.46
         FONT 1
         CANCEL-BUTTON btOK.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
   Allow: Basic,Browse,DB-Fields,Query
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* REPARENT FRAME */
ASSIGN FRAME fPage0:FRAME = FRAME Dialog-Frame:HANDLE.

/* SETTINGS FOR DIALOG-BOX Dialog-Frame
                                                                        */
ASSIGN 
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR FRAME fPage0
                                                                        */
/* BROWSE-TAB brRowErrors rtToolBar fPage0 */
ASSIGN 
       brRowErrors:NUM-LOCKED-COLUMNS IN FRAME fPage0     = 2.

ASSIGN 
       edErrorHelp:READ-ONLY IN FRAME fPage0        = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE brRowErrors
/* Query rebuild information for BROWSE brRowErrors
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH RowErrors NO-LOCK.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE brRowErrors */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Erros/Advertˆncias */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME brRowErrors
&Scoped-define FRAME-NAME fPage0
&Scoped-define SELF-NAME brRowErrors
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL brRowErrors Dialog-Frame
ON VALUE-CHANGED OF brRowErrors IN FRAME fPage0
DO:
    if avail RowErrors then
        do with frame {&frame-name}:
            assign
                edErrorHelp:screen-value = RowErrors.ErrorHelp.
    
            case RowErrors.ErrorSubType:
                when 'Information':u or when 'Informa‡Æo' then
                    imErrorSubType:load-image('image/im-mqinf.bmp':u).
                when 'Warning':u or when 'Aviso':u or when 'Advertˆncia':u then
                    imErrorSubType:load-image('image/im-mqwar.bmp':u).
                otherwise
                    imErrorSubType:load-image('image/im-mqerr.bmp':u).
            end case.
        end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btOK
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btOK Dialog-Frame
ON CHOOSE OF btOK IN FRAME fPage0 /* OK */
DO:
    APPLY "CLOSE":U TO THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME Dialog-Frame
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame 


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

if can-find(first RowErrors) then do:
    /* Now enable the interface and wait for the exit condition.            */
    /* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
    MAIN-BLOCK:
    DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
       ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
      RUN enable_UI.

      apply 'value-changed':u to brRowErrors.

      WAIT-FOR GO OF FRAME {&FRAME-NAME}.
    END.
    RUN disable_UI.
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI Dialog-Frame  _DEFAULT-DISABLE
PROCEDURE disable_UI :
/*------------------------------------------------------------------------------
  Purpose:     DISABLE the User Interface
  Parameters:  <none>
  Notes:       Here we clean-up the user-interface by deleting
               dynamic widgets we have created and/or hide 
               frames.  This procedure is usually called when
               we are ready to "clean-up" after running.
------------------------------------------------------------------------------*/
  /* Hide all frames. */
  HIDE FRAME Dialog-Frame.
  HIDE FRAME fPage0.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI Dialog-Frame  _DEFAULT-ENABLE
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
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
  DISPLAY edErrorHelp 
      WITH FRAME fPage0.
  ENABLE imErrorSubType rtToolBar brRowErrors edErrorHelp btOK btHelp 
      WITH FRAME fPage0.
  {&OPEN-BROWSERS-IN-QUERY-fPage0}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

