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
{include/i-prgvrs.i NI0102-V1 2.00.00.000}  /*** 020004 ***/

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
&Scop adm-attribute-dlg support/viewerd.w

/* global variable definitions */
def new global shared var v-row-parent as rowid no-undo.                                
/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */
def buffer b-int_ds_fornecedor_linha for int_ds_fornecedor_linha.

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
&Scoped-define EXTERNAL-TABLES int_ds_fornecedor_linha
&Scoped-define FIRST-EXTERNAL-TABLE int_ds_fornecedor_linha


/* Need to scope the external tables to this procedure                  */
DEFINE QUERY external_tables FOR int_ds_fornecedor_linha.
/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS int_ds_fornecedor_linha.stnopreco ~
int_ds_fornecedor_linha.tipo_trib 
&Scoped-define ENABLED-TABLES int_ds_fornecedor_linha
&Scoped-define FIRST-ENABLED-TABLE int_ds_fornecedor_linha
&Scoped-Define ENABLED-OBJECTS rt-key rt-mold 
&Scoped-Define DISPLAYED-FIELDS int_ds_fornecedor_linha.cod_emitente ~
int_ds_fornecedor_linha.linha int_ds_fornecedor_linha.stnopreco ~
int_ds_fornecedor_linha.tipo_trib 
&Scoped-define DISPLAYED-TABLES int_ds_fornecedor_linha
&Scoped-define FIRST-DISPLAYED-TABLE int_ds_fornecedor_linha
&Scoped-Define DISPLAYED-OBJECTS c-nome-fornec c-label-cd-acao 

/* Custom List Definitions                                              */
/* ADM-CREATE-FIELDS,ADM-ASSIGN-FIELDS,ADM-MODIFY-FIELDS,List-4,List-5,List-6 */
&Scoped-define ADM-CREATE-FIELDS int_ds_fornecedor_linha.cod_emitente ~
int_ds_fornecedor_linha.linha 

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
DEFINE VARIABLE c-label-cd-acao AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 14 BY .63 NO-UNDO.

DEFINE VARIABLE c-nome-fornec AS CHARACTER FORMAT "X(50)":U 
     VIEW-AS FILL-IN 
     SIZE 50 BY .88 NO-UNDO.

DEFINE RECTANGLE rt-key
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 88.57 BY 2.5.

DEFINE RECTANGLE rt-mold
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 88.57 BY 2.33.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME f-main
     int_ds_fornecedor_linha.cod_emitente AT ROW 1.38 COL 24.72 COLON-ALIGNED WIDGET-ID 12
          VIEW-AS FILL-IN 
          SIZE 10 BY .88
     c-nome-fornec AT ROW 1.38 COL 34.86 COLON-ALIGNED NO-LABEL WIDGET-ID 10
     int_ds_fornecedor_linha.linha AT ROW 2.38 COL 24.72 COLON-ALIGNED WIDGET-ID 14
          VIEW-AS COMBO-BOX 
          LIST-ITEMS "01 - Medicamentos","02 - Perfumaria","03 - Conveniància","04 - Serviáos","05 - Manipulaá∆o","06 - Consumo","07 - Manutená∆o" 
          DROP-DOWN-LIST
          SIZE 18 BY 1
          FONT 4
     int_ds_fornecedor_linha.stnopreco AT ROW 3.88 COL 36 NO-LABEL WIDGET-ID 16
          VIEW-AS RADIO-SET HORIZONTAL
          RADIO-BUTTONS 
                    "Sim", 1,
"N∆o", 2
          SIZE 14.86 BY .88
          FONT 4
     int_ds_fornecedor_linha.tipo_trib AT ROW 4.88 COL 36 NO-LABEL WIDGET-ID 20
          VIEW-AS RADIO-SET HORIZONTAL
          RADIO-BUTTONS 
                    "Substitu°da", 1,
"Substituta", 2
          SIZE 23.72 BY .88
          FONT 4
     c-label-cd-acao AT ROW 5 COL 19.57 COLON-ALIGNED NO-LABEL
     "Substituiá∆o Tribut†ria:" VIEW-AS TEXT
          SIZE 15.86 BY .88 AT ROW 3.88 COL 20 WIDGET-ID 26
          FONT 4
     "Tipo Tributaá∆o:" VIEW-AS TEXT
          SIZE 11.57 BY .88 AT ROW 4.88 COL 24.43 WIDGET-ID 28
          FONT 4
     rt-key AT ROW 1.13 COL 1
     rt-mold AT ROW 3.71 COL 1
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1 SCROLLABLE .


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: SmartViewer
   External Tables: mgespe.int_ds_fornecedor_linha
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
         HEIGHT             = 5.04
         WIDTH              = 88.57.
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

