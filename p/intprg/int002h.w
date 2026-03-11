&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME wWindow
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS wWindow 
/*:T*******************************************************************************
** Copyright DATASUL S.A. (1999)
** Todos os Direitos Reservados.
**
** Este fonte e de propriedade exclusiva da DATASUL, sua reproducao
** parcial ou total por qualquer meio, so podera ser feita mediante
** autorizacao expressa.
*******************************************************************************/
{include/i-prgvrs.i int002h 2.12.01.001}

CREATE WIDGET-POOL.

/* Preprocessors Definitions ---                                      */
&GLOBAL-DEFINE Program        int002h
&GLOBAL-DEFINE Version        2.12.01.001

&GLOBAL-DEFINE WindowType     Master/Detail

&GLOBAL-DEFINE Folder         NO
&GLOBAL-DEFINE InitialPage    1
&GLOBAL-DEFINE FolderLabels   <Folder1 ,Folder 2 ,... , Folder8>

&GLOBAL-DEFINE page0Widgets   btQueryJoins btReportsJoins btExit btHelp ~
                              btOK btCancel btHelp2
&GLOBAL-DEFINE page1Widgets   c-class-fiscal c-nat-operacao bt-natureza i-cfop
&GLOBAL-DEFINE page2Widgets   

/* Parameters Definitions ---                                           */

DEFINE INPUT PARAMETER p-rowid AS ROWID    NO-UNDO.
DEFINE OUTPUT PARAMETER p-ok    AS LOGICAL  NO-UNDO.

/* Local Variable Definitions ---                                       */
DEFINE NEW GLOBAL SHARED VARIABLE adm-broker-hdl AS HANDLE NO-UNDO.
DEFINE VARIABLE wh-pesquisa AS HANDLE NO-UNDO.

define temp-table tt-param no-undo
    field destino          as integer
    field arquivo          as char format "x(35)":U
    field usuario          as char format "x(12)":U
    field data-exec        as date
    field hora-exec        as integer
    field classifica       as integer
    field desc-classifica  as char format "x(40)":U
    field modelo           AS char format "x(35)":U
    field l-habilitaRtf    as LOG
    FIELD dt-trans-ini     LIKE docum-est.dt-trans
    FIELD dt-trans-fin     LIKE docum-est.dt-trans
    FIELD i-nro-docto-ini  LIKE docum-est.nro-docto
    FIELD i-nro-docto-fin  LIKE docum-est.nro-docto
    FIELD i-cod-emit-ini   LIKE docum-est.cod-emitente
    FIELD i-cod-emit-fin   LIKE docum-est.cod-emitente.

DEFINE TEMP-TABLE tt-digita
    FIELD arquivo AS CHAR
    FIELD raiz    AS CHAR 
    FIELD node    AS CHAR
    FIELD campo   AS CHAR FORMAT "X(100)"
    FIELD valor   AS CHAR FORMAT "X(100)"
    FIELD linha   AS INTEGER.

def temp-table tt-raw-digita
    field raw-digita as raw.

DEF TEMP-TABLE tt-raw-param 
 FIELD raw-param  AS RAW.

DEF VAR raw-param  AS RAW.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Window
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME fpage0

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS rtToolBar-2 rtToolBar btQueryJoins ~
btReportsJoins btExit btHelp btOK btCancel btHelp2 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR wWindow AS WIDGET-HANDLE NO-UNDO.

/* Menu Definitions                                                     */
DEFINE SUB-MENU smFile 
       MENU-ITEM miQueryJoins   LABEL "&Consultas"    
       MENU-ITEM miReportsJoins LABEL "&Relat¢rios"   
       RULE
       MENU-ITEM miExit         LABEL "&Sair"          ACCELERATOR "CTRL-X".

DEFINE SUB-MENU smHelp 
       MENU-ITEM miContents     LABEL "&Conte£do"     
       MENU-ITEM miAbout        LABEL "&Sobre..."     .

DEFINE MENU mbMain MENUBAR
       SUB-MENU  smFile         LABEL "&Arquivo"      
       SUB-MENU  smHelp         LABEL "&Ajuda"        .


