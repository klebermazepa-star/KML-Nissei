&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI ADM1
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME D-Dialog
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS D-Dialog 
/*:T*******************************************************************************
** Copyright TOTVS S.A. (2009)
** Todos os Direitos Reservados.
**
** Este fonte e de propriedade exclusiva da TOTVS, sua reproducao
** parcial ou total por qualquer meio, so podera ser feita mediante
** autorizacao expressa.
*******************************************************************************/
{include/i-prgvrs.i NICR003F 9.99.99.999}

/* Chamada a include do gerenciador de licen‡as. Necessario alterar os parametros */
/*                                                                                */
/* <programa>:  Informar qual o nome do programa.                                 */
/* <m¢dulo>:  Informar qual o m¢dulo a qual o programa pertence.                  */
/*                                                                                */
/* OBS: Para os smartobjects o parametro m¢dulo dever  ser MUT                    */

&IF "{&EMSFND_VERSION}" >= "1.00" &THEN
    {include/i-license-manager.i <programa> MUT}
&ENDIF

/* Create an unnamed pool to store all the widgets created 
     by this procedure. This is a good default which assures
     that this procedure's triggers and internal procedures 
     will execute in this procedure's storage, and that proper
     cleanup will occur on deletion of the procedure. */

CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */
DEFINE INPUT-OUTPUT PARAM c-estab-ini    AS CHARACTER   NO-UNDO.
DEFINE INPUT-OUTPUT PARAM c-estab-fim    AS CHARACTER   NO-UNDO.
DEFINE INPUT-OUTPUT PARAM c-especie-ini  AS CHARACTER   NO-UNDO.
DEFINE INPUT-OUTPUT PARAM c-especie-fim  AS CHARACTER   NO-UNDO.
DEFINE INPUT-OUTPUT PARAM c-serie-ini    AS CHARACTER   NO-UNDO.
DEFINE INPUT-OUTPUT PARAM c-serie-fim    AS CHARACTER   NO-UNDO.
DEFINE INPUT-OUTPUT PARAM c-titulo-ini   AS CHARACTER   NO-UNDO.
DEFINE INPUT-OUTPUT PARAM c-titulo-fim   AS CHARACTER   NO-UNDO.
DEFINE INPUT-OUTPUT PARAM c-data-ini     AS DATE        NO-UNDO.
DEFINE INPUT-OUTPUT PARAM c-data-fim     AS DATE        NO-UNDO.
DEFINE INPUT-OUTPUT PARAM c-venc-ini     AS DATE        NO-UNDO.
DEFINE INPUT-OUTPUT PARAM c-venc-fim     AS DATE        NO-UNDO.
DEFINE OUTPUT       PARAM c-opcao        AS LOGICAL     NO-UNDO.

/* Parameters Definitions ---                                           */

/* Local INPUT-OUTPUT PARAM Definitions ---                                       */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE SmartDialog
&Scoped-define DB-AWARE no

&Scoped-define ADM-CONTAINER DIALOG-BOX

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME D-Dialog

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS rt-buttom RECT-16 IMAGE-1 IMAGE-2 IMAGE-7 ~
IMAGE-8 IMAGE-9 IMAGE-10 IMAGE-11 IMAGE-12 IMAGE-13 IMAGE-14 IMAGE-15 ~
IMAGE-16 fi-estab-ini fi-estab-fim fi-especie-ini fi-especie-fim ~
fi-serie-ini fi-serie-fim fi-titulo-ini fi-titulo-fim fi-data-ini ~
fi-data-fim fi-venc-ini fi-venc-fim bt-ok bt-cancela bt-ajuda 
&Scoped-Define DISPLAYED-OBJECTS fi-estab-ini fi-estab-fim fi-especie-ini ~
fi-especie-fim fi-serie-ini fi-serie-fim fi-titulo-ini fi-titulo-fim ~
fi-data-ini fi-data-fim fi-venc-ini fi-venc-fim 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON bt-ajuda 
     LABEL "&Ajuda" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON bt-cancela AUTO-END-KEY 
     LABEL "&Cancelar" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON bt-ok AUTO-GO 
     LABEL "&OK" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE fi-data-fim AS DATE FORMAT "99/99/9999":U 
     VIEW-AS FILL-IN 
     SIZE 14.43 BY .88 NO-UNDO.

