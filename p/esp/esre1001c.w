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
{include/i-prgvrs.i ESRE1001C 2.00.01.GCJ}

&IF "{&EMSFND_VERSION}" >= "1.00"
&THEN
&ENDIF

CREATE WIDGET-POOL.

/* Preprocessors Definitions ---                                      */
&GLOBAL-DEFINE Program        ESRE1001C
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


DEF TEMP-TABLE tt-es-contrato-docum-imp-aux NO-UNDO
    LIKE es-contrato-docum-imp
    FIELD r-rowid AS ROWID
    .



/* Parameters Definitions ---                                           */
DEFINE INPUT  PARAMETER pc-action    AS CHARACTER   NO-UNDO.
DEFINE INPUT  PARAMETER pr-rowid     AS ROWID       NO-UNDO.
DEFINE INPUT  PARAMETER pi-sequencia AS INTEGER     NO-UNDO.
DEFINE INPUT  PARAMETER pi-seq-dup   AS INTEGER     NO-UNDO.
DEFINE OUTPUT PARAM TABLE FOR tt-es-contrato-docum-imp-aux.

/* Local Variable Definitions ---                                       */

DEF BUFFER bf-es-contrato-docum-imp FOR es-contrato-docum-imp.


def temp-table tt-erro no-undo
    field i-sequen as int             
    field cd-erro  as int
    field mensagem as char format "x(255)".

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
i-seq-dup i-seq-imp c-cod-esp c-serie c-nro-docto-imp c-parcela-imp ~
i-cod-retencao dt-venc-imp de-rend-trib de-aliquota de-vl-imposto ~
i-tp-codigo btOK btCancel 
&Scoped-Define DISPLAYED-OBJECTS i-sequencia i-seq-dup i-seq-imp ~
i-cod-imposto c-desc-imposto c-cod-esp c-desc-especie c-serie ~
c-nro-docto-imp c-parcela-imp i-cod-retencao dt-venc-imp de-rend-trib ~
de-aliquota de-vl-imposto i-tp-codigo 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */
&Scoped-define List-1 i-cod-imposto 
&Scoped-define List-2 c-cod-esp 

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

DEFINE VARIABLE c-cod-esp AS CHARACTER FORMAT "!!" 
     LABEL "Esp‚cie" 
     VIEW-AS FILL-IN 
     SIZE 5.72 BY .88.

DEFINE VARIABLE c-desc-especie AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 37.72 BY .88 NO-UNDO.

DEFINE VARIABLE c-desc-imposto AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 37.72 BY .88 NO-UNDO.

DEFINE VARIABLE c-nro-docto-imp AS CHARACTER FORMAT "x(16)" 
     LABEL "Docto Imposto" 
     VIEW-AS FILL-IN 
     SIZE 14.43 BY .88.

DEFINE VARIABLE c-parcela-imp AS CHARACTER FORMAT "x(2)" 
     VIEW-AS FILL-IN 
     SIZE 5.14 BY .88.

DEFINE VARIABLE c-serie AS CHARACTER FORMAT "X(5)":U 
     LABEL "S‚rie Imposto" 
     VIEW-AS FILL-IN 
     SIZE 6.57 BY .88 NO-UNDO.

DEFINE VARIABLE de-aliquota AS DECIMAL FORMAT ">>,>>9.99":U INITIAL 0 
     LABEL "Aliquota" 
     VIEW-AS FILL-IN 
     SIZE 12 BY .88 NO-UNDO.

DEFINE VARIABLE de-rend-trib AS DECIMAL FORMAT "->>,>>9.99":U INITIAL 0 
     LABEL "Rend Trib" 
     VIEW-AS FILL-IN 
     SIZE 14 BY .88 NO-UNDO.

DEFINE VARIABLE de-vl-imposto AS DECIMAL FORMAT "->>,>>9.99":U INITIAL 0 
     LABEL "Valor Imposto" 
     VIEW-AS FILL-IN 
     SIZE 20 BY .88 NO-UNDO.

