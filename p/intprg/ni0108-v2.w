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
{include/i-prgvrs.i NI0108-V2 2.00.00.000}

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
DEF BUFFER b-int_ds_rota_veic FOR int_ds_rota_veic.

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
&Scoped-define EXTERNAL-TABLES int_ds_rota_veic
&Scoped-define FIRST-EXTERNAL-TABLE int_ds_rota_veic


/* Need to scope the external tables to this procedure                  */
DEFINE QUERY external_tables FOR int_ds_rota_veic.
/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS int_ds_rota_veic.placa ~
int_ds_rota_veic.uf_placa 
&Scoped-define ENABLED-TABLES int_ds_rota_veic
&Scoped-define FIRST-ENABLED-TABLE int_ds_rota_veic
&Scoped-Define ENABLED-OBJECTS rt-key 
&Scoped-Define DISPLAYED-FIELDS int_ds_rota_veic.cod_rota ~
int_ds_rota_veic.placa int_ds_rota_veic.uf_placa 
&Scoped-define DISPLAYED-TABLES int_ds_rota_veic
&Scoped-define FIRST-DISPLAYED-TABLE int_ds_rota_veic
&Scoped-Define DISPLAYED-OBJECTS c-desc-rota c-nome-uf 

/* Custom List Definitions                                              */
/* ADM-CREATE-FIELDS,ADM-ASSIGN-FIELDS,ADM-MODIFY-FIELDS,List-4,List-5,List-6 */
&Scoped-define ADM-CREATE-FIELDS int_ds_rota_veic.cod_rota 

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _XFTR "Foreign Keys" V-table-Win _INLINE
/* Actions: ? adm/support/keyedit.w ? ? ? */
/* STRUCTURED-DATA
<KEY-OBJECT>
THIS-PROCEDURE
</KEY-OBJECT>
<FOREIGN-KEYS>
cod-rota|y|y|int_ds_rota_veic.cod_rota
placa|y|y|int_ds_rota_veic.placa
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
DEFINE VARIABLE c-desc-rota AS CHARACTER FORMAT "X(40)":U 
     VIEW-AS FILL-IN 
     SIZE 42 BY .88 NO-UNDO.

DEFINE VARIABLE c-nome-uf AS CHARACTER FORMAT "X(20)":U 
     VIEW-AS FILL-IN 
     SIZE 22 BY .88 NO-UNDO.

DEFINE RECTANGLE rt-key
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 88.57 BY 3.5.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME f-main
     int_ds_rota_veic.cod_rota AT ROW 1.29 COL 25.14 COLON-ALIGNED WIDGET-ID 2
          VIEW-AS FILL-IN 
          SIZE 14 BY .88
     c-desc-rota AT ROW 1.29 COL 39.29 COLON-ALIGNED NO-LABEL WIDGET-ID 8
     int_ds_rota_veic.placa AT ROW 2.29 COL 25.14 COLON-ALIGNED WIDGET-ID 4
          VIEW-AS FILL-IN 
          SIZE 12 BY .88
     int_ds_rota_veic.uf_placa AT ROW 3.29 COL 25.14 COLON-ALIGNED WIDGET-ID 6
          VIEW-AS FILL-IN 
          SIZE 5 BY .88
     c-nome-uf AT ROW 3.29 COL 30.29 COLON-ALIGNED NO-LABEL WIDGET-ID 10
     rt-key AT ROW 1 COL 1
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1 SCROLLABLE 
         FONT 4.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: SmartViewer
   External Tables: mgespe.int_ds_rota_veic
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
         HEIGHT             = 3.5
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

/* SETTINGS FOR FILL-IN c-desc-rota IN FRAME f-main
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN c-nome-uf IN FRAME f-main
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN int_ds_rota_veic.cod_rota IN FRAME f-main
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

&Scoped-define SELF-NAME int_ds_rota_veic.cod_rota
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL int_ds_rota_veic.cod_rota V-table-Win
ON F5 OF int_ds_rota_veic.cod_rota IN FRAME f-main /* Rota */
DO:  
    assign l-implanta = NO.
    {include/zoomvar.i &prog-zoom = "dizoom/z01di181.w"
                       &campo = int_ds_rota_veic.cod_rota
                       &campozoom = cod-rota
                       &campo2 = c-desc-rota
                       &campozoom2 = descricao}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL int_ds_rota_veic.cod_rota V-table-Win
