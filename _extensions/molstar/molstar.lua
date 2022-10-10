-- for development:
local p = function (x)
  quarto.log.output(x)
end

---@type boolean
local useIframes = false
if quarto.doc.isFormat("revealjs") then
  useIframes = true
end

---@param path string Path to the file
---@return string|nil The file content
local function readFile(path)
  local file = io.open(path, "r")
  if not file then return nil end
  local content = file:read "*a"
  file:close()
  return content
end

---Format string like in bash or python,
---e.g. f('Hello ${one}', {one = 'world'})
---@param s string The string to format
---@param kwargs {[string]: string} A table with key-value replacemen pairs
---@return string
local function f(s, kwargs)
  return (s:gsub('($%b{})', function(w) return kwargs[w:sub(3, -2)] or w end))
end

---Get the file extension
---@param path string
---@return string
local function fileExt(path)
  return path:match("[^.]+$")
end

---Add molstar css and js dependencies.
---Can be linked / embedded for regular html documents,
---but have to be copied for revealjs to be used in iframes
local function addDependencies()
  quarto.doc.addHtmlDependency {
    name = 'molstar',
    version = 'v3.13.0',
    scripts = { './assets/molstar.js' },
    stylesheets = { './assets/molstar.css', 'assets/app-container.css' },
  }
  if useIframes then
    quarto.doc.addFormatResource('./assets/molstar.css')
    quarto.doc.addFormatResource('./assets/molstar.js')
  end
end

---Merge user provided molstar options with defaults
---@param userOptions table
---@return string JSON string to pass to molstar
local function mergeMolstarOptions(userOptions)
  local defaultOptions = {
    layoutIsExpanded = false,
    layoutShowControls = false,
    layoutShowRemoteState = false,
    layoutShowSequence = false,
    layoutShowLog = false,
    layoutShowLeftPanel = true,
    viewportShowExpand = true,
    viewportShowSelectionMode = false,
    viewportShowAnimation = true,
    pdbProvider = "rcsb",
    emdbProvider = "rcsb",
  }
  if userOptions == nil then
    return quarto.json.encode(defaultOptions)
  end

  for k, v in pairs(userOptions) do
    local value = pandoc.utils.stringify(v)
    if value == 'true' then value = true end
    if value == 'false' then value = false end
    defaultOptions[k] = value
  end

  return quarto.json.encode(defaultOptions)
end

---@param viewerFunctionString string
---@return string
local function wrapInlineIframe(viewerFunctionString)
  return [[
    <iframe id="${appId}" class="molstar-app" seamless allow="fullscreen" srcdoc='
    <html>
    <head>
    <script type="text/javascript" src="./molstar.js"></script>
    <link rel="stylesheet" type="text/css" href="./molstar.css"/>
    </head>
    <body>
    <div id="${appId}" class="molstar-app"></div>
    <script type="text/javascript">
    molstar.Viewer.create("${appId}", ${options}).then(viewer => {
    ]] .. viewerFunctionString .. [[
    });
    </script>
    </body>
    </html>
    '>
    </iframe>
    ]]
end

---@param viewerFunctionString string
---@return string
local function wrapInlineDiv(viewerFunctionString)
  return [[
    <div id="${appId}" class="molstar-app"></div>
    <script type="text/javascript">
    molstar.Viewer.create("${appId}", ${options}).then(viewer => {
    ]] .. viewerFunctionString .. [[
    });
    </script>
    ]]
end

