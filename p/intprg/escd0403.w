&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
          ems2log          PROGRESS
*/
&Scoped-define WINDOW-NAME wMaintenance


/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE tt-estabelec NO-UNDO LIKE estabelec
       field r-rowid as rowid.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS wMaintenance 
/*:T*******************************************************************************
** Copyright TOTVS S.A. (2009)
** Todos os Direitos Reservados.
**
** Este fonte e de propriedade exclusiva da TOTVS, sua reproducao
** parcial ou total por qualquer meio, so podera ser feita mediante
** autorizacao expressa.
*******************************************************************************/
{include/i-prgvrs.i ESCD0403 1.00.00.001KML}

/* Chamada a include do gerenciador de licen‡as. Necessario alterar os parametros */
/*                                                                                */
/* <programa>:  Informar qual o nome do programa.                                 */
/* <m¢dulo>:  Informar qual o m¢dulo a qual o programa pertence.                  */

&IF "{&EMSFND_VERSION}" >= "1.00" &THEN
    {include/i-license-manager.i ESCD0403 MFT}
&ENDIF

CREATE WIDGET-POOL.

/* Preprocessors Definitions ---                                      */
&GLOBAL-DEFINE Program        ESCD0403
&GLOBAL-DEFINE Version        1.00.00.001KML

&GLOBAL-DEFINE Folder         YES
&GLOBAL-DEFINE InitialPage    1

&GLOBAL-DEFINE FolderLabels   Gerais

&GLOBAL-DEFINE First          YES
&GLOBAL-DEFINE Prev           YES
&GLOBAL-DEFINE Next           YES
&GLOBAL-DEFINE Last           YES
&GLOBAL-DEFINE GoTo           YES
&GLOBAL-DEFINE Search         YES

&GLOBAL-DEFINE Add            YES
&GLOBAL-DEFINE Copy           YES
&GLOBAL-DEFINE Update         YES
&GLOBAL-DEFINE Delete         YES
&GLOBAL-DEFINE Undo           YES
&GLOBAL-DEFINE Cancel         YES
&GLOBAL-DEFINE Save           YES

&GLOBAL-DEFINE ttTable        tt-estabelec
&GLOBAL-DEFINE hDBOTable      hestabelec
&GLOBAL-DEFINE DBOTable       estabelec

&GLOBAL-DEFINE page0KeyFields 
&GLOBAL-DEFINE page0Fields    tt-estabelec.cod-estabel tt-estabelec.nome
&GLOBAL-DEFINE page1Fields    tt-estabelec.cgc tt-estabelec.endereco tt-estabelec.bairro tt-estabelec.cidade tt-estabelec.estado ~
                              tt-estabelec.pais tt-estabelec.cep tt-estabelec.ins-estadual tt-estabelec.ins-municipal tt-estabelec.val-livre-1 ~
                              tt-estabelec.serie tt-estabelec.serie-manual tt-estabelec.grupo-aloca c-serie-nfse tt-estabelec.cod-emitente ~
                              tt-estabelec.cod-suframa cod-repar-fiscal cod-cnae c-nome-fantasia c-nome-pessoa c-email c-telefone ~
                              tt-estabelec.dep-rej-cq tt-estabelec.deposito-cq tt-estabelec.idi-tributac-cofins c-cod-pessoa-jur

                             
&GLOBAL-DEFINE page2Fields    

//  tt-estabelec.ct-icms-ft tt-estabelec.sc-icms-ft tt-estabelec.ct-icms-comp tt-estabelec.sc-icms-comp tt-estabelec.cod-cta-icms-ativ-recup tt-estabelec.cod-ccusto-icms-ativ-recup  ~

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */

DEFINE BUFFER bfpessoa_jurid FOR pessoa_jurid.
DEFINE BUFFER bfemitente FOR emitente.
DEFINE BUFFER bfestabelecimento FOR estabelecimento.
DEFINE BUFFER bfestab_unid_negoc FOR estab_unid_negoc.
DEFINE BUFFER bfunid_organ FOR ems5.unid_organ.  
DEFINE BUFFER bftrad_org_ext FOR trad_org_ext.
DEFINE BUFFER bfcontabiliza FOR contabiliza.
DEFINE BUFFER bfparam-gener FOR param-gener.
DEFINE BUFFER bfestab-mat FOR estab-mat.
DEFINE BUFFER bfmla-perm-lotacao FOR mla-perm-lotacao.
DEFINE BUFFER bfmla-param-aprov FOR mla-param-aprov.
DEFINE BUFFER bfmla-tipo-doc-aprov FOR mla-tipo-doc-aprov.
DEFINE BUFFER bfconta-ft FOR conta-ft.
DEFINE BUFFER bfmapa_distrib_ccusto FOR mapa_distrib_ccusto .
DEFINE BUFFER bfitem_lista_ccusto FOR item_lista_ccusto.
DEFINE BUFFER bfcriter_distrib_cta_ctbl FOR criter_distrib_cta_ctbl.
DEFINE BUFFER bfinf-compl FOR inf-compl.
DEFINE BUFFER bfccusto FOR  ems5.ccusto.

DEFINE VARIABLE c-estab-copia AS CHARACTER   NO-UNDO.

/* Local Variable Definitions (DBOs Handles) --- */
DEFINE VARIABLE {&hDBOTable} AS HANDLE NO-UNDO.

{btb/btb009za.i} /* Defini»’o tt_erros_conexao */
{cdp/cd0666.i}   /* Defini»’o tt_erro */
//{method/dbo.i}
//{method/dboqry.i}




DEFINE NEW GLOBAL SHARED VARIABLE adm-broker-hdl AS HANDLE NO-UNDO.
DEFINE VARIABLE wh-pesquisa AS HANDLE NO-UNDO.


define temp-table tt-param
    field destino          as integer
    field arquivo          as char
    field usuario          as char format "x(12)"
    field data-exec        as date
    field hora-exec        as integer
    field classifica       as integer
    field desc-classifica  as char format "x(40)"
    field i-ep-codigo      like ems2mult.empresa.ep-codigo
    field rs-param         as logical
    field i-cod-ini        as integer
    field i-cod-fim        as integer
    field i-identific      as integer
    field r-execucao       as integer.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Maintenance
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME fpage0

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS tt-estabelec.cod-estabel tt-estabelec.nome 
&Scoped-define ENABLED-TABLES tt-estabelec
&Scoped-define FIRST-ENABLED-TABLE tt-estabelec
&Scoped-Define ENABLED-OBJECTS rtToolBar rtKeys btFirst btPrev btNext ~
btLast btGoTo btSearch btAdd btCopy btUpdate btDelete btUndo btCancel ~
btSave btQueryJoins btReportsJoins btExit btHelp 
&Scoped-Define DISPLAYED-FIELDS tt-estabelec.cod-estabel tt-estabelec.nome 
&Scoped-define DISPLAYED-TABLES tt-estabelec
&Scoped-define FIRST-DISPLAYED-TABLE tt-estabelec


/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR wMaintenance AS WIDGET-HANDLE NO-UNDO.

/* Menu Definitions                                                     */
DEFINE SUB-MENU smFile 
       MENU-ITEM miFirst        LABEL "&Primeiro"      ACCELERATOR "CTRL-HOME"
       MENU-ITEM miPrev         LABEL "&Anterior"      ACCELERATOR "CTRL-CURSOR-LEFT"
       MENU-ITEM miNext         LABEL "&Pr¢ximo"       ACCELERATOR "CTRL-CURSOR-RIGHT"
       MENU-ITEM miLast         LABEL "&éltimo"        ACCELERATOR "CTRL-END"
       RULE
       MENU-ITEM miGoTo         LABEL "&V  Para"       ACCELERATOR "CTRL-T"
       MENU-ITEM miSearch       LABEL "&Pesquisa"      ACCELERATOR "CTRL-F5"
       RULE
       MENU-ITEM miAdd          LABEL "&Incluir"       ACCELERATOR "CTRL-INS"
       MENU-ITEM miCopy         LABEL "&Copiar"        ACCELERATOR "CTRL-C"
       MENU-ITEM miUpdate       LABEL "&Alterar"       ACCELERATOR "CTRL-A"
       MENU-ITEM miDelete       LABEL "&Eliminar"      ACCELERATOR "CTRL-DEL"
       RULE
       MENU-ITEM miUndo         LABEL "&Desfazer"      ACCELERATOR "CTRL-U"
       MENU-ITEM miCancel       LABEL "&Cancelar"      ACCELERATOR "CTRL-F4"
       RULE
       MENU-ITEM miSave         LABEL "&Salvar"        ACCELERATOR "CTRL-S"
       RULE
       MENU-ITEM miQueryJoins   LABEL "&Consultas"    
       MENU-ITEM miReportsJoins LABEL "&Relat¢rios"   
       RULE
       MENU-ITEM miExit         LABEL "&Sair"          ACCELERATOR "CTRL-X".

DEFINE SUB-MENU smHelp 
       MENU-ITEM miContents     LABEL "&Conte£do"     
       RULE
       MENU-ITEM miAbout        LABEL "&Sobre..."     .

DEFINE MENU mbMain MENUBAR
       SUB-MENU  smFile         LABEL "&Arquivo"      
       SUB-MENU  smHelp         LABEL "&Ajuda"        .


/* Definitions of the field level widgets                               */
DEFINE BUTTON btAdd 
     IMAGE-UP FILE "image\im-add":U
     IMAGE-INSENSITIVE FILE "image\ii-add":U
     LABEL "Add" 
     SIZE 4 BY 1.25
     FONT 4.

DEFINE BUTTON btCancel 
     IMAGE-UP FILE "image\im-can":U
     IMAGE-INSENSITIVE FILE "image\im-can":U
     LABEL "Cancel" 
     SIZE 4 BY 1.25
     FONT 4.

DEFINE BUTTON btCopy 
     IMAGE-UP FILE "image\im-copy":U
     IMAGE-INSENSITIVE FILE "image\ii-copy":U
     LABEL "Copy" 
     SIZE 4 BY 1.25
     FONT 4.

DEFINE BUTTON btDelete 
     IMAGE-UP FILE "image\im-era":U
     IMAGE-INSENSITIVE FILE "image\ii-era":U
     LABEL "Delete" 
     SIZE 4 BY 1.25
     FONT 4.

DEFINE BUTTON btExit 
     IMAGE-UP FILE "image\im-exi":U
     IMAGE-INSENSITIVE FILE "image\ii-exi":U
     LABEL "Exit" 
     SIZE 4 BY 1.25
     FONT 4.

DEFINE BUTTON btFirst 
     IMAGE-UP FILE "image\im-fir":U
     IMAGE-INSENSITIVE FILE "image\ii-fir":U
     LABEL "First":L 
     SIZE 4 BY 1.25.

DEFINE BUTTON btGoTo 
     IMAGE-UP FILE "image\im-enter":U
     IMAGE-INSENSITIVE FILE "image\ii-enter":U
     LABEL "Go To" 
     SIZE 4 BY 1.25.

DEFINE BUTTON btHelp 
     IMAGE-UP FILE "image\im-hel":U
     IMAGE-INSENSITIVE FILE "image\ii-hel":U
     LABEL "Help" 
     SIZE 4 BY 1.25
     FONT 4.

DEFINE BUTTON btLast 
     IMAGE-UP FILE "image\im-las":U
     IMAGE-INSENSITIVE FILE "image\ii-las":U
     LABEL "Last":L 
     SIZE 4 BY 1.25.

DEFINE BUTTON btNext 
     IMAGE-UP FILE "image\im-nex":U
     IMAGE-INSENSITIVE FILE "image\ii-nex":U
     LABEL "Next":L 
     SIZE 4 BY 1.25.

DEFINE BUTTON btPrev 
     IMAGE-UP FILE "image\im-pre":U
     IMAGE-INSENSITIVE FILE "image\ii-pre":U
     LABEL "Prev":L 
     SIZE 4 BY 1.25.

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

DEFINE BUTTON btSave 
     IMAGE-UP FILE "image\im-sav":U
     IMAGE-INSENSITIVE FILE "image\ii-sav":U
     LABEL "Save" 
     SIZE 4 BY 1.25
     FONT 4.

DEFINE BUTTON btSearch 
     IMAGE-UP FILE "image\im-sea":U
     IMAGE-INSENSITIVE FILE "image\ii-sea":U
     LABEL "Search" 
     SIZE 4 BY 1.25.

DEFINE BUTTON btUndo 
     IMAGE-UP FILE "image\im-undo":U
     IMAGE-INSENSITIVE FILE "image\ii-undo":U
     LABEL "Undo" 
     SIZE 4 BY 1.25
     FONT 4.

DEFINE BUTTON btUpdate 
     IMAGE-UP FILE "image\im-mod":U
     IMAGE-INSENSITIVE FILE "image\ii-mod":U
     LABEL "Update" 
     SIZE 4 BY 1.25
     FONT 4.

DEFINE RECTANGLE rtKeys
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 154 BY 3.08.

DEFINE RECTANGLE rtToolBar
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 154 BY 1.5
     BGCOLOR 7 .

DEFINE VARIABLE c-cod-pessoa-jur AS CHARACTER FORMAT "X(20)":U 
     LABEL "Pessoa Juridica" 
     VIEW-AS FILL-IN 
     SIZE 11 BY .79 NO-UNDO.

DEFINE VARIABLE c-email AS CHARACTER FORMAT "X(30)":U 
     LABEL "Email" 
     VIEW-AS FILL-IN 
     SIZE 23.72 BY .79 NO-UNDO.

DEFINE VARIABLE c-nome-fantasia AS CHARACTER FORMAT "X(256)":U 
     LABEL "Nome Fantasia" 
     VIEW-AS FILL-IN 
     SIZE 61 BY .79 NO-UNDO.

DEFINE VARIABLE c-nome-pessoa AS CHARACTER FORMAT "X(256)":U 
     LABEL "Nome (Pessoa Juridica)" 
     VIEW-AS FILL-IN 
     SIZE 61 BY .79 NO-UNDO.

DEFINE VARIABLE c-serie-nfse AS CHARACTER FORMAT "X(5)":U 
     LABEL "S‚rie NFS-e" 
     VIEW-AS FILL-IN 
     SIZE 8.86 BY .79 NO-UNDO.

DEFINE VARIABLE c-telefone AS CHARACTER FORMAT "X(25)":U 
     LABEL "Telefone" 
     VIEW-AS FILL-IN 
     SIZE 15.57 BY .79 NO-UNDO.

