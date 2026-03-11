/*******************************************************************************
**  Programa.: upc-cd0204.p	- UPC cadastro de Itens
**  
**  Descri‡Æo: InclusÆo dos campos NCMIPI, Pre‡o Base e Pre‡o Ult. Entrada
*********************************************************************************/

def input param p-ind-event        as char          no-undo.
def input param p-ind-object       as char          no-undo.
def input param p-wgh-object       as handle        no-undo.
def input param p-wgh-frame        as widget-handle no-undo.
def input param p-cod-table        as char          no-undo.
def input param p-row-table        as rowid         no-undo.

DEF VAR c-char                     AS CHAR          NO-UNDO.
DEF VAR wh-objeto                  AS WIDGET-HANDLE NO-UNDO.
DEF VAR wgh-child                  AS WIDGET-HANDLE NO-UNDO.

DEF NEW GLOBAL SHARED VAR de-preco-base-cd0204   LIKE item-uni-estab.preco-base   NO-UNDO.
DEF NEW GLOBAL SHARED VAR de-preco-ul-ent-cd0204 LIKE item-uni-estab.preco-ul-ent NO-UNDO.
DEF NEW GLOBAL SHARED VAR l-item-estab-cd0204    AS   LOGICAL                     NO-UNDO.
DEF NEW GLOBAL SHARED VAR c-it-codigo-cd0204     LIKE ITEM.it-codigo              NO-UNDO.

DEF NEW GLOBAL SHARED VAR wh-it-codigo-cd0204          AS WIDGET-HANDLE NO-UNDO.
DEF NEW GLOBAL SHARED VAR wh-ncmipi-cd0204             AS WIDGET-HANDLE NO-UNDO.
DEF NEW GLOBAL SHARED VAR wh-label-ncmipi-cd0204       AS WIDGET-HANDLE NO-UNDO.
def new global shared var wh-bt-compl-it-cd0204        as widget-handle no-undo.
def new global shared var wh-bt-exporta-cd0204         as widget-handle no-undo.
def new global shared var wh-cd-folh-item-cd0204       as widget-handle no-undo.
DEF NEW GLOBAL SHARED VAR wh-it-carac-tec-cd0204       AS WIDGET-HANDLE NO-UNDO.
DEF NEW GLOBAL SHARED VAR wgh-handle-container-cd0204  AS WIDGET-HANDLE NO-UNDO.

DEF NEW GLOBAL SHARED VAR wh-preco-base-cd0204         AS WIDGET-HANDLE NO-UNDO.
DEF NEW GLOBAL SHARED VAR wh-preco-ul-ent-cd0204       AS WIDGET-HANDLE NO-UNDO.
DEF NEW GLOBAL SHARED VAR wh-label-preco-base-cd0204   AS WIDGET-HANDLE NO-UNDO.
DEF NEW GLOBAL SHARED VAR wh-label-preco-ul-ent-cd0204 AS WIDGET-HANDLE NO-UNDO.

def new global shared var wh-frame                 as widget-handle no-undo.

def new global shared var r-rowid-upc-cd0204       as rowid no-undo.

/******************************************************************************************************/
assign c-char = entry(num-entries(p-wgh-object:private-data, "~/"), p-wgh-object:private-data, "~/")
       r-rowid-upc-cd0204 = p-row-table.

/*MESSAGE p-ind-event              "p-ind-event  " skip
         p-ind-object             "p-ind-object " skip
         p-wgh-object:FILE-NAME   "p-wgh-object " skip
         p-wgh-frame:NAME         "p-wgh-frame  " skip
         p-cod-table              "p-cod-table  " skip
        string(p-row-table)      "p-row-table  " skip
 VIEW-AS ALERT-BOX INFO BUTTONS OK.*/


IF (p-ind-event  = "before-initialize" AND  
    p-ind-object = "container")  OR 
   (p-ind-event  = "initialize" AND  
    p-ind-object = "viewer") THEN DO:          
    
    ASSIGN wh-frame = p-wgh-frame:FIRST-CHILD
           wh-frame = wh-frame:FIRST-CHILD. 
 
    DO WHILE VALID-HANDLE(wh-frame):
       
       IF wh-frame:NAME = "bt-exporta" THEN 
          ASSIGN wh-bt-exporta-cd0204 = wh-frame.

       IF wh-frame:NAME = "cd-folh-item" THEN 
          ASSIGN wh-cd-folh-item-cd0204 = wh-frame.

       IF wh-frame:NAME = "it-codigo" THEN 
          ASSIGN wh-it-carac-tec-cd0204 = wh-frame.
               
       ASSIGN wh-frame = wh-frame:NEXT-SIBLING.

    END.
END.

