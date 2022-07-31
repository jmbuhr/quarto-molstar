# Molstar (Mol*) Extension for Quarto

WIP, not ready yet :)

This extension provides shortcodes for [molstar](https://github.com/molstar/molstar) in quarto.
Molstar can display macro-molecules such as proteins as well as molcular dynamics trajectories in an interactive viewer.
You can see it in action e.g. in the RCSB Protein Data Base: <https://www.rcsb.org/>, where it provides the 3d view for entries.
Follow me, if you want this right in your quarto reports (html only).

## Installing

```sh
quarto install extension jmbuhr/quarto-molstar
```

This will install the extension under the `_extensions` subdirectory.
If you're using version control, you will want to check in this directory.

## Using

To embed a protein straight from RCSB PDB, use the `{{< rcsb-pdb >}}` shortcode. For example:

```default
{{< rcsb-pdb 7sgl >}} 
```

will embed this protein: <https://www.rcsb.org/3d-view/7SGL> (there is no special meaning to this example; it was the molecule of the day when this README was written).

To embed a local pdb, use:

```default
{{< pdb ./path-to-prot.pdb >}} 
```

To embed a whole trajectory, use:

```default
{{< traj ./path-to-topoloy.gro ./path-to-trajectory.xtc >}} 
```

Note that embedding complete trajectories can result in large file sizes and high memory usage.



