# ==============================================================================
# Makefile — Build automation for empirical economics research
#
# Usage:
#   make              Build everything (only stale targets)
#   make all          Same as above
#   make clean        Remove all generated files
#   make paper        Compile the PDF only (assumes tables/figures are current)
#   make sync         Push updated output to Overleaf via Git bridge
#
# Prerequisites:
#   - GNU Make (pre-installed on Linux/Mac; via WSL or choco on Windows)
#   - Stata, R, Python as needed
#   - latexmk (for PDF compilation; optional if compiling on Overleaf)
# ==============================================================================

# ---- OS detection for Stata path ----
# Adjust the Windows path below to match your Stata installation.
ifeq ($(OS),Windows_NT)
    STATA := "/mnt/c/Program Files/Stata19/StataSE-64.exe" -e do
else
    UNAME := $(shell uname -s)
    ifeq ($(UNAME),Linux)
        # Check if running inside WSL
        ifneq (,$(findstring microsoft,$(shell uname -r 2>/dev/null | tr A-Z a-z)))
            STATA := "/mnt/c/Program Files/Stata19/StataSE-64.exe" -e do
        else
            STATA := stata-se -b do
        endif
    else
        STATA := stata-se -b do
    endif
endif

RSCRIPT   := Rscript
PYTHON    := python3
LATEXMK   := latexmk -pdf -quiet -cd

# ---- Overleaf Git bridge ----
# Set this to the local path of your cloned Overleaf project.
# Clone it once:  git clone https://git.overleaf.com/YOUR_PROJECT_ID ../overleaf-PROJECT
# Then update the path below.
OVERLEAF_DIR := ../overleaf-$(notdir $(CURDIR))

# ---- Default target ----
.PHONY: all clean paper sync

all: paper/main.pdf

# ==============================================================================
# DATA CLEANING
# Add one rule per cleaning script. Each rule should list:
#   - target: the output dataset(s)
#   - dependencies: raw data files + the script itself
#   - recipe: the command to run
#
# Example:
# data/derived/clean.dta: data/raw/survey.csv code/01_clean_data.do code/_config.do
# 	cd code && $(STATA) 01_clean_data.do
# ==============================================================================


# ==============================================================================
# ANALYSIS
# Example:
# output/tables/reg_main.tex: data/derived/clean.dta code/02_analysis.do code/_config.do
# 	cd code && $(STATA) 02_analysis.do
# ==============================================================================


# ==============================================================================
# TABLES
# Example:
# output/tables/sumstats.tex: data/derived/clean.dta code/03_tables.do code/_config.do
# 	cd code && $(STATA) 03_tables.do
# ==============================================================================


# ==============================================================================
# FIGURES
# Example (R):
# output/figures/fig1.pdf: data/derived/clean.dta code/04_figures.R
# 	$(RSCRIPT) code/04_figures.R
#
# Example (Python):
# output/figures/fig2.pdf: data/derived/clean.dta code/05_figures.py
# 	$(PYTHON) code/05_figures.py
# ==============================================================================


# ==============================================================================
# COMPILE PAPER
# List ALL .tex inputs and figures as dependencies so the paper recompiles
# when any content changes.
# ==============================================================================
# paper/main.pdf: paper/main.tex paper/references.bib \
#                 output/tables/reg_main.tex output/tables/sumstats.tex \
#                 output/figures/fig1.pdf
# 	$(LATEXMK) paper/main.tex

paper:
	$(LATEXMK) paper/main.tex

# ---- Sync to Overleaf via Git bridge ----
sync:
	@if [ ! -d "$(OVERLEAF_DIR)" ]; then \
		echo "Error: Overleaf directory not found at $(OVERLEAF_DIR)"; \
		echo "Clone your Overleaf project first:"; \
		echo "  git clone https://git.overleaf.com/YOUR_PROJECT_ID $(OVERLEAF_DIR)"; \
		exit 1; \
	fi
	@echo "Syncing output to Overleaf..."
	@mkdir -p $(OVERLEAF_DIR)/tables $(OVERLEAF_DIR)/figures
	cp output/tables/*.tex $(OVERLEAF_DIR)/tables/ 2>/dev/null || true
	cp output/figures/*.pdf $(OVERLEAF_DIR)/figures/ 2>/dev/null || true
	cp paper/references.bib $(OVERLEAF_DIR)/ 2>/dev/null || true
	cd $(OVERLEAF_DIR) && git add -A && \
		git diff-index --quiet HEAD || \
		git commit -m "Auto-update $$(date '+%Y-%m-%d %H:%M')" && \
		git push origin master
	@echo "Done. Overleaf should update within a few seconds."

# ---- Clean all generated files ----
clean:
	rm -f data/derived/*
	rm -f output/tables/*.tex
	rm -f output/figures/*.pdf
	rm -f code/*.log code/*.smcl
	-$(LATEXMK) -C paper/main.tex 2>/dev/null
	@echo "Cleaned. Run 'make' to rebuild from scratch."