DEFINE VARIABLE cod-cnae AS CHARACTER FORMAT "X(16)":U 
     LABEL "Cod CNAE" 
     VIEW-AS FILL-IN 
     SIZE 15 BY .79 NO-UNDO.

DEFINE VARIABLE cod-repar-fiscal AS CHARACTER FORMAT "X(256)":U 
     LABEL "C. Repar Fiscal" 
     VIEW-AS FILL-IN 
     SIZE 13.29 BY .79 TOOLTIP "substr(estabelec.char-2,62,20)" NO-UNDO.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 63 BY 5.

DEFINE RECTANGLE RECT-2
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 81.72 BY 5.

DEFINE RECTANGLE RECT-3
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 20 BY 2.75.

DEFINE RECTANGLE RECT-4
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 63 BY 4.5.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME fpage0
     btFirst AT ROW 1.13 COL 1.57 HELP
          "Primeira ocorrˆncia"
     btPrev AT ROW 1.13 COL 5.57 HELP
          "Ocorrˆncia anterior"
     btNext AT ROW 1.13 COL 9.57 HELP
          "Pr¢xima ocorrˆncia"
     btLast AT ROW 1.13 COL 13.57 HELP
          "éltima ocorrˆncia"
     btGoTo AT ROW 1.13 COL 17.57 HELP
          "V  Para"
     btSearch AT ROW 1.13 COL 21.57 HELP
          "Pesquisa"
     btAdd AT ROW 1.13 COL 31 HELP
          "Inclui nova ocorrˆncia"
     btCopy AT ROW 1.13 COL 35 HELP
          "Cria uma c¢pia da ocorrˆncia corrente"
     btUpdate AT ROW 1.13 COL 39 HELP
          "Altera ocorrˆncia corrente"
     btDelete AT ROW 1.13 COL 43 HELP
          "Elimina ocorrˆncia corrente"
     btUndo AT ROW 1.13 COL 47 HELP
          "Desfaz altera‡äes"
     btCancel AT ROW 1.13 COL 51 HELP
          "Cancela altera‡äes"
     btSave AT ROW 1.13 COL 55 HELP
          "Confirma altera‡äes"
     btQueryJoins AT ROW 1.17 COL 137.14 HELP
          "Consultas relacionadas"
     btReportsJoins AT ROW 1.17 COL 141.14 HELP
          "Relat¢rios relacionados"
     btExit AT ROW 1.17 COL 145.14 HELP
          "Sair"
     btHelp AT ROW 1.17 COL 149.14 HELP
          "Ajuda"
     tt-estabelec.cod-estabel AT ROW 3.75 COL 9 COLON-ALIGNED WIDGET-ID 6
          VIEW-AS FILL-IN 
          SIZE 11 BY .79
     tt-estabelec.nome AT ROW 3.75 COL 21 COLON-ALIGNED NO-LABEL WIDGET-ID 8
          VIEW-AS FILL-IN 
          SIZE 56 BY .79
     rtToolBar AT ROW 1 COL 1
     rtKeys AT ROW 2.67 COL 1
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 154 BY 19.75
         FONT 1 WIDGET-ID 100.

DEFINE FRAME fPage1
     c-nome-fantasia AT ROW 1.5 COL 16.86 COLON-ALIGNED WIDGET-ID 86
     c-cod-pessoa-jur AT ROW 2.46 COL 93 COLON-ALIGNED WIDGET-ID 90
     c-nome-pessoa AT ROW 2.5 COL 16.72 COLON-ALIGNED WIDGET-ID 88
     tt-estabelec.cod-suframa AT ROW 5.21 COL 128.57 COLON-ALIGNED WIDGET-ID 36
          VIEW-AS FILL-IN 
          SIZE 13.43 BY .79
     tt-estabelec.endereco AT ROW 5.25 COL 9.86 COLON-ALIGNED WIDGET-ID 12
          VIEW-AS FILL-IN 
          SIZE 51.14 BY .79
     tt-estabelec.cgc AT ROW 5.25 COL 74.86 COLON-ALIGNED WIDGET-ID 2
          VIEW-AS FILL-IN 
          SIZE 18 BY .79
     tt-estabelec.serie AT ROW 5.25 COL 107 COLON-ALIGNED WIDGET-ID 24
          VIEW-AS FILL-IN 
          SIZE 8.86 BY .79
     tt-estabelec.bairro AT ROW 6.33 COL 10 COLON-ALIGNED WIDGET-ID 4
          VIEW-AS FILL-IN 
          SIZE 25 BY .79
     tt-estabelec.pais AT ROW 6.33 COL 41.14 COLON-ALIGNED WIDGET-ID 20
          VIEW-AS FILL-IN 
          SIZE 10.29 BY .79
     tt-estabelec.estado AT ROW 6.33 COL 55.43 COLON-ALIGNED WIDGET-ID 14
          VIEW-AS FILL-IN 
          SIZE 5.14 BY .79
     tt-estabelec.ins-estadual AT ROW 6.33 COL 75 COLON-ALIGNED WIDGET-ID 16
          LABEL "Ins. Estadual"
          VIEW-AS FILL-IN 
          SIZE 15 BY .79
     tt-estabelec.serie-manual AT ROW 6.33 COL 107 COLON-ALIGNED WIDGET-ID 26
          VIEW-AS FILL-IN 
          SIZE 8.86 BY .79
     cod-repar-fiscal AT ROW 6.33 COL 128.57 COLON-ALIGNED WIDGET-ID 38
     tt-estabelec.grupo-aloca AT ROW 7.46 COL 107 COLON-ALIGNED WIDGET-ID 28
          VIEW-AS FILL-IN 
          SIZE 8.86 BY .79
     cod-cnae AT ROW 7.46 COL 128.57 COLON-ALIGNED WIDGET-ID 40
     tt-estabelec.cidade AT ROW 7.5 COL 10 COLON-ALIGNED WIDGET-ID 8
          VIEW-AS FILL-IN 
          SIZE 28 BY .79
     c-telefone AT ROW 7.5 COL 45.43 COLON-ALIGNED WIDGET-ID 94
     tt-estabelec.ins-municipal AT ROW 7.5 COL 75 COLON-ALIGNED WIDGET-ID 18
          LABEL "Ins. Municipal"
          VIEW-AS FILL-IN 
          SIZE 15 BY .79
     c-serie-nfse AT ROW 8.5 COL 107 COLON-ALIGNED WIDGET-ID 30
     tt-estabelec.cep AT ROW 8.58 COL 10 COLON-ALIGNED WIDGET-ID 6 FORMAT "99999999"
          VIEW-AS FILL-IN 
          SIZE 8.86 BY .79
     c-email AT ROW 8.58 COL 25.29 COLON-ALIGNED WIDGET-ID 92
     tt-estabelec.val-livre-1 AT ROW 8.58 COL 74.86 COLON-ALIGNED WIDGET-ID 22
          LABEL "Nire"
          VIEW-AS FILL-IN 
          SIZE 11.72 BY .79
     tt-estabelec.cod-emitente AT ROW 10.5 COL 14 COLON-ALIGNED WIDGET-ID 10
          VIEW-AS FILL-IN 
          SIZE 11 BY .79
     tt-estabelec.idi-tributac-cofins AT ROW 11.25 COL 35.14 NO-LABEL WIDGET-ID 48
          VIEW-AS RADIO-SET VERTICAL
          RADIO-BUTTONS 
                    "Tributado", 1,
"Isento", 2,
"Outros", 3
          SIZE 11 BY 1.75
     tt-estabelec.dep-rej-cq AT ROW 11.63 COL 14 COLON-ALIGNED WIDGET-ID 46
          LABEL "Dep. Rejei‡Æo CQ"
          VIEW-AS FILL-IN 
          SIZE 8.86 BY .79
     tt-estabelec.deposito-cq AT ROW 12.75 COL 14 COLON-ALIGNED WIDGET-ID 42
          VIEW-AS FILL-IN 
          SIZE 8.86 BY .79
     "Tributa‡Æo PI/COFINS" VIEW-AS TEXT
          SIZE 17 BY .54 AT ROW 10.54 COL 34.14 WIDGET-ID 52
     RECT-1 AT ROW 4.75 COL 2 WIDGET-ID 32
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 3.57 ROW 6.38
         SIZE 151.43 BY 14.38
         FONT 1 WIDGET-ID 100.

/* DEFINE FRAME statement is approaching 4K Bytes.  Breaking it up   */
DEFINE FRAME fPage1
     RECT-2 AT ROW 4.75 COL 65.72 WIDGET-ID 34
     RECT-3 AT ROW 10.75 COL 33.14 WIDGET-ID 54
     RECT-4 AT ROW 9.96 COL 2 WIDGET-ID 56
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 3.57 ROW 6.38
         SIZE 151.43 BY 14.38
         FONT 1 WIDGET-ID 100.

DEFINE FRAME fPage2
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 152 ROW 19.92
         SIZE 2.72 BY .79
         FONT 1 WIDGET-ID 100.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Maintenance
   Allow: Basic,Browse,DB-Fields,Window,Query
   Add Fields to: Neither
   Other Settings: COMPILE
   Temp-Tables and Buffers:
      TABLE: tt-estabelec T "?" NO-UNDO ems2log estabelec
      ADDITIONAL-FIELDS:
          field r-rowid as rowid
      END-FIELDS.
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
IF SESSION:DISPLAY-TYPE = "GUI":U THEN
  CREATE WINDOW wMaintenance ASSIGN
         HIDDEN             = YES
         TITLE              = ""
         HEIGHT             = 19.75
         WIDTH              = 154
         MAX-HEIGHT         = 28.29
         MAX-WIDTH          = 156.72
         VIRTUAL-HEIGHT     = 28.29
         VIRTUAL-WIDTH      = 156.72
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _INCLUDED-LIB wMaintenance 
/* ************************* Included-Libraries *********************** */

