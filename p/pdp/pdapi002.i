/********************************************************************************
** Copyright DATASUL S.A. (1997)
** Todos os Direitos Reservados.
**
** Este fonte e de propriedade exclusiva da DATASUL, sua reproducao
** parcial ou total por qualquer meio, so podera ser feita mediante
** autorizacao expressa.
*******************************************************************************/

def temp-table tt-api-param no-undo
    field alocacao-pedidos as int /* 1-Mant‚m 2-Aloca 3-Desaloca */
    field l-acomp          as logi
    field h-acomp          as handle.

def temp-table tt-aloc-ped-venda no-undo
    field i-sequen   as int
    field nome-abrev like ped-venda.nome-abrev
    field nr-pedcli  like ped-venda.nr-pedcli
    index ch-pedido is primary unique
        nome-abrev
        nr-pedcli.
        
def temp-table tt-aloc-ped-ent no-undo
    field nome-abrev   like ped-ent.nome-abrev
    field nr-pedcli    like ped-ent.nr-pedcli
    field nr-sequencia like ped-ent.nr-sequencia
    field it-codigo    like ped-ent.it-codigo
    field cod-refer    like ped-ent.cod-refer
    field nr-entrega   like ped-ent.nr-entrega
    field qt-a-alocar  as decimal
    index ch-item-ped is primary unique
        nome-abrev
        nr-pedcli
        nr-sequencia
        it-codigo
        cod-refer
        nr-entrega.
        
def temp-table tt-erro no-undo
    field i-sequen as int             
    field cd-erro  as int
    field mensagem as char format "x(255)".
