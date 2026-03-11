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
&Scoped-define EXTERNAL-TABLES int-ds-tp-trib-natur-oper
&Scoped-define FIRST-EXTERNAL-TABLE int-ds-tp-trib-natur-oper


/* Need to scope the external tables to this procedure                  */
DEFINE QUERY external_tables FOR int-ds-tp-trib-natur-oper.
/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS int-ds-tp-trib-natur-oper.tp-pedido ~
int-ds-tp-trib-natur-oper.cd-trib-icm int-ds-tp-trib-natur-oper.uf-origem ~
int-ds-tp-trib-natur-oper.nat-saida-est ~
int-ds-tp-trib-natur-oper.nat-saida-inter ~
int-ds-tp-trib-natur-oper.nat-entrada-est ~
int-ds-tp-trib-natur-oper.nat-entrada-inter ~
int-ds-tp-trib-natur-oper.nat-saida-est-nao-contrib ~
int-ds-tp-trib-natur-oper.nat-saida-inter-nao-contrib ~
int-ds-tp-trib-natur-oper.nat-entrada-est-nao-contrib ~
int-ds-tp-trib-natur-oper.nat-entrada-inter-nao-contrib 
&Scoped-define ENABLED-TABLES int-ds-tp-trib-natur-oper
&Scoped-define FIRST-ENABLED-TABLE int-ds-tp-trib-natur-oper
&Scoped-Define ENABLED-OBJECTS RECT-19 RECT-22 RECT-24 RECT-23 RECT-25 
&Scoped-Define DISPLAYED-FIELDS int-ds-tp-trib-natur-oper.tp-pedido ~
int-ds-tp-trib-natur-oper.cd-trib-icm int-ds-tp-trib-natur-oper.uf-origem ~
int-ds-tp-trib-natur-oper.nat-saida-est ~
int-ds-tp-trib-natur-oper.nat-saida-inter ~
int-ds-tp-trib-natur-oper.nat-entrada-est ~
int-ds-tp-trib-natur-oper.nat-entrada-inter ~
int-ds-tp-trib-natur-oper.nat-saida-est-nao-contrib ~
int-ds-tp-trib-natur-oper.nat-saida-inter-nao-contrib ~
int-ds-tp-trib-natur-oper.nat-entrada-est-nao-contrib ~
int-ds-tp-trib-natur-oper.nat-entrada-inter-nao-contrib 
&Scoped-define DISPLAYED-TABLES int-ds-tp-trib-natur-oper
&Scoped-define FIRST-DISPLAYED-TABLE int-ds-tp-trib-natur-oper
&Scoped-Define DISPLAYED-OBJECTS cNatSaiEst cNatSaiInter cNatEntEst ~
cNatEntInter cNatSaiEstNAO cNatSaiInterNAO cNatEntEstNAO cNatEntInterNAO 

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
DEFINE VARIABLE cNatEntEst AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 61 BY .88 NO-UNDO.

DEFINE VARIABLE cNatEntEstNAO AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 61 BY .88 NO-UNDO.

DEFINE VARIABLE cNatEntInter AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 61 BY .88 NO-UNDO.

DEFINE VARIABLE cNatEntInterNAO AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 61 BY .88 NO-UNDO.

DEFINE VARIABLE cNatSaiEst AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 61 BY .88 NO-UNDO.

DEFINE VARIABLE cNatSaiEstNAO AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 61 BY .88 NO-UNDO.

DEFINE VARIABLE cNatSaiInter AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 61 BY .88 NO-UNDO.

DEFINE VARIABLE cNatSaiInterNAO AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 61 BY .88 NO-UNDO.

DEFINE RECTANGLE RECT-19
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 91 BY 4.25.

DEFINE RECTANGLE RECT-22
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 91 BY 3.21.

DEFINE RECTANGLE RECT-23
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 91 BY 3.21.

DEFINE RECTANGLE RECT-24
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 91 BY 3.17.

