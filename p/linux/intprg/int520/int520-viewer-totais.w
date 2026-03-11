&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI ADM1
&ANALYZE-RESUME
/* Connected Databases 
          emsesp           PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS V-table-Win 
/*:T *******************************************************************************
** Copyright DATASUL S.A. (1997)
** Todos os Direitos Reservados.
**
** Este fonte e de propriedade exclusiva da DATASUL, sua reproducao
** parcial ou total por qualquer meio, so podera ser feita mediante
** autorizacao expressa.
*******************************************************************************/
{include/i-prgvrs.i int520-viewer-totais 1.12.01.AVB}

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
&Scoped-define EXTERNAL-TABLES int-ds-nota-entrada
&Scoped-define FIRST-EXTERNAL-TABLE int-ds-nota-entrada


/* Need to scope the external tables to this procedure                  */
DEFINE QUERY external_tables FOR int-ds-nota-entrada.
/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS int-ds-nota-entrada.nen-baseicms-n ~
int-ds-nota-entrada.nen-valoricms-n int-ds-nota-entrada.nen-valoripi-n ~
int-ds-nota-entrada.nen-basest-n int-ds-nota-entrada.nen-icmsst-n ~
int-ds-nota-entrada.nen-desconto-n 
&Scoped-define ENABLED-TABLES int-ds-nota-entrada
&Scoped-define FIRST-ENABLED-TABLE int-ds-nota-entrada
&Scoped-Define ENABLED-OBJECTS RECT-24 
&Scoped-Define DISPLAYED-FIELDS int-ds-nota-entrada.nen-baseicms-n ~
int-ds-nota-entrada.nen-valoricms-n int-ds-nota-entrada.nen-valoripi-n ~
int-ds-nota-entrada.nen-basest-n int-ds-nota-entrada.nen-icmsst-n ~
int-ds-nota-entrada.nen-desconto-n 
&Scoped-define DISPLAYED-TABLES int-ds-nota-entrada
&Scoped-define FIRST-DISPLAYED-TABLE int-ds-nota-entrada
&Scoped-Define DISPLAYED-OBJECTS tot-produtos tot-nf tot-base-icms-it ~
tot-icms-it tot-ipi-it tot-base-icms-st-it tot-icms-st-it tot-valor-it ~
tot-desconto-it tot-nf-it 

/* Custom List Definitions                                              */
/* ADM-CREATE-FIELDS,ADM-ASSIGN-FIELDS,ADM-MODIFY-FIELDS,List-4,List-5,List-6 */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */
DEFINE VARIABLE tot-base-icms-it AS DECIMAL FORMAT "->,>>>,>>>,>>9.99999":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 16.13 BY .87 NO-UNDO.

DEFINE VARIABLE tot-base-icms-st-it AS DECIMAL FORMAT "->,>>>,>>>,>>9.99999":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 16.13 BY .87 NO-UNDO.

DEFINE VARIABLE tot-desconto-it AS DECIMAL FORMAT "->,>>>,>>>,>>9.99999":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 16.13 BY .87 NO-UNDO.

DEFINE VARIABLE tot-icms-it AS DECIMAL FORMAT "->,>>>,>>>,>>9.99999":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 16.13 BY .87 NO-UNDO.

DEFINE VARIABLE tot-icms-st-it AS DECIMAL FORMAT "->,>>>,>>>,>>9.99999":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 16.13 BY .87 NO-UNDO.

DEFINE VARIABLE tot-ipi-it AS DECIMAL FORMAT "->,>>>,>>>,>>9.99999":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 16.13 BY .87 NO-UNDO.

DEFINE VARIABLE tot-nf AS DECIMAL FORMAT "->,>>>,>>>,>>9.99999":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 16.13 BY .87 NO-UNDO.

DEFINE VARIABLE tot-nf-it AS DECIMAL FORMAT "->,>>>,>>>,>>9.99999":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 16.13 BY .87 NO-UNDO.

DEFINE VARIABLE tot-produtos AS DECIMAL FORMAT "->>>>,>>>,>>9.99999":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 16.13 BY .87 NO-UNDO.

DEFINE VARIABLE tot-valor-it AS DECIMAL FORMAT "->,>>>,>>>,>>9.99999":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 16.13 BY .87 NO-UNDO.

