all:
	pandoc -f markdown+autolink_bare_uris -sN  workbench-doc.md --output workbench-doc.html --css doc.css --metadata title="Lean Workbench" --lua-filter=mermaid.lua

pdf:
	pandoc -f markdown+autolink_bare_uris -sN  workbench-doc.md --output workbench-doc.pdf --metadata title="Lean Workbench" --lua-filter=mermaid-png.lua -V colorlinks=true -V urlcolor=blue
