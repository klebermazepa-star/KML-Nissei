/********************************************************************************
** Copyright DATASUL S.A. (1997)
** Todos os Direitos Reservados.
**
** Este fonte e de propriedade exclusiva da DATASUL, sua reproducao
** parcial ou total por qualquer meio, so podera ser feita mediante
** autorizacao expressa.
*******************************************************************************/
{include/i-prgvrs.i int036RP 2.12.00.001 } /* */

&IF "{&EMSFND_VERSION}" >= "1.00" &THEN
    {include/i-license-manager.i int036RP MOF}
&ENDIF
 
{include/i_fnctrad.i}
{utp/ut-glob.i}
/********************************************************************************
** Copyright DATASUL S.A. (2004)
** Todos os Direitos Reservados.
**
** Este fonte e de propriedade exclusiva da DATASUL, sua reproducao
** parcial ou total por qualquer meio, so podera ser feita mediante
** autorizacao expressa.
*******************************************************************************/

/****************************************************************************
**
**  Programa: int036RP.P
**
**  Data....: Julho de 2016
**
**  Autor...: ResultPro 
**
**  Objetivo: Lista Notas Int002
**
******************************************************************************/

/*** defini‡Æo de pre-processador ***/
{cdp/cdcfgdis.i} 

DEF TEMP-TABLE tt-nfe    LIKE int-ds-docto-xml
FIELD id-ndd     AS CHAR
FIELD desc-docto AS CHAR
FIELD sit-nfe    AS CHAR
INDEX idx_chave cod-estab nnf serie cod-emitente.
                 
DEFINE TEMP-TABLE tt-docto-xml LIKE int-ds-docto-xml
FIELD id-ndd AS CHAR.

DEFINE TEMP-TABLE tt-it-docto-xml LIKE int-ds-it-docto-xml.

define temp-table tt-param no-undo
    field destino          as integer
    field arquivo          as char format "x(35)":U
    field usuario          as char format "x(12)":U
    field data-exec        as date
    field hora-exec        as integer
    FIELD dt-periodo-ini   AS DATE FORMAT "99/99/9999"
    FIELD dt-periodo-fim   AS DATE FORMAT "99/99/9999"
    FIELD cod-estabel-ini  AS CHAR format "x(05)"
    FIELD cod-estabel-fim  AS CHAR FORMAT "x(03)"
    FIELD rs-tipo          AS INTEGER.

DEFINE TEMP-TABLE tt-digita
    FIELD arquivo AS CHAR
    FIELD raiz    AS CHAR 
    FIELD node    AS CHAR
    FIELD campo   AS CHAR FORMAT "X(100)"
    FIELD valor   AS CHAR FORMAT "X(100)"
    FIELD linha   AS INTEGER.

DEFINE TEMP-TABLE tt-estab
FIELD cod-estabel LIKE estabelec.cod-estabel
FIELD cgc         LIKE estabelec.cgc. 

DEF BUFFER b-tt-digita             FOR tt-digita.
DEF BUFFER b-int-ds-docto-xml      FOR int-ds-docto-xml.

/*** defini‡Æo de vari veis locais ***/
DEF VAR h-acomp    AS HANDLE  NO-UNDO.
DEF VAR i-linha    AS INTEGER NO-UNDO.
DEF VAR l-transf   AS LOGICAL NO-UNDO.
DEF VAR l-prod     AS LOGICAL NO-UNDO.
DEF VAR i-seq-item AS INTEGER NO-UNDO.
DEF VAR c-lista    AS CHAR INITIAL "1,2,3,4,5,6,7,8,9,10".
DEF VAR c-data     AS CHAR    NO-UNDO.
DEF VAR i-cont     AS INTEGER.
DEF VAR i-situacao AS INTEGER NO-UNDO.
DEF VAR i-pos      AS INTEGER.
DEF VAR h-niveis   AS HANDLE  NO-UNDO.
DEF VAR c-id-ndd   AS CHAR.
DEF VAR c-nome-emit AS CHAR NO-UNDO.
def var c-saida     as char format "x(40)" no-undo.
def var c-estabel   like estabelec.nome    no-undo.
DEF VAR c-desc-docto AS CHAR NO-UNDO.

def temp-table tt-raw-digita NO-UNDO
    field raw-digita as raw.

def input param raw-param as raw no-undo.
def input param table for tt-raw-digita.

create tt-param.
raw-transfer raw-param to tt-param.

{include/i-rpvar.i}

