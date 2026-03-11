&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
          ems2mult         PROGRESS
          mgesp            PROGRESS
*/
&Scoped-define WINDOW-NAME wMaintenanceNoNavigation


/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE ttestabelec NO-UNDO LIKE estabelec
       field r-rowid as rowid.
DEFINE TEMP-TABLE ttint-ds-natur-oper NO-UNDO LIKE int-ds-natur-oper
       field r-rowid as rowid.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS wMaintenanceNoNavigation 
/********************************************************************************
** Copyright DATASUL S.A. (1999)
** Todos os Direitos Reservados.
**
** Este fonte e de propriedade exclusiva da DATASUL, sua reproducao
** parcial ou total por qualquer meio, so podera ser feita mediante
** autorizacao expressa.
*******************************************************************************/
/*******************************************************************************
**
** Programa: INT013a
** Objetivo: Manuten‡Æo Naturezas de Opera‡Æo Datasul X Sysfarma
** 
** Parƒmetros:
** Especificidades:
** 
** Autor: Alessandro V Baccin
** Data: 15/02/2016
**
*******************************************************************************/
{include/i-prgvrs.i INT013a 2.12.01.AVB}

CREATE WIDGET-POOL.

/* Preprocessors Definitions ---                                      */
&GLOBAL-DEFINE Program        INT013a
&GLOBAL-DEFINE Version        2.12.01.AVB

&GLOBAL-DEFINE Folder         no
&GLOBAL-DEFINE InitialPage    1

&GLOBAL-DEFINE FolderLabels   

&GLOBAL-DEFINE ttTable        ttint-ds-natur-oper
&GLOBAL-DEFINE hDBOTable      hDBOint-ds-natur-oper
&GLOBAL-DEFINE DBOTable       int-ds-natur-oper
&GLOBAL-DEFINE DBOProgram     intprg/boint-ds-natur-oper.p

&GLOBAL-DEFINE ttParent       ttestabelec

&GLOBAL-DEFINE page0KeyFields ttint-ds-natur-oper.cod-emitente ttint-ds-natur-oper.dt-inicio-validade ttint-ds-natur-oper.nen-cfop-n ttint-ds-natur-oper.nep-cstb-n
&GLOBAL-DEFINE page0ParentFields    ttestabelec.cod-estabel ttestabelec.estado ttestabelec.nome
&GLOBAL-DEFINE page0Fields    
&GLOBAL-DEFINE page1Fields    ttint-ds-natur-oper.nat-operacao
/*
&GLOBAL-DEFINE DBOVersion 1.1
*/

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */

/* Local Variable Definitions (DBOs Handles) --- */
DEFINE VARIABLE {&hDBOTable} AS HANDLE NO-UNDO.

/* Definir se este programa ‚ de tabela filha */
&SCOPED-DEFINE isSon yes

/* Definir chaves estrangeiras a serem atualizados no Son vindo de Parent */    
    &SCOPED-DEFINE ParentKey1 cod-estabel

/* Parameters Definitions ---                                           */
DEFINE INPUT PARAMETER prTable         AS ROWID     NO-UNDO.

&IF DEFINED(isSon) <> 0 &THEN
    DEFINE INPUT PARAMETER prParent        AS ROWID     NO-UNDO.
&ENDIF

DEFINE INPUT PARAMETER pcAction        AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER phCaller        AS HANDLE    NO-UNDO.

&IF DEFINED(isSon) <> 0 &THEN
    DEFINE INPUT PARAMETER piSonPageNumber AS INTEGER   NO-UNDO.
&ENDIF


