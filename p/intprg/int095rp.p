/********************************************************************************
** Copyright DATASUL S.A. (1997)
** Todos os Direitos Reservados.
**
** Este fonte e de propriedade exclusiva da DATASUL, sua reproducao
** parcial ou total por qualquer meio, so podera ser feita mediante
** autorizacao expressa.
*******************************************************************************/
{include/i-prgvrs.i INT095RP 1.00.00.000}  /*** 010000 ***/

&IF "{&EMSFND_VERSION}" >= "1.00" &THEN
{include/i-license-manager.i int095rp cdp }
&ENDIF

{cdp/cdcfgdis.i}
  
define temp-table TT-PARAM NO-UNDO
       FIELD DESTINO            AS INTEGER 
       FIELD ARQUIVO            AS CHAR FORMAT "x(35)"
       FIELD USUARIO            AS CHAR FORMAT "x(12)"
       FIELD DATA-EXEC          AS DATE 
       FIELD HORA-EXEC          AS INTEGER 
       FIELD L-IMP-PARAM        AS LOG 
       FIELD L-EXCEL            AS LOG 
       FIELD it-codigo-ini      as character FORMAT "x(16)"
       FIELD it-codigo-fim      as character FORMAT "x(16)"
       FIELD planilha           AS CHAR.

define temp-table tt-msg
    FIELD linha         AS INT
    FIELD tabela        AS CHAR
    FIELD it-codigo     AS CHAR
    FIELD preco         AS DEC
    FIELD data          AS DATE
    FIELD inativar      AS CHAR
    FIELD descricao     AS CHAR.

DEFINE TEMP-TABLE tt-imp
    FIELD col-a       AS CHAR    /* TAbela de pre‡o */
    field col-b       as CHAR    /* Item */
    field col-c       as DEC    /* Pre‡o Venda */
    field col-d       as DATE     /* Data */
    field col-e       as CHAR    /* Situa‡Æo */
    .

def temp-table tt-raw-digita
    field raw-digita as raw.

def input parameter raw-param as raw no-undo.
def input parameter table for tt-raw-digita.

DEF VAR h-excel       AS HANDLE      NO-UNDO.
DEF VAR chExcel       AS COM-HANDLE  NO-UNDO.
DEF VAR c-arq-csv     AS CHAR        NO-UNDO.
DEF VAR i-atualizados AS INT         NO-UNDO.     

DEFINE STREAM s-import.

def var h-acomp         as handle       no-undo.
def var c-selecao       as char no-undo format "x(20)" init "SELE€ÇO".
def var c-impressao     as char no-undo format "x(20)" init "IMPRESSÇO". 
def var c-msg           as char no-undo format "X(10)".
def var l-atualizou     as logical INIT NO no-undo.
DEF VAR l-alterou       AS LOGICAL NO-UNDO.
DEF VAR i-seq-int_ds_item AS INT NO-UNDO.
DEF VAR i-zeros         AS INT NO-UNDO.
DEF VAR c-class         AS CHAR FORMAT "X(8)" NO-UNDO.
DEF VAR c-zeros         AS CHAR FORMAT "X(8)" NO-UNDO.
DEF VAR i-cont          AS INT NO-UNDO.


DEFINE BUFFER b-item FOR ITEM.

run utp/ut-acomp.p persistent set h-acomp.
run pi-inicializar in h-acomp (input "Aguarde !").

{include/i-rpvar.i}

{utp/ut-liter.i SELE€ÇO *}
assign c-selecao = return-value.

{utp/ut-liter.i IMPRESSÇO *}
assign c-impressao = return-value.

create tt-param.
raw-transfer raw-param to tt-param.                    
find first param-global no-lock no-error.



form
    tt-msg.linha          column-label "Linha"                  at 1 
    tt-msg.tabela         column-label "Tabela de Pre‡o"        at 12
    tt-msg.it-codigo      column-label "Item"                   at 30 
    tt-msg.preco          column-label "Pre‡o item"             at 50 
    tt-msg.data           column-label "Data Ini. Validade"     at 65  
    tt-msg.inativar       column-label "Inativar"               AT 80  
    tt-msg.descricao      column-label "Inativar"               AT 100  
    with DOWN STREAM-IO width 142 frame f-impressao.
    

assign c-empresa  = param-global.grupo
       c-programa = "INT095"
       c-versao   = "1.00"
       c-revisao  = "000KML".

assign c-titulo-relat = "IMPORTACAO EXCEL".
assign c-sistema      = "CADASTROS".

{utp/ut-glob.i}

RUN pi-importa-excel.


{include/i-rpcab.i}
{include/i-rpout.i}

RUN pi-processa.

RUN pi-finalizar IN h-acomp.

{include/i-rpclo.i}

