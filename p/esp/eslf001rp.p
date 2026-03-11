/*********************************************************************************
*      Programa .....: eslf001rp.p                                               *
*      Data .........: 09/2021                                                   *
*      Sistema ......:                                                           *
*      Empresa ......: Sensus                                                    * 
*      Cliente ......: Nissei                                                    *
*      Programador ..: Jeferson Venicios de Souza                                *
*      Objetivo .....: CORRIGIR SALDO FINAL MES ANTERIOR DWF no LF0203 - CAT42   *
**********************************************************************************
*      VERSAO      DATA        RESPONSAVEL    MOTIVO                             *
*        001       09/2021     Venicios       Desenvolvimento                    * 
*        002       12/2021     Venicios       Desenvolvimento                    * 
*********************************************************************************/
{include/i-prgvrs.i eslf001 1.1.1.002}

/* Temporary Table Definitions ---  */
define temp-table tt-param no-undo
    field destino           as integer
    field arquivo           as char format "x(35)"
    field usuario           as char format "x(12)" 
    FIELD c-cod-estabel     LIKE nota-fiscal.cod-estabel
    FIELD c-periodo-mes     AS INT
    FIELD c-periodo-ano     AS INT
    FIELD c-limpa-dados     AS LOGICAL.

DEF TEMP-TABLE tt-itens NO-UNDO
    FIELD it-codigo LIKE ITEM.it-codigo
    FIELD saldo-ant AS DECIMAL
    FIELD saldo     AS DECIMAL
    FIELD vl-total  AS DECIMAL
    FIELD saldo-neg AS DECIMAL.

DEF TEMP-TABLE tt-datas NO-UNDO
    FIELD id        AS INT
    FIELD c-data    AS DATE
      INDEX idx-prim id.

/* Definiá∆o de Variaveis */
DEF VAR h-acomp          AS HANDLE  NO-UNDO.
DEF VAR meses            AS CHAR EXTENT 12 INITIAL ["31","28","31","30","31","30","31","31","30","31","30","31"].
DEF VAR dt-ini           AS DATE         NO-UNDO.
DEF VAR dt-fim           AS DATE         NO-UNDO.
DEF VAR aux-dia-mes-fim  AS CHAR         NO-UNDO.
DEF VAR periodo          AS CHAR         NO-UNDO.
DEF VAR c-estab          AS CHAR         NO-UNDO.
DEF VAR bisexto          AS DECIMAL      NO-UNDO.
DEF VAR ult-dia-mes-ant  AS DATE         NO-UNDO.
DEF VAR aux-ano-anterior AS INT          NO-UNDO.
DEF VAR aux-mes-anterior AS INT          NO-UNDO.
DEF VAR aux-dia-mes-ant  AS CHAR         NO-UNDO.

/* Definicao e Preparacao dos parametros */
def temp-table tt-raw-digita
    field raw-digita as raw.    
def input parameter raw-param as raw no-undo.
def input parameter table for tt-raw-digita.
create tt-param.
raw-transfer raw-param to tt-param.


/* Output do programa de relatorio ***************************************/
form
    tt-itens.it-codigo      AT 20   column-label    "Codigo Item"
    tt-itens.saldo-neg              column-label    "Saldo a Corrigir"
    tt-itens.vl-total               column-label    "Valor a Corrigir"
    tt-param.c-periodo-mes          column-label    "Mes Dif"
    tt-param.c-periodo-ano          column-label    "Ano Dif"
    with frame f-rel width 132 down stream-io.

{include/i-rpvar.i}
run utp/ut-acomp.p persistent set h-acomp.
{include/i-rpout.i}
RUN pi-inicializar IN h-acomp (INPUT "Iniciando Consultas...").