---@param args table
---@return string
local function createViewer(args)
  local subs = {
    appId = args.appId,
    url = args.url,
    urlExtension = args.urlExtension,
    pdb = args.pdbId,
    trajUrl = args.trajUrl,
    trajExtension = args.trajExtension,
    volumeUrl = args.volumeUrl,
    volumeExtension = args.volumeExtension,
    snapshotUrl = args.snapshotUrl,
    snapshotExtension = args.snapshotExtension,
    afdb = args.afdb,
    data = args.data,
    options = mergeMolstarOptions(args.userOptions)
  }

  local wrapper
  local viewerFunction

  if useIframes then
    wrapper = wrapInlineIframe
  else
    wrapper = wrapInlineDiv
  end

  if args.data then -- if we have embedded data, use it
    viewerFunction = 'viewer.loadStructureFromData(`${data}`, format="${urlExtension}");'
  elseif args.pdbId then -- fetch from rcsb pdbb if an ID is given
    viewerFunction = 'viewer.loadPdb("${pdb}");'
  elseif args.url and args.trajUrl then -- load topology + trajectory if both are given
    viewerFunction = [[
    viewer.loadTrajectory(
    {
      model: {
        kind: "model-url", url: "${url}", format: "${urlExtension}"
      },
      coordinates: {
        kind: "coordinates-url", url: "${trajUrl}",
        format: "${trajExtension}", isBinary: true
      }
    }
    );
    ]]
  elseif args.volumeUrl and args.volumeExtension then
    viewerFunction = [[
    viewer.loadStructureFromUrl("${url}", "${urlExtension}")
    viewer.loadVolumeFromUrl(
    {url: "${volumeUrl}",
    format: "${volumeExtension}",
    isBinary: false},
    [{type: "absolute",
    alpha: 1,
    value: 0.001, 
      }
      ]
    );
    ]]
  elseif args.snapshotUrl and args.snapshotExtension then
    viewerFunction = 'viewer.loadSnapshotFromUrl(url="${snapshotUrl}", "${snapshotExtension}");'
  elseif args.afdb then
    viewerFunction = 'viewer.loadAlphaFoldDb(afdb="${afdb}")'
  else -- otherwise read from url (local or remote)
    viewerFunction = 'viewer.loadStructureFromUrl("${url}", format="${urlExtension}");'
  end

  return f(wrapper(viewerFunction), subs)
end

return {
  ['mol-rcsb'] = function(args, kwargs)
    -- return early if the output format is unsupported
    if not quarto.doc.isFormat("html:js") then
      return pandoc.Null()
    end

    addDependencies()

    local pdbId = pandoc.utils.stringify(args[1])
    local appId = 'app-' .. pdbId

    return pandoc.RawBlock('html', createViewer {
      appId = appId,
      pdbId = pdbId,
      userOptions = kwargs
    })
  end,

  ['mol-afdb'] = function(args, kwargs)
    -- return early if the output format is unsupported
    if not quarto.doc.isFormat("html:js") then
      return pandoc.Null()
    end

    addDependencies()

    local afdb = pandoc.utils.stringify(args[1])
    local appId = 'app-' .. afdb

    return pandoc.RawBlock('html', createViewer {
      appId = appId,
      afdb = afdb,
      userOptions = kwargs
    })
  end,

  ['mol-url'] = function(args, kwargs, meta)
    if not quarto.doc.isFormat("html:js") then
      return pandoc.Null()
    end

    addDependencies()

    local url = pandoc.utils.stringify(args[1])
    local appId = 'app-' .. url
    local urlExtension = fileExt(url)
    local molstarMeta = ''
    if meta.molstar then
      molstarMeta = pandoc.utils.stringify(meta.molstar)
    end
    local pdbContent
    if molstarMeta == 'embed' and not useIframes then
      ---@type string|nil
      pdbContent = readFile(url)
    end
    return pandoc.RawBlock('html', createViewer {
      appId = appId,
      url = url,
      data = pdbContent,
      urlExtension = urlExtension,
      userOptions = kwargs
    })
  end,
  
  ['mol-snapshot'] = function(args, kwargs, meta)
    if not quarto.doc.isFormat("html:js") then
      return pandoc.Null()
    end

    addDependencies()

    local url = pandoc.utils.stringify(args[1])
    local appId = 'app-' .. url

    return pandoc.RawBlock('html', createViewer {
      appId = appId,
      snapshotUrl = url,
      snapshotExtension = fileExt(url),
      userOptions = kwargs
    })
  end,

  ['mol-traj'] = function(args, kwargs)
    if not quarto.doc.isFormat("html:js") then
      return pandoc.Null()
    end

    addDependencies()

    local url = pandoc.utils.stringify(args[1])
    local trajUrl = pandoc.utils.stringify(args[2])
    local appId = 'app-' .. url .. trajUrl

    return pandoc.RawBlock('html', createViewer {
      appId = appId,
      url = url,
      trajUrl = trajUrl,
      urlExtension = fileExt(url),
      trajExtension = fileExt(trajUrl),
      userOptions = kwargs
    })
  end,

  ['mol-volume'] = function(args, kwargs)
    if not quarto.doc.isFormat("html:js") then
      return pandoc.Null()
    end

    addDependencies()

    local url = pandoc.utils.stringify(args[1])
    local volumeUrl = pandoc.utils.stringify(args[2])
    local appId = 'app-' .. url .. volumeUrl

    return pandoc.RawBlock('html', createViewer {
      appId = appId,
      url = url,
      volumeUrl = volumeUrl,
      urlExtension = fileExt(url),
      volumeExtension = fileExt(volumeUrl),
      userOptions = kwargs
    })
  end,

}
