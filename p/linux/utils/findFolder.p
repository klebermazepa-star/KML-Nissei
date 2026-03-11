/***
*
* PROGRAMA:
*   upc/findFolder.p
*
* FINALIDADE:
*   Procedure para encontrar o widget da folder em um container
*
* PARAMETROS:
*   p-wgh-object: container para procurar o widget
*   h-folder:     widget encontrado
*
* VERSOES:
*   14/09/2005, Leandro Dalle Laste, Datasul Paranaense,
*     Implementacao inicial
*
*/

define input  parameter p-wgh-object as handle no-undo.
define output parameter h-folder     as handle no-undo.

assign h-folder = p-wgh-object.

do while valid-handle(h-folder):
    if  h-folder:file-name = 'utp/thinFolder.w':u then 
        leave.
    assign h-folder = h-folder:next-sibling.
end.
