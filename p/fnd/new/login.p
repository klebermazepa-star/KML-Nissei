/*
*/

{utp/ut-glob.i}

{include/i-prgvrs.i LOGIN 1.00.00.000}

DEF INPUT PARAMETER p-user      AS CHAR NO-UNDO .
DEF INPUT PARAMETER p-password  AS CHAR NO-UNDO .
DEF INPUT PARAMETER p-empresa   AS CHAR NO-UNDO .

DEF VAR iCont   AS INT NO-UNDO .

DEF TEMP-TABLE tt-erros NO-UNDO
    FIELD cod-erro      AS INTEGER
    FIELD desc-erro     AS CHARACTER FORMAT "x(256)"
    FIELD desc-arq      AS CHARACTER
    .

DO iCont = NUM-DBS TO 1 BY -1
    :
    IF LDBNAME(iCont) = "emsfnd" THEN NEXT .
    DISCONNECT VALUE(LDBNAME(iCont)) .
END.

TRA1:
DO TRANSACTION ON ERROR UNDO , LEAVE ON STOP UNDO , LEAVE
    :
    FOR FIRST fnd_usuar_univ EXCLUSIVE-LOCK
        WHERE fnd_usuar_univ.cod_usuario = p-user
        :
        ASSIGN
            fnd_usuar_univ.cod_empresa  = p-empresa
            fnd_usuar_univ.cod_livre_1  = p-empresa
            fnd_usuar_univ.log_livre_2  = NO
            fnd_usuar_univ.log_livre_1  = YES
            .
    END.

    RUN btb/btapi910za.p(INPUT p-user, INPUT p-password, OUTPUT TABLE tt-erros) .
    FOR EACH tt-erros NO-LOCK:
        MESSAGE
            "login2 tt-erros" SKIP
            STRING(tt-erros.cod-erro) + " - " + 
            tt-erros.desc-erro + " - " +
            tt-erros.desc-arq 
            VIEW-AS ALERT-BOX .
        UNDO TRA1 , LEAVE TRA1 .
    END.

    CREATE ALIAS DICTDB FOR DATABASE VALUE("emsfnd") .
    SETUSERID(p-user, p-user + "@123456", "DICTDB") .
END.

/**/
RETURN "OK":U .
