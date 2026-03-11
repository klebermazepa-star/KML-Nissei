/****************************************************************************************************
**   Programa: trg-w-fam-uni-estab.p - Trigger de write para a tabela fam-uni-estab
*****************************************************************************************************/
 
DEF PARAM BUFFER b-fam-uni-estab     FOR fam-uni-estab.
DEF PARAM BUFFER b-old-fam-uni-estab FOR fam-uni-estab.

/* Inicio SM 159 - Dep¢sito unico para Matriz/CD e Filial 23/01/2018 */
IF  b-fam-uni-estab.cod-estabel   = "973" AND
    b-fam-uni-estab.deposito-pad <> "973"
THEN
    ASSIGN b-fam-uni-estab.deposito-pad = "973".

IF  b-fam-uni-estab.cod-estabel  <> "973" AND
    b-fam-uni-estab.deposito-pad <> "LOJ"
THEN
    ASSIGN b-fam-uni-estab.deposito-pad = "LOJ".
/* Fim SM 159 - Dep¢sito unico para Matriz/CD e Filial 23/01/2018 */

RETURN "OK".

