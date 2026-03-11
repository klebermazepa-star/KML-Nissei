/********************************************************************************
** Copyright DATASUL S.A. (1997)
** Todos os Direitos Reservados.
**
** Este fonte e de propriedade exclusiva da DATASUL, sua reproducao
** parcial ou total por qualquer meio, so podera ser feita mediante
** autorizacao expressa.
*******************************************************************************/
{include/i-prgvrs.i BODI018 2.00.00.011}  /*** 010011 ***/
/*
**  BODI018.P
**
**  cond-ped - Condicoes de Pagamento do Pedido de Venda
**
**  Ultima altera‡Æo : 31/03/99 - GeraBO
*/
 
/** necessário para chamada da api pdapi152.p */
{cdp/cdapi300.i1}  /* Temp-Table de Erros   */
{pdp/pdapi151.i}   /* Temp-Table Ped-Venda   */ 
{pdp/pdapi151.i1}  /* Temp-Table Ped-Item    */                     
{pdp/pdapi151.i2}  /* Temp-Table Ped-Repre   */                     
{pdp/pdapi151.i3}  /* Temp-Table Ped-Ent     */
{pdp/pdapi151.i4}  /* Temp-Table Con-Pges    */    
{pdp/pdapi151.i5}  /* Temp-Table Ped-Antecip */
{pdp/pdapi151.i6}  /* Temp-Table Pd-vendor   */
{cdp/cdapi150.i3}  /* Temp-Table de Versão   */
{cdp/cdapi150.i4}  /* Temp-Table de Erros    */
{utp/ut-glob.i}
def var i-cod-maq-origem like tt-erros-geral.cod-maq-origem no-undo.
def var i-num-processo   like tt-erros-geral.num-processo no-undo.
/**/
&scoped-define BOVERSION 1.1
&scoped-define FIRST-TABLE-IN-QUERY cond-ped
&scoped-define QUERY-NAME qTable
&scoped-define TABLE-NAME cond-ped
 
{include/boini.i}
 
 
{dibo/bodi018.i RowObject}
 
DEFINE QUERY {&QUERY-NAME} for {&TABLE-NAME} scrolling.
 
procedure setConstraint1:
	def input parameter r-chave as rowid.
	find ped-venda no-lock where rowid(ped-venda) = r-chave no-error.
 
end procedure.
 
procedure openQuery:
    define input parameter i-abertura as integer no-undo.
    case i-abertura:
        when 1 then
            open query {&QUERY-NAME} for each {&TABLE-NAME} of ped-venda no-lock.
    end case.
    assign l-query = true
           i-bo-query = i-abertura.
end procedure.
 
{include/bostrmet.i}
{include/boendmet.i}
{include/bocomver.i}
{include/bogetver.i}
{include/bonav.i}
{include/bofind.i}
{include/bosetcur.i}
{include/bogetcur.i}
{include/bosersen.i}
{include/boprebro.i}
/*
{include/boexecre.i}
*/
{include/boexeupt.i}
{include/boexedel.i}
/*
{include/bovalupt.i}
{include/bovaldel.i}
*/ 
procedure initializeValidate:
    /*
    **  Inicializa Validate
    */
 
    run startMethod ("initializeValidade":U).
 
    run endMethod   ("initializeValidade":U).
end procedure.
 
procedure findCh_cond_ped:
    /*
    **  Procura pelo indice, caso nao ache,
    **  retorna mensagem de erro padrao do EMS.
    */
    run startMethod ("find:U").
    def input parameter i-nr-pedido as inte no-undo.
    def input parameter i-nr-sequencia as inte no-undo.
    def output parameter c-return as char no-undo.
 
    find cond-ped where
        cond-ped.nr-pedido = i-nr-pedido
        and cond-ped.nr-sequencia = i-nr-sequencia
        no-lock no-error.
    if not avail {&TABLE-NAME} then do:
        {utp/ut-table.i movdis {&TABLE-NAME} 1}
        run utp/ut-msgs.p (input "msg",
                           input 2,
                           input return-value).
        assign c-return = return-value.
    end.
    else do:
       run setCurrent.
    end.
    run endMethod ("find":U).
end procedure.
 
