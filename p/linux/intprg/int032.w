&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
          emsesp           ORACLE
*/
&Scoped-define WINDOW-NAME wWindow


/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE tt-int_ds_prog_rpw NO-UNDO LIKE int_ds_prog_rpw
       field r-rowid as rowid.
DEFINE TEMP-TABLE tt-ped_exec NO-UNDO LIKE ped_exec
       field r-rowid as rowid.
DEFINE TEMP-TABLE tt-ped_exec_hist NO-UNDO LIKE ped_exec
       field r-rowid as rowid
       field desc-prog like int_ds_prog_rpw.desc_prog
       index ordem
       cod_prog_dtsul
       cod_servid_exec
       num_ped_exec DESC
       dat_inic_exec_servid_exec
       hra_inic_exec_servid_exec.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS wWindow 
/********************************************************************************
** Copyright DATASUL S.A. (1999)
** Todos os Direitos Reservados.
**
** Este fonte e de propriedade exclusiva da DATASUL, sua reproducao
** parcial ou total por qualquer meio, so podera ser feita mediante
** autorizacao expressa.
*******************************************************************************/
/********************************************************************************
** Programa: int030 - Monitor de Agendamento RPW
**
** Versao : 12 - 07/04/2016 - Alessandro V Baccin
**
********************************************************************************/
{include/i-prgvrs.i INT032 2.12.02.AVB}

CREATE WIDGET-POOL.

/* Preprocessors Definitions ---                                      */
&GLOBAL-DEFINE Program        INT032
&GLOBAL-DEFINE Version        2.12.02.AVB

&GLOBAL-DEFINE WindowType     Master

&GLOBAL-DEFINE Folder         YES
&GLOBAL-DEFINE InitialPage    1
&GLOBAL-DEFINE FolderLabels   Programas, Execu‡äes

&GLOBAL-DEFINE page0Widgets   btQueryJoins btReportsJoins btExit btHelp ~
                              btOK btCancel btHelp2 btSelecao c-intervalo btAtualiza rs-ordena rs-consulta

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */
DEF VAR d-dt-ocorrencia-ini                 LIKE int_ds_log.dt_ocorrencia    INITIAL TODAY NO-UNDO.
DEF VAR d-dt-ocorrencia-fim                 LIKE int_ds_log.dt_ocorrencia    INITIAL TODAY NO-UNDO.
DEF VAR c-origem-ini                        LIKE int_ds_prog_rpw.cod_prog    INITIAL "" NO-UNDO.
DEF VAR c-origem-fim                        LIKE int_ds_prog_rpw.cod_prog    INITIAL "ZZZZZZZZZZZZZZZ" NO-UNDO.
DEF VAR c-hora-ini                          as character initial "000000" no-undo.
DEF VAR c-hora-fim                          as character initial "235959" no-undo.
DEF VAR i-situacao                          as integer initial 0 no-undo.
DEF VAR c-ultimosMov                        AS INTEGER INITIAL 10 NO-UNDO.

DEFINE VARIABLE i-movimentos                AS INTEGER     NO-UNDO.  /* contar movimentos historico de pedidos */
DEFINE VARIABLE l-movComErro AS LOGICAL     NO-UNDO.

def temp-table tt-raw-digita NO-UNDO field raw-digita  as raw.

define temp-table tt-param no-undo
    field destino          as integer
    field arquivo          as char format "x(35)"
    field usuario          as char format "x(12)"
    field data-exec        as date
    field hora-exec        as integer
    field classifica       as integer
    field desc-classifica  as char format "x(40)".

define temp-table tt-param-int011-l no-undo
    field destino          as integer
    field arquivo          as char format "x(35)"
    field usuario          as char format "x(12)"
    field data-exec        as date
    field hora-exec        as integer
    field classifica       as integer
    field desc-classifica  as char format "x(40)"
    field cod-estabel-ini  as char format "x(5)"
    field cod-estabel-fim  as char format "x(5)"
    field dt-cancela-ini   as date format "99/99/9999"
    field dt-cancela-fim   as date format "99/99/9999"
    field dt-emis-nota-ini as date format "99/99/9999"
    field dt-emis-nota-fim as date format "99/99/9999".

define temp-table tt-param-int011-c no-undo
    field destino          as integer
    field arquivo          as char format "x(35)"
    field usuario          as char format "x(12)"
    field data-exec        as date
    field hora-exec        as integer
    field classifica       as integer
    field desc-classifica  as char format "x(40)"
    field cod-estabel-ini  as char format "x(5)"
    field cod-estabel-fim  as char format "x(5)"
    field dt-cancela-ini   as date format "99/99/9999"
    field dt-cancela-fim   as date format "99/99/9999"
    field dt-emis-nota-ini as date format "99/99/9999"
    field dt-emis-nota-fim as date format "99/99/9999".

define temp-table tt-param-int110 no-undo
    field destino          as integer
    field arquivo          as char format "x(35)"
    field usuario          as char format "x(12)"
    field data-exec        as date
    field hora-exec        as integer
    field classifica       as integer
    field desc-classifica  as char format "x(40)"
    field serie            as char.      

define temp-table tt-param-int012 no-undo
    field destino          as integer
    field arquivo          as char format "x(35)"
    field usuario          as char format "x(12)"
    field data-exec        as date
    field hora-exec        as integer
    field classifica       as integer
    field desc-classifica  as char format "x(40)"
    field cod-emitente-fim as integer
    field cod-emitente-ini as integer
    field cod-estabel-fim  as char
    field cod-estabel-ini  as char
    field dt-emis-nota-fim as date
    field dt-emis-nota-ini as date
    field nro-docto-fim    as integer
    field nro-docto-ini    as integer
    field serie-docto-fim  as char
    field serie-docto-ini  as char.

define temp-table tt-param-int052 no-undo
    field destino          as integer
    field arquivo          as char format "x(45)"
    field usuario          as char format "x(12)"
    field data-exec        as date
    field hora-exec        as integer
    field classifica       as integer
    field desc-classifica  as char format "x(40)"
    field cod-emitente-fim as integer
    field cod-emitente-ini as integer
    field cod-estabel-fim  as char
    field cod-estabel-ini  as char
    field dt-emis-nota-fim as date
    field dt-emis-nota-ini as date
    field nro-docto-fim    as char
    field nro-docto-ini    as char
    field serie-docto-fim  as char
    field serie-docto-ini  as char.

