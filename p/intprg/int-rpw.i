/**********************************************************************
**
**  INT-RPW.I - Parametros para execucao dos integradores via RPW
**
**********************************************************************/

DEF TEMP-TABLE tt-raw-digita NO-UNDO 
    FIELD raw-digita AS RAW.
DEF INPUT PARAM raw-param AS RAW NO-UNDO.
DEF INPUT PARAM TABLE FOR tt-raw-digita.

