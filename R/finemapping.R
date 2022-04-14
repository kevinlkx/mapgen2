
#' @title Prepare SuSiE data
#' @description Adds torus results to cleaned summary statistics
#' @param sumstats a tibble or data frame containing raw summary statistics
#' @param torus_pip a tibble containing PIP of each SNP (result from run_torus)
#' @param torus_fdr a tibble containing the FDR of each region (result from run_torus)
#' @return tibble of summary statistics updated with torus output
#' @export
prepare_susie_data <- function(sumstats, torus_pip, torus_fdr, fdr_thresh=0.1){

  # keep loci at fdr_thresh FDR (10% by default)
  chunks <- torus_fdr$region_id[torus_fdr$fdr < fdr_thresh]
  sumstats <- sumstats[sumstats$locus %in% chunks, ]

  # Add Torus PIP
  sumstats <- dplyr::inner_join(sumstats, torus_pip, by='snp')

  return(sumstats)

}

#' @title Run finemapping
#' @description Runs SuSiE with L = 1
#' @param sumstats a tibble or data frame containing raw summary statistics; must have header!
#' @param bigSNP a bigsnpr object attached via bigsnpr::snp_attach()
#' @param priortype prior type: "torus" or "uniform".
#' @return list of finemapping results; one per LD block
#' @export
run_finemapping <- function(sumstats, bigSNP, priortype = c('torus', 'uniform')){

  stopifnot('torus_pip' %in% colnames(sumstats))
  priortype <- match.arg(priortype)

  if(priortype == 'torus'){
    usePrior <- TRUE
  }else if(priortype == 'uniform'){
    usePrior <- FALSE
  }

  chunks <- unique(sumstats$locus)

  susie_res <- list()
  for(z in seq_along(chunks)){
    cat(sprintf('Finemapping chunks %d of %d ...\n', z, length(chunks)))
    susie.df <- sumstats[sumstats$locus == z, ]
    susie_res[[as.character(z)]] <- run.susie(susie.df, bigSNP, z, L = 1, prior = usePrior)
  }

  return(susie_res)

}


#' @title run SUSIE
#' @param sumstats summary statistics
#'
#' @param bigSNP bigSNP object
#' @param ldchunk LD chunk
#' @param L Number of causal signals
#' @param prior Logical, if TRUE, use the \code{torus_pip} column
#' in \code{sumstats} as prior
#'
#' @export
run_susie <- function(sumstats, bigSNP, ldchunk, L, prior){

  sub.sumstats <- sumstats[sumstats$locus == ldchunk, ]
  if(nrow(sub.sumstats) > 1){
    X <- bigSNP$genotypes[ , sub.sumstats$bigSNP_index]
    X <- scale(X, center = T, scale = T)
    zhat <- sub.sumstats$zscore
    R <- cov2cor((crossprod(X) + tcrossprod(zhat))/nrow(X))
    if(prior){
      res <- suppressWarnings(susieR::susie_rss(z = zhat,
                                                prior_weights = sub.sumstats$torus_pip,
                                                R = R,
                                                L = L,
                                                verbose = F))
    }
    else{
      res <- suppressWarnings(susieR::susie_rss(z = zhat,
                                                R = R,
                                                L = L,
                                                verbose = F))
    }
    return(res)
  }
}

#' @title merges SuSiE results with original summary statistics data frame
#' @description  merges SuSiE results with original summary statistics data frame
#' This function assumes L = 1. ONLY ONE CREDIBLE SET PER LOCUS!
#' @param susie_results data frame containing SuSiE finemapping result
#' @param sumstats data frame containing summary statistics
#'
#' @export
merge_susie_sumstats <- function(susie_results, sumstats){

  sumstats$susie_pip <- 0
  sumstats$CS <- 0
  loci <- names(susie_results)

  for(l in loci){
    n.snps <- length(susie_results[[l]]$pip)
    sumstats[sumstats$locus == as.numeric(l), 'susie_pip'] <- susie_results[[l]]$pip

    snps.in.cs <- rep(0, n.snps)
    if(!is.null(susie_results[[l]]$sets$cs)){
      snps.in.cs[unlist(susie_results[[l]]$sets$cs$L1)] <- 1
    }
    sumstats[sumstats$locus == as.numeric(l), 'CS'] <- snps.in.cs
  }
  return(sumstats)
}


