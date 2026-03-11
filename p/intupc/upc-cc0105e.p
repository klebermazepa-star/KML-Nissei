/********************************************************************************
** Programa: upc-cc0105e.p
**     Data: 09/2016
**    Autor: ResultPro  
**    
** Objetivo: Gravar o c¢digo alternativo do item no campo item-fornec-umd.cod-livre-1
** 
*******************************************************************************/
{include/i-prgvrs.i upc-cc0105e 2.12.00.001} /*** 010002 ***/

/************ definicao de parametros ***********************/
def input param p-ind-event           as char          no-undo.
def input param p-ind-object          as char          no-undo.
def input param p-wgh-object          as handle        no-undo.
def input param p-wgh-frame           as widget-handle no-undo.
def input param p-cod-table           as char          no-undo.
def input param p-row-table           as rowid         no-undo.

def new global shared var wh-uni-med-for-cc0105e   as handle  no-undo.
def new global shared var wh-log-ativo-cc0105e     as handle  no-undo.
def new global shared var l-alteracao-cc0105e      as logical no-undo.
def new global shared var wh-it-codigo-alternativo as handle  no-undo. 
def new global shared var wh-it-codigo-alter-label as handle  no-undo.
                                          
DEF VAR wh-fill AS HANDLE. 
      
if p-ind-object = "CONTAINER"
THEN DO:
   if p-ind-event  = "BEFORE-INITIALIZE" then 
      assign l-alteracao-cc0105e = no.
   
   if p-ind-event  = "AFTER-ENABLE" 
   then do: 
      assign l-alteracao-cc0105e = yes.     
      
   end.  
     
end.  
              
if p-ind-event  = "AFTER-INITIALIZE" AND 
   p-ind-object = "CONTAINER"
THEN DO:
   
   ASSIGN wh-fill  = p-wgh-frame:FIRST-CHILD
          wh-fill  = wh-fill:FIRST-CHILD.

   DO WHILE VALID-HANDLE(wh-fill):
          
        if wh-fill:NAME = "unid-med-for" THEN 
           assign wh-uni-med-for-cc0105e = wh-fill.
          
        IF wh-fill:NAME = "log-ativo" THEN 
           ASSIGN wh-log-ativo-cc0105e = wh-fill.

        ASSIGN wh-fill = wh-fill:NEXT-SIBLING.
   END.   
  
   if valid-handle(wh-log-ativo-cc0105e) 
   then do:
       
       assign wh-uni-med-for-cc0105e:label = "Seq. Unidade".
              
       create text wh-it-codigo-alter-label
       assign frame              = p-wgh-frame
              format             = "x(21)"
              width              = 21
              height             = 0.88
              screen-value       = "C¢digo Alternativo :"
              row                =  wh-log-ativo-cc0105e:row + 1
              col                =  wh-log-ativo-cc0105e:col - 14
              visible            = yes
              sensitive          = yes.

       create fill-in wh-it-codigo-alternativo
       assign frame              = p-wgh-frame
              Side-label-handle  = wh-it-codigo-alter-label
              Data-type          = "CHARACTER"
              width              =  60
              format             = "x(60)"
              height             = 0.88
              name               = "item-fornec-umd.cod-livre-1" 
              row                = wh-log-ativo-cc0105e:ROW + 1
              col                = wh-log-ativo-cc0105e:COL
              visible            = yes
              sensitive          = yes.  
              
       wh-it-codigo-alternativo:MOVE-AFTER-TAB-ITEM(wh-log-ativo-cc0105e).       
              
       if l-alteracao-cc0105e = yes 
       then do:
             
          for first item-fornec-umd no-lock where
               rowid(item-fornec-umd) = p-row-table:
          end.
   
          if avail item-fornec-umd 
          then do:
             assign wh-it-codigo-alternativo:screen-value = item-fornec-umd.cod-livre-1.    
          end. 
              
       end. 
   
   end.       

END.

if p-ind-event  = "AFTER-ASSIGN" AND 
   p-ind-object = "CONTAINER"
THEN DO:
   
   /***** Campo C¢digo alternativo gravado no item-fornec-umd.cod-livre-1 ******/
   
   for first item-fornec-umd where
              rowid(item-fornec-umd) = p-row-table:
   end.
   
   if avail item-fornec-umd 
   then do:
      assign item-fornec-umd.cod-livre-1 = wh-it-codigo-alternativo:screen-value.                   
   end.
   
   release item-fornec-umd.
   
end.        
       
