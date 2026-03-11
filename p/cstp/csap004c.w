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
DEFINE BUFFER FORMA_pagto FOR ems5.FORMA_pagto.

/* Local Variable Definitions ---                                       */

{cstp/csap004.i}

DEF BUFFER b_portad_bco FOR portad_bco.
DEF BUFFER b-sc-portador  FOR ttPortador.
   
define input-output parameter table for ttPortador.
define input parameter c-portador like ttPortador.cod-portador no-undo.
    
def new global shared var v-rec-tt-portador as recid no-undo.
def new global shared var v_rec_cart_bcia       as recid no-undo.
def new global shared var v_rec_forma_pagto     as recid no-undo.
def new global shared var v_rec_portador        as recid no-undo.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Window
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME DEFAULT-FRAME

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS v-portad bt-sea-4 v-carteira bt-sea-5 ~
v-maximo v-pagto-mesmo bt-sea-6 v-pagto-outro bt-sea-7 BUTTON-1 bt-salva ~
BUTTON-2 classificacao RECT-30 RECT-33 RECT-9 
&Scoped-Define DISPLAYED-OBJECTS v-portad v-desc-portad v-carteira ~
v-desc-carteira v-maximo v-pagto-mesmo v-desc-mesmo v-pagto-outro ~
v-desc-outro classificacao 

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

DEFINE BUTTON bt-sea-4 
     IMAGE-UP FILE "image/im-zoo.bmp":U
     LABEL "zoom" 
     SIZE 3.86 BY 1 TOOLTIP "Zoom".

DEFINE BUTTON bt-sea-5 
     IMAGE-UP FILE "image/im-zoo.bmp":U
     LABEL "zoom" 
     SIZE 3.86 BY 1 TOOLTIP "Zoom".

DEFINE BUTTON bt-sea-6 
     IMAGE-UP FILE "image/im-zoo.bmp":U
     LABEL "zoom" 
     SIZE 3.86 BY 1 TOOLTIP "Zoom".

DEFINE BUTTON bt-sea-7 
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

DEFINE VARIABLE v-carteira AS CHARACTER FORMAT "x(3)" 
     LABEL "Carteira" 
     VIEW-AS FILL-IN 
     SIZE 7.14 BY .88
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE v-desc-carteira AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 36 BY .88 NO-UNDO.

DEFINE VARIABLE v-desc-mesmo AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 28 BY .88 NO-UNDO.

DEFINE VARIABLE v-desc-outro AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 28 BY .88 NO-UNDO.

DEFINE VARIABLE v-desc-portad AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 34 BY .88 NO-UNDO.

DEFINE VARIABLE v-maximo AS DECIMAL FORMAT "->>>,>>>,>>9.99" INITIAL 0 
     LABEL "Vl Maximo p/ Dest." 
     VIEW-AS FILL-IN 
     SIZE 18.29 BY .88
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE v-pagto-mesmo AS CHARACTER FORMAT "X(3)" 
     LABEL "Forma Pagto Mesmo Banco" 
     VIEW-AS FILL-IN 
     SIZE 5 BY .88
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE v-pagto-outro AS CHARACTER FORMAT "X(3)" 
     LABEL "Forma Pagto Outro Banco" 
     VIEW-AS FILL-IN 
     SIZE 5 BY .88
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE v-portad AS CHARACTER FORMAT "x(5)" 
     LABEL "Portador" 
     VIEW-AS FILL-IN 
     SIZE 9.14 BY .88
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE classificacao AS INTEGER 
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS 
          "Valor", 1,
"Quantidade", 2
     SIZE 19 BY .88 TOOLTIP "Classificaá∆o por maior valor ou quantidade" NO-UNDO.

DEFINE RECTANGLE RECT-30
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 80 BY 2.5.

DEFINE RECTANGLE RECT-33
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 80 BY 1.25
     BGCOLOR 18 .

