&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME C-Win
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS C-Win 
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
/*          This .W file was created with the Progress AppBuilder.      */
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

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Window
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME DEFAULT-FRAME

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS RECT-1 RECT-2 fi-serie rs-opcao fi-nota ~
fi-emitente bt-ok bt-fechar 
&Scoped-Define DISPLAYED-OBJECTS fi-serie rs-opcao fi-nota fi-emitente 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR C-Win AS WIDGET-HANDLE NO-UNDO.

/* Definitions of the field level widgets                               */
DEFINE BUTTON bt-fechar 
     LABEL "Fechar" 
     SIZE 15 BY 1.13
     FONT 1.

DEFINE BUTTON bt-ok 
     LABEL "OK" 
     SIZE 15 BY 1.13
     FONT 1.

DEFINE VARIABLE fi-emitente AS INTEGER FORMAT "->,>>>,>>9":U INITIAL 0 
     LABEL "Emitente" 
     VIEW-AS FILL-IN 
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE fi-nota AS CHARACTER FORMAT "X(256)":U 
     LABEL "Nota" 
     VIEW-AS FILL-IN 
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE fi-serie AS CHARACTER FORMAT "X(256)":U 
     LABEL "S‚rie" 
     VIEW-AS FILL-IN 
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE rs-opcao AS INTEGER 
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS 
          "Passar para Atualizado", 1,
"Passar para Liberado", 2
     SIZE 23 BY 3.25
     FONT 1 NO-UNDO.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 28 BY 3.75.

DEFINE RECTANGLE RECT-2
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 54 BY 1.75.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME DEFAULT-FRAME
     fi-serie AT ROW 1.5 COL 9 COLON-ALIGNED WIDGET-ID 2
     rs-opcao AT ROW 1.5 COL 30 NO-LABEL WIDGET-ID 6
     fi-nota AT ROW 2.75 COL 9 COLON-ALIGNED WIDGET-ID 4
     fi-emitente AT ROW 4.04 COL 9 COLON-ALIGNED WIDGET-ID 18
     bt-ok AT ROW 5.67 COL 3 WIDGET-ID 14
     bt-fechar AT ROW 5.67 COL 19.43 WIDGET-ID 16
     RECT-1 AT ROW 1.25 COL 28 WIDGET-ID 10
     RECT-2 AT ROW 5.25 COL 2 WIDGET-ID 12
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 77.72 BY 15.42 WIDGET-ID 100.


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
  CREATE WINDOW C-Win ASSIGN
         HIDDEN             = YES
         TITLE              = "Altera Status Int002"
         HEIGHT             = 6.38
         WIDTH              = 56.43
         MAX-HEIGHT         = 16
         MAX-WIDTH          = 80
         VIRTUAL-HEIGHT     = 16
         VIRTUAL-WIDTH      = 80
         RESIZE             = yes
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
/* SETTINGS FOR WINDOW C-Win
  VISIBLE,,RUN-PERSISTENT                                               */
/* SETTINGS FOR FRAME DEFAULT-FRAME
   FRAME-NAME                                                           */
IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(C-Win)
THEN C-Win:HIDDEN = no.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME C-Win
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL C-Win C-Win
ON END-ERROR OF C-Win /* Altera Status Int002 */
OR ENDKEY OF {&WINDOW-NAME} ANYWHERE DO:
  /* This case occurs when the user presses the "Esc" key.
     In a persistently run window, just ignore this.  If we did not, the
     application would exit. */
  IF THIS-PROCEDURE:PERSISTENT THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL C-Win C-Win
