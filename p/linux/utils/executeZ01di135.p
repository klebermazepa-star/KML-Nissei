define input parameter hCampoHandle as widget-handle no-undo. 
define input parameter hCampo2Handle as widget-handle no-undo. 
define input parameter lImplanta as logical   no-undo init true.

define var wh-pesquisa as widget-handle.
def new global shared var l-implanta as logical init no.
def new global shared var wh-window  as handle no-undo.

assign l-implanta = lImplanta.
{include/zoomvar.i &prog-zoom=dizoom/z03di135.w
                   &proghandle=wh-window
                   &campohandle=hCampoHandle
                   &campohandle2=hCampo2Handle
                   &campozoom=nr-nota-fis
                   &campozoom2=serie
                   }

