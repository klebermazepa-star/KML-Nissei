&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI ADM1
&ANALYZE-RESUME
/* Connected Databases 
          emsesp           ORACLE
          mgcad            ORACLE
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS B-table-Win 
/*:T *******************************************************************************
** Copyright TOTVS S.A. (2009)
** Todos os Direitos Reservados.
**
** Este fonte e de propriedade exclusiva da TOTVS, sua reproducao
** parcial ou total por qualquer meio, so podera ser feita mediante
** autorizacao expressa.
*******************************************************************************/
{include/i-prgvrs.i B99XX999 9.99.99.999}

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
&Scoped-define INTERNAL-TABLES cst_nota_fiscal nota-fiscal

/* Define KEY-PHRASE in case it is used by any query. */
&Scoped-define KEY-PHRASE TRUE

/* Definitions for BROWSE br-table                                      */
&Scoped-define FIELDS-IN-QUERY-br-table cst_nota_fiscal.cod_estabel ~
cst_nota_fiscal.serie cst_nota_fiscal.nr_nota_fis nota-fiscal.dt-emis-nota ~
nota-fiscal.vl-tot-nota 
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-table 
&Scoped-define QUERY-STRING-br-table FOR EACH cst_nota_fiscal WHERE ~{&KEY-PHRASE} ~
      AND cst_nota_fiscal.cod_estabel >= c-estab-ini ~
 AND cst_nota_fiscal.cod_estabel <= c-estab-fim ~
 AND cst_nota_fiscal.serie >= c-serie-ini ~
 AND cst_nota_fiscal.serie <= c-serie-fim ~
 AND cst_nota_fiscal.nr_nota_fis >= c-nota-ini ~
 AND cst_nota_fiscal.nr_nota_fis <= c-nota-fim ~
 AND cst_nota_fiscal.cartao_manual = TRUE NO-LOCK, ~
      FIRST nota-fiscal WHERE nota-fiscal.cod-estabel = cst_nota_fiscal.cod_estabel ~
  AND nota-fiscal.serie = cst_nota_fiscal.serie ~
  AND nota-fiscal.nr-nota-fis = cst_nota_fiscal.nr_nota_fis ~
      AND nota-fiscal.dt-cancela = ? ~
 AND nota-fiscal.dt-emis-nota >= c-data-ini ~
 AND nota-fiscal.dt-emis-nota <= c-data-fim NO-LOCK ~
    ~{&SORTBY-PHRASE} INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-br-table OPEN QUERY br-table FOR EACH cst_nota_fiscal WHERE ~{&KEY-PHRASE} ~
      AND cst_nota_fiscal.cod_estabel >= c-estab-ini ~
 AND cst_nota_fiscal.cod_estabel <= c-estab-fim ~
 AND cst_nota_fiscal.serie >= c-serie-ini ~
 AND cst_nota_fiscal.serie <= c-serie-fim ~
 AND cst_nota_fiscal.nr_nota_fis >= c-nota-ini ~
 AND cst_nota_fiscal.nr_nota_fis <= c-nota-fim ~
 AND cst_nota_fiscal.cartao_manual = TRUE NO-LOCK, ~
      FIRST nota-fiscal WHERE nota-fiscal.cod-estabel = cst_nota_fiscal.cod_estabel ~
  AND nota-fiscal.serie = cst_nota_fiscal.serie ~
  AND nota-fiscal.nr-nota-fis = cst_nota_fiscal.nr_nota_fis ~
      AND nota-fiscal.dt-cancela = ? ~
 AND nota-fiscal.dt-emis-nota >= c-data-ini ~
 AND nota-fiscal.dt-emis-nota <= c-data-fim NO-LOCK ~
    ~{&SORTBY-PHRASE} INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-br-table cst_nota_fiscal nota-fiscal
&Scoped-define FIRST-TABLE-IN-QUERY-br-table cst_nota_fiscal
&Scoped-define SECOND-TABLE-IN-QUERY-br-table nota-fiscal


