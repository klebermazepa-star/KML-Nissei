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
{include/i-prgvrs.i int115Cv 2.12.01.AVB}

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
&Scoped-define EXTERNAL-TABLES int_ds_tp_nat_origem
&Scoped-define FIRST-EXTERNAL-TABLE int_ds_tp_nat_origem


/* Need to scope the external tables to this procedure                  */
DEFINE QUERY external_tables FOR int_ds_tp_nat_origem.
/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS int_ds_tp_nat_origem.nat_saida ~
int_ds_tp_nat_origem.nat_entrada int_ds_tp_nat_origem.nat_saida_nao_contrib ~
int_ds_tp_nat_origem.nat_entrada_nao_contrib 
&Scoped-define ENABLED-TABLES int_ds_tp_nat_origem
&Scoped-define FIRST-ENABLED-TABLE int_ds_tp_nat_origem
&Scoped-Define ENABLED-OBJECTS rt-key rt-mold rt-mold-2 
&Scoped-Define DISPLAYED-FIELDS int_ds_tp_nat_origem.nat_origem ~
int_ds_tp_nat_origem.nat_saida int_ds_tp_nat_origem.nat_entrada ~
int_ds_tp_nat_origem.nat_saida_nao_contrib ~
int_ds_tp_nat_origem.nat_entrada_nao_contrib 
&Scoped-define DISPLAYED-TABLES int_ds_tp_nat_origem
&Scoped-define FIRST-DISPLAYED-TABLE int_ds_tp_nat_origem
&Scoped-Define DISPLAYED-OBJECTS tp_pedido cNatOrigem cNatSaida cNatEntrada ~
cNatSaidaNC cNatEntradaNC 

/* Custom List Definitions                                              */
/* ADM-CREATE-FIELDS,ADM-ASSIGN-FIELDS,ADM-MODIFY-FIELDS,List-4,List-5,List-6 */
&Scoped-define ADM-CREATE-FIELDS int_ds_tp_nat_origem.nat_origem 

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
     SIZE 73 BY 1.

DEFINE VARIABLE cNatEntrada AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 61 BY .88 NO-UNDO.

DEFINE VARIABLE cNatEntradaNC AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 61 BY .88 NO-UNDO.

DEFINE VARIABLE cNatOrigem AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 61 BY .88 NO-UNDO.

DEFINE VARIABLE cNatSaida AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 61 BY .88 NO-UNDO.

DEFINE VARIABLE cNatSaidaNC AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 61 BY .88 NO-UNDO.

DEFINE RECTANGLE rt-key
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 88.57 BY 2.75.

DEFINE RECTANGLE rt-mold
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 88.57 BY 2.75.

DEFINE RECTANGLE rt-mold-2
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 88.57 BY 2.75.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME f-main
     tp_pedido AT ROW 1.25 COL 12 COLON-ALIGNED WIDGET-ID 220
     int_ds_tp_nat_origem.nat_origem AT ROW 2.5 COL 12 COLON-ALIGNED WIDGET-ID 2
          VIEW-AS FILL-IN 
          SIZE 12.14 BY .88
     cNatOrigem AT ROW 2.5 COL 24 COLON-ALIGNED NO-LABEL WIDGET-ID 112
     int_ds_tp_nat_origem.nat_saida AT ROW 4.5 COL 12 COLON-ALIGNED WIDGET-ID 208
          VIEW-AS FILL-IN 
          SIZE 12.14 BY .88
     cNatSaida AT ROW 4.5 COL 24 COLON-ALIGNED NO-LABEL WIDGET-ID 204
     int_ds_tp_nat_origem.nat_entrada AT ROW 5.5 COL 12 COLON-ALIGNED WIDGET-ID 114
          VIEW-AS FILL-IN 
          SIZE 12.14 BY .88
     cNatEntrada AT ROW 5.5 COL 24 COLON-ALIGNED NO-LABEL WIDGET-ID 200
     int_ds_tp_nat_origem.nat_saida_nao_contrib AT ROW 7.5 COL 12 COLON-ALIGNED WIDGET-ID 210
          LABEL "Nat. Saida"
          VIEW-AS FILL-IN 
          SIZE 12.14 BY .88
     cNatSaidaNC AT ROW 7.5 COL 24 COLON-ALIGNED NO-LABEL WIDGET-ID 206
     int_ds_tp_nat_origem.nat_entrada_nao_contrib AT ROW 8.5 COL 12 COLON-ALIGNED WIDGET-ID 116
          LABEL "Nat. Entrada"
          VIEW-AS FILL-IN 
          SIZE 12.14 BY .88
     cNatEntradaNC AT ROW 8.5 COL 24 COLON-ALIGNED NO-LABEL WIDGET-ID 202
     "Naturezas N«O Contribuinte" VIEW-AS TEXT
          SIZE 24 BY .67 AT ROW 6.75 COL 3 WIDGET-ID 216
     "Naturezas Contribuinte" VIEW-AS TEXT
          SIZE 20 BY .67 AT ROW 3.75 COL 3 WIDGET-ID 218
     rt-key AT ROW 1 COL 1 WIDGET-ID 212
     rt-mold AT ROW 7 COL 1 WIDGET-ID 214
     rt-mold-2 AT ROW 4 COL 1 WIDGET-ID 194
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1 SCROLLABLE  WIDGET-ID 100.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: SmartViewer
   External Tables: custom.int_ds_tp_nat_origem
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
         HEIGHT             = 8.83
         WIDTH              = 89.29.
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

