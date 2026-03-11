&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI ADM1
&ANALYZE-RESUME
/* Connected Databases 
*/
&Scoped-define WINDOW-NAME w-win
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS w-win 
/*EDITAR NO APP BUILDER

rograma: cstp/csap007.w

Finalidade/Descricao: Realizar geraá∆o de arquivo de titulos com ISS para PMC

Analise (Autor): Rafael Taizo Yamashita , 
                 

LOG Alteraá‰es:
    2015-07-13 - Jo∆o Almeida (JRA)
*/

/* ***************************  Definitions  ************************** */
&SCOPED-DEFINE program_name         csap007
&SCOPED-DEFINE program_module       MAP
&SCOPED-DEFINE program_version      2.00.01.008
{utp/ut-glob.i}
{include/i-prgvrs.i {&program_name} {&program_version}}

{cstp/csap007tt.i}

/*facelift*/
{include/i_fclpreproc.i}
DEF NEW GLOBAL SHARED VAR h-facelift AS HANDLE NO-UNDO .
IF NOT VALID-HANDLE(h-facelift) THEN RUN btb/btb901zo.p PERSISTENT SET h-facelift .

CREATE WIDGET-POOL .

DEF STREAM str-rp .

DEF BUFFER b_tit_ap FOR tit_ap .

DEF BUFFER empresa FOR emsuni.empresa .
DEF BUFFER portador FOR emsfin.portador .
DEF BUFFER cliente FOR emsuni.cliente .
DEF BUFFER fornecedor FOR emsuni.fornecedor .
DEF BUFFER b-pessoa_jurid for pessoa_jurid.
DEF BUFFER espec_docto FOR ems5.espec_docto .

/*Globais EMS5*/
DEF NEW GLOBAL SHARED VAR v_rec_empresa AS RECID NO-UNDO INIT ? .
DEF NEW GLOBAL SHARED VAR v_rec_portador AS RECID NO-UNDO INIT ? .
DEF NEW GLOBAL SHARED VAR v_rec_cart_bcia AS RECID NO-UNDO INIT ? .
DEF NEW GLOBAL SHARED VAR v_rec_bord_ap AS RECID NO-UNDO INIT ? .
DEF NEW GLOBAL SHARED VAR v_ind_dest_bord_ap AS CHARACTER NO-UNDO .
DEF NEW GLOBAL SHARED VAR v_nom_arq_bord_ap AS CHAR NO-UNDO .

DEF NEW GLOBAL SHARED VAR v_cod_aplicat_dtsul_corren    AS CHAR NO-UNDO .
DEF NEW GLOBAL SHARED VAR v_cod_ccusto_corren           AS CHAR NO-UNDO .
DEF NEW GLOBAL SHARED VAR v_cod_empres_usuar            AS CHAR NO-UNDO .
DEF NEW GLOBAL SHARED VAR v_cod_dwb_user                AS CHAR NO-UNDO .
DEF NEW GLOBAL SHARED VAR v_cod_estab_usuar             AS CHAR NO-UNDO .
DEF NEW GLOBAL SHARED VAR v_cod_funcao_negoc_empres     AS CHAR NO-UNDO .
DEF NEW GLOBAL SHARED VAR v_cod_grp_usuar_lst           AS CHAR NO-UNDO .
DEF NEW GLOBAL SHARED VAR v_cod_idiom_usuar             AS CHAR NO-UNDO .
DEF NEW GLOBAL SHARED VAR v_cod_modul_dtsul_corren      AS CHAR NO-UNDO .
DEF NEW GLOBAL SHARED VAR v_cod_modul_dtsul_empres      AS CHAR NO-UNDO .
DEF NEW GLOBAL SHARED VAR v_cod_pais_empres_usuar       AS CHAR NO-UNDO .
DEF NEW GLOBAL SHARED VAR v_cod_plano_ccusto_corren     AS CHAR NO-UNDO .
DEF NEW GLOBAL SHARED VAR v_cod_unid_negoc_usuar        AS CHAR NO-UNDO .
DEF NEW GLOBAL SHARED VAR v_cod_usuar_corren            AS CHAR NO-UNDO .
DEF NEW GLOBAL SHARED VAR v_cod_usuar_corren_criptog    AS CHAR NO-UNDO .
DEF NEW GLOBAL SHARED VAR v_num_ped_exec_corren         AS INT NO-UNDO .
/**/

DEFINE VARIABLE h-acomp AS HANDLE NO-UNDO.
DEF VAR i AS INT NO-UNDO .
DEF VAR i-tit AS INT NO-UNDO .
DEF VAR d-soma-ger      AS INT NO-UNDO FORMAT ">>>,>>9" .
DEF VAR d-soma-nger     AS INT NO-UNDO FORMAT ">>>,>>9" .
DEF VAR d-soma-sel-ger  AS INT NO-UNDO FORMAT ">>>,>>9" .
DEF VAR d-soma-sel-nger AS INT NO-UNDO FORMAT ">>>,>>9" .
DEF VAR l-msg AS LOG NO-UNDO .
DEF VAR c-prefeitura    LIKE pessoa_jurid.nom_cidade NO-UNDO.
DEF VAR cDirReturn      AS character no-undo init ?.

DEF VAR cod-bord-apb AS INT NO-UNDO .

/**/

DEFINE TEMP-TABLE tt-compl_impto_retid_ap NO-UNDO LIKE compl_impto_retid_ap .
DEFINE TEMP-TABLE b-tt-tit_ap NO-UNDO LIKE tt-tit_ap.

DEF TEMP-TABLE tt-apb NO-UNDO
    FIELD num           AS INT FORMAT ">>>>>>>>9" COLUMN-LABEL ""
    FIELD l-show        AS LOGICAL INIT YES
    FIELD vl-liquidar   LIKE tit_ap.val_pagto_tit_ap COLUMN-LABEL "Vl Baixar"
    FIELD r-rowid       AS ROWID
    FIELD cod_ser_docto     LIKE tit_ap.cod_ser_docto   
    FIELD cod_tit_ap        LIKE tit_ap.cod_tit_ap      
    FIELD cod_parcela       LIKE tit_ap.cod_parcela     
    FIELD val_sdo_tit_ap    LIKE tit_ap.val_sdo_tit_ap  

    INDEX num AS PRIMARY num
    INDEX show l-show
    INDEX concilia cod_ser_docto cod_tit_ap cod_parcela val_sdo_tit_ap
    .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE w-cadsim
&Scoped-define DB-AWARE no

&Scoped-define ADM-CONTAINER WINDOW

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME f-opt
&Scoped-define BROWSE-NAME b-apb

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-tit_ap

/* Definitions for BROWSE b-apb                                         */
&Scoped-define FIELDS-IN-QUERY-b-apb tt-tit_ap.cod_estab tt-tit_ap.cod_espec_docto tt-tit_ap.cod_ser_docto tt-tit_ap.cod_tit_ap tt-tit_ap.cod_parcela tt-tit_ap.dat_emis_docto tt-tit_ap.dat_transacao tt-tit_ap.dat_vencto_tit_ap tt-tit_ap.val_origin_tit_ap tt-tit_ap.cod_imposto tt-tit_ap.cod_classif_impto tt-tit_ap.val_aliq_impto tt-tit_ap.cod_ativid_pessoa_jurid tt-tit_ap.cdn_fornecedor tt-tit_ap.nom_pessoa tt-tit_ap.log_gerado tt-tit_ap.cod_usuar_gera tt-tit_ap.dat_geracao tt-tit_ap.hra_geracao   
&Scoped-define ENABLED-FIELDS-IN-QUERY-b-apb   
&Scoped-define SELF-NAME b-apb
&Scoped-define OPEN-QUERY-b-apb IF t-nao-gerado:INPUT-VALUE IN FRAME f-apb = YES and t-gerados:INPUT-VALUE IN FRAME f-apb = YES THEN DO:     OPEN QUERY {&SELF-NAME} FOR EACH tt-tit_ap NO-LOCK     INDEXED-REPOSITION     . END.  ELSE IF t-nao-gerado:INPUT-VALUE IN FRAME f-apb = YES and t-gerados:INPUT-VALUE IN FRAME f-apb = NO THEN DO:     OPEN QUERY {&SELF-NAME} FOR EACH tt-tit_ap NO-LOCK     WHERE tt-tit_ap.log_gerado = NO     INDEXED-REPOSITION     . END.  ELSE IF t-nao-gerado:INPUT-VALUE IN FRAME f-apb = NO and t-gerados:INPUT-VALUE IN FRAME f-apb = YES THEN DO:     OPEN QUERY {&SELF-NAME} FOR EACH tt-tit_ap NO-LOCK     WHERE tt-tit_ap.log_gerado = YES     INDEXED-REPOSITION     . END.
&Scoped-define TABLES-IN-QUERY-b-apb tt-tit_ap
&Scoped-define FIRST-TABLE-IN-QUERY-b-apb tt-tit_ap