/* Defini‡äes p/ Chaves Estrangeiras */
&SCOPED-DEFINE ttExtTable1              ttnatur-oper        /* tabela temporaria */
&SCOPED-DEFINE hDBOExtTable1            hDBOnatur-oper      /* handle do DBO */
&SCOPED-DEFINE DBOExtTable1             natur-oper          /* tabela do banco de dados a ser buscada */
&SCOPED-DEFINE ExtKey1                  nat-operacao        /* campo chave da tabela a buscar */
&SCOPED-DEFINE ReturnExtTable1          denominacao         /* campo a ser retornado pelo zoom */
&SCOPED-DEFINE ScreenExtTable1          {&ttTable}                  /* tabela da tela aonde sera aplicado o leave da chave */
&SCOPED-DEFINE ScreenExtKey1            {&ExtKey1}                  /* campo da tela aonde sera aplicado o leave da chave */
&SCOPED-DEFINE ScreenDescriptionExt1    c{&ReturnExtTable1}         /* campo em tela que recebera o retorno */
&SCOPED-DEFINE DBOExtProgram1           intprg/boint-ds-natur-oper.p /* programa bo da tabela do banco de dados */
&SCOPED-DEFINE ProgramZoom1             dizoom/z01in245.w            /* programa zoom da tabela do banco de dados */
&SCOPED-DEFINE Frame1                   fPage1                       /* frame aonde estao os campos chave e descricao */

DEFINE VARIABLE {&hDBOExtTable1} AS HANDLE NO-UNDO.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE MaintenanceNoNavigation
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME fpage0

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS ttestabelec.cod-estabel ttestabelec.nome ~
ttestabelec.estado ttint-ds-natur-oper.cod-emitente ~
ttint-ds-natur-oper.nen-cfop-n ttint-ds-natur-oper.nep-cstb-n ~
ttint-ds-natur-oper.dt-inicio-validade 
&Scoped-define ENABLED-TABLES ttestabelec ttint-ds-natur-oper
&Scoped-define FIRST-ENABLED-TABLE ttestabelec
&Scoped-define SECOND-ENABLED-TABLE ttint-ds-natur-oper
&Scoped-Define ENABLED-OBJECTS rtKeys rtToolBar btOK btSave btCancel btHelp 
&Scoped-Define DISPLAYED-FIELDS ttestabelec.cod-estabel ttestabelec.nome ~
ttestabelec.estado ttint-ds-natur-oper.cod-emitente ~
ttint-ds-natur-oper.nen-cfop-n ttint-ds-natur-oper.nep-cstb-n ~
ttint-ds-natur-oper.dt-inicio-validade 
&Scoped-define DISPLAYED-TABLES ttestabelec ttint-ds-natur-oper
&Scoped-define FIRST-DISPLAYED-TABLE ttestabelec
&Scoped-define SECOND-DISPLAYED-TABLE ttint-ds-natur-oper


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

DEFINE RECTANGLE rtKeys
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 90 BY 3.5.

DEFINE RECTANGLE rtToolBar
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 90 BY 1.42
     BGCOLOR 7 .

DEFINE VARIABLE Cdenominacao AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 55 BY .79 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME fpage0
     ttestabelec.cod-estabel AT ROW 1.17 COL 15 COLON-ALIGNED WIDGET-ID 2
          VIEW-AS FILL-IN 
          SIZE 5 BY .88
     ttestabelec.nome AT ROW 1.17 COL 20 COLON-ALIGNED NO-LABEL WIDGET-ID 6
          VIEW-AS FILL-IN 
          SIZE 53 BY .88
     ttestabelec.estado AT ROW 1.17 COL 73 COLON-ALIGNED NO-LABEL WIDGET-ID 4
          VIEW-AS FILL-IN 
          SIZE 4 BY .88
     ttint-ds-natur-oper.cod-emitente AT ROW 2.17 COL 15 COLON-ALIGNED WIDGET-ID 8
          VIEW-AS FILL-IN 
          SIZE 10 BY .88
     ttint-ds-natur-oper.nen-cfop-n AT ROW 3.17 COL 15 COLON-ALIGNED WIDGET-ID 12
          VIEW-AS FILL-IN 
          SIZE 6 BY .79
     ttint-ds-natur-oper.nep-cstb-n AT ROW 3.17 COL 42 COLON-ALIGNED WIDGET-ID 14
          VIEW-AS FILL-IN 
          SIZE 4 BY .79
     ttint-ds-natur-oper.dt-inicio-validade AT ROW 3.17 COL 68 COLON-ALIGNED WIDGET-ID 10
          VIEW-AS FILL-IN 
          SIZE 9.29 BY .79
     btOK AT ROW 8 COL 2
     btSave AT ROW 8 COL 13
     btCancel AT ROW 8 COL 24
     btHelp AT ROW 8 COL 80
     rtKeys AT ROW 1 COL 1
     rtToolBar AT ROW 7.75 COL 1
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 90 BY 8.75
         FONT 1 WIDGET-ID 100.

