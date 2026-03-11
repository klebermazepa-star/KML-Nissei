/* efetua a validacao do usuario de acordo com o grupo passado como parametro 
   se o usuario atual pertence ao grupo informado, ok direto
   se nao, solicita senha de um usuario do grupo */

define input  parameter c-grupo   as char    no-undo.
define output parameter c-usuario as char    no-undo.

def shared var c-seg-usuario as char no-undo.

def var c-user-list as char    no-undo.
def var l-ok        as logical no-undo.

assign c-usuario = c-seg-usuario
       l-ok      = false.

/* verifica se o usuario atual tem direito */
assign l-ok = can-find(first usuar_grp_usuar
                       where usuar_grp_usuar.cod_grp_usuar = c-grupo
                         and usuar_grp_usuar.cod_usuario = c-usuario).

if not l-ok then do:
    /* solicita um usuario com direito */
    for each usuar_grp_usuar
        where usuar_grp_usuar.cod_grp_usuar = c-grupo
        no-lock:

        if c-user-list <> '' then
            assign c-user-list = c-user-list + ",".

        assign c-user-list = usuar_grp_usuar.cod_usuario.
    end.

    run btb/btb910zc.p (input  c-user-list,
                        input  true,
                        input  c-seg-usuario,
                        output c-usuario).

    assign l-ok = return-value = "ok":u and c-usuario <> ?.
end.

if not l-ok then do:
    assign c-usuario = ?.

    return 'nok':u.
end.

return 'ok':u.

/* end */