DEFINE RECTANGLE RECT-25
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 91 BY 3.17.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME F-Main
     int-ds-tp-trib-natur-oper.tp-pedido AT ROW 1.75 COL 17 COLON-ALIGNED WIDGET-ID 110
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
                     "BALANCO MANUAL FILIAL - PERMITE CONSOLIDA€ÇO","14",
                     "DEVOLUCAO FILIAL - FORNECEDOR","15",
                     "DEVOLUCAO DEPOSITO - FORNECEDOR","16",
                     "TRANSFERENCIA DEPOSITO - DEPOSITO (COMERCIALIZAVEL)","17",
                     "TRANSFERENCIA DEPOSITO - DEPOSITO (AVARIA)","18",
                     "TRANSFERENCIA FILIAL - FILIAL","19",
                     "BALANCO MANUAL FILIAL - ESPECIAL (MED. CONTROLADO)","31",
                     "DEVOLUCAO FILIAL - FORNECEDOR (MED. CONTROLADO)","32",
                     "TRANSFERENCIA FILIAL - FORNECEDOR (MED. CONTROLADO)","33",
                     "BALAN€O GERAL CONTROLADOS DEPOSITO","35",
                     "BALAN€O GERAL CONTROLADOS FILIAL","36",
                     "ATIVO IMOBILIZADO DEPOSITO => FILIAL","37",
                     "ESTORNO","38",
                     "ATIVO IMOBILIZADO FILIAL => FILIAL","39",
                     "RETIRADA FILIAL => PROPRIA FILIAL","46",
                     "SUBSTITUI€ÇO DE CUPOM","48",
                     "ESTORNO","51",
                     "ESTORNO","52",
                     "ESTORNO","53"
          DROP-DOWN-LIST
          SIZE 72 BY 1
     int-ds-tp-trib-natur-oper.cd-trib-icm AT ROW 3 COL 19.29 NO-LABEL WIDGET-ID 148
          VIEW-AS RADIO-SET HORIZONTAL
          RADIO-BUTTONS 
                    "Nenhum":U, 0,
"Tributado":U, 1,
"Isento":U, 2,
"Outros":U, 3,
"ST":U, 9
          SIZE 62 BY .75
     int-ds-tp-trib-natur-oper.uf-origem AT ROW 4 COL 17 COLON-ALIGNED HELP
          "Unidade da federa‡Æo origem (somente para exce‡äes)" WIDGET-ID 188
          VIEW-AS FILL-IN 
          SIZE 4 BY .88
     int-ds-tp-trib-natur-oper.nat-saida-est AT ROW 7.21 COL 17 COLON-ALIGNED WIDGET-ID 158
          LABEL "Nat. Estadual"
          VIEW-AS FILL-IN 
          SIZE 10 BY .88
     cNatSaiEst AT ROW 7.21 COL 27 COLON-ALIGNED NO-LABEL
     int-ds-tp-trib-natur-oper.nat-saida-inter AT ROW 8.21 COL 17 COLON-ALIGNED WIDGET-ID 160
          LABEL "Nat. Interestadual"
          VIEW-AS FILL-IN 
          SIZE 10 BY .88
     cNatSaiInter AT ROW 8.21 COL 27 COLON-ALIGNED NO-LABEL WIDGET-ID 138
     int-ds-tp-trib-natur-oper.nat-entrada-est AT ROW 11 COL 17 COLON-ALIGNED WIDGET-ID 154
          LABEL "Nat. Estadual"
          VIEW-AS FILL-IN 
          SIZE 10 BY .88
     cNatEntEst AT ROW 11 COL 27 COLON-ALIGNED NO-LABEL WIDGET-ID 142
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE NO-VALIDATE THREE-D 
         AT COL 1 ROW 1 SCROLLABLE .

