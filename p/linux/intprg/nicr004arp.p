/********************************************************************************
*******************************************************************************/
{include/i-prgvrs.i NICR004ARP 2.06.00.001}  
{include/i_fnctrad.i}
/******************************************************************************
**
**       PROGRAMA: NICR004ARP
**
**       DATA....: 01/2016
**
**       OBJETIVO: Importa‡Æo das Liquida‡äes de Cheque e Dinheiro atrav‚s do
                   arquivo enviado pela empresa de transportes de valores.
**
**       VERSAO..: 2.06.001
** 
******************************************************************************/
define buffer portador for ems5.portador.

{include/i-rpvar.i}
{include/i-rpcab.i}

/* {utp/ut-glob.i} */ 
def new Global shared var c-seg-usuario        as char format "x(12)" no-undo.

{method/dbotterr.i} 
/*{cdp/cd0666.i}       Definicao da temp-table de erros */

define temp-table tt-param no-undo
    field destino          as integer
    field arquivo          as char format "x(35)"
    field usuario          as char format "x(12)"
    field data-exec        as date
    field hora-exec        as integer
    field classifica       as integer
    field desc-classifica  as char format "x(40)"
    field modelo-rtf       as char format "x(35)"
    field l-habilitaRtf    as LOG
    field c-portador-di    LIKE portador.cod_portador
    field c-portador-ch    LIKE portador.cod_portador
    FIELD c-carteira-di    LIKE cart_bcia.cod_cart_bcia
    FIELD c-carteira-ch    LIKE cart_bcia.cod_cart_bcia
    FIELD c-arquivo        AS CHAR FORMAT "x(500)"
    FIELD tipo             AS INT FORMAT "9".

def temp-table tt-raw-digita
    field raw-digita as raw.

DEF TEMP-TABLE tt-raw-param 
 FIELD raw-param  AS RAW.

define temp-table tt-movto-din-tic no-undo
   field cod-estab as char format "x(03)"
   field tipo      as char format "x(03)"
   field vl-movto  like tit_acr.val_sdo_tit_acr
   field dt-movto  as date format "99/99/99"
   FIELD dt-liquid as date format "99/99/99"
   FIELD linha     AS INTEGER 
   FIELD arquivo   AS CHARACTER FORMAT "X(200)" .

define temp-table tt-movto-cheque no-undo
   field cod-estab     as char format "x(03)"
   field tipo          as char format "x(03)"
   field vl-movto      like tit_acr.val_sdo_tit_acr
   field dt-movto      as date format "99/99/99"
   FIELD cod-banco     as character format "x(8)" label "Banco" column-label "Banco"
   FIELD cod-agencia   as character format "x(10)" label "Agˆncia Banc ria" column-label "Agˆncia Banc ria"
   FIELD dig-agencia   as character format "x(10)" label "Digito Agˆncia Banc ria" column-label "Digito Agˆncia Banc ria" 
   FIELD cod-conta     as character format "x(10)" label "Agˆncia Banc ria" column-label "Agˆncia Banc ria"
   FIELD dig-conta     as character format "x(10)" label "Digito Agˆncia Banc ria" column-label "Digito Agˆncia Banc ria" 
   FIELD cod-comp      AS INTEGER FORMAT "999" LABEL "C¢digo Cƒmara Compensa‡Æo"
   FIELD num-cheq      as integer format ">>>>,>>>,>>9" initial ? label "Num Cheque" column-label "Num Cheque"
   FIELD cod-feder     as character format "x(20)" initial ? label "ID Federal" column-label "ID Federal"
   FIELD cod-tit-acr   LIKE tit_acr.cod_tit_acr
   FIELD dt-credito    as date format "99/99/9999"
   FIELD linha         AS CHAR

    .
DEFINE TEMP-TABLE tt-tit-criados 
    FIELD cod_estab           LIKE tit_acr.cod_estab         
    FIELD cod_espec_docto     LIKE tit_acr.cod_espec_docto   
    FIELD cod_ser_docto       LIKE tit_acr.cod_ser_docto     
    FIELD cod_tit_acr         LIKE tit_acr.cod_tit_acr     
    FIELD cod_parcela         LIKE tit_acr.cod_parcela       
    FIELD cdn_cliente         LIKE tit_acr.cdn_cliente       
    FIELD cod_portador        LIKE tit_acr.cod_portador      
    FIELD dat_transacao       LIKE tit_acr.dat_transacao     
    FIELD dat_emis_docto      LIKE tit_acr.dat_emis_docto    
    FIELD dat_vencto_tit_acr  LIKE tit_acr.dat_vencto_tit_acr
    FIELD val_origin_tit_acr  LIKE tit_acr.val_origin_tit_acr
    FIELD situacao            AS CHAR FORMAT "x(20)".
   
define temp-table tt-titulo no-undo
   field cod-estab as char format "x(03)"
   field vl-movto  like tit_acr.val_sdo_tit_acr
   field dt-movto  as date format "99/99/99"
   field dt-liquid as date format "99/99/99"
   field cd-tit    like tit_acr.cod_tit_acr
   FIELD linha     AS INTEGER
   FIELD arquivo   AS CHARACTER FORMAT "X(200)".  

define temp-table tt-titulo-cheque no-undo
    FIELD cod_estab           LIKE tit_acr.cod_estab 
    FIELD num_id_tit_acr      LIKE tit_acr.num_id_tit_acr 
    FIELD val_movto           LIKE tit_acr.val_origin_tit_acr
    FIELD dat_movto           LIKE tit_acr.dat_vencto_tit_acr .

DEFINE TEMP-TABLE tt-erro NO-UNDO
    FIELD i-sequen    AS INTEGER
    FIELD cd-erro     AS INTEGER
    FIELD mensagem    AS CHAR
    FIELD ajuda       AS CHAR.             

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

DEF VAR d-dt-movto-aux as char no-undo.
DEF VAR d-dt-movto     as date format "99/99/9999" no-undo.

def var c_cod_table               as character         format "x(8)"                no-undo.
def var w_estabel                 as character         format "x(3)"                no-undo.
def var c-cod-refer               as character         format "x(10)"               no-undo.
def var v_log_refer_uni           as log                                            no-undo.

DEF VAR v_hdl_program     AS HANDLE  FORMAT ">>>>>>9":U NO-UNDO.
DEF var v_log_integr_cmg  AS LOGICAL FORMAT "Sim/NÆo":U INITIAL NO LABEL "CMG" COLUMN-LABEL "CMG" NO-UNDO.

DEF VAR h-boin157q01   AS HANDLE                           NO-UNDO.
DEF VAR l-habilita     AS LOGICAL                          NO-UNDO.
DEF VAR d-return       AS DATE FORMAT "99/99/9999"         NO-UNDO.
def var ix             as integer                          no-undo.

find first param-estoq  no-lock no-error.
find first param-global no-lock no-error.
find first ems2log.empresa where 
           empresa.ep-codigo = param-global.empresa-prin no-lock no-error.

assign c-programa = "NICR004"
       c-versao   = "2.06"
       c-revisao  = "001"
       c-empresa  = empresa.razao-social.

find first tt-param no-lock no-error.
{include/i-rpout.i}
{utp/ut-liter.i Importa‡Æo_Coleta_Lojas * L}
assign c-titulo-relat = trim(return-value).
{utp/ut-liter.i Importa‡Æo * L}
assign c-sistema = trim(return-value).

VIEW frame f-cabec.
view frame f-rodape.

{intprg/nicr004arp.i}
                    
/* log-manager:logfile-name= "\\192.168.200.52\datasul\_custom_teste\Prog_QG\Liquidacao.txt". */
/* log-manager:log-entry-types= "4gltrace".                                                   */
     
RUN utp/ut-acomp.p PERSISTENT SET h-acomp.
RUN pi-inicializar IN h-acomp (INPUT "Importa‡Æo Arquivos").

IF tt-param.tipo = 1 THEN DO:
    RUN pi-seta-titulo IN h-acomp (INPUT "Importa‡Æo - Coleta":U).
    RUN pi-importa-arquivo-coleta.
    RUN pi-seta-titulo IN h-acomp (INPUT "Proces..Coleta - Dinheiro":U).
    RUN pi-processa-dinheiro-coleta.
    RUN pi-seta-titulo IN h-acomp (INPUT "Proces..Coleta - Cheque":U).
    RUN pi-processa-cheque-coleta.
END.
ELSE IF tt-param.tipo = 2 THEN DO:
    RUN pi-seta-titulo IN h-acomp (INPUT "Importa‡Æo - Dep¢sito":U).
    RUN pi-importa-arquivo-deposito.
    RUN pi-seta-titulo IN h-acomp (INPUT "Proces..Coleta - Cheque":U).
    RUN pi-processa-cheque-deposito.
END.

RUN pi-seta-titulo IN h-acomp (INPUT "Imprimindo Erros":U).
RUN pi-mostra-titulos-criados.
RUN pi-mostra-erros.

RUN pi-finalizar IN h-acomp.                       


/* log-manager:close-log(). */

{include/i-rpclo.i}   

return "OK":U.

