&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
*/
&Scoped-define WINDOW-NAME wWindow
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS wWindow 
/********************************************************************************
** Programa: int550- Monitor de Arquivos Pendentes NDD
**
** Versao : 12 - 20/09/2018 - Alessandro V Baccin
**
********************************************************************************/
{include/i-prgvrs.i int550 2.12.02.AVB}
{cdp/cdcfgdis.i}
{utp/ut-glob.i}

/* Variaveis e procedures para tratamento de XML - NDD Web */
{xmlinc/xmlndd.i}

/* Carrega API auxiliar processamento de XML */
{xmlinc/xmlloadgenxml.i &GenXml="hGenXML" &GXReturnValue="cReturnValue"}

CREATE WIDGET-POOL.

/* Preprocessors Definitions ---                                      */
&GLOBAL-DEFINE Program        int550
&GLOBAL-DEFINE Version        2.12.02.AVB

&GLOBAL-DEFINE WindowType     Master

&GLOBAL-DEFINE Folder         YES
&GLOBAL-DEFINE InitialPage    1
&GLOBAL-DEFINE FolderLabels   Arquivos, XML

&GLOBAL-DEFINE page0Widgets   btQueryJoins btReportsJoins btExit btHelp cCaminhoTela ~
                              btOK btCancel btHelp2 btAtualiza btBuscaXML cChaveNFe
&GLOBAL-DEFINE page1Widgets   brArquivos brNotas
&GLOBAL-DEFINE page2Widgets   edXML

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */
def var iCod-emitente like emitente.cod-emitente no-undo.
def var cNome-abrev like emitente.nome-abrev no-undo.
def var cCod-Estabel like estabelec.cod-estabel no-undo.

define temp-table tt-arquivos
    field arquivo as char format "X(256)" label "Arquivo"
    field conteudo as char format "X(32000)"
    index chave /*is unique*/
    arquivo.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Window
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME fpage0
&Scoped-define BROWSE-NAME brArquivos

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-arquivos tt-NDD_ENTRYINTEGRATION

/* Definitions for BROWSE brArquivos                                    */
&Scoped-define FIELDS-IN-QUERY-brArquivos tt-arquivos.arquivo tt-arquivos.conteudo   
&Scoped-define ENABLED-FIELDS-IN-QUERY-brArquivos   
&Scoped-define SELF-NAME brArquivos
&Scoped-define QUERY-STRING-brArquivos FOR EACH tt-arquivos NO-LOCK     BY tt-arquivos.ARQUIVO
&Scoped-define OPEN-QUERY-brArquivos OPEN QUERY {&SELF-NAME} FOR EACH tt-arquivos NO-LOCK     BY tt-arquivos.ARQUIVO.
&Scoped-define TABLES-IN-QUERY-brArquivos tt-arquivos
&Scoped-define FIRST-TABLE-IN-QUERY-brArquivos tt-arquivos


