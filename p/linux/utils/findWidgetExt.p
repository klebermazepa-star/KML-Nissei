/***
*
* PROGRAMA:
*   upc/findWidgetExt.p
*
* FINALIDADE:
*   Procedure para encontrar um widget 'extent' em um frame
*
* PARAMETROS:
*   c-widget-name:  nome do widget a ser localizado
*   c-widget-type:  tipo do widget a ser localizado
*   h-start-widget: container para procurar o widget
*   i-index: indice do campo extent
*   h-widget:       widget encontrado
*
* VERSOES:
*   17/10/2005, Leandro Dalle Laste, Datasul Paranaense,
*     Implementacao inicial baseado no findWidget
*
*/

define input  parameter c-widget-name  as char    no-undo.
define input  parameter c-widget-type  as char    no-undo.
define input  parameter h-start-widget as handle  no-undo.
define input  parameter i-index        as integer no-undo.
define output parameter h-widget       as handle  no-undo.

do while valid-handle(h-start-widget):
    if h-start-widget:name  = c-widget-name and
       h-start-widget:type  = c-widget-type and
       h-start-widget:index = i-index           then do:
        assign h-widget = h-start-widget:handle.
        leave.
    end.

    if h-start-widget:type = "field-group":u or
       h-start-widget:type = "frame":u or
       h-start-widget:type = "dialog-box":u then do:
        run utils/findWidgetExt.p
            (input  c-widget-name, input  c-widget-type,
             input  h-start-widget:first-child, input i-index,
             output h-widget).

        if valid-handle(h-widget) then
            leave.
    end.
    assign h-start-widget = h-start-widget:next-sibling.
end.
