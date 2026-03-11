/**********************************************************************
**
**  Programa: upc-cd0603.p - UPC para o programa CD0603 
**              
**  Objetivo: Criar campo natureza operaá∆o cupom, devoluá∆o e tributaá∆o icms
**
**********************************************************************/
 
DEFINE INPUT PARAMETER p-ind-event  AS CHARACTER.
DEFINE INPUT PARAMETER p-ind-object AS CHARACTER.
DEFINE INPUT PARAMETER p-wgh-object AS HANDLE.
DEFINE INPUT PARAMETER p-wgh-frame  AS WIDGET-HANDLE.
DEFINE INPUT PARAMETER p-cod-table  AS CHARACTER.
DEFINE INPUT PARAMETER p-row-table  AS ROWID.


DEFINE NEW GLOBAL SHARED VAR wh-cod-cfp-cupom-cd0603 AS WIDGET-HANDLE NO-UNDO.
DEFINE NEW GLOBAL SHARED VAR wh-txt-cfp-cupom-cd0603 AS WIDGET-HANDLE NO-UNDO.
DEFINE NEW GLOBAL SHARED VAR wh-cod-cfp-devol-cd0603 AS WIDGET-HANDLE NO-UNDO.
DEFINE NEW GLOBAL SHARED VAR wh-txt-cfp-devol-cd0603 AS WIDGET-HANDLE NO-UNDO.
DEFINE NEW GLOBAL SHARED VAR wh-cod-trib-icm-cd0603  AS WIDGET-HANDLE NO-UNDO.
DEFINE NEW GLOBAL SHARED VAR wh-txt-trib-icm-cd0603  AS WIDGET-HANDLE NO-UNDO.

DEFINE NEW GLOBAL SHARED VAR wh-cd-trib-icm          AS WIDGET-HANDLE NO-UNDO.
DEFINE NEW GLOBAL SHARED VAR wh-lbl-cd-trib-icm      AS WIDGET-HANDLE NO-UNDO.

DEFINE NEW GLOBAL SHARED VAR wh-cst-icms             AS WIDGET-HANDLE NO-UNDO.
DEFINE NEW GLOBAL SHARED VAR wh-lbl-cst-icms         AS WIDGET-HANDLE NO-UNDO.

DEFINE VARIABLE c-objeto AS CHARACTER   NO-UNDO.

IF  VALID-HANDLE(p-wgh-object)
THEN
    assign c-objeto   = entry(num-entries(p-wgh-object:private-data, "~/"), p-wgh-object:private-data, "~/").

if  p-ind-event  = "INITIALIZE" and
    p-ind-object = "VIEWER"     and 
    c-objeto     = "v06in046.w"
