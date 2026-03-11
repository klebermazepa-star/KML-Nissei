
DEF VAR l-erro AS LOGICAL NO-UNDO.

{cdp/cd0666.i}
{utp/ut-glob.i}

{inbo/boin090.i tt-docum-est}       /* Definição TT-DOCUM-EST       */
{inbo/boin366.i tt-rat-docum}       /* Definição TT-RAT-DOCUM       */
{inbo/boin176.i tt-item-doc-est}    /* Definição TT-ITEM-DOC-EST    */
{inbo/boin092.i tt-dupli-apagar}    /* Definição TT-DUPLI-APAGAR    */
{inbo/boin567.i tt-dupli-imp}       /* Definição TT-DUPLI-IMP       */

define temp-table tt-param no-undo
    field destino          as integer
    field arquivo          as char format "x(35)"
    field usuario          as char format "x(12)"
    field data-exec        as date
    field hora-exec        as integer
    field classifica       as integer
    field desc-classifica  as char format "x(40)"
    field r-docum-est      as ROWID.

/* Transfer Definitions */
 
 
def temp-table tt-raw-digita
    field raw-digita as raw.

       
       
def TEMP-TABLE tt-erros no-undo
    field identif-segment as char
    field cd-erro         as integer
    field desc-erro       as char format "x(80)".


//def input parameter raw-param as raw no-undo.
//def input parameter table for tt-raw-digita.

DEF VAR raw-param as raw no-undo.

create tt-param.
//raw-transfer raw-param to tt-param.

INPUT FROM VALUE ("v:/downloads/itens_excluir.csv").

DEFINE TEMP-TABLE tt-notas NO-UNDO
    FIELD estab     AS CHAR
    FIELD nota      AS INT
    FIELD serie     AS CHAR.
    
REPEAT:

    CREATE tt-notas.
    IMPORT DELIMITER ";" tt-notas.
END.
    
    
    
    
    
DEFINE BUFFER b-estabelec FOR ems2mult.estabelec.    

DEF VAR cont AS INT.

output to value ("X:/KML/KLEBER/Notas_exclusao_977.csv").   

FOR EACH tt-notas,
    FIRST estabelec 
        WHERE estabelec.cod-estabel = tt-notas.estab,
    EACH docum-est NO-LOCK
    WHERE docum-est.cod-emitente    = estabelec.cod-emitente
      AND docum-est.nro-docto       = STRING(tt-notas.nota, "9999999")
      AND docum-est.serie-docto     = tt-notas.serie:
      
      
      ASSIGN cont = cont + 1.
      
    FOR EACH item-doc-est OF docum-est NO-LOCK:
        
        FIND FIRST item-uni-estab EXCLUSIVE-LOCK
            WHERE item-uni-estab.it-codigo  = item-doc-est.it-codigo
              AND item-uni-estab.cod-estabel    = docum-est.cod-estabel
              AND item-uni-estab.perm-saldo-neg <> 3 NO-ERROR.
              
        IF AVAIL item-uni-estab THEN
        DO:
           ASSIGN item-uni-estab.perm-saldo-neg = 3. 
        END.
        RELEASE item-uni-estab.
    END.
          

    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-erros.
    EMPTY TEMP-TABLE tt-docum-est.
    
    
    BUFFER-COPY docum-est TO tt-docum-est.
   
   
    run rep/re0402a.p ( input  rowid(docum-est),
                    input  /*tt-param.l-of*/ no,
                    input  /*tt-param.l-saldo*/ yes,
                    input  /*tt-param.l-desatual*/ yes,
                    input  /*tt-param.l-custo-padrao*/ yes,
                    input  /*tt-param.l-desatualiza-ap*/ NO,
                    input  /*tt-param.i-prc-custo*/ 2,
                    input  /*tt-param.l-desatualiza-aca*/ yes,
                    input  /*tt-param.l-desatualiza-wms*/ no,
                    input  /*tt-param.l-desatualiza-draw*/ no,
                    input  /*tt-param.l-desatualiza-cr*/ NO,
                    OUTPUT l-erro,
                    output TABLE tt-erro).       
                    
                    
                    
    IF docum-est.CE-atual = no
    then do:
    
        FOR EACH item-doc-est OF docum-est EXCLUSIVE-LOCK:
            DELETE item-doc-est.
        END.
        FOR EACH rat-docum OF docum-est EXCLUSIVE-LOCK:
            DELETE rat-docum.
        END.
        FOR EACH dupli-imp OF docum-est EXCLUSIVE-LOCK:
            DELETE dupli-imp.
        END.
        EXPORT DELIMITER ";"
                     docum-est.nro-docto
                     docum-est.serie-docto
                     docum-est.cod-emitente
                     docum-est.dt-trans
                     "EXCLUIDA".                           
        DELETE docum-est.        
            

  
    end. /*if not l-erro */
    else do:
        for each tt-erro:
        export delimiter ";"
                         docum-est.nro-docto
                         docum-est.serie-docto
                         docum-est.cod-emitente
                         docum-est.dt-trans
                         "DEU ERRO RE0402".  
        end.
        
        run rep/re0402a.p ( input  rowid(docum-est),
                        input  /*tt-param.l-of*/ no,
                        input  /*tt-param.l-saldo*/ yes,
                        input  /*tt-param.l-desatual*/ yes,
                        input  /*tt-param.l-custo-padrao*/ yes,
                        input  /*tt-param.l-desatualiza-ap*/ NO,
                        input  /*tt-param.i-prc-custo*/ 2,
                        input  /*tt-param.l-desatualiza-aca*/ yes,
                        input  /*tt-param.l-desatualiza-wms*/ no,
                        input  /*tt-param.l-desatualiza-draw*/ no,
                        input  /*tt-param.l-desatualiza-cr*/ NO,
                        OUTPUT l-erro,
                        output TABLE tt-erro).   
                        
        IF docum-est.CE-atual = no
        then do:
        
            FOR EACH item-doc-est OF docum-est EXCLUSIVE-LOCK:
                DELETE item-doc-est.
            END.
            FOR EACH rat-docum OF docum-est EXCLUSIVE-LOCK:
                DELETE rat-docum.
            END.
            FOR EACH dupli-imp OF docum-est EXCLUSIVE-LOCK:
                DELETE dupli-imp.
            END.
            EXPORT DELIMITER ";"
                         docum-est.nro-docto
                         docum-est.serie-docto
                         docum-est.cod-emitente
                         docum-est.dt-trans
                         "EXCLUIDA".                           
            DELETE docum-est. 
  
        end. /*if not l-erro */ 
        ELSE DO:
        
            export delimiter ";"
                             docum-est.nro-docto
                             docum-est.serie-docto
                             docum-est.cod-emitente
                             docum-est.dt-trans
                            "DEU ERRO RE0402 - SEGUNDA TENTATIVA".  
        END.
        
      
     //   return "NOK".
    END.
      
END.


OUTPUT CLOSE.

DISP cont.
