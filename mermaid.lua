local diagram_count = 0

function CodeBlock(el)
  if el.classes:includes("mermaid") then
    local tmp = os.tmpname() .. ".mmd"
    diagram_count = diagram_count + 1
    local out = "diagram_" .. diagram_count .. ".svg"
    -- write Mermaid code to tmp file
    print(tmp)
    local f = io.open(tmp, "w")
    f:write(el.text)
    f:close()
    -- call mermaid-cli
    os.execute("mmdc -i " .. tmp .. " -o " .. out)

    -- Create inline image
    local img = pandoc.Image("diagram", out)

    -- Wrap image in a link to the SVG file
    local link = pandoc.Link(img, out)

    return pandoc.Para{ link }
  end
end
