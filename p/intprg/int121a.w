&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
          custom           PROGRESS
          ems2log          PROGRESS
*/
&Scoped-define WINDOW-NAME wMaintenanceNoNavigation


/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE tt-es-cesta-basica NO-UNDO LIKE es-cesta-basica
       field r-rowid as rowid.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS wMaintenanceNoNavigation 
/*:T*******************************************************************************
** Copyright TOTVS S.A. (2009)
** Todos os Direitos Reservados.
**
** Este fonte e de propriedade exclusiva da TOTVS, sua reproducao
** parcial ou total por qualquer meio, so podera ser feita mediante
** autorizacao expressa.
*******************************************************************************/
{include/i-prgvrs.i int121a 2.00.00.003}  /*** 010000 ***/

/* Chamada a include do gerenciador de licen‡as. Necessario alterar os parametros */
/*                                                                                */
/* <programa>:  Informar qual o nome do programa.                                 */
/* <m¢dulo>:  Informar qual o m¢dulo a qual o programa pertence.                  */

&IF "{&EMSFND_VERSION}" >= "1.00" &THEN
    {include/i-license-manager.i int121a MFT}
&ENDIF

CREATE WIDGET-POOL.

/* Preprocessors Definitions ---                                      */
&GLOBAL-DEFINE Program           int121a
&GLOBAL-DEFINE Version           2.00.00.003

&GLOBAL-DEFINE Folder            NO
&GLOBAL-DEFINE InitialPage       

&GLOBAL-DEFINE FolderLabels      

&GLOBAL-DEFINE ttTable           tt-es-cesta-basica
&GLOBAL-DEFINE hDBOTable         h-tt-es-cesta-basica
&GLOBAL-DEFINE DBOTable          dbo-tt-es-cesta-basica

&GLOBAL-DEFINE page0KeyFields    tt-es-cesta-basica.uf-origem ~
                                 tt-es-cesta-basica.uf-destino ~
                                 tt-es-cesta-basica.tp-pedido
                                 
&GLOBAL-DEFINE page0Fields       tt-es-cesta-basica.nat-operacao
&GLOBAL-DEFINE page1Fields       

/* Parameters Definitions ---                                           */
DEFINE INPUT PARAMETER prTable         AS ROWID     NO-UNDO.
DEFINE INPUT PARAMETER pcAction        AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER phCaller        AS HANDLE    NO-UNDO.

/* Local Variable Definitions ---                                       */

/* Local Variable Definitions (DBOs Handles) --- */
DEFINE VARIABLE {&hDBOTable}  AS HANDLE NO-UNDO.
DEFINE VARIABLE wh-pesquisa AS HANDLE NO-UNDO.
DEFINE NEW GLOBAL SHARED VARIABLE adm-broker-hdl AS HANDLE NO-UNDO.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE MaintenanceNoNavigation
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME fpage0

/* External Tables                                                      */
&Scoped-define EXTERNAL-TABLES natur-oper
&Scoped-define FIRST-EXTERNAL-TABLE natur-oper


/* Need to scope the external tables to this procedure                  */
DEFINE QUERY external_tables FOR natur-oper.
/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS tt-es-cesta-basica.uf-origem ~
tt-es-cesta-basica.uf-destino tt-es-cesta-basica.tp-pedido ~
tt-es-cesta-basica.nat-operacao 
&Scoped-define ENABLED-TABLES tt-es-cesta-basica
&Scoped-define FIRST-ENABLED-TABLE tt-es-cesta-basica
&Scoped-Define ENABLED-OBJECTS rtKeys rt-2 c-desc-nat-operacao btOK btSave ~
btCancel btHelp 
&Scoped-Define DISPLAYED-FIELDS tt-es-cesta-basica.uf-origem ~
tt-es-cesta-basica.uf-destino tt-es-cesta-basica.tp-pedido ~
tt-es-cesta-basica.nat-operacao 
&Scoped-define DISPLAYED-TABLES tt-es-cesta-basica
&Scoped-define FIRST-DISPLAYED-TABLE tt-es-cesta-basica
&Scoped-Define DISPLAYED-OBJECTS c-desc-tp-pedido c-desc-nat-operacao 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR wMaintenanceNoNavigation AS WIDGET-HANDLE NO-UNDO.

