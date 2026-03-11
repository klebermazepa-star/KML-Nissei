/********************************************************************************
** Programa: int010 - Importa‡Æo de Pedidos CD->Lojas do Tutorial/Sysfarma
**
** Versao : 12 - 30/01/2016 - Alessandro V Baccin
**
********************************************************************************/

FIND FIRST int-ds-ger-cupom NO-LOCK NO-ERROR.

&scoped-define faixa-ini int-ds-ger-cupom.cod-estab-ini-2
&scoped-define faixa-fim int-ds-ger-cupom.cod-estab-fim-2

/* in¡cio */
{intprg/int010rp.i}

return "OK".