/* Definitions for FRAME f-apb                                          */

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS bt-Atualizar bt-gerar b-cancelar ~
f-dt-transacao f-ano 
&Scoped-Define DISPLAYED-OBJECTS f-dt-transacao f-ano cb-prefeituras 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR w-win AS WIDGET-HANDLE NO-UNDO.

/* Menu Definitions                                                     */
DEFINE SUB-MENU mi-arquivo 
       RULE
       MENU-ITEM mi-sair        LABEL "&Sair"          ACCELERATOR "CTRL-X".

DEFINE SUB-MENU mi-ajuda 
       MENU-ITEM mi-sobre       LABEL "&Sobre..."     .

DEFINE MENU m-menu MENUBAR
       SUB-MENU  mi-arquivo     LABEL "&Arquivo"      
       SUB-MENU  mi-ajuda       LABEL "A&juda"        .


/* Definitions of the field level widgets                               */
DEFINE BUTTON b-retornar-n-gerados 
     LABEL "Retornar" 
     SIZE 12 BY 1.13.

DEFINE BUTTON b-sel-all-apb 
     LABEL "Todos" 
     SIZE 12 BY 1.13 TOOLTIP "Selecionar todos".

DEFINE BUTTON b-sel-non-apb 
     LABEL "Nenhum" 
     SIZE 12 BY 1.13 TOOLTIP "Desmarcar todos".

DEFINE VARIABLE f-sel-gerado AS INTEGER FORMAT "->,>>>,>>9":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 6 BY .88 TOOLTIP "Gerados Selecionados" NO-UNDO.

DEFINE VARIABLE f-sel-nao-gerado AS INTEGER FORMAT "->,>>>,>>9":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 6 BY .88 TOOLTIP "N∆o gerados selecionados" NO-UNDO.

DEFINE VARIABLE f-tot-gerado AS INTEGER FORMAT "->,>>>,>>9":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 6 BY .88 TOOLTIP "Total gerado" NO-UNDO.

DEFINE VARIABLE f-tot-nao-gerado AS INTEGER FORMAT "->,>>>,>>9":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 6 BY .88 TOOLTIP "Total n∆o gerado" NO-UNDO.

DEFINE VARIABLE t-gerados AS LOGICAL INITIAL no 
     LABEL "Gerados" 
     VIEW-AS TOGGLE-BOX
     SIZE 12 BY .83 NO-UNDO.

DEFINE VARIABLE t-nao-gerado AS LOGICAL INITIAL yes 
     LABEL "N∆o Gerados" 
     VIEW-AS TOGGLE-BOX
     SIZE 12 BY .83 NO-UNDO.

DEFINE VARIABLE t-teste AS LOGICAL INITIAL no 
     LABEL "TESTE" 
     VIEW-AS TOGGLE-BOX
     SIZE 8.86 BY .83 TOOLTIP "Indica se o arquivo a ser gerado ser† apenas de teste." NO-UNDO.

DEFINE BUTTON b-cancelar 
     LABEL "Cancelar" 
     SIZE 12 BY 1.13.

DEFINE BUTTON bt-Atualizar 
     LABEL "Atualizar" 
     SIZE 12 BY 1.13.

DEFINE BUTTON bt-gerar 
     LABEL "Gerar" 
     SIZE 12 BY 1.13.

DEFINE VARIABLE cb-prefeituras AS CHARACTER FORMAT "X(80)":U 
     LABEL "Prefeitura" 
     VIEW-AS COMBO-BOX INNER-LINES 18
     LIST-ITEM-PAIRS "''","''"
     DROP-DOWN-LIST
     SIZE 46 BY 1 TOOLTIP "Selecionar Prefeitura" NO-UNDO.

DEFINE VARIABLE f-ano AS INTEGER FORMAT "9999":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 5 BY .88 TOOLTIP "Ano" NO-UNDO.

DEFINE VARIABLE f-dt-transacao AS INTEGER FORMAT "99":U INITIAL 0 
     LABEL "Màs/Ano Transaá∆o" 
     VIEW-AS FILL-IN 
     SIZE 3 BY .88 TOOLTIP "Màs" NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY b-apb FOR 
      tt-tit_ap SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE b-apb
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS b-apb w-win _FREEFORM
  QUERY b-apb DISPLAY
      tt-tit_ap.cod_estab               
tt-tit_ap.cod_espec_docto         
tt-tit_ap.cod_ser_docto           
tt-tit_ap.cod_tit_ap              WIDTH 9
tt-tit_ap.cod_parcela            
tt-tit_ap.dat_emis_docto         
tt-tit_ap.dat_transacao          
tt-tit_ap.dat_vencto_tit_ap      
tt-tit_ap.val_origin_tit_ap      
tt-tit_ap.cod_imposto            
tt-tit_ap.cod_classif_impto      
tt-tit_ap.val_aliq_impto         
tt-tit_ap.cod_ativid_pessoa_jurid
tt-tit_ap.cdn_fornecedor         
tt-tit_ap.nom_pessoa             
tt-tit_ap.log_gerado             
tt-tit_ap.cod_usuar_gera         
tt-tit_ap.dat_geracao
tt-tit_ap.hra_geracao
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-BOX NO-AUTO-VALIDATE NO-ROW-MARKERS SEPARATORS MULTIPLE NO-VALIDATE SIZE 127.57 BY 19
         FONT 10.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME f-opt
     bt-Atualizar AT ROW 1.13 COL 91 WIDGET-ID 6
     bt-gerar AT ROW 1.13 COL 104 WIDGET-ID 24
     b-cancelar AT ROW 1.13 COL 117 WIDGET-ID 26
     f-dt-transacao AT ROW 1.25 COL 15 COLON-ALIGNED HELP
          "Màs" WIDGET-ID 20
     f-ano AT ROW 1.25 COL 18.57 COLON-ALIGNED HELP
          "Ano" NO-LABEL WIDGET-ID 30
     cb-prefeituras AT ROW 1.25 COL 38 COLON-ALIGNED WIDGET-ID 12
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1.5 ROW 1
         SIZE 129 BY 1.46
         FONT 7 WIDGET-ID 800.

DEFINE FRAME f-apb
     b-apb AT ROW 1 COL 1.57 WIDGET-ID 600
     b-retornar-n-gerados AT ROW 20.29 COL 61.71 WIDGET-ID 24
     b-sel-all-apb AT ROW 20.29 COL 103 HELP
          "Selecionar todos" WIDGET-ID 6
     b-sel-non-apb AT ROW 20.29 COL 117 HELP
          "Desmarcar todos" WIDGET-ID 8
     t-nao-gerado AT ROW 20.5 COL 2 WIDGET-ID 10
     f-tot-nao-gerado AT ROW 20.5 COL 12 COLON-ALIGNED HELP
          "Total n∆o gerado" NO-LABEL WIDGET-ID 14
     f-sel-nao-gerado AT ROW 20.5 COL 18.57 COLON-ALIGNED HELP
          "N∆o gerados selecionados" NO-LABEL WIDGET-ID 18
     t-gerados AT ROW 20.5 COL 36 WIDGET-ID 12
     f-tot-gerado AT ROW 20.5 COL 46 COLON-ALIGNED HELP
          "Total gerado" NO-LABEL WIDGET-ID 16
     f-sel-gerado AT ROW 20.5 COL 52.57 COLON-ALIGNED HELP
          "Gerados Selecionados" NO-LABEL WIDGET-ID 20
     t-teste AT ROW 20.5 COL 90.86 HELP
          "Indica se o arquivo a ser gerado ser† apenas de teste." WIDGET-ID 22
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1.5 ROW 2.5
         SIZE 129 BY 21.4
         FONT 7
         TITLE "APB" WIDGET-ID 1000.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: w-cadsim
   Allow: Basic,Browse,DB-Fields,Smart,Window,Query
   Container Links: 
   Add Fields to: Neither
   Other Settings: COMPILE
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
IF SESSION:DISPLAY-TYPE = "GUI":U THEN
  CREATE WINDOW w-win ASSIGN
         HIDDEN             = YES
         TITLE              = ""
         HEIGHT             = 23
         WIDTH              = 130
         MAX-HEIGHT         = 28.54
         MAX-WIDTH          = 195.14
         VIRTUAL-HEIGHT     = 28.54
         VIRTUAL-WIDTH      = 195.14
         RESIZE             = no
         SCROLL-BARS        = no
         STATUS-AREA        = no
         BGCOLOR            = ?
         FGCOLOR            = ?
         THREE-D            = yes
         MESSAGE-AREA       = no
         SENSITIVE          = yes.
