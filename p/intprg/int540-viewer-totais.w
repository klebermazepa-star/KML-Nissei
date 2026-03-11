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
{include/i-prgvrs.i INT540-viewer-totais 1.12.00.AVB}

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
&Scoped-Define ENABLED-FIELDS int_ds_docto_xml.vbc ~
int_ds_docto_xml.valor_icms int_ds_docto_xml.valor_ipi ~
int_ds_docto_xml.vbc_cst int_ds_docto_xml.valor_st ~
int_ds_docto_xml.valor_mercad int_ds_docto_xml.tot_desconto ~
int_ds_docto_xml.vNF int_ds_docto_xml.valor_pis ~
int_ds_docto_xml.valor_cofins int_ds_docto_xml.valor_outras ~
int_ds_docto_xml.valor_icms_des 
&Scoped-define ENABLED-TABLES int_ds_docto_xml
&Scoped-define FIRST-ENABLED-TABLE int_ds_docto_xml
&Scoped-Define ENABLED-OBJECTS RECT-24 RECT-26 
&Scoped-Define DISPLAYED-FIELDS int_ds_docto_xml.vbc ~
int_ds_docto_xml.valor_icms int_ds_docto_xml.valor_ipi ~
int_ds_docto_xml.vbc_cst int_ds_docto_xml.valor_st ~
int_ds_docto_xml.valor_mercad int_ds_docto_xml.tot_desconto ~
int_ds_docto_xml.vNF int_ds_docto_xml.valor_pis ~
int_ds_docto_xml.valor_cofins int_ds_docto_xml.valor_outras ~
int_ds_docto_xml.valor_icms_des 
&Scoped-define DISPLAYED-TABLES int_ds_docto_xml
&Scoped-define FIRST-DISPLAYED-TABLE int_ds_docto_xml
&Scoped-Define DISPLAYED-OBJECTS tot-base-icms-it tot-icms-it tot-ipi-it ~
tot-base-icms-st-it tot-icms-st-it tot-valor-it tot-desconto-it tot-nf-it ~
tot-tot-pis-it tot-cofins-it tot-outras-it tot-icms-des 

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
ep_codigo||y|custom.int_ds_docto_xml.ep_codigo
</FOREIGN-KEYS> 
<EXECUTING-CODE>
**************************
* Set attributes related to FOREIGN KEYS
*/
RUN set-attribute-list (
    'Keys-Accepted = ,
     Keys-Supplied = "ep_codigo"':U).
/**************************
</EXECUTING-CODE> */
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD fnTrataNuloDec V-table-Win 
FUNCTION fnTrataNuloDec RETURNS decimal
  ( p-valor as decimal )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */
DEFINE VARIABLE tot-base-icms-it AS DECIMAL FORMAT "->>>>,>>>,>>9.99999":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 16.13 BY .87 NO-UNDO.

DEFINE VARIABLE tot-base-icms-st-it AS DECIMAL FORMAT "->>>>,>>>,>>9.99999":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 16.13 BY .87 NO-UNDO.

DEFINE VARIABLE tot-cofins-it AS DECIMAL FORMAT "->>>>,>>>,>>9.99999":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 16.13 BY .87 NO-UNDO.

DEFINE VARIABLE tot-desconto-it AS DECIMAL FORMAT "->>>>,>>>,>>9.99999":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 16.13 BY .87 NO-UNDO.

DEFINE VARIABLE tot-icms-des AS DECIMAL FORMAT "->>>>,>>>,>>9.99999":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 16.13 BY .87 NO-UNDO.

DEFINE VARIABLE tot-icms-it AS DECIMAL FORMAT "->>>>,>>>,>>9.99999":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 16.13 BY .87 NO-UNDO.

DEFINE VARIABLE tot-icms-st-it AS DECIMAL FORMAT "->>>>,>>>,>>9.99999":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 16.13 BY .87 NO-UNDO.

DEFINE VARIABLE tot-ipi-it AS DECIMAL FORMAT "->>>>,>>>,>>9.99999":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 16.13 BY .87 NO-UNDO.

DEFINE VARIABLE tot-nf-it AS DECIMAL FORMAT "->>>>,>>>,>>9.99999":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 16.13 BY .87 NO-UNDO.

DEFINE VARIABLE tot-outras-it AS DECIMAL FORMAT "->>>>,>>>,>>9.99999":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 16.13 BY .87 NO-UNDO.

DEFINE VARIABLE tot-tot-pis-it AS DECIMAL FORMAT "->>>>,>>>,>>9.99999":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 16.13 BY .87 NO-UNDO.

DEFINE VARIABLE tot-valor-it AS DECIMAL FORMAT "->>>>,>>>,>>9.99999":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 16.13 BY .87 NO-UNDO.

DEFINE RECTANGLE RECT-24
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 141.63 BY 3.2.

DEFINE RECTANGLE RECT-26
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 141.63 BY 3.2.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME f-main
     int_ds_docto_xml.vbc AT ROW 2.2 COL 8.88 NO-LABEL WIDGET-ID 44
          VIEW-AS FILL-IN 
          SIZE 16.13 BY .87
     int_ds_docto_xml.valor_icms AT ROW 2.2 COL 23.38 COLON-ALIGNED NO-LABEL WIDGET-ID 32
          VIEW-AS FILL-IN 
          SIZE 16.13 BY .87
     int_ds_docto_xml.valor_ipi AT ROW 2.2 COL 40.25 COLON-ALIGNED NO-LABEL WIDGET-ID 34
          VIEW-AS FILL-IN 
          SIZE 16.13 BY .87
     int_ds_docto_xml.vbc_cst AT ROW 2.2 COL 56.75 COLON-ALIGNED NO-LABEL WIDGET-ID 46
          VIEW-AS FILL-IN 
          SIZE 16.13 BY .87
     int_ds_docto_xml.valor_st AT ROW 2.2 COL 73.63 COLON-ALIGNED NO-LABEL WIDGET-ID 42
          VIEW-AS FILL-IN 
          SIZE 16.13 BY .87
     int_ds_docto_xml.valor_mercad AT ROW 2.2 COL 90.13 COLON-ALIGNED NO-LABEL WIDGET-ID 36
          VIEW-AS FILL-IN 
          SIZE 16.13 BY .87
     int_ds_docto_xml.tot_desconto AT ROW 2.2 COL 107 COLON-ALIGNED NO-LABEL WIDGET-ID 110
          VIEW-AS FILL-IN 
          SIZE 16.13 BY .87
     int_ds_docto_xml.vNF AT ROW 2.2 COL 123.63 COLON-ALIGNED NO-LABEL WIDGET-ID 48 FORMAT ">,>>>,>>>,>>>,>>9.99999"
          VIEW-AS FILL-IN 
          SIZE 16.13 BY .87
     tot-base-icms-it AT ROW 3.43 COL 7 COLON-ALIGNED NO-LABEL WIDGET-ID 142
     tot-icms-it AT ROW 3.43 COL 23.38 COLON-ALIGNED NO-LABEL WIDGET-ID 152
     tot-ipi-it AT ROW 3.43 COL 40.25 COLON-ALIGNED NO-LABEL WIDGET-ID 154
     tot-base-icms-st-it AT ROW 3.43 COL 56.75 COLON-ALIGNED NO-LABEL WIDGET-ID 156
     tot-icms-st-it AT ROW 3.43 COL 73.63 COLON-ALIGNED NO-LABEL WIDGET-ID 158
     tot-valor-it AT ROW 3.43 COL 90.13 COLON-ALIGNED NO-LABEL WIDGET-ID 160
     tot-desconto-it AT ROW 3.43 COL 107 COLON-ALIGNED NO-LABEL WIDGET-ID 162
     tot-nf-it AT ROW 3.43 COL 123.63 COLON-ALIGNED NO-LABEL WIDGET-ID 164
     int_ds_docto_xml.valor_pis AT ROW 6.43 COL 8.88 NO-LABEL WIDGET-ID 116
          VIEW-AS FILL-IN 
          SIZE 16.13 BY .87
     int_ds_docto_xml.valor_cofins AT ROW 6.43 COL 23.75 COLON-ALIGNED NO-LABEL WIDGET-ID 112
          VIEW-AS FILL-IN 
          SIZE 16.13 BY .87
     int_ds_docto_xml.valor_outras AT ROW 6.43 COL 40.25 COLON-ALIGNED NO-LABEL WIDGET-ID 180
          VIEW-AS FILL-IN 
          SIZE 16.13 BY .87
     int_ds_docto_xml.valor_icms_des AT ROW 6.43 COL 56.75 COLON-ALIGNED NO-LABEL WIDGET-ID 192
          VIEW-AS FILL-IN 
          SIZE 16.13 BY .87
     tot-tot-pis-it AT ROW 7.57 COL 8.88 NO-LABEL WIDGET-ID 166
     tot-cofins-it AT ROW 7.57 COL 23.75 COLON-ALIGNED NO-LABEL WIDGET-ID 168
     tot-outras-it AT ROW 7.57 COL 40.25 COLON-ALIGNED NO-LABEL WIDGET-ID 190
     tot-icms-des AT ROW 7.57 COL 56.75 COLON-ALIGNED NO-LABEL WIDGET-ID 196
     "Base ICMS ST" VIEW-AS TEXT
          SIZE 13.63 BY .67 AT ROW 1.43 COL 58.63 WIDGET-ID 62
     "Valor Total NF" VIEW-AS TEXT
          SIZE 13.63 BY .67 AT ROW 1.43 COL 125.63 WIDGET-ID 96
     "ICMS Desonerado" VIEW-AS TEXT
          SIZE 16 BY .67 AT ROW 5.57 COL 59 WIDGET-ID 194
     "Descontos" VIEW-AS TEXT
          SIZE 10.63 BY .67 AT ROW 1.43 COL 109.13 WIDGET-ID 138
     "Vl Despesas" VIEW-AS TEXT
          SIZE 12 BY .67 AT ROW 5.57 COL 43 WIDGET-ID 186
     "Valor ICMS" VIEW-AS TEXT
          SIZE 11 BY .67 AT ROW 1.5 COL 26 WIDGET-ID 58
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1 SCROLLABLE  WIDGET-ID 100.

/* DEFINE FRAME statement is approaching 4K Bytes.  Breaking it up   */
DEFINE FRAME f-main
     "Valor ICMS ST" VIEW-AS TEXT
          SIZE 13.63 BY .67 AT ROW 1.43 COL 76.13 WIDGET-ID 66
     "Itens:" VIEW-AS TEXT
          SIZE 5.25 BY .67 AT ROW 3.43 COL 2.13 WIDGET-ID 146
     "Vl COFINS" VIEW-AS TEXT
          SIZE 11 BY .67 AT ROW 5.57 COL 26.63 WIDGET-ID 136
     "Itens:" VIEW-AS TEXT
          SIZE 5.25 BY .67 AT ROW 7.57 COL 1.38 WIDGET-ID 150
     "Valor Produtos" VIEW-AS TEXT
          SIZE 13.63 BY .67 AT ROW 1.5 COL 92.63 WIDGET-ID 70
     "Vl PIS" VIEW-AS TEXT
          SIZE 7 BY .67 AT ROW 5.57 COL 9.75 WIDGET-ID 134
     "Base C lculo" VIEW-AS TEXT
          SIZE 12 BY .67 AT ROW 1.43 COL 9.38 WIDGET-ID 50
     "Nota:" VIEW-AS TEXT
          SIZE 5.25 BY .67 AT ROW 2.2 COL 2 WIDGET-ID 144
     "Nota:" VIEW-AS TEXT
          SIZE 5.25 BY .67 AT ROW 6.43 COL 1.63 WIDGET-ID 148
     "Valor IPI" VIEW-AS TEXT
          SIZE 8.63 BY .67 AT ROW 1.5 COL 43 WIDGET-ID 102
     RECT-24 AT ROW 1.8 COL 1 WIDGET-ID 172
     RECT-26 AT ROW 6 COL 1 WIDGET-ID 176
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
         HEIGHT             = 8.57
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

/* SETTINGS FOR FILL-IN tot-base-icms-it IN FRAME f-main
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN tot-base-icms-st-it IN FRAME f-main
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN tot-cofins-it IN FRAME f-main
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN tot-desconto-it IN FRAME f-main
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN tot-icms-des IN FRAME f-main
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN tot-icms-it IN FRAME f-main
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN tot-icms-st-it IN FRAME f-main
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN tot-ipi-it IN FRAME f-main
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN tot-nf-it IN FRAME f-main
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN tot-outras-it IN FRAME f-main
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN tot-tot-pis-it IN FRAME f-main
   NO-ENABLE ALIGN-L                                                    */
/* SETTINGS FOR FILL-IN tot-valor-it IN FRAME f-main
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN int_ds_docto_xml.valor_pis IN FRAME f-main
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN int_ds_docto_xml.vbc IN FRAME f-main
   ALIGN-L EXP-LABEL                                                    */
/* SETTINGS FOR FILL-IN int_ds_docto_xml.vNF IN FRAME f-main
   EXP-FORMAT                                                           */
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
          tot-cofins-it           = 0
          tot-desconto-it         = 0
          tot-icms-it             = 0
          tot-icms-st-it          = 0
          tot-ipi-it              = 0
          tot-nf-it               = 0
          tot-tot-pis-it          = 0
          tot-valor-it            = 0
          tot-outras-it           = 0
          tot-icms-des            = 0.

  if avail int_ds_docto_xml then do:
      for each int_ds_it_docto_xml no-lock where
          int_ds_it_docto_xml.tipo_nota     = int_ds_docto_xml.tipo_nota    and 
          int_ds_it_docto_xml.cod_emitente  = int_ds_docto_xml.cod_emitente and 
          int_ds_it_docto_xml.nNF           = int_ds_docto_xml.nNF          and 
          int_ds_it_docto_xml.serie         = int_ds_docto_xml.serie:
          assign 
          tot-base-icms-it        = tot-base-icms-it       + fnTrataNuloDec( int_ds_it_docto_xml.vbc_icms)
          tot-base-icms-st-it     = tot-base-icms-st-it    + fnTrataNuloDec( int_ds_it_docto_xml.vbcst   )     
          tot-cofins-it           = tot-cofins-it          + fnTrataNuloDec( int_ds_it_docto_xml.vcofins )
          tot-desconto-it         = tot-desconto-it        + fnTrataNuloDec( int_ds_it_docto_xml.vDesc   )
          tot-icms-it             = tot-icms-it            + fnTrataNuloDec( int_ds_it_docto_xml.vicms   )
          tot-icms-st-it          = tot-icms-st-it         + fnTrataNuloDec( int_ds_it_docto_xml.vicmsst )
          tot-ipi-it              = tot-ipi-it             + fnTrataNuloDec( int_ds_it_docto_xml.vipi    )
          tot-nf-it               = tot-nf-it              + fnTrataNuloDec( int_ds_it_docto_xml.vProd   )
                                                           + fnTrataNuloDec( int_ds_it_docto_xml.vipi    )
                                                           + fnTrataNuloDec( int_ds_it_docto_xml.vicmsst )
                                                           - fnTrataNuloDec( int_ds_it_docto_xml.vDesc   )
                                                           - fnTrataNuloDec( int_ds_it_docto_xml.vicmsdeson)
          tot-tot-pis-it          = tot-tot-pis-it         + fnTrataNuloDec( int_ds_it_docto_xml.vpis    )
          tot-valor-it            = tot-valor-it           + fnTrataNuloDec( int_ds_it_docto_xml.vProd   )
          tot-outras-it           = tot-outras-it          + fnTrataNuloDec( int_ds_it_docto_xml.vOutro  )
          tot-icms-des            = tot-icms-des           + fnTrataNuloDec( int_ds_it_docto_xml.vicmsdeson). 
      end.
      tot-nf-it = tot-nf-it + fnTrataNuloDec( int_ds_docto_xml.valor_frete  )
                            + fnTrataNuloDec( int_ds_docto_xml.valor_seguro )
                            + fnTrataNuloDec( int_ds_docto_xml.valor_outras ).
      tot-nf-it = round(tot-nf-it,2).

      if  tot-base-icms-it        = fnTrataNuloDec(int_ds_docto_xml.vbc )
          then int_ds_docto_xml.vbc:bgcolor in frame f-Main = ?. else int_ds_docto_xml.vbc:bgcolor in frame f-Main = 14.
      if  tot-base-icms-st-it     = int_ds_docto_xml.vbc_cst
          then int_ds_docto_xml.vbc_cst:bgcolor in frame f-Main = ?. else int_ds_docto_xml.vbc_cst:bgcolor in frame f-Main = 14.
      if  tot-cofins-it           = fnTrataNuloDec(int_ds_docto_xml.valor_cofins)
          then int_ds_docto_xml.valor_cofins:bgcolor in frame f-Main = ?. else int_ds_docto_xml.valor_cofins:bgcolor in frame f-Main = 14.
      if  tot-desconto-it         = fnTrataNuloDec(int_ds_docto_xml.tot_desconto)
          then int_ds_docto_xml.tot_desconto:bgcolor in frame f-Main = ?. else int_ds_docto_xml.tot_desconto:bgcolor in frame f-Main = 14.
      if  tot-icms-it             = fnTrataNuloDec(int_ds_docto_xml.valor_icms)
          then int_ds_docto_xml.valor_icms:bgcolor in frame f-Main = ?. else int_ds_docto_xml.valor_icms:bgcolor in frame f-Main = 14.
      if  tot-icms-st-it          = fnTrataNuloDec(int_ds_docto_xml.valor_st)
          then int_ds_docto_xml.valor_st:bgcolor in frame f-Main = ?. else int_ds_docto_xml.valor_st:bgcolor in frame f-Main = 14.
      if  tot-ipi-it              = fnTrataNuloDec(int_ds_docto_xml.valor_ipi)
          then int_ds_docto_xml.valor_ipi:bgcolor in frame f-Main = ?. else int_ds_docto_xml.valor_ipi:bgcolor in frame f-Main = 14.
      if  tot-nf-it               = fnTrataNuloDec(int_ds_docto_xml.vNF )
          then int_ds_docto_xml.vNF:bgcolor in frame f-Main = ?. else int_ds_docto_xml.vNF:bgcolor in frame f-Main = 14.
      if  tot-tot-pis-it          = fnTrataNuloDec(int_ds_docto_xml.valor_pis)
          then int_ds_docto_xml.valor_pis:bgcolor in frame f-Main = ?. else int_ds_docto_xml.valor_pis:bgcolor in frame f-Main = 14.
      if  tot-valor-it            = fnTrataNuloDec(int_ds_docto_xml.valor_mercad)
          then int_ds_docto_xml.valor_mercad:bgcolor in frame f-Main = ?. else int_ds_docto_xml.valor_mercad:bgcolor in frame f-Main = 14.
      if  tot-outras-it           = fnTrataNuloDec(int_ds_docto_xml.valor_outras)
          then int_ds_docto_xml.valor_outras:bgcolor in frame f-Main = ?. else int_ds_docto_xml.valor_outras:bgcolor in frame f-Main = 14.
      if  tot-icms-des            = fnTrataNuloDec(int_ds_docto_xml.valor_icms_des)
          then int_ds_docto_xml.valor_icms_des:bgcolor in frame f-Main = ?. else int_ds_docto_xml.valor_icms_des:bgcolor in frame f-Main = 14.
  end.
  display tot-base-icms-it      
          tot-base-icms-st-it   
          tot-cofins-it         
          tot-desconto-it       
          tot-icms-it           
          tot-icms-st-it        
          tot-ipi-it            
          tot-nf-it             
          tot-tot-pis-it        
          tot-valor-it    
          tot-outras-it
          tot-icms-des
          
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
  {src/adm/template/sndkycas.i "ep_codigo" "int_ds_docto_xml" "ep_codigo"}

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

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION fnTrataNuloDec V-table-Win 
FUNCTION fnTrataNuloDec RETURNS decimal
  ( p-valor as decimal ) :
    if p-valor = ? then RETURN 0.
    else return p-valor.

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

