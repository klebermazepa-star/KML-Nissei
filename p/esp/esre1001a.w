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
{include/i-prgvrs.i ESRE1001A 2.00.01.GCJ}

&IF "{&EMSFND_VERSION}" >= "1.00"
&THEN
&ENDIF

CREATE WIDGET-POOL.

/* Preprocessors Definitions ---                                      */
&GLOBAL-DEFINE Program        ESRE1001A
&GLOBAL-DEFINE Version        2.00.01.GCJ

&GLOBAL-DEFINE WindowType     Master
&GLOBAL-DEFINE Folder         NO
&GLOBAL-DEFINE InitialPage    1
&GLOBAL-DEFINE FolderLabels   

&GLOBAL-DEFINE page0Widgets   btOK btCancel ~
                              
&GLOBAL-DEFINE page1Widgets   
&GLOBAL-DEFINE page2Widgets   

&GLOBAL-DEFINE EXCLUDE-translate     YES
&GLOBAL-DEFINE EXCLUDE-translateMenu YES


DEF TEMP-TABLE tt-es-contrato-docum-aux NO-UNDO
    LIKE es-contrato-docum
    FIELD r-rowid AS ROWID
    .



/* Parameters Definitions ---                                           */

DEFINE INPUT  PARAMETER pr-rowid   AS ROWID       NO-UNDO.
DEFINE INPUT  PARAMETER pc-periodo AS CHARACTER   NO-UNDO.
DEFINE INPUT  PARAMETER pc-action  AS CHARACTER   NO-UNDO.
DEFINE OUTPUT PARAM TABLE FOR tt-es-contrato-docum-aux.

/* Local Variable Definitions ---                                       */

DEF BUFFER bf-es-contrato-docum FOR es-contrato-docum.


def temp-table tt-erro no-undo
    field i-sequen as int             
    field cd-erro  as int
    field mensagem as char format "x(255)".

DEFINE NEW GLOBAL SHARED VARIABLE adm-broker-hdl AS HANDLE NO-UNDO.
DEFINE VARIABLE wh-pesquisa AS HANDLE NO-UNDO.

DEFINE VARIABLE h-boin176 AS HANDLE      NO-UNDO.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Window
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME fpage0

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS rtToolBar RECT-2 RECT-3 RECT-4 i-sequencia ~
c-periodo i-cod-emitente c-nome-abrev i-num-pedido i-nr-contrato ~
c-cod-estabel c-serie-docto c-nro-docto c-nat-operacao c-denominacao ~
c-it-codigo c-desc-item i-numero-ordem de-qt-do-forn c-un de-preco-unit ~
de-quantidade de-preco-total btOK btCancel 
&Scoped-Define DISPLAYED-OBJECTS i-sequencia c-periodo i-cod-emitente ~
c-nome-abrev i-num-pedido i-nr-contrato c-cod-estabel c-serie-docto ~
c-nro-docto c-nat-operacao c-denominacao c-it-codigo c-desc-item ~
i-numero-ordem de-qt-do-forn c-un de-preco-unit de-quantidade ~
de-preco-total 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR wWindow AS WIDGET-HANDLE NO-UNDO.

/* Definitions of the field level widgets                               */
DEFINE BUTTON btCancel 
     LABEL "Cancelar" 
     SIZE 10 BY 1.

DEFINE BUTTON btOK 
     LABEL "OK" 
     SIZE 10 BY 1.

DEFINE VARIABLE c-cod-estabel AS CHARACTER FORMAT "X(256)":U 
     LABEL "Estabelec" 
     VIEW-AS FILL-IN 
     SIZE 8 BY .88 NO-UNDO.

DEFINE VARIABLE c-denominacao AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 28 BY .88 NO-UNDO.

DEFINE VARIABLE c-desc-item AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 44 BY .88 NO-UNDO.

DEFINE VARIABLE c-it-codigo AS CHARACTER FORMAT "X(16)":U 
     LABEL "Item" 
     VIEW-AS FILL-IN 
     SIZE 15 BY .88 NO-UNDO.

DEFINE VARIABLE c-nat-operacao AS CHARACTER FORMAT "X(6)":U 
     LABEL "Nat Operacao" 
     VIEW-AS FILL-IN 
     SIZE 12 BY .88 NO-UNDO.

