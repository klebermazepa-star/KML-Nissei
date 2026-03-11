/************************************************************************
**
**  Programa.: int100.p
**
**  Descri‡Æo: Gera‡Æo Nota Fiscal de Devolu‡Æo - Retorno Contagem WMS
**
*************************************************************************/

{dibo/bodi317sd.i1}

def temp-table tt-erro no-undo
    field i-sequen  as int              
    field cd-erro   as int
    field desc-erro as char format "x(255)".

{method/dbotterr.i } /*** Defini‡Æo RowErrors ***/

/***************** Defini‡Æo de Vari veis ************/

def var h-boin672                  as HANDLE  no-undo.
def var h-bodi317pr                as handle  no-undo.
def var h-bodi317sd                as handle  no-undo.
def var h-bodi317im1bra            as handle  no-undo.
def var h-bodi317va                as handle  no-undo.
def var h-bodi317in                as handle  no-undo.
def var l-proc-ok-aux              as log     no-undo.
def var c-ultimo-metodo-exec       as char    no-undo.
def var l-nf-man-dev-terc-dif      as log     no-undo.
def var l-recal-apenas-totais      as log     no-undo.
DEF VAR i-seq-wt-docto             AS INT     NO-UNDO.
def var h-bodi317ef                as handle  no-undo.
DEF VAR i-seq-item                 AS INTEGER NO-UNDO.

{utp/ut-glob.i}

DEF INPUT PARAM c-serie-docto  AS CHAR NO-UNDO.
DEF INPUT PARAM c-nro-docto    AS CHAR NO-UNDO.
DEF INPUT PARAM i-cod-emitente AS INT  NO-UNDO.


FIND FIRST emitente WHERE 
           emitente.cod-emitente = i-cod-emitente NO-LOCK NO-ERROR.
IF AVAIL emitente THEN DO:
   FIND FIRST int-ds-nfd-wms USE-INDEX docto-orig WHERE
              int-ds-nfd-wms.serie-docto-orig = c-serie-docto AND
              int-ds-nfd-wms.nro-docto-orig   = c-nro-docto   AND
              int-ds-nfd-wms.cnpj-cpf         = emitente.cgc  AND 
              int-ds-nfd-wms.situacao         = 1 /* Pendente */ NO-ERROR.
   IF AVAIL int-ds-nfd-wms THEN DO:

      RUN pi-inicializa. /*** Inicializa as BOs ***/
 
      run emptyRowErrors in h-bodi317in. /*** Limpa a tabela de erros ***/

      RUN pi-default-nota.

      IF RETURN-VALUE <> "NOK" THEN
         RUN pi-dados-nota.

      IF RETURN-VALUE <> "NOK" THEN
         RUN pi-dados-item-nota.

      IF RETURN-VALUE <> "NOK" THEN
         RUN pi-calcula-nota.

      IF RETURN-VALUE <> "NOK" THEN
         RUN pi-efetiva-nota. 
   
      RUN pi-finaliza-bos.

      RUN pi-destroy.

   END.
END.

PROCEDURE pi-inicializa:
    
    IF NOT VALID-HANDLE(h-bodi317in) THEN DO:
       run dibo/bodi317in.p persistent set h-bodi317in.
       run inicializaBOS in h-bodi317in(output h-bodi317pr,
                                        output h-bodi317sd,     
                                        output h-bodi317im1bra,
                                        output h-bodi317va).
    END.    

END PROCEDURE.


PROCEDURE pi-default-nota:

    run criaWtDocto in h-bodi317sd
           (input  c-seg-usuario,
            input  int-ds-nfd-wms.cod-estabel,
            input  int-ds-nfd-wms.serie-docto,     
            input  int-ds-nfd-wms.nro-docto, 
            input  emitente.nome-abrev,   
            input  "",   /* verificar */    
            input  1,    /* Nota do Sistema    */ 
            input  0,    /* N£mero do programa */
            input  TODAY,   
            input  0,    /* N£mero do embarque */
            input  ""    /* nat-operacao - verificar */,
            input  0,    /* canal de venda */
            output i-seq-wt-docto,
            output l-proc-ok-aux).

            /* wt-docto.peso-bru-tot-inf    
            wt-docto.peso-liq-tot-inf         
            wt-docto.nome-transp         
            wt-docto.cod-rota            
            wt-docto.cidade-cif          
            wt-docto.cod-msg */            
   
    /*** retorna erros ***/
    run devolveErrosbodi317sd in h-bodi317sd(output c-ultimo-metodo-exec,
                                             output table RowErrors).
    
    RUN pi-RowErrors.        

    IF RETURN-VALUE = "NOK" THEN
       RETURN "NOK".

