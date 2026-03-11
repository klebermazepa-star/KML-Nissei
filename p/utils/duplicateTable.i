/* duplica um tabela {1} parauma temp-table {2} */

if {3} then
    empty temp-table {2}.

for each {1}:
    create {2}.
    buffer-copy {1} to {2}.
end.

