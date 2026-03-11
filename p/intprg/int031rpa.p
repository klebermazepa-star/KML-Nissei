/********************************************************************************
*******************************************************************************/
{include/i-prgvrs.i int031rpa.p 2.06.00.002}  
/****************************************************************************
**
**       Programa: int031rpa.p
**
**       Data....: Junho de 2015.
**
**       Autor...: ResultPro
**
**       Objetivo: Atualiza‡Æo Registros C400 
**
*****************************************************************************/
{cdp/cd9701.i} /* Defini»’o/atribui»ao da variÿvel l-mult-natur-receb -> Usa mœltiplas naturezas no recebimento */

/*DISABLE TRIGGERS FOR LOAD OF dwf-reduc-z.*/
    
define temp-table tt-param
    field destino          as integer
    field arquivo          as char
    field usuario          as char format "x(12)"
    field data-exec        as date
    field hora-exec        as integer 
    field c-programa       as char
    field c-diretorio      as char format "x(100)"
    field c-estab-ini      like item.cod-estabel
    field c-estab-fim      like item.cod-estabel
    field dt-trans-ini     as date format "99/99/9999"
    field dt-trans-fim     as date format "99/99/9999"
    field i-cdn-layout     like clf-import-layout.cdn-layout
    field rs-atualiza      as integer 
    field it-recarga       like item.it-codigo initial "990000"
    field dir-export       as char.

define temp-table tt-tipo-operacao no-undo
    field nat-oper      like natur-oper.nat-operacao
    field cod-model-cfe as   char  format "x(02)".

def temp-table tt-it-doc-fisc no-undo like it-doc-fisc.
def temp-table tt-doc-fiscal no-undo like doc-fiscal
    field vl-despesas  like it-doc-fisc.vl-despes-it
    field vl-pis-st    like doc-fiscal.vl-pis       
    field vl-cofins-st like doc-fiscal.vl-finsocial 
        index tipo-data tipo-nat dt-docto.

def temp-table tt-estabelec no-undo
    field cod-estabel  like estabelec.cod-estabel.
    
def temp-table tt-dwf-cupom-fisc-resum no-undo like dwf-cupom-fisc-resum
    field cod-sit-docto like  dwf-cupom-fisc.cod-sit-doc.

DEF TEMP-TABLE tt-mapa-ecf
    FIELD r-mapa AS ROWID.

def temp-table tt-dwf-eqpto-ecf  no-undo like dwf-eqpto-ecf.
def temp-table tt-dwf-cupom-fisc no-undo like dwf-cupom-fisc.
def temp-table tt-dwf-cupom-fisc-item no-undo like dwf-cupom-fisc-item.
def temp-table tt-dwf-reduc-z no-undo like dwf-reduc-z.
def temp-table tt-dwf-reduc-z-resum-diario no-undo like dwf-reduc-z-resum-diario.
def temp-table tt-dwf-reduc-z-tot-parcial no-undo like dwf-reduc-z-tot-parcial.
def temp-table tt-dwf-reduc-z-tot-parcial-item no-undo like dwf-reduc-z-tot-parcial-item.
def temp-table tt-dwf-cfe  no-undo like dwf-cfe.
def temp-table tt-dwf-cfe-resum  no-undo like dwf-cfe-resum.

def input parameter raw-param as raw no-undo.
def input-output param table for tt-estabelec.
def input-output param table for tt-tipo-operacao.

create tt-param.
raw-transfer raw-param to tt-param. 

def var cSerie              as char no-undo.
def var d-vl-tot-pis        like it-doc-fisc.val-pis      no-undo.
def var d-vl-tot-cofins     like it-doc-fisc.val-cofins   no-undo.
def var d-tot-reduc-pis     like it-doc-fisc.val-pis      no-undo.
def var d-tot-reduc-cofins  like it-doc-fisc.val-cofins   no-undo.
def var d-vl-tot-item       like doc-fiscal.vl-cont-doc   no-undo.
def var c-model-docto       like dwf-reduc-z.cod-model-docto   no-undo.
def var c-model-ecf         like dwf-reduc-z.cod-model-ecf     no-undo.
def var c-model-cf          like dwf-cupom-fisc-item.cod-model-cf no-undo.
def var dt-inic-valid       like dwf-eqpto-ecf.dat-inic-valid  no-undo.
def var c-cod-total         as   char                          no-undo.
def var c-num-totaliz       as   char                          no-undo.
def var c-aliq              as   char                          no-undo.
def var h-acomp             as handle no-undo.  
def var i-empresa-prin      like param-global.empresa-prin.
def var c-acum              as char no-undo.
def var c-mensagem          as char no-undo.
def var c-situacao          as char no-undo.
def var c-tipo-mov          as char format "x(01)".
def var c-tipo-arq          as char.
def var iCodOrig            as integer no-undo. 
def var c-niv-trib-icms     as char  no-undo.
def var i-niv-trib-icms     as integer no-undo.
def var l-sub               as logical    no-undo.
def var i-codigo            as int    no-undo.
def var c-cod-tributac-icms as char   no-undo.

define buffer b-int_ds_mapa_ecf for int_ds_mapa_ecf.
/*define buffer b-natur-oper      for natur-oper. */

FIND FIRST param-global NO-LOCK NO-ERROR.
FIND FIRST tt-param             NO-ERROR.

{include/i-rpvar.i}

{include/i-rpcab.i &STREAM="str-rp"} 

{include/i-rpc255.i &STREAM="str-rp"}

assign  c-programa     = "int031rpa"
        c-versao       = "2.06"
        c-revisao      = ".00.001"
        c-empresa      = param-global.grupo
        c-sistema      = "Obriga‡äes Fiscais"
        c-titulo-relat = "Gera‡Æo SPED FISCAL"
        i-empresa-prin = param-global.empresa-prin.

assign c-acum = c-versao + c-revisao.

{include/i-rpout.i &STREAM="stream str-rp"}

VIEW STREAM str-rp FRAME f-cabec-255.
VIEW STREAM str-rp FRAME f-rodape-255.

run utp/ut-acomp.p persistent set h-acomp. 
       
run pi-inicializar in h-acomp (input c-mensagem).        

empty temp-table tt-dwf-eqpto-ecf.
empty temp-table tt-dwf-cupom-fisc.
empty temp-table tt-dwf-cupom-fisc-item.
empty temp-table tt-dwf-cupom-fisc-resum.
empty temp-table tt-dwf-reduc-z.
empty temp-table tt-dwf-reduc-z-resum-diario. 
empty temp-table tt-dwf-reduc-z-tot-parcial.
empty temp-table tt-dwf-reduc-z-tot-parcial-item.
EMPTY TEMP-TABLE tt-mapa-ecf.

if tt-param.rs-atualiza = 1 then
   assign c-tipo-mov = "I"
          c-tipo-arq = "Inclusao"
          c-situacao = "InclusÆo"
          c-mensagem = "Gerando arquivos fiscais...". 
else
   assign c-tipo-mov = "E"
          c-tipo-arq = "Eliminacao"
          c-situacao = "Elimina‡Æo"
          c-mensagem = "Eliminando arquivos fiscais...".

assign c-model-docto  = "2D"  
       c-model-cf     = "2D"     
       c-model-ecf    = "BEMATECH"
       dt-inic-valid  = today.

