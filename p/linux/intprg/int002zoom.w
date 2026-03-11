&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
          emsesp           ORACLE
*/
&Scoped-define WINDOW-NAME wZoom


/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE tt-int-ds-docto-xml-1 NO-UNDO LIKE int-ds-docto-xml
       fields r-rowid as rowid.
DEFINE TEMP-TABLE tt-int-ds-docto-xml-2 NO-UNDO LIKE int-ds-docto-xml
       fields r-rowid as rowid.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS wZoom 
/*:T*******************************************************************************
** Copyright DATASUL S.A. (1999)
** Todos os Direitos Reservados.
**
** Este fonte e de propriedade exclusiva da DATASUL, sua reproducao
** parcial ou total por qualquer meio, so podera ser feita mediante
** autorizacao expressa.
*******************************************************************************/

{include/i-prgvrs.i int002zoom 2.06.00.001}

DEF VAR c-contrato AS CHAR.

CREATE WIDGET-POOL.

/* Preprocessors Definitions ---                                      */
&GLOBAL-DEFINE Program           int002zoom
&GLOBAL-DEFINE Version           2.06.00.001

&GLOBAL-DEFINE InitialPage       1
&GLOBAL-DEFINE FolderLabels      Nota, Emitente

&GLOBAL-DEFINE Range             no


&GLOBAL-DEFINE page1Fields       c-nr-nota-ini c-nr-nota-fim c-serie-ini c-serie-fim
&GLOBAL-DEFINE page2Fields       i-cod-emitente-ini i-cod-emitente-fim 

&GLOBAL-DEFINE FieldsRangePage1  NO

&GLOBAL-DEFINE FieldsRangePage1  NO
&GLOBAL-DEFINE FieldsRangePage2  NO
&GLOBAL-DEFINE FieldsAnyKeyPage1 NO
&GLOBAL-DEFINE FieldsAnyKeyPage2 NO


&GLOBAL-DEFINE ttTable1          tt-int-ds-docto-xml-1
&GLOBAL-DEFINE hDBOTable1        h-tt-int-ds-docto-xml-1
&GLOBAL-DEFINE DBOTable1         dbo-tt-int-ds-docto-xml-1

&GLOBAL-DEFINE ttTable2          tt-int-ds-docto-xml-2
&GLOBAL-DEFINE hDBOTable2        h-tt-int-ds-docto-xml-2
&GLOBAL-DEFINE DBOTable2         dbo-tt-int-ds-docto-xml-2

&GLOBAL-DEFINE page1Browse      brTable1
&GLOBAL-DEFINE page2Browse      brTable2

&GLOBAL-DEFINE EXCLUDE-ApplyOffEnd
&GLOBAL-DEFINE EXCLUDE-ApplyOffHome

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */

/* Local Variable Definitions (DBOs Handles) --- */
DEFINE VARIABLE {&hDBOTable1} AS HANDLE NO-UNDO.
DEFINE VARIABLE {&hDBOTable2} AS HANDLE NO-UNDO.

DEFINE VAR c-desc-emitente AS CHAR NO-UNDO.
DEFINE VAR c-desc-situacao AS CHAR NO-UNDO.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Zoom
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME fpage0
&Scoped-define BROWSE-NAME brTable1

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-int-ds-docto-xml-1 tt-int-ds-docto-xml-2

/* Definitions for BROWSE brTable1                                      */
&Scoped-define FIELDS-IN-QUERY-brTable1 tt-int-ds-docto-xml-1.nNF ~
tt-int-ds-docto-xml-1.serie tt-int-ds-docto-xml-1.cod-emitente ~
fn-desc-emitente(tt-int-ds-docto-xml-1.cod-emitente) @ c-desc-emitente ~
tt-int-ds-docto-xml-1.dEmi ~
fn-situacao(tt-int-ds-docto-xml-1.situacao) @ c-desc-situacao 
&Scoped-define ENABLED-FIELDS-IN-QUERY-brTable1 
&Scoped-define QUERY-STRING-brTable1 FOR EACH tt-int-ds-docto-xml-1 ~
      WHERE tt-int-ds-docto-xml-1.nNF >= c-nr-nota-ini ~
 AND tt-int-ds-docto-xml-1.nNF <= c-nr-nota-fim ~
 AND tt-int-ds-docto-xml-1.serie >= c-serie-ini ~
 AND tt-int-ds-docto-xml-1.serie <= c-serie-fim NO-LOCK
&Scoped-define OPEN-QUERY-brTable1 OPEN QUERY brTable1 FOR EACH tt-int-ds-docto-xml-1 ~
      WHERE tt-int-ds-docto-xml-1.nNF >= c-nr-nota-ini ~
 AND tt-int-ds-docto-xml-1.nNF <= c-nr-nota-fim ~
 AND tt-int-ds-docto-xml-1.serie >= c-serie-ini ~
 AND tt-int-ds-docto-xml-1.serie <= c-serie-fim NO-LOCK.
