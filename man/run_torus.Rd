% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/torus.R
\name{run_torus}
\alias{run_torus}
\title{Run enrichment analysis and compute SNP-level priors using TORUS}
\usage{
run_torus(
  torus_annot_file,
  torus_zscore_file,
  option = c("est", "est-prior", "fdr"),
  torus_path = "torus"
)
}
\arguments{
\item{torus_annot_file}{SNP annotation file prepared by
the \code{prepare_torus_input_files} function.
The SNP annotation file contains SNP-level genomic annotations used by
TORUS analysis. The annotation file uses a header to specify the number
and the nature (categorical or continuous) of the annotations.
The first column with the header "SNP" represents the SNP name.
The following columns represent specific annotations.
For categorical/discrete annotations, the header should have a suffix "_d";
whereas for continuous annotations, the header should ends with "_c".}

\item{torus_zscore_file}{Summary statistics from single SNP association
analysis, prepared by
the \code{prepare_torus_input_files} function.
Should be compressed in gzip format.}

\item{option}{TORUS options:
\dQuote{est}, obtain estimates of enrichment parameters and their confidence intervals;
\dQuote{est-prior}, perform enrichment analysis and
compute SNP-level priors using
the estimated enrichment estimates for each locus;
or \dQuote{fdr}, perform Bayesian FDR control, and output the result.}

\item{torus_path}{Path to \code{torus} executable.}
}
\value{
a list of enrichment results, SNP-level prior probabilities,
and/or FDR result.
Enrichment result contains the point estimate (MLE) of the log odds ratio,
as well as 95\% confidence interval for the corresponding point estimate.
}
\description{
Perform enrichment analysis using TORUS and then
compute SNP-level priors using the enrichment estimates.
}
\examples{
\dontrun{
# Get enrichment estimates and confidence intervals
torus.result <- run_torus("torus_annotations.txt.gz",
                          "torus_zscore.txt.gz",
                          option = "est")

# Get enrichment estimates and compute SNP-level priors
torus.result <- run_torus("torus_annotations.txt.gz",
                          "torus_zscore.txt.gz",
                          option = "est-prior")
# Bayesian FDR control
torus.result <- run_torus("torus_annotations.txt.gz",
                          "torus_zscore.txt.gz",
                          option = "fdr")
}
}
