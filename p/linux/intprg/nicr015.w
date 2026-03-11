&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI ADM1
&ANALYZE-RESUME
/* Connected Databases 
*/
&Scoped-define WINDOW-NAME W-Win
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS W-Win 
/*********************************************************************
* Copyright (C) 2000 by Progress Software Corporation. All rights    *
* reserved. Prior versions of this work may contain portions         *
* contributed by participants of Possenet.                           *
*                                                                    *
*********************************************************************/
DEFINE BUFFER cliente FOR ems5.cliente.
/*------------------------------------------------------------------------

  File: 

  Description: from cntnrwin.w - ADM SmartWindow Template

  Input Parameters:
      <none>

  Output Parameters:
      <none>

  History: 
          
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

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */

DEFINE TEMP-TABLE tt-convenio LIKE int_ds_convenio
    FIELD cod-emitente LIKE emitente.cod-emitente
    FIELD nome-abrev   LIKE emitente.nome-abrev
    FIELD nome-emit    LIKE emitente.nome-emit
    FIELD receita      AS CHAR FORMAT "x(20)".

DEFINE VARIABLE h-acomp          AS HANDLE                   NO-UNDO.

DEFINE BUFFER bf-emitente FOR emitente.

DEF NEW GLOBAL SHARED VAR c-seg-usuario AS CHAR NO-UNDO.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE SmartWindow
&Scoped-define DB-AWARE no

&Scoped-define ADM-CONTAINER WINDOW

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME F-Main
&Scoped-define BROWSE-NAME br-convenio

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-convenio

/* Definitions for BROWSE br-convenio                                   */
&Scoped-define FIELDS-IN-QUERY-br-convenio /* int_ds_convenio.cnpj */ tt-convenio.cod_convenio tt-convenio.cod-emitente tt-convenio.nome-abrev tt-convenio.nome-emit tt-convenio.dia-fechamento tt-convenio.dia-vencimento tt-convenio.log-envia-cupom /* tt-convenio.receita */   
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-convenio   
&Scoped-define SELF-NAME br-convenio
&Scoped-define QUERY-STRING-br-convenio FOR EACH tt-convenio BY tt-convenio.cod_convenio
&Scoped-define OPEN-QUERY-br-convenio OPEN QUERY {&SELF-NAME} FOR EACH tt-convenio BY tt-convenio.cod_convenio.
&Scoped-define TABLES-IN-QUERY-br-convenio tt-convenio
&Scoped-define FIRST-TABLE-IN-QUERY-br-convenio tt-convenio


/* Definitions for FRAME F-Main                                         */
&Scoped-define OPEN-BROWSERS-IN-QUERY-F-Main ~
    ~{&OPEN-QUERY-br-convenio}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS RECT-1 RECT-2 rt-button IMAGE-1 IMAGE-2 ~
IMAGE-3 IMAGE-4 IMAGE-5 IMAGE-6 fi-convenio-ini fi-convenio-fim ~
fi-cliente-ini fi-cliente-fim fi-nome-ini fi-nome-fim bt-carrega-convenio ~
rs-envia-cupom br-convenio bt-cancelar 
&Scoped-Define DISPLAYED-OBJECTS fi-convenio-ini fi-convenio-fim ~
fi-cliente-ini fi-cliente-fim fi-nome-ini fi-nome-fim rs-envia-cupom 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR W-Win AS WIDGET-HANDLE NO-UNDO.

/* Definitions of the field level widgets                               */
DEFINE BUTTON bt-cancelar AUTO-END-KEY 
     LABEL "Fechar" 
     SIZE 10 BY 1.

DEFINE BUTTON bt-carrega-convenio 
     IMAGE-UP FILE "image/im-cq.bmp":U
     IMAGE-INSENSITIVE FILE "image/ii-cq.bmp":U
     LABEL "Carrega Convˆnio" 
     SIZE 4 BY 1 TOOLTIP "Aplica Filtro na Listagem de Convˆnio".