/* Definitions of the field level widgets                               */
DEFINE BUTTON btCancel 
     LABEL "Cancelar" 
     SIZE 10 BY 1.

DEFINE BUTTON btExit 
     IMAGE-UP FILE "image\im-exi":U
     IMAGE-INSENSITIVE FILE "image\ii-exi":U
     LABEL "Exit" 
     SIZE 4 BY 1.25
     FONT 4.

DEFINE BUTTON btHelp 
     IMAGE-UP FILE "image\im-hel":U
     IMAGE-INSENSITIVE FILE "image\ii-hel":U
     LABEL "Help" 
     SIZE 4 BY 1.25
     FONT 4.

DEFINE BUTTON btHelp2 
     LABEL "Ajuda" 
     SIZE 10 BY 1.

DEFINE BUTTON btOK 
     LABEL "OK" 
     SIZE 10 BY 1.

DEFINE BUTTON btQueryJoins 
     IMAGE-UP FILE "image\im-joi":U
     IMAGE-INSENSITIVE FILE "image\ii-joi":U
     LABEL "Query Joins" 
     SIZE 4 BY 1.25
     FONT 4.

DEFINE BUTTON btReportsJoins 
     IMAGE-UP FILE "image\im-pri":U
     IMAGE-INSENSITIVE FILE "image\ii-pri":U
     LABEL "Reports Joins" 
     SIZE 4 BY 1.25
     FONT 4.

DEFINE RECTANGLE rtToolBar
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 90 BY 1.42
     BGCOLOR 7 .

DEFINE RECTANGLE rtToolBar-2
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 90 BY 1.5
     BGCOLOR 8 .

DEFINE BUTTON bt-natureza 
     IMAGE-UP FILE "image\im-sav":U
     LABEL "Altera Natureza" 
     SIZE 5.14 BY 1.

DEFINE VARIABLE c-class-fiscal AS CHARACTER FORMAT "99999999" 
     LABEL "Classificaá∆o Fiscal" 
     VIEW-AS FILL-IN 
     SIZE 12 BY .88.

DEFINE VARIABLE c-desc-class AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 31.29 BY .88 NO-UNDO.

DEFINE VARIABLE c-desc-nat AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 35 BY .88 NO-UNDO.

DEFINE VARIABLE c-nat-operacao AS CHARACTER FORMAT "x(6)" 
     LABEL "Nat Operaá∆o" 
     VIEW-AS FILL-IN 
     SIZE 8.86 BY .88.

DEFINE VARIABLE c-nNF AS CHARACTER FORMAT "x(16)" 
     LABEL "Nota" 
     VIEW-AS FILL-IN 
     SIZE 12.57 BY .88.

DEFINE VARIABLE c-serie AS CHARACTER FORMAT "x(5)" 
     LABEL "Serie" 
     VIEW-AS FILL-IN 
     SIZE 5 BY .88.

DEFINE VARIABLE i-cfop AS INTEGER FORMAT ">>>>>9" INITIAL 0 
     LABEL "CFOP" 
     VIEW-AS FILL-IN 
     SIZE 8.86 BY .88.

DEFINE VARIABLE i-cod-emitente AS INTEGER FORMAT ">>>>>>>>9" INITIAL 0 
     LABEL "Emitente":R10 
     VIEW-AS FILL-IN 
     SIZE 10 BY .88.

DEFINE RECTANGLE RECT-12
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 79 BY 3.5.

DEFINE RECTANGLE RECT-13
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 79 BY 4.21.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME fpage0
     btQueryJoins AT ROW 1.13 COL 74.72 HELP
          "Consultas relacionadas"
     btReportsJoins AT ROW 1.13 COL 78.72 HELP
          "Relat¢rios relacionados"
     btExit AT ROW 1.13 COL 82.72 HELP
          "Sair"
     btHelp AT ROW 1.13 COL 86.72 HELP
          "Ajuda"
     btOK AT ROW 12.96 COL 2
     btCancel AT ROW 12.96 COL 13
     btHelp2 AT ROW 12.96 COL 80
     rtToolBar-2 AT ROW 1 COL 1
     rtToolBar AT ROW 12.75 COL 1
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 90 BY 13.67
         FONT 1 WIDGET-ID 100.

