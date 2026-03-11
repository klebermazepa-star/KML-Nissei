&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI ADM1
&ANALYZE-RESUME
/* Connected Databases 
          custom           PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS V-table-Win 
/*------------------------------------------------------------------------

  File:

  Description: from VIEWER.W - Template for SmartViewer Objects

  Input Parameters:
      <none>

  Output Parameters:
      <none>

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
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

def var r-registro-atual as rowid no-undo.

def var wh-pesquisa as widget-handle no-undo.
def var l-implanta as logical no-undo.

DEF BUFFER b-int_ds_loja_cond_pag FOR int_ds_loja_cond_pag.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE SmartViewer
&Scoped-define DB-AWARE no

&Scoped-define ADM-SUPPORTED-LINKS Record-Source,Record-Target,TableIO-Target

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME F-Main

/* External Tables                                                      */
&Scoped-define EXTERNAL-TABLES int_ds_loja_cond_pag
&Scoped-define FIRST-EXTERNAL-TABLE int_ds_loja_cond_pag


/* Need to scope the external tables to this procedure                  */
DEFINE QUERY external_tables FOR int_ds_loja_cond_pag.
/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS int_ds_loja_cond_pag.CONVENIO ~
int_ds_loja_cond_pag.COD_COND_PAG int_ds_loja_cond_pag.COD_PORTADOR ~
int_ds_loja_cond_pag.COD_ESP int_ds_loja_cond_pag.cod_emitente 
&Scoped-define ENABLED-TABLES int_ds_loja_cond_pag
&Scoped-define FIRST-ENABLED-TABLE int_ds_loja_cond_pag
&Scoped-Define ENABLED-OBJECTS RECT-20 cb-modalidade 
&Scoped-Define DISPLAYED-FIELDS int_ds_loja_cond_pag.CONVENIO ~
int_ds_loja_cond_pag.CONDIPAG int_ds_loja_cond_pag.COD_COND_PAG ~
int_ds_loja_cond_pag.COD_PORTADOR int_ds_loja_cond_pag.COD_ESP ~
int_ds_loja_cond_pag.cod_emitente 
&Scoped-define DISPLAYED-TABLES int_ds_loja_cond_pag
&Scoped-define FIRST-DISPLAYED-TABLE int_ds_loja_cond_pag
&Scoped-Define DISPLAYED-OBJECTS log-adquirente cCondicao cb-modalidade ~
cPortador cEspecie c-desc-emitente 

/* Custom List Definitions                                              */
/* ADM-CREATE-FIELDS,ADM-ASSIGN-FIELDS,List-3,List-4,List-5,List-6      */
&Scoped-define ADM-CREATE-FIELDS int_ds_loja_cond_pag.CONDIPAG 

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
DEFINE VARIABLE cb-modalidade AS CHARACTER FORMAT "X(40)":U INITIAL "Carteira" 
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEMS "Cb Simples" 
     DROP-DOWN-LIST
     SIZE 16 BY 1 NO-UNDO.

DEFINE VARIABLE c-desc-emitente AS CHARACTER FORMAT "X(40)":U 
     VIEW-AS FILL-IN 
     SIZE 57.43 BY .88 NO-UNDO.

DEFINE VARIABLE cCondicao AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 65 BY .88 NO-UNDO.

DEFINE VARIABLE cEspecie AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 47 BY .88 NO-UNDO.

DEFINE VARIABLE cPortador AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 47 BY .88 NO-UNDO.

DEFINE RECTANGLE RECT-20
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 96 BY 6.21.

DEFINE VARIABLE log-adquirente AS LOGICAL INITIAL no 
     LABEL "Verifica Adquirente CartÆo" 
     VIEW-AS TOGGLE-BOX
     SIZE 20 BY .83 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME F-Main
     int_ds_loja_cond_pag.CONVENIO AT ROW 2 COL 52.43 NO-LABEL WIDGET-ID 134
          VIEW-AS RADIO-SET HORIZONTAL
          RADIO-BUTTONS 
                    "Sim", "S":U,
