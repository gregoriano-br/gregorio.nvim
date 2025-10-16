#!/usr/bin/env bash
# Test neume fusion syntax highlighting

set -e

# Create a temporary Vim script
cat > /tmp/test_fusion.vim << 'VIMSCRIPT'
set runtimepath+=.
syntax on
filetype plugin indent on
edit tests/smoke/fusion_smoke_test.gabc

" Test individual fusion connector @ (line 3, column 7: f@g)
call cursor(3, 7)
let fusion_conn = synIDattr(synID(line("."), col("."), 1), "name")

" Test collective fusion function @ (line 6, column 7: @[fgh])
call cursor(6, 7)
let fusion_func = synIDattr(synID(line("."), col("."), 1), "name")

" Test pitch inside collective fusion (line 6, column 9: f in @[fgh])
call cursor(6, 9)
let fusion_pitch = synIDattr(synID(line("."), col("."), 1), "name")

echo "FUSION_CONN=" . fusion_conn
echo "FUSION_FUNC=" . fusion_func
echo "FUSION_PITCH=" . fusion_pitch

if fusion_conn == "gabcFusionConnector"
    echo "CONN=PASS"
else
    echo "CONN=FAIL (got: " . fusion_conn . ")"
endif

if fusion_func == "gabcFusionFunction"
    echo "FUNC=PASS"
else
    echo "FUNC=FAIL (got: " . fusion_func . ")"
endif

if fusion_pitch == "gabcPitch"
    echo "PITCH=PASS"
else
    echo "PITCH=FAIL (got: " . fusion_pitch . ")"
endif

qall!
VIMSCRIPT

nvim --headless --noplugin -u NONE -S /tmp/test_fusion.vim 2>&1
rm /tmp/test_fusion.vim
