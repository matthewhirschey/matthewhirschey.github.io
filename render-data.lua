-- render-data.lua
-- Pandoc Lua filter that replaces {{talks}} and {{projects}} markers in the
-- document body with HTML rendered from the `talks:` and `projects:` arrays
-- in the document's YAML metadata. Lets us keep those sections as structured
-- data in index.qmd while preserving the karpathy-style page order.

local talks = {}
local projects = {}

local function to_str(v)
  if v == nil then return "" end
  return pandoc.utils.stringify(v)
end

-- Render a YAML scalar that may contain inline markdown or raw HTML to an
-- HTML fragment, stripping the wrapping <p>…</p> Pandoc adds.
local function md_to_html(v)
  if v == nil then return "" end
  local s = pandoc.utils.stringify(v)
  local doc = pandoc.read(s, "markdown+raw_html")
  local html = pandoc.write(doc, "html")
  html = html:gsub("^%s*<p>(.-)</p>%s*$", "%1")
  return html
end

function Meta(m)
  if m.talks then
    for i, t in ipairs(m.talks) do
      talks[i] = {
        year  = to_str(t.year),
        venue = to_str(t.venue),
        loc   = to_str(t.loc),
      }
    end
  end
  if m.projects then
    for i, p in ipairs(m.projects) do
      projects[i] = {
        badge = to_str(p.badge),
        title = to_str(p.title),
        url   = to_str(p.url),
        desc  = md_to_html(p.desc),
      }
    end
  end
  return m
end

local function render_talks()
  local parts = {
    '<div style="background-color: #eee; padding-top: 1px; margin-top: 10px;">',
    '  <div id="featured-talks" class="container">',
    '    <div class="ctitle">featured talks</div>',
    '    <div class="row">',
  }
  for _, t in ipairs(talks) do
    table.insert(parts, '      <div class="card">')
    table.insert(parts, '        <span class="cyear">' .. t.year .. '</span>')
    table.insert(parts, '        <span class="cvenue">' .. t.venue .. '</span>')
    table.insert(parts, '        <span class="cloc">' .. t.loc .. '</span>')
    table.insert(parts, '      </div>')
  end
  table.insert(parts, '    </div>')
  table.insert(parts, '  </div>')
  table.insert(parts, '</div>')
  return table.concat(parts, '\n')
end

local function render_projects()
  local parts = {
    '<div id="pet-projects" class="container">',
    '  <div class="ctitle">projects</div>',
  }
  for _, p in ipairs(projects) do
    table.insert(parts, '  <div class="project">')
    table.insert(parts, '    <div class="pico">' .. p.badge .. '</div>')
    table.insert(parts, '    <div class="pdesc">')
    table.insert(parts, '      <a href="' .. p.url .. '"><b>' .. p.title .. '</b></a> — ' .. p.desc)
    table.insert(parts, '    </div>')
    table.insert(parts, '    <div class="pend"></div>')
    table.insert(parts, '  </div>')
  end
  table.insert(parts, '</div>')
  return table.concat(parts, '\n')
end

function Para(el)
  if #el.content == 1 and el.content[1].t == "Str" then
    local text = el.content[1].text
    if text == "{{talks}}" then
      return pandoc.RawBlock("html", render_talks())
    elseif text == "{{projects}}" then
      return pandoc.RawBlock("html", render_projects())
    end
  end
end

-- Run Meta before Para so the data is populated before we replace markers.
return {
  { Meta = Meta },
  { Para = Para },
}
