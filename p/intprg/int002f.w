&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI ADM1
&ANALYZE-RESUME
/* Connected Databases 
*/
&Scoped-define WINDOW-NAME w-consim
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS w-consim 
/*:T *******************************************************************************
** Copyright DATASUL S.A. (1997)
** Todos os Direitos Reservados.
**
** Este fonte e de propriedade exclusiva da DATASUL, sua reproducao
** parcial ou total por qualquer meio, so podera ser feita mediante
** autorizacao expressa.
*******************************************************************************/
{include/i-prgvrs.i Int002f 2.06.00.001}

/* Create an unnamed pool to store all the widgets created 
     by this procedure. This is a good default which assures
     that this procedure's triggers and internal procedures 
     will execute in this procedure's storage, and that proper
     cleanup will occur on deletion of the procedure. */

CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */
{intprg/int002.i}   /* tt-param-nissei  tt-nota-xml */
{intprg/int002c.i} /* tt-docum-est-xml tt-item-doc-est-xml */

DEF TEMP-TABLE tt-nota no-undo
FIELD situacao     AS INTEGER
FIELD nro-docto    LIKE docum-est.nro-docto   
FIELD serie-nota   LIKE docum-est.serie-docto
FIELD serie-docum  LIKE docum-est.serie-docto        
FIELD cod-emitente LIKE docum-est.cod-emitente
FIELD nat-operacao LIKE docum-est.nat-operacao
FIELD valor-mercad LIKE doc-fisico.valor-mercad.
/***** Integracao com o re1001 ********/

{inbo/boin090.i tt-docum-est}       /* Defini»’o TT-DOCUM-EST       */
{inbo/boin176.i tt-item-doc-est}    /* Defini»’o TT-ITEM-DOC-EST    */

{method/dbotterr.i }               /* Defini»’o RowErrors          */
{cdp/cd0666.i}                     /* Definicao tt-erro */
                              
/* Parameters Definitions ---                                      */

/* Local Variable Definitions ---                                  */
DEF VAR hProgramZoom AS HANDLE                    NO-UNDO.
DEF VAR i-seq-item   AS INTEGER                   NO-UNDO.
DEF VAR d-tot-nota   LIKE doc-fisico.valor-mercad NO-UNDO.
DEF VAR i-seq-erro   AS INTEGER                   NO-UNDO.
DEF VAR c-desc-erro  AS CHAR                      NO-UNDO.
DEF VAR c-cod-depos  AS CHAR                      NO-UNDO.
DEF VAR c-comando    AS CHAR                      NO-UNDO.
DEF VAR r-rowid      AS ROWID                     NO-UNDO.
DEF VAR c-desc-situacao AS CHAR.

DEF BUFFER b-it-doc-fisico    FOR it-doc-fisico.
DEF BUFFER b-int-ds-docto-xml FOR int-ds-docto-xml.

{utp/ut-glob.i}

define temp-table tt-param no-undo
    field destino          as integer
    field arquivo          as char format "x(35)":U
    field usuario          as char format "x(12)":U
    field data-exec        as date
    field hora-exec        as integer
    field classifica       as integer
    field desc-classifica  as char format "x(40)":U
    field modelo           AS char format "x(35)":U
    field l-habilitaRtf    as LOG
    FIELD dt-trans-ini     LIKE docum-est.dt-trans
    FIELD dt-trans-fin     LIKE docum-est.dt-trans
    FIELD i-nro-docto-ini  LIKE docum-est.nro-docto
    FIELD i-nro-docto-fin  LIKE docum-est.nro-docto
    FIELD i-cod-emit-ini   LIKE docum-est.cod-emitente
    FIELD i-cod-emit-fin   LIKE docum-est.cod-emitente.

DEFINE TEMP-TABLE tt-digita
    FIELD arquivo AS CHAR
    FIELD raiz    AS CHAR 
    FIELD node    AS CHAR
    FIELD campo   AS CHAR FORMAT "X(100)"
    FIELD valor   AS CHAR FORMAT "X(100)"
    FIELD linha   AS INTEGER.

def temp-table tt-raw-digita
    field raw-digita as raw.

DEF TEMP-TABLE tt-raw-param 
 FIELD raw-param  AS RAW.

DEF VAR raw-param  AS RAW.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE w-consim
&Scoped-define DB-AWARE no

&Scoped-define ADM-CONTAINER WINDOW

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME f-cad
&Scoped-define BROWSE-NAME br-nota

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-nota-xml

/* Definitions for BROWSE br-nota                                       */
&Scoped-define FIELDS-IN-QUERY-br-nota fn-tipo-contr(tt-nota-xml.tipo-contr) tt-nota-xml.cod-estab tt-nota-xml.serie tt-nota-xml.nNF tt-nota-xml.dEmi tt-nota-xml.nat-operacao fn-situacao(tt-nota-xml.situacao) @ c-desc-situacao tt-nota-xml.cod-emitente tt-nota-xml.xnome tt-nota-xml.CNPJ   
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-nota   
&Scoped-define SELF-NAME br-nota
&Scoped-define QUERY-STRING-br-nota FOR EACH tt-nota-xml
&Scoped-define OPEN-QUERY-br-nota OPEN QUERY {&SELF-NAME} FOR EACH tt-nota-xml.
&Scoped-define TABLES-IN-QUERY-br-nota tt-nota-xml
&Scoped-define FIRST-TABLE-IN-QUERY-br-nota tt-nota-xml


