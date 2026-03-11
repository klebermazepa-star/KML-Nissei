assign
    c-rodape = 'DATASUL - ' + c-sistema + ' - ' + c-programa + ' - V:' + c-versao
    c-rodape = fill('-', 200 - length(c-rodape)) + c-rodape.

form header
    fill('-', 200) format 'x(200)' skip

    c-empresa + 
    fill( ' ', int( ((200 - 12) - length(c-empresa) - length(c-titulo-relat)) / 2)) +
    c-titulo-relat at 01 format 'x(187)'

    'P gina:' at 188 page-number at 196 format '>>>>9' skip
    fill('-', (200 - 22)) format 'x(178)'
    today format '99/99/9999' '-' string(time, 'HH:MM:SS')
    skip(1)
    with stream-io width 200 no-labels no-box page-top frame f-cabec.

form header
     c-rodape format 'x(200)'
     with stream-io width 200 no-labels no-box page-bottom frame f-rodape.
