/********************************************************************************
*******************************************************************************/
{include/i-prgvrs.i int006RP 2.06.00.001}  
{include/i_fnctrad.i}
/******************************************************************************
**
**       PROGRAMA: int006RP
**
**       DATA....: 01/2016
**
**       OBJETIVO: Integra‡Æo WMS/DATASUL/SYSFARMA
**                 Ler as tabelas de Invent rio do WMS , gerar movimentos de invent rio no Datasul 
**                 e integrar com o Sysfarma 
**
**       VERSAO..: 2.06.001
** 
******************************************************************************/

{include/i-rpvar.i}
{include/i-rpcab.i}

/* {utp/ut-glob.i} */ def new Global shared var c-seg-usuario        as char format "x(12)" no-undo.


{cep/ceapi001.i}    /* Definicao de temp-table do movto-estoq */
{cdp/cd0666.i}      /* Definicao da temp-table de erros */

define temp-table tt-param no-undo
    field destino          as integer
    field arquivo          as char format "x(35)":U
    field usuario          as char format "x(12)":U
    field data-exec        as date
    field hora-exec        as integer
    field classifica       as integer
    field desc-classifica  as char format "x(40)":U
    field modelo           AS char format "x(35)":U
    field l-habilitaRtf    as LOG
    FIELD dt-trans-ini     LIKE docum-est.dt-trans
    FIELD dt-trans-fin     LIKE docum-est.dt-trans
    FIELD i-cod-estab-ini  LIKE int-ds-inventario.cod-estabel
    FIELD i-cod-estab-fin  LIKE int-ds-inventario.cod-estabel.

def temp-table tt-raw-digita
    field raw-digita as raw.

DEF TEMP-TABLE tt-raw-param 
 FIELD raw-param  AS RAW.

DEF TEMP-TABLE tt-int-ds-inv LIKE int-ds-inventario
FIELD nr-ficha-novo LIKE int-ds-inventario.nr-ficha
FIELD r-rowid AS ROWID.

def input parameter raw-param as raw no-undo.
def input parameter table for tt-raw-digita.

create tt-param.
raw-transfer raw-param to tt-param.


def var c-acompanha    as char    no-undo.
DEF VAR h-acomp        AS HANDLE  NO-UNDO.
DEF VAR c-nom-arq      AS CHAR    NO-UNDO.
DEF VAR c-data         AS CHAR    NO-UNDO.
DEF VAR i-cont         AS INTEGER NO-UNDO.
DEF VAR i-linha        AS INTEGER NO-UNDO.
DEF VAR c-localizacao  LIKE saldo-estoq.cod-localiz  NO-UNDO.
DEF VAR dt-vali-lote   LIKE fat-ser-lote.dt-vali-lote NO-UNDO.
DEF VAR c-conta-movto  LIKE estab-mat.conta-inven-ent NO-UNDO.
DEF VAR i-empresa      LIKE conta-contab.ep-codigo    NO-UNDO.
                                      
find first param-estoq  no-lock no-error.
find first param-global no-lock no-error.
find first mgcad.empresa where 
           empresa.ep-codigo = param-global.empresa-prin no-lock no-error.

assign c-programa = "Int006rp"
       c-versao   = "2.06"
       c-revisao  = "001"
       c-empresa  = empresa.razao-social.

find first tt-param no-lock no-error.
{include/i-rpout.i}
{utp/ut-liter.i Integra‡Æo_WMS * L}
assign c-titulo-relat = trim(return-value).
{utp/ut-liter.i WMS * L}
assign c-sistema = trim(return-value).

view frame f-cabec.
view frame f-rodape.

run utp/ut-acomp.p persistent set h-acomp.
{utp/ut-liter.i Integra‡Æo_WMS * L}
run pi-inicializar in h-acomp (input return-value).
           
