/********************************************************************************
** Copyright DATASUL S.A. (1997)
** Todos os Direitos Reservados.
**
** Este fonte e de propriedade exclusiva da DATASUL, sua reproducao
** parcial ou total por qualquer meio, so podera ser feita mediante
** autorizacao expressa.
*******************************************************************************/
{include/i-prgvrs.i OF0717B 2.00.00.031}  /*** 010031 ***/

&IF "{&EMSFND_VERSION}" >= "1.00"
&THEN
{include/i-license-manager.i OF0717B MOF}
&ENDIF




    {include/tt-edit.i}  /** definiá∆o da tabela p/ impress∆o do campo editor */    
    {include/pi-edit.i}

    DEFINE INPUT PARAMETER c-texto LIKE termo.texto NO-UNDO.
    DEFINE INPUT PARAMETER c-descricao LIKE termo.descricao NO-UNDO.

        run pi-print-editor (c-texto, 60).
        put skip(10) space(41) c-descricao skip
            space(41) fill("-", 40) format "x(40)" skip(5).
        for each tt-editor:
           put space(26) tt-editor.conteudo skip.
        end.
