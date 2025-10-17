" Load the test file
edit test_nabc_lines.gabc

" Enable syntax highlighting
syntax on
filetype on

" Create a validation report
redir > nabc_lines_report.txt
echo "NABC Lines Header Recognition Test Report"
echo "========================================"
echo ""
echo "Checking for NABC Lines highlight groups:"
syntax list gabcNabcLinesField
syntax list gabcNabcLinesValue
echo ""
echo "File processed successfully."
redir END

quit
