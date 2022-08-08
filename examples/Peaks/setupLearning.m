%% Function: setupLearning
%
% Description: This script establishes the parameters and settings of the
%   learning problem.
%
% Author: Maegan Tucker, mtucker@caltech.edu
% ________________________________________

function [ settings ] = setupLearning()
% --------------------- General Settings ----------------------------------
settings.save_folder = 'saved_results';

% choose max number of iterations to run
settings.maxIter = 100;

% choose size of buffer
settings.b = 1;

% choose number of samples to query each iteration
settings.n = 1;

% choose if synthetic objective function is used to automatically dictate
% feedback
settings.useSyntheticObjective = 1;

% -------------------- Posterior Sampling Settings  -----------------------

% choose regret minimization (1) or active learning (2)
settings.sampling.type = 2;

% choose settings of regret minimization
switch settings.sampling.type
    case 1
        settings.gp_settings.cov_scale = 0.5;
        settings.sampling.useSubset = 0; %true or false
        settings.sampling.isCoordinateAligned = 0; %choose if random linear subspace is coordinate aligned
    case 2
        settings.sampling.useSubset = 1; %true or false
        settings.sampling.subsetSize = 100; %choose subset size
        
        % Region of Avoidance (ordinal categories to avoid)
        settings.roa.use_roa = 0; %true or false
end

% ------------------------ Feedback Settings  -----------------------------

% choose types of feedback (list choices in vector)
% 1 - preferences
% 2 - coactive
% 3 - ordinal
settings.feedback.types = [1,2,3];
settings.feedback.num_ord_categories = 5;

% ROA settings
settings.roa.use_roa = 0;

% -------------- Action Space Properties (need to be selected) ------------

settings.parameters(1).name = 'x';
settings.parameters(2).name = 'y';
for i = 1:length(settings.parameters)
    settings.parameters(i).discretization = 0.5;
    settings.parameters(i).lower = -3;
    settings.parameters(i).upper = 3;
    settings.parameters(i).lengthscale = 0.7;
end

% --------------------- Learning Hyperparameters --------------------------

settings.gp_settings.linkfunction = 'sigmoid';
settings.gp_settings.signal_variance = 1;   % Gaussian process amplitude parameter
settings.gp_settings.pref_noise = 0.02;    % How noisy are the user's preferences?
settings.gp_settings.pref_noise = 0.04;    % How noisy are the user's preferences?
settings.gp_settings.ord_noise = 0.15;
settings.gp_settings.GP_noise_var = 1e-6;        % GP model noise--need at least a very small

% --------------------- CUSTOM SETTINGS -----------------------------------
settings.objective_settings = [];
end