&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
*/
&Scoped-define WINDOW-NAME C-Win
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS C-Win 
/*------------------------------------------------------------------------

  File: 

  Description: 

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/


CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/******************************************************************/
{system/Error.i}

/* Local Variable Definitions ---                                       */
{cstp/csap004.i}

/* Local Variable Definitions ---                                       */
def var v-estab-ini   AS CHARACTER  NO-UNDO.
def var v-estab-fim   AS CHARACTER INITIAL "ZZZZZZzzzzzzzzzzzzzzzzzzzzzzzzzzz" NO-UNDO.
def var v-espec-ini   AS CHARACTER  NO-UNDO.
def var v-espec-fim   AS CHARACTER INITIAL "ZZZZZZzzzzzzzzzzzzzzzzzzzzzzzzzzz"  NO-UNDO.
def var v-titulo-ini  AS CHARACTER  NO-UNDO.
def var v-titulo-fim  AS CHARACTER INITIAL "ZZZZZZzzzzzzzzzzzzzzzzzzzzzzzzzzz" NO-UNDO.
def var v-parcela-ini AS CHARACTER  NO-UNDO.
def var v-parcela-fim AS CHARACTER INITIAL "ZZZZZZzzzzzzzzzzzzzzzzzzzzzzzzzzz" NO-UNDO.
def var v-vencto-ini  AS DATE       INITIAL 01/01/1900 NO-UNDO.
def var v-vencto-fim  AS DATE       INITIAL 12/31/9999 NO-UNDO.
def var v-emissao-ini AS DATE       INITIAL 01/01/1900 NO-UNDO.
def var v-emissao-fim AS DATE       INITIAL 12/31/9999 NO-UNDO.
def var v-portad-ini  AS CHARACTER  NO-UNDO.
def var v-portad-fim  AS CHARACTER INITIAL "ZZZZZZzzzzzzzzzzzzzzzzzzzzzzzzzzz" NO-UNDO.
def var v-fornec-ini  AS INTEGER  NO-UNDO.
def var v-fornec-fim  AS INTEGER  INITIAL "999999" NO-UNDO.

DEF VAR v-vl-destino  LIKE tit_ap.val_sdo_tit_ap NO-UNDO.

define variable tipoClassificacao as character no-undo.
define variable portador like portador.cod_portador no-undo.
define variable carteira like cart_bcia.cod_cart_bcia no-undo.
define variable i-titulos as integer   no-undo.
define variable d-totaltit like tit_ap.val_origin_tit_ap  no-undo.

define new shared variable v_rec_tit_ap as recid    no-undo.

define variable oldClassifica as integer   no-undo.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Window
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME f-440
&Scoped-define BROWSE-NAME brExcecao

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES ttExcecao ttPortador ttTitulo

/* Definitions for BROWSE brExcecao                                     */
&Scoped-define FIELDS-IN-QUERY-brExcecao ttExcecao.cod_estab ttExcecao.cdn_fornecedor ttExcecao.cod_espec_docto ttExcecao.cod_ser_docto ttExcecao.cod_tit_ap ttExcecao.cod_parcela   
&Scoped-define ENABLED-FIELDS-IN-QUERY-brExcecao   
&Scoped-define SELF-NAME brExcecao
&Scoped-define QUERY-STRING-brExcecao for each ttExcecao use-index pk_portador     where ttExcecao.cod-portador = portador       and ttExcecao.cod-cart-bcia = carteira     by ttExcecao.re-tit-ap     by ttExcecao.cod_estab     by ttExcecao.cdn_fornecedor     by ttExcecao.cod_espec_docto     by ttExcecao.cod_ser_docto     by ttExcecao.cod_tit_ap     by ttExcecao.cod_parcela
&Scoped-define OPEN-QUERY-brExcecao OPEN QUERY {&SELF-NAME} for each ttExcecao use-index pk_portador     where ttExcecao.cod-portador = portador       and ttExcecao.cod-cart-bcia = carteira     by ttExcecao.re-tit-ap     by ttExcecao.cod_estab     by ttExcecao.cdn_fornecedor     by ttExcecao.cod_espec_docto     by ttExcecao.cod_ser_docto     by ttExcecao.cod_tit_ap     by ttExcecao.cod_parcela.
&Scoped-define TABLES-IN-QUERY-brExcecao ttExcecao
&Scoped-define FIRST-TABLE-IN-QUERY-brExcecao ttExcecao


/* Definitions for BROWSE brPortador                                    */
&Scoped-define FIELDS-IN-QUERY-brPortador ttPortador.cod-portador ttPortador.cod-cart-bcia ttPortador.vl-maximo ttPortador.cod-forma-pagto-mesmo ttPortador.cod-forma-pagto-outro getClassificacao(ttPortador.classificacao) @ tipoClassificacao   
&Scoped-define ENABLED-FIELDS-IN-QUERY-brPortador   
&Scoped-define SELF-NAME brPortador
&Scoped-define QUERY-STRING-brPortador FOR EACH ttPortador     BY ttPortador.cod-portador
&Scoped-define OPEN-QUERY-brPortador OPEN QUERY {&SELF-NAME} FOR EACH ttPortador     BY ttPortador.cod-portador.
&Scoped-define TABLES-IN-QUERY-brPortador ttPortador
&Scoped-define FIRST-TABLE-IN-QUERY-brPortador ttPortador


/* Definitions for BROWSE brTitulo                                      */
&Scoped-define FIELDS-IN-QUERY-brTitulo ttTitulo.cod_estab ttTitulo.cdn_fornecedor ttTitulo.cod_espec_docto ttTitulo.cod_ser_docto ttTitulo.cod_tit_ap ttTitulo.cod_parcela ttTitulo.cod_portador ttTitulo.dat_vencto_tit_ap ttTitulo.dat_transacao ttTitulo.valorPagamento   
&Scoped-define ENABLED-FIELDS-IN-QUERY-brTitulo   
&Scoped-define SELF-NAME brTitulo
&Scoped-define QUERY-STRING-brTitulo for each ttTitulo use-index pk_portador     where ttTitulo.cod-portador = portador       and ttTitulo.cod-cart-bcia = carteira     by ttTitulo.cdn_fornecedor     by ttTitulo.cod_tit_ap
&Scoped-define OPEN-QUERY-brTitulo OPEN QUERY {&SELF-NAME} for each ttTitulo use-index pk_portador     where ttTitulo.cod-portador = portador       and ttTitulo.cod-cart-bcia = carteira     by ttTitulo.cdn_fornecedor     by ttTitulo.cod_tit_ap.
&Scoped-define TABLES-IN-QUERY-brTitulo ttTitulo
&Scoped-define FIRST-TABLE-IN-QUERY-brTitulo ttTitulo


