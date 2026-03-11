/**
*
* INCLUDE:
*    utils/generateRowError.p
*
* FINALIDADE:
*   Insere registros na rowErrors.
*
* PARAMETROS:
*   iErro    :  Numero do erro.
*   cDescErro:  Texto do erro.
*   cErroHelp:  Descricao detalhada do erro.
*   rowErrors:  Tabela com os erros que ser’o mostrados.
*
* NOTAS:
*   Os parametros cDescErro e cErroHelp devem ser passados
*   tal qual deverao ser mostrados na tela, ou seja, ja com
*   as substituicoes de parametros (&1,&2,etc) ja realizadas.
*
* VERSOES:
*   19/08/2005, Cristiano Moreira da Costa, Datasul Parana,
*     Implementacao inicial do modelo recursivo
*
*/

/* Definicao da rowErrors */
{method/dbotterr.i}

/* Definicao dos parametros */
DEFINE INPUT  PARAMETER iErro     AS INTEGER    NO-UNDO.
DEFINE INPUT  PARAMETER cDescErro AS CHARACTER  NO-UNDO.
DEFINE INPUT  PARAMETER cErroHelp AS CHARACTER  NO-UNDO.
DEFINE INPUT-OUTPUT PARAMETER TABLE FOR rowErrors.

/* Definicao das variaveis */
DEFINE VARIABLE iSequencia AS INTEGER    NO-UNDO.

FIND LAST rowErrors NO-ERROR.

IF NOT AVAIL rowErrors THEN
    ASSIGN iSequencia = 1.
ELSE
    ASSIGN iSequencia = rowErrors.ErrorSequence + 1.

CREATE rowErrors.
ASSIGN rowErrors.ErrorSequence    = iSequencia
       rowErrors.ErrorNumber      = iErro
       rowErrors.ErrorDescription = cDescErro
       rowErrors.ErrorParameters  = ""
       rowErrors.ErrorType        = "EMS"
       rowErrors.ErrorHelp        = cErroHelp.

FIND FIRST cadast_msg NO-LOCK WHERE cadast_msg.cdn_msg = iErro NO-ERROR.
IF NOT AVAIL cadast_msg OR Cadast_msg.idi_tip_msg = 1 THEN
    ASSIGN rowErrors.ErrorSubType = "Error".
ELSE 
    CASE cadast_msg.idi_tip_msg:
        WHEN 2 THEN ASSIGN rowErrors.ErrorSubType = "Warning".
        /*WHEN 3 THEN ASSIGN rowErrors.ErrorSubType = "Question".*/ /* NÆo tratado dentro da showMessage.p */
        WHEN 4 THEN ASSIGN rowErrors.ErrorSubType = "Information".
        OTHERWISE ASSIGN rowErrors.ErrorSubType = "Error".
    END CASE.

/* Fim */