DEFINE VARIABLE dt-venc-imp AS DATE FORMAT "99/99/9999":U 
     LABEL "Vencto Imposto" 
     VIEW-AS FILL-IN 
     SIZE 12 BY .88 NO-UNDO.

DEFINE VARIABLE i-cod-imposto AS INTEGER FORMAT "->>>>>>>>9" INITIAL 0 
     LABEL "C¢digo Imposto" 
     VIEW-AS FILL-IN 
     SIZE 5.72 BY .88.

DEFINE VARIABLE i-cod-retencao AS INTEGER FORMAT ">>>>9" INITIAL 0 
     LABEL "Cod Ret" 
     VIEW-AS FILL-IN 
     SIZE 6.86 BY .88.

DEFINE VARIABLE i-seq-dup AS INTEGER FORMAT ">>>,>>>,>>9":U INITIAL 0 
     LABEL "Sequencia Dupl" 
     VIEW-AS FILL-IN 
     SIZE 8 BY .88 NO-UNDO.

DEFINE VARIABLE i-seq-imp AS INTEGER FORMAT ">>>,>>>,>>9":U INITIAL 0 
     LABEL "Sequencia Imposto" 
     VIEW-AS FILL-IN 
     SIZE 8 BY .88 NO-UNDO.

DEFINE VARIABLE i-sequencia AS INTEGER FORMAT ">>>,>>>,>>9":U INITIAL 0 
     LABEL "Sequencia" 
     VIEW-AS FILL-IN 
     SIZE 8 BY .88 NO-UNDO.

DEFINE VARIABLE i-tp-codigo AS INTEGER FORMAT ">>9":U INITIAL 0 
     LABEL "Tp Recta/Desp" 
     VIEW-AS FILL-IN 
     SIZE 6 BY .88 NO-UNDO.

DEFINE RECTANGLE RECT-2
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 88 BY 2.

DEFINE RECTANGLE RECT-3
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 88 BY 12.13.

DEFINE RECTANGLE rtToolBar
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 90 BY 1.42
     BGCOLOR 7 .


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME fpage0
     i-sequencia AT ROW 1.75 COL 13.43 COLON-ALIGNED WIDGET-ID 10
     i-seq-dup AT ROW 1.75 COL 34.72 COLON-ALIGNED WIDGET-ID 60
     i-seq-imp AT ROW 1.75 COL 58.14 COLON-ALIGNED WIDGET-ID 62
     i-cod-imposto AT ROW 3.75 COL 13.86 COLON-ALIGNED WIDGET-ID 42
     c-desc-imposto AT ROW 3.75 COL 20 COLON-ALIGNED NO-LABEL WIDGET-ID 34
     c-cod-esp AT ROW 4.75 COL 13.86 COLON-ALIGNED WIDGET-ID 38
     c-desc-especie AT ROW 4.75 COL 20 COLON-ALIGNED NO-LABEL WIDGET-ID 32
     c-serie AT ROW 5.75 COL 13.86 COLON-ALIGNED WIDGET-ID 36
     c-nro-docto-imp AT ROW 6.75 COL 13.86 COLON-ALIGNED WIDGET-ID 44
     c-parcela-imp AT ROW 6.75 COL 28.72 COLON-ALIGNED NO-LABEL WIDGET-ID 46
     i-cod-retencao AT ROW 7.75 COL 13.86 COLON-ALIGNED WIDGET-ID 40
     dt-venc-imp AT ROW 8.75 COL 13.86 COLON-ALIGNED WIDGET-ID 50
     de-rend-trib AT ROW 9.75 COL 13.86 COLON-ALIGNED WIDGET-ID 52
     de-aliquota AT ROW 10.75 COL 13.86 COLON-ALIGNED WIDGET-ID 54
     de-vl-imposto AT ROW 11.75 COL 13.86 COLON-ALIGNED WIDGET-ID 56
     i-tp-codigo AT ROW 12.75 COL 13.86 COLON-ALIGNED WIDGET-ID 58
     btOK AT ROW 16.75 COL 2 WIDGET-ID 4
     btCancel AT ROW 16.75 COL 13 WIDGET-ID 2
     rtToolBar AT ROW 16.54 COL 1 WIDGET-ID 6
     RECT-2 AT ROW 1.25 COL 2 WIDGET-ID 12
     RECT-3 AT ROW 3.38 COL 1.86 WIDGET-ID 28
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 90 BY 17
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
/* SETTINGS FOR FILL-IN c-cod-esp IN FRAME fpage0
   2                                                                    */