"Nao", "N":U
          SIZE 13 BY 1
     int_ds_loja_cond_pag.CONDIPAG AT ROW 2.08 COL 19 COLON-ALIGNED WIDGET-ID 110
          LABEL "Cond Pagto PRS" FORMAT "x(3)"
          VIEW-AS FILL-IN 
          SIZE 5.14 BY .88
     log-adquirente AT ROW 2.08 COL 70.57 WIDGET-ID 146
     int_ds_loja_cond_pag.COD_COND_PAG AT ROW 3.04 COL 19 COLON-ALIGNED WIDGET-ID 114
          VIEW-AS FILL-IN 
          SIZE 5 BY .88
     cCondicao AT ROW 3.04 COL 24 COLON-ALIGNED NO-LABEL WIDGET-ID 116
     int_ds_loja_cond_pag.COD_PORTADOR AT ROW 4.08 COL 19 COLON-ALIGNED WIDGET-ID 122
          VIEW-AS FILL-IN 
          SIZE 7 BY .88
     cb-modalidade AT ROW 4.08 COL 26 COLON-ALIGNED NO-LABEL WIDGET-ID 128
     cPortador AT ROW 4.08 COL 42 COLON-ALIGNED NO-LABEL WIDGET-ID 120
     int_ds_loja_cond_pag.COD_ESP AT ROW 5.08 COL 19 COLON-ALIGNED WIDGET-ID 142
          VIEW-AS FILL-IN 
          SIZE 5.14 BY .88
     cEspecie AT ROW 5.08 COL 24.29 COLON-ALIGNED NO-LABEL WIDGET-ID 144
     int_ds_loja_cond_pag.cod_emitente AT ROW 6.13 COL 19 COLON-ALIGNED WIDGET-ID 148
          VIEW-AS FILL-IN 
          SIZE 12 BY .88
     c-desc-emitente AT ROW 6.13 COL 31.57 COLON-ALIGNED NO-LABEL WIDGET-ID 150
     "Convenio:" VIEW-AS TEXT
          SIZE 9 BY .67 AT ROW 2.17 COL 43.43 WIDGET-ID 138
     "Financeiro" VIEW-AS TEXT
          SIZE 9 BY .67 AT ROW 1.25 COL 3 WIDGET-ID 34
     RECT-20 AT ROW 1.54 COL 2 WIDGET-ID 24
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE NO-VALIDATE THREE-D 
         AT COL 1 ROW 1 SCROLLABLE .


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: SmartViewer
   External Tables: mgesp.int_ds_loja_cond_pag
   Allow: Basic,DB-Fields
   Frames: 1
   Add Fields to: EXTERNAL-TABLES
   Other Settings: PERSISTENT-ONLY COMPILE
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
         HEIGHT             = 7.25
         WIDTH              = 97.
/* END WINDOW DEFINITION */
                                                                        */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _INCLUDED-LIB V-table-Win 
/* ************************* Included-Libraries *********************** */

