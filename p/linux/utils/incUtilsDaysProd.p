/* incremente iDays uteis em dSource, de acordo com o calen-coml 

  27/06/2006, Leandro Dalle Laste, Datasul Paranaense, 
  -  Criacao
*/    
    
    def input param cEstab   as char        no-undo.
    def input-output param dSource as date  no-undo.
    def input        param iDays as integer no-undo.
    
    def var i-cont as integer no-undo.

    do while i-cont < iDays:

        assign dSource = dSource + 1.

        if can-find(calen-prod
                    where calen-prod.cod-estabel = cEstab
                      and calen-prod.data        = dSource
                      and calen-prod.tipo-dia    = 1) then /* dia util */
            assign i-cont = i-cont + 1.
    end.

    return 'ok':u.

/* end */