DEFINE VARIABLE c-nome-abrev AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 25 BY .88 NO-UNDO.

DEFINE VARIABLE c-nro-docto AS CHARACTER FORMAT "X(256)":U 
     LABEL "Documento" 
     VIEW-AS FILL-IN 
     SIZE 16 BY .88 NO-UNDO.

DEFINE VARIABLE c-periodo AS CHARACTER FORMAT "xx/xxxx" 
     LABEL "Per°odo" 
     VIEW-AS FILL-IN 
     SIZE 10 BY .88
     BGCOLOR 15 .

DEFINE VARIABLE c-serie-docto AS CHARACTER FORMAT "X(5)":U 
     LABEL "Serie" 
     VIEW-AS FILL-IN 
     SIZE 6 BY .88 NO-UNDO.

DEFINE VARIABLE c-un AS CHARACTER FORMAT "X(4)":U 
     VIEW-AS FILL-IN 
     SIZE 4 BY .88 NO-UNDO.

DEFINE VARIABLE de-preco-total AS DECIMAL FORMAT "->>,>>9.99":U INITIAL 0 
     LABEL "Preco Total" 
     VIEW-AS FILL-IN 
     SIZE 25 BY .88 NO-UNDO.

DEFINE VARIABLE de-preco-unit AS DECIMAL FORMAT "->>,>>9.99":U INITIAL 0 
     LABEL "Preco Unitario" 
     VIEW-AS FILL-IN 
     SIZE 25 BY .88 NO-UNDO.

DEFINE VARIABLE de-qt-do-forn AS DECIMAL FORMAT "->>,>>9.99":U INITIAL 0 
     LABEL "Qtde Emitente" 
     VIEW-AS FILL-IN 
     SIZE 25 BY .88 NO-UNDO.

DEFINE VARIABLE de-quantidade AS DECIMAL FORMAT "->>,>>9.99":U INITIAL 0 
     LABEL "Nossa Qtde" 
     VIEW-AS FILL-IN 
     SIZE 25 BY .88 NO-UNDO.

DEFINE VARIABLE i-cod-emitente AS INTEGER FORMAT ">>>>>>>>>>>9":U INITIAL 0 
     LABEL "Emitente" 
     VIEW-AS FILL-IN 
     SIZE 8 BY .88 NO-UNDO.

DEFINE VARIABLE i-nr-contrato AS INTEGER FORMAT ">>>,>>>,>>9":U INITIAL 0 
     LABEL "Contrato" 
     VIEW-AS FILL-IN 
     SIZE 12 BY .88 NO-UNDO.

DEFINE VARIABLE i-num-pedido AS INTEGER FORMAT ">,>>>,>>9":U INITIAL 0 
     LABEL "Pedido" 
     VIEW-AS FILL-IN 
     SIZE 12 BY .88 NO-UNDO.

DEFINE VARIABLE i-numero-ordem AS INTEGER FORMAT "zzzzz9,99":U INITIAL 0 
     LABEL "Ordem Compra" 
     VIEW-AS FILL-IN 
     SIZE 10 BY .88 NO-UNDO.

DEFINE VARIABLE i-sequencia AS INTEGER FORMAT ">>>,>>>,>>9":U INITIAL 0 
     LABEL "Sequencia" 
     VIEW-AS FILL-IN 
     SIZE 8 BY .88 NO-UNDO.

DEFINE RECTANGLE RECT-2
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 88 BY 2.

DEFINE RECTANGLE RECT-3
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 88 BY 4.63.

DEFINE RECTANGLE RECT-4
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 88 BY 6.54.

