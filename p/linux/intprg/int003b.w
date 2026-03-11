&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
          emsesp           ORACLE
*/
&Scoped-define WINDOW-NAME wMaintenanceNoNavigation


/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE tt-int_ds_ccusto_fundo_fixo NO-UNDO LIKE int_ds_ccusto_fundo_fixo
       fields r-rowid as rowid.
DEFINE TEMP-TABLE tt-int_ds_param_fundo_fixo NO-UNDO LIKE int_ds_param_fundo_fixo
       fields r-rowid as rowid.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS wMaintenanceNoNavigation 
/*:T*******************************************************************************
** Copyright DATASUL S.A. (1999)
** Todos os Direitos Reservados.
**
** Este fonte e de propriedade exclusiva da DATASUL, sua reproducao
** parcial ou total por qualquer meio, so podera ser feita mediante
** autorizacao expressa.
*******************************************************************************/

{include/i-prgvrs.i int003b 2.12.00.001}

CREATE WIDGET-POOL.

/* PrenNFrs Definitions ---                                      */
&GLOBAL-DEFINE Program           int003b
&GLOBAL-DEFINE Version           2.12.00.001

&GLOBAL-DEFINE Folder            YES
&GLOBAL-DEFINE InitialPage       1

&GLOBAL-DEFINE FolderLabels      CCusto.

&GLOBAL-DEFINE ttTable           tt-int_ds_ccusto_fundo_fixo
&GLOBAL-DEFINE hDBOTable         h-tt-int_ds_ccusto_fundo_fixo
&GLOBAL-DEFINE DBOTable          dbo-tt-int_ds_ccusto_fundo_fixo

&GLOBAL-DEFINE ttParent          tt-int_ds_param_fundo_fixo
&GLOBAL-DEFINE DBOParentTable    dbo-tt-int_ds_param_fundo_fixo

&GLOBAL-DEFINE page0KeyFields    tt-int_ds_param_fundo_fixo.cod_empresa 
&GLOBAL-DEFINE page0Fields       
&GLOBAL-DEFINE page0ParentFields tt-int_ds_param_fundo_fixo.cod_empresa 
&GLOBAL-DEFINE page1Fields       tt-int_ds_ccusto_fundo_fixo.cod_estab tt-int_ds_ccusto_fundo_fixo.cod_ccusto
&GLOBAL-DEFINE page1widgets      bt-zoom-cc  
    

DEFINE INPUT PARAMETER prTable         AS ROWID     NO-UNDO.
DEFINE INPUT PARAMETER prParent        AS ROWID     NO-UNDO.
DEFINE INPUT PARAMETER pcAction        AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER phCaller        AS HANDLE    NO-UNDO.
DEFINE INPUT PARAMETER piSonPageNumber AS INTEGER   NO-UNDO.


DEFINE VARIABLE {&hDBOTable}  AS HANDLE NO-UNDO.

def new global shared var v_cod_plano_ccusto_corren
    as character
    format "x(8)":U
    label "Plano CCusto"
    column-label "Plano CCusto"
    NO-UNDO.

def new global shared var v_rec_plano_ccusto
    as recid
    format ">>>>>>9":U
    no-undo.

DEFINE NEW GLOBAL SHARED VARIABLE adm-broker-hdl AS HANDLE NO-UNDO.
DEFINE VARIABLE wh-pesquisa AS HANDLE NO-UNDO.

def new global shared var v_rec_ccusto
    as recid
    format ">>>>>>9":U
    initial ?
    no-undo.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE MaintenanceNoNavigation
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME fpage0

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS tt-int_ds_param_fundo_fixo.cod_empresa 
&Scoped-define ENABLED-TABLES tt-int_ds_param_fundo_fixo
&Scoped-define FIRST-ENABLED-TABLE tt-int_ds_param_fundo_fixo
&Scoped-Define ENABLED-OBJECTS c-desc-empresa btOK btSave btCancel btHelp ~
rtKeys rtToolBar 
&Scoped-Define DISPLAYED-FIELDS tt-int_ds_param_fundo_fixo.cod_empresa 
&Scoped-define DISPLAYED-TABLES tt-int_ds_param_fundo_fixo
&Scoped-define FIRST-DISPLAYED-TABLE tt-int_ds_param_fundo_fixo
&Scoped-Define DISPLAYED-OBJECTS c-desc-empresa 

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

