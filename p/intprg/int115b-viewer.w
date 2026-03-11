&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI ADM1
&ANALYZE-RESUME
/* Connected Databases 
          custom           PROGRESS
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
&Scoped-define EXTERNAL-TABLES int_ds_tp_trib_natur_oper
&Scoped-define FIRST-EXTERNAL-TABLE int_ds_tp_trib_natur_oper


/* Need to scope the external tables to this procedure                  */
DEFINE QUERY external_tables FOR int_ds_tp_trib_natur_oper.
/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS int_ds_tp_trib_natur_oper.uf_origem ~
int_ds_tp_trib_natur_oper.class_fiscal ~
int_ds_tp_trib_natur_oper.nat_saida_est ~
int_ds_tp_trib_natur_oper.nat_saida_inter ~
int_ds_tp_trib_natur_oper.nat_saida_sem_reg ~
int_ds_tp_trib_natur_oper.nat_saida_inter_sem_reg ~
int_ds_tp_trib_natur_oper.nat_entrada_est ~
int_ds_tp_trib_natur_oper.nat_entrada_inter ~
int_ds_tp_trib_natur_oper.nat_saida_est_nao_contrib ~
int_ds_tp_trib_natur_oper.nat_saida_inter_nao_contrib ~
int_ds_tp_trib_natur_oper.nat_entrada_est_nao_contrib ~
int_ds_tp_trib_natur_oper.nat_entrada_inter_nao_contrib 
&Scoped-define ENABLED-TABLES int_ds_tp_trib_natur_oper
&Scoped-define FIRST-ENABLED-TABLE int_ds_tp_trib_natur_oper
&Scoped-Define ENABLED-OBJECTS RECT-19 RECT-22 RECT-24 RECT-23 RECT-25 
&Scoped-Define DISPLAYED-FIELDS int_ds_tp_trib_natur_oper.uf_origem ~
int_ds_tp_trib_natur_oper.class_fiscal ~
int_ds_tp_trib_natur_oper.nat_saida_est ~
int_ds_tp_trib_natur_oper.nat_saida_inter ~
int_ds_tp_trib_natur_oper.nat_saida_sem_reg ~
int_ds_tp_trib_natur_oper.nat_saida_inter_sem_reg ~
int_ds_tp_trib_natur_oper.nat_entrada_est ~
int_ds_tp_trib_natur_oper.nat_entrada_inter ~
int_ds_tp_trib_natur_oper.nat_saida_est_nao_contrib ~
int_ds_tp_trib_natur_oper.nat_saida_inter_nao_contrib ~
int_ds_tp_trib_natur_oper.nat_entrada_est_nao_contrib ~
int_ds_tp_trib_natur_oper.nat_entrada_inter_nao_contrib 
&Scoped-define DISPLAYED-TABLES int_ds_tp_trib_natur_oper
&Scoped-define FIRST-DISPLAYED-TABLE int_ds_tp_trib_natur_oper
&Scoped-Define DISPLAYED-OBJECTS tp_pedido cd-trib-icm cNCM cNatSaiEst ~
cNatSaiInter c-nat-est-s-reg c-nat-interest-s-reg cNatEntEst cNatEntInter ~
cNatSaiEstNAO cNatSaiInterNAO cNatEntEstNAO cNatEntInterNAO 

/* Custom List Definitions                                              */
/* ADM-CREATE-FIELDS,ADM-ASSIGN-FIELDS,ADM-MODIFY-FIELDS,List-4,List-5,List-6 */

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
DEFINE VARIABLE tp_pedido AS CHARACTER FORMAT "X(2)" 
     LABEL "Tipo Pedido" 
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
     SIZE 72 BY 1.

DEFINE VARIABLE c-nat-est-s-reg AS CHARACTER FORMAT "X(100)":U 
     VIEW-AS FILL-IN 
     SIZE 60.86 BY .88 NO-UNDO.

DEFINE VARIABLE c-nat-interest-s-reg AS CHARACTER FORMAT "X(100)":U 
     VIEW-AS FILL-IN 
     SIZE 60.86 BY .88 NO-UNDO.

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

DEFINE VARIABLE cd-trib-icm AS INTEGER 
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS 
          "Tributado":U, 1,
"Isento":U, 2,
"Cesta B†sica":U, 3,
"ST":U, 9,
"Outros":U, 4,
"Nenhum":U, 0
     SIZE 62 BY .75.

DEFINE RECTANGLE RECT-19
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 91 BY 5.

DEFINE RECTANGLE RECT-22
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 91 BY 8.5.

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

