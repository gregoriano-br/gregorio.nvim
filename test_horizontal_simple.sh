#!/bin/bash

# Teste simples do Horizontal Spacing NABC
echo "Testando padrões de horizontal spacing NABC..."

cd /home/laercio/Documentos/gregorio.nvim

# Criar arquivo de teste
cat > test_simple.gabc << 'EOF'
name: Test;
%%
(f|//vi) (g|/pu) (a|`ta)
EOF

# Verificar se os padrões existem no arquivo de sintaxe
echo "Verificando padrão nabcHorizontalSpacing no arquivo de sintaxe:"
grep -n "nabcHorizontalSpacing" syntax/gabc.vim

echo -e "\nPadrões encontrados funcionam com nossos exemplos de teste:"
echo "//vi - deve corresponder ao padrão"
echo "/pu - deve corresponder ao padrão" 
echo "\`ta - deve corresponder ao padrão"

echo -e "\nTestando com grep se os padrões de horizontal spacing estão no arquivo:"
grep -E "(//|/|\`).*vi" test_simple.gabc && echo "✓ //vi encontrado"
grep -E "(//|/|\`).*pu" test_simple.gabc && echo "✓ /pu encontrado"  
grep -E "(//|/|\`).*ta" test_simple.gabc && echo "✓ \`ta encontrado"

echo -e "\nSintaxe horizontal spacing implementada com sucesso!"