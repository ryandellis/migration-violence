# ==============================================================================
# Makefile — Migration and Insurgent Violence
#
# Usage:
#   make              Build everything (only stale targets)
#   make all          Same as above
#   make clean        Remove all generated files
#   make tables       Build only tables
#   make figures      Build only figures
#   make sync         Push updated output to Overleaf via Git bridge
#
# Dependency graph:
#
#   RAW VFD DATA
#       → 01_clean → VFD_data_clean.dta
#       → 02_wrangle → VFD_data_wrangled.dta, VFD_with_internal.dta
#       → 03_internal_mig → (updates VFD_with_internal.dta)
#       → 04_01_sample → VFD_baseline_unrestricted.dta,
#                         VFD_restricted_1monthmin.dta, etc.
#       → 04_02_sample_wgap → VFD_restricted_1monthmin_GAP.dta
#       → 05_01_intl_mig → VFD_restricted_1monthmin_with_migration.dta
#       → 05_02_intl_mig_wgap → VFD_restricted_1monthmin_with_migration_GAP.dta
#
#   From VFD_restricted_1monthmin_with_migration.dta (the main analysis dataset):
#       → 06_sumstats   → summary statistics tables
#       → 07_estimates  → regression tables + marginal effects figures
#       → 07_02_estimates_xt → panel regression tables + figures
#       → 08_choicemodel → choice model tables
#       → 09_survival   → survival figures
#       → 11_mobility   → stacked event study figures
#       → 12_mobility_long → long panel event study figures
#
#   Auxiliary (z_ scripts, run independently):
#       → z_merge_allgtd      → allgtd_clean.dta (from QGIS CSVs)
#       → z_merge_highcasualty → all_highcasualty_clean.dta (from QGIS CSVs)
#
#   From analysis dataset + auxiliary merges:
#       → 10_allgtd      → GTD violence tables + bar figures
#       → 10_highcasualty → high-casualty tables + figures
#
# ==============================================================================

# ---- OS detection for Stata path ----
ifeq ($(OS),Windows_NT)
    STATA := cmd.exe /C run_stata.bat
else
    UNAME := $(shell uname -s)
    ifeq ($(UNAME),Linux)
        ifneq (,$(findstring microsoft,$(shell uname -r 2>/dev/null | tr A-Z a-z)))
            STATA := cmd.exe /C run_stata.bat
        else
            STATA := stata-se -b do
        endif
    else
        STATA := stata-se -b do
    endif
endif

LATEXMK   := latexmk -pdf -quiet -cd

# ---- Overleaf Git bridge ----
OVERLEAF_DIR := /mnt/c/Users/ellisrya/overleaf-migration-violence

# ---- Shorthand paths ----
D  := data/derived
R  := data/raw
T  := output/tables
F  := output/figures
C  := code

# ---- Phony targets ----
.PHONY: all clean tables figures sync data analysis

all: tables figures

data: $(D)/VFD_restricted_1monthmin_with_migration.dta \
      $(D)/VFD_restricted_1monthmin_with_migration_GAP.dta \
      $(D)/allgtd_clean.dta \
      $(D)/all_highcasualty_clean.dta

# ==============================================================================
# DATA CLEANING (01–03)
# ==============================================================================

$(D)/VFD_data_clean.dta: $(R)/VFD_data/fullpanel_analysis.dta \
                          $(C)/01_clean_VFD_data.do $(C)/_config.do
	cd $(C) && $(STATA) 01_clean_VFD_data.do

$(D)/VFD_data_wrangled.dta $(D)/VFD_with_internal.dta &: \
                          $(D)/VFD_data_clean.dta \
                          $(C)/02_wrangle_VFD_data.do $(C)/_config.do
	cd $(C) && $(STATA) 02_wrangle_VFD_data.do

# 03 merges back into VFD_with_internal using VFD_data_wrangled
# It updates VFD_with_internal.dta in place
$(D)/VFD_with_internal_mig.dta: $(D)/VFD_with_internal.dta \
                                 $(D)/VFD_data_wrangled.dta \
                                 $(C)/03_internal_mig_algorithm_VFD.do $(C)/_config.do
	cd $(C) && $(STATA) 03_internal_mig_algorithm_VFD.do

# ==============================================================================
# SAMPLE RESTRICTIONS (04)
# ==============================================================================

$(D)/VFD_restricted_1monthmin.dta: $(D)/VFD_with_internal.dta \
                                    $(C)/04_01_sample_restrictions_and_imputation_gap_dropped.do \
                                    $(C)/_config.do
	cd $(C) && $(STATA) 04_01_sample_restrictions_and_imputation_gap_dropped.do

$(D)/VFD_restricted_1monthmin_GAP.dta: $(D)/VFD_with_internal.dta \
                                        $(C)/04_02_sample_restrictions_and_imputation_wgap.do \
                                        $(C)/_config.do
	cd $(C) && $(STATA) 04_02_sample_restrictions_and_imputation_wgap.do

# ==============================================================================
# INTERNATIONAL MIGRATION ALGORITHM (05)
# ==============================================================================