then do:
    assign p-wgh-frame:width = 90.
    assign p-wgh-frame:height = 6.
    

    create text wh-txt-cfp-cupom-cd0603
    ASSIGN name         = "wh-txt-cfp-cupom-cd0603"
           frame        = p-wgh-frame
           row          = 1.5
           format       = 'x(15)'
           col          = 59
           width        = 15
           screen-value = 'Natureza Cupom:'
           visible      = yes.
    
    create FILL-IN wh-cod-cfp-cupom-cd0603
    ASSIGN name      = "wh-cod-cfp-cupom-cd0603"
           frame     = p-wgh-frame
           width     = 10
           height    = .88
           column    = 70
           row       = 1.4
           format    = "X(6)"
           visible   = true
           sensitive = no.

       ON LEAVE OF wh-cod-cfp-cupom-cd0603 PERSISTENT RUN intupc/upc-cd0603-a.p(INPUT "leave").
       ON F5    OF wh-cod-cfp-cupom-cd0603 PERSISTENT RUN intupc/upc-cd0603-a.p(INPUT "F5-cupom").
       ON MOUSE-SELECT-DBLCLICK OF wh-cod-cfp-cupom-cd0603 PERSISTENT RUN intupc/upc-cd0603-a.p(INPUT "F5-cupom"). 

    create text wh-txt-cfp-devol-cd0603
    ASSIGN name         = "wh-txt-cfp-devol-cd0603"
           frame        = p-wgh-frame
           row          = 2.5
           format       = 'x(19)'
           col          = 55.4
           width        = 18
           screen-value = 'Natureza Devoluá∆o:'
           visible      = yes.
    
    create FILL-IN wh-cod-cfp-devol-cd0603
    ASSIGN name      = "wh-cod-cfp-devol-cd0603"
           frame     = p-wgh-frame
           width     = 10
           height    = .88
           column    = 70
           row       = 2.4
           format    = "X(6)"
           visible   = true
           sensitive = no.


    ON F5    OF wh-cod-cfp-devol-cd0603 PERSISTENT RUN intupc/upc-cd0603-a.p(INPUT "F5-devol").
    ON MOUSE-SELECT-DBLCLICK OF wh-cod-cfp-devol-cd0603 PERSISTENT RUN intupc/upc-cd0603-a.p(INPUT "F5-devol"). 

    create text wh-txt-trib-icm-cd0603
    ASSIGN name         = "wh-txt-trib-icm-cd0603"
           frame        = p-wgh-frame
           row          = 3.5
           format       = 'x(19)'
           col          = 60.4
           width        = 18
           screen-value = 'ICMS Cupom:'
           visible      = yes.

    create FILL-IN wh-cod-trib-icm-cd0603
    ASSIGN name      = "wh-cod-trib-icm-cd0603"
           frame     = p-wgh-frame
           width     = 15
           height    = .88
           column    = 70
           row       = 3.4
           format    = "X(15)"
           visible   = true
           sensitive = no.
    
    /*
    create text wh-lbl-cd-trib-icm
        assign
            name      = 'lbl-cd-trib-icm':u
            frame     = p-wgh-frame
            row       = 1.1
            format    = 'X(10)'
            col       = 55
            width     = 7.5
            screen-value = 'Trib ICMS:'
            visible   = yes.

    create radio-set wh-cd-trib-icm
        assign
            name      = 'cd-trib-icm':u
            frame     = p-wgh-frame
            horizontal = false
            width     = 15
            height    = 3.6
            column    = wh-lbl-cd-trib-icm:col + wh-lbl-cd-trib-icm:width
            row       = 1.0
            font      = wh-lbl-cd-trib-icm:font
            fgcolor   = wh-lbl-cd-trib-icm:fgcolor
            side-label-handle = wh-lbl-cd-trib-icm
            radio-buttons = "Tributado,1,Isento,2,Cesta B†sica,3,ST,9,Nenhum,0"
            help      = 'Tipo de tributaá∆o de ICMS p/ a classificaá∆o fiscal':u
            tooltip   = 'Tipo de tributaá∆o de ICMS p/ a classificaá∆o fiscal':u
            visible   = true
            sensitive = no.

    wh-cd-trib-icm:tab-stop = yes.

    create text wh-lbl-cst-icms
        assign name         = "wh-lbl-cst-icms"
               frame        = p-wgh-frame
               row          = 4.7
               format       = 'x(9)'
               col          = 55
               width        = 7.7
               screen-value = 'CST ICMS:'
               visible      = yes.
    
    create fill-in wh-cst-icms
        assign name      = "wh-cst-icms"
               frame     = p-wgh-frame
               width     = 3
               height    = .88
               column    = wh-lbl-cst-icms:col + wh-lbl-cst-icms:width
               row       = 4.6
               format    = "X(2)"
               visible   = true
               help      = 'C¢digo do CST ICMS':u
               tooltip   = 'C¢digo do CST ICMS':u
               sensitive = no.

    wh-cst-icms:tab-stop = yes.
    */

    create text wh-lbl-cd-trib-icm
        assign
            name      = 'lbl-cd-trib-icm':u
            frame     = p-wgh-frame
            row       = 6.2
            format    = 'X(10)'
            col       = 20
            width     = 7.5
            screen-value = 'Trib ICMS:'
            visible   = yes.

    create radio-set wh-cd-trib-icm
        assign
            name      = 'cd-trib-icm':u
            frame     = p-wgh-frame
            horizontal = TRUE
            width     = 52
            height    = 1.0
            column    = wh-lbl-cd-trib-icm:col + wh-lbl-cd-trib-icm:width
            row       = 6.0
            font      = wh-lbl-cd-trib-icm:font
            fgcolor   = wh-lbl-cd-trib-icm:fgcolor
            side-label-handle = wh-lbl-cd-trib-icm
            radio-buttons = "Tributado,1,Isento,2,Cesta B†sica,3,ST,9,Outros,4,Nenhum,0"
            help      = 'Tipo de tributaá∆o de ICMS p/ a classificaá∆o fiscal':u
            tooltip   = 'Tipo de tributaá∆o de ICMS p/ a classificaá∆o fiscal':u
            visible   = true
            sensitive = no.

    wh-cd-trib-icm:tab-stop = yes.

    create text wh-lbl-cst-icms
        assign name         = "wh-lbl-cst-icms"
               frame        = p-wgh-frame
               row          = 4.7
               format       = 'x(9)'
               col          = 62.4
               width        = 7.7
               screen-value = 'CST ICMS:'
               visible      = yes.
    
    create fill-in wh-cst-icms
        assign name      = "wh-cst-icms"
               frame     = p-wgh-frame
               width     = 3
               height    = .88
               column    = wh-lbl-cst-icms:col + wh-lbl-cst-icms:width
               row       = 4.6
               format    = "X(2)"
               visible   = true
               help      = 'C¢digo do CST ICMS':u
               tooltip   = 'C¢digo do CST ICMS':u
               sensitive = no.

    wh-cst-icms:tab-stop = yes.