DEFINE FRAME fPage1
     ttint-ds-natur-oper.nat-operacao AT ROW 1.5 COL 13 COLON-ALIGNED WIDGET-ID 2
          VIEW-AS FILL-IN 
          SIZE 7 BY .79
     Cdenominacao AT ROW 1.5 COL 20 COLON-ALIGNED NO-LABEL WIDGET-ID 4
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 3.57 ROW 5
         SIZE 84.43 BY 2.25
         FONT 1 WIDGET-ID 100.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: MaintenanceNoNavigation
   Allow: Basic,Browse,DB-Fields,Window,Query
   Add Fields to: Neither
   Other Settings: COMPILE
   Temp-Tables and Buffers:
      TABLE: ttestabelec T "?" NO-UNDO ems2mult estabelec
      ADDITIONAL-FIELDS:
          field r-rowid as rowid
      END-FIELDS.
      TABLE: ttint-ds-natur-oper T "?" NO-UNDO mgesp int-ds-natur-oper
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
         HEIGHT             = 8.63
         WIDTH              = 90
         MAX-HEIGHT         = 17.58
         MAX-WIDTH          = 90
         VIRTUAL-HEIGHT     = 17.58
         VIRTUAL-WIDTH      = 90
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
   FRAME-NAME                                                           */
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
    RUN validateRecord.
    if return-value = "OK" then do:
        RUN saveRecord IN THIS-PROCEDURE.
        IF RETURN-VALUE = "OK":U THEN
            APPLY "CLOSE":U TO THIS-PROCEDURE.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btSave
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btSave wMaintenanceNoNavigation
ON CHOOSE OF btSave IN FRAME fpage0 /* Salvar */
DO:
    RUN validateRecord.
    if return-value = "OK" then do:
        RUN saveRecord IN THIS-PROCEDURE.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK wMaintenanceNoNavigation 


/* Procedure p/ Carga de Ponteiros de Mouse p/ Zoom */
RUN setMousePointers IN THIS-PROCEDURE.
/* ZOOM do Campo Chave */
&IF defined(ttExtTable1) &THEN
ON "MOUSE-SELECT-DBLCLICK":U, "F5":U OF {&ScreenExtTable1}.{&ScreenExtKey1}  in frame {&Frame1}
DO:
    {method/ZoomFields.i &ProgramZoom="{&ProgramZoom1}"                 /* programa zoom da tabela do banco de dados */
                         &FieldZoom1="{&ExtKey1}"                       /* campo chave da tabela a buscar - recebera leave */
                         &FieldScreen1="{&ScreenExtTable1}.{&ScreenExtKey1}"  /* aonde sera aplicado o leave da chave */
                         &Frame1="{&Frame1}"                            /* frame aonde estao os campos chave e descricao */
                         &FieldZoom2="{&ReturnExtTable1}"               /* campo a ser retornado pelo zoom */    
                         &FieldScreen2="{&ScreenDescriptionExt1}"       /* campo em tela que recebera o retorno */
                         &Frame2="{&Frame1}"                            /* frame aonde estao os campos chave e descricao */
                         &EnableImplant="NO"}                           /* nao permitir implantacao */

