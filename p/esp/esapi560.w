&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI ADM1
&ANALYZE-RESUME
/* Connected Databases 
          custom           PROGRESS
*/
&Scoped-define WINDOW-NAME w-livre
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS w-livre 
/*:T *******************************************************************************
** Copyright TOTVS S.A. (2009)
** Todos os Direitos Reservados.
**
** Este fonte e de propriedade exclusiva da TOTVS, sua reproducao
** parcial ou total por qualquer meio, so podera ser feita mediante
** autorizacao expressa.
*******************************************************************************/
{include/i-prgvrs.i ESAPI560 TOTVS}

/* Chamada a include do gerenciador de licenáas. Necessario alterar os parametros */
/*                                                                                */
/* <programa>:  Informar qual o nome do programa.                                 */
/* <m¢dulo>:  Informar qual o m¢dulo a qual o programa pertence.                  */

&IF "{&EMSFND_VERSION}" >= "1.00" &THEN
    {include/i-license-manager.i <programa> <m¢dulo>}
&ENDIF

/* Create an unnamed pool to store all the widgets created 
     by this procedure. This is a good default which assures
     that this procedure's triggers and internal procedures 
     will execute in this procedure's storage, and that proper
     cleanup will occur on deletion of the procedure. */

CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */

DEF VAR c-situacao AS c LABEL "Tipo" NO-UNDO.

DEF TEMP-TABLE tt-sel NO-UNDO
    FIELD rw  AS ROWID
    INDEX i rw.

{esp/esapi560.i "NEW SHARED"}

DEF VAR i            AS i             NO-UNDO.
DEF VAR lFir         AS l             NO-UNDO.
DEF VAR da-data-liq  AS da INIT TODAY NO-UNDO.
DEF VAR c-refer-lote AS c             NO-UNDO.

DEF BUFFER bf-tit_acr       FOR tit_acr.
DEF BUFFER bf-bv-fat-duplic FOR es-bv-fat-duplic.

DEF NEW SHARED TEMP-TABLE tt-lote NO-UNDO
    FIELD c-refer-lote AS c FORMAT "x(10)"
    FIELD dt-pagto     LIKE es-bv-fat-duplic.dt-pagto
    .

DEF VAR h-run AS HANDLE NO-UNDO.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE w-livre
&Scoped-define DB-AWARE no

&Scoped-define ADM-CONTAINER WINDOW

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME f-cad
&Scoped-define BROWSE-NAME br-integracao

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES es-bv-fat-duplic cst_fat_duplic ~
tit_acr_cartao es-bv-depara

/* Definitions for BROWSE br-integracao                                 */
&Scoped-define FIELDS-IN-QUERY-br-integracao fc-sel() @ es-bv-fat-duplic.char-1 es-bv-fat-duplic.cod-estabel es-bv-fat-duplic.serie es-bv-fat-duplic.nr-fatura es-bv-fat-duplic.parcela es-bv-fat-duplic.adm_cartao cst_fat_duplic.nsu_numero es-bv-fat-duplic.banco es-bv-fat-duplic.agencia es-bv-fat-duplic.conta es-bv-depara.cod-para es-bv-fat-duplic.dt-emissao es-bv-fat-duplic.dt-venciment es-bv-fat-duplic.ret-dt-venciment es-bv-fat-duplic.dt-pagto es-bv-fat-duplic.vl-parcela es-bv-fat-duplic.ret-vl-parcela es-bv-fat-duplic.vl-taxa es-bv-fat-duplic.ret-vl-taxa es-bv-fat-duplic.ret-vl-pago   
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-integracao   
&Scoped-define SELF-NAME br-integracao
&Scoped-define QUERY-STRING-br-integracao FOR EACH es-bv-fat-duplic NO-LOCK        WHERE es-bv-fat-duplic.cod-estabel  >= c-cod-estabel-ini :INPUT-VALUE IN FRAME f-cad          AND es-bv-fat-duplic.cod-estabel  <= c-cod-estabel-fim :INPUT-VALUE IN FRAME f-cad          AND es-bv-fat-duplic.dt-pagto     >= dt-emissao-ini    :INPUT-VALUE IN FRAME f-cad          AND es-bv-fat-duplic.dt-pagto     <= dt-emissao-fim    :INPUT-VALUE IN FRAME f-cad          AND es-bv-fat-duplic.nr-fatura    >= nr-nota-fis-ini   :INPUT-VALUE IN FRAME f-cad          AND es-bv-fat-duplic.nr-fatura    <= nr-nota-fis-fim   :INPUT-VALUE IN FRAME f-cad          AND es-bv-fat-duplic.adm_cartao   >= c-adm-cartao-ini  :INPUT-VALUE IN FRAME f-cad          AND es-bv-fat-duplic.adm_cartao   <= c-adm-cartao-fim  :INPUT-VALUE IN FRAME f-cad          AND es-bv-fat-duplic.ind-envio    =  3, ~
              FIRST cst_fat_duplic NO-LOCK        WHERE cst_fat_duplic.cod_estabel    =  es-bv-fat-duplic.cod-estabel          AND cst_fat_duplic.serie          =  es-bv-fat-duplic.serie          AND cst_fat_duplic.nr_fatura      =  es-bv-fat-duplic.nr-fatura          AND cst_fat_duplic.parcela        =  es-bv-fat-duplic.parcela, ~
              FIRST tit_acr_cartao NO-LOCK        WHERE tit_acr_cartao.cod_estab      =  es-bv-fat-duplic.cod-estabel          AND tit_acr_cartao.serie_cupom    =  es-bv-fat-duplic.serie          AND tit_acr_cartao.num_cupom      =  es-bv-fat-duplic.nr-fatura          AND tit_acr_cartao.cod_parc       =  es-bv-fat-duplic.parcela, ~
              FIRST es-bv-depara NO-LOCK        WHERE es-bv-depara.cod-de           =  es-bv-fat-duplic.conta          AND es-bv-depara.cod-para         >= c-cod-portador-ini:INPUT-VALUE IN FRAME f-cad          AND es-bv-depara.cod-para         <= c-cod-portador-fim:INPUT-VALUE IN FRAME f-cad
&Scoped-define OPEN-QUERY-br-integracao OPEN QUERY {&SELF-NAME}     FOR EACH es-bv-fat-duplic NO-LOCK        WHERE es-bv-fat-duplic.cod-estabel  >= c-cod-estabel-ini :INPUT-VALUE IN FRAME f-cad          AND es-bv-fat-duplic.cod-estabel  <= c-cod-estabel-fim :INPUT-VALUE IN FRAME f-cad          AND es-bv-fat-duplic.dt-pagto     >= dt-emissao-ini    :INPUT-VALUE IN FRAME f-cad          AND es-bv-fat-duplic.dt-pagto     <= dt-emissao-fim    :INPUT-VALUE IN FRAME f-cad          AND es-bv-fat-duplic.nr-fatura    >= nr-nota-fis-ini   :INPUT-VALUE IN FRAME f-cad          AND es-bv-fat-duplic.nr-fatura    <= nr-nota-fis-fim   :INPUT-VALUE IN FRAME f-cad          AND es-bv-fat-duplic.adm_cartao   >= c-adm-cartao-ini  :INPUT-VALUE IN FRAME f-cad          AND es-bv-fat-duplic.adm_cartao   <= c-adm-cartao-fim  :INPUT-VALUE IN FRAME f-cad          AND es-bv-fat-duplic.ind-envio    =  3, ~
              FIRST cst_fat_duplic NO-LOCK        WHERE cst_fat_duplic.cod_estabel    =  es-bv-fat-duplic.cod-estabel          AND cst_fat_duplic.serie          =  es-bv-fat-duplic.serie          AND cst_fat_duplic.nr_fatura      =  es-bv-fat-duplic.nr-fatura          AND cst_fat_duplic.parcela        =  es-bv-fat-duplic.parcela, ~
              FIRST tit_acr_cartao NO-LOCK        WHERE tit_acr_cartao.cod_estab      =  es-bv-fat-duplic.cod-estabel          AND tit_acr_cartao.serie_cupom    =  es-bv-fat-duplic.serie          AND tit_acr_cartao.num_cupom      =  es-bv-fat-duplic.nr-fatura          AND tit_acr_cartao.cod_parc       =  es-bv-fat-duplic.parcela, ~
              FIRST es-bv-depara NO-LOCK        WHERE es-bv-depara.cod-de           =  es-bv-fat-duplic.conta          AND es-bv-depara.cod-para         >= c-cod-portador-ini:INPUT-VALUE IN FRAME f-cad          AND es-bv-depara.cod-para         <= c-cod-portador-fim:INPUT-VALUE IN FRAME f-cad        .