/* Definitions for FRAME frExcecao                                      */
&Scoped-define OPEN-BROWSERS-IN-QUERY-frExcecao ~
    ~{&OPEN-QUERY-brExcecao}

/* Definitions for FRAME frPortador                                     */
&Scoped-define OPEN-BROWSERS-IN-QUERY-frPortador ~
    ~{&OPEN-QUERY-brPortador}

/* Definitions for FRAME frTitulo                                       */
&Scoped-define OPEN-BROWSERS-IN-QUERY-frTitulo ~
    ~{&OPEN-QUERY-brTitulo}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS btFechar btExecuta RECT-2 
&Scoped-Define DISPLAYED-OBJECTS v-qt-titulos-total v-vl-titulos-total ~
v-qt-titulos-falta v-vl-titulos-falta 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD getClassificacao C-Win 
FUNCTION getClassificacao RETURNS CHARACTER
  ( input classificacao as integer )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR C-Win AS WIDGET-HANDLE NO-UNDO.

/* Definitions of the field level widgets                               */
DEFINE BUTTON btExecuta 
     LABEL "&Executar" 
     SIZE 11.14 BY 1 TOOLTIP "Executar destinaá∆o e impress∆o relat¢rio"
     FONT 1.

DEFINE BUTTON btFechar 
     LABEL "&Fechar" 
     SIZE 11.14 BY 1 TOOLTIP "Fechar"
     FONT 1.

DEFINE VARIABLE v-qt-titulos-falta AS INTEGER FORMAT ">,>>9":U INITIAL 0 
     LABEL "QTDE" 
     VIEW-AS FILL-IN 
     SIZE 8.86 BY .88
     BGCOLOR 12  NO-UNDO.

DEFINE VARIABLE v-qt-titulos-total AS INTEGER FORMAT ">,>>9":U INITIAL 0 
     LABEL "QTDE" 
     VIEW-AS FILL-IN 
     SIZE 8.86 BY .88
     BGCOLOR 10  NO-UNDO.

DEFINE VARIABLE v-vl-titulos-falta AS DECIMAL FORMAT "->>>,>>>,>>9.99":U INITIAL 0 
     LABEL "VALOR" 
     VIEW-AS FILL-IN 
     SIZE 12 BY .88
     BGCOLOR 12  NO-UNDO.

DEFINE VARIABLE v-vl-titulos-total AS DECIMAL FORMAT "->>>,>>>,>>9.99":U INITIAL 0 
     LABEL "VALOR" 
     VIEW-AS FILL-IN 
     SIZE 12 BY .88
     BGCOLOR 10  NO-UNDO.

DEFINE RECTANGLE RECT-2
     EDGE-PIXELS 1 GRAPHIC-EDGE    
     SIZE 101.43 BY 1.5
     BGCOLOR 18 FGCOLOR 19 .

DEFINE BUTTON btExcluiExcecao 
     IMAGE-UP FILE "image\im-era1":U
     LABEL "del" 
     SIZE 4.29 BY 1.13 TOOLTIP "Exclui exceá‰es selecionadas".

DEFINE BUTTON btIncluiExcecao 
     IMAGE-UP FILE "image/im-add.bmp":U
     LABEL "mod" 
     SIZE 4.29 BY 1.13 TOOLTIP "Inclui nova exceá∆o de fornecedor".

DEFINE BUTTON btExcluiPortador 
     IMAGE-UP FILE "image\im-era1":U
     LABEL "del" 
     SIZE 4.29 BY 1.13 TOOLTIP "Exclui portador selecionado".

DEFINE BUTTON btIncluiPortador 
     IMAGE-UP FILE "image/im-add.bmp":U
     LABEL "mod" 
     SIZE 4.29 BY 1.13 TOOLTIP "Inclui novo portador".

DEFINE BUTTON btModificaPortador 
     IMAGE-UP FILE "image\im-mod":U
     LABEL "mod" 
     SIZE 4.29 BY 1.13 TOOLTIP "Modifica portador selecionado".

DEFINE VARIABLE v-val-dest AS DECIMAL FORMAT "->>>,>>>,>>9.99" INITIAL 0 
     LABEL "Valor total destinaá∆o" 
     VIEW-AS FILL-IN 
     SIZE 12 BY .88 TOOLTIP "Valor total para destinaá∆o" NO-UNDO.

DEFINE BUTTON btFaixa 
     IMAGE-UP FILE "image/im-ran.bmp":U
     LABEL "" 
     SIZE 4.29 BY 1.13 TOOLTIP "Faixa para seleá∆o dos t°tulos".

DEFINE BUTTON btRecalcular 
     IMAGE-UP FILE "image/im-chck1.bmp":U
     LABEL "" 
     SIZE 4.29 BY 1.13 TOOLTIP "Recalcular t°tulos para o portador selecionado acima".

DEFINE BUTTON btUpToExcecao 
     IMAGE-UP FILE "image/im-up2.bmp":U
     LABEL "bt-up" 
     SIZE 4.29 BY 1.13 TOOLTIP "Envia t°tulos selecionados para exceá∆o".

DEFINE BUTTON BUTTON-1 
     IMAGE-UP FILE "image/im-det.bmp":U
     IMAGE-INSENSITIVE FILE "image/ii-det.bmp":U
     LABEL "Button 1" 
     SIZE 4.29 BY 1.13.

DEFINE VARIABLE v-qt-titulos AS INTEGER FORMAT ">,>>9":U INITIAL 0 
     LABEL "Quantidade" 
     VIEW-AS FILL-IN 
     SIZE 8.86 BY .88 NO-UNDO.