DEFINE RECTANGLE RECT-24
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 141.63 BY 3.2.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME f-main
     int-ds-nota-entrada.nen-baseicms-n AT ROW 2.2 COL 8.88 NO-LABEL WIDGET-ID 44
          VIEW-AS FILL-IN 
          SIZE 16.13 BY .87
     int-ds-nota-entrada.nen-valoricms-n AT ROW 2.2 COL 23.63 COLON-ALIGNED NO-LABEL WIDGET-ID 178
          VIEW-AS FILL-IN 
          SIZE 16.13 BY .87
     int-ds-nota-entrada.nen-valoripi-n AT ROW 2.2 COL 40.13 COLON-ALIGNED NO-LABEL WIDGET-ID 34
          VIEW-AS FILL-IN 
          SIZE 16.13 BY .87
     int-ds-nota-entrada.nen-basest-n AT ROW 2.2 COL 56.75 COLON-ALIGNED NO-LABEL WIDGET-ID 46
          VIEW-AS FILL-IN 
          SIZE 16.13 BY .87
     int-ds-nota-entrada.nen-icmsst-n AT ROW 2.2 COL 73.63 COLON-ALIGNED NO-LABEL WIDGET-ID 42
          VIEW-AS FILL-IN 
          SIZE 16.13 BY .87
     tot-produtos AT ROW 2.2 COL 90.13 COLON-ALIGNED NO-LABEL WIDGET-ID 180
     int-ds-nota-entrada.nen-desconto-n AT ROW 2.2 COL 107 COLON-ALIGNED NO-LABEL WIDGET-ID 110
          VIEW-AS FILL-IN 
          SIZE 16.13 BY .87
     tot-nf AT ROW 2.2 COL 123.63 COLON-ALIGNED NO-LABEL WIDGET-ID 182
     tot-base-icms-it AT ROW 3.43 COL 7 COLON-ALIGNED NO-LABEL WIDGET-ID 142
     tot-icms-it AT ROW 3.43 COL 23.38 COLON-ALIGNED NO-LABEL WIDGET-ID 152
     tot-ipi-it AT ROW 3.43 COL 40.25 COLON-ALIGNED NO-LABEL WIDGET-ID 154
     tot-base-icms-st-it AT ROW 3.43 COL 56.75 COLON-ALIGNED NO-LABEL WIDGET-ID 156
     tot-icms-st-it AT ROW 3.43 COL 73.63 COLON-ALIGNED NO-LABEL WIDGET-ID 158
     tot-valor-it AT ROW 3.43 COL 90.13 COLON-ALIGNED NO-LABEL WIDGET-ID 160
     tot-desconto-it AT ROW 3.43 COL 107 COLON-ALIGNED NO-LABEL WIDGET-ID 162
     tot-nf-it AT ROW 3.43 COL 123.63 COLON-ALIGNED NO-LABEL WIDGET-ID 164
     "Valor ICMS" VIEW-AS TEXT
          SIZE 11 BY .67 AT ROW 1.5 COL 26 WIDGET-ID 58
     "Valor ICMS ST" VIEW-AS TEXT
          SIZE 13.63 BY .67 AT ROW 1.43 COL 76.13 WIDGET-ID 66
     "Nota:" VIEW-AS TEXT
          SIZE 5.25 BY .67 AT ROW 2.2 COL 2 WIDGET-ID 144
     "Valor Produtos" VIEW-AS TEXT
          SIZE 13.63 BY .67 AT ROW 1.5 COL 92.63 WIDGET-ID 70
     "Itens:" VIEW-AS TEXT
          SIZE 5.25 BY .67 AT ROW 3.43 COL 2.13 WIDGET-ID 146
     "Valor IPI" VIEW-AS TEXT
          SIZE 8.63 BY .67 AT ROW 1.5 COL 43 WIDGET-ID 102
     "Descontos" VIEW-AS TEXT
          SIZE 10.63 BY .67 AT ROW 1.43 COL 109.13 WIDGET-ID 138
     "Base C lculo" VIEW-AS TEXT
          SIZE 12 BY .67 AT ROW 1.43 COL 9.38 WIDGET-ID 50
     "Base ICMS ST" VIEW-AS TEXT
          SIZE 13.63 BY .67 AT ROW 1.43 COL 58.63 WIDGET-ID 62
     "Valor Total NF" VIEW-AS TEXT
          SIZE 13.63 BY .67 AT ROW 1.43 COL 125.63 WIDGET-ID 96
     RECT-24 AT ROW 1.8 COL 1 WIDGET-ID 172
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1 SCROLLABLE  WIDGET-ID 100.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: SmartViewer
   External Tables: emsesp.int-ds-nota-entrada
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
         HEIGHT             = 4.33
         WIDTH              = 141.63.
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

/* SETTINGS FOR FILL-IN int-ds-nota-entrada.nen-baseicms-n IN FRAME f-main
   ALIGN-L EXP-LABEL                                                    */