IF p-ind-event  = "initialize" AND  
   p-ind-object = "container" THEN DO:  
    
   ASSIGN wgh-handle-container-cd0204 = p-wgh-object.

   IF VALID-HANDLE (wh-bt-exporta-cd0204) THEN DO:  
      CREATE BUTTON wh-bt-compl-it-cd0204                                       
      ASSIGN FRAME     = wh-bt-exporta-cd0204:FRAME                        
             LABEL     = wh-bt-exporta-cd0204:LABEL                            
             FONT      = 4
             WIDTH     = 4.5 
             HEIGHT    = 1.20
             ROW       = 1.10                              
             COL       = wh-bt-exporta-cd0204:COL + 4.2
             FGCOLOR   = ?
             BGCOLOR   = ?
             CONVERT-3D-COLORS = YES
             TOOLTIP   = "C¢digos EAN"
             VISIBLE   = wh-bt-exporta-cd0204:VISIBLE                                        
             SENSITIVE = wh-bt-exporta-cd0204:SENSITIVE
             TRIGGERS:                                              
                 ON CHOOSE PERSISTENT RUN intprg/nicd0204.w.
             END TRIGGERS.
              
      wh-bt-compl-it-cd0204:LOAD-IMAGE-UP("image/toolbar/mip-barras").
      wh-bt-compl-it-cd0204:LOAD-IMAGE-INSENSITIVE("image/toolbar/mip-barras").
      wh-bt-compl-it-cd0204:MOVE-TO-TOP().
   end.
end.

if p-ind-event = "INITIALIZE" and c-char = "v34in172.w" then do:
    assign wh-objeto = p-wgh-frame:first-child 
           wh-objeto = wh-objeto:first-child.
    
    do while valid-handle(wh-objeto):        
       IF wh-objeto:NAME = "it-codigo" THEN
          ASSIGN wh-it-codigo-cd0204 = wh-objeto.        
       IF wh-objeto:TYPE = "field-group" THEN
          assign wh-objeto = wh-objeto:FIRST-CHILD.
       ELSE
          ASSIGN wh-objeto = wh-objeto:next-sibling.    
    END.
END.


IF  p-ind-event = "before-initialize"   
AND c-char      = "v36in172.w" THEN DO:  

   CREATE TEXT wh-label-ncmipi-cd0204
   ASSIGN ROW            = 7.3
          COLUMN         = 21.9
          FRAME          = p-wgh-frame
          SENSITIVE      = NO
          VISIBLE        = YES
          HEIGHT-CHARS   = 0.88
          WIDTH-CHARS    = 8
          FORMAT         = "X(8)"
          SCREEN-VALUE   = "NCMIPI:".

    CREATE FILL-IN wh-ncmipi-cd0204
    ASSIGN ROW          = 7.3
           COLUMN       = 27.8
           DATA-TYPE    = "INTEGER"
           FRAME        = p-wgh-frame
           SENSITIVE    = NO
           VISIBLE      = YES
           HEIGHT       = 0.88
           WIDTH        = 10
           NAME         = "ncmipi"
           FORMAT       = ">>>>>>>>9"
           SCREEN-VALUE = "0"
           HELP         = "Informe o NCMIPI do Item".

    CREATE TEXT wh-label-preco-base-cd0204
    ASSIGN ROW            = 4.2
           COLUMN         = 57
           FRAME          = p-wgh-frame
           SENSITIVE      = NO
           VISIBLE        = YES
           HEIGHT-CHARS   = 0.88
           WIDTH-CHARS    = 12
           FORMAT         = "X(11)"
           SCREEN-VALUE   = "Pre‡o Base:".

     CREATE FILL-IN wh-preco-base-cd0204
     ASSIGN ROW          = 4.2
            COLUMN       = 65.7
            DATA-TYPE    = "DECIMAL"
            FRAME        = p-wgh-frame
            SENSITIVE    = NO
            VISIBLE      = YES
            HEIGHT       = 0.88
            WIDTH        = 17
            NAME         = "preco-base"
            FORMAT       = ">>>,>>>,>>9.9999"
            SCREEN-VALUE = "0"
            HELP         = "Informe o Pre‡o Base do Item".

     CREATE TEXT wh-label-preco-ul-ent-cd0204
     ASSIGN ROW            = 5.2
            COLUMN         = 55
            FRAME          = p-wgh-frame
            SENSITIVE      = NO
            VISIBLE        = YES
            HEIGHT-CHARS   = 0.88
            WIDTH-CHARS    = 12
            FORMAT         = "X(17)"
            SCREEN-VALUE   = "Pre‡o Ult. Ent.:".

      CREATE FILL-IN wh-preco-ul-ent-cd0204
      ASSIGN ROW          = 5.2
             COLUMN       = 65.7
             DATA-TYPE    = "DECIMAL"
             FRAME        = p-wgh-frame
             SENSITIVE    = NO
             VISIBLE      = YES
             HEIGHT       = 0.88
             WIDTH        = 17
             NAME         = "preco-ul-ent"
             FORMAT       = ">>>,>>>,>>9.9999"
             SCREEN-VALUE = "0"
             HELP         = "Informe o Pre‡o Ultima Entrada do Item".

