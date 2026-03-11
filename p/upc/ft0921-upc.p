// Fun‡äes                                                                                 
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

// Vari veis Locais
define variable c-objeto                        as character        no-undo.
define variable h-handle-aux                    as handle           no-undo.
define variable wh_lbl-estado-fcp-tr-cd0754a    as handle           no-undo.
define variable wh_lbl-aliq-fcp-tr-cd0754a      as handle           no-undo.


// Vari veis Globais
define new global shared variable wh-bt-atualiza              as handle           no-undo.
define new global shared variable wh-bt-atualiza-aux          as handle           no-undo.
define new global shared variable wh-bt-enviar                as handle           no-undo.
define new global shared variable wh-bt-enviar-aux            as handle           no-undo.
define new global shared variable wh-brDoctoMDFE              as handle           no-undo.


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
                                           'btAtualiza',    /* objeto ser buscado  */ /* obrigat½rio */
                                           'button',      /* tipo do objeto      */ /* obrigat½rio */
                                           '').
    
    ASSIGN wh-bt-atualiza = h-handle-aux.

    CREATE BUTTON wh-bt-atualiza-aux
    ASSIGN FRAME        = wh-bt-atualiza:FRAME  
           WIDTH        = wh-bt-atualiza:width
           HEIGHT       = wh-bt-atualiza:height
           ROW          = wh-bt-atualiza:row
           COL          = wh-bt-atualiza:col
           NAME         = 'wh-bt-atualiza-aux'
           LABEL        = wh-bt-atualiza:label
           SENSITIVE    = yes
           VISIBLE      = yes
           TRIGGERS:
              ON CHOOSE PERSISTENT RUN upc/ft0921-upc-b.p.
           END TRIGGERS.
    
    wh-bt-atualiza-aux:LOAD-IMAGE-UP(wh-bt-atualiza:IMAGE-UP).

    wh-bt-atualiza-aux:MOVE-TO-TOP().
    wh-bt-atualiza:VISIBLE = NO.

    assign h-handle-aux = fc-busca-handle (p-wgh-frame,   /* objeto */
                                           no,            /* visualiza mensagem  */
                                           no,            /* alterar tooltip     */
                                           'btEnviar',    /* objeto ser buscado  */ /* obrigat½rio */
                                           'button',      /* tipo do objeto      */ /* obrigat½rio */
                                           '').
    
    ASSIGN wh-bt-enviar = h-handle-aux.

    CREATE BUTTON wh-bt-enviar-aux
    ASSIGN FRAME        = wh-bt-enviar:FRAME  
           WIDTH        = wh-bt-enviar:width
           HEIGHT       = wh-bt-enviar:height
           ROW          = wh-bt-enviar:row
           COL          = wh-bt-enviar:col
           NAME         = 'wh-bt-enviar-aux'
           LABEL        = wh-bt-enviar:label
           SENSITIVE    = yes
           VISIBLE      = yes
           TRIGGERS:
              ON CHOOSE PERSISTENT RUN upc/ft0921-upc-a.p.
           END TRIGGERS.

    wh-bt-enviar-aux:MOVE-TO-TOP().
    wh-bt-enviar:VISIBLE = NO.

    assign h-handle-aux = fc-busca-handle (p-wgh-frame,   /* objeto */
                                           NO,            /* visualiza mensagem  */
                                           no,            /* alterar tooltip     */
                                           'brDoctoMDFE', /* objeto ser buscado  */ /* obrigat½rio */
                                           'BROWSE',      /* tipo do objeto      */ /* obrigat½rio */
                                           '').
    
    ASSIGN wh-brDoctoMDFE = h-handle-aux.
end.

IF VALID-HANDLE(wh-bt-atualiza-aux) THEN
    ASSIGN wh-bt-atualiza-aux:SENSITIVE = wh-bt-atualiza:SENSITIVE.

IF VALID-HANDLE(wh-bt-enviar-aux) THEN
    ASSIGN wh-bt-enviar-aux:SENSITIVE = wh-bt-enviar:SENSITIVE.


// Functions
function fc-busca-handle returns widget-handle (p-fc-wh-objeto as widget-handle,     /* objeto              */
                                                l-mensagem     as logical      ,     /* visualiza mensagem  */
                                                l-tooltip      as logical      ,     /* alterar tooltip     */
                                                c-campo        as character    ,     /* objeto ser buscado  */ /* obrigat½rio               */
                                                c-tipo         as character    ,     /* tipo do objeto      */ /* obrigat½rio               */
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