/* SETTINGS FOR FILL-IN tot-base-icms-it IN FRAME f-main
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN tot-base-icms-st-it IN FRAME f-main
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN tot-desconto-it IN FRAME f-main
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN tot-icms-it IN FRAME f-main
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN tot-icms-st-it IN FRAME f-main
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN tot-ipi-it IN FRAME f-main
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN tot-nf IN FRAME f-main
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN tot-nf-it IN FRAME f-main
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN tot-produtos IN FRAME f-main
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN tot-valor-it IN FRAME f-main
   NO-ENABLE                                                            */
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE adm-find-using-key V-table-Win  adm/support/_key-fnd.p
PROCEDURE adm-find-using-key :
/*------------------------------------------------------------------------------
  Purpose:     Finds the current record using the contents of
               the 'Key-Name' and 'Key-Value' attributes.
  Parameters:  <none>
------------------------------------------------------------------------------*/

  /* No Foreign keys are accepted by this SmartObject. */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

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
  {src/adm/template/row-list.i "int-ds-nota-entrada"}

  /* Get the record ROWID's from the RECORD-SOURCE.                  */
  {src/adm/template/row-get.i}

  /* FIND each record specified by the RECORD-SOURCE.                */
  {src/adm/template/row-find.i "int-ds-nota-entrada"}

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
    
    /* Dispatch standard ADM method.                             */
    RUN dispatch IN THIS-PROCEDURE ( INPUT 'assign-record':U ) .
    if RETURN-VALUE = 'ADM-ERROR':U then 
        return 'ADM-ERROR':U.
    
    /*:T Todos os assignïs nÆo feitos pelo assign-record devem ser feitos aqui */  
    /* Code placed here will execute AFTER standard behavior.    */

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
  assign  tot-base-icms-it        = 0
          tot-base-icms-st-it     = 0
          tot-desconto-it         = 0
          tot-icms-it             = 0
          tot-icms-st-it          = 0
          tot-ipi-it              = 0
          tot-nf-it               = 0
          tot-valor-it            = 0.
          tot-produtos            = 0.
  if avail int-ds-nota-entrada then do:
      for each int-ds-nota-entrada-produto no-lock where
          int-ds-nota-entrada-produto.nen-cnpj-origem-s  = int-ds-nota-entrada-produto.nen-cnpj-origem-s and 
          int-ds-nota-entrada-produto.nen-notafiscal-n   = int-ds-nota-entrada.nen-notafiscal-n       and 
          int-ds-nota-entrada-produto.nen-serie-s        = int-ds-nota-entrada.nen-serie-s:
          assign 
          tot-base-icms-it        = tot-base-icms-it       + int-ds-nota-entrada-produto.nep-baseicms-n
          tot-base-icms-st-it     = tot-base-icms-st-it    + int-ds-nota-entrada-produto.nep-basest-n
          tot-desconto-it         = tot-desconto-it        + int-ds-nota-entrada-produto.nep-valordesconto-n
          tot-icms-it             = tot-icms-it            + int-ds-nota-entrada-produto.nep-valoricms-n
          tot-icms-st-it          = tot-icms-st-it         + int-ds-nota-entrada-produto.nep-icmsst-n
          tot-ipi-it              = tot-ipi-it             + int-ds-nota-entrada-produto.nep-valoripi-n
          tot-nf-it               = tot-nf-it              + (int-ds-nota-entrada-produto.nep-valorBRUTO-n
                                                           +  int-ds-nota-entrada-produto.nep-valoripi-n
                                                           +  int-ds-nota-entrada-produto.nep-icmsst-n
                                                           +  int-ds-nota-entrada-produto.nep-valordespesa-n)
                                                           - int-ds-nota-entrada-produto.nep-valordesconto-n
          tot-valor-it            = tot-valor-it           + int-ds-nota-entrada-produto.nep-valorBRUTO-n - int-ds-nota-entrada-produto.nep-valordesconto-n.
      end.
      assign tot-produtos      = tot-valor-it
             tot-nf            = tot-nf-it.
      if  tot-base-icms-it        = int-ds-nota-entrada.nen-baseicms-n 
          then int-ds-nota-entrada.nen-baseicms-n:bgcolor in frame f-Main = ?. else int-ds-nota-entrada.nen-baseicms-n:bgcolor in frame f-Main = 14.
      if  tot-base-icms-st-it     = int-ds-nota-entrada.nen-basest-n
          then int-ds-nota-entrada.nen-basest-n:bgcolor in frame f-Main = ?. else int-ds-nota-entrada.nen-basest-n:bgcolor in frame f-Main = 14.
      if  tot-desconto-it         = int-ds-nota-entrada.nen-desconto-n
          then int-ds-nota-entrada.nen-desconto-n:bgcolor in frame f-Main = ?. else int-ds-nota-entrada.nen-desconto-n:bgcolor in frame f-Main = 14.
      if  tot-icms-it             = int-ds-nota-entrada.nen-icmsst-n
          then int-ds-nota-entrada.nen-icmsst-n:bgcolor in frame f-Main = ?. else int-ds-nota-entrada.nen-icmsst-n:bgcolor in frame f-Main = 14.
      if  tot-icms-st-it          = int-ds-nota-entrada.nen-icmsst-n
          then int-ds-nota-entrada.nen-icmsst-n:bgcolor in frame f-Main = ?. else int-ds-nota-entrada.nen-icmsst-n:bgcolor in frame f-Main = 14.
      if  tot-ipi-it              = int-ds-nota-entrada.nen-valoripi-n
          then int-ds-nota-entrada.nen-valoripi-n:bgcolor in frame f-Main = ?. else int-ds-nota-entrada.nen-valoripi-n:bgcolor in frame f-Main = 14.
  end.
  display tot-base-icms-it      
          tot-base-icms-st-it   
          tot-desconto-it       
          tot-icms-it           
          tot-icms-st-it        
          tot-ipi-it            
          tot-nf-it             
          tot-nf
          tot-valor-it          
          tot-produtos
      with frame f-Main.
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
  {src/adm/template/snd-list.i "int-ds-nota-entrada"}

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

