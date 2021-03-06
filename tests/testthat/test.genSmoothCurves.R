library(monocle)
context("genSmoothCurves")

test_that("genSmoothCurves() fits (branched) smooth curves for the data along pseudotime", {

	set.seed(123)

	lung <- load_lung()

	cds_subset <- buildLineageBranchCellDataSet(cds = lung, #lineage_states = trajectory_states,
	                                                lineage_labels = NULL, stretch = T,
	                                                weighted = T)

  	trend_formula = "~sm.ns(Pseudotime, df = 3)*Lineage"
    overlap_rng <- c(0, max(pData(cds_subset)$Pseudotime))

  	formula_all_variables <- all.vars(as.formula(trend_formula))
  
    cds_branchA <- cds_subset[, pData(cds_subset)[, 'State'] ==
                              2]
	cds_branchB <- cds_subset[, pData(cds_subset)[, 'State'] ==
                              3]
	t_rng <- range(pData(cds_branchA)$Pseudotime)
  	str_new_cds_branchA <- data.frame(Pseudotime = seq(overlap_rng[1], overlap_rng[2],
                                                     length.out = 100), Lineage = as.factor(2))
  	colnames(str_new_cds_branchA)[2] <- formula_all_variables[2] #interaction term can be terms rather than Lineage
  
  	str_new_cds_branchB <- data.frame(Pseudotime = seq(overlap_rng[1], overlap_rng[2],
                                                     length.out = 100), Lineage = as.factor(3))
  
  	colnames(str_new_cds_branchB)[2] <- formula_all_variables[2] #interaction term can be terms rather than Lineage

	str_branchAB_expression_curve_matrix <- genSmoothCurves(cds_subset, cores = 1, trend_formula = "~sm.ns(Pseudotime, df = 3)*Lineage",  weights = pData(cds_subset)$weight,
	                                                          relative_expr = T, pseudocount = 0, new_data = rbind(str_new_cds_branchA, str_new_cds_branchB))

	expect_equal(dim(str_branchAB_expression_curve_matrix), c(218, 200))

	expect_equal(str_branchAB_expression_curve_matrix['ENSMUSG00000000058.6', 1:5], c(0.2579, 0.2864, 0.3180, 0.3530, 0.3917), tolerance=1e-4)
	
	#test the parallel 
	cds_subset <- buildLineageBranchCellDataSet(lung, #lineage_states = trajectory_states,
	                                            lineage_labels = c(2, 3), stretch = T,
	                                            weighted = T)
	str_new_cds_branchA <- data.frame(Pseudotime = seq(0, 100,
	                                                   length.out = 100), Lineage = as.factor(unique(as.character(pData(cds_subset)$Lineage))[1]))   
	str_new_cds_branchB <- data.frame(Pseudotime = seq(0, 100,
	                                                   length.out = 100), Lineage = as.factor(unique(as.character(pData(cds_subset)$Lineage))[2]))
	
	lung_smooth_df <- genSmoothCurves(cds_subset[, ], cores=detectCores(), trend_formula = "~sm.ns(Pseudotime, df = 3)*Lineage",
	                               relative_expr = F, pseudocount = 1, 
	                               new_data = rbind(str_new_cds_branchA, str_new_cds_branchB))
	
	expect_equal(dim(lung_smooth_df), c(as.vector(nrow(cds_subset)), 200))
	
})