END.
                                              
ON 'LEAVE':U OF {&ScreenExtTable1}.{&ScreenExtKey1}  in frame {&Frame1}
DO:
    for first {&DBOExtTable1} 
        fields ({&ExtKey1} {&ReturnExtTable1})
        no-lock where
        {&DBOExtTable1}.{&ExtKey1} = input frame {&Frame1} {&ScreenExtTable1}.{&ScreenExtKey1}:
        assign {&ScreenDescriptionExt1}:screen-value in frame {&Frame1} = string({&DBOExtTable1}.{&ReturnExtTable1}).
    end.

END.
&ENDIF

&IF defined(ttExtTable2) &THEN
ON "MOUSE-SELECT-DBLCLICK":U, "F5":U OF {&ScreenExtTable2}.{&ScreenExtKey2}  in frame {&Frame2}
DO:
    {method/ZoomFields.i &ProgramZoom="{&ProgramZoom2}"                 /* programa zoom da tabela do banco de dados */
                         &FieldZoom1="{&ExtKey2}"                       /* campo chave da tabela a buscar - recebera leave */
                         &FieldScreen1="{&ScreenExtTable2}.{&ScreenExtKey2}"  /* aonde sera aplicado o leave da chave */
                         &Frame1="{&Frame2}"                            /* frame aonde estao os campos chave e descricao */
                         &FieldZoom2="{&ReturnExtTable2}"               /* campo a ser retornado pelo zoom */    
                         &FieldScreen2="{&ScreenDescriptionExt2}"       /* campo em tela que recebera o retorno */
                         &Frame2="{&Frame2}"                            /* frame aonde estao os campos chave e descricao */
                         &EnableImplant="NO"}                           /* nao permitir implantacao */

END.
                                              
ON 'LEAVE':U OF {&ScreenExtTable2}.{&ScreenExtKey2}  in frame {&Frame2}
DO:
    for first {&DBOExtTable2} 
        fields ({&ExtKey2} {&ReturnExtTable2})
        no-lock where
        {&DBOExtTable2}.{&ExtKey2} = input frame {&Frame2} {&ScreenExtTable2}.{&ScreenExtKey2}:
        assign {&ScreenDescriptionExt2}:screen-value in frame {&Frame2} = string({&DBOExtTable2}.{&ReturnExtTable2}).
    end.

END.
&ENDIF

&IF defined(ttExtTable3) &THEN
ON "MOUSE-SELECT-DBLCLICK":U, "F5":U OF {&ScreenExtTable3}.{&ScreenExtKey3}  in frame {&Frame3}
DO:
    {method/ZoomFields.i &ProgramZoom="{&ProgramZoom3}"                 /* programa zoom da tabela do banco de dados */
                         &FieldZoom1="{&ExtKey3}"                       /* campo chave da tabela a buscar - recebera leave */
                         &FieldScreen1="{&ScreenExtTable3}.{&ScreenExtKey3}"  /* aonde sera aplicado o leave da chave */
                         &Frame1="{&Frame3}"                            /* frame aonde estao os campos chave e descricao */
                         &FieldZoom2="{&ReturnExtTable3}"               /* campo a ser retornado pelo zoom */    
                         &FieldScreen2="{&ScreenDescriptionExt3}"       /* campo em tela que recebera o retorno */
                         &Frame2="{&Frame3}"                            /* frame aonde estao os campos chave e descricao */
                         &EnableImplant="NO"}                           /* nao permitir implantacao */

END.
                                              
ON 'LEAVE':U OF {&ScreenExtTable3}.{&ScreenExtKey3}  in frame {&Frame3}
DO:
    for first {&DBOExtTable3} 
        fields ({&ExtKey3} {&ReturnExtTable3})
        no-lock where
        {&DBOExtTable3}.{&ExtKey3} = input frame {&Frame3} {&ScreenExtTable3}.{&ScreenExtKey3}:
        assign {&ScreenDescriptionExt3}:screen-value in frame {&Frame3} = string({&DBOExtTable2}.{&ReturnExtTable3}).
    end.

