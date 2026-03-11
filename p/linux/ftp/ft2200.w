&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
          mov2emp          PROGRESS
*/
&Scoped-define WINDOW-NAME wReport


/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE tt-nota-fiscal NO-UNDO LIKE nota-fiscal
       field r-rowid as rowid.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS wReport 
/********************************************************************************
** Copyright DATASUL S.A. (1997)
** Todos os Direitos Reservados.
**
** Este fonte e de propriedade exclusiva da DATASUL, sua reproducao
** parcial ou total por qualquer meio, so podera ser feita mediante
** autorizacao expressa.
*******************************************************************************/
{include/i-prgvrs.i FT2200 2.00.01.020}  /*** 010120 ***/

&IF "{&EMSFND_VERSION}" >= "1.00" &THEN
    {include/i-license-manager.i ft2200 MFT}
&ENDIF

/********************************************************************************
** Copyright DATASUL S.A. (1999)
** Todos os Direitos Reservados.
**
** Este fonte e de propriedade exclusiva da DATASUL, sua reproducao
** parcial ou total por qualquer meio, so podera ser feita mediante
** autorizacao expressa.
*******************************************************************************/

CREATE WIDGET-POOL.

{cdp/cdcfgdis.i}

{cdp/cd0019.i MFT YES} /* inicializa‡Æo da seguran‡a por estabelecimento */

/* Preprocessors Definitions ---                                      */
&GLOBAL-DEFINE Program        FT2200
&GLOBAL-DEFINE Version        2.00.01.020

&GLOBAL-DEFINE Folder         YES
&GLOBAL-DEFINE InitialPage    1
&GLOBAL-DEFINE FolderLabels   Parƒmetro,ImpressÆo

&GLOBAL-DEFINE PGLAY          NO
&GLOBAL-DEFINE PGSEL          NO
&GLOBAL-DEFINE PGCLA          NO
&GLOBAL-DEFINE PGPAR          YES
&GLOBAL-DEFINE PGDIG          NO
&GLOBAL-DEFINE PGIMP          YES
&GLOBAL-DEFINE PGLOG          NO

&GLOBAL-DEFINE page0Widgets   btOk ~
                              btCancel ~
                              btHelp2

&if "{&bf_dis_versao_ems}":U >= "2.04":U &then
    &GLOBAL-DEFINE page4Widgets   tt-nota-fiscal.cod-estabel  ~
                                  tt-nota-fiscal.serie        ~
                                  tt-nota-fiscal.nr-nota-fis  ~
                                  tt-nota-fiscal.dt-cancela   ~
                                  tt-nota-fiscal.desc-cancela ~
                                  bt-valida                   ~
                                  c-arquivo                   ~
                                  bt-sea                      ~
                                  tb-valida-data-saida        ~
                                  rs-cancela-titulos          ~
                                  tb-ajuda
&else
    &GLOBAL-DEFINE page4Widgets   tt-nota-fiscal.cod-estabel  ~
                                  tt-nota-fiscal.serie        ~
                                  tt-nota-fiscal.nr-nota-fis  ~
                                  tt-nota-fiscal.dt-cancela   ~
                                  tt-nota-fiscal.desc-cancela ~
                                  bt-valida                   ~
                                  c-arquivo                   ~
                                  bt-sea                      ~
                                  tb-valida-data-saida        ~
                                  tb-ajuda
&endif

&GLOBAL-DEFINE page6Widgets   rsDestiny ~
                              btConfigImpr ~
                              btFile ~
                              rsExecution ~

&GLOBAL-DEFINE page0Text      
&GLOBAL-DEFINE page4Text      c-texto-1 c-texto-2
&GLOBAL-DEFINE page6Text      text-destino text-modo

&GLOBAL-DEFINE page4Fields    
&GLOBAL-DEFINE page6Fields    cFile

/* Parameters Definitions ---                                           */
define temp-table tt-param no-undo
    field destino           as integer
    field arquivo           as char format "x(35)"
    field usuario           as char format "x(12)"
    field data-exec         as date
    field hora-exec         as integer
    field cod-estabel       like nota-fiscal.cod-estabel
    field serie             like nota-fiscal.serie
    field nr-nota-fis       like nota-fiscal.nr-nota-fis
    field dt-cancela        like nota-fiscal.dt-cancela
    field desc-cancela      like nota-fiscal.desc-cancela
    field arquivo-estoq     as char
&IF '{&BF_DIS_VERSAO_EMS}' >= '2.03' &THEN
    field reabre-resumo     as logi
&ENDIF
&IF '{&BF_DIS_VERSAO_EMS}' >= '2.04' &THEN
    field cancela-titulos   as logi
&ENDIF
    field imprime-ajuda     as logi
    field l-valida-dt-saida as logi
    field l-elinia-nfse     as logical.

define temp-table tt-digita no-undo
    field ordem             as integer   format ">>>>9"
    field exemplo           as character format "x(30)"
    index id ordem.

