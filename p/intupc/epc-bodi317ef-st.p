DEFINE VARIABLE de-quantidade-aux AS DECIMAL     NO-UNDO.
DEFINE VARIABLE de-qtd-sdo-aux    AS DECIMAL     NO-UNDO.

DEF SHARED TEMP-TABLE tt-item-st-aux NO-UNDO
    FIELD it-codigo     AS CHAR
    FIELD quantidade    AS DEC
    FIELD preco         AS DEC
    FIELD l-item-criado AS LOG
    FIELD r-rowid       AS ROWID.

DEF SHARED TEMP-TABLE tt-item-nfs-ds-retorno NO-UNDO
    FIELD nr-sequencia       AS INT
    FIELD seq-wt-docto       AS INT
    FIELD seq-wt-it-docto    AS INT
    FIELD nsa_cnpj_origem_s  AS CHAR
    FIELD nsa_cnpj_destino_s AS CHAR
    FIELD nsa_notafiscal_n   AS INT
    FIELD nsa_serie_s        AS CHAR
    FIELD ped_codigo_n       AS INT
    FIELD nsp_produto_n      AS INT
    FIELD nsp_lote_s         AS CHAR
    FIELD nsp_caixa_n        AS INT
    FIELD nsp_sequencia_n    AS INT
    FIELD rpp_validade_d     AS DATE
    INDEX id IS PRIMARY seq-wt-docto seq-wt-it-docto
    INDEX seq nr-sequencia.

DEFINE INPUT  PARAMETER p-rowids AS CHARACTER   NO-UNDO.
DEFINE        PARAMETER BUFFER bf-it-nota-fisc FOR it-nota-fisc.

DEF BUFFER bf-natur-oper FOR natur-oper.
DEF BUFFER bf-wt-it-docto FOR wt-it-docto.
DEF BUFFER bf-nota-fiscal FOR nota-fiscal.
.MESSAGE "10" VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
FOR FIRST bf-wt-it-docto NO-LOCK
    WHERE ROWID(bf-wt-it-docto) = TO-ROWID(ENTRY(1,p-rowids,",")):
    .MESSAGE "9" VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
    FIND FIRST nar-it-nota NO-LOCK
            WHERE nar-it-nota.cod-estabel   =  bf-it-nota-fisc.cod-estabel 
              AND nar-it-nota.nr-nota-fis   =  bf-it-nota-fisc.nr-nota-fis
              AND nar-it-nota.serie         =  bf-it-nota-fisc.serie
              AND nar-it-nota.it-codigo     =  bf-it-nota-fisc.it-codigo    
              AND nar-it-nota.nr-sequencia  =  bf-it-nota-fisc.nr-seq-fat NO-ERROR.

        .MESSAGE "1" SKIP
            bf-it-nota-fisc.cod-estabel  skip 
            bf-it-nota-fisc.serie        skip 
            bf-it-nota-fisc.nr-nota-fis  skip 
            bf-it-nota-fisc.nr-seq-fat   skip 
            bf-it-nota-fisc.it-codigo  SKIP
            AVAIL nar-it-nota
            VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
     .MESSAGE "8" VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
     FIND FIRST bf-nota-fiscal NO-LOCK
         WHERE bf-nota-fiscal.cod-estabel = bf-it-nota-fisc.cod-estabel
           AND bf-nota-fiscal.serie       = bf-it-nota-fisc.serie      
           AND bf-nota-fiscal.nr-nota-fis = bf-it-nota-fisc.nr-nota-fis NO-ERROR.

     .MESSAGE bf-it-nota-fisc.nr-pedcli
         VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
         .MESSAGE "7" VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
     FIND FIRST int_ds_pedido NO-LOCK
         WHERE int_ds_pedido.ped_codigo_n = INT(bf-it-nota-fisc.nr-pedcli) NO-ERROR.

    .MESSAGE "6" VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
    FOR FIRST int_ds_nota_saida_relacto EXCLUSIVE-LOCK
        WHERE int_ds_nota_saida_relacto.cod_estabel = bf-it-nota-fisc.cod-estabel
        AND   int_ds_nota_saida_relacto.serie       = bf-it-nota-fisc.serie      
        AND   int_ds_nota_saida_relacto.nr_nota_fis = bf-it-nota-fisc.nr-nota-fis
        AND   int_ds_nota_saida_relacto.nr_seq_fat  = bf-it-nota-fisc.nr-seq-fat 
        AND   int_ds_nota_saida_relacto.it_codigo   = bf-it-nota-fisc.it-codigo: END.
    IF NOT AVAIL int_ds_nota_saida_relacto THEN DO:
        CREATE int_ds_nota_saida_relacto.
        ASSIGN int_ds_nota_saida_relacto.cod_estabel = bf-it-nota-fisc.cod-estabel
               int_ds_nota_saida_relacto.serie       = bf-it-nota-fisc.serie
               int_ds_nota_saida_relacto.nr_nota_fis = bf-it-nota-fisc.nr-nota-fis
               int_ds_nota_saida_relacto.nr_seq_fat  = bf-it-nota-fisc.nr-seq-fat
               int_ds_nota_saida_relacto.it_codigo   = bf-it-nota-fisc.it-codigo.
        
        .MESSAGE "criou especifica"                      skip
                int_ds_nota_saida_relacto.cod_estabel   skip
                int_ds_nota_saida_relacto.serie         skip
                int_ds_nota_saida_relacto.nr_nota_fis   skip
                int_ds_nota_saida_relacto.nr_seq_fat    skip
                int_ds_nota_saida_relacto.it_codigo  
            VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
    END.
    .MESSAGE "5" VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
    FIND FIRST estabelec NO-LOCK
        WHERE estabelec.cod-estabel = bf-it-nota-fisc.cod-estabel NO-ERROR.


    ASSIGN int_ds_nota_saida_relacto.nsa_cnpj_origem_s  = IF AVAIL int_Ds_pedido THEN int_ds_pedido.ped_cnpj_origem_s  ELSE estabelec.cgc
           int_ds_nota_saida_relacto.nsa_cnpj_destino_s = IF AVAIL int_Ds_pedido THEN int_ds_pedido.ped_cnpj_destino_s  ELSE ""
           int_ds_nota_saida_relacto.nsa_notafiscal_n   = INT(bf-it-nota-fisc.nr-nota-fis) 
           int_ds_nota_saida_relacto.nsa_serie_s        = bf-it-nota-fisc.serie       
           int_ds_nota_saida_relacto.ped_codigo_n       = IF AVAIL int_Ds_pedido THEN int_ds_pedido.ped_codigo_n ELSE INT(bf-nota-fiscal.nr-pedcli)  
           int_ds_nota_saida_relacto.nsp_produto_n      = INT(bf-it-nota-fisc.it-codigo)    
           int_ds_nota_saida_relacto.nsp_lote_s         = IF AVAIL nar-it-nota THEN entry(1,SUBSTR(nar-it-nota.narrativa,INDEX(nar-it-nota.narrativa,"LT:") + 4)," ") ELSE ""       
           int_ds_nota_saida_relacto.nsp_caixa_n        = int(bf-it-nota-fisc.nr-seq-ped)      
           int_ds_nota_saida_relacto.nsp_sequencia_n    = INT(bf-it-nota-fisc.nr-seq-fat)  
           int_ds_nota_saida_relacto.rpp_validade_d     = ?   . 
        
    RELEASE int_ds_nota_saida_relacto.