END.

IF  p-ind-event = "Enable"      
AND c-char      = "v36in172.w" THEN DO:
    
    IF VALID-HANDLE(wh-ncmipi-cd0204) THEN
       ASSIGN wh-ncmipi-cd0204:SENSITIVE       = TRUE
              wh-preco-base-cd0204:SENSITIVE   = TRUE
              wh-preco-ul-ent-cd0204:SENSITIVE = TRUE.

END.

IF  p-ind-event = "Disable"     
AND c-char      = "v36in172.w" THEN DO:
   
    IF  VALID-HANDLE(wh-ncmipi-cd0204) THEN
        ASSIGN wh-ncmipi-cd0204:SENSITIVE       = FALSE
               wh-preco-base-cd0204:SENSITIVE   = FALSE
               wh-preco-ul-ent-cd0204:SENSITIVE = FALSE.
END.

IF  p-ind-event = "Display"   
AND c-char      = "v36in172.w" THEN DO:

    IF VALID-HANDLE(wh-ncmipi-cd0204) THEN DO:
       ASSIGN wh-ncmipi-cd0204:SENSITIVE          = FALSE
              wh-ncmipi-cd0204:SCREEN-VALUE       = "0"
              wh-preco-base-cd0204:SENSITIVE      = FALSE
              wh-preco-ul-ent-cd0204:SENSITIVE    = FALSE.

       FIND FIRST ITEM NO-LOCK
            WHERE ROWID(ITEM) = p-row-table  NO-ERROR.
       IF AVAIL ITEM THEN DO:
          FIND first int-ds-ext-item NO-LOCK 
               WHERE int-ds-ext-item.it-codigo = ITEM.it-codigo NO-ERROR.
          IF AVAIL int-ds-ext-item THEN
             ASSIGN wh-ncmipi-cd0204:SCREEN-VALUE = string(int-ds-ext-item.ncmipi).

          FIND FIRST item-uni-estab WHERE
                     item-uni-estab.it-codigo   = ITEM.it-codigo AND
                     item-uni-estab.cod-estabel = "973" NO-LOCK NO-ERROR.
          IF AVAIL item-uni-estab THEN DO:
             ASSIGN wh-preco-base-cd0204:SCREEN-VALUE   = STRING(item-uni-estab.preco-base)
                    wh-preco-ul-ent-cd0204:SCREEN-VALUE = STRING(item-uni-estab.preco-ul-ent).
          END.
          ELSE DO: 
             ASSIGN wh-preco-base-cd0204:SCREEN-VALUE   = "0,0000"
                    wh-preco-ul-ent-cd0204:SCREEN-VALUE = "0,0000".
          END.
       END.  
    END.

    RUN select-page IN wgh-handle-container-cd0204 (INPUT 3).
    RUN select-page IN wgh-handle-container-cd0204 (INPUT 1).

END.

if  p-ind-event = "ASSIGN"      
AND c-char      = "v36in172.w" then do:

    IF  VALID-HANDLE(wh-ncmipi-cd0204) THEN DO:

        ASSIGN wh-ncmipi-cd0204:SENSITIVE       = FALSE
               wh-preco-base-cd0204:SENSITIVE   = FALSE
               wh-preco-ul-ent-cd0204:SENSITIVE = FALSE.

        FIND FIRST ITEM NO-LOCK
             WHERE ROWID(ITEM) = p-row-table  NO-ERROR.
        IF AVAIL ITEM THEN DO:
           FIND first int-ds-ext-item WHERE 
                      int-ds-ext-item.it-codigo = ITEM.it-codigo exclusive-LOCK NO-ERROR.
           IF NOT AVAIL int-ds-ext-item THEN DO:
              CREATE int-ds-ext-item.
              ASSIGN int-ds-ext-item.it-codigo = ITEM.it-codigo.
           END. 
           ASSIGN int-ds-ext-item.ncmipi = int(wh-ncmipi-cd0204:SCREEN-VALUE).
        END.
    END.
END.

