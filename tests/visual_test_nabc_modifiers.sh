#!/bin/bash
# Simple visual test for NABC glyph modifiers
# Opens a test file in nvim to visually verify syntax highlighting

TEST_FILE="/home/laercio/Documentos/gregorio.nvim/examples/nabc_glyph_modifiers.gabc"

echo "=== NABC Glyph Modifiers Visual Test ==="
echo ""
echo "Opening test file: $TEST_FILE"
echo ""
echo "Expected highlighting:"
echo "  - Neume codes (vi, pu, ta, etc.) should be highlighted as Keywords"
echo "  - Modifiers (S, G, M, -, >, ~) should be highlighted as SpecialChar"
echo "  - Numbers (1-9) after modifiers should be highlighted as Number"
echo ""
echo "Examples from the file:"
echo "  viS    → 'vi' as Keyword, 'S' as SpecialChar"
echo "  viS1   → 'vi' as Keyword, 'S' as SpecialChar, '1' as Number"
echo "  grS2   → 'gr' as Keyword, 'S' as SpecialChar, '2' as Number"
echo ""
echo "Press ENTER to open in nvim (or Ctrl+C to cancel)"
read

# Open in nvim with syntax enabled
nvim "$TEST_FILE"

echo ""
echo "Test complete."