END.

LOG-MANAGER:WRITE-MESSAGE("bf-it-nota-fisc.cod-estabel = " + bf-it-nota-fisc.cod-estabel) NO-ERROR.
LOG-MANAGER:WRITE-MESSAGE("bf-it-nota-fisc.serie       = " + bf-it-nota-fisc.serie      ) NO-ERROR.
LOG-MANAGER:WRITE-MESSAGE("bf-it-nota-fisc.nr-nota-fis = " + bf-it-nota-fisc.nr-nota-fis) NO-ERROR.
LOG-MANAGER:WRITE-MESSAGE("bf-it-nota-fisc.nr-seq-fat  = " + string(bf-it-nota-fisc.nr-seq-fat) ) NO-ERROR.
LOG-MANAGER:WRITE-MESSAGE("bf-it-nota-fisc.it-codigo.  = " + bf-it-nota-fisc.it-codigo  ) NO-ERROR.

    
FOR FIRST item-uf NO-LOCK
    WHERE item-uf.it-codigo = bf-it-nota-fisc.it-codigo,
    FIRST ITEM NO-LOCK
    WHERE ITEM.it-codigo = item-uf.it-codigo,
    FIRST item-uni-estab NO-LOCK
        WHERE item-uni-estab.it-codigo = ITEM.it-codigo
          AND item-uni-estab.cod-estabel = bf-it-nota-fisc.cod-estabel
          AND SUBSTRING(item-uni-estab.char-2,60,1) = "S" ,
    FIRST bf-natur-oper NO-LOCK
    WHERE bf-natur-oper.nat-operacao = bf-it-nota-fisc.nat-operacao:
    
    
    message "entrou regra Regime especial" view-as alert-box.

    LOG-MANAGER:WRITE-MESSAGE("bf-natur-oper.especie-doc  = " + bf-natur-oper.especie-doc  ) NO-ERROR.
    .MESSAGE "3" VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
    IF bf-natur-oper.especie-doc = "NFT" THEN DO:
        ASSIGN de-quantidade-aux = bf-it-nota-fisc.qt-faturada[1].
    
        LOG-MANAGER:WRITE-MESSAGE("de-quantidade-aux  = " + string(de-quantidade-aux)  ) NO-ERROR.
        .MESSAGE "2 bodi" VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
        FOR EACH tt-item-st-aux:
            LOG-MANAGER:WRITE-MESSAGE("tt-item-st-aux") NO-ERROR.
            LOG-MANAGER:WRITE-MESSAGE("tt-item-st-aux.it-codigo   = " + tt-item-st-aux.it-codigo   ) NO-ERROR.
            LOG-MANAGER:WRITE-MESSAGE("tt-item-st-aux.quantidade  = " + string(tt-item-st-aux.quantidade)  ) NO-ERROR.
            LOG-MANAGER:WRITE-MESSAGE("esp-item-entr-st  = " + STRING(CAN-FIND(FIRST esp-item-entr-st NO-LOCK
                                                                               WHERE ROWID(esp-item-entr-st) = tt-item-st-aux.r-rowid))   ) NO-ERROR.
        END.
        
        for each tt-item-st-aux no-lock
            WHERE tt-item-st-aux.it-codigo  = bf-it-nota-fisc.it-codigo:
            
           .message tt-item-st-aux.it-codigo skip tt-item-st-aux.quantidade skip bf-it-nota-fisc.qt-faturada[1] skip "r-rowid " string(tt-item-st-aux.r-rowid) VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
            find FIRST esp-item-entr-st NO-LOCK
            WHERE ROWID(esp-item-entr-st) = tt-item-st-aux.r-rowid no-error.
               .message avail esp-item-entr-st VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
        end.
        
        .MESSAGE "1 bodi" VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
        
        FOR FIRST tt-item-st-aux
            WHERE tt-item-st-aux.it-codigo  = bf-it-nota-fisc.it-codigo
            AND   tt-item-st-aux.quantidade = bf-it-nota-fisc.qt-faturada[1],
            FIRST esp-item-entr-st NO-LOCK
            WHERE ROWID(esp-item-entr-st) = tt-item-st-aux.r-rowid:
            /*esp-item-entr-st.cod-item      = bf-it-nota-fisc.it-codigo
            AND   esp-item-entr-st.qtd-sdo-final > 0:*/
            .MESSAGE "0 bodi" VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
            find first esp-item-nfs-st
                 where esp-item-nfs-st.cod-estab-nfs         = bf-it-nota-fisc.cod-estabel
                   and esp-item-nfs-st.cod-ser-nfs           = bf-it-nota-fisc.serie
                   and esp-item-nfs-st.cod-docto-nfs         = bf-it-nota-fisc.nr-nota-fis
                   and esp-item-nfs-st.cod-item              = bf-it-nota-fisc.it-codigo
                   and esp-item-nfs-st.num-seq-nfs           = bf-it-nota-fisc.nr-seq-fat
                   and esp-item-nfs-st.cod-estab-entr        = esp-item-entr-st.cod-estab
                   and esp-item-nfs-st.cod-ser-entr          = esp-item-entr-st.cod-serie
                   and esp-item-nfs-st.cod-nota-entr         = esp-item-entr-st.cod-docto
                   and esp-item-nfs-st.cod-natur-operac-entr = esp-item-entr-st.cod-natur-operac
                   and esp-item-nfs-st.cod-emitente-entr     = esp-item-entr-st.cod-emitente    
                   and esp-item-nfs-st.num-seq-item-entr     = esp-item-entr-st.num-seq           exclusive-lock no-error.
           
            if  not avail esp-item-nfs-st then do:

                .MESSAGE "3 - criando esp-item-nfs-st" SKIP
                    bf-it-nota-fisc.cod-estabel  skip 
                    bf-it-nota-fisc.serie        skip 
                    bf-it-nota-fisc.nr-nota-fis  skip 
                    bf-it-nota-fisc.nr-seq-fat   skip 
                    bf-it-nota-fisc.it-codigo  SKIP
                    AVAIL nar-it-nota
                    VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
                create esp-item-nfs-st.
                assign esp-item-nfs-st.cod-estab-nfs         = bf-it-nota-fisc.cod-estabel         
                       esp-item-nfs-st.cod-ser-nfs           = bf-it-nota-fisc.serie               
                       esp-item-nfs-st.cod-docto-nfs         = bf-it-nota-fisc.nr-nota-fis         
                       esp-item-nfs-st.cod-item              = bf-it-nota-fisc.it-codigo           
                       esp-item-nfs-st.num-seq-nfs           = bf-it-nota-fisc.nr-seq-fat          
                       esp-item-nfs-st.cod-estab-entr        = esp-item-entr-st.cod-estab       
                       esp-item-nfs-st.cod-ser-entr          = esp-item-entr-st.cod-serie       
                       esp-item-nfs-st.cod-nota-entr         = esp-item-entr-st.cod-docto        
                       esp-item-nfs-st.cod-natur-operac-entr = esp-item-entr-st.cod-natur-operac
                       esp-item-nfs-st.cod-emitente-entr     = esp-item-entr-st.cod-emitente    
                       esp-item-nfs-st.num-seq-item-entr     = esp-item-entr-st.num-seq    no-error.
                       
               
               .MESSAGE "Entrou aqui esp-item-nfs-st " VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
               .message esp-item-nfs-st.cod-estab-nfs        
                       esp-item-nfs-st.cod-ser-nfs          
                       esp-item-nfs-st.cod-docto-nfs        
                       esp-item-nfs-st.cod-item             
                       esp-item-nfs-st.num-seq-nfs          
                       esp-item-nfs-st.cod-estab-entr       
                       esp-item-nfs-st.cod-ser-entr         
                       esp-item-nfs-st.cod-nota-entr        
                       esp-item-nfs-st.cod-natur-operac-entr
                       esp-item-nfs-st.cod-emitente-entr    
                       esp-item-nfs-st.num-seq-item-entr      view-as ALERT-BOX INFORMATION BUTTONS OK.        
                       
            end.
            
            /* quantidade vendida e valores de base e imposto */ 
            assign //de-quantidade-aux                   = de-quantidade-aux - de-qtd-sdo-aux
                   //esp-item-entr-st.qtd-sdo-final      = esp-item-entr-st.qtd-sdo-final - de-qtd-sdo-aux
                   esp-item-nfs-st.qtd-saida           = de-quantidade-aux
                   esp-item-nfs-st.val-base-calc-impto = bf-it-nota-fisc.vl-bsubs-it   //* de-qtd-sdo-aux / bf-it-nota-fisc.qt-faturada[1]
                   esp-item-nfs-st.val-impto           = bf-it-nota-fisc.vl-icmsub-it. //* de-qtd-sdo-aux / bf-it-nota-fisc.qt-faturada[1].
    
            RELEASE esp-item-nfs-st.
            DELETE tt-item-st-aux.
        END.
    END.
    ELSE IF bf-natur-oper.especie-doc = "NFD" THEN DO:
        FOR FIRST bf-nota-fiscal NO-LOCK
            WHERE bf-nota-fiscal.cod-estabel = bf-it-nota-fisc.cod-estabel
            AND   bf-nota-fiscal.serie       = bf-it-nota-fisc.serie      
            AND   bf-nota-fiscal.nr-nota-fis = bf-it-nota-fisc.nr-nota-fis,
            FIRST item-doc-est NO-LOCK
            WHERE item-doc-est.cod-emitente = bf-nota-fiscal.cod-emitente
            AND   item-doc-est.serie-docto  = bf-it-nota-fisc.serie-docum
            AND   item-doc-est.nro-docto    = bf-it-nota-fisc.nr-docum
            AND   item-doc-est.nat-operacao = bf-it-nota-fisc.nat-docum
            AND   item-doc-est.sequencia    = bf-it-nota-fisc.int-1,
            FIRST esp-item-entr-st EXCLUSIVE-LOCK
            WHERE esp-item-entr-st.cod-estab        = item-doc-est.cod-estab
            AND   esp-item-entr-st.cod-serie        = item-doc-est.serie-docto
            AND   esp-item-entr-st.cod-docto        = item-doc-est.nro-docto
            AND   esp-item-entr-st.cod-natur-operac = item-doc-est.nat-operacao
            AND   esp-item-entr-st.cod-emitente     = string(item-doc-est.cod-emitente)
            AND   esp-item-entr-st.cod-item         = item-doc-est.it-codigo
            AND   esp-item-entr-st.num-seq          = item-doc-est.sequencia :

            IF bf-it-nota-fisc.qt-faturada[1] > esp-item-entr-st.qtd-sdo-final THEN
                ASSIGN esp-item-entr-st.qtd-sdo-final = 0.
            ELSE 
                ASSIGN esp-item-entr-st.qtd-sdo-final = esp-item-entr-st.qtd-sdo-final - bf-it-nota-fisc.qt-faturada[1].

            RELEASE esp-item-entr-st.
        END.
    END.
END.
