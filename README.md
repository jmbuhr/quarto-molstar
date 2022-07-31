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

Usage examples are in `index.qmd`, which you can see rendered locally and served with GitHub pages here: 
<https://jmbuhr.de/quarto-molstar/>

## Update (extension developement)

The self-contained js and css files where downloaded from the [molstar web viewer](https://molstar.org/viewer/) in order to be up to date but also self-contained and functional without an internet connection. 

```bash
wget https://molstar.org/viewer/molstar.js
wget https://molstar.org/viewer/molstar.css
```

