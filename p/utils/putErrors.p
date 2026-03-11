/**
*
* PROGRAMA:
* utils/putErrors.p
*
* FINALIDADE:
*   escreve as mensagens de erro (put) no stream atual, 
*   com cabecalho de 132 colunas, mas imprime toda a mensagem, independente do tamanho
*   Retorna OK se teve erro
*
* Leandro Dalle Laste, Datasul Paranaense
*
* $Id$
*
*/

{method/dbotterr.i} /* RowErrors */

define input parameter table for rowErrors.

/* includes para utilizar pi-print-editor */
{include/tt-edit.i}

&global-define iColunaDescricao 09
&global-define iTamanhoDescricao 124

if not can-find(first rowErrors) then
    return 'nok':u.
    
put unformatted
    skip
    'Erro    Descri‡Æo' skip
    '------- '
    fill('-', {&iTamanhoDescricao}) skip.

for each rowErrors:

    put unformatted
        rowErrors.ErrorNumber at 01 format '>>>,>>9'.

    run putDescricao(input rowErrors.ErrorDescription).

    if rowErrors.ErrorHelp <> ? and rowErrors.ErrorHelp <> '' and
       rowErrors.ErrorDescription <> rowErrors.ErrorHelp then
        run putDescricao(input rowErrors.ErrorHelp).
end.

return 'ok':u.

/* end */

/* procedures */

{include/pi-edit.i}

procedure putDescricao:
    define input parameter cDescricao as character no-undo. 

    run pi-print-editor (cDescricao, {&iTamanhoDescricao}).

    for each tt-editor:
        put unformatted
            tt-editor.conteudo at {&iColunaDescricao}
            skip.
    end.
end.
