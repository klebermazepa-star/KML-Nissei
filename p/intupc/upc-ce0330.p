/*******************************************************************************
**  Programa.: upc-ce0330.p	- UPC cadastro de Itens x estabelecimento e regime especial por estabecimento
**  
**  Descri‡Æo: InclusÆo dos campos NCMIPI, Pre‡o Base e Pre‡o Ult. Entrada
               CriacÆo do flag de regime especial
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


DEF NEW GLOBAL SHARED VAR wh-controleQualidade       AS WIDGET-HANDLE NO-UNDO.
DEF NEW GLOBAL SHARED VAR wh-regimeEspecial          AS WIDGET-HANDLE NO-UNDO.
DEF NEW GLOBAL SHARED VAR wh-ponto-encomenda-ce0330     AS WIDGET-HANDLE NO-UNDO.
DEF NEW GLOBAL SHARED VAR wh-preco-base-ce0330          AS WIDGET-HANDLE NO-UNDO.
DEF NEW GLOBAL SHARED VAR wh-label-preco-base-ce0330    AS WIDGET-HANDLE NO-UNDO.
DEF NEW GLOBAL SHARED VAR wh-preco-ul-ent-ce0330        AS WIDGET-HANDLE NO-UNDO.
DEF NEW GLOBAL SHARED VAR wh-label-preco-ul-ent-ce0330  AS WIDGET-HANDLE NO-UNDO.

def new global shared var wh-frame                 as widget-handle no-undo.



/******************************************************************************************************/


.MESSAGE p-ind-event              "p-ind-event  " SKIP
         p-ind-object             "p-ind-object " skip
         p-wgh-object:FILE-NAME   "p-wgh-object " skip
         c-char                   "c-char " SKIP  
         p-wgh-frame:NAME         "p-wgh-frame  " skip
         p-cod-table              "p-cod-table  " skip
        string(p-row-table)      "p-row-table  " skip
    VIEW-AS ALERT-BOX INFO BUTTONS OK.

IF (p-ind-event  = "BEFORE-DISPLAY" AND  
    p-ind-object = "CONTAINER")  THEN DO:
    
      
                                
        RUN utils/findWidget.p (INPUT  'contr-qualid',   
                                INPUT  'TOGGLE-BOX',       
                                INPUT  p-wgh-frame,    
                                OUTPUT wh-controleQualidade).                        
                                
    IF VALID-HANDLE (wh-controleQualidade) AND NOT VALID-HANDLE(wh-regimeEspecial) THEN DO: 
    
       create toggle-box wh-regimeEspecial
        ASSIGN FRAME             = wh-controleQualidade:FRAME
               WIDTH             = wh-controleQualidade:WIDTH
               HEIGHT            = wh-controleQualidade:HEIGHT
               ROW               = wh-controleQualidade:ROW - 1.2
               COL               = wh-controleQualidade:COL 
               NAME              = 'wh-regimeEspecial'
               VISIBLE           = yes
               SENSITIVE         = no
               CHECKED           = no
               LABEL             = "Regime Especial". 
               
    
    END. 
    
    run utils\findWidget.p( 'fator-refugo', 
                            'fill-in', 
                            p-wgh-frame, 
                            output wh-ponto-encomenda-ce0330).
    
    IF valid-handle(wh-ponto-encomenda-ce0330) THEN DO:

        CREATE TEXT wh-label-preco-base-ce0330
        ASSIGN ROW            = wh-ponto-encomenda-ce0330:ROW
               COLUMN         = wh-ponto-encomenda-ce0330:COL + wh-ponto-encomenda-ce0330:WIDTH + 10
               FRAME          = wh-ponto-encomenda-ce0330:FRAME
               SENSITIVE      = NO
               VISIBLE        = YES
               HEIGHT-CHARS   = 0.88
               WIDTH-CHARS    = 9
               FORMAT         = "X(11)"
               SCREEN-VALUE   = "Pre‡o Base:".

         CREATE FILL-IN wh-preco-base-ce0330
         ASSIGN ROW          = wh-label-preco-base-ce0330:ROW
                COLUMN       = wh-label-preco-base-ce0330:COL + wh-label-preco-base-ce0330:WIDTH  + 1
                DATA-TYPE    = "DECIMAL"
                FRAME        = wh-label-preco-base-ce0330:FRAME
                SENSITIVE    = NO
                VISIBLE      = YES
                HEIGHT       = 0.88
                WIDTH        = 12
                NAME         = "preco-base"
                FORMAT       = ">>>,>>>,>>9.9999"
                SCREEN-VALUE = "0"
                HELP         = "Informe o Pre‡o Base do Item".    
                
        CREATE TEXT wh-label-preco-ul-ent-ce0330
        ASSIGN ROW            = wh-ponto-encomenda-ce0330:ROW  + 1.1
               COLUMN         = wh-ponto-encomenda-ce0330:COL + wh-ponto-encomenda-ce0330:WIDTH + 10
               FRAME          = wh-ponto-encomenda-ce0330:FRAME
               SENSITIVE      = NO
               VISIBLE        = YES
               HEIGHT-CHARS   = 0.88
               WIDTH-CHARS    = 10
               FORMAT         = "X(15)"
               SCREEN-VALUE   = "Pre‡o Ult. Ent:".

         CREATE FILL-IN wh-preco-ul-ent-ce0330
         ASSIGN ROW          = wh-label-preco-ul-ent-ce0330:ROW
                COLUMN       = wh-label-preco-ul-ent-ce0330:COL + wh-label-preco-ul-ent-ce0330:WIDTH
                DATA-TYPE    = "DECIMAL"
                FRAME        = wh-label-preco-ul-ent-ce0330:FRAME
                SENSITIVE    = NO
                VISIBLE      = YES
                HEIGHT       = 0.88
                WIDTH        = 12
                NAME         = "preco-ult-entrada"
                FORMAT       = ">>>,>>>,>>9.9999"
                SCREEN-VALUE = "0"
                HELP         = "Informe o Pre‡o Base do Item".                   
    END.
    