procedure validateFields:
    /*
    **  Valida Fields
    */
    find first rowObject
        no-lock no-error.
 
    run startMethod ("validateFields":U).
    if rowObject.cod-vencto = ? then do:
        assign i-seq-erro = i-seq-erro + 1.
        run utp/ut-msgs.p (input "msg",
                           input 190,
                           input "").
        create tt-bo-erro.
        assign tt-bo-erro.i-sequen     = i-seq-erro
               tt-bo-erro.cd-erro      = 190
               tt-bo-erro.mensagem     = return-value.
    end.
 
    if rowObject.nr-dias-venc = ? then do:
        assign i-seq-erro = i-seq-erro + 1.
        run utp/ut-msgs.p (input "msg",
                           input 190,
                           input "").
        create tt-bo-erro.
        assign tt-bo-erro.i-sequen     = i-seq-erro
               tt-bo-erro.cd-erro      = 190
               tt-bo-erro.mensagem     = return-value.
    end.
 
    if rowObject.nr-pedido = ? then do:
        assign i-seq-erro = i-seq-erro + 1.
        run utp/ut-msgs.p (input "msg",
                           input 190,
                           input "").
        create tt-bo-erro.
        assign tt-bo-erro.i-sequen     = i-seq-erro
               tt-bo-erro.cd-erro      = 190
               tt-bo-erro.mensagem     = return-value.
    end.
 
    if rowObject.nr-sequencia = ? then do:
        assign i-seq-erro = i-seq-erro + 1.
        run utp/ut-msgs.p (input "msg",
                           input 190,
                           input "").
        create tt-bo-erro.
        assign tt-bo-erro.i-sequen     = i-seq-erro
               tt-bo-erro.cd-erro      = 190
               tt-bo-erro.mensagem     = return-value.
    end.
 
    if rowObject.perc-pagto = ? then do:
        assign i-seq-erro = i-seq-erro + 1.
        run utp/ut-msgs.p (input "msg",
                           input 190,
                           input "").
        create tt-bo-erro.
        assign tt-bo-erro.i-sequen     = i-seq-erro
               tt-bo-erro.cd-erro      = 190
               tt-bo-erro.mensagem     = return-value.
    end.
 
    if rowObject.vl-pagto = ? then do:
        assign i-seq-erro = i-seq-erro + 1.
        run utp/ut-msgs.p (input "msg",
                           input 190,
                           input "").
        create tt-bo-erro.
        assign tt-bo-erro.i-sequen     = i-seq-erro
               tt-bo-erro.cd-erro      = 190
               tt-bo-erro.mensagem     = return-value.
    end.
 
    run endMethod ("validateFields":U).
 
end procedure.
procedure validateUpdate:
    /*
    **  Valida Update de ped-venda
    **  Pedido de Venda
    */
    def input parameter table for RowObject.
    def input parameter r-chave as rowid no-undo.
    def input parameter c-tipo as char. 
    def output parameter table for tt-bo-erro.
    run InitializeValidate.
    for each tt-bo-erro:
        delete tt-bo-erro.
    end.
    run validateFields.
    run condPedCallApi (input 2, input c-tipo).
    find first tt-bo-erro
        no-lock no-error.
    if not avail tt-bo-erro then do:
        find first rowObject no-error. 
        find {&TABLE-NAME} where
            rowid({&TABLE-NAME}) = r-chave
            exclusive-lock no-error.
        run executeUpdate.
    end.
end procedure.

procedure validateDelete:
    /*
    **  Valida Delete de um ped-venda
    **  Antecipações do Pedido de Venda
    */
    def input-output parameter r-chave as rowid.
    def output parameter table for tt-bo-erro.
    run InitializeValidate.
    for each tt-bo-erro:
        delete tt-bo-erro.
    end.
    if can-find({&TABLE-NAME} no-lock where rowid({&TABLE-NAME}) = r-chave) then do:
          find {&TABLE-NAME} exclusive-lock where rowid({&TABLE-NAME}) = r-chave no-error. 
	   run executeDelete.
    end. 
    else do:
       assign i-seq-erro = i-seq-erro + 1.
       {utp/ut-table.i mgdis {&TABLE-NAME} 1}
       run utp/ut-msgs.p (input "msg",
                         input 2,
                         input return-value).
      create tt-bo-erro.
      assign tt-bo-erro.i-sequen     = i-seq-erro
             tt-bo-erro.cd-erro      = 2
             tt-bo-erro.mensagem     = return-value.
    end. 
 
end procedure.
 
procedure validateCreate:
    /*
    **  Valida cria‡Æo da tabela/duplicidade de registro.
    */
    def input  parameter table for RowObject.
    def input parameter c-tipo as char. 
    def output parameter table for tt-bo-erro.
    def output parameter r-chave as rowid.
 
    run initializeValidate.
    run startMethod ("validateCreate":U).
 
    for each tt-bo-erro:
        delete tt-bo-erro.
    end.
    find first rowObject no-error.
    find ped-venda no-lock where ped-venda.nr-pedido = rowObject.nr-pedido no-error.
    if ped-venda.cod-cond-pag > 0 then do:
        assign i-seq-erro = 1.
        run utp/ut-msgs.p (input "msg",
                           input 7949,
                           input return-value).
        create tt-bo-erro.
        assign tt-bo-erro.i-sequen     = i-seq-erro
               tt-bo-erro.cd-erro      = 7949
               tt-bo-erro.mensagem     = return-value.
        return.       
    end.
 
    run condPedCallApi (input 1, input c-tipo).

    find first tt-bo-erro no-error.
 
    if not avail tt-bo-erro then do:
       find first rowObject no-error.
       find {&TABLE-NAME} no-lock where {&TABLE-NAME}.nr-pedido = rowObject.nr-pedido no-error.
       assign r-chave = rowid({&TABLE-NAME}).
    end.
 
    run endMethod ("validateCreate":U).
end procedure.
 