/* Definitions for BROWSE brNotas                                       */
&Scoped-define FIELDS-IN-QUERY-brNotas tt-NDD_ENTRYINTEGRATION.CNPJDEST fncod-estabel(string(tt-NDD_ENTRYINTEGRATION.CNPJDEST,"99999999999999")) @ cCod-Estabel tt-NDD_ENTRYINTEGRATION.CNPJEMIT fncod-emitente(string(tt-NDD_ENTRYINTEGRATION.CNPJEMIT,"99999999999999")) @ iCod-Emitente fnnome-abrev(string(tt-NDD_ENTRYINTEGRATION.CNPJEMIT,"99999999999999")) @ cNome-Abrev tt-NDD_ENTRYINTEGRATION.EMISSIONDATE tt-NDD_ENTRYINTEGRATION.SERIE tt-NDD_ENTRYINTEGRATION.DOCUMENTNUMBER tt-NDD_ENTRYINTEGRATION.int500 tt-NDD_ENTRYINTEGRATION.processado tt-NDD_ENTRYINTEGRATION.retOK   
&Scoped-define ENABLED-FIELDS-IN-QUERY-brNotas   
&Scoped-define SELF-NAME brNotas
&Scoped-define QUERY-STRING-brNotas FOR EACH tt-NDD_ENTRYINTEGRATION NO-LOCK     BY tt-NDD_ENTRYINTEGRATION.CNPJDEST      BY tt-NDD_ENTRYINTEGRATION.CNPJEMIT       BY tt-NDD_ENTRYINTEGRATION.EMISSIONDATE        BY tt-NDD_ENTRYINTEGRATION.SERIE         BY tt-NDD_ENTRYINTEGRATION.DOCUMENTNUMBER
&Scoped-define OPEN-QUERY-brNotas OPEN QUERY {&SELF-NAME} FOR EACH tt-NDD_ENTRYINTEGRATION NO-LOCK     BY tt-NDD_ENTRYINTEGRATION.CNPJDEST      BY tt-NDD_ENTRYINTEGRATION.CNPJEMIT       BY tt-NDD_ENTRYINTEGRATION.EMISSIONDATE        BY tt-NDD_ENTRYINTEGRATION.SERIE         BY tt-NDD_ENTRYINTEGRATION.DOCUMENTNUMBER.
&Scoped-define TABLES-IN-QUERY-brNotas tt-NDD_ENTRYINTEGRATION
&Scoped-define FIRST-TABLE-IN-QUERY-brNotas tt-NDD_ENTRYINTEGRATION


/* Definitions for FRAME fPage1                                         */

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS rtToolBar-2 rtToolBar btQueryJoins ~
btReportsJoins btExit btHelp btAtualiza btBuscaXML cChaveNFe btOK btCancel ~
btHelp2 
&Scoped-Define DISPLAYED-OBJECTS cCaminhoTela cChaveNFe 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD fnCod-Emitente wWindow 
FUNCTION fnCod-Emitente RETURNS integer
  ( pcnpj as char )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD fnCod-Estabel wWindow 
FUNCTION fnCod-Estabel RETURNS CHARACTER
  ( pcnpj as char )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD fnNome-Abrev wWindow 
FUNCTION fnNome-Abrev RETURNS CHARACTER
  ( pcnpj as char )  FORWARD.

/* _UIB-CODE-BLOCK-END */
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
DEFINE BUTTON btAtualiza 
     IMAGE-UP FILE "image/im-relo.bmp":U
     IMAGE-INSENSITIVE FILE "image/ii-relo.bmp":U
     LABEL "Query Joins" 
     SIZE 4 BY 1.25
     FONT 4.

DEFINE BUTTON btBuscaXML 
     IMAGE-UP FILE "image/gera-default.bmp":U
     IMAGE-INSENSITIVE FILE "image/gera-disable.bmp":U
     LABEL "Busca XML" 
     SIZE 4 BY 1.25 TOOLTIP "Buscar XML na NDD"
     FONT 4.

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

DEFINE VARIABLE cCaminhoTela AS CHARACTER FORMAT "X(256)":U 
     LABEL "Caminho" 
     VIEW-AS FILL-IN 
     SIZE 120.57 BY .79 NO-UNDO.

DEFINE VARIABLE cChaveNFe AS CHARACTER FORMAT "X(44)":U 
     LABEL "Chave NFe" 
     VIEW-AS FILL-IN 
     SIZE 52 BY .79 NO-UNDO.

DEFINE RECTANGLE rtToolBar
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 135 BY 1.42
     BGCOLOR 7 .

DEFINE RECTANGLE rtToolBar-2
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 135 BY 1.5
     BGCOLOR 7 .

DEFINE VARIABLE edXML AS CHARACTER 
     VIEW-AS EDITOR SCROLLBAR-VERTICAL LARGE
     SIZE 132 BY 17.79 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY brArquivos FOR 
      tt-arquivos SCROLLING.

