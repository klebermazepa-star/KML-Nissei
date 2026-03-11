/*****************************************************************************
**
**     Objetivo: Notas Fiscais EMS para Transportadoras
**
**     Versao..: 2.00.00.000
**     Autor: hoepers - 21/03/2017
*****************************************************************************/
{include/i-prgvrs.i NIFT001 2.00.00.000}

{intprg/nift001tt.i}

def temp-table tt-raw-digita
    field raw-digita as raw.

DEF TEMP-TABLE tt-notas NO-UNDO
    FIELD row-nota      AS ROWID
    FIELD cod-estabel  LIKE nota-fiscal.cod-estabel
    FIELD nome-transp  LIKE nota-fiscal.nome-transp
    FIELD cod-emitente LIKE nota-fiscal.cod-emitente
    INDEX id-transportadora
            cod-estabel
            nome-transp
            cod-emitente.

def input param raw-param as raw no-undo.
def input param table for tt-raw-digita.

/****Variaveis de Relatorio******/
DEFINE VARIABLE v-cod-arq-destino       AS CHARACTER                 NO-UNDO.
DEFINE VARIABLE h-acomp                 AS HANDLE                    NO-UNDO.
DEFINE VARIABLE de-tot-valor-notas    LIKE nota-fiscal.vl-tot-nota   NO-UNDO.
DEFINE VARIABLE de-tot-peso-notas     LIKE nota-fiscal.peso-bru-tot  NO-UNDO.
DEFINE VARIABLE de-volume-nf          LIKE nota-embal.qt-volumes     NO-UNDO.
DEFINE VARIABLE de-tot-volume         LIKE nota-embal.qt-volumes     NO-UNDO.

{include/i-freeac.i}

DEF STREAM s-arquivo.

/*********************************************************************/

FIND LAST param-global NO-LOCK NO-ERROR.

RUN utp/ut-acomp.p PERSISTEN SET h-acomp.
RUN pi-inicializar IN h-acomp("Extraá∆o de nota Transportadoras").

create tt-param.
raw-transfer raw-param to tt-param.

IF  tt-param.dat-emis-ini = 01/01/2000 AND
    tt-param.dat-emis-fim = 12/31/9999
THEN
    ASSIGN tt-param.dat-emis-ini = TODAY - 60
           tt-param.dat-emis-fim = TODAY.

EMPTY TEMP-TABLE tt-notas.

/* Filtrar notas */
bloco-transporte:
FOR EACH  transporte NO-LOCK
    WHERE transporte.nome-abrev >= tt-param.c-nome-transp-ini
      AND transporte.nome-abrev <= tt-param.c-nome-transp-fim
      AND transporte.cod-transp >= tt-param.cod-transp-ini
      AND transporte.cod-transp <= tt-param.cod-transp-fim:

    IF  transporte.nome-abrev = "" OR
        transporte.nome-abrev = "PADRAO"
    THEN
        NEXT bloco-transporte.

    bloco-notas:
    FOR EACH  nota-fiscal USE-INDEX ch-transp NO-LOCK
        WHERE nota-fiscal.nome-transp   = transporte.nome-abrev   
          AND nota-fiscal.dt-emis-nota >= tt-param.dat-emis-ini 
          AND nota-fiscal.dt-emis-nota <= tt-param.dat-emis-fim 
          AND nota-fiscal.cod-estabel  >= tt-param.cod-estab-ini     
          AND nota-fiscal.cod-estabel  <= tt-param.cod-estab-fim 
          AND nota-fiscal.serie        >= tt-param.c-serie-ini       
          AND nota-fiscal.serie        <= tt-param.c-serie-fim
          AND nota-fiscal.nr-nota-fis  >= tt-param.num-nota-ini      
          AND nota-fiscal.nr-nota-fis  <= tt-param.num-nota-fim:
    
        RUN pi-acompanhar IN h-acomp (INPUT "Filtrando Notas:" + STRING(nota-fiscal.dt-emis-nota)).
    
        IF  nota-fiscal.dt-cancela <> ?
        THEN
            NEXT bloco-notas.

        IF  nota-fiscal.idi-sit-nf-eletro        < 3 OR
            nota-fiscal.cod-chave-aces-nf-eletro = "" /* Uso autorizado */ 
        THEN 
            NEXT bloco-notas. 
    
        CREATE tt-notas.
        ASSIGN tt-notas.nome-transp  = nota-fiscal.nome-transp
               tt-notas.cod-estabel  = nota-fiscal.cod-estabel
               tt-notas.row-nota     = ROWID(nota-fiscal)
               tt-notas.cod-emitente = nota-fiscal.cod-emitente.
    END.
END.

