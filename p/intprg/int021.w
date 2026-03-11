&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI ADM1
&ANALYZE-RESUME
/* Connected Databases 
*/
&Scoped-define WINDOW-NAME W-Win
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS W-Win 
/*********************************************************************
* Copyright (C) 2000 by Progress Software Corporation. All rights    *
* reserved. Prior versions of this work may contain portions         *
* contributed by participants of Possenet.                           *
*                                                                    *
*********************************************************************/
DEFINE BUFFER cliente FOR emscad.cliente.
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
def new global shared var v_rec_clien_financ
    as recid
    format ">>>>>>9":U
    initial ?
    no-undo.
/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */

DEFINE TEMP-TABLE tt-tit-acr     LIKE tit_acr
    FIELD marca  AS LOGICAL FORMAT "*/ "
    FIELD mostra AS LOGICAL FORMAT "Sim/N∆o".
DEFINE TEMP-TABLE tt-tit-acr-sel LIKE tit_acr
    FIELD marca AS LOGICAL FORMAT "*/ "
    FIELD r-rowid AS ROWID.


DEFINE VARIABLE c-cod-refer      AS CHARACTER                NO-UNDO.
DEFINE VARIABLE h-acomp          AS HANDLE                   NO-UNDO.
DEFINE VARIABLE c_cod_table      AS CHARACTER                NO-UNDO.
DEFINE VARIABLE v_log_refer_uni  AS LOGICAL                  NO-UNDO.