DEFINE VARIABLE fi-data-ini AS DATE FORMAT "99/99/9999":U 
     LABEL "Dt. EmissÆo" 
     VIEW-AS FILL-IN 
     SIZE 14.43 BY .88 NO-UNDO.

DEFINE VARIABLE fi-especie-fim AS CHARACTER FORMAT "X(5)":U 
     VIEW-AS FILL-IN 
     SIZE 9 BY .88 NO-UNDO.

DEFINE VARIABLE fi-especie-ini AS CHARACTER FORMAT "X(5)":U 
     LABEL "Esp‚cie" 
     VIEW-AS FILL-IN 
     SIZE 9 BY .88 NO-UNDO.

DEFINE VARIABLE fi-estab-fim AS CHARACTER FORMAT "X(5)":U 
     VIEW-AS FILL-IN 
     SIZE 9 BY .88 NO-UNDO.

DEFINE VARIABLE fi-estab-ini AS CHARACTER FORMAT "X(5)":U 
     LABEL "Estabelecimento" 
     VIEW-AS FILL-IN 
     SIZE 9 BY .88 NO-UNDO.

DEFINE VARIABLE fi-serie-fim AS CHARACTER FORMAT "X(5)":U 
     VIEW-AS FILL-IN 
     SIZE 9 BY .88 NO-UNDO.

DEFINE VARIABLE fi-serie-ini AS CHARACTER FORMAT "X(5)":U 
     LABEL "S‚rie" 
     VIEW-AS FILL-IN 
     SIZE 9 BY .88 NO-UNDO.

DEFINE VARIABLE fi-titulo-fim AS CHARACTER FORMAT "X(20)":U 
     VIEW-AS FILL-IN 
     SIZE 19 BY .88 NO-UNDO.

DEFINE VARIABLE fi-titulo-ini AS CHARACTER FORMAT "X(20)":U 
     LABEL "T¡tulo" 
     VIEW-AS FILL-IN 
     SIZE 19 BY .88 NO-UNDO.

DEFINE VARIABLE fi-venc-fim AS DATE FORMAT "99/99/9999":U 
     VIEW-AS FILL-IN 
     SIZE 14.43 BY .88 TOOLTIP "Data de Vencimento Final" NO-UNDO.

DEFINE VARIABLE fi-venc-ini AS DATE FORMAT "99/99/9999":U 
     LABEL "Dt. Vencto" 
     VIEW-AS FILL-IN 
     SIZE 14.43 BY .88 TOOLTIP "Data de Vencimento Inicial" NO-UNDO.

DEFINE IMAGE IMAGE-1
     FILENAME "image\im-fir":U
     SIZE 3 BY .88.

DEFINE IMAGE IMAGE-10
     FILENAME "image\im-las":U
     SIZE 3 BY .88.

DEFINE IMAGE IMAGE-11
     FILENAME "image\im-fir":U
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

DEFINE IMAGE IMAGE-15
     FILENAME "image\im-fir":U
     SIZE 3 BY .88.

DEFINE IMAGE IMAGE-16
     FILENAME "image\im-las":U
     SIZE 3 BY .88.

DEFINE IMAGE IMAGE-2
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

DEFINE RECTANGLE RECT-16
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 60 BY 6.71.

