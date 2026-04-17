# `tex-sty/` — template infrastructure

The five `.sty` files in this directory implement the TUD Corporate Design title page, heading styling, chapter sidebar thumbs, and the `research-question` environment on top of KOMA-Script. This document is for maintainers.

> End-user documentation lives in the repo's [`README.md`](../README.md).

## Package inventory

| File | Role | Origin |
|---|---|---|
| `tud-colors.sty` | TUD CD color palette (26 named colors) | local |
| `tud-titlepage.sty` | Title page layout, metadata commands, `\titlestyle` dispatcher | local |
| `tud-thesis.sty` | Heading color, TOC/LOF/LOT style, chapter thumbs, `research-question`, `\confirmation`, color sync | local |
| `chapterthumb.sty` | Sidebar chapter markers — KOMA extension by Markus Kohm | vendored (LPPL) |
| `tabu.sty` | Flexible tabulars; the `%%TABU-FIXED` header marks a patched upstream copy | vendored |

The local packages require a KOMA-Script class (`scrbook`, `scrreprt`, `scrartcl`) and guard against that via `\@ifundefined{setkomafont}`.

## Load order & dependencies

The canonical order is fixed by `preamble.tex`:

```
iftex → (fontenc[T1] if pdfLaTeX) → noto → babel → isodate → pdfpages → hyphenat
     → setspace → biblatex → hyperref → amsmath → cleveref → todonotes
     → graphicx → svg → theorem defs → blindtext → csquotes
     → caption → floatrow → booktabs/array/tabularx/tabulary/tabu/longtable/multirow
     → quoting → microtype → xfrac → enumitem → ellipsis → \input{minted}
     → conditions env → geometry → tud-colors → tud-titlepage → tud-thesis
```

Key ordering contracts:

- **`iftex` before `fontenc` / `noto`** — engine detection gates `T1` fontenc on pdfLaTeX.
- **`babel` before anything that calls `\iflanguage`** — `tud-titlepage` and `tud-thesis` both branch on `ngerman`.
- **`amsmath` before `cleveref`** — `cleveref` patches `amsmath` references.
- **`hyperref` before `cleveref`** — standard cleveref requirement.
- **`tud-colors` before `tud-titlepage`** — color names (`Brilliantblau`, `Dunkelblau`, …) must exist before the title page references them.
- **`tud-titlepage` before `tud-thesis`** — `tud-thesis` `\let`-patches `\tud@applythesiscolors` and reads `\tud@bgcolor`, both defined in `tud-titlepage`.
- **`\input{minted}` after the tabular packages** — avoids verbatim-vs-tabular catcode clashes.

## `tud-colors.sty`

Pure `\definecolor` calls via `xcolor`. No logic.

| Group | Names & hex |
|---|---|
| Primary | `Brilliantblau` `#00008C`, `Dunkelblau` `#001450` |
| Blau | `Blau1` `#2F57B2`, `Blau2` `#97C6FF` |
| Violett | `Violett1` `#7369BE`, `Violett2` `#C8C8FF` |
| Magenta | `Magenta1` `#BC1589`, `Magenta2` `#FFB9FF` |
| Rot | `Rot1` `#D20F41`, `Rot2` `#FFAAA5` |
| Orange | `Orange1` `#C85000`, `Orange2` `#FFBE78` |
| Gelb | `Gelb1` `#FFC700`, `Gelb2` `#FFE483` |
| Oliv | `Oliv1` `#767A23`, `Oliv2` `#D2DC46` |
| Gruen | `Gruen1` `#007D4B`, `Gruen2` `#8CE6AA` |
| Tuerkis | `Tuerkis1` `#0A777F`, `Tuerkis2` `#8CE6D7` |
| Grau | `Grau100` `#323F4B`, `Grau80` `#566371`, `Grau60` `#7D8894`, `Grau40` `#A5AEB8`, `Grau20` `#D0D5DC`, `Grau10` `#E7E9ED` |

Naming convention: `Xn` pairs where `1` is the bold CD variant and `2` is the pastel variant. `GrauNN` is approximate lightness percent.