/* DEFINE FRAME statement is approaching 4K Bytes.  Breaking it up   */
DEFINE FRAME F-Main
     int-ds-tp-trib-natur-oper.nat-entrada-inter AT ROW 12 COL 17 COLON-ALIGNED WIDGET-ID 156
          LABEL "Nat. Interestadual"
          VIEW-AS FILL-IN 
          SIZE 10 BY .88
     cNatEntInter AT ROW 12 COL 27 COLON-ALIGNED NO-LABEL WIDGET-ID 140
     int-ds-tp-trib-natur-oper.nat-saida-est-nao-contrib AT ROW 14.75 COL 17 COLON-ALIGNED WIDGET-ID 180
          LABEL "Nat. Estadual"
          VIEW-AS FILL-IN 
          SIZE 10 BY .88
     cNatSaiEstNAO AT ROW 14.75 COL 27 COLON-ALIGNED NO-LABEL WIDGET-ID 168
     int-ds-tp-trib-natur-oper.nat-saida-inter-nao-contrib AT ROW 15.75 COL 17 COLON-ALIGNED WIDGET-ID 182
          LABEL "Nat. Interestadual"
          VIEW-AS FILL-IN 
          SIZE 10 BY .88
     cNatSaiInterNAO AT ROW 15.75 COL 27 COLON-ALIGNED NO-LABEL WIDGET-ID 170
     int-ds-tp-trib-natur-oper.nat-entrada-est-nao-contrib AT ROW 18.5 COL 17 COLON-ALIGNED WIDGET-ID 184
          LABEL "Nat. Estadual"
          VIEW-AS FILL-IN 
          SIZE 10 BY .88
     cNatEntEstNAO AT ROW 18.5 COL 27 COLON-ALIGNED NO-LABEL WIDGET-ID 164
     int-ds-tp-trib-natur-oper.nat-entrada-inter-nao-contrib AT ROW 19.5 COL 17 COLON-ALIGNED WIDGET-ID 186
          LABEL "Nat. Interestadual"
          VIEW-AS FILL-IN 
          SIZE 10 BY .88
     cNatEntInterNAO AT ROW 19.5 COL 27 COLON-ALIGNED NO-LABEL WIDGET-ID 166
     "Sa¡das p/ Contribuinte" VIEW-AS TEXT
          SIZE 20 BY .67 AT ROW 6 COL 4 WIDGET-ID 120
     "Sa¡das NAO Contribuinte" VIEW-AS TEXT
          SIZE 22 BY .67 AT ROW 13.5 COL 4 WIDGET-ID 176
     "Entradas NAO Contribuinte" VIEW-AS TEXT
          SIZE 23 BY .67 AT ROW 17.25 COL 4 WIDGET-ID 178
     "Tributa‡Æo ICMS:" VIEW-AS TEXT
          SIZE 15 BY .67 AT ROW 2.92 COL 3.86 WIDGET-ID 162
     "Opera‡Æo" VIEW-AS TEXT
          SIZE 9 BY .67 AT ROW 1 COL 4 WIDGET-ID 40
     "<--- Preencher somente para exce‡äes" VIEW-AS TEXT
          SIZE 34 BY .67 AT ROW 4.08 COL 25 WIDGET-ID 190
     "Entradas p/ Contribuinte" VIEW-AS TEXT
          SIZE 21 BY .67 AT ROW 9.75 COL 4 WIDGET-ID 146
     RECT-19 AT ROW 1.25 COL 2 WIDGET-ID 12
     RECT-22 AT ROW 6.25 COL 2 WIDGET-ID 118
     RECT-24 AT ROW 10 COL 2 WIDGET-ID 144
     RECT-23 AT ROW 13.75 COL 2 WIDGET-ID 172
     RECT-25 AT ROW 17.5 COL 2 WIDGET-ID 174
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE NO-VALIDATE THREE-D 
         AT COL 1 ROW 1 SCROLLABLE .


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: SmartViewer
   External Tables: mgesp.int-ds-tp-trib-natur-oper
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
         HEIGHT             = 20.17
         WIDTH              = 93.14.
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

/* SETTINGS FOR FILL-IN cNatEntEst IN FRAME F-Main
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN cNatEntEstNAO IN FRAME F-Main
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN cNatEntInter IN FRAME F-Main
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN cNatEntInterNAO IN FRAME F-Main
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN cNatSaiEst IN FRAME F-Main
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN cNatSaiEstNAO IN FRAME F-Main
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN cNatSaiInter IN FRAME F-Main
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN cNatSaiInterNAO IN FRAME F-Main
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN int-ds-tp-trib-natur-oper.nat-entrada-est IN FRAME F-Main
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN int-ds-tp-trib-natur-oper.nat-entrada-est-nao-contrib IN FRAME F-Main
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN int-ds-tp-trib-natur-oper.nat-entrada-inter IN FRAME F-Main
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN int-ds-tp-trib-natur-oper.nat-entrada-inter-nao-contrib IN FRAME F-Main
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN int-ds-tp-trib-natur-oper.nat-saida-est IN FRAME F-Main
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN int-ds-tp-trib-natur-oper.nat-saida-est-nao-contrib IN FRAME F-Main
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN int-ds-tp-trib-natur-oper.nat-saida-inter IN FRAME F-Main
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN int-ds-tp-trib-natur-oper.nat-saida-inter-nao-contrib IN FRAME F-Main
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN int-ds-tp-trib-natur-oper.uf-origem IN FRAME F-Main
   EXP-HELP                                                             */
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

