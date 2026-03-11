/******************************************************************************************
**  Programa: upc-re2001.p
**  Versao..:  
**  Data....: Bot∆o integraá∆o XML 
******************************************************************************************/
DEF INPUT PARAM p-ind-event      AS   CHAR              NO-UNDO.
DEF INPUT PARAM p-ind-object     AS   CHAR              NO-UNDO.
DEF INPUT PARAM p-wgh-object     AS   HANDLE            NO-UNDO.
DEF INPUT PARAM p-wgh-frame      AS   WIDGET-HANDLE     NO-UNDO.
DEF INPUT PARAM p-cod-table      AS   CHAR              NO-UNDO.
DEF INPUT PARAM p-row-table      AS   ROWID             NO-UNDO.

DEFINE NEW GLOBAL SHARED VAR wh-frame                 AS WIDGET-HANDLE NO-UNDO.
DEFINE NEW GLOBAL SHARED VAR wh-object-re2001         AS WIDGET-HANDLE NO-UNDO.
DEFINE NEW GLOBAL SHARED VAR wh-cod-emitente-re2001   AS WIDGET-HANDLE no-undo.
DEFINE NEW GLOBAL SHARED VAR wh-serie-re2001          AS WIDGET-HANDLE no-undo.
DEFINE NEW GLOBAL SHARED VAR wh-nro-docto-re2001      AS WIDGET-HANDLE no-undo.
DEFINE NEW GLOBAL SHARED VAR wh-btconf-orig-re2001    AS WIDGET-HANDLE no-undo.
DEFINE NEW GLOBAL SHARED VAR wh-bt-int-xml-re2001     AS WIDGET-HANDLE no-undo.
DEFINE NEW GLOBAL SHARED VAR wh-query-re2001          AS WIDGET-HANDLE NO-UNDO.
                                           
define new global shared var adm-broker-hdl as handle no-undo.

define var c-objects      as character no-undo.
define var h-object       as handle    no-undo.
define var i-objects      as integer   no-undo.

{utp/ut-glob.i}

/* MESSAGE p-ind-event              "p-ind-event  " skip 
         p-ind-object             "p-ind-object " skip
         p-wgh-object:FILE-NAME   "p-wgh-object " skip
         p-wgh-frame:NAME         "p-wgh-frame  " skip
         p-cod-table              "p-cod-table  " skip
        string(p-row-table)      "p-row-table  " skip
 VIEW-AS ALERT-BOX INFO BUTTONS OK.
 */

IF (p-ind-event  = "before-initialize" AND  
    p-ind-object = "container")  OR 
   (p-ind-event  = "initialize" AND  
    p-ind-object = "viewer")

THEN DO:          
    
    ASSIGN wh-frame  = p-wgh-frame:FIRST-CHILD
           wh-frame  = wh-frame:FIRST-CHILD. 
 
    DO WHILE VALID-HANDLE(wh-frame):
       
        IF wh-frame:NAME = "bt-atualizar" THEN
           ASSIGN wh-btconf-orig-re2001 = wh-frame.
        
        IF wh-frame:NAME = "cod-emitente" THEN
          ASSIGN wh-cod-emitente-re2001 = wh-frame.

        IF wh-frame:NAME = "serie-docto" THEN
          ASSIGN wh-serie-re2001 = wh-frame.

        IF wh-frame:NAME = "nro-docto" THEN
         ASSIGN wh-nro-docto-re2001 = wh-frame.
        
        ASSIGN wh-frame = wh-frame:NEXT-SIBLING.

    END.
    
END.
 
IF p-ind-event  = "initialize" AND  
   p-ind-object = "container" 
THEN DO:  

  IF VALID-HANDLE (wh-btconf-orig-re2001) THEN DO:  
        CREATE BUTTON wh-bt-int-xml-re2001                                       
        ASSIGN FRAME     = wh-btconf-orig-re2001:FRAME                        
               LABEL     = wh-btconf-orig-re2001:LABEL                            
               FONT      = 4
               WIDTH     = 4.5 
               HEIGHT    = 1.20
               ROW       = 1.10                              
               COL       = wh-btconf-orig-re2001:COL - 6
               FGCOLOR   = ?
               BGCOLOR   = ?
               CONVERT-3D-COLORS = YES
               TOOLTIP   = "Integraá∆o XML"
               VISIBLE   = wh-btconf-orig-re2001:VISIBLE                                        
               SENSITIVE = wh-btconf-orig-re2001:SENSITIVE
               TRIGGERS:                                              
                   ON CHOOSE PERSISTENT RUN intprg\upc-re2001-a.p.
               END TRIGGERS.
              
               wh-bt-int-xml-re2001:LOAD-IMAGE-UP("image/toolbar/im-carga").
               wh-bt-int-xml-re2001:LOAD-IMAGE-INSENSITIVE("image/toolbar/im-carga").
               wh-bt-int-xml-re2001:MOVE-TO-TOP().
    END.   
   
   ASSIGN wh-object-re2001 = p-wgh-object. 


   RUN get-link-handle IN adm-broker-hdl (INPUT p-wgh-object, 
                                          INPUT "CONTAINER-TARGET":U, 
                                          OUTPUT c-objects).
        
   do i-objects = 1 to num-entries(c-objects):
      assign h-object = widget-handle(entry(i-objects, c-objects)).
      
      if index(h-object:private-data, "qry") <> 0 
      then do:

         ASSIGN wh-query-re2001 = h-object.
         
      end. 
     
   end.                      

   
END. 



