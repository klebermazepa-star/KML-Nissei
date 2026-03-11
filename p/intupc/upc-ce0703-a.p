/***************************************************************************************
**  Autor....: ResultPro
**  Cliente..: Nissei
**  Programa.: upc-ce0703-a.p
**  
**  Objetivo: Desabilitar o campo de sele‡Æo do estabelecimento 
***************************************************************************************/

DEFINE NEW GLOBAL SHARED VAR wh-btexec-orig-ce0703  AS WIDGET-HANDLE no-undo.
DEFINE NEW GLOBAL SHARED VAR wh-btexec-ce0703       AS WIDGET-HANDLE no-undo.
DEFINE NEW GLOBAL SHARED VAR wh-br-digita-ce0703    AS WIDGET-HANDLE no-undo.

{utp/ut-glob.i}
                                  
IF NOT VALID-HANDLE(wh-br-digita-ce0703) OR 
   wh-br-digita-ce0703:NUM-ITERATIONS <= 0  
THEN DO:

   RUN utp/ut-msgs.p (input "show":U, 
                      input 17006, 
                      input "Nenhum estabelecimento informado na tela de digita‡Æo!" + "~~" + 
                            "Informar estabelecimento na pasta de digita‡Æo.").
END.
ELSE 
    APPLY "choose" TO wh-btexec-orig-ce0703.
     

