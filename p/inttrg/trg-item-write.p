/****************************************************************************************************
**   Programa: trg-item-write.p - Trigger de write para a tabela item
**             Criar registro pra integra‡Æo com procfit
**   Data....: 14/11/2024
**   Autor: Rafael de Araujo Andrade (rafael.araujo.andrade@gmail.com)
*****************************************************************************************************/

DEF PARAM BUFFER itemAtual FOR ITEM.
DEF PARAM BUFFER itemOld   FOR ITEM. 

DEF VAR numero AS INTEGER.

numero = INTEGER(itemAtual.it-codigo) NO-ERROR.
IF ERROR-STATUS:ERROR THEN RETURN.

FOR EACH integra-item WHERE integra-item.it-codigo = itemAtual.it-codigo EXCLUSIVE-LOCK:
    DELETE integra-item.
END.
 
CREATE integra-item.
ASSIGN integra-item.it-codigo    = itemAtual.it-codigo
       integra-item.dt-alteracao = TODAY
       integra-item.situacao     = 1.