/****************************************************************************
**                    FUNCTIONS                                            ** 
****************************************************************************/
FUNCTION valor-ult-entrada RETURNS DECIMAL(INPUT c-estab AS CHAR,
                                           INPUT c-item  AS CHAR,
                                           INPUT c-saldo AS DECIMAL):

    DEF VAR aux-valor AS DECIMAL FORMAT ">>>>>>>>>>9.9999" INITIAL 0.
    DEF VAR tot-valor AS DECIMAL FORMAT ">>>>>>>>>>9.9999" INITIAL 0.
    DEF VAR tot-qtd   AS DECIMAL FORMAT ">>>>>>>>>>9.9999" INITIAL 0.
    DEF VAR aux-data  AS DATE INITIAL ?.

    FOR EACH tt-datas USE-INDEX idx-prim NO-LOCK:

        RUN pi-acompanhar IN h-acomp (INPUT "Preáo - It:" + c-item +
                                            " Dt:" + string(tt-datas.c-data)).

        FOR EACH movto-estoq WHERE
            movto-estoq.it-codigo   = c-item            AND   
            movto-estoq.cod-estabel = c-estab           AND
            //movto-estoq.dt-trans   >= (dt-ini - 90) AND
            //movto-estoq.dt-trans    < dt-fim        AND
            movto-estoq.dt-trans    = tt-datas.c-data   AND     
            movto-estoq.tipo-trans  = 1                 AND
           (movto-estoq.esp-docto   = 21        OR 
            movto-estoq.esp-docto   = 23        )       NO-LOCK:
                
            RUN pi-acompanhar IN h-acomp (INPUT "Preáo - It:" + movto-estoq.it-codigo +
                                                " Dt:" + string(movto-estoq.dt-trans) +
                                                " Mov:" + string(movto-estoq.nro-docto)).

            FOR FIRST it-doc-fisc WHERE
                it-doc-fisc.cod-estabel    = movto-estoq.cod-estabel  AND
                it-doc-fisc.serie          = movto-estoq.serie-docto  AND
                it-doc-fisc.nr-doc-fis     = movto-estoq.nro-docto    AND
                it-doc-fisc.cod-emitente   = movto-estoq.cod-emitente AND
                //it-doc-fisc.nat-operacao   = movto-estoq.nat-operacao AND
                it-doc-fisc.dt-docto       = movto-estoq.dt-trans     AND
                it-doc-fisc.it-codigo      = movto-estoq.it-codigo    NO-LOCK.
    
                IF (it-doc-fisc.val-livre-1 + it-doc-fisc.val-icms-subst-entr) > 0 AND it-doc-fisc.quantidade > 0 THEN DO:
                    ASSIGN 
                        tot-valor = tot-valor + (it-doc-fisc.val-livre-1 + it-doc-fisc.val-icms-subst-entr)
                        tot-qtd   = tot-qtd + it-doc-fisc.quantidade.
                END.

            END.

        END.

        IF tot-qtd >= (c-saldo * -1) THEN
                LEAVE.
    END.

    IF tot-valor <= 0 THEN DO:
        FIND FIRST item-uni-estab WHERE 
            item-uni-estab.it-codigo   = movto-estoq.it-codigo   AND
            item-uni-estab.cod-estabel = movto-estoq.cod-estabel NO-LOCK NO-ERROR.
        IF AVAIL item-uni-estab THEN DO:
            ASSIGN aux-valor = item-uni-estab.preco-fiscal.
        END.
    END.
    ELSE DO:
        ASSIGN aux-valor = ROUND(tot-valor / tot-qtd, 2).
    END.

    
    RETURN aux-valor.
END FUNCTION.


/****************************************************************************
**                    INICIO C‡DIGO DO PROGRAMA                            ** 
****************************************************************************/

// Ajusta Data Inicial e Final para buscar dados
ASSIGN dt-ini           = DATE("01" + "/" + string(tt-param.c-periodo-mes) + "/" + string(tt-param.c-periodo-ano)).
ASSIGN bisexto          = tt-param.c-periodo-ano mod 4.
ASSIGN aux-dia-mes-fim  = IF tt-param.c-periodo-mes = 2 AND bisexto = 0 THEN  "29" ELSE meses[tt-param.c-periodo-mes].
ASSIGN dt-fim           = DATE(aux-dia-mes-fim + "/" + string(tt-param.c-periodo-mes) + "/" + string(tt-param.c-periodo-ano)).

// Ajusta Data Final do Mes Anterior para buscar dados
ASSIGN aux-ano-anterior = IF tt-param.c-periodo-mes = 1 THEN tt-param.c-periodo-ano - 1 ELSE tt-param.c-periodo-ano.
ASSIGN aux-mes-anterior = IF tt-param.c-periodo-mes = 1 THEN 12 ELSE tt-param.c-periodo-mes - 1.
ASSIGN aux-dia-mes-fim  = IF aux-mes-anterior = 2 AND bisexto = 0 THEN  "29" ELSE meses[aux-mes-anterior].
ASSIGN ult-dia-mes-ant  = DATE(aux-dia-mes-fim + "/" + string(aux-mes-anterior) + "/" + string(aux-ano-anterior)).