define buffer b-tt-digita for tt-digita.

/* Transfer Definitions */

def var raw-param        as raw no-undo.

def temp-table tt-raw-digita NO-UNDO
   field raw-digita      as raw.

def var l-ok               as logical no-undo.
def var c-arq-digita       as char    no-undo.
def var c-terminal         as char    no-undo.
def var c-arq-layout       as char    no-undo.      
def var c-arq-temp         as char    no-undo.

def stream s-imp.

DEFINE NEW GLOBAL SHARED VARIABLE adm-broker-hdl AS HANDLE NO-UNDO.

DEFINE VARIABLE bo-cancela  AS HANDLE NO-UNDO.

DEFINE VARIABLE l-monitorNf-e AS LOGICAL  INIT NO          NO-UNDO.
DEFINE VARIABLE c-cod-estabel LIKE nota-fiscal.cod-estabel NO-UNDO.
DEFINE VARIABLE c-serie       LIKE nota-fiscal.serie       NO-UNDO.
DEFINE VARIABLE c-nr-nota-fis LIKE nota-fiscal.nr-nota-fis NO-UNDO.
DEFINE VARIABLE l-reabre          AS LOGICAL NO-UNDO.

def var c-nome-ab-cli as char no-undo.
def var dt-emis-nota  as date no-undo.

{utp/ut-glob.i}
DEFINE VARIABLE c-arquivo-usuar AS CHARACTER  NO-UNDO.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Window
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME fpage0

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS rtToolBar btOK btCancel btHelp2 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR wReport AS WIDGET-HANDLE NO-UNDO.

/* Definitions of the field level widgets                               */
DEFINE BUTTON btCancel 
     LABEL "Fechar" 
     SIZE 10 BY 1.

DEFINE BUTTON btHelp2 
     LABEL "Ajuda" 
     SIZE 10 BY 1.

DEFINE BUTTON btOK 
     LABEL "Executar" 
     SIZE 10 BY 1.

DEFINE RECTANGLE rtToolBar
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 90 BY 1.42
     BGCOLOR 7 .

DEFINE BUTTON bt-sea 
     IMAGE-UP FILE "image\im-sea":U
     LABEL "" 
     SIZE 4 BY 1.25.

DEFINE BUTTON bt-valida 
     IMAGE-UP FILE "image\im-enter":U
     LABEL "" 
     SIZE 4 BY .88 TOOLTIP "Valida a nota fiscal".

DEFINE VARIABLE c-arquivo AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 40 BY .88 NO-UNDO.

DEFINE VARIABLE c-texto-1 AS CHARACTER FORMAT "X(256)":U INITIAL "Arquivo Destino Atualiza‡Æo Estoque" 
      VIEW-AS TEXT 
     SIZE 26 BY .67 NO-UNDO.

DEFINE VARIABLE c-texto-2 AS CHARACTER FORMAT "X(256)":U INITIAL "Motivo Cancelamento" 
      VIEW-AS TEXT 
     SIZE 16 BY .67 NO-UNDO.

DEFINE RECTANGLE RECT-10
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 51 BY 3.29.

DEFINE RECTANGLE RECT-11
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 75 BY 4.75.

DEFINE RECTANGLE RECT-13
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 23 BY 3.29.

DEFINE VARIABLE rs-cancela-titulos AS LOGICAL INITIAL yes 
     LABEL "Cancela T¡tulos" 
     VIEW-AS TOGGLE-BOX
     SIZE 17 BY .83 NO-UNDO.

DEFINE VARIABLE rs-reabre AS LOGICAL INITIAL no 
     LABEL "Reabre Resumo" 
     VIEW-AS TOGGLE-BOX
     SIZE 17 BY .83 NO-UNDO.

DEFINE VARIABLE tb-ajuda AS LOGICAL INITIAL yes 
     LABEL "Imprime Ajuda das Msg" 
     VIEW-AS TOGGLE-BOX
     SIZE 19 BY .83 NO-UNDO.

DEFINE VARIABLE tb-valida-data-saida AS LOGICAL INITIAL yes 
     LABEL "Valida Data de Sa¡da?" 
     VIEW-AS TOGGLE-BOX
     SIZE 19.43 BY .83 NO-UNDO.

DEFINE BUTTON btConfigImpr 
     IMAGE-UP FILE "image\im-cfprt":U
     LABEL "" 
     SIZE 4 BY 1.

DEFINE BUTTON btFile 
     IMAGE-UP FILE "image\im-sea":U
     IMAGE-INSENSITIVE FILE "image\ii-sea":U
     LABEL "" 
     SIZE 4 BY 1.

DEFINE VARIABLE cFile AS CHARACTER 
     VIEW-AS EDITOR MAX-CHARS 256
     SIZE 40 BY .88
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE text-destino AS CHARACTER FORMAT "X(256)":U INITIAL " Destino" 
      VIEW-AS TEXT 
     SIZE 8.14 BY .63
     FONT 1 NO-UNDO.

