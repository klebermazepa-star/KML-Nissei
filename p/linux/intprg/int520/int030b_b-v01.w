&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI ADM1
&ANALYZE-RESUME
/* Connected Databases 
          emsesp           ORACLE
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS V-table-Win 
/*:T *******************************************************************************
** Copyright TOTVS S.A. (2009)
** Todos os Direitos Reservados.
**
** Este fonte e de propriedade exclusiva da TOTVS, sua reproducao
** parcial ou total por qualquer meio, so podera ser feita mediante
** autorizacao expressa.
*******************************************************************************/
{include/i-prgvrs.i V99XX999 9.99.99.999}

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
&Scop adm-attribute-dlg support/viewerd.w

/* global variable definitions */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */
def var v-row-parent as rowid no-undo.

DEFINE BUFFER bf-int-ds-msg-usuario FOR int-ds-msg-usuario.

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
&Scoped-define EXTERNAL-TABLES int-ds-msg-usuario
&Scoped-define FIRST-EXTERNAL-TABLE int-ds-msg-usuario


/* Need to scope the external tables to this procedure                  */
DEFINE QUERY external_tables FOR int-ds-msg-usuario.
/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS int-ds-msg-usuario.cod-usuario ~
int-ds-msg-usuario.mensagem 
&Scoped-define ENABLED-TABLES int-ds-msg-usuario
&Scoped-define FIRST-ENABLED-TABLE int-ds-msg-usuario
&Scoped-Define ENABLED-OBJECTS rt-key 
&Scoped-Define DISPLAYED-FIELDS int-ds-msg-usuario.cod-usuario ~
int-ds-msg-usuario.mensagem 
&Scoped-define DISPLAYED-TABLES int-ds-msg-usuario
&Scoped-define FIRST-DISPLAYED-TABLE int-ds-msg-usuario


/* Custom List Definitions                                              */
/* ADM-CREATE-FIELDS,ADM-ASSIGN-FIELDS,ADM-MODIFY-FIELDS,List-4,List-5,List-6 */
&Scoped-define ADM-CREATE-FIELDS int-ds-msg-usuario.cod-usuario 
&Scoped-define ADM-ASSIGN-FIELDS int-ds-msg-usuario.cod-usuario 
&Scoped-define ADM-MODIFY-FIELDS int-ds-msg-usuario.cod-usuario 

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
DEFINE RECTANGLE rt-key
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 88.57 BY 6.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME f-main
     int-ds-msg-usuario.cod-usuario AT ROW 1.25 COL 20.29 COLON-ALIGNED WIDGET-ID 2
          LABEL "Usu rio Respons vel"
          VIEW-AS FILL-IN 
          SIZE 16 BY .88
     int-ds-msg-usuario.mensagem AT ROW 2.38 COL 22.29 NO-LABEL WIDGET-ID 4
          VIEW-AS EDITOR SCROLLBAR-VERTICAL
          SIZE 61.72 BY 4.13 TOOLTIP "Informar como Inicia a Mensagem ou Peda‡o da Mensagem de Integra‡Æo"
     "Mensagem:" VIEW-AS TEXT
          SIZE 8 BY .67 AT ROW 2.5 COL 14.14 WIDGET-ID 6
     rt-key AT ROW 1 COL 1
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1 SCROLLABLE  WIDGET-ID 100.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: SmartViewer
   External Tables: mgesp.int-ds-msg-usuario
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
         HEIGHT             = 6.33
         WIDTH              = 89.86.
/* END WINDOW DEFINITION */
                                                                        */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _INCLUDED-LIB V-table-Win 
/* ************************* Included-Libraries *********************** */

{src/adm/method/viewer.i}
{include/c-viewer.i}
{utp/ut-glob.i}
{include/i_dbtype.i}

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

/* SETTINGS FOR FILL-IN int-ds-msg-usuario.cod-usuario IN FRAME f-main
   1 2 3 EXP-LABEL                                                      */
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