if tt-param.rs-atualiza = 1
then do:
/*
put STREAM str-rp "1" skip.
*/
    RUN atualizaModelo59(input tt-param.c-estab-ini,
                         input tt-param.c-estab-FIM,
                         input tt-param.dt-trans-ini,
                         input tt-param.dt-trans-fim). 

    for each tt-estabelec no-lock where
        tt-estabelec.cod-estabel >= tt-param.c-estab-ini and 
        tt-estabelec.cod-estabel <= tt-param.c-estab-fim,
        first estabelec where 
        estabelec.cod-estabel = tt-estabelec.cod-estabel and 
       (estabelec.estado = 'SC' or estabelec.estado = 'SP')
        break by tt-estabelec.cod-estabel:  

        /*
        put STREAM str-rp " Est:" estabelec.cod-estabel " " 
                    tt-param.dt-trans-ini " " tt-param.dt-trans-fim skip.
        */

        bloco_fim_operacao:
        for each int_ds_mapa_ecf no-lock where
            int_ds_mapa_ecf.filial  = estabelec.cod-estabel and
            int_ds_mapa_ecf.data   >= tt-param.dt-trans-ini and  
            int_ds_mapa_ecf.data   <= tt-param.dt-trans-fim and 
            int_ds_mapa_ecf.situacao = "F" /* Finalizado Tutorial */:
    
            /*
            put STREAM str-rp " Est:" estabelec.cod-estabel " " 
                        tt-param.dt-trans-ini " " tt-param.dt-trans-fim skip.
            */
            
            /* verificar qual ‚ o estabelecimento pelo cnpj. No entanto, dever  ser verificado se a Data de Validade do estabelecimento est  em branco, 
               pois existem mais de um estabelecimento cadastrado com o mesmo CNPJ.     
               Valida‡Æo cst_estabelec.dt-fim-operacao <> 31/12/9999 e se est  v lido. 
               Sempre verificar o data fim do per¡odo para buscar o estabelecimento.
            */  
    
            for first cst_estabelec no-lock where
                cst_estabelec.cod_estabel = int_ds_mapa_ecf.filial:
                if int_ds_mapa_ecf.data > cst_estabelec.dt_fim_operacao then
                    next bloco_fim_operacao.
            end.
    
            RUN pi-acompanhar IN h-acomp (input "Mapa Ecf : " + string(int_ds_mapa_ecf.cupom_ini)).  

            assign d-tot-reduc-cofins = 0
                   d-tot-reduc-pis    = 0.
                          
            for each cst_nota_fiscal no-lock where
                cst_nota_fiscal.Impressora  = int_ds_mapa_ecf.Serie_equi    and /* Terminal diferente no mapa 
                cst_nota_fiscal.Indterminal = int_ds_mapa_ecf.Impressora    and */
                cst_nota_fiscal.data_ecf    = int_ds_mapa_ecf.data          and
                cst_nota_fiscal.cod_estabel = estabelec.cod-estabel                  
                /*int(cst_nota_fiscal.cupom_ecf) >= int(int_ds_mapa_ecf.cupom_ini) and 
                int(cst_nota_fiscal.cupom_ecf) <= int(int_ds_mapa_ecf.cupom_fim)*/ ,                          
                first nota-fiscal no-lock where
                nota-fiscal.cod-estabel    = estabelec.cod-estabel and
                nota-fiscal.serie          = cst_nota_fiscal.serie and 
                nota-fiscal.nr-nota-fis    = cst_nota_fiscal.nr_nota_fis:    

                for first it-doc-fisc NO-LOCK where
                    it-doc-fisc.cod-estabel     = estabelec.cod-estabel        and
                    it-doc-fisc.serie           = nota-fiscal.serie            and
                    it-doc-fisc.nr-doc-fis      = nota-fiscal.nr-nota-fis and                                 
                    it-doc-fisc.it-codigo       = tt-param.it-recarga :  /* Item de recarga desconsidera */ end.                                                  
                if avail it-doc-fisc then next.    
                
                RUN pi-acompanhar IN h-acomp (input "Nota Loja : " + string(cst_nota_fiscal.nr_nota_fis)). 
                
                assign d-vl-tot-pis    = 0 
                       d-vl-tot-cofins = 0
                       d-vl-tot-item   = 0. 
    
                for each doc-fiscal no-lock where
                    doc-fiscal.cod-estabel     = nota-fiscal.cod-estabel    and
                    doc-fiscal.serie           = nota-fiscal.serie          and
                    doc-fiscal.nr-doc-fis      = nota-fiscal.nr-nota-fis    and
                    doc-fiscal.tipo-nat        = 2
                    break by doc-fiscal.nr-doc-fis:
                          
                    for first tt-dwf-eqpto-ecf where 
                        tt-dwf-eqpto-ecf.cod-cx-ecf      = int_ds_mapa_ecf.impressora and
                        tt-dwf-eqpto-ecf.cod-estab       = int_ds_mapa_ecf.filial     and 
                        tt-dwf-eqpto-ecf.cod-fabricc-ecf = int_ds_mapa_ecf.serie_equi and
                        tt-dwf-eqpto-ecf.cod-model-docto = c-model-docto              and
                        tt-dwf-eqpto-ecf.cod-model-ecf   = c-model-ecf                and
                        tt-dwf-eqpto-ecf.dat-inic-valid  = dt-inic-valid              and
                        tt-dwf-eqpto-ecf.dat-fim-valid   = ?: end.
            
                    if not avail tt-dwf-eqpto-ecf then do:
                        create tt-dwf-eqpto-ecf.
                        assign tt-dwf-eqpto-ecf.cod-cx-ecf      = int_ds_mapa_ecf.impressora 
                               tt-dwf-eqpto-ecf.cod-estab       = int_ds_mapa_ecf.filial     
                               tt-dwf-eqpto-ecf.cod-fabricc-ecf = int_ds_mapa_ecf.serie_equi 
                               tt-dwf-eqpto-ecf.cod-model-docto = c-model-docto                       
                               tt-dwf-eqpto-ecf.cod-model-ecf   = c-model-ecf       
                               tt-dwf-eqpto-ecf.dat-inic-valid  = dt-inic-valid
                               tt-dwf-eqpto-ecf.dat-fim-valid   = ?
                               tt-dwf-eqpto-ecf.dat-reduc-z     = int_ds_mapa_ecf.data.
                    end.
                    
                    for each it-doc-fisc of doc-fiscal no-lock where it-doc-fisc.vl-tot-item > 0,
                        first item no-lock where
                        item.it-codigo  = it-doc-fisc.it-codigo,
                        first natur-oper no-lock where
                        natur-oper.nat-operacao = it-doc-fisc.nat-operacao : 
                                  
                        if doc-fiscal.ind-sit-doc <> 2 /* Cancelados */
                        then do:
                           assign d-tot-reduc-cofins = d-tot-reduc-cofins + it-doc-fisc.val-cofins
                                  d-tot-reduc-pis    = d-tot-reduc-pis    + it-doc-fisc.val-pis
                                  d-vl-tot-pis       = d-vl-tot-pis       + it-doc-fisc.val-pis
                                  d-vl-tot-cofins    = d-vl-tot-cofins    + it-doc-fisc.val-cofins
                                  d-vl-tot-item      = d-vl-tot-item      + it-doc-fisc.vl-tot-item.                                               
                        end.
                           
                        for first it-nota-fisc  no-lock where
                          /*it-nota-fisc.nr-seq-fat    = it-doc-fisc.nr-seq-doc and */
                            it-nota-fisc.cod-estabel    = it-doc-fisc.cod-estabel   and 
                            it-nota-fisc.serie          = it-doc-fisc.serie         and
                            it-nota-fisc.nr-nota-fis = it-doc-fisc.nr-doc-fis       and 
                            it-nota-fisc.it-codigo   = it-doc-fisc.it-codigo        and 
                            it-nota-fisc.nat-operacao = it-doc-fisc.nat-operacao :
    
                            assign i-niv-trib-icms = 0
                                   c-niv-trib-icms = "".

                            run ftp/ft0515a.p (input  ROWID(it-nota-fisc), 
                                               OUTPUT i-niv-trib-icms,      
                                               OUTPUT l-sub).

                            assign iCodOrig = item.codigo-orig. /* Verificar se possui o campo na it-doc-fisc */

                           /* CST -> Codigo da Situacao Tributaria (conforme DANFE): Codigo Origem + Nivel Tributacao ICMS */
                           assign i-niv-trib-icms = int(string(iCodOrig) + string(i-niv-trib-icms, "99"))
                                  c-niv-trib-icms = string(i-niv-trib-icms,"999").

                            if int(substring(c-niv-trib-icms,2,2)) >= 0 then
                                assign c-niv-trib-icms = substring(c-niv-trib-icms,2,2). 
                            else
                                assign c-niv-trib-icms = "00".
                        end. /* first it-not-fisc */
                          
                        if it-doc-fisc.quantidade > 0
                        then do:  
                            for first tt-dwf-cupom-fisc-item where
                                      tt-dwf-cupom-fisc-item.cod-cx-ecf      = int_ds_mapa_ecf.impressora and  
                                      tt-dwf-cupom-fisc-item.cod-estab       = int_ds_mapa_ecf.filial     and  
                                      tt-dwf-cupom-fisc-item.cod-fabricc-ecf = int_ds_mapa_ecf.serie_equi and 
                                      tt-dwf-cupom-fisc-item.cod-model-docto = c-model-docto              and
                                      tt-dwf-cupom-fisc-item.cod-model-ecf   = c-model-ecf                and 
                                      tt-dwf-cupom-fisc-item.cod-model-cf    = c-model-cf                 and 
                                      tt-dwf-cupom-fisc-item.dat-inic-valid  = dt-inic-valid              and 
                                      tt-dwf-cupom-fisc-item.dat-reduc-z     = int_ds_mapa_ecf.data       and
                                      tt-dwf-cupom-fisc-item.cod-docto       = cst_nota_fiscal.cupom_ecf  and
                                      tt-dwf-cupom-fisc-item.num-seq-item    = it-doc-fisc.nr-seq-doc: end. 
                            if not avail tt-dwf-cupom-fisc-item then do:
                                 create tt-dwf-cupom-fisc-item.                                               
                                 assign tt-dwf-cupom-fisc-item.cod-cx-ecf      = int_ds_mapa_ecf.impressora 
                                        tt-dwf-cupom-fisc-item.cod-estab       = int_ds_mapa_ecf.filial     
                                        tt-dwf-cupom-fisc-item.cod-fabricc-ecf = int_ds_mapa_ecf.serie_equi 
                                        tt-dwf-cupom-fisc-item.cod-model-docto = c-model-docto                       
                                        tt-dwf-cupom-fisc-item.cod-model-ecf   = c-model-ecf 
                                        tt-dwf-cupom-fisc-item.cod-model-cf    = c-model-cf                   
                                        tt-dwf-cupom-fisc-item.dat-reduc-z     = int_ds_mapa_ecf.data  
                                        tt-dwf-cupom-fisc-item.dat-inic-valid  = dt-inic-valid                    
                                        tt-dwf-cupom-fisc-item.cod-sit-docto   = string(doc-fiscal.ind-sit-doc,"99")    
                                        tt-dwf-cupom-fisc-item.cod-docto       = cst_nota_fiscal.cupom_ecf
                                        tt-dwf-cupom-fisc-item.num-seq-item    = it-doc-fisc.nr-seq-doc
                                        tt-dwf-cupom-fisc-item.cod-item        = it-doc-fisc.it-codigo
                                        tt-dwf-cupom-fisc-item.cod-sit-tributar-icms = c-niv-trib-icms
                                        tt-dwf-cupom-fisc-item.cod-unid-medid  = /*ITEM.un*/ it-doc-fisc.un        
                                        tt-dwf-cupom-fisc-item.cod-cfop        = natur-oper.cod-cfop
                                        tt-dwf-cupom-fisc-item.val-aliq-icms   = if it-doc-fisc.vl-icms-it > 0 
                                                                                 then it-doc-fisc.aliquota-icm else 0
                                        tt-dwf-cupom-fisc-item.val-item        = it-doc-fisc.vl-tot-item
                                        tt-dwf-cupom-fisc-item.val-tot-cofins  = it-doc-fisc.val-cofins    
                                        tt-dwf-cupom-fisc-item.val-tot-pis     = it-doc-fisc.val-pis.
    
                                 if doc-fiscal.ind-sit-doc = 2 then
                                    assign tt-dwf-cupom-fisc-item.qtd-cancdo = it-doc-fisc.quantidade.
                                 else
                                    assign tt-dwf-cupom-fisc-item.qtd-item   = it-doc-fisc.quantidade.  
                            end.
                        end. /* it-doc-fisc.quantidada < 0 */
                        
                        if doc-fiscal.ind-sit-doc <> 2 /* Cancelado */ 
                        then do:
                           for first tt-dwf-cupom-fisc-resum where 
                                     tt-dwf-cupom-fisc-resum.cod-estab       = int_ds_mapa_ecf.filial     and
                                     tt-dwf-cupom-fisc-resum.cod-model-docto = c-model-docto              and
                                     tt-dwf-cupom-fisc-resum.cod-model-ecf   = c-model-ecf                and
                                     tt-dwf-cupom-fisc-resum.cod-fabricc-ecf = int_ds_mapa_ecf.serie_equi and
                                     tt-dwf-cupom-fisc-resum.cod-cx-ecf      = int_ds_mapa_ecf.impressora and
                                     tt-dwf-cupom-fisc-resum.dat-inic-valid  = dt-inic-valid              and 
                                     tt-dwf-cupom-fisc-resum.dat-reduc-z     = int_ds_mapa_ecf.data       and 
                                     tt-dwf-cupom-fisc-resum.cod-sit-tributar-icms = c-niv-trib-icms      and  
                                  /* tt-dwf-cupom-fisc-resum.cod-sit-docto   = string(doc-fiscal.ind-sit-doc,"99") and */
                                     tt-dwf-cupom-fisc-resum.cod-cfop        = natur-oper.cod-cfop        and
                                     tt-dwf-cupom-fisc-resum.val-aliq-icms   = if it-doc-fisc.vl-icms-it > 0 
                                                                              then it-doc-fisc.aliquota-icm else 0    
                                     /*tt-dwf-cupom-fisc-resum.dat-fim-valid = ?*/: end.
                           if not avail tt-dwf-cupom-fisc-resum  then do:
                               create tt-dwf-cupom-fisc-resum.
                               assign tt-dwf-cupom-fisc-resum.cod-cx-ecf       = int_ds_mapa_ecf.impressora             
                                      tt-dwf-cupom-fisc-resum.cod-estab        = int_ds_mapa_ecf.filial               
                                      tt-dwf-cupom-fisc-resum.cod-fabricc-ecf  = int_ds_mapa_ecf.serie_equi           
                                      tt-dwf-cupom-fisc-resum.cod-model-docto  = c-model-docto                                 
                                      tt-dwf-cupom-fisc-resum.cod-model-ecf    = c-model-ecf                           
                                      tt-dwf-cupom-fisc-resum.dat-reduc-z      = int_ds_mapa_ecf.data 
                                      tt-dwf-cupom-fisc-resum.dat-inic-valid   = dt-inic-valid                    
                                      tt-dwf-cupom-fisc-resum.cod-sit-docto    = string(doc-fiscal.ind-sit-doc,"99")
                                      tt-dwf-cupom-fisc-resum.cod-cfop         = natur-oper.cod-cfop        
                                      tt-dwf-cupom-fisc-resum.cod-sit-tributar = c-niv-trib-icms
                                      tt-dwf-cupom-fisc-resum.val-aliq-icms    = if it-doc-fisc.vl-icms-it > 0 then it-doc-fisc.aliquota-icm else 0
                                      tt-dwf-cupom-fisc-resum.val-base-icms    = if it-doc-fisc.vl-icms-it > 0 then it-doc-fisc.vl-bicms-it else 0
                                      tt-dwf-cupom-fisc-resum.val-icms         = it-doc-fisc.vl-icms-it
                                      tt-dwf-cupom-fisc-resum.val-docto        = it-doc-fisc.vl-tot-item.
                           end.
                           else do:
                               assign tt-dwf-cupom-fisc-resum.val-base-icms    = tt-dwf-cupom-fisc-resum.val-base-icms  + (IF it-doc-fisc.vl-icms-it > 0 THEN it-doc-fisc.vl-bicms-it ELSE 0 )     
                                      tt-dwf-cupom-fisc-resum.val-icms         = tt-dwf-cupom-fisc-resum.val-icms       + it-doc-fisc.vl-icms-it        
                                      tt-dwf-cupom-fisc-resum.val-docto        = tt-dwf-cupom-fisc-resum.val-docto      + it-doc-fisc.vl-tot-item.  
                           end.
                           
                           for first tt-dwf-reduc-z-resum-diario where 
                               tt-dwf-reduc-z-resum-diario.cod-cx-ecf            = int_ds_mapa_ecf.impressora and  
                               tt-dwf-reduc-z-resum-diario.cod-estab             = int_ds_mapa_ecf.filial     and
                               tt-dwf-reduc-z-resum-diario.cod-fabricc-ecf       = int_ds_mapa_ecf.serie_equi and
                               tt-dwf-reduc-z-resum-diario.cod-model-docto       = c-model-docto              and
                               tt-dwf-reduc-z-resum-diario.cod-model-ecf         = c-model-ecf                and
                               tt-dwf-reduc-z-resum-diario.dat-inic-valid        = dt-inic-valid              and 
                               tt-dwf-reduc-z-resum-diario.dat-reduc-z           = int_ds_mapa_ecf.data       and
                               tt-dwf-reduc-z-resum-diario.cod-sit-tributar-icms = c-niv-trib-icms            and
                               tt-dwf-reduc-z-resum-diario.cod-cfop              = natur-oper.cod-cfop        and
                               tt-dwf-reduc-z-resum-diario.val-aliq-icms         = if it-doc-fisc.vl-icms-it > 0 
                                                                                   then it-doc-fisc.aliquota-icm else 0: end.
                           if not avail tt-dwf-reduc-z-resum-diario then do:

                              create tt-dwf-reduc-z-resum-diario.
                              assign tt-dwf-reduc-z-resum-diario.cod-cx-ecf            = int_ds_mapa_ecf.impressora 
                                     tt-dwf-reduc-z-resum-diario.cod-estab             = int_ds_mapa_ecf.filial     
                                     tt-dwf-reduc-z-resum-diario.cod-fabricc-ecf       = int_ds_mapa_ecf.serie_equi  
                                     tt-dwf-reduc-z-resum-diario.cod-model-docto       = c-model-docto              
                                     tt-dwf-reduc-z-resum-diario.cod-model-ecf         = c-model-ecf   
                                     tt-dwf-reduc-z-resum-diario.dat-inic-valid        = dt-inic-valid              
                                     tt-dwf-reduc-z-resum-diario.dat-reduc-z           = int_ds_mapa_ecf.data       
                                     tt-dwf-reduc-z-resum-diario.cod-sit-tributar-icms = c-niv-trib-icms            
                                     tt-dwf-reduc-z-resum-diario.cod-cfop              = natur-oper.cod-cfop          
                                     tt-dwf-reduc-z-resum-diario.val-aliq-icms         = IF it-doc-fisc.vl-icms-it > 0 THEN  it-doc-fisc.aliquota-icm ELSE 0
                                     tt-dwf-reduc-z-resum-diario.val-acum-operac       = it-doc-fisc.vl-tot-item  
                                     tt-dwf-reduc-z-resum-diario.val-aliq-iss          = it-doc-fisc.aliquota-iss
                                     tt-dwf-reduc-z-resum-diario.val-base-calc-icms    = IF it-doc-fisc.vl-icms-it > 0 THEN  it-doc-fisc.vl-bicms-it ELSE 0
                                     tt-dwf-reduc-z-resum-diario.val-base-calc-iss     = it-doc-fisc.vl-biss-it  
                                     tt-dwf-reduc-z-resum-diario.val-icms              = it-doc-fisc.vl-icms-it  
                                     tt-dwf-reduc-z-resum-diario.val-iss               = it-doc-fisc.vl-iss-it.   
                           
                           end.
                           else do:
                               assign tt-dwf-reduc-z-resum-diario.val-acum-operac       = tt-dwf-reduc-z-resum-diario.val-acum-operac    + it-doc-fisc.vl-tot-item 
                                      tt-dwf-reduc-z-resum-diario.val-aliq-iss          = tt-dwf-reduc-z-resum-diario.val-aliq-iss       + it-doc-fisc.aliquota-iss
                                      tt-dwf-reduc-z-resum-diario.val-base-calc-icms    = tt-dwf-reduc-z-resum-diario.val-base-calc-icms + (IF it-doc-fisc.vl-icms-it > 0 THEN  it-doc-fisc.vl-bicms-it ELSE 0)
                                      tt-dwf-reduc-z-resum-diario.val-base-calc-iss     = tt-dwf-reduc-z-resum-diario.val-base-calc-iss  + it-doc-fisc.vl-biss-it  
                                      tt-dwf-reduc-z-resum-diario.val-icms              = tt-dwf-reduc-z-resum-diario.val-icms           + it-doc-fisc.vl-icms-it   
                                      tt-dwf-reduc-z-resum-diario.val-iss               = tt-dwf-reduc-z-resum-diario.val-iss            + it-doc-fisc.vl-iss-it.
                           end.
                        end. /*doc-fiscal.ind-sit-doc <> 2 /* Cancelado */ */
                               
                        /**** totais parciais conforme as aliquotas de ICMS */
                        if doc-fiscal.ind-sit-doc <> 2 /* Cancelados */ then do:
                            assign c-aliq = "".
                             
                            if /*it-doc-fisc.cd-trib-icm  = 1 and*/  /*Tributado**/
                               it-doc-fisc.aliquota-icm > 0 and 
                               it-doc-fisc.vl-bicms-it > 0 /* and
                               it-doc-fisc.vl-icms-it > 0*/ then do:
                                       
                               assign c-aliq = string(round(It-doc-fisc.aliquota-icm,2)).
    
                               if index(c-aliq,",") > 0 then 
                                 assign c-cod-total = "T" + replace(string(It-doc-fisc.aliquota-icm),",",""). 
                               else
                                 assign c-cod-total = "T" + c-aliq + "00".
    
                               RUN pi-tot-parcial (input c-cod-total , 
                                                   input 1).                                                                       
                            end.
                            else if /*it-doc-fisc.vl-icmsub-it > 0*/ it-doc-fisc.cd-trib-icm  = 3 /*Substitui‡Æo Tribut ria***/ then do:
                                 assign c-cod-total = "F1".
                                 RUN pi-tot-parcial (input c-cod-total , 
                                                     input 0).
                            end.
                            else IF it-doc-fisc.cd-trib-icm  = 2 and  /**ISENto*/
                                 it-doc-fisc.aliquota-icm = 0   
                            then do:
                                  assign c-cod-total = "I1".
                                  RUN pi-tot-parcial (input c-cod-total , 
                                                      input 0).
                            end.                                                                                 
                            else if avail it-nota-fisc and 
                                 it-doc-fisc.dec-1 > 0
                            then do:
                                   assign c-cod-total = "DT".
                                   RUN pi-tot-parcial (input c-cod-total , 
                                                       input 0).  
                            end.
                            else do:
                               assign c-aliq = string(round(It-doc-fisc.aliquota-icm,2)).
                               assign c-cod-total = "N1".   
                               RUN pi-tot-parcial (input c-cod-total , 
                                                   input 0).
                            end.
                        end. /*doc-fiscal.ind-sit-doc <> 2 /* Cancelados */*/
                        else do:                                    
                            assign c-cod-total = "Can-T".
                            RUN pi-tot-parcial (input c-cod-total , 
                                                input 0).
                        end.
                    end. /* it-doc-fisc */
                                                           
                    if last (doc-fiscal.nr-doc-fis) 
                    then do:
                        
                        for first tt-dwf-cupom-fisc where
                            tt-dwf-cupom-fisc.cod-cx-ecf      = int_ds_mapa_ecf.impressora and
                            tt-dwf-cupom-fisc.cod-estab       = int_ds_mapa_ecf.filial     and
                            tt-dwf-cupom-fisc.cod-fabricc-ecf = int_ds_mapa_ecf.serie_equi and
                            tt-dwf-cupom-fisc.cod-model-docto = c-model-docto              and
                            tt-dwf-cupom-fisc.cod-model-ecf   = c-model-ecf                and
                            tt-dwf-cupom-fisc.dat-inic-valid  = dt-inic-valid              and 
                            tt-dwf-cupom-fisc.dat-reduc-z     = int_ds_mapa_ecf.data       and
                            tt-dwf-cupom-fisc.cod-docto       = cst_nota_fiscal.cupom_ecf: end.
                        if not avail tt-dwf-cupom-fisc then do:
                             create tt-dwf-cupom-fisc.                                               
                             assign tt-dwf-cupom-fisc.cod-cx-ecf      = int_ds_mapa_ecf.impressora 
                                    tt-dwf-cupom-fisc.cod-estab       = int_ds_mapa_ecf.filial     
                                    tt-dwf-cupom-fisc.cod-fabricc-ecf = int_ds_mapa_ecf.serie_equi 
                                    tt-dwf-cupom-fisc.cod-model-docto = c-model-docto                       
                                    tt-dwf-cupom-fisc.cod-model-ecf   = c-model-ecf
                                    tt-dwf-cupom-fisc.cod-model-cf    = c-model-cf                  
                                    tt-dwf-cupom-fisc.dat-reduc-z     = int_ds_mapa_ecf.data
                                    tt-dwf-cupom-fisc.dat-inic-valid  = dt-inic-valid        
                                    tt-dwf-cupom-fisc.cod-sit-docto   = string(doc-fiscal.ind-sit-doc,"99")    
                                    tt-dwf-cupom-fisc.cod-docto       = cst_nota_fiscal.cupom_ecf
                                    tt-dwf-cupom-fisc.dat-emis-docto  = doc-fiscal.dt-emis-doc
                                    tt-dwf-cupom-fisc.val-docto       = d-vl-tot-item
                                    tt-dwf-cupom-fisc.val-tot-cofins  = d-vl-tot-cofins
                                    tt-dwf-cupom-fisc.val-tot-pis     = d-vl-tot-pis.    
                        end.
                    end.   /* last-of (doc-fiscal) */
                end. /* doc-fiscal */
            end. /* cst_nota_fiscal */
              
            for first tt-dwf-reduc-z where 
                tt-dwf-reduc-z.cod-cx-ecf      = int_ds_mapa_ecf.impressora and
                tt-dwf-reduc-z.cod-estab       = int_ds_mapa_ecf.filial     and
                tt-dwf-reduc-z.cod-fabricc-ecf = int_ds_mapa_ecf.serie_equi and
                tt-dwf-reduc-z.cod-model-docto = c-model-docto              and
                tt-dwf-reduc-z.cod-model-ecf   = c-model-ecf                and
                tt-dwf-reduc-z.dat-inic-valid  = dt-inic-valid              and  
                tt-dwf-reduc-z.dat-reduc-z     = int_ds_mapa_ecf.data: end.
            if not avail tt-dwf-reduc-z  then do:
               create tt-dwf-reduc-z.                                               
               assign tt-dwf-reduc-z.cod-cx-ecf           = int_ds_mapa_ecf.impressora 
                      tt-dwf-reduc-z.cod-estab            = int_ds_mapa_ecf.filial     
                      tt-dwf-reduc-z.cod-fabricc-ecf      = int_ds_mapa_ecf.serie_equi 
                      tt-dwf-reduc-z.cod-model-docto      = c-model-docto                       
                      tt-dwf-reduc-z.cod-model-ecf        = c-model-ecf                 
                      tt-dwf-reduc-z.dat-reduc-z          = int_ds_mapa_ecf.data
                      tt-dwf-reduc-z.dat-inic-valid       = dt-inic-valid    
                      tt-dwf-reduc-z.val-tot-cofins       = d-tot-reduc-cofins
                      tt-dwf-reduc-z.val-tot-pis          = d-tot-reduc-pis
                      tt-dwf-reduc-z.num-cont-ult-docto   = int(int_ds_mapa_ecf.cupom_ini)
                      tt-dwf-reduc-z.num-reduc-z          = int(int_ds_mapa_ecf.cont_reduc)
                      tt-dwf-reduc-z.num-reinicio-operac  = INT(int_ds_mapa_ecf.CRO)
                      tt-dwf-reduc-z.val-grande-tot-final = int_ds_mapa_ecf.gt_final
                      tt-dwf-reduc-z.val-vda-bruta        = int_ds_mapa_ecf.valor_tota.
            end.
                               
            /*for first b-int_ds_mapa_ecf where
                rowid(b-int_ds_mapa_ecf) = rowid(int_ds_mapa_ecf) :
                assign b-int_ds_mapa_ecf.situacao = "I". /* INTEGRADO */
            end.*/

            CREATE tt-mapa-ecf.
            ASSIGN tt-mapa-ecf.r-mapa = ROWID(int_ds_mapa_ecf).
            
            /*release b-int_ds_mapa_ecf.*/               
        end. /* int_ds_mapa_ecf */

        /*Modelo 59**/
        if estabelec.estado <> 'SP' then next.
 
        for each doc-fiscal no-lock where 
            doc-fiscal.dt-docto >= tt-param.dt-trans-ini    and  
            doc-fiscal.dt-docto <= tt-param.dt-trans-fim    and  
            doc-fiscal.cod-estabel = estabelec.cod-estabel  and
            doc-fiscal.tipo-nat = 2:

           for each it-doc-fisc of doc-fiscal no-lock:
              if (substr(doc-fiscal.cod-chave-aces-nf-eletro,21,2) = '59' or trim(substring(doc-fiscal.char-2,175,2)) = '59'
              /* OR SUBSTR(doc-fiscal.cod-chave-aces-nf-eletro,21,2) = '65' OR TRIM(SUBstring(doc-fiscal.char-2,175,2)) = '65'*/ ) and 
                  estabelec.estado = 'SP' and 
                  doc-fiscal.dt-docto >= 10/01/2016 
              then do:
                  if Doc-fiscal.ind-sit-doc = 1 then run GravaInfModelo59.
              end.
           end.
        end.
        
    end. /* tt-estabelec */
    
