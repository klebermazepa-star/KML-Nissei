&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI ADM1
&ANALYZE-RESUME
/* Connected Databases 
          emsesp           PROGRESS
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
{include/i-prgvrs.i int115-browser 2.12.01.AVB}

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
def var c-nome-abrev as char no-undo.
def var c-denominacao as char no-undo.
def var c-tp-pedido as char no-undo.
def var c-modalidade as char no-undo.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE SmartBrowser
&Scoped-define DB-AWARE no

&Scoped-define ADM-SUPPORTED-LINKS Record-Source,Record-Target,TableIO-Target

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME F-Main
&Scoped-define BROWSE-NAME br-cfop

/* External Tables                                                      */
&Scoped-define EXTERNAL-TABLES int-ds-tp-trib-natur-oper
&Scoped-define FIRST-EXTERNAL-TABLE int-ds-tp-trib-natur-oper


/* Need to scope the external tables to this procedure                  */
DEFINE QUERY external_tables FOR int-ds-tp-trib-natur-oper.
/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES int-ds-tp-trib-natur-oper

/* Define KEY-PHRASE in case it is used by any query. */
&Scoped-define KEY-PHRASE TRUE

/* Definitions for BROWSE br-cfop                                       */
&Scoped-define FIELDS-IN-QUERY-br-cfop fnTipoPedido(int-ds-tp-trib-natur-oper.tp-pedido) @ c-tp-pedido int-ds-tp-trib-natur-oper.uf-destino int-ds-tp-trib-natur-oper.uf-origem int-ds-tp-trib-natur-oper.cod-estabel int-ds-tp-trib-natur-oper.cod-emitente fnEmitente(int-ds-tp-trib-natur-oper.cod-emitente) @ c-nome-abrev int-ds-tp-trib-natur-oper.cod-cond-pag int-ds-tp-trib-natur-oper.class-fiscal int-ds-tp-trib-natur-oper.nat-operacao fnNatureza(int-ds-tp-trib-natur-oper.nat-operacao) @ c-denominacao int-ds-tp-trib-natur-oper.cod-portador fnModalidade(int-ds-tp-trib-natur-oper.modalidade) @ c-modalidade int-ds-tp-trib-natur-oper.serie   
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-cfop   
&Scoped-define SELF-NAME br-cfop
&Scoped-define QUERY-STRING-br-cfop FOR EACH int-ds-tp-trib-natur-oper WHERE     int-ds-tp-trib-natur-oper.tp-pedido = i-tp-pedido and (     int-ds-tp-trib-natur-oper.cod-estabel = ? or (     int-ds-tp-trib-natur-oper.cod-estabel >= c-estab-ini   and     int-ds-tp-trib-natur-oper.cod-estabel <= c-estab-fim)) and (     int-ds-tp-trib-natur-oper.uf-destino = ? or (     int-ds-tp-trib-natur-oper.uf-destino >= c-uf-destino-ini   and     int-ds-tp-trib-natur-oper.uf-destino <= c-uf-destino-fim)) and (     int-ds-tp-trib-natur-oper.uf-origem = ? or (     int-ds-tp-trib-natur-oper.uf-origem >= c-uf-origem-ini    and     int-ds-tp-trib-natur-oper.uf-origem <= c-uf-origem-fim))  NO-LOCK     ~{&SORTBY-PHRASE} INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-br-cfop OPEN QUERY {&SELF-NAME} FOR EACH int-ds-tp-trib-natur-oper WHERE     int-ds-tp-trib-natur-oper.tp-pedido = i-tp-pedido and (     int-ds-tp-trib-natur-oper.cod-estabel = ? or (     int-ds-tp-trib-natur-oper.cod-estabel >= c-estab-ini   and     int-ds-tp-trib-natur-oper.cod-estabel <= c-estab-fim)) and (     int-ds-tp-trib-natur-oper.uf-destino = ? or (     int-ds-tp-trib-natur-oper.uf-destino >= c-uf-destino-ini   and     int-ds-tp-trib-natur-oper.uf-destino <= c-uf-destino-fim)) and (     int-ds-tp-trib-natur-oper.uf-origem = ? or (     int-ds-tp-trib-natur-oper.uf-origem >= c-uf-origem-ini    and     int-ds-tp-trib-natur-oper.uf-origem <= c-uf-origem-fim))  NO-LOCK     ~{&SORTBY-PHRASE} INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-br-cfop int-ds-tp-trib-natur-oper
&Scoped-define FIRST-TABLE-IN-QUERY-br-cfop int-ds-tp-trib-natur-oper


