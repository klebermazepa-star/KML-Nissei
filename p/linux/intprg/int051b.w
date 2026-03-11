&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
*/
&Scoped-define WINDOW-NAME wWindow
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS wWindow 
/********************************************************************************
** Copyright DATASUL S.A. (1999)
** Todos os Direitos Reservados.
**
** Este fonte e de propriedade exclusiva da DATASUL, sua reproducao
** parcial ou total por qualquer meio, so podera ser feita mediante
** autorizacao expressa.
*******************************************************************************/
/********************************************************************************
**
** Programa: int051b - Listar Itens do Pedido - Chamado pelo int051
**
********************************************************************************/
{include/i-prgvrs.i INT051B 2.00.00.000}

CREATE WIDGET-POOL.

/* Preprocessors Definitions ---                                      */
&GLOBAL-DEFINE Program        INT051B
&GLOBAL-DEFINE Version        2.00.00.000

&GLOBAL-DEFINE WindowType     Master

&GLOBAL-DEFINE Folder         NO
&GLOBAL-DEFINE InitialPage    1
&GLOBAL-DEFINE FolderLabels   Itens

&GLOBAL-DEFINE page0Widgets   btOK  
&GLOBAL-DEFINE page1Widgets   brItem

/* Parameters Definitions ---                                           */

DEFINE INPUT PARAM p-nr-pedido AS INT NO-UNDO.
DEFINE INPUT PARAM p-tipo-ped  AS INT NO-UNDO. 

/* Local Variable Definitions ---                                       */

def temp-table tt-raw-digita NO-UNDO field raw-digita  as raw.

define temp-table tt-param no-undo
    field destino          as integer
    field arquivo          as char format "x(35)"
    field usuario          as char format "x(12)"
    field data-exec        as date
    field hora-exec        as integer
    field classifica       as integer
    field desc-classifica  as char format "x(40)".

def var raw-param          as raw no-undo.

def var h-acomp as handle no-undo.

DEFINE TEMP-TABLE tt-int_ds_pedido_retorno NO-UNDO LIKE int_ds_pedido_retorno
       field desc-item as char format "x(60)"
       field vl-preco-est like item-uni-estab.preco-base label "Pr Estadual"
       field vl-preco-int like item-uni-estab.preco-ul-ent label "Pr Interestadual"
       field class-fiscal like item.class-fiscal label "NCM"
       field uf-orig like estabelec.estado
       field uf-dest like estabelec.estado
       FIELD nen_notafiscal_n LIKE int_ds_pedido_produto.nen_notafiscal_n
       FIELD nen_serie_s LIKE int_ds_pedido_produto.nen_serie_s
       FIELD nep_sequencia_n LIKE int_ds_pedido_produto.nep_sequencia_n.

DEF VAR i-cont AS INT FORMAT ">,>>>,>>9" NO-UNDO.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME fpage0
&Scoped-define BROWSE-NAME brItem

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-int_ds_pedido_retorno

/* Definitions for BROWSE brItem                                        */
&Scoped-define FIELDS-IN-QUERY-brItem string(tt-int_ds_pedido_retorno.ppr_produto_n) tt-int_ds_pedido_retorno.desc-item tt-int_ds_pedido_retorno.rpp_quantidade_n tt-int_ds_pedido_retorno.vl-preco-est tt-int_ds_pedido_retorno.vl-preco-int tt-int_ds_pedido_retorno.class-fiscal tt-int_ds_pedido_retorno.nen_notafiscal_n tt-int_ds_pedido_retorno.nen_serie_s tt-int_ds_pedido_retorno.nep_sequencia_n   
&Scoped-define ENABLED-FIELDS-IN-QUERY-brItem   
&Scoped-define SELF-NAME brItem
&Scoped-define QUERY-STRING-brItem FOR EACH tt-int_ds_pedido_retorno NO-LOCK
&Scoped-define OPEN-QUERY-brItem OPEN QUERY {&SELF-NAME} FOR EACH tt-int_ds_pedido_retorno NO-LOCK.
&Scoped-define TABLES-IN-QUERY-brItem tt-int_ds_pedido_retorno
&Scoped-define FIRST-TABLE-IN-QUERY-brItem tt-int_ds_pedido_retorno


/* Definitions for FRAME fPage1                                         */
&Scoped-define OPEN-BROWSERS-IN-QUERY-fPage1 ~
    ~{&OPEN-QUERY-brItem}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS rtToolBar btOK 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR wWindow AS WIDGET-HANDLE NO-UNDO.

/* Definitions of the field level widgets                               */
DEFINE BUTTON btOK 
     LABEL "OK" 
     SIZE 10 BY 1.

