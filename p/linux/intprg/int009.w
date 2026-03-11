&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
          emsesp           PROGRESS
*/
&Scoped-define WINDOW-NAME wMasterDetail


/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE tt-int-ds-cenar-estab NO-UNDO LIKE int-ds-cenar-estab
       fields r-rowid as rowid.
DEFINE TEMP-TABLE tt-int-ds-cenar-fam NO-UNDO LIKE int-ds-cenar-fam
       field r-rowid as rowid.
DEFINE TEMP-TABLE tt-int-ds-cenar-grupo NO-UNDO LIKE int-ds-cenar-grupo
       fields r-rowid as rowid.
DEFINE TEMP-TABLE tt-int-ds-cenario NO-UNDO LIKE int-ds-cenario
       fields r-rowid as rowid.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS wMasterDetail 
/*:T*******************************************************************************
** Copyright DATASUL S.A. (1999)
** Todos os Direitos Reservados.
**
** Este fonte e de propriedade exclusiva da DATASUL, sua reproducao
** parcial ou total por qualquer meio, so podera ser feita mediante
** autorizacao expressa.
*******************************************************************************/

{include/i-prgvrs.i int009 2.12.00.001}

CREATE WIDGET-POOL.

/* Preprocessors Definitions ---                                      */
&GLOBAL-DEFINE Program          int009
&GLOBAL-DEFINE Version          2.12.00.01
&GLOBAL-DEFINE Folder           YES
&GLOBAL-DEFINE InitialPage      1
&GLOBAL-DEFINE FolderLabels     Estabelec.,Fam¡lia,Grupo


&GLOBAL-DEFINE First            YES
&GLOBAL-DEFINE Prev             YES
&GLOBAL-DEFINE Next             YES
&GLOBAL-DEFINE Last             YES
&GLOBAL-DEFINE GoTo             YES
&GLOBAL-DEFINE Search           YES

&GLOBAL-DEFINE AddParent        YES
&GLOBAL-DEFINE CopyParent       NO
&GLOBAL-DEFINE UpdateParent     YES
&GLOBAL-DEFINE DeleteParent     YES

&GLOBAL-DEFINE AddSon1          YES
&GLOBAL-DEFINE CopySon1         NO
&GLOBAL-DEFINE UpdateSon1       NO
&GLOBAL-DEFINE DeleteSon1       YES

&GLOBAL-DEFINE AddSon2          YES
&GLOBAL-DEFINE CopySon2         NO
&GLOBAL-DEFINE UpdateSon2       NO
&GLOBAL-DEFINE DeleteSon2       YES

&GLOBAL-DEFINE AddSon3          YES
&GLOBAL-DEFINE CopySon3         NO
&GLOBAL-DEFINE UpdateSon3       NO
&GLOBAL-DEFINE DeleteSon3       YES
                         

&GLOBAL-DEFINE ttParent         tt-int-ds-cenario     
&GLOBAL-DEFINE hDBOParent       h-dbo-int-ds-cenario  
&GLOBAL-DEFINE DBOParentTable   dbo-int-ds-cenario    
&GLOBAL-DEFINE DBOParentDestroy YES                   

&GLOBAL-DEFINE ttSon1           tt-int-ds-cenar-estab
&GLOBAL-DEFINE hDBOSon1         h-dbo-int-ds-cenar-estab
&GLOBAL-DEFINE DBOSon1Table     dbo-int-ds-cenar-estab
&GLOBAL-DEFINE DBOSon1Destroy   NO

&GLOBAL-DEFINE ttSon2           tt-int-ds-cenar-fam
&GLOBAL-DEFINE hDBOSon2         h-dbo-int-ds-cenar-fam
&GLOBAL-DEFINE DBOSon2Table     dbo-int-ds-cenar-fam
&GLOBAL-DEFINE DBOSon2Destroy   NO

&GLOBAL-DEFINE ttSon3           tt-int-ds-cenar-grupo
&GLOBAL-DEFINE hDBOSon3         h-dbo-int-ds-cenar-grupo
&GLOBAL-DEFINE DBOSon3Table     dbo-int-ds-cenar-grupo
&GLOBAL-DEFINE DBOSon3Destroy   NO

DEFINE BUFFER bf-int-ds-cenar-estab FOR int-ds-cenar-estab.

&GLOBAL-DEFINE page0Fields      tt-int-ds-cenario.cod-cenario tt-int-ds-cenario.descricao 

&GLOBAL-DEFINE page1Widget      c-estab-ini c-estab-fim  bt-sav-faix bt-can-faix
&GLOBAL-DEFINE page2Widget      c-fam-ini   c-fam-fim    bt-sav-faix-2 bt-can-faix-2
&GLOBAL-DEFINE page2Widget      i-grupo-ini i-grupo-fim  bt-sav-faix-3 bt-can-faix-3

&GLOBAL-DEFINE page1Browse      brSon1 
&GLOBAL-DEFINE page2Browse      brSon2 
&GLOBAL-DEFINE page3Browse      brSon3  
  
DEFINE VARIABLE {&hDBOParent} AS HANDLE NO-UNDO.
DEFINE VARIABLE {&hDBOSon1}   AS HANDLE NO-UNDO.
DEFINE VARIABLE {&hDBOSon2}   AS HANDLE NO-UNDO.
DEFINE VARIABLE {&hDBOSon3}   AS HANDLE NO-UNDO.

DEF VAR c-desc-situacao AS CHAR NO-UNDO.
DEF VAR i-seq-erro      AS INT  NO-UNDO.

{cdp/cd0666.i}                     /* Definicao tt-erro */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE MasterDetail
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME fPage0
&Scoped-define BROWSE-NAME brSon1

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-int-ds-cenar-estab tt-int-ds-cenar-fam ~
tt-int-ds-cenar-grupo

/* Definitions for BROWSE brSon1                                        */
&Scoped-define FIELDS-IN-QUERY-brSon1 tt-int-ds-cenar-estab.cod-estabel fn-descEstab(tt-int-ds-cenar-estab.cod-estabel)   
&Scoped-define ENABLED-FIELDS-IN-QUERY-brSon1   
&Scoped-define SELF-NAME brSon1
&Scoped-define QUERY-STRING-brSon1 FOR EACH tt-int-ds-cenar-estab NO-LOCK BY tt-int-ds-cenar-estab.cod-estabel
&Scoped-define OPEN-QUERY-brSon1 OPEN QUERY {&SELF-NAME} FOR EACH tt-int-ds-cenar-estab NO-LOCK BY tt-int-ds-cenar-estab.cod-estabel.
&Scoped-define TABLES-IN-QUERY-brSon1 tt-int-ds-cenar-estab
&Scoped-define FIRST-TABLE-IN-QUERY-brSon1 tt-int-ds-cenar-estab


