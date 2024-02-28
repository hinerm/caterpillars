# caterpillars.github.io
Dynamic caterpillar documentation

## Purpose

The goal of this repository is to establish mechanisms for automatically
creating pages and a menu structure from a collection of raw data and images.

## Usage

There are two scripts for auto-generation live in the `scripts` subdirectory:
one for generating species pages for each species and one for building the
taxonomy menu.

```
base_directory
|-- scripts
|   |-- make_menu.sh
|   |-- make_species.sh
```

### Species pages

The `make_species.sh` script takes two inputs:
1. A path to a directory that contains any number of sub-directories, named for
   an individual, containing any number of images related to that individual.
2. A `csv` file formatted with each line containing data for an individual.
   Currently assume the first column is a unique identifier matching the
   corresponding image folders.

This script would need to be adjusted for real-world `csv` structure.

Sample usage in the current repository:

```
$ scripts/make_species.sh docs/assets/cats cats.csv
```

### Site menu

The `make_menu.sh` script takes one input:
1. A file with the desired taxonomy structure, with each taxonomic level indented by an additional space, with genus as the leaves

Sample usage:

```
$ scripts/make_menu.sh taxonomy.txt
```

## Key Elements

This is brief explanation of key pieces of the site. They should not need
manual adjustment, but could be adjusted in the auto-generation scripts.

### Front matter

Each species page contains [front matter](https://jekyllrb.com/docs/front-matter/), for example:

```
---
layout: species
genus: "Entheus"
title: "Entheus matho"
categories: jekyll species
---
```

This allows the pages to be categorized and titled appropriately.

### Menu features

Each genus section of the menus use this liquid selection logic to collect all
individual pages of that genus and create menu links.

```
{% assign genus = site.pages | where:'genus','Entheus' %}
{%- for page in genus -%}
<li><a href="/caterpillars{{ page.url }}">{{ page.title }}</a></li>
{%- endfor -%}
```

Menu categories are created via the `menu/section.html` includes. A `border`
value allows adding a border to the left of the menu. The `taxon` value is
currently only used for genera right now, such that the genus menu sections
(and all parents) are opened when a page of that genus is visited.

```
{% include menu/section.html title="Entheus" border="2" taxon="Entheus" %}
```

This logic lives in:
```
base_directory
|-- assets
|   |-- js
|   |-- |-- menu.js
```

### Image manipulation

We use [Jekyll picture tag](https://rbuchberger.github.io/jekyll_picture_tag/)
to generate source sets for each image. This can be adjusted in:

```
base_directory
|-- data
|   |-- picture.yml
```

### Image gallery

An image gallery is generated for each individual using lightbox scripts and
styling. This is done automatically for all images that are links on a
particular page. Logic is defined here:

```
base_directory
|-- assets
|   |-- js
|   |-- |-- lightbox.js
|   |-- css
|   |-- |-- lightbox.css
```
