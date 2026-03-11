/********************************************************************************
** Copyright DATASUL S.A. (1997)
** Todos os Direitos Reservados.
**
** Este fonte e de propriedade exclusiva da DATASUL, sua reproducao
** parcial ou total por qualquer meio, so podera ser feita mediante
** autorizacao expressa.
*******************************************************************************/


CREATE ALIAS dthrgst   FOR DATABASE emsfnd NO-ERROR.
CREATE ALIAS dthrpmg   FOR DATABASE emsfnd NO-ERROR.
CREATE ALIAS dthrpyc   FOR DATABASE emsfnd NO-ERROR.
CREATE ALIAS dthrtma   FOR DATABASE emsfnd NO-ERROR.


RUN btb/btb908zc.p.

quit.