# 05_01 also reads feasibleborderpoints.dta from derived
$(D)/VFD_restricted_1monthmin_with_migration.dta: \
                          $(D)/VFD_restricted_1monthmin.dta \
                          $(C)/05_01_international_mig_algo.do $(C)/_config.do
	cd $(C) && $(STATA) 05_01_international_mig_algo.do

$(D)/VFD_restricted_1monthmin_with_migration_GAP.dta: \
                          $(D)/VFD_restricted_1monthmin_GAP.dta \
                          $(C)/05_02_international_mig_algo_wgap.do $(C)/_config.do
	cd $(C) && $(STATA) 05_02_international_mig_algo_wgap.do

# ==============================================================================
# AUXILIARY DATA (z_ scripts)
# These read from CSVs produced by QGIS spatial matching (manual step).
# The CSVs are treated as inputs; the z_ scripts clean and merge them.
# ==============================================================================

$(D)/allgtd_clean.dta: $(D)/5km_all_gtd_matches.csv \
                        $(D)/20km_all_gtd_matches.csv \
                        $(C)/z_merge_allgtd.do $(C)/_config.do
	cd $(C) && $(STATA) z_merge_allgtd.do

$(D)/all_highcasualty_clean.dta: $(D)/5km_highcasualty_matches.csv \
                                  $(D)/20km_highcasualty_matches.csv \
                                  $(C)/z_merge_highcasualty.do $(C)/_config.do
	cd $(C) && $(STATA) z_merge_highcasualty.do

# ==============================================================================
# SUMMARY STATISTICS (06)
# ==============================================================================

SUMSTAT_TABLES := $(T)/sumstat5km1_1monthmin.tex \
                  $(T)/sumstat20km1_1monthmin.tex \
                  $(T)/sumstat_monthly.tex \
                  $(T)/sumstat_mig_1monthmin.tex \
                  $(T)/balance_quartiles.tex

$(SUMSTAT_TABLES) &: $(D)/VFD_restricted_1monthmin_with_migration.dta \
                    $(C)/06_sumstats_mobility.do $(C)/_config.do
	cd $(C) && $(STATA) 06_sumstats_mobility.do

# ==============================================================================
# MAIN ESTIMATES (07)
# ==============================================================================

MAIN_TABLES := $(T)/simple_logit_combo_ctrls.tex \
               $(T)/simple_logit_combo_ied.tex \
               $(T)/simple_poisson_combo_ctrls.tex \
               $(T)/simple_probit_combo_ctrls.tex \
               $(T)/sanitycheck.tex \
               $(T)/quadtratic.tex

MAIN_FIGURES := $(F)/migration_levels_ctrls.png \
                $(F)/nonmig_levels_ctrls.png \
                $(F)/migration_levels_ctrls20.png \
                $(F)/nonmig_levels_ctrls20.png \
                $(F)/migration_elasticities_ctrls.png \
                $(F)/migration_elasticities_ctrls20.png \
                $(F)/nonmig_elasticities_ctrls.png \
                $(F)/nonmig_elasticities_ctrls20.png \
                $(F)/migration_dydx_ctrls.png \
                $(F)/nonmig_dydx_ctrls.png

$(MAIN_TABLES) $(MAIN_FIGURES) &: $(D)/VFD_restricted_1monthmin_with_migration.dta \
                                 $(C)/07_estimates_international.do $(C)/_config.do
	cd $(C) && $(STATA) 07_estimates_international.do

# 07_02 overwrites some of the same files — run after 07 if both are needed.
# Uncomment if 07_02 is the preferred specification:
# $(MAIN_TABLES) $(MAIN_FIGURES) &: $(D)/VFD_restricted_1monthmin_with_migration.dta \
#                                  $(C)/07_02_estimates_international_xt.do $(C)/_config.do
# 	cd $(C) && $(STATA) 07_02_estimates_international_xt.do

# ==============================================================================
# CHOICE MODEL (08)
# ==============================================================================

$(T)/cmclogit_combo.tex: $(D)/VFD_restricted_1monthmin_with_migration.dta \
                          $(C)/08_setup_choicemodel.do $(C)/_config.do
	cd $(C) && $(STATA) 08_setup_choicemodel.do

# ==============================================================================
# SURVIVAL ANALYSIS (09)
# ==============================================================================

SURVIVAL_FIGURES := $(F)/survival_ext_lax_5km.png \
                    $(F)/survival_ext_strict_5km.png \
                    $(F)/survival_internal_5km.png \
                    $(F)/survival_dropout_5km.png \
                    $(F)/survival_combo.png

$(SURVIVAL_FIGURES) &: $(D)/VFD_restricted_1monthmin_with_migration.dta \
                      $(C)/09_survival.do $(C)/_config.do
	cd $(C) && $(STATA) 09_survival.do

# ==============================================================================
# GTD / HIGH-CASUALTY ANALYSIS (10)
# ==============================================================================

GTD_TABLES := $(T)/bands_logit_sigact.tex

