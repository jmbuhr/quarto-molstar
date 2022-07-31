# Molstar (Mol*) Extension for Quarto

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
{{< rcsb 7sgl >}} 
```

will embed this protein: <https://www.rcsb.org/3d-view/7SGL> (there is no special meaning to this example; it was the molecule of the day when this README was written).

{{< mol-rcsb 7sgl >}} 

Get a local pdb file (or file from a url) with:

{{< mol-url ./path-to-protein.pdb >}} 

{{< mol-url https://files.rcsb.org/download/7sgl.pdb >}} 

Get a local xyz file with:

{{< mol-url ./example.xyz >}} 

Or a trajectory with:

{{< mol-traj example.pdb example.xtc >}}

## Update (extension developement)

The self-contained js and css files where downloaded from the [molstar web viewer](https://molstar.org/viewer/) in order to be up to date but also self-contained and functional without an internet connection. 

```bash
wget https://molstar.org/viewer/molstar.js
wget https://molstar.org/viewer/molstar.css
```