/* Gerar Arquivos */
FOR EACH tt-notas
    BREAK BY tt-notas.cod-estabel
          BY tt-notas.nome-transp
          BY tt-notas.cod-emitente:

    FIND nota-fiscal NO-LOCK
        WHERE ROWID(nota-fiscal) = tt-notas.row-nota NO-ERROR.

    RUN pi-acompanhar IN h-acomp (INPUT "Est:" + tt-notas.cod-estabel + " - Transp: " + tt-notas.nome-transp + " - Data: " + STRING(nota-fiscal.dt-emis-nota)).

    IF  FIRST-OF(tt-notas.cod-estabel)
    THEN
        FIND FIRST estabelec NO-LOCK
            WHERE  estabelec.cod-estabel = tt-notas.cod-estabel NO-ERROR.

    IF  FIRST-OF(tt-notas.nome-transp)
    THEN DO:
        ASSIGN v-cod-arq-destino  = tt-param.c-pasta-destino
                                    + "\notfis-" 
                                    + tt-notas.cod-estabel 
                                    + "-"
                                    + fn-free-accent(TRIM(LC(tt-notas.nome-transp))) 
                                    + "-"
                                    + string(day(TODAY),"99")
                                    + string(month(TODAY),"99")
                                    + string(YEAR(TODAY),"9999")                     
                                    + "-"
                                    + string(TIME)
                                    + ".txt"
               de-tot-valor-notas = 0
               de-tot-peso-notas  = 0
               de-tot-volume      = 0.

        FIND transporte NO-LOCK
            WHERE transporte.nome-abrev = nota-fiscal.nome-transp NO-ERROR.

        OUTPUT STREAM s-arquivo to value(v-cod-arq-destino) page-size 0.
    
        PUT STREAM s-arquivo "000"
                             fn-free-accent(CAPS(estabelec.nome))  FORMAT "x(35)"
                             fn-free-accent(CAPS(transporte.nome)) FORMAT "x(35)"
                             STRING(TODAY,"999999")                FORMAT "x(06)"
                             REPLACE(STRING(TIME,"hh:mm"),":","")  FORMAT "x(04)"
                             "NOT"                                 FORMAT "x(03)"
                             STRING(TODAY,"999999")                FORMAT "x(04)"
                             REPLACE(STRING(TIME,"hh:mm"),":","")  FORMAT "x(04)"
                             "0"
                             FILL(" ",145)                         FORMAT "x(145)" SKIP.
    
        PUT STREAM s-arquivo "310"
                             "NOT" 
                             STRING(TODAY,"999999")                FORMAT "x(04)"
                             REPLACE(STRING(TIME,"hh:mm"),":","")  FORMAT "x(04)"
                             "0"
                             FILL(" ",223)                         FORMAT "x(223)" SKIP.
    
        PUT STREAM s-arquivo "311"
                             estabelec.cgc                                FORMAT "x(14)"
                             estabelec.ins-estadual                       FORMAT "x(15)"
                             fn-free-accent(CAPS(estabelec.endereco))     FORMAT "x(40)"
                             fn-free-accent(CAPS(estabelec.cidade))       FORMAT "x(35)"
                             estabelec.cep                                FORMAT "999999999"
                             fn-free-accent(CAPS(estabelec.estado))       FORMAT "x(9)"
                             STRING(nota-fiscal.dt-emis-nota,"99999999")  FORMAT "x(08)"
                             fn-free-accent(CAPS(estabelec.nome))         FORMAT "x(40)"
                             FILL(" ",67)                                 FORMAT "x(67)" SKIP.

    END.

    IF  FIRST-OF(tt-notas.cod-emitente)
    THEN DO:
        FIND emitente NO-LOCK
            WHERE emitente.cod-emitente = nota-fiscal.cod-emitente NO-ERROR.
    
        RUN pi-gera-registro-312.
    END.

    RUN pi-gera-registro-313.

    FOR FIRST natur-oper NO-LOCK
        WHERE natur-oper.nat-operacao = nota-fiscal.nat-operacao:
        PUT STREAM s-arquivo "333"
            natur-oper.cod-cfop FORMAT "x(04)" SKIP.
    END.


/*
    RUN pi-gera-registro-314.
    RUN pi-gera-registro-317.
*/    
    
    IF  LAST-OF(tt-notas.nome-transp)
    THEN DO:
        RUN pi-gera-registro-318.
        OUTPUT STREAM s-arquivo CLOSE.
    END.
END.

run pi-finalizar in h-acomp.

RETURN "OK".


