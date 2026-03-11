&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI ADM1
&ANALYZE-RESUME
/* Connected Databases 
          emsesp           PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS V-table-Win 
/*------------------------------------------------------------------------

  File:

  Description: from VIEWER.W - Template for SmartViewer Objects

  Input Parameters:
      <none>

  Output Parameters:
      <none>

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

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */

def var r-registro-atual as rowid no-undo.

def var wh-pesquisa as widget-handle no-undo.
def var l-implanta as logical no-undo.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE SmartViewer
&Scoped-define DB-AWARE no

&Scoped-define ADM-SUPPORTED-LINKS Record-Source,Record-Target,TableIO-Target

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME F-Main

/* External Tables                                                      */
&Scoped-define EXTERNAL-TABLES int-ds-tp-natur-oper
&Scoped-define FIRST-EXTERNAL-TABLE int-ds-tp-natur-oper


/* Need to scope the external tables to this procedure                  */
DEFINE QUERY external_tables FOR int-ds-tp-natur-oper.
/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS int-ds-tp-natur-oper.tp-pedido ~
int-ds-tp-natur-oper.cod-estabel int-ds-tp-natur-oper.uf-origem ~
int-ds-tp-natur-oper.cst-icms int-ds-tp-natur-oper.uf-destino ~
int-ds-tp-natur-oper.cod-emitente int-ds-tp-natur-oper.class-fiscal ~
int-ds-tp-natur-oper.nat-operacao int-ds-tp-natur-oper.nat-oper-entrada ~
int-ds-tp-natur-oper.serie int-ds-tp-natur-oper.cod-cond-pag ~
int-ds-tp-natur-oper.cod-portador 
&Scoped-define ENABLED-TABLES int-ds-tp-natur-oper
&Scoped-define FIRST-ENABLED-TABLE int-ds-tp-natur-oper
&Scoped-Define ENABLED-OBJECTS RECT-19 RECT-20 RECT-21 RECT-22 RECT-23 ~
cb-modalidade 
&Scoped-Define DISPLAYED-FIELDS int-ds-tp-natur-oper.tp-pedido ~
int-ds-tp-natur-oper.cod-estabel int-ds-tp-natur-oper.uf-origem ~
int-ds-tp-natur-oper.cst-icms int-ds-tp-natur-oper.uf-destino ~
int-ds-tp-natur-oper.cod-emitente int-ds-tp-natur-oper.class-fiscal ~
int-ds-tp-natur-oper.nat-operacao int-ds-tp-natur-oper.nat-oper-entrada ~
int-ds-tp-natur-oper.serie int-ds-tp-natur-oper.cod-cond-pag ~
int-ds-tp-natur-oper.cod-portador 
&Scoped-define DISPLAYED-TABLES int-ds-tp-natur-oper
&Scoped-define FIRST-DISPLAYED-TABLE int-ds-tp-natur-oper
&Scoped-Define DISPLAYED-OBJECTS cEstabelec cEmitente cClassFisc cNatureza ~
cNatEntrada cCondicao cb-modalidade cPortador 

