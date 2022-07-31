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

## Limitations

Molstar viewers for local files are empty when the file is not served by a webserver such as `quarto preview` or GitHub pages.
This means it will not display your molecule when you simply open the rendered html with a browser,
even if you set the html to be self-contained.

The reason for this is the [Same-origin Policy](https://developer.mozilla.org/en-US/docs/Glossary/Same-origin_policy), a security measure in web browsers.
It and similar policies prevent that one document can access resources it is not supposed to access.
For example, an html document you downloaded is not allowed to execute code that reads personal files on your computer.
This also prevents it from loading your molecules from local paths.

## Update Mol* (extension developement)

The js and css files where downloaded from the [molstar web viewer](https://molstar.org/viewer/) in order to be up to date but also self-contained and functional without an internet connection. 

```bash
wget https://molstar.org/viewer/molstar.js
wget https://molstar.org/viewer/molstar.css
```