&Scoped-define SELF-NAME int-ds-tp-trib-natur-oper.nat-entrada-est
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL int-ds-tp-trib-natur-oper.nat-entrada-est V-table-Win
ON F5 OF int-ds-tp-trib-natur-oper.nat-entrada-est IN FRAME F-Main /* Nat. Estadual */
OR MOUSE-SELECT-DBLCLICK OF int-ds-tp-trib-natur-oper.nat-entrada-est in frame {&FRAME-NAME} DO:
        {include/zoomvar.i &prog-zoom=inzoom/z01in245.w
                                &campo=int-ds-tp-trib-natur-oper.nat-entrada-est
                                &campozoom=nat-operacao}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL int-ds-tp-trib-natur-oper.nat-entrada-est V-table-Win
ON LEAVE OF int-ds-tp-trib-natur-oper.nat-entrada-est IN FRAME F-Main /* Nat. Estadual */
DO:
    cNatEntEst:screen-value in frame {&frame-name} = "".
    for first mgind.natur-oper 
        fields (nat-operacao denominacao)
        no-lock where
        mgind.natur-oper.nat-operacao = input frame {&FRAME-NAME} int-ds-tp-trib-natur-oper.nat-Entrada-Est.
        display natur-oper.denominacao @ cNatEntEst with frame {&FRAME-NAME}.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME int-ds-tp-trib-natur-oper.nat-entrada-est-nao-contrib
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL int-ds-tp-trib-natur-oper.nat-entrada-est-nao-contrib V-table-Win
ON F5 OF int-ds-tp-trib-natur-oper.nat-entrada-est-nao-contrib IN FRAME F-Main /* Nat. Estadual */
OR MOUSE-SELECT-DBLCLICK OF int-ds-tp-trib-natur-oper.nat-entrada-est-nao-contrib in frame {&FRAME-NAME} DO:
        {include/zoomvar.i &prog-zoom=inzoom/z01in245.w
                                &campo=int-ds-tp-trib-natur-oper.nat-entrada-est-nao-contrib
                                &campozoom=nat-operacao}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL int-ds-tp-trib-natur-oper.nat-entrada-est-nao-contrib V-table-Win
ON LEAVE OF int-ds-tp-trib-natur-oper.nat-entrada-est-nao-contrib IN FRAME F-Main /* Nat. Estadual */
DO:
    cNatEntEstNAO:screen-value in frame {&frame-name} = "".
    for first mgind.natur-oper 
        fields (nat-operacao denominacao)
        no-lock where
        mgind.natur-oper.nat-operacao = input frame {&FRAME-NAME} int-ds-tp-trib-natur-oper.nat-entrada-est-nao-contrib.
        display natur-oper.denominacao @ cNatEntEstNAO with frame {&FRAME-NAME}.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME int-ds-tp-trib-natur-oper.nat-entrada-inter
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL int-ds-tp-trib-natur-oper.nat-entrada-inter V-table-Win
ON F5 OF int-ds-tp-trib-natur-oper.nat-entrada-inter IN FRAME F-Main /* Nat. Interestadual */
OR MOUSE-SELECT-DBLCLICK OF int-ds-tp-trib-natur-oper.nat-entrada-inter in frame {&FRAME-NAME} DO:
        {include/zoomvar.i &prog-zoom=inzoom/z01in245.w
                                &campo=int-ds-tp-trib-natur-oper.nat-entrada-inter
                                &campozoom=nat-operacao}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL int-ds-tp-trib-natur-oper.nat-entrada-inter V-table-Win