**Adding a color:** append a `\definecolor` line. If the new color is "light enough" that it should map to `Brilliantblau` upper-block text rather than white, also add it to the whitelists in `\tud@autoshapecolor` and `\tudupdatecolors` (see § Color flow).

## `tud-titlepage.sty` architecture

### Pipeline (inside `\maketitle`)

The title page is a single `tikzpicture[remember picture, overlay]` drawn on top of an empty `titlepage`. Render order:

1. **Full-page background fill** — gated by `\tud@titlebg == 1`, uses `\tud@bgcolor`.
2. **Shape polygons** — gated by `\tud@titleshapes == 1`. Two `\fill` commands draw Fragment 1 (upper-right triangle) and Fragment 2 (lower-left triangle) of the CD logo mark inside a `scope` with `xshift=\tud@shapexoffset`, `yshift=\tud@shapeyoffset`, `rotate=\tud@shaperotation`, `x=y=\tud@effectiveshapeunit`.
3. **Logo** — `includegraphics` of `figures/tud-logo-<color>-<variant>.pdf`; color/variant determined by `\tud@logocolor` and `\tud@logovariant`.
4. **Node A (`tudorgunit`)** — faculty / institute / chair, anchored north-west below the logo.
5. **Node B (`tudauthor`)** — author name + email, anchored south-west at `\tud@authorblockY` above the page bottom.
6. **Node C (title + subtitle)** — west-anchored, vertically midway between A and B via a `coordinate (tudmid) = midpoint(A.south west, B.north west)`.
7. **Metadata block** — anchored south-west at `\tud@marginbottom`. Contains thesis-type line, then a `tabular` with the reviewer / second-reviewer / matriculation number / supervisor(s) / submission date in a two-column grid.

### Shape geometry

All coordinates are pinned to **variant 1** (scale 4, 90° rotation, offset `−15cm,40cm`) because the author block's Y position depends on where the shape's lower boundary ends up:

- `\tud@shapeunit = \paperwidth / 600` — base unit.
- `\tud@effectiveshapeunit = \tud@shapescale · \tud@shapeunit`.
- `\tud@v@shapelowery = 128.5mm` — Y of the visible Fragment-2 corner in variant 1.
- `\tud@v@cornerx = 129.02mm` — X of the same corner.
- `\tud@authorblockY = \tud@v@shapelowery + 3/2 \tud@margintop` — places author block 1.5× the top margin above the shape vertex.
- `\tud@metacolL = \tud@v@cornerx − \tud@marginleft − 1em` — meta-table left column ends just before the corner.
- `\tud@metacolR = \paperwidth − \tud@marginright − \tud@v@cornerx` — right column starts at the corner.

If you change variant 1's geometry, recompute these and the metadata block will still align.

### `\titlestyle` dispatcher

Defined via `NewDocumentCommand` with four optional arguments. Dispatches on the mandatory style name:

- `\titlestyle{unicolor}` — solid-color bg. Optionals `[textcolor][bgcolor]`.
- `\titlestyle{shapes}` — shape overlay. Two overloads:
  - Two-optional: `[variant][scheme]` where `scheme ∈ {accent, tonal}`.
  - Four-optional: `[variant][lower-textcolor][shapecolor][bgcolor]`.
- `\titlestyle{legacy}` — white bg, no shapes, Brilliantblau accent.

The dispatcher first resets all color and geometry state, then branches and applies defaults + auto-color resolvers. `\IfNoValueTF` is used to distinguish "argument omitted" from "explicit empty".

### Auto-color resolvers

Three functions decide text / logo color from the bg / shape colors:

- `\tud@autologocolor` — reads `\tud@bgcolor`. If it's in the "dark" whitelist (`Brilliantblau`, `Dunkelblau`, `Blau1`, `Violett1`, `Magenta1`, `Rot1`, `Orange1`, `Oliv1`, `Gruen1`, `Tuerkis1`, `Grau100/80/60`), sets `\tud@logocolor = weiss` and lower-block fg to `white`. Otherwise `blau` logo + `Brilliantblau` text.
- `\tud@autoshapecolor` — runs only in `shapes` style. Reads `\tud@shapecolor`. If it's in the "light" whitelist (all `Color2` variants, `Gelb1`, `Gelb2`, `Grau40/20/10`, `white`), sets upper-block fg to `Brilliantblau`. Otherwise upper-block fg is `white`. Then swaps the lower-block labels/values so labels take the bg-derived color and values take the shape color. Dark-bg + dark-shape fallback: values flip to `Blau2` to stay readable.
- `\tud@setmetalabelcolor` — used by `unicolor` / `legacy` where there's no shape. Mirrors the label color to the bg-derived color.

