 
/*---------------------------------------------------------------------------------

PAR∂METROS

{1} NOME DA TAG
{2} VALOR DA TAG
{3} ê TAG OBRIGAT‡RIA ?
{4} QTDE DE CASAS DECIMAIS
{5} NR DE CASAS DECIMAIS ê OBRIGAT‡RIO ?

---------------------------------------------------------------------------------*/
    
IF ("{3}" = "NO" /* Se a TAG n∆o for obrigat¢ria, s¢ imprimir se tiver valor */
AND {2} <> 0
AND {2} <> ?)
OR  "{3}"  = "YES" THEN DO: /* Se a TAG for obrigat¢rio, imprimir sempre */

    /* Arredonda o valor {2} conforme o n£mero de casas decimais {4} */
    /* e foráa campo com 10 casas decimais, ex: 1,0000000000         */
    ASSIGN cValue = STRING(ROUND(DEC({2}),{4}),">>>>>>>>>>>>>>9.9999999999"). 

    IF  "{5}" = "NO" THEN /* Se o numero de casas decimais {4} N«O Ç obrigat¢rio */
        ASSIGN cValue = STRING(DEC(cValue),">>>>>>>>>>>>>>9.99<<<<<<<<"). /* retira "zeros" n∆o significativos nas casas decimais */
    
    ASSIGN cValue = TRIM(REPLACE(cValue, ",", ".")). /* troca "v°rgula" por "ponto" como separador de casa decimal */

    IF  "{5}" = "YES" THEN /* Se o numero de casas decimais {4} Ç obrigat¢rio */
        ASSIGN cValue = SUBSTR(cValue, 1, INDEX(cValue, ".") + {4}). /* retira as casas decimais excedentes */
        
    /* OPCAO DE IMPRIMIR LAYOUT XML OU EM TXT */
    IF  lLayoutXML THEN
        RUN addNode  IN hGenXml (getStack(), "{1}", cValue, OUTPUT iId).
    ELSE
    IF  lLayoutTXT THEN DO:

        ASSIGN cValue = (IF ({2} = ? OR ({2} = 0 AND "{1}" = "vICMSDeson"))
                         THEN " "
                         ELSE cValue).

        PUT UNFORMATTED cValue "|".
    END.

END.