/* Definitions of the field level widgets                               */
DEFINE BUTTON btCancel AUTO-END-KEY 
     LABEL "Cancelar" 
     SIZE 10 BY 1.

DEFINE BUTTON btHelp 
     LABEL "Ajuda" 
     SIZE 10 BY 1.

DEFINE BUTTON btOK AUTO-GO 
     LABEL "OK" 
     SIZE 10 BY 1.

DEFINE BUTTON btSave 
     LABEL "Salvar" 
     SIZE 10 BY 1.

DEFINE VARIABLE c-desc-nat-operacao AS CHARACTER FORMAT "X(60)":U 
     VIEW-AS FILL-IN 
     SIZE 49.43 BY .88 NO-UNDO.

DEFINE VARIABLE c-desc-tp-pedido AS CHARACTER FORMAT "X(60)":U 
     VIEW-AS FILL-IN 
     SIZE 45 BY .88 NO-UNDO.

DEFINE RECTANGLE rt-2
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 89 BY 1.5.

DEFINE RECTANGLE rtKeys
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 89 BY 3.5.

DEFINE RECTANGLE rtToolBar
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 89 BY 1.42
     BGCOLOR 7 .


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME fpage0
     tt-es-cesta-basica.uf-origem AT ROW 1.25 COL 17 COLON-ALIGNED WIDGET-ID 6
          VIEW-AS FILL-IN 
          SIZE 5 BY .88
     tt-es-cesta-basica.uf-destino AT ROW 2.25 COL 17 COLON-ALIGNED WIDGET-ID 4
          VIEW-AS FILL-IN 
          SIZE 5 BY .88
     tt-es-cesta-basica.tp-pedido AT ROW 3.25 COL 17 COLON-ALIGNED WIDGET-ID 2
          VIEW-AS FILL-IN 
          SIZE 5 BY .88
     c-desc-tp-pedido AT ROW 3.25 COL 22.57 COLON-ALIGNED NO-LABEL WIDGET-ID 12
     tt-es-cesta-basica.nat-operacao AT ROW 5 COL 17 COLON-ALIGNED WIDGET-ID 14
          VIEW-AS FILL-IN 
          SIZE 12 BY .88
     c-desc-nat-operacao AT ROW 5 COL 29.57 COLON-ALIGNED NO-LABEL WIDGET-ID 16
     btOK AT ROW 6.75 COL 2 WIDGET-ID 42
     btSave AT ROW 6.75 COL 13 WIDGET-ID 44
     btCancel AT ROW 6.75 COL 24 WIDGET-ID 46
     btHelp AT ROW 6.75 COL 78 WIDGET-ID 48
     rtKeys AT ROW 1 COL 1
     rtToolBar AT ROW 6.5 COL 1 WIDGET-ID 40
     rt-2 AT ROW 4.75 COL 1 WIDGET-ID 8
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 90 BY 7.58
         FONT 1 WIDGET-ID 100.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: MaintenanceNoNavigation
   External Tables: ems2log.natur-oper
   Allow: Basic,Browse,DB-Fields,Window,Query
   Add Fields to: Neither
   Other Settings: COMPILE
   Temp-Tables and Buffers:
      TABLE: tt-es-cesta-basica T "?" NO-UNDO custom es-cesta-basica
      ADDITIONAL-FIELDS:
          field r-rowid as rowid
      END-FIELDS.
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
IF SESSION:DISPLAY-TYPE = "GUI":U THEN
  CREATE WINDOW wMaintenanceNoNavigation ASSIGN
         HIDDEN             = YES
         TITLE              = ""
         HEIGHT             = 7.75
         WIDTH              = 89.43
         MAX-HEIGHT         = 17
         MAX-WIDTH          = 94.14
         VIRTUAL-HEIGHT     = 17
         VIRTUAL-WIDTH      = 94.14
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _INCLUDED-LIB wMaintenanceNoNavigation 
/* ************************* Included-Libraries *********************** */