END PROCEDURE.


PROCEDURE pi-dados-nota:

    do trans:                
       run emptyRowErrors          in h-bodi317sd.
       run emptyRowErrors          in h-bodi317va.
       run atualizaDadosGeraisNota in h-bodi317sd(input  i-seq-wt-docto,
                                                  output l-proc-ok-aux).
       run devolveErrosbodi317sd   in h-bodi317sd(output c-ultimo-metodo-exec,
                                                  output table RowErrors).        
       RUN pi-RowErrors.
    end.

END PROCEDURE.


PROCEDURE pi-dados-item-nota:
    
    SESSION:SET-WAIT-STATE("GENERAL":U).

    run emptyRowErrors in h-bodi317in.
    
    do trans: 

       RUN pi-cria-itens-devol.
       if RETURN-VALUE = "NOK" THEN 
          return "NOK".
               
       RUN pi-rowerrors.

    END.

END PROCEDURE.


PROCEDURE pi-cria-itens-devol:
    
    run inbo/boin672.p persistent set h-boin672.

    ASSIGN i-seq-item = 0.

    FOR EACH int-ds-it-nfd-wms WHERE 
             int-ds-it-nfd-wms.serie-docto = int-ds-nfd-wms.serie-docto AND 
             int-ds-it-nfd-wms.nro-docto   = int-ds-nfd-wms.nro-docto   AND
             int-ds-it-nfd-wms.cnpj-cpf    = int-ds-nfd-wms.cnpj-cpf NO-LOCK:
        
        FIND FIRST item
            WHERE item.it-codigo = int-ds-it-nfd-wms.it-codigo NO-LOCK NO-ERROR.

        FIND FIRST emitente WHERE
                   emitente.cgc = int-ds-it-nfd-wms.cnpj-cpf NO-LOCK NO-ERROR.

        ASSIGN i-seq-item = i-seq-item + 10.

        create tt-itens-devol.
        assign tt-itens-devol.serie-docto       = int-ds-it-nfd-wms.serie-docto 
               tt-itens-devol.cod-emitente      = emitente.cod-emitente
               tt-itens-devol.nro-docto         = int-ds-it-nfd-wms.nro-docto   
               tt-itens-devol.nat-operacao      = "" /* verificar */
               tt-itens-devol.sequencia         = i-seq-item
               tt-itens-devol.it-codigo         = int-ds-it-nfd-wms.it-codigo
               tt-itens-devol.cod-refer         = ""
               tt-itens-devol.desc-nar          = if item.tipo-contr = 4 /* D‚bito Direto */
                                                  then substr(item.narrativa,1,60)
                                                  else item.desc-item
               tt-itens-devol.quantidade        = int-ds-it-nfd-wms.quantidade
               tt-itens-devol.preco-total       = int-ds-it-nfd-wms.preco-total
               tt-itens-devol.selecionado       = YES
               tt-itens-devol.qt-a-devolver-inf = int-ds-it-nfd-wms.quantidade
               tt-itens-devol.qt-a-devolver     = int-ds-it-nfd-wms.quantidade.

    END.

    run emptyRowErrors in h-bodi317in.
    run geraWtItDoctoPartindoDoTtItensDevol in h-bodi317sd(input  i-seq-wt-docto,
                                                           input  table tt-itens-devol,
                                                           output l-proc-ok-aux).
    run devolveErrosbodi317sd               in h-bodi317sd(output c-ultimo-metodo-exec,
                                                           output table RowErrors).                
    RUN pi-rowerrors.

    if  valid-handle(h-boin672) then do:
        delete procedure h-boin672.
        assign h-boin672 = ?.
    end.

END PROCEDURE.