DEFINE RECTANGLE RECT-9
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 80 BY 4.5.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME DEFAULT-FRAME
     v-portad AT ROW 1.25 COL 27 COLON-ALIGNED HELP
          "C¢digo Portador"
     bt-sea-4 AT ROW 1.25 COL 38.29
     v-desc-portad AT ROW 1.25 COL 40.43 COLON-ALIGNED NO-LABEL
     v-carteira AT ROW 2.25 COL 27 COLON-ALIGNED HELP
          "Carteira Banc†ria"
     bt-sea-5 AT ROW 2.25 COL 36.43
     v-desc-carteira AT ROW 2.25 COL 38.43 COLON-ALIGNED NO-LABEL
     v-maximo AT ROW 4.13 COL 27 COLON-ALIGNED HELP
          "Valor M†ximo para Destinaá∆o"
     v-pagto-mesmo AT ROW 5.13 COL 27 COLON-ALIGNED
     bt-sea-6 AT ROW 5.08 COL 34
     v-desc-mesmo AT ROW 5.13 COL 36 COLON-ALIGNED NO-LABEL
     v-pagto-outro AT ROW 6.13 COL 27 COLON-ALIGNED
     bt-sea-7 AT ROW 6.13 COL 34
     v-desc-outro AT ROW 6.13 COL 36 COLON-ALIGNED NO-LABEL
     BUTTON-1 AT ROW 8.67 COL 2.57
     bt-salva AT ROW 8.67 COL 13
     BUTTON-2 AT ROW 8.67 COL 23.43
     classificacao AT ROW 7.13 COL 28.86 NO-LABEL WIDGET-ID 14
     "Classificaá∆o de t°tulos por maior" VIEW-AS TEXT
          SIZE 22.72 BY .54 AT ROW 7.25 COL 6.14 WIDGET-ID 18
     RECT-30 AT ROW 1 COL 1
     RECT-33 AT ROW 8.5 COL 1
     RECT-9 AT ROW 3.75 COL 1
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 80.29 BY 8.83
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
         TITLE              = "Manutená∆o de Portadores destinaá∆o"
         HEIGHT             = 8.83
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
/* SETTINGS FOR FILL-IN v-desc-carteira IN FRAME DEFAULT-FRAME
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN v-desc-mesmo IN FRAME DEFAULT-FRAME
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN v-desc-outro IN FRAME DEFAULT-FRAME
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN v-desc-portad IN FRAME DEFAULT-FRAME
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
ON END-ERROR OF C-Win /* Manutená∆o de Portadores destinaá∆o */
OR ENDKEY OF {&WINDOW-NAME} ANYWHERE DO:
  /* This case occurs when the user presses the "Esc" key.
     In a persistently run window, just ignore this.  If we did not, the
     application would exit. */
  IF THIS-PROCEDURE:PERSISTENT THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL C-Win C-Win
