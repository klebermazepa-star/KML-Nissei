/* FINALIDADE:
*   abre documentos windows, usando o shellExecuteA da shell32.dll.
*
* NOTAS:
*  - nShowCmd: 3 - maximizado
*              outros, abre na ultima posicao (?)
*
* VERSOES:
*   14/07/2006, Leandro Dalle Laste,
*   - criacao
*
*/

define input parameter cDocto   as char no-undo.
define input parameter nShowCmd as int no-undo. /* 3 = maximizado, outros abre na ultima posicao */

procedure ShellExecuteA external "Shell32.dll":

    define input parameter hwnd as long.
    define input parameter lpOperation as char  no-undo.
    define input parameter lpFile as char  no-undo.
    define input parameter lpParameters as char  no-undo.
    define input parameter lpDirectory as char  no-undo.
    define input parameter nShowCmd as long.
    define return parameter hInstance as long.

end procedure.


define variable hInst as int  no-undo.

run ShellExecuteA (input 0,
                   input "open",
                   input cDocto,
                   input "",
                   input "",
                   input nShowCmd,
                   output hInst).

if hInst < 0 or hInst > 32 then
    return 'ok':u.
else
    return 'nok':u.

/* end procedure. */

