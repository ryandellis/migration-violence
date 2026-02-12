# Migration and Insurgent Violence

> Replication package for "Migration and Insurgent Violence" by Ryan Ellis [and coauthors].

## Overview

This paper studies the relationship between migration and insurgent violence
using call detail records from Afghanistan.

**Computational requirements:** Approximately [X hours/minutes] on a standard desktop.

## Data availability

### Vodafone Foundation Data (VFD)
- **Source:** Proprietary CDR data provided under data use agreement
- **Access:** Application required; contact [details]
- **Files used:** `data/raw/VFD_data/fullpanel_analysis.dta` and related files
- **License/Terms:** Not redistributable

### DHS Afghanistan 2015
- **Source:** The DHS Program (dhsprogram.com)
- **Access:** Registration required at dhsprogram.com
- **Files used:** `data/raw/dhs/` (household, individual, children surveys)

### Disaggregated Migration Estimates
- **Source:** [Source name and URL]
- **Access:** [Publicly available / Registration required]
- **Files used:** `data/raw/Disaggregated_Migration/MigrationEstimates/`

### IOM Displacement Tracking Matrix
- **Source:** IOM DTM (dtm.iom.int)
- **Access:** [Access conditions]
- **Files used:** `data/raw/dtm/`

### UNHCR Refugee Statistics
- **Source:** UNHCR (unhcr.org)
- **Access:** Publicly available
- **Files used:** `data/raw/unhcr_query/`

### World Bank Indicators
- **Source:** World Bank Open Data (data.worldbank.org)
- **Access:** Publicly available
- **Files used:** `data/raw/worldbank/`

### GeoQuery / Gridded Population
- **Source:** [Source details]
- **Files used:** `data/raw/geoquery/`, `data/raw/griddedpop/`

### NRVA Survey
- **Source:** [National Risk and Vulnerability Assessment - details]
- **Files used:** `data/raw/nrva_survey/`

## Computational requirements

### Software
- **Stata 19 SE** (or MP)
- **GNU Make** (pre-installed on Linux/Mac; available via WSL on Windows)

### Stata packages
Installed automatically by `code/00_setup.do`:
- estout, reghdfe, ftools, [add others as identified]

### Hardware
- Tested on: Windows 11 via WSL, [X] GB RAM
- Storage: approximately [X] GB required

## Description of programs

| Script | Inputs | Outputs | Purpose |
|--------|--------|---------|---------|
| `code/00_setup.do` | — | Installed packages | Install Stata dependencies |
| `code/01_clean_VFD_data.do` | `data/raw/VFD_data/*` | `data/derived/VFD_data_clean.dta` | Clean raw CDR data |
| `code/02_wrangle_VFD_data.do` | `data/derived/VFD_data_clean.dta` | `data/derived/...` | Wrangle CDR variables |
| `code/03_internal_mig_algorithm_VFD.do` | `data/derived/...` | `data/derived/...` | Internal migration algorithm |
| `code/04_01_sample_restrictions_*.do` | `data/derived/...` | `data/derived/...` | Sample restrictions (gap dropped) |
| `code/04_02_sample_restrictions_*.do` | `data/derived/...` | `data/derived/...` | Sample restrictions (with gap) |
| `code/05_01_international_mig_algo.do` | `data/derived/...` | `data/derived/...` | International migration (no gap) |
| `code/05_02_international_mig_algo_wgap.do` | `data/derived/...` | `data/derived/...` | International migration (with gap) |
| `code/06_sumstats_mobility.do` | `data/derived/...` | `output/tables/...` | Summary statistics |
| `code/07_estimates_international.do` | `data/derived/...` | `output/tables/...` | Main international estimates |
| `code/08_setup_choicemodel.do` | `data/derived/...` | `data/derived/...` | Choice model data setup |
| `code/09_survival.do` | `data/derived/...` | `output/tables/...` | Survival analysis |
| `code/10_allgtd_improvement.do` | `data/derived/...` | `output/tables/...` | GTD matching (all events) |
| `code/10_highcasualty.do` | `data/derived/...` | `output/tables/...` | GTD matching (high-casualty) |
| `code/11_mobility_panel.do` | `data/derived/...` | `output/tables/...` | Mobility panel |
| `code/12_mobility_long_panel.do` | `data/derived/...` | `output/tables/...` | Long panel mobility |

## Instructions to replicators

1. Install the required software listed above.
2. Obtain the raw data files and place them in `data/raw/` as described above.
3. Open a terminal in the project root directory.
4. Run:
   ```
   cd code && stata-se -b do 00_setup.do && cd ..
   make clean && make
   ```
5. Output tables appear in `output/tables/`, figures in `output/figures/`.

---

*This README follows the [Social Science Data Editors' template](https://social-science-data-editors.github.io/template_README/).*
