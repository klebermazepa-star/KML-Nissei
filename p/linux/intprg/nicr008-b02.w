&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI ADM1
&ANALYZE-RESUME
/* Connected Databases 
          emscad           ORACLE
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
&Scoped-define INTERNAL-TABLES tit_acr movto_tit_acr

/* Definitions for BROWSE br-table                                      */
&Scoped-define FIELDS-IN-QUERY-br-table tit_acr.cod_empresa ~
tit_acr.cod_estab tit_acr.cod_espec_docto tit_acr.cod_ser_docto ~
tit_acr.cod_tit_acr tit_acr.cod_parcela tit_acr.nom_abrev ~
tit_acr.val_sdo_tit_acr 
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-table 
&Scoped-define QUERY-STRING-br-table FOR EACH tit_acr ~
      WHERE tit_acr.cod_espec_docto = "DI" ~
AND tit_acr.cod_estab >= c-estab-ini ~
 AND tit_acr.cod_estab <= c-estab-fim ~
 AND tit_acr.cod_espec_docto >= c-especie-ini ~
 AND tit_acr.cod_espec_docto <= c-especie-fim ~
 AND tit_acr.cod_ser_docto >= c-serie-ini ~
 AND tit_acr.cod_ser_docto <= c-serie-fim  ~
 AND tit_acr.cod_tit_acr >= c-titulo-ini ~
 AND tit_acr.cod_tit_acr <= c-titulo-fim ~
 AND tit_acr.cod_parcela >= c-parcela-ini ~
 AND tit_acr.cod_parcela <= c-parcela-fim ~
 ~
 NO-LOCK, ~
      FIRST movto_tit_acr WHERE movto_tit_acr.cod_estab = tit_acr.cod_estab ~
  AND movto_tit_acr.num_id_tit_acr = tit_acr.num_id_tit_acr ~
      AND movto_tit_acr.ind_trans_acr_abrev = "AVMN" NO-LOCK ~
    ~{&SORTBY-PHRASE} INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-br-table OPEN QUERY br-table FOR EACH tit_acr ~
      WHERE tit_acr.cod_espec_docto = "DI" ~
AND tit_acr.cod_estab >= c-estab-ini ~
 AND tit_acr.cod_estab <= c-estab-fim ~
 AND tit_acr.cod_espec_docto >= c-especie-ini ~
 AND tit_acr.cod_espec_docto <= c-especie-fim ~
 AND tit_acr.cod_ser_docto >= c-serie-ini ~
 AND tit_acr.cod_ser_docto <= c-serie-fim  ~
 AND tit_acr.cod_tit_acr >= c-titulo-ini ~
 AND tit_acr.cod_tit_acr <= c-titulo-fim ~
 AND tit_acr.cod_parcela >= c-parcela-ini ~
 AND tit_acr.cod_parcela <= c-parcela-fim ~
 ~
 NO-LOCK, ~
      FIRST movto_tit_acr WHERE movto_tit_acr.cod_estab = tit_acr.cod_estab ~
  AND movto_tit_acr.num_id_tit_acr = tit_acr.num_id_tit_acr ~
      AND movto_tit_acr.ind_trans_acr_abrev = "AVMN" NO-LOCK ~
    ~{&SORTBY-PHRASE} INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-br-table tit_acr movto_tit_acr
&Scoped-define FIRST-TABLE-IN-QUERY-br-table tit_acr
&Scoped-define SECOND-TABLE-IN-QUERY-br-table movto_tit_acr


