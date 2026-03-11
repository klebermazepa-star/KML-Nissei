/***************************************************************************************
**  Autor....: ResultPro
**  Cliente..: Nissei
**  Programa.: upc-ce0712b-01.p
**  
**  Objetivo: Criar filtro por estabelecimento 
***************************************************************************************/

DEFINE NEW GLOBAL SHARED VAR wh-c-cod-estabel-ini-ce0712 AS WIDGET-HANDLE no-undo.
DEFINE NEW GLOBAL SHARED VAR wh-c-cod-estabel-fim-ce0712 AS WIDGET-HANDLE no-undo.
DEFINE NEW GLOBAL SHARED VAR wh-cod-estabel-ce0712       AS WIDGET-HANDLE no-undo.
DEFINE NEW GLOBAL SHARED VAR wh-bt-ok-orig-ce0712b       AS WIDGET-HANDLE NO-UNDO.

{utp/ut-glob.i}

DEF INPUT PARAMETER p-opcao AS CHAR.

IF p-opcao = "leave" THEN DO:
    
    IF VALID-HANDLE(wh-c-cod-estabel-ini-ce0712) THEN DO:
        ASSIGN wh-c-cod-estabel-fim-ce0712:SCREEN-VALUE = wh-c-cod-estabel-ini-ce0712:SCREEN-VALUE.
    END.

END.

IF p-opcao = "OK" THEN DO:

   ASSIGN wh-cod-estabel-ce0712:SCREEN-VALUE = wh-c-cod-estabel-ini-ce0712:SCREEN-VALUE.
   
   APPLY "choose" TO wh-bt-ok-orig-ce0712b.
END.
