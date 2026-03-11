/******************************************************************************
**
**  Include.: FT0603.I3 - usado pelo programa FT0603 e FTAPI006.P
**
**  Data....: Maio de 1997
**
**  Objetivo: Variaveis para criacao do movimento pendente no CR
**
******************************************************************************/
def {1} workfile w-ped-ant
    field r-pedido     as rowid
    field r-titulo     as rowid extent 3
    field vl-antec     as decimal
    field vl-usado     as decimal.
def {1} workfile w-cr-ant
    field ep-codigo    like titulo.ep-codigo
    field cod-estabel  like titulo.cod-estabel
    field cod-esp      like titulo.cod-esp
    field nr-docto     like titulo.nr-docto
    field parcela      like titulo.parcela
    field vl-antec     as decimal
    field vl-usado     as decimal.
def {1} workfile doc-work
    field reg-doc      as rowid
    field referencia like doc-i-cr.referencia.
def workfile w-lin
    field r-lin as rowid.
def {1} var de-cdd-embarq-ini like nota-fiscal.cdd-embarq.
def {1} var de-cdd-embarq-fim like nota-fiscal.cdd-embarq init 999999999999999.
def {1} var da-emi-ini      like nota-fiscal.dt-emis-nota.                            
def {1} var da-emi-fim      like nota-fiscal.dt-emis-nota.
/*---- Variaveis para calcular a comissao pelo cadastro de comissoes ----*/
def {1} var c-reg-tab  like comissao.nome-ab-reg         init ?  extent 32.
def {1} var c-fam-tab  like comissao.fm-codigo           init ?  extent 32.
def {1} var i-rep-tab  like comissao.cod-rep             init ?  extent 32.
def {1} var i-cpg-tab  like comissao.cod-cond-pag        init ?  extent 32.
def {1} var i-grp-tab  like comissao.cod-gr-cli          init ?  extent 32.
def {1} var de-tot-aux like it-nota-fisc.vl-tot-item             no-undo.
def {1} var de-tot-it  like it-nota-fisc.vl-tot-item             no-undo.
def {1} var de-comis   as decimal  format '>>9.9999999'          no-undo.
def {1} var i-co-tab   as integer                                no-undo.
def {1} var i-tab      as integer                                no-undo.
/* */
def {1} var l-comissao as logical                                no-undo.
def {1} var l-achou    as logical                                no-undo.
def {1} var r-fat-dupl        as rowid no-undo.
def {1} var de-vl-vista       like doc-i-cr.total-movto.
def {1} var de-vl-prazo       like doc-i-cr.total-movto.
def {1} var de-titulo         like fat-duplic.vl-parcela.
def {1} var de-maior-tit      like fat-duplic.vl-parcela.
def {1} var de-conta          as decimal.
def {1} var de-despesa like fat-duplic.vl-despesa no-undo.
def {1} var de-fator1         as decimal no-undo.
def {1} var de-fator          as decimal no-undo.
def {1} var de-fator2         as decimal no-undo.
def {1} var c-nome-cliente    like emitente.nome-abrev no-undo.
def {1} var c-serie           like serie.serie no-undo.
def {1} var c-fr-val          as character no-undo.
def {1} var c-referencia      like lin-i-cr.referencia no-undo.                             
def {1} var c-conta           as character format 'x(15)' no-undo.
def {1} var i-nr-seq          like lin-i-cr.sequencia.
def {1} var i-seq-ct          like lin-i-cr.sequencia.
def {1} var i-tot-doc         as integer format '>,>>9'.
def {1} var i-not-doc         as integer.
def {1} var i-cont as integer.
def {1} var i-aux as integer no-undo.
def {1} var l-tem-repres      as logical no-undo.
def {1} var l-titulo          as logical no-undo.  

 {utp/ut-liter.i Num_Embarque * r} 
 put trim(return-value) space(1) de-cdd-embarq-ini. 
 
 {utp/ut-liter.i Data_EmissÆo * r} 
 put trim(return-value) space(1) da-emi-ini.
 
 {utp/ut-liter.i Referˆncia * r} 
 put trim(return-value) space(1) c-referencia.  

/* FT0603.I3 */

