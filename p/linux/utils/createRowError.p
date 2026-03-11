/**
*
* INCLUDE:
*    utils/createRowError.p
*
* FINALIDADE:
*   Insere registros na rowErrors.
*
* PARAMETROS:
*   iErro      :  Numero do erro.
*   cParametros:  Parametros (como na ut-msgs).
*   rowErrors  :  Tabela dos erros.
*
* NOTAS:
*   Monta a Descricao e Help do erro de acordo com o cadastro da mensagem,
*   da mesma forma que seriam mostrados na ut-msgs.
*
* VERSOES:
*   06/09/2005, Leandro Dalle Laste, Datasul Paranaense,
*   Criacao, a partir do generateRowerror (Cristiano Moreira da Costa, Datasul Parana)
*
*/

/* Definicao da rowErrors */
{method/dbotterr.i}

/* Definicao dos parametros */
DEFINE INPUT  PARAMETER iErro       AS INTEGER    NO-UNDO.
DEFINE INPUT  PARAMETER cParametros AS CHARACTER  NO-UNDO.
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
       rowErrors.ErrorParameters  = ""
       rowErrors.ErrorType        = "EMS".

run utp/ut-msgs.p (input 'codtype':u, input iErro,
                   input cParametros).
if return-value = '0' then do: /* nao cadastrada */
    assign rowErrors.ErrorDescription = cParametros.
end.
else do:
    run utp/ut-msgs.p (input 'msg':u, input iErro,
                       input cParametros).
    assign rowErrors.ErrorDescription = return-value.

    run utp/ut-msgs.p (input 'help':u, input iErro,
                       input cParametros).
    assign rowErrors.ErrorHelp = return-value.
end.

if trim(rowErrors.ErrorHelp) = '' then
    assign rowErrors.ErrorHelp = cParametros.

run utp/ut-msgs.p (input 'type':u, input iErro,
                   input cParametros).
assign rowErrors.ErrorSubType = return-value.

/* Fim */