ON ENTRY OF C-Win /* Manutená∆o de Portadores destinaá∆o */
DO:
    FIND first ttPortador 
        where cod-portador = c-portador 
        no-lock NO-ERROR.

    if avail ttPortador then do:
        ASSIGN 
            v-carteira:SCREEN-VALUE IN FRAME {&FRAME-NAME}    = ttPortador.cod-cart-bcia  
            v-portad:SCREEN-VALUE IN FRAME {&FRAME-NAME}      = ttPortador.cod-portador
            v-maximo:SCREEN-VALUE IN FRAME {&FRAME-NAME}      = string(ttPortador.vl-maximo)
            v-pagto-mesmo:SCREEN-VALUE IN FRAME {&FRAME-NAME} = ttPortador.cod-forma-pagto-mesmo 
            v-pagto-outro:SCREEN-VALUE IN FRAME {&FRAME-NAME} = ttPortador.cod-forma-pagto-outro
            classificacao:SCREEN-VALUE IN FRAME {&FRAME-NAME} = string(ttPortador.classificacao).
                    
        FIND FIRST cart_bcia 
            WHERE cart_bcia.cod_cart_bcia = ttPortador.cod-cart-bcia 
            no-lock NO-ERROR.

        IF AVAIL cart_bcia THEN
            ASSIGN 
                v-desc-carteira:SCREEN-VALUE IN FRAME {&FRAME-NAME} = cart_bcia.des_cart_bcia.
               
        FIND FIRST portador 
            WHERE portador.cod_portador = ttPortador.cod-portador 
            no-lock NO-ERROR.

        IF AVAIL portador THEN
            ASSIGN 
                v-desc-portad:SCREEN-VALUE IN FRAME {&FRAME-NAME} = portador.nom_pessoa.
            
        FIND FIRST FORMA_pagto 
            WHERE forma_pagto.cod_forma_pagto = ttPortador.cod-forma-pagto-mesmo 
            no-lock NO-ERROR.

        IF AVAIL FORMA_pagto then
            ASSIGN 
                v-desc-mesmo:SCREEN-VALUE IN FRAME {&FRAME-NAME} = forma_pagto.des_forma_pagto.
            
        FIND FIRST FORMA_pagto 
            WHERE forma_pagto.cod_forma_pagto = ttPortador.cod-forma-pagto-outro 
            no-lock NO-ERROR.

        IF AVAIL FORMA_pagto then
            ASSIGN 
                v-desc-outro:SCREEN-VALUE IN FRAME {&FRAME-NAME} = forma_pagto.des_forma_pagto.

        DISABLE v-carteira v-portad bt-sea-4 bt-sea-5 WITH FRAME {&FRAME-NAME}.
    END.
    else
        ASSIGN 
            v-carteira:SCREEN-VALUE IN FRAME {&FRAME-NAME}    = ""
            v-portad:SCREEN-VALUE IN FRAME {&FRAME-NAME}      = ""
            v-maximo:SCREEN-VALUE IN FRAME {&FRAME-NAME}      = ""
            v-pagto-mesmo:SCREEN-VALUE IN FRAME {&FRAME-NAME} = "BMB"
            v-pagto-outro:SCREEN-VALUE IN FRAME {&FRAME-NAME} = "BOB"
            classificacao:SCREEN-VALUE IN FRAME {&FRAME-NAME} = "1".

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL C-Win C-Win
ON WINDOW-CLOSE OF C-Win /* Manutená∆o de Portadores destinaá∆o */
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
        run validate.
        run save.
    end. 
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-sea-4
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-sea-4 C-Win
ON CHOOSE OF bt-sea-4 IN FRAME DEFAULT-FRAME /* zoom */
DO:
/* run sc0003z.w.  */
    ASSIGN v_rec_portador = ?.

    RUN prgint/ufn/ufn008ka.p.
    IF v_rec_portador <> ? THEN DO:

        FIND portador NO-LOCK
            WHERE RECID(portador) = v_rec_portador NO-ERROR.
        ASSIGN v-portad:SCREEN-VALUE IN FRAME {&FRAME-NAME}      = portador.cod_portador
               v-desc-portad:SCREEN-VALUE IN FRAME {&FRAME-NAME} = portador.nom_pessoa.
    END.
    
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-sea-5
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-sea-5 C-Win
ON CHOOSE OF bt-sea-5 IN FRAME DEFAULT-FRAME /* zoom */
DO:
/* run sc0003z.w.  */
    ASSIGN v_rec_cart_bcia = ?.

    RUN prgint/ufn/ufn012ka.p.
    IF v_rec_cart_bcia <> ? THEN DO:

        FIND cart_bcia NO-LOCK
            WHERE RECID(cart_bcia) = v_rec_cart_bcia NO-ERROR.
        ASSIGN v-carteira:SCREEN-VALUE IN FRAME {&FRAME-NAME}      = cart_bcia.cod_cart_bcia  
               v-desc-carteira:SCREEN-VALUE IN FRAME {&FRAME-NAME} = cart_bcia.des_cart_bcia.
    END.
    
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-sea-6
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-sea-6 C-Win
ON CHOOSE OF bt-sea-6 IN FRAME DEFAULT-FRAME /* zoom */
DO:
/* run sc0003z.w.  */
    ASSIGN v_rec_forma_pagto = ?.

    RUN prgfin/apb/apb005ka.p.
    IF v_rec_forma_pagto <> ? THEN DO:

        FIND forma_pagto NO-LOCK
            WHERE RECID(forma_pagto) = v_rec_forma_pagto NO-ERROR.
        ASSIGN v-pagto-mesmo:SCREEN-VALUE IN FRAME {&FRAME-NAME} = forma_pagto.cod_forma_pagto
               v-desc-mesmo:SCREEN-VALUE IN FRAME {&FRAME-NAME} = forma_pagto.des_forma_pagto.
    END.
    
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-sea-7
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-sea-7 C-Win
ON CHOOSE OF bt-sea-7 IN FRAME DEFAULT-FRAME /* zoom */
DO:
/* run sc0003z.w.  */
    ASSIGN v_rec_forma_pagto = ?.

    RUN prgfin/apb/apb005ka.p.
    IF v_rec_forma_pagto <> ? THEN DO:

        FIND forma_pagto NO-LOCK
            WHERE RECID(forma_pagto) = v_rec_forma_pagto NO-ERROR.
        ASSIGN v-pagto-outro:SCREEN-VALUE IN FRAME {&FRAME-NAME} = forma_pagto.cod_forma_pagto
               v-desc-outro:SCREEN-VALUE IN FRAME {&FRAME-NAME} = forma_pagto.des_forma_pagto.
    END.
    
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME BUTTON-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BUTTON-1 C-Win
ON CHOOSE OF BUTTON-1 IN FRAME DEFAULT-FRAME /* OK */
DO: 
    do {&try}:
        run validate.
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