DEFINE RECTANGLE rt-buttom
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 59.43 BY 1.42
     BGCOLOR 7 .


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME D-Dialog
     fi-estab-ini AT ROW 1.63 COL 19.86 COLON-ALIGNED WIDGET-ID 50
     fi-estab-fim AT ROW 1.63 COL 36.57 COLON-ALIGNED NO-LABEL WIDGET-ID 52
     fi-especie-ini AT ROW 2.63 COL 19.86 COLON-ALIGNED WIDGET-ID 56
     fi-especie-fim AT ROW 2.63 COL 36.57 COLON-ALIGNED NO-LABEL WIDGET-ID 54
     fi-serie-ini AT ROW 3.58 COL 19.86 COLON-ALIGNED WIDGET-ID 62
     fi-serie-fim AT ROW 3.58 COL 36.57 COLON-ALIGNED NO-LABEL WIDGET-ID 60
     fi-titulo-ini AT ROW 4.58 COL 9.86 COLON-ALIGNED WIDGET-ID 66
     fi-titulo-fim AT ROW 4.58 COL 36.57 COLON-ALIGNED NO-LABEL WIDGET-ID 64
     fi-data-ini AT ROW 5.58 COL 14.29 COLON-ALIGNED WIDGET-ID 70
     fi-data-fim AT ROW 5.58 COL 36.57 COLON-ALIGNED NO-LABEL WIDGET-ID 68
     fi-venc-ini AT ROW 6.54 COL 14.29 COLON-ALIGNED WIDGET-ID 96
     fi-venc-fim AT ROW 6.54 COL 36.57 COLON-ALIGNED NO-LABEL WIDGET-ID 94
     bt-ok AT ROW 8.33 COL 3
     bt-cancela AT ROW 8.33 COL 14
     bt-ajuda AT ROW 8.33 COL 50.14
     rt-buttom AT ROW 8.13 COL 1.57
     RECT-16 AT ROW 1.29 COL 1.43 WIDGET-ID 72
     IMAGE-1 AT ROW 1.63 COL 31.29 WIDGET-ID 74
     IMAGE-2 AT ROW 1.63 COL 35.43 WIDGET-ID 76
     IMAGE-7 AT ROW 2.67 COL 31.29 WIDGET-ID 78
     IMAGE-8 AT ROW 2.67 COL 35.43 WIDGET-ID 80
     IMAGE-9 AT ROW 3.63 COL 31.29 WIDGET-ID 82
     IMAGE-10 AT ROW 3.63 COL 35.43 WIDGET-ID 84
     IMAGE-11 AT ROW 4.63 COL 31.29 WIDGET-ID 88
     IMAGE-12 AT ROW 4.63 COL 35.43 WIDGET-ID 86
     IMAGE-13 AT ROW 5.5 COL 31.29 WIDGET-ID 90
     IMAGE-14 AT ROW 5.5 COL 35.43 WIDGET-ID 92
     IMAGE-15 AT ROW 6.46 COL 31.29 WIDGET-ID 98
     IMAGE-16 AT ROW 6.46 COL 35.43 WIDGET-ID 100
     SPACE(23.70) SKIP(2.36)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Filtro T¡tulo"
         DEFAULT-BUTTON bt-ok WIDGET-ID 100.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: SmartDialog
   Allow: Basic,Browse,DB-Fields,Query,Smart
   Other Settings: COMPILE
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _INCLUDED-LIB D-Dialog 
/* ************************* Included-Libraries *********************** */