DEFINE RECTANGLE rtToolBar
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 90 BY 1.42
     BGCOLOR 7 .


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME fpage0
     i-sequencia AT ROW 1.75 COL 13.43 COLON-ALIGNED WIDGET-ID 10
     c-periodo AT ROW 1.75 COL 57.14 COLON-ALIGNED WIDGET-ID 30
     i-cod-emitente AT ROW 3.5 COL 13.57 COLON-ALIGNED WIDGET-ID 18
     c-nome-abrev AT ROW 3.5 COL 21.86 COLON-ALIGNED NO-LABEL WIDGET-ID 50
     i-num-pedido AT ROW 3.58 COL 57.14 COLON-ALIGNED WIDGET-ID 14
     i-nr-contrato AT ROW 4.5 COL 13.57 COLON-ALIGNED WIDGET-ID 16
     c-cod-estabel AT ROW 4.5 COL 57 COLON-ALIGNED WIDGET-ID 24
     c-serie-docto AT ROW 5.5 COL 13.57 COLON-ALIGNED WIDGET-ID 20
     c-nro-docto AT ROW 5.5 COL 57 COLON-ALIGNED WIDGET-ID 48
     c-nat-operacao AT ROW 6.5 COL 13.43 COLON-ALIGNED WIDGET-ID 22
     c-denominacao AT ROW 6.5 COL 26 COLON-ALIGNED NO-LABEL WIDGET-ID 52
     c-it-codigo AT ROW 8.5 COL 13.43 COLON-ALIGNED WIDGET-ID 32
     c-desc-item AT ROW 8.5 COL 29 COLON-ALIGNED NO-LABEL WIDGET-ID 54
     i-numero-ordem AT ROW 9.5 COL 13.43 COLON-ALIGNED WIDGET-ID 34
     de-qt-do-forn AT ROW 10.5 COL 13.43 COLON-ALIGNED WIDGET-ID 36
     c-un AT ROW 10.5 COL 39 COLON-ALIGNED NO-LABEL WIDGET-ID 44
     de-preco-unit AT ROW 10.5 COL 55 COLON-ALIGNED WIDGET-ID 40
     de-quantidade AT ROW 11.5 COL 13.43 COLON-ALIGNED WIDGET-ID 38
     de-preco-total AT ROW 11.5 COL 55 COLON-ALIGNED WIDGET-ID 42
     btOK AT ROW 16.75 COL 2 WIDGET-ID 4
     btCancel AT ROW 16.75 COL 13 WIDGET-ID 2
     rtToolBar AT ROW 16.54 COL 1 WIDGET-ID 6
     RECT-2 AT ROW 1.25 COL 2 WIDGET-ID 12
     RECT-3 AT ROW 3.38 COL 2 WIDGET-ID 28
     RECT-4 AT ROW 8.21 COL 2 WIDGET-ID 46
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 90 BY 17.04
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
         HEIGHT             = 17.04
         WIDTH              = 90
         MAX-HEIGHT         = 17.04
         MAX-WIDTH          = 90
         VIRTUAL-HEIGHT     = 17.04
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


&Scoped-define SELF-NAME btCancel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btCancel wWindow
ON CHOOSE OF btCancel IN FRAME fpage0 /* Cancelar */
DO:
    APPLY "CLOSE":U TO THIS-PROCEDURE.
    RETURN "NOK".
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btOK
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btOK wWindow
ON CHOOSE OF btOK IN FRAME fpage0 /* OK */
DO:
    RUN pi-gera-registro.


    IF CAN-FIND(FIRST tt-erro) THEN DO:       
        RUN cdp\cd0666.w (INPUT TABLE tt-erro).
    END.                                      
    ELSE DO:
        APPLY "CLOSE":U TO THIS-PROCEDURE.
        RETURN "OK".

    END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME c-cod-estabel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL c-cod-estabel wWindow
