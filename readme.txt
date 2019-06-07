# 
# 
# Readme.txt
#
# Code for "Using Path Signatures to Predict a Diagnosis of Alzheimer's Disease."
#
# Acknowledgement: TADPOLE Grand Challenge https://tadpole.grand-challenge.org/.
#
# Requirement: MATLAB  R2018a, though the codes may work on earlier versions.
#
# (c) 2019 Paul Moore - moorep@maths.ox.ac.uk 
#
# This software is provided 'as is' with no warranty or other guarantee of
# fitness for the user's purpose.  Please let the author know of any bugs
# or potential improvements.
------------------------------------------------------------------------------------------------

data                                     Data subdirectory for reading and writing files.  The user needs to add TADPOLE_D1_D2.csv
                                         which is available via https://tadpole.grand-challenge.org/data/

data/vars.txt                            List of variables which were used in experiments, though not for the paper.

tadpole_save_dataset.m                   Reads TADPOLE_D1_D2.csv and saves as tpdata_brain702xt.mat.
                                         
create_three_sets.m                      Creates AD, MCI and NL sets.                        

create_training_set.m                    Creates matched AD, MCI and NL sets.                        

create_test_set.m                        Creates AD, MCI and NL sets, all disjoint from the training set

plot_interactions.m                      Plots graph of Hippocampus vs Wholebrain etc. for the sets AD-NL and AD-MCI.

create_features.m                        Creates features for both training and test sets.

create_features_plot.m                   Copy of create_features with a block to plot features.

classify_features.m                      Logistic regression using features from pairs of sets.

compare_features.m                       Display bar charts of features for the sets AD-NL and AD-MCI.

------------------------------------------------------------------------------------------------

matlab_esig_shell.m                      Wrapper for esig, which must be installed using pip install esig.

------------------------------------------------------------------------------------------------