&Scoped-define TABLES-IN-QUERY-br-integracao es-bv-fat-duplic ~
cst_fat_duplic tit_acr_cartao es-bv-depara
&Scoped-define FIRST-TABLE-IN-QUERY-br-integracao es-bv-fat-duplic
&Scoped-define SECOND-TABLE-IN-QUERY-br-integracao cst_fat_duplic
&Scoped-define THIRD-TABLE-IN-QUERY-br-integracao tit_acr_cartao
&Scoped-define FOURTH-TABLE-IN-QUERY-br-integracao es-bv-depara


/* Definitions for FRAME f-cad                                          */
&Scoped-define OPEN-BROWSERS-IN-QUERY-f-cad ~
    ~{&OPEN-QUERY-br-integracao}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS rt-button c-cod-estabel-ini ~
c-cod-estabel-fim c-adm-cartao-ini c-adm-cartao-fim dt-emissao-ini ~
dt-emissao-fim nr-nota-fis-ini nr-nota-fis-fim c-cod-portador-ini ~
c-cod-portador-fim bt-sel br-integracao bt-todos bt-nenhum bt-excel ~
bt-dgita bt-criar 
&Scoped-Define DISPLAYED-OBJECTS c-cod-estabel-ini c-cod-estabel-fim ~
c-adm-cartao-ini c-adm-cartao-fim dt-emissao-ini dt-emissao-fim ~
nr-nota-fis-ini nr-nota-fis-fim c-cod-portador-ini c-cod-portador-fim 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD fc-sel w-livre 
FUNCTION fc-sel RETURNS CHARACTER
  ( /* parameter-definitions */ )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR w-livre AS WIDGET-HANDLE NO-UNDO.

/* Menu Definitions                                                     */
DEFINE SUB-MENU mi-programa 
       MENU-ITEM mi-consultas   LABEL "Co&nsultas"     ACCELERATOR "CTRL-L"
       MENU-ITEM mi-imprimir    LABEL "&Relat¢rios"    ACCELERATOR "CTRL-P"
       RULE
       MENU-ITEM mi-sair        LABEL "&Sair"          ACCELERATOR "CTRL-X".

DEFINE SUB-MENU m_Ajuda 
       MENU-ITEM mi-conteudo    LABEL "&Conteudo"     
       MENU-ITEM mi-sobre       LABEL "&Sobre..."     .

DEFINE MENU m-livre MENUBAR
       SUB-MENU  mi-programa    LABEL "&Nome-do-Programa"
       SUB-MENU  m_Ajuda        LABEL "&Ajuda"        .


/* Definitions of handles for SmartObjects                              */
DEFINE VARIABLE h_p-exihel AS HANDLE NO-UNDO.

/* Definitions of the field level widgets                               */
DEFINE BUTTON bt-criar 
     LABEL "Criar Lote Liquidaá∆o" 
     SIZE 20 BY 1.13.

DEFINE BUTTON bt-dgita 
     LABEL "Digitar Lote Liquidaá∆o" 
     SIZE 20 BY 1.13.

DEFINE BUTTON bt-excel 
     LABEL "Gerar Relat¢rio em Excel" 
     SIZE 20 BY 1.13.

DEFINE BUTTON bt-nenhum 
     LABEL "Nenhum" 
     SIZE 18 BY 1.13.

DEFINE BUTTON bt-sel 
     LABEL "Selecionar" 
     SIZE 70.29 BY 1.13.

DEFINE BUTTON bt-todos 
     LABEL "Todos" 
     SIZE 18 BY 1.13.

DEFINE VARIABLE c-adm-cartao-fim AS CHARACTER FORMAT "X(256)":U INITIAL "ZZZZZZ" 
     VIEW-AS FILL-IN 
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE c-adm-cartao-ini AS CHARACTER FORMAT "X(256)":U 
     LABEL "Administradora" 
     VIEW-AS FILL-IN 
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE c-cod-estabel-fim AS CHARACTER FORMAT "X(256)":U INITIAL "ZZZ" 
     VIEW-AS FILL-IN 
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE c-cod-estabel-ini AS CHARACTER FORMAT "X(256)":U 
     LABEL "Filial" 
     VIEW-AS FILL-IN 
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE c-cod-portador-fim AS CHARACTER FORMAT "X(256)":U INITIAL "999999999" 
     VIEW-AS FILL-IN 
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE c-cod-portador-ini AS CHARACTER FORMAT "X(256)":U INITIAL "0" 
     LABEL "Portador" 
     VIEW-AS FILL-IN 
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE dt-emissao-fim AS DATE FORMAT "99/99/9999":U INITIAL 12/31/9999 
     VIEW-AS FILL-IN 
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE dt-emissao-ini AS DATE FORMAT "99/99/9999":U INITIAL 01/01/001 
     LABEL "Data Pagamento" 
     VIEW-AS FILL-IN 
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE nr-nota-fis-fim AS CHARACTER FORMAT "X(256)":U INITIAL "999999999" 
     VIEW-AS FILL-IN 
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE nr-nota-fis-ini AS CHARACTER FORMAT "X(256)":U 
     LABEL "Cupom" 
     VIEW-AS FILL-IN 
     SIZE 14 BY 1 NO-UNDO.

DEFINE RECTANGLE rt-button
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 177 BY 1.46
     BGCOLOR 7 .

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-integracao FOR 
      es-bv-fat-duplic, 
      cst_fat_duplic, 
      tit_acr_cartao, 
      es-bv-depara SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-integracao
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-integracao w-livre _FREEFORM
  QUERY br-integracao NO-LOCK DISPLAY
      fc-sel() @ es-bv-fat-duplic.char-1          FORMAT "x"                 COLUMN-LABEL "*"
      es-bv-fat-duplic.cod-estabel                FORMAT "x(5)":U
      es-bv-fat-duplic.serie                      FORMAT "x(5)":U
      es-bv-fat-duplic.nr-fatura                  FORMAT "x(16)":U           COLUMN-LABEL "Cupom"
      es-bv-fat-duplic.parcela                    FORMAT "x(02)":U           
      es-bv-fat-duplic.adm_cartao
      cst_fat_duplic.nsu_numero                   FORMAT "x(15)"
      es-bv-fat-duplic.banco                                                 COLUMN-LABEL "Bco"
      es-bv-fat-duplic.agencia                    FORMAT "x(10)"             COLUMN-LABEL "Agencia"
      es-bv-fat-duplic.conta                      FORMAT "x(16)"             COLUMN-LABEL "Conta"
      es-bv-depara.cod-para                                                  COLUMN-LABEL "Portador"
      es-bv-fat-duplic.dt-emissao                 FORMAT "99/99/9999":U      
      es-bv-fat-duplic.dt-venciment               FORMAT "99/99/9999":U      COLUMN-LABEL "Venc Datasul"   
      es-bv-fat-duplic.ret-dt-venciment           FORMAT "99/99/9999":U      COLUMN-LABEL "Venc Boa Vista" 
      es-bv-fat-duplic.dt-pagto                   FORMAT "99/99/9999":U      COLUMN-LABEL "Pagamento" 
      es-bv-fat-duplic.vl-parcela                 FORMAT ">>>,>>>,>>9.99":U  COLUMN-LABEL "Vl Datasul (bruto)"
      es-bv-fat-duplic.ret-vl-parcela             FORMAT ">>>,>>>,>>9.99":U  COLUMN-LABEL "Vl Boa Vista (bruto)"
      es-bv-fat-duplic.vl-taxa                    FORMAT ">,>>9.99":U        COLUMN-LABEL "Taxa Datasul"
      es-bv-fat-duplic.ret-vl-taxa                FORMAT ">,>>9.99":U        COLUMN-LABEL "Taxa Boa Vista"
      es-bv-fat-duplic.ret-vl-pago                FORMAT ">,>>9.99":U        COLUMN-LABEL "Vl Pago"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 177 BY 9.29
         FONT 1
         TITLE "Integraá∆o Boa Vista" FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME f-cad
     c-cod-estabel-ini AT ROW 2.75 COL 13.43 COLON-ALIGNED WIDGET-ID 32
     c-cod-estabel-fim AT ROW 2.75 COL 28.43 COLON-ALIGNED NO-LABEL WIDGET-ID 30
     c-adm-cartao-ini AT ROW 2.79 COL 54.14 COLON-ALIGNED WIDGET-ID 46
     c-adm-cartao-fim AT ROW 2.79 COL 69.14 COLON-ALIGNED NO-LABEL WIDGET-ID 44
     dt-emissao-ini AT ROW 3.83 COL 13.43 COLON-ALIGNED WIDGET-ID 2
     dt-emissao-fim AT ROW 3.83 COL 28.43 COLON-ALIGNED NO-LABEL WIDGET-ID 8
     nr-nota-fis-ini AT ROW 4.88 COL 13.43 COLON-ALIGNED WIDGET-ID 4
     nr-nota-fis-fim AT ROW 4.88 COL 28.43 COLON-ALIGNED NO-LABEL WIDGET-ID 12
     c-cod-portador-ini AT ROW 5.96 COL 13.43 COLON-ALIGNED WIDGET-ID 6
     c-cod-portador-fim AT ROW 5.96 COL 28.43 COLON-ALIGNED NO-LABEL WIDGET-ID 10
     bt-sel AT ROW 7.08 COL 15 WIDGET-ID 38
     br-integracao AT ROW 8.21 COL 1 WIDGET-ID 100
     bt-todos AT ROW 17.75 COL 1 WIDGET-ID 34
     bt-nenhum AT ROW 17.75 COL 19.29 WIDGET-ID 36
     bt-excel AT ROW 17.75 COL 117 WIDGET-ID 24
     bt-dgita AT ROW 17.75 COL 137.57 WIDGET-ID 28
     bt-criar AT ROW 17.75 COL 157.86 WIDGET-ID 48
     rt-button AT ROW 1 COL 1
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 177.43 BY 17.92
         FONT 1.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: w-livre Template
   Allow: Basic,Browse,DB-Fields,Smart,Window,Query
   Container Links: 
   Add Fields to: Neither
   Other Settings: COMPILE
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
IF SESSION:DISPLAY-TYPE = "GUI":U THEN
  CREATE WINDOW w-livre ASSIGN
         HIDDEN             = YES
         TITLE              = "Template Livre <Insira complemento>"
         HEIGHT             = 17.92
         WIDTH              = 177.43
         MAX-HEIGHT         = 17.92
         MAX-WIDTH          = 177.43
         VIRTUAL-HEIGHT     = 17.92
         VIRTUAL-WIDTH      = 177.43
         RESIZE             = yes
         SCROLL-BARS        = no
         STATUS-AREA        = yes
         BGCOLOR            = ?
         FGCOLOR            = ?
         THREE-D            = yes
         MESSAGE-AREA       = no
         SENSITIVE          = yes.
