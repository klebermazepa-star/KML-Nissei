&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
          custom           PROGRESS
*/
&Scoped-define WINDOW-NAME C-Win
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS C-Win 
/*------------------------------------------------------------------------

  File: 

  Description: 

  Input Parameters:
      <none>

  Output Parameters:
      <none>

  Author: 

  Created: 

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress AppBuilder.      */
/*----------------------------------------------------------------------*/

/* Create an unnamed pool to store all the widgets created 
     by this procedure. This is a good default which assures
     that this procedure's triggers and internal procedures 
     will execute in this procedure's storage, and that proper
     cleanup will occur on deletion of the procedure. */

CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */

define new global shared var wh-cod-estabel-ft0904 as HANDLE NO-UNDO.
define new global shared var wh-serie-ft0904 as HANDLE NO-UNDO.
define new global shared var wh-nr-nota-fis-ft0904 as HANDLE NO-UNDO.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Window
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME DEFAULT-FRAME
&Scoped-define BROWSE-NAME brCartao

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES cst-fat-duplic cst_nota_fiscal

/* Definitions for BROWSE brCartao                                      */
&Scoped-define FIELDS-IN-QUERY-brCartao cst-fat-duplic.parcela ~
cst-fat-duplic.condipag cst_fat_duplic.cod_cond_pag ~
cst_fat_duplic.adm_cartao cst_fat_duplic.cod_portador ~
cst-fat-duplic.modalidade cst_fat_duplic.nsu_admin ~
cst_fat_duplic.nsu_numero cst_fat_duplic.taxa_admin 
&Scoped-define ENABLED-FIELDS-IN-QUERY-brCartao 
&Scoped-define QUERY-STRING-brCartao FOR EACH cst-fat-duplic NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-brCartao OPEN QUERY brCartao FOR EACH cst-fat-duplic NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-brCartao cst-fat-duplic
&Scoped-define FIRST-TABLE-IN-QUERY-brCartao cst-fat-duplic


/* Definitions for FRAME DEFAULT-FRAME                                  */
&Scoped-define FIELDS-IN-QUERY-DEFAULT-FRAME cst_nota_fiscal.cpf_cupom ~
cst_nota_fiscal.convenio cst_nota_fiscal.condipag ~
cst_nota_fiscal.valor_cartao cst_nota_fiscal.valor_dinheiro ~
cst_nota_fiscal.valor_chq cst_nota_fiscal.valor_chq_pre ~
cst_nota_fiscal.valor_convenio cst_nota_fiscal.valor_ticket ~
cst_nota_fiscal.valor_vale cst_nota_fiscal.cartao_manual ~
cst_nota_fiscal.id_pedido_convenio 
&Scoped-define ENABLED-FIELDS-IN-QUERY-DEFAULT-FRAME ~
cst_nota_fiscal.id_pedido_convenio 
&Scoped-define ENABLED-TABLES-IN-QUERY-DEFAULT-FRAME cst_nota_fiscal
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-DEFAULT-FRAME cst_nota_fiscal
&Scoped-define QUERY-STRING-DEFAULT-FRAME FOR EACH cst_nota_fiscal SHARE-LOCK
&Scoped-define OPEN-QUERY-DEFAULT-FRAME OPEN QUERY DEFAULT-FRAME FOR EACH cst_nota_fiscal SHARE-LOCK.
&Scoped-define TABLES-IN-QUERY-DEFAULT-FRAME cst_nota_fiscal
&Scoped-define FIRST-TABLE-IN-QUERY-DEFAULT-FRAME cst_nota_fiscal


/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS cst_nota_fiscal.id_pedido_convenio 
&Scoped-define ENABLED-TABLES cst_nota_fiscal
&Scoped-define FIRST-ENABLED-TABLE cst_nota_fiscal
&Scoped-Define ENABLED-OBJECTS RECT-2 brCartao 
&Scoped-Define DISPLAYED-FIELDS cst_nota_fiscal.cpf-cupom ~
cst_nota_fiscal.convenio cst_nota_fiscal.condipag ~
cst_nota_fiscal.valor-cartao cst_nota_fiscal.valor-dinheiro ~
cst_nota_fiscal.valor-chq cst_nota_fiscal.valor-chq-pre ~
cst_nota_fiscal.valor-convenio cst_nota_fiscal.valor-ticket ~
cst_nota_fiscal.valor-vale cst_nota_fiscal.cartao-manual ~
cst_nota_fiscal.id_pedido_convenio 
&Scoped-define DISPLAYED-TABLES cst_nota_fiscal
&Scoped-define FIRST-DISPLAYED-TABLE cst_nota_fiscal
&Scoped-Define DISPLAYED-OBJECTS i-cod-emitente c-nome-emit 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR C-Win AS WIDGET-HANDLE NO-UNDO.