DEFINE RECTANGLE rtToolBar
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 138.43 BY 1.42
     BGCOLOR 7 .

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY brItem FOR 
      tt-int_ds_pedido_retorno SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE brItem
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS brItem wWindow _FREEFORM
  QUERY brItem NO-LOCK DISPLAY
      string(tt-int_ds_pedido_retorno.ppr_produto_n) COLUMN-LABEL "Item"      FORMAT "x(16)"
tt-int_ds_pedido_retorno.desc-item             COLUMN-LABEL "Descri‡Æo" FORMAT "x(62)"
tt-int_ds_pedido_retorno.rpp_quantidade_n      COLUMN-LABEL "Quantidade"
tt-int_ds_pedido_retorno.vl-preco-est COLUMN-LABEL "Pre‡o Estadual"
tt-int_ds_pedido_retorno.vl-preco-int COLUMN-LABEL "Pre‡o Interestadual"
tt-int_ds_pedido_retorno.class-fiscal COLUMN-LABEL "NCM"
tt-int_ds_pedido_retorno.nen_notafiscal_n 
tt-int_ds_pedido_retorno.nen_serie_s 
tt-int_ds_pedido_retorno.nep_sequencia_n
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS NO-COLUMN-SCROLLING SEPARATORS SIZE 138 BY 16.42
         FONT 1 NO-EMPTY-SPACE.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME fpage0
     btOK AT ROW 17.83 COL 3.57
     rtToolBar AT ROW 17.63 COL 2.14
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1.14 ROW 1.42
         SIZE 140.29 BY 18.08
         FONT 1 WIDGET-ID 100.

DEFINE FRAME fPage1
     brItem AT ROW 1 COL 1 WIDGET-ID 600
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 2.29 ROW 1
         SIZE 138.72 BY 16.5
         FONT 1 WIDGET-ID 100.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: 
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
IF SESSION:DISPLAY-TYPE = "GUI":U THEN
  CREATE WINDOW wWindow ASSIGN
         HIDDEN             = YES
         TITLE              = ""
         HEIGHT             = 18.58
         WIDTH              = 140.14
         MAX-HEIGHT         = 24.67
         MAX-WIDTH          = 157
         VIRTUAL-HEIGHT     = 24.67
         VIRTUAL-WIDTH      = 157
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
/* REPARENT FRAME */
ASSIGN FRAME fPage1:FRAME = FRAME fpage0:HANDLE.

/* SETTINGS FOR FRAME fpage0
   FRAME-NAME                                                           */
ASSIGN 
       rtToolBar:HIDDEN IN FRAME fpage0           = TRUE.

/* SETTINGS FOR FRAME fPage1
                                                                        */
/* BROWSE-TAB brItem 1 fPage1 */
IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(wWindow)
THEN wWindow:HIDDEN = yes.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE brItem
/* Query rebuild information for BROWSE brItem
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH tt-int_ds_pedido_retorno NO-LOCK.
     _END_FREEFORM
     _Options          = "NO-LOCK"
     _TblOptList       = "USED"
     _Query            is OPENED
*/  /* BROWSE brItem */
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


&Scoped-define BROWSE-NAME brItem
&Scoped-define FRAME-NAME fPage1
&Scoped-define SELF-NAME brItem
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL brItem wWindow
ON ROW-DISPLAY OF brItem IN FRAME fPage1
DO:

    if (tt-int_ds_pedido_retorno.uf-orig = tt-int_ds_pedido_retorno.uf-dest and tt-int_ds_pedido_retorno.vl-preco-est = 0) 
    then tt-int_ds_pedido_retorno.vl-preco-est :bgcolor in browse brItem = 12. 
    else tt-int_ds_pedido_retorno.vl-preco-est :bgcolor in browse brItem = ?. 

    if (tt-int_ds_pedido_retorno.uf-orig <> tt-int_ds_pedido_retorno.uf-dest and tt-int_ds_pedido_retorno.vl-preco-int = 0) 
    then tt-int_ds_pedido_retorno.vl-preco-int :bgcolor in browse brItem = 12. 
    else tt-int_ds_pedido_retorno.vl-preco-int :bgcolor in browse brItem = ?. 

    if (tt-int_ds_pedido_retorno.class-fiscal = "" or tt-int_ds_pedido_retorno.class-fiscal = "00000000") 
    then tt-int_ds_pedido_retorno.class-fiscal :bgcolor in browse brItem = 12. 
    else tt-int_ds_pedido_retorno.class-fiscal :bgcolor in browse brItem = ?. 
  
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME fpage0
&Scoped-define SELF-NAME btOK
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btOK wWindow
ON CHOOSE OF btOK IN FRAME fpage0 /* OK */
DO:
    APPLY "CLOSE":U TO THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK wWindow 


