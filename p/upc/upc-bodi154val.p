
/*
/* Include i-epc200.i: Definicao Temp-Table tt-epc */
{include/i-epc200.i}
{dibo/bodi154.i tt-ped-item}
{pdp/pdapi002.i} /* Defini»’o tt-erro */ 

DEFINE  VARIABLE  h-aloc AS HANDLE      NO-UNDO. 
 
run pdp/pdapi002.p persistent set h-aloc.

DEFINE VARIABLE i-ind-aval AS INTEGER     NO-UNDO.
 
DEF INPUT PARAM p-ind-event AS CHAR NO-UNDO.
DEF INPUT-OUTPUT PARAM TABLE FOR tt-epc.

DEFINE VARIABLE l-ok             AS LOGICAL     NO-UNDO.
DEFINE VARIABLE r-rowid             AS ROWID       NO-UNDO.
DEFINE VARIABLE de-qtd-saldo        AS DECIMAL     NO-UNDO.

    /* Variaveis locais */
DEF VAR h-bo-ped-item   AS WIDGET-HANDLE NO-UNDO.
DEF VAR r-ped-item      AS ROWID NO-UNDO.

DEF BUFFER bf-ped-item  FOR ped-item.
DEF BUFFER bf-ped-venda FOR ped-venda. 

FIND FIRST tt-epc NO-ERROR.

IF AVAIL tt-epc AND 
   tt-epc.cod-event = 'AfterValidateItem' THEN DO: 

    ASSIGN h-bo-ped-item = WIDGET-HANDLE(tt-epc.val-parameter).

    IF VALID-HANDLE(h-bo-ped-item) THEN DO:    
       
        RUN GetRecord IN h-bo-ped-item (OUTPUT TABLE tt-ped-item).
        
        FOR EACH tt-ped-item:
        
            FIND FIRST ped-venda OF tt-ped-item NO-ERROR.

            RUN pi-verifica-saldo IN h-aloc ( INPUT tt-ped-item.it-codigo,
                                              INPUT tt-ped-item.cod-refer,
                                              INPUT ped-venda.cod-estab,
                                              INPUT TODAY,
                                              OUTPUT de-qtd-saldo).
                                        
            IF tt-ped-item.qt-pedida - tt-ped-item.qt-log-aloca <= de-qtd-saldo THEN 
                RETURN "OK". 
            ELSE DO: 
            
                RUN _insertErrorManual IN h-bo-ped-item (INPUT 9999,
                                             INPUT "EPC",
                                             INPUT "ERROR",
                                             INPUT '*** Item sem saldo em estoque disponivel.*** ' ,
                                             INPUT "",
                                             INPUT "").
                RETURN "NOK" .                                              
            END.
                              
           
        END.           
    END.           
END.  */         
           
           
           
           