end. /* InclusÆo de Registros */

if tt-param.rs-atualiza = 1 /* InclusÆo */
then do:

    for each tt-dwf-eqpto-ecf: 
        
         RUN pi-acompanhar IN h-acomp (input "Eqpto : " + string(tt-dwf-eqpto-ecf.cod-cx-ecf)).

         for first dwf-eqpto-ecf where
             dwf-eqpto-ecf.cod-cx-ecf      = tt-dwf-eqpto-ecf.cod-cx-ecf        and 
             dwf-eqpto-ecf.cod-estab       = tt-dwf-eqpto-ecf.cod-estab         and 
             dwf-eqpto-ecf.cod-fabricc-ecf = tt-dwf-eqpto-ecf.cod-fabricc-ecf   and
             dwf-eqpto-ecf.cod-model-docto = tt-dwf-eqpto-ecf.cod-model-docto   and
             dwf-eqpto-ecf.cod-model-ecf   = tt-dwf-eqpto-ecf.cod-model-ecf   /*and                   
             dwf-eqpto-ecf.dat-inic-valid  = tt-dwf-eqpto-ecf.dat-inic-valid*/: end.
         
         if not avail dwf-eqpto-ecf then do:
            create dwf-eqpto-ecf.
            buffer-copy tt-dwf-eqpto-ecf to dwf-eqpto-ecf.
         end. 
    end. /* tt-dwf-eqpto-ecf */

    for each tt-dwf-cupom-fisc-item: 
     
        RUN pi-acompanhar IN h-acomp (input "Cupom Item : " + string(tt-dwf-cupom-fisc-item.cod-docto)).

        for first dwf-cupom-fisc-item where
            dwf-cupom-fisc-item.cod-cx-ecf      = tt-dwf-cupom-fisc-item.cod-cx-ecf      and 
            dwf-cupom-fisc-item.cod-estab       = tt-dwf-cupom-fisc-item.cod-estab       and 
            dwf-cupom-fisc-item.cod-fabricc-ecf = tt-dwf-cupom-fisc-item.cod-fabricc-ecf and
            dwf-cupom-fisc-item.cod-model-docto = tt-dwf-cupom-fisc-item.cod-model-docto and
            dwf-cupom-fisc-item.cod-model-ecf   = tt-dwf-cupom-fisc-item.cod-model-ecf   and
            dwf-cupom-fisc-item.cod-model-cf    = tt-dwf-cupom-fisc-item.cod-model-cf    and
            dwf-cupom-fisc-item.dat-inic-valid  = tt-dwf-cupom-fisc-item.dat-inic-valid  and 
            dwf-cupom-fisc-item.dat-reduc-z     = tt-dwf-cupom-fisc-item.dat-reduc-z     and 
          /*dwf-cupom-fisc-item.cod-sit-docto   = tt-dwf-cupom-fisc-item.cod-sit-docto   and*/
            dwf-cupom-fisc-item.cod-docto       = tt-dwf-cupom-fisc-item.cod-docto       and 
            dwf-cupom-fisc-item.num-seq-item    = tt-dwf-cupom-fisc-item.num-seq-item:   end.
           
        if not avail dwf-cupom-fisc-item then do:
           /*MESSAGE 8 VIEW-as ALERT-BOX INFO BUTtoNS OK.*/
           create dwf-cupom-fisc-item. 
           buffer-copy tt-dwf-cupom-fisc-item to dwf-cupom-fisc-item.
        end. 
        else do:
           assign dwf-cupom-fisc-item.cod-item              = tt-dwf-cupom-fisc-item.cod-item             
                  dwf-cupom-fisc-item.cod-sit-tributar-icms = tt-dwf-cupom-fisc-item.cod-sit-tributar-icms
                  dwf-cupom-fisc-item.cod-unid-medid        = tt-dwf-cupom-fisc-item.cod-unid-medid       
                  dwf-cupom-fisc-item.cod-cfop              = tt-dwf-cupom-fisc-item.cod-cfop             
                  dwf-cupom-fisc-item.val-aliq-icms         = tt-dwf-cupom-fisc-item.val-aliq-icms        
                  dwf-cupom-fisc-item.val-item              = tt-dwf-cupom-fisc-item.val-item             
                  dwf-cupom-fisc-item.val-tot-cofins        = tt-dwf-cupom-fisc-item.val-tot-cofins       
                  dwf-cupom-fisc-item.val-tot-pis           = tt-dwf-cupom-fisc-item.val-tot-pis 
                  dwf-cupom-fisc-item.qtd-cancdo            = tt-dwf-cupom-fisc-item.qtd-cancdo 
                  dwf-cupom-fisc-item.qtd-item              = tt-dwf-cupom-fisc-item.qtd-item. 
        end.
    end. /* tt-dwf-cupom-fisc-item */

    for each tt-dwf-cupom-fisc-resum where
             tt-dwf-cupom-fisc-resum.cod-sit-docto <> "02" :
        
        RUN pi-acompanhar IN h-acomp (input "Resumo : " + string(tt-dwf-cupom-fisc-resum.dat-reduc-z)).
                                          
        for first dwf-cupom-fisc-resum where
            dwf-cupom-fisc-resum.cod-estab       = tt-dwf-cupom-fisc-resum.cod-estab       and 
            dwf-cupom-fisc-resum.cod-model-docto = tt-dwf-cupom-fisc-resum.cod-model-docto and
            dwf-cupom-fisc-resum.cod-model-ecf   = tt-dwf-cupom-fisc-resum.cod-model-ecf   and
            dwf-cupom-fisc-resum.cod-fabricc-ecf = tt-dwf-cupom-fisc-resum.cod-fabricc-ecf and
            dwf-cupom-fisc-resum.cod-cx-ecf      = tt-dwf-cupom-fisc-resum.cod-cx-ecf      and
            dwf-cupom-fisc-resum.dat-inic-valid  = tt-dwf-cupom-fisc-resum.dat-inic-valid  and
            dwf-cupom-fisc-resum.dat-reduc-z     = tt-dwf-cupom-fisc-resum.dat-reduc-z     and 
            dwf-cupom-fisc-resum.cod-sit-tributar-icms = tt-dwf-cupom-fisc-resum.cod-sit-tributar-icms  and 
            dwf-cupom-fisc-resum.cod-cfop        = tt-dwf-cupom-fisc-resum.cod-cfop        and   
            dwf-cupom-fisc-resum.val-aliq-icms   = tt-dwf-cupom-fisc-resum.val-aliq-icms   and
            tt-dwf-cupom-fisc-resum.dat-fim-valid = ?: end.
        
        if not avail dwf-cupom-fisc-resum  then do:
           create dwf-cupom-fisc-resum.
           buffer-copy tt-dwf-cupom-fisc-resum  except cod-sit-docto to dwf-cupom-fisc-resum.
        end.
        else do:
           assign dwf-cupom-fisc-resum.val-base-icms = tt-dwf-cupom-fisc-resum.val-base-icms    
                  dwf-cupom-fisc-resum.val-icms      = tt-dwf-cupom-fisc-resum.val-icms          
                  dwf-cupom-fisc-resum.val-docto     = tt-dwf-cupom-fisc-resum.val-docto.      
        end.

    end.
   
    for each tt-dwf-reduc-z-resum-diario:
         
         RUN pi-acompanhar IN h-acomp (input "Resumo Di rio : " + string(tt-dwf-reduc-z-resum-diario.dat-reduc-z)).

         for first dwf-reduc-z-resum-diario where
             dwf-reduc-z-resum-diario.cod-cx-ecf            = tt-dwf-reduc-z-resum-diario.cod-cx-ecf            and 
             dwf-reduc-z-resum-diario.cod-estab             = tt-dwf-reduc-z-resum-diario.cod-estab             and
             dwf-reduc-z-resum-diario.cod-fabricc-ecf       = tt-dwf-reduc-z-resum-diario.cod-fabricc-ecf       and
             dwf-reduc-z-resum-diario.cod-model-docto       = tt-dwf-reduc-z-resum-diario.cod-model-docto       and
             dwf-reduc-z-resum-diario.cod-model-ecf         = tt-dwf-reduc-z-resum-diario.cod-model-ecf         and
             dwf-reduc-z-resum-diario.dat-inic-valid        = tt-dwf-reduc-z-resum-diario.dat-inic-valid        and 
             dwf-reduc-z-resum-diario.dat-reduc-z           = tt-dwf-reduc-z-resum-diario.dat-reduc-z           and
             dwf-reduc-z-resum-diario.cod-sit-tributar-icms = tt-dwf-reduc-z-resum-diario.cod-sit-tributar-icms and
             dwf-reduc-z-resum-diario.cod-cfop              = tt-dwf-reduc-z-resum-diario.cod-cfop              and 
             dwf-reduc-z-resum-diario.val-aliq-icms         = tt-dwf-reduc-z-resum-diario.val-aliq-icms:        end.

         if not avail dwf-reduc-z-resum-diario then do:
            create dwf-reduc-z-resum-diario.
            buffer-copy tt-dwf-reduc-z-resum-diario to dwf-reduc-z-resum-diario.
         end.
         else do:
            assign dwf-reduc-z-resum-diario.val-acum-operac     = tt-dwf-reduc-z-resum-diario.val-acum-operac    
                   dwf-reduc-z-resum-diario.val-aliq-iss        = tt-dwf-reduc-z-resum-diario.val-aliq-iss       
                   dwf-reduc-z-resum-diario.val-base-calc-icms  = tt-dwf-reduc-z-resum-diario.val-base-calc-icms 
                   dwf-reduc-z-resum-diario.val-base-calc-iss   = tt-dwf-reduc-z-resum-diario.val-base-calc-iss  
                   dwf-reduc-z-resum-diario.val-icms            = tt-dwf-reduc-z-resum-diario.val-icms           
                   dwf-reduc-z-resum-diario.val-iss             = tt-dwf-reduc-z-resum-diario.val-iss.   
         end.
    end. /* tt-dwf-reduc-z-resum-diario */
    
    for each tt-dwf-reduc-z-tot-parcial:
           
         RUN pi-acompanhar IN h-acomp (input "total Parcial: " + string(tt-dwf-reduc-z-tot-parcial.dat-reduc-z)).
       
         for first dwf-reduc-z-tot-parcial where 
             dwf-reduc-z-tot-parcial.cod-cx-ecf          = tt-dwf-reduc-z-tot-parcial.cod-cx-ecf          and  
             dwf-reduc-z-tot-parcial.cod-estab           = tt-dwf-reduc-z-tot-parcial.cod-estab           and  
             dwf-reduc-z-tot-parcial.cod-fabricc-ecf     = tt-dwf-reduc-z-tot-parcial.cod-fabricc-ecf     and  
             dwf-reduc-z-tot-parcial.cod-model-docto     = tt-dwf-reduc-z-tot-parcial.cod-model-docto     and  
             dwf-reduc-z-tot-parcial.cod-model-ecf       = tt-dwf-reduc-z-tot-parcial.cod-model-ecf       and  
             dwf-reduc-z-tot-parcial.dat-inic-valid      = tt-dwf-reduc-z-tot-parcial.dat-inic-valid      and  
             dwf-reduc-z-tot-parcial.dat-reduc-z         = tt-dwf-reduc-z-tot-parcial.dat-reduc-z         and  
             dwf-reduc-z-tot-parcial.cod-totaliz-parcial = tt-dwf-reduc-z-tot-parcial.cod-totaliz-parcial and
             dwf-reduc-z-tot-parcial.num-totaliz         = tt-dwf-reduc-z-tot-parcial.num-totaliz:       /* Sequencial chave */ end.
         if not avail dwf-reduc-z-tot-parcial then do:
            create dwf-reduc-z-tot-parcial.
            buffer-copy tt-dwf-reduc-z-tot-parcial to dwf-reduc-z-tot-parcial.
         end.
         else do:
            assign dwf-reduc-z-tot-parcial.val-acum-totaliz = tt-dwf-reduc-z-tot-parcial.val-acum-totaliz.
         end.
    end. /* tt-dwf-reduc-z-tot-parcial */

    for each tt-dwf-reduc-z-tot-parcial-item:
        
        RUN pi-acompanhar IN h-acomp (input "total Parcial Item: " + string(tt-dwf-reduc-z-tot-parcial-item.dat-reduc-z)).

        for first dwf-reduc-z-tot-parcial-item where
            dwf-reduc-z-tot-parcial-item.cod-cx-ecf          = tt-dwf-reduc-z-tot-parcial-item.cod-cx-ecf          and 
            dwf-reduc-z-tot-parcial-item.cod-estab           = tt-dwf-reduc-z-tot-parcial-item.cod-estab           and 
            dwf-reduc-z-tot-parcial-item.cod-fabricc-ecf     = tt-dwf-reduc-z-tot-parcial-item.cod-fabricc-ecf     and 
            dwf-reduc-z-tot-parcial-item.cod-model-docto     = tt-dwf-reduc-z-tot-parcial-item.cod-model-docto     and 
            dwf-reduc-z-tot-parcial-item.cod-model-ecf       = tt-dwf-reduc-z-tot-parcial-item.cod-model-ecf       and 
            dwf-reduc-z-tot-parcial-item.dat-inic-valid      = tt-dwf-reduc-z-tot-parcial-item.dat-inic-valid      and 
            dwf-reduc-z-tot-parcial-item.dat-reduc-z         = tt-dwf-reduc-z-tot-parcial-item.dat-reduc-z         and 
            dwf-reduc-z-tot-parcial-item.cod-totaliz-parcial = tt-dwf-reduc-z-tot-parcial-item.cod-totaliz-parcial and 
            dwf-reduc-z-tot-parcial-item.num-totaliz         = tt-dwf-reduc-z-tot-parcial-item.num-totaliz         and /* Sequencial chave */ 
            dwf-reduc-z-tot-parcial-item.cod-item            = tt-dwf-reduc-z-tot-parcial-item.cod-item:           end.                                        
        
        if not avail dwf-reduc-z-tot-parcial-item  then do:
            create dwf-reduc-z-tot-parcial-item.                                      
            buffer-copy tt-dwf-reduc-z-tot-parcial-item to dwf-reduc-z-tot-parcial-item.  
        end.
               
    end. /* tt-dwf-reduc-z-tot-parcial-item */

    for each tt-dwf-cupom-fisc:
         
         RUN pi-acompanhar IN h-acomp (input "Cupom :" + string(tt-dwf-cupom-fisc.cod-docto)).

         for first dwf-cupom-fisc where
             dwf-cupom-fisc.cod-cx-ecf      = tt-dwf-cupom-fisc.cod-cx-ecf       and 
             dwf-cupom-fisc.cod-estab       = tt-dwf-cupom-fisc.cod-estab        and 
             dwf-cupom-fisc.cod-fabricc-ecf = tt-dwf-cupom-fisc.cod-fabricc-ecf  and
             dwf-cupom-fisc.cod-model-docto = tt-dwf-cupom-fisc.cod-model-docto  and
             dwf-cupom-fisc.cod-model-ecf   = tt-dwf-cupom-fisc.cod-model-ecf    and
             dwf-cupom-fisc.dat-inic-valid  = tt-dwf-cupom-fisc.dat-inic-valid   and  
             dwf-cupom-fisc.dat-reduc-z     = tt-dwf-cupom-fisc.dat-reduc-z      and                    
             dwf-cupom-fisc.cod-docto       = tt-dwf-cupom-fisc.cod-docto:       end.
         if not avail dwf-cupom-fisc  then do:
             create dwf-cupom-fisc.                                               
             buffer-copy tt-dwf-cupom-fisc to dwf-cupom-fisc. 
         end.
    end. /* tt-dwf-cupom-fisc */
     
    for each tt-dwf-reduc-z:
         
         RUN pi-acompanhar IN h-acomp (input "Redu‡Æo Z : " + string(tt-dwf-reduc-z.dat-reduc-z)).

         for first dwf-reduc-z where
             dwf-reduc-z.cod-cx-ecf      = tt-dwf-reduc-z.cod-cx-ecf       and 
             dwf-reduc-z.cod-estab       = tt-dwf-reduc-z.cod-estab        and 
             dwf-reduc-z.cod-fabricc-ecf = tt-dwf-reduc-z.cod-fabricc-ecf  and
             dwf-reduc-z.cod-model-docto = tt-dwf-reduc-z.cod-model-docto  and
             dwf-reduc-z.cod-model-ecf   = tt-dwf-reduc-z.cod-model-ecf    and
             dwf-reduc-z.dat-inic-valid  = tt-dwf-reduc-z.dat-inic-valid   and 
             dwf-reduc-z.dat-reduc-z     = tt-dwf-reduc-z.dat-reduc-z:     end.
         if not avail dwf-reduc-z then do:
             create dwf-reduc-z.                                               
             buffer-copy tt-dwf-reduc-z to dwf-reduc-z. 
         end.
          
         assign dwf-reduc-z.val-vda-bruta = 0. 
          
         for each dwf-reduc-z-tot-parcial no-lock where 
             dwf-reduc-z-tot-parcial.cod-cx-ecf          = tt-dwf-reduc-z.cod-cx-ecf          and  
             dwf-reduc-z-tot-parcial.cod-estab           = tt-dwf-reduc-z.cod-estab           and  
             dwf-reduc-z-tot-parcial.cod-fabricc-ecf     = tt-dwf-reduc-z.cod-fabricc-ecf     and  
             dwf-reduc-z-tot-parcial.cod-model-docto     = tt-dwf-reduc-z.cod-model-docto     and  
             dwf-reduc-z-tot-parcial.cod-model-ecf       = tt-dwf-reduc-z.cod-model-ecf       and  
             dwf-reduc-z-tot-parcial.dat-inic-valid      = tt-dwf-reduc-z.dat-inic-valid      and  
             dwf-reduc-z-tot-parcial.dat-reduc-z         = tt-dwf-reduc-z.dat-reduc-z :
             assign dwf-reduc-z.val-vda-bruta = dwf-reduc-z.val-vda-bruta + dwf-reduc-z-tot-parcial.val-acum-totaliz.
         end.        
    end. /* tt-dwf-reduc-z */


    for each tt-dwf-cfe: 
        
         RUN pi-acompanhar IN h-acomp (input "Cupom Modelo 59 : " + string(tt-dwf-cfe.dat-reduc-z)).
 
         for first dwf-cfe where
             dwf-cfe.cod-estab        = tt-dwf-cfe.cod-estab        and 
             dwf-cfe.cod-model-docto  = tt-dwf-cfe.cod-model-docto  and 
             dwf-cfe.cod-model-cfe    = tt-dwf-cfe.cod-model-cfe    and
             dwf-cfe.cod-sat          = tt-dwf-cfe.cod-sat          and
             dwf-cfe.dat-reduc-z      = tt-dwf-cfe.dat-reduc-z      and                   
             dwf-cfe.dat-inic-valid   = tt-dwf-cfe.dat-inic-valid   and
             dwf-cfe.dat-fim-valid   = ?:                           end.
         
         if not avail dwf-cfe then do:
            create dwf-cfe.
            buffer-copy tt-dwf-cfe to dwf-cfe.
         end. 
    end. /* tt-dwf-cfe */

    for each tt-dwf-cfe-resum: 
        
         RUN pi-acompanhar IN h-acomp (input "ITEM Cupom Modelo 59 : " + string(tt-dwf-cfe-resum.dat-reduc-z)).
 
         for first dwf-cfe-resum where
             dwf-cfe-resum.cod-estab            = tt-dwf-cfe-resum.cod-estab        and 
             dwf-cfe-resum.cod-model-docto      = tt-dwf-cfe-resum.cod-model-docto  and 
             dwf-cfe-resum.cod-model-cfe        = tt-dwf-cfe-resum.cod-model-cfe    and
             dwf-cfe-resum.cod-sat              = tt-dwf-cfe-resum.cod-sat          and
             dwf-cfe-resum.dat-reduc-z          = tt-dwf-cfe-resum.dat-reduc-z      and                   
             dwf-cfe-resum.cod-sit-tributar-icms = tt-dwf-cfe-resum.cod-sit-tributar-icms and
             dwf-cfe-resum.cod-cfop	            = tt-dwf-cfe-resum.cod-cfop       and
             dwf-cfe-resum.val-aliq-icms	    = tt-dwf-cfe-resum.val-aliq-icms  and
             dwf-cfe-resum.dat-inic-valid       = tt-dwf-cfe-resum.dat-inic-valid and
             dwf-cfe-resum.dat-fim-valid        = ?: end.
         
         if not avail dwf-cfe-resum then do:
            create dwf-cfe-resum.
            buffer-copy tt-dwf-cfe-resum to dwf-cfe-resum.
         end. 
    end. /* tt-dwf-cfe-resum */

    FOR EACH tt-mapa-ecf:
        for first int_ds_mapa_ecf where
                  rowid(int_ds_mapa_ecf) = tt-mapa-ecf.r-mapa EXCLUSIVE-LOCK:
        end.
        IF AVAIL int_ds_mapa_ecf THEN DO:
           assign int_ds_mapa_ecf.situacao = "I". /* INTEGRADO */
           RELEASE int_ds_mapa_ecf.
        END.
    END.
