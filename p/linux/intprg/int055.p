/********************************************************************************
**
**  Programa: int055.p - Integraá∆o informaá‰es ABC Farma - Procfit -> Datasul
**
********************************************************************************/                                                                
        
{intprg/int-rpw.i} 
        
DEF NEW GLOBAL SHARED VAR c-seg-usuario AS CHAR FORMAT "x(12)" NO-UNDO.
        
DEF VAR c-pnu             AS CHAR NO-UNDO.
DEF VAR c-monitor         AS CHAR NO-UNDO.
DEF VAR i-seq-int_ds_item AS INT  NO-UNDO.

FOR EACH int_dp_abc_farma WHERE 
         int_dp_abc_farma.situacao = 1 USE-INDEX sequencia
    BY int_dp_abc_farma.sequencia QUERY-TUNING(NO-LOOKAHEAD):

    FOR FIRST ITEM WHERE
              ITEM.it-codigo = int_dp_abc_farma.it_codigo NO-LOCK QUERY-TUNING(NO-LOOKAHEAD):
    END.
    IF NOT AVAIL ITEM THEN DO:
       RUN intprg/int999.p (INPUT "ABCFARMA", 
                            INPUT int_dp_abc_farma.it_codigo,
                            INPUT "Item n∆o cadastrado no Datasul: " + STRING(int_dp_abc_farma.it_codigo),
                            INPUT 1, /* 1 - Pendente */
                            INPUT c-seg-usuario,
                            INPUT "int055.p").
       NEXT.
    END.

    FOR FIRST unid-feder WHERE
              unid-feder.pais   = "Brasil" AND
              unid-feder.estado = int_dp_abc_farma.uf NO-LOCK QUERY-TUNING(NO-LOOKAHEAD):
    END.
    IF NOT AVAIL unid-feder THEN DO:
       RUN intprg/int999.p (INPUT "ABCFARMA", 
                            INPUT int_dp_abc_farma.uf,
                            INPUT "UF n∆o cadastrada para o Pa°s: Brasil / " + int_dp_abc_farma.uf,
                            INPUT 1, /* 1 - Pendente */
                            INPUT c-seg-usuario,
                            INPUT "int055.p").
       NEXT.
    END.

    FOR FIRST int_dp_info_abc WHERE
              int_dp_info_abc.it_codigo = int_dp_abc_farma.it_codigo AND
              int_dp_info_abc.uf        = int_dp_abc_farma.uf:
    END.
    IF NOT AVAIL int_dp_info_abc THEN DO:
       CREATE int_dp_info_abc.
       ASSIGN int_dp_info_abc.it_codigo = int_dp_abc_farma.it_codigo
              int_dp_info_abc.uf        = int_dp_abc_farma.uf.  
    END.
    ASSIGN int_dp_info_abc.pmc          = int_dp_abc_farma.pmc
           int_dp_info_abc.pnu          = int_dp_abc_farma.pnu        
           int_dp_info_abc.tipo_preco   = int_dp_abc_farma.tipo_preco         
           int_dp_info_abc.preco_fabric = int_dp_abc_farma.preco_fabric          
           int_dp_info_abc.categoria    = "".         

    IF int_dp_abc_farma.uf = "PR" THEN DO:
       FOR FIRST item-uf WHERE
                 item-uf.it-codigo       = int_dp_abc_farma.it_codigo AND
                 item-uf.cod-estado-orig = "PR" AND
                 item-uf.estado          = "PR" NO-LOCK:
       END.
       IF AVAIL item-uf THEN DO:
          for each preco-item where preco-item.nr-tabpre  = "PR12" AND
                                    preco-item.dt-inival <= today and
                                    preco-item.it-codigo  = int_dp_abc_farma.it_codigo:
              ASSIGN preco-item.situacao = 2.
          END.

          create preco-item.
          assign preco-item.nr-tabpre    = "PR12"
                 preco-item.it-codigo    = int_dp_abc_farma.it_codigo
                 preco-item.preco-venda  = int_dp_abc_farma.pmc
                 preco-item.preco-fob    = int_dp_abc_farma.pmc
                 preco-item.dt-inival    = TODAY
                 preco-item.cod-unid-med = item.un
                 preco-item.situacao     = 1
                 preco-item.user-alter   = "super"
                 preco-item.dt-useralt   = TODAY.
       END.
   END.

   IF int_dp_abc_farma.uf = "SC" THEN DO:
      FOR FIRST item-uf WHERE
                item-uf.it-codigo       = int_dp_abc_farma.it_codigo AND
                item-uf.cod-estado-orig = "SC" AND
                item-uf.estado          = "SC" NO-LOCK:
      END.
      IF AVAIL item-uf THEN DO:
         for each preco-item where preco-item.nr-tabpre  = "SC17" AND
                                   preco-item.dt-inival <= today and
                                   preco-item.it-codigo  = int_dp_abc_farma.it_codigo:
             ASSIGN preco-item.situacao = 2.
         END.

         create preco-item.
         assign preco-item.nr-tabpre    = "SC17"
                preco-item.it-codigo    = int_dp_abc_farma.it_codigo
                preco-item.preco-venda  = int_dp_abc_farma.pmc
                preco-item.preco-fob    = int_dp_abc_farma.pmc
                preco-item.dt-inival    = TODAY
                preco-item.cod-unid-med = item.un
                preco-item.situacao     = 1
                preco-item.user-alter   = "super"
                preco-item.dt-useralt   = TODAY. 
      END.
   END.

   IF int_dp_abc_farma.uf = "SP" THEN DO:
      FOR FIRST item-uf WHERE
                item-uf.it-codigo       = int_dp_abc_farma.it_codigo AND
                item-uf.cod-estado-orig = "SP" AND
                item-uf.estado          = "SP" NO-LOCK:
      END.
      IF AVAIL item-uf THEN DO:
         for each preco-item where preco-item.nr-tabpre  = "SP18" AND
                                   preco-item.dt-inival <= today and
                                   preco-item.it-codigo  = int_dp_abc_farma.it_codigo:
             ASSIGN preco-item.situacao = 2.
         END.

         create preco-item.
         assign preco-item.nr-tabpre    = "SP18"
                preco-item.it-codigo    = int_dp_abc_farma.it_codigo
                preco-item.preco-venda  = int_dp_abc_farma.pmc
                preco-item.preco-fob    = int_dp_abc_farma.pmc
                preco-item.dt-inival    = TODAY
                preco-item.cod-unid-med = item.un
                preco-item.situacao     = 1
                preco-item.user-alter   = "super"
                preco-item.dt-useralt   = TODAY. 
      END.
   END.

   IF item.cd-folh-item = "CADITEM" THEN DO:

      ASSIGN c-pnu = "*OUTR*".

      IF int_dp_abc_farma.pnu = 1 THEN
         ASSIGN c-pnu = "*POSITIV*".

      IF int_dp_abc_farma.pnu = 2 THEN
         ASSIGN c-pnu = "*NEGATIV*".

      IF int_dp_abc_farma.pnu = 3 THEN
         ASSIGN c-pnu = "*NEUTR*".

      FIND FIRST it-carac-tec WHERE
                 it-carac-tec.it-codigo = ITEM.it-codigo and
                 it-carac-tec.cd-folha  = "CADITEM"      AND
                 it-carac-tec.cd-comp   = "90"           EXCLUSIVE-LOCK NO-ERROR.
      IF NOT AVAIL it-carac-tec THEN DO:
         CREATE it-carac-tec.                                                               
         ASSIGN it-carac-tec.it-codigo  = ITEM.it-codigo
                it-carac-tec.cd-folha   = "CADITEM"
                it-carac-tec.cd-comp    = "90"
                it-carac-tec.tipo-resul = 2 /* tabela */
                it-carac-tec.nr-tabela  = 90.
      END.
      FIND FIRST c-tab-res WHERE
                 c-tab-res.nr-tabela = 90 AND
                 c-tab-res.descricao MATCHES c-pnu NO-LOCK NO-ERROR.
      IF AVAIL c-tab-res THEN DO:
         FIND FIRST it-res-carac WHERE
                    it-res-carac.cd-comp    = "90"           AND
                    it-res-carac.cd-folha   = "CADITEM"      AND
                    it-res-carac.it-codigo  = ITEM.it-codigo AND
                    it-res-carac.nr-tabela  = 90 NO-ERROR.
         IF NOT AVAIL it-res-carac THEN DO:
            create it-res-carac.
            assign it-res-carac.cd-comp    = "90"
                   it-res-carac.cd-folha   = "CADITEM"
                   it-res-carac.it-codigo  = ITEM.it-codigo
                   it-res-carac.nr-tabela  = 90
                   it-res-carac.sequencia  = c-tab-res.sequencia.
         END.
         ELSE
            ASSIGN it-res-carac.sequencia = c-tab-res.sequencia.

         ASSIGN it-carac-tec.observacao = substr(c-tab-res.descricao,1,40).
      END.

      RELEASE it-carac-tec.
      RELEASE it-res-carac.

      IF int_dp_abc_farma.tipo_preco = 1 THEN
         ASSIGN c-monitor = "*SIM*".
      ELSE 
         ASSIGN c-monitor = "*N«O*".

      FIND FIRST it-carac-tec WHERE
                 it-carac-tec.it-codigo = ITEM.it-codigo and
                 it-carac-tec.cd-folha  = "CADITEM"      AND
                 it-carac-tec.cd-comp   = "170"          EXCLUSIVE-LOCK NO-ERROR.
      IF NOT AVAIL it-carac-tec THEN DO:
         CREATE it-carac-tec.                                                               
         ASSIGN it-carac-tec.it-codigo  = ITEM.it-codigo
                it-carac-tec.cd-folha   = "CADITEM"
                it-carac-tec.cd-comp    = "170"
                it-carac-tec.tipo-resul = 2 /* tabela */
                it-carac-tec.nr-tabela  = 170.
      END.
      FIND FIRST c-tab-res WHERE
                 c-tab-res.nr-tabela = 170 AND
                 c-tab-res.descricao MATCHES c-monitor NO-LOCK NO-ERROR.
      IF AVAIL c-tab-res THEN DO:
         FIND FIRST it-res-carac WHERE
                    it-res-carac.cd-comp    = "170"          AND
                    it-res-carac.cd-folha   = "CADITEM"      AND
                    it-res-carac.it-codigo  = ITEM.it-codigo AND
                    it-res-carac.nr-tabela  = 170 NO-ERROR.
         IF NOT AVAIL it-res-carac THEN DO:
            create it-res-carac.
            assign it-res-carac.cd-comp    = "170"
                   it-res-carac.cd-folha   = "CADITEM"
                   it-res-carac.it-codigo  = ITEM.it-codigo
                   it-res-carac.nr-tabela  = 170
                   it-res-carac.sequencia  = c-tab-res.sequencia.
         END.
         ELSE
            ASSIGN it-res-carac.sequencia = c-tab-res.sequencia.

         ASSIGN it-carac-tec.observacao = substr(c-tab-res.descricao,1,40).
      END.

      RELEASE it-carac-tec.
      RELEASE it-res-carac.

      RUN pi-integracao.
   END.
   
   ASSIGN int_dp_abc_farma.situacao = 2. /* Integrado */

   RUN intprg/int999.p (INPUT "ABCFARMA", 
                        INPUT int_dp_abc_farma.it_codigo + int_dp_abc_farma.uf,
                        INPUT "Informaá‰es da ABC Farma atualizadas com sucesso no Datasul.", 
                        INPUT 2, /* 2 - Integrado */
                        INPUT c-seg-usuario,
                        INPUT "int055.p").