/* Definitions for FRAME F-Main                                         */

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS IMAGE-1 IMAGE-2 IMAGE-3 IMAGE-4 IMAGE-5 ~
IMAGE-6 i-tp-pedido c-uf-origem-ini c-uf-origem-fim c-uf-destino-ini ~
c-uf-destino-fim c-estab-ini c-estab-fim bt-confirma br-cfop 
&Scoped-Define DISPLAYED-OBJECTS i-tp-pedido c-uf-origem-ini ~
c-uf-origem-fim c-uf-destino-ini c-uf-destino-fim c-estab-ini c-estab-fim 

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
</FOREIGN-KEYS
><EXECUTING-CODE>
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

/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD fnEmitente B-table-Win 
FUNCTION fnEmitente RETURNS CHARACTER
  ( p-cod-emitente as integer )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD fnModalidade B-table-Win 
FUNCTION fnModalidade RETURNS CHARACTER
  ( p-modalidade as integer )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD fnNatureza B-table-Win 
FUNCTION fnNatureza RETURNS CHARACTER
  ( p-nat-operacao as char )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD fnTipoPedido B-table-Win 
FUNCTION fnTipoPedido RETURNS CHARACTER
  ( p-tp-pedido as char )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */
DEFINE BUTTON bt-confirma 
     IMAGE-UP FILE "image\im-sav":U
     LABEL "Button 1" 
     SIZE 5.14 BY 1.

DEFINE VARIABLE i-tp-pedido AS CHARACTER FORMAT "X(2)" 
     LABEL "Tipo Pedido" 
     VIEW-AS COMBO-BOX INNER-LINES 10
     LIST-ITEM-PAIRS "TRANSFERENCIA DEPOSITO - FILIAL","1",
                     "TRANSFERENCIA FILIAL - DEPOSITO","2",
                     "BALANCO MANUAL FILIAL","3",
                     "COMPRA FORNECEDOR - FILIAL","4",
                     "COMPRA FORNECEDOR - DEPOSITO","5",
                     "TRANSFERENCIA DEPOSITO - DEPOSITO","6",
                     "ELETRONICO FORNECEDOR - FILIAL","7",
                     "ELETRONICO DEPOSITO - FILIAL","8",
                     "PBM FILIAL","9",
                     "PBM DEPOSITO","10",
                     "BALANCO MANUAL DEPOSITO","11",
                     "BALANCO COLETOR FILIAL","12",
                     "BALANCO COLETOR DEPOSITO","13",
                     "BALANCO MANUAL FILIAL - PERMITE CONSOLIDA€ÇO","14",
                     "DEVOLUCAO FILIAL - FORNECEDOR","15",
                     "DEVOLUCAO DEPOSITO - FORNECEDOR","16",
                     "TRANSFERENCIA DEPOSITO - DEPOSITO (COMERCIALIZAVEL)","17",
                     "TRANSFERENCIA DEPOSITO - DEPOSITO (AVARIA)","18",
                     "TRANSFERENCIA FILIAL - FILIAL","19",
                     "BALANCO MANUAL FILIAL - ESPECIAL (MED. CONTROLADO)","31",
                     "DEVOLUCAO FILIAL - FORNECEDOR (MED. CONTROLADO)","32",
                     "TRANSFERENCIA FILIAL - FORNECEDOR (MED. CONTROLADO)","33",
                     "BALAN€O GERAL CONTROLADOS DEPOSITO","35",
                     "BALAN€O GERAL CONTROLADOS FILIAL","36",
                     "ATIVO IMOBILIZADO DEPOSITO => FILIAL","37",
                     "ESTORNO","38",
                     "ATIVO IMOBILIZADO FILIAL => FILIAL","39",
                     "RETIRADA FILIAL => PROPRIA FILIAL","46",
                     "SUBSTITUI€ÇO DE CUPOM","48"
     DROP-DOWN-LIST
     SIZE 58.86 BY 1.