{maintenance/maintenance.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME




/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW wMaintenance
  NOT-VISIBLE,,RUN-PERSISTENT                                           */
/* REPARENT FRAME */
ASSIGN FRAME fPage1:FRAME = FRAME fpage0:HANDLE
       FRAME fPage2:FRAME = FRAME fpage0:HANDLE.

/* SETTINGS FOR FRAME fpage0
   FRAME-NAME                                                           */
/* SETTINGS FOR FILL-IN tt-estabelec.nome IN FRAME fpage0
   EXP-LABEL                                                            */
/* SETTINGS FOR FRAME fPage1
                                                                        */
/* SETTINGS FOR FILL-IN c-cod-pessoa-jur IN FRAME fPage1
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN tt-estabelec.cep IN FRAME fPage1
   EXP-FORMAT                                                           */
/* SETTINGS FOR FILL-IN tt-estabelec.dep-rej-cq IN FRAME fPage1
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-estabelec.ins-estadual IN FRAME fPage1
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-estabelec.ins-municipal IN FRAME fPage1
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-estabelec.val-livre-1 IN FRAME fPage1
   EXP-LABEL                                                            */
/* SETTINGS FOR FRAME fPage2
                                                                        */
ASSIGN 
       FRAME fPage2:SENSITIVE        = FALSE.

IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(wMaintenance)
THEN wMaintenance:HIDDEN = yes.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK FRAME fpage0
/* Query rebuild information for FRAME fpage0
     _Options          = "SHARE-LOCK KEEP-EMPTY"
     _Query            is NOT OPENED
*/  /* FRAME fpage0 */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK FRAME fPage1
/* Query rebuild information for FRAME fPage1
     _Options          = "SHARE-LOCK KEEP-EMPTY"
     _Query            is NOT OPENED
*/  /* FRAME fPage1 */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK FRAME fPage2
/* Query rebuild information for FRAME fPage2
     _Query            is NOT OPENED
*/  /* FRAME fPage2 */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME wMaintenance
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL wMaintenance wMaintenance
ON END-ERROR OF wMaintenance
OR ENDKEY OF {&WINDOW-NAME} ANYWHERE DO:
  /* This case occurs when the user presses the "Esc" key.
     In a persistently run window, just ignore this.  If we did not, the
     application would exit. */
  IF THIS-PROCEDURE:PERSISTENT THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL wMaintenance wMaintenance
ON WINDOW-CLOSE OF wMaintenance
DO:
  /* This event will close the window and terminate the procedure.  */
  APPLY "CLOSE":U TO THIS-PROCEDURE.
  RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btAdd
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btAdd wMaintenance
ON CHOOSE OF btAdd IN FRAME fpage0 /* Add */
OR CHOOSE OF MENU-ITEM miAdd in MENU mbMain DO:
    RUN addRecord IN THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btCancel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btCancel wMaintenance
ON CHOOSE OF btCancel IN FRAME fpage0 /* Cancel */
OR CHOOSE OF MENU-ITEM miCancel IN MENU mbMain DO:
    RUN cancelRecord IN THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btCopy
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btCopy wMaintenance
ON CHOOSE OF btCopy IN FRAME fpage0 /* Copy */
OR CHOOSE OF MENU-ITEM miCopy IN MENU mbMain DO:

    ASSIGN c-cod-pessoa-jur:SCREEN-VALUE IN FRAME fpage1 = ""
           tt-estabelec.cod-emitente:SCREEN-VALUE IN FRAM fpage1 = "".

    ASSIGN c-estab-copia = tt-estabelec.cod-estabel:SCREEN-VALUE IN FRAME fpage0.

    RUN copyRecord IN THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btDelete
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btDelete wMaintenance
ON CHOOSE OF btDelete IN FRAME fpage0 /* Delete */
OR CHOOSE OF MENU-ITEM miDelete IN MENU mbMain DO:
    RUN deleteRecord IN THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btExit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btExit wMaintenance
ON CHOOSE OF btExit IN FRAME fpage0 /* Exit */
OR CHOOSE OF MENU-ITEM miExit IN MENU mbMain DO:
    APPLY "CLOSE":U TO THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btFirst
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btFirst wMaintenance
ON CHOOSE OF btFirst IN FRAME fpage0 /* First */
OR CHOOSE OF MENU-ITEM miFirst IN MENU mbMain DO:
    RUN getFirst IN THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btGoTo
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btGoTo wMaintenance
ON CHOOSE OF btGoTo IN FRAME fpage0 /* Go To */
OR CHOOSE OF MENU-ITEM miGoTo IN MENU mbMain DO:
    RUN goToRecord IN THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btHelp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btHelp wMaintenance
ON CHOOSE OF btHelp IN FRAME fpage0 /* Help */
OR CHOOSE OF MENU-ITEM miContents IN MENU mbMain DO:
    {include/ajuda.i}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btLast
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btLast wMaintenance
ON CHOOSE OF btLast IN FRAME fpage0 /* Last */
OR CHOOSE OF MENU-ITEM miLast IN MENU mbMain DO:
    RUN getLast IN THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btNext
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btNext wMaintenance
ON CHOOSE OF btNext IN FRAME fpage0 /* Next */
OR CHOOSE OF MENU-ITEM miNext IN MENU mbMain DO:
    RUN getNext IN THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btPrev
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btPrev wMaintenance
ON CHOOSE OF btPrev IN FRAME fpage0 /* Prev */
OR CHOOSE OF MENU-ITEM miPrev IN MENU mbMain DO:
    RUN getPrev IN THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btQueryJoins
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btQueryJoins wMaintenance
ON CHOOSE OF btQueryJoins IN FRAME fpage0 /* Query Joins */
OR CHOOSE OF MENU-ITEM miQueryJoins IN MENU mbMain DO:
    RUN showQueryJoins IN THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btReportsJoins
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btReportsJoins wMaintenance
ON CHOOSE OF btReportsJoins IN FRAME fpage0 /* Reports Joins */
OR CHOOSE OF MENU-ITEM miReportsJoins IN MENU mbMain DO:
    RUN showReportsJoins IN THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btSave
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btSave wMaintenance
ON CHOOSE OF btSave IN FRAME fpage0 /* Save */
OR CHOOSE OF MENU-ITEM miSave IN MENU mbMain DO:




    RUN validaDados.
    
    IF RETURN-VALUE = "OK" THEN
    DO:
    
        RUN gera-cliente-fornecedor.
        RUN gera-pessoa-juridica.
        RUN gera-estab-ems5.
        RUN gera-complemento-estab.
        RUN gera-unid-organ.
        RUN gera-localizacao.
        RUN gera-contas-contabilizacao.
        RUN gera-estab-material.
        RUN gera-mla.
      //  RUN afterdisplayfields.



        RUN saveRecord IN THIS-PROCEDURE.

        
    END.

END.



/*



Table: cst_estabelec

Field Name                  Data Type  Flg Format
--------------------------- ---------- --- --------------------------------
cod_estabel                 char       i   x(3)
dt_fim_operacao             date           99/99/9999
sistema                     logi           Oblak/Procfit
dt_inicio_oper              date           99/99/9999
dt_alter                    date           99/99/9999
cod_usuario                 char           x(12)
cod_adquirente              inte           999
cod_portador_db             inte           >>>>9
cod_portador_cr             inte           >>>>9



*/

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btSearch
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btSearch wMaintenance
ON CHOOSE OF btSearch IN FRAME fpage0 /* Search */
OR CHOOSE OF MENU-ITEM miSearch IN MENU mbMain DO:

    {include/zoomvar.i &prog-zoom="adzoom/z01ad107.w"
               &campo="tt-estabelec.cod-estabel"
               &campozoom="cod-estabel"
               &frame="fPage0"
               &campo2="tt-estabelec.nome"
               &campozoom2="nome"
               &frame2="fPage0"}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btUndo
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btUndo wMaintenance
ON CHOOSE OF btUndo IN FRAME fpage0 /* Undo */
OR CHOOSE OF MENU-ITEM miUndo IN MENU mbMain DO:
    RUN undoRecord IN THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btUpdate
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btUpdate wMaintenance
ON CHOOSE OF btUpdate IN FRAME fpage0 /* Update */
OR CHOOSE OF MENU-ITEM miUpdate IN MENU mbMain DO:
    RUN updateRecord IN THIS-PROCEDURE.

    ASSIGN c-cod-pessoa-jur:SENSITIVE IN FRAME fpage1 = NO.

    ASSIGN c-estab-copia = tt-estabelec.cod-estabel:SCREEN-VALUE IN FRAME fpage0.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME fPage1
&Scoped-define SELF-NAME c-serie-nfse
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL c-serie-nfse wMaintenance
ON VALUE-CHANGED OF c-serie-nfse IN FRAME fPage1 /* S‚rie NFS-e */
DO:
  ASSIGN c-serie-nfse:SCREEN-VALUE IN FRAME fpage1 = SUBSTRING(tt-estabelec.char-2,233,5).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-estabelec.cidade
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-estabelec.cidade wMaintenance
ON F5 OF tt-estabelec.cidade IN FRAME fPage1 /* Cidade */
DO:
   {method/zoomfields.i &ProgramZoom="dizoom/z01di341.w"
                &FieldZoom1="cidade"
                &FieldScreen1="tt-estabelec.cidade"
                &Frame1="fPage1"
                &EnableImplant="NO"}  
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-estabelec.cidade wMaintenance
ON LEAVE OF tt-estabelec.cidade IN FRAME fPage1 /* Cidade */
DO:
  /*  MESSAGE "teste"
        VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
        
 FOR EACH estabelec        nis
     WHERE estabelec.cod-estabel = tt-estabelec.cod-estabel:
     
     MESSAGE "teste 3 " 
         VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.

    FIND FIRST  ems2dis.cidade NO-LOCK
         WHERE cidade.cidade  = estabelec.cidade.
             
             MESSAGE cidade.cidade SKIP
                     tt-estabelec.cod-estabel
                 VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
             
             IF NOT AVAIL cidade THEN
             DO:
             
             MESSAGE "entrou if not avail"
                 VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
              RETURN "OK".
              
          END.   
     END. */ 
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-estabelec.cidade wMaintenance
ON MOUSE-SELECT-DBLCLICK OF tt-estabelec.cidade IN FRAME fPage1 /* Cidade */
DO:

    APPLY "f5" TO SELF.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME miAbout
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL miAbout wMaintenance
ON CHOOSE OF MENU-ITEM miAbout /* Sobre... */
DO:
  {include/sobre.i}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME fpage0
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK wMaintenance 


/*:T--- L¢gica para inicializa‡Æo do programam ---*/
{maintenance/mainblock.i}


tt-estabelec.cidade:load-mouse-pointer("image/lupa.cur":U)  in frame fPage1.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE afterdisplayfields wMaintenance 
PROCEDURE afterdisplayfields :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

  FIND FIRST estab-compl NO-LOCK
       WHERE estab-compl.cod-estabel = tt-estabelec.cod-estabel:SCREEN-VALUE IN FRAME fpage0 NO-ERROR.

  IF AVAIL estab-compl THEN DO:

      ASSIGN c-nome-fantasia:SCREEN-VALUE IN FRAME fpage1 = estab-compl.nom-fantasia. 

  END.

  FIND FIRST ems5.fornecedor NO-LOCK
      WHERE fornecedor.cdn_fornecedor = int(tt-estabelec.cod-emitente:SCREEN-VALUE IN FRAME fpage1) NO-ERROR.


  IF AVAIL fornecedor THEN DO:


      FIND FIRST pessoa_jurid NO-LOCK
          WHERE pessoa_jurid.num_pessoa_jurid = fornecedor.num_pessoa NO-ERROR.

      IF AVAIL pessoa_jurid THEN DO:

          ASSIGN c-nome-pessoa:SCREEN-VALUE IN FRAME fpage1 = pessoa_jurid.nom_pessoa
                 c-cod-pessoa-jur:SCREEN-VALUE IN FRAME fpage1 = string(pessoa_jurid.num_pessoa_jurid)
                 c-email:SCREEN-VALUE IN FRAME fpage1 = pessoa_jurid.cod_e_mail
                 c-telefone:SCREEN-VALUE IN FRAME fpage1 = pessoa_jurid.cod_telefone. 

      END.

  END.


  


END PROCEDURE.


/*

---------------------------
Informacao
---------------------------
DBName: ems5 
Table: pessoa_jurid 
Name: cod_e_mail 
Type: CHARACTER 
Format: x(80) 
Transaction: yes 
Program: prgint/utb/utb006ec.p 
Path: \\192.168.200.78\Totvs12\_quarentena_teste\ems5\prgint\utb\utb006ec.r
---------------------------
OK   
---------------------------


*/

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE gera-cliente-fornecedor wMaintenance 
PROCEDURE gera-cliente-fornecedor :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/


    DEFINE VARIABLE i-emitente AS INTEGER     NO-UNDO.
    DEFINE VARIABLE h-cd1608 AS HANDLE      NO-UNDO.

    FIND FIRST emitente EXCLUSIVE-LOCK
        WHERE emitente.cod-emitente = int(tt-estabelec.cod-emitente:SCREEN-VALUE IN FRAME fpage1) 
         AND tt-estabelec.cod-emitente:SCREEN-VALUE IN FRAME fpage1 <> "0" NO-ERROR.
    
    
    IF AVAIL emitente THEN DO: // atualizar registros
        
        ASSIGN emitente.nome-emit             = c-nome-pessoa:SCREEN-VALUE IN FRAME fpage1
               emitente.ins-estadual          = tt-estabelec.ins-estadual:SCREEN-VALUE IN FRAME fpage1 
               emitente.ins-municipal         = tt-estabelec.ins-municipal:SCREEN-VALUE IN FRAME fpage1 
               emitente.endereco              = tt-estabelec.endereco:SCREEN-VALUE IN FRAME fpage1 
               emitente.bairro                = tt-estabelec.bairro:SCREEN-VALUE IN FRAME fpage1
               emitente.estado                = tt-estabelec.estado:SCREEN-VALUE IN FRAME fpage1
               emitente.cidade                = tt-estabelec.cidade:SCREEN-VALUE IN FRAME fpage1
               emitente.cep                   = tt-estabelec.cep:SCREEN-VALUE IN FRAME fpage1 
               emitente.zip-code              = tt-estabelec.cep:SCREEN-VALUE IN FRAME fpage1
               emitente.pais                  = tt-estabelec.pais:SCREEN-VALUE IN FRAME fpage1 
               emitente.endereco-cob          = tt-estabelec.endereco:SCREEN-VALUE IN FRAME fpage1 
               emitente.e-mail                = c-email:SCREEN-VALUE IN FRAME fpage1 
               emitente.telefone[1]           = c-telefone:SCREEN-VALUE IN FRAME fpage1 
               emitente.bairro-cob            = tt-estabelec.bairro:SCREEN-VALUE IN FRAME fpage1 
               emitente.estado-cob            = tt-estabelec.estado:SCREEN-VALUE IN FRAME fpage1
               emitente.cidade-cob            = tt-estabelec.cidade:SCREEN-VALUE IN FRAME fpage1 
               emitente.cep-cob               = tt-estabelec.cep:SCREEN-VALUE IN FRAME fpage1 
               emitente.pais-cob              = tt-estabelec.pais:SCREEN-VALUE IN FRAME fpage1 
               emitente.ins-est-cob           = tt-estabelec.ins-estadual:SCREEN-VALUE IN FRAME fpage1 
               emitente.cgc                   = tt-estabelec.cgc:SCREEN-VALUE IN FRAME fpage1
               emitente.cgc-cob               = tt-estabelec.cgc:SCREEN-VALUE IN FRAME fpage1.  
                         

        ASSIGN tt-estabelec.cod-emitente:SCREEN-VALUE IN FRAME fpage1 = STRING(emitente.cod-emitente).               
        
    
    END.
    ELSE DO:  // criar novo cliente

        RUN cdp/cd9960.p (OUTPUT i-emitente).

        FIND FIRST bfemitente NO-LOCK
            WHERE bfemitente.cod-emitente = 1541990 NO-ERROR.  // Pega o emitente da loja 014 para c¢pia

        CREATE emitente.

        BUFFER-COPY bfemitente EXCEPT cod-emitente nome-abrev TO emitente.

        ASSIGN emitente.cod-emitente          = i-emitente
               emitente.nome-abrev            = "NISSEI " + tt-estabelec.cod-estabel:SCREEN-VALUE IN FRAME fpage0
               emitente.cgc                   = tt-estabelec.cgc:SCREEN-VALUE IN FRAME fpage1
               emitente.cgc-cob               = tt-estabelec.cgc:SCREEN-VALUE IN FRAME fpage1
               emitente.nome-matriz           = "NISSEI " + tt-estabelec.cod-estabel:SCREEN-VALUE IN FRAME fpage0
               emitente.end-cobranca          = i-emitente.
        
        ASSIGN emitente.nome-emit             = c-nome-pessoa:SCREEN-VALUE IN FRAME fpage1
               emitente.ins-estadual          = tt-estabelec.ins-estadual:SCREEN-VALUE IN FRAME fpage1 
               emitente.ins-municipal         = tt-estabelec.ins-municipal:SCREEN-VALUE IN FRAME fpage1 
               emitente.endereco              = tt-estabelec.endereco:SCREEN-VALUE IN FRAME fpage1 
               emitente.bairro                = tt-estabelec.bairro:SCREEN-VALUE IN FRAME fpage1
               emitente.cidade                = tt-estabelec.cidade:SCREEN-VALUE IN FRAME fpage1
               emitente.estado                = tt-estabelec.estado:SCREEN-VALUE IN FRAME fpage1
               emitente.cep                   = tt-estabelec.cep:SCREEN-VALUE IN FRAME fpage1
               emitente.zip-code              = tt-estabelec.cep:SCREEN-VALUE IN FRAME fpage1
               emitente.pais                  = tt-estabelec.pais:SCREEN-VALUE IN FRAME fpage1 
               emitente.e-mail                = c-email:SCREEN-VALUE IN FRAME fpage1 
               emitente.telefone[1]           = c-telefone:SCREEN-VALUE IN FRAME fpage1 
               emitente.endereco-cob          = tt-estabelec.endereco:SCREEN-VALUE IN FRAME fpage1 
               emitente.bairro-cob            = tt-estabelec.bairro:SCREEN-VALUE IN FRAME fpage1 
               emitente.estado-cob            = tt-estabelec.estado:SCREEN-VALUE IN FRAME fpage1
               emitente.cidade-cob            = tt-estabelec.cidade:SCREEN-VALUE IN FRAME fpage1 
               emitente.cep-cob               = tt-estabelec.cep:SCREEN-VALUE IN FRAME fpage1 
               emitente.pais-cob              = tt-estabelec.pais:SCREEN-VALUE IN FRAME fpage1
               emitente.ins-est-cob           = tt-estabelec.ins-estadual:SCREEN-VALUE IN FRAME fpage1    .

        ASSIGN tt-estabelec.cod-emitente:SCREEN-VALUE IN FRAME fpage1 = STRING(i-emitente).

     //   RELEASE emitente.
    
    END.

    FIND FIRST loc-entr 
        WHERE loc-entr.nome-abrev  = emitente.nome-abrev
          AND loc-entr.cod-entrega = "PadrÆo" NO-ERROR.

    IF NOT AVAIL loc-entr THEN DO:
        CREATE loc-entr.
        ASSIGN loc-entr.nome-abrev  = emitente.nome-abrev  
                loc-entr.cod-entrega = "PadrÆo".            
    END.
    ASSIGN loc-entr.endereco     = emitente.endereco
           loc-entr.bairro       = SUBSTRING(emitente.bairro,1,30)
           loc-entr.cidade       = emitente.cidade
           loc-entr.estado       = emitente.estado
           loc-entr.pais         = emitente.pais
           loc-entr.cep          = emitente.cep
           loc-entr.ins-estadual = emitente.ins-estadual  
           loc-entr.cgc          = emitente.cgc.

    
    run cdp/cd1608.p PERSISTENT SET h-cd1608
                 (input emitente.cod-emitente,
                  input emitente.cod-emitente,
                  input emitente.identific,
                  input yes,
                  input 1,
                  input 0,
                  input session:temp-dir + "integracaoEMS5.txt",
                  input "Terminal",
                  input "").
    run pi-erros in h-cd1608 (output table tt_erros_conexao).
    delete procedure h-cd1608.
    for each tt-erro:
        delete tt-erro.
    end.    
    for each tt_erros_conexao:
        create tt-erro.
        assign tt-erro.cd-erro  = tt_erros_conexao.cd-erro
               tt-erro.i-sequen = tt_erros_conexao.i-sequen
               tt-erro.mensagem = tt_erros_conexao.mensagem.
    end.
    if can-find (first tt-erro) then do:
        run cdp/cd0666.w (input table tt-erro).
     /*return "adm-error".*/                  
    end.

    


END PROCEDURE.


    /*
    
    
    
Table: emitente

Field Name                  Data Type  Flg Format
--------------------------- ---------- --- --------------------------------
cod-emitente                inte       im  >>>>>>>>9
nome-abrev                  char       im  X(12)
cgc                         char       i   x(19)
identific                   inte       m   >9
natureza                    inte       m   >9
nome-emit                   char       m   x(80)
endereco                    char       m   X(40)
bairro                      char       m   X(30)
cidade                      char       im  x(50)
estado                      char       m   x(4)
cep                         char       m   x(12)
caixa-postal                char           x(10)
pais                        char       im  x(20)
ins-estadual                char       m   X(19)
cod-cond-pag                inte       i   >>>9
taxa-financ                 deci-2     m   >>9.99
data-taxa                   date           99/99/9999
cod-transp                  inte       im  >>,>>9
cod-gr-forn                 inte       i   >9
linha-produt                char       m   X(08)
atividade                   char       m   X(12)
contato                     char[2]    m   X(12)
telefone                    char[2]    m   x(15)
ramal                       char[2]    m   x(05)
telefax                     char       m   x(15)
ramal-fax                   char           x(05)
telex                       char       m   x(15)
data-implant                date       m   99/99/9999
compr-period                deci-2         >>>>,>>>,>>>,>>9.99
end-cobranca                inte       im  >>>>>>>>9
cod-rep                     inte       im  >>>>9
categoria                   char       m   X(03)
bonificacao                 deci-3     m   >>9.999
istr                        inte       m   9
cod-gr-cli                  inte       im  >>>9
lim-credito                 deci-2     m   >>>,>>>,>>9.99
dt-lim-cred                 date           99/99/9999
perc-fat-ped                inte       m   >>9
portador                    inte       im  >>>>9
modalidade                  inte       im  9
ind-fat-par                 logi       m   Sim/NÆo
ind-cre-cli                 inte       m   9
ind-apr-cred                logi       m   Sim/NÆo
nat-operacao                char       im  x(06)
observacoes                 char       m   x(2000)
per-minfat                  deci-2         >9.99
emissao-ped                 inte           >9
nome-matriz                 char       im  x(12)
telef-modem                 char           x(15)
ramal-modem                 char           x(07)
telef-fac                   char           x(15)
ramal-fac                   char           x(05)
agencia                     char       m   x(8)
nr-titulo                   inte           >>>>>>>9
nr-dias                     inte           >>>>>>>9
per-max-canc                deci-2     m   >9.99
dt-ult-venda                date           99/99/9999
emite-bloq                  logi           Sim/NÆo
emite-etiq                  logi       m   Sim/NÆo
tr-ar-valor                 inte       m   >9
gera-ad                     logi       m   Sim/NÆo
port-prefer                 inte           >>>>9
mod-prefer                  inte       m   9
bx-acatada                  inte       m   >>9
conta-corren                char       m   x(20)
nr-copias-ped               inte       m   >9
cod-suframa                 char       m   x(20)
cod-cacex                   char       m   x(20)
gera-difer                  inte       m   9
nr-tabpre                   char       m   x(8)
ind-aval                    inte       m   9
user-libcre                 char       m   x(12)
ins-banc                    inte[2]        >>9
ven-feriado                 inte       m   9
ven-domingo                 inte       m   9
ven-sabado                  inte       m   9
cgc-cob                     char       m   x(19)
cep-cob                     char           x(12)
estado-cob                  char       m   x(04)
cidade-cob                  char       m   x(50)
bairro-cob                  char       m   x(30)
endereco-cob                char       m   X(40)
cx-post-cob                 char           x(10)
ins-est-cob                 char       m   x(19)
nome-mic-reg                char       i   x(12)
tip-cob-desp                inte           9
nome-tr-red                 char       i   x(12)
nat-ope-ext                 char           x(06)
cod-banco                   inte       m   999
prox-ad                     inte       m   >>>>>9
lim-adicional               deci-2         >>>,>>>,>>9.99
dt-fim-cred                 date           99/99/9999
obs-entrega                 char           x(2000)
cod-tip-ent                 inte           >>9
ins-municipal               char       m   X(19)
nr-peratr                   inte       m   >9
nr-mesina                   inte       m   >9
insc-subs-trib              char           x(19)
cod-mensagem                inte       m   >>9
nr-dias-taxa                inte           >>9
tp-desp-padrao              inte           >>9
tp-rec-padrao               inte           >>9
inf-complementar            char           x(12)
zip-code                    char           x(12)
tp-inspecao                 inte           9
forn-exp                    logi       m   Sim/NÆo
tp-qt-prg                   inte       m   9
ind-atraso                  inte       m   9
ind-div-atraso              inte       m   9
ind-dif-atrs-1              inte       m   9
ind-dif-atrs-2              inte       m   9
esp-pd-venda                inte       m   99
ind-lib-estoque             logi           Sim/NÆo
ind-moeda-tit               inte           >9
ind-rendiment               logi           Sim/NÆo
tp-pagto                    inte           99
vl-min-ad                   deci-2         >>,>>>,>>>,>>9.99
zip-cob-code                char           x(12)
hora-ini                    inte           99
hora-fim                    inte           99
pais-cob                    char           x(20)
resumo-mp                   inte       m   >9
ind-cred-abat               logi           Sim/NÆo
contrib-icms                logi           Sim/NÆo
e-mail                      char           x(40)
home-page                   char           x(40)
ind-licenciador             logi           Sim/NÆo
endereco2                   char           x(40)
ind-aval-embarque           inte           9
ind-abrange-aval            inte           >9
cod-tax                     inte           >>9
cn-codigo                   char           x(20)
cod-entrega                 char           x(12)
cod-isencao                 inte           >>9
dias-comp                   inte           >>9
estoque                     inte           9
flag-pag                    inte           9
item-cli                    logi           Sim/NÆo
moeda-libcre                inte           >9
nr-dias-atraso              inte           9999
valor-minimo                deci-2         >>,>>>,>>>,>>9.99
cod-parceiro-edi            inte           >>>>>>>>9
agente-retencao             logi           Sim/NÆo
percepcao                   logi           Sim/NÆo
char-1                      char           x(2000)
char-2                      char           x(100)
dec-1                       deci-8         ->>>>>>>>>>>9.99999999
dec-2                       deci-8         ->>>>>>>>>>>9.99999999
int-1                       inte           ->>>>>>>>>9
int-2                       inte           ->>>>>>>>>9
log-1                       logi           Sim/NÆo
log-2                       logi           Sim/NÆo
data-1                      date           99/99/9999
data-2                      date           99/99/9999
cod-canal-venda             inte           >>9
ind-sit-emitente            inte           >9
ind-emit-retencao           inte           >9
calcula-multa               logi       m   Sim/NÆo
prog-emit                   logi       i   Sim/NÆo
nr-tab-progr                inte           >>9
recebe-inf-sci              logi           Sim/NÆo
cod-classif-fornec          inte           >9
cod-classif-cliente         inte           >9
nr-cheque-devol             inte           >>9
periodo-devol               inte           >,>>9
vl-max-devol                deci-2         >>>,>>>,>>9.99
check-sum                   char           x(20)
val-quota-media             deci-4         >>>,>>>,>>9.9999
cod-repres-imp              inte           >>>>>>>>9
vencto-dia-nao-util         logi       m   Sim/NÆo
rend-tribut                 deci-2         >>9.99
utiliza-verba               logi       m   Sim/NÆo
percent-verba               deci-2     m   >>>9.99
endereco_text               char           X(2000)
endereco-cob-text           char           X(2000)
short-name                  char       i   x(16)
log-controla-val-max-inss   logi           Sim/NÆo
cod-inscr-inss              char           x(20)
cod-pulmao                  char           X(5)
idi-tributac-cofins         inte       m   9
idi-tributac-pis            inte       m   9
log-calcula-pis-cofins-unid logi       m   Sim/NÆo
log-optan-suspens-ipi       logi       m   Sim/NÆo
log-optan-cr-presmdo-subst  logi       m   Sim/NÆo
retem-pagto                 logi       m   Sim/NÆo
portador-ap                 inte       m   >>>>9
modalidade-ap               inte       m   9
log-contribt-subst-interm   logi       m   Sim/NÆo
dat-valid-suframa           date           99/99/9999
nom-fantasia                char           x(60)
log-possui-nf-eletro        logi       m   Sim/NÆo
log-nf-eletro               logi           Sim/NÆo
dt-atualiza                 date       i   99/99/9999
hra-atualiz                 char       i   99:99:99
cod-email-nfe               char           x(500)
log-integr-totvs-colab-vend logi           Sim/NÆo
cdn-atraso-max              inte           >>>9
dat-nasc                    date           99/99/9999
log-beneficiario            logi           Sim/NÆo


*/

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE gera-complemento-estab wMaintenance 
PROCEDURE gera-complemento-estab :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    FIND FIRST estabelec NO-LOCK
        WHERE estabelec.cod-estabel = c-estab-copia NO-ERROR.

    IF AVAIL estabelec THEN DO:

        ASSIGN tt-estabelec.cod-cta-icms-presmdo            = estabelec.cod-cta-icms-presmdo        
               tt-estabelec.idi-tributac-cofins             = estabelec.idi-tributac-cofins         
               tt-estabelec.cod-cta-cofins-recup            = estabelec.cod-cta-cofins-recup        
               tt-estabelec.cod-cta-pis-recup               = estabelec.cod-cta-pis-recup           
               tt-estabelec.cod-cta-pis-ativ-recup          = estabelec.cod-cta-pis-ativ-recup      
               tt-estabelec.cod-cta-cofins-ativ-recup       = estabelec.cod-cta-cofins-ativ-recup   
               tt-estabelec.cod-cta-icms-ativ-recup         = estabelec.cod-cta-icms-ativ-recup     
               tt-estabelec.cod-cta-transit-icms-anteci     = estabelec.cod-cta-transit-icms-anteci 
               tt-estabelec.cod-cta-icms-antecip            = estabelec.cod-cta-icms-antecip        
               tt-estabelec.cod-cta-icms-entreg-fut         = estabelec.cod-cta-icms-entreg-fut     
               tt-estabelec.cod-ccusto-icms-entreg-fut      = estabelec.cod-ccusto-icms-entreg-fut  
               tt-estabelec.cod-cta-transit-icms-antec      = estabelec.cod-cta-transit-icms-antec  
               tt-estabelec.cod-ccusto-transit-icms-ant     = estabelec.cod-ccusto-transit-icms-ant 
               tt-estabelec.cod-cta-cofins-substto-unif     = estabelec.cod-cta-cofins-substto-unif 
               tt-estabelec.cod-cta-pis-substto-unif        = estabelec.cod-cta-pis-substto-unif    
               tt-estabelec.cod-cta-cofins-recup-unif       = estabelec.cod-cta-cofins-recup-unif   
               tt-estabelec.cod-cta-pis-recup-unif          = estabelec.cod-cta-pis-recup-unif      
               tt-estabelec.cod-cta-icms-antecip-unif       = estabelec.cod-cta-icms-antecip-unif   
               tt-estabelec.cod-ccusto-icms-antecip-uni     = estabelec.cod-ccusto-icms-antecip-uni
               tt-estabelec.cod-ccusto-cofins-recup         = estabelec.cod-ccusto-cofins-recup    
               tt-estabelec.cod-ccusto-icms-presmdo         = estabelec.cod-ccusto-icms-presmdo    
               tt-estabelec.cod-ccusto-pis-recup            = estabelec.cod-ccusto-pis-recup       
               tt-estabelec.cod-ccusto-pis-substto          = estabelec.cod-ccusto-pis-substto     
               tt-estabelec.cod-ccusto-icms-ativ-recup      = estabelec.cod-ccusto-icms-ativ-recup 
               tt-estabelec.cod-ccusto-pis-ativ-recup       = estabelec.cod-ccusto-pis-ativ-recup  
               tt-estabelec.cod-ccusto-cofins-ativ-recu     = estabelec.cod-ccusto-cofins-ativ-recu
               tt-estabelec.cod-cta-despes-iss              = estabelec.cod-cta-despes-iss         
               tt-estabelec.cod-ccusto-despes-iss           = estabelec.cod-ccusto-despes-iss      
               tt-estabelec.cod-cta-icms-ret                = estabelec.cod-cta-icms-ret           
               tt-estabelec.cod-ccusto-icms-ret             = estabelec.cod-ccusto-icms-ret        
               tt-estabelec.cod-cta-inss-recolh             = estabelec.cod-cta-inss-recolh        
               tt-estabelec.cod-ccusto-inss-recolh          = estabelec.cod-ccusto-inss-recolh     
               tt-estabelec.cod-cta-despes-icms-sub         = estabelec.cod-cta-despes-icms-sub    
               tt-estabelec.cod-ccusto-despes-icms-sub      = estabelec.cod-ccusto-despes-icms-sub 
               tt-estabelec.cod-cta-despes-ipi              = estabelec.cod-cta-despes-ipi         
               tt-estabelec.cod-subconta-despes-ipi         = estabelec.cod-subconta-despes-ipi    
               tt-estabelec.cod-cta-despes-icms             = estabelec.cod-cta-despes-icms        
               tt-estabelec.cod-subconta-despes-icms        = estabelec.cod-subconta-despes-icms   
               tt-estabelec.cod-cta-ipi-entreg-fut          = estabelec.cod-cta-ipi-entreg-fut     
               tt-estabelec.cod-ccusto-ipi-entreg-fut       = estabelec.cod-ccusto-ipi-entreg-fut  
               tt-estabelec.cod-ccusto-cofins-substto       = estabelec.cod-ccusto-cofins-substto  
               tt-estabelec.cod-cta-pis-entreg-fut          = estabelec.cod-cta-pis-entreg-fut      
               tt-estabelec.cod-ccusto-pis-entreg-fut       = estabelec.cod-ccusto-pis-entreg-fut   
               tt-estabelec.cod-cta-cofins-entreg-fut       = estabelec.cod-cta-cofins-entreg-fut   
               tt-estabelec.cod-ccusto-cofins-entreg-fu     = estabelec.cod-ccusto-cofins-entreg-fu 
               tt-estabelec.cod-cta-ctbl-jurosavc           = estabelec.cod-cta-ctbl-jurosavc       
               tt-estabelec.cod-cta-ctbl-icms-presmdo       = estabelec.cod-cta-ctbl-icms-presmdo   
               tt-estabelec.cod-cta-ctbl-pis-ativ-recup     = estabelec.cod-cta-ctbl-pis-ativ-recup 
               tt-estabelec.cod-cta-ctbl-icms-ativ-recu     = estabelec.cod-cta-ctbl-icms-ativ-recu 
               tt-estabelec.cod-cta-ctbl-cofins-ativ-re     = estabelec.cod-cta-ctbl-cofins-ativ-re 
               tt-estabelec.cod-cta-ctbl-despes-iss-uni     = estabelec.cod-cta-ctbl-despes-iss-uni 
               tt-estabelec.cod-cta-ctbl-despes-icms-su     = estabelec.cod-cta-ctbl-despes-icms-su 
               tt-estabelec.cod-cta-ctbl-despes-ipi-uni     = estabelec.cod-cta-ctbl-despes-ipi-uni .


    END.

        /*
        
        
        
        
        
        */



    FIND FIRST estab-compl EXCLUSIVE-LOCK
        WHERE estab-compl.cod-estabel = tt-estabelec.cod-estabel:SCREEN-VALUE IN FRAME fpage0 NO-ERROR.

    IF NOT AVAIL estab-compl THEN DO:
        CREATE estab-compl.
        ASSIGN estab-compl.cod-estabel = tt-estabelec.cod-estabel:SCREEN-VALUE IN FRAME fpage0 NO-ERROR.

    END.
    ASSIGN estab-compl.nom-fantasia = c-nome-fantasia:SCREEN-VALUE IN FRAME fpage1. 

    RELEASE estab-compl.

    FIND FIRST cst_estabelec EXCLUSIVE-LOCK
        WHERE cst_estabelec.cod_estabel = tt-estabelec.cod-estabel:SCREEN-VALUE IN FRAME fpage0 NO-ERROR.

    IF NOT AVAIL cst_estabelec THEN DO:
        CREATE cst_estabelec.
        ASSIGN cst_estabelec.cod_estabel = tt-estabelec.cod-estabel:SCREEN-VALUE IN FRAME fpage0.

    END.
    ASSIGN cst_estabelec.dt_fim_operacao    = 12/31/9999     
           cst_estabelec.sistema            = NO
           cst_estabelec.dt_inicio_oper     = TODAY
           cst_estabelec.dt_alter           = TODAY
           cst_estabelec.cod_usuario        = "RPW" 
           cst_estabelec.cod_adquirente     = 125 
           cst_estabelec.cod_portador_db    = 90102 
           cst_estabelec.cod_portador_cr    = 90101.

    RELEASE cst_estabelec.

    FOR EACH bfparam-gener
       WHERE bfparam-gener.cod-chave-1 = "param-comunic" 
         AND bfparam-gener.cod-chave-2 = c-estab-copia :

        FIND FIRST param-gener EXCLUSIVE-LOCK
            WHERE param-gener.cod-chave-1 = "param-comunic" 
              AND param-gener.cod-chave-2 = tt-estabelec.cod-estabel:SCREEN-VALUE IN FRAME fpage0 
              AND param-gener.cod-param   = bfparam-gener.cod-param NO-ERROR.

        IF NOT AVAIL param-gener THEN DO:

            CREATE param-gener.
            BUFFER-COPY bfparam-gener EXCEPT cod-chave-2 TO param-gener.
            ASSIGN param-gener.cod-chave-2 = tt-estabelec.cod-estabel:SCREEN-VALUE IN FRAME fpage0.

        END.

    END.

    RELEASE param-gener.


    FOR EACH bfconta-ft
       WHERE bfconta-ft.cod-estabel = c-estab-copia :

        FIND FIRST conta-ft NO-LOCK
            WHERE conta-ft.cod-estabel = tt-estabelec.cod-estabel:SCREEN-VALUE IN FRAME fpage0 
              AND conta-ft.nat-operacao = bfconta-ft.nat-operacao NO-ERROR.

        IF NOT AVAIL conta-ft THEN DO:

            CREATE conta-ft.
            BUFFER-COPY bfconta-ft EXCEPT cod-estabel TO conta-ft.
            ASSIGN conta-ft.cod-estabel             = tt-estabelec.cod-estabel:SCREEN-VALUE IN FRAME fpage0 
                   conta-ft.cod-ccusto-devol-produc = STRING(INT(tt-estabelec.cod-estabel:SCREEN-VALUE IN FRAME fpage0), "99999")
                   conta-ft.sc-cusven               = STRING(INT(tt-estabelec.cod-estabel:SCREEN-VALUE IN FRAME fpage0), "99999").
        END.

    END.

    RELEASE conta-ft.



    FIND FIRST reg-inf-compl NO-LOCK
        WHERE reg-inf-compl.cod-tab-inform   = "CONTA-CONTAB-CD0403":U
          AND reg-inf-compl.cod-campo-inform = "CONTA-CONTAB-CD0403":U NO-ERROR.
    
    IF AVAIL reg-inf-compl THEN DO:

        FIND FIRST bfinf-compl NO-LOCK
            WHERE bfinf-compl.cdn-identif = reg-inf-compl.cdn-identif /*18*/
              AND bfinf-compl.cod-indice  = c-estab-copia
              AND bfinf-compl.num-campo   = 0 NO-ERROR.

        IF AVAIL  bfinf-compl THEN DO:

            FIND FIRST inf-compl NO-LOCK
                WHERE inf-compl.cdn-identif = reg-inf-compl.cdn-identif /*18*/
                  AND inf-compl.cod-indice  = tt-estabelec.cod-estabel:SCREEN-VALUE IN FRAME fpage0
                  AND inf-compl.num-campo   = 0 NO-ERROR.

            IF NOT AVAIL inf-compl THEN DO:

                CREATE inf-compl.
                BUFFER-COPY bfinf-compl EXCEPT cod-indice TO inf-compl.
                ASSIGN inf-compl.cod-indice  = tt-estabelec.cod-estabel:SCREEN-VALUE IN FRAME fpage0.

            END.


        END.

        FIND FIRST bfinf-compl NO-LOCK
            WHERE bfinf-compl.cdn-identif = reg-inf-compl.cdn-identif /*18*/
              AND bfinf-compl.cod-indice  = c-estab-copia
              AND bfinf-compl.num-campo   = 1 NO-ERROR.

        IF AVAIL  bfinf-compl THEN DO:

            FIND FIRST inf-compl NO-LOCK
                WHERE inf-compl.cdn-identif = reg-inf-compl.cdn-identif /*18*/
                  AND inf-compl.cod-indice  = tt-estabelec.cod-estabel:SCREEN-VALUE IN FRAME fpage0
                  AND inf-compl.num-campo   = 1 NO-ERROR.

            IF NOT AVAIL inf-compl THEN DO:

                CREATE inf-compl.
                BUFFER-COPY bfinf-compl EXCEPT cod-indice TO inf-compl.
                ASSIGN inf-compl.cod-indice  = tt-estabelec.cod-estabel:SCREEN-VALUE IN FRAME fpage0.

            END.


        END.



    END.

END PROCEDURE.

/*


Table: conta-ft

Field Name                  Data Type  Flg Format
--------------------------- ---------- --- --------------------------------
cod-estabel                 char       i   x(5)
cod-gr-cli                  inte       i   >>>9
fm-codigo                   char       i   x(8)
ct-recven                   char           x(20)
sc-recven                   char       m   x(20)
ct-cusven                   char           x(20)
sc-cusven                   char       m   x(20)
ct-icms-ft                  char           x(20)
sc-icms-ft                  char           x(20)
ct-ipi-ft                   char           x(20)
sc-ipi-ft                   char           x(20)
ct-iss-ft                   char           x(20)
sc-iss-ft                   char       m   x(20)
ct-ir-ret                   char           x(20)
sc-ir-ret                   char           x(20)
ct-icmsub-ft                char           x(20)
sc-icmsub-ft                char       m   x(20)
sc-cofins-ft                char       m   x(20)
ct-cofins-ft                char           x(20)
ct-pis-ft                   char           x(20)
sc-pis-ft                   char       m   x(20)
nat-operacao                char       i   x(06)
serie                       char       i   x(5)
fm-com                      char       i   x(8)
no-ab-repre                 char           x(12)
ct-despesa                  char       m   x(17)
ge-codigo                   inte       i   >9
ct-frete-ft                 char           x(17)
ct-diversos-ft              char           x(17)
char-1                      char           x(100)
char-2                      char           x(100)
dec-1                       deci-8         ->>>>>>>>>>>9.99999999
dec-2                       deci-8         ->>>>>>>>>>>9.99999999
int-1                       inte           ->>>>>>>>>9
int-2                       inte           ->>>>>>>>>9
log-1                       logi           Sim/NÆo
log-2                       logi           Sim/NÆo
data-1                      date           99/99/9999
data-2                      date           99/99/9999
cod-depos                   char       i   x(03)
cod-canal-venda             inte       i   >>9
it-codigo                   char       i   x(16)
check-sum                   char           x(20)
conta-dev-cpv               char       m   x(17)
conta-dev-rec               char       m   x(17)
Ct-desp-fretes              char           x(20)
Sc-desp-fretes              char           x(20)
cod-dev-prod                char           x(17)
cod-ct-inss                 char           x(17)
cod-ct-pis                  char           x(17)
cod-ct-cofins               char           x(17)
cod-livre-1                 char           x(100)
cod-livre-2                 char           x(100)
log-livre-1                 logi           Sim/NÆo
log-livre-2                 logi           Sim/NÆo
log-livre-3                 logi           Sim/NÆo
log-livre-4                 logi           Sim/NÆo
log-livre-5                 logi           Sim/NÆo
log-livre-6                 logi           Sim/NÆo
num-livre-1                 inte           ->>>>>>>>9
num-livre-2                 inte           ->>>>>>>>9
val-livre-1                 deci-8         ->>>>>>>>>>>9.99999999
val-livre-2                 deci-8         ->>>>>>>>>>>9.99999999
dat-livre-1                 date           99/99/9999
dat-livre-2                 date           99/99/9999
cod-cta-retenc-csll         char           x(20)
cod-cta-retenc-pis          char           x(20)
cod-cta-retenc-cofins       char           x(20)
cod-cta-recta-export-nao-em char           x(20)
cod-ccusto-recta-export-nao char           x(20)
cod-ccusto-retenc-cofins    char           x(20)
cod-ccusto-retenc-csll      char           x(20)
cod-ccusto-retenc-pis       char           x(20)
cod-cta-devol-cpv           char           x(20)
cod-ccusto-devol-cpv        char           x(20)
cod-cta-devol-recta         char           x(20)
cod-ccusto-devol-recta      char           x(20)
cod-cta-desc                char           x(20)
cod-ccusto-desc             char           x(20)
cod-cta-diver               char           x(20)
cod-ccusto-diver            char           x(20)
cod-cta-frete               char           x(20)
cod-ccusto-frete            char           x(20)
cod-cta-irrf                char           x(17)
cod-cta-despes-iss          char           x(17)
cod-cta-devol-produc        char           x(20)
cod-ccusto-devol-produc     char           x(20)
cod-cta-inss-retid          char           x(20)
cod-ccusto-inss-retid       char           x(20)
cod-cta-pis                 char           x(20)
cod-ccusto-pis              char           x(20)
cod-cta-cofins              char           x(20)
cod-ccusto-cofins           char           x(20)
cod-cta-retenc-iss          char           x(20)
cod-ccusto-retenc-iss       char           x(20)
cod-cta-despes-icms-sub     char           x(17)
cod-cta-cust-produt-vendido char           x(17)
cod-cta-despes-recta-vda    char           x(17)
cod-cta-ctbl-despes-icms    char           x(17)
cod-cta-ctbl-despes-ipi     char           x(17)
cod-cta-ctbl-despes-frete   char           x(17)
cod-cta-ctbl-retenc-csll    char           x(17)
cod-cta-ctbl-retenc-pis     char           x(17)
cod-cta-ctbl-retenc-cofins  char           x(17)
cod-cta-ctbl-recta-export-n char           x(17)
cod-cta-ctbl-retenc-iss     char           x(17)
cod-cta-ctbl-despes-pis-sub char           x(17)
cod-cta-ctbl-despes-cofins- char           x(17)
cod-cta-depos-fechado       char           x(20)
cod-ccusto-depos-fechado    char           x(20)
cod-cta-armazem             char           x(20)
cod-ccusto-armazem          char           x(20)
cod-cta-despes-iva          char           x(20)
cod-subconta-despes-iva     char           x(20)


*/

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE gera-contas-contabilizacao wMaintenance 
PROCEDURE gera-contas-contabilizacao :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    FOR EACH bfcontabiliza
        WHERE bfcontabiliza.cod-estabel = c-estab-copia :

        FIND FIRST contabiliza EXCLUSIVE-LOCK
            WHERE contabiliza.ge-codigo     = bfcontabiliza.ge-codigo
              AND contabiliza.cod-depos     = bfcontabiliza.cod-depos
              AND contabiliza.cod-estabel   = tt-estabelec.cod-estabel:SCREEN-VALUE IN FRAME fpage0 NO-ERROR.

        IF NOT AVAIL contabiliza THEN DO:

            CREATE contabiliza.
            BUFFER-COPY bfcontabiliza EXCEPT cod-estabel TO contabiliza.
            ASSIGN contabiliza.cod-estabel   = tt-estabelec.cod-estabel:SCREEN-VALUE IN FRAME fpage0.

        END.

    END.

    RELEASE contabiliza.

END PROCEDURE.


/*


Table: contabiliza

Field Name                  Data Type  Flg Format
--------------------------- ---------- --- --------------------------------
ge-codigo                   inte       im  99
cod-depos                   char       im  x(3)
cod-estabel                 char       im  x(5)
ct-codigo                   char       m   x(20)
sc-codigo                   char       m   x(20)
valor-cont                  deci-2     m   ->>>,>>>,>>>,>>9.99
saldo-ini                   deci-2     m   ->>>,>>>,>>>,>>9.99
vl-cont-fasb                deci-2[2]  m   ->>>,>>>,>>>,>>9.99
sl-ini-fasb                 deci-2[2]  m   ->>>,>>>,>>>,>>9.99
ct-var-saldo                char       m   x(20)
sc-var-saldo                char       m   x(20)
ct-var-movto                char       m   x(20)
sc-var-movto                char       m   x(20)
conta-contabil              char           x(17)
conta-var-saldo             char           x(17)
conta-movto                 char           x(17)
char-1                      char           x(100)
char-2                      char           x(100)
dec-1                       deci-8         ->>>>>>>>>>>9.99999999
dec-2                       deci-8         ->>>>>>>>>>>9.99999999
int-1                       inte           ->>>>>>>>>9
int-2                       inte           ->>>>>>>>>9
log-1                       logi           Sim/NÆo
log-2                       logi           Sim/NÆo
data-1                      date           99/99/9999
data-2                      date           99/99/9999
check-sum                   char           x(20)


*/

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE gera-estab-ems5 wMaintenance 
PROCEDURE gera-estab-ems5 :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    FIND FIRST estabelecimento EXCLUSIVE-LOCK
        WHERE estabelecimento.cod_estab = tt-estabelec.cod-estabel:SCREEN-VALUE IN FRAME fpage0 NO-ERROR.
    
    IF NOT AVAIL estabelecimento THEN DO:
    
        FIND FIRST bfestabelecimento NO-LOCK
            WHERE bfestabelecimento.cod_estab = c-estab-copia NO-ERROR.


        IF AVAIL bfestabelecimento THEN DO:
      
            CREATE estabelecimento.
            BUFFER-COPY bfestabelecimento EXCEPT cod_estab cdn_estab nom_abrev cod_id_feder num_pessoa_jurid TO estabelecimento.
    
            ASSIGN estabelecimento.cod_estab        = tt-estabelec.cod-estabel:SCREEN-VALUE IN FRAME fpage0
                   estabelecimento.cdn_estab        = int(tt-estabelec.cod-estabel:SCREEN-VALUE IN FRAME fpage0)
                   estabelecimento.num_pessoa_jurid = int(c-cod-pessoa-jur:SCREEN-VALUE IN FRAME fpage1)
                   estabelecimento.nom_pessoa       = c-nome-pessoa:SCREEN-VALUE IN FRAME fpage1
                   estabelecimento.cod_id_feder     = tt-estabelec.cgc:SCREEN-VALUE IN FRAME fpage1
                   estabelecimento.nom_abrev        = "NISSEI " + tt-estabelec.cod-estabel:SCREEN-VALUE IN FRAME fpage0.
        
        END.
    
        FIND FIRST bfestab_unid_negoc NO-LOCK
            WHERE bfestab_unid_negoc.cod_estab = c-estab-copia NO-ERROR.
    
        FIND FIRST estab_unid_negoc NO-LOCK
            WHERE estab_unid_negoc.cod_estab = tt-estabelec.cod-estabel:SCREEN-VALUE IN FRAME fpage0 NO-ERROR.

        IF NOT AVAIL estab_unid_negoc THEN DO:
              
            CREATE estab_unid_negoc.
            BUFFER-COPY bfestab_unid_negoc EXCEPT cod_estab TO estab_unid_negoc.
            ASSIGN estab_unid_negoc.cod_estab = tt-estabelec.cod-estabel:SCREEN-VALUE IN FRAME fpage0.
        
        
        END.
    
    END.
    ELSE DO:

        ASSIGN estabelecimento.cod_id_feder     = tt-estabelec.cgc:SCREEN-VALUE IN FRAME fpage1.

    END.

    RELEASE estabelecimento.


END PROCEDURE.

/*


Table: estabelecimento

Field Name                  Data Type  Flg Format
--------------------------- ---------- --- --------------------------------
cod_estab                   char       im  x(5)
nom_pessoa                  char       m   x(40)
cdn_estab                   inte       im  >>9
cod_empresa                 char       im  x(3)
nom_abrev                   char       im  x(15)
num_pessoa_jurid            inte       im  >>>,>>>,>>9
log_estab_princ             logi       m   Sim/NÆo
cod_pais                    char       im  x(3)
cod_id_feder                char       im  x(20)
cod_id_previd_social        char       im  x(20)
des_anot_tab                char       m   x(2000)
cod_calend_financ           char       im  x(8)
cod_calend_mater            char       im  x(8)
cod_calend_rh               char       im  x(8)
cod_calend_manuf            char       im  x(8)
cod_calend_distrib          char       im  x(8)
cod_livre_1                 char           x(100)
log_livre_1                 logi           Sim/NÆo
num_livre_1                 inte           >>>>>9
val_livre_1                 deci-4         >>>,>>>,>>9.9999
dat_livre_1                 date           99/99/9999
cod_livre_2                 char           x(100)
dat_livre_2                 date           99/99/9999
log_livre_2                 logi           Sim/NÆo
num_livre_2                 inte           >>>>>9
val_livre_2                 deci-4         >>>,>>>,>>9.9999
cdd_version                 deci-0         >>>,>>>,>>>,>>9
cod_lotac                   char           x(30)


*/

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE gera-estab-material wMaintenance 
PROCEDURE gera-estab-material :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/


    FIND FIRST bfestab-mat NO-LOCK
        WHERE bfestab-mat.cod-estabel = c-estab-copia NO-ERROR.

    IF AVAIL bfestab-mat THEN DO:

        FIND FIRST estab-mat NO-LOCK
            WHERE estab-mat.cod-estabel = tt-estabelec.cod-estabel:SCREEN-VALUE IN FRAME fpage0 NO-ERROR.

        IF NOT AVAIL estab-mat THEN DO:

            CREATE estab-mat.
            BUFFER-COPY bfestab-mat EXCEPT cod-estabel cod-estabel-prin TO estab-mat.
            ASSIGN estab-mat.cod-estabel        = tt-estabelec.cod-estabel:SCREEN-VALUE IN FRAME fpage0
                   estab-mat.cod-estabel-prin   = tt-estabelec.cod-estabel:SCREEN-VALUE IN FRAME fpage0.

        END.
        RELEASE estab-mat.


    END.





END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE gera-localizacao wMaintenance 
PROCEDURE gera-localizacao :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    FIND FIRST ems2log.localizacao EXCLUSIVE-LOCK
        WHERE localizacao.cod-estabel = tt-estabelec.cod-estabel:SCREEN-VALUE IN FRAME fpage0 NO-ERROR.

    IF NOT AVAIL localizacao THEN DO:
        CREATE localizacao.
        ASSIGN localizacao.cod-localiz = ""
               localizacao.descricao   = "BRANCO"  
               localizacao.cod-estabel = tt-estabelec.cod-estabel:SCREEN-VALUE IN FRAME fpage0 
               localizacao.cod-depos   = "LOJ".

    END.

    RELEASE localizacao.


    FIND FIRST centro-custo NO-LOCK
        WHERE centro-custo.cc-codigo = STRING(int(tt-estabelec.cod-estabel:SCREEN-VALUE IN FRAME fpage0), "99999") NO-ERROR.

    IF NOT AVAIL centro-custo THEN DO:

        CREATE centro-custo.
        ASSIGN centro-custo.cc-codigo   = STRING(int(tt-estabelec.cod-estabel:SCREEN-VALUE IN FRAME fpage0), "99999")
               centro-custo.cod-estabel = tt-estabelec.cod-estabel:SCREEN-VALUE IN FRAME fpage0
               centro-custo.descricao   = c-nome-fantasia:SCREEN-VALUE IN FRAME fpage1.
                           

    END.
    RELEASE centro-custo.




END PROCEDURE.



/*

Table: localizacao

Field Name                  Data Type  Flg Format
--------------------------- ---------- --- --------------------------------
cod-localiz                 char       im  x(20)
descricao                   char       im  x(30)
cod-estabel                 char       im  x(5)
cod-depos                   char       im  x(3)
char-1                      char           x(100)
char-2                      char           x(100)
dec-1                       deci-8         ->>>>>>>>>>>9.99999999
dec-2                       deci-8         ->>>>>>>>>>>9.99999999
int-1                       inte           ->>>>>>>>>9
int-2                       inte           ->>>>>>>>>9
log-1                       logi           Sim/NÆo
log-2                       logi           Sim/NÆo
data-1                      date           99/99/9999
data-2                      date           99/99/9999
check-sum                   char           x(20)



*/

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE gera-mla wMaintenance 
PROCEDURE gera-mla :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    FIND FIRST mla-lotacao NO-LOCK
        WHERE mla-lotacao.cod-lotacao   = STRING(int(tt-estabelec.cod-estabel:SCREEN-VALUE IN FRAME fpage0), "99999") 
          AND mla-lotacao.ep-codigo     = "1"  NO-ERROR.

    IF NOT AVAIL mla-lotacao THEN DO:
    
        CREATE mla-lotacao.
        ASSIGN mla-lotacao.ep-codigo    = "1"
               mla-lotacao.cod-lotacao = STRING(int(tt-estabelec.cod-estabel:SCREEN-VALUE IN FRAME fpage0), "99999") 
               mla-lotacao.desc-lotacao = c-nome-fantasia:SCREEN-VALUE IN FRAME fpage1.

    END.
    RELEASE mla-lotacao.

    FOR EACH bfmla-perm-lotacao NO-LOCK
        WHERE bfmla-perm-lotacao.cod-lotacao = STRING(int(c-estab-copia), "99999"):

        FIND FIRST mla-perm-lotacao NO-LOCK
            WHERE mla-perm-lotacao.cod-lotacao = STRING(int(tt-estabelec.cod-estabel:SCREEN-VALUE IN FRAME fpage0), "99999") 
              AND mla-perm-lotacao.cod-usuar   = bfmla-perm-lotacao.cod-usuar NO-ERROR.

        IF NOT AVAIL mla-perm-lotacao THEN DO:

            CREATE mla-perm-lotacao.
            BUFFER-COPY bfmla-perm-lotacao EXCEPT cod-lotacao TO mla-perm-lotacao.
            ASSIGN mla-perm-lotacao.cod-lotacao = STRING(int(tt-estabelec.cod-estabel:SCREEN-VALUE IN FRAME fpage0), "99999") .

        END.



    END.

    RELEASE mla-perm-lotacao.


    FIND FIRST bfmla-param-aprov NO-LOCK
        WHERE bfmla-param-aprov.cod-estabel = c-estab-copia NO-ERROR.

    IF AVAIL bfmla-param-aprov THEN DO:

        FIND FIRST mla-param-aprov NO-LOCK
            WHERE mla-param-aprov.cod-estabel = tt-estabelec.cod-estabel:SCREEN-VALUE IN FRAME fpage0 NO-ERROR.

        IF NOT AVAIL mla-param-aprov THEN DO:

            CREATE mla-param-aprov.
            BUFFER-COPY bfmla-param-aprov EXCEPT cod-estabel TO mla-param-aprov.
            ASSIGN mla-param-aprov.cod-estabel = tt-estabelec.cod-estabel:SCREEN-VALUE IN FRAME fpage0.
        END.


    END.

    RELEASE mla-param-aprov.



    FOR EACH bfmla-tipo-doc-aprov NO-LOCK
        WHERE bfmla-tipo-doc-aprov.ep-codigo    = "1"
          AND bfmla-tipo-doc-aprov.cod-estabel  = c-estab-copia:

        FIND FIRST mla-tipo-doc-aprov NO-LOCK
            WHERE mla-tipo-doc-aprov.ep-codigo    = bfmla-tipo-doc-aprov.ep-codigo
              AND mla-tipo-doc-aprov.cod-tip-doc  = bfmla-tipo-doc-aprov.cod-tip-doc
              AND mla-tipo-doc-aprov.cod-estabel  = STRING(tt-estabelec.cod-estabel:SCREEN-VALUE IN FRAME fpage0, "99999") NO-ERROR.

        IF NOT AVAIL mla-tipo-doc-aprov THEN DO:

            CREATE mla-tipo-doc-aprov.
            BUFFER-COPY bfmla-tipo-doc-aprov EXCEPT cod-estabel TO mla-tipo-doc-aprov.
            ASSIGN mla-tipo-doc-aprov.cod-estabel  = STRING(tt-estabelec.cod-estabel:SCREEN-VALUE IN FRAME fpage0, "99999") .

        END.

    END.

    RELEASE mla-tipo-doc-aprov.



END PROCEDURE.


/*


Table: mla-tipo-doc-aprov

Field Name                  Data Type  Flg Format
--------------------------- ---------- --- --------------------------------
cod-tip-doc                 inte       im  >>9
des-tip-doc                 char       i   X(40)
apr-tip-doc                 logi           Sim/NÆo
prioridade-aprov            inte           9
prog-consulta               char           X(40)
prog-aprova                 char           X(40)
prog-rejeita                char           X(40)
verba-aprov                 logi           Sim/NÆo
char-1                      char           x(100)
char-2                      char           x(100)
dec-1                       deci-8         ->>>>>>>>>>>9.99999999
dec-2                       deci-8         ->>>>>>>>>>>9.99999999
int-1                       inte           >>>>>>>>>9
int-2                       inte           >>>>>>>>>9
log-1                       logi           Sim/NÆo
log-2                       logi           Sim/NÆo
data-1                      date           99/99/9999
data-2                      date           99/99/9999
char-3                      char           x(100)
char-4                      char           x(100)
char-5                      char       i   x(100)
dec-3                       deci-8         ->>>>>>>>>>>9.99999999
dec-4                       deci-8         ->>>>>>>>>>>9.99999999
dec-5                       deci-8         ->>>>>>>>>>>9.99999999
int-3                       inte           >>>>>>>>>9
int-4                       inte           >>>>>>>>>9
int-5                       inte       i   >>>>>>>>>9
log-3                       logi           Sim/NÆo
log-4                       logi           yes/no
log-5                       logi           yes/no
data-3                      date           99/99/9999
data-4                      date           99/99/9999
data-5                      date       i   99/99/9999
ep-codigo                   char       im  x(3)
cod-estabel                 char       im  x(5)
log-html                    logi           yes/no
log-excec-val               logi           Sim/NÆo
log-integr-fluig            logi           Sim/NÆo
cod-proces                  char           x(20)
log-praz-conclus            logi           Sim/NÆo
hra-execucao                char           x(6)
hra-exec-priorid-media      char           x(6)
hra-exec-priorid-alta       char           x(6)
hra-exec-priorid-altssmo    char           x(6)
hra-exec-priorid-baixa      char           x(6)
idi-tip-val-pendcia         inte           >9


---------------------------
Informacao
---------------------------
DBName: ems2log 
Table: mla-tipo-doc-aprov 
Name: des-tip-doc 
Type: CHARACTER 
Format: X(40) 
Transaction: no 
Program: invwr/v01in001.w 
Path: \\192.168.200.78\Totvs12\_quarentena_teste\ems2\invwr\v01in001.r
---------------------------
OK   
---------------------------


Table: mla-perm-lotacao

Field Name                  Data Type  Flg Format
--------------------------- ---------- --- --------------------------------
cod-usuar                   char       im  X(12)
validade-ini                date           99/99/9999
validade-fim                date           99/99/9999
cod-lotacao                 char       im  x(20)
char-1                      char           x(100)
char-2                      char           x(100)
dec-1                       deci-8         ->>>>>>>>>>>9.99999999
dec-2                       deci-8         ->>>>>>>>>>>9.99999999
int-1                       inte           >>>>>>>>>9
int-2                       inte           >>>>>>>>>9
log-1                       logi           Sim/NÆo
log-2                       logi           Sim/NÆo
data-1                      date           99/99/9999
data-2                      date           99/99/9999
char-3                      char           x(100)
char-4                      char           x(100)
char-5                      char       i   x(100)
dec-3                       deci-8         ->>>>>>>>>>>9.99999999
dec-4                       deci-8         ->>>>>>>>>>>9.99999999
dec-5                       deci-8         ->>>>>>>>>>>9.99999999
int-3                       inte           >>>>>>>>>9
int-4                       inte           >>>>>>>>>9
int-5                       inte       i   >>>>>>>>>9
log-3                       logi           Sim/NÆo
log-4                       logi           yes/no
log-5                       logi           yes/no
data-3                      date           99/99/9999
data-4                      date           99/99/9999
data-5                      date       i   99/99/9999
ep-codigo                   char       im  x(3)

---------------------------
Informacao
---------------------------
DBName: ems2log 
Table: mla-perm-lotacao 
Name: cod-lotacao 
Type: CHARACTER 
Format: x(20) 
Transaction: no 
Program: invwr/v01in006.w 
Path: \\192.168.200.78\Totvs12\_quarentena_teste\ems2\invwr\v01in006.r
---------------------------
OK   
---------------------------



*/

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE gera-pessoa-juridica wMaintenance 
PROCEDURE gera-pessoa-juridica :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    DEFINE VARIABLE i-num-pessoa-jurid AS INTEGER     NO-UNDO.

    FIND FIRST ems5.fornecedor NO-LOCK
        WHERE fornecedor.cdn_fornecedor = int(tt-estabelec.cod-emitente:SCREEN-VALUE IN FRAME fpage1) NO-ERROR.

    IF AVAIL fornecedor THEN DO:

        FIND FIRST pessoa_jurid EXCLUSIVE-LOCK
            WHERE pessoa_jurid.num_pessoa_jurid = fornecedor.num_pessoa NO-ERROR.

        IF AVAIL pessoa_jurid THEN DO:

             ASSIGN c-cod-pessoa-jur:SCREEN-VALUE IN FRAME fpage1 = string(fornecedor.num_pessoa).

              ASSIGN pessoa_jurid.cod_id_feder          = tt-estabelec.cgc:SCREEN-VALUE IN FRAME fpage1
                     pessoa_jurid.nom_pessoa            = c-nome-pessoa:SCREEN-VALUE IN FRAME fpage1
                     pessoa_jurid.cod_id_estad_jurid    = tt-estabelec.ins-estadual:SCREEN-VALUE IN FRAME fpage1 
                     pessoa_jurid.cod_id_munic_jurid    = tt-estabelec.ins-municipal:SCREEN-VALUE IN FRAME fpage1 
                     pessoa_jurid.nom_endereco          = tt-estabelec.endereco:SCREEN-VALUE IN FRAME fpage1 
                     pessoa_jurid.nom_bairro            = tt-estabelec.bairro:SCREEN-VALUE IN FRAME fpage1
                     pessoa_jurid.nom_cidade            = tt-estabelec.cidade:SCREEN-VALUE IN FRAME fpage1
                     pessoa_jurid.cod_unid_federac      = tt-estabelec.estado:SCREEN-VALUE IN FRAME fpage1 
                     pessoa_jurid.cod_cep               = tt-estabelec.cep:SCREEN-VALUE IN FRAME fpage1 
                     pessoa_jurid.cod_pais              = "BRA" 
                     pessoa_jurid.nom_ender_cobr        = tt-estabelec.endereco:SCREEN-VALUE IN FRAME fpage1 
                     pessoa_jurid.nom_ender_compl_cobr  = tt-estabelec.endereco:SCREEN-VALUE IN FRAME fpage1 
                     pessoa_jurid.nom_bairro_cobr       = tt-estabelec.bairro:SCREEN-VALUE IN FRAME fpage1 
                     pessoa_jurid.nom_cidad_cobr        = tt-estabelec.cidade:SCREEN-VALUE IN FRAME fpage1 
                     pessoa_jurid.cod_cep_pagto         = tt-estabelec.cep:SCREEN-VALUE IN FRAME fpage1 
                     pessoa_jurid.cod_cep_cobr          = tt-estabelec.cep:SCREEN-VALUE IN FRAME fpage1 
                     pessoa_jurid.cod_e_mail            = c-email:SCREEN-VALUE IN FRAME fpage1 
                     pessoa_jurid.cod_telefone          = c-telefone:SCREEN-VALUE IN FRAME fpage1. 
        END.

    END.
    ELSE DO:
    
        FIND LAST bfpessoa_jurid NO-LOCK NO-ERROR.
        IF AVAIL  bfpessoa_jurid THEN
            ASSIGN i-num-pessoa-jurid = bfpessoa_jurid.num_pessoa_jurid + 1.

        FIND FIRST bfpessoa_jurid
            WHERE bfpessoa_jurid.num_pessoa_jurid = 63 NO-ERROR.

        IF AVAIL bfpessoa_jurid THEN DO:

            ASSIGN c-cod-pessoa-jur:SCREEN-VALUE IN FRAME fpage1 = STRING(i-num-pessoa-jurid).


            FIND LAST pessoa_jurid NO-LOCK 
                WHERE pessoa_jurid.cod_id_feder  = tt-estabelec.cgc:SCREEN-VALUE IN FRAME fpage1   NO-ERROR.

            IF AVAIL pessoa_jurid THEN DO:

               // ASSIGN c-cod-pessoa-jur:SCREEN-VALUE IN FRAME fpage1 = string(pessoa_jurid.num_pessoa_jurid).

            END.
            ELSE DO:
            
            
               /* CREATE pessoa_jurid.
                BUFFER-COPY bfpessoa_jurid EXCEPT num_pessoa_jurid TO pessoa_jurid.
                ASSIGN pessoa_jurid.num_pessoa_jurid      = i-num-pessoa-jurid
                       pessoa_jurid.num_pessoa_jurid_matriz = i-num-pessoa-jurid
                       pessoa_jurid.cod_id_feder          = tt-estabelec.cgc:SCREEN-VALUE IN FRAME fpage1
                       pessoa_jurid.nom_pessoa            = c-nome-pessoa:SCREEN-VALUE IN FRAME fpage1
                       pessoa_jurid.cod_id_estad_jurid    = tt-estabelec.ins-estadual:SCREEN-VALUE IN FRAME fpage1 
                       pessoa_jurid.cod_id_munic_jurid    = tt-estabelec.ins-municipal:SCREEN-VALUE IN FRAME fpage1 
                       pessoa_jurid.nom_endereco          = tt-estabelec.endereco:SCREEN-VALUE IN FRAME fpage1 
                       pessoa_jurid.nom_bairro            = tt-estabelec.bairro:SCREEN-VALUE IN FRAME fpage1
                       pessoa_jurid.nom_cidade            = tt-estabelec.cidade:SCREEN-VALUE IN FRAME fpage1
                       pessoa_jurid.cod_unid_federac      = tt-estabelec.estado:SCREEN-VALUE IN FRAME fpage1 
                       pessoa_jurid.cod_cep               = tt-estabelec.cep:SCREEN-VALUE IN FRAME fpage1 
                       pessoa_jurid.cod_pais              = "BRA" 
                       pessoa_jurid.nom_ender_cobr        = tt-estabelec.endereco:SCREEN-VALUE IN FRAME fpage1 
                       pessoa_jurid.nom_ender_compl_cobr  = tt-estabelec.endereco:SCREEN-VALUE IN FRAME fpage1 
                       pessoa_jurid.nom_bairro_cobr       = tt-estabelec.bairro:SCREEN-VALUE IN FRAME fpage1 
                       pessoa_jurid.nom_cidad_cobr        = tt-estabelec.cidade:SCREEN-VALUE IN FRAME fpage1 
                       pessoa_jurid.cod_cep_pagto         = tt-estabelec.cep:SCREEN-VALUE IN FRAME fpage1 
                       pessoa_jurid.cod_cep_cobr          = tt-estabelec.cep:SCREEN-VALUE IN FRAME fpage1 
                       pessoa_jurid.cod_e_mail            = c-email:SCREEN-VALUE IN FRAME fpage1 
                       pessoa_jurid.cod_telefone          = c-telefone:SCREEN-VALUE IN FRAME fpage1.*/

            END.


        END.

    END.


END PROCEDURE.


/*



Table: pessoa_jurid

Field Name                  Data Type  Flg Format
--------------------------- ---------- --- --------------------------------
num_pessoa_jurid            inte       im  >>>,>>>,>>9
nom_pessoa                  char       im  x(40)
cod_id_feder                char       i   x(20)
cod_id_estad_jurid          char       i   x(20)
cod_id_munic_jurid          char           x(20)
cod_id_previd_social        char       i   x(20)
log_fins_lucrat             logi       m   Sim/NÆo
num_pessoa_jurid_matriz     inte       im  >>>,>>>,>>9
nom_endereco                char       m   x(40)
nom_ender_compl             char       m   x(10)
nom_bairro                  char       m   x(20)
nom_cidade                  char       m   x(50)
nom_condado                 char           x(32)
cod_pais                    char       im  x(3)
cod_unid_federac            char       im  x(3)
cod_cep                     char       m   x(20)
cod_cx_post                 char       m   x(20)
cod_telefone                char       m   x(20)
cod_fax                     char       m   x(20)
cod_ramal_fax               char       m   x(07)
cod_telex                   char       m   x(7)
cod_modem                   char       m   x(20)
cod_ramal_modem             char       m   x(07)
cod_e_mail                  char           x(40)
cod_e_mail_cobr             char           x(40)
num_pessoa_jurid_cobr       inte       im  >>>,>>>,>>9
nom_ender_cobr              char       m   x(40)
nom_ender_compl_cobr        char       m   x(10)
nom_bairro_cobr             char       m   x(20)
nom_cidad_cobr              char       m   x(50)
nom_condad_cobr             char       m   x(32)
cod_unid_federac_cobr       char       im  x(3)
cod_pais_cobr               char       im  x(3)
cod_cep_cobr                char       m   x(20)
cod_cx_post_cobr            char       m   x(20)
num_pessoa_jurid_pagto      inte       im  >>>,>>>,>>9
nom_ender_pagto             char       m   x(40)
nom_ender_compl_pagto       char       m   x(10)
nom_bairro_pagto            char       m   x(20)
nom_cidad_pagto             char       m   x(50)
nom_condad_pagto            char       m   x(32)
cod_pais_pagto              char       im  x(3)
cod_unid_federac_pagto      char       im  x(3)
cod_cep_pagto               char       m   x(20)
cod_cx_post_pagto           char       m   x(20)
des_anot_tab                char       m   x(2000)
ind_tip_pessoa_jurid        char       m   X(08)
ind_tip_capit_pessoa_jurid  char       m   X(13)
cod_usuar_ult_atualiz       char       m   x(12)
dat_ult_atualiz             date           99/99/9999
hra_ult_atualiz             char       m   99:99:99
cod_imagem                  char           x(30)
log_ems_20_atlzdo           logi       m   Sim/NÆo
cod_livre_1                 char           x(100)
log_livre_1                 logi           Sim/NÆo
num_livre_1                 inte           >>>>>9
val_livre_1                 deci-4         >>>,>>>,>>9.9999
dat_livre_1                 date           99/99/9999
nom_home_page               char           x(40)
nom_ender_text              char           x(2000)
nom_ender_cobr_text         char           x(2000)
nom_ender_pagto_text        char           x(2000)
log_envio_bco_histor        logi       m   Sim/NÆo
cod_livre_2                 char           x(100)
dat_livre_2                 date           99/99/9999
log_livre_2                 logi           Sim/NÆo
num_livre_2                 inte           >>>>>9
val_livre_2                 deci-4         >>>,>>>,>>9.9999
ind_natur_pessoa_jurid      char           X(20)
nom_fantasia                char           x(60)
cod_sub_regiao_vendas       char           x(12)
cdd_version                 deci-0         >>>,>>>,>>>,>>9
log_replic_pessoa_hcm       logi           Sim/NÆo
log_replic_pessoa_crm       logi           Sim/NÆo
log_replic_pessoa_gps       logi           Sim/NÆo
cod_fax_2                   char           x(10)
cod_ramal_fax_2             char           x(7)
cod_telef_2                 char           x(20)
cod_ramal_2                 char           x(7)
ind_tip_matriz              char           x(20)
log_fund_public_privad      logi           Sim/NÆo
num_forma_tribut            inte           >>>>99
ind_nif                     char           x(40)
cod_num_id_fisc             char           x(30)
num_relac_fonte_pagto       inte           999


*/

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE gera-unid-organ wMaintenance 
PROCEDURE gera-unid-organ :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    
    
    FIND FIRST ems5.unid_organ NO-LOCK
        WHERE unid_organ.cod_unid_organ = tt-estabelec.cod-estabel:SCREEN-VALUE IN FRAME fpage0 NO-ERROR.
    
    IF NOT AVAIL unid_organ  THEN DO:
    
        FIND FIRST bfunid_organ NO-LOCK
            WHERE bfunid_organ.cod_unid_organ = c-estab-copia NO-ERROR.
    
        IF AVAIL bfunid_organ THEN DO:
    
            CREATE unid_organ.
            BUFFER-COPY bfunid_organ EXCEPT cod_unid_organ TO unid_organ.
            ASSIGN unid_organ.cod_unid_organ = tt-estabelec.cod-estabel:SCREEN-VALUE IN FRAME fpage0 
                   unid_organ.des_unid_organ = c-nome-pessoa:SCREEN-VALUE IN FRAME fpage1 .
    
        END.
    END.
    
    FIND FIRST ems5.segur_unid_organ EXCLUSIVE-LOCK
        WHERE segur_unid_organ.cod_unid_organ =  unid_organ.cod_unid_organ NO-ERROR.
    
    IF NOT AVAIL segur_unid_organ THEN DO:
    
        CREATE segur_unid_organ.
        ASSIGN segur_unid_organ.cod_unid_organ =  unid_organ.cod_unid_organ
               segur_unid_organ.cod_grp_usuar  = "*".
    END.

    RELEASE segur_unid_organ.
    
    FIND FIRST bftrad_org_ext NO-LOCK
        WHERE bftrad_org_ext.cod_matriz_trad_org_ext    = "EMS2"
          AND bftrad_org_ext.cod_tip_unid_organ         = "999"
          AND bftrad_org_ext.cod_unid_organ_ext         = c-estab-copia NO-ERROR.
    
    IF AVAIL bftrad_org_ext THEN DO:

        FIND FIRST trad_org_ext EXCLUSIVE-LOCK
            WHERE trad_org_ext.cod_matriz_trad_org_ext    = "EMS2"
              AND trad_org_ext.cod_tip_unid_organ         = "999"
              AND trad_org_ext.cod_unid_organ_ext         = tt-estabelec.cod-estabel:SCREEN-VALUE IN FRAME fpage0 NO-ERROR.

        IF NOT AVAIL trad_org_ext THEN DO:
            CREATE trad_org_ext.
            BUFFER-COPY bftrad_org_ext EXCEPT cod_unid_organ_ext TO trad_org_ext.
            ASSIGN trad_org_ext.cod_unid_organ_ext  = tt-estabelec.cod-estabel:SCREEN-VALUE IN FRAME fpage0
                   trad_org_ext.cod_unid_organ      = tt-estabelec.cod-estabel:SCREEN-VALUE IN FRAME fpage0.
    
        END.

    END.
    RELEASE trad_org_ext.


    FOR EACH bfmapa_distrib_ccusto  NO-LOCK
        WHERE  bfmapa_distrib_ccusto.cod_estab  = c-estab-copia:

        FIND FIRST mapa_distrib_ccusto NO-LOCK
            WHERE mapa_distrib_ccusto.cod_mapa_distrib_ccusto   = bfmapa_distrib_ccusto.cod_mapa_distrib_ccusto 
              AND mapa_distrib_ccusto.cod_estab  = STRING(tt-estabelec.cod-estabel:SCREEN-VALUE IN FRAME fpage0, "99999") NO-ERROR.

        IF NOT AVAIL mapa_distrib_ccusto THEN DO:

            CREATE mapa_distrib_ccusto.
            BUFFER-COPY bfmapa_distrib_ccusto EXCEPT cod_estab TO mapa_distrib_ccusto.
            ASSIGN mapa_distrib_ccusto.cod_estab  = STRING(tt-estabelec.cod-estabel:SCREEN-VALUE IN FRAME fpage0, "99999") .
           
        END.


        FIND FIRST item_lista_ccusto NO-LOCK
            WHERE item_lista_ccusto.cod_mapa_distrib_ccusto = bfmapa_distrib_ccusto.cod_mapa_distrib_ccusto
              AND item_lista_ccusto.cod_ccusto              = STRING(int(tt-estabelec.cod-estabel:SCREEN-VALUE IN FRAME fpage0), "99999")
              AND item_lista_ccusto.cod_estab               = tt-estabelec.cod-estabel:SCREEN-VALUE IN FRAME fpage0 
              AND item_lista_ccusto.cod_empresa             = bfmapa_distrib_ccusto.cod_empresa 
              AND item_lista_ccusto.cod_plano_ccusto        = bfmapa_distrib_ccusto.cod_plano_ccusto NO-ERROR.
    
        IF NOT AVAIL item_lista_ccusto THEN DO:

            FIND FIRST ems5.ccusto NO-LOCK
                WHERE ccusto.cod_empresa        = bfmapa_distrib_ccusto.cod_empresa            
                  AND ccusto.cod_plano_ccusto   = bfmapa_distrib_ccusto.cod_plano_ccusto 
                  AND ccusto.cod_ccusto         = STRING(int(tt-estabelec.cod-estabel:SCREEN-VALUE IN FRAME fpage0), "99999") NO-ERROR.

            IF NOT AVAIL ccusto THEN DO:

                FIND FIRST bfccusto NO-LOCK
                    WHERE bfccusto.cod_empresa        = bfmapa_distrib_ccusto.cod_empresa            
                      AND bfccusto.cod_plano_ccusto   = bfmapa_distrib_ccusto.cod_plano_ccusto 
                      AND bfccusto.cod_ccusto         = bfmapa_distrib_ccusto.cod_estab NO-ERROR.

                IF AVAIL bfccusto THEN DO:
                

                    CREATE ems5.ccusto.
                    BUFFER-COPY bfccusto EXCEPT cod_ccusto des_tit_ctbl TO ccusto.
                    ASSIGN ccusto.cod_ccusto = STRING(int(tt-estabelec.cod-estabel:SCREEN-VALUE IN FRAME fpage0), "99999")
                           ccusto.des_tit_ctbl = c-nome-pessoa:SCREEN-VALUE IN FRAME fpage1.

                END.

            END.





            CREATE item_lista_ccusto.
            ASSIGN item_lista_ccusto.cod_mapa_distrib_ccusto    = bfmapa_distrib_ccusto.cod_mapa_distrib_ccusto
                   item_lista_ccusto.cod_estab                  = tt-estabelec.cod-estabel:SCREEN-VALUE IN FRAME fpage0 
                   item_lista_ccusto.cod_ccusto                 = STRING(int(tt-estabelec.cod-estabel:SCREEN-VALUE IN FRAME fpage0), "99999")
                   item_lista_ccusto.cod_empresa                = bfmapa_distrib_ccusto.cod_empresa
                   item_lista_ccusto.cod_plano_ccusto           = bfmapa_distrib_ccusto.cod_plano_ccusto  .
    
        END.

    END.

    RELEASE mapa_distrib_ccust.
    RELEASE item_lista_ccusto.





    FOR EACH bfcriter_distrib_cta_ctbl  NO-LOCK
        WHERE  bfcriter_distrib_cta_ctbl.cod_estab   = c-estab-copia:

        FIND FIRST criter_distrib_cta_ctbl NO-LOCK
            WHERE criter_distrib_cta_ctbl.cod_cta_ctbl          = bfcriter_distrib_cta_ctbl.cod_cta_ctbl
              AND criter_distrib_cta_ctbl.cod_plano_cta_ctbl    = bfcriter_distrib_cta_ctbl.cod_plano_cta_ctbl
              AND criter_distrib_cta_ctbl.cod_estab             = tt-estabelec.cod-estabel:SCREEN-VALUE IN FRAME fpage0 NO-ERROR.

        IF NOT AVAIL criter_distrib_cta_ctbl THEN DO:

            CREATE criter_distrib_cta_ctbl.
            BUFFER-COPY bfcriter_distrib_cta_ctbl EXCEPT cod_estab TO criter_distrib_cta_ctbl.
            ASSIGN criter_distrib_cta_ctbl.cod_estab  = STRING(tt-estabelec.cod-estabel:SCREEN-VALUE IN FRAME fpage0, "99999") .

        END.

    END.

    RELEASE item_lista_ccusto.

END PROCEDURE.

/*



Table: criter_distrib_cta_ctbl

Field Name                  Data Type  Flg Format
--------------------------- ---------- --- --------------------------------
cod_plano_cta_ctbl          char       im  x(8)
cod_cta_ctbl                char       im  x(20)
cod_estab                   char       im  x(5)
num_seq_criter_distrib_ctbl inte       im  >>9
dat_inic_valid              date       m   99/99/9999
dat_fim_valid               date       m   99/99/9999
cod_empresa                 char       im  x(3)
ind_criter_distrib_ccusto   char       m   X(15)
cod_mapa_distrib_ccusto     char       im  x(8)
cod_livre_1                 char           x(100)
log_livre_1                 logi           Sim/NÆo
num_livre_1                 inte           >>>>>9
val_livre_1                 deci-4         >>>,>>>,>>9.9999
dat_livre_1                 date           99/99/9999
cod_livre_2                 char           x(100)
dat_livre_2                 date           99/99/9999
log_livre_2                 logi           Sim/NÆo
num_livre_2                 inte           >>>>>9
val_livre_2                 deci-4         >>>,>>>,>>9.9999
cdd_version                 deci-0         >>>,>>>,>>>,>>9



*/

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE goToRecord wMaintenance 
PROCEDURE goToRecord :
/*:T------------------------------------------------------------------------------
  Purpose:     Exibe dialog de V  Para
  Parameters:  
  Notes:       
------------------------------------------------------------------------------*/
    DEFINE BUTTON btGoToCancel AUTO-END-KEY 
         LABEL "&Cancelar" 
         SIZE 10 BY 1
         BGCOLOR 8.
    
    DEFINE BUTTON btGoToOK AUTO-GO 
         LABEL "&OK" 
         SIZE 10 BY 1
         BGCOLOR 8.
    
    DEFINE RECTANGLE rtGoToButton
         EDGE-PIXELS 2 GRAPHIC-EDGE  
         SIZE 58 BY 1.42
         BGCOLOR 7.
    
    DEFINE VARIABLE rGoTo AS ROWID NO-UNDO.
    
    DEFINE VARIABLE c-cod-estabel   LIKE {&ttTable}.cod-estabel    NO-UNDO.
    
    DEFINE FRAME fGoToRecord
        c-cod-estabel     AT ROW 1.21 COL 17.72 COLON-ALIGNED
        btGoToOK          AT ROW 3.63 COL 2.14
        btGoToCancel      AT ROW 3.63 COL 13
        rtGoToButton      AT ROW 3.38 COL 1
        SPACE(0.28)
        WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER SIDE-LABELS NO-UNDERLINE 
             THREE-D SCROLLABLE TITLE "V  Para estabel" FONT 1
             DEFAULT-BUTTON btGoToOK CANCEL-BUTTON btGoToCancel.
    
/*tech1139 - FO 1338.917 - 10/07/2006  */
    RUN utp/ut-trfrrp.p (input Frame fGoToRecord:Handle).
    {utp/ut-liter.i "V _Para_Estabel"}
    ASSIGN FRAME fGoToRecord:TITLE = RETURN-VALUE.
/*tech1139 - FO 1338.917 - 10/07/2006  */

    ON "CHOOSE":U OF btGoToOK IN FRAME fGoToRecord DO:
        ASSIGN c-cod-estabel.
        
        RUN goToKey IN {&hDBOTable} (INPUT c-cod-estabel ).
        IF RETURN-VALUE = "NOK":U THEN DO:
            RUN utp/ut-msgs.p (INPUT "SHOW":U, INPUT 2, INPUT "estabel":U).
            
            RETURN NO-APPLY.
        END.
        
        /*:T Retorna rowid do registro corrente do DBO */
        RUN getRowid IN {&hDBOTable} (OUTPUT rGoTo).
        
        /*:T Reposiciona registro com base em um rowid */
        RUN repositionRecord IN THIS-PROCEDURE (INPUT rGoTo).

        APPLY "GO":U TO FRAME fGoToRecord.
    END.
    
    ENABLE c-cod-estabel btGoToOK btGoToCancel 
        WITH FRAME fGoToRecord. 
    
    WAIT-FOR "GO":U OF FRAME fGoToRecord.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE initializeDBOs wMaintenance 
PROCEDURE initializeDBOs :
/*:T------------------------------------------------------------------------------
  Purpose:     Inicializa DBOs
  Parameters:  
  Notes:       
------------------------------------------------------------------------------*/
    
    /*:T--- Verifica se o DBO j  est  inicializado ---*/
    IF NOT VALID-HANDLE({&hDBOTable}) OR
       {&hDBOTable}:TYPE <> "PROCEDURE":U OR
       {&hDBOTable}:FILE-NAME <> "intprg/esbocd0403.p":U THEN DO:
        {btb/btb008za.i1 intprg/esbocd0403.p YES}
        {btb/btb008za.i2 intprg/esbocd0403.p '' {&hDBOTable}}
    END.
    
  //  RUN setConstraint<Description> IN {&hDBOTable} (<pamameters>) NO-ERROR.
    RUN openQueryStatic IN {&hDBOTable} (INPUT "main":U) NO-ERROR.
    
    RETURN "OK":U.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE validaDados wMaintenance 
PROCEDURE validaDados :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    
    FIND FIRST  ems2dis.cidade NO-LOCK
         WHERE cidade.cidade  = tt-estabelec.cidade:SCREEN-VALUE IN FRAME fpage1 NO-ERROR.

    IF AVAIL cidade THEN
        RETURN "OK".
    ELSE DO:
/*         {method/svc/errors/inserr.i                                          */
/*                                    &ErrorNumber="17006"                      */
/*                                    &ErrorType="EMS"                          */
/*                                    &ErrorSubType="ERROR"                     */
/*                                    &ErrorParameters="'Ja existe registro!'"} */
                                   
        MESSAGE "Cidade Inexistente"
            VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.

        RETURN "NOK" .
    END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

