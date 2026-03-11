/********************************************************************************
***
*** cdp/cd0020.i - Gerar no extrato de vers∆o alguns pontos especificos 
***                que est∆o sendo executados. Utilizada nos seguintes 
***                programas:
***
***                - apapi001a.p
***                - crapi001a.p
***
********************************************************************************/

PROCEDURE pi-gerar-dados-extrato:
    
    def input param p-string as char no-undo.
            
    if  c-arquivo-log <> "" and c-arquivo-log <> ? then do:
    
        output to value(c-arquivo-log) append.
             /* Inicio -- Projeto Internacional */
             DEFINE VARIABLE c-lbl-liter-ponto-executado AS CHARACTER FORMAT "X(24)" NO-UNDO.
             {utp/ut-liter.i "Ponto_Executado" *}
             ASSIGN c-lbl-liter-ponto-executado = TRIM(RETURN-VALUE).
             put "     " + c-lbl-liter-ponto-executado + ": " p-string format "x(100)" skip.
        output close. 
    
    end.

END PROCEDURE.

/* Fim de Include */
