---
title: Artifact Architecture
date: 2026-07-17
category: docs
type: architecure
summary:
---

# Artifact

````
       document
          |
        reader
          |
        entry
          |
       validator
          |
       manifest
          |
       builder
	      |
        output

````

We're trying to make a publishing system that just works --- 
at least for our personal use. Sometimes there is documents 
or things that you want to see in another format, in pdf, webpage, etc.
Naturally you convert them by hand for each documents, but now
we're trying to automate that process.

*Why Markdown?*

Because we're trying to learn the format. There are countless format
that we can work on, but for now, we're choosing Markdown.
[Make a better argument]

## Design Principles

[TBD]


## Asterisk

Asterisk is the output we're trying to target for now. A site.
A collection of `.html` pages that being generated from `.md` sources.

### Concept

We have a notion of Category and Type. Category defines where an entry 
belongs. Type defines what an entry is, eg. it's an essay type belongs
in writings category.

We have directory and output directory.

Source directory contains all the source files, eg. Markdown files,
templates, assets, etc.

Output directory contains the full site.



#### Category and Type

[TBD]

#### Archive

Archive is a generated view containing every published entry ordered chronologically. Unlike other pages, it does not own content. It is derived entirely from existing entries.

#### Metadata

Metadata describes an entry independent of its output format.


#### Discovering Entries

Artifact discovers entries by recursively scanning the content directory for supported source files. Every discovered entry is parsed into a common internal representation before any output is generated.

### Structure

The Content tree would be something like this:

```
content # source
|
|-- writings/
|  |-- notes/
|  |-- essays/
| ...
|-- visuals/
|  |-- photograph/
|  |-- illustration/
| ...
|-- library/
|  |-- books/
|  |-- paper/
| ...
|-- self/
|  |-- logs/
|  |-- about/
| ...
|-- assets/
|  |-- static/
|  |-- templates/
| ...
|

```

The ouput directory would be something like this:

```
site # output
|
|-- index.html
|-- data/
|-- archive/
|  |-- index.html
| ...
|-- writings/
|  |-- index.html
|  |-- notes/
|  |-- essays/
| ...
|-- visuals/
|  |-- index.html
|  |-- photograph/
|  |-- illustration/
| ...
|-- library/
|  |-- index.html
|  |-- books/
|  |-- paper/
| ...
|-- self/
|  |-- index.html
|  |-- logs/
|  |-- about/
| ...
|

```