ON LEAVE OF int-ds-tp-trib-natur-oper.nat-entrada-inter IN FRAME F-Main /* Nat. Interestadual */
DO:
    cNatEntInter:screen-value in frame {&frame-name} = "".
    for first mgind.natur-oper 
        fields (nat-operacao denominacao)
        no-lock where
        mgind.natur-oper.nat-operacao = input frame {&FRAME-NAME} int-ds-tp-trib-natur-oper.nat-Entrada-inter.
        display natur-oper.denominacao @ cNatEntInter with frame {&FRAME-NAME}.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME int-ds-tp-trib-natur-oper.nat-entrada-inter-nao-contrib
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL int-ds-tp-trib-natur-oper.nat-entrada-inter-nao-contrib V-table-Win
ON F5 OF int-ds-tp-trib-natur-oper.nat-entrada-inter-nao-contrib IN FRAME F-Main /* Nat. Interestadual */
OR MOUSE-SELECT-DBLCLICK OF int-ds-tp-trib-natur-oper.nat-entrada-inter-nao-contrib in frame {&FRAME-NAME} DO:
        {include/zoomvar.i &prog-zoom=inzoom/z01in245.w
                                &campo=int-ds-tp-trib-natur-oper.nat-entrada-inter-nao-contrib
                                &campozoom=nat-operacao}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL int-ds-tp-trib-natur-oper.nat-entrada-inter-nao-contrib V-table-Win
ON LEAVE OF int-ds-tp-trib-natur-oper.nat-entrada-inter-nao-contrib IN FRAME F-Main /* Nat. Interestadual */
DO:
    cNatEntInterNAO:screen-value in frame {&frame-name} = "".
    for first mgind.natur-oper 
        fields (nat-operacao denominacao)
        no-lock where
        mgind.natur-oper.nat-operacao = input frame {&FRAME-NAME} int-ds-tp-trib-natur-oper.nat-Entrada-Inter-nao-contrib.
        display natur-oper.denominacao @ cNatEntInterNAO with frame {&FRAME-NAME}.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME int-ds-tp-trib-natur-oper.nat-saida-est
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL int-ds-tp-trib-natur-oper.nat-saida-est V-table-Win
ON F5 OF int-ds-tp-trib-natur-oper.nat-saida-est IN FRAME F-Main /* Nat. Estadual */
OR MOUSE-SELECT-DBLCLICK OF int-ds-tp-trib-natur-oper.nat-saida-est in frame {&FRAME-NAME} DO:
        {include/zoomvar.i &prog-zoom=inzoom/z01in245.w
                                &campo=int-ds-tp-trib-natur-oper.nat-saida-est
                                &campozoom=nat-operacao}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL int-ds-tp-trib-natur-oper.nat-saida-est V-table-Win
ON LEAVE OF int-ds-tp-trib-natur-oper.nat-saida-est IN FRAME F-Main /* Nat. Estadual */
DO:
    cNatSaiEst:screen-value in frame {&frame-name} = "".
    for first mgind.natur-oper 
        fields (nat-operacao denominacao)
        no-lock where
        mgind.natur-oper.nat-operacao = input frame {&FRAME-NAME} int-ds-tp-trib-natur-oper.nat-saida-est.
        display natur-oper.denominacao @ cNatSaiEst with frame {&FRAME-NAME}.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME int-ds-tp-trib-natur-oper.nat-saida-est-nao-contrib
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL int-ds-tp-trib-natur-oper.nat-saida-est-nao-contrib V-table-Win
ON F5 OF int-ds-tp-trib-natur-oper.nat-saida-est-nao-contrib IN FRAME F-Main /* Nat. Estadual */
OR MOUSE-SELECT-DBLCLICK OF int-ds-tp-trib-natur-oper.nat-saida-est-nao-contrib in frame {&FRAME-NAME} DO:
        {include/zoomvar.i &prog-zoom=inzoom/z01in245.w
                                &campo=int-ds-tp-trib-natur-oper.nat-saida-est-nao-contrib
                                &campozoom=nat-operacao}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL int-ds-tp-trib-natur-oper.nat-saida-est-nao-contrib V-table-Win
