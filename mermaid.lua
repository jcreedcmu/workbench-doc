function CodeBlock(el)
  if el.classes:includes("mermaid") then
    local tmp = os.tmpname() .. ".mmd"
    local out = os.tmpname() .. ".svg"
    -- write Mermaid code to tmp file
    print(tmp)
    local f = io.open(tmp, "w")
    f:write(el.text)
    f:close()
    -- call mermaid-cli
    os.execute("mmdc -i " .. tmp .. " -o " .. out)
    -- read SVG back into Pandoc document

    local svg = io.open(out):read("*a")
    return pandoc.RawBlock("html", svg)
  end
end
