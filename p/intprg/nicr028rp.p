{include/i-prgvrs.i NICR028RP 2.00.09.GCJ} 

/* tt-param */
{intprg/nicr028_tt.i}
{intprg/nicr002rp.i}

DEFINE VARIABLE v_log_refer_uni AS LOGICAL   NO-UNDO.

DEFINE VARIABLE lErro AS LOGICAL     NO-UNDO.


def temp-table tt-raw-digita
    field raw-digita as raw.


def input param raw-param as raw no-undo.
def input param table for tt-raw-digita.                   


create tt-param.
raw-transfer raw-param to tt-param.

/*
FOR EACH tt-raw-digita:
    CREATE tt-digita.
    RAW-TRANSFER tt-raw-digita.raw-digita TO tt-digita.
END.
*/


/**============================================ Definiá‰es =================================================**/


{include/i-rpvar.i}
{include/i-rpcab.i}

{utp/ut-glob.i}
{btb/btb009za.i}

{include/tt-edit.i}

 &scoped-define TTONLY YES    
{include/i-estab-security.i}


{include/pi-edit.i}

/*================================================== temp tables =========================================*/

def temp-table tt-nota-fiscal no-undo
    field atualizar     as log  init yes
    field referencia    as char format "x(10)"
    field r-nota-fiscal as rowid
    field emite-duplic  like nota-fiscal.emite-duplic
    field cod-estabel   like nota-fiscal.cod-estabel
    field serie         like nota-fiscal.serie
    field nr-fatura     like nota-fiscal.nr-fatura
    FIELD l-ecom        AS   LOG.

def temp-table tt-nota-fiscal-aux NO-UNDO LIKE tt-nota-fiscal.


def temp-table tt-retorno-nota-fiscal no-undo
    field tipo       as integer   /* 1- Nota Fiscal 2- T°tulo 3- Nota de DÇbito/CrÇdito */
    field cod-erro   as character format "x(10)"
    field referencia as character format "x(10)"
    field desc-erro  as character format "x(60)"
                        view-as editor max-chars 2000 
                        scrollbar-vertical size 50 by 4
    field situacao   as LOGICAL format "Sim/N∆o"
    field cod-chave  as character
    INDEX ch-codigo  IS PRIMARY tipo
                                cod-erro
                                cod-chave.

def temp-table tt-erro NO-UNDO like tt-retorno-nota-fiscal.



def temp-table tt-total-refer no-undo
    field referencia     as char format "x(10)"
    field nr-doctos      as int
    field vendas-a-vista as dec format '->>>,>>>,>>9.99'
    field vendas-a-prazo as dec format '->>>,>>>,>>9.99'
    field vl-total       as dec format '->>>,>>>,>>9.99'
    INDEX ch-codigo      IS PRIMARY referencia.

def temp-table tt-total-refer-aux no-undo LIKE tt-total-refer.

DEFINE TEMP-TABLE tt-nf-ja-impressa NO-UNDO
    FIELD cod-estabel LIKE nota-fiscal.cod-estabel
    FIELD serie       LIKE nota-fiscal.serie
    FIELD nr-fatura   LIKE fat-duplic.nr-fatura
    FIELD parcela     LIKE fat-duplic.parcela
    FIELD cod-erro    AS CHARACTER FORMAT "x(10)"
    INDEX ch-parcel IS PRIMARY UNIQUE
          cod-estabel
          serie
          nr-fatura
          parcela
          cod-erro.


DEF TEMP-TABLE tt-fat-duplic-aux NO-UNDO
    LIKE fat-duplic
    FIELD r-rowid AS ROWID.


/*=========================================================================================*/





DEFINE VARIABLE h-acomp AS HANDLE      NO-UNDO.
DEF VAR h_bodi135     AS HANDLE  NO-UNDO.
DEF VAR l-cons-nota   AS LOGICAL NO-UNDO.
DEF VAR c-msg-retorno AS CHAR    NO-UNDO.
def var i-versao-api          as int                        no-undo.
def var da-cont               as date                       no-undo.
DEFINE VARIABLE i-time        AS INTEGER                    NO-UNDO.
def var i-empresa             like param-global.empresa-prin no-undo.
DEFINE VARIABLE l-ems5 AS LOGICAL     NO-UNDO.
DEFINE VARIABLE h-btb009za AS HANDLE      NO-UNDO.
DEFINE VARIABLE l-conecta AS LOGICAL     NO-UNDO.
DEFINE VARIABLE l-erro AS LOGICAL     NO-UNDO.
def var l-ja-conec-emsfin     as logical                    no-undo.
def var l-conec-bas           as logical                    no-undo.
def var l-conec-fin           as logical                    no-undo.
def var l-conec-uni           as logical                    no-undo.
def var l-ja-conec-emsuni     as logical                    no-undo.
def var l-ja-conec-emsbas     as logical                    no-undo.

def var c-referencia-aux      as char                       no-undo.
def var de-tot-geral-a-vista  as dec form "->>>,>>>,>>9.99" no-undo.
def var de-tot-geral-a-prazo  as dec form "->>>,>>>,>>9.99" no-undo.
def var de-tot-geral-vl-total as dec form "->>>,>>>,>>9.99" no-undo.
def var de-tot-a-vista-NFOK   as dec form "->>>,>>>,>>9.99" no-undo.
def var de-tot-a-prazo-NFOK   as dec form "->>>,>>>,>>9.99" no-undo.
def var de-tot-vl-total-NFOK  as dec form "->>>,>>>,>>9.99" no-undo.

def var c-sit            as char format "x(05)"  no-undo.
DEF VAR c-referencia     AS CHAR                 NO-UNDO.
DEF VAR c-cod-esp        AS CHAR                 NO-UNDO.
DEF VAR c-nr-docto       AS CHAR                 NO-UNDO.
DEF VAR i-port           AS INT                  NO-UNDO.
DEF VAR i-modalidade     AS INT                  NO-UNDO.
DEF VAR c-conta-contabil AS CHAR format "x(20)"  NO-UNDO.
DEF VAR c-centro-custo AS CHAR format "x(20)"  NO-UNDO.
def var i-parcela        as int  format "99"     no-undo.
DEF VAR c-desc-erro      AS CHAR FORMAT "x(153)" NO-UNDO.
DEF VAR c-cgc         AS CHAR NO-UNDO.


DEF BUFFER b-estabelec    FOR estabelec.
def buffer b-nota-fisc    for nota-fiscal.
DEF BUFFER b2-nota-fiscal FOR nota-fiscal.
DEF BUFFER b2-fat-duplic  FOR fat-duplic.
DEF BUFFER bf-fat-duplic  FOR fat-duplic.


/*******************************************************************/


form nota-fiscal.nome-ab-cli          at 1                         COLUMN-LABEL "Cliente"       
     nota-fiscal.cod-estabel          /* AT 14  */                 COLUMN-LABEL "Estab"
      nota-fiscal.serie               /* AT 20  */                 COLUMN-LABEL "Serie"
     c-cod-esp                        /* AT 26  */  FORMAT "x(02)" COLUMN-LABEL "Esp"
     c-nr-docto                       /* AT 30  */                 COLUMN-LABEL "Docto"
     i-parcela                        /* AT 40  */                 COLUMN-LABEL "Pa"
     fat-duplic.vl-parcela            /*        */                 COLUMN-LABEL "Valor Bruto"
     fat-duplic.dt-venciment          /*        */                 COLUMN-LABEL "Vencimento"
     fat-duplic.cod-vencto            /* AT 72  */ FORMAT "99"     COLUMN-LABEL "CV"
     i-port                           /* AT 75  */ FORMAT ">>>>9"  COLUMN-LABEL "Port"
     i-modalidade                     /* AT 81  */ FORMAT "9"      COLUMN-LABEL "M"
     nota-fiscal.nat-operacao         /* AT 83  */                 COLUMN-LABEL "Nat Ope"
     tt-retorno-nota-fiscal.cod-erro  /* AT 93  */                 COLUMN-LABEL "Mensagem"
     c-desc-erro                      /* AT 120 */                 COLUMN-LABEL "Descricao"
     with width 255 stream-io DOWN frame f-consitencia.

