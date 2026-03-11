/***************************************************************************** 
** Nome Externo..........: prgfin/epc/epc_fgl718ra.p
** Descricao.............: Programa Espec¡fico 
** Engenharia............: Desenvolvimento customizado conforme FO 1798.849
** Criado por............: Paulo Roberto Barth
** Criado em.............: 22/07/2008
*****************************************************************************/ 
def Input param p_ind_event        as character     no-undo.
def Input param p_ind_objeto       as character     no-undo.
def Input param p_wgh_objeto       as handle        no-undo.
def Input param p_wgh_frame        as widget-handle no-undo.
def Input param p_cod_table        as character     no-undo.
def Input param p_row_table_dw     as recid         no-undo.

DEF NEW GLOBAL SHARED VAR h-campo   AS WIDGET-HANDLE NO-UNDO.
/*DEF NEW GLOBAL SHARED VAR wh-button AS WIDGET-HANDLE NO-UNDO. Paulo Barth*/
DEF                   VAR wh-button AS WIDGET-HANDLE NO-UNDO. /* Paulo Barth */
DEF                   VAR h-objeto  AS WIDGET-HANDLE NO-UNDO.
def var v_cod_estab as char format "x(05)" no-undo.
def var v_cod_espec as char format "x(03)" no-undo.
def var v_cod_ser   as char format "x(02)" no-undo.
def var v_cod_tit_acr as char format "x(10)" no-undo.
def var v_cod_parcela as char format "x(02)" no-undo.

def NEW GLOBAL SHARED VAR h_epc212aa as handle no-undo.
  
IF p_ind_event = "DISPLAY" THEN DO:

    assign wh-button = ?.

    DO:
        assign h-objeto = p_wgh_frame:FIRST-CHILD.
        do  while valid-handle(h-objeto):
            IF  h-objeto:TYPE <> "field-group" THEN DO:
                
                IF  h-objeto:NAME = "cod_estab" then do:
                    assign v_cod_estab = h-objeto:screen-value. 
                end.

                IF  h-objeto:NAME = "cod_espec_docto" then do:
                    assign v_cod_espec = h-objeto:screen-value.
                end.

                IF  h-objeto:NAME = "cod_ser_docto" then do:
                    assign v_cod_ser = h-objeto:screen-value.
                end.

                IF  h-objeto:NAME = "cod_tit_acr" then do:
                    assign v_cod_tit_acr = h-objeto:screen-value.
                end.

                IF  h-objeto:NAME = "cod_parcela" then do:
                    assign v_cod_parcela = h-objeto:screen-value.
                end.
                IF  h-objeto:NAME = "bt_tit_cartao" then do:
                    assign wh-button = h-objeto.
                end.

                
                assign h-objeto = h-objeto:NEXT-SIBLING.
            end.
            ELSE DO:
                Assign h-objeto = h-objeto:first-child.
            END.
        end.
    END.

    DO:
        assign h-objeto = p_wgh_frame:FIRST-CHILD.
        do  while valid-handle(h-objeto):
            IF  h-objeto:TYPE <> "field-group" THEN DO:
                IF  h-objeto:NAME = "bt_vendor" THEN DO:
                    ASSIGN h-campo = h-objeto.
                    Leave.
                END.
                assign h-objeto = h-objeto:NEXT-SIBLING.
            END.
            ELSE DO:
                Assign h-objeto = h-objeto:first-child.
            END.
        end.
    END.

    if not valid-handle(wh-button) then do:
        
        unsubscribe procedure h_epc212aa to all.

        run prgfin/epc/epc_acr212aa.p persistent set h_epc212aa (Input "",
                                                                 Input p_ind_objeto,
                                                                 Input p_wgh_objeto,
                                                                 Input p_wgh_frame,
                                                                 Input p_cod_table,
                                                                 Input p_row_table_dw).
        
        CREATE BUTTON wh-button
        assign FRAME     = p_wgh_frame
               name      = "bt_tit_cartao"
               WIDTH     = 13.57
               HEIGHT    = 1.00
               LABEL     = "Cupom Relac."
               ROW       = 15.46
               COL       = 74.17
               FONT      = ?
               VISIBLE   = YES
               SENSITIVE = no
               TRIGGERS:
                   ON CHOOSE persistent run pi_exec in h_epc212aa.
               END TRIGGERS.

        subscribe procedure h_epc212aa to "getParamEpc" anywhere.
    end.

    publish "getParamEpc" (input v_cod_estab,   
                           input v_cod_espec,   
                           input v_cod_ser,     
                           input v_cod_tit_acr, 
                           input v_cod_parcela).

    find tit_acr no-lock where
         recid(tit_acr) = p_row_table_dw no-error.
    
    assign wh-button:sensitive = no.
    
    if avail tit_acr then do:
    
        if can-find(first tit_acr_cartao where
                          tit_acr.cod_estab      = tit_acr_cartao.cod_estab
                      and tit_acr.num_id_tit_acr = tit_acr_cartao.num_id_tit_acr) then do:
            assign wh-button:sensitive = yes.
        end.
    end.
end.


procedure pi_exec:

    RUN prgfin/spp/spp212aa.p (input v_cod_estab,
                               input v_cod_espec,
                               input v_cod_ser,
                               input v_cod_tit_acr,
                               input v_cod_parcela).
end.

procedure getParamEpc:
    
    def input param p_cod_estab   as char format "x(05)" no-undo.  
    def input param p_cod_espec   as char format "x(03)" no-undo.  
    def input param p_cod_ser     as char format "x(02)" no-undo.  
    def input param p_cod_tit_acr as char format "x(10)" no-undo.
    def input param p_cod_parcela as char format "x(02)" no-undo.

    assign v_cod_estab   = p_cod_estab  
           v_cod_espec   = p_cod_espec  
           v_cod_ser     = p_cod_ser    
           v_cod_tit_acr = p_cod_tit_acr
           v_cod_parcela = p_cod_parcela.
end.
