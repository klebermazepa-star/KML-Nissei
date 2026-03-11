/**********************************************************************
**
**  Programa: upc-cd0904.p - UPC para o programa CD0704 - Diferenciar clientes Merco
**              
**  Objetivo: Criar campo clientes Merco/Nissei
**
**********************************************************************/
 
DEFINE INPUT PARAMETER p-ind-event  AS CHARACTER.
DEFINE INPUT PARAMETER p-ind-object AS CHARACTER.
DEFINE INPUT PARAMETER p-wgh-object AS HANDLE.
DEFINE INPUT PARAMETER p-wgh-frame  AS WIDGET-HANDLE.
DEFINE INPUT PARAMETER p-cod-table  AS CHARACTER.
DEFINE INPUT PARAMETER p-row-table  AS ROWID.


DEFINE NEW GLOBAL SHARED VAR wh-grupo-cd0704 AS WIDGET-HANDLE NO-UNDO.
DEFINE NEW GLOBAL SHARED VAR wh-empresa-cliente-cd0704 AS WIDGET-HANDLE NO-UNDO.
DEFINE NEW GLOBAL SHARED VAR wh-txt-empresa-cliente-cd0704 AS WIDGET-HANDLE NO-UNDO.

DEFINE NEW GLOBAL SHARED VAR wh-txt-shelflife-cd0704    AS WIDGET-HANDLE NO-UNDO.
DEFINE NEW GLOBAL SHARED VAR wh-shelflife-cd0704        AS WIDGET-HANDLE NO-UNDO.

DEFINE VARIABLE c-objeto AS CHARACTER   NO-UNDO.

  /*
MESSAGE p-ind-event              "p-ind-event  " skip
         p-ind-object             "p-ind-object " skip
         p-wgh-object:FILE-NAME   "p-wgh-object " SKIP
         p-wgh-frame:NAME         "p-wgh-frame  " skip
         p-cod-table              "p-cod-table  " skip
        string(p-row-table)      "p-row-table  " skip
VIEW-AS ALERT-BOX INFO BUTTONS OK.  */

IF  VALID-HANDLE(p-wgh-object)
THEN
   // assign c-objeto   = entry(num-entries(p-wgh-object:private-data, "~/"), p-wgh-object:private-data, "~/").

if  p-ind-event  = "INITIALIZE" and
    p-ind-object = "VIEWER"    
then do:


    RUN utils/findWidget.p (INPUT  'cod-gr-cli',   
                            INPUT  'fill-in',       
                            INPUT  p-wgh-frame,    
                            OUTPUT wh-grupo-cd0704).
                            
                            
    if valid-handle (wh-grupo-cd0704) then DO:

        create text wh-txt-empresa-cliente-cd0704
        ASSIGN name         = "wh-txt-empresa-cliente-cd0704"
               frame        = wh-grupo-cd0704:frame
               row          = wh-grupo-cd0704:ROW - 0.8
               format       = "x(9)"
               col          = wh-grupo-cd0704:col + wh-grupo-cd0704:WIDTH + 38
               width        = 7
               screen-value = 'Empresa:'
               visible      = yes.
        
        create combo-box wh-empresa-cliente-cd0704
        assign
            name      = 'wh-empresa-cliente-cd0704':u
            frame     = wh-grupo-cd0704:frame
            width     = 6
            /*height    = .88*/
            column    = wh-txt-empresa-cliente-cd0704:col + wh-txt-empresa-cliente-cd0704:WIDTH 
            row       = wh-txt-empresa-cliente-cd0704:ROW - 0.2 
            font      = wh-grupo-cd0704:font
            fgcolor   = wh-grupo-cd0704:fgcolor
            format    = "X(6)"
            help      = 'Empresa do cliente'
            tooltip   = 'Empresa do cliente'
            visible   = true
            sensitive = NO
            inner-lines = 20
            auto-completion = yes.
            
            // wh-txt-shelflife-cd0704
            
        wh-empresa-cliente-cd0704:add-last("1").
        wh-empresa-cliente-cd0704:add-last("10").
       // wh-empresa-cliente-cd0704:screen-value = " ".

        wh-empresa-cliente-cd0704:tab-stop = yes.            
                    
      //  wh-log-operacional-cd0904:tab-stop = yes.
      
            
        .MESSAGE "entrou"
            VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
                
        create text wh-txt-shelflife-cd0704
        ASSIGN name         = "wh-txt-shelflife-cd0704"
               frame        =  wh-grupo-cd0704:frame
               row          = wh-grupo-cd0704:ROW + 0.2
               format       = 'x(10)'
               col          = wh-grupo-cd0704:col + wh-grupo-cd0704:WIDTH + 33.7
               width        = 7
               screen-value = 'ShelfLife:'
               visible      = yes.
        
        create FILL-IN wh-shelflife-cd0704
        assign
            name      = 'wh-shelflife-cd0704'
            frame     = wh-grupo-cd0704:frame
            width     = 12
            /*height    = .88*/
            column    = wh-txt-shelflife-cd0704:col + wh-txt-shelflife-cd0704:WIDTH 
            row       = wh-grupo-cd0704:ROW 
            font      = wh-grupo-cd0704:font
            fgcolor   = wh-grupo-cd0704:fgcolor
            format    = "X(4)"
            help      = "ShelfLife"
            tooltip   = "ShelfLife"
            visible   = true
            sensitive = NO.                
    
    END.

