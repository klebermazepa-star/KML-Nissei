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

DEFINE NEW GLOBAL SHARED VAR wh-cd-trib-icm-ent          AS WIDGET-HANDLE NO-UNDO.
DEFINE NEW GLOBAL SHARED VAR wh-lbl-cd-trib-icm-ent      AS WIDGET-HANDLE NO-UNDO.

DEFINE VARIABLE c-objeto AS CHARACTER   NO-UNDO.

IF  VALID-HANDLE(p-wgh-object) 
THEN
    assign c-objeto   = entry(num-entries(p-wgh-object:private-data, "~/"), p-wgh-object:private-data, "~/").

IF  p-ind-event  = "INITIALIZE" AND 
    p-ind-object = "VIEWER"     AND 
    c-objeto     = "v06in046.w"
THEN DO:
    ASSIGN p-wgh-frame:WIDTH = 85.
    
    create text wh-txt-cfp-cupom-cd0603
    ASSIGN name         = "wh-txt-cfp-cupom-cd0603"
           frame        = p-wgh-frame
           row          = 1.5
           format       = 'x(15)'
           col          = 58
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
           col          = 58
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

    
    create text wh-lbl-cd-trib-icm
        assign
            name      = 'lbl-cd-trib-icm':u
            frame     = p-wgh-frame
            row       = 4.7
            format    = 'X(10)'
            col       = 35
            width     = 7.5
            screen-value = 'Trib ICMS:'
            visible   = yes.

    create radio-set wh-cd-trib-icm
        assign
            name      = 'cd-trib-icm':u
            frame     = p-wgh-frame
            horizontal = true
            width     = 43
            height    = .88
            column    = wh-lbl-cd-trib-icm:col + wh-lbl-cd-trib-icm:width
            row       = 4.6
            font      = wh-lbl-cd-trib-icm:font
            fgcolor   = wh-lbl-cd-trib-icm:fgcolor
            side-label-handle = wh-lbl-cd-trib-icm
            radio-buttons = "Tributado,1,Isento,2,Cesta B†sica,3,ST,9,Nenhum,0"
            help      = 'Tipo de tributaá∆o de ICMS p/ a classificaá∆o fiscal':u
            tooltip   = 'Tipo de tributaá∆o de ICMS p/ a classificaá∆o fiscal':u
            visible   = true
            sensitive = no.

    wh-cd-trib-icm:tab-stop = yes.
    
    /*
    create text wh-lbl-cd-trib-icm-ent
        assign
            name      = 'lbl-cd-trib-icm-ent':u
            frame     = p-wgh-frame
            row       = 4.9
            format    = 'X(10)'
            col       = 38
            width     = 7.5
            screen-value = 'Trib ICMS:'
            visible   = yes.

    create radio-set wh-cd-trib-icm-ent
        assign
            name      = 'cd-trib-icm-ent':u
            frame     = p-wgh-frame
            horizontal = true
            width     = 39
            height    = .88
            column    = wh-lbl-cd-trib-icm-ent:col + wh-lbl-cd-trib-icm-ent:width
            row       = 4.6
            font      = wh-lbl-cd-trib-icm-ent:font
            fgcolor   = wh-lbl-cd-trib-icm-ent:fgcolor
            side-label-handle = wh-lbl-cd-trib-icm-ent
            radio-buttons = "Nenhum,0,Tributado,1,Isento,2,Cesta B†sica,3,ST,9"
            help      = 'Tipo de tributaá∆o de ICMS p/ a classificaá∆o fiscal':u
            tooltip   = 'Tipo de tributaá∆o de ICMS p/ a classificaá∆o fiscal':u
            visible   = true
            sensitive = no.

    wh-cd-trib-icm-ent:tab-stop = yes.
    */
END.

IF  p-ind-event  = "DISPLAY" AND 
    p-ind-object = "VIEWER"  AND 
    c-objeto     = "v06in046.w" AND
    VALID-HANDLE(wh-cod-cfp-cupom-cd0603)