PROCEDURE pi-gera-registro-312:
    IF  nota-fiscal.cod-entrega <> "Padr∆o"
    THEN DO:
        FOR  FIRST loc-entr NO-LOCK 
             WHERE loc-entr.nome-abrev  = nota-fiscal.nome-ab-cli
               AND loc-entr.cod-entrega = nota-fiscal.cod-entrega:

            PUT STREAM s-arquivo "312"
                                 fn-free-accent(CAPS(emitente.nome-emit))     FORMAT "x(40)"
                                 emitente.cgc                                 FORMAT "x(14)"
                                 emitente.ins-estadual                        FORMAT "x(15)"
                                 fn-free-accent(CAPS(loc-entr.endereco))      FORMAT "x(40)"
                                 fn-free-accent(CAPS(loc-entr.bairro))        FORMAT "x(20)"
                                 fn-free-accent(CAPS(loc-entr.cidade))        FORMAT "x(35)"
                                 loc-entr.cep                                 FORMAT "999999999"
                                 FILL(" ",9)                                  FORMAT "x(09)"
                                 fn-free-accent(CAPS(loc-entr.estado))        FORMAT "x(09)"
                                 FILL(" ",4)                                  FORMAT "x(04)"
                                 fn-free-accent(CAPS(emitente.telefone[1]))   FORMAT "x(35)"
                                 "1" /* 1 - CGC, 2 - CPF */
                                 FILL(" ",6)                                  FORMAT "x(06)" SKIP.
        END. 
    END.
    ELSE DO:
        PUT STREAM s-arquivo "312"
                             fn-free-accent(CAPS(emitente.nome-emit))     FORMAT "x(40)"
                             emitente.cgc                                 FORMAT "x(14)"
                             emitente.ins-estadual                        FORMAT "x(15)"
                             fn-free-accent(CAPS(emitente.endereco))      FORMAT "x(40)"
                             fn-free-accent(CAPS(emitente.bairro))        FORMAT "x(20)"
                             fn-free-accent(CAPS(emitente.cidade))        FORMAT "x(35)"
                             emitente.cep                                 FORMAT "999999999"
                             FILL(" ",9)                                  FORMAT "x(09)"
                             fn-free-accent(CAPS(emitente.estado))        FORMAT "x(09)"
                             FILL(" ",4)                                  FORMAT "x(04)"
                             fn-free-accent(CAPS(emitente.telefone[1]))   FORMAT "x(35)"
                             "1" /* 1 - CGC, 2 - CPF */
                             FILL(" ",6)                                  FORMAT "x(06)" SKIP.
    END.
END PROCEDURE.


PROCEDURE pi-gera-registro-313:

    ASSIGN de-volume-nf = 0.
    FOR EACH  nota-embal NO-LOCK
        WHERE nota-embal.cod-estabel = nota-fiscal.cod-estabel
          AND nota-embal.serie       = nota-fiscal.serie
          AND nota-embal.nr-nota-fis = nota-fiscal.nr-nota-fis:

        ASSIGN de-volume-nf = de-volume-nf + nota-embal.qt-volumes.
    END.


    ASSIGN de-tot-valor-notas = de-tot-valor-notas + nota-fiscal.vl-tot-nota  
           de-tot-peso-notas  = de-tot-peso-notas  + nota-fiscal.peso-bru-tot
           de-tot-volume      = de-tot-volume      + de-volume-nf.

    PUT STREAM s-arquivo "313"
                         nota-fiscal.cdd-embarq                            FORMAT "999999999999999"
                         nota-fiscal.cod-rota                              FORMAT "x(07)"
                         "1"                                                         /* 1 = RODOVIµRIO; 2 = AêREO; 3 = MAR÷TIMO; 4 = FLUVIAL; 5 = FERROVIµRIO */
                         "2"                                                         /* 1 = CARGA FECHADA; 2 = CARGA FRACIONADA */
                         "2"                                                         /* 1 = FRIA; 2 = SECA; 3 = MISTA */
                         IF emitente.estado <> "PR" THEN "F" ELSE "C"      FORMAT "x(01)"  /* IF nota-fiscal.cidade-cif <> "" THEN "C" ELSE "F" FORMAT "x(01)" /* CIF ou FOB */ */
                         fn-free-accent(CAPS(nota-fiscal.serie))           FORMAT "x(03)"
                         INT(nota-fiscal.nr-nota-fis)                      FORMAT "99999999"
                         STRING(nota-fiscal.dt-emis-nota,"99999999")       FORMAT "x(08)"
                         "MEDICAMENTO"                                     FORMAT "x(15)"
                         "VOLUME"                                          FORMAT "x(15)"
                         de-volume-nf             * 100                    FORMAT "9999999"
                         nota-fiscal.vl-tot-nota  * 100                    FORMAT "999999999999999"
                         nota-fiscal.peso-bru-tot * 100                    FORMAT "9999999"
                         "00000"                                                     /* peso-cubado */
                         "N"                                                         /* Incidencia ICMS S = SIM; N = N«O; I=ISENTO */
                         IF nota-fiscal.vl-seguro = 0 THEN "N" ELSE "S"    FORMAT "x(01)"
                         nota-fiscal.vl-seguro    * 100                    FORMAT "999999999999999"
                         "000000000000000"                                 FORMAT "x(15)"
                         fn-free-accent(CAPS(nota-fiscal.placa))           FORMAT "x(07)"
                         "N"                                               
                         "000000000000000"                                 FORMAT "x(15)"
                         "000000000000000"                                 FORMAT "x(15)"
                         "000000000000000"                                 FORMAT "x(15)"
                         "000000000000000"                                 FORMAT "x(15)"
                         "I"                                                              /* I = INCLUS«O E = EXCLUS«O/CANCELAMENTO */
                         "000000000000"                                    FORMAT "x(12)" /* valor icms */
                         "000000000000"                                    FORMAT "x(12)" /* valor icms retido */
                         "N"                                                              /* S = SIM Œ NOTA COM BONIFICAÄ«O; N = N«O Œ SEM BONIFICAÄ«O*/
                         FILL(" ",6)                                       FORMAT "x(06)"
                         FILL(" ",6)                                       FORMAT "x(06)"
                         FILL(" ",6)                                       FORMAT "x(06)"
                         TRIM(nota-fiscal.cod-chave-aces-nf-eletro)        FORMAT "x(44)"
                         FILL(" ",6)                                       FORMAT "x(06)"
                         FILL(" ",6)                                       FORMAT "x(06)" SKIP.
