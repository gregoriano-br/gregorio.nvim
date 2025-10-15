syntax region testR start=+{+ end=+}+ keepend
highlight link testR Special

enew!
set ft=test
call setline(1, "a{b}c")
syntax enable
sleep 100m

call cursor(1,2)
echo 'Pos 2 ({): ' . synIDattr(synID(line('.'), col('.'), 1), 'name')

call cursor(1,3)
echo 'Pos 3 (b): ' . synIDattr(synID(line('.'), 1), 1), 'name')

call cursor(1,4)
echo 'Pos 4 (}): ' . synIDattr(synID(line('.'), col('.'), 1), 'name')

quitall!
