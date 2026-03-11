/************************************************************************************
** Programa: INT110-11RP.P - Faturamento de Pedidos CD->Lojas do Tutorial/Sysfarma
**
** Geraá∆o Notas Fiscais SêRIE 11 
**
** Vers∆o: 12 - 08/11/2016 - Alessandro V Baccin
************************************************************************************/

/* include de controle de versao */
{include/i-prgvrs.i int110-11rp 2.12.01.AVB}

/* definiÁao das temp-tables para recebimento de parametros */
def temp-table tt-param no-undo
    field destino          as integer
    field arquivo          as char format "x(35)"
    field usuario          as char format "x(12)"
    field data-exec        as date
    field hora-exec        as integer
    field classifica       as integer
    field desc-classifica  as char format "x(40)"
    field serie            as char.

def temp-table tt-raw-digita
        field raw-digita	as raw.

def temp-table tt-ped-venda-imp         like ped-venda.
def temp-table tt-ped-item-imp          like ped-item  
    field numero-caixa like cst_ped_item.numero_caixa
    field numero-lote  like cst_ped_item.numero_lote
    /*
    field ct-codigo    like item.ct-codigo
    field sc-codigo    like item.sc-codigo
    */
    .
def temp-table tt-ped-repre-imp         like ped-repre.

&global-define log-erro     "ERRO"
&global-define log-erro-api "ERRO API"
&global-define log-adv      "ADVERT"
&global-define log-info     "INFO"

/* temp-tables das API's e BO's */
{method/dbotterr.i}

def var h-bodi317pr         as handle no-undo.
def var h-bodi317sd         as handle no-undo.
def var h-bodi317im1bra     as handle no-undo.
def var h-bodi317va         as handle no-undo.
def var h-bodi317in         as handle no-undo.
def var h-bodi317ef         as handle no-undo.
def var h-boin404te         as handle no-undo.
def var h-bodi515           as handle no-undo.

def var i-seq-wt-docto      as int    no-undo.
def var i-seq-wt-it-docto   as int    no-undo.
def var i-seq-wt-it-last    as int    no-undo.
def var c-ultimo-metodo-exec as char  no-undo.
def var l-proc-ok-aux        as log    no-undo.
def var l-movto-com-erro     as logical init no no-undo.
DEF VAR c-prog-log           AS CHAR NO-UNDO.

def temp-table tt-notas-geradas no-undo
    field rw-nota-fiscal   as rowid
    field nr-nota        like nota-fiscal.nr-nota-fis
    field seq-wt-docto   like wt-docto.seq-wt-docto.

def var c-docto-orig         as character.
def var c-obs-gerada         as character.

/* recebimento de parametros */
def input parameter raw-param as raw no-undo.
def input parameter table for tt-raw-digita.  

create tt-param.                    
raw-transfer raw-param to tt-param no-error. 
IF tt-param.arquivo = "" THEN 
    ASSIGN tt-param.arquivo = "int110-11.txt"
           tt-param.destino = 3
           tt-param.data-exec = TODAY
           tt-param.hora-exec = TIME.

ASSIGN tt-param.serie = "11"
       c-prog-log     = "int110-11rp.p".
                            
DO TRANS:
   FOR FIRST cst_mon_fat_serie query-tuning(no-lookahead):
   END.
   IF NOT AVAIL cst_mon_fat_serie THEN DO:
      CREATE cst_mon_fat_serie.
      ASSIGN cst_mon_fat_serie.serie_10 = ?
             cst_mon_fat_serie.serie_11 = ?
             cst_mon_fat_serie.serie_12 = ? 
             cst_mon_fat_serie.serie_13 = ? 
             cst_mon_fat_serie.serie_14 = ?. 
   END.
   ASSIGN cst_mon_fat_serie.serie_11 = YES.
   RELEASE cst_mon_fat_serie.
END.

{intprg/int110rp.i}

DO TRANS:
   FOR FIRST cst_mon_fat_serie QUERY-TUNING(no-lookahead):
   END.
   IF AVAIL cst_mon_fat_serie THEN DO:
      ASSIGN cst_mon_fat_serie.serie_11 = NO.
      RELEASE cst_mon_fat_serie.
   END.
END.

RETURN "OK"


