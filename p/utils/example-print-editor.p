/* includes para tratamento de textos */
{include/tt-edit.i}
{include/pi-edit.i}

run pi-print-editor(input texto, input tamanho).

for each tt-editor:
    tt-editor.conteudo.
end.
