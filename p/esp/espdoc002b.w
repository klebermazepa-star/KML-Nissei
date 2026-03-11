&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
          custom           PROGRESS
*/
&Scoped-define WINDOW-NAME wMaintenanceNoNavigation


/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE tt-esp-tipo-doc NO-UNDO LIKE esp-tipo-doc
       field r-rowid as rowid.
DEFINE TEMP-TABLE tt-esp-tipo-doc-emitente NO-UNDO LIKE esp-tipo-doc-emitente
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
{include/i-prgvrs.i espdoc002b 1.00.00.001KML}

/* Chamada a include do gerenciador de licen‡as. Necessario alterar os parametros */
/*                                                                                */
/* <programa>:  Informar qual o nome do programa.                                 */
/* <m¢dulo>:  Informar qual o m¢dulo a qual o programa pertence.                  */

&IF "{&EMSFND_VERSION}" >= "1.00" &THEN
    {include/i-license-manager.i espdoc002b 1.00.00.001KML}
&ENDIF

CREATE WIDGET-POOL.

/* Preprocessors Definitions ---                                      */
&GLOBAL-DEFINE Program           espdoc002b
&GLOBAL-DEFINE Version           1.00.00.001KML

&GLOBAL-DEFINE Folder            no
&GLOBAL-DEFINE InitialPage       1

&GLOBAL-DEFINE FolderLabels      <Folder1 ,Folder 2 ,... , Folder8>

&GLOBAL-DEFINE ttTable           tt-esp-tipo-doc
&GLOBAL-DEFINE hDBOTable         hesp-tipo-doc
&GLOBAL-DEFINE DBOTable          dboesp-tipo-doc

&GLOBAL-DEFINE ttParent          tt-esp-tipo-doc-emitente
&GLOBAL-DEFINE DBOParentTable    dboesp-tipo-doc-emitente

&GLOBAL-DEFINE page0KeyFields    tt-esp-tipo-doc.tipo-documento
&GLOBAL-DEFINE page0Fields         tt-esp-tipo-doc.Descricao tt-esp-tipo-doc.obrigatorio tt-esp-tipo-doc.bloqueia-vendas tt-esp-tipo-doc.caminho-documento tt-esp-tipo-doc.Data-documento tt-esp-tipo-doc.Data-validade
&GLOBAL-DEFINE page0ParentFields 
&GLOBAL-DEFINE page1Fields       
&GLOBAL-DEFINE page2Fields       

//

/* Parameters Definitions ---                                           */
DEFINE INPUT PARAMETER prTable         AS ROWID     NO-UNDO.
DEFINE INPUT PARAMETER prParent        AS ROWID     NO-UNDO.
DEFINE INPUT PARAMETER pcAction        AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER phCaller        AS HANDLE    NO-UNDO.
DEFINE INPUT PARAMETER piSonPageNumber AS INTEGER   NO-UNDO.

/* Local Variable Definitions ---                                       */

/* Local Variable Definitions (DBOs Handles) --- */
DEFINE VARIABLE {&hDBOTable}  AS HANDLE NO-UNDO.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE MaintenanceNoNavigation
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME fpage0

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS tt-esp-tipo-doc.tipo-documento ~
tt-esp-tipo-doc.Data-validade tt-esp-tipo-doc.Data-documento ~
tt-esp-tipo-doc.caminho-documento 
&Scoped-define ENABLED-TABLES tt-esp-tipo-doc
&Scoped-define FIRST-ENABLED-TABLE tt-esp-tipo-doc
&Scoped-Define ENABLED-OBJECTS rtKeys rtToolBar BUTTON-1 btOK btSave ~
btCancel btHelp 
&Scoped-Define DISPLAYED-FIELDS tt-esp-tipo-doc.tipo-documento ~
tt-esp-tipo-doc.Descricao tt-esp-tipo-doc.Data-validade ~
tt-esp-tipo-doc.Data-documento tt-esp-tipo-doc.caminho-documento ~
tt-esp-tipo-doc.obrigatorio tt-esp-tipo-doc.bloqueia-vendas 
&Scoped-define DISPLAYED-TABLES tt-esp-tipo-doc
&Scoped-define FIRST-DISPLAYED-TABLE tt-esp-tipo-doc


/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR wMaintenanceNoNavigation AS WIDGET-HANDLE NO-UNDO.

/* Definitions of the field level widgets                               */
DEFINE BUTTON btCancel 
     LABEL "Cancelar" 
     SIZE 10 BY 1.

DEFINE BUTTON btHelp 
     LABEL "Ajuda" 
     SIZE 10 BY 1.

DEFINE BUTTON btOK 
     LABEL "OK" 
     SIZE 10 BY 1.

DEFINE BUTTON btSave 
     LABEL "Salvar" 
     SIZE 10 BY 1.

