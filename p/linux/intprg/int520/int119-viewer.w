&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI ADM1
&ANALYZE-RESUME
/* Connected Databases 
          emsesp           PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS V-table-Win 
/*:T *******************************************************************************
** Copyright DATASUL S.A. (1997)
** Todos os Direitos Reservados.
**
** Este fonte e de propriedade exclusiva da DATASUL, sua reproducao
** parcial ou total por qualquer meio, so podera ser feita mediante
** autorizacao expressa.
*******************************************************************************/
{include/i-prgvrs.i int115Bv 2.12.01.AVB}

/* Create an unnamed pool to store all the widgets created 
     by this procedure. This is a good default which assures
     that this procedure's triggers and internal procedures 
     will execute in this procedure's storage, and that proper
     cleanup will occur on deletion of the procedure. */

CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */
&Scop adm-attribute-dlg support/viewerd.w

/* global variable definitions */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */
def var v-row-parent as rowid no-undo.

define new global shared variable i-cd-trib-icm-115 as integer no-undo.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE SmartViewer
&Scoped-define DB-AWARE no

&Scoped-define ADM-SUPPORTED-LINKS Record-Source,Record-Target,TableIO-Target

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME f-main

/* External Tables                                                      */
&Scoped-define EXTERNAL-TABLES int-ds-tp-trib-natur-oper
&Scoped-define FIRST-EXTERNAL-TABLE int-ds-tp-trib-natur-oper


/* Need to scope the external tables to this procedure                  */
DEFINE QUERY external_tables FOR int-ds-tp-trib-natur-oper.
/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS int-ds-tp-trib-natur-oper.nat-saida-est ~
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
&Scoped-Define DISPLAYED-FIELDS int-ds-tp-trib-natur-oper.cd-trib-icm ~
int-ds-tp-trib-natur-oper.uf-origem int-ds-tp-trib-natur-oper.class-fiscal ~
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
&Scoped-Define DISPLAYED-OBJECTS cNCM cNatSaiEst cNatSaiInter cNatEntEst ~
cNatEntInter cNatSaiEstNAO cNatSaiInterNAO cNatEntEstNAO cNatEntInterNAO 

/* Custom List Definitions                                              */
/* ADM-CREATE-FIELDS,ADM-ASSIGN-FIELDS,ADM-MODIFY-FIELDS,List-4,List-5,List-6 */
&Scoped-define ADM-CREATE-FIELDS int-ds-tp-trib-natur-oper.uf-origem ~
int-ds-tp-trib-natur-oper.class-fiscal 

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

DEFINE VARIABLE cNCM AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 60 BY .88 NO-UNDO.

DEFINE RECTANGLE RECT-19
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 91 BY 3.75.

DEFINE RECTANGLE RECT-22
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 91 BY 2.75.

DEFINE RECTANGLE RECT-23
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 91 BY 2.75.

DEFINE RECTANGLE RECT-24
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 91 BY 2.75.

DEFINE RECTANGLE RECT-25
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 91 BY 2.75.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME f-main
     int-ds-tp-trib-natur-oper.cd-trib-icm AT ROW 1.75 COL 20 NO-LABEL WIDGET-ID 148
          VIEW-AS RADIO-SET HORIZONTAL
          RADIO-BUTTONS 
                    "Tributado":U, 1,