DEFINE VARIABLE c-desc-empresa AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 61 BY .88 NO-UNDO.

DEFINE RECTANGLE rtKeys
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 88 BY 1.71.

DEFINE RECTANGLE rtToolBar
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 90 BY 1.42
     BGCOLOR 7 .

DEFINE BUTTON bt-zoom-cc 
     IMAGE-UP FILE "image/toolbar/im-zoo.bmp":U
     LABEL "bt-zoom-cc" 
     SIZE 5 BY 1.

DEFINE VARIABLE c-desc-ccusto AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 46 BY .88 NO-UNDO.

DEFINE VARIABLE c-desc-estab AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 58.72 BY .88 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME fpage0
     tt-int_ds_param_fundo_fixo.cod_empresa AT ROW 1.71 COL 14 COLON-ALIGNED WIDGET-ID 36
          VIEW-AS FILL-IN 
          SIZE 6 BY .88
     c-desc-empresa AT ROW 1.71 COL 20.14 COLON-ALIGNED NO-LABEL WIDGET-ID 34
     btOK AT ROW 8.83 COL 2
     btSave AT ROW 8.83 COL 13
     btCancel AT ROW 8.83 COL 24
     btHelp AT ROW 8.83 COL 80
     rtKeys AT ROW 1.29 COL 2
     rtToolBar AT ROW 8.58 COL 1
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 90.57 BY 9.38
         FONT 1 WIDGET-ID 100.

DEFINE FRAME fPage1
     tt-int_ds_ccusto_fundo_fixo.cod_estab AT ROW 1.83 COL 13 COLON-ALIGNED WIDGET-ID 36
          VIEW-AS FILL-IN 
          SIZE 7 BY .88
     c-desc-estab AT ROW 1.83 COL 20.29 COLON-ALIGNED NO-LABEL WIDGET-ID 46
     bt-zoom-cc AT ROW 2.88 COL 29.57 WIDGET-ID 20
     tt-int_ds_ccusto_fundo_fixo.cod_ccusto AT ROW 2.96 COL 13 COLON-ALIGNED WIDGET-ID 48
          VIEW-AS FILL-IN 
          SIZE 14 BY .88
     c-desc-ccusto AT ROW 2.96 COL 33 COLON-ALIGNED NO-LABEL WIDGET-ID 50
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 2.14 ROW 4.25
         SIZE 87.86 BY 4.25
         FONT 1 WIDGET-ID 100.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: MaintenanceNoNavigation
   Allow: Basic,Browse,DB-Fields,Window,Query
   Add Fields to: Neither
   Other Settings: COMPILE
   Temp-Tables and Buffers:
      TABLE: tt-int_ds_ccusto_fundo_fixo T "?" NO-UNDO emsesp int_ds_ccusto_fundo_fixo
      ADDITIONAL-FIELDS:
          fields r-rowid as rowid
      END-FIELDS.
      TABLE: tt-int_ds_param_fundo_fixo T "?" NO-UNDO emsesp int_ds_param_fundo_fixo
      ADDITIONAL-FIELDS:
          fields r-rowid as rowid
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
         HEIGHT             = 9.42
         WIDTH              = 91.43
         MAX-HEIGHT         = 28.33
         MAX-WIDTH          = 195.14
         VIRTUAL-HEIGHT     = 28.33
         VIRTUAL-WIDTH      = 195.14
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
/* REPARENT FRAME */
ASSIGN FRAME fPage1:FRAME = FRAME fpage0:HANDLE.

/* SETTINGS FOR FRAME fpage0
   FRAME-NAME Custom                                                    */
/* SETTINGS FOR FRAME fPage1
                                                                        */
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

