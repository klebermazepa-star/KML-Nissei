/* separa por virgula as palavras contidas em c-text
   tira os acentos e capitaliza para fins de comparacao,
   mas retorna exatamente como passado
 */

/* rotina para tirar acentos */
{include/i-freeac.i}

def input  param c-text as char no-undo.
def output param c-list as char no-undo.

def var i     as integer no-undo.
def var i-asc as integer no-undo.
def var c-aux as char    no-undo.

assign c-list = ''
       c-aux = fn-free-accent(c-text).

do i = 1 to length(c-text):

    assign i-asc = asc(caps(substring(c-aux, i, 1))). /* pega o char convertido */

    if (i-asc >= 48 and i-asc <= 57) or    /* 0..9 */
       (i-asc >= 65 and i-asc <= 90) then  /* A..Z */
        assign c-list = c-list + substring(c-text, i, 1). /* adiciona o char original */

    else
    if c-list <> '' and substring(c-list, length(c-list), 1) <> ',' then
        assign c-list = c-list + ','.
end.

if substring(c-list, length(c-list), 1) = ',' then
    assign c-list = substring(c-list, 1, length(c-list) - 1).

/* end */