end. /* InclusÆo */

else do : /* Elimina‡Æo */

  for each tt-estabelec NO-LOCK,
      first estabelec where 
      estabelec.cod-estabel = tt-estabelec.cod-estabel 
      break by tt-estabelec.cod-estabel: 

      for each dwf-cfe-resum where
          dwf-cfe-resum.cod-estab       = estabelec.cod-estabel and 
          dwf-cfe-resum.dat-reduc-z    >= tt-param.dt-trans-ini and
          dwf-cfe-resum.dat-reduc-z    <= tt-param.dt-trans-fim and
          dwf-cfe-resum.cod-model-docto = '59':
          RUN pi-acompanhar IN h-acomp (input "NF Modelo 59 ITEM : " + string(dwf-cfe-resum.dat-reduc-z)).
          delete dwf-cfe-resum.
      end.

      for each dwf-cfe where
          dwf-cfe.cod-estab       = estabelec.cod-estabel   and 
          dwf-cfe.dat-reduc-z    >= tt-param.dt-trans-ini   and
          dwf-cfe.dat-reduc-z    <= tt-param.dt-trans-fim   and
          dwf-cfe.cod-model-docto = '59':
          RUN pi-acompanhar IN h-acomp (input "NF Modelo 59 : " + string(dwf-cfe.dat-reduc-z)).
          delete dwf-cfe.
      end.
          
      bloco_fim_operacao:
      for each int_ds_mapa_ecf no-lock where
          int_ds_mapa_ecf.filial  = estabelec.cod-estabel and 
          int_ds_mapa_ecf.data   >= tt-param.dt-trans-ini and 
          int_ds_mapa_ecf.data   <= tt-param.dt-trans-fim and 
          int_ds_mapa_ecf.situacao = "I" : /* Integrado */
               
          RUN pi-acompanhar IN h-acomp (input "Eliminando : " + string(int_ds_mapa_ecf.cont_reduc)).
            
           /* verificar qual ‚ o estabelecimento pelo cnpj. No entanto, dever  ser verificado se a Data de Validade do estabelecimento est  em branco, 
              pois existem mais de um estabelecimento cadastrado com o mesmo CNPJ.     
              Valida‡Æo cst_estabelec.dt-fim-operacao <> 31/12/9999 e se est  v lido. 
              Sempre verificar o data fim do per¡odo para buscar o estabelecimento.
           */  

          for first cst_estabelec no-lock where
              cst_estabelec.cod_estabel = int_ds_mapa_ecf.filial :
              if int_ds_mapa_ecf.data > cst_estabelec.dt_fim_operacao then next bloco_fim_operacao.
          end. 
          /*      
          for each dwf-eqpto-ecf where
              dwf-eqpto-ecf.cod-cx-ecf      = int_ds_mapa_ecf.impressora and 
              dwf-eqpto-ecf.cod-estab       = int_ds_mapa_ecf.filial     and 
              dwf-eqpto-ecf.cod-fabricc-ecf = int_ds_mapa_ecf.serie_equi and 
              dwf-eqpto-ecf.cod-estab       = estabelec.cod-estabel      /*and 
              dwf-eqpto-ecf.dat-reduc-z    >= tt-param.dt-trans-ini      and  
              dwf-eqpto-ecf.dat-reduc-z    <= tt-param.dt-trans-fim*/ :
              RUN pi-acompanhar IN h-acomp (input "Eqpto : " + string(dwf-eqpto-ecf.cod-cx-ecf)).
              /*DELETE dwf-eqpto-ecf.*/
          end. 
          */

          for each dwf-cupom-fisc-item where
              dwf-cupom-fisc-item.cod-cx-ecf      = int_ds_mapa_ecf.impressora and 
              dwf-cupom-fisc-item.cod-estab       = int_ds_mapa_ecf.filial     and 
              dwf-cupom-fisc-item.cod-fabricc-ecf = int_ds_mapa_ecf.serie_equi and
              dwf-cupom-fisc-item.cod-estab       = estabelec.cod-estabel      and 
              dwf-cupom-fisc-item.dat-reduc-z    >= tt-param.dt-trans-ini      and 
              dwf-cupom-fisc-item.dat-reduc-z    <= tt-param.dt-trans-fim : 
              RUN pi-acompanhar IN h-acomp (input "Cupom Item : " + string(dwf-cupom-fisc-item.cod-docto)).
              delete dwf-cupom-fisc-item.
          end.
  
          for each dwf-cupom-fisc-resum where
              dwf-cupom-fisc-resum.cod-cx-ecf      = int_ds_mapa_ecf.impressora and 
              dwf-cupom-fisc-resum.cod-estab       = int_ds_mapa_ecf.filial     and 
              dwf-cupom-fisc-resum.cod-fabricc-ecf = int_ds_mapa_ecf.serie_equi and 
              dwf-cupom-fisc-resum.cod-estab       = estabelec.cod-estabel      and  
              dwf-cupom-fisc-resum.dat-reduc-z    >= tt-param.dt-trans-ini      and  
              dwf-cupom-fisc-resum.dat-reduc-z    <= tt-param.dt-trans-fim :
              RUN pi-acompanhar IN h-acomp (input "Resumo : " + string(dwf-cupom-fisc-resum.dat-reduc-z)).
              delete dwf-cupom-fisc-resum.
          end.       
  
          for each dwf-reduc-z-resum-diario where
                   dwf-reduc-z-resum-diario.cod-cx-ecf      = int_ds_mapa_ecf.impressora and 
                   dwf-reduc-z-resum-diario.cod-estab       = int_ds_mapa_ecf.filial     and 
                   dwf-reduc-z-resum-diario.cod-fabricc-ecf = int_ds_mapa_ecf.serie_equi and                      
                   dwf-reduc-z-resum-diario.cod-estab       = estabelec.cod-estabel      and
                   dwf-reduc-z-resum-diario.dat-reduc-z    >= tt-param.dt-trans-ini      and 
                   dwf-reduc-z-resum-diario.dat-reduc-z    <= tt-param.dt-trans-fim : 
                   
              RUN pi-acompanhar IN h-acomp (input "Resumo Di rio : " + string(dwf-reduc-z-resum-diario.dat-reduc-z)).        
                    
              DELETE dwf-reduc-z-resum-diario.
                   
          end.         
  
          for each dwf-reduc-z-tot-parcial where 
              dwf-reduc-z-tot-parcial.cod-cx-ecf      = int_ds_mapa_ecf.impressora and 
              dwf-reduc-z-tot-parcial.cod-estab       = int_ds_mapa_ecf.filial     and 
              dwf-reduc-z-tot-parcial.cod-fabricc-ecf = int_ds_mapa_ecf.serie_equi and                                        
              dwf-reduc-z-tot-parcial.cod-estab       = estabelec.cod-estabel      and  
              dwf-reduc-z-tot-parcial.dat-reduc-z    >= tt-param.dt-trans-ini      and
              dwf-reduc-z-tot-parcial.dat-reduc-z    <= tt-param.dt-trans-fim :
              RUN pi-acompanhar IN h-acomp (input "total Parcial: " + string(dwf-reduc-z-tot-parcial.dat-reduc-z)).
              delete dwf-reduc-z-tot-parcial.
          end.
  
          for each dwf-reduc-z-tot-parcial-item where
              dwf-reduc-z-tot-parcial-item.cod-cx-ecf      = int_ds_mapa_ecf.impressora and 
              dwf-reduc-z-tot-parcial-item.cod-estab       = int_ds_mapa_ecf.filial     and 
              dwf-reduc-z-tot-parcial-item.cod-fabricc-ecf = int_ds_mapa_ecf.serie_equi and               
              dwf-reduc-z-tot-parcial-item.cod-estab    = estabelec.cod-estabel         and  
              dwf-reduc-z-tot-parcial-item.dat-reduc-z >= tt-param.dt-trans-ini         and  
              dwf-reduc-z-tot-parcial-item.dat-reduc-z <= tt-param.dt-trans-fim :  
              RUN pi-acompanhar IN h-acomp (input "total Parcial Item: " + string(dwf-reduc-z-tot-parcial-item.dat-reduc-z)).        
              delete dwf-reduc-z-tot-parcial-item.
          end.
  
          for each dwf-cupom-fisc where
              dwf-cupom-fisc.cod-cx-ecf      = int_ds_mapa_ecf.impressora and 
              dwf-cupom-fisc.cod-estab       = int_ds_mapa_ecf.filial     and 
              dwf-cupom-fisc.cod-fabricc-ecf = int_ds_mapa_ecf.serie_equi and                           
              dwf-cupom-fisc.cod-estab       = estabelec.cod-estabel      and  
              dwf-cupom-fisc.dat-reduc-z    >= tt-param.dt-trans-ini      and  
              dwf-cupom-fisc.dat-reduc-z    <= tt-param.dt-trans-fim :  
              RUN pi-acompanhar IN h-acomp (input "Cupom :" + string(dwf-cupom-fisc.cod-docto)).       
              delete dwf-cupom-fisc.
          end.
  
          for each dwf-reduc-z where
              dwf-reduc-z.cod-cx-ecf      = int_ds_mapa_ecf.impressora and 
              dwf-reduc-z.cod-estab       = int_ds_mapa_ecf.filial     and 
              dwf-reduc-z.cod-fabricc-ecf = int_ds_mapa_ecf.serie_equi and    
              dwf-reduc-z.cod-estab       = int_ds_mapa_ecf.filial     and   
              dwf-reduc-z.dat-reduc-z    >= tt-param.dt-trans-ini      and
              dwf-reduc-z.dat-reduc-z    <= tt-param.dt-trans-fim:
              RUN pi-acompanhar IN h-acomp (input "Redu‡Æo Z : " + string(dwf-reduc-z.dat-reduc-z)).
              delete dwf-reduc-z.
          end.
         
          for first b-int_ds_mapa_ecf where
              rowid(b-int_ds_mapa_ecf) = rowid(int_ds_mapa_ecf) :
              assign b-int_ds_mapa_ecf.situacao = "F". /* Finalizado Tutorial */
          end.    
          
          release b-int_ds_mapa_ecf.      
                        
      end. /* bloco int_ds_mapa_ecf */        
   end. /* estabelec */
