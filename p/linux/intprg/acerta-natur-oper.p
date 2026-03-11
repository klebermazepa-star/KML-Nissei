def temp-table tt-natur-oper
    field nat-operacao like natur-oper.nat-operacao
    field cd-situacao  like natur-oper.cd-situacao
    field tp-rec-desp  like natur-oper.tp-rec-desp
    field cod-cfop     like natur-oper.cod-cfop
    field cod-esp      like natur-oper.cod-esp.

INPUT FROM C:\Nass\nat-compl.csv CONVERT SOURCE "ISO8859-1".
 
REPEAT:  
   CREATE tt-natur-oper.
   IMPORT DELIMITER ";" tt-natur-oper.  
END. 
    
INPUT CLOSE.

for each tt-natur-oper where 
         tt-natur-oper.nat-operacao <> "":
                  
    find first natur-oper where
               natur-oper.nat-operacao = tt-natur-oper.nat-operacao no-error.
    if avail natur-oper then do:
       assign natur-oper.cd-situacao = tt-natur-oper.cd-situacao
              natur-oper.tp-rec-desp = tt-natur-oper.tp-rec-desp
              natur-oper.cod-cfop    = tt-natur-oper.cod-cfop
              natur-oper.cod-esp     = tt-natur-oper.cod-esp.
    end.
end.