DEFINE QUERY brNotas FOR 
      tt-NDD_ENTRYINTEGRATION SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE brArquivos
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS brArquivos wWindow _FREEFORM
  QUERY brArquivos NO-LOCK DISPLAY
      tt-arquivos.arquivo column-label "Arquivo"
      tt-arquivos.conteudo column-label "XMLString"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS NO-SCROLLBAR-VERTICAL SIZE 130.57 BY 8.79
         FONT 1 ROW-HEIGHT-CHARS .53.

DEFINE BROWSE brNotas
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS brNotas wWindow _FREEFORM
  QUERY brNotas NO-LOCK DISPLAY
      tt-NDD_ENTRYINTEGRATION.CNPJDEST COLUMN-LABEL "Destino" FORMAT ">>>>>>>>>>>>>>9":U
            WIDTH 12
      fncod-estabel(string(tt-NDD_ENTRYINTEGRATION.CNPJDEST,"99999999999999")) @ cCod-Estabel format "X(3)"
      tt-NDD_ENTRYINTEGRATION.CNPJEMIT COLUMN-LABEL "Emitente" FORMAT ">>>>>>>>>>>>>>9":U
            WIDTH 12
      fncod-emitente(string(tt-NDD_ENTRYINTEGRATION.CNPJEMIT,"99999999999999")) @ iCod-Emitente
      fnnome-abrev(string(tt-NDD_ENTRYINTEGRATION.CNPJEMIT,"99999999999999")) @ cNome-Abrev format "X(12)"
      tt-NDD_ENTRYINTEGRATION.EMISSIONDATE COLUMN-LABEL "Emissao" FORMAT "99/99/9999":U
            WIDTH 12.5
      tt-NDD_ENTRYINTEGRATION.SERIE COLUMN-LABEL "Ser" FORMAT ">>>>9":U
            WIDTH 3
      tt-NDD_ENTRYINTEGRATION.DOCUMENTNUMBER COLUMN-LABEL "Nota" FORMAT ">>>>>>>>9":U
            WIDTH 8
      tt-NDD_ENTRYINTEGRATION.int500     label "INT500" format "x(3)"
      tt-NDD_ENTRYINTEGRATION.processado label "Proc" format "x(3)"
      tt-NDD_ENTRYINTEGRATION.retOK COLUMN-LABEL "Observaá‰es" FORMAT "X(55)":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 130.57 BY 8.79
         FONT 1 ROW-HEIGHT-CHARS .53.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME fpage0
     btQueryJoins AT ROW 1.13 COL 119.43 HELP
          "Consultas relacionadas"
     btReportsJoins AT ROW 1.13 COL 123.43 HELP
          "Relat¢rios relacionados"
     btExit AT ROW 1.13 COL 127.43 HELP
          "Sair"
     btHelp AT ROW 1.13 COL 131.43 HELP
          "Ajuda"
     btAtualiza AT ROW 2.58 COL 131.57 HELP
          "Atualiza consulta" WIDGET-ID 4
     cCaminhoTela AT ROW 2.88 COL 8.57 COLON-ALIGNED WIDGET-ID 20
     btBuscaXML AT ROW 3.92 COL 131.57 HELP
          "Busca XML da nota na NDD" WIDGET-ID 24
     cChaveNFe AT ROW 4.21 COL 77 COLON-ALIGNED WIDGET-ID 22
     btOK AT ROW 23.63 COL 2
     btCancel AT ROW 23.63 COL 13
     btHelp2 AT ROW 23.63 COL 125.43
     rtToolBar-2 AT ROW 1 COL 1
     rtToolBar AT ROW 23.42 COL 1
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 135.13 BY 24.03
         FONT 1 WIDGET-ID 100.

DEFINE FRAME fPage2
     edXML AT ROW 1 COL 1 NO-LABEL WIDGET-ID 2
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 2.25 ROW 5.27
         SIZE 132.5 BY 17.87
         FONT 1 WIDGET-ID 900.