&ANALYZE-SUSPEND _QUERY-BLOCK FRAME fPage1
/* Query rebuild information for FRAME fPage1
     _Options          = "SHARE-LOCK KEEP-EMPTY"
     _Query            is NOT OPENED
*/  /* FRAME fPage1 */
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


&Scoped-define FRAME-NAME fPage1
&Scoped-define SELF-NAME bt-zoom-cc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-zoom-cc wMaintenanceNoNavigation
ON CHOOSE OF bt-zoom-cc IN FRAME fPage1 /* bt-zoom-cc */
DO:
   
    ASSIGN v_cod_plano_ccusto_corren = "PADRAO".

    find plano_ccusto NO-LOCK where 
         plano_ccusto.cod_empresa = i-ep-codigo-usuario AND  
         plano_ccusto.cod_plano_ccusto = v_cod_plano_ccusto_corren NO-ERROR.
               
    IF AVAIL plano_ccusto THEN
       ASSIGN v_rec_plano_ccusto = recid(plano_ccusto).
    ELSE 
       ASSIGN v_rec_plano_ccusto = ?.
             
    run prgint/utb/utb066na.p /*prg_see_ccusto_usuar*/.

    if  v_rec_ccusto <> ? 
    then do:
        find ems5.ccusto NO-LOCK where 
                  recid(ccusto) = v_rec_ccusto /*cl_rec_ccusto of tt_ccusto*/ no-error.
        if  avail ccusto
        then do:
           ASSIGN tt-int_ds_ccusto_fundo_fixo.cod_ccusto:SCREEN-VALUE IN FRAME fpage1 = ccusto.cod_ccusto
                  c-desc-ccusto:SCREEN-VALUE IN FRAME fpage1 = ccusto.des_tit_ctbl.
        END.
    END.
   
    apply "entry" to tt-int_ds_ccusto_fundo_fixo.cod_ccusto in frame fpage1.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME fpage0
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

    IF RETURN-VALUE = "OK":U THEN DO:
        RUN pi-reposiciona-filho IN phCaller.
        APPLY "CLOSE":U TO THIS-PROCEDURE.
    END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btSave
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btSave wMaintenanceNoNavigation
ON CHOOSE OF btSave IN FRAME fpage0 /* Salvar */
DO:
    RUN saveRecord IN THIS-PROCEDURE.
    RUN pi-reposiciona-filho IN phCaller.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME fPage1
&Scoped-define SELF-NAME tt-int_ds_ccusto_fundo_fixo.cod_ccusto
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-int_ds_ccusto_fundo_fixo.cod_ccusto wMaintenanceNoNavigation
ON F5 OF tt-int_ds_ccusto_fundo_fixo.cod_ccusto IN FRAME fPage1 /* Centro Custo */
DO:
  APPLY "choose" TO bt-zoom-cc.
 
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-int_ds_ccusto_fundo_fixo.cod_ccusto wMaintenanceNoNavigation
ON LEAVE OF tt-int_ds_ccusto_fundo_fixo.cod_ccusto IN FRAME fPage1 /* Centro Custo */
DO:
  
  find ems5.ccusto NO-LOCK where 
              ccusto.cod_empresa = i-ep-codigo-usuario AND
              ccusto.cod_plano_ccusto = "padrao"       AND 
              ccusto.cod_ccusto = INPUT FRAME fpage1 tt-int_ds_ccusto_fundo_fixo.cod_ccusto no-error.
  if avail ccusto
  then do:
      ASSIGN c-desc-ccusto:SCREEN-VALUE IN FRAME fpage1 = ccusto.des_tit_ctbl.
  END.
  ELSE 
      ASSIGN c-desc-ccusto:SCREEN-VALUE IN FRAME fpage1 = "".   

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-int_ds_ccusto_fundo_fixo.cod_ccusto wMaintenanceNoNavigation
ON MOUSE-SELECT-DBLCLICK OF tt-int_ds_ccusto_fundo_fixo.cod_ccusto IN FRAME fPage1 /* Centro Custo */
DO:
  APPLY "f5" TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME fpage0
