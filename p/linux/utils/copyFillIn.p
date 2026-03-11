/***
*
* PROGRAMA:
*   utils/copyFillIn.p
*
* FINALIDADE:
*   cria um fill-in identico
* 
* NOTA:
*
* VERSOES:
*/

define input parameter hOld as widget-handle no-undo. 
define input parameter cName as character no-undo. 
define output parameter hNew as widget-handle no-undo. 
        
create fill-in hNew
     assign
         frame     = hOld:frame
         name      = cName
         width     = hOld:width
         height    = hOld:height
         row       = hOld:row
         col       = hOld:col
         data-type = hOld:data-type
         format    = hOld:format
         font      = hOld:font
         fgcolor   = hOld:fgcolor
         side-label-handle = hOld:side-label-handle
         sensitive = hOld:sensitive
         visible   = hOld:visible
         help      = hOld:help
         tooltip   = hOld:tooltip.

 hNew:move-before-tab(hOld).

 if hOld:mouse-pointer <> '' then
     hNew:load-mouse-pointer(hOld:mouse-pointer).

/* end */