/* Definitions for FRAME f-cad                                          */
&Scoped-define OPEN-BROWSERS-IN-QUERY-f-cad ~
    ~{&OPEN-QUERY-br-nota}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS dt-trans-ini dt-trans-fin i-nro-docto-ini ~
i-nro-docto-fin i-cod-emit-ini i-cod-emit-fin rs-situacao br-nota bt-filtro ~
bt-reenvio bt-erros c-estab-ini c-estab-fin c-serie-ini c-serie-fin ~
rt-button RECT-1 IMAGE-1 IMAGE-2 IMAGE-3 IMAGE-4 IMAGE-5 IMAGE-6 IMAGE-11 ~
IMAGE-12 IMAGE-13 IMAGE-14 RECT-13 
&Scoped-Define DISPLAYED-OBJECTS dt-trans-ini dt-trans-fin i-nro-docto-ini ~
i-nro-docto-fin i-cod-emit-ini i-cod-emit-fin rs-situacao c-estab-ini ~
c-estab-fin c-serie-ini c-serie-fin 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD fn-situacao w-consim 
FUNCTION fn-situacao RETURNS CHARACTER
  ( p-situacao AS INT)  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD fn-status w-consim 
FUNCTION fn-status RETURNS CHARACTER
  ( p-situacao AS INT)  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD fn-tipo-contr w-consim 
FUNCTION fn-tipo-contr RETURNS CHARACTER
  ( p-tipo-contr AS INT /* parameter-definitions */ )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR w-consim AS WIDGET-HANDLE NO-UNDO.

/* Menu Definitions                                                     */
DEFINE SUB-MENU mi-arquivo 
       MENU-ITEM mi-consultas   LABEL "Co&nsultas"     ACCELERATOR "CTRL-L"
       MENU-ITEM mi-imprimir    LABEL "&Relat¢rios"    ACCELERATOR "CTRL-P"
       RULE
       MENU-ITEM mi-sair        LABEL "&Sair"          ACCELERATOR "CTRL-X".

DEFINE SUB-MENU m_Ajuda 
       MENU-ITEM mi-conteudo    LABEL "&Conteudo"     
       MENU-ITEM mi-sobre       LABEL "&Sobre..."     .

DEFINE MENU m-cadastro MENUBAR
       SUB-MENU  mi-arquivo     LABEL "&Arquivo"      
       SUB-MENU  m_Ajuda        LABEL "&Ajuda"        .


/* Definitions of handles for SmartObjects                              */
DEFINE VARIABLE h_p-exihel AS HANDLE NO-UNDO.

/* Definitions of the field level widgets                               */
DEFINE BUTTON bt-detalhe 
     LABEL "Detalhar" 
     SIZE 13 BY 1.

DEFINE BUTTON bt-erros 
     LABEL "Erros" 
     SIZE 13 BY 1.

DEFINE BUTTON bt-filtro 
     IMAGE-UP FILE "image/im-chck1.bmp":U
     IMAGE-INSENSITIVE FILE "image/ii-chck1.bmp":U
     LABEL "Filtro" 
     SIZE 4 BY 1.25 TOOLTIP "Carrega Notas conforme os parƒmetros informados"
     FONT 4.

DEFINE BUTTON bt-reenvio 
     LABEL "Reenvio" 
     SIZE 13 BY 1.

DEFINE VARIABLE c-estab-fin AS CHARACTER FORMAT "X(03)":U INITIAL "ZZZ" 
     VIEW-AS FILL-IN 
     SIZE 5 BY .88 NO-UNDO.

DEFINE VARIABLE c-estab-ini AS CHARACTER FORMAT "X(03)":U 
     LABEL "Estab." 
     VIEW-AS FILL-IN 
     SIZE 5 BY .88 NO-UNDO.

DEFINE VARIABLE c-serie-fin AS CHARACTER FORMAT "X(05)":U INITIAL "ZZZZZ" 
     VIEW-AS FILL-IN 
     SIZE 6.14 BY .88 NO-UNDO.

DEFINE VARIABLE c-serie-ini AS CHARACTER FORMAT "X(05)":U 
     LABEL "S‚rie" 
     VIEW-AS FILL-IN 
     SIZE 6.14 BY .88 NO-UNDO.

DEFINE VARIABLE dt-trans-fin AS DATE FORMAT "99/99/9999":U INITIAL 12/31/9999 
     VIEW-AS FILL-IN 
     SIZE 10.86 BY .88 NO-UNDO.

DEFINE VARIABLE dt-trans-ini AS DATE FORMAT "99/99/9999":U INITIAL 01/01/001 
     LABEL "Dt EmissÆo" 
     VIEW-AS FILL-IN 
     SIZE 10.86 BY .88 NO-UNDO.

DEFINE VARIABLE i-cod-emit-fin AS INTEGER FORMAT ">>>>>>>>9":U INITIAL 99999999 
     VIEW-AS FILL-IN 
     SIZE 11 BY .88 NO-UNDO.

DEFINE VARIABLE i-cod-emit-ini AS INTEGER FORMAT ">>>>>>>>9":U INITIAL 0 
     LABEL "Fornecedor" 
     VIEW-AS FILL-IN 
     SIZE 11 BY .88 NO-UNDO.

