DEFINE VARIABLE cDir AS CHARACTER  NO-UNDO.

ASSIGN cDir = 'c:\datasul\temp\'.

/* programas */
output to value(cDir + 'programas-espec.txt') convert target 'iso8859-1'.

for each prog_dtsul
    where log_reg_padr = no
    no-lock:

    EXPORT prog_dtsul.
end.

output close.

/* seguranca programas */
output to value(cDir + 'prog-segur-espec.txt') convert target 'iso8859-1'.

for each prog_dtsul_segur
    ,
    first prog_dtsul
    where prog_dtsul.cod_prog_dtsul = prog_dtsul_segur.cod_prog_dtsul
      and prog_dtsul.log_reg_padr = no
    no-lock:

    export prog_dtsul_segur.
end.

output close.


/* procedimetos */
output to value(cDir + 'procedimentos-espec.txt') convert target 'iso8859-1'.

for each procedimento
    where log_reg_padr = no
    no-lock:

    EXPORT procedimento.
end.

output close.

/* seguranca procedimentos */
output to value(cDir + 'proced-segur-espec.txt') convert target 'iso8859-1'.

for each proced_segur
    , first procedimento of proced_segur
    where procedimento.log_reg_padr = no
    no-lock:

    export proced_segur.
end.

output close.


/* estrutura */
output to value(cDir + 'estrutura-espec.txt') convert target 'iso8859-1'.

for each modul_rot_proced
    where log_reg_padr = no
    no-lock:

    EXPORT modul_rot_proced.
end.

output close.



/* estrutura - sub-rotinas */
output to value(cDir + 'estrutura-sub-espec.txt') convert target 'iso8859-1'.

for each sub_rot_dtsul_proced
    where log_reg_padr = no
    no-lock:

    EXPORT sub_rot_dtsul_proced.
end.

output close.


/* estrutura - sub-rotinas */
output to value(cDir + 'tabelas-dic.txt') convert target 'iso8859-1'.

for each tab_dic_dtsul
    no-lock:

    EXPORT tab_dic_dtsul.
end.

output close.

/* sub-rotinas */
output to value(cDir + 'sub-rotinas-espec.txt') convert target 'iso8859-1'.

for each sub_rot_dtsul
    where log_reg_padr = no
    no-lock:

    EXPORT sub_rot_dtsul.
end.

output close.

