/********************************************************************************
**
** Programa: int023 - Exportaá∆o de Dados Tributarios Legado
**
** Versao..: 12 - 18/04/2016 - Alessandro V Baccin
**
********************************************************************************/
/* include de controle de vers∆o */
{include/i-prgvrs.i INT023RP 2.12.01.AVB}

def new global shared var c-seg-usuario as char no-undo.

/* definiá∆o das temp-tables para recebimento de parÉmetros */
define temp-table tt-param no-undo
    field destino          as integer
    field arquivo          as char format "x(35)"
    field usuario          as char format "x(12)"
    field data-exec        as date
    field hora-exec        as integer
    field classifica       as integer
    field desc-classifica  as char format "x(40)".

def temp-table tt-raw-digita
    	field raw-digita	as raw.

/* recebimento de parÉmetros */
def input parameter raw-param as raw no-undo.
def input parameter table for tt-raw-digita.
create tt-param.
raw-transfer raw-param to tt-param NO-ERROR.
IF tt-param.arquivo = "" THEN 
   ASSIGN tt-param.arquivo = "INT023.txt"
          tt-param.destino = 3
          tt-param.data-exec = TODAY
          tt-param.hora-exec = TIME.

/* include padr∆o para vari†veis de relat¢rio  */
{include/i-rpvar.i}

/* definiá∆o de vari†veis  */
def var h-acomp as handle no-undo.
def var l-sub as logical no-undo.
def var c-pis as character no-undo.
def var c-cofins as character no-undo.
DEF VAR i-cont AS INT FORMAT ">,>>>,>>9" NO-UNDO.
DEF VAR l-item-uf AS LOGICAL NO-UNDO.
DEF VAR i-cst AS INT NO-UNDO.
DEF VAR de-aliquota-estadual AS DEC NO-UNDO.

define buffer bunid-feder for unid-feder.
define buffer bitem for item.

/* definiá∆o de frames do relat¢rio */

form
  with frame f-rel down stream-io width 300.

IF tt-param.arquivo <> "" THEN DO:
    /* include padr∆o para output de relat¢rios */
    {include/i-rpout.i /*&STREAM="stream str-rp"*/}
END.
/* include com a definiá∆o da frame de cabeáalho e rodapÇ */
{include/i-rpcab.i /*&STREAM="str-rp"*/}

for first param-global fields (empresa-prin) no-lock: end.
for first mguni.empresa fields (razao-social) no-lock where
    empresa.ep-codigo = param-global.empresa-prin : end.

/* bloco principal do programa */
assign  c-programa 	    = "INT023RP"
	    c-versao	    = "2.12"
	    c-revisao	    = ".01.AVB"
        c-empresa       = mguni.empresa.razao-social
	    c-sistema	    = "Faturamento"
	    c-titulo-relat  = "Integraá∆o Dados Fiscais - Tutorial/PRS".

IF tt-param.arquivo <> "" THEN DO:
    view /*stream str-rp*/ frame f-cabec.
    view /*stream str-rp*/ frame f-rodape.
END.

run utp/ut-acomp.p persistent set h-acomp.
run pi-inicializar in h-acomp (input "Imprimindo").

ASSIGN i-cont = 0.