DEFINE FRAME fPage1
     c-serie AT ROW 1.46 COL 17 COLON-ALIGNED WIDGET-ID 54
     c-nNF AT ROW 2.46 COL 17 COLON-ALIGNED WIDGET-ID 76
     i-cod-emitente AT ROW 3.63 COL 17 COLON-ALIGNED WIDGET-ID 74
     c-class-fiscal AT ROW 5.67 COL 16 COLON-ALIGNED WIDGET-ID 4
     c-desc-class AT ROW 5.67 COL 28.29 COLON-ALIGNED NO-LABEL WIDGET-ID 6
     i-cfop AT ROW 6.71 COL 16 COLON-ALIGNED WIDGET-ID 50
     c-nat-operacao AT ROW 7.75 COL 16 COLON-ALIGNED WIDGET-ID 60
     c-desc-nat AT ROW 7.75 COL 25 COLON-ALIGNED NO-LABEL WIDGET-ID 58
     bt-natureza AT ROW 7.58 COL 63 WIDGET-ID 18
     RECT-12 AT ROW 1.25 COL 3 WIDGET-ID 78
     RECT-13 AT ROW 5.04 COL 3 WIDGET-ID 80
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 3.57 ROW 3.25
         SIZE 84.43 BY 9
         FONT 1 WIDGET-ID 100.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Window
   Allow: Basic,Browse,DB-Fields,Window,Query
   Add Fields to: Neither
   Other Settings: COMPILE
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
IF SESSION:DISPLAY-TYPE = "GUI":U THEN
  CREATE WINDOW wWindow ASSIGN
         HIDDEN             = YES
         TITLE              = ""
         HEIGHT             = 13.38
         WIDTH              = 91.29
         MAX-HEIGHT         = 27.5
         MAX-WIDTH          = 195.14
         VIRTUAL-HEIGHT     = 27.5
         VIRTUAL-WIDTH      = 195.14
         RESIZE             = no
         SCROLL-BARS        = no
         STATUS-AREA        = yes
         BGCOLOR            = ?
         FGCOLOR            = ?
         KEEP-FRAME-Z-ORDER = yes
         THREE-D            = yes
         MESSAGE-AREA       = no
         SENSITIVE          = yes.
ELSE {&WINDOW-NAME} = CURRENT-WINDOW.

ASSIGN {&WINDOW-NAME}:MENUBAR    = MENU mbMain:HANDLE.
/* END WINDOW DEFINITION                                                */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _INCLUDED-LIB wWindow 
/* ************************* Included-Libraries *********************** */

