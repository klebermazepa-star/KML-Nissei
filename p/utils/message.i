/***
*
* INCLUDE:
*   utils/message.i
*
* FINALIDADE:
*   Mapeia DEFINE's para os programas que devem ser executados para
*   exibir as mensagens. Nos DEFINE's, as letras depois do h°fen tàm
*   os seguintes significados:
*   1a letra: tipo da mensagem (Q=question, I=information, E=error)
*   Demais: primeira letra dos bot‰es (Y=yes, N=no, C=cancel, O=ok.
*           Por exemplo, YNC indica que ser∆o apresentados os bot‰es
*           SIM, N«O, CANCELAR, com o foco no primeiro bot∆o
*
* VERSOES:
*   23/06/2003, Leandro Johann,
*       criacao
*
*/

&global-define MESSAGE-QYN  "utils/mqyn.p"
&global-define MESSAGE-QNY  "utils/mqny.p"
&global-define MESSAGE-QYNC "utils/mqync.p"
&global-define MESSAGE-IO   "utils/mio.p"
&global-define MESSAGE-EC   "utils/mec.p"
&global-define MESSAGE-EO   "utils/meo.p"