PROCEDURE pi-calcula-nota:

    run emptyRowErrors           in h-bodi317in.
        
    do trans: 
       run inicializaAcompanhamento in h-bodi317pr.
       run retornaVariaveisParaCalculoImpostos in h-bodi317sd (input  i-seq-wt-docto,
                                                               output l-nf-man-dev-terc-dif,
                                                               output l-recal-apenas-totais,
                                                               output l-proc-ok-aux).
       run recebeVariavelTipoCalculoImpostos   in h-bodi317im1bra (input if l-recal-apenas-totais 
                                                                         then 1
                                                                         else 0,
                                                                         output l-proc-ok-aux).
       run confirmaCalculo         in h-bodi317pr(input  i-seq-wt-docto,
                                                  output l-proc-ok-aux).

       run finalizaAcompanhamento  in h-bodi317pr.
       run devolveErrosbodi317pr   in h-bodi317pr(output c-ultimo-metodo-exec,
                                                  output table RowErrors).                        
       RUN pi-rowerrors. 
          
       IF RETURN-VALUE = "NOK" THEN
          RETURN "NOK".
    end.
            
    DO TRANS:
       ASSIGN int-ds-nfd-wms.situacao = 2. /* Atualizada */
    END.

    RETURN "OK".

END PROCEDURE.


PROCEDURE pi-efetiva-nota:

    run dibo/bodi317ef.p persistent set h-bodi317ef.

    run emptyRowErrors           in h-bodi317in.
    run inicializaAcompanhamento in h-bodi317ef.
    run setaHandlesBOS           in h-bodi317ef(h-bodi317pr,    
                                                h-bodi317sd, 
                                                h-bodi317im1bra, 
                                                h-bodi317va).
    
    run efetivaNota              in h-bodi317ef(input  i-seq-wt-docto,
                                                input  yes,
                                                output l-proc-ok-aux).

    run finalizaAcompanhamento   in h-bodi317ef.
    run devolveErrosbodi317ef    in h-bodi317ef(output c-ultimo-metodo-exec,
                                                output table RowErrors).
    RUN pi-rowerrors.

    if  RETURN-VALUE = "NOK" THEN DO:
        delete procedure h-bodi317ef.
        ASSIGN h-bodi317ef = ?.
        return "NOK".
    end.

    delete procedure h-bodi317ef.
    ASSIGN h-bodi317ef = ?.

END PROCEDURE.


PROCEDURE pi-finaliza-bos:
    
    if  valid-handle(h-bodi317va) then do:
        delete procedure h-bodi317va.
        assign h-bodi317va = ?.
    end.
    if  valid-handle(h-bodi317pr) then do:
        delete procedure h-bodi317pr.
        assign h-bodi317pr = ?.
    end.

    if  valid-handle(h-bodi317sd) then do:
        delete procedure h-bodi317sd.
        assign h-bodi317sd = ?.
    end.

    if  valid-handle(h-bodi317im1bra) then do:
        delete procedure h-bodi317im1bra.
        assign h-bodi317im1bra = ?.
    end.

END PROCEDURE.


PROCEDURE pi-destroy:
    
    if valid-handle(h-bodi317in) then do:
       run finalizaBOS in h-bodi317in.
       assign h-bodi317in = ?.    
    end.

END PROCEDURE.


PROCEDURE pi-Rowerrors:

    FOR EACH  RowErrors
            where RowErrors.ErrorSubType = "ERROR":
      
        RUN pi-tt-erro(INPUT string(RowErrors.ErrorNumber) + " - " + RowErrors.ErrorDescription).
    end.
    
    FIND FIRST tt-erro NO-ERROR.
    IF AVAIL tt-erro THEN DO:   
       RETURN "NOK".        
    END.

END PROCEDURE.


PROCEDURE pi-tt-erro:

    DEF INPUT PARAM c-erro AS CHAR.
     
    CREATE tt-erro.
    ASSIGN tt-erro.desc-erro = c-erro.

    RUN intprg/int999.p (INPUT "NF DEVOL", 
                         INPUT int-ds-nfd-wms.serie-docto-orig + int-ds-nfd-wms.nro-docto-orig + int-ds-nfd-wms.cnpj-cpf,
                         INPUT "Erro ao gerar a NF de Devolu‡Æo para a Nota Fiscal " + int-ds-nfd-wms.nro-docto-orig + " S‚rie " + int-ds-nfd-wms.serie-docto-orig + " CNPJ/CPF " + int-ds-nfd-wms.cnpj-cpf + 
                               ". Erro: " + c-erro,
                         INPUT 1, /* 1 - Pendente */
                         INPUT c-seg-usuario).

END PROCEDURE.