ELSE {&WINDOW-NAME} = CURRENT-WINDOW.

ASSIGN {&WINDOW-NAME}:MENUBAR    = MENU m-menu:HANDLE.
/* END WINDOW DEFINITION                                                */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _INCLUDED-LIB w-win 
/* ************************* Included-Libraries *********************** */

{src/adm/method/containr.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME




/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW w-win
  VISIBLE,,RUN-PERSISTENT                                               */
/* SETTINGS FOR FRAME f-apb
                                                                        */
/* BROWSE-TAB b-apb 1 f-apb */
ASSIGN 
       b-apb:COLUMN-RESIZABLE IN FRAME f-apb       = TRUE
       b-apb:COLUMN-MOVABLE IN FRAME f-apb         = TRUE.

/* SETTINGS FOR BUTTON b-retornar-n-gerados IN FRAME f-apb
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN f-sel-gerado IN FRAME f-apb
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN f-sel-nao-gerado IN FRAME f-apb
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN f-tot-gerado IN FRAME f-apb
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN f-tot-nao-gerado IN FRAME f-apb
   NO-ENABLE                                                            */
/* SETTINGS FOR FRAME f-opt
   FRAME-NAME                                                           */
/* SETTINGS FOR COMBO-BOX cb-prefeituras IN FRAME f-opt
   NO-ENABLE                                                            */
IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(w-win)
THEN w-win:HIDDEN = yes.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE b-apb
/* Query rebuild information for BROWSE b-apb
     _START_FREEFORM
IF t-nao-gerado:INPUT-VALUE IN FRAME f-apb = YES and t-gerados:INPUT-VALUE IN FRAME f-apb = YES THEN DO:
    OPEN QUERY {&SELF-NAME} FOR EACH tt-tit_ap NO-LOCK
    INDEXED-REPOSITION
    .
END.

ELSE IF t-nao-gerado:INPUT-VALUE IN FRAME f-apb = YES and t-gerados:INPUT-VALUE IN FRAME f-apb = NO THEN DO:
    OPEN QUERY {&SELF-NAME} FOR EACH tt-tit_ap NO-LOCK
    WHERE tt-tit_ap.log_gerado = NO
    INDEXED-REPOSITION
    .
END.

ELSE IF t-nao-gerado:INPUT-VALUE IN FRAME f-apb = NO and t-gerados:INPUT-VALUE IN FRAME f-apb = YES THEN DO:
    OPEN QUERY {&SELF-NAME} FOR EACH tt-tit_ap NO-LOCK
    WHERE tt-tit_ap.log_gerado = YES
    INDEXED-REPOSITION
    .
END.
     _END_FREEFORM
     _Query            is NOT OPENED
*/  /* BROWSE b-apb */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME w-win
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL w-win w-win
ON END-ERROR OF w-win
OR ENDKEY OF {&WINDOW-NAME} ANYWHERE DO:
  /* This case occurs when the user presses the "Esc" key.
     In a persistently run window, just ignore this.  If we did not, the
     application would exit. */
   RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL w-win w-win
ON WINDOW-CLOSE OF w-win
DO:
  /* This ADM code must be left here in order for the SmartWindow
     and its descendents to terminate properly on exit. */
  APPLY "CLOSE":U TO THIS-PROCEDURE.
  RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME b-apb
&Scoped-define FRAME-NAME f-apb
&Scoped-define SELF-NAME b-apb
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-apb w-win
ON ITERATION-CHANGED OF b-apb IN FRAME f-apb
DO:
    ASSIGN d-soma-sel-ger = 0 
           d-soma-sel-nger = 0 .
    DO i = 1 TO SELF:QUERY:NUM-RESULTS:
        IF (tt-tit_ap.log_gerado = YES) AND (SELF:FOCUSED-ROW-SELECTED) THEN DO:
            /*SELF:FETCH-SELECTED-ROW(i) .*/
            ASSIGN d-soma-sel-ger = d-soma-sel-ger + 1 .
        END.    
        IF (tt-tit_ap.log_gerado = NO) AND (SELF:FOCUSED-ROW-SELECTED) THEN
            ASSIGN d-soma-sel-nger = d-soma-sel-nger + 1 .           
    END.
    
    ASSIGN f-sel-nao-gerado:SCREEN-VALUE = string(d-soma-sel-nger)
           f-sel-gerado:SCREEN-VALUE = string(d-soma-sel-ger).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-apb w-win
ON ROW-LEAVE OF b-apb IN FRAME f-apb
DO:
    APPLY "ITERATION-CHANGED" TO SELF .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME f-opt
&Scoped-define SELF-NAME b-cancelar
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-cancelar w-win
ON CHOOSE OF b-cancelar IN FRAME f-opt /* Cancelar */
DO:
    FOR EACH tt-apb:
        tt-apb.l-show = YES .
    END.
    {&open-query-b-apb}
    
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME f-apb
&Scoped-define SELF-NAME b-retornar-n-gerados
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-retornar-n-gerados w-win
ON CHOOSE OF b-retornar-n-gerados IN FRAME f-apb /* Retornar */
DO:
    RUN pi-retornar .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sel-all-apb
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sel-all-apb w-win
ON CHOOSE OF b-sel-all-apb IN FRAME f-apb /* Todos */
DO:
    b-apb:SELECT-ALL() NO-ERROR .
    APPLY "ITERATION-CHANGED" TO b-apb .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sel-non-apb
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sel-non-apb w-win
ON CHOOSE OF b-sel-non-apb IN FRAME f-apb /* Nenhum */
DO:
    b-apb:DESELECT-ROWS() .
    APPLY "ITERATION-CHANGED" TO b-apb .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME f-opt
&Scoped-define SELF-NAME bt-Atualizar
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-Atualizar w-win
ON CHOOSE OF bt-Atualizar IN FRAME f-opt /* Atualizar */
DO:
    EMPTY TEMP-TABLE tt-tit_ap.
    RUN carrega-b-apb .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-gerar
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-gerar w-win
ON CHOOSE OF bt-gerar IN FRAME f-opt /* Gerar */
DO:
    SYSTEM-DIALOG GET-DIR cDirReturn
        INITIAL-DIR 'C:\Totvs\work\integPref\' 
        RETURN-TO-START-DIR
        TITLE 'Escolha o Diret¢rio Onde os Arquivos Ser∆o Gerados'
        .
    IF cDirReturn = ? THEN
        RETURN "NOK".        
    
    RUN geracao.
    
    IF t-teste:INPUT-VALUE IN FRAME f-apb = "NO" THEN
        RUN efetivacao.
        
    MESSAGE "Arquivo(s) gerado(s) em " cDirReturn VIEW-AS ALERT-BOX.
    ASSIGN cDirReturn = ?.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-dt-transacao
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-dt-transacao w-win
ON LEAVE OF f-dt-transacao IN FRAME f-opt /* Màs/Ano Transaá∆o */
DO:
    IF f-dt-transacao:input-value < 1 or
       f-dt-transacao:input-value > 12 THEN DO:
       message "O màs de transaá∆o inv†lido. Deve ser um valor entre 1 e 12." view-as alert-box.
       APPLY "MOUSE-SELECT-DBLCLICK":U TO f-dt-transacao IN FRAME f-opt.
    END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME mi-sair
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL mi-sair w-win
ON CHOOSE OF MENU-ITEM mi-sair /* Sair */
DO:
    APPLY "WINDOW-CLOSE" TO w-win .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME mi-sobre
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL mi-sobre w-win
ON CHOOSE OF MENU-ITEM mi-sobre /* Sobre... */
DO:
  {include/sobre.i}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME f-apb
&Scoped-define SELF-NAME t-gerados
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL t-gerados w-win
ON VALUE-CHANGED OF t-gerados IN FRAME f-apb /* Gerados */
DO:
    RUN pi-framecontroller .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME t-nao-gerado
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL t-nao-gerado w-win
ON VALUE-CHANGED OF t-nao-gerado IN FRAME f-apb /* N∆o Gerados */
DO:
    RUN pi-framecontroller .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME f-opt
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK w-win 


/* ***************************  Main Block  *************************** */

/*Zooms*/


/* Include custom  Main Block code for SmartWindows. */
{src/adm/template/windowmn.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE adm-create-objects w-win  _ADM-CREATE-OBJECTS
PROCEDURE adm-create-objects :
/*------------------------------------------------------------------------------
  Purpose:     Create handles for all SmartObjects used in this procedure.
               After SmartObjects are initialized, then SmartLinks are added.
  Parameters:  <none>
------------------------------------------------------------------------------*/

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE adm-row-available w-win  _ADM-ROW-AVAILABLE
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE carrega-apb w-win 
PROCEDURE carrega-apb :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
/*Validaá∆o*/
/**/


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE carrega-b-apb w-win 
PROCEDURE carrega-b-apb :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

RUN utp/ut-acomp.p PERSISTENT SET h-acomp.
RUN pi-inicializar IN h-acomp (INPUT 'Carregando Titulos...') .

DEFINE BUFFER b-fornecedor FOR ems5.fornecedor.
DEFINE BUFFER b-pessoa_jurid FOR pessoa_jurid.

FIND FIRST fornecedor WHERE fornecedor.cdn_fornecedor = cb-prefeituras:INPUT-VALUE IN FRAME f-opt NO-LOCK NO-ERROR.
FIND FIRST pessoa_jurid WHERE pessoa_jurid.cod_id_feder = fornecedor.cod_id_feder NO-LOCK NO-ERROR.
assign c-prefeitura = pessoa_jurid.nom_cidade.

ASSIGN i-tit = 0 
       d-soma-ger = 0
       d-soma-nger = 0.

DEF VAR data-ini    AS DATE NO-UNDO .
DEF VAR data-fim    AS DATE NO-UNDO .
ASSIGN 
    data-ini = DATE(INPUT FRAME f-opt f-dt-transacao , 1 , INPUT FRAME f-opt f-ano)
    data-fim = ADD-INTERVAL(data-ini , 1 , "months")
    data-fim = ADD-INTERVAL(data-fim , -1 , "days")
    .

/*MESSAGE data-ini SKIP data-fim VIEW-AS ALERT-BOX .*/

FOR EACH pessoa_jurid_ativid 
        NO-LOCK,
    EACH pessoa_jurid 
        WHERE pessoa_jurid.num_pessoa_jurid = pessoa_jurid_ativid.num_pessoa_jurid
        NO-LOCK,
    FIRST fornecedor 
        /*WHERE fornecedor.cod_id_feder = pessoa_jurid.cod_id_feder*/
        WHERE fornecedor.num_pessoa = pessoa_jurid.num_pessoa_jurid
        NO-LOCK,
    EACH tit_ap
        WHERE tit_ap.cdn_fornecedor         = fornecedor.cdn_fornecedor
          /*and month(tit_ap.dat_emis_docto)  = f-dt-transacao:input-value IN FRAME f-opt
          and year(tit_ap.dat_emis_docto)   = f-ano:input-value IN FRAME f-opt*/
          AND tit_ap.dat_emis_docto         >= data-ini
          AND tit_ap.dat_emis_docto         <= data-fim
          and (tit_ap.cod_espec_docto       = 'NF'
           or tit_ap.cod_espec_docto        = 'FL')
        NO-LOCK,    
    EACH movto_tit_ap
        WHERE movto_tit_ap.cod_estab            = tit_ap.cod_estab
          AND movto_tit_ap.num_id_tit_ap        = tit_ap.num_id_tit_ap
          AND movto_tit_ap.ind_trans_ap_abrev   = "IMPL"
          AND movto_tit_ap.log_movto_estordo    = NO
        NO-LOCK,
    FIRST estabelecimento
        WHERE estabelecimento.cod_empresa   = tit_ap.cod_empresa
          AND estabelecimento.cod_estab     = tit_ap.cod_estab
        NO-LOCK
    BREAK BY tit_ap.cod_estab
    :
    FIND FIRST b-pessoa_jurid 
        WHERE b-pessoa_jurid.num_pessoa_jurid = estabelecimento.num_pessoa_jurid NO-LOCK NO-ERROR.   
    IF b-pessoa_jurid.nom_cidade <> c-prefeitura THEN
        NEXT.    
        
    FIND FIRST tt-tit_ap WHERE tt-tit_ap.cod_estab          = tit_ap.cod_estab
                           AND tt-tit_ap.cdn_fornecedor     = tit_ap.cdn_fornecedor
                           AND tt-tit_ap.cod_espec_docto    = tit_ap.cod_espec_docto
                           AND tt-tit_ap.cod_ser_docto      = tit_ap.cod_ser_docto
                           AND tt-tit_ap.cod_tit_ap         = tit_ap.cod_tit_ap                           
                           AND tt-tit_ap.cod_parcela        = tit_ap.cod_parcela
                               NO-LOCK NO-ERROR.
    IF AVAIL tt-tit_ap THEN
        NEXT.
    
    assign i-tit = i-tit + 1.
/*
    IF i-tit >15 THEN
        LEAVE.
*/      

    RUN pi-acompanhar IN h-acomp (INPUT 'Carregando titulo: ' + string(i-tit) + ' - ' + tit_ap.cod_tit_ap).
        
    EMPTY TEMP-TABLE tt-compl_impto_retid_ap.
    FOR EACH b-fornecedor 
        WHERE b-fornecedor.cod_grp_fornec = '26'
        NO-LOCK:
        FIND FIRST compl_impto_retid_ap 
            WHERE compl_impto_retid_ap.cod_estab = movto_tit_ap.cod_estab
                AND compl_impto_retid_ap.num_id_movto_tit_ap_pai = movto_tit_ap.num_id_movto_tit_ap 
                AND compl_impto_retid_ap.cdn_fornec_favorec = b-fornecedor.cdn_fornecedor
                NO-LOCK NO-ERROR.            

        IF AVAIL compl_impto_retid_ap THEN DO:
            CREATE tt-compl_impto_retid_ap .
            BUFFER-COPY compl_impto_retid_ap to tt-compl_impto_retid_ap.
        END.
    END.

    FIND FIRST b-pessoa_jurid
        WHERE b-pessoa_jurid.num_pessoa_jurid = estabelecimento.num_pessoa_jurid
        NO-LOCK NO-ERROR.
    
    FIND LAST cst_tit_ap_gerado
        OF tit_ap NO-LOCK NO-ERROR.
        
    IF (t-nao-gerado:INPUT-VALUE IN FRAME f-apb = YES) AND (t-gerados:INPUT-VALUE IN FRAME f-apb = NO)
        AND AVAIL cst_tit_ap_gerado AND cst_tit_ap_gerado.log_gerado = YES THEN
        NEXT.
        
    IF (t-nao-gerado:INPUT-VALUE IN FRAME f-apb = NO) AND (t-gerados:INPUT-VALUE IN FRAME f-apb = YES)
        AND ((NOT AVAIL cst_tit_ap_gerado) OR (AVAIL cst_tit_ap_gerado AND cst_tit_ap_gerado.log_gerado = NO)) THEN
        NEXT.   
        
    IF AVAIL cst_tit_ap_gerado AND cst_tit_ap_gerado.log_gerado = YES THEN
        ASSIGN d-soma-ger = d-soma-ger + 1 . 
    IF NOT AVAIL cst_tit_ap_gerado or cst_tit_ap_gerado.log_gerado = NO THEN
        ASSIGN d-soma-nger = d-soma-nger + 1 .             
               
    /**/
    create tt-tit_ap.
    assign tt-tit_ap.num_id_tit_ap              = tit_ap.num_id_tit_ap
           tt-tit_ap.cod_estab                  = tit_ap.cod_estab
           tt-tit_ap.cod_espec_docto            = tit_ap.cod_espec_docto
           tt-tit_ap.cod_ser_docto              = tit_ap.cod_ser_docto
           tt-tit_ap.cod_tit_ap                 = tit_ap.cod_tit_ap
           tt-tit_ap.cod_parcela                = tit_ap.cod_parcela
           tt-tit_ap.dat_emis_doct              = tit_ap.dat_emis_docto
           tt-tit_ap.dat_transacao              = movto_tit_ap.dat_transacao
           tt-tit_ap.dat_vencto_tit_ap          = tit_ap.dat_vencto_tit_ap
           tt-tit_ap.val_origin_tit_ap          = tit_ap.val_origin_tit_ap 
           tt-tit_ap.cod_imposto                = IF AVAIL tt-compl_impto_retid_ap    
                                                    THEN tt-compl_impto_retid_ap.cod_imposto
                                                    ELSE "" 
           tt-tit_ap.cod_classif_impto          = IF AVAIL tt-compl_impto_retid_ap 
                                                    THEN tt-compl_impto_retid_ap.cod_classif_impto
                                                    ELSE "" 
           tt-tit_ap.val_aliq_impto             = IF AVAIL tt-compl_impto_retid_ap 
                                                    THEN tt-compl_impto_retid_ap.val_aliq_impto
                                                    ELSE 0 
           tt-tit_ap.cod_ativid_pessoa_jurid    = pessoa_jurid_ativid.cod_ativid_pessoa_jurid
           tt-tit_ap.cdn_fornecedor             = tit_ap.cdn_fornecedor
           tt-tit_ap.nom_pessoa                 = fornecedor.nom_pessoa
           tt-tit_ap.log_gerado                 = IF AVAIL cst_tit_ap_gerado
                                                    THEN cst_tit_ap_gerado.log_gerado
                                                    ELSE NO
           tt-tit_ap.cod_usuar_gera             = IF AVAIL cst_tit_ap_gerado
                                                    THEN cst_tit_ap_gerado.cod_usuar_gera
                                                    ELSE ""
           tt-tit_ap.dat_geracao                = IF AVAIL cst_tit_ap_gerado
                                                    THEN cst_tit_ap_gerado.dat_geracao
                                                    ELSE ? 
           tt-tit_ap.cod_id_feder_estab         = estabelecimento.cod_id_feder
           tt-tit_ap.cod_id_munic_jurid_estab   = b-pessoa_jurid.cod_id_munic_jurid
           tt-tit_ap.nom_pessoa_estab           = b-pessoa_jurid.nom_pessoa
           tt-tit_ap.val_base_liq_impto         = IF AVAIL tt-compl_impto_retid_ap 
                                                    THEN tt-compl_impto_retid_ap.val_base_liq_impto
                                                    ELSE 0  
           tt-tit_ap.cod_id_feder               = pessoa_jurid.cod_id_feder                                         
           tt-tit_ap.log_pessoa_jurid           = YES                                         
           .

END.      

FOR EACH pessoa_fisic 
        WHERE pessoa_fisic.cod_telex <> '' /* COD_TELEX foi o campo estipulado para ser o campo de atividade na pessoa fisica */
        NO-LOCK,
    FIRST fornecedor 
        WHERE fornecedor.cod_id_feder = pessoa_fisic.cod_id_feder
        NO-LOCK,
    FIRST movto_tit_ap
        WHERE movto_tit_ap.cdn_fornecedor       = fornecedor.cdn_fornecedor
          AND movto_tit_ap.ind_trans_ap_abrev   = "IMPL"
          AND movto_tit_ap.log_movto_estordo    = NO
        NO-LOCK,
    EACH tit_ap
        WHERE tit_ap.cod_estab      = movto_tit_ap.cod_estab
          and tit_ap.num_id_tit_ap  = movto_tit_ap.num_id_tit_ap
          and month(tit_ap.dat_emis_docto)  = f-dt-transacao:input-value IN FRAME f-opt
          and year(tit_ap.dat_emis_docto)   = f-ano:input-value IN FRAME f-opt
          and (tit_ap.cod_espec_docto = 'NF'
           or tit_ap.cod_espec_docto = 'FL')
        NO-LOCK,
    FIRST estabelecimento
        WHERE estabelecimento.cod_empresa   = tit_ap.cod_empresa
          AND estabelecimento.cod_estab     = tit_ap.cod_estab
        NO-LOCK
    BREAK BY tit_ap.cod_estab:
        
    EMPTY TEMP-TABLE tt-compl_impto_retid_ap.
    FOR EACH b-fornecedor 
        WHERE b-fornecedor.cod_grp_fornec = '26'
        NO-LOCK:
        FIND FIRST compl_impto_retid_ap 
            WHERE compl_impto_retid_ap.num_id_movto_tit_ap_pai = movto_tit_ap.num_id_movto_tit_ap 
                AND compl_impto_retid_ap.cdn_fornec_favorec = b-fornecedor.cdn_fornecedor
                NO-LOCK NO-ERROR.            

        IF AVAIL compl_impto_retid_ap THEN DO:
            CREATE tt-compl_impto_retid_ap .
            BUFFER-COPY compl_impto_retid_ap to tt-compl_impto_retid_ap.
        END.
            
    END.
    
    FIND FIRST tt-tit_ap WHERE tt-tit_ap.cod_estab          = tit_ap.cod_estab
                           AND tt-tit_ap.cdn_fornecedor     = tit_ap.cdn_fornecedor
                           AND tt-tit_ap.cod_espec_docto    = tit_ap.cod_espec_docto
                           AND tt-tit_ap.cod_ser_docto      = tit_ap.cod_ser_docto
                           AND tt-tit_ap.cod_tit_ap         = tit_ap.cod_tit_ap                           
                           AND tt-tit_ap.cod_parcela        = tit_ap.cod_parcela
                               NO-LOCK NO-ERROR.
    IF AVAIL tt-tit_ap THEN
        NEXT. 
    
    FIND FIRST b-pessoa_jurid
        WHERE b-pessoa_jurid.num_pessoa_jurid = estabelecimento.num_pessoa_jurid
        NO-LOCK NO-ERROR.
    
    FIND FIRST cst_tit_ap_gerado
        OF tit_ap NO-LOCK NO-ERROR.
        
    IF (t-nao-gerado:INPUT-VALUE IN FRAME f-apb = YES) AND (t-gerados:INPUT-VALUE IN FRAME f-apb = NO)
        AND AVAIL cst_tit_ap_gerado AND cst_tit_ap_gerado.log_gerado = YES THEN
        NEXT.
  
    IF (t-nao-gerado:INPUT-VALUE IN FRAME f-apb = NO) AND (t-gerados:INPUT-VALUE IN FRAME f-apb = YES)
        AND ((NOT AVAIL cst_tit_ap_gerado) OR (AVAIL cst_tit_ap_gerado AND cst_tit_ap_gerado.log_gerado = NO)) THEN
        NEXT.     
        
    IF AVAIL cst_tit_ap_gerado AND cst_tit_ap_gerado.log_gerado = YES THEN
        ASSIGN d-soma-ger = d-soma-ger + 1 . 
    IF NOT AVAIL cst_tit_ap_gerado OR cst_tit_ap_gerado.log_gerado = NO THEN
        ASSIGN d-soma-nger = d-soma-nger + 1 .  
              
    create tt-tit_ap.
    assign tt-tit_ap.num_id_tit_ap              = tit_ap.num_id_tit_ap
           tt-tit_ap.cod_estab                  = tit_ap.cod_estab
           tt-tit_ap.cod_espec_docto            = tit_ap.cod_espec_docto
           tt-tit_ap.cod_ser_docto              = tit_ap.cod_ser_docto
           tt-tit_ap.cod_tit_ap                 = tit_ap.cod_tit_ap
           tt-tit_ap.cod_parcela                = tit_ap.cod_parcela
           tt-tit_ap.dat_emis_doct              = tit_ap.dat_emis_docto
           tt-tit_ap.dat_transacao              = movto_tit_ap.dat_transacao
           tt-tit_ap.dat_vencto_tit_ap          = tit_ap.dat_vencto_tit_ap
           tt-tit_ap.val_origin_tit_ap          = tit_ap.val_origin_tit_ap 
           tt-tit_ap.cod_imposto                = IF AVAIL tt-compl_impto_retid_ap    
                                                    THEN tt-compl_impto_retid_ap.cod_imposto
                                                    ELSE "" 
           tt-tit_ap.cod_classif_impto          = IF AVAIL tt-compl_impto_retid_ap 
                                                    THEN tt-compl_impto_retid_ap.cod_classif_impto
                                                    ELSE "" 
           tt-tit_ap.val_aliq_impto             = IF AVAIL tt-compl_impto_retid_ap 
                                                    THEN tt-compl_impto_retid_ap.val_aliq_impto
                                                    ELSE 0 
           tt-tit_ap.cod_ativid_pessoa_jurid    = pessoa_fisic.cod_telex 
           tt-tit_ap.cdn_fornecedor             = tit_ap.cdn_fornecedor
           tt-tit_ap.nom_pessoa                 = fornecedor.nom_pessoa
           tt-tit_ap.log_gerado                 = IF AVAIL cst_tit_ap_gerado
                                                    THEN cst_tit_ap_gerado.log_gerado
                                                    ELSE NO
           tt-tit_ap.cod_usuar_gera             = IF AVAIL cst_tit_ap_gerado
                                                    THEN cst_tit_ap_gerado.cod_usuar_gera
                                                    ELSE ""
           tt-tit_ap.dat_geracao                = IF AVAIL cst_tit_ap_gerado
                                                    THEN cst_tit_ap_gerado.dat_geracao
                                                    ELSE ? 
           tt-tit_ap.cod_id_feder_estab         = estabelecimento.cod_id_feder
           tt-tit_ap.cod_id_munic_jurid_estab   = b-pessoa_jurid.cod_id_munic_jurid
           tt-tit_ap.nom_pessoa_estab           = b-pessoa_jurid.nom_pessoa
           tt-tit_ap.val_base_liq_impto         = IF AVAIL tt-compl_impto_retid_ap 
                                                    THEN tt-compl_impto_retid_ap.val_base_liq_impto
                                                    ELSE 0  
           tt-tit_ap.cod_id_feder               = pessoa_fisic.cod_id_feder                          
           tt-tit_ap.log_pessoa_jurid           = NO
           .

END.  

/*
Titulos Relacionados - Acrescentar ao valor original do titulo os valores referentes a impostos retidos
*/
RUN pi-acompanhar IN h-acomp (INPUT "Titulos Relacionados").
FOR EACH tt-tit_ap NO-LOCK:
    FOR EACH movto_tit_ap NO-LOCK WHERE
        movto_tit_ap.cod_estab = tt-tit_ap.cod_estab AND
        movto_tit_ap.num_id_tit_ap = tt-tit_ap.num_id_tit_ap
        :
        FOR EACH compl_impto_retid_ap NO-LOCK WHERE
            compl_impto_retid_ap.cod_estab               = movto_tit_ap.cod_estab AND
            compl_impto_retid_ap.num_id_movto_tit_ap_pai = movto_tit_ap.num_id_movto_tit_ap
            :
            FIND b_tit_ap NO-LOCK WHERE
                b_tit_ap.cod_estab     = compl_impto_retid_ap.cod_estab AND
                b_tit_ap.num_id_tit_ap = compl_impto_retid_ap.num_id_tit_ap
                NO-ERROR .
            IF AVAIL b_tit_ap THEN DO:
                FIND espec_docto NO-LOCK OF b_tit_ap .
                IF espec_docto.ind_tip_espec_docto <> "Imposto Retido" THEN NEXT .
                ASSIGN tt-tit_ap.val_origin_tit_ap = tt-tit_ap.val_origin_tit_ap + b_tit_ap.val_origin_tit_ap .
            END.
        END.
    END.
END.
/**/

{&open-query-b-apb}

ASSIGN f-tot-nao-gerado:SCREEN-VALUE = string(d-soma-nger)
       f-tot-gerado:SCREEN-VALUE = string(d-soma-ger).


b-apb:SELECT-ALL() NO-ERROR .


RUN pi-finalizar IN h-acomp .

APPLY "ITERATION-CHANGED" TO b-apb .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI w-win  _DEFAULT-DISABLE
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
  IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(w-win)
  THEN DELETE WIDGET w-win.
  IF THIS-PROCEDURE:PERSISTENT THEN DELETE PROCEDURE THIS-PROCEDURE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE efetivacao w-win 
PROCEDURE efetivacao :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

RUN utp/ut-acomp.p PERSISTENT SET h-acomp.
RUN pi-inicializar IN h-acomp (INPUT 'Atualizando tabela de titulos gerados...') .

OUTPUT STREAM str-rp TO
    VALUE(SESSION:TEMP-DIR + "csap007.txt")
    NO-CONVERT .

FOR EACH b-tt-tit_ap NO-LOCK:

    RUN pi-acompanhar IN h-acomp (INPUT 'Atualizando Titulos gerados...') .
     
    create cst_tit_ap_gerado.
    assign cst_tit_ap_gerado.cod_estab          = b-tt-tit_ap.cod_estab
           cst_tit_ap_gerado.cdn_fornecedor     = b-tt-tit_ap.cdn_fornecedor
           cst_tit_ap_gerado.cod_espec_docto    = b-tt-tit_ap.cod_espec_docto
           cst_tit_ap_gerado.cod_ser_docto      = b-tt-tit_ap.cod_ser_docto
           cst_tit_ap_gerado.cod_tit_ap         = b-tt-tit_ap.cod_tit_ap
           cst_tit_ap_gerado.cod_parcela        = b-tt-tit_ap.cod_parcela
           cst_tit_ap_gerado.log_gerado         = YES
           cst_tit_ap_gerado.cod_usuar_gera     = v_cod_usuar_corren
           cst_tit_ap_gerado.dat_geracao        = TODAY
           cst_tit_ap_gerado.hra_geracao        = TIME.
           .
         
    /*UNDO , LEAVE .*/
END.

OUTPUT STREAM str-rp CLOSE .

OS-COMMAND NO-WAIT VALUE("start " + SESSION:TEMP-DIR + "csap007.txt")  .

/*Volta os valores*/

FOR EACH tt-apb WHERE 
    tt-apb.l-show = YES ,
    EACH tit_ap NO-LOCK WHERE
    ROWID(tit_ap) = tt-apb.r-rowid
    :
    ASSIGN tt-apb.vl-liquidar = tit_ap.val_sdo_tit_ap .
END.
/**/

RUN pi-finalizar IN h-acomp .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI w-win  _DEFAULT-ENABLE
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
  DISPLAY f-dt-transacao f-ano cb-prefeituras 
      WITH FRAME f-opt IN WINDOW w-win.
  ENABLE bt-Atualizar bt-gerar b-cancelar f-dt-transacao f-ano 
      WITH FRAME f-opt IN WINDOW w-win.
  {&OPEN-BROWSERS-IN-QUERY-f-opt}
  DISPLAY t-nao-gerado f-tot-nao-gerado f-sel-nao-gerado t-gerados f-tot-gerado 
          f-sel-gerado t-teste 
      WITH FRAME f-apb IN WINDOW w-win.
  ENABLE b-apb b-sel-all-apb b-sel-non-apb t-nao-gerado t-gerados t-teste 
      WITH FRAME f-apb IN WINDOW w-win.
  {&OPEN-BROWSERS-IN-QUERY-f-apb}
  VIEW w-win.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE geracao w-win 
PROCEDURE geracao :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

DEFINE VARIABLE linha   AS CHAR NO-UNDO.
DEFINE VARIABLE i-count AS INT NO-UNDO INIT 0.
DEFINE VARIABLE d-soma-val AS DEC NO-UNDO INIT 0.

RUN utp/ut-acomp.p PERSISTENT SET h-acomp.
RUN pi-inicializar IN h-acomp (INPUT 'Gerando Arquivo...') .

EMPTY TEMP-TABLE b-tt-tit_ap.

DO i = 1 TO b-apb:NUM-SELECTED-ROWS IN FRAME f-apb:
    b-apb:FETCH-SELECTED-ROW(i) .
        
    CREATE b-tt-tit_ap.
    BUFFER-COPY tt-tit_ap TO b-tt-tit_ap.
            
END.

FOR EACH b-tt-tit_ap NO-LOCK
    BREAK BY b-tt-tit_ap.cod_estab:
    
    IF FIRST-OF(b-tt-tit_ap.cod_estab) THEN DO:
    
        RUN pi-acompanhar IN h-acomp (INPUT 'Gerando Arquivo para estabelec: ' + b-tt-tit_ap.cod_id_feder_estab) .
            
        d-soma-val = 0.
        i-count = i-count + 1.
       
        OUTPUT TO VALUE(cDirReturn + '\PMC_' + string(f-dt-transacao:INPUT-VALUE IN FRAME f-opt,'99') + 
                '_' + f-ano:INPUT-VALUE IN FRAME F-opt + '_' + SUBSTRING(b-tt-tit_ap.cod_id_feder_estab, 9, 6) + '.txt').
      
        OVERLAY(linha, 1, 1)        = 'H'.                                      /* 001,001 - C¢digo do registro ?H? */
        OVERLAY(linha, 2, 10)       = IF b-tt-tit_ap.cod_id_munic_jurid_estab <> ?
                                        THEN string(int(b-tt-tit_ap.cod_id_munic_jurid_estab),'9999999999')
                                        ELSE ''.                                /* 002,011 - N£mero da Inscriá∆o Municipal do Declarante  */
        OVERLAY(linha, 12, 14)      = string(b-tt-tit_ap.cod_id_feder_estab, '99999999999999').           /* 012,025 - N£mero do CNPJ do Declarante no caso de pessoa jur°dica */
        OVERLAY(linha, 26, 11)      = ''.                                       /* 026,036 - N£mero do CPF do Declarante no caso de pessoa f°sica. */
        OVERLAY(linha, 37, 100)     = b-tt-tit_ap.nom_pessoa_estab.             /* 037,136 - Nome/Raz∆o Social do Declarante */
        OVERLAY(linha, 137, 1)      = IF t-teste:INPUT-VALUE IN FRAME f-apb = NO 
                                       THEN 'N'
                                       ELSE 'T'.                                /* 137,137 - Tipo do Arquivo enviado para a Prefeitura, podendo ser: N ? normal ou       T ? Teste */
        OVERLAY(linha, 138, 2)      = string(f-dt-transacao:INPUT-VALUE IN FRAME F-opt,'99').   /* 138,139 - Màs de referància dos documentos declarados */
        OVERLAY(linha, 140, 4)      = string(f-ano:INPUT-VALUE IN FRAME F-opt,'9999').          /* 140,143 - Ano de referància dos documentos declarados */
        OVERLAY(linha, 144, 252)    = ''.                                       /* 144,395 - Brancos ? reservado para futuro */
        OVERLAY(linha, 396, 1)      = '.'.                                      /* 396,396 - Caracter fixo = . (ponto)  */
       
        PUT UNFORMATTED linha skip.
    
    END.
    
    i-count = i-count + 1.
    
    OVERLAY(linha, 1, 1)        = 'R'.                                                  /* 001,001  - C¢digo do registro ?R? */
    OVERLAY(linha, 2, 8)        = string(b-tt-tit_ap.dat_emis_docto,'99999999').        /* 002,009  - Data de emiss∆o do documento recebido.  */
    OVERLAY(linha, 10, 8)       = substring(b-tt-tit_ap.cod_tit_ap,3,8).                               /* 010,017  - N£mero do documento recebido */
    OVERLAY(linha, 18, 8)       = ''.                                                   /* 018,025  - Deixar com brancos */
    OVERLAY(linha, 26, 1)       = IF b-tt-tit_ap.cod_espec_docto = 'NF'
                                    THEN '1'
                                    ELSE '3'.                                           /* 026,026  - Identificaá∆o do Tipo de Documento recebido. (1. Nota Fiscal, 2. Recibo Comum, 3. RPA - Recibo Pagamento Autìnomo, 4. Cupom Fiscal, 5. Outros, 6. Conhecimento de Transporte) */
    OVERLAY(linha, 27, 3)       = IF b-tt-tit_ap.cod_espec_docto = 'NF'
                                    THEN b-tt-tit_ap.cod_ser_docto
                                    ELSE ''.                                            /* 027,029  - SÇrie do Documento recebido quando o campo R.05 = Nota Fiscal */
    OVERLAY(linha, 30, 1)       = IF b-tt-tit_ap.cod_imposto <> ''
                                    THEN 'S'
                                    ELSE 'N'.                                           /* 030,030  - Identificaá∆o do Serviáo Tomado caracterizando Substituiá∆o Tribut†ria / Retená∆o ‡rg∆o P£blico, retená∆o na fonte ou Doc.Fiscal Normal
                                    S ? caracteriza substituiá∆o tribut†ria/retená∆o ¢rg∆o p£blico
                                    R ? caracteriza retená∆o na fonte 
                                    N ?caracteriza Doc.Fiscal Normal */
    OVERLAY(linha, 31, 1)       = 'D'.                                                 /* 031,031  - Indicador do Local de Prestaá∆o do Serviáo quando o serviáo tomado caracterizar substituiá∆o tribut†ria / retená∆o ¢rg∆o p£blico, de acordo com o campo R.07.
                                                                                       D ? Dentro do Munic°pio
                                                                                       F ? Fora do Munic°pio */
    OVERLAY(linha, 32, 4)       = b-tt-tit_ap.cod_ativid_pessoa_jurid.                  /* 032,033  - C¢digo do Item da Lista de Serviáos (Lei Complementar 116/2003). */
    /* OVERLAY(linha, 34, 2)    =  Item anterior est† ocupando ambos os campos */       /* 034,035  - C¢digo do Sub-item da Lista de Serviáos (Lei Complementar 116/2003). */
    OVERLAY(linha, 36, 15)      = string((b-tt-tit_ap.val_origin_tit_ap * 100),'999999999999999').      /* 036,050  - Valor do documento recebido.  */
    OVERLAY(linha, 51, 15)      = '000000000000000'.     /* 051,065  - Valor de deduá∆o do documento emitido conforme legislaá∆o tribut†ria municipal pertinente. */
    OVERLAY(linha, 66, 10)      = b-tt-tit_ap.cod_id_munic_jurid.                       /* 066,075  - N£mero da inscriá∆o municipal do prestador de serviáo. */
    OVERLAY(linha, 76, 14)      = IF b-tt-tit_ap.log_pessoa_jurid = YES
                                    THEN b-tt-tit_ap.cod_id_feder
                                    ELSE ''.                                            /* 076,089  - N£mero do CNPJ do prestador de serviáo quando este for Pessoa Jur°dica */
    OVERLAY(linha, 90, 11)      = IF b-tt-tit_ap.log_pessoa_jurid = NO
                                    THEN b-tt-tit_ap.cod_id_feder
                                    ELSE ''.                                            /* 090,100  - N£mero do CPF do prestador de serviáo quando este for Pessoa F°sica */
    OVERLAY(linha, 101, 100)    = b-tt-tit_ap.nom_pessoa.                               /* 101,200  - Nome ou Raz∆o Social do prestador de serviáo  */
    OVERLAY(linha, 201, 5)      = ''.                                                   /* 201,205  - Identificaá∆o do Tipo do Logradouro do Endereáo do prestador de serviáo 
                                                                                        Siglas a serem utilizadas: AV.Avenida - ROT.R¢tula - R.Rua - TV.Travessa - AL.Alameda - EST.Estrada - ROD.Rodovia - VAR.Variante - PC.Praáa - LG.Largo - JDTE.Jardinete - 
                                                                                        PQ.Parque - RIO Rio - TER.Terminal - AT.Alto - BC.Beco - CJTO.Conjunto - GL.Galeria - GR.Granja - LA Lagoa - LD.Ladeira - LT.Loteamento - PÄ Paáo - VILA Vila - SL.Salina - 
                                                                                        SIT.S°tio - VEL.Viela - VIAD.Viaduto - SER.Servid∆o - JAR.Jardim   */
    OVERLAY(linha, 206, 50)     = ''.                                           /* 206,255  - Nome do Logradouro do Endereáo do prestador de serviáo  */
    OVERLAY(linha, 256, 6)      = ''.                                           /* 256,261  - N£mero do Endereáo do prestador de serviáo  */
    OVERLAY(linha, 262, 20)     = ''.                                           /* 262,281  - Complemento do Endereáo do prestador  de serviáo  */
    OVERLAY(linha, 282, 50)     = ''.                                           /* 282,331  - Bairro do Endereáo do prestador de serviáo  */
    OVERLAY(linha, 332, 44)     = ''.                                           /* 332,375  - Cidade do Endereáo do prestador de serviáo  */
    OVERLAY(linha, 376, 2)      = ''.                                           /* 376,377  - Estado da Cidade do Endereáo do prestador de serviáo */
    OVERLAY(linha, 378, 8)      = ''.                                           /* 378,385  - Cep do Endereáo do prestador de serviáo  */
    OVERLAY(linha, 386, 6)      = string(i-count,'99999999').                           /* 386,391  - N£mero seqÅencial do registro dentro do arquivo */
    OVERLAY(linha, 392, 4)      = string((b-tt-tit_ap.val_aliq_impto * 100), '9999').           /* 392,395  - Valor percentual da al°quota */
    OVERLAY(linha, 396, 1)      = '.'.                                                  /* 396,396  - Caracter fixo = . (ponto) */
    
    d-soma-val = d-soma-val + (b-tt-tit_ap.val_origin_tit_ap * 100).
    
    PUT UNFORMATTED linha skip.
    
    IF LAST-OF(b-tt-tit_ap.cod_estab) THEN DO:
    
    i-count = i-count + 1.
        
        OVERLAY(linha, 1, 1)        = 'T'.                              /* 001,001      C¢digo do registro ?T? */
        OVERLAY(linha, 002,  8)     = string(i-count,'99999999').               /* 002,009      Quantidade total de registros do arquivo, incluindo o header (H) e trailler (T) */
        OVERLAY(linha, 010, 15)     = '000000000000000'.                /* 010,024      Valor Total dos Documentos emitidos  pelo Prestador de Serviáos. Soma de todos os valores descritos nos campos E.11 */
        OVERLAY(linha, 025, 15)     = '000000000000000'.                /* 025,039      Valor Total das Deduá‰es dos Documentos emitidos pelo Prestador de Serviáos. Soma de todos os valores descritos nos campos E.12 */
        OVERLAY(linha, 040, 15)     = string(d-soma-val,'999999999999999').     /* 040,054      Valor Total dos Documentos recebidos  pelo tomador de Serviáos. Soma de todos os valores descritos nos campos R.11 */
        OVERLAY(linha, 055, 15)     = '000000000000000'.                /* 055,069      Valor Total das Deduá‰es dos Documentos recebidos  pelo tomador de Serviáos. Soma de todos os valores descritos nos campos R.12 */
        OVERLAY(linha, 070, 326)    = ''.               /* 070,395      Brancos ? reservado para futuro */
        OVERLAY(linha, 396, 1)      = '.'.              /* 396,396      Caracter fixo = . (ponto) */
        
        PUT UNFORMATTED linha skip.
        
        OUTPUT CLOSE.                        
    END.

END.

RUN pi-finalizar IN h-acomp .



END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-destroy w-win 
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-exit w-win 
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-initialize w-win 
PROCEDURE local-initialize :
/*------------------------------------------------------------------------------
  Purpose:     Override standard ADM method
  Notes:       
------------------------------------------------------------------------------*/

  /* Code placed here will execute PRIOR to standard behavior. */
  /*{include/win-size.i}*/
  {utp/ut9000.i "{&program_name}" "{&program_version}"}

  RUN pi_aplica_facelift_thin IN h-facelift (FRAME f-apb:HANDLE) .
  RUN pi_aplica_facelift_thin IN h-facelift (FRAME f-opt:HANDLE) .

  /* Dispatch standard ADM method.                             */
  RUN dispatch IN THIS-PROCEDURE ( INPUT 'initialize':U ) .

  /* Code placed here will execute AFTER standard behavior.    */

    f-dt-transacao:SCREEN-VALUE = STRING(month(TODAY)) .
    f-ano:SCREEN-VALUE = STRING(year(TODAY)) .
  
    cb-prefeituras:DELETE(1).
  
    for each fornecedor 
        where fornecedor.cod_grp_fornec = '26'
        no-lock:
        cb-prefeituras:ADD-LAST(fornecedor.nom_pessoa, string(cdn_fornecedor)) IN FRAME f-opt.            
    end.
        
    assign cb-prefeituras:SCREEN-VALUE IN FRAME f-opt = '2197'.

/* DESABILITARAS PROXIMA LINHA QUANDO MAIS PREFEITURAS FOREM ADICIONADAS */
        .cb-prefeituras:SENSITIVE = NO.
   
 
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-framecontroller w-win 
PROCEDURE pi-framecontroller :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

ASSIGN b-retornar-n-gerados:SENSITIVE IN FRAME f-apb = NO .

IF INPUT FRAME f-apb t-gerados = YES AND
   INPUT FRAME f-apb t-nao-gerado = NO 
THEN DO:
    ASSIGN b-retornar-n-gerados:SENSITIVE IN FRAME f-apb = YES .
END.

RETURN "OK":U .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-retornar w-win 
PROCEDURE pi-retornar :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
DO i = 1 TO b-apb:NUM-SELECTED-ROWS IN FRAME f-apb:
    b-apb:FETCH-SELECTED-ROW(i) .
    FOR EACH cst_tit_ap_gerado EXCLUSIVE-LOCK WHERE
        cst_tit_ap_gerado.cod_estab         = tt-tit_ap.cod_estab AND
        cst_tit_ap_gerado.cdn_fornecedor    = tt-tit_ap.cdn_fornecedor AND 
        cst_tit_ap_gerado.cod_espec_docto   = tt-tit_ap.cod_espec_docto AND
        cst_tit_ap_gerado.cod_ser_docto     = tt-tit_ap.cod_ser_docto AND
        cst_tit_ap_gerado.cod_tit_ap        = tt-tit_ap.cod_tit_ap AND
        cst_tit_ap_gerado.cod_parcela       = tt-tit_ap.cod_parcela
        :
        DELETE cst_tit_ap_gerado .
    END.
    FIND CURRENT tt-tit_ap . 
    DELETE tt-tit_ap .
END.

b-apb:REFRESH() .

RETURN "OK":U .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE send-records w-win  _ADM-SEND-RECORDS
PROCEDURE send-records :
/*------------------------------------------------------------------------------
  Purpose:     Send record ROWID's for all tables used by
               this file.
  Parameters:  see template/snd-head.i
------------------------------------------------------------------------------*/

  /* Define variables needed by this internal procedure.               */
  {src/adm/template/snd-head.i}

  /* For each requested table, put it's ROWID in the output list.      */
  {src/adm/template/snd-list.i "tt-tit_ap"}

  /* Deal with any unexpected table requests before closing.           */
  {src/adm/template/snd-end.i}

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE state-changed w-win 
PROCEDURE state-changed :
/*:T -----------------------------------------------------------
  Purpose:     Manuseia trocas de estado dos SmartObjects
  Parameters:  <none>
  Notes:       
-------------------------------------------------------------*/
  DEFINE INPUT PARAMETER p-issuer-hdl AS HANDLE NO-UNDO.
  DEFINE INPUT PARAMETER p-state AS CHARACTER NO-UNDO.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

