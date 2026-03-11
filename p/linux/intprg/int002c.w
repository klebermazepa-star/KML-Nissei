&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI ADM1
&ANALYZE-RESUME
/* Connected Databases 
          mgcad            ORACLE
*/
&Scoped-define WINDOW-NAME w-digita
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS w-digita 
/*:T *******************************************************************************
** Copyright DATASUL S.A. (1997)
** Todos os Direitos Reservados.
**
** Este fonte e de propriedade exclusiva da DATASUL, sua reproducao
** parcial ou total por qualquer meio, so podera ser feita mediante
** autorizacao expressa.
*******************************************************************************/
{include/i-prgvrs.i int002c 2.06.00.001}
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

DEF VAR hProgramZoom AS HANDLE NO-UNDO.

{intprg/int002.i}
{intprg/int002c.i}

 {inbo/boin090.i tt-docum-est}       /* Definiªío TT-DOCUM-EST       */
{inbo/boin176.i tt-item-doc-est}    /* Definiªío TT-ITEM-DOC-EST    */

 DEF TEMP-TABLE tt-nota no-undo
FIELD situacao     AS INTEGER
FIELD nro-docto    LIKE docum-est.nro-docto   
FIELD serie-nota   LIKE docum-est.serie-docto
FIELD serie-docum  LIKE docum-est.serie-docto        
FIELD cod-emitente LIKE docum-est.cod-emitente
FIELD nat-operacao LIKE docum-est.nat-operacao
FIELD tipo-nota    LIKE int-ds-docto-xml.tipo-nota
FIELD valor-mercad LIKE doc-fisico.valor-mercad.

DEF TEMP-TABLE tt-erro-xml
FIELD cd-erro      AS INT
FIELD arquivo      AS CHAR
FIELD nNF          AS CHAR
FIELD serie        AS CHAR
FIELD sequencia    AS INTEGER
FIELD num-pedido   LIKE ordem-compra.num-pedido
FIELD numero-ordem LIKE ordem-compra.numero-ordem
FIELD descricao    AS CHAR.

DEF BUFFER b-tt-it-nota-xml FOR tt-it-nota-xml.
DEF BUFFER b-it-doc-fisico  FOR it-doc-fisico.
 
/* Parameters Definitions ---                                           */

DEF INPUT PARAMETER TABLE FOR tt-param-nissei.

/* Local Variable Definitions ---                                       */

DEF VAR i-seq-item       AS INT     NO-UNDO.
def var c-pasta          as char    no-undo.
def var l-cancelado      as logical no-undo.
DEF VAR c-param          AS CHAR    NO-UNDO.
DEF VAR c-comando        AS CHAR    NO-UNDO.
DEF VAR d-tot-quant      AS DEC     NO-UNDO.
DEF VAR de-fator         LIKE item-fornec.fator-conver NO-UNDO.
DEF VAR c-estab-orig     LIKE param-estoq.estabel-pad  NO-UNDO.
DEF VAR d-quant          LIKE prazo-compra.quant-saldo NO-UNDO.
DEF VAR d-tot-nota       LIKE doc-fisico.valor-mercad NO-UNDO.
DEF VAR c-mensagem       AS CHAR      NO-UNDO.
DEF VAR i-seq-erro       AS INTEGER   NO-UNDO.
DEF VAR c-desc-erro      AS CHAR      NO-UNDO.
DEF VAR c-cod-depos      AS CHAR      NO-UNDO.
DEF VAR i-qry            AS INTEGER   NO-UNDO.
DEF VAR r-rowid-nota     AS ROWID     NO-UNDO.
        
DEF BUFFER b-estabelec FOR estabelec.
DEF VAR p-tipo-compra AS INTEGER NO-UNDO.

DEF BUFFER b-tt-nota-xml FOR tt-nota-xml.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Digitacao
&Scoped-define DB-AWARE no

&Scoped-define ADM-CONTAINER WINDOW

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME F-cad
&Scoped-define BROWSE-NAME br-erro

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-erro-xml tt-it-nota-xml tt-nota-xml ~
emitente

/* Definitions for BROWSE br-erro                                       */
&Scoped-define FIELDS-IN-QUERY-br-erro tt-erro-xml.nNF tt-erro-xml.serie tt-erro-xml.sequencia tt-erro-xml.numero-ordem tt-erro-xml.num-pedido tt-erro-xml.descricao   
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-erro   
&Scoped-define SELF-NAME br-erro
&Scoped-define QUERY-STRING-br-erro FOR EACH tt-erro-xml
&Scoped-define OPEN-QUERY-br-erro OPEN QUERY {&SELF-NAME} FOR EACH tt-erro-xml.
&Scoped-define TABLES-IN-QUERY-br-erro tt-erro-xml
&Scoped-define FIRST-TABLE-IN-QUERY-br-erro tt-erro-xml


/* Definitions for BROWSE br-it-nota                                    */
&Scoped-define FIELDS-IN-QUERY-br-it-nota tt-it-nota-xml.sequencia tt-it-nota-xml.numero-ordem tt-it-nota-xml.qOrdem tt-it-nota-xml.num-pedido tt-it-nota-xml.nat-operacao tt-it-nota-xml.it-codigo tt-it-nota-xml.xProd tt-it-nota-xml.uCom tt-it-nota-xml.qCom-forn tt-it-nota-xml.qCom tt-it-nota-xml.vProd tt-it-nota-xml.vDesc   
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-it-nota   
&Scoped-define SELF-NAME br-it-nota
&Scoped-define QUERY-STRING-br-it-nota FOR EACH tt-it-nota-xml WHERE                                  tt-it-nota-xml.arquivo   = tt-nota-xml.arquivo AND                                  tt-it-nota-xml.serie     = tt-nota-xml.serie   AND                                  int(tt-it-nota-xml.nNF)  = int(tt-nota-xml.nNF) AND                                  tt-it-nota-xml.CNPJ      = tt-nota-xml.CNPJ
&Scoped-define OPEN-QUERY-br-it-nota OPEN QUERY {&SELF-NAME} FOR EACH tt-it-nota-xml WHERE                                  tt-it-nota-xml.arquivo   = tt-nota-xml.arquivo AND                                  tt-it-nota-xml.serie     = tt-nota-xml.serie   AND                                  int(tt-it-nota-xml.nNF)  = int(tt-nota-xml.nNF) AND                                  tt-it-nota-xml.CNPJ      = tt-nota-xml.CNPJ.
&Scoped-define TABLES-IN-QUERY-br-it-nota tt-it-nota-xml
&Scoped-define FIRST-TABLE-IN-QUERY-br-it-nota tt-it-nota-xml


/* Definitions for BROWSE br-nota                                       */
&Scoped-define FIELDS-IN-QUERY-br-nota tt-nota-xml.marca tt-nota-xml.nNF tt-nota-xml.serie tt-nota-xml.dEmi tt-nota-xml.VNF emitente.cod-emitente emitente.nome-emit tt-nota-xml.CNPJ   
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-nota   
&Scoped-define SELF-NAME br-nota
&Scoped-define OPEN-QUERY-br-nota IF i-qry = 1 THEN     OPEN QUERY {&SELF-NAME} FOR EACH tt-nota-xml WHERE                                      tt-nota-xml.ep-codigo = int(i-ep-codigo-usuario) AND                                      tt-nota-xml.dEmi >= INPUT FRAME {&FRAME-NAME} dt-trans-ini AND                                      tt-nota-xml.dEmi <= INPUT FRAME {&FRAME-NAME} dt-trans-fin AND                                      int(tt-nota-xml.nNF)  >= INPUT FRAME {&FRAME-NAME} i-nro-docto-ini AND                                      int(tt-nota-xml.nNF)  <= INPUT FRAME {&FRAME-NAME} i-nro-docto-fin AND                                      tt-nota-xml.situacao   = 2   , ~
                                       FIRST emitente NO-LOCK WHERE                                       emitente.cgc = tt-nota-xml.CNPJ AND                                       emitente.cod-emitente  > 0 AND                                       emitente.cod-emitente  >= INPUT FRAME {&FRAME-NAME} i-cod-emit-ini AND                                       emitente.cod-emitente  <= INPUT FRAME {&FRAME-NAME} i-cod-emit-fin .   ELSE       OPEN QUERY {&SELF-NAME} FOR EACH tt-nota-xml WHERE                                      tt-nota-xml.ep-codigo = int(i-ep-codigo-usuario) AND                                      tt-nota-xml.chNfe     = INPUT FRAME {&FRAME-NAME} c-chave AND                                      tt-nota-xml.situacao  = 2   , ~
                                       FIRST emitente NO-LOCK WHERE                                       emitente.cgc = tt-nota-xml.CNPJ AND                                       emitente.cod-emitente  > 0 AND                                       emitente.cod-emitente  >= INPUT FRAME {&FRAME-NAME} i-cod-emit-ini AND                                       emitente.cod-emitente  <= INPUT FRAME {&FRAME-NAME} i-cod-emit-fin .
&Scoped-define TABLES-IN-QUERY-br-nota tt-nota-xml emitente
&Scoped-define FIRST-TABLE-IN-QUERY-br-nota tt-nota-xml
&Scoped-define SECOND-TABLE-IN-QUERY-br-nota emitente


/* Definitions for FRAME F-cad                                          */
&Scoped-define OPEN-BROWSERS-IN-QUERY-F-cad ~
    ~{&OPEN-QUERY-br-erro}~
    ~{&OPEN-QUERY-br-it-nota}~
    ~{&OPEN-QUERY-br-nota}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS RECT-12 IMAGE-1 IMAGE-2 IMAGE-3 IMAGE-4 ~
IMAGE-5 IMAGE-6 dt-trans-ini dt-trans-fin bt-ok i-nro-docto-ini ~
i-nro-docto-fin btGoTo bt-filtro c-chave i-cod-emit-ini i-cod-emit-fin ~
br-nota bt-marca bt-todos bt-confirma br-it-nota br-erro 
&Scoped-Define DISPLAYED-OBJECTS dt-trans-ini dt-trans-fin i-nro-docto-ini ~
i-nro-docto-fin c-chave i-cod-emit-ini i-cod-emit-fin 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR w-digita AS WIDGET-HANDLE NO-UNDO.

/* Definitions of the field level widgets                               */
DEFINE BUTTON bt-confirma 
     LABEL "Confirma" 
     SIZE 13 BY 1.

DEFINE BUTTON bt-filtro 
     IMAGE-UP FILE "image/im-chck1.bmp":U
     IMAGE-INSENSITIVE FILE "image/ii-chck1.bmp":U
     LABEL "" 
     SIZE 4 BY 1.25 TOOLTIP "Selecionar notas"
     FONT 4.

DEFINE BUTTON bt-marca 
     LABEL "Marca" 
     SIZE 13 BY 1.

DEFINE BUTTON bt-ok AUTO-GO 
     IMAGE-UP FILE "image/toolbar/im-exi.bmp":U
     IMAGE-INSENSITIVE FILE "image/toolbar/ii-exi.bmp":U
     LABEL "Sair" 
     SIZE 4 BY 1.25 TOOLTIP "Sair".

DEFINE BUTTON bt-todos 
     LABEL "Todos" 
     SIZE 13 BY 1.

DEFINE BUTTON btGoTo 
     IMAGE-UP FILE "image\im-enter":U
     IMAGE-INSENSITIVE FILE "image\ii-enter":U
     LABEL "Go To" 
     SIZE 4 BY 1.25.

DEFINE VARIABLE c-chave AS CHARACTER FORMAT "X(44)":U 
     LABEL "Chave" 
     VIEW-AS FILL-IN 
     SIZE 39.43 BY .79 NO-UNDO.

DEFINE VARIABLE dt-trans-fin AS DATE FORMAT "99/99/9999":U INITIAL 12/31/9999 
     VIEW-AS FILL-IN 
     SIZE 10.86 BY .88 NO-UNDO.

DEFINE VARIABLE dt-trans-ini AS DATE FORMAT "99/99/9999":U INITIAL 01/01/001 
     LABEL "Dt Emissao" 
     VIEW-AS FILL-IN 
     SIZE 10.86 BY .88 NO-UNDO.

DEFINE VARIABLE i-cod-emit-fin AS INTEGER FORMAT ">>>>>>>>9":U INITIAL 999999999 
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

DEFINE RECTANGLE RECT-12
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 122 BY 3.63.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-erro FOR 
      tt-erro-xml SCROLLING.

DEFINE QUERY br-it-nota FOR 
      tt-it-nota-xml SCROLLING.

DEFINE QUERY br-nota FOR 
      tt-nota-xml, 
      emitente SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-erro
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-erro w-digita _FREEFORM
  QUERY br-erro DISPLAY
      tt-erro-xml.nNF          FORMAT "x(10)" LABEL "NFE"
 tt-erro-xml.serie        FORMAT "x(03)" LABEL "Serie"
 tt-erro-xml.sequencia    FORMAT ">>9"   LABEL "Seq"     
 tt-erro-xml.numero-ordem
 tt-erro-xml.num-pedido  
 tt-erro-xml.descricao    FORMAT "x(200)" LABEL "Descriá∆o"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 122 BY 5.25
         FONT 1
         TITLE "Erros".

