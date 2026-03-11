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
{include/i-prgvrs.i ESRE1001B 2.00.01.GCJ}

&IF "{&EMSFND_VERSION}" >= "1.00"
&THEN
&ENDIF

CREATE WIDGET-POOL.

/* Preprocessors Definitions ---                                      */
&GLOBAL-DEFINE Program        ESRE1001B
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


DEF TEMP-TABLE tt-es-contrato-docum-dup-aux NO-UNDO
    LIKE es-contrato-docum-dup
    FIELD r-rowid AS ROWID
    .



/* Parameters Definitions ---                                           */

DEFINE INPUT  PARAMETER pr-rowid AS ROWID       NO-UNDO.
DEFINE INPUT  PARAMETER pi-sequencia    AS INTEGER     NO-UNDO.
DEFINE INPUT  PARAMETER pc-nro-docto    AS CHARACTER   NO-UNDO.
DEFINE INPUT  PARAMETER pde-preco-total AS DECIMAL     NO-UNDO.
DEFINE INPUT  PARAMETER pc-action       AS CHARACTER   NO-UNDO.
DEFINE OUTPUT PARAM TABLE FOR tt-es-contrato-docum-dup-aux.

/* Local Variable Definitions ---                                       */


DEF BUFFER bf-es-contrato-docum-dup FOR es-contrato-docum-dup.


def temp-table tt-erro no-undo
    field i-sequen as int             
    field cd-erro  as int
    field mensagem as char format "x(255)".

DEFINE NEW GLOBAL SHARED VARIABLE adm-broker-hdl AS HANDLE NO-UNDO.
DEFINE VARIABLE wh-pesquisa AS HANDLE NO-UNDO.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Window
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME fpage0

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS rtToolBar RECT-2 RECT-3 i-sequencia ~
i-seq-dup c-parcela de-vl-a-pagar c-nr-duplic de-desconto cod-esp ~
de-vl-desconto i-tp-despesa dt-venc-desc dt-emissao dt-trans dt-vencim btOK ~
btCancel 
&Scoped-Define DISPLAYED-OBJECTS i-sequencia i-seq-dup c-parcela ~
de-vl-a-pagar c-nr-duplic de-desconto cod-esp de-vl-desconto i-tp-despesa ~
dt-venc-desc dt-emissao dt-trans dt-vencim 

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

DEFINE VARIABLE c-nr-duplic AS CHARACTER FORMAT "X(16)":U 
     LABEL "Duplicata" 
     VIEW-AS FILL-IN 
     SIZE 20 BY .88 NO-UNDO.

DEFINE VARIABLE c-parcela AS CHARACTER FORMAT "X(2)":U 
     LABEL "Parcela" 
     VIEW-AS FILL-IN 
     SIZE 8 BY .88 NO-UNDO.

DEFINE VARIABLE cod-esp AS CHARACTER FORMAT "!!":U 
     LABEL "Especie" 
     VIEW-AS FILL-IN 
     SIZE 6 BY .88 NO-UNDO.

DEFINE VARIABLE de-desconto AS DECIMAL FORMAT ">>9.99":U INITIAL 0 
     LABEL "Percentual Desconto" 
     VIEW-AS FILL-IN 
     SIZE 8 BY .88 NO-UNDO.

DEFINE VARIABLE de-vl-a-pagar AS DECIMAL FORMAT "->>,>>9.99":U INITIAL 0 
     LABEL "Valor Duplicata" 
     VIEW-AS FILL-IN 
     SIZE 16 BY .88 NO-UNDO.

DEFINE VARIABLE de-vl-desconto AS DECIMAL FORMAT "->>,>>9.99":U INITIAL 0 
     LABEL "Desconto" 
     VIEW-AS FILL-IN 
     SIZE 20 BY .88 NO-UNDO.

DEFINE VARIABLE dt-emissao AS DATE FORMAT "99/99/9999":U 
     LABEL "Data Emiss∆o" 
     VIEW-AS FILL-IN 
     SIZE 12 BY .88 NO-UNDO.

DEFINE VARIABLE dt-trans AS DATE FORMAT "99/99/9999":U 
     LABEL "Data Transaá∆o" 
     VIEW-AS FILL-IN 
     SIZE 12 BY .88 NO-UNDO.

DEFINE VARIABLE dt-venc-desc AS DATE FORMAT "99/99/9999":U 
     LABEL "Vencimento com Desc" 
     VIEW-AS FILL-IN 
     SIZE 12 BY .88 NO-UNDO.