end. /* Elimina */


run pi-finalizar in h-acomp.          

page stream str-rp.

PUT STREAM str-rp "------------- PARAMETROS CONSIDERADOS --------------" skip(1)
    "         Execu‡Æo     " at  2  c-situacao format "x(30)" SKIP
    "--------------------- SELECAO ----------------------" skip(1)
    " Estabelecimento.: " c-estab-ini " a " c-estab-fim AT 29 SKIP
    " Per¡odo.......: " tt-param.dt-trans-ini   at 20 " at‚ " tt-param.dt-trans-fim   skip
    .

{include/i-rpclo.i  &STREAM="stream str-rp"}      


PROCEDURE pi-tot-parcial:
    DEF input PARAMETER p-cod-total    as char.
    DEF input PARAMETER p-num-totaliz  as int.

    for first tt-dwf-reduc-z-tot-parcial where 
              tt-dwf-reduc-z-tot-parcial.cod-cx-ecf          = int_ds_mapa_ecf.impressora and  
              tt-dwf-reduc-z-tot-parcial.cod-estab           = int_ds_mapa_ecf.filial     and  
              tt-dwf-reduc-z-tot-parcial.cod-fabricc-ecf     = int_ds_mapa_ecf.serie_equi and  
              tt-dwf-reduc-z-tot-parcial.cod-model-docto     = c-model-docto              and  
              tt-dwf-reduc-z-tot-parcial.cod-model-ecf       = c-model-ecf                and  
              tt-dwf-reduc-z-tot-parcial.dat-inic-valid      = dt-inic-valid              and  
              tt-dwf-reduc-z-tot-parcial.dat-reduc-z         = int_ds_mapa_ecf.data       and  
              tt-dwf-reduc-z-tot-parcial.cod-totaliz-parcial = p-cod-total                and
              tt-dwf-reduc-z-tot-parcial.num-totaliz         = p-num-totaliz :  /* Sequencial chave */

    end.
    if not avail tt-dwf-reduc-z-tot-parcial 
    then do:
        IF it-doc-fisc.vl-tot-item > 0 then do:
            /*MESSAGE 17  VIEW-as ALERT-BOX INFO BUTtoNS OK.*/
           create tt-dwf-reduc-z-tot-parcial.
          assign tt-dwf-reduc-z-tot-parcial.cod-cx-ecf          = int_ds_mapa_ecf.impressora 
                 tt-dwf-reduc-z-tot-parcial.cod-estab           = int_ds_mapa_ecf.filial     
                 tt-dwf-reduc-z-tot-parcial.cod-fabricc-ecf     = int_ds_mapa_ecf.serie_equi 
                 tt-dwf-reduc-z-tot-parcial.cod-model-docto     = c-model-docto              
                 tt-dwf-reduc-z-tot-parcial.cod-model-ecf       = c-model-ecf                
                 tt-dwf-reduc-z-tot-parcial.dat-reduc-z         = int_ds_mapa_ecf.data  
                 tt-dwf-reduc-z-tot-parcial.dat-inic-valid      = dt-inic-valid      
                 tt-dwf-reduc-z-tot-parcial.cod-totaliz-parcial = p-cod-total  
                 tt-dwf-reduc-z-tot-parcial.num-totaliz         = p-num-totaliz 
                 tt-dwf-reduc-z-tot-parcial.val-acum-totaliz    = it-doc-fisc.vl-tot-item.
        end.

       /*CasE It-doc-fisc.cd-trib-icm:
            WHEN 1 THEN tt-dwf-reduc-z-tot-parcial.des-sit-totaliz = "Tributado".
            WHEN 2 THEN tt-dwf-reduc-z-tot-parcial.des-sit-totaliz = "Isento".
            WHEN 3 THEN tt-dwf-reduc-z-tot-parcial.des-sit-totaliz = "Outros".
       end CasE.*/
                                                                      
    end.
    else do:
        assign tt-dwf-reduc-z-tot-parcial.val-acum-totaliz = tt-dwf-reduc-z-tot-parcial.val-acum-totaliz + it-doc-fisc.vl-tot-item.
    end.
     
    if p-cod-total <> "Can-T" and 
         it-doc-fisc.quantidade > 0 then do:
     
        for first tt-dwf-reduc-z-tot-parcial-item where
                  tt-dwf-reduc-z-tot-parcial-item.cod-cx-ecf          = int_ds_mapa_ecf.impressora and 
                  tt-dwf-reduc-z-tot-parcial-item.cod-estab           = int_ds_mapa_ecf.filial     and 
                  tt-dwf-reduc-z-tot-parcial-item.cod-fabricc-ecf     = int_ds_mapa_ecf.serie_equi and 
                  tt-dwf-reduc-z-tot-parcial-item.cod-model-docto     = c-model-docto              and 
                  tt-dwf-reduc-z-tot-parcial-item.cod-model-ecf       = c-model-ecf                and 
                  tt-dwf-reduc-z-tot-parcial-item.dat-inic-valid      = dt-inic-valid              and  
                  tt-dwf-reduc-z-tot-parcial-item.dat-reduc-z         = int_ds_mapa_ecf.data    and 
                  tt-dwf-reduc-z-tot-parcial-item.cod-totaliz-parcial = p-cod-total                and
                  tt-dwf-reduc-z-tot-parcial-item.num-totaliz         = p-num-totaliz              and  /* Sequencial chave */  
                  tt-dwf-reduc-z-tot-parcial-item.cod-item            = it-doc-fisc.it-codigo:                            
             
        end.
        if not avail tt-dwf-reduc-z-tot-parcial-item then do:
           IF it-doc-fisc.vl-tot-item > 0 then do:
               /*MESSAGE 18 VIEW-as ALERT-BOX INFO BUTtoNS OK.*/
              create tt-dwf-reduc-z-tot-parcial-item.
              assign tt-dwf-reduc-z-tot-parcial-item.cod-cx-ecf              = int_ds_mapa_ecf.impressora
                     tt-dwf-reduc-z-tot-parcial-item.cod-estab               = int_ds_mapa_ecf.filial    
                     tt-dwf-reduc-z-tot-parcial-item.cod-fabricc-ecf         = int_ds_mapa_ecf.serie_equi
                     tt-dwf-reduc-z-tot-parcial-item.cod-model-docto         = c-model-docto             
                     tt-dwf-reduc-z-tot-parcial-item.cod-model-ecf           = c-model-ecf    
                     tt-dwf-reduc-z-tot-parcial-item.dat-inic-valid          = dt-inic-valid                  
                     tt-dwf-reduc-z-tot-parcial-item.dat-reduc-z             = int_ds_mapa_ecf.data        
                     tt-dwf-reduc-z-tot-parcial-item.cod-totaliz-parcial     = p-cod-total   
                     tt-dwf-reduc-z-tot-parcial-item.num-totaliz             = p-num-totaliz             
                     tt-dwf-reduc-z-tot-parcial-item.cod-item                = it-doc-fisc.it-codigo
                     tt-dwf-reduc-z-tot-parcial-item.cod-sit-tributar-cofins = string(it-nota-fisc.cod-sit-tributar-pis,"99") /*string(it-doc-fisc.cd-trib-cofins) */
                     tt-dwf-reduc-z-tot-parcial-item.cod-sit-tributar-pis    = string(it-nota-fisc.cod-sit-tributar-cofins,"99") /*string(it-doc-fisc.cd-trib-pis)  */
                     tt-dwf-reduc-z-tot-parcial-item.cod-unid-medid          = it-doc-fisc.un                  
                     tt-dwf-reduc-z-tot-parcial-item.qtd-item                = it-doc-fisc.quantidade              
                     tt-dwf-reduc-z-tot-parcial-item.val-aliq-cofins         = it-doc-fisc.aliq-cofins             
                     tt-dwf-reduc-z-tot-parcial-item.val-aliq-pis            = it-doc-fisc.aliq-pis                
                     tt-dwf-reduc-z-tot-parcial-item.val-base-cofins         = it-doc-fisc.val-base-calc-cofins    
                     tt-dwf-reduc-z-tot-parcial-item.val-base-pis            = it-doc-fisc.val-base-calc-pis       
                     tt-dwf-reduc-z-tot-parcial-item.val-cofins              = it-doc-fisc.val-cofins              
                     tt-dwf-reduc-z-tot-parcial-item.val-item                = it-doc-fisc.vl-tot-item             
                     tt-dwf-reduc-z-tot-parcial-item.val-pis                 = it-doc-fisc.val-pis                      
                     tt-dwf-reduc-z-tot-parcial-item.val-quant-aliq-cofins   = 0                       
                     tt-dwf-reduc-z-tot-parcial-item.val-quant-aliq-pis      = 0                    
                     tt-dwf-reduc-z-tot-parcial-item.val-quant-base-cofins   = 0                    
                     tt-dwf-reduc-z-tot-parcial-item.val-quant-base-pis      = 0.            
           end.
        end.
        else do:
           
           assign tt-dwf-reduc-z-tot-parcial-item.qtd-item                = tt-dwf-reduc-z-tot-parcial-item.qtd-item        + it-doc-fisc.quantidade              
                  tt-dwf-reduc-z-tot-parcial-item.val-base-cofins         = tt-dwf-reduc-z-tot-parcial-item.val-base-cofins + it-doc-fisc.val-base-calc-cofins    
                  tt-dwf-reduc-z-tot-parcial-item.val-base-pis            = tt-dwf-reduc-z-tot-parcial-item.val-base-pis    + it-doc-fisc.val-base-calc-pis       
                  tt-dwf-reduc-z-tot-parcial-item.val-cofins              = tt-dwf-reduc-z-tot-parcial-item.val-cofins      + it-doc-fisc.val-cofins              
                  tt-dwf-reduc-z-tot-parcial-item.val-item                = tt-dwf-reduc-z-tot-parcial-item.val-item        + it-doc-fisc.vl-tot-item             
                  tt-dwf-reduc-z-tot-parcial-item.val-pis                 = tt-dwf-reduc-z-tot-parcial-item.val-pis         + it-doc-fisc.val-pis
                  tt-dwf-reduc-z-tot-parcial-item.cod-unid-medid          = it-doc-fisc.un                  .
        
        end.
    end. 

