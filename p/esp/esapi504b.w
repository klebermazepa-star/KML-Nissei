&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI ADM1
&ANALYZE-RESUME
/* Connected Databases 
          mgesp            PROGRESS
*/
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
{include/i-prgvrs.i ESAPI504B TOTVS}

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

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */

DEF INPUT PARAM rwRec AS ROWID NO-UNDO.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE SmartDialog
&Scoped-define DB-AWARE no

&Scoped-define ADM-CONTAINER DIALOG-BOX

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME D-Dialog

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES es-api-log

/* Definitions for DIALOG-BOX D-Dialog                                  */
&Scoped-define FIELDS-IN-QUERY-D-Dialog es-api-log.dh-request ~
es-api-log.Origem es-api-log.dh-envio es-api-log.end-envio ~
es-api-log.envio-content-type es-api-log.envio-headers ~
es-api-log.envio-params es-api-log.dh-retorno es-api-log.cod-retorno ~
es-api-log.retorno-content-type es-api-log.retorno-headers 
&Scoped-define ENABLED-FIELDS-IN-QUERY-D-Dialog es-api-log.dh-request ~
es-api-log.Origem es-api-log.dh-envio es-api-log.end-envio ~
es-api-log.envio-content-type es-api-log.envio-headers ~
es-api-log.envio-params es-api-log.dh-retorno es-api-log.cod-retorno ~
es-api-log.retorno-content-type es-api-log.retorno-headers 
&Scoped-define ENABLED-TABLES-IN-QUERY-D-Dialog es-api-log
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-D-Dialog es-api-log
&Scoped-define QUERY-STRING-D-Dialog FOR EACH es-api-log SHARE-LOCK
&Scoped-define OPEN-QUERY-D-Dialog OPEN QUERY D-Dialog FOR EACH es-api-log SHARE-LOCK.
&Scoped-define TABLES-IN-QUERY-D-Dialog es-api-log
&Scoped-define FIRST-TABLE-IN-QUERY-D-Dialog es-api-log


/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS es-api-log.dh-request es-api-log.Origem ~
es-api-log.dh-envio es-api-log.end-envio es-api-log.envio-content-type ~
es-api-log.envio-headers es-api-log.envio-params es-api-log.dh-retorno ~
es-api-log.cod-retorno es-api-log.retorno-content-type ~
es-api-log.retorno-headers 
&Scoped-define ENABLED-TABLES es-api-log
&Scoped-define FIRST-ENABLED-TABLE es-api-log
&Scoped-Define ENABLED-OBJECTS rt-buttom bt-ok 
&Scoped-Define DISPLAYED-FIELDS es-api-log.dh-request es-api-log.Origem ~
es-api-log.dh-envio es-api-log.end-envio es-api-log.envio-content-type ~
es-api-log.envio-headers es-api-log.envio-params es-api-log.dh-retorno ~
es-api-log.cod-retorno es-api-log.retorno-content-type ~
es-api-log.retorno-headers 
&Scoped-define DISPLAYED-TABLES es-api-log
&Scoped-define FIRST-DISPLAYED-TABLE es-api-log


/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON bt-ok AUTO-GO 
     LABEL "&OK" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE RECTANGLE rt-buttom
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 134.57 BY 1.42
     BGCOLOR 7 .

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY D-Dialog FOR 
      es-api-log SCROLLING.
&ANALYZE-RESUME

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME D-Dialog
     es-api-log.dh-request AT ROW 1.08 COL 27 COLON-ALIGNED WIDGET-ID 8
          LABEL "Request" FORMAT "99/99/9999 HH:MM:SS"
          VIEW-AS FILL-IN 
          SIZE 28 BY 1
     es-api-log.Origem AT ROW 2.21 COL 27 COLON-ALIGNED WIDGET-ID 22
          VIEW-AS FILL-IN 
          SIZE 28 BY 1
     es-api-log.dh-envio AT ROW 3.29 COL 27 COLON-ALIGNED WIDGET-ID 6 FORMAT "99/99/9999 HH:MM:SS"
          VIEW-AS FILL-IN 
          SIZE 28 BY 1
     es-api-log.end-envio AT ROW 4.5 COL 29 NO-LABEL WIDGET-ID 36
          VIEW-AS EDITOR SCROLLBAR-VERTICAL
          SIZE 108 BY 2.21
     es-api-log.envio-content-type AT ROW 6.83 COL 27 COLON-ALIGNED WIDGET-ID 14
          LABEL "Content-Type Envio"
          VIEW-AS FILL-IN 
          SIZE 28 BY 1
     es-api-log.envio-headers AT ROW 8.04 COL 29 NO-LABEL WIDGET-ID 32
          VIEW-AS EDITOR SCROLLBAR-VERTICAL
          SIZE 108 BY 4
     es-api-log.envio-params AT ROW 12.21 COL 29 NO-LABEL WIDGET-ID 38
          VIEW-AS EDITOR SCROLLBAR-VERTICAL
          SIZE 108 BY 4
     es-api-log.dh-retorno AT ROW 16.5 COL 27 COLON-ALIGNED WIDGET-ID 10
          LABEL "Retorno" FORMAT "99/99/9999 HH:MM:SS"
          VIEW-AS FILL-IN 
          SIZE 28 BY 1
     es-api-log.cod-retorno AT ROW 17.63 COL 27 COLON-ALIGNED WIDGET-ID 4
          LABEL "C¢digo Retorno"
          VIEW-AS FILL-IN 
          SIZE 28 BY 1
     es-api-log.retorno-content-type AT ROW 18.75 COL 27 COLON-ALIGNED WIDGET-ID 24
          VIEW-AS FILL-IN 
          SIZE 28 BY 1
     es-api-log.retorno-headers AT ROW 20.13 COL 29.29 NO-LABEL WIDGET-ID 44
          VIEW-AS EDITOR SCROLLBAR-VERTICAL
          SIZE 108 BY 4
     bt-ok AT ROW 24.54 COL 3.29
     "Header de Retorno:" VIEW-AS TEXT
          SIZE 14 BY .67 AT ROW 20.04 COL 15.29 WIDGET-ID 42
     "Parƒmetros:" VIEW-AS TEXT
          SIZE 7.86 BY .67 AT ROW 12.08 COL 20.29 WIDGET-ID 40
     "Header de Envio:" VIEW-AS TEXT
          SIZE 12 BY .67 AT ROW 8.04 COL 16.72 WIDGET-ID 34
     "Endere‡o de Envio:" VIEW-AS TEXT
          SIZE 13.86 BY .67 AT ROW 4.54 COL 15.14 WIDGET-ID 30
     rt-buttom AT ROW 24.29 COL 2.72
     SPACE(0.84) SKIP(0.11)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         FONT 1
         TITLE "<insert SmartDialog title>"
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