DEFINE BROWSE br-it-nota
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-it-nota w-digita _FREEFORM
  QUERY br-it-nota DISPLAY
      tt-it-nota-xml.sequencia     FORMAT ">>9"   LABEL "Seq"
tt-it-nota-xml.numero-ordem
tt-it-nota-xml.qOrdem        LABEL "Qtd Ordem"
tt-it-nota-xml.num-pedido  
tt-it-nota-xml.nat-operacao  FORMAT "x(06)" LABEL "Natureza"
tt-it-nota-xml.it-codigo     FORMAT "x(10)" LABEL "Item"
tt-it-nota-xml.xProd         FORMAT "x(50)" LABEL "Descriá∆o" 
tt-it-nota-xml.uCom          FORMAT "x(03)" LABEL "Un" 
tt-it-nota-xml.qCom-forn     column-label "Qtd Forn"
tt-it-nota-xml.qCom          column-label "Nossa Qtd"
tt-it-nota-xml.vProd         FORMAT "->>>,>>>,>>9.99" LABEL "Valor Total"
tt-it-nota-xml.vDesc         LABEL "Desconto"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ASSIGN NO-ROW-MARKERS SEPARATORS SIZE 122 BY 6.42
         FONT 1
         TITLE "Itens".

DEFINE BROWSE br-nota
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-nota w-digita _FREEFORM
  QUERY br-nota DISPLAY
      tt-nota-xml.marca   COLUMN-LABEL ""   FORMAT "x(01)"
tt-nota-xml.nNF     FORMAT "x(10)"     LABEL "NFE"
tt-nota-xml.serie   FORMAT "x(03)"     LABEL "Serie"
tt-nota-xml.dEmi    FORMAT 99/99/9999  LABEL "Dt Emissao" 
tt-nota-xml.VNF                        LABEL "Valor Total"
emitente.cod-emitente LABEL "Fornecedor" 
emitente.nome-emit  LABEL "Nome" FORMAT "x(20)"
tt-nota-xml.CNPJ    FORMAT "x(19)"     LABEL "CNPJ"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 122 BY 5.63
         FONT 1
         TITLE "Notas".


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME F-cad
     dt-trans-ini AT ROW 1.5 COL 11.14 COLON-ALIGNED WIDGET-ID 26
     dt-trans-fin AT ROW 1.5 COL 29.72 COLON-ALIGNED NO-LABEL WIDGET-ID 24
     bt-ok AT ROW 1.5 COL 119 HELP
          "Sair"
     i-nro-docto-ini AT ROW 2.5 COL 11.14 COLON-ALIGNED WIDGET-ID 34
     i-nro-docto-fin AT ROW 2.5 COL 29.57 COLON-ALIGNED NO-LABEL WIDGET-ID 40
     btGoTo AT ROW 3.04 COL 106 HELP
          "V† Para" WIDGET-ID 70
     bt-filtro AT ROW 3.25 COL 44.29 HELP
          "Selecionar notas" WIDGET-ID 54
     c-chave AT ROW 3.46 COL 63.86 COLON-ALIGNED WIDGET-ID 66
     i-cod-emit-ini AT ROW 3.5 COL 4.43 WIDGET-ID 58
     i-cod-emit-fin AT ROW 3.5 COL 29.72 COLON-ALIGNED NO-LABEL WIDGET-ID 56
     br-nota AT ROW 4.88 COL 2 WIDGET-ID 200
     bt-marca AT ROW 10.75 COL 2.57 WIDGET-ID 62
     bt-todos AT ROW 10.75 COL 15.57 WIDGET-ID 64
     bt-confirma AT ROW 10.75 COL 111 WIDGET-ID 20
     br-it-nota AT ROW 12.08 COL 2 WIDGET-ID 400
     br-erro AT ROW 19 COL 2 WIDGET-ID 300
     RECT-12 AT ROW 1.25 COL 2 WIDGET-ID 28
     IMAGE-1 AT ROW 1.5 COL 25 WIDGET-ID 52
     IMAGE-2 AT ROW 1.5 COL 28.57 WIDGET-ID 30
     IMAGE-3 AT ROW 2.5 COL 25 WIDGET-ID 36
     IMAGE-4 AT ROW 2.5 COL 28.57 WIDGET-ID 38
     IMAGE-5 AT ROW 3.5 COL 25 WIDGET-ID 46
     IMAGE-6 AT ROW 3.5 COL 28.57 WIDGET-ID 48
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 124.43 BY 23.58
         FONT 1 WIDGET-ID 100.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Digitacao
   Allow: Basic,Browse,DB-Fields,Smart,Window,Query
   Container Links: 
   Add Fields to: Neither
   Design Page: 1
   Other Settings: COMPILE
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
IF SESSION:DISPLAY-TYPE = "GUI":U THEN
  CREATE WINDOW w-digita ASSIGN
         HIDDEN             = YES
         TITLE              = ""
         HEIGHT             = 23.58
         WIDTH              = 125.29
         MAX-HEIGHT         = 30.13
         MAX-WIDTH          = 195.14
         VIRTUAL-HEIGHT     = 30.13
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
/* END WINDOW DEFINITION                                                */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _INCLUDED-LIB w-digita 
/* ************************* Included-Libraries *********************** */