DEFINE VARIABLE c-estab-fim AS CHARACTER FORMAT "X(5)":U INITIAL "99999" 
     VIEW-AS FILL-IN 
     SIZE 6.57 BY .88 NO-UNDO.

DEFINE VARIABLE c-estab-ini AS CHARACTER FORMAT "X(5)":U 
     LABEL "Estab." 
     VIEW-AS FILL-IN 
     SIZE 6.57 BY .88 NO-UNDO.

DEFINE VARIABLE c-uf-destino-fim AS CHARACTER FORMAT "X(2)":U INITIAL "ZZ" 
     VIEW-AS FILL-IN 
     SIZE 4.57 BY .88 NO-UNDO.

DEFINE VARIABLE c-uf-destino-ini AS CHARACTER FORMAT "X(2)":U 
     LABEL "UF Destino" 
     VIEW-AS FILL-IN 
     SIZE 4.57 BY .88 NO-UNDO.

DEFINE VARIABLE c-uf-origem-fim AS CHARACTER FORMAT "X(2)":U INITIAL "ZZ" 
     VIEW-AS FILL-IN 
     SIZE 4.57 BY .88 NO-UNDO.

DEFINE VARIABLE c-uf-origem-ini AS CHARACTER FORMAT "X(2)":U 
     LABEL "UF Origem" 
     VIEW-AS FILL-IN 
     SIZE 4.57 BY .88 NO-UNDO.

DEFINE IMAGE IMAGE-1
     FILENAME "image\ii-fir":U
     SIZE 3 BY .79.

DEFINE IMAGE IMAGE-2
     FILENAME "image\ii-las":U
     SIZE 2.57 BY .79.

DEFINE IMAGE IMAGE-3
     FILENAME "image\ii-fir":U
     SIZE 3 BY .79.

DEFINE IMAGE IMAGE-4
     FILENAME "image\ii-las":U
     SIZE 3.57 BY .79.

DEFINE IMAGE IMAGE-5
     FILENAME "image\ii-fir":U
     SIZE 3 BY .79.

