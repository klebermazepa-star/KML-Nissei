/********************************************************************************
*******************************************************************************/
{include/i-prgvrs.i int007RP 2.06.00.001}  
{include/i_fnctrad.i}
/******************************************************************************
**
**       PROGRAMA: int007RP
**
**       DATA....: 01/2016
**
**       OBJETIVO: Integra‡Æo Inventario/Frente Loja/Datasul
**                 Ler as tabelas de Invent rio Balan‡o Frente de Loja , 
**                 gerar fichas de inventario no Datasul 
**
**       VERSAO..: 2.06.001
** 
******************************************************************************/

{include/i-rpvar.i}  
/* {include/i-rpcab.i}  */

/* {utp/ut-glob.i} */ def new Global shared var c-seg-usuario        as char format "x(12)" no-undo.

{method/dbotterr.i} 
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

DEF TEMP-TABLE tt-inventario NO-UNDO LIKE inventario
FIELD r-Rowid AS ROWID.

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

DEF VAR dt-vali-lote   LIKE fat-ser-lote.dt-vali-lote      NO-UNDO.
DEF VAR c-conta-movto  LIKE estab-mat.conta-inven-ent      NO-UNDO.
DEF VAR i-empresa      LIKE conta-contab.ep-codigo         NO-UNDO.
DEF VAR i-nr-ficha     LIKE inventario.nr-ficha            NO-UNDO.                                      

DEF VAR h-boin157q01   AS HANDLE                           NO-UNDO.
DEF VAR l-habilita     AS LOGICAL                          NO-UNDO.
DEF VAR d-return       AS DATE FORMAT "99/99/9999"         NO-UNDO.
def var ix             as integer                          no-undo.
DEF VAR c-lote         AS CHAR                             NO-UNDO.
DEF VAR c-cod-depos    AS CHAR                             NO-UNDO.

DEF BUFFER b-tt-int-ds-inv FOR tt-int-ds-inv.

find first param-estoq  no-lock no-error.
find first param-global no-lock no-error.
find first mgcad.empresa where 
           empresa.ep-codigo = param-global.empresa-prin no-lock no-error.

assign c-programa = "Int007rp"
       c-versao   = "2.06"
       c-revisao  = "001"
       c-empresa  = empresa.razao-social.

find first tt-param no-lock no-error.
/* {include/i-rpout.i}                                  */
/* {utp/ut-liter.i Integra‡Æo_Balan‡o_Frente_Loja * L}  */
/* assign c-titulo-relat = trim(return-value).          */
/* {utp/ut-liter.i Frente_Loja * L}                     */
/* assign c-sistema = trim(return-value).               */
/*                                                      */
/* VIEW frame f-cabec.                                  */
/* view frame f-rodape.                                 */

/* run utp/ut-acomp.p persistent set h-acomp.           */
/* {utp/ut-liter.i Integra‡Æo_Balan‡o_Frente_Loja * L}  */
/* run pi-inicializar in h-acomp (input return-value).  */

                     
/* log-manager:logfile-name= "\\192.168.200.52\datasul\_custom_teste\Prog_QG\clientelog-int007.txt".  */
/* log-manager:log-entry-types= "4gltrace".                                                           */
     
                     
FOR EACH int-ds-inventario NO-LOCK WHERE
         /*int-ds-inventario.dt-saldo     >= tt-param.dt-trans-ini    AND 
         int-ds-inventario.dt-saldo     <= tt-param.dt-trans-fin    AND
         int-ds-inventario.cod-estabel  >= tt-param.i-cod-estab-ini AND 
         int-ds-inventario.cod-estabel  <= tt-param.i-cod-estab-fin AND*/
         int-ds-inventario.situacao     = 1  /* Pendente */         AND 
         int-ds-inventario.tipo-docto   = 2 /* Frente de Loja */
    BY int-ds-inventario.dt-saldo:    

     FOR LAST b-tt-int-ds-inv WHERE  
              b-tt-int-ds-inv.dt-saldo    = int-ds-inventario.dt-saldo 
        BY b-tt-int-ds-inv.dt-saldo : 

         ASSIGN i-nr-ficha = b-tt-int-ds-inv.nr-ficha-novo + 1.

     END.

     CREATE tt-int-ds-inv.
     BUFFER-COPY int-ds-inventario TO tt-int-ds-inv.
     ASSIGN tt-int-ds-inv.r-rowid  = rowid(int-ds-inventario).
            tt-int-ds-inv.nr-ficha = 0.      
                   
     IF i-nr-ficha = 0 
     THEN DO:
     
         FOR LAST inventario NO-LOCK WHERE
                  inventario.dt-saldo    = tt-int-ds-inv.dt-saldo
              BY inventario.nr-ficha:
    
              ASSIGN i-nr-ficha = inventario.nr-ficha + 1.
         END.

     END.

     IF i-nr-ficha = 0 THEN
        ASSIGN i-nr-ficha = 1.
     
     ASSIGN tt-int-ds-inv.nr-ficha-novo = i-nr-ficha.
             
