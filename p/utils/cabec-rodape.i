assign c-rodape = 'DATASUL - ' + c-sistema + ' - ' + c-programa + ' - V:' + c-versao
                  + '.00.' + c-revisao.
assign c-rodape = fill('-', 210 - length(c-rodape)) + c-rodape.

form header
    fill('-', 210) format 'x(210)' skip

    c-empresa + 
    fill( ' ', int( ((210 - 12) - length(c-empresa) - length(c-titulo-relat)) / 2)) +
    c-titulo-relat at 01 format 'x(197)'

    'P gina:' at 198 page-number at 206 format '>>>>9' skip
    fill('-', (210 - 22)) format 'x(188)'
    today format '99/99/9999' '-' string(time, 'HH:MM:SS')
    skip(1)
    with stream-io width 210 no-labels no-box page-top frame f-cabec.

form header
     c-rodape format 'x(210)'
     with stream-io width 210 no-labels no-box page-bottom frame f-rodape.