DEFINE VARIABLE dt-vencim AS DATE FORMAT "99/99/9999":U 
     LABEL "Data Vencimento" 
     VIEW-AS FILL-IN 
     SIZE 12 BY .88 NO-UNDO.

DEFINE VARIABLE i-seq-dup AS INTEGER FORMAT ">>>,>>>,>>9" INITIAL 0 
     LABEL "Seq Duplicata" 
     VIEW-AS FILL-IN 
     SIZE 10 BY .88
     BGCOLOR 15 .

DEFINE VARIABLE i-sequencia AS INTEGER FORMAT ">>>,>>>,>>9":U INITIAL 0 
     LABEL "Sequencia" 
     VIEW-AS FILL-IN 
     SIZE 8 BY .88 NO-UNDO.

DEFINE VARIABLE i-tp-despesa AS INTEGER FORMAT ">>>9":U INITIAL 0 
     LABEL "Tipo Despesa" 
     VIEW-AS FILL-IN 
     SIZE 6 BY .88 NO-UNDO.

DEFINE RECTANGLE RECT-2
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 88 BY 2.

DEFINE RECTANGLE RECT-3
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 88 BY 7.38.

DEFINE RECTANGLE rtToolBar
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 90 BY 1.42
     BGCOLOR 7 .


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME fpage0
     i-sequencia AT ROW 1.75 COL 13.43 COLON-ALIGNED WIDGET-ID 10
     i-seq-dup AT ROW 1.75 COL 49.72 COLON-ALIGNED WIDGET-ID 30
     c-parcela AT ROW 3.5 COL 13.43 COLON-ALIGNED WIDGET-ID 14
     de-vl-a-pagar AT ROW 3.5 COL 49.72 COLON-ALIGNED WIDGET-ID 16
     c-nr-duplic AT ROW 4.5 COL 13.43 COLON-ALIGNED WIDGET-ID 20
     de-desconto AT ROW 4.5 COL 49.72 COLON-ALIGNED WIDGET-ID 24
     cod-esp AT ROW 5.5 COL 13.43 COLON-ALIGNED WIDGET-ID 18
     de-vl-desconto AT ROW 5.5 COL 49.72 COLON-ALIGNED WIDGET-ID 22
     i-tp-despesa AT ROW 6.5 COL 13.43 COLON-ALIGNED WIDGET-ID 32
     dt-venc-desc AT ROW 6.5 COL 49.72 COLON-ALIGNED WIDGET-ID 40
     dt-emissao AT ROW 7.5 COL 13.43 COLON-ALIGNED WIDGET-ID 34
     dt-trans AT ROW 8.5 COL 13.43 COLON-ALIGNED WIDGET-ID 36
     dt-vencim AT ROW 9.5 COL 13.43 COLON-ALIGNED WIDGET-ID 38
     btOK AT ROW 11.5 COL 2 WIDGET-ID 4
     btCancel AT ROW 11.5 COL 13 WIDGET-ID 2
     rtToolBar AT ROW 11.29 COL 1 WIDGET-ID 6
     RECT-2 AT ROW 1.25 COL 2 WIDGET-ID 12
     RECT-3 AT ROW 3.38 COL 2 WIDGET-ID 28
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 90 BY 12.29
         FONT 1 WIDGET-ID 100.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Window
   Allow: Basic,Browse,DB-Fields,Window,Query
   Add Fields to: Neither
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
IF SESSION:DISPLAY-TYPE = "GUI":U THEN
  CREATE WINDOW wWindow ASSIGN
         HIDDEN             = YES
         TITLE              = ""
         HEIGHT             = 12.29
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