END PROCEDURE.


PROCEDURE pi-gera-registro-314:
    FOR EACH it-nota-fisc OF nota-fiscal NO-LOCK:
        PUT STREAM s-arquivo "314"
                             "0000000"              FORMAT "x(07)" /* volumes */
                             FILL(" ",15)           FORMAT "x(15)"
                             it-nota-fisc.it-codigo FORMAT "x(30)" SKIP.
    END.
END PROCEDURE.


PROCEDURE pi-gera-registro-317:
    IF  nota-fiscal.cidade-cif <> ""
    THEN DO:
        PUT STREAM s-arquivo "317"
                             fn-free-accent(CAPS(estabelec.nome))         FORMAT "x(40)"
                             estabelec.cgc                                FORMAT "x(14)"
                             estabelec.ins-estadual                       FORMAT "x(15)"
                             fn-free-accent(CAPS(estabelec.endereco))     FORMAT "x(40)"
                             fn-free-accent(CAPS(estabelec.bairro))       FORMAT "x(20)"
                             fn-free-accent(CAPS(estabelec.cidade))       FORMAT "x(35)"
                             estabelec.cep                                FORMAT "999999999"
                             FILL(" ",9)                                  FORMAT "x(09)"
                             fn-free-accent(CAPS(estabelec.estado))       FORMAT "x(09)"
                             FILL(" ",35)                                 FORMAT "x(35)"
                             FILL(" ",11)                                 FORMAT "x(11)" SKIP.
    END.
    ELSE DO:
        PUT STREAM s-arquivo "317"
                             fn-free-accent(CAPS(emitente.nome-emit))     FORMAT "x(40)"
                             emitente.cgc                                 FORMAT "x(14)"
                             emitente.ins-estadual                        FORMAT "x(15)"
                             fn-free-accent(CAPS(emitente.endereco))      FORMAT "x(40)"
                             fn-free-accent(CAPS(emitente.bairro))        FORMAT "x(20)"
                             fn-free-accent(CAPS(emitente.cidade))        FORMAT "x(35)"
                             emitente.cep                                 FORMAT "999999999"
                             FILL(" ",9)                                  FORMAT "x(09)"
                             fn-free-accent(CAPS(emitente.estado))        FORMAT "x(09)"
                             fn-free-accent(CAPS(emitente.telefone[1]))   FORMAT "x(35)"
                             FILL(" ",11)                                 FORMAT "x(11)" SKIP.
    END.
END PROCEDURE.


PROCEDURE pi-gera-registro-318:
    PUT STREAM s-arquivo "318"
               de-tot-valor-notas * 100 FORMAT "999999999999999"
               de-tot-peso-notas  * 100 FORMAT "999999999999999"
               FILL("0",15)             FORMAT "x(15)"
               de-tot-volume      * 100 FORMAT "999999999999999"
               FILL("0",15)             FORMAT "x(15)"
               FILL("0",15)             FORMAT "x(15)"
               FILL(" ",147)            FORMAT "x(147)"  SKIP.
END PROCEDURE.