end.



PROCEDURE GravaInfModelo59:
    def var nr-docto as char format "X(20)" no-undo.
    def var nr-docto-SAT as char format "X(20)" no-undo.

    IF TRIM(Doc-fiscal.cod-chave-aces-nf-eletro) <> '' then do:
        assign Nr-docto-SAT = string(int(SUBstring(doc-fiscal.cod-chave-aces-nf-eletro,23,9))).
        assign nr-docto    = string(int(SUBstring(doc-fiscal.cod-chave-aces-nf-eletro,32,6))).
    end.  
    else do:
       assign Nr-docto-SAT = string(int(SUBstring(doc-fiscal.char-2,177,9))).
       assign nr-docto    = string(int(SUBstring(doc-fiscal.char-2,186,6))).
    end.

    find first tt-dwf-cfe exclusive-lock 
       where tt-dwf-cfe.cod-estab       = doc-fiscal.cod-estab
       and   tt-dwf-cfe.cod-model-docto = '59'
       and   tt-dwf-cfe.cod-model-cfe   = Nr-docto /*string(int(doc-fiscal.nr-doc-fis))*/                     
       and   tt-dwf-cfe.cod-sat         = Nr-docto-SAT /*string(int(doc-fiscal.nr-doc-fis))*/
       and   tt-dwf-cfe.dat-reduc-z     = doc-fiscal.dt-docto
       and   tt-dwf-cfe.dat-fim-valid   = ? NO-ERROR.


     FIND FIRST natur-oper NO-LOCK where natur-oper.nat-operacao = doc-fiscal.nat-operacao NO-ERROR.

     &IF '{&bf_dis_versao_ems}' >= '2.08' &THEN
        &GLOBAL-DEFINE log-icms-substto-antecip natur-oper.log-icms-substto-antecip
      &ELSE
         &GLOBAL-DEFINE log-icms-substto-antecip SUBstring(natur-oper.char-1,147,1) = "1"    
     &endIF 
     

    IF it-doc-fisc.vl-tot-item > 0  then do:

       if not avail tt-dwf-cfe then do:
          FIND FIRST emitente NO-LOCK where emitente.cod-emitente = Doc-fiscal.cod-emitente NO-ERROR.

          create tt-dwf-cfe.
          assign tt-Dwf-cfe.cod-estab                  = Doc-fiscal.cod-estabel
                 tt-Dwf-cfe.cod-model-docto            = '59' /*Doc-fiscal.nat-operacao ' natur-oper.nat-operacao = natur-oper.cod-model-nf-eletro*/
                 tt-Dwf-cfe.dat-reduc-z                = doc-fiscal.dt-docto
                 tt-Dwf-cfe.cod-model-cfe              = nr-docto /*string(int(Doc-fiscal.nr-doc-fis)) */
                 tt-Dwf-cfe.cod-sat	                = nr-docto-SAT /*string(int(Doc-fiscal.nr-doc-fis))*/
                 tt-Dwf-cfe.cod-sit-docto              = string(IF Doc-fiscal.ind-sit-doc = 1 THEN 0 ELSE 2,"99")
                 tt-Dwf-cfe.cod-chave-cupom-fisc-eletr = Doc-fiscal.cod-chave-aces-nf-eletro    
                 tt-Dwf-cfe.cod-cnpj-cpf-dest          = Emitente.cgc
                 tt-Dwf-cfe.val-mercad                 = it-doc-fisc.vl-merc-liq
                 tt-Dwf-cfe.val-docto                  = it-doc-fisc.vl-tot-item /*Doc-fiscal.vl-cont-doc*/
                 tt-Dwf-cfe.val-pis	                = it-doc-fisc.val-pis
                 tt-Dwf-cfe.val-cofins                 = it-doc-fisc.val-cofins
                 tt-Dwf-cfe.val-desc	                = it-doc-fisc.desconto
                 tt-Dwf-cfe.val-despes-acessor  	    = it-doc-fisc.vl-despes-it
                 tt-Dwf-cfe.val-icms	                = it-doc-fisc.vl-icms-it
                 tt-Dwf-cfe.val-cofins-st	            = 0
                 tt-Dwf-cfe.val-pis-st	                = 0
                 tt-Dwf-cfe.dat-fim-valid	            = ?
                 tt-Dwf-cfe.dat-inic-valid	            = today  .
          IF TRIM(tt-Dwf-cfe.cod-chave-cupom-fisc-eletr)   = '' THEN
              assign tt-Dwf-cfe.cod-chave-cupom-fisc-eletr = SUBstring(doc-fiscal.char-2,155,60).
          /*assign Dwf-cfe.cod-model-cfe = SubStr(Dwf-cfe.cod-chave-cupom-fisc-eletr,23,9).*/
       end. 
       else do:
           assign tt-Dwf-cfe.val-docto   = tt-Dwf-cfe.val-docto  + it-doc-fisc.vl-tot-item
                  tt-Dwf-cfe.val-mercad  = tt-Dwf-cfe.val-mercad + it-doc-fisc.vl-merc-liq
                  tt-Dwf-cfe.val-pis     = tt-Dwf-cfe.val-pis + it-doc-fisc.val-pis
                  tt-Dwf-cfe.val-cofins  = tt-Dwf-cfe.val-cofins + it-doc-fisc.val-cofins
                  tt-Dwf-cfe.val-desc    = tt-Dwf-cfe.val-desc + it-doc-fisc.desconto
                  tt-Dwf-cfe.val-despes-acessor = tt-Dwf-cfe.val-despes-acessor + it-doc-fisc.vl-despes-it
                  tt-Dwf-cfe.val-icms	  = tt-Dwf-cfe.val-icms + it-doc-fisc.vl-icms-it.
       end.

       assign i-codigo = 0.

       /*RUN situacaoTribICMSDoitem(input  2,  /* Para Saida e servico */ OUTPUT i-codigo).*/
       assign c-cod-tributac-icms = string(i-codigo,"999").

       /*MESSAGE c-cod-tributac-icms
           VIEW-as ALERT-BOX INFO BUTtoNS OK.*/


       FIND FIRST tt-dwf-cfe-resum EXCLUSIVE-LOCK
          where tt-dwf-cfe-resum.cod-estab             = doc-fiscal.cod-estabel
          and   tt-dwf-cfe-resum.cod-model-docto       = "59"
          and   tt-dwf-cfe-resum.cod-model-cfe         = nr-docto                     
          and   tt-dwf-cfe-resum.cod-sat               = nr-docto-SAT
          and   tt-dwf-cfe-resum.dat-reduc-z           = doc-fiscal.dt-docto
          and   tt-dwf-cfe-resum.cod-sit-tributar-icms = c-cod-tributac-icms
          and   tt-dwf-cfe-resum.cod-cfop	            = doc-fiscal.cod-cfop
          and   tt-dwf-cfe-resum.val-aliq-icms	        = it-doc-fisc.aliquota-icm
          and   tt-dwf-cfe-resum.dat-fim-valid         = ? NO-ERROR.


       if not avail tt-dwf-cfe-resum then do:
           /*MESSAGE 20 VIEW-as ALERT-BOX INFO BUTtoNS OK.*/
           create tt-dwf-cfe-resum.
           assign tt-dwf-cfe-resum.cod-estab               =  it-doc-fisc.cod-estabel
                  tt-dwf-cfe-resum.cod-model-docto         = '59'  /*it-doc-fisc.nat-operacao ' natur-oper.nat-operacao = natur-oper.cod-model-nf-eletro*/
                  tt-dwf-cfe-resum.cod-model-cfe           = Nr-docto  /*string(int(it-doc-fisc.nr-doc-fis))*/
                  tt-dwf-cfe-resum.cod-sat	                = Nr-docto-SAT /*string(int(it-doc-fisc.nr-doc-fis))*/
                  tt-dwf-cfe-resum.dat-reduc-z	            = doc-fiscal.dt-docto
                  tt-dwf-cfe-resum.cod-sit-tributar-icms	= c-cod-tributac-icms
                  tt-dwf-cfe-resum.cod-cfop	            = doc-fiscal.cod-cfop
                  tt-dwf-cfe-resum.val-aliq-icms	        = it-doc-fisc.aliquota-icm
                  /*tt-dwf-cfe-resum.cod-obs-fisc	        = string(doc-fiscal.cod-mensagem)*/
                  tt-dwf-cfe-resum.val-docto	            = it-doc-fisc.vl-tot-item
                  tt-dwf-cfe-resum.val-base-icms	        = it-doc-fisc.vl-bicms-it
                  tt-dwf-cfe-resum.val-icms	            = it-doc-fisc.vl-icms-it 
                  tt-dwf-cfe-resum.dat-fim-valid	        =  ?
                  tt-dwf-cfe-resum.dat-inic-valid	        = today.
    

       end. 
       else do:
           assign tt-dwf-cfe-resum.val-docto	            = tt-dwf-cfe-resum.val-docto     + it-doc-fisc.vl-tot-item
                  tt-dwf-cfe-resum.val-base-icms	        = tt-dwf-cfe-resum.val-base-icms + it-doc-fisc.vl-bicms-it
                  tt-dwf-cfe-resum.val-icms	            = tt-dwf-cfe-resum.val-icms      + it-doc-fisc.vl-icms-it .
   
       end.
      /*RELEasE tt-dwf-cfe.
       RELEasE tt-dwf-cfe-resum.*/
    end.

