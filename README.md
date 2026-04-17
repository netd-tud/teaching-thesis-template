# teaching-thesis-template

A LaTeX thesis template for TU Dresden following the [Corporate Design guidelines](https://tu-dresden.de/intern/services-und-hilfe/ressourcen-und-service/corporate-design). Based on KOMA-Script (`scrbook`), with custom packages for the title page, heading style, chapter sidebar markers, and TUD color palette. Edit `thesis.tex`, `preamble.tex`, `minted.tex`, and the files under `sections/` — template infrastructure in `tex-sty/` should stay untouched.

> Maintaining the template itself? See [`tex-sty/README.md`](tex-sty/README.md).

## Requirements

- A modern TeX distribution (TeX Live 2022+ or MiKTeX 22+) with the full package set
- LuaLaTeX (recommended) or pdfLaTeX
- `biber` for bibliographies
- `minted` uses Pygments, so compile with `-shell-escape` (the included `Makefile` already sets this)

## Quick start

```bash
latexmk -lualatex thesis
```

Then edit:

- `thesis.tex` — metadata (title, author, supervisors, date) and chapter inputs
- `sections/abstract.tex`, `sections/introduction.tex`, `sections/appendix.tex` — your content
- `bibliography.bib` — your citations

## File structure

```
thesis.tex              Main document — edit metadata and chapter inputs here
preamble.tex            Package setup — see "What's pre-configured" below
bibliography.bib        BibLaTeX database
minted.tex              minted code-style defaults
lst.tex                 listings code-style defaults (legacy alternative)
.latexmkrc              latexmk config
Makefile                make targets: all, clean, latexdiff, textidote, sources-zip
sections/
  abstract.tex
  introduction.tex      Example chapter with usage examples (rename/replace)
  appendix.tex
figures/                Images and graphics (TUD logos in blau/weiss × de/en variants)
tex-sty/                Template infrastructure — see tex-sty/README.md
```

## Compiling

```bash
latexmk -lualatex thesis
```

If you compile without latexmk, set `TEXINPUTS` manually:

```bash
TEXINPUTS=./tex-sty//: lualatex -shell-escape thesis.tex
```

The `Makefile` exposes additional targets:

```bash
make              # build thesis.pdf via latexmk
make clean        # remove latex aux files
make cleanall     # + remove minted cache, bbl, sources.zip
make latexdiff    # build latexdiff.pdf (requires latexdiff.tex)
make textidote    # run grammar/style check, output HTML
make sources-zip  # pack all used source files into sources.zip
```

## Language

Switch between English and German by changing two lines in `thesis.tex`:

```latex
\documentclass[ngerman, ...]{scrbook}
\usepackage[ngerman]{babel}
```

Affected text: thesis-type label, supervisor/reviewer labels, submission-date label, statutory declaration, abstract heading, research-question title tab.

## Title page

### Metadata

Set in `thesis.tex` before `\maketitle`:

```latex
\faculty{<faculty name>}
\institute{<institute name>}
\chair{<chair name>}
\title{<thesis title>}
% \subtitle{<subtitle>}

\thesis{master}            % master | bachelor | diploma | phd — also sets accent colors
\graduation[<degree>]{<full degree name>}

\author{<your name>}
\matriculationnumber{<matriculation number>}
\email{<email>}

\supervisor{<name> \and <name>}   % multiple supervisors via \and
\professor{<professor name>}
\reviewer{<reviewer name>}
\date{<submission date>}
```

### Styles

The default style is `shapes` (variant 5, Dunkelblau background, Brilliantblau shape). Override with `\titlestyle` before `\maketitle`.

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

**`legacy`** — white background, no shapes, Brilliantblau accent (the pre-CD look).

```latex
\titlestyle{legacy}
```

Fine-tune shape placement after `\titlestyle`:

```latex
\titleshapevariant{<1–5>}              % apply a numbered preset
\titleshaperotation{<0–7>}             % rotation in steps of 45° (e.g. 2 = 90°)
\titleshapescale{<factor>}             % scale factor (1 = natural page-width proportional size)
\titleshapeoffset{<x>}{<y>}            % X/Y offset from page center (e.g. 10mm, -20mm)
```

Adding a new style or shape variant? See [`tex-sty/README.md` § Extending the template](tex-sty/README.md#extending-the-template).

### Colors and logo

```latex
\logovariant{de}           % switch to German logo (default: auto from babel language)
\logocolor{weiss}          % force white logo (default: auto-detected from bg color)
\titlebgcolor{Gruen1}      % change background color after \titlestyle
\titleshapecolor{Violett1} % change shape color after \titlestyle
\titletextcolor{black}     % override lower-block text color after \titlestyle
```

### Fonts

Each element is controlled via KOMA's `\setkomafont` / `\addtokomafont`. Four elements reuse standard KOMA names; two (`tudorgunit`, `tudmeta`) are specific to this template:

| Element | Key | Default |
|---|---|---|
| Faculty / institute / chair | `tudorgunit` | `\footnotesize` |
| Thesis title | `title` | `26 pt bold, accent color` |
| Subtitle | `subtitle` | `17 pt` |
| Thesis type + degree | `subject` | `\large` |
| Author name | `author` | `\large\bfseries` |
| Email, matrnr, supervisors, date | `tudmeta` | `\normalsize` |

Colors default to the active `\titlestyle` and update automatically. Examples:

```latex
\setkomafont{title}{\fontsize{28pt}{33pt}\selectfont\bfseries\color{Rot1}}
\addtokomafont{tudmeta}{\itshape}
\setkomafont{author}{\Large\bfseries\color{white}}
```

## Headings

Headings default to `Brilliantblau`. To use black headings:

```latex
\renewcommand{\headingcolor}{black}
```

## Color scheme

`\thesis` sets an accent color that is automatically applied to the chapter thumb markers and research-question boxes. `\titlestyle` does the same from the title page background color. Both sync derived colors via `\tudupdatecolors`.

To override after `\thesis` or `\titlestyle`:

```latex
\renewcommand*{\chapterthumbboxcolor}{<color>}  % chapter thumb background
\renewcommand{\researchquestioncolor}{<color>}  % research-question frame + fill
```

If `\titlestyle` is called inside the document body, call `\tudupdatecolors` afterwards to re-sync.

How the sync works internally → [`tex-sty/README.md` § Color flow](tex-sty/README.md#color-flow).

## TUD color palette

All TUD CD colors are defined in `tex-sty/tud-colors.sty` and available as xcolor names:

| Group | Colors |
|---|---|
| Primary | `Brilliantblau`, `Dunkelblau` |
| Secondary | `Blau1/2`, `Violett1/2`, `Magenta1/2`, `Rot1/2`, `Orange1/2`, `Gelb1/2`, `Oliv1/2`, `Gruen1/2`, `Tuerkis1/2` |
| Grayscale | `Grau100`, `Grau80`, `Grau60`, `Grau40`, `Grau20`, `Grau10` |

The `1` suffix is the bold variant; `2` is the pastel variant. Grayscale numbers are approximate lightness percentages.

## Writing features

Worked examples for everything below live in [`sections/introduction.tex`](sections/introduction.tex).

### Research questions

The `research-question` environment renders a styled tcolorbox with a title tab that follows the active title-page color. Title text is bilingual (DE/EN) via babel.

```latex
\begin{research-question}
  \item Do we live in the Matrix?
  \item Based on \cite{gos_2020}, is it actually possible to answer the first question?
\end{research-question}
```

Rename the title tab:

```latex
\renewcommand{\researchquestiontitle}{Forschungsfragen}
```

### Statutory declaration

`\confirmation` renders a bilingual statutory-declaration page using `\author` and `\date`. Drop it anywhere after `\maketitle`:

```latex
\confirmation
```

### Code listings

Code is rendered via [minted](https://ctan.org/pkg/minted) (Pygments-backed). Requires `-shell-escape` (the `Makefile` sets this).

```latex
\begin{minted}{python}
def hello():
    print("world")
\end{minted}
```

Global style defaults live in `minted.tex` (font size, line numbers, frame, breaklines). Edit there to change every listing at once. If you prefer `listings`, a `lst.tex` configuration exists as a drop-in alternative — `\input{lst}` instead of `\input{minted}` in `preamble.tex`.

### Figures, tables, theorems, todonotes

Preconfigured packages:

- Figures: `graphicx`, `svg`, `floatrow`
- Tables: `booktabs`, `tabularx`, `tabulary`, `longtable`, `multirow`
- Captions: `caption` (hang format, raggedright, sans-serif label)
- Cross-refs: `cleveref` (use `\Cref{fig:foo}`, `\cref{tab:bar}`)
- Theorem environments: `lem` (Lemma), `thm` (Theorem), `defs` (Definition) — all wired up with cleveref names
- Margin notes: `todonotes` (`\todo{...}`, `\todo[inline]{...}`, `\missingfigure{...}`)
- Quotes: `csquotes` (use `\enquote{...}` — renders correctly per language)

## What's pre-configured (`preamble.tex` and `minted.tex`)

These files are set up so most theses don't need to touch them. Touch them only when adding a package that isn't here, or changing a global default.

- **Bibliography** — `biblatex` (alphabetic style, `biber` backend, hyperref-aware)
- **Links** — `hyperref` with `hidelinks` (clickable but no ugly boxes)
- **Cross-references** — `cleveref` (capitalise, name-in-link, no abbreviations)
- **Typography** — `microtype`, one-half line spacing, `isodate` for ISO dates
- **Page layout** — `geometry` with inner 1.5 cm, outer 3 cm, top 1.5 cm, bottom 2.5 cm; include head
- **Fonts** — Noto Sans/Serif (`noto` package); T1 font encoding under pdfLaTeX
- **Code listings** — `minted` with `\footnotesize`, left-aligned line numbers, line breaking, tabsize 2 (see `minted.tex`)
- **Floats** — `floatrow` (replaces `float`), `plaintop` table style
- **Lists** — `enumitem` with `noitemsep` defaults
- **Title page + headings + chapter thumbs + research-question + statutory declaration** — `tud-colors`, `tud-titlepage`, `tud-thesis`

The package load order in `preamble.tex` is deliberate. Don't reorder lines without reading [`tex-sty/README.md` § Load order](tex-sty/README.md#load-order--dependencies).

## Troubleshooting

- **`no output PDF file produced` or minted errors** → compile with `-shell-escape` (use the `Makefile` or `latexmk`).
- **`Package noto not found`** → install `noto` via your TeX distribution's package manager (`tlmgr install noto`).
- **Fonts look wrong or engine errors** → use LuaLaTeX (`latexmk -lualatex thesis`); pdfLaTeX works but LuaLaTeX has native OpenType.
- **Code listings show stale content after edits** → run `make clean` to drop the `_minted/` cache, then rebuild.
