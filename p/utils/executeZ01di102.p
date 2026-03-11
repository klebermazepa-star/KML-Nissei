define input  parameter nomeAbrev as character  no-undo.
define input parameter hCampoHandle as widget-handle no-undo. 
define input parameter lImplanta as logical   no-undo init true.

define var wh-pesquisa as widget-handle.
def new global shared var l-implanta as logical init no.
def new global shared var wh-window  as handle no-undo.

assign l-implanta = lImplanta.
{include/zoomvar.i &prog-zoom=dizoom/z01di102.w
                   &proghandle=wh-window
                   &campohandle=hCampoHandle
                   &campozoom=cod-entrega
                   &parametros="run pi-seta-inicial in wh-pesquisa (nomeAbrev)."}