form emitente.nome-abrev         at 1                              COLUMN-LABEL "Nome Abrev"       
     nota-fiscal.cod-estabel          /* AT 14  */                 COLUMN-LABEL "Estab"
      nota-fiscal.serie               /* AT 20  */                 COLUMN-LABEL "Serie"
     c-cod-esp                        /* AT 26  */  FORMAT "x(02)" COLUMN-LABEL "Esp"
     c-nr-docto                       /* AT 30  */                 COLUMN-LABEL "Docto"
     i-parcela                        /* AT 40  */                 COLUMN-LABEL "Pa"
     fat-duplic.vl-parcela            /*        */                 COLUMN-LABEL "Valor Bruto"
     fat-duplic.dt-venciment          /*        */                 COLUMN-LABEL "Vencimento"
     fat-duplic.cod-vencto            /* AT 72  */ FORMAT "99"     COLUMN-LABEL "CV"
     i-port                           /* AT 75  */ FORMAT ">>>>9"  COLUMN-LABEL "Port"
     i-modalidade                     /* AT 81  */ FORMAT "9"      COLUMN-LABEL "M"
     nota-fiscal.nat-operacao         /* AT 83  */                 COLUMN-LABEL "Nat Ope"
     tt-retorno-nota-fiscal.cod-erro  /* AT 93  */                 COLUMN-LABEL "Mensagem"
     c-desc-erro                      /* AT 120 */                 COLUMN-LABEL "Descricao"
     with width 255 stream-io DOWN frame f-consitencia-emit.





/** =========================================  Bloco Principal ============================================== **/


RUN utp\ut-acomp.p PERSISTENT SET h-acomp.



find first param-global no-lock no-error.
find first para-ped     no-lock no-error.
find first b-estabelec where b-estabelec.cons-cent-vend no-lock no-error.
find first para-fat no-lock no-error.



 {include/i-rpout.i}          

 view frame f-cabec. 
 view frame f-rodape.


assign i-empresa = param-global.empresa-prin .

if can-find(funcao where funcao.cd-funcao = "adm-acr-ems-5.00" 
                     and funcao.ativo     = yes
                     and funcao.log-1     = yes) then 
    assign l-ems5 = yes.



RUN dibo/bodi135.p PERSISTENT SET h_bodi135.
 

RUN pi-inicializar IN h-acomp (INPUT "Lendos Notas").

// Leitura notas fiscais
RUN _pi_leitura_notas.


IF NOT VALID-HANDLE(h-btb009za) THEN
    RUN btb/btb009za.p PERSISTENT SET h-btb009za. 

if l-ems5 then do:
    assign l-conecta = yes.
    run pi-conecta-ems-5 (input l-conecta,
                          input i-empresa,
                          output l-erro). /* EMS5 */
end.

{utp/ut-liter.i Atualizando_Contas_Receber *}
run pi-acompanhar in h-acomp (input trim(return-value)).
assign i-versao-api = 3.


IF NOT l-erro THEN DO:

    RUN _pi_atualiza_acr.
END.

if l-ems5 then do:
    assign l-conecta = no.
    run pi-conecta-ems-5 (input l-conecta,
                          input i-empresa,
                          output l-erro). /* EMS5 */
end.


FOR EACH tt-retorno-nota-fiscal
    WHERE tt-retorno-nota-fiscal.cod-erro <> "9999"
    AND   tt-retorno-nota-fiscal.cod-erro <> "0000"
    AND   tt-retorno-nota-fiscal.situacao  = YES:

    DELETE tt-retorno-nota-fiscal.
END.

if valid-handle(h-btb009za) then
    delete procedure h-btb009za.

for each tt-erro :
  create tt-retorno-nota-fiscal.
  buffer-copy tt-erro to tt-retorno-nota-fiscal no-error.  
end.  


// Mostra log com o resultado do processo
RUN _pi_show_log.

{include/i-rpclo.i} 


IF VALID-HANDLE(h_bodi135) THEN
    DELETE PROCEDURE h_bodi135.


RUN pi-finalizar IN h-acomp.

RETURN "OK".

/***************************************** procedures internas ************************************************/

PROCEDURE _pi_show_log:

DEFINE VARIABLE i-cont AS INTEGER     NO-UNDO.


assign c-referencia-aux      = ""
       /* Total de todas as notas fiscais lidas  */
       de-tot-geral-a-vista  = 0
       de-tot-geral-a-prazo  = 0
       de-tot-geral-vl-total = 0
       /* Totais das notas que foram atualizadas */
       de-tot-a-vista-NFOK   = 0
       de-tot-a-prazo-NFOK   = 0
       de-tot-vl-total-NFOK  = 0.

for each tt-total-refer:
    /* Totalizaá∆o de todas as notas fiscais lidas  */
    assign de-tot-geral-a-vista  = de-tot-geral-a-vista  + tt-total-refer.vendas-a-vista
           de-tot-geral-a-prazo  = de-tot-geral-a-prazo  + tt-total-refer.vendas-a-prazo
           de-tot-geral-vl-total = de-tot-geral-vl-total + tt-total-refer.vl-total.
end.

