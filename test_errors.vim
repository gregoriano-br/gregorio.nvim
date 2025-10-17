" Load the test file
edit test_error_detection.gabc

" Enable syntax highlighting
syntax on
filetype on

" Save syntax state for analysis
redir > syntax_output.txt
syntax list
redir END

" Create a simple validation report
redir > error_report.txt
echo "GABC/NABC Error Detection Test Report"
echo "====================================="
echo ""
echo "Checking for Error highlight groups:"
syntax list gabcError
syntax list nabcError
echo ""
echo "File processed successfully."
redir END

quit
