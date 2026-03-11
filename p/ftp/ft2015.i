/******************************************************************************
**
** FT2015.I - Definicoes das tabelas temporarias tt-docto-bn, tt-it-docto-bn.
**
**
******************************************************************************/

/********************************* Produto EMS  ********************************/

def temp-table tt-docto-bn no-undo

        field cod-estabel                    like nota-fiscal.cod-estabel      
        field nr-nota                        like nota-fiscal.nr-nota-fis        
        field serie                          like nota-fiscal.serie
        
        field val-pct-desconto-tab-preco     as   decimal format "->>9.99"
        field des-pct-desconto-inform        as   char    format "x(50)"
        field val-pct-desconto-total         as   decimal format "->>9.9999"
        field val-desconto-total             as   decimal format ">>>,>>>,>>9.99"
        field val-pct-desconto-valor         as   decimal format "->>9.9999"
        field endereco_text                  as   char    format "x(2000)"

        index codigo is primary
              cod-estabel
              serie
              nr-nota.
             
def temp-table tt-it-docto-bn no-undo
     
        field cod-estabel          like it-nota-fisc.cod-estab     
        field nr-nota              like it-nota-fisc.nr-nota-fis     
        field nr-sequencia         like it-nota-fisc.nr-seq-fat      
        field serie                like it-nota-fisc.serie           
        field it-codigo            like it-nota-fisc.it-codigo

        field val-pct-desconto-tab-preco as decimal format "->>9.99"
        field des-pct-desconto-inform    as char    format "x(50)"
        field val-desconto-inform        as decimal format ">>>,>>>,>9.99"
        field val-pct-desconto-total     as decimal format "->>9.9999"
        field val-desconto-total         as decimal format ">>>,>>>,>>9.99"
        field val-pct-desconto-periodo   as decimal format "->9.999"
        field val-pct-desconto-prazo     as decimal format "->9.999"
        field val-desconto               as decimal extent 5 format ">>>,>>>,>>9.99999"

        index codigo is primary
              cod-estabel
              serie
              nr-nota
              nr-sequencia
              it-codigo.