DEFINE VARIABLE v-val-titulos AS DECIMAL FORMAT "->>>,>>>,>>9.99":U INITIAL 0 
     LABEL "Valor" 
     VIEW-AS FILL-IN 
     SIZE 12 BY .88 NO-UNDO.

DEFINE VARIABLE titClassificacao AS INTEGER 
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS 
          "Estabelecimento", 1,
"Fornecedor", 2,
"T°tulo", 3,
"Portador", 4,
"Vencimento", 5,
"Transacao", 6,
"Valor Pagamento", 7
     SIZE 93 BY .88 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY brExcecao FOR 
      ttExcecao SCROLLING.

DEFINE QUERY brPortador FOR 
      ttPortador SCROLLING.

DEFINE QUERY brTitulo FOR 
      ttTitulo SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE brExcecao
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS brExcecao C-Win _FREEFORM
  QUERY brExcecao DISPLAY
      ttExcecao.cod_estab 
    ttExcecao.cdn_fornecedor
    ttExcecao.cod_espec_docto
    ttExcecao.cod_ser_docto
    ttExcecao.cod_tit_ap
    ttExcecao.cod_parcela
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS MULTIPLE SIZE 43 BY 5.25
         BGCOLOR 15 FONT 1 ROW-HEIGHT-CHARS .5.

DEFINE BROWSE brPortador
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS brPortador C-Win _FREEFORM
  QUERY brPortador DISPLAY
      ttPortador.cod-portador 
    ttPortador.cod-cart-bcia
    ttPortador.vl-maximo format ">>>,>>>,>>9.99"
    ttPortador.cod-forma-pagto-mesmo
    ttPortador.cod-forma-pagto-outro
    getClassificacao(ttPortador.classificacao) @ tipoClassificacao column-label 'Classificaá∆o'
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 51.43 BY 5.21
         BGCOLOR 15 FONT 1 ROW-HEIGHT-CHARS .5.

DEFINE BROWSE brTitulo
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS brTitulo C-Win _FREEFORM
  QUERY brTitulo DISPLAY
      ttTitulo.cod_estab 
    ttTitulo.cdn_fornecedor
    ttTitulo.cod_espec_docto
    ttTitulo.cod_ser_docto
    ttTitulo.cod_tit_ap width 10
    ttTitulo.cod_parcela
    ttTitulo.cod_portador
    ttTitulo.dat_vencto_tit_ap
    ttTitulo.dat_transacao
    ttTitulo.valorPagamento
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS MULTIPLE SIZE 93.43 BY 7.5
         BGCOLOR 15 FONT 1 ROW-HEIGHT-CHARS .46.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME f-440
     btFechar AT ROW 21.04 COL 90.86
     btExecuta AT ROW 21.04 COL 3.14
     v-qt-titulos-total AT ROW 21.13 COL 19 COLON-ALIGNED WIDGET-ID 6
     v-vl-titulos-total AT ROW 21.13 COL 35.29 COLON-ALIGNED WIDGET-ID 4
     v-qt-titulos-falta AT ROW 21.13 COL 58.43 COLON-ALIGNED WIDGET-ID 8
     v-vl-titulos-falta AT ROW 21.13 COL 74.72 COLON-ALIGNED WIDGET-ID 10
     RECT-2 AT ROW 20.79 COL 1.57
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY NO-HELP 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 105 BY 22
         BGCOLOR 17 FONT 1.

DEFINE FRAME frExcecao
     btIncluiExcecao AT ROW 1.25 COL 3 WIDGET-ID 12
     btExcluiExcecao AT ROW 1.25 COL 8 WIDGET-ID 10
     brExcecao AT ROW 2.5 COL 3 WIDGET-ID 500
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 57 ROW 1.25
         SIZE 46 BY 8
         BGCOLOR 17 FONT 1
         TITLE "Exceá‰es" WIDGET-ID 300.

DEFINE FRAME frPortador
     btIncluiPortador AT ROW 1.25 COL 3 WIDGET-ID 4
     btModificaPortador AT ROW 1.25 COL 8 WIDGET-ID 6
     btExcluiPortador AT ROW 1.25 COL 13 WIDGET-ID 2
     v-val-dest AT ROW 1.42 COL 40 COLON-ALIGNED HELP
          "Valor M†ximo para Destinaá∆o" WIDGET-ID 12
     brPortador AT ROW 2.54 COL 2.57 WIDGET-ID 200
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1.57 ROW 1.25
         SIZE 54.43 BY 8
         BGCOLOR 17 FONT 1
         TITLE "Portadores" WIDGET-ID 100.

DEFINE FRAME frTitulo
     titClassificacao AT ROW 1.25 COL 3 NO-LABEL WIDGET-ID 16
     btUpToExcecao AT ROW 2.21 COL 97.14 WIDGET-ID 6
     brTitulo AT ROW 2.25 COL 2.57 WIDGET-ID 600
     BUTTON-1 AT ROW 5.92 COL 97.14 WIDGET-ID 14
     btFaixa AT ROW 7.13 COL 97.14 WIDGET-ID 8
     btRecalcular AT ROW 8.38 COL 97.14 WIDGET-ID 10
     v-qt-titulos AT ROW 9.92 COL 67.29 COLON-ALIGNED WIDGET-ID 2
     v-val-titulos AT ROW 9.92 COL 81.86 COLON-ALIGNED WIDGET-ID 4
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1.57 ROW 9.5
         SIZE 101.43 BY 11
         BGCOLOR 17 FONT 1
         TITLE "T°tulos" WIDGET-ID 400.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Window
   Allow: Basic,Browse,DB-Fields,Window,Query
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
IF SESSION:DISPLAY-TYPE = "GUI":U THEN
  CREATE WINDOW C-Win ASSIGN
         HIDDEN             = YES
         TITLE              = "Destinaá∆o de Pagamentos"
         COLUMN             = 1
         ROW                = 3.67
         HEIGHT             = 21.5
         WIDTH              = 102.57
         MAX-HEIGHT         = 30.21
         MAX-WIDTH          = 182.86
         VIRTUAL-HEIGHT     = 30.21
         VIRTUAL-WIDTH      = 182.86
         RESIZE             = no
         SCROLL-BARS        = no
         STATUS-AREA        = yes
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
/* REPARENT FRAME */
ASSIGN FRAME frExcecao:FRAME = FRAME f-440:HANDLE
       FRAME frPortador:FRAME = FRAME f-440:HANDLE
       FRAME frTitulo:FRAME = FRAME f-440:HANDLE.

