/********************************************************************************
** Copyright DATASUL S.A. (1997)
** Todos os Direitos Reservados.
**
** Este fonte e de propriedade exclusiva da DATASUL, sua reproducao
** parcial ou total por qualquer meio, so podera ser feita mediante
** autorizacao expressa.
*******************************************************************************/
{include/i-prgvrs.i NICS0202RP 2.00.00.000}  /*** 020016 ***/

/* ---------------------[ VERSAO ]-------------------- */
/******************************************************************************
**
**   Programa: NICS0202RP.P
**
**   Objetivo: Listagem dos Custos dos Itens.
**
****************************************************************************/
define temp-table tt-param
    field destino          as integer
    field arquivo          as char
    field usuario          as char
    field data-exec        as date
    field hora-exec        as integer
    field classifica       as integer
    field i-ge-codigo-ini      like item.ge-codigo
    field i-ge-codigo-fim      like item.ge-codigo  
    field c-fm-codigo-ini      like item.fm-codigo     
    field c-fm-codigo-fim      like item.fm-codigo    
    field c-it-codigo-ini      like item.it-codigo   
    field c-it-codigo-fim      like item.it-codigo     
    field c-descricao-1-ini    like item.desc-item   
    field c-descricao-1-fim    like item.desc-item
    field c-inform-compl-ini   like item.inform-compl  
    field c-inform-compl-fim   like item.inform-compl    
    field da-implant-ini       like item.data-implant       
    field da-implant-fim       like item.data-implant 
    field rs-item              as integer format ">9"
    field desc-classifica      as char format "x(40)"
    field cod-estabel          like estabelec.cod-estabel
    field rs-preco             as integer format ">9"
    field descricao            like estabelec.nome.   

def temp-table tt-raw-digita
    field raw-digita as raw.

def input parameter raw-param as raw no-undo.
def input parameter table for tt-raw-digita.

{cdp/cdcfgman.i}

create tt-param.
raw-transfer raw-param to tt-param.

def buffer b-item for item.
def buffer b-item-estab for item-estab.
&IF DEFINED (bf_man_custeio_item) &THEN
    def buffer b-item-uni-estab for item-uni-estab.
&ENDIF

def workfile w-mat
    field it-codigo as character.

def var i-nr-niveis     as integer no-undo init 19.
def var i-nivel         as integer no-undo.
def var c-item          as char format "x(12)" extent 20 no-undo.
def var r-end-estr      as rowid extent 20 no-undo.
def var i-cont as integer no-undo.
def var l-primeira  as logical format "Primeira/Segunda" init yes no-undo.

def var i-grupo-aux like item.ge-codigo no-undo.
def var i-grupo-ini as integer format "99" init 0 no-undo.
def var i-grupo-fim as integer format "99" init 99 no-undo.
def var c-familia-aux like item.fm-codigo no-undo.
def var c-familia-ini as character format "x(8)" init "" no-undo.
def var c-familia-fim as character format "x(8)" init "ZZZZZZZZ" no-undo.
def var c-item-ini as character format "x(16)" init "" no-undo.
def var c-item-fim as character format "x(16)" init "ZZZZZZZZZZZZZZZZ" no-undo.
def var c-descr-ini as character format "x(18)" init "" no-undo.
def var c-descr-fim as character format "x(18)" init "ZZZZZZZZZZZZZZZZZZ" no-undo.
def var c-inf-ini as character format "x(16)" init "" no-undo.
def var c-inf-fim as character format "x(16)" init "ZZZZZZZZZZZZZZZZ" no-undo.
def var d-data-ini as date format "99/99/9999" init &IF "{&ems_dbtype}":U = "MSS":U &THEN 01/01/1800 &ELSE 01/01/0001 &ENDIF no-undo.
def var d-data-fim as date format "99/99/9999" init 12/31/9999 no-undo.
def var c-descricao as character format "x(60)" label "Descricao" no-undo.

def var c-opcao-obs as character init "1" no-undo.
def var c-opcao-cha as character init "1" no-undo.
def var c-obs as char format "x(01)".
def var c-cha as char format "x(01)".
def var c-gr-estoq as char format "x(22)". 
def var c-fam as char format "x(13)".
def var c-desc as char format "x(23)".
def var h-acomp as handle no-undo. 
def var c-parametros    as char format "x(10)".
def var c-selecao       as char format "x(07)".
def var c-destino       as char format "x(10)" no-undo.
def var c-arquivo       as char format "x(40)" no-undo.
def var c-liter-impres  as char format "x(09)" no-undo.
def var c-liter-destin  as char format "x(08)" no-undo.
def var c-liter-usuario as char format "x(08)" no-undo.
def var c-classificacao as char format "x(16)" no-undo.