&Scoped-define TABLES-IN-QUERY-brTable1 tt-int-ds-docto-xml-1
&Scoped-define FIRST-TABLE-IN-QUERY-brTable1 tt-int-ds-docto-xml-1


/* Definitions for BROWSE brTable2                                      */
&Scoped-define FIELDS-IN-QUERY-brTable2 tt-int-ds-docto-xml-2.cod-emitente ~
fn-desc-emitente(tt-int-ds-docto-xml-2.cod-emitente) @ c-desc-emitente ~
tt-int-ds-docto-xml-2.nNF tt-int-ds-docto-xml-2.serie ~
tt-int-ds-docto-xml-2.dEmi ~
fn-situacao(tt-int-ds-docto-xml-2.situacao) @ c-desc-situacao 
&Scoped-define ENABLED-FIELDS-IN-QUERY-brTable2 
&Scoped-define QUERY-STRING-brTable2 FOR EACH tt-int-ds-docto-xml-2 ~
      WHERE tt-int-ds-docto-xml-2.cod-emitente >= i-cod-emitente-ini ~
 AND tt-int-ds-docto-xml-2.cod-emitente <= i-cod-emitente-fim ~
 AND tt-int-ds-docto-xml-2.dEmi >= dt-emit-data-ini ~
 AND tt-int-ds-docto-xml-2.dEmi <= dt-emit-data-fim ~
  NO-LOCK
&Scoped-define OPEN-QUERY-brTable2 OPEN QUERY brTable2 FOR EACH tt-int-ds-docto-xml-2 ~
      WHERE tt-int-ds-docto-xml-2.cod-emitente >= i-cod-emitente-ini ~
 AND tt-int-ds-docto-xml-2.cod-emitente <= i-cod-emitente-fim ~
 AND tt-int-ds-docto-xml-2.dEmi >= dt-emit-data-ini ~
 AND tt-int-ds-docto-xml-2.dEmi <= dt-emit-data-fim ~
  NO-LOCK.
&Scoped-define TABLES-IN-QUERY-brTable2 tt-int-ds-docto-xml-2
&Scoped-define FIRST-TABLE-IN-QUERY-brTable2 tt-int-ds-docto-xml-2


/* Definitions for FRAME fPage1                                         */

/* Definitions for FRAME fPage2                                         */

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS rtToolBar btOK btCancel btHelp 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD fn-desc-emitente wZoom 
FUNCTION fn-desc-emitente RETURNS CHARACTER
  (p-cod-emitente AS INT /* parameter-definitions */ )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD fn-situacao wZoom 
FUNCTION fn-situacao RETURNS CHARACTER
  ( p-situacao AS INT)  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR wZoom AS WIDGET-HANDLE NO-UNDO.

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

DEFINE RECTANGLE rtToolBar
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 90 BY 1.42
     BGCOLOR 7 .

DEFINE BUTTON btcheck1 
     IMAGE-UP FILE "image\im-sav":U
     LABEL "Button 1" 
     SIZE 5.14 BY 1.

DEFINE BUTTON btImplant1 
     LABEL "Implantar" 
     SIZE 10 BY 1.

DEFINE VARIABLE cb-situacao-nota AS INTEGER FORMAT ">9":U INITIAL 4 
     LABEL "Situa‡Æo" 
     VIEW-AS COMBO-BOX INNER-LINES 4
     LIST-ITEM-PAIRS "Pendente",1,
                     "Liberado",2,
                     "Atualizado",3,
                     "Todos",4
     DROP-DOWN-LIST
     SIZE 16 BY 1 NO-UNDO.

DEFINE VARIABLE c-nr-nota-fim AS CHARACTER FORMAT "X(8)":U INITIAL "99999999" 
     VIEW-AS FILL-IN 
     SIZE 11 BY .79 NO-UNDO.

DEFINE VARIABLE c-nr-nota-ini AS CHARACTER FORMAT "X(8)":U INITIAL "0" 
     LABEL "Nota" 
     VIEW-AS FILL-IN 
     SIZE 11 BY .79 NO-UNDO.

DEFINE VARIABLE c-serie-fim AS CHARACTER FORMAT "X(05)":U INITIAL "ZZZZZ" 
     VIEW-AS FILL-IN 
     SIZE 7 BY .79 NO-UNDO.

DEFINE VARIABLE c-serie-ini AS CHARACTER FORMAT "X(05)":U 
     LABEL "Serie" 
     VIEW-AS FILL-IN 
     SIZE 7 BY .79 NO-UNDO.

DEFINE VARIABLE dt-data-fim AS DATE FORMAT "99/99/9999":U 
     VIEW-AS FILL-IN 
     SIZE 11 BY .79 NO-UNDO.