// Cria Temp-table de DATAS para buscar VALOR de ENTRADAS
DEF VAR cont-data    AS INTEGER INITIAL 0 NO-UNDO.
DO cont-data = 1 TO 2200:
    CREATE tt-datas.
    ASSIGN 
        tt-datas.id     =  cont-data
        tt-datas.c-data =  (dt-fim + 1) - cont-data. //dt-fim + 1 pra comeáar da DATA FINAL pois contador comeáa no 1
END.

// Limpar Dados Existente na DWF
IF tt-param.c-limpa-dados = YES THEN DO:

    FOR EACH dwf-sdo-est-it-ressarcto WHERE 
        dwf-sdo-est-it-ressarcto.cod-estab  = tt-param.c-cod-estabel AND
        dwf-sdo-est-it-ressarcto.dat-sdo    = ult-dia-mes-ant        EXCLUSIVE-LOCK:
    
        RUN pi-acompanhar IN h-acomp (INPUT "Limpa Dados - Estab:" + tt-param.c-cod-estabel +
                                            " Dt:" + string(ult-dia-mes-ant)).
    
        DELETE dwf-sdo-est-it-ressarcto.
    
    END.
END.

// Buscando Dados e fazendo validacao
FOR EACH ITEM //WHERE item.it-codigo >= "06800" AND item.it-codigo <= "06850"
    NO-LOCK:

    CREATE tt-itens.
    ASSIGN
        tt-itens.it-codigo = ITEM.it-codigo
        tt-itens.saldo-neg = 0.

    //Procura Saldo do Mes Anterior no LF0203
    FIND FIRST dwf-sdo-est-it-ressarcto WHERE
        dwf-sdo-est-it-ressarcto.cod-estab   = tt-param.c-cod-estabel AND
        dwf-sdo-est-it-ressarcto.cod-item    = tt-itens.it-codigo     AND
        dwf-sdo-est-it-ressarcto.dat-sdo     = ult-dia-mes-ant        EXCLUSIVE-LOCK NO-ERROR.
    IF AVAIL dwf-sdo-est-it-ressarcto THEN DO:
        ASSIGN 
            tt-itens.saldo     = dwf-sdo-est-it-ressarcto.qtd-saldo
            tt-itens.saldo-ant = dwf-sdo-est-it-ressarcto.qtd-saldo * -1.      
    END.
    ELSE DO:
        ASSIGN 
            tt-itens.saldo     = 0
            tt-itens.saldo-ant = 0.
    END.

    //Percorre todos movimentos do Màs para procurar momento NEGATIVO para ajustar
    FOR EACH movto-estoq OF ITEM WHERE
        movto-estoq.cod-estabel = tt-param.c-cod-estabel    AND
        movto-estoq.dt-trans   >=  dt-ini                   AND
        movto-estoq.dt-trans   <=  dt-fim                   NO-LOCK:

        RUN pi-acompanhar IN h-acomp (INPUT "It:" + ITEM.it-codigo +
                                            " Dt:" + string(movto-estoq.dt-trans) +
                                            " Mov:" + string(movto-estoq.nro-docto)).

        IF movto-estoq.tipo-trans = 1 THEN DO:
            //Entrada
            FOR FIRST docum-est WHERE
                    docum-est.serie-docto  = movto-estoq.serie-docto  AND
                    docum-est.nro-docto    = movto-estoq.nro-docto    AND
                    docum-est.cod-emitente = movto-estoq.cod-emitente AND
                    docum-est.nat-operacao = movto-estoq.nat-operacao AND
                    docum-est.cod-estabel  = movto-estoq.cod-estabel  AND
                    docum-est.dt-trans     = movto-estoq.dt-trans     NO-LOCK,
                FIRST item-doc-est OF docum-est WHERE
                    item-doc-est.it-codigo    = movto-estoq.it-codigo    NO-LOCK:
            
                //verifica se Natureza Entrada esta no OF0170
                FIND FIRST dipam-param WHERE       
                    dipam-param.cod-estab  = docum-est.cod-estabel   AND 
                    dipam-param.cod-period = "0"                     AND
                    dipam-param.cod-dipam  = "0"                     AND
                    dipam-param.num-tip    = 6                       AND 
                    dipam-param.cod-tip    = item-doc-est.nat-of     NO-LOCK NO-ERROR.
                IF AVAIL dipam-param THEN DO:

                    //Entrada com Natureza do OF0170 soma no saldo, demais nao somam
                    ASSIGN tt-itens.saldo = tt-itens.saldo + movto-estoq.quantidade.
                END.
            END.    
        END.
        ELSE DO:
            //Saida
            ASSIGN tt-itens.saldo = tt-itens.saldo - movto-estoq.quantidade.
        END.

        //Verifica Quantidade Negativa do Saldo no Momento
        IF tt-itens.saldo-neg > tt-itens.saldo THEN
            ASSIGN tt-itens.saldo-neg = tt-itens.saldo.
    
    END.

    //Verifica se Item ficou Negativo ou N∆o para Buscar Valor
    IF tt-itens.saldo-neg >= 0 THEN
        DELETE tt-itens.
    ELSE DO:
        ASSIGN tt-itens.saldo-neg = tt-itens.saldo-neg + tt-itens.saldo-ant.
        ASSIGN tt-itens.vl-total = ROUND((tt-itens.saldo-neg * -1) * valor-ult-entrada(INPUT tt-param.c-cod-estabel,INPUT tt-itens.it-codigo,INPUT tt-itens.saldo-neg), 2). 
    END.

