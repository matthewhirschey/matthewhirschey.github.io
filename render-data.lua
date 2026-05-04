-- render-data.lua
-- Pandoc Lua filter that expands {{talks}}, {{projects}}, and {{writing}}
-- markers in the document body with HTML rendered from the corresponding
-- arrays in the document's YAML metadata. Lets us keep those sections as
-- structured data in index.qmd while preserving karpathy-style page order.

local talks = {}
local projects = {}
local writing = {}
local publications = {}

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
        logo  = to_str(p.logo),
        badge = to_str(p.badge),
        title = to_str(p.title),
        url   = to_str(p.url),
        desc  = md_to_html(p.desc),
      }
    end
  end
  if m.writing then
    for i, w in ipairs(m.writing) do
      writing[i] = {
        title = to_str(w.title),
        url   = to_str(w.url),
        img   = to_str(w.img),
        desc  = md_to_html(w.desc),
      }
    end
  end
  if m.publications then
    for i, p in ipairs(m.publications) do
      publications[i] = {
        title   = to_str(p.title),
        authors = to_str(p.authors),
        venue   = to_str(p.venue),
        year    = to_str(p.year),
        doi     = to_str(p.doi),
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
    if p.logo ~= "" then
      table.insert(parts, '    <div class="pico"><img src="' .. p.logo .. '" alt="' .. p.title .. '" /></div>')
    else
      table.insert(parts, '    <div class="pico">' .. p.badge .. '</div>')
    end
    table.insert(parts, '    <div class="pdesc">')
    table.insert(parts, '      <a href="' .. p.url .. '"><b>' .. p.title .. '</b></a> — ' .. p.desc)
    table.insert(parts, '    </div>')
    table.insert(parts, '    <div class="pend"></div>')
    table.insert(parts, '  </div>')
  end
  table.insert(parts, '</div>')
  return table.concat(parts, '\n')
end

local function render_writing()
  local parts = {
    '<div class="row writing-row">',
  }
  for _, w in ipairs(writing) do
    table.insert(parts, '  <div class="card wcard">')
    table.insert(parts, '    <a href="' .. w.url .. '" class="wthumb"><img src="' .. w.img .. '" alt="' .. w.title .. '" /></a>')
    table.insert(parts, '    <a href="' .. w.url .. '" class="wtitle">' .. w.title .. '</a>')
    table.insert(parts, '    <div class="wdesc">' .. w.desc .. '</div>')
    table.insert(parts, '  </div>')
  end
  table.insert(parts, '</div>')
  return table.concat(parts, '\n')
end

-- JSON string escape. `&` survives Pandoc's YAML parser intact, so we emit
-- a Unicode escape (&) to dodge Pandoc's HTML escaping and the browser's
-- script-tag termination scan ("</script>" inside a string would close the tag).
-- The < / > branches for `<` and `>` are belt-and-suspenders only —
-- Pandoc parses YAML scalars as inline content and silently strips bare HTML
-- tags before this function ever runs, so a title with `A <foo> B` already
-- arrives as `A  B`. If you genuinely need literal angle brackets in a title,
-- escape them in YAML as `\<` and `\>` or use HTML entities.
local function json_escape(s)
  if s == nil then return "" end
  s = s:gsub("\\", "\\\\")
  s = s:gsub('"', '\\"')
  s = s:gsub("\n", "\\n"):gsub("\r", "\\r"):gsub("\t", "\\t")
  s = s:gsub("&", "\\u0026")
  s = s:gsub("<", "\\u003c")
  s = s:gsub(">", "\\u003e")
  s = s:gsub("[%z\1-\31]", "")
  return s
end

-- Split "Foo A, Bar B*, Baz C" into JSON-LD authors. Strips `*` co-first markers
-- and "et al." entries. Drops trailing punctuation.
local function authors_to_jsonld(s)
  local clean = s:gsub("%.$", "")
  local out = {}
  for name in (clean .. ","):gmatch("([^,]+),%s*") do
    name = name:gsub("^%s+", ""):gsub("%s+$", ""):gsub("%*", "")
    if name ~= "" and not name:lower():match("^et al") then
      table.insert(out, '{"@type":"Person","name":"' .. json_escape(name) .. '"}')
    end
  end
  return table.concat(out, ",")
end

-- Pull the venue name from an author-styled string like
-- "Nature Communications (2025) 16:5771" → "Nature Communications".
local function periodical_name(venue)
  return (venue:gsub("%s*%(.*$", ""))
end

local function render_publications()
  local parts = {
    '<div class="pub-list">',
  }
  local emit_jsonld = (FORMAT == "html" or FORMAT == "html5" or FORMAT == "html4")
  for _, p in ipairs(publications) do
    table.insert(parts, '<div class="pub">')
    if p.doi ~= "" then
      table.insert(parts, '<a class="pub-title" href="' .. p.doi .. '" target="_blank" rel="noopener">' .. p.title .. '</a>')
    else
      table.insert(parts, '<span class="pub-title">' .. p.title .. '</span>')
    end
    table.insert(parts, '<span class="pub-authors">' .. p.authors .. '</span>')
    table.insert(parts, '<span class="pub-venue">' .. p.venue .. '</span>')
    table.insert(parts, '</div>')
    if emit_jsonld and p.doi ~= "" then
      local jsonld = {
        '<script type="application/ld+json">',
        '{',
        '"@context":"https://schema.org",',
        '"@type":"ScholarlyArticle",',
        '"name":"' .. json_escape(p.title) .. '",',
        '"author":[' .. authors_to_jsonld(p.authors) .. '],',
        '"datePublished":"' .. p.year .. '",',
        '"isPartOf":{"@type":"Periodical","name":"' .. json_escape(periodical_name(p.venue)) .. '"},',
        '"identifier":"' .. p.doi .. '",',
        '"sameAs":"' .. p.doi .. '",',
        '"url":"' .. p.doi .. '"',
        '}',
        '</script>',
      }
      table.insert(parts, table.concat(jsonld, ''))
    end
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
    elseif text == "{{writing}}" then
      return pandoc.RawBlock("html", render_writing())
    elseif text == "{{publications}}" then
      return pandoc.RawBlock("html", render_publications())
    end
  end
end

-- Run Meta before Para so the data is populated before we replace markers.
return {
  { Meta = Meta },
  { Para = Para },
}