for each classif-fisc NO-LOCK WHERE
         classif-fisc.class-fiscal <> "" ,
    first ITEM no-lock where 
    ITEM.class-fiscal = classif-fisc.class-fiscal AND
    ITEM.ge-codigo <> 40 AND item.ge-codigo < 80 AND ITEM.it-codigo = "8304"
    on stop undo, leave:

    ASSIGN i-cont = i-cont + 1.

    run pi-acompanhar in h-acomp (input "Class. Fisc.: " + classif-fisc.class-fiscal + " - " + string(i-cont)).

    for each estabelec fields (cod-estabel estado pais) no-lock where
             estabelec.estado = "PR"
        break by estabelec.estado:

        if first-of(estabelec.estado) then do:
           for each unid-feder no-lock where 
                    unid-feder.pais   = estabelec.pais and
                    unid-feder.estado = estabelec.estado:

               for each bitem no-lock where 
                        bitem.class-fiscal = item.class-fiscal AND bITEM.ge-codigo <> 40 AND bitem.ge-codigo < 80 AND bitem.it-codigo = "8304":
                   
                   IF int(bITEM.fm-codigo) > 800 THEN NEXT.

                   ASSIGN l-item-uf = NO.

                   for each item-uf no-lock where 
                            item-uf.pais      = unid-feder.pais and
                            item-uf.it-codigo = bitem.it-codigo:

                       ASSIGN l-item-uf = YES.

                       run pi-acompanhar in h-acomp (input "Item: " + item-uf.it-codigo + " Origem: " + item-uf.cod-estado-orig + " Destino: " + item-uf.estado).
                       
                       RUN pi-cria-int-ds(item-uf.estado, 
                                          unid-feder.per-icms-ext,
                                          unid-feder.desc-icms,
                                          item-uf.it-codigo).
                   end.                    

                   IF l-item-uf = NO THEN DO:
                      for each bunid-feder where 
                               bunid-feder.pais = "Brasil" AND 
                               (bunid-feder.estado = "PR" OR bunid-feder.estado = "SC" OR bunid-feder.estado = "SP") NO-LOCK: 

                          for first int-ds-tp-natur-oper where
                                    int-ds-tp-natur-oper.tp-pedido    = "99"     and
                                    int-ds-tp-natur-oper.uf-origem    = "PR"     and 
                                    int-ds-tp-natur-oper.uf-destino   = bunid-feder.estado and 
                                    int-ds-tp-natur-oper.class-fiscal = classif-fisc.class-fiscal no-lock:
                          end.

                          ASSIGN i-cst                = 0
                                 de-aliquota-estadual = 0.

                          if avail int-ds-tp-natur-oper then do:
                             assign i-cst = int-ds-tp-natur-oper.cst-icms.  
                          end.
                          else do:
                             for first int-ds-tp-natur-oper where
                                       int-ds-tp-natur-oper.tp-pedido    = "99"     and
                                       int-ds-tp-natur-oper.uf-origem    = "PR"     and 
                                       int-ds-tp-natur-oper.uf-destino   = bunid-feder.estado and 
                                       int-ds-tp-natur-oper.class-fiscal = ? no-lock:
                             end.
                             if avail int-ds-tp-natur-oper then do:
                                assign i-cst = int-ds-tp-natur-oper.cst-icms.  
                             end.
                          end.

                          ASSIGN de-aliquota-estadual = bunid-feder.pc-icms-st.
                          if i-cst = 10 or
                             i-cst = 30 or
                             i-cst = 40 or
                             i-cst = 41 or
                             i-cst = 50 or
                             i-cst = 60 or
                             i-cst = 90 then de-aliquota-estadual = 0.

                          IF (i-cst = 00 OR i-cst = 20 OR i-cst = 51) AND de-aliquota-estadual = 0 THEN DO:
                             RUN intprg/int999.p (INPUT "FISC", 
                                                  INPUT "Erro CST x Al°quota Estadual",
                                                  INPUT "Item: " + string(bitem.it-codigo) + " UF: " + string(bunid-feder.estado) + " Class. Fisc.: " + STRING(classif-fisc.class-fiscal) + 
                                                        " CST: " + STRING(i-cst,"99") + " Aliq. Est.: " + string(de-aliquota-estadual) + ". Para CST igual a 00, 20 ou 51 a Al°quota Estadual n∆o pode ser zero",
                                                  INPUT 1, /* 1 - Pendente */
                                                  INPUT c-seg-usuario).           
                             NEXT.
                          END.

                          IF i-cst <> 00 AND i-cst <> 20 AND i-cst <> 51 AND de-aliquota-estadual <> 0 THEN  DO:
                             RUN intprg/int999.p (INPUT "FISC", 
                                                  INPUT "Erro CST x Al°quota Estadual",
                                                  INPUT "Item: " + string(bitem.it-codigo) + " UF: " + string(bunid-feder.estado) + " Class. Fisc.: " + STRING(classif-fisc.class-fiscal) + 
                                                        " CST: " + STRING(i-cst,"99") + " Aliq. Est.: " + string(de-aliquota-estadual) + ". Para CST diferente de 00, 20 e 51 a Al°quota Estadual deve ser zero",
                                                  INPUT 1, /* 1 - Pendente */
                                                  INPUT c-seg-usuario).           
                            NEXT.
                          END.

                          FOR FIRST int-ds-ncm-produto WHERE 
                                    int-ds-ncm-produto.ncm     = bitem.class-fiscal AND
                                    int-ds-ncm-produto.estado  = bunid-feder.estado AND
                                    int-ds-ncm-produto.produto = int(bitem.it-codigo):
                          END.
                          IF NOT AVAIL int-ds-ncm-produto THEN DO:
                             CREATE int-ds-ncm-produto.
                             ASSIGN int-ds-ncm-produto.ncm                    = bitem.class-fiscal 
                                    int-ds-ncm-produto.estado                 = bunid-feder.estado 
                                    int-ds-ncm-produto.produto                = int(bitem.it-codigo)
                                    int-ds-ncm-produto.utiliza_mva_ajustada   = "N"
                                    int-ds-ncm-produto.icms_entrada_st        = 0
                                    int-ds-ncm-produto.icms_saida_st          = 0
                                    int-ds-ncm-produto.aliquota_estadual      = de-aliquota-estadual
                                    int-ds-ncm-produto.aliquota_interestadual = bunid-feder.per-icms-ext
                                    int-ds-ncm-produto.redutor_aliquota_st    = IF bunid-feder.estado = "PR" THEN 33.33 ELSE 0
                                    int-ds-ncm-produto.data_registro          = today
                                    int-ds-ncm-produto.data_vigencia          = today
                                    int-ds-ncm-produto.descricao              = classif-fisc.descricao
                                    int-ds-ncm-produto.dt-geracao             = today
                                    int-ds-ncm-produto.hr-geracao             = string(time,"HH:MM:SS")
                                    int-ds-ncm-produto.situacao               = 9.                                    
                          END.
                             
                          for first int-ds-tp-natur-oper where
                                    int-ds-tp-natur-oper.tp-pedido    = "99"     and
                                    int-ds-tp-natur-oper.uf-origem    = "PR"     and 
                                    int-ds-tp-natur-oper.uf-destino   = bunid-feder.estado and 
                                    int-ds-tp-natur-oper.class-fiscal = classif-fisc.class-fiscal no-lock:
                          end.

                          if avail int-ds-tp-natur-oper then do:
                             assign int-ds-ncm-produto.cst = int-ds-tp-natur-oper.cst-icms.  
                          end.
                          else do:
                             for first int-ds-tp-natur-oper where
                                       int-ds-tp-natur-oper.tp-pedido    = "99"     and
                                       int-ds-tp-natur-oper.uf-origem    = "PR"     and 
                                       int-ds-tp-natur-oper.uf-destino   = bunid-feder.estado and 
                                       int-ds-tp-natur-oper.class-fiscal = ? no-lock:
                             end.
                             if avail int-ds-tp-natur-oper then do:
                                assign int-ds-ncm-produto.cst = int-ds-tp-natur-oper.cst-icms.  
                             end.
                          end.

                          ASSIGN c-pis    = if (classif-fisc.dec-1 = 0) then "S" else "N"
                                 c-cofins = if (classif-fisc.dec-2 = 0) then "S" else "N".

                          if int-ds-ncm-produto.descricao         <> classif-fisc.descricao or
                             int-ds-ncm-produto.valor_ipi_ncm     <> classif-fisc.aliquota-ipi or
                             int-ds-ncm-produto.valor_ipi_produto <> bitem.aliquota-ipi OR
                             int-ds-ncm-produto.tributa_pis       <> c-pis or
                             int-ds-ncm-produto.tributa_cofins    <> c-cofins then do:
                             assign int-ds-ncm-produto.data_registro     = today
                                    int-ds-ncm-produto.data_vigencia     = today
                                    int-ds-ncm-produto.descricao         = classif-fisc.descricao
                                    int-ds-ncm-produto.valor_ipi_ncm     = classif-fisc.aliquota-ipi
                                    int-ds-ncm-produto.valor_ipi_produto = bitem.aliquota-ipi 
                                    int-ds-ncm-produto.tributa_pis       = c-pis
                                    int-ds-ncm-produto.tributa_cofins    = c-cofins
                                    int-ds-ncm-produto.dt-geracao        = today
                                    int-ds-ncm-produto.hr-geracao        = string(time,"HH:MM:SS")
                                    int-ds-ncm-produto.situacao          = 9.
                          end.

                          for last sit-tribut-relacto no-lock where 
                                   sit-tribut-relacto.cdn-tribut    = 11 and
                                   sit-tribut-relacto.cod-estab     = estabelec.cod-estabel and
                                   sit-tribut-relacto.cod-livre-1   begins bunid-feder.estado and
                                   sit-tribut-relacto.cod-ncm       = classif-fisc.class-fiscal and
                                   sit-tribut-relacto.idi-tip-docto =  1: 
                          end.
                          if not avail sit-tribut-relacto THEN DO: 
                             for last sit-tribut-relacto no-lock where 
                                      sit-tribut-relacto.cdn-tribut    = 11 and
                                      sit-tribut-relacto.cod-estab     = "*" and
                                      sit-tribut-relacto.cod-livre-1   begins bunid-feder.estado and
                                      sit-tribut-relacto.cod-ncm       = classif-fisc.class-fiscal and
                                      sit-tribut-relacto.idi-tip-docto =  1: 
                             end.
                             if not avail sit-tribut-relacto THEN DO: 
                                for last sit-tribut-relacto no-lock where 
                                         sit-tribut-relacto.cdn-tribut    = 11 and
                                         sit-tribut-relacto.cod-estab     = "*" and
                                         sit-tribut-relacto.cod-livre-1   = "*" and
                                         sit-tribut-relacto.cod-ncm       = classif-fisc.class-fiscal and
                                         sit-tribut-relacto.idi-tip-docto =  1: 
                                end.
                             END.
                          END.
                          if  avail sit-tribut-relacto 
                          AND int-ds-ncm-produto.cest <> trim(string(sit-tribut-relacto.cdn-sit-tribut)) then do:
                              assign int-ds-ncm-produto.cest = trim(string(sit-tribut-relacto.cdn-sit-tribut))
                                     int-ds-ncm-produto.situacao = 9.
                              if int-ds-ncm-produto.data_vigencia < sit-tribut-relacto.dat-valid-inic then
                                 ASSIGN int-ds-ncm-produto.data_vigencia = sit-tribut-relacto.dat-valid-inic.
                          end.

                          IF int-ds-ncm-produto.utiliza_mva_ajustada = "S" THEN
                             ASSIGN int-ds-ncm-produto.utiliza_mva_ajustada = "N"
                                    int-ds-ncm-produto.situacao             = 9.

                          IF int-ds-ncm-produto.icms_entrada_st <> 0 THEN
                             ASSIGN int-ds-ncm-produto.icms_entrada_st = 0 
                                    int-ds-ncm-produto.situacao        = 9.

                          IF int-ds-ncm-produto.icms_saida_st <> 0 THEN
                             ASSIGN int-ds-ncm-produto.icms_saida_st = 0
                                    int-ds-ncm-produto.situacao      = 9.

                          IF int-ds-ncm-produto.aliquota_estadual <> de-aliquota-estadual THEN
                             ASSIGN int-ds-ncm-produto.aliquota_estadual = de-aliquota-estadual
                                    int-ds-ncm-produto.situacao          = 9.

                          IF int-ds-ncm-produto.aliquota_interestadual <> bunid-feder.per-icms-ext THEN
                             ASSIGN int-ds-ncm-produto.aliquota_interestadual = bunid-feder.per-icms-ext
                                    int-ds-ncm-produto.situacao               = 9.
                         
                          IF int-ds-ncm-produto.estado = "PR" THEN DO:
                             IF int-ds-ncm-produto.redutor_aliquota_st <> 33.33 THEN
                                ASSIGN int-ds-ncm-produto.redutor_aliquota_st = 33.33
                                       int-ds-ncm-produto.situacao            = 9.
                          END.
                      END.
                   END.
               end. /* bitem */
            END.
        end. /* FIRS-OF */
    end. /* estabelec */
