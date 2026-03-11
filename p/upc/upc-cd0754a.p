/******************************************************************************
* Programa .....: upc-cd0754a.p                                               *
* Data .........: 03 de outubro de 2022                                       *
* Empresa ......: Jeferson Consulting                                         *
* Cliente ......: Farm†cias Nissei                                            *
* Programador ..: Jeferson Souza                                              *
* Objetivo .....: Parametrizar Classificaá‰es Fiscais para FCP                *
* Revis‰es .....: 001 - 03/10/2022 - JS - Criaá∆o                             *  
******************************************************************************/

// Funá‰es                                                                                 
function fc-busca-handle returns widget-handle (p-fc-wh-objeto as widget-handle,
                                                l-mensagem     as logical      ,
                                                l-tooltip      as logical      ,
                                                c-campo        as character    ,
                                                c-tipo         as character    ,
                                                c-pagina       as character    )  forward.

// Parametros
define input parameter p-ind-event           as char            no-undo.
define input parameter p-ind-object          as char            no-undo.
define input parameter p-wgh-object          as handle          no-undo.
define input parameter p-wgh-frame           as widget-handle   no-undo.
define input parameter p-cod-table           as char            no-undo.
define input parameter p-row-table           as rowid           no-undo.

// Vari†veis Locais
define variable c-objeto                        as character        no-undo.
define variable h-handle-aux                    as handle           no-undo.
define variable wh_lbl-estado-fcp-tr-cd0754a    as handle           no-undo.
define variable wh_lbl-aliq-fcp-tr-cd0754a      as handle           no-undo.


// Vari†veis Globais
define new global shared variable wh_tg-fcp-tr-cd0754a             as handle           no-undo.
define new global shared variable wh_aliq-fcp-tr-cd0754a           as handle           no-undo.
define new global shared variable wh_estado-fcp-tr-cd0754a         as handle           no-undo.
define new global shared variable wh_no-estado-fcp-tr-cd0754a      as handle           no-undo.
define new global shared variable wh_upc-cd0754a                   as handle           no-undo.


if valid-handle(p-wgh-object) 
then assign c-objeto = entry(num-entries(p-wgh-object:private-data, "~/"), p-wgh-object:private-data, "~/").

/*message 'p-ind-event ' p-ind-event  skip
        'p-ind-object' p-ind-object skip
        'p-wgh-object' string(p-wgh-object) skip
        'p-wgh-frame ' string(p-wgh-frame)  skip
        'p-cod-table ' p-cod-table  skip
        'c-objeto' c-objeto skip
        'p-row-table' string(p-row-table)
        view-as alert-box info buttons ok.*/

