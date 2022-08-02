local function f(s, kwargs)
  return (s:gsub('($%b{})', function(w) return kwargs[w:sub(3, -2)] or w end))
end

local function fileExt(path)
  return path:match("[^.]+$")
end

local function addDependencies(useIframes)
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
  if kwargs == nil then
    return quarto.json.encode(defaultOptions)
  end

  for k, v in pairs(userOptions) do
    value = pandoc.utils.stringify(v)
    if value == 'true' then value = true end
    if value == 'false' then value = false end
    defaultArgs[k] = value
  end

  return quarto.json.encode(defaultOptions)
end

local function rcsbViewer(appId, pdbId, userOptions)
  local subs = { appId = appId, pdb = pdbId, height = height, options = mergeMolstarOptions(userOptions) }
  return f([[
         <script type="text/javascript">
          molstar.Viewer.create("${appId}", ${options}).then(viewer => {
            viewer.loadPdb("${pdb}");
          });
          </script>
          ]], subs)
end

local function rcsbViewerIframe(appId, pdbId, userOptions)
  local frameId = 'frame' .. appId
  local subs = { frameId = frameId, appId = appId, pdb = pdbId, options = mergeMolstarOptions(userOptions) }
  return f([[
         <iframe id='${frameId}' class="molstar-app" seamless allow="fullscreen" srcdoc='
         <html>
         <head>
         <script type="text/javascript" src="./molstar.js"></script>
         <link rel="stylesheet" type="text/css" href="./molstar.css"/>
         </head>
         <body>
         <div id="${appId}"></div>
         <script type="text/javascript">
          molstar.Viewer.create("${appId}", ${options}).then(viewer => {
            viewer.loadPdb("${pdb}");
          });
          </script>
          </body>
          </html>
          '>
          </iframe>
          ]], subs)
end

local function urlViewer(appId, topPath, userOptions)
  local subs = {
    appId = appId,
    top = topPath,
    topExt = fileExt(topPath),
    options = mergeMolstarOptions(molstarOptions)
  }
  return f([[
         <script type="text/javascript">
          molstar.Viewer.create('${appId}', ${options}).then(viewer => {
            viewer.loadStructureFromUrl('${top}', format='${topExt}');
          });
          </script>
          ]], subs)
end

local function urlViewerIframe(appId, topPath, userOptions)
  local frameId = 'frame' .. appId
  local subs = {
    appId = appId,
    top = topPath,
    frameId = frameId,
    topExt = fileExt(topPath),
    options = mergeMolstarOptions(molstarOptions)
  }
  return f([[
         <iframe id="${frameId}" class="molstar-app" seamless allow="fullscreen" srcdoc='
         <html>
         <head>
         <script type="text/javascript" src="./molstar.js"></script>
         <link rel="stylesheet" type="text/css" href="./molstar.css"/>
         </head>
         <body>
         <div id="${appId}"></div>
         <script type="text/javascript">
          molstar.Viewer.create("${appId}", ${options}).then(viewer => {
            viewer.loadStructureFromUrl("${top}", format="${topExt}");
          });
          </script>
          '>
          </iframe>
          ]], subs)
end

local function trajViewer(appId, topPath, trajPath, userOptions)
  local subs = {
    appId   = appId,
    top     = topPath,
    topExt  = fileExt(topPath),
    traj    = trajPath,
    trajExt = fileExt(trajPath),
    options = mergeMolstarOptions(molstarOptions)
  }
  return f([[
         <script type="text/javascript">
          molstar.Viewer.create('${appId}', ${options}).then(viewer => {
            viewer.loadTrajectory(
            {
              model: {
                kind: 'model-url', url: '${top}', format: '${topExt}'
              },
              coordinates: {
                kind: 'coordinates-url', url: '${traj}',
                format: '${trajExt}', isBinary: true
              }
            }
            );
          });
          </script>
          ]], subs)
end

local function trajViewerIframe(appId, topPath, trajPath, userOptions)
  local frameId = 'frame' .. appId
  local subs = {
    appId   = appId,
    frameId = frameId,
    top     = topPath,
    topExt  = fileExt(topPath),
    traj    = trajPath,
    trajExt = fileExt(trajPath),
    options = mergeMolstarOptions(molstarOptions)
  }
  return f([[
         <iframe id='${frameId}' class="molstar-app" seamless allow="fullscreen" srcdoc='
         <html>
         <head>
         <script type="text/javascript" src="./molstar.js"></script>
         <link rel="stylesheet" type="text/css" href="./molstar.css"/>
         </head>
         <body>
         <div id="${appId}"></div>
         <script type="text/javascript">
          molstar.Viewer.create("${appId}", ${options}).then(viewer => {
            viewer.loadTrajectory(
            {
              model: {
                kind: "model-url", url: "${top}", format: "${topExt}"
              },
              coordinates: {
                kind: "coordinates-url", url: "${traj}",
                format: "${trajExt}", isBinary: true
              }
            }
            );
          });
          </script>
          '>
          </iframe>
          ]], subs)
end

return {
  ['mol-rcsb'] = function(args, kwargs)
    -- return early if the output format is unsupported
    if not quarto.doc.isFormat("html:js") then
      return pandoc.Null()
    end

    if quarto.doc.isFormat("revealjs") then
      useIframes = true
    end

    addDependencies(useIframes)

    local pdbId = pandoc.utils.stringify(args[1])
    local appId = 'app-' .. pdbId

    if useIframes then
      return pandoc.RawBlock('html', rcsbViewerIframe(appId, pdbId, kwargs))
    else
      return {
        pandoc.Div(
          {},
          { id = appId, class = 'molstar-app' }
        ),
        pandoc.RawBlock('html', rcsbViewer(appId, pdbId, kwargs)),
      }
    end
  end,

  ['mol-url'] = function(args, kwargs)
    if not quarto.doc.isFormat("html:js") then
      return pandoc.Null()
    end

    if quarto.doc.isFormat("revealjs") then
      useIframes = true
    end

    addDependencies(useIframes)

    local pdbPath = pandoc.utils.stringify(args[1])
    local appId = 'app-' .. pdbPath

    if useIframes then
      return pandoc.RawBlock('html', urlViewerIframe(appId, pdbPath, kwargs))
    else
      return {
        pandoc.Div(
          {},
          { id = appId, class = 'molstar-app' }
        ),
        pandoc.RawBlock('html', urlViewer(appId, pdbPath, kwargs)),
      }
    end
  end,

  ['mol-traj'] = function(args, kwargs)
    if not quarto.doc.isFormat("html:js") then
      return pandoc.Null()
    end

    if quarto.doc.isFormat("revealjs") then
      useIframes = true
    end

    addDependencies()

    local topPath = pandoc.utils.stringify(args[1])
    local trajPath = pandoc.utils.stringify(args[2])
    local appId = 'app-' .. topPath .. trajPath

    if useIframes then
      return pandoc.RawBlock('html', trajViewerIframe(appId, topPath, trajPath, kwargs))
    else
      return {
        pandoc.Div(
          {},
          { id = appId, class = 'molstar-app' }
        ),
        pandoc.RawBlock('html', trajViewer(appId, topPath, trajPath, kwargs))
      }
    end
  end,
}
