&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
*/
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
{include/i-prgvrs.i ESFT1002 2.00.01.GCJ}

&IF "{&EMSFND_VERSION}" >= "1.00"
&THEN
&ENDIF

CREATE WIDGET-POOL.

/* Preprocessors Definitions ---                                      */
&GLOBAL-DEFINE Program        ESFT1002
&GLOBAL-DEFINE Version        2.00.01.GCJ

&GLOBAL-DEFINE WindowType     Master
&GLOBAL-DEFINE Folder         NO
&GLOBAL-DEFINE InitialPage    1
&GLOBAL-DEFINE FolderLabels   

&GLOBAL-DEFINE page0Widgets   btFiltro btSelecao btQueryJoins btReportsJoins btExit btHelp ~
                              
&GLOBAL-DEFINE page1Widgets   
&GLOBAL-DEFINE page2Widgets   

&GLOBAL-DEFINE EXCLUDE-translate     YES
&GLOBAL-DEFINE EXCLUDE-translateMenu YES



DEF TEMP-TABLE tt-selecao NO-UNDO
    FIELD cod-estabel                LIKE es-fat-duplic-nexxera.cod-estabel       EXTENT 2
    FIELD nr-fatura                  LIKE es-fat-duplic-nexxera.nr-fatura         EXTENT 2  
    FIELD cod-portador               LIKE es-fat-duplic-nexxera.cod-portador      EXTENT 2  
    FIELD dt-venciment               LIKE es-fat-duplic-nexxera.dt-venciment      EXTENT 2  

    .

DEF TEMP-TABLE tt-param NO-UNDO
    FIELD situacao AS INT EXTENT 3 INITIAL 1.
    

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */

DEF TEMP-TABLE tt-es-fat-duplic-nexxera-aux NO-UNDO
    LIKE es-fat-duplic-nexxera.


DEF TEMP-TABLE tt-es-fat-duplic-nexxera NO-UNDO
    LIKE es-fat-duplic-nexxera.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Window
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME fpage0
&Scoped-define BROWSE-NAME brTable

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-es-fat-duplic-nexxera

/* Definitions for BROWSE brTable                                       */
&Scoped-define FIELDS-IN-QUERY-brTable tt-es-fat-duplic-nexxera.cod-estabel tt-es-fat-duplic-nexxera.serie tt-es-fat-duplic-nexxera.parcela tt-es-fat-duplic-nexxera.nr-fatura tt-es-fat-duplic-nexxera.dt-venciment tt-es-fat-duplic-nexxera.cod-portador tt-es-fat-duplic-nexxera.taxa-admin tt-es-fat-duplic-nexxera.taxa-admin-datasul tt-es-fat-duplic-nexxera.vl-parcela tt-es-fat-duplic-nexxera.vl-parcela-datasul tt-es-fat-duplic-nexxera.id-divergente   
&Scoped-define ENABLED-FIELDS-IN-QUERY-brTable   
&Scoped-define SELF-NAME brTable
&Scoped-define QUERY-STRING-brTable FOR EACH tt-es-fat-duplic-nexxera
&Scoped-define OPEN-QUERY-brTable OPEN QUERY {&SELF-NAME} FOR EACH tt-es-fat-duplic-nexxera.
&Scoped-define TABLES-IN-QUERY-brTable tt-es-fat-duplic-nexxera
&Scoped-define FIRST-TABLE-IN-QUERY-brTable tt-es-fat-duplic-nexxera


/* Definitions for FRAME fpage0                                         */
&Scoped-define OPEN-BROWSERS-IN-QUERY-fpage0 ~
    ~{&OPEN-QUERY-brTable}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS rtToolBar-2 btQueryJoins btReportsJoins ~
btExit btHelp btSelecao btFiltro brTable 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR wWindow AS WIDGET-HANDLE NO-UNDO.

/* Definitions of the field level widgets                               */
DEFINE BUTTON btExit 
     IMAGE-UP FILE "image\im-exi":U
     IMAGE-INSENSITIVE FILE "image\ii-exi":U
     LABEL "Exit" 
     SIZE 4 BY 1.25
     FONT 4.

