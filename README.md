# Page Viewer

This is a dumb little app for dynamically rendering a directory full of markdown files on a website. It has the following additional features:

* `_index.md` will be displayed as the index document if it exists. Otherwise a simple directory listing is displayed.
* Integrates with [Docverter](http://www.docverter.com) for on-the-fly PDF conversion
* Code blocks will get syntax highlighted using Pygments

## Installation

```
gem 'page_viewer', git: 'https://github.com/peterkeen/page_viewer'
```

## Usage

Here's an example `config.ru` file:

```
require 'page_viewer'

PageViewer::App.set :page_root, '/path/to/markdown_files'

run PageViewer::App
```
