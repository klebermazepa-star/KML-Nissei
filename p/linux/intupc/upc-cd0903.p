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

DEF NEW GLOBAL SHARED VAR wh-label-forma-desc-cd0903 AS WIDGET-HANDLE NO-UNDO.
DEF NEW GLOBAL SHARED VAR wh-text-forma-desc-cd0903  AS WIDGET-HANDLE NO-UNDO.

/******************************************************************************************************/
assign c-char = entry(num-entries(p-wgh-object:private-data, "~/"), p-wgh-object:private-data, "~/").

/*MESSAGE p-ind-event              "p-ind-event  " skip
         p-ind-object             "p-ind-object " skip
         p-wgh-object:FILE-NAME   "p-wgh-object " skip
         c-char                   "c-char " SKIP  
         p-wgh-frame:NAME         "p-wgh-frame  " skip
         p-cod-table              "p-cod-table  " skip
        string(p-row-table)      "p-row-table  " skip
VIEW-AS ALERT-BOX INFO BUTTONS OK.*/

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
END.

RETURN "OK".

 
