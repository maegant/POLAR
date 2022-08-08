%% Script: example_script
% Description: This script runs the main POLAR framework and queries the user for feedback.
%
% Author: Maegan Tucker (mtucker@caltech.edu)
% Date: July 20, 2022
% ________________________________________

%% Run toolbox_addpath to add the POLAR toolbox to your path
toolbox_addpath % add toolbox path

%% Define user settings
clear settings

%%%%%% general settings
settings.save_folder = 'saved_results'; % specify folder where results will be saved
settings.b = 0; % number of past actions to compare with current trial
settings.n = 2; % number of actions to sample in each trial
settings.sampling.type = 1; % 1 for regret minimization, 2 for active learning, 3 for random sampling
settings.feedback.types = [1,2,3]; %include 1 for preferences, 2 for suggestions, and 3 for ordinal labels
settings.useSubset = 1; % 0 for no dim reduction, 1 for dim reduction
settings.subsetSize = 500; % number of samples to include in each subset for active learning

%%%%%% simulation settings
settings.maxIter = 100; % max number of iterations for simulations
settings.simulation.simulated_pref_noise = 0.02; % synthetic feedback noise parameter
settings.simulation.simulated_coac_noise = 0.04; % synthetic feedback noise parameter
settings.simulation.simulated_ord_noise = 0.1;  % synthetic feedback noise parameter

%%%%%% ordinal settings
settings.feedback.num_ord_categories = 3; %number of ordinal categories
                       
%%%%%% active learning settings
settings.roa.use_roa = 1; % 0 for no ROA, 1 to avoid ROA
settings.roa.ord_label_to_avoid = 1; % largest ordinal category to avoid
settings.roa.lambda = 0.4; % hyperparameter for conservativeness of avoidance

%%%%%%  Parameter settings - add as many as you need

% Dimension 1 
ind = 1;
settings.parameters(ind).name = 'Dim1_name'; 
settings.parameters(ind).discretization = 0.1;
settings.parameters(ind).lower = 0;
settings.parameters(ind).upper = 1;
settings.parameters(ind).lengthscale = 0.5;

% Dimension 2 
ind = ind+1;
settings.parameters(ind).name = 'Dim2_name'; 
settings.parameters(ind).discretization = 0.1;
settings.parameters(ind).lower = 0;
settings.parameters(ind).upper = 1;
settings.parameters(ind).lengthscale = 0.5;

%%%%%%  Hyperparameters
settings.gp_settings.linkfunction = 'sigmoid';
settings.gp_settings.signal_variance = 1;   % Gaussian process amplitude parameter
settings.gp_settings.pref_noise = 0.02;    % How noisy are the user's preferences?
settings.gp_settings.coac_noise = 0.04;    % How noisy are the user's suggestions?
settings.gp_settings.ord_noise = 0.1;      % How noisy are the user's labels?
settings.gp_settings.GP_noise_var = 1e-4;       % GP model noise--need at least a very small


alg = PBL(settings);

%% Run Experiment
alg.reset; %optional - used to reset algorithm 
export_folder = 'example_yamls'; %optional input - location for writing yaml files of actions to sample
plottingFlag = 0; %flag for showing plots during experiment 
isSave = 1; % flag for saving results
alg.runExperiment(plottingFlag,isSave,export_folder);
% NOTE: ENTER -1 FOR PREFERENCE TO STOP LEARNING ALGORITHM


