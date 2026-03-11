{include/i-prgvrs.i NICR002RP 2.06.00.001}  
{utp/ut-glob.i}

def new global shared var i-num-ped-exec-rpw  as integer no-undo.   
DEF BUFFER bf-ped-curva FOR ped-curva.

FIND FIRST ped-curva 
    WHERE ped-curva.vl-aberto = 987654321
    AND   ped-curva.codigo    = 987123
    AND   ped-curva.it-codigo = "nicr002" EXCLUSIVE-LOCK NO-WAIT NO-ERROR.

IF LOCKED ped-curva THEN DO:

    FOR FIRST bf-ped-curva NO-LOCK
        WHERE bf-ped-curva.vl-aberto = 987654321
        AND   bf-ped-curva.codigo    = 987123
        AND   bf-ped-curva.it-codigo = "nicr002":
        IF i-num-ped-exec-rpw = 0 THEN DO:
            RUN utp/ut-msgs.p(INPUT "show",
                              INPUT 17006,
                              INPUT "NICR002 j  esta em execu‡Æo!~~Execu‡Æo sendo feita pelo usu rio: " + bf-ped-curva.char-1).
            RETURN "NOK".
        END.
        ELSE 
            RETURN "NICR002 j  esta em execu‡Æo!~~Execu‡Æo sendo feita pelo usu rio: " + bf-ped-curva.char-1.
    END.
END.

IF NOT AVAIL ped-curva THEN DO:
    CREATE ped-curva.
    ASSIGN ped-curva.vl-aberto = 987654321
           ped-curva.codigo    = 987123
           ped-curva.it-codigo = "nicr002".
END.

ASSIGN ped-curva.char-1 = c-seg-usuario.

RELEASE ped-curva.

FIND FIRST ped-curva
    WHERE ped-curva.vl-aberto = 987654321
    AND   ped-curva.codigo    = 987123
    AND   ped-curva.it-codigo = "nicr002" EXCLUSIVE-LOCK NO-WAIT.

RETURN "OK".