PROCEDURE pi-importa-arquivo-coleta.
    DEFINE VARIABLE c-reg    AS CHARACTER         NO-UNDO.
    DEFINE VARIABLE i-linha  AS INTEGER INITIAL 1 NO-UNDO.

    EMPTY TEMP-TABLE tt-movto-cheque.
    EMPTY TEMP-TABLE tt-movto-din-tic.

    INPUT FROM VALUE(tt-param.c-arquivo) NO-ECHO.               
    
    REPEAT ON ERROR UNDO, LEAVE
           ON STOP  UNDO,LEAVE TRANSACTION:   

      RUN pi-acompanhar IN h-acomp (INPUT "Linha: ":U + STRING(i-linha)).
      
        
      IMPORT UNFORMATTED c-reg.
      
      IF substring(TRIM(c-reg),1,1) = "0" THEN DO:
        assign d-dt-movto-aux = substring(c-reg,2,8).
        assign d-dt-movto     = DATE(substring(d-dt-movto-aux,1,2) + "/" +
                                     substring(d-dt-movto-aux,3,2) + "/" +
                                     substring(d-dt-movto-aux,5,4)) .        
                
      END.
      ELSE IF substring(c-reg,1,1) = "1" THEN DO:
        IF substring(TRIM(c-reg),5,3) = "DIN" OR     
           substring(TRIM(c-reg),5,3) = "TIC" THEN DO:
           
           assign d-dt-movto-aux = substring(trim(c-reg),19,8).      
           
           create tt-movto-din-tic.
           assign tt-movto-din-tic.cod-estab = substring(trim(c-reg),2,3)       
                  tt-movto-din-tic.tipo      = substring(trim(c-reg),5,3)
                  tt-movto-din-tic.vl-movto  = DEC(int(substring(trim(c-reg),8,11)) / 100)
                  tt-movto-din-tic.dt-movto  = DATE(substring(d-dt-movto-aux,7,2) + "/" +
                                                    substring(d-dt-movto-aux,5,2) + "/" +
                                                    substring(d-dt-movto-aux,1,4)) 
                  tt-movto-din-tic.dt-liquid = d-dt-movto
                  tt-movto-din-tic.linha     = i-linha
                  tt-movto-din-tic.arquivo   = tt-param.c-arquivo.
           
        END.
        ELSE IF substring(TRIM(c-reg),5,3) = "CHQ" THEN DO:


            

            FIND FIRST tt-movto-cheque NO-LOCK
                 WHERE tt-movto-cheque.linha = c-reg NO-ERROR.
            IF NOT AVAIL tt-movto-cheque THEN DO:
                CREATE tt-movto-cheque.
                ASSIGN tt-movto-cheque.linha         = c-reg
                       tt-movto-cheque.cod-estab     = substring(trim(c-reg),2,3)        
                       tt-movto-cheque.tipo          = substring(trim(c-reg),5,3)
                       tt-movto-cheque.vl-movto      = DEC(int(substring(trim(c-reg),53,11)) / 100)
                       tt-movto-cheque.cod-banco     = substring(trim(c-reg),8,3)
                       tt-movto-cheque.cod-agencia   = substring(trim(c-reg),11,4)
                       tt-movto-cheque.dig-agencia   = substring(trim(c-reg),15,1)
                       tt-movto-cheque.cod-conta     = substring(trim(c-reg),16,10)
                       tt-movto-cheque.dig-conta     = substring(trim(c-reg),26,2)
                       tt-movto-cheque.num-cheq      = INT(substring(trim(c-reg),28,6))
                       tt-movto-cheque.cod-feder     = substring(trim(c-reg),34,11).
    
    
                assign d-dt-movto-aux                = substring(trim(c-reg),45,8). 
                       tt-movto-cheque.dt-credito    = DATE(substring(d-dt-movto-aux,7,2) + "/" +
                                                            substring(d-dt-movto-aux,5,2) + "/" +
                                                            substring(d-dt-movto-aux,1,4)).
    
                assign d-dt-movto-aux                = substring(trim(c-reg),64,8). 
                       tt-movto-cheque.dt-movto      = DATE(substring(d-dt-movto-aux,7,2) + "/" +
                                                            substring(d-dt-movto-aux,5,2) + "/" +
                                                            substring(d-dt-movto-aux,1,4)).
            END.



        END.      
      END.
      ELSE IF substring(c-reg,1,1) = "9" THEN DO:
      
      END.

      ASSIGN i-linha = i-linha + 1.  
    
    END.
END PROCEDURE.


PROCEDURE pi-importa-arquivo-deposito.
    DEFINE VARIABLE c-reg    AS CHARACTER         NO-UNDO.
    DEFINE VARIABLE i-linha  AS INTEGER INITIAL 1 NO-UNDO.

    EMPTY TEMP-TABLE tt-movto-cheque.
    
    INPUT FROM VALUE(tt-param.c-arquivo) NO-ECHO.               
    
    REPEAT ON ERROR UNDO, LEAVE
           ON STOP  UNDO,LEAVE TRANSACTION:   

      RUN pi-acompanhar IN h-acomp (INPUT "Linha: ":U + STRING(i-linha)).
      
        
      IMPORT UNFORMATTED c-reg.
      
      IF substring(TRIM(c-reg),1,1) = "0" THEN DO:
        assign d-dt-movto-aux = substring(c-reg,2,8).
        assign d-dt-movto     = DATE(substring(d-dt-movto-aux,1,2) + "/" +
                                     substring(d-dt-movto-aux,3,2) + "/" +
                                     substring(d-dt-movto-aux,5,4)) .        
                
      END.
      ELSE IF SUBSTRING(c-reg,1,1) = "1" THEN DO:
        IF SUBSTRING(TRIM(c-reg),5,3) = "CHQ" THEN DO:

            FIND FIRST tt-movto-cheque NO-LOCK
                 WHERE tt-movto-cheque.linha = c-reg NO-ERROR.
            IF NOT AVAIL tt-movto-cheque THEN DO:
                CREATE tt-movto-cheque.
                ASSIGN tt-movto-cheque.linha         = c-reg
                       tt-movto-cheque.cod-estab     = SUBSTRING(TRIM(c-reg),2,3)        
                       tt-movto-cheque.tipo          = SUBSTRING(TRIM(c-reg),5,3)
                       tt-movto-cheque.vl-movto      = DEC(int(SUBSTRING(TRIM(c-reg),53,11)) / 100)
                       tt-movto-cheque.cod-banco     = SUBSTRING(TRIM(c-reg),8,3)
                       tt-movto-cheque.cod-agencia   = SUBSTRING(TRIM(c-reg),11,4)
                       tt-movto-cheque.dig-agencia   = SUBSTRING(TRIM(c-reg),15,1)
                       tt-movto-cheque.cod-conta     = SUBSTRING(TRIM(c-reg),16,10)
                       tt-movto-cheque.dig-conta     = SUBSTRING(TRIM(c-reg),26,2)
                       tt-movto-cheque.num-cheq      = INT(SUBSTRING(TRIM(c-reg),28,6))
                       tt-movto-cheque.cod-feder     = SUBSTRING(TRIM(c-reg),34,11).
    
                ASSIGN d-dt-movto-aux                = SUBSTRING(TRIM(c-reg),45,8).
                ASSIGN tt-movto-cheque.dt-credito    = DATE(SUBSTRING(d-dt-movto-aux,7,2) + "/" +
                                                            SUBSTRING(d-dt-movto-aux,5,2) + "/" +
                                                            SUBSTRING(d-dt-movto-aux,1,4))      .
    
                ASSIGN d-dt-movto-aux                = SUBSTRING(TRIM(c-reg),64,8).
                       tt-movto-cheque.dt-movto      = DATE(SUBSTRING(d-dt-movto-aux,7,2) + "/" +  
                                                            SUBSTRING(d-dt-movto-aux,5,2) + "/" +  
                                                            SUBSTRING(d-dt-movto-aux,1,4))      .  
            END.

        END.      
      END.

      ASSIGN i-linha = i-linha + 1.  
    
    END.
END PROCEDURE.

PROCEDURE pi-processa-dinheiro-coleta:

    EMPTY TEMP-TABLE tt-titulo.

    FOR EACH tt-movto-din-tic
       WHERE tt-movto-din-tic.tipo = "DIN":
              
/*         FIND FIRST tt-titulo EXCLUSIVE-LOCK                                  */
/*              WHERE tt-titulo.cod-estab = tt-movto-din-tic.cod-estab          */
/*                and tt-titulo.dt-movto  = tt-movto-din-tic.dt-movto NO-ERROR. */
/*         IF NOT AVAIL tt-titulo THEN DO:                                      */
        
            CREATE tt-titulo.
            ASSIGN tt-titulo.cod-estab = tt-movto-din-tic.cod-estab
                   tt-titulo.dt-movto  = tt-movto-din-tic.dt-movto
                   tt-titulo.vl-movto  = tt-movto-din-tic.vl-movto
                   tt-titulo.cd-tit    = "DINH" + string(REPLACE(STRING(tt-movto-din-tic.dt-movto,"99/99/99"),"/",""))
                   tt-titulo.dt-liquid = tt-movto-din-tic.dt-liquid
                   tt-titulo.linha     = tt-movto-din-tic.linha
                   tt-titulo.arquivo   = tt-movto-din-tic.arquivo
                
                .         
/*         END.                                                                             */
/*         ELSE DO:                                                                         */
/*             ASSIGN tt-titulo.vl-movto =  tt-titulo.vl-movto + tt-movto-din-tic.vl-movto. */
/*         END.                                                                             */
    END.   
    
    RUN pi-cria-liquidacao-dinheiro. 

END PROCEDURE.

PROCEDURE pi-processa-cheque-coleta:

    EMPTY TEMP-TABLE tt-titulo.

    FOR EACH tt-movto-cheque
       WHERE tt-movto-cheque.tipo = "CHQ":
                
        FIND FIRST tt-titulo EXCLUSIVE-LOCK
             WHERE tt-titulo.cod-estab = tt-movto-cheque.cod-estab
               and tt-titulo.dt-movto  = tt-movto-cheque.dt-movto NO-ERROR.
        IF NOT AVAIL tt-titulo THEN DO:
        
            CREATE tt-titulo.
            ASSIGN tt-titulo.cod-estab = tt-movto-cheque.cod-estab
                   tt-titulo.dt-movto  = tt-movto-cheque.dt-movto
                   tt-titulo.vl-movto  = tt-movto-cheque.vl-movto
                   tt-titulo.cd-tit    = "CHEQ" + string(REPLACE(STRING(tt-movto-cheque.dt-movto,"99/99/99"),"/","")). 

            ASSIGN tt-movto-cheque.cod-tit-acr = tt-titulo.cd-tit.
        END. 
        ELSE DO:
            ASSIGN tt-titulo.vl-movto          =  tt-titulo.vl-movto + tt-movto-cheque.vl-movto.
            ASSIGN tt-movto-cheque.cod-tit-acr = tt-titulo.cd-tit.
        END.       
    END.   

    
    RUN pi-cria-alteracao-cheque. 