/* Definitions of the field level widgets                               */
DEFINE VARIABLE c-nome-emit AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 38 BY .79 NO-UNDO.

DEFINE VARIABLE i-cod-emitente AS INTEGER FORMAT ">>>>>>>>9":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 10 BY .79 NO-UNDO.

DEFINE RECTANGLE RECT-2
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 81 BY 7.25.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY brCartao FOR 
      cst_fat_duplic SCROLLING.

DEFINE QUERY DEFAULT-FRAME FOR 
      cst_nota_fiscal SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE brCartao
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS brCartao C-Win _STRUCTURED
  QUERY brCartao NO-LOCK DISPLAY
      cst_fat_duplic.parcela FORMAT "x(02)":U
      cst_fat_duplic.condipag FORMAT "x(2)":U WIDTH 8.43
      cst_fat_duplic.cod_cond_pag FORMAT ">>9":U
      cst_fat_duplic.adm_cartao FORMAT "x(3)":U WIDTH 6.43
      cst_fat_duplic.cod_portador FORMAT ">>>>9":U WIDTH 6.86
      cst_fat_duplic.modalidade FORMAT "9":U
      cst_fat_duplic.nsu_admin FORMAT "x(10)":U WIDTH 13
      cst_fat_duplic.nsu_numero FORMAT "x(10)":U WIDTH 11.43
      cst_fat_duplic.taxa_admin FORMAT "->>>,>>>,>>9.99":U WIDTH 12.43
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 81 BY 5.75
         FONT 1 ROW-HEIGHT-CHARS .5.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME DEFAULT-FRAME
     cst_nota_fiscal.cpf_cupom AT ROW 1.75 COL 15 COLON-ALIGNED WIDGET-ID 6
          VIEW-AS FILL-IN 
          SIZE 14 BY .79
     i-cod-emitente AT ROW 1.75 COL 29 COLON-ALIGNED NO-LABEL WIDGET-ID 36
     c-nome-emit AT ROW 1.75 COL 39 COLON-ALIGNED NO-LABEL WIDGET-ID 34
     cst_nota_fiscal.convenio AT ROW 2.75 COL 15 COLON-ALIGNED WIDGET-ID 4
          VIEW-AS FILL-IN 
          SIZE 7 BY .79
     cst_nota_fiscal.condipag AT ROW 2.75 COL 63 COLON-ALIGNED WIDGET-ID 2
          VIEW-AS FILL-IN 
          SIZE 4 BY .79
     cst_nota_fiscal.valor_cartao AT ROW 3.75 COL 15 COLON-ALIGNED WIDGET-ID 16
          VIEW-AS FILL-IN 
          SIZE 11.86 BY .79
     cst_nota_fiscal.valor_dinheiro AT ROW 3.75 COL 63 COLON-ALIGNED WIDGET-ID 24
          VIEW-AS FILL-IN 
          SIZE 11.86 BY .79
     cst_nota_fiscal.valor_chq AT ROW 4.75 COL 15 COLON-ALIGNED WIDGET-ID 18
          VIEW-AS FILL-IN 
          SIZE 11.86 BY .79
     cst_nota_fiscal.valor_chq_pre AT ROW 4.75 COL 63 COLON-ALIGNED WIDGET-ID 20
          VIEW-AS FILL-IN 
          SIZE 11.86 BY .79
     cst_nota_fiscal.valor_convenio AT ROW 5.75 COL 15 COLON-ALIGNED WIDGET-ID 22
          VIEW-AS FILL-IN 
          SIZE 11.86 BY .79
     cst_nota_fiscal.valor_ticket AT ROW 5.75 COL 63 COLON-ALIGNED WIDGET-ID 26
          VIEW-AS FILL-IN 
          SIZE 11.86 BY .79
     cst_nota_fiscal.valor_vale AT ROW 6.75 COL 15 COLON-ALIGNED WIDGET-ID 28
          VIEW-AS FILL-IN 
          SIZE 11.86 BY .79
     cst_nota_fiscal.cartao_manual AT ROW 6.75 COL 36 WIDGET-ID 32
          VIEW-AS TOGGLE-BOX
          SIZE 13 BY .83
     cst_nota_fiscal.id_pedido_convenio AT ROW 6.75 COL 63 COLON-ALIGNED WIDGET-ID 40
          VIEW-AS FILL-IN 
          SIZE 12 BY .79
     brCartao AT ROW 8.75 COL 2 WIDGET-ID 200
     RECT-2 AT ROW 1 COL 2 WIDGET-ID 38
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 82.72 BY 13.96
         FONT 1 WIDGET-ID 100.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Window
   Allow: Basic,Browse,DB-Fields,Window,Query
   Other Settings: COMPILE
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
IF SESSION:DISPLAY-TYPE = "GUI":U THEN
  CREATE WINDOW C-Win ASSIGN
         HIDDEN             = YES
         TITLE              = "Detalhes Cupom Fiscal"
         HEIGHT             = 13.96
         WIDTH              = 82.72
         MAX-HEIGHT         = 16
         MAX-WIDTH          = 82.72
         VIRTUAL-HEIGHT     = 16
         VIRTUAL-WIDTH      = 82.72
         RESIZE             = yes
         SCROLL-BARS        = no
         STATUS-AREA        = no
         BGCOLOR            = ?
         FGCOLOR            = ?
         KEEP-FRAME-Z-ORDER = yes
         THREE-D            = yes
         MESSAGE-AREA       = no
         SENSITIVE          = yes.
