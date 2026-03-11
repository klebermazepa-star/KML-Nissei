/**
* PROGRAMA:
*   utils/ttErro.i
*
* FINALIDADE:
*   declarar a temp-table tt-erro
*/

def temp-table tt-erro no-undo /* usada em alguns processos */
    field i-sequen as int             
    field cd-erro  as int
    field mensagem as char.