for each tt-retorno-nota-fiscal
    break by tt-retorno-nota-fiscal.tipo
          by entry(1, tt-retorno-nota-fiscal.cod-chave, ","):

   if  tt-retorno-nota-fiscal.situacao then
       {utp/ut-liter.i Sim *}
   else
       {utp/ut-liter.i Nao *}
   assign c-sit = trim(return-value).

   if  tt-retorno-nota-fiscal.situacao 
   and tt-retorno-nota-fiscal.cod-erro = "0" then 
       next.

   /* Totais das notas que foram atualizadas */
   if  tt-retorno-nota-fiscal.cod-erro = "9999" then
       for each tt-total-refer
           where tt-total-refer.referencia = entry(1, tt-retorno-nota-fiscal.cod-chave, ","):
           assign de-tot-a-vista-NFOK   = de-tot-a-vista-NFOK  + tt-total-refer.vendas-a-vista
                  de-tot-a-prazo-NFOK   = de-tot-a-prazo-NFOK  + tt-total-refer.vendas-a-prazo
                  de-tot-vl-total-NFOK  = de-tot-vl-total-NFOK + tt-total-refer.vl-total.
       end.

   if  num-entries(tt-retorno-nota-fiscal.cod-chave,",") < 10 then
       assign tt-retorno-nota-fiscal.cod-chave = tt-retorno-nota-fiscal.cod-chave + ", , , , , , , , ,".

   if first-of(entry(1, tt-retorno-nota-fiscal.cod-chave, ","))
   OR entry(1, tt-retorno-nota-fiscal.cod-chave, ",") = "" then DO:
      ASSIGN c-referencia = entry(1, tt-retorno-nota-fiscal.cod-chave, ","). 
   /*   Put skip(2)
          "Referencia :" at 1 
          c-referencia   at 14 skip.*/
   END.

   assign c-referencia-aux = entry(1, tt-retorno-nota-fiscal.cod-chave, ",").

   find first nota-fiscal 
       where nota-fiscal.cod-estabel = entry(4, tt-retorno-nota-fiscal.cod-chave, ",")
         and nota-fiscal.serie = entry(6, tt-retorno-nota-fiscal.cod-chave, ",")
         and nota-fiscal.nr-fatura = entry(7, tt-retorno-nota-fiscal.cod-chave, ",") NO-LOCK no-error.    

   IF NOT AVAIL nota-fiscal THEN
       find first nota-fiscal  
           where nota-fiscal.cod-estabel = entry(4, tt-retorno-nota-fiscal.cod-chave, ",")
             and nota-fiscal.serie       = entry(6, tt-retorno-nota-fiscal.cod-chave, ",")
             and nota-fiscal.nr-nota-fis = entry(7, tt-retorno-nota-fiscal.cod-chave, ",") NO-LOCK no-error.     


   find first fat-repre 
       where fat-repre.cod-estabel = entry(4, tt-retorno-nota-fiscal.cod-chave, ",")
         and fat-repre.serie       = entry(6, tt-retorno-nota-fiscal.cod-chave, ",")
         and fat-repre.nr-fatura   = entry(7, tt-retorno-nota-fiscal.cod-chave, ",")
         and fat-repre.nome-ab-rep = nota-fiscal.no-ab-reppri NO-LOCK no-error.


   ASSIGN c-cod-esp  = entry(5, tt-retorno-nota-fiscal.cod-chave, ",")
          c-nr-docto = entry(7, tt-retorno-nota-fiscal.cod-chave, ",").

   ASSIGN i-port = 0.

   IF AVAIL nota-fiscal THEN DO:
        find first fat-duplic 
        where fat-duplic.cod-estabel = nota-fiscal.cod-estabel
          and fat-duplic.serie      = nota-fiscal.serie
          and fat-duplic.nr-fatura  = nota-fiscal.nr-fatura
          AND fat-duplic.cod-esp    = "CV"
          AND fat-duplic.int-1      = 99501 no-error.

    END.
    ELSE IF AVAIL nota-fiscal THEN DO:
        find first fat-duplic 
        where fat-duplic.cod-estabel = nota-fiscal.cod-estabel
          and fat-duplic.serie      = nota-fiscal.serie
          and fat-duplic.nr-fatura  = nota-fiscal.nr-fatura
          AND fat-duplic.cod-esp    = "CV"
          AND fat-duplic.int-1      = 93102 no-error.
    
    END.
    ELSE IF AVAIL nota-fiscal AND nota-fiscal.cod-portador = 99999 THEN DO:
        find first fat-duplic 
        where fat-duplic.cod-estabel = nota-fiscal.cod-estabel
          and fat-duplic.serie = nota-fiscal.serie
          and fat-duplic.nr-fatura = nota-fiscal.nr-fatura
          AND fat-duplic.cod-esp = "NF" no-error.

    END.
    ELSE IF AVAIL nota-fiscal THEN DO:
        Find FIRST  fat-duplic 
        where fat-duplic.cod-estabel = nota-fiscal.cod-estabel
          and fat-duplic.serie = nota-fiscal.serie
          and fat-duplic.nr-fatura = nota-fiscal.nr-fatura
          AND fat-duplic.cod-esp = "CE" no-error.


    END.
    ELSE IF AVAIL nota-fiscal THEN DO:

        Find FIRST fat-duplic 
        where fat-duplic.cod-estabel = nota-fiscal.cod-estabel
          and fat-duplic.serie = nota-fiscal.serie
          and fat-duplic.nr-fatura = nota-fiscal.nr-fatura
          AND fat-duplic.cod-esp = "CA" no-error.

    END.
    ELSE IF AVAIL nota-fiscal THEN DO:
        Find FIRST  fat-duplic 
        where fat-duplic.cod-estabel = nota-fiscal.cod-estabel
          and fat-duplic.serie = nota-fiscal.serie
          and fat-duplic.nr-fatura = nota-fiscal.nr-fatura
          AND fat-duplic.cod-esp = "CR" no-error.

    END.

    ASSIGN i-modalidade = 0.
    IF AVAIL fat-duplic THEN DO:
        ASSIGN i-modalidade = IF tt-param.i-cod-portador <> 0 AND fat-duplic.cod-vencto = 3 THEN 1
                              ELSE
                                 IF nota-fiscal.modalidade <> 0 THEN nota-fiscal.modalidade
                                 ELSE 1.
    END.

   ASSIGN c-conta-contabil = "".
   ASSIGN c-centro-custo = "".
   assign i-parcela = if avail fat-duplic then int(fat-duplic.parcela) else 0.

   
   IF AVAIL fat-duplic AND fat-duplic.flag-atualiz = YES THEN DO: 

        FOR EACH fat-duplic 
        where  fat-duplic.cod-estabel  = nota-fiscal.cod-estabel
          and  fat-duplic.serie        = nota-fiscal.serie
          AND  fat-duplic.nr-fatura    = nota-fiscal.nr-fatura
          /*
          AND (fat-duplic.cod-esp      = "CV" OR
               fat-duplic.cod-esp      = "CE" OR
               fat-duplic.cod-esp      = "CA" OR
               fat-duplic.cod-esp      = "NF")
               
          */
            AND (fat-duplic.INT-1 =  99501 
                or   fat-duplic.int-1 =  99301
                or   fat-duplic.int-1 =  99701 
                or   fat-duplic.int-1 =  99801
                or   fat-duplic.int-1 =  91801
                or   fat-duplic.int-1 =  99999
                or   fat-duplic.int-1 =  99201
                or   fat-duplic.int-1 =  93102
                or   fat-duplic.int-1 =  0)
               
          AND  fat-duplic.flag-atualiz = YES  NO-LOCK:  

    /*       IF fat-duplic.int-1 <> 99501 THEN DO:   /* portador convenio */             */
    /*                                                                                   */
    /*           FIND FIRST natur-oper NO-LOCK WHERE                                     */
    /*                      natur-oper.nat-operacao = nota-fiscal.nat-operacao NO-ERROR. */
    /*                                                                                   */
    /*           IF natur-oper.cod-cfop <> '6933' AND                                    */
    /*              natur-oper.cod-cfop <> '5933' THEN NEXT.                             */
    /*                                                                                   */
    /*       END.                                                                        */
    
          FIND FIRST tt-nf-ja-impressa NO-LOCK
               WHERE tt-nf-ja-impressa.cod-estabel = nota-fiscal.cod-estabel
               AND   tt-nf-ja-impressa.serie       = nota-fiscal.serie
               AND   tt-nf-ja-impressa.nr-fatura   = nota-fiscal.nr-fatura
               AND   tt-nf-ja-impressa.parcela     = fat-duplic.parcela
               AND   tt-nf-ja-impressa.cod-erro    = tt-retorno-nota-fiscal.cod-erro NO-ERROR.
    
          IF  AVAIL tt-nf-ja-impressa THEN
              NEXT.
    
          CREATE tt-nf-ja-impressa.
          ASSIGN tt-nf-ja-impressa.cod-estabel = nota-fiscal.cod-estabel
                 tt-nf-ja-impressa.serie       = nota-fiscal.serie
                 tt-nf-ja-impressa.nr-fatura   = nota-fiscal.nr-fatura
                 tt-nf-ja-impressa.parcela     = fat-duplic.parcela
                 tt-nf-ja-impressa.cod-erro    = tt-retorno-nota-fiscal.cod-erro.
    
          ASSIGN i-port = IF NOT fat-duplic.log-1 THEN
                             IF tt-param.i-cod-portador <> 0 AND fat-duplic.cod-vencto = 3 THEN tt-param.i-cod-portador
                             ELSE nota-fiscal.cod-portador
                          ELSE fat-duplic.int-1.
    
    
            ASSIGN c-conta-contabil = fat-duplic.ct-recven
                   c-centro-custo   = fat-duplic.sc-recven.
    
            ASSIGN i-cont = 1.
            RUN pi-print-editor (tt-retorno-nota-fiscal.desc-erro, 153).
            FOR EACH tt-editor WHERE
                     tt-editor.linha > 0:
                IF i-cont = 1 THEN
                   ASSIGN c-desc-erro = tt-editor.conteudo. 
                ASSIGN i-cont = i-cont + 1.
            END.
            /**/
    
            IF AVAIL nota-fiscal AND AVAIL fat-duplic AND (fat-duplic.cod-esp = "CV" AND (fat-duplic.int-1 = 99501 or fat-duplic.int-1 = 93102)) THEN DO:
    
                FIND FIRST emitente WHERE emitente.cod-emitente = nota-fiscal.cod-emitente NO-LOCK NO-ERROR.
    
                ASSIGN c-cgc = ''.
                
                FIND FIRST cst_nota_fiscal 
                     WHERE cst_nota_fiscal.cod_estabel = nota-fiscal.cod-estabel
                       AND cst_nota_fiscal.serie       = nota-fiscal.serie
                       AND cst_nota_fiscal.nr_nota_fis = nota-fiscal.nr-nota-fis  NO-LOCK  NO-ERROR.

                IF AVAIL cst_nota_fiscal THEN DO:
                    ASSIGN c-cgc = replace(cst_nota_fiscal.cpf_cupom,".","").
                           c-cgc = replace(c-cgc,"/","").
                           c-cgc = replace(c-cgc,"-","").
                           
                   IF emitente.cgc <> c-cgc THEN DO:
                       FIND FIRST emitente WHERE emitente.cgc =  c-cgc NO-LOCK NO-ERROR.
                   END.
                   ELSE DO:
                       FIND FIRST emitente WHERE emitente.cod-emitente = nota-fiscal.cod-emitente NO-LOCK NO-ERROR.
                   END.
                END.
                
                
                DISP emitente.nome-abrev WHEN AVAIL emitente
                     fat-duplic.cod-esp @ c-cod-esp
                     c-nr-docto
                     int(fat-duplic.parcela) FORMAT "99" @ i-parcela 
                     fat-duplic.vl-parcela  
                     fat-duplic.dt-venciment
                     fat-duplic.cod-vencto  
                     i-port
                     i-modalidade 
                     nota-fiscal.nat-operacao when avail nota-fiscal
                     tt-retorno-nota-fiscal.cod-erro
                     nota-fiscal.cod-estabel  WHEN avail nota-fiscal
                     nota-fiscal.serie        WHEN avail nota-fiscal  
                     c-desc-erro
                     with frame f-consitencia-emit.
                     down with frame f-consitencia-emit. 
    
    
    
            END.
            ELSE DO:
                DISP nota-fiscal.nome-ab-cli  WHEN avail nota-fiscal
                     fat-duplic.cod-esp @ c-cod-esp
                     c-nr-docto
                     int(fat-duplic.parcela) FORMAT "99" @ i-parcela 
                     fat-duplic.vl-parcela  
                     fat-duplic.dt-venciment
                     fat-duplic.cod-vencto  
                     i-port
                     i-modalidade 
                     nota-fiscal.nat-operacao when avail nota-fiscal
                     tt-retorno-nota-fiscal.cod-erro
                     nota-fiscal.cod-estabel  WHEN avail nota-fiscal
                     nota-fiscal.serie        WHEN avail nota-fiscal  
                     c-desc-erro
                     with frame f-consitencia.
                     down with frame f-consitencia. 
            END.
       END.
   END.
   ELSE DO:

        /**/
        ASSIGN i-cont = 1.
        RUN pi-print-editor (tt-retorno-nota-fiscal.desc-erro, 153).
        FOR EACH tt-editor WHERE
                 tt-editor.linha > 0:
            IF i-cont = 1 THEN
               ASSIGN c-desc-erro = tt-editor.conteudo. 
            ASSIGN i-cont = i-cont + 1.
        END.
        /**/

        IF c-cod-esp = "CV" OR c-cod-esp = "CE"  OR c-cod-esp = "CA" OR c-cod-esp = "CR" THEN DO:

            FIND FIRST emitente WHERE emitente.cod-emitente = nota-fiscal.cod-emitente NO-LOCK NO-ERROR.
    
            ASSIGN c-cgc = ''.
     
            
            
            
            FIND FIRST cst_nota_fiscal
                 WHERE cst_nota_fiscal.cod_estabel = nota-fiscal.cod-estabel
                   AND cst_nota_fiscal.serie       = nota-fiscal.serie
                   AND cst_nota_fiscal.nr_nota_fis = nota-fiscal.nr-nota-fis NO-LOCK  NO-ERROR.
            IF AVAIL cst_nota_fiscal THEN DO:
                ASSIGN c-cgc = replace(cst_nota_fiscal.cpf_cupom,".","").
                       c-cgc = replace(c-cgc,"/","").
                       c-cgc = replace(c-cgc,"-","").
                       
               IF emitente.cgc <> c-cgc THEN DO:
                   FIND FIRST emitente WHERE emitente.cgc =  c-cgc NO-LOCK NO-ERROR.
               END.
               ELSE DO:
                   FIND FIRST emitente WHERE emitente.cod-emitente = nota-fiscal.cod-emitente NO-LOCK NO-ERROR.
               END.
            END.
            

            DISP emitente.nome-abrev WHEN AVAIL emitente
                 c-cod-esp
                 c-nr-docto
                 i-parcela
                 fat-duplic.vl-parcela    when avail fat-duplic
                 fat-duplic.dt-venciment  when avail fat-duplic
                 fat-duplic.cod-vencto    when avail fat-duplic
                 i-port
                 i-modalidade 
                 nota-fiscal.nat-operacao when avail nota-fiscal
                 tt-retorno-nota-fiscal.cod-erro
                 nota-fiscal.cod-estabel  WHEN avail nota-fiscal
                 nota-fiscal.serie        WHEN avail nota-fiscal
                 c-desc-erro
                 with frame f-consitencia-emit.
            DOWN with frame f-consitencia-emit.


        END.
        ELSE DO:
           DISP nota-fiscal.nome-ab-cli  WHEN avail nota-fiscal
                c-cod-esp
                c-nr-docto
                i-parcela
                fat-duplic.vl-parcela    when avail fat-duplic
                fat-duplic.dt-venciment  when avail fat-duplic
                fat-duplic.cod-vencto    when avail fat-duplic
                i-port
                i-modalidade 
                nota-fiscal.nat-operacao when avail nota-fiscal
                tt-retorno-nota-fiscal.cod-erro
                nota-fiscal.cod-estabel  WHEN avail nota-fiscal
                nota-fiscal.serie        WHEN avail nota-fiscal
                c-desc-erro
                with frame f-consitencia.
           down with frame f-consitencia.
        END.

   END.