ELSE {&WINDOW-NAME} = CURRENT-WINDOW.
/* END WINDOW DEFINITION                                                */
&ANALYZE-RESUME



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW C-Win
  VISIBLE,,RUN-PERSISTENT                                               */
/* SETTINGS FOR FRAME DEFAULT-FRAME
   FRAME-NAME                                                           */
/* BROWSE-TAB brCartao id_pedido_convenio DEFAULT-FRAME */
ASSIGN 
       brCartao:COLUMN-RESIZABLE IN FRAME DEFAULT-FRAME       = TRUE
       brCartao:COLUMN-MOVABLE IN FRAME DEFAULT-FRAME         = TRUE.

/* SETTINGS FOR FILL-IN c-nome-emit IN FRAME DEFAULT-FRAME
   NO-ENABLE                                                            */
/* SETTINGS FOR TOGGLE-BOX cst_nota_fiscal.cartao-manual IN FRAME DEFAULT-FRAME
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN cst_nota_fiscal.condipag IN FRAME DEFAULT-FRAME
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN cst_nota_fiscal.convenio IN FRAME DEFAULT-FRAME
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN cst_nota_fiscal.cpf-cupom IN FRAME DEFAULT-FRAME
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN i-cod-emitente IN FRAME DEFAULT-FRAME
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN cst_nota_fiscal.valor-cartao IN FRAME DEFAULT-FRAME
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN cst_nota_fiscal.valor-chq IN FRAME DEFAULT-FRAME
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN cst_nota_fiscal.valor-chq-pre IN FRAME DEFAULT-FRAME
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN cst_nota_fiscal.valor-convenio IN FRAME DEFAULT-FRAME
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN cst_nota_fiscal.valor-dinheiro IN FRAME DEFAULT-FRAME
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN cst_nota_fiscal.valor-ticket IN FRAME DEFAULT-FRAME
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN cst_nota_fiscal.valor-vale IN FRAME DEFAULT-FRAME
   NO-ENABLE                                                            */
IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(C-Win)
THEN C-Win:HIDDEN = no.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE brCartao
/* Query rebuild information for BROWSE brCartao
     _TblList          = "custom.cst-fat-duplic"
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _FldNameList[1]   = custom.cst-fat-duplic.parcela
     _FldNameList[2]   > custom.cst-fat-duplic.condipag
"cst-fat-duplic.condipag" ? ? "character" ? ? ? ? ? ? no ? no no "8.43" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[3]   = custom.cst_fat_duplic.cod_cond_pag
     _FldNameList[4]   > custom.cst_fat_duplic.adm_cartao
"cst_fat_duplic.adm_cartao" ? ? "character" ? ? ? ? ? ? no ? no no "6.43" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[5]   > custom.cst_fat_duplic.cod_portador
"cst_fat_duplic.cod_portador" ? ? "integer" ? ? ? ? ? ? no ? no no "6.86" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[6]   = custom.cst-fat-duplic.modalidade
     _FldNameList[7]   > custom.cst_fat_duplic.nsu_admin
"cst_fat_duplic.nsu_admin" ? ? "character" ? ? ? ? ? ? no ? no no "13" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[8]   > custom.cst_fat_duplic.nsu_numero
"cst_fat_duplic.nsu_numero" ? ? "character" ? ? ? ? ? ? no ? no no "11.43" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[9]   > custom.cst_fat_duplic.taxa_admin
"cst_fat_duplic.taxa_admin" ? ? "decimal" ? ? ? ? ? ? no ? no no "12.43" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _Query            is NOT OPENED
*/  /* BROWSE brCartao */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK FRAME DEFAULT-FRAME
/* Query rebuild information for FRAME DEFAULT-FRAME
     _TblList          = "custom.cst_nota_fiscal"
     _Query            is NOT OPENED
*/  /* FRAME DEFAULT-FRAME */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME C-Win
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL C-Win C-Win
ON END-ERROR OF C-Win /* Detalhes Cupom Fiscal */
OR ENDKEY OF {&WINDOW-NAME} ANYWHERE DO:
  /* This case occurs when the user presses the "Esc" key.
     In a persistently run window, just ignore this.  If we did not, the
     application would exit. */
  IF THIS-PROCEDURE:PERSISTENT THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL C-Win C-Win
