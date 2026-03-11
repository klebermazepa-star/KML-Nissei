assign
    c-rodape = 'DATASUL - ' + c-sistema + ' - ' + c-programa + ' - V:' + c-versao
    c-rodape = fill('-', 160 - length(c-rodape)) + c-rodape.

form header
    fill('-', 160) format 'x(160)' skip

    c-empresa + 
    fill( ' ', int( ((160 - 12) - length(c-empresa) - length(c-titulo-relat)) / 2)) +
    c-titulo-relat at 01 format 'x(147)'

    'P gina:' at 148 page-number at 156 format '>>>>9' skip
    fill('-', (160 - 22)) format 'x(138)'
    today format '99/99/9999' '-' string(time, 'HH:MM:SS')
    skip(1)
    with stream-io width 160 no-labels no-box page-top frame f-cabec.

form header
     c-rodape format 'x(160)'
     with stream-io width 160 no-labels no-box page-bottom frame f-rodape.