end.

if  de-tot-geral-a-vista  <> 0
or  de-tot-geral-a-prazo  <> 0 then do:
    if  line-counter > page-size - 10 then
        page.
    put skip(2).
    {utp/ut-liter.i Notas_Atualizadas * R}
    put trim(return-value) form "x(22)" at 20.
    {utp/ut-liter.i Notas_com_Problemas * R}
    put trim(return-value) form "x(22)" at 43
        skip
        "---------------------- ----------------------" at 20
        skip.
     {utp/ut-liter.i Vendas_π_Vista * R}
    assign de-tot-geral-a-vista = de-tot-geral-a-vista - de-tot-a-vista-NFOK.
    put (trim(return-value) + ":") form "x(18)" to 18
        de-tot-a-vista-NFOK at 20
        de-tot-geral-a-vista at 43
        skip.
    {utp/ut-liter.i Vendas_a_Prazo * R}
    assign de-tot-geral-a-prazo = de-tot-geral-a-prazo - de-tot-a-prazo-NFOK.
    put (trim(return-value) + ":") form "x(18)" to 18
        de-tot-a-prazo-NFOK at 20
        de-tot-geral-a-prazo at 43
        skip.
    {utp/ut-liter.i Total * R}
    assign de-tot-geral-vl-total = de-tot-geral-vl-total - de-tot-vl-total-NFOK.
    put (trim(return-value) + ":") form "x(18)" to 18
        de-tot-vl-total-NFOK at 20
        de-tot-geral-vl-total at 43.
