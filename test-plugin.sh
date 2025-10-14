#!/usr/bin/env bash

# Test script for gregorio.nvim plugin
# This script performs basic checks to ensure the plugin is working correctly

echo "Testing gregorio.nvim plugin..."
echo "================================"

# Check if we're in the right directory
if [ ! -f "plugin/gregorio.vim" ]; then
    echo "Error: This script must be run from the plugin root directory"
    echo "Expected to find plugin/gregorio.vim"
    exit 1
fi

echo "✓ Plugin directory structure found"

# Check required files exist
required_files=(
    "plugin/gregorio.vim"
    "ftdetect/gabc.vim"
    "ftplugin/gabc.vim"
    "syntax/gabc.vim"
    "lua/gabc/init.lua"
    "lua/gabc/markup.lua"
    "lua/gabc/transpose.lua"
    "lua/gabc/utils.lua"
    "lua/gabc/nabc.lua"
    "snippets/gabc.snippets"
    "doc/gregorio.txt"
    "README.md"
    "LICENSE"
)

for file in "${required_files[@]}"; do
    if [ -f "$file" ]; then
        echo "✓ Found $file"
    else
        echo "✗ Missing $file"
    fi
done

# Check if example file has correct syntax
if [ -f "example.gabc" ]; then
    echo "✓ Example GABC file found"
    
    # Basic syntax checks
    if grep -q "^name:" example.gabc; then
        echo "✓ Example has proper header"
    else
        echo "✗ Example missing proper header"
    fi
    
    if grep -q "^%%" example.gabc; then
        echo "✓ Example has header separator"
    else
        echo "✗ Example missing header separator"
    fi
    
    if grep -q "nabc-lines:" example.gabc; then
        echo "✓ Example includes NABC extension"
    else
        echo "! Example doesn't include NABC extension (optional)"
    fi
else
    echo "! No example file found (optional)"
fi

# Check documentation
if [ -f "doc/gregorio.txt" ]; then
    if grep -q "*gregorio.txt*" doc/gregorio.txt; then
        echo "✓ Vim help documentation is properly formatted"
    else
        echo "✗ Vim help documentation formatting issue"
    fi
fi

# Check if Lua modules are syntactically correct (basic check)
for lua_file in lua/gabc/*.lua; do
    if [ -f "$lua_file" ]; then
        if lua -l luac -e "luac.compile('$lua_file')" 2>/dev/null; then
            echo "✓ $lua_file syntax OK"
        else
            echo "✗ $lua_file has syntax errors"
        fi
    fi
done

echo ""
echo "Test completed!"
echo ""
echo "To install this plugin:"
echo "1. Copy the entire directory to your Neovim configuration"
echo "2. Add require('gabc').setup() to your init.lua"
echo "3. Restart Neovim"
echo "4. Open example.gabc to test functionality"
echo ""
echo "For detailed usage instructions, see README.md or :help gabc"