DEFINE IMAGE IMAGE-6
     FILENAME "image\ii-las":U
     SIZE 3 BY .79.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-cfop FOR 
      int-ds-tp-trib-natur-oper SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-cfop
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-cfop B-table-Win _FREEFORM
  QUERY br-cfop NO-LOCK DISPLAY
      fnTipoPedido(int-ds-tp-trib-natur-oper.tp-pedido) @  c-tp-pedido FORMAT "X(45)":U column-label "Tipo Pedido"
      int-ds-tp-trib-natur-oper.uf-destino FORMAT "x(2)":U
      int-ds-tp-trib-natur-oper.uf-origem FORMAT "x(2)":U
      int-ds-tp-trib-natur-oper.cod-estabel FORMAT "x(5)":U
      int-ds-tp-trib-natur-oper.cod-emitente FORMAT ">>>>>>>>9":U WIDTH 8.86
      fnEmitente(int-ds-tp-trib-natur-oper.cod-emitente) @ c-nome-abrev COLUMN-LABEL "Nome" FORMAT "X(12)":U
      int-ds-tp-trib-natur-oper.cod-cond-pag FORMAT ">>9":U WIDTH 9.86
      int-ds-tp-trib-natur-oper.class-fiscal FORMAT "9999.99.99":U WIDTH 13.29
      int-ds-tp-trib-natur-oper.nat-operacao FORMAT "X(8)":U WIDTH 9.72
      fnNatureza(int-ds-tp-trib-natur-oper.nat-operacao) @ c-denominacao COLUMN-LABEL "Denominacao" FORMAT "x(65)":U
          WIDTH 40
      int-ds-tp-trib-natur-oper.cod-portador FORMAT ">>>>9":U
      fnModalidade(int-ds-tp-trib-natur-oper.modalidade) @ c-modalidade FORMAT "X(12)":U column-label "Modalid"
      int-ds-tp-trib-natur-oper.serie FORMAT "x(5)":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ASSIGN SEPARATORS SIZE 81 BY 10.42 ROW-HEIGHT-CHARS .58.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME F-Main
     i-tp-pedido AT ROW 1.25 COL 1.43 WIDGET-ID 110
     c-uf-origem-ini AT ROW 2.5 COL 11 COLON-ALIGNED WIDGET-ID 12
     c-uf-origem-fim AT ROW 2.5 COL 42.43 COLON-ALIGNED NO-LABEL WIDGET-ID 10
     c-uf-destino-ini AT ROW 3.58 COL 11 COLON-ALIGNED WIDGET-ID 20
     c-uf-destino-fim AT ROW 3.58 COL 42.43 COLON-ALIGNED NO-LABEL WIDGET-ID 18
     c-estab-ini AT ROW 4.63 COL 9 COLON-ALIGNED WIDGET-ID 4
     c-estab-fim AT ROW 4.63 COL 42.43 COLON-ALIGNED NO-LABEL WIDGET-ID 2
     bt-confirma AT ROW 4.75 COL 77
     br-cfop AT ROW 5.75 COL 1
     IMAGE-1 AT ROW 2.58 COL 18 WIDGET-ID 14
     IMAGE-2 AT ROW 2.58 COL 41 WIDGET-ID 16
     IMAGE-3 AT ROW 4.75 COL 18 WIDGET-ID 6
     IMAGE-4 AT ROW 4.75 COL 41 WIDGET-ID 8
     IMAGE-5 AT ROW 3.67 COL 18 WIDGET-ID 22
     IMAGE-6 AT ROW 3.67 COL 41 WIDGET-ID 24
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1 SCROLLABLE 
         BGCOLOR 8 FGCOLOR 0  WIDGET-ID 100.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: SmartBrowser
   External Tables: emsesp.int-ds-tp-trib-natur-oper
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
         HEIGHT             = 15.29
         WIDTH              = 81.72.
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
/* BROWSE-TAB br-cfop bt-confirma F-Main */
ASSIGN 
       FRAME F-Main:SCROLLABLE       = FALSE
       FRAME F-Main:HIDDEN           = TRUE.

ASSIGN 
       br-cfop:COLUMN-RESIZABLE IN FRAME F-Main       = TRUE
       br-cfop:COLUMN-MOVABLE IN FRAME F-Main         = TRUE.

