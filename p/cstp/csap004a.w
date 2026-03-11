&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame 
/*------------------------------------------------------------------------

  File: 

  Description: 

  Input parameters:
      <none>

  input-output parameters:
      <none>

  Author: 

  Created: 
------------------------------------------------------------------------*/
/*          This .W file was created with the Progress AppBuilder.       */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* parameters Definitions ---                                           */
DEFINE BUFFER portador FOR ems5.portador.

/* Local Variable Definitions ---                                       */

define input-output parameter p-estab-ini   as character  no-undo.
define input-output parameter p-estab-fim   as character  no-undo.
define input-output parameter p-espec-ini   as character  no-undo.
define input-output parameter p-espec-fim   as character  no-undo.
define input-output parameter p-titulo-ini  as character  no-undo.
define input-output parameter p-titulo-fim  as character  no-undo.
define input-output parameter p-parcela-ini as character  no-undo.
define input-output parameter p-parcela-fim as character  no-undo.
define input-output parameter p-vencto-ini  as date       no-undo.
define input-output parameter p-vencto-fim  as date       no-undo.
define input-output parameter p-emissao-ini as date       no-undo.
define input-output parameter p-emissao-fim as date       no-undo.
define input-output parameter p-portad-ini  as character  no-undo.
define input-output parameter p-portad-fim  as character  no-undo.
define input-output parameter p-fornec-ini  as integer    no-undo.
define input-output parameter p-fornec-fim  as integer    no-undo.
define output parameter doClear as logical initial false no-undo.

def new global shared var v_rec_estabelecimento as recid no-undo.
def new global shared var v_rec_portador        as recid no-undo.
def new global shared var v_rec_fornec_financ   as recid no-undo.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS RECT-2 v-estab-ini bt-sea-2 v-estab-fim ~
bt-sea-3 v-espec-ini v-espec-fim v-titulo-ini v-titulo-fim v-parc-ini ~
v-parc-fim v-vencto-ini v-vencto-fim v-emissao-ini v-emissao-fim ~
v-portad-ini bt-sea-4 v-portad-fim bt-sea-5 v-fornec-ini bt-sea-6 ~
v-fornec-fim bt-sea-7 Btn_OK Btn_Cancel 
&Scoped-Define DISPLAYED-OBJECTS v-estab-ini v-estab-fim v-espec-ini ~
v-espec-fim v-titulo-ini v-titulo-fim v-parc-ini v-parc-fim v-vencto-ini ~
v-vencto-fim v-emissao-ini v-emissao-fim v-portad-ini v-portad-fim ~
v-fornec-ini v-fornec-fim 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON bt-sea-2 
     IMAGE-UP FILE "image/im-zoo.bmp":U
     LABEL "zoom" 
     SIZE 3.86 BY 1 TOOLTIP "Zoom".

DEFINE BUTTON bt-sea-3 
     IMAGE-UP FILE "image/im-zoo.bmp":U
     LABEL "zoom" 
     SIZE 3.86 BY 1 TOOLTIP "Zoom".

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

DEFINE BUTTON Btn_Cancel AUTO-END-KEY 
     LABEL "Cancel" 
     SIZE 11 BY 1.

DEFINE BUTTON Btn_OK AUTO-GO 
     LABEL "OK" 
     SIZE 11 BY 1.