END.

run inbo/boin157q01.p persistent set h-boin157q01.
run openQueryStatic in h-boin157q01 (input "Inclui":U).
run setConstraintInclui in h-boin157q01 (input 1).

FOR EACH tt-int-ds-inv:
  
  /* run emptyRowObject     in h-boin157q01.  */
     
  RUN emptyRowErrors     IN h-boin157q01.
   
  empty temp-table tt-inventario.
  
  RUN newRecord    IN h-boin157q01.
  RUN getRecord    IN h-boin157q01 (OUTPUT TABLE tt-inventario).
  
  find first tt-inventario no-error. 
  if not avail tt-inventario then do:
     CREATE tt-inventario.
  end. 

  IF tt-int-ds-inv.lote = "0" THEN
     ASSIGN c-lote = "".
  ELSE
     ASSIGN c-lote = STRING(tt-int-ds-inv.lote).

  ASSIGN tt-inventario.cod-estabel    = STRING(tt-int-ds-inv.cod-estabel,"999")
         tt-inventario.dt-saldo       = tt-int-ds-inv.dt-saldo
         tt-inventario.it-codigo      = string(tt-int-ds-inv.it-codigo)
         tt-inventario.lote           = c-lote 
         tt-inventario.char-1         = "Importada"
         tt-inventario.situacao       = 4 /*  Inventario OK verificar com o BeltrÆo como deve iniciar */ 
         tt-inventario.val-apurado[1] = tt-int-ds-inv.valor-apurado
         tt-inventario.valor-contab   = tt-int-ds-inv.valor-contab
         tt-inventario.valor-mat-m[1] = tt-int-ds-inv.valor-contab.  
         
  if tt-inventario.cod-estabel = "973" then
     assign c-cod-depos = tt-inventario.cod-estabel.
  ELSE
      assign c-cod-depos  = "LOJ". /* de-para */

  FIND FIRST item-uni-estab NO-LOCK WHERE
             item-uni-estab.cod-estabel = tt-inventario.cod-estabel AND  
             item-uni-estab.it-codigo   =  tt-inventario.it-codigo NO-ERROR.
  IF AVAIL item-uni-estab THEN
     ASSIGN c-cod-depos  = item-uni-estab.deposito-pad.
  ELSE DO:
     FIND FIRST ITEM NO-LOCK WHERE
                ITEM.it-codigo = tt-inventario.it-codigo NO-ERROR.
     IF AVAIL ITEM THEN
            ASSIGN c-cod-depos  = item-uni-estab.deposito-pad.
  END.             

  ASSIGN tt-inventario.cod-depos = c-cod-depos. 

  IF tt-int-ds-inv.nr-ficha = 0 THEN
     ASSIGN tt-inventario.nr-ficha = tt-int-ds-inv.nr-ficha-novo.
  ELSE 
     ASSIGN tt-inventario.nr-ficha = tt-int-ds-inv.nr-ficha.   

       

  /* Grava datas (entrada e sa¡da) */
   run piRetornaData in h-boin157q01 (input tt-inventario.it-codigo,
                                      output l-habilita,
                                      output d-return). 

  assign tt-inventario.dt-ult-sai = d-return.
         tt-inventario.dt-ult-ent = if l-habilita then tt-int-ds-inv.dt-validade
                                     else ?.       

  IF l-habilita THEN
     ASSIGN tt-inventario.valor-mat-m[1] = tt-int-ds-inv.valor-contab.
          
             
  RUN setRecord      IN h-boin157q01(INPUT TABLE tt-inventario).
  run piInicializa   in h-boin157q01(output table RowErrors).  
  run setConstraintDataSaldo in h-boin157q01(input tt-int-ds-inv.dt-saldo). 
  RUN createRecord   IN h-boin157q01.  
  
  RUN getRowErrors IN h-boin157q01(OUTPUT TABLE RowErrors).
   
  FOR EACH RowErrors where
           RowErrors.errornumber <> 3 and 
           RowErrors.errornumber <> 8 and 
           RowErrors.errornumber <> 37:

        CREATE tt-erro.
        ASSIGN tt-erro.cd-erro  = RowErrors.errornumber
               tt-erro.mensagem = RowErrors.errordescription.                                     
  END.
 
    
  IF RETURN-VALUE = "NOK":U 
  THEN DO:

        RUN getRowErrors IN h-boin157q01(OUTPUT TABLE RowErrors).

        FOR EACH RowErrors where
                 RowErrors.errornumber <> 3 and 
                 RowErrors.errornumber <> 8 and 
                 RowErrors.errornumber <> 37:

            CREATE tt-erro.
            ASSIGN tt-erro.cd-erro  = RowErrors.errornumber
                   tt-erro.mensagem = RowErrors.errordescription.                                     
        END.

        EMPTY TEMP-TABLE RowErrors.

        RUN emptyRowErrors  IN h-boin157q01.

        for FIRST tt-erro WHERE
                  tt-erro.cd-erro = 30528 OR 
                  tt-erro.cd-erro = 1:
                  
        end.
                  
        IF AVAIL tt-erro 
        THEN DO: 
                                       
            RUN goToKey         IN h-boin157q01(INPUT tt-inventario.dt-saldo    ,
                                                INPUT tt-inventario.cod-estabel ,
                                                INPUT tt-inventario.cod-depos   ,
                                                INPUT "" ,
                                                INPUT tt-inventario.lote        ,
                                                INPUT tt-inventario.it-codigo   ,
                                                INPUT ""). 
    
            RUN setRecord       IN h-boin157q01(INPUT TABLE tt-inventario).
            RUN updateRecord    IN h-boin157q01.
            
            IF RETURN-VALUE = "NOK":U 
            THEN DO:
               
                RUN getRowErrors IN h-boin157q01(OUTPUT TABLE RowErrors).
    
                FOR EACH RowErrors where
                         RowErrors.errornumber <> 3 and 
                         RowErrors.errornumber <> 8 and 
                         RowErrors.errornumber <> 37:                                 
                    
                   CREATE tt-erro.
                   ASSIGN tt-erro.cd-erro  = RowErrors.errornumber
                          tt-erro.mensagem = RowErrors.errordescription.                                     
                END.
    
                RUN emptyRowErrors     IN h-boin157q01.

                EMPTY TEMP-TABLE RowErrors.
                
            END.

        END.
  END.  
  
  FOR EACH tt-erro WHERE
           tt-erro.cd-erro = 30528 OR 
           tt-erro.cd-erro = 1:

      DELETE tt-erro.

  END.

  IF CAN-FIND (FIRST tt-erro) 
  THEN DO:
    
        FOR FIRST tt-erro:

             RUN intprg/int999.p (INPUT "FLoja", 
                                  INPUT string(tt-int-ds-inv.num-pedido-wms) + "-" + string(tt-int-ds-inv.sequencia),
                                  INPUT tt-erro.mensagem + " Num. Pedido: " + string(tt-int-ds-inv.num-pedido-wms) + " Seq.: " + string(tt-int-ds-inv.sequencia) + 
                                                           " Nr. Ficha: " + string(tt-int-ds-inv.nr-ficha) + " Item: " + string(tt-int-ds-inv.it-codigo) + 
                                                           " Estab.: " + string(tt-int-ds-inv.cod-estabel) + " Depos.: " + string(tt-int-ds-inv.cod-depos) + 
                                                           " Lote: " + string(tt-int-ds-inv.lote),
                                  INPUT 1, /* 1 - Pendente ou 2 - Integrado */
                                  INPUT c-seg-usuario).
        