END.

PROCEDURE pi-integracao:

    ASSIGN i-seq-int_ds_item = NEXT-VALUE(seq-int-ds-item). /* Preparaá∆o para integraá∆o com Procfit */

    CREATE int_ds_item.
    ASSIGN int_ds_item.tipo_movto                 = 2 /* Alteraá∆o */                 
           int_ds_item.dt_geracao                 = TODAY
           int_ds_item.hr_geracao                 = STRING(TIME,"hh:mm:ss") 
           int_ds_item.cod_usuario                = c-seg-usuario
           int_ds_item.situacao                   = 1 /* Pendente */
           int_ds_item.pro_codigo_n               = int(item.it-codigo) 
           int_ds_item.pro_descricaocupomfiscal_s = item.desc-item 
           int_ds_item.pro_datacadastro_d         = item.data-implant
           int_ds_item.pro_ncm_s                  = substr(item.class-fiscal,1,8)
           int_ds_item.pro_grupocomercial_n       = INT(item.fm-cod-com)
           int_ds_item.id_sequencial              = i-seq-int_ds_item. 
    
    FIND FIRST int_ds_ext_item WHERE
               int_ds_ext_item.it_codigo = item.it-codigo NO-LOCK NO-ERROR.
    IF AVAIL int_ds_ext_item THEN DO:
       ASSIGN int_ds_item.pro_ncmipi_n = int_ds_ext_item.ncmipi.
    END.
        
    FOR EACH it-carac-tec WHERE
             it-carac-tec.it-codigo = item.it-codigo AND
             it-carac-tec.cd-folha = "CADITEM" NO-LOCK:
    
        IF it-carac-tec.cd-comp = "10" THEN
           ASSIGN int_ds_item.pro_descricaoetiqueta_s = substr(it-carac-tec.observacao,1,30).
    
        IF it-carac-tec.cd-comp = "20" THEN
           ASSIGN int_ds_item.pro_descricaoweb_s = it-carac-tec.observacao.
        
        IF it-carac-tec.cd-comp = "25" THEN
           ASSIGN int_ds_item.pro_divisao_n = INT(substr(it-carac-tec.observacao,1,3)).          
    
        IF it-carac-tec.cd-comp = "30" THEN
           ASSIGN int_ds_item.pro_tipoproduto_n = INT(substr(it-carac-tec.observacao,1,1)).
    
        IF it-carac-tec.cd-comp = "40" THEN
           ASSIGN int_ds_item.pro_categoriaconvenio_n = INT(substr(it-carac-tec.observacao,1,2)).
        
        IF it-carac-tec.cd-comp = "45" THEN
           ASSIGN int_ds_item.pro_sazonalidade_n = INT(substr(it-carac-tec.observacao,1,1)).                   
    
        IF it-carac-tec.cd-comp = "60" THEN
           ASSIGN int_ds_item.pro_subgrupocomercial_n = INT(substr(it-carac-tec.observacao,1,3)).
    
        IF it-carac-tec.cd-comp = "65" THEN
           ASSIGN int_ds_item.pro_sigla_pdv_s = substr(it-carac-tec.observacao,1,15). 
    
        IF it-carac-tec.cd-comp = "70" THEN
           ASSIGN int_ds_item.pro_gerapedido_s = substr(it-carac-tec.observacao,1,1). 
    
        IF item.cod-obsoleto = 1 THEN
           ASSIGN int_ds_item.pro_situacaoproduto_s = "A".
    
        IF item.cod-obsoleto = 2 OR item.cod-obsoleto = 3 THEN
           ASSIGN int_ds_item.pro_situacaoproduto_s = "E".
    
        IF item.cod-obsoleto = 4 THEN
           ASSIGN int_ds_item.pro_situacaoproduto_s = "I".
    
        IF it-carac-tec.cd-comp = "90" THEN
           ASSIGN int_ds_item.pro_lista_s = substr(it-carac-tec.observacao,1,1).                
    
        IF it-carac-tec.cd-comp = "100" THEN
           ASSIGN int_ds_item.pro_fracionado_s = substr(it-carac-tec.observacao,1,1).
    
        IF it-carac-tec.cd-comp = "110" THEN
           ASSIGN int_ds_item.pro_lastro_n = it-carac-tec.vl-result.
    
        IF it-carac-tec.cd-comp = "120" THEN
           ASSIGN int_ds_item.pro_camada_n = it-carac-tec.vl-result.         
    
        IF it-carac-tec.cd-comp = "140" THEN
           ASSIGN int_ds_item.pro_publicoalvo_n = INT(substr(it-carac-tec.observacao,1,1)).
    
        IF it-carac-tec.cd-comp = "150" THEN
           ASSIGN int_ds_item.pro_informaprescricao_s = substr(it-carac-tec.observacao,1,1).
        
        IF it-carac-tec.cd-comp = "170" THEN
           ASSIGN int_ds_item.pro_monitorado_s = substr(it-carac-tec.observacao,1,1).
    
        IF it-carac-tec.cd-comp = "180" THEN
           ASSIGN int_ds_item.pro_tarjado_s = substr(it-carac-tec.observacao,1,1).
    
        IF it-carac-tec.cd-comp = "190" THEN
           ASSIGN int_ds_item.pro_sngpc_n  = INT(substr(it-carac-tec.observacao,1,1)).
    
        IF it-carac-tec.cd-comp = "200" THEN DO:
           IF substr(it-carac-tec.observacao,1,2) = "  " THEN
              ASSIGN int_ds_item.pro_portaria_s = "".
           ELSE
              ASSIGN int_ds_item.pro_portaria_s = substr(it-carac-tec.observacao,1,2).
        END.
    
        IF it-carac-tec.cd-comp = "210" THEN
           ASSIGN int_ds_item.pro_apresentacao_n = it-carac-tec.vl-result.
    
        IF it-carac-tec.cd-comp = "225" THEN
           ASSIGN int_ds_item.pro_dosagemapresentacao_n = INT(substr(it-carac-tec.observacao,1,2)).
    
        IF it-carac-tec.cd-comp = "230" THEN
           ASSIGN int_ds_item.pro_concentracao_n = it-carac-tec.vl-result.
    
        IF it-carac-tec.cd-comp = "240" THEN
           ASSIGN int_ds_item.pro_dosagemconcentracao_n = INT(substr(it-carac-tec.observacao,1,2)).
    
        IF it-carac-tec.cd-comp = "250" THEN
           ASSIGN int_ds_item.pro_nomecomercial_s = it-carac-tec.observacao. 
    
        IF it-carac-tec.cd-comp = "255" THEN
           ASSIGN int_ds_item.pro_datasngpc_d = it-carac-tec.dt-result. 
                   
        IF it-carac-tec.cd-comp = "260" THEN
           ASSIGN int_ds_item.pro_csta_n = INT(substr(it-carac-tec.observacao,1,1)).
    
        IF it-carac-tec.cd-comp = "270" THEN
           ASSIGN int_ds_item.pro_unidademedidamedicamento_n = INT(substr(it-carac-tec.observacao,1,1)).
         
        IF it-carac-tec.cd-comp = "280" THEN
           ASSIGN int_ds_item.pro_excecaopiscofinsncm_s = substr(it-carac-tec.observacao,1,1).
    
        IF it-carac-tec.cd-comp = "290" THEN
           ASSIGN int_ds_item.pro_tributapis_s = substr(it-carac-tec.observacao,1,1).
    
        IF it-carac-tec.cd-comp = "300" THEN
           ASSIGN int_ds_item.pro_tributacofins_s = substr(it-carac-tec.observacao,1,1).
    
        IF it-carac-tec.cd-comp = "310" THEN
           ASSIGN int_ds_item.pro_classificacaomedicamento_n = INT(substr(it-carac-tec.observacao,1,1)).
        
        IF it-carac-tec.cd-comp = "330" THEN
           ASSIGN int_ds_item.pro_utilizapautafiscal_s = substr(it-carac-tec.observacao,1,1).
    
        IF it-carac-tec.cd-comp = "340" THEN
           ASSIGN int_ds_item.pro_valorpautafiscal_n = it-carac-tec.vl-result.
    
        IF it-carac-tec.cd-comp = "350" THEN
           ASSIGN int_ds_item.pro_emiteetiqueta_s = substr(it-carac-tec.observacao,1,1).
    
        IF it-carac-tec.cd-comp = "360" THEN
           ASSIGN int_ds_item.pro_pbm_s = substr(it-carac-tec.observacao,1,1).
    
        IF it-carac-tec.cd-comp = "370" THEN
           ASSIGN int_ds_item.pro_cestabasica_s = substr(it-carac-tec.observacao,1,1).  
    
        IF it-carac-tec.cd-comp = "380" THEN
           ASSIGN int_ds_item.pro_reposicaopbm_s = substr(it-carac-tec.observacao,1,1).
                  
        IF it-carac-tec.cd-comp = "390" THEN
           ASSIGN int_ds_item.pro_quantidadeembarque_n = DEC(it-carac-tec.observacao).          
        
        IF it-carac-tec.cd-comp = "400" THEN
           ASSIGN int_ds_item.pro_circuladeposito_s = substr(it-carac-tec.observacao,1,1).  
    
        IF it-carac-tec.cd-comp = "410" THEN
           ASSIGN int_ds_item.pro_aceitadevolucao_s = substr(it-carac-tec.observacao,1,1).     
        
        IF it-carac-tec.cd-comp = "420" THEN
           ASSIGN int_ds_item.pro_mercadologica_s = substr(it-carac-tec.observacao,1,2).          
    
        IF it-carac-tec.cd-comp = "430" THEN 
           ASSIGN int_ds_item.pro_registroms_n = DEC(it-carac-tec.observacao).
    END.    

END PROCEDURE.

RUN intprg/int888.p (INPUT "ABCFARMA",
                     INPUT "int055.p").

RETURN "OK".
