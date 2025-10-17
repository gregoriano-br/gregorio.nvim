set runtimepath+=/home/laercio/Documentos/gregorio.nvim

enew
call setline(1, '%%')
call setline(2, 'Test(abc)')

let g:gabc_devmode = 1
set filetype=gabc
syntax enable
runtime! syntax/gabc.vim
sleep 300m

" List all syntax groups
redir => syntax_output
silent! syntax list
redir END

" Check if gabcPitch is defined
if syntax_output =~ 'gabcPitch'
    echo 'gabcPitch IS DEFINED'
else
    echo 'gabcPitch NOT DEFINED'
endif

" Show gabcPitch definition
redir => pitch_output
silent! syntax list gabcPitch
redir END
echo pitch_output

qall!