def var c-sistema-origem   as char no-undo.
def var c-sistema-destino  as char no-undo.
FUNCTION fnSistema RETURNS CHARACTER
  ( p-cnpj as char,
    p-dt-referencia as date ) :

    if can-find(first estabelec no-lock where estabelec.cgc = p-cnpj) then do:
        for each estabelec no-lock where estabelec.cgc = p-cnpj,
            first cst-estabelec no-lock of estabelec where
            cst-estabelec.dt-fim-operacao >= p-dt-referencia:
            if cst-estabelec.dt-inicio-oper <= p-dt-referencia 
            then 
                return "PROCFIT".
            else 
                return "OBLAK".
        end.
        RETURN "OBLAK".
    end.
    else RETURN "FORNECEDOR".

END FUNCTION.

form   
    skip (04)
    "SELE€ÇO"  at 10  skip(01)
    tt-param.dt-periodo-ini    label "Per¡odo."         at 30 "|<    >|" at 50
    tt-param.dt-periodo-fim    no-label                 at 63 skip(1)
    "PAR¶METROS" at 10 skip(1)
    tt-param.cod-estabel-ini label "Estabelecimento"  colon 34 "|<    >|" AT 50
    tt-param.cod-estabel-fim NO-LABEL                          SKIP
    tt-param.rs-tipo        label "Modo Execu‡Æo"     colon 34 skip
    skip(1)
    "IMPRESSÇO" at 10  skip(1)
    c-saida label "Destino"                        colon 34  
    tt-param.usuario  label "Usu rio"              colon 34 
    with side-labels stream-io frame f-resumo.


run utp/ut-acomp.p persistent set h-acomp.

run pi-inicializar in h-acomp (input "Int036 - Lista notas").

FIND FIRST param-global NO-ERROR.

FIND FIRST mgadm.empresa NO-LOCK WHERE
           empresa.ep-codigo = param-global.empresa-prin NO-ERROR.

if avail empresa then 
   assign c-empresa   = string(empresa.ep-codigo) 
          c-estabel   = empresa.razao-social.

{utp/ut-liter.i INTEGRA€ÇO NDD  * r }
assign c-sistema  = return-value.

/* {include/i-rpout.i &page-size = 0} */

output to value(tt-param.arquivo) page-size 0 convert target "iso8859-1".

 /* {include/i-rpcab.i}

view frame f-cab.
view frame f-rodape.
 */

EMPTY TEMP-TABLE tt-estab.
EMPTY TEMP-TABLE tt-nfe.             

RUN pi-leitura-notas.   /* Leitura das notas */      

/** Impressao das notas */

FOR EACH tt-nfe WHERE
         tt-nfe.cod-estab >= tt-param.cod-estabel-ini  AND
         tt-nfe.cod-estab <= tt-param.cod-estabel-fim  AND 
         tt-nfe.demi      >= tt-param.dt-periodo-ini   AND
         tt-nfe.demi      <= tt-param.dt-periodo-fim 
    BY tt-nfe.desc-docto
    BY tt-nfe.cod-estab
    BY tt-nfe.demi :

   FIND FIRST emitente NO-LOCK WHERE
              emitente.cod-emitente = tt-nfe.cod-emitente NO-ERROR.
   IF AVAIL emitente THEN
      ASSIGN c-nome-emit = emitente.nome-emit.
                   
   DISP  tt-nfe.desc-docto FORMAT "x(12)" COLUMN-LABEL "Tipo"
         fnSistema(tt-nfe.cnpj,tt-nfe.dEmi) @ c-sistema-origem column-label "Origem"
         fnSistema(tt-nfe.cnpj-dest,tt-nfe.dEmi) @ c-sistema-destino column-label "Destino"
         tt-nfe.cod-estab   COLUMN-LABEL "Estab"
         tt-nfe.nnf
         tt-nfe.serie
         tt-nfe.cod-emitente COLUMN-LABEL "Fornecedor"
         c-nome-emit         COLUMN-LABEL  "Nome" FORMAT "X(30)"
         tt-nfe.demi 
         tt-nfe.cnpj-dest    COLUMN-LABEL "CNPJ Destino"
         tt-nfe.id-ndd       COLUMN-LABEL "ID NDD"
         tt-nfe.sit-nfe      COLUMN-LABEL "Situa‡Æo" FORMAT "x(12)"
         WITH DOWN STREAM-IO WIDTH 550 FRAME f-nfe.
   DOWN WITH FRAME tt-nfe.
       
END.


{include/i-rpclo.i}
RUN pi-finalizar IN h-acomp.
RETURN "OK":U.
               