&Scoped-define SELF-NAME v-carteira
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-carteira C-Win
ON F5 OF v-carteira IN FRAME DEFAULT-FRAME /* Carteira */
DO:
    APPLY "choose" TO bt-sea-5 IN FRAME {&FRAME-NAME}.  
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-carteira C-Win
ON LEAVE OF v-carteira IN FRAME DEFAULT-FRAME /* Carteira */
DO:
    FIND FIRST cart_bcia 
        WHERE cart_bcia.cod_cart_bcia = INPUT FRAME {&FRAME-NAME} v-carteira 
        no-lock NO-ERROR.

    IF AVAIL cart_bcia THEN
        ASSIGN 
            v-desc-carteira:SCREEN-VALUE IN FRAME {&FRAME-NAME} = cart_bcia.des_cart_bcia.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME v-pagto-mesmo
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-pagto-mesmo C-Win
ON F5 OF v-pagto-mesmo IN FRAME DEFAULT-FRAME /* Forma Pagto Mesmo Banco */
DO:
  APPLY "choose" TO bt-sea-6 IN FRAME {&FRAME-NAME}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-pagto-mesmo C-Win
ON LEAVE OF v-pagto-mesmo IN FRAME DEFAULT-FRAME /* Forma Pagto Mesmo Banco */
DO:
    FIND FIRST FORMA_pagto 
        WHERE forma_pagto.cod_forma_pagto = INPUT FRAME {&FRAME-NAME} v-pagto-mesmo 
        no-lock NO-ERROR.
    
    IF AVAIL FORMA_pagto then
        ASSIGN 
            v-desc-mesmo:SCREEN-VALUE IN FRAME {&FRAME-NAME} = forma_pagto.des_forma_pagto.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME v-pagto-outro
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-pagto-outro C-Win
ON F5 OF v-pagto-outro IN FRAME DEFAULT-FRAME /* Forma Pagto Outro Banco */
DO:
    APPLY "choose" TO bt-sea-7 IN FRAME {&FRAME-NAME}.  
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-pagto-outro C-Win
ON LEAVE OF v-pagto-outro IN FRAME DEFAULT-FRAME /* Forma Pagto Outro Banco */
DO:
    FIND FIRST FORMA_pagto 
       WHERE forma_pagto.cod_forma_pagto = INPUT FRAME {&FRAME-NAME} v-pagto-outro 
        no-lock NO-ERROR.

    IF AVAIL FORMA_pagto then
       ASSIGN 
           v-desc-outro:SCREEN-VALUE IN FRAME {&FRAME-NAME} = forma_pagto.des_forma_pagto.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME v-portad
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-portad C-Win
ON F5 OF v-portad IN FRAME DEFAULT-FRAME /* Portador */
DO:
  APPLY "choose" TO bt-sea-4 IN FRAME {&FRAME-NAME}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-portad C-Win