end.



END PROCEDURE.

PROCEDURE _pi_leitura_notas:
    
    IF l-estab-security-active = YES THEN DO:
       {intprg/nicr028.i1 "and nota-fiscal.cod-estabel = {&ESTAB-SEC-TT-FIELD} "}
    END.
    ELSE DO:
       {intprg/nicr028.i1 " "}
    END. 

    /* KML - Marcar notas que n∆o geram financeiro como ja integrado ACR */
    FOR EACH nota-fiscal USE-INDEX nfftrm-20 no-lock
        where nota-fiscal.dt-emis-nota >= tt-param.da-emissao-ini 
        AND   nota-fiscal.dt-emis-nota <= tt-param.da-emissao-fim
        and   nota-fiscal.cod-estabel  >= tt-param.c-cod-estabel-ini
        and   nota-fiscal.cod-estabel  <= tt-param.c-cod-estabel-fim
        and   nota-fiscal.serie        >= tt-param.c-serie-ini
        and   nota-fiscal.serie        <= tt-param.c-serie-fim
        and   nota-fiscal.nr-nota-fis  >= tt-param.c-nr-nota-ini
        and   nota-fiscal.nr-nota-fis  <= tt-param.c-nr-nota-fim
        and   nota-fiscal.dt-cancela   = ?
        AND   nota-fiscal.dt-atual-cr  = ? ,
         EACH natur-oper NO-LOCK
        WHERE natur-oper.nat-operacao = nota-fiscal.nat-operacao
          AND natur-oper.emite-duplic = NO :
    

        run pi-acompanhar in h-acomp ("Atualizando transf: " +
                                      STRING(nota-fiscal.dt-emis-nota) + " - " +
                                      STRING(nota-fiscal.nr-nota-fis)).
        FIND FIRST b-nota-fisc EXCLUSIVE-LOCK
            WHERE rowid(b-nota-fisc) = ROWID(nota-fiscal) NO-ERROR.
        
        IF AVAIL b-nota-fisc THEN DO:
            ASSIGN b-nota-fisc.dt-atual-cr = TODAY.
    
        END.
    
        RELEASE b-nota-fisc.
    END.                    

END PROCEDURE.

procedure pi-conecta-ems-5:

    def input param l-conecta as logical no-undo.
    def input param p-empresa like param-global.empresa-prin no-undo.
    def output param l-erro   as logical no-undo.

    assign l-erro = no.

    if  l-conecta then do:

        if  search("prgfin/acr/acr900zf.r":U)  = ? 
        and search("prgfin/acr/acr900zf.py":U) = ? then do:

            run utp/ut-msgs.p (input "msg":U,
                               input 6246,
                               input "prgfin/acr/acr900zf.py":U).
            create tt-retorno-nota-fiscal.
            assign tt-retorno-nota-fiscal.tipo         = 1
                   tt-retorno-nota-fiscal.cod-erro  = "6246":U
                   tt-retorno-nota-fiscal.cod-chave = ",,,,,,,,,"
                   tt-retorno-nota-fiscal.desc-erro = return-value
                   tt-retorno-nota-fiscal.situacao  = no.
            assign l-erro = yes.                                

        end.
        else do:
            if  connected("emsuni") 
                then assign l-ja-conec-emsuni = yes.
                else assign l-ja-conec-emsuni = no.

            if  connected("emsbas") 
                then assign l-ja-conec-emsbas = yes.
                else assign l-ja-conec-emsbas = no.

            if  connected("emsfin") 
                then assign l-ja-conec-emsfin = yes.
                else assign l-ja-conec-emsfin = no.

            if  l-ja-conec-emsuni = no or 
                l-ja-conec-emsbas = no or
                l-ja-conec-emsfin = no then do:

                {utp/ut-liter.i Conex∆o_Bancos_Externos_EMS5 *}
                run pi-acompanhar in h-acomp (input  Return-value ).
                IF VALID-HANDLE(h-btb009za) THEN
                    run pi-conecta-bco IN h-btb009za (Input 1, /* Versao API  */
                                                      input 1, /* 1 - conexao, 2 - Desconexao */
                                                      input p-empresa, /* Codigo da empresa */
                                                      input "all":U, /* nome do banco */
                                                      output table tt_erros_conexao). /* temp-table de erros */
                if  return-value <> "OK":U then do:
                    find first tt_erros_conexao no-lock no-error.
                    if avail tt_erros_conexao then do:
                        create tt-retorno-nota-fiscal.
                        assign tt-retorno-nota-fiscal.tipo   = 1
                            tt-retorno-nota-fiscal.cod-erro  = string(tt_erros_conexao.cd-erro)
                            tt-retorno-nota-fiscal.desc-erro = tt_erros_conexao.param-1
                            tt-retorno-nota-fiscal.cod-chave = ",":U + ",":U + ",":U + ",":U + ",":U + ",":U + ",":U + ",":U
                            tt-retorno-nota-fiscal.situacao  = no.
                        assign l-erro = yes.                                              
                    end.               
                end.                
            end. 
        end.
    end.

    if  not l-conecta or l-erro then do:
        if l-ja-conec-emsuni = no 
        or l-ja-conec-emsbas = no 
        or l-ja-conec-emsfin = no then do: 

            {utp/ut-liter.i Desconex∆o_Bancos_Externos_EMS5 *}
            run pi-acompanhar in h-acomp (input  Return-value ).
            IF VALID-HANDLE(h-btb009za) THEN
                run pi-conecta-bco IN h-btb009za (Input 1, /* Versao API  */
                                                  input 2, /* 1 - conexao, 2 - Desconexao */
                                                  input p-empresa, /* Codigo da empresa */
                                                  input "all":U, /* nome do banco */
                                                  output table tt_erros_conexao). /* temp-table de erros */
            if return-value <> "OK":U then do:
                find first tt_erros_conexao no-lock no-error.
                if avail tt_erros_conexao then do:
                    create tt-retorno-nota-fiscal.
                    assign tt-retorno-nota-fiscal.tipo   = 1
                        tt-retorno-nota-fiscal.cod-erro  = string(tt_erros_conexao.cd-erro)
                        tt-retorno-nota-fiscal.desc-erro = tt_erros_conexao.param-1
                        tt-retorno-nota-fiscal.cod-chave = ",":U + ",":U + ",":U + ",":U + ",":U + ",":U + ",":U + ",":U
                        tt-retorno-nota-fiscal.situacao  = no.
                    assign l-erro = yes.                                              
                end.
            end.
        end.
    end.   

