/*** Defini‡äes cdapi1001.p ***/
DEF TEMP-TABLE tt-sit-tribut NO-UNDO
         FIELD cdn-tribut     AS INT
         FIELD cdn-sit-tribut AS INT
         FIELD seq-tab-comb   AS INT.

DEF TEMP-TABLE tt-retorna-rowid NO-UNDO
    FIELD cdn-tribut            AS INT
    FIELD rw-sit-tribut-relacto AS ROWID.