end PROCEDURE.

/*PROCEDURE situacaoTribICMSDoitem:
    {intprg/lf0202.i15}
end PROCEDURE.*/

/*PROCEDURE situacaoTribICMSDoitem:

/*---------------------------------------------------------------------------
 Procedimento: situacaoTribICMSDoitem
 Objetivo: Determina a situacao tributaria do item da Nota, conforme tabela
           do regulamento do Icms:
           00 - Tributado integralmente
           10 - Tributado e com cobranca por susbstituicao tributaria
           20 - Com relacao a base de calculo
           30 - Isenta e com cobranca por susbstituicao tributaria
           40 - Isenta
           41 - Nao tributada
           50 - Suspensao
           51 - Diferimento
           60 - Icms cobrado anteriormente por substituicao tributaria
           70 - Com reducao e com cobranca por susbstituicao tributaria 
           90 - Outras
 --------------------------------------------------------------------------*/

DEF input  PARAM piTipoNat as INT no-undo.
DEF OUTPUT PARAM piCodigo  as INT no-undo.
def var deVlIcmsIte3       as DEC no-undo.
def var iCdTribIcm         as INT no-undo.
def var lIndIcmRet         as LOG no-undo.
def var deVlIcmRed         as DEC no-undo.
def var iTipoVat           as INT no-undo.
def var lDifPr             as LOG no-undo.
def var iCodOrig           as INT no-undo.
def var de-val-diferim     as DEC no-undo.