{src/adm/method/viewer.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME




/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW V-table-Win
  VISIBLE,,RUN-PERSISTENT                                               */
/* SETTINGS FOR FRAME F-Main
   NOT-VISIBLE FRAME-NAME Size-to-Fit                                   */
ASSIGN 
       FRAME F-Main:SCROLLABLE       = FALSE
       FRAME F-Main:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN c-desc-emitente IN FRAME F-Main
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN cCondicao IN FRAME F-Main
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN cEspecie IN FRAME F-Main
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN int_ds_loja_cond_pag.CONDIPAG IN FRAME F-Main
   NO-ENABLE 1 EXP-LABEL EXP-FORMAT                                     */
/* SETTINGS FOR FILL-IN cPortador IN FRAME F-Main
   NO-ENABLE                                                            */
/* SETTINGS FOR TOGGLE-BOX log-adquirente IN FRAME F-Main
   NO-ENABLE                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK FRAME F-Main
/* Query rebuild information for FRAME F-Main
     _Options          = "NO-LOCK"
     _Query            is NOT OPENED
*/  /* FRAME F-Main */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME cb-modalidade
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL cb-modalidade V-table-Win
ON VALUE-CHANGED OF cb-modalidade IN FRAME F-Main
DO:
    cPortador:screen-value = "".
    for first mgadm.portador 
        fields (cod-portador nome modalidade)
        no-lock where
        mgadm.portador.cod-portador = input frame {&FRAME-NAME} int_ds_loja_cond_pag.cod_portador and
        mgadm.portador.modalidade = {adinc/i03ad209.i 06 cb-modalidade:screen-value}:
        cb-modalidade:screen-value = {adinc/i03ad209.i 04 mgadm.portador.modalidade}.
        cPortador    :screen-value = portador.nome.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME int_ds_loja_cond_pag.COD_COND_PAG
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL int_ds_loja_cond_pag.COD_COND_PAG V-table-Win
ON F5 OF int_ds_loja_cond_pag.COD_COND_PAG IN FRAME F-Main /* Cond Pagto */
OR MOUSE-SELECT-DBLCLICK OF int_ds_loja_cond_pag.cod_cond_pag in frame {&FRAME-NAME} DO:
        {include/zoomvar.i &prog-zoom=adzoom/z01ad039.w
                                &campo=int_ds_loja_cond_pag.cod_cond_pag
                                &campozoom=cod-cond-pag}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL int_ds_loja_cond_pag.COD_COND_PAG V-table-Win
ON LEAVE OF int_ds_loja_cond_pag.COD_COND_PAG IN FRAME F-Main /* Cond Pagto */
DO:
   /* cCondicao:screen-value in frame {&frame-name} = "".
    for first mgadm.cond-pagto 
        fields (cod-cond-pag descricao)
        no-lock where
        mgadm.cond-pagto.cod-cond-pag = input frame {&FRAME-NAME} int_ds_loja_cond_pag.cod_cond_pag.
        display cond-pagto.descricao @ cCondicao with frame {&FRAME-NAME}.
        for first cst_cond_pagto no-lock where 
            cst_cond_pagto.cod_cond_pag = cond-pagto.cod-cond-pag:
            display cst_cond_pagto.cod_esp @ int_ds_loja_cond_pag.cod_esp with frame {&FRAME-NAME}.
        end.
    end.  */
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME int_ds_loja_cond_pag.cod_emitente
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL int_ds_loja_cond_pag.cod_emitente V-table-Win
ON F5 OF int_ds_loja_cond_pag.cod_emitente IN FRAME F-Main /* Emitente */
DO:
      {include/zoomvar.i &prog-zoom=adzoom/z02ad098.w
                       &campo=int_ds_loja_cond_pag.cod_emitente
                       &campozoom=cod-emitente
                       &campo2=c-desc-emitente
                       &campozoom2=nome-emit}
                       
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL int_ds_loja_cond_pag.cod_emitente V-table-Win
ON LEAVE OF int_ds_loja_cond_pag.cod_emitente IN FRAME F-Main /* Emitente */
DO:
  
    FIND FIRST emitente NO-LOCK
        WHERE emitente.cod-emitente = INT_ds_loja_cond_pag.cod_emitente NO-ERROR.

    IF AVAIL emitente THEN
        ASSIGN c-desc-emitente:SCREEN-VALUE IN FRAME f-main = emitente.nome-emit.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL int_ds_loja_cond_pag.cod_emitente V-table-Win
ON MOUSE-SELECT-DBLCLICK OF int_ds_loja_cond_pag.cod_emitente IN FRAME F-Main /* Emitente */
DO:
      apply "F5" to self.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME int_ds_loja_cond_pag.CONVENIO
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL int_ds_loja_cond_pag.CONVENIO V-table-Win
ON VALUE-CHANGED OF int_ds_loja_cond_pag.CONVENIO IN FRAME F-Main /* Convenio */
DO:
    if int_ds_loja_cond_pag.convenio:screen-value in frame f-Main = "Convenio" then
        assign int_ds_loja_cond_pag.cod_esp:screen-value in frame f-Main = "CV"
               int_ds_loja_cond_pag.cod_portador:screen-value in frame f-Main = "99501"
               cb-modalidade:screen-value in frame f-Main = "Carteira".
    else
        assign int_ds_loja_cond_pag.cod_esp:screen-value in frame f-Main = ""
               int_ds_loja_cond_pag.cod_portador:screen-value in frame f-Main = ""
               cb-modalidade:screen-value in frame f-Main = "Carteira".
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK V-table-Win 


/* ***************************  Main Block  *************************** */

  &IF DEFINED(UIB_IS_RUNNING) <> 0 &THEN          
    RUN dispatch IN THIS-PROCEDURE ('initialize':U).        
  &ENDIF         
  

INT_ds_loja_cond_pag.cod_emitente:LOAD-MOUSE-POINTER("IMAGE/lupa.cur":U) IN FRAME f-main.
  
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
  {src/adm/template/row-list.i "int_ds_loja_cond_pag"}

  /* Get the record ROWID's from the RECORD-SOURCE.                  */
  {src/adm/template/row-get.i}

  /* FIND each record specified by the RECORD-SOURCE.                */
  {src/adm/template/row-find.i "int_ds_loja_cond_pag"}

  /* Process the newly available records (i.e. display fields,
     open queries, and/or pass records on to any RECORD-TARGETS).    */
  {src/adm/template/row-end.i}

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE afterdisplayfields V-table-Win 
PROCEDURE afterdisplayfields :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    FIND FIRST emitente NO-LOCK
        WHERE emitente.cod-emitente = INT_ds_loja_cond_pag.cod_emitente NO-ERROR.

    IF AVAIL emitente THEN
        ASSIGN c-desc-emitente:SCREEN-VALUE IN FRAME f-main = emitente.nome-emit.

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
  HIDE FRAME F-Main.
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
  
  IF  adm-new-record = YES
  THEN DO:
      FIND FIRST b-int_ds_loja_cond_pag NO-LOCK 
          WHERE  b-int_ds_loja_cond_pag.condipag = INPUT FRAME {&FRAME-NAME} int_ds_loja_cond_pag.condipag NO-ERROR.
      IF  AVAIL b-int_ds_loja_cond_pag 
      THEN DO:
          run utp/ut-msgs.p(input "show",
                            input 17006,
                            input ("Condi‡Æo de pagamento j  cadastrada.")).
          return "ADM-ERROR".
      end.
  END.

  if input frame {&FRAME-NAME} int_ds_loja_cond_pag.cod_cond_pag <> 0 and
     not can-find(first cond-pagto no-lock where cond-pagto.cod-cond-pag = input frame {&FRAME-NAME} int_ds_loja_cond_pag.cod_cond_pag)
  then do:
      run utp/ut-msgs.p(input "show",
                        input 17006,
                        input ("Cond. Pagto inv lida!" + "~~" + "Cond. de Pagamento deve estar cadastrada.")).
      return "ADM-ERROR".
  end.
  if input frame {&FRAME-NAME} int_ds_loja_cond_pag.cod_portador = 0 or
     not can-find(first mgadm.portador no-lock where 
                  mgadm.portador.cod-portador = input frame {&FRAME-NAME} int_ds_loja_cond_pag.cod_portador and
                  mgadm.portador.modalidade = {adinc/i03ad209.i 06 cb-modalidade:screen-value})
  then do:
      run utp/ut-msgs.p(input "show",
                        input 17006,
                        input ("Portador inv lido!" + "~~" + "Portador deve estar cadastrado.")).
      return "ADM-ERROR".
  end.

  if input frame {&FRAME-NAME} int_ds_loja_cond_pag.cod_esp = "" or
     not can-find(first esp-doc no-lock where esp-doc.cod-esp = input frame {&FRAME-NAME} int_ds_loja_cond_pag.cod_esp)
  then do:
      run utp/ut-msgs.p(input "show",
                        input 17006,
                        input ("Esp‚cie inv lida!" + "~~" + "Esp‚cie deve existir no cadastro de esp‚cies!")).
      return "ADM-ERROR".
  end.

  /* Dispatch standard ADM method.                             */
  RUN dispatch IN THIS-PROCEDURE ( INPUT 'assign-record':U ) .

  /* Code placed here will execute AFTER standard behavior.    */
  assign cb-modalidade
         int_ds_loja_cond_pag.modalidade = {adinc/i03ad209.i 06 cb-modalidade}.

  ASSIGN int_ds_loja_cond_pag.log_adquirente = INPUT FRAME {&FRAME-NAME} log-adquirente.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-disable-fields V-table-Win 
PROCEDURE local-disable-fields :
/*------------------------------------------------------------------------------
  Purpose:     Override standard ADM method
  Notes:       
------------------------------------------------------------------------------*/

  /* Code placed here will execute PRIOR to standard behavior. */

  /* Dispatch standard ADM method.                             */
  RUN dispatch IN THIS-PROCEDURE ( INPUT 'disable-fields':U ) .

  ASSIGN log-adquirente:SENSITIVE IN FRAME {&FRAME-NAME} = NO.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-display-fields V-table-Win 
PROCEDURE local-display-fields :
/*------------------------------------------------------------------------------
  Purpose:     Override standard ADM method
  Notes:       
------------------------------------------------------------------------------*/

  /* Code placed here will execute PRIOR to standard behavior. */

  /* Dispatch standard ADM method.                             */
  RUN dispatch IN THIS-PROCEDURE ( INPUT 'display-fields':U ) .


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-enable-fields V-table-Win 
PROCEDURE local-enable-fields :
/*------------------------------------------------------------------------------
  Purpose:     Override standard ADM method
  Notes:       
------------------------------------------------------------------------------*/

  /* Code placed here will execute PRIOR to standard behavior. */

  /* Dispatch standard ADM method.                             */
  RUN dispatch IN THIS-PROCEDURE ( INPUT 'enable-fields':U ) .

  ASSIGN log-adquirente:SENSITIVE IN FRAME {&FRAME-NAME} = YES.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-initialize V-table-Win 
PROCEDURE local-initialize :
/*------------------------------------------------------------------------------
  Purpose:     Override standard ADM method
  Notes:       
------------------------------------------------------------------------------*/

  /* Code placed here will execute PRIOR to standard behavior. */

  /* Dispatch standard ADM method.                             */
  RUN dispatch IN THIS-PROCEDURE ( INPUT 'initialize':U ) .

  /* Code placed here will execute AFTER standard behavior.    */
    int_ds_loja_cond_pag.cod_cond_pag:LOAD-MOUSE-POINTER("image/lupa.cur":U) IN FRAME f-Main.
    int_ds_loja_cond_pag.cod_portador:LOAD-MOUSE-POINTER("image/lupa.cur":U) IN FRAME f-Main.
    int_ds_loja_cond_pag.cod_esp:LOAD-MOUSE-POINTER("image/lupa.cur":U) IN FRAME f-Main.

    assign cb-modalidade:list-items = {adinc/i03ad209.i 03}.
    cb-modalidade:screen-value = {adinc/i03ad209.i 04 1}.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-row-available V-table-Win 
PROCEDURE local-row-available :
/*------------------------------------------------------------------------------
  Purpose:     Override standard ADM method
  Notes:       
------------------------------------------------------------------------------*/

  /* Code placed here will execute PRIOR to standard behavior. */

  /* Dispatch standard ADM method.                             */
  RUN dispatch IN THIS-PROCEDURE ( INPUT 'row-available':U ) .

  /* Code placed here will execute AFTER standard behavior.    */
  apply "LEAVE":U to int_ds_loja_cond_pag.cod_cond_pag in frame {&FRAME-NAME}.
  apply "LEAVE":U to int_ds_loja_cond_pag.cod_portador in frame {&FRAME-NAME}.
  apply "LEAVE":U to cb-modalidade in frame {&FRAME-NAME}.
  apply "LEAVE":U to int_ds_loja_cond_pag.cod_esp in frame {&FRAME-NAME}.
  apply "LEAVE":U to int_ds_loja_cond_pag.cod_emitente in frame {&FRAME-NAME}.

  IF NOT AVAIL int_ds_loja_cond_pag THEN
       ASSIGN log-adquirente:SCREEN-VALUE IN FRAME {&FRAME-NAME} = "NO" .
  ELSE IF int_ds_loja_cond_pag.log_adquirente = ?  THEN
       ASSIGN log-adquirente:SCREEN-VALUE IN FRAME {&FRAME-NAME} = "NO" .
  ELSE ASSIGN log-adquirente:SCREEN-VALUE IN FRAME {&FRAME-NAME} = STRING(int_ds_loja_cond_pag.log_adquirente).

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
  {src/adm/template/snd-list.i "int_ds_loja_cond_pag"}

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

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

