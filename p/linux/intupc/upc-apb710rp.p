/********************************************************************************
*******************************************************************************/
{include/i-prgvrs.i upc-apb710rp.p 2.06.00.001}  
{include/i_fnctrad.i}
/******************************************************************************
**
**       PROGRAMA: upc-apb710rp.p
**
**       DATA....: 01/2016
**
**       OBJETIVO: Integra‡Æo Inventario/Frente Loja/Datasul
**                 Ler as tabelas de Invent rio Balan‡o Frente de Loja , 
**                 gerar fichas de inventario no Datasul 
**
**       VERSAO..: 2.06.001
** 
******************************************************************************/

{include/i-rpvar.i}
{include/i-rpcab.i}

/* {utp/ut-glob.i} */ def new Global shared var c-seg-usuario        as char format "x(12)" no-undo.

{method/dbotterr.i} 
{cdp/cd0666.i}      /* Definicao da temp-table de erros */

define temp-table tt-param no-undo
    field destino          as integer
    field arquivo          as char format "x(35)":U
    field usuario          as char format "x(12)":U
    field data-exec        as date
    field hora-exec        as integer
    field classifica       as integer
    field desc-classifica  as char format "x(40)":U
    field modelo           AS char format "x(35)":U
    field l-habilitaRtf    as LOG
    FIELD r-recid          as recid
    FIELD l-ok             as logical.

def temp-table tt-raw-digita
    field raw-digita as raw.

DEF TEMP-TABLE tt-raw-param 
 FIELD raw-param  AS RAW.

def input parameter raw-param as raw no-undo.
def input parameter table for tt-raw-digita.

create tt-param.
raw-transfer raw-param to tt-param.

def var c-acompanha    as char    no-undo.
DEF VAR h-acomp        AS HANDLE  NO-UNDO.
DEF VAR c-nom-arq      AS CHAR    NO-UNDO.
DEF VAR c-data         AS CHAR    NO-UNDO.

find first param-estoq  no-lock no-error.
find first param-global no-lock no-error.
find first ems2log.empresa where 
           empresa.ep-codigo = param-global.empresa-prin no-lock no-error.

assign c-programa = "upc-apb710rp.p"
       c-versao   = "2.06"
       c-revisao  = "001"
       c-empresa  = empresa.razao-social.

find first tt-param no-lock no-error.

/* {include/i-rpout.i &page-size = 0 } */

output to value(tt-param.arquivo) page-size 0 convert target "iso8859-1".

{utp/ut-liter.i Fatura_Distribuidora *L}
assign c-titulo-relat = trim(return-value).
{utp/ut-liter.i APB *L}
assign c-sistema = trim(return-value).

run utp/ut-acomp.p persistent set h-acomp.
{utp/ut-liter.i Fatura *L}
run pi-inicializar in h-acomp (input return-value).

/* 

ITEM	POSI€ÇO	TIPO	TAMANHO	DECIMAL	DESCRI€ÇO



09	063 ? 069	N	007	000	
10	070 ? 080	N	011	000	Preencher com zeros
 1.3.    Registro trailer
 ITEM	POSI€ÇO	TIPO	TAMANHO	DECIMAL	DESCRI€ÇO
01	001 ? 007 	N	007	000	N£mero Sequencial
02	008 ? 009 	N	002	000	C¢digo fixo ?99? 
03	010 ? 016 	N	007	000	Quantidade de notas fiscais no arquivo
04	017 ? 080 	N	071	000	Preencher com zeros

*/

def var i-seq-reg      as integer.
DEF VAR c-tipo         AS CHAR.
DEF VAR c-titulo       AS CHAR.
DEF VAR c-nf-dev       AS CHAR. 
DEF VAR c-espaco       AS CHAR.      
def var i-nr-notas     as integer.
def var c-cgc          as char format "x(15)".
def var v_cod_id_feder like ems5.fornecedor.cod_id_feder no-undo. 
def var val_corr       like item_bord_ap.val_juros         no-undo. 
DEF VAR i-cod-tit-ap   AS INTEGER NO-UNDO.
          
