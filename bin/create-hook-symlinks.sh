#!/bin/bash

for hook in "$(dirname "$0")/../githooks/"*; do
    ln -s -f "../../githooks/$(basename $hook)" "$(dirname "$0")/../.git/hooks/$(basename $hook)"
    echo -e "\n# run $(basename $hook) script" >> "$(dirname "$0")/../.git/hooks/pre-commit"
    echo "\$(dirname \"\$0\")/$(basename $hook)" >> "$(dirname "$0")/../.git/hooks/pre-commit"
done
