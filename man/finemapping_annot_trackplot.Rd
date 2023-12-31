% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/plots.R
\name{finemapping_annot_trackplot}
\alias{finemapping_annot_trackplot}
\title{Make gene track plot}
\usage{
finemapping_annot_trackplot(
  finemapstats,
  region,
  gene.annots,
  bigSNP,
  txdb,
  genome = c("hg19", "hg38"),
  genetrack_db = c("txdb", "gene.annots", "UCSC"),
  filter_protein_coding_genes = TRUE,
  countsdata,
  peaks,
  HiC_loops,
  filter_HiCloops_genes = NULL,
  filter_HiCloops_snps = NULL,
  data_colors = seq_along(countsdata),
  data_ylim = c(0, 1),
  color_pip_by = c("locus", "cs", "none"),
  highlight_snps = NULL,
  highlight_colors = "pink",
  genelabel_side = c("above", "right", "left", "below"),
  track.sizes = NULL,
  rotation.title = 90,
  verbose = FALSE
)
}
\arguments{
\item{finemapstats}{A GRanges object or data frame of finemapping summary statistics}

\item{region}{A GRanges object or data frame for the genomic range to plot}

\item{gene.annots}{A GRanges object of gene annotations}

\item{bigSNP}{A bigsnpr object attached via bigsnpr::snp_attach()}

\item{txdb}{A txdb object of gene annotations}

\item{genome}{Genome assembly version, hg19 (default) or hg38.}

\item{genetrack_db}{Select a gene annotation database to use. Options:
\code{txdb}: use the \code{txdb} objec.
\code{gene.annots}: use the \code{gene.annots} object.
\code{UCSC} uses \verb{UCSC knownGene} annotations.}

\item{filter_protein_coding_genes}{If TRUE, only shows protein coding gene}

\item{countsdata}{A list of counts data}

\item{peaks}{A list of peaks}

\item{HiC_loops}{A list of HiC loops, e.g. PC-HiC, ABC, etc.}

\item{filter_HiCloops_genes}{If TRUE, only shows HiC loops connected to
the gene(s)}

\item{filter_HiCloops_snps}{If TRUE, only shows HiC loops connected to
the SNP(s)}

\item{data_colors}{Colors for the \code{countsdata} tracks}

\item{data_ylim}{ylim range for the \code{countsdata} tracks}

\item{color_pip_by}{color SNPs in the PIP track by \code{locus}, \code{cs},
or \code{none} (same color).}

\item{highlight_snps}{SNPs (rsIDs) to highlight}

\item{highlight_colors}{Colors for the highlighted SNPs}

\item{genelabel_side}{Side to put gene labels,
options are: above (default), right, left, below}

\item{track.sizes}{Sizes of the tracks}

\item{rotation.title}{Rotation of the track titles}

\item{verbose}{if TRUE, print detail messages for plotting}
}
\description{
Make gene track plot
}
