# teaching-thesis-template

A LaTeX thesis template for TU Dresden following the [Corporate Design guidelines](https://tu-dresden.de/intern/services-und-hilfe/ressourcen-und-service/corporate-design). Based on KOMA-Script (`scrbook`), with custom packages for the title page, heading style, chapter sidebar markers, and TUD color palette. Template infrastructure lives in `tex-sty/` — edit only `thesis.tex`, `preamble.tex`, and the files under `sections/`.

## Requirements

- A modern TeX distribution (TeX Live 2022+ or MiKTeX 22+)
- LuaLaTeX or pdfLaTeX (LuaLaTeX recommended for the Noto font)
- The following CTAN packages (all included in TeX Live full): `koma-script`, `biblatex` + `biber`, `tikz`, `graphicx`, `tcolorbox`, `fontawesome5`, `noto`, `microtype`, `listings`, `booktabs`, `hyperref`, `cleveref`, `todonotes`

## File structure

```
thesis.tex              Main document — edit metadata here
preamble.tex            Package setup — minimal edits
bibliography.bib        BibLaTeX database
lst.tex                 listings code-style definitions
minted.tex              minted code-style definitions
.latexmkrc              latexmk config (sets TEXINPUTS for tex-sty/)
sections/
  abstract.tex
  introduction.tex      Example chapter with usage guide (rename/replace)
  appendix.tex
figures/                Images and graphics
  tud-logo-blau-en.pdf  TUD logo (blue, English)
  tud-logo-blau-de.pdf  TUD logo (blue, German)
  tud-logo-weiss-en.pdf TUD logo (white, English)
  tud-logo-weiss-de.pdf TUD logo (white, German)
tex-sty/                Template infrastructure — do not edit
  tud-colors.sty        TUD CD color definitions
  tud-titlepage.sty     Title page layout and commands
  tud-thesis.sty        Heading style, \confirmation, chapter thumb markers, research-question box
  chapterthumb.sty      Chapter sidebar markers (third-party, configured by tud-thesis.sty)
  tabu.sty              Patched tabu table package
```

## Compiling

```bash
latexmk -lualatex thesis
```

The included `.latexmkrc` automatically adds `tex-sty/` to the TeX input path. If you compile without latexmk, set `TEXINPUTS` manually:

```bash
TEXINPUTS=./tex-sty//: lualatex thesis.tex
```

## Language

Switch between English and German throughout the document by changing two lines in `thesis.tex`:

```latex
\documentclass[ngerman, ...]{scrbook}
\usepackage[ngerman]{babel}
```

Affected text: thesis type label, supervisor/reviewer labels, submission date label, statutory declaration, abstract heading.

## Title page

### Metadata

Set in `thesis.tex` before `\maketitle`:

```latex
\faculty{<faculty name>}
\institute{<institute name>}
\chair{<chair name>}
\title{<thesis title>}
% \subtitle{<subtitle>}

\thesis{master}            % master | bachelor
\graduation[<degree>]{<full degree name>}

\author{<your name>}
\matriculationnumber{<matriculation number>}
\dateofbirth{<date>}
\placeofbirth{<city>}
\email{<email>}

\supervisor{<name> \and <name>}
\professor{<professor name>}
\reviewer{<reviewer name>}
\date{<submission date>}
```

### Styles

The default style is `shapes` (variant 5, white background, Brilliantblau shape). Override with `\titlestyle` before `\maketitle`.

**`unicolor`** — full-page solid color background; text and logo color auto-selected.

```latex
\titlestyle{unicolor}                                  % Brilliantblau background (default)
\titlestyle[<bgcolor>]{unicolor}                       % custom background color
\titlestyle[<textcolor>][<bgcolor>]{unicolor}          % custom background + explicit text color
```

**`shapes`** — full-page background with the TUD CD logo-mark shape overlay.

```latex
\titlestyle{shapes}                                          % tonal scheme, variant 5 (default)
\titlestyle[<variant>]{shapes}                               % tonal, custom variant (1–5)
\titlestyle[<variant>][<scheme>]{shapes}                     % scheme: accent | tonal
\titlestyle[<variant>][<text>][<shape>][<bg>]{shapes}        % full custom colors
```

| Scheme | Background | Shape color |
|--------|------------|-------------|
| `tonal` (default) | `Dunkelblau` | `Brilliantblau` |
| `accent` | `white` | `Blau2` |

| Variant | Rotation | Scale | Position |
|---------|----------|-------|----------|
| 1 | 90° | 4× | upper-left |
| 2 | 90° | 2.75× | near center |
| 3 | 0° | 2× | centered |
| 4 | 0° | 4× | lower-right |
| 5 (default) | 0° | 2.75× | lower-right |

Fine-tune shape placement after `\titlestyle`:

```latex
\titleshapevariant{<1–5>}              % apply a numbered preset
\titleshaperotation{<0–7>}             % rotation in steps of 45° (e.g. 2 = 90°)
\titleshapescale{<factor>}             % scale factor (1 = natural page-width proportional size)
\titleshapeoffset{<x>}{<y>}            % X/Y offset from page center (e.g. 10mm, -20mm)
```

### Colors and logo

```latex
\logovariant{de}           % switch to German logo (default: en)
\logocolor{weiss}          % force white logo (default: auto-detected from bg color)
\titlebgcolor{Gruen1}      % change background color after \titlestyle
\titleshapecolor{Violett1} % change shape color after \titlestyle
\titletextcolor{black}     % override text color after \titlestyle
```

### Fonts

Each element is controlled via KOMA's `\setkomafont` / `\addtokomafont`. Four elements reuse standard KOMA names; two (`tudorgunit`, `tudmeta`) are specific to this template:

| Element | Key | Default |
|---|---|---|
| Faculty / institute / chair | `tudorgunit` | `\footnotesize` |
| Thesis title | `title` | `26pt bold, accent color` |
| Subtitle | `subtitle` | `17pt` |
| Thesis type + degree | `subject` | `\large` |
| Author name | `author` | `\large\bfseries` |
| Email, matrnr, supervisors, date | `tudmeta` | `\small` |

Colors default to the active `\titlestyle` and update automatically. Examples:

```latex
\setkomafont{title}{\fontsize{28pt}{33pt}\selectfont\bfseries\color{Rot1}}
\addtokomafont{tudmeta}{\itshape}
\setkomafont{author}{\Large\bfseries\color{white}}
```

## Heading color

Headings default to `Brilliantblau`. To use black headings:

```latex
\renewcommand{\headingcolor}{black}
```

## TUD color palette

All TUD CD colors are defined in `tud-colors.sty` and available as xcolor names, e.g. `Brilliantblau`, `Dunkelblau`, `Blau1`, `Blau2`, `Rot1`, `Gruen1`, etc.