END PROCEDURE.

PROCEDURE pi-processa-cheque-deposito:

    EMPTY TEMP-TABLE tt-titulo.

    FOR EACH tt-movto-cheque
       WHERE tt-movto-cheque.tipo = "CHQ":

        FIND FIRST cheq_acr NO-LOCK
             WHERE cheq_acr.cod_banco           = tt-movto-cheque.cod-banco
               AND cheq_acr.cod_agenc_bcia      = tt-movto-cheque.cod-agencia  /* + tt-movto-cheque.dig-agencia */
               AND cheq_acr.cod_cta_corren_bco  = tt-movto-cheque.cod-conta    /* + tt-movto-cheque.dig-conta   */
               AND cheq_acr.num_cheque          = tt-movto-cheque.num-cheq    NO-ERROR.
        IF NOT AVAIL cheq_acr THEN DO:
            RUN pi-cria-tt-erro(INPUT 1,
                                INPUT 17006,
                                INPUT "NÆo encontrado nenhum t¡tulo relacionado ao cheque.",
                                INPUT "Banco/Agencia/Conta/Cheque : " + STRING(tt-movto-cheque.cod-banco) + "/" + STRING(tt-movto-cheque.cod-agencia) + "/" +
                                                                        STRING(tt-movto-cheque.cod-conta) + "/" + STRING(tt-movto-cheque.num-cheq)).
            NEXT.
        END.
        ELSE DO:
            FOR EACH relacto_cheq_acr NO-LOCK
               WHERE relacto_cheq_acr.cod_banco          = cheq_acr.cod_banco
                 AND relacto_cheq_acr.cod_agenc_bcia     = cheq_acr.cod_agenc_bcia
                 AND relacto_cheq_acr.cod_cta_corren_bco = cheq_acr.cod_cta_corren_bco
                 AND relacto_cheq_acr.num_cheque         = cheq_acr.num_cheque,
               FIRST tit_acr NO-LOCK 
               WHERE tit_acr.cod_estab = cheq_acr.cod_estab 
                 AND tit_acr.num_id_tit_acr = cheq_acr.num_id_tit_acr :

                FIND FIRST tt-titulo-cheque EXCLUSIVE-LOCK
                     WHERE tt-titulo-cheque.num_id_tit_acr = tit_acr.num_id_tit_acr NO-ERROR.
                IF NOT AVAIL tt-titulo-cheque THEN DO:
                    CREATE tt-titulo-cheque.
                    ASSIGN tt-titulo-cheque.num_id_tit_acr = tit_acr.num_id_tit_acr
                           tt-titulo-cheque.cod_estab      = tit_acr.cod_estab
                           tt-titulo-cheque.dat_movto      = tt-movto-cheque.dt-movto
                            .
                END.

                ASSIGN tt-titulo-cheque.val_movto = tt-movto-cheque.vl-movto. 

            END.
        END.
    END.

    
    RUN pi-cria-liquidacao-cheque. 

END PROCEDURE.

PROCEDURE pi-cria-alteracao-cheque:
    DEFINE VARIABLE v_hdl_programa AS HANDLE      NO-UNDO.

    bloco_trans:
    DO TRANSACTION ON ERROR UNDO:

        FOR EACH tt-titulo
           BREAK BY tt-titulo.cod-estab:
           
                RUN pi-acompanhar IN h-acomp (INPUT "Est/Titulo: ":U + STRING(tt-titulo.cod-estab) + "/" + STRING(tt-titulo.cd-tit)).

                FIND FIRST tit_acr WHERE
                     tit_acr.cod_estab        = tt-titulo.cod-estab          AND 
                     tit_acr.cod_espec_docto  = "CE"                         AND 
                     tit_acr.cod_tit_acr      = tt-titulo.cd-tit             NO-LOCK NO-ERROR.
                IF NOT AVAIL tit_acr THEN DO:                
                     RUN pi-cria-tt-erro(INPUT 1,
                                         INPUT 17006,
                                         INPUT "Estab/Titulo Nr.: " + string(tt-titulo.cod-estab) + string(tt-titulo.cd-tit) + " , nÆo foi encontrado.",
                                         INPUT "Estab/Titulo Nr.: " + string(tt-titulo.cod-estab)+ string(tt-titulo.cd-tit) + " , nÆo foi encontrado.").                
                     UNDO bloco_trans, LEAVE bloco_trans.                   
                END.

                empty temp-table tt_integr_acr_liquidac_lote    no-error.
                empty temp-table tt_integr_acr_liq_item_lote_3  no-error.
                empty temp-table tt_integr_acr_abat_antecip     no-error.
                empty temp-table tt_integr_acr_abat_prev        no-error.
                empty temp-table tt_integr_acr_cheq             no-error.
                empty temp-table tt_integr_acr_liquidac_impto_2   no-error.
                empty temp-table tt_integr_acr_rel_pend_cheq    no-error.
                empty temp-table tt_integr_acr_liq_aprop_ctbl   no-error.
                empty temp-table tt_integr_acr_liq_desp_rec     no-error.
                empty temp-table tt_integr_acr_aprop_liq_antec  no-error.
                empty temp-table tt_log_erros_import_liquidac   no-error.
           
                assign c_cod_table = "lote_liquidac_acr"
                       w_estabel   = tt-titulo.cod-estab. 
               
                ASSIGN c-cod-refer = "".

                run pi_retorna_sugestao_referencia (Input  "LC",
                                                    Input  today,
                                                    output c-cod-refer,
                                                    Input  c_cod_table,
                                                    input  w_estabel).

                create tt_integr_acr_liquidac_lote.
                assign tt_integr_acr_liquidac_lote.tta_cod_empresa                 = tit_acr.cod_empresa
                       tt_integr_acr_liquidac_lote.tta_cod_estab_refer             = tit_acr.cod_estab
                       tt_integr_acr_liquidac_lote.tta_cod_usuario                 = c-seg-usuario
                       tt_integr_acr_liquidac_lote.tta_cod_portador                = tit_acr.cod_portador
                       tt_integr_acr_liquidac_lote.tta_cod_cart_bcia               = tit_acr.cod_cart_bcia
                       tt_integr_acr_liquidac_lote.tta_dat_gerac_lote_liquidac     = tt-titulo.dt-movto
                       tt_integr_acr_liquidac_lote.tta_dat_transacao               = tt-titulo.dt-movto
                       tt_integr_acr_liquidac_lote.tta_val_tot_lote_liquidac_infor = 0 
                       tt_integr_acr_liquidac_lote.tta_val_tot_lote_liquidac_efetd = 0  
                       tt_integr_acr_liquidac_lote.tta_val_tot_despes_bcia         = 0
                       tt_integr_acr_liquidac_lote.tta_ind_tip_liquidac_acr        = "lote"
                       tt_integr_acr_liquidac_lote.tta_ind_sit_lote_liquidac_acr   = "Em digita‡Æo":U
                       tt_integr_acr_liquidac_lote.tta_nom_arq_movimen_bcia        = ""
                       tt_integr_acr_liquidac_lote.tta_cdn_cliente                 = tit_acr.cdn_cliente
                       tt_integr_acr_liquidac_lote.tta_log_enctro_cta              = no   
                       tt_integr_acr_liquidac_lote.ttv_log_atualiz_refer           = YES
                       tt_integr_acr_liquidac_lote.ttv_log_gera_lote_parcial       = yes 
                       tt_integr_acr_liquidac_lote.ttv_rec_lote_liquidac_acr       = recid(tt_integr_acr_liquidac_lote)
                       tt_integr_acr_liquidac_lote.tta_cod_refer                   = c-cod-refer
                       tt_integr_acr_liquidac_lote.ttv_cod_indic_econ              = "" /*tit_acr.cod_indic_econ*/ . 

                CREATE tt_integr_acr_liq_item_lote_3.
                ASSIGN tt_integr_acr_liq_item_lote_3.tta_cod_empresa                  = tit_acr.cod_empresa
                       tt_integr_acr_liq_item_lote_3.tta_cod_estab                    = tit_acr.cod_estab
                       tt_integr_acr_liq_item_lote_3.tta_cod_espec_docto              = tit_acr.cod_espec_docto
                       tt_integr_acr_liq_item_lote_3.tta_cod_ser_docto                = tit_acr.cod_ser_docto
                       tt_integr_acr_liq_item_lote_3.tta_num_seq_refer                = 1
                       tt_integr_acr_liq_item_lote_3.tta_cod_tit_acr                  = tit_acr.cod_tit_acr
                       tt_integr_acr_liq_item_lote_3.tta_cod_parcela                  = tit_acr.cod_parcela
                       tt_integr_acr_liq_item_lote_3.tta_cdn_cliente                  = tit_acr.cdn_cliente
                       tt_integr_acr_liq_item_lote_3.tta_cod_portador                 = tt-param.c-portador-ch
                       tt_integr_acr_liq_item_lote_3.tta_cod_cart_bcia                = tt-param.c-carteira-ch
                       tt_integr_acr_liq_item_lote_3.tta_cod_finalid_econ             = 'Corrente':u
                       tt_integr_acr_liq_item_lote_3.tta_cod_indic_econ               = 'Real':u
                       tt_integr_acr_liq_item_lote_3.tta_dat_cr_liquidac_tit_acr      = tt-titulo.dt-movto
                       tt_integr_acr_liq_item_lote_3.tta_dat_cr_liquidac_calc         = tt-titulo.dt-movto  
                       tt_integr_acr_liq_item_lote_3.tta_dat_liquidac_tit_acr         = tt-titulo.dt-movto
