&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI ADM1
&ANALYZE-RESUME
/* Connected Databases 
          custom           PROGRESS
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
&Scoped-define EXTERNAL-TABLES int_ds_docto_xml
&Scoped-define FIRST-EXTERNAL-TABLE int_ds_docto_xml


/* Need to scope the external tables to this procedure                  */
DEFINE QUERY external_tables FOR int_ds_docto_xml.
/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS int_ds_docto_xml.chave-ref-oper-triangular 
&Scoped-define ENABLED-TABLES int_ds_docto_xml
&Scoped-define FIRST-ENABLED-TABLE int_ds_docto_xml
&Scoped-Define ENABLED-OBJECTS RECT-24 fi-nota-refer fi-serie-refer 
&Scoped-Define DISPLAYED-FIELDS int_ds_docto_xml.chave-ref-oper-triangular 
&Scoped-define DISPLAYED-TABLES int_ds_docto_xml
&Scoped-define FIRST-DISPLAYED-TABLE int_ds_docto_xml
&Scoped-Define DISPLAYED-OBJECTS fi-nota-refer fi-serie-refer 

/* Custom List Definitions                                              */
/* ADM-CREATE-FIELDS,ADM-ASSIGN-FIELDS,ADM-MODIFY-FIELDS,List-4,List-5,List-6 */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */
DEFINE VARIABLE fi-nota-refer AS CHARACTER FORMAT "X(10)":U 
     LABEL "Nota referenciada" 
     VIEW-AS FILL-IN 
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE fi-serie-refer AS CHARACTER FORMAT "X(256)":U 
     LABEL "S‚rie referenciada" 
     VIEW-AS FILL-IN 
     SIZE 14 BY 1 NO-UNDO.

DEFINE RECTANGLE RECT-24
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 141.57 BY 6.21.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME f-main
     int_ds_docto_xml.chave-ref-oper-triangular AT ROW 2.5 COL 28 COLON-ALIGNED WIDGET-ID 174
          LABEL "Chave de acesso" FORMAT "x(50)"
          VIEW-AS FILL-IN 
          SIZE 45 BY 1
     fi-nota-refer AT ROW 3.75 COL 28 COLON-ALIGNED WIDGET-ID 176
     fi-serie-refer AT ROW 5.08 COL 28 COLON-ALIGNED WIDGET-ID 178
     "Nota referenciada (Opera‡Æo Triangular)" VIEW-AS TEXT
          SIZE 49.72 BY .67 AT ROW 1.38 COL 6 WIDGET-ID 180
     RECT-24 AT ROW 1.79 COL 1 WIDGET-ID 172
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1 SCROLLABLE  WIDGET-ID 100.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: SmartViewer
   External Tables: custom.int_ds_docto_xml
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
         HEIGHT             = 7.38
         WIDTH              = 141.57.
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

/* SETTINGS FOR FILL-IN int_ds_docto_xml.chave-ref-oper-triangular IN FRAME f-main
   EXP-LABEL EXP-FORMAT                                                 */
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

&Scoped-define SELF-NAME int_ds_docto_xml.chave-ref-oper-triangular
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL int_ds_docto_xml.chave-ref-oper-triangular V-table-Win
ON VALUE-CHANGED OF int_ds_docto_xml.chave-ref-oper-triangular IN FRAME f-main /* Chave de acesso */
DO:
        FIND FIRST docum-est NO-LOCK
        WHERE docum-est.cod-chave-aces-nf-eletro = int_ds_docto_xml.chave-ref-oper-triangular:SCREEN-VALUE IN FRAME f-main NO-ERROR.

    IF AVAIL docum-est THEN DO:
        ASSIGN fi-serie-refer:SCREEN-VALUE IN FRAME f-main = docum-est.serie-docto.
        ASSIGN fi-nota-refer:SCREEN-VALUE IN FRAME f-main = docum-est.nro-docto.
    END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME fi-nota-refer
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fi-nota-refer V-table-Win
ON ENTRY OF fi-nota-refer IN FRAME f-main /* Nota referenciada */
DO:
      FIND FIRST docum-est NO-LOCK
        WHERE docum-est.cod-chave-aces-nf-eletro = int_ds_docto_xml.chave-ref-oper-triangular:SCREEN-VALUE IN FRAME f-main NO-ERROR.

    IF AVAIL docum-est THEN DO:
        ASSIGN fi-nota-refer:SCREEN-VALUE IN FRAME f-main = docum-est.nro-docto.

    END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fi-nota-refer V-table-Win
