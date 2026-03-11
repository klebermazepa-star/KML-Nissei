/**********************************************************************
**
**  Programa: upc-cd0904.p - UPC para o programa CD0904 - Unid Feder
**              
**  Objetivo: Criar campo estado operacional Nissei
**
**********************************************************************/
 
DEFINE INPUT PARAMETER p-ind-event  AS CHARACTER.
DEFINE INPUT PARAMETER p-ind-object AS CHARACTER.
DEFINE INPUT PARAMETER p-wgh-object AS HANDLE.
DEFINE INPUT PARAMETER p-wgh-frame  AS WIDGET-HANDLE.
DEFINE INPUT PARAMETER p-cod-table  AS CHARACTER.
DEFINE INPUT PARAMETER p-row-table  AS ROWID.


DEFINE NEW GLOBAL SHARED VAR wh-log-operacional-cd0904 AS WIDGET-HANDLE NO-UNDO.
DEFINE NEW GLOBAL SHARED VAR wh-txt-log-operacional-cd0904 AS WIDGET-HANDLE NO-UNDO.

DEFINE VARIABLE c-objeto AS CHARACTER   NO-UNDO.

IF  VALID-HANDLE(p-wgh-object)
THEN
    assign c-objeto   = entry(num-entries(p-wgh-object:private-data, "~/"), p-wgh-object:private-data, "~/").

if  p-ind-event  = "INITIALIZE" and
    p-ind-object = "VIEWER"     and 
    c-objeto     = "v03un007.w"
then do:

    create text wh-txt-log-operacional-cd0904
    ASSIGN name         = "wh-txt-log-operacional-cd0904"
           frame        = p-wgh-frame
           row          = 2.35
           format       = 'x(15)'
           col          = 49.5
           width        = 15
           screen-value = 'UF operacional'
           visible      = yes.
    
    create toggle-box wh-log-operacional-cd0904
    ASSIGN name      = "wh-log-operacional-cd0904"
           frame     = p-wgh-frame
           width     = 10
           height    = .88
           column    = 47
           row       = 2.2
           format    = "yes/no"
           visible   = true
           sensitive = no.


    wh-log-operacional-cd0904:tab-stop = yes.

end.

if  p-ind-event  = "DISPLAY" and
    p-ind-object = "VIEWER"  and 
    c-objeto     = "v03un007.w" /*AND
    VALID-HANDLE(wh-log-operacional-cd0904)*/
then do:
    if valid-handle(wh-log-operacional-cd0904) then do:
        assign wh-log-operacional-cd0904:screen-value = "no".
        for first unid-feder no-lock where 
            rowid(unid-feder) = p-row-table:
            for first int-ds-unid-feder no-lock where 
                int-ds-unid-feder.pais   = unid-feder.pais and
                int-ds-unid-feder.estado = unid-feder.estado:
                assign wh-log-operacional-cd0904:screen-value = string(int-ds-unid-feder.log-operacional).
            end.
        end.
    end.
end.

if  p-ind-event  = "AFTER-ENABLE" and
    p-ind-object = "VIEWER"       and 
    c-objeto     = "v03un007.w"
then do:
    if valid-handle(wh-log-operacional-cd0904) then    
        assign wh-log-operacional-cd0904:sensitive = yes.
end.

if  p-ind-event  = "AFTER-DISABLE" and
    p-ind-object = "VIEWER"        and 
    c-objeto     = "v03un007.w"
then do:
    if valid-handle(wh-log-operacional-cd0904) then       
        assign wh-log-operacional-cd0904:sensitive = no.
end.

if  p-ind-event  = "ASSIGN" and
    p-ind-object = "VIEWER" and
    c-objeto     = "v03un007.w"
then do:
    
    for first unid-feder no-lock 
        where rowid(unid-feder) = p-row-table:

        find int-ds-unid-feder exclusive-lock where  
            int-ds-unid-feder.pais   = unid-feder.pais and
            int-ds-unid-feder.estado = unid-feder.estado no-error.

        if  not avail int-ds-unid-feder
        then do:
            create int-ds-unid-feder.
            assign int-ds-unid-feder.pais   = unid-feder.pais 
                   int-ds-unid-feder.estado = unid-feder.estado.
        end.

        if valid-handle (wh-log-operacional-cd0904) then
            assign int-ds-unid-feder.log-operacional = wh-log-operacional-cd0904:input-value.

        release int-ds-unid-feder.
    end.
end.

if  p-ind-event = "DESTROY"
then do:
    if valid-handle (wh-log-operacional-cd0904) then 
        delete widget wh-log-operacional-cd0904.
    if valid-handle (wh-txt-log-operacional-cd0904) then 
        delete widget wh-txt-log-operacional-cd0904.
end.

if valid-handle (wh-log-operacional-cd0904) then wh-log-operacional-cd0904:move-to-top().
if valid-handle (wh-txt-log-operacional-cd0904) then wh-txt-log-operacional-cd0904:move-to-top().

RETURN "OK".