/* SETTINGS FOR FRAME f-440
   FRAME-NAME Custom                                                    */
/* SETTINGS FOR FILL-IN v-qt-titulos-falta IN FRAME f-440
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN v-qt-titulos-total IN FRAME f-440
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN v-vl-titulos-falta IN FRAME f-440
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN v-vl-titulos-total IN FRAME f-440
   NO-ENABLE                                                            */
/* SETTINGS FOR FRAME frExcecao
                                                                        */
/* BROWSE-TAB brExcecao btExcluiExcecao frExcecao */
ASSIGN 
       brExcecao:COLUMN-RESIZABLE IN FRAME frExcecao       = TRUE
       brExcecao:COLUMN-MOVABLE IN FRAME frExcecao         = TRUE.

/* SETTINGS FOR FRAME frPortador
                                                                        */
/* BROWSE-TAB brPortador v-val-dest frPortador */
ASSIGN 
       brPortador:COLUMN-RESIZABLE IN FRAME frPortador       = TRUE
       brPortador:COLUMN-MOVABLE IN FRAME frPortador         = TRUE.

/* SETTINGS FOR FILL-IN v-val-dest IN FRAME frPortador
   NO-ENABLE                                                            */
/* SETTINGS FOR FRAME frTitulo
                                                                        */
/* BROWSE-TAB brTitulo btUpToExcecao frTitulo */
ASSIGN 
       brTitulo:COLUMN-RESIZABLE IN FRAME frTitulo       = TRUE
       brTitulo:COLUMN-MOVABLE IN FRAME frTitulo         = TRUE.

/* SETTINGS FOR FILL-IN v-qt-titulos IN FRAME frTitulo
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN v-val-titulos IN FRAME frTitulo
   NO-ENABLE                                                            */
IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(C-Win)
THEN C-Win:HIDDEN = no.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE brExcecao
/* Query rebuild information for BROWSE brExcecao
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} for each ttExcecao use-index pk_portador
    where ttExcecao.cod-portador = portador
      and ttExcecao.cod-cart-bcia = carteira
    by ttExcecao.re-tit-ap
    by ttExcecao.cod_estab
    by ttExcecao.cdn_fornecedor
    by ttExcecao.cod_espec_docto
    by ttExcecao.cod_ser_docto
    by ttExcecao.cod_tit_ap
    by ttExcecao.cod_parcela
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE brExcecao */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE brPortador
/* Query rebuild information for BROWSE brPortador
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH ttPortador
    BY ttPortador.cod-portador.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE brPortador */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE brTitulo
/* Query rebuild information for BROWSE brTitulo
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} for each ttTitulo use-index pk_portador
    where ttTitulo.cod-portador = portador
      and ttTitulo.cod-cart-bcia = carteira
    by ttTitulo.cdn_fornecedor
    by ttTitulo.cod_tit_ap
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE brTitulo */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME C-Win
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL C-Win C-Win
ON END-ERROR OF C-Win /* Destinaá∆o de Pagamentos */
OR ENDKEY OF {&WINDOW-NAME} ANYWHERE DO:
  /* This case occurs when the user presses the "Esc" key.
     In a persistently run window, just ignore this.  If we did not, the
     application would exit. */
  IF THIS-PROCEDURE:PERSISTENT THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL C-Win C-Win
ON WINDOW-CLOSE OF C-Win /* Destinaá∆o de Pagamentos */
DO:
  /* This event will close the window and terminate the procedure.  */
  APPLY "CLOSE":U TO THIS-PROCEDURE.
  RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME brPortador
&Scoped-define FRAME-NAME frPortador
&Scoped-define SELF-NAME brPortador
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL brPortador C-Win
ON MOUSE-SELECT-CLICK OF brPortador IN FRAME frPortador
DO:
    if avail ttPortador then
        assign
            portador = ttPortador.cod-portador
            carteira = ttPortador.cod-cart-bcia.
    else
        assign
            portador = ''
            carteira = ''.

    {&OPEN-QUERY-brExcecao}

    assign
        v-qt-titulos = 0
        v-val-titulos = 0.

    for each ttTitulo use-index pk_portador
        where ttTitulo.cod-portador = portador
          and ttTitulo.cod-cart-bcia = carteira
        no-lock:
        assign 
            v-qt-titulos = v-qt-titulos + 1
            v-val-titulos = v-val-titulos + ttTitulo.valorPagamento.
    end.

    assign 
        v-qt-titulos:screen-value in frame frTitulo = string(v-qt-titulos)
        v-val-titulos:screen-value in frame frTitulo = string(v-val-titulos).

    {&OPEN-QUERY-brTitulo}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME frExcecao
&Scoped-define SELF-NAME btExcluiExcecao
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btExcluiExcecao C-Win
ON CHOOSE OF btExcluiExcecao IN FRAME frExcecao /* del */
DO:
    do {&try}:
        message 'Deseja excluir as exceá‰es selecionadas ?'
            view-as alert-box question buttons yes-no
            title "Mensagem" update doRecalcula as logical.

        if doRecalcula then do:
            run deleteExcecao.
        end.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME frPortador
