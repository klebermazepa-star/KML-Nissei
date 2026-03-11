/**
*
* FINALIDADE:
*   executa programas windows, usando o winexec da kernel32.dll.
*
* NOTAS:
*  - i-style: 1 - abre normal
*             2 - minimizado - com foco (foca na barra)
*             3 - maximizado
*             4 - minimizado sem foco (foco fica na rotina chamadora)
*
* VERSOES:
*   05/08/2005, Leandro Dalle Laste,
*   - criacao
*
*/

def input param c-program as character no-undo.
def input param i-style   as integer   no-undo.
                                                 
/* define procedure externa para execucao do programa */
procedure WinExec external "kernel32.dll":
  def input param prg_name  as character.
  def input param prg_style as short.
end procedure.

/* executa */
run winExec(input c-program, input i-style).

return.
