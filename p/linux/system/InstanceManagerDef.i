/**
*
* INCLUDE:
*   system/InstanceManagerDef.i
*
* FINALIDADE:
*   Declara handle global para a classe gerenciadora instancias de objetos.
*   e, se necessario, instancia a referida classe.
*
*/

define new global shared variable ghInstanceManager as handle no-undo.
{system/Child.i}

/* function newInstance returns handle(input path as char) in ghInstanceManager. */
/* quick fix 09/03/09 . 18:00 */
function newInstance returns handle(input path as char):
    def var hand as handle no-undo.
    run createInstance in ghInstanceManager(target-procedure, path, output hand).
    return hand.
end function.
