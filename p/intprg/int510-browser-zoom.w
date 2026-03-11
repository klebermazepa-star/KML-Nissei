&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI ADM1
&ANALYZE-RESUME
/* Connected Databases 
          custom           PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS B-table-Win 
/*:T *******************************************************************************
** Copyright DATASUL S.A. (1997)
** Todos os Direitos Reservados.
**
** Este fonte e de propriedade exclusiva da DATASUL, sua reproducao
** parcial ou total por qualquer meio, so podera ser feita mediante
** autorizacao expressa.
*******************************************************************************/
{include/i-prgvrs.i BINT-DS-DOCT-XML 1.12.00.AVB}

/* Create an unnamed pool to store all the widgets created 
     by this procedure. This is a good default which assures
     that this procedure's triggers and internal procedures 
     will execute in this procedure's storage, and that proper
     cleanup will occur on deletion of the procedure. */

CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */
&Scop adm-attribute-dlg support/browserd.w

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */
define variable c-lista-valor as character init '':U no-undo.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE SmartBrowser
&Scoped-define DB-AWARE no

&Scoped-define ADM-SUPPORTED-LINKS Record-Source,Record-Target,TableIO-Target

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME F-Main
&Scoped-define BROWSE-NAME br-table

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES int_ds_docto_xml

/* Define KEY-PHRASE in case it is used by any query. */
&Scoped-define KEY-PHRASE TRUE

/* Definitions for BROWSE br-table                                      */
&Scoped-define FIELDS-IN-QUERY-br-table int_ds_docto_xml.cnpj int_ds_docto_xml.cod_emitente int_ds_docto_xml.xNome int_ds_docto_xml.nNF int_ds_docto_xml.serie int_ds_docto_xml.cod_estab int_ds_docto_xml.dEmi int_ds_docto_xml.num_pedido int_ds_docto_xml.tipo_nota int_ds_docto_xml.cfop   
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-table   
&Scoped-define SELF-NAME br-table
&Scoped-define QUERY-STRING-br-table FOR EACH int_ds_docto_xml WHERE         int_ds_docto_xml.cnpj >= c-cnpjorigem-ini     and int_ds_docto_xml.cnpj <= c-cnpjorigem-fim     and int_ds_docto_xml.serie >= c-serie-ini     and int_ds_docto_xml.serie <= c-serie-fim     and INT_ds_docto_xml.nNF >= i-notafiscal-ini     and INT_ds_docto_xml.nNF <= i-notafiscal-fim     and int_ds_docto_xml.cod_emitente >= i-emitente-ini     and int_ds_docto_xml.cod_emitente <= i-emitente-fim     and int_ds_docto_xml.situacao <> 9     and int_ds_docto_xml.tipo_nota <> 3     and (int_ds_docto_xml.cnpj_dest  = "79430682025540" OR int_ds_docto_xml.cnpj_dest  = "05912018000183"  OR int_ds_docto_xml.cnpj_dest  = "05912018000426")     ~{&SORTBY-PHRASE} INDEXED-REPOSITION QUERY-TUNING(NO-LOOKAHEAD)
&Scoped-define OPEN-QUERY-br-table OPEN QUERY {&SELF-NAME} FOR EACH int_ds_docto_xml WHERE         int_ds_docto_xml.cnpj >= c-cnpjorigem-ini     and int_ds_docto_xml.cnpj <= c-cnpjorigem-fim     and int_ds_docto_xml.serie >= c-serie-ini     and int_ds_docto_xml.serie <= c-serie-fim     and INT_ds_docto_xml.nNF >= i-notafiscal-ini     and INT_ds_docto_xml.nNF <= i-notafiscal-fim     and int_ds_docto_xml.cod_emitente >= i-emitente-ini     and int_ds_docto_xml.cod_emitente <= i-emitente-fim     and int_ds_docto_xml.situacao <> 9     and int_ds_docto_xml.tipo_nota <> 3     and (int_ds_docto_xml.cnpj_dest  = "79430682025540" OR int_ds_docto_xml.cnpj_dest  = "05912018000183"  OR int_ds_docto_xml.cnpj_dest  = "05912018000426")     ~{&SORTBY-PHRASE} INDEXED-REPOSITION QUERY-TUNING(NO-LOOKAHEAD).
&Scoped-define TABLES-IN-QUERY-br-table int_ds_docto_xml
&Scoped-define FIRST-TABLE-IN-QUERY-br-table int_ds_docto_xml