PROCEDURE pi-leitura-notas:

    FOR EACH estabelec NO-LOCK WHERE
             estabelec.cod-estabel >= tt-param.cod-estabel-ini AND 
             estabelec.cod-estabel <= tt-param.cod-estabel-fim :

        CREATE tt-estab.
        ASSIGN tt-estab.cod-estabel = estabelec.cod-estabel
               tt-estab.cgc         = estabelec.cgc. 

    END.

    IF tt-param.rs-tipo = 1 OR   /* Notas Integradas Loja */
       tt-param.rs-tipo = 4   
    THEN DO: 
        FOR EACH int-ds-nota-entrada NO-LOCK WHERE
                 int-ds-nota-entrada.nen-dataemissao-d >= tt-param.dt-periodo-ini AND                
                 int-ds-nota-entrada.nen-dataemissao-d <= tt-param.dt-periodo-fim ,
            FIRST tt-estab WHERE
                  tt-estab.cgc = int-ds-nota-entrada.nen-cnpj-destino-s :
           
           CREATE tt-nfe.
           ASSIGN tt-nfe.desc-docto  = "Loja"
                  tt-nfe.CNPJ        = int-ds-nota-entrada.nen-cnpj-origem-s         /* CNPJ fornecedor/estabelecimento origem */
                  tt-nfe.serie       = int-ds-nota-entrada.nen-serie-s               /*  Serie da nota fiscal */    
                  tt-nfe.nnf         = string(int-ds-nota-entrada.nen-notafiscal-n)  /*  Numero da nota fiscal  */
                  tt-nfe.cnpj-dest   = int-ds-nota-entrada.nen-cnpj-destino-s        /* CNPJ estabelecimento de destino */
                  tt-nfe.cod-estab   = tt-estab.cod-estabel
                  tt-nfe.demi        = int-ds-nota-entrada.nen-dataemissao-d         /*  Data emissao da nota fiscal */  
                  tt-nfe.VNF         = int-ds-nota-entrada.nen-valortotalprodutos-n  /*  Valor total da nota fiscal */
                  tt-nfe.sit-nfe     = "Atualizada"
                  tt-nfe.num-pedido  = int-ds-nota-entrada.ped-codigo-n.

           RUN pi-acompanhar IN h-acomp(INPUT "Nota :" + STRING(tt-nfe.NNF)).

           FIND FIRST emitente NO-LOCK WHERE
                      emitente.cgc = int-ds-nota-entrada.nen-cnpj-origem-s NO-ERROR.
           IF AVAIL emitente THEN
              ASSIGN tt-nfe.cod-emitente = emitente.cod-emitente. 

           IF R-INDEX(int-ds-nota-entrada.nen-observacao-s,"NDDID:") > 0 
           THEN DO:
              ASSIGN i-pos    = R-INDEX(int-ds-nota-entrada.nen-observacao-s,"NDDID:") + 6
                     c-id-ndd = SUBSTRING(int-ds-nota-entrada.nen-observacao-s,i-pos,12).

              ASSIGN tt-nfe.id-ndd = c-id-ndd.

           END.

        END.

    END.

    IF tt-param.rs-tipo = 2 OR   /* Notas Integradas CD */
       tt-param.rs-tipo = 3 OR   /* Notas Pepsico */
       tt-param.rs-tipo = 4   
    THEN DO:

       FOR EACH int-ds-docto-xml NO-LOCK WHERE
                int-ds-docto-xml.cod-estab >= tt-param.cod-estabel-ini AND  
                int-ds-docto-xml.cod-estab <= tt-param.cod-estabel-fim AND 
                int-ds-docto-xml.demi      >= tt-param.dt-periodo-ini  AND    
                int-ds-docto-xml.demi      <= tt-param.dt-periodo-fim: 

           IF int-ds-docto-xml.tipo-docto = 5 THEN NEXT. /* Desconsidera Balan‡o */ 
           IF int-ds-docto-xml.situacao = 9 THEN NEXT. /* Desconsidera Recusadas */ 
                
           ASSIGN c-desc-docto = ""
                  i-situacao   = int-ds-docto-xml.situacao.
                                   
           IF tt-param.rs-tipo = 4 
           THEN DO:   
               FIND FIRST int-ds-ext-emitente NO-LOCK WHERE
                          int-ds-ext-emitente.cod-emitente = int-ds-docto-xml.cod-emitente NO-ERROR.
               IF (AVAIL int-ds-ext-emitente AND  
                         int-ds-ext-emitente.gera-nota) THEN DO:
                   /* Notas PEPSICO eletronicas que entram em int-ds-nota-entrada */
                   FIND int-ds-nota-entrada NO-LOCK WHERE
                       int-ds-nota-entrada.nen-serie = int-ds-docto-xml.serie AND
                       int-ds-nota-entrada.nen-notafiscal-n = int64(int-ds-docto-xml.nNF) AND
                       int-ds-nota-entrada.nen-cnpj-origem-s = int-ds-docto-xml.cnpj NO-ERROR.
                   IF AVAIL int-ds-nota-entrada THEN DO:
                       IF int-ds-docto-xml.situacao <> 9 AND 
                          int-ds-docto-xml.situacao <> 3 THEN DO:
                           FOR FIRST b-int-ds-docto-xml WHERE 
                               b-int-ds-docto-xml.serie = int-ds-docto-xml.serie AND
                               b-int-ds-docto-xml.nNF = int-ds-docto-xml.nNF AND
                               b-int-ds-docto-xml.cnpj = int-ds-docto-xml.cnpj:
                               ASSIGN b-int-ds-docto-xml.situacao = 9.
                           END.
                       END.
                       IF int-ds-docto-xml.situacao <> 3 THEN NEXT.
                   END.
                   ASSIGN c-desc-docto = "Pepsico".
               END.
               ELSE
                   ASSIGN c-desc-docto = "CD". 
                    
           END.
                                             
           IF tt-param.rs-tipo = 2 
           THEN DO:   
               FIND FIRST int-ds-ext-emitente NO-LOCK WHERE
                          int-ds-ext-emitente.cod-emitente = int-ds-docto-xml.cod-emitente NO-ERROR.
               IF (AVAIL int-ds-ext-emitente AND  
                         int-ds-ext-emitente.gera-nota) THEN NEXT. 

               ASSIGN c-desc-docto = "CD". 
                    
           END.

           IF tt-param.rs-tipo = 3 /* Pepsico */
           THEN DO:   
               FIND FIRST int-ds-ext-emitente NO-LOCK WHERE
                          int-ds-ext-emitente.cod-emitente = int-ds-docto-xml.cod-emitente NO-ERROR.

               IF AVAIL int-ds-ext-emitente THEN DO:  

                   IF int-ds-ext-emitente.gera-nota = NO THEN NEXT. 

               END.
               ELSE 
                   NEXT.
               /* Notas PEPSICO eletronicas que entram em int-ds-nota-entrada */
               FIND int-ds-nota-entrada NO-LOCK WHERE
                   int-ds-nota-entrada.nen-serie = int-ds-docto-xml.serie AND
                   int-ds-nota-entrada.nen-notafiscal-n = int64(int-ds-docto-xml.nNF) AND
                   int-ds-nota-entrada.nen-cnpj-origem-s = int-ds-docto-xml.cnpj NO-ERROR.
               IF AVAIL int-ds-nota-entrada THEN DO:
                   IF int-ds-docto-xml.situacao <> 9 AND 
                      int-ds-docto-xml.situacao <> 3 THEN DO:
                       FOR FIRST b-int-ds-docto-xml WHERE 
                           b-int-ds-docto-xml.serie = int-ds-docto-xml.serie AND
                           b-int-ds-docto-xml.nNF = int-ds-docto-xml.nNF AND
                           b-int-ds-docto-xml.cnpj = int-ds-docto-xml.cnpj:
                           ASSIGN b-int-ds-docto-xml.situacao = 9.
                       END.
                   END.
                   IF int-ds-docto-xml.situacao <> 3 THEN NEXT.
               END.

               ASSIGN c-desc-docto = "Pepsico". 

               /* 
               FOR FIRST int-ds-it-docto-xml NO-LOCK WHERE
                         int-ds-it-docto-xml.serie        = int-ds-docto-xml.serie AND
                         int-ds-it-docto-xml.nNF          = int-ds-docto-xml.nNF   AND
                         int-ds-it-docto-xml.cod-emitente = int-ds-docto-xml.cod-emitente
                   BY  int-ds-it-docto-xml.situacao:

                    ASSIGN i-situacao =  int-ds-it-docto-xml.situacao.

               END.                      
               */
               IF i-situacao <> 3 THEN ASSIGN i-situacao = 1.  /* Elaine pediu para retirar as notas liberadas e passar para pendentes */

           END.

           CREATE tt-nfe.
           BUFFER-COPY int-ds-docto-xml TO tt-nfe.
           ASSIGN tt-nfe.desc-docto  =  c-desc-docto.

           CASE i-situacao:
               WHEN 1 THEN ASSIGN tt-nfe.sit-nfe = "Pendente".
               WHEN 2 THEN ASSIGN tt-nfe.sit-nfe = "Liberada".
               WHEN 3 THEN ASSIGN tt-nfe.sit-nfe = "Atualizada".
           END.
                  
           RUN pi-acompanhar IN h-acomp(INPUT "Nota :" + STRING(tt-nfe.NNF)).
        
           IF int-ds-docto-xml.tipo-docto <> 4  /* Pepsico */
           THEN DO:
              IF int-ds-docto-xml.arquivo <> ? THEN
                 ASSIGN tt-nfe.id-ndd = TRIM(STRING(int-ds-docto-xml.arquivo)).
              ELSE 
                ASSIGN tt-nfe.id-ndd = "".
           END.
           ELSE
             ASSIGN tt-nfe.id-ndd = "".
            
       END. 

    END.

    /*
        IF tt-param.rs-tipo = 4 /* OR   
           tt-param.rs-tipo = 5 */  
        THEN DO:
    
            RUN pi-IntegracaoNDD.
    
        END.
    */

END PROCEDURE.