&Scoped-define SELF-NAME btExcluiPortador
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btExcluiPortador C-Win
ON CHOOSE OF btExcluiPortador IN FRAME frPortador /* del */
DO:
    if avail ttPortador then do:
        message substitute('Confirma eliminaá∆o da destinaá∆o do portador "&1", modalidade "&2"?',
                ttPortador.cod-portador, ttPortador.cod-cart-bcia)
            view-as alert-box question buttons yes-no-cancel
            title "Mensagem" update doDelete as logical.

        if doDelete then do:
            for each ttExcecao use-index pk_portador
                where ttExcecao.cod-portador = ttPortador.cod-portador
                  and ttExcecao.cod-cart-bcia = ttPortador.cod-cart-bcia
                no-lock:
                delete ttExcecao.
            end.

            for each ttTitulo use-index pk_portador
                where ttTitulo.cod-portador = ttPortador.cod-portador
                  and ttTitulo.cod-cart-bcia = ttPortador.cod-cart-bcia
                no-lock:
                delete ttTitulo.
            end.

            delete ttPortador.

            {&OPEN-QUERY-brPortador}
            {&OPEN-QUERY-brTitulo}
            {&OPEN-QUERY-brExcecao}
        end.
    END.
    else 
        message 'Para efetuar a alteraá∆o Ç necess†rio selecionar um portador na tela!'
            VIEW-AS ALERT-BOX INFO BUTTONS OK.

    RUN calculateValorDestinacao.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME f-440
&Scoped-define SELF-NAME btExecuta
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btExecuta C-Win
ON CHOOSE OF btExecuta IN FRAME f-440 /* Executar */
DO:
    run executeDestinacao.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME frTitulo
&Scoped-define SELF-NAME btFaixa
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btFaixa C-Win
ON CHOOSE OF btFaixa IN FRAME frTitulo
DO:
    define variable doClear as logical   no-undo.

    if session:set-wait-state("general") then.
    run cstp/csap004a.w (input-output v-estab-ini,  
                         input-output v-estab-fim,  
                         input-output v-espec-ini,  
                         input-output v-espec-fim,  
                         input-output v-titulo-ini, 
                         input-output v-titulo-fim, 
                         input-output v-parcela-ini,
                         input-output v-parcela-fim,
                         input-output v-vencto-ini, 
                         input-output v-vencto-fim, 
                         input-output v-emissao-ini,
                         input-output v-emissao-fim,
                         input-output v-portad-ini, 
                         input-output v-portad-fim, 
                         input-output v-fornec-ini, 
                         input-output v-fornec-fim,
                         output doClear). 
    if session:set-wait-state("") then.

    if doClear then do:
        empty temp-table ttTitulo.

        {&OPEN-QUERY-brTitulo}
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME f-440
&Scoped-define SELF-NAME btFechar
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btFechar C-Win
ON CHOOSE OF btFechar IN FRAME f-440 /* Fechar */
DO:
    apply "close" to this-procedure. 
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME frExcecao
&Scoped-define SELF-NAME btIncluiExcecao
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btIncluiExcecao C-Win
ON CHOOSE OF btIncluiExcecao IN FRAME frExcecao /* mod */
DO:
    if avail ttPortador then do:
        run cstp/csap004d.w (input-output table ttExcecao, 
                ttPortador.cod-portador, ttPortador.cod-cart-bcia).
    
        {&OPEN-QUERY-brExcecao} 
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME frPortador
&Scoped-define SELF-NAME btIncluiPortador
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btIncluiPortador C-Win
ON CHOOSE OF btIncluiPortador IN FRAME frPortador /* mod */
DO:
    RUN cstp/csap004c.w (input-output table ttPortador, ?).

    close query brPortador.

    run calculateValorDestinacao.

    {&OPEN-QUERY-brPortador}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btModificaPortador
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btModificaPortador C-Win
ON CHOOSE OF btModificaPortador IN FRAME frPortador /* mod */
DO:
    IF AVAIL ttPortador THEN DO:
        RUN cstp/csap004c.w (input-output table ttPortador, ttPortador.cod-portador).

        close query brPortador.

        run calculateValorDestinacao.

        {&OPEN-QUERY-brPortador}
    END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME frTitulo
&Scoped-define SELF-NAME btRecalcular
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btRecalcular C-Win
ON CHOOSE OF btRecalcular IN FRAME frTitulo
DO:
    if avail ttPortador then do 
        {&try}:
        assign
            portador = ttPortador.cod-portador
            carteira = ttPortador.cod-cart-bcia.

        message 'Confirma o c†lculo dos t°tulos do ' skip
                substitute('portador "&1", modalidade "&2"?',
                ttPortador.cod-portador, ttPortador.cod-cart-bcia)
            view-as alert-box question buttons yes-no
            title "Mensagem" update doRecalcula as logical.

        if doRecalcula then do:

            if session:set-wait-state("general") then. /* mostra na tela a amputela */

            run loadTitulos.

            if session:set-wait-state("") then.

            run calculateTotais.
        end.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btUpToExcecao
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btUpToExcecao C-Win
ON CHOOSE OF btUpToExcecao IN FRAME frTitulo /* bt-up */
DO:
    do {&try}:
        message 'Deseja enviar os t°tulos selecionados para o grid de exceá‰es?'
            view-as alert-box question buttons yes-no
            title "Mensagem" update doRecalcula as logical.

        if doRecalcula then do:
            run createExcecaoTitulo.
        end.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME BUTTON-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BUTTON-1 C-Win
ON CHOOSE OF BUTTON-1 IN FRAME frTitulo /* Button 1 */
DO:
    if avail ttTitulo then do:
        find first tit_ap
            where tit_ap.cod_estab = ttTitulo.cod_estab
              and tit_ap.cdn_fornecedor = ttTitulo.cdn_fornecedor
              and tit_ap.cod_espec_docto = ttTitulo.cod_espec_docto
              and tit_ap.cod_ser_docto = ttTitulo.cod_ser_docto
              and tit_ap.cod_parcela = ttTitulo.cod_parcela
            no-lock no-error.

        if avail tit_ap then do:
            assign 
                v_rec_tit_ap = recid(tit_ap).

            run prgfin/apb/apb002ia.p.
        end.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME titClassificacao
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL titClassificacao C-Win
ON MOUSE-SELECT-CLICK OF titClassificacao IN FRAME frTitulo
DO:
    if oldClassifica = self:input-value then do:
        run classificaTituloDescendente.
        assign
            oldClassifica = self:input-value + 1.
    end.
    else do:
        run classificaTituloAscendente.
        assign
            oldClassifica = self:input-value.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME f-440
