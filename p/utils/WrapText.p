/**
*
* PROGRAMA:
*   utils/WrapText.p
*
* FINALIDADE:
*   Programa semelhante ao pi-print-editor, mas que pode ser executado
*   em clientes que so tem o EMS 5 (os .i da pi-print-editor nao estao
*   disponiveis para quem so tem o EMS 5).
*
* VERSOES:
*   21/06/2006, Leandro Johann, Datasul Paranaense,
*     Correcao para nao truncar o texto quando nao encontrava nenhum espaco
*     no cLine (no primeiro SUBSTRING dentro do WHILE).
*   01/02/2005, Leandro Johann, Datasul Paranaense,
*     Versao inicial. ATENCAO: em funcao do pouco tempo nao foram feitos
*     muitos testes. Assim, vale ser cauteloso ao usar esse programa.
*
*/

{utils/fn-one-space.i}
{utils/fn-unWrap.i}

{utils/ttEdit.i tt-editor}

define input  parameter cText      as character  no-undo.
define input  parameter iLineLength as integer   no-undo.
define output parameter table for tt-editor.

define variable cLine      as character no-undo.
define variable iLastSpace as integer   no-undo.

assign cText = fn-one-space(fn-unWrap(cText)).

if length(cText) <= iLineLength then do:
    run createText (input cText).
    return.
end.

do while length(cText) > 0:
    assign cLine      = substring(cText, 1, iLineLength)
           iLastSpace = r-index(cLine, ' ').

    if length(cLine) < iLineLength then
        assign cLine = substring(cLine, 1)
               cText = ''.
    else if iLastSpace = 0 then
        assign cText = substring(cText, iLineLength + 1).
    else
        assign cLine = substring(cLine, 1, iLastSpace - 1)
               cText = substring(cText, iLastSpace + 1).

    run createText (input cLine).
end.

/**
*
* Cria uma nova linha na tt-editor para o texto passado como parametro.
*
*/
procedure createText private:
    define input  parameter cText as character no-undo.

    define variable iLinha as integer no-undo.

    assign iLinha = 1.

    for last tt-editor:
        assign iLinha = tt-editor.linha + 1.
    end.
    
    create tt-editor.
    assign tt-editor.linha    = iLinha
           tt-editor.conteudo = cText.
end procedure.