DEFINE FRAME fPage1
     brArquivos AT ROW 1 COL 1 WIDGET-ID 1000
     brNotas AT ROW 9.79 COL 1 WIDGET-ID 800
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 2.25 ROW 5.27
         SIZE 132.5 BY 17.87
         FONT 1 WIDGET-ID 700.


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
         HEIGHT             = 24.04
         WIDTH              = 135.14
         MAX-HEIGHT         = 24.04
         MAX-WIDTH          = 135.14
         VIRTUAL-HEIGHT     = 24.04
         VIRTUAL-WIDTH      = 135.14
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
ASSIGN FRAME fPage1:FRAME = FRAME fpage0:HANDLE
       FRAME fPage2:FRAME = FRAME fpage0:HANDLE.

/* SETTINGS FOR FRAME fpage0
   FRAME-NAME                                                           */
/* SETTINGS FOR FILL-IN cCaminhoTela IN FRAME fpage0
   NO-ENABLE                                                            */
/* SETTINGS FOR FRAME fPage1
                                                                        */
/* BROWSE-TAB brArquivos 1 fPage1 */
/* BROWSE-TAB brNotas brArquivos fPage1 */
/* SETTINGS FOR FRAME fPage2
                                                                        */
ASSIGN 
       edXML:READ-ONLY IN FRAME fPage2        = TRUE.

IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(wWindow)
THEN wWindow:HIDDEN = yes.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE brArquivos
/* Query rebuild information for BROWSE brArquivos
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH tt-arquivos NO-LOCK
    BY tt-arquivos.ARQUIVO
     _END_FREEFORM
     _Options          = "NO-LOCK"
     _OrdList          = "Temp-Tables.tt-NDD_ENTRYINTEGRATION.CNPJDEST|yes,Temp-Tables.tt-NDD_ENTRYINTEGRATION.CNPJEMIT|yes,Temp-Tables.tt-NDD_ENTRYINTEGRATION.EMISSIONDATE|yes,Temp-Tables.tt-NDD_ENTRYINTEGRATION.SERIE|yes,Temp-Tables.tt-NDD_ENTRYINTEGRATION.DOCUMENTNUMBER|yes"
     _Query            is NOT OPENED
*/  /* BROWSE brArquivos */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE brNotas
/* Query rebuild information for BROWSE brNotas
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH tt-NDD_ENTRYINTEGRATION NO-LOCK
    BY tt-NDD_ENTRYINTEGRATION.CNPJDEST
     BY tt-NDD_ENTRYINTEGRATION.CNPJEMIT
      BY tt-NDD_ENTRYINTEGRATION.EMISSIONDATE
       BY tt-NDD_ENTRYINTEGRATION.SERIE
        BY tt-NDD_ENTRYINTEGRATION.DOCUMENTNUMBER.
     _END_FREEFORM
     _Options          = "NO-LOCK"
     _OrdList          = "Temp-Tables.tt-NDD_ENTRYINTEGRATION.CNPJDEST|yes,Temp-Tables.tt-NDD_ENTRYINTEGRATION.CNPJEMIT|yes,Temp-Tables.tt-NDD_ENTRYINTEGRATION.EMISSIONDATE|yes,Temp-Tables.tt-NDD_ENTRYINTEGRATION.SERIE|yes,Temp-Tables.tt-NDD_ENTRYINTEGRATION.DOCUMENTNUMBER|yes"
     _Query            is NOT OPENED
*/  /* BROWSE brNotas */
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
     _Options          = "SHARE-LOCK KEEP-EMPTY"
     _Query            is NOT OPENED
*/  /* FRAME fPage2 */
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