END.
&ENDIF

&IF defined(ttExtTable4) &THEN
ON "MOUSE-SELECT-DBLCLICK":U, "F5":U OF {&ScreenExtTable4}.{&ScreenExtKey4}  in frame {&Frame4}
DO:
    {method/ZoomFields.i &ProgramZoom="{&ProgramZoom4}"                 /* programa zoom da tabela do banco de dados */
                         &FieldZoom1="{&ExtKey4}"                       /* campo chave da tabela a buscar - recebera leave */
                         &FieldScreen1="{&ScreenExtTable4}.{&ScreenExtKey4}"  /* aonde sera aplicado o leave da chave */
                         &Frame1="{&Frame4}"                            /* frame aonde estao os campos chave e descricao */
                         &FieldZoom2="{&ReturnExtTable4}"               /* campo a ser retornado pelo zoom */    
                         &FieldScreen2="{&ScreenDescriptionExt4}"       /* campo em tela que recebera o retorno */
                         &Frame2="{&Frame4}"                            /* frame aonde estao os campos chave e descricao */
                         &EnableImplant="NO"}                           /* nao permitir implantacao */

END.
                                              
ON 'LEAVE':U OF {&ScreenExtTable4}.{&ScreenExtKey4}  in frame {&Frame4}
DO:
    for first {&DBOExtTable4} 
        fields ({&ExtKey4} {&ReturnExtTable4})
        no-lock where
        {&DBOExtTable4}.{&ExtKey4} = input frame {&Frame4} {&ScreenExtTable4}.{&ScreenExtKey4}:
        assign {&ScreenDescriptionExt4}:screen-value in frame {&Frame4} = string({&DBOExtTable2}.{&ReturnExtTable4}).
    end.

END.
&ENDIF

