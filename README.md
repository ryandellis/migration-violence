# [TITLE]

> Replication package for "[Paper Title]" by [Authors].

## Overview

Provide a brief description of the paper and what this replication package contains.

**Computational requirements:** Approximately [X hours/minutes] on a standard desktop.

## Data availability

### [Dataset 1 Name]
- **Source:** [Agency/provider name and URL]
- **Access:** [Publicly available / Application required / Purchase required]
- **Files used:** `data/raw/filename.csv`
- **License/Terms:** [Redistribution permitted / Not permitted]
- **DOI or citation:** [If applicable]

### [Dataset 2 Name]
- **Source:**
- **Access:**
- **Files used:**

## Computational requirements

### Software
- **Stata 19 SE** (or MP). Earlier versions may work but are untested.
- **R 4.x** with packages managed by `renv` (run `renv::restore()`)
- **Python 3.x** with packages in `requirements.txt` (run `pip install -r requirements.txt`)
- **GNU Make** (pre-installed on Linux/Mac; available via WSL on Windows)

### Stata packages
Installed automatically by `code/00_setup.do`:
- estout, reghdfe, ftools, [add others]

### Hardware
- Tested on: [e.g., Windows 11 with 16GB RAM, Ubuntu 24.04]
- Storage: approximately [X] GB required

## Description of programs

| Script | Inputs | Outputs | Purpose |
|--------|--------|---------|---------|
| `code/00_setup.do` | — | Installed packages | Install Stata dependencies |
| `code/01_clean_data.do` | `data/raw/*` | `data/derived/clean.dta` | Data cleaning and merging |
| `code/02_analysis.do` | `data/derived/clean.dta` | `output/tables/reg_main.tex` | Main regression analysis |
| `code/03_tables.do` | `data/derived/clean.dta` | `output/tables/sumstats.tex` | Summary statistics |
| `code/04_figures.R` | `data/derived/clean.dta` | `output/figures/fig1.pdf` | Main figures |

## Instructions to replicators

1. Install the required software listed above.
2. Place the raw data files in `data/raw/` as described in the data availability section.
3. Open a terminal in the project root directory.
4. Run:
   ```
   cd code && stata-se -b do 00_setup.do && cd ..
   make clean && make
   ```
5. Output tables appear in `output/tables/`, figures in `output/figures/`, and the compiled paper in `paper/main.pdf`.

## References

[Data citations as required by the AEA Data Editor.]

---

*This README follows the [Social Science Data Editors' template](https://social-science-data-editors.github.io/template_README/).*
