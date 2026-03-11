&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
          custom           PROGRESS
*/
&Scoped-define WINDOW-NAME wWindow

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DECLARATIONS wWindow 
USING OpenEdge.Core.*.
USING OpenEdge.Net.HTTP.RequestBuilder.
USING OpenEdge.Net.HTTP.IHttpClient.
USING OpenEdge.Net.HTTP.IHttpRequest.
USING OpenEdge.Net.HTTP.IHttpResponse.
USING OpenEdge.Net.HTTP.ClientBuilder.
USING OpenEdge.Net.HTTP.lib.ClientLibraryBuilder.
USING OpenEdge.Net.URI.
USING Progress.Json.ObjectModel.*.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME




/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE tt-esp_dootax_pagamento NO-UNDO LIKE esp_dootax_pagamento
       field cod-situacao as char
       field ind-situacao as int
       field openPayments as char extent 15
       field r-rowid as rowid
       index id-sit ind-situacao id.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS wWindow 
/*:T*******************************************************************************
** Copyright TOTVS S.A. (2009)
** Todos os Direitos Reservados.
**
** Este fonte e de propriedade exclusiva da TOTVS, sua reproducao
** parcial ou total por qualquer meio, so podera ser feita mediante
** autorizacao expressa.
*******************************************************************************/
{include/i-prgvrs.i NICR034 2.00.00.000}

/* Chamada a include do gerenciador de licenáas. Necessario alterar os parametros */
/*                                                                                */
/* <programa>:  Informar qual o nome do programa.                                 */
/* <m¢dulo>:  Informar qual o m¢dulo a qual o programa pertence.                  */

&IF "{&EMSFND_VERSION}" >= "1.00" &THEN
    {include/i-license-manager.i NICR034 NICR}
&ENDIF

CREATE WIDGET-POOL.

/* Preprocessors Definitions ---                                      */
&GLOBAL-DEFINE Program        NICR034
&GLOBAL-DEFINE Version        2.00.00.000

&GLOBAL-DEFINE WindowType     Master

&GLOBAL-DEFINE Folder         NO
&GLOBAL-DEFINE InitialPage    1
&GLOBAL-DEFINE FolderLabels   <Folder1 ,Folder 2 ,... , Folder8>

&GLOBAL-DEFINE page0Widgets   btParam BROWSE-2 bt-estadoFornec~
                              btQueryJoins btReportsJoins btExit btHelp ~
                              dt-ini dt-fim co-situacao ~
                              btBuscar btGeraTitulos btAtualizarDooTax btHelp2

&GLOBAL-DEFINE page1Widgets   
&GLOBAL-DEFINE page2Widgets   

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */
DEFINE VARIABLE c-host  AS CHARACTER   NO-UNDO.
DEFINE VARIABLE c-alias AS CHARACTER   NO-UNDO.
DEFINE VARIABLE c-token AS CHARACTER   NO-UNDO.

DEFINE VARIABLE l-atualiza AS LOGICAL     NO-UNDO.
DEFINE VARIABLE c-arquivo  AS CHARACTER   NO-UNDO.

DEF TEMP-TABLE tt-esp_dootax_pagamento-aux NO-UNDO
    LIKE tt-esp_dootax_pagamento.

def temp-table tt-sel no-undo
    field rowid_dootax  as rowid
    field v_estab       as char
    field v_espec_docto as char
    field v_ser_docto   as char
    field v_fornecedor  as int
    field v_tit_ap      as char
    field v_parcela     as char.
    
{intprg\nicr034.i}  // TEMP-TABLE API IMPLANTAÄ«O TITULOS APB APB900ZG
{intprg\nicr034.i2} // TEMP-TABLE API PAGAMENTO VIA BORDER‚ APB APB902ZE

def new global shared var v_rec_bord_ap
    as recid
    format ">>>>>>9":U
    initial ?
    no-undo.

def new global shared var v_cod_ccusto_corren
    as character
    format "x(11)":U
    label "Centro Custo"
    column-label "Centro Custo"
    no-undo.

def new global shared var v_cod_plano_ccusto_corren
    as character
    format "x(8)":U
    label "Plano CCusto"
    column-label "Plano CCusto"
    no-undo.

def new global shared var v_log_atualiza_refer_apb
    as logical
    format "Sim/N?o"
    initial NO
    view-as toggle-box
    label "Atualiza Referencia"
    column-label "Atualiza Referencia"
    no-undo.

def new global shared var v_log_envia_aed
    as logical
    format "Sim/N?o"
    initial yes
    no-undo.

def new global shared var v_rec_lote_impl_tit_ap
    as recid
    format ">>>>>>9":U
    initial ?
    no-undo.

def var v_rec_lote_impl_tit_ap_aux
    as recid
    format ">>>>>>9":U
    initial ?
    no-undo.


DEFINE BUFFER b-emitente FOR emitente.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Window
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME fpage0
&Scoped-define BROWSE-NAME BROWSE-2

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-esp_dootax_pagamento

/* Definitions for BROWSE BROWSE-2                                      */
&Scoped-define FIELDS-IN-QUERY-BROWSE-2 tt-esp_dootax_pagamento.id tt-esp_dootax_pagamento.titleId tt-esp_dootax_pagamento.cod-situacao tt-esp_dootax_pagamento.companyCnpj tt-esp_dootax_pagamento.insertDate tt-esp_dootax_pagamento.period tt-esp_dootax_pagamento.docType tt-esp_dootax_pagamento.revenueCode tt-esp_dootax_pagamento.taxName tt-esp_dootax_pagamento.state tt-esp_dootax_pagamento.docNum tt-esp_dootax_pagamento.series tt-esp_dootax_pagamento.accessKey tt-esp_dootax_pagamento.canceled tt-esp_dootax_pagamento.cod-status tt-esp_dootax_pagamento.totalAmount tt-esp_dootax_pagamento.originalDueDate tt-esp_dootax_pagamento.barcode tt-esp_dootax_pagamento.controlNum tt-esp_dootax_pagamento.userImportedFile tt-esp_dootax_pagamento.debitDate   
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-2   
&Scoped-define SELF-NAME BROWSE-2
&Scoped-define OPEN-QUERY-BROWSE-2 IF co-situacao:INPUT-VALUE IN FRAME fPage0 = 5 THEN    OPEN QUERY {&SELF-NAME}       FOR EACH tt-esp_dootax_pagamento NO-LOCK           BY tt-esp_dootax_pagamento.id. ELSE    OPEN QUERY {&SELF-NAME}       FOR EACH tt-esp_dootax_pagamento          WHERE tt-esp_dootax_pagamento.ind-situacao = co-situacao:INPUT-VALUE IN FRAME fPage0 NO-LOCK          BY tt-esp_dootax_pagamento.id.
&Scoped-define TABLES-IN-QUERY-BROWSE-2 tt-esp_dootax_pagamento
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-2 tt-esp_dootax_pagamento


/* Definitions for FRAME fpage0                                         */
&Scoped-define OPEN-BROWSERS-IN-QUERY-fpage0 ~
    ~{&OPEN-QUERY-BROWSE-2}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS rtToolBar-2 rtToolBar IMAGE-1 IMAGE-2 ~
btQueryJoins btReportsJoins btExit btHelp btParam bt-estadoFornec dt-ini ~
dt-fim co-situacao BROWSE-2 btBuscar btGeraTitulos btAtualizarDooTax ~
btHelp2 
&Scoped-Define DISPLAYED-OBJECTS dt-ini dt-fim co-situacao 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR wWindow AS WIDGET-HANDLE NO-UNDO.

/* Menu Definitions                                                     */
DEFINE SUB-MENU smFile 
       MENU-ITEM miQueryJoins   LABEL "&Consultas"    
       MENU-ITEM miReportsJoins LABEL "&Relat¢rios"   
       RULE
       MENU-ITEM miExit         LABEL "&Sair"          ACCELERATOR "CTRL-X".

DEFINE SUB-MENU smHelp 
       MENU-ITEM miContents     LABEL "&Conte£do"     
       MENU-ITEM miAbout        LABEL "&Sobre..."     .

DEFINE MENU mbMain MENUBAR
       SUB-MENU  smFile         LABEL "&Arquivo"      
       SUB-MENU  smHelp         LABEL "&Ajuda"        .


/* Definitions of the field level widgets                               */
DEFINE BUTTON bt-estadoFornec 
     LABEL "Estado Fornec" 
     SIZE 11 BY 1.

DEFINE BUTTON btAtualizarDooTax 
     LABEL "Atualizar DooTax" 
     SIZE 13 BY 1.

DEFINE BUTTON btBuscar 
     LABEL "Buscar" 
     SIZE 10 BY 1.

DEFINE BUTTON btExit 
     IMAGE-UP FILE "image\im-exi":U
     IMAGE-INSENSITIVE FILE "image\ii-exi":U
     LABEL "Exit" 
     SIZE 4 BY 1.25
     FONT 4.

DEFINE BUTTON btGeraTitulos 
     LABEL "Gerar Titulos" 
     SIZE 13 BY 1.

DEFINE BUTTON btHelp 
     IMAGE-UP FILE "image\im-hel":U
     IMAGE-INSENSITIVE FILE "image\ii-hel":U
     LABEL "Help" 
     SIZE 4 BY 1.25
     FONT 4.

DEFINE BUTTON btHelp2 
     LABEL "Ajuda" 
     SIZE 10 BY 1.

DEFINE BUTTON btParam 
     IMAGE-UP FILE "image\im-param.gif":U
     LABEL "" 
     SIZE 4 BY 1.13 TOOLTIP "ParÉmetros".

DEFINE BUTTON btQueryJoins 
     IMAGE-UP FILE "image\im-joi":U
     IMAGE-INSENSITIVE FILE "image\ii-joi":U
     LABEL "Query Joins" 
     SIZE 4 BY 1.25
     FONT 4.

DEFINE BUTTON btReportsJoins 
     IMAGE-UP FILE "image\im-pri":U
     IMAGE-INSENSITIVE FILE "image\ii-pri":U
     LABEL "Reports Joins" 
     SIZE 4 BY 1.25
     FONT 4.

DEFINE VARIABLE co-situacao AS INTEGER FORMAT ">>9":U INITIAL 1 
     LABEL "Situaá∆o" 
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEM-PAIRS "Aguardando Implantaá∆o",1,
                     "Pendente Pagamento",2,
                     "Titulo pago",3,
                     "Integrado Dootax",4,
                     "Todos",5
     DROP-DOWN-LIST
     SIZE 24 BY 1 NO-UNDO.

