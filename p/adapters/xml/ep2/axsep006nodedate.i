/* IMPORTANTE: toda alteraá∆o efetuada nessa include ser† reaproveitada   */
/* pela nova include do layout 2.00 da NF-e. Caso a alteraá∆o compreenda  */
/* apenas o novo layout 2.00, solicitamos que seja observado o coment†rio */
/* da include criada para o novo layout.                                  */

/*---------------------------------------------------------------------------------

PAR∂METROS

{1} NOME DA TAG
{2} VALOR DA TAG
{3} ê TAG OBRIGAT‡RIA ?

---------------------------------------------------------------------------------*/

    
IF ("{3}" = "NO" /* Se a TAG n∆o for obrigat¢ria, s¢ imprimir se tiver valor */
AND  {2} <> ?)
OR  "{3}" = "YES" THEN DO: /* Se a TAG for obrigat¢rio, imprimir sempre */

    /* OPCAO DE IMPRIMIR LAYOUT XML OU EM TXT */
    IF  lLayoutXML THEN
        RUN addNodeDate     IN hGenXml (getStack(), "{1}", {2}, OUTPUT iId).
    ELSE
    IF  lLayoutTXT THEN DO:

        ASSIGN cValue = STRING(YEAR ({2}),"9999") + "-" +
                        STRING(MONTH({2}),"99")   + "-" +
                        STRING(DAY  ({2}),"99")
               cValue = (IF cValue = ?
                         THEN " "
                         ELSE cValue) NO-ERROR.

        PUT UNFORMATTED cValue "|".
    END.
        
END.
