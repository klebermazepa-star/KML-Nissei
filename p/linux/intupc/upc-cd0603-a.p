/****************************************************************************
** Programa: upc-cd0603-a.p
** Objetivo: Criar campo natureza opera‡Æo cupom, devolu‡Æo e tributa‡Æo icms
*****************************************************************************/

DEF INPUT PARAMETER p-evento           AS CHAR NO-UNDO.

DEFINE NEW GLOBAL SHARED VAR wh-cod-cfp-cupom-cd0603 AS WIDGET-HANDLE NO-UNDO.
DEFINE NEW GLOBAL SHARED VAR wh-cod-cfp-devol-cd0603 AS WIDGET-HANDLE NO-UNDO.
DEFINE NEW GLOBAL SHARED VAR wh-cod-trib-icm-cd0603  AS WIDGET-HANDLE NO-UNDO.

DEFINE VARIABLE hprogramzoom AS HANDLE NO-UNDO.

IF p-evento = "leave" 
THEN DO:
    ASSIGN wh-cod-trib-icm-cd0603:SCREEN-VALUE = "".
    FOR FIRST natur-oper NO-LOCK
        WHERE natur-oper.nat-operacao = wh-cod-cfp-cupom-cd0603:SCREEN-VALUE:
        ASSIGN wh-cod-trib-icm-cd0603:SCREEN-VALUE = {ininc\i01in245.i 04 natur-oper.cd-trib-icm}.
    END.
END.


IF p-evento = "F5-cupom" THEN DO:
    {method/zoomfields.i &ProgramZoom="inzoom/z04in245.w"
                         &fieldZoom1="nat-operacao"
                         &fieldhandle1 = "wh-cod-cfp-cupom-cd0603"
                         &EnableImplant="NO"}
END.

IF p-evento = "F5-devol" THEN DO:
    {method/zoomfields.i &ProgramZoom="inzoom/z04in245.w"
                         &fieldZoom1="nat-operacao"
                         &fieldhandle1 = "wh-cod-cfp-devol-cd0603"
                         &EnableImplant="NO"}
END.