/* SETTINGS FOR FILL-IN c-label-cd-acao IN FRAME f-main
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN c-nome-fornec IN FRAME f-main
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN int_ds_fornecedor_linha.cod_emitente IN FRAME f-main
   NO-ENABLE 1                                                          */
/* SETTINGS FOR COMBO-BOX int_ds_fornecedor_linha.linha IN FRAME f-main
   NO-ENABLE 1                                                          */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK FRAME f-main
/* Query rebuild information for FRAME f-main
     _Options          = "NO-LOCK"
     _Query            is NOT OPENED
*/  /* FRAME f-main */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME int_ds_fornecedor_linha.cod_emitente
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL int_ds_fornecedor_linha.cod_emitente V-table-Win
ON F5 OF int_ds_fornecedor_linha.cod_emitente IN FRAME f-main /* Fornecedor */
DO:
   {include/zoomvar.i &prog-zoom=adzoom/z01ad098.w
                      &campo=int_ds_fornecedor_linha.cod_emitente
                      &campozoom=cod-emitente
                      &campo2=c-nome-fornec
                      &campozoom2=nome-emit}

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL int_ds_fornecedor_linha.cod_emitente V-table-Win
ON LEAVE OF int_ds_fornecedor_linha.cod_emitente IN FRAME f-main /* Fornecedor */
DO:
  
    ASSIGN c-nome-fornec = "".
    FIND FIRST emitente WHERE
               emitente.cod-emitente = INPUT frame {&frame-name} int_ds_fornecedor_linha.cod_emitente NO-LOCK NO-ERROR.
    IF AVAIL emitente THEN
       ASSIGN c-nome-fornec = emitente.nome-emit.
    DISP c-nome-fornec WITH frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL int_ds_fornecedor_linha.cod_emitente V-table-Win
ON MOUSE-SELECT-DBLCLICK OF int_ds_fornecedor_linha.cod_emitente IN FRAME f-main /* Fornecedor */
DO:  
    apply "F5":U to self.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK V-table-Win 


/* ***************************  Main Block  *************************** */

  &IF DEFINED(UIB_IS_RUNNING) <> 0 &THEN          
    RUN dispatch IN THIS-PROCEDURE ('initialize':U).        
  &ENDIF         
  
  if int_ds_fornecedor_linha.cod_emitente:load-mouse-pointer ("image~\lupa.cur":U) in frame {&frame-name} then. 

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
  {src/adm/template/row-list.i "int_ds_fornecedor_linha"}

  /* Get the record ROWID's from the RECORD-SOURCE.                  */
  {src/adm/template/row-get.i}

  /* FIND each record specified by the RECORD-SOURCE.                */
  {src/adm/template/row-find.i "int_ds_fornecedor_linha"}

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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-add-record V-table-Win 
PROCEDURE local-add-record :
/*------------------------------------------------------------------------------
  Purpose:     Override standard ADM method
  Notes:       
------------------------------------------------------------------------------*/

  /* Code placed here will execute PRIOR to standard behavior. */

  /* Dispatch standard ADM method.                             */
  RUN dispatch IN THIS-PROCEDURE ( INPUT 'add-record':U ) .

  /* Code placed here will execute AFTER standard behavior.    */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-assign-record V-table-Win 