ELSE {&WINDOW-NAME} = CURRENT-WINDOW.

ASSIGN {&WINDOW-NAME}:MENUBAR    = MENU m-livre:HANDLE.
/* END WINDOW DEFINITION                                                */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _INCLUDED-LIB w-livre 
/* ************************* Included-Libraries *********************** */

{src/adm/method/containr.i}
{include/w-livre.i}
{utp/ut-glob.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME




/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW w-livre
  VISIBLE,,RUN-PERSISTENT                                               */
/* SETTINGS FOR FRAME f-cad
   FRAME-NAME L-To-R                                                    */
/* BROWSE-TAB br-integracao bt-sel f-cad */
IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(w-livre)
THEN w-livre:HIDDEN = yes.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-integracao
/* Query rebuild information for BROWSE br-integracao
     _START_FREEFORM
OPEN QUERY {&SELF-NAME}
    FOR EACH es-bv-fat-duplic NO-LOCK
       WHERE es-bv-fat-duplic.cod-estabel  >= c-cod-estabel-ini :INPUT-VALUE IN FRAME f-cad
         AND es-bv-fat-duplic.cod-estabel  <= c-cod-estabel-fim :INPUT-VALUE IN FRAME f-cad
         AND es-bv-fat-duplic.dt-pagto     >= dt-emissao-ini    :INPUT-VALUE IN FRAME f-cad
         AND es-bv-fat-duplic.dt-pagto     <= dt-emissao-fim    :INPUT-VALUE IN FRAME f-cad
         AND es-bv-fat-duplic.nr-fatura    >= nr-nota-fis-ini   :INPUT-VALUE IN FRAME f-cad
         AND es-bv-fat-duplic.nr-fatura    <= nr-nota-fis-fim   :INPUT-VALUE IN FRAME f-cad
         AND es-bv-fat-duplic.adm_cartao   >= c-adm-cartao-ini  :INPUT-VALUE IN FRAME f-cad
         AND es-bv-fat-duplic.adm_cartao   <= c-adm-cartao-fim  :INPUT-VALUE IN FRAME f-cad
         AND es-bv-fat-duplic.ind-envio    =  3,
       FIRST cst_fat_duplic NO-LOCK
       WHERE cst_fat_duplic.cod_estabel    =  es-bv-fat-duplic.cod-estabel
         AND cst_fat_duplic.serie          =  es-bv-fat-duplic.serie
         AND cst_fat_duplic.nr_fatura      =  es-bv-fat-duplic.nr-fatura
         AND cst_fat_duplic.parcela        =  es-bv-fat-duplic.parcela,
       FIRST tit_acr_cartao NO-LOCK
       WHERE tit_acr_cartao.cod_estab      =  es-bv-fat-duplic.cod-estabel
         AND tit_acr_cartao.serie_cupom    =  es-bv-fat-duplic.serie
         AND tit_acr_cartao.num_cupom      =  es-bv-fat-duplic.nr-fatura
         AND tit_acr_cartao.cod_parc       =  es-bv-fat-duplic.parcela,
       FIRST es-bv-depara NO-LOCK
       WHERE es-bv-depara.cod-de           =  es-bv-fat-duplic.conta
         AND es-bv-depara.cod-para         >= c-cod-portador-ini:INPUT-VALUE IN FRAME f-cad
         AND es-bv-depara.cod-para         <= c-cod-portador-fim:INPUT-VALUE IN FRAME f-cad
       .
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is OPENED
*/  /* BROWSE br-integracao */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME w-livre
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL w-livre w-livre
ON END-ERROR OF w-livre /* Template Livre <Insira complemento> */
OR ENDKEY OF {&WINDOW-NAME} ANYWHERE DO:
  /* This case occurs when the user presses the "Esc" key.
     In a persistently run window, just ignore this.  If we did not, the
     application would exit. */
  RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL w-livre w-livre
ON WINDOW-CLOSE OF w-livre /* Template Livre <Insira complemento> */
DO:
  /* This ADM code must be left here in order for the SmartWindow
     and its descendents to terminate properly on exit. */
  APPLY "CLOSE":U TO THIS-PROCEDURE.
  RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-integracao
&Scoped-define SELF-NAME br-integracao
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-integracao w-livre
ON MOUSE-SELECT-DBLCLICK OF br-integracao IN FRAME f-cad /* Integraá∆o Boa Vista */
DO:
   IF AVAIL es-bv-fat-duplic
   THEN DO:
      FIND FIRST tt-sel
           WHERE tt-sel.rw = ROWID(es-bv-fat-duplic)
           NO-ERROR.
      IF NOT AVAIL tt-sel 
      THEN DO:
         CREATE tt-sel.
         ASSIGN
            tt-sel.rw = ROWID(es-bv-fat-duplic).
      END.
      ELSE DELETE tt-sel.
      BROWSE {&browse-name}:REFRESH().
   END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-integracao w-livre
ON VALUE-CHANGED OF br-integracao IN FRAME f-cad /* Integraá∆o Boa Vista */
DO:
   {&OPEN-QUERY-br-retorno}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-criar
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-criar w-livre
ON CHOOSE OF bt-criar IN FRAME f-cad /* Criar Lote Liquidaá∆o */
DO:
   DEF VAR h AS HANDLE NO-UNDO.

   IF TEMP-TABLE tt-lote:HAS-RECORDS = NO
   THEN DO:
      RUN utp/ut-msgs.p ("show",17006,"Referàncias n∆o foram digitadas").
      RETURN.

   END.

   FIND FIRST tt-lote
        WHERE tt-lote.c-refer-lote = ""
        NO-ERROR.
   IF AVAIL tt-lote
   THEN DO:
      RUN utp/ut-msgs.p ("show",17006,"Existem lotes sem refàncias digitadas").
      RETURN.
   END.

   RUN utp/ut-msgs.p ("show",27100,"Gerar Lote de Liquidaá∆o?").
   IF RETURN-VALUE = "NO" 
   THEN RETURN.

   RUN utp/ut-acomp.p PERSISTENT SET h.

   RUN pi-inicializar IN h ("").

   FOR EACH tt-lote:
      EMPTY TEMP-TABLE tt_integr_acr_liquidac_lote.
      EMPTY TEMP-TABLE tt_integr_acr_liq_item_lote_3.
      EMPTY TEMP-TABLE tt_integr_acr_abat_antecip_1.
      EMPTY TEMP-TABLE tt_integr_acr_abat_prev_1.
      EMPTY TEMP-TABLE tt_integr_acr_cheq_1.
      EMPTY TEMP-TABLE tt_integr_acr_liquidac_impto_2.
      EMPTY TEMP-TABLE tt_integr_acr_rel_pend_cheq.
      EMPTY TEMP-TABLE tt_integr_acr_liq_aprop_ctbl.
      EMPTY TEMP-TABLE tt_integr_acr_liq_desp_rec.
      EMPTY TEMP-TABLE tt_integr_acr_aprop_liq_antec_1.
      EMPTY TEMP-TABLE tt_log_erros_import_liquidac.
      EMPTY TEMP-TABLE tt_integr_cambio_ems5.
      ASSIGN
         lFir = NO.

      FOR EACH tt-sel,
         FIRST es-bv-fat-duplic NO-LOCK
         WHERE ROWID(es-bv-fat-duplic) = tt-sel.rw,
         FIRST fat-duplic NO-LOCK
         WHERE fat-duplic.cod-estabel = es-bv-fat-duplic.cod-estabel
           AND fat-duplic.serie       = es-bv-fat-duplic.serie
           AND fat-duplic.nr-fatura   = es-bv-fat-duplic.nr-fatura
           AND fat-duplic.parcela     = es-bv-fat-duplic.parcela:

         IF tt-lote.dt-pagto <> es-bv-fat-duplic.dt-pagto
         THEN NEXT.

   
         FIND FIRST tit_acr_cartao NO-LOCK
              WHERE tit_acr_cartao.cod_estab   = es-bv-fat-duplic.cod-estabel
                AND tit_acr_cartao.serie_cupom = es-bv-fat-duplic.serie
                AND tit_acr_cartao.num_cupom   = es-bv-fat-duplic.nr-fatura
                AND tit_acr_cartao.cod_parc    = es-bv-fat-duplic.parcela
              NO-ERROR.
         FIND FIRST tit_acr NO-LOCK
              WHERE tit_acr.cod_estab      = es-bv-fat-duplic.cod-estabel
                AND tit_acr.num_id_tit_acr = tit_acr_cartao.num_id_tit_acr
              NO-ERROR.
         
   
         FIND FIRST es-bv-depara NO-LOCK
              WHERE es-bv-depara.cod-de   = es-bv-fat-duplic.conta
              NO-ERROR.
         IF AVAIL es-bv-depara
         THEN FIND FIRST ems5.portador NO-LOCK
              WHERE portador.cod_portador = es-bv-depara.cod-para
              NO-ERROR.
   
         IF  AVAIL tit_acr_cartao
         AND AVAIL tit_acr
         AND AVAIL ems5.portador
         THEN RUN pi-liquida.
      END.
   
      IF CAN-FIND(FIRST tt_integr_acr_liq_item_lote_3) 
      THEN DO:
         RUN prgfin/acr/acr901zf.py PERSISTENT SET v_hdl_api_integr_acr.
         RUN pi_main_code_api_integr_acr_liquidac_4 IN v_hdl_api_integr_acr
                                    (INPUT  1,
                                     INPUT  TABLE tt_integr_acr_liquidac_lote,
                                     INPUT  TABLE tt_integr_acr_liq_item_lote_3,
                                     INPUT  TABLE tt_integr_acr_abat_antecip_1,
                                     INPUT  TABLE tt_integr_acr_abat_prev_1,
                                     INPUT  TABLE tt_integr_acr_cheq_1,
                                     INPUT  TABLE tt_integr_acr_liquidac_impto_2,
                                     INPUT  TABLE tt_integr_acr_rel_pend_cheq,
                                     INPUT  TABLE tt_integr_acr_liq_aprop_ctbl,
                                     INPUT  TABLE tt_integr_acr_liq_desp_rec,
                                     INPUT  TABLE tt_integr_acr_aprop_liq_antec_1,
                                     INPUT  "",
                                     OUTPUT TABLE tt_log_erros_import_liquidac,
                                     INPUT  TABLE tt_integr_cambio_ems5) /*prg_api_integr_acr_liquidac_2*/.
         IF RETURN-VALUE = "OK" 
         THEN DO:
            FOR EACH tt-sel,
               FIRST es-bv-fat-duplic 
               WHERE ROWID(es-bv-fat-duplic) = tt-sel.rw:
               ASSIGN
                  es-bv-fat-duplic.ind-envio = 4
                  .
            END.
         END.
      END.
   
      IF TEMP-TABLE tt_log_erros_import_liquidac:HAS-RECORDS 
      THEN DO:
         OUTPUT TO VALUE(SESSION:TEMP-DIRECTORY + "esapi560-" +  c-refer-lote + ".lst") PAGE-SIZE 0 CONVERT TARGET "iso8859-1".
         FOR EACH tt_log_erros_import_liquidac
            BREAK BY tt_log_erros_import_liquidac.tta_num_seq:
             ASSIGN
                 tt_log_erros_import_liquidac.ttv_des_msg_erro = REPLACE(tt_log_erros_import_liquidac.ttv_des_msg_erro,CHR(13)," ")
                 tt_log_erros_import_liquidac.ttv_des_msg_erro = REPLACE(tt_log_erros_import_liquidac.ttv_des_msg_erro,CHR(10)," ")
                 .
             DISP 
                 tt_log_erros_import_liquidac.tta_cod_estab        COLUMN-LABEL "Estab"
                 tt_log_erros_import_liquidac.tta_cod_espec_docto  COLUMN-LABEL "EspÇcie"
                 tt_log_erros_import_liquidac.tta_cod_ser_docto    COLUMN-LABEL "SÇrie"
                 tt_log_erros_import_liquidac.tta_cod_tit_acr      COLUMN-LABEL "T°tulo"
                 tt_log_erros_import_liquidac.tta_cod_parcela      COLUMN-LABEL "Parcela"
                 tt_log_erros_import_liquidac.ttv_num_erro_log     COLUMN-LABEL "Erro"
                 tt_log_erros_import_liquidac.ttv_des_msg_erro     COLUMN-LABEL "Inconsistància" FORMAT "x(240)" 
                 WITH STREAM-IO DOWN FRAME fLogMsg WIDTH 455.               
                 
         END.
         OUTPUT CLOSE.
         RUN OpenDocument (SESSION:TEMP-DIRECTORY + "esapi560-" +  c-refer-lote + ".lst").
   
      END.
   END.

   RUN pi-finalizar IN h.
   EMPTY TEMP-TABLE tt-sel.

   {&OPEN-QUERY-{&BROWSE-NAME}}

   IF NOT TEMP-TABLE tt_log_erros_import_liquidac:HAS-RECORDS  
   THEN RUN utp/ut-msgs.p ("show",15825,"Lote de liquidaá∆o gerados").
   
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-dgita
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-dgita w-livre
ON CHOOSE OF bt-dgita IN FRAME f-cad /* Digitar Lote Liquidaá∆o */
DO:
   DEF VAR h AS HANDLE NO-UNDO.

   IF TEMP-TABLE tt-sel:HAS-RECORDS = NO
   THEN DO:
      RUN utp/ut-msgs.p ("show",17006,"Nenhum registro foi selecionado").
      RETURN.
   END.

   EMPTY TEMP-TABLE tt-lote.

   FOR EACH tt-sel,
      FIRST es-bv-fat-duplic NO-LOCK
      WHERE ROWID(es-bv-fat-duplic) = tt-sel.rw,
      FIRST fat-duplic NO-LOCK
      WHERE fat-duplic.cod-estabel = es-bv-fat-duplic.cod-estabel
        AND fat-duplic.serie       = es-bv-fat-duplic.serie
        AND fat-duplic.nr-fatura   = es-bv-fat-duplic.nr-fatura
        AND fat-duplic.parcela     = es-bv-fat-duplic.parcela:
      FIND FIRST tt-lote
           WHERE tt-lote.dt-pagto = es-bv-fat-duplic.dt-pagto
           NO-ERROR.
      IF NOT AVAIL tt-lote
      THEN DO:
         CREATE tt-lote.
         ASSIGN
            tt-lote.dt-pagto = es-bv-fat-duplic.dt-pagto.
      END.
   END.

   RUN pi-run ("esapi560z.w.w", OUTPUT h-run).

   IF NOT VALID-HANDLE(h-run)
   THEN RUN esp\esapi560z.w  PERSISTENT SET h-run.
   RUN local-initialize IN h-run.


//   RUN esp/esapi560x.w (INPUT-OUTPUT TABLE tt-lote).

   /*

   RUN esp/esapi560a.w (OUTPUT c-refer-lote).

   IF c-refer-lote = ""
   THEN RETURN.

   EMPTY TEMP-TABLE tt_integr_acr_liquidac_lote.
   EMPTY TEMP-TABLE tt_integr_acr_liq_item_lote_3.
   EMPTY TEMP-TABLE tt_integr_acr_abat_antecip_1.
   EMPTY TEMP-TABLE tt_integr_acr_abat_prev_1.
   EMPTY TEMP-TABLE tt_integr_acr_cheq_1.
   EMPTY TEMP-TABLE tt_integr_acr_liquidac_impto_2.
   EMPTY TEMP-TABLE tt_integr_acr_rel_pend_cheq.
   EMPTY TEMP-TABLE tt_integr_acr_liq_aprop_ctbl.
   EMPTY TEMP-TABLE tt_integr_acr_liq_desp_rec.
   EMPTY TEMP-TABLE tt_integr_acr_aprop_liq_antec_1.
   EMPTY TEMP-TABLE tt_log_erros_import_liquidac.
   EMPTY TEMP-TABLE tt_integr_cambio_ems5.

   RUN utp/ut-msgs.p ("show",27100,"Gerar Lote de Liquidaá∆o?").
   IF RETURN-VALUE = "NO" 
   THEN RETURN.

   RUN utp/ut-acomp.p PERSISTENT SET h.

   RUN pi-inicializar IN h ("").

   ASSIGN
      lFir = NO.

   FOR EACH tt-sel,
      FIRST es-bv-fat-duplic NO-LOCK
      WHERE ROWID(es-bv-fat-duplic) = tt-sel.rw,
      FIRST fat-duplic NO-LOCK
      WHERE fat-duplic.cod-estabel = es-bv-fat-duplic.cod-estabel
        AND fat-duplic.serie       = es-bv-fat-duplic.serie
        AND fat-duplic.nr-fatura   = es-bv-fat-duplic.nr-fatura
        AND fat-duplic.parcela     = es-bv-fat-duplic.parcela:


      FIND FIRST tit_acr_cartao NO-LOCK
           WHERE tit_acr_cartao.cod_estab   = es-bv-fat-duplic.cod-estabel
             AND tit_acr_cartao.serie_cupom = es-bv-fat-duplic.serie
             AND tit_acr_cartao.num_cupom   = es-bv-fat-duplic.nr-fatura
             AND tit_acr_cartao.cod_parc    = es-bv-fat-duplic.parcela
           NO-ERROR.
      FIND FIRST tit_acr NO-LOCK
           WHERE tit_acr.cod_estab      = es-bv-fat-duplic.cod-estabel
             AND tit_acr.num_id_tit_acr = tit_acr_cartao.num_id_tit_acr
           NO-ERROR.
      

      FIND FIRST es-bv-depara NO-LOCK
           WHERE es-bv-depara.cod-de   = es-bv-fat-duplic.conta
           NO-ERROR.
      IF AVAIL es-bv-depara
      THEN FIND FIRST ems5.portador NO-LOCK
           WHERE portador.cod_portador = es-bv-depara.cod-para
           NO-ERROR.

      IF  AVAIL tit_acr_cartao
      AND AVAIL tit_acr
      AND AVAIL ems5.portador
      THEN RUN pi-liquida.
   END.

   IF CAN-FIND(FIRST tt_integr_acr_liq_item_lote_3) 
   THEN DO:
      RUN prgfin/acr/acr901zf.py PERSISTENT SET v_hdl_api_integr_acr.
      RUN pi_main_code_api_integr_acr_liquidac_4 IN v_hdl_api_integr_acr
                                 (INPUT  1,
                                  INPUT  TABLE tt_integr_acr_liquidac_lote,
                                  INPUT  TABLE tt_integr_acr_liq_item_lote_3,
                                  INPUT  TABLE tt_integr_acr_abat_antecip_1,
                                  INPUT  TABLE tt_integr_acr_abat_prev_1,
                                  INPUT  TABLE tt_integr_acr_cheq_1,
                                  INPUT  TABLE tt_integr_acr_liquidac_impto_2,
                                  INPUT  TABLE tt_integr_acr_rel_pend_cheq,
                                  INPUT  TABLE tt_integr_acr_liq_aprop_ctbl,
                                  INPUT  TABLE tt_integr_acr_liq_desp_rec,
                                  INPUT  TABLE tt_integr_acr_aprop_liq_antec_1,
                                  INPUT  "",
                                  OUTPUT TABLE tt_log_erros_import_liquidac,
                                  INPUT  TABLE tt_integr_cambio_ems5) /*prg_api_integr_acr_liquidac_2*/.
      IF RETURN-VALUE = "OK" 
      THEN DO:
         FOR EACH tt-sel,
            FIRST es-bv-fat-duplic 
            WHERE ROWID(es-bv-fat-duplic) = tt-sel.rw:
            ASSIGN
               es-bv-fat-duplic.ind-envio = 4.
         END.
         EMPTY TEMP-TABLE tt-sel.
      END.
   END.

   IF TEMP-TABLE tt_log_erros_import_liquidac:HAS-RECORDS 
   THEN DO:
      OUTPUT TO VALUE(SESSION:TEMP-DIRECTORY + "esapi560-" +  c-refer-lote + ".lst") PAGE-SIZE 0 CONVERT TARGET "iso8859-1".
      FOR EACH tt_log_erros_import_liquidac
         BREAK BY tt_log_erros_import_liquidac.tta_num_seq:
          ASSIGN
              tt_log_erros_import_liquidac.ttv_des_msg_erro = REPLACE(tt_log_erros_import_liquidac.ttv_des_msg_erro,CHR(13)," ")
              tt_log_erros_import_liquidac.ttv_des_msg_erro = REPLACE(tt_log_erros_import_liquidac.ttv_des_msg_erro,CHR(10)," ")
              .
          DISP 
              tt_log_erros_import_liquidac.tta_cod_estab        COLUMN-LABEL "Estab"
              tt_log_erros_import_liquidac.tta_cod_espec_docto  COLUMN-LABEL "EspÇcie"
              tt_log_erros_import_liquidac.tta_cod_ser_docto    COLUMN-LABEL "SÇrie"
              tt_log_erros_import_liquidac.tta_cod_tit_acr      COLUMN-LABEL "T°tulo"
              tt_log_erros_import_liquidac.tta_cod_parcela      COLUMN-LABEL "Parcela"
              tt_log_erros_import_liquidac.ttv_num_erro_log     COLUMN-LABEL "Erro"
              tt_log_erros_import_liquidac.ttv_des_msg_erro     COLUMN-LABEL "Inconsistància" FORMAT "x(240)" 
              WITH STREAM-IO DOWN FRAME fLogMsg WIDTH 455.               
              
      END.
      OUTPUT CLOSE.
      RUN OpenDocument (SESSION:TEMP-DIRECTORY + "esapi560-" +  c-refer-lote + ".lst").

   END.
   RUN pi-finalizar IN h.
   {&OPEN-QUERY-{&BROWSE-NAME}}

   IF NOT TEMP-TABLE tt_log_erros_import_liquidac:HAS-RECORDS  
   THEN RUN utp/ut-msgs.p ("show",15825,"Lote de liquidaá∆o gerado: " + c-refer-lote).
   */
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-excel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-excel w-livre
ON CHOOSE OF bt-excel IN FRAME f-cad /* Gerar Relat¢rio em Excel */
DO:
   RUN pi-excel.  
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-nenhum
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-nenhum w-livre
ON CHOOSE OF bt-nenhum IN FRAME f-cad /* Nenhum */
DO:
   EMPTY TEMP-TABLE tt-sel.
   BROWSE {&browse-name}:REFRESH().
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-sel w-livre
ON CHOOSE OF bt-sel IN FRAME f-cad /* Selecionar */
DO:
   EMPTY TEMP-TABLE tt-sel.
   {&OPEN-QUERY-{&BROWSE-NAME}}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-todos
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-todos w-livre
ON CHOOSE OF bt-todos IN FRAME f-cad /* Todos */
DO:
    DEF BUFFER bf-bv-fat-duplic  FOR es-bv-fat-duplic.
    DEF BUFFER bf-cst_fat_duplic FOR cst_fat_duplic.
    DEF VAR i AS i      NO-UNDO.
    DEF VAR h AS HANDLE NO-UNDO.
    RUN utp/ut-acomp.p PERSISTENT SET h.
    RUN pi-inicializar IN h ("").

    EMPTY TEMP-TABLE tt-sel.

    GET FIRST br-integracao.

    REPEAT WHILE AVAIL es-bv-fat-duplic:
       ASSIGN
          i = i + 1.
       IF i / 10 = INT(i / 10)
       THEN RUN pi-acompanhar IN h (STRING(i)).

       FIND FIRST tt-sel
            WHERE tt-sel.rw = ROWID(es-bv-fat-duplic)
            NO-ERROR.
       IF NOT AVAIL tt-sel 
       THEN DO:
          CREATE tt-sel.
          ASSIGN
             tt-sel.rw = ROWID(es-bv-fat-duplic).
       END.

       GET NEXT br-integracao.
    END.

    /*
    FOR EACH bf-bv-fat-duplic NO-LOCK
       WHERE bf-bv-fat-duplic.cod-estabel  >= c-cod-estabel-ini :INPUT-VALUE IN FRAME f-cad
         AND bf-bv-fat-duplic.cod-estabel  <= c-cod-estabel-fim :INPUT-VALUE IN FRAME f-cad
         AND bf-bv-fat-duplic.dt-emissao   >= dt-emissao-ini    :INPUT-VALUE IN FRAME f-cad
         AND bf-bv-fat-duplic.dt-emissao   <= dt-emissao-fim    :INPUT-VALUE IN FRAME f-cad
         AND bf-bv-fat-duplic.nr-fatura    >= nr-nota-fis-ini   :INPUT-VALUE IN FRAME f-cad
         AND bf-bv-fat-duplic.nr-fatura    <= nr-nota-fis-fim   :INPUT-VALUE IN FRAME f-cad
         AND bf-bv-fat-duplic.adm_cartao   >= c-adm-cartao-ini  :INPUT-VALUE IN FRAME f-cad
         AND bf-bv-fat-duplic.adm_cartao   <= c-adm-cartao-fim  :INPUT-VALUE IN FRAME f-cad
         AND bf-bv-fat-duplic.ind-envio    =  3,
       FIRST bf-cst_fat_duplic NO-LOCK
       WHERE bf-cst_fat_duplic.cod_estabel =  bf-bv-fat-duplic.cod-estabel
         AND bf-cst_fat_duplic.serie       =  bf-bv-fat-duplic.serie
         AND bf-cst_fat_duplic.nr_fatura   =  bf-bv-fat-duplic.nr-fatura
         AND bf-cst_fat_duplic.parcela     =  bf-bv-fat-duplic.parcela,
       FIRST es-bv-depara NO-LOCK 
       WHERE es-bv-depara.cod-de           =  es-bv-fat-duplic.conta
         AND es-bv-depara.cod-de           >= c-cod-portador-ini:INPUT-VALUE IN FRAME f-cad
         AND es-bv-depara.cod-de           <= c-cod-portador-fim:INPUT-VALUE IN FRAME f-cad
       ON STOP UNDO, LEAVE:
       ASSIGN
          i = i + 1.
       IF i / 10 = INT(i / 10)
       THEN RUN pi-acompanhar IN h (STRING(i)).

       FIND FIRST tt-sel
            WHERE tt-sel.rw = ROWID(bf-bv-fat-duplic)
            NO-ERROR.
       IF NOT AVAIL tt-sel 
       THEN DO:
          CREATE tt-sel.
          ASSIGN
             tt-sel.rw = ROWID(bf-bv-fat-duplic).
       END.
    END.
    */
    RUN pi-finalizar IN h.
    BROWSE {&browse-name}:REFRESH().
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME mi-consultas
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL mi-consultas w-livre
ON CHOOSE OF MENU-ITEM mi-consultas /* Consultas */
DO:
  RUN pi-consulta IN h_p-exihel.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME mi-conteudo
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL mi-conteudo w-livre
ON CHOOSE OF MENU-ITEM mi-conteudo /* Conteudo */
OR HELP OF FRAME {&FRAME-NAME}
DO:
  RUN pi-ajuda IN h_p-exihel.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME mi-imprimir
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL mi-imprimir w-livre
ON CHOOSE OF MENU-ITEM mi-imprimir /* Relat¢rios */
DO:
  RUN pi-imprimir IN h_p-exihel.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME mi-programa
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL mi-programa w-livre
ON MENU-DROP OF MENU mi-programa /* Nome-do-Programa */
DO:
  run pi-disable-menu.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME mi-sair
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL mi-sair w-livre
ON CHOOSE OF MENU-ITEM mi-sair /* Sair */
DO:
  RUN pi-sair IN h_p-exihel.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME mi-sobre
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL mi-sobre w-livre
ON CHOOSE OF MENU-ITEM mi-sobre /* Sobre... */
DO:
  {include/sobre.i}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK w-livre 


/* ***************************  Main Block  *************************** */

/* Include custom  Main Block code for SmartWindows. */
{src/adm/template/windowmn.i}

PROCEDURE OpenDocument:

    def input param c-doc as char  no-undo.
    def var c-exec as char  no-undo.
    def var h-Inst as int  no-undo.

    assign c-exec = fill("x",255).
    run FindExecutableA (input c-doc,
                         input "",
                         input-output c-exec,
                         output h-inst).

    if h-inst >= 0 and h-inst <=32 then
      run ShellExecuteA (input 0,
                         input "open",
                         input "rundll32.exe",
                         input "shell32.dll,OpenAs_RunDLL " + c-doc,
                         input "",
                         input 1,
                         output h-inst).

    run ShellExecuteA (input 0,
                       input "open",
                       input c-doc,
                       input "",
                       input "",
                       input 1,
                       output h-inst).

    if h-inst < 0 or h-inst > 32 then return "OK".
    else return "NOK".

END PROCEDURE.

PROCEDURE FindExecutableA EXTERNAL "Shell32.dll" persistent:

    define input parameter lpFile as char  no-undo.
    define input parameter lpDirectory as char  no-undo.
    define input-output parameter lpResult as char  no-undo.
    define return parameter hInstance as long.

END PROCEDURE.

PROCEDURE ShellExecuteA EXTERNAL "Shell32.dll" persistent:

    define input parameter hwnd as long.
    define input parameter lpOperation as char  no-undo.
    define input parameter lpFile as char  no-undo.
    define input parameter lpParameters as char  no-undo.
    define input parameter lpDirectory as char  no-undo.
    define input parameter nShowCmd as long.
    define return parameter hInstance as long.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE adm-create-objects w-livre  _ADM-CREATE-OBJECTS
PROCEDURE adm-create-objects :
/*------------------------------------------------------------------------------
  Purpose:     Create handles for all SmartObjects used in this procedure.
               After SmartObjects are initialized, then SmartLinks are added.
  Parameters:  <none>
------------------------------------------------------------------------------*/
  DEFINE VARIABLE adm-current-page  AS INTEGER NO-UNDO.

  RUN get-attribute IN THIS-PROCEDURE ('Current-Page':U).
  ASSIGN adm-current-page = INTEGER(RETURN-VALUE).

  CASE adm-current-page: 

    WHEN 0 THEN DO:
       RUN init-object IN THIS-PROCEDURE (
             INPUT  'panel/p-exihel.w':U ,
             INPUT  FRAME f-cad:HANDLE ,
             INPUT  'Edge-Pixels = 2,
                     SmartPanelType = NAV-ICON,
                     Right-to-Left = First-On-Left':U ,
             OUTPUT h_p-exihel ).
       RUN set-position IN h_p-exihel ( 1.13 , 161.00 ) NO-ERROR.
       /* Size in UIB:  ( 1.25 , 16.00 ) */

       /* Links to SmartPanel h_p-exihel. */
       RUN add-link IN adm-broker-hdl ( h_p-exihel , 'State':U , THIS-PROCEDURE ).

       /* Adjust the tab order of the smart objects. */
       RUN adjust-tab-order IN adm-broker-hdl ( h_p-exihel ,
             c-cod-estabel-ini:HANDLE IN FRAME f-cad , 'BEFORE':U ).
    END. /* Page 0 */

  END CASE.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE adm-row-available w-livre  _ADM-ROW-AVAILABLE
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI w-livre  _DEFAULT-DISABLE
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
  IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(w-livre)
  THEN DELETE WIDGET w-livre.
  IF THIS-PROCEDURE:PERSISTENT THEN DELETE PROCEDURE THIS-PROCEDURE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI w-livre  _DEFAULT-ENABLE
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
  DISPLAY c-cod-estabel-ini c-cod-estabel-fim c-adm-cartao-ini c-adm-cartao-fim 
          dt-emissao-ini dt-emissao-fim nr-nota-fis-ini nr-nota-fis-fim 
          c-cod-portador-ini c-cod-portador-fim 
      WITH FRAME f-cad IN WINDOW w-livre.
  ENABLE rt-button c-cod-estabel-ini c-cod-estabel-fim c-adm-cartao-ini 
         c-adm-cartao-fim dt-emissao-ini dt-emissao-fim nr-nota-fis-ini 
         nr-nota-fis-fim c-cod-portador-ini c-cod-portador-fim bt-sel 
         br-integracao bt-todos bt-nenhum bt-excel bt-dgita bt-criar 
      WITH FRAME f-cad IN WINDOW w-livre.
  {&OPEN-BROWSERS-IN-QUERY-f-cad}
  VIEW w-livre.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-destroy w-livre 
PROCEDURE local-destroy :
/*------------------------------------------------------------------------------
  Purpose:     Override standard ADM method
  Notes:       
------------------------------------------------------------------------------*/

  /* Code placed here will execute PRIOR to standard behavior. */

  /* Dispatch standard ADM method.                             */
  RUN dispatch IN THIS-PROCEDURE ( INPUT 'destroy':U ) .
  {include/i-logfin.i}

  /* Code placed here will execute AFTER standard behavior.    */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-exit w-livre 
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-initialize w-livre 
PROCEDURE local-initialize :
/*------------------------------------------------------------------------------
  Purpose:     Override standard ADM method
  Notes:       
------------------------------------------------------------------------------*/

  /* Code placed here will execute PRIOR to standard behavior. */
  run pi-before-initialize.

  {include/win-size.i}

  {utp/ut9000.i "ESAPI560" "TOTVS"}

  /* Dispatch standard ADM method.                             */
  RUN dispatch IN THIS-PROCEDURE ( INPUT 'initialize':U ) .

  /* Code placed here will execute AFTER standard behavior.    */

  run pi-after-initialize.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-excel w-livre 
PROCEDURE pi-excel :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    DEF BUFFER bf-bv-fat-duplic  FOR es-bv-fat-duplic.
    DEF BUFFER bf-cst_fat_duplic FOR cst_fat_duplic.

    DEF VAR excelAppl  AS COM-HANDLE NO-UNDO.
    DEF VAR chquery    AS COM-HANDLE NO-UNDO.

    DEF VAR c-arquivo  AS c          NO-UNDO.

    DEF VAR i AS i      NO-UNDO.
    DEF VAR h AS HANDLE NO-UNDO.
    RUN utp/ut-acomp.p PERSISTENT SET h.
    RUN pi-inicializar IN h ("").


    ASSIGN
       c-arquivo = SESSION:TEMP-DIRECTORY 
                 + "ESAPI501-"
                 + STRING(TIME)
                 + ".csv"
                 .
    
        
    OUTPUT TO VALUE(c-arquivo) PAGE-SIZE 0 CONVERT TARGET "iso8859-1".

    PUT
       "Filial"               CHR(9)
       "Parcela"              CHR(9)
       "Cupom"                CHR(9)
       "Parcela"              CHR(9)
       "Administradora"       CHR(9)
       "NSU"                  CHR(9)
       "Banco"                CHR(9)
       "Agància"              CHR(9)
       "Conta"                CHR(9)
       "Portador"             CHR(9)
       "Emiss∆o"              CHR(9)
       "Venc Datasul"         CHR(9)
       "Venc Boa Vista"       CHR(9)
       "Dt Pagto"             CHR(9)
       "Vl Datasul (bruto)"   CHR(9)
       "Vl Boa Vista (bruto)" CHR(9)
       "Taxa Datasul"         CHR(9)
       "Taxa Boa Vista"       CHR(9)
       "Vl Pago"              CHR(9)
       SKIP.

    FOR EACH bf-bv-fat-duplic NO-LOCK
       WHERE bf-bv-fat-duplic.cod-estabel  >= c-cod-estabel-ini :INPUT-VALUE IN FRAME f-cad
         AND bf-bv-fat-duplic.cod-estabel  <= c-cod-estabel-fim :INPUT-VALUE IN FRAME f-cad
         AND bf-bv-fat-duplic.dt-emissao   >= dt-emissao-ini    :INPUT-VALUE IN FRAME f-cad
         AND bf-bv-fat-duplic.dt-emissao   <= dt-emissao-fim    :INPUT-VALUE IN FRAME f-cad
         AND bf-bv-fat-duplic.nr-fatura    >= nr-nota-fis-ini   :INPUT-VALUE IN FRAME f-cad
         AND bf-bv-fat-duplic.nr-fatura    <= nr-nota-fis-fim   :INPUT-VALUE IN FRAME f-cad
         AND bf-bv-fat-duplic.adm_cartao   >= c-adm-cartao-ini  :INPUT-VALUE IN FRAME f-cad
         AND bf-bv-fat-duplic.adm_cartao   <= c-adm-cartao-fim  :INPUT-VALUE IN FRAME f-cad
         AND bf-bv-fat-duplic.ind-envio    =  3,
       FIRST bf-cst_fat_duplic NO-LOCK
       WHERE bf-cst_fat_duplic.cod_estabel =  bf-bv-fat-duplic.cod-estabel
         AND bf-cst_fat_duplic.serie       =  bf-bv-fat-duplic.serie
         AND bf-cst_fat_duplic.nr_fatura   =  bf-bv-fat-duplic.nr-fatura
         AND bf-cst_fat_duplic.parcela     =  bf-bv-fat-duplic.parcela,
       FIRST es-bv-depara NO-LOCK 
       WHERE es-bv-depara.cod-de           =  es-bv-fat-duplic.conta
         AND es-bv-depara.cod-para         >= c-cod-portador-ini:INPUT-VALUE IN FRAME f-cad
         AND es-bv-depara.cod-para         <= c-cod-portador-fim:INPUT-VALUE IN FRAME f-cad
       ON STOP UNDO, LEAVE:
       ASSIGN
          i = i + 1.
       IF i / 10 = INT(i / 10)
       THEN RUN pi-acompanhar IN h (STRING(i)).

       PUT
          es-bv-fat-duplic.cod-estabel                FORMAT "x(5)":U            CHR(9)
          es-bv-fat-duplic.serie                      FORMAT "x(5)":U            CHR(9)
          es-bv-fat-duplic.nr-fatura                  FORMAT "x(16)":U           CHR(9)
          es-bv-fat-duplic.parcela                    FORMAT "x(02)":U           CHR(9)
          es-bv-fat-duplic.adm_cartao                                            CHR(9)
          cst_fat_duplic.nsu_numero                                              CHR(9)
          es-bv-fat-duplic.banco                                                 CHR(9)
          es-bv-fat-duplic.agencia                    FORMAT "x(10)"             CHR(9)
          es-bv-fat-duplic.conta                      FORMAT "x(16)"             CHR(9)
          es-bv-depara.cod-para                                                  CHR(9)
          es-bv-fat-duplic.dt-emissao                 FORMAT "99/99/9999":U      CHR(9)
          es-bv-fat-duplic.dt-venciment               FORMAT "99/99/9999":U      CHR(9)
          es-bv-fat-duplic.ret-dt-venciment           FORMAT "99/99/9999":U      CHR(9)
          es-bv-fat-duplic.dt-pagto                   FORMAT "99/99/9999":U      CHR(9)
          es-bv-fat-duplic.vl-parcela                 FORMAT ">>>,>>>,>>9.99":U  CHR(9)
          es-bv-fat-duplic.ret-vl-parcela             FORMAT ">>>,>>>,>>9.99":U  CHR(9)
          es-bv-fat-duplic.vl-taxa                    FORMAT ">,>>9.99":U        CHR(9)
          es-bv-fat-duplic.ret-vl-taxa                FORMAT ">,>>9.99":U        CHR(9)
          es-bv-fat-duplic.ret-vl-pago                FORMAT ">,>>9.99":U        CHR(9)
          SKIP.
    END.
    OUTPUT CLOSE.
    
    CREATE "Excel.Application" excelAppl.
    excelAppl:SheetsInNewWorkbook = 1.
    excelAppl:Workbooks:ADD.
    excelAppl:Sheets(1):SELECT.
    excelAppl:range("a1"):SELECT.
    chquery = excelAppl:activesheet:QueryTables:ADD("TEXT;" + SEARCH(c-arquivo),excelAppl:range("a1")).
    chquery:REFRESH().
    excelAppl:Cells:EntireColumn:Autofit.
    excelAppl:VISIBLE = YES.
    RELEASE OBJECT chquery.
    RELEASE OBJECT excelAppl.
    RUN pi-finalizar IN h.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-liquida w-livre 
PROCEDURE pi-liquida :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
   IF lFir = NO
   THEN DO:
       /*
       ASSIGN
          c-refer-lote = "BV" +        STRING(  DAY(TODAY),"99"  )
                              +        STRING(MONTH(TODAY),"99"  )
                              + SUBSTR(STRING( YEAR(TODAY),"9999"),3)
                              +        STRING(TIME,"HH:MM:SS").
       */
       CREATE tt_integr_acr_liquidac_lote.
       ASSIGN tt_integr_acr_liquidac_lote.tta_cod_refer                   = tt-lote.c-refer-lote
              tt_integr_acr_liquidac_lote.tta_cod_empresa                 = tit_acr.cod_empresa
              tt_integr_acr_liquidac_lote.tta_cod_estab_refer             = "973"
              tt_integr_acr_liquidac_lote.tta_cod_usuario                 = v_cod_usuar_corren
              //tt_integr_acr_liquidac_lote.tta_cod_portador                = tit_acr.cod_portador
              //tt_integr_acr_liquidac_lote.tta_cod_cart_bcia               = tit_acr.cod_cart_bcia
              tt_integr_acr_liquidac_lote.tta_dat_gerac_lote_liquidac     = es-bv-fat-duplic.dt-pagto
              tt_integr_acr_liquidac_lote.tta_dat_transacao               = TODAY
              tt_integr_acr_liquidac_lote.tta_val_tot_lote_liquidac_infor = 0 
              tt_integr_acr_liquidac_lote.tta_val_tot_lote_liquidac_efetd = 0  
              tt_integr_acr_liquidac_lote.tta_val_tot_despes_bcia         = 0 
              tt_integr_acr_liquidac_lote.tta_ind_tip_liquidac_acr        = "Autom†tica"
              tt_integr_acr_liquidac_lote.tta_ind_sit_lote_liquidac_acr   = "Em digitaá∆o"
              tt_integr_acr_liquidac_lote.tta_nom_arq_movimen_bcia        = ""
              tt_integr_acr_liquidac_lote.tta_cdn_cliente                 = 0
              tt_integr_acr_liquidac_lote.tta_log_enctro_cta              = NO   
              tt_integr_acr_liquidac_lote.ttv_log_atualiz_refer           = NO
              tt_integr_acr_liquidac_lote.ttv_log_gera_lote_parcial       = NO
              tt_integr_acr_liquidac_lote.ttv_rec_lote_liquidac_acr       = RECID(tt_integr_acr_liquidac_lote)
              //tt_integr_acr_liquidac_lote.ttv_cod_indic_econ              = tit_acr.cod_indic_econ
              .
       ASSIGN
          lFir = YES.
   END.

   CREATE tt_integr_acr_liq_item_lote_3.
   ASSIGN tt_integr_acr_liq_item_lote_3.tta_cod_empresa                = tit_acr.cod_empresa    
          tt_integr_acr_liq_item_lote_3.tta_cod_estab                  = tit_acr.cod_estab      
          tt_integr_acr_liq_item_lote_3.tta_cod_espec_docto            = tit_acr.cod_espec_docto
          tt_integr_acr_liq_item_lote_3.tta_cod_ser_docto              = tit_acr.cod_ser_docto  
          tt_integr_acr_liq_item_lote_3.tta_cod_tit_acr                = tit_acr.cod_tit_acr    
          tt_integr_acr_liq_item_lote_3.tta_cod_parcela                = tit_acr.cod_parcela    
          tt_integr_acr_liq_item_lote_3.tta_cdn_cliente                = tit_acr.cdn_cliente    
          tt_integr_acr_liq_item_lote_3.tta_cod_portad_ext             = ""
          tt_integr_acr_liq_item_lote_3.tta_cod_modalid_ext            = ""
          tt_integr_acr_liq_item_lote_3.tta_cod_portador               = ems5.portador.cod_portador
          tt_integr_acr_liq_item_lote_3.tta_cod_cart_bcia              = tit_acr.cod_cart_bcia

          tt_integr_acr_liq_item_lote_3.tta_cod_portador               = ems5.portador.cod_portador  
          tt_integr_acr_liq_item_lote_3.tta_cod_cart_bcia              = tit_acr.cod_cart_bcia
          tt_integr_acr_liq_item_lote_3.tta_cod_finalid_econ           = "Corrente"
          tt_integr_acr_liq_item_lote_3.tta_cod_indic_econ             = tit_acr.cod_indic_econ
          tt_integr_acr_liq_item_lote_3.tta_val_tit_acr                = tit_acr.val_sdo_tit_acr 
          tt_integr_acr_liq_item_lote_3.tta_val_liquidac_tit_acr       = es-bv-fat-duplic.ret-vl-pago
          tt_integr_acr_liq_item_lote_3.tta_dat_cr_liquidac_tit_acr    = es-bv-fat-duplic.dt-pagto
          tt_integr_acr_liq_item_lote_3.tta_dat_cr_liquidac_calc       = es-bv-fat-duplic.dt-pagto
          tt_integr_acr_liq_item_lote_3.tta_dat_liquidac_tit_acr       = es-bv-fat-duplic.dt-pagto
          //tt_integr_acr_liq_item_lote_3.tta_cod_autoriz_bco            = ext_movto_tit_acr.cod_autoriz_bco
          //tt_integr_acr_liq_item_lote_3.tta_val_abat_tit_acr           = ext_movto_tit_acr.val_abat_tit_acr
          //tt_integr_acr_liq_item_lote_3.tta_val_despes_bcia            = ext_movto_tit_acr.val_despes_bcia
          //tt_integr_acr_liq_item_lote_3.tta_val_multa_tit_acr          = ext_movto_tit_acr.val_multa_tit_acr
          //tt_integr_acr_liq_item_lote_3.tta_val_juros                  = ext_movto_tit_acr.val_juros
          //tt_integr_acr_liq_item_lote_3.tta_val_cm_tit_acr             = ext_movto_tit_acr.val_cm_tit_acr
          tt_integr_acr_liq_item_lote_3.tta_val_liquidac_orig          = 0
          tt_integr_acr_liq_item_lote_3.tta_val_desc_tit_acr_orig      = 0
          tt_integr_acr_liq_item_lote_3.tta_val_abat_tit_acr_orig      = 0
          tt_integr_acr_liq_item_lote_3.tta_val_despes_bcia_orig       = 0
          tt_integr_acr_liq_item_lote_3.tta_val_multa_tit_acr_origin   = 0
          tt_integr_acr_liq_item_lote_3.tta_val_juros_tit_acr_orig     = 0
          tt_integr_acr_liq_item_lote_3.tta_val_cm_tit_acr_orig        = 0
          tt_integr_acr_liq_item_lote_3.tta_val_nota_db_orig           = 0
          tt_integr_acr_liq_item_lote_3.tta_log_gera_antecip           = NO
          tt_integr_acr_liq_item_lote_3.tta_des_text_histor            = ""
          tt_integr_acr_liq_item_lote_3.tta_ind_sit_item_lote_liquidac = ""
          tt_integr_acr_liq_item_lote_3.tta_log_gera_avdeb             = NO
          tt_integr_acr_liq_item_lote_3.tta_cod_indic_econ_avdeb       = ""
          tt_integr_acr_liq_item_lote_3.tta_cod_portad_avdeb           = ""
          tt_integr_acr_liq_item_lote_3.tta_cod_cart_bcia_avdeb        = "" 
          tt_integr_acr_liq_item_lote_3.tta_dat_vencto_avdeb           = ?
          tt_integr_acr_liq_item_lote_3.tta_val_perc_juros_avdeb       = 0
          tt_integr_acr_liq_item_lote_3.tta_val_avdeb                  = 0
          tt_integr_acr_liq_item_lote_3.tta_log_movto_comis_estordo    = NO
          tt_integr_acr_liq_item_lote_3.tta_ind_tip_item_liquidac_acr = "Pagamento"
          tt_integr_acr_liq_item_lote_3.tta_ind_tip_calc_juros         = "Simples"
          tt_integr_acr_liq_item_lote_3.ttv_rec_lote_liquidac_acr      = tt_integr_acr_liquidac_lote.ttv_rec_lote_liquidac_acr
          tt_integr_acr_liq_item_lote_3.ttv_rec_item_lote_liquidac_acr = RECID(tt_integr_acr_liq_item_lote_3).

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-run w-livre 
PROCEDURE pi-run :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
   DEF INPUT  PARAMETER c-pesquisa  AS c      NO-UNDO.
   DEF OUTPUT PARAMETER h-handle    AS HANDLE NO-UNDO.
   DEF VAR              h-current   AS HANDLE NO-UNDO.

   ASSIGN
       h-current = SESSION:FIRST-PROCEDURE
       h-handle = ?.
   DO WHILE VALID-HANDLE(h-current):
      IF INDEX(h-current:FILE-NAME, c-pesquisa) > 0
      THEN ASSIGN
         h-handle = h-current.
      ASSIGN
         h-current = h-current:NEXT-SIBLING.
   END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE send-records w-livre  _ADM-SEND-RECORDS
PROCEDURE send-records :
/*------------------------------------------------------------------------------
  Purpose:     Send record ROWID's for all tables used by
               this file.
  Parameters:  see template/snd-head.i
------------------------------------------------------------------------------*/

  /* Define variables needed by this internal procedure.               */
  {src/adm/template/snd-head.i}

  /* For each requested table, put it's ROWID in the output list.      */
  {src/adm/template/snd-list.i "es-bv-fat-duplic"}
  {src/adm/template/snd-list.i "cst_fat_duplic"}
  {src/adm/template/snd-list.i "tit_acr_cartao"}
  {src/adm/template/snd-list.i "es-bv-depara"}

  /* Deal with any unexpected table requests before closing.           */
  {src/adm/template/snd-end.i}

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE state-changed w-livre 
PROCEDURE state-changed :
/*:T -----------------------------------------------------------
  Purpose:     Manuseia trocas de estado dos SmartObjects
  Parameters:  <none>
  Notes:       
-------------------------------------------------------------*/
  DEFINE INPUT PARAMETER p-issuer-hdl AS HANDLE NO-UNDO.
  DEFINE INPUT PARAMETER p-state AS CHARACTER NO-UNDO.

  run pi-trata-state (p-issuer-hdl, p-state).
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION fc-sel w-livre 
FUNCTION fc-sel RETURNS CHARACTER
  ( /* parameter-definitions */ ) :
/*------------------------------------------------------------------------------
  Purpose:  
    Notes:  
------------------------------------------------------------------------------*/
  IF AVAIL es-bv-fat-duplic
  THEN DO:
     FIND FIRST tt-sel
          WHERE tt-sel.rw = ROWID(es-bv-fat-duplic)
          NO-ERROR.
     IF AVAIL tt-sel
     THEN RETURN "*".
  END.
  RETURN "".   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

