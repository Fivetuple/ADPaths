% 
% 
% Readme.txt
% ----------


------------------------------------------------------------------------------------------------

data                                     Data subdirectory for reading and writing files.

tadpole_save_dataset.m                     Reads TADPOLE_D1_D2.csv and saves as tpdata_brain702xt.mat.
                                         TADPOLE_D1_D2.csv is available via https://tadpole.grand-challenge.org/data/

create_three_sets.m                      Creates AD, MCI and NL sets.                        

create_training_set.m                    Creates matched AD, MCI and NL sets.                        

create_test_set.m                        Creates AD, MCI and NL sets, all disjoint from the training set

plot_roi_timeseries.m                    (unused) Plots time series of TADPOLE dynamic variables.

plot_interactions.m                      Plots graph of Hippocampus vs Wholebrain etc. for the sets AD-NL and AD-MCI.

create_features.m                        Creates features for both training and test sets.

create_features_plot.m                   Copy of create_features with a block to plot features.

classify_features.m                      Logistic regression using features from pairs of sets.

compare_features.m                       Display bar charts of features for the sets AD-NL and AD-MCI.
------------------------------------------------------------------------------------------------

arch                                     Code no longer used.