/* Definitions for FRAME F-Main                                         */

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS c-estab-ini c-estab-fim IMAGE-1 IMAGE-2 ~
IMAGE-9 IMAGE-10 IMAGE-11 IMAGE-12 IMAGE-13 IMAGE-14 IMAGE-15 IMAGE-16 ~
c-especie-ini c-especie-fim c-serie-ini c-serie-fim c-titulo-ini ~
c-titulo-fim bt-confirma c-parcela-ini c-parcela-fim br-table 
&Scoped-Define DISPLAYED-OBJECTS c-estab-ini c-estab-fim c-especie-ini ~
c-especie-fim c-serie-ini c-serie-fim c-titulo-ini c-titulo-fim ~
c-parcela-ini c-parcela-fim 

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
cod_portador|y|y|ems5.tit_acr.cod_portador
num_id_movto_cta_corren|y|y|ems5.tit_acr.num_id_movto_cta_corren
cod_banco||y|ems5.tit_acr.cod_banco
cod_cart_bcia||y|ems5.tit_acr.cod_cart_bcia
cod_cta_corren||y|ems5.tit_acr.cod_cta_corren
cod_empresa||y|ems5.tit_acr.cod_empresa
cod_espec_docto||y|ems5.tit_acr.cod_espec_docto
cod_estab||y|ems5.tit_acr.cod_estab
nom_abrev||y|ems5.tit_acr.nom_abrev
cod_grp_clien||y|ems5.tit_acr.cod_grp_clien
cod_indic_econ||y|ems5.tit_acr.cod_indic_econ
cod_refer||y|ems5.tit_acr.cod_refer
</FOREIGN-KEYS> 
<EXECUTING-CODE>
**************************
* Set attributes related to FOREIGN KEYS
*/
RUN set-attribute-list (
    'Keys-Accepted = "cod_portador,num_id_movto_cta_corren",
     Keys-Supplied = "cod_portador,num_id_movto_cta_corren,cod_banco,cod_cart_bcia,cod_cta_corren,cod_empresa,cod_espec_docto,cod_estab,nom_abrev,cod_grp_clien,cod_indic_econ,cod_refer"':U).

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

DEFINE VARIABLE c-especie-fim AS CHARACTER FORMAT "X(256)" INITIAL "ZZZ" 
     VIEW-AS FILL-IN 
     SIZE 7 BY .88 NO-UNDO.

DEFINE VARIABLE c-especie-ini AS CHARACTER FORMAT "X(5)" 
     LABEL "Esp‚cie" 
     VIEW-AS FILL-IN 
     SIZE 7 BY .88 NO-UNDO.

DEFINE VARIABLE c-estab-fim AS CHARACTER FORMAT "X(5)" INITIAL "ZZZZZ" 
     VIEW-AS FILL-IN 
     SIZE 10.14 BY .88 NO-UNDO.

DEFINE VARIABLE c-estab-ini AS CHARACTER FORMAT "X(5)" 
     LABEL "Estabelecimento" 
     VIEW-AS FILL-IN 
     SIZE 10.14 BY .88 NO-UNDO.

DEFINE VARIABLE c-parcela-fim AS CHARACTER FORMAT "X(3)" INITIAL "ZZZ" 
     VIEW-AS FILL-IN 
     SIZE 10.14 BY .88 NO-UNDO.

DEFINE VARIABLE c-parcela-ini AS CHARACTER FORMAT "X(3)" 
     LABEL "Parcela" 
     VIEW-AS FILL-IN 
     SIZE 10.14 BY .88 NO-UNDO.

DEFINE VARIABLE c-serie-fim AS CHARACTER FORMAT "X(5)" INITIAL "ZZZ" 
     VIEW-AS FILL-IN 
     SIZE 10.14 BY .88 NO-UNDO.

DEFINE VARIABLE c-serie-ini AS CHARACTER FORMAT "X(5)" 
     LABEL "S‚rie" 
     VIEW-AS FILL-IN 
     SIZE 10.14 BY .88 NO-UNDO.

DEFINE VARIABLE c-titulo-fim AS CHARACTER FORMAT "X(15)" INITIAL "ZZZZZZZZZZZZZZZZ" 
     VIEW-AS FILL-IN 
     SIZE 15.29 BY .88 NO-UNDO.

DEFINE VARIABLE c-titulo-ini AS CHARACTER FORMAT "X(15)" 
     LABEL "T¡tulo" 
     VIEW-AS FILL-IN 
     SIZE 15.29 BY .88 NO-UNDO.

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

DEFINE IMAGE IMAGE-13
     FILENAME "image\ii-fir":U
     SIZE 2.86 BY 1.

DEFINE IMAGE IMAGE-14
     FILENAME "image\ii-las":U
     SIZE 2.86 BY 1.

DEFINE IMAGE IMAGE-15
     FILENAME "image\ii-fir":U
     SIZE 2.86 BY 1.

DEFINE IMAGE IMAGE-16
     FILENAME "image\ii-las":U
     SIZE 2.86 BY 1.

DEFINE IMAGE IMAGE-2
     FILENAME "image\ii-las":U
     SIZE 2.86 BY 1.

DEFINE IMAGE IMAGE-9
     FILENAME "image\ii-fir":U
     SIZE 2.86 BY 1.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-table FOR 
      tit_acr, 
      movto_tit_acr
    FIELDS() SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-table
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-table B-table-Win _STRUCTURED
  QUERY br-table NO-LOCK DISPLAY
      tit_acr.cod_empresa FORMAT "x(3)":U
      tit_acr.cod_estab FORMAT "x(5)":U
      tit_acr.cod_espec_docto FORMAT "x(3)":U
      tit_acr.cod_ser_docto FORMAT "x(3)":U
      tit_acr.cod_tit_acr FORMAT "x(10)":U
      tit_acr.cod_parcela FORMAT "x(02)":U
      tit_acr.nom_abrev FORMAT "x(15)":U
      tit_acr.val_sdo_tit_acr FORMAT ">>>,>>>,>>9.99":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ASSIGN SEPARATORS SIZE 80 BY 6.75.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME F-Main
     c-estab-ini AT ROW 1 COL 18.14 COLON-ALIGNED
     c-estab-fim AT ROW 1 COL 42.43 COLON-ALIGNED NO-LABEL
     c-especie-ini AT ROW 1.92 COL 21.29 COLON-ALIGNED WIDGET-ID 4
     c-especie-fim AT ROW 1.92 COL 42.43 COLON-ALIGNED NO-LABEL WIDGET-ID 2
     c-serie-ini AT ROW 2.83 COL 18.14 COLON-ALIGNED WIDGET-ID 12
     c-serie-fim AT ROW 2.83 COL 42.43 COLON-ALIGNED NO-LABEL WIDGET-ID 10
     c-titulo-ini AT ROW 3.75 COL 13 COLON-ALIGNED WIDGET-ID 20
     c-titulo-fim AT ROW 3.75 COL 42.43 COLON-ALIGNED NO-LABEL WIDGET-ID 18
     bt-confirma AT ROW 4.46 COL 76
     c-parcela-ini AT ROW 4.67 COL 18.14 COLON-ALIGNED WIDGET-ID 28
     c-parcela-fim AT ROW 4.67 COL 42.43 COLON-ALIGNED NO-LABEL WIDGET-ID 26
     br-table AT ROW 5.75 COL 1
     IMAGE-1 AT ROW 1 COL 30.72
     IMAGE-2 AT ROW 1 COL 41
     IMAGE-9 AT ROW 1.92 COL 30.72 WIDGET-ID 6
     IMAGE-10 AT ROW 1.92 COL 41 WIDGET-ID 8
     IMAGE-11 AT ROW 2.83 COL 30.72 WIDGET-ID 16
     IMAGE-12 AT ROW 2.83 COL 41 WIDGET-ID 14
     IMAGE-13 AT ROW 3.75 COL 30.72 WIDGET-ID 22
     IMAGE-14 AT ROW 3.75 COL 41 WIDGET-ID 24
     IMAGE-15 AT ROW 4.67 COL 30.72 WIDGET-ID 30
     IMAGE-16 AT ROW 4.67 COL 41 WIDGET-ID 32
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
         HEIGHT             = 12.46
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
/* BROWSE-TAB br-table c-parcela-fim F-Main */
ASSIGN 
       FRAME F-Main:SCROLLABLE       = FALSE
       FRAME F-Main:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-table
/* Query rebuild information for BROWSE br-table
     _TblList          = "ems5.tit_acr,ems5.movto_tit_acr WHERE ems5.tit_acr ..."
     _Options          = "NO-LOCK INDEXED-REPOSITION SORTBY-PHRASE"
     _TblOptList       = ", FIRST USED"
     _Where[1]         = "ems5.tit_acr.cod_espec_docto = ""DI""
AND ems5.tit_acr.cod_estab >= c-estab-ini
 AND ems5.tit_acr.cod_estab <= c-estab-fim
 AND ems5.tit_acr.cod_espec_docto >= c-especie-ini
 AND ems5.tit_acr.cod_espec_docto <= c-especie-fim
 AND ems5.tit_acr.cod_ser_docto >= c-serie-ini
 AND ems5.tit_acr.cod_ser_docto <= c-serie-fim 
 AND ems5.tit_acr.cod_tit_acr >= c-titulo-ini
 AND ems5.tit_acr.cod_tit_acr <= c-titulo-fim
 AND ems5.tit_acr.cod_parcela >= c-parcela-ini
 AND ems5.tit_acr.cod_parcela <= c-parcela-fim

"
     _JoinCode[2]      = "ems5.movto_tit_acr.cod_estab = ems5.tit_acr.cod_estab
  AND ems5.movto_tit_acr.num_id_tit_acr = ems5.tit_acr.num_id_tit_acr"
     _Where[2]         = "ems5.movto_tit_acr.ind_trans_acr_abrev = ""AVMN"""
     _FldNameList[1]   = ems5.tit_acr.cod_empresa
     _FldNameList[2]   = ems5.tit_acr.cod_estab
     _FldNameList[3]   = ems5.tit_acr.cod_espec_docto
     _FldNameList[4]   = ems5.tit_acr.cod_ser_docto
     _FldNameList[5]   = ems5.tit_acr.cod_tit_acr
     _FldNameList[6]   = ems5.tit_acr.cod_parcela
     _FldNameList[7]   = ems5.tit_acr.nom_abrev
     _FldNameList[8]   = ems5.tit_acr.val_sdo_tit_acr
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
  assign input frame {&frame-name} c-estab-ini   c-estab-fim 
                                   c-especie-ini c-especie-fim
                                   c-serie-ini   c-serie-fim
                                   c-titulo-ini  c-titulo-fim
                                   c-parcela-ini c-parcela-fim.
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
  DEF VAR key-value AS CHAR NO-UNDO.

  DEF VAR Filter-Value AS CHAR NO-UNDO.

  /* Copy 'Filter-Attributes' into local variables. */
  RUN get-attribute ('Filter-Value':U).
  Filter-Value = RETURN-VALUE.
  /* Look up the current key-value. */
  RUN get-attribute ('Key-Value':U).
  key-value = RETURN-VALUE.

  /* Find the current record using the current Key-Name. */
  RUN get-attribute ('Key-Name':U).
  CASE RETURN-VALUE:
    WHEN 'cod_portador':U THEN DO:
       &Scope KEY-PHRASE tit_acr.cod_portador eq key-value
       {&OPEN-QUERY-{&BROWSE-NAME}}
    END. /* cod_portador */
    WHEN 'num_id_movto_cta_corren':U THEN DO:
       &Scope KEY-PHRASE tit_acr.num_id_movto_cta_corren eq INTEGER(key-value)
       {&OPEN-QUERY-{&BROWSE-NAME}}
    END. /* num_id_movto_cta_corren */
    OTHERWISE DO:
       &Scope KEY-PHRASE TRUE
       {&OPEN-QUERY-{&BROWSE-NAME}}
    END. /* OTHERWISE...*/
  END CASE.

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

    if  avail ems5.tit_acr then do:
        case p-campo:
            when "cod_empresa" then
                assign p-valor = string(tit_acr.cod_empresa).
            when "cod_estab" then
                assign p-valor = string(tit_acr.cod_estab).
            when "cod_espec_docto" then
                assign p-valor = string(tit_acr.cod_espec_docto).
            when "cod_ser_docto" then
                assign p-valor = string(tit_acr.cod_ser_docto).
            when "cod_tit_acr" then
                assign p-valor = string(tit_acr.cod_tit_acr).
            when "cod_parcela" then
                assign p-valor = string(tit_acr.cod_parcela).
            when "nom_abrev" then
                assign p-valor = string(tit_acr.nom_abrev).
            when "val_sdo_tit_acr" then
                assign p-valor = string(tit_acr.val_sdo_tit_acr).
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
  {src/adm/template/sndkycas.i "cod_portador" "tit_acr" "cod_portador"}
  {src/adm/template/sndkycas.i "num_id_movto_cta_corren" "tit_acr" "num_id_movto_cta_corren"}
  {src/adm/template/sndkycas.i "cod_banco" "tit_acr" "cod_banco"}
  {src/adm/template/sndkycas.i "cod_cart_bcia" "tit_acr" "cod_cart_bcia"}
  {src/adm/template/sndkycas.i "cod_cta_corren" "tit_acr" "cod_cta_corren"}
  {src/adm/template/sndkycas.i "cod_empresa" "tit_acr" "cod_empresa"}
  {src/adm/template/sndkycas.i "cod_espec_docto" "tit_acr" "cod_espec_docto"}
  {src/adm/template/sndkycas.i "cod_estab" "tit_acr" "cod_estab"}
  {src/adm/template/sndkycas.i "nom_abrev" "tit_acr" "nom_abrev"}
  {src/adm/template/sndkycas.i "cod_grp_clien" "tit_acr" "cod_grp_clien"}
  {src/adm/template/sndkycas.i "cod_indic_econ" "tit_acr" "cod_indic_econ"}
  {src/adm/template/sndkycas.i "cod_refer" "tit_acr" "cod_refer"}

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
  {src/adm/template/snd-list.i "tit_acr"}
  {src/adm/template/snd-list.i "movto_tit_acr"}

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