ON WINDOW-CLOSE OF C-Win /* Altera Status Int002 */
DO:
  /* This event will close the window and terminate the procedure.  */
  APPLY "CLOSE":U TO THIS-PROCEDURE.
  RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-fechar
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-fechar C-Win
ON CHOOSE OF bt-fechar IN FRAME DEFAULT-FRAME /* Fechar */
DO:
  APPLY 'close' TO THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-ok
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-ok C-Win
ON CHOOSE OF bt-ok IN FRAME DEFAULT-FRAME /* OK */
DO:
  
    IF rs-opcao:SCREEN-VALUE = '1' THEN
    DO:

        FOR EACH int-ds-docto-xml WHERE
                 int(int-ds-docto-xml.nnf) = int(fi-nota:SCREEN-VALUE)  AND
                 int-ds-docto-xml.serie    = fi-serie:SCREEN-VALUE      AND 
                 int-ds-docto-xml.situacao = 2, /* 1 - Pendente, 2 - Liberado, 3 - Atualizado */
            FIRST emitente NO-LOCK WHERE   
                  emitente.cgc           = int-ds-docto-xml.CNPJ AND 
                  emitente.cod-emitente  = int(fi-emitente:SCREEN-VALUE):

           
           FOR EACH int-ds-it-docto-xml WHERE 
                    int-ds-it-docto-xml.serie          =  int-ds-docto-xml.serie         AND
                    int-ds-it-docto-xml.nNF            =  int-ds-docto-xml.nNF           AND
                    int-ds-it-docto-xml.cod-emitente   =  int-ds-docto-xml.cod-emitente  AND
                    int-ds-it-docto-xml.tipo-nota      =  int-ds-docto-xml.tipo-nota     AND
                    int-ds-it-docto-xml.situacao       =  2 /* 1 - Pendente, 2 - Liberado, 3 - Atualizado */ :       

               ASSIGN int-ds-it-docto-xml.situacao = 3. /* 1 - Pendente, 2 - Liberado, 3 - Atualizado */


           END.

           ASSIGN  int-ds-docto-xml.situacao = 3. /* 1 - Pendente, 2 - Liberado, 3 - Atualizado */
           MESSAGE 'Alterado de Liberado para Atualizado' VIEW-AS ALERT-BOX.

        END.
    END.
    IF rs-opcao:SCREEN-VALUE = '2' THEN
    DO:
        FOR EACH int-ds-docto-xml WHERE
                 int(int-ds-docto-xml.nnf) = int(fi-nota:SCREEN-VALUE)  AND
                 int-ds-docto-xml.serie    = fi-serie:SCREEN-VALUE      AND 
                 int-ds-docto-xml.situacao = 3, /* 1 - Pendente, 2 - Liberado, 3 - Atualizado */
            FIRST emitente NO-LOCK WHERE   
                  emitente.cgc           = int-ds-docto-xml.CNPJ AND 
                  emitente.cod-emitente  = int(fi-emitente:SCREEN-VALUE):

           FOR EACH int-ds-it-docto-xml WHERE 
                    int-ds-it-docto-xml.serie          =  int-ds-docto-xml.serie         AND
                    int-ds-it-docto-xml.nNF            =  int-ds-docto-xml.nNF           AND
                    int-ds-it-docto-xml.cod-emitente   =  int-ds-docto-xml.cod-emitente  AND
                    int-ds-it-docto-xml.tipo-nota      =  int-ds-docto-xml.tipo-nota     AND
                    int-ds-it-docto-xml.situacao       =  3 /* 1 - Pendente, 2 - Liberado, 3 - Atualizado */ :       

               ASSIGN int-ds-it-docto-xml.situacao = 2. /* 1 - Pendente, 2 - Liberado, 3 - Atualizado */


           END.

           ASSIGN  int-ds-docto-xml.situacao = 2. /* 1 - Pendente, 2 - Liberado, 3 - Atualizado */

           MESSAGE 'Alterado de Atualizado para Liberado' VIEW-AS ALERT-BOX.
        END.
    END.

      
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK C-Win 


/* ***************************  Main Block  *************************** */

/* Set CURRENT-WINDOW: this will parent dialog-boxes and frames.        */
ASSIGN CURRENT-WINDOW                = {&WINDOW-NAME} 
       THIS-PROCEDURE:CURRENT-WINDOW = {&WINDOW-NAME}.

/* The CLOSE event can be used from inside or outside the procedure to  */
/* terminate it.                                                        */
ON CLOSE OF THIS-PROCEDURE 
   RUN disable_UI.

/* Best default for GUI applications is...                              */
PAUSE 0 BEFORE-HIDE.

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  RUN enable_UI.
  IF NOT THIS-PROCEDURE:PERSISTENT THEN
    WAIT-FOR CLOSE OF THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI C-Win  _DEFAULT-DISABLE
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
  IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(C-Win)
  THEN DELETE WIDGET C-Win.
  IF THIS-PROCEDURE:PERSISTENT THEN DELETE PROCEDURE THIS-PROCEDURE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI C-Win  _DEFAULT-ENABLE
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
  DISPLAY fi-serie rs-opcao fi-nota fi-emitente 
      WITH FRAME DEFAULT-FRAME IN WINDOW C-Win.
  ENABLE RECT-1 RECT-2 fi-serie rs-opcao fi-nota fi-emitente bt-ok bt-fechar 
      WITH FRAME DEFAULT-FRAME IN WINDOW C-Win.
  {&OPEN-BROWSERS-IN-QUERY-DEFAULT-FRAME}
  VIEW C-Win.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