&Scoped-define BROWSE-NAME brArquivos
&Scoped-define FRAME-NAME fPage1
&Scoped-define SELF-NAME brArquivos
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL brArquivos wWindow
ON MOUSE-SELECT-DBLCLICK OF brArquivos IN FRAME fPage1
DO:
    if avail tt-arquivos then do:
        edXML:screen-value in frame fPage2 = "".
        edXML:read-file(cCaminhoTMP + tt-arquivos.arquivo) in frame fPage2 no-error.
        RUN utils\winopen.p (cCaminhoTMP + tt-arquivos.arquivo,3).
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL brArquivos wWindow
ON VALUE-CHANGED OF brArquivos IN FRAME fPage1
DO:
    empty temp-table tt-ndd_entryintegration.
    assign cFile = cCaminhoTMP + "\" + tt-arquivos.arquivo.
    copy-lob FILE cFile TO cReturnValue.
    run pi-processa-retorno-cold (input no).
    RUN pi-openQueryNotas.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME brNotas
&Scoped-define SELF-NAME brNotas
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL brNotas wWindow
ON MOUSE-SELECT-DBLCLICK OF brNotas IN FRAME fPage1
DO:
    if avail tt-NDD_ENTRYINTEGRATION then do:
        edXML:screen-value in frame fPage2 = "".
        /* gravar arquivo para tela quando n∆o grava na base */
        cFileXML =  cCaminhoNDD + "tmp\NF" + "_" + c-seg-usuario + "_" +
                    string(today,"99-99-9999") + "_" + replace(string(time,"HH:MM:SS"),':','_') + "_" + string(iId) + '.xml'.
        copy-lob tt-NDD_ENTRYINTEGRATION.DOCUMENTDATA to file cFileXML.
        RUN utils\winopen.p (cFileXML,3). 
        edXML:read-file(cFileXML) in frame fPage2 no-error.
        pause 3 no-message.
        os-command silent del value(cFileXML) no-error.
    end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL brNotas wWindow
ON ROW-DISPLAY OF brNotas IN FRAME fPage1
DO:
  
    if tt-NDD_ENTRYINTEGRATION.retOK matches "*ERRO*" then
        assign tt-NDD_ENTRYINTEGRATION.retOK:bgcolor in browse brNotas = 12.
    else 
        assign tt-NDD_ENTRYINTEGRATION.retOK:bgcolor in browse brNotas = 10.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME fpage0
&Scoped-define SELF-NAME btAtualiza
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btAtualiza wWindow
ON CHOOSE OF btAtualiza IN FRAME fpage0 /* Query Joins */
OR CHOOSE OF btAtualiza DO:
    def var l-frame1 as logical.
    assign l-frame1 = frame fPage1:visible.
    assign frame fPage0 cCaminhoTela.
    RUN pi-openQueryArquivos.
    RUN pi-openQueryNotas.
    if l-frame1 then
        run SetFolder in hFolder (input 1).
    else
        run SetFolder in hFolder (input 2).

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btBuscaXML
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btBuscaXML wWindow
ON CHOOSE OF btBuscaXML IN FRAME fpage0 /* Busca XML */
OR CHOOSE OF btBuscaXML DO:
    def var l-frame1 as logical.
    assign l-frame1 = frame fPage1:visible.
    assign frame fPage0 cCaminhoTela.
    assign cCaminhoTMP = cCaminhoTela.

    if length(cChaveNFe:screen-value in frame fPage0) <> 44 then do:
        run message.p ("Chave NFe Inv†lida","Por favor informe uma chave de nota fiscal eletrìnica v†lida.").
        return no-apply.
    end.
    run pi-ConsultarColdSincrono (cChaveNFe:screen-value in frame fPage0).

    RUN pi-openQueryArquivos.
    RUN pi-openQueryNotas.
    if l-frame1 then
        run SetFolder in hFolder (input 1).
    else
        run SetFolder in hFolder (input 2).

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


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


