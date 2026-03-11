/** utils/debugMe.i 
* Ao invez de colocar um monte de messages em seu codigo e depois ter
* que apagar um por um, use '&scoped-define debug'
* para mostrar e apague-o para esconder!
*
* quando precisar dar manuten‡Æo os pontos criticos ja estarao com esses
* "break points" improvisados!
*/

/** @trace :procedure
* uso: 'run trace( msg:String ).'
* WARNING: windows only
*/

/** @debug :function
* uso: 'debug( msg:String ).'
*/

&if defined(debug) &then
define var messageList as char view-as editor size 32 by 15 scrollbar-vertical.
define frame outputDebug
    messageList
    with title "Output" size 32 by 15 view-as dialog-box.
    
&endif

function debug returns log(input msg as char):
    &if defined(debug) &then
        message msg.
        return true.
    &endif
    return false.
end function.
procedure trace private:
    def input param msg as char no-undo.
    &if defined(debug) &then
        assign messageList = messageList + replace(msg, "~~", "~n") + "~n~n".
        enable all with frame outputDebug.
        display messageList with frame outputDebug.
        wait-for 'close' of frame outputDebug.
    &endif
    return.
end procedure.
