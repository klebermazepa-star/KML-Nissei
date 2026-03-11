/********************************************************************************
**
*******************************************************************************/
{include/i-prgvrs.i int031rp 2.06.00.001}  
/*******************************************************************************
**
**       Programa: int031rp
**
**       Data....: Junho de 2016
**
**       Autor...: ResultPro
**
**       Objetivo: Gera informa‡äes para os registros C400 SPED Fiscal.     
**                 Conforme Layout 400 cadastrado no Lf0214                      
**                 
**
*******************************************************************************/

{cdp/cdcfgmat.i}

define temp-table tt-param
    field destino          as integer
    field arquivo          as char
    field usuario          as char format "x(12)"
    field data-exec        as date
    field hora-exec        as integer
    field c-programa       as char
    field c-diretorio      as char format "x(100)"
    field c-estab-ini      like item.cod-estabel
    field c-estab-fim      like item.cod-estabel
    field dt-trans-ini     as date format "99/99/9999"
    field dt-trans-fim     as date format "99/99/9999"
    field i-cdn-layout     like clf-import-layout.cdn-layout
    field rs-atualiza      as integer 
    field it-recarga       like item.it-codigo
    field dir-export       as char.

define temp-table tt-digita
    field cod-estabel           as character format "x(3)"
    field nome                  as character format "x(40)"
    field data-ini              like param-estoq.ult-per-fech
    field data-fim              like param-estoq.ult-per-fech
    field ult-per-fech          like param-estoq.ult-per-fech
    field l-processou           like item.loc-unica
    index codigo cod-estabel.

define temp-table tt-tipo-operacao
    field nat-oper      like natur-oper.nat-operacao
    field cod-model-cfe as   char  format "x(02)".

def temp-table tt-raw-digita
    field raw-digita as raw.

def input parameter raw-param as raw no-undo.
def input parameter table for tt-raw-digita.

create tt-param.
raw-transfer raw-param to tt-param.          

find first param-global no-lock no-error.
find first param-estoq no-lock no-error.

DEF TEMP-TABLE tt-estabelec
    FIELD cod-estabel  LIKE estabelec.cod-estabel.

if available param-global then do:
    find ems2mult.empresa where 
               empresa.ep-codigo = param-global.empresa-prin no-lock no-error.
end.     

FOR EACH  estabelec 
    WHERE estabelec.cod-estabel >= tt-param.c-estab-ini
      AND estabelec.cod-estabel <= tt-param.c-estab-fim NO-LOCK:

    CREATE tt-estabelec.
    ASSIGN tt-estabelec.cod-estabel = estabelec.cod-estabel.

END.

FOR each natur-oper where
         natur-oper.cod-model-nf-eletro = "55" /*"59"*/ AND /* SUBSTR(natur-oper.char-2,120,2) = "59" */   
         natur-oper.tipo = 2   :

    CREATE tt-tipo-operacao.
    ASSIGN tt-tipo-operacao.nat-oper      = natur-oper.nat-operacao
           tt-tipo-operacao.cod-model-cfe = natur-oper.cod-model-nf-eletro. /* SUBSTR(natur-oper.char-2,120,2) */

END. 

/***** Saidas *********/

run intprg/int031rpa.p (input raw-param,
                        INPUT-OUTPUT TABLE tt-estabelec,
                        input-output table tt-tipo-operacao).

return "OK".