ON LEAVE OF int_ds_rota_veic.cod_rota IN FRAME f-main /* Rota */
DO:
    ASSIGN c-desc-rota = "".
    FIND FIRST rota WHERE 
               rota.cod-rota = input frame {&frame-name} int_ds_rota_veic.cod_rota NO-LOCK NO-ERROR.
    IF AVAIL rota THEN
       ASSIGN c-desc-rota = rota.descricao.
    DISP c-desc-rota WITH FRAME {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL int_ds_rota_veic.cod_rota V-table-Win
ON MOUSE-SELECT-DBLCLICK OF int_ds_rota_veic.cod_rota IN FRAME f-main /* Rota */
DO:
  APPLY "F5":U to self.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME int_ds_rota_veic.uf_placa
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL int_ds_rota_veic.uf_placa V-table-Win
ON F5 OF int_ds_rota_veic.uf_placa IN FRAME f-main /* UF Placa */
DO:
    assign l-implanta = NO.
    {include/zoomvar.i &prog-zoom = "unzoom/z01un007.w"
                       &campo = int_ds_rota_veic.uf_placa
                       &campozoom = estado
                       &campo2 = c-nome-uf
                       &campozoom2 = no-estado}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL int_ds_rota_veic.uf_placa V-table-Win
ON LEAVE OF int_ds_rota_veic.uf_placa IN FRAME f-main /* UF Placa */
DO:
    ASSIGN c-nome-uf = "".
    FIND FIRST unid-feder WHERE 
               unid-feder.pais   = "Brasil" AND
               unid-feder.estado = input frame {&frame-name} int_ds_rota_veic.uf_placa NO-LOCK NO-ERROR.
    IF AVAIL unid-feder THEN
       ASSIGN c-nome-uf = unid-feder.no-estado.
    DISP c-nome-uf WITH frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL int_ds_rota_veic.uf_placa V-table-Win
ON MOUSE-SELECT-DBLCLICK OF int_ds_rota_veic.uf_placa IN FRAME f-main /* UF Placa */
DO:
  APPLY "F5":U to self.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK V-table-Win 


/* ***************************  Main Block  *************************** */

  &IF DEFINED(UIB_IS_RUNNING) <> 0 &THEN          
    RUN dispatch IN THIS-PROCEDURE ('initialize':U).        
  &ENDIF         
  
  /************************ INTERNAL PROCEDURES ********************/

  if int_ds_rota_veic.cod_rota:load-mouse-pointer ("image~\lupa.cur") in frame {&frame-name} then.
  if int_ds_rota_veic.uf_placa:load-mouse-pointer ("image~\lupa.cur") in frame {&frame-name} then.

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
  {src/adm/template/row-list.i "int_ds_rota_veic"}

  /* Get the record ROWID's from the RECORD-SOURCE.                  */
  {src/adm/template/row-get.i}

  /* FIND each record specified by the RECORD-SOURCE.                */
  {src/adm/template/row-find.i "int_ds_rota_veic"}

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
  /*{include/i-valid.i}*/
  
  if not frame {&frame-name}:validate() then
     return 'ADM-ERROR':U.
       
  /*** Validaá∆o de chave duplicada ***/  
  if int_ds_rota_veic.cod_rota:sensitive in frame {&frame-name} = yes then do:
     if can-find(b-int_ds_rota_veic where 
                 b-int_ds_rota_veic.cod_rota = input frame {&frame-name} int_ds_rota_veic.cod_rota) then do:
        MESSAGE "Rota j† cadastrada."
                VIEW-AS ALERT-BOX INFO BUTTONS OK.
        apply "entry" to int_ds_rota_veic.cod_rota in frame {&frame-name}.
        return "adm-error".
     end.
     FIND FIRST rota WHERE 
                rota.cod-rota = input frame {&frame-name} int_ds_rota_veic.cod_rota NO-LOCK NO-ERROR.
     IF NOT AVAIL rota THEN DO:
        MESSAGE "Rota informada n∆o cadastrada da tabela de Rotas."
                VIEW-AS ALERT-BOX INFO BUTTONS OK.
        apply "entry" to int_ds_rota_veic.cod_rota in frame {&frame-name}.
        return "adm-error".
     END.
     IF input frame {&frame-name} int_ds_rota_veic.placa = "" THEN DO:
        MESSAGE "Placa deve ser diferente de brancos."
                VIEW-AS ALERT-BOX INFO BUTTONS OK.
        apply "entry" to int_ds_rota_veic.placa in frame {&frame-name}.
        return "adm-error".
     END.
  END.
     
  IF input frame {&frame-name} int_ds_rota_veic.uf_placa = "" THEN DO:
     MESSAGE "UF da Placa deve ser diferente de brancos."
             VIEW-AS ALERT-BOX INFO BUTTONS OK.
     apply "entry" to int_ds_rota_veic.uf_placa in frame {&frame-name}.
     return "adm-error".
  END.
  FIND FIRST unid-feder WHERE 
             unid-feder.pais   = "Brasil" AND
             unid-feder.estado = input frame {&frame-name} int_ds_rota_veic.uf_placa NO-LOCK NO-ERROR.
  IF NOT AVAIL unid-feder THEN DO:
     MESSAGE "UF da Placa n∆o cadastrada da tabela de Unidades da Federaá∆o."
             VIEW-AS ALERT-BOX INFO BUTTONS OK.
     apply "entry" to int_ds_rota_veic.uf_placa in frame {&frame-name}.
     return "adm-error".
  END.
  
  /* Dispatch standard ADM method.                             */
  RUN dispatch IN THIS-PROCEDURE ( INPUT 'assign-record':U ) .
  if RETURN-VALUE = 'ADM-ERROR':U then 
     RETURN 'ADM-ERROR':U.
  
  /* Code placed here will execute AFTER standard behavior.    */

  ASSIGN int_ds_rota_veic.dt_ult_alter  = TODAY
         int_ds_rota_veic.usu_ult_alter = c-seg-usuario.

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

  IF AVAIL int_ds_rota_veic THEN DO:
     FIND FIRST rota WHERE 
                rota.cod-rota = int_ds_rota_veic.cod_rota NO-LOCK NO-ERROR.
     ASSIGN c-desc-rota = "".
     IF AVAIL rota THEN
        ASSIGN c-desc-rota = rota.descricao.
     DISP c-desc-rota WITH frame {&frame-name}.

     ASSIGN c-nome-uf = "".
     FIND FIRST unid-feder WHERE 
                unid-feder.pais   = "Brasil" AND
                unid-feder.estado = int_ds_rota_veic.uf_placa NO-LOCK NO-ERROR.
     IF AVAIL unid-feder THEN
        ASSIGN c-nome-uf = unid-feder.no-estado.
     DISP c-nome-uf WITH frame {&frame-name}.
  END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Pi-validate V-table-Win 
PROCEDURE Pi-validate :
/*------------------------------------------------------------------------------
  Purpose:Validar a viewer     
  Parameters:  <none>
  Notes: N∆o fazer assign aqui. Nesta procedure
  devem ser colocadas apenas validaá‰es, pois neste ponto do programa o registro 
  ainda n∆o foi criado.       
------------------------------------------------------------------------------*/
  {include/i-vldfrm.i} /* Validaá∆o de dicion†rio */
   
   /*Segue um exemplo de validaá∆o de programa 
 *    find tabela where tabela.campo1 = c-variavel and
 *                      tabela.campo2 > i-variavel no-lock no-error.
 *    {include/i-vldprg.i} /* Este include deve ser colocado sempre antes do ut-msgs.p */                  
 *    run utp/ut-msgs.p (input "show":U, input 7, input return-value).
 *    return 'ADM-ERROR':U.*/
 
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE send-key V-table-Win  adm/support/_key-snd.p
PROCEDURE send-key :
/*------------------------------------------------------------------------------
  Purpose:     Sends a requested KEY value back to the calling
               SmartObject.
  Parameters:  <see adm/template/sndkytop.i>
------------------------------------------------------------------------------*/

  /* Define variables needed by this internal procedure.             */
  {src/adm/template/sndkytop.i}

  /* Return the key value associated with each key case.             */
  {src/adm/template/sndkycas.i "cod_rota" "int_ds_rota_veic" "cod_rota"}

  /* Close the CASE statement and end the procedure.                 */
  {src/adm/template/sndkyend.i}

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
  {src/adm/template/snd-list.i "int_ds_rota_veic"}

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