{intprg\int021.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE SmartWindow
&Scoped-define DB-AWARE no

&Scoped-define ADM-CONTAINER WINDOW

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME F-Main
&Scoped-define BROWSE-NAME br-tit-acr

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-tit-acr tt-tit-acr-sel

/* Definitions for BROWSE br-tit-acr                                    */
&Scoped-define FIELDS-IN-QUERY-br-tit-acr tt-tit-acr.marca tt-tit-acr.cod_estab tt-tit-acr.cdn_cliente tt-tit-acr.nom_abrev tt-tit-acr.cod_espec_docto tt-tit-acr.cod_ser_docto tt-tit-acr.cod_tit_acr tt-tit-acr.cod_parcela tt-tit-acr.dat_vencto_origin_tit_acr tt-tit-acr.val_sdo_tit_acr   
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-tit-acr   
&Scoped-define SELF-NAME br-tit-acr
&Scoped-define QUERY-STRING-br-tit-acr FOR EACH tt-tit-acr WHERE tt-tit-acr.mostra = YES
&Scoped-define OPEN-QUERY-br-tit-acr OPEN QUERY {&SELF-NAME} FOR EACH tt-tit-acr WHERE tt-tit-acr.mostra = YES.
&Scoped-define TABLES-IN-QUERY-br-tit-acr tt-tit-acr
&Scoped-define FIRST-TABLE-IN-QUERY-br-tit-acr tt-tit-acr


/* Definitions for BROWSE br-tit-acr-sel                                */
&Scoped-define FIELDS-IN-QUERY-br-tit-acr-sel tt-tit-acr-sel.marca tt-tit-acr-sel.cod_estab tt-tit-acr-sel.cdn_cliente tt-tit-acr-sel.nom_abrev tt-tit-acr-sel.cod_espec_docto tt-tit-acr-sel.cod_ser_docto tt-tit-acr-sel.cod_tit_acr tt-tit-acr-sel.cod_parcela tt-tit-acr-sel.dat_vencto_origin_tit_acr tt-tit-acr-sel.val_sdo_tit_acr   
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-tit-acr-sel   
&Scoped-define SELF-NAME br-tit-acr-sel
&Scoped-define QUERY-STRING-br-tit-acr-sel FOR EACH tt-tit-acr-sel
&Scoped-define OPEN-QUERY-br-tit-acr-sel OPEN QUERY {&SELF-NAME} FOR EACH tt-tit-acr-sel.
&Scoped-define TABLES-IN-QUERY-br-tit-acr-sel tt-tit-acr-sel
&Scoped-define FIRST-TABLE-IN-QUERY-br-tit-acr-sel tt-tit-acr-sel


/* Definitions for FRAME F-Main                                         */
&Scoped-define OPEN-BROWSERS-IN-QUERY-F-Main ~
    ~{&OPEN-QUERY-br-tit-acr}~
    ~{&OPEN-QUERY-br-tit-acr-sel}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS RECT-1 RECT-2 rt-button IMAGE-1 IMAGE-2 ~
fi-estab fi-dt-emis fi-cliente-ini fi-cliente-fim tg-escolhe bt-carrega-tit ~
bt-zoom-cliente fi-cliente cb-convenio br-tit-acr bt-filtro bt-marca ~
bt-desmarca bt-incluir br-tit-acr-sel bt-marca-sel bt-desmarca-sel ~
bt-excluir bt-executar bt-cancelar 
&Scoped-Define DISPLAYED-OBJECTS fi-estab fi-dt-emis fi-cliente-ini ~
fi-cliente-fim tg-escolhe fi-cliente fi-nome-cliente cb-convenio 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR W-Win AS WIDGET-HANDLE NO-UNDO.

/* Definitions of the field level widgets                               */
DEFINE BUTTON bt-cancelar AUTO-END-KEY 
     LABEL "Fechar" 
     SIZE 10 BY 1.

DEFINE BUTTON bt-carrega-tit 
     IMAGE-UP FILE "image/im-cq.bmp":U
     IMAGE-INSENSITIVE FILE "image/ii-cq.bmp":U
     LABEL "Button 2" 
     SIZE 4 BY 1.

DEFINE BUTTON bt-desmarca 
     IMAGE-UP FILE "image/im-ran_n.bmp":U
     IMAGE-INSENSITIVE FILE "image/im-ran5i.bmp":U
     LABEL "Button 4" 
     SIZE 4 BY 1.

DEFINE BUTTON bt-desmarca-sel 
     IMAGE-UP FILE "image/im-ran_n.bmp":U
     IMAGE-INSENSITIVE FILE "image/im-ran5i.bmp":U
     LABEL "Button 7" 
     SIZE 4 BY 1.

DEFINE BUTTON bt-excluir 
     IMAGE-UP FILE "image/im-up2.bmp":U
     IMAGE-INSENSITIVE FILE "image/ii-up2.bmp":U
     LABEL "Button 8" 
     SIZE 4 BY 1.

DEFINE BUTTON bt-executar 
     LABEL "Executar" 
     SIZE 10 BY 1.

DEFINE BUTTON bt-filtro 
     IMAGE-UP FILE "image/im-ran.bmp":U
     IMAGE-INSENSITIVE FILE "image/ii-ran.bmp":U
     LABEL "Button 1" 
     SIZE 4 BY 1.

DEFINE BUTTON bt-incluir 
     IMAGE-UP FILE "image/im-down2.bmp":U
     IMAGE-INSENSITIVE FILE "image/ii-down2.bmp":U
     LABEL "Button 5" 
     SIZE 4 BY 1.

DEFINE BUTTON bt-marca 
     IMAGE-UP FILE "image/im-ran_a.bmp":U
     IMAGE-INSENSITIVE FILE "image/im-ran5i.bmp":U
     LABEL "Button 3" 
     SIZE 4 BY 1.

DEFINE BUTTON bt-marca-sel 
     IMAGE-UP FILE "image/im-ran_a.bmp":U
     IMAGE-INSENSITIVE FILE "image/im-ran5i.bmp":U
     LABEL "Button 6" 
     SIZE 4 BY 1.

DEFINE BUTTON bt-zoom-cliente 
     IMAGE-UP FILE "image/im-zoo":U
     IMAGE-INSENSITIVE FILE "image/ii-zoo":U
     LABEL "Button 2" 
     SIZE 4 BY 1.

DEFINE VARIABLE cb-convenio AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEM-PAIRS "Convànio","Convànio"
     DROP-DOWN-LIST
     SIZE 10.57 BY 1 NO-UNDO.

DEFINE VARIABLE fi-cliente AS INTEGER FORMAT ">>>>>>>>9":U INITIAL 0 
     LABEL "Cliente" 
     VIEW-AS FILL-IN 
     SIZE 14 BY .88 NO-UNDO.

DEFINE VARIABLE fi-cliente-fim AS INTEGER FORMAT ">>>>>>>>9":U INITIAL 99999999 
     VIEW-AS FILL-IN 
     SIZE 14 BY .88 NO-UNDO.

DEFINE VARIABLE fi-cliente-ini AS INTEGER FORMAT ">>>>>>>>9":U INITIAL 0 
     LABEL "Cliente" 
     VIEW-AS FILL-IN 
     SIZE 14 BY .88 NO-UNDO.

DEFINE VARIABLE fi-dt-emis AS DATE FORMAT "99/99/9999":U 
     LABEL "Data Emiss∆o" 
     VIEW-AS FILL-IN 
     SIZE 14 BY .88 NO-UNDO.

DEFINE VARIABLE fi-estab AS CHARACTER FORMAT "X(256)":U INITIAL "973" 
     LABEL "Estabelecimento" 
     VIEW-AS FILL-IN 
     SIZE 14 BY .88 NO-UNDO.

DEFINE VARIABLE fi-nome-cliente AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 46 BY .88 NO-UNDO.

DEFINE IMAGE IMAGE-1
     FILENAME "image\im-fir":U
     SIZE 3 BY .88.

DEFINE IMAGE IMAGE-2
     FILENAME "image\im-las":U
     SIZE 3 BY .88.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 88 BY 4.38.

DEFINE RECTANGLE RECT-2
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 88 BY 19.54.

DEFINE RECTANGLE rt-button
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 88 BY 1.42
     BGCOLOR 7 .

DEFINE VARIABLE tg-escolhe AS LOGICAL INITIAL no 
     LABEL "Escolhe Cliente" 
     VIEW-AS TOGGLE-BOX
     SIZE 20 BY .83 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-tit-acr FOR 
      tt-tit-acr SCROLLING.

DEFINE QUERY br-tit-acr-sel FOR 
      tt-tit-acr-sel SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-tit-acr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-tit-acr W-Win _FREEFORM
  QUERY br-tit-acr DISPLAY
      tt-tit-acr.marca COLUMN-LABEL " * "
 tt-tit-acr.cod_estab 
 tt-tit-acr.cdn_cliente 
 tt-tit-acr.nom_abrev 
 tt-tit-acr.cod_espec_docto 
 tt-tit-acr.cod_ser_docto 
 tt-tit-acr.cod_tit_acr 
 tt-tit-acr.cod_parcela 
 tt-tit-acr.dat_vencto_origin_tit_acr
 tt-tit-acr.val_sdo_tit_acr
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS MULTIPLE SIZE 81.72 BY 8.83 ROW-HEIGHT-CHARS .58 FIT-LAST-COLUMN.

DEFINE BROWSE br-tit-acr-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-tit-acr-sel W-Win _FREEFORM
  QUERY br-tit-acr-sel DISPLAY
      tt-tit-acr-sel.marca COLUMN-LABEL " * "
 tt-tit-acr-sel.cod_estab 
 tt-tit-acr-sel.cdn_cliente 
 tt-tit-acr-sel.nom_abrev 
 tt-tit-acr-sel.cod_espec_docto 
 tt-tit-acr-sel.cod_ser_docto 
 tt-tit-acr-sel.cod_tit_acr 
 tt-tit-acr-sel.cod_parcela 
 tt-tit-acr-sel.dat_vencto_origin_tit_acr
 tt-tit-acr-sel.val_sdo_tit_acr
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS MULTIPLE SIZE 81.72 BY 8.63 ROW-HEIGHT-CHARS .58 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME F-Main
     fi-estab AT ROW 2 COL 15.57 COLON-ALIGNED WIDGET-ID 10
     fi-dt-emis AT ROW 3 COL 15.57 COLON-ALIGNED WIDGET-ID 12
     fi-cliente-ini AT ROW 4.04 COL 15.57 COLON-ALIGNED WIDGET-ID 14
     fi-cliente-fim AT ROW 4.04 COL 36.14 COLON-ALIGNED NO-LABEL WIDGET-ID 16
     tg-escolhe AT ROW 4.13 COL 65 WIDGET-ID 18
     bt-carrega-tit AT ROW 5.92 COL 84.43 WIDGET-ID 34
     bt-zoom-cliente AT ROW 5.96 COL 22.72 WIDGET-ID 50
     fi-cliente AT ROW 6 COL 6.57 COLON-ALIGNED WIDGET-ID 24
     fi-nome-cliente AT ROW 6 COL 25 COLON-ALIGNED NO-LABEL WIDGET-ID 26
     cb-convenio AT ROW 6 COL 71.57 COLON-ALIGNED NO-LABEL WIDGET-ID 52
     br-tit-acr AT ROW 7.17 COL 2.29 WIDGET-ID 200
     bt-filtro AT ROW 7.21 COL 84.43 WIDGET-ID 28
     bt-marca AT ROW 8.21 COL 84.43 WIDGET-ID 36
     bt-desmarca AT ROW 9.21 COL 84.43 WIDGET-ID 38
     bt-incluir AT ROW 10.17 COL 84.43 WIDGET-ID 40
     br-tit-acr-sel AT ROW 16.25 COL 2.29 WIDGET-ID 300
     bt-marca-sel AT ROW 16.33 COL 84.43 WIDGET-ID 44
     bt-desmarca-sel AT ROW 17.33 COL 84.43 WIDGET-ID 46
     bt-excluir AT ROW 18.29 COL 84.43 WIDGET-ID 48
     bt-executar AT ROW 25.54 COL 2 HELP
          "Dispara a execuá∆o do relat¢rio" WIDGET-ID 32
     bt-cancelar AT ROW 25.54 COL 13 HELP
          "Fechar" WIDGET-ID 30
     "ParÉmentros" VIEW-AS TEXT
          SIZE 9.57 BY .67 AT ROW 1.04 COL 2.43 WIDGET-ID 8
     RECT-1 AT ROW 1.25 COL 1.43 WIDGET-ID 2
     RECT-2 AT ROW 5.71 COL 1.43 WIDGET-ID 4
     rt-button AT ROW 25.33 COL 1.29 WIDGET-ID 6
     IMAGE-1 AT ROW 4.08 COL 31.86 WIDGET-ID 20
     IMAGE-2 AT ROW 4.08 COL 35 WIDGET-ID 22
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 88.57 BY 25.96 WIDGET-ID 100.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: SmartWindow
   Allow: Basic,Browse,DB-Fields,Query,Smart,Window
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
IF SESSION:DISPLAY-TYPE = "GUI":U THEN
  CREATE WINDOW W-Win ASSIGN
         HIDDEN             = YES
         TITLE              = "Geraá∆o Convànio"
         HEIGHT             = 25.96
         WIDTH              = 88.57
         MAX-HEIGHT         = 25.96
         MAX-WIDTH          = 90.43
         VIRTUAL-HEIGHT     = 25.96
         VIRTUAL-WIDTH      = 90.43
         RESIZE             = no
         SCROLL-BARS        = no
         STATUS-AREA        = no
         BGCOLOR            = ?
         FGCOLOR            = ?
         THREE-D            = yes
         MESSAGE-AREA       = no
         SENSITIVE          = yes.
ELSE {&WINDOW-NAME} = CURRENT-WINDOW.
/* END WINDOW DEFINITION                                                */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _INCLUDED-LIB W-Win 
/* ************************* Included-Libraries *********************** */

{src/adm/method/containr.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME




/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW W-Win
  VISIBLE,,RUN-PERSISTENT                                               */
/* SETTINGS FOR FRAME F-Main
   FRAME-NAME                                                           */
/* BROWSE-TAB br-tit-acr cb-convenio F-Main */
/* BROWSE-TAB br-tit-acr-sel bt-incluir F-Main */
/* SETTINGS FOR FILL-IN fi-nome-cliente IN FRAME F-Main
   NO-ENABLE                                                            */
IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(W-Win)
THEN W-Win:HIDDEN = yes.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-tit-acr
/* Query rebuild information for BROWSE br-tit-acr
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH tt-tit-acr WHERE tt-tit-acr.mostra = YES.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE br-tit-acr */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-tit-acr-sel
/* Query rebuild information for BROWSE br-tit-acr-sel
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH tt-tit-acr-sel.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE br-tit-acr-sel */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME W-Win
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL W-Win W-Win
ON END-ERROR OF W-Win /* Geraá∆o Convànio */
OR ENDKEY OF {&WINDOW-NAME} ANYWHERE DO:
  /* This case occurs when the user presses the "Esc" key.
     In a persistently run window, just ignore this.  If we did not, the
     application would exit. */
  IF THIS-PROCEDURE:PERSISTENT THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL W-Win W-Win
ON WINDOW-CLOSE OF W-Win /* Geraá∆o Convànio */
DO:
  /* This ADM code must be left here in order for the SmartWindow
     and its descendents to terminate properly on exit. */
  APPLY "CLOSE":U TO THIS-PROCEDURE.
  RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-tit-acr
&Scoped-define SELF-NAME br-tit-acr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-tit-acr W-Win
ON MOUSE-SELECT-DBLCLICK OF br-tit-acr IN FRAME F-Main
DO:
  IF tt-tit-acr.marca = YES THEN
       ASSIGN tt-tit-acr.marca  = NO.
  ELSE ASSIGN tt-tit-acr.marca  = YES.

  br-tit-acr:REFRESH().
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-tit-acr-sel
&Scoped-define SELF-NAME br-tit-acr-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-tit-acr-sel W-Win
ON MOUSE-SELECT-DBLCLICK OF br-tit-acr-sel IN FRAME F-Main
DO:
  IF tt-tit-acr-sel.marca = YES THEN
       ASSIGN tt-tit-acr-sel.marca  = NO.
  ELSE ASSIGN tt-tit-acr-sel.marca  = YES.

  br-tit-acr-sel:REFRESH().
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-cancelar
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-cancelar W-Win
ON CHOOSE OF bt-cancelar IN FRAME F-Main /* Fechar */
DO:
   apply "close":U to this-procedure.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-carrega-tit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-carrega-tit W-Win
ON CHOOSE OF bt-carrega-tit IN FRAME F-Main /* Button 2 */
DO:
  RUN pi-carrega-titulos.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-desmarca
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-desmarca W-Win
ON CHOOSE OF bt-desmarca IN FRAME F-Main /* Button 4 */
DO:
  FOR EACH tt-tit-acr:
      ASSIGN tt-tit-acr.marca = NO.
  END.
  br-tit-acr:REFRESH().

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-desmarca-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-desmarca-sel W-Win
ON CHOOSE OF bt-desmarca-sel IN FRAME F-Main /* Button 7 */
DO:
  FOR EACH tt-tit-acr-sel:
      ASSIGN tt-tit-acr-sel.marca = NO.
  END.
  br-tit-acr-sel:REFRESH().
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-excluir
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-excluir W-Win
ON CHOOSE OF bt-excluir IN FRAME F-Main /* Button 8 */
DO:
    IF CAN-FIND(FIRST tt-tit-acr-sel
                WHERE tt-tit-acr-sel.marca = YES) THEN DO:
        FOR EACH tt-tit-acr-sel
         WHERE tt-tit-acr-sel.marca = YES :
    
         FIND FIRST tt-tit-acr 
              WHERE ROWID(tt-tit-acr)  = tt-tit-acr-sel.r-rowid NO-ERROR.
         IF AVAIL tt-tit-acr THEN DO:
             ASSIGN tt-tit-acr.marca  = NO
                    tt-tit-acr.mostra = YES.
    
             DELETE tt-tit-acr-sel.
         END.

        END.

        {&OPEN-QUERY-br-tit-acr}
        {&OPEN-QUERY-br-tit-acr-sel}

    END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-executar
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-executar W-Win
ON CHOOSE OF bt-executar IN FRAME F-Main /* Executar */
DO:
   do  on error undo, return no-apply:
       run pi-executar.
   end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-incluir
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-incluir W-Win
ON CHOOSE OF bt-incluir IN FRAME F-Main /* Button 5 */
DO:
    IF CAN-FIND(FIRST tt-tit-acr
                WHERE tt-tit-acr.marca  = YES
                  AND tt-tit-acr.mostra = YES) THEN DO:

        FOR EACH tt-tit-acr
           WHERE tt-tit-acr.marca  = YES
             AND tt-tit-acr.mostra = YES:
    
           CREATE tt-tit-acr-sel.
           BUFFER-COPY tt-tit-acr TO tt-tit-acr-sel.
           ASSIGN tt-tit-acr-sel.marca   = YES
                  tt-tit-acr-sel.r-rowid = ROWID(tt-tit-acr).
    
           ASSIGN tt-tit-acr.mostra = NO.
    
        END.

        {&OPEN-QUERY-br-tit-acr}
        {&OPEN-QUERY-br-tit-acr-sel}

    END.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-marca
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-marca W-Win
ON CHOOSE OF bt-marca IN FRAME F-Main /* Button 3 */
DO:
  FOR EACH tt-tit-acr:
      ASSIGN tt-tit-acr.marca = YES.
  END.
  br-tit-acr:REFRESH().
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-marca-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-marca-sel W-Win
ON CHOOSE OF bt-marca-sel IN FRAME F-Main /* Button 6 */
DO:
  FOR EACH tt-tit-acr-sel:
      ASSIGN tt-tit-acr-sel.marca = YES.
  END.
  br-tit-acr-sel:REFRESH().
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-zoom-cliente
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-zoom-cliente W-Win
ON CHOOSE OF bt-zoom-cliente IN FRAME F-Main /* Button 2 */
DO:
    run prgint/ufn/ufn011ka.p /*prg_sea_clien_financ*/.
    if  v_rec_clien_financ <> ?
    then do:
        find clien_financ where recid(clien_financ) = v_rec_clien_financ no-lock no-error.
        assign fi-cliente:screen-value in frame {&FRAME-NAME} = STRING(clien_financ.cdn_cliente).

        apply "ENTRY" to fi-cliente IN FRAME {&FRAME-NAME}.
        apply "LEAVE" to fi-cliente IN FRAME {&FRAME-NAME}.
    end /* if */.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME fi-cliente
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fi-cliente W-Win
ON LEAVE OF fi-cliente IN FRAME F-Main /* Cliente */
DO:
  FIND FIRST cliente NO-LOCK
       WHERE cliente.cdn_cliente = INPUT FRAME {&FRAME-NAME} fi-cliente NO-ERROR.
  IF AVAIL cliente THEN DO:
      IF NOT CAN-FIND(FIRST int-ds-convenio
                      WHERE int-ds-convenio.cnpj = cliente.cod_id_feder) THEN DO:
          RUN utp/ut-msgs.p (input "show":U, input 17006, input "Convànio n∆o Encontrado!~~ N∆o foi encontrado convànio para o Cliente Informado. Favor verificar.").
          RETURN "NOK".
      END.
      ELSE DO:

          IF NOT CAN-FIND(FIRST int-ds-convenio
                          WHERE int-ds-convenio.cnpj = cliente.cod_id_feder
                            AND int-ds-convenio.log-envia-cupom = YES      ) THEN DO:
              RUN utp/ut-msgs.p (input "show":U, input 17006, input "Convànio n∆o permitido Execuá∆o!~~ Esse cliente n∆o est† marcado para realizar a geraá∆o de convànio individual. Favor verificar.").
              RETURN "NOK".
          END.
          ELSE DO:
              FOR EACH int-ds-convenio
                 WHERE int-ds-convenio.cnpj = cliente.cod_id_feder
                   AND int-ds-convenio.log-envia-cupom = YES NO-LOCK:
        
                  MESSAGE int-ds-convenio.cod-convenio
                      VIEW-AS ALERT-BOX INFO BUTTONS OK.
        
              END.
          END.
      END.
      ASSIGN fi-nome-cliente:SCREEN-VALUE IN FRAME {&FRAME-NAME} = cliente.nom_abrev.
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tg-escolhe
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tg-escolhe W-Win
ON VALUE-CHANGED OF tg-escolhe IN FRAME F-Main /* Escolhe Cliente */
DO:
  IF INPUT FRAME {&FRAME-NAME} tg-escolhe = YES THEN DO:
      ENABLE fi-cliente
             bt-carrega-tit
             bt-filtro
             bt-marca
             bt-desmarca
             bt-incluir
             bt-marca-sel
             bt-desmarca-sel
             bt-excluir
             br-tit-acr
             br-tit-acr-sel
             bt-zoom-cliente
          WITH FRAME {&FRAME-NAME}.

      DISABLE fi-cliente-ini
              fi-cliente-fim WITH FRAME {&FRAME-NAME}.
  END.
  ELSE DO:
     DISABLE fi-cliente
             bt-carrega-tit
             bt-filtro
             bt-marca
             bt-desmarca
             bt-incluir
             bt-marca-sel
             bt-desmarca-sel
             bt-excluir
             br-tit-acr
             br-tit-acr-sel
             bt-zoom-cliente
          WITH FRAME {&FRAME-NAME}.  

     ENABLE fi-cliente-ini
            fi-cliente-fim WITH FRAME {&FRAME-NAME}.
  END.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-tit-acr
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK W-Win 


/* ***************************  Main Block  *************************** */

/* Include custom  Main Block code for SmartWindows. */
{src/adm/template/windowmn.i}

RUN pi-inicializar.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE adm-create-objects W-Win  _ADM-CREATE-OBJECTS
PROCEDURE adm-create-objects :
/*------------------------------------------------------------------------------
  Purpose:     Create handles for all SmartObjects used in this procedure.
               After SmartObjects are initialized, then SmartLinks are added.
  Parameters:  <none>
------------------------------------------------------------------------------*/

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE adm-row-available W-Win  _ADM-ROW-AVAILABLE
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI W-Win  _DEFAULT-DISABLE
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
  IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(W-Win)
  THEN DELETE WIDGET W-Win.
  IF THIS-PROCEDURE:PERSISTENT THEN DELETE PROCEDURE THIS-PROCEDURE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI W-Win  _DEFAULT-ENABLE
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
  DISPLAY fi-estab fi-dt-emis fi-cliente-ini fi-cliente-fim tg-escolhe 
          fi-cliente fi-nome-cliente cb-convenio 
      WITH FRAME F-Main IN WINDOW W-Win.
  ENABLE RECT-1 RECT-2 rt-button IMAGE-1 IMAGE-2 fi-estab fi-dt-emis 
         fi-cliente-ini fi-cliente-fim tg-escolhe bt-carrega-tit 
         bt-zoom-cliente fi-cliente cb-convenio br-tit-acr bt-filtro bt-marca 
         bt-desmarca bt-incluir br-tit-acr-sel bt-marca-sel bt-desmarca-sel 
         bt-excluir bt-executar bt-cancelar 
      WITH FRAME F-Main IN WINDOW W-Win.
  {&OPEN-BROWSERS-IN-QUERY-F-Main}
  VIEW W-Win.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-exit W-Win 
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-carrega-titulos W-Win 
PROCEDURE pi-carrega-titulos :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
FOR EACH tit_acr NO-LOCK USE-INDEX titacr_cliente
   WHERE tit_acr.cdn_cliente = INPUT FRAME {&FRAME-NAME} fi-cliente 
     AND tit_acr.dat_emis_docto >= 01/01/2016
     AND tit_acr.log_sdo_tit_acr = YES:

    CREATE tt-tit-acr.
    BUFFER-COPY tit_acr TO tt-tit-acr.
    ASSIGN tt-tit-acr.mostra = YES.

END.

{&OPEN-QUERY-BR-TIT-ACR}


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-cria-titulo-acr W-Win 
PROCEDURE pi-cria-titulo-acr :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
DEFINE BUFFER b_tit_acr FOR tit_acr.

DEFINE VARIABLE i-cod-titulo AS INTEGER     NO-UNDO.

DO TRANSACTION:

        RUN utp/ut-acomp.p PERSISTENT SET h-acomp.
  
        RUN pi-inicializar IN h-acomp ("Aguarde, Gerando T≠tulo...").

        EMPTY TEMP-TABLE tt_integr_acr_lote_impl        NO-ERROR.
        EMPTY TEMP-TABLE tt_integr_acr_item_lote_impl_4 NO-ERROR.
        EMPTY TEMP-TABLE tt_log_erros_atualiz           NO-ERROR.
        EMPTY TEMP-TABLE tt_integr_acr_aprop_ctbl_pend  NO-ERROR.
  
        ASSIGN c_cod_table = "lote_impl_tit_acr". 
        RUN pi-retorna-sugestao-referencia (INPUT  "ACR",
                                            INPUT  TODAY,
                                            OUTPUT c-cod-refer,
                                            INPUT  c_cod_table,
                                            INPUT  INPUT FRAME {&FRAME-NAME} fi-estab).

        FIND LAST b_tit_acr NO-LOCK
            WHERE b_tit_acr.cod_estab       = INPUT FRAME {&FRAME-NAME} fi-estab
              AND b_tit_acr.cod_espec_docto = "CF"
              AND b_tit_acr.cod_ser_docto   = "015" NO-ERROR.
        IF AVAIL b_tit_acr THEN
            ASSIGN i-cod-titulo = i-cod-titulo + (INT(b_tit_acr.cod_tit_acr) + 1).
        ELSE
            ASSIGN i-cod-titulo = 1.

        CREATE tt_integr_acr_item_lote_impl_4.
        ASSIGN tt_integr_acr_item_lote_impl_4.ttv_rec_lote_impl_tit_acr        = RECID(tt_integr_acr_lote_impl)
               tt_integr_acr_item_lote_impl_4.tta_num_seq_refer                = 10
               tt_integr_acr_item_lote_impl_4.tta_cdn_cliente                  = INPUT FRAME {&FRAME-NAME} fi-cliente
               tt_integr_acr_item_lote_impl_4.tta_cod_espec_docto              = "CF"
               tt_integr_acr_item_lote_impl_4.tta_cod_ser_docto                = "015"
               tt_integr_acr_item_lote_impl_4.tta_cod_tit_acr                  = STRING(i-cod-titulo)
               tt_integr_acr_item_lote_impl_4.tta_cod_parcela                  = "1"
               tt_integr_acr_item_lote_impl_4.tta_cod_indic_econ               = "Real"
               tt_integr_acr_item_lote_impl_4.tta_cod_portador                 = "99501"
               tt_integr_acr_item_lote_impl_4.tta_cod_cart_bcia                = "COB"
               tt_integr_acr_item_lote_impl_4.tta_cod_cond_cobr                = ""
               tt_integr_acr_item_lote_impl_4.tta_cdn_repres                   = 0
               tt_integr_acr_item_lote_impl_4.tta_dat_vencto_tit_acr           = TODAY
               tt_integr_acr_item_lote_impl_4.tta_dat_prev_liquidac            = TODAY
               tt_integr_acr_item_lote_impl_4.tta_dat_desconto                 = ?
               tt_integr_acr_item_lote_impl_4.tta_dat_emis_docto               = TODAY.
         ASSIGN      tt_integr_acr_item_lote_impl_4.tta_val_perc_desc                = 0
               tt_integr_acr_item_lote_impl_4.tta_val_perc_juros_dia_atraso    = 0
               tt_integr_acr_item_lote_impl_4.tta_val_perc_multa_atraso        = 0
               tt_integr_acr_item_lote_impl_4.tta_qtd_dias_carenc_multa_acr    = 0
               tt_integr_acr_item_lote_impl_4.tta_cod_banco                    = /*tit_acr.cod_banco*/ ""
               tt_integr_acr_item_lote_impl_4.tta_cod_agenc_bcia               = /*tit_acr.cod_agenc_bcia   */ ""
               tt_integr_acr_item_lote_impl_4.tta_cod_cta_corren_bco           = /*tit_acr.cod_cta_corren_bco*/ ""
               tt_integr_acr_item_lote_impl_4.tta_cod_digito_cta_corren        = /*tit_acr.cod_digito_cta_corren   */ "" 
               tt_integr_acr_item_lote_impl_4.tta_qtd_dias_carenc_juros_acr    = 0
               tt_integr_acr_item_lote_impl_4.tta_ind_tip_espec_docto          = "".

        FIND FIRST tt_integr_acr_lote_impl        NO-ERROR.
        FIND FIRST tt_integr_acr_item_lote_impl_4 NO-ERROR.
        FIND FIRST tt_integr_acr_aprop_ctbl_pend  NO-ERROR.
        FIND FIRST tt_integr_acr_repres_pend      NO-ERROR.
        RUN prgfin/acr/acr900zf.py (INPUT 6,
                                    INPUT "",
                                    INPUT YES,
                                    INPUT NO,
                                    INPUT-OUTPUT TABLE tt_integr_acr_item_lote_impl_4).    

        RUN pi-finalizar IN h-acomp.

        EMPTY TEMP-TABLE tt-log NO-ERROR.
        FIND FIRST tt_log_erros_atualiz NO-ERROR.
        IF AVAIL tt_log_erros_atualiz THEN DO:

            FIND FIRST tt_integr_acr_item_lote_impl_4 NO-ERROR.
            FOR EACH tt_log_erros_atualiz:

                 CREATE tt-log.
                 ASSIGN tt-log.cod_estab       = tit_acr.cod_estab
                        tt-log.cod_espec_docto = tt_integr_acr_item_lote_impl_4.tta_cod_espec_docto
                        tt-log.cod_ser_docto   = tt_integr_acr_item_lote_impl_4.tta_cod_ser_docto
                        tt-log.cod_tit_acr     = tt_integr_acr_item_lote_impl_4.tta_cod_tit_acr
                        tt-log.cod_parcela     = tt_integr_acr_item_lote_impl_4.tta_cod_parcela
                        tt-log.val_receber     = tit_acr.val_sdo_tit_acr
                        tt-log.num_erro_log    = tt_log_erros_atualiz.ttv_num_relacto
                        tt-log.des_msg_erro    = tt_log_erros_atualiz.ttv_des_msg_ajuda.

                 MESSAGE tt-log.num_erro_log " - " tt-log.des_msg_erro
                     VIEW-AS ALERT-BOX INFO BUTTONS OK.
            END.
        END.
        ELSE DO:
/*              RUN pi-acerto-valores (INPUT TABLE tt-gera-movto, */
/*                                    OUTPUT TABLE tt-log).       */
            FIND FIRST tt-log NO-ERROR.
             IF AVAIL tt-log THEN
                 UNDO, LEAVE.
             ELSE DO:
                 FIND FIRST tt_integr_acr_item_lote_impl_4 NO-ERROR.

                 MESSAGE "Titulo Criado com Sucesso" SKIP
/*                          tt_integr_acr_item_lote_impl_4.tta_cod_espec_docto SKIP */
/*                          tt_integr_acr_item_lote_impl_4.tta_cod_ser_docto   SKIP */
/*                          tt_integr_acr_item_lote_impl_4.tta_cod_tit_acr     SKIP */
/*                          tt_integr_acr_item_lote_impl_4.tta_cod_parcela          */
                     VIEW-AS ALERT-BOX INFO BUTTONS OK.
             END.
                 

        END.

END.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-executar W-Win 
PROCEDURE pi-executar :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

IF INPUT FRAME {&FRAME-NAME} tg-escolhe = YES THEN DO:
    RUN pi-gera-convenio-cliente.
END.
ELSE DO:
    RUN pi-gera-convenio-todos.
END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-gera-convenio-cliente W-Win 
PROCEDURE pi-gera-convenio-cliente :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
IF INPUT FRAME {&FRAME-NAME} fi-dt-emis = ? THEN DO:
            run utp/ut-msgs.p (input "show":U, 
                               input 17006, 
                               input "Data Emiss∆o Inv†lida!~~Favor informar uma data de Emiss∆o V†lida!").
            apply "ENTRY":U to fi-dt-emis in frame {&FRAME-NAME}.
            return error.
END.

RUN pi-cria-titulo-acr.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-inicializar W-Win 
PROCEDURE pi-inicializar :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
APPLY "VALUE-CHANGED" TO tg-escolhe IN FRAME {&FRAME-NAME}.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-retorna-sugestao-referencia W-Win 
PROCEDURE pi-retorna-sugestao-referencia :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    /************************ Parameter Definition Begin ************************/
    DEF INPUT  PARAM p_ind_tip_atualiz AS CHAR FORMAT "X(08)"      NO-UNDO.
    DEF INPUT  PARAM p_dat_refer       AS DATE FORMAT "99/99/9999" NO-UNDO.
    DEF OUTPUT PARAM p_cod_refer       AS CHAR FORMAT "x(10)"      NO-UNDO.
    DEF INPUT  PARAM p_cod_table       AS CHAR FORMAT "x(8)"       NO-UNDO.
    DEF INPUT  PARAM p_estabel         AS CHAR FORMAT "x(3)"       NO-UNDO.

    /************************* Parameter Definition End *************************/

    /************************* Variable Definition Begin ************************/

    DEF VAR v_des_dat   AS CHAR NO-UNDO. /*local*/
    DEF VAR v_num_aux   AS INT  NO-UNDO. /*local*/
    DEF VAR v_num_aux_2 AS INT  NO-UNDO. /*local*/
    DEF VAR v_num_cont  AS INT  NO-UNDO. /*local*/

    /************************** Variable Definition End *************************/

    ASSIGN v_des_dat   = STRING(p_dat_refer,"99999999")
           p_cod_refer = SUBSTRING(p_ind_tip_atualiz,1,2) + SUBSTRING(v_des_dat,7,2)
                       + SUBSTRING(v_des_dat,3,2) + SUBSTRING(v_des_dat,1,2)
           v_num_aux_2 = INT(this-PROCEDURE:HANDLE).

    DO v_num_cont = 1 TO 2:
        ASSIGN v_num_aux   = (RANDOM(0,v_num_aux_2) MOD 26) + 97
               p_cod_refer = p_cod_refer + CHR(v_num_aux).
    END.
    
    RUN pi-verifica-refer-unica-acr (INPUT p_estabel,
                                     INPUT p_cod_refer,
                                     INPUT p_cod_table,
                                     INPUT ?,
                                     OUTPUT v_log_refer_uni) /*pi-verifica-refer-unica-acr*/.

    IF v_log_refer_uni = NO THEN
            RUN pi-retorna-sugestao-referencia (INPUT  "BP",
                                                INPUT  TODAY,
                                                OUTPUT p_cod_refer,
                                                INPUT  p_cod_table,
                                                INPUT  p_estabel).
    
END PROCEDURE. /* pi_retorna_sugestao_referencia */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-verifica-refer-unica-acr W-Win 
PROCEDURE pi-verifica-refer-unica-acr :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/


    /************************ Parameter Definition Begin ************************/

    DEF INPUT  PARAM p_cod_estab     AS CHAR FORMAT "x(3)"    NO-UNDO.
    DEF INPUT  PARAM p_cod_refer     AS CHAR FORMAT "x(10)"   NO-UNDO.
    DEF INPUT  PARAM p_cod_table     AS CHAR FORMAT "x(8)"    NO-UNDO.
    DEF INPUT  PARAM p_rec_tabela    AS RECID     FORMAT ">>>>>>9" NO-UNDO.
    DEF OUTPUT PARAM p_log_refer_uni AS LOGICAL   FORMAT "Sim/Nao" NO-UNDO.

    /************************* Parameter Definition End *************************/

    /************************** Buffer Definition Begin *************************/

    DEF BUFFER b_cobr_especial_acr FOR cobr_especial_acr.
    DEF BUFFER b_lote_impl_tit_acr FOR lote_impl_tit_acr.
    DEF BUFFER b_lote_liquidac_acr FOR lote_liquidac_acr.
    DEF BUFFER b_movto_tit_acr     FOR movto_tit_acr.
    DEF BUFFER b_renegoc_acr       FOR renegoc_acr.

    /*************************** Buffer Definition End **************************/

    /************************* Variable Definition Begin ************************/

    DEF VAR v_cod_return AS CHAR FORMAT "x(40)" NO-UNDO.

    /************************** Variable Definition End *************************/

    ASSIGN p_log_refer_uni = YES.

    IF p_cod_table <> "lote_impl_tit_acr" /*l_lote_impl_tit_acr*/  THEN DO:
        FIND FIRST b_lote_impl_tit_acr NO-LOCK USE-INDEX ltmplttc_id
             WHERE b_lote_impl_tit_acr.cod_estab = p_cod_estab
               AND b_lote_impl_tit_acr.cod_refer = p_cod_refer
               AND RECID( b_lote_impl_tit_acr ) <> p_rec_tabela NO-ERROR.
        IF AVAIL b_lote_impl_tit_acr THEN
            ASSIGN p_log_refer_uni = NO.
    END.

    IF p_cod_table <> "lote_liquidac_acr" /*l_lote_liquidac_acr*/  THEN DO:
        FIND FIRST b_lote_liquidac_acr NO-LOCK USE-INDEX ltlqdccr_id
             where b_lote_liquidac_acr.cod_estab_refer = p_cod_estab
               and b_lote_liquidac_acr.cod_refer       = p_cod_refer
               and recid( b_lote_liquidac_acr )       <> p_rec_tabela NO-ERROR.
        IF AVAIL b_lote_liquidac_acr THEN
            ASSIGN p_log_refer_uni = NO.
    END.

    IF p_cod_table = 'cobr_especial_acr' THEN DO:
        FIND FIRST b_cobr_especial_acr NO-LOCK USE-INDEX cbrspclc_id
             WHERE b_cobr_especial_acr.cod_estab = p_cod_estab
               AND b_cobr_especial_acr.cod_refer = p_cod_refer
               AND RECID( b_cobr_especial_acr ) <> p_rec_tabela NO-ERROR.
        IF AVAIL b_cobr_especial_acr THEN
            ASSIGN p_log_refer_uni = NO.
    END.

    IF p_log_refer_uni = YES THEN DO:
        FIND FIRST b_renegoc_acr NO-LOCK
             WHERE b_renegoc_acr.cod_estab = p_cod_estab
               AND b_renegoc_acr.cod_refer = p_cod_refer
               AND RECID(b_renegoc_acr)   <> p_rec_tabela NO-ERROR.
        IF AVAIL b_renegoc_acr THEN
            ASSIGN p_log_refer_uni = NO.
        ELSE DO:
            FIND FIRST b_movto_tit_acr NO-LOCK USE-INDEX mvtttcr_refer
                 WHERE b_movto_tit_acr.cod_estab = p_cod_estab
                   AND b_movto_tit_acr.cod_refer = p_cod_refer
                   AND RECID(b_movto_tit_acr)   <> p_rec_tabela NO-ERROR.
            IF AVAIL b_movto_tit_acr THEN
                ASSIGN p_log_refer_uni = NO.
        END.
    END.

END PROCEDURE. /* pi_verifica_refer_unica_acr */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE send-records W-Win  _ADM-SEND-RECORDS
PROCEDURE send-records :
/*------------------------------------------------------------------------------
  Purpose:     Send record ROWID's for all tables used by
               this file.
  Parameters:  see template/snd-head.i
------------------------------------------------------------------------------*/

  /* Define variables needed by this internal procedure.               */
  {src/adm/template/snd-head.i}

  /* For each requested table, put it's ROWID in the output list.      */
  {src/adm/template/snd-list.i "tt-tit-acr-sel"}
  {src/adm/template/snd-list.i "tt-tit-acr"}

  /* Deal with any unexpected table requests before closing.           */
  {src/adm/template/snd-end.i}

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE state-changed W-Win 
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