DEFINE VARIABLE dt-fim AS DATE FORMAT "99/99/9999":U 
     VIEW-AS FILL-IN 
     SIZE 12 BY .88 NO-UNDO.

DEFINE VARIABLE dt-ini AS DATE FORMAT "99/99/9999":U 
     LABEL "Data" 
     VIEW-AS FILL-IN 
     SIZE 11 BY .88 NO-UNDO.

DEFINE IMAGE IMAGE-1
     FILENAME "image\im-fir":U
     SIZE 3 BY .88.

DEFINE IMAGE IMAGE-2
     FILENAME "image\im-las":U
     SIZE 3 BY .88.

DEFINE RECTANGLE rtToolBar
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 90 BY 1.42
     BGCOLOR 7 .

DEFINE RECTANGLE rtToolBar-2
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 90 BY 1.5
     BGCOLOR 7 .

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BROWSE-2 FOR 
      tt-esp_dootax_pagamento SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BROWSE-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-2 wWindow _FREEFORM
  QUERY BROWSE-2 NO-LOCK DISPLAY
      tt-esp_dootax_pagamento.id COLUMN-LABEL "ID Pagamento" FORMAT "->>>>>>>,>>>,>>9":U
      tt-esp_dootax_pagamento.titleId COLUMN-LABEL "ID Titulo" FORMAT "->,>>>,>>9":U
      tt-esp_dootax_pagamento.cod-situacao COLUMN-LABEL "Situaá∆o" FORMAT "X(50)"
            WIDTH 17
      tt-esp_dootax_pagamento.companyCnpj COLUMN-LABEL "CNPJ" FORMAT "x(50)":U
            WIDTH 15
      tt-esp_dootax_pagamento.insertDate COLUMN-LABEL "Data criaá∆o" FORMAT "99/99/9999":U
      tt-esp_dootax_pagamento.period COLUMN-LABEL "Periodo" FORMAT "99/99/9999":U
      tt-esp_dootax_pagamento.docType COLUMN-LABEL "Tipo documento" FORMAT "x(20)":U
            WIDTH 12
      tt-esp_dootax_pagamento.revenueCode COLUMN-LABEL "Referencia" FORMAT "->>>>>>9":U
      tt-esp_dootax_pagamento.taxName COLUMN-LABEL "Tipo Imposto" FORMAT "x(20)":U
            WIDTH 12
      tt-esp_dootax_pagamento.state COLUMN-LABEL "Estado" FORMAT "x(2)":U
      tt-esp_dootax_pagamento.docNum COLUMN-LABEL "N Nota Fiscal" FORMAT "x(50)":U
            WIDTH 15
      tt-esp_dootax_pagamento.series COLUMN-LABEL "SÇrie" FORMAT "x(10)":U
            WIDTH 7
      tt-esp_dootax_pagamento.accessKey COLUMN-LABEL "Chave" FORMAT "x(100)":U
            WIDTH 30
      tt-esp_dootax_pagamento.canceled COLUMN-LABEL "Cancelada" FORMAT "SIM/Nao":U
      tt-esp_dootax_pagamento.cod-status COLUMN-LABEL "Status" FORMAT "x(100)":U
            WIDTH 12
      tt-esp_dootax_pagamento.totalAmount COLUMN-LABEL "Valor Total" FORMAT "->>,>>9.99":U
      tt-esp_dootax_pagamento.originalDueDate COLUMN-LABEL "Data de Emiss∆o" FORMAT "99/99/9999":U
      tt-esp_dootax_pagamento.barcode COLUMN-LABEL "C¢digo de barras" FORMAT "x(100)":U
            WIDTH 30
      tt-esp_dootax_pagamento.controlNum COLUMN-LABEL "N£mero de controle" FORMAT "x(100)":U
            WIDTH 15
      tt-esp_dootax_pagamento.userImportedFile COLUMN-LABEL "Usu†rio Dootax" FORMAT "x(100)":U
            WIDTH 15
      tt-esp_dootax_pagamento.debitDate COLUMN-LABEL "Data de DÇbito" FORMAT "99/99/9999":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS MULTIPLE SIZE 90 BY 12.5
         FONT 1 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME fpage0
     btQueryJoins AT ROW 1.13 COL 74.72 HELP
          "Consultas relacionadas"
     btReportsJoins AT ROW 1.13 COL 78.72 HELP
          "Relat¢rios relacionados"
     btExit AT ROW 1.13 COL 82.72 HELP
          "Sair"
     btHelp AT ROW 1.13 COL 86.72 HELP
          "Ajuda"
     btParam AT ROW 1.25 COL 2
     bt-estadoFornec AT ROW 1.29 COL 7.14 WIDGET-ID 16
     dt-ini AT ROW 2.75 COL 16 COLON-ALIGNED WIDGET-ID 2
     dt-fim AT ROW 2.75 COL 34 COLON-ALIGNED NO-LABEL WIDGET-ID 4
     co-situacao AT ROW 2.79 COL 62 COLON-ALIGNED WIDGET-ID 14
     BROWSE-2 AT ROW 4 COL 1 WIDGET-ID 200
     btBuscar AT ROW 16.75 COL 2
     btGeraTitulos AT ROW 16.75 COL 13 WIDGET-ID 12
     btAtualizarDooTax AT ROW 16.75 COL 27 WIDGET-ID 10
     btHelp2 AT ROW 16.75 COL 80
     rtToolBar-2 AT ROW 1 COL 1
     rtToolBar AT ROW 16.54 COL 1
     IMAGE-1 AT ROW 2.75 COL 29 WIDGET-ID 6
     IMAGE-2 AT ROW 2.75 COL 33 WIDGET-ID 8
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 90 BY 17
         FONT 1 WIDGET-ID 100.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Window
   Allow: Basic,Browse,DB-Fields,Window,Query
   Add Fields to: Neither
   Other Settings: COMPILE
   Temp-Tables and Buffers:
      TABLE: tt-esp_dootax_pagamento T "?" NO-UNDO custom esp_dootax_pagamento
      ADDITIONAL-FIELDS:
          field cod-situacao as char
          field ind-situacao as int
          field openPayments as char extent 15
          field r-rowid as rowid
          index id-sit ind-situacao id
      END-FIELDS.
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
IF SESSION:DISPLAY-TYPE = "GUI":U THEN
  CREATE WINDOW wWindow ASSIGN
         HIDDEN             = YES
         TITLE              = ""
         HEIGHT             = 17
         WIDTH              = 90
         MAX-HEIGHT         = 17
         MAX-WIDTH          = 90
         VIRTUAL-HEIGHT     = 17
         VIRTUAL-WIDTH      = 90
         RESIZE             = yes
         SCROLL-BARS        = no
         STATUS-AREA        = yes
         BGCOLOR            = ?
         FGCOLOR            = ?
         KEEP-FRAME-Z-ORDER = yes
         THREE-D            = yes
         MESSAGE-AREA       = no
         SENSITIVE          = yes.
ELSE {&WINDOW-NAME} = CURRENT-WINDOW.

ASSIGN {&WINDOW-NAME}:MENUBAR    = MENU mbMain:HANDLE.
/* END WINDOW DEFINITION                                                */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _INCLUDED-LIB wWindow 
/* ************************* Included-Libraries *********************** */

