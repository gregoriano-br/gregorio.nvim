" GABC filetype plugin
" This file contains GABC-specific settings

if exists('b:did_ftplugin')
  finish
endif
let b:did_ftplugin = 1

" Comment settings for GABC (uses % for comments)
setlocal commentstring=%\ %s
setlocal comments=:%

" Set up folding for GABC sections
setlocal foldmethod=expr
setlocal foldexpr=GabcFoldLevel(v:lnum)

" GABC-specific options
setlocal textwidth=0
setlocal wrap
setlocal linebreak

" Auto-closing pairs specific to GABC
inoremap <buffer> ( ()<Left>
inoremap <buffer> [ []<Left>
inoremap <buffer> < <><Left>

" Define fold levels for GABC
function! GabcFoldLevel(lnum)
  let line = getline(a:lnum)
  
  " Header section (before %%)
  if line =~ '^%%\s*$'
    return 0
  endif
  
  " Header lines
  if line =~ '^\w\+:'
    return 1
  endif
  
  " Empty lines
  if line =~ '^\s*$'
    return '='
  endif
  
  return 0
endfunction

" Undo settings when buffer is unloaded
let b:undo_ftplugin = 'setlocal commentstring< comments< foldmethod< foldexpr< textwidth< wrap< linebreak<'
let b:undo_ftplugin .= ' | iunmap <buffer> ('
let b:undo_ftplugin .= ' | iunmap <buffer> ['
let b:undo_ftplugin .= ' | iunmap <buffer> <'