END PROCEDURE.          


PROCEDURE _pi_atualiza_acr:


    DEFINE VARIABLE c-arquivo-exp AS CHARACTER   NO-UNDO.

    ASSIGN c-arquivo-exp = session:TEMP-DIRECTORY  + "lin-i-cr.d".


    // verificar as duplicatas que n∆o serao atualizadas nesse processo
    tt-nota:
    FOR EACH tt-nota-fiscal,
        FIRST nota-fiscal WHERE 
              ROWID(nota-fiscal) = r-nota-fiscal:
    
        // buscar somente as nao atualizadas 
        FOR EACH fat-duplic NO-LOCK
            WHERE fat-duplic.nr-fatura   = nota-fiscal.nr-nota-fis
              AND fat-duplic.serie       = nota-fiscal.serie
              AND fat-duplic.cod-estabel = nota-fiscal.cod-estabel
              AND fat-duplic.flag-atualiz = NO
              AND (fat-duplic.int-1 <> 99501 AND 
                   fat-duplic.int-1 <> 99801 AND /* Convenio */   
                   fat-duplic.int-1 <> 99301 AND
                   fat-duplic.int-1 <> 99201 AND
                   fat-duplic.int-1 <> 91801 AND 
                   fat-duplic.int-1 <> 93102 AND /* Convenio Medme */
                   fat-duplic.int-1 <> 0):


               FIND FIRST tt-fat-duplic-aux 
                    WHERE tt-fat-duplic-aux.cod-estabel = fat-duplic.cod-estabel
                    AND   tt-fat-duplic-aux.serie       = fat-duplic.serie
                    AND   tt-fat-duplic-aux.nr-fatura   = fat-duplic.nr-fatura
                    AND   tt-fat-duplic-aux.ind-fat-nota = fat-duplic.ind-fat-nota
                    AND   tt-fat-duplic-aux.parcela      = fat-duplic.parcela
                    NO-ERROR.

               IF NOT AVAIL tt-fat-duplic-aux THEN DO:

                   CREATE tt-fat-duplic-aux.
                   BUFFER-COPY fat-duplic TO tt-fat-duplic-aux no-error.
                   ASSIGN tt-fat-duplic-aux.r-rowid = ROWID(fat-duplic).

               END.

        END.
    END.
    

    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-total-refer-aux.

    IF CAN-FIND(FIRST tt-nota-fiscal) 
    THEN DO:

         atualizacao:
         do transaction on error undo atualizacao, leave atualizacao
                       on STOP  undo atualizacao, leave atualizacao:

            // marcar as duplicatas que nao sao de convenio como atualizadas
            FOR EACH tt-fat-duplic-aux:

                FOR FIRST bf-fat-duplic EXCLUSIVE-LOCK
                   WHERE  ROWID(bf-fat-duplic) = tt-fat-duplic-aux.r-rowid:

                   ASSIGN bf-fat-duplic.flag-atualiz = YES.
                END.

                RELEASE bf-fat-duplic.
            END.


            run ftp/ftapi001.p (input  i-versao-api,
                              input  tt-param.i-pais,
                                input  tt-param.i-cod-portador,             /* Notas Normais */
                                input  tt-param.rs-gera-titulo,
                                input  c-arquivo-exp,
                                input  table tt-nota-fiscal,
                                output table tt-retorno-nota-fiscal,
                                output table tt-total-refer).

            
            // voltar as duplicatas que nao sao de convenio como atualizadas
            FOR EACH tt-fat-duplic-aux:

                FOR FIRST bf-fat-duplic EXCLUSIVE-LOCK
                   WHERE  ROWID(bf-fat-duplic) = tt-fat-duplic-aux.r-rowid:

                   ASSIGN bf-fat-duplic.flag-atualiz = NO.
                END.

                RELEASE bf-fat-duplic.
            END.



         END. // atualizacao

         /* buscar a tit_Ar dos titulos gerados e chamar a procedure abaixo. KML */

         FOR EACH tt-nota-fiscal:

             FIND FIRST nota-fiscal NO-LOCK
                 WHERE ROWID(nota-fiscal) = tt-nota-fiscal.r-nota-fiscal NO-ERROR.

             IF AVAIL nota-fiscal THEN DO:
                 
                 FOR EACH fat-duplic NO-LOCK
                     WHERE fat-duplic.cod-estabel   = nota-fiscal.cod-estabel
                       AND fat-duplic.serie         = nota-fiscal.serie
                       AND fat-duplic.nr-fatura     = nota-fiscal.nr-nota-fis:

                     IF fat-duplic.cod-esp = "CA" THEN DO:

                        FIND FIRST tit_acr NO-LOCK
                             WHERE tit_acr.cod_estab        = fat-duplic.cod-estabel 
                               AND tit_acr.cod_ser_docto    = fat-duplic.serie
                               AND tit_acr.cod_tit_acr      = fat-duplic.nr-fatura
                               AND tit_acr.cod_espec_docto  = fat-duplic.cod-esp
                               AND tit_acr.cod_parcela      = fat-duplic.parcela NO-ERROR.

                         IF AVAIL tit_acr THEN DO:

                            RUN piCriaAlteracaoTaxaCartao(INPUT tit_acr.cod_estab,
                                                          INPUT tit_acr.num_id_tit_acr,
                                                          INPUT "CASHBACK",
                                                          INPUT tit_acr.val_sdo_tit_acr,
                                                          INPUT "Alteraá∆o do T°tulo devido a destinaá∆o do cashback",
                                                          OUTPUT lErro).

                         END.                      

                     END.

                 END.
             END.
         END.

        FOR EACH tt-retorno-nota-fiscal:

            CREATE tt-erro.
            BUFFER-COPY tt-retorno-nota-fiscal TO tt-erro no-error.
        END.
    
        FOR EACH tt-total-refer:

            CREATE tt-total-refer-aux.
            BUFFER-COPY tt-total-refer TO tt-total-refer-aux no-error.
        END.
        
        EMPTY TEMP-TABLE tt-retorno-nota-fiscal.
        EMPTY TEMP-TABLE tt-total-refer.

    END.

    FOR EACH tt-erro:

        CREATE tt-retorno-nota-fiscal.
        BUFFER-COPY tt-erro TO tt-retorno-nota-fiscal no-error.

    END.

    FOR EACH tt-total-refer-aux:

        CREATE tt-total-refer.
        BUFFER-COPY tt-total-refer-aux TO tt-total-refer no-error.

    END.

    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-total-refer-aux.


   RETURN "OK".

END PROCEDURE.