DEFINE VARIABLE text-modo AS CHARACTER FORMAT "X(256)":U INITIAL "Execu‡Æo" 
      VIEW-AS TEXT 
     SIZE 10.86 BY .63
     FONT 1 NO-UNDO.

DEFINE VARIABLE rsDestiny AS INTEGER INITIAL 2 
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS 
          "Impressora", 1,
"Arquivo", 2,
"Terminal", 3
     SIZE 44 BY 1.08
     FONT 1 NO-UNDO.

DEFINE VARIABLE rsExecution AS INTEGER INITIAL 1 
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS 
          "On-Line", 1,
"Batch", 2
     SIZE 27.72 BY .92
     FONT 1 NO-UNDO.

DEFINE RECTANGLE RECT-7
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 46.29 BY 2.92.

DEFINE RECTANGLE RECT-9
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 46.29 BY 1.71.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME fpage0
     btOK AT ROW 16.75 COL 2
     btCancel AT ROW 16.75 COL 13
     btHelp2 AT ROW 16.75 COL 80
     rtToolBar AT ROW 16.54 COL 1
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 90 BY 17
         FONT 1.

DEFINE FRAME fPage4
     tt-nota-fiscal.dt-emis-nota AT ROW 3.5 COL 47.43 COLON-ALIGNED
          VIEW-AS FILL-IN 
          SIZE 10.14 BY .88
     tt-nota-fiscal.nome-ab-cli AT ROW 2.5 COL 47.43 COLON-ALIGNED
          VIEW-AS FILL-IN 
          SIZE 15.14 BY .88
     tt-nota-fiscal.cod-estabel AT ROW 1.5 COL 21 COLON-ALIGNED
          VIEW-AS FILL-IN 
          SIZE 6 BY .88
     tt-nota-fiscal.serie AT ROW 2.5 COL 21 COLON-ALIGNED
          VIEW-AS FILL-IN 
          SIZE 6 BY .88
     tt-nota-fiscal.nr-nota-fis AT ROW 3.5 COL 21 COLON-ALIGNED
          VIEW-AS FILL-IN 
          SIZE 13 BY .88
     tt-nota-fiscal.dt-cancela AT ROW 1.5 COL 47.43 COLON-ALIGNED
          VIEW-AS FILL-IN 
          SIZE 9.86 BY .88
     bt-valida AT ROW 3.54 COL 59.72
     tt-nota-fiscal.desc-cancela AT ROW 5.63 COL 2.86 NO-LABEL
          VIEW-AS EDITOR SCROLLBAR-VERTICAL
          SIZE 73 BY 4
     c-arquivo AT ROW 11.67 COL 3.86 COLON-ALIGNED NO-LABEL
     bt-sea AT ROW 11.42 COL 46.86
     tb-ajuda AT ROW 10.46 COL 57
     rs-reabre AT ROW 11.92 COL 57
     tb-valida-data-saida AT ROW 11.17 COL 57
     c-texto-2 AT ROW 4.88 COL 2 COLON-ALIGNED NO-LABEL
     c-texto-1 AT ROW 10.08 COL 2 COLON-ALIGNED NO-LABEL
     rs-cancela-titulos AT ROW 12.67 COL 57 WIDGET-ID 2
     RECT-10 AT ROW 10.33 COL 2
     RECT-11 AT ROW 5.13 COL 2
     RECT-13 AT ROW 10.33 COL 54
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 7 ROW 2.25
         SIZE 76.86 BY 13.67
         FONT 1.

DEFINE FRAME fPage6
     rsDestiny AT ROW 2.38 COL 3.29 HELP
          "Destino de ImpressÆo do Relat¢rio" NO-LABEL
     btFile AT ROW 3.58 COL 43.29 HELP
          "Escolha do nome do arquivo"
     btConfigImpr AT ROW 3.58 COL 43.29 HELP
          "Configura‡Æo da impressora"
     cFile AT ROW 3.63 COL 3.29 HELP
          "Nome do arquivo de destino do relat¢rio" NO-LABEL
     rsExecution AT ROW 5.75 COL 3 HELP
          "Modo de Execu‡Æo" NO-LABEL
     text-destino AT ROW 1.63 COL 1.86 COLON-ALIGNED NO-LABEL
     text-modo AT ROW 5 COL 1.29 COLON-ALIGNED NO-LABEL
     RECT-7 AT ROW 1.92 COL 2.14
     RECT-9 AT ROW 5.29 COL 2.14
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 7 ROW 2.79
         SIZE 76.86 BY 11.96
         FONT 1.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Window
   Other Settings: COMPILE
   Temp-Tables and Buffers:
      TABLE: tt-nota-fiscal T "?" NO-UNDO mov2emp nota-fiscal
      ADDITIONAL-FIELDS:
          field r-rowid as rowid
      END-FIELDS.
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
IF SESSION:DISPLAY-TYPE = "GUI":U THEN
  CREATE WINDOW wReport ASSIGN
         HIDDEN             = YES
         TITLE              = ""
         HEIGHT             = 17
         WIDTH              = 90
         MAX-HEIGHT         = 22
         MAX-WIDTH          = 114.29
         VIRTUAL-HEIGHT     = 22
         VIRTUAL-WIDTH      = 114.29
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
/* END WINDOW DEFINITION                                                */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _INCLUDED-LIB wReport 
/* ************************* Included-Libraries *********************** */

