/*******************************************************************
  Verifica se a funcao EMS2-UNIDADE-NEGOCIO esta definida
*******************************************************************/

def var l-unidade-negocio as log no-undo.
def var l-dis-unid-negoc  as log no-undo.
def var l-mat-unid-negoc  as log no-undo.

if can-find (first funcao where
                   funcao.cd-funcao = "ems2-unidade-negocio":U and
                   funcao.ativo     = yes) then
    assign l-unidade-negocio = yes.

find first para-dis no-lock no-error.
if avail para-dis then
    assign l-dis-unid-negoc = para-dis.log-unid-neg.

find first param-mat no-lock no-error.
if avail param-mat then
    assign l-mat-unid-negoc = param-mat.ind-unid-neg.

