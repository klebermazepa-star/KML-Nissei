
output to value(session:temp-directory + 'temp.log':u)
    convert target 'iso8859-1':u.

for each esp_layout_column
    no-lock:

    display
        esp_layout_column
        with stream-io width 320 no-box down.
end.

output close.

run utils/showReport.p(session:temp-directory + 'temp.log':u).