END.

// Criando Registros que forem necessarios na DWF
PUT "---------------ABAIXO ITENS ACERTADOS NO LF0203-------------" AT 20 SKIP.
FOR EACH tt-itens WHERE tt-itens.vl-total > 0 NO-LOCK:

    RUN pi-acompanhar IN h-acomp (INPUT "Cria Dados - Estab:" + tt-param.c-cod-estabel +
                                        " It:" + tt-itens.it-codigo +
                                        " Dt:" + string(ult-dia-mes-ant)).

    /* Se dados n∆o foram limpos no LF0203 e existir para o ITEM, ele Ç Deletado para criar um novo */
    FIND FIRST dwf-sdo-est-it-ressarcto WHERE
        dwf-sdo-est-it-ressarcto.cod-estab   = tt-param.c-cod-estabel AND
        dwf-sdo-est-it-ressarcto.cod-item    = tt-itens.it-codigo     AND
        dwf-sdo-est-it-ressarcto.dat-sdo     = ult-dia-mes-ant        EXCLUSIVE-LOCK NO-ERROR.
    IF AVAIL dwf-sdo-est-it-ressarcto   THEN DO:

        DELETE dwf-sdo-est-it-ressarcto.

    END.

    /* Cria Registro de Ajuste no LF0203 */
    CREATE dwf-sdo-est-it-ressarcto.
    ASSIGN
        dwf-sdo-est-it-ressarcto.cod-estab   = tt-param.c-cod-estabel
        dwf-sdo-est-it-ressarcto.cod-item    = tt-itens.it-codigo
        dwf-sdo-est-it-ressarcto.dat-sdo     = ult-dia-mes-ant
        dwf-sdo-est-it-ressarcto.qtd-saldo   = tt-itens.saldo-neg * -1
        dwf-sdo-est-it-ressarcto.val-tot-sdo = tt-itens.vl-total.

    DISP
        tt-itens.it-codigo
        tt-itens.saldo-neg
        tt-itens.vl-total
        tt-param.c-periodo-mes
        tt-param.c-periodo-ano
        WITH FRAME f-rel WIDTH 132 STREAM-IO.
    DOWN WITH FRAME f-rel.

END.

PUT skip(2) "-----------ABAIXO ITENS SEM HISTORICO DE PREÄO (N«O FORAM CORRIGIDOS)-------------" AT 20 SKIP.
FOR EACH tt-itens WHERE tt-itens.vl-total <= 0 NO-LOCK:

    RUN pi-acompanhar IN h-acomp (INPUT "Cria Dados - Estab:" + tt-param.c-cod-estabel +
                                        " It:" + tt-itens.it-codigo +
                                        " Dt:" + string(ult-dia-mes-ant)).
    DISP
        tt-itens.it-codigo
        tt-itens.saldo-neg
        tt-itens.vl-total
        tt-param.c-periodo-mes
        tt-param.c-periodo-ano
        WITH FRAME f-rel WIDTH 132 STREAM-IO.
    DOWN WITH FRAME f-rel.

END.
PUT skip(2).

run pi-finalizar in h-acomp. 
{include/i-rpclo.i}
return "OK".


