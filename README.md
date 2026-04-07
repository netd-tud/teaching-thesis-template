# teaching-thesis-template

A LaTeX thesis template for TU Dresden following the [Corporate Design guidelines](https://tu-dresden.de/intern/services-und-hilfe/ressourcen-und-service/corporate-design). Based on KOMA-Script (`scrbook`), with custom packages for the title page, heading style, and TUD color palette.

## Requirements

- A modern TeX distribution (TeX Live 2022+ or MiKTeX 22+)
- LuaLaTeX or pdfLaTeX (LuaLaTeX recommended for the Noto font)
- The following CTAN packages (all included in TeX Live full): `koma-script`, `biblatex` + `biber`, `tikz`, `graphicx`, `tcolorbox`, `fontawesome5`, `noto`, `microtype`, `listings`, `booktabs`, `hyperref`, `cleveref`, `todonotes`

## File structure

```
thesis.tex              Main document
bibliography.bib        BibLaTeX database
lst.tex                 listings code-style definitions
sections/
  abstract.tex
  introduction.tex      Example chapter (rename/replace)
  appendix.tex
figures/
  tud-logo-blau-en.pdf  TUD logo (blue, English)
  tud-logo-blau-de.pdf  TUD logo (blue, German)
  tud-logo-weiss-en.pdf TUD logo (white, English)
  tud-logo-weiss-de.pdf TUD logo (white, German)
tud-colors.sty          TUD CD color definitions
tud-titlepage.sty       Title page layout and commands
tud-thesis.sty          Heading style and \confirmation
```

## Compiling

```bash
latexmk -lualatex thesis
```

## Language

Switch between English and German throughout the document by changing two lines in `thesis.tex`:

```latex
\documentclass[ngerman, ...]{scrbook}
\usepackage[ngerman]{babel}
```

Affected text: thesis type label, supervisor/reviewer labels, submission date label, statutory declaration, abstract heading.

## Title page configuration

Set metadata in `thesis.tex` before `\maketitle`:

```latex
\faculty{Faculty of Computer Science}
\institute{Institute of Systems Architecture}
\chair{Chair of Distributed and Networked Systems}
\title{Title of Your Thesis}
% \subtitle{An Optional Subtitle}

\thesis{master}            % master | bachelor
\graduation[M.Sc.]{Master of Science}

\author{Max Mustermann}
\matriculationnumber{1234567}
\dateofbirth{1.1.1970}
\placeofbirth{Dresden}
\email{max.mustermann@mailbox.tu-dresden.de}

\supervisor{Dipl.-Inf. Max Mustermann}
\professor{Prof. Dr. rer. nat. Matthias Wählisch}
\reviewer{Prof. Dr. Second Reviewer}
\cosupervisor{Dr. Co-Supervisor}
\date{1.1.1970}
```

## Title styles

Select a style with `\titlestyle` before `\maketitle`.

### `plain` (default)

White background with a colored accent band in the top-right corner.

```latex
\titlestyle{plain}
```

### `unicolor`

Full-page solid color background. Text and logo color are selected automatically.

```latex
\titlestyle{unicolor}                          % Brilliantblau background (default)
\titlestyle[bgcolor]{unicolor}                 % custom background color
\titlestyle[textcolor][bgcolor]{unicolor}      % custom background + explicit text color
```

### `shapes`

Full-page background with the TUD CD logo-mark shape overlay.

```latex
\titlestyle{shapes}                            % tonal scheme, variant 5 (default)
\titlestyle[variant]{shapes}                   % tonal, custom variant (1–5)
\titlestyle[variant][scheme]{shapes}           % scheme: accent | tonal
\titlestyle[variant][text][shape][bg]{shapes}  % full custom colors
```

**Schemes:**

| Scheme | Background | Shape color |
|--------|------------|-------------|
| `tonal` (default) | `Dunkelblau` | `Brilliantblau` |
| `accent` | `white` | `Blau2` |

**Shape variants (1–5):**

| # | Rotation | Scale | Position |
|---|----------|-------|----------|
| 1 | 90° | 4× | upper-left |
| 2 | 90° | 2.75× | near center |
| 3 | 0° | 2× | centered |
| 4 | 0° | 4× | lower-right |
| 5 | 0° | 2.75× | lower-right (default) |

### Fine-tuning shapes

After `\titlestyle`, you can further adjust placement:

```latex
\titleshapevariant{3}            % apply a numbered preset
\titleshaperotation{2}           % rotation in steps of 45° (0–7); step 2 = 90°
\titleshapescale{1.5}            % scale factor (1 = natural page-width proportional size)
\titleshapeoffset{10mm}{-20mm}   % X/Y offset from page center
```

### Other overrides

```latex
\accentcolor{Rot1}         % change the accent band color (plain style)
\logovariant{de}           % switch to German logo (default: en)
\logocolor{weiss}          % force white logo (default: auto-detected from bg color)
\titlebgcolor{Gruen1}      % change background color after \titlestyle
\titleshapecolor{Violett1} % change shape color after \titlestyle
\titletextcolor{black}     % override text color after \titlestyle
```

## Heading color

Headings default to `Brilliantblau`. To use black headings:

```latex
\renewcommand{\headingcolor}{black}
```

## TUD color palette

All TUD CD colors are defined in `tud-colors.sty` and available as xcolor names, e.g. `Brilliantblau`, `Dunkelblau`, `Blau1`, `Blau2`, `Rot1`, `Gruen1`, etc.