&Scoped-define SELF-NAME int-ds-msg-usuario.cod-usuario
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL int-ds-msg-usuario.cod-usuario V-table-Win
ON F5 OF int-ds-msg-usuario.cod-usuario IN FRAME f-main /* Usu rio Respons vel */
DO:
   {include/zoomvar.i &prog-zoom=unzoom/z01un178.w
                      &campo=int-ds-msg-usuario.cod-usuario
                      &campozoom=cod_usuario}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL int-ds-msg-usuario.cod-usuario V-table-Win
ON MOUSE-SELECT-DBLCLICK OF int-ds-msg-usuario.cod-usuario IN FRAME f-main /* Usu rio Respons vel */
DO:
  APPLY "F5" TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK V-table-Win 


/* ***************************  Main Block  *************************** */

  &IF DEFINED(UIB_IS_RUNNING) <> 0 &THEN          
    RUN dispatch IN THIS-PROCEDURE ('initialize':U).        
  &ENDIF         
  
  int-ds-msg-usuario.cod-usuario:load-mouse-pointer ("Image\lupa.cur") in frame {&frame-name}.
  
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
  {src/adm/template/row-list.i "int-ds-msg-usuario"}

  /* Get the record ROWID's from the RECORD-SOURCE.                  */
  {src/adm/template/row-get.i}

  /* FIND each record specified by the RECORD-SOURCE.                */
  {src/adm/template/row-find.i "int-ds-msg-usuario"}

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
    
    /*:T Ponha na pi-validate todas as valida‡äes */
    /*:T NÆo gravar nada no registro antes do dispatch do assign-record e 
       nem na PI-validate. */
       
    RUN Pi-validate. 

    IF RETURN-VALUE = 'ADM-ERROR':U then 
        return 'ADM-ERROR':U.

    
    /* Dispatch standard ADM method.                             */
    RUN dispatch IN THIS-PROCEDURE ( INPUT 'assign-record':U ) .
    if RETURN-VALUE = 'ADM-ERROR':U then 
        return 'ADM-ERROR':U.
    
    /*:T Todos os assignïs nÆo feitos pelo assign-record devem ser feitos aqui */  
    /* Code placed here will execute AFTER standard behavior.    */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-create-record V-table-Win 
PROCEDURE local-create-record :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    /* Code placed here will execute PRIOR to standard behavior.  */
    /* Dispatch standard ADM method.*/

    RUN dispatch IN THIS-PROCEDURE ( INPUT 'create-record':U ).
    /* Code placed here will execute AFTER standard behavior.     */
    
    find int-ds-origem where rowid (int-ds-origem) = v-row-parent no-lock no-error.
    if available int-ds-origem then do:
        assign int-ds-msg-usuario.origem = int-ds-origem.origem.
    end. 
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
    
    /* Dispatch standard ADM method.                             */
    RUN dispatch IN THIS-PROCEDURE ( INPUT 'enable-fields':U ) .
    
    /* Code placed here will execute AFTER standard behavior.    */
    &if  defined(ADM-MODIFY-FIELDS) &then
    if adm-new-record = yes then
        enable {&ADM-MODIFY-FIELDS} with frame {&frame-name}.
    &endif

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
/*:T------------------------------------------------------------------------------
  Purpose:Validar a viewer     
  Parameters:  <none>
  Notes: NÆo fazer assign aqui. Nesta procedure
  devem ser colocadas apenas valida‡äes, pois neste ponto do programa o registro 
  ainda nÆo foi criado.       
------------------------------------------------------------------------------*/
    {include/i-vldfrm.i} /*:T Valida‡Æo de dicion rio */
    
/*:T    Segue um exemplo de valida‡Æo de programa */
/*       find tabela where tabela.campo1 = c-variavel and               */
/*                         tabela.campo2 > i-variavel no-lock no-error. */
      
      /*:T Este include deve ser colocado sempre antes do ut-msgs.p */
