define variable {1}          as handle  no-undo.
define variable iterator_{2} as handle  no-undo.
define variable hasNext_{1}  as logical no-undo.

run iterator in {2}(output iterator_{2}).
run hasNext in iterator_{2}(output hasNext_{1}).
do while hasNext_{1} {&throws}:
    run next in iterator_{2}(output {1}).
    run hasNext in iterator_{2}(output hasNext_{1}).
