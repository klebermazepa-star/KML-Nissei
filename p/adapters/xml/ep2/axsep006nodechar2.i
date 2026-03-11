/* IMPORTANTE: toda alteraá∆o efetuada nessa include ser† reaproveitada   */
/* pela nova include do layout 2.00 da NF-e. Caso a alteraá∆o compreenda  */
/* apenas o novo layout 2.00, solicitamos que seja observado o coment†rio */
/* da include criada para o novo layout.                                  */

/*****************************************************************************************************
FUNCIONALIDADE IGUAL AO axsep006nodechar.i, PORêM SEM TRANSFORMAR CONTEÈDO PARA CAIXA ALTA (MA÷USCULO)
*****************************************************************************************************/

/*---------------------------------------------------------------------------------

PAR∂METROS

{1} NOME DA TAG
{2} VALOR DA TAG
{3} ê TAG OBRIGAT‡RIA ?

---------------------------------------------------------------------------------*/

IF ("{3}" = "NO" /* Se a TAG n∆o for obrigat¢ria, s¢ imprimir se tiver valor */
AND  {2} <> ""
AND  {2} <> ?)
OR  "{3}" = "YES" THEN DO: /* Se a TAG for obrigat¢rio, imprimir sempre */

    /* Retira Acentuaá∆o | Trata Caracteres Especiais */
    /* Retira pulo de linha | Retira espaáos em branco | Todas para ma°sculas*/
    ASSIGN c-string-sem-acento = fn-trata-caracteres(fn-tira-acento(REPLACE(REPLACE(TRIM({2}),CHR(10),""),"?",""))). 
        

    IF "{1}" = "xProd" THEN
        ASSIGN c-string-sem-acento = fn-ajusta-tamanho-campo(c-string-sem-acento,120).

    /* OPCAO DE IMPRIMIR LAYOUT XML OU EM TXT */
    IF  lLayoutXML THEN
        RUN addNode     IN hGenXml (getStack(), "{1}", c-string-sem-acento, OUTPUT iId).
    ELSE IF  lLayoutTXT THEN DO:
        ASSIGN c-string-sem-acento = (IF c-string-sem-acento = ? THEN " " ELSE c-string-sem-acento).
        PUT UNFORMATTED c-string-sem-acento "|".
    END.

END.