{src/adm/method/containr.i}
{include/d-dialog.i}
{utp/ut-glob.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME




/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX D-Dialog
   FRAME-NAME L-To-R                                                    */
ASSIGN 
       FRAME D-Dialog:SCROLLABLE       = FALSE
       FRAME D-Dialog:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX D-Dialog
/* Query rebuild information for DIALOG-BOX D-Dialog
     _Options          = "SHARE-LOCK"
     _Query            is NOT OPENED
*/  /* DIALOG-BOX D-Dialog */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME D-Dialog
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL D-Dialog D-Dialog
ON WINDOW-CLOSE OF FRAME D-Dialog /* Filtro T¡tulo */
DO:  
  /* Add Trigger to equate WINDOW-CLOSE to END-ERROR. */
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-ajuda
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-ajuda D-Dialog
ON CHOOSE OF bt-ajuda IN FRAME D-Dialog /* Ajuda */
OR HELP OF FRAME {&FRAME-NAME}
DO: /* Call Help Function (or a simple message). */
  {include/ajuda.i}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-cancela
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-cancela D-Dialog
ON CHOOSE OF bt-cancela IN FRAME D-Dialog /* Cancelar */
DO:
  ASSIGN c-opcao = NO.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-ok
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-ok D-Dialog
ON CHOOSE OF bt-ok IN FRAME D-Dialog /* OK */
DO:
  ASSIGN c-estab-ini   = INPUT FRAME {&FRAME-NAME} fi-estab-ini
         c-estab-fim   = INPUT FRAME {&FRAME-NAME} fi-estab-fim
         c-especie-ini = INPUT FRAME {&FRAME-NAME} fi-especie-ini
         c-especie-fim = INPUT FRAME {&FRAME-NAME} fi-especie-fim
         c-serie-ini   = INPUT FRAME {&FRAME-NAME} fi-serie-ini
         c-serie-fim   = INPUT FRAME {&FRAME-NAME} fi-serie-fim
         c-titulo-ini  = INPUT FRAME {&FRAME-NAME} fi-titulo-ini
         c-titulo-fim  = INPUT FRAME {&FRAME-NAME} fi-titulo-fim
         c-data-ini    = INPUT FRAME {&FRAME-NAME} fi-data-ini
         c-data-fim    = INPUT FRAME {&FRAME-NAME} fi-data-fim
         c-venc-ini    = INPUT FRAME {&FRAME-NAME} fi-venc-ini
         c-venc-fim    = INPUT FRAME {&FRAME-NAME} fi-venc-fim
         c-opcao       = YES
      .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK D-Dialog 


/* ***************************  Main Block  *************************** */

{src/adm/template/dialogmn.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE adm-create-objects D-Dialog  _ADM-CREATE-OBJECTS
PROCEDURE adm-create-objects :
/*------------------------------------------------------------------------------
  Purpose:     Create handles for all SmartObjects used in this procedure.
               After SmartObjects are initialized, then SmartLinks are added.
  Parameters:  <none>
------------------------------------------------------------------------------*/

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE adm-row-available D-Dialog  _ADM-ROW-AVAILABLE
PROCEDURE adm-row-available :
/*------------------------------------------------------------------------------
  Purpose:     Dispatched to this procedure when the Record-
               Source has a new row available.  This procedure
               tries to get the new row (or foriegn keys) from
               the Record-Source and process it.
  Parameters:  <none>
------------------------------------------------------------------------------*/

  /* Define variables needed by this internal procedure.             */
  {src/adm/template/row-head.i}

  /* Process the newly available records (i.e. display fields,
     open queries, and/or pass records on to any RECORD-TARGETS).    */
  {src/adm/template/row-end.i}

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI D-Dialog  _DEFAULT-DISABLE
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
  HIDE FRAME D-Dialog.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI D-Dialog  _DEFAULT-ENABLE
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
  DISPLAY fi-estab-ini fi-estab-fim fi-especie-ini fi-especie-fim fi-serie-ini 
          fi-serie-fim fi-titulo-ini fi-titulo-fim fi-data-ini fi-data-fim 
          fi-venc-ini fi-venc-fim 
      WITH FRAME D-Dialog.
  ENABLE rt-buttom RECT-16 IMAGE-1 IMAGE-2 IMAGE-7 IMAGE-8 IMAGE-9 IMAGE-10 
         IMAGE-11 IMAGE-12 IMAGE-13 IMAGE-14 IMAGE-15 IMAGE-16 fi-estab-ini 
         fi-estab-fim fi-especie-ini fi-especie-fim fi-serie-ini fi-serie-fim 
         fi-titulo-ini fi-titulo-fim fi-data-ini fi-data-fim fi-venc-ini 
         fi-venc-fim bt-ok bt-cancela bt-ajuda 
      WITH FRAME D-Dialog.
  VIEW FRAME D-Dialog.
  {&OPEN-BROWSERS-IN-QUERY-D-Dialog}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-destroy D-Dialog 
PROCEDURE local-destroy :
/*------------------------------------------------------------------------------
  Purpose:     Override standard ADM method
  Notes:       
------------------------------------------------------------------------------*/

  /* Code placed here will execute PRIOR to standard behavior. */

  /* Dispatch standard ADM method.                             */
  RUN dispatch IN THIS-PROCEDURE ( INPUT 'destroy':U ) .
  {include/i-logfin.i}

  /* Code placed here will execute AFTER standard behavior.    */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-initialize D-Dialog 
PROCEDURE local-initialize :
/*------------------------------------------------------------------------------
  Purpose:     Override standard ADM method
  Notes:       
------------------------------------------------------------------------------*/

  /* Code placed here will execute PRIOR to standard behavior. */

  {utp/ut9000.i "NICR003F" "9.99.99.999"}

  /* Dispatch standard ADM method.                             */
  RUN dispatch IN THIS-PROCEDURE ( INPUT 'initialize':U ) .

  /* Code placed here will execute AFTER standard behavior.    */

  ASSIGN fi-estab-ini:SCREEN-VALUE IN FRAME {&FRAME-NAME} = c-estab-ini  
         fi-estab-fim:SCREEN-VALUE IN FRAME {&FRAME-NAME} = c-estab-fim  
         fi-especie-ini:SCREEN-VALUE IN FRAME {&FRAME-NAME} = c-especie-ini
         fi-especie-fim:SCREEN-VALUE IN FRAME {&FRAME-NAME} = c-especie-fim
         fi-serie-ini:SCREEN-VALUE IN FRAME {&FRAME-NAME} = c-serie-ini  
         fi-serie-fim:SCREEN-VALUE IN FRAME {&FRAME-NAME} = c-serie-fim  
         fi-titulo-ini:SCREEN-VALUE IN FRAME {&FRAME-NAME} = c-titulo-ini 
         fi-titulo-fim:SCREEN-VALUE IN FRAME {&FRAME-NAME} = c-titulo-fim 
         fi-data-ini:SCREEN-VALUE IN FRAME {&FRAME-NAME} = STRING(c-data-ini,"99/99/9999")   
         fi-data-fim:SCREEN-VALUE IN FRAME {&FRAME-NAME} = STRING(c-data-fim,"99/99/9999")
         fi-venc-ini:SCREEN-VALUE IN FRAME {&FRAME-NAME} = STRING(c-venc-ini,"99/99/9999")   
         fi-venc-fim:SCREEN-VALUE IN FRAME {&FRAME-NAME} = STRING(c-venc-fim,"99/99/9999")

      .





END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE send-records D-Dialog  _ADM-SEND-RECORDS
PROCEDURE send-records :
/*------------------------------------------------------------------------------
  Purpose:     Send record ROWID's for all tables used by
               this file.
  Parameters:  see template/snd-head.i
------------------------------------------------------------------------------*/

  /* SEND-RECORDS does nothing because there are no External
     Tables specified for this SmartDialog, and there are no
     tables specified in any contained Browse, Query, or Frame. */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE state-changed D-Dialog 
PROCEDURE state-changed :
/* -----------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
-------------------------------------------------------------*/
  DEFINE INPUT PARAMETER p-issuer-hdl AS HANDLE NO-UNDO.
  DEFINE INPUT PARAMETER p-state AS CHARACTER NO-UNDO.
  
  run pi-trata-state (p-issuer-hdl, p-state).
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