DEFINE VARIABLE i-nro-docto-fin AS INTEGER FORMAT "99999999":U INITIAL 99999999 
     VIEW-AS FILL-IN 
     SIZE 9.43 BY .88 NO-UNDO.

DEFINE VARIABLE i-nro-docto-ini AS INTEGER FORMAT "99999999":U INITIAL 0 
     LABEL "Nota Fiscal" 
     VIEW-AS FILL-IN 
     SIZE 9.43 BY .88 NO-UNDO.

DEFINE IMAGE IMAGE-1
     FILENAME "image\im-fir":U
     SIZE 3 BY .88.

DEFINE IMAGE IMAGE-11
     FILENAME "image\im-fir":U
     SIZE 3 BY .88.

DEFINE IMAGE IMAGE-12
     FILENAME "image\im-las":U
     SIZE 3 BY .88.

DEFINE IMAGE IMAGE-13
     FILENAME "image\im-fir":U
     SIZE 3 BY .88.

DEFINE IMAGE IMAGE-14
     FILENAME "image\im-las":U
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

DEFINE VARIABLE rs-situacao AS INTEGER 
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS 
          "Pendente", 1,
"Liberado", 2,
"Atualizado", 3,
"Todas", 4
     SIZE 10 BY 3.17 NO-UNDO.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 107 BY 6.08.

DEFINE RECTANGLE RECT-13
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 14 BY 4.

DEFINE RECTANGLE rt-button
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 18.14 BY 1.83.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-nota FOR 
      tt-nota-xml SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-nota
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-nota w-consim _FREEFORM
  QUERY br-nota DISPLAY
      fn-tipo-contr(tt-nota-xml.tipo-contr)  FORMAT "x(12)" LABEL "Origem"
tt-nota-xml.cod-estab    FORMAT "x(03)"     LABEL "Estab"
tt-nota-xml.serie        FORMAT "x(03)"     LABEL "Serie"
tt-nota-xml.nNF          FORMAT "x(10)"     LABEL "NFE"  
tt-nota-xml.dEmi         FORMAT 99/99/9999  LABEL "Dt Emissao" 
tt-nota-xml.nat-operacao FORMAT "x(05)"     LABEL "Natureza"
fn-situacao(tt-nota-xml.situacao) @ c-desc-situacao LABEL "Situa‡Æo" FORMAT "x(12)"
tt-nota-xml.cod-emitente LABEL "Fornecedor"
tt-nota-xml.xnome    LABEL "Nome" FORMAT "x(40)"
tt-nota-xml.CNPJ     FORMAT "x(19)"     LABEL "CNPJ"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 106 BY 14
         FONT 1.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME f-cad
     dt-trans-ini AT ROW 5.5 COL 11 COLON-ALIGNED WIDGET-ID 26
     dt-trans-fin AT ROW 5.5 COL 30 COLON-ALIGNED NO-LABEL WIDGET-ID 24
     i-nro-docto-ini AT ROW 4.5 COL 11 COLON-ALIGNED WIDGET-ID 34
     i-nro-docto-fin AT ROW 4.5 COL 30.14 COLON-ALIGNED NO-LABEL WIDGET-ID 40
     i-cod-emit-ini AT ROW 1.5 COL 4.57 WIDGET-ID 50
     i-cod-emit-fin AT ROW 1.5 COL 30 COLON-ALIGNED NO-LABEL WIDGET-ID 42
     rs-situacao AT ROW 3.04 COL 51 NO-LABEL WIDGET-ID 52
     br-nota AT ROW 7.5 COL 2 WIDGET-ID 200
     bt-filtro AT ROW 5.25 COL 64 HELP
          "Carrega Notas conforme os parƒmetros informados" WIDGET-ID 58
     bt-detalhe AT ROW 21.75 COL 2 WIDGET-ID 68
     bt-reenvio AT ROW 21.75 COL 15.72 WIDGET-ID 70
     bt-erros AT ROW 21.75 COL 29.43 WIDGET-ID 72
     c-estab-ini AT ROW 2.5 COL 7.86 WIDGET-ID 82
     c-estab-fin AT ROW 2.5 COL 30 COLON-ALIGNED NO-LABEL WIDGET-ID 80
     c-serie-ini AT ROW 3.5 COL 8.71 WIDGET-ID 88
     c-serie-fin AT ROW 3.5 COL 30 COLON-ALIGNED NO-LABEL WIDGET-ID 90
     "Situa‡Æo" VIEW-AS TEXT
          SIZE 7 BY .54 AT ROW 2.21 COL 50 WIDGET-ID 96
     rt-button AT ROW 1.17 COL 90.14
     RECT-1 AT ROW 1.17 COL 2 WIDGET-ID 22
     IMAGE-1 AT ROW 5.5 COL 24.86 WIDGET-ID 28
     IMAGE-2 AT ROW 5.5 COL 28.43 WIDGET-ID 30
     IMAGE-3 AT ROW 4.5 COL 24.86 WIDGET-ID 36
     IMAGE-4 AT ROW 4.5 COL 28.57 WIDGET-ID 38
     IMAGE-5 AT ROW 1.5 COL 24.72 WIDGET-ID 46
     IMAGE-6 AT ROW 1.5 COL 28.57 WIDGET-ID 48
     IMAGE-11 AT ROW 2.5 COL 24.72 WIDGET-ID 84
     IMAGE-12 AT ROW 2.5 COL 28.57 WIDGET-ID 86
     IMAGE-13 AT ROW 3.5 COL 24.72 WIDGET-ID 92
     IMAGE-14 AT ROW 3.5 COL 28.57 WIDGET-ID 94
     RECT-13 AT ROW 2.5 COL 49 WIDGET-ID 98
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 133.72 BY 27.13
         FONT 1 WIDGET-ID 100.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: w-consim
   Allow: Basic,Browse,DB-Fields,Smart,Window,Query
   Container Links: 
   Add Fields to: Neither
   Other Settings: COMPILE
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
IF SESSION:DISPLAY-TYPE = "GUI":U THEN
  CREATE WINDOW w-consim ASSIGN
         HIDDEN             = YES
         TITLE              = "Monitor Integra‡Æo"
         HEIGHT             = 21.88
         WIDTH              = 108.57
         MAX-HEIGHT         = 29.29
         MAX-WIDTH          = 195.14
         VIRTUAL-HEIGHT     = 29.29
         VIRTUAL-WIDTH      = 195.14
         RESIZE             = no
         SCROLL-BARS        = no
         STATUS-AREA        = yes
         BGCOLOR            = ?
         FGCOLOR            = ?
         THREE-D            = yes
         MESSAGE-AREA       = no
         SENSITIVE          = yes.