def var de-vl-unit-mat-1   as decimal.
def var de-vl-unit-mat-2   as decimal.
def var de-vl-unit-mat-3   as decimal.
def var de-vl-unit-mob-1   as decimal.
def var de-vl-unit-mob-2   as decimal.
def var de-vl-unit-mob-3   as decimal.
def var de-vl-unit-ggf-1   as decimal.
def var de-vl-unit-ggf-2   as decimal.
def var de-vl-unit-ggf-3   as decimal.
def var da-tp-preco        as date format "99/99/9999".
def var c-tipo-item        as char format "x(25)" no-undo.
def var c-preco            as char format "x(10)" no-undo.
DEF VAR de-tot-vl-item     AS DEC FORMAT "->,>>>,>>9.9999" NO-UNDO.
DEF VAR de-medio-31-07     AS DEC FORMAT "->>>,>>9.9999"   NO-UNDO.
DEF VAR de-medio-31-08     AS DEC FORMAT "->>>,>>9.9999"   NO-UNDO.
DEF VAR c-tp-controle      AS CHAR FORMAT "x(14)" NO-UNDO.
DEF VAR c-obsoleto         AS CHAR FORMAT "x(28)" NO-UNDO.

form item.it-codigo 
     item.desc-item
     item.un     
     SPACE(5)
     item.preco-ul-ent    format "->>>,>>9.9999"     
     SPACE(2)
     item.data-ult-ent    
     /*item.preco-repos     format "->>>,>>9.9999"  
     item.data-ult-rep*/   
     item.preco-base      format "->>>,>>9.9999"  
     item.data-base       
     SPACE(4)
     de-medio-31-07       COLUMN-LABEL "MÇdio 31/07/2016"
     SPACE(4)
     de-medio-31-08       COLUMN-LABEL "MÇdio 31/08/2016"
     c-tp-controle        COLUMN-LABEL "Tipo Controle"
     c-obsoleto           COLUMN-LABEL "Cod. Obsoleto"
     /*de-tot-vl-item       COLUMN-LABEL "MAT + MOB + GGF"
     da-tp-preco          COLUMN-LABEL "Data MÇdio"*/ 
     with down no-box NO-LABELS width 255 STREAM-IO frame f-detalhe-255.     

{utp/ut-liter.i CLASSIFICAÄ«O mcs}
assign c-classificacao = trim(return-value).

{utp/ut-liter.i SELEÄ«O mcs r}
assign c-selecao = trim(return-value).  

{utp/ut-liter.i PAR∂METROS mcs r}
assign c-parametros = trim(return-value).

{utp/ut-liter.i Usu†rio * r}
assign c-liter-usuario = trim(return-value) + ":".

{utp/ut-liter.i Destino * r}
assign c-liter-destin = trim(return-value) + ":".

{utp/ut-liter.i IMPRESS«O * r}
assign c-liter-impres = trim(return-value).                        

if tt-param.rs-item = 1 then do:
   {utp/ut-liter.i Todos mcs l}
   assign c-tipo-item = trim(return-value).  
end.

if tt-param.rs-item = 2 then do:
   {utp/ut-liter.i Somente_os_Ativos mcs l}
   assign c-tipo-item = trim(return-value).  
end.

if tt-param.rs-item = 3 then do:
   {utp/ut-liter.i Somente_os_Obsoletos mcs l}
   assign c-tipo-item = trim(return-value).  
end.

if tt-param.rs-preco = 1 then do:
   /*{utp/ut-field.i mgind item-estab mensal-ate 1}
   assign da-tp-preco:label in frame f-detalhe-255 = trim(return-value).*/

   &IF DEFINED (bf_man_custeio_item) &THEN
      {utp/ut-liter.i Batch mcs l}
      assign c-preco = trim(return-value).   
   &ELSE
      {utp/ut-liter.i Mensal mcs l}
      assign c-preco = trim(return-value).  
   &ENDIF
end.