### Shape variant presets

`\titleshapevariant{N}` sets scale / rotation / offset in one call:

| N | Scale | Rotation step (×45°) | Offset (x, y) |
|---|---|---|---|
| 1 | 4 | 2 (90°) | `−15cm, 40cm` — upper-left |
| 2 | 2.75 | 2 (90°) | `−10cm, 2cm` — near center |
| 3 | 2 | 0 (0°) | `0, 0` — centered |
| 4 | 4 | 0 (0°) | `25cm, −15cm` — lower-right |
| 5 (default for `shapes`) | 2.75 | 0 (0°) | `12.5cm, −12.5cm` — lower-right |

### Supervisor `\and` handling

`\supervisor{A \and B}` must render "A / newline / B" inside the metadata tabular's left column. Two pieces:

- `\def\and{\newline}` — scoped inside the tabular so `\and` becomes a line break in the current cell.
- Pre-scan: before the tabular, a `\setbox\z@=\hbox{...}` rebinds `\and` to set `\tud@ismultisuper`; the label then renders as singular `Betreuer` / `Supervisor` or plural `Betreuer` / `Supervisors`.

### Fonts

Six font elements:

| Element | Mechanism | Color source |
|---|---|---|
| `title` | `\setkomafont` (KOMA standard) | `\tud@titleaccentcolor` |
| `subtitle` | `\setkomafont` | `\tud@titleupperfgcolor` |
| `author` | `\setkomafont` | `\tud@titleupperfgcolor` |
| `subject` | `\setkomafont` | `\tud@titlefgcolor` |
| `tudorgunit` | `\newkomafont` (template-specific) | `\tud@titleupperfgcolor` |
| `tudmeta` | `\newkomafont` | `\tud@titlefgcolor` |

Color macros resolve at render time via `\color{\tud@...}`, so the element's color picks up whatever `\titlestyle` set last. Users customize via `\setkomafont{...}{...}` / `\addtokomafont{...}{...}` in their preamble.

### Noto Sans scoping

`\maketitle` forces Noto Sans on the title page regardless of the document's active sans font:

- pdfLaTeX path: `\renewcommand{\sfdefault}{\tud@notosansfamily}` inside the `titlepage` env.
- Lua/XeLaTeX path: `\setsansfont{Noto Sans}` (same scope).

`\tud@notosansfamily` was captured at package load via `\edef\tud@notosansfamily{\sfdefault}` right after `\RequirePackage{noto}`.

## `tud-thesis.sty` architecture

### Heading color

```latex
\setkomafont{disposition}{\sffamily\color{\headingcolor}}
```

Plus sans-serif TOC entries via `\addtokomafont{chapterentry}{\sffamily}` and `\DeclareTOCStyleEntry` for `section`, `subsection`, `figure`, `table`. `\headingcolor` defaults to `Brilliantblau`.

### Chapter thumbs

Integrates the `chapterthumb` package with `scrlayer-scrpage`:

```latex
\AddLayersToPageStyle{@everystyle@}{chapterthumb}
\addtokomafont{chapterthumb}{\bfseries}
\renewcommand*{\chapterthumbboxcolor}{Dunkelblau}   % overridden by \tudupdatecolors
\renewcommand*{\chapterthumbcolor}{white}            % overridden by \tudupdatecolors
\renewcommand*{\chapterthumbheight}{10mm}
\renewcommand*{\firstchapterthumbskip}{0sp}
```

### `research-question` environment

A `tcolorbox` wrapping an `itemize`. Built from three parts:

- **`\labelitemi` override** inside the environment — swaps the bullet for `\faIcon{caret-right}` in `\researchquestioncolor`.
- **`underlay boxed title`** — custom tikz draw of the title tab (straight edges with two small rounded corners, computed from `tcboxedtitleheight` so it adapts to title text height).
- **`frame code`** — custom tikz draw of the main box frame (rounded-corner rectangle with fill = `\researchquestioncolor!20!white`, stroke = `\researchquestioncolor`, line width 2 pt).

Both title tab and frame stroke use `\researchquestioncolor`; the fill is derived via `!20!white`. The title text is bilingual via `\researchquestiontitle` (default `Research Questions`; override with `\renewcommand{\researchquestiontitle}{Forschungsfragen}`).

### `\confirmation`

Typesets a bilingual (`\iflanguage{ngerman}`) statutory-declaration page as an unnumbered chapter. Uses `\@author` and `\@date` from the document preamble.

## Color flow

This is the sync logic you need to understand before changing anything color-adjacent.

```
\thesis{master|bachelor|diploma|phd}
      │
      ▼
\tud@applythesiscolors{bg}{shape}
      │   — sets \tud@bgcolor, \tud@shapecolor
      │   — runs \tud@autologocolor (logo + lower-block fg)
      │   — runs \tud@autoshapecolor (upper-block fg + swap)
      │
      ▼  (patched by tud-thesis: \let \tud@thesis@orig@applycolors = \tud@applythesiscolors;
      │                          \def \tud@applythesiscolors = orig + \tudupdatecolors)
      │
\tudupdatecolors
      │   — \renewcommand*\chapterthumbboxcolor{\tud@bgcolor}
      │   — \renewcommand*\chapterthumbcolor{white|Brilliantblau}    (white-only for dark bg)
      │   — \edef\researchquestioncolor{\tud@bgcolor}
      ▼
chapter thumbs + research-question boxes now match the thesis color.
```

A parallel path exists for `\titlestyle`:

```
\titlestyle{...}
      │   — sets \tud@bgcolor, \tud@shapecolor, fg/accent/logo colors
      │   — does NOT call \tudupdatecolors
      ▼
If called in the document body, follow with \tudupdatecolors manually.
```

### Override timing

`\renewcommand*{\chapterthumbboxcolor}{...}` and `\renewcommand{\researchquestioncolor}{...}` must come **after** the last `\thesis{...}` / `\tudupdatecolors`, because those overwrite the values. The template's public API (`README.md` § Color scheme) is specifically this ordering contract.

### Why `\def` not `\newcommand` for internal macros

Internal metadata storage uses `\def\tud@foo{}` with a sentinel empty body so `\ifx\tud@foo\@empty` tests work reliably. `\newcommand` wraps its body in protection that breaks `\ifx` equivalence tests.

## Extending the template

### Add a new shape variant

Extend `\titleshapevariant` with a new `\or` arm:

```latex
\newcommand{\titleshapevariant}[1]{%
  \ifcase#1\relax
  \or % 1 ...
  ...
  \or % 6 — YOUR NEW VARIANT
    \titleshapescale{3}\titleshaperotation{1}\titleshapeoffset{5cm}{-5cm}%
  \fi
}
```

Then add the row to the variant table in this README and in the user README.

### Add a new title style

1. Add a dispatch branch in `\titlestyle` (mirror the `unicolor` / `shapes` blocks): set `\tud@titlebg`, `\tud@titleshapes`, the color state, and any geometry defaults.
2. Export it in the user README's "Title page › Styles" section.
3. Decide whether it needs `\tud@autologocolor` / `\tud@autoshapecolor` or a custom resolver.

### Add a new color

1. Append `\definecolor{YourColor}{RGB}{...}` in `tud-colors.sty`.
2. If it's **light** (pastel-like), add it to the whitelists in both `\tud@autoshapecolor` and `\tudupdatecolors` so text contrast auto-selects correctly.
3. If it's **dark** (bold-like), add it to the whitelist in `\tud@autologocolor`.
4. Update the palette table in `README.md` and the hex table above.

### Add a new thesis type

Extend the `\ifx...\fi` cascade in `\thesis`:

```latex
\newcommand{\thesis}[1]{%
  \def\tud@thesistype{#1}%
  \def\tud@ts@msc{master}...\def\tud@ts@new{habilitation}%
  ...
  \else\ifx\tud@thesistype\tud@ts@new
    \tud@applythesiscolors{<bg>}{<shape>}%
  \else ...
}
```