ON LEAVE OF int-ds-tp-trib-natur-oper.nat-saida-est-nao-contrib IN FRAME F-Main /* Nat. Estadual */
DO:
    cNatSaiEstNAO:screen-value in frame {&frame-name} = "".
    for first mgind.natur-oper 
        fields (nat-operacao denominacao)
        no-lock where
        mgind.natur-oper.nat-operacao = input frame {&FRAME-NAME} int-ds-tp-trib-natur-oper.nat-saida-est-nao-contrib.
        display natur-oper.denominacao @ cNatSaiEstNAO with frame {&FRAME-NAME}.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME int-ds-tp-trib-natur-oper.nat-saida-inter
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL int-ds-tp-trib-natur-oper.nat-saida-inter V-table-Win
ON F5 OF int-ds-tp-trib-natur-oper.nat-saida-inter IN FRAME F-Main /* Nat. Interestadual */
OR MOUSE-SELECT-DBLCLICK OF int-ds-tp-trib-natur-oper.nat-saida-inter in frame {&FRAME-NAME} DO:
        {include/zoomvar.i &prog-zoom=inzoom/z01in245.w
                                &campo=int-ds-tp-trib-natur-oper.nat-saida-inter
                                &campozoom=nat-operacao}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL int-ds-tp-trib-natur-oper.nat-saida-inter V-table-Win
ON LEAVE OF int-ds-tp-trib-natur-oper.nat-saida-inter IN FRAME F-Main /* Nat. Interestadual */
DO:
    cNatSaiInter:screen-value in frame {&frame-name} = "".
    for first mgind.natur-oper 
        fields (nat-operacao denominacao)
        no-lock where
        mgind.natur-oper.nat-operacao = input frame {&FRAME-NAME} int-ds-tp-trib-natur-oper.nat-saida-inter.
        display natur-oper.denominacao @ cNatSaiInter with frame {&FRAME-NAME}.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME int-ds-tp-trib-natur-oper.nat-saida-inter-nao-contrib
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL int-ds-tp-trib-natur-oper.nat-saida-inter-nao-contrib V-table-Win
ON F5 OF int-ds-tp-trib-natur-oper.nat-saida-inter-nao-contrib IN FRAME F-Main /* Nat. Interestadual */
OR MOUSE-SELECT-DBLCLICK OF int-ds-tp-trib-natur-oper.nat-saida-inter-nao-contrib in frame {&FRAME-NAME} DO:
        {include/zoomvar.i &prog-zoom=inzoom/z01in245.w
                                &campo=int-ds-tp-trib-natur-oper.nat-saida-inter-nao-contrib
                                &campozoom=nat-operacao}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL int-ds-tp-trib-natur-oper.nat-saida-inter-nao-contrib V-table-Win