GTD_FIGURES := $(F)/killbarslenient5km.png \
               $(F)/killbarslenient20km.png \
               $(F)/killbarsrestrictive5km.png \
               $(F)/killbarsrestrictive20km.png \
               $(F)/killbarsinternal5km.png \
               $(F)/killbarsinternal20km.png

$(GTD_TABLES) $(GTD_FIGURES) &: $(D)/VFD_restricted_1monthmin_with_migration.dta \
                               $(D)/allgtd_clean.dta \
                               $(C)/10_allgtd_improvement.do $(C)/_config.do
	cd $(C) && $(STATA) 10_allgtd_improvement.do

HC_TABLES := $(T)/casualty_logit_combo.tex \
             $(T)/casualty_logit_combo_ktag.tex \
             $(T)/casualty_logit_combo_wtag.tex

HC_FIGURES := $(F)/highcasualty_levels.png \
              $(F)/highcasualty20_levels.png

$(HC_TABLES) $(HC_FIGURES) &: $(D)/VFD_restricted_1monthmin_with_migration.dta \
                             $(D)/all_highcasualty_clean.dta \
                             $(C)/10_highcasualty.do $(C)/_config.do
	cd $(C) && $(STATA) 10_highcasualty.do

# ==============================================================================
# MOBILITY PANELS (11–12)
# ==============================================================================

# MOBILITY_FIGURES := $(F)/stackedeventstudy_distance_jmp.png \
#                     $(F)/stackedeventstudy_dtaglpm_jmp.png \
#                     $(F)/stackedeventstudy_ptaglpm_jmp.png \
#                     $(F)/stackedeventstudy_dtag_jmp.png \
#                     $(F)/stackedeventstudy_ptag_jmp.png

# $(MOBILITY_FIGURES) &: $(D)/VFD_restricted_1monthmin_with_migration.dta \
#                       $(C)/11_mobility_panel.do $(C)/_config.do
# 	cd $(C) && $(STATA) 11_mobility_panel.do

LONGPANEL_FIGURES := $(F)/bigstackedeventstudy_ptaglpm_jmp.png \
                     $(F)/bigstackedeventstudy_distance_jmp.png \
                     $(F)/bigstackedeventstudy_dtaglpm_jmp.png

# LONGPANEL disabled — not used in final paper
# $(C)/12_mobility_long_panel.do $(C)/_config.do
# cd $(C) && $(STATA) 12_mobility_long_panel.do

# ==============================================================================
# AGGREGATE TARGETS
# ==============================================================================

tables: $(SUMSTAT_TABLES) $(MAIN_TABLES) $(T)/cmclogit_combo.tex \
        $(GTD_TABLES) $(HC_TABLES)

figures: $(MAIN_FIGURES) $(SURVIVAL_FIGURES) $(GTD_FIGURES) $(HC_FIGURES) \
# $(MOBILITY_FIGURES)

# ==============================================================================
# COMPILE PAPER (uncomment when manuscript \input{} paths are updated)
# ==============================================================================
# paper/main.pdf: paper/main.tex paper/references.bib \
#                 $(SUMSTAT_TABLES) $(MAIN_TABLES) $(GTD_TABLES) $(HC_TABLES) \
#                 $(T)/cmclogit_combo.tex \
#                 $(MAIN_FIGURES) $(SURVIVAL_FIGURES) $(GTD_FIGURES) \
#                 $(HC_FIGURES) $(MOBILITY_FIGURES) $(LONGPANEL_FIGURES)
# 	$(LATEXMK) paper/main.tex

# ==============================================================================
# SYNC TO OVERLEAF
# ==============================================================================
sync:
	@if [ ! -d "$(OVERLEAF_DIR)" ]; then \
		echo "Error: Overleaf directory not found at $(OVERLEAF_DIR)"; \
		exit 1; \
	fi
	@echo "Syncing output to Overleaf..."
	@mkdir -p $(OVERLEAF_DIR)/tables $(OVERLEAF_DIR)/figures
	cp $(T)/*.tex $(OVERLEAF_DIR)/tables/ 2>/dev/null || true
	cp $(F)/*.png $(OVERLEAF_DIR)/figures/ 2>/dev/null || true
	cp $(F)/*.pdf $(OVERLEAF_DIR)/figures/ 2>/dev/null || true
	cp paper/references.bib $(OVERLEAF_DIR)/ 2>/dev/null || true
	cd $(OVERLEAF_DIR) && git add -A && \
		git diff-index --quiet HEAD || \
		git commit -m "Auto-update $$(date '+%Y-%m-%d %H:%M')" && \
		git push origin master
	@echo "Done."

# ==============================================================================
# CLEAN
# ==============================================================================
clean:
	rm -f $(D)/*.dta
	rm -f $(D)/stacks/*.dta $(D)/bigstacks/*.dta
	rm -f $(T)/*.tex
	rm -f $(F)/*.png $(F)/*.pdf
	rm -f $(C)/*.log $(C)/*.smcl
	@echo "Cleaned. Run 'make' to rebuild from scratch."
	@echo "Note: QGIS-generated CSVs in data/derived/ are preserved."