/*                        tt_integr_acr_liq_item_lote_3.tta_val_tit_acr                  = tt-titulo.vl-movto */
                       tt_integr_acr_liq_item_lote_3.tta_val_liquidac_tit_acr         = tt-titulo.vl-movto
                       tt_integr_acr_liq_item_lote_3.tta_val_desc_tit_acr             = 0
                       tt_integr_acr_liq_item_lote_3.tta_val_abat_tit_acr             = 0
                       tt_integr_acr_liq_item_lote_3.tta_val_despes_bcia              = 0
                       tt_integr_acr_liq_item_lote_3.tta_val_multa_tit_acr            = 0
                       tt_integr_acr_liq_item_lote_3.tta_val_juros                    = 0
                       tt_integr_acr_liq_item_lote_3.tta_val_cm_tit_acr               = 0
                       tt_integr_acr_liq_item_lote_3.tta_val_liquidac_orig            = 0
                       tt_integr_acr_liq_item_lote_3.tta_ind_sit_item_lote_liquidac   = 'Gerado':u
                       tt_integr_acr_liq_item_lote_3.tta_log_gera_avdeb               = no
                       tt_integr_acr_liq_item_lote_3.ttv_rec_lote_liquidac_acr        = recid(tt_integr_acr_liquidac_lote)
                       tt_integr_acr_liq_item_lote_3.ttv_rec_item_lote_liquidac_acr   = recid(tt_integr_acr_liq_item_lote_3)
                       tt_integr_acr_liq_item_lote_3.tta_ind_tip_calc_juros           = 'Simples':u
                       tt_integr_acr_liq_item_lote_3.tta_des_text_histor              = ""
                       tt_integr_acr_liq_item_lote_3.tta_ind_tip_item_liquidac_acr    = 'Pagamento':u
                       tt_integr_acr_liq_item_lote_3.tta_log_gera_antecip             = YES.
                       .
            
                FOR EACH tt-movto-cheque
                   WHERE tt-movto-cheque.cod-estab   = tit_acr.cod_estab
                     AND tt-movto-cheque.cod-tit-acr = tit_acr.cod_tit_acr :

                    FIND FIRST tt_integr_acr_cheq NO-LOCK
                         WHERE tt_integr_acr_cheq.tta_cod_banco               = tt-movto-cheque.cod-banco                                              
                           AND tt_integr_acr_cheq.tta_cod_agenc_bcia          = STRING(tt-movto-cheque.cod-agencia)/* + STRING(tt-movto-cheque.dig-agencia) */
                           AND tt_integr_acr_cheq.tta_cod_cta_corren          = STRING(tt-movto-cheque.cod-conta)  /* + STRING(tt-movto-cheque.dig-conta)   */   
                           AND tt_integr_acr_cheq.tta_num_cheque              = INT(tt-movto-cheque.num-cheq)       NO-ERROR.
                    IF NOT AVAIL tt_integr_acr_cheq THEN DO:
                        CREATE tt_integr_acr_cheq.
                        ASSIGN tt_integr_acr_cheq.tta_cod_banco               = tt-movto-cheque.cod-banco.
                        ASSIGN tt_integr_acr_cheq.tta_cod_agenc_bcia          = STRING(tt-movto-cheque.cod-agencia) /* + STRING(tt-movto-cheque.dig-agencia)  */    .
                        ASSIGN tt_integr_acr_cheq.tta_cod_cta_corren          = STRING(tt-movto-cheque.cod-conta)   /* + STRING(tt-movto-cheque.dig-conta)    */   
                               tt_integr_acr_cheq.tta_num_cheque              = INT(tt-movto-cheque.num-cheq).

                           
                        ASSIGN tt_integr_acr_cheq.tta_dat_emis_cheq           = tt-titulo.dt-movto
                               tt_integr_acr_cheq.tta_dat_depos_cheq_acr      = tt-movto-cheque.dt-credito
                               tt_integr_acr_cheq.tta_dat_prev_depos_cheq_acr = tt-movto-cheque.dt-credito
                               tt_integr_acr_cheq.tta_dat_desc_cheq_acr       = tt-movto-cheque.dt-credito
                               tt_integr_acr_cheq.tta_dat_prev_desc_cheq_acr  = tt-movto-cheque.dt-credito.
                        ASSIGN 
                               tt_integr_acr_cheq.tta_val_cheque              = tt-movto-cheque.vl-movto
                               tt_integr_acr_cheq.tta_cod_estab               = tit_acr.cod_estab
                               tt_integr_acr_cheq.tta_cod_estab_ext           = ""
                               tt_integr_acr_cheq.tta_cod_motiv_devol_cheq    = ""
                               tt_integr_acr_cheq.tta_cod_indic_econ          = "Real"
                               tt_integr_acr_cheq.tta_cod_finalid_econ_ext    = ""
                               tt_integr_acr_cheq.tta_cod_usuar_cheq_acr_terc = c-seg-usuario
                               tt_integr_acr_cheq.tta_log_pend_cheq_acr       = YES
                               tt_integr_acr_cheq.tta_log_cheq_terc           = YES
                               tt_integr_acr_cheq.tta_log_cheq_acr_renegoc    = NO
                               tt_integr_acr_cheq.tta_log_cheq_acr_devolv     = NO
                               tt_integr_acr_cheq.tta_cod_pais                = "BRA"
                            .
    
                        CREATE tt_integr_acr_rel_pend_cheq.
                        ASSIGN tt_integr_acr_rel_pend_cheq.ttv_rec_item_lote_liquidac_acr = RECID(tt_integr_acr_liq_item_lote_3)
                               tt_integr_acr_rel_pend_cheq.tta_cod_banco                  = tt_integr_acr_cheq.tta_cod_banco     
                               tt_integr_acr_rel_pend_cheq.tta_cod_agenc_bcia             = tt_integr_acr_cheq.tta_cod_agenc_bcia
                               tt_integr_acr_rel_pend_cheq.tta_cod_cta_corren             = tt_integr_acr_cheq.tta_cod_cta_corren
                               tt_integr_acr_rel_pend_cheq.tta_num_cheque                 = tt_integr_acr_cheq.tta_num_cheque    
                               tt_integr_acr_rel_pend_cheq.tta_val_vincul_cheq_acr        = tt_integr_acr_cheq.tta_val_cheque.
    
    
                        
                        FIND FIRST ems5.cliente NO-LOCK
                             WHERE cliente.cod_id_feder = tt-movto-cheque.cod-feder NO-ERROR.
                        IF AVAIL cliente THEN DO:
                            ASSIGN tt_integr_acr_cheq.tta_cod_id_feder            = cliente.cod_id_feder
                                   tt_integr_acr_cheq.tta_num_pessoa              = cliente.num_pessoa.
    
                                FIND FIRST pessoa_fisic NO-LOCK
                                     WHERE pessoa_fisic.num_pessoa_fisic = cliente.num_pessoa NO-ERROR.
                                IF AVAIL pessoa_fisic THEN DO:
                                    ASSIGN tt_integr_acr_cheq.tta_nom_emit                = pessoa_fisic.nom_pessoa
                                           tt_integr_acr_cheq.tta_nom_cidad_emit          = pessoa_fisic.nom_cidade.
                                END.
                        END.
                        ELSE DO:
                            FIND FIRST ems5.cliente NO-LOCK
                                 WHERE cliente.cod_id_feder = "99999999999" NO-ERROR.
                            IF AVAIL cliente THEN DO:
                                ASSIGN tt_integr_acr_cheq.tta_cod_id_feder            = cliente.cod_id_feder
                                       tt_integr_acr_cheq.tta_num_pessoa              = cliente.num_pessoa.
        
                                    FIND FIRST pessoa_fisic NO-LOCK
                                         WHERE pessoa_fisic.num_pessoa_fisic = cliente.num_pessoa NO-ERROR.
                                    IF AVAIL pessoa_fisic THEN DO:
                                        ASSIGN tt_integr_acr_cheq.tta_nom_emit                = pessoa_fisic.nom_pessoa
                                               tt_integr_acr_cheq.tta_nom_cidad_emit          = pessoa_fisic.nom_cidade.
                                    END.
                            END.
                        END.
                    END.
                END.

                 
                 run prgfin/acr/acr901zf.py persistent set v_hdl_programa.
                 run pi_main_code_api_integr_acr_liquidac_5  in v_hdl_programa (INPUT 1,
                                                                               INPUT TABLE tt_integr_acr_liquidac_lote,
                                                                               INPUT TABLE tt_integr_acr_liq_item_lote_3,
                                                                               INPUT TABLE tt_integr_acr_abat_antecip,
                                                                               INPUT TABLE tt_integr_acr_abat_prev,
                                                                               INPUT TABLE tt_integr_acr_cheq,
                                                                               INPUT TABLE tt_integr_acr_liquidac_impto_2,
                                                                               INPUT TABLE tt_integr_acr_rel_pend_cheq,
                                                                               INPUT TABLE tt_integr_acr_liq_aprop_ctbl,
                                                                               INPUT TABLE tt_integr_acr_liq_desp_rec,
                                                                               INPUT TABLE tt_integr_acr_aprop_liq_antec,
                                                                               INPUT "EMS",
                                                                               OUTPUT TABLE tt_log_erros_import_liquidac,
                                                                               INPUT TABLE tt_integr_cambio_ems5).
                 Delete procedure v_hdl_programa.

                                                                                  
                IF CAN-FIND(FIRST tt_log_erros_import_liquidac) THEN DO:
                    FOR EACH tt_log_erros_import_liquidac NO-LOCK:

                        FIND FIRST tt_integr_acr_liq_item_lote_3 NO-LOCK NO-ERROR.
                        IF AVAIL tt_integr_acr_liq_item_lote_3 THEN DO:
                            RUN pi-cria-tt-erro(INPUT tt_integr_acr_liq_item_lote_3.tta_num_seq_refer,
                                                INPUT 17006, 
                                                INPUT "Houve erro na cria‡Æo do titulo abaixo, favor verificar.",
                                                INPUT "Estab/Especie/Serie/Titulo/Parcela/Cliente/Portador : " +  STRING(tit_acr.cod_estab)       + "/" +
                                                                                                                  STRING(tit_acr.cod_espec_docto) + "/" +
                                                                                                                  STRING(tit_acr.cod_ser_docto)   + "/" +
                                                                                                                  STRING(tit_acr.cod_tit_acr)     + "/" +
                                                                                                                  STRING(tit_acr.cod_parcela)     + "/" +
                                                                                                                  STRING(tit_acr.cdn_cliente)     + "/"  +
                                                                                                                  STRING(tit_acr.cod_portador)   ). 
                        END.

                        RUN pi-cria-tt-erro(INPUT  tt_log_erros_import_liquidac.tta_num_seq,
                                            INPUT  tt_log_erros_import_liquidac.ttv_num_erro_log,    
                                            INPUT  tt_log_erros_import_liquidac.ttv_des_msg_erro,
                                            INPUT  tt_log_erros_import_liquidac.ttv_des_msg_erro).
                    END.                     
                    UNDO bloco_trans, LEAVE bloco_trans.                
                END. 
                ELSE DO:
                    FOR EACH tt_integr_acr_liq_item_lote_3:
                       CREATE tt-tit-criados.
                       ASSIGN tt-tit-criados.cod_estab          = tit_acr.cod_estab
                              tt-tit-criados.cod_espec_docto    = tt_integr_acr_liq_item_lote_3.tta_cod_espec_docto
                              tt-tit-criados.cod_ser_docto      = tt_integr_acr_liq_item_lote_3.tta_cod_ser_docto
                              tt-tit-criados.cod_tit_acr        = tt_integr_acr_liq_item_lote_3.tta_cod_tit_acr
                              tt-tit-criados.cod_parcela        = tt_integr_acr_liq_item_lote_3.tta_cod_parcela              
                              tt-tit-criados.cdn_cliente        = tt_integr_acr_liq_item_lote_3.tta_cdn_cliente
                              tt-tit-criados.cod_portador       = tt_integr_acr_liq_item_lote_3.tta_cod_portad_ext
                              tt-tit-criados.val_origin_tit_acr = tt_integr_acr_liq_item_lote_3.tta_val_tit_acr
                              tt-tit-criados.dat_transacao      = tit_acr.dat_transacao
                              tt-tit-criados.dat_emis_docto     = tit_acr.dat_emis_docto    
                              tt-tit-criados.dat_vencto_tit_acr = tit_acr.dat_vencto_tit_acr
                              tt-tit-criados.situacao           = "T¡tulo Baixado".
                   END.

                END.
        END.
    END.