end.

if  p-ind-event  = "DISPLAY" and
    p-ind-object = "VIEWER"  and 
    c-objeto     = "v06in046.w" /*AND
    VALID-HANDLE(wh-cod-cfp-cupom-cd0603)*/
then do:
    
    if VALID-HANDLE(wh-cod-cfp-cupom-cd0603) then
        ASSIGN wh-cod-cfp-cupom-cd0603:SCREEN-VALUE = ""
               wh-cod-cfp-devol-cd0603:SCREEN-VALUE = ""
               wh-cod-trib-icm-cd0603 :SCREEN-VALUE = "".

    if valid-handle (wh-cd-trib-icm) then assign wh-cst-icms:screen-value = "".
    if valid-handle (wh-cst-icms)    then assign wh-cd-trib-icm:screen-value = "0".

    for first classif-fisc no-lock
        where rowid(classif-fisc) = p-row-table:

        for first int_ds_classif_fisc no-lock
            where int_ds_classif_fisc.class_fiscal = classif-fisc.class-fiscal:

            if valid-handle (wh-cd-trib-icm) then assign wh-cd-trib-icm:screen-value = string(int_ds_classif_fisc.cd_trib_icm).
            if valid-handle (wh-cst-icms)    then assign wh-cst-icms:screen-value = string(int_ds_classif_fisc.cst_icms).

            
            if valid-handle (wh-cod-cfp-cupom-cd0603) then
                ASSIGN wh-cod-cfp-cupom-cd0603:SCREEN-VALUE = int_ds_classif_fisc.cod_nat_oper_cupom
                       wh-cod-cfp-devol-cd0603:SCREEN-VALUE = int_ds_classif_fisc.cod_nat_oper_devol.
                       
            if valid-handle (wh-cod-trib-icm-cd0603) then
            FOR FIRST natur-oper NO-LOCK
                WHERE natur-oper.nat-operacao = int_ds_classif_fisc.cod_nat_oper_cupom:
                ASSIGN wh-cod-trib-icm-cd0603:screen-value = {ininc\i01in245.i 04 natur-oper.cd-trib-icm}.
            END.
        end.
    end.
end.

if  p-ind-event  = "AFTER-ENABLE" and
    p-ind-object = "VIEWER"       and 
    c-objeto     = "v06in046.w"
then do:
    
    ASSIGN wh-cod-cfp-cupom-cd0603:SENSITIVE = YES
           wh-cod-cfp-devol-cd0603:SENSITIVE = YES.
    if valid-handle (wh-cd-trib-icm) then assign wh-cd-trib-icm:sensitive = yes.
    if valid-handle (wh-cst-icms)    then assign wh-cst-icms:sensitive    = yes.
end.

if  p-ind-event  = "AFTER-DISABLE" and
    p-ind-object = "VIEWER"        and 
    c-objeto     = "v06in046.w"