DEFINE BUTTON btFiltro 
     IMAGE-UP FILE "image\im-fil.gif":U
     LABEL "" 
     SIZE 4 BY 1.13 TOOLTIP "Parƒmetros".

DEFINE BUTTON btHelp 
     IMAGE-UP FILE "image\im-hel":U
     IMAGE-INSENSITIVE FILE "image\ii-hel":U
     LABEL "Help" 
     SIZE 4 BY 1.25
     FONT 4.

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

DEFINE BUTTON btSelecao 
     IMAGE-UP FILE "image/im-ran.gif":U
     LABEL "" 
     SIZE 4 BY 1.13 TOOLTIP "Sele‡Æo".

DEFINE RECTANGLE rtToolBar-2
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 157 BY 1.5
     BGCOLOR 7 .

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY brTable FOR 
      tt-es-fat-duplic-nexxera SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE brTable
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS brTable wWindow _FREEFORM
  QUERY brTable DISPLAY
      tt-es-fat-duplic-nexxera.cod-estabel                
tt-es-fat-duplic-nexxera.serie                      
tt-es-fat-duplic-nexxera.parcela                    
tt-es-fat-duplic-nexxera.nr-fatura                  
tt-es-fat-duplic-nexxera.dt-venciment               
tt-es-fat-duplic-nexxera.cod-portador               
tt-es-fat-duplic-nexxera.taxa-admin                 
tt-es-fat-duplic-nexxera.taxa-admin-datasul         
tt-es-fat-duplic-nexxera.vl-parcela                 
tt-es-fat-duplic-nexxera.vl-parcela-datasul         
tt-es-fat-duplic-nexxera.id-divergente
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 156 BY 14.25
         FONT 1 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME fpage0
     btQueryJoins AT ROW 1.13 COL 141 HELP
          "Consultas relacionadas"
     btReportsJoins AT ROW 1.13 COL 145 HELP
          "Relat¢rios relacionados"
     btExit AT ROW 1.13 COL 149 HELP
          "Sair"
     btHelp AT ROW 1.13 COL 153 HELP
          "Ajuda"
     btSelecao AT ROW 1.25 COL 3.29 WIDGET-ID 36
     btFiltro AT ROW 1.25 COL 7.43 WIDGET-ID 34
     brTable AT ROW 2.75 COL 2 WIDGET-ID 200
     rtToolBar-2 AT ROW 1 COL 1
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 157.43 BY 17
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
         HEIGHT             = 17
         WIDTH              = 157.43
         MAX-HEIGHT         = 17
         MAX-WIDTH          = 157.43
         VIRTUAL-HEIGHT     = 17
         VIRTUAL-WIDTH      = 157.43
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _INCLUDED-LIB wWindow 
/* ************************* Included-Libraries *********************** */

