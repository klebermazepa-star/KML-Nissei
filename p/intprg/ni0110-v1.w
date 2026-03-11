&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI ADM1
&ANALYZE-RESUME
/* Connected Databases 
          mgespe           PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS V-table-Win 
/********************************************************************************
** Copyright DATASUL S.A. (1997)
** Todos os Direitos Reservados.
**
** Este fonte e de propriedade exclusiva da DATASUL, sua reproducao
** parcial ou total por qualquer meio, so podera ser feita mediante
** autorizacao expressa.
*******************************************************************************/
{include/i-prgvrs.i NI0110-V01 2.00.00.00}  /*** 010009 ***/

/* Create an unnamed pool to store all the widgets created 
     by this procedure. This is a good default which assures
     that this procedure's triggers and internal procedures 
     will execute in this procedure's storage, and that proper
     cleanup will occur on deletion of the procedure. */

CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */
&Scop adm-attribute-dlg support/viewerd.w

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */
def var v-row-parent as rowid no-undo.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE SmartViewer
&Scoped-define DB-AWARE no

&Scoped-define ADM-SUPPORTED-LINKS Record-Source,Record-Target,TableIO-Target

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME f-main

/* External Tables                                                      */
&Scoped-define EXTERNAL-TABLES int_ds_ger_cupom
&Scoped-define FIRST-EXTERNAL-TABLE int_ds_ger_cupom


/* Need to scope the external tables to this procedure                  */
DEFINE QUERY external_tables FOR int_ds_ger_cupom.
/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS int_ds_ger_cupom.cod_estab_ini_1 ~
int_ds_ger_cupom.cod_estab_fim_1 int_ds_ger_cupom.cod_estab_ini_2 ~
int_ds_ger_cupom.cod_estab_fim_2 int_ds_ger_cupom.cod_estab_ini_3 ~
int_ds_ger_cupom.cod_estab_fim_3 int_ds_ger_cupom.cod_estab_ini_4 ~
int_ds_ger_cupom.cod_estab_fim_4 int_ds_ger_cupom.cod_estab_ini_5 ~
int_ds_ger_cupom.cod_estab_fim_5 int_ds_ger_cupom.cod_estab_ini_6 ~
int_ds_ger_cupom.cod_estab_fim_6 int_ds_ger_cupom.cod_estab_ini_7 ~
int_ds_ger_cupom.cod_estab_fim_7 int_ds_ger_cupom.cod_estab_ini_8 ~
int_ds_ger_cupom.cod_estab_fim_8 int_ds_ger_cupom.cod_estab_ini_9 ~
int_ds_ger_cupom.cod_estab_fim_9 int_ds_ger_cupom.cod_estab_ini_10 ~
int_ds_ger_cupom.cod_estab_fim_10 
&Scoped-define ENABLED-TABLES int_ds_ger_cupom
&Scoped-define FIRST-ENABLED-TABLE int_ds_ger_cupom
&Scoped-Define ENABLED-OBJECTS IMAGE-7 IMAGE-11 IMAGE-12 IMAGE-13 IMAGE-14 ~
IMAGE-15 IMAGE-16 IMAGE-17 IMAGE-18 IMAGE-19 IMAGE-20 IMAGE-21 IMAGE-22 ~
IMAGE-23 IMAGE-24 IMAGE-25 IMAGE-26 IMAGE-27 IMAGE-28 IMAGE-29 RECT-1 
&Scoped-Define DISPLAYED-FIELDS int_ds_ger_cupom.cod_estab_ini_1 ~
int_ds_ger_cupom.cod_estab_fim_1 int_ds_ger_cupom.cod_estab_ini_2 ~
int_ds_ger_cupom.cod_estab_fim_2 int_ds_ger_cupom.cod_estab_ini_3 ~
int_ds_ger_cupom.cod_estab_fim_3 int_ds_ger_cupom.cod_estab_ini_4 ~
int_ds_ger_cupom.cod_estab_fim_4 int_ds_ger_cupom.cod_estab_ini_5 ~
int_ds_ger_cupom.cod_estab_fim_5 int_ds_ger_cupom.cod_estab_ini_6 ~
int_ds_ger_cupom.cod_estab_fim_6 int_ds_ger_cupom.cod_estab_ini_7 ~
int_ds_ger_cupom.cod_estab_fim_7 int_ds_ger_cupom.cod_estab_ini_8 ~
int_ds_ger_cupom.cod_estab_fim_8 int_ds_ger_cupom.cod_estab_ini_9 ~
int_ds_ger_cupom.cod_estab_fim_9 int_ds_ger_cupom.cod_estab_ini_10 ~
int_ds_ger_cupom.cod_estab_fim_10 
&Scoped-define DISPLAYED-TABLES int_ds_ger_cupom
&Scoped-define FIRST-DISPLAYED-TABLE int_ds_ger_cupom


