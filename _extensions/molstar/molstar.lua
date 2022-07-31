local function f(s, kwargs)
  return (s:gsub('($%b{})', function(w) return kwargs[w:sub(3, -2)] or w end))
end

local function fileExt(path)
  return path:match("[^.]+$")
end

local function addDependencies()
  quarto.doc.addHtmlDependency {
    name = 'molstar',
    version = 'v3.13.0',
    scripts = { './assets/molstar.js' },
    stylesheets = { './assets/molstar.css', 'assets/app-container.css' }
  }
end

local function rcsbViewer(appId, pdbId)
  local subs = { app = appId, pdb = pdbId }
  return f([[
         <script type="text/javascript">
          molstar.Viewer.create('${app}', {
                layoutIsExpanded: false,
                layoutShowControls: false,
                layoutShowRemoteState: false,
                layoutShowSequence: false,
                layoutShowLog: false,
                layoutShowLeftPanel: true,
                viewportShowExpand: true,
                viewportShowSelectionMode: false,
                viewportShowAnimation: true,
                pdbProvider: "rcsb",
                emdbProvider: "rcsb",
          }).then(viewer => {
          viewer.loadPdb('${pdb}');
          });
          </script>
          ]], subs)
end

local function urlViewer(appId, topPath)
  local subs = {
    app = appId,
    top = topPath,
    topExt = fileExt(topPath),
  }
  return f([[
         <script type="text/javascript">
          molstar.Viewer.create('${app}', {
                layoutIsExpanded: false,
                layoutShowControls: false,
                layoutShowRemoteState: false,
                layoutShowSequence: false,
                layoutShowLog: false,
                layoutShowLeftPanel: true,
                viewportShowExpand: true,
                viewportShowSelectionMode: false,
                viewportShowAnimation: true,
                pdbProvider: "rcsb",
                emdbProvider: "rcsb",
          }).then(viewer => {
          viewer.loadStructureFromUrl('${top}', format='${topExt}');
          });
          </script>
          ]], subs)
end

local function trajViewer(appId, topPath, trajPath)
  local subs = {
    app     = appId,
    pdb     = pdbPath,
    top     = topPath,
    topExt  = fileExt(topPath),
    traj    = trajPath,
    trajExt = fileExt(trajPath),
  }
  return f([[
         <script type="text/javascript">
          molstar.Viewer.create('${app}', {
                layoutIsExpanded: false,
                layoutShowControls: false,
                layoutShowRemoteState: false,
                layoutShowSequence: false,
                layoutShowLog: false,
                layoutShowLeftPanel: true,
                viewportShowExpand: true,
                viewportShowSelectionMode: false,
                viewportShowAnimation: true,
                pdbProvider: "rcsb",
                emdbProvider: "rcsb",
          }).then(viewer => {
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

return {
  ['mol-rcsb'] = function(args, kwargs)
    -- return early if the output format is unsupported
    if not quarto.doc.isFormat("html:js") then
      return pandoc.Null()
    end

    addDependencies()

    -- parse arguments
    local pdbId = pandoc.utils.stringify(args[1])
    local appId = 'app-' .. pdbId

    -- create molstar app div and js
    return {
      pandoc.Div(
        {},
        { id = appId, class = 'molstar-app' }
      ),
      pandoc.RawBlock('html', rcsbViewer(appId, pdbId))
    }
  end,
  ['mol-url'] = function(args, kwargs)
    if not quarto.doc.isFormat("html:js") then
      return pandoc.Null()
    end

    addDependencies()

    -- parse arguments
    local pdbPath = pandoc.utils.stringify(args[1])
    local appId = 'app-' .. pdbPath

    -- create molstar app div and js
    return {
      pandoc.Div(
        {},
        { id = appId, class = 'molstar-app' }
      ),
      pandoc.RawBlock('html', urlViewer(appId, pdbPath))
    }
  end,
  ['mol-traj'] = function(args, kwargs)
    if not quarto.doc.isFormat("html:js") then
      return pandoc.Null()
    end

    addDependencies()

    -- parse arguments
    local topPath = pandoc.utils.stringify(args[1])
    local trajPath = pandoc.utils.stringify(args[2])
    local appId = 'app-' .. topPath .. trajPath

    -- create molstar app div and js
    return {
      pandoc.Div(
        {},
        { id = appId, class = 'molstar-app' }
      ),
      pandoc.RawBlock('html', trajViewer(appId, topPath, trajPath))
    }
  end,
}
