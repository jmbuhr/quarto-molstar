




return {
  ['rcsb'] = function (args, kwargs)
    quarto.utils.dump(args)
    return pandoc.RawInline(
      'html',
      '<div id="app">' .. 'hello' .. '</div>'
    )
  end,
  -- ['rcsb-pdb'] = function (args, kwargs)
  --   quarto.utils.dump(args)
  -- end,
  -- ['rcsb-pdb'] = function (args, kwargs)
  --   quarto.utils.dump(args)
  -- end,
}