DEFINE FRAME f-main
     tp_pedido AT ROW 1.75 COL 17 COLON-ALIGNED WIDGET-ID 110
     cd-trib-icm AT ROW 3 COL 19.29 HELP
          "C¢digo de tributaá∆o do ICMS" NO-LABEL WIDGET-ID 148
     int_ds_tp_trib_natur_oper.uf_origem AT ROW 4 COL 17 COLON-ALIGNED WIDGET-ID 188
          VIEW-AS FILL-IN 
          SIZE 4 BY .88
     int_ds_tp_trib_natur_oper.class_fiscal AT ROW 5 COL 18.72 COLON-ALIGNED WIDGET-ID 198
          VIEW-AS FILL-IN 
          SIZE 11.14 BY .88
     cNCM AT ROW 5 COL 28 COLON-ALIGNED NO-LABEL WIDGET-ID 196
     int_ds_tp_trib_natur_oper.nat_saida_est AT ROW 8.71 COL 17 COLON-ALIGNED WIDGET-ID 158
          LABEL "Nat. Estadual"
          VIEW-AS FILL-IN 
          SIZE 10 BY .88
     cNatSaiEst AT ROW 8.71 COL 27 COLON-ALIGNED NO-LABEL WIDGET-ID 192
     int_ds_tp_trib_natur_oper.nat_saida_inter AT ROW 9.71 COL 17 COLON-ALIGNED WIDGET-ID 160
          LABEL "Nat. Interestadual"
          VIEW-AS FILL-IN 
          SIZE 10 BY .88
     cNatSaiInter AT ROW 9.71 COL 27 COLON-ALIGNED NO-LABEL WIDGET-ID 138
     int_ds_tp_trib_natur_oper.nat_saida_sem_reg AT ROW 12.33 COL 17 COLON-ALIGNED WIDGET-ID 204
          LABEL "Nat. Estadual"
          VIEW-AS FILL-IN 
          SIZE 10 BY .88
     c-nat-est-s-reg AT ROW 12.33 COL 27 COLON-ALIGNED NO-LABEL WIDGET-ID 206
     int_ds_tp_trib_natur_oper.nat_saida_inter_sem_reg AT ROW 13.42 COL 17 COLON-ALIGNED WIDGET-ID 210
          LABEL "Nat. InterEstadual"
          VIEW-AS FILL-IN 
          SIZE 10 BY .88
     c-nat-interest-s-reg AT ROW 13.42 COL 27 COLON-ALIGNED NO-LABEL WIDGET-ID 208
     int_ds_tp_trib_natur_oper.nat_entrada_est AT ROW 17 COL 17 COLON-ALIGNED WIDGET-ID 154
          LABEL "Nat. Estadual"
          VIEW-AS FILL-IN 
          SIZE 10 BY .88
     cNatEntEst AT ROW 17 COL 27 COLON-ALIGNED NO-LABEL WIDGET-ID 142
     int_ds_tp_trib_natur_oper.nat_entrada_inter AT ROW 18 COL 17 COLON-ALIGNED WIDGET-ID 156
          LABEL "Nat. Interestadual"
          VIEW-AS FILL-IN 
          SIZE 10 BY .88
     cNatEntInter AT ROW 18 COL 27 COLON-ALIGNED NO-LABEL WIDGET-ID 140
     int_ds_tp_trib_natur_oper.nat_saida_est_nao_contrib AT ROW 20.75 COL 17 COLON-ALIGNED WIDGET-ID 180
          LABEL "Nat. Estadual"
          VIEW-AS FILL-IN 
          SIZE 10 BY .88
     cNatSaiEstNAO AT ROW 20.75 COL 27 COLON-ALIGNED NO-LABEL WIDGET-ID 168
     int_ds_tp_trib_natur_oper.nat_saida_inter_nao_contrib AT ROW 21.75 COL 17 COLON-ALIGNED WIDGET-ID 182
          LABEL "Nat. Interestadual"
          VIEW-AS FILL-IN 
          SIZE 10 BY .88
     cNatSaiInterNAO AT ROW 21.75 COL 27 COLON-ALIGNED NO-LABEL WIDGET-ID 170
     int_ds_tp_trib_natur_oper.nat_entrada_est_nao_contrib AT ROW 24.5 COL 17 COLON-ALIGNED WIDGET-ID 184
          LABEL "Nat. Estadual"
          VIEW-AS FILL-IN 
          SIZE 10 BY .88
     cNatEntEstNAO AT ROW 24.5 COL 27 COLON-ALIGNED NO-LABEL WIDGET-ID 164
     int_ds_tp_trib_natur_oper.nat_entrada_inter_nao_contrib AT ROW 25.5 COL 17 COLON-ALIGNED WIDGET-ID 186
          LABEL "Nat. Interestadual"
          VIEW-AS FILL-IN 
          SIZE 10 BY .88
     cNatEntInterNAO AT ROW 25.5 COL 27 COLON-ALIGNED NO-LABEL WIDGET-ID 166
     "Entradas p/ Contribuinte" VIEW-AS TEXT
          SIZE 21 BY .67 AT ROW 15.75 COL 4 WIDGET-ID 146
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1 SCROLLABLE  WIDGET-ID 100.

/* DEFINE FRAME statement is approaching 4K Bytes.  Breaking it up   */
DEFINE FRAME f-main
     "Sa°das p/ Contribuinte" VIEW-AS TEXT
          SIZE 20 BY .67 AT ROW 6.5 COL 4 WIDGET-ID 120
     "Sa°das NAO Contribuinte" VIEW-AS TEXT
          SIZE 22 BY .67 AT ROW 19.5 COL 4 WIDGET-ID 176
     "Entradas NAO Contribuinte" VIEW-AS TEXT
          SIZE 23 BY .67 AT ROW 23.25 COL 4 WIDGET-ID 178
     "Operaá∆o" VIEW-AS TEXT
          SIZE 9 BY .67 AT ROW 1 COL 4 WIDGET-ID 40
     "ST - Sem regime especial" VIEW-AS TEXT
          SIZE 30 BY .67 AT ROW 11.21 COL 14 WIDGET-ID 202
     "Tributaá∆o ICMS:" VIEW-AS TEXT
          SIZE 15 BY .67 AT ROW 2.96 COL 3.86 WIDGET-ID 162
     "ST - Regime Especial" VIEW-AS TEXT
          SIZE 24 BY .67 AT ROW 7.5 COL 14 WIDGET-ID 200
     RECT-19 AT ROW 1.25 COL 2 WIDGET-ID 12
     RECT-22 AT ROW 6.75 COL 2 WIDGET-ID 118
     RECT-24 AT ROW 16 COL 2 WIDGET-ID 144
     RECT-23 AT ROW 19.75 COL 2 WIDGET-ID 172
     RECT-25 AT ROW 23.5 COL 2 WIDGET-ID 174
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1 SCROLLABLE  WIDGET-ID 100.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: SmartViewer
   External Tables: custom.int_ds_tp_trib_natur_oper
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
         HEIGHT             = 26.08
         WIDTH              = 93.86.
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