{window/window.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME




/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW wWindow
  NOT-VISIBLE,,RUN-PERSISTENT                                           */
/* SETTINGS FOR FRAME fpage0
   FRAME-NAME                                                           */
/* BROWSE-TAB brTable btFiltro fpage0 */
IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(wWindow)
THEN wWindow:HIDDEN = yes.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE brTable
/* Query rebuild information for BROWSE brTable
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH tt-es-fat-duplic-nexxera.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE brTable */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK FRAME fpage0
/* Query rebuild information for FRAME fpage0
     _Options          = "SHARE-LOCK KEEP-EMPTY"
     _Query            is NOT OPENED
*/  /* FRAME fpage0 */
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


&Scoped-define SELF-NAME btExit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btExit wWindow
ON CHOOSE OF btExit IN FRAME fpage0 /* Exit */
DO:
    APPLY "CLOSE":U TO THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btFiltro
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btFiltro wWindow
ON CHOOSE OF btFiltro IN FRAME fpage0
DO:
    DEFINE VARIABLE l-ok AS LOGICAL     NO-UNDO.


    RUN esp\esft1002b.w (OUTPUT l-ok,
                          INPUT-OUTPUT TABLE tt-param).


    IF l-ok THEN
        RUN pi-open-query.


    RETURN "OK".

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btHelp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btHelp wWindow
ON CHOOSE OF btHelp IN FRAME fpage0 /* Help */
DO:
    {include/ajuda.i}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btQueryJoins
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btQueryJoins wWindow
ON CHOOSE OF btQueryJoins IN FRAME fpage0 /* Query Joins */
DO:
    RUN showQueryJoins IN THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btReportsJoins
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btReportsJoins wWindow
ON CHOOSE OF btReportsJoins IN FRAME fpage0 /* Reports Joins */
DO:
    RUN showReportsJoins IN THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btSelecao
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btSelecao wWindow
ON CHOOSE OF btSelecao IN FRAME fpage0
DO:
    DEFINE VARIABLE l-ok AS LOGICAL     NO-UNDO.


    RUN esp\esft1002a.w (OUTPUT l-ok,
                        INPUT-OUTPUT TABLE tt-selecao).



    IF l-ok THEN
        RUN pi-open-query.



    RETURN "OK".

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME brTable
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK wWindow 


/*:T--- L¢gica para inicializa‡Æo do programam ---*/
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

  CREATE tt-param.
  ASSIGN tt-param.situacao[1] = 2.
  CREATE tt-selecao.

  ASSIGN tt-selecao.cod-estabel[2]   = "ZZZ"             
         tt-selecao.nr-fatura[2]     = "ZZZ"                 
         tt-selecao.cod-portador[2]  = 999999

         tt-selecao.dt-venciment[1] = DATE(1,1,YEAR(TODAY))            
         tt-selecao.dt-venciment[2] = TODAY.


 

  ASSIGN brTable:SENSITIVE IN FRAME fPage0 = YES.
  RUN pi-open-query.


 RETURN "OK".

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-open-query wWindow 
PROCEDURE pi-open-query :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/







FIND FIRST tt-selecao.
FIND FIRST tt-param.

EMPTY TEMP-TABLE tt-es-fat-duplic-nexxera.
EMPTY TEMP-TABLE tt-es-fat-duplic-nexxera-aux.

blk_1:
FOR EACH es-fat-duplic-nexxera NO-LOCK
   WHERE es-fat-duplic-nexxera.cod-estabel        >= tt-selecao.cod-estabel[1]  
   AND   es-fat-duplic-nexxera.cod-estabel        <= tt-selecao.cod-estabel[2]  

   AND   es-fat-duplic-nexxera.nr-fatura  >= tt-selecao.nr-fatura[1]  
   AND   es-fat-duplic-nexxera.nr-fatura  <= tt-selecao.nr-fatura[2]  

   AND   es-fat-duplic-nexxera.dt-venciment    >= tt-selecao.dt-venciment[1]  
   AND   es-fat-duplic-nexxera.dt-venciment    <= tt-selecao.dt-venciment[2]  

   AND   es-fat-duplic-nexxera.cod-portador      >= tt-selecao.cod-portador[1]  
   AND   es-fat-duplic-nexxera.cod-portador      <= tt-selecao.cod-portador[2]  

    
   :

    
   /* situacao conciliacao 
   IF tt-param.situacao[1] > 1 THEN DO:

       IF  tt-param.situacao[1] = 2 
       AND NOT es-fat-duplic-nexxera.id-divergente THEN NEXT blk_1.

       IF  tt-param.situacao[1] = 3 
       AND es-fat-duplic-nexxera.id-divergente THEN NEXT blk_1.
   END.
   
   */

    IF tt-param.situacao[1] < 5 THEN DO:


        IF es-fat-duplic-nexxera.situacao <> tt-param.situacao[1] THEN
            NEXT blk_1.
    END.

    CREATE tt-es-fat-duplic-nexxera.
    BUFFER-COPY es-fat-duplic-nexxera TO tt-es-fat-duplic-nexxera.

END.

{&OPEN-QUERY-brTable}

RETURN "OK".


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Translate wWindow 
PROCEDURE Translate :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/


 RETURN "OK".

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