END PROCEDURE. /* pi-cria-alteracao-cheque */

PROCEDURE pi-cria-liquidacao-dinheiro:
    DEFINE VARIABLE v_hdl_programa AS HANDLE      NO-UNDO.

    empty temp-table tt_integr_acr_liquidac_lote    no-error.
    empty temp-table tt_integr_acr_liq_item_lote_3  no-error.
    empty temp-table tt_integr_acr_abat_antecip     no-error.
    empty temp-table tt_integr_acr_abat_prev        no-error.
    empty temp-table tt_integr_acr_cheq             no-error.
    empty temp-table tt_integr_acr_liquidac_impto_2 NO-ERROR.
    empty temp-table tt_integr_acr_rel_pend_cheq    no-error.
    empty temp-table tt_integr_acr_liq_aprop_ctbl   no-error.
    empty temp-table tt_integr_acr_liq_desp_rec     no-error.
    empty temp-table tt_integr_acr_aprop_liq_antec  no-error.
    empty temp-table tt_log_erros_import_liquidac   no-error.

    bloco_trans:
    DO TRANSACTION ON ERROR UNDO:
    
        FOR EACH tt-titulo
           BREAK BY tt-titulo.cod-estab:
           
                RUN pi-acompanhar IN h-acomp (INPUT "Est/Titulo: ":U + STRING(tt-titulo.cod-estab) + "/" + STRING(tt-titulo.cd-tit)).
           
                FIND FIRST tit_acr NO-LOCK
                     WHERE tit_acr.cod_estab        = tt-titulo.cod-estab          
                       AND tit_acr.cod_espec_docto  = "DI"                         
                       AND tit_acr.cod_tit_acr      = tt-titulo.cd-tit    NO-ERROR.
                IF NOT AVAIL tit_acr THEN DO:                
                     RUN pi-cria-tt-erro(INPUT 1,
                                         INPUT 17006,
                                         INPUT "Estab/Titulo Nr.: " + string(tt-titulo.cod-estab) + string(tt-titulo.cd-tit) + " , nÆo foi encontrado.",
                                         INPUT "Estab/Titulo Nr.: " + string(tt-titulo.cod-estab)+ string(tt-titulo.cd-tit) + " , nÆo foi encontrado.").                
                     UNDO bloco_trans, LEAVE bloco_trans.                   
                END. 

                IF AVAIL tit_acr AND log_sdo_tit_acr = NO THEN DO:
                    FIND FIRST tit_acr NO-LOCK
                         WHERE tit_acr.cod_estab        = tt-titulo.cod-estab          
                           AND tit_acr.cod_espec_docto  = "DI"                         
                           AND tit_acr.cod_tit_acr      = tt-titulo.cd-tit
                           AND log_sdo_tit_acr          = YES    NO-ERROR.
                    IF NOT AVAIL tit_acr THEN DO:                
                         RUN pi-cria-tt-erro(INPUT 1,
                                             INPUT 17006,
                                             INPUT "Estab/Titulo Nr.: " + string(tt-titulo.cod-estab) + string(tt-titulo.cd-tit) + " , nÆo foi encontrado com saldo pra realizar a Liquida‡Æo.",
                                             INPUT "Estab/Titulo Nr.: " + string(tt-titulo.cod-estab)+ string(tt-titulo.cd-tit) + " , nÆo foi encontrado com saldo pra realizar a Liquida‡Æo.").                
                         UNDO bloco_trans, LEAVE bloco_trans.                   
                    END. 
                END.

                empty temp-table tt_integr_acr_liquidac_lote    no-error.
                empty temp-table tt_integr_acr_liq_item_lote_3    no-error.
                empty temp-table tt_integr_acr_abat_antecip     no-error.
                empty temp-table tt_integr_acr_abat_prev        no-error.
                empty temp-table tt_integr_acr_cheq             no-error.
                empty temp-table tt_integr_acr_liquidac_impto_2   no-error.
                empty temp-table tt_integr_acr_rel_pend_cheq    no-error.
                empty temp-table tt_integr_acr_liq_aprop_ctbl   no-error.
                empty temp-table tt_integr_acr_liq_desp_rec     no-error.
                empty temp-table tt_integr_acr_aprop_liq_antec  no-error.
                empty temp-table tt_log_erros_import_liquidac   no-error.
           
                assign c_cod_table = "lote_liquidac_acr"
                       w_estabel   = tt-titulo.cod-estab. 
               
                ASSIGN c-cod-refer = "".

                run pi_retorna_sugestao_referencia (INPUT  "LD",
                                                    INPUT  TODAY,
                                                    OUTPUT c-cod-refer,
                                                    INPUT  c_cod_table,
                                                    INPUT  w_estabel).

                create tt_integr_acr_liquidac_lote.
                assign tt_integr_acr_liquidac_lote.tta_cod_empresa                 = tit_acr.cod_empresa
                       tt_integr_acr_liquidac_lote.tta_cod_estab_refer             = tit_acr.cod_estab
                       tt_integr_acr_liquidac_lote.tta_cod_usuario                 = c-seg-usuario
                       tt_integr_acr_liquidac_lote.tta_cod_portador                = tit_acr.cod_portador
                       tt_integr_acr_liquidac_lote.tta_cod_cart_bcia               = tit_acr.cod_cart_bcia
                       tt_integr_acr_liquidac_lote.tta_dat_gerac_lote_liquidac     = tt-titulo.dt-liquid
                       tt_integr_acr_liquidac_lote.tta_dat_transacao               = tt-titulo.dt-liquid
                       tt_integr_acr_liquidac_lote.tta_val_tot_lote_liquidac_infor = 0 
                       tt_integr_acr_liquidac_lote.tta_val_tot_lote_liquidac_efetd = 0  
                       tt_integr_acr_liquidac_lote.tta_val_tot_despes_bcia         = 0
                       tt_integr_acr_liquidac_lote.tta_ind_tip_liquidac_acr        = "lote"
                       tt_integr_acr_liquidac_lote.tta_ind_sit_lote_liquidac_acr   = "Em digita‡Æo":U
                       tt_integr_acr_liquidac_lote.tta_nom_arq_movimen_bcia        = ""
                       tt_integr_acr_liquidac_lote.tta_cdn_cliente                 = tit_acr.cdn_cliente
                       tt_integr_acr_liquidac_lote.tta_log_enctro_cta              = no   
                       tt_integr_acr_liquidac_lote.ttv_log_atualiz_refer           = YES
                       tt_integr_acr_liquidac_lote.ttv_log_gera_lote_parcial       = yes 
                       tt_integr_acr_liquidac_lote.ttv_rec_lote_liquidac_acr       = recid(tt_integr_acr_liquidac_lote)
                       tt_integr_acr_liquidac_lote.tta_cod_refer                   = c-cod-refer
                       tt_integr_acr_liquidac_lote.ttv_cod_indic_econ              = "" /*tit_acr.cod_indic_econ*/ . 

                                      
                create tt_integr_acr_liq_item_lote_3.
                assign tt_integr_acr_liq_item_lote_3.tta_cod_empresa              = tit_acr.cod_empresa
                       tt_integr_acr_liq_item_lote_3.tta_cod_estab                = tit_acr.cod_estab
                       tt_integr_acr_liq_item_lote_3.tta_cod_espec_docto          = tit_acr.cod_espec_docto
                       tt_integr_acr_liq_item_lote_3.tta_cod_ser_docto            = tit_acr.cod_ser_docto
                       tt_integr_acr_liq_item_lote_3.tta_cod_tit_acr              = tit_acr.cod_tit_acr
                       tt_integr_acr_liq_item_lote_3.tta_cod_parcela              = tit_acr.cod_parcela
                       tt_integr_acr_liq_item_lote_3.tta_cdn_cliente              = tit_acr.cdn_cliente
                       tt_integr_acr_liq_item_lote_3.tta_cod_portad_ext           = ""
                       tt_integr_acr_liq_item_lote_3.tta_cod_modalid_ext          = ""
                       tt_integr_acr_liq_item_lote_3.tta_cod_portador             = tt-param.c-portador-di
                       tt_integr_acr_liq_item_lote_3.tta_cod_cart_bcia            = tt-param.c-carteira-di
                       tt_integr_acr_liq_item_lote_3.tta_cod_finalid_econ         = "Corrente"
                       tt_integr_acr_liq_item_lote_3.tta_cod_indic_econ           = tit_acr.cod_indic_econ 
                       tt_integr_acr_liq_item_lote_3.tta_val_tit_acr              = tit_acr.val_sdo_tit_acr /* tt-titulo.vl-movto */
                       tt_integr_acr_liq_item_lote_3.tta_val_liquidac_tit_acr     = tt-titulo.vl-movto
                       tt_integr_acr_liq_item_lote_3.tta_dat_cr_liquidac_tit_acr  = tt-titulo.dt-liquid
                       tt_integr_acr_liq_item_lote_3.tta_dat_cr_liquidac_calc     = tt-titulo.dt-liquid
                       tt_integr_acr_liq_item_lote_3.tta_dat_liquidac_tit_acr     = tt-titulo.dt-liquid
                       tt_integr_acr_liq_item_lote_3.tta_cod_autoriz_bco          = ""
                       tt_integr_acr_liq_item_lote_3.tta_val_abat_tit_acr         = 0
                       tt_integr_acr_liq_item_lote_3.tta_val_despes_bcia          = 0
                       tt_integr_acr_liq_item_lote_3.tta_val_multa_tit_acr        = 0
                       tt_integr_acr_liq_item_lote_3.tta_val_juros                = 0
                       tt_integr_acr_liq_item_lote_3.tta_val_cm_tit_acr           = 0
                       tt_integr_acr_liq_item_lote_3.tta_val_liquidac_orig        = 0
                       tt_integr_acr_liq_item_lote_3.tta_val_desc_tit_acr_orig    = 0  
                       tt_integr_acr_liq_item_lote_3.tta_val_abat_tit_acr_orig    = 0 
                       tt_integr_acr_liq_item_lote_3.tta_val_despes_bcia_orig     = 0
                       tt_integr_acr_liq_item_lote_3.tta_val_multa_tit_acr_origin = 0
                       tt_integr_acr_liq_item_lote_3.tta_val_juros_tit_acr_orig   = 0
                       tt_integr_acr_liq_item_lote_3.tta_val_cm_tit_acr_orig      = 0
                       tt_integr_acr_liq_item_lote_3.tta_val_nota_db_orig         = 0
                       tt_integr_acr_liq_item_lote_3.tta_log_gera_antecip         = NO
                       tt_integr_acr_liq_item_lote_3.tta_des_text_histor          = "Liquida‡Æo realizada atrav‚s do arquivo:  " + tt-titulo.arquivo + " linha: " + STRING(tt-titulo.linha) + "."
                       tt_integr_acr_liq_item_lote_3.tta_ind_sit_item_lote_liquidac = ""
                       tt_integr_acr_liq_item_lote_3.tta_log_gera_avdeb           = NO
                       tt_integr_acr_liq_item_lote_3.tta_cod_indic_econ_avdeb     = ""
                       tt_integr_acr_liq_item_lote_3.tta_cod_portad_avdeb         = ""
                       tt_integr_acr_liq_item_lote_3.tta_cod_cart_bcia_avdeb      = "" 
                       tt_integr_acr_liq_item_lote_3.tta_dat_vencto_avdeb         = ?
                       tt_integr_acr_liq_item_lote_3.tta_val_perc_juros_avdeb     = 0
                       tt_integr_acr_liq_item_lote_3.tta_val_avdeb                = 0
                       tt_integr_acr_liq_item_lote_3.tta_log_movto_comis_estordo  = no
                       tt_integr_acr_liq_item_lote_3.tta_ind_tip_item_liquidac_acr = "Pagamento"
                       tt_integr_acr_liq_item_lote_3.tta_ind_tip_calc_juros       = "Compostos"
                       tt_integr_acr_liq_item_lote_3.ttv_rec_lote_liquidac_acr    = tt_integr_acr_liquidac_lote.ttv_rec_lote_liquidac_acr
                       tt_integr_acr_liq_item_lote_3.ttv_rec_item_lote_liquidac_acr = recid(tt_integr_acr_liq_item_lote_3)
                       tt_integr_acr_liq_item_lote_3.tta_val_cotac_indic_econ = 1.


                IF tt_integr_acr_liq_item_lote_3.tta_val_liquidac_tit_acr > tit_acr.val_sdo_tit_acr THEN DO:
                     ASSIGN tt_integr_acr_liq_item_lote_3.tta_log_gera_antecip = YES.
                END.
                ELSE ASSIGN tt_integr_acr_liq_item_lote_3.tta_log_gera_antecip = NO.

                IF tt-titulo.vl-movto - tit_acr.val_sdo_tit_acr = 0.01 THEN DO:
                    ASSIGN tt_integr_acr_liq_item_lote_3.tta_log_gera_antecip         = NO
                           tt_integr_acr_liq_item_lote_3.tta_val_liquidac_tit_acr     = tt-titulo.vl-movto - 0.01
                           tt_integr_acr_liq_item_lote_3.tta_val_juros                = 0.01 .
                END.