ON WINDOW-CLOSE OF C-Win /* Detalhes Cupom Fiscal */
DO:
  /* This event will close the window and terminate the procedure.  */
  APPLY "CLOSE":U TO THIS-PROCEDURE.
  RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME brCartao
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK C-Win 


/* ***************************  Main Block  *************************** */

/* Set CURRENT-WINDOW: this will parent dialog-boxes and frames.        */
ASSIGN CURRENT-WINDOW                = {&WINDOW-NAME} 
       THIS-PROCEDURE:CURRENT-WINDOW = {&WINDOW-NAME}.

/* The CLOSE event can be used from inside or outside the procedure to  */
/* terminate it.                                                        */
ON CLOSE OF THIS-PROCEDURE 
   RUN disable_UI.

/* Best default for GUI applications is...                              */
PAUSE 0 BEFORE-HIDE.

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

  /*RUN enable_UI.*/
    VIEW C-Win.
    for each cst_nota_fiscal no-lock where 
        cst_nota_fiscal.cod_estabel = wh-cod-estabel-ft0904 :screen-value and
        cst_nota_fiscal.serie       = wh-serie-ft0904 :screen-value and
        cst_nota_fiscal.nr_nota_fis = wh-nr-nota-fis-ft0904 :screen-value
        query-tuning(no-lookahead):
        display {&FIELDS-IN-QUERY-{&FRAME-NAME}} with FRAME {&FRAME-NAME}.
        for each emitente fields (cod-emitente nome-emit) no-lock where 
            emitente.cgc = cst_nota_fiscal.cpf_cupom
            query-tuning(no-lookahead):
            i-cod-emitente:screen-value in FRAME {&FRAME-NAME} = string(emitente.cod-emitente).
            c-nome-emit:screen-value in FRAME {&FRAME-NAME} = emitente.nome-emit.
        end.
        close query brCartao.
        open query brCartao 
            for each cst_fat_duplic NO-LOCK where 
                cst_fat_duplic.cod_estabel = cst_nota_fiscal.cod_estabel and
                cst_fat_duplic.serie = cst_nota_fiscal.serie and
                cst_fat_duplic.nr_fatura = cst_nota_fiscal.nr_nota_fis
                query-tuning(no-lookahead).
        enable brCartao with FRAME {&FRAME-NAME}.
    end.
  IF NOT THIS-PROCEDURE:PERSISTENT THEN
    WAIT-FOR CLOSE OF THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI C-Win  _DEFAULT-DISABLE
PROCEDURE disable_UI :
/*------------------------------------------------------------------------------
  Purpose:     DISABLE the User Interface
  Parameters:  <none>
  Notes:       Here we clean-up the user-interface by deleting
               dynamic widgets we have created and/or hide 
               frames.  This procedure is usually called when
               we are ready to "clean-up" after running.
------------------------------------------------------------------------------*/
  /* Delete the WINDOW we created */
  IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(C-Win)
  THEN DELETE WIDGET C-Win.
  IF THIS-PROCEDURE:PERSISTENT THEN DELETE PROCEDURE THIS-PROCEDURE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI C-Win  _DEFAULT-ENABLE
PROCEDURE enable_UI :
/*------------------------------------------------------------------------------
  Purpose:     ENABLE the User Interface
  Parameters:  <none>
  Notes:       Here we display/view/enable the widgets in the
               user-interface.  In addition, OPEN all queries
               associated with each FRAME and BROWSE.
               These statements here are based on the "Other 
               Settings" section of the widget Property Sheets.
------------------------------------------------------------------------------*/
  DISPLAY i-cod-emitente c-nome-emit 
      WITH FRAME DEFAULT-FRAME IN WINDOW C-Win.
  IF AVAILABLE cst_nota_fiscal THEN 
    DISPLAY cst_nota_fiscal.cpf_cupom cst_nota_fiscal.convenio 
          cst_nota_fiscal.condipag cst_nota_fiscal.valor_cartao 
          cst_nota_fiscal.valor_dinheiro cst_nota_fiscal.valor_chq 
          cst_nota_fiscal.valor_chq_pre cst_nota_fiscal.valor_convenio 
          cst_nota_fiscal.valor_ticket cst_nota_fiscal.valor_vale 
          cst_nota_fiscal.cartao_manual cst_nota_fiscal.id_pedido_convenio 
      WITH FRAME DEFAULT-FRAME IN WINDOW C-Win.
  ENABLE RECT-2 cst_nota_fiscal.id_pedido_convenio brCartao 
      WITH FRAME DEFAULT-FRAME IN WINDOW C-Win.
  {&OPEN-BROWSERS-IN-QUERY-DEFAULT-FRAME}
  VIEW C-Win.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