DEFINE VARIABLE v-emissao-fim AS DATE FORMAT "99/99/9999":U INITIAL 12/31/2999 
     LABEL "at‚" 
     VIEW-AS FILL-IN 
     SIZE 11 BY .88
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE v-emissao-ini AS DATE FORMAT "99/99/9999":U INITIAL 01/01/00 
     LABEL "Data EmissÆo" 
     VIEW-AS FILL-IN 
     SIZE 11 BY .88
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE v-espec-fim AS CHARACTER FORMAT "X(3)":U INITIAL "ZZZ" 
     LABEL "at‚" 
     VIEW-AS FILL-IN 
     SIZE 7 BY .88
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE v-espec-ini AS CHARACTER FORMAT "X(3)":U 
     LABEL "Esp‚cie" 
     VIEW-AS FILL-IN 
     SIZE 7 BY .88
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE v-estab-fim AS CHARACTER FORMAT "X(3)":U INITIAL "ZZZ" 
     LABEL "at‚" 
     VIEW-AS FILL-IN 
     SIZE 7 BY .88
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE v-estab-ini AS CHARACTER FORMAT "x(3)" 
     LABEL "Estabelecimento" 
     VIEW-AS FILL-IN 
     SIZE 7 BY .88
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE v-fornec-fim AS INTEGER FORMAT ">>>,>>>,>99":U INITIAL 999999999 
     LABEL "at‚" 
     VIEW-AS FILL-IN 
     SIZE 11 BY .88
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE v-fornec-ini AS INTEGER FORMAT ">>>,>>>,>99" INITIAL 0 
     LABEL "Fornecedor" 
     VIEW-AS FILL-IN 
     SIZE 11 BY .88
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE v-parc-fim AS CHARACTER FORMAT "X(2)":U INITIAL "ZZ" 
     LABEL "at‚" 
     VIEW-AS FILL-IN 
     SIZE 5 BY .88
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE v-parc-ini AS CHARACTER FORMAT "X(2)":U 
     LABEL "Parcela" 
     VIEW-AS FILL-IN 
     SIZE 5 BY .88
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE v-portad-fim AS CHARACTER FORMAT "X(5)":U INITIAL "ZZZZZ" 
     LABEL "at‚" 
     VIEW-AS FILL-IN 
     SIZE 8 BY .88
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE v-portad-ini AS CHARACTER FORMAT "x(5)" 
     LABEL "Portador" 
     VIEW-AS FILL-IN 
     SIZE 8 BY .88
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE v-titulo-fim AS CHARACTER FORMAT "X(10)":U INITIAL "ZZZZZZZZZZ" 
     LABEL "at‚" 
     VIEW-AS FILL-IN 
     SIZE 11 BY .88
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE v-titulo-ini AS CHARACTER FORMAT "x(10)" 
     LABEL "T¡tulo" 
     VIEW-AS FILL-IN 
     SIZE 11 BY .88
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE v-vencto-fim AS DATE FORMAT "99/99/9999":U INITIAL 12/31/2999 
     LABEL "at‚" 
     VIEW-AS FILL-IN 
     SIZE 11 BY .88
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE v-vencto-ini AS DATE FORMAT "99/99/9999":U INITIAL 01/01/00 
     LABEL "Data Vencimento" 
     VIEW-AS FILL-IN 
     SIZE 11 BY .88
     BGCOLOR 15  NO-UNDO.

