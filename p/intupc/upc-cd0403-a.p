/*****************************************************************************
*  Programa: UPC/CD0403.p - Atualiza‡Æo de Estabelecimentos
*  
*  Autor: ResultPro
*
*  Data: 07/2018
*  Objetivo: Mostrar o portador Relacionado ao Adquirente.
******************************************************************************/

DEF NEW GLOBAL SHARED VAR c-seg-usuario AS CHAR NO-UNDO.

define new global shared var h-cd0403-adquirente        as HANDLE no-undo.
define new global shared var h-cd0403-fi-portador-db    as HANDLE no-undo.
define new global shared var h-cd0403-fi-portador-cr    as HANDLE no-undo.

IF h-cd0403-adquirente:SCREEN-VALUE = "125" THEN DO: /* CIELO */
    ASSIGN h-cd0403-fi-portador-cr:SCREEN-VALUE = "Cr‚dito: 90101"
           h-cd0403-fi-portador-db:SCREEN-VALUE = "D‚bito : 90102".
END.
IF h-cd0403-adquirente:SCREEN-VALUE = "005" THEN DO: /* REDE */
    ASSIGN h-cd0403-fi-portador-cr:SCREEN-VALUE = "Cr‚dito: 90201"
           h-cd0403-fi-portador-db:SCREEN-VALUE = "D‚bito : 90202".
END.
/* ELSE IF h-cd0403-adquirente:SCREEN-VALUE = "181" THEN DO: /* GETNETLAC */ */
/*     ASSIGN h-cd0403-fi-portador-cr:SCREEN-VALUE = "Cr‚dito: 91601"        */
/*            h-cd0403-fi-portador-db:SCREEN-VALUE = "D‚bito : 91602".       */
/* END.                                                               */
ELSE IF h-cd0403-adquirente:SCREEN-VALUE = "082" THEN DO: /* GETNET VERTICAIS */
    ASSIGN h-cd0403-fi-portador-cr:SCREEN-VALUE = "Cr‚dito: 91601"
           h-cd0403-fi-portador-db:SCREEN-VALUE = "D‚bito : 91602".
END.
ELSE IF h-cd0403-adquirente:SCREEN-VALUE = "296" THEN DO: /* SAFRAPAY */
    ASSIGN h-cd0403-fi-portador-cr:SCREEN-VALUE = "Cr‚dito: 91501"
           h-cd0403-fi-portador-db:SCREEN-VALUE = "D‚bito : 91502".
END.

RETURN "OK".