/*--- L¢gica para inicializa‡Æo do programam ---*/
{window/MainBlock.i}

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

   RUN pi-openQueryItem.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-openQueryItem wWindow 
PROCEDURE pi-openQueryItem :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
empty temp-table tt-int_ds_pedido_retorno.

run utp/ut-acomp.p persistent set h-acomp.
run pi-inicializar in h-acomp ("Itens do Pedido").

session:SET-WAIT-STATE ("GENERAL").

ASSIGN i-cont = 0.

IF p-tipo-ped <> 48 THEN DO:
   for each int_ds_pedido_retorno no-lock where
            int_ds_pedido_retorno.ped_codigo_n = p-nr-pedido
            QUERY-TUNING(NO-LOOKAHEAD) on stop undo, leave:
   
       ASSIGN i-cont = i-cont + 1.
   
       RUN pi-acompanhar IN h-acomp (INPUT "Item: " + string(int_ds_pedido_retorno.ppr_produto_n) + " - " + STRING(i-cont,">,>>>,>>9")).
   
       CREATE tt-int_ds_pedido_retorno.
       BUFFER-COPY int_ds_pedido_retorno TO tt-int_ds_pedido_retorno.
   
       FOR FIRST int_ds_pedido_produto OF int_ds_pedido_retorno NO-LOCK:
       END.
       ASSIGN tt-int_ds_pedido_retorno.nen_notafiscal_n = IF AVAIL int_ds_pedido_produto THEN int_ds_pedido_produto.nen_notafiscal_n ELSE 0
              tt-int_ds_pedido_retorno.nen_serie_s      = IF AVAIL int_ds_pedido_produto THEN int_ds_pedido_produto.nen_serie_s      ELSE ""
              tt-int_ds_pedido_retorno.nep_sequencia_n  = IF AVAIL int_ds_pedido_produto THEN int_ds_pedido_produto.nep_sequencia_n  ELSE 0.
   
       IF tt-int_ds_pedido_retorno.nen_notafiscal_n = ? THEN
          ASSIGN tt-int_ds_pedido_retorno.nen_notafiscal_n = 0.
   
       IF tt-int_ds_pedido_retorno.nen_serie_s = "?" 
       OR tt-int_ds_pedido_retorno.nen_serie_s  = ? THEN
          ASSIGN tt-int_ds_pedido_retorno.nen_serie_s = "".
   
       IF tt-int_ds_pedido_retorno.nep_sequencia_n = ? THEN
          ASSIGN tt-int_ds_pedido_retorno.nep_sequencia_n = 0.                                                                                                                                          
   
       FOR FIRST ITEM WHERE 
                 ITEM.it-codigo = STRING(int_ds_pedido_retorno.ppr_produto_n) NO-LOCK QUERY-TUNING(NO-LOOKAHEAD):
       END.
       IF AVAIL ITEM THEN
          ASSIGN tt-int_ds_pedido_retorno.desc-item    = item.desc-item
                 tt-int_ds_pedido_retorno.class-fiscal = item.class-fiscal.
   
       for first int_ds_pedido no-lock of int_ds_pedido_retorno:
           for each estabelec no-lock where 
                    estabelec.cgc = int_ds_pedido.ped_cnpj_destino_s:
               assign tt-int_ds_pedido_retorno.uf-dest = estabelec.estado.
               leave.
           end.
   
           for each estabelec where
                    estabelec.cgc = int_ds_pedido.ped_cnpj_origem_s:
               assign tt-int_ds_pedido_retorno.uf-orig = estabelec.estado.
               for each item-uni-estab no-lock where 
                        item-uni-estab.it-codigo = trim(STRING(int_ds_pedido_retorno.ppr_produto_n)) and
                        item-uni-estab.cod-estabel = estabelec.cod-estabel:
   
                   assign tt-int_ds_pedido_retorno.vl-preco-est = item-uni-estab.preco-base
                          tt-int_ds_pedido_retorno.vl-preco-int = item-uni-estab.preco-ul-ent.
               end.
               leave.
           end.
   
           IF tt-int_ds_pedido_retorno.vl-preco-est = 0
           OR tt-int_ds_pedido_retorno.vl-preco-int = 0 THEN DO:
              for each item-uni-estab no-lock where 
                       item-uni-estab.it-codigo = trim(STRING(int_ds_pedido_retorno.ppr_produto_n)) and
                       item-uni-estab.cod-estabel = "973":
                  IF  tt-int_ds_pedido_retorno.vl-preco-est = 0 
                  AND item-uni-estab.preco-base <> 0 THEN
                      ASSIGN tt-int_ds_pedido_retorno.vl-preco-est = item-uni-estab.preco-base.
   
                  IF  tt-int_ds_pedido_retorno.vl-preco-int = 0 
                  AND item-uni-estab.preco-ul-ent <> 0 THEN
                      ASSIGN tt-int_ds_pedido_retorno.vl-preco-int = item-uni-estab.preco-ul-ent.
              end.
           END.
       end.
   END.