PROCEDURE piCriaAlteracaoTaxaCartao:
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    DEF INPUT  PARAM p-cod-estab         AS CHAR                                 NO-UNDO.
    DEF INPUT  PARAM p-tit-acr           AS INT                                  NO-UNDO.
    DEF INPUT  PARAM p-tipo              AS CHAR                                 NO-UNDO.
    DEF INPUT  PARAM p-valor             AS DECIMAL                              NO-UNDO.
    DEF INPUT  PARAM p-historico         AS CHAR  FORMAT "x(2000)"               NO-UNDO.
    DEF OUTPUT PARAM l-erro              AS LOGICAL  INITIAL NO                  NO-UNDO.

    DEFINE VARIABLE c_cod_refer       AS CHARACTER                    NO-UNDO.
    DEFINE VARIABLE v_hdl_program     AS HANDLE    FORMAT ">>>>>>9":U NO-UNDO.
    DEFINE VARIABLE v_log_integr_cmg  AS LOGICAL   FORMAT "Sim/Nío":U INITIAL NO LABEL "CMG" COLUMN-LABEL "CMG" NO-UNDO.

    EMPTY TEMP-TABLE tt_alter_tit_acr_base_5         NO-ERROR.
    EMPTY TEMP-TABLE tt_alter_tit_acr_rateio         NO-ERROR.
    EMPTY TEMP-TABLE tt_alter_tit_acr_ped_vda        NO-ERROR.
    EMPTY TEMP-TABLE tt_alter_tit_acr_comis_1        NO-ERROR.
    EMPTY TEMP-TABLE tt_alter_tit_acr_cheq           NO-ERROR.      
    EMPTY TEMP-TABLE tt_alter_tit_acr_iva            NO-ERROR.          
    EMPTY TEMP-TABLE tt_alter_tit_acr_impto_retid_2  NO-ERROR.
    EMPTY TEMP-TABLE tt_alter_tit_acr_cobr_espec_2   NO-ERROR. 
    EMPTY TEMP-TABLE tt_alter_tit_acr_rat_desp_rec   NO-ERROR. 
    EMPTY TEMP-TABLE tt_log_erros_alter_tit_acr      NO-ERROR.    

    FIND FIRST tt_alter_tit_acr_base_5 EXCLUSIVE-LOCK
         WHERE tt_alter_tit_acr_base_5.tta_cod_estab      = tit_acr.cod_estab
           AND tt_alter_tit_acr_base_5.tta_num_id_tit_acr = tit_acr.num_id_tit_acr NO-ERROR.
    IF NOT AVAIL tt_alter_tit_acr_base_5 THEN DO:
        CREATE tt_alter_tit_acr_base_5.
        ASSIGN tt_alter_tit_acr_base_5.tta_cod_estab      = tit_acr.cod_estab
               tt_alter_tit_acr_base_5.tta_num_id_tit_acr = tit_acr.num_id_tit_acr.
    END.

    ASSIGN c_cod_refer = "".
    RUN pi_retorna_sugestao_referencia (INPUT  "DS",
                                        INPUT  TODAY,
                                        OUTPUT c_cod_refer,
                                        INPUT  "tit_acr",
                                        INPUT  STRING(tit_acr.cod_estab)).

    ASSIGN tt_alter_tit_acr_base_5.tta_dat_transacao               = tit_acr.dat_transacao
           tt_alter_tit_acr_base_5.tta_cod_refer                   = CAPS(c_cod_refer)
           tt_alter_tit_acr_base_5.ttv_cod_motiv_movto_tit_acr_imp = ?
           tt_alter_tit_acr_base_5.tta_val_sdo_tit_acr             = tit_acr.val_sdo_tit_acr - p-valor
           tt_alter_tit_acr_base_5.tta_val_liq_tit_acr             = tt_alter_tit_acr_base_5.tta_val_sdo_tit_acr
           tt_alter_tit_acr_base_5.ttv_cod_motiv_movto_tit_acr_alt = p-tipo
           tt_alter_tit_acr_base_5.ttv_ind_motiv_acerto_val        = "Alteraá∆o":U
           tt_alter_tit_acr_base_5.tta_cod_portador                = tit_acr.cod_portador
           tt_alter_tit_acr_base_5.tta_cod_cart_bcia               = tit_acr.cod_cart_bcia
           tt_alter_tit_acr_base_5.tta_val_despes_bcia             = tit_acr.val_despes_bcia
           tt_alter_tit_acr_base_5.tta_cod_agenc_cobr_bcia         = ""
           tt_alter_tit_acr_base_5.tta_cod_tit_acr_bco             = ""
           tt_alter_tit_acr_base_5.tta_dat_emis_docto              = tit_acr.dat_emis_docto
           tt_alter_tit_acr_base_5.tta_dat_vencto_tit_acr          = tit_acr.dat_vencto_tit_acr
           tt_alter_tit_acr_base_5.tta_dat_prev_liquidac           = tit_acr.dat_prev_liquidac
           tt_alter_tit_acr_base_5.tta_dat_fluxo_tit_acr           = IF tit_acr.dat_fluxo_tit_acr > tit_acr.dat_emis_docto THEN tit_acr.dat_fluxo_tit_acr ELSE tit_acr.dat_emis_docto
           tt_alter_tit_acr_base_5.tta_ind_sit_tit_acr             = tit_acr.ind_sit_tit_acr
           tt_alter_tit_acr_base_5.tta_cod_cond_cobr               = tit_acr.cod_cond_cobr
           tt_alter_tit_acr_base_5.tta_log_tip_cr_perda_dedut_tit  = tit_acr.log_tip_cr_perda_dedut_tit
           tt_alter_tit_acr_base_5.tta_log_tit_acr_destndo         = tit_acr.log_tit_acr_destndo
           tt_alter_tit_acr_base_5.ttv_cod_portador_mov            = ""
           tt_alter_tit_acr_base_5.tta_ind_tip_cobr_acr            = tit_acr.ind_tip_cobr_acr
           &if '{&emsfin_version}' >= "5.02" &then
               tt_alter_tit_acr_base_5.tta_des_obs_cobr            = tit_acr.des_obs_cobr
           &endif
           tt_alter_tit_acr_base_5.ttv_log_estorn_impto_retid      = NO
           tt_alter_tit_acr_base_5.tta_cod_histor_padr             = ""
           tt_alter_tit_acr_base_5.ttv_des_text_histor             = p-historico
           tt_alter_tit_acr_base_5.tta_cdn_repres                  = tit_acr.cdn_repres
           tt_alter_tit_acr_base_5.tta_cod_instruc_bcia_1_movto    = tit_acr.cod_instruc_bcia_1_acr  
           tt_alter_tit_acr_base_5.tta_cod_instruc_bcia_2_movto    = tit_acr.cod_instruc_bcia_2_acr
           .