&Scoped-define SELF-NAME cod-esp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL cod-esp wWindow
ON F5 OF cod-esp IN FRAME fpage0 /* Especie */
DO:
    {include/zoomvar.i &prog-zoom=adzoom/z01ad104.w
                          &campo=cod-esp
                          &campozoom=cod-esp
                          &FRAME=fPage0}.      
  
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL cod-esp wWindow
ON MOUSE-SELECT-DBLCLICK OF cod-esp IN FRAME fpage0 /* Especie */
DO:
  APPLY "F5" TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME i-tp-despesa
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL i-tp-despesa wWindow
ON F5 OF i-tp-despesa IN FRAME fpage0 /* Tipo Despesa */
DO:
  {include/zoomvar.i &prog-zoom="adzoom/z01ad259.w"
                       &campo=i-Tp-despesa
                       &campozoom=tp-codigo}  
  
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL i-tp-despesa wWindow
ON MOUSE-SELECT-DBLCLICK OF i-tp-despesa IN FRAME fpage0 /* Tipo Despesa */
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

       FIND LAST bf-es-contrato-docum-dup NO-LOCK
           WHERE bf-es-contrato-docum-dup.sequencia = pi-sequencia NO-ERROR.
    
       IF AVAIL bf-es-contrato-docum-dup THEN
          ASSIGN i-sequencia-aux = bf-es-contrato-docum-dup.seq-dup + 1.
       ELSE
          ASSIGN i-sequencia-aux = 1.
    
       DISP pi-sequencia    @ i-sequencia 
            i-sequencia-aux @ i-seq-dup
            WITH FRAME fPage0.
       
       DO WITH FRAME fPage0.
           ASSIGN c-parcela:SENSITIVE = YES               
                  c-nr-duplic:SENSITIVE = YES                          
                  cod-esp:SENSITIVE = YES                            
                  i-tp-despesa:SENSITIVE = YES          
                  dt-emissao:SENSITIVE = YES          
                  dt-trans:SENSITIVE = YES            
                  dt-vencim:SENSITIVE = YES           
                  de-vl-a-pagar:SENSITIVE = YES          
                  de-desconto:SENSITIVE = YES            
                  de-vl-desconto:SENSITIVE = YES         
                  dt-venc-desc:SENSITIVE = YES
                  .
           DISP TODAY @ dt-emissao
                TODAY @ dt-trans 
                TODAY @ dt-vencim.
    
           DISP "01" @ c-parcela.

           DISP pc-nro-docto @ c-nr-duplic
                pde-preco-total @ de-vl-a-pagar.

       END.


    END.
    ELSE DO:

        FIND FIRST bf-es-contrato-docum-dup NO-LOCK
            WHERE rowid(bf-es-contrato-docum-dup) = pr-rowid NO-ERROR.

        ASSIGN i-sequencia-aux = bf-es-contrato-docum-dup.seq-dup.

        DISP pi-sequencia    @ i-sequencia 
             i-sequencia-aux @ i-seq-dup
             WITH FRAME fPage0.


       DO WITH FRAME fPage0.
           ASSIGN c-parcela:SENSITIVE = YES               
                  c-nr-duplic:SENSITIVE = YES                          
                  cod-esp:SENSITIVE = YES                            
                  i-tp-despesa:SENSITIVE = YES          
                  dt-emissao:SENSITIVE = YES          
                  dt-trans:SENSITIVE = YES            
                  dt-vencim:SENSITIVE = YES           
                  de-vl-a-pagar:SENSITIVE = YES          
                  de-desconto:SENSITIVE = YES            
                  de-vl-desconto:SENSITIVE = YES         
                  dt-venc-desc:SENSITIVE = YES.


           DISP bf-es-contrato-docum-dup.parcela            @ c-parcela         
                bf-es-contrato-docum-dup.nr-duplic          @ c-nr-duplic       
                bf-es-contrato-docum-dup.cod-esp            @ cod-esp           
                bf-es-contrato-docum-dup.tp-despesa         @ i-tp-despesa      
                bf-es-contrato-docum-dup.dt-emissao         @ dt-emissao        
                bf-es-contrato-docum-dup.dt-trans           @ dt-trans          
                bf-es-contrato-docum-dup.dt-vencim          @ dt-vencim         
                bf-es-contrato-docum-dup.vl-a-pagar         @ de-vl-a-pagar     
                bf-es-contrato-docum-dup.desconto           @ de-desconto       
                bf-es-contrato-docum-dup.vl-desconto        @ de-vl-desconto    
                bf-es-contrato-docum-dup.dt-venc-desc       @ dt-venc-desc.

       END.

    END.



    cod-esp:load-mouse-pointer ("image/lupa.cur") in frame fPage0.
    i-tp-despesa:load-mouse-pointer ("image/lupa.cur") in frame fPage0.

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


 EMPTY TEMP-TABLE tt-erro.

 EMPTY TEMP-TABLE tt-es-contrato-docum-dup-aux.

 CREATE tt-es-contrato-docum-dup-aux.
 ASSIGN tt-es-contrato-docum-dup-aux.sequencia          = INPUT FRAME fPage0 i-sequencia
        tt-es-contrato-docum-dup-aux.seq-dup            = INPUT FRAME fPage0 i-seq-dup
        tt-es-contrato-docum-dup-aux.parcela            = INPUT FRAME fPage0 c-parcela
        tt-es-contrato-docum-dup-aux.nr-duplic          = INPUT FRAME fPage0 c-nr-duplic
        tt-es-contrato-docum-dup-aux.cod-esp            = INPUT FRAME fPage0 cod-esp
        tt-es-contrato-docum-dup-aux.tp-despesa         = INPUT FRAME fPage0 i-tp-despesa
        tt-es-contrato-docum-dup-aux.dt-emissao         = INPUT FRAME fPage0 dt-emissao
        tt-es-contrato-docum-dup-aux.dt-trans           = INPUT FRAME fPage0 dt-trans
        tt-es-contrato-docum-dup-aux.dt-vencim          = INPUT FRAME fPage0 dt-vencim
        tt-es-contrato-docum-dup-aux.vl-a-pagar         = INPUT FRAME fPage0 de-vl-a-pagar
        tt-es-contrato-docum-dup-aux.desconto           = INPUT FRAME fPage0 de-desconto
        tt-es-contrato-docum-dup-aux.vl-desconto        = INPUT FRAME fPage0 de-vl-desconto
        tt-es-contrato-docum-dup-aux.dt-venc-desc       = INPUT FRAME fPage0 dt-venc-desc
        .
                                                    

 /* validar registros */
 IF NOT CAN-FIND(FIRST espec-ap 
                 WHERE espec-ap.cod-esp = INPUT FRAME fPage0 cod-esp) THEN DO:

     CREATE tt-erro.
     ASSIGN tt-erro.i-sequen = 1
            tt-erro.cd-erro  = 1
            tt-erro.mensagem = "Especie n∆o cadastrada".

 END.

 IF NOT CAN-FIND(FIRST tipo-rec-desp 
                 WHERE tipo-rec-desp.tp-codigo = INPUT FRAME fPage0 i-tp-despesa) THEN DO:

     CREATE tt-erro.
     ASSIGN tt-erro.i-sequen = 2
            tt-erro.cd-erro  = 2
            tt-erro.mensagem = "Tipo Despesa n∆o cadastrada".

 END.

 IF INPUT FRAME fpage0 c-parcela = "" THEN DO:

     CREATE tt-erro.
     ASSIGN tt-erro.i-sequen = 3
            tt-erro.cd-erro  = 3
            tt-erro.mensagem = "informe Parcela".


 END.
  
 IF INPUT FRAME fpage0 c-nr-duplic = "" THEN DO:

     CREATE tt-erro.
     ASSIGN tt-erro.i-sequen = 3
            tt-erro.cd-erro  = 3
            tt-erro.mensagem = "informe Duplicata".


 END.

 IF INPUT FRAME fpage0 de-vl-a-pagar = 0 THEN DO:

     CREATE tt-erro.
     ASSIGN tt-erro.i-sequen = 3
            tt-erro.cd-erro  = 3
            tt-erro.mensagem = "informe Valor".


 END.

 IF INPUT FRAME fpage0 dt-emissao = ?
 OR INPUT FRAME fpage0 dt-trans   = ?  
 OR INPUT FRAME fpage0 dt-vencim   = ? THEN DO:

     CREATE tt-erro.
     ASSIGN tt-erro.i-sequen = 3
            tt-erro.cd-erro  = 3
            tt-erro.mensagem = "informe Data".


 END.

  /* fim valida registros */


 IF NOT CAN-FIND(FIRST tt-erro) THEN DO:

      IF pc-action = "ADD" THEN DO:
    
          CREATE es-contrato-docum-dup.
          BUFFER-COPY tt-es-contrato-docum-dup-aux TO es-contrato-docum-dup.
          ASSIGN  tt-es-contrato-docum-dup-aux.r-rowid = ROWID(es-contrato-docum-dup).

      END.
      ELSE DO:

          FIND FIRST bf-es-contrato-docum-dup EXCLUSIVE-LOCK
              WHERE rowid(bf-es-contrato-docum-dup) = pr-rowid NO-ERROR.

          BUFFER-COPY tt-es-contrato-docum-dup-aux TO bf-es-contrato-docum-dup.

      END.
 END.

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

