/*------  PESQUISA A DESCRICAO DO PRODUTO  ------ */

def param buffer bNota-fiscal for nota-fiscal.
def param buffer bIt-nota-fisc for it-nota-fisc.
def param buffer bItem for item.
def output param cDescItem as char no-undo.

find narrativa of bItem
    no-lock no-error.

if bItem.ind-imp-desc = 1 then
    assign cDescItem = bItem.desc-item.
else
if bItem.ind-imp-desc = 8 then do:
  find item-cli
      where item-cli.nome-abrev = bNota-fiscal.nome-ab-cli
        and item-cli.it-codigo  = bIt-nota-fisc.it-codigo
      no-lock no-error.

  assign cDescItem = bItem.desc-item + " " + 
                     if avail item-cli then
                         trim(substring(item-cli.narrativa, 1, 27))
                     else
                         ''.
end.
else
if bItem.ind-imp-desc = 9 then do:
  find nar-it-nota
      where nar-it-nota.cod-estabel  = bIt-nota-fisc.cod-estabel
        and nar-it-nota.serie        = bIt-nota-fisc.serie
        and nar-it-nota.nr-nota-fis  = bIt-nota-fisc.nr-nota-fis
        and nar-it-nota.nr-sequencia = bIt-nota-fisc.nr-seq-fat
        and nar-it-nota.it-codigo    = bIt-nota-fisc.it-codigo no-lock no-error.

   assign cDescItem = bItem.desc-item + " " 
                      + if  avail nar-it-nota then
                            trim(substring(nar-it-nota.narrativa,1,27))
                        else ''.
end.
else
if bItem.ind-imp-desc = 10 then
  assign cDescItem = bItem.desc-item + " " +
                     if avail narrativa then
                         trim(substring(narrativa.descricao,1,27))
                     else
                         ''.
else
if (bItem.ind-imp-desc = 2 or bItem.ind-imp-desc = 5 or bItem.ind-imp-desc = 6)
   and avail narrativa then do:
      assign cDescItem = if bItem.ind-imp-desc = 2 then
                             bItem.desc-item + " " + trim(substring(narrativa.descricao,1,38))
                         else if bItem.ind-imp-desc = 5 then 
                             trim(narrativa.descricao)
                         else if bItem.ind-imp-desc = 6 then
                             trim(entry(1,substring(narrativa.descricao,1,80),chr(10)))
                         else
                             ''.
end.
else
if bItem.ind-imp-desc = 3 then do:
  find item-cli
      where item-cli.nome-abrev = bNota-fiscal.nome-ab-cli
        and item-cli.it-codigo  = bIt-nota-fisc.it-codigo
      no-lock no-error.
  assign cDescItem = bItem.desc-item + " " +
                     if avail item-cli then
                         trim(substring(item-cli.narrativa,1,380))
                       else
                           ''.
end.
else
if bItem.ind-imp-desc = 4 or bItem.ind-imp-desc = 7 then do:
  find nar-it-nota
      where nar-it-nota.cod-estabel  = bIt-nota-fisc.cod-estabel
        and nar-it-nota.serie        = bIt-nota-fisc.serie
        and nar-it-nota.nr-nota-fis  = bIt-nota-fisc.nr-nota-fis
        and nar-it-nota.nr-sequencia = bIt-nota-fisc.nr-seq-fat
        and nar-it-nota.it-codigo    = bIt-nota-fisc.it-codigo
       no-lock no-error.

  if bItem.ind-imp-desc = 4 then 
     assign cDescItem = bItem.desc-item + " " +
                        if avail nar-it-nota then
                            trim(substring(nar-it-nota.narrativa,1,380))
                        else
                            ''.
  else
  if bItem.ind-imp-desc = 7 then
     assign cDescItem = if avail nar-it-nota then
                            trim(substring(nar-it-nota.narrativa,1,380))
                        else
                            ''.
end.

return 'ok':u.