/* SETTINGS FOR FILL-IN cNatEntrada IN FRAME f-main
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN cNatEntradaNC IN FRAME f-main
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN cNatOrigem IN FRAME f-main
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN cNatSaida IN FRAME f-main
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN cNatSaidaNC IN FRAME f-main
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN int_ds_tp_nat_origem.nat-entrada-nao-contrib IN FRAME f-main
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN int_ds_tp_nat_origem.nat-origem IN FRAME f-main
   NO-ENABLE 1                                                          */
/* SETTINGS FOR FILL-IN int_ds_tp_nat_origem.nat-saida-nao-contrib IN FRAME f-main
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

&Scoped-define SELF-NAME int_ds_tp_nat_origem.nat_entrada
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL int_ds_tp_nat_origem.nat_entrada V-table-Win
ON F5 OF int_ds_tp_nat_origem.nat_entrada IN FRAME f-main /* Nat. Entrada */
OR MOUSE-SELECT-DBLCLICK OF int_ds_tp_nat_origem.nat_entrada in frame {&FRAME-NAME} DO:
        {include/zoomvar.i &prog-zoom=inzoom/z01in245.w
                                &campo=int_ds_tp_nat_origem.nat_entrada
                                &campozoom=nat-operacao}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL int_ds_tp_nat_origem.nat_entrada V-table-Win
ON LEAVE OF int_ds_tp_nat_origem.nat_entrada IN FRAME f-main /* Nat. Entrada */
DO:
    cNatEntrada:screen-value in frame {&frame-name} = "".
    for first mgind.natur-oper 
        fields (nat-operacao denominacao)
        no-lock where
        mgind.natur-oper.nat-operacao = input frame {&FRAME-NAME} int_ds_tp_nat_origem.nat_entrada:
        display natur-oper.denominacao @ cNatEntrada with frame {&FRAME-NAME}.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME int_ds_tp_nat_origem.nat_entrada_nao_contrib
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL int_ds_tp_nat_origem.nat_entrada_nao_contrib V-table-Win
ON F5 OF int_ds_tp_nat_origem.nat_entrada_nao_contrib IN FRAME f-main /* Nat. Entrada */
OR MOUSE-SELECT-DBLCLICK OF int_ds_tp_nat_origem.nat_saida_nao_contrib in frame {&FRAME-NAME} DO:
        {include/zoomvar.i &prog-zoom=inzoom/z01in245.w
                                &campo=int_ds_tp_nat_origem.nat_saida_nao_contrib
                                &campozoom=nat-operacao}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL int_ds_tp_nat_origem.nat_entrada_nao_contrib V-table-Win
ON LEAVE OF int_ds_tp_nat_origem.nat_entrada_nao_contrib IN FRAME f-main /* Nat. Entrada */
DO:
    cNatEntradaNC:screen-value in frame {&frame-name} = "".
    for first mgind.natur-oper 
        fields (nat-operacao denominacao)
        no-lock where
        mgind.natur-oper.nat-operacao = input frame {&FRAME-NAME} int_ds_tp_nat_origem.nat_entrada_nao_contrib.
        display natur-oper.denominacao @ cNatEntradaNC with frame {&FRAME-NAME}.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME int_ds_tp_nat_origem.nat_origem
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL int_ds_tp_nat_origem.nat_origem V-table-Win
ON F5 OF int_ds_tp_nat_origem.nat_origem IN FRAME f-main /* Nat. Origem */
OR MOUSE-SELECT-DBLCLICK OF int_ds_tp_nat_origem.nat_origem in frame {&FRAME-NAME} DO:
        {include/zoomvar.i &prog-zoom=inzoom/z01in245.w
                                &campo=int_ds_tp_nat_origem.nat_origem
                                &campozoom=nat-operacao}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL int_ds_tp_nat_origem.nat_origem V-table-Win
