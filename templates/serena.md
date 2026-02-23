## Code Editing — Prefer Serena's Symbolic Tools

When Serena's tools are available and the language is supported, **prefer Serena's symbolic code-editing tools** over the built-in file tools:

- **Navigation**: Use `find_symbol`, `find_referencing_symbols`, and `get_symbols_overview` instead of Grep/Glob for locating code.
- **Editing**: Use `replace_symbol_body`, `insert_after_symbol`, `insert_before_symbol`, and `rename_symbol` instead of Edit for modifying code.
- **Context**: Use `get_symbols_overview` to understand file structure before making changes.
- **Before removing or renaming** any symbol, verify it is unused via `find_referencing_symbols`.

Serena auto-detects the project's languages. For files or languages Serena does not support, fall back to the standard Read, Edit, Grep, and Glob tools.