Also extend the bilingual label resolver `\tud@thesislabel` with the new type's DE/EN name.

### Add a new language

Touch every `\iflanguage{ngerman}{...}{...}` site:

- `\tud@thesislabel` in `tud-titlepage.sty`.
- `\tud@lbl@supervisor`, `\tud@lbl@reviewer`, `\tud@lbl@secondreviewer`, `\tud@lbl@submitted`, `\tud@lbl@matrnr`, `\tud@lbl@supervisors`.
- `\tud@logovariant` default.
- `\confirmation` body in `tud-thesis.sty`.

`\iflanguage` is binary — if you need a third language, replace these sites with a dispatcher keyed on `\languagename`.

## Third-party packages

### `chapterthumb.sty`

Markus Kohm, 2016/02/01 v0.3a (LPPL). Labeled "unsupported" upstream but has been stable for years. Configured — not patched — via these knobs (all `\renewcommand*`):

| Macro | Default | Used for |
|---|---|---|
| `\chapterthumbboxcolor` | `black` (overridden to `\tud@bgcolor`) | box background |
| `\chapterthumbcolor` | `white` (overridden by `\tudupdatecolors`) | text color |
| `\chapterthumbheight` | `2em` (overridden to `10mm`) | vertical size |
| `\chapterthumbwidth` | `0.2\paperheight` | horizontal size |
| `\chapterthumbskip` | `0.1\paperheight` | spacing between thumbs |
| `\firstchapterthumbskip` | `0.05\paperheight` (overridden to `0sp`) | first thumb position |
| `\chapterthumbformat` | `\@chapapp~\thechapter` | label text |

`chapterthumb` font element is `\bfseries`-extended in `tud-thesis.sty`.

### `tabu.sty`

Vendored copy marked `%%TABU-FIXED` at the top — a patched build from a community fork. The upstream CTAN `tabu` package has been unmaintained for years; the local copy is kept to avoid breakage with newer LaTeX kernels. If you upgrade the copy, diff against the header to preserve whatever the `FIXED` marker was fixing, and test the tables in `sections/introduction.tex`.

## `preamble.tex` and `minted.tex` contracts

- **`preamble.tex`** is the authoritative load order. Respect the chain in § Load order. Packages added in the middle must not break the ordering contracts listed there.
- **`minted.tex`** is wrapped by `\input{minted}` in the preamble. Edit `\setminted{...}` to change every code listing at once. The alternative `lst.tex` uses `listings` and is intended as a fallback for environments where `-shell-escape` is unavailable — it is not loaded by default.

## Build system

- **`.latexmkrc`** — one line: `ensure_path('TEXINPUTS', './tex-sty//')`. Makes these packages discoverable by latexmk without a system-wide install.
- **`Makefile`** — the canonical build. Key knob: `LATEXMK_FLAGS` includes `-e '$$pdflatex=q/pdflatex %O -shell-escape %S/'`, which is why minted works out of the box. Override the engine with `make LATEX=lualatex`.
- **Manual invocation** — `TEXINPUTS=./tex-sty//: lualatex -shell-escape thesis.tex`.

## Testing changes

After any edit to a `.sty` file, compile `thesis.tex` end-to-end:

```bash
latexmk -lualatex thesis
```

Inspect visually:

- Title page (logo color, shape orientation, text readability).
- First chapter thumb (color sync with `\thesis` / `\titlestyle`).
- Any `research-question` environment (frame + title tab colors).
- Statutory declaration page (bilingual rendering if you toggle `ngerman`).

Toggle the thesis language in `thesis.tex` and rebuild before committing changes that touch `\iflanguage` sites.

## Versioning

Each local package has a `\ProvidesPackage{name}[YYYY/MM/DD description]` line. Bump the date string on substantive changes. Current values:

- `tud-colors.sty` — `2026/04/01 TUD CD Color Palette`
- `tud-titlepage.sty` — `2026/04/01 TUD CD Thesis Title Page`
- `tud-thesis.sty` — `2026/04/13 TUD Thesis Styling`
