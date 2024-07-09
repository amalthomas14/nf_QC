#!/usr/bin/env Rscript
#Author: A.Thomas

args <- commandArgs(trailingOnly = TRUE)

# List of output TSV files from arguments
files <- args

# Ensure we have at least one file
if (length(files) == 0) {
   cat("Usage: Rscript plot_A_T.R <file1> <file2> ... <fileN>\n")
   cat("  <file1>, <file2>, ... <fileN> : Paths to the input TSV files\n")
   stop("No input files provided")
}

# Load necessary libraries
suppressPackageStartupMessages({
    library(ggplot2)
    library(dplyr)
    library(tidyr)
})

# Function to read and process individual TSV file
read_sample <- function(file) {
  df <- read.delim(file, header = TRUE)
  df$sample <- gsub("_output\\.tsv", "", basename(file))  # Extract sample name from file name
  return(df)
}


# Read and combine all samples into a single data frame
data_list <- lapply(files, read_sample)

combined_data <- do.call(rbind, data_list)
combined_data
# Save the combined data to a file
write.table(combined_data, "combined_data_A_T.tsv", row.names = FALSE, quote = F,
            sep = "\t")

# Pivot the data for easier plotting
combined_data_long <- pivot_longer(combined_data, 
                                   cols = starts_with("T_") | starts_with("A_"), 
                                   names_to = c("type", "bin", ".value"),
                                   names_sep = "_")
# Correct the bin format
combined_data_long$bin <- gsub("\\.", "-", combined_data_long$bin)
#combined_data_long

# Define bins for plotting
bins <- unique(data_T$bin)
#bins
bins_order <- c('0-5', '5-10', '10-15', '15-20', '20-25', '25-30', 
                '30-35', '35-40', '40-45', '45-50', '50-55', '55-60', 
                '60-65', '65-70', '70-75', '75-80', '80-85', '85-90', 
                '90-95', '95-100')
combined_data_long$bin <- factor(combined_data_long$bin, levels = bins_order)
# Separate data for T and A
data_T <- combined_data_long %>% filter(type == "T")
data_A <- combined_data_long %>% filter(type == "A")

# Plotting function
plot_nucleotide <- function(data, nucleotide) {
  ggplot(data, aes(x = bin, y = pct, group = sample, color = sample)) +
    geom_line() +
    labs(title = paste("%", nucleotide, "in reads"),
         x = paste("%", nucleotide),
         y = "Percentage of total reads",
         color = "Sample") +
    theme_minimal() +
    theme(
      legend.position = "right",
      legend.direction = "vertical",
      axis.text.x = element_text(angle = 30, hjust = 1)
      #panel.grid.major = element_blank(),
      #panel.grid.minor = element_blank()
    )
}

# Plot for T
plot_T <- plot_nucleotide(data_T, "T")
plot_A <- plot_nucleotide(data_A, "A")

# Save plot for T in PDF and PNG formats
ggsave("T_nucleotide_plot.pdf", plot_T, dpi = 300, height = 7, width = 7, units = "cm")
ggsave("T_nucleotide_plot.png", plot_T, dpi = 300, height = 7, width = 7, units = "cm")

# Save plot for A in PDF and PNG formats
ggsave("A_nucleotide_plot.pdf", plot_A, dpi = 300, height = 7, width = 7, units = "cm")
ggsave("A_nucleotide_plot.png", plot_A, dpi = 300, height = 7, width = 7, units = "cm")
