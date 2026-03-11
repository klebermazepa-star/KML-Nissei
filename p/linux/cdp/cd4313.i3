&IF DEFINED(bf_dis_unid_neg) &THEN
    def temp-table tt-valor-item no-undo
        field seq-tt-it-docto         as int
        field nr-seq-fat              as int
        field it-codigo               as char
        field de-ger-mercad           as dec  decimals 2
        field de-ger-ipi              as dec  decimals 2
        field de-ger-desp             as dec  decimals 2
        field de-ger-iss              as dec  decimals 2
        field de-ger-irf              as dec  decimals 2
        field de-ger-inss             as dec  decimals 2
        field de-ger-icmsr            as dec  decimals 2
        field de-ger-antecip          as dec  decimals 2
        field de-vl-tot-base-comis    as dec  decimals 2
        field de-vl-tot-comis-antecip as dec  decimals 2
        field de-vl-totdup            as dec  decimals 2
        field de-vl-duplic            as dec  decimals 2
        field de-acum-dup             as dec  decimals 2

        field de-ger-pisretido         as dec  decimals 2
        field de-ger-cofinsretido      as dec  decimals 2
        field de-ger-csslretido        as dec  decimals 2

        index ch-valor is primary unique
            seq-tt-it-docto.
&ENDIF    