/* SETTINGS FOR FILL-IN c-nat-est-s-reg IN FRAME f-main
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN c-nat-interest-s-reg IN FRAME f-main
   NO-ENABLE                                                            */
/* SETTINGS FOR RADIO-SET cd-trib-icm IN FRAME f-main
   NO-ENABLE                                                            */
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
/* SETTINGS FOR FILL-IN int_ds_tp_trib_natur_oper.nat_entrada_est IN FRAME f-main
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN int_ds_tp_trib_natur_oper.nat_entrada_est_nao_contrib IN FRAME f-main
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN int_ds_tp_trib_natur_oper.nat_entrada_inter IN FRAME f-main
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN int_ds_tp_trib_natur_oper.nat_entrada_inter_nao_contrib IN FRAME f-main
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN int_ds_tp_trib_natur_oper.nat_saida_est IN FRAME f-main
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN int_ds_tp_trib_natur_oper.nat_saida_est_nao_contrib IN FRAME f-main
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN int_ds_tp_trib_natur_oper.nat_saida_inter IN FRAME f-main
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN int_ds_tp_trib_natur_oper.nat_saida_inter_nao_contrib IN FRAME f-main
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN int_ds_tp_trib_natur_oper.nat_saida_inter_sem_reg IN FRAME f-main
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN int_ds_tp_trib_natur_oper.nat_saida_sem_reg IN FRAME f-main
   EXP-LABEL                                                            */
/* SETTINGS FOR COMBO-BOX tp_pedido IN FRAME f-main
   NO-ENABLE                                                            */
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

&Scoped-define SELF-NAME int_ds_tp_trib_natur_oper.class_fiscal
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL int_ds_tp_trib_natur_oper.class_fiscal V-table-Win
ON F5 OF int_ds_tp_trib_natur_oper.class_fiscal IN FRAME f-main /* Classificaá∆o Fiscal */
OR MOUSE-SELECT-DBLCLICK OF int_ds_tp_trib_natur_oper.class_fiscal in frame {&FRAME-NAME} DO:
        {include/zoomvar.i &prog-zoom=inzoom/z01in046.w
                                &campo=int_ds_tp_trib_natur_oper.class_fiscal
                                &campozoom=class-fiscal}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL int_ds_tp_trib_natur_oper.class_fiscal V-table-Win
ON LEAVE OF int_ds_tp_trib_natur_oper.class_fiscal IN FRAME f-main /* Classificaá∆o Fiscal */
DO:
    cNCM:screen-value in frame {&frame-name} = "".
    for first classif-fisc 
        fields (class-fiscal descricao)
        no-lock where 
        classif-fisc.class-fiscal = input frame {&FRAME-NAME} int_ds_tp_trib_natur_oper.class_fiscal.
        display classif-fisc.descricao @ cNCM with frame {&FRAME-NAME}.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME int_ds_tp_trib_natur_oper.nat_entrada_est
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL int_ds_tp_trib_natur_oper.nat_entrada_est V-table-Win
ON F5 OF int_ds_tp_trib_natur_oper.nat_entrada_est IN FRAME f-main /* Nat. Estadual */
OR MOUSE-SELECT-DBLCLICK OF int_ds_tp_trib_natur_oper.nat_entrada_est in frame {&FRAME-NAME} DO:
        {include/zoomvar.i &prog-zoom=inzoom/z01in245.w
                                &campo=int_ds_tp_trib_natur_oper.nat_entrada_est
                                &campozoom=nat-operacao}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL int_ds_tp_trib_natur_oper.nat_entrada_est V-table-Win
ON LEAVE OF int_ds_tp_trib_natur_oper.nat_entrada_est IN FRAME f-main /* Nat. Estadual */
DO:
    cNatEntEst:screen-value in frame {&frame-name} = "".
    for first mgind.natur-oper 
        fields (nat-operacao denominacao)
        no-lock where
        mgind.natur-oper.nat-operacao = input frame {&FRAME-NAME} int_ds_tp_trib_natur_oper.nat_entrada_est.
        display natur-oper.denominacao @ cNatEntEst with frame {&FRAME-NAME}.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME int_ds_tp_trib_natur_oper.nat_entrada_est_nao_contrib
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL int_ds_tp_trib_natur_oper.nat_entrada_est_nao_contrib V-table-Win
ON F5 OF int_ds_tp_trib_natur_oper.nat_entrada_est_nao_contrib IN FRAME f-main /* Nat. Estadual */
OR MOUSE-SELECT-DBLCLICK OF int_ds_tp_trib_natur_oper.nat_entrada_est_nao_contrib in frame {&FRAME-NAME} DO:
        {include/zoomvar.i &prog-zoom=inzoom/z01in245.w
                                &campo=int_ds_tp_trib_natur_oper.nat_entrada_est_nao_contrib
                                &campozoom=nat-operacao}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL int_ds_tp_trib_natur_oper.nat_entrada_est_nao_contrib V-table-Win