"Isento":U, 2,
"Cesta B†sica":U, 3,
"ST":U, 9,
"Outros":U, 4,
"Nenhum":U, 0
          SIZE 62 BY .75
     int-ds-tp-trib-natur-oper.uf-origem AT ROW 2.75 COL 18 COLON-ALIGNED HELP
          "Unidade da federaá∆o origem (somente para exceá‰es)" WIDGET-ID 188
          VIEW-AS FILL-IN 
          SIZE 4 BY .88
     int-ds-tp-trib-natur-oper.class-fiscal AT ROW 3.75 COL 18 COLON-ALIGNED WIDGET-ID 198
          LABEL "NCM" FORMAT "9999.99.99"
          VIEW-AS FILL-IN 
          SIZE 11.14 BY .88
     cNCM AT ROW 3.75 COL 29 COLON-ALIGNED NO-LABEL WIDGET-ID 196
     int-ds-tp-trib-natur-oper.nat-saida-est AT ROW 5.75 COL 17 COLON-ALIGNED WIDGET-ID 158
          LABEL "Nat. Estadual"
          VIEW-AS FILL-IN 
          SIZE 10 BY .88
     cNatSaiEst AT ROW 5.75 COL 27 COLON-ALIGNED NO-LABEL WIDGET-ID 192
     int-ds-tp-trib-natur-oper.nat-saida-inter AT ROW 6.75 COL 17 COLON-ALIGNED WIDGET-ID 160
          LABEL "Nat. Interestadual"
          VIEW-AS FILL-IN 
          SIZE 10 BY .88
     cNatSaiInter AT ROW 6.75 COL 27 COLON-ALIGNED NO-LABEL WIDGET-ID 138
     int-ds-tp-trib-natur-oper.nat-entrada-est AT ROW 8.75 COL 17 COLON-ALIGNED WIDGET-ID 154
          LABEL "Nat. Estadual"
          VIEW-AS FILL-IN 
          SIZE 10 BY .88
     cNatEntEst AT ROW 8.75 COL 27 COLON-ALIGNED NO-LABEL WIDGET-ID 142
     int-ds-tp-trib-natur-oper.nat-entrada-inter AT ROW 9.75 COL 17 COLON-ALIGNED WIDGET-ID 156
          LABEL "Nat. Interestadual"
          VIEW-AS FILL-IN 
          SIZE 10 BY .88
     cNatEntInter AT ROW 9.75 COL 27 COLON-ALIGNED NO-LABEL WIDGET-ID 140
     int-ds-tp-trib-natur-oper.nat-saida-est-nao-contrib AT ROW 11.75 COL 17 COLON-ALIGNED WIDGET-ID 180
          LABEL "Nat. Estadual"
          VIEW-AS FILL-IN 
          SIZE 10 BY .88
     cNatSaiEstNAO AT ROW 11.75 COL 27 COLON-ALIGNED NO-LABEL WIDGET-ID 168
     int-ds-tp-trib-natur-oper.nat-saida-inter-nao-contrib AT ROW 12.75 COL 17 COLON-ALIGNED WIDGET-ID 182
          LABEL "Nat. Interestadual"
          VIEW-AS FILL-IN 
          SIZE 10 BY .88
     cNatSaiInterNAO AT ROW 12.75 COL 27 COLON-ALIGNED NO-LABEL WIDGET-ID 170
     int-ds-tp-trib-natur-oper.nat-entrada-est-nao-contrib AT ROW 14.75 COL 17 COLON-ALIGNED WIDGET-ID 184
          LABEL "Nat. Estadual"
          VIEW-AS FILL-IN 
          SIZE 10 BY .88
     cNatEntEstNAO AT ROW 14.75 COL 27 COLON-ALIGNED NO-LABEL WIDGET-ID 164
     int-ds-tp-trib-natur-oper.nat-entrada-inter-nao-contrib AT ROW 15.75 COL 17 COLON-ALIGNED WIDGET-ID 186
          LABEL "Nat. Interestadual"
          VIEW-AS FILL-IN 
          SIZE 10 BY .88
     cNatEntInterNAO AT ROW 15.75 COL 27 COLON-ALIGNED NO-LABEL WIDGET-ID 166
     "Sa°das NAO Contribuinte" VIEW-AS TEXT
          SIZE 22 BY .67 AT ROW 11 COL 4 WIDGET-ID 176
     "Sa°das p/ Contribuinte" VIEW-AS TEXT
          SIZE 20 BY .67 AT ROW 5 COL 4 WIDGET-ID 120
     "Operaá∆o" VIEW-AS TEXT
          SIZE 9 BY .67 AT ROW 1 COL 4 WIDGET-ID 40
     "Tributaá∆o ICMS:" VIEW-AS TEXT
          SIZE 15 BY .67 AT ROW 1.75 COL 5 WIDGET-ID 162
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1 SCROLLABLE  WIDGET-ID 100.