{maintenancenonavigation/maintenancenonavigation.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME




/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW wMaintenanceNoNavigation
  NOT-VISIBLE,,RUN-PERSISTENT                                           */
/* SETTINGS FOR FRAME fpage0
   FRAME-NAME                                                           */
/* SETTINGS FOR FILL-IN c-desc-tp-pedido IN FRAME fpage0
   NO-ENABLE                                                            */
/* SETTINGS FOR RECTANGLE rtToolBar IN FRAME fpage0
   NO-ENABLE                                                            */
IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(wMaintenanceNoNavigation)
THEN wMaintenanceNoNavigation:HIDDEN = yes.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK FRAME fpage0
/* Query rebuild information for FRAME fpage0
     _Options          = "SHARE-LOCK KEEP-EMPTY"
     _Query            is NOT OPENED
*/  /* FRAME fpage0 */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME wMaintenanceNoNavigation
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL wMaintenanceNoNavigation wMaintenanceNoNavigation
ON END-ERROR OF wMaintenanceNoNavigation
OR ENDKEY OF {&WINDOW-NAME} ANYWHERE DO:
  /* This case occurs when the user presses the "Esc" key.
     In a persistently run window, just ignore this.  If we did not, the
     application would exit. */
  IF THIS-PROCEDURE:PERSISTENT THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL wMaintenanceNoNavigation wMaintenanceNoNavigation
ON WINDOW-CLOSE OF wMaintenanceNoNavigation
DO:
  /* This event will close the window and terminate the procedure.  */
  APPLY "CLOSE":U TO THIS-PROCEDURE.
  RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btCancel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btCancel wMaintenanceNoNavigation
ON CHOOSE OF btCancel IN FRAME fpage0 /* Cancelar */
DO:
    APPLY "CLOSE":U TO THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btHelp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btHelp wMaintenanceNoNavigation
ON CHOOSE OF btHelp IN FRAME fpage0 /* Ajuda */
DO:
    {include/ajuda.i}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btOK
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btOK wMaintenanceNoNavigation
ON CHOOSE OF btOK IN FRAME fpage0 /* OK */
DO:
    RUN saveRecord IN THIS-PROCEDURE.
    IF RETURN-VALUE = "OK":U THEN
        APPLY "CLOSE":U TO THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btSave
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btSave wMaintenanceNoNavigation
ON CHOOSE OF btSave IN FRAME fpage0 /* Salvar */
DO:
    RUN saveRecord IN THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-es-cesta-basica.nat-operacao
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-es-cesta-basica.nat-operacao wMaintenanceNoNavigation
ON F5 OF tt-es-cesta-basica.nat-operacao IN FRAME fpage0 /* Natureza */
DO:
    {method/ZoomFields.i &ProgramZoom="inzoom/z04in245.w"
                         &FieldZoom1="nat-operacao"
                         &FieldScreen1="tt-es-cesta-basica.nat-operacao"
                         &Frame1="fPage0"
                         &FieldZoom2="denominacao"
                         &FieldScreen2="c-desc-nat-operacao"
                         &Frame2="fPage0"
                         &EnableImplant="NO"}  
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-es-cesta-basica.nat-operacao wMaintenanceNoNavigation
ON LEAVE OF tt-es-cesta-basica.nat-operacao IN FRAME fpage0 /* Natureza */
DO:
    FIND natur-oper
        WHERE natur-oper.nat-operacao = INPUT FRAME {&FRAME-NAME} tt-es-cesta-basica.nat-operacao
        NO-LOCK NO-ERROR.
    ASSIGN c-desc-nat-operacao:SCREEN-VALUE IN FRAME {&FRAME-NAME} = IF AVAIL natur-oper THEN natur-oper.denominacao ELSE "".  
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-es-cesta-basica.nat-operacao wMaintenanceNoNavigation
ON MOUSE-SELECT-DBLCLICK OF tt-es-cesta-basica.nat-operacao IN FRAME fpage0 /* Natureza */
DO:
  APPLY "F5" TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-es-cesta-basica.tp-pedido
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-es-cesta-basica.tp-pedido wMaintenanceNoNavigation
ON F5 OF tt-es-cesta-basica.tp-pedido IN FRAME fpage0 /* Tipo Pedido */
DO:

    //run intprg/int115-zoom.w.

    assign l-implanta = no.
    {include/zoomvar.i &prog-zoom="intprg/int115-zoom.w"
                     &campo=tt-es-cesta-basica.tp-pedido
                     &campozoom=tp_pedido
                     &campo2=c-desc-tp-pedido
                     &campozoom2=descricao}

    //{method/ZoomFields.i &ProgramZoom="intprg/int115-zoom.w"
    //                     &FieldZoom1="tp_pedido"
    //                     &FieldScreen1="tt-es-cesta-basica.tp-pedido"
    //                     &Frame1="fPage0"
    //                     &EnableImplant="NO"}
  
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-es-cesta-basica.tp-pedido wMaintenanceNoNavigation
ON LEAVE OF tt-es-cesta-basica.tp-pedido IN FRAME fpage0 /* Tipo Pedido */
DO:
    FIND int_ds_tipo_pedido
        WHERE int_ds_tipo_pedido.tp_pedido = INPUT FRAME {&FRAME-NAME} tt-es-cesta-basica.tp-pedido
        NO-LOCK NO-ERROR.
    ASSIGN c-desc-tp-pedido:SCREEN-VALUE IN FRAME {&FRAME-NAME} = IF AVAIL int_ds_tipo_pedido THEN int_ds_tipo_pedido.descricao ELSE "".

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-es-cesta-basica.tp-pedido wMaintenanceNoNavigation
ON MOUSE-SELECT-DBLCLICK OF tt-es-cesta-basica.tp-pedido IN FRAME fpage0 /* Tipo Pedido */
DO:
  APPLY "F5" TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK wMaintenanceNoNavigation 


/*:T--- L¢gica para inicializa‡Æo do programam ---*/
{maintenancenonavigation/mainblock.i}

/*--- Seta cursor do mouse para lupa, quando estiver posicionado
      sobre o fill-in ---*/
tt-es-cesta-basica.tp-pedido:LOAD-MOUSE-POINTER("image/lupa.cur":U) IN FRAME fPage0.
tt-es-cesta-basica.nat-operacao:LOAD-MOUSE-POINTER("image/lupa.cur":U) IN FRAME fPage0.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE afterDisplayFields wMaintenanceNoNavigation 
PROCEDURE afterDisplayFields :
/*-----------------------------------------------------------------
  Purpose:     Override do m‚todo displayFields (after)
  Parameters:  
  Notes:       
-----------------------------------------------------------------*/
    
    APPLY "LEAVE":U TO tt-es-cesta-basica.tp-pedido IN FRAME fPage0.
    APPLY "LEAVE":U TO tt-es-cesta-basica.nat-operacao IN FRAME fPage0.

    RETURN "OK":U.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE afterSaveFields wMaintenanceNoNavigation 
PROCEDURE afterSaveFields :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    DEF BUFFER b-es-cesta-basica-item FOR es-cesta-basica-item.

    // Copia tamb‚m os itens da Cesta ao usar o botÆo Copiar
    IF  pcAction = "COPY" THEN DO:

        run utp/ut-msgs.p (input "show", 
                           input 27100, 
                           input "Copiar itens~~Deseja copiar tamb‚m os itens da lista?").
        IF  RETURN-VALUE = 'YES' THEN DO:
            FIND es-cesta-basica
                WHERE ROWID(es-cesta-basica) = prTable
                NO-LOCK NO-ERROR.
            IF  AVAIL es-cesta-basica    // registro origem
            AND AVAIL tt-es-cesta-basica // registro destino
            THEN DO:
                FOR EACH es-cesta-basica-item OF es-cesta-basica NO-LOCK:
                    CREATE b-es-cesta-basica-item.
                    ASSIGN b-es-cesta-basica-item.uf-origem  = tt-es-cesta-basica.uf-origem 
                           b-es-cesta-basica-item.uf-destino = tt-es-cesta-basica.uf-destino
                           b-es-cesta-basica-item.tp-pedido  = tt-es-cesta-basica.tp-pedido 
                           b-es-cesta-basica-item.it-codigo  = es-cesta-basica-item.it-codigo.                       
                END.
            END.
        END.
    END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE saveParentFields wMaintenanceNoNavigation 
PROCEDURE saveParentFields :
/*:T------------------------------------------------------------------------------
  Purpose:     Salva valores dos campos da tabela filho ({&ttTable}) com base 
               nos campos da tabela pai ({&ttParent})
  Parameters:  
  Notes:       Este m‚todo somente ‚ executado quando a vari vel pcAction 
               possuir os valores ADD ou COPY
------------------------------------------------------------------------------*/
    
    RETURN "OK":U.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