DEF BUFFER b-it-nota-fisc  FOR it-nota-fisc.
DEF BUFFER b-item-doc-est  FOR item-doc-est.

IF  NOT AVAIL natur-oper THEN 
    RETURN "OK":U.

assign deVlIcmsIte3 = 0
       iCdTribIcm   = it-doc-fisc.cd-trib-icm
       /* se basia tambem no campo val icms subst entrada */
       lIndIcmRet   = (it-doc-fisc.vl-icmsub-it > 0 ) 
       piCodigo     = 0.
       
DO TRANS:
    IF  piTipoNat = 2 then do: /* Documento de Sa¡da */
        for first b-it-nota-fisc
            where b-it-nota-fisc.cod-estabel = it-doc-fisc.cod-estabel
            and   b-it-nota-fisc.serie       = it-doc-fisc.serie
            and   b-it-nota-fisc.nr-nota-fis = it-doc-fisc.nr-doc-fis
            and   b-it-nota-fisc.nr-seq-fat  = it-doc-fisc.nr-seq-doc
            and   b-it-nota-fisc.it-codigo   = it-doc-fisc.it-codigo NO-LOCK:
        end.
            
        IF  AVAIL b-it-nota-fisc THEN
            assign deVlIcmsIte3 = b-it-nota-fisc.vl-icmsit-e[3]
                   iCdTribIcm   = (IF b-it-nota-fisc.cd-trib-icm = 4 THEN 4 ELSE it-doc-fisc.cd-trib-icm)
                   lIndIcmRet   = b-it-nota-fisc.ind-icm-ret OR it-doc-fisc.vl-icmsub-it > 0
                   deVlIcmRed   = (IF iCdTribIcm = 4 THEN b-it-nota-fisc.vl-icmsnt-it + b-it-nota-fisc.vl-icmsou-it ELSE 0).
    end.
    
    IF AVAIL item-doc-est 
    and SUBstring(item-doc-est.char-2,502,3) <> "" THEN
        assign piCodigo = INT(TRIM(SUBstring(item-doc-est.char-2,502,3))).
    else do:
        assign iTipoVat = INT(natur-oper.ind-tipo-vat).
        /* O tratamento do diferimento FT0609 ² feito apenas para o ICMS tributado */
        IF iCdTribIcm = 1 then do: /* Tributado */
            /* DIFERIMENto PR */
            assign lDifPr = NO.
            
            for first doc-fiscal
                where doc-fiscal.cod-estabel  = it-doc-fisc.cod-estabel
                and   doc-fiscal.serie        = it-doc-fisc.serie
                and   doc-fiscal.nr-doc-fis   = it-doc-fisc.nr-doc-fis 
	        and   doc-fiscal.cod-emitente = it-doc-fisc.cod-emitente
                and   doc-fiscal.nat-operacao = it-doc-fisc.nat-operacao NO-LOCK:
                
                FIND FIRST estabelec NO-LOCK
                     where estabelec.cod-estabel = doc-fiscal.cod-estabel NO-ERROR.
                     
                IF AVAIL estabelec THEN 
                    FIND FIRST diferim-parcial-icms NO-LOCK
                        where  diferim-parcial-icms.cod-estado = estabelec.estado
                        and    diferim-parcial-icms.cod-item   = it-doc-fisc.it-codigo NO-ERROR.
                     
                IF AVAIL diferim-parcial-icms then do:
                    IF AVAIL natur-oper
                    and (   natur-oper.nat-operacao BEGINS "5":U  
                         OR natur-oper.nat-operacao BEGINS "3":U 
                         OR natur-oper.nat-operacao BEGINS "1":U )
                    and NOT natur-oper.consum-final then do:
                        assign lDifPr = YES.
                    end.
                end.
                IF AVAIL b-it-nota-fisc then do:    
                    assign de-val-diferim = 0.
                    {dibo/bodi630.i5 "ICMS_ValDif" de-val-diferim b-it-nota-fisc}
                    
                    IF de-val-diferim <> 0 THEN 
                        assign lDifPr = YES.
                end.
            end.
        end.
        IF  NOT AVAIL ITEM 
        OR  ITEM.it-codigo <> it-doc-fisc.it-codigo THEN
            for first item
                where item.it-codigo = it-doc-fisc.it-codigo NO-LOCK: 
            end.
        &IF "{&bf_dis_versao_ems}":U >= "2.09":U &THEN
            assign iCodOrig = IF  it-doc-fisc.num-origem <> ? THEN  
                                  it-doc-fisc.num-origem.  
                              ELSE 
                                  ITEM.codigo-orig.
        &ELSE
            IF  SUBstring(it-doc-fisc.char-2,228,3) <> "" THEN
                assign iCodOrig = INT(SUBstring(it-doc-fisc.char-2,228,3)).
            ELSE
                assign iCodOrig = ITEM.codigo-orig.
        &endIF

        assign piCodigo = (IF iCodOrig <= 0 
                           OR ( AVAIL tt-dwf-docto
                                and LOOKUP(tt-dwf-docto.cod-model-docto ,"07,08,8B,09,10,11,26,27,57") > 0)
                           THEN 000 
                           ELSE (iCodOrig * 100)) +  
                          (     IF AVAIL b-it-nota-fisc   and  b-it-nota-fisc.vl-icmsub-it > 0 and {&log-icms-substto-antecip}                           THEN 60 
                           ELSE IF  natur-oper.ind-entfut and deVlIcmsIte3 > 0                                                                           THEN 90
                           ELSE IF  natur-oper.ind-it-sub-dif                                                                                            THEN 50
                           ELSE IF  iCdTribIcm = 1                                                                                                      
                                and lIndIcmRet /* Retem ICMS Fonte */                                                                                   
                                and (   it-doc-fisc.vl-bsubs-it  > 0                                                                                    
                                     OR it-doc-fisc.vl-icmsub-it > 0                                                                                    
                                     &IF "{&bf_dis_versao_ems}"      < "2.06" &THEN                                                                          
                                         &IF "{&bf_dis_versao_ems}" >= "2.04" &THEN                                                                     
                                             OR it-doc-fisc.dec-2               > 0                                                                     
                                         &endIF                                                                                                         
                                     &ELSE                                                                                                              
                                             OR it-doc-fisc.val-icms-subst-entr > 0                                                                     
                                     &endIF)                                                                                                            
                                /* Situacao inserida pois existem casos, onde por possuir aliquotas iguais o valor do ICMS ST n’oý gravado em OF       
                                   Mas a nota possui as parametriza¯´es abaixo, onde indica que o CST deve ser 10 */                                                                                                             
                                OR (   natur-oper.subs-trib /* Substitui¯Êo tribut˜ria */                                                               
                                    and iCdTribIcm = 1      /* ICMS Tributado          */                                                               
                                    and lIndIcmRet)         /* Retem ICMS Fonte        */                                                                THEN 10
                           ELSE IF  natur-oper.ind-it-sub-dif = ? /* CD0606 - Item ICMS Diferido */                                                      
                                OR  lDifPr                    = YES                                                                                      THEN 51
                           /* Tambem se baseia no val icms subst entrada pra atribuir a cst */                                                           
                           ELSE IF  natur-oper.ind-it-icms and it-doc-fisc.vl-icmsub-it = 0 and it-doc-fisc.vl-bsubs-it = 0                              
                                &IF "{&bf_dis_versao_ems}"      < "2.06" &THEN                                                                           
                                    &IF "{&bf_dis_versao_ems}" >= "2.04" &THEN                                                                           
                                        and it-doc-fisc.dec-2               = 0                                                                          
                                    &endIF                                                                                                               
                                &ELSE                                                                                                                    
                                        and it-doc-fisc.val-icms-subst-entr = 0                                                                          
                                &endIF                                                                                                                   THEN 60
                           ELSE IF  iCdTribIcm = 1 and it-doc-fisc.aliquota-icm = 0                                                                      THEN 90
                           ELSE IF  iCdTribIcm = 1 and it-doc-fisc.vl-icms-it   > 0 and lDifPr = NO                                                      THEN 00
                           ELSE IF  iCdTribIcm = 1 and it-doc-fisc.vl-icms-it   > 0 and lDifPr = YES                                                     THEN 90 
			               /* Existem casos onde o valor do item ý igual a um centavo, e nÊo possui valor de icms. Estavamos gerando CST90 sendo correto CST00 */                           
                           ELSE IF  iCdTribIcm = 1 and it-doc-fisc.vl-bicms-it  > 0                                                                      THEN 00
                           ELSE IF  iCdTribIcm = 4 and lIndIcmRet     and deVlIcmRed > 0 and it-doc-fisc.aliquota-icm > 0 and it-doc-fisc.vl-icms-it > 0 THEN 70
                           ELSE IF  iCdTribIcm = 4 and deVlIcmRed = 0                    and it-doc-fisc.aliquota-icm > 0 and it-doc-fisc.vl-icms-it > 0 THEN 00
                           ELSE IF  iCdTribIcm = 4 and NOT lIndIcmRet and deVlIcmRed > 0 and it-doc-fisc.aliquota-icm > 0                                THEN 20
                           ELSE IF  iCdTribIcm = 2 and lIndIcmRet                                                                                        THEN 30
                           ELSE IF  iCdTribIcm = 2                                                                                                       THEN 40 + iTipoVat
                                                                                                                                                         ELSE 90).
    end.
end.
*/


PROCEDURE atualizaModelo59 :
    DEF input PARAM c-cod-estabel-ini like tt-param.c-estab-ini no-undo.
    DEF input PARAM c-cod-estabel-fim like tt-param.c-estab-fim no-undo.
    DEF input PARAM Dt-ini            like tt-param.dt-trans-ini no-undo.
    DEF input PARAM dt-fim            like tt-param.dt-trans-fim no-undo.
    
    /*PUT "atualizaModelo59" SKIP.*/
    {intprg/int031a.i}
end PROCEDURE .
        
        
/*OUTPUT CLOSE.*/