/* Definitions for FRAME F-Main                                         */

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS c-estab-ini c-estab-fim IMAGE-1 IMAGE-2 ~
IMAGE-3 IMAGE-4 IMAGE-5 IMAGE-6 IMAGE-7 IMAGE-8 c-serie-ini c-serie-fim ~
c-nota-ini c-nota-fim bt-confirma c-data-ini c-data-fim br-table 
&Scoped-Define DISPLAYED-OBJECTS c-estab-ini c-estab-fim c-serie-ini ~
c-serie-fim c-nota-ini c-nota-fim c-data-ini c-data-fim 

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
cod_estabel||y|emsesp.cst_nota_fiscal.cod_estabel
CONDIPAG||y|emsesp.cst_nota_fiscal.CONDIPAG
</FOREIGN-KEYS> 
<EXECUTING-CODE>
**************************
* Set attributes related to FOREIGN KEYS
*/
RUN set-attribute-list (
    'Keys-Accepted = ,
     Keys-Supplied = "cod_estabel,CONDIPAG"':U).

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

DEFINE VARIABLE c-data-fim AS DATE FORMAT "99/99/9999" 
     VIEW-AS FILL-IN 
     SIZE 10.14 BY .88 NO-UNDO.

DEFINE VARIABLE c-data-ini AS DATE FORMAT "99/99/9999" 
     LABEL "EmissÆo" 
     VIEW-AS FILL-IN 
     SIZE 10.14 BY .88 NO-UNDO.

DEFINE VARIABLE c-estab-fim AS CHARACTER FORMAT "X(5)" 
     VIEW-AS FILL-IN 
     SIZE 6.43 BY .88 NO-UNDO.

DEFINE VARIABLE c-estab-ini AS CHARACTER FORMAT "X(5)" 
     LABEL "Estabelecimento" 
     VIEW-AS FILL-IN 
     SIZE 6.43 BY .88 NO-UNDO.

DEFINE VARIABLE c-nota-fim AS CHARACTER FORMAT "X(12)" 
     VIEW-AS FILL-IN 
     SIZE 10.14 BY .88 NO-UNDO.

DEFINE VARIABLE c-nota-ini AS CHARACTER FORMAT "X(12)" 
     LABEL "Nota Fiscal" 
     VIEW-AS FILL-IN 
     SIZE 10.14 BY .88 NO-UNDO.

DEFINE VARIABLE c-serie-fim AS CHARACTER FORMAT "X(5)" 
     VIEW-AS FILL-IN 
     SIZE 7.43 BY .88 NO-UNDO.

DEFINE VARIABLE c-serie-ini AS CHARACTER FORMAT "X(5)" 
     LABEL "S‚rie" 
     VIEW-AS FILL-IN 
     SIZE 7.43 BY .88 NO-UNDO.

DEFINE IMAGE IMAGE-1
     FILENAME "image\ii-fir":U
     SIZE 2.86 BY 1.

DEFINE IMAGE IMAGE-2
     FILENAME "image\ii-las":U
     SIZE 2.86 BY 1.

DEFINE IMAGE IMAGE-3
     FILENAME "image\ii-fir":U
     SIZE 2.86 BY 1.

DEFINE IMAGE IMAGE-4
     FILENAME "image\ii-las":U
     SIZE 2.86 BY 1.

DEFINE IMAGE IMAGE-5
     FILENAME "image\ii-fir":U
     SIZE 2.86 BY 1.

DEFINE IMAGE IMAGE-6
     FILENAME "image\ii-las":U
     SIZE 2.86 BY 1.

DEFINE IMAGE IMAGE-7
     FILENAME "image\ii-fir":U
     SIZE 2.86 BY 1.

DEFINE IMAGE IMAGE-8
     FILENAME "image\ii-las":U
     SIZE 2.86 BY 1.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-table FOR 
      cst_nota_fiscal, 
      nota-fiscal SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-table
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-table B-table-Win _STRUCTURED
  QUERY br-table NO-LOCK DISPLAY
      cst_nota_fiscal.cod_estabel FORMAT "x(3)":U
      cst_nota_fiscal.serie FORMAT "x(5)":U
      cst_nota_fiscal.nr_nota_fis FORMAT "x(16)":U
      nota-fiscal.dt-emis-nota FORMAT "99/99/9999":U
      nota-fiscal.vl-tot-nota FORMAT ">>,>>>,>>>,>>9.99":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ASSIGN SEPARATORS SIZE 80 BY 7.17.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME F-Main
     c-estab-ini AT ROW 1 COL 24 COLON-ALIGNED WIDGET-ID 30
     c-estab-fim AT ROW 1 COL 41.57 COLON-ALIGNED NO-LABEL WIDGET-ID 28
     c-serie-ini AT ROW 1.96 COL 23 COLON-ALIGNED WIDGET-ID 4
     c-serie-fim AT ROW 1.96 COL 41.57 COLON-ALIGNED NO-LABEL WIDGET-ID 2
     c-nota-ini AT ROW 2.92 COL 20.29 COLON-ALIGNED WIDGET-ID 12
     c-nota-fim AT ROW 2.92 COL 41.57 COLON-ALIGNED NO-LABEL WIDGET-ID 10
     bt-confirma AT ROW 3.79 COL 76 WIDGET-ID 26
     c-data-ini AT ROW 3.88 COL 20.29 COLON-ALIGNED WIDGET-ID 20
     c-data-fim AT ROW 3.88 COL 41.57 COLON-ALIGNED NO-LABEL WIDGET-ID 18
     br-table AT ROW 5 COL 1
     IMAGE-1 AT ROW 1 COL 32.86 WIDGET-ID 32
     IMAGE-2 AT ROW 1 COL 40.14 WIDGET-ID 34
     IMAGE-3 AT ROW 1.96 COL 32.86 WIDGET-ID 6
     IMAGE-4 AT ROW 1.96 COL 40.14 WIDGET-ID 8
     IMAGE-5 AT ROW 2.92 COL 32.86 WIDGET-ID 14
     IMAGE-6 AT ROW 2.92 COL 40.14 WIDGET-ID 16
     IMAGE-7 AT ROW 3.88 COL 32.86 WIDGET-ID 22
     IMAGE-8 AT ROW 3.88 COL 40.14 WIDGET-ID 24
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
         HEIGHT             = 11.33
         WIDTH              = 80.14.
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
/* BROWSE-TAB br-table c-data-fim F-Main */
ASSIGN 
       FRAME F-Main:SCROLLABLE       = FALSE
       FRAME F-Main:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-table
/* Query rebuild information for BROWSE br-table
     _TblList          = "emsesp.cst_nota_fiscal,mgcad.nota-fiscal WHERE emsesp.cst_nota_fiscal ..."
     _Options          = "NO-LOCK INDEXED-REPOSITION KEY-PHRASE SORTBY-PHRASE"
     _TblOptList       = ", FIRST"
     _Where[1]         = "emsesp.cst_nota_fiscal.cod_estabel >= c-estab-ini
 AND emsesp.cst_nota_fiscal.cod_estabel <= c-estab-fim
 AND emsesp.cst_nota_fiscal.serie >= c-serie-ini
 AND emsesp.cst_nota_fiscal.serie <= c-serie-fim
 AND emsesp.cst_nota_fiscal.nr_nota_fis >= c-nota-ini
 AND emsesp.cst_nota_fiscal.nr_nota_fis <= c-nota-fim
 AND emsesp.cst_nota_fiscal.cartao_manual = TRUE"
     _JoinCode[2]      = "mgcad.nota-fiscal.cod-estabel = emsesp.cst_nota_fiscal.cod_estabel
  AND mgcad.nota-fiscal.serie = emsesp.cst_nota_fiscal.serie
  AND mgcad.nota-fiscal.nr-nota-fis = emsesp.cst_nota_fiscal.nr_nota_fis"
     _Where[2]         = "mgcad.nota-fiscal.dt-cancela = ?
 AND mgcad.nota-fiscal.dt-emis-nota >= c-data-ini
 AND mgcad.nota-fiscal.dt-emis-nota <= c-data-fim"
     _FldNameList[1]   = emsesp.cst_nota_fiscal.cod_estabel
     _FldNameList[2]   = emsesp.cst_nota_fiscal.serie
     _FldNameList[3]   = emsesp.cst_nota_fiscal.nr_nota_fis
     _FldNameList[4]   = mgcad.nota-fiscal.dt-emis-nota
     _FldNameList[5]   = mgcad.nota-fiscal.vl-tot-nota
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
  assign input frame {&frame-name} c-estab-ini c-estab-fim
                                   c-serie-ini c-serie-fim
                                   c-nota-ini  c-nota-fim
                                   c-data-ini  c-data-fim.
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

    if  avail emsesp.cst_nota_fiscal then do:
        case p-campo:
            when "cod_estabel" then
                assign p-valor = string(cst_nota_fiscal.cod_estabel).
            when "serie" then
                assign p-valor = string(cst_nota_fiscal.serie).
            when "nr_nota_fis" then
                assign p-valor = string(cst_nota_fiscal.nr_nota_fis).
            when "dt-emis-nota" then
                assign p-valor = string(nota-fiscal.dt-emis-nota).
            when "vl-tot-nota" then
                assign p-valor = string(nota-fiscal.vl-tot-nota).
            when "cartao_manual" then
                assign p-valor = string(cst_nota_fiscal.cartao_manual).
            when "condipag" then
                assign p-valor = string(cst_nota_fiscal.condipag).
            when "convenio" then
                assign p-valor = string(cst_nota_fiscal.convenio).
            when "cpf_cupom" then
                assign p-valor = string(cst_nota_fiscal.cpf_cupom).
            when "cupom_ecf" then
                assign p-valor = string(cst_nota_fiscal.cupom_ecf).
            when "nfce_chave" then
                assign p-valor = string(cst_nota_fiscal.nfce_chave).
            when "nfce_dt_transmissao" then
                assign p-valor = string(cst_nota_fiscal.nfce_dt_transmissao).
            when "nfce_protocolo" then
                assign p-valor = string(cst_nota_fiscal.nfce_protocolo).
            when "nfce_transmissao" then
                assign p-valor = string(cst_nota_fiscal.nfce_transmissao).
            when "tipo_venda" then
                assign p-valor = string(cst_nota_fiscal.tipo_venda).
            when "valor_cartao" then
                assign p-valor = string(cst_nota_fiscal.valor_cartao).
            when "valor_chq" then
                assign p-valor = string(cst_nota_fiscal.valor_chq).
            when "valor_chq_pre" then
                assign p-valor = string(cst_nota_fiscal.valor_chq_pre).
            when "valor_convenio" then
                assign p-valor = string(cst_nota_fiscal.valor_convenio).
            when "valor_dinheiro" then
                assign p-valor = string(cst_nota_fiscal.valor_dinheiro).
            when "valor_ticket" then
                assign p-valor = string(cst_nota_fiscal.valor_ticket).
            when "valor_vale" then
                assign p-valor = string(cst_nota_fiscal.valor_vale).
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
  {src/adm/template/sndkycas.i "cod_estabel" "cst_nota_fiscal" "cod_estabel"}
  {src/adm/template/sndkycas.i "CONDIPAG" "cst_nota_fiscal" "CONDIPAG"}

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
  {src/adm/template/snd-list.i "cst_nota_fiscal"}
  {src/adm/template/snd-list.i "nota-fiscal"}

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

