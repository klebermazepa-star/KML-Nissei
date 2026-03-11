&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI ADM1
&ANALYZE-RESUME
/* Connected Databases 
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
{include/i-prgvrs.i NICR009D 9.99.99.999}

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
DEFINE TEMP-TABLE tt-titulo-movto LIKE tit_acr
    FIELD marca    AS LOGICAL FORMAT "*/ "
    FIELD vl-movto LIKE tit_acr.val_sdo_tit_acr.

DEFINE OUTPUT PARAM TABLE FOR tt-titulo-movto.
/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */
DEFINE VARIABLE c-estab-ini    AS CHARACTER INITIAL ""              NO-UNDO.
DEFINE VARIABLE c-estab-fim    AS CHARACTER INITIAL "ZZZZZ"         NO-UNDO.
DEFINE VARIABLE c-especie-ini  AS CHARACTER INITIAL ""              NO-UNDO.
DEFINE VARIABLE c-especie-fim  AS CHARACTER INITIAL "ZZZ"           NO-UNDO.
DEFINE VARIABLE c-serie-ini    AS CHARACTER INITIAL ""              NO-UNDO.
DEFINE VARIABLE c-serie-fim    AS CHARACTER INITIAL "ZZZZZ"         NO-UNDO.
DEFINE VARIABLE c-titulo-ini   AS CHARACTER INITIAL ""              NO-UNDO.
DEFINE VARIABLE c-titulo-fim   AS CHARACTER INITIAL "ZZZZZZZZZZZZ"  NO-UNDO.
DEFINE VARIABLE c-data-ini     AS DATE      INITIAL "01/01/2010"    NO-UNDO.
DEFINE VARIABLE c-data-fim     AS DATE      INITIAL "12/31/2999"    NO-UNDO.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE SmartDialog
&Scoped-define DB-AWARE no

&Scoped-define ADM-CONTAINER DIALOG-BOX

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME D-Dialog
&Scoped-define BROWSE-NAME br-titulo

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-titulo-movto

