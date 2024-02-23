ifeq (,$(BIBINPUTS))
  $(warning "BIBINPUTS not set")
endif

export BIBINPUTS := $(BIBINPUTS):$(CURDIR)

NAME = thesis
INPUTS = $(filter-out $(NAME).tex,$(wildcard *.tex tex/*.tex))
FIGS = $(wildcard figures/*[^~])
FIG_FRAGMENTS_NAME := $(patsubst %.dpth,%,$(wildcard figures/*.dpth))
BIBS = $(wildcard *.bib)
TEX_MACROS = ie,eg,verb,fi,iffalse,crefrange,linebreak
LATEXMK_FLAGS = -pdf -e '$$pdflatex=q/pdflatex %O -shell-escape %S/' -use-make

ifeq (1,$(FORCE))
  LATEXMK_FLAGS += -f
endif

.PHONY: all latexdiff cleanall clean clean-fragments sources-zip textidote textidote-cli

all: $(NAME).pdf

latexdiff: latexdiff.pdf

$(NAME).pdf: $(NAME).tex $(INPUTS) $(FIGS) $(BIBS)
	latexmk $(LATEXMK_FLAGS) $<

latexdiff.pdf: latexdiff.tex $(INPUTS) $(FIGS) $(BIBS)
	latexmk $(LATEXMK_FLAGS) $<

cleanall: clean-fragments clean-sources-zip
	latexmk -C

clean:
	latexmk -c

clean-fragments:
	-rm -f $(NAME).bbl $(foreach ext,dpth log md5 pdf,$(foreach name,$(FIG_FRAGMENTS_NAME),$(name).$(ext)))

sources-zip: sources.zip

sources.zip: $(NAME).fls $(NAME).tex $(INPUTS) $(FIGS) $(BIBS)
	zip $@ $(shell grep 'INPUT\s*\./' "$<" | grep -v 'main\.\(out\|aux\)' | sed -e 's/INPUT\s*//'  -e 's#//#/#' | sort -u) main.tex

$(NAME).fls: $(NAME).pdf

clean-sources-zip:
	-rm -rf sources.zip

TEXTIDOTE_DICT = textidote-dict.txt
TEXTIDOTE_IGNORE = sh:008,sh:secskip,sh:seclen,sh:stacked,sh:nobreak,sh:nsubdiv

textidote: $(NAME)-textidote.html

textidote-cli: $(NAME).tex $(INPUTS) $(FIGS) $(BIBS) $(TEXTIDOTE_DICT)
	textidote --check en --dict $(TEXTIDOTE_DICT) --ignore $(TEXTIDOTE_IGNORE) --remove-macros "$(TEX_MACROS)" --type tex --output singleline $<

$(NAME)-textidote.html: $(NAME).tex $(INPUTS) $(FIGS) $(BIBS) $(TEXTIDOTE_DICT)
	textidote --check en --dict $(TEXTIDOTE_DICT) --ignore $(TEXTIDOTE_IGNORE) --remove-macros "$(TEX_MACROS)" --type tex --output html $< > $@
