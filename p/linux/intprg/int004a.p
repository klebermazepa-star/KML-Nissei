/********************************************************************************
** Copyright DATASUL S.A. (1997)
** Todos os Direitos Reservados.
**
** Este fonte e de propriedade exclusiva da DATASUL, sua reproducao
** parcial ou total por qualquer meio, so podera ser feita mediante
** autorizacao expressa.
*******************************************************************************/
{include/i-prgvrs.i int004a 2.00.00.003}  /*** 010003 ***/
/******************************************************************************
**  Programa: CD9960.p
**  Objetivo: Retorna o numero do proximo emitente
******************************************************************************/

def output param i-emitente like emitente.cod-emitente init 0 no-undo.

def var i-tentativas   as  int               no-undo.
def var i-ultimo-emit like emitente.cod-emit no-undo.

/* Verifica o formato do campo na base para verificar o ultimo emiente */
{utp/ut-field.i mgadm emitente cod-emitente 4}
ASSIGN i-ultimo-emit = INT(FILL("9",LENGTH(RETURN-VALUE))).

DO TRANSACTION:
    
    
    FIND LAST emitente USE-INDEX codigo NO-LOCK NO-ERROR.
    IF AVAIL emitente THEN 
         ASSIGN i-emitente = emitente.cod-emitente + 1.
    ELSE ASSIGN i-emitente = 1.
       
    REPEAT:
       IF CAN-FIND(FIRST emitente USE-INDEX codigo 
                   WHERE emitente.cod-emitente = i-emitente NO-LOCK) THEN DO:
          ASSIGN i-emitente = i-emitente + 1.
          IF  i-emitente > i-ultimo-emit THEN
              ASSIGN i-emitente = 1.
       END.
       ELSE LEAVE.
    END.

    FIND FIRST tab-ocor USE-INDEX descricao EXCLUSIVE-LOCK
         WHERE tab-ocor.cod-tab   = 098 
           AND tab-ocor.descricao = "Inclui Emit"  NO-WAIT NO-ERROR.
    IF NOT AVAIL tab-ocor THEN DO:
        CREATE tab-ocor.
        ASSIGN tab-ocor.cod-tab    = 098
               tab-ocor.descricao  = "Inclui Emit"
               tab-ocor.i-campo[1] = 0.
    END.
           
    IF NOT AVAIL tab-ocor THEN DO:
       FIND FIRST tab-ocor USE-INDEX descricao EXCLUSIVE-LOCK
            WHERE tab-ocor.cod-tab   = 098 
              AND tab-ocor.descricao = "Inclui Emit" NO-ERROR. 
    END.
       
    IF AVAIL tab-ocor THEN
        ASSIGN tab-ocor.i-campo[1] = i-emitente.

    RELEASE tab-ocor.
    
end. /* do transaction */

