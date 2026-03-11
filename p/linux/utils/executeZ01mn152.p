define input parameter hCampoHandle as widget-handle no-undo. 
define input parameter hCampo2Handle as widget-handle no-undo. 
define input parameter lImplanta as logical   no-undo init true.
define input parameter h-frame-aux as logical   no-undo init true.

define var hProgramZoom as widget-handle no-undo.

{method/zoomFields.i &ProgramZoom="mnzoom/z03mn152.w"
                     &FieldZoom1="cd-tag"
                     &frame1=h-frame-aux
                     &fieldHandle1=hCampoHandle
                     &FieldZoom2="descricao"
                     &frame2=h-frame-aux
                     &fieldHandle2=hCampo2Handle                  
    
    }
                     