end. /* classif-fisc */

FOR EACH int-ds-ncm-produto USE-INDEX situacao WHERE
         int-ds-ncm-produto.situacao = 9:
    ASSIGN int-ds-ncm-produto.situacao = 1.
END.

IF tt-param.arquivo <> "" THEN DO:
    /* fechamento do output do relat¢rio  */
    {include/i-rpclo.i /*&STREAM="stream str-rp"*/}
END.
run pi-finalizar in h-acomp.
return "OK":U.

procedure pi-cria-int-ds:
    define input parameter p-estado as char no-undo.
    define input parameter p-per-icms-ext as decimal no-undo.
    define input parameter p-perc-exc as decimal no-undo.
    define input parameter p-it-codigo as char no-undo.

    def var c-natur         like ped-venda.nat-operacao no-undo.
    def var i-cod-cond-pag  as integer no-undo.
    def var i-cod-portador  as integer no-undo.
    def var i-modalidade    as integer no-undo.
    def var c-serie         as char no-undo.
    def var r-rowid         as rowid no-undo.
    def var c-tp-pedido     as character no-undo.

    for first bunid-feder no-lock where 
              bunid-feder.pais   = estabelec.pais and
              bunid-feder.estado = p-estado: 
    end.
    
    ASSIGN i-cst                = 0
           de-aliquota-estadual = 0.

    for first int-ds-tp-natur-oper where
              int-ds-tp-natur-oper.tp-pedido    = "99"     and
              int-ds-tp-natur-oper.uf-origem    = "PR"     and 
              int-ds-tp-natur-oper.uf-destino   = p-estado and 
              int-ds-tp-natur-oper.class-fiscal = classif-fisc.class-fiscal no-lock:
    end.
    
    if avail int-ds-tp-natur-oper then do:
       assign i-cst = int-ds-tp-natur-oper.cst-icms.  
    end.
    else do:
       for first int-ds-tp-natur-oper where
                 int-ds-tp-natur-oper.tp-pedido    = "99"     and
                 int-ds-tp-natur-oper.uf-origem    = "PR"     and 
                 int-ds-tp-natur-oper.uf-destino   = p-estado and 
                 int-ds-tp-natur-oper.class-fiscal = ? no-lock:
       end.
       if avail int-ds-tp-natur-oper then do:
          assign i-cst = int-ds-tp-natur-oper.cst-icms.  
       end.
    end.

    ASSIGN de-aliquota-estadual = bunid-feder.pc-icms-st.
    if i-cst = 10 or
       i-cst = 30 or
       i-cst = 40 or
       i-cst = 41 or
       i-cst = 50 or
       i-cst = 60 or
       i-cst = 90 then de-aliquota-estadual = 0.

    IF (i-cst = 00 OR i-cst = 20 OR i-cst = 51) AND de-aliquota-estadual = 0 THEN DO:
       RUN intprg/int999.p (INPUT "FISC", 
                            INPUT "Erro CST x Al°quota Estadual",
                            INPUT "Item: " + string(p-it-codigo) + " UF: " + string(p-estado) + " Class. Fisc.: " + STRING(classif-fisc.class-fiscal) + 
                                  " CST: " + STRING(i-cst,"99") + " Aliq. Est.: " + string(de-aliquota-estadual) + ". Para CST igual a 00, 20 ou 51 a Al°quota Estadual n∆o pode ser zero",
                            INPUT 1, /* 1 - Pendente */
                            INPUT c-seg-usuario).           
       NEXT.
    END.

    IF i-cst <> 00 AND i-cst <> 20 AND i-cst <> 51 AND de-aliquota-estadual <> 0 THEN  DO:
       RUN intprg/int999.p (INPUT "FISC", 
                            INPUT "Erro CST x Al°quota Estadual",
                            INPUT "Item: " + string(p-it-codigo) + " UF: " + string(p-estado) + " Class. Fisc.: " + STRING(classif-fisc.class-fiscal) + 
                                  " CST: " + STRING(i-cst,"99") + " Aliq. Est.: " + string(de-aliquota-estadual) + ". Para CST diferente de 00, 20 e 51 a Al°quota Estadual deve ser zero",
                            INPUT 1, /* 1 - Pendente */
                            INPUT c-seg-usuario).           
       NEXT.
    END.

    for first int-ds-ncm-produto where 
              int-ds-ncm-produto.ncm     = classif-fisc.class-fiscal and
              int-ds-ncm-produto.estado  = p-estado and
              int-ds-ncm-produto.produto = int(p-it-codigo): 
    end.
    
    if not avail int-ds-ncm-produto then do:
       create int-ds-ncm-produto.
       assign int-ds-ncm-produto.ncm     = classif-fisc.class-fiscal 
              int-ds-ncm-produto.estado  = p-estado
              int-ds-ncm-produto.produto = int(p-it-codigo).
    end.
            
    for first int-ds-tp-natur-oper where
              int-ds-tp-natur-oper.tp-pedido    = "99"     and
              int-ds-tp-natur-oper.uf-origem    = "PR"     and 
              int-ds-tp-natur-oper.uf-destino   = p-estado and 
              int-ds-tp-natur-oper.class-fiscal = classif-fisc.class-fiscal no-lock:
    end.
    
    if avail int-ds-tp-natur-oper then do:
       assign int-ds-ncm-produto.cst = int-ds-tp-natur-oper.cst-icms.  
    end.
    else do:
       for first int-ds-tp-natur-oper where
                 int-ds-tp-natur-oper.tp-pedido    = "99"     and
                 int-ds-tp-natur-oper.uf-origem    = "PR"     and 
                 int-ds-tp-natur-oper.uf-destino   = p-estado and 
                 int-ds-tp-natur-oper.class-fiscal = ? no-lock:
       end.
       if avail int-ds-tp-natur-oper then do:
          assign int-ds-ncm-produto.cst = int-ds-tp-natur-oper.cst-icms.  
       end.
    end.

    ASSIGN c-pis    = if (classif-fisc.dec-1 = 0) then "S" else "N"
           c-cofins = if (classif-fisc.dec-2 = 0) then "S" else "N".

    if int-ds-ncm-produto.descricao         <> classif-fisc.descricao or
       int-ds-ncm-produto.valor_ipi_ncm     <> classif-fisc.aliquota-ipi or
       int-ds-ncm-produto.valor_ipi_produto <> bitem.aliquota-ipi OR
       int-ds-ncm-produto.tributa_pis       <> c-pis or
       int-ds-ncm-produto.tributa_cofins    <> c-cofins then do:
       assign int-ds-ncm-produto.data_registro     = today
              int-ds-ncm-produto.data_vigencia     = today
              int-ds-ncm-produto.descricao         = classif-fisc.descricao
              int-ds-ncm-produto.valor_ipi_ncm     = classif-fisc.aliquota-ipi
              int-ds-ncm-produto.valor_ipi_produto = bitem.aliquota-ipi 
              int-ds-ncm-produto.tributa_pis       = c-pis
              int-ds-ncm-produto.tributa_cofins    = c-cofins
              int-ds-ncm-produto.dt-geracao        = today
              int-ds-ncm-produto.hr-geracao        = string(time,"HH:MM:SS")
              int-ds-ncm-produto.situacao          = 9.
    end.

    for last sit-tribut-relacto no-lock where 
             sit-tribut-relacto.cdn-tribut    = 11 and
             sit-tribut-relacto.cod-estab     = estabelec.cod-estabel and
             sit-tribut-relacto.cod-livre-1   begins p-estado and
             sit-tribut-relacto.cod-ncm       = classif-fisc.class-fiscal and
             sit-tribut-relacto.idi-tip-docto =  1: 
    end.
    if not avail sit-tribut-relacto THEN DO: 
       for last sit-tribut-relacto no-lock where 
                sit-tribut-relacto.cdn-tribut    = 11 and
                sit-tribut-relacto.cod-estab     = "*" and
                sit-tribut-relacto.cod-livre-1   begins p-estado and
                sit-tribut-relacto.cod-ncm       = classif-fisc.class-fiscal and
                sit-tribut-relacto.idi-tip-docto =  1: 
       end.
       if not avail sit-tribut-relacto THEN DO: 
          for last sit-tribut-relacto no-lock where 
                   sit-tribut-relacto.cdn-tribut    = 11 and
                   sit-tribut-relacto.cod-estab     = "*" and
                   sit-tribut-relacto.cod-livre-1   = "*" and
                   sit-tribut-relacto.cod-ncm       = classif-fisc.class-fiscal and
                   sit-tribut-relacto.idi-tip-docto =  1: 
          end.
       END.
    END.
    if  avail sit-tribut-relacto 
    AND int-ds-ncm-produto.cest <> trim(string(sit-tribut-relacto.cdn-sit-tribut)) then do:
        assign int-ds-ncm-produto.cest = trim(string(sit-tribut-relacto.cdn-sit-tribut))
               int-ds-ncm-produto.situacao = 9.
        if int-ds-ncm-produto.data_vigencia < sit-tribut-relacto.dat-valid-inic then
           ASSIGN int-ds-ncm-produto.data_vigencia = sit-tribut-relacto.dat-valid-inic.
    end.
    if int-ds-ncm-produto.aliquota_estadual <> de-aliquota-estadual or
       (unid-feder.possui-subst-trib = yes and int-ds-ncm-produto.utiliza_pauta_fiscal <> "S") or
       (unid-feder.possui-subst-trib = no  and int-ds-ncm-produto.utiliza_pauta_fiscal <> "N") or
       (unid-feder.possui-subst-trib = yes and int-ds-ncm-produto.utiliza_mva_ajustada <> "N") or
       (unid-feder.possui-subst-trib = no  and int-ds-ncm-produto.utiliza_mva_ajustada <> "S") then do:

       assign int-ds-ncm-produto.aliquota_estadual     = de-aliquota-estadual
              int-ds-ncm-produto.redutor_estadual      = 0
              int-ds-ncm-produto.redutor_interestadual = 0
              int-ds-ncm-produto.situacao = 9.

       IF  int-ds-ncm-produto.cst <> 00 
       AND int-ds-ncm-produto.cst <> 20 
       AND int-ds-ncm-produto.cst <> 51 THEN
           ASSIGN int-ds-ncm-produto.aliquota_estadual = 0.

        assign int-ds-ncm-produto.utiliza_pauta_fiscal = "N"
               int-ds-ncm-produto.utiliza_mva_ajustada = "S".
        if int-ds-ncm-produto.data_vigencia < today then 
           ASSIGN int-ds-ncm-produto.data_vigencia = today.
    end.
    if p-it-codigo <> "" then do:
       for each preco-item no-lock where 
                preco-item.nr-tabpre  = unid-feder.nr-tb-pauta and
                preco-item.dt-inival <= today and
                preco-item.it-codigo  = p-it-codigo
           break by preco-item.it-codigo
                 by preco-item.dt-inival:
           if  last-of(preco-item.dt-inival) 
           and (int-ds-ncm-produto.valor_pauta_fiscal <> preco-item.preco-venda or
               int-ds-ncm-produto.utiliza_pauta_fiscal = "S" or
               int-ds-ncm-produto.utiliza_mva_ajustada = "N") then do:
               assign int-ds-ncm-produto.valor_pauta_fiscal   = preco-item.preco-venda
                      int-ds-ncm-produto.utiliza_pauta_fiscal = "S"
                      int-ds-ncm-produto.utiliza_mva_ajustada = "N"
                      int-ds-ncm-produto.situacao = 9.
           end.
       end.

       IF AVAIL bitem THEN DO:
          IF item-uf.estado = "PR" THEN DO:
              IF int-ds-ncm-produto.aliquota_interestadual <> bunid-feder.per-icms-ext THEN DO: 
                 assign int-ds-ncm-produto.aliquota_interestadual = bunid-feder.per-icms-ext
                        int-ds-ncm-produto.situacao = 9.
              END.
          END.
          ELSE DO:
              IF bitem.fm-codigo = "100" 
              OR bitem.fm-codigo = "105"
              OR bitem.fm-codigo = "200"
              OR bitem.fm-codigo = "400"
              OR bitem.fm-codigo = "401"
              OR bitem.fm-codigo = "403"
              OR bitem.fm-codigo = "404"
              OR bitem.fm-codigo = "405"
              OR bitem.fm-codigo = "406"
              OR bitem.fm-codigo = "407"
              OR bitem.fm-codigo = "408"
              OR bitem.fm-codigo = "409"
              OR bitem.fm-codigo = "410"
              OR bitem.fm-codigo = "411"
              OR bitem.fm-codigo = "412"
              OR bitem.fm-codigo = "413" THEN DO:
                 IF int-ds-ncm-produto.icms_entrada_st <> 12 
                 OR int-ds-ncm-produto.aliquota_interestadual <> 12 then do:
                    if int-ds-ncm-produto.data_vigencia < today then 
                       ASSIGN int-ds-ncm-produto.data_vigencia = today.              
                    assign int-ds-ncm-produto.icms_entrada_st        = 12
                           int-ds-ncm-produto.aliquota_interestadual = 12
                           int-ds-ncm-produto.situacao = 9.
                 end.
              END.
              ELSE DO:
                  IF int-ds-ncm-produto.icms_entrada_st <> bunid-feder.per-icms-ext 
                  OR int-ds-ncm-produto.aliquota_interestadual <> bunid-feder.per-icms-ext then 
                     assign int-ds-ncm-produto.icms_entrada_st        = bunid-feder.per-icms-ext
                            int-ds-ncm-produto.aliquota_interestadual = bunid-feder.per-icms-ext
                            int-ds-ncm-produto.situacao = 9.
              END.
           
              IF bitem.fm-codigo = "101" 
              OR bitem.fm-codigo = "201"
              OR bitem.fm-codigo = "300"
              OR bitem.fm-codigo = "301"
              OR bitem.fm-codigo = "302"
              OR bitem.fm-codigo = "303"
              OR bitem.fm-codigo = "304"
              OR bitem.fm-codigo = "305"
              OR bitem.fm-codigo = "306"
              OR bitem.fm-codigo = "307"
              OR bitem.fm-codigo = "308"
              OR bitem.fm-codigo = "309" THEN DO:
                 IF int-ds-ncm-produto.icms_entrada_st <> 4 
                 OR int-ds-ncm-produto.aliquota_interestadual <> 4 then do:
                    if int-ds-ncm-produto.data_vigencia < today then 
                       ASSIGN int-ds-ncm-produto.data_vigencia = today.              
                    assign int-ds-ncm-produto.icms_entrada_st        = 4
                           int-ds-ncm-produto.aliquota_interestadual = 4
                           int-ds-ncm-produto.situacao = 9.
                 end.
              END.
              ELSE DO:
                 IF int-ds-ncm-produto.icms_entrada_st <> bunid-feder.per-icms-ext 
                 OR int-ds-ncm-produto.aliquota_interestadual <> bunid-feder.per-icms-ext then 
                    assign int-ds-ncm-produto.icms_entrada_st        = bunid-feder.per-icms-ext
                           int-ds-ncm-produto.aliquota_interestadual = bunid-feder.per-icms-ext
                           int-ds-ncm-produto.situacao = 9.
              END.
          END.
       END.
       if avail item-uf then do:    
          IF item-uf.cod-estado-orig = item-uf.estado THEN DO:
             IF int-ds-ncm-produto.st_estadual <> item-uf.per-sub-tri THEN
                ASSIGN int-ds-ncm-produto.st_estadual = item-uf.per-sub-tri
                       int-ds-ncm-produto.situacao = 9.
          END.
            
          IF item-uf.cod-estado-orig <> "PR" THEN DO:
             IF item-uf.estado = "PR" THEN DO:
                IF int-ds-ncm-produto.st_interestadual <> item-uf.per-sub-tri THEN DO:
                   ASSIGN int-ds-ncm-produto.st_interestadual = item-uf.per-sub-tri
                          int-ds-ncm-produto.situacao = 9.
                END.
             END.
          END.

          IF item-uf.cod-estado-orig <> "SC" THEN DO:
             IF item-uf.estado = "SC" THEN DO:
                IF int-ds-ncm-produto.st_interestadual <> item-uf.per-sub-tri THEN DO:
                   ASSIGN int-ds-ncm-produto.st_interestadual = item-uf.per-sub-tri
                          int-ds-ncm-produto.situacao = 9.
                END.
             END.
          END.

          IF item-uf.cod-estado-orig <> "SP" THEN DO:
             IF item-uf.estado = "SP" THEN DO:
                IF int-ds-ncm-produto.st_interestadual <> item-uf.per-sub-tri THEN DO:
                   ASSIGN int-ds-ncm-produto.st_interestadual = item-uf.per-sub-tri
                          int-ds-ncm-produto.situacao = 9.
                END.
             END.
          END.

          IF int-ds-ncm-produto.icms_saida_st <> item-uf.dec-1 THEN DO:
             ASSIGN int-ds-ncm-produto.icms_saida_st = item-uf.dec-1
                    int-ds-ncm-produto.situacao = 9.
          END.

          IF item-uf.perc-red-sub <> 0 THEN DO:
             if int-ds-ncm-produto.redutor_base_estado_st <> item-uf.perc-red-sub then do:
                if int-ds-ncm-produto.data_vigencia < today then 
                   ASSIGN int-ds-ncm-produto.data_vigencia = today.
               ASSIGN int-ds-ncm-produto.redutor_base_estado_st = item-uf.perc-red-sub
                      int-ds-ncm-produto.situacao = 9.
             end.
          END.

          IF  item-uf.cod-estado-orig = "PR"
          AND item-uf.estado          = "PR" THEN DO:
              
              ASSIGN int-ds-ncm-produto.icms_entrada_st = item-uf.dec-1.

              IF int-ds-ncm-produto.icms_saida_st = 18 
              OR int-ds-ncm-produto.icms_entrada_st = 18 THEN DO:
                 if int-ds-ncm-produto.redutor_aliquota_st <> 33.33 THEN DO:
                    if int-ds-ncm-produto.data_vigencia < today then 
                       ASSIGN int-ds-ncm-produto.data_vigencia = today.
                    ASSIGN int-ds-ncm-produto.redutor_aliquota_st = 33.33
                           int-ds-ncm-produto.situacao = 9.
                 END.
              END.

              IF int-ds-ncm-produto.icms_saida_st = 25 
              OR int-ds-ncm-produto.icms_entrada_st = 25 THEN DO:
                 if int-ds-ncm-produto.redutor_aliquota_st <> 52 THEN DO:
                    if int-ds-ncm-produto.data_vigencia < today then 
                       ASSIGN int-ds-ncm-produto.data_vigencia = today.
                    ASSIGN int-ds-ncm-produto.redutor_aliquota_st = 52
                           int-ds-ncm-produto.situacao = 9.
                 END.
              END.

              IF int-ds-ncm-produto.icms_saida_st = 12 
              OR int-ds-ncm-produto.icms_entrada_st = 12 THEN DO:
                 if int-ds-ncm-produto.redutor_aliquota_st <> 0 THEN DO:
                    if int-ds-ncm-produto.data_vigencia < today then 
                       ASSIGN int-ds-ncm-produto.data_vigencia = today.
                    ASSIGN int-ds-ncm-produto.redutor_aliquota_st = 0
                           int-ds-ncm-produto.situacao = 9.
                 END.
              END.
              IF int-ds-ncm-produto.redutor_base_estado_st <> 0 THEN DO:
                 IF int-ds-ncm-produto.redutor_aliquota_st <> 0 THEN
                    ASSIGN int-ds-ncm-produto.redutor_aliquota_st = 0
                           int-ds-ncm-produto.situacao = 9.
              END.
          end.
       end.      
    end.
end.


/* Tabela de Equivalància CST Datasul -> CST Sysfarma                            

CST Datasul Descriá∆o                                                                     CST Sysfamra
----------- ----------------------------------------------------------------------------- ------------
00          Tributada integralmente                                                       1
10          Tributada e com cobranáa do ICMS por substituiá∆o tribut†ria                  5
20          Com reduá∆o de base de c†lculo                                                3
30          Isenta ou n∆o tributada e com cobranáa do ICMS por substituiá∆o tribut†ria    5
40          Isenta                                                                        2
41          N∆o tributada                                                                 4
50          Suspens∆o                                                                     4
51          Diferimento                                                                   1
60          ICMS cobrado anteriormente por substituiá∆o tribut†ria                        5
70          Com reduá∆o da base de c†lculo e cobranáa do ICMS por substituiá∆o tribut†ria 5
90          Outras                                                                        4  


CST Sysfarma 1 e 3: Al°quota Estadual deve ser > que 0 - 00, 20, 51

CST Sysfarma 2,4 e 5: Al°quota Estadual deve ser = 0 */



 