DEFINE VARIABLE fi-cliente-fim AS INTEGER FORMAT ">>>>>>>>>>9":U INITIAL 999999999 
     VIEW-AS FILL-IN 
     SIZE 14 BY .88 NO-UNDO.

DEFINE VARIABLE fi-cliente-ini AS INTEGER FORMAT ">>>>>>>>>>9":U INITIAL 0 
     LABEL "Cliente" 
     VIEW-AS FILL-IN 
     SIZE 14 BY .88 NO-UNDO.

DEFINE VARIABLE fi-convenio-fim AS INTEGER FORMAT ">>>>>>9":U INITIAL 999999 
     VIEW-AS FILL-IN 
     SIZE 14 BY .88 NO-UNDO.

DEFINE VARIABLE fi-convenio-ini AS INTEGER FORMAT ">>>>>>9":U INITIAL 0 
     LABEL "Convˆnio" 
     VIEW-AS FILL-IN 
     SIZE 14 BY .88 NO-UNDO.

DEFINE VARIABLE fi-nome-fim AS CHARACTER FORMAT "X(100)":U INITIAL "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ" 
     VIEW-AS FILL-IN 
     SIZE 29.57 BY .88 NO-UNDO.

DEFINE VARIABLE fi-nome-ini AS CHARACTER FORMAT "X(100)":U 
     LABEL "Nome Cliente" 
     VIEW-AS FILL-IN 
     SIZE 29.57 BY .88 NO-UNDO.

DEFINE IMAGE IMAGE-1
     FILENAME "image\im-fir":U
     SIZE 3 BY .88.

DEFINE IMAGE IMAGE-2
     FILENAME "image\im-las":U
     SIZE 3 BY .88.

DEFINE IMAGE IMAGE-3
     FILENAME "image\im-fir":U
     SIZE 3 BY .88.

DEFINE IMAGE IMAGE-4
     FILENAME "image\im-las":U
     SIZE 3 BY .88.

DEFINE IMAGE IMAGE-5
     FILENAME "image\im-fir":U
     SIZE 3 BY .88.

DEFINE IMAGE IMAGE-6
     FILENAME "image\im-las":U
     SIZE 3 BY .88.

DEFINE VARIABLE rs-envia-cupom AS INTEGER INITIAL 3 
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS 
          "Sim", 1,
"NÆo", 2,
"Ambos", 3
     SIZE 34 BY .75 NO-UNDO.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 108.57 BY 4.38.

DEFINE RECTANGLE RECT-2
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 108.57 BY 15.29.

DEFINE RECTANGLE rt-button
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 108.72 BY 1.42
     BGCOLOR 7 .

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-convenio FOR 
      tt-convenio SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-convenio
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-convenio W-Win _FREEFORM
  QUERY br-convenio DISPLAY
      /* int_ds_convenio.cnpj */
     tt-convenio.cod_convenio
     tt-convenio.cod-emitente
     tt-convenio.nome-abrev
     tt-convenio.nome-emit  FORMAT "x(50)"
     tt-convenio.dia_fechamento 
     tt-convenio.dia_vencimento 
     tt-convenio.log_envia_cupom FORMAT "Sim/NÆo" COLUMN-LABEL "Envia Cupom"