/* SETTINGS FOR FILL-IN c-desc-especie IN FRAME fpage0
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN c-desc-imposto IN FRAME fpage0
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN i-cod-imposto IN FRAME fpage0
   NO-ENABLE 1                                                          */
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


&Scoped-define SELF-NAME c-cod-esp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL c-cod-esp wWindow
ON F5 OF c-cod-esp IN FRAME fpage0 /* Esp‚cie */
OR "MOUSE-SELECT-DBLCLICK":U OF c-cod-esp IN FRAME fPage0 DO:

    /*
    {include/zoomvar.i &prog-zoom=adzoom/z01ad104.w
                       &campo=tt-dupli-imp.cod-esp
                       &campozoom=cod-esp}  */

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL c-cod-esp wWindow
ON LEAVE OF c-cod-esp IN FRAME fpage0 /* Esp‚cie */
DO:
    
    
    /*
    if  length(self:screen-value) <> 2 or
        error-status:error then
        assign self:format = "x(2)":U.
    else
        assign self:format = "!(2)":U.
    
    run findEspecie in {&hDBOTable} ( input frame fPage0 tt-dupli-imp.cod-esp ).

    run getDescriptionFields in {&hDBOTable} ( input "c-desc-especie":U,
                                               output c-desc-especie ).
                                    
    assign c-desc-especie:screen-value in frame fPage0 = c-desc-especie.  */

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME c-serie
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL c-serie wWindow
ON F5 OF c-serie IN FRAME fpage0 /* S‚rie Imposto */
OR "MOUSE-SELECT-DBLCLICK":U OF c-serie IN FRAME fPage0 DO:


    /*
    {include/zoomvar.i &prog-zoom=inzoom/z01in407.w
                       &campo=c-serie
                       &campozoom=serie}   */
  
             
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL c-serie wWindow
ON MOUSE-SELECT-DBLCLICK OF c-serie IN FRAME fpage0 /* S‚rie Imposto */
DO:
   apply 'F5' to self.  

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME i-cod-imposto
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL i-cod-imposto wWindow
ON LEAVE OF i-cod-imposto IN FRAME fpage0 /* C¢digo Imposto */
DO:
    

    /*
    ASSIGN l-mostra-msg = FALSE.

    FIND FIRST tt_integr_imptos_pgto_apb WHERE
               tt_integr_imptos_pgto_apb.tta_cod_imposto = string(input frame fPage0 tt-dupli-imp.int-1) NO-LOCK NO-ERROR.

    IF NOT AVAIL tt_integr_imptos_pgto_apb THEN
        ASSIGN c-desc-imposto:SCREEN-VALUE       IN FRAME fPage0 = ""
               l-mostra-msg = TRUE
               tt-dupli-imp.cod-esp:SCREEN-VALUE IN FRAME fPage0 = ""
               c-desc-especie:SCREEN-VALUE       IN FRAME fPage0 = "".
    ELSE DO:
        ASSIGN c-desc-imposto:SCREEN-VALUE IN FRAME fPage0 = tt_integr_imptos_pgto_apb.tta_des_imposto
               c-cod-retencao                              = STRING(tt_integr_imptos_pgto_apb.tta_cod_classif_impto, "9999").

        RUN pi-busca-especie-imposto(INPUT c-pais-trad, 
                                     INPUT tt_integr_imptos_pgto_apb.tta_cod_unid_federac,
                                     INPUT INPUT FRAME fPage0 tt-dupli-imp.int-1, 
                                     OUTPUT c-cod-esp).
                                                                         
        ASSIGN tt-dupli-imp.cod-esp:SCREEN-VALUE      IN FRAME fPage0 = c-cod-esp
               tt-dupli-imp.cod-retencao:SCREEN-VALUE IN FRAME fPage0 = tt_integr_imptos_pgto_apb.tta_cod_classif_impto WHEN NOT CAN-FIND(FIRST tt_integr_imptos_pgto_apb 
                                                                                                                                          WHERE tt_integr_imptos_pgto_apb.tta_cod_imposto = STRING(INPUT FRAME fPage0 tt-dupli-imp.int-1)
                                                                                                                                            AND tt_integr_imptos_pgto_apb.tta_cod_classif_impto <> c-cod-retencao).

        APPLY "LEAVE" TO tt-dupli-imp.cod-esp IN FRAME fPage0.
    END.

   */

    RETURN "OK":U.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL i-cod-imposto wWindow
