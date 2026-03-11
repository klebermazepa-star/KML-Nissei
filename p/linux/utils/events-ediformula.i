

OUTPUT TO VALUE("{1}") APPEND NO-CONVERT .

PUT UNFORMATTED 
    p_cdn_mapa_edi ' ; ' p_cdn_segment_edi ' ; ' p_cdn_element_edi SKIP
    'BEGIN' 
    SKIP
    .
FOR EACH tt_param_program_formul NO-LOCK:
    PUT UNFORMATTED '   '
        tt_param_program_formul.tta_cdn_segment_edi ' ; '
        tt_param_program_formul.tta_cdn_element_edi ' ; ' 
        tt_param_program_formul.tta_des_label_utiliz_formul_edi ' ; '
        tt_param_program_formul.ttv_des_contdo
        SKIP
        .
END.
PUT UNFORMATTED 'END' SKIP . 

OUTPUT CLOSE .