/* Custom List Definitions                                              */
/* ADM-CREATE-FIELDS,ADM-ASSIGN-FIELDS,ADM-MODIFY-FIELDS,List-4,List-5,List-6 */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _XFTR "Foreign Keys" V-table-Win _INLINE
/* Actions: ? adm/support/keyedit.w ? ? ? */
/* STRUCTURED-DATA
<KEY-OBJECT>
THIS-PROCEDURE
</KEY-OBJECT>
<FOREIGN-KEYS>
</FOREIGN-KEYS> 
<EXECUTING-CODE>
**************************
* Set attributes related to FOREIGN KEYS
*/
RUN set-attribute-list (
    'Keys-Accepted = "",
     Keys-Supplied = ""':U).
/**************************
</EXECUTING-CODE> */   

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */
DEFINE IMAGE IMAGE-11
     FILENAME "image\im-las":U
     SIZE 3 BY .88.

DEFINE IMAGE IMAGE-12
     FILENAME "image\im-fir":U
     SIZE 3 BY .88.

DEFINE IMAGE IMAGE-13
     FILENAME "image\im-las":U
     SIZE 3 BY .88.

DEFINE IMAGE IMAGE-14
     FILENAME "image\im-fir":U
     SIZE 3 BY .88.

DEFINE IMAGE IMAGE-15
     FILENAME "image\im-las":U
     SIZE 3 BY .88.

DEFINE IMAGE IMAGE-16
     FILENAME "image\im-fir":U
     SIZE 3 BY .88.

DEFINE IMAGE IMAGE-17
     FILENAME "image\im-las":U
     SIZE 3 BY .88.

DEFINE IMAGE IMAGE-18
     FILENAME "image\im-fir":U
     SIZE 3 BY .88.

DEFINE IMAGE IMAGE-19
     FILENAME "image\im-las":U
     SIZE 3 BY .88.

DEFINE IMAGE IMAGE-20
     FILENAME "image\im-fir":U
     SIZE 3 BY .88.

DEFINE IMAGE IMAGE-21
     FILENAME "image\im-las":U
     SIZE 3 BY .88.

DEFINE IMAGE IMAGE-22
     FILENAME "image\im-fir":U
     SIZE 3 BY .88.

DEFINE IMAGE IMAGE-23
     FILENAME "image\im-las":U
     SIZE 3 BY .88.

DEFINE IMAGE IMAGE-24
     FILENAME "image\im-fir":U
     SIZE 3 BY .88.

DEFINE IMAGE IMAGE-25
     FILENAME "image\im-las":U
     SIZE 3 BY .88.

DEFINE IMAGE IMAGE-26
     FILENAME "image\im-fir":U
     SIZE 3 BY .88.

DEFINE IMAGE IMAGE-27
     FILENAME "image\im-las":U
     SIZE 3 BY .88.

DEFINE IMAGE IMAGE-28
     FILENAME "image\im-fir":U
     SIZE 3 BY .88.

DEFINE IMAGE IMAGE-29
     FILENAME "image\im-las":U
     SIZE 3 BY .88.

DEFINE IMAGE IMAGE-7
     FILENAME "image\im-fir":U
     SIZE 3 BY .88.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 62.72 BY 11.13.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME f-main
     int_ds_ger_cupom.cod_estab_ini_1 AT ROW 1.67 COL 26 COLON-ALIGNED NO-LABEL WIDGET-ID 22
          VIEW-AS FILL-IN 
          SIZE 4 BY .88
     int_ds_ger_cupom.cod_estab_fim_1 AT ROW 1.67 COL 48.43 COLON-ALIGNED NO-LABEL WIDGET-ID 2
          VIEW-AS FILL-IN 
          SIZE 4 BY .88
     int_ds_ger_cupom.cod_estab_ini_2 AT ROW 2.67 COL 26 COLON-ALIGNED NO-LABEL WIDGET-ID 26
          VIEW-AS FILL-IN 
          SIZE 4 BY .88
     int_ds_ger_cupom.cod_estab_fim_2 AT ROW 2.67 COL 48.43 COLON-ALIGNED NO-LABEL WIDGET-ID 6
          VIEW-AS FILL-IN 
          SIZE 4 BY .88
     int_ds_ger_cupom.cod_estab_ini_3 AT ROW 3.67 COL 26 COLON-ALIGNED NO-LABEL WIDGET-ID 28
          VIEW-AS FILL-IN 
          SIZE 4 BY .88
     int_ds_ger_cupom.cod_estab_fim_3 AT ROW 3.67 COL 48.43 COLON-ALIGNED NO-LABEL WIDGET-ID 8
          VIEW-AS FILL-IN 
          SIZE 4 BY .88
     int_ds_ger_cupom.cod_estab_ini_4 AT ROW 4.67 COL 26 COLON-ALIGNED NO-LABEL WIDGET-ID 30
          VIEW-AS FILL-IN 
          SIZE 4 BY .88
     int_ds_ger_cupom.cod_estab_fim_4 AT ROW 4.67 COL 48.43 COLON-ALIGNED NO-LABEL WIDGET-ID 10
          VIEW-AS FILL-IN 
          SIZE 4 BY .88
     int_ds_ger_cupom.cod_estab_ini_5 AT ROW 5.67 COL 26 COLON-ALIGNED NO-LABEL WIDGET-ID 32
          VIEW-AS FILL-IN 
          SIZE 4 BY .88
     int_ds_ger_cupom.cod_estab_fim_5 AT ROW 5.67 COL 48.43 COLON-ALIGNED NO-LABEL WIDGET-ID 12
          VIEW-AS FILL-IN 
          SIZE 4 BY .88
     int_ds_ger_cupom.cod_estab_ini_6 AT ROW 6.67 COL 26 COLON-ALIGNED NO-LABEL WIDGET-ID 34
          VIEW-AS FILL-IN 
          SIZE 4 BY .88
     int_ds_ger_cupom.cod_estab_fim_6 AT ROW 6.67 COL 48.43 COLON-ALIGNED NO-LABEL WIDGET-ID 14
          VIEW-AS FILL-IN 
          SIZE 4 BY .88
     int_ds_ger_cupom.cod_estab_ini_7 AT ROW 7.67 COL 26 COLON-ALIGNED NO-LABEL WIDGET-ID 36
          VIEW-AS FILL-IN 
          SIZE 4 BY .88
     int_ds_ger_cupom.cod_estab_fim_7 AT ROW 7.67 COL 48.43 COLON-ALIGNED NO-LABEL WIDGET-ID 16
          VIEW-AS FILL-IN 
          SIZE 4 BY .88
     int_ds_ger_cupom.cod_estab_ini_8 AT ROW 8.67 COL 26 COLON-ALIGNED NO-LABEL WIDGET-ID 38
          VIEW-AS FILL-IN 
          SIZE 4 BY .88
     int_ds_ger_cupom.cod_estab_fim_8 AT ROW 8.67 COL 48.43 COLON-ALIGNED NO-LABEL WIDGET-ID 18
          VIEW-AS FILL-IN 
          SIZE 4 BY .88
     int_ds_ger_cupom.cod_estab_ini_9 AT ROW 9.67 COL 26 COLON-ALIGNED NO-LABEL WIDGET-ID 40
          VIEW-AS FILL-IN 
          SIZE 4 BY .88
     int_ds_ger_cupom.cod_estab_fim_9 AT ROW 9.67 COL 48.43 COLON-ALIGNED NO-LABEL WIDGET-ID 20
          VIEW-AS FILL-IN 
          SIZE 4 BY .88
     int_ds_ger_cupom.cod_estab_ini_10 AT ROW 10.67 COL 26 COLON-ALIGNED NO-LABEL WIDGET-ID 24
          VIEW-AS FILL-IN 
          SIZE 4 BY .88
     int_ds_ger_cupom.cod_estab_fim_10 AT ROW 10.67 COL 48.43 COLON-ALIGNED NO-LABEL WIDGET-ID 4
          VIEW-AS FILL-IN 
          SIZE 4 BY .88
     "Estabelecimento - Faixa 01:" VIEW-AS TEXT
          SIZE 18.86 BY .88 AT ROW 1.67 COL 9 WIDGET-ID 82
     "Estabelecimento - Faixa 10:" VIEW-AS TEXT
          SIZE 18.86 BY .88 AT ROW 10.67 COL 9 WIDGET-ID 100
     "Estabelecimento - Faixa 09:" VIEW-AS TEXT
          SIZE 18.86 BY .88 AT ROW 9.67 COL 9 WIDGET-ID 98
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1 SCROLLABLE 
         FONT 1.

/* DEFINE FRAME statement is approaching 4K Bytes.  Breaking it up   */
DEFINE FRAME f-main
     "Estabelecimento - Faixa 08:" VIEW-AS TEXT
          SIZE 18.86 BY .88 AT ROW 8.67 COL 9 WIDGET-ID 96
     "Estabelecimento - Faixa 07:" VIEW-AS TEXT
          SIZE 18.86 BY .88 AT ROW 7.67 COL 9 WIDGET-ID 94
     "Estabelecimento - Faixa 06:" VIEW-AS TEXT
          SIZE 18.86 BY .88 AT ROW 6.67 COL 9 WIDGET-ID 92
     "Estabelecimento - Faixa 05:" VIEW-AS TEXT
          SIZE 18.86 BY .88 AT ROW 5.67 COL 9 WIDGET-ID 90
     "Estabelecimento - Faixa 04:" VIEW-AS TEXT
          SIZE 18.86 BY .88 AT ROW 4.67 COL 9 WIDGET-ID 88
     "Estabelecimento - Faixa 03:" VIEW-AS TEXT
          SIZE 18.86 BY .88 AT ROW 3.67 COL 9 WIDGET-ID 86
     "Estabelecimento - Faixa 02:" VIEW-AS TEXT
          SIZE 18.86 BY .88 AT ROW 2.67 COL 9 WIDGET-ID 84
     IMAGE-7 AT ROW 1.67 COL 32.43 WIDGET-ID 44
     IMAGE-11 AT ROW 1.67 COL 47.14 WIDGET-ID 42
     IMAGE-12 AT ROW 2.67 COL 32.43 WIDGET-ID 48
     IMAGE-13 AT ROW 2.67 COL 47.14 WIDGET-ID 46
     IMAGE-14 AT ROW 3.67 COL 32.43 WIDGET-ID 50
     IMAGE-15 AT ROW 3.67 COL 47.14 WIDGET-ID 52
     IMAGE-16 AT ROW 4.67 COL 32.43 WIDGET-ID 54
     IMAGE-17 AT ROW 4.67 COL 47.14 WIDGET-ID 56
     IMAGE-18 AT ROW 5.67 COL 32.43 WIDGET-ID 58
     IMAGE-19 AT ROW 5.67 COL 47.14 WIDGET-ID 60
     IMAGE-20 AT ROW 6.67 COL 32.43 WIDGET-ID 62
     IMAGE-21 AT ROW 6.67 COL 47.14 WIDGET-ID 64
     IMAGE-22 AT ROW 7.67 COL 32.43 WIDGET-ID 66
     IMAGE-23 AT ROW 7.67 COL 47.14 WIDGET-ID 68
     IMAGE-24 AT ROW 8.67 COL 32.43 WIDGET-ID 70
     IMAGE-25 AT ROW 8.67 COL 47.14 WIDGET-ID 72
     IMAGE-26 AT ROW 9.67 COL 32.43 WIDGET-ID 74
     IMAGE-27 AT ROW 9.67 COL 47.14 WIDGET-ID 76
     IMAGE-28 AT ROW 10.67 COL 32.43 WIDGET-ID 78
     IMAGE-29 AT ROW 10.67 COL 47.14 WIDGET-ID 80
     RECT-1 AT ROW 1 COL 1 WIDGET-ID 102
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1 SCROLLABLE 
         FONT 1.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: SmartViewer
   External Tables: mgespe.int_ds_ger_cupom
   Allow: Basic,DB-Fields
   Frames: 1
   Add Fields to: EXTERNAL-TABLES
   Other Settings: PERSISTENT-ONLY
 */

/* This procedure should always be RUN PERSISTENT.  Report the error,  */
/* then cleanup and return.                                            */
IF NOT THIS-PROCEDURE:PERSISTENT THEN DO:
  MESSAGE "{&FILE-NAME} should only be RUN PERSISTENT.":U
          VIEW-AS ALERT-BOX ERROR BUTTONS OK.
  RETURN.
END.

&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
/* DESIGN Window definition (used by the UIB) 
  CREATE WINDOW V-table-Win ASSIGN
         HEIGHT             = 11.13
         WIDTH              = 62.72.
/* END WINDOW DEFINITION */
                                                                        */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _INCLUDED-LIB V-table-Win 
/* ************************* Included-Libraries *********************** */

{src/adm/method/viewer.i}
{include/c-viewer.i}
{utp/ut-glob.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME




/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW V-table-Win
  VISIBLE,,RUN-PERSISTENT                                               */
/* SETTINGS FOR FRAME f-main
   NOT-VISIBLE FRAME-NAME Size-to-Fit                                   */
ASSIGN 
       FRAME f-main:SCROLLABLE       = FALSE
       FRAME f-main:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK FRAME f-main
/* Query rebuild information for FRAME f-main
     _Options          = "NO-LOCK"
     _Query            is NOT OPENED
*/  /* FRAME f-main */
&ANALYZE-RESUME

 


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK V-table-Win 


/* ***************************  Main Block  *************************** */

  &IF DEFINED(UIB_IS_RUNNING) <> 0 &THEN          
    RUN dispatch IN THIS-PROCEDURE ('initialize':U).        
  &ENDIF         

  /************************ INTERNAL PROCEDURES ********************/

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE adm-row-available V-table-Win  _ADM-ROW-AVAILABLE
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

  /* Create a list of all the tables that we need to get.            */
  {src/adm/template/row-list.i "int_ds_ger_cupom"}

  /* Get the record ROWID's from the RECORD-SOURCE.                  */
  {src/adm/template/row-get.i}

  /* FIND each record specified by the RECORD-SOURCE.                */
  {src/adm/template/row-find.i "int_ds_ger_cupom"}

  /* Process the newly available records (i.e. display fields,
     open queries, and/or pass records on to any RECORD-TARGETS).    */
  {src/adm/template/row-end.i}

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI V-table-Win  _DEFAULT-DISABLE
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
  HIDE FRAME f-main.
  IF THIS-PROCEDURE:PERSISTENT THEN DELETE PROCEDURE THIS-PROCEDURE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-assign-record V-table-Win 
PROCEDURE local-assign-record :
/*------------------------------------------------------------------------------
  Purpose:     Override standard ADM method
  Notes:       
------------------------------------------------------------------------------*/

    /* Code placed here will execute PRIOR to standard behavior. */
    {include/i-valid.i}

    /* Ponha na pi-validate todas as valida‡äes */
    /* NÆo gravar nada no registro antes do dispatch do assign-record e 
       nem na PI-validate. */

    /* Dispatch standard ADM method.                             */
    RUN dispatch IN THIS-PROCEDURE ( INPUT 'assign-record':U ) .
    if RETURN-VALUE = 'ADM-ERROR':U then 
        return 'ADM-ERROR':U.

    /* Todos os assignïs nÆo feitos pelo assign-record devem ser feitos aqui */  
    /* Code placed here will execute AFTER standard behavior.    */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-atualiza-parent V-table-Win 
PROCEDURE pi-atualiza-parent :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define input parameter v-row-parent-externo as rowid no-undo.

    assign v-row-parent = v-row-parent-externo.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Pi-validate V-table-Win 
PROCEDURE Pi-validate :
/*------------------------------------------------------------------------------
  Purpose:Validar a viewer     
  Parameters:  <none>
  Notes: NÆo fazer assign aqui. Nesta procedure
  devem ser colocadas apenas valida‡äes, pois neste ponto do programa o registro 
  ainda nÆo foi criado.       
------------------------------------------------------------------------------*/
    {include/i-vldfrm.i} /* Valida‡Æo de dicion rio */

/*/*    Segue um exemplo de valida‡Æo de programa */
 *     find tabela where tabela.campo1 = c-variavel and
 *                       tabela.campo2 > i-variavel no-lock no-error.
 *     
 *     /* Este include deve ser colocado sempre antes do ut-msgs.p */
 *     {include/i-vldprg.i}
 *     run utp/ut-msgs.p (input "show":U, input 7, input return-value).
 *     return 'ADM-ERROR':U.*/

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE send-records V-table-Win  _ADM-SEND-RECORDS
PROCEDURE send-records :
/*------------------------------------------------------------------------------
  Purpose:     Send record ROWID's for all tables used by
               this file.
  Parameters:  see template/snd-head.i
------------------------------------------------------------------------------*/

  /* Define variables needed by this internal procedure.               */
  {src/adm/template/snd-head.i}

  /* For each requested table, put it's ROWID in the output list.      */
  {src/adm/template/snd-list.i "int_ds_ger_cupom"}

  /* Deal with any unexpected table requests before closing.           */
  {src/adm/template/snd-end.i}

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE state-changed V-table-Win 
PROCEDURE state-changed :
/* -----------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
-------------------------------------------------------------*/
  DEFINE INPUT PARAMETER p-issuer-hdl AS HANDLE    NO-UNDO.
  DEFINE INPUT PARAMETER p-state      AS CHARACTER NO-UNDO.

  CASE p-state:
      /* Object instance CASEs can go here to replace standard behavior
         or add new cases. */
      {src/adm/template/vstates.i}
  END CASE.
  run pi-trata-state (p-issuer-hdl, p-state).
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

