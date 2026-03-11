/******************************************************************************
**
**  CD4300.I3 - Esse programa define as variaveis que serao utilizadas pela
**              include cd4300.i3, que faz a quebra de uma variavel do tipo
**              caraceter em no maximo 50 outras variaveis do mesmo tipo.
**
**  Significados das variaveis:
**
**  aux-c-char...: Cada ocorrencia dessa variavel sera um novo campo;
**  aux-i-cont...: Contador auxiliar;
**  aux-i-num-var: Contera o numero de variaveis criadas ate o momento;
**
******************************************************************************/

def var aux-c-char    as char extent 50 no-undo.
def var aux-i-cont    as int            no-undo.
def var aux-i-num-var as int extent 2   no-undo.
def var aux-i-tamanho as int extent 2   no-undo.

/*  CD4300.i3  */