DEFINE BUTTON BUTTON-1 
     IMAGE-UP FILE "adeicon/prevw-u.bmp":U
     LABEL "Button 1" 
     SIZE 4 BY 1.

DEFINE RECTANGLE rtKeys
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 90 BY 2.25.

DEFINE RECTANGLE rtToolBar
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 90 BY 1.42
     BGCOLOR 7 .


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME fpage0
     tt-esp-tipo-doc.tipo-documento AT ROW 1.75 COL 15 COLON-ALIGNED WIDGET-ID 8
          LABEL "Tipo Documento"
          VIEW-AS FILL-IN 
          SIZE 20 BY .79
     tt-esp-tipo-doc.Descricao AT ROW 4 COL 9.28 WIDGET-ID 16
          VIEW-AS FILL-IN 
          SIZE 65 BY .79
     tt-esp-tipo-doc.Data-validade AT ROW 5.25 COL 15 COLON-ALIGNED WIDGET-ID 24
          LABEL "DataValidade"
          VIEW-AS FILL-IN 
          SIZE 10 BY .79
     tt-esp-tipo-doc.Data-documento AT ROW 6.25 COL 15 COLON-ALIGNED WIDGET-ID 22
          LABEL "Data Documento"
          VIEW-AS FILL-IN 
          SIZE 10 BY .79
     BUTTON-1 AT ROW 7.13 COL 74 WIDGET-ID 26
     tt-esp-tipo-doc.caminho-documento AT ROW 7.25 COL 2 WIDGET-ID 20
          LABEL "Caminho Documento"
          VIEW-AS FILL-IN 
          SIZE 56 BY .79
     tt-esp-tipo-doc.obrigatorio AT ROW 8.5 COL 17 WIDGET-ID 18
          LABEL "Obrigatorio"
          VIEW-AS TOGGLE-BOX
          SIZE 16 BY .83
     tt-esp-tipo-doc.bloqueia-vendas AT ROW 9.75 COL 17 WIDGET-ID 14
          LABEL "Bloqueia Vendas"
          VIEW-AS TOGGLE-BOX
          SIZE 17 BY .83
     btOK AT ROW 11.25 COL 2
     btSave AT ROW 11.25 COL 13
     btCancel AT ROW 11.25 COL 24
     btHelp AT ROW 11.25 COL 80
     rtKeys AT ROW 1 COL 1
     rtToolBar AT ROW 11 COL 1
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 90 BY 11.42
         FONT 1 WIDGET-ID 100.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: MaintenanceNoNavigation
   Allow: Basic,Browse,DB-Fields,Window,Query
   Add Fields to: Neither
   Other Settings: COMPILE
   Temp-Tables and Buffers:
      TABLE: tt-esp-tipo-doc T "?" NO-UNDO custom esp-tipo-doc
      ADDITIONAL-FIELDS:
          field r-rowid as rowid
      END-FIELDS.
      TABLE: tt-esp-tipo-doc-emitente T "?" NO-UNDO custom esp-tipo-doc-emitente
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
         HEIGHT             = 11.42
         WIDTH              = 90
         MAX-HEIGHT         = 41
         MAX-WIDTH          = 274.29
         VIRTUAL-HEIGHT     = 41
         VIRTUAL-WIDTH      = 274.29
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
/* SETTINGS FOR TOGGLE-BOX tt-esp-tipo-doc.bloqueia-vendas IN FRAME fpage0
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN tt-esp-tipo-doc.caminho-documento IN FRAME fpage0
   ALIGN-L EXP-LABEL                                                    */
/* SETTINGS FOR FILL-IN tt-esp-tipo-doc.Data-documento IN FRAME fpage0
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-esp-tipo-doc.Data-validade IN FRAME fpage0
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-esp-tipo-doc.Descricao IN FRAME fpage0
   NO-ENABLE ALIGN-L                                                    */
/* SETTINGS FOR TOGGLE-BOX tt-esp-tipo-doc.obrigatorio IN FRAME fpage0
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN tt-esp-tipo-doc.tipo-documento IN FRAME fpage0
   EXP-LABEL                                                            */
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


