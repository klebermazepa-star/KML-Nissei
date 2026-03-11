/******************************************************************************
 * Programa:  upc-cc0105a.p
 * Diretorio: upc
 * Objetivo:  UPC para tirar o zero do campo item fornecedor
 *
 * Autor: KML - Lohan / Guilherme
 * Data de Criaî?o: 07/2024
 *
 ******************************************************************************/
def input param p-ind-event        as char          no-undo.
def input param p-ind-object       as char          no-undo.
def input param p-wgh-object       as handle        no-undo.
def input param p-wgh-frame        as widget-handle no-undo.
def input param p-cod-table        as char          no-undo.
def input param p-row-table        as rowid         no-undo.

define new global shared var h-centro-centro-wms  as handle no-undo.
define new global shared var h-l-aloca-saldo-erp    as handle no-undo.
define new global shared var h-text-centro-centro-wms    as handle no-undo.
define new global shared var h-RECT-5    as handle no-undo.

.MESSAGE 'EVENTO' p-ind-event SKIP
        'OBJETO' p-ind-object SKIP
        'FRAME' p-wgh-frame SKIP
        'TABELA' p-cod-table SKIP
        'ROWID' STRING(p-row-table) SKIP VIEW-AS ALERT-BOX.
             
        
.message p-ind-event VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.


IF p-ind-event  =   'before-INITIALIZE' and
   p-ind-object =   'viewer'            THEN DO:
    
                            //cod-sit-aval
    RUN utils/findWidget.p (INPUT  'RECT-5',                                                               
                            INPUT  'rectangle',       
                            INPUT  p-wgh-frame,
                            output h-RECT-5).
                            
   IF VALID-HANDLE (h-RECT-5) THEN
   DO:
          
          h-RECT-5:HEIGHT = h-RECT-5:HEIGHT + 1.30.
          
   END.
   
    
end.



IF p-ind-event = "BEFORE-INITIALIZE" 
    AND p-ind-object = "VIEWER" THEN DO:
                            //cod-sit-aval
    RUN utils/findWidget.p (INPUT  'l-aloca-saldo-erp',                                                               
                            INPUT  'toggle-box',       
                            INPUT  p-wgh-frame,
                            output h-l-aloca-saldo-erp).   
    
    
end.


IF p-ind-event = "DISPLAY" 
   AND p-ind-object = "VIEWER" THEN DO:
   
   IF VALID-HANDLE(h-l-aloca-saldo-erp) THEN DO:
   
   
        .MESSAGE "entrou"
            VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.

        create text h-text-centro-centro-wms
        assign name = "h-text-centro-centro-wms"
             FRAME     = h-l-aloca-saldo-erp:FRAME
             ROW       = h-l-aloca-saldo-erp:row + 1.50
             COL       = h-l-aloca-saldo-erp:COL 
             VISIBLE   = YES
             FORMAT         = "X(15)"
             screen-value = "Centro Estoque".                    
     
   END. 
END.

IF p-ind-event = "ADD" 
   AND p-ind-object = "VIEWER" THEN DO:
   
   IF VALID-HANDLE(h-l-aloca-saldo-erp) THEN DO:
   
   
        .MESSAGE "entrou"
            VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.

        create text h-text-centro-centro-wms
        assign name = "h-text-centro-centro-wms"
             FRAME     = h-l-aloca-saldo-erp:FRAME
             ROW       = h-l-aloca-saldo-erp:row + 1.50
             COL       = h-l-aloca-saldo-erp:COL 
             VISIBLE   = YES
             FORMAT         = "X(15)"
             screen-value = "Centro Estoque".                    
     
   END. 
END.




IF p-ind-event = "BEFORE-DISPLAY" 
   AND p-ind-object = "VIEWER" THEN DO:
   
   IF VALID-HANDLE(h-l-aloca-saldo-erp) THEN DO:
   
   
        .MESSAGE "entrou"
            VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.                
     
     
        create fill-in h-centro-centro-wms
         ASSIGN NAME      = "h-centro-centro-wms"
                FRAME     = h-l-aloca-saldo-erp:FRAME
                ROW       = h-l-aloca-saldo-erp:row + 1.50
                COL       = h-l-aloca-saldo-erp:COL + 11
                VISIBLE   = YES
                SENSITIVE = no
                HEIGHT-CHARS   = 0.70
                WIDTH-CHARS    = 12
                FORMAT         = "X(9)" .
   END. 
END.





IF  p-ind-event = "ENABLE" 
and p-ind-object = "VIEWER" 
THEN DO:


   IF valid-handle(h-text-centro-centro-wms) THEN 
      ASSIGN   h-centro-centro-wms:SENSITIVE = yes.
     
end.
     
IF  p-ind-event = "DISABLE" 
 and p-ind-object = "VIEWER" 
 THEN DO:

     IF valid-handle(h-text-centro-centro-wms) THEN 
        ASSIGN h-centro-centro-wms:SENSITIVE = no.

end.


IF  p-ind-event = "DISPLAY" 
 and p-ind-object = "VIEWER"
 THEN DO:
 
     .message "entrou if" VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
     
     IF valid-handle(h-centro-centro-wms) then do: 
     
         find first deposito    
            where   rowid(deposito) = p-row-table no-error.
            
         if avail deposito then do:
         
               .message "entrou assign 1" VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
               
               assign h-centro-centro-wms:SCREEN-VALUE = SUBSTRING(deposito.char-1, 120,10).

                  
            
         end.
         else do: 
         
            assign h-centro-centro-wms:SCREEN-VALUE = "".
         
         end.
     
     end.
       

end.
        
        
      
IF  p-ind-event = "ASSIGN" 
 and p-ind-object = "VIEWER" 
 THEN DO:

     IF valid-handle(h-centro-centro-wms) then do: 
     
         find first deposito    
            where   rowid(deposito) = p-row-table no-error.
            
         if avail deposito then do:
         
               .message "entrou assign 1" VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.

               assign OVERLAY(deposito.char-1, 120,10) = h-centro-centro-wms:SCREEN-VALUE.                   
                  

         end.    
     end.
end.  