ELSE {&WINDOW-NAME} = CURRENT-WINDOW.

ASSIGN {&WINDOW-NAME}:MENUBAR    = MENU m-cadastro:HANDLE.
/* END WINDOW DEFINITION                                                */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _INCLUDED-LIB w-consim 
/* ************************* Included-Libraries *********************** */

{src/adm/method/containr.i}
{include/w-livre.i}
  
{utp/ut-glob.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME




/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW w-consim
  VISIBLE,,RUN-PERSISTENT                                               */
/* SETTINGS FOR FRAME f-cad
   FRAME-NAME Custom                                                    */
/* BROWSE-TAB br-nota rs-situacao f-cad */
/* SETTINGS FOR BUTTON bt-detalhe IN FRAME f-cad
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN c-estab-ini IN FRAME f-cad
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN c-serie-ini IN FRAME f-cad
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN i-cod-emit-ini IN FRAME f-cad
   ALIGN-L                                                              */
IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(w-consim)
THEN w-consim:HIDDEN = yes.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-nota
/* Query rebuild information for BROWSE br-nota
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH tt-nota-xml.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE br-nota */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME w-consim
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL w-consim w-consim
ON END-ERROR OF w-consim /* Monitor Integra‡Æo */
OR ENDKEY OF {&WINDOW-NAME} ANYWHERE DO:
  /* This case occurs when the user presses the "Esc" key.
     In a persistently run window, just ignore this.  If we did not, the
     application would exit. */
  RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL w-consim w-consim
ON WINDOW-CLOSE OF w-consim /* Monitor Integra‡Æo */
DO:
  /* This ADM code must be left here in order for the SmartWindow
     and its descendents to terminate properly on exit. */
  APPLY "CLOSE":U TO THIS-PROCEDURE.
  RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-nota
&Scoped-define SELF-NAME br-nota
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-nota w-consim
ON ROW-DISPLAY OF br-nota IN FRAME f-cad
DO:
  IF AVAIL tt-nota-xml THEN DO:

      IF tt-nota-xml.situacao = 1 THEN
         ASSIGN c-desc-situacao:BGCOLOR IN BROWSE br-nota = 12.
      ELSE IF tt-nota-xml.situacao = 2 THEN
         ASSIGN c-desc-situacao:BGCOLOR IN BROWSE br-nota = 14.
      ELSE 
          ASSIGN c-desc-situacao:BGCOLOR IN BROWSE br-nota = 2.

           
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-nota w-consim
ON VALUE-CHANGED OF br-nota IN FRAME f-cad
DO:
  IF br-nota:NUM-ITERATIONS > 0
  THEN DO:
     br-nota:SELECT-FOCUSED-ROW().
        
    
  END.  

  
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-erros
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-erros w-consim
ON CHOOSE OF bt-erros IN FRAME f-cad /* Erros */
DO:
  
  IF br-nota:NUM-ITERATIONS > 0
  THEN DO:
        br-nota:SELECT-FOCUSED-ROW().
        
        if AVAIL tt-nota-xml then do:
           EMPTY TEMP-TABLE tt-erro.
           
           ASSIGN i-seq-erro = 0.

           FOR EACH int-ds-doc-erro NO-LOCK WHERE
                    int-ds-doc-erro.serie-docto  = tt-nota-xml.serie        AND 
                    int-ds-doc-erro.cod-emitente = tt-nota-xml.cod-emitente AND
                    int-ds-doc-erro.CNPJ         = tt-nota-xml.CNPJ         AND        
                    int-ds-doc-erro.nro-docto    = tt-nota-xml.nNF          AND 
                    int-ds-doc-erro.tipo-nota    = tt-nota-xml.tipo-nota
               BY int-ds-doc-erro.cod-erro :
                 
                CREATE tt-erro.
                ASSIGN i-seq-erro        = i-seq-erro + 1 
                       tt-erro.i-sequen  = i-seq-erro
                       tt-erro.cd-erro   = int-ds-doc-erro.cod-erro
                       tt-erro.mensagem  = int-ds-doc-erro.descricao. 

           END. 

           IF i-seq-erro > 0 THEN  
               run cdp/cd0666.w (input table tt-erro).
        
        END.
  END.
 
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-filtro
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-filtro w-consim
ON CHOOSE OF bt-filtro IN FRAME f-cad /* Filtro */
DO:
  RUN pi-carregaNota.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-reenvio
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-reenvio w-consim
ON CHOOSE OF bt-reenvio IN FRAME f-cad /* Reenvio */
DO:
   IF AVAIL tt-nota-xml AND 
            tt-nota-xml.situacao <> 3 
   THEN DO:
   
        for each tt-raw-digita:
            delete tt-raw-digita.
        end.
    
        CREATE tt-param.
        ASSIGN tt-param.destino         = 2                              
               tt-param.arquivo         = SESSION:TEMP-DIRECTORY + "\" + "int002brp.txt"       
               tt-param.usuario         = c-seg-usuario       
               tt-param.data-exec       = TODAY  
               tt-param.hora-exec       = TIME      
               tt-param.dt-trans-ini    = tt-nota-xml.DEmi 
               tt-param.dt-trans-fin    = tt-nota-xml.DEmi
               tt-param.i-nro-docto-ini = tt-nota-xml.nNF 
               tt-param.i-nro-docto-fin = tt-nota-xml.nNF
               tt-param.i-cod-emit-ini  = tt-nota-xml.cod-emitente
               tt-param.i-cod-emit-fin  = tt-nota-xml.cod-emitente. 

        FOR FIRST int-ds-docto-xml NO-LOCK where 
                  int-ds-docto-xml.serie         =  tt-nota-xml.serie         AND
                  int-ds-docto-xml.nNf           =  tt-nota-xml.nNF           AND
                  int-ds-docto-xml.cod-emitente  =  tt-nota-xml.cod-emitente  AND
                  int-ds-docto-xml.tipo-nota     =  int-ds-docto-xml.tipo-nota,
            FIRST int-ds-it-docto-xml NO-LOCK WHERE
                  int-ds-it-docto-xml.serie        =  tt-nota-xml.serie         AND
                  int-ds-it-docto-xml.nnf          =  tt-nota-xml.nNF           AND
                  int-ds-it-docto-xml.cod-emitente =  tt-nota-xml.cod-emitente  AND
                  int-ds-it-docto-xml.tipo-nota    =  int-ds-docto-xml.tipo-nota:
                   
            create tt-digita.
            assign tt-digita.campo = "Reenvio"
                   tt-digita.valor = string(rowid(int-ds-it-docto-xml)).
            raw-transfer tt-param  to raw-param.
        
            for each tt-digita:
                create tt-raw-digita.
                raw-transfer tt-digita to tt-raw-digita.raw-digita.
            end.
            
            run intprg/int002brp.p (input raw-param, 
                                 input table tt-raw-digita).
                        
            FIND FIRST int-ds-ext-emitente NO-LOCK WHERE   /* Pepsico nao atualiza */
                       int-ds-ext-emitente.cod-emitente = int-ds-docto-xml.cod-emitente AND 
                       int-ds-ext-emitente.gera-nota    = NO NO-ERROR.
            IF AVAIL int-ds-ext-emitente 
            THEN DO:

                FIND FIRST b-int-ds-docto-xml EXCLUSIVE-LOCK WHERE
                           b-int-ds-docto-xml.serie         =  int-ds-docto-xml.serie         AND
                           b-int-ds-docto-xml.nNF           =  int-ds-docto-xml.nNF           AND
                           b-int-ds-docto-xml.cod-emitente  =  int-ds-docto-xml.cod-emitente  AND
                           b-int-ds-docto-xml.tipo-nota     =  int-ds-docto-xml.tipo-nota NO-ERROR.
                IF AVAIL b-int-ds-docto-xml 
                THEN DO:
                
                    IF NOT CAN-FIND(FIRST int-ds-it-docto-xml NO-LOCK WHERE 
                                          int-ds-it-docto-xml.serie         =  int-ds-docto-xml.serie         AND
                                          int-ds-it-docto-xml.nNF           =  int-ds-docto-xml.nNF           AND
                                          int-ds-it-docto-xml.cod-emitente  =  int-ds-docto-xml.cod-emitente  AND
                                          int-ds-it-docto-xml.tipo-nota     =  int-ds-docto-xml.tipo-nota     AND
                                          int-ds-it-docto-xml.situacao      =  1 /* Pendente */)   
                    THEN 
                        ASSIGN b-int-ds-docto-xml.situacao = 2. /* Liberado */
                    ELSE 
                        ASSIGN b-int-ds-docto-xml.situacao = 1. /* Pendente */ 
    
                END.

            END.

        END.

        APPLY "choose" TO bt-filtro.
   END.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME c-estab-ini
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL c-estab-ini w-consim
ON F5 OF c-estab-ini IN FRAME f-cad /* Estab. */
DO:
          
    {include/zoomvar.i &prog-zoom="adzoom/z01ad098.w"
                     &campo=i-cod-emit-ini
                     &campozoom=cod-emitente
                     &campo2=i-cod-emit-fin
                     &campozoom2=cod-emitente
                     &FRAME=f-cad} 

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL c-estab-ini w-consim
ON LEAVE OF c-estab-ini IN FRAME f-cad /* Estab. */
DO:
  
   IF INPUT FRAME {&FRAME-NAME} i-cod-emit-ini <> 0 THEN
    ASSIGN i-cod-emit-fin:SCREEN-VALUE IN FRAME {&FRAME-NAME} = INPUT FRAME {&FRAME-NAME} i-cod-emit-ini. 

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL c-estab-ini w-consim
ON MOUSE-SELECT-DBLCLICK OF c-estab-ini IN FRAME f-cad /* Estab. */
DO:
  APPLY "F5" TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME c-serie-ini
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL c-serie-ini w-consim
ON F5 OF c-serie-ini IN FRAME f-cad /* S‚rie */
DO:
          
    {include/zoomvar.i &prog-zoom="adzoom/z01ad098.w"
                     &campo=i-cod-emit-ini
                     &campozoom=cod-emitente
                     &campo2=i-cod-emit-fin
                     &campozoom2=cod-emitente
                     &FRAME=f-cad} 

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL c-serie-ini w-consim
ON LEAVE OF c-serie-ini IN FRAME f-cad /* S‚rie */
DO:
  
   IF INPUT FRAME {&FRAME-NAME} i-cod-emit-ini <> 0 THEN
    ASSIGN i-cod-emit-fin:SCREEN-VALUE IN FRAME {&FRAME-NAME} = INPUT FRAME {&FRAME-NAME} i-cod-emit-ini. 

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL c-serie-ini w-consim
ON MOUSE-SELECT-DBLCLICK OF c-serie-ini IN FRAME f-cad /* S‚rie */
DO:
  APPLY "F5" TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME i-cod-emit-ini
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL i-cod-emit-ini w-consim
ON F5 OF i-cod-emit-ini IN FRAME f-cad /* Fornecedor */
DO:
          
    {include/zoomvar.i &prog-zoom="adzoom/z01ad098.w"
                     &campo=i-cod-emit-ini
                     &campozoom=cod-emitente
                     &campo2=i-cod-emit-fin
                     &campozoom2=cod-emitente
                     &FRAME=f-cad} 

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL i-cod-emit-ini w-consim
ON LEAVE OF i-cod-emit-ini IN FRAME f-cad /* Fornecedor */
DO:
  
   IF INPUT FRAME {&FRAME-NAME} i-cod-emit-ini <> 0 THEN
    ASSIGN i-cod-emit-fin:SCREEN-VALUE IN FRAME {&FRAME-NAME} = INPUT FRAME {&FRAME-NAME} i-cod-emit-ini. 

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL i-cod-emit-ini w-consim
ON MOUSE-SELECT-DBLCLICK OF i-cod-emit-ini IN FRAME f-cad /* Fornecedor */
DO:
  APPLY "F5" TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME mi-arquivo
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL mi-arquivo w-consim
ON MENU-DROP OF MENU mi-arquivo /* Arquivo */
DO:
  run pi-disable-menu.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME mi-consultas
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL mi-consultas w-consim
ON CHOOSE OF MENU-ITEM mi-consultas /* Consultas */
DO:
  RUN pi-consulta IN h_p-exihel.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME mi-conteudo
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL mi-conteudo w-consim
ON CHOOSE OF MENU-ITEM mi-conteudo /* Conteudo */
OR HELP OF FRAME {&FRAME-NAME}
DO:
  RUN pi-ajuda IN h_p-exihel.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME mi-imprimir
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL mi-imprimir w-consim
ON CHOOSE OF MENU-ITEM mi-imprimir /* Relat¢rios */
DO:
  RUN pi-imprimir IN h_p-exihel.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME mi-sair
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL mi-sair w-consim
ON CHOOSE OF MENU-ITEM mi-sair /* Sair */
DO:
  RUN pi-sair IN h_p-exihel.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME mi-sobre
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL mi-sobre w-consim
ON CHOOSE OF MENU-ITEM mi-sobre /* Sobre... */
DO:
  {include/sobre.i}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME rs-situacao
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL rs-situacao w-consim
ON VALUE-CHANGED OF rs-situacao IN FRAME f-cad
DO:
  APPLY "choose" TO bt-filtro. 
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK w-consim 


/* ***************************  Main Block  *************************** */


if i-cod-emit-ini:load-mouse-pointer("image/lupa.cur") in frame {&frame-name} then


/* Include custom  Main Block code for SmartWindows. */
{src/adm/template/windowmn.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE adm-create-objects w-consim  _ADM-CREATE-OBJECTS
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
       RUN set-position IN h_p-exihel ( 1.33 , 91.14 ) NO-ERROR.
       /* Size in UIB:  ( 1.25 , 16.00 ) */

       /* Adjust the tab order of the smart objects. */
       RUN adjust-tab-order IN adm-broker-hdl ( h_p-exihel ,
             br-nota:HANDLE IN FRAME f-cad , 'AFTER':U ).
    END. /* Page 0 */

  END CASE.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE adm-row-available w-consim  _ADM-ROW-AVAILABLE
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI w-consim  _DEFAULT-DISABLE
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
  IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(w-consim)
  THEN DELETE WIDGET w-consim.
  IF THIS-PROCEDURE:PERSISTENT THEN DELETE PROCEDURE THIS-PROCEDURE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI w-consim  _DEFAULT-ENABLE
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
  DISPLAY dt-trans-ini dt-trans-fin i-nro-docto-ini i-nro-docto-fin 
          i-cod-emit-ini i-cod-emit-fin rs-situacao c-estab-ini c-estab-fin 
          c-serie-ini c-serie-fin 
      WITH FRAME f-cad IN WINDOW w-consim.
  ENABLE dt-trans-ini dt-trans-fin i-nro-docto-ini i-nro-docto-fin 
         i-cod-emit-ini i-cod-emit-fin rs-situacao br-nota bt-filtro bt-reenvio 
         bt-erros c-estab-ini c-estab-fin c-serie-ini c-serie-fin rt-button 
         RECT-1 IMAGE-1 IMAGE-2 IMAGE-3 IMAGE-4 IMAGE-5 IMAGE-6 IMAGE-11 
         IMAGE-12 IMAGE-13 IMAGE-14 RECT-13 
      WITH FRAME f-cad IN WINDOW w-consim.
  {&OPEN-BROWSERS-IN-QUERY-f-cad}
  VIEW w-consim.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-destroy w-consim 
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-exit w-consim 
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-initialize w-consim 
PROCEDURE local-initialize :
/*------------------------------------------------------------------------------
  Purpose:     Override standard ADM method
  Notes:       
------------------------------------------------------------------------------*/

  /* Code placed here will execute PRIOR to standard behavior. */
  {include/win-size.i}

  run pi-before-initialize.

  {utp/ut9000.i "int002f" "2.06.00.001"}

  /* Dispatch standard ADM method.                             */
  RUN dispatch IN THIS-PROCEDURE ( INPUT 'initialize':U ) .

  RUN pi-carregaNota.
       
  /* Code placed here will execute AFTER standard behavior.    */

  run pi-after-initialize.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-carregaNota w-consim 
PROCEDURE pi-carregaNota :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
EMPTY TEMP-TABLE tt-nota-xml.

DEF VAR c-nat-operacao AS CHAR.
        
FOR EACH int-ds-docto-xml WHERE 
         int-ds-docto-xml.cod-emitente >= INPUT FRAME {&FRAME-NAME} i-cod-emit-ini  AND
         int-ds-docto-xml.cod-emitente <= INPUT FRAME {&FRAME-NAME} i-cod-emit-fin  AND 
         int-ds-docto-xml.cod-estab    >= INPUT FRAME {&FRAME-NAME} c-estab-ini     AND
         int-ds-docto-xml.cod-estab    <= INPUT FRAME {&FRAME-NAME} c-estab-fin     AND 
         int-ds-docto-xml.serie        >= INPUT FRAME {&FRAME-NAME} c-serie-ini     AND
         int-ds-docto-xml.serie        <= INPUT FRAME {&FRAME-NAME} c-serie-fin     AND 
     int(int-ds-docto-xml.nNF)         >= INPUT FRAME {&FRAME-NAME} i-nro-docto-ini AND  
     int(int-ds-docto-xml.nNF)         <= INPUT FRAME {&FRAME-NAME} i-nro-docto-fin AND  
         int-ds-docto-xml.dEmi         >= INPUT FRAME {&FRAME-NAME} dt-trans-ini    AND          
         int-ds-docto-xml.dEmi         <= INPUT FRAME {&FRAME-NAME} dt-trans-fin    AND 
         int-ds-docto-xml.tipo-estab    = 1 ,
    EACH int-ds-it-docto-xml WHERE 
         int-ds-it-docto-xml.serie          =  int-ds-docto-xml.serie         AND
         int-ds-it-docto-xml.nNF            =  int-ds-docto-xml.nNF           AND
         int-ds-it-docto-xml.cod-emitente   =  int-ds-docto-xml.cod-emitente  AND
         int-ds-it-docto-xml.cnpj           =  int-ds-docto-xml.cnpj          AND
         int-ds-it-docto-xml.tipo-nota      =  int-ds-docto-xml.tipo-nota     AND 
        ((int-ds-it-docto-xml.situacao       = INPUT FRAME {&FRAME-NAME} rs-situacao  AND 
                                               INPUT FRAME {&FRAME-NAME} rs-situacao < 4) OR 
        (int-ds-it-docto-xml.situacao  > 0 AND INPUT FRAME {&FRAME-NAME} rs-situacao = 4))  
    BREAK BY int-ds-it-docto-xml.cod-emitente
          BY int-ds-it-docto-xml.nNF
          BY int-ds-it-docto-xml.tipo-contr :
  
             
    IF FIRST-OF(int-ds-it-docto-xml.tipo-contr)
    THEN DO:

          /* MESSAGE  INPUT FRAME {&FRAME-NAME} rs-situacao SKIP
                   int-ds-it-docto-xml.nNF SKIP
                   int-ds-it-docto-xml.situacao SKIP
                   int-ds-it-docto-xml.tipo-contr VIEW-AS ALERT-BOX.  
             */

        CASE int-ds-it-docto-xml.situacao:
             
            WHEN 3 THEN DO: /* Liberado */ 
                  
               IF int-ds-it-docto-xml.tipo-contr = 1 THEN
                  ASSIGN c-nat-operacao = "".
               ELSE 
                  ASSIGN c-nat-operacao = int-ds-it-docto-xml.nat-operacao.
                    
               FOR EACH int-ds-doc where 
                        int-ds-doc.serie         =  int-ds-docto-xml.serie         AND
                        int-ds-doc.nro-docto     =  int-ds-docto-xml.nNF           AND
                        int-ds-doc.cod-emitente  =  int-ds-docto-xml.cod-emitente  AND
                        int-ds-doc.nat-operacao  =  c-nat-operacao                 AND
                        int-ds-doc.tipo-nota     =  int-ds-docto-xml.tipo-nota :
                    
                   CREATE tt-nota-xml.
                   BUFFER-COPY int-ds-doc TO tt-nota-xml.
                   ASSIGN tt-nota-xml.r-rowid      = ROWID(int-ds-doc)
                          tt-nota-xml.situacao     = int-ds-it-docto-xml.situacao
                          tt-nota-xml.tipo-contr   = int-ds-it-docto-xml.tipo-contr
                          tt-nota-xml.nat-operacao = int-ds-doc.nat-operacao
                          tt-nota-xml.cod-estab    = int-ds-doc.cod-estab
                          tt-nota-xml.serie        = int-ds-doc.serie-docto
                          tt-nota-xml.nNF          = int-ds-doc.nro-docto
                          tt-nota-xml.dEmi         = int-ds-doc.dt-emissao
                          tt-nota-xml.CNPJ         = int-ds-docto-xml.CNPJ.
            
                   FIND FIRST emitente NO-LOCK WHERE
                              emitente.cod-emitente = int-ds-doc.cod-emitente AND 
                              emitente.cod-emitente > 0 NO-ERROR.
                   IF AVAIL emitente THEN
                      ASSIGN tt-nota-xml.xnome = emitente.nome-emit. 
               END.

            END.
            OTHERWISE DO: 
                   
                   CREATE tt-nota-xml.
                   BUFFER-COPY int-ds-docto-xml TO tt-nota-xml.
                   ASSIGN tt-nota-xml.r-rowid      = ROWID(int-ds-docto-xml)
                          tt-nota-xml.situacao     = int-ds-it-docto-xml.situacao
                          tt-nota-xml.tipo-contr   = int-ds-it-docto-xml.tipo-contr
                          tt-nota-xml.nat-operacao = int-ds-it-docto-xml.nat-operacao. 
                          
                                                                        
                   FIND FIRST emitente NO-LOCK WHERE
                              emitente.cod-emitente = int-ds-doc.cod-emitente AND 
                              emitente.cod-emitente > 0 NO-ERROR.
                   IF AVAIL emitente THEN
                      ASSIGN tt-nota-xml.xnome = emitente.nome-emit.
            
            END.
         END CASE.

    END.

END.

{&OPEN-QUERY-br-nota}
{&OPEN-QUERY-br-it-nota}

APPLY "VALUE-CHANGED" TO br-nota.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE send-records w-consim  _ADM-SEND-RECORDS
PROCEDURE send-records :
/*------------------------------------------------------------------------------
  Purpose:     Send record ROWID's for all tables used by
               this file.
  Parameters:  see template/snd-head.i
------------------------------------------------------------------------------*/

  /* Define variables needed by this internal procedure.               */
  {src/adm/template/snd-head.i}

  /* For each requested table, put it's ROWID in the output list.      */
  {src/adm/template/snd-list.i "tt-nota-xml"}

  /* Deal with any unexpected table requests before closing.           */
  {src/adm/template/snd-end.i}

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE state-changed w-consim 
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION fn-situacao w-consim 
FUNCTION fn-situacao RETURNS CHARACTER
  ( p-situacao AS INT) :
/*------------------------------------------------------------------------------
  Purpose:  
    Notes:  
------------------------------------------------------------------------------*/
IF p-situacao = 1 THEN
   RETURN "Pendente".   
IF p-situacao = 2 THEN
   RETURN "Liberado".   
IF p-situacao = 3 THEN
   RETURN "Atualizado".   


END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION fn-status w-consim 
FUNCTION fn-status RETURNS CHARACTER
  ( p-situacao AS INT) :
/*------------------------------------------------------------------------------
  Purpose:  
    Notes:  
------------------------------------------------------------------------------*/
  CASE p-situacao:
      WHEN 1 THEN RETURN "Pendente Integra‡Æo".   
      WHEN 2 THEN RETURN "Erro Integra‡Æo F¡sico".   
      WHEN 3 THEN RETURN "Erro Integra‡Æo Fiscal".   
      WHEN 4 THEN RETURN "Pendente Integra‡Æo Fiscal".   
      WHEN 5 THEN RETURN "Integrado Fiscal".
      WHEN 6 THEN RETURN "Implantado Fiscal Erro Varia‡Æo".
      WHEN 7 THEN RETURN "Implantado F¡sico Erro Varia‡Æo".
  END CASE.
  

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION fn-tipo-contr w-consim 
FUNCTION fn-tipo-contr RETURNS CHARACTER
  ( p-tipo-contr AS INT /* parameter-definitions */ ) :
/*------------------------------------------------------------------------------
  Purpose:  
    Notes:  
------------------------------------------------------------------------------*/

 CASE p-tipo-contr:
      WHEN 1 THEN RETURN "F¡sico".   
      WHEN 4 THEN RETURN "Fiscal".   
 END CASE.

  RETURN "".   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

