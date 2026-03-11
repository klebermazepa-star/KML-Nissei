/***************************************************************************************
**  Programa.: upc-cd0204b-01.p
***************************************************************************************/

def new global shared var c-seg-usuario as char no-undo.

DEF NEW GLOBAL SHARED VAR wh-bt-ok-orig-cd0204b    AS WIDGET-HANDLE NO-UNDO.
DEF NEW GLOBAL SHARED VAR wh-bt-ok-cd0204b         AS WIDGET-HANDLE NO-UNDO.
def new global shared var wh-cd-folh-item-cd0204   as widget-handle no-undo.
DEF NEW GLOBAL SHARED VAR wh-it-carac-tec-cd0204   AS WIDGET-HANDLE NO-UNDO.

DEF VAR l-result                   AS LOGICAL      NO-UNDO.
DEF VAR i-tp-movto                 AS INT          NO-UNDO.
DEF VAR i-seq-int_ds_item          AS INT          NO-UNDO.

DEF INPUT PARAMETER p-opcao AS CHAR.

IF p-opcao = "OK" THEN DO:
    
   IF VALID-HANDLE(wh-bt-ok-orig-cd0204b) THEN DO:
   
      ASSIGN l-result = YES.

      FOR EACH it-carac-tec WHERE
               it-carac-tec.it-codigo = wh-it-carac-tec-cd0204:SCREEN-VALUE AND 
               it-carac-tec.cd-folha  = "CADITEM" NO-LOCK,
          EACH comp-folh OF it-carac-tec WHERE 
               comp-folh.log-estado = TRUE NO-LOCK:
          FIND FIRST int_ds_ext_comp_folh WHERE
                     int_ds_ext_comp_folh.cd_folha = comp-folh.cd-folha AND
                     int_ds_ext_comp_folh.cd_comp  = comp-folh.cd-comp NO-LOCK NO-ERROR.
          IF AVAIL int_ds_ext_comp_folh THEN DO:
             IF int_ds_ext_comp_folh.obriga_carac_tec = YES THEN DO:
                IF  it-carac-tec.tipo-result = 1 /* Num‚rico */
                AND it-carac-tec.vl-result   = 0 THEN
                    ASSIGN l-result = NO.

                IF  it-carac-tec.tipo-result = 2 /* Tabela */
                AND it-carac-tec.observacao  = "" THEN
                    ASSIGN l-result = NO.

                IF  it-carac-tec.tipo-result = 4 /* Observa‡Æo */
                AND it-carac-tec.observacao  = "" THEN
                    ASSIGN l-result = NO.

                IF  it-carac-tec.tipo-result = 6 /* Data */
                AND it-carac-tec.dt-result   = ? THEN
                    ASSIGN l-result = NO.

             END.
          END.
      END.

      IF l-result = NO THEN DO:
         MESSAGE "Existe(m) Caracter¡stica(s) T‚cnica(s) obrigat¢ria(s) sem Resultado."
             VIEW-AS ALERT-BOX INFO BUTTONS OK.
         RETURN "NOK".
      END.

      FIND FIRST ITEM WHERE
                 ITEM.it-codigo = wh-it-carac-tec-cd0204:SCREEN-VALUE NO-LOCK NO-ERROR.
      IF AVAIL ITEM THEN DO:
         ASSIGN i-seq-int_ds_item = NEXT-VALUE(seq-int-ds-item). /* Prepara‡Æo para integra‡Æo com Procfit */
         FIND FIRST int_ds_item WHERE
                    int_ds_item.pro_codigo_n = int(it-carac-tec.it-codigo) NO-ERROR.
         IF NOT AVAIL int_ds_item THEN DO:
            CREATE int_ds_item.
            ASSIGN int_ds_item.tipo_movto                  = 1 /* InclusÆo */
                   int_ds_item.dt_geracao                  = TODAY
                   int_ds_item.hr_geracao                  = STRING(TIME,"hh:mm:ss") 
                   int_ds_item.cod_usuario                 = c-seg-usuario
                   int_ds_item.situacao                    = 1 /* Pendente */
                   int_ds_item.pro_codigo_n                = int(item.it-codigo) 
                   int_ds_item.pro_descricaocupomfiscal_s  = item.desc-item 
                   int_ds_item.pro_datacadastro_d          = item.data-implant
                   int_ds_item.pro_ncm_s                   = substr(item.class-fiscal,1,8)
                   int_ds_item.pro_grupocomercial_n        = INT(item.fm-cod-com)
                   int_ds_item.id_sequencial               = i-seq-int_ds_item /* Prepara‡Æo para integra‡Æo com Procfit */
                   i-tp-movto                              = 1.

            FIND FIRST int_ds_ext_item WHERE
                       int_ds_ext_item.it_codigo = item.it-codigo NO-LOCK NO-ERROR.
            IF AVAIL int_ds_ext_item THEN DO:
               ASSIGN int_ds_item.pro_ncmipi_n = int_ds_ext_item.ncmipi.
            END.
         END.
         ELSE DO:
             CREATE int_ds_item.
             ASSIGN int_ds_item.tipo_movto                  = 2 /* Altera‡Æo */
                    int_ds_item.dt_geracao                  = TODAY
                    int_ds_item.hr_geracao                  = STRING(TIME,"hh:mm:ss") 
                    int_ds_item.cod_usuario                 = c-seg-usuario
                    int_ds_item.situacao                    = 1 /* Pendente */
                    int_ds_item.pro_codigo_n                = int(item.it-codigo) 
                    int_ds_item.pro_descricaocupomfiscal_s  = item.desc-item 
                    int_ds_item.pro_datacadastro_d          = item.data-implant
                    int_ds_item.pro_ncm_s                   = substr(item.class-fiscal,1,8)
                    int_ds_item.pro_grupocomercial_n        = INT(item.fm-cod-com)
                    int_ds_item.id_sequencial               = i-seq-int_ds_item /* Prepara‡Æo para integra‡Æo com Procfit */
                    i-tp-movto                              = 2.

             FIND FIRST int_ds_ext_item WHERE
                        int_ds_ext_item.it_codigo = item.it-codigo NO-LOCK NO-ERROR.
             IF AVAIL int_ds_ext_item THEN DO:
                ASSIGN int_ds_item.pro_ncmipi_n = int_ds_ext_item.ncmipi.
             END.
         END.

         /* Atualiza‡Æo da tabela de integra‡Æo Datasul -> Sysfarma */
         /*           C¢digos de Barra dos Itens - EAN              */  

         FOR EACH int_ds_ean_item WHERE
                  int_ds_ean_item.it_codigo = ITEM.it-codigo NO-LOCK:

            CREATE int_ds_item_compl.
            ASSIGN int_ds_item_compl.tipo_movto          = i-tp-movto
                   int_ds_item_compl.dt_geracao          = TODAY
                   int_ds_item_compl.hr_geracao          = STRING(TIME,"hh:mm:ss") 
                   int_ds_item_compl.cod_usuario         = c-seg-usuario
                   int_ds_item_compl.situacao            = 1 /* Pendente */
                   int_ds_item_compl.cba_produto_n       = INT(int_ds_ean_item.it_codigo)        
                   int_ds_item_compl.cba_ean_n           = int_ds_ean_item.codigo_ean          
                   int_ds_item_compl.cba_lotemultiplo_n  = int_ds_ean_item.lote_multiplo       
                   int_ds_item_compl.cba_altura_n        = int_ds_ean_item.altura              
                   int_ds_item_compl.cba_largura_n       = int_ds_ean_item.largura             
                   int_ds_item_compl.cba_profundidade_n  = int_ds_ean_item.profundidade        
                   int_ds_item_compl.cba_peso_n          = int_ds_ean_item.peso                
                   int_ds_item_compl.cba_data_cadastro_d = int_ds_ean_item.data_cadastro       
                   int_ds_item_compl.cba_principal_s     = IF int_ds_ean_item.principal = YES THEN
                                                              "S"
                                                           ELSE 
                                                              "N"
                   int_ds_item_compl.id_cabecalho        = i-seq-int_ds_item
                   int_ds_item_compl.id_sequencial       = NEXT-VALUE(seq-int-ds-item-compl). /* Prepara‡Æo para integra‡Æo com Procfit */
                                                                  
         END.

         FOR EACH it-carac-tec WHERE
                  it-carac-tec.it-codigo = wh-it-carac-tec-cd0204:SCREEN-VALUE AND 
                  it-carac-tec.cd-folha  = "CADITEM" NO-LOCK:
    
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
    
             /*IF it-carac-tec.cd-comp = "80" THEN
                ASSIGN int_ds_item.pro_situacaoproduto_s = substr(it-carac-tec.observacao,1,1).*/

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
    
             /*IF it-carac-tec.cd-comp = "160" THEN 
                 ASSIGN int_ds_item.pro_registroms_n = it-carac-tec.vl-result.*/
    
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
    
             /*IF it-carac-tec.cd-comp = "320" THEN
                ASSIGN int_ds_item.pro_aceitadevolucao_s = substr(it-carac-tec.observacao,1,1).*/
    
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
                ASSIGN int_ds_item.pro_quantidadeembarque_n = it-carac-tec.vl-result.          
    
             IF it-carac-tec.cd-comp = "400" THEN
                ASSIGN int_ds_item.pro_circuladeposito_s = substr(it-carac-tec.observacao,1,1).  
    
             IF it-carac-tec.cd-comp = "410" THEN 
                ASSIGN int_ds_item.pro_aceitadevolucao_s = substr(it-carac-tec.observacao,1,1).     
    
             IF it-carac-tec.cd-comp = "420" THEN
                ASSIGN int_ds_item.pro_mercadologica_s = substr(it-carac-tec.observacao,1,2).            

             IF it-carac-tec.cd-comp = "430" THEN 
                ASSIGN int_ds_item.pro_registroms_n = DEC(it-carac-tec.observacao).

    
         END.
      END.

      APPLY "choose" TO wh-bt-ok-orig-cd0204b.    
        
   END.
END.