/* SETTINGS FOR FILL-IN es-api-log.cod-retorno IN FRAME D-Dialog
   EXP-LABEL                                                            */
ASSIGN 
       es-api-log.cod-retorno:READ-ONLY IN FRAME D-Dialog        = TRUE.

/* SETTINGS FOR FILL-IN es-api-log.dh-envio IN FRAME D-Dialog
   EXP-FORMAT                                                           */
ASSIGN 
       es-api-log.dh-envio:READ-ONLY IN FRAME D-Dialog        = TRUE.

/* SETTINGS FOR FILL-IN es-api-log.dh-request IN FRAME D-Dialog
   EXP-LABEL EXP-FORMAT                                                 */
ASSIGN 
       es-api-log.dh-request:READ-ONLY IN FRAME D-Dialog        = TRUE.

/* SETTINGS FOR FILL-IN es-api-log.dh-retorno IN FRAME D-Dialog
   EXP-LABEL EXP-FORMAT                                                 */
ASSIGN 
       es-api-log.dh-retorno:READ-ONLY IN FRAME D-Dialog        = TRUE.

ASSIGN 
       es-api-log.end-envio:READ-ONLY IN FRAME D-Dialog        = TRUE.

/* SETTINGS FOR FILL-IN es-api-log.envio-content-type IN FRAME D-Dialog
   EXP-LABEL                                                            */
ASSIGN 
       es-api-log.envio-content-type:READ-ONLY IN FRAME D-Dialog        = TRUE.

ASSIGN 
       es-api-log.envio-headers:READ-ONLY IN FRAME D-Dialog        = TRUE.

ASSIGN 
       es-api-log.envio-params:READ-ONLY IN FRAME D-Dialog        = TRUE.

ASSIGN 
       es-api-log.Origem:READ-ONLY IN FRAME D-Dialog        = TRUE.

ASSIGN 
       es-api-log.retorno-content-type:READ-ONLY IN FRAME D-Dialog        = TRUE.

ASSIGN 
       es-api-log.retorno-headers:READ-ONLY IN FRAME D-Dialog        = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX D-Dialog
/* Query rebuild information for DIALOG-BOX D-Dialog
     _TblList          = "mgesp.es-api-log"
     _Options          = "SHARE-LOCK"
     _Query            is NOT OPENED
*/  /* DIALOG-BOX D-Dialog */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME D-Dialog
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL D-Dialog D-Dialog
ON WINDOW-CLOSE OF FRAME D-Dialog /* <insert SmartDialog title> */
DO:  
  /* Add Trigger to equate WINDOW-CLOSE to END-ERROR. */
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-ok
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
  IF AVAILABLE es-api-log THEN 
    DISPLAY es-api-log.dh-request es-api-log.Origem es-api-log.dh-envio 
          es-api-log.end-envio es-api-log.envio-content-type 
          es-api-log.envio-headers es-api-log.envio-params es-api-log.dh-retorno 
          es-api-log.cod-retorno es-api-log.retorno-content-type 
          es-api-log.retorno-headers 
      WITH FRAME D-Dialog.
  ENABLE rt-buttom es-api-log.dh-request es-api-log.Origem es-api-log.dh-envio 
         es-api-log.end-envio es-api-log.envio-content-type 
         es-api-log.envio-headers es-api-log.envio-params es-api-log.dh-retorno 
         es-api-log.cod-retorno es-api-log.retorno-content-type 
         es-api-log.retorno-headers bt-ok 
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

  {utp/ut9000.i "ESAPI504B" "TOTVS"}

  /* Dispatch standard ADM method.                             */
  RUN dispatch IN THIS-PROCEDURE ( INPUT 'initialize':U ) .

  /* Code placed here will execute AFTER standard behavior.    */

  FOR FIRST es-api-log NO-LOCK
      WHERE ROWID(es-api-log) = rwRec:
     DISP
        es-api-log.cod-retorno 
        es-api-log.end-envio
        es-api-log.dh-envio 
        es-api-log.dh-request 
        es-api-log.dh-retorno 
        es-api-log.envio-content-type 
        es-api-log.envio-headers 
        es-api-log.envio-params 
        es-api-log.Origem 
        es-api-log.retorno-content-type
        es-api-log.retorno-headers
        WITH FRAME D-Dialog.
  END.

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

  /* Define variables needed by this internal procedure.               */
  {src/adm/template/snd-head.i}

  /* For each requested table, put it's ROWID in the output list.      */
  {src/adm/template/snd-list.i "es-api-log"}

  /* Deal with any unexpected table requests before closing.           */
  {src/adm/template/snd-end.i}

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

