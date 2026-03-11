/* incremente iDays uteis em dSource, de acordo com o calen-coml 

  12/07/2005, Leandro Dalle Laste, Datasul Paranaense, 
  -  Criacao
*/    
    
    def input param iEmpresa as CHAR     no-undo.
    def input param cEstab   as char        no-undo.
    def input-output param dSource as date  no-undo.
    def input        param iDays as integer no-undo.
    
    def var i-cont as integer no-undo.

    do while i-cont < iDays:

        assign dSource = dSource + 1.

        find calen-coml
            where calen-coml.ep-codigo   = iEmpresa
              and calen-coml.cod-estabel = cEstab
              and calen-coml.data        = dSource
            no-lock no-error.

        if avail calen-coml then do: 
            if calen-coml.tipo-dia = 1 then do: /* dia util */
                assign i-cont = i-cont + 1.
            end.
        end.

        else do: 

            run utp/ut-msgs.p (input 'show', input 133, input string(dSource)).

            assign dSource = ?.

            return 'nok':u.

        end.
    end.

    return 'ok':u.

/* end */

