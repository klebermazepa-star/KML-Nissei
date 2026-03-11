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
{include/i-prgvrs.i NICR009C 9.99.99.999}

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
def new global shared var gr-vale_manual as rowid no-undo.

def new global shared var v_cod_empres_usuar
    as character
    format "x(3)"
    label "Empresa"
    column-label "Empresa"
    no-undo.

DEFINE TEMP-TABLE tt-titulo-movto LIKE tit_acr
    FIELD marca    AS LOGICAL FORMAT "*/ "
    FIELD vl-movto LIKE tit_acr.val_sdo_tit_acr.

DEFINE TEMP-TABLE tt-titulo-movto-aux LIKE tit_acr
    FIELD marca    AS LOGICAL FORMAT "*/ "
    FIELD vl-movto LIKE tit_acr.val_sdo_tit_acr.


/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */

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
&Scoped-define INTERNAL-TABLES tt-titulo-movto-aux

/* Definitions for BROWSE br-titulo                                     */
&Scoped-define FIELDS-IN-QUERY-br-titulo tt-titulo-movto-aux.marca tt-titulo-movto-aux.cod_estab tt-titulo-movto-aux.cod_espec_docto tt-titulo-movto-aux.cod_ser_docto tt-titulo-movto-aux.cod_tit_acr tt-titulo-movto-aux.cod_parcela tt-titulo-movto-aux.cdn_cliente tt-titulo-movto-aux.nom_abrev tt-titulo-movto-aux.val_sdo_tit_acr tt-titulo-movto-aux.vl-movto   
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-titulo tt-titulo-movto-aux.vl-movto ~
VALIDATE(tt-titulo-movto-aux.vl-movto <= tt-titulo-movto-aux.val_sdo_tit_acr, "Valor do movimento deve ser igual ou menor que o saldo do t¡tulo")   
&Scoped-define ENABLED-TABLES-IN-QUERY-br-titulo tt-titulo-movto-aux ~
VALIDATE(tt-titulo-movto-aux
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-br-titulo tt-titulo-movto-aux
&Scoped-define SECOND-ENABLED-TABLE-IN-QUERY-br-titulo VALIDATE(tt-titulo-movto-aux
&Scoped-define SELF-NAME br-titulo
&Scoped-define QUERY-STRING-br-titulo FOR EACH tt-titulo-movto-aux
&Scoped-define OPEN-QUERY-br-titulo OPEN QUERY {&SELF-NAME} FOR EACH tt-titulo-movto-aux.
&Scoped-define TABLES-IN-QUERY-br-titulo tt-titulo-movto-aux
&Scoped-define FIRST-TABLE-IN-QUERY-br-titulo tt-titulo-movto-aux


/* Definitions for DIALOG-BOX D-Dialog                                  */
&Scoped-define OPEN-BROWSERS-IN-QUERY-D-Dialog ~
    ~{&OPEN-QUERY-br-titulo}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS rt-buttom RECT-10 RECT-11 br-titulo ~
bt-inclui bt-elimina bt-ajuda bt-ok bt-cancela 
&Scoped-Define DISPLAYED-OBJECTS fi-cod-empresa fi-nome-empresa ~
fi-matricula fi-nome-func fi-num_vale 

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

DEFINE BUTTON bt-elimina 
     LABEL "&Elimina" 
     SIZE 15 BY .92.

DEFINE BUTTON bt-inclui 
     LABEL "&Incluir" 
     SIZE 15 BY .92.

DEFINE BUTTON bt-ok AUTO-GO 
     LABEL "&OK" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE fi-cod-empresa AS CHARACTER FORMAT "X(5)":U 
     LABEL "Empresa" 
     VIEW-AS FILL-IN 
     SIZE 9 BY .88 NO-UNDO.

DEFINE VARIABLE fi-matricula AS INTEGER FORMAT ">>>>>>>>>9":U INITIAL 0 
     LABEL "Matr¡cula" 
     VIEW-AS FILL-IN 
     SIZE 16 BY .88 NO-UNDO.

DEFINE VARIABLE fi-nome-empresa AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 49.72 BY .88 NO-UNDO.

DEFINE VARIABLE fi-nome-func AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 49.72 BY .88 NO-UNDO.

DEFINE VARIABLE fi-num_vale AS INTEGER FORMAT ">>>>>>>>>9":U INITIAL 0 
     LABEL "Vale" 
     VIEW-AS FILL-IN 
     SIZE 16 BY .88 NO-UNDO.

DEFINE RECTANGLE RECT-10
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 116 BY 3.75.

DEFINE RECTANGLE RECT-11
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 116 BY 13.04.

DEFINE RECTANGLE rt-buttom
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 115.57 BY 1.42
     BGCOLOR 7 .

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-titulo FOR 
      tt-titulo-movto-aux SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-titulo
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-titulo D-Dialog _FREEFORM
  QUERY br-titulo DISPLAY
      tt-titulo-movto-aux.marca COLUMN-LABEL " * "
      tt-titulo-movto-aux.cod_estab
      tt-titulo-movto-aux.cod_espec_docto
      tt-titulo-movto-aux.cod_ser_docto
      tt-titulo-movto-aux.cod_tit_acr WIDTH 15
      tt-titulo-movto-aux.cod_parcela
      tt-titulo-movto-aux.cdn_cliente 
      tt-titulo-movto-aux.nom_abrev   WIDTH 20
      tt-titulo-movto-aux.val_sdo_tit_acr
      tt-titulo-movto-aux.vl-movto COLUMN-LABEL "Valor Movto"
      ENABLE 
      tt-titulo-movto-aux.vl-movto
      VALIDATE(tt-titulo-movto-aux.vl-movto <= tt-titulo-movto-aux.val_sdo_tit_acr, "Valor do movimento deve ser igual ou menor que o saldo do t¡tulo")
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 113.72 BY 11.54 ROW-HEIGHT-CHARS .58 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME D-Dialog
     fi-cod-empresa AT ROW 1.54 COL 28 COLON-ALIGNED WIDGET-ID 6
     fi-nome-empresa AT ROW 1.54 COL 37.29 COLON-ALIGNED NO-LABEL WIDGET-ID 14
     fi-matricula AT ROW 2.5 COL 28 COLON-ALIGNED WIDGET-ID 8
     fi-nome-func AT ROW 2.5 COL 44.29 COLON-ALIGNED NO-LABEL WIDGET-ID 12
     fi-num_vale AT ROW 3.46 COL 28 COLON-ALIGNED WIDGET-ID 10
     br-titulo AT ROW 5.17 COL 2.29 WIDGET-ID 200
     bt-inclui AT ROW 16.83 COL 2.43 WIDGET-ID 16
     bt-elimina AT ROW 16.83 COL 17.57 WIDGET-ID 20
     bt-ajuda AT ROW 18.29 COL 106.14
     bt-ok AT ROW 18.33 COL 2.43
     bt-cancela AT ROW 18.33 COL 13.43
     rt-buttom AT ROW 18.08 COL 1.43
     RECT-10 AT ROW 1.08 COL 1.43 WIDGET-ID 2
     RECT-11 AT ROW 4.96 COL 1.29 WIDGET-ID 4
     SPACE(0.42) SKIP(1.50)
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
/* BROWSE-TAB br-titulo fi-num_vale D-Dialog */
ASSIGN 
       FRAME D-Dialog:SCROLLABLE       = FALSE
       FRAME D-Dialog:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN fi-cod-empresa IN FRAME D-Dialog
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN fi-matricula IN FRAME D-Dialog
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN fi-nome-empresa IN FRAME D-Dialog
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN fi-nome-func IN FRAME D-Dialog
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN fi-num_vale IN FRAME D-Dialog
   NO-ENABLE                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-titulo
/* Query rebuild information for BROWSE br-titulo
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH tt-titulo-movto-aux.
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


&Scoped-define SELF-NAME bt-ajuda
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-ajuda D-Dialog
ON CHOOSE OF bt-ajuda IN FRAME D-Dialog /* Ajuda */
OR HELP OF FRAME {&FRAME-NAME}
DO: /* Call Help Function (or a simple message). */
  {include/ajuda.i}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-elimina
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-elimina D-Dialog
ON CHOOSE OF bt-elimina IN FRAME D-Dialog /* Elimina */
DO:
  IF AVAIL tt-titulo-movto-aux THEN DO:
      DELETE tt-titulo-movto-aux.
      BR-TITULO:REFRESH().
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-inclui
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-inclui D-Dialog
ON CHOOSE OF bt-inclui IN FRAME D-Dialog /* Incluir */
DO:
  RUN intprg/nicr009d.w(OUTPUT TABLE tt-titulo-movto).

  IF CAN-FIND(FIRST tt-titulo-movto) THEN DO:
      FOR EACH tt-titulo-movto:
          CREATE tt-titulo-movto-aux.
          BUFFER-COPY tt-titulo-movto TO tt-titulo-movto-aux.
      END.

      {&OPEN-QUERY-BR-TITULO}
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-ok
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-ok D-Dialog
ON CHOOSE OF bt-ok IN FRAME D-Dialog /* OK */
DO:
   DEFINE VARIABLE iSeq AS INTEGER     NO-UNDO.

  FIND FIRST vale_manual NO-LOCK
       WHERE ROWID(vale_manual) = gr-vale_manual NO-ERROR.
  IF AVAIL vale_manual THEN DO:

      FOR EACH movto_vale_manual
         WHERE movto_vale_manual.num_vale = vale_manual.num_vale:
          DELETE movto_vale_manual.
      END.

      ASSIGN iSeq = 1.
      FOR EACH tt-titulo-movto-aux:

          CREATE movto_vale_manual.
          ASSIGN movto_vale_manual.num_vale       = vale_manual.num_vale
                 movto_vale_manual.seq_movto      = iSeq
                 movto_vale_manual.val_movto      = tt-titulo-movto-aux.vl-movto
                 movto_vale_manual.num_id_tit_acr = tt-titulo-movto-aux.num_id_tit_acr
              .
          ASSIGN iSeq = iSeq + 1.
      END.
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-titulo
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
  DISPLAY fi-cod-empresa fi-nome-empresa fi-matricula fi-nome-func fi-num_vale 
      WITH FRAME D-Dialog.
  ENABLE rt-buttom RECT-10 RECT-11 br-titulo bt-inclui bt-elimina bt-ajuda 
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

  {utp/ut9000.i "NICR009C" "9.99.99.999"}

  /* Dispatch standard ADM method.                             */
  RUN dispatch IN THIS-PROCEDURE ( INPUT 'initialize':U ) .

  /* Code placed here will execute AFTER standard behavior.    */
  RUN pi-mostra-dados.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-mostra-dados D-Dialog 
PROCEDURE pi-mostra-dados :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
FIND FIRST vale_manual NO-LOCK
     WHERE ROWID(vale_manual) = gr-vale_manual NO-ERROR.
IF AVAIL vale_manual THEN DO:
    ASSIGN fi-matricula:SCREEN-VALUE IN FRAME {&FRAME-NAME} = STRING(vale_manual.mat_funcionario)
           fi-num_vale:SCREEN-VALUE  IN FRAME {&FRAME-NAME} = STRING(vale_manual.num_vale).

    FIND FIRST ems5.empresa NO-LOCK
         WHERE empresa.cod_empresa = v_cod_empres_usuar NO-ERROR.
    IF AVAIL empresa THEN DO:
        ASSIGN fi-cod-empresa:SCREEN-VALUE  IN FRAME {&FRAME-NAME} = v_cod_empres_usuar
               fi-nome-empresa:SCREEN-VALUE IN FRAME {&FRAME-NAME} = empresa.nom_razao_social.
    END.

    FIND FIRST VR034FUN NO-LOCK
         WHERE VR034FUN.NUMCAD = INPUT FRAME {&FRAME-NAME} fi-matricula NO-ERROR.
    IF AVAIL VR034FUN THEN DO:
        ASSIGN fi-nome-func:SCREEN-VALUE IN FRAME {&FRAME-NAME} = VR034FUN.NOMFUN.
    END.


    FOR EACH movto_vale_manual
       WHERE movto_vale_manual.num_vale = vale_manual.num_vale,
       FIRST tit_acr
       WHERE tit_acr.num_id_tit_acr = movto_vale_manual.num_id_tit_acr NO-LOCK:

        CREATE tt-titulo-movto-aux.
        BUFFER-COPY tit_acr TO tt-titulo-movto-aux.

        ASSIGN tt-titulo-movto-aux.vl-movto = movto_vale_manual.val_movto
               tt-titulo-movto-aux.marca    = YES.

    END.
    {&OPEN-QUERY-BR-TITULO}

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
  {src/adm/template/snd-list.i "tt-titulo-movto-aux"}

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

