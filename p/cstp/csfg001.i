  on 'mouse-select-click':u of situacao in browse brLote
  do:
      do with frame {&frame-name}:
          if ultimaClassificacao <> 'situacao' then do:
              open query brLote {&QUERY-STRING-brLote}
                  by situacao
                  by ttItem.num_lancto_ctbl
                  by ttItem.num_seq_lancto_ctbl.
              assign
                  ultimaClassificacao = 'situacao'.
          end.
          else do:
              open query brLote {&QUERY-STRING-brLote}
                  by situacao descending
                  by ttItem.num_lancto_ctbl
                  by ttItem.num_seq_lancto_ctbl.
              assign
                  ultimaClassificacao = ''.
          end.
      end.
      return.
  end.
  
  on 'mouse-select-click':u of ttItem.num_lancto_ctbl in browse brLote
  do:
      do with frame {&frame-name}:
          if ultimaClassificacao <> 'ttItem.num_lancto_ctbl' then do:
              open query brLote {&QUERY-STRING-brLote}
                  by ttItem.num_lancto_ctbl
                  by ttItem.num_seq_lancto_ctbl.
              assign
                  ultimaClassificacao = 'ttItem.num_lancto_ctbl'.
          end.
          else do:
              open query brLote {&QUERY-STRING-brLote}
                  by ttItem.num_lancto_ctbl descending
                  by ttItem.num_seq_lancto_ctbl.
              assign
                  ultimaClassificacao = ''.
          end.
      end.
      return.
  end.

  on 'mouse-select-click':u of ttItem.num_seq_lancto_ctbl in browse brLote
  do:
      do with frame {&frame-name}:
          if ultimaClassificacao <> 'ttItem.num_seq_lancto_ctbl' then do:
              open query brLote {&QUERY-STRING-brLote}
                  by ttItem.num_seq_lancto_ctbl
                  by ttItem.num_lancto_ctbl
                  by ttItem.cod_estab.
              assign
                  ultimaClassificacao = 'ttItem.num_seq_lancto_ctbl'.
          end.
          else do:
              open query brLote {&QUERY-STRING-brLote}
                  by ttItem.num_seq_lancto_ctbl descending
                  by ttItem.num_lancto_ctbl
                  by ttItem.cod_estab.
              assign
                  ultimaClassificacao = ''.
          end.
      end.
      return.
  end.

  on 'mouse-select-click':u of ttItem.ind_natur_lancto_ctbl in browse brLote
  do:
      do with frame {&frame-name}:
          if ultimaClassificacao <> 'ttItem.ind_natur_lancto_ctbl' then do:
              open query brLote {&QUERY-STRING-brLote}
                  by ttItem.ind_natur_lancto_ctbl
                  by ttItem.num_lancto_ctbl
                  by ttItem.num_seq_lancto_ctbl.
              assign
                  ultimaClassificacao = 'ttItem.ind_natur_lancto_ctbl'.
          end.
          else do:
              open query brLote {&QUERY-STRING-brLote}
                  by ttItem.ind_natur_lancto_ctbl descending
                  by ttItem.num_lancto_ctbl
                  by ttItem.num_seq_lancto_ctbl.
              assign
                  ultimaClassificacao = ''.
          end.
      end.
      return.
  end.

  on 'mouse-select-click':u of ttItem.cod_estab in browse brLote
  do:
      do with frame {&frame-name}:
          if ultimaClassificacao <> 'ttItem.cod_estab' then do:
              open query brLote {&QUERY-STRING-brLote}
                  by ttItem.cod_estab
                  by ttItem.num_lancto_ctbl
                  by ttItem.num_seq_lancto_ctbl.
              assign
                  ultimaClassificacao = 'ttItem.cod_estab'.
          end.
          else do:
              open query brLote {&QUERY-STRING-brLote}
                  by ttItem.cod_estab descending
                  by ttItem.num_lancto_ctbl
                  by ttItem.num_seq_lancto_ctbl.
              assign
                  ultimaClassificacao = ''.
          end.
      end.
      return.
  end.

  on 'mouse-select-click':u of ttItem.nomeEstabelecimento in browse brLote
  do:
      do with frame {&frame-name}:
          if ultimaClassificacao <> 'ttItem.nomeEstabelecimento' then do:
              open query brLote {&QUERY-STRING-brLote}
                  by ttItem.nomeEstabelecimento
                  by ttItem.num_lancto_ctbl
                  by ttItem.num_seq_lancto_ctbl.
              assign
                  ultimaClassificacao = 'ttItem.nomeEstabelecimento'.
          end.
          else do:
              open query brLote {&QUERY-STRING-brLote}
                  by ttItem.nomeEstabelecimento descending
                  by ttItem.num_lancto_ctbl
                  by ttItem.num_seq_lancto_ctbl.
              assign
                  ultimaClassificacao = ''.
          end.
      end.
      return.
  end.

  on 'mouse-select-click':u of ttItem.cod_cta_ctbl in browse brLote
  do:
      do with frame {&frame-name}:
          if ultimaClassificacao <> 'ttItem.cod_cta_ctbl' then do:
              open query brLote {&QUERY-STRING-brLote}
                  by ttItem.cod_cta_ctbl
                  by ttItem.num_lancto_ctbl
                  by ttItem.num_seq_lancto_ctbl.
              assign
                  ultimaClassificacao = 'ttItem.cod_cta_ctbl'.
          end.
          else do:
              open query brLote {&QUERY-STRING-brLote}
                  by ttItem.cod_cta_ctbl descending
                  by ttItem.num_lancto_ctbl
                  by ttItem.num_seq_lancto_ctbl.
              assign
                  ultimaClassificacao = ''.
          end.
      end.
      return.
  end.

  on 'mouse-select-click':u of ttItem.cod_ccusto in browse brLote
  do:
      do with frame {&frame-name}:
          if ultimaClassificacao <> 'ttItem.cod_ccusto' then do:
              open query brLote {&QUERY-STRING-brLote}
                  by ttItem.cod_ccusto
                  by ttItem.num_lancto_ctbl
                  by ttItem.num_seq_lancto_ctbl.
              assign
                  ultimaClassificacao = 'ttItem.cod_ccusto'.
          end.
          else do:
              open query brLote {&QUERY-STRING-brLote}
                  by ttItem.cod_ccusto descending
                  by ttItem.num_lancto_ctbl
                  by ttItem.num_seq_lancto_ctbl.
              assign
                  ultimaClassificacao = ''.
          end.
      end.
      return.
  end.

  on 'mouse-select-click':u of ttItem.dat_lancto_ctbl in browse brLote
  do:
      do with frame {&frame-name}:
          if ultimaClassificacao <> 'ttItem.dat_lancto_ctbl' then do:
              open query brLote {&QUERY-STRING-brLote}
                  by ttItem.dat_lancto_ctbl
                  by ttItem.num_lancto_ctbl
                  by ttItem.num_seq_lancto_ctbl.
              assign
                  ultimaClassificacao = 'ttItem.dat_lancto_ctbl'.
          end.
          else do:
              open query brLote {&QUERY-STRING-brLote}
                  by ttItem.dat_lancto_ctbl descending
                  by ttItem.num_lancto_ctbl
                  by ttItem.num_seq_lancto_ctbl.
              assign
                  ultimaClassificacao = ''.
          end.
      end.
      return.
  end.

  on 'mouse-select-click':u of ttItem.val_lancto_ctbl in browse brLote
  do:
      do with frame {&frame-name}:
          if ultimaClassificacao <> 'ttItem.val_lancto_ctbl' then do:
              open query brLote {&QUERY-STRING-brLote}
                  by ttItem.val_lancto_ctbl
                  by ttItem.num_lancto_ctbl
                  by ttItem.num_seq_lancto_ctbl.
              assign
                  ultimaClassificacao = 'ttItem.val_lancto_ctbl'.
          end.
          else do:
              open query brLote {&QUERY-STRING-brLote}
                  by ttItem.val_lancto_ctbl descending
                  by ttItem.num_lancto_ctbl
                  by ttItem.num_seq_lancto_ctbl.
              assign
                  ultimaClassificacao = ''.
          end.
      end.
      return.
  end.

  on 'mouse-select-click':u of ttItem.des_histor_lancto_ctbl in browse brLote
  do:
      do with frame {&frame-name}:
          if ultimaClassificacao <> 'ttItem.des_histor_lancto_ctbl' then do:
              open query brLote {&QUERY-STRING-brLote}
                  by ttItem.des_histor_lancto_ctbl
                  by ttItem.num_lancto_ctbl
                  by ttItem.num_seq_lancto_ctbl.
              assign
                  ultimaClassificacao = 'ttItem.des_histor_lancto_ctbl'.
          end.
          else do:
              open query brLote {&QUERY-STRING-brLote}
                  by ttItem.des_histor_lancto_ctbl descending
                  by ttItem.num_lancto_ctbl
                  by ttItem.num_seq_lancto_ctbl.
              assign
                  ultimaClassificacao = ''.
          end.
      end.
      return.
  end.

  on 'mouse-select-click':u of ttItem.ind_sit_lancto_ctbl in browse brLote
  do:
      do with frame {&frame-name}:
          if ultimaClassificacao <> 'ttItem.ind_sit_lancto_ctbl' then do:
              open query brLote {&QUERY-STRING-brLote}
                  by ttItem.ind_sit_lancto_ctbl
                  by ttItem.num_lancto_ctbl
                  by ttItem.num_seq_lancto_ctbl.
              assign
                  ultimaClassificacao = 'ttItem.ind_sit_lancto_ctbl'.
          end.
          else do:
              open query brLote {&QUERY-STRING-brLote}
                  by ttItem.ind_sit_lancto_ctbl descending
                  by ttItem.num_lancto_ctbl
                  by ttItem.num_seq_lancto_ctbl.
              assign
                  ultimaClassificacao = ''.
          end.
      end.
      return.
  end.
  
  on 'mouse-select-click':u of ttLancamento.num_lancto_ctbl in browse brGerencial
  do:
      do with frame {&frame-name}:
          if ultimaClassificacao <> 'ttLancamento.num_lancto_ctbl' then do:
              open query brGerencial {&QUERY-STRING-brGerencial}
                  by ttLancamento.num_lancto_ctbl
                  by ttLancamento.num_seq_lancto_ctbl.
              assign
                  ultimaClassificacao = 'ttLancamento.num_lancto_ctbl'.
          end.
          else do:
              open query brGerencial {&QUERY-STRING-brGerencial}
                  by ttLancamento.num_lancto_ctbl descending
                  by ttLancamento.num_seq_lancto_ctbl.
              assign
                  ultimaClassificacao = ''.
          end.
      end.
      return.
  end.

  on 'mouse-select-click':u of ttLancamento.num_seq_lancto_ctbl in browse brGerencial
  do:
      do with frame {&frame-name}:
          if ultimaClassificacao <> 'ttLancamento.num_seq_lancto_ctbl' then do:
              open query brGerencial {&QUERY-STRING-brGerencial}
                  by ttLancamento.num_seq_lancto_ctbl
                  by ttLancamento.num_lancto_ctbl
                  by ttLancamento.cod_estab.
              assign
                  ultimaClassificacao = 'ttLancamento.num_seq_lancto_ctbl'.
          end.
          else do:
              open query brGerencial {&QUERY-STRING-brGerencial}
                  by ttLancamento.num_seq_lancto_ctbl descending
                  by ttLancamento.num_lancto_ctbl
                  by ttLancamento.cod_estab.
              assign
                  ultimaClassificacao = ''.
          end.
      end.
      return.
  end.

  on 'mouse-select-click':u of ttLancamento.ind_natur_lancto_ctbl in browse brGerencial
  do:
      do with frame {&frame-name}:
          if ultimaClassificacao <> 'ttLancamento.ind_natur_lancto_ctbl' then do:
              open query brGerencial {&QUERY-STRING-brGerencial}
                  by ttLancamento.ind_natur_lancto_ctbl
                  by ttLancamento.num_lancto_ctbl
                  by ttLancamento.num_seq_lancto_ctbl.
              assign
                  ultimaClassificacao = 'ttLancamento.ind_natur_lancto_ctbl'.
          end.
          else do:
              open query brGerencial {&QUERY-STRING-brGerencial}
                  by ttLancamento.ind_natur_lancto_ctbl descending
                  by ttLancamento.num_lancto_ctbl
                  by ttLancamento.num_seq_lancto_ctbl.
              assign
                  ultimaClassificacao = ''.
          end.
      end.
      return.
  end.

  on 'mouse-select-click':u of ttLancamento.cod_estab in browse brGerencial
  do:
      do with frame {&frame-name}:
          if ultimaClassificacao <> 'ttLancamento.cod_estab' then do:
              open query brGerencial {&QUERY-STRING-brGerencial}
                  by ttLancamento.cod_estab
                  by ttLancamento.num_lancto_ctbl
                  by ttLancamento.num_seq_lancto_ctbl.
              assign
                  ultimaClassificacao = 'ttLancamento.cod_estab'.
          end.
          else do:
              open query brGerencial {&QUERY-STRING-brGerencial}
                  by ttLancamento.cod_estab descending
                  by ttLancamento.num_lancto_ctbl
                  by ttLancamento.num_seq_lancto_ctbl.
              assign
                  ultimaClassificacao = ''.
          end.
      end.
      return.
  end.

  on 'mouse-select-click':u of ttLancamento.nomeEstabelecimento in browse brGerencial
  do:
      do with frame {&frame-name}:
          if ultimaClassificacao <> 'ttLancamento.nomeEstabelecimento' then do:
              open query brGerencial {&QUERY-STRING-brGerencial}
                  by ttLancamento.nomeEstabelecimento
                  by ttLancamento.num_lancto_ctbl
                  by ttLancamento.num_seq_lancto_ctbl.
              assign
                  ultimaClassificacao = 'ttLancamento.nomeEstabelecimento'.
          end.
          else do:
              open query brGerencial {&QUERY-STRING-brGerencial}
                  by ttLancamento.nomeEstabelecimento descending
                  by ttLancamento.num_lancto_ctbl
                  by ttLancamento.num_seq_lancto_ctbl.
              assign
                  ultimaClassificacao = ''.
          end.
      end.
      return.
  end.

  on 'mouse-select-click':u of ttLancamento.cod_cta_ctbl in browse brGerencial
  do:
      do with frame {&frame-name}:
          if ultimaClassificacao <> 'ttLancamento.cod_cta_ctbl' then do:
              open query brGerencial {&QUERY-STRING-brGerencial}
                  by ttLancamento.cod_cta_ctbl
                  by ttLancamento.num_lancto_ctbl
                  by ttLancamento.num_seq_lancto_ctbl.
              assign
                  ultimaClassificacao = 'ttLancamento.cod_cta_ctbl'.
          end.
          else do:
              open query brGerencial {&QUERY-STRING-brGerencial}
                  by ttLancamento.cod_cta_ctbl descending
                  by ttLancamento.num_lancto_ctbl
                  by ttLancamento.num_seq_lancto_ctbl.
              assign
                  ultimaClassificacao = ''.
          end.
      end.
      return.
  end.

  on 'mouse-select-click':u of ttLancamento.cod_ccusto in browse brGerencial
  do:
      do with frame {&frame-name}:
          if ultimaClassificacao <> 'ttLancamento.cod_ccusto' then do:
              open query brGerencial {&QUERY-STRING-brGerencial}
                  by ttLancamento.cod_ccusto
                  by ttLancamento.num_lancto_ctbl
                  by ttLancamento.num_seq_lancto_ctbl.
              assign
                  ultimaClassificacao = 'ttLancamento.cod_ccusto'.
          end.
          else do:
              open query brGerencial {&QUERY-STRING-brGerencial}
                  by ttLancamento.cod_ccusto descending
                  by ttLancamento.num_lancto_ctbl
                  by ttLancamento.num_seq_lancto_ctbl.
              assign
                  ultimaClassificacao = ''.
          end.
      end.
      return.
  end.

  on 'mouse-select-click':u of ttLancamento.dat_lancto_ctbl in browse brGerencial
  do:
      do with frame {&frame-name}:
          if ultimaClassificacao <> 'ttLancamento.dat_lancto_ctbl' then do:
              open query brGerencial {&QUERY-STRING-brGerencial}
                  by ttLancamento.dat_lancto_ctbl
                  by ttLancamento.num_lancto_ctbl
                  by ttLancamento.num_seq_lancto_ctbl.
              assign
                  ultimaClassificacao = 'ttLancamento.dat_lancto_ctbl'.
          end.
          else do:
              open query brGerencial {&QUERY-STRING-brGerencial}
                  by ttLancamento.dat_lancto_ctbl descending
                  by ttLancamento.num_lancto_ctbl
                  by ttLancamento.num_seq_lancto_ctbl.
              assign
                  ultimaClassificacao = ''.
          end.
      end.
      return.
  end.

  on 'mouse-select-click':u of ttLancamento.val_lancto_ctbl in browse brGerencial
  do:
      do with frame {&frame-name}:
          if ultimaClassificacao <> 'ttLancamento.val_lancto_ctbl' then do:
              open query brGerencial {&QUERY-STRING-brGerencial}
                  by ttLancamento.val_lancto_ctbl
                  by ttLancamento.num_lancto_ctbl
                  by ttLancamento.num_seq_lancto_ctbl.
              assign
                  ultimaClassificacao = 'ttLancamento.val_lancto_ctbl'.
          end.
          else do:
              open query brGerencial {&QUERY-STRING-brGerencial}
                  by ttLancamento.val_lancto_ctbl descending
                  by ttLancamento.num_lancto_ctbl
                  by ttLancamento.num_seq_lancto_ctbl.
              assign
                  ultimaClassificacao = ''.
          end.
      end.
      return.
  end.

  on 'mouse-select-click':u of ttLancamento.des_histor_lancto_ctbl in browse brGerencial
  do:
      do with frame {&frame-name}:
          if ultimaClassificacao <> 'ttLancamento.des_histor_lancto_ctbl' then do:
              open query brGerencial {&QUERY-STRING-brGerencial}
                  by ttLancamento.des_histor_lancto_ctbl
                  by ttLancamento.num_lancto_ctbl
                  by ttLancamento.num_seq_lancto_ctbl.
              assign
                  ultimaClassificacao = 'ttLancamento.des_histor_lancto_ctbl'.
          end.
          else do:
              open query brGerencial {&QUERY-STRING-brGerencial}
                  by ttLancamento.des_histor_lancto_ctbl descending
                  by ttLancamento.num_lancto_ctbl
                  by ttLancamento.num_seq_lancto_ctbl.
              assign
                  ultimaClassificacao = ''.
          end.
      end.
      return.
  end.

  on 'mouse-select-click':u of ttLancamento.ind_sit_lancto_ctbl in browse brGerencial
  do:
      do with frame {&frame-name}:
          if ultimaClassificacao <> 'ttLancamento.ind_sit_lancto_ctbl' then do:
              open query brGerencial {&QUERY-STRING-brGerencial}
                  by ttLancamento.ind_sit_lancto_ctbl
                  by ttLancamento.num_lancto_ctbl
                  by ttLancamento.num_seq_lancto_ctbl.
              assign
                  ultimaClassificacao = 'ttLancamento.ind_sit_lancto_ctbl'.
          end.
          else do:
              open query brGerencial {&QUERY-STRING-brGerencial}
                  by ttLancamento.ind_sit_lancto_ctbl descending
                  by ttLancamento.num_lancto_ctbl
                  by ttLancamento.num_seq_lancto_ctbl.
              assign
                  ultimaClassificacao = ''.
          end.
      end.
      return.
  end.

  on 'mouse-select-click':u of ttLancamento.num_lancto_ctbl in browse brFiscal
  do:
      do with frame {&frame-name}:
          if ultimaClassificacao <> 'ttLancamento.num_lancto_ctbl' then do:
              open query brFiscal {&QUERY-STRING-brFiscal}
                  by ttLancamento.num_lancto_ctbl
                  by ttLancamento.num_seq_lancto_ctbl.
              assign
                  ultimaClassificacao = 'ttLancamento.num_lancto_ctbl'.
          end.
          else do:
              open query brFiscal {&QUERY-STRING-brFiscal}
                  by ttLancamento.num_lancto_ctbl descending
                  by ttLancamento.num_seq_lancto_ctbl.
              assign
                  ultimaClassificacao = ''.
          end.
      end.
      return.
  end.

  on 'mouse-select-click':u of ttLancamento.num_seq_lancto_ctbl in browse brFiscal
  do:
      do with frame {&frame-name}:
          if ultimaClassificacao <> 'ttLancamento.num_seq_lancto_ctbl' then do:
              open query brFiscal {&QUERY-STRING-brFiscal}
                  by ttLancamento.num_seq_lancto_ctbl
                  by ttLancamento.num_lancto_ctbl
                  by ttLancamento.cod_estab.
              assign
                  ultimaClassificacao = 'ttLancamento.num_seq_lancto_ctbl'.
          end.
          else do:
              open query brFiscal {&QUERY-STRING-brFiscal}
                  by ttLancamento.num_seq_lancto_ctbl descending
                  by ttLancamento.num_lancto_ctbl
                  by ttLancamento.cod_estab.
              assign
                  ultimaClassificacao = ''.
          end.
      end.
      return.
  end.

  on 'mouse-select-click':u of ttLancamento.ind_natur_lancto_ctbl in browse brFiscal
  do:
      do with frame {&frame-name}:
          if ultimaClassificacao <> 'ttLancamento.ind_natur_lancto_ctbl' then do:
              open query brFiscal {&QUERY-STRING-brFiscal}
                  by ttLancamento.ind_natur_lancto_ctbl
                  by ttLancamento.num_lancto_ctbl
                  by ttLancamento.num_seq_lancto_ctbl.
              assign
                  ultimaClassificacao = 'ttLancamento.ind_natur_lancto_ctbl'.
          end.
          else do:
              open query brFiscal {&QUERY-STRING-brFiscal}
                  by ttLancamento.ind_natur_lancto_ctbl descending
                  by ttLancamento.num_lancto_ctbl
                  by ttLancamento.num_seq_lancto_ctbl.
              assign
                  ultimaClassificacao = ''.
          end.
      end.
      return.
  end.

  on 'mouse-select-click':u of ttLancamento.cod_estab in browse brFiscal
  do:
      do with frame {&frame-name}:
          if ultimaClassificacao <> 'ttLancamento.cod_estab' then do:
              open query brFiscal {&QUERY-STRING-brFiscal}
                  by ttLancamento.cod_estab
                  by ttLancamento.num_lancto_ctbl
                  by ttLancamento.num_seq_lancto_ctbl.
              assign
                  ultimaClassificacao = 'ttLancamento.cod_estab'.
          end.
          else do:
              open query brFiscal {&QUERY-STRING-brFiscal}
                  by ttLancamento.cod_estab descending
                  by ttLancamento.num_lancto_ctbl
                  by ttLancamento.num_seq_lancto_ctbl.
              assign
                  ultimaClassificacao = ''.
          end.
      end.
      return.
  end.

  on 'mouse-select-click':u of ttLancamento.nomeEstabelecimento in browse brFiscal
  do:
      do with frame {&frame-name}:
          if ultimaClassificacao <> 'ttLancamento.nomeEstabelecimento' then do:
              open query brFiscal {&QUERY-STRING-brFiscal}
                  by ttLancamento.nomeEstabelecimento
                  by ttLancamento.num_lancto_ctbl
                  by ttLancamento.num_seq_lancto_ctbl.
              assign
                  ultimaClassificacao = 'ttLancamento.nomeEstabelecimento'.
          end.
          else do:
              open query brFiscal {&QUERY-STRING-brFiscal}
                  by ttLancamento.nomeEstabelecimento descending
                  by ttLancamento.num_lancto_ctbl
                  by ttLancamento.num_seq_lancto_ctbl.
              assign
                  ultimaClassificacao = ''.
          end.
      end.
      return.
  end.

  on 'mouse-select-click':u of ttLancamento.cod_cta_ctbl in browse brFiscal
  do:
      do with frame {&frame-name}:
          if ultimaClassificacao <> 'ttLancamento.cod_cta_ctbl' then do:
              open query brFiscal {&QUERY-STRING-brFiscal}
                  by ttLancamento.cod_cta_ctbl
                  by ttLancamento.num_lancto_ctbl
                  by ttLancamento.num_seq_lancto_ctbl.
              assign
                  ultimaClassificacao = 'ttLancamento.cod_cta_ctbl'.
          end.
          else do:
              open query brFiscal {&QUERY-STRING-brFiscal}
                  by ttLancamento.cod_cta_ctbl descending
                  by ttLancamento.num_lancto_ctbl
                  by ttLancamento.num_seq_lancto_ctbl.
              assign
                  ultimaClassificacao = ''.
          end.
      end.
      return.
  end.

  on 'mouse-select-click':u of ttLancamento.cod_ccusto in browse brFiscal
  do:
      do with frame {&frame-name}:
          if ultimaClassificacao <> 'ttLancamento.cod_ccusto' then do:
              open query brFiscal {&QUERY-STRING-brFiscal}
                  by ttLancamento.cod_ccusto
                  by ttLancamento.num_lancto_ctbl
                  by ttLancamento.num_seq_lancto_ctbl.
              assign
                  ultimaClassificacao = 'ttLancamento.cod_ccusto'.
          end.
          else do:
              open query brFiscal {&QUERY-STRING-brFiscal}
                  by ttLancamento.cod_ccusto descending
                  by ttLancamento.num_lancto_ctbl
                  by ttLancamento.num_seq_lancto_ctbl.
              assign
                  ultimaClassificacao = ''.
          end.
      end.
      return.
  end.

  on 'mouse-select-click':u of ttLancamento.dat_lancto_ctbl in browse brFiscal
  do:
      do with frame {&frame-name}:
          if ultimaClassificacao <> 'ttLancamento.dat_lancto_ctbl' then do:
              open query brFiscal {&QUERY-STRING-brFiscal}
                  by ttLancamento.dat_lancto_ctbl
                  by ttLancamento.num_lancto_ctbl
                  by ttLancamento.num_seq_lancto_ctbl.
              assign
                  ultimaClassificacao = 'ttLancamento.dat_lancto_ctbl'.
          end.
          else do:
              open query brFiscal {&QUERY-STRING-brFiscal}
                  by ttLancamento.dat_lancto_ctbl descending
                  by ttLancamento.num_lancto_ctbl
                  by ttLancamento.num_seq_lancto_ctbl.
              assign
                  ultimaClassificacao = ''.
          end.
      end.
      return.
  end.

  on 'mouse-select-click':u of ttLancamento.val_lancto_ctbl in browse brFiscal
  do:
      do with frame {&frame-name}:
          if ultimaClassificacao <> 'ttLancamento.val_lancto_ctbl' then do:
              open query brFiscal {&QUERY-STRING-brFiscal}
                  by ttLancamento.val_lancto_ctbl
                  by ttLancamento.num_lancto_ctbl
                  by ttLancamento.num_seq_lancto_ctbl.
              assign
                  ultimaClassificacao = 'ttLancamento.val_lancto_ctbl'.
          end.
          else do:
              open query brFiscal {&QUERY-STRING-brFiscal}
                  by ttLancamento.val_lancto_ctbl descending
                  by ttLancamento.num_lancto_ctbl
                  by ttLancamento.num_seq_lancto_ctbl.
              assign
                  ultimaClassificacao = ''.
          end.
      end.
      return.
  end.

  on 'mouse-select-click':u of ttLancamento.des_histor_lancto_ctbl in browse brFiscal
  do:
      do with frame {&frame-name}:
          if ultimaClassificacao <> 'ttLancamento.des_histor_lancto_ctbl' then do:
              open query brFiscal {&QUERY-STRING-brFiscal}
                  by ttLancamento.des_histor_lancto_ctbl
                  by ttLancamento.num_lancto_ctbl
                  by ttLancamento.num_seq_lancto_ctbl.
              assign
                  ultimaClassificacao = 'ttLancamento.des_histor_lancto_ctbl'.
          end.
          else do:
              open query brFiscal {&QUERY-STRING-brFiscal}
                  by ttLancamento.des_histor_lancto_ctbl descending
                  by ttLancamento.num_lancto_ctbl
                  by ttLancamento.num_seq_lancto_ctbl.
              assign
                  ultimaClassificacao = ''.
          end.
      end.
      return.
  end.

  on 'mouse-select-click':u of ttLancamento.ind_sit_lancto_ctbl in browse brFiscal
  do:
      do with frame {&frame-name}:
          if ultimaClassificacao <> 'ttLancamento.ind_sit_lancto_ctbl' then do:
              open query brFiscal {&QUERY-STRING-brFiscal}
                  by ttLancamento.ind_sit_lancto_ctbl
                  by ttLancamento.num_lancto_ctbl
                  by ttLancamento.num_seq_lancto_ctbl.
              assign
                  ultimaClassificacao = 'ttLancamento.ind_sit_lancto_ctbl'.
          end.
          else do:
              open query brFiscal {&QUERY-STRING-brFiscal}
                  by ttLancamento.ind_sit_lancto_ctbl descending
                  by ttLancamento.num_lancto_ctbl
                  by ttLancamento.num_seq_lancto_ctbl.
              assign
                  ultimaClassificacao = ''.
          end.
      end.
      return.
  end.