define temp-table tt-param-int042 no-undo
    field destino          as integer
    field arquivo          as char format "x(35)"
    field usuario          as char format "x(12)"
    field data-exec        as date
    field hora-exec        as integer
    field classifica       as integer
    field desc-classifica  as char format "x(40)"
    field cod-emitente-fim as integer
    field cod-emitente-ini as integer
    field cod-estabel-fim  as char
    field cod-estabel-ini  as char
    field dt-emis-nota-fim as date
    field dt-emis-nota-ini as date
    field nro-docto-fim    as integer
    field nro-docto-ini    as integer
    field serie-docto-fim  as char
    field serie-docto-ini  as char.

def var raw-param          as raw no-undo.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Window
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME fpage0
&Scoped-define BROWSE-NAME Br-prog

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-int_ds_prog_rpw tt-ped_exec ~
tt-ped_exec_hist

/* Definitions for BROWSE Br-prog                                       */
&Scoped-define FIELDS-IN-QUERY-Br-prog tt-int_ds_prog_rpw.cod-prog tt-int_ds_prog_rpw.desc-prog tt-int_ds_prog_rpw.nome-ext tt-ped_exec.num_ped_exec tt-ped_exec.cod_servid_exec tt-ped_exec.ind_sit_ped_exec tt-ped_exec.dat_criac_ped_exec tt-ped_exec.dat_exec_ped_exec tt-ped_exec.hra_exec_ped_exec tt-ped_exec.dat_inic_exec_servid_exec tt-ped_exec.hra_inic_exec_servid_exec tt-ped_exec.hra_fim_exec_servid_exec tt-ped_exec.des_text_erro   
&Scoped-define ENABLED-FIELDS-IN-QUERY-Br-prog   
&Scoped-define SELF-NAME Br-prog
&Scoped-define QUERY-STRING-Br-prog FOR EACH tt-int_ds_prog_rpw NO-LOCK , ~
           EACH tt-ped_exec WHERE tt-ped_exec.cod_prog_dtsul = tt-int_ds_prog_rpw.cod-prog INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-Br-prog OPEN QUERY {&SELF-NAME} FOR EACH tt-int_ds_prog_rpw NO-LOCK , ~
           EACH tt-ped_exec WHERE tt-ped_exec.cod_prog_dtsul = tt-int_ds_prog_rpw.cod-prog INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-Br-prog tt-int_ds_prog_rpw tt-ped_exec
&Scoped-define FIRST-TABLE-IN-QUERY-Br-prog tt-int_ds_prog_rpw
&Scoped-define SECOND-TABLE-IN-QUERY-Br-prog tt-ped_exec


/* Definitions for BROWSE brPedexec                                     */
&Scoped-define FIELDS-IN-QUERY-brPedexec tt-ped_exec_hist.cod_prog_dtsul tt-ped_exec_hist.desc-prog tt-ped_exec_hist.num_ped_exec tt-ped_exec_hist.cod_servid_exec tt-ped_exec_hist.ind_sit_ped_exec tt-ped_exec_hist.dat_exec_ped_exec tt-ped_exec_hist.hra_exec_ped_exec tt-ped_exec_hist.dat_inic_exec_servid_exec tt-ped_exec_hist.hra_inic_exec_servid_exec tt-ped_exec_hist.hra_fim_exec_servid_exec tt-ped_exec_hist.des_text_erro   
&Scoped-define ENABLED-FIELDS-IN-QUERY-brPedexec   
&Scoped-define SELF-NAME brPedexec
&Scoped-define QUERY-STRING-brPedexec FOR EACH tt-ped_exec_hist NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-brPedexec OPEN QUERY {&SELF-NAME} FOR EACH tt-ped_exec_hist NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-brPedexec tt-ped_exec_hist
&Scoped-define FIRST-TABLE-IN-QUERY-brPedexec tt-ped_exec_hist


/* Definitions for FRAME fPage1                                         */
&Scoped-define OPEN-BROWSERS-IN-QUERY-fPage1 ~
    ~{&OPEN-QUERY-Br-prog}

/* Definitions for FRAME fPage2                                         */
&Scoped-define OPEN-BROWSERS-IN-QUERY-fPage2 ~
    ~{&OPEN-QUERY-brPedexec}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS rtToolBar-2 rtToolBar RECT-consulta RECT-1 ~
RECT-Ordena btSelecao btQueryJoins btReportsJoins btExit btHelp fi-erro ~
fi-pendente rs-ordena rs-consulta btAtualiza fi-execucao fi-executado btOK ~
btCancel btHelp2 
&Scoped-Define DISPLAYED-OBJECTS fi-erro fi-pendente rs-ordena rs-consulta ~
fi-execucao c-intervalo fi-executado 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD fnCod-Emitente wWindow 
FUNCTION fnCod-Emitente RETURNS integer
  ( pcnpj as char )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD fnCod-Estabel wWindow 
FUNCTION fnCod-Estabel RETURNS CHARACTER
  ( pcnpj as char )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD fnItem wWindow 
FUNCTION fnItem RETURNS CHARACTER
  ( pcod-produto as integer )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD fnNome-Abrev wWindow 
FUNCTION fnNome-Abrev RETURNS CHARACTER
  ( pcnpj as char )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD fnRefresh wWindow 
FUNCTION fnRefresh returns logical ( )  FORWARD.

/* _UIB-CODE-BLOCK-END */
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


/* Definitions of handles for OCX Containers                            */
DEFINE VARIABLE CtrlFrame AS WIDGET-HANDLE NO-UNDO.
DEFINE VARIABLE chCtrlFrame AS COMPONENT-HANDLE NO-UNDO.

/* Definitions of the field level widgets                               */
DEFINE BUTTON btAtualiza 
     IMAGE-UP FILE "image/im-relo.bmp":U
     IMAGE-INSENSITIVE FILE "image/ii-relo.bmp":U
     LABEL "Query Joins" 
     SIZE 4 BY 1.25
     FONT 4.

DEFINE BUTTON btCancel 
     LABEL "Cancelar" 
     SIZE 10 BY 1.

DEFINE BUTTON btExit 
     IMAGE-UP FILE "image\im-exi":U
     IMAGE-INSENSITIVE FILE "image\ii-exi":U
     LABEL "Exit" 
     SIZE 4 BY 1.25
     FONT 4.

DEFINE BUTTON btHelp 
     IMAGE-UP FILE "image\im-hel":U
     IMAGE-INSENSITIVE FILE "image\ii-hel":U
     LABEL "Help" 
     SIZE 4 BY 1.25
     FONT 4.

DEFINE BUTTON btHelp2 
     LABEL "Ajuda" 
     SIZE 10 BY 1.

DEFINE BUTTON btOK 
     LABEL "OK" 
     SIZE 10 BY 1.

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