&Scoped-define BROWSE-NAME brExcecao
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
  RUN enable_UI.
  
  APPLY "entry" TO {&WINDOW-NAME}.

  IF NOT THIS-PROCEDURE:PERSISTENT THEN
    WAIT-FOR CLOSE OF THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE calculateTotais C-Win 
PROCEDURE calculateTotais :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    
    define variable qtTitulosTotal as integer no-undo.
    define variable vlTitulosTotal as decimal no-undo.
    
    do {&throws}:
        for each ttTitulo
            no-lock:
            assign
                qtTitulosTotal = qtTitulosTotal + 1
                vlTitulosTotal = vlTitulosTotal + ttTitulo.valorPagamento.
        end.
    
        assign 
            v-qt-titulos-total:screen-value in frame {&frame-name} = string(qtTitulosTotal)
            v-vl-titulos-total:screen-value in frame {&frame-name} = string(vlTitulosTotal).
    end.
    
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE calculateValorDestinacao C-Win 
PROCEDURE calculateValorDestinacao :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    assign 
        v-val-dest = 0.

    for each ttPortador
        no-lock:
        assign 
            v-val-dest = v-val-dest + ttPortador.vl-maximo.
    end.

    assign 
        v-val-dest:screen-value in frame frPortador = string(v-val-dest).

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE classificaTituloAscendente C-Win 
PROCEDURE classificaTituloAscendente :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    define variable tituloClassificacao as integer   no-undo.
    assign
        tituloClassificacao = input frame frTitulo titClassificacao.

    close query brTitulo.

    case tituloClassificacao:
        when 1 then
            open query brTitulo for each ttTitulo use-index pk_portador
            where ttTitulo.cod-portador = portador
              and ttTitulo.cod-cart-bcia = carteira
            by ttTitulo.cod_estab      
            by ttTitulo.cdn_fornecedor
            by ttTitulo.cod_tit_ap
            by ttTitulo.valorPagamento.
        when 2 then
            open query brTitulo for each ttTitulo use-index pk_portador
            where ttTitulo.cod-portador = portador
              and ttTitulo.cod-cart-bcia = carteira
            by ttTitulo.cdn_fornecedor 
            by ttTitulo.cod_tit_ap
            by ttTitulo.cod_parcela
            by ttTitulo.valorPagamento.
        when 3 then
            open query brTitulo for each ttTitulo use-index pk_portador
            where ttTitulo.cod-portador = portador
              and ttTitulo.cod-cart-bcia = carteira
            by ttTitulo.cod_tit_ap     
            by ttTitulo.cod_parcela
            by ttTitulo.valorPagamento.
        when 4 then
            open query brTitulo for each ttTitulo use-index pk_portador
            where ttTitulo.cod-portador = portador
              and ttTitulo.cod-cart-bcia = carteira
            by ttTitulo.cod_portador
            by ttTitulo.cdn_fornecedor 
            by ttTitulo.cod_tit_ap
            by ttTitulo.cod_parcela
            by ttTitulo.valorPagamento.
        when 5 then
            open query brTitulo for each ttTitulo use-index pk_portador
            where ttTitulo.cod-portador = portador
              and ttTitulo.cod-cart-bcia = carteira
            by ttTitulo.dat_vencto_tit_ap 
            by ttTitulo.cdn_fornecedor
            by ttTitulo.valorPagamento.
        when 6 then
            open query brTitulo for each ttTitulo use-index pk_portador
            where ttTitulo.cod-portador = portador
              and ttTitulo.cod-cart-bcia = carteira
            by ttTitulo.dat_transacao  
            by ttTitulo.cdn_fornecedor
            by ttTitulo.valorPagamento.
        when 7 then
            open query brTitulo for each ttTitulo use-index pk_portador
            where ttTitulo.cod-portador = portador
              and ttTitulo.cod-cart-bcia = carteira
            by ttTitulo.valorPagamento 
            by ttTitulo.cdn_fornecedor.
    end case.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE classificaTituloDescendente C-Win 
PROCEDURE classificaTituloDescendente :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    define variable tituloClassificacao as integer   no-undo.
    assign
        tituloClassificacao = input frame frTitulo titClassificacao.

    close query brTitulo.

    case tituloClassificacao:
        when 1 then
            open query brTitulo for each ttTitulo use-index pk_portador
            where ttTitulo.cod-portador = portador
              and ttTitulo.cod-cart-bcia = carteira
            by ttTitulo.cod_estab      descending
            by ttTitulo.cdn_fornecedor
            by ttTitulo.cod_tit_ap
            by ttTitulo.valorPagamento.
        when 2 then
            open query brTitulo for each ttTitulo use-index pk_portador
            where ttTitulo.cod-portador = portador
              and ttTitulo.cod-cart-bcia = carteira
            by ttTitulo.cdn_fornecedor descending
            by ttTitulo.cod_tit_ap
            by ttTitulo.cod_parcela
            by ttTitulo.valorPagamento.
        when 3 then
            open query brTitulo for each ttTitulo use-index pk_portador
            where ttTitulo.cod-portador = portador
              and ttTitulo.cod-cart-bcia = carteira
            by ttTitulo.cod_tit_ap     descending
            by ttTitulo.cod_parcela
            by ttTitulo.valorPagamento.
        when 4 then
            open query brTitulo for each ttTitulo use-index pk_portador
            where ttTitulo.cod-portador = portador
              and ttTitulo.cod-cart-bcia = carteira
            by ttTitulo.cod_portador
            by ttTitulo.cdn_fornecedor descending
            by ttTitulo.cod_tit_ap
            by ttTitulo.cod_parcela
            by ttTitulo.valorPagamento.
        when 5 then
            open query brTitulo for each ttTitulo use-index pk_portador
            where ttTitulo.cod-portador = portador
              and ttTitulo.cod-cart-bcia = carteira
            by ttTitulo.dat_vencto_tit_ap descending
            by ttTitulo.cdn_fornecedor
            by ttTitulo.valorPagamento.
        when 6 then
            open query brTitulo for each ttTitulo use-index pk_portador
            where ttTitulo.cod-portador = portador
              and ttTitulo.cod-cart-bcia = carteira
            by ttTitulo.dat_transacao  descending
            by ttTitulo.cdn_fornecedor
            by ttTitulo.valorPagamento.
        when 7 then
            open query brTitulo for each ttTitulo use-index pk_portador
            where ttTitulo.cod-portador = portador
              and ttTitulo.cod-cart-bcia = carteira
            by ttTitulo.valorPagamento descending
            by ttTitulo.cdn_fornecedor.
    end case.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE createExcecaoTitulo C-Win 