PROCEDURE local-assign-record :
/*------------------------------------------------------------------------------
  Purpose:     Override standard ADM method
  Notes:       
------------------------------------------------------------------------------*/

  if  not frame {&frame-name}:validate() then
      return 'ADM-ERROR':U.      
  
  /* Ponha aqui a validaá∆o de chave duplicada */
  
  if  int_ds_fornecedor_linha.cod_emitente:sensitive in frame {&frame-name} = yes 
  and can-find (b-int_ds_fornecedor_linha where 
                b-int_ds_fornecedor_linha.cod_emitente = input frame {&frame-name} int_ds_fornecedor_linha.cod_emitente AND
                b-int_ds_fornecedor_linha.linha        = input frame {&frame-name} int_ds_fornecedor_linha.linha) then do:   
      run utp/ut-msgs.p (input "show",
                         input 7,
                         input "Linha por Fornecedor").
      apply 'entry' to  int_ds_fornecedor_linha.cod_emitente in frame {&FRAME-NAME}.
      return 'adm-error'.
  END.                       
  
  /* Ponha aqui as demais validaá‰es */
  
  /* Obs.: CASO A VALIDAÄ«O FALHE, DEVERµ SER RETORNADO UM COMANDO "RETURN 'ADM-ERROR'.". */
  
  /* Dispatch standard ADM method.                             */
  RUN dispatch IN THIS-PROCEDURE ( INPUT 'assign-record':U ) .
  if RETURN-VALUE = 'ADM-ERROR':U then 
     RETURN 'ADM-ERROR':U.

  IF adm-new-record = YES THEN DO:
 
     FIND FIRST emitente WHERE
                emitente.cod-emitente = INPUT frame {&frame-name} int_ds_fornecedor_linha.cod_emitente NO-LOCK NO-ERROR.
     IF NOT AVAIL emitente THEN DO:
        run utp/ut-msgs.p (input "show",
                           input 2,
                           input "Fornecedor").
        apply 'entry' to  int_ds_fornecedor_linha.cod_emitente in frame {&FRAME-NAME}.
        return 'adm-error'.
     END.
  END.

  /* Atualizaá∆o da tabela de integraá∆o Datasul -> Sysfarma */
  /*           C¢digos de Barra dos Itens - EAN              */  

  find first emitente where
             emitente.cod-emitente = int_ds_fornecedor_linha.cod_emitente no-lock no-error.

  CREATE int_ds_fornec_mercadologica.
  ASSIGN int_ds_fornec_mercadologica.tipo_movto          = IF adm-new-record = YES THEN
                                                              1 /* Inclus∆o */
                                                           ELSE
                                                              2 /* Alteraá∆o */
         int_ds_fornec_mercadologica.dt_geracao          = TODAY
         int_ds_fornec_mercadologica.hr_geracao          = STRING(TIME,"hh:mm:ss") 
         int_ds_fornec_mercadologica.cod_usuario         = c-seg-usuario
         int_ds_fornec_mercadologica.situacao            = 1 /* Pendente */
         int_ds_fornec_mercadologica.fme_fornecedor_n    = int_ds_fornecedor_linha.cod_emitente          
         int_ds_fornec_mercadologica.fme_mercadologica_s = SUBSTR(int_ds_fornecedor_linha.linha,1,2)
         int_ds_fornec_mercadologica.fme_stnopreco_s     = IF int_ds_fornecedor_linha.stnopreco = 1 THEN "S" ELSE "N"
         int_ds_fornec_mercadologica.fme_tipo_s          = IF int_ds_fornecedor_linha.tipo_trib = 1 THEN "D" ELSE "T"
         int_ds_fornec_mercadologica.cnpj_cpf            = if avail emitente then emitente.cgc else "".

  /*        Fim atualizaá∆o tabela de integraá∆o        */

  /* Code placed here will execute AFTER standard behavior.    */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-delete-record V-table-Win 
PROCEDURE local-delete-record :
/*------------------------------------------------------------------------------
  Purpose:     Override standard ADM method
  Notes:       
------------------------------------------------------------------------------*/

CREATE int_ds_fornec_mercadologica.
ASSIGN int_ds_fornec_mercadologica.tipo_movto          = 3 /* Exclus∆o */
       int_ds_fornec_mercadologica.dt_geracao          = TODAY
       int_ds_fornec_mercadologica.hr_geracao          = STRING(TIME,"hh:mm:ss") 
       int_ds_fornec_mercadologica.cod_usuario         = c-seg-usuario
       int_ds_fornec_mercadologica.situacao            = 1 /* Pendente */
       int_ds_fornec_mercadologica.fme_fornecedor_n    = int_ds_fornecedor_linha.cod_emitente          
       int_ds_fornec_mercadologica.fme_mercadologica_s = int_ds_fornecedor_linha.linha
       int_ds_fornec_mercadologica.fme_stnopreco_s     = IF int_ds_fornecedor_linha.stnopreco = 1 THEN "S" ELSE "N"
       int_ds_fornec_mercadologica.fme_tipo_s          = IF int_ds_fornecedor_linha.tipo_trib = 1 THEN "D" ELSE "T".
            
RUN dispatch IN THIS-PROCEDURE ( INPUT 'delete-record':U ) .


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

  /* Code placed here will execute AFTER standard behavior.    */
  &if  defined(ADM-MODIFY-FIELDS) &then
      disable {&ADM-MODIFY-FIELDS} with frame {&frame-name}.
  &endif
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
  /* Code placed here will execute AFTER standard behavior.    */

  ASSIGN c-nome-fornec = "".
  FIND FIRST emitente WHERE
             emitente.cod-emitente = INPUT frame {&frame-name} int_ds_fornecedor_linha.cod_emitente NO-LOCK NO-ERROR.
  IF AVAIL emitente THEN
     ASSIGN c-nome-fornec = emitente.nome-emit.
  DISP c-nome-fornec WITH frame {&frame-name}.

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
  run get-attribute ('adm-new-record').
  /* Dispatch standard ADM method.                             */
  RUN dispatch IN THIS-PROCEDURE ( INPUT 'enable-fields':U ) .

  /* Code placed here will execute AFTER standard behavior.    */
  &if  defined(ADM-MODIFY-FIELDS) &then
      enable {&ADM-MODIFY-FIELDS} with frame {&frame-name}.
  &endif

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
  {src/adm/template/snd-list.i "int_ds_fornecedor_linha"}

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