ON LEAVE OF int_ds_tp_nat_origem.nat_origem IN FRAME f-main /* Nat. Origem */
DO:
    cNatOrigem:screen-value in frame {&frame-name} = "".
    for first mgind.natur-oper 
        fields (nat-operacao denominacao)
        no-lock where
        mgind.natur-oper.nat-operacao = input frame {&FRAME-NAME} int_ds_tp_nat_origem.nat_origem:
        display natur-oper.denominacao @ cNatOrigem with frame {&FRAME-NAME}.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME int_ds_tp_nat_origem.nat_saida
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL int_ds_tp_nat_origem.nat_saida V-table-Win
ON F5 OF int_ds_tp_nat_origem.nat_saida IN FRAME f-main /* Nat. Saida */
OR MOUSE-SELECT-DBLCLICK OF int_ds_tp_nat_origem.nat_saida in frame {&FRAME-NAME} DO:
        {include/zoomvar.i &prog-zoom=inzoom/z01in245.w
                                &campo=int_ds_tp_nat_origem.nat_saida
                                &campozoom=nat-operacao}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL int_ds_tp_nat_origem.nat_saida V-table-Win
ON LEAVE OF int_ds_tp_nat_origem.nat_saida IN FRAME f-main /* Nat. Saida */
DO:
    cNatSaida:screen-value in frame {&frame-name} = "".
    for first mgind.natur-oper 
        fields (nat-operacao denominacao)
        no-lock where
        mgind.natur-oper.nat-operacao = input frame {&FRAME-NAME} int_ds_tp_nat_origem.nat_saida:
        display natur-oper.denominacao @ cNatSaida with frame {&FRAME-NAME}.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME int_ds_tp_nat_origem.nat_saida_nao_contrib
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL int_ds_tp_nat_origem.nat_saida_nao_contrib V-table-Win
ON F5 OF int_ds_tp_nat_origem.nat_saida_nao_contrib IN FRAME f-main /* Nat. Saida */
OR MOUSE-SELECT-DBLCLICK OF int_ds_tp_nat_origem.nat_entrada_nao_contrib in frame {&FRAME-NAME} DO:
        {include/zoomvar.i &prog-zoom=inzoom/z01in245.w
                                &campo=int_ds_tp_nat_origem.nat_entrada_nao_contrib
                                &campozoom=nat-operacao}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL int_ds_tp_nat_origem.nat_saida_nao_contrib V-table-Win