then do:
    
    ASSIGN wh-cod-cfp-cupom-cd0603:SENSITIVE = NO
           wh-cod-cfp-devol-cd0603:SENSITIVE = NO.
    if valid-handle (wh-cd-trib-icm) then assign wh-cd-trib-icm:sensitive = no.
    if valid-handle (wh-cst-icms)    then assign wh-cst-icms:sensitive    = no.
end.

if  p-ind-event  = "ASSIGN" and
    p-ind-object = "VIEWER" and
    c-objeto     = "v06in046.w"
then do:
    
    IF  wh-cod-cfp-cupom-cd0603:SCREEN-VALUE <> ""
    THEN DO:
        FIND FIRST natur-oper NO-LOCK
            WHERE  natur-oper.nat-operacao = wh-cod-cfp-cupom-cd0603:SCREEN-VALUE NO-ERROR.

        IF  NOT AVAIL natur-oper
        THEN DO:
            RUN utp\ut-msgs.p (INPUT "show",
                               INPUT 17006,
                               INPUT "Natureza de operaá∆o para cumpom n∆o cadastrada.").
            APPLY "entry" TO wh-cod-cfp-cupom-cd0603.
            RETURN "nok".
        END.
    END.

    IF wh-cod-cfp-devol-cd0603:SCREEN-VALUE <> ""
    THEN DO:
        FIND FIRST natur-oper NO-LOCK
            WHERE  natur-oper.nat-operacao = wh-cod-cfp-devol-cd0603:SCREEN-VALUE NO-ERROR.

        IF  NOT AVAIL natur-oper
        THEN DO:
            RUN utp\ut-msgs.p (INPUT "show",
                               INPUT 17006,
                               INPUT "Natureza de operaá∆o para devoluá∆o n∆o cadastrada.").
            APPLY "entry" TO wh-cod-cfp-devol-cd0603.
            RETURN "nok".
        END.
    END.
    

    for first classif-fisc no-lock 
        where rowid(classif-fisc) = p-row-table:

        find first int_ds_classif_fisc exclusive-lock
            where  int_ds_classif_fisc.class_fiscal = classif-fisc.class-fiscal no-error.

        if  not avail int_ds_classif_fisc
        then do:
            create int_ds_classif_fisc.
            assign int_ds_classif_fisc.class_fiscal = classif-fisc.class-fiscal.
        end.

        
        if valid-handle (wh-cod-cfp-cupom-cd0603) then
            ASSIGN int_ds_classif_fisc.cod_nat_oper_cupom = wh-cod-cfp-cupom-cd0603:SCREEN-VALUE
                   int_ds_classif_fisc.cod_nat_oper_devol = wh-cod-cfp-devol-cd0603:SCREEN-VALUE.

        if valid-handle (wh-cd-trib-icm) then assign int_ds_classif_fisc.cd_trib_icm = wh-cd-trib-icm:input-value.
        if valid-handle (wh-cst-icms)    then assign int_ds_classif_fisc.cst_icms    = wh-cst-icms:input-value.

        release int_ds_classif_fisc.
    end.
end.

if  p-ind-event = "DESTROY"
then do:

    if valid-handle (wh-cd-trib-icm) then delete widget wh-cd-trib-icm.
    if valid-handle (wh-lbl-cd-trib-icm) then delete widget wh-lbl-cd-trib-icm.
    if valid-handle (wh-cst-icms) then delete widget wh-cst-icms.
    if valid-handle (wh-lbl-cst-icms) then delete widget wh-lbl-cst-icms.

    
    ASSIGN wh-cod-cfp-cupom-cd0603 = ?
           wh-txt-cfp-cupom-cd0603 = ?
           wh-cod-cfp-devol-cd0603 = ?
           wh-txt-cfp-devol-cd0603 = ?
           wh-cod-trib-icm-cd0603  = ?
           wh-txt-trib-icm-cd0603  = ?.
end.

IF VALID-HANDLE (wh-cd-trib-icm) THEN wh-cd-trib-icm:MOVE-TO-TOP().
IF VALID-HANDLE (wh-lbl-cd-trib-icm) THEN wh-lbl-cd-trib-icm:MOVE-TO-TOP().
IF VALID-HANDLE (wh-cst-icms) THEN wh-cst-icms:MOVE-TO-TOP().
IF VALID-HANDLE (wh-lbl-cst-icms) THEN wh-lbl-cst-icms:MOVE-TO-TOP().


RETURN "OK".

