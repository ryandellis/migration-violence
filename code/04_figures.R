# ==============================================================================
# 04_figures.R — Main figures
# ==============================================================================

library(ggplot2)
library(haven)     # read .dta files

# --- Paths ---
root    <- ".."
derived <- file.path(root, "data", "derived")
figdir  <- file.path(root, "output", "figures")

# --- Load data ---
# df <- read_dta(file.path(derived, "clean.dta"))

# --- Figure 1 ---
# p1 <- ggplot(df, aes(x = x1, y = y)) +
#   geom_point(alpha = 0.5) +
#   geom_smooth(method = "lm", se = TRUE) +
#   theme_minimal(base_size = 12) +
#   labs(x = "X Variable", y = "Y Variable")
#
# ggsave(file.path(figdir, "fig1.pdf"), p1, width = 6, height = 4)

message("04_figures.R complete.")