&Scoped-define SELF-NAME tt-int_ds_param_fundo_fixo.cod_empresa
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-int_ds_param_fundo_fixo.cod_empresa wMaintenanceNoNavigation
ON LEAVE OF tt-int_ds_param_fundo_fixo.cod_empresa IN FRAME fpage0 /* Empresa */
DO:
    FIND FIRST ems2log.empresa NO-LOCK WHERE
             string(empresa.ep-codigo) =  tt-int_ds_param_fundo_fixo.cod_empresa:SCREEN-VALUE IN FRAME {&FRAME-NAME} NO-ERROR.
  IF AVAIL empresa  THEN
     ASSIGN c-desc-empresa:SCREEN-VALUE IN FRAME {&FRAME-NAME} = empresa.razao-social.
  ELSE 
     ASSIGN c-desc-empresa:SCREEN-VALUE IN FRAME {&FRAME-NAME} = "".


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME fPage1
&Scoped-define SELF-NAME tt-int_ds_ccusto_fundo_fixo.cod_estab
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-int_ds_ccusto_fundo_fixo.cod_estab wMaintenanceNoNavigation
ON F5 OF tt-int_ds_ccusto_fundo_fixo.cod_estab IN FRAME fPage1 /* Estabelecimento */
DO:

  {include/zoomvar.i &prog-zoom="adzoom/z01ad107.w"
                     &campo=tt-int_ds_ccusto_fundo_fixo.cod_estab
                     &campozoom=cod-estabel
                     &campo2=c-desc-estab
                     &campozoom2=nome}

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-int_ds_ccusto_fundo_fixo.cod_estab wMaintenanceNoNavigation
ON LEAVE OF tt-int_ds_ccusto_fundo_fixo.cod_estab IN FRAME fPage1 /* Estabelecimento */
DO:
  
     FIND FIRST estabelec NO-LOCK
        WHERE estabelec.cod-estabel = INPUT FRAME fpage1 tt-int_ds_ccusto_fundo_fixo.cod_estab NO-ERROR.
   IF AVAIL estabelec THEN
       ASSIGN c-desc-estab:SCREEN-VALUE IN FRAME fpage1 = estabelec.nome.
   ELSE 
       ASSIGN c-desc-estab:SCREEN-VALUE IN FRAME fpage1 = "".


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-int_ds_ccusto_fundo_fixo.cod_estab wMaintenanceNoNavigation
ON MOUSE-SELECT-DBLCLICK OF tt-int_ds_ccusto_fundo_fixo.cod_estab IN FRAME fPage1 /* Estabelecimento */
DO:
  APPLY "f5" TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME fpage0
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK wMaintenanceNoNavigation 


/*:T--- L¢gica para inicializa‡Æo do programam ---*/
{maintenancenonavigation/mainblock.i}

tt-int_ds_ccusto_fundo_fixo.cod_estab:load-mouse-pointer("image/lupa.cur":U) in frame fPage1.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE afterInitializeInterface wMaintenanceNoNavigation 
PROCEDURE afterInitializeInterface :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    IF pcAction <> "update" THEN DO:

        
    END.

    DISABLE tt-int_ds_param_fundo_fixo.cod_empresa c-desc-empresa WITH FRAME fpage0.

     ASSIGN bt-zoom-cc:SENSITIVE                            IN FRAME fpage1   = YES
             tt-int_ds_ccusto_fundo_fixo.cod_ccusto:SENSITIVE IN FRAME fpage1 = YES.
    
    APPLY 'leave' TO tt-int_ds_param_fundo_fixo.cod_empresa IN FRAME fpage0.

    APPLY 'leave' TO tt-int_ds_ccusto_fundo_fixo.cod_estab  IN FRAME fpage1.
    APPLY 'leave' TO tt-int_ds_ccusto_fundo_fixo.cod_ccusto IN FRAME fpage1.

    RETURN "ok".

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

    ASSIGN tt-int_ds_ccusto_fundo_fixo.cod_empresa  = tt-int_ds_param_fundo_fixo.cod_empresa.       
    
    RETURN "OK":U.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