DEFINE BUTTON btSelecao 
     IMAGE-UP FILE "image\im-ran":U
     IMAGE-INSENSITIVE FILE "image\ii-ran":U
     LABEL "Sele‡Æo" 
     SIZE 4 BY 1.25
     FONT 4.

DEFINE VARIABLE c-intervalo AS INTEGER FORMAT ">,>>>,>>9":U INITIAL 60 
     VIEW-AS FILL-IN 
     SIZE 4.72 BY .79 NO-UNDO.

DEFINE VARIABLE fi-erro AS CHARACTER FORMAT "X(25)":U INITIAL " Executado c/ ERRO" 
     VIEW-AS FILL-IN 
     SIZE 16 BY .79
     BGCOLOR 12  NO-UNDO.

DEFINE VARIABLE fi-execucao AS CHARACTER FORMAT "X(25)":U INITIAL "2 - Em execu‡Æo" 
     VIEW-AS FILL-IN 
     SIZE 14 BY .67
     BGCOLOR 14 FONT 1 NO-UNDO.

DEFINE VARIABLE fi-executado AS CHARACTER FORMAT "X(25)":U INITIAL "3 - Executado" 
     VIEW-AS FILL-IN 
     SIZE 14 BY .67
     BGCOLOR 7 FONT 1 NO-UNDO.

DEFINE VARIABLE fi-pendente AS CHARACTER FORMAT "X(25)":U INITIAL "1 - Pendente" 
     VIEW-AS FILL-IN 
     SIZE 14 BY .67
     BGCOLOR 3 FONT 1 NO-UNDO.

DEFINE VARIABLE rs-consulta AS INTEGER 
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS 
          "Manual", 1,
"Autom tico", 2
     SIZE 11.57 BY 1.5 NO-UNDO.

DEFINE VARIABLE rs-ordena AS INTEGER INITIAL 2 
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS 
          "Programa", 1,
"SituacÆo", 2,
"Data Exec", 3
     SIZE 14 BY 1.75 NO-UNDO.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 16 BY 2.33.

DEFINE RECTANGLE RECT-consulta
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 32.72 BY 2.33.

DEFINE RECTANGLE RECT-Ordena
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 20 BY 2.5.

DEFINE RECTANGLE rtToolBar
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 158 BY 1.5
     BGCOLOR 7 .

DEFINE RECTANGLE rtToolBar-2
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 158 BY 1.5
     BGCOLOR 7 .

DEFINE BUTTON btAgenda 
     LABEL "Agenda RPW" 
     SIZE 15 BY 1.13.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY Br-prog FOR 
      tt-int_ds_prog_rpw, 
      tt-ped_exec SCROLLING.

DEFINE QUERY brPedexec FOR 
      tt-ped_exec_hist SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE Br-prog
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS Br-prog wWindow _FREEFORM
  QUERY Br-prog NO-LOCK DISPLAY
      tt-int_ds_prog_rpw.cod_prog FORMAT "x(10)":U WIDTH 9
    tt-int_ds_prog_rpw.desc_prog FORMAT "x(40)":U WIDTH 30.86
    tt-int_ds_prog_rpw.nome_ext FORMAT "x(20)":U WIDTH 16.43
    tt-ped_exec.num_ped_exec FORMAT ">>>>>>>9":U WIDTH 6.8
    tt-ped_exec.cod_servid_exec FORMAT "x(8)":U
    tt-ped_exec.ind_sit_ped_exec COLUMN-LABEL "Sit" FORMAT "X(3)":U WIDTH 3.4
    tt-ped_exec.dat_criac_ped_exec FORMAT "99/99/9999":U
    tt-ped_exec.dat_exec_ped_exec FORMAT "99/99/9999":U WIDTH 9
    tt-ped_exec.hra_exec_ped_exec FORMAT "99:99:99":U
    tt-ped_exec.dat_inic_exec_servid_exec FORMAT "99/99/9999":U WIDTH 9
    tt-ped_exec.hra_inic_exec_servid_exec FORMAT "99:99:99":U WIDTH 9.29
    tt-ped_exec.hra_fim_exec_servid_exec FORMAT "99:99:99":U WIDTH 9.43
    tt-ped_exec.des_text_erro FORMAT "x(2000)":U WIDTH 500
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 154.72 BY 18.92
         FONT 1 ROW-HEIGHT-CHARS .63.

DEFINE BROWSE brPedexec
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS brPedexec wWindow _FREEFORM
  QUERY brPedexec NO-LOCK DISPLAY
      tt-ped_exec_hist.cod_prog_dtsul FORMAT "x(50)":U WIDTH 10.57
    tt-ped_exec_hist.desc-prog COLUMN-LABEL "Descri»’o" FORMAT "X(65)":U WIDTH 34
    tt-ped_exec_hist.num_ped_exec FORMAT ">>>>>>>9":U
    tt-ped_exec_hist.cod_servid_exec FORMAT "x(8)":U
    tt-ped_exec_hist.ind_sit_ped_exec COLUMN-LABEL "Sit" FORMAT "X(3)":U WIDTH 3
    tt-ped_exec_hist.dat_exec_ped_exec FORMAT "99/99/9999":U
    tt-ped_exec_hist.hra_exec_ped_exec FORMAT "99:99:99":U
    tt-ped_exec_hist.dat_inic_exec_servid_exec FORMAT "99/99/9999":U
    tt-ped_exec_hist.hra_inic_exec_servid_exec FORMAT "99:99:99":U
    tt-ped_exec_hist.hra_fim_exec_servid_exec FORMAT "99:99:99":U
    tt-ped_exec_hist.des_text_erro COLUMN-LABEL "Texto Mensagem" FORMAT "x(2000)":U WIDTH 500
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 154 BY 20
         FONT 1 ROW-HEIGHT-CHARS .63.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME fpage0
     btSelecao AT ROW 1.08 COL 1.57 HELP
          "Relat¢rios relacionados" WIDGET-ID 2
     btQueryJoins AT ROW 1.13 COL 142 HELP
          "Consultas relacionadas"
     btReportsJoins AT ROW 1.13 COL 146 HELP
          "Relat¢rios relacionados"
     btExit AT ROW 1.13 COL 150 HELP
          "Sair"
     btHelp AT ROW 1.13 COL 154 HELP
          "Ajuda"
     fi-erro AT ROW 3.04 COL 91 COLON-ALIGNED NO-LABEL WIDGET-ID 44
     fi-pendente AT ROW 3.04 COL 108.72 COLON-ALIGNED NO-LABEL WIDGET-ID 46
     rs-ordena AT ROW 3.21 COL 72.57 NO-LABEL WIDGET-ID 54
     rs-consulta AT ROW 3.46 COL 127.72 NO-LABEL WIDGET-ID 10
     btAtualiza AT ROW 3.63 COL 152.72 HELP
          "Consultas relacionadas" WIDGET-ID 4
     fi-execucao AT ROW 3.75 COL 108.72 COLON-ALIGNED NO-LABEL WIDGET-ID 48
     c-intervalo AT ROW 3.96 COL 138.72 COLON-ALIGNED NO-LABEL WIDGET-ID 6
     fi-executado AT ROW 4.42 COL 108.72 COLON-ALIGNED NO-LABEL WIDGET-ID 50
     btOK AT ROW 26.29 COL 2
     btCancel AT ROW 26.29 COL 13
     btHelp2 AT ROW 26.29 COL 147
     "Ordernar por:" VIEW-AS TEXT
          SIZE 10 BY .54 AT ROW 2.5 COL 71.72 WIDGET-ID 58
     "Situa‡Æo Pedido" VIEW-AS TEXT
          SIZE 13 BY .5 AT ROW 2.54 COL 110.72 WIDGET-ID 26
     "seg" VIEW-AS TEXT
          SIZE 4.29 BY .54 AT ROW 4.17 COL 145.86 WIDGET-ID 16
     "Consulta" VIEW-AS TEXT
          SIZE 8 BY .54 AT ROW 2.63 COL 128.72 WIDGET-ID 14
     rtToolBar-2 AT ROW 1 COL 1
     rtToolBar AT ROW 26 COL 1
     RECT-consulta AT ROW 2.92 COL 126.29 WIDGET-ID 8
     RECT-1 AT ROW 2.92 COL 109.72 WIDGET-ID 24
     RECT-Ordena AT ROW 2.75 COL 70 WIDGET-ID 52
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 158.72 BY 26.71
         FONT 1 WIDGET-ID 100.