/* Definitions for BROWSE br-titulo                                     */
&Scoped-define FIELDS-IN-QUERY-br-titulo tt-titulo-movto.marca tt-titulo-movto.cod_estab tt-titulo-movto.cod_espec_docto tt-titulo-movto.cod_ser_docto tt-titulo-movto.cod_tit_acr tt-titulo-movto.cod_parcela tt-titulo-movto.cdn_cliente tt-titulo-movto.nom_abrev tt-titulo-movto.val_sdo_tit_acr tt-titulo-movto.vl-movto   
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-titulo tt-titulo-movto.vl-movto   /* VALIDATE( INPUT tt-titulo-movto.vl-movto < tt-titulo-movto.val_sdo_tit_acr, "Valor do movimento deve ser igual ou menor que o saldo do t¡tulo") */ ~
VALIDATE(tt-titulo-movto.vl-movto <= tt-titulo-movto.val_sdo_tit_acr, "Valor do movimento deve ser igual ou menor que o saldo do t¡tulo")   
&Scoped-define ENABLED-TABLES-IN-QUERY-br-titulo tt-titulo-movto ~
VALIDATE(tt-titulo-movto
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-br-titulo tt-titulo-movto
&Scoped-define SECOND-ENABLED-TABLE-IN-QUERY-br-titulo VALIDATE(tt-titulo-movto
&Scoped-define SELF-NAME br-titulo
&Scoped-define QUERY-STRING-br-titulo FOR EACH tt-titulo-movto
&Scoped-define OPEN-QUERY-br-titulo OPEN QUERY {&SELF-NAME} FOR EACH tt-titulo-movto.
&Scoped-define TABLES-IN-QUERY-br-titulo tt-titulo-movto
&Scoped-define FIRST-TABLE-IN-QUERY-br-titulo tt-titulo-movto


/* Definitions for DIALOG-BOX D-Dialog                                  */
&Scoped-define OPEN-BROWSERS-IN-QUERY-D-Dialog ~
    ~{&OPEN-QUERY-br-titulo}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS rt-buttom RECT-11 br-titulo bt-filtro ~
bt-marca bt-desmarca bt-ajuda bt-ok bt-cancela 

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

DEFINE BUTTON bt-desmarca 
     LABEL "Button 7" 
     SIZE 4.72 BY 1.13.

DEFINE BUTTON bt-filtro 
     IMAGE-UP FILE "\\192.168.200.52\datasul\ems2\image\ii-ran.bmp":U
     IMAGE-INSENSITIVE FILE "//192.168.200.52/datasul/ems2/image/ii-ran.bmp":U
     LABEL "Button 5" 
     SIZE 4.72 BY 1.13.

DEFINE BUTTON bt-marca 
     LABEL "Button 6" 
     SIZE 4.72 BY 1.13.

DEFINE BUTTON bt-ok AUTO-GO 
     LABEL "&OK" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE RECTANGLE RECT-11
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 103.57 BY 12.17.

DEFINE RECTANGLE rt-buttom
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 103.57 BY 1.42
     BGCOLOR 7 .

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-titulo FOR 
      tt-titulo-movto SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-titulo
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-titulo D-Dialog _FREEFORM
  QUERY br-titulo DISPLAY
      tt-titulo-movto.marca COLUMN-LABEL " * "
      tt-titulo-movto.cod_estab
      tt-titulo-movto.cod_espec_docto
      tt-titulo-movto.cod_ser_docto
      tt-titulo-movto.cod_tit_acr WIDTH 15
      tt-titulo-movto.cod_parcela
      tt-titulo-movto.cdn_cliente 
      tt-titulo-movto.nom_abrev   WIDTH 20
      tt-titulo-movto.val_sdo_tit_acr
      tt-titulo-movto.vl-movto COLUMN-LABEL "Valor Movto"
      ENABLE 
      tt-titulo-movto.vl-movto
     /* VALIDATE( INPUT tt-titulo-movto.vl-movto < tt-titulo-movto.val_sdo_tit_acr, "Valor do movimento deve ser igual ou menor que o saldo do t¡tulo") */
      VALIDATE(tt-titulo-movto.vl-movto <= tt-titulo-movto.val_sdo_tit_acr, "Valor do movimento deve ser igual ou menor que o saldo do t¡tulo")
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 96.72 BY 11.54 ROW-HEIGHT-CHARS .58 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME D-Dialog
     br-titulo AT ROW 1.42 COL 2.29 WIDGET-ID 200
     bt-filtro AT ROW 1.5 COL 99.43 WIDGET-ID 26
     bt-marca AT ROW 2.67 COL 99.43 WIDGET-ID 28
     bt-desmarca AT ROW 3.83 COL 99.43 WIDGET-ID 34
     bt-ajuda AT ROW 13.58 COL 94
     bt-ok AT ROW 13.63 COL 2.43
     bt-cancela AT ROW 13.63 COL 13.43
     rt-buttom AT ROW 13.38 COL 1.43
     RECT-11 AT ROW 1.08 COL 1.43 WIDGET-ID 4
     SPACE(0.42) SKIP(1.70)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Movimentos Vale Funcion rio"
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
/* BROWSE-TAB br-titulo RECT-11 D-Dialog */
ASSIGN 
       FRAME D-Dialog:SCROLLABLE       = FALSE
       FRAME D-Dialog:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-titulo
/* Query rebuild information for BROWSE br-titulo
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH tt-titulo-movto.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE br-titulo */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX D-Dialog
/* Query rebuild information for DIALOG-BOX D-Dialog
     _Options          = "SHARE-LOCK"
     _Query            is NOT OPENED
*/  /* DIALOG-BOX D-Dialog */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME D-Dialog
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL D-Dialog D-Dialog
ON WINDOW-CLOSE OF FRAME D-Dialog /* Movimentos Vale Funcion rio */
DO:  
  /* Add Trigger to equate WINDOW-CLOSE to END-ERROR. */
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-titulo
&Scoped-define SELF-NAME br-titulo
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-titulo D-Dialog
ON MOUSE-SELECT-DBLCLICK OF br-titulo IN FRAME D-Dialog
DO:
  IF tt-titulo-movto.marca = YES THEN
       ASSIGN tt-titulo-movto.marca  = NO.
  ELSE ASSIGN tt-titulo-movto.marca  = YES.

  br-titulo:REFRESH().
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
  FOR EACH tt-titulo-movto:
      DELETE tt-titulo-movto.
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-filtro
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-filtro D-Dialog
ON CHOOSE OF bt-filtro IN FRAME D-Dialog /* Button 5 */
DO:
  RUN intprg/nicr009f.w(INPUT-OUTPUT c-estab-ini,
                        INPUT-OUTPUT c-estab-fim,
                        INPUT-OUTPUT c-especie-ini,
                        INPUT-OUTPUT c-especie-fim,
                        INPUT-OUTPUT c-serie-ini,
                        INPUT-OUTPUT c-serie-fim,
                        INPUT-OUTPUT c-titulo-ini,
                        INPUT-OUTPUT c-titulo-fim,
                        INPUT-OUTPUT c-data-ini,
                        INPUT-OUTPUT c-data-fim).

  RUN pi-carrega-titulo.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-ok
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-ok D-Dialog
ON CHOOSE OF bt-ok IN FRAME D-Dialog /* OK */
DO:
  FOR EACH tt-titulo-movto 
     WHERE tt-titulo-movto.marca = NO:

      DELETE tt-titulo-movto.

  END.
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
  ENABLE rt-buttom RECT-11 br-titulo bt-filtro bt-marca bt-desmarca bt-ajuda 
         bt-ok bt-cancela 
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

  {utp/ut9000.i "NICR009D" "9.99.99.999"}

  /* Dispatch standard ADM method.                             */
  RUN dispatch IN THIS-PROCEDURE ( INPUT 'initialize':U ) .

  /* Code placed here will execute AFTER standard behavior.    */
  APPLY "CHOOSE" TO bt-filtro IN FRAME {&FRAME-NAME}.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-carrega-titulo D-Dialog 
PROCEDURE pi-carrega-titulo :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

EMPTY TEMP-TABLE tt-titulo-movto.   
        
FOR EACH tit_acr
   WHERE tit_acr.cod_estab        >= c-estab-ini  
     AND tit_acr.cod_estab        <= c-estab-fim  
     AND tit_acr.cod_espec_docto  >= c-especie-ini
     AND tit_acr.cod_espec_docto  <= c-especie-fim
     AND tit_acr.cod_ser_docto    >= c-serie-ini  
     AND tit_acr.cod_ser_docto    <= c-serie-fim  
     AND tit_acr.cod_tit_acr      >= c-titulo-ini 
     AND tit_acr.cod_tit_acr      <= c-titulo-fim 
     AND tit_acr.dat_emis         >= c-data-ini   
     AND tit_acr.dat_emis         <= c-data-fim   
     AND tit_acr.log_sdo_tit_acr  NO-LOCK:

    CREATE tt-titulo-movto.
    BUFFER-COPY tit_acr TO tt-titulo-movto.

END.

{&OPEN-QUERY-BR-TITULO}

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
  {src/adm/template/snd-list.i "tt-titulo-movto"}

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