IF  p-ind-event = "ADD" 
AND c-char = "v36in172.w" THEN DO:
          
    IF l-item-estab-cd0204 = YES THEN DO:

        FOR EACH item-uni-estab WHERE
                 item-uni-estab.it-codigo = c-it-codigo-cd0204:
           
           ASSIGN item-uni-estab.preco-base   = de-preco-base-cd0204 
                  item-uni-estab.preco-ul-ent = de-preco-ul-ent-cd0204
                  item-uni-estab.data-base    = TODAY
                  item-uni-estab.data-ult-ent = TODAY.         
        END.                 
        ASSIGN l-item-estab-cd0204 = NO.
    END.
    
    ASSIGN wh-label-ncmipi-cd0204:VISIBLE = YES
           wh-label-ncmipi-cd0204:SCREEN-VALUE = "NCMIPI:"
           wh-ncmipi-cd0204:SCREEN-VALUE = "0".

    ASSIGN wh-label-preco-base-cd0204:VISIBLE = YES
           wh-label-preco-base-cd0204:SCREEN-VALUE = "Pre‡o Base:"
           wh-preco-base-cd0204:SCREEN-VALUE = "0".

    ASSIGN wh-label-preco-ul-ent-cd0204:VISIBLE = YES
           wh-label-preco-ul-ent-cd0204:SCREEN-VALUE = "Pre‡o Ult. Ent.:"
           wh-preco-ul-ent-cd0204:SCREEN-VALUE = "0".

    RUN select-page IN wgh-handle-container-cd0204 (INPUT 3).
    RUN select-page IN wgh-handle-container-cd0204 (INPUT 1).

END.

IF  (p-ind-event = "enable" OR p-ind-event = "after-enable") 
AND valid-handle(wh-it-codigo-cd0204) 
AND wh-it-codigo-cd0204:SENSITIVE = TRUE 
AND c-char = "v36in172.w" THEN DO:

    IF VALID-HANDLE(wh-ncmipi-cd0204) THEN
       ASSIGN wh-ncmipi-cd0204:SENSITIVE       = TRUE
              wh-preco-base-cd0204:SENSITIVE   = TRUE
              wh-preco-ul-ent-cd0204:SENSITIVE = TRUE.

    ASSIGN wh-ncmipi-cd0204:SCREEN-VALUE       = "0".
END. 

if  p-ind-event = "INITIALIZE" 
and c-char = "v35in172.w" then do:

    assign wh-objeto = p-wgh-frame:first-child 
           wh-objeto = wh-objeto:first-child.

    do while valid-handle(wh-objeto):
        
        IF wh-objeto:TYPE = "field-group" THEN
            assign wh-objeto = wh-objeto:FIRST-CHILD.
        ELSE
            ASSIGN wh-objeto = wh-objeto:next-sibling.
    END.
END.

IF  p-ind-event  = "validate" 
AND p-ind-object = "viewer"
AND c-char       = "v36in172.w" THEN DO:

    IF wh-preco-base-cd0204:SCREEN-VALUE = "0,0000" THEN DO:
       RUN select-page IN wgh-handle-container-cd0204 (INPUT 3).
       RUN select-page IN wgh-handle-container-cd0204 (INPUT 2).
       MESSAGE "Pre‡o Base deve ser diferente de zero."
           VIEW-AS ALERT-BOX ERROR BUTTONS OK.    
       RETURN "NOK".
    END.

    IF wh-preco-ul-ent-cd0204:SCREEN-VALUE = "0,0000" THEN DO:       
       RUN select-page IN wgh-handle-container-cd0204 (INPUT 3).
       RUN select-page IN wgh-handle-container-cd0204 (INPUT 2).
       MESSAGE "Pre‡o Ultima Entrada deve ser diferente de zero."
           VIEW-AS ALERT-BOX ERROR BUTTONS OK.
       RETURN "NOK".
    END.
END.

IF  p-ind-event  = "after-end-update" 
AND p-ind-object = "viewer"
AND c-char       = "v36in172.w" THEN DO:

    ASSIGN de-preco-base-cd0204   = DEC(wh-preco-base-cd0204:SCREEN-VALUE)
           de-preco-ul-ent-cd0204 = DEC(wh-preco-ul-ent-cd0204:SCREEN-VALUE).
  
    ASSIGN l-item-estab-cd0204 = YES
           c-it-codigo-cd0204  = wh-it-codigo-cd0204:SCREEN-VALUE.
    
   FIND FIRST ITEM NO-LOCK WHERE
         ROWID(ITEM) = p-row-table NO-ERROR.
    IF AVAIL ITEM THEN DO:
                                      
       FOR EACH item-uni-estab WHERE
                item-uni-estab.it-codigo = ITEM.it-codigo:

           ASSIGN item-uni-estab.preco-base   = de-preco-base-cd0204
                  item-uni-estab.preco-ul-ent = de-preco-ul-ent-cd0204
                  item-uni-estab.data-base    = TODAY
                  item-uni-estab.data-ult-ent = TODAY.
       END.
   END.
END.