/*       {include/i-vldprg.i}                                             */
/*       run utp/ut-msgs.p (input "show":U, input 7, input return-value). */
/*       return 'ADM-ERROR':U.                                            */
    find int-ds-origem where rowid (int-ds-origem) = v-row-parent no-lock no-error.
    
    if trim(input frame {&frame-name} int-ds-msg-usuario.cod-usuario) = "" then do:
            {include/i-vldprg.i}                                            
            run utp/ut-msgs.p (input "show":U, input 17006, input "Usu rio Inv lido!~~ Usu rio deve ser informado.").
            return 'ADM-ERROR':U.                                           
    end.
    
    if trim(input frame {&frame-name} int-ds-msg-usuario.mensagem) = "" then do:
            {include/i-vldprg.i}                                            
            run utp/ut-msgs.p (input "show":U, input 17006, input "Mensagem Inv lida!~~ Mensagem deve ser informada.").
            return 'ADM-ERROR':U.                                           
    end.

/*     IF input frame {&frame-name} int-ds-msg-usuario.cod-usuario <> "*" THEN DO:                                                                                            */
/*         find first int-ds-msg-usuario no-lock                                                                                                                              */
/*              where int-ds-msg-usuario.origem   = int-ds-origem.origem                                                                                                      */
/*                and int-ds-msg-usuario.mensagem = input frame {&frame-name} int-ds-msg-usuario.mensagem no-error.                                                           */
/*         if avail int-ds-msg-usuario then do:                                                                                                                               */
/*                 {include/i-vldprg.i}                                                                                                                                       */
/*                 run utp/ut-msgs.p (input "show":U, input 17006, input "Mensagem Inv lida!~~ J  existe uma ocorrˆncia para esse mensagem para a Origem. Favor verificar."). */
/*                 return 'ADM-ERROR':U.                                                                                                                                      */
/*         end.                                                                                                                                                               */
/*     END.                                                                                                                                                                   */
/*     ELSE DO:                                                                                                                                                               */
/*     END.                                                                                                                                                                   */

    if adm-new-record = yes then do:

        IF input frame {&frame-name} int-ds-msg-usuario.cod-usuario <> "*" THEN DO:
            FIND usuar_mestre where usuar_mestre.cod_usuario = input frame {&frame-name} int-ds-msg-usuario.cod-usuario no-lock no-error.
            If not Available(usuar_mestre) then do:
                 {utp/ut-table.i mguni usuar_mestre 1}
                 run utp/ut-msgs.p (input "show",
                                    input 2,
                                    input return-value).
                 Apply "entry" to int-ds-msg-usuario.cod-usuario.                         
                 Return 'adm-error'.
            END.
        END.

        find first int-ds-msg-usuario no-lock
             where int-ds-msg-usuario.origem      = int-ds-origem.origem
               and int-ds-msg-usuario.mensagem    = input frame {&frame-name} int-ds-msg-usuario.mensagem
               AND int-ds-msg-usuario.cod-usuario = input frame {&frame-name} int-ds-msg-usuario.cod-usuario no-error.
        if avail int-ds-msg-usuario then do:
                {include/i-vldprg.i}
                run utp/ut-msgs.p (input "show":U, input 17006, input "Mensagem Inv lida!~~ J  existe uma ocorrˆncia para esse mensagem para a Origem. Favor verificar.").
                return 'ADM-ERROR':U.
        end.
    end.
    ELSE DO:

        find first bf-int-ds-msg-usuario no-lock
             where bf-int-ds-msg-usuario.origem      = int-ds-origem.origem
               and bf-int-ds-msg-usuario.mensagem    = input frame {&frame-name} int-ds-msg-usuario.mensagem
               AND bf-int-ds-msg-usuario.cod-usuario = input frame {&frame-name} int-ds-msg-usuario.cod-usuario 
               AND ROWID(bf-int-ds-msg-usuario)     <> ROWID(int-ds-msg-usuario)
            no-error.
        if avail bf-int-ds-msg-usuario then do:
                {include/i-vldprg.i}
                run utp/ut-msgs.p (input "show":U, input 17006, input "Mensagem Inv lida!~~ J  existe uma ocorrˆncia para esse mensagem para a Origem. Favor verificar.").
                return 'ADM-ERROR':U.
        end.
    END.


    

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
  {src/adm/template/snd-list.i "int-ds-msg-usuario"}

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

