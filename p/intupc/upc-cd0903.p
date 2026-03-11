/*******************************************************************************
**  Programa.: upc-cd0903.p	- UPC programa Atualizaá∆o Itens Faturamento
**  
**  Descriá∆o: Alteraá∆o do label do campo Forma Descriá∆o Item
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
DEF VAR h-campo                    as widget-handle no-undo. 

DEF NEW GLOBAL SHARED VAR wh-label-forma-desc-cd0903 AS WIDGET-HANDLE NO-UNDO.
DEF NEW GLOBAL SHARED VAR wh-text-forma-desc-cd0903  AS WIDGET-HANDLE NO-UNDO.
DEF NEW GLOBAL SHARED VAR h-cb-origem-pis            AS WIDGET-HANDLE NO-UNDO.
DEF NEW GLOBAL SHARED VAR h-cb-origem-cofins         AS WIDGET-HANDLE NO-UNDO.
DEF NEW GLOBAL SHARED VAR h-ind-especifico           AS WIDGET-HANDLE NO-UNDO.
DEF NEW GLOBAL SHARED VAR wh-regimeEspecial          AS WIDGET-HANDLE NO-UNDO.

/******************************************************************************************************/
assign c-char = entry(num-entries(p-wgh-object:private-data, "~/"), p-wgh-object:private-data, "~/").

/*
IF c-char       = "vb5in172.w"  THEN
    MESSAGE p-ind-event              "p-ind-event  " skip
             p-ind-object             "p-ind-object " skip
             p-wgh-object:FILE-NAME   "p-wgh-object " skip
             c-char                   "c-char " SKIP  
             p-wgh-frame:NAME         "p-wgh-frame  " skip
             p-cod-table              "p-cod-table  " skip
            string(p-row-table)      "p-row-table  " skip
    VIEW-AS ALERT-BOX INFO BUTTONS OK.  
*/

/* KML - Customizaá∆o para bloquear o campo origem aliquota do pis e cofins */
IF p-ind-object = "viewer"            AND 
   c-char      = "v42in172.w"         THEN DO:


    RUN utils/findWidget.p (INPUT  'cb-origem-pis',   
                            INPUT  'COMBO-BOX',       
                            INPUT  p-wgh-frame,    
                            OUTPUT h-campo).
    if valid-handle (h-campo) then 
       assign h-cb-origem-pis = h-campo.

    RUN utils/findWidget.p (INPUT  'ind-especifico',   
                            INPUT  'TOGGLE-BOX',       
                            INPUT  p-wgh-frame,    
                            OUTPUT h-campo).
    if valid-handle (h-campo) then 
       assign h-ind-especifico = h-campo.

    RUN utils/findWidget.p (INPUT  'cb-origem-cofins',   
                            INPUT  'COMBO-BOX',       
                            INPUT  p-wgh-frame,    
                            OUTPUT h-campo).
    if valid-handle (h-campo) then 
       assign h-cb-origem-cofins = h-campo.

    IF VALID-HANDLE(h-cb-origem-pis) THEN DO:
    
        ASSIGN h-cb-origem-pis:SENSITIVE = FALSE.
        ASSIGN h-cb-origem-pis:SCREEN-VALUE = "Item".
        APPLY "VALUE-CHANGED" TO h-cb-origem-pis.

    END.

    IF VALID-HANDLE(h-cb-origem-cofins) THEN DO:
    
        ASSIGN h-cb-origem-cofins:SENSITIVE = FALSE.
        ASSIGN h-cb-origem-cofins:SCREEN-VALUE = "Item". 
        APPLY "VALUE-CHANGED" TO h-cb-origem-cofins. 
    
    END.

END.
/* KML - Fim da Customizaá∆o para bloquear o campo de origem pis cofins */

IF  p-ind-event  = "DISPLAY"   
AND p-ind-object = "viewer"
AND c-char       = "v42in172.w" THEN DO:  

   CREATE TEXT wh-label-forma-desc-cd0903
   ASSIGN ROW            = 4.94
          COLUMN         = 11.45
          FRAME          = p-wgh-frame
          SENSITIVE      = NO
          VISIBLE        = YES
          HEIGHT-CHARS   = 0.88
          WIDTH-CHARS    = 15.5
          FORMAT         = "X(22)"
          SCREEN-VALUE   = "Descriá∆o Item + Lote:".
              
   CREATE TEXT wh-text-forma-desc-cd0903
   ASSIGN ROW            = 4
          COLUMN         = 34
          FRAME          = p-wgh-frame
          SENSITIVE      = NO
          VISIBLE        = YES
          HEIGHT-CHARS   = 0.88
          WIDTH-CHARS    = 49
          FORMAT         = "X(63)"
          SCREEN-VALUE   = "Descriá∆o = SEM LOTE / Desc + 24 Narrativa Informada = COM LOTE"
          TOOLTIP        = "Informaá∆o utilizada para Impress∆o da Nota Fiscal".

   IF VALID-HANDLE(h-ind-especifico) THEN DO:
       
      /* create toggle-box wh-regimeEspecial
        ASSIGN FRAME             = h-ind-especifico:FRAME
               WIDTH             = h-ind-especifico:WIDTH
               HEIGHT            = h-ind-especifico:HEIGHT
               ROW               = h-ind-especifico:ROW 
               COL               = h-ind-especifico:COL + 20
               NAME              = 'wh-regimeEspecial'
               VISIBLE           = yes
               SENSITIVE         = no
               CHECKED           = no
               LABEL             = "Regime Especial".     */

   END.

END.

IF  p-ind-event = "Enable"      
AND c-char      = "v42in172.w" THEN DO:
    
   /* IF VALID-HANDLE(wh-regimeEspecial) THEN
       ASSIGN wh-regimeEspecial:SENSITIVE       = TRUE.  */

END.

IF  p-ind-event = "Disable"     
AND c-char      = "v42in172.w" THEN DO:
   
   /*IF  VALID-HANDLE(wh-regimeEspecial) THEN
        ASSIGN wh-regimeEspecial:SENSITIVE       = FALSE.       */
END.

IF  p-ind-event  = "assign" 
    AND p-ind-object = "viewer"
    AND c-char       = "v42in172.w" THEN DO:

   /* FIND FIRST ITEM EXCLUSIVE-LOCK
        WHERE ROWID(ITEM) = p-row-table NO-ERROR.

    IF AVAIL ITEM THEN DO:
        
        IF wh-regimeEspecial:CHECKED = YES THEN
            OVERLAY(ITEM.char-2,60,1) = "S".
        ELSE 
            OVERLAY(ITEM.char-2,60,1) = "N".     

    END.                 */

END.

IF  p-ind-event = "Display"   
    AND c-char  = "v42in172.w" THEN DO:
     /*
    FIND FIRST ITEM EXCLUSIVE-LOCK
        WHERE ROWID(ITEM) = p-row-table NO-ERROR.

    IF AVAIL ITEM THEN DO:

        IF SUBSTRING(ITEM.char-2,60,1) = "S" THEN
            wh-regimeEspecial:CHECKED = YES.
        ELSE 
            wh-regimeEspecial:CHECKED = NO.
    END.    */

END.



RETURN "OK".