DEFINE FRAME fPage2
     brPedexec AT ROW 1 COL 2 WIDGET-ID 1100
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 2 ROW 5.5
         SIZE 156 BY 20.25
         FONT 1 WIDGET-ID 900.

DEFINE FRAME fPage1
     Br-prog AT ROW 1.08 COL 1.29 WIDGET-ID 1000
     btAgenda AT ROW 20 COL 1.86 WIDGET-ID 4
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 2 ROW 5.5
         SIZE 156 BY 20.3
         FONT 1 WIDGET-ID 900.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Window
   Allow: Basic,Browse,DB-Fields,Window,Query
   Add Fields to: Neither
   Other Settings: COMPILE
   Temp-Tables and Buffers:
      TABLE: tt-int_ds_prog_rpw T "?" NO-UNDO emsesp int_ds_prog_rpw
      ADDITIONAL-FIELDS:
          field r-rowid as rowid
      END-FIELDS.
      TABLE: tt-ped_exec T "?" NO-UNDO ems2mult ped_exec
      ADDITIONAL-FIELDS:
          field r-rowid as rowid
      END-FIELDS.
      TABLE: tt-ped_exec_hist T "?" NO-UNDO ems2mult ped_exec
      ADDITIONAL-FIELDS:
          field r-rowid as rowid
          field desc-prog like int_ds_prog_rpw.desc-prog
          index ordem
          cod_prog_dtsul
          cod_servid_exec
          num_ped_exec DESC
          dat_inic_exec_servid_exec
          hra_inic_exec_servid_exec
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
         HEIGHT             = 26.71
         WIDTH              = 158.72
         MAX-HEIGHT         = 27.5
         MAX-WIDTH          = 195.14
         VIRTUAL-HEIGHT     = 27.5
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _INCLUDED-LIB wWindow 
/* ************************* Included-Libraries *********************** */

