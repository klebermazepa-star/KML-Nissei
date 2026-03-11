/**********************************************************************
**
**   FT0603B.I - DEFINICAO DE TEMP-TABLE UTILIZADA PARA ARMAZENAR OS 
**               VALORES EXTRAÖDOS DA DPC ARG332, ESSA TEMP-TABLE 
**               AUXILIA NA CRIA€ÇO DA EXT-TIT-CR PARA O INTERNACIONAL
**
***********************************************************************/

def temp-table tt-tot-tit-ext no-undo 
    field referencia       like titulo.referencia
    field ep-codigo        like titulo.ep-codigo
    field cod-estabel      like titulo.cod-estabel
    field cod-estab-ems5   like titulo.cod-estabel
    field cod-esp          like titulo.cod-esp
    field serie            like titulo.serie
    field nr-docto         like titulo.nr-docto
    field cod-emitente     like titulo.cod-emitente
    field tot-saldo        like titulo.vl-saldo
    field de-vl-gravado    like titulo.vl-saldo
    field de-vl-no-gravado like titulo.vl-saldo
    field de-vl-exento     like titulo.vl-saldo
    field uf-entrega       like nota-fiscal.estado
    field tp-ret-gan       as   integer format ">>9"
    field tp-ret-iva       as   integer format ">>>9"
    field sequencia        as   integer
    index seq              is primary unique
          sequencia.
                 
/* FIM DO INCLUDE FT0603B.I */                 

          