/*            DISP tt-int-ds-inv.dt-saldo                        */
/*                 tt-int-ds-inv.cod-estab                       */
/*                 tt-inventario.cod-depos                       */
/*                 tt-int-ds-inv.lote                            */
/*                 tt-int-ds-inv.it-codigo                       */
/*                 tt-erro.cd-erro                               */
/*                 tt-erro.mensagem FORMAT "x(100)"              */
/*                  WITH WIDTH 333 STREAM-IO DOWN FRAME f-erro.  */
/*            DOWN WITH FRAME f-erro.                            */
           
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
           
           RUN intprg/int999.p (INPUT "FLoja", 
                                INPUT string(tt-int-ds-inv.num-pedido-wms) + "-" + string(tt-int-ds-inv.sequencia),
                                INPUT "Registro Integrado -" + " Num. Pedido: " + string(tt-int-ds-inv.num-pedido-wms) + " Seq.: " + string(tt-int-ds-inv.sequencia) + 
                                                               " Nr. Ficha: " + string(tt-int-ds-inv.nr-ficha) + " Item: " + string(tt-int-ds-inv.it-codigo) + 
                                                               " Estab.: " + string(tt-int-ds-inv.cod-estabel) + " Depos.: " + string(tt-int-ds-inv.cod-depos) + 
                                                               " Lote: " + string(tt-int-ds-inv.lote),
                                INPUT 2, /* 1 - Pendente ou 2 - Integrado */
                                INPUT c-seg-usuario).

           
/*             DISP tt-int-ds-inv.dt-saldo                      */
/*                  tt-int-ds-inv.cod-estab                     */
/*                  tt-inventario.cod-depos                     */
/*                  tt-int-ds-inv.lote                          */
/*                  tt-int-ds-inv.it-codigo                     */
/*                  tt-int-ds-inv.valor-apurado                 */
/*                                                              */
/*                  WITH WIDTH 333 STREAM-IO DOWN FRAME f-inv.  */
/*            DOWN WITH FRAME f-inv.                            */
           
        END.
  END.
    
  for each tt-erro:
      delete tt-erro.
  end.

END.                 


/* log-manager:close-log().      */
/*                               */
/* {include/i-rpclo.i}           */
/*                               */
/* run pi-finalizar in h-acomp.  */

return "OK":U.