PROCEDURE createExcecaoTitulo :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    
    define variable i as integer   no-undo.
    
    do {&throws}:
        do i = 1 to brTitulo:num-selected-rows in frame frTitulo:
            brTitulo:fetch-selected-row(i) in frame frTitulo.

            create ttExcecao.
            buffer-copy ttTitulo to ttExcecao.
        end.

        {&OPEN-QUERY-brExcecao}
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE deleteExcecao C-Win 
PROCEDURE deleteExcecao :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    do {&throws}:
        define variable i as integer   no-undo.
    
        do {&throws}:
            do i = 1 to brExcecao:num-selected-rows in frame frExcecao:
                brExcecao:fetch-selected-row(i) in frame frExcecao.
    
                delete ttExcecao.
            end.
    
            {&OPEN-QUERY-brExcecao}
        end.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

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
  DISPLAY v-qt-titulos-total v-vl-titulos-total v-qt-titulos-falta 
          v-vl-titulos-falta 
      WITH FRAME f-440 IN WINDOW C-Win.
  ENABLE btFechar btExecuta RECT-2 
      WITH FRAME f-440 IN WINDOW C-Win.
  {&OPEN-BROWSERS-IN-QUERY-f-440}
  DISPLAY v-val-dest 
      WITH FRAME frPortador IN WINDOW C-Win.
  ENABLE btIncluiPortador btModificaPortador btExcluiPortador brPortador 
      WITH FRAME frPortador IN WINDOW C-Win.
  {&OPEN-BROWSERS-IN-QUERY-frPortador}
  ENABLE btIncluiExcecao btExcluiExcecao brExcecao 
      WITH FRAME frExcecao IN WINDOW C-Win.
  {&OPEN-BROWSERS-IN-QUERY-frExcecao}
  DISPLAY titClassificacao v-qt-titulos v-val-titulos 
      WITH FRAME frTitulo IN WINDOW C-Win.
  ENABLE titClassificacao btUpToExcecao brTitulo BUTTON-1 btFaixa btRecalcular 
      WITH FRAME frTitulo IN WINDOW C-Win.
  {&OPEN-BROWSERS-IN-QUERY-frTitulo}
  VIEW C-Win.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE executeDestinacao C-Win 
PROCEDURE executeDestinacao :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    do {&try}:
        assign 
            current-window:sensitive = no.

        run cstp/csap004b.w (input table ttTitulo,
                             input v-estab-ini,  
                             input v-estab-fim,  
                             input v-espec-ini,  
                             input v-espec-fim,  
                             input v-titulo-ini, 
                             input v-titulo-fim, 
                             input v-parcela-ini,
                             input v-parcela-fim,
                             input v-vencto-ini, 
                             input v-vencto-fim, 
                             input v-emissao-ini,
                             input v-emissao-fim,
                             input v-portad-ini, 
                             input v-portad-fim, 
                             input v-fornec-ini, 
                             input v-fornec-fim,
                             input table ttPortador).
    end.
    assign 
        current-window:sensitive = yes.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE loadTitulos C-Win 
PROCEDURE loadTitulos :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    do {&throws}:
        assign
            i-titulos = 0
            d-totaltit = 0
            v-qt-titulos = 0
            v-val-titulos = 0
            ttPortador.qt-titulo = 0
            ttPortador.vl-destinado = 0.

        for each ttTitulo
            where ttTitulo.cod-portador = portador
              and ttTitulo.cod-cart-bcia = carteira
            no-lock:
            delete ttTitulo.
        end.

        if ttPortador.classificacao = 1 then
            run loadTitulosPorValor.
        else
            run loadTitulosPorQuantidade.

        assign 
            v-qt-titulos:screen-value in frame frTitulo = string(v-qt-titulos)
            v-val-titulos:screen-value in frame frTitulo = string(v-val-titulos).

        assign 
            v-qt-titulos-falta:screen-value in frame {&frame-name} = string(i-titulos)
            v-vl-titulos-falta:screen-value in frame {&frame-name} = string(d-totaltit).

        {&OPEN-QUERY-brTitulo}
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE loadTitulosPorQuantidade C-Win 
PROCEDURE loadTitulosPorQuantidade :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    define variable doNext as logical   no-undo.
    
    do {&throws}:
        for each tit_ap use-index titap_dat_prev_pagto
            where tit_ap.cod_estab           >= v-estab-ini  
              and tit_ap.cod_estab           <= v-estab-fim
              and tit_ap.cod_espec_docto     >= v-espec-ini
              and tit_ap.cod_espec_docto     <= v-espec-fim
              and tit_ap.dat_prev_pagto      >= v-vencto-ini - 10
              and tit_ap.dat_vencto_tit_ap   >= v-vencto-ini
              and tit_ap.dat_vencto_tit_ap   <= v-vencto-fim 
              and tit_ap.dat_liquidac_tit_ap  = 12/31/9999
              and tit_ap.cod_empresa          = v_cod_empres_usuar
            no-lock
            by tit_ap.val_sdo_tit_ap
            {&throws}:
    
            run validateTitulo(output doNext).
            if doNext then
                next.

            run markTitulo.
        end.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE loadTitulosPorValor C-Win 
