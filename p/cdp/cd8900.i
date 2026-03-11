/******************************************************************************
*
* CD8900.I -   - CONDICAO PARA LEITURA DE ARQUIVOS QUE ENVOLVEM NOTAS  *
* 
*                Copia do programa ce9030.i, p/ ser utilizado no Recebimento.
*
******************************************************************************/

use-index documento where
{1}.serie-docto = {2}.serie-docto and
{1}.nro-docto = {2}.nro-docto and
{1}.cod-emitente = {2}.cod-emitente and
{1}.nat-operacao = {2}.nat-operacao

/* Fim */
