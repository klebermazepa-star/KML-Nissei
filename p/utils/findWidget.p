/***
*
* PROGRAMA:
*   upc/findWidget.p
*
* FINALIDADE:
*   Procedure para encontrar um widget em um frame
*
* PARAMETROS:
*   c-widget-name:  nome do widget a ser localizado
*   c-widget-type:  tipo do widget a ser localizado
*   h-start-widget: container para procurar o widget
*   h-widget:       widget encontrado
*
* VERSOES:
*   18/06/2004, Leandro Dalle Laste, Datasul Parana,
*     Acrescentado 'dialog-box' ao 'field-group' e 'frame'
*   16/04/2004, Alexandre Reis, Datasul Parana,
*     Transcricao em fonte separado, no diretorio UPC
*   26/12/2003, Leandro Johann, Datasul Parana,
*     Implementacao inicial do modelo recursivo
*
*/

define input  parameter c-widget-name  as char   no-undo.
define input  parameter c-widget-type  as char   no-undo.
define input  parameter h-start-widget as handle no-undo.
define output parameter h-widget       as handle no-undo.

do while valid-handle(h-start-widget):
    if h-start-widget:name = c-widget-name and
       h-start-widget:type = c-widget-type then do:
        assign h-widget = h-start-widget:handle.
        leave.
    end.

    if h-start-widget:type = "field-group":u or
       h-start-widget:type = "frame":u or
       h-start-widget:type = "dialog-box":u then do:
        run utils/findWidget.p (input  c-widget-name,
                                input  c-widget-type,
                                input  h-start-widget:first-child,
                                output h-widget).

        if valid-handle(h-widget) then
            leave.
    end.
    assign h-start-widget = h-start-widget:next-sibling.
end.