ON F5 OF c-cod-estabel IN FRAME fpage0 /* Estabelec */
DO:
    {include/zoomvar.i &prog-zoom="adzoom\z01ad107.w"
                       &campo=c-cod-estabel
                       &campozoom=cod-estabel
                       &EnableImplant="yes"}
  
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL c-cod-estabel wWindow
ON MOUSE-SELECT-DBLCLICK OF c-cod-estabel IN FRAME fpage0 /* Estabelec */
DO:
  
    APPLY "F5" TO SELF.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME c-it-codigo
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL c-it-codigo wWindow
ON F5 OF c-it-codigo IN FRAME fpage0 /* Item */
DO:
    {include/zoomvar.i &prog-zoom=inzoom/z02in172.w
                          &campo=c-it-codigo
                          &campozoom=it-codigo
                          &FRAME=fPage0}.      
  
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL c-it-codigo wWindow
ON LEAVE OF c-it-codigo IN FRAME fpage0 /* Item */
DO:
  FIND FIRST ITEM NO-LOCK
       WHERE ITEM.it-codigo = INPUT FRAME fPage0 c-it-codigo NO-ERROR.

  ASSIGN c-desc-item:SCREEN-VALUE IN FRAME fPage0 = IF AVAIL ITEM THEN ITEM.desc-item ELSE "".
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL c-it-codigo wWindow
ON MOUSE-SELECT-DBLCLICK OF c-it-codigo IN FRAME fpage0 /* Item */
DO:
  APPLY "F5" TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME c-nat-operacao
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL c-nat-operacao wWindow
ON F5 OF c-nat-operacao IN FRAME fpage0 /* Nat Operacao */
DO:
    {include/zoomvar.i &prog-zoom=inzoom/z01in245.w
                          &campo=c-nat-operacao
                          &campozoom=nat-operacao
                          &FRAME=fPage0}.      
  
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL c-nat-operacao wWindow
ON LEAVE OF c-nat-operacao IN FRAME fpage0 /* Nat Operacao */
DO:
  FIND FIRST natur-oper NO-LOCK
       WHERE natur-oper.nat-operacao = INPUT FRAME fPage0 c-nat-operacao NO-ERROR.

  ASSIGN c-denominacao:SCREEN-VALUE IN FRAME fPage0 = IF AVAIL natur-oper THEN natur-oper.denominacao
      ELSE "".
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL c-nat-operacao wWindow
ON MOUSE-SELECT-DBLCLICK OF c-nat-operacao IN FRAME fpage0 /* Nat Operacao */
DO:
  APPLY "F5" TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME c-serie-docto
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL c-serie-docto wWindow
ON F5 OF c-serie-docto IN FRAME fpage0 /* Serie */
DO:
    {include/zoomvar.i &prog-zoom=inzoom/z01in407.w
                          &campo=c-serie-docto
                          &campozoom=serie
                          &FRAME=fPage0}.      
  
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL c-serie-docto wWindow
ON MOUSE-SELECT-DBLCLICK OF c-serie-docto IN FRAME fpage0 /* Serie */
DO:
  APPLY "F5" TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME i-cod-emitente
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL i-cod-emitente wWindow
ON F5 OF i-cod-emitente IN FRAME fpage0 /* Emitente */
DO:
    {include/zoomvar.i &prog-zoom=adzoom/z07ad098.w
                       &campo=i-cod-emitente
                       &campozoom=cod-emitente
                       &frame=fpage0}
  
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL i-cod-emitente wWindow
ON LEAVE OF i-cod-emitente IN FRAME fpage0 /* Emitente */
DO:
  FIND FIRST emitente NO-LOCK
       WHERE emitente.cod-emitente = INPUT FRAME fPage0 i-cod-emitente NO-ERROR.

  ASSIGN c-nome-abrev:SCREEN-VALUE IN FRAME fPage0 = IF AVAIL emitente THEN emitente.nome-abrev
         ELSE "".
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL i-cod-emitente wWindow
ON MOUSE-SELECT-DBLCLICK OF i-cod-emitente IN FRAME fpage0 /* Emitente */
DO:
  APPLY "F5" TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME i-num-pedido
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL i-num-pedido wWindow
ON F5 OF i-num-pedido IN FRAME fpage0 /* Pedido */
DO:

    /*
    {include/zoomvar.i &prog-zoom=inzoom/z22in274.w
                          &campo=i-num-pedido
                          &campozoom=num-pedido
                          &FRAME=fPage0}.        */
                          