/*      tt-convenio.receita FORMAT "x(12)" COLUMN-LABEL "Venda Receita" */
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS MULTIPLE SIZE 106.72 BY 14.71 ROW-HEIGHT-CHARS .58 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME F-Main
     fi-convenio-ini AT ROW 1.71 COL 28.14 COLON-ALIGNED WIDGET-ID 60
     fi-convenio-fim AT ROW 1.71 COL 48.72 COLON-ALIGNED NO-LABEL WIDGET-ID 58
     fi-cliente-ini AT ROW 2.67 COL 28.14 COLON-ALIGNED WIDGET-ID 68
     fi-cliente-fim AT ROW 2.67 COL 48.72 COLON-ALIGNED NO-LABEL WIDGET-ID 66
     fi-nome-ini AT ROW 3.63 COL 12.57 COLON-ALIGNED WIDGET-ID 14
     fi-nome-fim AT ROW 3.63 COL 48.72 COLON-ALIGNED NO-LABEL WIDGET-ID 16
     bt-carrega-convenio AT ROW 4.46 COL 80.72 WIDGET-ID 34
     rs-envia-cupom AT ROW 4.67 COL 37 NO-LABEL WIDGET-ID 74
     br-convenio AT ROW 6.04 COL 2.29 WIDGET-ID 200
     bt-cancelar AT ROW 21.33 COL 99.14 HELP
          "Fechar" WIDGET-ID 30
     "Envia Cupom:" VIEW-AS TEXT
          SIZE 13.14 BY .67 AT ROW 4.67 COL 22.14 WIDGET-ID 78
     "Filtro" VIEW-AS TEXT
          SIZE 4.57 BY .67 AT ROW 1.04 COL 2.43 WIDGET-ID 8
     RECT-1 AT ROW 1.25 COL 1.57 WIDGET-ID 2
     RECT-2 AT ROW 5.71 COL 1.43 WIDGET-ID 4
     rt-button AT ROW 21.13 COL 1.43 WIDGET-ID 6
     IMAGE-1 AT ROW 3.67 COL 44.43 WIDGET-ID 20
     IMAGE-2 AT ROW 3.67 COL 47.57 WIDGET-ID 22
     IMAGE-3 AT ROW 1.75 COL 44.43 WIDGET-ID 62
     IMAGE-4 AT ROW 1.75 COL 47.57 WIDGET-ID 64
     IMAGE-5 AT ROW 2.71 COL 44.43 WIDGET-ID 70
     IMAGE-6 AT ROW 2.71 COL 47.57 WIDGET-ID 72
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 109.72 BY 21.71 WIDGET-ID 100.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: SmartWindow
   Allow: Basic,Browse,DB-Fields,Query,Smart,Window
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
IF SESSION:DISPLAY-TYPE = "GUI":U THEN
  CREATE WINDOW W-Win ASSIGN
         HIDDEN             = YES
         TITLE              = "Lista Convˆnio Datasul - Sysfarma"
         HEIGHT             = 21.71
         WIDTH              = 109.72
         MAX-HEIGHT         = 34.88
         MAX-WIDTH          = 228.57
         VIRTUAL-HEIGHT     = 34.88
         VIRTUAL-WIDTH      = 228.57
         RESIZE             = no
         SCROLL-BARS        = no
         STATUS-AREA        = no
         BGCOLOR            = ?
         FGCOLOR            = ?
         THREE-D            = yes
         MESSAGE-AREA       = no
         SENSITIVE          = yes.
ELSE {&WINDOW-NAME} = CURRENT-WINDOW.
/* END WINDOW DEFINITION                                                */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _INCLUDED-LIB W-Win 
/* ************************* Included-Libraries *********************** */

