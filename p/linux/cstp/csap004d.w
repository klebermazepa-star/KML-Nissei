&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v9r12 GUI
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
{system/Error.i}


/* Parameters Definitions ---                                           */
DEFINE BUFFER fornecedor FOR ems5.fornecedor.

/* Local Variable Definitions ---                                       */

{cstp/csap004.i}
   
define input-output parameter table for ttExcecao.
define input parameter portador as character  no-undo.
define input parameter modalidade as character  no-undo.

def new global shared variable v_cod_empres_usuar as character no-undo.
    
def new global shared var v_rec_fornecedor as recid no-undo.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Window
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME DEFAULT-FRAME

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS BUTTON-1 bt-salva BUTTON-2 btFornecedor ~
fornecedor RECT-30 RECT-33 
&Scoped-Define DISPLAYED-OBJECTS nome fornecedor 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR C-Win AS WIDGET-HANDLE NO-UNDO.

/* Definitions of the field level widgets                               */
DEFINE BUTTON bt-salva 
     LABEL "Salvar" 
     SIZE 10 BY 1 TOOLTIP "Salvar"
     FONT 1.

DEFINE BUTTON btFornecedor 
     IMAGE-UP FILE "image/im-zoo.bmp":U
     LABEL "zoom" 
     SIZE 3.86 BY 1 TOOLTIP "Zoom".

DEFINE BUTTON BUTTON-1 
     LABEL "OK" 
     SIZE 10 BY 1
     FONT 1.

DEFINE BUTTON BUTTON-2 
     LABEL "Cancela" 
     SIZE 10 BY 1
     FONT 1.

DEFINE VARIABLE fornecedor AS INTEGER FORMAT ">>>,>>>,>>9" INITIAL 0 
     LABEL "Fornecedor" 
     VIEW-AS FILL-IN 
     SIZE 13.72 BY .88
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE nome AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 38.29 BY .88 NO-UNDO.

DEFINE RECTANGLE RECT-30
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 80 BY 2.5.

DEFINE RECTANGLE RECT-33
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 80 BY 1.25
     BGCOLOR 18 .


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME DEFAULT-FRAME
     nome AT ROW 1.75 COL 34.72 COLON-ALIGNED NO-LABEL
     BUTTON-1 AT ROW 3.88 COL 2.57
     bt-salva AT ROW 3.88 COL 13
     BUTTON-2 AT ROW 3.88 COL 23.43
     btFornecedor AT ROW 1.67 COL 32.43 WIDGET-ID 20
     fornecedor AT ROW 1.75 COL 31.01 RIGHT-ALIGNED HELP
          "C¢digo Fornecedor" WIDGET-ID 24
     RECT-30 AT ROW 1 COL 1
     RECT-33 AT ROW 3.71 COL 1
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 80.29 BY 4.13
         BGCOLOR 17 FONT 1.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Window
   Allow: Basic,Browse,DB-Fields,Window,Query
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
IF SESSION:DISPLAY-TYPE = "GUI":U THEN
  CREATE WINDOW C-Win ASSIGN
         HIDDEN             = YES
         TITLE              = "Inclus∆o de exceá∆o"
         HEIGHT             = 4.13
         WIDTH              = 80.29
         MAX-HEIGHT         = 16
         MAX-WIDTH          = 81.43
         VIRTUAL-HEIGHT     = 16
         VIRTUAL-WIDTH      = 81.43
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
   FRAME-NAME Custom                                                    */
/* SETTINGS FOR FILL-IN fornecedor IN FRAME DEFAULT-FRAME
   ALIGN-R                                                              */
/* SETTINGS FOR FILL-IN nome IN FRAME DEFAULT-FRAME
   NO-ENABLE                                                            */
IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(C-Win)
THEN C-Win:HIDDEN = no.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK FRAME DEFAULT-FRAME
/* Query rebuild information for FRAME DEFAULT-FRAME
     _Options          = "SHARE-LOCK KEEP-EMPTY"
     _Query            is NOT OPENED
*/  /* FRAME DEFAULT-FRAME */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME C-Win
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL C-Win C-Win
ON END-ERROR OF C-Win /* Inclus∆o de exceá∆o */
OR ENDKEY OF {&WINDOW-NAME} ANYWHERE DO:
  /* This case occurs when the user presses the "Esc" key.
     In a persistently run window, just ignore this.  If we did not, the
     application would exit. */
  IF THIS-PROCEDURE:PERSISTENT THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL C-Win C-Win
ON WINDOW-CLOSE OF C-Win /* Inclus∆o de exceá∆o */
DO:
  /* This event will close the window and terminate the procedure.  */
       
  APPLY "CLOSE":U TO THIS-PROCEDURE.
  RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-salva
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-salva C-Win
ON CHOOSE OF bt-salva IN FRAME DEFAULT-FRAME /* Salvar */
DO: 
    do {&try}:
        run save.
    end. 
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btFornecedor
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btFornecedor C-Win
ON CHOOSE OF btFornecedor IN FRAME DEFAULT-FRAME /* zoom */
DO:
    apply 'f5':u to fornecedor.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME BUTTON-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BUTTON-1 C-Win
ON CHOOSE OF BUTTON-1 IN FRAME DEFAULT-FRAME /* OK */
DO: 
    do {&try}:
        run save.
        
        apply "close" to this-procedure.
    end.         
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME BUTTON-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BUTTON-2 C-Win
ON CHOOSE OF BUTTON-2 IN FRAME DEFAULT-FRAME /* Cancela */
DO:
    apply "close" to this-procedure. 
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME fornecedor
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fornecedor C-Win
ON F5 OF fornecedor IN FRAME DEFAULT-FRAME /* Fornecedor */
DO:
    run prgint/ufn/ufn003nb.p (v_cod_empres_usuar).

    find first fornecedor 
        where recid(fornecedor) = v_rec_fornecedor 
        no-lock no-error.

    if avail fornecedor then do
        with frame {&frame-name}:
        assign 
            fornecedor:screen-value = string(fornecedor.cdn_fornecedor)
            nome:screen-value = string(fornecedor.nom_pessoa).

        apply "entry" to fornecedor.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fornecedor C-Win
ON LEAVE OF fornecedor IN FRAME DEFAULT-FRAME /* Fornecedor */
DO:
    do with frame {&frame-name}:
        find first fornecedor 
            where fornecedor.cdn_fornecedor = fornecedor:input-value
            no-lock no-error.
    
        if avail fornecedor then
            assign 
                nome:screen-value = string(fornecedor.nom_pessoa).
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fornecedor C-Win
ON MOUSE-SELECT-DBLCLICK OF fornecedor IN FRAME DEFAULT-FRAME /* Fornecedor */
DO:
    apply 'f5':u to self.
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
  APPLY "entry" TO {&WINDOW-NAME}.
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
  DISPLAY nome fornecedor 
      WITH FRAME DEFAULT-FRAME IN WINDOW C-Win.
  ENABLE BUTTON-1 bt-salva BUTTON-2 btFornecedor fornecedor RECT-30 RECT-33 
      WITH FRAME DEFAULT-FRAME IN WINDOW C-Win.
  {&OPEN-BROWSERS-IN-QUERY-DEFAULT-FRAME}
  VIEW C-Win.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE save C-Win 
PROCEDURE save :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    do with frame {&frame-name}
        {&throws}:
        find first ttExcecao use-index ie_fornecedor
            where ttExcecao.cdn_fornecedor = fornecedor:input-value
              and ttExcecao.re-tit-ap = ?
            no-lock no-error.

        if avail ttExcecao then do:
            message substitute('Fornecedor &1 ja cadastrado como exceá∆o',
                    fornecedor:input-value)
                view-as alert-box error.
            return error.
        end.

        create ttExcecao.
        assign 
            ttExcecao.cod-portador = portador
            ttExcecao.cod-cart-bcia = modalidade
            ttExcecao.cdn_fornecedor = fornecedor:input-value
            ttExcecao.re-tit-ap = ?.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

