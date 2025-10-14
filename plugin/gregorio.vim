" gregorio.vim - Gregorio plugin for Neovim
" Author: Laércio de Sousa
" Version: 1.0.0
" Description: Adds support for Gregorio project files with syntax highlighting,
"              snippets, and editing commands for GABC Gregorian Chant Notation
"              (including NABC extended notation for ancient neumes)

if exists('g:loaded_gabc') || v:version < 700 || &compatible
  finish
endif
let g:loaded_gabc = 1

" Default key mappings (can be disabled by setting g:gabc_no_default_mappings = 1)
if !exists('g:gabc_no_default_mappings') || !g:gabc_no_default_mappings
  " Transpose commands
  autocmd FileType gabc nnoremap <buffer> <silent> <C-A-=> :GabcTransposeUp<CR>
  autocmd FileType gabc vnoremap <buffer> <silent> <C-A-=> :GabcTransposeUp<CR>gv
  autocmd FileType gabc nnoremap <buffer> <silent> <C-A--> :GabcTransposeDown<CR>
  autocmd FileType gabc vnoremap <buffer> <silent> <C-A--> :GabcTransposeDown<CR>gv

  " Markup commands
  autocmd FileType gabc nnoremap <buffer> <silent> <C-A-b> :GabcAddBold<CR>
  autocmd FileType gabc vnoremap <buffer> <silent> <C-A-b> :GabcAddBold<CR>gv
  autocmd FileType gabc nnoremap <buffer> <silent> <C-A-i> :GabcAddItalic<CR>
  autocmd FileType gabc vnoremap <buffer> <silent> <C-A-i> :GabcAddItalic<CR>gv
  autocmd FileType gabc nnoremap <buffer> <silent> <C-A-c> :GabcAddColor<CR>
  autocmd FileType gabc vnoremap <buffer> <silent> <C-A-c> :GabcAddColor<CR>gv
  autocmd FileType gabc nnoremap <buffer> <silent> <C-A-s> :GabcAddSmallCaps<CR>
  autocmd FileType gabc vnoremap <buffer> <silent> <C-A-s> :GabcAddSmallCaps<CR>gv
  autocmd FileType gabc nnoremap <buffer> <silent> <C-A-u> :GabcAddUnderline<CR>
  autocmd FileType gabc vnoremap <buffer> <silent> <C-A-u> :GabcAddUnderline<CR>gv
  autocmd FileType gabc nnoremap <buffer> <silent> <C-A-t> :GabcAddTeletype<CR>
  autocmd FileType gabc vnoremap <buffer> <silent> <C-A-t> :GabcAddTeletype<CR>gv
  autocmd FileType gabc nnoremap <buffer> <silent> <C-A-r> :GabcRemoveMarkup<CR>
  autocmd FileType gabc vnoremap <buffer> <silent> <C-A-r> :GabcRemoveMarkup<CR>gv

  " Utility commands
  autocmd FileType gabc nnoremap <buffer> <silent> <C-A-l> :GabcFillParens<CR>
  autocmd FileType gabc vnoremap <buffer> <silent> <C-A-l> :GabcFillParens<CR>gv
  autocmd FileType gabc nnoremap <buffer> <silent> <C-A-L> :GabcConvertLigaturesToTags<CR>
  autocmd FileType gabc nnoremap <buffer> <silent> <C-A-T> :GabcConvertTagsToLigatures<CR>
endif

" Define commands using Lua functions
command! -range GabcTransposeUp lua require('gabc').transpose.up(<line1>, <line2>)
command! -range GabcTransposeDown lua require('gabc').transpose.down(<line1>, <line2>)

command! -range GabcAddBold lua require('gabc').markup.add('b', <line1>, <line2>)
command! -range GabcAddItalic lua require('gabc').markup.add('i', <line1>, <line2>)
command! -range GabcAddColor lua require('gabc').markup.add('c', <line1>, <line2>)
command! -range GabcAddSmallCaps lua require('gabc').markup.add('sc', <line1>, <line2>)
command! -range GabcAddUnderline lua require('gabc').markup.add('ul', <line1>, <line2>)
command! -range GabcAddTeletype lua require('gabc').markup.add('tt', <line1>, <line2>)
command! -range GabcRemoveMarkup lua require('gabc').markup.remove(<line1>, <line2>)

command! -range GabcFillParens lua require('gabc').utils.fill_parens(<line1>, <line2>)
command! GabcConvertLigaturesToTags lua require('gabc').utils.convert_ligatures_to_tags()
command! GabcConvertTagsToLigatures lua require('gabc').utils.convert_tags_to_ligatures()

" Additional utility commands
command! GabcValidate lua require('gabc').utils.validate()
command! GabcCleanFormat lua require('gabc').utils.clean_format()
command! GabcToggleNabc lua require('gabc').nabc.toggle_nabc_extension()
command! GabcInfo lua print(vim.inspect(require('gabc').info()))

" Status line function for NABC detection
function! GabcStatusNabc()
  if &filetype ==# 'gabc'
    return luaeval("require('gabc').nabc.status()")
  endif
  return ''
endfunction

" Auto commands for NABC status updates
augroup GabcNabc
  autocmd!
  autocmd BufEnter,TextChanged,TextChangedI *.gabc lua require('gabc').nabc.update_status()
augroup END