ON MOUSE-SELECT-DBLCLICK OF i-cod-imposto IN FRAME fpage0 /* C¢digo Imposto */
DO:
  apply "F5" to self.  
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME i-cod-retencao
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL i-cod-retencao wWindow
ON F5 OF i-cod-retencao IN FRAME fpage0 /* Cod Ret */
OR "MOUSE-SELECT-DBLCLICK":U OF i-cod-retencao IN FRAME fpage0 DO:


    /*

    /*--- ZOOM SMART OBJECT ---*/
    {include/zoomvar.i &prog-zoom=adzoom/z01ad999.w
                       &campo=tt-dupli-imp.cod-retencao    
                       &campozoom=tt-cod-ir.c-cod
                       &frame=fPage0}   */

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL i-cod-retencao wWindow
ON LEAVE OF i-cod-retencao IN FRAME fpage0 /* Cod Ret */
DO:
    
    /*
    ASSIGN l-mostra-msg-2 = FALSE.

    IF NOT CAN-FIND(FIRST tt_integr_imptos_pgto_apb 
                    WHERE tt_integr_imptos_pgto_apb.tta_cod_imposto       =  string(input frame fPage0 tt-dupli-imp.int-1)
                      AND tt_integr_imptos_pgto_apb.tta_cod_classif_impto =  string(input frame fPage0 tt-dupli-imp.cod-retencao,"9999")) THEN DO:

        ASSIGN l-mostra-msg-2 = TRUE.

    END.
    
    */

    RETURN "OK":U.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


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

   DEFINE VARIABLE i-sequencia-aux AS INTEGER     NO-UNDO.

   IF pc-action = "ADD" THEN DO:
    
       FIND LAST bf-es-contrato-docum-imp NO-LOCK 
            WHERE bf-es-contrato-docum-imp.sequencia = pi-sequencia
            AND   bf-es-contrato-docum-imp.seq-dup   = pi-seq-dup
            NO-ERROR.
    
       IF AVAIL bf-es-contrato-docum-imp THEN
          ASSIGN i-sequencia-aux = bf-es-contrato-docum-imp.seq-imp + 1.
       ELSE
          ASSIGN i-sequencia-aux = 1.
    
       DISP  pi-sequencia @ i-sequencia
             pi-seq-dup @ i-seq-dup
             i-sequencia-aux @ i-seq-imp WITH FRAME fPage0.

   END.
   ELSE DO:

       FIND FIRST bf-es-contrato-docum-imp NO-LOCK 
            WHERE rowid(bf-es-contrato-docum-imp) = pr-rowid
            NO-ERROR.

       ASSIGN i-sequencia-aux = bf-es-contrato-docum-imp.seq-imp.

       DO WITH FRAME fPage0:
       
           DISP bf-es-contrato-docum-imp.cod-imposto     @ i-cod-imposto      
                bf-es-contrato-docum-imp.cod-esp         @ c-cod-esp          
                bf-es-contrato-docum-imp.serie           @ c-serie            
                bf-es-contrato-docum-imp.nro-docto-imp   @ c-nro-docto-imp    
                bf-es-contrato-docum-imp.parcela-imp     @ c-parcela-imp      
                bf-es-contrato-docum-imp.cod-retencao    @ i-cod-retencao     
                bf-es-contrato-docum-imp.dt-venc-imp     @ dt-venc-imp        
                bf-es-contrato-docum-imp.rend-trib       @ de-rend-trib       
               // string(round(bf-es-contrato-docum-imp.aliquota,2), ">>9.99")        @ de-aliquota      
                bf-es-contrato-docum-imp.vl-imposto      @ de-vl-imposto      
                bf-es-contrato-docum-imp.tp-codigo       @ i-tp-codigo.    

       ASSIGN de-aliquota:SCREEN-VALUE IN FRAME fPage0 = string(bf-es-contrato-docum-imp.aliquota * 10000).

       END.


       DISP  pi-sequencia @ i-sequencia
             pi-seq-dup @ i-seq-dup
             i-sequencia-aux @ i-seq-imp
              WITH FRAME fPage0.        

   END.
   

   DO WITH FRAME fPage0.

       ASSIGN i-cod-imposto   :SENSITIVE = YES     
              c-cod-esp       :SENSITIVE = YES    
              c-serie         :SENSITIVE = YES   
              c-nro-docto-imp :SENSITIVE = YES    
              c-parcela-imp   :SENSITIVE = YES   
              i-cod-retencao  :SENSITIVE = YES
              dt-venc-imp     :SENSITIVE = YES
              de-rend-trib    :SENSITIVE = YES
              de-aliquota     :SENSITIVE = YES
              de-vl-imposto   :SENSITIVE = YES
              i-tp-codigo     :SENSITIVE = YES.

       

   END.

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

 EMPTY TEMP-TABLE tt-es-contrato-docum-imp-aux.

 CREATE tt-es-contrato-docum-imp-aux.
 ASSIGN tt-es-contrato-docum-imp-aux.sequencia       = INPUT FRAME fPage0 i-sequencia
        tt-es-contrato-docum-imp-aux.seq-dup         = INPUT FRAME fPage0 i-seq-dup
        tt-es-contrato-docum-imp-aux.seq-imp         = INPUT FRAME fPage0 i-seq-imp
     
     
        tt-es-contrato-docum-imp-aux.cod-imposto     = INPUT FRAME fPage0 i-cod-imposto  
        tt-es-contrato-docum-imp-aux.cod-esp         = INPUT FRAME fPage0 c-cod-esp      
        tt-es-contrato-docum-imp-aux.serie           = INPUT FRAME fPage0 c-serie        
        tt-es-contrato-docum-imp-aux.nro-docto-imp   = INPUT FRAME fPage0 c-nro-docto-imp
        tt-es-contrato-docum-imp-aux.parcela-imp     = INPUT FRAME fPage0 c-parcela-imp  
        tt-es-contrato-docum-imp-aux.cod-retencao    = INPUT FRAME fPage0 i-cod-retencao 
        tt-es-contrato-docum-imp-aux.dt-venc-imp     = INPUT FRAME fPage0 dt-venc-imp    
        tt-es-contrato-docum-imp-aux.rend-trib       = INPUT FRAME fPage0 de-rend-trib   
        tt-es-contrato-docum-imp-aux.aliquota        = INPUT FRAME fPage0 de-aliquota    
        tt-es-contrato-docum-imp-aux.vl-imposto      = INPUT FRAME fPage0 de-vl-imposto  
        tt-es-contrato-docum-imp-aux.tp-codigo       = INPUT FRAME fPage0 i-tp-codigo.

  /* validar registros */



  /* fim valida registros */

  IF pc-action = "ADD" THEN DO:
      CREATE es-contrato-docum-imp.
      BUFFER-COPY tt-es-contrato-docum-imp-aux TO es-contrato-docum-imp.
      ASSIGN  tt-es-contrato-docum-imp-aux.r-rowid = ROWID(es-contrato-docum-imp).
  END.
  ELSE DO:

      FIND FIRST bf-es-contrato-docum-imp EXCLUSIVE-LOCK 
      WHERE rowid(bf-es-contrato-docum-imp) = pr-rowid
          NO-ERROR.

      BUFFER-COPY tt-es-contrato-docum-imp-aux TO bf-es-contrato-docum-imp.
      ASSIGN  tt-es-contrato-docum-imp-aux.r-rowid = ROWID(bf-es-contrato-docum-imp).

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