/*                  CREATE tt_integr_acr_liq_aprop_ctbl.                                                                      */
/*                  ASSIGN tt_integr_acr_liq_aprop_ctbl.ttv_rec_item_lote_liquidac_acr = recid(tt_integr_acr_liq_item_lote_3) */
/*                         tt_integr_acr_liq_aprop_ctbl.tta_cod_fluxo_financ_ext       = ""                                   */
/*                         tt_integr_acr_liq_aprop_ctbl.tta_cod_unid_negoc             = "000"                                */
/*                         tt_integr_acr_liq_aprop_ctbl.tta_cod_tip_fluxo_financ       = "105"                                */
/*                         tt_integr_acr_liq_aprop_ctbl.tta_val_aprop_ctbl             = tt-titulo.vl-movto.                  */

                 RUN prgfin/acr/acr901zf.py PERSISTENT SET v_hdl_programa.
                 RUN pi_main_code_api_integr_acr_liquidac_5 IN v_hdl_programa (INPUT 1,
                                                                               INPUT TABLE tt_integr_acr_liquidac_lote,
                                                                               INPUT TABLE tt_integr_acr_liq_item_lote_3,
                                                                               INPUT TABLE tt_integr_acr_abat_antecip,
                                                                               INPUT TABLE tt_integr_acr_abat_prev,
                                                                               INPUT TABLE tt_integr_acr_cheq,
                                                                               INPUT TABLE tt_integr_acr_liquidac_impto_2,
                                                                               INPUT TABLE tt_integr_acr_rel_pend_cheq,
                                                                               INPUT TABLE tt_integr_acr_liq_aprop_ctbl,
                                                                               INPUT TABLE tt_integr_acr_liq_desp_rec,
                                                                               INPUT TABLE tt_integr_acr_aprop_liq_antec,
                                                                               INPUT "EMS",
                                                                               OUTPUT TABLE tt_log_erros_import_liquidac,
                                                                               INPUT TABLE tt_integr_cambio_ems5).
                 DELETE PROCEDURE v_hdl_programa.

                IF CAN-FIND(FIRST tt_log_erros_import_liquidac) THEN DO:
                    FOR EACH tt_log_erros_import_liquidac NO-LOCK:

                        FIND FIRST tt_integr_acr_liq_item_lote_3 NO-LOCK NO-ERROR.
                        IF AVAIL tt_integr_acr_liq_item_lote_3 THEN DO:
                            RUN pi-cria-tt-erro(INPUT tt_integr_acr_liq_item_lote_3.tta_num_seq_refer,
                                                INPUT 17006, 
                                                INPUT "Houve erro na cria‡Æo do titulo abaixo, favor verificar.",
                                                INPUT "Estab/Especie/Serie/Titulo/Parcela/Cliente/Portador : " +  STRING(tit_acr.cod_estab)       + "/" +
                                                                                                                  STRING(tit_acr.cod_espec_docto) + "/" +
                                                                                                                  STRING(tit_acr.cod_ser_docto)   + "/" +
                                                                                                                  STRING(tit_acr.cod_tit_acr)     + "/" +
                                                                                                                  STRING(tit_acr.cod_parcela)     + "/" +
                                                                                                                  STRING(tit_acr.cdn_cliente)     + "/"  +
                                                                                                                  STRING(tit_acr.cod_portador)   ). 
                        END.

                        RUN pi-cria-tt-erro(INPUT  tt_log_erros_import_liquidac.tta_num_seq,
                                            INPUT  tt_log_erros_import_liquidac.ttv_num_erro_log,    
                                            INPUT  tt_log_erros_import_liquidac.ttv_des_msg_erro,
                                            INPUT  tt_log_erros_import_liquidac.ttv_des_msg_erro).
                    END.                     
                    UNDO bloco_trans, LEAVE bloco_trans.                
                END. 
                ELSE DO:
                    FOR EACH tt_integr_acr_liq_item_lote_3:
                       CREATE tt-tit-criados.
                       ASSIGN tt-tit-criados.cod_estab          = tit_acr.cod_estab
                              tt-tit-criados.cod_espec_docto    = tt_integr_acr_liq_item_lote_3.tta_cod_espec_docto
                              tt-tit-criados.cod_ser_docto      = tt_integr_acr_liq_item_lote_3.tta_cod_ser_docto
                              tt-tit-criados.cod_tit_acr        = tt_integr_acr_liq_item_lote_3.tta_cod_tit_acr
                              tt-tit-criados.cod_parcela        = tt_integr_acr_liq_item_lote_3.tta_cod_parcela              
                              tt-tit-criados.cdn_cliente        = tt_integr_acr_liq_item_lote_3.tta_cdn_cliente
                              tt-tit-criados.cod_portador       = tt_integr_acr_liq_item_lote_3.tta_cod_portad_ext
                              tt-tit-criados.val_origin_tit_acr = tt_integr_acr_liq_item_lote_3.tta_val_tit_acr
                              tt-tit-criados.dat_transacao      = tit_acr.dat_transacao
                              tt-tit-criados.dat_emis_docto     = tit_acr.dat_emis_docto    
                              tt-tit-criados.dat_vencto_tit_acr = tit_acr.dat_vencto_tit_acr
                              tt-tit-criados.situacao           = "T¡tulo Alterado".
                   END.

                END.

         END.
    
    END. /* BLOCO TRANSA€ÇO */