ON LEAVE OF fi-nota-refer IN FRAME f-main /* Nota referenciada */
DO:

    FIND FIRST docum-est NO-LOCK
        WHERE docum-est.cod-chave-aces-nf-eletro = int_ds_docto_xml.chave-ref-oper-triangular:SCREEN-VALUE IN FRAME f-main NO-ERROR.

    IF AVAIL docum-est THEN DO:
        ASSIGN fi-nota-refer:SCREEN-VALUE IN FRAME f-main = docum-est.nro-docto.

    END.
  
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME fi-serie-refer
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fi-serie-refer V-table-Win
ON ENTRY OF fi-serie-refer IN FRAME f-main /* S‚rie referenciada */
DO:
    FIND FIRST docum-est NO-LOCK
        WHERE docum-est.cod-chave-aces-nf-eletro = int_ds_docto_xml.chave-ref-oper-triangular:SCREEN-VALUE IN FRAME f-main NO-ERROR.

    IF AVAIL docum-est THEN DO:
        ASSIGN fi-serie-refer:SCREEN-VALUE IN FRAME f-main = docum-est.serie-docto.

    END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fi-serie-refer V-table-Win
ON LEAVE OF fi-serie-refer IN FRAME f-main /* S‚rie referenciada */
DO:
      FIND FIRST docum-est NO-LOCK
        WHERE docum-est.cod-chave-aces-nf-eletro = int_ds_docto_xml.chave-ref-oper-triangular:SCREEN-VALUE IN FRAME f-main NO-ERROR.

    IF AVAIL docum-est THEN DO:
        ASSIGN fi-serie-refer:SCREEN-VALUE IN FRAME f-main = docum-est.serie-docto.

    END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK V-table-Win 


