/**
*
* INCLUDE:
*    utils/generateError.i
*
* FINALIDADE:
*   Insere registros na tt-erro.
*
*/
PROCEDURE generateError PRIVATE:
    DEFINE INPUT  PARAMETER iErro     AS INTEGER    NO-UNDO.
    DEFINE INPUT  PARAMETER cDescErro AS CHARACTER  NO-UNDO.

    DEFINE VARIABLE iSequencia AS INTEGER    NO-UNDO.

    FIND LAST tt-erro NO-ERROR.

    IF NOT AVAIL tt-erro THEN
        ASSIGN iSequencia = 1.
    ELSE
        ASSIGN iSequencia = tt-erro.i-sequen + 1.

    CREATE tt-erro.
    ASSIGN tt-erro.i-sequen = iSequencia
           tt-erro.cd-erro  = iErro
           tt-erro.mensagem = cDescErro.

END PROCEDURE.