END PROCEDURE.


PROCEDURE pi-cria-liquidacao-cheque:
    DEFINE VARIABLE v_hdl_programa AS HANDLE      NO-UNDO.

    empty temp-table tt_integr_acr_liquidac_lote    no-error.
    empty temp-table tt_integr_acr_liq_item_lote_3    no-error.
    empty temp-table tt_integr_acr_abat_antecip     no-error.
    empty temp-table tt_integr_acr_abat_prev        no-error.
    empty temp-table tt_integr_acr_cheq             no-error.
    empty temp-table tt_integr_acr_liquidac_impto_2   no-error.
    empty temp-table tt_integr_acr_rel_pend_cheq    no-error.
    empty temp-table tt_integr_acr_liq_aprop_ctbl   no-error.
    empty temp-table tt_integr_acr_liq_desp_rec     no-error.
    empty temp-table tt_integr_acr_aprop_liq_antec  no-error.
    empty temp-table tt_log_erros_import_liquidac   no-error.

    bloco_trans:
    DO TRANSACTION ON ERROR UNDO:
    
        FOR EACH tt-titulo-cheque
           BREAK BY tt-titulo-cheque.cod_estab:
           
                FIND FIRST tit_acr NO-LOCK
                     WHERE tit_acr.num_id_tit_acr =  tt-titulo-cheque.num_id_tit_acr  NO-ERROR.
                IF NOT AVAIL tit_acr THEN DO:                
                     RUN pi-cria-tt-erro(INPUT 1,
                                         INPUT 17006,
                                         INPUT "Estab/Serie/Titulo: ":U + STRING(tit_acr.cod_estab) + "/" + STRING(tit_acr.cod_ser_docto) + "/" + STRING(tit_acr.cod_tit_acr) + " , nÆo foi encontrado.",
                                         INPUT "Estab/Serie/Titulo: ":U + STRING(tit_acr.cod_estab) + "/" + STRING(tit_acr.cod_ser_docto) + "/" + STRING(tit_acr.cod_tit_acr) + " , nÆo foi encontrado.").                
                     UNDO bloco_trans, LEAVE bloco_trans.                   
                END. 

                RUN pi-acompanhar IN h-acomp (INPUT "Estab/Serie/Titulo: ":U + STRING(tit_acr.cod_estab) + "/" + STRING(tit_acr.cod_ser_docto) + "/" + STRING(tit_acr.cod_tit_acr)).

                empty temp-table tt_integr_acr_liquidac_lote    no-error.
                empty temp-table tt_integr_acr_liq_item_lote_3    no-error.
                empty temp-table tt_integr_acr_abat_antecip     no-error.
                empty temp-table tt_integr_acr_abat_prev        no-error.
                empty temp-table tt_integr_acr_cheq             no-error.
                empty temp-table tt_integr_acr_liquidac_impto_2   no-error.
                empty temp-table tt_integr_acr_rel_pend_cheq    no-error.
                empty temp-table tt_integr_acr_liq_aprop_ctbl   no-error.
                empty temp-table tt_integr_acr_liq_desp_rec     no-error.
                empty temp-table tt_integr_acr_aprop_liq_antec  no-error.
                empty temp-table tt_log_erros_import_liquidac   no-error.
           
                assign c_cod_table = "lote_liquidac_acr"
                       w_estabel   = tit_acr.cod_estab. 
               
                ASSIGN c-cod-refer = "".

                run pi_retorna_sugestao_referencia (Input  "DC",
                                                    Input  today,
                                                    output c-cod-refer,
                                                    Input  c_cod_table,
                                                    input  w_estabel).

                create tt_integr_acr_liquidac_lote.
                assign tt_integr_acr_liquidac_lote.tta_cod_empresa                 = tit_acr.cod_empresa
                       tt_integr_acr_liquidac_lote.tta_cod_estab_refer             = tit_acr.cod_estab
                       tt_integr_acr_liquidac_lote.tta_cod_usuario                 = c-seg-usuario
                       tt_integr_acr_liquidac_lote.tta_cod_portador                = tit_acr.cod_portador
                       tt_integr_acr_liquidac_lote.tta_cod_cart_bcia               = tit_acr.cod_cart_bcia
                       tt_integr_acr_liquidac_lote.tta_dat_gerac_lote_liquidac     = tt-titulo-cheque.dat_movto
                       tt_integr_acr_liquidac_lote.tta_dat_transacao               = tt-titulo-cheque.dat_movto
                       tt_integr_acr_liquidac_lote.tta_val_tot_lote_liquidac_infor = 0 
                       tt_integr_acr_liquidac_lote.tta_val_tot_lote_liquidac_efetd = 0  
                       tt_integr_acr_liquidac_lote.tta_val_tot_despes_bcia         = 0
                       tt_integr_acr_liquidac_lote.tta_ind_tip_liquidac_acr        = "lote"
                       tt_integr_acr_liquidac_lote.tta_ind_sit_lote_liquidac_acr   = "Em digita‡Æo":U
                       tt_integr_acr_liquidac_lote.tta_nom_arq_movimen_bcia        = ""
                       tt_integr_acr_liquidac_lote.tta_cdn_cliente                 = tit_acr.cdn_cliente
                       tt_integr_acr_liquidac_lote.tta_log_enctro_cta              = no   
                       tt_integr_acr_liquidac_lote.ttv_log_atualiz_refer           = YES
                       tt_integr_acr_liquidac_lote.ttv_log_gera_lote_parcial       = yes 
                       tt_integr_acr_liquidac_lote.ttv_rec_lote_liquidac_acr       = recid(tt_integr_acr_liquidac_lote)
                       tt_integr_acr_liquidac_lote.tta_cod_refer                   = c-cod-refer
                       tt_integr_acr_liquidac_lote.ttv_cod_indic_econ              = "" /*tit_acr.cod_indic_econ*/ . 

                                      
                create tt_integr_acr_liq_item_lote_3.
                assign tt_integr_acr_liq_item_lote_3.tta_cod_empresa              = tit_acr.cod_empresa
                       tt_integr_acr_liq_item_lote_3.tta_cod_estab                = tit_acr.cod_estab
                       tt_integr_acr_liq_item_lote_3.tta_cod_espec_docto          = tit_acr.cod_espec_docto
                       tt_integr_acr_liq_item_lote_3.tta_cod_ser_docto            = tit_acr.cod_ser_docto
                       tt_integr_acr_liq_item_lote_3.tta_cod_tit_acr              = tit_acr.cod_tit_acr
                       tt_integr_acr_liq_item_lote_3.tta_cod_parcela              = tit_acr.cod_parcela
                       tt_integr_acr_liq_item_lote_3.tta_cdn_cliente              = tit_acr.cdn_cliente
                       tt_integr_acr_liq_item_lote_3.tta_cod_portad_ext           = ""
                       tt_integr_acr_liq_item_lote_3.tta_cod_modalid_ext          = ""
                       tt_integr_acr_liq_item_lote_3.tta_cod_portador             = tt-param.c-portador-ch
                       tt_integr_acr_liq_item_lote_3.tta_cod_cart_bcia            = tt-param.c-carteira-ch
                       tt_integr_acr_liq_item_lote_3.tta_cod_finalid_econ         = "Corrente"
                       tt_integr_acr_liq_item_lote_3.tta_cod_indic_econ           = tit_acr.cod_indic_econ 
                       tt_integr_acr_liq_item_lote_3.tta_val_tit_acr              = tt-titulo-cheque.val_movto
                       tt_integr_acr_liq_item_lote_3.tta_val_liquidac_tit_acr     = tt-titulo-cheque.val_movto
                       tt_integr_acr_liq_item_lote_3.tta_dat_cr_liquidac_tit_acr  = tt-titulo-cheque.dat_movto
                       tt_integr_acr_liq_item_lote_3.tta_dat_cr_liquidac_calc     = tt-titulo-cheque.dat_movto
                       tt_integr_acr_liq_item_lote_3.tta_dat_liquidac_tit_acr     = tt-titulo-cheque.dat_movto
                       tt_integr_acr_liq_item_lote_3.tta_cod_autoriz_bco          = ""
                       tt_integr_acr_liq_item_lote_3.tta_val_abat_tit_acr         = 0
                       tt_integr_acr_liq_item_lote_3.tta_val_despes_bcia          = 0
                       tt_integr_acr_liq_item_lote_3.tta_val_multa_tit_acr        = 0
                       tt_integr_acr_liq_item_lote_3.tta_val_juros                = 0
                       tt_integr_acr_liq_item_lote_3.tta_val_cm_tit_acr           = 0
                       tt_integr_acr_liq_item_lote_3.tta_val_liquidac_orig        = 0
                       tt_integr_acr_liq_item_lote_3.tta_val_desc_tit_acr_orig    = 0  
                       tt_integr_acr_liq_item_lote_3.tta_val_abat_tit_acr_orig    = 0 
                       tt_integr_acr_liq_item_lote_3.tta_val_despes_bcia_orig     = 0
                       tt_integr_acr_liq_item_lote_3.tta_val_multa_tit_acr_origin = 0
                       tt_integr_acr_liq_item_lote_3.tta_val_juros_tit_acr_orig   = 0
                       tt_integr_acr_liq_item_lote_3.tta_val_cm_tit_acr_orig      = 0
                       tt_integr_acr_liq_item_lote_3.tta_val_nota_db_orig         = 0
                       tt_integr_acr_liq_item_lote_3.tta_log_gera_antecip         = YES
                       tt_integr_acr_liq_item_lote_3.tta_des_text_histor          = ""
                       tt_integr_acr_liq_item_lote_3.tta_ind_sit_item_lote_liquidac = ""
                       tt_integr_acr_liq_item_lote_3.tta_log_gera_avdeb           = NO
                       tt_integr_acr_liq_item_lote_3.tta_cod_indic_econ_avdeb     = ""
                       tt_integr_acr_liq_item_lote_3.tta_cod_portad_avdeb         = ""
                       tt_integr_acr_liq_item_lote_3.tta_cod_cart_bcia_avdeb      = "" 
                       tt_integr_acr_liq_item_lote_3.tta_dat_vencto_avdeb         = ?
                       tt_integr_acr_liq_item_lote_3.tta_val_perc_juros_avdeb     = 0
                       tt_integr_acr_liq_item_lote_3.tta_val_avdeb                = 0
                       tt_integr_acr_liq_item_lote_3.tta_log_movto_comis_estordo  = no
                       tt_integr_acr_liq_item_lote_3.tta_ind_tip_item_liquidac_acr = "Pagamento"
                       tt_integr_acr_liq_item_lote_3.tta_ind_tip_calc_juros       = "Compostos"
                       tt_integr_acr_liq_item_lote_3.ttv_rec_lote_liquidac_acr    = tt_integr_acr_liquidac_lote.ttv_rec_lote_liquidac_acr
                       tt_integr_acr_liq_item_lote_3.ttv_rec_item_lote_liquidac_acr = recid(tt_integr_acr_liq_item_lote_3)
                       tt_integr_acr_liq_item_lote_3.tta_val_cotac_indic_econ = 1.

            
                 RUN prgfin/acr/acr901zf.py PERSISTENT SET v_hdl_programa.
                 RUN pi_main_code_api_integr_acr_liquidac_5 IN v_hdl_programa (INPUT 1,
                                                                               INPUT TABLE tt_integr_acr_liquidac_lote,
                                                                               INPUT TABLE tt_integr_acr_liq_item_lote_3,
                                                                               INPUT TABLE tt_integr_acr_abat_antecip,
                                                                               INPUT TABLE tt_integr_acr_abat_prev,
                                                                               INPUT TABLE tt_integr_acr_cheq,
                                                                               INPUT TABLE tt_integr_acr_liquidac_impto_2,
                                                                               INPUT TABLE tt_integr_acr_rel_pend_cheq,
                                                                               INPUT TABLE tt_integr_acr_liq_aprop_ctbl,
                                                                               INPUT TABLE tt_integr_acr_liq_desp_rec,
                                                                               INPUT TABLE tt_integr_acr_aprop_liq_antec,
                                                                               INPUT "EMS",
                                                                               OUTPUT TABLE tt_log_erros_import_liquidac,
                                                                               INPUT TABLE tt_integr_cambio_ems5).
                 DELETE PROCEDURE v_hdl_programa.
                                            
                 IF CAN-FIND(FIRST tt_log_erros_import_liquidac) THEN DO:
                     FOR EACH tt_log_erros_import_liquidac NO-LOCK:

                         FIND FIRST tt_integr_acr_liq_item_lote_3 NO-LOCK NO-ERROR.
                         IF AVAIL tt_integr_acr_liq_item_lote_3 THEN DO:
                             RUN pi-cria-tt-erro(INPUT tt_integr_acr_liq_item_lote_3.tta_num_seq_refer,
                                                 INPUT 17006, 
                                                 INPUT "Houve erro na cria‡Æo do titulo abaixo, favor verificar.",
                                                 INPUT "Estab/Especie/Serie/Titulo/Parcela/Cliente/Portador : " +  STRING(tit_acr.cod_estab)       + "/" +
                                                                                                                   STRING(tit_acr.cod_espec_docto) + "/" +
                                                                                                                   STRING(tit_acr.cod_ser_docto)   + "/" +
                                                                                                                   STRING(tit_acr.cod_tit_acr)     + "/" +
                                                                                                                   STRING(tit_acr.cod_parcela)     + "/" +
                                                                                                                   STRING(tit_acr.cdn_cliente)     + "/"  +
                                                                                                                   STRING(tit_acr.cod_portador)   ). 
                         END.

                         RUN pi-cria-tt-erro(INPUT  tt_log_erros_import_liquidac.tta_num_seq,
                                             INPUT  tt_log_erros_import_liquidac.ttv_num_erro_log,    
                                             INPUT  tt_log_erros_import_liquidac.ttv_des_msg_erro,
                                             INPUT  tt_log_erros_import_liquidac.ttv_des_msg_erro).
                     END.                     
                     UNDO bloco_trans, LEAVE bloco_trans.                
                 END. 
                 ELSE DO:
                     FOR EACH tt_integr_acr_liq_item_lote_3:
                        CREATE tt-tit-criados.
                        ASSIGN tt-tit-criados.cod_estab          = tit_acr.cod_estab
                               tt-tit-criados.cod_espec_docto    = tt_integr_acr_liq_item_lote_3.tta_cod_espec_docto
                               tt-tit-criados.cod_ser_docto      = tt_integr_acr_liq_item_lote_3.tta_cod_ser_docto
                               tt-tit-criados.cod_tit_acr        = tt_integr_acr_liq_item_lote_3.tta_cod_tit_acr
                               tt-tit-criados.cod_parcela        = tt_integr_acr_liq_item_lote_3.tta_cod_parcela              
                               tt-tit-criados.cdn_cliente        = tt_integr_acr_liq_item_lote_3.tta_cdn_cliente
                               tt-tit-criados.cod_portador       = tt_integr_acr_liq_item_lote_3.tta_cod_portad_ext
                               tt-tit-criados.val_origin_tit_acr = tt_integr_acr_liq_item_lote_3.tta_val_tit_acr
                               tt-tit-criados.dat_transacao      = tit_acr.dat_transacao
                               tt-tit-criados.dat_emis_docto     = tit_acr.dat_emis_docto    
                               tt-tit-criados.dat_vencto_tit_acr = tit_acr.dat_vencto_tit_acr
                               tt-tit-criados.situacao           = "T¡tulo Alterado".
                    END.

                 END.
        END.    
    
    END. /* BLOCO TRANSA€ÇO */

       