find first bord_ap no-lock where
           recid(bord_ap) = tt-param.r-recid no-error.
if avail bord_ap 
then do:
   
    assign i-seq-reg  = 0
           i-nr-notas = 0. 
                               
    for each item_bord_ap no-lock of bord_ap
             break by item_bord_ap.num_seq_bord :
         
        if first(item_bord_ap.num_seq_bord)
        then do:
             
               find first ems5.fornecedor no-lock where
                                 fornecedor.cod_empresa    = bord_ap.cod_empresa and 
                                 fornecedor.cdn_fornecedor = item_bord_ap.cdn_fornecedor no-error.
               if avail fornecedor then 
                  assign v_cod_id_feder = ems5.fornecedor.cod_id_feder.                 
                 
               assign i-seq-reg = i-seq-reg + 1. 
                  
               /* Cabe‡alho */
                  
               put 
                   i-seq-reg  format "9999999" at 01
                   "01"                        at 08
                   DEC(v_cod_id_feder)   FORMAT "999999999999999" AT 10
                   bord_ap.dat_transacao format "99999999"        at 25
                   fill("0",48)          FORMAT "x(48)"           at 33 skip. 
       
        end.
               
        assign i-seq-reg  = i-seq-reg  + 1
               i-nr-notas = i-nr-notas + 1  
               val_corr   = item_bord_ap.val_juros + item_bord_ap.val_multa_tit_ap.
                  
        /* Detalhe */

        ASSIGN c-tipo = "/01"
               c-nf-dev = fill("0",07)
               c-espaco = fill("0",11).

        ASSIGN i-cod-tit-ap = INT(item_bord_ap.cod_tit_ap) NO-ERROR.
            
        IF ERROR-STATUS:ERROR 
        THEN DO:
           ASSIGN c-titulo = trim(string(item_bord_ap.cod_tit_ap)).
        END.
        ELSE DO:
          IF i-cod-tit-ap < 9999999 THEN
             ASSIGN c-titulo = trim(string(INT(item_bord_ap.cod_tit_ap),"9999999")).
          ELSE 
             ASSIGN c-titulo = trim(string(item_bord_ap.cod_tit_ap,"99999999999")).         
        END.

        put 
            i-seq-reg  format "9999999"                                                                                            AT 01
            "02"                                                                                                                   AT 08
            c-titulo   FORMAT "X(07)"                                                                                              AT 10
            c-tipo FORMAT "x(03)"                                                                                                  AT 17
            item_bord_ap.dat_pagto_tit_ap                                        format "99999999"                                 AT 20
           (item_bord_ap.val_pagto - (item_bord_ap.val_desc_tit_ap + item_bord_ap.val_abat_tit_ap)) * 100  format "9999999999999"  AT 28
           (item_bord_ap.val_desc_tit_ap + item_bord_ap.val_abat_tit_ap)                            * 100  format "99999999999"    AT 41
            val_corr                                                                                * 100  format "99999999999"    AT 52
            c-nf-dev FORMAT "x(07)"                                                                                                AT 63   /*   N£mero da Nota Fiscal de devolu‡Æo */
            c-espaco FORMAT "x(11)"                                                                                                AT 70 SKIP.      
      
        if last(item_bord_ap.num_seq_bord)
        then do:
            assign i-seq-reg = i-seq-reg + 1.
                               
             /* Rodape */
                       
             put 
                 i-seq-reg  format "9999999"               at 01
                 "99"                                      at 08
                 i-nr-notas format "9999999"               at 10
                 fill("0",64) FORMAT "x(64)"               at 17 skip.   
       
      
         
        end.
             
    end.
end.

{include/i-rpclo.i &page-size = 0}   
 
run pi-finalizar in h-acomp.

return "OK":U.