PROCEDURE loadTitulosPorValor :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    define variable doNext as logical   no-undo.
    
    do {&throws}:
        for each tit_ap use-index titap_dat_prev_pagto
            where tit_ap.cod_estab           >= v-estab-ini  
              and tit_ap.cod_estab           <= v-estab-fim
              and tit_ap.cod_espec_docto     >= v-espec-ini
              and tit_ap.cod_espec_docto     <= v-espec-fim
              and tit_ap.dat_prev_pagto      >= v-vencto-ini - 10
              and tit_ap.dat_vencto_tit_ap   >= v-vencto-ini
              and tit_ap.dat_vencto_tit_ap   <= v-vencto-fim 
              and tit_ap.dat_liquidac_tit_ap  = 12/31/9999
              and tit_ap.cod_empresa          = v_cod_empres_usuar
            no-lock
            by tit_ap.val_sdo_tit_ap descending
            {&throws}:
    
            run validateTitulo(output doNext).
            if doNext then
                next.

            run markTitulo.
        end.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE markTitulo C-Win 
PROCEDURE markTitulo :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    define variable valorPagamento like tit_ap.val_sdo_tit_ap   no-undo.

    do {&throws}:
        assign 
            valorPagamento = tit_ap.val_sdo_tit_ap.

        if tit_ap.dat_desconto >= today then
            assign 
                valorPagamento = valorPagamento - tit_ap.val_desconto.
        
        if ttPortador.vl-maximo >= (ttPortador.vl-destinado + valorPagamento) and
            not can-find(first ttExcecao
                where ttExcecao.re-tit-ap = recid(tit_ap)) and
            not can-find(first ttExcecao
                where ttExcecao.cdn_fornecedor = tit_ap.cdn_fornecedor) then do:

            assign 
                ttPortador.qt-titulo = ttPortador.qt-titulo + 1
                ttPortador.vl-destinado = ttPortador.vl-destinado + valorPagamento.

            create ttTitulo.
            assign 
                ttTitulo.cod-portador      = ttPortador.cod-portador
                ttTitulo.cod-cart-bcia     = ttPortador.cod-cart-bcia
                ttTitulo.cod_estab         = tit_ap.cod_estab      
                ttTitulo.cdn_fornecedor    = tit_ap.cdn_fornecedor 
                ttTitulo.cod_espec_docto   = tit_ap.cod_espec_docto
                ttTitulo.cod_ser_docto     = tit_ap.cod_ser_docto  
                ttTitulo.cod_tit_ap        = tit_ap.cod_tit_ap     
                ttTitulo.cod_parcela       = tit_ap.cod_parcela
                ttTitulo.valorPagamento    = valorPagamento
                ttTitulo.cod_portador      = tit_ap.cod_portador     
                ttTitulo.dat_vencto_tit_ap = tit_ap.dat_vencto_tit_ap
                ttTitulo.dat_transacao     = tit_ap.dat_transacao    
                ttTitulo.re-tit-ap         = recid(tit_ap).

            assign 
                v-qt-titulos = v-qt-titulos + 1
                v-val-titulos = v-val-titulos + valorPagamento.
        end.
        else do:
            assign 
                i-titulos  = i-titulos + 1
                d-totaltit = d-totaltit + valorPagamento.
        end.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi_message C-Win 
PROCEDURE pi_message :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
def input param c_action    as char    no-undo.
def input param i_msg       as integer no-undo.
def input param c_param     as char    no-undo.

def var c_prg_msg           as char    no-undo.

assign c_prg_msg = "messages/"
                 + string(trunc(i_msg / 1000,0),"99")
                 + "/msg"
                 + string(i_msg, "99999").

if search(c_prg_msg + ".r") = ? and search(c_prg_msg + ".p") = ? then do:
    message "Mensagem nr. " i_msg "!!!" skip
            "Programa Mensagem" c_prg_msg "n∆o encontrado."
            view-as alert-box error.
    return error.
end.

run value(c_prg_msg + ".p") (input c_action, input c_param).
return return-value.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE validateTitulo C-Win 
PROCEDURE validateTitulo :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define output parameter doNext as logical initial false no-undo.

    do {&throws}:
        if tit_ap.ind_tip_espec_docto    <> "normal"      or
            tit_ap.cdn_fornecedor         < v-fornec-ini  or
            tit_ap.cdn_fornecedor         > v-fornec-fim  or
            tit_ap.cod_tit_ap             < v-titulo-ini  or
            tit_ap.cod_tit_ap             > v-titulo-fim  or
            tit_ap.cod_parcela            < v-parcela-ini or
            tit_ap.cod_parcela            > v-parcela-fim or
            tit_ap.val_sdo_tit_ap         <= 0            or
            tit_ap.cb4_tit_ap_bco_cobdor  = ''            or
            tit_ap.dat_emis_docto         < v-emissao-ini or
            tit_ap.dat_emis_docto         > v-emissao-fim or
            tit_ap.cod_portador           < v-portad-ini  or
            tit_ap.cod_portador           > v-portad-fim  or
            can-find(first item_bord_ap
                        where item_bord_ap.cod_estab           = tit_ap.cod_estab
                          and item_bord_ap.cod_espec_docto     = tit_ap.cod_espec_docto
                          and item_bord_ap.cod_ser_docto       = tit_ap.cod_ser_docto
                          and item_bord_ap.cdn_fornecedor      = tit_ap.cdn_fornecedor
                          and item_bord_ap.cod_tit_ap          = tit_ap.cod_tit_ap
                          and item_bord_ap.cod_parcela         = tit_ap.cod_parcela) or
            can-find(first item_lote_pagto
                        where item_lote_pagto.cod_estab        = tit_ap.cod_estab
                          and item_lote_pagto.cod_espec_docto  = tit_ap.cod_espec_docto
                          and item_lote_pagto.cod_ser_docto    = tit_ap.cod_ser_docto
                          and item_lote_pagto.cdn_fornecedor   = tit_ap.cdn_fornecedor
                          and item_lote_pagto.cod_tit_ap       = tit_ap.cod_tit_ap
                          and item_lote_pagto.cod_parcela      = tit_ap.cod_parcela) or
            can-find(first ttTitulo
                where ttTitulo.re-tit-ap = recid(tit_ap)) then
            assign
                doNext = true.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION getClassificacao C-Win 
FUNCTION getClassificacao RETURNS CHARACTER
  ( input classificacao as integer ) :
/*------------------------------------------------------------------------------
  Purpose:  
    Notes:  
------------------------------------------------------------------------------*/

    if classificacao = 1 then
        return 'Valor'.
    else
        return 'Qtde'.

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