ON LEAVE OF int-ds-tp-trib-natur-oper.nat-saida-inter-nao-contrib IN FRAME F-Main /* Nat. Interestadual */
DO:
    cNatSaiInterNAO:screen-value in frame {&frame-name} = "".
    for first mgind.natur-oper 
        fields (nat-operacao denominacao)
        no-lock where
        mgind.natur-oper.nat-operacao = input frame {&FRAME-NAME} int-ds-tp-trib-natur-oper.nat-saida-Inter-nao-contrib.
        display natur-oper.denominacao @ cNatSaiInterNAO with frame {&FRAME-NAME}.
    end.
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
  {src/adm/template/row-list.i "int-ds-tp-trib-natur-oper"}

  /* Get the record ROWID's from the RECORD-SOURCE.                  */
  {src/adm/template/row-get.i}

  /* FIND each record specified by the RECORD-SOURCE.                */
  {src/adm/template/row-find.i "int-ds-tp-trib-natur-oper"}

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

  if input frame {&FRAME-NAME} int-ds-tp-trib-natur-oper.uf-origem <> "" and
     not can-find(first unid-feder no-lock where
                  unid-feder.pais = "BR" and
                  unid-feder.estado = int-ds-tp-trib-natur-oper.uf-origem:screen-value in frame {&FRAME-NAME}) then do:
      run utp/ut-msgs.p(input "show",
                        input 17006,
                        input ("Unidade da federa‡Æo inv lida!" + "~~" + "Unidade da federa‡Æo deve estar cadastrada ou ficar em branco.")).
      apply "entry":U to int-ds-tp-trib-natur-oper.uf-origem in frame {&FRAME-NAME}.
      return "ADM-ERROR".
  end.  

  if input frame {&FRAME-NAME} int-ds-tp-trib-natur-oper.nat-saida-est = "" or
     not can-find(first natur-oper no-lock where natur-oper.nat-operacao = input frame {&FRAME-NAME} int-ds-tp-trib-natur-oper.nat-saida-est)
  then do:
      run utp/ut-msgs.p(input "show",
                        input 17006,
                        input ("Natureza de sa¡da estadual inv lida!" + "~~" + "Natureza de opera‡Æo de sa¡da deve estar cadastrada.")).
      apply "entry":U to int-ds-tp-trib-natur-oper.nat-saida-est in frame {&FRAME-NAME}.
      return "ADM-ERROR".
  end.

  if input frame {&FRAME-NAME} int-ds-tp-trib-natur-oper.nat-saida-inter = "" or
     not can-find(first natur-oper no-lock where natur-oper.nat-operacao = input frame {&FRAME-NAME} int-ds-tp-trib-natur-oper.nat-saida-inter)
  then do:
      run utp/ut-msgs.p(input "show",
                        input 17006,
                        input ("Natureza de sa¡da interestadual inv lida!" + "~~" + "Natureza de opera‡Æo de sa¡da deve estar cadastrada.")).
      apply "entry":U to int-ds-tp-trib-natur-oper.nat-saida-inter in frame {&FRAME-NAME}.
      return "ADM-ERROR".
  end.

  if input frame {&FRAME-NAME} int-ds-tp-trib-natur-oper.nat-saida-est-nao-contrib <> "" and
     not can-find(first natur-oper no-lock where natur-oper.nat-operacao = input frame {&FRAME-NAME} int-ds-tp-trib-natur-oper.nat-saida-est-nao-contrib)
  then do:
      run utp/ut-msgs.p(input "show",
                        input 17006,
                        input ("Natureza de sa¡da estadual NAO contribuinte inv lida!" + "~~" + "Natureza de opera‡Æo de sa¡da deve estar cadastrada.")).
      apply "entry":U to int-ds-tp-trib-natur-oper.nat-saida-est-nao-contrib in frame {&FRAME-NAME}.
      return "ADM-ERROR".
  end.

  if input frame {&FRAME-NAME} int-ds-tp-trib-natur-oper.nat-saida-inter-nao-contrib <> "" and
     not can-find(first natur-oper no-lock where natur-oper.nat-operacao = input frame {&FRAME-NAME} int-ds-tp-trib-natur-oper.nat-saida-inter-nao-contrib)
  then do:
      run utp/ut-msgs.p(input "show",
                        input 17006,
                        input ("Natureza de sa¡da interestadual NAO contribuinte inv lida!" + "~~" + "Natureza de opera‡Æo de sa¡da deve estar cadastrada.")).
      apply "entry":U to int-ds-tp-trib-natur-oper.nat-saida-inter-nao-contrib in frame {&FRAME-NAME}.
      return "ADM-ERROR".
  end.


  if input frame {&FRAME-NAME} int-ds-tp-trib-natur-oper.nat-entrada-est <> "" AND
     not can-find(first natur-oper no-lock where natur-oper.nat-operacao = input frame {&FRAME-NAME} int-ds-tp-trib-natur-oper.nat-entrada-est)
  then do:
      run utp/ut-msgs.p(input "show",
                        input 17006,
                        input ("Natureza de entrada estadual inv lida!" + "~~" + "Natureza de opera‡Æo de entrada deve estar cadastrada.")).
      apply "entry":U to int-ds-tp-trib-natur-oper.nat-entrada-est in frame {&FRAME-NAME}.
      return "ADM-ERROR".
  end.
  
  if input frame {&FRAME-NAME} int-ds-tp-trib-natur-oper.nat-entrada-inter <> "" AND
     not can-find(first natur-oper no-lock where natur-oper.nat-operacao = input frame {&FRAME-NAME} int-ds-tp-trib-natur-oper.nat-entrada-inter)
  then do:
      run utp/ut-msgs.p(input "show",
                        input 17006,
                        input ("Natureza de entrada interestadual inv lida!" + "~~" + "Natureza de opera‡Æo de entrada deve estar cadastrada.")).
      apply "entry":U to int-ds-tp-trib-natur-oper.nat-entrada-inter in frame {&FRAME-NAME}.
      return "ADM-ERROR".
  end.

  if input frame {&FRAME-NAME} int-ds-tp-trib-natur-oper.nat-entrada-est-nao-contrib <> "" AND
     not can-find(first natur-oper no-lock where natur-oper.nat-operacao = input frame {&FRAME-NAME} int-ds-tp-trib-natur-oper.nat-entrada-est-nao-contrib)
  then do:
      run utp/ut-msgs.p(input "show",
                        input 17006,
                        input ("Natureza de entrada estadual NAO contriubuinte inv lida!" + "~~" + "Natureza de opera‡Æo de entrada deve estar cadastrada.")).
      apply "entry":U to int-ds-tp-trib-natur-oper.nat-entrada-est-nao-contrib in frame {&FRAME-NAME}.
      return "ADM-ERROR".
  end.
  
  if input frame {&FRAME-NAME} int-ds-tp-trib-natur-oper.nat-entrada-inter-nao-contrib <> "" AND
     not can-find(first natur-oper no-lock where natur-oper.nat-operacao = input frame {&FRAME-NAME} int-ds-tp-trib-natur-oper.nat-entrada-inter-nao-contrib)
  then do:
      run utp/ut-msgs.p(input "show",
                        input 17006,
                        input ("Natureza de entrada interestadual NAO contriubuinte inv lida!" + "~~" + "Natureza de opera‡Æo de entrada deve estar cadastrada.")).
      apply "entry":U to int-ds-tp-trib-natur-oper.nat-entrada-inter-nao-contrib in frame {&FRAME-NAME}.
      return "ADM-ERROR".
  end.



  
  /* Dispatch standard ADM method.                             */
  RUN dispatch IN THIS-PROCEDURE ( INPUT 'assign-record':U ) .

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
  
  int-ds-tp-trib-natur-oper.nat-saida-est   :LOAD-MOUSE-POINTER("image/lupa.cur":U) IN FRAME f-Main.
  int-ds-tp-trib-natur-oper.nat-saida-inter :LOAD-MOUSE-POINTER("image/lupa.cur":U) IN FRAME f-Main.
  int-ds-tp-trib-natur-oper.nat-entrada-est :LOAD-MOUSE-POINTER("image/lupa.cur":U) IN FRAME f-Main.
  int-ds-tp-trib-natur-oper.nat-entrada-inter :LOAD-MOUSE-POINTER("image/lupa.cur":U) IN FRAME f-Main.
  int-ds-tp-trib-natur-oper.nat-saida-est-nao-contrib :LOAD-MOUSE-POINTER("image/lupa.cur":U) IN FRAME f-Main.
  int-ds-tp-trib-natur-oper.nat-saida-inter-nao-contrib :LOAD-MOUSE-POINTER("image/lupa.cur":U) IN FRAME f-Main.
  int-ds-tp-trib-natur-oper.nat-entrada-est-nao-contrib :LOAD-MOUSE-POINTER("image/lupa.cur":U) IN FRAME f-Main.
  int-ds-tp-trib-natur-oper.nat-entrada-inter-nao-contrib :LOAD-MOUSE-POINTER("image/lupa.cur":U) IN FRAME f-Main.
  
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

  apply "LEAVE":U to int-ds-tp-trib-natur-oper.nat-saida-est   in frame {&FRAME-NAME}.
  apply "LEAVE":U to int-ds-tp-trib-natur-oper.nat-saida-inter in frame {&FRAME-NAME}.
  apply "LEAVE":U to int-ds-tp-trib-natur-oper.nat-entrada-est in frame {&FRAME-NAME}.
  apply "LEAVE":U to int-ds-tp-trib-natur-oper.nat-entrada-inter in frame {&FRAME-NAME}.
  apply "LEAVE":U to int-ds-tp-trib-natur-oper.nat-saida-est-nao-contrib in frame {&FRAME-NAME}.
  apply "LEAVE":U to int-ds-tp-trib-natur-oper.nat-saida-inter-nao-contrib in frame {&FRAME-NAME}.
  apply "LEAVE":U to int-ds-tp-trib-natur-oper.nat-entrada-est-nao-contrib in frame {&FRAME-NAME}.
  apply "LEAVE":U to int-ds-tp-trib-natur-oper.nat-entrada-inter-nao-contrib in frame {&FRAME-NAME}.

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
  {src/adm/template/snd-list.i "int-ds-tp-trib-natur-oper"}

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

