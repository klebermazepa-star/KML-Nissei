/***
*
* PROGRAMA:
*   utils/digRestore.i
*
* FINALIDADE:
*   restaurar digitacao de browse nao padrao (qdo tem 2 browsers, por ex)
* 
* NOTA:
*   {1} = tt-digita
*   {2} = br-digita
*   {3} = bt-alterar
*   {4} = bt-retirar
*   {5} = bt-salvar
*
* VERSAO ATUAL:
*   $Version: 0 
*
* VERSOES:
*/

system-dialog get-file c-arq-digita
   filters "*.dig" "*.dig",
           "*.*" "*.*"
   default-extension "*.dig"
   must-exist
   use-filename
   update l-ok.

if l-ok then do:

    empty temp-table {1}.
    
    input from value(c-arq-digita) no-echo.
    repeat:             
        create {1}.
        import {1}.
    end.    
    input close. 
    
    delete {1}.
    
    open query {2} for each {1}.
    
    if avail {1} then
        assign {3}:sensitive in frame f-pg-dig = yes
               {4}:sensitive in frame f-pg-dig = yes
               {5}:sensitive in frame f-pg-dig  = yes.
    else
        assign {3}:sensitive in frame f-pg-dig = no
               {4}:sensitive in frame f-pg-dig = no
               {5}:sensitive in frame f-pg-dig = no.
end.
/* digRestore.i */