/*

                                                                                                                                                                       
        create tt_alter_tit_acr_rateio.
        assign tt_alter_tit_acr_rateio.tta_cod_estab                    = tit_acr.cod_estab
               tt_alter_tit_acr_rateio.tta_num_id_tit_acr               = tit_acr.num_id_tit_acr
               tt_alter_tit_acr_rateio.tta_cod_refer                    = CAPS(c_cod_refer)
               tt_alter_tit_acr_rateio.tta_num_seq_refer                = 1
               tt_alter_tit_acr_rateio.tta_cod_plano_cta_ctbl           = "PADRAO"
               tt_alter_tit_acr_rateio.tta_cod_cta_ctbl                 = "21106110"
               tt_alter_tit_acr_rateio.tta_cod_unid_negoc               = "000"
               tt_alter_tit_acr_rateio.tta_cod_plano_ccusto             = ""
               tt_alter_tit_acr_rateio.tta_cod_ccusto                   = ""
               tt_alter_tit_acr_rateio.tta_cod_tip_fluxo_financ         = ""
               tt_alter_tit_acr_rateio.tta_val_aprop_ctbl               = tit_acr.val_sdo_tit_acr - p-valor
               tt_alter_tit_acr_rateio.tta_num_seq_aprop_ctbl_pend_acr  = 1
               tt_alter_tit_acr_rateio.ttv_ind_tip_rat_tit_acr          = "Alteraá∆o"
               tt_alter_tit_acr_rateio.tta_dat_transacao                =  tit_acr.dat_transacao. 

*/


    run prgfin/acr/acr711zv.py persistent set v_hdl_program /*prg_api_integr_acr_alter_tit_acr_novo_7*/.
    RUN pi_main_code_integr_acr_alter_tit_acr_novo_12 in v_hdl_program (Input 12,
                                                                        Input table  tt_alter_tit_acr_base_5,
                                                                        Input table  tt_alter_tit_acr_rateio,
                                                                        Input table  tt_alter_tit_acr_ped_vda,
                                                                        Input table  tt_alter_tit_acr_comis_1,
                                                                        Input table  tt_alter_tit_acr_cheq,
                                                                        Input table  tt_alter_tit_acr_iva,
                                                                        Input table  tt_alter_tit_acr_impto_retid_2,
                                                                        Input table  tt_alter_tit_acr_cobr_espec_2,
                                                                        Input table  tt_alter_tit_acr_rat_desp_rec,
                                                                        output table tt_log_erros_alter_tit_acr,
                                                                        Input v_log_integr_cmg) /*pi_main_code_integr_acr_alter_tit_acr_novo_12*/.
    delete procedure v_hdl_program.

    /*Tratamento de erros*/
    IF CAN-FIND(FIRST tt_log_erros_alter_tit_acr) THEN DO:
        FIND FIRST tt_alter_tit_acr_base_5 NO-LOCK NO-ERROR.
        IF AVAIL tt_alter_tit_acr_base_5 THEN DO:

            FOR EACH tt_log_erros_alter_tit_acr:
            

            END.

        END.

        ASSIGN l-erro = YES.
    END.
    ELSE ASSIGN l-erro = NO.
END PROCEDURE. /* piCriaAlteracaoTaxaCartao */


PROCEDURE pi_retorna_sugestao_referencia:

    /************************ Parameter Definition Begin ************************/

    def Input param p_ind_tip_atualiz
        as character
        format "X(08)"
        no-undo.
    def Input param p_dat_refer
        as date
        format "99/99/9999"
        no-undo.
    def output param p_cod_refer
        as character
        format "x(10)"
        no-undo.
    def Input param p_cod_table
        as character
        format "x(8)"
        no-undo.
    def input param p_estabel
        as character
        format "x(3)"
        no-undo.

    /************************* Parameter Definition End *************************/

    /************************* Variable Definition Begin ************************/

    def var v_des_dat                        as character       no-undo. /*local*/
    def var v_num_aux                        as integer         no-undo. /*local*/
    def var v_num_aux_2                      as integer         no-undo. /*local*/
    def var v_num_cont                       as integer         no-undo. /*local*/


    /************************** Variable Definition End *************************/

    assign v_des_dat   = string(p_dat_refer,"99999999")
           p_cod_refer = substring(p_ind_tip_atualiz,1,2)
                       + substring(v_des_dat,7,2)
                       + substring(v_des_dat,3,2)
/*                        + substring(v_des_dat,1,2) */
                       
           v_num_aux_2 = integer(this-procedure:handle).

    do  v_num_cont = 1 to 4:
        assign v_num_aux   = (random(0,v_num_aux_2) mod 26) + 97
               p_cod_refer = p_cod_refer + CAPS(chr(v_num_aux)).
    end.
    
    run pi_verifica_refer_unica_acr (Input p_estabel,
                                     Input p_cod_refer,
                                     Input p_cod_table,
                                     Input ?,
                                     output v_log_refer_uni) /*pi_verifica_refer_unica_acr*/.

    IF v_log_refer_uni = NO THEN
            run pi_retorna_sugestao_referencia (Input  "BP",
                                                Input  today,
                                                output p_cod_refer,
                                                Input  p_cod_table,
                                                input  p_estabel).
    
    

END PROCEDURE. /* pi_retorna_sugestao_referencia */


PROCEDURE pi_verifica_refer_unica_acr:

    /************************ Parameter Definition Begin ************************/

    def Input param p_cod_estab
        as character
        format "x(3)"
        no-undo.
    def Input param p_cod_refer
        as character
        format "x(10)"
        no-undo.
    def Input param p_cod_table
        as character
        format "x(8)"
        no-undo.
    def Input param p_rec_tabela
        as recid
        format ">>>>>>9"
        no-undo.
    def output param p_log_refer_uni
        as logical
        format "Sim/Nío"
        no-undo.


    /************************* Parameter Definition End *************************/

    /************************** Buffer Definition Begin *************************/

    def buffer b_cobr_especial_acr
        for cobr_especial_acr.
    def buffer b_lote_impl_tit_acr
        for lote_impl_tit_acr.
    def buffer b_lote_liquidac_acr
        for lote_liquidac_acr.
    def buffer b_movto_tit_acr
        for movto_tit_acr.
    def buffer b_renegoc_acr
        for renegoc_acr.


    /*************************** Buffer Definition End **************************/

    /************************* Variable Definition Begin ************************/

    def var v_cod_return
        as character
        format "x(40)"
        no-undo.


    /************************** Variable Definition End *************************/

    assign p_log_refer_uni = yes.

    if  p_cod_table <> "lote_impl_tit_acr" /*l_lote_impl_tit_acr*/  then do:
        find first b_lote_impl_tit_acr no-lock
             where b_lote_impl_tit_acr.cod_estab = p_cod_estab
               and b_lote_impl_tit_acr.cod_refer = p_cod_refer
               and recid( b_lote_impl_tit_acr ) <> p_rec_tabela
             use-index ltmplttc_id no-error.
        if  avail b_lote_impl_tit_acr then
            assign p_log_refer_uni = no.
    end.

    if  p_cod_table <> "lote_liquidac_acr" /*l_lote_liquidac_acr*/  then do:
        find first b_lote_liquidac_acr no-lock
             where b_lote_liquidac_acr.cod_estab_refer = p_cod_estab
               and b_lote_liquidac_acr.cod_refer       = p_cod_refer
               and recid( b_lote_liquidac_acr )       <> p_rec_tabela
             use-index ltlqdccr_id no-error.
        if  avail b_lote_liquidac_acr then
            assign p_log_refer_uni = no.
    end.

    if  p_cod_table = 'cobr_especial_acr' then do:
        find first b_cobr_especial_acr no-lock
             where b_cobr_especial_acr.cod_estab = p_cod_estab
               and b_cobr_especial_acr.cod_refer = p_cod_refer
               and recid( b_cobr_especial_acr ) <> p_rec_tabela
             use-index cbrspclc_id no-error.
        if  avail b_cobr_especial_acr then
            assign p_log_refer_uni = no.
    end.

    if  p_log_refer_uni = yes then do:
        find first b_renegoc_acr no-lock
            where b_renegoc_acr.cod_estab = p_cod_estab
            and   b_renegoc_acr.cod_refer = p_cod_refer
            and   recid(b_renegoc_acr)   <> p_rec_tabela
            no-error.
        if  avail b_renegoc_acr then
            assign p_log_refer_uni = no.
        else do:
            find first b_movto_tit_acr no-lock
                 where b_movto_tit_acr.cod_estab = p_cod_estab
                   and b_movto_tit_acr.cod_refer = p_cod_refer
                   and recid(b_movto_tit_acr)   <> p_rec_tabela
                 use-index mvtttcr_refer
                 no-error.
            if  avail b_movto_tit_acr then
                assign p_log_refer_uni = no.
        end.
    end.

END PROCEDURE. /* pi_verifica_refer_unica_acr */




