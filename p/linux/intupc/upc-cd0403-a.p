/*****************************************************************************
*  Programa: UPC/CD0403.p - Atualiza‡Æo de Estabelecimentos
*  
*  Autor: ResultPro
*
*  Data: 07/2018
*  Objetivo: Mostrar o portador Relacionado ao Adquirente.
******************************************************************************/

DEF NEW GLOBAL SHARED VAR c-seg-usuario AS CHAR NO-UNDO.

define new global shared var h-adquirente        as HANDLE no-undo.
define new global shared var h-fi-portador-db    as HANDLE no-undo.
define new global shared var h-fi-portador-cr    as HANDLE no-undo.

IF h-adquirente:SCREEN-VALUE = "125" THEN DO: /* CIELO */
    ASSIGN h-fi-portador-cr:SCREEN-VALUE = "Cr‚dito: 90101"
           h-fi-portador-db:SCREEN-VALUE = "D‚bito : 90102".
END.
IF h-adquirente:SCREEN-VALUE = "005" THEN DO: /* REDE */
    ASSIGN h-fi-portador-cr:SCREEN-VALUE = "Cr‚dito: 90201"
           h-fi-portador-db:SCREEN-VALUE = "D‚bito : 90202".
END.
/* ELSE IF h-adquirente:SCREEN-VALUE = "181" THEN DO: /* GETNETLAC */ */
/*     ASSIGN h-fi-portador-cr:SCREEN-VALUE = "Cr‚dito: 91601"        */
/*            h-fi-portador-db:SCREEN-VALUE = "D‚bito : 91602".       */
/* END.                                                               */
ELSE IF h-adquirente:SCREEN-VALUE = "082" THEN DO: /* GETNET VERTICAIS */
    ASSIGN h-fi-portador-cr:SCREEN-VALUE = "Cr‚dito: 91601"
           h-fi-portador-db:SCREEN-VALUE = "D‚bito : 91602".
END.
ELSE IF h-adquirente:SCREEN-VALUE = "296" THEN DO: /* SAFRAPAY */
    ASSIGN h-fi-portador-cr:SCREEN-VALUE = "Cr‚dito: 91501"
           h-fi-portador-db:SCREEN-VALUE = "D‚bito : 91502".
END.

RETURN "OK".
