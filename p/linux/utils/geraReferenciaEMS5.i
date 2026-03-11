/**
*
* INCLUDE:
*   utils/geraReferenciaEMS5.i
*
* FINALIDADE:
*   Gera referencia para o EMS 5.
*
*/
procedure geraReferenciaEMS5:
    define output parameter cRef as character  no-undo.

    RUN utils/geraReferenciaEMS5.p (OUTPUT cRef).
end procedure.