/* SETTINGS FOR COMBO-BOX i-tp-pedido IN FRAME F-Main
   ALIGN-L                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-cfop
/* Query rebuild information for BROWSE br-cfop
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH int-ds-tp-trib-natur-oper WHERE
    int-ds-tp-trib-natur-oper.tp-pedido = i-tp-pedido and (
    int-ds-tp-trib-natur-oper.cod-estabel = ? or (
    int-ds-tp-trib-natur-oper.cod-estabel >= c-estab-ini   and
    int-ds-tp-trib-natur-oper.cod-estabel <= c-estab-fim)) and (
    int-ds-tp-trib-natur-oper.uf-destino = ? or (
    int-ds-tp-trib-natur-oper.uf-destino >= c-uf-destino-ini   and
    int-ds-tp-trib-natur-oper.uf-destino <= c-uf-destino-fim)) and (
    int-ds-tp-trib-natur-oper.uf-origem = ? or (
    int-ds-tp-trib-natur-oper.uf-origem >= c-uf-origem-ini    and
    int-ds-tp-trib-natur-oper.uf-origem <= c-uf-origem-fim))  NO-LOCK
    ~{&SORTBY-PHRASE} INDEXED-REPOSITION.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION KEY-PHRASE SORTBY-PHRASE"
     _Query            is NOT OPENED
*/  /* BROWSE br-cfop */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK FRAME F-Main
/* Query rebuild information for FRAME F-Main
     _Options          = "NO-LOCK"
     _Query            is NOT OPENED
*/  /* FRAME F-Main */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define BROWSE-NAME br-cfop
&Scoped-define SELF-NAME br-cfop
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-cfop B-table-Win
ON MOUSE-SELECT-DBLCLICK OF br-cfop IN FRAME F-Main
DO:
    RUN New-State('DblClick':U).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-cfop B-table-Win
ON ROW-ENTRY OF br-cfop IN FRAME F-Main
DO:
  /* This code displays initial values for newly added or copied rows. */
  {src/adm/template/brsentry.i}
  
  run new-state('New-Line|':U + string(rowid({&FIRST-TABLE-IN-QUERY-{&BROWSE-NAME}}))).
  run seta-valor.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-cfop B-table-Win
ON ROW-LEAVE OF br-cfop IN FRAME F-Main
DO:
    /* Do not disable this code or no updates will take place except
     by pressing the Save button on an Update SmartPanel. */
   {src/adm/template/brsleave.i}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-cfop B-table-Win
ON VALUE-CHANGED OF br-cfop IN FRAME F-Main
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
  assign input frame {&frame-name} 
      c-estab-fim c-estab-ini 
      c-uf-origem-fim c-uf-origem-ini 
      c-uf-destino-fim c-uf-destino-ini 
      i-tp-pedido.
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

  /* Create a list of all the tables that we need to get.            */
  {src/adm/template/row-list.i "int-ds-tp-trib-natur-oper"}

  /* Get the record ROWID's from the RECORD-SOURCE.                  */
  {src/adm/template/row-get.i}

  /* FIND each record specified by the RECORD-SOURCE.                */
  {src/adm/template/row-find.i "int-ds-tp-trib-natur-oper"}

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

  display c-uf-destino-fim c-uf-origem-fim c-estab-fim with frame f-Main.
  /* Code placed here will execute AFTER standard behavior.    */
  apply 'value-changed':U to {&browse-name} in frame {&frame-name}.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-retorna-valor B-table-Win 
PROCEDURE pi-retorna-valor :
DEFINE INPUT PARAMETER P-CAMPO AS CHARACTER NO-UNDO.

    DEFINE VARIABLE P-VALOR AS CHAR INIT "" NO-UNDO.

    if  avail emsesp.int-ds-tp-trib-natur-oper then do:
        case p-campo:
            when "tp-pedido" then
                assign p-valor = string(int-ds-tp-trib-natur-oper.tp-pedido).
            when "uf-origem" then
                assign p-valor = string(int-ds-tp-trib-natur-oper.uf-origem).
            when "uf-destino" then
                assign p-valor = string(int-ds-tp-trib-natur-oper.uf-destino).
            when "cod-estabel" then
                assign p-valor = string(int-ds-tp-trib-natur-oper.cod-estabel).
            when "cod-emitente" then
                assign p-valor = string(int-ds-tp-trib-natur-oper.cod-emitente).
            when "class-fiscal" then
                assign p-valor = string(int-ds-tp-trib-natur-oper.class-fiscal).
            when "nat-operacao" then
                assign p-valor = string(int-ds-tp-trib-natur-oper.nat-operacao).
        end.
    end.
    return p-valor.
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
  {src/adm/template/snd-list.i "int-ds-tp-trib-natur-oper"}
  {src/adm/template/snd-list.i "int-ds-tp-trib-natur-oper"}

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

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION fnEmitente B-table-Win 
FUNCTION fnEmitente RETURNS CHARACTER
  ( p-cod-emitente as integer ) :

    for first emitente 
        fields (nome-abrev)
        no-lock where emitente.cod-emitente = p-cod-emitente:
        
        RETURN emitente.nome-abrev.
    end.
  RETURN "".   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION fnModalidade B-table-Win 
