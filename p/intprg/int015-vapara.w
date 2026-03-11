&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI ADM1
&ANALYZE-RESUME
/* Connected Databases 
          emsesp           PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME d-vapara
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS d-vapara 
/*:T *******************************************************************************
** Copyright DATASUL S.A. (1997)
** Todos os Direitos Reservados.
**
** Este fonte e de propriedade exclusiva da DATASUL, sua reproducao
** parcial ou total por qualquer meio, so podera ser feita mediante
** autorizacao expressa.
*******************************************************************************/
{include/i-prgvrs.i V01EMITESTAB 2.04.00.AVB}

/* Create an unnamed pool to store all the widgets created 
     by this procedure. This is a good default which assures
     that this procedure's triggers and internal procedures 
     will execute in this procedure's storage, and that proper
     cleanup will occur on deletion of the procedure. */

CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define output parameter     p-row-tabela    as rowid    no-undo.

/* Local Variable Definitions ---                                       */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE SmartVaPara
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME d-vapara

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS int-ds-tp-natur-oper.tp-pedido ~
int-ds-tp-natur-oper.cod-estabel int-ds-tp-natur-oper.uf-destino ~
int-ds-tp-natur-oper.uf-origem int-ds-tp-natur-oper.cod-emitente ~
int-ds-tp-natur-oper.class-fiscal 
&Scoped-define ENABLED-TABLES int-ds-tp-natur-oper
&Scoped-define FIRST-ENABLED-TABLE int-ds-tp-natur-oper
&Scoped-Define ENABLED-OBJECTS rt-button bt-ok bt-cancela bt-ajuda 
&Scoped-Define DISPLAYED-FIELDS int-ds-tp-natur-oper.tp-pedido ~
int-ds-tp-natur-oper.cod-estabel int-ds-tp-natur-oper.uf-destino ~
int-ds-tp-natur-oper.uf-origem int-ds-tp-natur-oper.cod-emitente ~
int-ds-tp-natur-oper.class-fiscal 
&Scoped-define DISPLAYED-TABLES int-ds-tp-natur-oper
&Scoped-define FIRST-DISPLAYED-TABLE int-ds-tp-natur-oper


/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Menu Definitions                                                     */
DEFINE MENU POPUP-MENU-bt-ajuda 
       MENU-ITEM mi-sobre       LABEL "Sobre..."      .


/* Definitions of the field level widgets                               */
DEFINE BUTTON bt-ajuda 
     LABEL "&Ajuda" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON bt-cancela AUTO-END-KEY 
     LABEL "&Cancelar" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON bt-ok AUTO-GO 
     LABEL "&OK" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE RECTANGLE rt-button
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 68 BY 1.42
     BGCOLOR 7 .


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME d-vapara
     int-ds-tp-natur-oper.tp-pedido AT ROW 1.25 COL 10.43 WIDGET-ID 110
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
                     "ATIVO IMOBILIZADO FILIAL => FILIAL","39"
          DROP-DOWN-LIST
          SIZE 45 BY 1
     int-ds-tp-natur-oper.cod-estabel AT ROW 2.5 COL 20 COLON-ALIGNED
          VIEW-AS FILL-IN 
          SIZE 7.14 BY .88
     int-ds-tp-natur-oper.uf-destino AT ROW 3.5 COL 20 COLON-ALIGNED WIDGET-ID 4
          VIEW-AS FILL-IN 
          SIZE 5.14 BY .88
     int-ds-tp-natur-oper.uf-origem AT ROW 4.5 COL 20 COLON-ALIGNED WIDGET-ID 112
          VIEW-AS FILL-IN 
          SIZE 26.14 BY .88
     int-ds-tp-natur-oper.cod-emitente AT ROW 5.5 COL 20 COLON-ALIGNED
          VIEW-AS FILL-IN 
          SIZE 8 BY .88
     int-ds-tp-natur-oper.class-fiscal AT ROW 6.58 COL 20 COLON-ALIGNED WIDGET-ID 6 FORMAT "99999999"
          VIEW-AS FILL-IN 
          SIZE 15 BY .88
     bt-ok AT ROW 8.25 COL 2.14
     bt-cancela AT ROW 8.25 COL 13
     bt-ajuda AT ROW 8.25 COL 58
     rt-button AT ROW 8 COL 1
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "V  Para Tipo Pedido X Natureza"
         DEFAULT-BUTTON bt-ok CANCEL-BUTTON bt-cancela.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: SmartVaPara
   Allow: Basic,DB-Fields
   Frames: 1
   Add Fields to: Neither
   Other Settings: COMPILE
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _INCLUDED-LIB d-vapara 
/* ************************* Included-Libraries *********************** */

