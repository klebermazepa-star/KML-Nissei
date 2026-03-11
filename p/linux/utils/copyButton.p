/***
*
* PROGRAMA:
*   utils/copyButton.p
*
* FINALIDADE:
*   cria um button identico
*/

define input parameter hOld as widget-handle no-undo. 
define input parameter cName as character no-undo. 
define output parameter hNew as widget-handle no-undo. 
        
create button hNew
    assign
        frame     = hOld:frame
        name      = cName
        help      = hOld:help
        tooltip   = hOld:tooltip
        width     = hOld:width
        height    = hOld:height
        row       = hOld:row
        col       = hOld:col
        flat-button = hOld:flat-button
        visible   = yes
        sensitive = hOld:sensitive.
    
    hNew:load-image(hOld:image).
    hNew:load-image-insensitive(hOld:image-insensitive).
    if not hNew:flat-button then
        hNew:move-before-tab(hOld).

/* end */