{method/zoomfields.i &ProgramZoom="inzoom/z22in274.w"
                        &FieldZoom1="num-pedido"
                        &FieldScreen1="i-num-pedido"
                        &Frame1="fPage0"                          
                        &FieldZoom2="numero-ordem"
                        &FieldScreen2="i-numero-ordem"                                                    
                        &Frame2="fPage0"
                        &FieldZoom3="it-codigo"
                        &FieldScreen3="c-it-codigo"
                        &Frame3="fPage0"
                        &RunMethod="Run setParametersPedido in hProgramZoom ( input INPUT FRAME fPage0 i-cod-emitente,
                                                                              input INPUT FRAME fPage0 c-it-codigo,
                                                                              input INPUT FRAME fPage0 i-num-pedido,
                                                                              input if   INPUT FRAME fPage0 i-num-pedido = 0 then 99999999
                                                                                    else INPUT FRAME fPage0 i-num-pedido,
                                                                              input h-boin176,
                                                                              input c-seg-usuario )."
                        &EnableImplant="NO"}

  
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL i-num-pedido wWindow
ON LEAVE OF i-num-pedido IN FRAME fpage0 /* Pedido */
DO:

    DEFINE VARIABLE c-docto AS CHARACTER FORMAT "x(20)"   NO-UNDO.
    DEFINE VARIABLE c-ano AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE c-dia AS CHARACTER   NO-UNDO.


    ASSIGN c-ano = STRING(YEAR(TODAY))
           c-ano = substring(c-ano,3,2)
           c-dia = STRING(MONTH(TODAY),"99")
            .

   FOR LAST ordem-compra NO-LOCK
       WHERE  ordem-compra.numero-ordem = INPUT FRAME fPage0 i-numero-ordem:


         FOR FIRST ITEM NO-LOCK
             WHERE ITEM.it-codigo = ordem-compra.it-codigo:

             DISP ITEM.un @ c-un  WITH FRAME fPage0.

         END.

          DISP ordem-compra.cod-estabel @ c-cod-estabel 

             //  ordem-compra.preco-unit @ de-preco-unit

              1 @ de-qt-do-forn
              1 @ de-quantidade


              ordem-compra.nr-contrato @ i-nr-contrato

              /* ( ordem-compra.preco-unit * 1) @ de-preco-total */
               
               WITH FRAME fPage0.

        /*  MESSAGE ordem-compra.nr-contrato    skip 
                  ordem-compra.numero-ordem   skip
                  ordem-compra.num-seq-item                SKIP
                  ordem-compra.sit-ordem-contrat 
              VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.*/

          FOR LAST medicao-contrat NO-LOCK
               WHERE medicao-contrat.nr-contrato  = ordem-compra.nr-contrato
               AND   medicao-contrat.numero-ordem = ordem-compra.numero-ordem
              BY medicao-contrat.num-seq-medicao:

             /* MESSAGE medicao-contrat.num-seq-medicao
                  VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.*/

              DISP medicao-contrat.val-medicao  @ de-preco-total WITH FRAME fPage0.
              DISP medicao-contrat.val-medicao  @ de-preco-unit WITH FRAME fPage0.

          END.




          ASSIGN c-docto = ordem-compra.cod-estabel + c-dia + c-ano .

          DISP c-docto @ c-nro-docto WITH FRAME fPage0.

    END.