/* Definitions for BROWSE brSon2                                        */
&Scoped-define FIELDS-IN-QUERY-brSon2 tt-int-ds-cenar-fam.fm-codigo fn-descFam(tt-int-ds-cenar-fam.fm-codigo)   
&Scoped-define ENABLED-FIELDS-IN-QUERY-brSon2   
&Scoped-define SELF-NAME brSon2
&Scoped-define QUERY-STRING-brSon2 FOR EACH tt-int-ds-cenar-fam NO-LOCK BY tt-int-ds-cenar-fam.fm-codigo
&Scoped-define OPEN-QUERY-brSon2 OPEN QUERY {&SELF-NAME} FOR EACH tt-int-ds-cenar-fam NO-LOCK BY tt-int-ds-cenar-fam.fm-codigo.
&Scoped-define TABLES-IN-QUERY-brSon2 tt-int-ds-cenar-fam
&Scoped-define FIRST-TABLE-IN-QUERY-brSon2 tt-int-ds-cenar-fam


/* Definitions for BROWSE brSon3                                        */
&Scoped-define FIELDS-IN-QUERY-brSon3 tt-int-ds-cenar-grupo.ge-codigo fn-descGrupo(tt-int-ds-cenar-grupo.ge-codigo)   
&Scoped-define ENABLED-FIELDS-IN-QUERY-brSon3   
&Scoped-define SELF-NAME brSon3
&Scoped-define QUERY-STRING-brSon3 FOR EACH tt-int-ds-cenar-grupo NO-LOCK BY tt-int-ds-cenar-grupo.ge-codigo
&Scoped-define OPEN-QUERY-brSon3 OPEN QUERY {&SELF-NAME} FOR EACH tt-int-ds-cenar-grupo NO-LOCK BY tt-int-ds-cenar-grupo.ge-codigo.
&Scoped-define TABLES-IN-QUERY-brSon3 tt-int-ds-cenar-grupo
&Scoped-define FIRST-TABLE-IN-QUERY-brSon3 tt-int-ds-cenar-grupo


/* Definitions for FRAME fPage1                                         */
&Scoped-define OPEN-BROWSERS-IN-QUERY-fPage1 ~
    ~{&OPEN-QUERY-brSon1}

/* Definitions for FRAME fpage2                                         */
&Scoped-define OPEN-BROWSERS-IN-QUERY-fpage2 ~
    ~{&OPEN-QUERY-brSon2}

/* Definitions for FRAME fpage3                                         */
&Scoped-define OPEN-BROWSERS-IN-QUERY-fpage3 ~
    ~{&OPEN-QUERY-brSon3}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS tt-int-ds-cenario.cod-cenario ~
tt-int-ds-cenario.descricao 
&Scoped-define ENABLED-TABLES tt-int-ds-cenario
&Scoped-define FIRST-ENABLED-TABLE tt-int-ds-cenario
&Scoped-Define ENABLED-OBJECTS rtToolBar rtParent btFirst btPrev btNext ~
btLast btGoTo btSearch btAdd btUpdate btDelete btQueryJoins btReportsJoins ~
btExit btHelp 
&Scoped-Define DISPLAYED-FIELDS tt-int-ds-cenario.cod-cenario ~
tt-int-ds-cenario.descricao 
&Scoped-define DISPLAYED-TABLES tt-int-ds-cenario
&Scoped-define FIRST-DISPLAYED-TABLE tt-int-ds-cenario


/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD fn-descEstab wMasterDetail 
FUNCTION fn-descEstab RETURNS CHARACTER
  ( c-cod-estabel AS char)  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD fn-descFam wMasterDetail 
FUNCTION fn-descFam RETURNS CHARACTER
  ( c-fm-codigo AS char)  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD fn-descGrupo wMasterDetail 
FUNCTION fn-descGrupo RETURNS CHARACTER
  ( i-ge-codigo AS integer)  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD fn-Situacao wMasterDetail 
FUNCTION fn-Situacao RETURNS CHARACTER
  ( p-situacao AS INT)  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD fnCliente wMasterDetail 
FUNCTION fnCliente RETURNS CHARACTER
  ( i-emitente AS INTEGER )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD fnContrato wMasterDetail 
FUNCTION fnContrato RETURNS CHARACTER
  ( p-ts AS INTEGER , p-versao AS INTEGER /* parameter-definitions */ )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD fnPedido wMasterDetail 
FUNCTION fnPedido RETURNS CHARACTER
  (p-ts AS INTEGER , p-versao AS INTEGER /* parameter-definitions */ )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD fnQuantidade wMasterDetail 
FUNCTION fnQuantidade RETURNS DECIMAL
  (p-ts AS INTEGER , p-versao AS INTEGER /* parameter-definitions */ )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR wMasterDetail AS WIDGET-HANDLE NO-UNDO.

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

DEFINE BUTTON btSearch 
     IMAGE-UP FILE "image\im-sea":U
     IMAGE-INSENSITIVE FILE "image\ii-sea":U
     LABEL "Search" 
     SIZE 4 BY 1.25.

DEFINE BUTTON btUpdate 
     IMAGE-UP FILE "image\im-mod":U
     IMAGE-INSENSITIVE FILE "image\ii-mod":U
     LABEL "Update" 
     SIZE 4 BY 1.25
     FONT 4.

DEFINE RECTANGLE rtParent
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 124 BY 1.75.

DEFINE RECTANGLE rtToolBar
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 126 BY 1.5
     BGCOLOR 7 .

DEFINE BUTTON bt-can-faix AUTO-END-KEY 
     IMAGE-UP FILE "image\im-can":U
     IMAGE-INSENSITIVE FILE "image\im-can":U
     LABEL "Elimina" 
     SIZE 4 BY 1.25 TOOLTIP "Elimina Faixa"
     FONT 4.

DEFINE BUTTON bt-sav-faix 
     IMAGE-UP FILE "image\im-sav":U
     IMAGE-INSENSITIVE FILE "image\ii-sav":U
     LABEL "Faixa" 
     SIZE 4 BY 1.25 TOOLTIP "incluir Faixa"
     FONT 4.

DEFINE BUTTON btAddSon1 
     LABEL "Incluir" 
     SIZE 10 BY 1.

DEFINE BUTTON btCopySon1 
     LABEL "Copiar" 
     SIZE 10 BY 1.

DEFINE BUTTON btDeleteSon1 
     LABEL "Eliminar" 
     SIZE 10 BY 1.

DEFINE BUTTON btUpdateSon1 
     LABEL "Alterar" 
     SIZE 10 BY 1.

DEFINE VARIABLE c-estab-fim AS CHARACTER FORMAT "X(3)" INITIAL "ZZZ" 
     VIEW-AS FILL-IN 
     SIZE 5 BY .88 NO-UNDO.

DEFINE VARIABLE c-estab-ini LIKE estabelec.cod-estabel
     LABEL "Estabelecimento":R15 
     VIEW-AS FILL-IN 
     SIZE 6 BY .88 NO-UNDO.