{window/window.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME




/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW wWindow
  NOT-VISIBLE,,RUN-PERSISTENT                                           */
/* SETTINGS FOR FRAME fpage0
   FRAME-NAME                                                           */
/* BROWSE-TAB BROWSE-2 co-situacao fpage0 */
IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(wWindow)
THEN wWindow:HIDDEN = yes.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-2
/* Query rebuild information for BROWSE BROWSE-2
     _START_FREEFORM
IF co-situacao:INPUT-VALUE IN FRAME fPage0 = 5 THEN
   OPEN QUERY {&SELF-NAME}
      FOR EACH tt-esp_dootax_pagamento NO-LOCK
          BY tt-esp_dootax_pagamento.id.
ELSE
   OPEN QUERY {&SELF-NAME}
      FOR EACH tt-esp_dootax_pagamento
         WHERE tt-esp_dootax_pagamento.ind-situacao = co-situacao:INPUT-VALUE IN FRAME fPage0 NO-LOCK
         BY tt-esp_dootax_pagamento.id.
     _END_FREEFORM
     _Options          = "NO-LOCK"
     _Query            is OPENED
*/  /* BROWSE BROWSE-2 */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK FRAME fpage0
/* Query rebuild information for FRAME fpage0
     _Options          = "SHARE-LOCK KEEP-EMPTY"
     _Query            is NOT OPENED
*/  /* FRAME fpage0 */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME wWindow
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL wWindow wWindow
ON END-ERROR OF wWindow
OR ENDKEY OF {&WINDOW-NAME} ANYWHERE DO:
  /* This case occurs when the user presses the "Esc" key.
     In a persistently run window, just ignore this.  If we did not, the
     application would exit. */
  IF THIS-PROCEDURE:PERSISTENT THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL wWindow wWindow
ON WINDOW-CLOSE OF wWindow
DO:
  /* This event will close the window and terminate the procedure.  */
  APPLY "CLOSE":U TO THIS-PROCEDURE.
  RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-estadoFornec
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-estadoFornec wWindow
ON CHOOSE OF bt-estadoFornec IN FRAME fpage0 /* Estado Fornec */
DO:

    RUN esp\esef0101.r.
  
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btAtualizarDooTax
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btAtualizarDooTax wWindow
ON CHOOSE OF btAtualizarDooTax IN FRAME fpage0 /* Atualizar DooTax */
DO:
    ASSIGN c-arquivo  = SESSION:TEMP-DIR + "/retornopagamento" + REPLACE(STRING(TODAY,"99/99/9999"),"/","") + REPLACE(STRING(TIME,"HH:MM:SS"),":","") + ".txt"
           l-atualiza = NO.

    OUTPUT TO VALUE(c-arquivo).

    EMPTY TEMP-TABLE tt-esp_dootax_pagamento-aux.

    FOR EACH tt-esp_dootax_pagamento,
        FIRST estabelecimento NO-LOCK
        WHERE estabelecimento.cod_estab = tt-esp_dootax_pagamento.branchCode:

        FOR FIRST nota-fiscal NO-LOCK
            WHERE nota-fiscal.cod-estabel = tt-esp_dootax_pagamento.branchCode
            AND   nota-fiscal.serie       = tt-esp_dootax_pagamento.series
            AND   nota-fiscal.nr-nota-fis = FILL("0",7 - LENGTH(tt-esp_dootax_pagamento.docNum)) + tt-esp_dootax_pagamento.docNum: END.

        FOR FIRST tit_ap NO-LOCK
            WHERE tit_ap.cod_empresa     = estabelecimento.cod_empresa 
            AND   tit_ap.cod_estab       = estabelecimento.cod_estab
            AND   tit_ap.cod_espec_docto = "FL"
            AND   tit_ap.cod_ser_docto   = tt-esp_dootax_pagamento.series        
            AND   tit_ap.cdn_fornecedor  = nota-fiscal.cod-emitente
            AND   tit_ap.cod_tit_ap      = tt-esp_dootax_pagamento.cod_tit_ap
            AND   tit_ap.cod_parcela     = "": END.
    
        IF  AVAIL tit_ap 
        AND tit_ap.dat_liquidac_tit_ap <> ?
        AND tit_ap.val_sdo_tit_ap = 0 
        AND tt-esp_dootax_pagamento.log_envio_dootax = NO THEN DO:
            ASSIGN l-atualiza = YES.
            RUN pi-gera-arq-dootax.
        END.
            
    END.

    OUTPUT CLOSE.

    IF l-atualiza = YES THEN
        RUN pi-atualiza-dooTax.
    ELSE
        RUN utp/ut-msgs.p (INPUT "show", 
                           INPUT "17006", 
                           INPUT "Integraá∆o n∆o realizada!~~Nenhum registro pendente de atualizaá∆o.").
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btBuscar
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btBuscar wWindow
ON CHOOSE OF btBuscar IN FRAME fpage0 /* Buscar */
DO:
    RUN pi-busca.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btExit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btExit wWindow
ON CHOOSE OF btExit IN FRAME fpage0 /* Exit */
OR CHOOSE OF MENU-ITEM miExit IN MENU mbMain DO:
    APPLY "CLOSE":U TO THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btGeraTitulos
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btGeraTitulos wWindow
ON CHOOSE OF btGeraTitulos IN FRAME fpage0 /* Gerar Titulos */
DO:
    DEF VAR v_linha      as int no-undo.
    DEF VAR v_log_method as log no-undo.

    ASSIGN v_rec_bord_ap = ?.
    
    // Grava linhas selecionadas 
    empty temp-table tt-sel.
    DO  v_linha = 1 to browse BROWSE-2:num-selected-rows:

        assign v_log_method = browse BROWSE-2:fetch-selected-row(v_linha).

        if  tt-esp_dootax_pagamento.cod_tit_ap <> "" then
            next. // Linha selecionada j† foi gerado o titulo.
        if  tt-esp_dootax_pagamento.ind-situacao <> 1 then
            next. // N∆o est† aguardando implantaá∆o.

        create tt-sel.
        assign tt-sel.rowid_dootax = ROWID(tt-esp_dootax_pagamento).
    END.
    
    if  not can-find(first tt-sel) then
        return "OK".

    if  session:set-wait-state('general') then.
    
    LOTE:
    DO TRANSACTION
       ON ERROR UNDO LOTE, LEAVE LOTE
       ON STOP  UNDO LOTE, LEAVE LOTE:
       
       // Implanta titulos
       RUN pi-integra-ap.
       
       IF  RETURN-VALUE <> "OK" THEN DO:
       
            ASSIGN tt-esp_dootax_pagamento.ind-situacao = 1
                   tt-esp_dootax_pagamento.cod-situacao = "Aguardando Implantaá∆o".
            UNDO LOTE, LEAVE LOTE.
       END.
           
     /*  
       // Cria borderì escritural para os t°tulos
       RUN pi-pagar-via-bordero.
    
       IF  RETURN-VALUE <> "OK" THEN DO:
       
            ASSIGN tt-esp_dootax_pagamento.ind-situacao = 1
                   tt-esp_dootax_pagamento.cod-situacao = "Aguardando Implantaá∆o".      
       
            UNDO LOTE, LEAVE LOTE.
       END.
             */
           
    END.
    
    if  session:set-wait-state('') then.
    {&OPEN-QUERY-BROWSE-2}

    if  v_rec_bord_ap <> ? then
        RUN prgfin/apb/apb710aa.p. // bas_bord_ap (abre com o borderì recÇm-gerado)
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btHelp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btHelp wWindow
ON CHOOSE OF btHelp IN FRAME fpage0 /* Help */
OR CHOOSE OF MENU-ITEM miContents IN MENU mbMain DO:
    {include/ajuda.i}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btHelp2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btHelp2 wWindow
ON CHOOSE OF btHelp2 IN FRAME fpage0 /* Ajuda */
DO:
    {include/ajuda.i}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btParam
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btParam wWindow
ON CHOOSE OF btParam IN FRAME fpage0
DO:
    RUN intprg\nicr034a.w.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btQueryJoins
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btQueryJoins wWindow
ON CHOOSE OF btQueryJoins IN FRAME fpage0 /* Query Joins */
OR CHOOSE OF MENU-ITEM miQueryJoins IN MENU mbMain DO:
    RUN showQueryJoins IN THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btReportsJoins
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btReportsJoins wWindow
ON CHOOSE OF btReportsJoins IN FRAME fpage0 /* Reports Joins */
OR CHOOSE OF MENU-ITEM miReportsJoins IN MENU mbMain DO:
    RUN showReportsJoins IN THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME co-situacao
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL co-situacao wWindow
ON VALUE-CHANGED OF co-situacao IN FRAME fpage0 /* Situaá∆o */
DO:
    {&OPEN-QUERY-BROWSE-2}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME miAbout
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL miAbout wWindow
ON CHOOSE OF MENU-ITEM miAbout /* Sobre... */
DO:
  {include/sobre.i}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BROWSE-2
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK wWindow 


/*:T--- L¢gica para inicializaá∆o do programam ---*/
{window/mainblock.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE afterInitializeInterface wWindow 
PROCEDURE afterInitializeInterface :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    ASSIGN dt-ini = TODAY - 30
           dt-fim = TODAY.

    DISPLAY dt-ini
            dt-fim
        WITH FRAME fPage0.

    RETURN "OK".
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-atualiza-dooTax wWindow 
PROCEDURE pi-atualiza-dooTax :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    DEFINE VARIABLE oClient   AS IHttpClient   NO-UNDO.
    DEFINE VARIABLE oURI      AS URI           NO-UNDO.
    DEFINE VARIABLE oRequest  AS IHttpRequest  NO-UNDO.
    DEFINE VARIABLE hXmlDoc   AS HANDLE        NO-UNDO.
    DEFINE VARIABLE mData     AS MEMPTR        NO-UNDO.
    DEFINE VARIABLE oDocument AS CLASS MEMPTR  NO-UNDO.
    DEFINE VARIABLE oResponse AS IHttpResponse NO-UNDO.
    DEFINE VARIABLE oJson     AS JsonObject    NO-UNDO.
    DEFINE VARIABLE oResult   AS JsonObject    NO-UNDO.
    DEF VAR memptr-aux AS MEMPTR NO-UNDO.
    
    
    DEFINE VARIABLE lc-aux AS LONGCHAR NO-UNDO.
    DEFINE VARIABLE sData  AS STRING        NO-UNDO.
    
    DEFINE VARIABLE oLib           AS OpenEdge.Net.HTTP.IHttpClientLibrary NO-UNDO.
    DEFINE VARIABLE cSSLProtocols  AS CHARACTER          NO-UNDO EXTENT.
    DEFINE VARIABLE cSSLCiphers    AS CHARACTER          NO-UNDO EXTENT.

    IF c-token = "" THEN RUN pi-token.

    //RUN pi-gera-arq-dootax.
    
    EXTENT(cSSLProtocols) = 3.
    EXTENT(cSSLCiphers) = 12.
    // Supported ciphers and protocols at https://documentation.progress.com/output/ua/OpenEdge_latest/gscsv/supported-protocols,-ciphers,-and-certificates-f.html# 
    ASSIGN cSSLProtocols[1] = 'TLSv1.2'
           cSSLProtocols[2] = 'TLSv1.1'
           cSSLProtocols[3] = 'TLSv1.3'
           cSSLCiphers[1]   = 'AES128-SHA256'
           cSSLCiphers[2]   = 'DHE-RSA-AES128-SHA256'
           cSSLCiphers[3]   = 'AES128-GCM-SHA256' 
           cSSLCiphers[4]   = 'DHE-RSA-AES128-GCM-SHA256'
           cSSLCiphers[5]   = 'ADH-AES128-SHA256'
           cSSLCiphers[6]   = 'ADH-AES128-GCM-SHA256'
           cSSLCiphers[7]   = 'ADH-AES256-SHA256'
           cSSLCiphers[8]   = 'AES256-SHA256' 
           cSSLCiphers[9]   = 'DHE-RSA-AES256-SHA256'
           cSSLCiphers[10]  = 'AES128-SHA'
           cSSLCiphers[11]  = 'ECDHE-RSA-AES128-GCM-SHA256'
           cSSLCiphers[12]  = 'TLS_AES_128_GCM_SHA256'.
    
    //Build a request
    //oURI = URI:Parse('https://nissei.inventti.app/nfe/api/destinadas/Obter';).
    
    ASSIGN oURI        = OpenEdge.Net.URI:Parse(c-host)
           oURI:Path   = "/api/v2/doodoc/pagtrib/upload/payment/result/BB-teste".
    
    //https://portal.cosmospro.com.br:9191/api/login/autenticar?api-version=1.0&Content-Type=application/json&Accept=application/json
        
    ASSIGN oLib = ClientLibraryBuilder:Build()
                                      :SetSSLProtocols(cSSLProtocols)
                                      :SetSSLCiphers(cSSLCiphers)
                                      :sslVerifyHost(FALSE)
                                      :ServerNameIndicator(oURI:host)
                                      :library.
     
    COPY-LOB FROM FILE c-arquivo TO memptr-aux.

    ASSIGN oJson = NEW JsonObject().
    oJson:ADD("filename","retornopagamento.txt").
    oJson:ADD("content",memptr-aux).

    oRequest  = RequestBuilder:POST(oURI, oJson )
                :AddHeader("Content-Type", "application/json")
                :AddHeader("oauth-token", c-token)
                :AddHeader("tenant-alias", c-alias)
                :Request.                                      
    
    ASSIGN oResponse = ClientBuilder:Build():UsingLibrary(oLib):Client:Execute(oRequest).
    
    IF TYPE-OF(oResponse:Entity,JsonObject) THEN DO:
        oResult = CAST(oResponse:Entity, JsonObject).
    
        //c-token = string(oResult:getJsonText()).

        
    END.

    IF oResponse:statusCode = 200 THEN DO:
        FOR EACH tt-esp_dootax_pagamento-aux,
            FIRST esp_dootax_pagamento EXCLUSIVE-LOCK
            WHERE esp_dootax_pagamento.id = tt-esp_dootax_pagamento-aux.id:
            ASSIGN tt-esp_dootax_pagamento-aux.log_envio_dootax = YES.
        END.
        
        EMPTY TEMP-TABLE tt-esp_dootax_pagamento-aux.

        RUN utp/ut-msgs.p (INPUT "show", 
                           INPUT 31396,
                           INPUT "Integraá∆o Dootax.~~Integraá∆o Dootax realizada com Sucesso!").
    END.

    RETURN "OK".
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-busca wWindow 
PROCEDURE pi-busca :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
   
   
    DEFINE VARIABLE oClient     AS IHttpClient   NO-UNDO.
    DEFINE VARIABLE oURI        AS URI           NO-UNDO.
    DEFINE VARIABLE oRequest    AS IHttpRequest  NO-UNDO.
    DEFINE VARIABLE hXmlDoc     AS HANDLE        NO-UNDO.                                                                           
    DEFINE VARIABLE mData       AS MEMPTR        NO-UNDO.
    DEFINE VARIABLE oDocument   AS CLASS MEMPTR  NO-UNDO.
    DEFINE VARIABLE oResponse   AS IHttpResponse NO-UNDO.
    DEFINE VARIABLE oJson       AS JsonObject    NO-UNDO.
    DEFINE VARIABLE oResult     AS JsonObject    NO-UNDO.
    DEFINE VARIABLE oJsonObject AS JsonObject    NO-UNDO.
    
    
    DEFINE VARIABLE lc-aux AS LONGCHAR NO-UNDO.
    DEFINE VARIABLE sData  AS STRING        NO-UNDO.
    
    DEFINE VARIABLE oLib           AS OpenEdge.Net.HTTP.IHttpClientLibrary NO-UNDO.
    DEFINE VARIABLE cSSLProtocols  AS CHARACTER          NO-UNDO EXTENT.
    DEFINE VARIABLE cSSLCiphers    AS CHARACTER          NO-UNDO EXTENT.

    IF c-token = "" THEN DO:

        FIND FIRST esp_dootax_param NO-LOCK NO-ERROR.
    
        IF AVAIL esp_dootax_param THEN DO:
        
            ASSIGN c-host   = esp_dootax_param.cod-host  
                   c-alias  = esp_dootax_param.cod-alias 
                   c-token  = esp_dootax_param.cod-token .

        END.
    END.
    //MESSAGE "Tentando conectar em: " c-host SKIP "Path: " string(oURI:Path) VIEW-AS ALERT-BOX.
    //MESSAGE c-host VIEW-AS ALERT-BOX.
    
    EMPTY TEMP-TABLE tt-esp_dootax_pagamento.
    
    EXTENT(cSSLProtocols) = 1.
    EXTENT(cSSLCiphers) = 5.
    // Supported ciphers and protocols at https://documentation.progress.com/output/ua/OpenEdge_latest/gscsv/supported-protocols,-ciphers,-and-certificates-f.html# 

    ASSIGN cSSLProtocols[1] = 'TLSv1.2'
            cSSLCiphers[1]   = 'ECDHE-RSA-CHACHA20-POLY1305'
            cSSLCiphers[2]   = 'ECDHE-RSA-AES128-GCM-SHA256'
            cSSLCiphers[3]   = 'ECDHE-RSA-AES256-GCM-SHA384'
            cSSLCiphers[4]   = 'DHE-RSA-AES128-GCM-SHA256'
            cSSLCiphers[5]   = 'DHE-RSA-AES256-GCM-SHA384'.
    
    
/*     ASSIGN cSSLProtocols[1] = 'TLSv1.3'                      */
/*            cSSLProtocols[2] = 'TLSv1.2'                      */
/*            cSSLCiphers[1]   = 'TLS_AES_256_GCM_SHA384'       */
/*            cSSLCiphers[2]   = 'TLS_CHACHA20_POLY1305_SHA256' */
/*            cSSLCiphers[3]   = 'TLS_AES_128_GCM_SHA256'       */
/*            cSSLCiphers[4]   = 'ECDHE-RSA-CHACHA20-POLY1305'  */
/*            cSSLCiphers[5]   = 'ECDHE-RSA-AES128-GCM-SHA256'  */
/*            cSSLCiphers[6]   = 'ECDHE-RSA-AES256-GCM-SHA384'  */
/*            cSSLCiphers[7]   = 'DHE-RSA-AES128-GCM-SHA256'    */
/*            cSSLCiphers[8]   = 'DHE-RSA-AES256-GCM-SHA384'    */
           .

/*     ASSIGN cSSLProtocols[1] = 'TLSv1.3'                     */
/*            cSSLProtocols[2] = 'TLSv1.2'                     */
/*            //cSSLProtocols[3] = 'TLSv1.3'                   */
/*            cSSLCiphers[1]   = 'AES128-SHA256'               */
/*            cSSLCiphers[2]   = 'DHE-RSA-AES128-SHA256'       */
/*            cSSLCiphers[3]   = 'AES128-GCM-SHA256'           */
/*            cSSLCiphers[4]   = 'DHE-RSA-AES128-GCM-SHA256'   */
/*            cSSLCiphers[5]   = 'ADH-AES128-SHA256'           */
/*            cSSLCiphers[6]   = 'ADH-AES128-GCM-SHA256'       */
/*            cSSLCiphers[7]   = 'ADH-AES256-SHA256'           */
/*            cSSLCiphers[8]   = 'AES256-SHA256'               */
/*            cSSLCiphers[9]   = 'DHE-RSA-AES256-SHA256'       */
/*            cSSLCiphers[10]  = 'AES128-SHA'                  */
/*            cSSLCiphers[11]  = 'ECDHE-RSA-AES128-GCM-SHA256' */
/*            cSSLCiphers[12]  = 'TLS_AES_128_GCM_SHA256'.     */
    
    //Build a request
    //oURI = URI:Parse('https://nissei.inventti.app/nfe/api/destinadas/Obter';).
    
        ASSIGN oURI        = OpenEdge.Net.URI:Parse(c-host)
               oURI:Path   = "/api/v2/doodoc/pagtrib/listAll?size=150".        //?size=150
    
    //https://portal.cosmospro.com.br:9191/api/login/autenticar?api-version=1.0&Content-Type=application/json&Accept=application/json
            
        ASSIGN oLib = ClientLibraryBuilder:Build()
                                          :SetSSLProtocols(cSSLProtocols)
                                          :SetSSLCiphers(cSSLCiphers)
                                          :sslVerifyHost(FALSE) 
                                          :ServerNameIndicator(oURI:host)
                                          :library.

      /*  ASSIGN oLib = ClientLibraryBuilder:Build()
                                          :sslVerifyHost(FALSE)
                                          :ServerNameIndicator(oURI:host)
                                          :library.   */
/*                                                               */
/*         MESSAGE STRING(dt-ini:INPUT-VALUE, "9999-99-99") SKIP */
/*                 STRING(dt-fim:INPUT-VALUE, "9999-99-99")      */
/*             VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.         */
        
        ASSIGN oJson = NEW JsonObject().
        oJson:ADD("initialPeriod",dt-ini:INPUT-VALUE IN FRAME fPage0).
        oJson:ADD("endPeriod"    ,dt-fim:INPUT-VALUE IN FRAME fPage0). 
        
        /*DEFINE VARIABLE cIni AS CHAR NO-UNDO.
        DEFINE VARIABLE cFim AS CHAR NO-UNDO.

        cIni = STRING(YEAR(dt-ini:INPUT-VALUE IN FRAME fPage0), "9999") + "-" +
               STRING(MONTH(dt-ini:INPUT-VALUE IN FRAME fPage0), "99")  + "-" +
               STRING(DAY(dt-ini:INPUT-VALUE IN FRAME fPage0), "99").

        cFim = STRING(YEAR(dt-fim:INPUT-VALUE IN FRAME fPage0), "9999") + "-" +
               STRING(MONTH(dt-fim:INPUT-VALUE IN FRAME fPage0), "99")  + "-" +
               STRING(DAY(dt-fim:INPUT-VALUE IN FRAME fPage0), "99").

        MESSAGE cIni SKIP
                cFim
            VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
               
        oJson = NEW JsonObject().       
        oJson:ADD("initialPeriod", cIni).
        oJson:ADD("endPeriod"    , cFim).    */
        
        
/*         MESSAGE STRING(dt-ini:INPUT-VALUE IN FRAME fPage0, "9999-99-99") SKIP                 */
/*                 STRING(dt-fim:INPUT-VALUE IN FRAME fPage0, "9999-99-99")                      */
/*             VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.                                         */
/*                                                                                               */
/*         oJson = NEW JsonObject().                                                             */
/*         oJson:ADD("initialPeriod", STRING(dt-ini:INPUT-VALUE IN FRAME fPage0, "9999-99-99")). */
/*         oJson:ADD("endPeriod", STRING(dt-fim:INPUT-VALUE IN FRAME fPage0, "9999-99-99")).     */
    
        oRequest  = RequestBuilder:POST(oURI, oJson )
                    :AddHeader("Content-Type", "application/json")
                    :AddHeader("oauth-token", c-token)
                    :AddHeader("tenant-alias", c-alias)
                    :Request.     
                    
    
    ASSIGN oResponse = ClientBuilder:Build():UsingLibrary(oLib):Client:Execute(oRequest).   
    
    
    DEFINE VARIABLE lcjson AS LONGCHAR   NO-UNDO.
    
    FIX-CODEPAGE(lcjson) = "UTF-8".

    IF TYPE-OF(oResponse:Entity,JsonObject) THEN DO:
        oResult = CAST(oResponse:Entity, JsonObject).

        
        oResult:WRITE(lcjson).
        
        .MESSAGE string(lcjson)
            VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
        
        
        //TEMP-TABLE tt-esp_dootax_pagamento:HANDLE:READ-JSON("JsonArray",oResult:getJsonArray("content")). 
        
        def var myParser    AS ObjectModelParser NO-UNDO.

        myParser = NEW ObjectModelParser().


        lcjson = oResult:getJsonArray("content"):GetJsonText().
        lcjson = '~{"tt-esp_dootax_pagamento":' + lcjson + '}'.

        oJsonObject = CAST(myParser:Parse(lcjson), JsonObject).
        
        .MESSAGE 111 SKIP STRING(lcjson)
            VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
        
        TEMP-TABLE tt-esp_dootax_pagamento:READ-JSON("JsonObject",oJsonObject).
        
        
       /* lcjson = oResult:getJsonArray("content"):GetJsonText().
        lcjson = '~{"tt-esp_dootax_pagamento":' + lcjson + '}'.
        TEMP-TABLE tt-esp_dootax_pagamento:HANDLE:READ-JSON("JsonObject",lcjson).  */
       
       
    END.  
      
                                                    

    FOR EACH tt-esp_dootax_pagamento:
        FOR FIRST esp_dootax_pagamento EXCLUSIVE-LOCK
            WHERE esp_dootax_pagamento.id = tt-esp_dootax_pagamento.id: END.

        IF NOT AVAIL esp_dootax_pagamento THEN DO:
            CREATE esp_dootax_pagamento.
            ASSIGN esp_dootax_pagamento.id = tt-esp_dootax_pagamento.id.

        END.

        ASSIGN tt-esp_dootax_pagamento.cod_tit_ap       = esp_dootax_pagamento.cod_tit_ap
               tt-esp_dootax_pagamento.log_envio_dootax = esp_dootax_pagamento.log_envio_dootax.
               
        ASSIGN tt-esp_dootax_pagamento.cod-situacao = "Aguardando implantaá∆o"
               tt-esp_dootax_pagamento.ind-situacao = 1.                    
               

        BUFFER-COPY tt-esp_dootax_pagamento EXCEPT cod-situacao ind-situacao r-rowid id cod_tit_ap log_envio_dootax TO esp_dootax_pagamento.
        
        RELEASE esp_dootax_pagamento.
                     
                     

        
        IF tt-esp_dootax_pagamento.log_envio_dootax = YES THEN
            ASSIGN tt-esp_dootax_pagamento.cod-situacao = "Integrado dootax"
                   tt-esp_dootax_pagamento.ind-situacao = 4.
        ELSE DO:
    
            IF  tt-esp_dootax_pagamento.cod_tit_ap <> ?
            AND tt-esp_dootax_pagamento.cod_tit_ap <> "" THEN DO:
                FOR FIRST estabelec NO-LOCK
                    WHERE estabelec.cgc = tt-esp_dootax_pagamento.companyCnpj: END.
            
                FIND FIRST estabelecimento WHERE estabelecimento.cod_estab = estabelec.cod-estabel NO-LOCK NO-ERROR.
    
                FOR FIRST nota-fiscal NO-LOCK
                    WHERE nota-fiscal.cod-estabel = estabelec.cod-estabel
                    AND   nota-fiscal.serie       = tt-esp_dootax_pagamento.series
                    AND   nota-fiscal.nr-nota-fis = FILL("0",7 - LENGTH(tt-esp_dootax_pagamento.docNum)) + tt-esp_dootax_pagamento.docNum: END.            
                IF NOT AVAIL nota-fiscal THEN NEXT.
            
                IF estabelec.estado = "PR" THEN
                    FIND FIRST emitente WHERE emitente.cod-emitente = 6014 NO-LOCK NO-ERROR.
                IF estabelec.estado = "SP" THEN
                    FIND FIRST emitente WHERE emitente.cod-emitente = 8668082 NO-LOCK NO-ERROR.   
                IF estabelec.estado = "SC" THEN
                    FIND FIRST emitente WHERE emitente.cod-emitente = 6014 NO-LOCK NO-ERROR.     //ARRUMAR FORNECEDOR SC                
    
                FOR FIRST tit_ap NO-LOCK
                    WHERE tit_ap.cod_estab       = estabelecimento.cod_estab
                    AND   tit_ap.cod_espec_docto = "DF"
                    AND   tit_ap.cod_ser_docto   = tt-esp_dootax_pagamento.series        
                    AND   tit_ap.cdn_fornecedor  = emitente.cod-emitente
                    AND   tit_ap.cod_tit_ap      = tt-esp_dootax_pagamento.cod_tit_ap:
                    
                    ASSIGN tt-esp_dootax_pagamento.cod-situacao = "Implantado"
                           tt-esp_dootax_pagamento.ind-situacao = 2.
                    IF  tit_ap.dat_liquidac_tit_ap <> ?
                    AND tit_ap.dat_liquidac_tit_ap <> 12/31/9999 THEN
                        ASSIGN tt-esp_dootax_pagamento.cod-situacao = "Titulo pago"
                               tt-esp_dootax_pagamento.ind-situacao = 3
                               tt-esp_dootax_pagamento.debitDate    = tit_ap.dat_liquidac_tit_ap.    
                END.
            END.
        END.
    END.

    {&OPEN-QUERY-BROWSE-2}

    RETURN "OK".
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-gera-arq-dootax wWindow 
PROCEDURE pi-gera-arq-dootax :
PUT UNFORMATTED tt-esp_dootax_pagamento.id ";"
                                               ";"
                    tit_ap.dat_liquidac_tit_ap ";"
                    tit_ap.val_pagto_tit_ap    ";"
                    tt-esp_dootax_pagamento.barcode SKIP.
    
    CREATE tt-esp_dootax_pagamento-aux.
    BUFFER-COPY tt-esp_dootax_pagamento TO tt-esp_dootax_pagamento-aux.

    RETURN "OK".
END PROCEDURE. /* pi-gera-arq-dootax */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-integra-ap wWindow 
PROCEDURE pi-integra-ap :
DEFINE VARIABLE v_cod_refer      AS CHAR        NO-UNDO.
    DEFINE VARIABLE i-num_seq_refer  AS INT         NO-UNDO.
    DEFINE VARIABLE v_log_refer_uni  AS LOGICAL     NO-UNDO.
    DEFINE VARIABLE v_hdl_aux        AS HANDLE      NO-UNDO.
    DEFINE VARIABLE v_recid_lote     AS RECID       NO-UNDO.
    DEFINE VARIABLE v_arq_log        AS CHAR        NO-UNDO.

    DEFINE variable v_empresa        as char no-undo.
    DEFINE variable v_estab          as char no-undo.
    DEFINE VARIABLE v_espec_docto    as char no-undo.
    DEFINE VARIABLE v_ser_docto      as char no-undo.
    DEFINE VARIABLE v_fornecedor     as int  no-undo.
    DEFINE VARIABLE v_tit_ap         as char no-undo.
    DEFINE VARIABLE v_parcela        as char no-undo.
    
    EMPTY TEMP-TABLE tt_integr_apb_lote_impl.
    EMPTY TEMP-TABLE tt_integr_apb_item_lote_impl3v.
    EMPTY TEMP-TABLE tt_integr_apb_aprop_ctbl_pend.
    EMPTY TEMP-TABLE tt_erro_aed.
    EMPTY TEMP-TABLE tt_log_erros_atualiz.
    
    assign v_cod_refer     = ""
           i-num_seq_refer = 10.           
    ASSIGN v_rec_lote_impl_tit_ap     = ?
           v_rec_lote_impl_tit_ap_aux = ?.
           
    // Para cada linha selecionada da tela...
    FOR EACH tt-sel:

       find tt-esp_dootax_pagamento
           where rowid(tt-esp_dootax_pagamento) = tt-sel.rowid_dootax
           no-error.
       
       IF  not avail tt-esp_dootax_pagamento then
           next.
       
       FOR FIRST estabelec NO-LOCK
           WHERE estabelec.cgc = tt-esp_dootax_pagamento.companyCnpj: END.

       FIND FIRST estabelecimento WHERE estabelecimento.cod_estab = estabelec.cod-estabel NO-LOCK NO-ERROR.

       FOR FIRST nota-fiscal NO-LOCK
           WHERE nota-fiscal.cod-estabel = estabelec.cod-estabel
           AND   nota-fiscal.serie       = tt-esp_dootax_pagamento.series
           AND   nota-fiscal.nr-nota-fis = FILL("0",7 - LENGTH(tt-esp_dootax_pagamento.docNum)) + tt-esp_dootax_pagamento.docNum: END.

       IF  NOT AVAIL nota-fiscal then DO:
           if  session:set-wait-state('') then.
           RUN utp/ut-msgs.p (INPUT "show", INPUT 17006, INPUT "Nota Fiscal n∆o encontrada!~~N∆o foi encontrada a Nota Fiscal:" + chr(13)
                                            + "Estab.: " + estabelec.cod-estabel + chr(13)
                                            + "SÇrie.: " + tt-esp_dootax_pagamento.series + chr(13)
                                            + "N£mero: " + FILL("0",7 - LENGTH(tt-esp_dootax_pagamento.docNum)) + tt-esp_dootax_pagamento.docNum).
           DELETE tt-sel.
           next.
       END.
       
       FIND FIRST b-emitente NO-LOCK
            WHERE b-emitente.nome-abrev = nota-fiscal.nome-ab-cli NO-ERROR.
            
       IF NOT AVAIL b-emitente THEN
       DO:
       
           if  session:set-wait-state('') then.
           RUN utp/ut-msgs.p (INPUT "show", INPUT 17006, INPUT "Emitente n∆o encontrado!~~N∆o foi encontrada o emitente da Nota Fiscal:" + chr(13)
                                            + "Estab.: " + estabelec.cod-estabel + chr(13)
                                            + "SÇrie.: " + tt-esp_dootax_pagamento.series + chr(13)
                                            + "N£mero: " + FILL("0",7 - LENGTH(tt-esp_dootax_pagamento.docNum)) + tt-esp_dootax_pagamento.docNum).
           DELETE tt-sel.
           next.       
           
       END.
       
       
       FIND FIRST esp-consu-fornec NO-LOCK
            WHERE esp-consu-fornec.cod-estado = b-emitente.estado NO-ERROR.
       IF NOT AVAIL esp-consu-fornec THEN
       DO:
       
            RUN utp/ut-msgs.p (INPUT "show", INPUT 17006, INPUT "Estado n∆o cadastrado!~~N∆o foi vinculo de estado x fornecedor nos parametros Dootax:" + chr(13)
                                            + "Estab.: " + estabelec.cod-estabel + chr(13)
                                            + "SÇrie.: " + tt-esp_dootax_pagamento.series + chr(13)
                                            + "N£mero: " + FILL("0",7 - LENGTH(tt-esp_dootax_pagamento.docNum)) + tt-esp_dootax_pagamento.docNum).
            DELETE tt-sel.
            next.       
       
           
       END.
       FIND FIRST emitente 
            WHERE emitente.cod-emitente = esp-consu-fornec.cod-fornec NO-LOCK NO-ERROR.     

       assign  v_empresa      = estabelecimento.cod_empresa
               v_estab        = estabelecimento.cod_estab 
               v_espec_docto  = "DF"         
               v_ser_docto    = tt-esp_dootax_pagamento.series                 
               v_fornecedor   = emitente.cod-emitente         
               v_tit_ap       = v_estab + STRING(MONTH(tt-esp_dootax_pagamento.insertDate), "99" ) + SUBSTRING(string(tt-esp_dootax_pagamento.insertDate),7,2 ) + "DA" + tt-esp_dootax_pagamento.docNum          
               v_parcela      = "".            
               
       FIND FIRST tit_ap 
            WHERE tit_ap.cod_estab       = v_estab      
              AND tit_ap.cod_espec_docto = v_espec_docto
              AND tit_ap.cod_ser_docto   = v_ser_docto  
              AND tit_ap.cdn_fornecedor  = v_fornecedor 
              AND tit_ap.cod_tit_ap      = v_tit_ap     
              AND tit_ap.cod_parcela     = v_parcela
              no-lock no-error.       
       IF AVAIL tit_ap THEN DO:
          if  session:set-wait-state('') then.
          RUN utp/ut-msgs.p (INPUT "show", INPUT 17006, INPUT "T°tulo j† existe!~~J† existe um titulo com essa numeraá∆o de Recibo no Financeiro!" + chr(13)
                                           + "Estab: " + v_estab + chr(13)
                                           + "Emitente: " + string(v_fornecedor) + chr(13)
                                           + "Codigo Titulo: " + v_tit_ap + chr(13)
                                           + "Especie: " + v_espec_docto).
          DELETE tt-sel.
          next.
       END.
       FIND FIRST item_lote_impl_ap 
            WHERE item_lote_impl_ap.cod_empresa     = v_empresa    
              AND item_lote_impl_ap.cod_estab       = v_estab      
              AND item_lote_impl_ap.cod_espec_docto = v_espec_docto
              AND item_lote_impl_ap.cod_ser_docto   = v_ser_docto  
              AND item_lote_impl_ap.cdn_fornecedor  = v_fornecedor 
              AND item_lote_impl_ap.cod_tit_ap      = v_tit_ap     
              AND item_lote_impl_ap.cod_parcela     = v_parcela
              no-lock NO-ERROR.
       IF AVAIL item_lote_impl_ap THEN DO:
          if  session:set-wait-state('') then.
          RUN utp/ut-msgs.p (INPUT "show", INPUT 17006, INPUT "T°tulo j† existe!~~J† existe um titulo com essa numeraá∆o de Recibo no Financeiro!" + chr(13)
                                           + "Estab: " + v_estab + chr(13)
                                           + "Emitente: " + string(v_fornecedor) + chr(13)
                                           + "Codigo Titulo: " + v_tit_ap + chr(13)
                                           + "Especie: " + v_espec_docto).
          DELETE tt-sel.
          next.
       END.           
           
       // Cria capa do Lote implantaá∆o
       if  v_cod_refer = "" then do:
          REPEAT WHILE v_log_refer_uni = NO:
              RUN pi_retorna_sugestao_referencia (INPUT "T",INPUT TODAY,OUTPUT v_cod_refer).

              RUN pi_verifica_refer_unica_apb    (INPUT estabelecimento.cod_estab ,INPUT v_cod_refer,INPUT '',INPUT ?,OUTPUT v_log_refer_uni).
          END.
          
          create tt_integr_apb_lote_impl.
          assign tt_integr_apb_lote_impl.tta_cod_estab_ext            = ""
                 tt_integr_apb_lote_impl.tta_cod_refer                = v_cod_refer
                 tt_integr_apb_lote_impl.tta_cod_espec_docto           = ''
                 tt_integr_apb_lote_impl.tta_dat_transacao            = TODAY
                 tt_integr_apb_lote_impl.tta_val_tot_lote_impl_tit_ap = 0
                 tt_integr_apb_lote_impl.tta_ind_origin_tit_ap        = "APB"
                 tt_integr_apb_lote_impl.tta_cod_estab                = estabelecimento.cod_estab
                 tt_integr_apb_lote_impl.tta_cod_empresa              = estabelecimento.cod_empresa
                 tt_integr_apb_lote_impl.ttv_cod_empresa_ext           = '' 
                 tt_integr_apb_lote_impl.tta_cod_finalid_econ_ext      = '' 
                 tt_integr_apb_lote_impl.tta_cod_indic_econ            = ''.          
       end.
       
        CREATE tt_integr_apb_item_lote_impl3v.
        ASSIGN tt_integr_apb_item_lote_impl3v.ttv_rec_integr_apb_lote_impl  = recid(tt_integr_apb_lote_impl)
               tt_integr_apb_item_lote_impl3v.tta_num_seq_refer             = i-num_seq_refer
               tt_integr_apb_item_lote_impl3v.tta_cdn_fornecedor            = v_fornecedor
               tt_integr_apb_item_lote_impl3v.tta_cod_espec_docto           = v_espec_docto 
               tt_integr_apb_item_lote_impl3v.tta_cod_ser_docto             = v_ser_docto
               tt_integr_apb_item_lote_impl3v.tta_cod_tit_ap                = v_tit_ap
               tt_integr_apb_item_lote_impl3v.tta_cod_parcela               = v_parcela
               tt_integr_apb_item_lote_impl3v.tta_dat_emis_docto            = tt-esp_dootax_pagamento.insertDate 
               tt_integr_apb_item_lote_impl3v.tta_dat_vencto_tit_ap         = TODAY
               tt_integr_apb_item_lote_impl3v.tta_cod_indic_econ            = "Real"
               tt_integr_apb_item_lote_impl3v.tta_cod_finalid_econ_ext      = ""
               tt_integr_apb_item_lote_impl3v.tta_val_tit_ap                = tt-esp_dootax_pagamento.totalAmount
               tt_integr_apb_item_lote_impl3v.tta_num_dias_atraso           = 0
               tt_integr_apb_item_lote_impl3v.tta_val_juros_dia_atraso      = 0
               tt_integr_apb_item_lote_impl3v.tta_val_perc_juros_dia_atraso = 0
               tt_integr_apb_item_lote_impl3v.tta_val_perc_multa_atraso     = 0
               tt_integr_apb_item_lote_impl3v.tta_cod_apol_seguro           = ""
               tt_integr_apb_item_lote_impl3v.tta_cod_seguradora            = ""
               tt_integr_apb_item_lote_impl3v.tta_cod_arrendador            = ""
               tt_integr_apb_item_lote_impl3v.tta_cod_contrat_leas          = ""
               tt_integr_apb_item_lote_impl3v.tta_cod_forma_pagto           = "" /**/
               tt_integr_apb_item_lote_impl3v.tta_cod_portador              = string(emitente.portador-ap)
               tt_integr_apb_item_lote_impl3v.tta_cod_portad_ext            = ""
               tt_integr_apb_item_lote_impl3v.tta_cod_modalid_ext           = ""
               tt_integr_apb_item_lote_impl3v.tta_dat_desconto              = ?
               tt_integr_apb_item_lote_impl3v.tta_val_desconto              = 0
               tt_integr_apb_item_lote_impl3v.tta_val_perc_desc             = 0
               tt_integr_apb_item_lote_impl3v.tta_des_text_histor           = "Titulo gerado pela Integraá∆o com DooTax"
               tt_integr_apb_item_lote_impl3v.tta_dat_prev_pagto            = TODAY 
               tt_integr_apb_item_lote_impl3v.ttv_rec_integr_apb_item_lote  = recid(tt_integr_apb_item_lote_impl3v)
               tt_integr_apb_item_lote_impl3v.tta_val_cotac_indic_econ      = 1
               tt_integr_apb_item_lote_impl3v.ttv_num_ord_invest            = 0
               tt_integr_apb_item_lote_impl3v.tta_cb4_tit_ap_bco_cobdor     = tt-esp_dootax_pagamento.barcode
               tt_integr_apb_item_lote_impl3v.ttv_ind_tip_cod_barra         = "F"
               tt_integr_apb_item_lote_impl3v.tta_cod_tit_ap_bco_cobdor     = string(tt-esp_dootax_pagamento.titleId)
               tt_integr_apb_item_lote_impl3v.ttv_rec_integr_apb_item_lote  = RECID(tt_integr_apb_item_lote_impl3v)
               i-num_seq_refer = i-num_seq_refer + 10.

        CREATE tt_integr_apb_aprop_ctbl_pend.
        ASSIGN tt_integr_apb_aprop_ctbl_pend.ttv_rec_integr_apb_item_lote   = RECID(tt_integr_apb_item_lote_impl3v)
               tt_integr_apb_aprop_ctbl_pend.ttv_rec_antecip_pef_pend       = ?
               tt_integr_apb_aprop_ctbl_pend.ttv_rec_integr_apb_impto_pend  = ?
               tt_integr_apb_aprop_ctbl_pend.tta_cod_plano_cta_ctbl         = "PADRAO"
               tt_integr_apb_aprop_ctbl_pend.tta_cod_cta_ctbl               = "91103020"
               tt_integr_apb_aprop_ctbl_pend.tta_cod_cta_ctbl_ext           = ""
               tt_integr_apb_aprop_ctbl_pend.tta_cod_sub_cta_ctbl_ext       = ""
               tt_integr_apb_aprop_ctbl_pend.tta_cod_unid_negoc             = "000"
               tt_integr_apb_aprop_ctbl_pend.tta_cod_unid_negoc_ext         = ""
               tt_integr_apb_aprop_ctbl_pend.tta_cod_plano_ccusto           = ""
               tt_integr_apb_aprop_ctbl_pend.tta_cod_ccusto                 = ""
               tt_integr_apb_aprop_ctbl_pend.tta_cod_ccusto_ext             = ""
               tt_integr_apb_aprop_ctbl_pend.tta_cod_tip_fluxo_financ       = "408" //"10.28.1"
               tt_integr_apb_aprop_ctbl_pend.tta_val_aprop_ctbl             = tt_integr_apb_item_lote_impl3v.tta_val_tit_ap .

        ASSIGN tt-sel.v_estab        = v_estab       
               tt-sel.v_espec_docto  = v_espec_docto
               tt-sel.v_ser_docto    = v_ser_docto  
               tt-sel.v_fornecedor   = v_fornecedor 
               tt-sel.v_tit_ap       = v_tit_ap     
               tt-sel.v_parcela      = v_parcela.                   
    END.

    ASSIGN v_log_atualiza_refer_apb = YES
           v_log_envia_aed          = NO.
    
    RELEASE tt_integr_apb_lote_impl.
    RELEASE tt_integr_apb_item_lote_impl3v.
    RELEASE tt_integr_apb_aprop_ctbl_pend.

    if  not can-find(first tt_integr_apb_item_lote_impl3v) then
        return "NOK".
    
    TUDO:
    DO ON ERROR UNDO TUDO, RETURN "NOK"
       ON STOP  UNDO TUDO, RETURN "NOK":
    
       RUN prgfin/apb/apb900zg.r PERSISTENT SET v_hdl_aux.
       
       run pi_main_block_api_tit_ap_cria_9 in v_hdl_aux (Input 9,
                                                         Input '',
                                                         input-output table tt_integr_apb_item_lote_impl3v,
                                                         input-output table tt_params_generic_api,
                                                         Input table tt_integr_apb_relacto_pend_aux, 
                                                         Input table tt_integr_apb_aprop_relacto_2,
                                                         Input table tt_docum_est_esoc_api,
                                                         Input table tt_item_doc_est_esoc_api,
                                                         Input table tt_integr_apb_nota_pend_cart). 
       DELETE PROCEDURE v_hdl_aux NO-ERROR.
       
       IF  CAN-FIND(FIRST tt_log_erros_atualiz) then do: 
           if  session:set-wait-state('') then.
           RUN utp/ut-msgs.p (INPUT "show", INPUT "17006", INPUT "Houve Erro na Implantaá∆o dos t°tulos !!~~Toda a transaá∆o ser† desfeita. Pressione OK para ver os erros.").
           
           // GERA LOG DOS ERROS EM ARQUIVO TEXTO
           ASSIGN v_arq_log = SESSION:TEMP-DIRECTORY
                            + "NICR034_IMPL_LOG_"
                            + REPLACE(STRING(TIME,"hh:mm:ss"),":","")
                            + ".TXT".
           OUTPUT TO VALUE(v_arq_log) NO-CONVERT.
           PUT UNFORMATTED "ERROS INTEGRAÄ«O APB" SKIP
               "-------------------------------------" SKIP(2).
           FOR EACH tt_log_erros_atualiz:
               PUT UNFORMATTED
                   "Estab.....: " tt_log_erros_atualiz.tta_cod_estab     skip
                   "Referencia: " tt_log_erros_atualiz.tta_cod_refer     skip
                   "Sequencia.: " tt_log_erros_atualiz.tta_num_seq_refer skip
                   "Mensagem..: " tt_log_erros_atualiz.ttv_num_mensagem  skip
                   "Erro......: " tt_log_erros_atualiz.ttv_des_msg_erro  skip
                   "Ajuda.....: " tt_log_erros_atualiz.ttv_des_msg_ajuda skip(2).
           END.
           OUTPUT CLOSE.
           DOS SILENT START NOTEPAD.EXE VALUE(v_arq_log).
           UNDO TUDO, RETURN "NOK".
       END. 
       
       // Atualiza situaá∆o e c¢digo do t°tulo gerado
       FOR EACH tt-sel:

          find tt-esp_dootax_pagamento
              where rowid(tt-esp_dootax_pagamento) = tt-sel.rowid_dootax
              no-error.

          FIND FIRST tit_ap 
               WHERE tit_ap.cod_estab       = tt-sel.v_estab      
                 AND tit_ap.cod_espec_docto = tt-sel.v_espec_docto
                 AND tit_ap.cod_ser_docto   = tt-sel.v_ser_docto  
                 AND tit_ap.cdn_fornecedor  = tt-sel.v_fornecedor 
                 AND tit_ap.cod_tit_ap      = tt-sel.v_tit_ap     
                 AND tit_ap.cod_parcela     = tt-sel.v_parcela
                 no-lock no-error.       
          IF  NOT AVAIL tit_ap
          OR  NOT AVAIL tt-esp_dootax_pagamento THEN DO:
              DELETE tt-sel.
              NEXT.
          END.

          ASSIGN tt-esp_dootax_pagamento.cod_tit_ap   = tt-sel.v_tit_ap
                 tt-esp_dootax_pagamento.ind-situacao = 2
                 tt-esp_dootax_pagamento.cod-situacao = "Implantado".

          FOR FIRST esp_dootax_pagamento EXCLUSIVE-LOCK
              WHERE esp_dootax_pagamento.id = tt-esp_dootax_pagamento.id:
              ASSIGN esp_dootax_pagamento.cod_tit_ap = tt-sel.v_tit_ap
                     esp_dootax_pagamento.cod-status = "Implantado"
                     .
          END.                                                                 
       END.
    END.
    
    RETURN "OK".
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-pagar-via-bordero wWindow 
PROCEDURE pi-pagar-via-bordero :
DEFINE VARIABLE v_arq_log        AS CHAR   NO-UNDO.
    DEFINE VARIABLE v_hdl_aux        AS HANDLE NO-UNDO.
    DEFINE VARIABLE v_estab_pag      as char no-undo.
    DEFINE VARIABLE v_portador       as char no-undo.
    DEFINE VARIABLE v_forma          as char no-undo.
    DEFINE VARIABLE v_num_bordero    as int  no-undo.
    DEFINE VARIABLE v_qtd            as int  no-undo.
    
    // INICIO Pagamento via Borderì
    EMPTY TEMP-TABLE tt_erro_aed.
    EMPTY TEMP-TABLE tt_log_erros_atualiz.
    EMPTY TEMP-TABLE tt_integr_apb_pagto.
    EMPTY TEMP-TABLE tt_integr_bord_lote_pagto_1.
    EMPTY TEMP-TABLE tt_params_generic_api.
    
    ASSIGN v_estab_pag   = "002"
           v_portador    = "23705"
           v_forma       = "BOL"
           v_num_bordero = 1
           v_rec_bord_ap = ?.
           
    FIND LAST bord_ap
         WHERE bord_ap.cod_estab_bord = v_estab_pag
         AND   bord_ap.cod_portador   = v_portador
         NO-LOCK NO-ERROR.
    IF  AVAIL bord_ap THEN
        ASSIGN v_num_bordero = bord_ap.num_bord_ap + 1.

    // Lote
    CREATE tt_integr_apb_pagto.                                                             
    ASSIGN tt_integr_apb_pagto.tta_cod_empresa               = "1"
           tt_integr_apb_pagto.tta_dat_livre_1               = TODAY
           tt_integr_apb_pagto.tta_cod_estab_bord            = v_estab_pag
           tt_integr_apb_pagto.tta_dat_transacao             = TODAY
           tt_integr_apb_pagto.tta_cod_portador              = v_portador
           tt_integr_apb_pagto.tta_num_bord_ap               = v_num_bordero
           tt_integr_apb_pagto.tta_cod_indic_econ            = "Real"
           tt_integr_apb_pagto.tta_log_bord_ap_escrit        = YES
           tt_integr_apb_pagto.tta_log_bord_ap_escrit_envdo  = NO
           tt_integr_apb_pagto.tta_cod_usuar_pagto           = v_cod_usuar_corren           
           tt_integr_apb_pagto.tta_log_enctro_cta            = NO
           tt_integr_apb_pagto.tta_ind_tip_bord_ap           = "Normal"
           tt_integr_apb_pagto.tta_cod_finalid_econ          = "Corrente"
           tt_integr_apb_pagto.ttv_log_atualiz_refer         = NO
           tt_integr_apb_pagto.ttv_log_gera_lote_parcial     = NO
           tt_integr_apb_pagto.ttv_ind_tip_atualiz           = "Borderì"
           tt_integr_apb_pagto.ttv_rec_table_parent          = RECID(tt_integr_apb_pagto)
           tt_integr_apb_pagto.ttv_log_vinc_impto_auto       = NO.

   FOR EACH tt-sel:

       FIND FIRST tit_ap 
           WHERE tit_ap.cod_estab       = tt-sel.v_estab      
           AND   tit_ap.cod_espec_docto = tt-sel.v_espec_docto
           AND   tit_ap.cod_ser_docto   = tt-sel.v_ser_docto  
           AND   tit_ap.cdn_fornecedor  = tt-sel.v_fornecedor 
           AND   tit_ap.cod_tit_ap      = tt-sel.v_tit_ap     
           AND   tit_ap.cod_parcela     = tt-sel.v_parcela
           no-lock no-error.       
       IF  NOT AVAIL tit_ap THEN
           NEXT.

       CREATE tt_integr_bord_lote_pagto_1.
       ASSIGN tt_integr_bord_lote_pagto_1.ttv_rec_table_child          = RECID(tt_integr_bord_lote_pagto_1)           
              tt_integr_bord_lote_pagto_1.ttv_rec_table_parent         = tt_integr_apb_pagto.ttv_rec_table_parent  
              tt_integr_bord_lote_pagto_1.tta_dat_livre_1              = tt_integr_apb_pagto.tta_dat_livre_1
              tt_integr_bord_lote_pagto_1.tta_cod_empresa              = tit_ap.cod_empresa
              tt_integr_bord_lote_pagto_1.ttv_cod_estab_bord_refer     = tit_ap.cod_estab
              tt_integr_bord_lote_pagto_1.tta_cod_forma_pagto          = v_forma
              tt_integr_bord_lote_pagto_1.tta_cod_portador             = v_portador
              tt_integr_bord_lote_pagto_1.tta_cod_estab                = tit_ap.cod_estab
              tt_integr_bord_lote_pagto_1.tta_cod_espec_docto          = tit_ap.cod_espec_docto
              tt_integr_bord_lote_pagto_1.tta_cod_ser_docto            = tit_ap.cod_ser_docto
              tt_integr_bord_lote_pagto_1.tta_cdn_fornecedor           = tit_ap.cdn_fornecedor
              tt_integr_bord_lote_pagto_1.tta_cod_tit_ap               = tit_ap.cod_tit_ap
              tt_integr_bord_lote_pagto_1.tta_cod_parcela              = tit_ap.cod_parcela
              tt_integr_bord_lote_pagto_1.tta_cod_indic_econ           = tit_ap.cod_indic_econ
              tt_integr_bord_lote_pagto_1.tta_dat_cotac_indic_econ     = ?
              tt_integr_bord_lote_pagto_1.tta_val_cotac_indic_econ     = 1
              tt_integr_bord_lote_pagto_1.tta_val_pagto                = tit_ap.val_origin_tit_ap
              tt_integr_bord_lote_pagto_1.tta_log_critic_atualiz_ok    = NO
              tt_integr_bord_lote_pagto_1.tta_des_text_histor          = "Pagamento gerado pela Integraá∆o Dootax"
              tt_integr_bord_lote_pagto_1.tta_cod_finalid_econ         = "Corrente"
              //tt_integr_bord_lote_pagto_1.tta_ind_favorec_cheq         = "Portador"
              tt_integr_bord_lote_pagto_1.ttv_ind_forma_pagto          = "Informada"
              tt_integr_bord_lote_pagto_1.tta_ind_sit_item_lote_bxa_ap = "Gerado"
              v_qtd = v_qtd + 1.
   END.
   
   IF  NOT CAN-FIND(first tt_integr_bord_lote_pagto_1) THEN
       RETURN "OK".

   RELEASE tt_integr_apb_pagto.
   RELEASE tt_integr_bord_lote_pagto_1.
   
   RUN prgfin/apb/apb902ze.py PERSISTENT SET v_hdl_aux.

   RUN pi_main_code_api_integr_apb_pagto_4_evo_4 IN v_hdl_aux (INPUT 1,
                                                               INPUT TABLE tt_integr_apb_pagto,             
                                                               OUTPUT TABLE tt_log_erros_atualiz,          
                                                               INPUT TABLE tt_integr_bord_lote_pagto_1,    
                                                               INPUT TABLE tt_integr_apb_abat_prev,        
                                                               INPUT TABLE tt_integr_apb_abat_antecip,     
                                                               INPUT TABLE tt_integr_apb_impto_impl_pend,  
                                                               INPUT  "",  /* p_cod_matriz_trad_org_ext */          
                                                               INPUT TABLE tt_integr_cambio_ems5,          
                                                               INPUT TABLE tt_1099,                        
                                                               INPUT TABLE tt_integr_apb_pagto_aux_1,      
                                                               INPUT TABLE tt_integr_apb_bord_lote_pg_a,   
                                                               INPUT-OUTPUT table tt_params_generic_api) . 

   IF  VALID-HANDLE (v_hdl_aux) THEN
       DELETE PROCEDURE v_hdl_aux .

   if  session:set-wait-state('') then.
        
    IF  CAN-FIND(FIRST tt_log_erros_atualiz) then do:
        RUN utp/ut-msgs.p (INPUT "show", INPUT "17006", INPUT "Houve Erro na tentativa de Pagar via Borderì !!~~Toda a transaá∆o ser† desfeita. Pressione OK para ver os erros.").
        
        // GERA LOG DOS ERROS EM ARQUIVO TEXTO
        ASSIGN v_arq_log = SESSION:TEMP-DIRECTORY
                         + "NICR034_BORD_LOG_"
                         + REPLACE(STRING(TIME,"hh:mm:ss"),":","")
                         + ".TXT".
        OUTPUT TO VALUE(v_arq_log) NO-CONVERT.
        PUT UNFORMATTED "ERROS PAGAMENTO VIA BORDER‚" SKIP
            "-------------------------------------" SKIP(2).
        FOR EACH tt_log_erros_atualiz:
            PUT UNFORMATTED
                "Estab.....: " tt_log_erros_atualiz.tta_cod_estab     skip
                "Referencia: " tt_log_erros_atualiz.tta_cod_refer     skip
                "Sequencia.: " tt_log_erros_atualiz.tta_num_seq_refer skip
                "Mensagem..: " tt_log_erros_atualiz.ttv_num_mensagem  skip
                "Erro......: " tt_log_erros_atualiz.ttv_des_msg_erro  skip
                "Ajuda.....: " tt_log_erros_atualiz.ttv_des_msg_ajuda skip(2).
        END.
        OUTPUT CLOSE.
        DOS SILENT START NOTEPAD.EXE VALUE(v_arq_log).
        UNDO, RETURN "NOK".
   END.
   ELSE DO:
       RUN utp/ut-msgs.p (INPUT "show", INPUT "27100", INPUT "Execuá∆o com sucesso !!~~Foram implantados " + string(v_qtd) + " t°tulos e colocados no borderì:" + chr(13) +
                           "Borderì.: " + string(v_num_bordero) +
                           " (Estab." + v_estab_pag +
                           " Portador " + v_portador + ")" + chr(13) +
                           "Este borderì precisa ser impresso e enviado." + chr(13) +
                           "Deseja abrir o borderì agora ?").
       IF  RETURN-VALUE = 'yes' THEN DO:
           FIND bord_ap
               WHERE bord_ap.cod_estab_bord = v_estab_pag
               AND   bord_ap.cod_portador   = v_portador
               AND   bord_ap.num_bord_ap    = v_num_bordero
               NO-LOCK NO-ERROR.
           IF  AVAIL bord_ap THEN
               ASSIGN v_rec_bord_ap = recid(bord_ap).
       END.
   END.

   RETURN "OK".
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi_retorna_sugestao_referencia wWindow 
PROCEDURE pi_retorna_sugestao_referencia :
/************************ Parameter Definition Begin ************************/

    def Input param p_ind_tip_atualiz
        as character
        format "X(08)"
        no-undo.
    def Input param p_dat_refer
        as date
        format "99/99/9999"
        no-undo.
    def output param p_cod_refer
        as character
        format "x(10)"
        no-undo.


    /************************* Parameter Definition End *************************/

    /************************* Variable Definition Begin ************************/

    def var v_des_dat                        as character       no-undo. /*local*/
    def var v_num_aux                        as integer         no-undo. /*local*/
    def var v_num_aux_2                      as integer         no-undo. /*local*/
    def var v_num_cont                       as integer         no-undo. /*local*/


    /************************** Variable Definition End *************************/

    assign v_des_dat   = string(p_dat_refer,"99999999")
           p_cod_refer = substring(v_des_dat,7,2)
                       + substring(v_des_dat,3,2)
                       + substring(v_des_dat,1,2)
                       + substring(p_ind_tip_atualiz,1,1)
           v_num_aux_2 = integer(this-procedure:handle).

    do  v_num_cont = 1 to 3:
        assign v_num_aux   = (random(0,v_num_aux_2) mod 26) + 97
               p_cod_refer = p_cod_refer + chr(v_num_aux).
    end.
END PROCEDURE. /* pi_retorna_sugestao_referencia */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi_verifica_refer_unica_apb wWindow 
PROCEDURE pi_verifica_refer_unica_apb :
/************************ Parameter Definition Begin ************************/

    def Input param p_cod_estab
        as character
        format "x(5)"
        no-undo.
    def Input param p_cod_refer
        as character
        format "x(10)"
        no-undo.
    def Input param p_cod_table
        as character
        format "x(8)"
        no-undo.
    def Input param p_rec_movto_tit_ap
        as recid
        format ">>>>>>9"
        no-undo.
    def output param p_log_refer_uni
        as logical
        format "Sim/Nío"
        no-undo.


    /************************* Parameter Definition End *************************/

    /************************** Buffer Definition Begin *************************/

    &if "{&emsfin_version}" >= "5.01" &then
    def buffer b_antecip_pef_pend
        for antecip_pef_pend.
    &endif
    &if "{&emsfin_version}" >= "5.01" &then
    def buffer b_lote_impl_tit_ap
        for lote_impl_tit_ap.
    &endif
    &if "{&emsfin_version}" >= "5.01" &then
    def buffer b_lote_pagto
        for lote_pagto.
    &endif
    &if "{&emsfin_version}" >= "5.01" &then
    def buffer b_movto_tit_ap
        for movto_tit_ap.
    &endif


    /*************************** Buffer Definition End **************************/

    assign p_log_refer_uni = yes.



    if  p_cod_table <> "antecip_pef_pend" /*l_antecip_pef_pend*/ 
    then do:
        find first b_antecip_pef_pend no-lock
             where b_antecip_pef_pend.cod_estab = p_cod_estab
               and b_antecip_pef_pend.cod_refer = p_cod_refer /*cl_verifica_refer_uni of b_antecip_pef_pend*/ no-error.
    end /* if */.
    if  avail b_antecip_pef_pend
    then do:
        assign p_log_refer_uni = no.
    end /* if */.
    else do:
        if  p_cod_table <> "lote_impl_tit_ap" /*l_lote_impl_tit_ap*/ 
        then do:
            find first b_lote_impl_tit_ap no-lock
                 where b_lote_impl_tit_ap.cod_estab = p_cod_estab
                   and b_lote_impl_tit_ap.cod_refer = p_cod_refer /*cl_verifica_refer_uni of b_lote_impl_tit_ap*/ no-error.
        end /* if */.
        if  avail b_lote_impl_tit_ap
        then do:
            assign p_log_refer_uni = no.
        end /* if */.
        else do:
            if  p_cod_table <> "lote_pagto" /*l_lote_pagto*/ 
            then do:
                find first b_lote_pagto no-lock
                     where b_lote_pagto.cod_estab_refer = p_cod_estab
                       and b_lote_pagto.cod_refer = p_cod_refer /*cl_verifica_refer_uni of b_lote_pagto*/ no-error.
            end /* if */.
            if  avail b_lote_pagto
            then do:
                assign p_log_refer_uni = no.
            end /* if */.
            else do:
                find first b_movto_tit_ap no-lock
                     where b_movto_tit_ap.cod_estab = p_cod_estab
                       and b_movto_tit_ap.cod_refer = p_cod_refer
                       and recid(b_movto_tit_ap) <> p_rec_movto_tit_ap /*cl_verifica_refer_uni_apb of b_movto_tit_ap*/ no-error.
                if  avail b_movto_tit_ap
                then do:
                    assign p_log_refer_uni = no.
                end /* if */.
            end /* else */.
        end /* else */.
    end /* else */.

    &if defined(BF_FIN_BCOS_HISTORICOS) &then
        if can-find(first his_movto_tit_ap_histor no-lock
                    where his_movto_tit_ap_histor.cod_estab = p_cod_estab
                      and his_movto_tit_ap_histor.cod_refer = p_cod_refer) then
            assign p_log_refer_uni = no.
    &endif
END PROCEDURE. /* pi_verifica_refer_unica_apb */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