END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL i-num-pedido wWindow
ON MOUSE-SELECT-DBLCLICK OF i-num-pedido IN FRAME fpage0 /* Pedido */
DO:
  APPLY "F5" TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME i-numero-ordem
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL i-numero-ordem wWindow
ON F5 OF i-numero-ordem IN FRAME fpage0 /* Ordem Compra */
DO:
  /*  {include/zoomvar.i &prog-zoom=inzoom/z22in274.w
                          &campo=i-numero-ordem
                          &campozoom=numero-ordem
                          &FRAME=fPage0}.         */
                          


    {method/zoomfields.i &ProgramZoom="inzoom/z22in274.w"
                            &FieldZoom1="num-pedido"
                            &FieldScreen1="i-num-pedido"
                            &Frame1="fPage0"                          
                            &FieldZoom2="numero-ordem"
                            &FieldScreen2="i-numero-ordem"                                                    
                            &Frame2="fPage0"
                            &FieldZoom3="it-codigo"
                            &FieldScreen3="c-it-codigo"
                            &Frame3="fPage0"
                            &RunMethod="Run setParametersPedido in hProgramZoom ( input INPUT FRAME fPage0 i-cod-emitente,
                                                                                  input INPUT FRAME fPage0 c-it-codigo,
                                                                                  input INPUT FRAME fPage0 i-num-pedido,
                                                                                  input if   INPUT FRAME fPage0 i-num-pedido = 0 then 99999999
                                                                                        else INPUT FRAME fPage0 i-num-pedido,
                                                                                  input h-boin176,
                                                                                  input c-seg-usuario )."
                            &EnableImplant="NO"}

  
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL i-numero-ordem wWindow
ON MOUSE-SELECT-DBLCLICK OF i-numero-ordem IN FRAME fpage0 /* Ordem Compra */
DO:
  APPLY "F5" TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


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

   DEFINE VARIABLE i-sequencia-aux AS INTEGER     NO-UNDO.

   IF pc-action = "ADD" THEN DO:
    
       FIND LAST bf-es-contrato-docum USE-INDEX idx-1 NO-LOCK NO-ERROR.
    
       IF AVAIL bf-es-contrato-docum THEN
          ASSIGN i-sequencia-aux = bf-es-contrato-docum.sequencia + 1.
       ELSE
          ASSIGN i-sequencia-aux = 1.
    
       DISP i-sequencia-aux @ i-sequencia WITH FRAME fPage0.
       /*
       ASSIGN c-periodo:SCREEN-VALUE = STRING(MONTH(TODAY), '99') + STRING(YEAR(TODAY), '9999').
       */

       ASSIGN c-periodo:SCREEN-VALUE = pc-periodo.

       DISP "001" @ c-serie-docto
            "1949x3" @ c-nat-operacao WITH FRAME fPage0.
       

   END.
   ELSE DO:

       FIND FIRST bf-es-contrato-docum  NO-LOCK 
            WHERE rowid(bf-es-contrato-docum) = pr-rowid NO-ERROR.

       ASSIGN c-periodo:SCREEN-VALUE = STRING(MONTH(bf-es-contrato-docum.dt-periodo), '99') + STRING(YEAR(bf-es-contrato-docum.dt-periodo), '9999').

       DO WITH FRAME fPage0.


           DISP

               bf-es-contrato-docum.sequencia       @ i-sequencia     
               bf-es-contrato-docum.num-pedido      @ i-num-pedido    
               bf-es-contrato-docum.nr-contrato     @ i-nr-contrato   
               bf-es-contrato-docum.cod-emitente    @ i-cod-emitente  
               bf-es-contrato-docum.serie-docto     @ c-serie-docto   
               bf-es-contrato-docum.nat-operacao    @ c-nat-operacao  
               bf-es-contrato-docum.cod-estabel     @ c-cod-estabel   
               bf-es-contrato-docum.nro-docto       @ c-nro-docto     
               bf-es-contrato-docum.it-codigo       @ c-it-codigo        
               bf-es-contrato-docum.numero-ordem    @ i-numero-ordem     
               bf-es-contrato-docum.qt-do-forn      @ de-qt-do-forn      
               bf-es-contrato-docum.un              @ c-un               
               bf-es-contrato-docum.quantidade      @ de-quantidade     
               bf-es-contrato-docum.preco-unit      @ de-preco-unit      
               bf-es-contrato-docum.preco-total     @ de-preco-total .    
       END.

   END.

   DO WITH FRAME fPage0.
       ASSIGN i-num-pedido  :SENSITIVE = YES     
              i-nr-contrato :SENSITIVE = YES    
              i-cod-emitente:SENSITIVE = YES   
              c-serie-docto :SENSITIVE = YES    
              c-nat-operacao:SENSITIVE = YES   
              c-cod-estabel :SENSITIVE = YES
              c-nro-docto   :SENSITIVE = YES
              .    


       ASSIGN c-it-codigo       :SENSITIVE = YES    
              i-numero-ordem    :SENSITIVE = YES  
           /*
              de-qt-do-forn     :SENSITIVE = YES    
              c-un              :SENSITIVE = YES    
              de-quantidade     :SENSITIVE = YES    
              de-preco-unit     :SENSITIVE = YES   
              de-preco-total    :SENSITIVE = YES
              
              */.
   END.


   c-serie-docto:load-mouse-pointer ("image/lupa.cur") in frame fPage0.
   c-cod-estabel:load-mouse-pointer ("image/lupa.cur") in frame fPage0.
   i-cod-emitente:load-mouse-pointer ("image/lupa.cur") in frame fPage0.
   c-nat-operacao:load-mouse-pointer ("image/lupa.cur") in frame fPage0.
   i-num-pedido:load-mouse-pointer ("image/lupa.cur") in frame fPage0.

   c-it-codigo:load-mouse-pointer ("image/lupa.cur") in frame fPage0.
   i-numero-ordem:load-mouse-pointer ("image/lupa.cur") in frame fPage0.
       
  


  RETURN "OK".

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-gera-registro wWindow 
PROCEDURE pi-gera-registro :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

 DEFINE VARIABLE iMes      AS INTEGER     NO-UNDO.
 DEFINE VARIABLE iAno      AS INTEGER     NO-UNDO.
 DEFINE VARIABLE dtPeriodo AS DATE  FORMAT "99/99/9999"        NO-UNDO.

 ASSIGN INPUT FRAME fPage0 c-periodo.

 ASSIGN 
    iMes        = INTEGER(SUBSTRING(c-periodo, 1, 02))
    iAno        = INTEGER(SUBSTRING(c-periodo, 3, 04))
    dtPeriodo   = DATE(iMes, 1, iAno)
    NO-ERROR.           

 EMPTY TEMP-TABLE tt-erro.

 EMPTY TEMP-TABLE tt-es-contrato-docum-aux.

 CREATE tt-es-contrato-docum-aux.
 ASSIGN tt-es-contrato-docum-aux.sequencia       = INPUT FRAME fPage0 i-sequencia
        tt-es-contrato-docum-aux.dt-periodo      = dtPeriodo
        tt-es-contrato-docum-aux.num-pedido      = INPUT FRAME fPage0 i-num-pedido
        tt-es-contrato-docum-aux.nr-contrato     = INPUT FRAME fPage0 i-nr-contrato
        tt-es-contrato-docum-aux.cod-emitente    = INPUT FRAME fPage0 i-cod-emitente
        tt-es-contrato-docum-aux.serie-docto     = INPUT FRAME fPage0 c-serie-docto
        tt-es-contrato-docum-aux.nat-operacao    = INPUT FRAME fPage0 c-nat-operacao
        tt-es-contrato-docum-aux.cod-estabel     = INPUT FRAME fPage0 c-cod-estabel
        tt-es-contrato-docum-aux.dt-inclusao     = TODAY
        tt-es-contrato-docum-aux.nro-docto       = INPUT FRAME fpage0 c-nro-docto
        .

 ASSIGN tt-es-contrato-docum-aux.it-codigo    = INPUT FRAME fPage0 c-it-codigo   
        tt-es-contrato-docum-aux.numero-ordem = INPUT FRAME fPage0 i-numero-ordem
        tt-es-contrato-docum-aux.qt-do-forn   = INPUT FRAME fPage0 de-qt-do-forn 
        tt-es-contrato-docum-aux.un           = INPUT FRAME fPage0 c-un          
        tt-es-contrato-docum-aux.quantidade   =  INPUT FRAME fPage0 de-quantidade 
        tt-es-contrato-docum-aux.preco-unit   = INPUT FRAME fPage0 de-preco-unit 
        tt-es-contrato-docum-aux.preco-total  = INPUT FRAME fPage0 de-preco-total
     
         .


 EMPTY TEMP-TABLE tt-erro.


 IF CAN-FIND(FIRST es-contrato-docum
             WHERE es-contrato-docum.cod-emitente = INPUT FRAME fPage0 i-cod-emitente
             AND   es-contrato-docum.serie-docto  = INPUT FRAME fPage0 c-serie-docto
             AND   es-contrato-docum.nro-docto    = INPUT FRAME fPage0 c-nro-docto 
             AND   es-contrato-docum.nat-operacao = INPUT FRAME fPage0 c-nat-operacao) THEN DO:

     CREATE tt-erro.
     ASSIGN tt-erro.i-sequen = 9
            tt-erro.cd-erro  = 9
            tt-erro.mensagem = "Documento ja cadastrado".



 END.


 IF CAN-FIND(FIRST docum-est
            WHERE docum-est.cod-emitente = INPUT FRAME fPage0 i-cod-emitente
            AND   docum-est.serie-docto  = INPUT FRAME fPage0 c-serie-docto
            AND   docum-est.nro-docto    = INPUT FRAME fPage0 c-nro-docto 
            AND   docum-est.nat-operacao = INPUT FRAME fPage0 c-nat-operacao) THEN DO:

    CREATE tt-erro.
    ASSIGN tt-erro.i-sequen = 9
           tt-erro.cd-erro  = 9
           tt-erro.mensagem = "Documento ja cadastrado".