END PROCEDURE.

PROCEDURE pi_retorna_sugestao_referencia:

    /************************ Parameter Definition Begin ************************/
    def Input param p_ind_tip_atualiz as CHARACTER  format "X(08)"      no-undo.
    def Input param p_dat_refer       as DATE       format "99/99/9999" no-undo.
    def output param p_cod_refer      as character  format "x(10)"      no-undo.
    def Input param p_cod_table       as CHARACTER  format "x(8)"       no-undo.
    def input param p_estabel         as CHARACTER  format "x(3)"       no-undo.
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
           v_num_aux_2 = integer(this-procedure:handle).

    do  v_num_cont = 1 to 4:
        assign v_num_aux   = (random(0,v_num_aux_2) mod 26) + 97
               p_cod_refer = CAPS(p_cod_refer + chr(v_num_aux)).
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
    def Input param p_cod_estab       as CHARACTER format "x(3)"    no-undo.
    def Input param p_cod_refer       as CHARACTER format "x(10)"   no-undo.
    def Input param p_cod_table       as CHARACTER format "x(8)"    no-undo.
    def Input param p_rec_tabela      as RECID     format ">>>>>>9" no-undo.
    def output param p_log_refer_uni  as LOGICAL   format "Sim/N’o" no-undo.
    /************************* Parameter Definition End *************************/
    /************************** Buffer Definition Begin *************************/
    def buffer b_cobr_especial_acr for cobr_especial_acr.
    def buffer b_lote_impl_tit_acr for lote_impl_tit_acr.
    def buffer b_lote_liquidac_acr for lote_liquidac_acr.
    def buffer b_movto_tit_acr     for movto_tit_acr.
    def buffer b_renegoc_acr       for renegoc_acr.
    /*************************** Buffer Definition End **************************/
    /************************* Variable Definition Begin ************************/ 
    def var v_cod_return as CHARACTER format "x(40)" no-undo.
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

PROCEDURE pi-cria-tt-erro:

    DEFINE INPUT PARAMETER p-i-sequen    AS INTEGER   NO-UNDO.
    DEFINE INPUT PARAMETER p-cd-erro     AS INTEGER   NO-UNDO.
    DEFINE INPUT PARAMETER p-mensagem    AS CHARACTER NO-UNDO.
    DEFINE INPUT PARAMETER p-ajuda       AS CHARACTER NO-UNDO.
    
    CREATE tt-erro.
    ASSIGN tt-erro.i-sequen    = p-i-sequen
           tt-erro.cd-erro     = p-cd-erro 
           tt-erro.mensagem    = p-mensagem
           tt-erro.ajuda       = p-ajuda.

    RETURN "OK".

END PROCEDURE.

PROCEDURE pi-mostra-erros:

    FOR EACH tt-erro:
           DISP tt-erro.cd-erro
                 tt-erro.mensagem  FORMAT "x(100)" SKIP
                 tt-erro.ajuda    FORMAT "x(150)" NO-LABEL
                 WITH WIDTH 333 STREAM-IO DOWN FRAME f-erro.
           DOWN WITH FRAME f-erro.             
    END.    
END.

PROCEDURE pi-mostra-titulos-criados:

    FOR EACH tt-tit-criados:
        DISP tt-tit-criados.cod_estab          
             tt-tit-criados.cod_espec_docto   
             tt-tit-criados.cod_ser_docto     
             tt-tit-criados.cod_tit_acr       
             tt-tit-criados.cod_parcela       
             tt-tit-criados.cdn_cliente       
             tt-tit-criados.cod_portador      
             tt-tit-criados.dat_transacao     
             tt-tit-criados.dat_emis_docto    
             tt-tit-criados.dat_vencto_tit_acr
             tt-tit-criados.val_origin_tit_acr
             tt-tit-criados.situacao          
             WITH WIDTH 555 STREAM-IO DOWN FRAME f-titulo.
                                 DOWN WITH FRAME f-titulo.  

    END.

END PROCEDURE. /* pi-mostra-titulos-criados */