END.

IF  p-ind-event = "after-Enable"   THEN DO:
    
    IF VALID-HANDLE(wh-regimeEspecial) THEN
       ASSIGN wh-regimeEspecial:SENSITIVE       = TRUE.

END.

IF  p-ind-event = "after-Disable"  THEN DO:
   
    IF  VALID-HANDLE(wh-regimeEspecial) THEN
        ASSIGN wh-regimeEspecial:SENSITIVE       = FALSE.
END.

IF  p-ind-event  = "after-assign" THEN DO:

    FIND FIRST item-uni-estab EXCLUSIVE-LOCK
        WHERE ROWID(item-uni-estab) = p-row-table NO-ERROR.

    IF AVAIL item-uni-estab THEN DO:
            
        IF wh-regimeEspecial:CHECKED = YES THEN
            OVERLAY(item-uni-estab.char-2,60,1) = "S".
        ELSE 
            OVERLAY(item-uni-estab.char-2,60,1) = "N".

    END.

END.

IF  p-ind-event = "after-Display"   THEN DO:

    FIND FIRST item-uni-estab EXCLUSIVE-LOCK
        WHERE ROWID(item-uni-estab) = p-row-table NO-ERROR.

    IF AVAIL item-uni-estab THEN DO:
    
        IF SUBSTRING(item-uni-estab.char-2,60,1) = "S" THEN
            wh-regimeEspecial:CHECKED = YES.
        ELSE 
            wh-regimeEspecial:CHECKED = NO.
    END.

END.

IF (p-ind-event  = "AFTER-DISPLAY" AND  
    p-ind-object = "CONTAINER")  THEN DO:
            
    FIND FIRST item-uni-estab 
        WHERE rowid(item-uni-estab) = p-row-table NO-LOCK NO-ERROR.
          
    IF AVAIL item-uni-estab THEN 
        ASSIGN wh-preco-base-ce0330:SCREEN-VALUE    = STRING(item-uni-estab.preco-base)
               wh-preco-ul-ent-ce0330:SCREEN-VALUE  = STRING(item-uni-estab.preco-ul-ent).
    ELSE  
        ASSIGN wh-preco-base-ce0330:SCREEN-VALUE    = "0,0000"
               wh-preco-ul-ent-ce0330:SCREEN-VALUE  = "0,0000".
    
END.

IF (p-ind-event  = "AFTER-ASSIGN" AND  
    p-ind-object = "CONTAINER")  THEN DO:
        
    FIND FIRST item-uni-estab 
        WHERE rowid(item-uni-estab) = p-row-table EXCLUSIVE-LOCK NO-ERROR.
          
    IF AVAIL item-uni-estab THEN 
        ASSIGN item-uni-estab.preco-base    = dec(wh-preco-base-ce0330:SCREEN-VALUE)
               item-uni-estab.preco-ul-ent  = dec(wh-preco-ul-ent-ce0330:SCREEN-VALUE).
        
    RELEASE item-uni-estab.
END.

IF (p-ind-event  = "AFTER-ENABLE" AND  
    p-ind-object = "CONTAINER")  THEN DO:
    
    IF valid-handle(wh-preco-base-ce0330) THEN
        ASSIGN wh-preco-base-ce0330:SENSITIVE = TRUE
               wh-preco-ul-ent-ce0330:SENSITIVE = TRUE.    

    
END.

IF (p-ind-event  = "AFTER-DISABLE" AND  
    p-ind-object = "CONTAINER")  THEN DO:
    
    IF valid-handle(wh-preco-base-ce0330) THEN
        ASSIGN wh-preco-base-ce0330:SENSITIVE = NO
               wh-preco-ul-ent-ce0330:SENSITIVE = NO.    

    
END.

RETURN "OK".

 