END.


  /* validar registros */
  IF NOT CAN-FIND(FIRST serie 
                  WHERE serie.serie = INPUT FRAME fPage0 c-serie-docto) THEN DO:

      CREATE tt-erro.
      ASSIGN tt-erro.i-sequen = 1
             tt-erro.cd-erro  = 1
             tt-erro.mensagem = "Serie n∆o cadastrada".

  END.


  IF NOT CAN-FIND(FIRST estabelec 
                   WHERE estabelec.cod-estabel = INPUT FRAME fPage0 c-cod-estabel) THEN DO:

       CREATE tt-erro.
       ASSIGN tt-erro.i-sequen = 2
              tt-erro.cd-erro  = 2
              tt-erro.mensagem = "Estabelec n∆o cadastrado".

   END.

   IF NOT CAN-FIND(FIRST emitente 
                    WHERE emitente.cod-emitente = INPUT FRAME fPage0 i-cod-emitente) THEN DO:

        CREATE tt-erro.
        ASSIGN tt-erro.i-sequen = 3
               tt-erro.cd-erro  = 3
               tt-erro.mensagem = "Emitente n∆o cadastrado".

    END.

    IF INPUT FRAME fPage0 c-nro-docto = "" THEN DO:

         CREATE tt-erro.
         ASSIGN tt-erro.i-sequen = 4
                tt-erro.cd-erro  = 4
                tt-erro.mensagem = "Informe Numero do Documento".

     END.

     IF NOT CAN-FIND(FIRST natur-oper 
                      WHERE natur-oper.nat-operacao = INPUT FRAME fPage0 c-nat-operacao) THEN DO:

          CREATE tt-erro.
          ASSIGN tt-erro.i-sequen = 5
                 tt-erro.cd-erro  = 5
                 tt-erro.mensagem = "Natureza n∆o cadastrado".

      END.


      IF NOT CAN-FIND(FIRST item 
                       WHERE item.it-codigo = INPUT FRAME fPage0 c-it-codigo) THEN DO:

           CREATE tt-erro.
           ASSIGN tt-erro.i-sequen = 6
                  tt-erro.cd-erro  = 6
                  tt-erro.mensagem = "Item n∆o cadastrado".

       END.


       IF INPUT FRAME fPage0 de-quantidade = 0 THEN DO:

            CREATE tt-erro.
            ASSIGN tt-erro.i-sequen = 7
                   tt-erro.cd-erro  = 7
                   tt-erro.mensagem = "Informe Quantidade".

        END.



       IF INPUT FRAME fPage0 de-preco-total = 0 THEN DO:

            CREATE tt-erro.
            ASSIGN tt-erro.i-sequen = 8
                   tt-erro.cd-erro  = 8
                   tt-erro.mensagem = "Informe Valor".

        END.



  /* fim valida registros */


  IF NOT CAN-FIND(FIRST tt-erro) THEN DO:

      IF pc-action = "ADD" THEN DO:
      
          CREATE es-contrato-docum.
          BUFFER-COPY tt-es-contrato-docum-aux TO es-contrato-docum.
          ASSIGN  tt-es-contrato-docum-aux.r-rowid = ROWID(es-contrato-docum).

      END.
      ELSE DO:

          FIND FIRST bf-es-contrato-docum  EXCLUSIVE-LOCK 
               WHERE rowid(bf-es-contrato-docum) = pr-rowid NO-ERROR.

          BUFFER-COPY tt-es-contrato-docum-aux TO bf-es-contrato-docum.


      END.

  END.



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