if tt-param.rs-preco = 2 then do:
   /*{utp/ut-field.i mgind item-estab on-line-ate 1}
   assign da-tp-preco:label in frame f-detalhe-255 = trim(return-value).*/

   {utp/ut-liter.i On-Line mcs l}
   assign c-preco = trim(return-value).  
end.

if tt-param.rs-preco = 3 then do:
   /*{utp/ut-field.i mgind item-estab padrao-ate 1}
   assign da-tp-preco:label in frame f-detalhe-255 = trim(return-value).*/

   {utp/ut-liter.i Padr∆o mcs l}
   assign c-preco = trim(return-value).  
end.

create tt-param.
raw-transfer raw-param to tt-param.    

{include/i-rpvar.i}

assign c-programa = "NICS0202"
       c-versao   = "0.00"
       c-revisao  = "000".

assign i-grupo-ini = i-ge-codigo-ini     
       i-grupo-fim = i-ge-codigo-fim      
       c-familia-ini = c-fm-codigo-ini      
       c-familia-fim = c-fm-codigo-fim      
       c-item-ini    = c-it-codigo-ini      
       c-item-fim    = c-it-codigo-fim      
       c-descr-ini   = c-descricao-1-ini    
       c-descr-fim   = c-descricao-1-fim    
       c-inf-ini     = c-inform-compl-ini   
       c-inf-fim     = c-inform-compl-fim   
       d-data-ini    = da-implant-ini       
       d-data-fim    = da-implant-fim .   

assign c-obs =  string(rs-item)
       c-cha =  string(tt-param.classifica).
assign c-opcao-obs = substring(c-obs,1,1) 
       c-opcao-cha = substring(c-cha,1,1).

find first param-global no-lock no-error.
find first param-estoq no-lock no-error.

if available param-global then
   c-empresa  = grupo.
else do:
   run utp/ut-msgs.p (input "show",
                   input  16,
                   input "").
   return.
end.

if not available param-estoq then do:
   run utp/ut-msgs.p (input "show",
                      input  1059,
                      input "").
   return.
end. 

{utp/ut-liter.i Custos_dos_Itens mcs}
assign c-titulo-relat = return-value.

ASSIGN c-sistema = "CUSTOS".

run utp/ut-trfrrp.p (input frame f-detalhe-255:handle).

/*{include/i-rpcab.i}*/
{include/i-rpc255.i}
{include/i-rpout.i}      

run utp/ut-acomp.p persistent set h-acomp. 

{utp/ut-liter.i Listagem_dos_Custos_dos_Itens mcs}
run pi-inicializar in h-acomp (return-value).

if c-opcao-cha = "1" then do:
   {intprg/nics0202.i1}
end.
if c-opcao-cha = "2" then do:
   {intprg/nics0202.i2}
end.
if c-opcao-cha = "3" then do:
   {intprg/nics0202.i3}
end.
if c-opcao-cha = "4" then do:
   {intprg/nics0202.i4}
end.

/*page.

disp c-selecao          no-label skip(1)
     i-ge-codigo-ini 
     i-ge-codigo-fim    no-label
     c-fm-codigo-ini
     c-fm-codigo-fim    no-label    
     c-it-codigo-ini
     c-it-codigo-fim    no-label
     c-descricao-1-ini  format "x(13)"
     c-descricao-1-fim  format "x(13)" no-label
     c-inform-compl-ini
     c-inform-compl-fim no-label
     da-implant-ini 
     da-implant-fim     no-label
     with side-labels frame f-selecao.

disp c-classificacao           no-label
     tt-param.desc-classifica  no-label  
     c-parametros              no-label  
     tt-param.rs-item
     c-tipo-item               
     tt-param.rs-preco
     c-preco                    
     tt-param.cod-estabel  
     tt-param.descricao        no-label
     with side-labels frame f-param.

assign c-destino = {varinc/var00002.i 04 tt-param.destino}
       c-arquivo = tt-param.arquivo.    
                                                                     
 disp skip(3)  
      c-liter-impres           at 03 skip(1)
      c-liter-destin           at 15  
      c-destino                space(1) "- " 
      c-arquivo
      c-liter-usuario          at 15 
      tt-param.usuario 
      with width 132 no-labels no-box frame f-imp-param stream-io.*/           

run pi-finalizar in h-acomp.   

{include/i-rpclo.i}            

return "OK".