DEFINE RECTANGLE RECT-2
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 64.14 BY 1.5
     BGCOLOR 18 .


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     v-estab-ini AT ROW 1.25 COL 16 COLON-ALIGNED HELP
          "C¢digo Estabelecimento" WIDGET-ID 24
     bt-sea-2 AT ROW 1.25 COL 25 WIDGET-ID 2
     v-estab-fim AT ROW 1.25 COL 37 COLON-ALIGNED WIDGET-ID 22
     bt-sea-3 AT ROW 1.25 COL 46 WIDGET-ID 4
     v-espec-ini AT ROW 2.25 COL 16 COLON-ALIGNED WIDGET-ID 20
     v-espec-fim AT ROW 2.25 COL 37 COLON-ALIGNED WIDGET-ID 18
     v-titulo-ini AT ROW 3.25 COL 16 COLON-ALIGNED HELP
          "C¢digo T¡tulo" WIDGET-ID 40
     v-titulo-fim AT ROW 3.25 COL 37 COLON-ALIGNED WIDGET-ID 38
     v-parc-ini AT ROW 4.25 COL 16 COLON-ALIGNED WIDGET-ID 32
     v-parc-fim AT ROW 4.25 COL 37 COLON-ALIGNED WIDGET-ID 30
     v-vencto-ini AT ROW 5.25 COL 16 COLON-ALIGNED WIDGET-ID 44
     v-vencto-fim AT ROW 5.25 COL 37 COLON-ALIGNED WIDGET-ID 42
     v-emissao-ini AT ROW 6.25 COL 16 COLON-ALIGNED WIDGET-ID 16
     v-emissao-fim AT ROW 6.25 COL 37 COLON-ALIGNED WIDGET-ID 14
     v-portad-ini AT ROW 7.25 COL 16 COLON-ALIGNED HELP
          "C¢digo Portador" WIDGET-ID 36
     bt-sea-4 AT ROW 7.25 COL 26 WIDGET-ID 6
     v-portad-fim AT ROW 7.25 COL 37 COLON-ALIGNED WIDGET-ID 34
     bt-sea-5 AT ROW 7.25 COL 47 WIDGET-ID 8
     v-fornec-ini AT ROW 8.25 COL 16 COLON-ALIGNED HELP
          "C¢digo Fornecedor" WIDGET-ID 28
     bt-sea-6 AT ROW 8.25 COL 29 WIDGET-ID 10
     v-fornec-fim AT ROW 8.25 COL 37 COLON-ALIGNED WIDGET-ID 26
     bt-sea-7 AT ROW 8.25 COL 50 WIDGET-ID 12
     Btn_OK AT ROW 10 COL 2.43 WIDGET-ID 48
     Btn_Cancel AT ROW 10 COL 14.14 WIDGET-ID 46
     RECT-2 AT ROW 9.75 COL 1.29 WIDGET-ID 50
     SPACE(0.28) SKIP(0.16)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         BGCOLOR 17 FONT 1
         TITLE "Sele‡Æo t¡tulos" WIDGET-ID 100.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
   Allow: Basic,Browse,DB-Fields,Query
   Other Settings: COMPILE
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
ASSIGN 
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Sele‡Æo t¡tulos */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-sea-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-sea-2 Dialog-Frame
ON CHOOSE OF bt-sea-2 IN FRAME Dialog-Frame /* zoom */
DO:
/* run sc0003z.w.  */
    ASSIGN v_rec_estabelecimento = ?.

    RUN prgint/utb/utb071ka.p.
    IF v_rec_estabelecimento <> ? THEN DO:

        FIND estabelecimento NO-LOCK
            WHERE RECID(estabelecimento) = v_rec_estabelecimento NO-ERROR.
        ASSIGN v-estab-ini:SCREEN-VALUE IN FRAME {&FRAME-NAME} = estabelecimento.cod_estab.
    END.
    
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-sea-3
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-sea-3 Dialog-Frame
ON CHOOSE OF bt-sea-3 IN FRAME Dialog-Frame /* zoom */
DO:
/* run sc0003z.w.  */
    ASSIGN v_rec_estabelecimento = ?.

    RUN prgint/utb/utb071ka.p.
    IF v_rec_estabelecimento <> ? THEN DO:

        FIND estabelecimento NO-LOCK
            WHERE RECID(estabelecimento) = v_rec_estabelecimento NO-ERROR.
        ASSIGN v-estab-fim:SCREEN-VALUE IN FRAME {&FRAME-NAME} = estabelecimento.cod_estab.
    END.
    
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-sea-4
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-sea-4 Dialog-Frame
ON CHOOSE OF bt-sea-4 IN FRAME Dialog-Frame /* zoom */
DO:
/* run sc0003z.w.  */
    ASSIGN v_rec_portador = ?.

    RUN prgint/ufn/ufn008ka.p.
    IF v_rec_portador <> ? THEN DO:

        FIND portador NO-LOCK
            WHERE RECID(portador) = v_rec_portador NO-ERROR.
        ASSIGN v-portad-ini:SCREEN-VALUE IN FRAME {&FRAME-NAME} = portador.cod_portador.
    END.
    
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-sea-5
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-sea-5 Dialog-Frame
ON CHOOSE OF bt-sea-5 IN FRAME Dialog-Frame /* zoom */
DO:
/* run sc0003z.w.  */
    ASSIGN v_rec_portador = ?.

    RUN prgint/ufn/ufn008ka.p.
    IF v_rec_portador <> ? THEN DO:

        FIND portador NO-LOCK
            WHERE RECID(portador) = v_rec_portador NO-ERROR.
        ASSIGN v-portad-fim:SCREEN-VALUE IN FRAME {&FRAME-NAME} = portador.cod_portador.
    END.
    
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-sea-6
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-sea-6 Dialog-Frame
ON CHOOSE OF bt-sea-6 IN FRAME Dialog-Frame /* zoom */
DO:
/* run sc0003z.w.  */
    ASSIGN v_rec_fornec_financ = ?.

    RUN prgint/ufn/ufn003ka.p.
    IF v_rec_fornec_financ <> ? THEN DO:

        FIND fornec_financ NO-LOCK
            WHERE RECID(fornec_financ) = v_rec_fornec_financ NO-ERROR.
        ASSIGN v-fornec-ini:SCREEN-VALUE IN FRAME {&FRAME-NAME} = string(fornec_financ.cdn_fornecedor).
    END.
    
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-sea-7
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-sea-7 Dialog-Frame
ON CHOOSE OF bt-sea-7 IN FRAME Dialog-Frame /* zoom */
DO:
/* run sc0003z.w.  */
    ASSIGN v_rec_fornec_financ = ?.

    RUN prgint/ufn/ufn003ka.p.
    IF v_rec_fornec_financ <> ? THEN DO:

        FIND fornec_financ NO-LOCK
            WHERE RECID(fornec_financ) = v_rec_fornec_financ NO-ERROR.
        ASSIGN v-fornec-fim:SCREEN-VALUE IN FRAME {&FRAME-NAME} = string(fornec_financ.cdn_fornecedor).
    END.
    
    
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_OK
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_OK Dialog-Frame
ON CHOOSE OF Btn_OK IN FRAME Dialog-Frame /* OK */
DO:
    message 'Todos os t¡tulos ja calculados serÆo apagados' skip
            'Confirma a nova sele‡Æo?'
        view-as alert-box question buttons yes-no
        title "Aviso" update doClear.

    assign p-estab-ini   = input frame {&frame-name} v-estab-ini 
           p-estab-fim   = input frame {&frame-name} v-estab-fim
           p-espec-ini   = input frame {&frame-name} v-espec-ini 
           p-espec-fim   = input frame {&frame-name} v-espec-fim 
           p-titulo-ini  = input frame {&frame-name} v-titulo-ini 
           p-titulo-fim  = input frame {&frame-name} v-titulo-fim 
           p-parcela-ini = input frame {&frame-name} v-parc-ini 
           p-parcela-fim = input frame {&frame-name} v-parc-fim 
           p-vencto-ini  = input frame {&frame-name} v-vencto-ini 
           p-vencto-fim  = input frame {&frame-name} v-vencto-fim 
           p-emissao-ini = input frame {&frame-name} v-emissao-ini 
           p-emissao-fim = input frame {&frame-name} v-emissao-fim   
           p-portad-ini  = input frame {&frame-name} v-portad-ini 
           p-portad-fim  = input frame {&frame-name} v-portad-fim 
           p-fornec-ini  = input frame {&frame-name} v-fornec-ini 
           p-fornec-fim  = input frame {&frame-name} v-fornec-fim.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame 


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  RUN enable_UI.

  run populateFields.

  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

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
  DISPLAY v-estab-ini v-estab-fim v-espec-ini v-espec-fim v-titulo-ini 
          v-titulo-fim v-parc-ini v-parc-fim v-vencto-ini v-vencto-fim 
          v-emissao-ini v-emissao-fim v-portad-ini v-portad-fim v-fornec-ini 
          v-fornec-fim 
      WITH FRAME Dialog-Frame.
  ENABLE RECT-2 v-estab-ini bt-sea-2 v-estab-fim bt-sea-3 v-espec-ini 
         v-espec-fim v-titulo-ini v-titulo-fim v-parc-ini v-parc-fim 
         v-vencto-ini v-vencto-fim v-emissao-ini v-emissao-fim v-portad-ini 
         bt-sea-4 v-portad-fim bt-sea-5 v-fornec-ini bt-sea-6 v-fornec-fim 
         bt-sea-7 Btn_OK Btn_Cancel 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE populateFields Dialog-Frame 
PROCEDURE populateFields :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    do with frame {&frame-name}:
        assign
            v-estab-ini:screen-value    = p-estab-ini  
            v-estab-fim:screen-value    = p-estab-fim  
            v-espec-ini:screen-value    = p-espec-ini  
            v-espec-fim:screen-value    = p-espec-fim
            v-titulo-ini:screen-value   = p-titulo-ini 
            v-titulo-fim:screen-value   = p-titulo-fim 
            v-parc-ini:screen-value     = p-parcela-ini
            v-parc-fim:screen-value     = p-parcela-fim
            v-vencto-ini:screen-value   = string(p-vencto-ini) 
            v-vencto-fim:screen-value   = string(p-vencto-fim) 
            v-emissao-ini:screen-value  = string(p-emissao-ini)
            v-emissao-fim:screen-value  = string(p-emissao-fim)
            v-portad-ini:screen-value   = p-portad-ini 
            v-portad-fim:screen-value   = p-portad-fim 
            v-fornec-ini:screen-value   = string(p-fornec-ini) 
            v-fornec-fim:screen-value   = string(p-fornec-fim).
    end.
    
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