/* ***************************  Main Block  *************************** */

  &IF DEFINED(UIB_IS_RUNNING) <> 0 &THEN          
    RUN dispatch IN THIS-PROCEDURE ('initialize':U).        
  &ENDIF     
  
  
    FIND FIRST docum-est NO-LOCK
        WHERE docum-est.cod-chave-aces-nf-eletro = int_ds_docto_xml.chave-ref-oper-triangular:SCREEN-VALUE IN FRAME f-main NO-ERROR.

    IF AVAIL docum-est THEN DO:
        ASSIGN fi-nota-refer:SCREEN-VALUE IN FRAME f-main = docum-est.nro-docto.

    END.
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
  {src/adm/template/row-list.i "int_ds_docto_xml"}

  /* Get the record ROWID's from the RECORD-SOURCE.                  */
  {src/adm/template/row-get.i}

  /* FIND each record specified by the RECORD-SOURCE.                */
  {src/adm/template/row-find.i "int_ds_docto_xml"}

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
    
    
    MESSAGE "pi-enable fields"
        VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.

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
/*                                                                                                                                                      */
/*   /* Code placed here will execute AFTER standard behavior.    */                                                                                    */
/*   assign  tot-base-icms-it        = 0                                                                                                                */
/*           tot-base-icms-st-it     = 0                                                                                                                */
/*           tot-desconto-it         = 0                                                                                                                */
/*           tot-icms-it             = 0                                                                                                                */
/*           tot-icms-st-it          = 0                                                                                                                */
/*           tot-ipi-it              = 0                                                                                                                */
/*           tot-nf-it               = 0                                                                                                                */
/*           tot-valor-it            = 0.                                                                                                               */
/*           tot-produtos            = 0.                                                                                                               */
/*           tot-despesas-it         = 0.                                                                                                               */
/*   if avail int_ds_nota_entrada then do:                                                                                                              */
/*       for each int_ds_nota_entrada_produt no-lock where                                                                                              */
/*           int_ds_nota_entrada_produt.nen_cnpj_origem_s  = int_ds_nota_entrada.nen_cnpj_origem_s and                                                  */
/*           int_ds_nota_entrada_produt.nen_notafiscal_n   = int_ds_nota_entrada.nen_notafiscal_n       and                                             */
/*           int_ds_nota_entrada_produt.nen_serie_s        = int_ds_nota_entrada.nen_serie_s:                                                           */
/*           assign                                                                                                                                     */
/*           tot-base-icms-it        = tot-base-icms-it       + int_ds_nota_entrada_produt.nep_baseicms_n                                               */
/*           tot-base-icms-st-it     = tot-base-icms-st-it    + int_ds_nota_entrada_produt.nep_basest_n                                                 */
/*           tot-desconto-it         = tot-desconto-it        + int_ds_nota_entrada_produt.nep_valordesconto_n                                          */
/*           tot-icms-it             = tot-icms-it            + int_ds_nota_entrada_produt.nep_valoricms_n                                              */
/*           tot-icms-st-it          = tot-icms-st-it         + int_ds_nota_entrada_produt.nep_icmsst_n                                                 */
/*           tot-ipi-it              = tot-ipi-it             + int_ds_nota_entrada_produt.nep_valoripi_n                                               */
/*           tot-nf-it               = tot-nf-it              + (int_ds_nota_entrada_produt.nep_valorBRUTO_n                                            */
/*                                                            +  int_ds_nota_entrada_produt.nep_valoripi_n                                              */
/*                                                            +  int_ds_nota_entrada_produt.nep_icmsst_n                                                */
/*                                                            +  int_ds_nota_entrada_produt.nep_valordespesa_n)                                         */
/*                                                            - int_ds_nota_entrada_produt.nep_valordesconto_n                                          */
/*           tot-valor-it            = tot-valor-it           + int_ds_nota_entrada_produt.nep_valorBRUTO_n.                                            */
/*           tot-despesas-it         = tot-despesas-it        + int_ds_nota_entrada_produt.nep_valordespesa_n.                                          */
/*       end.                                                                                                                                           */
/*       assign tot-produtos      = int_ds_nota_entrada.nen_valortotalprodutos_n.                                                                       */
/*              tot-nf            = int_ds_nota_entrada.nen_valortotalprodutos_n - int_ds_nota_entrada.nen_desconto_n                                   */
/*                                + int_ds_nota_entrada.nen_despesas_n                                                                                  */
/*                                + int_ds_nota_entrada.nen_icmsst_n                                                                                    */
/*                                + int_ds_nota_entrada.nen_valoripi_n.                                                                                 */
/*       if  tot-base-icms-it        = int_ds_nota_entrada.nen_baseicms_n                                                                               */
/*           then int_ds_nota_entrada.nen_baseicms_n:bgcolor in frame f-Main = ?. else int_ds_nota_entrada.nen_baseicms_n:bgcolor in frame f-Main = 14. */
/*       if  tot-base-icms-st-it     = int_ds_nota_entrada.nen_basest_n                                                                                 */
/*           then int_ds_nota_entrada.nen_basest_n:bgcolor in frame f-Main = ?. else int_ds_nota_entrada.nen_basest_n:bgcolor in frame f-Main = 14.     */
/*       if  tot-desconto-it         = int_ds_nota_entrada.nen_desconto_n                                                                               */
/*           then int_ds_nota_entrada.nen_desconto_n:bgcolor in frame f-Main = ?. else int_ds_nota_entrada.nen_desconto_n:bgcolor in frame f-Main = 14. */
/*       if  tot-icms-it             = int_ds_nota_entrada.nen_icmsst_n                                                                                 */
/*           then int_ds_nota_entrada.nen_icmsst_n:bgcolor in frame f-Main = ?. else int_ds_nota_entrada.nen_icmsst_n:bgcolor in frame f-Main = 14.     */
/*       if  tot-icms-st-it          = int_ds_nota_entrada.nen_icmsst_n                                                                                 */
/*           then int_ds_nota_entrada.nen_icmsst_n:bgcolor in frame f-Main = ?. else int_ds_nota_entrada.nen_icmsst_n:bgcolor in frame f-Main = 14.     */
/*       if  tot-ipi-it              = int_ds_nota_entrada.nen_valoripi_n                                                                               */
/*           then int_ds_nota_entrada.nen_valoripi_n:bgcolor in frame f-Main = ?. else int_ds_nota_entrada.nen_valoripi_n:bgcolor in frame f-Main = 14. */
/*       if  tot-despesas-it         = int_ds_nota_entrada.nen_despesas_n                                                                               */
/*           then int_ds_nota_entrada.nen_despesas_n:bgcolor in frame f-Main = ?. else int_ds_nota_entrada.nen_despesas_n:bgcolor in frame f-Main = 14. */
/*                                                                                                                                                      */
/*       if  tot-valor-it            = tot-produtos                                                                                                     */
/*           then tot-produtos:bgcolor in frame f-Main = ?. else tot-produtos:bgcolor in frame f-Main = 14.                                             */
/*                                                                                                                                                      */
/*   end.                                                                                                                                               */
/*   display tot-base-icms-it                                                                                                                           */
/*           tot-base-icms-st-it                                                                                                                        */
/*           tot-desconto-it                                                                                                                            */
/*           tot-icms-it                                                                                                                                */
/*           tot-icms-st-it                                                                                                                             */
/*           tot-ipi-it                                                                                                                                 */
/*           tot-nf-it                                                                                                                                  */
/*           tot-nf                                                                                                                                     */
/*           tot-valor-it                                                                                                                               */
/*           tot-produtos                                                                                                                               */
/*           tot-despesas-it                                                                                                                            */
/*       with frame f-Main.                                                                                                                             */
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-after-initialize V-table-Win 
PROCEDURE pi-after-initialize :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

MESSAGE "pi-after-initialize"
    VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.

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


MESSAGE "pi-validade"
    VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.

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
  {src/adm/template/snd-list.i "int_ds_docto_xml"}

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