&Scoped-define SELF-NAME cCaminhoTela
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL cCaminhoTela wWindow
ON LEAVE OF cCaminhoTela IN FRAME fpage0 /* Caminho */
DO:
    assign frame fPage0 cCaminhoTela.
    if substring(cCaminhoTela,length(cCaminhoTela),1) <> "\" then assign cCaminhoTela = cCaminhoTela + "\".
    assign cCaminhoTMP = cCaminhoTela.  
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME brArquivos
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK wWindow 


/*--- L¢gica para inicializaá∆o do programam ---*/
{window/MainBlock.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE afterDestroyInterface wWindow 
PROCEDURE afterDestroyInterface :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    /*if l-log then*/ output stream str-log close.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE beforeInitializeInterface wWindow 
PROCEDURE beforeInitializeInterface :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    /*if l-log then*/ output stream str-log to 
        value(cCaminhoTMP + c-seg-usuario + "_int550" + "_" + 
              string(today,"99-99-9999") + "_" + 
              replace(string(time,"HH:MM:SS"),':','_') + ".LOG").
    cCaminhoTela = cCaminhoTMP.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-openQueryArquivos wWindow 
PROCEDURE pi-openQueryArquivos :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
empty temp-table tt-arquivos.
empty temp-table tt-ndd_entryintegration.

if substring(cCaminhoTela,length(cCaminhoTela),1) <> "\" then assign cCaminhoTela = cCaminhoTela + "\".

os-command silent "dir /b" value(cCaminhoTela + "eformsConsultarCold*Retorno*.xml") > value(cCaminhoTela + c-seg-usuario + ".inp").
input from value(cCaminhoTela + c-seg-usuario + ".inp").

repeat:
    import  cFile.
    create  tt-arquivos.
    assign  tt-arquivos.arquivo = cFile.
end.

if can-find (first tt-arquivos) then do:
    open query brArquivos for each tt-arquivos no-lock.
    run setEnabled in hFolder (input 1, input true).
    enable all with frame fPage1.
    run setEnabled in hFolder (input 2, input true).
    enable all with frame fPage2.
    if brArquivos:num-entries > 0 then do:
        brArquivos:SELECT-ROW(1) in frame fPage1.
        apply "VALUE-CHANGED":U to brArquivos in frame fPage1.
    end.
end.
else do:
    run setEnabled in hFolder (input 1, input false).
    close query brArquivos.
    disable all with frame fPage1.
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-openQueryNotas wWindow 
PROCEDURE pi-openQueryNotas :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

session:SET-WAIT-STATE("GENERAL").
open query brNotas for each tt-ndd_entryintegration.
session:SET-WAIT-STATE("").

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION fnCod-Emitente wWindow 
FUNCTION fnCod-Emitente RETURNS integer
  ( pcnpj as char ) :
/*------------------------------------------------------------------------------
  Purpose:  
    Notes:  
------------------------------------------------------------------------------*/

    if pcnpj <> "" then 
    for first emitente fields (cod-emitente)
        no-lock where emitente.cgc begins pcnpj:
        RETURN emitente.cod-emitente.
    end.

  RETURN 0.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION fnCod-Estabel wWindow 
FUNCTION fnCod-Estabel RETURNS CHARACTER
  ( pcnpj as char ) :
/*------------------------------------------------------------------------------
  Purpose:  
    Notes:  
------------------------------------------------------------------------------*/

    if pcnpj <> "" then 
    for first estabelec fields (cod-estabel)
        no-lock where estabelec.cgc begins pcnpj:
        RETURN estabelec.cod-estabel.
    end.

  RETURN "".   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION fnNome-Abrev wWindow 
FUNCTION fnNome-Abrev RETURNS CHARACTER
  ( pcnpj as char ) :
/*------------------------------------------------------------------------------
  Purpose:  
    Notes:  
------------------------------------------------------------------------------*/
    if pcnpj <> "" then 
    for first emitente fields (nome-abrev)
        no-lock where emitente.cgc = pcnpj:
        RETURN emitente.nome-abrev.
    end.

  RETURN "".   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

