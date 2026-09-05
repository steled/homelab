#!/bin/bash
shopt -s nullglob

for hook in "$(dirname "$0")/../githooks/"*; do
    hook_name="$(basename "$hook")"
    [[ "$hook_name" == *.bak ]] && continue
    ln -s -f "../../githooks/${hook_name}" "$(dirname "$0")/../.git/hooks/${hook_name}"
    if ! grep -qF "# run ${hook_name} script" "$(dirname "$0")/../.git/hooks/pre-commit"; then
        echo -e "\n# run ${hook_name} script" >> "$(dirname "$0")/../.git/hooks/pre-commit"
        echo "\$(dirname \"\$0\")/${hook_name}" >> "$(dirname "$0")/../.git/hooks/pre-commit"
    fi
done