END.
ELSE DO:
   for each int_ds_pedido_produto_subs no-lock where
            int_ds_pedido_produto_subs.ped_codigo_n = p-nr-pedido
            QUERY-TUNING(NO-LOOKAHEAD) on stop undo, leave:

       ASSIGN i-cont = i-cont + 1.

       RUN pi-acompanhar IN h-acomp (INPUT "Item: " + string(int_ds_pedido_produto_subs.ppr_produto_n) + " - " + STRING(i-cont,">,>>>,>>9")).

       CREATE tt-int_ds_pedido_retorno.
       BUFFER-COPY int_ds_pedido_produto_subs TO tt-int_ds_pedido_retorno.

       IF tt-int_ds_pedido_retorno.nen_notafiscal_n = ? THEN
          ASSIGN tt-int_ds_pedido_retorno.nen_notafiscal_n = 0.

       IF tt-int_ds_pedido_retorno.nen_serie_s = "?" 
       OR tt-int_ds_pedido_retorno.nen_serie_s  = ? THEN
          ASSIGN tt-int_ds_pedido_retorno.nen_serie_s = "".

       IF tt-int_ds_pedido_retorno.nep_sequencia_n = ? THEN
          ASSIGN tt-int_ds_pedido_retorno.nep_sequencia_n = 0.                                                                                                                                          

       FOR FIRST ITEM WHERE 
                 ITEM.it-codigo = STRING(int_ds_pedido_produto_subs.ppr_produto_n) NO-LOCK QUERY-TUNING(NO-LOOKAHEAD):
       END.
       IF AVAIL ITEM THEN
          ASSIGN tt-int_ds_pedido_retorno.desc-item    = item.desc-item
                 tt-int_ds_pedido_retorno.class-fiscal = item.class-fiscal.

       for first int_ds_pedido_subs no-lock of int_ds_pedido_produto_subs:
           for each estabelec NO-LOCK where
                    estabelec.cgc = int_ds_pedido_subs.ped_cnpj_destino_s:
               assign tt-int_ds_pedido_retorno.uf-dest = estabelec.estado.
               leave.
           end.

           for each estabelec no-lock where
                    estabelec.cgc = int_ds_pedido_subs.ped_cnpj_origem_s:
               assign tt-int_ds_pedido_retorno.uf-orig = estabelec.estado.
               for each item-uni-estab no-lock where 
                        item-uni-estab.it-codigo = trim(STRING(int_ds_pedido_produto_subs.ppr_produto_n)) and
                        item-uni-estab.cod-estabel = estabelec.cod-estabel:

                   assign tt-int_ds_pedido_retorno.vl-preco-est = item-uni-estab.preco-base
                          tt-int_ds_pedido_retorno.vl-preco-int = item-uni-estab.preco-ul-ent.

               end.
               leave.
           end.

           IF tt-int_ds_pedido_retorno.vl-preco-est = 0
           OR tt-int_ds_pedido_retorno.vl-preco-int = 0 THEN DO:
              for each item-uni-estab no-lock where 
                       item-uni-estab.it-codigo = trim(STRING(int_ds_pedido_produto_subs.ppr_produto_n)) and
                       item-uni-estab.cod-estabel = "973":
                  IF  tt-int_ds_pedido_retorno.vl-preco-est = 0 
                  AND item-uni-estab.preco-base <> 0 THEN
                      ASSIGN tt-int_ds_pedido_retorno.vl-preco-est = item-uni-estab.preco-base.

                  IF  tt-int_ds_pedido_retorno.vl-preco-int = 0 
                  AND item-uni-estab.preco-ul-ent <> 0 THEN
                      ASSIGN tt-int_ds_pedido_retorno.vl-preco-int = item-uni-estab.preco-ul-ent.
              end.
           END.
       end.
   END.
END.

run pi-finalizar in h-acomp.

session:SET-WAIT-STATE ("").

if can-find (first tt-int_ds_pedido_retorno) then do:
   OPEN QUERY brItem FOR EACH tt-int_ds_pedido_retorno NO-LOCK
       max-rows 100000 .
   enable all with frame fPage1.
   brItem:SELECT-ROW(1) in frame fPage1.
   apply "VALUE-CHANGED":U to brItem in frame fPage1.
end.
else do:
   close query brItem.
   disable all with frame fPage1.
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