&Scoped-define SELF-NAME BUTTON-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BUTTON-1 wMaintenanceNoNavigation
ON CHOOSE OF BUTTON-1 IN FRAME fpage0 /* Button 1 */
DO:
  def var cFile as char no-undo.
    def var l-ok  as logical no-undo.

    assign tt-esp-tipo-doc.caminho-documento = replace(input frame {&frame-name} tt-esp-tipo-doc.caminho-documento, "/", "~\").
    SYSTEM-DIALOG GET-FILE cFile
       FILTERS "*.*" "*.*"
       DEFAULT-EXTENSION "*.*"
       INITIAL-DIR "modelos" 
       MUST-EXIST
       USE-FILENAME
       UPDATE l-ok.
    if  l-ok = yes then
        assign tt-esp-tipo-doc.caminho-documento:screen-value in frame {&frame-name}  = replace(cFile, "~\", "/"). 
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-esp-tipo-doc.tipo-documento
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-esp-tipo-doc.tipo-documento wMaintenanceNoNavigation
ON F5 OF tt-esp-tipo-doc.tipo-documento IN FRAME fpage0 /* Tipo Documento */
DO:



  {method/ZoomFields.i &ProgramZoom="esp/zoomespdoc001.w"

                         &FieldZoom1="tipo-documento"
                         &FieldScreen1="tt-esp-tipo-doc.tipo-documento"
                         &Frame1="fPage0"
                        
                         &EnableImplant="YES"}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-esp-tipo-doc.tipo-documento wMaintenanceNoNavigation
ON LEAVE OF tt-esp-tipo-doc.tipo-documento IN FRAME fpage0 /* Tipo Documento */
DO:

    find first custom.esp-tipo-documento no-lock
      WHERE esp-tipo-documento.tipo-documento = tt-esp-tipo-doc.tipo-documento:SCREEN-VALUE no-error.
      
   if avail esp-tipo-documento then do:
   
      ASSIGN  tt-esp-tipo-doc.Descricao:SENSITIVE IN FRAME fpage0 = NO
        tt-esp-tipo-doc.obrigatorio:SENSITIVE IN FRAME fpage0 = NO
        tt-esp-tipo-doc.bloqueia-vendas:SENSITIVE IN FRAME fpage0 = NO.
   
      assign tt-esp-tipo-doc.Descricao:screen-value in frame fpage0 = esp-tipo-documento.Descricao.
      
      IF esp-tipo-documento.obrigatorio = YES THEN
      DO:
      
        ASSIGN tt-esp-tipo-doc.obrigatorio:CHECKED in frame fpage0 = TRUE.
          
      END.
      ELSE DO:
        
        ASSIGN tt-esp-tipo-doc.obrigatorio:CHECKED in frame fpage0 = FALSE.
      
      END.
      
      IF esp-tipo-documento.bloqueia-vendas = YES THEN
      DO:
      
        ASSIGN tt-esp-tipo-doc.bloqueia-vendas:CHECKED in frame fpage0 = TRUE .
          
      END.
      ELSE DO:
      
        ASSIGN tt-esp-tipo-doc.bloqueia-vendas:CHECKED in frame fpage0 = FALSE.
      
      END.
      

   end.
   else do:
   
      assign tt-esp-tipo-doc.Descricao:screen-value in frame fpage0  = "".
      
   end.
  
END.

/*

---------------------------
Warning (Press HELP to view stack trace)
---------------------------
**Attribute SCREEN-VALUE for the TOGGLE-BOX obrigatorio has an invalid value of YES. (4058)
---------------------------
OK   Help   
---------------------------

Table: esp-tipo-documento

Field Name                  Data Type  Flg Format
--------------------------- ---------- --- --------------------------------
tipo-documento              char       i   x(50)
Descricao                   char           x(150)
obrigatorio                 logi           sim/nao
bloqueia-vendas             logi           sim/nao
*/

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-esp-tipo-doc.tipo-documento wMaintenanceNoNavigation
ON MOUSE-SELECT-DBLCLICK OF tt-esp-tipo-doc.tipo-documento IN FRAME fpage0 /* Tipo Documento */
DO:
    APPLY "F5" TO SELF. 
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK wMaintenanceNoNavigation 


/*:T--- L¢gica para inicializa‡Æo do programam ---*/
{maintenancenonavigation/mainblock.i}

tt-esp-tipo-doc.tipo-documento:load-mouse-pointer("image/lupa.cur":U)  in frame fPage0.

ASSIGN  BUTTON-1:SENSITIVE IN FRAME fpage0 = YES
        tt-esp-tipo-doc.Descricao:SENSITIVE IN FRAME fpage0 = NO
        tt-esp-tipo-doc.obrigatorio:SENSITIVE IN FRAME fpage0 = NO
        tt-esp-tipo-doc.bloqueia-vendas:SENSITIVE IN FRAME fpage0 = NO.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE saveParentFields wMaintenanceNoNavigation 
PROCEDURE saveParentFields :
/*:T------------------------------------------------------------------------------
  Purpose:     Salva valores dos campos da tabela filho ({&ttTable}) com base 
               nos campos da tabela pai ({&ttParent})
  Parameters:  
  Notes:       Este m‚todo somente ‚ executado quando a vari vel pcAction 
               possuir os valores ADD ou COPY
------------------------------------------------------------------------------*/
    ASSIGN tt-esp-tipo-doc.cod-emitente = tt-esp-tipo-doc-emitente.cod-emitente.
    RETURN "OK":U.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