THEN DO:
    ASSIGN wh-cod-cfp-cupom-cd0603:SCREEN-VALUE = ""
           wh-cod-cfp-devol-cd0603:SCREEN-VALUE = ""
           wh-cod-trib-icm-cd0603 :SCREEN-VALUE = ""
           wh-cd-trib-icm:screen-value = "0".

    FOR FIRST classif-fisc NO-LOCK
        WHERE ROWID(classif-fisc) = p-row-table:
        FOR FIRST int-ds-classif-fisc NO-LOCK 
            WHERE int-ds-classif-fisc.class-fiscal = classif-fisc.class-fiscal:

            ASSIGN wh-cod-cfp-cupom-cd0603:SCREEN-VALUE = int-ds-classif-fisc.cod-nat-oper-cupom
                   wh-cod-cfp-devol-cd0603:SCREEN-VALUE = int-ds-classif-fisc.cod-nat-oper-devol.

            assign wh-cd-trib-icm:screen-value = string(int-ds-classif-fisc.cd-trib-icm).

            FOR FIRST natur-oper NO-LOCK
                WHERE natur-oper.nat-operacao = int-ds-classif-fisc.cod-nat-oper-cupom:
                ASSIGN wh-cod-trib-icm-cd0603 :SCREEN-VALUE = {ininc\i01in245.i 04 natur-oper.cd-trib-icm}.
            END.
        END.
    END.
END.

IF  p-ind-event  = "AFTER-ENABLE" AND 
    p-ind-object = "VIEWER"       AND 
    c-objeto     = "v06in046.w"
then do:
    ASSIGN wh-cod-cfp-cupom-cd0603:SENSITIVE = YES
           wh-cod-cfp-devol-cd0603:SENSITIVE = YES.
    assign wh-cd-trib-icm:sensitive = yes.
end.

IF  p-ind-event  = "AFTER-DISABLE" AND 
    p-ind-object = "VIEWER"        AND 
    c-objeto     = "v06in046.w"
then do:
    ASSIGN wh-cod-cfp-cupom-cd0603:SENSITIVE = NO
           wh-cod-cfp-devol-cd0603:SENSITIVE = NO.
    assign wh-cd-trib-icm:sensitive = no.
end.

IF  p-ind-event  = "ASSIGN" AND 
    p-ind-object = "VIEWER"       AND 
    c-objeto     = "v06in046.w"
THEN DO:
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

    IF  wh-cod-cfp-devol-cd0603:SCREEN-VALUE <> ""
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

    FOR FIRST classif-fisc NO-LOCK
        WHERE ROWID(classif-fisc) = p-row-table:

        FIND FIRST int-ds-classif-fisc EXCLUSIVE-LOCK 
            WHERE  int-ds-classif-fisc.class-fiscal = classif-fisc.class-fiscal NO-ERROR.

        IF  NOT AVAIL int-ds-classif-fisc
        THEN DO:
            CREATE int-ds-classif-fisc.
            ASSIGN int-ds-classif-fisc.class-fiscal = classif-fisc.class-fiscal.
        END.

        ASSIGN int-ds-classif-fisc.cod-nat-oper-cupom = wh-cod-cfp-cupom-cd0603:SCREEN-VALUE
               int-ds-classif-fisc.cod-nat-oper-devol = wh-cod-cfp-devol-cd0603:SCREEN-VALUE.

        assign int-ds-classif-fisc.cd-trib-icm = int(wh-cd-trib-icm:screen-value).

        RELEASE int-ds-classif-fisc.
    END.
END.

IF  p-ind-event = "DESTROY"
then do:

    if valid-handle (wh-cd-trib-icm) then delete widget wh-cd-trib-icm.
    if valid-handle (wh-lbl-cd-trib-icm) then delete widget wh-lbl-cd-trib-icm.
    ASSIGN wh-cod-cfp-cupom-cd0603 = ?
           wh-txt-cfp-cupom-cd0603 = ?
           wh-cod-cfp-devol-cd0603 = ?
           wh-txt-cfp-devol-cd0603 = ?
           wh-cod-trib-icm-cd0603  = ?
           wh-txt-trib-icm-cd0603  = ?.
end.
IF VALID-HANDLE (wh-cd-trib-icm) THEN wh-cd-trib-icm:MOVE-TO-TOP().
IF VALID-HANDLE (wh-lbl-cd-trib-icm) THEN wh-lbl-cd-trib-icm:MOVE-TO-TOP().

RETURN "OK".