/* Custom List Definitions                                              */
/* ADM-CREATE-FIELDS,ADM-ASSIGN-FIELDS,List-3,List-4,List-5,List-6      */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _XFTR "Foreign Keys" V-table-Win _INLINE
/* Actions: ? adm/support/keyedit.w ? ? ? */
/* STRUCTURED-DATA
<KEY-OBJECT>
THIS-PROCEDURE
</KEY-OBJECT>
<FOREIGN-KEYS>
</FOREIGN-KEYS> 
<EXECUTING-CODE>
**************************
* Set attributes related to FOREIGN KEYS
*/
RUN set-attribute-list (
    'Keys-Accepted = "",
     Keys-Supplied = ""':U).
/**************************
</EXECUTING-CODE> */   

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */
DEFINE VARIABLE cb-modalidade AS CHARACTER FORMAT "X(40)":U 
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEMS "Cb Simples" 
     DROP-DOWN-LIST
     SIZE 16 BY 1 NO-UNDO.

DEFINE VARIABLE cClassFisc AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 57 BY .88 NO-UNDO.

DEFINE VARIABLE cCondicao AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 67.57 BY .88 NO-UNDO.

DEFINE VARIABLE cEmitente AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 64 BY .88 NO-UNDO.

DEFINE VARIABLE cEstabelec AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 65 BY .88 NO-UNDO.

DEFINE VARIABLE cNatEntrada AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 61 BY .88 NO-UNDO.

DEFINE VARIABLE cNatureza AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 61 BY .88 NO-UNDO.

DEFINE VARIABLE cPortador AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 48 BY .88 NO-UNDO.

DEFINE RECTANGLE RECT-19
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 91 BY 4.

DEFINE RECTANGLE RECT-20
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 91 BY 3.21.

DEFINE RECTANGLE RECT-21
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 91 BY 2.25.

DEFINE RECTANGLE RECT-22
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 91 BY 2.75.

DEFINE RECTANGLE RECT-23
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 91 BY 2.46.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME F-Main
     int-ds-tp-natur-oper.tp-pedido AT ROW 1.5 COL 17 COLON-ALIGNED WIDGET-ID 110
          VIEW-AS COMBO-BOX INNER-LINES 10
          LIST-ITEM-PAIRS "TRANSFERENCIA DEPOSITO - FILIAL","1",
                     "TRANSFERENCIA FILIAL - DEPOSITO","2",
                     "BALANCO MANUAL FILIAL","3",
                     "COMPRA FORNECEDOR - FILIAL","4",
                     "COMPRA FORNECEDOR - DEPOSITO","5",
                     "TRANSFERENCIA DEPOSITO - DEPOSITO","6",
                     "ELETRONICO FORNECEDOR - FILIAL","7",
                     "ELETRONICO DEPOSITO - FILIAL","8",
                     "PBM FILIAL","9",
                     "PBM DEPOSITO","10",
                     "BALANCO MANUAL DEPOSITO","11",
                     "BALANCO COLETOR FILIAL","12",
                     "BALANCO COLETOR DEPOSITO","13",
                     "BALANCO MANUAL FILIAL - PERMITE CONSOLIDAÄ«O","14",
                     "DEVOLUCAO FILIAL - FORNECEDOR","15",
                     "DEVOLUCAO DEPOSITO - FORNECEDOR","16",
                     "TRANSFERENCIA DEPOSITO - DEPOSITO (COMERCIALIZAVEL)","17",
                     "TRANSFERENCIA DEPOSITO - DEPOSITO (AVARIA)","18",
                     "TRANSFERENCIA FILIAL - FILIAL","19",
                     "BALANCO MANUAL FILIAL - ESPECIAL (MED. CONTROLADO)","31",
                     "DEVOLUCAO FILIAL - FORNECEDOR (MED. CONTROLADO)","32",
                     "TRANSFERENCIA FILIAL - FORNECEDOR (MED. CONTROLADO)","33",
                     "BALANÄO GERAL CONTROLADOS DEPOSITO","35",
                     "BALANÄO GERAL CONTROLADOS FILIAL","36",
                     "ATIVO IMOBILIZADO DEPOSITO => FILIAL","37",
                     "ESTORNO","38",
                     "ATIVO IMOBILIZADO FILIAL => FILIAL","39",
                     "RETIRADA FILIAL => PROPRIA FILIAL","46",
                     "SUBSTITUIÄ«O DE CUPOM","48",
                     "ESTORNO","51",
                     "ESTORNO","52",
                     "ESTORNO","53"
          DROP-DOWN-LIST
          SIZE 72 BY 1
     int-ds-tp-natur-oper.cod-estabel AT ROW 2.75 COL 17 COLON-ALIGNED
          VIEW-AS FILL-IN 
          SIZE 7.14 BY .88
     cEstabelec AT ROW 2.75 COL 24 COLON-ALIGNED NO-LABEL
     int-ds-tp-natur-oper.uf-origem AT ROW 3.92 COL 17 COLON-ALIGNED WIDGET-ID 112
          VIEW-AS FILL-IN 
          SIZE 5 BY .88
     int-ds-tp-natur-oper.cst-icms AT ROW 3.92 COL 84.57 COLON-ALIGNED WIDGET-ID 132
          VIEW-AS FILL-IN 
          SIZE 4.29 BY .88
     int-ds-tp-natur-oper.uf-destino AT ROW 6.25 COL 17 COLON-ALIGNED WIDGET-ID 4
          VIEW-AS FILL-IN 
          SIZE 5.14 BY .88
     int-ds-tp-natur-oper.cod-emitente AT ROW 7.25 COL 17 COLON-ALIGNED
          LABEL "Emitente Destino"
          VIEW-AS FILL-IN 
          SIZE 8 BY .88
     cEmitente AT ROW 7.25 COL 25 COLON-ALIGNED NO-LABEL
     int-ds-tp-natur-oper.class-fiscal AT ROW 9.83 COL 17 COLON-ALIGNED WIDGET-ID 6 FORMAT "X(8)"
          VIEW-AS FILL-IN 
          SIZE 15 BY .88
     cClassFisc AT ROW 9.83 COL 32 COLON-ALIGNED NO-LABEL WIDGET-ID 8
     int-ds-tp-natur-oper.nat-operacao AT ROW 12.13 COL 17.72 COLON-ALIGNED
          LABEL "Natureza Sa°da"
          VIEW-AS FILL-IN 
          SIZE 10.14 BY .88
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE NO-VALIDATE THREE-D 
         AT COL 1 ROW 1 SCROLLABLE .

/* DEFINE FRAME statement is approaching 4K Bytes.  Breaking it up   */
DEFINE FRAME F-Main
     cNatureza AT ROW 12.13 COL 28 COLON-ALIGNED NO-LABEL
     int-ds-tp-natur-oper.nat-oper-entrada AT ROW 13.04 COL 17.72 COLON-ALIGNED WIDGET-ID 140
          VIEW-AS FILL-IN 
          SIZE 10.29 BY .88
     cNatEntrada AT ROW 13.04 COL 28 COLON-ALIGNED NO-LABEL WIDGET-ID 138
     int-ds-tp-natur-oper.serie AT ROW 13.96 COL 17.86 COLON-ALIGNED WIDGET-ID 126
          VIEW-AS FILL-IN 
          SIZE 9.14 BY .88
     int-ds-tp-natur-oper.cod-cond-pag AT ROW 15.83 COL 17 COLON-ALIGNED WIDGET-ID 114
          VIEW-AS FILL-IN 
          SIZE 4.57 BY .88
     cCondicao AT ROW 15.83 COL 21.43 COLON-ALIGNED NO-LABEL WIDGET-ID 116
     int-ds-tp-natur-oper.cod-portador AT ROW 16.83 COL 17 COLON-ALIGNED WIDGET-ID 122
          VIEW-AS FILL-IN 
          SIZE 8 BY .88
     cb-modalidade AT ROW 16.83 COL 25 COLON-ALIGNED NO-LABEL WIDGET-ID 128
     cPortador AT ROW 16.83 COL 41 COLON-ALIGNED NO-LABEL WIDGET-ID 130
     "Origem" VIEW-AS TEXT
          SIZE 7 BY .67 AT ROW 1 COL 4 WIDGET-ID 40
     "Financeiro" VIEW-AS TEXT
          SIZE 13 BY .67 AT ROW 15.29 COL 3 WIDGET-ID 136
     "Fiscal" VIEW-AS TEXT
          SIZE 7 BY .67 AT ROW 11.5 COL 3 WIDGET-ID 34
     "Destino" VIEW-AS TEXT
          SIZE 7 BY .67 AT ROW 5.54 COL 4 WIDGET-ID 120
     "Produto" VIEW-AS TEXT
          SIZE 8 BY .67 AT ROW 8.83 COL 3 WIDGET-ID 38
     RECT-19 AT ROW 1.25 COL 2 WIDGET-ID 12
     RECT-20 AT ROW 11.79 COL 2 WIDGET-ID 24
     RECT-21 AT ROW 9.04 COL 2 WIDGET-ID 36
     RECT-22 AT ROW 5.75 COL 2 WIDGET-ID 118
     RECT-23 AT ROW 15.58 COL 2 WIDGET-ID 134
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE NO-VALIDATE THREE-D 
         AT COL 1 ROW 1 SCROLLABLE .


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: SmartViewer
   External Tables: mgesp.int-ds-tp-natur-oper
   Allow: Basic,DB-Fields
   Frames: 1
   Add Fields to: EXTERNAL-TABLES
   Other Settings: PERSISTENT-ONLY COMPILE
 */

/* This procedure should always be RUN PERSISTENT.  Report the error,  */
/* then cleanup and return.                                            */
IF NOT THIS-PROCEDURE:PERSISTENT THEN DO:
  MESSAGE "{&FILE-NAME} should only be RUN PERSISTENT.":U
          VIEW-AS ALERT-BOX ERROR BUTTONS OK.
  RETURN.
END.

&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
/* DESIGN Window definition (used by the UIB) 
  CREATE WINDOW V-table-Win ASSIGN
         HEIGHT             = 17.42
         WIDTH              = 93.
/* END WINDOW DEFINITION */
                                                                        */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _INCLUDED-LIB V-table-Win 
/* ************************* Included-Libraries *********************** */

{src/adm/method/viewer.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME




/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW V-table-Win
  VISIBLE,,RUN-PERSISTENT                                               */
/* SETTINGS FOR FRAME F-Main
   NOT-VISIBLE FRAME-NAME Size-to-Fit                                   */
ASSIGN 
       FRAME F-Main:SCROLLABLE       = FALSE
       FRAME F-Main:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN cClassFisc IN FRAME F-Main
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN cCondicao IN FRAME F-Main
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN cEmitente IN FRAME F-Main
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN cEstabelec IN FRAME F-Main
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN int-ds-tp-natur-oper.class-fiscal IN FRAME F-Main
   EXP-FORMAT                                                           */
/* SETTINGS FOR FILL-IN cNatEntrada IN FRAME F-Main
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN cNatureza IN FRAME F-Main
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN int-ds-tp-natur-oper.cod-emitente IN FRAME F-Main
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN cPortador IN FRAME F-Main
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN int-ds-tp-natur-oper.nat-operacao IN FRAME F-Main
   EXP-LABEL                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK FRAME F-Main
/* Query rebuild information for FRAME F-Main
     _Options          = "NO-LOCK"
     _Query            is NOT OPENED
*/  /* FRAME F-Main */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME cb-modalidade
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL cb-modalidade V-table-Win
ON VALUE-CHANGED OF cb-modalidade IN FRAME F-Main
DO:
    cPortador:screen-value = "".
    for first mgadm.portador 
        fields (cod-portador nome modalidade)
        no-lock where
        mgadm.portador.cod-portador = input frame {&FRAME-NAME} int-ds-tp-natur-oper.cod-portador and
        mgadm.portador.modalidade = {adinc/i03ad209.i 06 cb-modalidade:screen-value}:
    end.
    if avail portador then
    do:
        cb-modalidade:screen-value = {adinc/i03ad209.i 04 mgadm.portador.modalidade}.
        cPortador    :screen-value = portador.nome.
    end.         
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME int-ds-tp-natur-oper.class-fiscal
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL int-ds-tp-natur-oper.class-fiscal V-table-Win
ON F5 OF int-ds-tp-natur-oper.class-fiscal IN FRAME F-Main /* Classif.Fiscal */
OR MOUSE-SELECT-DBLCLICK OF int-ds-tp-natur-oper.class-fiscal in frame {&FRAME-NAME} DO:
        {include/zoomvar.i &prog-zoom=inzoom/z01in046.w
                                &campo=int-ds-tp-natur-oper.class-fiscal
                                &campozoom=class-fiscal}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL int-ds-tp-natur-oper.class-fiscal V-table-Win
ON LEAVE OF int-ds-tp-natur-oper.class-fiscal IN FRAME F-Main /* Classif.Fiscal */
DO:
    cClassFisc:screen-value in frame {&frame-name} = "".
    for first classif-fisc 
        fields (class-fiscal descricao)
        no-lock where
        classif-fisc.class-fiscal = input frame {&FRAME-NAME} int-ds-tp-natur-oper.class-fiscal.
    end.
    if avail classif-fisc then
    do:
        display classif-fisc.descricao @ cClassFisc with frame {&FRAME-NAME}.
    end.    
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME int-ds-tp-natur-oper.cod-cond-pag
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL int-ds-tp-natur-oper.cod-cond-pag V-table-Win
ON F5 OF int-ds-tp-natur-oper.cod-cond-pag IN FRAME F-Main /* Cond Pagto */
OR MOUSE-SELECT-DBLCLICK OF int-ds-tp-natur-oper.cod-cond-pag in frame {&FRAME-NAME} DO:
        {include/zoomvar.i &prog-zoom=adzoom/z01ad039.w
                                &campo=int-ds-tp-natur-oper.cod-cond-pag
                                &campozoom=cod-cond-pag}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL int-ds-tp-natur-oper.cod-cond-pag V-table-Win
ON LEAVE OF int-ds-tp-natur-oper.cod-cond-pag IN FRAME F-Main /* Cond Pagto */
DO:
    cCondicao:screen-value in frame {&frame-name} = "".
    for first mgadm.cond-pagto 
        fields (cod-cond-pag descricao)
        no-lock where
        mgadm.cond-pagto.cod-cond-pag = input frame {&FRAME-NAME} int-ds-tp-natur-oper.cod-cond-pag.
    end.
    if avail cond-pagto then
    do:
        display cond-pagto.descricao @ cCondicao with frame {&FRAME-NAME}.
    end.  
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME int-ds-tp-natur-oper.cod-emitente
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL int-ds-tp-natur-oper.cod-emitente V-table-Win
ON F5 OF int-ds-tp-natur-oper.cod-emitente IN FRAME F-Main /* Emitente Destino */
OR MOUSE-SELECT-DBLCLICK OF int-ds-tp-natur-oper.cod-emitente in frame {&FRAME-NAME} DO:
        {include/zoomvar.i &prog-zoom=adzoom/z01ad098.w
                                &campo=int-ds-tp-natur-oper.cod-emitente
                                &campozoom=cod-emitente}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL int-ds-tp-natur-oper.cod-emitente V-table-Win
ON LEAVE OF int-ds-tp-natur-oper.cod-emitente IN FRAME F-Main /* Emitente Destino */
DO:
    cEmitente:screen-value in frame {&frame-name} = "".
    for first mgadm.emitente 
        fields (cod-emitente nome-emit)
        no-lock where
        mgadm.emitente.cod-emitente = input frame {&FRAME-NAME} int-ds-tp-natur-oper.cod-emitente.
    end.
    if avail emitente then
    do:
        display emitente.nome-emit @ cEmitente with frame {&FRAME-NAME}.
    end.  
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME int-ds-tp-natur-oper.cod-estabel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL int-ds-tp-natur-oper.cod-estabel V-table-Win
ON F5 OF int-ds-tp-natur-oper.cod-estabel IN FRAME F-Main /* Estabelecimento */
OR MOUSE-SELECT-DBLCLICK OF int-ds-tp-natur-oper.cod-estabel in frame {&FRAME-NAME} DO:
        {include/zoomvar.i &prog-zoom=adzoom/z01ad107.w
                                &campo=int-ds-tp-natur-oper.cod-estabel
                                &campozoom=cod-estabel}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL int-ds-tp-natur-oper.cod-estabel V-table-Win
ON LEAVE OF int-ds-tp-natur-oper.cod-estabel IN FRAME F-Main /* Estabelecimento */
DO:
    cEstabelec:screen-value in frame {&frame-name} = "".    
    for first mgadm.estabelec 
        fields (cod-estabel nome)
        no-lock where
        mgadm.estabelec.cod-estabel = input frame {&FRAME-NAME} int-ds-tp-natur-oper.cod-estabel.
    end.
    if avail estabelec then
    do:
        display estabelec.nome @ cEstabelec with frame {&FRAME-NAME}.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME int-ds-tp-natur-oper.cod-portador
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL int-ds-tp-natur-oper.cod-portador V-table-Win
ON F5 OF int-ds-tp-natur-oper.cod-portador IN FRAME F-Main /* Portador */
OR MOUSE-SELECT-DBLCLICK OF int-ds-tp-natur-oper.cod-portador in frame {&FRAME-NAME} DO:
        {include/zoomvar.i &prog-zoom=adzoom/z01ad209.w
                                &campo=int-ds-tp-natur-oper.cod-portador
                                &campozoom=cod-portador}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL int-ds-tp-natur-oper.cod-portador V-table-Win
ON LEAVE OF int-ds-tp-natur-oper.cod-portador IN FRAME F-Main /* Portador */
DO:
    cb-modalidade:screen-value = {adinc/i03ad209.i 04 1}.
    cPortador    :screen-value = "".

    for first mgadm.portador 
        fields (cod-portador nome modalidade)
        no-lock where
        mgadm.portador.cod-portador = input frame {&FRAME-NAME} int-ds-tp-natur-oper.cod-portador /*and
        mgadm.portador.modalidade = {adinc/i03ad209.i 06 cb-modalidade:screen-value}*/:
    end.
    if avail portador then
    do:
        cb-modalidade:screen-value = {adinc/i03ad209.i 04 mgadm.portador.modalidade}.
        cPortador    :screen-value = portador.nome.
    end.         
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME int-ds-tp-natur-oper.nat-oper-entrada
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL int-ds-tp-natur-oper.nat-oper-entrada V-table-Win
ON F5 OF int-ds-tp-natur-oper.nat-oper-entrada IN FRAME F-Main /* nat-oper-entrada */
OR MOUSE-SELECT-DBLCLICK OF int-ds-tp-natur-oper.nat-operacao in frame {&FRAME-NAME} DO:
        {include/zoomvar.i &prog-zoom=inzoom/z01in245.w
                                &campo=int-ds-tp-natur-oper.nat-oper-entrada
                                &campozoom=nat-operacao}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL int-ds-tp-natur-oper.nat-oper-entrada V-table-Win
ON LEAVE OF int-ds-tp-natur-oper.nat-oper-entrada IN FRAME F-Main /* nat-oper-entrada */
DO:
   cNatentrada:screen-value in frame {&frame-name} = "".
    for first mgind.natur-oper 
        fields (nat-operacao denominacao)
        no-lock where
        mgind.natur-oper.nat-operacao = input frame {&FRAME-NAME} int-ds-tp-natur-oper.nat-oper-entrada.
    end.
    if avail natur-oper then
    do:
        display natur-oper.denominacao @ cNatentrada with frame {&FRAME-NAME}.
    end.  
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME int-ds-tp-natur-oper.nat-operacao
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL int-ds-tp-natur-oper.nat-operacao V-table-Win
ON F5 OF int-ds-tp-natur-oper.nat-operacao IN FRAME F-Main /* Natureza Sa°da */
OR MOUSE-SELECT-DBLCLICK OF int-ds-tp-natur-oper.nat-operacao in frame {&FRAME-NAME} DO:
        {include/zoomvar.i &prog-zoom=inzoom/z01in245.w
                                &campo=int-ds-tp-natur-oper.nat-operacao
                                &campozoom=nat-operacao}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL int-ds-tp-natur-oper.nat-operacao V-table-Win
ON LEAVE OF int-ds-tp-natur-oper.nat-operacao IN FRAME F-Main /* Natureza Sa°da */
DO:
    cNatureza:screen-value in frame {&frame-name} = "".
    for first mgind.natur-oper 
        fields (nat-operacao denominacao)
        no-lock where
        mgind.natur-oper.nat-operacao = input frame {&FRAME-NAME} int-ds-tp-natur-oper.nat-operacao.
    end.
    if avail natur-oper then
    do:
        display natur-oper.denominacao @ cNatureza with frame {&FRAME-NAME}.
    end.  
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME int-ds-tp-natur-oper.serie
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL int-ds-tp-natur-oper.serie V-table-Win
ON F5 OF int-ds-tp-natur-oper.serie IN FRAME F-Main /* Serie */
OR MOUSE-SELECT-DBLCLICK OF int-ds-tp-natur-oper.serie in frame {&FRAME-NAME} DO:
        {include/zoomvar.i &prog-zoom=inzoom/z01in407.w
                                &campo=int-ds-tp-natur-oper.serie
                                &campozoom=serie}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME int-ds-tp-natur-oper.tp-pedido
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL int-ds-tp-natur-oper.tp-pedido V-table-Win
ON VALUE-CHANGED OF int-ds-tp-natur-oper.tp-pedido IN FRAME F-Main /* Tipo Pedido */
DO:
    if emsesp.int-ds-tp-natur-oper.tp-pedido:screen-value in frame f-main = "15" or  
       emsesp.int-ds-tp-natur-oper.tp-pedido:screen-value in frame f-main = "32" then 
        assign emsesp.int-ds-tp-natur-oper.cst-icms:sensitive in frame f-main = yes.
    else 
        assign emsesp.int-ds-tp-natur-oper.cst-icms:sensitive in frame f-main = no.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK V-table-Win 


/* ***************************  Main Block  *************************** */

  &IF DEFINED(UIB_IS_RUNNING) <> 0 &THEN          
    RUN dispatch IN THIS-PROCEDURE ('initialize':U).        
  &ENDIF         
  
  /************************ INTERNAL PROCEDURES ********************/

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE adm-row-available V-table-Win  _ADM-ROW-AVAILABLE
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

  /* Create a list of all the tables that we need to get.            */
  {src/adm/template/row-list.i "int-ds-tp-natur-oper"}

  /* Get the record ROWID's from the RECORD-SOURCE.                  */
  {src/adm/template/row-get.i}

  /* FIND each record specified by the RECORD-SOURCE.                */
  {src/adm/template/row-find.i "int-ds-tp-natur-oper"}

  /* Process the newly available records (i.e. display fields,
     open queries, and/or pass records on to any RECORD-TARGETS).    */
  {src/adm/template/row-end.i}

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI V-table-Win  _DEFAULT-DISABLE
PROCEDURE disable_UI :
/*------------------------------------------------------------------------------
  Purpose:     DISABLE the User Interface
  Parameters:  <none>
  Notes:       Here we clean-up the user-interface by deleting
               dynamic widgets we have created and/or hide 
               frames.  This procedure is usually called when
               we are ready to "clean-up" after running.
------------------------------------------------------------------------------*/
  /* Hide all frames. */
  HIDE FRAME F-Main.
  IF THIS-PROCEDURE:PERSISTENT THEN DELETE PROCEDURE THIS-PROCEDURE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-assign-record V-table-Win 
PROCEDURE local-assign-record :
/*------------------------------------------------------------------------------
  Purpose:     Override standard ADM method
  Notes:       
------------------------------------------------------------------------------*/
 
  /* Code placed here will execute PRIOR to standard behavior. */
  if input frame {&FRAME-NAME} int-ds-tp-natur-oper.cod-estabel <> ? then do:
      if input frame {&FRAME-NAME} int-ds-tp-natur-oper.cod-estabel = "" or
         not can-find(first estabelec no-lock where 
                      estabelec.cod-estabel = input frame {&FRAME-NAME} int-ds-tp-natur-oper.cod-estabel)
      then do:
          run utp/ut-msgs.p(input "show",
                            input 17006,
                            input ("Estabelecimento inv†lido!" + "~~" + "Estabelicimento n∆o encontrado no cadastro.")).
          return "ADM-ERROR".
      end.
  end.
  if input frame {&FRAME-NAME} int-ds-tp-natur-oper.uf-origem <> ? then do:
      if input frame {&FRAME-NAME} int-ds-tp-natur-oper.uf-origem = "" or
         not can-find(first unid-feder no-lock where unid-feder.estado = input frame {&FRAME-NAME} int-ds-tp-natur-oper.uf-origem)
      then do:
          run utp/ut-msgs.p(input "show",
                            input 17006,
                            input ("Estado Origem inv†lido!" + "~~" + "Estado origem deve estar cadastrado em unidades da federaá∆o ou ser ?.")).
          return "ADM-ERROR".
      end.
  end.

  if input frame {&FRAME-NAME} int-ds-tp-natur-oper.uf-destino <> ? then do:
      if input frame {&FRAME-NAME} int-ds-tp-natur-oper.uf-destino = "" or
         not can-find(first unid-feder no-lock where unid-feder.estado = input frame {&FRAME-NAME} int-ds-tp-natur-oper.uf-destino)
      then do:
          run utp/ut-msgs.p(input "show",
                            input 17006,
                            input ("Estado Destino inv†lido!" + "~~" + "Estado destino deve estar cadastrado em unidades da federaá∆o ou ser ?.")).
          return "ADM-ERROR".
      end.
  end.

  if input frame {&FRAME-NAME} int-ds-tp-natur-oper.cod-emitente <> ? then do:
      if input frame {&FRAME-NAME} int-ds-tp-natur-oper.cod-emitente = "" or
         not can-find(first emitente no-lock where emitente.cod-emitente = input frame {&FRAME-NAME} int-ds-tp-natur-oper.cod-emitente)
      then do:
          run utp/ut-msgs.p(input "show",
                            input 17006,
                            input ("Emitente inv†lido!" + "~~" + "Emitente deve estar cadastrado ou ser ?.")).
          return "ADM-ERROR".
      end.
  end.

  if input frame {&FRAME-NAME} int-ds-tp-natur-oper.class-fiscal <> ? then do:
      if input frame {&FRAME-NAME} int-ds-tp-natur-oper.class-fiscal = "" or
         not can-find(first classif-fisc no-lock where classif-fisc.class-fiscal = input frame {&FRAME-NAME} int-ds-tp-natur-oper.class-fiscal)
      then do:
          run utp/ut-msgs.p(input "show",
                            input 17006,
                            input ("Classificaá∆o Fiscal inv†lida!" + "~~" + "Classificaá∆o Fiscal deve estar cadastrada ou ser ?.")).
          return "ADM-ERROR".
      end.
  end.

  if input frame {&FRAME-NAME} int-ds-tp-natur-oper.nat-operacao = "" or
     not can-find(first natur-oper no-lock where natur-oper.nat-operacao = input frame {&FRAME-NAME} int-ds-tp-natur-oper.nat-operacao)
  then do:
      run utp/ut-msgs.p(input "show",
                        input 17006,
                        input ("Natureza de sa°da inv†lida!" + "~~" + "Natureza de operaá∆o de sa°da deve estar cadastrada.")).
      return "ADM-ERROR".
  end.

  if input frame {&FRAME-NAME} int-ds-tp-natur-oper.nat-oper-entrada <> "" AND
     not can-find(first natur-oper no-lock where natur-oper.nat-operacao = input frame {&FRAME-NAME} int-ds-tp-natur-oper.nat-oper-entrada)
  then do:
      run utp/ut-msgs.p(input "show",
                        input 17006,
                        input ("Natureza de entrada inv†lida!" + "~~" + "Natureza de operaá∆o de entrada deve estar cadastrada.")).
      return "ADM-ERROR".
  end.

  if input frame {&FRAME-NAME} int-ds-tp-natur-oper.cod-cond-pag <> ? then do:
      if input frame {&FRAME-NAME} int-ds-tp-natur-oper.cod-cond-pag <> 0 and
         not can-find(first cond-pagto no-lock where cond-pagto.cod-cond-pag = input frame {&FRAME-NAME} int-ds-tp-natur-oper.cod-cond-pag)
      then do:
          run utp/ut-msgs.p(input "show",
                            input 17006,
                            input ("Cond. Pagto inv†lida!" + "~~" + "Cond. de Pagamento deve estar cadastrada.")).
          return "ADM-ERROR".
      end.
  end.

  if input frame {&FRAME-NAME} int-ds-tp-natur-oper.cod-portador <> 0 and
     input frame {&FRAME-NAME} int-ds-tp-natur-oper.cod-portador <> ? and
     not can-find(first mgadm.portador no-lock where 
                  mgadm.portador.cod-portador = input frame {&FRAME-NAME} int-ds-tp-natur-oper.cod-portador and
                  mgadm.portador.modalidade = {adinc/i03ad209.i 06 cb-modalidade:screen-value})
  then do:
      run utp/ut-msgs.p(input "show",
                        input 17006,
                        input ("Portador inv†lido!" + "~~" + "Portador deve estar cadastrado.")).
      return "ADM-ERROR".
  end.
  if input frame {&FRAME-NAME} int-ds-tp-natur-oper.serie <> "" and
     input frame {&FRAME-NAME} int-ds-tp-natur-oper.serie <> ? and
     not can-find(first serie no-lock where serie.serie = input frame {&FRAME-NAME} int-ds-tp-natur-oper.serie and
                  serie.forma-emis = 1 /* Automatica */)
  then do:
      run utp/ut-msgs.p(input "show",
                        input 17006,
                        input ("SÇrie inv†lida!" + "~~" + "SÇrie de operaá∆o deve estar cadastrada com forma de emiss∆o AUTOMµTICA.")).
      return "ADM-ERROR".
  end.

  if (input frame {&FRAME-NAME} int-ds-tp-natur-oper.tp-pedido = "15" or
      input frame {&FRAME-NAME} int-ds-tp-natur-oper.tp-pedido = "32") and
      input frame {&FRAME-NAME} int-ds-tp-natur-oper.cst-icms = ?
  then do:
      run utp/ut-msgs.p(input "show",
                        input 17006,
                        input ("CST inv†lido!" + "~~" + "CST ICMS deve ser informado.")).
      return "ADM-ERROR".
  end.
  
  /* Dispatch standard ADM method.                             */
  RUN dispatch IN THIS-PROCEDURE ( INPUT 'assign-record':U ) .

  /* Code placed here will execute AFTER standard behavior.    */
  assign cb-modalidade
         int-ds-tp-natur-oper.modalidade = {adinc/i03ad209.i 06 cb-modalidade}.


                

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-initialize V-table-Win 
PROCEDURE local-initialize :
/*------------------------------------------------------------------------------
  Purpose:     Override standard ADM method
  Notes:       
------------------------------------------------------------------------------*/

  /* Code placed here will execute PRIOR to standard behavior. */

  /* Dispatch standard ADM method.                             */
  RUN dispatch IN THIS-PROCEDURE ( INPUT 'initialize':U ) .

  /* Code placed here will execute AFTER standard behavior.    */
    int-ds-tp-natur-oper.cod-cond-pag:LOAD-MOUSE-POINTER("image/lupa.cur":U) IN FRAME f-Main.
    int-ds-tp-natur-oper.cod-emitente:LOAD-MOUSE-POINTER("image/lupa.cur":U) IN FRAME f-Main.
    int-ds-tp-natur-oper.cod-estabel:LOAD-MOUSE-POINTER("image/lupa.cur":U) IN FRAME f-Main.
    int-ds-tp-natur-oper.class-fiscal:LOAD-MOUSE-POINTER("image/lupa.cur":U) IN FRAME f-Main.
    int-ds-tp-natur-oper.nat-operacao:LOAD-MOUSE-POINTER("image/lupa.cur":U) IN FRAME f-Main.
    int-ds-tp-natur-oper.nat-oper-entrada:LOAD-MOUSE-POINTER("image/lupa.cur":U) IN FRAME f-Main.
    int-ds-tp-natur-oper.cod-portador:LOAD-MOUSE-POINTER("image/lupa.cur":U) IN FRAME f-Main.
    int-ds-tp-natur-oper.serie:LOAD-MOUSE-POINTER("image/lupa.cur":U) IN FRAME f-Main.

    assign cb-modalidade:list-items = {adinc/i03ad209.i 03}.
    cb-modalidade:screen-value = {adinc/i03ad209.i 04 1}.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-row-available V-table-Win 
PROCEDURE local-row-available :
/*------------------------------------------------------------------------------
  Purpose:     Override standard ADM method
  Notes:       
------------------------------------------------------------------------------*/

  /* Code placed here will execute PRIOR to standard behavior. */

  /* Dispatch standard ADM method.                             */
  RUN dispatch IN THIS-PROCEDURE ( INPUT 'row-available':U ) .

  /* Code placed here will execute AFTER standard behavior.    */
  apply "LEAVE":U to int-ds-tp-natur-oper.cod-cond-pag in frame {&FRAME-NAME}.
  apply "LEAVE":U to int-ds-tp-natur-oper.cod-estabel in frame {&FRAME-NAME}.
  apply "LEAVE":U to int-ds-tp-natur-oper.cod-emitente in frame {&FRAME-NAME}.
  apply "LEAVE":U to int-ds-tp-natur-oper.nat-operacao in frame {&FRAME-NAME}.
  apply "LEAVE":U to int-ds-tp-natur-oper.nat-oper-entrada in frame {&FRAME-NAME}.
  apply "LEAVE":U to int-ds-tp-natur-oper.class-fiscal in frame {&FRAME-NAME}.
  apply "LEAVE":U to int-ds-tp-natur-oper.cod-portador in frame {&FRAME-NAME}.
  apply "LEAVE":U to cb-modalidade in frame {&FRAME-NAME}.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE send-records V-table-Win  _ADM-SEND-RECORDS
PROCEDURE send-records :
/*------------------------------------------------------------------------------
  Purpose:     Send record ROWID's for all tables used by
               this file.
  Parameters:  see template/snd-head.i
------------------------------------------------------------------------------*/

  /* Define variables needed by this internal procedure.               */
  {src/adm/template/snd-head.i}

  /* For each requested table, put it's ROWID in the output list.      */
  {src/adm/template/snd-list.i "int-ds-tp-natur-oper"}

  /* Deal with any unexpected table requests before closing.           */
  {src/adm/template/snd-end.i}

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE state-changed V-table-Win 
PROCEDURE state-changed :
/* -----------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
-------------------------------------------------------------*/
  DEFINE INPUT PARAMETER p-issuer-hdl AS HANDLE    NO-UNDO.
  DEFINE INPUT PARAMETER p-state      AS CHARACTER NO-UNDO.

  CASE p-state:
      /* Object instance CASEs can go here to replace standard behavior
         or add new cases. */
      {src/adm/template/vstates.i}
  END CASE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