ON LEAVE OF int_ds_tp_trib_natur_oper.nat_entrada_est_nao_contrib IN FRAME f-main /* Nat. Estadual */
DO:
    cNatEntEstNAO:screen-value in frame {&frame-name} = "".
    for first mgind.natur-oper 
        fields (nat-operacao denominacao)
        no-lock where
        mgind.natur-oper.nat-operacao = input frame {&FRAME-NAME} int_ds_tp_trib_natur_oper.nat_entrada_est_nao_contrib.
        display natur-oper.denominacao @ cNatEntEstNAO with frame {&FRAME-NAME}.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME int_ds_tp_trib_natur_oper.nat_entrada_inter
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL int_ds_tp_trib_natur_oper.nat_entrada_inter V-table-Win
ON F5 OF int_ds_tp_trib_natur_oper.nat_entrada_inter IN FRAME f-main /* Nat. Interestadual */
OR MOUSE-SELECT-DBLCLICK OF int_ds_tp_trib_natur_oper.nat_entrada_inter in frame {&FRAME-NAME} DO:
        {include/zoomvar.i &prog-zoom=inzoom/z01in245.w
                                &campo=int_ds_tp_trib_natur_oper.nat_entrada_inter
                                &campozoom=nat-operacao}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL int_ds_tp_trib_natur_oper.nat_entrada_inter V-table-Win
ON LEAVE OF int_ds_tp_trib_natur_oper.nat_entrada_inter IN FRAME f-main /* Nat. Interestadual */
DO:
    cNatEntInter:screen-value in frame {&frame-name} = "".
    for first mgind.natur-oper 
        fields (nat-operacao denominacao)
        no-lock where
        mgind.natur-oper.nat-operacao = input frame {&FRAME-NAME} int_ds_tp_trib_natur_oper.nat_entrada_inter.
        display natur-oper.denominacao @ cNatEntInter with frame {&FRAME-NAME}.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME int_ds_tp_trib_natur_oper.nat_entrada_inter_nao_contrib
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL int_ds_tp_trib_natur_oper.nat_entrada_inter_nao_contrib V-table-Win
ON F5 OF int_ds_tp_trib_natur_oper.nat_entrada_inter_nao_contrib IN FRAME f-main /* Nat. Interestadual */
OR MOUSE-SELECT-DBLCLICK OF int_ds_tp_trib_natur_oper.nat_entrada_inter_nao_contrib in frame {&FRAME-NAME} DO:
        {include/zoomvar.i &prog-zoom=inzoom/z01in245.w
                                &campo=int_ds_tp_trib_natur_oper.nat_entrada_inter_nao_contrib
                                &campozoom=nat-operacao}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL int_ds_tp_trib_natur_oper.nat_entrada_inter_nao_contrib V-table-Win
ON LEAVE OF int_ds_tp_trib_natur_oper.nat_entrada_inter_nao_contrib IN FRAME f-main /* Nat. Interestadual */
DO:
    cNatEntInterNAO:screen-value in frame {&frame-name} = "".
    for first mgind.natur-oper 
        fields (nat-operacao denominacao)
        no-lock where
        mgind.natur-oper.nat-operacao = input frame {&FRAME-NAME} int_ds_tp_trib_natur_oper.nat_entrada_inter_nao_contrib.
        display natur-oper.denominacao @ cNatEntInterNAO with frame {&FRAME-NAME}.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME int_ds_tp_trib_natur_oper.nat_saida_est
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL int_ds_tp_trib_natur_oper.nat_saida_est V-table-Win
ON F5 OF int_ds_tp_trib_natur_oper.nat_saida_est IN FRAME f-main /* Nat. Estadual */
OR MOUSE-SELECT-DBLCLICK OF int_ds_tp_trib_natur_oper.nat_saida_est in frame {&FRAME-NAME} DO:
        {include/zoomvar.i &prog-zoom=inzoom/z01in245.w
                                &campo=int_ds_tp_trib_natur_oper.nat_saida_est
                                &campozoom=nat-operacao}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL int_ds_tp_trib_natur_oper.nat_saida_est V-table-Win
ON LEAVE OF int_ds_tp_trib_natur_oper.nat_saida_est IN FRAME f-main /* Nat. Estadual */
DO:
    cNatSaiEst:screen-value in frame {&frame-name} = "".
    for first mgind.natur-oper 
        fields (nat-operacao denominacao)
        no-lock where
        mgind.natur-oper.nat-operacao = input frame {&FRAME-NAME} int_ds_tp_trib_natur_oper.nat_saida_est.
        display natur-oper.denominacao @ cNatSaiEst with frame {&FRAME-NAME}.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME int_ds_tp_trib_natur_oper.nat_saida_est_nao_contrib
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL int_ds_tp_trib_natur_oper.nat_saida_est_nao_contrib V-table-Win
ON F5 OF int_ds_tp_trib_natur_oper.nat_saida_est_nao_contrib IN FRAME f-main /* Nat. Estadual */
OR MOUSE-SELECT-DBLCLICK OF int_ds_tp_trib_natur_oper.nat_saida_est_nao_contrib in frame {&FRAME-NAME} DO:
        {include/zoomvar.i &prog-zoom=inzoom/z01in245.w
                                &campo=int_ds_tp_trib_natur_oper.nat_saida_est_nao_contrib
                                &campozoom=nat-operacao}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL int_ds_tp_trib_natur_oper.nat_saida_est_nao_contrib V-table-Win