FUNCTION fnModalidade RETURNS CHARACTER
  ( p-modalidade as integer ) :
/*------------------------------------------------------------------------------
  Purpose:  
    Notes:  
------------------------------------------------------------------------------*/


  RETURN {adinc/i03ad209.i 04 p-modalidade}.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION fnNatureza B-table-Win 
FUNCTION fnNatureza RETURNS CHARACTER
  ( p-nat-operacao as char ) :

    for first natur-oper 
        fields (denominacao)
        no-lock where natur-oper.nat-operacao = p-nat-operacao:
        RETURN natur-oper.denominacao.
    end.
  RETURN "".   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION fnTipoPedido B-table-Win 
FUNCTION fnTipoPedido RETURNS CHARACTER
  ( p-tp-pedido as char ) :
/*------------------------------------------------------------------------------
  Purpose:  
    Notes:  
------------------------------------------------------------------------------*/
case p-tp-pedido:
    when "1" then return "TRANSFERENCIA DEPOSITO - FILIAL".
    when "2" then return "TRANSFERENCIA FILIAL - DEPOSITO".
    when "3" then return "BALANCO MANUAL FILIAL".
    when "4" then return "COMPRA FORNECEDOR - FILIAL".
    when "5" then return "COMPRA FORNECEDOR - DEPOSITO".
    when "6" then return "TRANSFERENCIA DEPOSITO - DEPOSITO".
    when "7" then return "ELETRONICO FORNECEDOR - FILIAL".
    when "8" then return "ELETRONICO DEPOSITO - FILIAL".
    when "9" then return "PBM FILIAL".
    when "10" then return "PBM DEPOSITO".
    when "11" then return "BALANCO MANUAL DEPOSITO".
    when "12" then return "BALANCO COLETOR FILIAL".
    when "13" then return "BALANCO COLETOR DEPOSITO".
    when "14" then return "BALANCO MANUAL FILIAL - PERMITE CONSOLIDA€ÇO".
    when "15" then return "DEVOLUCAO FILIAL - FORNECEDOR".
    when "16" then return "DEVOLUCAO DEPOSITO - FORNECEDOR".
    when "17" then return "TRANSFERENCIA DEPOSITO - DEPOSITO (COMERCIALIZAVEL)".
    when "18" then return "TRANSFERENCIA DEPOSITO - DEPOSITO (AVARIA)".
    when "19" then return "TRANSFERENCIA FILIAL - FILIAL".
    when "31" then return "BALANCO MANUAL FILIAL - ESPECIAL (MED. CONTROLADO)".
    when "32" then return "DEVOLUCAO FILIAL - FORNECEDOR (MED. CONTROLADO)".
    when "33" then return "TRANSFERENCIA FILIAL - FORNECEDOR (MED. CONTROLADO)".
    when "35" then return "BALAN€O GERAL CONTROLADOS DEPOSITO".
    when "36" then return "BALAN€O GERAL CONTROLADOS FILIAL".
    when "37" then return "ATIVO IMOBILIZADO DEPOSITO => FILIAL".
    when "38" then return "ESTORNO".
    when "39" then return "ATIVO IMOBILIZADO FILIAL => FILIAL".
    otherwise return "".
end case.

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

