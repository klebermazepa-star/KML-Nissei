/***
*
* PROGRAMA:
*   utils/digSave.i
*
* FINALIDADE:
*   salvar digitacao de browse nao padrao (qdo tem 2 browsers, por ex)
* 
* NOTA:
*   {1} = tt-digita
*   {2} = br-digita
*
* VERSAO ATUAL:
*   $Version: 0 
*
* VERSOES:
*/

define var r-tt-digita as rowid no-undo.

system-dialog get-file c-arq-digita
   filters "*.dig" "*.dig",
           "*.*" "*.*"
   ask-overwrite 
   default-extension "*.dig"
   save-as             
   create-test-file
   use-filename
   update l-ok.

if avail {1} then assign r-tt-digita = rowid({1}).

if l-ok then do:
    output to value(c-arq-digita).
    for each {1}:
        export {1}.
    end.
    output close. 
    
    reposition {2} to rowid(r-tt-digita) no-error.
end.

/* digSave.i */
