%% **Master's Thesis - Section 3**
% Benjamin Menashe

% This is the main script for the machine learning section of Benjamin's
% Master's thesis project. This script:
%   1. imports data from excel file
%   2. selects predictors and responses
%   3. trains, evaluates, ranks, and exports different models using 5-fold
%   validation. hyperparameters can be changed in specific functions.
%   4. in some cases, predictor importance is calculated.

    % There are 3 predictor sets we use:
    %   a. pre-neural - using the neural data from the pre scans only.
    %   b. all-pre - using neural and behavioral data from pre scans.
    %   c. change - using neural and behav data from pre scans change data
    %   (post-pre).
    
    % There are 3 responses we want to predict:
    %   a. Phonological Fluency
    %   b. Semantic Fluency
    %   c. Semantic Comprehension
    
path = 'C:\Users\Benjamin\Documents\Benjamin_Thesis';
dataFile = 'ML_wide4';

%% import data
clear variables
clc

mlData = xlsread(dataFile);