ON LEAVE OF int_ds_tp_trib_natur_oper.nat_saida_est_nao_contrib IN FRAME f-main /* Nat. Estadual */
DO:
    cNatSaiEstNAO:screen-value in frame {&frame-name} = "".
    for first mgind.natur-oper 
        fields (nat-operacao denominacao)
        no-lock where
        mgind.natur-oper.nat-operacao = input frame {&FRAME-NAME} int_ds_tp_trib_natur_oper.nat_saida_est_nao_contrib.
        display natur-oper.denominacao @ cNatSaiEstNAO with frame {&FRAME-NAME}.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME int_ds_tp_trib_natur_oper.nat_saida_inter
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL int_ds_tp_trib_natur_oper.nat_saida_inter V-table-Win
ON F5 OF int_ds_tp_trib_natur_oper.nat_saida_inter IN FRAME f-main /* Nat. Interestadual */
OR MOUSE-SELECT-DBLCLICK OF int_ds_tp_trib_natur_oper.nat_saida_inter in frame {&FRAME-NAME} DO:
        {include/zoomvar.i &prog-zoom=inzoom/z01in245.w
                                &campo=int_ds_tp_trib_natur_oper.nat_saida_inter
                                &campozoom=nat-operacao}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL int_ds_tp_trib_natur_oper.nat_saida_inter V-table-Win
ON LEAVE OF int_ds_tp_trib_natur_oper.nat_saida_inter IN FRAME f-main /* Nat. Interestadual */
DO:
    cNatSaiInter:screen-value in frame {&frame-name} = "".
    for first mgind.natur-oper 
        fields (nat-operacao denominacao)
        no-lock where
        mgind.natur-oper.nat-operacao = input frame {&FRAME-NAME} int_ds_tp_trib_natur_oper.nat_saida_inter.
        display natur-oper.denominacao @ cNatSaiInter with frame {&FRAME-NAME}.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME int_ds_tp_trib_natur_oper.nat_saida_inter_nao_contrib
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL int_ds_tp_trib_natur_oper.nat_saida_inter_nao_contrib V-table-Win
ON F5 OF int_ds_tp_trib_natur_oper.nat_saida_inter_nao_contrib IN FRAME f-main /* Nat. Interestadual */
OR MOUSE-SELECT-DBLCLICK OF int_ds_tp_trib_natur_oper.nat_saida_inter_nao_contrib in frame {&FRAME-NAME} DO:
        {include/zoomvar.i &prog-zoom=inzoom/z01in245.w
                                &campo=int_ds_tp_trib_natur_oper.nat_saida_inter_nao_contrib
                                &campozoom=nat-operacao}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL int_ds_tp_trib_natur_oper.nat_saida_inter_nao_contrib V-table-Win
ON LEAVE OF int_ds_tp_trib_natur_oper.nat_saida_inter_nao_contrib IN FRAME f-main /* Nat. Interestadual */
DO:
    cNatSaiInterNAO:screen-value in frame {&frame-name} = "".
    for first mgind.natur-oper 
        fields (nat-operacao denominacao)
        no-lock where
        mgind.natur-oper.nat-operacao = input frame {&FRAME-NAME} int_ds_tp_trib_natur_oper.nat_saida_inter_nao_contrib.
        display natur-oper.denominacao @ cNatSaiInterNAO with frame {&FRAME-NAME}.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME int_ds_tp_trib_natur_oper.nat_saida_inter_sem_reg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL int_ds_tp_trib_natur_oper.nat_saida_inter_sem_reg V-table-Win
ON F5 OF int_ds_tp_trib_natur_oper.nat_saida_inter_sem_reg IN FRAME f-main /* Nat. InterEstadual */
OR MOUSE-SELECT-DBLCLICK OF int_ds_tp_trib_natur_oper.nat_saida_inter_sem_reg in frame {&FRAME-NAME} DO:
        {include/zoomvar.i &prog-zoom=inzoom/z01in245.w
                                &campo=int_ds_tp_trib_natur_oper.nat_saida_inter_sem_reg
                                &campozoom=nat-operacao}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL int_ds_tp_trib_natur_oper.nat_saida_inter_sem_reg V-table-Win
ON LEAVE OF int_ds_tp_trib_natur_oper.nat_saida_inter_sem_reg IN FRAME f-main /* Nat. InterEstadual */
DO:
    c-nat-interest-s-reg:screen-value in frame {&frame-name} = "".
    for first mgind.natur-oper 
        fields (nat-operacao denominacao)
        no-lock where
        mgind.natur-oper.nat-operacao = input frame {&FRAME-NAME} int_ds_tp_trib_natur_oper.nat_saida_inter_sem_reg.
        display natur-oper.denominacao @ c-nat-interest-s-reg with frame {&FRAME-NAME}.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME int_ds_tp_trib_natur_oper.nat_saida_sem_reg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL int_ds_tp_trib_natur_oper.nat_saida_sem_reg V-table-Win
ON F5 OF int_ds_tp_trib_natur_oper.nat_saida_sem_reg IN FRAME f-main /* Nat. Estadual */
OR MOUSE-SELECT-DBLCLICK OF int_ds_tp_trib_natur_oper.nat_saida_sem_reg in frame {&FRAME-NAME} DO:
        {include/zoomvar.i &prog-zoom=inzoom/z01in245.w
                                &campo=int_ds_tp_trib_natur_oper.nat_saida_sem_reg
                                &campozoom=nat-operacao}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL int_ds_tp_trib_natur_oper.nat_saida_sem_reg V-table-Win