ON LEAVE OF v-portad IN FRAME DEFAULT-FRAME /* Portador */
DO:
    FIND FIRST portador 
        WHERE portador.cod_portador = INPUT FRAME {&FRAME-NAME} v-portad 
        no-lock NO-ERROR.

    IF AVAIL portador THEN
        ASSIGN 
            v-desc-portad:SCREEN-VALUE IN FRAME {&FRAME-NAME} = portador.nom_pessoa.
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
  DISPLAY v-portad v-desc-portad v-carteira v-desc-carteira v-maximo 
          v-pagto-mesmo v-desc-mesmo v-pagto-outro v-desc-outro classificacao 
      WITH FRAME DEFAULT-FRAME IN WINDOW C-Win.
  ENABLE v-portad bt-sea-4 v-carteira bt-sea-5 v-maximo v-pagto-mesmo bt-sea-6 
         v-pagto-outro bt-sea-7 BUTTON-1 bt-salva BUTTON-2 classificacao 
         RECT-30 RECT-33 RECT-9 
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

    FIND FIRST ttPortador 
        where ttPortador.cod-portador = c-portador 
        no-lock NO-ERROR.

    IF AVAIL ttPortador then do:
        ASSIGN ttPortador.vl-maximo = int(v-maximo:SCREEN-VALUE IN FRAME {&FRAME-NAME})
              ttPortador.cod-forma-pagto-mesmo = v-pagto-mesmo:SCREEN-VALUE IN FRAME {&FRAME-NAME}
              ttPortador.cod-forma-pagto-outro = v-pagto-outro:SCREEN-VALUE IN FRAME {&FRAME-NAME}
              ttPortador.classificacao = input frame {&frame-name} classificacao.
    end.
    ELSE DO:
       CREATE ttPortador.
       ASSIGN ttPortador.cod-cart-bcia = v-carteira:SCREEN-VALUE IN FRAME {&FRAME-NAME}
              ttPortador.cod-portador  = v-portad:SCREEN-VALUE IN FRAME {&FRAME-NAME}
              ttPortador.vl-maximo     = int(v-maximo:SCREEN-VALUE IN FRAME {&FRAME-NAME})
              ttPortador.cod-forma-pagto-mesmo = v-pagto-mesmo:SCREEN-VALUE IN FRAME {&FRAME-NAME}
              ttPortador.cod-forma-pagto-outro = v-pagto-outro:SCREEN-VALUE IN FRAME {&FRAME-NAME}
              ttPortador.classificacao = input frame {&frame-name} classificacao
              v-carteira:SCREEN-VALUE IN FRAME {&FRAME-NAME}    = ""
              v-portad:SCREEN-VALUE IN FRAME {&FRAME-NAME}      = ""
              v-maximo:SCREEN-VALUE IN FRAME {&FRAME-NAME}      = "0.00"
              v-pagto-mesmo:SCREEN-VALUE IN FRAME {&FRAME-NAME} = ""
              v-pagto-outro:SCREEN-VALUE IN FRAME {&FRAME-NAME} = ""
              v-desc-carteira:SCREEN-VALUE IN FRAME {&FRAME-NAME} = "" 
              v-desc-mesmo:SCREEN-VALUE IN FRAME {&FRAME-NAME}    = "" 
              v-desc-outro:SCREEN-VALUE IN FRAME {&FRAME-NAME}    = "" 
              v-desc-portad:SCREEN-VALUE IN FRAME {&FRAME-NAME}   = "".
   END.
    

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE validate C-Win 
PROCEDURE validate :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    do {&throws}:
        FIND FIRST portador 
            WHERE portador.cod_portador = INPUT FRAME {&FRAME-NAME} v-portad 
            no-lock NO-ERROR.

        IF NOT AVAIL portador THEN DO:
           MESSAGE "Portador informado n∆o est† cadastrado, favor verificar." VIEW-AS ALERT-BOX ERROR BUTTONS OK.
           APPLY "entry" TO v-portad IN FRAME {&FRAME-NAME}.
           return error.
        END.
    
        FIND FIRST cart_bcia 
           WHERE cart_bcia.cod_cart_bcia = INPUT FRAME {&FRAME-NAME} v-carteira 
            no-lock NO-ERROR.

        IF NOT AVAIL cart_bcia THEN DO:
           MESSAGE "Carteira informada n∆o est† cadastrada, favor verificar!" VIEW-AS ALERT-BOX ERROR BUTTONS OK.
           APPLY "entry" TO v-carteira IN FRAME {&FRAME-NAME}.
           return error.
        END.
        ELSE do:
            IF cart_bcia.ind_tip_cart_bcia <> "Contas a Pagar" THEN DO:
               MESSAGE "Carteira informada deve ser do tipo Contas a Pagar, favor verificar!" VIEW-AS ALERT-BOX ERROR BUTTONS OK.
               APPLY "entry" TO v-carteira IN FRAME {&FRAME-NAME}.
               return error.
            END.
        end.

        if c-portador = ? then do:
            FIND first b-sc-portador 
                WHERE b-sc-portador.cod-portador  = INPUT FRAME {&FRAME-NAME} v-portad 
                  AND b-sc-portador.cod-cart-bcia = INPUT FRAME {&FRAME-NAME} v-carteira 
                no-lock NO-ERROR.

            IF AVAIL b-sc-portador THEN DO:
               MESSAGE "Portador e carteira j† informados anteriormente, favor verificar!" VIEW-AS ALERT-BOX ERROR BUTTONS OK.
               APPLY "entry" TO v-portad IN FRAME {&FRAME-NAME}.
               return error.
            END.
        end.
    
        FIND FIRST FORMA_pagto 
            WHERE forma_pagto.cod_forma_pagto = INPUT FRAME {&FRAME-NAME} v-pagto-mesmo 
            no-lock NO-ERROR.

        IF NOT AVAIL FORMA_pagto THEN DO:
            MESSAGE "Forma de pagamento para mesmo banco n∆o existe, favor verificar!" VIEW-AS ALERT-BOX ERROR BUTTONS OK.
           APPLY "entry" TO v-pagto-mesmo IN FRAME {&FRAME-NAME}.
           return error.
        END.
    
        FIND FIRST FORMA_pagto 
            WHERE forma_pagto.cod_forma_pagto = INPUT FRAME {&FRAME-NAME} v-pagto-outro 
            no-lock NO-ERROR.

        IF NOT AVAIL FORMA_pagto THEN DO:
            MESSAGE "Forma de pagamento para outro banco n∆o existe, favor verificar!" VIEW-AS ALERT-BOX ERROR BUTTONS OK.
           APPLY "entry" TO v-pagto-outro IN FRAME {&FRAME-NAME}.
           return error.
        END.
    
        if input frame {&FRAME-NAME} v-maximo = 0 then do:
           MESSAGE "Valor para destinaá∆o deve ser diferente de zero, favor informar um valor v†lido" VIEW-AS ALERT-BOX WARNING BUTTONS ok.
           apply "entry" to v-maximo in frame {&FRAME-NAME}.
           return error.
        end.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