{window/window.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME




/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW wWindow
  NOT-VISIBLE,,RUN-PERSISTENT                                           */
/* REPARENT FRAME */
ASSIGN FRAME fPage1:FRAME = FRAME fpage0:HANDLE
       FRAME fPage2:FRAME = FRAME fpage0:HANDLE.

/* SETTINGS FOR FRAME fpage0
   FRAME-NAME                                                           */
/* SETTINGS FOR FILL-IN c-intervalo IN FRAME fpage0
   NO-ENABLE                                                            */
/* SETTINGS FOR FRAME fPage1
                                                                        */
/* BROWSE-TAB Br-prog 1 fPage1 */
ASSIGN 
       Br-prog:COLUMN-RESIZABLE IN FRAME fPage1       = TRUE
       Br-prog:COLUMN-MOVABLE IN FRAME fPage1         = TRUE.

/* SETTINGS FOR FRAME fPage2
                                                                        */
/* BROWSE-TAB brPedexec 1 fPage2 */
ASSIGN 
       brPedexec:COLUMN-RESIZABLE IN FRAME fPage2       = TRUE.

IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(wWindow)
THEN wWindow:HIDDEN = yes.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE Br-prog
/* Query rebuild information for BROWSE Br-prog
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH tt-int_ds_prog_rpw NO-LOCK ,
    EACH tt-ped_exec WHERE tt-ped_exec.cod_prog_dtsul = tt-int_ds_prog_rpw.cod-prog INDEXED-REPOSITION.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is OPENED
*/  /* BROWSE Br-prog */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE brPedexec
/* Query rebuild information for BROWSE brPedexec
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH tt-ped_exec_hist NO-LOCK INDEXED-REPOSITION.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is OPENED
*/  /* BROWSE brPedexec */
&ANALYZE-RESUME

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
     _Options          = "SHARE-LOCK KEEP-EMPTY"
     _Query            is NOT OPENED
*/  /* FRAME fPage2 */
&ANALYZE-RESUME

 


/* **********************  Create OCX Containers  ********************** */

&ANALYZE-SUSPEND _CREATE-DYNAMIC

&IF "{&OPSYS}" = "WIN32":U AND "{&WINDOW-SYSTEM}" NE "TTY":U &THEN

CREATE CONTROL-FRAME CtrlFrame ASSIGN
       FRAME           = FRAME fpage0:HANDLE
       ROW             = 1
       COLUMN          = 135.14
       HEIGHT          = 1.5
       WIDTH           = 6
       WIDGET-ID       = 18
       HIDDEN          = yes
       SENSITIVE       = yes.
/* CtrlFrame OCXINFO:CREATE-CONTROL from: {F0B88A90-F5DA-11CF-B545-0020AF6ED35A} type: PSTimer */

&ENDIF

&ANALYZE-RESUME /* End of _CREATE-DYNAMIC */


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


&Scoped-define BROWSE-NAME Br-prog
&Scoped-define FRAME-NAME fPage1
&Scoped-define SELF-NAME Br-prog
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Br-prog wWindow
ON MOUSE-SELECT-DBLCLICK OF Br-prog IN FRAME fPage1
DO:
      if avail tt-int_ds_prog_rpw then do:
    
        if tt-int_ds_prog_rpw.cod_prog begins "int011-l" then do:
            create tt-param-int011-l.
            assign tt-param-int011-l.usuario         = "rpw"
                   tt-param-int011-l.destino         = 2
                   tt-param-int011-l.data-exec       = today
                   tt-param-int011-l.hora-exec       = time
                   tt-param-int011-l.arquivo         = tt-int_ds_prog_rpw.cod_prog + ".LST"
                   tt-param-int011-l.classifica      = 0
                   tt-param-int011-l.desc-classifica = ""
                   tt-param-int011-l.dt-cancela-ini  = ?
                   tt-param-int011-l.dt-cancela-fim  = ?
                   tt-param-int011-l.dt-emis-nota-ini  = ?
                   tt-param-int011-l.dt-emis-nota-fim  = ?
                   tt-param-int011-l.cod-estabel-ini = "001"
                   tt-param-int011-l.cod-estabel-fim = "900".
            raw-transfer tt-param-int011-l to raw-param.
        end.
        ELSE if tt-int_ds_prog_rpw.cod_prog begins "int011-c" then do:   
            create tt-param-int011-C.
            assign tt-param-int011-C.usuario         = "rpw"
                   tt-param-int011-C.destino         = 2
                   tt-param-int011-C.data-exec       = today
                   tt-param-int011-C.hora-exec       = time
                   tt-param-int011-C.arquivo         = tt-int_ds_prog_rpw.cod_prog + ".LST"
                   tt-param-int011-C.classifica      = 0
                   tt-param-int011-C.desc-classifica = ""
                   tt-param-int011-C.dt-cancela-ini  = ?
                   tt-param-int011-C.dt-cancela-fim  = ?
                   tt-param-int011-C.dt-emis-nota-ini  = ?
                   tt-param-int011-C.dt-emis-nota-fim  = ?
                   tt-param-int011-C.cod-estabel-ini = "973"
                   tt-param-int011-C.cod-estabel-fim = "973".
            raw-transfer tt-param-int011-C to raw-param.
        end.
        else if tt-int_ds_prog_rpw.cod_prog begins "int012" then do:    
            create  tt-param-int012.
            assign  tt-param-int012.destino          = 2
                    tt-param-int012.arquivo          = tt-int_ds_prog_rpw.cod_prog + ".LST"
                    tt-param-int012.usuario          = "rpw"
                    tt-param-int012.data-exec        = today
                    tt-param-int012.hora-exec        = time
                    tt-param-int012.classifica       = 0
                    tt-param-int012.desc-classifica  = ""
                    tt-param-int012.cod-emitente-fim = 999999999
                    tt-param-int012.cod-emitente-ini = 0
                    tt-param-int012.cod-estabel-fim  = "ZZZZZ"
                    tt-param-int012.cod-estabel-ini  = ""
                    tt-param-int012.dt-emis-nota-fim = ?
                    tt-param-int012.dt-emis-nota-ini = ?
                    tt-param-int012.nro-docto-fim    = 999999999
                    tt-param-int012.nro-docto-ini    = 0
                    tt-param-int012.serie-docto-fim  = "ZZZZZ"
                    tt-param-int012.serie-docto-ini  = "".
            raw-transfer tt-param-int012 to raw-param.


        end.
        else if tt-int_ds_prog_rpw.cod_prog begins "int042" then do:
            create  tt-param-int042.
            assign  tt-param-int042.destino          = 2
                    tt-param-int042.arquivo          = tt-int_ds_prog_rpw.cod_prog + ".LST"
                    tt-param-int042.usuario          = "rpw"
                    tt-param-int042.data-exec        = today
                    tt-param-int042.hora-exec        = time
                    tt-param-int042.classifica       = 0
                    tt-param-int042.desc-classifica  = ""
                    tt-param-int042.cod-emitente-fim = 999999999
                    tt-param-int042.cod-emitente-ini = 0
                    tt-param-int042.cod-estabel-fim  = "ZZZZZ"
                    tt-param-int042.cod-estabel-ini  = ""
                    tt-param-int042.dt-emis-nota-fim = ?
                    tt-param-int042.dt-emis-nota-ini = ?
                    tt-param-int042.nro-docto-fim    = 999999999
                    tt-param-int042.nro-docto-ini    = 0
                    tt-param-int042.serie-docto-fim  = "ZZZZZ"
                    tt-param-int042.serie-docto-ini  = "".
            raw-transfer tt-param-int042 to raw-param.
        end.
        else if tt-int_ds_prog_rpw.cod_prog begins "int052rp" then do:
            create  tt-param-int052.
            assign  tt-param-int052.destino          = 2
                    tt-param-int052.arquivo          = tt-int_ds_prog_rpw.cod_prog + ".LST"
                    tt-param-int052.usuario          = "rpw"
                    tt-param-int052.data-exec        = today
                    tt-param-int052.hora-exec        = time
                    tt-param-int052.classifica       = 0
                    tt-param-int052.desc-classifica  = ""
                    tt-param-int052.cod-emitente-fim = 999999999
                    tt-param-int052.cod-emitente-ini = 0
                    tt-param-int052.cod-estabel-fim  = "ZZZZZ"
                    tt-param-int052.cod-estabel-ini  = ""
                    tt-param-int052.dt-emis-nota-fim = ?
                    tt-param-int052.dt-emis-nota-ini = ?
                    tt-param-int052.nro-docto-fim    = "999999999"
                    tt-param-int052.nro-docto-ini    = "0"
                    tt-param-int052.serie-docto-fim  = "ZZZZZ"
                    tt-param-int052.serie-docto-ini  = "".
            raw-transfer tt-param-int052 to raw-param.
        end.
        else if tt-int_ds_prog_rpw.cod_prog begins "int110-14w" then do:
            create  tt-param-int110.
            assign  tt-param-int110.destino          = 2
                    tt-param-int110.arquivo          = tt-int_ds_prog_rpw.cod_prog + ".LST"
                    tt-param-int110.usuario          = "rpw"
                    tt-param-int110.data-exec        = today
                    tt-param-int110.hora-exec        = time
                    tt-param-int110.classifica       = 0
                    tt-param-int110.desc-classifica  = ""
                    tt-param-int110.serie            = "14".
            raw-transfer tt-param-int110 to raw-param.
        end.
        else if tt-int_ds_prog_rpw.cod_prog begins "int110-13w" then do:
            create  tt-param-int110.
            assign  tt-param-int110.destino          = 2
                    tt-param-int110.arquivo          = tt-int_ds_prog_rpw.cod_prog + ".LST"
                    tt-param-int110.usuario          = "rpw"
                    tt-param-int110.data-exec        = today
                    tt-param-int110.hora-exec        = time
                    tt-param-int110.classifica       = 0
                    tt-param-int110.desc-classifica  = ""
                    tt-param-int110.serie            = "13".
            raw-transfer tt-param-int110 to raw-param.
        end.
        else do:
            create tt-param.
            assign tt-param.usuario         = "rpw"
                   tt-param.destino         = 2
                   tt-param.data-exec       = today
                   tt-param.hora-exec       = time
                   tt-param.arquivo         = tt-int_ds_prog_rpw.cod_prog + ".LST"
                   tt-param.classifica      = 0
                   tt-param.desc-classifica = "".
            raw-transfer tt-param to raw-param.
        end.

        run btb/btb911zb.p (input tt-int_ds_prog_rpw.cod_prog,
                            input tt-int_ds_prog_rpw.nome_ext,
                            input "2.00.00.000",
                            input 97,
                            input tt-int_ds_prog_rpw.cod_prog + ".LST",
                            input 2,
                            input raw-param,
                            input table tt-raw-digita,
                            output i-num-ped-exec-rpw).

        for last ped_exec no-lock where 
            ped_exec.cod_prog_dtsul = tt-int_ds_prog_rpw.cod_prog and
            ped_exec.num_ped_exec = i-num-ped-exec-rpw:
            if not avail tt-ped_exec then 
                create tt-ped_exec.
            buffer-copy ped_exec to tt-ped_exec.
            open query brProg 
                for each tt-int_ds_prog_rpw no-lock, 
                    each tt-ped_exec no-lock where 
                    tt-ped_exec.cod_prog_dtsul = tt-int_ds_prog_rpw.cod_prog
                outer-join .
        end.        
        empty temp-table tt-param.
        empty temp-table tt-param-int011-l.   
        empty temp-table tt-param-int011-C.     
        empty temp-table tt-param-int012.
        empty temp-table tt-param-int110.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Br-prog wWindow
ON ROW-DISPLAY OF Br-prog IN FRAME fPage1
DO:
    ASSIGN l-movComErro = NO.

    if trim(tt-ped_exec.ind_sit_ped_exec) = "1" then DO:

        FOR LAST tt-ped_exec_hist 
            WHERE tt-ped_exec_hist.cod_prog_dtsul = tt-ped_exec.cod_prog_dtsul 
              AND int(tt-ped_exec_hist.ind_sit_ped_exec) = 3:

            if  tt-ped_exec_hist.des_text_erro <> ? and
                tt-ped_exec_hist.des_text_erro <> "" 
                THEN ASSIGN l-movComErro = YES.
        END.

        IF l-movComErro THEN 
            ASSIGN tt-ped_exec.ind_sit_ped_exec:bgcolor in browse br-Prog = 12.
        ELSE
            ASSIGN tt-ped_exec.ind_sit_ped_exec:bgcolor in browse br-Prog = 3.

    END.
    ELSE if trim(tt-ped_exec.ind_sit_ped_exec) = "2" then DO:
        
        FOR LAST tt-ped_exec_hist 
            WHERE tt-ped_exec_hist.cod_prog_dtsul = tt-ped_exec.cod_prog_dtsul 
              AND int(tt-ped_exec_hist.ind_sit_ped_exec) = 3:

            if  tt-ped_exec_hist.des_text_erro <> ? and
                tt-ped_exec_hist.des_text_erro <> "" 
                THEN ASSIGN l-movComErro = YES.
        END.

        IF l-movComErro THEN 
            ASSIGN tt-ped_exec.ind_sit_ped_exec:bgcolor in browse br-Prog = 12.
        ELSE
            assign tt-ped_exec.ind_sit_ped_exec:bgcolor in browse br-Prog = 14.


    END.
    ELSE if trim(tt-ped_exec.ind_sit_ped_exec) = "3" THEN
        assign tt-ped_exec.ind_sit_ped_exec:bgcolor in browse br-Prog = 7.

    if  tt-ped_exec.des_text_erro <> ? and
        tt-ped_exec.des_text_erro <> "" then
        tt-ped_exec.num_ped_exec:bgcolor in browse br-Prog = 12.
    else
        tt-ped_exec.num_ped_exec:bgcolor in browse br-Prog = 15. 
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME brPedexec
&Scoped-define FRAME-NAME fPage2
&Scoped-define SELF-NAME brPedexec
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL brPedexec wWindow
ON ROW-DISPLAY OF brPedexec IN FRAME fPage2
DO:
    if trim(tt-ped_exec_hist.ind_sit_ped_exec) = "1" then 
        assign tt-ped_exec_hist.ind_sit_ped_exec:bgcolor in browse brPedExec = 3.
    if trim(tt-ped_exec_hist.ind_sit_ped_exec) = "2" then 
        assign tt-ped_exec_hist.ind_sit_ped_exec:bgcolor in browse brPedExec = 14.
    if trim(tt-ped_exec_hist.ind_sit_ped_exec) = "3" then 
        assign tt-ped_exec_hist.ind_sit_ped_exec:bgcolor in browse brPedExec = 7.

    if  tt-ped_exec_hist.des_text_erro <> ? and
        tt-ped_exec_hist.des_text_erro <> "" then
        tt-ped_exec_hist.num_ped_exec:bgcolor in browse brPedExec = 12.
    else
        tt-ped_exec_hist.num_ped_exec:bgcolor in browse brPedExec = 15.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME fPage1
&Scoped-define SELF-NAME btAgenda
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btAgenda wWindow
ON CHOOSE OF btAgenda IN FRAME fPage1 /* Agenda RPW */
DO:
  apply "mouse-select-dblclick":u to br-Prog.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME fpage0
&Scoped-define SELF-NAME btAtualiza
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btAtualiza wWindow
ON CHOOSE OF btAtualiza IN FRAME fpage0 /* Query Joins */
OR CHOOSE OF btAtualiza DO:
    def var l-frame1 as logical.
    fnRefresh().

    assign l-frame1 = frame fPage1:visible.
    RUN pi-openQueryProg.
    RUN pi-openQueryHist.
    if l-frame1 then
        run SetFolder in hFolder (input 1).
    else
        run SetFolder in hFolder (input 2).

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btCancel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btCancel wWindow
ON CHOOSE OF btCancel IN FRAME fpage0 /* Cancelar */
DO:
    APPLY "CLOSE":U TO THIS-PROCEDURE.
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


&Scoped-define SELF-NAME btOK
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btOK wWindow
ON CHOOSE OF btOK IN FRAME fpage0 /* OK */
DO:
    APPLY "CLOSE":U TO THIS-PROCEDURE.
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


&Scoped-define SELF-NAME btSelecao
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btSelecao wWindow
ON CHOOSE OF btSelecao IN FRAME fpage0 /* Sele‡Æo */
OR CHOOSE OF btSelecao DO:
   fnRefresh().
   DEF VAR l-openquery AS LOG NO-UNDO.

   RUN intprg/int032a.w ( INPUT-OUTPUT c-origem-ini, 
                          INPUT-OUTPUT c-origem-fim, 
                          INPUT-OUTPUT d-dt-ocorrencia-ini, 
                          INPUT-OUTPUT d-dt-ocorrencia-fim, 
                          INPUT-OUTPUT c-hora-ini, 
                          INPUT-OUTPUT c-hora-fim, 
                          INPUT-OUTPUT i-situacao,
                          INPUT-OUTPUT c-ultimosMov,
                          OUTPUT l-openquery ).

    if l-openquery and rs-consulta:SCREEN-VALUE IN FRAME fPage0 = "2" then do:
        RUN pi-openQueryProg.
        RUN pi-openQueryHist.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME c-intervalo
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL c-intervalo wWindow
ON LEAVE OF c-intervalo IN FRAME fpage0
DO: 
  IF INT(c-intervalo:SCREEN-VALUE IN FRAME fPage0) <> 0 THEN
      chCtrlFrame:PSTimer:interval = INT(c-intervalo:SCREEN-VALUE IN FRAME fPage0) * 1000.
  ELSE
      run utp/ut-msgs.p (input "show", 
                         input 17006, 
                         input "O intervalo de atualiza‡Æo deve ser informado!").    
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME CtrlFrame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL CtrlFrame wWindow OCX.Tick
PROCEDURE CtrlFrame.PSTimer.Tick .
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  None required for OCX.
  Notes:       
------------------------------------------------------------------------------*/
    APPLY "CHOOSE" TO btAtualiza IN FRAME fPage0.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME rs-consulta
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL rs-consulta wWindow
ON VALUE-CHANGED OF rs-consulta IN FRAME fpage0
DO:
  IF rs-consulta:SCREEN-VALUE IN FRAME fPage0 = "2" THEN DO:
      ENABLE c-intervalo WITH FRAME fPage0.
      DISABLE btAtualiza WITH FRAME fPage0.
      display c-intervalo WITH FRAME fPage0.
      chCtrlFrame:PSTimer:interval = INT(c-intervalo:SCREEN-VALUE IN FRAME fPage0) * 1000.
  END.
  ELSE DO:
      DISABLE c-intervalo WITH FRAME fPage0. 
      ENABLE btAtualiza WITH FRAME fPage0.
      ASSIGN chCtrlFrame:PSTimer:interval = 0
             c-intervalo:SCREEN-VALUE IN FRAME fPage0 = "".
  END.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME Br-prog
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK wWindow 


/*--- L¢gica para inicializa‡Æo do programam ---*/
{window/MainBlock.i}

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

    assign fi-pendente:bgcolor in frame fPage0  = 3.
    assign fi-execucao:bgcolor in frame fPage0  = 14.
    assign fi-executado:bgcolor in frame fPage0  = 7.
    assign fi-erro:bgcolor in frame fPage0  = 12.

    display fi-pendente
            fi-execucao
            fi-executado
            fi-erro
        with frame fPage0.



    apply "VALUE-CHANGED":U to rs-consulta in frame fPage0.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE beforeInitializeInterface wWindow 
PROCEDURE beforeInitializeInterface :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    d-dt-ocorrencia-ini = today.
    d-dt-ocorrencia-fim = today + 1.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE control_load wWindow  _CONTROL-LOAD
PROCEDURE control_load :
/*------------------------------------------------------------------------------
  Purpose:     Load the OCXs    
  Parameters:  <none>
  Notes:       Here we load, initialize and make visible the 
               OCXs in the interface.                        
------------------------------------------------------------------------------*/

&IF "{&OPSYS}" = "WIN32":U AND "{&WINDOW-SYSTEM}" NE "TTY":U &THEN
DEFINE VARIABLE UIB_S    AS LOGICAL    NO-UNDO.
DEFINE VARIABLE OCXFile  AS CHARACTER  NO-UNDO.

OCXFile = SEARCH( "int032.wrx":U ).
IF OCXFile = ? THEN
  OCXFile = SEARCH(SUBSTRING(THIS-PROCEDURE:FILE-NAME, 1,
                     R-INDEX(THIS-PROCEDURE:FILE-NAME, ".":U), "CHARACTER":U) + "wrx":U).

IF OCXFile <> ? THEN
DO:
  ASSIGN
    chCtrlFrame = CtrlFrame:COM-HANDLE
    UIB_S = chCtrlFrame:LoadControls( OCXFile, "CtrlFrame":U)
    CtrlFrame:NAME = "CtrlFrame":U
  .
  RUN initialize-controls IN THIS-PROCEDURE NO-ERROR.
END.
ELSE MESSAGE "int032.wrx":U SKIP(1)
             "The binary control file could not be found. The controls cannot be loaded."
             VIEW-AS ALERT-BOX TITLE "Controls Not Loaded".

&ENDIF

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-openQueryHist wWindow 
PROCEDURE pi-openQueryHist :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
empty temp-table tt-ped_exec_hist.

session:SET-WAIT-STATE("GENERAL").
for each int_ds_prog_rpw no-lock where
    int_ds_prog_rpw.cod_prog >= c-origem-ini and
    int_ds_prog_rpw.cod_prog <= c-origem-fim:

    ASSIGN i-movimentos = 0.

    for each ped_exec no-lock where 
        ped_exec.cod_prog_dtsul = int_ds_prog_rpw.cod_prog and
        ped_exec.dat_exec_ped_exec >= d-dt-ocorrencia-ini  and
        ped_exec.dat_exec_ped_exec <= d-dt-ocorrencia-fim
         query-tuning(no-lookahead)
        BY ped_exec.dat_exec_ped_exec DESC
        BY ped_exec.hra_inic_exec_servid_exec DESC
        :
                
        if ped_exec.hra_inic_exec_servid_exec <> "" and (
           ped_exec.hra_inic_exec_servid_exec < c-hora-ini or
           ped_exec.hra_inic_exec_servid_exec > c-hora-fim) then next.

        IF i-movimentos = c-ultimosMov THEN NEXT.

        if i-situacao <> 0 then do: 
            if i-situacao = 1 and 
               int(ped_exec.ind_sit_ped_exec) > 2 then next.
            if i-situacao = 3 and 
               int(ped_exec.ind_sit_ped_exec) < 3 then next.
        end.
        create tt-ped_exec_hist.
        buffer-copy ped_exec to tt-ped_exec_hist
            assign tt-ped_exec_hist.desc-prog = int_ds_prog_rpw.desc_prog.

        ASSIGN i-movimentos = i-movimentos + 1.
    end.        
end.
session:SET-WAIT-STATE(""). 

if can-find (first int_ds_prog_rpw) then do:
    open query brPedExec 
        for each tt-ped_exec_hist.
            /*
            by tt-ped_exec_hist.cod_prog_dtsul
              by tt-ped_exec.num_ped_exec desc
                by tt-ped_exec.dat_inic_exec_servid_exec
                  by tt-ped_exec_hist.hra_inic_exec_servid_exec.
*/
    run setEnabled in hFolder (input 2, input true).
    enable all with frame fPage2.
    /*
    if brPedExec:num-entries > 0 then do:
        brPedExec:SELECT-ROW(1) in frame fPage2.
        apply "VALUE-CHANGED":U to brPedExec in frame fPage2.
    end.
    */
end.
else do:
    run setEnabled in hFolder (input 2, input false).
    close query brPedExec.
    disable all with frame fPage2.
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-openQueryprog wWindow 
PROCEDURE pi-openQueryprog :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
empty temp-table tt-int_ds_prog_rpw.
empty temp-table tt-ped_exec.


for each int_ds_prog_rpw no-lock:
    create tt-int_ds_prog_rpw.
    buffer-copy int_ds_prog_rpw to tt-int_ds_prog_rpw.
    for last ped_exec no-lock where 
        ped_exec.cod_prog_dtsul = int_ds_prog_rpw.cod_prog and
        ped_exec.ind_sit_ped_exec = "2":
        create tt-ped_exec.
        buffer-copy ped_exec to tt-ped_exec.
    end.
    if not avail ped_exec then do:
        for last ped_exec no-lock where 
            ped_exec.cod_prog_dtsul = int_ds_prog_rpw.cod_prog:
            create tt-ped_exec.
            buffer-copy ped_exec to tt-ped_exec.
        end.
    end.
end.

if can-find (first tt-int_ds_prog_rpw) then do:

    IF rs-ordena:SCREEN-VALUE IN FRAME fpage0 = "1" THEN DO:
        open query br-Prog 
            for each tt-int_ds_prog_rpw no-lock, 
                each tt-ped_exec no-lock where 
                tt-ped_exec.cod_prog_dtsul = tt-int_ds_prog_rpw.cod_prog
            outer-join 
            BY tt-int_ds_prog_rpw.cod_prog.
    END.
    ELSE IF rs-ordena:SCREEN-VALUE IN FRAME fpage0 = "2" THEN DO:
        open query br-Prog 
            for each tt-int_ds_prog_rpw no-lock, 
                each tt-ped_exec no-lock where 
                tt-ped_exec.cod_prog_dtsul = tt-int_ds_prog_rpw.cod_prog
            outer-join 
            BY tt-ped_exec.ind_sit_ped_exec DESC.
    END.
    ELSE IF rs-ordena:SCREEN-VALUE IN FRAME fpage0 = "3" THEN DO:
        open query br-Prog 
            for each tt-int_ds_prog_rpw no-lock, 
                each tt-ped_exec no-lock where 
                tt-ped_exec.cod_prog_dtsul = tt-int_ds_prog_rpw.cod_prog
            outer-join 
            BY tt-ped_exec.dat_exec_ped_exec.
    END.

    run setEnabled in hFolder (input 1, input true).
    enable all with frame fPage1.
    if br-Prog:num-entries > 0 then do:
        br-Prog:SELECT-ROW(1) in frame fPage1.
        apply "VALUE-CHANGED":U to br-Prog in frame fPage1.
    end.
end.
else do:
    run setEnabled in hFolder (input 1, input false).
    close query br-Prog.
    disable all with frame fPage1.
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION fnCod-Emitente wWindow 
FUNCTION fnCod-Emitente RETURNS integer
  ( pcnpj as char ) :
/*------------------------------------------------------------------------------
  Purpose:  
    Notes:  
------------------------------------------------------------------------------*/

    for first emitente fields (cod-emitente)
        no-lock where emitente.cgc begins pcnpj:
        RETURN emitente.cod-emitente.
    end.

  RETURN ?.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION fnCod-Estabel wWindow 
FUNCTION fnCod-Estabel RETURNS CHARACTER
  ( pcnpj as char ) :
/*------------------------------------------------------------------------------
  Purpose:  
    Notes:  
------------------------------------------------------------------------------*/

    for first estabelec fields (cod-estabel)
        no-lock where estabelec.cgc begins pcnpj:
        RETURN estabelec.cod-estabel.
    end.

  RETURN "".   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION fnItem wWindow 
FUNCTION fnItem RETURNS CHARACTER
  ( pcod-produto as integer ) :
/*------------------------------------------------------------------------------
  Purpose:  
    Notes:  
------------------------------------------------------------------------------*/

    for first ITEM fields (desc-item)
        no-lock where item.it-codigo = string(pcod-produto):
        RETURN item.desc-item.
    end.

  RETURN "".   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION fnNome-Abrev wWindow 
FUNCTION fnNome-Abrev RETURNS CHARACTER
  ( pcnpj as char ) :
/*------------------------------------------------------------------------------
  Purpose:  
    Notes:  
------------------------------------------------------------------------------*/

    for first emitente fields (nome-abrev)
        no-lock where emitente.cgc = pcnpj:
        RETURN emitente.nome-abrev.
    end.

  RETURN "".   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION fnRefresh wWindow 
FUNCTION fnRefresh returns logical ( ) :
    IF rs-consulta:SCREEN-VALUE IN FRAME fPage0 = "2" THEN DO:
        chCtrlFrame:PSTimer:interval = 0.
        APPLY "LEAVE" TO c-intervalo IN FRAME fPage0.
    END.

    RETURN FALSE.   

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