if  p-ind-event  = "after-initialize" 
and p-ind-object = "container"
then do:
    // aumenta a tela para acomodar novos campos 
    assign p-wgh-frame:parent:height = p-wgh-frame:parent:height + 2.5
           p-wgh-frame:height        = p-wgh-frame:height + 2.5.

    assign h-handle-aux = fc-busca-handle (p-wgh-frame,   /* objeto */
                                           no,            /* visualiza mensagem  */
                                           no,            /* alterar tooltip     */
                                           'btok',        /* objeto ser buscado  */ /* obrigatΩrio */
                                           'button',      /* tipo do objeto      */ /* obrigatΩrio */
                                           '').
    if valid-handle(h-handle-aux) 
    then run pi-reposiciona-objeto (input h-handle-aux).

    assign h-handle-aux = fc-busca-handle (p-wgh-frame,   /* objeto */
                                           no,            /* visualiza mensagem  */
                                           no,            /* alterar tooltip     */
                                           'btsave',      /* objeto ser buscado  */ /* obrigatΩrio */
                                           'button',      /* tipo do objeto      */ /* obrigatΩrio */
                                           '').
    if valid-handle(h-handle-aux) 
    then run pi-reposiciona-objeto (input h-handle-aux).

    assign h-handle-aux = fc-busca-handle (p-wgh-frame,   /* objeto */
                                           no,            /* visualiza mensagem  */
                                           no,            /* alterar tooltip     */
                                           'btcancel',    /* objeto ser buscado  */ /* obrigatΩrio */
                                           'button',      /* tipo do objeto      */ /* obrigatΩrio */
                                           '').
    if valid-handle(h-handle-aux) 
    then run pi-reposiciona-objeto (input h-handle-aux).

    assign h-handle-aux = fc-busca-handle (p-wgh-frame,   /* objeto */
                                           no,            /* visualiza mensagem  */
                                           no,            /* alterar tooltip     */
                                           'bthelp',      /* objeto ser buscado  */ /* obrigatΩrio */
                                           'button',      /* tipo do objeto      */ /* obrigatΩrio */
                                           '').
    if valid-handle(h-handle-aux) 
    then run pi-reposiciona-objeto (input h-handle-aux).

    assign h-handle-aux = fc-busca-handle (p-wgh-frame,   /* objeto */
                                           no,            /* visualiza mensagem  */
                                           no,            /* alterar tooltip     */
                                           'rttoolbar',   /* objeto ser buscado  */ /* obrigatΩrio */
                                           'rectangle',   /* tipo do objeto      */ /* obrigatΩrio */
                                           '').
    if valid-handle(h-handle-aux) 
    then run pi-reposiciona-objeto (input h-handle-aux).

    assign h-handle-aux = fc-busca-handle (p-wgh-frame,   /* objeto */
                                           no,            /* visualiza mensagem  */
                                           no,            /* alterar tooltip     */
                                           'rtfields',    /* objeto ser buscado  */ /* obrigatΩrio */
                                           'rectangle',   /* tipo do objeto      */ /* obrigatΩrio */
                                           '').
    if valid-handle(h-handle-aux) 
    then do:
        assign h-handle-aux:column = 2
               h-handle-aux:width  = 90
               h-handle-aux:height = 3.5.
    end.
    
    // cria campo na tela....
    run upc/upc-cd0754a.p persistent set wh_upc-cd0754a (input '':U        ,
                                                         input '':U        ,
                                                         input p-wgh-object,
                                                         input p-wgh-frame ,
                                                         input '':U        ,
                                                         input p-row-table).
    create toggle-box wh_tg-fcp-tr-cd0754a
    assign frame       = h-handle-aux:frame
           width       = 12
           height      = 0.88
           row         = 7.25
           column      = 26
           label       = "FCP TaxRules"
           sensitive   = yes
           visible     = yes.
    
    create text wh_lbl-aliq-fcp-tr-cd0754a
    assign frame        = h-handle-aux:frame
           format       = "x(16)"
           height       = 0.88
           width        = 13
           screen-value = "Al°quota FCP:"
           row          = 7.25
           col          = 47
           visible      = yes.
    
    create fill-in wh_aliq-fcp-tr-cd0754a
    assign frame             = h-handle-aux:frame
           name              = "aliquota-fcp-taxrules"
           data-type         = "decimal"
           format            = ">>9.99"
           width             = 7
           height            = 0.88
           row               = 7.25
           col               = 57
           visible           = yes  
           sensitive         = yes.

    create text wh_lbl-estado-fcp-tr-cd0754a
    assign frame        = h-handle-aux:frame
           format       = "x(16)"
           height       = 0.88
           width        = 13
           screen-value = "Estado FCP:"
           row          = 8.25
           col          = 17
           visible      = yes.
       
    create fill-in wh_estado-fcp-tr-cd0754a
    assign frame             = h-handle-aux:frame
           name              = "estado-fcp-taxrules"
           data-type         = "character"
           format            = "x(04)"
           width             = 5
           height            = 0.88
           row               = 8.25
           col               = 26
           visible           = yes  
           sensitive         = yes
           triggers:
               on leave persistent run pi-leave-etado in wh_upc-cd0754a. 
           end triggers.

    create fill-in wh_no-estado-fcp-tr-cd0754a
    assign frame             = h-handle-aux:frame
           name              = "estado-fcp-taxrules"
           data-type         = "character"
           format            = "x(20)"
           width             = 32.7
           height            = 0.88
           row               = 8.25
           col               = 31.3
           visible           = yes  
           sensitive         = no.
    
    find first ct-clas-fisc
         where rowid(ct-clas-fisc) = p-row-table
               no-lock no-error.

    if avail ct-clas-fisc 
    then do:
        find first es-ct-clas-fisc
             where es-ct-clas-fisc.cod-clas-fisc = ct-clas-fisc.cod-clas-fisc
               and es-ct-clas-fisc.idi-tip-clas  = ct-clas-fisc.idi-tip-clas
                   exclusive-lock no-error.

        if avail es-ct-clas-fisc 
        then assign wh_tg-fcp-tr-cd0754a:checked          = es-ct-clas-fisc.lg-fcp       
                    wh_aliq-fcp-tr-cd0754a:screen-value   = string(es-ct-clas-fisc.aliquota-fcp)
                    wh_estado-fcp-tr-cd0754a:screen-value = es-ct-clas-fisc.estado.

        apply 'leave' to wh_estado-fcp-tr-cd0754a.
    end.