/*--- L¢gica para inicializa‡Æo do programam ---*/
{maintenancenonavigation/MainBlock.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE afterDestroyInterface wMaintenanceNoNavigation 
PROCEDURE afterDestroyInterface :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    &IF DEFINED (hDBOExtTable1) &THEN
        IF VALID-HANDLE({&hDBOExtTable1}) THEN RUN destroy IN {&hDBOExtTable1}.
    &ENDIF
    &IF DEFINED (hDBOExtTable2) &THEN
        IF VALID-HANDLE({&hDBOExtTable2}) THEN RUN destroy IN {&hDBOExtTable2}.
    &ENDIF
    &IF DEFINED (hDBOExtTable3) &THEN
        IF VALID-HANDLE({&hDBOExtTable3}) THEN RUN destroy IN {&hDBOExtTable3}.
    &ENDIF
    &IF DEFINED (hDBOExtTable4) &THEN
        IF VALID-HANDLE({&hDBOExtTable4}) THEN RUN destroy IN {&hDBOExtTable4}.
    &ENDIF
    &IF DEFINED (hDBOExtTable5) &THEN
        IF VALID-HANDLE({&hDBOExtTable5}) THEN RUN destroy IN {&hDBOExtTable5}.
    &ENDIF
    &IF DEFINED (hDBOExtTable6) &THEN
        IF VALID-HANDLE({&hDBOExtTable6}) THEN RUN destroy IN {&hDBOExtTable6}.
    &ENDIF

    RETURN "OK":U.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE afterDisplayFields wMaintenanceNoNavigation 
PROCEDURE afterDisplayFields :
/*-----------------------------------------------------------------
  Purpose:     Override do m‚todo displayFields (after)
  Parameters:  
  Notes:       
-----------------------------------------------------------------*/
&IF DEFINED(ExtKey1) <> 0 &THEN
        APPLY "LEAVE":U TO {&ScreenExtTable1}.{&ScreenExtKey1} IN FRAME {&Frame1}.
    &ENDIF
    &IF DEFINED(ExtKey2) <> 0 &THEN
        APPLY "LEAVE":U TO {&ScreenExtTable2}.{&ScreenExtKey2} IN FRAME {&Frame2}.
    &ENDIF
    &IF DEFINED(ExtKey3) <> 0 &THEN
        APPLY "LEAVE":U TO {&ScreenExtTable3}.{&ScreenExtKey3} IN FRAME {&Frame3}.
    &ENDIF
    &IF DEFINED(ExtKey4) <> 0 &THEN
        APPLY "LEAVE":U TO {&ScreenExtTable4}.{&ScreenExtKey4} IN FRAME {&Frame4}.
    &ENDIF
    &IF DEFINED(ExtKey5) <> 0 &THEN
        APPLY "LEAVE":U TO {&ScreenExtTable5}.{&ScreenExtKey5} IN FRAME {&Frame5}.
    &ENDIF
    &IF DEFINED(ExtKey6) <> 0 &THEN
        APPLY "LEAVE":U TO {&ScreenExtTable6}.{&ScreenExtKey6} IN FRAME {&Frame6}.
    &ENDIF
   
    RETURN "OK":U.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE AfterInitializeInterface wMaintenanceNoNavigation 
PROCEDURE AfterInitializeInterface :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

/* DBO's de Chaves Estrangeiras */
    &IF DEFINED(hDBOExtTable1) <> 0 &THEN
        IF NOT VALID-HANDLE({&hDBOExtTable1}) OR
           {&hDBOTable}:TYPE <> "PROCEDURE":U OR
           {&hDBOTable}:FILE-NAME <> "{&DBOExtProgram1}":U THEN DO:
            {btb/btb008za.i1 {&DBOExtProgram1} YES}
            {btb/btb008za.i2 {&DBOExtProgram1} '' {&hDBOExtTable1}}
        END.
        RUN openQueryStatic IN {&hDBOExtTable1} (INPUT "Main":U) NO-ERROR.
    &ENDIF
    &IF DEFINED(hDBOExtTable2) <> 0 &THEN
        IF NOT VALID-HANDLE({&hDBOExtTable2}) OR
           {&hDBOTable}:TYPE <> "PROCEDURE":U OR
           {&hDBOTable}:FILE-NAME <> "{&DBOExtProgram2}":U THEN DO:
            {btb/btb008za.i1 {&DBOExtProgram2} YES}
            {btb/btb008za.i2 {&DBOExtProgram2} '' {&hDBOExtTable2}}
        END.
        RUN openQueryStatic IN {&hDBOExtTable2} (INPUT "Main":U) NO-ERROR.
    &ENDIF
    &IF DEFINED(hDBOExtTable3) <> 0 &THEN
        IF NOT VALID-HANDLE({&hDBOExtTable3}) OR
           {&hDBOTable}:TYPE <> "PROCEDURE":U OR
           {&hDBOTable}:FILE-NAME <> "{&DBOExtProgram3}":U THEN DO:
            {btb/btb008za.i1 {&DBOExtProgram3} YES}
            {btb/btb008za.i2 {&DBOExtProgram3} '' {&hDBOExtTable3}}
        END.
        RUN openQueryStatic IN {&hDBOExtTable3} (INPUT "Main":U) NO-ERROR.
    &ENDIF
    &IF DEFINED(hDBOExtTable4) <> 0 &THEN
        IF NOT VALID-HANDLE({&hDBOExtTable4}) OR
           {&hDBOTable}:TYPE <> "PROCEDURE":U OR
           {&hDBOTable}:FILE-NAME <> "{&DBOExtProgram4}":U THEN DO:
            {btb/btb008za.i1 {&DBOExtProgram4} YES}
            {btb/btb008za.i2 {&DBOExtProgram4} '' {&hDBOExtTable4}}
        END.
        RUN openQueryStatic IN {&hDBOExtTable4} (INPUT "Main":U) NO-ERROR.
    &ENDIF
    &IF DEFINED(hDBOExtTable5) <> 0 &THEN
        IF NOT VALID-HANDLE({&hDBOExtTable5}) OR
           {&hDBOTable}:TYPE <> "PROCEDURE":U OR
           {&hDBOTable}:FILE-NAME <> "{&DBOExtProgram5}":U THEN DO:
            {btb/btb008za.i1 {&DBOExtProgram5} YES}
            {btb/btb008za.i2 {&DBOExtProgram5} '' {&hDBOExtTable5}}
        END.
        RUN openQueryStatic IN {&hDBOExtTable5} (INPUT "Main":U) NO-ERROR.
    &ENDIF
    &IF DEFINED(hDBOExtTable6) <> 0 &THEN
        IF NOT VALID-HANDLE({&hDBOExtTable6}) OR
           {&hDBOTable}:TYPE <> "PROCEDURE":U OR
           {&hDBOTable}:FILE-NAME <> "{&DBOExtProgram6}":U THEN DO:
            {btb/btb008za.i1 {&DBOExtProgram6} YES}
            {btb/btb008za.i2 {&DBOExtProgram6} '' {&hDBOExtTable6}}
        END.
        RUN openQueryStatic IN {&hDBOExtTable6} (INPUT "Main":U) NO-ERROR.
    &ENDIF
    
    RUN afterDisplayFields.
    

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE saveParentFields wMaintenanceNoNavigation 
PROCEDURE saveParentFields :
/*------------------------------------------------------------------------------
  Purpose:     Salva valores dos campos da tabela filho ({&ttTable}) com base 
               nos campos da tabela pai ({&ttParent})
  Parameters:  
  Notes:       Este m‚todo somente ‚ executado quando a vari vel pcAction 
               possuir os valores ADD ou COPY
------------------------------------------------------------------------------*/
    &IF DEFINED(isSon) <> 0 &THEN
        
        &IF DEFINED(ParentKey1) <> 0 &THEN
            ASSIGN {&ttTable}.{&ParentKey1} = {&ttParent}.{&ParentKey1}.
        &ENDIF
        &IF DEFINED(ParentKey2) <> 0 &THEN
            ASSIGN {&ttTable}.{&ParentKey2} = {&ttParent}.{&ParentKey2}.
        &ENDIF
        &IF DEFINED(ParentKey3) <> 0 &THEN
            ASSIGN {&ttTable}.{&ParentKey3} = {&ttParent}.{&ParentKey3}.
        &ENDIF
        &IF DEFINED(ParentKey4) <> 0 &THEN
            ASSIGN {&ttTable}.{&ParentKey4} = {&ttParent}.{&ParentKey4}.
        &ENDIF
        &IF DEFINED(ParentKey5) <> 0 &THEN
            ASSIGN {&ttTable}.{&ParentKey5} = {&ttParent}.{&ParentKey5}.
        &ENDIF
        &IF DEFINED(ParentKey6) <> 0 &THEN
            ASSIGN {&ttTable}.{&ParentKey6} = {&ttParent}.{&ParentKey6}.
        &ENDIF
    &ENDIF

    RETURN "OK":U.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setMousePointers wMaintenanceNoNavigation 
PROCEDURE setMousePointers :
/*------------------------------------------------------------------------------
  Purpose: Carregar mouse-pointers de zoom p/ as chaves estrangeiras     
  Parameters:  <none>
  Notes:       AVB Master DBA Progress
------------------------------------------------------------------------------*/

/* Carga de Ponteiros */
    
    &IF DEFINED(ExtKey1) &THEN
        {&ScreenExtTable1}.{&ScreenExtKey1}:LOAD-MOUSE-POINTER("image/lupa.cur":U) 
         IN FRAME {&Frame1}.
    &ENDIF
    &IF DEFINED(ExtKey2) &THEN
        {&ScreenExtTable2}.{&ScreenExtKey2}:LOAD-MOUSE-POINTER("image/lupa.cur":U) 
         IN FRAME {&Frame2}.
    &ENDIF
    &IF DEFINED(ExtKey3) &THEN
        {&ScreenExtTable3}.{&ScreenExtKey3}:LOAD-MOUSE-POINTER("image/lupa.cur":U) 
         IN FRAME {&Frame3}.
    &ENDIF
    &IF DEFINED(ExtKey4) &THEN
        {&ScreenExtTable4}.{&ScreenExtKey4}:LOAD-MOUSE-POINTER("image/lupa.cur":U) 
         IN FRAME {&Frame4}.
    &ENDIF
    &IF DEFINED(ExtKey5) &THEN
        {&ScreenExtTable5}.{&ScreenExtKey5}:LOAD-MOUSE-POINTER("image/lupa.cur":U) 
         IN FRAME {&Frame5}.
    &ENDIF
    &IF DEFINED(ExtKey6) &THEN
        {&ScreenExtTable6}.{&ScreenExtKey6}:LOAD-MOUSE-POINTER("image/lupa.cur":U) 
         IN FRAME {&Frame6}.
    &ENDIF


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE validateRecord wMaintenanceNoNavigation 
PROCEDURE validateRecord :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    for first natur-oper no-lock where
        natur-oper.nat-operacao = ttint-ds-natur-oper.nat-operacao:screen-value in frame fPage1:
        if natur-oper.cod-cfop <> ttint-ds-natur-oper.nen-cfop-n:screen-value in frame fPage0 then do:
            RUN intprg/message.p("Natureza de Opera‡Æo Inv lida","CFOP: " +  ttint-ds-natur-oper.nen-cfop-n:screen-value + " incompat¡vel com cfop cadastrada na natureza de opera‡Æo: " + ttint-ds-natur-oper.nat-operacao:screen-value).
            return "NOK".
        end.

        if  (ttint-ds-natur-oper.nep-cstb-n:screen-value = "00" and
             natur-oper.cd-trib-icm <> 1) or
            (ttint-ds-natur-oper.nep-cstb-n:screen-value = "10" and
             natur-oper.cd-trib-icm <> 1) or
            (ttint-ds-natur-oper.nep-cstb-n:screen-value = "20" and
             natur-oper.cd-trib-icm <> 4) or
            (ttint-ds-natur-oper.nep-cstb-n:screen-value = "70" and
             natur-oper.cd-trib-icm <> 4) or
            (ttint-ds-natur-oper.nep-cstb-n:screen-value = "40" and
             natur-oper.cd-trib-icm <> 2) or
            (ttint-ds-natur-oper.nep-cstb-n:screen-value = "41" and
             natur-oper.cd-trib-icm <> 2) or
            (ttint-ds-natur-oper.nep-cstb-n:screen-value = "30" and
             natur-oper.cd-trib-icm <> 2) or
            (ttint-ds-natur-oper.nep-cstb-n:screen-value = "90" and
             natur-oper.cd-trib-icm <> 3) or
            (ttint-ds-natur-oper.nep-cstb-n:screen-value = "51" and
             natur-oper.cd-trib-icm <> 5) or
            (natur-oper.ind-it-sub-dif and
             ttint-ds-natur-oper.nep-cstb-n:screen-value <> "50") or
            (natur-oper.ind-it-icms and
             ttint-ds-natur-oper.nep-cstb-n:screen-value <> "60")
        then do:
            RUN intprg/message.p("Natureza de Opera‡Æo Inv lida","C¢digo de tributa‡Æo do ICMS incompat¡vel com o CST Informado.").
            return "NOK".
        end.
    end.
    return "OK".

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