DEFINE IMAGE IMAGE-12
     FILENAME "image\im-fir":U
     SIZE 3 BY .88.

DEFINE IMAGE IMAGE-21
     FILENAME "image\im-las":U
     SIZE 3 BY .88.

DEFINE BUTTON bt-can-faix-2 AUTO-END-KEY 
     IMAGE-UP FILE "image\im-can":U
     IMAGE-INSENSITIVE FILE "image\im-can":U
     LABEL "Elimina" 
     SIZE 4 BY 1.25 TOOLTIP "Elimina Faixa"
     FONT 4.

DEFINE BUTTON bt-sav-faix-2 
     IMAGE-UP FILE "image\im-sav":U
     IMAGE-INSENSITIVE FILE "image\ii-sav":U
     LABEL "Faixa" 
     SIZE 4 BY 1.25 TOOLTIP "incluir Faixa"
     FONT 4.

DEFINE BUTTON btAddSon2 
     LABEL "Incluir" 
     SIZE 10 BY 1.

DEFINE BUTTON btCopySon2 
     LABEL "Copiar" 
     SIZE 10 BY 1.

DEFINE BUTTON btDeleteSon2 
     LABEL "Eliminar" 
     SIZE 10 BY 1.

DEFINE BUTTON btUpdateSon2 
     LABEL "Alterar" 
     SIZE 10 BY 1.

DEFINE VARIABLE c-fam-fim AS CHARACTER FORMAT "X(08)" INITIAL "ZZZZZZZZ" 
     VIEW-AS FILL-IN 
     SIZE 10 BY .88 NO-UNDO.

DEFINE VARIABLE c-fam-ini AS CHARACTER FORMAT "X(12)" 
     LABEL "Fam¡lia":R15 
     VIEW-AS FILL-IN 
     SIZE 10 BY .88 NO-UNDO.

DEFINE IMAGE IMAGE-22
     FILENAME "image\im-fir":U
     SIZE 3 BY .88.

DEFINE IMAGE IMAGE-23
     FILENAME "image\im-las":U
     SIZE 3 BY .88.

DEFINE BUTTON bt-can-faix-3 AUTO-END-KEY 
     IMAGE-UP FILE "image\im-can":U
     IMAGE-INSENSITIVE FILE "image\im-can":U
     LABEL "Elimina" 
     SIZE 4 BY 1.25 TOOLTIP "Elimina Faixa"
     FONT 4.

DEFINE BUTTON bt-sav-faix-3 
     IMAGE-UP FILE "image\im-sav":U
     IMAGE-INSENSITIVE FILE "image\ii-sav":U
     LABEL "Faixa" 
     SIZE 4 BY 1.25 TOOLTIP "incluir Faixa"
     FONT 4.

DEFINE BUTTON btAddSon3 
     LABEL "Incluir" 
     SIZE 10 BY 1.

DEFINE BUTTON btCopySon3 
     LABEL "Copiar" 
     SIZE 10 BY 1.

DEFINE BUTTON btDeleteSon3 
     LABEL "Eliminar" 
     SIZE 10 BY 1.

DEFINE BUTTON btUpdateSon3 
     LABEL "Alterar" 
     SIZE 10 BY 1.

DEFINE VARIABLE i-grupo-fim AS INTEGER FORMAT ">9" INITIAL 99 
     VIEW-AS FILL-IN 
     SIZE 4.14 BY .88 NO-UNDO.

DEFINE VARIABLE i-grupo-ini AS INTEGER FORMAT ">>9" INITIAL 0 
     LABEL "Grupo":R15 
     VIEW-AS FILL-IN 
     SIZE 4.29 BY .88 NO-UNDO.

DEFINE IMAGE IMAGE-24
     FILENAME "image\im-fir":U
     SIZE 3 BY .88.

DEFINE IMAGE IMAGE-25
     FILENAME "image\im-las":U
     SIZE 3 BY .88.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY brSon1 FOR 
      tt-int-ds-cenar-estab SCROLLING.

DEFINE QUERY brSon2 FOR 
      tt-int-ds-cenar-fam SCROLLING.

DEFINE QUERY brSon3 FOR 
      tt-int-ds-cenar-grupo SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE brSon1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS brSon1 wMasterDetail _FREEFORM
  QUERY brSon1 NO-LOCK DISPLAY
      tt-int-ds-cenar-estab.cod-estabel   COLUMN-LABEL "Estab" WIDTH 5
      fn-descEstab(tt-int-ds-cenar-estab.cod-estabel) FORMAT "X(60)" COLUMN-LABEL "Descri‡Æo"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 61 BY 12
         FONT 2.

DEFINE BROWSE brSon2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS brSon2 wMasterDetail _FREEFORM
  QUERY brSon2 NO-LOCK DISPLAY
      tt-int-ds-cenar-fam.fm-codigo   COLUMN-LABEL "Fam¡lia" WIDTH 10
      fn-descFam(tt-int-ds-cenar-fam.fm-codigo) FORMAT "X(60)" COLUMN-LABEL "Descri‡Æo"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 61 BY 12
         FONT 2.

DEFINE BROWSE brSon3
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS brSon3 wMasterDetail _FREEFORM
  QUERY brSon3 NO-LOCK DISPLAY
      tt-int-ds-cenar-grupo.ge-codigo   COLUMN-LABEL "Grupo" WIDTH 10
      fn-descGrupo(tt-int-ds-cenar-grupo.ge-codigo) FORMAT "X(60)" COLUMN-LABEL "Descri‡Æo"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 61 BY 12
         FONT 2.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME fPage0
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
     btUpdate AT ROW 1.13 COL 34.86 HELP
          "Altera ocorrˆncia corrente"
     btDelete AT ROW 1.13 COL 38.86 HELP
          "Elimina ocorrˆncia corrente"
     btQueryJoins AT ROW 1.13 COL 109.86 HELP
          "Consultas relacionadas"
     btReportsJoins AT ROW 1.13 COL 113.86 HELP
          "Relat¢rios relacionados"
     btExit AT ROW 1.13 COL 117.86 HELP
          "Sair"
     btHelp AT ROW 1.13 COL 121.86 HELP
          "Ajuda"
     tt-int-ds-cenario.cod-cenario AT ROW 3.17 COL 13 COLON-ALIGNED WIDGET-ID 74
          VIEW-AS FILL-IN 
          SIZE 19 BY .88
     tt-int-ds-cenario.descricao AT ROW 3.17 COL 32.57 COLON-ALIGNED NO-LABEL WIDGET-ID 6
          VIEW-AS FILL-IN 
          SIZE 75.43 BY .88
     rtToolBar AT ROW 1 COL 1
     rtParent AT ROW 2.75 COL 1.86
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 126 BY 19.46
         FONT 1 WIDGET-ID 100.