procedure getCharField:
    define input  parameter c-field as char.
    define output parameter c-value as char.
 
    case c-field:
        when "char-1" then c-value = RowObject.char-1.
        when "char-2" then c-value = RowObject.char-2.
        when "check-sum" then c-value = RowObject.check-sum.
        when "observacoes":U then c-value = RowObject.observacoes.
        otherwise return error.
    end case.
end procedure.
 
procedure getDecField:
    define input  parameter c-field as char.
    define output parameter c-value as decimal.
 
    case c-field:
        when "dec-1" then c-value = RowObject.dec-1.
        when "dec-2" then c-value = RowObject.dec-2.
        when "perc-pagto" then c-value = RowObject.perc-pagto.
        when "vl-pagto" then c-value = RowObject.vl-pagto.
        otherwise return error.
    end case.
end procedure.
 
procedure getIntField:
    define input  parameter c-field as char.
    define output parameter c-value as integer.
 
    case c-field:
        when "cod-vencto" then c-value = RowObject.cod-vencto.
        when "int-1" then c-value = RowObject.int-1.
        when "int-2" then c-value = RowObject.int-2.
        when "nr-dias-venc" then c-value = RowObject.nr-dias-venc.
        when "nr-pedido" then c-value = RowObject.nr-pedido.
        when "nr-sequencia" then c-value = RowObject.nr-sequencia.
        otherwise return error.
    end case.
end procedure.
 
procedure getDateField:
    define input  parameter c-field as char.
    define output parameter c-value as date.
 
    case c-field:
        when "data-1" then c-value = RowObject.data-1.
        when "data-2" then c-value = RowObject.data-2.
        when "data-pagto" then c-value = RowObject.data-pagto.
        otherwise return error.
    end case.
end procedure.
 
procedure getLogField:
    define input  parameter c-field as char.
    define output parameter c-value as logical.
 
    case c-field:
        when "log-1" then c-value = RowObject.log-1.
        when "log-2" then c-value = RowObject.log-2.
        otherwise return error.
    end case.
end procedure.
 
/* here comes the business logic methods */
procedure condPedCallApi:
   /* 
   ** Chamada da api pdapi152.p 
   ** Condicoes de Pagamento do Pedido de Venda
   */
   def input parameter i-ind-tipo-movto as integer.
   def input parameter c-tipo as character.
   def var i-seq-erro as integer no-undo.
   create tt-versao-integr.
   assign tt-versao-integr.cod-versao-integracao = 001
          tt-versao-integr.ind-origem-msg        = 01.
   find first RowObject no-error.
   find ped-venda no-lock 
      where ped-venda.nr-pedido = RowObject.nr-pedido no-error.
   create tt-ped-venda.
   buffer-copy ped-venda to tt-ped-venda.
   assign tt-ped-venda.ind-tipo-movto = 8.
   create tt-con-pges.
   buffer-copy RowObject except r-rowid to tt-con-pges.
   assign tt-con-pges.ind-tipo-movto = i-ind-tipo-movto
          tt-con-pges.nr-pedcli = tt-ped-venda.nr-pedcli
          tt-con-pges.tipo = integer(c-tipo).
            
   run pdp/pdapi152.p (input-output table tt-ped-venda,
                       input-output table tt-ped-item, 
                       input-output table tt-ped-ent,
                       input-output table tt-ped-repre,
                       input-output table tt-con-pges,
                       input-output table tt-ped-antecip,
                       input-output table tt-versao-integr,
                       output       table tt-erros-geral, 
                       input        i-cod-maq-origem,
                       input        i-num-processo,
                       input        no,
                       input        table tt-pd-vendor).
   for each tt-erros-geral:
      assign i-seq-erro = i-seq-erro + 1.
      run utp/ut-msgs.p (input "msg",
                         input tt-erros-geral.cod-erro,
                         input "").
      create tt-bo-erro.
      assign tt-bo-erro.i-sequen     = i-seq-erro
             tt-bo-erro.cd-erro      = tt-erros-geral.cod-erro
             tt-bo-erro.mensagem     = return-value.
   end.
   find first tt-bo-erro no-error.
   if not avail tt-bo-erro then do:
      find first tt-con-pges no-error.
      if avail tt-con-pges then do:
         buffer-copy tt-con-pges except ind-tipo-movto nr-pedcli tipo to RowObject.
      end.
   end.
end procedure.
procedure condPedSetGlobals:
   /* 
   ** Seta as variáveis globais c-seg-usuario e i-pais-impto-usuario para a api pdapi152.p 
   ** Condicoes de Pagamento do Pedido de Venda
   */
   def input parameter c-usuario as char.
   def input parameter c-pais as char.
   assign c-seg-usuario = c-usuario
          i-pais-impto-usuario = integer(c-pais).
end procedure.

procedure findFirstSeq:
    def input param i-nr-pedido as integer.
    def output param c-return as char.
    
    find first {&TABLE-NAME} where {&TABLE-NAME}.nr-pedido = i-nr-pedido
    no-lock no-error.
    
    run setCurrent.
    if not avail {&TABLE-NAME} then c-return = "error":U. 
end procedure.
