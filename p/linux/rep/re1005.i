/***************************************************************************
**
**     Programa....: RE1005.I
**
**     Data........: MARCO DE 1997
**
**     Autor.......: Elisabete
**
**     Objetivo....: Procedure de consistˆncia da atualiza‡Æo da nota fiscal
**
***************************************************************************/

procedure pi-erro-nota:

    def input parameter cod-mensag  as integer                      no-undo.
    def input parameter c-complem   as char                         no-undo.

    run utp/ut-msgs.p ( input "msg",
                        input cod-mensag,
                        input c-complem  ).  

    create tt-erro.
    assign tt-erro.cd-erro  = cod-mensag
           tt-erro.mensagem = return-value
           l-erro           = yes.

    if line-counter > 62 then
        page.

    if line-counter <= 5 then do:
        put c-cabec1 at 0 skip.
        put c-cabec2 at 0 skip.
    end.

    put docum-est.serie-docto at 1.
    put docum-est.nro-docto   at 7.
    put string(docum-est.cod-emitente) at 24 format "x(9)".
    put docum-est.nat-operacao at 35.
    put string(cod-mensag,">>>>>9") at 43.
    
    run pi-print-editor (input tt-erro.mensagem, input 78).
    for each tt-editor:
        put tt-editor.conteudo at 53 format "X(78)" skip.
    end.
end.

procedure pi-consiste-nota:

    def input parameter l-opcao         as logical                      no-undo.
    def input parameter cod-mensag      as integer                      no-undo.
    def input parameter c-complem       as char                         no-undo.
    def input parameter i-seq-item      as integer                      no-undo.
    def input parameter de-calculado    as decimal                      no-undo.
    def input parameter de-informado    as decimal                      no-undo.
    def input parameter i-tipo-msg      as integer                      no-undo. 

    def var c-mensagem                  as char                         no-undo.

    /* CRIACAO DE CONSISTENCIAS DA NOTA */
    if  l-opcao then do: 

        find first consist-nota {cdp/cd8900.i consist-nota docum-est}
               and consist-nota.int-1    = i-seq-item
               and consist-nota.mensagem = cod-mensag
             exclusive-lock no-error.

        if  not avail consist-nota then do:
            create consist-nota.
            assign consist-nota.nro-docto    = docum-est.nro-docto
                   consist-nota.serie-docto  = docum-est.serie-docto
                   consist-nota.cod-emitente = docum-est.cod-emitente
                   consist-nota.nat-operacao = docum-est.nat-operacao
                   consist-nota.int-1        = i-seq-item
                   consist-nota.mensagem     = cod-mensag
                   consist-nota.tipo         = i-tipo-msg.
        end.
        assign consist-nota.calculado = de-calculado
               consist-nota.informado = de-informado.

        run utp/ut-msgs.p ( input "msg",
                            input cod-mensag,
                            input c-complem  ).  

        assign c-mensagem = return-value.

        if not l-erro-nota  then do:
            if  line-counter <= 5 then do:
                put c-cabec1 at 0 skip.
                put c-cabec2 at 0 skip.
            end.
        
            if line-counter > 62 then
               page.
    
            put docum-est.serie-docto at 1.
            put docum-est.nro-docto   at 7.
            put string(docum-est.cod-emitente) at 24 format "x(9)".
            put docum-est.nat-operacao at 35.
            put string(cod-mensag,">>>>>9") at 43.
            
            run pi-print-editor (input c-mensagem, input 78).
            for each tt-editor:
                put tt-editor.conteudo at 53 format "X(78)" skip.
            end.
        end.
    end.
    /* ELIMINACAO DE CONSISTENCIAS DA NOTA */
    else  do:
        for each consist-nota {cdp/cd8900.i consist-nota docum-est}
             and consist-nota.int-1     = i-seq-item
             and consist-nota.mensagem  = cod-mensag exclusive-lock:

            delete consist-nota.
        end.
    end.        
end.

PROCEDURE pi-detalhar-erro:
    DEF INPUT PARAMETER c-msg-detalhe AS CHARACTER NO-UNDO.

    IF LINE-COUNTER > 62 THEN
        PAGE.
    IF LINE-COUNTER <= 5 THEN DO:
        PUT c-cabec1 AT 0 SKIP.
        PUT c-cabec2 at 0 SKIP.
    END.
    RUN pi-print-editor (INPUT c-msg-detalhe, INPUT 78).
    FOR EACH tt-editor:
        PUT tt-editor.conteudo AT 53 FORMAT "X(78)" SKIP.
    END.
END PROCEDURE.

procedure pi-erro-nota-ems5:

    def input parameter cod-mensag  as integer                      no-undo.
    def input parameter desc-mensag as char                         no-undo.
    def input parameter help-mensag as char                         no-undo.

    create tt-erro.
    assign tt-erro.cd-erro  = cod-mensag
           tt-erro.mensagem = desc-mensag + " " + help-mensag
           l-erro           = yes.

    if line-counter > 62 then
        page.

    if line-counter <= 5 then do:
        put c-cabec1 at 0 skip.
        put c-cabec2 at 0 skip.
    end.

    put docum-est.serie-docto at 1.
    put docum-est.nro-docto   at 7.
    put string(docum-est.cod-emitente) at 24 format "x(9)".
    put docum-est.nat-operacao at 35.
    put string(cod-mensag,">>>>>9") at 43.
    
    run pi-print-editor (input tt-erro.mensagem, input 78).
    for each tt-editor:
        put tt-editor.conteudo at 53 format "X(78)" skip.
    end.
end.

/* fim do programa */