end.

if  p-ind-event  = "DISPLAY" and
    p-ind-object = "VIEWER" 
then do:
    
    
    if valid-handle(wh-empresa-cliente-cd0704) then do:
        
       
        FIND FIRST ems2mult.emitente NO-LOCK
            WHERE ROWID(emitente) = p-row-table NO-ERROR.
            
        IF AVAIL emitente THEN
        DO:
       
            FIND first ext-emitente-nissei no-lock 
                    where ext-emitente-nissei.cod-emitente = emitente.cod-emitente NO-ERROR.
                    
            IF AVAIL ext-emitente-nissei THEN
            DO:
                assign wh-empresa-cliente-cd0704:screen-value = ext-emitente-nissei.cod-empresa
                       wh-shelflife-cd0704:screen-value = string(ext-emitente-nissei.shelflife).
            END.
            ELSE DO:
                ASSIGN wh-empresa-cliente-cd0704:screen-value = "1"
                       wh-shelflife-cd0704:screen-value =   "0".
            END.
           
       END.
       
    end.
    
end.

if  p-ind-event  = "AFTER-ENABLE" and
    p-ind-object = "VIEWER"       
then do:

         
    if valid-handle(wh-empresa-cliente-cd0704) then    
        assign wh-empresa-cliente-cd0704:sensitive = yes.
        
         
    if valid-handle(wh-shelflife-cd0704) then    
        assign wh-shelflife-cd0704:sensitive = yes.        
        
       
end.

if  p-ind-event  = "AFTER-DISABLE" and
    p-ind-object = "VIEWER"       
then do:

    if valid-handle(wh-empresa-cliente-cd0704) then       
        assign wh-empresa-cliente-cd0704:sensitive = no.
     
         
    if valid-handle(wh-shelflife-cd0704) then    
        assign wh-shelflife-cd0704:sensitive = NO.       
        
end.

if  p-ind-event  = "ASSIGN" and
    p-ind-object = "VIEWER" 
then do:
              
    FIND FIRST ems2mult.emitente NO-LOCK
        WHERE ROWID(emitente) = p-row-table NO-ERROR.
        
    IF AVAIL emitente THEN
    DO:
   
        FIND first ext-emitente-nissei EXCLUSIVE-LOCK 
                where ext-emitente-nissei.cod-emitente = emitente.cod-emitente NO-ERROR.
                
        IF NOT AVAIL ext-emitente-nissei THEN
        DO:
            CREATE ext-emitente-nissei .
            ASSIGN ext-emitente-nissei.cod-emitente = emitente.cod-emitente.            
        
        END.
        ASSIGN ext-emitente-nissei.cod-empresa  = wh-empresa-cliente-cd0704:SCREEN-VALUE
               ext-emitente-nissei.shelflife    = int(wh-shelflife-cd0704:SCREEN-VALUE).
    
        RELEASE ext-emitente-nissei.
        
    END.   
    
end.

if  p-ind-event = "DESTROY"
then do:


    if valid-handle (wh-txt-empresa-cliente-cd0704) then 
        delete widget wh-txt-empresa-cliente-cd0704.
    if valid-handle (wh-empresa-cliente-cd0704) then 
        delete widget wh-empresa-cliente-cd0704.
    if valid-handle (wh-txt-shelflife-cd0704) then 
        delete widget wh-txt-shelflife-cd0704.
    if valid-handle (wh-shelflife-cd0704) then 
        delete widget wh-shelflife-cd0704.     
        
                
end.


RETURN "OK".