{window/window.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME




/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW wWindow
  NOT-VISIBLE,,RUN-PERSISTENT                                           */
/* REPARENT FRAME */
ASSIGN FRAME fPage1:FRAME = FRAME fpage0:HANDLE.

/* SETTINGS FOR FRAME fpage0
   FRAME-NAME                                                           */
/* SETTINGS FOR FRAME fPage1
   Custom                                                               */
IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(wWindow)
THEN wWindow:HIDDEN = yes.

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

&Scoped-define SELF-NAME wWindow
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL wWindow wWindow
ON END-ERROR OF wWindow
OR ENDKEY OF {&WINDOW-NAME} ANYWHERE DO:
  /* This case occurs when the user presses the "Esc" key.
     In a persistently run window, just ignore this.  If we did not, the
     application would exit. */
  IF THIS-PROCEDURE:PERSISTENT THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL wWindow wWindow
ON WINDOW-CLOSE OF wWindow
DO:
  /* This event will close the window and terminate the procedure.  */
  APPLY "CLOSE":U TO THIS-PROCEDURE.
  RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME fPage1
&Scoped-define SELF-NAME bt-natureza
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-natureza wWindow
ON CHOOSE OF bt-natureza IN FRAME fPage1 /* Altera Natureza */
DO:
  IF INPUT FRAME fpage1 c-class-fiscal <> ""
  THEN DO:
      FIND FIRST classif-fisc NO-LOCK WHERE
                 classif-fisc.class-fiscal = INPUT FRAME fpage1 c-class-fiscal NO-ERROR.
      IF NOT AVAIL classif-fisc 
      THEN DO:
    
            RUN utp/ut-msgs.p (input "show":U, 
                            input 17006, 
                            input "Classificaá∆o fiscal n∆o cadastrada!" + "~~" + 
                                  "Classificaá∆o fiscal informada n∆o cadastrada").
    
    
         RETURN NO-APPLY. 
    
    
      END.
  END.


  FIND FIRST natur-oper NO-LOCK WHERE
             natur-oper.nat-operacao = INPUT FRAME fpage1 c-nat-operacao NO-ERROR.
  IF NOT AVAIL natur-oper 
  THEN DO:

        RUN utp/ut-msgs.p (input "show":U, 
                        input 17006, 
                        input "Natureza de operaá∆o n∆o cadastrada!" + "~~" + 
                              "Natureza de operaá∆o informada n∆o cadastrada").

     RETURN NO-APPLY. 


  END.

  ASSIGN p-ok = YES.
     
  RUN pi-altera-natureza.


  
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME fpage0
&Scoped-define SELF-NAME btCancel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btCancel wWindow
ON CHOOSE OF btCancel IN FRAME fpage0 /* Cancelar */
DO:
    APPLY "CLOSE":U TO THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btExit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btExit wWindow
ON CHOOSE OF btExit IN FRAME fpage0 /* Exit */
OR CHOOSE OF MENU-ITEM miExit IN MENU mbMain DO:
    APPLY "CLOSE":U TO THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btHelp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btHelp wWindow
ON CHOOSE OF btHelp IN FRAME fpage0 /* Help */
OR CHOOSE OF MENU-ITEM miContents IN MENU mbMain DO:
    {include/ajuda.i}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btHelp2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btHelp2 wWindow
ON CHOOSE OF btHelp2 IN FRAME fpage0 /* Ajuda */
DO:
    {include/ajuda.i}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btOK
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btOK wWindow
ON CHOOSE OF btOK IN FRAME fpage0 /* OK */
DO:
    APPLY "CLOSE":U TO THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btQueryJoins
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btQueryJoins wWindow
ON CHOOSE OF btQueryJoins IN FRAME fpage0 /* Query Joins */
OR CHOOSE OF MENU-ITEM miQueryJoins IN MENU mbMain DO:
    RUN showQueryJoins IN THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btReportsJoins
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btReportsJoins wWindow
ON CHOOSE OF btReportsJoins IN FRAME fpage0 /* Reports Joins */
OR CHOOSE OF MENU-ITEM miReportsJoins IN MENU mbMain DO:
    RUN showReportsJoins IN THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME fPage1
&Scoped-define SELF-NAME c-class-fiscal
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL c-class-fiscal wWindow
ON F5 OF c-class-fiscal IN FRAME fPage1 /* Classificaá∆o Fiscal */
DO:
    &if defined(bf-mat-comex) &then  
      assign l-implanta = no.
    &else
      assign l-implanta = yes.
    &endif 

    {include/zoomvar.i &prog-zoom="inzoom/z01in046.w"
                       &campo="c-class-fiscal"
                       &campozoom="class-fiscal"
                       &campo2="c-desc-class"
                       &campozoom2="descricao"
                       &frame="fPage1"}  
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL c-class-fiscal wWindow
ON LEAVE OF c-class-fiscal IN FRAME fPage1 /* Classificaá∆o Fiscal */
DO:
  FIND FIRST classif-fisc NO-LOCK WHERE
             classif-fisc.class-fiscal = INPUT FRAME fpage1 c-class-fiscal NO-ERROR.
  IF AVAIL classif-fisc THEN
     ASSIGN c-desc-class:SCREEN-VALUE IN FRAME fpage1 = classif-fisc.descricao.
  ELSE 
     ASSIGN c-desc-class:SCREEN-VALUE IN FRAME fpage1 = "".

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL c-class-fiscal wWindow
ON MOUSE-SELECT-DBLCLICK OF c-class-fiscal IN FRAME fPage1 /* Classificaá∆o Fiscal */
DO:
    apply "F5":u to self in frame fPage0.  
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME c-nat-operacao
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL c-nat-operacao wWindow
ON F5 OF c-nat-operacao IN FRAME fPage1 /* Nat Operaá∆o */
DO:
  
     {method/zoomfields.i &ProgramZoom="inzoom/z04in245.w"
                         &FieldZoom1="nat-operacao"
                         &FieldScreen1="c-nat-operacao"
                         &frame1="fpage1"
                         &FieldZoom2="denominacao"
                         &FieldScreen2="c-desc-nat"
                         &frame2="fpage1"} 
                         
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL c-nat-operacao wWindow
ON LEAVE OF c-nat-operacao IN FRAME fPage1 /* Nat Operaá∆o */
DO:
  FIND FIRST natur-oper NO-LOCK
        WHERE natur-oper.nat-operacao = INPUT FRAME fpage1 c-nat-operacao NO-ERROR.
   IF AVAIL natur-oper THEN
       ASSIGN c-desc-nat:SCREEN-VALUE IN FRAME fpage1                  = natur-oper.denominacao.
   ELSE 
       ASSIGN c-desc-nat:SCREEN-VALUE IN FRAME fpage1 = "".
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL c-nat-operacao wWindow
ON MOUSE-SELECT-DBLCLICK OF c-nat-operacao IN FRAME fPage1 /* Nat Operaá∆o */
DO:
  APPLY "f5" TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME i-cfop
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL i-cfop wWindow
ON F5 OF i-cfop IN FRAME fPage1 /* CFOP */
DO:
  
      {include/zoomvar.i &prog-zoom=cdp/cd0620-z01.w
                           &campo=i-cfop
                           &campozoom=cod-cfop
                           &frame=fpage1
                           &EnableImplant="no"}
                           
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME fpage0
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK wWindow 


/*:T--- L¢gica para inicializaá∆o do programam ---*/
{window/mainblock.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE afterInitializeInterface wWindow 
PROCEDURE afterInitializeInterface :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

c-class-fiscal:load-mouse-pointer("image/lupa.cur":U) in frame fPage1.
c-nat-operacao:load-mouse-pointer("image/lupa.cur":U) in frame fPage1.

FIND FIRST int-ds-docto-xml no-lock WHERE
           rowid(int-ds-docto-xml) = p-rowid NO-ERROR.
IF AVAIL int-ds-docto-xml 
THEN DO:

    ASSIGN c-serie:SCREEN-VALUE IN FRAME fpage1 = int-ds-docto-xml.serie
           c-nnf:SCREEN-VALUE IN FRAME fpage1   = int-ds-docto-xml.nnf
           i-cod-emitente:SCREEN-VALUE IN FRAME fpage1 = string(int-ds-docto-xml.cod-emitente).

END.


/* ASSIGN c-class-fiscal:SENSITIVE IN FRAME fpage1 = YES
       c-class-fiscal:SENSITIVE IN FRAME fpage1 = YES 
   */    
      
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-altera-natureza wWindow 
PROCEDURE pi-altera-natureza :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

FIND FIRST int-ds-docto-xml EXCLUSIVE-LOCK WHERE
           rowid(int-ds-docto-xml) = p-rowid NO-ERROR.
IF AVAIL int-ds-docto-xml 
THEN DO:
    
    FOR EACH int-ds-it-docto-xml EXCLUSIVE-LOCK WHERE
             int-ds-it-docto-xml.serie          =  int-ds-docto-xml.serie         AND
             int-ds-it-docto-xml.nNF            =  int-ds-docto-xml.nNF           AND
             int-ds-it-docto-xml.cod-emitente   =  int-ds-docto-xml.cod-emitente  AND
             int-ds-it-docto-xml.tipo-nota      =  int-ds-docto-xml.tipo-nota     AND 
             int-ds-it-docto-xml.situacao       < 3                               AND 
             int-ds-it-docto-xml.cfop           = INPUT FRAME fpage1 i-cfop :

        IF AVAIL classif-fis THEN DO:
        
          FIND FIRST ITEM NO-LOCK WHERE
                     ITEM.it-codigo    = int-ds-it-docto-xml.it-codigo AND 
                     ITEM.class-fiscal = classif-fis.class-fiscal NO-ERROR.
          
          IF NOT AVAIL ITEM  THEN NEXT.

        END.

        ASSIGN int-ds-it-docto-xml.nat-operacao = natur-oper.nat-operacao
               int-ds-it-docto-xml.cfop         = int(natur-oper.cod-cfop).

    END. 
  
    FOR EACH int-ds-it-docto-xml NO-LOCK WHERE
             int-ds-it-docto-xml.serie          =  int-ds-docto-xml.serie         AND
             int-ds-it-docto-xml.nNF            =  int-ds-docto-xml.nNF           AND
             int-ds-it-docto-xml.cod-emitente   =  int-ds-docto-xml.cod-emitente  AND
             int-ds-it-docto-xml.tipo-nota      =  int-ds-docto-xml.tipo-nota     AND
             int-ds-it-docto-xml.cfop           = INPUT FRAME fpage1 i-cfop       AND
             int-ds-it-docto-xml.situacao       < 3:

         IF AVAIL classif-fis THEN DO:
        
              FIND FIRST ITEM NO-LOCK WHERE
                         ITEM.it-codigo    = int-ds-it-docto-xml.it-codigo AND 
                         ITEM.class-fiscal = classif-fis.class-fiscal NO-ERROR.
              
              IF NOT AVAIL ITEM  THEN NEXT.

         END.
         
         for each tt-raw-digita:
            delete tt-raw-digita.
         end.

         EMPTY TEMP-TABLE tt-digita.
         EMPTY TEMP-TABLE tt-param.
    
        CREATE tt-param.
        ASSIGN tt-param.destino         = 2                              
               tt-param.arquivo         = SESSION:TEMP-DIRECTORY + "\" + "int002brp.txt"       
               tt-param.usuario         = c-seg-usuario       
               tt-param.data-exec       = TODAY  
               tt-param.hora-exec       = TIME      
               tt-param.dt-trans-ini    = int-ds-docto-xml.DEmi 
               tt-param.dt-trans-fin    = int-ds-docto-xml.DEmi
               tt-param.i-nro-docto-ini = int-ds-docto-xml.nNF 
               tt-param.i-nro-docto-fin = int-ds-docto-xml.nNF
               tt-param.i-cod-emit-ini  = int-ds-docto-xml.cod-emitente
               tt-param.i-cod-emit-fin  = int-ds-docto-xml.cod-emitente. 
    
        create tt-digita.
        assign tt-digita.campo = "item"
               tt-digita.valor = string(ROWID(int-ds-it-docto-xml)).
        raw-transfer tt-param  to raw-param.
    
        for each tt-digita:
            create tt-raw-digita.
            raw-transfer tt-digita to tt-raw-digita.raw-digita.
        end.

        run intprg/int002brp.p (input raw-param, 
                                input table tt-raw-digita).

    END.

    FIND FIRST int-ds-ext-emitente NO-LOCK WHERE   /* Pepsico nao atualiza */
               int-ds-ext-emitente.cod-emitente = int-ds-docto-xml.cod-emitente AND 
               int-ds-ext-emitente.gera-nota    = NO NO-ERROR.
    IF AVAIL int-ds-ext-emitente THEN DO:

        IF NOT CAN-FIND(FIRST int-ds-it-docto-xml NO-LOCK WHERE 
                              int-ds-it-docto-xml.serie         =  int-ds-docto-xml.serie         AND
                              int-ds-it-docto-xml.nNF           =  int-ds-docto-xml.nNF           AND
                              int-ds-it-docto-xml.cod-emitente  =  int-ds-docto-xml.cod-emitente  AND
                              int-ds-it-docto-xml.tipo-nota     =  int-ds-docto-xml.tipo-nota     AND
                              int-ds-it-docto-xml.situacao      =  1 /* Pendente */)   
        THEN 
          ASSIGN int-ds-docto-xml.situacao = 2. /* Liberado */
        ELSE 
          ASSIGN int-ds-docto-xml.situacao = 1. /* Pendente */

    END.

END.
            
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