{src/adm/method/containr.i}
{include/d-vapara.i}
{utp/ut-glob.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME




/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX d-vapara
   FRAME-NAME L-To-R                                                    */
ASSIGN 
       FRAME d-vapara:SCROLLABLE       = FALSE
       FRAME d-vapara:HIDDEN           = TRUE.

ASSIGN 
       bt-ajuda:POPUP-MENU IN FRAME d-vapara       = MENU POPUP-MENU-bt-ajuda:HANDLE.

/* SETTINGS FOR FILL-IN int-ds-tp-natur-oper.class-fiscal IN FRAME d-vapara
   EXP-FORMAT                                                           */
/* SETTINGS FOR COMBO-BOX int-ds-tp-natur-oper.tp-pedido IN FRAME d-vapara
   ALIGN-L                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX d-vapara
/* Query rebuild information for DIALOG-BOX d-vapara
     _Options          = "SHARE-LOCK"
     _Query            is NOT OPENED
*/  /* DIALOG-BOX d-vapara */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME d-vapara
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL d-vapara d-vapara
ON GO OF FRAME d-vapara /* V  Para Tipo Pedido X Natureza */
DO:
  find first int-ds-tp-natur-oper no-lock where 
      int-ds-tp-natur-oper.tp-pedido = input frame {&frame-name} int-ds-tp-natur-oper.tp-pedido and
      int-ds-tp-natur-oper.cod-estabel = input frame {&frame-name} int-ds-tp-natur-oper.cod-estabel   and
      int-ds-tp-natur-oper.cod-emitente = input frame {&frame-name} int-ds-tp-natur-oper.cod-emitente and
      int-ds-tp-natur-oper.uf-destino = input frame {&frame-name} int-ds-tp-natur-oper.uf-destino and
      int-ds-tp-natur-oper.uf-origem = input frame {&frame-name} int-ds-tp-natur-oper.uf-origem and
      int-ds-tp-natur-oper.class-fiscal = input frame {&frame-name} int-ds-tp-natur-oper.class-fiscal
      no-error.
  if  not avail int-ds-tp-natur-oper then do:
      {utp/ut-table.i emsesp int-ds-tp-natur-oper 1}
      run utp/ut-msgs.p (input "show":U,
                         input 2,
                         input RETURN-VALUE).
      return no-apply.
  end.
  assign p-row-tabela = rowid(int-ds-tp-natur-oper).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL d-vapara d-vapara
ON WINDOW-CLOSE OF FRAME d-vapara /* V  Para Tipo Pedido X Natureza */
DO:  
  /* Add Trigger to equate WINDOW-CLOSE to END-ERROR. */
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-ajuda
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-ajuda d-vapara
ON CHOOSE OF bt-ajuda IN FRAME d-vapara /* Ajuda */
OR HELP OF FRAME {&FRAME-NAME}
DO: /* Call Help Function (or a simple message). */
  {include/ajuda.i}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME mi-sobre
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL mi-sobre d-vapara
ON CHOOSE OF MENU-ITEM mi-sobre /* Sobre... */
DO:
  {include/sobre.i}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK d-vapara 


/* ***************************  Main Block  *************************** */

assign p-row-tabela = ?.

{src/adm/template/dialogmn.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE adm-create-objects d-vapara  _ADM-CREATE-OBJECTS
PROCEDURE adm-create-objects :
/*------------------------------------------------------------------------------
  Purpose:     Create handles for all SmartObjects used in this procedure.
               After SmartObjects are initialized, then SmartLinks are added.
  Parameters:  <none>
------------------------------------------------------------------------------*/

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE adm-row-available d-vapara  _ADM-ROW-AVAILABLE
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI d-vapara  _DEFAULT-DISABLE
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
  HIDE FRAME d-vapara.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI d-vapara  _DEFAULT-ENABLE
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
  IF AVAILABLE int-ds-tp-natur-oper THEN 
    DISPLAY int-ds-tp-natur-oper.tp-pedido int-ds-tp-natur-oper.cod-estabel 
          int-ds-tp-natur-oper.uf-destino int-ds-tp-natur-oper.uf-origem 
          int-ds-tp-natur-oper.cod-emitente int-ds-tp-natur-oper.class-fiscal 
      WITH FRAME d-vapara.
  ENABLE rt-button int-ds-tp-natur-oper.tp-pedido 
         int-ds-tp-natur-oper.cod-estabel int-ds-tp-natur-oper.uf-destino 
         int-ds-tp-natur-oper.uf-origem int-ds-tp-natur-oper.cod-emitente 
         int-ds-tp-natur-oper.class-fiscal bt-ok bt-cancela bt-ajuda 
      WITH FRAME d-vapara.
  VIEW FRAME d-vapara.
  {&OPEN-BROWSERS-IN-QUERY-d-vapara}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-destroy d-vapara 
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-initialize d-vapara 
PROCEDURE local-initialize :
/*------------------------------------------------------------------------------
  Purpose:     Override standard ADM method
  Notes:       
------------------------------------------------------------------------------*/

  /* Code placed here will execute PRIOR to standard behavior. */

  {utp/ut9000.i "V01EMITESTAB" "2.04.00.000"}

  /* Dispatch standard ADM method.                             */
  RUN dispatch IN THIS-PROCEDURE ( INPUT 'initialize':U ) .

  /* Code placed here will execute AFTER standard behavior.    */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE send-records d-vapara  _ADM-SEND-RECORDS
PROCEDURE send-records :
/*------------------------------------------------------------------------------
  Purpose:     Send record ROWID's for all tables used by
               this file.
  Parameters:  see template/snd-head.i
------------------------------------------------------------------------------*/

  /* SEND-RECORDS does nothing because there are no External
     Tables specified for this SmartVaPara, and there are no
     tables specified in any contained Browse, Query, or Frame. */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE state-changed d-vapara 
PROCEDURE state-changed :
/* -----------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
-------------------------------------------------------------*/
  DEFINE INPUT PARAMETER p-issuer-hdl AS HANDLE NO-UNDO.
  DEFINE INPUT PARAMETER p-state AS CHARACTER NO-UNDO.

  run pi-trata-state (p-issuer-hdl, p-state).
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