DEFINE FRAME fpage3
     brSon3 AT ROW 1.38 COL 3.14
     i-grupo-ini AT ROW 1.5 COL 76.72 COLON-ALIGNED WIDGET-ID 76
     i-grupo-fim AT ROW 1.5 COL 89.86 COLON-ALIGNED NO-LABEL WIDGET-ID 74
     bt-sav-faix-3 AT ROW 1.5 COL 105 HELP
          "Confirma altera‡äes" WIDGET-ID 84
     bt-can-faix-3 AT ROW 1.5 COL 109 HELP
          "Cancela altera‡äes" WIDGET-ID 82
     btAddSon3 AT ROW 14 COL 3.57
     btDeleteSon3 AT ROW 14 COL 14
     btCopySon3 AT ROW 14 COL 44
     btUpdateSon3 AT ROW 14 COL 54
     IMAGE-24 AT ROW 1.5 COL 84 WIDGET-ID 78
     IMAGE-25 AT ROW 1.5 COL 88.29 WIDGET-ID 80
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 2 ROW 5.75
         SIZE 123 BY 14.5
         FONT 1 WIDGET-ID 300.

DEFINE FRAME fpage2
     brSon2 AT ROW 1.38 COL 3.14
     c-fam-ini AT ROW 1.5 COL 70.72 COLON-ALIGNED WIDGET-ID 76
     c-fam-fim AT ROW 1.5 COL 89.86 COLON-ALIGNED NO-LABEL WIDGET-ID 74
     bt-sav-faix-2 AT ROW 1.5 COL 105 HELP
          "Confirma altera‡äes" WIDGET-ID 84
     bt-can-faix-2 AT ROW 1.5 COL 109 HELP
          "Cancela altera‡äes" WIDGET-ID 82
     btAddSon2 AT ROW 14 COL 3.57
     btDeleteSon2 AT ROW 14 COL 14
     btCopySon2 AT ROW 14 COL 44
     btUpdateSon2 AT ROW 14 COL 54
     IMAGE-22 AT ROW 1.5 COL 84 WIDGET-ID 78
     IMAGE-23 AT ROW 1.5 COL 88.29 WIDGET-ID 80
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 2 ROW 5.75
         SIZE 123 BY 14.5
         FONT 1 WIDGET-ID 200.

DEFINE FRAME fPage1
     brSon1 AT ROW 1.38 COL 3.14
     c-estab-ini AT ROW 1.5 COL 76 COLON-ALIGNED HELP
          "" WIDGET-ID 76
          LABEL "Estabelecimento":R15
     c-estab-fim AT ROW 1.5 COL 92 COLON-ALIGNED NO-LABEL WIDGET-ID 74
     bt-sav-faix AT ROW 1.5 COL 102 HELP
          "Confirma altera‡äes" WIDGET-ID 84
     bt-can-faix AT ROW 1.5 COL 106 HELP
          "Cancela altera‡äes" WIDGET-ID 82
     btAddSon1 AT ROW 14 COL 3.57
     btDeleteSon1 AT ROW 14 COL 14
     btCopySon1 AT ROW 14 COL 44
     btUpdateSon1 AT ROW 14 COL 54
     IMAGE-12 AT ROW 1.5 COL 85.14 WIDGET-ID 78
     IMAGE-21 AT ROW 1.5 COL 90.14 WIDGET-ID 80
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 2 ROW 5.75
         SIZE 123 BY 14.5
         FONT 1 WIDGET-ID 100.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: MasterDetail
   Allow: Basic,Browse,DB-Fields,Window,Query
   Add Fields to: Neither
   Other Settings: COMPILE
   Temp-Tables and Buffers:
      TABLE: tt-int-ds-cenar-estab T "?" NO-UNDO emsespe int-ds-cenar-estab
      ADDITIONAL-FIELDS:
          fields r-rowid as rowid
      END-FIELDS.
      TABLE: tt-int-ds-cenar-fam T "?" NO-UNDO emsesp int-ds-cenar-fam
      ADDITIONAL-FIELDS:
          field r-rowid as rowid
      END-FIELDS.
      TABLE: tt-int-ds-cenar-grupo T "?" NO-UNDO emsesp int-ds-cenar-grupo
      ADDITIONAL-FIELDS:
          fields r-rowid as rowid
      END-FIELDS.
      TABLE: tt-int-ds-cenario T "?" NO-UNDO emsespe int-ds-cenario
      ADDITIONAL-FIELDS:
          fields r-rowid as rowid
      END-FIELDS.
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
IF SESSION:DISPLAY-TYPE = "GUI":U THEN
  CREATE WINDOW wMasterDetail ASSIGN
         HIDDEN             = YES
         TITLE              = ""
         HEIGHT             = 19.46
         WIDTH              = 126
         MAX-HEIGHT         = 29.38
         MAX-WIDTH          = 195.14
         VIRTUAL-HEIGHT     = 29.38
         VIRTUAL-WIDTH      = 195.14
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _INCLUDED-LIB wMasterDetail 
/* ************************* Included-Libraries *********************** */

