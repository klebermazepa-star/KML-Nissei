/***
*
* PROGRAMA:
*   utils/displayMessage.p
*
* FINALIDADE:
*   Procedure para mostrar erros no programa padr∆o datasul
*
* PARAMETROS:
*   rowErrors:  Tabela com os erros que ser∆o mostrados.
*
* VERSOES:
*   19/08/2005, Cristiano Moreira da Costa, Datasul Parana,
*     Implementacao inicial
*
*/

/* Definiá∆o da rowErrors */
{method/dbotterr.i}

/* Definiá∆o de parÉmetros */
DEFINE INPUT PARAMETER TABLE FOR rowErrors.

/* Definiá∆o de vari†veis */
DEFINE VARIABLE hShowMessage AS HANDLE     NO-UNDO.

/* Executando o programa padr∆o datasul para mostrar erros */
RUN utp/showmessage.p PERSISTENT SET hShowMessage.

/* Setando a window como modal */
RUN setModal IN hShowMessage (INPUT YES).

/* Mostrando as mensagens */
RUN showMessages IN hShowMessage (INPUT TABLE rowErrors).

/* Fim */
