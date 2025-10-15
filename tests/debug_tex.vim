" Debug script to check tex.vim loading
set runtimepath+=/home/laercio/Documentos/gregorio.nvim

" Try to include tex syntax manually
let s:save_syntax = exists('b:current_syntax') ? b:current_syntax : ''
unlet! b:current_syntax

echo "Trying to load tex.vim..."
try
	execute 'syntax include @texSyntax ' . $VIMRUNTIME . '/syntax/tex.vim'
	echo "SUCCESS: tex.vim loaded"
	echo "Cluster contents:"
	syntax list @texSyntax
catch /^Vim\%((\a\+)\)\=:E/
	echo "ERROR: " . v:exception
endtry

if !empty(s:save_syntax)
	let b:current_syntax = s:save_syntax
endif

echo "Press ENTER"
call getchar()
quitall!