end.

if  p-ind-event  = "before-assign" 
and p-ind-object = "container"
then do:
    if wh_estado-fcp-tr-cd0754a:screen-value <> ""
    then do:
        find first param-global
                   no-lock no-error.
    
        if avail param-global 
        then do:
            find first ems2mult.empresa
                 where empresa.ep-codigo = param-global.empresa-prin
                       no-lock no-error.
    
            find first unid-feder
                 where unid-feder.pais   = empresa.pais
                   and unid-feder.estado = wh_estado-fcp-tr-cd0754a:screen-value
                       no-lock no-error.
    
            if not avail unid-feder 
            then do:
                run utp/ut-msgs.p (input "show", input 17567, input "Estado n∆o cadastrado").
                return error.
            end.
        end.
    end.
end.

if  p-ind-event  = "after-assign" 
and p-ind-object = "container"
then do:
    find first ct-clas-fisc
         where rowid(ct-clas-fisc) = p-row-table
               no-lock no-error.

    if avail ct-clas-fisc 
    then do:
        find first es-ct-clas-fisc
             where es-ct-clas-fisc.cod-clas-fisc = ct-clas-fisc.cod-clas-fisc
               and es-ct-clas-fisc.idi-tip-clas  = ct-clas-fisc.idi-tip-clas
                   exclusive-lock no-error.

        if not avail es-ct-clas-fisc 
        then do:
            create es-ct-clas-fisc.
            assign es-ct-clas-fisc.cod-clas-fisc = ct-clas-fisc.cod-clas-fisc
                   es-ct-clas-fisc.idi-tip-clas  = ct-clas-fisc.idi-tip-clas.
        end.

        if  valid-handle(wh_tg-fcp-tr-cd0754a)
        and valid-handle(wh_aliq-fcp-tr-cd0754a)
        and valid-handle(wh_estado-fcp-tr-cd0754a)
        then do:
            assign es-ct-clas-fisc.lg-fcp       = wh_tg-fcp-tr-cd0754a:checked
                   es-ct-clas-fisc.aliquota-fcp = dec(wh_aliq-fcp-tr-cd0754a:screen-value)
                   es-ct-clas-fisc.estado       = wh_estado-fcp-tr-cd0754a:screen-value.

            if not es-ct-clas-fisc.lg-fcp 
            then assign es-ct-clas-fisc.aliquota-fcp = 0
                        es-ct-clas-fisc.estado       = "".

        end.

        release es-ct-clas-fisc.
    end.
end.


if  p-ind-event  = "after-destroy-interface" 
and p-ind-object = "container"
then do:
    assign wh_tg-fcp-tr-cd0754a        = ?
           wh_aliq-fcp-tr-cd0754a      = ?
           wh_estado-fcp-tr-cd0754a    = ?
           wh_no-estado-fcp-tr-cd0754a = ?.

    if valid-handle(wh_upc-cd0754a)
    then delete procedure wh_upc-cd0754a.
end.

return "OK".

// Procedures
procedure pi-reposiciona-objeto:

    def input parameter p-handle            as handle           no-undo.

    assign p-handle:row = p-handle:row + 2.5.

end.

procedure pi-leave-etado:

    if wh_estado-fcp-tr-cd0754a:screen-value = "" 
    then assign wh_no-estado-fcp-tr-cd0754a:screen-value = "".
    else do:
        find first param-global
                   no-lock no-error.
    
        if avail param-global 
        then do:
            find first ems2mult.empresa
                 where empresa.ep-codigo = param-global.empresa-prin
                       no-lock no-error.
    
            find first unid-feder
                 where unid-feder.pais   = empresa.pais
                   and unid-feder.estado = wh_estado-fcp-tr-cd0754a:screen-value
                       no-lock no-error.
    
            if avail unid-feder 
            then assign wh_no-estado-fcp-tr-cd0754a:screen-value = unid-feder.no-estado.
        end.
    end.

