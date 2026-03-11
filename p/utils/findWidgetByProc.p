/***
*
* PROGRAMA:
*   utils/findWidgetByProc.p
*
* FINALIDADE:
*   Procedure para encontrar um widget em um frame
* 
* PARAMETROS:
*   c-procedure:    nome da procedure a ser localizada (por exemplo, 'v01ime040')
*   p-wgh-frame:    frame do procedure (passado para a UPC pelo programa Datasul)
*   c-widget-name:  nome do widget a ser localizado
*   c-widget-type:  tipo do widget a ser localizado
*   h-widget (out): widget encontrado
*
* $Id$
*
*/

define input  parameter c-procedure    as character     no-undo.
define input  parameter p-wgh-frame    as widget-handle no-undo.
define input  parameter c-widget-name  as character     no-undo.
define input  parameter c-widget-type  as character     no-undo.
define output parameter h-widget       as handle        no-undo.

define variable h-start-widget as handle no-undo.

run utils/findFrameByProc.p
    (input c-procedure,
     input p-wgh-frame,
     output h-start-widget).

if valid-handle(h-start-widget) then
    run utils/findWidget.p
        (input c-widget-name,
         input c-widget-type,
         input h-start-widget,
         output h-widget).
