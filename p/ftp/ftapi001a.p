/********************************************************************************
** Copyright DATASUL S.A. (1997)
** Todos os Direitos Reservados.
**
** Este fonte e de propriedade exclusiva da DATASUL, sua reproducao
** parcial ou total por qualquer meio, so podera ser feita mediante
** autorizacao expressa.
*******************************************************************************/
{include/i-prgvrs.i FTAPI001A 2.00.00.005 } /*** 010005 ***/

&IF "{&EMSFND_VERSION}" >= "1.00"
&THEN
{include/i-license-manager.i FTAPI001A MUT}
&ENDIF


/************************************************************************
**
** FTAPI001a.P - Verifica‡Æo de Transa‡Æo do MP ADM046
**
*************************************************************************/
              
IF CAN-FIND (FIRST dest-trans WHERE dest-trans.cd-trans = "ADM046")
THEN RETURN "OK":U.
ELSE RETURN "NOK":U.