#' @title Process fine mapping summary statistics data
#'
#' @param finemap A data frame of fine-mapping summary statistics
#' @param snp Name of the SNP ID (rsID) column in the summary statistics data
#' @param chr Name of the chr column in the summary statistics data frame
#' @param pos Name of the position column in the summary statistics data frame
#' @param pip Name of the PIP column in the summary statistics data frame
#' @param pval Name of the P-value column in the summary statistics data frame
#' @param zscore Name of the z-score column in the summary statistics data frame
#' @param cs Name of the CS column in the summary statistics data frame
#' @param locus Name of the locus column in the summary statistics data frame
#' @param cols.to.keep columns to keep in the returned data frame
#' @param pip.thresh PIP threshold (default = 1e-5).
#' @param filterCS If TRUE, limiting to SNPs within credible sets.
#' @param maxCS Maximum number of credible sets (default = 10).
#' @importFrom magrittr %>%
#' @return A GRanges object with cleaned and filtered fine-mapping summary statistics
#' @export
process_finemapping_sumstat <- function(finemap,
                                        snp = 'snp',
                                        chr = 'chr',
                                        pos = 'pos',
                                        pip = 'pip',
                                        pval = 'pval',
                                        zscore = 'zscore',
                                        cs = 'cs',
                                        locus = 'locus',
                                        pip.thresh = 1e-5,
                                        filterCS = FALSE,
                                        maxCS = 10,
                                        cols.to.keep = c('snp','chr','pos', 'pip', 'pval', 'zscore','cs', 'locus')){

  cat('Process fine-mapping summary statistics ...\n')
  finemap <- finemap %>% dplyr::rename(snp = all_of(snp),
                                       chr = all_of(chr),
                                       pos = all_of(pos),
                                       pip = all_of(pip))

  if( pval %in% colnames(finemap) ){
    finemap <- dplyr::rename(finemap, pval = all_of(pval))
  }else{
    finemap$pval <- NA
  }

  if( zscore %in% colnames(finemap) ){
    finemap <- dplyr::rename(finemap, zscore = all_of(zscore))
  }else{
    finemap$zscore <- NA
  }

  if( cs %in% colnames(finemap) ){
    finemap <- dplyr::rename(finemap, cs = all_of(cs))
  }else{
    finemap$cs <- NA
  }

  if( locus %in% colnames(finemap) ){
    finemap <- dplyr::rename(finemap, locus = all_of(locus))
  }else{
    finemap$locus <- NA
  }

  # Remove SNPs with multiple PIPs
  if(any(duplicated(paste(finemap$chr, finemap$pos)))){
    cat('Remove SNPs with multiple PIPs...\n')
    finemap <- finemap %>% dplyr::arrange(desc(pip)) %>% dplyr::distinct(chr, pos, .keep_all = TRUE)
  }

  finemap.gr <- GenomicRanges::makeGRangesFromDataFrame(finemap, start.field = 'pos', end.field = 'pos', keep.extra.columns = TRUE)
  finemap.gr$chr <- finemap$chr
  finemap.gr$pos <- finemap$pos
  mcols(finemap.gr) <- mcols(finemap.gr)[,cols.to.keep]
  GenomeInfoDb::seqlevelsStyle(finemap.gr) <- 'UCSC'

  if( pip.thresh > 0 ) {
    cat('Filter SNPs with PIP threshold of', pip.thresh, '\n')
    finemap.gr <- finemap.gr[finemap.gr$pip > pip.thresh, ]
  }

  if( filterCS ) {
    cat('Filter SNPs in credible sets \n')
    finemap.gr <- finemap.gr[finemap.gr$cs >= 1 & finemap.gr$cs <= maxCS, ]
  }

  return(finemap.gr)

}