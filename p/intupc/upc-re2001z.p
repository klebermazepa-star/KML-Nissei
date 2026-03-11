{include/i-prgvrs.i UPC-RE2001Z 2.12.00.001 } /*** 120001 ***/

def input param p-ind-event                     as char             no-undo.
def input param p-ind-object                    as char             no-undo.
def input param p-wgh-object                    as handle           no-undo.
def input param p-wgh-frame                     as widget-handle    no-undo.
def input param p-cod-table                     as char             no-undo.
def input param p-row-table                     as rowid            no-undo.

/* Valida versao EMS. */
{cdp/cdcfgmat.i}

def new global shared var wh-object             as widget-handle    no-undo.

def new global shared var wh-fi-cod-emitente    as widget-handle    no-undo.
def new global shared var wh-fi-nat-operacao    as widget-handle    no-undo.
def new global shared var wh-fi-nro-docto       as widget-handle    no-undo.
def new global shared var wh-fi-serie-docto     as widget-handle    no-undo.
def new global shared var wh-fi-tipo-nota       as widget-handle    no-undo.

DEF NEW GLOBAL SHARED VAR wh-row-ant            AS ROWID            NO-UNDO.
DEF NEW GLOBAL SHARED VAR wh-log-natureza       AS LOGICAL          NO-UNDO.
def new global shared var h-frame               as widget-handle    no-undo.


def var c-nat-operacao                          as char             no-undo.
def var c-serie-docto                           as char             no-undo.
def var c-nro-docto                             as char             no-undo.
def var i-cod-emitente                          as int              no-undo.
def var c-tipo-nota-re2001z                     as char             no-undo.

def buffer bf-doc-orig-nfe for doc-orig-nfe.

if p-ind-event = "AFTER-INITIALIZE" 
then do:
    
    ASSIGN wh-row-ant       = ?   
           wh-log-natureza  = NO.

    assign wh-object = p-wgh-frame:first-child.
    do  while valid-handle(wh-object):

        if  wh-object:type = "field-group" then
            assign wh-object = wh-object:first-child.
        else do:
            assign wh-object = wh-object:next-sibling.
           
            if valid-handle(wh-object) then do:
                case wh-object:name:
                    
                    WHEN "cb-tipo-nota":U THEN
                        ASSIGN wh-fi-tipo-nota = wh-object.

                    when "nat-operacao" then
                        assign wh-fi-nat-operacao = wh-object.
                    
                    when "cod-emitente" then
                        assign wh-fi-cod-emitente = wh-object.
                    
                    when "serie-docto" then
                        assign wh-fi-serie-docto = wh-object.
                    
                    when "nro-docto" then
                        assign wh-fi-nro-docto = wh-object.
                  
                    otherwise
                        next.
                end case.
           end.
        end.
    end.   
    
    if valid-handle(wh-fi-nat-operacao) 
    then do:   
        ON ENTRY OF wh-fi-nat-operacao PERSISTENT run intupc/upc-re2001z-a.p(input "Entry").
    end.

end.
  
return "OK":U.