/* Definitions for FRAME F-Main                                         */

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS c-cnpjorigem-ini c-cnpjorigem-fim IMAGE-1 ~
IMAGE-2 IMAGE-7 IMAGE-8 IMAGE-9 IMAGE-10 IMAGE-11 IMAGE-12 i-notafiscal-ini ~
i-notafiscal-fim c-serie-ini c-serie-fim i-emitente-ini i-emitente-fim ~
bt-confirma br-table 
&Scoped-Define DISPLAYED-OBJECTS c-cnpjorigem-ini c-cnpjorigem-fim ~
i-notafiscal-ini i-notafiscal-fim c-serie-ini c-serie-fim i-emitente-ini ~
i-emitente-fim 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _XFTR "Foreign Keys" B-table-Win _INLINE
/* Actions: ? adm/support/keyedit.w ? ? ? */
/* STRUCTURED-DATA
<KEY-OBJECT>
&BROWSE-NAME
</KEY-OBJECT>
<FOREIGN-KEYS>
num-pedido||y|custom.int_ds_docto_xml.num-pedido
</FOREIGN-KEYS> 
<EXECUTING-CODE>
**************************
* Set attributes related to FOREIGN KEYS
*/
RUN set-attribute-list (
    'Keys-Accepted = ,
     Keys-Supplied = "num_pedido"':U).

/* Tell the ADM to use the OPEN-QUERY-CASES. */
&Scoped-define OPEN-QUERY-CASES RUN dispatch ('open-query-cases':U).
/**************************
</EXECUTING-CODE> */
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _XFTR "Advanced Query Options" B-table-Win _INLINE
/* Actions: ? adm/support/advqedit.w ? ? ? */
/* STRUCTURED-DATA
<KEY-OBJECT>
&BROWSE-NAME
</KEY-OBJECT>
<SORTBY-OPTIONS>
</SORTBY-OPTIONS>
<SORTBY-RUN-CODE>
************************
* Set attributes related to SORTBY-OPTIONS */
RUN set-attribute-list (
    'SortBy-Options = ""':U).
/************************
</SORTBY-RUN-CODE>
<FILTER-ATTRIBUTES>
************************
* Initialize Filter Attributes */
RUN set-attribute-list IN THIS-PROCEDURE ('
  Filter-Value=':U).
/************************
</FILTER-ATTRIBUTES> */   

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */
DEFINE BUTTON bt-confirma 
     IMAGE-UP FILE "image\im-sav":U
     LABEL "Button 1" 
     SIZE 5.14 BY 1.

DEFINE VARIABLE c-cnpjorigem-fim AS CHARACTER FORMAT "X(15)":U INITIAL "ZZZZZZZZZZZZZZZZZ" 
     VIEW-AS FILL-IN 
     SIZE 15 BY .88 NO-UNDO.

DEFINE VARIABLE c-cnpjorigem-ini AS CHARACTER FORMAT "X(15)":U 
     LABEL "Cnpj" 
     VIEW-AS FILL-IN 
     SIZE 15 BY .88 NO-UNDO.

DEFINE VARIABLE c-serie-fim AS CHARACTER FORMAT "X(5)":U INITIAL "ZZZZZ" 
     VIEW-AS FILL-IN 
     SIZE 7.57 BY .88 NO-UNDO.

DEFINE VARIABLE c-serie-ini AS CHARACTER FORMAT "X(5)":U 
     LABEL "S‚rie" 
     VIEW-AS FILL-IN 
     SIZE 7.57 BY .88 NO-UNDO.

DEFINE VARIABLE i-emitente-fim AS INTEGER FORMAT ">>>,>>>,>>9":U INITIAL 999999999 
     VIEW-AS FILL-IN 
     SIZE 13.14 BY .88 NO-UNDO.

DEFINE VARIABLE i-emitente-ini AS INTEGER FORMAT ">>>,>>>,>>9":U INITIAL 0 
     LABEL "Emitente" 
     VIEW-AS FILL-IN 
     SIZE 13.14 BY .88 NO-UNDO.

DEFINE VARIABLE i-notafiscal-fim AS /*INTEGER FORMAT ">>>,>>>,>>9":U*/ CHAR FORMAT "x(10)" INITIAL 9999999999 
     VIEW-AS FILL-IN 
     SIZE 13.14 BY .88 NO-UNDO.

DEFINE VARIABLE i-notafiscal-ini AS /*INTEGER FORMAT ">>>,>>>,>>9":U*/ CHAR FORMAT "x(10)" INITIAL 0 
     LABEL "Nota" 
     VIEW-AS FILL-IN 
     SIZE 13.14 BY .88 NO-UNDO.

DEFINE IMAGE IMAGE-1
     FILENAME "image\ii-fir":U
     SIZE 2.86 BY 1.

DEFINE IMAGE IMAGE-10
     FILENAME "image\ii-las":U
     SIZE 2.86 BY 1.

DEFINE IMAGE IMAGE-11
     FILENAME "image\ii-fir":U
     SIZE 2.86 BY 1.

DEFINE IMAGE IMAGE-12
     FILENAME "image\ii-las":U
     SIZE 2.86 BY 1.

DEFINE IMAGE IMAGE-2
     FILENAME "image\ii-las":U
     SIZE 2.86 BY 1.

DEFINE IMAGE IMAGE-7
     FILENAME "image\ii-fir":U
     SIZE 2.86 BY 1.

DEFINE IMAGE IMAGE-8
     FILENAME "image\ii-las":U
     SIZE 2.86 BY 1.

DEFINE IMAGE IMAGE-9
     FILENAME "image\ii-fir":U
     SIZE 2.86 BY 1.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-table FOR 
      int_ds_docto_xml SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-table
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-table B-table-Win _FREEFORM
  QUERY br-table NO-LOCK DISPLAY
      int_ds_docto_xml.cnpj FORMAT "x(14)":U width 16
      int_ds_docto_xml.cod_emitente
      int_ds_docto_xml.xNome column-label "RazÆo Social" 
      int_ds_docto_xml.nNF
      int_ds_docto_xml.serie FORMAT "x(3)":U
      int_ds_docto_xml.cod_estab format "x(5)"
      int_ds_docto_xml.dEmi FORMAT "99/99/9999":U width 11
      int_ds_docto_xml.num_pedido FORMAT ">>>>>>>>9":U
      int_ds_docto_xml.tipo_nota FORMAT ">9":U
      int_ds_docto_xml.cfop FORMAT ">>>9":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ASSIGN SEPARATORS SIZE 113 BY 8.75.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME F-Main
     c-cnpjorigem-ini AT ROW 1 COL 6 COLON-ALIGNED WIDGET-ID 2
     c-cnpjorigem-fim AT ROW 1 COL 42 COLON-ALIGNED NO-LABEL WIDGET-ID 4
     i-notafiscal-ini AT ROW 2 COL 8 COLON-ALIGNED WIDGET-ID 10
     i-notafiscal-fim AT ROW 2 COL 42 COLON-ALIGNED NO-LABEL WIDGET-ID 12
     c-serie-ini AT ROW 3 COL 13.57 COLON-ALIGNED WIDGET-ID 18
     c-serie-fim AT ROW 3 COL 42 COLON-ALIGNED NO-LABEL WIDGET-ID 20
     i-emitente-ini AT ROW 4 COL 8 COLON-ALIGNED WIDGET-ID 28
     i-emitente-fim AT ROW 4 COL 42 COLON-ALIGNED NO-LABEL WIDGET-ID 26
     bt-confirma AT ROW 4 COL 76
     br-table AT ROW 5.25 COL 2
     IMAGE-1 AT ROW 1.04 COL 23.57
     IMAGE-2 AT ROW 1.04 COL 41
     IMAGE-7 AT ROW 2 COL 23.57 WIDGET-ID 6
     IMAGE-8 AT ROW 2 COL 41 WIDGET-ID 8
     IMAGE-9 AT ROW 3.04 COL 23.57 WIDGET-ID 14
     IMAGE-10 AT ROW 3.04 COL 41 WIDGET-ID 16
     IMAGE-11 AT ROW 4 COL 23.57 WIDGET-ID 24
     IMAGE-12 AT ROW 4 COL 41 WIDGET-ID 22
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1 SCROLLABLE 
         BGCOLOR 8 FGCOLOR 0  WIDGET-ID 100.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: SmartBrowser
   Allow: Basic,Browse
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
  CREATE WINDOW B-table-Win ASSIGN
         HEIGHT             = 13.13
         WIDTH              = 116.72.
/* END WINDOW DEFINITION */
                                                                        */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _INCLUDED-LIB B-table-Win 
/* ************************* Included-Libraries *********************** */

{src/adm/method/browser.i}
{include/c-brwzoo.i}
{utp/ut-glob.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME




/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW B-table-Win
  NOT-VISIBLE,,RUN-PERSISTENT                                           */
/* SETTINGS FOR FRAME F-Main
   NOT-VISIBLE FRAME-NAME Size-to-Fit L-To-R                            */
/* BROWSE-TAB br-table bt-confirma F-Main */
ASSIGN 
       FRAME F-Main:SCROLLABLE       = FALSE
       FRAME F-Main:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-table
/* Query rebuild information for BROWSE br-table
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH int_ds_docto_xml WHERE
        int_ds_docto_xml.cnpj >= c-cnpjorigem-ini
    and int_ds_docto_xml.cnpj <= c-cnpjorigem-fim
    and int_ds_docto_xml.serie >= c-serie-ini
    and int_ds_docto_xml.serie <= c-serie-fim
    and int_ds_docto_xml.nNF >= i-notafiscal-ini
    and int_ds_docto_xml.nNF <= i-notafiscal-fim
    and int_ds_docto_xml.cod-emitente >= i-emitente-ini
    and int_ds_docto_xml.cod-emitente <= i-emitente-fim
    and int_ds_docto_xml.situacao <> 9
    and int_ds_docto_xml.tipo_nota <> 3
    and (int_ds_docto_xml.CNPJ-dest = "79430682025540"
    or int_ds_docto_xml.CNPJ-dest = "79430682057400" )	/* 973 */
    ~{&SORTBY-PHRASE} INDEXED-REPOSITION QUERY-TUNING(NO-LOOKAHEAD).
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION KEY-PHRASE SORTBY-PHRASE"
     _Where[1]         = "custom.int_ds_docto_xml.situacao = 5"
     _Query            is NOT OPENED
*/  /* BROWSE br-table */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK FRAME F-Main
/* Query rebuild information for FRAME F-Main
     _Options          = "NO-LOCK"
     _Query            is NOT OPENED
*/  /* FRAME F-Main */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define BROWSE-NAME br-table
&Scoped-define SELF-NAME br-table
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-table B-table-Win
ON MOUSE-SELECT-DBLCLICK OF br-table IN FRAME F-Main
DO:
    RUN New-State('DblClick':U).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-table B-table-Win
ON ROW-ENTRY OF br-table IN FRAME F-Main
DO:
  /* This code displays initial values for newly added or copied rows. */
  {src/adm/template/brsentry.i}
  
  run new-state('New-Line|':U + string(rowid({&FIRST-TABLE-IN-QUERY-{&BROWSE-NAME}}))).
  run seta-valor.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-table B-table-Win
ON ROW-LEAVE OF br-table IN FRAME F-Main
DO:
    /* Do not disable this code or no updates will take place except
     by pressing the Save button on an Update SmartPanel. */
   {src/adm/template/brsleave.i}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-table B-table-Win
ON VALUE-CHANGED OF br-table IN FRAME F-Main
DO:
  /* This ADM trigger code must be preserved in order to notify other
     objects when the browser's current row changes. */
  {src/adm/template/brschnge.i}
  run new-state('New-Line|':U + string(rowid({&FIRST-TABLE-IN-QUERY-{&BROWSE-NAME}}))).
  run new-state('Value-Changed|':U + string(this-procedure)).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-confirma
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-confirma B-table-Win
ON CHOOSE OF bt-confirma IN FRAME F-Main /* Button 1 */
DO:
  assign input frame {&frame-name} c-cnpjorigem-fim c-cnpjorigem-ini 
      c-serie-fim c-serie-ini i-notafiscal-fim i-notafiscal-ini
      i-emitente-ini i-emitente-fim.
  RUN dispatch IN THIS-PROCEDURE ('open-query':U).
  apply 'value-changed':U to {&browse-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK B-table-Win 


/* ***************************  Main Block  *************************** */

&IF DEFINED(UIB_IS_RUNNING) <> 0 &THEN          
RUN dispatch IN THIS-PROCEDURE ('initialize':U).        
&ENDIF

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE adm-open-query-cases B-table-Win  adm/support/_adm-opn.p
PROCEDURE adm-open-query-cases :
/*------------------------------------------------------------------------------
  Purpose:     Opens different cases of the query based on attributes
               such as the 'Key-Name', or 'SortBy-Case'
  Parameters:  <none>
------------------------------------------------------------------------------*/
  DEF VAR Filter-Value AS CHAR NO-UNDO.

  /* Copy 'Filter-Attributes' into local variables. */
  RUN get-attribute ('Filter-Value':U).
  Filter-Value = RETURN-VALUE.

  /* No Foreign keys are accepted by this SmartObject. */

  {&OPEN-QUERY-{&BROWSE-NAME}}

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE adm-row-available B-table-Win  _ADM-ROW-AVAILABLE
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI B-table-Win  _DEFAULT-DISABLE
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-open-query-cases B-table-Win 
PROCEDURE local-open-query-cases :
/*------------------------------------------------------------------------------
  Purpose:     Override standard ADM method
  Notes:       
------------------------------------------------------------------------------*/

  /* Code placed here will execute PRIOR to standard behavior. */

  /* Dispatch standard ADM method.                             
  RUN dispatch IN THIS-PROCEDURE ( INPUT 'open-query-cases':U ) .
    */
    
  /* Code placed here will execute AFTER standard behavior.    */
    OPEN QUERY br-table FOR EACH int_ds_docto_xml NO-LOCK WHERE
            int_ds_docto_xml.cnpj >= c-cnpjorigem-ini
        and int_ds_docto_xml.cnpj <= c-cnpjorigem-fim
        and int_ds_docto_xml.serie >= c-serie-ini
        and int_ds_docto_xml.serie <= c-serie-fim
        and INT_ds_docto_xml.nNF >= i-notafiscal-ini
        and INT_ds_docto_xml.nNF <= i-notafiscal-fim
        and int_ds_docto_xml.cod_emitente >= i-emitente-ini
        and int_ds_docto_xml.cod_emitente <= i-emitente-fim
        /*and int_ds_docto_xml.situacao <> 3*/
        and int_ds_docto_xml.situacao <> 9
        and int_ds_docto_xml.tipo_nota <> 3                                                                                                           /*10001*/                                       /*10004*/                                             /*10008*/
        and (int_ds_docto_xml.cnpj_dest  = "79430682025540" OR int_ds_docto_xml.cnpj_dest  = "79430682057400"  OR int_ds_docto_xml.cnpj_dest  = "05912018000183"  OR int_ds_docto_xml.cnpj_dest  = "05912018000426" OR int_ds_docto_xml.cnpj_dest = "05912018000850")
        by int_ds_docto_xml.cnpj
          by int_ds_docto_xml.serie
            by int_ds_docto_xml.nNF
         INDEXED-REPOSITION QUERY-TUNING(NO-LOOKAHEAD).

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-view B-table-Win 
PROCEDURE local-view :
/*------------------------------------------------------------------------------
  Purpose:     Override standard ADM method
  Notes:       
------------------------------------------------------------------------------*/

  /* Code placed here will execute PRIOR to standard behavior. */

  /* Dispatch standard ADM method.                             */
  RUN dispatch IN THIS-PROCEDURE ( INPUT 'view':U ) .

  /* Code placed here will execute AFTER standard behavior.    */
  apply 'value-changed':U to {&browse-name} in frame {&frame-name}.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-retorna-valor B-table-Win 
PROCEDURE pi-retorna-valor :
DEFINE INPUT PARAMETER P-CAMPO AS CHARACTER NO-UNDO.

    DEFINE VARIABLE P-VALOR AS CHAR INIT "" NO-UNDO.

    if  avail custom.int_ds_docto_xml then do:
        case p-campo:
            when "cnpj" then
                assign p-valor = string(int_ds_docto_xml.cnpj).
            when "serie" then
                assign p-valor = string(int_ds_docto_xml.serie).
            when "dEmi" then
                assign p-valor = string(int_ds_docto_xml.dEmi).
            when "nNF" then
                assign p-valor = string(int_ds_docto_xml.nNF).
            when "cnpj_dest" then
                assign p-valor = string(int_ds_docto_xml.cnpj_dest).
            when "num_pedido" then
                assign p-valor = string(int_ds_docto_xml.num_pedido).
            when "tipo_nota" then
                assign p-valor = string(int_ds_docto_xml.tipo_nota).
            when "cfop" then
                assign p-valor = string(int_ds_docto_xml.cfop).
        end.
    end.
    return p-valor.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE send-key B-table-Win  adm/support/_key-snd.p
PROCEDURE send-key :
/*------------------------------------------------------------------------------
  Purpose:     Sends a requested KEY value back to the calling
               SmartObject.
  Parameters:  <see adm/template/sndkytop.i>
------------------------------------------------------------------------------*/

  /* Define variables needed by this internal procedure.             */
  {src/adm/template/sndkytop.i}

  /* Return the key value associated with each key case.             */
  {src/adm/template/sndkycas.i "num_pedido" "int_ds_docto_xml" "num_pedido"}

  /* Close the CASE statement and end the procedure.                 */
  {src/adm/template/sndkyend.i}

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE send-records B-table-Win  _ADM-SEND-RECORDS
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE state-changed B-table-Win 
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
      {src/adm/template/bstates.i}
  END CASE.
  run pi-trata-state (p-issuer-hdl, p-state).
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _XFTR "RetornaValorCampo" B-table-Win _INLINE
/* Actions: ? ? ? ? support/brwrtval.p */
/* Procedure desativada */
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

