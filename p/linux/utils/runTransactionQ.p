/**
* PROGRAMA
*   utils/runTransactionQ.p
*
* FINALIDADE
*   Executar um programa, com parametro para dar a op‡Æo de cancelar a 
*   transa‡Æo ao final
*   A funcao e muito util para testar processos de negocio de dificil 
*   criacao
*   NOTA: qdo lQuestion = false, cancela a transacao
*
* VERSOES
*   23/03/2006, Alexandre Reis/Leandro Johann, Datasul Paranaense,
*     Criacao
*/

define input parameter cPrograma as char no-undo.
define input  parameter lQuestion as logical    no-undo.

define variable lOk as logical   no-undo.

bloco-trans:
do  transaction on error undo, leave:
    run value(cPrograma).
    if lQuestion then
        message "Confirma Transa‡Æo?"
            view-as alert-box question buttons yes-no update lOk.
    if not lOk then
        undo bloco-trans, leave bloco-trans.
end.
