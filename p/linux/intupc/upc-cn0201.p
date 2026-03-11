/*******************************************************************************
**  Programa.: upc-cn0201.p	- UPC programa Manutená∆o de Contratos
**  
**  Descriá∆o: Bot∆o para chamar programa para anexar arquivos ao Contrato 
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

def new global shared var wh-bt-anexar-cn0201   as widget-handle no-undo.
def new global shared var wh-bt-imagem-cn0201   as widget-handle no-undo.
def var wh-frame                                as widget-handle no-undo.

def new global shared var r-rowid-upc-cn0201    as rowid no-undo.

/******************************************************************************************************/
assign c-char = entry(num-entries(p-wgh-object:private-data, "~/"), p-wgh-object:private-data, "~/")
       r-rowid-upc-cn0201 = p-row-table.

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
       
       IF wh-frame:NAME = "bt-copia" THEN 
          ASSIGN wh-bt-imagem-cn0201 = wh-frame.
               
       ASSIGN wh-frame = wh-frame:NEXT-SIBLING.

    END.
END.

IF p-ind-event  = "initialize" AND  
   p-ind-object = "container" THEN DO:  

   IF VALID-HANDLE (wh-bt-imagem-cn0201) THEN DO:  
      CREATE BUTTON wh-bt-anexar-cn0201                                       
      ASSIGN FRAME     = wh-bt-imagem-cn0201:FRAME                        
             LABEL     = wh-bt-imagem-cn0201:LABEL                            
             FONT      = 4
             WIDTH     = 4.5 
             HEIGHT    = 1.20
             ROW       = 1.10                              
             COL       = wh-bt-imagem-cn0201:COL + 5.5
             FGCOLOR   = ?
             BGCOLOR   = ?
             CONVERT-3D-COLORS = YES
             TOOLTIP   = "Anexar Arquivos"
             VISIBLE   = wh-bt-imagem-cn0201:VISIBLE                                        
             SENSITIVE = wh-bt-imagem-cn0201:SENSITIVE
             TRIGGERS:                                              
                 ON CHOOSE PERSISTENT RUN intprg/nicn0201.w.
             END TRIGGERS.
              
             wh-bt-anexar-cn0201:LOAD-IMAGE-UP("image/toolbar/im-imp").
             wh-bt-anexar-cn0201:LOAD-IMAGE-INSENSITIVE("image/toolbar/im-imp").
             wh-bt-anexar-cn0201:MOVE-TO-TOP().
   end.
end.

RETURN "OK".