ON LEAVE OF int_ds_tp_nat_origem.nat_saida_nao_contrib IN FRAME f-main /* Nat. Saida */
DO:
    cNatSaidaNC:screen-value in frame {&frame-name} = "".
    for first mgind.natur-oper 
        fields (nat-operacao denominacao)
        no-lock where
        mgind.natur-oper.nat-operacao = input frame {&FRAME-NAME} int_ds_tp_nat_origem.nat_saida_nao_contrib:
        display natur-oper.denominacao @ cNatSaidaNC with frame {&FRAME-NAME}.
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
  {src/adm/template/row-list.i "int_ds_tp_nat_origem"}

  /* Get the record ROWID's from the RECORD-SOURCE.                  */
  {src/adm/template/row-get.i}

  /* FIND each record specified by the RECORD-SOURCE.                */
  {src/adm/template/row-find.i "int_ds_tp_nat_origem"}

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
      assign int_ds_tp_nat_origem.tp_pedido = int_ds_tipo_pedido.tp_pedido.
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
  
  int_ds_tp_nat_origem.nat_saida   :LOAD-MOUSE-POINTER("image/lupa.cur":U) IN FRAME f-Main.
  int_ds_tp_nat_origem.nat_saida_nao_contrib :LOAD-MOUSE-POINTER("image/lupa.cur":U) IN FRAME f-Main.
  int_ds_tp_nat_origem.nat_entrada :LOAD-MOUSE-POINTER("image/lupa.cur":U) IN FRAME f-Main.
  int_ds_tp_nat_origem.nat_entrada_nao_contrib :LOAD-MOUSE-POINTER("image/lupa.cur":U) IN FRAME f-Main.
  int_ds_tp_nat_origem.nat_origem :LOAD-MOUSE-POINTER("image/lupa.cur":U) IN FRAME f-Main.
  
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

  apply "LEAVE":U to int_ds_tp_nat_origem.nat_saida   in frame {&FRAME-NAME}.
  apply "LEAVE":U to int_ds_tp_nat_origem.nat_saida_nao_contrib in frame {&FRAME-NAME}.
  apply "LEAVE":U to int_ds_tp_nat_origem.nat_entrada in frame {&FRAME-NAME}.
  apply "LEAVE":U to int_ds_tp_nat_origem.nat_entrada_nao_contrib in frame {&FRAME-NAME}.
  apply "LEAVE":U to int_ds_tp_nat_origem.nat_origem in frame {&FRAME-NAME}.

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

  if int_ds_tp_nat_origem.nat_origem:screen-value in frame {&FRAME-NAME} = "" or
     not can-find(first natur-oper no-lock where natur-oper.nat-operacao = int_ds_tp_nat_origem.nat_origem:screen-value in frame {&FRAME-NAME})
  then do:
      run utp/ut-msgs.p(input "show",
                        input 17006,
                        input ("Natureza de origem!" + "~~" + "Natureza de operaá∆o de sa°da deve estar cadastrada.")).
      apply "entry":U to int_ds_tp_nat_origem.nat_origem in frame {&FRAME-NAME}.
      return "ADM-ERROR".
  end.

  if int_ds_tp_nat_origem.nat_saida:screen-value in frame {&FRAME-NAME} = "" or
     not can-find(first natur-oper no-lock where natur-oper.nat-operacao = int_ds_tp_nat_origem.nat_saida:screen-value in frame {&FRAME-NAME})
  then do:
      run utp/ut-msgs.p(input "show",
                        input 17006,
                        input ("Natureza de sa°da!" + "~~" + "Natureza de operaá∆o de sa°da deve estar cadastrada.")).
      apply "entry":U to int_ds_tp_nat_origem.nat_saida in frame {&FRAME-NAME}.
      return "ADM-ERROR".
  end.

  if int_ds_tp_nat_origem.nat_saida_nao_contrib:screen-value in frame {&FRAME-NAME} = "" or
     not can-find(first natur-oper no-lock where natur-oper.nat-operacao = int_ds_tp_nat_origem.nat_saida_nao_contrib:screen-value in frame {&FRAME-NAME})
  then do:
      run utp/ut-msgs.p(input "show",
                        input 17006,
                        input ("Natureza de sa°da n∆o contribuinte inv†lida!" + "~~" + "Natureza de operaá∆o de sa°da deve estar cadastrada.")).
      apply "entry":U to int_ds_tp_nat_origem.nat_saida_nao_contrib in frame {&FRAME-NAME}.
      return "ADM-ERROR".
  end.

  if int_ds_tp_nat_origem.nat_entrada:screen-value in frame {&FRAME-NAME} <> "" AND
     not can-find(first natur-oper no-lock where natur-oper.nat-operacao = int_ds_tp_nat_origem.nat_entrada:screen-value in frame {&FRAME-NAME})
  then do:
      run utp/ut-msgs.p(input "show",
                        input 17006,
                        input ("Natureza de entrada inv†lida!" + "~~" + "Natureza de operaá∆o de entrada deve estar cadastrada.")).
      apply "entry":U to int_ds_tp_nat_origem.nat_entrada in frame {&FRAME-NAME}.
      return "ADM-ERROR".
  end.
  
  if int_ds_tp_nat_origem.nat_entrada_nao_contrib:screen-value in frame {&FRAME-NAME} <> "" AND
     not can-find(first natur-oper no-lock where natur-oper.nat-operacao = int_ds_tp_nat_origem.nat_entrada_nao_contrib:screen-value in frame {&FRAME-NAME})
  then do:
      run utp/ut-msgs.p(input "show",
                        input 17006,
                        input ("Natureza de entrada n∆o contriubuinte inv†lida!" + "~~" + "Natureza de operaá∆o de entrada deve estar cadastrada.")).
      apply "entry":U to int_ds_tp_nat_origem.nat_entrada_nao_contrib in frame {&FRAME-NAME}.
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
  {src/adm/template/snd-list.i "int_ds_tp_nat_origem"}

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