{masterdetail/masterdetail.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME




/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW wMasterDetail
  NOT-VISIBLE,,RUN-PERSISTENT                                           */
/* REPARENT FRAME */
ASSIGN FRAME fPage1:FRAME = FRAME fPage0:HANDLE
       FRAME fpage2:FRAME = FRAME fPage0:HANDLE
       FRAME fpage3:FRAME = FRAME fPage0:HANDLE.

/* SETTINGS FOR FRAME fPage0
   FRAME-NAME                                                           */
/* SETTINGS FOR FRAME fPage1
                                                                        */
/* BROWSE-TAB brSon1 IMAGE-21 fPage1 */
ASSIGN 
       btCopySon1:HIDDEN IN FRAME fPage1           = TRUE.

ASSIGN 
       btUpdateSon1:HIDDEN IN FRAME fPage1           = TRUE.

/* SETTINGS FOR FILL-IN c-estab-ini IN FRAME fPage1
   LIKE = mgadm.estabelec.cod-estabel EXP-LABEL                         */
/* SETTINGS FOR FRAME fpage2
                                                                        */
/* BROWSE-TAB brSon2 IMAGE-23 fpage2 */
ASSIGN 
       btCopySon2:HIDDEN IN FRAME fpage2           = TRUE.

ASSIGN 
       btUpdateSon2:HIDDEN IN FRAME fpage2           = TRUE.

/* SETTINGS FOR FRAME fpage3
                                                                        */
/* BROWSE-TAB brSon3 IMAGE-25 fpage3 */
ASSIGN 
       btCopySon3:HIDDEN IN FRAME fpage3           = TRUE.

ASSIGN 
       btUpdateSon3:HIDDEN IN FRAME fpage3           = TRUE.

IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(wMasterDetail)
THEN wMasterDetail:HIDDEN = yes.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE brSon1
/* Query rebuild information for BROWSE brSon1
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH tt-int-ds-cenar-estab NO-LOCK BY tt-int-ds-cenar-estab.cod-estabel.
     _END_FREEFORM
     _Options          = "NO-LOCK"
     _Query            is OPENED
*/  /* BROWSE brSon1 */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE brSon2
/* Query rebuild information for BROWSE brSon2
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH tt-int-ds-cenar-fam NO-LOCK BY tt-int-ds-cenar-fam.fm-codigo.
     _END_FREEFORM
     _Options          = "NO-LOCK"
     _Query            is OPENED
*/  /* BROWSE brSon2 */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE brSon3
/* Query rebuild information for BROWSE brSon3
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH tt-int-ds-cenar-grupo NO-LOCK BY tt-int-ds-cenar-grupo.ge-codigo.
     _END_FREEFORM
     _Options          = "NO-LOCK"
     _Query            is OPENED
*/  /* BROWSE brSon3 */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK FRAME fPage0
/* Query rebuild information for FRAME fPage0
     _Options          = "SHARE-LOCK KEEP-EMPTY"
     _Query            is NOT OPENED
*/  /* FRAME fPage0 */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK FRAME fPage1
/* Query rebuild information for FRAME fPage1
     _Query            is NOT OPENED
*/  /* FRAME fPage1 */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK FRAME fpage2
/* Query rebuild information for FRAME fpage2
     _Query            is NOT OPENED
*/  /* FRAME fpage2 */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK FRAME fpage3
/* Query rebuild information for FRAME fpage3
     _Query            is NOT OPENED
*/  /* FRAME fpage3 */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME wMasterDetail
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL wMasterDetail wMasterDetail
ON END-ERROR OF wMasterDetail
OR ENDKEY OF {&WINDOW-NAME} ANYWHERE DO:
  /* This case occurs when the user presses the "Esc" key.
     In a persistently run window, just ignore this.  If we did not, the
     application would exit. */
  IF THIS-PROCEDURE:PERSISTENT THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL wMasterDetail wMasterDetail
ON WINDOW-CLOSE OF wMasterDetail
DO:
  /* This event will close the window and terminate the procedure.  */
  APPLY "CLOSE":U TO THIS-PROCEDURE.
  RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME fPage1
&Scoped-define SELF-NAME bt-can-faix
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-can-faix wMasterDetail
ON CHOOSE OF bt-can-faix IN FRAME fPage1 /* Elimina */
DO:

      FOR EACH estabelec NO-LOCK WHERE
               estabelec.cod-estabel >= INPUT FRAME fpage1 c-estab-ini AND 
               estabelec.cod-estabel <= INPUT FRAME fpage1 c-estab-fim :

          FIND FIRST int-ds-cenar-estab EXCLUSIVE-LOCK WHERE
                     int-ds-cenar-estab.cod-cenario = tt-int-ds-cenario.cod-cenario AND
                     int-ds-cenar-estab.cod-estabel = estabelec.cod-estabel NO-ERROR.
          IF AVAIL int-ds-cenar-estab THEN DO:
             DELETE int-ds-cenar-estab.
          END.                               

      END.

      RUN openQueriesSon IN THIS-PROCEDURE.



END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME fpage2
&Scoped-define SELF-NAME bt-can-faix-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-can-faix-2 wMasterDetail
ON CHOOSE OF bt-can-faix-2 IN FRAME fpage2 /* Elimina */
DO:

      FOR EACH familia NO-LOCK WHERE
               familia.fm-codigo >= INPUT FRAME fpage2 c-fam-ini AND 
               familia.fm-codigo <= INPUT FRAME fpage2 c-fam-fim :

          FIND FIRST int-ds-cenar-fam EXCLUSIVE-LOCK WHERE
                     int-ds-cenar-fam.cod-cenario = tt-int-ds-cenario.cod-cenario AND
                     int-ds-cenar-fam.fm-codigo   = familia.fm-codigo NO-ERROR.
          IF AVAIL int-ds-cenar-fam THEN DO:
             DELETE int-ds-cenar-fam.
          END.                               

      END.

      RUN openQueriesSon2 IN THIS-PROCEDURE.



END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME fpage3
&Scoped-define SELF-NAME bt-can-faix-3
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-can-faix-3 wMasterDetail
ON CHOOSE OF bt-can-faix-3 IN FRAME fpage3 /* Elimina */
DO:

      FOR EACH Grup-estoq NO-LOCK WHERE
             Grup-estoq.ge-codigo >= INPUT FRAME fpage3 i-grupo-ini AND 
             Grup-estoq.ge-codigo <= INPUT FRAME fpage3 i-grupo-fim :

        FIND FIRST int-ds-cenar-grupo EXCLUSIVE-LOCK WHERE
                   int-ds-cenar-grupo.cod-cenario = tt-int-ds-cenario.cod-cenario AND
                   int-ds-cenar-grupo.ge-codigo   = Grup-estoq.ge-codigo NO-ERROR.
        IF AVAIL int-ds-cenar-grupo THEN DO:   
           DELETE int-ds-cenar-grupo.
        END. 

      END.

        RUN openQueriesSon IN THIS-PROCEDURE.



END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME fPage1
&Scoped-define SELF-NAME bt-sav-faix
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-sav-faix wMasterDetail
ON CHOOSE OF bt-sav-faix IN FRAME fPage1 /* Faixa */
DO:
    
    FOR EACH estabelec NO-LOCK WHERE
             estabelec.cod-estabel >= INPUT FRAME fpage1 c-estab-ini AND 
             estabelec.cod-estabel <= INPUT FRAME fpage1 c-estab-fim :

        FIND FIRST int-ds-cenar-estab NO-LOCK WHERE
                   int-ds-cenar-estab.cod-cenario = tt-int-ds-cenario.cod-cenario AND
                   int-ds-cenar-estab.cod-estabel = estabelec.cod-estabel NO-ERROR.
        IF NOT AVAIL int-ds-cenar-estab THEN DO:

           CREATE int-ds-cenar-estab.
           ASSIGN int-ds-cenar-estab.cod-cenario = tt-int-ds-cenario.cod-cenario 
                  int-ds-cenar-estab.cod-estabel = estabelec.cod-estabel.
        END. 

        
            
    END.

    RUN openQueriesSon IN THIS-PROCEDURE.

    RETURN "":U.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME fpage2
&Scoped-define SELF-NAME bt-sav-faix-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-sav-faix-2 wMasterDetail
ON CHOOSE OF bt-sav-faix-2 IN FRAME fpage2 /* Faixa */
DO:
    
    FOR EACH familia NO-LOCK WHERE
             familia.fm-codigo >= INPUT FRAME fpage2 c-fam-ini AND 
             familia.fm-codigo <= INPUT FRAME fpage2 c-fam-fim :

        FIND FIRST int-ds-cenar-fam NO-LOCK WHERE
                   int-ds-cenar-fam.cod-cenario = tt-int-ds-cenario.cod-cenario AND
                   int-ds-cenar-fam.fm-codigo   = familia.fm-codigo NO-ERROR.
        IF NOT AVAIL int-ds-cenar-fam THEN DO:

           CREATE int-ds-cenar-fam.
           ASSIGN int-ds-cenar-fam.cod-cenario = tt-int-ds-cenario.cod-cenario 
                  int-ds-cenar-fam.fm-codigo   = familia.fm-codigo.
        END. 
        
            
    END.

    RUN openQueriesSon IN THIS-PROCEDURE.

    RETURN "":U.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME fpage3
&Scoped-define SELF-NAME bt-sav-faix-3
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-sav-faix-3 wMasterDetail
ON CHOOSE OF bt-sav-faix-3 IN FRAME fpage3 /* Faixa */
DO:
    
    FOR EACH Grup-estoq NO-LOCK WHERE
             Grup-estoq.ge-codigo >= INPUT FRAME fpage3 i-grupo-ini AND 
             Grup-estoq.ge-codigo <= INPUT FRAME fpage3 i-grupo-fim :

        FIND FIRST int-ds-cenar-grupo NO-LOCK WHERE
                   int-ds-cenar-grupo.cod-cenario = tt-int-ds-cenario.cod-cenario AND
                   int-ds-cenar-grupo.ge-codigo   = Grup-estoq.ge-codigo NO-ERROR.
        IF NOT AVAIL int-ds-cenar-grupo THEN DO:

           CREATE int-ds-cenar-grupo.
           ASSIGN int-ds-cenar-grupo.cod-cenario = tt-int-ds-cenario.cod-cenario 
                  int-ds-cenar-grupo.ge-codigo   = Grup-estoq.ge-codigo.
        END. 
        
            
    END.

    RUN openQueriesSon IN THIS-PROCEDURE.

    RETURN "":U.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME fPage0
&Scoped-define SELF-NAME btAdd
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btAdd wMasterDetail
ON CHOOSE OF btAdd IN FRAME fPage0 /* Add */
OR CHOOSE OF MENU-ITEM miAdd IN MENU mbMain DO:
    RUN addRecord IN THIS-PROCEDURE (INPUT "intprg\int009a.w":U). 
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME fPage1
&Scoped-define SELF-NAME btAddSon1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btAddSon1 wMasterDetail
ON CHOOSE OF btAddSon1 IN FRAME fPage1 /* Incluir */
DO:
    {masterdetail/addson.i &ProgramSon="intprg\int009b.w"
                           &PageNumber="1"}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME fpage2
&Scoped-define SELF-NAME btAddSon2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btAddSon2 wMasterDetail
ON CHOOSE OF btAddSon2 IN FRAME fpage2 /* Incluir */
DO:
    {masterdetail/addson.i &ProgramSon="intprg\int009c.w"
                           &PageNumber="2"}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME fpage3
&Scoped-define SELF-NAME btAddSon3
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btAddSon3 wMasterDetail
ON CHOOSE OF btAddSon3 IN FRAME fpage3 /* Incluir */
DO:
    {masterdetail/addson.i &ProgramSon="intprg\int009d.w"
                           &PageNumber="3"}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME fPage1
&Scoped-define SELF-NAME btCopySon1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btCopySon1 wMasterDetail
ON CHOOSE OF btCopySon1 IN FRAME fPage1 /* Copiar */
DO:
    {masterdetail/copyson.i &ProgramSon="intprg\int002b-01.w"
                            &PageNumber="1"}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME fpage2
&Scoped-define SELF-NAME btCopySon2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btCopySon2 wMasterDetail
ON CHOOSE OF btCopySon2 IN FRAME fpage2 /* Copiar */
DO:
    {masterdetail/copyson.i &ProgramSon="intprg\int009c.w"
                            &PageNumber="2"}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME fpage3
&Scoped-define SELF-NAME btCopySon3
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btCopySon3 wMasterDetail
ON CHOOSE OF btCopySon3 IN FRAME fpage3 /* Copiar */
DO:
    {masterdetail/copyson.i &ProgramSon="intprg\int009c.w"
                            &PageNumber="3"}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME fPage0
&Scoped-define SELF-NAME btDelete
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btDelete wMasterDetail
ON CHOOSE OF btDelete IN FRAME fPage0 /* Delete */
OR CHOOSE OF MENU-ITEM miDelete IN MENU mbMain DO:
    RUN deleteRecord IN THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME fPage1
&Scoped-define SELF-NAME btDeleteSon1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btDeleteSon1 wMasterDetail
ON CHOOSE OF btDeleteSon1 IN FRAME fPage1 /* Eliminar */
DO:
    
   {masterdetail/deleteson.i &PageNumber="1"}
    
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME fpage2
&Scoped-define SELF-NAME btDeleteSon2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btDeleteSon2 wMasterDetail
ON CHOOSE OF btDeleteSon2 IN FRAME fpage2 /* Eliminar */
DO:
    
   {masterdetail/deleteson.i &PageNumber="2"}
    
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME fpage3
&Scoped-define SELF-NAME btDeleteSon3
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btDeleteSon3 wMasterDetail
ON CHOOSE OF btDeleteSon3 IN FRAME fpage3 /* Eliminar */
DO:
    
   {masterdetail/deleteson.i &PageNumber="3"}
    
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME fPage0
&Scoped-define SELF-NAME btExit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btExit wMasterDetail
ON CHOOSE OF btExit IN FRAME fPage0 /* Exit */
OR CHOOSE OF MENU-ITEM miExit IN MENU mbMain DO:
    APPLY "CLOSE":U TO THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btFirst
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btFirst wMasterDetail
ON CHOOSE OF btFirst IN FRAME fPage0 /* First */
OR CHOOSE OF MENU-ITEM miFirst IN MENU mbMain DO:
    RUN getFirst IN THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btGoTo
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btGoTo wMasterDetail
ON CHOOSE OF btGoTo IN FRAME fPage0 /* Go To */
OR CHOOSE OF MENU-ITEM miGoTo IN MENU mbMain DO:
    RUN goToRecord IN THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btHelp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btHelp wMasterDetail
ON CHOOSE OF btHelp IN FRAME fPage0 /* Help */
OR CHOOSE OF MENU-ITEM miContents IN MENU mbMain DO:
    {include/ajuda.i}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btLast
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btLast wMasterDetail
ON CHOOSE OF btLast IN FRAME fPage0 /* Last */
OR CHOOSE OF MENU-ITEM miLast IN MENU mbMain DO:
    RUN getLast IN THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btNext
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btNext wMasterDetail
ON CHOOSE OF btNext IN FRAME fPage0 /* Next */
OR CHOOSE OF MENU-ITEM miNext IN MENU mbMain DO:
    RUN getNext IN THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btPrev
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btPrev wMasterDetail
ON CHOOSE OF btPrev IN FRAME fPage0 /* Prev */
OR CHOOSE OF MENU-ITEM miPrev IN MENU mbMain DO:
    RUN getPrev IN THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btQueryJoins
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btQueryJoins wMasterDetail
ON CHOOSE OF btQueryJoins IN FRAME fPage0 /* Query Joins */
OR CHOOSE OF MENU-ITEM miQueryJoins IN MENU mbMain DO:
    RUN showQueryJoins IN THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btReportsJoins
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btReportsJoins wMasterDetail
ON CHOOSE OF btReportsJoins IN FRAME fPage0 /* Reports Joins */
OR CHOOSE OF MENU-ITEM miReportsJoins IN MENU mbMain DO:
    RUN showReportsJoins IN THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btSearch
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btSearch wMasterDetail
ON CHOOSE OF btSearch IN FRAME fPage0 /* Search */
OR CHOOSE OF MENU-ITEM miSearch IN MENU mbMain DO:
    {method/zoomreposition.i &ProgramZoom="intprg\int009zoom.w"}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btUpdate
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btUpdate wMasterDetail
ON CHOOSE OF btUpdate IN FRAME fPage0 /* Update */
OR CHOOSE OF MENU-ITEM miUpdate IN MENU mbMain DO:
    RUN updateRecord IN THIS-PROCEDURE (INPUT "intprg\int009a.w":U).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME fPage1
&Scoped-define SELF-NAME btUpdateSon1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btUpdateSon1 wMasterDetail
ON CHOOSE OF btUpdateSon1 IN FRAME fPage1 /* Alterar */
DO:
    
    {masterdetail/updateson.i &ProgramSon="intprg\int002b-01.w"
                              &PageNumber="1"}
    
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME fpage2
&Scoped-define SELF-NAME btUpdateSon2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btUpdateSon2 wMasterDetail
ON CHOOSE OF btUpdateSon2 IN FRAME fpage2 /* Alterar */
DO:
    
    {masterdetail/updateson.i &ProgramSon="intprg\int002b-01.w"
                              &PageNumber="1"}
    
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME fpage3
&Scoped-define SELF-NAME btUpdateSon3
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btUpdateSon3 wMasterDetail
ON CHOOSE OF btUpdateSon3 IN FRAME fpage3 /* Alterar */
DO:
    
    {masterdetail/updateson.i &ProgramSon="intprg\int009c.w"
                              &PageNumber="3"}
    
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME fPage0
&Scoped-define BROWSE-NAME brSon1
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK wMasterDetail 


/*:T--- L¢gica para inicializa‡Æo do programam ---*/
{masterdetail/mainblock.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE afterdisplayfields wMasterDetail 
PROCEDURE afterdisplayfields :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
  
    IF AVAIL tt-int-ds-cenario THEN DO:
     
    END.

   RETURN "ok".

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE afterInitializeInterface wMasterDetail 
PROCEDURE afterInitializeInterface :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    ASSIGN c-estab-ini:SENSITIVE IN FRAME fpage1 = YES
           c-estab-fim:SENSITIVE IN FRAME fpage1 = YES
           bt-sav-faix:SENSITIVE IN FRAME fpage1 = YES
           bt-can-faix:SENSITIVE IN FRAME fpage1 = YES
           c-estab-fim:SCREEN-VALUE IN FRAME fpage1 = "ZZZ"
           c-fam-ini:SENSITIVE IN FRAME fpage2 = YES
           c-fam-fim:SENSITIVE IN FRAME fpage2 = YES
           bt-sav-faix-2:SENSITIVE IN FRAME fpage2 = YES
           bt-can-faix-2:SENSITIVE IN FRAME fpage2 = YES
           c-fam-fim:SCREEN-VALUE IN FRAME fpage2 = "ZZZZZZZZ"
           i-grupo-ini:SENSITIVE IN FRAME fpage3 = YES
           i-grupo-fim:SENSITIVE IN FRAME fpage3 = YES
           bt-sav-faix-3:SENSITIVE IN FRAME fpage3 = YES
           bt-can-faix-3:SENSITIVE IN FRAME fpage3 = YES
           i-grupo-fim:SCREEN-VALUE IN FRAME fpage3 = "99".
           
    RETURN "Ok".

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE goToRecord wMasterDetail 
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
    
    DEFINE VARIABLE c-cod-cenario LIKE {&ttParent}.cod-cenario NO-UNDO.

    DEFINE FRAME fGoToRecord
        c-cod-cenario AT ROW 1.7 COL 17.72 COLON-ALIGNED
        btGoToOK       AT ROW 3.63 COL 2.14
        btGoToCancel   AT ROW 3.63 COL 13
        rtGoToButton   AT ROW 3.38 COL 1
        SPACE(0.28)
        WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER SIDE-LABELS NO-UNDERLINE 
             THREE-D SCROLLABLE TITLE "V  Para Cen rio" FONT 1
             DEFAULT-BUTTON btGoToOK CANCEL-BUTTON btGoToCancel.

/*tech1139 - FO 1338.917 - 10/07/2006  */
    RUN utp/ut-trfrrp.p (input Frame fGoToRecord:Handle).
    {utp/ut-liter.i "V _Para_Cen rio"}
    ASSIGN FRAME fGoToRecord:TITLE = RETURN-VALUE.
/*tech1139 - FO 1338.917 - 10/07/2006  */
                                         
    ON "CHOOSE":U OF btGoToOK IN FRAME fGoToRecord DO:
        ASSIGN c-cod-cenario.

      /*:T Posiciona query, do DBO, atrav‚s dos valores do ¡ndice £nico */
        RUN goToKey IN {&hDBOParent} (INPUT c-cod-cenario). 
                                               
        IF RETURN-VALUE = "NOK":U THEN DO:
            RUN utp/ut-msgs.p (INPUT "SHOW":U, INPUT 2, INPUT "Cen rio":U).
            
            RETURN NO-APPLY.
        END.
        
        /*:T Retorna rowid do registro corrente do DBO */
        RUN getRowid IN {&hDBOParent} (OUTPUT rGoTo).
        
        /*:T Reposiciona registro com base em um rowid */
        RUN repositionRecord IN THIS-PROCEDURE (INPUT rGoTo).
        
        APPLY "GO":U TO FRAME fGoToRecord.
    END.
    
    ENABLE c-cod-cenario btGoToOK btGoToCancel 
        WITH FRAME fGoToRecord. 
    
    WAIT-FOR "GO":U OF FRAME fGoToRecord.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE initializeDBOs wMasterDetail 
PROCEDURE initializeDBOs :
/*:T------------------------------------------------------------------------------
  Purpose:     Inicializa DBOs
  Parameters:  
  Notes:       
------------------------------------------------------------------------------*/
    
    /*:T--- Verifica se o DBO j  est  inicializado ---*/
    IF NOT VALID-HANDLE({&hDBOParent})  THEN DO:
        {btb/btb008za.i1 intprg\intbo009a.p YES}
        {btb/btb008za.i2 intprg\intbo009a.p '' {&hDBOParent}} 
    END.
    
    RUN openQueryStatic IN {&hDBOParent} (INPUT "Main":U) NO-ERROR.
    
    /*:T--- Verifica se o DBO j  est  inicializado ---*/
    IF NOT VALID-HANDLE({&hDBOSon1}) THEN DO:
        {btb/btb008za.i1 intprg\intbo009b.p YES}
        {btb/btb008za.i2 intprg\intbo009b.p '' {&hDBOSon1}} 
    END.
    
    RUN LinktoNota      IN {&hDBOSon1} (INPUT {&hDBOParent}) NO-ERROR.
    RUN openQueryStatic IN {&hDBOSon1} (INPUT "Cenario":U) NO-ERROR.


     /*:T--- Verifica se o DBO j  est  inicializado ---*/
    IF NOT VALID-HANDLE({&hDBOSon2}) THEN DO:
        {btb/btb008za.i1 intprg\intbo009c.p YES}
        {btb/btb008za.i2 intprg\intbo009c.p '' {&hDBOSon2}} 
    END.
    
    RUN LinktoNota      IN {&hDBOSon2} (INPUT {&hDBOParent}) NO-ERROR.
    RUN openQueryStatic IN {&hDBOSon2} (INPUT "Cenario":U) NO-ERROR.


     /*:T--- Verifica se o DBO j  est  inicializado ---*/
    IF NOT VALID-HANDLE({&hDBOSon3}) THEN DO:
        {btb/btb008za.i1 intprg\intbo009d.p YES}
        {btb/btb008za.i2 intprg\intbo009d.p '' {&hDBOSon3}} 
    END.
    
    RUN LinktoNota      IN {&hDBOSon3} (INPUT {&hDBOParent}) NO-ERROR.
    RUN openQueryStatic IN {&hDBOSon3} (INPUT "Cenario":U) NO-ERROR.
    
    RETURN "OK":U.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE openQueriesSon wMasterDetail 
PROCEDURE openQueriesSon :
/*:T------------------------------------------------------------------------------
  Purpose:     Atualiza browsers filhos
  Parameters:  
  Notes:       
------------------------------------------------------------------------------*/
    
    {masterdetail/openqueriesson.i &Parent="Cenario"
                                   &Query="Cenario"
                                   &PageNumber="1"}
                                   

    {masterdetail/openqueriesson.i &Parent="Cenario"
                                   &Query="Cenario"
                                   &PageNumber="2"}
                                   
    {masterdetail/openqueriesson.i &Parent="Cenario"
                                   &Query="Cenario"
                                   &PageNumber="3"}
    
    
    RETURN "OK":U.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-reposiciona-filho wMasterDetail 
PROCEDURE pi-reposiciona-filho :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    IF AVAIL tt-int-ds-cenario THEN
        RUN repositionRecord IN THIS-PROCEDURE (INPUT tt-int-ds-cenario.r-rowid).

    RETURN "ok".

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION fn-descEstab wMasterDetail 
FUNCTION fn-descEstab RETURNS CHARACTER
  ( c-cod-estabel AS char) :
/*------------------------------------------------------------------------------
  Purpose:  
    Notes:  
------------------------------------------------------------------------------*/
DEF VAR c-desc-estab AS CHAR.

 FIND FIRST estabelec NO-LOCK WHERE
            estabelec.cod-estabel = c-cod-estabel NO-ERROR.
 IF AVAIL estabelec THEN
    ASSIGN c-desc-estab = estabelec.nome.
 ELSE 
    ASSIGN c-desc-estab = "". 
                    
  RETURN c-desc-estab.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION fn-descFam wMasterDetail 
FUNCTION fn-descFam RETURNS CHARACTER
  ( c-fm-codigo AS char) :
/*------------------------------------------------------------------------------
  Purpose:  
    Notes:  
------------------------------------------------------------------------------*/
DEF VAR c-desc-fam AS CHAR.

 FIND FIRST familia NO-LOCK WHERE
            familia.fm-codigo = c-fm-codigo NO-ERROR.
 IF AVAIL familia THEN
    ASSIGN c-desc-fam = familia.descricao.
 ELSE 
    ASSIGN c-desc-fam = "". 
                    
  RETURN c-desc-fam.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION fn-descGrupo wMasterDetail 
FUNCTION fn-descGrupo RETURNS CHARACTER
  ( i-ge-codigo AS integer) :
/*------------------------------------------------------------------------------
  Purpose:  
    Notes:  
------------------------------------------------------------------------------*/
DEF VAR c-desc-grupo AS CHAR.

 FIND FIRST grup-estoq NO-LOCK WHERE
            grup-estoq.ge-codigo = i-ge-codigo NO-ERROR.
 IF AVAIL grup-estoq THEN
    ASSIGN c-desc-grupo = grup-estoq.descricao.
 ELSE 
    ASSIGN c-desc-grupo = "". 
                    
  RETURN c-desc-grupo.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION fn-Situacao wMasterDetail 
FUNCTION fn-Situacao RETURNS CHARACTER
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION fnCliente wMasterDetail 
FUNCTION fnCliente RETURNS CHARACTER
  ( i-emitente AS INTEGER ) :
/*------------------------------------------------------------------------------
  Purpose:  
    Notes:  
------------------------------------------------------------------------------*/

  FIND FIRST emitente NO-LOCK
       WHERE emitente.cod-emitente = i-emitente NO-ERROR.
  IF AVAIL emitente THEN
      RETURN emitente.nome-abrev.
  ELSE 
      RETURN "".

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION fnContrato wMasterDetail 
FUNCTION fnContrato RETURNS CHARACTER
  ( p-ts AS INTEGER , p-versao AS INTEGER /* parameter-definitions */ ) :
/*------------------------------------------------------------------------------
  Purpose:  
    Notes:  
------------------------------------------------------------------------------*/
 RETURN "".
   
  
END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION fnPedido wMasterDetail 
FUNCTION fnPedido RETURNS CHARACTER
  (p-ts AS INTEGER , p-versao AS INTEGER /* parameter-definitions */ ) :
/*------------------------------------------------------------------------------
  Purpose:  
    Notes:  
------------------------------------------------------------------------------*/

RETURN "".   /* Function return value. */

  

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION fnQuantidade wMasterDetail 
FUNCTION fnQuantidade RETURNS DECIMAL
  (p-ts AS INTEGER , p-versao AS INTEGER /* parameter-definitions */ ) :
/*------------------------------------------------------------------------------
  Purpose:  
    Notes:  
------------------------------------------------------------------------------*/

RETURN 0.00.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