DEFINE VARIABLE dt-data-ini AS DATE FORMAT "99/99/9999":U 
     LABEL "EmissÆo" 
     VIEW-AS FILL-IN 
     SIZE 11 BY .79 NO-UNDO.

DEFINE IMAGE IMAGE-1
     FILENAME "image\ii-fir":U
     SIZE 2.86 BY 1.

DEFINE IMAGE IMAGE-10
     FILENAME "image\ii-las":U
     SIZE 2.86 BY 1.

DEFINE IMAGE IMAGE-13
     FILENAME "image\ii-fir":U
     SIZE 2.86 BY 1.

DEFINE IMAGE IMAGE-14
     FILENAME "image\ii-las":U
     SIZE 2.86 BY 1.

DEFINE IMAGE IMAGE-2
     FILENAME "image\ii-las":U
     SIZE 2.86 BY 1.

DEFINE IMAGE IMAGE-9
     FILENAME "image\ii-fir":U
     SIZE 2.86 BY 1.

DEFINE BUTTON btcheck2 
     IMAGE-UP FILE "image\im-sav":U
     LABEL "bt1 confirma 2" 
     SIZE 5.14 BY 1.

DEFINE BUTTON btImplant2 
     LABEL "Implantar" 
     SIZE 10 BY 1.

DEFINE VARIABLE cb-situacao-emit AS INTEGER FORMAT ">9":U INITIAL 4 
     LABEL "Situa‡Æo" 
     VIEW-AS COMBO-BOX INNER-LINES 4
     LIST-ITEM-PAIRS "Pendente",1,
                     "Liberado",2,
                     "Atualizado",3,
                     "Todos",4
     DROP-DOWN-LIST
     SIZE 16 BY 1 NO-UNDO.

DEFINE VARIABLE dt-emit-data-fim AS DATE FORMAT "99/99/9999":U 
     VIEW-AS FILL-IN 
     SIZE 11 BY .79 NO-UNDO.

DEFINE VARIABLE dt-emit-data-ini AS DATE FORMAT "99/99/9999":U 
     LABEL "EmissÆo" 
     VIEW-AS FILL-IN 
     SIZE 11 BY .79 NO-UNDO.

DEFINE VARIABLE i-cod-emitente-fim AS INTEGER FORMAT ">>>>>>9":U INITIAL 9999999 
     VIEW-AS FILL-IN 
     SIZE 9 BY .79 NO-UNDO.

DEFINE VARIABLE i-cod-emitente-ini AS INTEGER FORMAT ">>>>>>9":U INITIAL 0 
     LABEL "Emitente" 
     VIEW-AS FILL-IN 
     SIZE 11 BY .79 NO-UNDO.

DEFINE IMAGE IMAGE-11
     FILENAME "image\ii-fir":U
     SIZE 2.86 BY 1.

DEFINE IMAGE IMAGE-12
     FILENAME "image\ii-las":U
     SIZE 2.86 BY 1.

DEFINE IMAGE IMAGE-7
     FILENAME "image\ii-fir":U
     SIZE 2.86 BY 1.

DEFINE IMAGE IMAGE-8
     FILENAME "image\ii-las":U
     SIZE 2.86 BY 1.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY brTable1 FOR 
      tt-int-ds-docto-xml-1 SCROLLING.

DEFINE QUERY brTable2 FOR 
      tt-int-ds-docto-xml-2 SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE brTable1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS brTable1 wZoom _STRUCTURED
  QUERY brTable1 NO-LOCK DISPLAY
      tt-int-ds-docto-xml-1.nNF FORMAT "x(16)":U
      tt-int-ds-docto-xml-1.serie FORMAT "x(5)":U WIDTH 6
      tt-int-ds-docto-xml-1.cod-emitente COLUMN-LABEL "Emitente" FORMAT ">>>>>>>>9":U
      fn-desc-emitente(tt-int-ds-docto-xml-1.cod-emitente) @ c-desc-emitente COLUMN-LABEL "Nome" FORMAT "x(30)":U
            WIDTH 30
      tt-int-ds-docto-xml-1.dEmi FORMAT "99/99/9999":U
      fn-situacao(tt-int-ds-docto-xml-1.situacao) @ c-desc-situacao COLUMN-LABEL "Situa‡Æo" FORMAT "x(16)":U
            WIDTH 16
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 82 BY 8.75
         FONT 2.