{src/adm/method/containr.i}
{include/w-digit.i}
{utp/ut-glob.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME




/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW w-digita
  VISIBLE,,RUN-PERSISTENT                                               */
/* SETTINGS FOR FRAME F-cad
   FRAME-NAME                                                           */
/* BROWSE-TAB br-nota i-cod-emit-fin F-cad */
/* BROWSE-TAB br-it-nota bt-confirma F-cad */
/* BROWSE-TAB br-erro br-it-nota F-cad */
/* SETTINGS FOR FILL-IN i-cod-emit-ini IN FRAME F-cad
   ALIGN-L                                                              */
IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(w-digita)
THEN w-digita:HIDDEN = yes.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-erro
/* Query rebuild information for BROWSE br-erro
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH tt-erro-xml.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE br-erro */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-it-nota
/* Query rebuild information for BROWSE br-it-nota
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH tt-it-nota-xml WHERE
                                 tt-it-nota-xml.arquivo   = tt-nota-xml.arquivo AND
                                 tt-it-nota-xml.serie     = tt-nota-xml.serie   AND
                                 int(tt-it-nota-xml.nNF)  = int(tt-nota-xml.nNF) AND
                                 tt-it-nota-xml.CNPJ      = tt-nota-xml.CNPJ.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE br-it-nota */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-nota
/* Query rebuild information for BROWSE br-nota
     _START_FREEFORM
IF i-qry = 1 THEN
    OPEN QUERY {&SELF-NAME} FOR EACH tt-nota-xml WHERE
                                     tt-nota-xml.ep-codigo = int(i-ep-codigo-usuario) AND
                                     tt-nota-xml.dEmi >= INPUT FRAME {&FRAME-NAME} dt-trans-ini AND
                                     tt-nota-xml.dEmi <= INPUT FRAME {&FRAME-NAME} dt-trans-fin AND
                                     int(tt-nota-xml.nNF)  >= INPUT FRAME {&FRAME-NAME} i-nro-docto-ini AND
                                     int(tt-nota-xml.nNF)  <= INPUT FRAME {&FRAME-NAME} i-nro-docto-fin AND
                                     tt-nota-xml.situacao   = 2   ,
                                FIRST emitente NO-LOCK WHERE
                                      emitente.cgc = tt-nota-xml.CNPJ AND
                                      emitente.cod-emitente  > 0 AND
                                      emitente.cod-emitente  >= INPUT FRAME {&FRAME-NAME} i-cod-emit-ini AND
                                      emitente.cod-emitente  <= INPUT FRAME {&FRAME-NAME} i-cod-emit-fin .

 ELSE
      OPEN QUERY {&SELF-NAME} FOR EACH tt-nota-xml WHERE
                                     tt-nota-xml.ep-codigo = int(i-ep-codigo-usuario) AND
                                     tt-nota-xml.chNfe     = INPUT FRAME {&FRAME-NAME} c-chave AND
                                     tt-nota-xml.situacao  = 2   ,
                                FIRST emitente NO-LOCK WHERE
                                      emitente.cgc = tt-nota-xml.CNPJ AND
                                      emitente.cod-emitente  > 0 AND
                                      emitente.cod-emitente  >= INPUT FRAME {&FRAME-NAME} i-cod-emit-ini AND
                                      emitente.cod-emitente  <= INPUT FRAME {&FRAME-NAME} i-cod-emit-fin .
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE br-nota */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME w-digita
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL w-digita w-digita
ON END-ERROR OF w-digita
OR ENDKEY OF {&WINDOW-NAME} ANYWHERE DO:
  /* This case occurs when the user presses the "Esc" key.
     In a persistently run window, just ignore this.  If we did not, the
     application would exit. */
  IF THIS-PROCEDURE:PERSISTENT THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL w-digita w-digita
ON WINDOW-CLOSE OF w-digita
DO:
  /* This ADM code must be left here in order for the SmartWindow
     and its descendents to terminate properly on exit. */
  APPLY "CLOSE":U TO THIS-PROCEDURE.
  RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-it-nota
&Scoped-define SELF-NAME br-it-nota
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-it-nota w-digita
ON ROW-LEAVE OF br-it-nota IN FRAME F-cad /* Itens */
DO:
  
  ASSIGN tt-it-nota-xml.numero-ordem = INPUT BROWSE br-it-nota tt-it-nota-xml.numero-ordem
         tt-it-nota-xml.num-pedido   = INPUT BROWSE br-it-nota tt-it-nota-xml.num-pedido
         tt-it-nota-xml.qOrdem       = INPUT BROWSE br-it-nota tt-it-nota-xml.qOrdem.
  
  IF tt-it-nota-xml.tipo-compra = 2 OR 
     tt-it-nota-xml.tipo-compra = 3 
  THEN DO:
     ASSIGN tt-it-nota-xml.it-codigo  = INPUT BROWSE br-it-nota tt-it-nota-xml.it-codigo.
     RUN pi-altera-item (INPUT 2). 
  END.
  
     
       
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-it-nota w-digita
ON VALUE-CHANGED OF br-it-nota IN FRAME F-cad /* Itens */
DO:
  ASSIGN tt-it-nota-xml.numero-ordem = INPUT BROWSE br-it-nota tt-it-nota-xml.numero-ordem
         tt-it-nota-xml.num-pedido   = INPUT BROWSE br-it-nota tt-it-nota-xml.num-pedido.
  
  IF tt-it-nota-xml.tipo-compra = 2 OR 
     tt-it-nota-xml.tipo-compra = 3 
  THEN DO:
     ASSIGN tt-it-nota-xml.it-codigo  = INPUT BROWSE br-it-nota tt-it-nota-xml.it-codigo.

     RUN pi-altera-item (INPUT 2).
     
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-nota
&Scoped-define SELF-NAME br-nota
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-nota w-digita
ON MOUSE-SELECT-DBLCLICK OF br-nota IN FRAME F-cad /* Notas */
DO:
  APPLY "choose" TO bt-marca.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-nota w-digita
ON RETURN OF br-nota IN FRAME F-cad /* Notas */
DO:
  APPLY "choose" TO bt-marca.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-nota w-digita
ON VALUE-CHANGED OF br-nota IN FRAME F-cad /* Notas */
DO:
  IF br-nota:NUM-ITERATIONS > 0
  THEN DO:
     br-nota:SELECT-FOCUSED-ROW().
        
     if avail tt-nota-xml 
     THEN DO:
        IF tt-nota-xml.marca = "*" THEN 
           assign bt-marca:label = "Desmarca".
        ELSE 
           assign bt-marca:label = "Marca".

        ASSIGN r-rowid-nota = ROWID(tt-nota-xml).
     END.
  END.  

  {&OPEN-QUERY-br-it-nota}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-confirma
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-confirma w-digita
ON CHOOSE OF bt-confirma IN FRAME F-cad /* Confirma */
DO:  
     IF NOT CAN-FIND(FIRST tt-nota-xml WHERE
                           tt-nota-xml.marca = "*")
     THEN DO:
    
         RUN utp/ut-msgs.p (input "show":U, 
                            input 27979, 
                            input "Nenhuma nota selecionada!" + "~~" + 
                                  "Selecione uma nota.").

          RETURN NO-APPLY.
    
     END.
  
     /* FIND FIRST exten-param-re NO-LOCK WHERE
                exten-param-re.usuario = c-seg-usuario NO-ERROR.
     IF (NOT AVAIL exten-param-re OR 
         (AVAIL exten-param-re AND
                exten-param-re.usu-master = NO))
     THEN DO:
        RUN utp/ut-msgs.p (input "show":U, 
                           input 17006, 
                           input "Usu†rio sem permiss∆o." + "~~" + 
                                 "Usu†rio precisa estar cadastrado como master nos parÉmetros DO recebimento.").

        RETURN NO-APPLY.
     END. */
     
     IF tt-param-nissei.tipo-docto = 1 THEN
            ASSIGN c-mensagem = "recebimento f°sico ? ". 
      ELSE 
            ASSIGN c-mensagem = "recebimento fiscal ? ".

     RUN utp/ut-msgs.p (INPUT "SHOW":U,
                        INPUT 27100,
                        INPUT "Integrar notas selecionadas ? "  + "~~" + 
                              "Integrar notas selecionadas para o " + c-mensagem).
     IF RETURN-VALUE = "yes" 
     THEN DO:
        
            EMPTY TEMP-TABLE tt-erro-xml.
            EMPTY TEMP-TABLE tt-docum-est.
            EMPTY TEMP-TABLE tt-item-doc-est.
            EMPTY TEMP-TABLE tt-int-ds-doc.
            EMPTY TEMP-TABLE tt-int-ds-it-doc.
            EMPTY TEMP-TABLE tt-nota.
        
            FIND FIRST param-estoq NO-LOCK NO-ERROR.                   
             
            FOR EACH tt-nota-xml WHERE
                     tt-nota-xml.marca = "*" :

               RUN pi-geraNota.

            END.                       
               
            IF NOT CAN-FIND(FIRST tt-erro-xml) 
            THEN DO:                  
                  
                IF tt-param-nissei.tipo-docto = 1 
                THEN DO:
                       
                    /* Integracao com o recebimento f°sico  */
                     
                    RUN intprg/int002d.p(INPUT-OUTPUT TABLE tt-int-ds-doc,
                                         INPUT        TABLE tt-int-ds-it-doc). 
                           
                    FOR EACH tt-nota-xml WHERE
                             tt-nota-xml.marca = "*":                                         
                                                              
                        FOR EACH int-ds-doc-erro NO-LOCK WHERE
                                 int-ds-doc-erro.serie-docto    = tt-nota-xml.serie   AND 
                                 int-ds-doc-erro.cod-emitente   = tt-nota-xml.cod-emitente AND
                                 int(int-ds-doc-erro.nro-docto) = int(tt-nota-xml.nnf)    AND 
                                 int-ds-doc-erro.tipo-nota      = tt-nota-xml.tipo-nota  :                             
                                                                                                                                          
                            RUN pi-geraErro(INPUT int-ds-doc-erro.descricao).    
                                                    
                        END.
                                         
                    end.
                     
                END.
                ELSE DO:
    
                       /*** Gerar notas conforme a natureza de operacao/serie  ***/
                
                       FOR EACH tt-nota-xml WHERE
                                tt-nota-xml.marca = "*" AND
                                tt-nota-xml.situacao < 3 
                           BREAK BY tt-nota-xml.nNF
                                 BY tt-nota-xml.cod-emitente :
                            
                           IF LAST-OF(tt-nota-xml.cod-emitente) THEN DO:
                
                               FOR EACH int-ds-doc-erro EXCLUSIVE-LOCK  WHERE
                                        int-ds-doc-erro.serie-docto  = tt-nota-xml.serie        AND 
                                        int-ds-doc-erro.cod-emitente = tt-nota-xml.cod-emitente AND
                                        int(int-ds-doc-erro.nro-docto) = int(tt-nota-xml.nNF)       AND  
                                        int-ds-doc-erro.tipo-nota    = tt-nota-xml.tipo-nota :
                                 
                                   DELETE int-ds-doc-erro.
                               END.
                
                           END.
                
                           IF tt-nota-xml.tipo-docto <> 4 THEN
                             RUN pi-geraDocto (INPUT tt-nota-xml.situacao).
                           ELSE DO:
                          
                              RUN pi-geraDocto (INPUT 1).
                               
                              FOR EACH tt-nota WHERE
                                       tt-nota-xml.nNF = tt-nota-xml.nNF :

                                 ASSIGN tt-nota.situacao = 2. /* Liberado */

                              END.
                           END.
                       END.
                         
                       /*** Integracao com re1001 ****/ 
    
                       IF NOT CAN-FIND(FIRST tt-erro-xml) 
                       THEN DO:
                
                            RUN intprg/int002e.p(INPUT TABLE tt-nota,
                                                 INPUT TABLE tt-docum-est,
                                                 INPUT TABLE tt-item-doc-est). 
                          
                           /*** Atualiza situacao da nota no monitor */
                    
                           FOR EACH tt-nota
                              BREAK BY tt-nota.nro-docto
                                    BY tt-nota.cod-emitente:
                     
                             IF LAST-OF(tt-nota.cod-emitente) 
                             THEN DO:                         
                                
                                FIND FIRST int-ds-docto-xml EXCLUSIVE-LOCK WHERE
                                           int-ds-docto-xml.serie        = tt-nota.serie-nota   AND
                                           int-ds-docto-xml.cod-emitente = tt-nota.cod-emitente AND
                                           int(int-ds-docto-xml.nNF)     = int(tt-nota.nro-docto)  AND 
                                           int-ds-docto-xml.tipo-nota    = tt-nota.tipo-nota NO-ERROR.
                                IF AVAIL int-ds-docto-xml THEN DO:
                    
                                   FIND FIRST int-ds-doc-erro NO-LOCK WHERE
                                              int-ds-doc-erro.serie-docto  = tt-nota.serie-nota   AND 
                                              int-ds-doc-erro.cod-emitente = tt-nota.cod-emitente AND
                                              int(int-ds-doc-erro.nro-docto) = int(tt-nota.nro-docto) AND 
                                              int-ds-doc-erro.tipo-nota    = tt-nota.tipo-nota    AND
                                              int-ds-doc-erro.tipo-erro    = "Error"  NO-ERROR.
                                   IF AVAIL int-ds-doc-erro THEN DO:
                                   
                                      ASSIGN int-ds-docto-xml.sit-re = 3.
    
                                      FOR EACH int-ds-doc-erro NO-LOCK WHERE
                                               int-ds-doc-erro.serie-docto  = tt-nota.serie-nota   AND 
                                               int-ds-doc-erro.cod-emitente = tt-nota.cod-emitente AND
                                               int(int-ds-doc-erro.nro-docto) = int(tt-nota.nro-docto) AND 
                                               int-ds-doc-erro.tipo-nota    = tt-nota.tipo-nota    AND
                                               int-ds-doc-erro.tipo-erro    = "Error" :
                                              
                                              RUN pi-geraErro(INPUT int-ds-doc-erro.descricao).    
                                                
                                      END.
                                       
                                   END.
                                   ELSE DO:
                                      
                                      FOR EACH tt-int-ds-doc WHERE
                                               tt-int-ds-doc.serie        = tt-nota.serie-nota   AND
                                               tt-int-ds-doc.cod-emitente = tt-nota.cod-emitente AND
                                               int(tt-int-ds-doc.nro-docto)  = int(tt-nota.nro-docto) AND 
                                               tt-int-ds-doc.nat-operacao = ""                   AND 
                                               tt-int-ds-doc.tipo-nota    = tt-nota.tipo-nota:
                                                            
                                             CREATE int-ds-doc.
                                             BUFFER-COPY tt-int-ds-doc EXCEPT nat-operacao TO int-ds-doc.
                                             ASSIGN  int-ds-doc.nat-operacao = tt-nota.nat-operacao.
                                            
                                      END.
    
                                      FOR EACH tt-int-ds-it-doc WHERE
                                               tt-int-ds-it-doc.serie        = tt-nota.serie-nota   AND
                                               tt-int-ds-it-doc.cod-emitente = tt-nota.cod-emitente AND
                                               tt-int-ds-it-doc.nat-operacao = tt-nota.nat-operacao AND
                                               int(tt-int-ds-it-doc.nro-docto) = int(tt-nota.nro-docto) AND 
                                               tt-int-ds-it-doc.tipo-nota    = tt-nota.tipo-nota: 
                                                               
                                             CREATE int-ds-it-doc.
                                             BUFFER-COPY tt-int-ds-it-doc TO int-ds-it-doc.
    
                                      END.
                                          
                                      FOR EACH int-ds-it-docto-xml EXCLUSIVE-LOCK WHERE
                                               int-ds-it-docto-xml.serie        = tt-nota.serie-nota   AND
                                               int-ds-it-docto-xml.cod-emitente = tt-nota.cod-emitente AND
                                               int-ds-it-docto-xml.nat-operacao = tt-nota.nat-operacao AND 
                                               int(int-ds-it-docto-xml.nNF)     = int(tt-nota.nro-docto)    AND 
                                               int-ds-it-docto-xml.tipo-nota    = tt-nota.tipo-nota:
                                                 
                                          ASSIGN int-ds-it-docto-xml.situacao = 3.
                                                  
                                      END.
                                                
                                      IF NOT CAN-FIND(FIRST int-ds-it-docto-xml NO-LOCK WHERE 
                                                            int-ds-it-docto-xml.serie         =  tt-nota.serie-nota     AND
                                                            int-ds-it-docto-xml.cod-emitente  =  tt-nota.cod-emitente   AND
                                                            int(int-ds-it-docto-xml.nNF)      =  int(tt-nota.nro-docto) AND
                                                            int-ds-it-docto-xml.tipo-nota     =  tt-nota.tipo-nota      AND
                                                            int-ds-it-docto-xml.situacao      =  2 /* Liberado */)   
                                      THEN DO:
                                          ASSIGN int-ds-docto-xml.situacao = 3.
                                      END.
    
                                      ASSIGN int-ds-docto-xml.sit-re   = 5.
                                           
                                   END.
                    
                                   RELEASE int-ds-docto-xml.
    
    
                                END.
                    
                             END.
    
                           END.
    
                       END.
                
                END. /* else do tipo-docto */
                
                RUN pi-carrega-nota.
                    
                APPLY "choose" TO bt-filtro.
    
            END. /* not can-find */
           

     END. /* yes / No */
      
     IF NOT CAN-FIND(FIRST tt-erro-xml) 
     THEN DO:
          
        {&OPEN-QUERY-br-nota}
        {&OPEN-QUERY-br-it-nota}
        
        FIND FIRST tt-int-ds-doc NO-ERROR.
        IF AVAIL tt-int-ds-doc 
        THEN DO:
            IF tt-param-nissei.tipo-docto = 1 
            THEN DO: 
                FIND FIRST doc-fisico NO-LOCK WHERE
                           int(doc-fisico.nro-docto) = int(string(int(tt-int-ds-doc.nro-docto),"9999999")) AND
                           doc-fisico.serie-docto   = tt-int-ds-doc.serie                        AND
                           doc-fisico.cod-emitente  = tt-int-ds-doc.cod-emitente                 AND
                           doc-fisico.tipo-nota     = tt-int-ds-doc.tipo-nota NO-ERROR.
                IF AVAIL doc-fisico THEN 
                  RUN pi-reposiciona-query IN tt-param-nissei.h-tela (INPUT ROWID(doc-fisico)).
                
            END.
            ELSE DO:
                 FIND FIRST tt-nota NO-ERROR.
    
                 FIND FIRST docum-est NO-LOCK where
                            docum-est.serie        = tt-nota.serie-nota   AND
                            docum-est.cod-emitente = tt-nota.cod-emitente AND 
                            docum-est.nat-operacao = tt-nota.nat-operacao AND
                            int(docum-est.nro-docto) = INT(tt-nota.nro-docto)  NO-ERROR.
                 IF AVAIL docum-est THEN
                    RUN repositionRecord IN tt-param-nissei.h-tela (ROWID(docum-est)).
            END.

            

            

        END.                                                                       
     END.

     {&OPEN-QUERY-br-erro}

 

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-filtro
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-filtro w-digita
ON CHOOSE OF bt-filtro IN FRAME F-cad
DO:
   ASSIGN i-qry = 1.

   {&OPEN-QUERY-br-nota}
   {&OPEN-QUERY-br-it-nota}
   {&OPEN-QUERY-br-erro}
    

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-marca
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-marca w-digita
ON CHOOSE OF bt-marca IN FRAME F-cad /* Marca */
DO:
  
  IF br-nota:NUM-ITERATIONS > 0
  THEN DO:
        br-nota:SELECT-FOCUSED-ROW().
            
        if bt-marca:label = "Marca" then do:
           
           if avail tt-nota-xml then 
              assign tt-nota-xml.marca = "*"
                     tt-nota-xml.marca:screen-value in browse br-nota = "*"
                     r-rowid-nota = ROWID(tt-nota-xml).
              
           assign bt-marca:label = "Desmarca".
        end.
        else do:
           if avail tt-nota-xml then             
              assign tt-nota-xml.marca = ""
                     tt-nota-xml.marca:screen-value in browse br-nota = ""
                     r-rowid-nota      = ROWID(tt-nota-xml).
          
           assign bt-marca:label = "Marca".  
        end.

        APPLY "value-changed" TO br-nota.
        
        {&OPEN-QUERY-br-nota}

        REPOSITION br-nota TO ROWID r-rowid-nota NO-ERROR. 

  END.
 
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-ok
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-ok w-digita
ON CHOOSE OF bt-ok IN FRAME F-cad /* Sair */
DO:
  
  apply "close":U to this-procedure.
  
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-todos
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-todos w-digita
ON CHOOSE OF bt-todos IN FRAME F-cad /* Todos */
DO:
    IF br-nota:NUM-ITERATIONS > 0
    THEN DO:
       br-nota:SELECT-FOCUSED-ROW().
    
        if bt-todos:label = "Nenhum" then do:
           
           for each tt-nota-xml where
                    tt-nota-xml.marca = "*" :
               assign tt-nota-xml.marca = "".
           end.     
           
           assign bt-todos:label = "Todos"
                  bt-marca:label = "Marca".
        end.
        else do:
          
           for each tt-nota-xml where
                    tt-nota-xml.marca = "" :
               assign tt-nota-xml.marca = "*".
           end.
           
          assign bt-todos:label = "Nenhum"
                 bt-marca:label = "Desmarca".
          
        end.
    
        {&OPEN-QUERY-br-nota}
    END.                     

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btGoTo
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btGoTo w-digita
ON CHOOSE OF btGoTo IN FRAME F-cad /* Go To */
DO:
   ASSIGN i-qry = 2.

   {&OPEN-QUERY-br-nota}
   {&OPEN-QUERY-br-it-nota}
   {&OPEN-QUERY-br-erro}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME i-cod-emit-ini
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL i-cod-emit-ini w-digita
ON F5 OF i-cod-emit-ini IN FRAME F-cad /* Fornecedor */
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


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL i-cod-emit-ini w-digita
ON LEAVE OF i-cod-emit-ini IN FRAME F-cad /* Fornecedor */
DO:
  
   IF INPUT FRAME {&FRAME-NAME} i-cod-emit-ini <> 0 THEN
    ASSIGN i-cod-emit-fin:SCREEN-VALUE IN FRAME {&FRAME-NAME} = INPUT FRAME {&FRAME-NAME} i-cod-emit-ini. 

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL i-cod-emit-ini w-digita
ON MOUSE-SELECT-DBLCLICK OF i-cod-emit-ini IN FRAME F-cad /* Fornecedor */
DO:
  APPLY "F5" TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-erro
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK w-digita 


/* ***************************  Main Block  *************************** */

if i-cod-emit-ini:load-mouse-pointer("image/lupa.cur") in frame {&frame-name} then

ON F5 OF tt-it-nota-xml.numero-ordem in browse br-it-nota
OR MOUSE-SELECT-DBLCLICK OF tt-it-nota-xml.numero-ordem in browse br-it-nota DO:
   
   /* {method/zoomFields.i &ProgramZoom="inzoom/z22in274.w"
                        &FieldZoom1="num-pedido"
                        &FieldScreen1="tt-it-nota-xml.num-pedido"
                        &Browse1="br-it-nota"                          
                        &FieldZoom2="numero-ordem"
                        &FieldScreen2="tt-it-nota-xml.numero-ordem"                                                    
                        &Browse2="br-it-nota" 
                        &FieldZoom3="it-codigo"
                        &FieldScreen3="tt-it-nota-xml.it-codigo"
                        &Browse3="br-it-nota" 
                        &RunMethod="Run setParametersPedido in hProgramZoom (input tt-nota-xml.cod-emitente,INPUT '',INPUT 0,input 99999999,input ?,input c-seg-usuario)." 
                        &EnableImplant="NO"} */
  
  {include/zoomvar.i &prog-zoom=inzoom/z13in274.w
                     &campo=tt-it-nota-xml.num-pedido
                     &campozoom=num-pedido
                     &BROWSE=br-it-nota 
                     &campo2=tt-it-nota-xml.numero-ordem
                     &campozoom2=numero-ordem
                     &BROWSE2=br-it-nota
                     &campo3=tt-it-nota-xml.it-codigo
                     &campozoom3=it-codigo
                     &BROWSE3=br-it-nota
                     &campo4=tt-it-nota-xml.qordem
                     &campozoom4=qt-solic
                     &BROWSE4=br-it-nota
                     &parametros="Run pi-recebe-parametros in wh-pesquisa(input tt-nota-xml.cod-emitente, input 1 , input '' )." } 
          
END.                                                   

ON LEAVE OF tt-it-nota-xml.numero-ordem DO: 
   
   /* 
   IF tt-it-nota-xml.tipo-compra = 2 
   THEN DO:
       ASSIGN tt-it-nota-xml.numero-ordem = INPUT BROWSE br-it-nota tt-it-nota-xml.numero-ordem.
       
       FIND FIRST ordem-compra NO-LOCK WHERE
                  ordem-compra.numero-ordem = INPUT BROWSE br-it-nota tt-it-nota-xml.numero-ordem NO-ERROR.
       IF AVAIL ordem-compra THEN DO:
          ASSIGN tt-it-nota-xml.num-pedido = ordem-compra.num-pedido 
                 tt-it-nota-xml.num-pedido:SCREEN-VALUE IN BROWSE br-it-nota = STRING(ordem-compra.num-pedido)
                 tt-it-nota-xml.it-codigo  = ordem-compra.it-codigo
                 tt-it-nota-xml.it-codigo:SCREEN-VALUE IN BROWSE br-it-nota = STRING(ordem-compra.it-codigo).
              
            ASSIGN d-quant = 0.

            FOR FIRST prazo-compra OF ordem-compra NO-LOCK WHERE
                      prazo-compra.situacao    = 2 AND 
                      prazo-compra.quant-saldo - prazo-compra.dec-1 > 0 :
                
                ASSIGN d-quant = prazo-compra.quant-saldo - prazo-compra.dec-1.
                
            END.

            FOR EACH docum-est-xml NO-LOCK WHERE
                     docum-est-xml.ep-codigo = int(i-ep-codigo-usuario) AND
                     docum-est-xml.situacao  = 1,
                EACH item-doc-est-xml OF docum-est-xml NO-LOCK WHERE   
                     item-doc-est-xml.num-pedido   = ordem-compra.num-pedido   AND
                     item-doc-est-xml.numero-ordem = ordem-compra.numero-ordem :

                ASSIGN d-quant = d-quant - item-doc-est-xml.quantidade.
                    
            END.
                 
            FOR EACH it-docto-xml NO-LOCK WHERE
                     it-docto-xml.num-pedido   = ordem-compra.num-pedido   AND
                     it-docto-xml.numero-ordem = ordem-compra.numero-ordem :
    
                 ASSIGN d-quant = d-quant - it-docto-xml.qOrdem.
                    
             END.
            
             IF d-quant >= 0  THEN
               ASSIGN tt-it-nota-xml.qordem  = d-quant
                      tt-it-nota-xml.qordem:SCREEN-VALUE IN BROWSE br-it-nota = STRING(d-quant).
       END.
       ELSE
          ASSIGN tt-it-nota-xml.num-pedido = 0
                 tt-it-nota-xml.num-pedido:SCREEN-VALUE IN BROWSE br-it-nota = STRING(0)
                 tt-it-nota-xml.it-codigo  = ""
                 tt-it-nota-xml.it-codigo:SCREEN-VALUE IN BROWSE br-it-nota = "".
   END.
   */
   
END. 

ON LEAVE OF tt-it-nota-xml.it-codigo DO: 

   IF tt-it-nota-xml.tipo-compra <> 3 THEN
      ASSIGN tt-it-nota-xml.it-codigo:SCREEN-VALUE IN BROWSE br-it-nota = tt-it-nota-xml.it-codigo.
   
END. 
 

ON F5 OF tt-it-nota-xml.it-codigo in browse br-it-nota
OR MOUSE-SELECT-DBLCLICK OF tt-it-nota-xml.it-codigo in browse br-it-nota DO:
   
  IF tt-it-nota-xml.tipo-compra = 3 
  THEN DO:
      {include/zoomvar.i &prog-zoom=inzoom/z05in172.w
                         &campo=tt-it-nota-xml.it-codigo
                         &campozoom=it-codigo
                         &BROWSE=br-it-nota } 
  END.
END.                                                   


/* Include custom  Main Block code for SmartWindows. */
{src/adm/template/windowmn.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE adm-create-objects w-digita  _ADM-CREATE-OBJECTS
PROCEDURE adm-create-objects :
/*------------------------------------------------------------------------------
  Purpose:     Create handles for all SmartObjects used in this procedure.
               After SmartObjects are initialized, then SmartLinks are added.
  Parameters:  <none>
------------------------------------------------------------------------------*/
  DEFINE VARIABLE adm-current-page  AS INTEGER NO-UNDO.

  RUN get-attribute IN THIS-PROCEDURE ('Current-Page':U).
  ASSIGN adm-current-page = INTEGER(RETURN-VALUE).

  /* Select a Startup page. */
  IF adm-current-page eq 0 
  THEN RUN select-page IN THIS-PROCEDURE ( 1 ).

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE adm-row-available w-digita  _ADM-ROW-AVAILABLE
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI w-digita  _DEFAULT-DISABLE
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
  IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(w-digita)
  THEN DELETE WIDGET w-digita.
  IF THIS-PROCEDURE:PERSISTENT THEN DELETE PROCEDURE THIS-PROCEDURE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI w-digita  _DEFAULT-ENABLE
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
  DISPLAY dt-trans-ini dt-trans-fin i-nro-docto-ini i-nro-docto-fin c-chave 
          i-cod-emit-ini i-cod-emit-fin 
      WITH FRAME F-cad IN WINDOW w-digita.
  ENABLE RECT-12 IMAGE-1 IMAGE-2 IMAGE-3 IMAGE-4 IMAGE-5 IMAGE-6 dt-trans-ini 
         dt-trans-fin bt-ok i-nro-docto-ini i-nro-docto-fin btGoTo bt-filtro 
         c-chave i-cod-emit-ini i-cod-emit-fin br-nota bt-marca bt-todos 
         bt-confirma br-it-nota br-erro 
      WITH FRAME F-cad IN WINDOW w-digita.
  {&OPEN-BROWSERS-IN-QUERY-F-cad}
  VIEW w-digita.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-destroy w-digita 
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-exit w-digita 
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-initialize w-digita 
PROCEDURE local-initialize :
/*------------------------------------------------------------------------------
  Purpose:     Override standard ADM method
  Notes:       
------------------------------------------------------------------------------*/

  /* Code placed here will execute PRIOR to standard behavior. */

  {utp/ut9000.i "int002c" "2.06.00.001"}

  /* Dispatch standard ADM method.                             */
  RUN dispatch IN THIS-PROCEDURE ( INPUT 'initialize':U ) .
  
/* gravar caminho em uma tabela espec°fica */

  FIND FIRST tt-param-nissei NO-ERROR.
  FIND FIRST param-estoq NO-LOCK NO-ERROR.
  
  RUN pi-carrega-nota.

  APPLY "choose" TO bt-filtro IN FRAME {&FRAME-NAME}.

  /* Code placed here will execute AFTER standard behavior.    */

  {include/i-inifld.i}

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-altera-item w-digita 
PROCEDURE pi-altera-item :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
DEF INPUT PARAM p-tipo AS INTEGER.

IF p-tipo = 1 THEN DO: /* inclui */
  IF AVAIL b-tt-it-nota-xml 
  THEN DO:
      CREATE int-ds-it-docto-xml.
      BUFFER-COPY b-tt-it-nota-xml EXCEPT r-rowid TO int-ds-it-docto-xml.
      ASSIGN b-tt-it-nota-xml.r-rowid = ROWID(int-ds-it-docto-xml).
  END.
END.
ELSE IF p-tipo = 2 THEN DO: /* Altera */
    FIND FIRST int-ds-it-docto-xml EXCLUSIVE-LOCK WHERE
               ROWID(int-ds-it-docto-xml) = tt-it-nota-xml.r-rowid NO-ERROR.
    IF AVAIL int-ds-it-docto-xml 
    THEN DO:
        BUFFER-COPY tt-it-nota-xml TO int-ds-it-docto-xml.
    END.
END.
ELSE DO: /* Elimina */
    FIND FIRST int-ds-it-docto-xml EXCLUSIVE-LOCK WHERE
               ROWID(int-ds-it-docto-xml) = tt-it-nota-xml.r-rowid NO-ERROR.
    IF AVAIL int-ds-it-docto-xml 
    THEN DO:
        DELETE int-ds-it-docto-xml.
    END. 
END.

RELEASE int-ds-it-docto-xml.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-carrega-nota w-digita 
PROCEDURE pi-carrega-nota :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
EMPTY TEMP-TABLE tt-nota-xml.
EMPTY TEMP-TABLE tt-it-nota-xml.

DEF BUFFER b-emitente FOR emitente.
DEF BUFFER b-item     FOR ITEM.
 
DEF VAR i-tp-contr-ini AS INT NO-UNDO.
DEF VAR i-tp-contr-fin AS INT NO-UNDO.
DEF VAR v-tot-nota LIKE tt-nota-xml.vNF NO-UNDO.

IF tt-param-nissei.tipo-docto = 1 /* Fisico */ THEN
    ASSIGN i-tp-contr-ini = 1
           i-tp-contr-fin = 2.
ELSE 
    ASSIGN i-tp-contr-ini = 4
           i-tp-contr-fin = 4. 

FOR EACH int-ds-docto-xml WHERE
         int-ds-docto-xml.ep-codigo = int(i-ep-codigo-usuario) AND
         int-ds-docto-xml.dEmi >= INPUT FRAME {&FRAME-NAME} dt-trans-ini AND
         int-ds-docto-xml.dEmi <= INPUT FRAME {&FRAME-NAME} dt-trans-fin AND
         int(int-ds-docto-xml.nNF)  >= INPUT FRAME {&FRAME-NAME} i-nro-docto-ini AND
         int(int-ds-docto-xml.nNF)  <= INPUT FRAME {&FRAME-NAME} i-nro-docto-fin AND 
         int-ds-docto-xml.situacao   = 2 /* Liberado */                          AND
         int-ds-docto-xml.tipo-estab = 1 ,
    FIRST emitente NO-LOCK WHERE   
         emitente.cgc           = int-ds-docto-xml.CNPJ AND 
         emitente.cod-emitente  > 0                AND
         emitente.cod-emitente  >= INPUT FRAME {&FRAME-NAME} i-cod-emit-ini AND
         emitente.cod-emitente  <= INPUT FRAME {&FRAME-NAME} i-cod-emit-fin ,
    EACH int-ds-it-docto-xml WHERE 
         int-ds-it-docto-xml.serie          =  int-ds-docto-xml.serie         AND
         int(int-ds-it-docto-xml.nNF)       =  INT(int-ds-docto-xml.nNF)      AND
         int-ds-it-docto-xml.cod-emitente   =  int-ds-docto-xml.cod-emitente  AND
         int-ds-it-docto-xml.tipo-nota      =  int-ds-docto-xml.tipo-nota     AND
         int-ds-it-docto-xml.situacao       =  2 /* Liberado */               AND
         int-ds-it-docto-xml.tipo-contr     >=  i-tp-contr-ini AND 
         int-ds-it-docto-xml.tipo-contr     <=  i-tp-contr-fin
    BREAK BY int-ds-it-docto-xml.nNF
          BY int-ds-it-docto-xml.cod-emitente
          BY int-ds-it-docto-xml.tipo-contr:
    
    IF FIRST-OF(int-ds-it-docto-xml.tipo-contr) 
    THEN DO:
      
        CREATE tt-nota-xml.
        BUFFER-COPY int-ds-docto-xml TO tt-nota-xml.
        ASSIGN tt-nota-xml.r-rowid     =  ROWID(int-ds-docto-xml)
               tt-nota-xml.tipo-compra =  2
               tt-nota-xml.tipo-nota   =  1 /* "NFE" */ .

        FIND FIRST estabelec NO-LOCK WHERE
                   estabelec.cgc = int-ds-docto-xml.cnpj NO-ERROR.
        IF AVAIL estabelec 
        THEN DO:
           FIND FIRST nota-fiscal NO-LOCK WHERE
                      nota-fiscal.cod-estabel  = estabelec.cod-estabel AND
                      nota-fiscal.serie        = int-ds-docto-xml.serie       AND
                      int(nota-fiscal.nr-nota-fis)  = int(int-ds-docto-xml.nNF) NO-ERROR.
           IF AVAIL nota-fiscal THEN DO:
              FIND FIRST b-estabelec NO-LOCK WHERE
                         b-estabelec.cod-emitente = nota-fiscal.cod-emitente NO-ERROR.
              IF AVAIL b-estabelec THEN
                 ASSIGN tt-nota-xml.estab-de-or =  b-estabelec.cod-estabel.
           END.
    
           ASSIGN tt-nota-xml.tipo-nota = 3. /* "NFT" */ 
           IF tt-nota-xml.tipo-nota <> 1 /* "NFE" */ 
           THEN DO: 
                IF AVAIL nota-fiscal THEN DO:

                   FOR EACH it-nota-fisc OF nota-fiscal NO-LOCK,
                       FIRST b-ITEM NO-LOCK WHERE
                             b-ITEM.it-codigo = it-nota-fisc.it-codigo:
                       CREATE tt-it-nota-xml.
                       ASSIGN tt-it-nota-xml.arquivo   = int-ds-docto-xml.arquivo 
                              tt-it-nota-xml.CNPJ      = int-ds-docto-xml.CNPJ   
                              tt-it-nota-xml.nNF       = int-ds-docto-xml.nNF    
                              tt-it-nota-xml.serie     = int-ds-docto-xml.serie
                              tt-it-nota-xml.sequencia = it-nota-fisc.nr-seq-fat
                              tt-it-nota-xml.it-codigo = it-nota-fisc.it-codigo 
                              tt-it-nota-xml.xProd     = b-ITEM.desc-item     
                              tt-it-nota-xml.marca     = ""
                              tt-it-nota-xml.qCom      = it-nota-fisc.qt-faturada[1]
                              tt-it-nota-xml.qOrdem    = it-nota-fisc.qt-faturada[1]
                              tt-it-nota-xml.uCom      = it-nota-fisc.un-fatur[1] 
                              tt-it-nota-xml.vProd     = it-nota-fisc.vl-preuni * it-nota-fisc.qt-faturada[1] 
                              tt-it-nota-xml.vUnCom    = 1
                              tt-it-nota-xml.tipo-nota = tt-nota-xml.tipo-nota.
        
                   END.

                END. 
           END.
           
        END.

    END. /* Last-of */

    IF tt-nota-xml.tipo-nota = 1 /* "NFE" */ 
    THEN DO:
                                          
       CREATE tt-it-nota-xml.
       BUFFER-COPY int-ds-it-docto-xml TO tt-it-nota-xml
           assign tt-it-nota-xml.arquivo   = int-ds-docto-xml.arquivo.
       ASSIGN tt-it-nota-xml.r-rowid     = ROWID(int-ds-it-docto-xml)
              tt-it-nota-xml.tipo-nota   = tt-nota-xml.tipo-nota
              tt-it-nota-xml.tipo-compra = 2  
              tt-it-nota-xml.qOrdem      = int-ds-it-docto-xml.qCom
              tt-it-nota-xml.vProd       = tt-it-nota-xml.vProd - tt-it-nota-xml.Vdesc.
    END.
    
    IF LAST-OF(int-ds-it-docto-xml.tipo-contr) 
    THEN DO:
        ASSIGN v-tot-nota = 0.
                
        FOR EACH tt-it-nota-xml WHERE
                 tt-it-nota-xml.serie          =  tt-nota-xml.serie         AND
                 int(tt-it-nota-xml.nNF)       =  int(tt-nota-xml.nNF)      AND
                 tt-it-nota-xml.cod-emitente   =  tt-nota-xml.cod-emitente  AND
                 tt-it-nota-xml.tipo-nota      =  tt-nota-xml.tipo-nota :


            ASSIGN v-tot-nota = v-tot-nota + tt-it-nota-xml.vProd.
                   
        END.

        ASSIGN tt-nota-xml.vNF = v-tot-nota.


    END.

END.  


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-geradocto w-digita 
PROCEDURE pi-geradocto :
DEF INPUT PARAMETER p-situacao AS INTEGER.

FOR EACH tt-int-ds-it-doc WHERE
         tt-int-ds-it-doc.serie        = tt-nota-xml.serie   AND
         int(tt-int-ds-it-doc.nro-docto)  = int(tt-nota-xml.nNF)    AND 
         tt-int-ds-it-doc.cod-emitente = tt-nota-xml.cod-emitente AND 
         tt-int-ds-it-doc.tipo-nota    = tt-nota-xml.tipo-nota
    BREAK BY tt-int-ds-it-doc.nat-operacao :
       
    ASSIGN d-tot-nota = d-tot-nota + tt-int-ds-it-doc.preco-total[1].  
    
    IF LAST-OF(tt-int-ds-it-doc.nat-operacao) 
    THEN DO:
       IF NOT CAN-FIND(FIRST tt-nota WHERE
                             int(tt-nota.nro-docto) = int(tt-int-ds-it-doc.nro-docto) AND
                             tt-nota.serie-nota   = tt-int-ds-it-doc.serie        AND
                             tt-nota.cod-emitente = tt-int-ds-it-doc.cod-emitente AND
                             tt-nota.nat-operacao = tt-int-ds-it-doc.nat-operacao) 
       THEN DO:
          CREATE tt-nota.
          ASSIGN tt-nota.situacao     = p-situacao 
                 tt-nota.nro-docto    = tt-int-ds-it-doc.nro-docto  
                 tt-nota.serie-nota   = tt-int-ds-it-doc.serie
                 tt-nota.serie-docum  = tt-int-ds-it-doc.serie        
                 tt-nota.cod-emitente = tt-int-ds-it-doc.cod-emitente
                 tt-nota.nat-operacao = tt-int-ds-it-doc.nat-operacao
                 tt-nota.valor-mercad = d-tot-nota.
       END.
       /* ELSE DO:
          CREATE tt-nota.
          ASSIGN tt-nota.situacao     = p-situacao 
                 tt-nota.nro-docto    = tt-nota-xml.nNF
                 tt-nota.serie-nota   = tt-nota-xml.serie
                 tt-nota.serie-docum  = STRING(int(tt-nota-xml.serie) + 1)        
                 tt-nota.cod-emitente = tt-nota-xml.cod-emitente
                 tt-nota.nat-operacao = tt-int-ds-it-doc.nat-operacao
                 tt-nota.valor-mercad = d-tot-nota.
       END.*/


       ASSIGN d-tot-nota = 0.
    END.
END.

IF NOT CAN-FIND(FIRST tt-nota WHERE
                      int(tt-nota.nro-docto)  = int(tt-nota-xml.nNF)  AND
                      tt-nota.serie-nota   = tt-nota-xml.serie        AND
                      tt-nota.cod-emitente = tt-nota-xml.cod-emitente AND  
                      tt-nota.tipo-nota    = tt-nota-xml.tipo-nota)
THEN DO:
  CREATE tt-nota.
  ASSIGN tt-nota.situacao     = p-situacao 
         tt-nota.nro-docto    = tt-nota-xml.nNF   
         tt-nota.serie-nota   = tt-nota-xml.serie
         tt-nota.serie-docum  = tt-nota-xml.serie        
         tt-nota.cod-emitente = tt-nota-xml.cod-emitente
         tt-nota.nat-operacao = tt-nota-xml.nat-operacao
         tt-nota.tipo-nota    = tt-nota-xml.tipo-nota
         tt-nota.valor-mercad = tt-nota-xml.vNF.
END.

FOR EACH tt-nota WHERE
         int(tt-nota.nro-docto) = int(tt-nota-xml.nNF)   AND
         tt-nota.serie-nota   = tt-nota-xml.serie         AND
         tt-nota.cod-emitente = tt-nota-xml.cod-emitente :

  FIND FIRST natur-oper NO-LOCK WHERE
             natur-oper.nat-operacao = tt-nota.nat-operacao NO-ERROR.
  IF NOT AVAIL natur-oper THEN DO:

     ASSIGN c-desc-erro = "Natureza de operacao " + tt-nota.nat-operacao + " n∆o cadastrada".

     RUN pi-geraErro(INPUT c-desc-erro).

  END.

  FIND FIRST serie NO-LOCK WHERE
             serie.serie = tt-nota.serie-docum NO-ERROR.
  IF NOT AVAIL serie THEN DO:
     ASSIGN c-desc-erro = "Serie " + tt-nota.serie-docum + " n∆o cadastrada".

     RUN pi-geraErro(INPUT c-desc-erro).

  END.

  IF tt-nota-xml.tipo-nota = 3  /* NFT */
  THEN DO:
     IF AVAIL natur-oper 
     THEN DO:
        IF natur-oper.especie-doc <> "NFT" 
        THEN DO:
          ASSIGN c-desc-erro = "EspÇcie da Natureza de Operaá∆o " + tt-nota.nat-operacao + " deve ser de transferància : NFT".

          RUN pi-geraErro(INPUT c-desc-erro).
        END.
     END.

     IF tt-nota-xml.cod-estab = tt-nota-xml.estab-de-or 
     THEN DO:
        ASSIGN c-desc-erro = "Estabelecimento de origem " + tt-nota-xml.estab-de-or + " igual ao estabelecimento da nota.".

        RUN pi-geraErro(INPUT c-desc-erro).

     END.
  END.

END.

IF NOT CAN-FIND(FIRST int-ds-doc-erro WHERE
                      int-ds-doc-erro.serie-docto  = tt-nota-xml.serie        AND 
                      int-ds-doc-erro.cod-emitente = tt-nota-xml.cod-emitente AND
                      int(int-ds-doc-erro.nro-docto) = int(tt-nota-xml.nNf)   AND 
                      int-ds-doc-erro.tipo-nota    = tt-nota-xml.tipo-nota  )    
THEN DO:

    IF p-situacao = 1 /* Pendente */
    THEN DO:
    
       FOR EACH tt-nota WHERE
                int(tt-nota.nro-docto)  = int(tt-nota-xml.nNF)   AND
                tt-nota.serie-nota   = tt-nota-xml.serie         AND
                tt-nota.cod-emitente = tt-nota-xml.cod-emitente ,
           FIRST natur-oper NO-LOCK WHERE
                 natur-oper.nat-operacao = tt-nota.nat-operacao :
           
           FIND FIRST emitente NO-LOCK WHERE
                      emitente.cod-emitente = tt-nota-xml.cod-emitente NO-ERROR.
                   
           CREATE tt-docum-est.
           assign tt-docum-est.nro-docto    = tt-nota-xml.nNF
                  tt-docum-est.cod-emitente = tt-nota-xml.cod-emitente
                  tt-docum-est.serie-docto  = tt-nota.serie-docum
                  tt-docum-est.char-2       = tt-nota.serie-nota  /* Serie documento principal */
                  tt-docum-est.nat-operacao = natur-oper.nat-operacao                              
                  tt-docum-est.cod-observa  = if natur-oper.log-2 then 2 /* Comercio */ else 1  /* Industria*/
                  tt-docum-est.cod-estabel   = tt-nota-xml.cod-estab
                  tt-docum-est.estab-fisc    = tt-nota-xml.cod-estab
                  tt-docum-est.estab-de-or   = tt-nota-xml.estab-de-or  
                  tt-docum-est.usuario       = tt-nota-xml.cod-usuario
                  tt-docum-est.uf            = emitente.estado 
                  tt-docum-est.via-transp    = 1
                  tt-docum-est.dt-emis       = tt-nota-xml.dEmi   
                  tt-docum-est.dt-trans      = tt-nota-xml.dt-trans                          
                  tt-docum-est.nff           = no                              /**** Nota fiscal de Fatura ***/
                  tt-docum-est.observacao    = tt-nota-xml.observacao
                  tt-docum-est.valor-mercad  = 0 
                  tt-docum-est.tot-valor     = tt-nota.valor-mercad
                  tt-docum-est.conta-transit = param-estoq.conta-fornec
                  substring(tt-docum-est.char-1,93,60) = tt-nota-xml.chNfe.

            IF LENGTH(TRIM(string(tt-docum-est.nro-docto))) < 8 THEN
              ASSIGN tt-docum-est.nro-docto = STRING(int(tt-docum-est.nro-docto),"9999999").

           IF tt-nota-xml.tipo-nota = 3 THEN 
              ASSIGN tt-docum-est.esp-docto   = 23
                     tt-docum-est.cod-estabel = tt-nota-xml.estab-de-or
                     tt-docum-est.estab-fisc  = tt-nota-xml.estab-de-or
                     tt-docum-est.estab-de-or = tt-nota-xml.cod-estab.
           ELSE 
              ASSIGN tt-docum-est.esp-docto = 21.

           ASSIGN i-seq-item = 0.
    
           FOR EACH tt-int-ds-it-doc WHERE
                    int(tt-int-ds-it-doc.nro-docto) = int(tt-nota-xml.nNF)    AND 
                    tt-int-ds-it-doc.serie         = tt-nota-xml.serie        AND
                    tt-int-ds-it-doc.cod-emitente  = tt-nota-xml.cod-emitente AND
                    tt-int-ds-it-doc.nat-operacao  = tt-nota.nat-operacao ,
                FIRST ITEM NO-LOCK WHERE 
                      ITEM.it-codigo = tt-int-ds-it-doc.it-codigo 
                BREAK BY tt-int-ds-it-doc.nat-operacao:
                
                IF FIRST-OF(tt-int-ds-it-doc.nat-operacao) THEN
                   ASSIGN i-seq-item  = 0.
        
                 ASSIGN i-seq-item  =  i-seq-item + 10.
                           
                 CREATE tt-item-doc-est.
                 ASSIGN tt-item-doc-est.serie-docto    = tt-docum-est.serie-docto
                        tt-item-doc-est.char-2         = tt-nota.serie-nota       /* Serie documento principal */
                        tt-item-doc-est.nro-docto      = tt-docum-est.nro-docto
                        tt-item-doc-est.cod-emitente   = tt-docum-est.cod-emitente
                        tt-item-doc-est.nat-operacao   = tt-docum-est.nat-operacao
                        tt-item-doc-est.sequencia      = i-seq-item
                        tt-item-doc-est.it-codigo      = ITEM.it-codigo
                        tt-item-doc-est.num-pedido     = tt-int-ds-it-doc.num-pedido    
                        tt-item-doc-est.numero-ordem   = tt-int-ds-it-doc.numero-ordem. 
            
                 if  tt-item-doc-est.numero-ordem <> 0 then
                      for first ordem-compra fields (numero-ordem)
                          where ordem-compra.numero-ordem = tt-item-doc-est.numero-ordem no-lock:
                      end.
                
                 if  not avail ordem-compra then
                      assign tt-item-doc-est.numero-ordem = 0
                             tt-item-doc-est.parcela      = 0.
                 else do:
                     find FIRST prazo-compra NO-LOCK where 
                                prazo-compra.numero-ordem = tt-item-doc-est.numero-ordem and 
                                prazo-compra.situacao     = 2 AND
                                prazo-compra.quant-saldo - prazo-compra.dec-1  > 0 NO-ERROR.
                     if avail prazo-compra then 
                        assign tt-item-doc-est.parcela = prazo-compra.parcela.     
                 end. 

                 FIND FIRST item-uni-estab NO-LOCK WHERE
                            item-uni-estab.cod-estabel = tt-nota-xml.cod-estab AND
                            item-uni-estab.it-codigo   = ITEM.it-codigo NO-ERROR.
                 IF AVAIL item-uni-estab THEN
                    ASSIGN c-cod-depos = item-uni-estab.deposito-pad.
                 ELSE 
                    ASSIGN c-cod-depos = item.deposito-pad.
    
                 assign tt-item-doc-est.encerra-pa     = no
                        tt-item-doc-est.log-1          = NO /* FIFO */ 
                        tt-item-doc-est.parcela        = tt-int-ds-it-doc.parcela
                        tt-item-doc-est.nr-ord-prod    = 0
                        tt-item-doc-est.cod-roteiro    = ""
                        tt-item-doc-est.op-codigo      = 0
                        tt-item-doc-est.item-pai       = ""
                        tt-item-doc-est.baixa-ce       = YES 
                        tt-item-doc-est.quantidade     = tt-int-ds-it-doc.quantidade
                        tt-item-doc-est.cod-depos      = c-cod-depos
                        tt-item-doc-est.class-fiscal   = item.class-fiscal
                        tt-item-doc-est.preco-total[1] = tt-int-ds-it-doc.preco-total[1].    

                 IF ITEM.tipo-contr = 4 THEN DO:
                    IF AVAIL item-uni-estab THEN
                       ASSIGN tt-item-doc-est.conta-contabil = item-uni-estab.conta-aplicacao.
                    ELSE 
                       ASSIGN tt-item-doc-est.conta-contabil = ITEM.conta-aplicacao.
                 END.
                 ELSE 
                   ASSIGN tt-item-doc-est.conta-contabil = "".
                        
           END.

       END.    
        
    END.
    ELSE DO: /* Fisico */
       
        
       FOR EACH tt-nota WHERE
                int(tt-nota.nro-docto) = int(tt-nota-xml.nNF)    AND
                tt-nota.serie-nota   = tt-nota-xml.serie         AND
                tt-nota.cod-emitente = tt-nota-xml.cod-emitente ,
          FIRST doc-fisico NO-LOCK WHERE
                doc-fisico.nro-docto     = tt-nota-xml.nNF          AND 
                doc-fisico.serie-docto   = tt-nota-xml.serie        AND
                doc-fisico.cod-emitente  = tt-nota-xml.cod-emitente AND
                doc-fisico.tipo-nota     = 1 /* Compra */ ,
          FIRST natur-oper NO-LOCK WHERE
                natur-oper.nat-operacao = tt-nota.nat-operacao :
               
           FIND FIRST emitente NO-LOCK WHERE
                      emitente.cod-emitente = tt-nota-xml.cod-emitente NO-ERROR.
               
           CREATE tt-docum-est.
           assign tt-docum-est.nro-docto    = tt-nota-xml.nNF
                  tt-docum-est.cod-emitente = tt-nota-xml.cod-emitente
                  tt-docum-est.serie-docto  = tt-nota.serie-docum
                  tt-docum-est.char-2       = tt-nota.serie-nota  /* Serie documento principal */
                  tt-docum-est.nat-operacao = natur-oper.nat-operacao                              
                  tt-docum-est.esp-docto    = 21 
                  tt-docum-est.cod-observa  = if natur-oper.log-2 then 2 /* Comercio */ else 1  /* Industria*/
                  tt-docum-est.cod-estabel   = doc-fisico.cod-estabel
                  tt-docum-est.estab-fisc    = doc-fisico.cod-estabel
                  tt-docum-est.usuario       = doc-fisico.usuario
                  tt-docum-est.uf            = emitente.estado
                  tt-docum-est.via-transp    = 1
                  tt-docum-est.dt-emis       = doc-fisico.dt-emissao   
                  tt-docum-est.dt-trans      = tt-nota-xml.dt-trans                   
                  tt-docum-est.nff           = NO                  /**** Nota fiscal de Fatura ***/
                  tt-docum-est.observacao    = doc-fisico.observacao
                  tt-docum-est.valor-mercad  = 0 
                  tt-docum-est.tot-valor     = tt-nota.valor-mercad
                  tt-docum-est.conta-transit = param-estoq.conta-fornec
                  substring(tt-docum-est.char-1,93,60) = tt-nota-xml.chNfe.     

             IF LENGTH(TRIM(string(tt-docum-est.nro-docto))) < 8 THEN
              ASSIGN tt-docum-est.nro-docto = STRING(int(tt-docum-est.nro-docto),"9999999").
           
           ASSIGN i-seq-item = 0.
    
           FOR EACH tt-int-ds-it-doc WHERE
                    int(tt-int-ds-it-doc.nro-docto) = int(tt-nota-xml.nNF)    AND 
                    tt-int-ds-it-doc.serie-docto   = tt-nota-xml.serie        AND
                    tt-int-ds-it-doc.cod-emitente  = tt-nota-xml.cod-emitente AND
                    tt-int-ds-it-doc.nat-operacao  = tt-nota.nat-operacao ,
              FIRST it-doc-fisico OF doc-fisico no-LOCK WHERE
                    it-doc-fisico.sequencia = tt-int-ds-it-doc.sequencia,
              FIRST ITEM NO-LOCK WHERE 
                    ITEM.it-codigo = it-doc-fisico.it-codigo 
              BREAK BY tt-int-ds-it-doc.nat-operacao:
                
              FIND FIRST b-it-doc-fisico EXCLUSIVE-LOCK WHERE
                    rowid(b-it-doc-fisico) = rowid(it-doc-fisico) NO-ERROR.
              IF AVAIL b-it-doc-fisico THEN
                 ASSIGN b-it-doc-fisico.char-2 =tt-int-ds-it-doc.nat-operacao. 

              RELEASE b-it-doc-fisico.

                 IF FIRST-OF(tt-int-ds-it-doc.nat-operacao) THEN
                    ASSIGN i-seq-item  = 0.
        
                 ASSIGN i-seq-item  =  i-seq-item + 10.
                           
                 CREATE tt-item-doc-est.
                 ASSIGN tt-item-doc-est.serie-docto    = tt-docum-est.serie-docto
                        tt-item-doc-est.char-2         = tt-nota.serie-nota       /* Serie documento principal */
                        tt-item-doc-est.nro-docto      = tt-docum-est.nro-docto
                        tt-item-doc-est.cod-emitente   = tt-docum-est.cod-emitente
                        tt-item-doc-est.nat-operacao   = tt-docum-est.nat-operacao
                        tt-item-doc-est.sequencia      = i-seq-item
                        tt-item-doc-est.it-codigo      = ITEM.it-codigo
                        tt-item-doc-est.num-pedido     = it-doc-fisico.num-pedido    
                        tt-item-doc-est.numero-ordem   = it-doc-fisico.numero-ordem.
            
                 if  tt-item-doc-est.numero-ordem <> 0 then
                      for first ordem-compra fields (numero-ordem)
                          where ordem-compra.numero-ordem = tt-item-doc-est.numero-ordem no-lock:
                      end.
                
                 if  not avail ordem-compra then
                      assign tt-item-doc-est.numero-ordem = 0
                             tt-item-doc-est.parcela      = 0.
                 else do:
                     find FIRST prazo-compra NO-LOCK where 
                                prazo-compra.numero-ordem = tt-item-doc-est.numero-ordem and 
                                prazo-compra.situacao     = 2 AND
                                prazo-compra.quant-saldo - prazo-compra.dec-1  > 0 NO-ERROR.
                     if avail prazo-compra then 
                        assign tt-item-doc-est.parcela = prazo-compra.parcela.     
                 end. 
    
                 assign tt-item-doc-est.encerra-pa     = no
                        tt-item-doc-est.log-1          = NO /* FIFO */ 
                        tt-item-doc-est.parcela        = tt-int-ds-it-doc.parcela
                        tt-item-doc-est.nr-ord-prod    = 0
                        tt-item-doc-est.cod-roteiro    = ""
                        tt-item-doc-est.op-codigo      = 0
                        tt-item-doc-est.item-pai       = ""
                        tt-item-doc-est.conta-contabil = "" 
                        tt-item-doc-est.baixa-ce       = YES 
                        tt-item-doc-est.quantidade     = it-doc-fisico.quantidade
                        tt-item-doc-est.cod-depos      = it-doc-fisico.cod-depos
                        tt-item-doc-est.class-fiscal   = item.class-fiscal
                        tt-item-doc-est.preco-total[1] = it-doc-fisico.preco-total[1].           
                        
           END.
           
       END. 
    
    END.

END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-geraErro w-digita 
PROCEDURE pi-geraErro :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
DEF INPUT PARAMETER p-descricao AS CHAR.

DEF VAR i-erro AS INTEGER.

ASSIGN i-erro = 1.

FOR LAST tt-erro-xml:
   ASSIGN i-erro = tt-erro-xml.cd-erro + 1.
END.

CREATE tt-erro-xml.
ASSIGN tt-erro-xml.cd-erro     = i-erro
       tt-erro-xml.arquivo     = tt-nota-xml.arquivo
       tt-erro-xml.nNF         = tt-nota-xml.nNF
       tt-erro-xml.serie       = tt-nota-xml.serie
       tt-erro-xml.descricao   = p-descricao.

IF AVAIL tt-it-nota-xml THEN
    ASSIGN tt-erro-xml.sequencia    = tt-it-nota-xml.sequencia
           tt-erro-xml.num-pedido   = tt-it-nota-xml.num-pedido
           tt-erro-xml.numero-ordem = tt-it-nota-xml.numero-ordem.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-geraNota w-digita 
PROCEDURE pi-geraNota :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

DEF VAR i-seq         AS   INTEGER                  NO-UNDO.
DEF VAR i-num-pedido  LIKE ordem-compra.num-pedido  NO-UNDO.
DEF VAR l-item-ordem  AS LOGICAL                    NO-UNDO.

DEF VAR l-valida   AS   LOGICAL INITIAL NO.
DEF VAR de-pre-uni LIKE ordem-compra.preco-unit NO-UNDO.
DEF VAR i-parcela  LIKE prazo-compra.parcela    NO-UNDO.

assign l-valida = yes.
           
find first param-re no-lock where
           param-re.usuario = c-seg-usuario no-error.
if avail param-re then 
   assign l-valida = not param-re.sem-pedido.  
                    
FIND FIRST param-estoq NO-LOCK NO-ERROR.

FIND FIRST int-ds-param-xml NO-LOCK WHERE 
           int-ds-param-xml.ep-codigo = int(i-ep-codigo-usuario) NO-ERROR.

FIND FIRST serie where 
           serie.serie = tt-nota-xml.serie NO-LOCK NO-ERROR.
IF NOT AVAIL serie THEN 
   RUN pi-geraErro (INPUT "Serie " + tt-nota-xml.serie + " n∆o cadastrada.").

FIND FIRST emitente NO-LOCK WHERE 
           emitente.cod-emitente = tt-nota-xml.cod-emitente NO-ERROR.
IF NOT AVAIL emitente THEN 
   RUN pi-geraErro(INPUT "Fornecedor da nota nao cadastrado.").
     
IF tt-nota-xml.dt-trans <= param-estoq.mensal-ate  
THEN DO:

   RUN pi-geraErro(INPUT "Data de transaá∆o " + string(tt-nota-xml.dt-trans) + " menor do que a data do £ltimo per°odo fechado " + STRING(param-estoq.mensal-ate) + ".").

END.

/* FIND FIRST int-ds-doc NO-LOCK WHERE
           int-ds-doc.nro-docto    = tt-nota-xml.nNF          AND
           int-ds-doc.cod-emitente = tt-nota-xml.cod-emitente AND
           int-ds-doc.serie-docto  = tt-nota-xml.serie        AND 
           int-ds-doc.nat-operacao = tt-nota-xml.nat-operacao AND
           int-ds-doc.tipo-nota    = tt-nota-xml.tipo-nota NO-ERROR.    
IF AVAIL int-ds-doc THEN 
   RUN pi-geraErro(INPUT "Nota j† est† pendente para atualizaá∆o, eliminar pendància").    
*/

ASSIGN d-quant = 0.

IF tt-nota-xml.tipo-nota = 3 /* "NFT" */
THEN DO:
   IF NOT CAN-FIND(FIRST b-tt-it-nota-xml WHERE
                         b-tt-it-nota-xml.arquivo    = tt-nota-xml.arquivo  AND
                         b-tt-it-nota-xml.serie      = tt-nota-xml.serie    AND
                         int(b-tt-it-nota-xml.nNF)   = int(tt-nota-xml.nNF) AND
                         b-tt-it-nota-xml.CNPJ       = tt-nota-xml.CNPJ)
   THEN DO: 
     RUN pi-geraErro(INPUT "Nota Fiscal de Transferància n∆o cadastrada.").
   END.
END.

FOR EACH b-tt-it-nota-xml WHERE
         b-tt-it-nota-xml.arquivo    = tt-nota-xml.arquivo  AND
         b-tt-it-nota-xml.serie      = tt-nota-xml.serie    AND
         int(b-tt-it-nota-xml.nNF)   = int(tt-nota-xml.nNF) AND
         b-tt-it-nota-xml.CNPJ       = tt-nota-xml.CNPJ
   BREAK BY b-tt-it-nota-xml.xprod :
        
   IF b-tt-it-nota-xml.tipo-compra = 1 /* */ OR
      b-tt-it-nota-xml.tipo-compra = 3  
   THEN DO:
      FIND FIRST ITEM NO-LOCK WHERE
                 ITEM.it-codigo = b-tt-it-nota-xml.it-codigo AND 
                 ITEM.it-codigo <> ""   NO-ERROR.
      IF NOT AVAIL ITEM THEN
         RUN pi-geraErro(INPUT "ITEM " +  b-tt-it-nota-xml.it-codigo + " n∆o cadastradao." + " Seq. " + STRING(b-tt-it-nota-xml.sequencia)).
   END.

   IF b-tt-it-nota-xml.qOrdem = 0 THEN
     RUN pi-geraErro(INPUT "Quantidade informada deve ser maior que zero para o item " + b-tt-it-nota-xml.it-codigo + " Seq. " + STRING(b-tt-it-nota-xml.sequencia)).

   if l-valida = yes 
   then do:
       FIND FIRST ordem-compra NO-LOCK WHERE
                  ordem-compra.numero-ordem = b-tt-it-nota-xml.numero-ordem NO-ERROR.
       IF AVAIL ordem-compra THEN DO:
         IF b-tt-it-nota-xml.qOrdem > ordem-compra.qt-solic THEN
           RUN pi-geraErro(INPUT "Quantidade informada deve ser menor que a ordem de compra " + STRING(ordem-compra.qt-solic)).
       END.
   END.
   
      
   /*
   ASSIGN d-quant = d-quant + b-tt-it-nota-xml.qOrdem.

   IF LAST-OF(b-tt-it-nota-xml.xprod) 
   THEN DO:
      
      ASSIGN de-fator = 0.

      find item where  
           item.it-codigo = b-tt-it-nota-xml.it-codigo no-lock no-error.
      
        find item-fornec where 
             item-fornec.it-codigo = item.it-codigo and
             item-fornec.cod-emite = tt-nota-xml.cod-emite and
             item-fornec.ativo no-lock no-error.
        if avail item-fornec then 
            de-fator = item-fornec.fator-conver / if item-fornec.num-casa-dec = 0 then 1
                        else exp(10, item-fornec.num-casa-dec). 
        else do:
            find tab-conv-un where 
                 tab-conv-un.un           = item.un and 
                 tab-conv-un.unid-med-for = b-tt-it-nota-xml.uCom no-lock no-error.
            assign de-fator = if avail tab-conv-un then
                               tab-conv-un.fator-conver / exp(10, tab-conv-un.num-casa-dec) else 1.
        end.
        
        if  de-fator = 0 or de-fator = ? then assign de-fator = 1.
        
        IF ROUND((b-tt-it-nota-xml.qCom * de-fator),2) <> d-quant THEN
          RUN pi-geraErro(INPUT "Quantidades informadas " + STRING(d-quant) + " diferente do total do item " + b-tt-it-nota-xml.it-codigo + " da nota " + string(b-tt-it-nota-xml.qCom * de-fator)).       
       
        ASSIGN d-quant = 0.
   END. */


END.       

if l-valida = yes 
then do:

    bloco:
    FOR EACH tt-it-nota-xml WHERE
             tt-it-nota-xml.arquivo = tt-nota-xml.arquivo   AND
             tt-it-nota-xml.serie   = tt-nota-xml.serie     AND
             int(tt-it-nota-xml.nNF) = int(tt-nota-xml.nNF) AND
             tt-it-nota-xml.CNPJ    = tt-nota-xml.CNPJ      AND
            (tt-it-nota-xml.tipo-nota = 1 /* "NFE" */ OR 
             (tt-it-nota-xml.tipo-nota = 2 /* "NFG" */  AND
              tt-it-nota-xml.tipo-compra = 2)) :
       
        ASSIGN i-num-pedido = 0.
       
        FIND FIRST ordem-compra NO-LOCK WHERE
                   ordem-compra.numero-ordem = tt-it-nota-xml.numero-ordem NO-ERROR.
        IF NOT AVAIL ordem-compra THEN DO:
            RUN pi-geraErro (INPUT "Ordem de compra nao cadastrada.").
        END.                                                                            
        ELSE DO:
            ASSIGN i-num-pedido = ordem-compra.num-pedido.
    
            IF ordem-compra.situacao <> 2 THEN
               RUN pi-geraErro (INPUT "Situaá∆o da ordem de compra n∆o permite recebimento.").
        END.
            
        FIND FIRST pedido-compr NO-LOCK WHERE
                   pedido-compr.num-pedido = i-num-pedido NO-ERROR.
        IF NOT AVAIL pedido-compr THEN DO:
            RUN pi-geraErro (INPUT "Pedido de compra da ordem nao cadastrado.").
        END.
        ELSE DO:
    
            FIND FIRST emitente NO-LOCK WHERE 
                       emitente.cod-emitente = pedido-compr.cod-emitente NO-ERROR.
            IF AVAIL emitente THEN DO:
               IF substring(emitente.cgc,1,8) <> substring(tt-nota-xml.cnpj,1,8) THEN
                  RUN pi-geraErro(INPUT "Fornecdor do pedido : " + string(emitente.cod-emitente) + " - " + 
                                         emitente.nome-emit + " diferente do fornecedor da nota.").  
            END.
            
            /* Qdo o controle for por lote n∆o pode fazer a validaá∆o 
            FIND FIRST b-tt-it-nota-xml WHERE
                       b-tt-it-nota-xml.arquivo      = tt-nota-xml.arquivo  AND
                       b-tt-it-nota-xml.serie        = tt-nota-xml.serie    AND
                       b-tt-it-nota-xml.nNF          = tt-nota-xml.nNF      AND
                       b-tt-it-nota-xml.CNPJ         = tt-nota-xml.CNPJ     AND
                       b-tt-it-nota-xml.numero-ordem = tt-it-nota-xml.numero-ordem AND
                       b-tt-it-nota-xml.sequencia    <> tt-it-nota-xml.sequencia NO-ERROR.
            IF AVAIL b-tt-it-nota-xml THEN
               RUN pi-geraErro (INPUT "Ordem de compra j† informada na sequencia " + STRING(b-tt-it-nota-xml.sequencia) + ".").
               
            */
    
            ASSIGN d-quant = 0.
    
            FOR EACH ordem-compra NO-LOCK WHERE 
                     ordem-compra.num-pedido   = pedido-compr.num-pedido     AND 
                     ordem-compra.numero-ordem = tt-it-nota-xml.numero-ordem AND
                     ordem-compra.situacao     = 2 :
               
                FOR FIRST prazo-compra OF ordem-compra NO-LOCK WHERE
                          prazo-compra.situacao    = ordem-compra.situacao AND 
                          prazo-compra.quant-saldo - prazo-compra.dec-1 > 0 :
                    
                    ASSIGN d-quant = prazo-compra.quant-saldo - prazo-compra.dec-1.
                    
                END.        
    
                FOR EACH int-ds-doc NO-LOCK WHERE
                         int-ds-doc.ep-codigo = int(i-ep-codigo-usuario) AND
                         int-ds-doc.situacao  = 2,
                     EACH int-ds-it-doc OF int-ds-doc NO-LOCK WHERE   
                         int-ds-it-doc.num-pedido   = ordem-compra.num-pedido   AND
                         int-ds-it-doc.numero-ordem = ordem-compra.numero-ordem :
        
                     ASSIGN d-quant = d-quant - int-ds-it-doc.quantidade.
                        
                 END.
    
                 FOR EACH int-ds-it-doc NO-LOCK WHERE
                         ((int-ds-it-doc.nro-docto         = tt-it-nota-xml.nNF  AND
                          int-ds-it-doc.sequencia    <> tt-it-nota-xml.sequencia) OR
                          (int(int-ds-it-doc.nro-docto)  <> int(tt-it-nota-xml.nNF)))  AND
                          int-ds-it-doc.num-pedido   = ordem-compra.num-pedido   AND
                          int-ds-it-doc.numero-ordem = ordem-compra.numero-ordem :
        
                     ASSIGN d-quant = d-quant - int-ds-it-doc.quantidade.
                        
                 END.
    
            END.
             
            IF tt-it-nota-xml.qOrdem > d-quant THEN 
              RUN pi-geraErro(INPUT "Saldo da ordem de compra " + STRING(d-quant) + " insuficiente para quantidade informada " + string(tt-it-nota-xml.qOrdem)).    
                
        END.    
    
    END.
END.

FIND FIRST tt-erro-xml WHERE
           tt-erro-xml.arquivo  = tt-nota-xml.arquivo AND
           int(tt-erro-xml.nNF) = int(tt-nota-xml.nNF) AND
           tt-erro-xml.serie    = tt-nota-xml.serie NO-ERROR.
IF NOT AVAIL tt-erro-xml 
THEN DO:
        
       FIND FIRST tt-int-ds-doc NO-LOCK WHERE
                  tt-int-ds-doc.tipo-nota      = tt-nota-xml.tipo-nota    AND
                  int(tt-int-ds-doc.nro-docto) = int(tt-nota-xml.nNF)     AND
                  tt-int-ds-doc.cod-emitente   = tt-nota-xml.cod-emitente AND
                  tt-int-ds-doc.serie-docto    = tt-nota-xml.serie NO-ERROR.    
       IF NOT AVAIL tt-int-ds-doc THEN DO:
          CREATE tt-int-ds-doc.
          ASSIGN tt-int-ds-doc.ep-codigo    = int(i-ep-codigo-usuario)
                 tt-int-ds-doc.tipo-nota    = tt-nota-xml.tipo-nota  
                 tt-int-ds-doc.marca        = tt-nota-xml.marca
                 tt-int-ds-doc.situacao     = 2 
                 tt-int-ds-doc.nro-docto    = tt-nota-xml.nNF      
                 tt-int-ds-doc.cod-emitente = tt-nota-xml.cod-emitente 
                 tt-int-ds-doc.serie-docto  = tt-nota-xml.serie
                 tt-int-ds-doc.dt-trans     = tt-nota-xml.dt-trans
                 tt-int-ds-doc.dt-emissao   = tt-nota-xml.dEmi
                 tt-int-ds-doc.usuario      = c-seg-usuario 
                 tt-int-ds-doc.tot-valor    = tt-nota-xml.VNF
                 tt-int-ds-doc.arquivo      = tt-nota-xml.arquivo
                 tt-int-ds-doc.chnfe        = tt-nota-xml.chnfe.
                 
          FIND FIRST int-ds-docto-xml NO-LOCK WHERE
                     int-ds-docto-xml.serie        = tt-nota-xml.serie AND 
                     int(int-ds-docto-xml.nNF)     = int(tt-nota-xml.nNF)   AND     
                     int-ds-docto-xml.cod-emitente = tt-nota-xml.cod-emitente AND 
                     int-ds-docto-xml.tipo-nota    = tt-nota-xml.tipo-nota NO-ERROR.
          IF AVAIL int-ds-docto-xml THEN 
             ASSIGN tt-int-ds-doc.r-rowid = ROWID(int-ds-docto-xml)
                    c-estab-orig          = int-ds-docto-xml.cod-estab.
          ELSE 
             ASSIGN c-estab-orig = param-estoq.estabel-pad.

          FOR FIRST tt-it-nota-xml WHERE
                    tt-it-nota-xml.arquivo  = tt-nota-xml.arquivo  AND
                    tt-it-nota-xml.serie    = tt-nota-xml.serie    AND
                    int(tt-it-nota-xml.nNF) = int(tt-nota-xml.nNF) AND
                    tt-it-nota-xml.CNPJ     = tt-nota-xml.CNPJ:

              FIND FIRST ordem-compra NO-LOCK WHERE
                         ordem-compra.numero-ordem = tt-it-nota-xml.numero-ordem NO-ERROR.
              IF AVAIL ordem-compra THEN
                ASSIGN c-estab-orig = ordem-compra.cod-estabel.

          END.

          ASSIGN tt-int-ds-doc.cod-estabel = c-estab-orig.
            
          IF tt-nota-xml.tipo-nota = 3 /* "NFT" */ THEN DO:
          
             ASSIGN tt-int-ds-doc.tipo-nota    = 3 /* NFT */ 
                    tt-int-ds-doc.estab-de-or  = tt-nota-xml.estab-de-or.

             FIND FIRST b-estabelec NO-LOCK WHERE
                        b-estabelec.cod-emitente = tt-nota-xml.cod-emitente NO-ERROR.
             IF AVAIL b-estabelec THEN
                ASSIGN tt-int-ds-doc.cod-estabel = b-estabelec.cod-estabel. 

          END.
       END.
                    
       ASSIGN i-seq = 0.
       
       IF tt-nota-xml.tipo-nota = 1 /* "NFE" */ 
       THEN DO:
           FOR EACH tt-it-nota-xml WHERE
                    tt-it-nota-xml.arquivo = tt-nota-xml.arquivo  AND
                    tt-it-nota-xml.serie   = tt-nota-xml.serie    AND
                    int(tt-it-nota-xml.nNF) = int(tt-nota-xml.nNF)  AND
                    tt-it-nota-xml.CNPJ    = tt-nota-xml.CNPJ     AND
                    tt-it-nota-xml.tipo-nota = tt-nota-xml.tipo-nota :

               ASSIGN de-pre-uni = tt-it-nota-xml.vUnCom
                      i-parcela  = 0.

               IF l-valida = YES  THEN DO:
                   
                   FOR FIRST ordem-compra NO-LOCK WHERE
                             ordem-compra.numero-ordem = tt-it-nota-xml.numero-ordem AND
                             ordem-compra.situacao   = 2,
                   FIRST prazo-compra OF ordem-compra NO-LOCK WHERE
                         prazo-compra.situacao   = ordem-compra.situacao AND 
                         prazo-compra.quant-saldo - prazo-compra.dec-1 > 0 :
                     
                       ASSIGN de-pre-uni = ordem-compra.preco-unit
                              i-parcela  = prazo-compra.parcela.

                   END.
               
               END.

               ASSIGN i-seq = i-seq + 10.

               FIND FIRST tt-int-ds-it-doc NO-LOCK WHERE
                          tt-int-ds-it-doc.tipo-nota    = tt-int-ds-doc.tipo-nota    AND 
                          int(tt-int-ds-it-doc.nro-docto) = int(tt-int-ds-doc.nro-docto) AND
                          tt-int-ds-it-doc.cod-emitente = tt-int-ds-doc.cod-emitente AND
                          tt-int-ds-it-doc.serie-docto  = tt-int-ds-doc.serie-docto  AND 
                          tt-int-ds-it-doc.sequencia    = i-seq NO-ERROR.
               IF NOT AVAIL tt-int-ds-it-doc THEN DO: 
                  
                  CREATE tt-int-ds-it-doc.
                  ASSIGN tt-int-ds-it-doc.nro-docto      = tt-int-ds-doc.nro-docto    
                         tt-int-ds-it-doc.cod-emitente   = tt-int-ds-doc.cod-emitente 
                         tt-int-ds-it-doc.serie-docto    = tt-int-ds-doc.serie-docto
                         tt-int-ds-it-doc.nat-operacao   = tt-it-nota-xml.nat-operacao
                         tt-int-ds-it-doc.tipo-nota      = tt-int-ds-doc.tipo-nota
                         tt-int-ds-it-doc.numero-ordem   = tt-it-nota-xml.numero-ordem 
                         tt-int-ds-it-doc.num-pedido     = tt-it-nota-xml.num-pedido 
                         tt-int-ds-it-doc.sequencia      = i-seq
                         tt-int-ds-it-doc.it-codigo      = tt-it-nota-xml.it-codigo
                         tt-int-ds-it-doc.preco-unit[1]  = de-pre-uni
                         tt-int-ds-it-doc.quantidade     = tt-it-nota-xml.qCom
                         tt-int-ds-it-doc.qt-do-forn     = tt-it-nota-xml.qCom-forn
                         tt-int-ds-it-doc.preco-total[1] = (de-pre-uni * tt-it-nota-xml.qCom-forn)
                         tt-int-ds-it-doc.parcela        = i-parcela.
               END.
              
           END.
       END.
       ELSE DO:
           
           FOR EACH tt-it-nota-xml WHERE
                    tt-it-nota-xml.arquivo = tt-nota-xml.arquivo  AND
                    tt-it-nota-xml.serie   = tt-nota-xml.serie    AND
                    int(tt-it-nota-xml.nNF)  = int(tt-nota-xml.nNF)  AND
                    tt-it-nota-xml.CNPJ    = tt-nota-xml.CNPJ     AND
                    tt-it-nota-xml.tipo-nota = tt-nota-xml.tipo-nota:
                
                ASSIGN i-seq = i-seq + 10.
        
                FIND FIRST tt-int-ds-it-doc NO-LOCK WHERE
                           tt-int-ds-it-doc.tipo-nota    = tt-int-ds-doc.tipo-nota    AND 
                           int(tt-int-ds-it-doc.nro-docto) = int(tt-int-ds-doc.nro-docto) AND
                           tt-int-ds-it-doc.cod-emitente = tt-int-ds-doc.cod-emitente AND
                           tt-int-ds-it-doc.serie-docto  = tt-int-ds-doc.serie-docto  AND 
                           tt-int-ds-it-doc.sequencia    = i-seq NO-ERROR.
                IF NOT AVAIL tt-int-ds-it-doc THEN DO: 
                    
                   CREATE tt-int-ds-it-doc.
                   ASSIGN tt-int-ds-it-doc.tipo-nota      = tt-int-ds-doc.tipo-nota     
                          tt-int-ds-it-doc.nro-docto      = tt-int-ds-doc.nro-docto    
                          tt-int-ds-it-doc.cod-emitente   = tt-int-ds-doc.cod-emitente 
                          tt-int-ds-it-doc.serie-docto    = tt-int-ds-doc.serie-docto   
                          tt-int-ds-it-doc.nat-operacao   = tt-it-nota-xml.nat-operacao
                          tt-int-ds-it-doc.numero-ordem   = tt-it-nota-xml.numero-ordem 
                          tt-int-ds-it-doc.num-pedido     = tt-it-nota-xml.num-pedido 
                          tt-int-ds-it-doc.sequencia      = i-seq
                          tt-int-ds-it-doc.it-codigo      = tt-it-nota-xml.it-codigo
                          tt-int-ds-it-doc.preco-unit[1]  = tt-it-nota-xml.vProd
                          tt-int-ds-it-doc.quantidade     = tt-it-nota-xml.qOrdem
                          tt-int-ds-it-doc.qt-do-forn     = tt-it-nota-xml.qCom-forn
                          tt-int-ds-it-doc.preco-total[1] = (tt-int-ds-it-doc.preco-unit[1] * tt-int-ds-it-doc.qt-do-forn)
                          tt-int-ds-it-doc.parcela        = 1. 
                END.
           END.
       END. 
END.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE send-records w-digita  _ADM-SEND-RECORDS
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
  {src/adm/template/snd-list.i "emitente"}
  {src/adm/template/snd-list.i "tt-it-nota-xml"}
  {src/adm/template/snd-list.i "tt-erro-xml"}

  /* Deal with any unexpected table requests before closing.           */
  {src/adm/template/snd-end.i}

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE state-changed w-digita 
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

