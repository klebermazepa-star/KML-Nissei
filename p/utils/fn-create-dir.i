/* tenta criar a pasta informada */

function fn-create-dir returns integer (input c-pasta as char, input l-msg as logical).
    def var i-status as integer no-undo.

    os-create-dir value(c-pasta).

    assign i-status = os-error.
    
    if l-msg and i-status <> 0 then do:
/*         run utp/ut-msgs.p (input 'show',                                              */
/*                            input 17006,                                               */
/*                            input 'Erro ao tentar criar a pasta.~~' +                  */
/*                                  'Pasta: ' + c-pasta + chr(10) +                      */
/*                                  'Erro do sistema operacional: ' + string(i-status)). */
        /* o ut-msgs causa erro */
        message 'Erro ao tentar criar a pasta.' skip(1)
                'Pasta: ' + c-pasta             skip
                'Erro do sistema operacional: ' + string(i-status)
            view-as alert-box error buttons ok.
    end.

    return i-status.

end function.