DEFINE BROWSE brTable2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS brTable2 wZoom _STRUCTURED
  QUERY brTable2 NO-LOCK DISPLAY
      tt-int-ds-docto-xml-2.cod-emitente COLUMN-LABEL "Emitente" FORMAT ">>>>>>>>9":U
      fn-desc-emitente(tt-int-ds-docto-xml-2.cod-emitente) @ c-desc-emitente COLUMN-LABEL "Nome" FORMAT "x(30)":U
            WIDTH 30
      tt-int-ds-docto-xml-2.nNF FORMAT "x(16)":U
      tt-int-ds-docto-xml-2.serie FORMAT "x(5)":U WIDTH 5.57
      tt-int-ds-docto-xml-2.dEmi FORMAT "99/99/9999":U
      fn-situacao(tt-int-ds-docto-xml-2.situacao) @ c-desc-situacao COLUMN-LABEL "Situacao" FORMAT "x(16)":U
            WIDTH 16
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 82 BY 9.25
         FONT 2.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME fpage0
     btOK AT ROW 16.71 COL 2
     btCancel AT ROW 16.71 COL 13
     btHelp AT ROW 16.71 COL 80
     rtToolBar AT ROW 16.5 COL 1
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 90 BY 16.98
         FONT 1 WIDGET-ID 100.

DEFINE FRAME fPage1
     c-nr-nota-ini AT ROW 1.25 COL 12 COLON-ALIGNED WIDGET-ID 2
     c-nr-nota-fim AT ROW 1.25 COL 37.43 COLON-ALIGNED NO-LABEL WIDGET-ID 8
     btcheck1 AT ROW 1.29 COL 80 WIDGET-ID 18
     c-serie-ini AT ROW 2.21 COL 12 COLON-ALIGNED WIDGET-ID 10
     c-serie-fim AT ROW 2.25 COL 37.43 COLON-ALIGNED NO-LABEL WIDGET-ID 12
     cb-situacao-nota AT ROW 3.04 COL 57.86 COLON-ALIGNED WIDGET-ID 28
     dt-data-ini AT ROW 3.17 COL 12 COLON-ALIGNED WIDGET-ID 20
     dt-data-fim AT ROW 3.17 COL 37.43 COLON-ALIGNED NO-LABEL WIDGET-ID 26
     brTable1 AT ROW 4.25 COL 2
     btImplant1 AT ROW 13 COL 2
     IMAGE-1 AT ROW 1.25 COL 29.43 WIDGET-ID 4
     IMAGE-2 AT ROW 1.25 COL 35 WIDGET-ID 6
     IMAGE-9 AT ROW 2.13 COL 29.43 WIDGET-ID 14
     IMAGE-10 AT ROW 2.13 COL 35 WIDGET-ID 16
     IMAGE-13 AT ROW 3.17 COL 29.43 WIDGET-ID 22
     IMAGE-14 AT ROW 3.17 COL 35 WIDGET-ID 24
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 3.5 ROW 2.45
         SIZE 84.43 BY 13.29
         FONT 1 WIDGET-ID 100.

DEFINE FRAME fPage2
     i-cod-emitente-ini AT ROW 1.25 COL 16 COLON-ALIGNED WIDGET-ID 2
     i-cod-emitente-fim AT ROW 1.25 COL 39 COLON-ALIGNED NO-LABEL WIDGET-ID 8
     btcheck2 AT ROW 1.29 COL 80 WIDGET-ID 18
     dt-emit-data-ini AT ROW 2.25 COL 16 COLON-ALIGNED WIDGET-ID 20
     dt-emit-data-fim AT ROW 2.25 COL 39 COLON-ALIGNED NO-LABEL WIDGET-ID 26
     cb-situacao-emit AT ROW 2.25 COL 58 COLON-ALIGNED WIDGET-ID 28
     brTable2 AT ROW 3.75 COL 2
     btImplant2 AT ROW 13 COL 2
     IMAGE-7 AT ROW 1.25 COL 31 WIDGET-ID 4
     IMAGE-8 AT ROW 1.25 COL 36.57 WIDGET-ID 6
     IMAGE-11 AT ROW 2.25 COL 31 WIDGET-ID 22
     IMAGE-12 AT ROW 2.25 COL 36.57 WIDGET-ID 24
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 3.57 ROW 2.45
         SIZE 84.43 BY 13.29
         FONT 1 WIDGET-ID 100.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Zoom
   Allow: Basic,Browse,DB-Fields,Window,Query
   Add Fields to: Neither
   Other Settings: COMPILE
   Temp-Tables and Buffers:
      TABLE: tt-int-ds-docto-xml-1 T "?" NO-UNDO emsesp int-ds-docto-xml
      ADDITIONAL-FIELDS:
          fields r-rowid as rowid
      END-FIELDS.
      TABLE: tt-int-ds-docto-xml-2 T "?" NO-UNDO emsesp int-ds-docto-xml
      ADDITIONAL-FIELDS:
          fields r-rowid as rowid
      END-FIELDS.
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
IF SESSION:DISPLAY-TYPE = "GUI":U THEN
  CREATE WINDOW wZoom ASSIGN
         HIDDEN             = YES
         TITLE              = ""
         HEIGHT             = 17
         WIDTH              = 90
         MAX-HEIGHT         = 17
         MAX-WIDTH          = 90
         VIRTUAL-HEIGHT     = 17
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _INCLUDED-LIB wZoom 
/* ************************* Included-Libraries *********************** */