{src/adm/method/containr.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME




/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW W-Win
  VISIBLE,,RUN-PERSISTENT                                               */
/* SETTINGS FOR FRAME F-Main
   FRAME-NAME                                                           */
/* BROWSE-TAB br-convenio rs-envia-cupom F-Main */
IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(W-Win)
THEN W-Win:HIDDEN = yes.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-convenio
/* Query rebuild information for BROWSE br-convenio
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH tt-convenio BY tt-convenio.cod_convenio.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE br-convenio */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME W-Win
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL W-Win W-Win
ON END-ERROR OF W-Win /* Lista Convˆnio Datasul - Sysfarma */
OR ENDKEY OF {&WINDOW-NAME} ANYWHERE DO:
  /* This case occurs when the user presses the "Esc" key.
     In a persistently run window, just ignore this.  If we did not, the
     application would exit. */
  IF THIS-PROCEDURE:PERSISTENT THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL W-Win W-Win
ON WINDOW-CLOSE OF W-Win /* Lista Convˆnio Datasul - Sysfarma */
DO:
  /* This ADM code must be left here in order for the SmartWindow
     and its descendents to terminate properly on exit. */
  APPLY "CLOSE":U TO THIS-PROCEDURE.
  RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-convenio
&Scoped-define SELF-NAME br-convenio
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-convenio W-Win
ON MOUSE-SELECT-DBLCLICK OF br-convenio IN FRAME F-Main
DO:
/*   IF tt-tit-acr.marca = YES THEN       */
/*        ASSIGN tt-tit-acr.marca  = NO.  */
/*   ELSE ASSIGN tt-tit-acr.marca  = YES. */
/*                                        */
/*   br-tit-acr:REFRESH().                */
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-cancelar
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-cancelar W-Win
ON CHOOSE OF bt-cancelar IN FRAME F-Main /* Fechar */
DO:
   apply "close":U to this-procedure.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-carrega-convenio
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-carrega-convenio W-Win
ON CHOOSE OF bt-carrega-convenio IN FRAME F-Main /* Carrega Convˆnio */
DO:
  RUN pi-carrega-convenio.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK W-Win 


/* ***************************  Main Block  *************************** */

/* Include custom  Main Block code for SmartWindows. */
{src/adm/template/windowmn.i}

RUN pi-inicializar.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE adm-create-objects W-Win  _ADM-CREATE-OBJECTS
PROCEDURE adm-create-objects :
/*------------------------------------------------------------------------------
  Purpose:     Create handles for all SmartObjects used in this procedure.
               After SmartObjects are initialized, then SmartLinks are added.
  Parameters:  <none>
------------------------------------------------------------------------------*/

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE adm-row-available W-Win  _ADM-ROW-AVAILABLE
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI W-Win  _DEFAULT-DISABLE
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
  IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(W-Win)
  THEN DELETE WIDGET W-Win.
  IF THIS-PROCEDURE:PERSISTENT THEN DELETE PROCEDURE THIS-PROCEDURE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI W-Win  _DEFAULT-ENABLE
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
  DISPLAY fi-convenio-ini fi-convenio-fim fi-cliente-ini fi-cliente-fim 
          fi-nome-ini fi-nome-fim rs-envia-cupom 
      WITH FRAME F-Main IN WINDOW W-Win.
  ENABLE RECT-1 RECT-2 rt-button IMAGE-1 IMAGE-2 IMAGE-3 IMAGE-4 IMAGE-5 
         IMAGE-6 fi-convenio-ini fi-convenio-fim fi-cliente-ini fi-cliente-fim 
         fi-nome-ini fi-nome-fim bt-carrega-convenio rs-envia-cupom br-convenio 
         bt-cancelar 
      WITH FRAME F-Main IN WINDOW W-Win.
  {&OPEN-BROWSERS-IN-QUERY-F-Main}
  VIEW W-Win.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-exit W-Win 
PROCEDURE local-exit :
/* -----------------------------------------------------------
  Purpose:  Starts an "exit" by APPLYing CLOSE event, which starts "destroy".
  Parameters:  <none>
  Notes:    If activated, should APPLY CLOSE, *not* dispatch adm-exit.   
-------------------------------------------------------------*/
   APPLY "CLOSE":U TO THIS-PROCEDURE.
   
   RETURN.
       
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-carrega-convenio W-Win 
PROCEDURE pi-carrega-convenio :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
EMPTY TEMP-TABLE tt-convenio.

{&OPEN-QUERY-BR-CONVENIO}

    FOR EACH int_ds_convenio
       WHERE int_ds_convenio.cod_convenio >= INPUT FRAME {&FRAME-NAME} fi-convenio-ini
         AND int_ds_convenio.cod_convenio <= INPUT FRAME {&FRAME-NAME} fi-convenio-fim NO-LOCK,
       FIRST emitente USE-INDEX cgc NO-LOCK
       WHERE emitente.cgc = int_ds_convenio.cnpj
         AND emitente.cod-emitente >= INPUT FRAME {&FRAME-NAME} fi-cliente-ini
         AND emitente.cod-emitente <= INPUT FRAME {&FRAME-NAME} fi-cliente-fim
         AND emitente.nome-emit    >= INPUT FRAME {&FRAME-NAME} fi-nome-ini
         AND emitente.nome-emit    <= INPUT FRAME {&FRAME-NAME} fi-nome-fim :

         IF INPUT FRAME {&FRAME-NAME} rs-envia-cupom = 1 THEN DO:
             IF int_ds_convenio.log_envia_cupom = NO THEN NEXT.
         END.
         ELSE IF INPUT FRAME {&FRAME-NAME} rs-envia-cupom = 2 THEN DO:
             IF int_ds_convenio.log_envia_cupom = YES THEN NEXT.
         END.

         CREATE tt-convenio.
         ASSIGN tt-convenio.cod_convenio    = int_ds_convenio.cod_convenio 
                tt-convenio.dia_fechamento  = int_ds_convenio.dia_fechamento 
                tt-convenio.dia_vencimento  = int_ds_convenio.dia_vencimento 
                tt-convenio.log_envia_cupom = int_ds_convenio.log_envia_cupom.

         ASSIGN tt-convenio.cod-emitente = emitente.cod-emitente
                tt-convenio.nome-abrev   = emitente.nome-abrev
                tt-convenio.nome-emit    = emitente.nome-emit.

/*          IF int_ds_convenio.tipo-venda = 1 THEN DO:                                        */
/*              ASSIGN tt-convenio.receita = "Com Receita".                                   */
/*          END.                                                                              */
/*          ELSE IF int_ds_convenio.tipo-venda = 2 THEN DO:                                   */
/*              ASSIGN tt-convenio.receita = "Sem Receita".                                   */
/*          END.                                                                              */
/*          ELSE IF int_ds_convenio.tipo-venda = 0 OR int_ds_convenio.tipo-venda = 3 THEN DO: */
/*              ASSIGN tt-convenio.receita = "Ambos".                                         */
/*          END.                                                                              */

    END.

{&OPEN-QUERY-BR-CONVENIO}


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-carrega-titulo-filtro W-Win 
PROCEDURE pi-carrega-titulo-filtro :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-carrega-titulo-sel-filtro W-Win 
PROCEDURE pi-carrega-titulo-sel-filtro :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-cria-titulo-acr W-Win 
PROCEDURE pi-cria-titulo-acr :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-executar W-Win 
PROCEDURE pi-executar :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-gera-convenio-cliente W-Win 
PROCEDURE pi-gera-convenio-cliente :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/



END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-inicializar W-Win 
PROCEDURE pi-inicializar :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
/* ASSIGN tg-escolhe:SCREEN-VALUE IN FRAME {&FRAME-NAME} = "NO". */
/*                                                               */
 APPLY "CHOOSE" TO bt-carrega-convenio IN FRAME {&FRAME-NAME}.   

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-retorna-sugestao-referencia W-Win 
PROCEDURE pi-retorna-sugestao-referencia :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
END PROCEDURE. /* pi_retorna_sugestao_referencia */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-verifica-refer-unica-acr W-Win 
PROCEDURE pi-verifica-refer-unica-acr :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/


    /************************ Parameter Definition Begin ************************/

    DEF INPUT  PARAM p_cod_estab     AS CHAR FORMAT "x(3)"    NO-UNDO.
    DEF INPUT  PARAM p_cod_refer     AS CHAR FORMAT "x(10)"   NO-UNDO.
    DEF INPUT  PARAM p_cod_table     AS CHAR FORMAT "x(8)"    NO-UNDO.
    DEF INPUT  PARAM p_rec_tabela    AS RECID     FORMAT ">>>>>>9" NO-UNDO.
    DEF OUTPUT PARAM p_log_refer_uni AS LOGICAL   FORMAT "Sim/Nao" NO-UNDO.

    /************************* Parameter Definition End *************************/

    /************************** Buffer Definition Begin *************************/

    DEF BUFFER b_cobr_especial_acr FOR cobr_especial_acr.
    DEF BUFFER b_lote_impl_tit_acr FOR lote_impl_tit_acr.
    DEF BUFFER b_lote_liquidac_acr FOR lote_liquidac_acr.
    DEF BUFFER b_movto_tit_acr     FOR movto_tit_acr.
    DEF BUFFER b_renegoc_acr       FOR renegoc_acr.

    /*************************** Buffer Definition End **************************/

    /************************* Variable Definition Begin ************************/

    DEF VAR v_cod_return AS CHAR FORMAT "x(40)" NO-UNDO.

    /************************** Variable Definition End *************************/

    ASSIGN p_log_refer_uni = YES.

    IF p_cod_table <> "lote_impl_tit_acr" /*l_lote_impl_tit_acr*/  THEN DO:
        FIND FIRST b_lote_impl_tit_acr NO-LOCK USE-INDEX ltmplttc_id
             WHERE b_lote_impl_tit_acr.cod_estab = p_cod_estab
               AND b_lote_impl_tit_acr.cod_refer = p_cod_refer
               AND RECID( b_lote_impl_tit_acr ) <> p_rec_tabela NO-ERROR.
        IF AVAIL b_lote_impl_tit_acr THEN
            ASSIGN p_log_refer_uni = NO.
    END.

    IF p_cod_table <> "lote_liquidac_acr" /*l_lote_liquidac_acr*/  THEN DO:
        FIND FIRST b_lote_liquidac_acr NO-LOCK USE-INDEX ltlqdccr_id
             where b_lote_liquidac_acr.cod_estab_refer = p_cod_estab
               and b_lote_liquidac_acr.cod_refer       = p_cod_refer
               and recid( b_lote_liquidac_acr )       <> p_rec_tabela NO-ERROR.
        IF AVAIL b_lote_liquidac_acr THEN
            ASSIGN p_log_refer_uni = NO.
    END.

    IF p_cod_table = 'cobr_especial_acr' THEN DO:
        FIND FIRST b_cobr_especial_acr NO-LOCK USE-INDEX cbrspclc_id
             WHERE b_cobr_especial_acr.cod_estab = p_cod_estab
               AND b_cobr_especial_acr.cod_refer = p_cod_refer
               AND RECID( b_cobr_especial_acr ) <> p_rec_tabela NO-ERROR.
        IF AVAIL b_cobr_especial_acr THEN
            ASSIGN p_log_refer_uni = NO.
    END.

    IF p_log_refer_uni = YES THEN DO:
        FIND FIRST b_renegoc_acr NO-LOCK
             WHERE b_renegoc_acr.cod_estab = p_cod_estab
               AND b_renegoc_acr.cod_refer = p_cod_refer
               AND RECID(b_renegoc_acr)   <> p_rec_tabela NO-ERROR.
        IF AVAIL b_renegoc_acr THEN
            ASSIGN p_log_refer_uni = NO.
        ELSE DO:
            FIND FIRST b_movto_tit_acr NO-LOCK USE-INDEX mvtttcr_refer
                 WHERE b_movto_tit_acr.cod_estab = p_cod_estab
                   AND b_movto_tit_acr.cod_refer = p_cod_refer
                   AND RECID(b_movto_tit_acr)   <> p_rec_tabela NO-ERROR.
            IF AVAIL b_movto_tit_acr THEN
                ASSIGN p_log_refer_uni = NO.
        END.
    END.

END PROCEDURE. /* pi_verifica_refer_unica_acr */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE send-records W-Win  _ADM-SEND-RECORDS
PROCEDURE send-records :
/*------------------------------------------------------------------------------
  Purpose:     Send record ROWID's for all tables used by
               this file.
  Parameters:  see template/snd-head.i
------------------------------------------------------------------------------*/

  /* Define variables needed by this internal procedure.               */
  {src/adm/template/snd-head.i}

  /* For each requested table, put it's ROWID in the output list.      */
  {src/adm/template/snd-list.i "tt-convenio"}

  /* Deal with any unexpected table requests before closing.           */
  {src/adm/template/snd-end.i}

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE state-changed W-Win 
PROCEDURE state-changed :
/* -----------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
-------------------------------------------------------------*/
  DEFINE INPUT PARAMETER p-issuer-hdl AS HANDLE NO-UNDO.
  DEFINE INPUT PARAMETER p-state AS CHARACTER NO-UNDO.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