ON LEAVE OF int_ds_tp_trib_natur_oper.nat_saida_sem_reg IN FRAME f-main /* Nat. Estadual */
DO:
    c-nat-est-s-reg:screen-value in frame {&frame-name} = "".
    for first mgind.natur-oper 
        fields (nat-operacao denominacao)
        no-lock where
        mgind.natur-oper.nat-operacao = input frame {&FRAME-NAME} int_ds_tp_trib_natur_oper.nat_saida_sem_reg.
        display natur-oper.denominacao @ c-nat-est-s-reg with frame {&FRAME-NAME}.
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
  {src/adm/template/row-list.i "int_ds_tp_trib_natur_oper"}

  /* Get the record ROWID's from the RECORD-SOURCE.                  */
  {src/adm/template/row-get.i}

  /* FIND each record specified by the RECORD-SOURCE.                */
  {src/adm/template/row-find.i "int_ds_tp_trib_natur_oper"}

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
  find int_ds_tipo_pedido where rowid(int_ds_tipo_pedido) = v-row-parent no-error.
  if available int_ds_tipo_pedido then do:
      assign int_ds_tp_trib_natur_oper.tp_pedido = int_ds_tipo_pedido.tp_pedido.
      assign int_ds_tp_trib_natur_oper.cd_trib_icm = cd-trib-icm:input-value in FRAME {&FRAME-NAME}.

      /*
       if cd-trib-icm:input-value in frame {&FRAME-NAME} = 0 then
           assign int_ds_tp_trib_natur_oper.class-fiscal = c-class-fiscal:screen-value in frame {&FRAME-NAME}.
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
    assign int_ds_tp_trib_natur_oper.class_fiscal:sensitive in FRAME {&FRAME-NAME} = no.
    if i-cd-trib-icm-115 = 0 then do:
        if ADM-NEW-RECORD then
            assign int_ds_tp_trib_natur_oper.class_fiscal:sensitive in FRAME {&FRAME-NAME} = yes.
    end.

    IF cd-trib-icm:input-value in FRAME {&FRAME-NAME} = 9 THEN DO:

        assign int_ds_tp_trib_natur_oper.nat_saida_sem_reg:sensitive in FRAME {&FRAME-NAME} = YES
               int_ds_tp_trib_natur_oper.nat_saida_inter_sem_reg:sensitive in FRAME {&FRAME-NAME} = YES.
    END.
    ELSE DO:

assign int_ds_tp_trib_natur_oper.nat_saida_sem_reg:sensitive in FRAME {&FRAME-NAME} = NO
               int_ds_tp_trib_natur_oper.nat_saida_inter_sem_reg:sensitive in FRAME {&FRAME-NAME} = NO.

    END.

    

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
  
  int_ds_tp_trib_natur_oper.nat_saida_est   :LOAD-MOUSE-POINTER("image/lupa.cur":U) IN FRAME f-Main.
  int_ds_tp_trib_natur_oper.nat_saida_inter :LOAD-MOUSE-POINTER("image/lupa.cur":U) IN FRAME f-Main.
  int_ds_tp_trib_natur_oper.nat_entrada_est :LOAD-MOUSE-POINTER("image/lupa.cur":U) IN FRAME f-Main.
  int_ds_tp_trib_natur_oper.nat_entrada_inter :LOAD-MOUSE-POINTER("image/lupa.cur":U) IN FRAME f-Main.
  int_ds_tp_trib_natur_oper.nat_saida_est_nao_contrib :LOAD-MOUSE-POINTER("image/lupa.cur":U) IN FRAME f-Main.
  int_ds_tp_trib_natur_oper.nat_saida_inter_nao_contrib :LOAD-MOUSE-POINTER("image/lupa.cur":U) IN FRAME f-Main.
  int_ds_tp_trib_natur_oper.nat_entrada_est_nao_contrib :LOAD-MOUSE-POINTER("image/lupa.cur":U) IN FRAME f-Main.
  int_ds_tp_trib_natur_oper.nat_entrada_inter_nao_contrib :LOAD-MOUSE-POINTER("image/lupa.cur":U) IN FRAME f-Main.
  int_ds_tp_trib_natur_oper.nat_saida_sem_reg   :LOAD-MOUSE-POINTER("image/lupa.cur":U) IN FRAME f-Main.
  int_ds_tp_trib_natur_oper.nat_saida_inter_sem_reg   :LOAD-MOUSE-POINTER("image/lupa.cur":U) IN FRAME f-Main.
  
  int_ds_tp_trib_natur_oper.class_fiscal:LOAD-MOUSE-POINTER("image/lupa.cur":U) IN FRAME f-Main.
  int_ds_tp_trib_natur_oper.class_fiscal:sensitive in FRAME {&FRAME-NAME} = no.

  assign cd-trib-icm:screen-value in FRAME {&FRAME-NAME} = string(i-cd-trib-icm-115).

  assign int_ds_tp_trib_natur_oper.class_fiscal:sensitive in FRAME {&FRAME-NAME} = no.
  if i-cd-trib-icm-115 = 0 then do:
      assign cd-trib-icm:screen-value in FRAME {&FRAME-NAME} = "0".
      /*assign c-class-fiscal:screen-value in FRAME {&FRAME-NAME} = "00000000".*/
      if ADM-NEW-RECORD then
          assign int_ds_tp_trib_natur_oper.class_fiscal:sensitive in FRAME {&FRAME-NAME} = yes.
  end.
  assign tp_pedido:list-item-pairs in FRAME {&FRAME-NAME} = "0,0".
  for each int_ds_tipo_pedido no-lock:
      tp_pedido:ADD-LAST(int_ds_tipo_pedido.descricao,int_ds_tipo_pedido.tp_pedido).
  end.
  tp_pedido:DELETE("0,0") no-error.
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

  apply "LEAVE":U to int_ds_tp_trib_natur_oper.nat_saida_est   in frame {&FRAME-NAME}.
  apply "LEAVE":U to int_ds_tp_trib_natur_oper.nat_saida_inter in frame {&FRAME-NAME}.
  apply "LEAVE":U to int_ds_tp_trib_natur_oper.nat_entrada_est in frame {&FRAME-NAME}.
  apply "LEAVE":U to int_ds_tp_trib_natur_oper.nat_entrada_inter in frame {&FRAME-NAME}.
  apply "LEAVE":U to int_ds_tp_trib_natur_oper.nat_saida_est_nao_contrib in frame {&FRAME-NAME}.
  apply "LEAVE":U to int_ds_tp_trib_natur_oper.nat_saida_inter_nao_contrib in frame {&FRAME-NAME}.
  apply "LEAVE":U to int_ds_tp_trib_natur_oper.nat_entrada_est_nao_contrib in frame {&FRAME-NAME}.
  apply "LEAVE":U to int_ds_tp_trib_natur_oper.nat_entrada_inter_nao_contrib in frame {&FRAME-NAME}.
  apply "LEAVE":U to int_ds_tp_trib_natur_oper.class_fiscal in frame {&FRAME-NAME}.
  APPLY "LEAVE":U to int_ds_tp_trib_natur_oper.nat_saida_sem_reg  in frame {&FRAME-NAME}.
  apply "LEAVE":U to int_ds_tp_trib_natur_oper.nat_saida_inter_sem_reg   in frame {&FRAME-NAME}.

  assign cd-trib-icm:screen-value in FRAME {&FRAME-NAME} = string(i-cd-trib-icm-115).
  if i-cd-trib-icm-115 = 0 then do:
      assign cd-trib-icm:screen-value in FRAME {&FRAME-NAME} = "0".
      /*assign c-class-fiscal:screen-value in FRAME {&FRAME-NAME} = "00000000".*/
      if ADM-NEW-RECORD then
          assign int_ds_tp_trib_natur_oper.class_fiscal:sensitive in FRAME {&FRAME-NAME} = yes.
  end.

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

    for first int_ds_tipo_pedido no-lock where rowid(int_ds_tipo_pedido) = v-row-parent:
        assign tp_pedido:screen-value in FRAME {&FRAME-NAME} = int_ds_tipo_pedido.tp_pedido.
    end.  

    
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

  if int_ds_tp_trib_natur_oper.uf_origem:screen-value in frame {&FRAME-NAME} <> "" and
     not can-find(first unid-feder no-lock where
                  unid-feder.pais = "Brasil" and
                  unid-feder.estado = int_ds_tp_trib_natur_oper.uf_origem:screen-value in frame {&FRAME-NAME}) then do:
      run utp/ut-msgs.p(input "show",
                        input 17006,
                        input ("Unidade da federaá∆o inv†lida!" + "~~" + "Unidade da federaá∆o deve estar cadastrada ou ficar em branco.")).
      apply "entry":U to int_ds_tp_trib_natur_oper.uf_origem in frame {&FRAME-NAME}.
      return "ADM-ERROR".
  end.  

  if cd-trib-icm:input-value in frame {&FRAME-NAME} = 0 and 
     trim(int_ds_tp_trib_natur_oper.class_fiscal:screen-value in frame {&FRAME-NAME}) = "" 
  then do:
      run utp/ut-msgs.p(input "show",
                        input 17006,
                        input ("Classificaá∆o fiscal inv†lida!" + "~~" + "Classificaá∆o fiscal deve ser informada para tipo tributaá∆o Nenhum.")).
      apply "entry":U to int_ds_tp_trib_natur_oper.class_fiscal in frame {&FRAME-NAME}.
      return "ADM-ERROR".
  end.

  if cd-trib-icm:input-value in frame {&FRAME-NAME} = 0 and
     not can-find (first classif-fisc no-lock where 
                   classif-fisc.class-fiscal = int_ds_tp_trib_natur_oper.class_fiscal:input-value in frame {&FRAME-NAME}) 
  then do:
      run utp/ut-msgs.p(input "show",
                        input 17006,
                        input ("Classificaá∆o fiscal inv†lida!" + "~~" + "Classificaá∆o fiscal informada n∆o encontrada no cadastro.")).
      apply "entry":U to int_ds_tp_trib_natur_oper.class_fiscal in frame {&FRAME-NAME}.
      return "ADM-ERROR".
  end.

  if int_ds_tp_trib_natur_oper.nat_saida_est:screen-value in frame {&FRAME-NAME} = "" or
     not can-find(first natur-oper no-lock where natur-oper.nat-operacao = int_ds_tp_trib_natur_oper.nat_saida_est:screen-value in frame {&FRAME-NAME})
  then do:
      run utp/ut-msgs.p(input "show",
                        input 17006,
                        input ("Natureza de sa°da estadual inv†lida!" + "~~" + "Natureza de operaá∆o de sa°da deve estar cadastrada.")).
      apply "entry":U to int_ds_tp_trib_natur_oper.nat_saida_est in frame {&FRAME-NAME}.
      return "ADM-ERROR".
  end.

  if int_ds_tp_trib_natur_oper.nat_saida_inter:screen-value in frame {&FRAME-NAME} = "" or
     not can-find(first natur-oper no-lock where natur-oper.nat-operacao = int_ds_tp_trib_natur_oper.nat_saida_inter:screen-value in frame {&FRAME-NAME})
  then do:
      run utp/ut-msgs.p(input "show",
                        input 17006,
                        input ("Natureza de sa°da interestadual inv†lida!" + "~~" + "Natureza de operaá∆o de sa°da deve estar cadastrada.")).
      apply "entry":U to int_ds_tp_trib_natur_oper.nat_saida_inter in frame {&FRAME-NAME}.
      return "ADM-ERROR".
  end.

  if int_ds_tp_trib_natur_oper.nat_saida_est_nao_contrib:screen-value in frame {&FRAME-NAME} <> "" and
     not can-find(first natur-oper no-lock where natur-oper.nat-operacao = int_ds_tp_trib_natur_oper.nat_saida_est_nao_contrib:screen-value in frame {&FRAME-NAME})
  then do:
      run utp/ut-msgs.p(input "show",
                        input 17006,
                        input ("Natureza de sa°da estadual NAO contribuinte inv†lida!" + "~~" + "Natureza de operaá∆o de sa°da deve estar cadastrada.")).
      apply "entry":U to int_ds_tp_trib_natur_oper.nat_saida_est_nao_contrib in frame {&FRAME-NAME}.
      return "ADM-ERROR".
  end.

  if int_ds_tp_trib_natur_oper.nat_saida_inter_nao_contrib:screen-value in frame {&FRAME-NAME} <> "" and
     not can-find(first natur-oper no-lock where natur-oper.nat-operacao = int_ds_tp_trib_natur_oper.nat_saida_inter_nao_contrib:screen-value in frame {&FRAME-NAME})
  then do:
      run utp/ut-msgs.p(input "show",
                        input 17006,
                        input ("Natureza de sa°da interestadual NAO contribuinte inv†lida!" + "~~" + "Natureza de operaá∆o de sa°da deve estar cadastrada.")).
      apply "entry":U to int_ds_tp_trib_natur_oper.nat_saida_inter_nao_contrib in frame {&FRAME-NAME}.
      return "ADM-ERROR".
  end.


  if int_ds_tp_trib_natur_oper.nat_entrada_est:screen-value in frame {&FRAME-NAME} <> "" AND
     not can-find(first natur-oper no-lock where natur-oper.nat-operacao = int_ds_tp_trib_natur_oper.nat_entrada_est:screen-value in frame {&FRAME-NAME})
  then do:
      run utp/ut-msgs.p(input "show",
                        input 17006,
                        input ("Natureza de entrada estadual inv†lida!" + "~~" + "Natureza de operaá∆o de entrada deve estar cadastrada.")).
      apply "entry":U to int_ds_tp_trib_natur_oper.nat_entrada_est in frame {&FRAME-NAME}.
      return "ADM-ERROR".
  end.
  
  if int_ds_tp_trib_natur_oper.nat_entrada_inter:screen-value in frame {&FRAME-NAME} <> "" AND
     not can-find(first natur-oper no-lock where natur-oper.nat-operacao = int_ds_tp_trib_natur_oper.nat_entrada_inter:screen-value in frame {&FRAME-NAME})
  then do:
      run utp/ut-msgs.p(input "show",
                        input 17006,
                        input ("Natureza de entrada interestadual inv†lida!" + "~~" + "Natureza de operaá∆o de entrada deve estar cadastrada.")).
      apply "entry":U to int_ds_tp_trib_natur_oper.nat_entrada_inter in frame {&FRAME-NAME}.
      return "ADM-ERROR".
  end.

  if int_ds_tp_trib_natur_oper.nat_entrada_est_nao_contrib:screen-value in frame {&FRAME-NAME} <> "" AND
     not can-find(first natur-oper no-lock where natur-oper.nat-operacao = int_ds_tp_trib_natur_oper.nat_entrada_est_nao_contrib:screen-value in frame {&FRAME-NAME})
  then do:
      run utp/ut-msgs.p(input "show",
                        input 17006,
                        input ("Natureza de entrada estadual NAO contriubuinte inv†lida!" + "~~" + "Natureza de operaá∆o de entrada deve estar cadastrada.")).
      apply "entry":U to int_ds_tp_trib_natur_oper.nat_entrada_est_nao_contrib in frame {&FRAME-NAME}.
      return "ADM-ERROR".
  end.
  
  if int_ds_tp_trib_natur_oper.nat_entrada_inter_nao_contrib:screen-value in frame {&FRAME-NAME} <> "" AND
     not can-find(first natur-oper no-lock where natur-oper.nat-operacao = int_ds_tp_trib_natur_oper.nat_entrada_inter_nao_contrib:screen-value in frame {&FRAME-NAME})
  then do:
      run utp/ut-msgs.p(input "show",
                        input 17006,
                        input ("Natureza de entrada interestadual NAO contriubuinte inv†lida!" + "~~" + "Natureza de operaá∆o de entrada deve estar cadastrada.")).
      apply "entry":U to int_ds_tp_trib_natur_oper.nat_entrada_inter_nao_contrib in frame {&FRAME-NAME}.
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
  {src/adm/template/snd-list.i "int_ds_tp_trib_natur_oper"}

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