FOR EACH int-ds-inventario NO-LOCK WHERE
         int-ds-inventario.dt-saldo     >= tt-param.dt-trans-ini    AND 
         int-ds-inventario.dt-saldo     <= tt-param.dt-trans-fin    AND
         int-ds-inventario.cod-estabel  >= tt-param.i-cod-estab-ini AND 
         int-ds-inventario.cod-estabel  <= tt-param.i-cod-estab-fin AND
         int-ds-inventario.situacao     = 1  /* Pendente */         AND 
         int-ds-inventario.tipo-docto   = 1 /* WMS */
    BY int-ds-inventario.dt-saldo :    

     CREATE tt-int-ds-inv.
     BUFFER-COPY int-ds-inventario TO tt-int-ds-inv.
     ASSIGN tt-int-ds-inv.r-rowid = rowid(int-ds-inventario).
    
END.

/* log-manager:logfile-name= "\\192.168.200.52\datasul\_custom_teste\Prog_QG\log-int006rp.txt".
log-manager:log-entry-types= "4gltrace".
*/   

FOR EACH tt-int-ds-inv: 

    RUN pi-atualiza-wms. 
          
END.

Procedure pi-atualiza-wms:

    find item NO-LOCK where 
         item.it-codigo = string(tt-int-ds-inv.it-codigo) no-error.

    find item-uni-estab WHERE ITEM-uni-estab.cod-estabel = string(tt-int-ds-inv.cod-estabel) 
                          AND item-uni-estab.it-codigo   = string(tt-int-ds-inv.it-codigo) 
                          NO-LOCK no-error.

    assign dt-vali-lote  = ?.

    if  AVAIL item-uni-estab AND 
              item-uni-estab.loc-unica then 
        assign c-localizacao = item-uni-estab.cod-localiz.
    ELSE 
        assign c-localizacao = "".

    for each tt-movto:
        delete tt-movto.
    end.            
      
    create tt-movto.
    assign tt-movto.cod-versao-integ  = 1
           tt-movto.cod-estabel       = string(tt-int-ds-inv.cod-estabel,"999")
           tt-movto.cod-localiz       = c-localizacao
           tt-movto.lote              = tt-int-ds-inv.lote
           tt-movto.dt-vali-lote      = dt-vali-lote
           tt-movto.cod-refer         = ""
           tt-movto.conta-contabil    = "91107002"   
           tt-movto.ct-codigo         = "91107002"            
           tt-movto.sc-codigo         = "" 
           tt-movto.it-codigo         = string(tt-int-ds-inv.it-codigo)
           tt-movto.nro-docto         = string(tt-int-ds-inv.num-pedido-wms) + "-" + STRING(tt-int-ds-inv.sequencia)
           tt-movto.serie             = "W"  
           tt-movto.esp-docto         = 15
           tt-movto.cod-prog-orig     = "int006".
         
    if tt-movto.cod-estabel = "973" then
      assign tt-movto.cod-depos = tt-movto.cod-estabel.
    else    
     assign tt-movto.cod-depos = "LOJ".  /* de-para */ 
    
    /* Sempre ir  atualizar com a data da transa‡Æo */

    assign tt-movto.dt-trans       = tt-int-ds-inv.dt-atualiza
           tt-movto.tipo-trans     = tt-int-ds-inv.tipo-trans
           tt-movto.quantidade     = tt-int-ds-inv.valor-apurado
           tt-movto.valor-mat-o[1] = tt-int-ds-inv.valor-contab. 
    
    FOR FIRST estab-mat FIELDS (cod-estabel 
                                conta-inven-ent 
                                conta-inven-sai) WHERE
              estab-mat.cod-estabel = string(tt-int-ds-inv.cod-estabel) 
    NO-LOCK: 

    END.
    
    if avail estab-mat then
       ASSIGN c-conta-movto = IF tt-movto.tipo-trans = 1 THEN estab-mat.conta-inven-ent ELSE estab-mat.conta-inven-sai.
       
    assign i-empresa = param-global.empresa-prin.

    find FIRST estabelec where
               estabelec.cod-estabel = tt-movto.cod-estabel no-lock no-error.

    run cdp/cd9970.p (input rowid(estabelec),
                      output i-empresa).

    find first conta-contab NO-LOCK where  
               conta-contab.conta-contabil = c-conta-movto and 
               conta-contab.ep-codigo      = i-empresa no-error.
    IF AVAIL conta-contab THEN
        ASSIGN tt-movto.conta-contabil = conta-contab.conta-contabil
               tt-movto.ct-codigo      = conta-contab.ct-codigo
               tt-movto.sc-codigo      = conta-contab.sc-codigo.
               
    assign tt-movto.un               = item.un
           tt-int-ds-inv.dt-atualiza  = today.
                                 
    for each tt-erro:
        delete tt-erro.
    end.

    run cep/ceapi001.p (input-output table tt-movto,
                        input-output table tt-erro,
                        input yes).

    IF CAN-FIND (FIRST tt-erro) 
    THEN DO:
    
        FOR FIRST tt-erro:

            RUN intprg/int999.p (INPUT "WMS", 
                                       INPUT string(tt-int-ds-inv.num-pedido-wms) + "-" + string(tt-int-ds-inv.sequencia),
                                       INPUT tt-erro.mensagem + " Num. Pedido: " + string(tt-int-ds-inv.num-pedido-wms) + " Seq.: " + string(tt-int-ds-inv.sequencia) + 
                                                                " Nr. Ficha: " + string(tt-int-ds-inv.nr-ficha) + " Item: " + string(tt-int-ds-inv.it-codigo) + 
                                                                " Estab.: " + string(tt-int-ds-inv.cod-estabel) + " Depos.: " + string(tt-int-ds-inv.cod-depos) + 
                                                                " Lote: " + string(tt-int-ds-inv.lote),
                                       INPUT 1, /* 1 - Pendente ou 2 - Integrado */
                                       INPUT c-seg-usuario).
        
            DISP  tt-int-ds-inv.dt-saldo     
                 tt-int-ds-inv.cod-estab    
                 tt-int-ds-inv.cod-depos    
                 tt-int-ds-inv.lote         
                 tt-int-ds-inv.it-codigo    
                 tt-int-ds-inv.valor-apurado
                 c-conta-movto
                 tt-erro.cd-erro
                 tt-erro.mensagem
                 WITH WIDTH 333 STREAM-IO DOWN FRAME f-erro.
           DOWN WITH FRAME f-erro. 
         
        end.   

       

    END.
    ELSE DO:

        FIND FIRST int-ds-inventario EXCLUSIVE-LOCK WHERE
                   int-ds-inventario.num-pedido-wms = tt-int-ds-inv.num-pedido-wms and   
                   int-ds-inventario.sequencia      = tt-int-ds-inv.sequencia NO-ERROR.
        IF AVAIL int-ds-inventario THEN DO:
        
          assign int-ds-inventario.situacao    = 2 /* Atualizado Datasul */
                 int-ds-inventario.dt-atualiza = TODAY.
   
           RELEASE int-ds-inventario.
   
           RUN intprg/int999.p (INPUT "WMS", 
                                INPUT string(tt-int-ds-inv.num-pedido-wms) + "-" + string(tt-int-ds-inv.sequencia),
                                INPUT "Registro Integrado -" + " Num. Pedido: " + string(tt-int-ds-inv.num-pedido-wms) + " Seq.: " + string(tt-int-ds-inv.sequencia) + 
                                                               " Nr. Ficha: " + string(tt-int-ds-inv.nr-ficha) + " Item: " + string(tt-int-ds-inv.it-codigo) + 
                                                               " Estab.: " + string(tt-int-ds-inv.cod-estabel) + " Depos.: " + string(tt-int-ds-inv.cod-depos) + 
                                                               " Lote: " + string(tt-int-ds-inv.lote),
                                INPUT 2, /* 1 - Pendente ou 2 - Integrado */
                                INPUT c-seg-usuario).
   
            DISP tt-int-ds-inv.dt-saldo
                tt-int-ds-inv.cod-estab 
                tt-int-ds-inv.cod-depos
                tt-int-ds-inv.lote
                tt-int-ds-inv.it-codigo
                tt-int-ds-inv.valor-apurado 
                    WITH WIDTH 333 STREAM-IO DOWN FRAME f-inv.
              DOWN WITH FRAME f-inv.
               

        END.
    END.
    
    for each tt-erro:
        delete tt-erro.
    end.

end.


/* log-manager:close-log(). */

{include/i-rpclo.i}   

run pi-finalizar in h-acomp.

return "OK":U.