{report/report.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME




/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW wReport
  NOT-VISIBLE,,RUN-PERSISTENT                                           */
/* REPARENT FRAME */
ASSIGN FRAME fPage4:FRAME = FRAME fpage0:HANDLE
       FRAME fPage6:FRAME = FRAME fpage0:HANDLE.

/* SETTINGS FOR FRAME fpage0
   NOT-VISIBLE FRAME-NAME                                               */
/* SETTINGS FOR FRAME fPage4
   Custom                                                               */
/* SETTINGS FOR FRAME fPage6
                                                                        */
ASSIGN 
       text-destino:PRIVATE-DATA IN FRAME fPage6     = 
                "Destino".

ASSIGN 
       text-modo:PRIVATE-DATA IN FRAME fPage6     = 
                "Execu‡Æo".

IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(wReport)
THEN wReport:HIDDEN = yes.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK FRAME fpage0
/* Query rebuild information for FRAME fpage0
     _Options          = "SHARE-LOCK KEEP-EMPTY"
     _Query            is NOT OPENED
*/  /* FRAME fpage0 */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK FRAME fPage4
/* Query rebuild information for FRAME fPage4
     _Query            is NOT OPENED
*/  /* FRAME fPage4 */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK FRAME fPage6
/* Query rebuild information for FRAME fPage6
     _Query            is NOT OPENED
*/  /* FRAME fPage6 */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME wReport
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL wReport wReport
ON END-ERROR OF wReport
OR ENDKEY OF {&WINDOW-NAME} ANYWHERE DO:
  /* This case occurs when the user presses the "Esc" key.
     In a persistently run window, just ignore this.  If we did not, the
     application would exit. */
  IF THIS-PROCEDURE:PERSISTENT THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL wReport wReport
ON WINDOW-CLOSE OF wReport
DO:
  /* This event will close the window and terminate the procedure.  */
  {report/logfin.i}  
  APPLY "CLOSE":U TO THIS-PROCEDURE.
  RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME fPage4
&Scoped-define SELF-NAME bt-sea
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-sea wReport
ON CHOOSE OF bt-sea IN FRAME fPage4
DO:
    DEFINE VARIABLE c-aux AS CHARACTER NO-UNDO.
    DEFINE VARIABLE l-ok  AS LOGICAL   NO-UNDO.

    SYSTEM-DIALOG GET-FILE c-aux
        FILTERS    "Arquivo Listagem (*.lst)" "*.lst",
                   "Arquivo Texto (*.txt)" "*.txt",
                   "Todos Arquivos (*.*)"   "*.*"
        ASK-OVERWRITE CREATE-TEST-FILE
        DEFAULT-EXTENSION ".lst"
        SAVE-AS TITLE "Salvar Como"
        UPDATE l-ok.

    IF  l-ok THEN
        ASSIGN c-arquivo:SCREEN-VALUE IN FRAME fPage4 = c-aux.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-valida
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-valida wReport
ON CHOOSE OF bt-valida IN FRAME fPage4
DO:
    DEFINE VARIABLE l-valida-dt-saida AS LOGICAL NO-UNDO.

    IF  NOT VALID-HANDLE(bo-cancela) THEN DO:
        RUN dibo/bodi135cancel.p PERSISTENT SET bo-cancela.
    END.

    RUN emptyRowErrors IN bo-cancela.

    IF  rs-reabre:SENSITIVE THEN
        ASSIGN l-reabre = INPUT rs-reabre.
    
    ASSIGN l-valida-dt-saida = INPUT tb-valida-data-saida.

    RUN validaNotaFiscal IN bo-cancela (INPUT INPUT tt-nota-fiscal.cod-estabel,
                                        INPUT INPUT tt-nota-fiscal.serie,
                                        INPUT INPUT tt-nota-fiscal.nr-nota-fis,
                                        INPUT INPUT tt-nota-fiscal.dt-cancela,
                                        INPUT INPUT tt-nota-fiscal.desc-cancela,
                                        INPUT l-valida-dt-saida
                                        &IF '{&BF_DIS_VERSAO_EMS}' >= '2.03' &THEN
                                            ,
                                            INPUT l-reabre
                                        &ENDIF
                                        &IF '{&BF_DIS_VERSAO_EMS}' >= '2.04' &THEN
                                            ,
                                            input frame fPage4 rs-cancela-titulos
                                        &ENDIF
                                        ).

    RUN getRowErrors IN bo-cancela (OUTPUT TABLE RowErrors).

    RUN destroy IN bo-cancela .

    IF  CAN-FIND(FIRST RowErrors) THEN DO:
        {method/showmessage.i1}
        {method/showmessage.i2}
    END.
    ELSE
        RUN utp/ut-msgs.p ('SHOW':U, 19442, '':U).


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME fpage0
&Scoped-define SELF-NAME btCancel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btCancel wReport
ON CHOOSE OF btCancel IN FRAME fpage0 /* Fechar */
DO:
    APPLY "CLOSE":U TO THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME fPage6
&Scoped-define SELF-NAME btConfigImpr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btConfigImpr wReport
ON CHOOSE OF btConfigImpr IN FRAME fPage6
DO:
   {report/rpimp.i}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btFile
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btFile wReport
ON CHOOSE OF btFile IN FRAME fPage6
DO:
    {report/rparq.i}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME fpage0
&Scoped-define SELF-NAME btHelp2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btHelp2 wReport
ON CHOOSE OF btHelp2 IN FRAME fpage0 /* Ajuda */
DO:
    {include/ajuda.i}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btOK
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btOK wReport
ON CHOOSE OF btOK IN FRAME fpage0 /* Executar */
DO:
   do  on error undo, leave:
        run piExecute.
        if not l-reabre then do:
            for first nota-fiscal 
                fields (nr-pedcli idi-sit-nf-eletro)
                no-lock where 
                nota-fiscal.cod-estabel = tt-nota-fiscal.cod-estabel :screen-value in frame fPage4 and
                nota-fiscal.serie       = tt-nota-fiscal.serie       :screen-value in frame fPage4 and
                nota-fiscal.nr-nota-fis = tt-nota-fiscal.nr-nota-fis :screen-value in frame fPage4:
    
                if  nota-fiscal.nr-pedcli <> "" and (
                    nota-fiscal.idi-sit-nf-eletro = 12 or
                    nota-fiscal.idi-sit-nf-eletro = 13) then do:
                    for first int_ds_pedido where
                        int_ds_pedido.ped_codigo_n = int64(nota-fiscal.nr-pedcli):
    
                        assign int_ds_pedido.situacao = 3.
    
                    end.
                    if not avail int_ds_pedido then
                    for first int_ds_pedido_subs where
                        int_ds_pedido_subs.ped_codigo_n = int(nota-fiscal.nr-pedcli):
    
                        assign int_ds_pedido_subs.situacao = 3.
    
                    end.
                end.
            end.
        end.
   end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME fPage4
&Scoped-define SELF-NAME tt-nota-fiscal.cod-estabel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-nota-fiscal.cod-estabel wReport
ON F5 OF tt-nota-fiscal.cod-estabel IN FRAME fPage4 /* Estabelecimento */
DO:
    {include/zoomvar.i &prog-zoom="adzoom/z01ad107.w"
                       &campo="tt-nota-fiscal.cod-estabel"
                       &campozoom="cod-estabel"
                       &frame="fPage4"}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-nota-fiscal.cod-estabel wReport
ON LEAVE OF tt-nota-fiscal.cod-estabel IN FRAME fPage4 /* Estabelecimento */
DO:
    RUN piCliData IN THIS-PROCEDURE.

    RETURN "OK":U.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-nota-fiscal.cod-estabel wReport
ON MOUSE-SELECT-DBLCLICK OF tt-nota-fiscal.cod-estabel IN FRAME fPage4 /* Estabelecimento */
DO:
    APPLY 'F5':U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-nota-fiscal.nr-nota-fis
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-nota-fiscal.nr-nota-fis wReport
ON F5 OF tt-nota-fiscal.nr-nota-fis IN FRAME fPage4 /* Nr Nota Fiscal */
DO:
    {include/zoomvar.i &prog-zoom="dizoom/z03di135.w"
                       &campo="tt-nota-fiscal.nr-nota-fis"
                       &campozoom="nr-nota-fis"
                       &frame="fPage4"
                       &campo2="tt-nota-fiscal.serie"
                       &campozoom2="serie"
                       &frame2="fPage4"
                       &campo3="tt-nota-fiscal.cod-estabel"
                       &campozoom3="cod-estabel"
                       &frame3="fPage4"
                       &campo4="tt-nota-fiscal.nome-ab-cli"
                       &campozoom4="nome-ab-cli"
                       &frame4="fPage4"
                       &campo5="tt-nota-fiscal.dt-emis-nota"
                       &campozoom5="dt-emis-nota"
                       &frame5="fPage4"}

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-nota-fiscal.nr-nota-fis wReport
ON LEAVE OF tt-nota-fiscal.nr-nota-fis IN FRAME fPage4 /* Nr Nota Fiscal */
DO:

    RUN piCliData IN THIS-PROCEDURE.

    RETURN "OK":U.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-nota-fiscal.nr-nota-fis wReport
ON MOUSE-SELECT-DBLCLICK OF tt-nota-fiscal.nr-nota-fis IN FRAME fPage4 /* Nr Nota Fiscal */
DO:
    APPLY 'F5':U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME fPage6
&Scoped-define SELF-NAME rsDestiny
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL rsDestiny wReport
ON VALUE-CHANGED OF rsDestiny IN FRAME fPage6
DO:
do  with frame fPage6:
    case self:screen-value:
        when "1" then do:
            assign cFile:sensitive       = no
                   cFile:visible         = yes
                   btFile:visible        = no
                   btConfigImpr:visible  = yes.
        end.
        when "2" then do:
            assign cFile:sensitive       = yes
                   cFile:visible         = yes
                   btFile:visible        = yes
                   btConfigImpr:visible  = no.
        end.
        when "3" then do:
            assign cFile:visible         = no
                   cFile:sensitive       = no
                   btFile:visible        = no
                   btConfigImpr:visible  = no.
        end.
    end case.
end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME rsExecution
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL rsExecution wReport
ON VALUE-CHANGED OF rsExecution IN FRAME fPage6
DO:
   {report/rprse.i}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME fPage4
&Scoped-define SELF-NAME tt-nota-fiscal.serie
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-nota-fiscal.serie wReport
ON F5 OF tt-nota-fiscal.serie IN FRAME fPage4 /* S‚rie */
DO:
    {include/zoomvar.i &prog-zoom="inzoom/z03in407.w"
                       &campo="tt-nota-fiscal.serie"
                       &campozoom="serie"
                       &frame="fPage4"}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-nota-fiscal.serie wReport
ON LEAVE OF tt-nota-fiscal.serie IN FRAME fPage4 /* S‚rie */
DO:
    RUN piCliData IN THIS-PROCEDURE.

    RETURN "OK":U.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-nota-fiscal.serie wReport
ON MOUSE-SELECT-DBLCLICK OF tt-nota-fiscal.serie IN FRAME fPage4 /* S‚rie */
DO:
    APPLY 'F5':U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME fpage0
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK wReport 


/*--- L¢gica para inicializa‡Æo do programam ---*/
{report/mainblock.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE afterDestroyInterface wReport 
PROCEDURE afterDestroyInterface :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    /*{cdp/cd0019.i1} /* finaliza‡Æo da seguran‡a por estabelecimento */*/

    /*{method/showmessage.i3}*/

    RETURN "OK".

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE afterInitializeInterface wReport 
PROCEDURE afterInitializeInterface :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    IF l-monitorNf-e THEN
        RUN pi-setaNf-eMonitor.

    FIND FIRST para-fat NO-LOCK NO-ERROR.

    tt-nota-fiscal.cod-estabel:load-mouse-pointer('image/lupa.cur':U) IN FRAME fPage4.
    tt-nota-fiscal.serie:load-mouse-pointer('image/lupa.cur':U)       IN FRAME fPage4.
    tt-nota-fiscal.nr-nota-fis:load-mouse-pointer('image/lupa.cur':U) IN FRAME fPage4.

    ASSIGN tb-ajuda:CHECKED                       IN FRAME fPage4 = YES 
           c-arquivo:SCREEN-VALUE                 IN FRAME fPage4 = session:temp-directory + "FT2100.LST":U
           rsDestiny:SCREEN-VALUE                 IN FRAME fPage6 = '3':U
           tt-nota-fiscal.dt-cancela:SCREEN-VALUE IN FRAME fPage4 = STRING(TODAY, '99/99/9999':U).

    find usuar_mestre where 
        usuar_mestre.cod_usuario = c-seg-usuario 
        no-lock no-error.
    if avail usuar_mestre then DO:
        assign c-arquivo-usuar = if length(usuar_mestre.nom_subdir_spool) <> 0
                                 then caps(replace(usuar_mestre.nom_dir_spool, " ", "~/") + "~/" + replace(usuar_mestre.nom_subdir_spool, " ", "~/")) 
                                 else caps(replace(usuar_mestre.nom_dir_spool, " ", "~/"))  .
        ASSIGN c-arquivo:SCREEN-VALUE IN FRAME fPage4 = c-arquivo-usuar + "/FT2100.LST":U.
    END.

    &IF '{&BF_DIS_VERSAO_EMS}' >= '2.03' &THEN
    
        &IF "{&BF_DIS_VERSAO_EMS}":U < "2.062":U &THEN
            IF CAN-FIND(FIRST funcao
                WHERE funcao.cd-funcao = 'spp-sgt':U
                AND   funcao.ativo = TRUE NO-LOCK) 
            THEN ASSIGN l-eq-log-reabre-resum = NO.
            ELSE  IF  AVAIL para-fat 
                  THEN ASSIGN l-eq-log-reabre-resum = (SUBSTRING(para-fat.char-2, 41, 1) = "Y":U)
                              rs-reabre:CHECKED   IN FRAME fPage4 = l-eq-log-reabre-resum.
        &ENDIF

        FIND FIRST user-coml
             WHERE user-coml.usuario = c-seg-usuario NO-LOCK NO-ERROR.

        ASSIGN rs-reabre:SENSITIVE IN FRAME fPage4 = (AVAILABLE(user-coml) AND
                                                     (SUBSTRING(user-coml.char-1, 14, 1) = "Y":U)).
    &ELSE
        ASSIGN rs-reabre:HIDDEN IN FRAME fPage4 = YES.
    &ENDIF
    
    APPLY "VALUE-CHANGED" TO rsDestiny IN FRAME fPage6. 

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE beforeInitializeInterface wReport 
PROCEDURE beforeInitializeInterface :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/


    CREATE tt-nota-fiscal.
    ASSIGN tt-nota-fiscal.serie = "".
    /* L¢gica para esconder o check Reabre Resumo */
    IF CAN-FIND(FIRST funcao
                WHERE funcao.cd-funcao = 'spp-sgt':U
                AND   funcao.ativo = TRUE NO-LOCK) THEN ASSIGN rs-reabre:SENSITIVE IN FRAME fPage4 = NO
                                                               rs-reabre:VISIBLE   IN FRAME fpage4 = NO.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-monitor wReport 
PROCEDURE pi-monitor :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
DEF INPUT PARAM p-cod-estabel LIKE nota-fiscal.cod-estabel NO-UNDO.
DEF INPUT PARAM p-serie       LIKE nota-fiscal.serie       NO-UNDO.
DEF INPUT PARAM p-nr-nota-fis LIKE nota-fiscal.nr-nota-fis NO-UNDO.
DEF INPUT PARAM pl-monitor    AS LOG                       NO-UNDO.

ASSIGN l-monitorNf-e = pl-monitor
       c-cod-estabel = p-cod-estabel  
       c-serie       = p-serie        
       c-nr-nota-fis = p-nr-nota-fis. 

RETURN "OK":U.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-setaNf-eMonitor wReport 
PROCEDURE pi-setaNf-eMonitor :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    ASSIGN tt-nota-fiscal.cod-estabel:SCREEN-VALUE IN FRAME fPage4 = c-cod-estabel 
           tt-nota-fiscal.serie      :SCREEN-VALUE IN FRAME fPage4 = c-serie       
           tt-nota-fiscal.nr-nota-fis:SCREEN-VALUE IN FRAME fPage4 = c-nr-nota-fis. 

RETURN "OK":U.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE piCliData wReport 
PROCEDURE piCliData :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

&IF "{&bf_dis_versao_ems}" >= "2.04" &THEN
    DEF VAR c-nr-proc-exp LIKE nota-fiscal.nr-proc-exp NO-UNDO.
&ENDIF

    ASSIGN tt-nota-fiscal.nome-ab-cli:screen-value  IN FRAME fPage4 = ""
           tt-nota-fiscal.dt-emis-nota:screen-value IN FRAME fPage4 = "" .

    IF  tt-nota-fiscal.nr-nota-fis:SCREEN-VALUE IN FRAME fPage4 <> "" THEN DO:

        FOR FIRST nota-fiscal FIELDS (nome-ab-cli dt-emis-nota nr-proc-exp)  NO-LOCK
            WHERE nota-fiscal.cod-estabel = input frame fPage4 tt-nota-fiscal.cod-estabel
            AND   nota-fiscal.serie       = input frame fPage4 tt-nota-fiscal.serie
            AND   nota-fiscal.nr-nota-fis = input frame fPage4 tt-nota-fiscal.nr-nota-fis: END.
    
        IF  AVAIL nota-fiscal THEN DO:
    
            ASSIGN tt-nota-fiscal.nome-ab-cli:screen-value  = nota-fiscal.nome-ab-cli
                   tt-nota-fiscal.dt-emis-nota:screen-value = string(nota-fiscal.dt-emis-nota).
    
            &IF "{&bf_dis_versao_ems}" >= "2.04" &THEN                 
                IF  (nota-fiscal.nr-proc-exp <> "" AND 
                     AVAIL para-fat      AND 
                     para-fat.ind-docum-fatura  = 2)
                OR   (AVAIL para-fat     AND
                      para-fat.ind-pro-fat)
                OR  CAN-FIND(FIRST funcao   /* Fechamento de Duplicatas por Pedido */
                             WHERE funcao.cd-funcao = "spp-FechaDuplic"
                               AND funcao.ativo) THEN
                    ASSIGN rs-cancela-titulos:SENSITIVE IN FRAME fPage4 = NO
                           rs-cancela-titulos:CHECKED   IN FRAME fPage4 = NO.
                ELSE
                    ASSIGN rs-cancela-titulos:SENSITIVE IN FRAME fPage4 = YES.
            &ENDIF
                    
        END.
    END.

    RETURN "OK".

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE piExecute wReport 
PROCEDURE piExecute :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

define var r-tt-digita as rowid no-undo.

DEFINE VARIABLE l-valida-dt-saida AS LOGICAL NO-UNDO.

do on error undo, return error on stop  undo, return error:
    {report/rpexa.i}

    if input frame fPage6 rsExecution = 1 then do:
        assign c-arq-aux = input frame fPage4 c-arquivo
               c-arq-aux = replace(c-arq-aux, "/":U, "~\":U).
        if  r-index(c-arq-aux, "~\":U) > 0 then do:
            assign file-info:file-name = substring(c-arq-aux,1,r-index(c-arq-aux, "~\":U)).
            if  file-info:full-pathname = ? or not file-info:file-type matches "*D*":U then do:
                run utp/ut-msgs.p (input "show":U, 
                                   input 5749, 
                                   input "").
                apply 'entry':U to cFile in frame fPage6.
                return error.
            end.
        end.

        assign file-info:file-name = c-arq-aux.
        if file-info:file-type matches "*D*":U 
        OR c-arq-aux = "" then do:
            run utp/ut-msgs.p (input "show":U, 
                               input 73, 
                               input "").
            apply 'entry':U to cFile in frame fPage6.
            return error.
        end.
    end.

    /* Coloque aqui as valida‡äes da p gina de Digita‡Æo, lembrando que elas devem
       apresentar uma mensagem de erro cadastrada, posicionar nesta p gina e colocar
       o focus no campo com problemas */
    /*browse brDigita:SET-REPOSITIONED-ROW (browse brDigita:DOWN, "ALWAYS":U).*/

    /* Coloque aqui as valida‡äes das outras p ginas, lembrando que elas devem 
       apresentar uma mensagem de erro cadastrada, posicionar na p gina com 
       problemas e colocar o focus no campo com problemas */

    /************** CHAMADA EPC VALE ********************/
      /*{cdp/cd9995.i "Executa" return error} */


    /* Aqui sÆo gravados os campos da temp-table que ser  passada como parƒmetro
       para o programa RP.P */

    IF  rs-reabre:SENSITIVE IN FRAME fPage4 THEN
        ASSIGN l-reabre = INPUT FRAME fPage4 rs-reabre.
    
    ASSIGN l-valida-dt-saida = INPUT FRAME fpage4 tb-valida-data-saida.

    create tt-param.
    assign tt-param.usuario             = c-seg-usuario
           tt-param.destino             = input frame fPage6 rsDestiny
           tt-param.data-exec           = today
           tt-param.hora-exec           = time
           tt-param.cod-estabel         = INPUT FRAME fPage4 tt-nota-fiscal.cod-estabel
           tt-param.serie               = INPUT FRAME fPage4 tt-nota-fiscal.serie
           tt-param.nr-nota-fis         = INPUT FRAME fPage4 tt-nota-fiscal.nr-nota-fis
           tt-param.dt-cancela          = INPUT FRAME fPage4 tt-nota-fiscal.dt-cancela
           tt-param.desc-cancela        = INPUT FRAME fPage4 tt-nota-fiscal.desc-cancela
           tt-param.arquivo-estoq       = INPUT FRAME fPage4 c-arquivo
               tt-param.reabre-resumo   = l-reabre
               tt-param.cancela-titulos = INPUT FRAME fPage4 rs-cancela-titulos
           tt-param.imprime-ajuda       = INPUT FRAME fPage4 tb-ajuda
           tt-param.l-valida-dt-saida   = l-valida-dt-saida.

        /* Integra‡Æo SGT */
    &if '{&bf_dis_sgt}' = 'yes' &then
        if  can-find(first funcao
                     where funcao.cd-funcao = 'spp-sgt':U
                     and   funcao.ativo     = true) then assign tt-param.reabre-resumo = no.
    &endif

    if tt-param.destino = 1 
    then assign tt-param.arquivo = "".
    else if  tt-param.destino = 2 
         then assign tt-param.arquivo = input frame fPage6 cFile.
         else assign tt-param.arquivo = session:temp-directory + c-programa-mg97 + ".tmp".

    /* Coloque aqui a l¢gica de grava‡Æo dos demais campos que devem ser passados
       como parƒmetros para o programa RP.P, atrav‚s da temp-table tt-param */

    /* Executar do programa RP.P que ir  criar o relat¢rio */
    {report/rpexb.i}

    SESSION:SET-WAIT-STATE("general":U).

    {report/rprun.i ftp/ft2200rp.p}

    {report/rpexc.i}

    SESSION:SET-WAIT-STATE("":U).

    {report/rptrm.i}
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