{zoom/zoom.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME




/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW wZoom
  NOT-VISIBLE,,RUN-PERSISTENT                                           */
/* REPARENT FRAME */
ASSIGN FRAME fPage1:FRAME = FRAME fpage0:HANDLE
       FRAME fPage2:FRAME = FRAME fpage0:HANDLE.

/* SETTINGS FOR FRAME fpage0
   FRAME-NAME                                                           */
/* SETTINGS FOR FRAME fPage1
                                                                        */
/* BROWSE-TAB brTable1 dt-data-fim fPage1 */
/* SETTINGS FOR FRAME fPage2
                                                                        */
/* BROWSE-TAB brTable2 cb-situacao-emit fPage2 */
IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(wZoom)
THEN wZoom:HIDDEN = yes.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE brTable1
/* Query rebuild information for BROWSE brTable1
     _TblList          = "Temp-Tables.tt-int-ds-docto-xml-1"
     _Options          = "NO-LOCK"
     _Where[1]         = "Temp-Tables.tt-int-ds-docto-xml-1.nNF >= c-nr-nota-ini
 AND Temp-Tables.tt-int-ds-docto-xml-1.nNF <= c-nr-nota-fim
 AND Temp-Tables.tt-int-ds-docto-xml-1.serie >= c-serie-ini
 AND Temp-Tables.tt-int-ds-docto-xml-1.serie <= c-serie-fim"
     _FldNameList[1]   = Temp-Tables.tt-int-ds-docto-xml-1.nNF
     _FldNameList[2]   > Temp-Tables.tt-int-ds-docto-xml-1.serie
"tt-int-ds-docto-xml-1.serie" ? ? "character" ? ? ? ? ? ? no ? no no "6" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[3]   > Temp-Tables.tt-int-ds-docto-xml-1.cod-emitente
"tt-int-ds-docto-xml-1.cod-emitente" "Emitente" ? "integer" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[4]   > "_<CALC>"
"fn-desc-emitente(tt-int-ds-docto-xml-1.cod-emitente) @ c-desc-emitente" "Nome" "x(30)" ? ? ? ? ? ? ? no ? no no "30" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[5]   = Temp-Tables.tt-int-ds-docto-xml-1.dEmi
     _FldNameList[6]   > "_<CALC>"
"fn-situacao(tt-int-ds-docto-xml-1.situacao) @ c-desc-situacao" "Situa‡Æo" "x(16)" ? ? ? ? ? ? ? no ? no no "16" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _Query            is NOT OPENED
*/  /* BROWSE brTable1 */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE brTable2
/* Query rebuild information for BROWSE brTable2
     _TblList          = "Temp-Tables.tt-int-ds-docto-xml-2"
     _Options          = "NO-LOCK"
     _Where[1]         = "Temp-Tables.tt-int-ds-docto-xml-2.cod-emitente >= i-cod-emitente-ini
 AND Temp-Tables.tt-int-ds-docto-xml-2.cod-emitente <= i-cod-emitente-fim
 AND Temp-Tables.tt-int-ds-docto-xml-2.dEmi >= dt-emit-data-ini
 AND Temp-Tables.tt-int-ds-docto-xml-2.dEmi <= dt-emit-data-fim
 "
     _FldNameList[1]   > Temp-Tables.tt-int-ds-docto-xml-2.cod-emitente
"tt-int-ds-docto-xml-2.cod-emitente" "Emitente" ? "integer" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[2]   > "_<CALC>"
"fn-desc-emitente(tt-int-ds-docto-xml-2.cod-emitente) @ c-desc-emitente" "Nome" "x(30)" ? ? ? ? ? ? ? no ? no no "30" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[3]   = Temp-Tables.tt-int-ds-docto-xml-2.nNF
     _FldNameList[4]   > Temp-Tables.tt-int-ds-docto-xml-2.serie
"tt-int-ds-docto-xml-2.serie" ? ? "character" ? ? ? ? ? ? no ? no no "5.57" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[5]   = Temp-Tables.tt-int-ds-docto-xml-2.dEmi
     _FldNameList[6]   > "_<CALC>"
"fn-situacao(tt-int-ds-docto-xml-2.situacao) @ c-desc-situacao" "Situacao" "x(16)" ? ? ? ? ? ? ? no ? no no "16" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _Query            is NOT OPENED
*/  /* BROWSE brTable2 */
&ANALYZE-RESUME

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

&ANALYZE-SUSPEND _QUERY-BLOCK FRAME fPage2
/* Query rebuild information for FRAME fPage2
     _Query            is NOT OPENED
*/  /* FRAME fPage2 */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME wZoom
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL wZoom wZoom
ON END-ERROR OF wZoom
OR ENDKEY OF {&WINDOW-NAME} ANYWHERE DO:
  /* This case occurs when the user presses the "Esc" key.
     In a persistently run window, just ignore this.  If we did not, the
     application would exit. */
  IF THIS-PROCEDURE:PERSISTENT THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL wZoom wZoom
ON WINDOW-CLOSE OF wZoom
DO:
  /* This event will close the window and terminate the procedure.  */
  APPLY "CLOSE":U TO THIS-PROCEDURE.
  RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME brTable1
&Scoped-define FRAME-NAME fPage1
&Scoped-define SELF-NAME brTable1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL brTable1 wZoom
ON ROW-DISPLAY OF brTable1 IN FRAME fPage1
DO:

   IF AVAIL tt-int-ds-docto-xml-1 THEN DO:

      IF tt-int-ds-docto-xml-1.situacao = 1 THEN
         ASSIGN c-desc-situacao:BGCOLOR IN BROWSE brTable1 = 12.
      ELSE IF tt-int-ds-docto-xml-1.situacao = 2 THEN
         ASSIGN c-desc-situacao:BGCOLOR IN BROWSE brTable1 = 14.
      ELSE 
          ASSIGN c-desc-situacao:BGCOLOR IN BROWSE brTable1 = 2.

           
   END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME brTable2
&Scoped-define FRAME-NAME fPage2
&Scoped-define SELF-NAME brTable2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL brTable2 wZoom
ON ROW-DISPLAY OF brTable2 IN FRAME fPage2
DO:
  
  IF AVAIL tt-int-ds-docto-xml-2 THEN DO:

      IF tt-int-ds-docto-xml-2.situacao = 1 THEN
         ASSIGN c-desc-situacao:BGCOLOR IN BROWSE brTable2 = 12.
      ELSE IF tt-int-ds-docto-xml-2.situacao = 2 THEN
         ASSIGN c-desc-situacao:BGCOLOR IN BROWSE brTable2 = 14.
      ELSE 
          ASSIGN c-desc-situacao:BGCOLOR IN BROWSE brTable2 = 2.

           
  END.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME fpage0
&Scoped-define SELF-NAME btCancel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btCancel wZoom
ON CHOOSE OF btCancel IN FRAME fpage0 /* Cancelar */
DO:
    APPLY "CLOSE":U TO THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME fPage1
&Scoped-define SELF-NAME btcheck1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btcheck1 wZoom
ON CHOOSE OF btcheck1 IN FRAME fPage1 /* Button 1 */
DO:
  
  ASSIGN INPUT FRAME fpage1 c-nr-nota-ini c-nr-nota-fim 
                            c-serie-ini c-serie-fim 
                            dt-data-ini dt-data-fim
                            cb-situacao-nota.
  
  RUN setConstraints IN THIS-PROCEDURE (INPUT 1).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME fPage2
&Scoped-define SELF-NAME btcheck2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btcheck2 wZoom
ON CHOOSE OF btcheck2 IN FRAME fPage2 /* bt1 confirma 2 */
DO:
  
 ASSIGN INPUT FRAME fpage2 i-cod-emitente-ini i-cod-emitente-fim 
                           dt-emit-data-ini dt-emit-data-fim
                           cb-situacao-emit.

 RUN setConstraints IN THIS-PROCEDURE (INPUT 2).

  
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME fpage0
&Scoped-define SELF-NAME btHelp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btHelp wZoom
ON CHOOSE OF btHelp IN FRAME fpage0 /* Ajuda */
DO:
    {include/ajuda.i}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME fPage1
&Scoped-define SELF-NAME btImplant1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btImplant1 wZoom
ON CHOOSE OF btImplant1 IN FRAME fPage1 /* Implantar */
DO:
    {zoom/implant.i &ProgramImplant="intprg\int002.w"
                    &PageNumber="1"}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME fPage2
&Scoped-define SELF-NAME btImplant2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btImplant2 wZoom
ON CHOOSE OF btImplant2 IN FRAME fPage2 /* Implantar */
DO:
    {zoom/implant.i &ProgramImplant="intprg\int002.w"
                    &PageNumber="2"}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME fpage0
&Scoped-define SELF-NAME btOK
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btOK wZoom
ON CHOOSE OF btOK IN FRAME fpage0 /* OK */
DO:
    RUN returnValues IN THIS-PROCEDURE.
    
    APPLY "CLOSE":U TO THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME brTable1
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK wZoom 


/* ***************************  Main Block  *************************** */

/*:T--- L¢gica para inicializa‡Æo do programam ---*/
{zoom/mainblock.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE afterinitializeinterface wZoom 
PROCEDURE afterinitializeinterface :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

ASSIGN c-nr-nota-ini:sensitive  IN FRAME fpage1 = YES
       c-nr-nota-fim:sensitive  IN FRAME fpage1 = YES
       c-serie-ini:sensitive  IN FRAME fpage1 = YES
       c-serie-fim:sensitive  IN FRAME fpage1 = YES
       dt-data-ini:sensitive  IN FRAME fpage1 = YES
       dt-data-fim:sensitive  IN FRAME fpage1 = YES
       cb-situacao-nota:sensitive  IN FRAME fpage1 = YES
       btcheck1:sensitive  IN FRAME fpage1 = YES 
       i-cod-emitente-ini:sensitive  IN FRAME fpage2 = YES
       i-cod-emitente-fim:sensitive  IN FRAME fpage2 = YES
       dt-emit-data-ini:sensitive  IN FRAME fpage2 = YES
       dt-emit-data-fim:sensitive  IN FRAME fpage2 = YES
       cb-situacao-emit:sensitive  IN FRAME fpage2 = YES
       btcheck2:sensitive  IN FRAME fpage2 = YES.
       

ASSIGN  c-nr-nota-ini:SCREEN-VALUE IN FRAME fpage1 = "0"
        c-nr-nota-fim:SCREEN-VALUE IN FRAME fpage1 = "99999999"
        c-serie-ini:SCREEN-VALUE   IN FRAME fpage1 = ""
        c-serie-fim:SCREEN-VALUE   IN FRAME fpage1 = "ZZZZZZZZZZZZ"
        dt-data-ini:SCREEN-VALUE   IN FRAME fpage1 = STRING(TODAY - 30)
        dt-data-fim:SCREEN-VALUE   IN FRAME fpage1 = STRING(TODAY)
        cb-situacao-nota:SCREEN-VALUE IN FRAME fpage1 = "4"
        i-cod-emitente-ini:SCREEN-VALUE  IN FRAME fpage2 = "0"
        i-cod-emitente-fim:SCREEN-VALUE  IN FRAME fpage2 = "9999999"
        dt-emit-data-ini:SCREEN-VALUE    IN FRAME fpage2 = STRING(TODAY - 30)
        dt-emit-data-fim:SCREEN-VALUE    IN FRAME fpage2 = STRING(TODAY) 
        cb-situacao-emit:SCREEN-VALUE    IN FRAME fpage2 = "4".

          
        
        

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ApplyOffEnd wZoom 
PROCEDURE ApplyOffEnd :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    DEFINE INPUT PARAMETER pPageNumber AS INTEGER NO-UNDO.

    RETURN "OK":U.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ApplyOffHome wZoom 
PROCEDURE ApplyOffHome :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
DEFINE INPUT PARAMETER pPageNumber AS INTEGER NO-UNDO.

    RETURN "OK":U.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE initializeDBOs wZoom 
PROCEDURE initializeDBOs :
/*:T------------------------------------------------------------------------------
  Purpose:     Inicializa DBOs
  Parameters:  
  Notes:       
------------------------------------------------------------------------------*/
    
    /*:T--- Verifica se o DBO j  est  inicializado ---*/
    IF NOT VALID-HANDLE({&hDBOTable1}) THEN DO:
        {btb/btb008za.i1 intprg\intbo002a.p YES}
        {btb/btb008za.i2 intprg\intbo002a.p '' {&hDBOTable1}} 
    END.
    
    RUN setConstraintNota IN {&hDBOTable1} (INPUT "0",
                                            INPUT "99999999",
                                            INPUT "",
                                            INPUT "ZZZZZ",
                                            INPUT TODAY - 30,
                                            INPUT TODAY ,
                                            INPUT 4) NO-ERROR.
    
    /*:T--- Verifica se o DBO j  est  inicializado ---*/
    IF NOT VALID-HANDLE({&hDBOTable2}) THEN DO:
        {btb/btb008za.i1 intprg\intbo002a.p YES}
        {btb/btb008za.i2 intprg\intbo002a.p '' {&hDBOTable2}} 
    END.
    
    RUN setConstraintEmitente IN {&hDBOTable2} (INPUT 0,
                                                INPUT 9999999,
                                                INPUT "",
                                                INPUT "ZZZZZ",
                                                INPUT 0,
                                                INPUT 999999999) NO-ERROR.
    
    RETURN "OK":U.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE openQueries wZoom 
PROCEDURE openQueries :
/*:T------------------------------------------------------------------------------
  Purpose:     Atualiza browsers
  Parameters:  
  Notes:       
------------------------------------------------------------------------------*/
    
    {zoom/openqueries.i &Query="Nota"
                        &PageNumber="1"}
    
    {zoom/openqueries.i &Query="Emitente"
                        &PageNumber="2"}
    
    RETURN "OK":U.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE returnFieldsPage1 wZoom 
PROCEDURE returnFieldsPage1 :
/*:T------------------------------------------------------------------------------
  Purpose:     Retorna valores dos campos da p gina 1
  Parameters:  recebe nome do campo
               retorna valor do campo
  Notes:       
------------------------------------------------------------------------------*/
    
    DEFINE  INPUT PARAMETER pcField      AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER pcFieldValue AS CHARACTER NO-UNDO.
    
    IF AVAILABLE {&ttTable1} THEN DO:
        CASE pcField:
            WHEN "nnf":U THEN ASSIGN pcFieldValue          = STRING({&ttTable1}.nnf).
            WHEN "serie":U THEN ASSIGN pcFieldValue        = STRING({&ttTable1}.serie).
            WHEN "cod-emitente":U THEN ASSIGN pcFieldValue = STRING({&ttTable1}.cod-emitente).
            WHEN "tipo-nota":U THEN ASSIGN pcFieldValue    = STRING({&ttTable1}.tipo-nota).
        END CASE.
    END.
    
    RETURN "OK":U.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE returnFieldsPage2 wZoom 
PROCEDURE returnFieldsPage2 :
/*:T------------------------------------------------------------------------------
  Purpose:     Retorna valores dos campos da p gina 2
  Parameters:  recebe nome do campo
               retorna valor do campo
  Notes:       
------------------------------------------------------------------------------*/
    
    DEFINE  INPUT PARAMETER pcField      AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER pcFieldValue AS CHARACTER NO-UNDO.
    
    IF AVAILABLE {&ttTable2} THEN DO:
        CASE pcField:
            WHEN "nnf":U THEN ASSIGN pcFieldValue          = STRING({&ttTable1}.nnf).
            WHEN "serie":U THEN ASSIGN pcFieldValue        = STRING({&ttTable1}.serie).
            WHEN "cod-emitente":U THEN ASSIGN pcFieldValue = STRING({&ttTable1}.cod-emitente).
            WHEN "tipo-nota":U THEN ASSIGN pcFieldValue    = STRING({&ttTable1}.tipo-nota).
        END CASE.
    END.
    
    RETURN "OK":U.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setConstraints wZoom 
PROCEDURE setConstraints :
/*:T------------------------------------------------------------------------------
  Purpose:     Seta constraints e atualiza o browse, conforme n£mero da p gina
               passado como parƒmetro
  Parameters:  recebe n£mero da p gina
  Notes:       
------------------------------------------------------------------------------*/
    
    DEFINE INPUT PARAMETER pPageNumber AS INTEGER NO-UNDO.
    
    /*:T--- Seta constraints conforme n£mero da p gina ---*/
    CASE pPageNumber:
        WHEN 1 THEN
            /*:T--- Seta Constraints para o DBO Table1 ---*/
            RUN setConstraintNota IN {&hDBOTable1} (INPUT c-nr-nota-ini,
                                                    INPUT c-nr-nota-fim,
                                                    INPUT c-serie-ini,
                                                    INPUT c-serie-fim,
                                                    INPUT dt-data-ini,
                                                    INPUT dt-data-fim,
                                                    INPUT cb-situacao-nota).
        WHEN 2 THEN
            /*:T--- Seta Constraints para o DBO Table2 ---*/
            RUN setConstraintEmitente IN {&hDBOTable2} (INPUT i-cod-emitente-ini,   
                                                        INPUT i-cod-emitente-fim,
                                                        INPUT dt-emit-data-ini,
                                                        INPUT dt-emit-data-fim,
                                                        INPUT cb-situacao-emit).

     END CASE.  
    /*:T--- Seta vari vel iConstraintPageNumber com o n£INPUT c-serie-fim).mero da p gina atual 
          Esta vari vel ‚ utilizada no m‚todo openQueries ---*/
    ASSIGN iConstraintPageNumber = pPageNumber.
    
    /*:T--- Atualiza browse ---*/
    RUN openQueries IN THIS-PROCEDURE.
    
    RETURN "OK":U.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION fn-desc-emitente wZoom 
FUNCTION fn-desc-emitente RETURNS CHARACTER
  (p-cod-emitente AS INT /* parameter-definitions */ ) :
/*------------------------------------------------------------------------------
  Purpose:  
    Notes:  
------------------------------------------------------------------------------*/

  FIND FIRST emitente NO-LOCK WHERE
             emitente.cod-emitente = p-cod-emitente NO-ERROR.
  IF AVAIL emitente THEN
     RETURN emitente.nome-emit.
  ELSE 
     RETURN "".   

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION fn-situacao wZoom 
FUNCTION fn-situacao RETURNS CHARACTER
  ( p-situacao AS INT) :
/*------------------------------------------------------------------------------
  Purpose:  
    Notes:  
------------------------------------------------------------------------------*/
IF p-situacao = 1 THEN
   RETURN "Pendente".   
IF p-situacao = 2 THEN
   RETURN "Liberado".   
IF p-situacao = 3 THEN
   RETURN "Atualizado".   


END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

