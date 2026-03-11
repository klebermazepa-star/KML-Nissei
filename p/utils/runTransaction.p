/**
* PROGRAMA
*   utils/runTransaction.p
*
* FINALIDADE
*   Executar um programa, dando a op‡Æo de cancelar a transa‡Æo ao final
*   A funcao e muito util para testar processos de negocio de dificil 
*   criacao
*
* VERSOES
*   23/03/2006, Alexandre Reis/Leandro Johann, Datasul Paranaense,
*     Criacao
*/

define input parameter cPrograma as char no-undo.
bloco-trans:
do  transaction on error undo, leave:
    run value(cPrograma).
    message "Confirma Transa‡Æo?"
        view-as alert-box question buttons yes-no update lOk as logical.
    if not lOk then
        undo bloco-trans, leave bloco-trans.
end.