return "OK":U.

/*******************************************************************************************************************************************************************************************/

PROCEDURE pi-importa-excel:

    DEFINE VARIABLE i-linha AS INTEGER    NO-UNDO.

    DEFINE VARIABLE l-erro-linha AS LOGICAL    NO-UNDO.
    DEFINE VARIABLE l-erro       AS LOGICAL    NO-UNDO.

    DEFINE VARIABLE ch-arquivo        AS COM-HANDLE NO-UNDO. 
    DEFINE VARIABLE ch-planilha       AS COM-HANDLE NO-UNDO. 
    DEFINE VARIABLE c-arquivo         AS CHARACTER   NO-UNDO.

    IF VALID-HANDLE(h-acomp) THEN DO:
        {utp/ut-liter.i Importando * l}
        RUN pi-acompanhar IN h-acomp (INPUT TRIM(RETURN-VALUE) + "...":U).
    END.

    EMPTY TEMP-TABLE tt-imp.

    ASSIGN i-linha = 1
           l-erro  = NO.

    CREATE 'excel.application' chExcel NO-ERROR.
    ASSIGN chExcel     =  chExcel:APPLICATION 
           ch-arquivo  =  chExcel:workBooks:open(tt-param.planilha, NO, YES)
           ch-planilha =  ch-arquivo:workSheets(1).

     REPEAT ON ENDKEY UNDO, LEAVE:

        ASSIGN i-linha      = i-linha + 1
               l-erro-linha = NO.

        IF i-linha <= 1 THEN NEXT.

        IF chExcel:Range("A"  + STRING(i-linha)):TEXT = "" THEN LEAVE. /* item branco nao importa */

        RUN pi-acompanhar IN h-acomp (INPUT "Registros Lidos : " + STRING(i-linha) ).

        ASSIGN i-atualizados = 0.

        IF chExcel:Range("A"  + STRING(i-linha)):TEXT  >= tt-param.it-codigo-ini      AND  /* item */
           chExcel:Range("A"  + STRING(i-linha)):TEXT  <= tt-param.it-codigo-fim     THEN DO:   

           
            CREATE tt-imp.
            ASSIGN tt-imp.col-a                       = chExcel        :Range("A"  + STRING(i-linha)):TEXT  
                   tt-imp.col-b                       = chExcel        :Range("B"  + STRING(i-linha)):TEXT  
                   tt-imp.col-c                       = chExcel        :Range("C"  + STRING(i-linha)):TEXT    
                   tt-imp.col-d                       = chExcel        :Range("D"  + STRING(i-linha)):TEXT    
                   tt-imp.col-e                       = chExcel        :Range("E"  + STRING(i-linha)):TEXT. 
                                                                                                                                                                                                                   
            ASSIGN i-atualizados = i-atualizados + 1.  

        END.                                                                                                                                                                                                                                                                                              
    END.   

 END PROCEDURE.                                                                                                                                                                                                                                                                                           


PROCEDURE pi-processa:

    DEFINE VARIABLE i-linha AS INTEGER     NO-UNDO.

    ASSIGN i-linha = 1.

    FOR EACH tt-imp:

        ASSIGN i-linha = i-linha + 1.
        
        FIND FIRST ems2mult.preco-item EXCLUSIVE-LOCK
            WHERE preco-item.it-codigo = tt-imp.col-a
              AND preco-item.nr-tabpre = tt-imp.col-b NO-ERROR.

        IF AVAIL preco-item THEN DO:


            CREATE tt-msg.
            ASSIGN tt-msg.linha       = i-linha
                   tt-msg.tabela      = tt-imp.col-a
                   tt-msg.it-codigo   = tt-imp.col-b
                   tt-msg.preco       = DEC(tt-imp.col-c)
                   tt-msg.data        = date(tt-imp.col-d)
                   tt-msg.descricao   = "ITEM inativado com sucesso".

            ASSIGN preco-item.situacao = 2.



        END.
        ELSE DO:

            CREATE tt-msg.
            ASSIGN tt-msg.linha       = i-linha
                   tt-msg.tabela      = tt-imp.col-a
                   tt-msg.it-codigo   = tt-imp.col-b
                   tt-msg.preco       = DEC(tt-imp.col-c)
                   tt-msg.data        = date(tt-imp.col-d)
                   tt-msg.descricao   = "ITEM nÆo encontrado na tabela de pre‡o".


        END.

    END.

    FOR EACH tt-msg:

        DISP tt-msg.linha     
             tt-msg.tabela   
             tt-msg.it-codigo
             tt-msg.preco    
             tt-msg.data     
             tt-msg.descricao FORMAT "X(30)"
             WITH FRAME f-impressao. 
         down with frame f-impressao.

    END.


END PROCEDURE.