/* DEFINE FRAME statement is approaching 4K Bytes.  Breaking it up   */
DEFINE FRAME f-main
     "Entradas NAO Contribuinte" VIEW-AS TEXT
          SIZE 23 BY .67 AT ROW 14 COL 4 WIDGET-ID 178
     "Entradas p/ Contribuinte" VIEW-AS TEXT
          SIZE 21 BY .67 AT ROW 8 COL 4 WIDGET-ID 146
     RECT-19 AT ROW 1.25 COL 2 WIDGET-ID 12
     RECT-22 AT ROW 5.25 COL 2 WIDGET-ID 118
     RECT-24 AT ROW 8.25 COL 2 WIDGET-ID 144
     RECT-23 AT ROW 11.25 COL 2 WIDGET-ID 172
     RECT-25 AT ROW 14.25 COL 2 WIDGET-ID 174
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1 SCROLLABLE  WIDGET-ID 100.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: SmartViewer
   External Tables: emsesp.int-ds-tp-trib-natur-oper
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
         HEIGHT             = 16.17
         WIDTH              = 92.86.
/* END WINDOW DEFINITION */
                                                                        */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _INCLUDED-LIB V-table-Win 
/* ************************* Included-Libraries *********************** */

{src/adm/method/viewer.i}
{include/c-viewer.i}
{utp/ut-glob.i}
{include/i_dbtype.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME




/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW V-table-Win
  VISIBLE,,RUN-PERSISTENT                                               */
/* SETTINGS FOR FRAME f-main
   NOT-VISIBLE FRAME-NAME Size-to-Fit                                   */
ASSIGN 
       FRAME f-main:SCROLLABLE       = FALSE
       FRAME f-main:HIDDEN           = TRUE.

/* SETTINGS FOR RADIO-SET int-ds-tp-trib-natur-oper.cd-trib-icm IN FRAME f-main
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN int-ds-tp-trib-natur-oper.class-fiscal IN FRAME f-main
   NO-ENABLE 1 EXP-LABEL EXP-FORMAT                                     */
/* SETTINGS FOR FILL-IN cNatEntEst IN FRAME f-main
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN cNatEntEstNAO IN FRAME f-main
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN cNatEntInter IN FRAME f-main
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN cNatEntInterNAO IN FRAME f-main
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN cNatSaiEst IN FRAME f-main
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN cNatSaiEstNAO IN FRAME f-main
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN cNatSaiInter IN FRAME f-main
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN cNatSaiInterNAO IN FRAME f-main
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN cNCM IN FRAME f-main
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN int-ds-tp-trib-natur-oper.nat-entrada-est IN FRAME f-main
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN int-ds-tp-trib-natur-oper.nat-entrada-est-nao-contrib IN FRAME f-main
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN int-ds-tp-trib-natur-oper.nat-entrada-inter IN FRAME f-main
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN int-ds-tp-trib-natur-oper.nat-entrada-inter-nao-contrib IN FRAME f-main
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN int-ds-tp-trib-natur-oper.nat-saida-est IN FRAME f-main
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN int-ds-tp-trib-natur-oper.nat-saida-est-nao-contrib IN FRAME f-main
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN int-ds-tp-trib-natur-oper.nat-saida-inter IN FRAME f-main
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN int-ds-tp-trib-natur-oper.nat-saida-inter-nao-contrib IN FRAME f-main
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN int-ds-tp-trib-natur-oper.uf-origem IN FRAME f-main
   NO-ENABLE 1 EXP-HELP                                                 */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK FRAME f-main
/* Query rebuild information for FRAME f-main
     _Options          = "NO-LOCK"
     _Query            is NOT OPENED
*/  /* FRAME f-main */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME int-ds-tp-trib-natur-oper.class-fiscal
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL int-ds-tp-trib-natur-oper.class-fiscal V-table-Win
ON F5 OF int-ds-tp-trib-natur-oper.class-fiscal IN FRAME f-main /* NCM */
OR MOUSE-SELECT-DBLCLICK OF int-ds-tp-trib-natur-oper.class-fiscal in frame {&FRAME-NAME} DO:
        {include/zoomvar.i &prog-zoom=inzoom/z01in046.w
                                &campo=int-ds-tp-trib-natur-oper.class-fiscal
                                &campozoom=class-fiscal}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL int-ds-tp-trib-natur-oper.class-fiscal V-table-Win
ON LEAVE OF int-ds-tp-trib-natur-oper.class-fiscal IN FRAME f-main /* NCM */
DO:
    cNCM:screen-value in frame {&frame-name} = "".
    for first classif-fisc 
        fields (class-fiscal descricao)
        no-lock where 
        classif-fisc.class-fiscal = input frame {&FRAME-NAME} int-ds-tp-trib-natur-oper.class-fiscal.
        display classif-fisc.descricao @ cNCM with frame {&FRAME-NAME}.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME int-ds-tp-trib-natur-oper.nat-entrada-est
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL int-ds-tp-trib-natur-oper.nat-entrada-est V-table-Win
ON F5 OF int-ds-tp-trib-natur-oper.nat-entrada-est IN FRAME f-main /* Nat. Estadual */
OR MOUSE-SELECT-DBLCLICK OF int-ds-tp-trib-natur-oper.nat-entrada-est in frame {&FRAME-NAME} DO:
        {include/zoomvar.i &prog-zoom=inzoom/z01in245.w
                                &campo=int-ds-tp-trib-natur-oper.nat-entrada-est
                                &campozoom=nat-operacao}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL int-ds-tp-trib-natur-oper.nat-entrada-est V-table-Win
ON LEAVE OF int-ds-tp-trib-natur-oper.nat-entrada-est IN FRAME f-main /* Nat. Estadual */
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
ON F5 OF int-ds-tp-trib-natur-oper.nat-entrada-est-nao-contrib IN FRAME f-main /* Nat. Estadual */
OR MOUSE-SELECT-DBLCLICK OF int-ds-tp-trib-natur-oper.nat-entrada-est-nao-contrib in frame {&FRAME-NAME} DO:
        {include/zoomvar.i &prog-zoom=inzoom/z01in245.w
                                &campo=int-ds-tp-trib-natur-oper.nat-entrada-est-nao-contrib
                                &campozoom=nat-operacao}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL int-ds-tp-trib-natur-oper.nat-entrada-est-nao-contrib V-table-Win
ON LEAVE OF int-ds-tp-trib-natur-oper.nat-entrada-est-nao-contrib IN FRAME f-main /* Nat. Estadual */
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
ON F5 OF int-ds-tp-trib-natur-oper.nat-entrada-inter IN FRAME f-main /* Nat. Interestadual */
OR MOUSE-SELECT-DBLCLICK OF int-ds-tp-trib-natur-oper.nat-entrada-inter in frame {&FRAME-NAME} DO:
        {include/zoomvar.i &prog-zoom=inzoom/z01in245.w
                                &campo=int-ds-tp-trib-natur-oper.nat-entrada-inter
                                &campozoom=nat-operacao}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL int-ds-tp-trib-natur-oper.nat-entrada-inter V-table-Win
ON LEAVE OF int-ds-tp-trib-natur-oper.nat-entrada-inter IN FRAME f-main /* Nat. Interestadual */
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
ON F5 OF int-ds-tp-trib-natur-oper.nat-entrada-inter-nao-contrib IN FRAME f-main /* Nat. Interestadual */
OR MOUSE-SELECT-DBLCLICK OF int-ds-tp-trib-natur-oper.nat-entrada-inter-nao-contrib in frame {&FRAME-NAME} DO:
        {include/zoomvar.i &prog-zoom=inzoom/z01in245.w
                                &campo=int-ds-tp-trib-natur-oper.nat-entrada-inter-nao-contrib
                                &campozoom=nat-operacao}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL int-ds-tp-trib-natur-oper.nat-entrada-inter-nao-contrib V-table-Win
ON LEAVE OF int-ds-tp-trib-natur-oper.nat-entrada-inter-nao-contrib IN FRAME f-main /* Nat. Interestadual */
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
ON F5 OF int-ds-tp-trib-natur-oper.nat-saida-est IN FRAME f-main /* Nat. Estadual */
OR MOUSE-SELECT-DBLCLICK OF int-ds-tp-trib-natur-oper.nat-saida-est in frame {&FRAME-NAME} DO:
        {include/zoomvar.i &prog-zoom=inzoom/z01in245.w
                                &campo=int-ds-tp-trib-natur-oper.nat-saida-est
                                &campozoom=nat-operacao}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL int-ds-tp-trib-natur-oper.nat-saida-est V-table-Win
ON LEAVE OF int-ds-tp-trib-natur-oper.nat-saida-est IN FRAME f-main /* Nat. Estadual */
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
ON F5 OF int-ds-tp-trib-natur-oper.nat-saida-est-nao-contrib IN FRAME f-main /* Nat. Estadual */
OR MOUSE-SELECT-DBLCLICK OF int-ds-tp-trib-natur-oper.nat-saida-est-nao-contrib in frame {&FRAME-NAME} DO:
        {include/zoomvar.i &prog-zoom=inzoom/z01in245.w
                                &campo=int-ds-tp-trib-natur-oper.nat-saida-est-nao-contrib
                                &campozoom=nat-operacao}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL int-ds-tp-trib-natur-oper.nat-saida-est-nao-contrib V-table-Win
ON LEAVE OF int-ds-tp-trib-natur-oper.nat-saida-est-nao-contrib IN FRAME f-main /* Nat. Estadual */
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
ON F5 OF int-ds-tp-trib-natur-oper.nat-saida-inter IN FRAME f-main /* Nat. Interestadual */
OR MOUSE-SELECT-DBLCLICK OF int-ds-tp-trib-natur-oper.nat-saida-inter in frame {&FRAME-NAME} DO:
        {include/zoomvar.i &prog-zoom=inzoom/z01in245.w
                                &campo=int-ds-tp-trib-natur-oper.nat-saida-inter
                                &campozoom=nat-operacao}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL int-ds-tp-trib-natur-oper.nat-saida-inter V-table-Win
ON LEAVE OF int-ds-tp-trib-natur-oper.nat-saida-inter IN FRAME f-main /* Nat. Interestadual */
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
ON F5 OF int-ds-tp-trib-natur-oper.nat-saida-inter-nao-contrib IN FRAME f-main /* Nat. Interestadual */
OR MOUSE-SELECT-DBLCLICK OF int-ds-tp-trib-natur-oper.nat-saida-inter-nao-contrib in frame {&FRAME-NAME} DO:
        {include/zoomvar.i &prog-zoom=inzoom/z01in245.w
                                &campo=int-ds-tp-trib-natur-oper.nat-saida-inter-nao-contrib
                                &campozoom=nat-operacao}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL int-ds-tp-trib-natur-oper.nat-saida-inter-nao-contrib V-table-Win
ON LEAVE OF int-ds-tp-trib-natur-oper.nat-saida-inter-nao-contrib IN FRAME f-main /* Nat. Interestadual */
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
  HIDE FRAME f-main.
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
    {include/i-valid.i}
    
    /*:T Ponha na pi-validate todas as validaá‰es */
    /*:T N∆o gravar nada no registro antes do dispatch do assign-record e 
       nem na PI-validate. */
    RUN pi-validate.
    if return-value = "ADM-ERROR":U then return "ADM-ERROR":U.
    /* Dispatch standard ADM method.                             */
    RUN dispatch IN THIS-PROCEDURE ( INPUT 'assign-record':U ) .
    if RETURN-VALUE = 'ADM-ERROR':U then 
        return 'ADM-ERROR':U.
    
    /*:T Todos os assignÔs n∆o feitos pelo assign-record devem ser feitos aqui */  
    /* Code placed here will execute AFTER standard behavior.    */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-create-record V-table-Win 
PROCEDURE local-create-record :
/*------------------------------------------------------------------------------
  Purpose:     Override standard ADM method
  Notes:       
------------------------------------------------------------------------------*/


  /* Code placed here will execute PRIOR to standard behavior. */

  /* Dispatch standard ADM method.                             */
  RUN dispatch IN THIS-PROCEDURE ( INPUT 'create-record':U ) .

  /* Code placed here will execute AFTER standard behavior.    */
  find int-ds-tipo-pedido where rowid(int-ds-tipo-pedido) = v-row-parent no-error.
  if available int-ds-tipo-pedido then do:
      assign int-ds-tp-trib-natur-oper.tp-pedido = int-ds-tipo-pedido.tp-pedido.
      assign int-ds-tp-trib-natur-oper.cd-trib-icm = cd-trib-icm:input-value in FRAME {&FRAME-NAME}.

      /*
       if cd-trib-icm:input-value in frame {&FRAME-NAME} = 0 then
           assign int-ds-tp-trib-natur-oper.class-fiscal = c-class-fiscal:screen-value in frame {&FRAME-NAME}.
           */
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-disable-fields V-table-Win 
PROCEDURE local-disable-fields :
/*------------------------------------------------------------------------------
  Purpose:     Override standard ADM method
  Notes:       
------------------------------------------------------------------------------*/
    
    /* Code placed here will execute PRIOR to standard behavior. */
    
    /* Dispatch standard ADM method.                             */
    RUN dispatch IN THIS-PROCEDURE ( INPUT 'disable-fields':U ) .
    
    /* Code placed here will execute AFTER standard behavior.    */
    &if  defined(ADM-MODIFY-FIELDS) &then
    disable {&ADM-MODIFY-FIELDS} with frame {&frame-name}.
    &endif
    
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-enable-fields V-table-Win 
PROCEDURE local-enable-fields :
/*------------------------------------------------------------------------------
  Purpose:     Override standard ADM method
  Notes:       
------------------------------------------------------------------------------*/
    
    /* Code placed here will execute PRIOR to standard behavior. */
    
    /* Dispatch standard ADM method.                             */
    RUN dispatch IN THIS-PROCEDURE ( INPUT 'enable-fields':U ) .
    
    /* Code placed here will execute AFTER standard behavior.    */
    &if  defined(ADM-MODIFY-FIELDS) &then
    if adm-new-record = yes then
        enable {&ADM-MODIFY-FIELDS} with frame {&frame-name}.
    &endif
    assign int-ds-tp-trib-natur-oper.class-fiscal:sensitive in FRAME {&FRAME-NAME} = no.
    if i-cd-trib-icm-115 = 0 then do:
        if ADM-NEW-RECORD then
            assign int-ds-tp-trib-natur-oper.class-fiscal:sensitive in FRAME {&FRAME-NAME} = yes.
    end.
    

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
  
  int-ds-tp-trib-natur-oper.class-fiscal:LOAD-MOUSE-POINTER("image/lupa.cur":U) IN FRAME f-Main.
  int-ds-tp-trib-natur-oper.class-fiscal:sensitive in FRAME {&FRAME-NAME} = no.
  assign int-ds-tp-trib-natur-oper.class-fiscal:sensitive in FRAME {&FRAME-NAME} = no.
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
  apply "LEAVE":U to int-ds-tp-trib-natur-oper.class-fiscal in frame {&FRAME-NAME}.

  /* Code placed here will execute AFTER standard behavior.    */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-atualiza-parent V-table-Win 
PROCEDURE pi-atualiza-parent :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    define input parameter v-row-parent-externo as rowid no-undo.
    
    assign v-row-parent = v-row-parent-externo.

    
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Pi-validate V-table-Win 
PROCEDURE Pi-validate :
/*:T------------------------------------------------------------------------------
  Purpose:Validar a viewer     
  Parameters:  <none>
  Notes: N∆o fazer assign aqui. Nesta procedure
  devem ser colocadas apenas validaá‰es, pois neste ponto do programa o registro 
  ainda n∆o foi criado.       
------------------------------------------------------------------------------*/
    {include/i-vldfrm.i} /*:T Validaá∆o de dicion†rio */
    
/*:T    Segue um exemplo de validaá∆o de programa */
/*       find tabela where tabela.campo1 = c-variavel and               */
/*                         tabela.campo2 > i-variavel no-lock no-error. */
      
      /*:T Este include deve ser colocado sempre antes do ut-msgs.p */
/*       {include/i-vldprg.i}                                             */
/*       run utp/ut-msgs.p (input "show":U, input 7, input return-value). */
/*       return 'ADM-ERROR':U.                                            */

  if int-ds-tp-trib-natur-oper.uf-origem:screen-value in frame {&FRAME-NAME} <> "" and
     not can-find(first unid-feder no-lock where
                  unid-feder.pais = "BR" and
                  unid-feder.estado = int-ds-tp-trib-natur-oper.uf-origem:screen-value in frame {&FRAME-NAME}) then do:
      run utp/ut-msgs.p(input "show",
                        input 17006,
                        input ("Unidade da federaá∆o inv†lida!" + "~~" + "Unidade da federaá∆o deve estar cadastrada ou ficar em branco.")).
      apply "entry":U to int-ds-tp-trib-natur-oper.uf-origem in frame {&FRAME-NAME}.
      return "ADM-ERROR".
  end.  

  if cd-trib-icm:input-value in frame {&FRAME-NAME} = 0 and 
     trim(int-ds-tp-trib-natur-oper.class-fiscal:screen-value in frame {&FRAME-NAME}) = "" 
  then do:
      run utp/ut-msgs.p(input "show",
                        input 17006,
                        input ("Classificaá∆o fiscal inv†lida!" + "~~" + "Classificaá∆o fiscal deve ser informada para tipo tributaá∆o Nenhum.")).
      apply "entry":U to int-ds-tp-trib-natur-oper.class-fiscal in frame {&FRAME-NAME}.
      return "ADM-ERROR".
  end.

  if cd-trib-icm:input-value in frame {&FRAME-NAME} = 0 and
     not can-find (first classif-fisc no-lock where 
                   classif-fisc.class-fiscal = int-ds-tp-trib-natur-oper.class-fiscal:input-value in frame {&FRAME-NAME}) 
  then do:
      run utp/ut-msgs.p(input "show",
                        input 17006,
                        input ("Classificaá∆o fiscal inv†lida!" + "~~" + "Classificaá∆o fiscal informada n∆o encontrada no cadastro.")).
      apply "entry":U to int-ds-tp-trib-natur-oper.class-fiscal in frame {&FRAME-NAME}.
      return "ADM-ERROR".
  end.

  if int-ds-tp-trib-natur-oper.nat-saida-est:screen-value in frame {&FRAME-NAME} = "" or
     not can-find(first natur-oper no-lock where natur-oper.nat-operacao = int-ds-tp-trib-natur-oper.nat-saida-est:screen-value in frame {&FRAME-NAME})
  then do:
      run utp/ut-msgs.p(input "show",
                        input 17006,
                        input ("Natureza de sa°da estadual inv†lida!" + "~~" + "Natureza de operaá∆o de sa°da deve estar cadastrada.")).
      apply "entry":U to int-ds-tp-trib-natur-oper.nat-saida-est in frame {&FRAME-NAME}.
      return "ADM-ERROR".
  end.

  if int-ds-tp-trib-natur-oper.nat-saida-inter:screen-value in frame {&FRAME-NAME} = "" or
     not can-find(first natur-oper no-lock where natur-oper.nat-operacao = int-ds-tp-trib-natur-oper.nat-saida-inter:screen-value in frame {&FRAME-NAME})
  then do:
      run utp/ut-msgs.p(input "show",
                        input 17006,
                        input ("Natureza de sa°da interestadual inv†lida!" + "~~" + "Natureza de operaá∆o de sa°da deve estar cadastrada.")).
      apply "entry":U to int-ds-tp-trib-natur-oper.nat-saida-inter in frame {&FRAME-NAME}.
      return "ADM-ERROR".
  end.

  if int-ds-tp-trib-natur-oper.nat-saida-est-nao-contrib:screen-value in frame {&FRAME-NAME} <> "" and
     not can-find(first natur-oper no-lock where natur-oper.nat-operacao = int-ds-tp-trib-natur-oper.nat-saida-est-nao-contrib:screen-value in frame {&FRAME-NAME})
  then do:
      run utp/ut-msgs.p(input "show",
                        input 17006,
                        input ("Natureza de sa°da estadual NAO contribuinte inv†lida!" + "~~" + "Natureza de operaá∆o de sa°da deve estar cadastrada.")).
      apply "entry":U to int-ds-tp-trib-natur-oper.nat-saida-est-nao-contrib in frame {&FRAME-NAME}.
      return "ADM-ERROR".
  end.

  if int-ds-tp-trib-natur-oper.nat-saida-inter-nao-contrib:screen-value in frame {&FRAME-NAME} <> "" and
     not can-find(first natur-oper no-lock where natur-oper.nat-operacao = int-ds-tp-trib-natur-oper.nat-saida-inter-nao-contrib:screen-value in frame {&FRAME-NAME})
  then do:
      run utp/ut-msgs.p(input "show",
                        input 17006,
                        input ("Natureza de sa°da interestadual NAO contribuinte inv†lida!" + "~~" + "Natureza de operaá∆o de sa°da deve estar cadastrada.")).
      apply "entry":U to int-ds-tp-trib-natur-oper.nat-saida-inter-nao-contrib in frame {&FRAME-NAME}.
      return "ADM-ERROR".
  end.


  if int-ds-tp-trib-natur-oper.nat-entrada-est:screen-value in frame {&FRAME-NAME} <> "" AND
     not can-find(first natur-oper no-lock where natur-oper.nat-operacao = int-ds-tp-trib-natur-oper.nat-entrada-est:screen-value in frame {&FRAME-NAME})
  then do:
      run utp/ut-msgs.p(input "show",
                        input 17006,
                        input ("Natureza de entrada estadual inv†lida!" + "~~" + "Natureza de operaá∆o de entrada deve estar cadastrada.")).
      apply "entry":U to int-ds-tp-trib-natur-oper.nat-entrada-est in frame {&FRAME-NAME}.
      return "ADM-ERROR".
  end.
  
  if int-ds-tp-trib-natur-oper.nat-entrada-inter:screen-value in frame {&FRAME-NAME} <> "" AND
     not can-find(first natur-oper no-lock where natur-oper.nat-operacao = int-ds-tp-trib-natur-oper.nat-entrada-inter:screen-value in frame {&FRAME-NAME})
  then do:
      run utp/ut-msgs.p(input "show",
                        input 17006,
                        input ("Natureza de entrada interestadual inv†lida!" + "~~" + "Natureza de operaá∆o de entrada deve estar cadastrada.")).
      apply "entry":U to int-ds-tp-trib-natur-oper.nat-entrada-inter in frame {&FRAME-NAME}.
      return "ADM-ERROR".
  end.

  if int-ds-tp-trib-natur-oper.nat-entrada-est-nao-contrib:screen-value in frame {&FRAME-NAME} <> "" AND
     not can-find(first natur-oper no-lock where natur-oper.nat-operacao = int-ds-tp-trib-natur-oper.nat-entrada-est-nao-contrib:screen-value in frame {&FRAME-NAME})
  then do:
      run utp/ut-msgs.p(input "show",
                        input 17006,
                        input ("Natureza de entrada estadual NAO contriubuinte inv†lida!" + "~~" + "Natureza de operaá∆o de entrada deve estar cadastrada.")).
      apply "entry":U to int-ds-tp-trib-natur-oper.nat-entrada-est-nao-contrib in frame {&FRAME-NAME}.
      return "ADM-ERROR".
  end.
  
  if int-ds-tp-trib-natur-oper.nat-entrada-inter-nao-contrib:screen-value in frame {&FRAME-NAME} <> "" AND
     not can-find(first natur-oper no-lock where natur-oper.nat-operacao = int-ds-tp-trib-natur-oper.nat-entrada-inter-nao-contrib:screen-value in frame {&FRAME-NAME})
  then do:
      run utp/ut-msgs.p(input "show",
                        input 17006,
                        input ("Natureza de entrada interestadual NAO contriubuinte inv†lida!" + "~~" + "Natureza de operaá∆o de entrada deve estar cadastrada.")).
      apply "entry":U to int-ds-tp-trib-natur-oper.nat-entrada-inter-nao-contrib in frame {&FRAME-NAME}.
      return "ADM-ERROR".
  end.

  
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
  run pi-trata-state (p-issuer-hdl, p-state).
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