end.

// Functions
function fc-busca-handle returns widget-handle (p-fc-wh-objeto as widget-handle,     /* objeto              */
                                                l-mensagem     as logical      ,     /* visualiza mensagem  */
                                                l-tooltip      as logical      ,     /* alterar tooltip     */
                                                c-campo        as character    ,     /* objeto ser buscado  */ /* obrigatΩrio               */
                                                c-tipo         as character    ,     /* tipo do objeto      */ /* obrigatΩrio               */
                                                c-pagina       as character    ):    /* p gina              */ /* opcional - pode passar '' */
 
    define variable wh-objeto-recursivo as widget-handle no-undo.
    define variable wh-objeto           as widget-handle no-undo.
    define variable wh-frame            as widget-handle no-undo.
    define variable wh-obj-aux          as widget-handle no-undo.
    define variable c-format            as character     no-undo.
    define variable c-data-type         as character     no-undo.
    define variable c-aux               as character     no-undo.
    define variable i-aux               as integer       no-undo.
 
    assign wh-objeto = p-fc-wh-objeto. /*:first-child no-error.*/
 
    do while valid-handle(wh-objeto):
 
       if  valid-handle(wh-objeto) then do:
           if  l-mensagem then do:
               if  (c-campo  = '' and c-tipo  = '' and c-pagina  = '') or
                   (c-campo <> '' and c-tipo <> '' and c-pagina <> '' and wh-objeto:name = c-campo and wh-objeto:type = c-tipo and wh-objeto:frame:name = c-pagina) or
                   (c-campo <> '' and c-tipo  = '' and c-pagina  = '' and wh-objeto:name = c-campo) or
                   (c-campo  = '' and c-tipo <> '' and c-pagina  = '' and wh-objeto:type = c-tipo)  or
                   (c-campo  = '' and c-tipo  = '' and c-pagina <> '' and wh-objeto:frame:name = c-pagina) then do:
                   message
                       'nome       = ' wh-objeto:name       skip
                       'tipo       = ' wh-objeto:type       skip
                       'linha      = ' wh-objeto:row        skip
                       'coluna     = ' wh-objeto:col        skip
                       'altura     = ' wh-objeto:height     skip
                       'largura    = ' wh-objeto:width      skip
                       'tipo-inf   = ' wh-objeto:data-type  skip
                       'tooltip    = ' wh-objeto:tooltip    skip
                       'frame:name = ' wh-objeto:frame:name
                       view-as alert-box info buttons ok.
               end.
           end.
 
           if  l-tooltip = yes then do:
               assign wh-objeto:tooltip = ':name........ = '   + string(wh-objeto:name)      + chr(13)
                                        + ':type......... = '  + string(wh-objeto:type)      + chr(13)
                                        + ':row.......... = '  + string(wh-objeto:row)       + chr(13)
                                        + ':col........... = ' + string(wh-objeto:col)       + chr(13)
                                        + ':height....... = '  + string(wh-objeto:height)    + chr(13)
                                        + ':width........ = '  + string(wh-objeto:width)     + chr(13)
                                        + ':frame:name. = '    + string(wh-objeto:frame:name)
                                        no-error.
           end.
 
           if  wh-objeto:name = c-campo and
               wh-objeto:type = c-tipo  and
              (c-pagina = '' or wh-objeto:frame:name = c-pagina) then do:
               return wh-objeto.
           end.
       end.
 
       if  wh-objeto:type = 'field-group' or
           wh-objeto:type = 'frame'       or
           wh-objeto:type = 'window'      or
           wh-objeto:type = 'procedure'   then do:
           assign wh-objeto-recursivo = fc-busca-handle(wh-objeto:first-child, l-mensagem, l-tooltip, c-campo, c-tipo, c-pagina).
           if  valid-handle(wh-objeto-recursivo) then do:
               return wh-objeto-recursivo.
           end.
           assign wh-objeto = wh-objeto:next-sibling no-error.
       end.
       else
           assign wh-objeto = wh-objeto:next-sibling no-error.
    end.
 
    return ?.
end.


